From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: [PATCH net-next v2 3/6] ppc: bpf: update jit to use compatibility macros
Date: Tue, 17 Feb 2015 10:04:40 +0300
Message-ID: <1424156683-2682-4-git-send-email-kda@linux-powerpc.org>
References: <1424156683-2682-1-git-send-email-kda@linux-powerpc.org>
Cc: linuxppc-dev@lists.ozlabs.org,
	Denis Kirjanov <kda@linux-powerpc.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:38195 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932431AbbBQHAw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2015 02:00:52 -0500
Received: by lamq1 with SMTP id q1so33975750lam.5
        for <netdev@vger.kernel.org>; Mon, 16 Feb 2015 23:00:50 -0800 (PST)
In-Reply-To: <1424156683-2682-1-git-send-email-kda@linux-powerpc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use helpers from the asm-compat.h to wrap up assembly mnemonics

Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
---
 arch/powerpc/net/bpf_jit.h      | 47 ++++++++++++++++++++++++++-
 arch/powerpc/net/bpf_jit_64.S   | 70 ++++++++++++++++++++---------------------
 arch/powerpc/net/bpf_jit_comp.c | 32 ++++++++++---------
 3 files changed, 98 insertions(+), 51 deletions(-)

diff --git a/arch/powerpc/net/bpf_jit.h b/arch/powerpc/net/bpf_jit.h
index c406aa9..2d5e715 100644
--- a/arch/powerpc/net/bpf_jit.h
+++ b/arch/powerpc/net/bpf_jit.h
@@ -10,12 +10,25 @@
 #ifndef _BPF_JIT_H
 #define _BPF_JIT_H
 
+#ifdef CONFIG_PPC64
+#define BPF_PPC_STACK_R3_OFF	48
 #define BPF_PPC_STACK_LOCALS	32
 #define BPF_PPC_STACK_BASIC	(48+64)
 #define BPF_PPC_STACK_SAVE	(18*8)
 #define BPF_PPC_STACKFRAME	(BPF_PPC_STACK_BASIC+BPF_PPC_STACK_LOCALS+ \
 				 BPF_PPC_STACK_SAVE)
 #define BPF_PPC_SLOWPATH_FRAME	(48+64)
+#else
+#define BPF_PPC_STACK_R3_OFF	24
+#define BPF_PPC_STACK_LOCALS	16
+#define BPF_PPC_STACK_BASIC	(24+32)
+#define BPF_PPC_STACK_SAVE	(18*4)
+#define BPF_PPC_STACKFRAME	(BPF_PPC_STACK_BASIC+BPF_PPC_STACK_LOCALS+ \
+				 BPF_PPC_STACK_SAVE)
+#define BPF_PPC_SLOWPATH_FRAME	(24+32)
+#endif
+
+#define REG_SZ         (BITS_PER_LONG/8)
 
 /*
  * Generated code register usage:
@@ -57,7 +70,11 @@ DECLARE_LOAD_FUNC(sk_load_half);
 DECLARE_LOAD_FUNC(sk_load_byte);
 DECLARE_LOAD_FUNC(sk_load_byte_msh);
 
+#ifdef CONFIG_PPC64
 #define FUNCTION_DESCR_SIZE	24
+#else
+#define FUNCTION_DESCR_SIZE	0
+#endif
 
 /*
  * 16-bit immediate helper macros: HA() is for use with sign-extending instrs
@@ -86,7 +103,12 @@ DECLARE_LOAD_FUNC(sk_load_byte_msh);
 #define PPC_LIS(r, i)		PPC_ADDIS(r, 0, i)
 #define PPC_STD(r, base, i)	EMIT(PPC_INST_STD | ___PPC_RS(r) |	      \
 				     ___PPC_RA(base) | ((i) & 0xfffc))
-
+#define PPC_STDU(r, base, i)	EMIT(PPC_INST_STDU | ___PPC_RS(r) |	      \
+				     ___PPC_RA(base) | ((i) & 0xfffc))
+#define PPC_STW(r, base, i)	EMIT(PPC_INST_STW | ___PPC_RS(r) |	      \
+				     ___PPC_RA(base) | ((i) & 0xfffc))
+#define PPC_STWU(r, base, i)	EMIT(PPC_INST_STWU | ___PPC_RS(r) |	      \
+				     ___PPC_RA(base) | ((i) & 0xfffc))
 
 #define PPC_LBZ(r, base, i)	EMIT(PPC_INST_LBZ | ___PPC_RT(r) |	      \
 				     ___PPC_RA(base) | IMM_L(i))
@@ -98,6 +120,17 @@ DECLARE_LOAD_FUNC(sk_load_byte_msh);
 				     ___PPC_RA(base) | IMM_L(i))
 #define PPC_LHBRX(r, base, b)	EMIT(PPC_INST_LHBRX | ___PPC_RT(r) |	      \
 				     ___PPC_RA(base) | ___PPC_RB(b))
+
+#ifdef CONFIG_PPC64
+#define PPC_BPF_LL(r, base, i) do { PPC_LD(r, base, i); } while(0)
+#define PPC_BPF_STL(r, base, i) do { PPC_STD(r, base, i); } while(0)
+#define PPC_BPF_STLU(r, base, i) do { PPC_STDU(r, base, i); } while(0)
+#else
+#define PPC_BPF_LL(r, base, i) do { PPC_LWZ(r, base, i); } while(0)
+#define PPC_BPF_STL(r, base, i) do { PPC_STW(r, base, i); } while(0)
+#define PPC_BPF_STLU(r, base, i) do { PPC_STWU(r, base, i); } while(0)
+#endif
+
 /* Convenience helpers for the above with 'far' offsets: */
 #define PPC_LBZ_OFFS(r, base, i) do { if ((i) < 32768) PPC_LBZ(r, base, i);   \
 		else {	PPC_ADDIS(r, base, IMM_HA(i));			      \
@@ -115,6 +148,12 @@ DECLARE_LOAD_FUNC(sk_load_byte_msh);
 		else {	PPC_ADDIS(r, base, IMM_HA(i));			      \
 			PPC_LHZ(r, r, IMM_L(i)); } } while(0)
 
