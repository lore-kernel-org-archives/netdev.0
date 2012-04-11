From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: [PATCH 11/16] batman-adv: allow multiple entries in
	tt_global_entries
Date: Wed, 11 Apr 2012 14:50:44 +0200
Message-ID: <1334148649-25443-12-git-send-email-ordex@autistici.org>
References: <1334148649-25443-1-git-send-email-ordex@autistici.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	Simon Wunderlich <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1334148649-25443-1-git-send-email-ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Simon Wunderlich <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>

as backbone gateways will all independently announce the same clients,
also the tt global table must be able to hold multiple originators per
client entry.

Signed-off-by: Simon Wunderlich <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>
Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
---
 net/batman-adv/translation-table.c |  395 +++++++++++++++++++++++++++---------
 net/batman-adv/types.h             |   11 +-
 2 files changed, 312 insertions(+), 94 deletions(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 5f8c540..9648b0d 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -32,10 +32,8 @@
 
 static void send_roam_adv(struct bat_priv *bat_priv, uint8_t *client,
 			  struct orig_node *orig_node);
-static void _tt_global_del(struct bat_priv *bat_priv,
-			   struct tt_global_entry *tt_global_entry,
-			   const char *message);
 static void tt_purge(struct work_struct *work);
+static void tt_global_del_orig_list(struct tt_global_entry *tt_global_entry);
 
 /* returns 1 if they are the same mac addr */
 static int compare_tt(const struct hlist_node *node, const void *data2)
@@ -125,17 +123,31 @@ static void tt_global_entry_free_rcu(struct rcu_head *rcu)
 	tt_global_entry = container_of(tt_common_entry, struct tt_global_entry,
 				       common);
 
-	if (tt_global_entry->orig_node)
-		orig_node_free_ref(tt_global_entry->orig_node);
-
 	kfree(tt_global_entry);
 }
 
 static void tt_global_entry_free_ref(struct tt_global_entry *tt_global_entry)
 {
-	if (atomic_dec_and_test(&tt_global_entry->common.refcount))
+	if (atomic_dec_and_test(&tt_global_entry->common.refcount)) {
+		tt_global_del_orig_list(tt_global_entry);
 		call_rcu(&tt_global_entry->common.rcu,
 			 tt_global_entry_free_rcu);
+	}
+}
+
+static void tt_orig_list_entry_free_rcu(struct rcu_head *rcu)
+{
+	struct tt_orig_list_entry *orig_entry;
+
+	orig_entry = container_of(rcu, struct tt_orig_list_entry, rcu);
+	atomic_dec(&orig_entry->orig_node->tt_size);
+	orig_node_free_ref(orig_entry->orig_node);
+	kfree(orig_entry);
+}
+
+static void tt_orig_list_entry_free_ref(struct tt_orig_list_entry *orig_entry)
+{
+	call_rcu(&orig_entry->rcu, tt_orig_list_entry_free_rcu);
 }
 
 static void tt_local_event(struct bat_priv *bat_priv, const uint8_t *addr,
@@ -184,6 +196,9 @@ void tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
 	struct bat_priv *bat_priv = netdev_priv(soft_iface);
 	struct tt_local_entry *tt_local_entry = NULL;
 	struct tt_global_entry *tt_global_entry = NULL;
+	struct hlist_head *head;
+	struct hlist_node *node;
+	struct tt_orig_list_entry *orig_entry;
 	int hash_added;
 
 	tt_local_entry = tt_local_hash_find(bat_priv, addr);
@@ -234,14 +249,21 @@ void tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
 
 	/* Check whether it is a roaming! */
 	if (tt_global_entry) {
-		/* This node is probably going to update its tt table */
-		tt_global_entry->orig_node->tt_poss_change = true;
-		/* The global entry has to be marked as ROAMING and has to be
-		 * kept for consistency purpose */
+		/* These node are probably going to update their tt table */
+		head = &tt_global_entry->orig_list;
+		rcu_read_lock();
+		hlist_for_each_entry_rcu(orig_entry, node, head, list) {
+			orig_entry->orig_node->tt_poss_change = true;
+
+			send_roam_adv(bat_priv, tt_global_entry->common.addr,
+				      orig_entry->orig_node);
+		}
+		rcu_read_unlock();
+		/* The global entry has to be marked as ROAMING and
+		 * has to be kept for consistency purpose
+		 */
 		tt_global_entry->common.flags |= TT_CLIENT_ROAM;
 		tt_global_entry->roam_at = jiffies;
-		send_roam_adv(bat_priv, tt_global_entry->common.addr,
-			      tt_global_entry->orig_node);
 	}
 out:
 	if (tt_local_entry)
@@ -492,33 +514,76 @@ static void tt_changes_list_free(struct bat_priv *bat_priv)
 	spin_unlock_bh(&bat_priv->tt_changes_list_lock);
 }
 
