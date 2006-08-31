From: Paul Mackerras <paulus@samba.org>
Subject: Re: IPSec kernel oops on ppc64
Date: Thu, 31 Aug 2006 13:22:07 +1000
Message-ID: <17654.21983.691176.397891@cargo.ozlabs.ibm.com>
References: <200608301636.k7UGaQY5002569@faith.austin.ibm.com>
	<20060831015942.GA27423@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Joy Latten <latten@austin.ibm.com>, jmorris@redhat.com,
	netdev@vger.kernel.org, anton@au1.ibm.com, linuxppc-dev@ozlabs.org,
	gcwilson@us.ibm.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:1749 "EHLO ozlabs.org")
	by vger.kernel.org with ESMTP id S1750801AbWHaDtr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2006 23:49:47 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060831015942.GA27423@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu writes:

> Interesting.  We were previously off by 28 bytes, now we're off by 8 :)

You missed a couple of 'beqlr' instructions (branch if equal to LR).
I'd be interested to know if it still fails with the patch below.

Thanks,
Paul.

diff --git a/arch/powerpc/lib/memcpy_64.S b/arch/powerpc/lib/memcpy_64.S
index fd66acf..7173ba9 100644
--- a/arch/powerpc/lib/memcpy_64.S
+++ b/arch/powerpc/lib/memcpy_64.S
@@ -11,6 +11,7 @@ #include <asm/ppc_asm.h>
 
 	.align	7
 _GLOBAL(memcpy)
+	std	r3,48(r1)	/* save destination pointer for return value */
 	mtcrf	0x01,r5
 	cmpldi	cr1,r5,16
 	neg	r6,r3		# LS 3 bits = # bytes to 8-byte dest bdry
@@ -38,7 +39,7 @@ _GLOBAL(memcpy)
 	stdu	r9,16(r3)
 	bdnz	1b
 3:	std	r8,8(r3)
-	beqlr
+	beq	3f
 	addi	r3,r3,16
 	ld	r9,8(r4)
 .Ldo_tail:
@@ -53,7 +54,8 @@ _GLOBAL(memcpy)
 2:	bf	cr7*4+3,3f
 	rotldi	r9,r9,8
 	stb	r9,0(r3)
-3:	blr
+3:	ld	r3,48(r1)	/* return dest pointer */
+	blr
 
 .Lsrc_unaligned:
 	srdi	r6,r5,3
@@ -115,7 +117,7 @@ _GLOBAL(memcpy)
 5:	srd	r12,r9,r11
 	or	r12,r8,r12
 	std	r12,24(r3)
-	beqlr
+	beq	4f
 	cmpwi	cr1,r5,8
 	addi	r3,r3,32
 	sld	r9,r9,r10
@@ -167,4 +169,5 @@ _GLOBAL(memcpy)
 3:	bf	cr7*4+3,4f
 	lbz	r0,0(r4)
 	stb	r0,0(r3)
-4:	blr
+4:	ld	r3,48(r1)	/* return dest pointer */
+	blr
