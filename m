From: David Miller <davem@davemloft.net>
Subject: [PATCH 4/4] net: Add ->neigh_lookup() operation to dst_ops
Date: Mon, 18 Jul 2011 01:25:24 -0700 (PDT)
Message-ID: <20110718.012524.2116364171633337910.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57642 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755019Ab1GRIZ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 04:25:26 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p6I8PODR028380
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 18 Jul 2011 01:25:25 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


In the future dst entries will be neigh-less.  In that environment we
need to have an easy transition point for current users of
dst->neighbour outside of the packet output fast path.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/arp.h         |    9 ---------
 include/net/dst.h         |    5 +++++
 include/net/dst_ops.h     |    1 +
 net/bridge/br_netfilter.c |    6 ++++++
 net/decnet/dn_route.c     |    7 +++++++
 net/ipv4/route.c          |   26 +++++++++++++++++++-------
 net/ipv6/route.c          |    7 +++++++
 net/xfrm/xfrm_policy.c    |    7 +++++++
 8 files changed, 52 insertions(+), 16 deletions(-)

diff --git a/include/net/arp.h b/include/net/arp.h
index 5e669e6..4979af8 100644
--- a/include/net/arp.h
+++ b/include/net/arp.h
@@ -38,15 +38,6 @@ static inline struct neighbour *__ipv4_neigh_lookup(struct neigh_table *tbl, str
 	return n;
 }
 
-static inline struct neighbour *ipv4_neigh_lookup(struct neigh_table *tbl, struct net_device *dev, const __be32 *pkey)
-{
-	struct neighbour *n = __ipv4_neigh_lookup(tbl, dev,
-						  *(__force u32 *)pkey);
-	if (n)
-		return n;
-	return neigh_create(tbl, pkey, dev);
-}
-
 extern void	arp_init(void);
 extern int	arp_find(unsigned char *haddr, struct sk_buff *skb);
 extern int	arp_ioctl(struct net *net, unsigned int cmd, void __user *arg);
diff --git a/include/net/dst.h b/include/net/dst.h
index 8147206..29e2557 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -387,6 +387,11 @@ static inline void dst_confirm(struct dst_entry *dst)
 	}
 }
 