+/* find out if an orig_node is already in the list of a tt_global_entry.
+ * returns 1 if found, 0 otherwise
+ */
+static bool tt_global_entry_has_orig(const struct tt_global_entry *entry,
+				     const struct orig_node *orig_node)
+{
+	struct tt_orig_list_entry *tmp_orig_entry;
+	const struct hlist_head *head;
+	struct hlist_node *node;
+	bool found = false;
+
+	rcu_read_lock();
+	head = &entry->orig_list;
+	hlist_for_each_entry_rcu(tmp_orig_entry, node, head, list) {
+		if (tmp_orig_entry->orig_node == orig_node) {
+			found = true;
+			break;
+		}
+	}
+	rcu_read_unlock();
+	return found;
+}
+
+static void tt_global_add_orig_entry(struct tt_global_entry *tt_global_entry,
+				     struct orig_node *orig_node,
+				     int ttvn)
+{
+	struct tt_orig_list_entry *orig_entry;
+
+	orig_entry = kzalloc(sizeof(*orig_entry), GFP_ATOMIC);
+	if (!orig_entry)
+		return;
+
+	INIT_HLIST_NODE(&orig_entry->list);
+	atomic_inc(&orig_node->refcount);
+	atomic_inc(&orig_node->tt_size);
+	orig_entry->orig_node = orig_node;
+	orig_entry->ttvn = ttvn;
+
+	spin_lock_bh(&tt_global_entry->list_lock);
+	hlist_add_head_rcu(&orig_entry->list,
+			   &tt_global_entry->orig_list);
+	spin_unlock_bh(&tt_global_entry->list_lock);
+}
+
 /* caller must hold orig_node refcount */
 int tt_global_add(struct bat_priv *bat_priv, struct orig_node *orig_node,
 		  const unsigned char *tt_addr, uint8_t ttvn, bool roaming,
 		  bool wifi)
 {
-	struct tt_global_entry *tt_global_entry;
-	struct orig_node *orig_node_tmp;
+	struct tt_global_entry *tt_global_entry = NULL;
 	int ret = 0;
 	int hash_added;
 
 	tt_global_entry = tt_global_hash_find(bat_priv, tt_addr);
 
 	if (!tt_global_entry) {
-		tt_global_entry =
-			kmalloc(sizeof(*tt_global_entry),
-				GFP_ATOMIC);
+		tt_global_entry = kzalloc(sizeof(*tt_global_entry),
+					  GFP_ATOMIC);
 		if (!tt_global_entry)
 			goto out;
 
 		memcpy(tt_global_entry->common.addr, tt_addr, ETH_ALEN);
+
 		tt_global_entry->common.flags = NO_FLAGS;
+		tt_global_entry->roam_at = 0;
 		atomic_set(&tt_global_entry->common.refcount, 2);
-		/* Assign the new orig_node */
-		atomic_inc(&orig_node->refcount);
-		tt_global_entry->orig_node = orig_node;
-		tt_global_entry->ttvn = ttvn;
-		tt_global_entry->roam_at = 0;
+
+		INIT_HLIST_HEAD(&tt_global_entry->orig_list);
+		spin_lock_init(&tt_global_entry->list_lock);
 
 		hash_added = hash_add(bat_priv->tt_global_hash, compare_tt,
 				 choose_orig, &tt_global_entry->common,
@@ -529,19 +594,27 @@ int tt_global_add(struct bat_priv *bat_priv, struct orig_node *orig_node,
 			tt_global_entry_free_ref(tt_global_entry);
 			goto out_remove;
 		}
-		atomic_inc(&orig_node->tt_size);
+
+		tt_global_add_orig_entry(tt_global_entry, orig_node, ttvn);
 	} else {
-		if (tt_global_entry->orig_node != orig_node) {
-			atomic_dec(&tt_global_entry->orig_node->tt_size);
-			orig_node_tmp = tt_global_entry->orig_node;
-			atomic_inc(&orig_node->refcount);
-			tt_global_entry->orig_node = orig_node;
-			orig_node_free_ref(orig_node_tmp);
-			atomic_inc(&orig_node->tt_size);
+		/* there is already a global entry, use this one. */
+
+		/* If there is the TT_CLIENT_ROAM flag set, there is only one
+		 * originator left in the list and we previously received a
+		 * delete + roaming change for this originator.
+		 *
+		 * We should first delete the old originator before adding the
+		 * new one.
+		 */
+		if (tt_global_entry->common.flags & TT_CLIENT_ROAM) {
+			tt_global_del_orig_list(tt_global_entry);
+			tt_global_entry->common.flags &= ~TT_CLIENT_ROAM;
+			tt_global_entry->roam_at = 0;
 		}
-		tt_global_entry->common.flags = NO_FLAGS;
-		tt_global_entry->ttvn = ttvn;
-		tt_global_entry->roam_at = 0;
+
+		if (!tt_global_entry_has_orig(tt_global_entry, orig_node))
+			tt_global_add_orig_entry(tt_global_entry, orig_node,
+						 ttvn);
 	}
 
 	if (wifi)
@@ -562,6 +635,34 @@ out:
 	return ret;
 }
 
+/* print all orig nodes who announce the address for this global entry.
+ * it is assumed that the caller holds rcu_read_lock();
+ */
+static void tt_global_print_entry(struct tt_global_entry *tt_global_entry,
+				  struct seq_file *seq)
+{
+	struct hlist_head *head;
+	struct hlist_node *node;
+	struct tt_orig_list_entry *orig_entry;
+	struct tt_common_entry *tt_common_entry;
+	uint16_t flags;
+	uint8_t last_ttvn;
+
+	tt_common_entry = &tt_global_entry->common;
+
+	head = &tt_global_entry->orig_list;
+
+	hlist_for_each_entry_rcu(orig_entry, node, head, list) {
+		flags = tt_common_entry->flags;
+		last_ttvn = atomic_read(&orig_entry->orig_node->last_ttvn);
+		seq_printf(seq, " * %pM  (%3u) via %pM     (%3u)   [%c%c]\n",
+			   tt_global_entry->common.addr, orig_entry->ttvn,
+			   orig_entry->orig_node->orig, last_ttvn,
+			   (flags & TT_CLIENT_ROAM ? 'R' : '.'),
+			   (flags & TT_CLIENT_WIFI ? 'W' : '.'));
+	}
+}
+
 int tt_global_seq_print_text(struct seq_file *seq, void *offset)
 {
 	struct net_device *net_dev = (struct net_device *)seq->private;
@@ -605,18 +706,7 @@ int tt_global_seq_print_text(struct seq_file *seq, void *offset)
 			tt_global_entry = container_of(tt_common_entry,
 						       struct tt_global_entry,
 						       common);
-			seq_printf(seq,
-				   " * %pM  (%3u) via %pM     (%3u)   [%c%c]\n",
-				   tt_global_entry->common.addr,
-				   tt_global_entry->ttvn,
-				   tt_global_entry->orig_node->orig,
-				   (uint8_t) atomic_read(
-						&tt_global_entry->orig_node->
-						last_ttvn),
-				   (tt_global_entry->common.flags &
-				    TT_CLIENT_ROAM ? 'R' : '.'),
-				   (tt_global_entry->common.flags &
-				    TT_CLIENT_WIFI ? 'W' : '.'));
+			tt_global_print_entry(tt_global_entry, seq);
 		}
 		rcu_read_unlock();
 	}
@@ -626,27 +716,103 @@ out:
 	return ret;
 }
 
