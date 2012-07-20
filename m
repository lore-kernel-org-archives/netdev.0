From: David Miller <davem@davemloft.net>
Subject: [PATCH 15/16] ipv4: Turn rt->rt_route_iif into rt->rt_is_input.
Date: Fri, 20 Jul 2012 14:26:54 -0700 (PDT)
Message-ID: <20120720.142654.968750286623305835.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55719 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753575Ab2GTV0z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 17:26:55 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 336A5583615
	for <netdev@vger.kernel.org>; Fri, 20 Jul 2012 14:26:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


That is this value's only use, as a boolean to indicate whether
a route is an input route or not.

So implement it that way, using a u16 gap present in the struct
already.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/route.h     |    6 +++---
 net/ipv4/route.c        |   10 +++++-----
 net/ipv4/xfrm4_policy.c |    2 +-
 3 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index e789a92..4bafe0b 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -47,8 +47,8 @@ struct rtable {
 	int			rt_genid;
 	unsigned int		rt_flags;
 	__u16			rt_type;
+	__u16			rt_is_input;
 
-	int			rt_route_iif;
 	int			rt_iif;
 
 	/* Info on neighbour */
@@ -61,12 +61,12 @@ struct rtable {
 
 static inline bool rt_is_input_route(const struct rtable *rt)
 {
-	return rt->rt_route_iif != 0;
+	return rt->rt_is_input != 0;
 }
 
 static inline bool rt_is_output_route(const struct rtable *rt)
 {
-	return rt->rt_route_iif == 0;
+	return rt->rt_is_input == 0;
 }
 
 static inline __be32 rt_nexthop(const struct rtable *rt, __be32 daddr)
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index a280b6a..fac4c4a 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1330,7 +1330,7 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	rth->rt_genid	= rt_genid(dev_net(dev));
 	rth->rt_flags	= RTCF_MULTICAST;
 	rth->rt_type	= RTN_MULTICAST;
-	rth->rt_route_iif = dev->ifindex;
+	rth->rt_is_input= 1;
 	rth->rt_iif	= dev->ifindex;
 	rth->rt_pmtu	= 0;
 	rth->rt_gateway	= 0;
@@ -1460,7 +1460,7 @@ static int __mkroute_input(struct sk_buff *skb,
 	rth->rt_genid = rt_genid(dev_net(rth->dst.dev));
 	rth->rt_flags = flags;
 	rth->rt_type = res->type;
-	rth->rt_route_iif = in_dev->dev->ifindex;
+	rth->rt_is_input = 1;
 	rth->rt_iif 	= in_dev->dev->ifindex;
 	rth->rt_pmtu	= 0;
 	rth->rt_gateway	= 0;
@@ -1638,7 +1638,7 @@ local_input:
 	rth->rt_genid = rt_genid(net);
 	rth->rt_flags 	= flags|RTCF_LOCAL;
 	rth->rt_type	= res.type;
-	rth->rt_route_iif = dev->ifindex;
+	rth->rt_is_input = 1;
 	rth->rt_iif	= dev->ifindex;
 	rth->rt_pmtu	= 0;
 	rth->rt_gateway	= 0;
@@ -1803,7 +1803,7 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 	rth->rt_genid = rt_genid(dev_net(dev_out));
 	rth->rt_flags	= flags;
 	rth->rt_type	= type;
-	rth->rt_route_iif = 0;
+	rth->rt_is_input = 0;
 	rth->rt_iif	= orig_oif ? : dev_out->ifindex;
 	rth->rt_pmtu	= 0;
 	rth->rt_gateway = 0;
@@ -2079,7 +2079,7 @@ struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_or
 		if (new->dev)
 			dev_hold(new->dev);
 
-		rt->rt_route_iif = ort->rt_route_iif;
+		rt->rt_is_input = ort->rt_is_input;
 		rt->rt_iif = ort->rt_iif;
 		rt->rt_pmtu = ort->rt_pmtu;
 
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 3c99b4c..c628184 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -79,7 +79,6 @@ static int xfrm4_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
 	struct rtable *rt = (struct rtable *)xdst->route;
 	const struct flowi4 *fl4 = &fl->u.ip4;
 
-	xdst->u.rt.rt_route_iif = fl4->flowi4_iif;
 	xdst->u.rt.rt_iif = fl4->flowi4_iif;
 
 	xdst->u.dst.dev = dev;
@@ -87,6 +86,7 @@ static int xfrm4_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
 
 	/* Sheit... I remember I did this right. Apparently,
 	 * it was magically lost, so this code needs audit */
+	xdst->u.rt.rt_is_input = rt->rt_is_input;
 	xdst->u.rt.rt_flags = rt->rt_flags & (RTCF_BROADCAST | RTCF_MULTICAST |
 					      RTCF_LOCAL);
 	xdst->u.rt.rt_type = rt->rt_type;
-- 
1.7.10.4
