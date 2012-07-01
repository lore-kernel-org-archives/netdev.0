From: David Miller <davem@davemloft.net>
Subject: [PATCH 5/5] ipv4: Remove 'rt_mark' from 'struct rtable'
Date: Sun, 01 Jul 2012 05:03:01 -0700 (PDT)
Message-ID: <20120701.050301.1817456473445899477.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48348 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932239Ab2GAMDB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2012 08:03:01 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 3C65158375B
	for <netdev@vger.kernel.org>; Sun,  1 Jul 2012 05:03:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/route.h     |    1 -
 net/ipv4/ipmr.c         |    2 +-
 net/ipv4/route.c        |    9 ++-------
 net/ipv4/xfrm4_policy.c |    1 -
 4 files changed, 3 insertions(+), 10 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index ad387d2..9face41 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -53,7 +53,6 @@ struct rtable {
 	int			rt_route_iif;
 	int			rt_iif;
 	int			rt_oif;
-	__u32			rt_mark;
 
 	/* Info on neighbour */
 	__be32			rt_gateway;
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index b4ac39f..d472d1d 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1797,7 +1797,7 @@ static struct mr_table *ipmr_rt_fib_lookup(struct net *net, struct sk_buff *skb)
 		.flowi4_tos = RT_TOS(iph->tos),
 		.flowi4_oif = rt->rt_oif,
 		.flowi4_iif = rt->rt_iif,
-		.flowi4_mark = rt->rt_mark,
+		.flowi4_mark = skb->mark,
 	};
 	struct mr_table *mrt;
 	int err;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index a43a39b..f7ad8fd 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1226,7 +1226,6 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	rth->rt_route_iif = dev->ifindex;
 	rth->rt_iif	= dev->ifindex;
 	rth->rt_oif	= 0;
-	rth->rt_mark    = skb->mark;
 	rth->rt_gateway	= daddr;
 	rth->rt_peer_genid = 0;
 	rt_init_peer(rth, dev_net(dev)->ipv4.peers);
@@ -1347,7 +1346,6 @@ static int __mkroute_input(struct sk_buff *skb,
 	rth->rt_route_iif = in_dev->dev->ifindex;
 	rth->rt_iif 	= in_dev->dev->ifindex;
 	rth->rt_oif 	= 0;
-	rth->rt_mark    = skb->mark;
 	rth->rt_gateway	= daddr;
 	rth->rt_peer_genid = 0;
 	rt_init_peer(rth, &res->table->tb_peers);
@@ -1517,7 +1515,6 @@ local_input:
 	rth->rt_route_iif = dev->ifindex;
 	rth->rt_iif	= dev->ifindex;
 	rth->rt_oif	= 0;
-	rth->rt_mark    = skb->mark;
 	rth->rt_gateway	= daddr;
 	rth->rt_peer_genid = 0;
 	rt_init_peer(rth, net->ipv4.peers);
@@ -1672,7 +1669,6 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 	rth->rt_route_iif = 0;
 	rth->rt_iif	= orig_oif ? : dev_out->ifindex;
 	rth->rt_oif	= orig_oif;
-	rth->rt_mark    = fl4->flowi4_mark;
 	rth->rt_gateway = fl4->daddr;
 	rth->rt_peer_genid = 0;
 	rt_init_peer(rth, (res->table ?
@@ -1953,7 +1949,6 @@ struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_or
 		rt->rt_route_iif = ort->rt_route_iif;
 		rt->rt_iif = ort->rt_iif;
 		rt->rt_oif = ort->rt_oif;
-		rt->rt_mark = ort->rt_mark;
 
 		rt->rt_genid = rt_genid(net);
 		rt->rt_flags = ort->rt_flags;
@@ -2046,8 +2041,8 @@ static int rt_fill_info(struct net *net,  __be32 src, struct flowi4 *fl4,
 	if (rtnetlink_put_metrics(skb, dst_metrics_ptr(&rt->dst)) < 0)
 		goto nla_put_failure;
 
-	if (rt->rt_mark &&
-	    nla_put_be32(skb, RTA_MARK, rt->rt_mark))
+	if (fl4->flowi4_mark &&
+	    nla_put_be32(skb, RTA_MARK, fl4->flowi4_mark))
 		goto nla_put_failure;
 
 	error = rt->dst.error;
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 679f4fd..d59eaec 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -82,7 +82,6 @@ static int xfrm4_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
 	xdst->u.rt.rt_route_iif = fl4->flowi4_iif;
 	xdst->u.rt.rt_iif = fl4->flowi4_iif;
 	xdst->u.rt.rt_oif = fl4->flowi4_oif;
-	xdst->u.rt.rt_mark = fl4->flowi4_mark;
 
 	xdst->u.dst.dev = dev;
 	dev_hold(dev);
-- 
1.7.10
