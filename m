From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next] neigh: fix the loop index error in neigh dump
Date: Thu, 24 Nov 2016 13:25:09 +0800
Message-ID: <1479965109-14607-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: netdev@vger.kernel.org, dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta2.chinamobile.com ([221.176.66.80]:19747 "EHLO
        cmccmta2.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751169AbcKXF2h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 00:28:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Loop index in neigh dump function is not updated correctly under some
circumstances, this patch will fix it.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 net/core/neighbour.c | 39 ++++++++++++++++++---------------------
 1 file changed, 18 insertions(+), 21 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 2ae929f..ce32e9c 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2256,6 +2256,16 @@ static bool neigh_ifindex_filtered(struct net_device *dev, int filter_idx)
 	return false;
 }
 
+static bool neigh_dump_filtered(struct net_device *dev, int filter_idx,
+		int filter_master_idx)
+{
+	if (neigh_ifindex_filtered(dev, filter_idx) ||
+	    neigh_master_filtered(dev, filter_master_idx))
+		return true;
+
+	return false;
+}
+
 static int neigh_dump_table(struct neigh_table *tbl, struct sk_buff *skb,
 			    struct netlink_callback *cb)
 {
@@ -2285,20 +2295,15 @@ static int neigh_dump_table(struct neigh_table *tbl, struct sk_buff *skb,
 	rcu_read_lock_bh();
 	nht = rcu_dereference_bh(tbl->nht);
 
-	for (h = s_h; h < (1 << nht->hash_shift); h++) {
-		if (h > s_h)
-			s_idx = 0;
+	for (h = s_h; h < (1 << nht->hash_shift); h++, s_idx = 0) {
 		for (n = rcu_dereference_bh(nht->hash_buckets[h]), idx = 0;
 		     n != NULL;
-		     n = rcu_dereference_bh(n->next)) {
-			if (!net_eq(dev_net(n->dev), net))
-				continue;
-			if (neigh_ifindex_filtered(n->dev, filter_idx))
+		     n = rcu_dereference_bh(n->next), idx++) {
+			if (idx < s_idx || !net_eq(dev_net(n->dev), net))
 				continue;
-			if (neigh_master_filtered(n->dev, filter_master_idx))
+			if (neigh_dump_filtered(n->dev, filter_idx,
+						filter_master_idx))
 				continue;
-			if (idx < s_idx)
-				goto next;
 			if (neigh_fill_info(skb, n, NETLINK_CB(cb->skb).portid,
 					    cb->nlh->nlmsg_seq,
 					    RTM_NEWNEIGH,
@@ -2306,8 +2311,6 @@ static int neigh_dump_table(struct neigh_table *tbl, struct sk_buff *skb,
 				rc = -1;
 				goto out;
 			}
-next:
-			idx++;
 		}
 	}
 	rc = skb->len;
@@ -2328,14 +2331,10 @@ static int pneigh_dump_table(struct neigh_table *tbl, struct sk_buff *skb,
 
 	read_lock_bh(&tbl->lock);
 
-	for (h = s_h; h <= PNEIGH_HASHMASK; h++) {
-		if (h > s_h)
-			s_idx = 0;
-		for (n = tbl->phash_buckets[h], idx = 0; n; n = n->next) {
-			if (pneigh_net(n) != net)
+	for (h = s_h; h <= PNEIGH_HASHMASK; h++, s_idx = 0) {
+		for (n = tbl->phash_buckets[h], idx = 0; n; n = n->next, idx++) {
+			if (idx < s_idx || pneigh_net(n) != net)
 				continue;
-			if (idx < s_idx)
-				goto next;
 			if (pneigh_fill_info(skb, n, NETLINK_CB(cb->skb).portid,
 					    cb->nlh->nlmsg_seq,
 					    RTM_NEWNEIGH,
@@ -2344,8 +2343,6 @@ static int pneigh_dump_table(struct neigh_table *tbl, struct sk_buff *skb,
 				rc = -1;
 				goto out;
 			}
-		next:
-			idx++;
 		}
 	}
 
-- 
1.8.3.1
