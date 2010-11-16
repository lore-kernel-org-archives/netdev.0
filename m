From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] filter: Optimize instruction revalidation code.
Date: Tue, 16 Nov 2010 22:08:50 +0900
Message-ID: <201011162208.BHC17628.SVtFMJOOLFQFOH@I-love.SAKURA.ne.jp>
References: <1695276347-1289413089-cardhu_decombobulator_blackberry.rim.net-434693855-@bda083.bisx.prod.on.blackberry>
	<20101110.102129.112602843.davem@davemloft.net>
	<1289414024.2469.20.camel@edumazet-laptop>
	<20101110.103807.39173013.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: drosenberg@vsecurity.com, netdev@vger.kernel.org
To: davem@davemloft.net, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from wine.ocn.ne.jp ([122.1.235.145]:57276 "EHLO smtp.wine.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756667Ab0KPNIy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Nov 2010 08:08:54 -0500
In-Reply-To: <20101110.103807.39173013.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the wake of commit 57fe93b3 "filter: make sure filters dont read
uninitialized memory", I came up with this patch. I don't know how to test.
Please review and do tests.

This patch optimizes sk_chk_filter(). Using gcc 4.1.2 on x86_32, the size of
net/core/filter.o changed from 7416 bytes to 5260 bytes
("make allnoconfig" + CONFIG_NET=y).

By the way, if "struct sock_filter *filter" argument of sk_run_filter() does
not change after it was revalidated at sk_chk_filter(), can't we detect and
reject "BPF_S_LD_MEM/BPF_S_LDX_MEM before BPF_S_ST/BPF_S_STX" at
sk_chk_filter()?
----------------------------------------
 From 2bf36130bd4912590b409b47a6a9a82e2884e035 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Tue, 16 Nov 2010 21:39:50 +0900
Subject: [PATCH] filter: Optimize instruction revalidation code.

Since repeating small value to small value conversion using switch() clause's
case statement is wasteful, this patch instroduces u16 to u16 mapping table
and removes most of case statements. As a result, the size of net/core/filter.o
is reduced by about 30% on x86.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 net/core/filter.c |  214 ++++++++++++++++-------------------------------------
 1 files changed, 65 insertions(+), 149 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index 23e9b2a..85be3d8 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -383,7 +383,57 @@ EXPORT_SYMBOL(sk_run_filter);
  */
 int sk_chk_filter(struct sock_filter *filter, int flen)
 {
-	struct sock_filter *ftest;
+	/*
+	 * Valid instructions are initialized to non-0.
+	 * Invalid instructions are initialized to 0.
+	 */
+	static u16 codes[] = {
+		[BPF_ALU|BPF_ADD|BPF_K]  = BPF_S_ALU_ADD_K + 1,
+		[BPF_ALU|BPF_ADD|BPF_X]  = BPF_S_ALU_ADD_X + 1,
+		[BPF_ALU|BPF_SUB|BPF_K]  = BPF_S_ALU_SUB_K + 1,
+		[BPF_ALU|BPF_SUB|BPF_X]  = BPF_S_ALU_SUB_X + 1,
+		[BPF_ALU|BPF_MUL|BPF_K]  = BPF_S_ALU_MUL_K + 1,
+		[BPF_ALU|BPF_MUL|BPF_X]  = BPF_S_ALU_MUL_X + 1,
+		[BPF_ALU|BPF_DIV|BPF_X]  = BPF_S_ALU_DIV_X + 1,
+		[BPF_ALU|BPF_AND|BPF_K]  = BPF_S_ALU_AND_K + 1,
+		[BPF_ALU|BPF_AND|BPF_X]  = BPF_S_ALU_AND_X + 1,
+		[BPF_ALU|BPF_OR|BPF_K]   = BPF_S_ALU_OR_K + 1,
+		[BPF_ALU|BPF_OR|BPF_X]   = BPF_S_ALU_OR_X + 1,
+		[BPF_ALU|BPF_LSH|BPF_K]  = BPF_S_ALU_LSH_K + 1,
+		[BPF_ALU|BPF_LSH|BPF_X]  = BPF_S_ALU_LSH_X + 1,
+		[BPF_ALU|BPF_RSH|BPF_K]  = BPF_S_ALU_RSH_K + 1,
+		[BPF_ALU|BPF_RSH|BPF_X]  = BPF_S_ALU_RSH_X + 1,
+		[BPF_ALU|BPF_NEG]        = BPF_S_ALU_NEG + 1,
+		[BPF_LD|BPF_W|BPF_ABS]   = BPF_S_LD_W_ABS + 1,
+		[BPF_LD|BPF_H|BPF_ABS]   = BPF_S_LD_H_ABS + 1,
+		[BPF_LD|BPF_B|BPF_ABS]   = BPF_S_LD_B_ABS + 1,
+		[BPF_LD|BPF_W|BPF_LEN]   = BPF_S_LD_W_LEN + 1,
+		[BPF_LD|BPF_W|BPF_IND]   = BPF_S_LD_W_IND + 1,
+		[BPF_LD|BPF_H|BPF_IND]   = BPF_S_LD_H_IND + 1,
+		[BPF_LD|BPF_B|BPF_IND]   = BPF_S_LD_B_IND + 1,
+		[BPF_LD|BPF_IMM]         = BPF_S_LD_IMM + 1,
+		[BPF_LDX|BPF_W|BPF_LEN]  = BPF_S_LDX_W_LEN + 1,
+		[BPF_LDX|BPF_B|BPF_MSH]  = BPF_S_LDX_B_MSH + 1,
+		[BPF_LDX|BPF_IMM]        = BPF_S_LDX_IMM + 1,
+		[BPF_MISC|BPF_TAX]       = BPF_S_MISC_TAX + 1,
+		[BPF_MISC|BPF_TXA]       = BPF_S_MISC_TXA + 1,
+		[BPF_RET|BPF_K]          = BPF_S_RET_K + 1,
+		[BPF_RET|BPF_A]          = BPF_S_RET_A + 1,
+		[BPF_ALU|BPF_DIV|BPF_K]  = BPF_S_ALU_DIV_K + 1,
+		[BPF_LD|BPF_MEM]         = BPF_S_LD_MEM + 1,
+		[BPF_LDX|BPF_MEM]        = BPF_S_LDX_MEM + 1,
+		[BPF_ST]                 = BPF_S_ST + 1,
+		[BPF_STX]                = BPF_S_STX + 1,
+		[BPF_JMP|BPF_JA]         = BPF_S_JMP_JA + 1,
+		[BPF_JMP|BPF_JEQ|BPF_K]  = BPF_S_JMP_JEQ_K + 1,
+		[BPF_JMP|BPF_JEQ|BPF_X]  = BPF_S_JMP_JEQ_X + 1,
+		[BPF_JMP|BPF_JGE|BPF_K]  = BPF_S_JMP_JGE_K + 1,
+		[BPF_JMP|BPF_JGE|BPF_X]  = BPF_S_JMP_JGE_X + 1,
+		[BPF_JMP|BPF_JGT|BPF_K]  = BPF_S_JMP_JGT_K + 1,
+		[BPF_JMP|BPF_JGT|BPF_X]  = BPF_S_JMP_JGT_X + 1,
+		[BPF_JMP|BPF_JSET|BPF_K] = BPF_S_JMP_JSET_K + 1,
+		[BPF_JMP|BPF_JSET|BPF_X] = BPF_S_JMP_JSET_X + 1,
+	};
 	int pc;
 
 	if (flen == 0 || flen > BPF_MAXINSNS)
@@ -391,135 +441,26 @@ int sk_chk_filter(struct sock_filter *filter, int flen)
 
 	/* check the filter code now */
 	for (pc = 0; pc < flen; pc++) {
-		ftest = &filter[pc];
-
-		/* Only allow valid instructions */
-		switch (ftest->code) {
-		case BPF_ALU|BPF_ADD|BPF_K:
-			ftest->code = BPF_S_ALU_ADD_K;
-			break;
-		case BPF_ALU|BPF_ADD|BPF_X:
-			ftest->code = BPF_S_ALU_ADD_X;
-			break;
-		case BPF_ALU|BPF_SUB|BPF_K:
-			ftest->code = BPF_S_ALU_SUB_K;
-			break;
-		case BPF_ALU|BPF_SUB|BPF_X:
-			ftest->code = BPF_S_ALU_SUB_X;
-			break;
-		case BPF_ALU|BPF_MUL|BPF_K:
-			ftest->code = BPF_S_ALU_MUL_K;
-			break;
-		case BPF_ALU|BPF_MUL|BPF_X:
-			ftest->code = BPF_S_ALU_MUL_X;
-			break;
-		case BPF_ALU|BPF_DIV|BPF_X:
-			ftest->code = BPF_S_ALU_DIV_X;
-			break;
-		case BPF_ALU|BPF_AND|BPF_K:
-			ftest->code = BPF_S_ALU_AND_K;
-			break;
-		case BPF_ALU|BPF_AND|BPF_X:
-			ftest->code = BPF_S_ALU_AND_X;
-			break;
-		case BPF_ALU|BPF_OR|BPF_K:
-			ftest->code = BPF_S_ALU_OR_K;
-			break;
-		case BPF_ALU|BPF_OR|BPF_X:
-			ftest->code = BPF_S_ALU_OR_X;
-			break;
-		case BPF_ALU|BPF_LSH|BPF_K:
-			ftest->code = BPF_S_ALU_LSH_K;
-			break;
-		case BPF_ALU|BPF_LSH|BPF_X:
-			ftest->code = BPF_S_ALU_LSH_X;
-			break;
-		case BPF_ALU|BPF_RSH|BPF_K:
-			ftest->code = BPF_S_ALU_RSH_K;
-			break;
-		case BPF_ALU|BPF_RSH|BPF_X:
-			ftest->code = BPF_S_ALU_RSH_X;
-			break;
-		case BPF_ALU|BPF_NEG:
-			ftest->code = BPF_S_ALU_NEG;
-			break;
-		case BPF_LD|BPF_W|BPF_ABS:
-			ftest->code = BPF_S_LD_W_ABS;
-			break;
-		case BPF_LD|BPF_H|BPF_ABS:
-			ftest->code = BPF_S_LD_H_ABS;
-			break;
-		case BPF_LD|BPF_B|BPF_ABS:
-			ftest->code = BPF_S_LD_B_ABS;
-			break;
-		case BPF_LD|BPF_W|BPF_LEN:
-			ftest->code = BPF_S_LD_W_LEN;
-			break;
-		case BPF_LD|BPF_W|BPF_IND:
-			ftest->code = BPF_S_LD_W_IND;
-			break;
-		case BPF_LD|BPF_H|BPF_IND:
-			ftest->code = BPF_S_LD_H_IND;
-			break;
-		case BPF_LD|BPF_B|BPF_IND:
-			ftest->code = BPF_S_LD_B_IND;
-			break;
-		case BPF_LD|BPF_IMM:
-			ftest->code = BPF_S_LD_IMM;
-			break;
-		case BPF_LDX|BPF_W|BPF_LEN:
-			ftest->code = BPF_S_LDX_W_LEN;
-			break;
-		case BPF_LDX|BPF_B|BPF_MSH:
-			ftest->code = BPF_S_LDX_B_MSH;
-			break;
-		case BPF_LDX|BPF_IMM:
-			ftest->code = BPF_S_LDX_IMM;
-			break;
-		case BPF_MISC|BPF_TAX:
-			ftest->code = BPF_S_MISC_TAX;
-			break;
-		case BPF_MISC|BPF_TXA:
-			ftest->code = BPF_S_MISC_TXA;
-			break;
-		case BPF_RET|BPF_K:
-			ftest->code = BPF_S_RET_K;
-			break;
-		case BPF_RET|BPF_A:
-			ftest->code = BPF_S_RET_A;
-			break;
+		struct sock_filter *ftest = &filter[pc];
+		u16 code = ftest->code;
 
+		if (code >= ARRAY_SIZE(codes))
+			return 0;
 		/* Some instructions need special checks */
-
-			/* check for division by zero */
+		switch (code) {
 		case BPF_ALU|BPF_DIV|BPF_K:
+			/* check for division by zero */
 			if (ftest->k == 0)
 				return -EINVAL;
-			ftest->code = BPF_S_ALU_DIV_K;
 			break;
-
-		/* check for invalid memory addresses */
 		case BPF_LD|BPF_MEM:
-			if (ftest->k >= BPF_MEMWORDS)
-				return -EINVAL;
-			ftest->code = BPF_S_LD_MEM;
-			break;
 		case BPF_LDX|BPF_MEM:
-			if (ftest->k >= BPF_MEMWORDS)
-				return -EINVAL;
-			ftest->code = BPF_S_LDX_MEM;
-			break;
 		case BPF_ST:
-			if (ftest->k >= BPF_MEMWORDS)
-				return -EINVAL;
-			ftest->code = BPF_S_ST;
-			break;
 		case BPF_STX:
+			/* check for invalid memory addresses */
 			if (ftest->k >= BPF_MEMWORDS)
 				return -EINVAL;
-			ftest->code = BPF_S_STX;
 			break;
-
 		case BPF_JMP|BPF_JA:
 			/*
 			 * Note, the large ftest->k might cause loops.
@@ -528,40 +469,14 @@ int sk_chk_filter(struct sock_filter *filter, int flen)
 			 */
 			if (ftest->k >= (unsigned)(flen-pc-1))
 				return -EINVAL;
-			ftest->code = BPF_S_JMP_JA;
-			break;
-
-		case BPF_JMP|BPF_JEQ|BPF_K:
-			ftest->code = BPF_S_JMP_JEQ_K;
-			break;
-		case BPF_JMP|BPF_JEQ|BPF_X:
-			ftest->code = BPF_S_JMP_JEQ_X;
-			break;
-		case BPF_JMP|BPF_JGE|BPF_K:
-			ftest->code = BPF_S_JMP_JGE_K;
-			break;
-		case BPF_JMP|BPF_JGE|BPF_X:
-			ftest->code = BPF_S_JMP_JGE_X;
-			break;
-		case BPF_JMP|BPF_JGT|BPF_K:
-			ftest->code = BPF_S_JMP_JGT_K;
-			break;
-		case BPF_JMP|BPF_JGT|BPF_X:
-			ftest->code = BPF_S_JMP_JGT_X;
 			break;
-		case BPF_JMP|BPF_JSET|BPF_K:
-			ftest->code = BPF_S_JMP_JSET_K;
-			break;
-		case BPF_JMP|BPF_JSET|BPF_X:
-			ftest->code = BPF_S_JMP_JSET_X;
-			break;
-
-		default:
-			return -EINVAL;
 		}
-
-			/* for conditionals both must be safe */
-		switch (ftest->code) {
+		code = codes[code];
+		if (!code--)
+			return -EINVAL;
+
+		/* for conditionals both must be safe */
+		switch (code) {
 		case BPF_S_JMP_JEQ_K:
 		case BPF_S_JMP_JEQ_X:
 		case BPF_S_JMP_JGE_K:
@@ -574,6 +489,7 @@ int sk_chk_filter(struct sock_filter *filter, int flen)
 			    pc + ftest->jf + 1 >= flen)
 				return -EINVAL;
 		}
+		ftest->code = code;
 	}
 
 	/* last instruction must be a RET code */
-- 
1.6.1
