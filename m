From: Rui Ueyama <rui314@gmail.com>
Subject: [PATCH] net: filter: Convert the BPF VM to threaded code
Date: Fri, 29 Jul 2011 01:10:26 -0700
Message-ID: <CACKH++ZfNTB7Y8YhvQnZPEXpwmpWXzxQgnWniamDrjRWUwxaNw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:50333 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753123Ab1G2IKr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2011 04:10:47 -0400
Received: by gxk21 with SMTP id 21so2364768gxk.19
        for <netdev@vger.kernel.org>; Fri, 29 Jul 2011 01:10:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert the BPF VM to threaded code to improve performance.

The BPF VM is basically a big for loop containing a switch statement.  That is
slow because for each instruction it checks the for loop condition and does the
conditional branch of the switch statement.

This patch eliminates the conditional branch, by replacing it with jump table
using GCC's labels-as-values feature. The for loop condition check can also be
removed, because the filter code always end with a RET instruction.

Signed-off-by: Rui Ueyama <rui314@gmail.com>
---
 include/linux/filter.h      |   60 +------
 include/linux/filter_inst.h |   57 ++++++
 net/core/filter.c           |  457 +++++++++++++++++++++----------------------
 3 files changed, 289 insertions(+), 285 deletions(-)
 create mode 100644 include/linux/filter_inst.h

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 741956f..2f72166 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -172,62 +172,10 @@ static inline void bpf_jit_free(struct sk_filter *fp)
 #endif

 enum {
-	BPF_S_RET_K = 1,
-	BPF_S_RET_A,
-	BPF_S_ALU_ADD_K,
-	BPF_S_ALU_ADD_X,
-	BPF_S_ALU_SUB_K,
-	BPF_S_ALU_SUB_X,
-	BPF_S_ALU_MUL_K,
-	BPF_S_ALU_MUL_X,
-	BPF_S_ALU_DIV_X,
-	BPF_S_ALU_AND_K,
-	BPF_S_ALU_AND_X,
-	BPF_S_ALU_OR_K,
-	BPF_S_ALU_OR_X,
-	BPF_S_ALU_LSH_K,
-	BPF_S_ALU_LSH_X,
-	BPF_S_ALU_RSH_K,
-	BPF_S_ALU_RSH_X,
-	BPF_S_ALU_NEG,
-	BPF_S_LD_W_ABS,
-	BPF_S_LD_H_ABS,
-	BPF_S_LD_B_ABS,
-	BPF_S_LD_W_LEN,
-	BPF_S_LD_W_IND,
-	BPF_S_LD_H_IND,
-	BPF_S_LD_B_IND,
-	BPF_S_LD_IMM,
-	BPF_S_LDX_W_LEN,
-	BPF_S_LDX_B_MSH,
-	BPF_S_LDX_IMM,
-	BPF_S_MISC_TAX,
-	BPF_S_MISC_TXA,
-	BPF_S_ALU_DIV_K,
-	BPF_S_LD_MEM,
-	BPF_S_LDX_MEM,
-	BPF_S_ST,
-	BPF_S_STX,
-	BPF_S_JMP_JA,
-	BPF_S_JMP_JEQ_K,
-	BPF_S_JMP_JEQ_X,
-	BPF_S_JMP_JGE_K,
-	BPF_S_JMP_JGE_X,
-	BPF_S_JMP_JGT_K,
-	BPF_S_JMP_JGT_X,
-	BPF_S_JMP_JSET_K,
-	BPF_S_JMP_JSET_X,
-	/* Ancillary data */
-	BPF_S_ANC_PROTOCOL,
-	BPF_S_ANC_PKTTYPE,
-	BPF_S_ANC_IFINDEX,
-	BPF_S_ANC_NLATTR,
-	BPF_S_ANC_NLATTR_NEST,
-	BPF_S_ANC_MARK,
-	BPF_S_ANC_QUEUE,
-	BPF_S_ANC_HATYPE,
-	BPF_S_ANC_RXHASH,
-	BPF_S_ANC_CPU,
+	BPF_S_DUMMY = 0,
+#define BPF_INST(inst) inst,
+#include "filter_inst.h"
+#undef BPF_INST
 };

 #endif /* __KERNEL__ */
