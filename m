From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH 08/12] batman-adv: protect the local and the global trans-tables with rcu
Date: Mon, 20 Jun 2011 12:17:01 +0200
Message-ID: <1308565025-21293-9-git-send-email-sven@narfation.org>
References: <1308565025-21293-1-git-send-email-sven@narfation.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	Sven Eckelmann <sven@narfation.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:57172 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753927Ab1FTKRf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jun 2011 06:17:35 -0400
In-Reply-To: <1308565025-21293-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <ordex@autistici.org>

The local and the global translation-tables are now lock free and rcu
protected.

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
Acked-by: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
---
 net/batman-adv/main.c              |    2 -
 net/batman-adv/routing.c           |    2 -
 net/batman-adv/translation-table.c |  255 ++++++++++++++++++++----------------
 net/batman-adv/types.h             |    6 +-
 net/batman-adv/vis.c               |   13 +-
 5 files changed, 150 insertions(+), 128 deletions(-)

diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 3318ee2..c2b06b7 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -84,8 +84,6 @@ int mesh_init(struct net_device *soft_iface)
 
 	spin_lock_init(&bat_priv->forw_bat_list_lock);
 	spin_lock_init(&bat_priv->forw_bcast_list_lock);
-	spin_lock_init(&bat_priv->tt_lhash_lock);
-	spin_lock_init(&bat_priv->tt_ghash_lock);
 	spin_lock_init(&bat_priv->tt_changes_list_lock);
 	spin_lock_init(&bat_priv->tt_req_list_lock);
 	spin_lock_init(&bat_priv->tt_roam_list_lock);
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 05d50ca..0ce090c 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -90,9 +90,7 @@ static void update_transtable(struct bat_priv *bat_priv,
 		/* Even if we received the crc into the OGM, we prefer
 		 * to recompute it to spot any possible inconsistency
 		 * in the global table */
-		spin_lock_bh(&bat_priv->tt_ghash_lock);
 		orig_node->tt_crc = tt_global_crc(bat_priv, orig_node);
-		spin_unlock_bh(&bat_priv->tt_ghash_lock);
 		/* Roaming phase is over: tables are in sync again. I can
 		 * unset the flag */
 		orig_node->tt_poss_change = false;
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index d516d85..5f1fcd5 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -80,6 +80,9 @@ static struct tt_local_entry *tt_local_hash_find(struct bat_priv *bat_priv,
 		if (!compare_eth(tt_local_entry, data))
 			continue;
 
+		if (!atomic_inc_not_zero(&tt_local_entry->refcount))
+			continue;
+
 		tt_local_entry_tmp = tt_local_entry;
 		break;
 	}
@@ -109,6 +112,9 @@ static struct tt_global_entry *tt_global_hash_find(struct bat_priv *bat_priv,
 		if (!compare_eth(tt_global_entry, data))
 			continue;
 
+		if (!atomic_inc_not_zero(&tt_global_entry->refcount))
+			continue;
+
 		tt_global_entry_tmp = tt_global_entry;
 		break;
 	}
@@ -125,8 +131,20 @@ static bool is_out_of_time(unsigned long starting_time, unsigned long timeout)
 	return time_after(jiffies, deadline);
 }
 
