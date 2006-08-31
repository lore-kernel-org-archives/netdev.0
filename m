From: Joy Latten <latten@austin.ibm.com>
Subject: Re: IPSec kernel oops on ppc64
Date: Thu, 31 Aug 2006 09:55:58 -0500
Message-ID: <200608311455.k7VEtwUI011729@faith.austin.ibm.com>
Cc: anton@au1.ibm.com, davem@davemloft.net, gcwilson@us.ibm.com,
	herbert@gondor.apana.org.au, jmorris@redhat.com,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:41128 "EHLO
	e33.co.us.ibm.com") by vger.kernel.org with ESMTP id S932342AbWHaPHR
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 11:07:17 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k7VF7GpO001499
	for <netdev@vger.kernel.org>; Thu, 31 Aug 2006 11:07:16 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7VF7G39065700
	for <netdev@vger.kernel.org>; Thu, 31 Aug 2006 09:07:16 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7VF7FKK003771
	for <netdev@vger.kernel.org>; Thu, 31 Aug 2006 09:07:16 -0600
To: paulus@samba.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It works! I applied the patch to 
linux-2.6.17 + patch-2.6.17-rc1
and tried icmp, tcp and udp as well as sftp with 
ipsec and they all worked. 

Thanks!!!!

Regards,
Joy

>Herbert Xu writes:
>
>> Interesting.  We were previously off by 28 bytes, now we're off by 8 :)
>
>You missed a couple of 'beqlr' instructions (branch if equal to LR).
>I'd be interested to know if it still fails with the patch below.
>
>Thanks,
>Paul.
>
>diff --git a/arch/powerpc/lib/memcpy_64.S b/arch/powerpc/lib/memcpy_64.S
>index fd66acf..7173ba9 100644
>--- a/arch/powerpc/lib/memcpy_64.S
>+++ b/arch/powerpc/lib/memcpy_64.S
>@@ -11,6 +11,7 @@ #include <asm/ppc_asm.h>
> 
> 	.align	7
> _GLOBAL(memcpy)
>+	std	r3,48(r1)	/* save destination pointer for return value */
> 	mtcrf	0x01,r5
> 	cmpldi	cr1,r5,16
> 	neg	r6,r3		# LS 3 bits = # bytes to 8-byte dest bdry
>@@ -38,7 +39,7 @@ _GLOBAL(memcpy)
> 	stdu	r9,16(r3)
> 	bdnz	1b
> 3:	std	r8,8(r3)
>-	beqlr
>+	beq	3f
> 	addi	r3,r3,16
> 	ld	r9,8(r4)
> .Ldo_tail:
>@@ -53,7 +54,8 @@ _GLOBAL(memcpy)
> 2:	bf	cr7*4+3,3f
> 	rotldi	r9,r9,8
> 	stb	r9,0(r3)
>-3:	blr
>+3:	ld	r3,48(r1)	/* return dest pointer */
>+	blr
> 
> .Lsrc_unaligned:
> 	srdi	r6,r5,3
>@@ -115,7 +117,7 @@ _GLOBAL(memcpy)
> 5:	srd	r12,r9,r11
> 	or	r12,r8,r12
> 	std	r12,24(r3)
>-	beqlr
>+	beq	4f
> 	cmpwi	cr1,r5,8
> 	addi	r3,r3,32
> 	sld	r9,r9,r10
>@@ -167,4 +169,5 @@ _GLOBAL(memcpy)
> 3:	bf	cr7*4+3,4f
> 	lbz	r0,0(r4)
> 	stb	r0,0(r3)
>-4:	blr
>+4:	ld	r3,48(r1)	/* return dest pointer */
>+	blr
