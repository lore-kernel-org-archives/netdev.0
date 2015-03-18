From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 1/6] netns: constify net_hash_mix() and various callers
Date: Wed, 18 Mar 2015 14:05:33 -0700
Message-ID: <1426712738-23395-2-git-send-email-edumazet@google.com>
References: <1426712738-23395-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f202.google.com ([209.85.192.202]:34214 "EHLO
	mail-pd0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932889AbbCRVFo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 17:05:44 -0400
Received: by pdjp10 with SMTP id p10so2209100pdj.1
        for <netdev@vger.kernel.org>; Wed, 18 Mar 2015 14:05:44 -0700 (PDT)
In-Reply-To: <1426712738-23395-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

const qualifiers ease code review by making clear
which objects are not written in a function.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/udp.h           |  2 +-
 include/net/inet_hashtables.h |  6 +++---
 include/net/netns/hash.h      |  4 ++--
 net/ipv4/devinet.c            |  2 +-
 net/ipv4/inet_hashtables.c    |  6 +++---
 net/ipv4/ping.c               |  6 +++---
 net/ipv4/udp.c                | 10 +++++-----
 net/ipv6/inet6_hashtables.c   | 10 +++++-----
 net/ipv6/udp.c                | 16 ++++++++--------
 9 files changed, 31 insertions(+), 31 deletions(-)

diff --git a/include/linux/udp.h b/include/linux/udp.h
index 247cfdcc4b08..87c094961bd5 100644
--- a/include/linux/udp.h
+++ b/include/linux/udp.h
@@ -34,7 +34,7 @@ static inline struct udphdr *inner_udp_hdr(const struct sk_buff *skb)
 
 #define UDP_HTABLE_SIZE_MIN		(CONFIG_BASE_SMALL ? 128 : 256)
 
-static inline int udp_hashfn(struct net *net, unsigned num, unsigned mask)
+static inline u32 udp_hashfn(const struct net *net, u32 num, u32 mask)
 {
 	return (num + net_hash_mix(net)) & mask;
 }
diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index bcd64756e5fe..eb1963af0ebd 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -221,8 +221,8 @@ inet_bind_bucket_create(struct kmem_cache *cachep, struct net *net,
 void inet_bind_bucket_destroy(struct kmem_cache *cachep,
 			      struct inet_bind_bucket *tb);
 
-static inline int inet_bhashfn(struct net *net, const __u16 lport,
-			       const int bhash_size)
+static inline u32 inet_bhashfn(const struct net *net, const __u16 lport,
+			       const u32 bhash_size)
 {
 	return (lport + net_hash_mix(net)) & (bhash_size - 1);
 }
@@ -231,7 +231,7 @@ void inet_bind_hash(struct sock *sk, struct inet_bind_bucket *tb,
 		    const unsigned short snum);
 
 /* These can have wildcards, don't try too hard. */
-static inline int inet_lhashfn(struct net *net, const unsigned short num)
+static inline u32 inet_lhashfn(const struct net *net, const unsigned short num)
 {
 	return (num + net_hash_mix(net)) & (INET_LHTABLE_SIZE - 1);
 }
diff --git a/include/net/netns/hash.h b/include/net/netns/hash.h
index c06ac58ca107..69a6715d9f3f 100644
--- a/include/net/netns/hash.h
+++ b/include/net/netns/hash.h
@@ -5,7 +5,7 @@
 
 struct net;
 
-static inline unsigned int net_hash_mix(struct net *net)
+static inline u32 net_hash_mix(const struct net *net)
 {
 #ifdef CONFIG_NET_NS
 	/*
@@ -13,7 +13,7 @@ static inline unsigned int net_hash_mix(struct net *net)
 	 * always zeroed
 	 */
 
-	return (unsigned)(((unsigned long)net) >> L1_CACHE_SHIFT);
+	return (u32)(((unsigned long)net) >> L1_CACHE_SHIFT);
 #else
 	return 0;
 #endif
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 5105759e4e00..375dc71b9a64 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -107,7 +107,7 @@ static const struct nla_policy ifa_ipv4_policy[IFA_MAX+1] = {
 
 static struct hlist_head inet_addr_lst[IN4_ADDR_HSIZE];
 
-static u32 inet_addr_hash(struct net *net, __be32 addr)
+static u32 inet_addr_hash(const struct net *net, __be32 addr)
 {
 	u32 val = (__force u32) addr ^ net_hash_mix(net);
 
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index c28bca4cc15b..330a08bcd1c1 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -24,9 +24,9 @@
 #include <net/secure_seq.h>
 #include <net/ip.h>
 
-static unsigned int inet_ehashfn(struct net *net, const __be32 laddr,
-				 const __u16 lport, const __be32 faddr,
-				 const __be16 fport)
+static u32 inet_ehashfn(const struct net *net, const __be32 laddr,
+			const __u16 lport, const __be32 faddr,
+			const __be16 fport)
 {
 	static u32 inet_ehash_secret __read_mostly;
 
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index fd88f868776f..344e7cdfb8d4 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -64,11 +64,11 @@ EXPORT_SYMBOL_GPL(pingv6_ops);
 
 static u16 ping_port_rover;
 
-static inline int ping_hashfn(struct net *net, unsigned int num, unsigned int mask)
+static inline u32 ping_hashfn(const struct net *net, u32 num, u32 mask)
 {
-	int res = (num + net_hash_mix(net)) & mask;
+	u32 res = (num + net_hash_mix(net)) & mask;
 
-	pr_debug("hash(%d) = %d\n", num, res);
+	pr_debug("hash(%u) = %u\n", num, res);
 	return res;
 }
 EXPORT_SYMBOL_GPL(ping_hash);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index f27556e2158b..294af16633af 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -318,8 +318,8 @@ static int ipv4_rcv_saddr_equal(const struct sock *sk1, const struct sock *sk2)
 		   inet1->inet_rcv_saddr == inet2->inet_rcv_saddr));
 }
 
-static unsigned int udp4_portaddr_hash(struct net *net, __be32 saddr,
-				       unsigned int port)
+static u32 udp4_portaddr_hash(const struct net *net, __be32 saddr,
+			      unsigned int port)
 {
 	return jhash_1word((__force u32)saddr, net_hash_mix(net)) ^ port;
 }
@@ -421,9 +421,9 @@ static inline int compute_score2(struct sock *sk, struct net *net,
 	return score;
 }
 
-static unsigned int udp_ehashfn(struct net *net, const __be32 laddr,
-				 const __u16 lport, const __be32 faddr,
-				 const __be16 fport)
+static u32 udp_ehashfn(const struct net *net, const __be32 laddr,
+		       const __u16 lport, const __be32 faddr,
+		       const __be16 fport)
 {
 	static u32 udp_ehash_secret __read_mostly;
 
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index 051dffb49c90..df7df99d1d7e 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -23,11 +23,11 @@
 #include <net/secure_seq.h>
 #include <net/ip.h>
 
-static unsigned int inet6_ehashfn(struct net *net,
-				  const struct in6_addr *laddr,
-				  const u16 lport,
-				  const struct in6_addr *faddr,
-				  const __be16 fport)
+static u32 inet6_ehashfn(const struct net *net,
+			 const struct in6_addr *laddr,
+			 const u16 lport,
+			 const struct in6_addr *faddr,
+			 const __be16 fport)
 {
 	static u32 inet6_ehash_secret __read_mostly;
 	static u32 ipv6_hash_secret __read_mostly;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 70568a4548e4..7fe0329c0d37 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -53,11 +53,11 @@
 #include <trace/events/skb.h>
 #include "udp_impl.h"
 
-static unsigned int udp6_ehashfn(struct net *net,
-				  const struct in6_addr *laddr,
-				  const u16 lport,
-				  const struct in6_addr *faddr,
-				  const __be16 fport)
+static u32 udp6_ehashfn(const struct net *net,
+			const struct in6_addr *laddr,
+			const u16 lport,
+			const struct in6_addr *faddr,
+			const __be16 fport)
 {
 	static u32 udp6_ehash_secret __read_mostly;
 	static u32 udp_ipv6_hash_secret __read_mostly;
@@ -104,9 +104,9 @@ int ipv6_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2)
 	return 0;
 }
 
-static unsigned int udp6_portaddr_hash(struct net *net,
-				       const struct in6_addr *addr6,
-				       unsigned int port)
+static u32 udp6_portaddr_hash(const struct net *net,
+			      const struct in6_addr *addr6,
+			      unsigned int port)
 {
 	unsigned int hash, mix = net_hash_mix(net);
 
-- 
2.2.0.rc0.207.ga3a616c
