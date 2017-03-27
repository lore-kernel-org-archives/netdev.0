From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH v2] xfrm: branchless addr4_match() on 64-bit
Date: Mon, 27 Mar 2017 12:37:19 +0200
Message-ID: <20170327103719.GI23004@secunet.com>
References: <20170323233247.GE31372@avx2>
 <063D6719AE5E284EB5DD2968C1650D6DCFFB93A8@AcuExch.aculab.com>
 <20170325163712.GA4950@avx2>
 <20170325164117.GB4950@avx2>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        <David.Laight@ACULAB.COM>
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:39998 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751989AbdC0Kix (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 27 Mar 2017 06:38:53 -0400
Content-Disposition: inline
In-Reply-To: <20170325164117.GB4950@avx2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 25, 2017 at 07:41:17PM +0300, Alexey Dobriyan wrote:
> Current addr4_match() code has special test for /0 prefixes because of
> standard required undefined behaviour. However, it is possible to omit
> it on 64-bit because shifting can be done within a 64-bit register and
> then truncated to the expected value (which is 0 mask).
> 
> Implicit truncation by htonl() fits nicely into R32-within-R64 model
> on x86-64.
> 
> Space savings: none (coincidence)
> Branch savings: 1
> 
> Before:
> 
> 	movzx  eax,BYTE PTR [rdi+0x2a]		# ->prefixlen_d
> 	test   al,al
> 	jne    xfrm_selector_match + 0x23f
> 		...
> 	movzx  eax,BYTE PTR [rbx+0x2b]		# ->prefixlen_s
> 	test   al,al
> 	je     xfrm_selector_match + 0x1c7
> 
> After (no branches):
> 
> 	mov    r8d,0x20
> 	mov    rdx,0xffffffffffffffff
> 	mov    esi,DWORD PTR [rsi+0x2c]
> 	mov    ecx,r8d
> 	sub    cl,BYTE PTR [rdi+0x2a]
> 	xor    esi,DWORD PTR [rbx]
> 	mov    rdi,rdx
> 	xor    eax,eax
> 	shl    rdi,cl
> 	bswap  edi
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Also applied to ipsec-next, thanks for the patches Alexey!