+static inline struct neighbour *dst_neigh_lookup(const struct dst_entry *dst, const void *daddr)
+{
+	return dst->ops->neigh_lookup(dst, daddr);
+}
+
 static inline void dst_link_failure(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
diff --git a/include/net/dst_ops.h b/include/net/dst_ops.h
index dc07463..9adb998 100644
--- a/include/net/dst_ops.h
+++ b/include/net/dst_ops.h
@@ -26,6 +26,7 @@ struct dst_ops {
 	void			(*link_failure)(struct sk_buff *);
 	void			(*update_pmtu)(struct dst_entry *dst, u32 mtu);
 	int			(*local_out)(struct sk_buff *skb);
+	struct neighbour *	(*neigh_lookup)(const struct dst_entry *dst, const void *daddr);
 
 	struct kmem_cache	*kmem_cachep;
 
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index b1a5f97..d6ec372 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -109,11 +109,17 @@ static u32 *fake_cow_metrics(struct dst_entry *dst, unsigned long old)
 	return NULL;
 }
 
+static struct neighbour *fake_neigh_lookup(const struct dst_entry *dst, const void *daddr)
+{
+	return NULL;
+}
+
 static struct dst_ops fake_dst_ops = {
 	.family =		AF_INET,
 	.protocol =		cpu_to_be16(ETH_P_IP),
 	.update_pmtu =		fake_update_pmtu,
 	.cow_metrics =		fake_cow_metrics,
+	.neigh_lookup =		fake_neigh_lookup,
 };
 
 /*
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 9bd45fc..43450c1 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -116,6 +116,7 @@ static void dn_dst_destroy(struct dst_entry *);
 static struct dst_entry *dn_dst_negative_advice(struct dst_entry *);
 static void dn_dst_link_failure(struct sk_buff *);
 static void dn_dst_update_pmtu(struct dst_entry *dst, u32 mtu);
+static struct neighbour *dn_dst_neigh_lookup(const struct dst_entry *dst, const void *daddr);
 static int dn_route_input(struct sk_buff *);
 static void dn_run_flush(unsigned long dummy);
 
@@ -139,6 +140,7 @@ static struct dst_ops dn_dst_ops = {
 	.negative_advice =	dn_dst_negative_advice,
 	.link_failure =		dn_dst_link_failure,
 	.update_pmtu =		dn_dst_update_pmtu,
+	.neigh_lookup =		dn_dst_neigh_lookup,
 };
 
 static void dn_dst_destroy(struct dst_entry *dst)
@@ -827,6 +829,11 @@ static unsigned int dn_dst_default_mtu(const struct dst_entry *dst)
 	return dst->dev->mtu;
 }
 
+static struct neighbour *dn_dst_neigh_lookup(const struct dst_entry *dst, const void *daddr)
+{
+	return __neigh_lookup_errno(&dn_neigh_table, daddr, dst->dev);
+}
+
 static int dn_rt_set_next_hop(struct dn_route *rt, struct dn_fib_res *res)
 {
 	struct dn_fib_info *fi = res->fi;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 1d4cd3b..3313730 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -185,6 +185,8 @@ static u32 *ipv4_cow_metrics(struct dst_entry *dst, unsigned long old)
 	return p;
 }
 
+static struct neighbour *ipv4_neigh_lookup(const struct dst_entry *dst, const void *daddr);
+
 static struct dst_ops ipv4_dst_ops = {
 	.family =		AF_INET,
 	.protocol =		cpu_to_be16(ETH_P_IP),
@@ -199,6 +201,7 @@ static struct dst_ops ipv4_dst_ops = {
 	.link_failure =		ipv4_link_failure,
 	.update_pmtu =		ip_rt_update_pmtu,
 	.local_out =		__ip_local_out,
+	.neigh_lookup =		ipv4_neigh_lookup,
 };
 
 #define ECN_OR_COST(class)	TC_PRIO_##class
@@ -1008,22 +1011,30 @@ static int slow_chain_length(const struct rtable *head)
 	return length >> FRACT_BITS;
 }
 
-static int rt_bind_neighbour(struct rtable *rt)
+static struct neighbour *ipv4_neigh_lookup(const struct dst_entry *dst, const void *daddr)
 {
-	static const __be32 inaddr_any = 0;
-	struct net_device *dev = rt->dst.dev;
 	struct neigh_table *tbl = &arp_tbl;
-	const __be32 *nexthop;
+	static const __be32 inaddr_any = 0;
+	struct net_device *dev = dst->dev;
+	const __be32 *pkey = daddr;
 	struct neighbour *n;
 
 #if defined(CONFIG_ATM_CLIP) || defined(CONFIG_ATM_CLIP_MODULE)
 	if (dev->type == ARPHRD_ATM)
 		tbl = clip_tbl_hook;
 #endif
-	nexthop = &rt->rt_gateway;
 	if (dev->flags & (IFF_LOOPBACK | IFF_POINTOPOINT))
-		nexthop = &inaddr_any;
-	n = ipv4_neigh_lookup(tbl, dev, nexthop);
+		pkey = &inaddr_any;
+
+	n = __ipv4_neigh_lookup(tbl, dev, *(__force u32 *)pkey);
+	if (n)
+		return n;
+	return neigh_create(tbl, pkey, dev);
+}
+
+static int rt_bind_neighbour(struct rtable *rt)
+{
+	struct neighbour *n = ipv4_neigh_lookup(&rt->dst, &rt->rt_gateway);
 	if (IS_ERR(n))
 		return PTR_ERR(n);
 	dst_set_neighbour(&rt->dst, n);
@@ -2734,6 +2745,7 @@ static struct dst_ops ipv4_dst_blackhole_ops = {
 	.default_advmss		=	ipv4_default_advmss,
 	.update_pmtu		=	ipv4_rt_blackhole_update_pmtu,
 	.cow_metrics		=	ipv4_rt_blackhole_cow_metrics,
+	.neigh_lookup		=	ipv4_neigh_lookup,
 };
 
 struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_orig)
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 2998cb5..ddef80f 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -127,6 +127,11 @@ static u32 *ipv6_cow_metrics(struct dst_entry *dst, unsigned long old)
 	return p;
 }
 
+static struct neighbour *ip6_neigh_lookup(const struct dst_entry *dst, const void *daddr)
+{
+	return __neigh_lookup_errno(&nd_tbl, daddr, dst->dev);
+}
+
 static struct dst_ops ip6_dst_ops_template = {
 	.family			=	AF_INET6,
 	.protocol		=	cpu_to_be16(ETH_P_IPV6),
@@ -142,6 +147,7 @@ static struct dst_ops ip6_dst_ops_template = {
 	.link_failure		=	ip6_link_failure,
 	.update_pmtu		=	ip6_rt_update_pmtu,
 	.local_out		=	__ip6_local_out,
+	.neigh_lookup		=	ip6_neigh_lookup,
 };
 
 static unsigned int ip6_blackhole_default_mtu(const struct dst_entry *dst)
@@ -168,6 +174,7 @@ static struct dst_ops ip6_dst_blackhole_ops = {
 	.default_advmss		=	ip6_default_advmss,
 	.update_pmtu		=	ip6_rt_blackhole_update_pmtu,
 	.cow_metrics		=	ip6_rt_blackhole_cow_metrics,
+	.neigh_lookup		=	ip6_neigh_lookup,
 };
 
 static const u32 ip6_template_metrics[RTAX_MAX] = {
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 7803eb6..94fdcc7 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2385,6 +2385,11 @@ static unsigned int xfrm_default_mtu(const struct dst_entry *dst)
 	return dst_mtu(dst->path);
 }
 
+static struct neighbour *xfrm_neigh_lookup(const struct dst_entry *dst, const void *daddr)
+{
+	return dst_neigh_lookup(dst->path, daddr);
+}
+
 int xfrm_policy_register_afinfo(struct xfrm_policy_afinfo *afinfo)
 {
 	struct net *net;
@@ -2410,6 +2415,8 @@ int xfrm_policy_register_afinfo(struct xfrm_policy_afinfo *afinfo)
 			dst_ops->negative_advice = xfrm_negative_advice;
 		if (likely(dst_ops->link_failure == NULL))
 			dst_ops->link_failure = xfrm_link_failure;
+		if (likely(dst_ops->neigh_lookup == NULL))
+			dst_ops->neigh_lookup = xfrm_neigh_lookup;
 		if (likely(afinfo->garbage_collect == NULL))
 			afinfo->garbage_collect = __xfrm_garbage_collect;
 		xfrm_policy_afinfo[afinfo->family] = afinfo;
-- 
1.7.6