+#ifdef CONFIG_PPC64
+#define PPC_LL_OFFS(r, base, i) do { PPC_LD_OFFS(r, base, i); } while(0)
+#else
+#define PPC_LL_OFFS(r, base, i) do { PPC_LWZ_OFFS(r, base, i); } while(0)
+#endif
+
 #define PPC_CMPWI(a, i)		EMIT(PPC_INST_CMPWI | ___PPC_RA(a) | IMM_L(i))
 #define PPC_CMPDI(a, i)		EMIT(PPC_INST_CMPDI | ___PPC_RA(a) | IMM_L(i))
 #define PPC_CMPLWI(a, i)	EMIT(PPC_INST_CMPLWI | ___PPC_RA(a) | IMM_L(i))
@@ -196,6 +235,12 @@ DECLARE_LOAD_FUNC(sk_load_byte_msh);
 				PPC_ORI(d, d, (uintptr_t)(i) & 0xffff);	      \
 		} } while (0);
 
+#ifdef CONFIG_PPC64
+#define PPC_FUNC_ADDR(d,i) do { PPC_LI64(d, i); } while(0)
+#else
+#define PPC_FUNC_ADDR(d,i) do { PPC_LI32(d, i); } while(0)
+#endif
+
 #define PPC_LHBRX_OFFS(r, base, i) \
 		do { PPC_LI32(r, i); PPC_LHBRX(r, r, base); } while(0)
 #ifdef __LITTLE_ENDIAN__
diff --git a/arch/powerpc/net/bpf_jit_64.S b/arch/powerpc/net/bpf_jit_64.S
index 8f87d92..8ff5a3b 100644
--- a/arch/powerpc/net/bpf_jit_64.S
+++ b/arch/powerpc/net/bpf_jit_64.S
@@ -34,13 +34,13 @@
  */
 	.globl	sk_load_word
 sk_load_word:
-	cmpdi	r_addr, 0
+	PPC_LCMPI	r_addr, 0
 	blt	bpf_slow_path_word_neg
 	.globl	sk_load_word_positive_offset
 sk_load_word_positive_offset:
 	/* Are we accessing past headlen? */
 	subi	r_scratch1, r_HL, 4
