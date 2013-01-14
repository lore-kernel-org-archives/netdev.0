From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 1/6] ipv6: 64bit version of ipv6_addr_diff().
Date: Tue, 15 Jan 2013 02:09:54 +0900
Message-ID: <50F43BE2.8090005@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:39833 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757227Ab3ANRJz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2013 12:09:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce __ipv6_addr_diff64() to to find the first different
bit between two addresses on 64bit architectures.

32bit version is still available as __ipv6_addr_diff32(),
and __ipv6_addr_diff() automatically selects appropriate
version.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/ipv6.h |   29 ++++++++++++++++++++++++++++-
 1 file changed, 28 insertions(+), 1 deletion(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index ed67208..ace1113 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -507,7 +507,7 @@ static inline void ipv6_addr_set_v4mapped(const __be32 addr,
  * find the first different bit between two addresses
  * length of address must be a multiple of 32bits
  */
-static inline int __ipv6_addr_diff(const void *token1, const void *token2, int addrlen)
+static inline int __ipv6_addr_diff32(const void *token1, const void *token2, int addrlen)
 {
 	const __be32 *a1 = token1, *a2 = token2;
 	int i;
@@ -539,6 +539,33 @@ static inline int __ipv6_addr_diff(const void *token1, const void *token2, int a
 	return addrlen << 5;
 }
 
+#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS) && BITS_PER_LONG == 64
+static inline int __ipv6_addr_diff64(const void *token1, const void *token2, int addrlen)
+{
+	const __be64 *a1 = token1, *a2 = token2;
+	int i;
+
+	addrlen >>= 3;
+
+	for (i = 0; i < addrlen; i++) {
+		__be64 xb = a1[i] ^ a2[i];
+		if (xb)
+			return i * 64 + 63 - __fls(be64_to_cpu(xb));
+	}
+
+	return addrlen << 6;
+}
+#endif
+
+static inline int __ipv6_addr_diff(const void *token1, const void *token2, int addrlen)
+{
+#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS) && BITS_PER_LONG == 64
+	if (__builtin_constant_p(addrlen) && !(addrlen & 7))
+		return __ipv6_addr_diff64(token1, token2, addrlen);
+#endif
+	return __ipv6_addr_diff32(token1, token2, addrlen);
+}
+
 static inline int ipv6_addr_diff(const struct in6_addr *a1, const struct in6_addr *a2)
 {
 	return __ipv6_addr_diff(a1, a2, sizeof(struct in6_addr));
-- 
1.7.9.5
