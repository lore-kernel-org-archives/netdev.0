From: Yang Shi <yang.shi@linaro.org>
Subject: [PATCH V3 2/2] arm64: bpf: make BPF prologue and epilogue align with ARM64 AAPCS
Date: Fri, 13 Nov 2015 10:09:57 -0800
Message-ID: <1447438197-31838-1-git-send-email-yang.shi@linaro.org>
References: <CABg9mct-hnEhvT6y9ZgCC8nMan5YbmByQa_ViUWzeea6ToqG4A@mail.gmail.com>
Cc: zlim.lnx@gmail.com, xi.wang@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linaro-kernel@lists.linaro.org, yang.shi@linaro.org
To: ast@kernel.org, daniel@iogearbox.net, catalin.marinas@arm.com,
	will.deacon@arm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CABg9mct-hnEhvT6y9ZgCC8nMan5YbmByQa_ViUWzeea6ToqG4A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Save and restore FP/LR in BPF prog prologue and epilogue, save SP to FP
in prologue in order to get the correct stack backtrace.

However, ARM64 JIT used FP (x29) as eBPF fp register, FP is subjected to
change during function call so it may cause the BPF prog stack base address
change too.

Use x25 to replace FP as BPF stack base register (fp). Since x25 is callee
saved register, so it will keep intact during function call.
It is initialized in BPF prog prologue when BPF prog is started to run
everytime. When BPF prog exits, it could be just tossed.

So, the BPF stack layout looks like:

                                 high
         original A64_SP =>   0:+-----+ BPF prologue
                                |FP/LR|
         current A64_FP =>  -16:+-----+
                                | ... | callee saved registers
         BPF fp register => -64:+-----+
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

CC: Zi Shen Lim <zlim.lnx@gmail.com>
CC: Xi Wang <xi.wang@gmail.com>
Signed-off-by: Yang Shi <yang.shi@linaro.org>
---
V3 --> V2:
* Make FP point to FP'
* Fix a compile warning

 arch/arm64/net/bpf_jit_comp.c | 37 +++++++++++++++++++++++++++++++------
 1 file changed, 31 insertions(+), 6 deletions(-)

diff --git a/arch/arm64/net/bpf_jit_comp.c b/arch/arm64/net/bpf_jit_comp.c
index ac8b548..c131e38 100644
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
@@ -155,16 +155,42 @@ static void build_prologue(struct jit_ctx *ctx)
 	stack_size += 4; /* extra for skb_copy_bits buffer */
 	stack_size = STACK_ALIGN(stack_size);
 
+	/*
+	 * BPF prog stack layout
+	 *
+	 *                         high
+	 * original A64_SP =>   0:+-----+ BPF prologue
+	 *                        |FP/LR|
+	 * current A64_FP =>  -16:+-----+
+	 *                        | ... | callee saved registers
+	 * BPF fp register => -64:+-----+
+	 *                        |     |
+	 *                        | ... | BPF prog stack
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
+	emit(A64_MOV(1, A64_FP, A64_SP), ctx);
+
 	/* Save callee-saved register */
 	emit(A64_PUSH(r6, r7, A64_SP), ctx);
 	emit(A64_PUSH(r8, r9, A64_SP), ctx);
 	if (ctx->tmp_used)
 		emit(A64_PUSH(tmp1, tmp2, A64_SP), ctx);
 
-	/* Set up frame pointer */
+	/* Set up BPF prog stack base register (x25) */
 	emit(A64_MOV(1, fp, A64_SP), ctx);
 
-	/* Set up BPF stack */
+	/* Set up function call stack */
 	emit(A64_SUB_I(1, A64_SP, A64_SP, stack_size), ctx);
 
 	/* Clear registers A and X */
@@ -179,7 +205,6 @@ static void build_epilogue(struct jit_ctx *ctx)
 	const u8 r7 = bpf2a64[BPF_REG_7];
 	const u8 r8 = bpf2a64[BPF_REG_8];
 	const u8 r9 = bpf2a64[BPF_REG_9];
-	const u8 fp = bpf2a64[BPF_REG_FP];
 	const u8 tmp1 = bpf2a64[TMP_REG_1];
 	const u8 tmp2 = bpf2a64[TMP_REG_2];
 	int stack_size = MAX_BPF_STACK;
@@ -196,8 +221,8 @@ static void build_epilogue(struct jit_ctx *ctx)
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
