From: Yang Shi <yang.shi@linaro.org>
Subject: [PATCH] arm64: bpf: fix JIT stack setup
Date: Fri,  6 Nov 2015 21:34:54 -0800
Message-ID: <1446874494-14500-1-git-send-email-yang.shi@linaro.org>
Cc: zlim.lnx@gmail.com, xi.wang@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linaro-kernel@lists.linaro.org, yang.shi@linaro.org
To: ast@kernel.org, daniel@iogearbox.net, catalin.marinas@arm.com,
	will.deacon@arm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ARM64 JIT used FP (x29) as eBPF fp register, but FP is subjected to
change during function call so it may cause the BPF prog stack base address
change too. Whenever, it pointed to the bottom of BPF prog stack instead of
the top.

So, when copying data via bpf_probe_read, it will be copied to (SP - offset),
then it may overwrite the saved FP/LR.

Use x25 to replace FP as BPF stack base register (fp). Since x25 is callee
saved register, so it will keep intact during function call.
It is initialized in BPF prog prologue when BPF prog is started to run
everytime. When BPF prog exits, it could be just tossed.

Other than this the BPf prog stack base need to be setup before function
call stack.

So, the BPF stack layout looks like:

                                 high
         original A64_SP =>   0:+-----+ BPF prologue
                                |     | FP/LR and callee saved registers
         BPF fp register => +64:+-----+
                                |     |
                                | ... | BPF prog stack
                                |     |
                                |     |
         current A64_SP =>      +-----+
                                |     |
                                | ... | Function call stack
                                |     |
                                +-----+
                                  low

Signed-off-by: Yang Shi <yang.shi@linaro.org>
CC: Zi Shen Lim <zlim.lnx@gmail.com>
CC: Xi Wang <xi.wang@gmail.com>
---
 arch/arm64/net/bpf_jit_comp.c | 38 +++++++++++++++++++++++++++++++-------
 1 file changed, 31 insertions(+), 7 deletions(-)

diff --git a/arch/arm64/net/bpf_jit_comp.c b/arch/arm64/net/bpf_jit_comp.c
index a44e529..6809647 100644
--- a/arch/arm64/net/bpf_jit_comp.c
+++ b/arch/arm64/net/bpf_jit_comp.c
@@ -50,7 +50,7 @@ static const int bpf2a64[] = {
 	[BPF_REG_8] = A64_R(21),
 	[BPF_REG_9] = A64_R(22),
 	/* read-only frame pointer to access stack */
-	[BPF_REG_FP] = A64_FP,
+	[BPF_REG_FP] = A64_R(25),
 	/* temporary register for internal BPF JIT */
 	[TMP_REG_1] = A64_R(23),
 	[TMP_REG_2] = A64_R(24),
@@ -155,18 +155,42 @@ static void build_prologue(struct jit_ctx *ctx)
 	stack_size += 4; /* extra for skb_copy_bits buffer */
 	stack_size = STACK_ALIGN(stack_size);
 
+	/*
+	 * BPF prog stack layout
+	 *
+	 *                         high
+	 * original A64_SP =>   0:+-----+ BPF prologue
+	 *                        |     | FP/LR and callee saved registers
+	 * BPF fp register => +64:+-----+
+	 *                        |     |
+         *                        | ... | BPF prog stack
+	 *                        |     |
+	 *                        |     |
+	 * current A64_SP =>      +-----+
+	 *                        |     |
+	 *                        | ... | Function call stack
+	 *                        |     |
+	 *                        +-----+
+	 *                          low
+	 *
+	 */
+
+	/* Save FP and LR registers to stay align with ARM64 AAPCS */
+	emit(A64_PUSH(A64_FP, A64_LR, A64_SP), ctx);
+
 	/* Save callee-saved register */
 	emit(A64_PUSH(r6, r7, A64_SP), ctx);
 	emit(A64_PUSH(r8, r9, A64_SP), ctx);
 	if (ctx->tmp_used)
 		emit(A64_PUSH(tmp1, tmp2, A64_SP), ctx);
 
-	/* Set up BPF stack */
-	emit(A64_SUB_I(1, A64_SP, A64_SP, stack_size), ctx);
-
-	/* Set up frame pointer */
+	/* Set up BPF prog stack base register (x25) */
 	emit(A64_MOV(1, fp, A64_SP), ctx);
 
+	/* Set up function call stack */
+	emit(A64_SUB_I(1, A64_SP, A64_SP, stack_size), ctx);
+	emit(A64_MOV(1, A64_FP, A64_SP), ctx);
+
 	/* Clear registers A and X */
 	emit_a64_mov_i64(ra, 0, ctx);
 	emit_a64_mov_i64(rx, 0, ctx);
@@ -196,8 +220,8 @@ static void build_epilogue(struct jit_ctx *ctx)
 	emit(A64_POP(r8, r9, A64_SP), ctx);
 	emit(A64_POP(r6, r7, A64_SP), ctx);
 
-	/* Restore frame pointer */
-	emit(A64_MOV(1, fp, A64_SP), ctx);
+	/* Restore FP/LR registers */
+	emit(A64_POP(A64_FP, A64_LR, A64_SP), ctx);
 
 	/* Set return value */
 	emit(A64_MOV(1, A64_R(0), r0), ctx);
-- 
2.0.2
