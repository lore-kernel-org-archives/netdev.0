From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 4/4] net: filter: improve filter block macros
Date: Thu, 29 May 2014 10:22:51 +0200
Message-ID: <1401351771-5367-5-git-send-email-dborkman@redhat.com>
References: <1401351771-5367-1-git-send-email-dborkman@redhat.com>
Cc: ast@plumgrid.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61475 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932508AbaE2IXE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2014 04:23:04 -0400
In-Reply-To: <1401351771-5367-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 9739eef13c92 ("net: filter: make BPF conversion more readable")
started to introduce helper macros similar to BPF_STMT()/BPF_JUMP()
macros from classic BPF.

However, quite some statements in the filter conversion functions
remained in the old style which gives a mixture of block macros and
non block macros in the code. This patch makes the block macros itself
more readable by using explicit member initialization, and converts
the remaining ones where possible to remain in a more consistent state.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
---
 include/linux/filter.h | 255 +++++++++++++++++++++++++++++++++++++++----------
 net/core/filter.c      | 196 ++++++++++++++-----------------------
 2 files changed, 277 insertions(+), 174 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 49ef7a2..f0c2ad4 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -76,56 +76,211 @@ enum {
 /* BPF program can access up to 512 bytes of stack space. */
 #define MAX_BPF_STACK	512
 
-/* bpf_add|sub|...: a += x, bpf_mov: a = x */
-#define BPF_ALU64_REG(op, a, x) \
-	((struct sock_filter_int) {BPF_ALU64|BPF_OP(op)|BPF_X, a, x, 0, 0})
-#define BPF_ALU32_REG(op, a, x) \
-	((struct sock_filter_int) {BPF_ALU|BPF_OP(op)|BPF_X, a, x, 0, 0})
-
-/* bpf_add|sub|...: a += imm, bpf_mov: a = imm */
-#define BPF_ALU64_IMM(op, a, imm) \
-	((struct sock_filter_int) {BPF_ALU64|BPF_OP(op)|BPF_K, a, 0, 0, imm})
-#define BPF_ALU32_IMM(op, a, imm) \
-	((struct sock_filter_int) {BPF_ALU|BPF_OP(op)|BPF_K, a, 0, 0, imm})
-
-/* R0 = *(uint *) (skb->data + off) */
-#define BPF_LD_ABS(size, off) \
-	((struct sock_filter_int) {BPF_LD|BPF_SIZE(size)|BPF_ABS, 0, 0, 0, off})
-
-/* R0 = *(uint *) (skb->data + x + off) */
-#define BPF_LD_IND(size, x, off) \
-	((struct sock_filter_int) {BPF_LD|BPF_SIZE(size)|BPF_IND, 0, x, 0, off})
-
-/* a = *(uint *) (x + off) */
-#define BPF_LDX_MEM(sz, a, x, off) \
-	((struct sock_filter_int) {BPF_LDX|BPF_SIZE(sz)|BPF_MEM, a, x, off, 0})
-
-/* if (a 'op' x) goto pc+off */
-#define BPF_JMP_REG(op, a, x, off) \
-	((struct sock_filter_int) {BPF_JMP|BPF_OP(op)|BPF_X, a, x, off, 0})
-
-/* if (a 'op' imm) goto pc+off */
-#define BPF_JMP_IMM(op, a, imm, off) \
-	((struct sock_filter_int) {BPF_JMP|BPF_OP(op)|BPF_K, a, 0, off, imm})
-
-#define BPF_EXIT_INSN() \
-	((struct sock_filter_int) {BPF_JMP|BPF_EXIT, 0, 0, 0, 0})
-
-static inline int size_to_bpf(int size)
-{
-	switch (size) {
-	case 1:
-		return BPF_B;
-	case 2:
-		return BPF_H;
-	case 4:
-		return BPF_W;
-	case 8:
-		return BPF_DW;
-	default:
-		return -EINVAL;
-	}
-}
+/* Helper macros for filter block array initializers. */
+
+/* ALU ops on registers, bpf_add|sub|...: A += X */
+
+#define BPF_ALU64_REG(OP, A, X)					\
+	((struct sock_filter_int) {				\
+		.code  = BPF_ALU64 | BPF_OP(OP) | BPF_X,	\
+		.a_reg = A,					\
+		.x_reg = X,					\
+		.off   = 0,					\
+		.imm   = 0 })
+
+#define BPF_ALU32_REG(OP, A, X)					\
+	((struct sock_filter_int) {				\
+		.code  = BPF_ALU | BPF_OP(OP) | BPF_X,		\
+		.a_reg = A,					\
+		.x_reg = X,					\
+		.off   = 0,					\
+		.imm   = 0 })
+
+/* ALU ops on immediates, bpf_add|sub|...: A += IMM */
+
+#define BPF_ALU64_IMM(OP, A, IMM)				\
+	((struct sock_filter_int) {				\
+		.code  = BPF_ALU64 | BPF_OP(OP) | BPF_K,	\
+		.a_reg = A,					\
+		.x_reg = 0,					\
+		.off   = 0,					\
+		.imm   = IMM })
+
+#define BPF_ALU32_IMM(OP, A, IMM)				\
+	((struct sock_filter_int) {				\
+		.code  = BPF_ALU | BPF_OP(OP) | BPF_K,		\
+		.a_reg = A,					\
+		.x_reg = 0,					\
+		.off   = 0,					\
+		.imm   = IMM })
+
+/* Endianess conversion, cpu_to_{l,b}e(), {l,b}e_to_cpu() */
+
+#define BPF_ENDIAN(TYPE, A, LEN)				\
+	((struct sock_filter_int) {				\
+		.code  = BPF_ALU | BPF_END | BPF_SRC(TYPE),	\
+		.a_reg = A,					\
+		.x_reg = 0,					\
+		.off   = 0,					\
+		.imm   = LEN })
+
+/* Short form of mov, A = X */
+
+#define BPF_MOV64_REG(A, X)					\
+	((struct sock_filter_int) {				\
+		.code  = BPF_ALU64 | BPF_MOV | BPF_X,		\
+		.a_reg = A,					\
+		.x_reg = X,					\
+		.off   = 0,					\
+		.imm   = 0 })
+
+#define BPF_MOV32_REG(A, X)					\
+	((struct sock_filter_int) {				\
+		.code  = BPF_ALU | BPF_MOV | BPF_X,		\
+		.a_reg = A,					\
+		.x_reg = X,					\
+		.off   = 0,					\
+		.imm   = 0 })
+
+/* Short form of mov, A = IMM */
+
+#define BPF_MOV64_IMM(A, IMM)					\
+	((struct sock_filter_int) {				\
+		.code  = BPF_ALU64 | BPF_MOV | BPF_K,		\
+		.a_reg = A,					\
+		.x_reg = 0,					\
+		.off   = 0,					\
+		.imm   = IMM })
+
+#define BPF_MOV32_IMM(A, IMM)					\
+	((struct sock_filter_int) {				\
+		.code  = BPF_ALU | BPF_MOV | BPF_K,		\
+		.a_reg = A,					\
+		.x_reg = 0,					\
+		.off   = 0,					\
+		.imm   = IMM })
+
+/* Short form of mov based on type, BPF_X: A = X,  BPF_K: A = IMM */
+
+#define BPF_MOV64_RAW(TYPE, A, X, IMM)				\
+	((struct sock_filter_int) {				\
+		.code  = BPF_ALU64 | BPF_MOV | BPF_SRC(TYPE),	\
+		.a_reg = A,					\
+		.x_reg = X,					\
+		.off   = 0,					\
+		.imm   = IMM })
+
+#define BPF_MOV32_RAW(TYPE, A, X, IMM)				\
+	((struct sock_filter_int) {				\
+		.code  = BPF_ALU | BPF_MOV | BPF_SRC(TYPE),	\
+		.a_reg = A,					\
+		.x_reg = X,					\
+		.off   = 0,					\
+		.imm   = IMM })
+
+/* Direct packet access, R0 = *(uint *) (skb->data + OFF) */
+
+#define BPF_LD_ABS(SIZE, OFF)					\
+	((struct sock_filter_int) {				\
+		.code  = BPF_LD | BPF_SIZE(SIZE) | BPF_ABS,	\
+		.a_reg = 0,					\
+		.x_reg = 0,					\
+		.off   = 0,					\
+		.imm   = OFF })
+
+/* Indirect packet access, R0 = *(uint *) (skb->data + X + OFF) */
+
+#define BPF_LD_IND(SIZE, X, OFF)				\
+	((struct sock_filter_int) {				\
+		.code  = BPF_LD | BPF_SIZE(SIZE) | BPF_IND,	\
+		.a_reg = 0,					\
+		.x_reg = X,					\
+		.off   = 0,					\
+		.imm   = OFF })
+
+/* Memory store, A = *(uint *) (X + OFF), and vice versa */
+
+#define BPF_LDX_MEM(SIZE, A, X, OFF)				\
+	((struct sock_filter_int) {				\
+		.code  = BPF_LDX | BPF_SIZE(SIZE) | BPF_MEM,	\
+		.a_reg = A,					\
+		.x_reg = X,					\
+		.off   = OFF,					\
+		.imm   = 0 })
+
+#define BPF_STX_MEM(SIZE, A, X, OFF)				\
+	((struct sock_filter_int) {				\
+		.code  = BPF_STX | BPF_SIZE(SIZE) | BPF_MEM,	\
+		.a_reg = A,					\
+		.x_reg = X,					\
+		.off   = OFF,					\
+		.imm   = 0 })
+
+/* Conditional jumps against registers, if (A 'op' X) goto pc + OFF */
+
+#define BPF_JMP_REG(OP, A, X, OFF)				\
+	((struct sock_filter_int) {				\
+		.code  = BPF_JMP | BPF_OP(OP) | BPF_X,		\
+		.a_reg = A,					\
+		.x_reg = X,					\
+		.off   = OFF,					\
+		.imm   = 0 })
+
+/* Conditional jumps against immediates, if (A 'op' IMM) goto pc + OFF */
+
+#define BPF_JMP_IMM(OP, A, IMM, OFF)				\
+	((struct sock_filter_int) {				\
+		.code  = BPF_JMP | BPF_OP(OP) | BPF_K,		\
+		.a_reg = A,					\
+		.x_reg = 0,					\
+		.off   = OFF,					\
+		.imm   = IMM })
+
+/* Function call */
+
+#define BPF_EMIT_CALL(FUNC)					\
+	((struct sock_filter_int) {				\
+		.code  = BPF_JMP | BPF_CALL,			\
+		.a_reg = 0,					\
+		.x_reg = 0,					\
+		.off   = 0,					\
+		.imm   = ((FUNC) - __bpf_call_base) })
+
+/* Raw code statement block */
+
+#define BPF_RAW_INSN(CODE, A, X, OFF, IMM)			\
+	((struct sock_filter_int) {				\
+		.code  = CODE,					\
+		.a_reg = A,					\
+		.x_reg = X,					\
+		.off   = OFF,					\
+		.imm   = IMM })
+
+/* Program exit */
+
+#define BPF_EXIT_INSN()						\
+	((struct sock_filter_int) {				\
+		.code  = BPF_JMP | BPF_EXIT,			\
+		.a_reg = 0,					\
+		.x_reg = 0,					\
+		.off   = 0,					\
+		.imm   = 0 })
+
+#define bytes_to_bpf_size(bytes)				\
+({								\
+	int bpf_size = -EINVAL;					\
+								\
+	if (bytes == sizeof(u8))				\
+		bpf_size = BPF_B;				\
+	else if (bytes == sizeof(u16))				\
+		bpf_size = BPF_H;				\
+	else if (bytes == sizeof(u32))				\
+		bpf_size = BPF_W;				\
+	else if (bytes == sizeof(u64))				\
+		bpf_size = BPF_DW;				\
+								\
+	bpf_size;						\
+})
 
 /* Macro to invoke filter function. */
 #define SK_RUN_FILTER(filter, ctx)  (*filter->bpf_func)(ctx, filter->insnsi)
diff --git a/net/core/filter.c b/net/core/filter.c
index 328aaf6..842f839 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -672,14 +672,10 @@ static bool convert_bpf_extensions(struct sock_filter *fp,
 		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, protocol) != 2);
 
 		/* A = *(u16 *) (ctx + offsetof(protocol)) */