diff --git a/include/linux/filter_inst.h b/include/linux/filter_inst.h
new file mode 100644
index 0000000..235a797
--- /dev/null
+++ b/include/linux/filter_inst.h
@@ -0,0 +1,57 @@
+BPF_INST(BPF_S_RET_K)
+BPF_INST(BPF_S_RET_A)
+BPF_INST(BPF_S_ALU_ADD_K)
+BPF_INST(BPF_S_ALU_ADD_X)
+BPF_INST(BPF_S_ALU_SUB_K)
+BPF_INST(BPF_S_ALU_SUB_X)
+BPF_INST(BPF_S_ALU_MUL_K)
+BPF_INST(BPF_S_ALU_MUL_X)
+BPF_INST(BPF_S_ALU_DIV_X)
+BPF_INST(BPF_S_ALU_AND_K)
+BPF_INST(BPF_S_ALU_AND_X)
+BPF_INST(BPF_S_ALU_OR_K)
+BPF_INST(BPF_S_ALU_OR_X)
+BPF_INST(BPF_S_ALU_LSH_K)
+BPF_INST(BPF_S_ALU_LSH_X)
+BPF_INST(BPF_S_ALU_RSH_K)
+BPF_INST(BPF_S_ALU_RSH_X)
+BPF_INST(BPF_S_ALU_NEG)
+BPF_INST(BPF_S_LD_W_ABS)
+BPF_INST(BPF_S_LD_H_ABS)
+BPF_INST(BPF_S_LD_B_ABS)
+BPF_INST(BPF_S_LD_W_LEN)
+BPF_INST(BPF_S_LD_W_IND)
+BPF_INST(BPF_S_LD_H_IND)
+BPF_INST(BPF_S_LD_B_IND)
+BPF_INST(BPF_S_LD_IMM)
+BPF_INST(BPF_S_LDX_W_LEN)
+BPF_INST(BPF_S_LDX_B_MSH)
+BPF_INST(BPF_S_LDX_IMM)
+BPF_INST(BPF_S_MISC_TAX)
+BPF_INST(BPF_S_MISC_TXA)
+BPF_INST(BPF_S_ALU_DIV_K)
+BPF_INST(BPF_S_LD_MEM)
+BPF_INST(BPF_S_LDX_MEM)
+BPF_INST(BPF_S_ST)
+BPF_INST(BPF_S_STX)
+BPF_INST(BPF_S_JMP_JA)
+BPF_INST(BPF_S_JMP_JEQ_K)
+BPF_INST(BPF_S_JMP_JEQ_X)
+BPF_INST(BPF_S_JMP_JGE_K)
+BPF_INST(BPF_S_JMP_JGE_X)
+BPF_INST(BPF_S_JMP_JGT_K)
+BPF_INST(BPF_S_JMP_JGT_X)
+BPF_INST(BPF_S_JMP_JSET_K)
+BPF_INST(BPF_S_JMP_JSET_X)
+
+/* Ancillary data */
+BPF_INST(BPF_S_ANC_PROTOCOL)
+BPF_INST(BPF_S_ANC_PKTTYPE)
+BPF_INST(BPF_S_ANC_IFINDEX)
+BPF_INST(BPF_S_ANC_NLATTR)
+BPF_INST(BPF_S_ANC_NLATTR_NEST)
+BPF_INST(BPF_S_ANC_MARK)
+BPF_INST(BPF_S_ANC_QUEUE)
+BPF_INST(BPF_S_ANC_HATYPE)
+BPF_INST(BPF_S_ANC_RXHASH)
+BPF_INST(BPF_S_ANC_CPU)
diff --git a/net/core/filter.c b/net/core/filter.c
index 36f975f..e0c9d2c 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -119,245 +119,244 @@ unsigned int sk_run_filter(const struct sk_buff *skb,
 	u32 tmp;
 	int k;

-	/*
-	 * Process array of filter instructions.
-	 */
-	for (;; fentry++) {
-#if defined(CONFIG_X86_32)
+	static void *jump_table[] = {
+		NULL,
+#define BPF_INST(inst) &&inst,
+#include <linux/filter_inst.h>
+#undef BPF_INST
+	};
+
 #define	K (fentry->k)
-#else
-		const u32 K = fentry->k;
-#endif
-
-		switch (fentry->code) {
-		case BPF_S_ALU_ADD_X:
-			A += X;
-			continue;
-		case BPF_S_ALU_ADD_K:
-			A += K;
-			continue;
-		case BPF_S_ALU_SUB_X:
-			A -= X;
-			continue;
-		case BPF_S_ALU_SUB_K:
-			A -= K;
-			continue;
-		case BPF_S_ALU_MUL_X:
-			A *= X;
-			continue;
-		case BPF_S_ALU_MUL_K:
-			A *= K;
-			continue;
-		case BPF_S_ALU_DIV_X:
-			if (X == 0)
-				return 0;
-			A /= X;
-			continue;
-		case BPF_S_ALU_DIV_K:
-			A = reciprocal_divide(A, K);
-			continue;
-		case BPF_S_ALU_AND_X:
-			A &= X;
-			continue;
-		case BPF_S_ALU_AND_K:
-			A &= K;
-			continue;
-		case BPF_S_ALU_OR_X:
-			A |= X;
-			continue;
-		case BPF_S_ALU_OR_K:
-			A |= K;
-			continue;
-		case BPF_S_ALU_LSH_X:
-			A <<= X;
-			continue;
-		case BPF_S_ALU_LSH_K:
-			A <<= K;
-			continue;
-		case BPF_S_ALU_RSH_X:
-			A >>= X;
-			continue;
-		case BPF_S_ALU_RSH_K:
-			A >>= K;
-			continue;
-		case BPF_S_ALU_NEG:
-			A = -A;
-			continue;
-		case BPF_S_JMP_JA:
-			fentry += K;
-			continue;
-		case BPF_S_JMP_JGT_K:
-			fentry += (A > K) ? fentry->jt : fentry->jf;
-			continue;
-		case BPF_S_JMP_JGE_K:
-			fentry += (A >= K) ? fentry->jt : fentry->jf;
-			continue;
-		case BPF_S_JMP_JEQ_K:
-			fentry += (A == K) ? fentry->jt : fentry->jf;
-			continue;
-		case BPF_S_JMP_JSET_K:
-			fentry += (A & K) ? fentry->jt : fentry->jf;
-			continue;
-		case BPF_S_JMP_JGT_X:
-			fentry += (A > X) ? fentry->jt : fentry->jf;
-			continue;
-		case BPF_S_JMP_JGE_X:
-			fentry += (A >= X) ? fentry->jt : fentry->jf;
-			continue;
-		case BPF_S_JMP_JEQ_X:
-			fentry += (A == X) ? fentry->jt : fentry->jf;
-			continue;
-		case BPF_S_JMP_JSET_X:
-			fentry += (A & X) ? fentry->jt : fentry->jf;
-			continue;
-		case BPF_S_LD_W_ABS:
-			k = K;
-load_w:
-			ptr = load_pointer(skb, k, 4, &tmp);
-			if (ptr != NULL) {
-				A = get_unaligned_be32(ptr);
-				continue;
-			}
+#define NEXT goto *jump_table[(++fentry)->code]
+
+	/* Dispatch the first instruction */
+	goto *jump_table[fentry->code];
+
+ BPF_S_ALU_ADD_X:
+	A += X;
+	NEXT;
+ BPF_S_ALU_ADD_K:
+	A += K;
+	NEXT;
+ BPF_S_ALU_SUB_X:
+	A -= X;
+	NEXT;
+ BPF_S_ALU_SUB_K:
+	A -= K;
+	NEXT;
+ BPF_S_ALU_MUL_X:
+	A *= X;
+	NEXT;
+ BPF_S_ALU_MUL_K:
+	A *= K;
+	NEXT;
+ BPF_S_ALU_DIV_X:
+	if (X == 0)
+		return 0;
+	A /= X;
+	NEXT;
+ BPF_S_ALU_DIV_K:
+	A = reciprocal_divide(A, K);
+	NEXT;
+ BPF_S_ALU_AND_X:
+	A &= X;
+	NEXT;
+ BPF_S_ALU_AND_K:
+	A &= K;
+	NEXT;
+ BPF_S_ALU_OR_X:
+	A |= X;
+	NEXT;
+ BPF_S_ALU_OR_K:
+	A |= K;
+	NEXT;
+ BPF_S_ALU_LSH_X:
+	A <<= X;
+	NEXT;
+ BPF_S_ALU_LSH_K:
+	A <<= K;
+	NEXT;
+ BPF_S_ALU_RSH_X:
+	A >>= X;
+	NEXT;
+ BPF_S_ALU_RSH_K:
+	A >>= K;
+	NEXT;
+ BPF_S_ALU_NEG:
+	A = -A;
+	NEXT;
+ BPF_S_JMP_JA:
+	fentry += K;
+	NEXT;
+ BPF_S_JMP_JGT_K:
+	fentry += (A > K) ? fentry->jt : fentry->jf;
+	NEXT;
+ BPF_S_JMP_JGE_K:
+	fentry += (A >= K) ? fentry->jt : fentry->jf;
+	NEXT;
+ BPF_S_JMP_JEQ_K:
+	fentry += (A == K) ? fentry->jt : fentry->jf;
+	NEXT;
+ BPF_S_JMP_JSET_K:
+	fentry += (A & K) ? fentry->jt : fentry->jf;
+	NEXT;
+ BPF_S_JMP_JGT_X:
+	fentry += (A > X) ? fentry->jt : fentry->jf;
+	NEXT;
+ BPF_S_JMP_JGE_X:
+	fentry += (A >= X) ? fentry->jt : fentry->jf;
+	NEXT;
+ BPF_S_JMP_JEQ_X:
+	fentry += (A == X) ? fentry->jt : fentry->jf;
+	NEXT;
+ BPF_S_JMP_JSET_X:
+	fentry += (A & X) ? fentry->jt : fentry->jf;
+	NEXT;
+ BPF_S_LD_W_ABS:
+	k = K;
+ load_w:
+	ptr = load_pointer(skb, k, 4, &tmp);
+	if (ptr != NULL) {
+		A = get_unaligned_be32(ptr);
+		NEXT;
+	}
+	return 0;
+ BPF_S_LD_H_ABS:
+	k = K;
+ load_h:
+	ptr = load_pointer(skb, k, 2, &tmp);
+	if (ptr != NULL) {
+		A = get_unaligned_be16(ptr);
+		NEXT;
+	}
+	return 0;
+ BPF_S_LD_B_ABS:
+	k = K;
+ load_b:
+	ptr = load_pointer(skb, k, 1, &tmp);
+	if (ptr != NULL) {
+		A = *(u8 *)ptr;
+		NEXT;
+	}
+	return 0;
+ BPF_S_LD_W_LEN:
+	A = skb->len;
+	NEXT;
+ BPF_S_LDX_W_LEN:
+	X = skb->len;
+	NEXT;
+ BPF_S_LD_W_IND:
+	k = X + K;
+	goto load_w;
+ BPF_S_LD_H_IND:
+	k = X + K;
+	goto load_h;
+ BPF_S_LD_B_IND:
+	k = X + K;
+	goto load_b;
+ BPF_S_LDX_B_MSH:
+	ptr = load_pointer(skb, K, 1, &tmp);
+	if (ptr != NULL) {
+		X = (*(u8 *)ptr & 0xf) << 2;
+		NEXT;
+	}
+	return 0;
+ BPF_S_LD_IMM:
+	A = K;
+	NEXT;
+ BPF_S_LDX_IMM:
+	X = K;
+	NEXT;
+ BPF_S_LD_MEM:
+	A = mem[K];
+	NEXT;
+ BPF_S_LDX_MEM:
+	X = mem[K];
+	NEXT;
+ BPF_S_MISC_TAX:
+	X = A;
+	NEXT;
+ BPF_S_MISC_TXA:
+	A = X;
+	NEXT;
+ BPF_S_RET_K:
+	return K;
+ BPF_S_RET_A:
+	return A;
+ BPF_S_ST:
+	mem[K] = A;
+	NEXT;
+ BPF_S_STX:
+	mem[K] = X;
+	NEXT;
+ BPF_S_ANC_PROTOCOL:
+	A = ntohs(skb->protocol);
+	NEXT;
+ BPF_S_ANC_PKTTYPE:
+	A = skb->pkt_type;
+	NEXT;
+ BPF_S_ANC_IFINDEX:
+	if (!skb->dev)
+		return 0;
+	A = skb->dev->ifindex;
+	NEXT;
+ BPF_S_ANC_MARK:
+	A = skb->mark;
+	NEXT;
+ BPF_S_ANC_QUEUE:
+	A = skb->queue_mapping;
+	NEXT;
+ BPF_S_ANC_HATYPE:
+	if (!skb->dev)
+		return 0;
+	A = skb->dev->type;
+	NEXT;
+ BPF_S_ANC_RXHASH:
+	A = skb->rxhash;
+	NEXT;
+ BPF_S_ANC_CPU:
+	A = raw_smp_processor_id();
+	NEXT;
+ BPF_S_ANC_NLATTR:
+	{
+		struct nlattr *nla;
+
+		if (skb_is_nonlinear(skb))
 			return 0;
-		case BPF_S_LD_H_ABS:
-			k = K;
-load_h:
-			ptr = load_pointer(skb, k, 2, &tmp);
-			if (ptr != NULL) {
-				A = get_unaligned_be16(ptr);
-				continue;
-			}
+		if (A > skb->len - sizeof(struct nlattr))
 			return 0;
-		case BPF_S_LD_B_ABS:
-			k = K;
-load_b:
-			ptr = load_pointer(skb, k, 1, &tmp);
-			if (ptr != NULL) {
-				A = *(u8 *)ptr;
-				continue;
-			}
+
+		nla = nla_find((struct nlattr *)&skb->data[A],
+			       skb->len - A, X);
+		if (nla)
+			A = (void *)nla - (void *)skb->data;
+		else
+			A = 0;
+	}
+	NEXT;
+ BPF_S_ANC_NLATTR_NEST:
+	{
+		struct nlattr *nla;
+
+		if (skb_is_nonlinear(skb))
 			return 0;
-		case BPF_S_LD_W_LEN:
-			A = skb->len;
-			continue;
-		case BPF_S_LDX_W_LEN:
-			X = skb->len;
-			continue;
-		case BPF_S_LD_W_IND:
-			k = X + K;
-			goto load_w;
-		case BPF_S_LD_H_IND:
-			k = X + K;
-			goto load_h;
-		case BPF_S_LD_B_IND:
-			k = X + K;
-			goto load_b;
-		case BPF_S_LDX_B_MSH:
-			ptr = load_pointer(skb, K, 1, &tmp);
-			if (ptr != NULL) {
-				X = (*(u8 *)ptr & 0xf) << 2;
-				continue;
-			}
+		if (A > skb->len - sizeof(struct nlattr))
 			return 0;
-		case BPF_S_LD_IMM:
-			A = K;
-			continue;
-		case BPF_S_LDX_IMM:
-			X = K;
-			continue;
-		case BPF_S_LD_MEM:
-			A = mem[K];
-			continue;
-		case BPF_S_LDX_MEM:
-			X = mem[K];
-			continue;
-		case BPF_S_MISC_TAX:
-			X = A;
-			continue;
-		case BPF_S_MISC_TXA:
-			A = X;
-			continue;
-		case BPF_S_RET_K:
-			return K;
-		case BPF_S_RET_A:
-			return A;
-		case BPF_S_ST:
-			mem[K] = A;
-			continue;
-		case BPF_S_STX:
-			mem[K] = X;
-			continue;
-		case BPF_S_ANC_PROTOCOL:
-			A = ntohs(skb->protocol);
-			continue;
-		case BPF_S_ANC_PKTTYPE:
-			A = skb->pkt_type;
-			continue;
-		case BPF_S_ANC_IFINDEX:
-			if (!skb->dev)
-				return 0;
-			A = skb->dev->ifindex;
-			continue;
-		case BPF_S_ANC_MARK:
-			A = skb->mark;
-			continue;
-		case BPF_S_ANC_QUEUE:
-			A = skb->queue_mapping;
-			continue;
-		case BPF_S_ANC_HATYPE:
-			if (!skb->dev)
-				return 0;
-			A = skb->dev->type;
-			continue;
-		case BPF_S_ANC_RXHASH:
-			A = skb->rxhash;
-			continue;
-		case BPF_S_ANC_CPU:
-			A = raw_smp_processor_id();
-			continue;
-		case BPF_S_ANC_NLATTR: {
-			struct nlattr *nla;
-
-			if (skb_is_nonlinear(skb))
-				return 0;
-			if (A > skb->len - sizeof(struct nlattr))
-				return 0;
-
-			nla = nla_find((struct nlattr *)&skb->data[A],
-				       skb->len - A, X);
-			if (nla)
-				A = (void *)nla - (void *)skb->data;
-			else
-				A = 0;
-			continue;
-		}
-		case BPF_S_ANC_NLATTR_NEST: {
-			struct nlattr *nla;
-
-			if (skb_is_nonlinear(skb))
-				return 0;
-			if (A > skb->len - sizeof(struct nlattr))
-				return 0;
-
-			nla = (struct nlattr *)&skb->data[A];
-			if (nla->nla_len > A - skb->len)
-				return 0;
-
-			nla = nla_find_nested(nla, X);
-			if (nla)
-				A = (void *)nla - (void *)skb->data;
-			else
-				A = 0;
-			continue;
-		}
-		default:
-			WARN_RATELIMIT(1, "Unknown code:%u jt:%u tf:%u k:%u\n",
-				       fentry->code, fentry->jt,
-				       fentry->jf, fentry->k);
+
+		nla = (struct nlattr *)&skb->data[A];
+		if (nla->nla_len > A - skb->len)
 			return 0;
-		}
+
+		nla = nla_find_nested(nla, X);
+		if (nla)
+			A = (void *)nla - (void *)skb->data;
+		else
+			A = 0;
 	}
+	NEXT;

+#undef K
+#undef NEXT
 	return 0;
 }
 EXPORT_SYMBOL(sk_run_filter);
-- 
1.7.3.1
