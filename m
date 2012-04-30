From: Jan Seiffert <kaffeemonster@googlemail.com>
Subject: [REGRESSION][PATCH V5 3/3] bpf jit: Let the powerpc jit handle negative
 offsets
Date: Mon, 30 Apr 2012 07:02:19 +0200
Message-ID: <4F9E1CDB.9020104@googlemail.com>
References: <4F75CA89.4010709@googlemail.com>  <4F75D2A5.7060407@googlemail.com>  <20120403.180302.342779808900865443.davem@davemloft.net>  <1333491102.3040.12.camel@pasglop> <1335753820.20866.27.camel@pasglop> <1335759088.20866.32.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	David Miller <davem@davemloft.net>, <eric.dumazet@gmail.com>,
	<matt@ozlabs.org>, <linux-kernel@vger.kernel.org>,
	<linuxppc-dev@lists.ozlabs.org>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1335759088.20866.32.camel@pasglop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now the helper function from filter.c for negative offsets is exported,
it can be used it in the jit to handle negative offsets.

First modify the asm load helper functions to handle:
- know positive offsets
- know negative offsets
- any offset

then the compiler can be modified to explicitly use these helper
when appropriate.

This fixes the case of a negative X register and allows to lift
the restriction that bpf programs with negative offsets can't
be jited.

Tested-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Signed-off-by: Jan Seiffert <kaffeemonster@googlemail.com>
---
 arch/powerpc/net/bpf_jit.h      |    8 +++-
 arch/powerpc/net/bpf_jit_64.S   |  108 ++++++++++++++++++++++++++++++++++-----
 arch/powerpc/net/bpf_jit_comp.c |   26 +++------
 3 files changed, 111 insertions(+), 31 deletions(-)

diff --git a/arch/powerpc/net/bpf_jit.h b/arch/powerpc/net/bpf_jit.h
index af1ab5e..5c3cf2d 100644
--- a/arch/powerpc/net/bpf_jit.h
+++ b/arch/powerpc/net/bpf_jit.h
@@ -48,7 +48,13 @@
 /*
  * Assembly helpers from arch/powerpc/net/bpf_jit.S:
  */
-extern u8 sk_load_word[], sk_load_half[], sk_load_byte[], sk_load_byte_msh[];
+#define DECLARE_LOAD_FUNC(func)	\
+	extern u8 func[], func##_negative_offset[], func##_positive_offset[]
+
+DECLARE_LOAD_FUNC(sk_load_word);
+DECLARE_LOAD_FUNC(sk_load_half);
+DECLARE_LOAD_FUNC(sk_load_byte);
+DECLARE_LOAD_FUNC(sk_load_byte_msh);
 
 #define FUNCTION_DESCR_SIZE	24
 
diff --git a/arch/powerpc/net/bpf_jit_64.S b/arch/powerpc/net/bpf_jit_64.S
index ff4506e..55ba385 100644
--- a/arch/powerpc/net/bpf_jit_64.S
+++ b/arch/powerpc/net/bpf_jit_64.S
@@ -31,14 +31,13 @@
  * then branch directly to slow_path_XXX if required.  (In fact, could
  * load a spare GPR with the address of slow_path_generic and pass size
  * as an argument, making the call site a mtlr, li and bllr.)
- *
- * Technically, the "is addr < 0" check is unnecessary & slowing down
- * the ABS path, as it's statically checked on generation.
  */
 	.globl	sk_load_word
 sk_load_word:
 	cmpdi	r_addr, 0
-	blt	bpf_error
+	blt	bpf_slow_path_word_neg
+	.globl	sk_load_word_positive_offset
+sk_load_word_positive_offset:
 	/* Are we accessing past headlen? */
 	subi	r_scratch1, r_HL, 4
 	cmpd	r_scratch1, r_addr
@@ -51,7 +50,9 @@ sk_load_word:
 	.globl	sk_load_half
 sk_load_half:
 	cmpdi	r_addr, 0
-	blt	bpf_error
+	blt	bpf_slow_path_half_neg
+	.globl	sk_load_half_positive_offset
+sk_load_half_positive_offset:
 	subi	r_scratch1, r_HL, 2
 	cmpd	r_scratch1, r_addr
 	blt	bpf_slow_path_half