-		*insn = BPF_LDX_MEM(BPF_H, BPF_REG_A, BPF_REG_CTX,
-				    offsetof(struct sk_buff, protocol));
-		insn++;
-
+		*insn++ = BPF_LDX_MEM(BPF_H, BPF_REG_A, BPF_REG_CTX,
+				      offsetof(struct sk_buff, protocol));
 		/* A = ntohs(A) [emitting a nop or swap16] */
-		insn->code = BPF_ALU | BPF_END | BPF_FROM_BE;
-		insn->a_reg = BPF_REG_A;
-		insn->imm = 16;
+		*insn = BPF_ENDIAN(BPF_FROM_BE, BPF_REG_A, 16);
 		break;
 
 	case SKF_AD_OFF + SKF_AD_PKTTYPE:
@@ -688,37 +684,27 @@ static bool convert_bpf_extensions(struct sock_filter *fp,
 		if (insn->off < 0)
 			return false;
 		insn++;
-
 		*insn = BPF_ALU32_IMM(BPF_AND, BPF_REG_A, PKT_TYPE_MAX);
 		break;
 
 	case SKF_AD_OFF + SKF_AD_IFINDEX:
 	case SKF_AD_OFF + SKF_AD_HATYPE:
-		*insn = BPF_LDX_MEM(size_to_bpf(FIELD_SIZEOF(struct sk_buff, dev)),
-				    BPF_REG_TMP, BPF_REG_CTX,
-				    offsetof(struct sk_buff, dev));
-		insn++;
-
-		/* if (tmp != 0) goto pc+1 */
-		*insn = BPF_JMP_IMM(BPF_JNE, BPF_REG_TMP, 0, 1);
-		insn++;
-
-		*insn = BPF_EXIT_INSN();
-		insn++;
-
 		BUILD_BUG_ON(FIELD_SIZEOF(struct net_device, ifindex) != 4);
 		BUILD_BUG_ON(FIELD_SIZEOF(struct net_device, type) != 2);
-
-		insn->a_reg = BPF_REG_A;
-		insn->x_reg = BPF_REG_TMP;
-
-		if (fp->k == SKF_AD_OFF + SKF_AD_IFINDEX) {
-			insn->code = BPF_LDX | BPF_MEM | BPF_W;
-			insn->off = offsetof(struct net_device, ifindex);
-		} else {
-			insn->code = BPF_LDX | BPF_MEM | BPF_H;
-			insn->off = offsetof(struct net_device, type);
-		}
+		BUILD_BUG_ON(bytes_to_bpf_size(FIELD_SIZEOF(struct sk_buff, dev)) < 0);
+
+		*insn++ = BPF_LDX_MEM(bytes_to_bpf_size(FIELD_SIZEOF(struct sk_buff, dev)),
+				      BPF_REG_TMP, BPF_REG_CTX,
+				      offsetof(struct sk_buff, dev));
+		/* if (tmp != 0) goto pc + 1 */
+		*insn++ = BPF_JMP_IMM(BPF_JNE, BPF_REG_TMP, 0, 1);
+		*insn++ = BPF_EXIT_INSN();
+		if (fp->k == SKF_AD_OFF + SKF_AD_IFINDEX)
+			*insn = BPF_LDX_MEM(BPF_W, BPF_REG_A, BPF_REG_TMP,
+					    offsetof(struct net_device, ifindex));
+		else
+			*insn = BPF_LDX_MEM(BPF_H, BPF_REG_A, BPF_REG_TMP,
+					    offsetof(struct net_device, type));
 		break;
 
 	case SKF_AD_OFF + SKF_AD_MARK:
@@ -745,22 +731,17 @@ static bool convert_bpf_extensions(struct sock_filter *fp,
 	case SKF_AD_OFF + SKF_AD_VLAN_TAG:
 	case SKF_AD_OFF + SKF_AD_VLAN_TAG_PRESENT:
 		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, vlan_tci) != 2);
