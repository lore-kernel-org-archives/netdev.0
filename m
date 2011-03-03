From: David Miller <davem@davemloft.net>
Subject: [v3 RFC PATCH 5/8] ipv4: Remove flowi from struct rtable.
Date: Wed, 02 Mar 2011 17:02:05 -0800 (PST)
Message-ID: <20110302.170205.241934209.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48863
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754820Ab1CCBB2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 20:01:28 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id DEC3B24C087
	for <netdev@vger.kernel.org>; Wed,  2 Mar 2011 17:02:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The only necessary parts are the src/dst addresses, the
interface indexes, the TOS, and the mark.

The rest is unnecessary bloat, which amounts to nearly
50 bytes on 64-bit.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/route.h     |   24 +++++++-----
 net/ipv4/icmp.c         |    2 +-
 net/ipv4/ipmr.c         |   52 ++++++++++++++++++++-----
 net/ipv4/route.c        |   95 ++++++++++++++++++++++++++--------------------
 net/ipv4/xfrm4_policy.c |    7 +++-
 5 files changed, 116 insertions(+), 64 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index ef85013..ebf50a9 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -53,16 +53,20 @@ struct fib_info;
 struct rtable {
 	struct dst_entry	dst;
 
-	/* Cache lookup keys */
-	struct flowi		fl;
+	/* Lookup key. */
+	__be32			rt_key_dst;
+	__be32			rt_key_src;
 
 	int			rt_genid;
 	unsigned		rt_flags;
 	__u16			rt_type;
+	__u8			rt_tos;
 
 	__be32			rt_dst;	/* Path destination	*/
 	__be32			rt_src;	/* Path source		*/
 	int			rt_iif;
+	int			rt_oif;
+	__u32			rt_mark;
 
 	/* Info on neighbour */
 	__be32			rt_gateway;
@@ -76,12 +80,12 @@ struct rtable {
 
 static inline bool rt_is_input_route(struct rtable *rt)
 {
-	return rt->fl.iif != 0;
+	return rt->rt_iif != 0;
 }
 
 static inline bool rt_is_output_route(struct rtable *rt)
 {
-	return rt->fl.iif == 0;
+	return rt->rt_iif == 0;
 }
 
 struct ip_rt_acct {
@@ -199,12 +203,12 @@ static inline struct rtable *ip_route_newports(struct rtable *rt,
 					       __be16 dport, struct sock *sk)
 {
 	if (sport != orig_sport || dport != orig_dport) {
-		struct flowi fl = { .oif = rt->fl.oif,
-				    .mark = rt->fl.mark,
-				    .fl4_dst = rt->fl.fl4_dst,
-				    .fl4_src = rt->fl.fl4_src,
-				    .fl4_tos = rt->fl.fl4_tos,
-				    .proto = rt->fl.proto,
+		struct flowi fl = { .oif = rt->rt_oif,
+				    .mark = rt->rt_mark,
+				    .fl4_dst = rt->rt_key_dst,
+				    .fl4_src = rt->rt_key_src,
+				    .fl4_tos = rt->rt_tos,
+				    .proto = protocol,
 				    .fl_ip_sport = sport,
 				    .fl_ip_dport = dport };
 
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 994a785..1771ce6 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -563,7 +563,7 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 		rcu_read_lock();
 		if (rt_is_input_route(rt) &&
 		    net->ipv4.sysctl_icmp_errors_use_inbound_ifaddr)
-			dev = dev_get_by_index_rcu(net, rt->fl.iif);
+			dev = dev_get_by_index_rcu(net, rt->rt_iif);
 
 		if (dev)
 			saddr = inet_select_addr(dev, 0, RT_SCOPE_LINK);
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 26ca2f2..9d5f634 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1813,12 +1813,22 @@ int ip_mr_input(struct sk_buff *skb)
 	if (IPCB(skb)->flags & IPSKB_FORWARDED)
 		goto dont_forward;
 
-	err = ipmr_fib_lookup(net, &skb_rtable(skb)->fl, &mrt);
-	if (err < 0) {
-		kfree_skb(skb);
-		return err;
+	{
+		struct rtable *rt = skb_rtable(skb);
+		struct flowi fl = {
+			.fl4_dst = rt->rt_key_dst,
+			.fl4_src = rt->rt_key_src,
+			.fl4_tos = rt->rt_tos,
+			.oif = rt->rt_oif,
+			.iif = rt->rt_iif,
+			.mark = rt->rt_mark,
+		};
+		err = ipmr_fib_lookup(net, &fl, &mrt);
+		if (err < 0) {
+			kfree_skb(skb);
+			return err;
+		}
 	}
-
 	if (!local) {
 		if (IPCB(skb)->opt.router_alert) {
 			if (ip_call_ra_chain(skb))
@@ -1946,9 +1956,19 @@ int pim_rcv_v1(struct sk_buff *skb)
 
 	pim = igmp_hdr(skb);
 
-	if (ipmr_fib_lookup(net, &skb_rtable(skb)->fl, &mrt) < 0)
-		goto drop;
-
+	{
+		struct rtable *rt = skb_rtable(skb);
+		struct flowi fl = {
+			.fl4_dst = rt->rt_key_dst,
+			.fl4_src = rt->rt_key_src,
+			.fl4_tos = rt->rt_tos,
+			.oif = rt->rt_oif,
+			.iif = rt->rt_iif,
+			.mark = rt->rt_mark,
+		};
+		if (ipmr_fib_lookup(net, &fl, &mrt) < 0)
+			goto drop;
+	}
 	if (!mrt->mroute_do_pim ||
 	    pim->group != PIM_V1_VERSION || pim->code != PIM_V1_REGISTER)
 		goto drop;
@@ -1978,9 +1998,19 @@ static int pim_rcv(struct sk_buff *skb)
 	     csum_fold(skb_checksum(skb, 0, skb->len, 0))))
 		goto drop;
 
-	if (ipmr_fib_lookup(net, &skb_rtable(skb)->fl, &mrt) < 0)
-		goto drop;
-
+	{
+		struct rtable *rt = skb_rtable(skb);
+		struct flowi fl = {
+			.fl4_dst = rt->rt_key_dst,
+			.fl4_src = rt->rt_key_src,
+			.fl4_tos = rt->rt_tos,
+			.oif = rt->rt_oif,
+			.iif = rt->rt_iif,
+			.mark = rt->rt_mark,
+		};
+		if (ipmr_fib_lookup(net, &fl, &mrt) < 0)
+			goto drop;
+	}
 	if (__pim_rcv(mrt, skb, sizeof(*pim))) {
 drop:
 		kfree_skb(skb);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index e59241f..9e302dc 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -629,7 +629,7 @@ static struct dst_entry *ipv4_negative_advice(struct dst_entry *dst)
 		} else if (rt->rt_flags & RTCF_REDIRECTED) {
 #if RT_CACHE_DEBUG >= 1
 			printk(KERN_DEBUG "ipv4_negative_advice: redirect to %pI4/%02x dropped\n",
-			       &rt->rt_dst, rt->fl.fl4_tos);
+			       &rt->rt_dst, rt->rt_tos);
 #endif
 			ip_rt_put(rt);
 			ret = NULL;
@@ -977,8 +977,17 @@ void ip_rt_get_source(u8 *addr, struct rtable *rt)
 	if (rt_is_output_route(rt))
 		src = rt->rt_src;
 	else {
+		struct flowi fl = {
+			.fl4_dst = rt->rt_key_dst,
+			.fl4_src = rt->rt_key_src,
+			.fl4_tos = rt->rt_tos,
+			.oif = rt->rt_oif,
+			.iif = rt->rt_iif,
+			.mark = rt->rt_mark,
+		};
+
 		rcu_read_lock();
-		if (fib_lookup(dev_net(rt->dst.dev), &rt->fl, &res) == 0)
+		if (fib_lookup(dev_net(rt->dst.dev), &fl, &res) == 0)
 			src = FIB_RES_PREFSRC(res);
 		else
 			src = inet_select_addr(rt->dst.dev, rt->rt_gateway,
@@ -1028,7 +1037,8 @@ static unsigned int ipv4_default_mtu(const struct dst_entry *dst)
 	return mtu;
 }
 
-static void rt_init_metrics(struct rtable *rt, struct fib_info *fi)
+static void rt_init_metrics(struct rtable *rt, const struct flowi *oldflp,
+			    struct fib_info *fi)
 {
 	struct inet_peer *peer;
 	int create = 0;
@@ -1036,7 +1046,7 @@ static void rt_init_metrics(struct rtable *rt, struct fib_info *fi)
 	/* If a peer entry exists for this destination, we must hook
 	 * it up in order to get at cached metrics.
 	 */
-	if (rt->fl.flags & FLOWI_FLAG_PRECOW_METRICS)
+	if (oldflp && (oldflp->flags & FLOWI_FLAG_PRECOW_METRICS))
 		create = 1;
 
 	rt_bind_peer(rt, create);
@@ -1063,7 +1073,8 @@ static void rt_init_metrics(struct rtable *rt, struct fib_info *fi)
 	}
 }
 
-static void rt_set_nexthop(struct rtable *rt, const struct fib_result *res,
+static void rt_set_nexthop(struct rtable *rt, const struct flowi *oldflp,
+			   const struct fib_result *res,
 			   struct fib_info *fi, u16 type, u32 itag)
 {
 	struct dst_entry *dst = &rt->dst;
@@ -1072,7 +1083,7 @@ static void rt_set_nexthop(struct rtable *rt, const struct fib_result *res,
 		if (FIB_RES_GW(*res) &&
 		    FIB_RES_NH(*res).nh_scope == RT_SCOPE_LINK)
 			rt->rt_gateway = FIB_RES_GW(*res);
-		rt_init_metrics(rt, fi);
+		rt_init_metrics(rt, oldflp, fi);
 #ifdef CONFIG_IP_ROUTE_CLASSID
 		dst->tclassid = FIB_RES_NH(*res).nh_tclassid;
 #endif
@@ -1144,20 +1155,19 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 
 	rth->dst.output = ip_rt_bug;
 
-	rth->fl.fl4_dst	= daddr;
+	rth->rt_key_dst	= daddr;
 	rth->rt_dst	= daddr;
-	rth->fl.fl4_tos	= tos;
-	rth->fl.mark    = skb->mark;
-	rth->fl.fl4_src	= saddr;
+	rth->rt_tos	= tos;
+	rth->rt_mark    = skb->mark;
+	rth->rt_key_src	= saddr;
 	rth->rt_src	= saddr;
 #ifdef CONFIG_IP_ROUTE_CLASSID
 	rth->dst.tclassid = itag;
 #endif
-	rth->rt_iif	=
-	rth->fl.iif	= dev->ifindex;
+	rth->rt_iif	= dev->ifindex;
 	rth->dst.dev	= init_net.loopback_dev;
 	dev_hold(rth->dst.dev);
-	rth->fl.oif	= 0;
+	rth->rt_oif	= 0;
 	rth->rt_gateway	= daddr;
 	rth->rt_spec_dst= spec_dst;
 	rth->rt_genid	= rt_genid(dev_net(dev));
@@ -1281,25 +1291,24 @@ static int __mkroute_input(struct sk_buff *skb,
 		goto cleanup;
 	}
 
-	rth->fl.fl4_dst	= daddr;
+	rth->rt_key_dst	= daddr;
 	rth->rt_dst	= daddr;
-	rth->fl.fl4_tos	= tos;
-	rth->fl.mark    = skb->mark;
-	rth->fl.fl4_src	= saddr;
+	rth->rt_tos	= tos;
+	rth->rt_mark    = skb->mark;
+	rth->rt_key_src	= saddr;
 	rth->rt_src	= saddr;
 	rth->rt_gateway	= daddr;
-	rth->rt_iif 	=
-		rth->fl.iif	= in_dev->dev->ifindex;
+	rth->rt_iif 	= in_dev->dev->ifindex;
 	rth->dst.dev	= (out_dev)->dev;
 	dev_hold(rth->dst.dev);
-	rth->fl.oif 	= 0;
+	rth->rt_oif 	= 0;
 	rth->rt_spec_dst= spec_dst;
 
 	rth->dst.input = ip_forward;
 	rth->dst.output = ip_output;
 	rth->rt_genid = rt_genid(dev_net(rth->dst.dev));
 
-	rt_set_nexthop(rth, res, res->fi, res->type, itag);
+	rt_set_nexthop(rth, NULL, res, res->fi, res->type, itag);
 
 	rth->rt_flags = flags;
 
@@ -1449,17 +1458,16 @@ local_input:
 	rth->dst.output= ip_rt_bug;
 	rth->rt_genid = rt_genid(net);
 
-	rth->fl.fl4_dst	= daddr;
+	rth->rt_key_dst	= daddr;
 	rth->rt_dst	= daddr;
-	rth->fl.fl4_tos	= tos;
-	rth->fl.mark    = skb->mark;
-	rth->fl.fl4_src	= saddr;
+	rth->rt_tos	= tos;
+	rth->rt_mark    = skb->mark;
+	rth->rt_key_src	= saddr;
 	rth->rt_src	= saddr;
 #ifdef CONFIG_IP_ROUTE_CLASSID
 	rth->dst.tclassid = itag;
 #endif
-	rth->rt_iif	=
-	rth->fl.iif	= dev->ifindex;
+	rth->rt_iif	= dev->ifindex;
 	rth->dst.dev	= net->loopback_dev;
 	dev_hold(rth->dst.dev);
 	rth->rt_gateway	= daddr;
@@ -1613,11 +1621,11 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 	if (!rth)
 		return ERR_PTR(-ENOBUFS);
 
-	rth->fl.fl4_dst	= oldflp->fl4_dst;
-	rth->fl.fl4_tos	= tos;
-	rth->fl.fl4_src	= oldflp->fl4_src;
-	rth->fl.oif	= oldflp->oif;
-	rth->fl.mark    = oldflp->mark;
+	rth->rt_key_dst	= oldflp->fl4_dst;
+	rth->rt_tos	= tos;
+	rth->rt_key_src	= oldflp->fl4_src;
+	rth->rt_oif	= oldflp->oif;
+	rth->rt_mark    = oldflp->mark;
 	rth->rt_dst	= fl->fl4_dst;
 	rth->rt_src	= fl->fl4_src;
 	rth->rt_iif	= oldflp->oif ? : dev_out->ifindex;
@@ -1655,7 +1663,7 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 #endif
 	}
 
-	rt_set_nexthop(rth, res, fi, type, 0);
+	rt_set_nexthop(rth, oldflp, res, fi, type, 0);
 
 	rth->rt_flags = flags;
 	return rth;
@@ -1887,7 +1895,12 @@ struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_or
 		if (new->dev)
 			dev_hold(new->dev);
 
-		rt->fl = ort->fl;
+		rt->rt_key_dst = ort->rt_key_dst;
+		rt->rt_key_src = ort->rt_key_src;
+		rt->rt_tos = ort->rt_tos;
+		rt->rt_iif = ort->rt_iif;
+		rt->rt_oif = ort->rt_oif;
+		rt->rt_mark = ort->rt_mark;
 
 		rt->rt_genid = rt_genid(net);
 		rt->rt_flags = ort->rt_flags;
@@ -1950,7 +1963,7 @@ static int rt_fill_info(struct net *net,
 	r->rtm_family	 = AF_INET;
 	r->rtm_dst_len	= 32;
 	r->rtm_src_len	= 0;
-	r->rtm_tos	= rt->fl.fl4_tos;
+	r->rtm_tos	= rt->rt_tos;
 	r->rtm_table	= RT_TABLE_MAIN;
 	NLA_PUT_U32(skb, RTA_TABLE, RT_TABLE_MAIN);
 	r->rtm_type	= rt->rt_type;
@@ -1962,9 +1975,9 @@ static int rt_fill_info(struct net *net,
 
 	NLA_PUT_BE32(skb, RTA_DST, rt->rt_dst);
 
-	if (rt->fl.fl4_src) {
+	if (rt->rt_key_src) {
 		r->rtm_src_len = 32;
-		NLA_PUT_BE32(skb, RTA_SRC, rt->fl.fl4_src);
+		NLA_PUT_BE32(skb, RTA_SRC, rt->rt_key_src);
 	}
 	if (rt->dst.dev)
 		NLA_PUT_U32(skb, RTA_OIF, rt->dst.dev->ifindex);
@@ -1974,7 +1987,7 @@ static int rt_fill_info(struct net *net,
 #endif
 	if (rt_is_input_route(rt))
 		NLA_PUT_BE32(skb, RTA_PREFSRC, rt->rt_spec_dst);
-	else if (rt->rt_src != rt->fl.fl4_src)
+	else if (rt->rt_src != rt->rt_key_src)
 		NLA_PUT_BE32(skb, RTA_PREFSRC, rt->rt_src);
 
 	if (rt->rt_dst != rt->rt_gateway)
@@ -1983,8 +1996,8 @@ static int rt_fill_info(struct net *net,
 	if (rtnetlink_put_metrics(skb, dst_metrics_ptr(&rt->dst)) < 0)
 		goto nla_put_failure;
 
-	if (rt->fl.mark)
-		NLA_PUT_BE32(skb, RTA_MARK, rt->fl.mark);
+	if (rt->rt_mark)
+		NLA_PUT_BE32(skb, RTA_MARK, rt->rt_mark);
 
 	error = rt->dst.error;
 	expires = (rt->peer && rt->peer->pmtu_expires) ?
@@ -2018,7 +2031,7 @@ static int rt_fill_info(struct net *net,
 			}
 		} else
 #endif
-			NLA_PUT_U32(skb, RTA_IIF, rt->fl.iif);
+			NLA_PUT_U32(skb, RTA_IIF, rt->rt_iif);
 	}
 
 	if (rtnl_put_cacheinfo(skb, &rt->dst, id, ts, tsage,
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 45b8214..c70c42e 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -70,7 +70,12 @@ static int xfrm4_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
 {
 	struct rtable *rt = (struct rtable *)xdst->route;
 
-	xdst->u.rt.fl = *fl;
+	rt->rt_key_dst = fl->fl4_dst;
+	rt->rt_key_src = fl->fl4_src;
+	rt->rt_tos = fl->fl4_tos;
+	rt->rt_iif = fl->iif;
+	rt->rt_oif = fl->oif;
+	rt->rt_mark = fl->mark;
 
 	xdst->u.dst.dev = dev;
 	dev_hold(dev);
-- 
1.7.4.1

