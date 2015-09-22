From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH 5/9] powerpc32: rewrite csum_partial_copy_generic() based on
 copy_tofrom_user()
Date: Tue, 22 Sep 2015 16:34:27 +0200 (CEST)
Message-ID: <bdc0db5e47033d8cfc672160924f0d4d4efe721f.1442876807.git.christophe.leroy@c-s.fr>
References: <cover.1442876807.git.christophe.leroy@c-s.fr>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>, scottwood@freescale.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1442876807.git.christophe.leroy@c-s.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

csum_partial_copy_generic() does the same as copy_tofrom_user and also
calculates the checksum during the copy. Unlike copy_tofrom_user(),
the existing version of csum_partial_copy_generic() doesn't take
benefit of the cache.

This patch is a rewrite of csum_partial_copy_generic() based on
copy_tofrom_user().
The previous version of csum_partial_copy_generic() was handling
errors. Now we have the checksum wrapper functions to handle the error
case like in powerpc64 so we can make the error case simple:
just return -EFAULT.
copy_tofrom_user() only has r12 available => we use it for the
checksum r7 and r8 which contains pointers to error feedback are used,
so we stack them.

On a TCP benchmark using socklib on the loopback interface on which
checksum offload and scatter/gather have been deactivated, we get
about 20% performance increase.

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 arch/powerpc/lib/checksum_32.S | 320 +++++++++++++++++++++++++++--------------
 1 file changed, 209 insertions(+), 111 deletions(-)

diff --git a/arch/powerpc/lib/checksum_32.S b/arch/powerpc/lib/checksum_32.S
index 0d7eba3..3472372 100644
--- a/arch/powerpc/lib/checksum_32.S
+++ b/arch/powerpc/lib/checksum_32.S
@@ -14,6 +14,7 @@
 
 #include <linux/sys.h>
 #include <asm/processor.h>
+#include <asm/cache.h>
 #include <asm/errno.h>
 #include <asm/ppc_asm.h>
 
@@ -66,123 +67,220 @@ _GLOBAL(csum_partial)
  *
  * csum_partial_copy_generic(src, dst, len, sum, src_err, dst_err)
  */
+#define CSUM_COPY_16_BYTES_WITHEX(n)	\
+8 ## n ## 0:			\
+	lwz	r7,4(r4);	\
+8 ## n ## 1:			\
+	lwz	r8,8(r4);	\
+8 ## n ## 2:			\
+	lwz	r9,12(r4);	\
+8 ## n ## 3:			\
+	lwzu	r10,16(r4);	\
+8 ## n ## 4:			\
+	stw	r7,4(r6);	\
+	adde	r12,r12,r7;	\
+8 ## n ## 5:			\
+	stw	r8,8(r6);	\
+	adde	r12,r12,r8;	\
+8 ## n ## 6:			\
+	stw	r9,12(r6);	\
+	adde	r12,r12,r9;	\
+8 ## n ## 7:			\
+	stwu	r10,16(r6);	\
+	adde	r12,r12,r10
+
+#define CSUM_COPY_16_BYTES_EXCODE(n)		\
+.section __ex_table,"a";		\
+	.align	2;			\
+	.long	8 ## n ## 0b,src_error;	\
+	.long	8 ## n ## 1b,src_error;	\
+	.long	8 ## n ## 2b,src_error;	\
+	.long	8 ## n ## 3b,src_error;	\
+	.long	8 ## n ## 4b,dst_error;	\
+	.long	8 ## n ## 5b,dst_error;	\
+	.long	8 ## n ## 6b,dst_error;	\
+	.long	8 ## n ## 7b,dst_error;	\
+	.text
+
+	.text
+	.stabs	"arch/powerpc/lib/",N_SO,0,0,0f
+	.stabs	"checksum_32.S",N_SO,0,0,0f
+0:
+
+CACHELINE_BYTES = L1_CACHE_BYTES
+LG_CACHELINE_BYTES = L1_CACHE_SHIFT
+CACHELINE_MASK = (L1_CACHE_BYTES-1)
+
 _GLOBAL(csum_partial_copy_generic)