-
-		/* A = *(u16 *) (ctx + offsetof(vlan_tci)) */
-		*insn = BPF_LDX_MEM(BPF_H, BPF_REG_A, BPF_REG_CTX,
-				    offsetof(struct sk_buff, vlan_tci));
-		insn++;
-
 		BUILD_BUG_ON(VLAN_TAG_PRESENT != 0x1000);
 
+		/* A = *(u16 *) (ctx + offsetof(vlan_tci)) */
+		*insn++ = BPF_LDX_MEM(BPF_H, BPF_REG_A, BPF_REG_CTX,
+				      offsetof(struct sk_buff, vlan_tci));
 		if (fp->k == SKF_AD_OFF + SKF_AD_VLAN_TAG) {
 			*insn = BPF_ALU32_IMM(BPF_AND, BPF_REG_A,
 					      ~VLAN_TAG_PRESENT);
 		} else {
 			/* A >>= 12 */
-			*insn = BPF_ALU32_IMM(BPF_RSH, BPF_REG_A, 12);
-			insn++;
-
+			*insn++ = BPF_ALU32_IMM(BPF_RSH, BPF_REG_A, 12);
 			/* A &= 1 */
 			*insn = BPF_ALU32_IMM(BPF_AND, BPF_REG_A, 1);
 		}
