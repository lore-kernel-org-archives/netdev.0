From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-next 8/8] Netns: introduce the net_hash_mix "salt" for
 hashes
Date: Mon, 16 Jun 2008 13:51:55 +0400
Message-ID: <485637BB.4050102@openvz.org>
References: <485633E4.10900@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:41156 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757946AbYFPJyU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jun 2008 05:54:20 -0400
In-Reply-To: <485633E4.10900@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are many possible ways to add this "salt", thus I made this
patch to be the last in the series to change it if required.

Currently I propose to use the struct net pointer itself as this 
salt, but since this pointer is most often cache-line aligned, shift 
this right to eliminate the bits, that are most often zeroed.

After this, simply add this mix to prepared hashfn-s.

For CONFIG_NET_NS=n case this salt is 0 and no changes in hashfn
appear.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 include/linux/udp.h            |    3 ++-
 include/net/inet6_hashtables.h |    3 ++-
 include/net/inet_hashtables.h  |    5 +++--
 include/net/inet_sock.h        |    3 ++-
 include/net/netns/hash.h       |   21 +++++++++++++++++++++
 5 files changed, 30 insertions(+), 5 deletions(-)
 create mode 100644 include/net/netns/hash.h

diff --git a/include/linux/udp.h b/include/linux/udp.h
index 3deccac..0cf5c4c 100644
--- a/include/linux/udp.h
+++ b/include/linux/udp.h
@@ -38,6 +38,7 @@ struct udphdr {
 #ifdef __KERNEL__
 #include <net/inet_sock.h>
 #include <linux/skbuff.h>
+#include <net/netns/hash.h>
 
 static inline struct udphdr *udp_hdr(const struct sk_buff *skb)
 {
@@ -48,7 +49,7 @@ static inline struct udphdr *udp_hdr(const struct sk_buff *skb)
 
 static inline int udp_hashfn(struct net *net, const unsigned num)
 {
-	return num & (UDP_HTABLE_SIZE - 1);
+	return (num + net_hash_mix(net)) & (UDP_HTABLE_SIZE - 1);
 }
 
 struct udp_sock {
diff --git a/include/net/inet6_hashtables.h b/include/net/inet6_hashtables.h
index 72f13a9..e48989f 100644
--- a/include/net/inet6_hashtables.h
+++ b/include/net/inet6_hashtables.h
@@ -24,6 +24,7 @@
 #include <net/inet_sock.h>
 
 #include <net/ipv6.h>
+#include <net/netns/hash.h>
 
 struct inet_hashinfo;
 
@@ -36,7 +37,7 @@ static inline unsigned int inet6_ehashfn(struct net *net,
 
 	return jhash_3words((__force u32)laddr->s6_addr32[3],
 			    (__force u32)faddr->s6_addr32[3],
-			    ports, inet_ehash_secret);
+			    ports, inet_ehash_secret + net_hash_mix(net));
 }
 
 static inline int inet6_sk_ehashfn(const struct sock *sk)
diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index 26336cd..bb619d8 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -29,6 +29,7 @@
 #include <net/inet_sock.h>
 #include <net/sock.h>
 #include <net/tcp_states.h>
+#include <net/netns/hash.h>
 
 #include <asm/atomic.h>
 #include <asm/byteorder.h>
@@ -204,7 +205,7 @@ extern void inet_bind_bucket_destroy(struct kmem_cache *cachep,
 static inline int inet_bhashfn(struct net *net,
 		const __u16 lport, const int bhash_size)
 {
-	return lport & (bhash_size - 1);
+	return (lport + net_hash_mix(net)) & (bhash_size - 1);
 }
 
 extern void inet_bind_hash(struct sock *sk, struct inet_bind_bucket *tb,
@@ -213,7 +214,7 @@ extern void inet_bind_hash(struct sock *sk, struct inet_bind_bucket *tb,
 /* These can have wildcards, don't try too hard. */
 static inline int inet_lhashfn(struct net *net, const unsigned short num)
 {
-	return num & (INET_LHTABLE_SIZE - 1);
+	return (num + net_hash_mix(net)) & (INET_LHTABLE_SIZE - 1);
 }
 
 static inline int inet_sk_listen_hashfn(const struct sock *sk)
diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index ab8e19d..508fb95 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -25,6 +25,7 @@
 #include <net/sock.h>
 #include <net/request_sock.h>
 #include <net/route.h>
+#include <net/netns/hash.h>
 
 /** struct ip_options - IP Options
  *
@@ -178,7 +179,7 @@ static inline unsigned int inet_ehashfn(struct net *net,
 	return jhash_3words((__force __u32) laddr,
 			    (__force __u32) faddr,
 			    ((__u32) lport) << 16 | (__force __u32)fport,
-			    inet_ehash_secret);
+			    inet_ehash_secret + net_hash_mix(net));
 }
 
 static inline int inet_sk_ehashfn(const struct sock *sk)
diff --git a/include/net/netns/hash.h b/include/net/netns/hash.h
new file mode 100644
index 0000000..548d78f
--- /dev/null
+++ b/include/net/netns/hash.h
@@ -0,0 +1,21 @@
+#ifndef __NET_NS_HASH_H__
+#define __NET_NS_HASH_H__
+
+#include <asm/cache.h>
+
+struct net;
+
+static inline unsigned net_hash_mix(struct net *net)
+{
+#ifdef CONFIG_NET_NS
+	/*
+	 * shift this right to eliminate bits, that are
+	 * always zeroed
+	 */
+
+	return (unsigned)(((unsigned long)net) >> L1_CACHE_SHIFT);
+#else
+	return 0;
+#endif
+}
+#endif
-- 
1.5.3.4