-	addic	r0,r6,0
-	subi	r3,r3,4
-	subi	r4,r4,4
-	srwi.	r6,r5,2
-	beq	3f		/* if we're doing < 4 bytes */
-	andi.	r9,r4,2		/* Align dst to longword boundary */
-	beq+	1f
-81:	lhz	r6,4(r3)	/* do 2 bytes to get aligned */
-	addi	r3,r3,2
-	subi	r5,r5,2
-91:	sth	r6,4(r4)
-	addi	r4,r4,2
-	addc	r0,r0,r6
-	srwi.	r6,r5,2		/* # words to do */
-	beq	3f
-1:	srwi.	r6,r5,4		/* # groups of 4 words to do */
-	beq	10f
-	mtctr	r6
-71:	lwz	r6,4(r3)
-72:	lwz	r9,8(r3)
-73:	lwz	r10,12(r3)
-74:	lwzu	r11,16(r3)
-	adde	r0,r0,r6
-75:	stw	r6,4(r4)
-	adde	r0,r0,r9
-76:	stw	r9,8(r4)
-	adde	r0,r0,r10
-77:	stw	r10,12(r4)
-	adde	r0,r0,r11
-78:	stwu	r11,16(r4)
-	bdnz	71b
-10:	rlwinm.	r6,r5,30,30,31	/* # words left to do */
-	beq	13f
-	mtctr	r6
-82:	lwzu	r9,4(r3)
-92:	stwu	r9,4(r4)
-	adde	r0,r0,r9
-	bdnz	82b
-13:	andi.	r5,r5,3
-3:	cmpwi	0,r5,2
-	blt+	4f
-83:	lhz	r6,4(r3)
-	addi	r3,r3,2
-	subi	r5,r5,2
-93:	sth	r6,4(r4)
+	stwu	r1,-16(r1)
+	stw	r7,12(r1)
+	stw	r8,8(r1)
+
+	andi.	r0,r4,1			/* is destination address even ? */
+	cmplwi	cr7,r0,0
+	addic	r12,r6,0
+	addi	r6,r4,-4
+	neg	r0,r4
+	addi	r4,r3,-4
+	andi.	r0,r0,CACHELINE_MASK	/* # bytes to start of cache line */
+	beq	58f
+
+	cmplw	0,r5,r0			/* is this more than total to do? */
+	blt	63f			/* if not much to do */
+	andi.	r8,r0,3			/* get it word-aligned first */
+	mtctr	r8
+	beq+	61f
+	li	r3,0
+70:	lbz	r9,4(r4)		/* do some bytes */
+	addi	r4,r4,1
+	slwi	r3,r3,8
+	rlwimi	r3,r9,0,24,31
+71:	stb	r9,4(r6)
+	addi	r6,r6,1
+	bdnz	70b
+	adde	r12,r12,r3
+61:	subf	r5,r0,r5
+	srwi.	r0,r0,2
+	mtctr	r0
+	beq	58f
+72:	lwzu	r9,4(r4)		/* do some words */
+	adde	r12,r12,r9
+73:	stwu	r9,4(r6)
+	bdnz	72b
+
+58:	srwi.	r0,r5,LG_CACHELINE_BYTES /* # complete cachelines */
+	clrlwi	r5,r5,32-LG_CACHELINE_BYTES
+	li	r11,4
+	beq	63f
+
+	/* Here we decide how far ahead to prefetch the source */
+	li	r3,4
+	cmpwi	r0,1
+	li	r7,0
+	ble	114f
+	li	r7,1
+#if MAX_COPY_PREFETCH > 1
+	/* Heuristically, for large transfers we prefetch
+	   MAX_COPY_PREFETCH cachelines ahead.  For small transfers
+	   we prefetch 1 cacheline ahead. */
+	cmpwi	r0,MAX_COPY_PREFETCH
+	ble	112f
+	li	r7,MAX_COPY_PREFETCH
+112:	mtctr	r7
+111:	dcbt	r3,r4
+	addi	r3,r3,CACHELINE_BYTES
+	bdnz	111b
+#else
+	dcbt	r3,r4
+	addi	r3,r3,CACHELINE_BYTES
+#endif /* MAX_COPY_PREFETCH > 1 */
+
+114:	subf	r8,r7,r0
+	mr	r0,r7
+	mtctr	r8
+
+53:	dcbt	r3,r4
+54:	dcbz	r11,r6
+/* the main body of the cacheline loop */
+	CSUM_COPY_16_BYTES_WITHEX(0)
+#if L1_CACHE_BYTES >= 32
+	CSUM_COPY_16_BYTES_WITHEX(1)
+#if L1_CACHE_BYTES >= 64
+	CSUM_COPY_16_BYTES_WITHEX(2)
+	CSUM_COPY_16_BYTES_WITHEX(3)
+#if L1_CACHE_BYTES >= 128
+	CSUM_COPY_16_BYTES_WITHEX(4)
+	CSUM_COPY_16_BYTES_WITHEX(5)
+	CSUM_COPY_16_BYTES_WITHEX(6)
+	CSUM_COPY_16_BYTES_WITHEX(7)
+#endif
+#endif
+#endif
+	bdnz	53b
+	cmpwi	r0,0
+	li	r3,4
+	li	r7,0
+	bne	114b
+
+63:	srwi.	r0,r5,2
+	mtctr	r0
+	beq	64f
+30:	lwzu	r0,4(r4)
+	adde	r12,r12,r0
+31:	stwu	r0,4(r6)
+	bdnz	30b
+
+64:	andi.	r0,r5,2
+	beq+	65f
+40:	lhz	r0,4(r4)
 	addi	r4,r4,2