@@ -772,34 +753,27 @@ static bool convert_bpf_extensions(struct sock_filter *fp,
 	case SKF_AD_OFF + SKF_AD_CPU:
 	case SKF_AD_OFF + SKF_AD_RANDOM:
 		/* arg1 = ctx */
-		*insn = BPF_ALU64_REG(BPF_MOV, BPF_REG_ARG1, BPF_REG_CTX);
-		insn++;
-
+		*insn++ = BPF_MOV64_REG(BPF_REG_ARG1, BPF_REG_CTX);
 		/* arg2 = A */
-		*insn = BPF_ALU64_REG(BPF_MOV, BPF_REG_ARG2, BPF_REG_A);
-		insn++;
-
+		*insn++ = BPF_MOV64_REG(BPF_REG_ARG2, BPF_REG_A);
 		/* arg3 = X */
-		*insn = BPF_ALU64_REG(BPF_MOV, BPF_REG_ARG3, BPF_REG_X);
-		insn++;
-
+		*insn++ = BPF_MOV64_REG(BPF_REG_ARG3, BPF_REG_X);
 		/* Emit call(ctx, arg2=A, arg3=X) */
-		insn->code = BPF_JMP | BPF_CALL;
 		switch (fp->k) {
 		case SKF_AD_OFF + SKF_AD_PAY_OFFSET:
-			insn->imm = __skb_get_pay_offset - __bpf_call_base;
+			*insn = BPF_EMIT_CALL(__skb_get_pay_offset);
 			break;
 		case SKF_AD_OFF + SKF_AD_NLATTR:
-			insn->imm = __skb_get_nlattr - __bpf_call_base;
+			*insn = BPF_EMIT_CALL(__skb_get_nlattr);
 			break;
 		case SKF_AD_OFF + SKF_AD_NLATTR_NEST:
-			insn->imm = __skb_get_nlattr_nest - __bpf_call_base;
+			*insn = BPF_EMIT_CALL(__skb_get_nlattr_nest);
 			break;
 		case SKF_AD_OFF + SKF_AD_CPU:
-			insn->imm = __get_raw_cpu_id - __bpf_call_base;
+			*insn = BPF_EMIT_CALL(__get_raw_cpu_id);
 			break;
 		case SKF_AD_OFF + SKF_AD_RANDOM:
-			insn->imm = __get_random_u32 - __bpf_call_base;
+			*insn = BPF_EMIT_CALL(__get_random_u32);
 			break;
 		}
 		break;
@@ -871,9 +845,8 @@ do_pass:
 	new_insn = new_prog;
 	fp = prog;
 
-	if (new_insn) {
-		*new_insn = BPF_ALU64_REG(BPF_MOV, BPF_REG_CTX, BPF_REG_ARG1);
-	}
+	if (new_insn)
+		*new_insn = BPF_MOV64_REG(BPF_REG_CTX, BPF_REG_ARG1);
 	new_insn++;
 
 	for (i = 0; i < len; fp++, i++) {
@@ -921,17 +894,16 @@ do_pass:
 			    convert_bpf_extensions(fp, &insn))
 				break;
 
-			insn->code = fp->code;
-			insn->a_reg = BPF_REG_A;
-			insn->x_reg = BPF_REG_X;
-			insn->imm = fp->k;
+			*insn = BPF_RAW_INSN(fp->code, BPF_REG_A, BPF_REG_X, 0, fp->k);
 			break;
 
-		/* Jump opcodes map as-is, but offsets need adjustment. */
-		case BPF_JMP | BPF_JA:
-			target = i + fp->k + 1;
-			insn->code = fp->code;
-#define EMIT_JMP							\
+		/* Jump transformation cannot use BPF block macros
+		 * everywhere as offset calculation and target updates
+		 * require a bit more work than the rest, i.e. jump
+		 * opcodes map as-is, but offsets need adjustment.
+		 */
+
+#define BPF_EMIT_JMP							\
 	do {								\
 		if (target >= len || target < 0)			\
 			goto err;					\
@@ -940,7 +912,10 @@ do_pass:
 		insn->off -= insn - tmp_insns;				\
 	} while (0)
 
-			EMIT_JMP;
+		case BPF_JMP | BPF_JA:
+			target = i + fp->k + 1;
+			insn->code = fp->code;
+			BPF_EMIT_JMP;
 			break;
 
 		case BPF_JMP | BPF_JEQ | BPF_K:
@@ -956,10 +931,7 @@ do_pass:
 				 * immediate into tmp register and use it
 				 * in compare insn.
 				 */
-				insn->code = BPF_ALU | BPF_MOV | BPF_K;
-				insn->a_reg = BPF_REG_TMP;
-				insn->imm = fp->k;
-				insn++;
+				*insn++ = BPF_MOV32_IMM(BPF_REG_TMP, fp->k);
 
 				insn->a_reg = BPF_REG_A;
 				insn->x_reg = BPF_REG_TMP;
@@ -975,7 +947,7 @@ do_pass:
 			if (fp->jf == 0) {
 				insn->code = BPF_JMP | BPF_OP(fp->code) | bpf_src;
 				target = i + fp->jt + 1;
-				EMIT_JMP;
+				BPF_EMIT_JMP;
 				break;
 			}
 
@@ -983,116 +955,94 @@ do_pass:
 			if (fp->jt == 0 && BPF_OP(fp->code) == BPF_JEQ) {
 				insn->code = BPF_JMP | BPF_JNE | bpf_src;
 				target = i + fp->jf + 1;
-				EMIT_JMP;
+				BPF_EMIT_JMP;
 				break;
 			}
 
 			/* Other jumps are mapped into two insns: Jxx and JA. */
 			target = i + fp->jt + 1;
 			insn->code = BPF_JMP | BPF_OP(fp->code) | bpf_src;
-			EMIT_JMP;
+			BPF_EMIT_JMP;
 			insn++;
 
 			insn->code = BPF_JMP | BPF_JA;
 			target = i + fp->jf + 1;
-			EMIT_JMP;
+			BPF_EMIT_JMP;
 			break;
 
 		/* ldxb 4 * ([14] & 0xf) is remaped into 6 insns. */
 		case BPF_LDX | BPF_MSH | BPF_B:
 			/* tmp = A */
-			*insn = BPF_ALU64_REG(BPF_MOV, BPF_REG_TMP, BPF_REG_A);
-			insn++;
-
+			*insn++ = BPF_MOV64_REG(BPF_REG_TMP, BPF_REG_A);
 			/* A = BPF_R0 = *(u8 *) (skb->data + K) */
-			*insn = BPF_LD_ABS(BPF_B, fp->k);
-			insn++;
-
+			*insn++ = BPF_LD_ABS(BPF_B, fp->k);
 			/* A &= 0xf */
-			*insn = BPF_ALU32_IMM(BPF_AND, BPF_REG_A, 0xf);
-			insn++;
-
+			*insn++ = BPF_ALU32_IMM(BPF_AND, BPF_REG_A, 0xf);
 			/* A <<= 2 */
-			*insn = BPF_ALU32_IMM(BPF_LSH, BPF_REG_A, 2);
-			insn++;
-
+			*insn++ = BPF_ALU32_IMM(BPF_LSH, BPF_REG_A, 2);
 			/* X = A */
-			*insn = BPF_ALU64_REG(BPF_MOV, BPF_REG_X, BPF_REG_A);
-			insn++;
-
+			*insn++ = BPF_MOV64_REG(BPF_REG_X, BPF_REG_A);
 			/* A = tmp */
-			*insn = BPF_ALU64_REG(BPF_MOV, BPF_REG_A, BPF_REG_TMP);
+			*insn = BPF_MOV64_REG(BPF_REG_A, BPF_REG_TMP);
 			break;
 
 		/* RET_K, RET_A are remaped into 2 insns. */
 		case BPF_RET | BPF_A:
 		case BPF_RET | BPF_K:
-			insn->code = BPF_ALU | BPF_MOV |
-				     (BPF_RVAL(fp->code) == BPF_K ?
-				      BPF_K : BPF_X);
-			insn->a_reg = 0;
-			insn->x_reg = BPF_REG_A;
-			insn->imm = fp->k;
-			insn++;
-
+			*insn++ = BPF_MOV32_RAW(BPF_RVAL(fp->code) == BPF_K ?
+						BPF_K : BPF_X, BPF_REG_0,
+						BPF_REG_A, fp->k);
 			*insn = BPF_EXIT_INSN();
 			break;
 
 		/* Store to stack. */
 		case BPF_ST:
 		case BPF_STX:
-			insn->code = BPF_STX | BPF_MEM | BPF_W;
-			insn->a_reg = BPF_REG_FP;
-			insn->x_reg = fp->code == BPF_ST ?
-				      BPF_REG_A : BPF_REG_X;
-			insn->off = -(BPF_MEMWORDS - fp->k) * 4;
+			*insn = BPF_STX_MEM(BPF_W, BPF_REG_FP, BPF_CLASS(fp->code) ==
+					    BPF_ST ? BPF_REG_A : BPF_REG_X,
+					    -(BPF_MEMWORDS - fp->k) * 4);
 			break;
 
 		/* Load from stack. */
 		case BPF_LD | BPF_MEM:
 		case BPF_LDX | BPF_MEM:
-			insn->code = BPF_LDX | BPF_MEM | BPF_W;
-			insn->a_reg = BPF_CLASS(fp->code) == BPF_LD ?
-				      BPF_REG_A : BPF_REG_X;
-			insn->x_reg = BPF_REG_FP;
-			insn->off = -(BPF_MEMWORDS - fp->k) * 4;
+			*insn = BPF_LDX_MEM(BPF_W, BPF_CLASS(fp->code) == BPF_LD  ?
+					    BPF_REG_A : BPF_REG_X, BPF_REG_FP,
+					    -(BPF_MEMWORDS - fp->k) * 4);
 			break;
 
 		/* A = K or X = K */
 		case BPF_LD | BPF_IMM:
 		case BPF_LDX | BPF_IMM:
-			insn->code = BPF_ALU | BPF_MOV | BPF_K;
-			insn->a_reg = BPF_CLASS(fp->code) == BPF_LD ?
-				      BPF_REG_A : BPF_REG_X;
-			insn->imm = fp->k;
+			*insn = BPF_MOV32_IMM(BPF_CLASS(fp->code) == BPF_LD ?
+					      BPF_REG_A : BPF_REG_X, fp->k);
 			break;
 
 		/* X = A */
 		case BPF_MISC | BPF_TAX:
-			*insn = BPF_ALU64_REG(BPF_MOV, BPF_REG_X, BPF_REG_A);
+			*insn = BPF_MOV64_REG(BPF_REG_X, BPF_REG_A);
 			break;
 
 		/* A = X */
 		case BPF_MISC | BPF_TXA:
-			*insn = BPF_ALU64_REG(BPF_MOV, BPF_REG_A, BPF_REG_X);
+			*insn = BPF_MOV64_REG(BPF_REG_A, BPF_REG_X);
 			break;
 
 		/* A = skb->len or X = skb->len */
 		case BPF_LD | BPF_W | BPF_LEN:
 		case BPF_LDX | BPF_W | BPF_LEN:
-			insn->code = BPF_LDX | BPF_MEM | BPF_W;
-			insn->a_reg = BPF_CLASS(fp->code) == BPF_LD ?
-				      BPF_REG_A : BPF_REG_X;
-			insn->x_reg = BPF_REG_CTX;
-			insn->off = offsetof(struct sk_buff, len);
+			*insn = BPF_LDX_MEM(BPF_W, BPF_CLASS(fp->code) == BPF_LD ?
+					    BPF_REG_A : BPF_REG_X, BPF_REG_CTX,
+					    offsetof(struct sk_buff, len));
 			break;
 
-		/* access seccomp_data fields */
+		/* Access seccomp_data fields. */
 		case BPF_LDX | BPF_ABS | BPF_W:
 			/* A = *(u32 *) (ctx + K) */
 			*insn = BPF_LDX_MEM(BPF_W, BPF_REG_A, BPF_REG_CTX, fp->k);
 			break;
 
+		/* Unkown instruction. */
 		default:
 			goto err;
 		}
@@ -1101,7 +1051,6 @@ do_pass:
 		if (new_prog)
 			memcpy(new_insn, tmp_insns,
 			       sizeof(*insn) * (insn - tmp_insns));
-
 		new_insn += insn - tmp_insns;
 	}
 
@@ -1116,7 +1065,6 @@ do_pass:
 		new_flen = new_insn - new_prog;
 		if (pass > 2)
 			goto err;
-
 		goto do_pass;
 	}
 
-- 
1.7.11.7
