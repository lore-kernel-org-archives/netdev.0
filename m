From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv6: add ipv6_addr_hash() helper
Date: Wed, 18 Jul 2012 14:08:54 +0200
Message-ID: <1342613334.2626.2504.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Andrew McGregor <andrewmcgr@gmail.com>,
	Dave Taht <dave.taht@gmail.com>,
	Tom Herbert <therbert@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:58977 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753431Ab2GRMI7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 08:08:59 -0400
Received: by vbbff1 with SMTP id ff1so1012010vbb.19
        for <netdev@vger.kernel.org>; Wed, 18 Jul 2012 05:08:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Introduce ipv6_addr_hash() helper doing a XOR on all bits
of an IPv6 address, with an optimized x86_64 version.

Use it in flow dissector, as suggested by Andrew McGregor,
to reduce hash collision probabilities in fq_codel (and other
users of flow dissector)

As cleanups, use it in :

 net/sunrpc/svcauth_unix.c
 net/ipv6/ip6_tunnel.c
 net/ipv4/tcp_metrics.c

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Andrew McGregor <andrewmcgr@gmail.com>
Cc: Dave Taht <dave.taht@gmail.com>
Cc: Tom Herbert <therbert@google.com>
---
 include/net/ipv6.h        |   13 +++++++++++++
 net/core/flow_dissector.c |    5 +++--
 net/ipv4/tcp_metrics.c    |   15 +++------------
 net/ipv6/ip6_tunnel.c     |    4 +---
 net/sunrpc/svcauth_unix.c |   18 ++++++++----------
 5 files changed, 28 insertions(+), 27 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index f695f39..079cd9c 100644
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
index db32846..819b8eb 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -72,9 +72,7 @@ MODULE_ALIAS_NETDEV("ip6tnl0");
 
 #define HASH_SIZE  32
 
-#define HASH(addr) ((__force u32)((addr)->s6_addr32[0] ^ (addr)->s6_addr32[1] ^ \
-		     (addr)->s6_addr32[2] ^ (addr)->s6_addr32[3]) & \
-		    (HASH_SIZE - 1))
+#define HASH(addr) (ipv6_addr_hash(addr) & (HASH_SIZE - 1))
 
 static int ip6_tnl_dev_init(struct net_device *dev);
 static void ip6_tnl_dev_setup(struct net_device *dev);
diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index 2777fa8..e7e1dfe 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -109,18 +109,16 @@ static void ip_map_put(struct kref *kref)
  * IP addresses in reverse-endian (i.e. on a little-endian machine).
  * So use a trivial but reliable hash instead
  */
-static inline int hash_ip(__be32 ip)
+static inline int hash_ip(u32 ip)
 {
-	int hash = (__force u32)ip ^ ((__force u32)ip>>16);
-	return (hash ^ (hash>>8)) & 0xff;
+	ip ^= (ip >> 16);
+	ip ^= (ip >> 8);
+	return ip & 0xff;
 }
 #endif
-static inline int hash_ip6(struct in6_addr ip)
+static inline int hash_ip6(const struct in6_addr *ip)
 {
-	return (hash_ip(ip.s6_addr32[0]) ^
-		hash_ip(ip.s6_addr32[1]) ^
-		hash_ip(ip.s6_addr32[2]) ^
-		hash_ip(ip.s6_addr32[3]));
+	return hash_ip(ipv6_addr_hash(ip));
 }
 static int ip_map_match(struct cache_head *corig, struct cache_head *cnew)
 {
@@ -301,7 +299,7 @@ static struct ip_map *__ip_map_lookup(struct cache_detail *cd, char *class,
 	ip.m_addr = *addr;
 	ch = sunrpc_cache_lookup(cd, &ip.h,
 				 hash_str(class, IP_HASHBITS) ^
-				 hash_ip6(*addr));
+				 hash_ip6(addr));
 
 	if (ch)
 		return container_of(ch, struct ip_map, h);
@@ -331,7 +329,7 @@ static int __ip_map_update(struct cache_detail *cd, struct ip_map *ipm,
 	ip.h.expiry_time = expiry;
 	ch = sunrpc_cache_update(cd, &ip.h, &ipm->h,
 				 hash_str(ipm->m_class, IP_HASHBITS) ^
-				 hash_ip6(ipm->m_addr));
+				 hash_ip6(&ipm->m_addr));
 	if (!ch)
 		return -ENOMEM;
 	cache_put(ch, cd);
