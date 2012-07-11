From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv6: optimize ipv6 addresses compares
Date: Wed, 11 Jul 2012 05:49:18 +0200
Message-ID: <1341978558.3265.6609.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Joe Perches <joe@perches.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:46520 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754309Ab2GKDt1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 23:49:27 -0400
Received: by wibhm11 with SMTP id hm11so5234514wib.1
        for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 20:49:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

On 64 bit arches having efficient unaligned accesses (eg x86_64) we can
use long words to reduce number of instructions for free.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Joe Perches <joe@perches.com>
---
 include/net/ipv6.h |   22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index aecf884..9ac5ded 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -302,10 +302,19 @@ static inline int
 ipv6_masked_addr_cmp(const struct in6_addr *a1, const struct in6_addr *m,
 		     const struct in6_addr *a2)
 {
+#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS) && BITS_PER_LONG == 64
+	const unsigned long *ul1 = (const unsigned long *)a1;
+	const unsigned long *ulm = (const unsigned long *)m;
+	const unsigned long *ul2 = (const unsigned long *)a2;
+
+	return !!(((ul1[0] ^ ul2[0]) & ulm[0]) |
+		  ((ul1[1] ^ ul2[1]) & ulm[1]));
+#else
 	return !!(((a1->s6_addr32[0] ^ a2->s6_addr32[0]) & m->s6_addr32[0]) |
 		  ((a1->s6_addr32[1] ^ a2->s6_addr32[1]) & m->s6_addr32[1]) |
 		  ((a1->s6_addr32[2] ^ a2->s6_addr32[2]) & m->s6_addr32[2]) |
 		  ((a1->s6_addr32[3] ^ a2->s6_addr32[3]) & m->s6_addr32[3]));
+#endif
 }
 
 static inline void ipv6_addr_prefix(struct in6_addr *pfx, 
@@ -335,10 +344,17 @@ static inline void ipv6_addr_set(struct in6_addr *addr,
 static inline bool ipv6_addr_equal(const struct in6_addr *a1,
 				   const struct in6_addr *a2)
 {
+#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS) && BITS_PER_LONG == 64
+	const unsigned long *ul1 = (const unsigned long *)a1;
+	const unsigned long *ul2 = (const unsigned long *)a2;
+
+	return ((ul1[0] ^ ul2[0]) | (ul1[1] ^ ul2[1])) == 0UL;
+#else
 	return ((a1->s6_addr32[0] ^ a2->s6_addr32[0]) |
 		(a1->s6_addr32[1] ^ a2->s6_addr32[1]) |
 		(a1->s6_addr32[2] ^ a2->s6_addr32[2]) |
 		(a1->s6_addr32[3] ^ a2->s6_addr32[3])) == 0;
+#endif
 }
 
 static inline bool __ipv6_prefix_equal(const __be32 *a1, const __be32 *a2,
@@ -391,8 +407,14 @@ bool ip6_frag_match(struct inet_frag_queue *q, void *a);
 
 static inline bool ipv6_addr_any(const struct in6_addr *a)
 {
+#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS) && BITS_PER_LONG == 64
+	const unsigned long *ul = (const unsigned long *)a;
+
+	return (ul[0] | ul[1]) == 0UL;
+#else
 	return (a->s6_addr32[0] | a->s6_addr32[1] |
 		a->s6_addr32[2] | a->s6_addr32[3]) == 0;
+#endif
 }
 
 static inline bool ipv6_addr_loopback(const struct in6_addr *a)
