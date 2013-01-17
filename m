From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next (V4) 11/11] ipv6: Complete neighbour entry removal
 from dst_entry.
Date: Fri, 18 Jan 2013 07:54:05 +0900
Message-ID: <50F8810D.5030103@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, xiyou.wangcong@gmail.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:44788 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754776Ab3AQWyH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 17:54:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CC: Cong Wang <xiyou.wangcong@gmail.com>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/ip6_fib.h   |    2 --
 net/ipv6/route.c        |   84 +----------------------------------------------
 net/ipv6/xfrm6_policy.c |    1 -
 3 files changed, 1 insertion(+), 86 deletions(-)

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
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index afc8386..3a562a1 100644
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
 
@@ -845,8 +824,6 @@ static struct rt6_info *rt6_alloc_cow(struct rt6_info *ort,
 	rt = ip6_rt_copy(ort, daddr);
 
 	if (rt) {
-		int attempts = !in_softirq();
-
 		if (!(rt->rt6i_flags & RTF_GATEWAY)) {
 			if (ort->rt6i_dst.plen != 128 &&
 			    ipv6_addr_equal(&ort->rt6i_dst.addr, daddr))
@@ -862,32 +839,6 @@ static struct rt6_info *rt6_alloc_cow(struct rt6_info *ort,
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
@@ -898,10 +849,8 @@ static struct rt6_info *rt6_alloc_clone(struct rt6_info *ort,
 {
 	struct rt6_info *rt = ip6_rt_copy(ort, daddr);
 
-	if (rt) {
+	if (rt)
 		rt->rt6i_flags |= RTF_CACHE;
-		rt->n = neigh_clone(ort->n);
-	}
 	return rt;
 }
 
@@ -1272,20 +1221,8 @@ struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
 		goto out;
 	}
 
-	if (neigh)
-		neigh_hold(neigh);
-	else {
-		neigh = ip6_neigh_lookup(&rt->dst, NULL, &fl6->daddr);
-		if (IS_ERR(neigh)) {
-			in6_dev_put(idev);
-			dst_free(&rt->dst);
-			return ERR_CAST(neigh);
-		}
-	}
-
 	rt->dst.flags |= DST_HOST;
 	rt->dst.output  = ip6_output;
-	rt->n = neigh;
 	atomic_set(&rt->dst.__refcnt, 1);
 	rt->rt6i_dst.addr = fl6->daddr;
 	rt->rt6i_dst.plen = 128;
@@ -1594,12 +1531,6 @@ int ip6_route_add(struct fib6_config *cfg)
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
@@ -1713,7 +1644,6 @@ static void rt6_do_redirect(struct dst_entry *dst, struct sock *sk, struct sk_bu
 	struct netevent_redirect netevent;
 	struct rt6_info *rt, *nrt = NULL;
 	struct ndisc_options ndopts;
-	struct neighbour *old_neigh;
 	struct inet6_dev *in6_dev;
 	struct neighbour *neigh;
 	struct rd_msg *msg;
@@ -1786,11 +1716,6 @@ static void rt6_do_redirect(struct dst_entry *dst, struct sock *sk, struct sk_bu
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
@@ -1811,7 +1736,6 @@ static void rt6_do_redirect(struct dst_entry *dst, struct sock *sk, struct sk_bu
 		nrt->rt6i_flags &= ~RTF_GATEWAY;
 
 	nrt->rt6i_gateway = *(struct in6_addr *)neigh->primary_key;
-	nrt->n = neigh_clone(neigh);
 
 	if (ip6_ins_rt(nrt))
 		goto out;
@@ -2125,7 +2049,6 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 {
 	struct net *net = dev_net(idev->dev);
 	struct rt6_info *rt = ip6_dst_alloc(net, net->loopback_dev, 0, NULL);
-	int err;
 
 	if (!rt) {
 		net_warn_ratelimited("Maximum number of routes reached, consider increasing route/max_size\n");
@@ -2144,11 +2067,6 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
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
