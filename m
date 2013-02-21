From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ipv6: use a stronger hash for tcp
Date: Thu, 21 Feb 2013 14:18:52 -0800
Message-ID: <1361485132.17413.19.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:33477 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756192Ab3BUWSy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2013 17:18:54 -0500
Received: by mail-pa0-f54.google.com with SMTP id fa10so70506pad.41
        for <netdev@vger.kernel.org>; Thu, 21 Feb 2013 14:18:54 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

It looks like its possible to open thousands of TCP IPv6
sessions on a server, all landing in a single slot of TCP hash
table. Incoming packets have to lookup sockets in a very
long list.

We should hash all bits from foreign IPv6 addresses, using
a salt and hash mix, not a simple XOR.

inet6_ehashfn() can also separately use the ports, instead
of xoring them.

Reported-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
---
 include/net/inet6_hashtables.h |    8 ++++----
 include/net/inet_sock.h        |    1 +
 include/net/ipv6.h             |   12 ++++++++++++
 net/ipv4/af_inet.c             |    9 +++++++--
 4 files changed, 24 insertions(+), 6 deletions(-)

diff --git a/include/net/inet6_hashtables.h b/include/net/inet6_hashtables.h
index 7ca75cb..fd4ee01 100644
--- a/include/net/inet6_hashtables.h
+++ b/include/net/inet6_hashtables.h
@@ -28,16 +28,16 @@
 
 struct inet_hashinfo;
 
-/* I have no idea if this is a good hash for v6 or not. -DaveM */
 static inline unsigned int inet6_ehashfn(struct net *net,
 				const struct in6_addr *laddr, const u16 lport,
 				const struct in6_addr *faddr, const __be16 fport)
 {
-	u32 ports = (lport ^ (__force u16)fport);
+	u32 ports = (((u32)lport) << 16) | (__force u32)fport;
 
 	return jhash_3words((__force u32)laddr->s6_addr32[3],
-			    (__force u32)faddr->s6_addr32[3],
-			    ports, inet_ehash_secret + net_hash_mix(net));
+			    ipv6_addr_jhash(faddr),
+			    ports,
+			    inet_ehash_secret + net_hash_mix(net));
 }
 
 static inline int inet6_sk_ehashfn(const struct sock *sk)
diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index a4196cb..7235ae7 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -203,6 +203,7 @@ static inline void inet_sk_copy_descendant(struct sock *sk_to,
 extern int inet_sk_rebuild_header(struct sock *sk);
 
 extern u32 inet_ehash_secret;
+extern u32 ipv6_hash_secret;
 extern void build_ehash_secret(void);
 
 static inline unsigned int inet_ehashfn(struct net *net,
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 851d541..d772f99 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -15,6 +15,7 @@
 
 #include <linux/ipv6.h>
 #include <linux/hardirq.h>
+#include <linux/jhash.h>
 #include <net/if_inet6.h>
 #include <net/ndisc.h>
 #include <net/flow.h>
@@ -514,6 +515,17 @@ static inline u32 ipv6_addr_hash(const struct in6_addr *a)
 #endif
 }
 
+/* more secured version of ipv6_addr_hash() */
+static inline u32 ipv6_addr_jhash(const struct in6_addr *a)
+{
+	u32 v = (__force u32)a->s6_addr32[0] ^ (__force u32)a->s6_addr32[1];
+
+	return jhash_3words(v,
+			    (__force u32)a->s6_addr32[2],
+			    (__force u32)a->s6_addr32[3],
+			    ipv6_hash_secret);
+}
+
 static inline bool ipv6_addr_loopback(const struct in6_addr *a)
 {
 #if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS) && BITS_PER_LONG == 64
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index e225a4e..9cbcb94 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -248,8 +248,12 @@ EXPORT_SYMBOL(inet_listen);
 u32 inet_ehash_secret __read_mostly;
 EXPORT_SYMBOL(inet_ehash_secret);
 
+u32 ipv6_hash_secret __read_mostly;
+EXPORT_SYMBOL(ipv6_hash_secret);
+
 /*
- * inet_ehash_secret must be set exactly once
+ * inet_ehash_secret must be set exactly once, and to a non nul value
+ * ipv6_hash_secret must be set exactly once.
  */
 void build_ehash_secret(void)
 {
@@ -259,7 +263,8 @@ void build_ehash_secret(void)
 		get_random_bytes(&rnd, sizeof(rnd));
 	} while (rnd == 0);
 
-	cmpxchg(&inet_ehash_secret, 0, rnd);
+	if (cmpxchg(&inet_ehash_secret, 0, rnd) == 0)
+		get_random_bytes(&ipv6_hash_secret, sizeof(ipv6_hash_secret));
 }
 EXPORT_SYMBOL(build_ehash_secret);
 