-static void _tt_global_del(struct bat_priv *bat_priv,
-			   struct tt_global_entry *tt_global_entry,
-			   const char *message)
+/* deletes the orig list of a tt_global_entry */
+static void tt_global_del_orig_list(struct tt_global_entry *tt_global_entry)
 {
-	if (!tt_global_entry)
-		goto out;
+	struct hlist_head *head;
+	struct hlist_node *node, *safe;
+	struct tt_orig_list_entry *orig_entry;
 
+	spin_lock_bh(&tt_global_entry->list_lock);
+	head = &tt_global_entry->orig_list;
+	hlist_for_each_entry_safe(orig_entry, node, safe, head, list) {
+		hlist_del_rcu(node);
+		tt_orig_list_entry_free_ref(orig_entry);
+	}
+	spin_unlock_bh(&tt_global_entry->list_lock);
+
+}
+
+static void tt_global_del_orig_entry(struct bat_priv *bat_priv,
+				     struct tt_global_entry *tt_global_entry,
+				     struct orig_node *orig_node,
+				     const char *message)
+{
+	struct hlist_head *head;
+	struct hlist_node *node, *safe;
+	struct tt_orig_list_entry *orig_entry;
+
+	spin_lock_bh(&tt_global_entry->list_lock);
+	head = &tt_global_entry->orig_list;
+	hlist_for_each_entry_safe(orig_entry, node, safe, head, list) {
+		if (orig_entry->orig_node == orig_node) {
+			bat_dbg(DBG_TT, bat_priv,
+				"Deleting %pM from global tt entry %pM: %s\n",
+				orig_node->orig, tt_global_entry->common.addr,
+				message);
+			hlist_del_rcu(node);
+			tt_orig_list_entry_free_ref(orig_entry);
+		}
+	}
+	spin_unlock_bh(&tt_global_entry->list_lock);
+}
+
+static void tt_global_del_struct(struct bat_priv *bat_priv,
+				 struct tt_global_entry *tt_global_entry,
+				 const char *message)
+{
 	bat_dbg(DBG_TT, bat_priv,
-		"Deleting global tt entry %pM (via %pM): %s\n",
-		tt_global_entry->common.addr, tt_global_entry->orig_node->orig,
-		message);
-
-	atomic_dec(&tt_global_entry->orig_node->tt_size);
+		"Deleting global tt entry %pM: %s\n",
+		tt_global_entry->common.addr, message);
 
 	hash_remove(bat_priv->tt_global_hash, compare_tt, choose_orig,
 		    tt_global_entry->common.addr);
