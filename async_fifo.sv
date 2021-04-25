module async_fifo 
#(parameter AWIDTH = 4, parameter DWIDTH = 8)
(
	wr_clk,
	rd_clk,
	wr_rstb,
	rd_rstb,
	rd_en,
	wr_en,
	rd_data,
	wr_data,
	fifo_full,
	fifo_empty
);

//inputs

//outputs

//internals


always_ff @(posedge rd_clk or negedge rd_rstb) begin
	if(~rd_rstb) begin
		rd_ptr <= 0;
		rd_gray <= 0;
	end
	else begin
		rd_ptr <= rd_ptr_next;
		rd_gray <= rd_gray_next;
	end
end

assign rd_ptr_next = (rd_en & ~fifo_empty) rd_ptr + 1 : 0; 
assign rd_gray_next = (rd_ptr_next >> 1) ^ rd_ptr_next;

always_ff @(posedge rd_clk or negedge rd_rstb) begin
	if(~rd_rstb) begin
		{rd_gray_1ff, rd_gray_2ff} <= ‘0;
	end
	else begin
		{rd_gray_1ff, rd_gray_2ff} <= {rd_gray, rd_gray_1ff} ; 
	end
end
always_ff @(posedge wr_clk or negedge wr_rstb) begin
	if(~wr_rstb) begin
		wr_ptr <= 0;
		wr_gray <= 0;
	end
	else begin
		wr_ptr <= wr_ptr_next;
		wr_gray <= wr_gray_next;
	end
end

assign wr_ptr_next = (wr_en & ~fifo_full) wr_ptr + 1 : 0; 
assign wr_gray_next = (wr_ptr_next >> 1) ^ wr_ptr_next;

always_ff @(posedge wr_clk or negedge wr_rstb) begin
	if(~wr_rstb) begin
		{wr_gray_1ff, wr_gray_2ff} <= ‘0;
	end
	else begin
		{wr_gray_1ff, wr_gray_2ff} <= {wr_gray, wr_gray_1ff} ; 
	end
end

assign fifo_full_val = (~wr_ptr_next[AWIDTH:AWIDTH-1] == rd_gray_2ff[AWIDTH:AWIDTH-1]) & (wr_ptr_next[AWIDTH-1:0] == rd_gray_2ff[AWIDTH-1:0]); 

always_ff @(posedge wr_clk or negedge wr_rstb) begin
	if(~wr_rstb) begin
		fifo_full <= ‘0;
	end
	else begin
		fifo_full <= fifo_full_val; 
	end
end

assign fifo_empty_val = (rd_ptr_next == wr_gray_2ff);

always_ff @(posedge rd_clk or negedge rd_rstb) begin
	if(~rd_rstb) begin
		fifo_empty <= ‘0;
	end
	else begin
		fifo_empty <= fifo_empty_val; 
	end
end

assign rd_data = (rd_en & ~fifo_empty) ? mem[rd_ptr[AWIDTH-1:0]] : ‘0;

always_ff @(posedge wr_clk or negedge wr_rstb) begin
	if(~wr_rstb) begin
		for(int i; i<(2**AWIDTH); i++)
			mem[i] <= ‘0;
	end
	else begin
		mem[wr_ptr[AWIDTH-1:0]] <= (wr_en & ~fifo_full) ? wr_data: mem[wr_ptr[AWIDTH-1:0]]; 
	end
end


endmodule
