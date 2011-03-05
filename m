From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH 07/28] batman-adv: protect each hash row with rcu locks
Date: Sat,  5 Mar 2011 13:28:21 +0100
Message-ID: <1299328122-21468-8-git-send-email-sven@narfation.org>
References: <1299328122-21468-1-git-send-email-sven@narfation.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:36276 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752831Ab1CEM3h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Mar 2011 07:29:37 -0500
In-Reply-To: <1299328122-21468-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/hash.c              |   34 ++++++++++++----
 net/batman-adv/hash.h              |   73 ++++++++++++++++++++++++------------
 net/batman-adv/icmp_socket.c       |    2 +
 net/batman-adv/originator.c        |   27 ++++++++++---
 net/batman-adv/routing.c           |   16 +++++++-
 net/batman-adv/translation-table.c |   14 +++++++
 net/batman-adv/unicast.c           |    2 +
 net/batman-adv/vis.c               |   18 +++++++--
 8 files changed, 141 insertions(+), 45 deletions(-)

diff --git a/net/batman-adv/hash.c b/net/batman-adv/hash.c
index fa26939..0265366 100644
--- a/net/batman-adv/hash.c
+++ b/net/batman-adv/hash.c
@@ -27,13 +27,16 @@ static void hash_init(struct hashtable_t *hash)
 {
 	int i;
 
-	for (i = 0 ; i < hash->size; i++)
+	for (i = 0 ; i < hash->size; i++) {
 		INIT_HLIST_HEAD(&hash->table[i]);
+		spin_lock_init(&hash->list_locks[i]);
+	}
 }
 
 /* free only the hashtable and the hash itself. */
 void hash_destroy(struct hashtable_t *hash)
 {
+	kfree(hash->list_locks);
 	kfree(hash->table);
 	kfree(hash);
 }
@@ -43,20 +46,33 @@ struct hashtable_t *hash_new(int size)
 {
 	struct hashtable_t *hash;
 
-	hash = kmalloc(sizeof(struct hashtable_t) , GFP_ATOMIC);
-
+	hash = kmalloc(sizeof(struct hashtable_t), GFP_ATOMIC);
 	if (!hash)
 		return NULL;
 
-	hash->size = size;
 	hash->table = kmalloc(sizeof(struct element_t *) * size, GFP_ATOMIC);
+	if (!hash->table)
+		goto free_hash;
 
-	if (!hash->table) {
-		kfree(hash);
-		return NULL;
-	}
+	hash->list_locks = kmalloc(sizeof(spinlock_t) * size, GFP_ATOMIC);
+	if (!hash->list_locks)
+		goto free_table;
 
+	hash->size = size;
 	hash_init(hash);
-
 	return hash;
+
+free_table:
+	kfree(hash->table);
+free_hash:
+	kfree(hash);
+	return NULL;
+}
+
+void bucket_free_rcu(struct rcu_head *rcu)
+{
+	struct element_t *bucket;
+
+	bucket = container_of(rcu, struct element_t, rcu);
+	kfree(bucket);
 }
diff --git a/net/batman-adv/hash.h b/net/batman-adv/hash.h
index eae2440..3c48c6b 100644
--- a/net/batman-adv/hash.h
+++ b/net/batman-adv/hash.h
@@ -39,10 +39,12 @@ typedef void (*hashdata_free_cb)(void *, void *);
 struct element_t {
 	void *data;		/* pointer to the data */
 	struct hlist_node hlist;	/* bucket list pointer */
+	struct rcu_head rcu;
 };
 
 struct hashtable_t {
-	struct hlist_head *table;   /* the hashtable itself, with the buckets */
+	struct hlist_head *table;   /* the hashtable itself with the buckets */
+	spinlock_t *list_locks;     /* spinlock for each hash list entry */
 	int size;		    /* size of hashtable */
 };
 
@@ -52,6 +54,8 @@ struct hashtable_t *hash_new(int size);
 /* free only the hashtable and the hash itself. */
 void hash_destroy(struct hashtable_t *hash);
 
+void bucket_free_rcu(struct rcu_head *rcu);
+
 /* remove the hash structure. if hashdata_free_cb != NULL, this function will be
  * called to remove the elements inside of the hash.  if you don't remove the
  * elements, memory might be leaked. */
