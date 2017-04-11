From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 4/4] xfrm: branchless addr4_match() on 64-bit
Date: Tue, 11 Apr 2017 07:53:52 +0200
Message-ID: <1491890032-28655-5-git-send-email-steffen.klassert@secunet.com>
References: <1491890032-28655-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:56586 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752291AbdDKGAD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Apr 2017 02:00:03 -0400
In-Reply-To: <1491890032-28655-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>

Current addr4_match() code has special test for /0 prefixes because of
standard required undefined behaviour. However, it is possible to omit
it on 64-bit because shifting can be done within a 64-bit register and
then truncated to the expected value (which is 0 mask).

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
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 43b93d1..9e3dc7b 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -845,9 +845,9 @@ static inline bool addr_match(const void *token1, const void *token2,
 static inline bool addr4_match(__be32 a1, __be32 a2, u8 prefixlen)
 {
 	/* C99 6.5.7 (3): u32 << 32 is undefined behaviour */
-	if (prefixlen == 0)
+	if (sizeof(long) == 4 && prefixlen == 0)
 		return true;
-	return !((a1 ^ a2) & htonl(0xFFFFFFFFu << (32 - prefixlen)));
+	return !((a1 ^ a2) & htonl(~0UL << (32 - prefixlen)));
 }
 
 static __inline__
-- 
2.7.4
