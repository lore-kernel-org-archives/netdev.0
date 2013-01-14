From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [RFC net-next] ipv6 route: Do not attach neighbour on route.
Date: Tue, 15 Jan 2013 05:00:37 +0900
Message-ID: <50F463E5.7070206@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:40028 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758566Ab3ANUAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2013 15:00:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Not tested, just an RFC.
Depends on previous new_neigh removal from netevent patch (sorry).
 
--yoshfuji

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/ip6_fib.h   |    2 -
 include/net/ip6_route.h |    8 ++++
 net/ipv6/ip6_output.c   |   20 ++++++--
 net/ipv6/route.c        |  120 ++++++++++++-----------------------------------
 net/ipv6/xfrm6_policy.c |    1 -
 5 files changed, 52 insertions(+), 99 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index fdc48a9..6919a50 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -89,8 +89,6 @@ struct fib6_table;
 struct rt6_info {
 	struct dst_entry		dst;
 
-	struct neighbour		*n;
-
 	/*
 	 * Tail elements of dst_entry (__refcnt etc.)
 	 * and these elements (rarely used in hot path) are in
diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 27d8318..439928d 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -21,6 +21,7 @@ struct route_info {
 #include <net/flow.h>
 #include <net/ip6_fib.h>
 #include <net/sock.h>
+#include <linux/route.h>
 #include <linux/ip.h>
 #include <linux/ipv6.h>
 
@@ -137,6 +138,13 @@ extern void ip6_sk_update_pmtu(struct sk_buff *skb, struct sock *sk,
 extern void ip6_redirect(struct sk_buff *skb, struct net *net, int oif, u32 mark);
 extern void ip6_sk_redirect(struct sk_buff *skb, struct sock *sk);
 
+static inline struct in6_addr *rt6_nexthop(struct rt6_info *rt, struct in6_addr *dst)
+{
+	if (rt->rt6i_flags & RTF_GATEWAY)
+		return &rt->rt6i_gateway;
+	return dst;
+}
+
 struct netlink_callback;
 
 struct rt6_rtnl_dump_arg {
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 9581ffa..af2376d 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -123,10 +123,17 @@ static int ip6_finish_output2(struct sk_buff *skb)
 				skb->len);
 	}
 
+
 	rt = (struct rt6_info *) dst;
-	neigh = rt->n;
-	if (neigh)
-		return dst_neigh_output(dst, neigh, skb);
+	rcu_read_lock_bh();
+	neigh = __ipv6_neigh_lookup_noref(rt->rt6i_idev->dev,
+					  rt6_nexthop(rt, &ipv6_hdr(skb)->daddr));
+	if (neigh) {
+		int ret = dst_neigh_output(dst, neigh, skb);
+		rcu_read_unlock_bh();
+		return ret;
+	}
+	rcu_read_unlock_bh();
 
 	IP6_INC_STATS_BH(dev_net(dst->dev),
 			 ip6_dst_idev(dst), IPSTATS_MIB_OUTNOROUTES);
@@ -912,9 +919,12 @@ static int ip6_dst_lookup_tail(struct sock *sk,
 	 * dst entry and replace it instead with the
 	 * dst entry of the nexthop router
 	 */
+	rcu_read_lock_bh();
 	rt = (struct rt6_info *) *dst;
-	n = rt->n;
-	if (n && !(n->nud_state & NUD_VALID)) {
+	n = __ipv6_neigh_lookup_noref(rt->rt6i_idev->dev, rt6_nexthop(rt, &fl6->daddr));
+	err = n && n->nud_state & NUD_VALID ? 0 : -EINVAL;
+	rcu_read_unlock_bh();
+	if (!err) {
 		struct inet6_ifaddr *ifp;
 		struct flowi6 fl_gw6;
 		int redirect;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 6856e56..b57d0b5 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -151,19 +151,6 @@ static struct neighbour *ip6_neigh_lookup(const struct dst_entry *dst,
 	return neigh_create(&nd_tbl, daddr, dst->dev);
 }
 
-static int rt6_bind_neighbour(struct rt6_info *rt, struct net_device *dev)
-{
-	struct neighbour *n = __ipv6_neigh_lookup(dev, &rt->rt6i_gateway);
-	if (!n) {
-		n = neigh_create(&nd_tbl, &rt->rt6i_gateway, dev);
-		if (IS_ERR(n))
-			return PTR_ERR(n);
-	}
-	rt->n = n;
-
-	return 0;
-}
-
 static struct dst_ops ip6_dst_ops_template = {
 	.family			=	AF_INET6,
 	.protocol		=	cpu_to_be16(ETH_P_IPV6),
@@ -301,9 +288,6 @@ static void ip6_dst_destroy(struct dst_entry *dst)
 	struct rt6_info *rt = (struct rt6_info *)dst;
 	struct inet6_dev *idev = rt->rt6i_idev;
 
-	if (rt->n)
-		neigh_release(rt->n);
-
 	if (!(rt->dst.flags & DST_HOST))
 		dst_destroy_metrics_generic(dst);
 
@@ -354,11 +338,6 @@ static void ip6_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 				in6_dev_put(idev);
 			}
 		}
-		if (rt->n && rt->n->dev == dev) {
-			rt->n->dev = loopback_dev;
-			dev_hold(loopback_dev);
-			dev_put(dev);
-		}
 	}
 }
 