-	cmpd	r_scratch1, r_addr
+	PPC_LCMP	r_scratch1, r_addr
 	blt	bpf_slow_path_word
 	/* Nope, just hitting the header.  cr0 here is eq or gt! */
 #ifdef __LITTLE_ENDIAN__
@@ -52,12 +52,12 @@ sk_load_word_positive_offset:
 
 	.globl	sk_load_half
 sk_load_half:
-	cmpdi	r_addr, 0
+	PPC_LCMPI	r_addr, 0
 	blt	bpf_slow_path_half_neg
 	.globl	sk_load_half_positive_offset
 sk_load_half_positive_offset:
 	subi	r_scratch1, r_HL, 2
-	cmpd	r_scratch1, r_addr
+	PPC_LCMP	r_scratch1, r_addr
 	blt	bpf_slow_path_half
 #ifdef __LITTLE_ENDIAN__
 	lhbrx	r_A, r_D, r_addr
@@ -68,11 +68,11 @@ sk_load_half_positive_offset:
 
 	.globl	sk_load_byte
 sk_load_byte:
-	cmpdi	r_addr, 0
+	PPC_LCMPI	r_addr, 0
 	blt	bpf_slow_path_byte_neg
 	.globl	sk_load_byte_positive_offset
 sk_load_byte_positive_offset:
-	cmpd	r_HL, r_addr
+	PPC_LCMP	r_HL, r_addr
 	ble	bpf_slow_path_byte
 	lbzx	r_A, r_D, r_addr
 	blr
@@ -83,11 +83,11 @@ sk_load_byte_positive_offset:
  */
 	.globl sk_load_byte_msh
 sk_load_byte_msh:
-	cmpdi	r_addr, 0
+	PPC_LCMPI	r_addr, 0
 	blt	bpf_slow_path_byte_msh_neg
 	.globl sk_load_byte_msh_positive_offset
 sk_load_byte_msh_positive_offset:
-	cmpd	r_HL, r_addr
+	PPC_LCMP	r_HL, r_addr
 	ble	bpf_slow_path_byte_msh
 	lbzx	r_X, r_D, r_addr
 	rlwinm	r_X, r_X, 2, 32-4-2, 31-2
@@ -101,13 +101,13 @@ sk_load_byte_msh_positive_offset:
  */
 #define bpf_slow_path_common(SIZE)				\
 	mflr	r0;						\
-	std	r0, 16(r1);					\
+	PPC_STL	r0, PPC_LR_STKOFF(r1);					\
 	/* R3 goes in parameter space of caller's frame */	\
-	std	r_skb, (BPF_PPC_STACKFRAME+48)(r1);		\
-	std	r_A, (BPF_PPC_STACK_BASIC+(0*8))(r1);		\
-	std	r_X, (BPF_PPC_STACK_BASIC+(1*8))(r1);		\
-	addi	r5, r1, BPF_PPC_STACK_BASIC+(2*8);		\
-	stdu	r1, -BPF_PPC_SLOWPATH_FRAME(r1);		\
+	PPC_STL	r_skb, (BPF_PPC_STACKFRAME+BPF_PPC_STACK_R3_OFF)(r1);		\
+	PPC_STL	r_A, (BPF_PPC_STACK_BASIC+(0*REG_SZ))(r1);		\
+	PPC_STL	r_X, (BPF_PPC_STACK_BASIC+(1*REG_SZ))(r1);		\
+	addi	r5, r1, BPF_PPC_STACK_BASIC+(2*REG_SZ);		\
+	PPC_STLU	r1, -BPF_PPC_SLOWPATH_FRAME(r1);		\
 	/* R3 = r_skb, as passed */				\
 	mr	r4, r_addr;					\
 	li	r6, SIZE;					\
@@ -115,19 +115,19 @@ sk_load_byte_msh_positive_offset:
 	nop;							\
 	/* R3 = 0 on success */					\
 	addi	r1, r1, BPF_PPC_SLOWPATH_FRAME;			\