+static void tt_local_entry_free_ref(struct tt_local_entry *tt_local_entry)
+{
+	if (atomic_dec_and_test(&tt_local_entry->refcount))
+		kfree_rcu(tt_local_entry, rcu);
+}
+
+static void tt_global_entry_free_ref(struct tt_global_entry *tt_global_entry)
+{
+	if (atomic_dec_and_test(&tt_global_entry->refcount))
+		kfree_rcu(tt_global_entry, rcu);
+}
+
 static void tt_local_event(struct bat_priv *bat_priv, uint8_t op,
-			   const uint8_t *addr, uint8_t roaming)
+			   const uint8_t *addr, bool roaming)
 {
 	struct tt_change_node *tt_change_node;
 
@@ -171,21 +189,19 @@ static int tt_local_init(struct bat_priv *bat_priv)
 void tt_local_add(struct net_device *soft_iface, const uint8_t *addr)
 {
 	struct bat_priv *bat_priv = netdev_priv(soft_iface);
-	struct tt_local_entry *tt_local_entry;
-	struct tt_global_entry *tt_global_entry;
-	uint8_t roam_addr[ETH_ALEN];
+	struct tt_local_entry *tt_local_entry = NULL;
+	struct tt_global_entry *tt_global_entry = NULL;
 
-	spin_lock_bh(&bat_priv->tt_lhash_lock);
 	tt_local_entry = tt_local_hash_find(bat_priv, addr);
 
 	if (tt_local_entry) {
 		tt_local_entry->last_seen = jiffies;
-		goto unlock;
+		goto out;
 	}
 
 	tt_local_entry = kmalloc(sizeof(*tt_local_entry), GFP_ATOMIC);
 	if (!tt_local_entry)
-		goto unlock;
+		goto out;
 
 	tt_local_event(bat_priv, NO_FLAGS, addr, false);
 
@@ -195,6 +211,7 @@ void tt_local_add(struct net_device *soft_iface, const uint8_t *addr)
 
 	memcpy(tt_local_entry->addr, addr, ETH_ALEN);
 	tt_local_entry->last_seen = jiffies;
+	atomic_set(&tt_local_entry->refcount, 2);
 
 	/* the batman interface mac address should never be purged */
 	if (compare_eth(addr, soft_iface->dev_addr))
@@ -204,30 +221,26 @@ void tt_local_add(struct net_device *soft_iface, const uint8_t *addr)
 
 	hash_add(bat_priv->tt_local_hash, compare_ltt, choose_orig,
 		 tt_local_entry, &tt_local_entry->hash_entry);
+
 	atomic_inc(&bat_priv->num_local_tt);
-	spin_unlock_bh(&bat_priv->tt_lhash_lock);
 
 	/* remove address from global hash if present */
-	spin_lock_bh(&bat_priv->tt_ghash_lock);
-
 	tt_global_entry = tt_global_hash_find(bat_priv, addr);
 
 	/* Check whether it is a roaming! */
 	if (tt_global_entry) {
-		memcpy(roam_addr, tt_global_entry->addr, ETH_ALEN);
 		/* This node is probably going to update its tt table */
 		tt_global_entry->orig_node->tt_poss_change = true;
 		_tt_global_del(bat_priv, tt_global_entry,
 			       "local tt received");
-		spin_unlock_bh(&bat_priv->tt_ghash_lock);
 		send_roam_adv(bat_priv, tt_global_entry->addr,
-			tt_global_entry->orig_node);
-	} else
-		spin_unlock_bh(&bat_priv->tt_ghash_lock);
-
-	return;
-unlock:
-	spin_unlock_bh(&bat_priv->tt_lhash_lock);
+			      tt_global_entry->orig_node);
+	}
+out:
+	if (tt_local_entry)
+		tt_local_entry_free_ref(tt_local_entry);
+	if (tt_global_entry)
+		tt_global_entry_free_ref(tt_global_entry);
 }
 
 int tt_changes_fill_buffer(struct bat_priv *bat_priv,
@@ -309,8 +322,6 @@ int tt_local_seq_print_text(struct seq_file *seq, void *offset)
 		   "announced via TT (TTVN: %u):\n",
 		   net_dev->name, (uint8_t)atomic_read(&bat_priv->ttvn));
 
-	spin_lock_bh(&bat_priv->tt_lhash_lock);
-
 	buf_size = 1;
 	/* Estimate length for: " * xx:xx:xx:xx:xx:xx\n" */
 	for (i = 0; i < hash->size; i++) {
@@ -324,7 +335,6 @@ int tt_local_seq_print_text(struct seq_file *seq, void *offset)
 
 	buff = kmalloc(buf_size, GFP_ATOMIC);
 	if (!buff) {
-		spin_unlock_bh(&bat_priv->tt_lhash_lock);
 		ret = -ENOMEM;
 		goto out;
 	}
@@ -344,8 +354,6 @@ int tt_local_seq_print_text(struct seq_file *seq, void *offset)
 		rcu_read_unlock();
 	}
 
