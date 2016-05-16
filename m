From: Yang Shi <yang.shi@linaro.org>
Subject: [PATCH v2 net-next] bpf: arm64: remove callee-save registers use for tmp registers
Date: Mon, 16 May 2016 16:36:26 -0700
Message-ID: <1463441786-32224-1-git-send-email-yang.shi@linaro.org>
Cc: will.deacon@arm.com, catalin.marinas@arm.com, daniel@iogearbox.net,
	zlim.lnx@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linaro-kernel@lists.linaro.org, yang.shi@linaro.org
To: ast@kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In the current implementation of ARM64 eBPF JIT, R23 and R24 are used for
tmp registers, which are callee-saved registers. This leads to variable size
of JIT prologue and epilogue. The latest blinding constant change prefers to
constant size of prologue and epilogue. AAPCS reserves R9 ~ R15 for temp
registers which not need to be saved/restored during function call. So, replace
R23 and R24 to R10 and R11, and remove tmp_used flag to save 2 instructions for
some jited BPF program.

CC: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Zi Shen Lim <zlim.lnx@gmail.com>
Signed-off-by: Yang Shi <yang.shi@linaro.org>
---
Changelog v1 --> v2:
  * Updated stack diagram
  * Added the comment from Zi for the commit log
  * Added Zi's Acked-by

Apply on top of Daniel's blinding constant patchset

 arch/arm64/net/bpf_jit_comp.c | 34 +++++-----------------------------
 1 file changed, 5 insertions(+), 29 deletions(-)

diff --git a/arch/arm64/net/bpf_jit_comp.c b/arch/arm64/net/bpf_jit_comp.c
index d0d5190..49ba37e 100644
--- a/arch/arm64/net/bpf_jit_comp.c
+++ b/arch/arm64/net/bpf_jit_comp.c
@@ -51,9 +51,9 @@ static const int bpf2a64[] = {
 	[BPF_REG_9] = A64_R(22),
 	/* read-only frame pointer to access stack */
 	[BPF_REG_FP] = A64_R(25),
-	/* temporary register for internal BPF JIT */
-	[TMP_REG_1] = A64_R(23),
-	[TMP_REG_2] = A64_R(24),
+	/* temporary registers for internal BPF JIT */
+	[TMP_REG_1] = A64_R(10),
+	[TMP_REG_2] = A64_R(11),
 	/* temporary register for blinding constants */
 	[BPF_REG_AX] = A64_R(9),
 };