-	ld	r0, 16(r1);					\
-	ld	r_A, (BPF_PPC_STACK_BASIC+(0*8))(r1);		\
-	ld	r_X, (BPF_PPC_STACK_BASIC+(1*8))(r1);		\
+	PPC_LL	r0, PPC_LR_STKOFF(r1);					\
+	PPC_LL	r_A, (BPF_PPC_STACK_BASIC+(0*REG_SZ))(r1);		\
+	PPC_LL	r_X, (BPF_PPC_STACK_BASIC+(1*REG_SZ))(r1);		\
 	mtlr	r0;						\
-	cmpdi	r3, 0;						\
+	PPC_LCMPI	r3, 0;						\
 	blt	bpf_error;	/* cr0 = LT */			\
-	ld	r_skb, (BPF_PPC_STACKFRAME+48)(r1);		\
+	PPC_LL	r_skb, (BPF_PPC_STACKFRAME+BPF_PPC_STACK_R3_OFF)(r1);		\
 	/* Great success! */
 
 bpf_slow_path_word:
 	bpf_slow_path_common(4)
 	/* Data value is on stack, and cr0 != LT */
-	lwz	r_A, BPF_PPC_STACK_BASIC+(2*8)(r1)
+	lwz	r_A, BPF_PPC_STACK_BASIC+(2*REG_SZ)(r1)
 	blr
 
 bpf_slow_path_half:
@@ -154,12 +154,12 @@ bpf_slow_path_byte_msh:
  */
 #define sk_negative_common(SIZE)				\
 	mflr	r0;						\
-	std	r0, 16(r1);					\
+	PPC_STL	r0, PPC_LR_STKOFF(r1);					\
 	/* R3 goes in parameter space of caller's frame */	\
-	std	r_skb, (BPF_PPC_STACKFRAME+48)(r1);		\
-	std	r_A, (BPF_PPC_STACK_BASIC+(0*8))(r1);		\
-	std	r_X, (BPF_PPC_STACK_BASIC+(1*8))(r1);		\
-	stdu	r1, -BPF_PPC_SLOWPATH_FRAME(r1);		\
+	PPC_STL	r_skb, (BPF_PPC_STACKFRAME+BPF_PPC_STACK_R3_OFF)(r1);		\
+	PPC_STL	r_A, (BPF_PPC_STACK_BASIC+(0*REG_SZ))(r1);		\
+	PPC_STL	r_X, (BPF_PPC_STACK_BASIC+(1*REG_SZ))(r1);		\
+	PPC_STLU	r1, -BPF_PPC_SLOWPATH_FRAME(r1);		\
 	/* R3 = r_skb, as passed */				\
 	mr	r4, r_addr;					\
 	li	r5, SIZE;					\
@@ -167,19 +167,19 @@ bpf_slow_path_byte_msh:
 	nop;							\
 	/* R3 != 0 on success */				\
 	addi	r1, r1, BPF_PPC_SLOWPATH_FRAME;			\
-	ld	r0, 16(r1);					\
-	ld	r_A, (BPF_PPC_STACK_BASIC+(0*8))(r1);		\
-	ld	r_X, (BPF_PPC_STACK_BASIC+(1*8))(r1);		\
+	PPC_LL	r0, PPC_LR_STKOFF(r1);					\
+	PPC_LL	r_A, (BPF_PPC_STACK_BASIC+(0*REG_SZ))(r1);		\
+	PPC_LL	r_X, (BPF_PPC_STACK_BASIC+(1*REG_SZ))(r1);		\
 	mtlr	r0;						\
-	cmpldi	r3, 0;						\
+	PPC_LCMPLI	r3, 0;						\
 	beq	bpf_error_slow;	/* cr0 = EQ */			\
 	mr	r_addr, r3;					\
-	ld	r_skb, (BPF_PPC_STACKFRAME+48)(r1);		\
+	PPC_LL	r_skb, (BPF_PPC_STACKFRAME+BPF_PPC_STACK_R3_OFF)(r1);		\
 	/* Great success! */
 
 bpf_slow_path_word_neg:
 	lis     r_scratch1,-32	/* SKF_LL_OFF */
-	cmpd	r_addr, r_scratch1	/* addr < SKF_* */
+	PPC_LCMP	r_addr, r_scratch1	/* addr < SKF_* */
 	blt	bpf_error	/* cr0 = LT */
 	.globl	sk_load_word_negative_offset
 sk_load_word_negative_offset:
@@ -189,7 +189,7 @@ sk_load_word_negative_offset:
 
 bpf_slow_path_half_neg:
 	lis     r_scratch1,-32	/* SKF_LL_OFF */
-	cmpd	r_addr, r_scratch1	/* addr < SKF_* */
+	PPC_LCMP	r_addr, r_scratch1	/* addr < SKF_* */
 	blt	bpf_error	/* cr0 = LT */
 	.globl	sk_load_half_negative_offset
 sk_load_half_negative_offset:
@@ -199,7 +199,7 @@ sk_load_half_negative_offset:
 
 bpf_slow_path_byte_neg:
 	lis     r_scratch1,-32	/* SKF_LL_OFF */
-	cmpd	r_addr, r_scratch1	/* addr < SKF_* */
+	PPC_LCMP	r_addr, r_scratch1	/* addr < SKF_* */
 	blt	bpf_error	/* cr0 = LT */
 	.globl	sk_load_byte_negative_offset
 sk_load_byte_negative_offset:
@@ -209,7 +209,7 @@ sk_load_byte_negative_offset:
 
 bpf_slow_path_byte_msh_neg:
 	lis     r_scratch1,-32	/* SKF_LL_OFF */
-	cmpd	r_addr, r_scratch1	/* addr < SKF_* */
+	PPC_LCMP	r_addr, r_scratch1	/* addr < SKF_* */
 	blt	bpf_error	/* cr0 = LT */
 	.globl	sk_load_byte_msh_negative_offset
 sk_load_byte_msh_negative_offset:
@@ -221,7 +221,7 @@ sk_load_byte_msh_negative_offset:
 bpf_error_slow:
 	/* fabricate a cr0 = lt */
 	li	r_scratch1, -1
-	cmpdi	r_scratch1, 0
+	PPC_LCMPI	r_scratch1, 0
 bpf_error:
 	/* Entered with cr0 = lt */
 	li	r3, 0
diff --git a/arch/powerpc/net/bpf_jit_comp.c b/arch/powerpc/net/bpf_jit_comp.c
index d1916b5..8b29268 100644
--- a/arch/powerpc/net/bpf_jit_comp.c
+++ b/arch/powerpc/net/bpf_jit_comp.c
@@ -1,8 +1,9 @@
-/* bpf_jit_comp.c: BPF JIT compiler for PPC64
+/* bpf_jit_comp.c: BPF JIT compiler
  *
  * Copyright 2011 Matt Evans <matt@ozlabs.org>, IBM Corporation
  *
  * Based on the x86 BPF compiler, by Eric Dumazet (eric.dumazet@gmail.com)
+ * Ported to ppc32 by Denis Kirjanov <kda@linux-powerpc.org>
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License
@@ -36,11 +37,11 @@ static void bpf_jit_build_prologue(struct bpf_prog *fp, u32 *image,
 		if (ctx->seen & SEEN_DATAREF) {
 			/* If we call any helpers (for loads), save LR */
 			EMIT(PPC_INST_MFLR | __PPC_RT(R0));
-			PPC_STD(0, 1, 16);
+			PPC_BPF_STL(0, 1, PPC_LR_STKOFF);
 
 			/* Back up non-volatile regs. */
-			PPC_STD(r_D, 1, -(8*(32-r_D)));
-			PPC_STD(r_HL, 1, -(8*(32-r_HL)));
+			PPC_BPF_STL(r_D, 1, -(REG_SZ*(32-r_D)));
+			PPC_BPF_STL(r_HL, 1, -(REG_SZ*(32-r_HL)));
 		}
 		if (ctx->seen & SEEN_MEM) {
 			/*
@@ -49,11 +50,10 @@ static void bpf_jit_build_prologue(struct bpf_prog *fp, u32 *image,
 			 */
 			for (i = r_M; i < (r_M+16); i++) {
 				if (ctx->seen & (1 << (i-r_M)))
-					PPC_STD(i, 1, -(8*(32-i)));
+					PPC_BPF_STL(i, 1, -(REG_SZ*(32-i)));
 			}
 		}
