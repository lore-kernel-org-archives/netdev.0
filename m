From: David Miller <davem@davemloft.net>
Subject: [PATCH 16/19] ipv6: Store route neighbour in rt6_info struct.
Date: Tue, 03 Jul 2012 02:47:00 -0700 (PDT)
Message-ID: <20120703.024700.1627207600679312181.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36859 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932362Ab2GCJrC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2012 05:47:02 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 0E79158411D
	for <netdev@vger.kernel.org>; Tue,  3 Jul 2012 02:47:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This makes for a simplified conversion away from dst_get_neighbour*().

All code outside of ipv6 will use neigh lookups via dst_neigh_lookup*().

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ip6_fib.h   |    2 ++
 net/ipv6/ip6_output.c   |    8 ++++++--
 net/ipv6/route.c        |   42 ++++++++++++++++++++++++++----------------
 net/ipv6/xfrm6_policy.c |    1 +
 4 files changed, 35 insertions(+), 18 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index a192f78..0fedbd8 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -86,6 +86,8 @@ struct fib6_table;
 struct rt6_info {
 	struct dst_entry		dst;
 
+	struct neighbour		*n;
+
 	/*
 	 * Tail elements of dst_entry (__refcnt etc.)
 	 * and these elements (rarely used in hot path) are in
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index c94e4aa..6d9c0ab 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -88,6 +88,7 @@ static int ip6_finish_output2(struct sk_buff *skb)
 	struct dst_entry *dst = skb_dst(skb);
 	struct net_device *dev = dst->dev;
 	struct neighbour *neigh;
+	struct rt6_info *rt;
 
 	skb->protocol = htons(ETH_P_IPV6);
 	skb->dev = dev;
@@ -123,7 +124,8 @@ static int ip6_finish_output2(struct sk_buff *skb)
 	}
 
 	rcu_read_lock();
-	neigh = dst_get_neighbour_noref(dst);
+	rt = (struct rt6_info *) dst;
+	neigh = rt->n;
 	if (neigh) {
 		int res = dst_neigh_output(dst, neigh, skb);
 
@@ -944,6 +946,7 @@ static int ip6_dst_lookup_tail(struct sock *sk,
 	struct net *net = sock_net(sk);
 #ifdef CONFIG_IPV6_OPTIMISTIC_DAD
 	struct neighbour *n;
+	struct rt6_info *rt;
 #endif
 	int err;
 
@@ -972,7 +975,8 @@ static int ip6_dst_lookup_tail(struct sock *sk,
 	 * dst entry of the nexthop router
 	 */
 	rcu_read_lock();
-	n = dst_get_neighbour_noref(*dst);
+	rt = (struct rt6_info *) dst;
+	n = rt->n;
 	if (n && !(n->nud_state & NUD_VALID)) {
 		struct inet6_ifaddr *ifp;
 		struct flowi6 fl_gw6;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 24034d7..b4ecea0 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -155,7 +155,7 @@ static int rt6_bind_neighbour(struct rt6_info *rt, struct net_device *dev)
 		if (IS_ERR(n))
 			return PTR_ERR(n);
 	}
-	dst_set_neighbour(&rt->dst, n);
+	rt->n = n;
 
 	return 0;
 }
@@ -285,6 +285,9 @@ static void ip6_dst_destroy(struct dst_entry *dst)
 	struct rt6_info *rt = (struct rt6_info *)dst;
 	struct inet6_dev *idev = rt->rt6i_idev;
 
+	if (rt->n)
+		neigh_release(rt->n);
+
 	if (!(rt->dst.flags & DST_HOST))
 		dst_destroy_metrics_generic(dst);
 
@@ -335,12 +338,19 @@ static void ip6_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 	struct net_device *loopback_dev =
 		dev_net(dev)->loopback_dev;
 
