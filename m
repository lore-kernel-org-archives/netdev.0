From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next v4] ipv6: add ipv6_addr_hash() helper
Date: Wed, 18 Jul 2012 20:11:12 +0200
Message-ID: <1342635072.2626.3322.camel@edumazet-glaptop>
References: <1342613334.2626.2504.camel@edumazet-glaptop>
	 <1342619879.9551.14.camel@joe2Laptop>
	 <1342620841.2626.2786.camel@edumazet-glaptop>
	 <1342621670.2626.2818.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>, netdev <netdev@vger.kernel.org>,
	Andrew McGregor <andrewmcgr@gmail.com>,
	Dave Taht <dave.taht@gmail.com>,
	Tom Herbert <therbert@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:55043 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753211Ab2GRSLR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 14:11:17 -0400
Received: by gglu4 with SMTP id u4so1877957ggl.19
        for <netdev@vger.kernel.org>; Wed, 18 Jul 2012 11:11:17 -0700 (PDT)
In-Reply-To: <1342621670.2626.2818.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Introduce ipv6_addr_hash() helper doing a XOR on all bits
of an IPv6 address, with an optimized x86_64 version.

Use it in flow dissector, as suggested by Andrew McGregor,
to reduce hash collision probabilities in fq_codel (and other
users of flow dissector)

Use it in ip6_tunnel.c and use more bit shuffling, as suggested
by David Laight, as existing hash was ignoring most of them.

Use it in sunrpc and use more bit shuffling, using hash_32().

Use it in net/ipv6/addrconf.c, using hash_32() as well.

