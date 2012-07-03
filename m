From: David Miller <davem@davemloft.net>
Subject: [PATCH 05/19] net: Add optional SKB arg to dst_ops->neigh_lookup().
Date: Tue, 03 Jul 2012 02:46:14 -0700 (PDT)
Message-ID: <20120703.024614.302658222562307780.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36821 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754050Ab2GCJqP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2012 05:46:15 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id B9EF558411C
	for <netdev@vger.kernel.org>; Tue,  3 Jul 2012 02:46:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Causes the handler to use the daddr in the ipv4/ipv6 header when
the route gateway is unspecified (local subnet).

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/dst.h         |    8 +++++++-
 include/net/dst_ops.h     |    4 +++-
 net/bridge/br_netfilter.c |    4 +++-
 net/decnet/dn_route.c     |    8 ++++++--
 net/ipv4/route.c          |   14 ++++++++++----
 net/ipv6/route.c          |   14 ++++++++++----
 net/xfrm/xfrm_policy.c    |    6 ++++--
 7 files changed, 43 insertions(+), 15 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 84e7a3f..295a705 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -420,7 +420,13 @@ static inline int dst_neigh_output(struct dst_entry *dst, struct neighbour *n,
 
 static inline struct neighbour *dst_neigh_lookup(const struct dst_entry *dst, const void *daddr)
 {
-	return dst->ops->neigh_lookup(dst, daddr);
+	return dst->ops->neigh_lookup(dst, NULL, daddr);
+}
+
+static inline struct neighbour *dst_neigh_lookup_skb(const struct dst_entry *dst,
+						     struct sk_buff *skb)
+{
+	return dst->ops->neigh_lookup(dst, skb, NULL);
 }
 
 static inline void dst_link_failure(struct sk_buff *skb)
diff --git a/include/net/dst_ops.h b/include/net/dst_ops.h
index 3682a0a..4badc86 100644
--- a/include/net/dst_ops.h
+++ b/include/net/dst_ops.h
@@ -26,7 +26,9 @@ struct dst_ops {
 	void			(*link_failure)(struct sk_buff *);
 	void			(*update_pmtu)(struct dst_entry *dst, u32 mtu);
 	int			(*local_out)(struct sk_buff *skb);
-	struct neighbour *	(*neigh_lookup)(const struct dst_entry *dst, const void *daddr);
+	struct neighbour *	(*neigh_lookup)(const struct dst_entry *dst,
+						struct sk_buff *skb,
+						const void *daddr);
 
 	struct kmem_cache	*kmem_cachep;
 
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 20fa719..4378775 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -120,7 +120,9 @@ static u32 *fake_cow_metrics(struct dst_entry *dst, unsigned long old)
 	return NULL;
 }
 
-static struct neighbour *fake_neigh_lookup(const struct dst_entry *dst, const void *daddr)
+static struct neighbour *fake_neigh_lookup(const struct dst_entry *dst,
+					   struct sk_buff *skb,
+					   const void *daddr)
 {
 	return NULL;
 }
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 2493ed5..60e4c6e 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -117,7 +117,9 @@ static void dn_dst_destroy(struct dst_entry *);
 static struct dst_entry *dn_dst_negative_advice(struct dst_entry *);
 static void dn_dst_link_failure(struct sk_buff *);
 static void dn_dst_update_pmtu(struct dst_entry *dst, u32 mtu);
-static struct neighbour *dn_dst_neigh_lookup(const struct dst_entry *dst, const void *daddr);
+static struct neighbour *dn_dst_neigh_lookup(const struct dst_entry *dst,
+					     struct sk_buff *skb,
+					     const void *daddr);
 static int dn_route_input(struct sk_buff *);
 static void dn_run_flush(unsigned long dummy);
 
@@ -828,7 +830,9 @@ static unsigned int dn_dst_mtu(const struct dst_entry *dst)
 	return mtu ? : dst->dev->mtu;
 }
 
-static struct neighbour *dn_dst_neigh_lookup(const struct dst_entry *dst, const void *daddr)
+static struct neighbour *dn_dst_neigh_lookup(const struct dst_entry *dst,
+					     struct sk_buff *skb,
+					     const void *daddr)
 {
 	return __neigh_lookup_errno(&dn_neigh_table, daddr, dst->dev);
 }
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index bae3638..7453dfc 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -188,7 +188,9 @@ static u32 *ipv4_cow_metrics(struct dst_entry *dst, unsigned long old)
 	return p;
 }
 