@@ -61,19 +65,22 @@ static inline void hash_delete(struct hashtable_t *hash,
 	struct hlist_head *head;
 	struct hlist_node *walk, *safe;
 	struct element_t *bucket;
+	spinlock_t *list_lock; /* spinlock to protect write access */
 	int i;
 
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
+		list_lock = &hash->list_locks[i];
 
-		hlist_for_each_safe(walk, safe, head) {
-			bucket = hlist_entry(walk, struct element_t, hlist);
+		spin_lock_bh(list_lock);
+		hlist_for_each_entry_safe(bucket, walk, safe, head, hlist) {
 			if (free_cb)
 				free_cb(bucket->data, arg);
 
-			hlist_del(walk);
-			kfree(bucket);
+			hlist_del_rcu(walk);
+			call_rcu(&bucket->rcu, bucket_free_rcu);
 		}
+		spin_unlock_bh(list_lock);
 	}
 
 	hash_destroy(hash);
@@ -88,29 +95,39 @@ static inline int hash_add(struct hashtable_t *hash,
 	struct hlist_head *head;
 	struct hlist_node *walk, *safe;
 	struct element_t *bucket;
+	spinlock_t *list_lock; /* spinlock to protect write access */
 
 	if (!hash)
-		return -1;
+		goto err;
 
 	index = choose(data, hash->size);
 	head = &hash->table[index];
+	list_lock = &hash->list_locks[index];
 
-	hlist_for_each_safe(walk, safe, head) {
-		bucket = hlist_entry(walk, struct element_t, hlist);
+	rcu_read_lock();
+	hlist_for_each_entry_safe(bucket, walk, safe, head, hlist) {
 		if (compare(bucket->data, data))
-			return -1;
+			goto err_unlock;
 	}
+	rcu_read_unlock();
 
 	/* no duplicate found in list, add new element */
 	bucket = kmalloc(sizeof(struct element_t), GFP_ATOMIC);
-
 	if (!bucket)
-		return -1;
+		goto err;
 
 	bucket->data = data;
-	hlist_add_head(&bucket->hlist, head);
+
+	spin_lock_bh(list_lock);
+	hlist_add_head_rcu(&bucket->hlist, head);
+	spin_unlock_bh(list_lock);
 
 	return 0;
+
+err_unlock:
+	rcu_read_unlock();
+err:
+	return -1;
 }
 
 /* removes data from hash, if found. returns pointer do data on success, so you
@@ -125,25 +142,31 @@ static inline void *hash_remove(struct hashtable_t *hash,
 	struct hlist_node *walk;
 	struct element_t *bucket;
 	struct hlist_head *head;
-	void *data_save;
+	void *data_save = NULL;
 
 	index = choose(data, hash->size);
 	head = &hash->table[index];
 
+	spin_lock_bh(&hash->list_locks[index]);
 	hlist_for_each_entry(bucket, walk, head, hlist) {
 		if (compare(bucket->data, data)) {
 			data_save = bucket->data;
-			hlist_del(walk);
-			kfree(bucket);
-			return data_save;
+			hlist_del_rcu(walk);
+			call_rcu(&bucket->rcu, bucket_free_rcu);
+			break;
 		}
 	}
+	spin_unlock_bh(&hash->list_locks[index]);
 
-	return NULL;
+	return data_save;
 }
 
-/* finds data, based on the key in keydata. returns the found data on success,
- * or NULL on error */
+/**
+ * finds data, based on the key in keydata. returns the found data on success,
+ * or NULL on error
+ *
+ * caller must lock with rcu_read_lock() / rcu_read_unlock()
+ **/
 static inline void *hash_find(struct hashtable_t *hash,
 			      hashdata_compare_cb compare,
 			      hashdata_choose_cb choose, void *keydata)
@@ -152,6 +175,7 @@ static inline void *hash_find(struct hashtable_t *hash,
 	struct hlist_head *head;
 	struct hlist_node *walk;
 	struct element_t *bucket;
+	void *bucket_data = NULL;
 
 	if (!hash)
 		return NULL;
@@ -159,13 +183,14 @@ static inline void *hash_find(struct hashtable_t *hash,
 	index = choose(keydata , hash->size);
 	head = &hash->table[index];
 
-	hlist_for_each(walk, head) {
-		bucket = hlist_entry(walk, struct element_t, hlist);
-		if (compare(bucket->data, keydata))
-			return bucket->data;
+	hlist_for_each_entry(bucket, walk, head, hlist) {
+		if (compare(bucket->data, keydata)) {
+			bucket_data = bucket->data;
+			break;
+		}
 	}
 
-	return NULL;
+	return bucket_data;
 }
 
 #endif /* _NET_BATMAN_ADV_HASH_H_ */
diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.c
index 319a7cc..8e0cd8a 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -220,9 +220,11 @@ static ssize_t bat_socket_write(struct file *file, const char __user *buff,
 		goto dst_unreach;
 
 	spin_lock_bh(&bat_priv->orig_hash_lock);
+	rcu_read_lock();
 	orig_node = ((struct orig_node *)hash_find(bat_priv->orig_hash,
 						   compare_orig, choose_orig,
 						   icmp_packet->dst));
+	rcu_read_unlock();
 
 	if (!orig_node)
 		goto unlock;
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 899d494..5c32314 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -150,9 +150,11 @@ struct orig_node *get_orig_node(struct bat_priv *bat_priv, uint8_t *addr)
 	int size;
 	int hash_added;
 
+	rcu_read_lock();
 	orig_node = ((struct orig_node *)hash_find(bat_priv->orig_hash,
 						   compare_orig, choose_orig,
 						   addr));
+	rcu_read_unlock();
 
 	if (orig_node)
 		return orig_node;
@@ -294,6 +296,7 @@ static void _purge_orig(struct bat_priv *bat_priv)
 	struct hlist_node *walk, *safe;
 	struct hlist_head *head;
 	struct element_t *bucket;
+	spinlock_t *list_lock; /* spinlock to protect write access */
 	struct orig_node *orig_node;
 	int i;
 
@@ -305,22 +308,26 @@ static void _purge_orig(struct bat_priv *bat_priv)
 	/* for all origins... */
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
+		list_lock = &hash->list_locks[i];
 
+		spin_lock_bh(list_lock);
 		hlist_for_each_entry_safe(bucket, walk, safe, head, hlist) {
 			orig_node = bucket->data;
 
 			if (purge_orig_node(bat_priv, orig_node)) {
 				if (orig_node->gw_flags)
 					gw_node_delete(bat_priv, orig_node);
-				hlist_del(walk);
-				kfree(bucket);
+				hlist_del_rcu(walk);
+				call_rcu(&bucket->rcu, bucket_free_rcu);
 				free_orig_node(orig_node, bat_priv);
+				continue;
 			}
 
 			if (time_after(jiffies, orig_node->last_frag_packet +
 						msecs_to_jiffies(FRAG_TIMEOUT)))
 				frag_list_free(&orig_node->frag_list);
 		}
+		spin_unlock_bh(list_lock);
 	}
 
 	spin_unlock_bh(&bat_priv->orig_hash_lock);
@@ -387,7 +394,8 @@ int orig_seq_print_text(struct seq_file *seq, void *offset)
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
 
-		hlist_for_each_entry(bucket, walk, head, hlist) {
+		rcu_read_lock();
+		hlist_for_each_entry_rcu(bucket, walk, head, hlist) {
 			orig_node = bucket->data;
 
 			if (!orig_node->router)
@@ -408,17 +416,16 @@ int orig_seq_print_text(struct seq_file *seq, void *offset)
 				   neigh_node->addr,
 				   neigh_node->if_incoming->net_dev->name);
 
-			rcu_read_lock();
 			hlist_for_each_entry_rcu(neigh_node, node,
 						 &orig_node->neigh_list, list) {
 				seq_printf(seq, " %pM (%3i)", neigh_node->addr,
 						neigh_node->tq_avg);
 			}
-			rcu_read_unlock();
 
 			seq_printf(seq, "\n");
 			batman_count++;
 		}
+		rcu_read_unlock();
 	}
 
 	spin_unlock_bh(&bat_priv->orig_hash_lock);
@@ -476,18 +483,21 @@ int orig_hash_add_if(struct batman_if *batman_if, int max_if_num)
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
 
-		hlist_for_each_entry(bucket, walk, head, hlist) {
+		rcu_read_lock();
+		hlist_for_each_entry_rcu(bucket, walk, head, hlist) {
 			orig_node = bucket->data;
 
 			if (orig_node_add_if(orig_node, max_if_num) == -1)
 				goto err;
 		}
+		rcu_read_unlock();
 	}
 
 	spin_unlock_bh(&bat_priv->orig_hash_lock);
 	return 0;
 
 err:
+	rcu_read_unlock();
 	spin_unlock_bh(&bat_priv->orig_hash_lock);
 	return -ENOMEM;
 }
@@ -562,7 +572,8 @@ int orig_hash_del_if(struct batman_if *batman_if, int max_if_num)
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
 
-		hlist_for_each_entry(bucket, walk, head, hlist) {
+		rcu_read_lock();
+		hlist_for_each_entry_rcu(bucket, walk, head, hlist) {
 			orig_node = bucket->data;
 
 			ret = orig_node_del_if(orig_node, max_if_num,
@@ -571,6 +582,7 @@ int orig_hash_del_if(struct batman_if *batman_if, int max_if_num)
 			if (ret == -1)
 				goto err;
 		}
+		rcu_read_unlock();
 	}
 
 	/* renumber remaining batman interfaces _inside_ of orig_hash_lock */
@@ -595,6 +607,7 @@ int orig_hash_del_if(struct batman_if *batman_if, int max_if_num)
 	return 0;
 
 err:
+	rcu_read_unlock();
 	spin_unlock_bh(&bat_priv->orig_hash_lock);
 	return -ENOMEM;
 }
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index c15e6c1..32ae04e 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -52,7 +52,8 @@ void slide_own_bcast_window(struct batman_if *batman_if)
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
 
-		hlist_for_each_entry(bucket, walk, head, hlist) {
+		rcu_read_lock();
+		hlist_for_each_entry_rcu(bucket, walk, head, hlist) {
 			orig_node = bucket->data;
 			word_index = batman_if->if_num * NUM_WORDS;
 			word = &(orig_node->bcast_own[word_index]);
@@ -61,6 +62,7 @@ void slide_own_bcast_window(struct batman_if *batman_if)
 			orig_node->bcast_own_sum[batman_if->if_num] =
 				bit_packet_count(word);
 		}
+		rcu_read_unlock();
 	}
 
 	spin_unlock_bh(&bat_priv->orig_hash_lock);
@@ -873,9 +875,11 @@ static int recv_my_icmp_packet(struct bat_priv *bat_priv,
 	/* answer echo request (ping) */
 	/* get routing information */
 	spin_lock_bh(&bat_priv->orig_hash_lock);
+	rcu_read_lock();
 	orig_node = ((struct orig_node *)hash_find(bat_priv->orig_hash,
 						   compare_orig, choose_orig,
 						   icmp_packet->orig));
+	rcu_read_unlock();
 	ret = NET_RX_DROP;
 
 	if ((orig_node) && (orig_node->router)) {
@@ -931,9 +935,11 @@ static int recv_icmp_ttl_exceeded(struct bat_priv *bat_priv,
 
 	/* get routing information */
 	spin_lock_bh(&bat_priv->orig_hash_lock);
+	rcu_read_lock();
 	orig_node = ((struct orig_node *)
 		     hash_find(bat_priv->orig_hash, compare_orig, choose_orig,
 			       icmp_packet->orig));
+	rcu_read_unlock();
 	ret = NET_RX_DROP;
 
 	if ((orig_node) && (orig_node->router)) {
@@ -1023,9 +1029,11 @@ int recv_icmp_packet(struct sk_buff *skb, struct batman_if *recv_if)
 
 	/* get routing information */
 	spin_lock_bh(&bat_priv->orig_hash_lock);
+	rcu_read_lock();
 	orig_node = ((struct orig_node *)
 		     hash_find(bat_priv->orig_hash, compare_orig, choose_orig,
 			       icmp_packet->dst));
+	rcu_read_unlock();
 
 	if ((orig_node) && (orig_node->router)) {
 
@@ -1094,9 +1102,11 @@ struct neigh_node *find_router(struct bat_priv *bat_priv,
 				router_orig->orig, ETH_ALEN) == 0) {
 		primary_orig_node = router_orig;
 	} else {
+		rcu_read_lock();
 		primary_orig_node = hash_find(bat_priv->orig_hash, compare_orig,
 					       choose_orig,
 					       router_orig->primary_addr);
+		rcu_read_unlock();
 
 		if (!primary_orig_node)
 			return orig_node->router;
@@ -1199,9 +1209,11 @@ int route_unicast_packet(struct sk_buff *skb, struct batman_if *recv_if,
 
 	/* get routing information */
 	spin_lock_bh(&bat_priv->orig_hash_lock);
+	rcu_read_lock();
 	orig_node = ((struct orig_node *)
 		     hash_find(bat_priv->orig_hash, compare_orig, choose_orig,
 			       unicast_packet->dest));
+	rcu_read_unlock();
 
 	router = find_router(bat_priv, orig_node, recv_if);
 
@@ -1345,9 +1357,11 @@ int recv_bcast_packet(struct sk_buff *skb, struct batman_if *recv_if)
 		return NET_RX_DROP;
 
 	spin_lock_bh(&bat_priv->orig_hash_lock);
+	rcu_read_lock();
 	orig_node = ((struct orig_node *)
 		     hash_find(bat_priv->orig_hash, compare_orig, choose_orig,
 			       bcast_packet->orig));
+	rcu_read_unlock();
 
 	if (!orig_node) {
 		spin_unlock_bh(&bat_priv->orig_hash_lock);
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 7fb6726..b25e4b3 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -60,10 +60,12 @@ void hna_local_add(struct net_device *soft_iface, uint8_t *addr)
 	int required_bytes;
 
 	spin_lock_bh(&bat_priv->hna_lhash_lock);
+	rcu_read_lock();
 	hna_local_entry =
 		((struct hna_local_entry *)hash_find(bat_priv->hna_local_hash,
 						     compare_orig, choose_orig,
 						     addr));
+	rcu_read_unlock();
 	spin_unlock_bh(&bat_priv->hna_lhash_lock);
 
 	if (hna_local_entry) {
@@ -116,9 +118,11 @@ void hna_local_add(struct net_device *soft_iface, uint8_t *addr)
 	/* remove address from global hash if present */
 	spin_lock_bh(&bat_priv->hna_ghash_lock);
 
+	rcu_read_lock();
 	hna_global_entry = ((struct hna_global_entry *)
 				hash_find(bat_priv->hna_global_hash,
 					  compare_orig, choose_orig, addr));
+	rcu_read_unlock();
 
 	if (hna_global_entry)
 		_hna_global_del_orig(bat_priv, hna_global_entry,
@@ -252,9 +256,11 @@ void hna_local_remove(struct bat_priv *bat_priv,
 
 	spin_lock_bh(&bat_priv->hna_lhash_lock);
 
+	rcu_read_lock();
 	hna_local_entry = (struct hna_local_entry *)
 		hash_find(bat_priv->hna_local_hash, compare_orig, choose_orig,
 			  addr);
+	rcu_read_unlock();
 
 	if (hna_local_entry)
 		hna_local_del(bat_priv, hna_local_entry, message);
@@ -334,9 +340,11 @@ void hna_global_add_orig(struct bat_priv *bat_priv,
 		spin_lock_bh(&bat_priv->hna_ghash_lock);
 
 		hna_ptr = hna_buff + (hna_buff_count * ETH_ALEN);
+		rcu_read_lock();
 		hna_global_entry = (struct hna_global_entry *)
 			hash_find(bat_priv->hna_global_hash, compare_orig,
 				  choose_orig, hna_ptr);
+		rcu_read_unlock();
 
 		if (!hna_global_entry) {
 			spin_unlock_bh(&bat_priv->hna_ghash_lock);
@@ -368,9 +376,11 @@ void hna_global_add_orig(struct bat_priv *bat_priv,
 		spin_lock_bh(&bat_priv->hna_lhash_lock);
 
 		hna_ptr = hna_buff + (hna_buff_count * ETH_ALEN);
+		rcu_read_lock();
 		hna_local_entry = (struct hna_local_entry *)
 			hash_find(bat_priv->hna_local_hash, compare_orig,
 				  choose_orig, hna_ptr);
+		rcu_read_unlock();
 
 		if (hna_local_entry)
 			hna_local_del(bat_priv, hna_local_entry,
@@ -483,9 +493,11 @@ void hna_global_del_orig(struct bat_priv *bat_priv,
 
 	while ((hna_buff_count + 1) * ETH_ALEN <= orig_node->hna_buff_len) {
 		hna_ptr = orig_node->hna_buff + (hna_buff_count * ETH_ALEN);
+		rcu_read_lock();
 		hna_global_entry = (struct hna_global_entry *)
 			hash_find(bat_priv->hna_global_hash, compare_orig,
 				  choose_orig, hna_ptr);
+		rcu_read_unlock();
 
 		if ((hna_global_entry) &&
 		    (hna_global_entry->orig_node == orig_node))
@@ -521,9 +533,11 @@ struct orig_node *transtable_search(struct bat_priv *bat_priv, uint8_t *addr)
 	struct hna_global_entry *hna_global_entry;
 
 	spin_lock_bh(&bat_priv->hna_ghash_lock);
+	rcu_read_lock();
 	hna_global_entry = (struct hna_global_entry *)
 				hash_find(bat_priv->hna_global_hash,
 					  compare_orig, choose_orig, addr);
+	rcu_read_unlock();
 	spin_unlock_bh(&bat_priv->hna_ghash_lock);
 
 	if (!hna_global_entry)
diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index 1b5e761..4687027 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -179,9 +179,11 @@ int frag_reassemble_skb(struct sk_buff *skb, struct bat_priv *bat_priv,
 
 	*new_skb = NULL;
 	spin_lock_bh(&bat_priv->orig_hash_lock);
+	rcu_read_lock();
 	orig_node = ((struct orig_node *)
 		    hash_find(bat_priv->orig_hash, compare_orig, choose_orig,
 			      unicast_packet->orig));
+	rcu_read_unlock();
 
 	if (!orig_node) {
 		pr_debug("couldn't find originator in orig_hash\n");
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index a77b773..8092ead 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -380,8 +380,10 @@ static struct vis_info *add_packet(struct bat_priv *bat_priv,
 						     sizeof(struct vis_packet));
 
 	memcpy(search_packet->vis_orig, vis_packet->vis_orig, ETH_ALEN);
+	rcu_read_lock();
 	old_info = hash_find(bat_priv->vis_hash, vis_info_cmp, vis_info_choose,
 			     &search_elem);
+	rcu_read_unlock();
 	kfree_skb(search_elem.skb_packet);
 
 	if (old_info) {
@@ -540,7 +542,8 @@ static int find_best_vis_server(struct bat_priv *bat_priv,
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
 
-		hlist_for_each_entry(bucket, walk, head, hlist) {
+		rcu_read_lock();
+		hlist_for_each_entry_rcu(bucket, walk, head, hlist) {
 			orig_node = bucket->data;
 			if ((orig_node) && (orig_node->router) &&
 			(orig_node->flags & VIS_SERVER) &&
@@ -550,6 +553,7 @@ static int find_best_vis_server(struct bat_priv *bat_priv,
 				       ETH_ALEN);
 			}
 		}
+		rcu_read_unlock();
 	}
 
 	return best_tq;
@@ -605,7 +609,8 @@ static int generate_vis_packet(struct bat_priv *bat_priv)
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
 
-		hlist_for_each_entry(bucket, walk, head, hlist) {
+		rcu_read_lock();
+		hlist_for_each_entry_rcu(bucket, walk, head, hlist) {
 			orig_node = bucket->data;
 			neigh_node = orig_node->router;
 
@@ -632,10 +637,12 @@ static int generate_vis_packet(struct bat_priv *bat_priv)
 			packet->entries++;
 
 			if (vis_packet_full(info)) {
+				rcu_read_unlock();
 				spin_unlock_bh(&bat_priv->orig_hash_lock);
 				return 0;
 			}
 		}
+		rcu_read_unlock();
 	}
 
 	spin_unlock_bh(&bat_priv->orig_hash_lock);
@@ -721,7 +728,8 @@ static void broadcast_vis_packet(struct bat_priv *bat_priv,
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
 
-		hlist_for_each_entry(bucket, walk, head, hlist) {
+		rcu_read_lock();
+		hlist_for_each_entry_rcu(bucket, walk, head, hlist) {
 			orig_node = bucket->data;
 
 			/* if it's a vis server and reachable, send it. */
@@ -746,7 +754,7 @@ static void broadcast_vis_packet(struct bat_priv *bat_priv,
 
 			spin_lock_bh(&bat_priv->orig_hash_lock);
 		}
-
+		rcu_read_unlock();
 	}
 
 	spin_unlock_bh(&bat_priv->orig_hash_lock);
@@ -763,9 +771,11 @@ static void unicast_vis_packet(struct bat_priv *bat_priv,
 
 	spin_lock_bh(&bat_priv->orig_hash_lock);
 	packet = (struct vis_packet *)info->skb_packet->data;
+	rcu_read_lock();
 	orig_node = ((struct orig_node *)hash_find(bat_priv->orig_hash,
 						   compare_orig, choose_orig,
 						   packet->target_orig));
+	rcu_read_unlock();
 
 	if ((!orig_node) || (!orig_node->router))
 		goto out;
-- 
1.7.2.3