@@ -61,7 +61,6 @@ static const int bpf2a64[] = {
 struct jit_ctx {
 	const struct bpf_prog *prog;
 	int idx;
-	int tmp_used;
 	int epilogue_offset;
 	int *offset;
 	u32 *image;
@@ -154,8 +153,6 @@ static void build_prologue(struct jit_ctx *ctx)
 	const u8 r8 = bpf2a64[BPF_REG_8];
 	const u8 r9 = bpf2a64[BPF_REG_9];
 	const u8 fp = bpf2a64[BPF_REG_FP];
-	const u8 tmp1 = bpf2a64[TMP_REG_1];
-	const u8 tmp2 = bpf2a64[TMP_REG_2];
 
 	/*
 	 * BPF prog stack layout
@@ -167,7 +164,7 @@ static void build_prologue(struct jit_ctx *ctx)
 	 *                        | ... | callee saved registers
 	 *                        +-----+
 	 *                        |     | x25/x26
-	 * BPF fp register => -80:+-----+ <= (BPF_FP)
+	 * BPF fp register => -64:+-----+ <= (BPF_FP)
 	 *                        |     |
 	 *                        | ... | BPF prog stack
 	 *                        |     |
@@ -189,8 +186,6 @@ static void build_prologue(struct jit_ctx *ctx)
 	/* Save callee-saved register */
 	emit(A64_PUSH(r6, r7, A64_SP), ctx);
 	emit(A64_PUSH(r8, r9, A64_SP), ctx);
-	if (ctx->tmp_used)
-		emit(A64_PUSH(tmp1, tmp2, A64_SP), ctx);
 
 	/* Save fp (x25) and x26. SP requires 16 bytes alignment */
 	emit(A64_PUSH(fp, A64_R(26), A64_SP), ctx);
@@ -210,8 +205,6 @@ static void build_epilogue(struct jit_ctx *ctx)
 	const u8 r8 = bpf2a64[BPF_REG_8];
 	const u8 r9 = bpf2a64[BPF_REG_9];
 	const u8 fp = bpf2a64[BPF_REG_FP];
-	const u8 tmp1 = bpf2a64[TMP_REG_1];
-	const u8 tmp2 = bpf2a64[TMP_REG_2];
 
 	/* We're done with BPF stack */
 	emit(A64_ADD_I(1, A64_SP, A64_SP, STACK_SIZE), ctx);
@@ -220,8 +213,6 @@ static void build_epilogue(struct jit_ctx *ctx)
 	emit(A64_POP(fp, A64_R(26), A64_SP), ctx);
 
 	/* Restore callee-saved register */
-	if (ctx->tmp_used)
-		emit(A64_POP(tmp1, tmp2, A64_SP), ctx);
 	emit(A64_POP(r8, r9, A64_SP), ctx);
 	emit(A64_POP(r6, r7, A64_SP), ctx);
 
@@ -317,7 +308,6 @@ static int build_insn(const struct bpf_insn *insn, struct jit_ctx *ctx)
 			emit(A64_UDIV(is64, dst, dst, src), ctx);
 			break;
 		case BPF_MOD:
-			ctx->tmp_used = 1;
 			emit(A64_UDIV(is64, tmp, dst, src), ctx);
 			emit(A64_MUL(is64, tmp, tmp, src), ctx);
 			emit(A64_SUB(is64, dst, dst, tmp), ctx);
@@ -390,49 +380,41 @@ emit_bswap_uxt:
 	/* dst = dst OP imm */
 	case BPF_ALU | BPF_ADD | BPF_K:
 	case BPF_ALU64 | BPF_ADD | BPF_K:
-		ctx->tmp_used = 1;
 		emit_a64_mov_i(is64, tmp, imm, ctx);
 		emit(A64_ADD(is64, dst, dst, tmp), ctx);
 		break;
 	case BPF_ALU | BPF_SUB | BPF_K:
 	case BPF_ALU64 | BPF_SUB | BPF_K:
-		ctx->tmp_used = 1;
 		emit_a64_mov_i(is64, tmp, imm, ctx);
 		emit(A64_SUB(is64, dst, dst, tmp), ctx);
 		break;
 	case BPF_ALU | BPF_AND | BPF_K:
 	case BPF_ALU64 | BPF_AND | BPF_K:
-		ctx->tmp_used = 1;
 		emit_a64_mov_i(is64, tmp, imm, ctx);
 		emit(A64_AND(is64, dst, dst, tmp), ctx);
 		break;
 	case BPF_ALU | BPF_OR | BPF_K:
 	case BPF_ALU64 | BPF_OR | BPF_K:
-		ctx->tmp_used = 1;
 		emit_a64_mov_i(is64, tmp, imm, ctx);
 		emit(A64_ORR(is64, dst, dst, tmp), ctx);
 		break;
 	case BPF_ALU | BPF_XOR | BPF_K:
 	case BPF_ALU64 | BPF_XOR | BPF_K:
-		ctx->tmp_used = 1;
 		emit_a64_mov_i(is64, tmp, imm, ctx);
 		emit(A64_EOR(is64, dst, dst, tmp), ctx);
 		break;
 	case BPF_ALU | BPF_MUL | BPF_K:
 	case BPF_ALU64 | BPF_MUL | BPF_K:
-		ctx->tmp_used = 1;
 		emit_a64_mov_i(is64, tmp, imm, ctx);
 		emit(A64_MUL(is64, dst, dst, tmp), ctx);
 		break;
 	case BPF_ALU | BPF_DIV | BPF_K:
 	case BPF_ALU64 | BPF_DIV | BPF_K:
-		ctx->tmp_used = 1;
 		emit_a64_mov_i(is64, tmp, imm, ctx);
 		emit(A64_UDIV(is64, dst, dst, tmp), ctx);
 		break;
 	case BPF_ALU | BPF_MOD | BPF_K:
 	case BPF_ALU64 | BPF_MOD | BPF_K:
-		ctx->tmp_used = 1;
 		emit_a64_mov_i(is64, tmp2, imm, ctx);
 		emit(A64_UDIV(is64, tmp, dst, tmp2), ctx);
 		emit(A64_MUL(is64, tmp, tmp, tmp2), ctx);
@@ -503,12 +485,10 @@ emit_cond_jmp:
 	case BPF_JMP | BPF_JNE | BPF_K:
 	case BPF_JMP | BPF_JSGT | BPF_K:
 	case BPF_JMP | BPF_JSGE | BPF_K:
-		ctx->tmp_used = 1;
 		emit_a64_mov_i(1, tmp, imm, ctx);
 		emit(A64_CMP(1, dst, tmp), ctx);
 		goto emit_cond_jmp;
 	case BPF_JMP | BPF_JSET | BPF_K:
-		ctx->tmp_used = 1;
 		emit_a64_mov_i(1, tmp, imm, ctx);
 		emit(A64_TST(1, dst, tmp), ctx);
 		goto emit_cond_jmp;
@@ -518,7 +498,6 @@ emit_cond_jmp:
 		const u8 r0 = bpf2a64[BPF_REG_0];
 		const u64 func = (u64)__bpf_call_base + imm;
 
-		ctx->tmp_used = 1;
 		emit_a64_mov_i64(tmp, func, ctx);
 		emit(A64_PUSH(A64_FP, A64_LR, A64_SP), ctx);
 		emit(A64_MOV(1, A64_FP, A64_SP), ctx);
@@ -564,7 +543,6 @@ emit_cond_jmp:
 	case BPF_LDX | BPF_MEM | BPF_H:
 	case BPF_LDX | BPF_MEM | BPF_B:
 	case BPF_LDX | BPF_MEM | BPF_DW:
-		ctx->tmp_used = 1;
 		emit_a64_mov_i(1, tmp, off, ctx);
 		switch (BPF_SIZE(code)) {
 		case BPF_W:
@@ -588,7 +566,6 @@ emit_cond_jmp:
 	case BPF_ST | BPF_MEM | BPF_B:
 	case BPF_ST | BPF_MEM | BPF_DW:
 		/* Load imm to a register then store it */
-		ctx->tmp_used = 1;
 		emit_a64_mov_i(1, tmp2, off, ctx);
 		emit_a64_mov_i(1, tmp, imm, ctx);
 		switch (BPF_SIZE(code)) {
@@ -612,7 +589,6 @@ emit_cond_jmp:
 	case BPF_STX | BPF_MEM | BPF_H:
 	case BPF_STX | BPF_MEM | BPF_B:
 	case BPF_STX | BPF_MEM | BPF_DW:
-		ctx->tmp_used = 1;
 		emit_a64_mov_i(1, tmp, off, ctx);
 		switch (BPF_SIZE(code)) {
 		case BPF_W:
@@ -798,7 +774,7 @@ struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *prog)
 
 	/* 1. Initial fake pass to compute ctx->idx. */
 
-	/* Fake pass to fill in ctx->offset and ctx->tmp_used. */
+	/* Fake pass to fill in ctx->offset. */
 	if (build_body(&ctx)) {
 		prog = orig_prog;
 		goto out_off;
-- 
2.0.2
