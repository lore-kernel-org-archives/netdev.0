From: Zi Shen Lim <zlim.lnx@gmail.com>
Subject: [PATCH] arm64: bpf: fix buffer pointer
Date: Wed, 18 Nov 2015 00:56:02 -0800
Message-ID: <1447836962-4086-1-git-send-email-zlim.lnx@gmail.com>
Cc: Zi Shen Lim <zlim.lnx@gmail.com>, daniel@iogearbox.net,
	yang.shi@linaro.org, xi.wang@gmail.com,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org
To: davem@davemloft.net, ast@kernel.org, catalin.marinas@arm.com,
	will.deacon@arm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

During code review, I noticed we were passing a bad buffer pointer
to bpf_load_pointer helper function called by jitted code.

Point to the buffer allocated by JIT, so we don't silently corrupt
other parts of the stack.

Signed-off-by: Zi Shen Lim <zlim.lnx@gmail.com>
---
 arch/arm64/net/bpf_jit_comp.c | 27 +++++++++++++--------------
 1 file changed, 13 insertions(+), 14 deletions(-)

diff --git a/arch/arm64/net/bpf_jit_comp.c b/arch/arm64/net/bpf_jit_comp.c
index d6a53ef..7cf032b 100644
--- a/arch/arm64/net/bpf_jit_comp.c
+++ b/arch/arm64/net/bpf_jit_comp.c
@@ -139,6 +139,12 @@ static inline int epilogue_offset(const struct jit_ctx *ctx)
 /* Stack must be multiples of 16B */
 #define STACK_ALIGN(sz) (((sz) + 15) & ~15)
 
+#define _STACK_SIZE \
+	(MAX_BPF_STACK \
+	 + 4 /* extra for skb_copy_bits buffer */)
+
+#define STACK_SIZE STACK_ALIGN(_STACK_SIZE)
+
 static void build_prologue(struct jit_ctx *ctx)
 {
 	const u8 r6 = bpf2a64[BPF_REG_6];
@@ -150,10 +156,6 @@ static void build_prologue(struct jit_ctx *ctx)
 	const u8 rx = bpf2a64[BPF_REG_X];
 	const u8 tmp1 = bpf2a64[TMP_REG_1];
 	const u8 tmp2 = bpf2a64[TMP_REG_2];
-	int stack_size = MAX_BPF_STACK;
-
-	stack_size += 4; /* extra for skb_copy_bits buffer */
-	stack_size = STACK_ALIGN(stack_size);
 
 	/*
 	 * BPF prog stack layout
@@ -165,12 +167,13 @@ static void build_prologue(struct jit_ctx *ctx)
 	 *                        | ... | callee saved registers
 	 *                        +-----+
 	 *                        |     | x25/x26
-	 * BPF fp register => -80:+-----+
+	 * BPF fp register => -80:+-----+ <= (BPF_FP)
 	 *                        |     |
 	 *                        | ... | BPF prog stack
 	 *                        |     |
-	 *                        |     |
-	 * current A64_SP =>      +-----+
+	 *                        +-----+ <= (BPF_FP - MAX_BPF_STACK)
+	 *                        |RSVD | JIT scratchpad
+	 * current A64_SP =>      +-----+ <= (BPF_FP - STACK_SIZE)
 	 *                        |     |
 	 *                        | ... | Function call stack
 	 *                        |     |
@@ -196,7 +199,7 @@ static void build_prologue(struct jit_ctx *ctx)
 	emit(A64_MOV(1, fp, A64_SP), ctx);
 
 	/* Set up function call stack */
-	emit(A64_SUB_I(1, A64_SP, A64_SP, stack_size), ctx);
+	emit(A64_SUB_I(1, A64_SP, A64_SP, STACK_SIZE), ctx);
 
 	/* Clear registers A and X */
 	emit_a64_mov_i64(ra, 0, ctx);
@@ -213,13 +216,9 @@ static void build_epilogue(struct jit_ctx *ctx)
 	const u8 fp = bpf2a64[BPF_REG_FP];
 	const u8 tmp1 = bpf2a64[TMP_REG_1];
 	const u8 tmp2 = bpf2a64[TMP_REG_2];
-	int stack_size = MAX_BPF_STACK;
-
-	stack_size += 4; /* extra for skb_copy_bits buffer */
-	stack_size = STACK_ALIGN(stack_size);
 
 	/* We're done with BPF stack */
-	emit(A64_ADD_I(1, A64_SP, A64_SP, stack_size), ctx);
+	emit(A64_ADD_I(1, A64_SP, A64_SP, STACK_SIZE), ctx);
 
 	/* Restore fs (x25) and x26 */
 	emit(A64_POP(fp, A64_R(26), A64_SP), ctx);
@@ -658,7 +657,7 @@ emit_cond_jmp:
 			return -EINVAL;
 		}
 		emit_a64_mov_i64(r3, size, ctx);
-		emit(A64_ADD_I(1, r4, fp, MAX_BPF_STACK), ctx);
+		emit(A64_SUB_I(1, r4, fp, STACK_SIZE), ctx);
 		emit_a64_mov_i64(r5, (unsigned long)bpf_load_pointer, ctx);
 		emit(A64_PUSH(A64_FP, A64_LR, A64_SP), ctx);
 		emit(A64_MOV(1, A64_FP, A64_SP), ctx);
-- 
1.9.1
