From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 07/18] batman-adv: add reference counting for type batadv_tt_orig_list_entry
Date: Thu, 23 Aug 2012 15:10:16 +0200
Message-ID: <1345727427-20805-8-git-send-email-ordex@autistici.org>
References: <1345727427-20805-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:28810 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933002Ab2HWNKy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 09:10:54 -0400
In-Reply-To: <1345727427-20805-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The batadv_tt_orig_list_entry structure didn't have any refcounting mechanism so
far. This patch introduces it and makes the structure being usable in much more
complex context.

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/translation-table.c |   77 +++++++++++++++++++++++++-----------
 net/batman-adv/types.h             |    1 +
 2 files changed, 54 insertions(+), 24 deletions(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 99dd8f7..eb8490e 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -152,6 +152,8 @@ static void batadv_tt_orig_list_entry_free_rcu(struct rcu_head *rcu)
 static void
 batadv_tt_orig_list_entry_free_ref(struct batadv_tt_orig_list_entry *orig_entry)
 {
+	if (!atomic_dec_and_test(&orig_entry->refcount))
+		return;
 	/* to avoid race conditions, immediately decrease the tt counter */
 	atomic_dec(&orig_entry->orig_node->tt_size);
 	call_rcu(&orig_entry->rcu, batadv_tt_orig_list_entry_free_rcu);
@@ -625,50 +627,82 @@ static void batadv_tt_changes_list_free(struct batadv_priv *bat_priv)
 	spin_unlock_bh(&bat_priv->tt_changes_list_lock);
 }
 
+/* retrieves the orig_tt_list_entry belonging to orig_node from the
+ * batadv_tt_global_entry list
+ *
+ * returns it with an increased refcounter, NULL if not found
+ */
+static struct batadv_tt_orig_list_entry *
+batadv_tt_global_orig_entry_find(const struct batadv_tt_global_entry *entry,
+				 const struct batadv_orig_node *orig_node)
+{
+	struct batadv_tt_orig_list_entry *tmp_orig_entry, *orig_entry = NULL;
+	const struct hlist_head *head;
+	struct hlist_node *node;
+
+	rcu_read_lock();
+	head = &entry->orig_list;
+	hlist_for_each_entry_rcu(tmp_orig_entry, node, head, list) {
+		if (tmp_orig_entry->orig_node != orig_node)
+			continue;
+		if (!atomic_inc_not_zero(&tmp_orig_entry->refcount))
+			continue;
+
+		orig_entry = tmp_orig_entry;
+		break;
+	}
+	rcu_read_unlock();
+
+	return orig_entry;
+}
+
 /* find out if an orig_node is already in the list of a tt_global_entry.
- * returns 1 if found, 0 otherwise
+ * returns true if found, false otherwise
  */
 static bool
 batadv_tt_global_entry_has_orig(const struct batadv_tt_global_entry *entry,
 				const struct batadv_orig_node *orig_node)
 {
-	struct batadv_tt_orig_list_entry *tmp_orig_entry;
-	const struct hlist_head *head;
-	struct hlist_node *node;
+	struct batadv_tt_orig_list_entry *orig_entry;
 	bool found = false;
 
-	rcu_read_lock();
-	head = &entry->orig_list;
-	hlist_for_each_entry_rcu(tmp_orig_entry, node, head, list) {
-		if (tmp_orig_entry->orig_node == orig_node) {
-			found = true;
-			break;
-		}
+	orig_entry = batadv_tt_global_orig_entry_find(entry, orig_node);
+	if (orig_entry) {
+		found = true;
+		batadv_tt_orig_list_entry_free_ref(orig_entry);
 	}
-	rcu_read_unlock();
+
 	return found;
 }
 
 static void
-batadv_tt_global_add_orig_entry(struct batadv_tt_global_entry *tt_global_entry,
+batadv_tt_global_orig_entry_add(struct batadv_tt_global_entry *tt_global,
 				struct batadv_orig_node *orig_node, int ttvn)
 {
 	struct batadv_tt_orig_list_entry *orig_entry;
 
+	orig_entry = batadv_tt_global_orig_entry_find(tt_global, orig_node);
+	if (orig_entry)
+		goto out;
+
 	orig_entry = kzalloc(sizeof(*orig_entry), GFP_ATOMIC);
 	if (!orig_entry)
-		return;
+		goto out;
 
 	INIT_HLIST_NODE(&orig_entry->list);
 	atomic_inc(&orig_node->refcount);
 	atomic_inc(&orig_node->tt_size);
 	orig_entry->orig_node = orig_node;
 	orig_entry->ttvn = ttvn;
+	atomic_set(&orig_entry->refcount, 2);
 
-	spin_lock_bh(&tt_global_entry->list_lock);
+	spin_lock_bh(&tt_global->list_lock);
 	hlist_add_head_rcu(&orig_entry->list,
-			   &tt_global_entry->orig_list);
-	spin_unlock_bh(&tt_global_entry->list_lock);
+			   &tt_global->orig_list);
+	spin_unlock_bh(&tt_global->list_lock);
+out:
+	if (orig_entry)
+		batadv_tt_orig_list_entry_free_ref(orig_entry);
 }
 
 /* caller must hold orig_node refcount */
@@ -709,9 +743,6 @@ int batadv_tt_global_add(struct batadv_priv *bat_priv,
 			batadv_tt_global_entry_free_ref(tt_global_entry);
 			goto out_remove;
 		}
-
-		batadv_tt_global_add_orig_entry(tt_global_entry, orig_node,
-						ttvn);
 	} else {
 		/* there is already a global entry, use this one. */
 
@@ -728,11 +759,9 @@ int batadv_tt_global_add(struct batadv_priv *bat_priv,
 			tt_global_entry->roam_at = 0;
 		}
 
-		if (!batadv_tt_global_entry_has_orig(tt_global_entry,
-						     orig_node))
-			batadv_tt_global_add_orig_entry(tt_global_entry,
-							orig_node, ttvn);
 	}
+	/* add the new orig_entry (if needed) */
+	batadv_tt_global_orig_entry_add(tt_global_entry, orig_node, ttvn);
 
 	batadv_dbg(BATADV_DBG_TT, bat_priv,
 		   "Creating new global tt entry: %pM (via %pM)\n",
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 7812b6e..664ef81 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -282,6 +282,7 @@ struct batadv_tt_global_entry {
 struct batadv_tt_orig_list_entry {
 	struct batadv_orig_node *orig_node;
 	uint8_t ttvn;
+	atomic_t refcount;
 	struct rcu_head rcu;
 	struct hlist_node list;
 };
-- 
1.7.9.4
