From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv4: Cap ADVMSS metric in the FIB rather than the routing
 cache.
Date: Sun, 17 Jun 2012 19:53:56 -0700 (PDT)
Message-ID: <20120617.195356.1115146370520234751.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38942 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752966Ab2FRCx6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jun 2012 22:53:58 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id EB210585CD2
	for <netdev@vger.kernel.org>; Sun, 17 Jun 2012 19:53:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It makes no sense to execute this limit test every time we create a
routing cache entry.

We can't simply error out on these things since we've silently
accepted and truncated them forever.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/fib_semantics.c |    7 ++++++-
 net/ipv4/route.c         |    2 --
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index e5b7182..415f823 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -779,9 +779,14 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 			int type = nla_type(nla);
 
 			if (type) {
+				u32 val;
+
 				if (type > RTAX_MAX)
 					goto err_inval;
-				fi->fib_metrics[type - 1] = nla_get_u32(nla);
+				val = nla_get_u32(nla);
+				if (type == RTAX_ADVMSS && val > 65535 - 40)
+					val = 65535 - 40;
+				fi->fib_metrics[type - 1] = val;
 			}
 		}
 	}
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 41df529..a91f6d3 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1951,8 +1951,6 @@ static void rt_set_nexthop(struct rtable *rt, const struct flowi4 *fl4,
 
 	if (dst_mtu(dst) > IP_MAX_MTU)
 		dst_metric_set(dst, RTAX_MTU, IP_MAX_MTU);
-	if (dst_metric_raw(dst, RTAX_ADVMSS) > 65535 - 40)
-		dst_metric_set(dst, RTAX_ADVMSS, 65535 - 40);
 
 #ifdef CONFIG_IP_ROUTE_CLASSID
 #ifdef CONFIG_IP_MULTIPLE_TABLES
-- 
1.7.10