As a cleanup, use it in net/ipv4/tcp_metrics.c

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Andrew McGregor <andrewmcgr@gmail.com>
Cc: Dave Taht <dave.taht@gmail.com>
Cc: Tom Herbert <therbert@google.com>
Cc: David Laight <David.Laight@ACULAB.COM>
Cc: Joe Perches <joe@perches.com>
---
v4: net/ipv6/addrconf.c part, sorry again David

 include/net/addrconf.h    |    3 ++-
 include/net/ipv6.h        |   13 +++++++++++++
 net/core/flow_dissector.c |    5 +++--
 net/ipv4/tcp_metrics.c    |   15 +++------------
 net/ipv6/addrconf.c       |   21 ++++++++-------------
 net/ipv6/ip6_tunnel.c     |   20 ++++++++++++--------
 net/sunrpc/svcauth_unix.c |   22 ++++------------------
 7 files changed, 45 insertions(+), 54 deletions(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index f2b801c..089a09d 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -46,7 +46,8 @@ struct prefix_info {
 #include <net/if_inet6.h>
 #include <net/ipv6.h>
 
-#define IN6_ADDR_HSIZE		16
+#define IN6_ADDR_HSIZE_SHIFT	4
+#define IN6_ADDR_HSIZE		(1 << IN6_ADDR_HSIZE_SHIFT)
 
 extern int			addrconf_init(void);
 extern void			addrconf_cleanup(void);
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index f695f39..01c34b3 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -419,6 +419,19 @@ static inline bool ipv6_addr_any(const struct in6_addr *a)
 #endif
 }
 
+static inline u32 ipv6_addr_hash(const struct in6_addr *a)
+{
+#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS) && BITS_PER_LONG == 64
+	const unsigned long *ul = (const unsigned long *)a;
+	unsigned long x = ul[0] ^ ul[1];
+
+	return (u32)(x ^ (x >> 32));
+#else
+	return (__force u32)(a->s6_addr32[0] ^ a->s6_addr32[1] ^
+			     a->s6_addr32[2] ^ a->s6_addr32[3]);
+#endif
+}
+
 static inline bool ipv6_addr_loopback(const struct in6_addr *a)
 {
 	return (a->s6_addr32[0] | a->s6_addr32[1] |
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index a225089..466820b 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -4,6 +4,7 @@
 #include <linux/ipv6.h>
 #include <linux/if_vlan.h>
 #include <net/ip.h>
+#include <net/ipv6.h>
 #include <linux/if_tunnel.h>
 #include <linux/if_pppox.h>
 #include <linux/ppp_defs.h>
@@ -55,8 +56,8 @@ ipv6:
 			return false;
 
 		ip_proto = iph->nexthdr;
-		flow->src = iph->saddr.s6_addr32[3];
-		flow->dst = iph->daddr.s6_addr32[3];
+		flow->src = (__force __be32)ipv6_addr_hash(&iph->saddr);
+		flow->dst = (__force __be32)ipv6_addr_hash(&iph->daddr);
 		nhoff += sizeof(struct ipv6hdr);
 		break;
 	}
diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index 5a38a2d..1a115b6 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -211,10 +211,7 @@ static struct tcp_metrics_block *__tcp_get_metrics_req(struct request_sock *req,
 		break;
 	case AF_INET6:
 		*(struct in6_addr *)addr.addr.a6 = inet6_rsk(req)->rmt_addr;
-		hash = ((__force unsigned int) addr.addr.a6[0] ^
-			(__force unsigned int) addr.addr.a6[1] ^
-			(__force unsigned int) addr.addr.a6[2] ^
-			(__force unsigned int) addr.addr.a6[3]);
+		hash = ipv6_addr_hash(&inet6_rsk(req)->rmt_addr);
 		break;
 	default:
 		return NULL;
@@ -251,10 +248,7 @@ static struct tcp_metrics_block *__tcp_get_metrics_tw(struct inet_timewait_sock
 	case AF_INET6:
 		tw6 = inet6_twsk((struct sock *)tw);
 		*(struct in6_addr *)addr.addr.a6 = tw6->tw_v6_daddr;
-		hash = ((__force unsigned int) addr.addr.a6[0] ^
-			(__force unsigned int) addr.addr.a6[1] ^
-			(__force unsigned int) addr.addr.a6[2] ^
-			(__force unsigned int) addr.addr.a6[3]);
+		hash = ipv6_addr_hash(&tw6->tw_v6_daddr);
 		break;
 	default:
 		return NULL;
@@ -291,10 +285,7 @@ static struct tcp_metrics_block *tcp_get_metrics(struct sock *sk,
 		break;
 	case AF_INET6:
 		*(struct in6_addr *)addr.addr.a6 = inet6_sk(sk)->daddr;
-		hash = ((__force unsigned int) addr.addr.a6[0] ^
-			(__force unsigned int) addr.addr.a6[1] ^
-			(__force unsigned int) addr.addr.a6[2] ^
-			(__force unsigned int) addr.addr.a6[3]);
+		hash = ipv6_addr_hash(&inet6_sk(sk)->daddr);
 		break;
 	default:
 		return NULL;
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 8f6411c..7918181 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -63,6 +63,7 @@
 #include <linux/delay.h>
 #include <linux/notifier.h>
 #include <linux/string.h>
+#include <linux/hash.h>
 
 #include <net/net_namespace.h>
 #include <net/sock.h>
@@ -579,15 +580,9 @@ ipv6_link_dev_addr(struct inet6_dev *idev, struct inet6_ifaddr *ifp)
 	list_add_tail(&ifp->if_list, p);
 }
 
-static u32 ipv6_addr_hash(const struct in6_addr *addr)
+static u32 inet6_addr_hash(const struct in6_addr *addr)
 {
-	/*
-	 * We perform the hash function over the last 64 bits of the address
-	 * This will include the IEEE address token on links that support it.
-	 */
-	return jhash_2words((__force u32)addr->s6_addr32[2],
-			    (__force u32)addr->s6_addr32[3], 0)
-		& (IN6_ADDR_HSIZE - 1);
+	return hash_32(ipv6_addr_hash(addr), IN6_ADDR_HSIZE_SHIFT);
 }
 
 /* On success it returns ifp with increased reference count */
@@ -662,7 +657,7 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr, int pfxlen,
 	in6_ifa_hold(ifa);
 
 	/* Add to big hash table */
-	hash = ipv6_addr_hash(addr);
+	hash = inet6_addr_hash(addr);
 
 	hlist_add_head_rcu(&ifa->addr_lst, &inet6_addr_lst[hash]);
 	spin_unlock(&addrconf_hash_lock);
@@ -1270,7 +1265,7 @@ int ipv6_chk_addr(struct net *net, const struct in6_addr *addr,
 {
 	struct inet6_ifaddr *ifp;
 	struct hlist_node *node;
-	unsigned int hash = ipv6_addr_hash(addr);
+	unsigned int hash = inet6_addr_hash(addr);
 
 	rcu_read_lock_bh();
 	hlist_for_each_entry_rcu(ifp, node, &inet6_addr_lst[hash], addr_lst) {
@@ -1293,7 +1288,7 @@ EXPORT_SYMBOL(ipv6_chk_addr);
 static bool ipv6_chk_same_addr(struct net *net, const struct in6_addr *addr,
 			       struct net_device *dev)
 {
-	unsigned int hash = ipv6_addr_hash(addr);
+	unsigned int hash = inet6_addr_hash(addr);
 	struct inet6_ifaddr *ifp;
 	struct hlist_node *node;
 
@@ -1336,7 +1331,7 @@ struct inet6_ifaddr *ipv6_get_ifaddr(struct net *net, const struct in6_addr *add
 				     struct net_device *dev, int strict)
 {
 	struct inet6_ifaddr *ifp, *result = NULL;
-	unsigned int hash = ipv6_addr_hash(addr);
+	unsigned int hash = inet6_addr_hash(addr);
 	struct hlist_node *node;
 
 	rcu_read_lock_bh();
@@ -3223,7 +3218,7 @@ int ipv6_chk_home_addr(struct net *net, const struct in6_addr *addr)
 	int ret = 0;
 	struct inet6_ifaddr *ifp = NULL;
 	struct hlist_node *n;
-	unsigned int hash = ipv6_addr_hash(addr);
+	unsigned int hash = inet6_addr_hash(addr);
 
 	rcu_read_lock_bh();
 	hlist_for_each_entry_rcu_bh(ifp, n, &inet6_addr_lst[hash], addr_lst) {
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index db32846..9a1d5fe 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -40,6 +40,7 @@
 #include <linux/rtnetlink.h>
 #include <linux/netfilter_ipv6.h>
 #include <linux/slab.h>
+#include <linux/hash.h>
 
 #include <asm/uaccess.h>
 #include <linux/atomic.h>
@@ -70,11 +71,15 @@ MODULE_ALIAS_NETDEV("ip6tnl0");
 #define IPV6_TCLASS_MASK (IPV6_FLOWINFO_MASK & ~IPV6_FLOWLABEL_MASK)
 #define IPV6_TCLASS_SHIFT 20
 
-#define HASH_SIZE  32
+#define HASH_SIZE_SHIFT  5
+#define HASH_SIZE (1 << HASH_SIZE_SHIFT)
 
-#define HASH(addr) ((__force u32)((addr)->s6_addr32[0] ^ (addr)->s6_addr32[1] ^ \
-		     (addr)->s6_addr32[2] ^ (addr)->s6_addr32[3]) & \
-		    (HASH_SIZE - 1))
+static u32 HASH(const struct in6_addr *addr1, const struct in6_addr *addr2)
+{
+	u32 hash = ipv6_addr_hash(addr1) ^ ipv6_addr_hash(addr2);
+
+	return hash_32(hash, HASH_SIZE_SHIFT);
+}
 
 static int ip6_tnl_dev_init(struct net_device *dev);
 static void ip6_tnl_dev_setup(struct net_device *dev);
@@ -166,12 +171,11 @@ static inline void ip6_tnl_dst_store(struct ip6_tnl *t, struct dst_entry *dst)
 static struct ip6_tnl *
 ip6_tnl_lookup(struct net *net, const struct in6_addr *remote, const struct in6_addr *local)
 {
-	unsigned int h0 = HASH(remote);
-	unsigned int h1 = HASH(local);
+	unsigned int hash = HASH(remote, local);
 	struct ip6_tnl *t;
 	struct ip6_tnl_net *ip6n = net_generic(net, ip6_tnl_net_id);
 
-	for_each_ip6_tunnel_rcu(ip6n->tnls_r_l[h0 ^ h1]) {
+	for_each_ip6_tunnel_rcu(ip6n->tnls_r_l[hash]) {
 		if (ipv6_addr_equal(local, &t->parms.laddr) &&
 		    ipv6_addr_equal(remote, &t->parms.raddr) &&
 		    (t->dev->flags & IFF_UP))
@@ -205,7 +209,7 @@ ip6_tnl_bucket(struct ip6_tnl_net *ip6n, const struct ip6_tnl_parm *p)
 
 	if (!ipv6_addr_any(remote) || !ipv6_addr_any(local)) {
 		prio = 1;
-		h = HASH(remote) ^ HASH(local);
+		h = HASH(remote, local);
 	}
 	return &ip6n->tnls[prio][h];
 }
diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index 2777fa8..4d01292 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -104,23 +104,9 @@ static void ip_map_put(struct kref *kref)
 	kfree(im);
 }
 
-#if IP_HASHBITS == 8
-/* hash_long on a 64 bit machine is currently REALLY BAD for
- * IP addresses in reverse-endian (i.e. on a little-endian machine).
- * So use a trivial but reliable hash instead
- */
-static inline int hash_ip(__be32 ip)
-{
-	int hash = (__force u32)ip ^ ((__force u32)ip>>16);
-	return (hash ^ (hash>>8)) & 0xff;
-}
-#endif
-static inline int hash_ip6(struct in6_addr ip)
+static inline int hash_ip6(const struct in6_addr *ip)
 {
-	return (hash_ip(ip.s6_addr32[0]) ^
-		hash_ip(ip.s6_addr32[1]) ^
-		hash_ip(ip.s6_addr32[2]) ^
-		hash_ip(ip.s6_addr32[3]));
+	return hash_32(ipv6_addr_hash(ip), IP_HASHBITS);
 }
 static int ip_map_match(struct cache_head *corig, struct cache_head *cnew)
 {
@@ -301,7 +287,7 @@ static struct ip_map *__ip_map_lookup(struct cache_detail *cd, char *class,
 	ip.m_addr = *addr;
 	ch = sunrpc_cache_lookup(cd, &ip.h,
 				 hash_str(class, IP_HASHBITS) ^
-				 hash_ip6(*addr));
+				 hash_ip6(addr));
 
 	if (ch)
 		return container_of(ch, struct ip_map, h);
@@ -331,7 +317,7 @@ static int __ip_map_update(struct cache_detail *cd, struct ip_map *ipm,
 	ip.h.expiry_time = expiry;
 	ch = sunrpc_cache_update(cd, &ip.h, &ipm->h,
 				 hash_str(ipm->m_class, IP_HASHBITS) ^
-				 hash_ip6(ipm->m_addr));
+				 hash_ip6(&ipm->m_addr));
 	if (!ch)
 		return -ENOMEM;
 	cache_put(ch, cd);