-	if (dev != loopback_dev && idev && idev->dev == dev) {
-		struct inet6_dev *loopback_idev =
-			in6_dev_get(loopback_dev);
-		if (loopback_idev) {
-			rt->rt6i_idev = loopback_idev;
-			in6_dev_put(idev);
+	if (dev != loopback_dev) {
+		if (idev && idev->dev == dev) {
+			struct inet6_dev *loopback_idev =
+				in6_dev_get(loopback_dev);
+			if (loopback_idev) {
+				rt->rt6i_idev = loopback_idev;
+				in6_dev_put(idev);
+			}
+		}
+		if (rt->n && rt->n->dev == dev) {
+			rt->n->dev = loopback_dev;
+			dev_hold(loopback_dev);
+			dev_put(dev);
 		}
 	}
 }
@@ -430,7 +440,7 @@ static void rt6_probe(struct rt6_info *rt)
 	 * to no more than one per minute.
 	 */
 	rcu_read_lock();
-	neigh = rt ? dst_get_neighbour_noref(&rt->dst) : NULL;
+	neigh = rt ? rt->n : NULL;
 	if (!neigh || (neigh->nud_state & NUD_VALID))
 		goto out;
 	read_lock_bh(&neigh->lock);
@@ -477,7 +487,7 @@ static inline int rt6_check_neigh(struct rt6_info *rt)
 	int m;
 
 	rcu_read_lock();
-	neigh = dst_get_neighbour_noref(&rt->dst);
+	neigh = rt->n;
 	if (rt->rt6i_flags & RTF_NONEXTHOP ||
 	    !(rt->rt6i_flags & RTF_GATEWAY))
 		m = 1;
@@ -824,7 +834,7 @@ static struct rt6_info *rt6_alloc_clone(struct rt6_info *ort,
 
 	if (rt) {
 		rt->rt6i_flags |= RTF_CACHE;
-		dst_set_neighbour(&rt->dst, neigh_clone(dst_get_neighbour_noref_raw(&ort->dst)));
+		rt->n = neigh_clone(ort->n);
 	}
 	return rt;
 }
@@ -858,7 +868,7 @@ restart:
 	dst_hold(&rt->dst);
 	read_unlock_bh(&table->tb6_lock);
 
-	if (!dst_get_neighbour_noref_raw(&rt->dst) && !(rt->rt6i_flags & RTF_NONEXTHOP))
+	if (!rt->n && !(rt->rt6i_flags & RTF_NONEXTHOP))
 		nrt = rt6_alloc_cow(rt, &fl6->daddr, &fl6->saddr);
 	else if (!(rt->dst.flags & DST_HOST))
 		nrt = rt6_alloc_clone(rt, &fl6->daddr);
@@ -1178,7 +1188,7 @@ struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
 
 	rt->dst.flags |= DST_HOST;
 	rt->dst.output  = ip6_output;
-	dst_set_neighbour(&rt->dst, neigh);
+	rt->n = neigh;
 	atomic_set(&rt->dst.__refcnt, 1);
 	rt->rt6i_dst.addr = fl6->daddr;
 	rt->rt6i_dst.plen = 128;
@@ -1715,7 +1725,7 @@ void rt6_redirect(const struct in6_addr *dest, const struct in6_addr *src,
 	dst_confirm(&rt->dst);
 
 	/* Duplicate redirect: silently ignore. */
-	old_neigh = dst_get_neighbour_noref_raw(&rt->dst);
+	old_neigh = rt->n;
 	if (neigh == old_neigh)
 		goto out;
 
@@ -1728,7 +1738,7 @@ void rt6_redirect(const struct in6_addr *dest, const struct in6_addr *src,
 		nrt->rt6i_flags &= ~RTF_GATEWAY;
 
 	nrt->rt6i_gateway = *(struct in6_addr *)neigh->primary_key;
-	dst_set_neighbour(&nrt->dst, neigh_clone(neigh));
+	nrt->n = neigh_clone(neigh);
 
 	if (ip6_ins_rt(nrt))
 		goto out;
@@ -2441,7 +2451,7 @@ static int rt6_fill_node(struct net *net,
 		goto nla_put_failure;
 
 	rcu_read_lock();
-	n = dst_get_neighbour_noref(&rt->dst);
+	n = rt->n;
 	if (n) {
 		if (nla_put(skb, RTA_GATEWAY, 16, &n->primary_key) < 0) {
 			rcu_read_unlock();
@@ -2665,7 +2675,7 @@ static int rt6_info_route(struct rt6_info *rt, void *p_arg)
 	seq_puts(m, "00000000000000000000000000000000 00 ");
 #endif
 	rcu_read_lock();
-	n = dst_get_neighbour_noref(&rt->dst);
+	n = rt->n;
 	if (n) {
 		seq_printf(m, "%pi6", n->primary_key);
 	} else {
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index d749484..bb02038 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -103,6 +103,7 @@ static int xfrm6_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
 
 	/* Sheit... I remember I did this right. Apparently,
 	 * it was magically lost, so this code needs audit */
+	xdst->u.rt6.n = neigh_clone(rt->n);
 	xdst->u.rt6.rt6i_flags = rt->rt6i_flags & (RTF_ANYCAST |
 						   RTF_LOCAL);
 	xdst->u.rt6.rt6i_metric = rt->rt6i_metric;
-- 
1.7.10
