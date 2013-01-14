From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 6/6] ipv6: 64bit version of ipv6_prefix_equal().
Date: Tue, 15 Jan 2013 02:10:38 +0900
Message-ID: <50F43C0E.8060003@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:39849 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757701Ab3ANRKk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2013 12:10:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/ipv6.h |   26 ++++++++++++++++++++++++++
 1 file changed, 26 insertions(+)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index fe95053..3d32a8e 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -399,6 +399,31 @@ static inline bool ipv6_addr_equal(const struct in6_addr *a1,
 #endif
 }
 
+#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS) && BITS_PER_LONG == 64
+static inline bool __ipv6_prefix_equal64_half(const __be64 *a1,
+					      const __be64 *a2,
+					      unsigned int len)
+{
+	if (len && ((*a1 ^ *a2) & cpu_to_be64(~0UL) << (64 - len)))
+		return false;
+	return true;
+}
+
+static inline bool ipv6_prefix_equal(const struct in6_addr *addr1,
+				     const struct in6_addr *addr2,
+				     unsigned int prefixlen)
+{
+	const __be64 *a1 = (const __be64 *)addr1;
+	const __be64 *a2 = (const __be64 *)addr2;
+
+	if (prefixlen >= 64) {
+		if (a1[0] ^ a2[0])
+			return false;
+		return __ipv6_prefix_equal64_half(a1 + 1, a2 + 1, prefixlen - 64);
+	}
+	return __ipv6_prefix_equal64_half(a1, a2, prefixlen);
+}
+#else
 static inline bool ipv6_prefix_equal(const struct in6_addr *addr1,
 				     const struct in6_addr *addr2,
 				     unsigned int prefixlen)
@@ -419,6 +444,7 @@ static inline bool ipv6_prefix_equal(const struct in6_addr *addr1,
 
 	return true;
 }
+#endif
 
 struct inet_frag_queue;
 
-- 
1.7.9.5
