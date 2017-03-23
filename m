From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] xfrm: branchless addr4_match() on 64-bit
Date: Fri, 24 Mar 2017 02:32:47 +0300
Message-ID: <20170323233247.GE31372@avx2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, davem@davemloft.net,
        netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:35188 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756620AbdCWXcw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 19:32:52 -0400
Received: by mail-lf0-f67.google.com with SMTP id v2so18429242lfi.2
        for <netdev@vger.kernel.org>; Thu, 23 Mar 2017 16:32:51 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current addr4_match() code has special test for /0 prefixes because of
standard required undefined behaviour. However, it is possible to omit
it on 64-bit because shifting can be done in a 64-bit register and then
truncated to the expected value (which is 0 mask).

Implicit truncation by htonl() fits nicely into R32-within-R64 model
on x86-64.

Space savings: none (coincidence)
Branch savings: 1


Before:

	movzx  eax,BYTE PTR [rdi+0x2a]		# ->prefixlen_d
	test   al,al
	jne    xfrm_selector_match + 0x23f
		...
	movzx  eax,BYTE PTR [rbx+0x2b]		# ->prefixlen_s
	test   al,al
	je     xfrm_selector_match + 0x1c7


After (no branches):

	mov    r8d,0x20
	mov    rdx,0xffffffffffffffff
	mov    esi,DWORD PTR [rsi+0x2c]
	mov    ecx,r8d
	sub    cl,BYTE PTR [rdi+0x2a]
	xor    esi,DWORD PTR [rbx]
	mov    rdi,rdx
	xor    eax,eax
	shl    rdi,cl
	bswap  edi


Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/xfrm.h |    5 +++++
 1 file changed, 5 insertions(+)

--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -844,10 +844,15 @@ static inline bool addr_match(const void *token1, const void *token2,
 
 static inline bool addr4_match(__be32 a1, __be32 a2, u8 prefixlen)
 {
+#ifdef CONFIG_64BIT
+	/* L in UL is not a typo. */
+	return !((a1 ^ a2) & htonl(~0UL << (32 - prefixlen)));
+#else
 	/* C99 6.5.7 (3): u32 << 32 is undefined behaviour */
 	if (prefixlen == 0)
 		return true;
 	return !((a1 ^ a2) & htonl(0xFFFFFFFFu << (32 - prefixlen)));
+#endif
 }
 
 static __inline__