@@ -61,7 +62,9 @@ sk_load_half:
 	.globl	sk_load_byte
 sk_load_byte:
 	cmpdi	r_addr, 0
-	blt	bpf_error
+	blt	bpf_slow_path_byte_neg
+	.globl	sk_load_byte_positive_offset
+sk_load_byte_positive_offset:
 	cmpd	r_HL, r_addr
 	ble	bpf_slow_path_byte
 	lbzx	r_A, r_D, r_addr
@@ -69,22 +72,20 @@ sk_load_byte:
 
 /*
  * BPF_S_LDX_B_MSH: ldxb  4*([offset]&0xf)
- * r_addr is the offset value, already known positive
+ * r_addr is the offset value
  */
 	.globl sk_load_byte_msh
 sk_load_byte_msh:
+	cmpdi	r_addr, 0
+	blt	bpf_slow_path_byte_msh_neg
+	.globl sk_load_byte_msh_positive_offset
+sk_load_byte_msh_positive_offset:
 	cmpd	r_HL, r_addr
 	ble	bpf_slow_path_byte_msh
 	lbzx	r_X, r_D, r_addr
 	rlwinm	r_X, r_X, 2, 32-4-2, 31-2
 	blr
 
-bpf_error:
-	/* Entered with cr0 = lt */
-	li	r3, 0
-	/* Generated code will 'blt epilogue', returning 0. */
-	blr
-
 /* Call out to skb_copy_bits:
  * We'll need to back up our volatile regs first; we have
  * local variable space at r1+(BPF_PPC_STACK_BASIC).
@@ -136,3 +137,84 @@ bpf_slow_path_byte_msh:
 	lbz	r_X, BPF_PPC_STACK_BASIC+(2*8)(r1)
 	rlwinm	r_X, r_X, 2, 32-4-2, 31-2
 	blr
+
+/* Call out to bpf_internal_load_pointer_neg_helper:
+ * We'll need to back up our volatile regs first; we have
+ * local variable space at r1+(BPF_PPC_STACK_BASIC).
+ * Allocate a new stack frame here to remain ABI-compliant in
+ * stashing LR.
+ */
+#define sk_negative_common(SIZE)				\
+	mflr	r0;						\
+	std	r0, 16(r1);					\
+	/* R3 goes in parameter space of caller's frame */	\
+	std	r_skb, (BPF_PPC_STACKFRAME+48)(r1);		\
+	std	r_A, (BPF_PPC_STACK_BASIC+(0*8))(r1);		\
+	std	r_X, (BPF_PPC_STACK_BASIC+(1*8))(r1);		\
+	stdu	r1, -BPF_PPC_SLOWPATH_FRAME(r1);		\
+	/* R3 = r_skb, as passed */				\
+	mr	r4, r_addr;					\
+	li	r5, SIZE;					\
+	bl	bpf_internal_load_pointer_neg_helper;		\
+	/* R3 != 0 on success */				\
+	addi	r1, r1, BPF_PPC_SLOWPATH_FRAME;			\
+	ld	r0, 16(r1);					\
+	ld	r_A, (BPF_PPC_STACK_BASIC+(0*8))(r1);		\
+	ld	r_X, (BPF_PPC_STACK_BASIC+(1*8))(r1);		\
+	mtlr	r0;						\
+	cmpldi	r3, 0;						\
+	beq	bpf_error_slow;	/* cr0 = EQ */			\
+	mr	r_addr, r3;					\
+	ld	r_skb, (BPF_PPC_STACKFRAME+48)(r1);		\
+	/* Great success! */
+
+bpf_slow_path_word_neg:
+	lis     r_scratch1,-32	/* SKF_LL_OFF */
+	cmpd	r_addr, r_scratch1	/* addr < SKF_* */
+	blt	bpf_error	/* cr0 = LT */
+	.globl	sk_load_word_negative_offset
+sk_load_word_negative_offset:
+	sk_negative_common(4)
+	lwz	r_A, 0(r_addr)
+	blr
+
+bpf_slow_path_half_neg:
+	lis     r_scratch1,-32	/* SKF_LL_OFF */
+	cmpd	r_addr, r_scratch1	/* addr < SKF_* */
+	blt	bpf_error	/* cr0 = LT */
+	.globl	sk_load_half_negative_offset
+sk_load_half_negative_offset:
+	sk_negative_common(2)
+	lhz	r_A, 0(r_addr)
+	blr
+
+bpf_slow_path_byte_neg:
+	lis     r_scratch1,-32	/* SKF_LL_OFF */
+	cmpd	r_addr, r_scratch1	/* addr < SKF_* */
+	blt	bpf_error	/* cr0 = LT */
+	.globl	sk_load_byte_negative_offset
+sk_load_byte_negative_offset:
+	sk_negative_common(1)
+	lbz	r_A, 0(r_addr)
+	blr
+
+bpf_slow_path_byte_msh_neg:
+	lis     r_scratch1,-32	/* SKF_LL_OFF */
+	cmpd	r_addr, r_scratch1	/* addr < SKF_* */
+	blt	bpf_error	/* cr0 = LT */
+	.globl	sk_load_byte_msh_negative_offset
+sk_load_byte_msh_negative_offset:
+	sk_negative_common(1)
+	lbz	r_X, 0(r_addr)
+	rlwinm	r_X, r_X, 2, 32-4-2, 31-2
+	blr
+
+bpf_error_slow:
+	/* fabricate a cr0 = lt */
+	li	r_scratch1, -1
+	cmpdi	r_scratch1, 0
+bpf_error:
+	/* Entered with cr0 = lt */
+	li	r3, 0
+	/* Generated code will 'blt epilogue', returning 0. */
+	blr
diff --git a/arch/powerpc/net/bpf_jit_comp.c b/arch/powerpc/net/bpf_jit_comp.c
index 73619d3..2dc8b14 100644
--- a/arch/powerpc/net/bpf_jit_comp.c
+++ b/arch/powerpc/net/bpf_jit_comp.c
@@ -127,6 +127,9 @@ static void bpf_jit_build_epilogue(u32 *image, struct codegen_context *ctx)
 	PPC_BLR();
 }
 
