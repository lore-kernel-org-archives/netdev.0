From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 20/20] batman-adv: Prefix translation-table local static functions with batadv_
Date: Mon, 25 Jun 2012 08:54:44 +0200
Message-ID: <1340607284-29950-21-git-send-email-ordex@autistici.org>
References: <1340607284-29950-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:30541 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754751Ab2FYGyy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 02:54:54 -0400
In-Reply-To: <1340607284-29950-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

All non-static symbols of batman-adv were prefixed with batadv_ to avoid
collisions with other symbols of the kernel. Other symbols of batman-adv
should use the same prefix to keep the naming scheme consistent.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/translation-table.c |  540 +++++++++++++++++++-----------------
 1 file changed, 282 insertions(+), 258 deletions(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 2eff22f..f7a6152 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -29,13 +29,14 @@
 
 #include <linux/crc16.h>
 
-static void send_roam_adv(struct bat_priv *bat_priv, uint8_t *client,
-			  struct orig_node *orig_node);
-static void tt_purge(struct work_struct *work);
-static void tt_global_del_orig_list(struct tt_global_entry *tt_global_entry);
+static void batadv_send_roam_adv(struct bat_priv *bat_priv, uint8_t *client,
+				 struct orig_node *orig_node);
+static void batadv_tt_purge(struct work_struct *work);
+static void
+batadv_tt_global_del_orig_list(struct tt_global_entry *tt_global_entry);
 
 /* returns 1 if they are the same mac addr */
-static int compare_tt(const struct hlist_node *node, const void *data2)
+static int batadv_compare_tt(const struct hlist_node *node, const void *data2)
 {
 	const void *data1 = container_of(node, struct tt_common_entry,
 					 hash_entry);
@@ -43,15 +44,15 @@ static int compare_tt(const struct hlist_node *node, const void *data2)
 	return (memcmp(data1, data2, ETH_ALEN) == 0 ? 1 : 0);
 }
 
-static void tt_start_timer(struct bat_priv *bat_priv)
+static void batadv_tt_start_timer(struct bat_priv *bat_priv)
 {
-	INIT_DELAYED_WORK(&bat_priv->tt_work, tt_purge);
+	INIT_DELAYED_WORK(&bat_priv->tt_work, batadv_tt_purge);
 	queue_delayed_work(batadv_event_workqueue, &bat_priv->tt_work,
 			   msecs_to_jiffies(5000));
 }
 
-static struct tt_common_entry *tt_hash_find(struct hashtable_t *hash,
-					    const void *data)
+static struct tt_common_entry *batadv_tt_hash_find(struct hashtable_t *hash,
+						   const void *data)
 {
 	struct hlist_head *head;
 	struct hlist_node *node;
@@ -80,26 +81,26 @@ static struct tt_common_entry *tt_hash_find(struct hashtable_t *hash,
 	return tt_common_entry_tmp;
 }
 
-static struct tt_local_entry *tt_local_hash_find(struct bat_priv *bat_priv,
-						 const void *data)
+static struct tt_local_entry *
+batadv_tt_local_hash_find(struct bat_priv *bat_priv, const void *data)
 {
 	struct tt_common_entry *tt_common_entry;
 	struct tt_local_entry *tt_local_entry = NULL;
 
-	tt_common_entry = tt_hash_find(bat_priv->tt_local_hash, data);
+	tt_common_entry = batadv_tt_hash_find(bat_priv->tt_local_hash, data);
 	if (tt_common_entry)
 		tt_local_entry = container_of(tt_common_entry,
 					      struct tt_local_entry, common);
 	return tt_local_entry;
 }
 
-static struct tt_global_entry *tt_global_hash_find(struct bat_priv *bat_priv,
-						   const void *data)
+static struct tt_global_entry *
+batadv_tt_global_hash_find(struct bat_priv *bat_priv, const void *data)
 {
 	struct tt_common_entry *tt_common_entry;
 	struct tt_global_entry *tt_global_entry = NULL;
 
-	tt_common_entry = tt_hash_find(bat_priv->tt_global_hash, data);
+	tt_common_entry = batadv_tt_hash_find(bat_priv->tt_global_hash, data);
 	if (tt_common_entry)
 		tt_global_entry = container_of(tt_common_entry,
 					       struct tt_global_entry, common);
@@ -107,13 +108,14 @@ static struct tt_global_entry *tt_global_hash_find(struct bat_priv *bat_priv,
 
 }
 
-static void tt_local_entry_free_ref(struct tt_local_entry *tt_local_entry)
+static void
+batadv_tt_local_entry_free_ref(struct tt_local_entry *tt_local_entry)
 {
 	if (atomic_dec_and_test(&tt_local_entry->common.refcount))
 		kfree_rcu(tt_local_entry, common.rcu);
 }
 
-static void tt_global_entry_free_rcu(struct rcu_head *rcu)
+static void batadv_tt_global_entry_free_rcu(struct rcu_head *rcu)
 {
 	struct tt_common_entry *tt_common_entry;
 	struct tt_global_entry *tt_global_entry;
@@ -125,16 +127,17 @@ static void tt_global_entry_free_rcu(struct rcu_head *rcu)
 	kfree(tt_global_entry);
 }
 
-static void tt_global_entry_free_ref(struct tt_global_entry *tt_global_entry)
+static void
+batadv_tt_global_entry_free_ref(struct tt_global_entry *tt_global_entry)
 {
 	if (atomic_dec_and_test(&tt_global_entry->common.refcount)) {
-		tt_global_del_orig_list(tt_global_entry);
+		batadv_tt_global_del_orig_list(tt_global_entry);
 		call_rcu(&tt_global_entry->common.rcu,
-			 tt_global_entry_free_rcu);
+			 batadv_tt_global_entry_free_rcu);
 	}
 }
 
-static void tt_orig_list_entry_free_rcu(struct rcu_head *rcu)
+static void batadv_tt_orig_list_entry_free_rcu(struct rcu_head *rcu)
 {
 	struct tt_orig_list_entry *orig_entry;
 
@@ -144,13 +147,14 @@ static void tt_orig_list_entry_free_rcu(struct rcu_head *rcu)
 	kfree(orig_entry);
 }
 
-static void tt_orig_list_entry_free_ref(struct tt_orig_list_entry *orig_entry)
+static void
+batadv_tt_orig_list_entry_free_ref(struct tt_orig_list_entry *orig_entry)
 {
-	call_rcu(&orig_entry->rcu, tt_orig_list_entry_free_rcu);
+	call_rcu(&orig_entry->rcu, batadv_tt_orig_list_entry_free_rcu);
 }
 
-static void tt_local_event(struct bat_priv *bat_priv, const uint8_t *addr,
-			   uint8_t flags)
+static void batadv_tt_local_event(struct bat_priv *bat_priv,
+				  const uint8_t *addr, uint8_t flags)
 {
 	struct tt_change_node *tt_change_node;
 
@@ -176,7 +180,7 @@ int batadv_tt_len(int changes_num)
 	return changes_num * sizeof(struct tt_change);
 }
 
-static int tt_local_init(struct bat_priv *bat_priv)
+static int batadv_tt_local_init(struct bat_priv *bat_priv)
 {
 	if (bat_priv->tt_local_hash)
 		return 0;
@@ -200,7 +204,7 @@ void batadv_tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
 	struct tt_orig_list_entry *orig_entry;
 	int hash_added;
 
-	tt_local_entry = tt_local_hash_find(bat_priv, addr);
+	tt_local_entry = batadv_tt_local_hash_find(bat_priv, addr);
 
 	if (tt_local_entry) {
 		tt_local_entry->last_seen = jiffies;
@@ -234,21 +238,21 @@ void batadv_tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
 	 */
 	tt_local_entry->common.flags |= TT_CLIENT_NEW;
 
-	hash_added = batadv_hash_add(bat_priv->tt_local_hash, compare_tt,
+	hash_added = batadv_hash_add(bat_priv->tt_local_hash, batadv_compare_tt,
 				     batadv_choose_orig,
 				     &tt_local_entry->common,
 				     &tt_local_entry->common.hash_entry);
 
 	if (unlikely(hash_added != 0)) {
 		/* remove the reference for the hash */
-		tt_local_entry_free_ref(tt_local_entry);
+		batadv_tt_local_entry_free_ref(tt_local_entry);
 		goto out;
 	}
 
-	tt_local_event(bat_priv, addr, tt_local_entry->common.flags);
+	batadv_tt_local_event(bat_priv, addr, tt_local_entry->common.flags);
 
 	/* remove address from global hash if present */
-	tt_global_entry = tt_global_hash_find(bat_priv, addr);
+	tt_global_entry = batadv_tt_global_hash_find(bat_priv, addr);
 
 	/* Check whether it is a roaming! */
 	if (tt_global_entry) {
@@ -258,8 +262,9 @@ void batadv_tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
 		hlist_for_each_entry_rcu(orig_entry, node, head, list) {
 			orig_entry->orig_node->tt_poss_change = true;
 
-			send_roam_adv(bat_priv, tt_global_entry->common.addr,
-				      orig_entry->orig_node);
+			batadv_send_roam_adv(bat_priv,
+					     tt_global_entry->common.addr,
+					     orig_entry->orig_node);
 		}
 		rcu_read_unlock();
 		/* The global entry has to be marked as ROAMING and
@@ -270,14 +275,15 @@ void batadv_tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
 	}
 out:
 	if (tt_local_entry)
-		tt_local_entry_free_ref(tt_local_entry);
+		batadv_tt_local_entry_free_ref(tt_local_entry);
 	if (tt_global_entry)
-		tt_global_entry_free_ref(tt_global_entry);
+		batadv_tt_global_entry_free_ref(tt_global_entry);
 }
 
-static void tt_realloc_packet_buff(unsigned char **packet_buff,
-				   int *packet_buff_len, int min_packet_len,
-				   int new_packet_len)
+static void batadv_tt_realloc_packet_buff(unsigned char **packet_buff,
+					  int *packet_buff_len,
+					  int min_packet_len,
+					  int new_packet_len)
 {
 	unsigned char *new_buff;
 
@@ -292,9 +298,10 @@ static void tt_realloc_packet_buff(unsigned char **packet_buff,
 	}
 }
 
-static void tt_prepare_packet_buff(struct bat_priv *bat_priv,
-				   unsigned char **packet_buff,
-				   int *packet_buff_len, int min_packet_len)
+static void batadv_tt_prepare_packet_buff(struct bat_priv *bat_priv,
+					  unsigned char **packet_buff,
+					  int *packet_buff_len,
+					  int min_packet_len)
 {
 	struct hard_iface *primary_if;
 	int req_len;
@@ -310,23 +317,24 @@ static void tt_prepare_packet_buff(struct bat_priv *bat_priv,
 	if ((!primary_if) || (req_len > primary_if->soft_iface->mtu))
 		req_len = min_packet_len;
 
-	tt_realloc_packet_buff(packet_buff, packet_buff_len,
-			       min_packet_len, req_len);
+	batadv_tt_realloc_packet_buff(packet_buff, packet_buff_len,
+				      min_packet_len, req_len);
 
 	if (primary_if)
 		batadv_hardif_free_ref(primary_if);
 }
 
-static int tt_changes_fill_buff(struct bat_priv *bat_priv,
-				unsigned char **packet_buff,
-				int *packet_buff_len, int min_packet_len)
+static int batadv_tt_changes_fill_buff(struct bat_priv *bat_priv,
+				       unsigned char **packet_buff,
+				       int *packet_buff_len,
+				       int min_packet_len)
 {
 	struct tt_change_node *entry, *safe;
 	int count = 0, tot_changes = 0, new_len;
 	unsigned char *tt_buff;
 
-	tt_prepare_packet_buff(bat_priv, packet_buff,
-			       packet_buff_len, min_packet_len);
+	batadv_tt_prepare_packet_buff(bat_priv, packet_buff,
+				      packet_buff_len, min_packet_len);
 
 	new_len = *packet_buff_len - min_packet_len;
 	tt_buff = *packet_buff + min_packet_len;
@@ -428,12 +436,12 @@ out:
 	return ret;
 }
 
-static void tt_local_set_pending(struct bat_priv *bat_priv,
-				 struct tt_local_entry *tt_local_entry,
-				 uint16_t flags, const char *message)
+static void batadv_tt_local_set_pending(struct bat_priv *bat_priv,
+					struct tt_local_entry *tt_local_entry,
+					uint16_t flags, const char *message)
 {
-	tt_local_event(bat_priv, tt_local_entry->common.addr,
-		       tt_local_entry->common.flags | flags);
+	batadv_tt_local_event(bat_priv, tt_local_entry->common.addr,
+			      tt_local_entry->common.flags | flags);
 
 	/* The local client has to be marked as "pending to be removed" but has
 	 * to be kept in the table in order to send it in a full table
@@ -451,18 +459,19 @@ void batadv_tt_local_remove(struct bat_priv *bat_priv, const uint8_t *addr,
 {
 	struct tt_local_entry *tt_local_entry = NULL;
 
-	tt_local_entry = tt_local_hash_find(bat_priv, addr);
+	tt_local_entry = batadv_tt_local_hash_find(bat_priv, addr);
 	if (!tt_local_entry)
 		goto out;
 
-	tt_local_set_pending(bat_priv, tt_local_entry, TT_CLIENT_DEL |
-			     (roaming ? TT_CLIENT_ROAM : NO_FLAGS), message);
+	batadv_tt_local_set_pending(bat_priv, tt_local_entry, TT_CLIENT_DEL |
+				    (roaming ? TT_CLIENT_ROAM : NO_FLAGS),
+				    message);
 out:
 	if (tt_local_entry)
-		tt_local_entry_free_ref(tt_local_entry);
+		batadv_tt_local_entry_free_ref(tt_local_entry);
 }
 
-static void tt_local_purge(struct bat_priv *bat_priv)
+static void batadv_tt_local_purge(struct bat_priv *bat_priv)
 {
 	struct hashtable_t *hash = bat_priv->tt_local_hash;
 	struct tt_local_entry *tt_local_entry;
@@ -493,15 +502,15 @@ static void tt_local_purge(struct bat_priv *bat_priv)
 						  TT_LOCAL_TIMEOUT))
 				continue;
 
-			tt_local_set_pending(bat_priv, tt_local_entry,
-					     TT_CLIENT_DEL, "timed out");
+			batadv_tt_local_set_pending(bat_priv, tt_local_entry,
+						    TT_CLIENT_DEL, "timed out");
 		}
 		spin_unlock_bh(list_lock);
 	}
 
 }
 
-static void tt_local_table_free(struct bat_priv *bat_priv)
+static void batadv_tt_local_table_free(struct bat_priv *bat_priv)
 {
 	struct hashtable_t *hash;
 	spinlock_t *list_lock; /* protects write access to the hash lists */
@@ -527,7 +536,7 @@ static void tt_local_table_free(struct bat_priv *bat_priv)
 			tt_local_entry = container_of(tt_common_entry,
 						      struct tt_local_entry,
 						      common);
-			tt_local_entry_free_ref(tt_local_entry);
+			batadv_tt_local_entry_free_ref(tt_local_entry);
 		}
 		spin_unlock_bh(list_lock);
 	}
@@ -537,7 +546,7 @@ static void tt_local_table_free(struct bat_priv *bat_priv)
 	bat_priv->tt_local_hash = NULL;
 }
 
-static int tt_global_init(struct bat_priv *bat_priv)
+static int batadv_tt_global_init(struct bat_priv *bat_priv)
 {
 	if (bat_priv->tt_global_hash)
 		return 0;
@@ -550,7 +559,7 @@ static int tt_global_init(struct bat_priv *bat_priv)
 	return 0;
 }
 
-static void tt_changes_list_free(struct bat_priv *bat_priv)
+static void batadv_tt_changes_list_free(struct bat_priv *bat_priv)
 {
 	struct tt_change_node *entry, *safe;
 
@@ -569,8 +578,8 @@ static void tt_changes_list_free(struct bat_priv *bat_priv)
 /* find out if an orig_node is already in the list of a tt_global_entry.
  * returns 1 if found, 0 otherwise
  */
-static bool tt_global_entry_has_orig(const struct tt_global_entry *entry,
-				     const struct orig_node *orig_node)
+static bool batadv_tt_global_entry_has_orig(const struct tt_global_entry *entry,
+					    const struct orig_node *orig_node)
 {
 	struct tt_orig_list_entry *tmp_orig_entry;
 	const struct hlist_head *head;
@@ -589,9 +598,9 @@ static bool tt_global_entry_has_orig(const struct tt_global_entry *entry,
 	return found;
 }
 
-static void tt_global_add_orig_entry(struct tt_global_entry *tt_global_entry,
-				     struct orig_node *orig_node,
-				     int ttvn)
+static void
+batadv_tt_global_add_orig_entry(struct tt_global_entry *tt_global_entry,
+				struct orig_node *orig_node, int ttvn)
 {
 	struct tt_orig_list_entry *orig_entry;
 
@@ -621,7 +630,7 @@ int batadv_tt_global_add(struct bat_priv *bat_priv, struct orig_node *orig_node,
 	int hash_added;
 	struct tt_common_entry *common;
 
-	tt_global_entry = tt_global_hash_find(bat_priv, tt_addr);
+	tt_global_entry = batadv_tt_global_hash_find(bat_priv, tt_addr);
 
 	if (!tt_global_entry) {
 		tt_global_entry = kzalloc(sizeof(*tt_global_entry),
@@ -640,16 +649,18 @@ int batadv_tt_global_add(struct bat_priv *bat_priv, struct orig_node *orig_node,
 		spin_lock_init(&tt_global_entry->list_lock);
 
 		hash_added = batadv_hash_add(bat_priv->tt_global_hash,
-					     compare_tt, batadv_choose_orig,
-					     common, &common->hash_entry);
+					     batadv_compare_tt,
+					     batadv_choose_orig, common,
+					     &common->hash_entry);
 
 		if (unlikely(hash_added != 0)) {
 			/* remove the reference for the hash */
-			tt_global_entry_free_ref(tt_global_entry);
+			batadv_tt_global_entry_free_ref(tt_global_entry);
 			goto out_remove;
 		}
 
-		tt_global_add_orig_entry(tt_global_entry, orig_node, ttvn);
+		batadv_tt_global_add_orig_entry(tt_global_entry, orig_node,
+						ttvn);
 	} else {
 		/* there is already a global entry, use this one. */
 
@@ -661,14 +672,15 @@ int batadv_tt_global_add(struct bat_priv *bat_priv, struct orig_node *orig_node,
 		 * new one.
 		 */
 		if (tt_global_entry->common.flags & TT_CLIENT_ROAM) {
-			tt_global_del_orig_list(tt_global_entry);
+			batadv_tt_global_del_orig_list(tt_global_entry);
 			tt_global_entry->common.flags &= ~TT_CLIENT_ROAM;
 			tt_global_entry->roam_at = 0;
 		}
 
-		if (!tt_global_entry_has_orig(tt_global_entry, orig_node))
-			tt_global_add_orig_entry(tt_global_entry, orig_node,
-						 ttvn);
+		if (!batadv_tt_global_entry_has_orig(tt_global_entry,
+						     orig_node))
+			batadv_tt_global_add_orig_entry(tt_global_entry,
+							orig_node, ttvn);
 	}
 
 	if (wifi)
@@ -685,15 +697,16 @@ out_remove:
 	ret = 1;
 out:
 	if (tt_global_entry)
-		tt_global_entry_free_ref(tt_global_entry);
+		batadv_tt_global_entry_free_ref(tt_global_entry);
 	return ret;
 }
 
 /* print all orig nodes who announce the address for this global entry.
  * it is assumed that the caller holds rcu_read_lock();
  */
-static void tt_global_print_entry(struct tt_global_entry *tt_global_entry,
-				  struct seq_file *seq)
+static void
+batadv_tt_global_print_entry(struct tt_global_entry *tt_global_entry,
+			     struct seq_file *seq)
 {
 	struct hlist_head *head;
 	struct hlist_node *node;
@@ -760,7 +773,7 @@ int batadv_tt_global_seq_print_text(struct seq_file *seq, void *offset)
 			tt_global_entry = container_of(tt_common_entry,
 						       struct tt_global_entry,
 						       common);
-			tt_global_print_entry(tt_global_entry, seq);
+			batadv_tt_global_print_entry(tt_global_entry, seq);
 		}
 		rcu_read_unlock();
 	}
@@ -771,7 +784,8 @@ out:
 }
 
 /* deletes the orig list of a tt_global_entry */
-static void tt_global_del_orig_list(struct tt_global_entry *tt_global_entry)
+static void
+batadv_tt_global_del_orig_list(struct tt_global_entry *tt_global_entry)
 {
 	struct hlist_head *head;
 	struct hlist_node *node, *safe;
@@ -781,16 +795,17 @@ static void tt_global_del_orig_list(struct tt_global_entry *tt_global_entry)
 	head = &tt_global_entry->orig_list;
 	hlist_for_each_entry_safe(orig_entry, node, safe, head, list) {
 		hlist_del_rcu(node);
-		tt_orig_list_entry_free_ref(orig_entry);
+		batadv_tt_orig_list_entry_free_ref(orig_entry);
 	}
 	spin_unlock_bh(&tt_global_entry->list_lock);
 
 }
 
-static void tt_global_del_orig_entry(struct bat_priv *bat_priv,
-				     struct tt_global_entry *tt_global_entry,
-				     struct orig_node *orig_node,
-				     const char *message)
+static void
+batadv_tt_global_del_orig_entry(struct bat_priv *bat_priv,
+				struct tt_global_entry *tt_global_entry,
+				struct orig_node *orig_node,
+				const char *message)
 {
 	struct hlist_head *head;
 	struct hlist_node *node, *safe;
@@ -805,22 +820,22 @@ static void tt_global_del_orig_entry(struct bat_priv *bat_priv,
 				   orig_node->orig,
 				   tt_global_entry->common.addr, message);
 			hlist_del_rcu(node);
-			tt_orig_list_entry_free_ref(orig_entry);
+			batadv_tt_orig_list_entry_free_ref(orig_entry);
 		}
 	}
 	spin_unlock_bh(&tt_global_entry->list_lock);
 }
 
-static void tt_global_del_struct(struct bat_priv *bat_priv,
-				 struct tt_global_entry *tt_global_entry,
-				 const char *message)
+static void batadv_tt_global_del_struct(struct bat_priv *bat_priv,
+					struct tt_global_entry *tt_global_entry,
+					const char *message)
 {
 	batadv_dbg(DBG_TT, bat_priv, "Deleting global tt entry %pM: %s\n",
 		   tt_global_entry->common.addr, message);
 
-	batadv_hash_remove(bat_priv->tt_global_hash, compare_tt,
+	batadv_hash_remove(bat_priv->tt_global_hash, batadv_compare_tt,
 			   batadv_choose_orig, tt_global_entry->common.addr);
-	tt_global_entry_free_ref(tt_global_entry);
+	batadv_tt_global_entry_free_ref(tt_global_entry);
 
 }
 
@@ -828,10 +843,10 @@ static void tt_global_del_struct(struct bat_priv *bat_priv,
  * within tt_global entry. If yes, we set the TT_CLIENT_ROAM flag and the timer,
  * otherwise we simply remove the originator scheduled for deletion.
  */
-static void tt_global_del_roaming(struct bat_priv *bat_priv,
-				  struct tt_global_entry *tt_global_entry,
-				  struct orig_node *orig_node,
-				  const char *message)
+static void
+batadv_tt_global_del_roaming(struct bat_priv *bat_priv,
+			     struct tt_global_entry *tt_global_entry,
+			     struct orig_node *orig_node, const char *message)
 {
 	bool last_entry = true;
 	struct hlist_head *head;
@@ -860,31 +875,31 @@ static void tt_global_del_roaming(struct bat_priv *bat_priv,
 		/* there is another entry, we can simply delete this
 		 * one and can still use the other one.
 		 */
-		tt_global_del_orig_entry(bat_priv, tt_global_entry,
-					 orig_node, message);
+		batadv_tt_global_del_orig_entry(bat_priv, tt_global_entry,
+						orig_node, message);
 }
 
 
 
-static void tt_global_del(struct bat_priv *bat_priv,
-			  struct orig_node *orig_node,
-			  const unsigned char *addr,
-			  const char *message, bool roaming)
+static void batadv_tt_global_del(struct bat_priv *bat_priv,
+				 struct orig_node *orig_node,
+				 const unsigned char *addr,
+				 const char *message, bool roaming)
 {
 	struct tt_global_entry *tt_global_entry = NULL;
-	struct tt_local_entry *tt_local_entry = NULL;
+	struct tt_local_entry *local_entry = NULL;
 
-	tt_global_entry = tt_global_hash_find(bat_priv, addr);
+	tt_global_entry = batadv_tt_global_hash_find(bat_priv, addr);
 	if (!tt_global_entry)
 		goto out;
 
 	if (!roaming) {
-		tt_global_del_orig_entry(bat_priv, tt_global_entry, orig_node,
-					 message);
+		batadv_tt_global_del_orig_entry(bat_priv, tt_global_entry,
+						orig_node, message);
 
 		if (hlist_empty(&tt_global_entry->orig_list))
-			tt_global_del_struct(bat_priv, tt_global_entry,
-					     message);
+			batadv_tt_global_del_struct(bat_priv, tt_global_entry,
+						    message);
 
 		goto out;
 	}
@@ -902,29 +917,29 @@ static void tt_global_del(struct bat_priv *bat_priv,
 	 * 2) the client roamed to us => we can directly delete
 	 *    the global entry, since it is useless now.
 	 */
-	tt_local_entry = tt_local_hash_find(bat_priv,
-					    tt_global_entry->common.addr);
-	if (tt_local_entry) {
+	local_entry = batadv_tt_local_hash_find(bat_priv,
+						tt_global_entry->common.addr);
+	if (local_entry) {
 		/* local entry exists, case 2: client roamed to us. */
-		tt_global_del_orig_list(tt_global_entry);
-		tt_global_del_struct(bat_priv, tt_global_entry, message);
+		batadv_tt_global_del_orig_list(tt_global_entry);
+		batadv_tt_global_del_struct(bat_priv, tt_global_entry, message);
 	} else
 		/* no local entry exists, case 1: check for roaming */
-		tt_global_del_roaming(bat_priv, tt_global_entry, orig_node,
-				      message);
+		batadv_tt_global_del_roaming(bat_priv, tt_global_entry,
+					     orig_node, message);
 
 
 out:
 	if (tt_global_entry)
-		tt_global_entry_free_ref(tt_global_entry);
-	if (tt_local_entry)
-		tt_local_entry_free_ref(tt_local_entry);
+		batadv_tt_global_entry_free_ref(tt_global_entry);
+	if (local_entry)
+		batadv_tt_local_entry_free_ref(local_entry);
 }
 
 void batadv_tt_global_del_orig(struct bat_priv *bat_priv,
 			       struct orig_node *orig_node, const char *message)
 {
-	struct tt_global_entry *tt_global_entry;
+	struct tt_global_entry *global_entry;
 	struct tt_common_entry *tt_common_entry;
 	uint32_t i;
 	struct hashtable_t *hash = bat_priv->tt_global_hash;
@@ -942,20 +957,19 @@ void batadv_tt_global_del_orig(struct bat_priv *bat_priv,
 		spin_lock_bh(list_lock);
 		hlist_for_each_entry_safe(tt_common_entry, node, safe,
 					  head, hash_entry) {
-			tt_global_entry = container_of(tt_common_entry,
-						       struct tt_global_entry,
-						       common);
+			global_entry = container_of(tt_common_entry,
+						    struct tt_global_entry,
+						    common);
 
-			tt_global_del_orig_entry(bat_priv, tt_global_entry,
-						 orig_node, message);
+			batadv_tt_global_del_orig_entry(bat_priv, global_entry,
+							orig_node, message);
 
-			if (hlist_empty(&tt_global_entry->orig_list)) {
+			if (hlist_empty(&global_entry->orig_list)) {
 				batadv_dbg(DBG_TT, bat_priv,
 					   "Deleting global tt entry %pM: %s\n",
-					   tt_global_entry->common.addr,
-					   message);
+					   global_entry->common.addr, message);
 				hlist_del_rcu(node);
-				tt_global_entry_free_ref(tt_global_entry);
+				batadv_tt_global_entry_free_ref(global_entry);
 			}
 		}
 		spin_unlock_bh(list_lock);
@@ -964,7 +978,7 @@ void batadv_tt_global_del_orig(struct bat_priv *bat_priv,
 	orig_node->tt_initialised = false;
 }
 
-static void tt_global_roam_purge(struct bat_priv *bat_priv)
+static void batadv_tt_global_roam_purge(struct bat_priv *bat_priv)
 {
 	struct hashtable_t *hash = bat_priv->tt_global_hash;
 	struct tt_common_entry *tt_common_entry;
@@ -995,14 +1009,14 @@ static void tt_global_roam_purge(struct bat_priv *bat_priv)
 				   tt_global_entry->common.addr);
 
 			hlist_del_rcu(node);
-			tt_global_entry_free_ref(tt_global_entry);
+			batadv_tt_global_entry_free_ref(tt_global_entry);
 		}
 		spin_unlock_bh(list_lock);
 	}
 
 }
 
-static void tt_global_table_free(struct bat_priv *bat_priv)
+static void batadv_tt_global_table_free(struct bat_priv *bat_priv)
 {
 	struct hashtable_t *hash;
 	spinlock_t *list_lock; /* protects write access to the hash lists */
@@ -1028,7 +1042,7 @@ static void tt_global_table_free(struct bat_priv *bat_priv)
 			tt_global_entry = container_of(tt_common_entry,
 						       struct tt_global_entry,
 						       common);
-			tt_global_entry_free_ref(tt_global_entry);
+			batadv_tt_global_entry_free_ref(tt_global_entry);
 		}
 		spin_unlock_bh(list_lock);
 	}
@@ -1038,8 +1052,8 @@ static void tt_global_table_free(struct bat_priv *bat_priv)
 	bat_priv->tt_global_hash = NULL;
 }
 
-static bool _is_ap_isolated(struct tt_local_entry *tt_local_entry,
-			    struct tt_global_entry *tt_global_entry)
+static bool _batadv_is_ap_isolated(struct tt_local_entry *tt_local_entry,
+				   struct tt_global_entry *tt_global_entry)
 {
 	bool ret = false;
 
@@ -1064,19 +1078,20 @@ struct orig_node *batadv_transtable_search(struct bat_priv *bat_priv,
 	int best_tq;
 
 	if (src && atomic_read(&bat_priv->ap_isolation)) {
-		tt_local_entry = tt_local_hash_find(bat_priv, src);
+		tt_local_entry = batadv_tt_local_hash_find(bat_priv, src);
 		if (!tt_local_entry)
 			goto out;
 	}
 
-	tt_global_entry = tt_global_hash_find(bat_priv, addr);
+	tt_global_entry = batadv_tt_global_hash_find(bat_priv, addr);
 	if (!tt_global_entry)
 		goto out;
 
 	/* check whether the clients should not communicate due to AP
 	 * isolation
 	 */
-	if (tt_local_entry && _is_ap_isolated(tt_local_entry, tt_global_entry))
+	if (tt_local_entry &&
+	    _batadv_is_ap_isolated(tt_local_entry, tt_global_entry))
 		goto out;
 
 	best_tq = 0;
@@ -1100,16 +1115,16 @@ struct orig_node *batadv_transtable_search(struct bat_priv *bat_priv,
 	rcu_read_unlock();
 out:
 	if (tt_global_entry)
-		tt_global_entry_free_ref(tt_global_entry);
+		batadv_tt_global_entry_free_ref(tt_global_entry);
 	if (tt_local_entry)
-		tt_local_entry_free_ref(tt_local_entry);
+		batadv_tt_local_entry_free_ref(tt_local_entry);
 
 	return orig_node;
 }
 
 /* Calculates the checksum of the local table of a given orig_node */
-static uint16_t tt_global_crc(struct bat_priv *bat_priv,
-			      struct orig_node *orig_node)
+static uint16_t batadv_tt_global_crc(struct bat_priv *bat_priv,
+				     struct orig_node *orig_node)
 {
 	uint16_t total = 0, total_one;
 	struct hashtable_t *hash = bat_priv->tt_global_hash;
@@ -1140,8 +1155,8 @@ static uint16_t tt_global_crc(struct bat_priv *bat_priv,
 			/* find out if this global entry is announced by this
 			 * originator
 			 */
-			if (!tt_global_entry_has_orig(tt_global_entry,
-						      orig_node))
+			if (!batadv_tt_global_entry_has_orig(tt_global_entry,
+							     orig_node))
 				continue;
 
 			total_one = 0;
@@ -1190,7 +1205,7 @@ static uint16_t batadv_tt_local_crc(struct bat_priv *bat_priv)
 	return total;
 }
 
-static void tt_req_list_free(struct bat_priv *bat_priv)
+static void batadv_tt_req_list_free(struct bat_priv *bat_priv)
 {
 	struct tt_req_node *node, *safe;
 
@@ -1204,10 +1219,10 @@ static void tt_req_list_free(struct bat_priv *bat_priv)
 	spin_unlock_bh(&bat_priv->tt_req_list_lock);
 }
 
-static void tt_save_orig_buffer(struct bat_priv *bat_priv,
-				struct orig_node *orig_node,
-				const unsigned char *tt_buff,
-				uint8_t tt_num_changes)
+static void batadv_tt_save_orig_buffer(struct bat_priv *bat_priv,
+				       struct orig_node *orig_node,
+				       const unsigned char *tt_buff,
+				       uint8_t tt_num_changes)
 {
 	uint16_t tt_buff_len = batadv_tt_len(tt_num_changes);
 
@@ -1227,7 +1242,7 @@ static void tt_save_orig_buffer(struct bat_priv *bat_priv,
 	spin_unlock_bh(&orig_node->tt_buff_lock);
 }
 
-static void tt_req_purge(struct bat_priv *bat_priv)
+static void batadv_tt_req_purge(struct bat_priv *bat_priv)
 {
 	struct tt_req_node *node, *safe;
 
@@ -1244,8 +1259,8 @@ static void tt_req_purge(struct bat_priv *bat_priv)
 /* returns the pointer to the new tt_req_node struct if no request
  * has already been issued for this orig_node, NULL otherwise
  */
-static struct tt_req_node *new_tt_req_node(struct bat_priv *bat_priv,
-					  struct orig_node *orig_node)
+static struct tt_req_node *batadv_new_tt_req_node(struct bat_priv *bat_priv,
+						  struct orig_node *orig_node)
 {
 	struct tt_req_node *tt_req_node_tmp, *tt_req_node = NULL;
 
@@ -1271,7 +1286,8 @@ unlock:
 }
 
 /* data_ptr is useless here, but has to be kept to respect the prototype */
-static int tt_local_valid_entry(const void *entry_ptr, const void *data_ptr)
+static int batadv_tt_local_valid_entry(const void *entry_ptr,
+				       const void *data_ptr)
 {
 	const struct tt_common_entry *tt_common_entry = entry_ptr;
 
@@ -1280,7 +1296,8 @@ static int tt_local_valid_entry(const void *entry_ptr, const void *data_ptr)
 	return 1;
 }
 
-static int tt_global_valid_entry(const void *entry_ptr, const void *data_ptr)
+static int batadv_tt_global_valid(const void *entry_ptr,
+				  const void *data_ptr)
 {
 	const struct tt_common_entry *tt_common_entry = entry_ptr;
 	const struct tt_global_entry *tt_global_entry;
@@ -1292,15 +1309,15 @@ static int tt_global_valid_entry(const void *entry_ptr, const void *data_ptr)
 	tt_global_entry = container_of(tt_common_entry, struct tt_global_entry,
 				       common);
 
-	return tt_global_entry_has_orig(tt_global_entry, orig_node);
+	return batadv_tt_global_entry_has_orig(tt_global_entry, orig_node);
 }
 
-static struct sk_buff *tt_response_fill_table(uint16_t tt_len, uint8_t ttvn,
-					      struct hashtable_t *hash,
-					      struct hard_iface *primary_if,
-					      int (*valid_cb)(const void *,
-							      const void *),
-					      void *cb_data)
+static struct sk_buff *
+batadv_tt_response_fill_table(uint16_t tt_len, uint8_t ttvn,
+			      struct hashtable_t *hash,
+			      struct hard_iface *primary_if,
+			      int (*valid_cb)(const void *, const void *),
+			      void *cb_data)
 {
 	struct tt_common_entry *tt_common_entry;
 	struct tt_query_packet *tt_response;
@@ -1361,9 +1378,10 @@ out:
 	return skb;
 }
 
-static int send_tt_request(struct bat_priv *bat_priv,
-			   struct orig_node *dst_orig_node,
-			   uint8_t ttvn, uint16_t tt_crc, bool full_table)
+static int batadv_send_tt_request(struct bat_priv *bat_priv,
+				  struct orig_node *dst_orig_node,
+				  uint8_t ttvn, uint16_t tt_crc,
+				  bool full_table)
 {
 	struct sk_buff *skb = NULL;
 	struct tt_query_packet *tt_request;
@@ -1379,7 +1397,7 @@ static int send_tt_request(struct bat_priv *bat_priv,
 	/* The new tt_req will be issued only if I'm not waiting for a
 	 * reply from the same orig_node yet
 	 */
-	tt_req_node = new_tt_req_node(bat_priv, dst_orig_node);
+	tt_req_node = batadv_new_tt_req_node(bat_priv, dst_orig_node);
 	if (!tt_req_node)
 		goto out;
 
@@ -1434,8 +1452,8 @@ out:
 	return ret;
 }
 
-static bool send_other_tt_response(struct bat_priv *bat_priv,
-				   struct tt_query_packet *tt_request)
+static bool batadv_send_other_tt_response(struct bat_priv *bat_priv,
+					  struct tt_query_packet *tt_request)
 {
 	struct orig_node *req_dst_orig_node = NULL, *res_dst_orig_node = NULL;
 	struct neigh_node *neigh_node = NULL;
@@ -1515,10 +1533,11 @@ static bool send_other_tt_response(struct bat_priv *bat_priv,
 						sizeof(struct tt_change);
 		ttvn = (uint8_t)atomic_read(&req_dst_orig_node->last_ttvn);
 
-		skb = tt_response_fill_table(tt_len, ttvn,
-					     bat_priv->tt_global_hash,
-					     primary_if, tt_global_valid_entry,
-					     req_dst_orig_node);
+		skb = batadv_tt_response_fill_table(tt_len, ttvn,
+						    bat_priv->tt_global_hash,
+						    primary_if,
+						    batadv_tt_global_valid,
+						    req_dst_orig_node);
 		if (!skb)
 			goto out;
 
@@ -1563,8 +1582,8 @@ out:
 	return ret;
 
 }
-static bool send_my_tt_response(struct bat_priv *bat_priv,
-				struct tt_query_packet *tt_request)
+static bool batadv_send_my_tt_response(struct bat_priv *bat_priv,
+				       struct tt_query_packet *tt_request)
 {
 	struct orig_node *orig_node = NULL;
 	struct neigh_node *neigh_node = NULL;
@@ -1635,10 +1654,11 @@ static bool send_my_tt_response(struct bat_priv *bat_priv,
 						sizeof(struct tt_change);
 		ttvn = (uint8_t)atomic_read(&bat_priv->ttvn);
 
-		skb = tt_response_fill_table(tt_len, ttvn,
-					     bat_priv->tt_local_hash,
-					     primary_if, tt_local_valid_entry,
-					     NULL);
+		skb = batadv_tt_response_fill_table(tt_len, ttvn,
+						    bat_priv->tt_local_hash,
+						    primary_if,
+						    batadv_tt_local_valid_entry,
+						    NULL);
 		if (!skb)
 			goto out;
 
@@ -1689,26 +1709,28 @@ bool batadv_send_tt_response(struct bat_priv *bat_priv,
 		if (batadv_bla_is_backbone_gw_orig(bat_priv, tt_request->src))
 			return true;
 
-		return send_my_tt_response(bat_priv, tt_request);
+		return batadv_send_my_tt_response(bat_priv, tt_request);
 	} else {
-		return send_other_tt_response(bat_priv, tt_request);
+		return batadv_send_other_tt_response(bat_priv, tt_request);
 	}
 }
 
-static void _tt_update_changes(struct bat_priv *bat_priv,
-			       struct orig_node *orig_node,
-			       struct tt_change *tt_change,
-			       uint16_t tt_num_changes, uint8_t ttvn)
+static void _batadv_tt_update_changes(struct bat_priv *bat_priv,
+				      struct orig_node *orig_node,
+				      struct tt_change *tt_change,
+				      uint16_t tt_num_changes, uint8_t ttvn)
 {
 	int i;
 	int is_wifi;
+	int roams;
 
 	for (i = 0; i < tt_num_changes; i++) {
 		if ((tt_change + i)->flags & TT_CLIENT_DEL) {
-			tt_global_del(bat_priv, orig_node,
-				      (tt_change + i)->addr,
-				      "tt removed by changes",
-				      (tt_change + i)->flags & TT_CLIENT_ROAM);
+			roams = (tt_change + i)->flags & TT_CLIENT_ROAM;
+			batadv_tt_global_del(bat_priv, orig_node,
+					     (tt_change + i)->addr,
+					      "tt removed by changes",
+					      roams);
 		} else {
 			is_wifi = (tt_change + i)->flags & TT_CLIENT_WIFI;
 			if (!batadv_tt_global_add(bat_priv, orig_node,
@@ -1726,8 +1748,8 @@ static void _tt_update_changes(struct bat_priv *bat_priv,
 	orig_node->tt_initialised = true;
 }
 
-static void tt_fill_gtable(struct bat_priv *bat_priv,
-			   struct tt_query_packet *tt_response)
+static void batadv_tt_fill_gtable(struct bat_priv *bat_priv,
+				  struct tt_query_packet *tt_response)
 {
 	struct orig_node *orig_node = NULL;
 
@@ -1738,9 +1760,10 @@ static void tt_fill_gtable(struct bat_priv *bat_priv,
 	/* Purge the old table first.. */
 	batadv_tt_global_del_orig(bat_priv, orig_node, "Received full table");
 
-	_tt_update_changes(bat_priv, orig_node,
-			   (struct tt_change *)(tt_response + 1),
-			   ntohs(tt_response->tt_data), tt_response->ttvn);
+	_batadv_tt_update_changes(bat_priv, orig_node,
+				  (struct tt_change *)(tt_response + 1),
+				  ntohs(tt_response->tt_data),
+				  tt_response->ttvn);
 
 	spin_lock_bh(&orig_node->tt_buff_lock);
 	kfree(orig_node->tt_buff);
@@ -1755,16 +1778,16 @@ out:
 		batadv_orig_node_free_ref(orig_node);
 }
 
-static void tt_update_changes(struct bat_priv *bat_priv,
-			      struct orig_node *orig_node,
-			      uint16_t tt_num_changes, uint8_t ttvn,
-			      struct tt_change *tt_change)
+static void batadv_tt_update_changes(struct bat_priv *bat_priv,
+				     struct orig_node *orig_node,
+				     uint16_t tt_num_changes, uint8_t ttvn,
+				     struct tt_change *tt_change)
 {
-	_tt_update_changes(bat_priv, orig_node, tt_change, tt_num_changes,
-			   ttvn);
+	_batadv_tt_update_changes(bat_priv, orig_node, tt_change,
+				  tt_num_changes, ttvn);
 
-	tt_save_orig_buffer(bat_priv, orig_node, (unsigned char *)tt_change,
-			    tt_num_changes);
+	batadv_tt_save_orig_buffer(bat_priv, orig_node,
+				   (unsigned char *)tt_change, tt_num_changes);
 	atomic_set(&orig_node->last_ttvn, ttvn);
 }
 
@@ -1773,7 +1796,7 @@ bool batadv_is_my_client(struct bat_priv *bat_priv, const uint8_t *addr)
 	struct tt_local_entry *tt_local_entry = NULL;
 	bool ret = false;
 
-	tt_local_entry = tt_local_hash_find(bat_priv, addr);
+	tt_local_entry = batadv_tt_local_hash_find(bat_priv, addr);
 	if (!tt_local_entry)
 		goto out;
 	/* Check if the client has been logically deleted (but is kept for
@@ -1784,7 +1807,7 @@ bool batadv_is_my_client(struct bat_priv *bat_priv, const uint8_t *addr)
 	ret = true;
 out:
 	if (tt_local_entry)
-		tt_local_entry_free_ref(tt_local_entry);
+		batadv_tt_local_entry_free_ref(tt_local_entry);
 	return ret;
 }
 
@@ -1809,12 +1832,12 @@ void batadv_handle_tt_response(struct bat_priv *bat_priv,
 		goto out;
 
 	if (tt_response->flags & TT_FULL_TABLE)
-		tt_fill_gtable(bat_priv, tt_response);
+		batadv_tt_fill_gtable(bat_priv, tt_response);
 	else
-		tt_update_changes(bat_priv, orig_node,
-				  ntohs(tt_response->tt_data),
-				  tt_response->ttvn,
-				  (struct tt_change *)(tt_response + 1));
+		batadv_tt_update_changes(bat_priv, orig_node,
+					 ntohs(tt_response->tt_data),
+					 tt_response->ttvn,
+					 (struct tt_change *)(tt_response + 1));
 
 	/* Delete the tt_req_node from pending tt_requests list */
 	spin_lock_bh(&bat_priv->tt_req_list_lock);
@@ -1827,7 +1850,7 @@ void batadv_handle_tt_response(struct bat_priv *bat_priv,
 	spin_unlock_bh(&bat_priv->tt_req_list_lock);
 
 	/* Recalculate the CRC for this orig_node and store it */
-	orig_node->tt_crc = tt_global_crc(bat_priv, orig_node);
+	orig_node->tt_crc = batadv_tt_global_crc(bat_priv, orig_node);
 	/* Roaming phase is over: tables are in sync again. I can
 	 * unset the flag
 	 */
@@ -1841,20 +1864,20 @@ int batadv_tt_init(struct bat_priv *bat_priv)
 {
 	int ret;
 
-	ret = tt_local_init(bat_priv);
+	ret = batadv_tt_local_init(bat_priv);
 	if (ret < 0)
 		return ret;
 
-	ret = tt_global_init(bat_priv);
+	ret = batadv_tt_global_init(bat_priv);
 	if (ret < 0)
 		return ret;
 
-	tt_start_timer(bat_priv);
+	batadv_tt_start_timer(bat_priv);
 
 	return 1;
 }
 
-static void tt_roam_list_free(struct bat_priv *bat_priv)
+static void batadv_tt_roam_list_free(struct bat_priv *bat_priv)
 {
 	struct tt_roam_node *node, *safe;
 
@@ -1868,7 +1891,7 @@ static void tt_roam_list_free(struct bat_priv *bat_priv)
 	spin_unlock_bh(&bat_priv->tt_roam_list_lock);
 }
 
-static void tt_roam_purge(struct bat_priv *bat_priv)
+static void batadv_tt_roam_purge(struct bat_priv *bat_priv)
 {
 	struct tt_roam_node *node, *safe;
 
@@ -1889,8 +1912,8 @@ static void tt_roam_purge(struct bat_priv *bat_priv)
  *
  * returns true if the ROAMING_ADV can be sent, false otherwise
  */
-static bool tt_check_roam_count(struct bat_priv *bat_priv,
-				uint8_t *client)
+static bool batadv_tt_check_roam_count(struct bat_priv *bat_priv,
+				       uint8_t *client)
 {
 	struct tt_roam_node *tt_roam_node;
 	bool ret = false;
@@ -1932,8 +1955,8 @@ unlock:
 	return ret;
 }
 
-static void send_roam_adv(struct bat_priv *bat_priv, uint8_t *client,
-			  struct orig_node *orig_node)
+static void batadv_send_roam_adv(struct bat_priv *bat_priv, uint8_t *client,
+				 struct orig_node *orig_node)
 {
 	struct neigh_node *neigh_node = NULL;
 	struct sk_buff *skb = NULL;
@@ -1944,7 +1967,7 @@ static void send_roam_adv(struct bat_priv *bat_priv, uint8_t *client,
 	/* before going on we have to check whether the client has
 	 * already roamed to us too many times
 	 */
-	if (!tt_check_roam_count(bat_priv, client))
+	if (!batadv_tt_check_roam_count(bat_priv, client))
 		goto out;
 
 	skb = dev_alloc_skb(sizeof(struct roam_adv_packet) + ETH_HLEN);
@@ -1988,30 +2011,30 @@ out:
 	return;
 }
 
-static void tt_purge(struct work_struct *work)
+static void batadv_tt_purge(struct work_struct *work)
 {
 	struct delayed_work *delayed_work =
 		container_of(work, struct delayed_work, work);
 	struct bat_priv *bat_priv =
 		container_of(delayed_work, struct bat_priv, tt_work);
 
-	tt_local_purge(bat_priv);
-	tt_global_roam_purge(bat_priv);
-	tt_req_purge(bat_priv);
-	tt_roam_purge(bat_priv);
+	batadv_tt_local_purge(bat_priv);
+	batadv_tt_global_roam_purge(bat_priv);
+	batadv_tt_req_purge(bat_priv);
+	batadv_tt_roam_purge(bat_priv);
 
-	tt_start_timer(bat_priv);
+	batadv_tt_start_timer(bat_priv);
 }
 
 void batadv_tt_free(struct bat_priv *bat_priv)
 {
 	cancel_delayed_work_sync(&bat_priv->tt_work);
 
-	tt_local_table_free(bat_priv);
-	tt_global_table_free(bat_priv);
-	tt_req_list_free(bat_priv);
-	tt_changes_list_free(bat_priv);
-	tt_roam_list_free(bat_priv);
+	batadv_tt_local_table_free(bat_priv);
+	batadv_tt_global_table_free(bat_priv);
+	batadv_tt_req_list_free(bat_priv);
+	batadv_tt_changes_list_free(bat_priv);
+	batadv_tt_roam_list_free(bat_priv);
 
 	kfree(bat_priv->tt_buff);
 }
@@ -2019,8 +2042,8 @@ void batadv_tt_free(struct bat_priv *bat_priv)
 /* This function will enable or disable the specified flags for all the entries
  * in the given hash table and returns the number of modified entries
  */
-static uint16_t tt_set_flags(struct hashtable_t *hash, uint16_t flags,
-			     bool enable)
+static uint16_t batadv_tt_set_flags(struct hashtable_t *hash, uint16_t flags,
+				    bool enable)
 {
 	uint32_t i;
 	uint16_t changed_num = 0;
@@ -2055,7 +2078,7 @@ out:
 }
 
 /* Purge out all the tt local entries marked with TT_CLIENT_PENDING */
-static void tt_local_purge_pending_clients(struct bat_priv *bat_priv)
+static void batadv_tt_local_purge_pending_clients(struct bat_priv *bat_priv)
 {
 	struct hashtable_t *hash = bat_priv->tt_local_hash;
 	struct tt_common_entry *tt_common_entry;
@@ -2087,28 +2110,28 @@ static void tt_local_purge_pending_clients(struct bat_priv *bat_priv)
 			tt_local_entry = container_of(tt_common_entry,
 						      struct tt_local_entry,
 						      common);
-			tt_local_entry_free_ref(tt_local_entry);
+			batadv_tt_local_entry_free_ref(tt_local_entry);
 		}
 		spin_unlock_bh(list_lock);
 	}
 
 }
 
-static int tt_commit_changes(struct bat_priv *bat_priv,
-			     unsigned char **packet_buff, int *packet_buff_len,
-			     int packet_min_len)
+static int batadv_tt_commit_changes(struct bat_priv *bat_priv,
+				    unsigned char **packet_buff,
+				    int *packet_buff_len, int packet_min_len)
 {
 	uint16_t changed_num = 0;
 
 	if (atomic_read(&bat_priv->tt_local_changes) < 1)
 		return -ENOENT;
 
-	changed_num = tt_set_flags(bat_priv->tt_local_hash,
-				   TT_CLIENT_NEW, false);
+	changed_num = batadv_tt_set_flags(bat_priv->tt_local_hash,
+					  TT_CLIENT_NEW, false);
 
 	/* all reset entries have to be counted as local entries */
 	atomic_add(changed_num, &bat_priv->num_local_tt);
-	tt_local_purge_pending_clients(bat_priv);
+	batadv_tt_local_purge_pending_clients(bat_priv);
 	bat_priv->tt_crc = batadv_tt_local_crc(bat_priv);
 
 	/* Increment the TTVN only once per OGM interval */
@@ -2121,8 +2144,8 @@ static int tt_commit_changes(struct bat_priv *bat_priv,
 	/* reset the sending counter */
 	atomic_set(&bat_priv->tt_ogm_append_cnt, TT_OGM_APPEND_MAX);
 
-	return tt_changes_fill_buff(bat_priv, packet_buff,
-				    packet_buff_len, packet_min_len);
+	return batadv_tt_changes_fill_buff(bat_priv, packet_buff,
+					   packet_buff_len, packet_min_len);
 }
 
 /* when calling this function (hard_iface == primary_if) has to be true */
@@ -2133,14 +2156,15 @@ int batadv_tt_append_diff(struct bat_priv *bat_priv,
 	int tt_num_changes;
 
 	/* if at least one change happened */
-	tt_num_changes = tt_commit_changes(bat_priv, packet_buff,
-					   packet_buff_len, packet_min_len);
+	tt_num_changes = batadv_tt_commit_changes(bat_priv, packet_buff,
+						  packet_buff_len,
+						  packet_min_len);
 
 	/* if the changes have been sent often enough */
 	if ((tt_num_changes < 0) &&
 	    (!atomic_dec_not_zero(&bat_priv->tt_ogm_append_cnt))) {
-		tt_realloc_packet_buff(packet_buff, packet_buff_len,
-				       packet_min_len, packet_min_len);
+		batadv_tt_realloc_packet_buff(packet_buff, packet_buff_len,
+					      packet_min_len, packet_min_len);
 		tt_num_changes = 0;
 	}
 
@@ -2157,24 +2181,24 @@ bool batadv_is_ap_isolated(struct bat_priv *bat_priv, uint8_t *src,
 	if (!atomic_read(&bat_priv->ap_isolation))
 		return false;
 
-	tt_local_entry = tt_local_hash_find(bat_priv, dst);
+	tt_local_entry = batadv_tt_local_hash_find(bat_priv, dst);
 	if (!tt_local_entry)
 		goto out;
 
-	tt_global_entry = tt_global_hash_find(bat_priv, src);
+	tt_global_entry = batadv_tt_global_hash_find(bat_priv, src);
 	if (!tt_global_entry)
 		goto out;
 
-	if (_is_ap_isolated(tt_local_entry, tt_global_entry))
+	if (_batadv_is_ap_isolated(tt_local_entry, tt_global_entry))
 		goto out;
 
 	ret = false;
 
 out:
 	if (tt_global_entry)
-		tt_global_entry_free_ref(tt_global_entry);
+		batadv_tt_global_entry_free_ref(tt_global_entry);
 	if (tt_local_entry)
-		tt_local_entry_free_ref(tt_local_entry);
+		batadv_tt_local_entry_free_ref(tt_local_entry);
 	return ret;
 }
 
@@ -2204,14 +2228,14 @@ void batadv_tt_update_orig(struct bat_priv *bat_priv,
 			goto request_table;
 		}
 
-		tt_update_changes(bat_priv, orig_node, tt_num_changes, ttvn,
-				  (struct tt_change *)tt_buff);
+		batadv_tt_update_changes(bat_priv, orig_node, tt_num_changes,
+					 ttvn, (struct tt_change *)tt_buff);
 
 		/* Even if we received the precomputed crc with the OGM, we
 		 * prefer to recompute it to spot any possible inconsistency
 		 * in the global table
 		 */
-		orig_node->tt_crc = tt_global_crc(bat_priv, orig_node);
+		orig_node->tt_crc = batadv_tt_global_crc(bat_priv, orig_node);
 
 		/* The ttvn alone is not enough to guarantee consistency
 		 * because a single value could represent different states
@@ -2240,8 +2264,8 @@ request_table:
 				   "TT inconsistency for %pM. Need to retrieve the correct information (ttvn: %u last_ttvn: %u crc: %u last_crc: %u num_changes: %u)\n",
 				   orig_node->orig, ttvn, orig_ttvn, tt_crc,
 				   orig_node->tt_crc, tt_num_changes);
-			send_tt_request(bat_priv, orig_node, ttvn, tt_crc,
-					full_table);
+			batadv_send_tt_request(bat_priv, orig_node, ttvn,
+					       tt_crc, full_table);
 			return;
 		}
 	}
@@ -2257,12 +2281,12 @@ bool batadv_tt_global_client_is_roaming(struct bat_priv *bat_priv,
 	struct tt_global_entry *tt_global_entry;
 	bool ret = false;
 
-	tt_global_entry = tt_global_hash_find(bat_priv, addr);
+	tt_global_entry = batadv_tt_global_hash_find(bat_priv, addr);
 	if (!tt_global_entry)
 		goto out;
 
 	ret = tt_global_entry->common.flags & TT_CLIENT_ROAM;
-	tt_global_entry_free_ref(tt_global_entry);
+	batadv_tt_global_entry_free_ref(tt_global_entry);
 out:
 	return ret;
 }
-- 
1.7.9.4