-	adde	r0,r0,r6
-4:	cmpwi	0,r5,1
-	bne+	5f
-84:	lbz	r6,4(r3)
-94:	stb	r6,4(r4)
-	slwi	r6,r6,8		/* Upper byte of word */
-	adde	r0,r0,r6
-5:	addze	r3,r0		/* add in final carry */
+41:	sth	r0,4(r6)
+	adde	r12,r12,r0
+	addi	r6,r6,2
+65:	andi.	r0,r5,1
+	beq+	66f
+50:	lbz	r0,4(r4)
+51:	stb	r0,4(r6)
+	slwi	r0,r0,8
+	adde	r12,r12,r0
+66:	addze	r3,r12
+	addi	r1,r1,16
+	beqlr+	cr7
+	rlwinm	r3,r3,8,0,31	/* swap bytes for odd destination */
 	blr
 
-/* These shouldn't go in the fixup section, since that would
-   cause the ex_table addresses to get out of order. */
-
-src_error_4:
-	mfctr	r6		/* update # bytes remaining from ctr */
-	rlwimi	r5,r6,4,0,27
-	b	79f
-src_error_1:
-	li	r6,0
-	subi	r5,r5,2
-95:	sth	r6,4(r4)
-	addi	r4,r4,2
-79:	srwi.	r6,r5,2
-	beq	3f
-	mtctr	r6
-src_error_2:
-	li	r6,0
-96:	stwu	r6,4(r4)
-	bdnz	96b
-3:	andi.	r5,r5,3
-	beq	src_error
-src_error_3:
-	li	r6,0
-	mtctr	r5
-	addi	r4,r4,3
-97:	stbu	r6,1(r4)
-	bdnz	97b
+/* read fault */
 src_error:
-	cmpwi	0,r7,0
-	beq	1f
-	li	r6,-EFAULT
-	stw	r6,0(r7)
-1:	addze	r3,r0
+	lwz	r7,12(r1)
+	addi	r1,r1,16
+	cmpwi	cr0,r7,0
+	beqlr
+	li	r0,-EFAULT
+	stw	r0,0(r7)
 	blr
-
+/* write fault */
 dst_error:
-	cmpwi	0,r8,0
-	beq	1f
-	li	r6,-EFAULT
-	stw	r6,0(r8)
-1:	addze	r3,r0
+	lwz	r8,8(r1)
+	addi	r1,r1,16
+	cmpwi	cr0,r8,0
+	beqlr
+	li	r0,-EFAULT
+	stw	r0,0(r8)
 	blr
 
-.section __ex_table,"a"
-	.long	81b,src_error_1
-	.long	91b,dst_error
-	.long	71b,src_error_4
-	.long	72b,src_error_4
-	.long	73b,src_error_4
-	.long	74b,src_error_4
-	.long	75b,dst_error
-	.long	76b,dst_error
-	.long	77b,dst_error
-	.long	78b,dst_error
-	.long	82b,src_error_2
-	.long	92b,dst_error
-	.long	83b,src_error_3
-	.long	93b,dst_error
-	.long	84b,src_error_3
-	.long	94b,dst_error
-	.long	95b,dst_error
-	.long	96b,dst_error
-	.long	97b,dst_error
+	.section __ex_table,"a"
+	.align	2
+	.long	70b,src_error
+	.long	71b,dst_error
+	.long	72b,src_error
+	.long	73b,dst_error
+	.long	54b,dst_error
+	.text
+
+/*
+ * this stuff handles faults in the cacheline loop and branches to either
+ * src_error (if in read part) or dst_error (if in write part)
+ */
+	CSUM_COPY_16_BYTES_EXCODE(0)
+#if L1_CACHE_BYTES >= 32
+	CSUM_COPY_16_BYTES_EXCODE(1)
+#if L1_CACHE_BYTES >= 64
+	CSUM_COPY_16_BYTES_EXCODE(2)
+	CSUM_COPY_16_BYTES_EXCODE(3)
+#if L1_CACHE_BYTES >= 128
+	CSUM_COPY_16_BYTES_EXCODE(4)
+	CSUM_COPY_16_BYTES_EXCODE(5)
+	CSUM_COPY_16_BYTES_EXCODE(6)
+	CSUM_COPY_16_BYTES_EXCODE(7)
+#endif
+#endif
+#endif
+
+	.section __ex_table,"a"
+	.align	2
+	.long	30b,src_error
+	.long	31b,dst_error
+	.long	40b,src_error
+	.long	41b,dst_error
+	.long	50b,src_error
+	.long	51b,dst_error
-- 
2.1.0
