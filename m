From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH v3] filter: Optimize instruction revalidation code.
Date: Wed, 17 Nov 2010 10:19:51 +0900
Message-ID: <201011170119.oAH1JpES011121@www262.sakura.ne.jp>
References: <20101110.102129.112602843.davem@davemloft.net> <1289414024.2469.20.camel@edumazet-laptop> <20101110.103807.39173013.davem@davemloft.net> <201011162208.BHC17628.SVtFMJOOLFQFOH@I-love.SAKURA.ne.jp> <1289915053.5372.183.camel@edumazet-laptop> <201011162331.CGH00026.OFOSFVMFQtLHOJ@I-love.SAKURA.ne.jp> <1289925055.5372.484.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mjt@tls.msk.ru, davem@davemloft.net, drosenberg@vsecurity.com,
	hagen@jauu.net, xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:56098 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932215Ab0KQBUI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Nov 2010 20:20:08 -0500
In-Reply-To: <1289925055.5372.484.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> I dont understand the problem...
> Once translated, you have to test the translated code, not the original
> one ;)

I moved the test to after translation.

> why u16 ? 
> 
> You store translated instructions, so u8 is OK

I chose u16 because type of filter->code is __u16.
But I changed to use u8 as you suggested that translated code fits in u8.

> Also fix the indentation at the end of sk_chk_filter()
> 
> You have 3 extra tabulations :

Fixed.

Hagen Paul Pfeifer wrote:
> Maybe I don't get it, but you increment the opcode by one, but you never
> increment the opcode in sk_run_filter() - do I miss something? Did you test
> the your patch (a trivial tcpdump rule should be sufficient)?

I added a comment line.

Changli Gao wrote:
> > +               struct sock_filter *ftest = &filter[pc];
> 
> Why move the define here?

To suppress compiler's warning about mixed declaration.

> > +               u16 code = ftest->code;
> >
> > +               if (code >= ARRAY_SIZE(codes))
> > +                       return 0;
> 
> return -EINVAL;

Fixed in v2. Thanks.

> But how about this:
> 
> enum {
>         BPF_S_RET_K = 1,

If BPF_S_* are only for kernel internal use, I think we don't need to translate
from the beginning because only net/core/filter.c uses BPF_S_*.

BPF_S_* are exposed to userspace via /usr/include/linux/filter.h since 2.6.36.
Is it no problem to change?

Filesize change (x86_32) by this patch:
  gcc 3.3.5: 7184 -> 5060
  gcc 4.4.3: 7972 -> 5588
----------------------------------------
>From b8777ab64bc31dbbe499eb62c2ffd29add7e79c8 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Wed, 17 Nov 2010 09:46:33 +0900
Subject: [PATCH v3] filter: Optimize instruction revalidation code.

Since repeating u16 value to u8 value conversion using switch() clause's
case statement is wasteful, this patch introduces u16 to u8 mapping table
and removes most of case statements. As a result, the size of net/core/filter.o
is reduced by about 29% on x86.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 net/core/filter.c |  231 +++++++++++++++++------------------------------------
 1 files changed, 72 insertions(+), 159 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index 23e9b2a..03dc071 100644
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
+	static const u8 codes[] = {
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
@@ -391,136 +441,31 @@ int sk_chk_filter(struct sock_filter *filter, int flen)
 
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
+			return -EINVAL;
+		code = codes[code];
+		/* Undo the '+ 1' in codes[] after validation. */
+		if (!code--)
+			return -EINVAL;
 		/* Some instructions need special checks */
-
+		switch (code) {
+		case BPF_S_ALU_DIV_K:
 			/* check for division by zero */
-		case BPF_ALU|BPF_DIV|BPF_K:
 			if (ftest->k == 0)
 				return -EINVAL;
-			ftest->code = BPF_S_ALU_DIV_K;
 			break;
-
-		/* check for invalid memory addresses */
-		case BPF_LD|BPF_MEM:
-			if (ftest->k >= BPF_MEMWORDS)
-				return -EINVAL;
-			ftest->code = BPF_S_LD_MEM;
-			break;
-		case BPF_LDX|BPF_MEM:
-			if (ftest->k >= BPF_MEMWORDS)
-				return -EINVAL;
-			ftest->code = BPF_S_LDX_MEM;
-			break;
-		case BPF_ST:
-			if (ftest->k >= BPF_MEMWORDS)
-				return -EINVAL;
-			ftest->code = BPF_S_ST;
-			break;
-		case BPF_STX:
+		case BPF_S_LD_MEM:
+		case BPF_S_LDX_MEM:
+		case BPF_S_ST:
+		case BPF_S_STX:
+			/* check for invalid memory addresses */
 			if (ftest->k >= BPF_MEMWORDS)
 				return -EINVAL;
-			ftest->code = BPF_S_STX;
 			break;
-
-		case BPF_JMP|BPF_JA:
+		case BPF_S_JMP_JA:
 			/*
 			 * Note, the large ftest->k might cause loops.
 			 * Compare this with conditional jumps below,
@@ -528,40 +473,7 @@ int sk_chk_filter(struct sock_filter *filter, int flen)
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
 			break;
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
-			break;
-		case BPF_JMP|BPF_JSET|BPF_K:
-			ftest->code = BPF_S_JMP_JSET_K;
-			break;
-		case BPF_JMP|BPF_JSET|BPF_X:
-			ftest->code = BPF_S_JMP_JSET_X;
-			break;
-
-		default:
-			return -EINVAL;
-		}
-
-			/* for conditionals both must be safe */
-		switch (ftest->code) {
 		case BPF_S_JMP_JEQ_K:
 		case BPF_S_JMP_JEQ_X:
 		case BPF_S_JMP_JGE_K:
@@ -570,10 +482,13 @@ int sk_chk_filter(struct sock_filter *filter, int flen)
 		case BPF_S_JMP_JGT_X:
 		case BPF_S_JMP_JSET_X:
 		case BPF_S_JMP_JSET_K:
+			/* for conditionals both must be safe */
 			if (pc + ftest->jt + 1 >= flen ||
 			    pc + ftest->jf + 1 >= flen)
 				return -EINVAL;
+			break;
 		}
+		ftest->code = code;
 	}
 
 	/* last instruction must be a RET code */
@@ -581,10 +496,8 @@ int sk_chk_filter(struct sock_filter *filter, int flen)
 	case BPF_S_RET_K:
 	case BPF_S_RET_A:
 		return 0;
-		break;
-		default:
-			return -EINVAL;
-		}
+	}
+	return -EINVAL;
 }
 EXPORT_SYMBOL(sk_chk_filter);
 
-- 
1.7.1

