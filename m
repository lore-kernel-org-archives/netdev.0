From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPSec kernel oops on ppc64
Date: Wed, 30 Aug 2006 21:09:20 +1000
Message-ID: <20060830110920.GA19926@gondor.apana.org.au>
References: <200608282225.k7SMPF80022173@faith.austin.ibm.com> <20060829013023.GA5865@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, gcwilson@us.ibm.com, jmorris@redhat.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:23059 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750707AbWH3LJs
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Aug 2006 07:09:48 -0400
To: Joy Latten <latten@austin.ibm.com>, paulus@au.ibm.com,
	anton@au.ibm.com, linuxppc-dev@ozlabs.org
Content-Disposition: inline
In-Reply-To: <20060829013023.GA5865@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi:

Thanks to some excellent info from Joy, I've trakced the problem down to
a broken implementation of memmove on ppc64, which in turn is due to a
broken memcpy.

Both memmove and memcpy need to return the destination pointer as per
the C standard.  The ppc64 version of memcpy returns a pointer to the
last byte copied instead.  Since memmove degenerates into memcpy in
some cases, this makes it broken as well.

Something like the following patch should fix the problem.  Be warned
that I know absolutely nothing about ppc assembly so don't come back
to me if this patch eats your disk :)

BTW, I spotted a couple of typos in memcpy_64.S/copyuser_64.S where
"cmpldi cr1,..." became "cmpldi r1,...".  So please fix that up while
you ppc64 guys are at it.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/arch/powerpc/lib/memcpy_64.S b/arch/powerpc/lib/memcpy_64.S
index fd66acf..9e8d9e7 100644
--- a/arch/powerpc/lib/memcpy_64.S
+++ b/arch/powerpc/lib/memcpy_64.S
@@ -11,6 +11,7 @@ #include <asm/ppc_asm.h>
 
 	.align	7
 _GLOBAL(memcpy)
+	std	r3,-8(r1)
 	mtcrf	0x01,r5
 	cmpldi	cr1,r5,16
 	neg	r6,r3		# LS 3 bits = # bytes to 8-byte dest bdry
@@ -53,7 +54,8 @@ _GLOBAL(memcpy)
 2:	bf	cr7*4+3,3f
 	rotldi	r9,r9,8
 	stb	r9,0(r3)
-3:	blr
+3:	ld	r3,-8(r1)
+	blr
 
 .Lsrc_unaligned:
 	srdi	r6,r5,3
@@ -167,4 +169,5 @@ _GLOBAL(memcpy)
 3:	bf	cr7*4+3,4f
 	lbz	r0,0(r4)
 	stb	r0,0(r3)
-4:	blr
+4:	ld	r3,-8(r1)
+	blr
