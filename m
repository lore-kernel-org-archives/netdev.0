From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/7] ipv4: Consolidate ipv4 dst allocation logic.
Date: Thu, 17 Feb 2011 16:12:02 -0800 (PST)
Message-ID: <20110217.161202.27795455.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57121
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754591Ab1BRALZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Feb 2011 19:11:25 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 1CF2924C087
	for <netdev@vger.kernel.org>; Thu, 17 Feb 2011 16:12:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This also allows us to combine all the dst->flags settings and avoid
read/modify/write sequences to this struct member.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/route.c |   52 +++++++++++++++++++++-------------------------------
 1 files changed, 21 insertions(+), 31 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index b2b3c9e..79a2871 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1816,6 +1816,21 @@ static void rt_set_nexthop(struct rtable *rt, struct fib_result *res, u32 itag)
 	rt->rt_type = res->type;
 }
 
+static struct rtable *rt_dst_alloc(bool nopolicy, bool noxfrm)
+{
+	struct rtable *rt = dst_alloc(&ipv4_dst_ops);
+	if (rt) {
+		rt->dst.obsolete = -1;
+
+		atomic_set(&rt->dst.__refcnt, 1);
+
+		rt->dst.flags = DST_HOST |
+			(nopolicy ? DST_NOPOLICY : 0) |
+			(noxfrm ? DST_NOXFRM : 0);
+	}
+	return rt;
+}
+
 /* called in rcu_read_lock() section */
 static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 				u8 tos, struct net_device *dev, int our)
@@ -1846,17 +1861,12 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 		if (err < 0)
 			goto e_err;
 	}
-	rth = dst_alloc(&ipv4_dst_ops);
+	rth = rt_dst_alloc(IN_DEV_CONF_GET(in_dev, NOPOLICY), false);
 	if (!rth)
 		goto e_nobufs;
 
 	rth->dst.output = ip_rt_bug;
-	rth->dst.obsolete = -1;
 
-	atomic_set(&rth->dst.__refcnt, 1);
-	rth->dst.flags= DST_HOST;
-	if (IN_DEV_CONF_GET(in_dev, NOPOLICY))
-		rth->dst.flags |= DST_NOPOLICY;
 	rth->fl.fl4_dst	= daddr;
 	rth->rt_dst	= daddr;
 	rth->fl.fl4_tos	= tos;
@@ -1985,19 +1995,13 @@ static int __mkroute_input(struct sk_buff *skb,
 		}
 	}
 
-
-	rth = dst_alloc(&ipv4_dst_ops);
+	rth = rt_dst_alloc(IN_DEV_CONF_GET(in_dev, NOPOLICY),
+			   IN_DEV_CONF_GET(out_dev, NOXFRM));
 	if (!rth) {
 		err = -ENOBUFS;
 		goto cleanup;
 	}
 
-	atomic_set(&rth->dst.__refcnt, 1);
-	rth->dst.flags= DST_HOST;
-	if (IN_DEV_CONF_GET(in_dev, NOPOLICY))
-		rth->dst.flags |= DST_NOPOLICY;
-	if (IN_DEV_CONF_GET(out_dev, NOXFRM))
-		rth->dst.flags |= DST_NOXFRM;
 	rth->fl.fl4_dst	= daddr;
 	rth->rt_dst	= daddr;
 	rth->fl.fl4_tos	= tos;
@@ -2012,7 +2016,6 @@ static int __mkroute_input(struct sk_buff *skb,
 	rth->fl.oif 	= 0;
 	rth->rt_spec_dst= spec_dst;
 
-	rth->dst.obsolete = -1;
 	rth->dst.input = ip_forward;
 	rth->dst.output = ip_output;
 	rth->rt_genid = rt_genid(dev_net(rth->dst.dev));
@@ -2162,18 +2165,13 @@ brd_input:
 	RT_CACHE_STAT_INC(in_brd);
 
 local_input:
-	rth = dst_alloc(&ipv4_dst_ops);
+	rth = rt_dst_alloc(IN_DEV_CONF_GET(in_dev, NOPOLICY), false);
 	if (!rth)
 		goto e_nobufs;
 
 	rth->dst.output= ip_rt_bug;
-	rth->dst.obsolete = -1;
 	rth->rt_genid = rt_genid(net);
 
-	atomic_set(&rth->dst.__refcnt, 1);
-	rth->dst.flags= DST_HOST;
-	if (IN_DEV_CONF_GET(in_dev, NOPOLICY))
-		rth->dst.flags |= DST_NOPOLICY;
 	rth->fl.fl4_dst	= daddr;
 	rth->rt_dst	= daddr;
 	rth->fl.fl4_tos	= tos;
@@ -2366,18 +2364,11 @@ static struct rtable *__mkroute_output(struct fib_result *res,
 			res->fi = NULL;
 	}
 
-
-	rth = dst_alloc(&ipv4_dst_ops);
+	rth = rt_dst_alloc(IN_DEV_CONF_GET(in_dev, NOPOLICY),
+			   IN_DEV_CONF_GET(in_dev, NOXFRM));
 	if (!rth)
 		return ERR_PTR(-ENOBUFS);
 
-	atomic_set(&rth->dst.__refcnt, 1);
-	rth->dst.flags= DST_HOST;
-	if (IN_DEV_CONF_GET(in_dev, NOXFRM))
-		rth->dst.flags |= DST_NOXFRM;
-	if (IN_DEV_CONF_GET(in_dev, NOPOLICY))
-		rth->dst.flags |= DST_NOPOLICY;
-
 	rth->fl.fl4_dst	= oldflp->fl4_dst;
 	rth->fl.fl4_tos	= tos;
 	rth->fl.fl4_src	= oldflp->fl4_src;
@@ -2394,7 +2385,6 @@ static struct rtable *__mkroute_output(struct fib_result *res,
 	rth->rt_spec_dst= fl->fl4_src;
 
 	rth->dst.output=ip_output;
-	rth->dst.obsolete = -1;
 	rth->rt_genid = rt_genid(dev_net(dev_out));
 
 	RT_CACHE_STAT_INC(out_slow_tot);
-- 
1.7.4.1

