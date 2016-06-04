From: Zi Shen Lim <zlim.lnx@gmail.com>
Subject: [PATCH net-next 1/3] arm64: bpf: implement bpf_tail_call() helper
Date: Sat,  4 Jun 2016 15:00:28 -0700
Message-ID: <1465077630-633-1-git-send-email-zlim.lnx@gmail.com>
Cc: Zi Shen Lim <zlim.lnx@gmail.com>, Yang Shi <yang.shi@linaro.org>,
	Alexei Starovoitov <ast@kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support for JMP_CALL_X (tail call) introduced by commit 04fd61ab36ec
("bpf: allow bpf programs to tail-call other bpf programs").

bpf_tail_call() arguments:
  ctx   - context pointer passed to next program
  array - pointer to map which type is BPF_MAP_TYPE_PROG_ARRAY
  index - index inside array that selects specific program to run

In this implementation arm64 JIT jumps into callee program after prologue,
so callee program reuses the same stack. For tail_call_cnt, we use the
callee-saved R26 (which was already saved/restored but previously unused
by JIT).

With this patch a tail call generates the following code on arm64:

  if (index >= array->map.max_entries)
      goto out;

  34:   mov     x10, #0x10                      // #16
  38:   ldr     w10, [x1,x10]
  3c:   cmp     w2, w10
  40:   b.ge    0x0000000000000074

  if (tail_call_cnt > MAX_TAIL_CALL_CNT)
      goto out;
  tail_call_cnt++;

  44:   mov     x10, #0x20                      // #32
  48:   cmp     x26, x10
  4c:   b.gt    0x0000000000000074
  50:   add     x26, x26, #0x1

  prog = array->ptrs[index];
  if (prog == NULL)
      goto out;

  54:   mov     x10, #0x68                      // #104
  58:   ldr     x10, [x1,x10]
  5c:   ldr     x11, [x10,x2]
  60:   cbz     x11, 0x0000000000000074

  goto *(prog->bpf_func + prologue_size);

  64:   mov     x10, #0x20                      // #32
  68:   ldr     x10, [x11,x10]
  6c:   add     x10, x10, #0x20
  70:   br      x10
  74:

Signed-off-by: Zi Shen Lim <zlim.lnx@gmail.com>
---
 arch/arm64/net/bpf_jit.h      |   3 +-
 arch/arm64/net/bpf_jit_comp.c | 105 ++++++++++++++++++++++++++++++++++++++----
 2 files changed, 98 insertions(+), 10 deletions(-)

diff --git a/arch/arm64/net/bpf_jit.h b/arch/arm64/net/bpf_jit.h
index aee5637..7c16e54 100644
--- a/arch/arm64/net/bpf_jit.h
+++ b/arch/arm64/net/bpf_jit.h
@@ -1,7 +1,7 @@
 /*
  * BPF JIT compiler for ARM64
  *
- * Copyright (C) 2014-2015 Zi Shen Lim <zlim.lnx@gmail.com>
+ * Copyright (C) 2014-2016 Zi Shen Lim <zlim.lnx@gmail.com>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -55,6 +55,7 @@
 #define A64_BL(imm26) A64_BRANCH((imm26) << 2, LINK)
 
 /* Unconditional branch (register) */
+#define A64_BR(Rn)  aarch64_insn_gen_branch_reg(Rn, AARCH64_INSN_BRANCH_NOLINK)
 #define A64_BLR(Rn) aarch64_insn_gen_branch_reg(Rn, AARCH64_INSN_BRANCH_LINK)
 #define A64_RET(Rn) aarch64_insn_gen_branch_reg(Rn, AARCH64_INSN_BRANCH_RETURN)
 
diff --git a/arch/arm64/net/bpf_jit_comp.c b/arch/arm64/net/bpf_jit_comp.c
index 49ba37e..51abc97 100644
--- a/arch/arm64/net/bpf_jit_comp.c
+++ b/arch/arm64/net/bpf_jit_comp.c
@@ -18,6 +18,7 @@
 
 #define pr_fmt(fmt) "bpf_jit: " fmt
 