-	spin_unlock_bh(&bat_priv->tt_lhash_lock);
-
 	seq_printf(seq, "%s", buff);
 	kfree(buff);
 out:
@@ -354,15 +362,6 @@ out:
 	return ret;
 }
 
-static void tt_local_entry_free(struct hlist_node *node, void *arg)
-{
-	struct bat_priv *bat_priv = arg;
-	void *data = container_of(node, struct tt_local_entry, hash_entry);
-
-	kfree(data);
-	atomic_dec(&bat_priv->num_local_tt);
-}
-
 static void tt_local_del(struct bat_priv *bat_priv,
 			 struct tt_local_entry *tt_local_entry,
 			 const char *message)
@@ -375,23 +374,24 @@ static void tt_local_del(struct bat_priv *bat_priv,
 	hash_remove(bat_priv->tt_local_hash, compare_ltt, choose_orig,
 		    tt_local_entry->addr);
 
-	tt_local_entry_free(&tt_local_entry->hash_entry, bat_priv);
+	tt_local_entry_free_ref(tt_local_entry);
 }
 
 void tt_local_remove(struct bat_priv *bat_priv, const uint8_t *addr,
 		     const char *message, bool roaming)
 {
-	struct tt_local_entry *tt_local_entry;
+	struct tt_local_entry *tt_local_entry = NULL;
 
-	spin_lock_bh(&bat_priv->tt_lhash_lock);
 	tt_local_entry = tt_local_hash_find(bat_priv, addr);
 
-	if (tt_local_entry) {
-		tt_local_event(bat_priv, TT_CHANGE_DEL, tt_local_entry->addr,
-			       roaming);
-		tt_local_del(bat_priv, tt_local_entry, message);
-	}
-	spin_unlock_bh(&bat_priv->tt_lhash_lock);
+	if (!tt_local_entry)
+		goto out;
+
+	tt_local_event(bat_priv, TT_CHANGE_DEL, tt_local_entry->addr, roaming);
+	tt_local_del(bat_priv, tt_local_entry, message);
+out:
+	if (tt_local_entry)
+		tt_local_entry_free_ref(tt_local_entry);
 }
 
 static void tt_local_purge(struct bat_priv *bat_priv)
@@ -400,40 +400,45 @@ static void tt_local_purge(struct bat_priv *bat_priv)
 	struct tt_local_entry *tt_local_entry;
 	struct hlist_node *node, *node_tmp;
 	struct hlist_head *head;
+	spinlock_t *list_lock; /* protects write access to the hash lists */
 	int i;
 
-	spin_lock_bh(&bat_priv->tt_lhash_lock);
-
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
+		list_lock = &hash->list_locks[i];
 
+		spin_lock_bh(list_lock);
 		hlist_for_each_entry_safe(tt_local_entry, node, node_tmp,
 					  head, hash_entry) {
 			if (tt_local_entry->never_purge)
 				continue;
 
 			if (!is_out_of_time(tt_local_entry->last_seen,
-					   TT_LOCAL_TIMEOUT * 1000))
+					    TT_LOCAL_TIMEOUT * 1000))
 				continue;
 
 			tt_local_event(bat_priv, TT_CHANGE_DEL,
 				       tt_local_entry->addr, false);
-			tt_local_del(bat_priv, tt_local_entry,
-				     "address timed out");
+			atomic_dec(&bat_priv->num_local_tt);
+			bat_dbg(DBG_TT, bat_priv, "Deleting local "
+				"tt entry (%pM): timed out\n",
+				tt_local_entry->addr);
+			hlist_del_rcu(node);
+			tt_local_entry_free_ref(tt_local_entry);
 		}
+		spin_unlock_bh(list_lock);
 	}
 
