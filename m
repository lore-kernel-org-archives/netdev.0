From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH 21/28] batman-adv: remove extra layer between hash and hash element - hash bucket
Date: Sat,  5 Mar 2011 13:28:35 +0100
Message-ID: <1299328122-21468-22-git-send-email-sven@narfation.org>
References: <1299328122-21468-1-git-send-email-sven@narfation.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:36338 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753343Ab1CEMaL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Mar 2011 07:30:11 -0500
In-Reply-To: <1299328122-21468-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/hash.c              |    8 --
 net/batman-adv/hash.h              |   95 ++++------------
 net/batman-adv/icmp_socket.c       |    5 +-
 net/batman-adv/originator.c        |   73 ++++---------
 net/batman-adv/originator.h        |   35 ++++++-
 net/batman-adv/routing.c           |   40 +++-----
 net/batman-adv/translation-table.c |  208 +++++++++++++++++++++++-------------
 net/batman-adv/types.h             |    4 +
 net/batman-adv/unicast.c           |   21 ++--
 net/batman-adv/vis.c               |  103 ++++++++++--------
 10 files changed, 298 insertions(+), 294 deletions(-)

diff --git a/net/batman-adv/hash.c b/net/batman-adv/hash.c
index 0265366..c5213d8 100644
--- a/net/batman-adv/hash.c
+++ b/net/batman-adv/hash.c
@@ -68,11 +68,3 @@ free_hash:
 	kfree(hash);
 	return NULL;
 }
-
-void bucket_free_rcu(struct rcu_head *rcu)
-{
-	struct element_t *bucket;
-
-	bucket = container_of(rcu, struct element_t, rcu);
-	kfree(bucket);
-}
diff --git a/net/batman-adv/hash.h b/net/batman-adv/hash.h
index 3c48c6b..434822b 100644
--- a/net/batman-adv/hash.h
+++ b/net/batman-adv/hash.h
@@ -28,19 +28,13 @@
  * compare 2 element datas for their keys,
  * return 0 if same and not 0 if not
  * same */
-typedef int (*hashdata_compare_cb)(void *, void *);
+typedef int (*hashdata_compare_cb)(struct hlist_node *, void *);
 
 /* the hashfunction, should return an index
  * based on the key in the data of the first
  * argument and the size the second */
 typedef int (*hashdata_choose_cb)(void *, int);
