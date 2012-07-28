From: David Miller <davem@davemloft.net>
Subject: [PATCH 6/7] ipv4: Make fib_select_multipath() not depend upon
 fib_result.
Date: Fri, 27 Jul 2012 21:18:38 -0700 (PDT)
Message-ID: <20120727.211838.1469293796857461119.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38998 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751172Ab2G1ESi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jul 2012 00:18:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Pass the arguments and return the result explicitly.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ip_fib.h     |    2 +-
 net/ipv4/fib_semantics.c |   15 +++++++--------
 net/ipv4/route.c         |    4 ++--
 3 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 8a57513..66f5365 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -287,7 +287,7 @@ extern int fib_sync_down_dev(struct net_device *dev, int force);
 extern int fib_sync_down_addr(struct net *net, __be32 local);
 extern void fib_update_nh_saddrs(struct net_device *dev);
 extern int fib_sync_up(struct net_device *dev);
-extern void fib_select_multipath(struct fib_result *res);
+extern struct fib_nh *fib_select_multipath(struct fib_nh *res_nh);
 
 /* Exported by fib_trie.c */
 extern void fib_trie_init(void);
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 4c7b55c..f83bef3 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -1254,9 +1254,9 @@ int fib_sync_up(struct net_device *dev)
  * The algorithm is suboptimal, but it provides really
  * fair weighted route distribution.
  */
-void fib_select_multipath(struct fib_result *res)
+struct fib_nh *fib_select_multipath(struct fib_nh *res_nh)
 {
-	struct fib_info *fi = res->nh->nh_parent;
+	struct fib_info *fi = res_nh->nh_parent;
 	int w;
 
 	spin_lock_bh(&fib_multipath_lock);
@@ -1272,8 +1272,7 @@ void fib_select_multipath(struct fib_result *res)
 		if (power <= 0) {
 			spin_unlock_bh(&fib_multipath_lock);
 			/* Race condition: route has just become dead. */
-			res->nh = &fi->fib_nh[0];
-			return;
+			return &fi->fib_nh[0];
 		}
 	}
 
@@ -1291,15 +1290,15 @@ void fib_select_multipath(struct fib_result *res)
 			if (w <= 0) {
 				nexthop_nh->nh_power--;
 				fi->fib_power--;
-				res->nh = &fi->fib_nh[nhsel];
 				spin_unlock_bh(&fib_multipath_lock);
-				return;
+				return &fi->fib_nh[nhsel];
 			}
 		}
 	} endfor_nexthops(fi);
 
-	/* Race condition: route has just become dead. */
-	res->nh = &fi->fib_nh[0];
 	spin_unlock_bh(&fib_multipath_lock);
+
+	/* Race condition: route has just become dead. */
+	return &fi->fib_nh[0];
 }
 #endif
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 9a247ff..6b54323 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1461,7 +1461,7 @@ static int ip_mkroute_input(struct sk_buff *skb,
 {
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	if (res->nh->nh_parent->fib_nhs > 1)
-		fib_select_multipath(res);
+		res->nh = fib_select_multipath(res->nh);
 #endif
 
 	/* create a routing cache entry */
@@ -1964,7 +1964,7 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	if (res.nh->nh_parent->fib_nhs > 1 && fl4->flowi4_oif == 0)
-		fib_select_multipath(&res);
+		res.nh = fib_select_multipath(res.nh);
 	else
 #endif
 	if (!res.nh->nh_parent->fib_prefixlen &&
-- 
1.7.10.4