-static struct neighbour *ipv4_neigh_lookup(const struct dst_entry *dst, const void *daddr);
+static struct neighbour *ipv4_neigh_lookup(const struct dst_entry *dst,
+					   struct sk_buff *skb,
+					   const void *daddr);
 
 static struct dst_ops ipv4_dst_ops = {
 	.family =		AF_INET,
@@ -1088,7 +1090,9 @@ static int slow_chain_length(const struct rtable *head)
 	return length >> FRACT_BITS;
 }
 
-static struct neighbour *ipv4_neigh_lookup(const struct dst_entry *dst, const void *daddr)
+static struct neighbour *ipv4_neigh_lookup(const struct dst_entry *dst,
+					   struct sk_buff *skb,
+					   const void *daddr)
 {
 	struct net_device *dev = dst->dev;
 	const __be32 *pkey = daddr;
@@ -1098,6 +1102,8 @@ static struct neighbour *ipv4_neigh_lookup(const struct dst_entry *dst, const vo
 	rt = (const struct rtable *) dst;
 	if (rt->rt_gateway)
 		pkey = (const __be32 *) &rt->rt_gateway;
+	else if (skb)
+		pkey = &ip_hdr(skb)->daddr;
 
 	n = __ipv4_neigh_lookup(dev, *(__force u32 *)pkey);
 	if (n)
@@ -1107,7 +1113,7 @@ static struct neighbour *ipv4_neigh_lookup(const struct dst_entry *dst, const vo
 
 static int rt_bind_neighbour(struct rtable *rt)
 {
-	struct neighbour *n = ipv4_neigh_lookup(&rt->dst, &rt->rt_gateway);
+	struct neighbour *n = ipv4_neigh_lookup(&rt->dst, NULL, &rt->rt_gateway);
 	if (IS_ERR(n))
 		return PTR_ERR(n);
 	dst_set_neighbour(&rt->dst, n);
@@ -1388,7 +1394,7 @@ static void check_peer_redir(struct dst_entry *dst, struct inet_peer *peer)
 
 	rt->rt_gateway = peer->redirect_learned.a4;
 
-	n = ipv4_neigh_lookup(&rt->dst, &rt->rt_gateway);
+	n = ipv4_neigh_lookup(&rt->dst, NULL, &rt->rt_gateway);
 	if (IS_ERR(n)) {
 		rt->rt_gateway = orig_gw;
 		return;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index c518e4e..4b581c6 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -120,21 +120,27 @@ static u32 *ipv6_cow_metrics(struct dst_entry *dst, unsigned long old)
 	return p;
 }
 
-static inline const void *choose_neigh_daddr(struct rt6_info *rt, const void *daddr)
+static inline const void *choose_neigh_daddr(struct rt6_info *rt,
+					     struct sk_buff *skb,
+					     const void *daddr)
 {
 	struct in6_addr *p = &rt->rt6i_gateway;
 
 	if (!ipv6_addr_any(p))
 		return (const void *) p;
+	else if (skb)
+		return &ipv6_hdr(skb)->daddr;
 	return daddr;
 }
 
-static struct neighbour *ip6_neigh_lookup(const struct dst_entry *dst, const void *daddr)
+static struct neighbour *ip6_neigh_lookup(const struct dst_entry *dst,
+					  struct sk_buff *skb,
+					  const void *daddr)
 {
 	struct rt6_info *rt = (struct rt6_info *) dst;
 	struct neighbour *n;
 
-	daddr = choose_neigh_daddr(rt, daddr);
+	daddr = choose_neigh_daddr(rt, skb, daddr);
 	n = __ipv6_neigh_lookup(&nd_tbl, dst->dev, daddr);
 	if (n)
 		return n;
@@ -1162,7 +1168,7 @@ struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
 	if (neigh)
 		neigh_hold(neigh);
 	else {
-		neigh = ip6_neigh_lookup(&rt->dst, &fl6->daddr);
+		neigh = ip6_neigh_lookup(&rt->dst, NULL, &fl6->daddr);
 		if (IS_ERR(neigh)) {
 			in6_dev_put(idev);
 			dst_free(&rt->dst);
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index ccfbd32..a28a3f9 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2404,9 +2404,11 @@ static unsigned int xfrm_mtu(const struct dst_entry *dst)
 	return mtu ? : dst_mtu(dst->path);
 }
 
-static struct neighbour *xfrm_neigh_lookup(const struct dst_entry *dst, const void *daddr)
+static struct neighbour *xfrm_neigh_lookup(const struct dst_entry *dst,
+					   struct sk_buff *skb,
+					   const void *daddr)
 {
-	return dst_neigh_lookup(dst->path, daddr);
+	return dst->path->ops->neigh_lookup(dst, skb, daddr);
 }
 
 int xfrm_policy_register_afinfo(struct xfrm_policy_afinfo *afinfo)
-- 
1.7.10
