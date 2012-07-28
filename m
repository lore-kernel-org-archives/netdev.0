From: David Miller <davem@davemloft.net>
Subject: [PATCH 5/7] ipv4: Make fib_select_default() not depend upon
 fib_result.
Date: Fri, 27 Jul 2012 21:18:34 -0700 (PDT)
Message-ID: <20120727.211834.1950289656482825157.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38993 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751172Ab2G1ESf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jul 2012 00:18:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Pass the arguments and return the result explicitly.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ip_fib.h     |    3 ++-
 net/ipv4/fib_semantics.c |   19 +++++++++----------
 net/ipv4/route.c         |    2 +-
 3 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 43be7230..8a57513 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -267,7 +267,8 @@ extern __be32 fib_compute_spec_dst(struct sk_buff *skb);
 extern int fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
 			       u8 tos, int oif, struct net_device *dev,
 			       struct in_device *idev, u32 *itag);
-extern void fib_select_default(struct fib_result *res);
+extern struct fib_nh *fib_select_default(struct fib_nh *nh, struct list_head *fa_head,
+					 struct fib_table *tb);
 #ifdef CONFIG_IP_ROUTE_CLASSID
 static inline int fib_num_tclassid_users(struct net *net)
 {
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index bf4c809..4c7b55c 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -1134,11 +1134,10 @@ int fib_sync_down_dev(struct net_device *dev, int force)
 }
 
 /* Must be invoked inside of an RCU protected region.  */
-void fib_select_default(struct fib_result *res)
+struct fib_nh *fib_select_default(struct fib_nh *res_nh, struct list_head *fa_head,
+				  struct fib_table *tb)
 {
 	struct fib_nh *nh = NULL, *last_resort = NULL;
-	struct list_head *fa_head = res->fa_head;
-	struct fib_table *tb = res->table;
 	int order = -1, last_idx = -1;
 	struct fib_alias *fa;
 
@@ -1146,12 +1145,12 @@ void fib_select_default(struct fib_result *res)
 		struct fib_nh *next_nh = &fa->fa_info->fib_nh[0];
 
 		if ((next_nh->nh_parent->fib_scope !=
-		     res->nh->nh_parent->fib_scope) ||
+		     res_nh->nh_parent->fib_scope) ||
 		    next_nh->nh_parent->fib_type != RTN_UNICAST)
 			continue;
 
 		if (next_nh->nh_parent->fib_priority >
-		    res->nh->nh_parent->fib_priority)
+		    res_nh->nh_parent->fib_priority)
 			break;
 
 		if (!next_nh->nh_gw || next_nh->nh_scope != RT_SCOPE_LINK)
@@ -1160,11 +1159,11 @@ void fib_select_default(struct fib_result *res)
 		fib_alias_accessed(fa);
 
 		if (nh == NULL) {
-			if (next_nh != res->nh)
+			if (next_nh != res_nh)
 				break;
 		} else if (!fib_detect_death(nh, order, &last_resort,
 					     &last_idx, tb->tb_default)) {
-			res->nh = nh;
+			res_nh = nh;
 			tb->tb_default = order;
 			goto out;
 		}
@@ -1179,16 +1178,16 @@ void fib_select_default(struct fib_result *res)
 
 	if (!fib_detect_death(nh, order, &last_resort, &last_idx,
 			      tb->tb_default)) {
-		res->nh = nh;
+		res_nh = nh;
 		tb->tb_default = order;
 		goto out;
 	}
 
 	if (last_idx >= 0)
-		res->nh = last_resort;
+		res_nh = last_resort;
 	tb->tb_default = last_idx;
 out:
-	return;
+	return res_nh;
 }
 
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 597fbc0..9a247ff 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1970,7 +1970,7 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 	if (!res.nh->nh_parent->fib_prefixlen &&
 	    res.table->tb_num_default > 1 &&
 	    type == RTN_UNICAST && !fl4->flowi4_oif)
-		fib_select_default(&res);
+		res.nh = fib_select_default(res.nh, res.fa_head, res.table);
 
 	if (!fl4->saddr)
 		fl4->saddr = fib_res_prefsrc(net, &res);
-- 
1.7.10.4
