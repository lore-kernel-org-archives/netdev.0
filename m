From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 4/6] ipv6: 64bit version of ipv6_addr_set().
Date: Tue, 15 Jan 2013 02:10:24 +0900
Message-ID: <50F43C00.9060808@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:39841 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757232Ab3ANRK0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2013 12:10:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/ipv6.h |   26 ++++++++++++++++++++++----
 1 file changed, 22 insertions(+), 4 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 77cef332..fb7f7c6 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -355,14 +355,32 @@ static inline void ipv6_addr_prefix(struct in6_addr *pfx,
 		pfx->s6_addr[o] = addr->s6_addr[o] & (0xff00 >> b);
 }
 
+static inline void __ipv6_addr_set_half(__be32 *addr,
+					__be32 wh, __be32 wl)
+{
+#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS) && BITS_PER_LONG == 64
+#if defined(__BIG_ENDIAN)
+	if (__builtin_constant_p(wh) && __builtin_constant_p(wl)) {
+		*(__force u64 *)addr = ((__force u64)(wh) << 32 | (__force u64)(wl));
+		return;
+	}
+#elif defined(__LITTLE_ENDIAN)
+	if (__builtin_constant_p(wl) && __builtin_constant_p(wh)) {
+		*(__force u64 *)addr = ((__force u64)(wl) << 32 | (__force u64)(wh));
+		return;
+	}
+#endif
+#endif
+	addr[0] = wh;
+	addr[1] = wl;
+}
+
 static inline void ipv6_addr_set(struct in6_addr *addr, 
 				     __be32 w1, __be32 w2,
 				     __be32 w3, __be32 w4)
 {
-	addr->s6_addr32[0] = w1;
-	addr->s6_addr32[1] = w2;
-	addr->s6_addr32[2] = w3;
-	addr->s6_addr32[3] = w4;
+	__ipv6_addr_set_half(&addr->s6_addr32[0], w1, w2);
+	__ipv6_addr_set_half(&addr->s6_addr32[2], w3, w4);
 }
 
 static inline bool ipv6_addr_equal(const struct in6_addr *a1,
-- 
1.7.9.5
