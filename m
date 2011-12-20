From: David Miller <davem@davemloft.net>
Subject: [PATCH 5/5] ipv4: Remove 'rt_mark' from 'struct rtable'
Date: Tue, 20 Dec 2011 16:35:39 -0500 (EST)
Message-ID: <20111220.163539.621914708676431288.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43636 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753018Ab1LTVfl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2011 16:35:41 -0500
Received: from localhost (cpe-66-65-61-233.nyc.res.rr.com [66.65.61.233])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id pBKLZdD7006478
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 20 Dec 2011 13:35:40 -0800
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
index 2c5d300..1664745 100644
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
index 8e54490..49a9f77 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1798,7 +1798,7 @@ static struct mr_table *ipmr_rt_fib_lookup(struct net *net, struct sk_buff *skb)
 		.flowi4_tos = RT_TOS(iph->tos),
 		.flowi4_oif = rt->rt_oif,
 		.flowi4_iif = rt->rt_iif,
-		.flowi4_mark = rt->rt_mark,
+		.flowi4_mark = skb->mark,
 	};
 	struct mr_table *mrt;
 	int err;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 208be60..c48d6fc2 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1223,7 +1223,6 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	rth->rt_route_iif = dev->ifindex;
 	rth->rt_iif	= dev->ifindex;
 	rth->rt_oif	= 0;
-	rth->rt_mark    = skb->mark;
 	rth->rt_gateway	= daddr;
 	rth->rt_spec_dst= spec_dst;
 	rth->rt_peer_genid = 0;
@@ -1353,7 +1352,6 @@ static int __mkroute_input(struct sk_buff *skb,
 	rth->rt_route_iif = in_dev->dev->ifindex;
 	rth->rt_iif 	= in_dev->dev->ifindex;
 	rth->rt_oif 	= 0;
-	rth->rt_mark    = skb->mark;
 	rth->rt_gateway	= daddr;
 	rth->rt_spec_dst= spec_dst;
 	rth->rt_peer_genid = 0;
@@ -1527,7 +1525,6 @@ local_input:
 	rth->rt_route_iif = dev->ifindex;
 	rth->rt_iif	= dev->ifindex;
 	rth->rt_oif	= 0;
-	rth->rt_mark    = skb->mark;
 	rth->rt_gateway	= daddr;
 	rth->rt_spec_dst= spec_dst;
 	rth->rt_peer_genid = 0;
@@ -1687,7 +1684,6 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 	rth->rt_route_iif = 0;
 	rth->rt_iif	= orig_oif ? : dev_out->ifindex;
 	rth->rt_oif	= orig_oif;
-	rth->rt_mark    = fl4->flowi4_mark;
 	rth->rt_gateway = fl4->daddr;
 	rth->rt_spec_dst= fl4->saddr;
 	rth->rt_peer_genid = 0;
@@ -1965,7 +1961,6 @@ struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_or
 		rt->rt_route_iif = ort->rt_route_iif;
 		rt->rt_iif = ort->rt_iif;
 		rt->rt_oif = ort->rt_oif;
-		rt->rt_mark = ort->rt_mark;
 
 		rt->rt_genid = rt_genid(net);
 		rt->rt_flags = ort->rt_flags;
@@ -2057,8 +2052,8 @@ static int rt_fill_info(struct net *net,  __be32 src, struct flowi4 *fl4,
 	if (rtnetlink_put_metrics(skb, dst_metrics_ptr(&rt->dst)) < 0)
 		goto nla_put_failure;
 
-	if (rt->rt_mark)
-		NLA_PUT_BE32(skb, RTA_MARK, rt->rt_mark);
+	if (fl4->flowi4_mark)
+		NLA_PUT_BE32(skb, RTA_MARK, fl4->flowi4_mark);
 
 	error = rt->dst.error;
 	if (peer) {
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 210da0c..677a317 100644
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
1.7.6.401.g6a319
