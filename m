From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 09/16] batman-adv: adapt the TT component to use the new API functions
Date: Wed, 23 Oct 2013 18:04:56 +0200
Message-ID: <1382544303-2694-10-git-send-email-antonio@meshcoding.com>
References: <1382544303-2694-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:24708 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750847Ab3JWQFy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 12:05:54 -0400
In-Reply-To: <1382544303-2694-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/translation-table.c | 35 ++++++++++++++++++++++++-----------
 1 file changed, 24 insertions(+), 11 deletions(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 1d5a4f5..4c28251 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -1280,18 +1280,20 @@ out:
 }
 
 /* batadv_transtable_best_orig - Get best originator list entry from tt entry
+ * @bat_priv: the bat priv with all the soft interface information
  * @tt_global_entry: global translation table entry to be analyzed
  *
  * This functon assumes the caller holds rcu_read_lock().
  * Returns best originator list entry or NULL on errors.
  */
 static struct batadv_tt_orig_list_entry *
-batadv_transtable_best_orig(struct batadv_tt_global_entry *tt_global_entry)
+batadv_transtable_best_orig(struct batadv_priv *bat_priv,
+			    struct batadv_tt_global_entry *tt_global_entry)
 {
-	struct batadv_neigh_node *router = NULL;
+	struct batadv_neigh_node *router, *best_router = NULL;
+	struct batadv_algo_ops *bao = bat_priv->bat_algo_ops;
 	struct hlist_head *head;
 	struct batadv_tt_orig_list_entry *orig_entry, *best_entry = NULL;
-	int best_tq = 0;
 
 	head = &tt_global_entry->orig_list;
 	hlist_for_each_entry_rcu(orig_entry, head, list) {
@@ -1299,26 +1301,37 @@ batadv_transtable_best_orig(struct batadv_tt_global_entry *tt_global_entry)
 		if (!router)
 			continue;
 
-		if (router->bat_iv.tq_avg > best_tq) {
-			best_entry = orig_entry;
-			best_tq = router->bat_iv.tq_avg;
+		if (best_router &&
+		    bao->bat_neigh_cmp(router, best_router) <= 0) {
+			batadv_neigh_node_free_ref(router);
+			continue;
 		}
 
-		batadv_neigh_node_free_ref(router);
+		/* release the refcount for the "old" best */
+		if (best_router)
+			batadv_neigh_node_free_ref(best_router);
+
+		best_entry = orig_entry;
+		best_router = router;
 	}
 
+	if (best_router)
+		batadv_neigh_node_free_ref(best_router);
+
 	return best_entry;
 }
 
 /* batadv_tt_global_print_entry - print all orig nodes who announce the address
  * for this global entry
+ * @bat_priv: the bat priv with all the soft interface information
  * @tt_global_entry: global translation table entry to be printed
  * @seq: debugfs table seq_file struct
  *
  * This functon assumes the caller holds rcu_read_lock().
  */
 static void
-batadv_tt_global_print_entry(struct batadv_tt_global_entry *tt_global_entry,
+batadv_tt_global_print_entry(struct batadv_priv *bat_priv,
+			     struct batadv_tt_global_entry *tt_global_entry,
 			     struct seq_file *seq)
 {
 	struct batadv_tt_orig_list_entry *orig_entry, *best_entry;
@@ -1331,7 +1344,7 @@ batadv_tt_global_print_entry(struct batadv_tt_global_entry *tt_global_entry,
 	tt_common_entry = &tt_global_entry->common;
 	flags = tt_common_entry->flags;
 
-	best_entry = batadv_transtable_best_orig(tt_global_entry);
+	best_entry = batadv_transtable_best_orig(bat_priv, tt_global_entry);
 	if (best_entry) {
 		vlan = batadv_orig_node_vlan_get(best_entry->orig_node,
 						 tt_common_entry->vid);
@@ -1420,7 +1433,7 @@ int batadv_tt_global_seq_print_text(struct seq_file *seq, void *offset)
 			tt_global = container_of(tt_common_entry,
 						 struct batadv_tt_global_entry,
 						 common);
-			batadv_tt_global_print_entry(tt_global, seq);
+			batadv_tt_global_print_entry(bat_priv, tt_global, seq);
 		}
 		rcu_read_unlock();
 	}
@@ -1808,7 +1821,7 @@ struct batadv_orig_node *batadv_transtable_search(struct batadv_priv *bat_priv,
 		goto out;
 
 	rcu_read_lock();
-	best_entry = batadv_transtable_best_orig(tt_global_entry);
+	best_entry = batadv_transtable_best_orig(bat_priv, tt_global_entry);
 	/* found anything? */
 	if (best_entry)
 		orig_node = best_entry->orig_node;
-- 
1.8.4
