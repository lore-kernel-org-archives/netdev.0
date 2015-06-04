From: Markos Chandras <markos.chandras@imgtec.com>
Subject: [PATCH 6/6] MIPS: net: BPF: Introduce BPF ASM helpers
Date: Thu, 4 Jun 2015 11:56:16 +0100
Message-ID: <1433415376-20952-7-git-send-email-markos.chandras@imgtec.com>
References: <1433415376-20952-1-git-send-email-markos.chandras@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Markos Chandras <markos.chandras@imgtec.com>,
	<netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	"Hannes Frederic Sowa" <hannes@stressinduktion.org>,
	<linux-kernel@vger.kernel.org>
To: <linux-mips@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailapp01.imgtec.com ([195.59.15.196]:31775 "EHLO
	mailapp01.imgtec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753387AbbFDK5A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 06:57:00 -0400
In-Reply-To: <1433415376-20952-1-git-send-email-markos.chandras@imgtec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit introduces BPF ASM helpers for MIPS and MIPS64 kernels.
The purpose of this patch is to twofold:

1) We are now able to handle negative offsets instead of either
falling back to the interpreter or to simply not do anything and
bail out.

2) Optimize reads from the packet header instead of calling the C
helpers

Because of this patch, we are now able to get rid of quite a bit of
code in the JIT generation process by using MIPS optimized assembly
code. The new assembly code makes the test_bpf testsuite happy with
all 60 test passing successfully compared to the previous
implementation where 2 tests were failing.
Doing some basic analysis in the results between the old
implementation and the new one we can obtain the following
summary running current mainline on an ER8 board (+/- 30us delta is
ignored to prevent noise from kernel scheduling or IRQ latencies):

Summary: 22 tests are faster, 7 are slower and 47 saw no improvement

with the most notable improvement being the tcpdump tests. The 7 tests
that seem to be a bit slower is because they all follow the slow path
(bpf_internal_load_pointer_neg_helper) which is meant to be slow so
that's not a problem.

Cc: netdev@vger.kernel.org
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexei Starovoitov <ast@plumgrid.com>
Cc: Daniel Borkmann <dborkman@redhat.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Markos Chandras <markos.chandras@imgtec.com>
---
I have uploaded the script and the bpf result files in my LMO webspace
in case you want to have a look. I didn't paste them in here because they
are nearly 200 lines. Simply download all 3 files and run './bpf_analysis.py'

http://www.linux-mips.org/~mchandras/bpf/
---
 arch/mips/net/Makefile      |   2 +-
 arch/mips/net/bpf_jit.c     | 174 +++++++++-----------------------
 arch/mips/net/bpf_jit.h     |  33 +++---
 arch/mips/net/bpf_jit_asm.S | 238 ++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 302 insertions(+), 145 deletions(-)
 create mode 100644 arch/mips/net/bpf_jit_asm.S

diff --git a/arch/mips/net/Makefile b/arch/mips/net/Makefile
index ae74b3a91f5c..8c2771401f54 100644
--- a/arch/mips/net/Makefile
+++ b/arch/mips/net/Makefile
@@ -1,3 +1,3 @@
 # MIPS networking code
 
-obj-$(CONFIG_BPF_JIT) += bpf_jit.o
+obj-$(CONFIG_BPF_JIT) += bpf_jit.o bpf_jit_asm.o
diff --git a/arch/mips/net/bpf_jit.c b/arch/mips/net/bpf_jit.c
index f0db4f8310b2..0c4a133f6216 100644
--- a/arch/mips/net/bpf_jit.c
+++ b/arch/mips/net/bpf_jit.c
@@ -29,11 +29,14 @@
 #include "bpf_jit.h"
 
 /* ABI
- *
+ * r_skb_hl	SKB header length
+ * r_data	SKB data pointer
+ * r_off	Offset
  * r_A		BPF register A
  * r_X		BPF register X
  * r_skb	*skb
  * r_M		*scratch memory
+ * r_skb_len	SKB length
  *
  * On entry (*bpf_func)(*skb, *filter)
  * a0 = MIPS_R_A0 = skb;
@@ -75,6 +78,8 @@
 #define SEEN_X			SEEN_SREG(4)
 #define SEEN_SKB		SEEN_SREG(5)
 #define SEEN_MEM		SEEN_SREG(6)
+/* SEEN_SK_DATA also implies skb_hl an skb_len */
+#define SEEN_SKB_DATA		(SEEN_SREG(7) | SEEN_SREG(1) | SEEN_SREG(0))
 
 /* Arguments used by JIT */
 #define ARGS_USED_BY_JIT	2 /* only applicable to 64-bit */
