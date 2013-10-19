From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 17/18] batman-adv: make the TT global purge routine VLAN specific
Date: Sun, 20 Oct 2013 00:22:09 +0200
Message-ID: <1382221330-3769-18-git-send-email-antonio@meshcoding.com>
References: <1382221330-3769-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Simon Wunderlich <siwu@hrz.tu-chemnitz.de>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:30773 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753045Ab3JSWjg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Oct 2013 18:39:36 -0400
In-Reply-To: <1382221330-3769-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

Instead of unconditionally removing all the TT entries
served by a given originator, make tt_global_orig_del()
remove only entries matching a given VLAN identifier
provided as argument.

If such argument is negative all the global entries
served by the originator are removed.

This change is used into the BLA code to purge entries
served by a newly discovered Backbone node, but limiting
the operation only to those connected to the VLAN where the
backbone has been discovered.

Cc: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/bridge_loop_avoidance.c |  4 ++--
 net/batman-adv/originator.c            |  2 +-
 net/batman-adv/routing.c               |  2 +-
 net/batman-adv/translation-table.c     | 17 ++++++++++++++++-
 net/batman-adv/translation-table.h     |  2 +-
 5 files changed, 21 insertions(+), 6 deletions(-)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index e8a6458..3b3867db 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -411,10 +411,10 @@ batadv_bla_get_backbone_gw(struct batadv_priv *bat_priv, uint8_t *orig,
 		return NULL;
 	}
 
-	/* this is a gateway now, remove any tt entries */
+	/* this is a gateway now, remove any TT entry on this VLAN */
 	orig_node = batadv_orig_hash_find(bat_priv, orig);
 	if (orig_node) {
-		batadv_tt_global_del_orig(bat_priv, orig_node,
+		batadv_tt_global_del_orig(bat_priv, orig_node, vid,
 					  "became a backbone gateway");
 		batadv_orig_node_free_ref(orig_node);
 	}
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 7a499da..ee1d847 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -230,7 +230,7 @@ static void batadv_orig_node_free_rcu(struct rcu_head *rcu)
 
 	batadv_frag_purge_orig(orig_node, NULL);
 
-	batadv_tt_global_del_orig(orig_node->bat_priv, orig_node,
+	batadv_tt_global_del_orig(orig_node->bat_priv, orig_node, -1,
 				  "originator timed out");
 
 	kfree(orig_node->tt_buff);
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 149ef57..4bcf221 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -47,7 +47,7 @@ static void _batadv_update_route(struct batadv_priv *bat_priv,
 	if ((curr_router) && (!neigh_node)) {
 		batadv_dbg(BATADV_DBG_ROUTES, bat_priv,
 			   "Deleting route towards: %pM\n", orig_node->orig);
-		batadv_tt_global_del_orig(bat_priv, orig_node,
+		batadv_tt_global_del_orig(bat_priv, orig_node, -1,
 					  "Deleted route towards originator");
 
 	/* route added */
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 41a8387..4c313ff 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -1581,8 +1581,18 @@ out:
 		batadv_tt_local_entry_free_ref(local_entry);
 }
 
+/**
+ * batadv_tt_global_del_orig - remove all the TT global entries belonging to the
+ *  given originator matching the provided vid
+ * @bat_priv: the bat priv with all the soft interface information
+ * @orig_node: the originator owning the entries to remove
+ * @match_vid: the VLAN identifier to match. If negative all the entries will be
+ *  removed
+ * @message: debug message to print as "reason"
+ */
 void batadv_tt_global_del_orig(struct batadv_priv *bat_priv,
 			       struct batadv_orig_node *orig_node,
+			       int32_t match_vid,
 			       const char *message)
 {
 	struct batadv_tt_global_entry *tt_global;
@@ -1604,6 +1614,10 @@ void batadv_tt_global_del_orig(struct batadv_priv *bat_priv,
 		spin_lock_bh(list_lock);
 		hlist_for_each_entry_safe(tt_common_entry, safe,
 					  head, hash_entry) {
+			/* remove only matching entries */
+			if (match_vid >= 0 && tt_common_entry->vid != match_vid)
+				continue;
+
 			tt_global = container_of(tt_common_entry,
 						 struct batadv_tt_global_entry,
 						 common);
@@ -2570,7 +2584,8 @@ static void batadv_tt_fill_gtable(struct batadv_priv *bat_priv,
 		goto out;
 
 	/* Purge the old table first.. */
-	batadv_tt_global_del_orig(bat_priv, orig_node, "Received full table");
+	batadv_tt_global_del_orig(bat_priv, orig_node, -1,
+				  "Received full table");
 
 	_batadv_tt_update_changes(bat_priv, orig_node, tt_change, num_entries,
 				  ttvn);
diff --git a/net/batman-adv/translation-table.h b/net/batman-adv/translation-table.h
index c6bf33c..dc6db4e 100644
--- a/net/batman-adv/translation-table.h
+++ b/net/batman-adv/translation-table.h
@@ -30,7 +30,7 @@ int batadv_tt_local_seq_print_text(struct seq_file *seq, void *offset);
 int batadv_tt_global_seq_print_text(struct seq_file *seq, void *offset);
 void batadv_tt_global_del_orig(struct batadv_priv *bat_priv,
 			       struct batadv_orig_node *orig_node,
-			       const char *message);
+			       int32_t match_vid, const char *message);
 struct batadv_orig_node *batadv_transtable_search(struct batadv_priv *bat_priv,
 						  const uint8_t *src,
 						  const uint8_t *addr,
-- 
1.8.4