-		EMIT(PPC_INST_STDU | __PPC_RS(R1) | __PPC_RA(R1) |
-		     (-BPF_PPC_STACKFRAME & 0xfffc));
+		PPC_BPF_STLU(1, 1, -BPF_PPC_STACKFRAME);
 	}
 
 	if (ctx->seen & SEEN_DATAREF) {
@@ -67,7 +67,7 @@ static void bpf_jit_build_prologue(struct bpf_prog *fp, u32 *image,
 							 data_len));
 		PPC_LWZ_OFFS(r_HL, r_skb, offsetof(struct sk_buff, len));
 		PPC_SUB(r_HL, r_HL, r_scratch1);
-		PPC_LD_OFFS(r_D, r_skb, offsetof(struct sk_buff, data));
+		PPC_LL_OFFS(r_D, r_skb, offsetof(struct sk_buff, data));
 	}
 
 	if (ctx->seen & SEEN_XREG) {
@@ -99,16 +99,16 @@ static void bpf_jit_build_epilogue(u32 *image, struct codegen_context *ctx)
 	if (ctx->seen & (SEEN_MEM | SEEN_DATAREF)) {
 		PPC_ADDI(1, 1, BPF_PPC_STACKFRAME);
 		if (ctx->seen & SEEN_DATAREF) {
-			PPC_LD(0, 1, 16);
+			PPC_BPF_LL(0, 1, PPC_LR_STKOFF);
 			PPC_MTLR(0);
-			PPC_LD(r_D, 1, -(8*(32-r_D)));
-			PPC_LD(r_HL, 1, -(8*(32-r_HL)));
+			PPC_BPF_LL(r_D, 1, -(REG_SZ*(32-r_D)));
+			PPC_BPF_LL(r_HL, 1, -(REG_SZ*(32-r_HL)));
 		}
 		if (ctx->seen & SEEN_MEM) {
 			/* Restore any saved non-vol registers */
 			for (i = r_M; i < (r_M+16); i++) {
 				if (ctx->seen & (1 << (i-r_M)))
-					PPC_LD(i, 1, -(8*(32-i)));
+					PPC_BPF_LL(i, 1, -(REG_SZ*(32-i)));
 			}
 		}
 	}
@@ -355,7 +355,7 @@ static int bpf_jit_build_body(struct bpf_prog *fp, u32 *image,
 						ifindex) != 4);
 			BUILD_BUG_ON(FIELD_SIZEOF(struct net_device,
 						type) != 2);
-			PPC_LD_OFFS(r_scratch1, r_skb, offsetof(struct sk_buff,
+			PPC_LL_OFFS(r_scratch1, r_skb, offsetof(struct sk_buff,
 								dev));
 			PPC_CMPDI(r_scratch1, 0);
 			if (ctx->pc_ret0 != -1) {
@@ -437,7 +437,7 @@ static int bpf_jit_build_body(struct bpf_prog *fp, u32 *image,
 		common_load:
 			/* Load from [K]. */
 			ctx->seen |= SEEN_DATAREF;
-			PPC_LI64(r_scratch1, func);
+			PPC_FUNC_ADDR(r_scratch1, func);
 			PPC_MTLR(r_scratch1);
 			PPC_LI32(r_addr, K);
 			PPC_BLRL();
@@ -463,7 +463,7 @@ static int bpf_jit_build_body(struct bpf_prog *fp, u32 *image,
 			 * in the helper functions.
 			 */
 			ctx->seen |= SEEN_DATAREF | SEEN_XREG;
-			PPC_LI64(r_scratch1, func);
+			PPC_FUNC_ADDR(r_scratch1, func);
 			PPC_MTLR(r_scratch1);
 			PPC_ADDI(r_addr, r_X, IMM_L(K));
 			if (K >= 32768)
@@ -685,9 +685,11 @@ void bpf_jit_compile(struct bpf_prog *fp)
 
 	if (image) {
 		bpf_flush_icache(code_base, code_base + (proglen/4));
+#ifdef CONFIG_PPC64
 		/* Function descriptor nastiness: Address + TOC */
 		((u64 *)image)[0] = (u64)code_base;
 		((u64 *)image)[1] = local_paca->kernel_toc;
+#endif
 		fp->bpf_func = (void *)image;
 		fp->jited = true;
 	}
-- 
2.1.3