@@ -537,20 +542,6 @@ static void save_bpf_jit_regs(struct jit_ctx *ctx, unsigned offset)
 	/* Adjust the stack pointer */
 	emit_stack_offset(-align_sp(offset), ctx);
 
-	if (ctx->flags & SEEN_CALL) {
-		/* Argument save area */
-		if (config_enabled(CONFIG_64BIT))
-			/* Bottom of current frame */
-			real_off = align_sp(offset) - SZREG;
-		else
-			/* Top of previous frame */
-			real_off = align_sp(offset) + SZREG;
-		emit_store_stack_reg(MIPS_R_A0, r_sp, real_off, ctx);
-		emit_store_stack_reg(MIPS_R_A1, r_sp, real_off + SZREG, ctx);
-
-		real_off = 0;
-	}
-
 	tmp_flags = sflags = ctx->flags >> SEEN_SREG_SFT;
 	/* sflags is essentially a bitmap */
 	while (tmp_flags) {
@@ -583,19 +574,6 @@ static void restore_bpf_jit_regs(struct jit_ctx *ctx,
 	int i, real_off = 0;
 	u32 sflags, tmp_flags;
 
-	if (ctx->flags & SEEN_CALL) {
-		if (config_enabled(CONFIG_64BIT))
-			/* Bottom of current frame */
-			real_off = align_sp(offset) - SZREG;
-		else
-			/* Top of previous frame */
-			real_off = align_sp(offset) + SZREG;
-		emit_load_stack_reg(MIPS_R_A0, r_sp, real_off, ctx);
-		emit_load_stack_reg(MIPS_R_A1, r_sp, real_off + SZREG, ctx);
-
-		real_off = 0;
-	}
-
 	tmp_flags = sflags = ctx->flags >> SEEN_SREG_SFT;
 	/* sflags is a bitmap */
 	i = 0;
@@ -629,17 +607,7 @@ static unsigned int get_stack_depth(struct jit_ctx *ctx)
 		sp_off += 4 * BPF_MEMWORDS; /* BPF_MEMWORDS are 32-bit */
 
 	if (ctx->flags & SEEN_CALL)
-		/*
-		 * The JIT code make calls to external functions using 2
-		 * arguments. Therefore, for o32 we don't need to allocate
-		 * space because we don't care if the argumetns are lost
-		 * across calls. We do need however to preserve incoming
-		 * arguments but the space is already allocated for us by
-		 * the caller. On the other hand, for n64, we need to allocate
-		 * this space ourselves. We need to preserve $ra as well.
-		 */
-		sp_off += config_enabled(CONFIG_64BIT) ?
-			(ARGS_USED_BY_JIT + 1) * SZREG : SZREG;
+		sp_off += SZREG; /* Space for our ra register */
 
 	return sp_off;
 }
@@ -656,6 +624,19 @@ static void build_prologue(struct jit_ctx *ctx)
 	if (ctx->flags & SEEN_SKB)
 		emit_reg_move(r_skb, MIPS_R_A0, ctx);
 
+	if (ctx->flags & SEEN_SKB_DATA) {
+		/* Load packet length */
+		emit_load(r_skb_len, r_skb, offsetof(struct sk_buff, len),
+			  ctx);
+		emit_load(r_tmp, r_skb, offsetof(struct sk_buff, data_len),
+			  ctx);
+		/* Load the data pointer */
+		emit_load_ptr(r_skb_data, r_skb,
+			      offsetof(struct sk_buff, data), ctx);
+		/* Load the header length */
+		emit_subu(r_skb_hl, r_skb_len, r_tmp, ctx);
+	}
+
 	if (ctx->flags & SEEN_X)
 		emit_jit_reg_move(r_X, r_zero, ctx);
 
@@ -678,43 +659,17 @@ static void build_epilogue(struct jit_ctx *ctx)
 	emit_nop(ctx);
 }
 