+#define CHOOSE_LOAD_FUNC(K, func) \
+	((int)K < 0 ? ((int)K >= SKF_LL_OFF ? func##_negative_offset : func) : func##_positive_offset)
+
 /* Assemble the body code between the prologue & epilogue. */
 static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
 			      struct codegen_context *ctx,
@@ -391,21 +394,16 @@ static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
 
 			/*** Absolute loads from packet header/data ***/
 		case BPF_S_LD_W_ABS:
-			func = sk_load_word;
+			func = CHOOSE_LOAD_FUNC(K, sk_load_word);
 			goto common_load;
 		case BPF_S_LD_H_ABS:
-			func = sk_load_half;
+			func = CHOOSE_LOAD_FUNC(K, sk_load_half);
 			goto common_load;
 		case BPF_S_LD_B_ABS:
-			func = sk_load_byte;
+			func = CHOOSE_LOAD_FUNC(K, sk_load_byte);
 		common_load:
-			/*
-			 * Load from [K].  Reference with the (negative)
-			 * SKF_NET_OFF/SKF_LL_OFF offsets is unsupported.
-			 */
+			/* Load from [K]. */
 			ctx->seen |= SEEN_DATAREF;
-			if ((int)K < 0)
-				return -ENOTSUPP;
 			PPC_LI64(r_scratch1, func);
 			PPC_MTLR(r_scratch1);
 			PPC_LI32(r_addr, K);
@@ -429,7 +427,7 @@ static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
 		common_load_ind:
 			/*
 			 * Load from [X + K].  Negative offsets are tested for
-			 * in the helper functions, and result in a 'ret 0'.
+			 * in the helper functions.
 			 */
 			ctx->seen |= SEEN_DATAREF | SEEN_XREG;
 			PPC_LI64(r_scratch1, func);
@@ -443,13 +441,7 @@ static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
 			break;
 
 		case BPF_S_LDX_B_MSH:
-			/*
-			 * x86 version drops packet (RET 0) when K<0, whereas
-			 * interpreter does allow K<0 (__load_pointer, special
-			 * ancillary data).  common_load returns ENOTSUPP if K<0,
-			 * so we fall back to interpreter & filter works.
-			 */
-			func = sk_load_byte_msh;
+			func = CHOOSE_LOAD_FUNC(K, sk_load_byte_msh);
 			goto common_load;
 			break;
 
