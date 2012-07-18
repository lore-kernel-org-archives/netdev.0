From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH net-next] ipv6: add ipv6_addr_hash() helper
Date: Wed, 18 Jul 2012 16:06:06 +0200
Message-ID: <1342620366.2626.2764.camel@edumazet-glaptop>
References: <1342613334.2626.2504.camel@edumazet-glaptop>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B6F93@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Andrew McGregor <andrewmcgr@gmail.com>,
	Dave Taht <dave.taht@gmail.com>,
	Tom Herbert <therbert@google.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:62590 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753152Ab2GROGP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 10:06:15 -0400
Received: by vbbff1 with SMTP id ff1so1107449vbb.19
        for <netdev@vger.kernel.org>; Wed, 18 Jul 2012 07:06:14 -0700 (PDT)
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6F93@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

On Wed, 2012-07-18 at 13:28 +0100, David Laight wrote:
> >  #define HASH_SIZE  32
> > 
> > -#define HASH(addr) ((__force u32)((addr)->s6_addr32[0] ^ (addr)->s6_addr32[1] ^ \
> > -		     (addr)->s6_addr32[2] ^ (addr)->s6_addr32[3]) & \
> > -		    (HASH_SIZE - 1))
> > +#define HASH(addr) (ipv6_addr_hash(addr) & (HASH_SIZE - 1))
> 
> That hash doesn't seem to include many variable bits at all!
> Especially on LE systems where it doesn't contain any of
> the low bits of a mac address based IPv6 address.
> 

Good point.

Apparently nobody uses a lot of ipv6 tunnels ;)

Thanks

[PATCH net-next v2] ipv6: add ipv6_addr_hash() helper

Introduce ipv6_addr_hash() helper doing a XOR on all bits
of an IPv6 address, with an optimized x86_64 version.

Use it in flow dissector, as suggested by Andrew McGregor,
to reduce hash collision probabilities in fq_codel (and other
users of flow dissector)

Use it in ip6_tunnel.c and use more bit shuffling, as suggested
by David Laight, as existing hash was ignoring most of them.

Use it in sunrpc and use more bit shuffling, using hash_32().

As cleanup, use it in net/ipv4/tcp_metrics.c

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Andrew McGregor <andrewmcgr@gmail.com>
Cc: Dave Taht <dave.taht@gmail.com>
Cc: Tom Herbert <therbert@google.com>
Cc: David Laight <David.Laight@ACULAB.COM>
---
 include/net/ipv6.h        |   13 +++++++++++++
 net/core/flow_dissector.c |    5 +++--
 net/ipv4/tcp_metrics.c    |   15 +++------------
 net/ipv6/ip6_tunnel.c     |   20 ++++++++++++--------
 net/sunrpc/svcauth_unix.c |   22 ++++------------------
 5 files changed, 35 insertions(+), 40 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index f695f39..56ff725 100644
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
+	return x ^ (x >> 32);
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