-out:
-	if (tt_global_entry)
-		tt_global_entry_free_ref(tt_global_entry);
+	tt_global_entry_free_ref(tt_global_entry);
+
 }
 
+/* If the client is to be deleted, we check if it is the last origantor entry
+ * within tt_global entry. If yes, we set the TT_CLIENT_ROAM flag and the timer,
+ * otherwise we simply remove the originator scheduled for deletion.
+ */
+static void tt_global_del_roaming(struct bat_priv *bat_priv,
+				  struct tt_global_entry *tt_global_entry,
+				  struct orig_node *orig_node,
+				  const char *message)
+{
+	bool last_entry = true;
+	struct hlist_head *head;
+	struct hlist_node *node;
+	struct tt_orig_list_entry *orig_entry;
+
+	/* no local entry exists, case 1:
+	 * Check if this is the last one or if other entries exist.
+	 */
+
+	rcu_read_lock();
+	head = &tt_global_entry->orig_list;
+	hlist_for_each_entry_rcu(orig_entry, node, head, list) {
+		if (orig_entry->orig_node != orig_node) {
+			last_entry = false;
+			break;
+		}
+	}
+	rcu_read_unlock();
+
+	if (last_entry) {
+		/* its the last one, mark for roaming. */
+		tt_global_entry->common.flags |= TT_CLIENT_ROAM;
+		tt_global_entry->roam_at = jiffies;
+	} else
+		/* there is another entry, we can simply delete this
+		 * one and can still use the other one.
+		 */
+		tt_global_del_orig_entry(bat_priv, tt_global_entry,
+					 orig_node, message);
+}
+
+
+
 static void tt_global_del(struct bat_priv *bat_priv,
 			  struct orig_node *orig_node,
 			  const unsigned char *addr,
@@ -656,30 +822,44 @@ static void tt_global_del(struct bat_priv *bat_priv,
 	struct tt_local_entry *tt_local_entry = NULL;
 
 	tt_global_entry = tt_global_hash_find(bat_priv, addr);
-	if (!tt_global_entry || tt_global_entry->orig_node != orig_node)
+	if (!tt_global_entry)
 		goto out;
 
-	if (!roaming)
-		goto out_del;
+	if (!roaming) {
+		tt_global_del_orig_entry(bat_priv, tt_global_entry, orig_node,
+					 message);
+
+		if (hlist_empty(&tt_global_entry->orig_list))
+			tt_global_del_struct(bat_priv, tt_global_entry,
+					     message);
+
+		goto out;
+	}
 
 	/* if we are deleting a global entry due to a roam
 	 * event, there are two possibilities:
-	 * 1) the client roamed from node A to node B => we mark
+	 * 1) the client roamed from node A to node B => if there
+	 *    is only one originator left for this client, we mark
 	 *    it with TT_CLIENT_ROAM, we start a timer and we
 	 *    wait for node B to claim it. In case of timeout
 	 *    the entry is purged.
+	 *
+	 *    If there are other originators left, we directly delete
+	 *    the originator.
 	 * 2) the client roamed to us => we can directly delete
 	 *    the global entry, since it is useless now. */
+
 	tt_local_entry = tt_local_hash_find(bat_priv,
 					    tt_global_entry->common.addr);
-	if (!tt_local_entry) {
-		tt_global_entry->common.flags |= TT_CLIENT_ROAM;
-		tt_global_entry->roam_at = jiffies;
-		goto out;
-	}
+	if (tt_local_entry) {
+		/* local entry exists, case 2: client roamed to us. */
+		tt_global_del_orig_list(tt_global_entry);
+		tt_global_del_struct(bat_priv, tt_global_entry, message);
+	} else
+		/* no local entry exists, case 1: check for roaming */
+		tt_global_del_roaming(bat_priv, tt_global_entry, orig_node,
+				      message);
 
-out_del:
-	_tt_global_del(bat_priv, tt_global_entry, message);
 
 out:
 	if (tt_global_entry)
@@ -712,11 +892,14 @@ void tt_global_del_orig(struct bat_priv *bat_priv,
 			tt_global_entry = container_of(tt_common_entry,
 						       struct tt_global_entry,
 						       common);
-			if (tt_global_entry->orig_node == orig_node) {
+
+			tt_global_del_orig_entry(bat_priv, tt_global_entry,
+						 orig_node, message);
+
+			if (hlist_empty(&tt_global_entry->orig_list)) {
 				bat_dbg(DBG_TT, bat_priv,
-					"Deleting global tt entry %pM (via %pM): %s\n",
+					"Deleting global tt entry %pM: %s\n",
 					tt_global_entry->common.addr,
-					tt_global_entry->orig_node->orig,
 					message);
 				hlist_del_rcu(node);
 				tt_global_entry_free_ref(tt_global_entry);
@@ -757,7 +940,7 @@ static void tt_global_roam_purge(struct bat_priv *bat_priv)
 			bat_dbg(DBG_TT, bat_priv,
 				"Deleting global tt entry (%pM): Roaming timeout\n",
 				tt_global_entry->common.addr);
-			atomic_dec(&tt_global_entry->orig_node->tt_size);
+
 			hlist_del_rcu(node);
 			tt_global_entry_free_ref(tt_global_entry);
 		}
@@ -820,6 +1003,11 @@ struct orig_node *transtable_search(struct bat_priv *bat_priv,
 	struct tt_local_entry *tt_local_entry = NULL;
 	struct tt_global_entry *tt_global_entry = NULL;
 	struct orig_node *orig_node = NULL;
+	struct neigh_node *router = NULL;
+	struct hlist_head *head;
+	struct hlist_node *node;
+	struct tt_orig_list_entry *orig_entry;
+	int best_tq;
 
 	if (src && atomic_read(&bat_priv->ap_isolation)) {
 		tt_local_entry = tt_local_hash_find(bat_priv, src);
@@ -836,11 +1024,25 @@ struct orig_node *transtable_search(struct bat_priv *bat_priv,
 	if (tt_local_entry && _is_ap_isolated(tt_local_entry, tt_global_entry))
 		goto out;
 
-	if (!atomic_inc_not_zero(&tt_global_entry->orig_node->refcount))
-		goto out;
+	best_tq = 0;
 
-	orig_node = tt_global_entry->orig_node;
+	rcu_read_lock();
+	head = &tt_global_entry->orig_list;
+	hlist_for_each_entry_rcu(orig_entry, node, head, list) {
+		router = orig_node_get_router(orig_entry->orig_node);
+		if (!router)
+			continue;
 
+		if (router->tq_avg > best_tq) {
+			orig_node = orig_entry->orig_node;
+			best_tq = router->tq_avg;
+		}
+		neigh_node_free_ref(router);
+	}
+	/* found anything? */
+	if (orig_node && !atomic_inc_not_zero(&orig_node->refcount))
+		orig_node = NULL;
+	rcu_read_unlock();
 out:
 	if (tt_global_entry)
 		tt_global_entry_free_ref(tt_global_entry);
@@ -872,20 +1074,26 @@ static uint16_t tt_global_crc(struct bat_priv *bat_priv,
 			tt_global_entry = container_of(tt_common_entry,
 						       struct tt_global_entry,
 						       common);
-			if (compare_eth(tt_global_entry->orig_node,
-					orig_node)) {
-				/* Roaming clients are in the global table for
-				 * consistency only. They don't have to be
-				 * taken into account while computing the
-				 * global crc */
-				if (tt_common_entry->flags & TT_CLIENT_ROAM)
-					continue;
-				total_one = 0;
-				for (j = 0; j < ETH_ALEN; j++)
-					total_one = crc16_byte(total_one,
-						tt_common_entry->addr[j]);
-				total ^= total_one;
-			}
+			/* Roaming clients are in the global table for
+			 * consistency only. They don't have to be
+			 * taken into account while computing the
+			 * global crc
+			 */
+			if (tt_global_entry->common.flags & TT_CLIENT_ROAM)
+				continue;
+
+			/* find out if this global entry is announced by this
+			 * originator
+			 */
+			if (!tt_global_entry_has_orig(tt_global_entry,
+						      orig_node))
+				continue;
+
+			total_one = 0;
+			for (j = 0; j < ETH_ALEN; j++)
+				total_one = crc16_byte(total_one,
+					tt_global_entry->common.addr[j]);
+			total ^= total_one;
 		}
 		rcu_read_unlock();
 	}
@@ -1026,7 +1234,7 @@ static int tt_global_valid_entry(const void *entry_ptr, const void *data_ptr)
 	tt_global_entry = container_of(tt_common_entry, struct tt_global_entry,
 				       common);
 
-	return (tt_global_entry->orig_node == orig_node);
+	return tt_global_entry_has_orig(tt_global_entry, orig_node);
 }
 
 static struct sk_buff *tt_response_fill_table(uint16_t tt_len, uint8_t ttvn,
@@ -1802,6 +2010,8 @@ void tt_commit_changes(struct bat_priv *bat_priv)
 
 	/* Increment the TTVN only once per OGM interval */
 	atomic_inc(&bat_priv->ttvn);
+	bat_dbg(DBG_TT, bat_priv, "Local changes committed, updating to ttvn %u\n",
+		(uint8_t)atomic_read(&bat_priv->ttvn));
 	bat_priv->tt_poss_change = false;
 }
 
@@ -1879,6 +2089,7 @@ void tt_update_orig(struct bat_priv *bat_priv, struct orig_node *orig_node,
 	} else {
 		/* if we missed more than one change or our tables are not
 		 * in sync anymore -> request fresh tt data */
+
 		if (!orig_node->tt_initialised || ttvn != orig_ttvn ||
 		    orig_node->tt_crc != tt_crc) {
 request_table:
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 089dd44..35cd831 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -241,11 +241,18 @@ struct tt_local_entry {
 
 struct tt_global_entry {
 	struct tt_common_entry common;
-	struct orig_node *orig_node;
-	uint8_t ttvn;
+	struct hlist_head orig_list;
+	spinlock_t list_lock;	/* protects the list */
 	unsigned long roam_at; /* time at which TT_GLOBAL_ROAM was set */
 };
 
+struct tt_orig_list_entry {
+	struct orig_node *orig_node;
+	uint8_t ttvn;
+	struct rcu_head rcu;
+	struct hlist_node list;
+};
+
 struct backbone_gw {
 	uint8_t orig[ETH_ALEN];
 	short vid;		/* used VLAN ID */
-- 
1.7.9.4
