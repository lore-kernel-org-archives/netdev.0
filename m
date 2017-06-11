From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] bpf, arm64: take advantage of stack_depth tracking
Date: Sun, 11 Jun 2017 03:55:27 +0200
Message-ID: <afc90487fc573886a44178c2428f3157312128d8.1497145004.git.daniel@iogearbox.net>
Cc: ast@fb.com, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56391 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751689AbdFKC3n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2017 22:29:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make use of recently implemented stack_depth tracking for arm64 JIT,
so that stack usage can be reduced heavily for programs not using
tail calls at least.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 arch/arm64/net/bpf_jit_comp.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/arch/arm64/net/bpf_jit_comp.c b/arch/arm64/net/bpf_jit_comp.c
index 4f95873..73de2c7 100644
--- a/arch/arm64/net/bpf_jit_comp.c
+++ b/arch/arm64/net/bpf_jit_comp.c
@@ -69,6 +69,7 @@ struct jit_ctx {
 	int epilogue_offset;
 	int *offset;
 	u32 *image;
+	u32 stack_size;
 };
 
 static inline void emit(const u32 insn, struct jit_ctx *ctx)
@@ -145,16 +146,11 @@ static inline int epilogue_offset(const struct jit_ctx *ctx)
 /* Stack must be multiples of 16B */
 #define STACK_ALIGN(sz) (((sz) + 15) & ~15)
 
-#define _STACK_SIZE \
-	(MAX_BPF_STACK \
-	 + 4 /* extra for skb_copy_bits buffer */)
-
-#define STACK_SIZE STACK_ALIGN(_STACK_SIZE)
-
 #define PROLOGUE_OFFSET 8
 
 static int build_prologue(struct jit_ctx *ctx)
 {
+	const struct bpf_prog *prog = ctx->prog;
 	const u8 r6 = bpf2a64[BPF_REG_6];
 	const u8 r7 = bpf2a64[BPF_REG_7];
 	const u8 r8 = bpf2a64[BPF_REG_8];
@@ -176,9 +172,9 @@ static int build_prologue(struct jit_ctx *ctx)
 	 *                        |     |
 	 *                        | ... | BPF prog stack
 	 *                        |     |
-	 *                        +-----+ <= (BPF_FP - MAX_BPF_STACK)
+	 *                        +-----+ <= (BPF_FP - prog->aux->stack_depth)
 	 *                        |RSVD | JIT scratchpad
-	 * current A64_SP =>      +-----+ <= (BPF_FP - STACK_SIZE)
+	 * current A64_SP =>      +-----+ <= (BPF_FP - ctx->stack_size)
 	 *                        |     |
 	 *                        | ... | Function call stack
 	 *                        |     |
@@ -202,8 +198,12 @@ static int build_prologue(struct jit_ctx *ctx)
 	/* Initialize tail_call_cnt */
 	emit(A64_MOVZ(1, tcc, 0, 0), ctx);
 
+	/* 4 byte extra for skb_copy_bits buffer */
+	ctx->stack_size = prog->aux->stack_depth + 4;
+	ctx->stack_size = STACK_ALIGN(ctx->stack_size);
+
 	/* Set up function call stack */
-	emit(A64_SUB_I(1, A64_SP, A64_SP, STACK_SIZE), ctx);
+	emit(A64_SUB_I(1, A64_SP, A64_SP, ctx->stack_size), ctx);
 
 	cur_offset = ctx->idx - idx0;
 	if (cur_offset != PROLOGUE_OFFSET) {
@@ -288,7 +288,7 @@ static void build_epilogue(struct jit_ctx *ctx)
 	const u8 fp = bpf2a64[BPF_REG_FP];
 
 	/* We're done with BPF stack */
-	emit(A64_ADD_I(1, A64_SP, A64_SP, STACK_SIZE), ctx);
+	emit(A64_ADD_I(1, A64_SP, A64_SP, ctx->stack_size), ctx);
 
 	/* Restore fs (x25) and x26 */
 	emit(A64_POP(fp, A64_R(26), A64_SP), ctx);
@@ -732,7 +732,7 @@ static int build_insn(const struct bpf_insn *insn, struct jit_ctx *ctx)
 			return -EINVAL;
 		}
 		emit_a64_mov_i64(r3, size, ctx);
-		emit(A64_SUB_I(1, r4, fp, STACK_SIZE), ctx);
+		emit(A64_SUB_I(1, r4, fp, ctx->stack_size), ctx);
 		emit_a64_mov_i64(r5, (unsigned long)bpf_load_pointer, ctx);
 		emit(A64_BLR(r5), ctx);
 		emit(A64_MOV(1, r0, A64_R(0)), ctx);
-- 
1.9.3
