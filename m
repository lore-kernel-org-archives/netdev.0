From: David Miller <davem@davemloft.net>
Subject: [v3 RFC PATCH 8/8] ipv4: Kill rt_key_{src,dst} from struct rtable.
Date: Wed, 02 Mar 2011 17:02:13 -0800 (PST)
Message-ID: <20110302.170213.52199524.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48872
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755395Ab1CCBBg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 20:01:36 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 6EF1224C087
	for <netdev@vger.kernel.org>; Wed,  2 Mar 2011 17:02:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


They are always used in contexts where they can be reconstituted,
or where the finally resolved rt->rt_{src,dst} is semantically
equivalent.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/route.h     |    8 ++------
 net/ipv4/ipmr.c         |   33 ++++++++++++++++++---------------
 net/ipv4/route.c        |   24 +++++++-----------------
 net/ipv4/xfrm4_policy.c |    2 --
 4 files changed, 27 insertions(+), 40 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index ebf50a9..7e9d428 100644
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
@@ -205,8 +201,8 @@ static inline struct rtable *ip_route_newports(struct rtable *rt,
 	if (sport != orig_sport || dport != orig_dport) {
 		struct flowi fl = { .oif = rt->rt_oif,
 				    .mark = rt->rt_mark,
-				    .fl4_dst = rt->rt_key_dst,
-				    .fl4_src = rt->rt_key_src,
+				    .fl4_dst = rt->rt_dst,
+				    .fl4_src = rt->rt_src,
 				    .fl4_tos = rt->rt_tos,
 				    .proto = protocol,
 				    .fl_ip_sport = sport,
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 9d5f634..c8dd0b6 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1815,13 +1815,14 @@ int ip_mr_input(struct sk_buff *skb)
 
 	{
 		struct rtable *rt = skb_rtable(skb);
+		struct iphdr *iph = ip_hdr(skb);
 		struct flowi fl = {
-			.fl4_dst = rt->rt_key_dst,
-			.fl4_src = rt->rt_key_src,
-			.fl4_tos = rt->rt_tos,
+			.fl4_dst = iph->daddr,
+			.fl4_src = iph->saddr,
+			.fl4_tos = iph->tos,
 			.oif = rt->rt_oif,
-			.iif = rt->rt_iif,
-			.mark = rt->rt_mark,
+			.iif = skb->dev->ifindex,
+			.mark = skb->mark,
 		};
 		err = ipmr_fib_lookup(net, &fl, &mrt);
 		if (err < 0) {
@@ -1958,13 +1959,14 @@ int pim_rcv_v1(struct sk_buff *skb)
 
 	{
 		struct rtable *rt = skb_rtable(skb);
+		struct iphdr *iph = ip_hdr(skb);
 		struct flowi fl = {
-			.fl4_dst = rt->rt_key_dst,
-			.fl4_src = rt->rt_key_src,
-			.fl4_tos = rt->rt_tos,
+			.fl4_dst = iph->daddr,
+			.fl4_src = iph->saddr,
+			.fl4_tos = iph->tos,
 			.oif = rt->rt_oif,
-			.iif = rt->rt_iif,
-			.mark = rt->rt_mark,
+			.iif = skb->dev->ifindex,
+			.mark = skb->mark,
 		};
 		if (ipmr_fib_lookup(net, &fl, &mrt) < 0)
 			goto drop;
@@ -2000,13 +2002,14 @@ static int pim_rcv(struct sk_buff *skb)
 
 	{
 		struct rtable *rt = skb_rtable(skb);
+		struct iphdr *iph = ip_hdr(skb);
 		struct flowi fl = {
-			.fl4_dst = rt->rt_key_dst,
-			.fl4_src = rt->rt_key_src,
-			.fl4_tos = rt->rt_tos,
+			.fl4_dst = iph->daddr,
+			.fl4_src = iph->saddr,
+			.fl4_tos = iph->tos,
 			.oif = rt->rt_oif,
-			.iif = rt->rt_iif,
-			.mark = rt->rt_mark,
+			.iif = skb->dev->ifindex,
+			.mark = skb->mark,
 		};
 		if (ipmr_fib_lookup(net, &fl, &mrt) < 0)
 			goto drop;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 4f3ac67..04b8954 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -978,8 +978,8 @@ void ip_rt_get_source(u8 *addr, struct rtable *rt)
 		src = rt->rt_src;
 	else {
 		struct flowi fl = {
-			.fl4_dst = rt->rt_key_dst,
-			.fl4_src = rt->rt_key_src,
+			.fl4_dst = rt->rt_dst,
+			.fl4_src = rt->rt_src,
 			.fl4_tos = rt->rt_tos,
 			.oif = rt->rt_oif,
 			.iif = rt->rt_iif,
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
@@ -1461,8 +1457,6 @@ local_input:
 	rth->dst.tclassid = itag;
 #endif
 
-	rth->rt_key_dst	= daddr;
-	rth->rt_key_src	= saddr;
 	rth->rt_genid = rt_genid(net);
 	rth->rt_flags 	= flags|RTCF_LOCAL;
 	rth->rt_type	= res.type;
@@ -1626,8 +1620,6 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 
 	rth->dst.output = ip_output;
 
-	rth->rt_key_dst	= oldflp->fl4_dst;
-	rth->rt_key_src	= oldflp->fl4_src;
 	rth->rt_genid = rt_genid(dev_net(dev_out));
 	rth->rt_flags	= flags;
 	rth->rt_type	= type;
@@ -1897,8 +1889,6 @@ struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_or
 		if (new->dev)
 			dev_hold(new->dev);
 
-		rt->rt_key_dst = ort->rt_key_dst;
-		rt->rt_key_src = ort->rt_key_src;
 		rt->rt_tos = ort->rt_tos;
 		rt->rt_iif = ort->rt_iif;
 		rt->rt_oif = ort->rt_oif;
@@ -1947,7 +1937,7 @@ struct rtable *ip_route_output_flow(struct net *net, struct flowi *flp,
 }
 EXPORT_SYMBOL_GPL(ip_route_output_flow);
 
-static int rt_fill_info(struct net *net,
+static int rt_fill_info(struct net *net,  __be32 src,
 			struct sk_buff *skb, u32 pid, u32 seq, int event,
 			int nowait, unsigned int flags)
 {
@@ -1977,9 +1967,9 @@ static int rt_fill_info(struct net *net,
 
 	NLA_PUT_BE32(skb, RTA_DST, rt->rt_dst);
 
-	if (rt->rt_key_src) {
+	if (src) {
 		r->rtm_src_len = 32;
-		NLA_PUT_BE32(skb, RTA_SRC, rt->rt_key_src);
+		NLA_PUT_BE32(skb, RTA_SRC, src);
 	}
 	if (rt->dst.dev)
 		NLA_PUT_U32(skb, RTA_OIF, rt->dst.dev->ifindex);
@@ -1989,7 +1979,7 @@ static int rt_fill_info(struct net *net,
 #endif
 	if (rt_is_input_route(rt))
 		NLA_PUT_BE32(skb, RTA_PREFSRC, rt->rt_spec_dst);
-	else if (rt->rt_src != rt->rt_key_src)
+	else if (rt->rt_src != src)
 		NLA_PUT_BE32(skb, RTA_PREFSRC, rt->rt_src);
 
 	if (rt->rt_dst != rt->rt_gateway)
@@ -2131,7 +2121,7 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void
 	if (rtm->rtm_flags & RTM_F_NOTIFY)
 		rt->rt_flags |= RTCF_NOTIFY;
 
-	err = rt_fill_info(net, skb, NETLINK_CB(in_skb).pid, nlh->nlmsg_seq,
+	err = rt_fill_info(net, src, skb, NETLINK_CB(in_skb).pid, nlh->nlmsg_seq,
 			   RTM_NEWROUTE, 0, 0);
 	if (err <= 0)
 		goto errout_free;
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index c70c42e..f0bc2c8 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -70,8 +70,6 @@ static int xfrm4_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
 {
 	struct rtable *rt = (struct rtable *)xdst->route;
 
-	rt->rt_key_dst = fl->fl4_dst;
-	rt->rt_key_src = fl->fl4_src;
 	rt->rt_tos = fl->fl4_tos;
 	rt->rt_iif = fl->iif;
 	rt->rt_oif = fl->oif;
-- 
1.7.4.1

