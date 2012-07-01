From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/5] ipv4: Remove rt_key_{src,dst,tos} from struct rtable.
Date: Sun, 01 Jul 2012 05:02:56 -0700 (PDT)
Message-ID: <20120701.050256.248905305325596182.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48345 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932239Ab2GAMC4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2012 08:02:56 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 4E7BA583764
	for <netdev@vger.kernel.org>; Sun,  1 Jul 2012 05:02:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


They are always used in contexts where they can be reconstituted,
or where the finally resolved rt->rt_{src,dst} is semantically
equivalent.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/route.h     |    5 -----
 net/ipv4/route.c        |   39 +++++++++------------------------------
 net/ipv4/xfrm4_policy.c |    3 ---
 3 files changed, 9 insertions(+), 38 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index 04c1b7f..c5f2955 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -45,14 +45,9 @@ struct fib_info;
 struct rtable {
 	struct dst_entry	dst;
 
-	/* Lookup key. */
-	__be32			rt_key_dst;
-	__be32			rt_key_src;
-
 	int			rt_genid;
 	unsigned int		rt_flags;
 	__u16			rt_type;
-	__u8			rt_key_tos;
 
 	__be32			rt_dst;	/* Path destination	*/
 	__be32			rt_src;	/* Path source		*/
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 4377e01..ec38892 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1219,12 +1219,9 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 #endif
 	rth->dst.output = ip_rt_bug;
 
-	rth->rt_key_dst	= daddr;
-	rth->rt_key_src	= saddr;
 	rth->rt_genid	= rt_genid(dev_net(dev));
 	rth->rt_flags	= RTCF_MULTICAST;
 	rth->rt_type	= RTN_MULTICAST;
-	rth->rt_key_tos	= tos;
 	rth->rt_dst	= daddr;
 	rth->rt_src	= saddr;
 	rth->rt_route_iif = dev->ifindex;
@@ -1344,12 +1341,9 @@ static int __mkroute_input(struct sk_buff *skb,
 		goto cleanup;
 	}
 
-	rth->rt_key_dst	= daddr;
-	rth->rt_key_src	= saddr;
 	rth->rt_genid = rt_genid(dev_net(rth->dst.dev));
 	rth->rt_flags = flags;
 	rth->rt_type = res->type;
-	rth->rt_key_tos	= tos;
 	rth->rt_dst	= daddr;
 	rth->rt_src	= saddr;
 	rth->rt_route_iif = in_dev->dev->ifindex;
@@ -1518,12 +1512,9 @@ local_input:
 	rth->dst.tclassid = itag;
 #endif
 
-	rth->rt_key_dst	= daddr;
-	rth->rt_key_src	= saddr;
 	rth->rt_genid = rt_genid(net);
 	rth->rt_flags 	= flags|RTCF_LOCAL;
 	rth->rt_type	= res.type;
-	rth->rt_key_tos	= tos;
 	rth->rt_dst	= daddr;
 	rth->rt_src	= saddr;
 	rth->rt_route_iif = dev->ifindex;
@@ -1626,9 +1617,7 @@ EXPORT_SYMBOL(ip_route_input);
 
 /* called with rcu_read_lock() */
 static struct rtable *__mkroute_output(const struct fib_result *res,
-				       const struct flowi4 *fl4,
-				       __be32 orig_daddr, __be32 orig_saddr,
-				       int orig_oif, __u8 orig_rtos,
+				       const struct flowi4 *fl4, int orig_oif,
 				       struct net_device *dev_out,
 				       unsigned int flags)
 {
@@ -1679,12 +1668,9 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 
 	rth->dst.output = ip_output;
 
-	rth->rt_key_dst	= orig_daddr;
-	rth->rt_key_src	= orig_saddr;
 	rth->rt_genid = rt_genid(dev_net(dev_out));
 	rth->rt_flags	= flags;
 	rth->rt_type	= type;
-	rth->rt_key_tos	= orig_rtos;
 	rth->rt_dst	= fl4->daddr;
 	rth->rt_src	= fl4->saddr;
 	rth->rt_route_iif = 0;
@@ -1738,8 +1724,6 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 	unsigned int flags = 0;
 	struct fib_result res;
 	struct rtable *rth;
-	__be32 orig_daddr;
-	__be32 orig_saddr;
 	int orig_oif;
 
 	res.fi		= NULL;
@@ -1748,8 +1732,6 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 	res.r		= NULL;
 #endif
 
-	orig_daddr = fl4->daddr;
-	orig_saddr = fl4->saddr;
 	orig_oif = fl4->flowi4_oif;
 
 	fl4->flowi4_iif = net->loopback_dev->ifindex;
@@ -1911,8 +1893,7 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 
 
 make_route:
-	rth = __mkroute_output(&res, fl4, orig_daddr, orig_saddr, orig_oif,
-			       tos, dev_out, flags);
+	rth = __mkroute_output(&res, fl4, orig_oif, dev_out, flags);
 	if (!IS_ERR(rth))
 		rth = rt_finalize(rth, NULL);
 
@@ -1973,9 +1954,6 @@ struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_or
 		if (new->dev)
 			dev_hold(new->dev);
 
-		rt->rt_key_dst = ort->rt_key_dst;
-		rt->rt_key_src = ort->rt_key_src;
-		rt->rt_key_tos = ort->rt_key_tos;
 		rt->rt_route_iif = ort->rt_route_iif;
 		rt->rt_iif = ort->rt_iif;
 		rt->rt_oif = ort->rt_oif;
@@ -2017,7 +1995,7 @@ struct rtable *ip_route_output_flow(struct net *net, struct flowi4 *flp4,
 }
 EXPORT_SYMBOL_GPL(ip_route_output_flow);
 
-static int rt_fill_info(struct net *net,
+static int rt_fill_info(struct net *net,  __be32 src, u8 tos,
 			struct sk_buff *skb, u32 pid, u32 seq, int event,
 			int nowait, unsigned int flags)
 {
@@ -2035,7 +2013,7 @@ static int rt_fill_info(struct net *net,
 	r->rtm_family	 = AF_INET;
 	r->rtm_dst_len	= 32;
 	r->rtm_src_len	= 0;
-	r->rtm_tos	= rt->rt_key_tos;
+	r->rtm_tos	= tos;
 	r->rtm_table	= RT_TABLE_MAIN;
 	if (nla_put_u32(skb, RTA_TABLE, RT_TABLE_MAIN))
 		goto nla_put_failure;
@@ -2048,9 +2026,9 @@ static int rt_fill_info(struct net *net,
 
 	if (nla_put_be32(skb, RTA_DST, rt->rt_dst))
 		goto nla_put_failure;
-	if (rt->rt_key_src) {
+	if (src) {
 		r->rtm_src_len = 32;
-		if (nla_put_be32(skb, RTA_SRC, rt->rt_key_src))
+		if (nla_put_be32(skb, RTA_SRC, src))
 			goto nla_put_failure;
 	}
 	if (rt->dst.dev &&
@@ -2062,7 +2040,7 @@ static int rt_fill_info(struct net *net,
 		goto nla_put_failure;
 #endif
 	if (!rt_is_input_route(rt) &&
-	    rt->rt_src != rt->rt_key_src) {
+	    rt->rt_src != src) {
 		if (nla_put_be32(skb, RTA_PREFSRC, rt->rt_src))
 			goto nla_put_failure;
 	}
@@ -2213,7 +2191,8 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh, void
 	if (rtm->rtm_flags & RTM_F_NOTIFY)
 		rt->rt_flags |= RTCF_NOTIFY;
 
-	err = rt_fill_info(net, skb, NETLINK_CB(in_skb).pid, nlh->nlmsg_seq,
+	err = rt_fill_info(net, src, rtm->rtm_tos, skb,
+			   NETLINK_CB(in_skb).pid, nlh->nlmsg_seq,
 			   RTM_NEWROUTE, 0, 0);
 	if (err <= 0)
 		goto errout_free;
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 9815ea0..01808c5 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -79,9 +79,6 @@ static int xfrm4_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
 	struct rtable *rt = (struct rtable *)xdst->route;
 	const struct flowi4 *fl4 = &fl->u.ip4;
 
-	xdst->u.rt.rt_key_dst = fl4->daddr;
-	xdst->u.rt.rt_key_src = fl4->saddr;
-	xdst->u.rt.rt_key_tos = fl4->flowi4_tos;
 	xdst->u.rt.rt_route_iif = fl4->flowi4_iif;
 	xdst->u.rt.rt_iif = fl4->flowi4_iif;
 	xdst->u.rt.rt_oif = fl4->flowi4_oif;
-- 
1.7.10