@@ -498,24 +477,32 @@ static void rt6_probe(struct rt6_info *rt)
 	 * Router Reachability Probe MUST be rate-limited
 	 * to no more than one per minute.
 	 */
-	neigh = rt ? rt->n : NULL;
-	if (!neigh || (neigh->nud_state & NUD_VALID))
+	rcu_read_lock_bh();
+	neigh = __ipv6_neigh_lookup_noref(rt->rt6i_idev->dev, &rt->rt6i_gateway);
+	if (!neigh || neigh->nud_state & NUD_VALID) {
+		rcu_read_unlock_bh();
 		return;
-	read_lock_bh(&neigh->lock);
+	}
+	read_lock(&neigh->lock);
 	if (!(neigh->nud_state & NUD_VALID) &&
 	    time_after(jiffies, neigh->updated + rt->rt6i_idev->cnf.rtr_probe_interval)) {
 		struct in6_addr mcaddr;
 		struct in6_addr *target;
 
 		neigh->updated = jiffies;
-		read_unlock_bh(&neigh->lock);
+
+		neigh_hold(neigh);
+
+		read_unlock(&neigh->lock);
 
 		target = (struct in6_addr *)&neigh->primary_key;
 		addrconf_addr_solict_mult(target, &mcaddr);
 		ndisc_send_ns(rt->dst.dev, NULL, target, &mcaddr, NULL);
 	} else {
-		read_unlock_bh(&neigh->lock);
+		read_unlock(&neigh->lock);
 	}
+	rcu_read_unlock_bh();
+	neigh_release(neigh);
 }
 #else
 static inline void rt6_probe(struct rt6_info *rt)
@@ -542,20 +529,25 @@ static inline bool rt6_check_neigh(struct rt6_info *rt)
 	struct neighbour *neigh;
 	bool ret = false;
 
-	neigh = rt->n;
 	if (rt->rt6i_flags & RTF_NONEXTHOP ||
-	    !(rt->rt6i_flags & RTF_GATEWAY))
+	    !(rt->rt6i_flags & RTF_GATEWAY)) {
 		ret = true;
-	else if (neigh) {
-		read_lock_bh(&neigh->lock);
+		goto out;
+	}
+	rcu_read_lock_bh();
+	neigh = __ipv6_neigh_lookup_noref(rt->rt6i_idev->dev, &rt->rt6i_gateway);
+	if (neigh) {
+		read_lock(&neigh->lock);
 		if (neigh->nud_state & NUD_VALID)
 			ret = true;
 #ifdef CONFIG_IPV6_ROUTER_PREF
 		else if (!(neigh->nud_state & NUD_FAILED))
 			ret = true;
 #endif
-		read_unlock_bh(&neigh->lock);
+		read_unlock(&neigh->lock);
 	}
+	rcu_read_unlock_bh();
+out:
 	return ret;
 }
 