-	spin_unlock_bh(&bat_priv->tt_lhash_lock);
 }
 
 static void tt_local_table_free(struct bat_priv *bat_priv)
 {
 	struct hashtable_t *hash;
-	int i;
 	spinlock_t *list_lock; /* protects write access to the hash lists */
-	struct hlist_head *head;
-	struct hlist_node *node, *node_tmp;
 	struct tt_local_entry *tt_local_entry;
+	struct hlist_node *node, *node_tmp;
+	struct hlist_head *head;
+	int i;
 
 	if (!bat_priv->tt_local_hash)
 		return;
@@ -448,7 +453,7 @@ static void tt_local_table_free(struct bat_priv *bat_priv)
 		hlist_for_each_entry_safe(tt_local_entry, node, node_tmp,
 					  head, hash_entry) {
 			hlist_del_rcu(node);
-			kfree(tt_local_entry);
+			tt_local_entry_free_ref(tt_local_entry);
 		}
 		spin_unlock_bh(list_lock);
 	}
@@ -492,10 +497,9 @@ int tt_global_add(struct bat_priv *bat_priv, struct orig_node *orig_node,
 		  const unsigned char *tt_addr, uint8_t ttvn, bool roaming)
 {
 	struct tt_global_entry *tt_global_entry;
-	struct tt_local_entry *tt_local_entry;
 	struct orig_node *orig_node_tmp;
+	int ret = 0;
 
-	spin_lock_bh(&bat_priv->tt_ghash_lock);
 	tt_global_entry = tt_global_hash_find(bat_priv, tt_addr);
 
 	if (!tt_global_entry) {
@@ -503,7 +507,8 @@ int tt_global_add(struct bat_priv *bat_priv, struct orig_node *orig_node,
 			kmalloc(sizeof(*tt_global_entry),
 				GFP_ATOMIC);
 		if (!tt_global_entry)
-			goto unlock;
+			goto out;
+
 		memcpy(tt_global_entry->addr, tt_addr, ETH_ALEN);
 		/* Assign the new orig_node */
 		atomic_inc(&orig_node->refcount);
@@ -511,10 +516,12 @@ int tt_global_add(struct bat_priv *bat_priv, struct orig_node *orig_node,
 		tt_global_entry->ttvn = ttvn;
 		tt_global_entry->flags = NO_FLAGS;
 		tt_global_entry->roam_at = 0;
-		atomic_inc(&orig_node->tt_size);
+		atomic_set(&tt_global_entry->refcount, 2);
+
 		hash_add(bat_priv->tt_global_hash, compare_gtt,
 			 choose_orig, tt_global_entry,
 			 &tt_global_entry->hash_entry);
+		atomic_inc(&orig_node->tt_size);
 	} else {
 		if (tt_global_entry->orig_node != orig_node) {
 			atomic_dec(&tt_global_entry->orig_node->tt_size);
@@ -529,25 +536,18 @@ int tt_global_add(struct bat_priv *bat_priv, struct orig_node *orig_node,
 		tt_global_entry->roam_at = 0;
 	}
 
-	spin_unlock_bh(&bat_priv->tt_ghash_lock);
-
 	bat_dbg(DBG_TT, bat_priv,
 		"Creating new global tt entry: %pM (via %pM)\n",
 		tt_global_entry->addr, orig_node->orig);
 
 	/* remove address from local hash if present */
-	spin_lock_bh(&bat_priv->tt_lhash_lock);
-	tt_local_entry = tt_local_hash_find(bat_priv, tt_addr);
-
-	if (tt_local_entry)
-		tt_local_remove(bat_priv, tt_global_entry->addr,
-				"global tt received", roaming);
-
-	spin_unlock_bh(&bat_priv->tt_lhash_lock);
-	return 1;
-unlock:
-	spin_unlock_bh(&bat_priv->tt_ghash_lock);
-	return 0;
+	tt_local_remove(bat_priv, tt_global_entry->addr,
+			"global tt received", roaming);
+	ret = 1;
+out:
+	if (tt_global_entry)
+		tt_global_entry_free_ref(tt_global_entry);
+	return ret;
 }
 
 int tt_global_seq_print_text(struct seq_file *seq, void *offset)
@@ -584,8 +584,6 @@ int tt_global_seq_print_text(struct seq_file *seq, void *offset)
 	seq_printf(seq, "       %-13s %s       %-15s %s\n",
 		   "Client", "(TTVN)", "Originator", "(Curr TTVN)");
 
-	spin_lock_bh(&bat_priv->tt_ghash_lock);
-
 	buf_size = 1;
 	/* Estimate length for: " * xx:xx:xx:xx:xx:xx (ttvn) via
 	 * xx:xx:xx:xx:xx:xx (cur_ttvn)\n"*/
@@ -600,10 +598,10 @@ int tt_global_seq_print_text(struct seq_file *seq, void *offset)
 
 	buff = kmalloc(buf_size, GFP_ATOMIC);
 	if (!buff) {
-		spin_unlock_bh(&bat_priv->tt_ghash_lock);
 		ret = -ENOMEM;
 		goto out;
 	}
+
 	buff[0] = '\0';
 	pos = 0;
 
@@ -625,8 +623,6 @@ int tt_global_seq_print_text(struct seq_file *seq, void *offset)
 		rcu_read_unlock();
 	}
 
-	spin_unlock_bh(&bat_priv->tt_ghash_lock);
-
 	seq_printf(seq, "%s", buff);
 	kfree(buff);
 out:
@@ -640,7 +636,7 @@ static void _tt_global_del(struct bat_priv *bat_priv,
 			   const char *message)
 {
 	if (!tt_global_entry)
-		return;
+		goto out;
 
 	bat_dbg(DBG_TT, bat_priv,
 		"Deleting global tt entry %pM (via %pM): %s\n",
@@ -648,31 +644,35 @@ static void _tt_global_del(struct bat_priv *bat_priv,
 		message);
 
 	atomic_dec(&tt_global_entry->orig_node->tt_size);
+
 	hash_remove(bat_priv->tt_global_hash, compare_gtt, choose_orig,
 		    tt_global_entry->addr);
-	kfree(tt_global_entry);
+out:
+	if (tt_global_entry)
+		tt_global_entry_free_ref(tt_global_entry);
 }
 
 void tt_global_del(struct bat_priv *bat_priv,
 		   struct orig_node *orig_node, const unsigned char *addr,
 		   const char *message, bool roaming)
 {
-	struct tt_global_entry *tt_global_entry;
+	struct tt_global_entry *tt_global_entry = NULL;
 
-	spin_lock_bh(&bat_priv->tt_ghash_lock);
 	tt_global_entry = tt_global_hash_find(bat_priv, addr);
+	if (!tt_global_entry)
+		goto out;
 
-	if (tt_global_entry && tt_global_entry->orig_node == orig_node) {
+	if (tt_global_entry->orig_node == orig_node) {
 		if (roaming) {
 			tt_global_entry->flags |= TT_CLIENT_ROAM;
 			tt_global_entry->roam_at = jiffies;
 			goto out;
 		}
-		atomic_dec(&orig_node->tt_size);
 		_tt_global_del(bat_priv, tt_global_entry, message);
 	}
 out:
-	spin_unlock_bh(&bat_priv->tt_ghash_lock);
+	if (tt_global_entry)
+		tt_global_entry_free_ref(tt_global_entry);
 }
 
 void tt_global_del_orig(struct bat_priv *bat_priv,
@@ -683,30 +683,28 @@ void tt_global_del_orig(struct bat_priv *bat_priv,
 	struct hashtable_t *hash = bat_priv->tt_global_hash;
 	struct hlist_node *node, *safe;
 	struct hlist_head *head;
+	spinlock_t *list_lock; /* protects write access to the hash lists */
 
-	if (!bat_priv->tt_global_hash)
-		return;
-
-	spin_lock_bh(&bat_priv->tt_ghash_lock);
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
+		list_lock = &hash->list_locks[i];
 
+		spin_lock_bh(list_lock);
 		hlist_for_each_entry_safe(tt_global_entry, node, safe,
 					 head, hash_entry) {
-			if (tt_global_entry->orig_node == orig_node)
-				_tt_global_del(bat_priv, tt_global_entry,
-					       message);
+			if (tt_global_entry->orig_node == orig_node) {
+				bat_dbg(DBG_TT, bat_priv,
+					"Deleting global tt entry %pM "
+					"(via %pM): originator time out\n",
+					tt_global_entry->addr,
+					tt_global_entry->orig_node->orig);
+				hlist_del_rcu(node);
+				tt_global_entry_free_ref(tt_global_entry);
+			}
 		}
+		spin_unlock_bh(list_lock);
 	}
 	atomic_set(&orig_node->tt_size, 0);
-
-	spin_unlock_bh(&bat_priv->tt_ghash_lock);
-}
-
-static void tt_global_entry_free(struct hlist_node *node, void *arg)
-{
-	void *data = container_of(node, struct tt_global_entry, hash_entry);
-	kfree(data);
 }
 
 static void tt_global_roam_purge(struct bat_priv *bat_priv)
@@ -715,13 +713,14 @@ static void tt_global_roam_purge(struct bat_priv *bat_priv)
 	struct tt_global_entry *tt_global_entry;
 	struct hlist_node *node, *node_tmp;
 	struct hlist_head *head;
+	spinlock_t *list_lock; /* protects write access to the hash lists */
 	int i;
 
-	spin_lock_bh(&bat_priv->tt_ghash_lock);
-
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
+		list_lock = &hash->list_locks[i];
 
+		spin_lock_bh(list_lock);
 		hlist_for_each_entry_safe(tt_global_entry, node, node_tmp,
 					  head, hash_entry) {
 			if (!(tt_global_entry->flags & TT_CLIENT_ROAM))
@@ -730,20 +729,47 @@ static void tt_global_roam_purge(struct bat_priv *bat_priv)
 					    TT_CLIENT_ROAM_TIMEOUT * 1000))
 				continue;
 
-			_tt_global_del(bat_priv, tt_global_entry,
-				       "Roaming timeout");
+			bat_dbg(DBG_TT, bat_priv, "Deleting global "
+				"tt entry (%pM): Roaming timeout\n",
+				tt_global_entry->addr);
+			atomic_dec(&tt_global_entry->orig_node->tt_size);
+			hlist_del_rcu(node);
+			tt_global_entry_free_ref(tt_global_entry);
 		}
+		spin_unlock_bh(list_lock);
 	}
 
-	spin_unlock_bh(&bat_priv->tt_ghash_lock);
 }
 
 static void tt_global_table_free(struct bat_priv *bat_priv)
 {
+	struct hashtable_t *hash;
+	spinlock_t *list_lock; /* protects write access to the hash lists */
+	struct tt_global_entry *tt_global_entry;
+	struct hlist_node *node, *node_tmp;
+	struct hlist_head *head;
+	int i;
+
 	if (!bat_priv->tt_global_hash)
 		return;
 
-	hash_delete(bat_priv->tt_global_hash, tt_global_entry_free, NULL);
+	hash = bat_priv->tt_global_hash;
+
+	for (i = 0; i < hash->size; i++) {
+		head = &hash->table[i];
+		list_lock = &hash->list_locks[i];
+
+		spin_lock_bh(list_lock);
+		hlist_for_each_entry_safe(tt_global_entry, node, node_tmp,
+					  head, hash_entry) {
+			hlist_del_rcu(node);
+			tt_global_entry_free_ref(tt_global_entry);
+		}
+		spin_unlock_bh(list_lock);
+	}
+
+	hash_destroy(hash);
+
 	bat_priv->tt_global_hash = NULL;
 }
 
@@ -753,19 +779,19 @@ struct orig_node *transtable_search(struct bat_priv *bat_priv,
 	struct tt_global_entry *tt_global_entry;
 	struct orig_node *orig_node = NULL;
 
-	spin_lock_bh(&bat_priv->tt_ghash_lock);
 	tt_global_entry = tt_global_hash_find(bat_priv, addr);
 
 	if (!tt_global_entry)
 		goto out;
 
 	if (!atomic_inc_not_zero(&tt_global_entry->orig_node->refcount))
-		goto out;
+		goto free_tt;
 
 	orig_node = tt_global_entry->orig_node;
 
+free_tt:
+	tt_global_entry_free_ref(tt_global_entry);
 out:
-	spin_unlock_bh(&bat_priv->tt_ghash_lock);
 	return orig_node;
 }
 
@@ -828,7 +854,6 @@ uint16_t tt_local_crc(struct bat_priv *bat_priv)
 						   tt_local_entry->addr[j]);
 			total ^= total_one;
 		}
