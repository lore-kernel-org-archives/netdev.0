From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [RFC, PATCH] IPV6 : add 64 bits components in struct in6_addr to
 speedup ipv6_addr_equal() & ipv6_addr_any()
Date: Mon, 30 Apr 2007 16:28:51 +0200
Message-ID: <20070430162851.ca3c7869.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: yoshfuji Hideaki <yoshfuji@linux-ipv6.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:49973 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754392AbXD3O2x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Apr 2007 10:28:53 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 64bit arches, we can speedup some IPV6 addresses compares, using 64 bits fields in struct in6_addr.

I am not sure if this patch wont break some user ABI, maybe we should use some ifdef(KERNEL) ?

This patch saves some space, and also reduce number of conditional branches in ipv6_addr_equal()

# size vmlinux*
   text    data     bss     dec     hex filename
6257978  692044  660472 7610494  74207e vmlinux
6259178  692044  660472 7611694  74252e vmlinux.before_patch

Note : Maybe ipv6_addr_cmp() could be defined on top of ipv6_addr_equal() ?

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 include/linux/in6.h |    2 ++
 include/net/ipv6.h  |   17 +++++++++++++----
 2 files changed, 15 insertions(+), 4 deletions(-)

diff --git a/include/linux/in6.h b/include/linux/in6.h
index 2a61c82..a4241a6 100644
--- a/include/linux/in6.h
+++ b/include/linux/in6.h
@@ -34,10 +34,12 @@ struct in6_addr
 		__u8		u6_addr8[16];
 		__be16		u6_addr16[8];
 		__be32		u6_addr32[4];
+		__be64		u6_addr64[2];
 	} in6_u;
 #define s6_addr			in6_u.u6_addr8
 #define s6_addr16		in6_u.u6_addr16
 #define s6_addr32		in6_u.u6_addr32
+#define s6_addr64		in6_u.u6_addr64
 };
 
 /* IPv6 Wildcard Address (::) and Loopback Address (::1) defined in RFC2553
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index f70afef..6493ff6 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -343,10 +343,15 @@ #endif
 static inline int ipv6_addr_equal(const struct in6_addr *a1,
 				  const struct in6_addr *a2)
 {
-	return (a1->s6_addr32[0] == a2->s6_addr32[0] &&
-		a1->s6_addr32[1] == a2->s6_addr32[1] &&
-		a1->s6_addr32[2] == a2->s6_addr32[2] &&
-		a1->s6_addr32[3] == a2->s6_addr32[3]);
+#if defined(CONFIG_64BIT)
+	return (((a1->s6_addr64[0] ^ a2->s6_addr64[0]) |
+		(a1->s6_addr64[1] ^ a2->s6_addr64[1])) == 0);
+#else
+	return (((a1->s6_addr32[0] ^ a2->s6_addr32[0]) |
+		(a1->s6_addr32[1] ^ a2->s6_addr32[1]) |
+		(a1->s6_addr32[2] ^ a2->s6_addr32[2]) |
+		(a1->s6_addr32[3] ^ a2->s6_addr32[3])) == 0);
+#endif
 }
 
 static inline int __ipv6_prefix_equal(const __be32 *a1, const __be32 *a2,
@@ -377,8 +382,12 @@ static inline int ipv6_prefix_equal(cons
 
 static inline int ipv6_addr_any(const struct in6_addr *a)
 {
+#if defined(CONFIG_64BIT)
+	return ((a->s6_addr64[0] | a->s6_addr64[1]) == 0);
+#else
 	return ((a->s6_addr32[0] | a->s6_addr32[1] | 
 		 a->s6_addr32[2] | a->s6_addr32[3] ) == 0); 
+#endif
 }
 
 /*
