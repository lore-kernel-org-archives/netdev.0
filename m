From: David Miller <davem@davemloft.net>
Subject: [PATCH 13/16] ipv4: Enforce max MTU metric at route insertion time.
Date: Tue, 10 Jul 2012 08:07:49 -0700 (PDT)
Message-ID: <20120710.080749.904581179343385945.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38427 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754874Ab2GJPHt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 11:07:49 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id C0785586620
	for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 08:07:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Rather than at every struct rtable creation.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/fib_semantics.c |    2 ++
 net/ipv4/route.c         |    7 +------
 2 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index ae301c8..d71bfbd 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -794,6 +794,8 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 				val = nla_get_u32(nla);
 				if (type == RTAX_ADVMSS && val > 65535 - 40)
 					val = 65535 - 40;
+				if (type == RTAX_MTU && val > 65535 - 15)
+					val = 65535 - 15;
 				fi->fib_metrics[type - 1] = val;
 			}
 		}
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 677d652..1678b57 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1763,21 +1763,16 @@ static void rt_set_nexthop(struct rtable *rt, const struct flowi4 *fl4,
 			   const struct fib_result *res,
 			   struct fib_info *fi, u16 type, u32 itag)
 {
-	struct dst_entry *dst = &rt->dst;
-
 	if (fi) {
 		if (FIB_RES_GW(*res) &&
 		    FIB_RES_NH(*res).nh_scope == RT_SCOPE_LINK)
 			rt->rt_gateway = FIB_RES_GW(*res);
 		rt_init_metrics(rt, fl4, fi);
 #ifdef CONFIG_IP_ROUTE_CLASSID
-		dst->tclassid = FIB_RES_NH(*res).nh_tclassid;
+		rt->dst.tclassid = FIB_RES_NH(*res).nh_tclassid;
 #endif
 	}
 
-	if (dst_mtu(dst) > IP_MAX_MTU)
-		dst_metric_set(dst, RTAX_MTU, IP_MAX_MTU);
-
 #ifdef CONFIG_IP_ROUTE_CLASSID
 #ifdef CONFIG_IP_MULTIPLE_TABLES
 	set_class_tag(rt, fib_rules_tclass(res));
-- 
1.7.10.4
