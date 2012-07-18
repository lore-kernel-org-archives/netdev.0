From: David Miller <davem@davemloft.net>
Subject: [PATCH 13/15] ipv4: Kill rt->rt_oif
Date: Wed, 18 Jul 2012 11:24:37 -0700 (PDT)
Message-ID: <20120718.112437.1514603987324499891.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36956 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755437Ab2GRSYh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 14:24:37 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 79809583FC7
	for <netdev@vger.kernel.org>; Wed, 18 Jul 2012 11:24:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Never actually used.

It was being set on output routes to the original OIF specified in the
flow key used for the lookup.

But the only user was in ipmr_rt_fib_lookup() which always runs on an
input route.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/route.h     |    1 -
 net/ipv4/ipmr.c         |    1 -
 net/ipv4/route.c        |    5 -----
 net/ipv4/xfrm4_policy.c |    1 -
 4 files changed, 8 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index 6d111bc..ee3bf84 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -50,7 +50,6 @@ struct rtable {
 
 	int			rt_route_iif;
 	int			rt_iif;
-	int			rt_oif;
 
 	/* Info on neighbour */
 	__be32			rt_gateway;
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index eee3bf6..fa75f73 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1795,7 +1795,6 @@ static struct mr_table *ipmr_rt_fib_lookup(struct net *net, struct sk_buff *skb)
 		.daddr = iph->daddr,
 		.saddr = iph->saddr,
 		.flowi4_tos = RT_TOS(iph->tos),
-		.flowi4_oif = rt->rt_oif,
 		.flowi4_iif = rt->rt_iif,
 		.flowi4_mark = skb->mark,
 	};
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 2190fc4..4da374c 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1298,7 +1298,6 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	rth->rt_type	= RTN_MULTICAST;
 	rth->rt_route_iif = dev->ifindex;
 	rth->rt_iif	= dev->ifindex;
-	rth->rt_oif	= 0;
 	rth->rt_pmtu	= 0;
 	rth->rt_gateway	= 0;
 	rth->fi = NULL;
@@ -1429,7 +1428,6 @@ static int __mkroute_input(struct sk_buff *skb,
 	rth->rt_type = res->type;
 	rth->rt_route_iif = in_dev->dev->ifindex;
 	rth->rt_iif 	= in_dev->dev->ifindex;
-	rth->rt_oif 	= 0;
 	rth->rt_pmtu	= 0;
 	rth->rt_gateway	= 0;
 	rth->fi = NULL;
@@ -1608,7 +1606,6 @@ local_input:
 	rth->rt_type	= res.type;
 	rth->rt_route_iif = dev->ifindex;
 	rth->rt_iif	= dev->ifindex;
-	rth->rt_oif	= 0;
 	rth->rt_pmtu	= 0;
 	rth->rt_gateway	= 0;
 	rth->fi = NULL;
@@ -1774,7 +1771,6 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 	rth->rt_type	= type;
 	rth->rt_route_iif = 0;
 	rth->rt_iif	= orig_oif ? : dev_out->ifindex;
-	rth->rt_oif	= orig_oif;
 	rth->rt_pmtu	= 0;
 	rth->rt_gateway = 0;
 	rth->fi = NULL;
@@ -2050,7 +2046,6 @@ struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_or
 
 		rt->rt_route_iif = ort->rt_route_iif;
 		rt->rt_iif = ort->rt_iif;
-		rt->rt_oif = ort->rt_oif;
 		rt->rt_pmtu = ort->rt_pmtu;
 
 		rt->rt_genid = rt_genid(net);
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 6074b69..3c99b4c 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -81,7 +81,6 @@ static int xfrm4_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
 
 	xdst->u.rt.rt_route_iif = fl4->flowi4_iif;
 	xdst->u.rt.rt_iif = fl4->flowi4_iif;
-	xdst->u.rt.rt_oif = fl4->flowi4_oif;
 
 	xdst->u.dst.dev = dev;
 	dev_hold(dev);
-- 
1.7.10.4
