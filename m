From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next v2] neigh: remove duplicate check for same neigh
Date: Wed, 30 Nov 2016 11:24:42 +0800
Message-ID: <1480476282-3650-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: netdev@vger.kernel.org, dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta3.chinamobile.com ([221.176.66.81]:38081 "EHLO
        cmccmta3.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753815AbcK3DYv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 22:24:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently loop index 'idx' is used as the index in the neigh list of interest.
It's increased only when the neigh is dumped. It's not the absolute index in
the list. Because there is no info to record which neigh has already be scanned
by previous loop. This will cause the filtered out neighs to be scanned mulitple
times.

This patch make idx as the absolute index in the list, it will increase no matter
whether the neigh is filtered. This will prevent the above problem.

And this is in line with other dump functions.

v2:
 - take David Ahern's advice to do simple change

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 net/core/neighbour.c | 15 +++++----------
 1 file changed, 5 insertions(+), 10 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 2ae929f..782dd86 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2291,13 +2291,10 @@ static int neigh_dump_table(struct neigh_table *tbl, struct sk_buff *skb,
 		for (n = rcu_dereference_bh(nht->hash_buckets[h]), idx = 0;
 		     n != NULL;
 		     n = rcu_dereference_bh(n->next)) {
-			if (!net_eq(dev_net(n->dev), net))
-				continue;
-			if (neigh_ifindex_filtered(n->dev, filter_idx))
-				continue;
-			if (neigh_master_filtered(n->dev, filter_master_idx))
-				continue;
-			if (idx < s_idx)
+			if (idx < s_idx || !net_eq(dev_net(n->dev), net))
+				goto next;
+			if (neigh_ifindex_filtered(n->dev, filter_idx) ||
+			    neigh_master_filtered(n->dev, filter_master_idx))
 				goto next;
 			if (neigh_fill_info(skb, n, NETLINK_CB(cb->skb).portid,
 					    cb->nlh->nlmsg_seq,
@@ -2332,9 +2329,7 @@ static int pneigh_dump_table(struct neigh_table *tbl, struct sk_buff *skb,
 		if (h > s_h)
 			s_idx = 0;
 		for (n = tbl->phash_buckets[h], idx = 0; n; n = n->next) {
-			if (pneigh_net(n) != net)
-				continue;
-			if (idx < s_idx)
+			if (idx < s_idx || pneigh_net(n) != net)
 				goto next;
 			if (pneigh_fill_info(skb, n, NETLINK_CB(cb->skb).portid,
 					    cb->nlh->nlmsg_seq,
-- 
1.8.3.1