-static u64 jit_get_skb_b(struct sk_buff *skb, unsigned offset)
-{
-	u8 ret;
-	int err;
-
-	err = skb_copy_bits(skb, offset, &ret, 1);
-
-	return (u64)err << 32 | ret;
-}
-
-static u64 jit_get_skb_h(struct sk_buff *skb, unsigned offset)
-{
-	u16 ret;
-	int err;
-
-	err = skb_copy_bits(skb, offset, &ret, 2);
-
-	return (u64)err << 32 | ntohs(ret);
-}
-
-static u64 jit_get_skb_w(struct sk_buff *skb, unsigned offset)
-{
-	u32 ret;
-	int err;
-
-	err = skb_copy_bits(skb, offset, &ret, 4);
-
-	return (u64)err << 32 | ntohl(ret);
-}
+#define CHOOSE_LOAD_FUNC(K, func) \
+	((int)K < 0 ? ((int)K >= SKF_LL_OFF ? func##_negative : func) : \
+	 func##_positive)
 
 static int build_body(struct jit_ctx *ctx)
 {
-	void *load_func[] = {jit_get_skb_b, jit_get_skb_h, jit_get_skb_w};
 	const struct bpf_prog *prog = ctx->skf;
 	const struct sock_filter *inst;
-	unsigned int i, off, load_order, condt;
+	unsigned int i, off, condt;
 	u32 k, b_off __maybe_unused;
+	u8 (*sk_load_func)(unsigned long *skb, int offset);
 
 	for (i = 0; i < prog->len; i++) {
 		u16 code;
@@ -748,71 +703,46 @@ static int build_body(struct jit_ctx *ctx)
 			break;
 		case BPF_LD | BPF_W | BPF_ABS:
 			/* A <- P[k:4] */
-			load_order = 2;
+			sk_load_func = CHOOSE_LOAD_FUNC(k, sk_load_word);
 			goto load;
 		case BPF_LD | BPF_H | BPF_ABS:
 			/* A <- P[k:2] */
-			load_order = 1;
+			sk_load_func = CHOOSE_LOAD_FUNC(k, sk_load_half);
 			goto load;
 		case BPF_LD | BPF_B | BPF_ABS:
 			/* A <- P[k:1] */
-			load_order = 0;
+			sk_load_func = CHOOSE_LOAD_FUNC(k, sk_load_byte);
 load:
-			/* the interpreter will deal with the negative K */
-			if ((int)k < 0)
-				return -ENOTSUPP;
-
 			emit_load_imm(r_off, k, ctx);
 load_common:
-			/*
-			 * We may got here from the indirect loads so
-			 * return if offset is negative.
-			 */
-			emit_slt(r_s0, r_off, r_zero, ctx);
-			emit_bcond(MIPS_COND_NE, r_s0, r_zero,
-				   b_imm(prog->len, ctx), ctx);
-			emit_reg_move(r_ret, r_zero, ctx);
-
 			ctx->flags |= SEEN_CALL | SEEN_OFF |
-				SEEN_SKB | SEEN_A;
+				SEEN_SKB | SEEN_A | SEEN_SKB_DATA;
 
-			emit_load_func(r_s0, (ptr)load_func[load_order],
-				      ctx);
+			emit_load_func(r_s0, (ptr)sk_load_func, ctx);
 			emit_reg_move(MIPS_R_A0, r_skb, ctx);
 			emit_jalr(MIPS_R_RA, r_s0, ctx);
 			/* Load second argument to delay slot */
 			emit_reg_move(MIPS_R_A1, r_off, ctx);
 			/* Check the error value */
-			if (config_enabled(CONFIG_64BIT)) {
-				/* Get error code from the top 32-bits */
-				emit_dsrl32(r_s0, r_val, 0, ctx);
-				/* Branch to 3 instructions ahead */
-				emit_bcond(MIPS_COND_NE, r_s0, r_zero, 3 << 2,
-					   ctx);
-			} else {
-				/* Branch to 3 instructions ahead */
-				emit_bcond(MIPS_COND_NE, r_err, r_zero, 3 << 2,
-					   ctx);
-			}
-			emit_nop(ctx);
-			/* We are good */
-			emit_b(b_imm(i + 1, ctx), ctx);
-			emit_jit_reg_move(r_A, r_val, ctx);
+			emit_bcond(MIPS_COND_EQ, r_ret, 0, b_imm(i + 1, ctx),
+				   ctx);
+			/* Load return register on DS for failures */
+			emit_reg_move(r_ret, r_zero, ctx);
 			/* Return with error */
 			emit_b(b_imm(prog->len, ctx), ctx);
-			emit_reg_move(r_ret, r_zero, ctx);
+			emit_nop(ctx);
 			break;
 		case BPF_LD | BPF_W | BPF_IND:
 			/* A <- P[X + k:4] */
-			load_order = 2;
+			sk_load_func = sk_load_word;
 			goto load_ind;
 		case BPF_LD | BPF_H | BPF_IND:
 			/* A <- P[X + k:2] */
-			load_order = 1;
+			sk_load_func = sk_load_half;
 			goto load_ind;
 		case BPF_LD | BPF_B | BPF_IND:
 			/* A <- P[X + k:1] */
-			load_order = 0;
+			sk_load_func = sk_load_byte;
 load_ind:
 			ctx->flags |= SEEN_OFF | SEEN_X;
 			emit_addiu(r_off, r_X, k, ctx);
@@ -834,14 +764,10 @@ load_ind:
 			emit_load(r_X, r_skb, off, ctx);
 			break;
 		case BPF_LDX | BPF_B | BPF_MSH:
-			/* the interpreter will deal with the negative K */
-			if ((int)k < 0)
-				return -ENOTSUPP;
-
 			/* X <- 4 * (P[k:1] & 0xf) */
 			ctx->flags |= SEEN_X | SEEN_CALL | SEEN_SKB;
 			/* Load offset to a1 */
-			emit_load_func(r_s0, (ptr)jit_get_skb_b, ctx);
+			emit_load_func(r_s0, (ptr)sk_load_byte, ctx);
 			/*
 			 * This may emit two instructions so it may not fit
 			 * in the delay slot. So use a0 in the delay slot.
@@ -850,25 +776,15 @@ load_ind:
 			emit_jalr(MIPS_R_RA, r_s0, ctx);
 			emit_reg_move(MIPS_R_A0, r_skb, ctx); /* delay slot */
 			/* Check the error value */
-			if (config_enabled(CONFIG_64BIT)) {
-				/* Top 32-bits of $v0 on 64-bit */
-				emit_dsrl32(r_s0, r_val, 0, ctx);
-				emit_bcond(MIPS_COND_NE, r_s0, r_zero,
-					   3 << 2, ctx);
-			} else {
-				emit_bcond(MIPS_COND_NE, r_err, r_zero,
-					   3 << 2, ctx);
-			}
-			/* No need for delay slot */
+			emit_bcond(MIPS_COND_NE, r_ret, 0,
+				   b_imm(prog->len, ctx), ctx);
+			emit_reg_move(r_ret, r_zero, ctx);
 			/* We are good */
 			/* X <- P[1:K] & 0xf */
-			emit_andi(r_X, r_val, 0xf, ctx);
+			emit_andi(r_X, r_A, 0xf, ctx);
 			/* X << 2 */
 			emit_b(b_imm(i + 1, ctx), ctx);
 			emit_sll(r_X, r_X, 2, ctx); /* delay slot */
-			/* Return with error */
-			emit_b(b_imm(prog->len, ctx), ctx);
-			emit_load_imm(r_ret, 0, ctx); /* delay slot */
 			break;
 		case BPF_ST:
 			/* M[k] <- A */
@@ -942,7 +858,7 @@ load_ind:
 			/* Check if r_X is zero */
 			emit_bcond(MIPS_COND_EQ, r_X, r_zero,
 				   b_imm(prog->len, ctx), ctx);
-			emit_load_imm(r_val, 0, ctx); /* delay slot */
+			emit_load_imm(r_ret, 0, ctx); /* delay slot */
 			emit_div(r_A, r_X, ctx);
 			break;
 		case BPF_ALU | BPF_MOD | BPF_X:
@@ -951,7 +867,7 @@ load_ind:
 			/* Check if r_X is zero */
 			emit_bcond(MIPS_COND_EQ, r_X, r_zero,
 				   b_imm(prog->len, ctx), ctx);
-			emit_load_imm(r_val, 0, ctx); /* delay slot */
+			emit_load_imm(r_ret, 0, ctx); /* delay slot */
 			emit_mod(r_A, r_X, ctx);
 			break;
 		case BPF_ALU | BPF_OR | BPF_K:
diff --git a/arch/mips/net/bpf_jit.h b/arch/mips/net/bpf_jit.h
index 3afa7a6d81b3..8f9f54841123 100644
--- a/arch/mips/net/bpf_jit.h
+++ b/arch/mips/net/bpf_jit.h
@@ -15,7 +15,6 @@
 /* Registers used by JIT */
 #define MIPS_R_ZERO	0
 #define MIPS_R_V0	2
-#define MIPS_R_V1	3
 #define MIPS_R_A0	4
 #define MIPS_R_A1	5
 #define MIPS_R_T4	12
@@ -43,20 +42,6 @@
 #define MIPS_COND_X	(0x1 << 5)
 #define MIPS_COND_K	(0x1 << 6)
 
-/* ABI specific return values */
-#ifdef CONFIG_32BIT /* O32 */
-#ifdef CONFIG_CPU_LITTLE_ENDIAN
-#define r_err	MIPS_R_V1
-#define r_val	MIPS_R_V0
-#else /* CONFIG_CPU_LITTLE_ENDIAN */
-#define r_err	MIPS_R_V0
-#define r_val	MIPS_R_V1
-#endif
-#else /* N64 */
-#define r_err	MIPS_R_V0
-#define r_val	MIPS_R_V0
-#endif
-
 #define r_ret	MIPS_R_V0
 
 /*
@@ -65,11 +50,14 @@
  * any of the $s0-$s6 registers will only be preserved if
  * they are going to actually be used.
  */
+#define r_skb_hl	MIPS_R_S0 /* skb header length */
+#define r_skb_data	MIPS_R_S1 /* skb actual data */
 #define r_off		MIPS_R_S2
 #define r_A		MIPS_R_S3
 #define r_X		MIPS_R_S4
 #define r_skb		MIPS_R_S5
 #define r_M		MIPS_R_S6
+#define r_skb_len	MIPS_R_S7
 #define r_s0		MIPS_R_T4 /* scratch reg 1 */
 #define r_s1		MIPS_R_T5 /* scratch reg 2 */
 #define r_tmp_imm	MIPS_R_T6 /* No need to preserve this */
@@ -78,4 +66,19 @@
 #define r_sp		MIPS_R_SP
 #define r_ra		MIPS_R_RA
 
+#ifndef __ASSEMBLY__
+
+/* Declare ASM helpers */
+
+#define DECLARE_LOAD_FUNC(func) \
+	extern u8 func(unsigned long *skb, int offset); \
+	extern u8 func##_negative(unsigned long *skb, int offset); \
+	extern u8 func##_positive(unsigned long *skb, int offset)
+
+DECLARE_LOAD_FUNC(sk_load_word);
+DECLARE_LOAD_FUNC(sk_load_half);
+DECLARE_LOAD_FUNC(sk_load_byte);
+
+#endif
+
 #endif /* BPF_JIT_MIPS_OP_H */
diff --git a/arch/mips/net/bpf_jit_asm.S b/arch/mips/net/bpf_jit_asm.S
new file mode 100644
index 000000000000..365d6dfdce51
--- /dev/null
+++ b/arch/mips/net/bpf_jit_asm.S
@@ -0,0 +1,238 @@
+/*
+ * bpf_jib_asm.S: Packet/header access helper functions for MIPS/MIPS64 BPF
+ * compiler.
+ *
+ * Copyright (C) 2015 Imagination Technologies Ltd.
+ * Author: Markos Chandras <markos.chandras@imgtec.com>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the
+ * Free Software Foundation; version 2 of the License.
+ */
+
+#include <asm/asm.h>
+#include <asm/regdef.h>
+#include "bpf_jit.h"
+
+/* ABI
+ *
+ * r_skb_hl	skb header length
+ * r_skb_data	skb data
+ * r_off(a1)	offset register
+ * r_A		BPF register A
+ * r_X		PF register X
+ * r_skb(a0)	*skb
+ * r_M		*scratch memory
+ * r_skb_le	skb length
+ * r_s0		Scratch register 0
+ * r_s1		Scratch register 1
+ *
+ * On entry:
+ * a0: *skb
+ * a1: offset (imm or imm + X)
+ *
+ * All non-BPF-ABI registers are free for use. On return, we only
+ * care about r_ret. The BPF-ABI registers are assumed to remain
+ * unmodified during the entire filter operation.
+ */
+
+#define skb	a0
+#define offset	a1
+#define SKF_LL_OFF  (-0x200000) /* Can't include linux/filter.h in assembly */
+
+	/* We know better :) so prevent assembler reordering etc */
+	.set 	noreorder
+
+#define is_offset_negative(TYPE)				\
+	/* If offset is negative we have more work to do */	\
+	slti	t0, offset, 0;					\
+	bgtz	t0, bpf_slow_path_##TYPE##_neg;			\
+	/* Be careful what follows in DS. */
+
+#define is_offset_in_header(SIZE, TYPE)				\
+	/* Reading from header? */				\
+	addiu	$r_s0, $r_skb_hl, -SIZE;			\
+	slt	t0, $r_s0, offset;				\
+	bgtz	t0, bpf_slow_path_##TYPE;			\
+
+LEAF(sk_load_word)
+	is_offset_negative(word)
+	.globl sk_load_word_positive
+sk_load_word_positive:
+	is_offset_in_header(4, word)
+	/* Offset within header boundaries */
+	PTR_ADDU t1, $r_skb_data, offset
+	lw	$r_A, 0(t1)
+#ifdef CONFIG_CPU_LITTLE_ENDIAN
+	wsbh	t0, $r_A
+	rotr	$r_A, t0, 16
+#endif
+	jr	$r_ra
+	 move	$r_ret, zero
+	END(sk_load_word)
+
+LEAF(sk_load_half)
+	is_offset_negative(half)
+	.globl sk_load_half_positive
+sk_load_half_positive:
+	is_offset_in_header(2, half)
+	/* Offset within header boundaries */
+	PTR_ADDU t1, $r_skb_data, offset
+	lh	$r_A, 0(t1)
+#ifdef CONFIG_CPU_LITTLE_ENDIAN
+	wsbh	t0, $r_A
+	seh	$r_A, t0
+#endif
+	jr	$r_ra
+	 move	$r_ret, zero
+	END(sk_load_half)
+
+LEAF(sk_load_byte)
+	is_offset_negative(byte)
+	.globl sk_load_byte_positive
+sk_load_byte_positive:
+	is_offset_in_header(1, byte)
+	/* Offset within header boundaries */
+	PTR_ADDU t1, $r_skb_data, offset
+	lb	$r_A, 0(t1)
+	jr	$r_ra
+	 move	$r_ret, zero
+	END(sk_load_byte)
+
+/*
+ * call skb_copy_bits:
+ * (prototype in linux/skbuff.h)
+ *
+ * int skb_copy_bits(sk_buff *skb, int offset, void *to, int len)
+ *
+ * o32 mandates we leave 4 spaces for argument registers in case
+ * the callee needs to use them. Even though we don't care about
+ * the argument registers ourselves, we need to allocate that space
+ * to remain ABI compliant since the callee may want to use that space.
+ * We also allocate 2 more spaces for $r_ra and our return register (*to).
+ *
+ * n64 is a bit different. The *caller* will allocate the space to preserve
+ * the arguments. So in 64-bit kernels, we allocate the 4-arg space for no
+ * good reason but it does not matter that much really.
+ *
+ * (void *to) is returned in r_s0
+ *
+ */
+#define bpf_slow_path_common(SIZE)				\
+	/* Quick check. Are we within reasonable boundaries? */ \
+	LONG_ADDIU	$r_s1, $r_skb_len, -SIZE;		\
+	sltu		$r_s0, offset, $r_s1;			\
+	beqz		$r_s0, fault;				\
+	/* Load 4th argument in DS */				\
+	 LONG_ADDIU	a3, zero, SIZE;				\
+	PTR_ADDIU	$r_sp, $r_sp, -(6 * SZREG);		\
+	PTR_LA		t0, skb_copy_bits;			\
+	PTR_S		$r_ra, (5 * SZREG)($r_sp);		\
+	/* Assign low slot to a2 */				\
+	move		a2, $r_sp;				\
+	jalr		t0;					\
+	/* Reset our destination slot (DS but it's ok) */	\
+	 INT_S		zero, (4 * SZREG)($r_sp);		\
+	/*							\
+	 * skb_copy_bits returns 0 on success and -EFAULT	\
+	 * on error. Our data live in a2. Do not bother with	\
+	 * our data if an error has been returned.		\
+	 */							\
+	/* Restore our frame */					\
+	PTR_L		$r_ra, (5 * SZREG)($r_sp);		\
+	INT_L		$r_s0, (4 * SZREG)($r_sp);		\
+	bltz		v0, fault;				\
+	 PTR_ADDIU	$r_sp, $r_sp, 6 * SZREG;		\
+	move		$r_ret, zero;				\
+
+NESTED(bpf_slow_path_word, (6 * SZREG), $r_sp)
+	bpf_slow_path_common(4)
+#ifdef CONFIG_CPU_LITTLE_ENDIAN
+	wsbh	t0, $r_s0
+	jr	$r_ra
+	 rotr	$r_A, t0, 16
+#endif
+	jr	$r_ra
+	move	$r_A, $r_s0
+
+	END(bpf_slow_path_word)
+
+NESTED(bpf_slow_path_half, (6 * SZREG), $r_sp)
+	bpf_slow_path_common(2)
+#ifdef CONFIG_CPU_LITTLE_ENDIAN
+	jr	$r_ra
+	 wsbh	$r_A, $r_s0
+#endif
+	jr	$r_ra
+	 move	$r_A, $r_s0
+
+	END(bpf_slow_path_half)
+
+NESTED(bpf_slow_path_byte, (6 * SZREG), $r_sp)
+	bpf_slow_path_common(1)
+	jr	$r_ra
+	 move	$r_A, $r_s0
+
+	END(bpf_slow_path_byte)
+
+/*
+ * Negative entry points
+ */
+	.macro bpf_is_end_of_data
+	li	t0, SKF_LL_OFF
+	/* Reading link layer data? */
+	slt	t1, offset, t0
+	bgtz	t1, fault
+	/* Be careful what follows in DS. */
+	.endm
+/*
+ * call skb_copy_bits:
+ * (prototype in linux/filter.h)
+ *
+ * void *bpf_internal_load_pointer_neg_helper(const struct sk_buff *skb,
+ *                                            int k, unsigned int size)
+ *
+ * see above (bpf_slow_path_common) for ABI restrictions
+ */
+#define bpf_negative_common(SIZE)					\
+	PTR_ADDIU	$r_sp, $r_sp, -(6 * SZREG);			\
+	PTR_LA		t0, bpf_internal_load_pointer_neg_helper;	\
+	PTR_S		$r_ra, (5 * SZREG)($r_sp);			\
+	jalr		t0;						\
+	 li		a2, SIZE;					\
+	PTR_L		$r_ra, (5 * SZREG)($r_sp);			\
+	/* Check return pointer */					\
+	beqz		v0, fault;					\
+	 PTR_ADDIU	$r_sp, $r_sp, 6 * SZREG;			\
+	/* Preserve our pointer */					\
+	move		$r_s0, v0;					\
+	/* Set return value */						\
+	move		$r_ret, zero;					\
+
+bpf_slow_path_word_neg:
+	bpf_is_end_of_data
+NESTED(sk_load_word_negative, (6 * SZREG), $r_sp)
+	bpf_negative_common(4)
+	jr	$r_ra
+	 lw	$r_A, 0($r_s0)
+	END(sk_load_word_negative)
+
+bpf_slow_path_half_neg:
+	bpf_is_end_of_data
+NESTED(sk_load_half_negative, (6 * SZREG), $r_sp)
+	bpf_negative_common(2)
+	jr	$r_ra
+	 lhu	$r_A, 0($r_s0)
+	END(sk_load_half_negative)
+
+bpf_slow_path_byte_neg:
+	bpf_is_end_of_data
+NESTED(sk_load_byte_negative, (6 * SZREG), $r_sp)
+	bpf_negative_common(1)
+	jr	$r_ra
+	 lbu	$r_A, 0($r_s0)
+	END(sk_load_byte_negative)
+
+fault:
+	jr	$r_ra
+	 addiu $r_ret, zero, 1
-- 
2.4.2
