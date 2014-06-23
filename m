From: Markos Chandras <markos.chandras@imgtec.com>
Subject: [PATCH 13/17] MIPS: bpf: Drop update_on_xread and always initialize the X register
Date: Mon, 23 Jun 2014 10:38:56 +0100
Message-ID: <1403516340-22997-14-git-send-email-markos.chandras@imgtec.com>
References: <1403516340-22997-1-git-send-email-markos.chandras@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Markos Chandras <markos.chandras@imgtec.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	"Alexei Starovoitov" <ast@plumgrid.com>, <netdev@vger.kernel.org>
To: <linux-mips@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailapp01.imgtec.com ([195.59.15.196]:38044 "EHLO
	mailapp01.imgtec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752954AbaFWJjj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2014 05:39:39 -0400
In-Reply-To: <1403516340-22997-1-git-send-email-markos.chandras@imgtec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Previously, update_on_xread() only set the reset flag if SEEN_X hasn't
been set already. However, SEEN_X is used to indicate that X is used
as destination or source register so there are some cases where X
is only used as source register and we really need to make sure that it
has been initialized in time. As a result of which, drop this function and
always set X to zero if it's used in any of the opcodes.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Daniel Borkmann <dborkman@redhat.com>
Cc: Alexei Starovoitov <ast@plumgrid.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Markos Chandras <markos.chandras@imgtec.com>
---
 arch/mips/net/bpf_jit.c | 22 +---------------------
 1 file changed, 1 insertion(+), 21 deletions(-)

diff --git a/arch/mips/net/bpf_jit.c b/arch/mips/net/bpf_jit.c
index 00c4c83972bb..1bcd599d9971 100644
--- a/arch/mips/net/bpf_jit.c
+++ b/arch/mips/net/bpf_jit.c
@@ -119,8 +119,6 @@
 /* Arguments used by JIT */
 #define ARGS_USED_BY_JIT	2 /* only applicable to 64-bit */
 
-#define FLAG_NEED_X_RESET	(1 << 0)
-
 #define SBIT(x)			(1 << (x)) /* Signed version of BIT() */
 
 /**
@@ -549,14 +547,6 @@ static inline u16 align_sp(unsigned int num)
 	return num;
 }
 
-static inline void update_on_xread(struct jit_ctx *ctx)
-{
-	if (!(ctx->flags & SEEN_X))
-		ctx->flags |= FLAG_NEED_X_RESET;
-
-	ctx->flags |= SEEN_X;
-}
-
 static bool is_load_to_a(u16 inst)
 {
 	switch (inst) {
@@ -701,7 +691,7 @@ static void build_prologue(struct jit_ctx *ctx)
 	if (ctx->flags & SEEN_SKB)
 		emit_reg_move(r_skb, MIPS_R_A0, ctx);
 
-	if (ctx->flags & FLAG_NEED_X_RESET)
+	if (ctx->flags & SEEN_X)
 		emit_jit_reg_move(r_X, r_zero, ctx);
 
 	/* Do not leak kernel data to userspace */
@@ -876,7 +866,6 @@ load_common:
 			/* A <- P[X + k:1] */
 			load_order = 0;
 load_ind:
-			update_on_xread(ctx);
 			ctx->flags |= SEEN_OFF | SEEN_X;
 			emit_addiu(r_off, r_X, k, ctx);
 			goto load_common;
@@ -972,7 +961,6 @@ load_ind:
 			break;
 		case BPF_ALU | BPF_MUL | BPF_X:
 			/* A *= X */
-			update_on_xread(ctx);
 			ctx->flags |= SEEN_A | SEEN_X;
 			emit_mul(r_A, r_A, r_X, ctx);
 			break;
@@ -1002,7 +990,6 @@ load_ind:
 			break;
 		case BPF_ALU | BPF_DIV | BPF_X:
 			/* A /= X */
-			update_on_xread(ctx);
 			ctx->flags |= SEEN_X | SEEN_A;
 			/* Check if r_X is zero */
 			emit_bcond(MIPS_COND_EQ, r_X, r_zero,
@@ -1012,7 +999,6 @@ load_ind:
 			break;
 		case BPF_ALU | BPF_MOD | BPF_X:
 			/* A %= X */
-			update_on_xread(ctx);
 			ctx->flags |= SEEN_X | SEEN_A;
 			/* Check if r_X is zero */
 			emit_bcond(MIPS_COND_EQ, r_X, r_zero,
@@ -1027,7 +1013,6 @@ load_ind:
 			break;
 		case BPF_ALU | BPF_OR | BPF_X:
 			/* A |= X */
-			update_on_xread(ctx);
 			ctx->flags |= SEEN_A;
 			emit_ori(r_A, r_A, r_X, ctx);
 			break;
@@ -1039,7 +1024,6 @@ load_ind:
 		case BPF_ANC | SKF_AD_ALU_XOR_X:
 		case BPF_ALU | BPF_XOR | BPF_X:
 			/* A ^= X */
-			update_on_xread(ctx);
 			ctx->flags |= SEEN_A;
 			emit_xor(r_A, r_A, r_X, ctx);
 			break;
@@ -1050,7 +1034,6 @@ load_ind:
 			break;
 		case BPF_ALU | BPF_AND | BPF_X:
 			/* A &= X */
-			update_on_xread(ctx);
 			ctx->flags |= SEEN_A | SEEN_X;
 			emit_and(r_A, r_A, r_X, ctx);
 			break;
@@ -1062,7 +1045,6 @@ load_ind:
 		case BPF_ALU | BPF_LSH | BPF_X:
 			/* A <<= X */
 			ctx->flags |= SEEN_A | SEEN_X;
-			update_on_xread(ctx);
 			emit_sllv(r_A, r_A, r_X, ctx);
 			break;
 		case BPF_ALU | BPF_RSH | BPF_K:
@@ -1072,7 +1054,6 @@ load_ind:
 			break;
 		case BPF_ALU | BPF_RSH | BPF_X:
 			ctx->flags |= SEEN_A | SEEN_X;
-			update_on_xread(ctx);
 			emit_srlv(r_A, r_A, r_X, ctx);
 			break;
 		case BPF_ALU | BPF_NEG:
@@ -1243,7 +1224,6 @@ jmp_cmp:
 		case BPF_MISC | BPF_TXA:
 			/* A = X */
 			ctx->flags |= SEEN_A | SEEN_X;
-			update_on_xread(ctx);
 			emit_jit_reg_move(r_A, r_X, ctx);
 			break;
 		/* AUX */
-- 
2.0.0