-typedef void (*hashdata_free_cb)(void *, void *);
-
-struct element_t {
-	void *data;		/* pointer to the data */
-	struct hlist_node hlist;	/* bucket list pointer */
-	struct rcu_head rcu;
-};
+typedef void (*hashdata_free_cb)(struct hlist_node *, void *);
 
 struct hashtable_t {
 	struct hlist_head *table;   /* the hashtable itself with the buckets */
@@ -54,8 +48,6 @@ struct hashtable_t *hash_new(int size);
 /* free only the hashtable and the hash itself. */
 void hash_destroy(struct hashtable_t *hash);
 
-void bucket_free_rcu(struct rcu_head *rcu);
-
 /* remove the hash structure. if hashdata_free_cb != NULL, this function will be
  * called to remove the elements inside of the hash.  if you don't remove the
  * elements, memory might be leaked. */
@@ -63,8 +55,7 @@ static inline void hash_delete(struct hashtable_t *hash,
 			       hashdata_free_cb free_cb, void *arg)
 {
 	struct hlist_head *head;
-	struct hlist_node *walk, *safe;
-	struct element_t *bucket;
+	struct hlist_node *node, *node_tmp;
 	spinlock_t *list_lock; /* spinlock to protect write access */
 	int i;
 
@@ -73,12 +64,11 @@ static inline void hash_delete(struct hashtable_t *hash,
 		list_lock = &hash->list_locks[i];
 
 		spin_lock_bh(list_lock);
-		hlist_for_each_entry_safe(bucket, walk, safe, head, hlist) {
-			if (free_cb)
-				free_cb(bucket->data, arg);
+		hlist_for_each_safe(node, node_tmp, head) {
+			hlist_del_rcu(node);
 
-			hlist_del_rcu(walk);
-			call_rcu(&bucket->rcu, bucket_free_rcu);
+			if (free_cb)
+				free_cb(node, arg);
 		}
 		spin_unlock_bh(list_lock);
 	}
@@ -89,12 +79,12 @@ static inline void hash_delete(struct hashtable_t *hash,
 /* adds data to the hashtable. returns 0 on success, -1 on error */
 static inline int hash_add(struct hashtable_t *hash,
 			   hashdata_compare_cb compare,
-			   hashdata_choose_cb choose, void *data)
+			   hashdata_choose_cb choose,
+			   void *data, struct hlist_node *data_node)
 {
 	int index;
 	struct hlist_head *head;
-	struct hlist_node *walk, *safe;
-	struct element_t *bucket;
+	struct hlist_node *node;
 	spinlock_t *list_lock; /* spinlock to protect write access */
 
 	if (!hash)
@@ -105,21 +95,17 @@ static inline int hash_add(struct hashtable_t *hash,
 	list_lock = &hash->list_locks[index];
 
 	rcu_read_lock();
-	hlist_for_each_entry_safe(bucket, walk, safe, head, hlist) {
-		if (compare(bucket->data, data))
-			goto err_unlock;
+	__hlist_for_each_rcu(node, head) {
+		if (!compare(node, data))
+			continue;
+
+		goto err_unlock;
 	}
 	rcu_read_unlock();
 
 	/* no duplicate found in list, add new element */
-	bucket = kmalloc(sizeof(struct element_t), GFP_ATOMIC);
-	if (!bucket)
-		goto err;
-
-	bucket->data = data;
-
 	spin_lock_bh(list_lock);
-	hlist_add_head_rcu(&bucket->hlist, head);
+	hlist_add_head_rcu(data_node, head);
 	spin_unlock_bh(list_lock);
 
 	return 0;
@@ -139,8 +125,7 @@ static inline void *hash_remove(struct hashtable_t *hash,
 				hashdata_choose_cb choose, void *data)
 {
 	size_t index;
-	struct hlist_node *walk;
-	struct element_t *bucket;
+	struct hlist_node *node;
 	struct hlist_head *head;
 	void *data_save = NULL;
 
@@ -148,49 +133,17 @@ static inline void *hash_remove(struct hashtable_t *hash,
 	head = &hash->table[index];
 
 	spin_lock_bh(&hash->list_locks[index]);
-	hlist_for_each_entry(bucket, walk, head, hlist) {
-		if (compare(bucket->data, data)) {
-			data_save = bucket->data;
-			hlist_del_rcu(walk);
-			call_rcu(&bucket->rcu, bucket_free_rcu);
-			break;
-		}
+	hlist_for_each(node, head) {
+		if (!compare(node, data))
+			continue;
+
+		data_save = node;
+		hlist_del_rcu(node);
+		break;
 	}
 	spin_unlock_bh(&hash->list_locks[index]);
 
 	return data_save;
 }
 
-/**
- * finds data, based on the key in keydata. returns the found data on success,
- * or NULL on error
- *
- * caller must lock with rcu_read_lock() / rcu_read_unlock()
- **/
-static inline void *hash_find(struct hashtable_t *hash,
-			      hashdata_compare_cb compare,
-			      hashdata_choose_cb choose, void *keydata)
-{
-	int index;
-	struct hlist_head *head;
-	struct hlist_node *walk;
-	struct element_t *bucket;
-	void *bucket_data = NULL;
-
-	if (!hash)
-		return NULL;
-
-	index = choose(keydata , hash->size);
-	head = &hash->table[index];
-
-	hlist_for_each_entry(bucket, walk, head, hlist) {
-		if (compare(bucket->data, keydata)) {
-			bucket_data = bucket->data;
-			break;
-		}
-	}
-
-	return bucket_data;
-}
-
 #endif /* _NET_BATMAN_ADV_HASH_H_ */
diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.c
index 7fa5bb8..139b733 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -222,14 +222,11 @@ static ssize_t bat_socket_write(struct file *file, const char __user *buff,
 
 	spin_lock_bh(&bat_priv->orig_hash_lock);
 	rcu_read_lock();
-	orig_node = ((struct orig_node *)hash_find(bat_priv->orig_hash,
-						   compare_orig, choose_orig,
-						   icmp_packet->dst));
+	orig_node = orig_hash_find(bat_priv, icmp_packet->dst);
 
 	if (!orig_node)
 		goto unlock;
 
-	kref_get(&orig_node->refcount);
 	neigh_node = orig_node->router;
 
 	if (!neigh_node)
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index d9a8e31..bdcb399 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -140,9 +140,8 @@ void orig_node_free_ref(struct kref *refcount)
 void originator_free(struct bat_priv *bat_priv)
 {
 	struct hashtable_t *hash = bat_priv->orig_hash;
-	struct hlist_node *walk, *safe;
+	struct hlist_node *node, *node_tmp;
 	struct hlist_head *head;
-	struct element_t *bucket;
 	spinlock_t *list_lock; /* spinlock to protect write access */
 	struct orig_node *orig_node;
 	int i;
@@ -160,11 +159,10 @@ void originator_free(struct bat_priv *bat_priv)
 		list_lock = &hash->list_locks[i];
 
 		spin_lock_bh(list_lock);
-		hlist_for_each_entry_safe(bucket, walk, safe, head, hlist) {
-			orig_node = bucket->data;
+		hlist_for_each_entry_safe(orig_node, node, node_tmp,
+					  head, hash_entry) {
 
-			hlist_del_rcu(walk);
-			call_rcu(&bucket->rcu, bucket_free_rcu);
+			hlist_del_rcu(node);
 			kref_put(&orig_node->refcount, orig_node_free_ref);
 		}
 		spin_unlock_bh(list_lock);
@@ -174,18 +172,6 @@ void originator_free(struct bat_priv *bat_priv)
 	spin_unlock_bh(&bat_priv->orig_hash_lock);
 }
 
-static void bucket_free_orig_rcu(struct rcu_head *rcu)
-{
-	struct element_t *bucket;
-	struct orig_node *orig_node;
-
-	bucket = container_of(rcu, struct element_t, rcu);
-	orig_node = bucket->data;
-
-	kref_put(&orig_node->refcount, orig_node_free_ref);
-	kfree(bucket);
-}
-
 /* this function finds or creates an originator entry for the given
  * address if it does not exits */
 struct orig_node *get_orig_node(struct bat_priv *bat_priv, uint8_t *addr)
@@ -194,16 +180,9 @@ struct orig_node *get_orig_node(struct bat_priv *bat_priv, uint8_t *addr)
 	int size;
 	int hash_added;
 
-	rcu_read_lock();
-	orig_node = ((struct orig_node *)hash_find(bat_priv->orig_hash,
-						   compare_orig, choose_orig,
-						   addr));
-	rcu_read_unlock();
-
-	if (orig_node) {
-		kref_get(&orig_node->refcount);
+	orig_node = orig_hash_find(bat_priv, addr);
+	if (orig_node)
 		return orig_node;
-	}
 
 	bat_dbg(DBG_BATMAN, bat_priv,
 		"Creating new originator: %pM\n", addr);
@@ -245,8 +224,8 @@ struct orig_node *get_orig_node(struct bat_priv *bat_priv, uint8_t *addr)
 	if (!orig_node->bcast_own_sum)
 		goto free_bcast_own;
 
-	hash_added = hash_add(bat_priv->orig_hash, compare_orig, choose_orig,
-			      orig_node);
+	hash_added = hash_add(bat_priv->orig_hash, compare_orig,
+			      choose_orig, orig_node, &orig_node->hash_entry);
 	if (hash_added < 0)
 		goto free_bcast_own_sum;
 
@@ -346,9 +325,8 @@ static bool purge_orig_node(struct bat_priv *bat_priv,
 static void _purge_orig(struct bat_priv *bat_priv)
 {
 	struct hashtable_t *hash = bat_priv->orig_hash;
-	struct hlist_node *walk, *safe;
+	struct hlist_node *node, *node_tmp;
 	struct hlist_head *head;
-	struct element_t *bucket;
 	spinlock_t *list_lock; /* spinlock to protect write access */
 	struct orig_node *orig_node;
 	int i;
@@ -364,14 +342,14 @@ static void _purge_orig(struct bat_priv *bat_priv)
 		list_lock = &hash->list_locks[i];
 
 		spin_lock_bh(list_lock);
-		hlist_for_each_entry_safe(bucket, walk, safe, head, hlist) {
-			orig_node = bucket->data;
-
+		hlist_for_each_entry_safe(orig_node, node, node_tmp,
+					  head, hash_entry) {
 			if (purge_orig_node(bat_priv, orig_node)) {
 				if (orig_node->gw_flags)
 					gw_node_delete(bat_priv, orig_node);
-				hlist_del_rcu(walk);
-				call_rcu(&bucket->rcu, bucket_free_orig_rcu);
+				hlist_del_rcu(node);
+				kref_put(&orig_node->refcount,
+					 orig_node_free_ref);
 				continue;
 			}
 
@@ -411,9 +389,8 @@ int orig_seq_print_text(struct seq_file *seq, void *offset)
 	struct net_device *net_dev = (struct net_device *)seq->private;
 	struct bat_priv *bat_priv = netdev_priv(net_dev);
 	struct hashtable_t *hash = bat_priv->orig_hash;
-	struct hlist_node *walk, *node;
+	struct hlist_node *node, *node_tmp;
 	struct hlist_head *head;
-	struct element_t *bucket;
 	struct orig_node *orig_node;
 	struct neigh_node *neigh_node;
 	int batman_count = 0;
@@ -447,9 +424,7 @@ int orig_seq_print_text(struct seq_file *seq, void *offset)
 		head = &hash->table[i];
 
 		rcu_read_lock();
-		hlist_for_each_entry_rcu(bucket, walk, head, hlist) {
-			orig_node = bucket->data;
-
+		hlist_for_each_entry_rcu(orig_node, node, head, hash_entry) {
 			if (!orig_node->router)
 				continue;
 
@@ -468,7 +443,7 @@ int orig_seq_print_text(struct seq_file *seq, void *offset)
 				   neigh_node->addr,
 				   neigh_node->if_incoming->net_dev->name);
 
-			hlist_for_each_entry_rcu(neigh_node, node,
+			hlist_for_each_entry_rcu(neigh_node, node_tmp,
 						 &orig_node->neigh_list, list) {
 				seq_printf(seq, " %pM (%3i)", neigh_node->addr,
 						neigh_node->tq_avg);
@@ -522,9 +497,8 @@ int orig_hash_add_if(struct batman_if *batman_if, int max_if_num)
 {
 	struct bat_priv *bat_priv = netdev_priv(batman_if->soft_iface);
 	struct hashtable_t *hash = bat_priv->orig_hash;
-	struct hlist_node *walk;
+	struct hlist_node *node;
 	struct hlist_head *head;
-	struct element_t *bucket;
 	struct orig_node *orig_node;
 	int i, ret;
 
@@ -536,9 +510,7 @@ int orig_hash_add_if(struct batman_if *batman_if, int max_if_num)
 		head = &hash->table[i];
 
 		rcu_read_lock();
-		hlist_for_each_entry_rcu(bucket, walk, head, hlist) {
-			orig_node = bucket->data;
-
+		hlist_for_each_entry_rcu(orig_node, node, head, hash_entry) {
 			spin_lock_bh(&orig_node->ogm_cnt_lock);
 			ret = orig_node_add_if(orig_node, max_if_num);
 			spin_unlock_bh(&orig_node->ogm_cnt_lock);
@@ -614,9 +586,8 @@ int orig_hash_del_if(struct batman_if *batman_if, int max_if_num)
 {
 	struct bat_priv *bat_priv = netdev_priv(batman_if->soft_iface);
 	struct hashtable_t *hash = bat_priv->orig_hash;
-	struct hlist_node *walk;
+	struct hlist_node *node;
 	struct hlist_head *head;
-	struct element_t *bucket;
 	struct batman_if *batman_if_tmp;
 	struct orig_node *orig_node;
 	int i, ret;
@@ -629,9 +600,7 @@ int orig_hash_del_if(struct batman_if *batman_if, int max_if_num)
 		head = &hash->table[i];
 
 		rcu_read_lock();
-		hlist_for_each_entry_rcu(bucket, walk, head, hlist) {
-			orig_node = bucket->data;
-
+		hlist_for_each_entry_rcu(orig_node, node, head, hash_entry) {
 			spin_lock_bh(&orig_node->ogm_cnt_lock);
 			ret = orig_node_del_if(orig_node, max_if_num,
 					batman_if->if_num);
diff --git a/net/batman-adv/originator.h b/net/batman-adv/originator.h
index 84d96e2..b4b9a09 100644
--- a/net/batman-adv/originator.h
+++ b/net/batman-adv/originator.h
@@ -22,6 +22,8 @@
 #ifndef _NET_BATMAN_ADV_ORIGINATOR_H_
 #define _NET_BATMAN_ADV_ORIGINATOR_H_
 
+#include "hash.h"
+
 int originator_init(struct bat_priv *bat_priv);
 void originator_free(struct bat_priv *bat_priv);
 void purge_orig_ref(struct bat_priv *bat_priv);
@@ -38,8 +40,10 @@ int orig_hash_del_if(struct batman_if *batman_if, int max_if_num);
 
 
 /* returns 1 if they are the same originator */
-static inline int compare_orig(void *data1, void *data2)
+static inline int compare_orig(struct hlist_node *node, void *data2)
 {
+	void *data1 = container_of(node, struct orig_node, hash_entry);
+
 	return (memcmp(data1, data2, ETH_ALEN) == 0 ? 1 : 0);
 }
 
@@ -64,4 +68,33 @@ static inline int choose_orig(void *data, int32_t size)
 	return hash % size;
 }
 
+static inline struct orig_node *orig_hash_find(struct bat_priv *bat_priv,
+					       void *data)
+{
+	struct hashtable_t *hash = bat_priv->orig_hash;
+	struct hlist_head *head;
+	struct hlist_node *node;
+	struct orig_node *orig_node, *orig_node_tmp = NULL;
+	int index;
+
+	if (!hash)
+		return NULL;
+
+	index = choose_orig(data, hash->size);
+	head = &hash->table[index];
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(orig_node, node, head, hash_entry) {
+		if (!compare_eth(orig_node, data))
+			continue;
+
+		orig_node_tmp = orig_node;
+		kref_get(&orig_node_tmp->refcount);
+		break;
+	}
+	rcu_read_unlock();
+
+	return orig_node_tmp;
+}
+
 #endif /* _NET_BATMAN_ADV_ORIGINATOR_H_ */
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index b54bf6e..fc4c12a 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -39,9 +39,8 @@ void slide_own_bcast_window(struct batman_if *batman_if)
 {
 	struct bat_priv *bat_priv = netdev_priv(batman_if->soft_iface);
 	struct hashtable_t *hash = bat_priv->orig_hash;
-	struct hlist_node *walk;
+	struct hlist_node *node;
 	struct hlist_head *head;
-	struct element_t *bucket;
 	struct orig_node *orig_node;
 	unsigned long *word;
 	int i;
@@ -53,8 +52,7 @@ void slide_own_bcast_window(struct batman_if *batman_if)
 		head = &hash->table[i];
 
 		rcu_read_lock();
-		hlist_for_each_entry_rcu(bucket, walk, head, hlist) {
-			orig_node = bucket->data;
+		hlist_for_each_entry_rcu(orig_node, node, head, hash_entry) {
 			spin_lock_bh(&orig_node->ogm_cnt_lock);
 			word_index = batman_if->if_num * NUM_WORDS;
 			word = &(orig_node->bcast_own[word_index]);
@@ -908,14 +906,11 @@ static int recv_my_icmp_packet(struct bat_priv *bat_priv,
 	/* get routing information */
 	spin_lock_bh(&bat_priv->orig_hash_lock);
 	rcu_read_lock();
-	orig_node = ((struct orig_node *)hash_find(bat_priv->orig_hash,
-						   compare_orig, choose_orig,
-						   icmp_packet->orig));
+	orig_node = orig_hash_find(bat_priv, icmp_packet->orig);
 
 	if (!orig_node)
 		goto unlock;
 
-	kref_get(&orig_node->refcount);
 	neigh_node = orig_node->router;
 
 	if (!neigh_node)
@@ -987,14 +982,11 @@ static int recv_icmp_ttl_exceeded(struct bat_priv *bat_priv,
 	/* get routing information */
 	spin_lock_bh(&bat_priv->orig_hash_lock);
 	rcu_read_lock();
-	orig_node = ((struct orig_node *)
-		     hash_find(bat_priv->orig_hash, compare_orig, choose_orig,
-			       icmp_packet->orig));
+	orig_node = orig_hash_find(bat_priv, icmp_packet->orig);
 
 	if (!orig_node)
 		goto unlock;
 
-	kref_get(&orig_node->refcount);
 	neigh_node = orig_node->router;
 
 	if (!neigh_node)
@@ -1098,13 +1090,11 @@ int recv_icmp_packet(struct sk_buff *skb, struct batman_if *recv_if)
 	/* get routing information */
 	spin_lock_bh(&bat_priv->orig_hash_lock);
 	rcu_read_lock();
-	orig_node = ((struct orig_node *)
-		     hash_find(bat_priv->orig_hash, compare_orig, choose_orig,
-			       icmp_packet->dst));
+	orig_node = orig_hash_find(bat_priv, icmp_packet->dst);
+
 	if (!orig_node)
 		goto unlock;
 
-	kref_get(&orig_node->refcount);
 	neigh_node = orig_node->router;
 
 	if (!neigh_node)
@@ -1194,11 +1184,12 @@ struct neigh_node *find_router(struct bat_priv *bat_priv,
 	if (compare_eth(router_orig->primary_addr, router_orig->orig)) {
 		primary_orig_node = router_orig;
 	} else {
-		primary_orig_node = hash_find(bat_priv->orig_hash, compare_orig,
-					       choose_orig,
-					       router_orig->primary_addr);
+		primary_orig_node = orig_hash_find(bat_priv,
+						   router_orig->primary_addr);
 		if (!primary_orig_node)
 			goto return_router;
+
+		kref_put(&primary_orig_node->refcount, orig_node_free_ref);
 	}
 
 	/* with less than 2 candidates, we can't do any
@@ -1344,13 +1335,11 @@ int route_unicast_packet(struct sk_buff *skb, struct batman_if *recv_if,
 	/* get routing information */
 	spin_lock_bh(&bat_priv->orig_hash_lock);
 	rcu_read_lock();
-	orig_node = ((struct orig_node *)
-		     hash_find(bat_priv->orig_hash, compare_orig, choose_orig,
-			       unicast_packet->dest));
+	orig_node = orig_hash_find(bat_priv, unicast_packet->dest);
+
 	if (!orig_node)
 		goto unlock;
 
-	kref_get(&orig_node->refcount);
 	rcu_read_unlock();
 
 	/* find_router() increases neigh_nodes refcount if found. */
@@ -1508,14 +1497,11 @@ int recv_bcast_packet(struct sk_buff *skb, struct batman_if *recv_if)
 
 	spin_lock_bh(&bat_priv->orig_hash_lock);
 	rcu_read_lock();
-	orig_node = ((struct orig_node *)
-		     hash_find(bat_priv->orig_hash, compare_orig, choose_orig,
-			       bcast_packet->orig));
+	orig_node = orig_hash_find(bat_priv, bcast_packet->orig);
 
 	if (!orig_node)
 		goto rcu_unlock;
 
-	kref_get(&orig_node->refcount);
 	rcu_read_unlock();
 
 	spin_lock_bh(&orig_node->bcast_seqno_lock);
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 77d0ee0..cd8a583 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -30,12 +30,85 @@ static void _hna_global_del_orig(struct bat_priv *bat_priv,
 				 struct hna_global_entry *hna_global_entry,
 				 char *message);
 
+/* returns 1 if they are the same mac addr */
+static int compare_lhna(struct hlist_node *node, void *data2)
+{
+	void *data1 = container_of(node, struct hna_local_entry, hash_entry);
+
+	return (memcmp(data1, data2, ETH_ALEN) == 0 ? 1 : 0);
+}
+
+/* returns 1 if they are the same mac addr */
+static int compare_ghna(struct hlist_node *node, void *data2)
+{
+	void *data1 = container_of(node, struct hna_global_entry, hash_entry);
+
+	return (memcmp(data1, data2, ETH_ALEN) == 0 ? 1 : 0);
+}
+
 static void hna_local_start_timer(struct bat_priv *bat_priv)
 {
 	INIT_DELAYED_WORK(&bat_priv->hna_work, hna_local_purge);
 	queue_delayed_work(bat_event_workqueue, &bat_priv->hna_work, 10 * HZ);
 }
 
+static struct hna_local_entry *hna_local_hash_find(struct bat_priv *bat_priv,
+						   void *data)
+{
+	struct hashtable_t *hash = bat_priv->hna_local_hash;
+	struct hlist_head *head;
+	struct hlist_node *node;
+	struct hna_local_entry *hna_local_entry, *hna_local_entry_tmp = NULL;
+	int index;
+
+	if (!hash)
+		return NULL;
+
+	index = choose_orig(data, hash->size);
+	head = &hash->table[index];
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(hna_local_entry, node, head, hash_entry) {
+		if (!compare_eth(hna_local_entry, data))
+			continue;
+
+		hna_local_entry_tmp = hna_local_entry;
+		break;
+	}
+	rcu_read_unlock();
+
+	return hna_local_entry_tmp;
+}
+
+static struct hna_global_entry *hna_global_hash_find(struct bat_priv *bat_priv,
+						     void *data)
+{
+	struct hashtable_t *hash = bat_priv->hna_global_hash;
+	struct hlist_head *head;
+	struct hlist_node *node;
+	struct hna_global_entry *hna_global_entry;
+	struct hna_global_entry *hna_global_entry_tmp = NULL;
+	int index;
+
+	if (!hash)
+		return NULL;
+
+	index = choose_orig(data, hash->size);
+	head = &hash->table[index];
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(hna_global_entry, node, head, hash_entry) {
+		if (!compare_eth(hna_global_entry, data))
+			continue;
+
+		hna_global_entry_tmp = hna_global_entry;
+		break;
+	}
+	rcu_read_unlock();
+
+	return hna_global_entry_tmp;
+}
+
 int hna_local_init(struct bat_priv *bat_priv)
 {
 	if (bat_priv->hna_local_hash)
@@ -60,12 +133,7 @@ void hna_local_add(struct net_device *soft_iface, uint8_t *addr)
 	int required_bytes;
 
 	spin_lock_bh(&bat_priv->hna_lhash_lock);
-	rcu_read_lock();
-	hna_local_entry =
-		((struct hna_local_entry *)hash_find(bat_priv->hna_local_hash,
-						     compare_orig, choose_orig,
-						     addr));
-	rcu_read_unlock();
+	hna_local_entry = hna_local_hash_find(bat_priv, addr);
 	spin_unlock_bh(&bat_priv->hna_lhash_lock);
 
 	if (hna_local_entry) {
@@ -108,8 +176,8 @@ void hna_local_add(struct net_device *soft_iface, uint8_t *addr)
 
 	spin_lock_bh(&bat_priv->hna_lhash_lock);
 
-	hash_add(bat_priv->hna_local_hash, compare_orig, choose_orig,
-		 hna_local_entry);
+	hash_add(bat_priv->hna_local_hash, compare_lhna, choose_orig,
+		 hna_local_entry, &hna_local_entry->hash_entry);
 	bat_priv->num_local_hna++;
 	atomic_set(&bat_priv->hna_local_changed, 1);
 
@@ -118,11 +186,7 @@ void hna_local_add(struct net_device *soft_iface, uint8_t *addr)
 	/* remove address from global hash if present */
 	spin_lock_bh(&bat_priv->hna_ghash_lock);
 
-	rcu_read_lock();
-	hna_global_entry = ((struct hna_global_entry *)
-				hash_find(bat_priv->hna_global_hash,
-					  compare_orig, choose_orig, addr));
-	rcu_read_unlock();
+	hna_global_entry = hna_global_hash_find(bat_priv, addr);
 
 	if (hna_global_entry)
 		_hna_global_del_orig(bat_priv, hna_global_entry,
@@ -136,28 +200,27 @@ int hna_local_fill_buffer(struct bat_priv *bat_priv,
 {
 	struct hashtable_t *hash = bat_priv->hna_local_hash;
 	struct hna_local_entry *hna_local_entry;
-	struct element_t *bucket;
-	int i;
-	struct hlist_node *walk;
+	struct hlist_node *node;
 	struct hlist_head *head;
-	int count = 0;
+	int i, count = 0;
 
 	spin_lock_bh(&bat_priv->hna_lhash_lock);
 
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
 
-		hlist_for_each_entry(bucket, walk, head, hlist) {
-
+		rcu_read_lock();
+		hlist_for_each_entry_rcu(hna_local_entry, node,
+					 head, hash_entry) {
 			if (buff_len < (count + 1) * ETH_ALEN)
 				break;
 
-			hna_local_entry = bucket->data;
 			memcpy(buff + (count * ETH_ALEN), hna_local_entry->addr,
 			       ETH_ALEN);
 
 			count++;
 		}
+		rcu_read_unlock();
 	}
 
 	/* if we did not get all new local hnas see you next time  ;-) */
@@ -174,12 +237,11 @@ int hna_local_seq_print_text(struct seq_file *seq, void *offset)
 	struct bat_priv *bat_priv = netdev_priv(net_dev);
 	struct hashtable_t *hash = bat_priv->hna_local_hash;
 	struct hna_local_entry *hna_local_entry;
-	int i;
-	struct hlist_node *walk;
+	struct hlist_node *node;
 	struct hlist_head *head;
-	struct element_t *bucket;
 	size_t buf_size, pos;
 	char *buff;
+	int i;
 
 	if (!bat_priv->primary_if) {
 		return seq_printf(seq, "BATMAN mesh %s disabled - "
@@ -198,8 +260,10 @@ int hna_local_seq_print_text(struct seq_file *seq, void *offset)
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
 
-		hlist_for_each(walk, head)
+		rcu_read_lock();
+		__hlist_for_each_rcu(node, head)
 			buf_size += 21;
+		rcu_read_unlock();
 	}
 
 	buff = kmalloc(buf_size, GFP_ATOMIC);
@@ -207,18 +271,20 @@ int hna_local_seq_print_text(struct seq_file *seq, void *offset)
 		spin_unlock_bh(&bat_priv->hna_lhash_lock);
 		return -ENOMEM;
 	}
+
 	buff[0] = '\0';
 	pos = 0;
 
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
 
-		hlist_for_each_entry(bucket, walk, head, hlist) {
-			hna_local_entry = bucket->data;
-
+		rcu_read_lock();
+		hlist_for_each_entry_rcu(hna_local_entry, node,
+					 head, hash_entry) {
 			pos += snprintf(buff + pos, 22, " * %pM\n",
 					hna_local_entry->addr);
 		}
+		rcu_read_unlock();
 	}
 
 	spin_unlock_bh(&bat_priv->hna_lhash_lock);
@@ -228,9 +294,10 @@ int hna_local_seq_print_text(struct seq_file *seq, void *offset)
 	return 0;
 }
 
-static void _hna_local_del(void *data, void *arg)
+static void _hna_local_del(struct hlist_node *node, void *arg)
 {
 	struct bat_priv *bat_priv = (struct bat_priv *)arg;
+	void *data = container_of(node, struct hna_local_entry, hash_entry);
 
 	kfree(data);
 	bat_priv->num_local_hna--;
@@ -244,9 +311,9 @@ static void hna_local_del(struct bat_priv *bat_priv,
 	bat_dbg(DBG_ROUTES, bat_priv, "Deleting local hna entry (%pM): %s\n",
 		hna_local_entry->addr, message);
 
-	hash_remove(bat_priv->hna_local_hash, compare_orig, choose_orig,
+	hash_remove(bat_priv->hna_local_hash, compare_lhna, choose_orig,
 		    hna_local_entry->addr);
-	_hna_local_del(hna_local_entry, bat_priv);
+	_hna_local_del(&hna_local_entry->hash_entry, bat_priv);
 }
 
 void hna_local_remove(struct bat_priv *bat_priv,
@@ -256,11 +323,7 @@ void hna_local_remove(struct bat_priv *bat_priv,
 
 	spin_lock_bh(&bat_priv->hna_lhash_lock);
 
-	rcu_read_lock();
-	hna_local_entry = (struct hna_local_entry *)
-		hash_find(bat_priv->hna_local_hash, compare_orig, choose_orig,
-			  addr);
-	rcu_read_unlock();
+	hna_local_entry = hna_local_hash_find(bat_priv, addr);
 
 	if (hna_local_entry)
 		hna_local_del(bat_priv, hna_local_entry, message);
@@ -276,27 +339,29 @@ static void hna_local_purge(struct work_struct *work)
 		container_of(delayed_work, struct bat_priv, hna_work);
 	struct hashtable_t *hash = bat_priv->hna_local_hash;
 	struct hna_local_entry *hna_local_entry;
-	int i;
-	struct hlist_node *walk, *safe;
+	struct hlist_node *node, *node_tmp;
 	struct hlist_head *head;
-	struct element_t *bucket;
 	unsigned long timeout;
+	int i;
 
 	spin_lock_bh(&bat_priv->hna_lhash_lock);
 
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
 
-		hlist_for_each_entry_safe(bucket, walk, safe, head, hlist) {
-			hna_local_entry = bucket->data;
+		hlist_for_each_entry_safe(hna_local_entry, node, node_tmp,
+					  head, hash_entry) {
+			if (hna_local_entry->never_purge)
+				continue;
 
 			timeout = hna_local_entry->last_seen;
 			timeout += LOCAL_HNA_TIMEOUT * HZ;
 
-			if ((!hna_local_entry->never_purge) &&
-			    time_after(jiffies, timeout))
-				hna_local_del(bat_priv, hna_local_entry,
-					"address timed out");
+			if (time_before(jiffies, timeout))
+				continue;
+
+			hna_local_del(bat_priv, hna_local_entry,
+				      "address timed out");
 		}
 	}
 
@@ -340,11 +405,7 @@ void hna_global_add_orig(struct bat_priv *bat_priv,
 		spin_lock_bh(&bat_priv->hna_ghash_lock);
 
 		hna_ptr = hna_buff + (hna_buff_count * ETH_ALEN);
-		rcu_read_lock();
-		hna_global_entry = (struct hna_global_entry *)
-			hash_find(bat_priv->hna_global_hash, compare_orig,
-				  choose_orig, hna_ptr);
-		rcu_read_unlock();
+		hna_global_entry = hna_global_hash_find(bat_priv, hna_ptr);
 
 		if (!hna_global_entry) {
 			spin_unlock_bh(&bat_priv->hna_ghash_lock);
@@ -364,8 +425,9 @@ void hna_global_add_orig(struct bat_priv *bat_priv,
 				hna_global_entry->addr, orig_node->orig);
 
 			spin_lock_bh(&bat_priv->hna_ghash_lock);
-			hash_add(bat_priv->hna_global_hash, compare_orig,
-				 choose_orig, hna_global_entry);
+			hash_add(bat_priv->hna_global_hash, compare_ghna,
+				 choose_orig, hna_global_entry,
+				 &hna_global_entry->hash_entry);
 
 		}
 
@@ -376,11 +438,7 @@ void hna_global_add_orig(struct bat_priv *bat_priv,
 		spin_lock_bh(&bat_priv->hna_lhash_lock);
 
 		hna_ptr = hna_buff + (hna_buff_count * ETH_ALEN);
-		rcu_read_lock();
-		hna_local_entry = (struct hna_local_entry *)
-			hash_find(bat_priv->hna_local_hash, compare_orig,
-				  choose_orig, hna_ptr);
-		rcu_read_unlock();
+		hna_local_entry = hna_local_hash_find(bat_priv, hna_ptr);
 
 		if (hna_local_entry)
 			hna_local_del(bat_priv, hna_local_entry,
@@ -410,12 +468,11 @@ int hna_global_seq_print_text(struct seq_file *seq, void *offset)
 	struct bat_priv *bat_priv = netdev_priv(net_dev);
 	struct hashtable_t *hash = bat_priv->hna_global_hash;
 	struct hna_global_entry *hna_global_entry;
-	int i;
-	struct hlist_node *walk;
+	struct hlist_node *node;
 	struct hlist_head *head;
-	struct element_t *bucket;
 	size_t buf_size, pos;
 	char *buff;
+	int i;
 
 	if (!bat_priv->primary_if) {
 		return seq_printf(seq, "BATMAN mesh %s disabled - "
@@ -433,8 +490,10 @@ int hna_global_seq_print_text(struct seq_file *seq, void *offset)
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
 
-		hlist_for_each(walk, head)
+		rcu_read_lock();
+		__hlist_for_each_rcu(node, head)
 			buf_size += 43;
+		rcu_read_unlock();
 	}
 
 	buff = kmalloc(buf_size, GFP_ATOMIC);
@@ -448,14 +507,15 @@ int hna_global_seq_print_text(struct seq_file *seq, void *offset)
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
 
-		hlist_for_each_entry(bucket, walk, head, hlist) {
-			hna_global_entry = bucket->data;
-
+		rcu_read_lock();
+		hlist_for_each_entry_rcu(hna_global_entry, node,
+					 head, hash_entry) {
 			pos += snprintf(buff + pos, 44,
 					" * %pM via %pM\n",
 					hna_global_entry->addr,
 					hna_global_entry->orig_node->orig);
 		}
+		rcu_read_unlock();
 	}
 
 	spin_unlock_bh(&bat_priv->hna_ghash_lock);
@@ -474,7 +534,7 @@ static void _hna_global_del_orig(struct bat_priv *bat_priv,
 		hna_global_entry->addr, hna_global_entry->orig_node->orig,
 		message);
 
-	hash_remove(bat_priv->hna_global_hash, compare_orig, choose_orig,
+	hash_remove(bat_priv->hna_global_hash, compare_ghna, choose_orig,
 		    hna_global_entry->addr);
 	kfree(hna_global_entry);
 }
@@ -493,11 +553,7 @@ void hna_global_del_orig(struct bat_priv *bat_priv,
 
 	while ((hna_buff_count + 1) * ETH_ALEN <= orig_node->hna_buff_len) {
 		hna_ptr = orig_node->hna_buff + (hna_buff_count * ETH_ALEN);
-		rcu_read_lock();
-		hna_global_entry = (struct hna_global_entry *)
-			hash_find(bat_priv->hna_global_hash, compare_orig,
-				  choose_orig, hna_ptr);
-		rcu_read_unlock();
+		hna_global_entry = hna_global_hash_find(bat_priv, hna_ptr);
 
 		if ((hna_global_entry) &&
 		    (hna_global_entry->orig_node == orig_node))
@@ -514,8 +570,10 @@ void hna_global_del_orig(struct bat_priv *bat_priv,
 	orig_node->hna_buff = NULL;
 }
 
-static void hna_global_del(void *data, void *arg)
+static void hna_global_del(struct hlist_node *node, void *arg)
 {
+	void *data = container_of(node, struct hna_global_entry, hash_entry);
+
 	kfree(data);
 }
 
@@ -533,11 +591,11 @@ struct orig_node *transtable_search(struct bat_priv *bat_priv, uint8_t *addr)
 	struct hna_global_entry *hna_global_entry;
 
 	spin_lock_bh(&bat_priv->hna_ghash_lock);
-	rcu_read_lock();
-	hna_global_entry = (struct hna_global_entry *)
-				hash_find(bat_priv->hna_global_hash,
-					  compare_orig, choose_orig, addr);
-	rcu_read_unlock();
+	hna_global_entry = hna_global_hash_find(bat_priv, addr);
+
+	if (hna_global_entry)
+		kref_get(&hna_global_entry->orig_node->refcount);
+
 	spin_unlock_bh(&bat_priv->hna_ghash_lock);
 
 	if (!hna_global_entry)
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 3dd5e77..40365b8 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -85,6 +85,7 @@ struct orig_node {
 	struct list_head frag_list;
 	spinlock_t neigh_list_lock; /* protects neighbor list */
 	struct kref refcount;
+	struct hlist_node hash_entry;
 	struct bat_priv *bat_priv;
 	unsigned long last_frag_packet;
 	spinlock_t ogm_cnt_lock; /* protects: bcast_own, bcast_own_sum,
@@ -194,11 +195,13 @@ struct hna_local_entry {
 	uint8_t addr[ETH_ALEN];
 	unsigned long last_seen;
 	char never_purge;
+	struct hlist_node hash_entry;
 };
 
 struct hna_global_entry {
 	uint8_t addr[ETH_ALEN];
 	struct orig_node *orig_node;
+	struct hlist_node hash_entry;
 };
 
 /**
@@ -248,6 +251,7 @@ struct vis_info {
 			     * from.  we should not reply to them. */
 	struct list_head send_list;
 	struct kref refcount;
+	struct hlist_node hash_entry;
 	struct bat_priv *bat_priv;
 	/* this packet might be part of the vis send queue. */
 	struct sk_buff *skb_packet;
diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index 0603cea..2d5daac 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -178,17 +178,11 @@ int frag_reassemble_skb(struct sk_buff *skb, struct bat_priv *bat_priv,
 		(struct unicast_frag_packet *)skb->data;
 
 	*new_skb = NULL;
+
 	spin_lock_bh(&bat_priv->orig_hash_lock);
-	rcu_read_lock();
-	orig_node = ((struct orig_node *)
-		    hash_find(bat_priv->orig_hash, compare_orig, choose_orig,
-			      unicast_packet->orig));
-	rcu_read_unlock();
-
-	if (!orig_node) {
-		pr_debug("couldn't find originator in orig_hash\n");
-		goto out;
-	}
+	orig_node = orig_hash_find(bat_priv, unicast_packet->orig);
+	if (!orig_node)
+		goto unlock;
 
 	orig_node->last_frag_packet = jiffies;
 
@@ -212,9 +206,12 @@ int frag_reassemble_skb(struct sk_buff *skb, struct bat_priv *bat_priv,
 	/* if not, merge failed */
 	if (*new_skb)
 		ret = NET_RX_SUCCESS;
-out:
-	spin_unlock_bh(&bat_priv->orig_hash_lock);
 
+unlock:
+	spin_unlock_bh(&bat_priv->orig_hash_lock);
+out:
+	if (orig_node)
+		kref_put(&orig_node->refcount, orig_node_free_ref);
 	return ret;
 }
 
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index fc97329..d179aca 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -67,11 +67,12 @@ static void free_info(struct kref *ref)
 }
 
 /* Compare two vis packets, used by the hashing algorithm */
-static int vis_info_cmp(void *data1, void *data2)
+static int vis_info_cmp(struct hlist_node *node, void *data2)
 {
 	struct vis_info *d1, *d2;
 	struct vis_packet *p1, *p2;
-	d1 = data1;
+
+	d1 = container_of(node, struct vis_info, hash_entry);
 	d2 = data2;
 	p1 = (struct vis_packet *)d1->skb_packet->data;
 	p2 = (struct vis_packet *)d2->skb_packet->data;
@@ -103,6 +104,34 @@ static int vis_info_choose(void *data, int size)
 	return hash % size;
 }
 
+static struct vis_info *vis_hash_find(struct bat_priv *bat_priv,
+				      void *data)
+{
+	struct hashtable_t *hash = bat_priv->vis_hash;
+	struct hlist_head *head;
+	struct hlist_node *node;
+	struct vis_info *vis_info, *vis_info_tmp = NULL;
+	int index;
+
+	if (!hash)
+		return NULL;
+
+	index = vis_info_choose(data, hash->size);
+	head = &hash->table[index];
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(vis_info, node, head, hash_entry) {
+		if (!vis_info_cmp(node, data))
+			continue;
+
+		vis_info_tmp = vis_info;
+		break;
+	}
+	rcu_read_unlock();
+
+	return vis_info_tmp;
+}
+
 /* insert interface to the list of interfaces of one originator, if it
  * does not already exist in the list */
 static void vis_data_insert_interface(const uint8_t *interface,
@@ -174,9 +203,8 @@ static ssize_t vis_data_read_entry(char *buff, struct vis_info_entry *entry,
 
 int vis_seq_print_text(struct seq_file *seq, void *offset)
 {
-	struct hlist_node *walk;
+	struct hlist_node *node;
 	struct hlist_head *head;
-	struct element_t *bucket;
 	struct vis_info *info;
 	struct vis_packet *packet;
 	struct vis_info_entry *entries;
@@ -202,8 +230,8 @@ int vis_seq_print_text(struct seq_file *seq, void *offset)
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
 
-		hlist_for_each_entry(bucket, walk, head, hlist) {
-			info = bucket->data;
+		rcu_read_lock();
+		hlist_for_each_entry_rcu(info, node, head, hash_entry) {
 			packet = (struct vis_packet *)info->skb_packet->data;
 			entries = (struct vis_info_entry *)
 				((char *)packet + sizeof(struct vis_packet));
@@ -235,6 +263,7 @@ int vis_seq_print_text(struct seq_file *seq, void *offset)
 				kfree(entry);
 			}
 		}
+		rcu_read_unlock();
 	}
 
 	buff = kmalloc(buf_size, GFP_ATOMIC);
@@ -248,8 +277,8 @@ int vis_seq_print_text(struct seq_file *seq, void *offset)
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
 
-		hlist_for_each_entry(bucket, walk, head, hlist) {
-			info = bucket->data;
+		rcu_read_lock();
+		hlist_for_each_entry_rcu(info, node, head, hash_entry) {
 			packet = (struct vis_packet *)info->skb_packet->data;
 			entries = (struct vis_info_entry *)
 				((char *)packet + sizeof(struct vis_packet));
@@ -290,6 +319,7 @@ int vis_seq_print_text(struct seq_file *seq, void *offset)
 				kfree(entry);
 			}
 		}
+		rcu_read_unlock();
 	}
 
 	spin_unlock_bh(&bat_priv->vis_hash_lock);
@@ -380,10 +410,7 @@ static struct vis_info *add_packet(struct bat_priv *bat_priv,
 						     sizeof(struct vis_packet));
 
 	memcpy(search_packet->vis_orig, vis_packet->vis_orig, ETH_ALEN);
-	rcu_read_lock();
-	old_info = hash_find(bat_priv->vis_hash, vis_info_cmp, vis_info_choose,
-			     &search_elem);
-	rcu_read_unlock();
+	old_info = vis_hash_find(bat_priv, &search_elem);
 	kfree_skb(search_elem.skb_packet);
 
 	if (old_info) {
@@ -443,7 +470,7 @@ static struct vis_info *add_packet(struct bat_priv *bat_priv,
 
 	/* try to add it */
 	hash_added = hash_add(bat_priv->vis_hash, vis_info_cmp, vis_info_choose,
-			      info);
+			      info, &info->hash_entry);
 	if (hash_added < 0) {
 		/* did not work (for some reason) */
 		kref_put(&old_info->refcount, free_info);
@@ -530,9 +557,8 @@ static int find_best_vis_server(struct bat_priv *bat_priv,
 				struct vis_info *info)
 {
 	struct hashtable_t *hash = bat_priv->orig_hash;
-	struct hlist_node *walk;
+	struct hlist_node *node;
 	struct hlist_head *head;
-	struct element_t *bucket;
 	struct orig_node *orig_node;
 	struct vis_packet *packet;
 	int best_tq = -1, i;
@@ -543,11 +569,10 @@ static int find_best_vis_server(struct bat_priv *bat_priv,
 		head = &hash->table[i];
 
 		rcu_read_lock();
-		hlist_for_each_entry_rcu(bucket, walk, head, hlist) {
-			orig_node = bucket->data;
+		hlist_for_each_entry_rcu(orig_node, node, head, hash_entry) {
 			if ((orig_node) && (orig_node->router) &&
-			(orig_node->flags & VIS_SERVER) &&
-			(orig_node->router->tq_avg > best_tq)) {
+			    (orig_node->flags & VIS_SERVER) &&
+			    (orig_node->router->tq_avg > best_tq)) {
 				best_tq = orig_node->router->tq_avg;
 				memcpy(packet->target_orig, orig_node->orig,
 				       ETH_ALEN);
@@ -576,9 +601,8 @@ static bool vis_packet_full(struct vis_info *info)
 static int generate_vis_packet(struct bat_priv *bat_priv)
 {
 	struct hashtable_t *hash = bat_priv->orig_hash;
-	struct hlist_node *walk;
+	struct hlist_node *node;
 	struct hlist_head *head;
-	struct element_t *bucket;
 	struct orig_node *orig_node;
 	struct neigh_node *neigh_node;
 	struct vis_info *info = (struct vis_info *)bat_priv->my_vis_info;
@@ -610,8 +634,7 @@ static int generate_vis_packet(struct bat_priv *bat_priv)
 		head = &hash->table[i];
 
 		rcu_read_lock();
-		hlist_for_each_entry_rcu(bucket, walk, head, hlist) {
-			orig_node = bucket->data;
+		hlist_for_each_entry_rcu(orig_node, node, head, hash_entry) {
 			neigh_node = orig_node->router;
 
 			if (!neigh_node)
@@ -653,8 +676,7 @@ static int generate_vis_packet(struct bat_priv *bat_priv)
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
 
-		hlist_for_each_entry(bucket, walk, head, hlist) {
-			hna_local_entry = bucket->data;
+		hlist_for_each_entry(hna_local_entry, node, head, hash_entry) {
 			entry = (struct vis_info_entry *)
 					skb_put(info->skb_packet,
 						sizeof(*entry));
@@ -680,25 +702,22 @@ static void purge_vis_packets(struct bat_priv *bat_priv)
 {
 	int i;
 	struct hashtable_t *hash = bat_priv->vis_hash;
-	struct hlist_node *walk, *safe;
+	struct hlist_node *node, *node_tmp;
 	struct hlist_head *head;
-	struct element_t *bucket;
 	struct vis_info *info;
 
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
 
-		hlist_for_each_entry_safe(bucket, walk, safe, head, hlist) {
-			info = bucket->data;
-
+		hlist_for_each_entry_safe(info, node, node_tmp,
+					  head, hash_entry) {
 			/* never purge own data. */
 			if (info == bat_priv->my_vis_info)
 				continue;
 
 			if (time_after(jiffies,
 				       info->first_seen + VIS_TIMEOUT * HZ)) {
-				hlist_del(walk);
-				kfree(bucket);
+				hlist_del(node);
 				send_list_del(info);
 				kref_put(&info->refcount, free_info);
 			}
@@ -710,9 +729,8 @@ static void broadcast_vis_packet(struct bat_priv *bat_priv,
 				 struct vis_info *info)
 {
 	struct hashtable_t *hash = bat_priv->orig_hash;
-	struct hlist_node *walk;
+	struct hlist_node *node;
 	struct hlist_head *head;
-	struct element_t *bucket;
 	struct orig_node *orig_node;
 	struct vis_packet *packet;
 	struct sk_buff *skb;
@@ -729,9 +747,7 @@ static void broadcast_vis_packet(struct bat_priv *bat_priv,
 		head = &hash->table[i];
 
 		rcu_read_lock();
-		hlist_for_each_entry_rcu(bucket, walk, head, hlist) {
-			orig_node = bucket->data;
-
+		hlist_for_each_entry_rcu(orig_node, node, head, hash_entry) {
 			/* if it's a vis server and reachable, send it. */
 			if ((!orig_node) || (!orig_node->router))
 				continue;
@@ -774,14 +790,11 @@ static void unicast_vis_packet(struct bat_priv *bat_priv,
 
 	spin_lock_bh(&bat_priv->orig_hash_lock);
 	rcu_read_lock();
-	orig_node = ((struct orig_node *)hash_find(bat_priv->orig_hash,
-						   compare_orig, choose_orig,
-						   packet->target_orig));
+	orig_node = orig_hash_find(bat_priv, packet->target_orig);
 
 	if (!orig_node)
 		goto unlock;
 
-	kref_get(&orig_node->refcount);
 	neigh_node = orig_node->router;
 
 	if (!neigh_node)
@@ -925,7 +938,8 @@ int vis_init(struct bat_priv *bat_priv)
 	INIT_LIST_HEAD(&bat_priv->vis_send_list);
 
 	hash_added = hash_add(bat_priv->vis_hash, vis_info_cmp, vis_info_choose,
-			      bat_priv->my_vis_info);
+			      bat_priv->my_vis_info,
+			      &bat_priv->my_vis_info->hash_entry);
 	if (hash_added < 0) {
 		pr_err("Can't add own vis packet into hash\n");
 		/* not in hash, need to remove it manually. */
@@ -947,10 +961,11 @@ err:
 }
 
 /* Decrease the reference count on a hash item info */
-static void free_info_ref(void *data, void *arg)
+static void free_info_ref(struct hlist_node *node, void *arg)
 {
-	struct vis_info *info = data;
+	struct vis_info *info;
 
+	info = container_of(node, struct vis_info, hash_entry);
 	send_list_del(info);
 	kref_put(&info->refcount, free_info);
 }
-- 
1.7.2.3

