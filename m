From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/5] ipv4: Remove rt_key_{src,dst,tos} from struct rtable.
Date: Tue, 20 Dec 2011 16:35:29 -0500 (EST)
Message-ID: <20111220.163529.1130004546020725932.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43631 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752392Ab1LTVfb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2011 16:35:31 -0500
Received: from localhost (cpe-66-65-61-233.nyc.res.rr.com [66.65.61.233])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id pBKLZUM9006446
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 20 Dec 2011 13:35:30 -0800
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
index 9675965..a2f250d0 100644
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
 	unsigned		rt_flags;
 	__u16			rt_type;
-	__u8			rt_key_tos;
 
 	__be32			rt_dst;	/* Path destination	*/
 	__be32			rt_src;	/* Path source		*/
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index edc91aa..a30611c 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1216,12 +1216,9 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
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
@@ -1350,12 +1347,9 @@ static int __mkroute_input(struct sk_buff *skb,
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
@@ -1525,12 +1519,9 @@ local_input:
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
 #ifdef CONFIG_IP_ROUTE_CLASSID
@@ -1642,9 +1633,7 @@ EXPORT_SYMBOL(ip_route_input);
 
 /* called with rcu_read_lock() */
 static struct rtable *__mkroute_output(const struct fib_result *res,
-				       const struct flowi4 *fl4,
-				       __be32 orig_daddr, __be32 orig_saddr,
-				       int orig_oif, __u8 orig_rtos,
+				       const struct flowi4 *fl4, int orig_oif,
 				       struct net_device *dev_out,
 				       unsigned int flags)
 {
@@ -1694,12 +1683,9 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 
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
@@ -1752,8 +1738,6 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 	unsigned int flags = 0;
 	struct fib_result res;
 	struct rtable *rth;
-	__be32 orig_daddr;
-	__be32 orig_saddr;
 	int orig_oif;
 
 	res.fi		= NULL;
@@ -1761,8 +1745,6 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 	res.r		= NULL;
 #endif
 
-	orig_daddr = fl4->daddr;
-	orig_saddr = fl4->saddr;
 	orig_oif = fl4->flowi4_oif;
 
 	fl4->flowi4_iif = net->loopback_dev->ifindex;
@@ -1923,8 +1905,7 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 
 
 make_route:
-	rth = __mkroute_output(&res, fl4, orig_daddr, orig_saddr, orig_oif,
-			       tos, dev_out, flags);
+	rth = __mkroute_output(&res, fl4, orig_oif, dev_out, flags);
 	if (!IS_ERR(rth))
 		rth = rt_finalize(rth, NULL);
 
@@ -1985,9 +1966,6 @@ struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_or
 		if (new->dev)
 			dev_hold(new->dev);
 
-		rt->rt_key_dst = ort->rt_key_dst;
-		rt->rt_key_src = ort->rt_key_src;
-		rt->rt_key_tos = ort->rt_key_tos;
 		rt->rt_route_iif = ort->rt_route_iif;
 		rt->rt_iif = ort->rt_iif;
 		rt->rt_oif = ort->rt_oif;
@@ -2032,7 +2010,7 @@ struct rtable *ip_route_output_flow(struct net *net, struct flowi4 *flp4,
 }
 EXPORT_SYMBOL_GPL(ip_route_output_flow);
 
-static int rt_fill_info(struct net *net,
+static int rt_fill_info(struct net *net,  __be32 src, u8 tos,
 			struct sk_buff *skb, u32 pid, u32 seq, int event,
 			int nowait, unsigned int flags)
 {
@@ -2051,7 +2029,7 @@ static int rt_fill_info(struct net *net,
 	r->rtm_family	 = AF_INET;
 	r->rtm_dst_len	= 32;
 	r->rtm_src_len	= 0;
-	r->rtm_tos	= rt->rt_key_tos;
+	r->rtm_tos	= tos;
 	r->rtm_table	= RT_TABLE_MAIN;
 	NLA_PUT_U32(skb, RTA_TABLE, RT_TABLE_MAIN);
 	r->rtm_type	= rt->rt_type;
@@ -2063,9 +2041,9 @@ static int rt_fill_info(struct net *net,
 
 	NLA_PUT_BE32(skb, RTA_DST, rt->rt_dst);
 
-	if (rt->rt_key_src) {
+	if (src) {
 		r->rtm_src_len = 32;
-		NLA_PUT_BE32(skb, RTA_SRC, rt->rt_key_src);
+		NLA_PUT_BE32(skb, RTA_SRC, src);
 	}
 	if (rt->dst.dev)
 		NLA_PUT_U32(skb, RTA_OIF, rt->dst.dev->ifindex);
@@ -2075,7 +2053,7 @@ static int rt_fill_info(struct net *net,
 #endif
 	if (rt_is_input_route(rt))
 		NLA_PUT_BE32(skb, RTA_PREFSRC, rt->rt_spec_dst);
-	else if (rt->rt_src != rt->rt_key_src)
+	else if (rt->rt_src != src)
 		NLA_PUT_BE32(skb, RTA_PREFSRC, rt->rt_src);
 
 	if (rt->rt_dst != rt->rt_gateway)
@@ -2221,7 +2199,8 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void
 	if (rtm->rtm_flags & RTM_F_NOTIFY)
 		rt->rt_flags |= RTCF_NOTIFY;
 
-	err = rt_fill_info(net, skb, NETLINK_CB(in_skb).pid, nlh->nlmsg_seq,
+	err = rt_fill_info(net, src, rtm->rtm_tos, skb,
+			   NETLINK_CB(in_skb).pid, nlh->nlmsg_seq,
 			   RTM_NEWROUTE, 0, 0);
 	if (err <= 0)
 		goto errout_free;
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index a0b4c5d..a659008 100644
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
1.7.6.401.g6a319
