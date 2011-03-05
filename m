From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH 23/28] batman-adv: increase refcount in create_neighbor to be consistent
Date: Sat,  5 Mar 2011 13:28:37 +0100
Message-ID: <1299328122-21468-24-git-send-email-sven@narfation.org>
References: <1299328122-21468-1-git-send-email-sven@narfation.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:36346 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753343Ab1CEMaP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Mar 2011 07:30:15 -0500
In-Reply-To: <1299328122-21468-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/originator.c |    4 ++-
 net/batman-adv/routing.c    |   63 ++++++++++++++++++------------------------
 2 files changed, 30 insertions(+), 37 deletions(-)

diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index a70debe..69e27a24 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -94,7 +94,9 @@ struct neigh_node *create_neighbor(struct orig_node *orig_node,
 	memcpy(neigh_node->addr, neigh, ETH_ALEN);
 	neigh_node->orig_node = orig_neigh_node;
 	neigh_node->if_incoming = if_incoming;
-	atomic_set(&neigh_node->refcount, 1);
+
+	/* extra reference for return */
+	atomic_set(&neigh_node->refcount, 2);
 
 	spin_lock_bh(&orig_node->neigh_list_lock);
 	hlist_add_head_rcu(&neigh_node->list, &orig_node->neigh_list);
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 9863c03..c4b7ae9 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -150,7 +150,7 @@ static int is_bidirectional_neigh(struct orig_node *orig_node,
 				struct batman_if *if_incoming)
 {
 	struct bat_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
-	struct neigh_node *neigh_node = NULL, *tmp_neigh_node = NULL;
+	struct neigh_node *neigh_node = NULL, *tmp_neigh_node;
 	struct hlist_node *node;
 	unsigned char total_count;
 	uint8_t orig_eq_count, neigh_rq_count, tq_own;
@@ -161,27 +161,27 @@ static int is_bidirectional_neigh(struct orig_node *orig_node,
 		hlist_for_each_entry_rcu(tmp_neigh_node, node,
 					 &orig_node->neigh_list, list) {
 
-			if (compare_eth(tmp_neigh_node->addr,
-					orig_neigh_node->orig) &&
-			    (tmp_neigh_node->if_incoming == if_incoming))
-				neigh_node = tmp_neigh_node;
+			if (!compare_eth(tmp_neigh_node->addr,
+					 orig_neigh_node->orig))
+				continue;
+
+			if (tmp_neigh_node->if_incoming != if_incoming)
+				continue;
+
+			if (!atomic_inc_not_zero(&tmp_neigh_node->refcount))
+				continue;
+
+			neigh_node = tmp_neigh_node;
 		}
+		rcu_read_unlock();
 
 		if (!neigh_node)
 			neigh_node = create_neighbor(orig_node,
 						     orig_neigh_node,
 						     orig_neigh_node->orig,
 						     if_incoming);
-		/* create_neighbor failed, return 0 */
 		if (!neigh_node)
-			goto unlock;
-
-		if (!atomic_inc_not_zero(&neigh_node->refcount)) {
-			neigh_node = NULL;
-			goto unlock;
-		}
-
-		rcu_read_unlock();
+			goto out;
 
 		neigh_node->last_valid = jiffies;
 	} else {
@@ -190,27 +190,27 @@ static int is_bidirectional_neigh(struct orig_node *orig_node,
 		hlist_for_each_entry_rcu(tmp_neigh_node, node,
 					 &orig_neigh_node->neigh_list, list) {
 
-			if (compare_eth(tmp_neigh_node->addr,
-					orig_neigh_node->orig) &&
-			    (tmp_neigh_node->if_incoming == if_incoming))
-				neigh_node = tmp_neigh_node;
+			if (!compare_eth(tmp_neigh_node->addr,
+					 orig_neigh_node->orig))
+				continue;
+
+			if (tmp_neigh_node->if_incoming != if_incoming)
+				continue;
+
+			if (!atomic_inc_not_zero(&tmp_neigh_node->refcount))
+				continue;
+
+			neigh_node = tmp_neigh_node;
 		}
+		rcu_read_unlock();
 
 		if (!neigh_node)
 			neigh_node = create_neighbor(orig_neigh_node,
 						     orig_neigh_node,
 						     orig_neigh_node->orig,
 						     if_incoming);
-		/* create_neighbor failed, return 0 */
 		if (!neigh_node)
-			goto unlock;
-
-		if (!atomic_inc_not_zero(&neigh_node->refcount)) {
-			neigh_node = NULL;
-			goto unlock;
-		}
-
-		rcu_read_unlock();
+			goto out;
 	}
 
 	orig_node->last_valid = jiffies;
@@ -265,10 +265,6 @@ static int is_bidirectional_neigh(struct orig_node *orig_node,
 	if (batman_packet->tq >= TQ_TOTAL_BIDRECT_LIMIT)
 		ret = 1;
 
-	goto out;
-
-unlock:
-	rcu_read_unlock();
 out:
 	if (neigh_node)
 		neigh_node_free_ref(neigh_node);
@@ -423,11 +419,6 @@ static void update_orig(struct bat_priv *bat_priv,
 		orig_node_free_ref(orig_tmp);
 		if (!neigh_node)
 			goto unlock;
-
-		if (!atomic_inc_not_zero(&neigh_node->refcount)) {
-			neigh_node = NULL;
-			goto unlock;
-		}
 	} else
 		bat_dbg(DBG_BATMAN, bat_priv,
 			"Updating existing last-hop neighbor of originator\n");
-- 
1.7.2.3