@@ -831,8 +823,6 @@ static struct rt6_info *rt6_alloc_cow(struct rt6_info *ort,
 	rt = ip6_rt_copy(ort, daddr);
 
 	if (rt) {
-		int attempts = !in_softirq();
-
 		if (!(rt->rt6i_flags & RTF_GATEWAY)) {
 			if (ort->rt6i_dst.plen != 128 &&
 			    ipv6_addr_equal(&ort->rt6i_dst.addr, daddr))
@@ -848,32 +838,6 @@ static struct rt6_info *rt6_alloc_cow(struct rt6_info *ort,
 			rt->rt6i_src.plen = 128;
 		}
 #endif
-
-	retry:
-		if (rt6_bind_neighbour(rt, rt->dst.dev)) {
-			struct net *net = dev_net(rt->dst.dev);
-			int saved_rt_min_interval =
-				net->ipv6.sysctl.ip6_rt_gc_min_interval;
-			int saved_rt_elasticity =
-				net->ipv6.sysctl.ip6_rt_gc_elasticity;
-
-			if (attempts-- > 0) {
-				net->ipv6.sysctl.ip6_rt_gc_elasticity = 1;
-				net->ipv6.sysctl.ip6_rt_gc_min_interval = 0;
-
-				ip6_dst_gc(&net->ipv6.ip6_dst_ops);
-
-				net->ipv6.sysctl.ip6_rt_gc_elasticity =
-					saved_rt_elasticity;
-				net->ipv6.sysctl.ip6_rt_gc_min_interval =
-					saved_rt_min_interval;
-				goto retry;
-			}
-
-			net_warn_ratelimited("Neighbour table overflow\n");
-			dst_free(&rt->dst);
-			return NULL;
-		}
 	}
 
 	return rt;
@@ -884,10 +848,8 @@ static struct rt6_info *rt6_alloc_clone(struct rt6_info *ort,
 {
 	struct rt6_info *rt = ip6_rt_copy(ort, daddr);
 
-	if (rt) {
+	if (rt)
 		rt->rt6i_flags |= RTF_CACHE;
-		rt->n = neigh_clone(ort->n);
-	}
 	return rt;
 }
 
@@ -921,7 +883,7 @@ restart:
 	dst_hold(&rt->dst);
 	read_unlock_bh(&table->tb6_lock);
 
-	if (!rt->n && !(rt->rt6i_flags & RTF_NONEXTHOP))
+	if (!(rt->rt6i_flags & (RTF_GATEWAY | RTF_NONEXTHOP)))
 		nrt = rt6_alloc_cow(rt, &fl6->daddr, &fl6->saddr);
 	else if (!(rt->dst.flags & DST_HOST))
 		nrt = rt6_alloc_clone(rt, &fl6->daddr);
@@ -1271,7 +1233,6 @@ struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
 
 	rt->dst.flags |= DST_HOST;
 	rt->dst.output  = ip6_output;
-	rt->n = neigh;
 	atomic_set(&rt->dst.__refcnt, 1);
 	rt->rt6i_dst.addr = fl6->daddr;
 	rt->rt6i_dst.plen = 128;
@@ -1580,12 +1541,6 @@ int ip6_route_add(struct fib6_config *cfg)
 	} else
 		rt->rt6i_prefsrc.plen = 0;
 
-	if (cfg->fc_flags & (RTF_GATEWAY | RTF_NONEXTHOP)) {
-		err = rt6_bind_neighbour(rt, dev);
-		if (err)
-			goto out;
-	}
-
 	rt->rt6i_flags = cfg->fc_flags;
 
 install_route:
@@ -1699,7 +1654,6 @@ static void rt6_do_redirect(struct dst_entry *dst, struct sock *sk, struct sk_bu
 	struct netevent_redirect netevent;
 	struct rt6_info *rt, *nrt = NULL;
 	struct ndisc_options ndopts;
-	struct neighbour *old_neigh;
 	struct inet6_dev *in6_dev;
 	struct neighbour *neigh;
 	struct rd_msg *msg;
@@ -1772,11 +1726,6 @@ static void rt6_do_redirect(struct dst_entry *dst, struct sock *sk, struct sk_bu
 	if (!neigh)
 		return;
 
-	/* Duplicate redirect: silently ignore. */
-	old_neigh = rt->n;
-	if (neigh == old_neigh)
-		goto out;
-
 	/*
 	 *	We have finally decided to accept it.
 	 */
@@ -1797,7 +1746,6 @@ static void rt6_do_redirect(struct dst_entry *dst, struct sock *sk, struct sk_bu
 		nrt->rt6i_flags &= ~RTF_GATEWAY;
 
 	nrt->rt6i_gateway = *(struct in6_addr *)neigh->primary_key;
-	nrt->n = neigh_clone(neigh);
 
 	if (ip6_ins_rt(nrt))
 		goto out;
@@ -2111,7 +2059,6 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 {
 	struct net *net = dev_net(idev->dev);
 	struct rt6_info *rt = ip6_dst_alloc(net, net->loopback_dev, 0, NULL);
-	int err;
 
 	if (!rt) {
 		net_warn_ratelimited("Maximum number of routes reached, consider increasing route/max_size\n");
@@ -2130,11 +2077,6 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 		rt->rt6i_flags |= RTF_ANYCAST;
 	else
 		rt->rt6i_flags |= RTF_LOCAL;
-	err = rt6_bind_neighbour(rt, rt->dst.dev);
-	if (err) {
-		dst_free(&rt->dst);
-		return ERR_PTR(err);
-	}
 
 	rt->rt6i_dst.addr = *addr;
 	rt->rt6i_dst.plen = 128;
@@ -2480,7 +2422,6 @@ static int rt6_fill_node(struct net *net,
 	struct nlmsghdr *nlh;
 	long expires;
 	u32 table;
-	struct neighbour *n;
 
 	if (prefix) {	/* user wants prefix routes only */
 		if (!(rt->rt6i_flags & RTF_PREFIX_RT)) {
@@ -2593,9 +2534,8 @@ static int rt6_fill_node(struct net *net,
 	if (rtnetlink_put_metrics(skb, dst_metrics_ptr(&rt->dst)) < 0)
 		goto nla_put_failure;
 
-	n = rt->n;
-	if (n) {
-		if (nla_put(skb, RTA_GATEWAY, 16, &n->primary_key) < 0)
+	if (rt->rt6i_flags & RTF_GATEWAY) {
+		if (nla_put(skb, RTA_GATEWAY, 16, &rt->rt6i_gateway) < 0)
 			goto nla_put_failure;
 	}
 
@@ -2790,7 +2730,6 @@ struct rt6_proc_arg
 static int rt6_info_route(struct rt6_info *rt, void *p_arg)
 {
 	struct seq_file *m = p_arg;
-	struct neighbour *n;
 
 	seq_printf(m, "%pi6 %02x ", &rt->rt6i_dst.addr, rt->rt6i_dst.plen);
 
@@ -2799,9 +2738,8 @@ static int rt6_info_route(struct rt6_info *rt, void *p_arg)
 #else
 	seq_puts(m, "00000000000000000000000000000000 00 ");
 #endif
-	n = rt->n;
-	if (n) {
-		seq_printf(m, "%pi6", n->primary_key);
+	if (rt->rt6i_flags & RTF_GATEWAY) {
+		seq_printf(m, "%pi6", &rt->rt6i_gateway);
 	} else {
 		seq_puts(m, "00000000000000000000000000000000");
 	}
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index c984413..1282737 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -110,7 +110,6 @@ static int xfrm6_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
 
 	/* Sheit... I remember I did this right. Apparently,
 	 * it was magically lost, so this code needs audit */
-	xdst->u.rt6.n = neigh_clone(rt->n);
 	xdst->u.rt6.rt6i_flags = rt->rt6i_flags & (RTF_ANYCAST |
 						   RTF_LOCAL);
 	xdst->u.rt6.rt6i_metric = rt->rt6i_metric;
-- 
1.7.9.5
