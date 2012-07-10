From: David Miller <davem@davemloft.net>
Subject: [PATCH 16/16] ipv4: Remove inetpeer from routes.
Date: Tue, 10 Jul 2012 08:07:58 -0700 (PDT)
Message-ID: <20120710.080758.854894946730256936.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38430 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755050Ab2GJPH7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 11:07:59 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id E9B2058662D
	for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 08:08:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


No longer used.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/route.h     |   57 --------------------------------------------
 net/ipv4/route.c        |   60 +++++------------------------------------------
 net/ipv4/xfrm4_policy.c |    7 ------
 3 files changed, 6 insertions(+), 118 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index c274494..5236236 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -40,7 +40,6 @@
 #define RT_CONN_FLAGS(sk)   (RT_TOS(inet_sk(sk)->tos) | sock_flag(sk, SOCK_LOCALROUTE))
 
 struct fib_nh;
-struct inet_peer;
 struct fib_info;
 struct rtable {
 	struct dst_entry	dst;
@@ -66,44 +65,9 @@ struct rtable {
 
 	/* Miscellaneous cached information */
 	u32			rt_pmtu;
-	unsigned long		_peer; /* long-living peer info */
 	struct fib_info		*fi; /* for client ref to shared metrics */
 };
 
-static inline struct inet_peer *rt_peer_ptr(struct rtable *rt)
-{
-	return inetpeer_ptr(rt->_peer);
-}
-
-static inline bool rt_has_peer(struct rtable *rt)
-{
-	return inetpeer_ptr_is_peer(rt->_peer);
-}
-
-static inline void __rt_set_peer(struct rtable *rt, struct inet_peer *peer)
-{
-	__inetpeer_ptr_set_peer(&rt->_peer, peer);
-}
-
-static inline bool rt_set_peer(struct rtable *rt, struct inet_peer *peer)
-{
-	return inetpeer_ptr_set_peer(&rt->_peer, peer);
-}
-
-static inline void rt_init_peer(struct rtable *rt, struct inet_peer_base *base)
-{
-	inetpeer_init_ptr(&rt->_peer, base);
-}
-
-static inline void rt_transfer_peer(struct rtable *rt, struct rtable *ort)
-{
-	rt->_peer = ort->_peer;
-	if (rt_has_peer(ort)) {
-		struct inet_peer *peer = rt_peer_ptr(ort);
-		atomic_inc(&peer->refcnt);
-	}
-}
-
 static inline bool rt_is_input_route(const struct rtable *rt)
 {
 	return rt->rt_route_iif != 0;
@@ -326,27 +290,6 @@ static inline struct rtable *ip_route_newports(struct flowi4 *fl4, struct rtable
 	return rt;
 }
 
-extern void rt_bind_peer(struct rtable *rt, __be32 daddr, int create);
-
-static inline struct inet_peer *__rt_get_peer(struct rtable *rt, __be32 daddr, int create)
-{
-	if (rt_has_peer(rt))
-		return rt_peer_ptr(rt);
-
-	rt_bind_peer(rt, daddr, create);
-	return (rt_has_peer(rt) ? rt_peer_ptr(rt) : NULL);
-}
-
-static inline struct inet_peer *rt_get_peer(struct rtable *rt, __be32 daddr)
-{
-	return __rt_get_peer(rt, daddr, 0);
-}
-
-static inline struct inet_peer *rt_get_peer_create(struct rtable *rt, __be32 daddr)
-{
-	return __rt_get_peer(rt, daddr, 1);
-}
-
 static inline int inet_iif(const struct sk_buff *skb)
 {
 	return skb_rtable(skb)->rt_iif;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 9cc00f8..95bfa1b 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -889,7 +889,6 @@ static void rt_cache_invalidate(struct net *net)
 
 	get_random_bytes(&shuffle, sizeof(shuffle));
 	atomic_add(shuffle + 1U, &net->ipv4.rt_genid);
-	inetpeer_invalidate_family(AF_INET);
 }
 
 /*
@@ -1216,22 +1215,6 @@ skip_hashing:
 	return rt;
 }
 
-void rt_bind_peer(struct rtable *rt, __be32 daddr, int create)
-{
-	struct inet_peer_base *base;
-	struct inet_peer *peer;
-
-	base = inetpeer_base_ptr(rt->_peer);
-	if (!base)
-		return;
-
-	peer = inet_getpeer_v4(base, daddr, create);
-	if (peer) {
-		if (!rt_set_peer(rt, peer))
-			inet_putpeer(peer);
-	}
-}
-
 /*
  * Peer allocation may fail only in serious out-of-memory conditions.  However
  * we still can generate some output.
@@ -1588,10 +1571,6 @@ static void ipv4_dst_destroy(struct dst_entry *dst)
 		fib_info_put(rt->fi);
 		rt->fi = NULL;
 	}
-	if (rt_has_peer(rt)) {
-		struct inet_peer *peer = rt_peer_ptr(rt);
-		inet_putpeer(peer);
-	}
 }
 
 
@@ -1711,26 +1690,11 @@ static unsigned int ipv4_mtu(const struct dst_entry *dst)
 static void rt_init_metrics(struct rtable *rt, const struct flowi4 *fl4,
 			    struct fib_info *fi)
 {
-	struct inet_peer_base *base;
-	struct inet_peer *peer;
-
-	base = inetpeer_base_ptr(rt->_peer);
-	BUG_ON(!base);
-
-	peer = inet_getpeer_v4(base, rt->rt_dst, 0);
-	if (peer) {
-		__rt_set_peer(rt, peer);
-		if (inet_metrics_new(peer))
-			memcpy(peer->metrics, fi->fib_metrics,
-			       sizeof(u32) * RTAX_MAX);
-		dst_init_metrics(&rt->dst, peer->metrics, false);
-	} else {
-		if (fi->fib_metrics != (u32 *) dst_default_metrics) {
-			rt->fi = fi;
-			atomic_inc(&fi->fib_clntref);
-		}
-		dst_init_metrics(&rt->dst, fi->fib_metrics, true);
+	if (fi->fib_metrics != (u32 *) dst_default_metrics) {
+		rt->fi = fi;
+		atomic_inc(&fi->fib_clntref);
 	}
+	dst_init_metrics(&rt->dst, fi->fib_metrics, true);
 }
 
 static void rt_set_nexthop(struct rtable *rt, const struct flowi4 *fl4,
@@ -1820,7 +1784,6 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	rth->rt_mark    = skb->mark;
 	rth->rt_pmtu	= 0;
 	rth->rt_gateway	= daddr;
-	rt_init_peer(rth, dev_net(dev)->ipv4.peers);
 	rth->fi = NULL;
 	if (our) {
 		rth->dst.input= ip_local_deliver;
@@ -1946,7 +1909,6 @@ static int __mkroute_input(struct sk_buff *skb,
 	rth->rt_mark    = skb->mark;
 	rth->rt_pmtu	= 0;
 	rth->rt_gateway	= daddr;
-	rt_init_peer(rth, &res->table->tb_peers);
 	rth->fi = NULL;
 
 	rth->dst.input = ip_forward;
@@ -2125,7 +2087,6 @@ local_input:
 	rth->rt_mark    = skb->mark;
 	rth->rt_pmtu	= 0;
 	rth->rt_gateway	= daddr;
-	rt_init_peer(rth, net->ipv4.peers);
 	rth->fi = NULL;
 	if (res.type == RTN_UNREACHABLE) {
 		rth->dst.input= ip_error;
@@ -2323,9 +2284,6 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 	rth->rt_mark    = fl4->flowi4_mark;
 	rth->rt_pmtu	= 0;
 	rth->rt_gateway = fl4->daddr;
-	rt_init_peer(rth, (res->table ?
-			   &res->table->tb_peers :
-			   dev_net(dev_out)->ipv4.peers));
 	rth->fi = NULL;
 
 	RT_CACHE_STAT_INC(out_slow_tot);
@@ -2662,7 +2620,6 @@ struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_or
 		rt->rt_dst = ort->rt_dst;
 		rt->rt_src = ort->rt_src;
 		rt->rt_gateway = ort->rt_gateway;
-		rt_transfer_peer(rt, ort);
 		rt->fi = ort->fi;
 		if (rt->fi)
 			atomic_inc(&rt->fi->fib_clntref);
@@ -2700,7 +2657,7 @@ static int rt_fill_info(struct net *net,
 	struct rtmsg *r;
 	struct nlmsghdr *nlh;
 	unsigned long expires = 0;
-	u32 id = 0, error;
+	u32 error;
 
 	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*r), flags);
 	if (nlh == NULL)
@@ -2753,11 +2710,6 @@ static int rt_fill_info(struct net *net,
 		goto nla_put_failure;
 
 	error = rt->dst.error;
-	if (rt_has_peer(rt)) {
-		const struct inet_peer *peer = rt_peer_ptr(rt);
-		inet_peer_refcheck(peer);
-		id = atomic_read(&peer->ip_id_count) & 0xffff;
-	}
 	expires = rt->dst.expires;
 	if (expires) {
 		if (time_before(jiffies, expires))
@@ -2792,7 +2744,7 @@ static int rt_fill_info(struct net *net,
 				goto nla_put_failure;
 	}
 
-	if (rtnl_put_cacheinfo(skb, &rt->dst, id, expires, error) < 0)
+	if (rtnl_put_cacheinfo(skb, &rt->dst, 0, expires, error) < 0)
 		goto nla_put_failure;
 
 	return nlmsg_end(skb, nlh);
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 951bcf3..87d3fcc 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -90,8 +90,6 @@ static int xfrm4_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
 	xdst->u.dst.dev = dev;
 	dev_hold(dev);
 
-	rt_transfer_peer(&xdst->u.rt, rt);
-
 	/* Sheit... I remember I did this right. Apparently,
 	 * it was magically lost, so this code needs audit */
 	xdst->u.rt.rt_flags = rt->rt_flags & (RTCF_BROADCAST | RTCF_MULTICAST |
@@ -210,11 +208,6 @@ static void xfrm4_dst_destroy(struct dst_entry *dst)
 
 	dst_destroy_metrics_generic(dst);
 
-	if (rt_has_peer(&xdst->u.rt)) {
-		struct inet_peer *peer = rt_peer_ptr(&xdst->u.rt);
-		inet_putpeer(peer);
-	}
-
 	xfrm_dst_destroy(xdst);
 }
 
-- 
1.7.10.4
