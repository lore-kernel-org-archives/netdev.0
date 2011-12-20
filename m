From: David Miller <davem@davemloft.net>
Subject: [PATCH 4/5] ipv4: Kill 'rt_src' from 'struct rtable'
Date: Tue, 20 Dec 2011 16:35:34 -0500 (EST)
Message-ID: <20111220.163534.1145075005275331876.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43633 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752874Ab1LTVfg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2011 16:35:36 -0500
Received: from localhost (cpe-66-65-61-233.nyc.res.rr.com [66.65.61.233])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id pBKLZYYO006454
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 20 Dec 2011 13:35:35 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/route.h     |    1 -
 net/ipv4/route.c        |   34 +++++++++++++++-------------------
 net/ipv4/xfrm4_policy.c |    1 -
 3 files changed, 15 insertions(+), 21 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index a2f250d0..2c5d300 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -50,7 +50,6 @@ struct rtable {
 	__u16			rt_type;
 
 	__be32			rt_dst;	/* Path destination	*/
-	__be32			rt_src;	/* Path source		*/
 	int			rt_route_iif;
 	int			rt_iif;
 	int			rt_oif;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index a30611c..208be60 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1220,7 +1220,6 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	rth->rt_flags	= RTCF_MULTICAST;
 	rth->rt_type	= RTN_MULTICAST;
 	rth->rt_dst	= daddr;
-	rth->rt_src	= saddr;
 	rth->rt_route_iif = dev->ifindex;
 	rth->rt_iif	= dev->ifindex;
 	rth->rt_oif	= 0;
@@ -1351,7 +1350,6 @@ static int __mkroute_input(struct sk_buff *skb,
 	rth->rt_flags = flags;
 	rth->rt_type = res->type;
 	rth->rt_dst	= daddr;
-	rth->rt_src	= saddr;
 	rth->rt_route_iif = in_dev->dev->ifindex;
 	rth->rt_iif 	= in_dev->dev->ifindex;
 	rth->rt_oif 	= 0;
@@ -1523,7 +1521,6 @@ local_input:
 	rth->rt_flags 	= flags|RTCF_LOCAL;
 	rth->rt_type	= res.type;
 	rth->rt_dst	= daddr;
-	rth->rt_src	= saddr;
 #ifdef CONFIG_IP_ROUTE_CLASSID
 	rth->dst.tclassid = itag;
 #endif
@@ -1687,7 +1684,6 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 	rth->rt_flags	= flags;
 	rth->rt_type	= type;
 	rth->rt_dst	= fl4->daddr;
-	rth->rt_src	= fl4->saddr;
 	rth->rt_route_iif = 0;
 	rth->rt_iif	= orig_oif ? : dev_out->ifindex;
 	rth->rt_oif	= orig_oif;
@@ -1975,7 +1971,6 @@ struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_or
 		rt->rt_flags = ort->rt_flags;
 		rt->rt_type = ort->rt_type;
 		rt->rt_dst = ort->rt_dst;
-		rt->rt_src = ort->rt_src;
 		rt->rt_gateway = ort->rt_gateway;
 		rt->rt_spec_dst = ort->rt_spec_dst;
 		rt->peer = ort->peer;
@@ -2010,7 +2005,7 @@ struct rtable *ip_route_output_flow(struct net *net, struct flowi4 *flp4,
 }
 EXPORT_SYMBOL_GPL(ip_route_output_flow);
 
-static int rt_fill_info(struct net *net,  __be32 src, u8 tos,
+static int rt_fill_info(struct net *net,  __be32 src, struct flowi4 *fl4,
 			struct sk_buff *skb, u32 pid, u32 seq, int event,
 			int nowait, unsigned int flags)
 {
@@ -2029,7 +2024,7 @@ static int rt_fill_info(struct net *net,  __be32 src, u8 tos,
 	r->rtm_family	 = AF_INET;
 	r->rtm_dst_len	= 32;
 	r->rtm_src_len	= 0;
-	r->rtm_tos	= tos;
+	r->rtm_tos	= fl4->flowi4_tos;
 	r->rtm_table	= RT_TABLE_MAIN;
 	NLA_PUT_U32(skb, RTA_TABLE, RT_TABLE_MAIN);
 	r->rtm_type	= rt->rt_type;
@@ -2053,10 +2048,10 @@ static int rt_fill_info(struct net *net,  __be32 src, u8 tos,
 #endif
 	if (rt_is_input_route(rt))
 		NLA_PUT_BE32(skb, RTA_PREFSRC, rt->rt_spec_dst);
-	else if (rt->rt_src != src)
-		NLA_PUT_BE32(skb, RTA_PREFSRC, rt->rt_src);
+	else if (fl4->saddr != src)
+		NLA_PUT_BE32(skb, RTA_PREFSRC, fl4->saddr);
 
-	if (rt->rt_dst != rt->rt_gateway)
+	if (fl4->daddr != rt->rt_gateway)
 		NLA_PUT_BE32(skb, RTA_GATEWAY, rt->rt_gateway);
 
 	if (rtnetlink_put_metrics(skb, dst_metrics_ptr(&rt->dst)) < 0)
@@ -2089,7 +2084,7 @@ static int rt_fill_info(struct net *net,  __be32 src, u8 tos,
 		if (ipv4_is_multicast(dst) && !ipv4_is_local_multicast(dst) &&
 		    IPV4_DEVCONF_ALL(net, MC_FORWARDING)) {
 			int err = ipmr_get_route(net, skb,
-						 rt->rt_src, rt->rt_dst,
+						 fl4->saddr, fl4->daddr,
 						 r, nowait);
 			if (err <= 0) {
 				if (!nowait) {
@@ -2124,6 +2119,7 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void
 	struct rtmsg *rtm;
 	struct nlattr *tb[RTA_MAX+1];
 	struct rtable *rt = NULL;
+	struct flowi4 fl4;
 	__be32 dst = 0;
 	__be32 src = 0;
 	u32 iif;
@@ -2158,6 +2154,13 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void
 	iif = tb[RTA_IIF] ? nla_get_u32(tb[RTA_IIF]) : 0;
 	mark = tb[RTA_MARK] ? nla_get_u32(tb[RTA_MARK]) : 0;
 
+	memset(&fl4, 0, sizeof(fl4));
+	fl4.daddr = dst;
+	fl4.saddr = src;
+	fl4.flowi4_tos = rtm->rtm_tos;
+	fl4.flowi4_oif = tb[RTA_OIF] ? nla_get_u32(tb[RTA_OIF]) : 0;
+	fl4.flowi4_mark = mark;
+
 	if (iif) {
 		struct net_device *dev;
 
@@ -2178,13 +2181,6 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void
 		if (err == 0 && rt->dst.error)
 			err = -rt->dst.error;
 	} else {
-		struct flowi4 fl4 = {
-			.daddr = dst,
-			.saddr = src,
-			.flowi4_tos = rtm->rtm_tos,
-			.flowi4_oif = tb[RTA_OIF] ? nla_get_u32(tb[RTA_OIF]) : 0,
-			.flowi4_mark = mark,
-		};
 		rt = ip_route_output_key(net, &fl4);
 
 		err = 0;
@@ -2199,7 +2195,7 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void
 	if (rtm->rtm_flags & RTM_F_NOTIFY)
 		rt->rt_flags |= RTCF_NOTIFY;
 
-	err = rt_fill_info(net, src, rtm->rtm_tos, skb,
+	err = rt_fill_info(net, src, &fl4, skb,
 			   NETLINK_CB(in_skb).pid, nlh->nlmsg_seq,
 			   RTM_NEWROUTE, 0, 0);
 	if (err <= 0)
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index a659008..210da0c 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -96,7 +96,6 @@ static int xfrm4_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
 	xdst->u.rt.rt_flags = rt->rt_flags & (RTCF_BROADCAST | RTCF_MULTICAST |
 					      RTCF_LOCAL);
 	xdst->u.rt.rt_type = rt->rt_type;
-	xdst->u.rt.rt_src = rt->rt_src;
 	xdst->u.rt.rt_dst = rt->rt_dst;
 	xdst->u.rt.rt_gateway = rt->rt_gateway;
 	xdst->u.rt.rt_spec_dst = rt->rt_spec_dst;
-- 
1.7.6.401.g6a319