-
 		rcu_read_unlock();
 	}
 
@@ -1371,15 +1396,17 @@ void tt_update_changes(struct bat_priv *bat_priv, struct orig_node *orig_node,
 
 bool is_my_client(struct bat_priv *bat_priv, const uint8_t *addr)
 {
-	struct tt_local_entry *tt_local_entry;
+	struct tt_local_entry *tt_local_entry = NULL;
+	bool ret = false;
 
-	spin_lock_bh(&bat_priv->tt_lhash_lock);
 	tt_local_entry = tt_local_hash_find(bat_priv, addr);
-	spin_unlock_bh(&bat_priv->tt_lhash_lock);
-
+	if (!tt_local_entry)
+		goto out;
+	ret = true;
+out:
 	if (tt_local_entry)
-		return true;
-	return false;
+		tt_local_entry_free_ref(tt_local_entry);
+	return ret;
 }
 
 void handle_tt_response(struct bat_priv *bat_priv,
@@ -1416,9 +1443,7 @@ void handle_tt_response(struct bat_priv *bat_priv,
 	spin_unlock_bh(&bat_priv->tt_req_list_lock);
 
 	/* Recalculate the CRC for this orig_node and store it */
-	spin_lock_bh(&bat_priv->tt_ghash_lock);
 	orig_node->tt_crc = tt_global_crc(bat_priv, orig_node);
-	spin_unlock_bh(&bat_priv->tt_ghash_lock);
 	/* Roaming phase is over: tables are in sync again. I can
 	 * unset the flag */
 	orig_node->tt_poss_change = false;
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 9c84fa9..11e8569 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -184,8 +184,6 @@ struct bat_priv {
 	spinlock_t forw_bat_list_lock; /* protects forw_bat_list */
 	spinlock_t forw_bcast_list_lock; /* protects  */
 	spinlock_t tt_changes_list_lock; /* protects tt_changes */
-	spinlock_t tt_lhash_lock; /* protects tt_local_hash */
-	spinlock_t tt_ghash_lock; /* protects tt_global_hash */
 	spinlock_t tt_req_list_lock; /* protects tt_req_list */
 	spinlock_t tt_roam_list_lock; /* protects tt_roam_list */
 	spinlock_t gw_list_lock; /* protects gw_list and curr_gw */
@@ -226,6 +224,8 @@ struct tt_local_entry {
 	uint8_t addr[ETH_ALEN];
 	unsigned long last_seen;
 	char never_purge;
+	atomic_t refcount;
+	struct rcu_head rcu;
 	struct hlist_node hash_entry;
 };
 
@@ -235,6 +235,8 @@ struct tt_global_entry {
 	uint8_t ttvn;
 	uint8_t flags; /* only TT_GLOBAL_ROAM is used */
 	unsigned long roam_at; /* time at which TT_GLOBAL_ROAM was set */
+	atomic_t refcount;
+	struct rcu_head rcu;
 	struct hlist_node hash_entry; /* entry in the global table */
 };
 
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index 355c6e5..8a1b985 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -665,11 +665,12 @@ next:
 
 	hash = bat_priv->tt_local_hash;
 
-	spin_lock_bh(&bat_priv->tt_lhash_lock);
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
 
-		hlist_for_each_entry(tt_local_entry, node, head, hash_entry) {
+		rcu_read_lock();
+		hlist_for_each_entry_rcu(tt_local_entry, node, head,
+					 hash_entry) {
 			entry = (struct vis_info_entry *)
 					skb_put(info->skb_packet,
 						sizeof(*entry));
@@ -678,14 +679,12 @@ next:
 			entry->quality = 0; /* 0 means TT */
 			packet->entries++;
 
-			if (vis_packet_full(info)) {
-				spin_unlock_bh(&bat_priv->tt_lhash_lock);
-				return 0;
-			}
+			if (vis_packet_full(info))
+				goto unlock;
 		}
+		rcu_read_unlock();
 	}
 
-	spin_unlock_bh(&bat_priv->tt_lhash_lock);
 	return 0;
 
 unlock:
-- 
1.7.5.3

