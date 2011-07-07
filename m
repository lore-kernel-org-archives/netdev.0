From: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Subject: [PATCH 2/4] batman-adv: keep local table consistency
	for further TT_RESPONSE
Date: Fri,  8 Jul 2011 00:33:41 +0200
Message-ID: <1310078023-28958-3-git-send-email-lindner_marek@yahoo.de>
References: <1310078023-28958-1-git-send-email-lindner_marek@yahoo.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1310078023-28958-1-git-send-email-lindner_marek-LWAfsSFWpa4@public.gmane.org>
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

From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>

To keep transtable consistency among all the nodes, an originator must
not send not yet announced clients within a full table TT_RESPONSE.
Instead, deleted client have to be kept in the table in order to be sent
within an immediate TT_RESPONSE. In this way all the nodes in the
network will always provide the same response for the same request.

All the modification are committed at the next ttvn increment event.

Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Signed-off-by: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
---
 net/batman-adv/packet.h            |    4 +-
 net/batman-adv/send.c              |    4 +-
 net/batman-adv/translation-table.c |  146 +++++++++++++++++++++++++++++-------
 net/batman-adv/translation-table.h |    1 +
 4 files changed, 125 insertions(+), 30 deletions(-)

diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 590e4a6..b76b4be 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -84,7 +84,9 @@ enum tt_query_flags {
 enum tt_client_flags {
 	TT_CLIENT_DEL     = 1 << 0,
 	TT_CLIENT_ROAM    = 1 << 1,
-	TT_CLIENT_NOPURGE = 1 << 8
+	TT_CLIENT_NOPURGE = 1 << 8,
+	TT_CLIENT_NEW     = 1 << 9,
+	TT_CLIENT_PENDING = 1 << 10
 };
 
 struct batman_packet {
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 4b8e11b..58d1447 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -309,10 +309,8 @@ void schedule_own_packet(struct hard_iface *hard_iface)
 	if (hard_iface == primary_if) {
 		/* if at least one change happened */
 		if (atomic_read(&bat_priv->tt_local_changes) > 0) {
+			tt_commit_changes(bat_priv);
 			prepare_packet_buffer(bat_priv, hard_iface);
-			/* Increment the TTVN only once per OGM interval */
-			atomic_inc(&bat_priv->ttvn);
-			bat_priv->tt_poss_change = false;
 		}
 
 		/* if the changes have been sent enough times */
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 06d361d..7cc67c0 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -215,11 +215,14 @@ void tt_local_add(struct net_device *soft_iface, const uint8_t *addr)
 
 	tt_local_event(bat_priv, addr, tt_local_entry->flags);
 
+	/* The local entry has to be marked as NEW to avoid to send it in
+	 * a full table response going out before the next ttvn increment
+	 * (consistency check) */
+	tt_local_entry->flags |= TT_CLIENT_NEW;
+
 	hash_add(bat_priv->tt_local_hash, compare_ltt, choose_orig,
 		 tt_local_entry, &tt_local_entry->hash_entry);
 
-	atomic_inc(&bat_priv->num_local_tt);
-
 	/* remove address from global hash if present */
 	tt_global_entry = tt_global_hash_find(bat_priv, addr);
 
@@ -358,19 +361,17 @@ out:
 	return ret;
 }
 
-static void tt_local_del(struct bat_priv *bat_priv,
-			 struct tt_local_entry *tt_local_entry,
-			 const char *message)
+static void tt_local_set_pending(struct bat_priv *bat_priv,
+				 struct tt_local_entry *tt_local_entry,
+				 uint16_t flags)
 {
-	bat_dbg(DBG_TT, bat_priv, "Deleting local tt entry (%pM): %s\n",
-		tt_local_entry->addr, message);
+	tt_local_event(bat_priv, tt_local_entry->addr,
+		       tt_local_entry->flags | flags);
 
-	atomic_dec(&bat_priv->num_local_tt);
-
-	hash_remove(bat_priv->tt_local_hash, compare_ltt, choose_orig,
-		    tt_local_entry->addr);
-
-	tt_local_entry_free_ref(tt_local_entry);
+	/* The local client has to be merked as "pending to be removed" but has
+	 * to be kept in the table in order to send it in an full tables
+	 * response issued before the net ttvn increment (consistency check) */
+	tt_local_entry->flags |= TT_CLIENT_PENDING;
 }
 
 void tt_local_remove(struct bat_priv *bat_priv, const uint8_t *addr,
@@ -379,14 +380,14 @@ void tt_local_remove(struct bat_priv *bat_priv, const uint8_t *addr,
 	struct tt_local_entry *tt_local_entry = NULL;
 
 	tt_local_entry = tt_local_hash_find(bat_priv, addr);
-
 	if (!tt_local_entry)
 		goto out;
 
-	tt_local_event(bat_priv, tt_local_entry->addr,
-		       tt_local_entry->flags | TT_CLIENT_DEL |
-		       (roaming ? TT_CLIENT_ROAM : NO_FLAGS));
-	tt_local_del(bat_priv, tt_local_entry, message);
+	tt_local_set_pending(bat_priv, tt_local_entry, TT_CLIENT_DEL |
+			     (roaming ? TT_CLIENT_ROAM : NO_FLAGS));
+
+	bat_dbg(DBG_TT, bat_priv, "Local tt entry (%pM) pending to be removed: "
+		"%s\n", tt_local_entry->addr, message);
 out:
 	if (tt_local_entry)
 		tt_local_entry_free_ref(tt_local_entry);
@@ -411,18 +412,19 @@ static void tt_local_purge(struct bat_priv *bat_priv)
 			if (tt_local_entry->flags & TT_CLIENT_NOPURGE)
 				continue;
 
+			/* entry already marked for deletion */
+			if (tt_local_entry->flags & TT_CLIENT_PENDING)
+				continue;
+
 			if (!is_out_of_time(tt_local_entry->last_seen,
 					    TT_LOCAL_TIMEOUT * 1000))
 				continue;
 
-			tt_local_event(bat_priv, tt_local_entry->addr,
-				       tt_local_entry->flags | TT_CLIENT_DEL);
-			atomic_dec(&bat_priv->num_local_tt);
-			bat_dbg(DBG_TT, bat_priv, "Deleting local "
-				"tt entry (%pM): timed out\n",
+			tt_local_set_pending(bat_priv, tt_local_entry,
+					     TT_CLIENT_DEL);
+			bat_dbg(DBG_TT, bat_priv, "Local tt entry (%pM) "
+				"pending to be removed: timed out\n",
 				tt_local_entry->addr);
-			hlist_del_rcu(node);
-			tt_local_entry_free_ref(tt_local_entry);
 		}
 		spin_unlock_bh(list_lock);
 	}
@@ -846,6 +848,10 @@ uint16_t tt_local_crc(struct bat_priv *bat_priv)
 		rcu_read_lock();
 		hlist_for_each_entry_rcu(tt_local_entry, node,
 					 head, hash_entry) {
+			/* not yet committed clients have not to be taken into
+			 * account while computing the CRC */
+			if (tt_local_entry->flags & TT_CLIENT_NEW)
+				continue;
 			total_one = 0;
 			for (j = 0; j < ETH_ALEN; j++)
 				total_one = crc16_byte(total_one,
@@ -935,6 +941,16 @@ unlock:
 	return tt_req_node;
 }
 
+/* data_ptr is useless here, but has to be kept to respect the prototype */
+static int tt_local_valid_entry(const void *entry_ptr, const void *data_ptr)
+{
+	const struct tt_local_entry *tt_local_entry = entry_ptr;
+
+	if (tt_local_entry->flags & TT_CLIENT_NEW)
+		return 0;
+	return 1;
+}
+
 static int tt_global_valid_entry(const void *entry_ptr, const void *data_ptr)
 {
 	const struct tt_global_entry *tt_global_entry = entry_ptr;
@@ -1275,7 +1291,8 @@ static bool send_my_tt_response(struct bat_priv *bat_priv,
 
 		skb = tt_response_fill_table(tt_len, ttvn,
 					     bat_priv->tt_local_hash,
-					     primary_if, NULL, NULL);
+					     primary_if, tt_local_valid_entry,
+					     NULL);
 		if (!skb)
 			goto out;
 
@@ -1400,6 +1417,10 @@ bool is_my_client(struct bat_priv *bat_priv, const uint8_t *addr)
 	tt_local_entry = tt_local_hash_find(bat_priv, addr);
 	if (!tt_local_entry)
 		goto out;
+	/* Check if the client has been logically deleted (but is kept for
+	 * consistency purpose) */
+	if (tt_local_entry->flags & TT_CLIENT_PENDING)
+		goto out;
 	ret = true;
 out:
 	if (tt_local_entry)
@@ -1620,3 +1641,76 @@ void tt_free(struct bat_priv *bat_priv)
 
 	kfree(bat_priv->tt_buff);
 }
+
+/* This function will reset the specified flags from all the entries in
+ * the given hash table and will increment num_local_tt for each involved
+ * entry */
+static void tt_local_reset_flags(struct bat_priv *bat_priv, uint16_t flags)
+{
+	int i;
+	struct hashtable_t *hash = bat_priv->tt_local_hash;
+	struct hlist_head *head;
+	struct hlist_node *node;
+	struct tt_local_entry *tt_local_entry;
+
+	if (!hash)
+		return;
+
+	for (i = 0; i < hash->size; i++) {
+		head = &hash->table[i];
+
+		rcu_read_lock();
+		hlist_for_each_entry_rcu(tt_local_entry, node,
+					 head, hash_entry) {
+			tt_local_entry->flags &= ~flags;
+			atomic_inc(&bat_priv->num_local_tt);
+		}
+		rcu_read_unlock();
+	}
+
+}
+
+/* Purge out all the tt local entries marked with TT_CLIENT_PENDING */
+static void tt_local_purge_pending_clients(struct bat_priv *bat_priv)
+{
+	struct hashtable_t *hash = bat_priv->tt_local_hash;
+	struct tt_local_entry *tt_local_entry;
+	struct hlist_node *node, *node_tmp;
+	struct hlist_head *head;
+	spinlock_t *list_lock; /* protects write access to the hash lists */
+	int i;
+
+	if (!hash)
+		return;
+
+	for (i = 0; i < hash->size; i++) {
+		head = &hash->table[i];
+		list_lock = &hash->list_locks[i];
+
+		spin_lock_bh(list_lock);
+		hlist_for_each_entry_safe(tt_local_entry, node, node_tmp,
+					  head, hash_entry) {
+			if (!(tt_local_entry->flags & TT_CLIENT_PENDING))
+				continue;
+
+			bat_dbg(DBG_TT, bat_priv, "Deleting local tt entry "
+				"(%pM): pending\n", tt_local_entry->addr);
+
+			atomic_dec(&bat_priv->num_local_tt);
+			hlist_del_rcu(node);
+			tt_local_entry_free_ref(tt_local_entry);
+		}
+		spin_unlock_bh(list_lock);
+	}
+
+}
+
+void tt_commit_changes(struct bat_priv *bat_priv)
+{
+	tt_local_reset_flags(bat_priv, TT_CLIENT_NEW);
+	tt_local_purge_pending_clients(bat_priv);
+
+	/* Increment the TTVN only once per OGM interval */
+	atomic_inc(&bat_priv->ttvn);
+	bat_priv->tt_poss_change = false;
+}
diff --git a/net/batman-adv/translation-table.h b/net/batman-adv/translation-table.h
index 460e583..d4122cb 100644
--- a/net/batman-adv/translation-table.h
+++ b/net/batman-adv/translation-table.h
@@ -61,5 +61,6 @@ void handle_tt_response(struct bat_priv *bat_priv,
 			struct tt_query_packet *tt_response);
 void send_roam_adv(struct bat_priv *bat_priv, uint8_t *client,
 		   struct orig_node *orig_node);
+void tt_commit_changes(struct bat_priv *bat_priv);
 
 #endif /* _NET_BATMAN_ADV_TRANSLATION_TABLE_H_ */
-- 
1.7.5.3