+#include <linux/bpf.h>
 #include <linux/filter.h>
 #include <linux/printk.h>
 #include <linux/skbuff.h>
@@ -33,6 +34,7 @@ int bpf_jit_enable __read_mostly;
 
 #define TMP_REG_1 (MAX_BPF_JIT_REG + 0)
 #define TMP_REG_2 (MAX_BPF_JIT_REG + 1)
+#define TCALL_CNT (MAX_BPF_JIT_REG + 2)
 
 /* Map BPF registers to A64 registers */
 static const int bpf2a64[] = {
@@ -54,6 +56,8 @@ static const int bpf2a64[] = {
 	/* temporary registers for internal BPF JIT */
 	[TMP_REG_1] = A64_R(10),
 	[TMP_REG_2] = A64_R(11),
+	/* tail_call_cnt */
+	[TCALL_CNT] = A64_R(26),
 	/* temporary register for blinding constants */
 	[BPF_REG_AX] = A64_R(9),
 };
@@ -146,13 +150,18 @@ static inline int epilogue_offset(const struct jit_ctx *ctx)
 
 #define STACK_SIZE STACK_ALIGN(_STACK_SIZE)
 
-static void build_prologue(struct jit_ctx *ctx)
+#define PROLOGUE_OFFSET 8
+
+static int build_prologue(struct jit_ctx *ctx)
 {
 	const u8 r6 = bpf2a64[BPF_REG_6];
 	const u8 r7 = bpf2a64[BPF_REG_7];
 	const u8 r8 = bpf2a64[BPF_REG_8];
 	const u8 r9 = bpf2a64[BPF_REG_9];
 	const u8 fp = bpf2a64[BPF_REG_FP];
+	const u8 tcc = bpf2a64[TCALL_CNT];
+	const int idx0 = ctx->idx;
+	int cur_offset;
 
 	/*
 	 * BPF prog stack layout
@@ -162,8 +171,6 @@ static void build_prologue(struct jit_ctx *ctx)
 	 *                        |FP/LR|
 	 * current A64_FP =>  -16:+-----+
 	 *                        | ... | callee saved registers
-	 *                        +-----+
-	 *                        |     | x25/x26
 	 * BPF fp register => -64:+-----+ <= (BPF_FP)
 	 *                        |     |
 	 *                        | ... | BPF prog stack
@@ -183,18 +190,90 @@ static void build_prologue(struct jit_ctx *ctx)
 	emit(A64_PUSH(A64_FP, A64_LR, A64_SP), ctx);
 	emit(A64_MOV(1, A64_FP, A64_SP), ctx);
 
-	/* Save callee-saved register */
+	/* Save callee-saved registers */
 	emit(A64_PUSH(r6, r7, A64_SP), ctx);
 	emit(A64_PUSH(r8, r9, A64_SP), ctx);
+	emit(A64_PUSH(fp, tcc, A64_SP), ctx);
 
-	/* Save fp (x25) and x26. SP requires 16 bytes alignment */
-	emit(A64_PUSH(fp, A64_R(26), A64_SP), ctx);
-
-	/* Set up BPF prog stack base register (x25) */
+	/* Set up BPF prog stack base register */
 	emit(A64_MOV(1, fp, A64_SP), ctx);
 
+	/* Initialize tail_call_cnt */
+	emit(A64_MOVZ(1, tcc, 0, 0), ctx);
+
 	/* Set up function call stack */
 	emit(A64_SUB_I(1, A64_SP, A64_SP, STACK_SIZE), ctx);
+
+	cur_offset = ctx->idx - idx0;
+	if (cur_offset != PROLOGUE_OFFSET) {
+		pr_err_once("PROLOGUE_OFFSET = %d, expected %d!\n",
+			    cur_offset, PROLOGUE_OFFSET);
+		return -1;
+	}
+	return 0;
+}
+
+static int out_offset = -1; /* initialized on the first pass of build_body() */
+static int emit_bpf_tail_call(struct jit_ctx *ctx)
+{
+	/* bpf_tail_call(void *prog_ctx, struct bpf_array *array, u64 index) */
+	const u8 r2 = bpf2a64[BPF_REG_2];
+	const u8 r3 = bpf2a64[BPF_REG_3];
+
+	const u8 tmp = bpf2a64[TMP_REG_1];
+	const u8 prg = bpf2a64[TMP_REG_2];
+	const u8 tcc = bpf2a64[TCALL_CNT];
+	const int idx0 = ctx->idx;
+#define cur_offset (ctx->idx - idx0)
+#define jmp_offset (out_offset - (cur_offset))
+	size_t off;
+
+	/* if (index >= array->map.max_entries)
+	 *     goto out;
+	 */
+	off = offsetof(struct bpf_array, map.max_entries);
+	emit_a64_mov_i64(tmp, off, ctx);
+	emit(A64_LDR32(tmp, r2, tmp), ctx);
+	emit(A64_CMP(0, r3, tmp), ctx);
+	emit(A64_B_(A64_COND_GE, jmp_offset), ctx);
+
+	/* if (tail_call_cnt > MAX_TAIL_CALL_CNT)
+	 *     goto out;
+	 * tail_call_cnt++;
+	 */
+	emit_a64_mov_i64(tmp, MAX_TAIL_CALL_CNT, ctx);
+	emit(A64_CMP(1, tcc, tmp), ctx);
+	emit(A64_B_(A64_COND_GT, jmp_offset), ctx);
+	emit(A64_ADD_I(1, tcc, tcc, 1), ctx);
+
+	/* prog = array->ptrs[index];
+	 * if (prog == NULL)
+	 *     goto out;
+	 */
+	off = offsetof(struct bpf_array, ptrs);
+	emit_a64_mov_i64(tmp, off, ctx);
+	emit(A64_LDR64(tmp, r2, tmp), ctx);
+	emit(A64_LDR64(prg, tmp, r3), ctx);
+	emit(A64_CBZ(1, prg, jmp_offset), ctx);
+
+	/* goto *(prog->bpf_func + prologue_size); */
+	off = offsetof(struct bpf_prog, bpf_func);
+	emit_a64_mov_i64(tmp, off, ctx);
+	emit(A64_LDR64(tmp, prg, tmp), ctx);
+	emit(A64_ADD_I(1, tmp, tmp, sizeof(u32) * PROLOGUE_OFFSET), ctx);
+	emit(A64_BR(tmp), ctx);
+
+	/* out: */
+	if (out_offset == -1)
+		out_offset = cur_offset;
+	if (cur_offset != out_offset) {
+		pr_err_once("tail_call out_offset = %d, expected %d!\n",
+			    cur_offset, out_offset);
+		return -1;
+	}
+	return 0;
+#undef cur_offset
+#undef jmp_offset
 }
 
 static void build_epilogue(struct jit_ctx *ctx)
@@ -506,6 +585,11 @@ emit_cond_jmp:
 		emit(A64_POP(A64_FP, A64_LR, A64_SP), ctx);
 		break;
 	}
+	/* tail call */
+	case BPF_JMP | BPF_CALL | BPF_X:
+		if (emit_bpf_tail_call(ctx))
+			return -EFAULT;
+		break;
 	/* function return */
 	case BPF_JMP | BPF_EXIT:
 		/* Optimization: when last instruction is EXIT,
@@ -780,7 +864,10 @@ struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *prog)
 		goto out_off;
 	}
 
-	build_prologue(&ctx);
+	if (build_prologue(&ctx)) {
+		prog = orig_prog;
+		goto out_off;
+	}
 
 	ctx.epilogue_offset = ctx.idx;
 	build_epilogue(&ctx);
-- 
1.9.1
