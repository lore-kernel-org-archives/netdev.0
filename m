From: David Miller <davem@davemloft.net>
Subject: [PATCH v4 RFC 7/8] ipv4: Kill rt_key_{src,dst} from struct rtable.
Date: Sat, 12 Mar 2011 16:37:48 -0800 (PST)
Message-ID: <20110312.163748.13743845.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55607
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755055Ab1CMAhK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2011 19:37:10 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 726DA24C088
	for <netdev@vger.kernel.org>; Sat, 12 Mar 2011 16:37:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


They are always used in contexts where they can be reconstituted,
or where the finally resolved rt->rt_{src,dst} is semantically
equivalent.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/route.h     |    8 ++------
 net/ipv4/ipmr.c         |    4 ++--
 net/ipv4/route.c        |   24 +++++++-----------------
 net/ipv4/xfrm4_policy.c |    2 --
 4 files changed, 11 insertions(+), 27 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index 78e8ce1..154e589 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -53,10 +53,6 @@ struct fib_info;
 struct rtable {
 	struct dst_entry	dst;
 
-	/* Lookup key. */
-	__be32			rt_key_dst;
-	__be32			rt_key_src;
-
 	int			rt_genid;
 	unsigned		rt_flags;
 	__u16			rt_type;
@@ -256,8 +252,8 @@ static inline struct rtable *ip_route_newports(struct rtable *rt,
 		struct flowi4 fl4 = {
 			.flowi4_oif = rt->rt_oif,
 			.flowi4_mark = rt->rt_mark,
-			.daddr = rt->rt_key_dst,
-			.saddr = rt->rt_key_src,
+			.daddr = rt->rt_dst,
+			.saddr = rt->rt_src,
 			.flowi4_tos = rt->rt_tos,
 			.flowi4_proto = protocol,
 			.fl4_sport = sport,
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 1f62eae..0441b26 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1791,8 +1791,8 @@ dont_forward:
 static struct mr_table *ipmr_rt_fib_lookup(struct net *net, struct rtable *rt)
 {
 	struct flowi4 fl4 = {
-		.daddr = rt->rt_key_dst,
-		.saddr = rt->rt_key_src,
+		.daddr = rt->rt_dst,
+		.saddr = rt->rt_src,
 		.flowi4_tos = rt->rt_tos,
 		.flowi4_oif = rt->rt_oif,
 		.flowi4_iif = rt->rt_iif,
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 0b02eb3..21fb343 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -978,8 +978,8 @@ void ip_rt_get_source(u8 *addr, struct rtable *rt)
 		src = rt->rt_src;
 	else {
 		struct flowi4 fl4 = {
-			.daddr = rt->rt_key_dst,
-			.saddr = rt->rt_key_src,
+			.daddr = rt->rt_dst,
+			.saddr = rt->rt_src,
 			.flowi4_tos = rt->rt_tos,
 			.flowi4_oif = rt->rt_oif,
 			.flowi4_iif = rt->rt_iif,
@@ -1154,8 +1154,6 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 #endif
 	rth->dst.output = ip_rt_bug;
 
-	rth->rt_key_dst	= daddr;
-	rth->rt_key_src	= saddr;
 	rth->rt_genid	= rt_genid(dev_net(dev));
 	rth->rt_flags	= RTCF_MULTICAST;
 	rth->rt_type	= RTN_MULTICAST;
@@ -1289,8 +1287,6 @@ static int __mkroute_input(struct sk_buff *skb,
 		goto cleanup;
 	}
 
-	rth->rt_key_dst	= daddr;
-	rth->rt_key_src	= saddr;
 	rth->rt_genid = rt_genid(dev_net(rth->dst.dev));
 	rth->rt_flags = flags;
 	rth->rt_type = res->type;
@@ -1463,8 +1459,6 @@ local_input:
 	rth->dst.tclassid = itag;
 #endif
 
-	rth->rt_key_dst	= daddr;
-	rth->rt_key_src	= saddr;
 	rth->rt_genid = rt_genid(net);
 	rth->rt_flags 	= flags|RTCF_LOCAL;
 	rth->rt_type	= res.type;
@@ -1628,8 +1622,6 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 
 	rth->dst.output = ip_output;
 
-	rth->rt_key_dst	= oldflp4->daddr;
-	rth->rt_key_src	= oldflp4->saddr;
 	rth->rt_genid = rt_genid(dev_net(dev_out));
 	rth->rt_flags	= flags;
 	rth->rt_type	= type;
@@ -1903,8 +1895,6 @@ struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_or
 		if (new->dev)
 			dev_hold(new->dev);
 
-		rt->rt_key_dst = ort->rt_key_dst;
-		rt->rt_key_src = ort->rt_key_src;
 		rt->rt_tos = ort->rt_tos;
 		rt->rt_iif = ort->rt_iif;
 		rt->rt_oif = ort->rt_oif;
@@ -1955,7 +1945,7 @@ struct rtable *ip_route_output_flow(struct net *net, struct flowi4 *flp4,
 }
 EXPORT_SYMBOL_GPL(ip_route_output_flow);
 
-static int rt_fill_info(struct net *net,
+static int rt_fill_info(struct net *net,  __be32 src,
 			struct sk_buff *skb, u32 pid, u32 seq, int event,
 			int nowait, unsigned int flags)
 {
@@ -1985,9 +1975,9 @@ static int rt_fill_info(struct net *net,
 
 	NLA_PUT_BE32(skb, RTA_DST, rt->rt_dst);
 
-	if (rt->rt_key_src) {
+	if (src) {
 		r->rtm_src_len = 32;
-		NLA_PUT_BE32(skb, RTA_SRC, rt->rt_key_src);
+		NLA_PUT_BE32(skb, RTA_SRC, src);
 	}
 	if (rt->dst.dev)
 		NLA_PUT_U32(skb, RTA_OIF, rt->dst.dev->ifindex);
@@ -1997,7 +1987,7 @@ static int rt_fill_info(struct net *net,
 #endif
 	if (rt_is_input_route(rt))
 		NLA_PUT_BE32(skb, RTA_PREFSRC, rt->rt_spec_dst);
-	else if (rt->rt_src != rt->rt_key_src)
+	else if (rt->rt_src != src)
 		NLA_PUT_BE32(skb, RTA_PREFSRC, rt->rt_src);
 
 	if (rt->rt_dst != rt->rt_gateway)
@@ -2139,7 +2129,7 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void
 	if (rtm->rtm_flags & RTM_F_NOTIFY)
 		rt->rt_flags |= RTCF_NOTIFY;
 
-	err = rt_fill_info(net, skb, NETLINK_CB(in_skb).pid, nlh->nlmsg_seq,
+	err = rt_fill_info(net, src, skb, NETLINK_CB(in_skb).pid, nlh->nlmsg_seq,
 			   RTM_NEWROUTE, 0, 0);
 	if (err <= 0)
 		goto errout_free;
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 13e0e7f..813fb34 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -71,8 +71,6 @@ static int xfrm4_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
 	struct rtable *rt = (struct rtable *)xdst->route;
 	const struct flowi4 *fl4 = &fl->u.ip4;
 
-	rt->rt_key_dst = fl4->daddr;
-	rt->rt_key_src = fl4->saddr;
 	rt->rt_tos = fl4->flowi4_tos;
 	rt->rt_iif = fl4->flowi4_iif;
 	rt->rt_oif = fl4->flowi4_oif;
-- 
1.7.4.1

