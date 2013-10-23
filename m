From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 02/16] batman-adv: make struct batadv_orig_node algorithm agnostic
Date: Wed, 23 Oct 2013 18:04:49 +0200
Message-ID: <1382544303-2694-3-git-send-email-antonio@meshcoding.com>
References: <1382544303-2694-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:21942 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752313Ab3JWQFt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 12:05:49 -0400
In-Reply-To: <1382544303-2694-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

some of the struct batadv_orig_node members are B.A.T.M.A.N. IV
specific and therefore they are moved in a algorithm specific
substruct in order to make batadv_orig_node routing algorithm
agnostic

Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/bat_iv_ogm.c | 108 +++++++++++++++++++++++++++++++++-----------
 net/batman-adv/originator.c |  89 ++++++++++++++----------------------
 net/batman-adv/originator.h |   3 +-
 net/batman-adv/types.h      |  30 +++++++-----
 4 files changed, 135 insertions(+), 95 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index a2a0498..0b1343d 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -87,6 +87,57 @@ static uint8_t batadv_ring_buffer_avg(const uint8_t lq_recv[])
 	return (uint8_t)(sum / count);
 }
 
+/**
+ * batadv_iv_ogm_orig_get - retrieve or create (if does not exist) an originator
+ * @bat_priv: the bat priv with all the soft interface information
+ * @addr: mac address of the originator
+ *
+ * Returns the originator object corresponding to the passed mac address or NULL
+ * on failure.
+ * If the object does not exists it is created an initialised.
+ */
+static struct batadv_orig_node *
+batadv_iv_ogm_orig_get(struct batadv_priv *bat_priv, const uint8_t *addr)
+{
+	struct batadv_orig_node *orig_node;
+	int size, hash_added;
+
+	orig_node = batadv_orig_hash_find(bat_priv, addr);
+	if (orig_node)
+		return orig_node;
+
+	orig_node = batadv_orig_node_new(bat_priv, addr);
+	if (!orig_node)
+		return NULL;
+
+	spin_lock_init(&orig_node->bat_iv.ogm_cnt_lock);
+
+	size = bat_priv->num_ifaces * sizeof(unsigned long) * BATADV_NUM_WORDS;
+	orig_node->bat_iv.bcast_own = kzalloc(size, GFP_ATOMIC);
+	if (!orig_node->bat_iv.bcast_own)
+		goto free_orig_node;
+
+	size = bat_priv->num_ifaces * sizeof(uint8_t);
+	orig_node->bat_iv.bcast_own_sum = kzalloc(size, GFP_ATOMIC);
+	if (!orig_node->bat_iv.bcast_own_sum)
+		goto free_bcast_own;
+
+	hash_added = batadv_hash_add(bat_priv->orig_hash, batadv_compare_orig,
+				     batadv_choose_orig, orig_node,
+				     &orig_node->hash_entry);
+	if (hash_added != 0)
+		goto free_bcast_own;
+
+	return orig_node;
+
+free_bcast_own:
+	kfree(orig_node->bat_iv.bcast_own);
+free_orig_node:
+	batadv_orig_node_free_ref(orig_node);
+
+	return NULL;
+}
+
 static struct batadv_neigh_node *
 batadv_iv_ogm_neigh_new(struct batadv_hard_iface *hard_iface,
 			const uint8_t *neigh_addr,
@@ -663,20 +714,22 @@ batadv_iv_ogm_slide_own_bcast_window(struct batadv_hard_iface *hard_iface)
 	uint32_t i;
 	size_t word_index;
 	uint8_t *w;
+	int if_num;
 
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
 
 		rcu_read_lock();
 		hlist_for_each_entry_rcu(orig_node, head, hash_entry) {
-			spin_lock_bh(&orig_node->ogm_cnt_lock);
+			spin_lock_bh(&orig_node->bat_iv.ogm_cnt_lock);
 			word_index = hard_iface->if_num * BATADV_NUM_WORDS;
-			word = &(orig_node->bcast_own[word_index]);
+			word = &(orig_node->bat_iv.bcast_own[word_index]);
 
 			batadv_bit_get_packet(bat_priv, word, 1, 0);
-			w = &orig_node->bcast_own_sum[hard_iface->if_num];
+			if_num = hard_iface->if_num;
+			w = &orig_node->bat_iv.bcast_own_sum[if_num];
 			*w = bitmap_weight(word, BATADV_TQ_LOCAL_WINDOW_SIZE);
-			spin_unlock_bh(&orig_node->ogm_cnt_lock);
+			spin_unlock_bh(&orig_node->bat_iv.ogm_cnt_lock);
 		}
 		rcu_read_unlock();
 	}
@@ -768,7 +821,7 @@ batadv_iv_ogm_orig_update(struct batadv_priv *bat_priv,
 	if (!neigh_node) {
 		struct batadv_orig_node *orig_tmp;
 
-		orig_tmp = batadv_get_orig_node(bat_priv, ethhdr->h_source);
+		orig_tmp = batadv_iv_ogm_orig_get(bat_priv, ethhdr->h_source);
 		if (!orig_tmp)
 			goto unlock;
 
@@ -818,16 +871,16 @@ batadv_iv_ogm_orig_update(struct batadv_priv *bat_priv,
 	 */
 	if (router && (neigh_node->bat_iv.tq_avg == router->bat_iv.tq_avg)) {
 		orig_node_tmp = router->orig_node;
-		spin_lock_bh(&orig_node_tmp->ogm_cnt_lock);
+		spin_lock_bh(&orig_node_tmp->bat_iv.ogm_cnt_lock);
 		if_num = router->if_incoming->if_num;
-		sum_orig = orig_node_tmp->bcast_own_sum[if_num];
-		spin_unlock_bh(&orig_node_tmp->ogm_cnt_lock);
+		sum_orig = orig_node_tmp->bat_iv.bcast_own_sum[if_num];
+		spin_unlock_bh(&orig_node_tmp->bat_iv.ogm_cnt_lock);
 
 		orig_node_tmp = neigh_node->orig_node;
-		spin_lock_bh(&orig_node_tmp->ogm_cnt_lock);
+		spin_lock_bh(&orig_node_tmp->bat_iv.ogm_cnt_lock);
 		if_num = neigh_node->if_incoming->if_num;
-		sum_neigh = orig_node_tmp->bcast_own_sum[if_num];
-		spin_unlock_bh(&orig_node_tmp->ogm_cnt_lock);
+		sum_neigh = orig_node_tmp->bat_iv.bcast_own_sum[if_num];
+		spin_unlock_bh(&orig_node_tmp->bat_iv.ogm_cnt_lock);
 
 		if (sum_orig >= sum_neigh)
 			goto out;
@@ -855,7 +908,7 @@ static int batadv_iv_ogm_calc_tq(struct batadv_orig_node *orig_node,
 	uint8_t total_count;
 	uint8_t orig_eq_count, neigh_rq_count, neigh_rq_inv, tq_own;
 	unsigned int neigh_rq_inv_cube, neigh_rq_max_cube;
-	int tq_asym_penalty, inv_asym_penalty, ret = 0;
+	int tq_asym_penalty, inv_asym_penalty, if_num, ret = 0;
 	unsigned int combined_tq;
 
 	/* find corresponding one hop neighbor */
@@ -893,10 +946,11 @@ static int batadv_iv_ogm_calc_tq(struct batadv_orig_node *orig_node,
 	orig_node->last_seen = jiffies;
 
 	/* find packet count of corresponding one hop neighbor */
-	spin_lock_bh(&orig_node->ogm_cnt_lock);
-	orig_eq_count = orig_neigh_node->bcast_own_sum[if_incoming->if_num];
+	spin_lock_bh(&orig_node->bat_iv.ogm_cnt_lock);
+	if_num = if_incoming->if_num;
+	orig_eq_count = orig_neigh_node->bat_iv.bcast_own_sum[if_num];
 	neigh_rq_count = neigh_node->bat_iv.real_packet_count;
-	spin_unlock_bh(&orig_node->ogm_cnt_lock);
+	spin_unlock_bh(&orig_node->bat_iv.ogm_cnt_lock);
 
 	/* pay attention to not get a value bigger than 100 % */
 	if (orig_eq_count > neigh_rq_count)
@@ -980,11 +1034,11 @@ batadv_iv_ogm_update_seqnos(const struct ethhdr *ethhdr,
 	uint8_t packet_count;
 	unsigned long *bitmap;
 
-	orig_node = batadv_get_orig_node(bat_priv, batadv_ogm_packet->orig);
+	orig_node = batadv_iv_ogm_orig_get(bat_priv, batadv_ogm_packet->orig);
 	if (!orig_node)
 		return BATADV_NO_DUP;
 
-	spin_lock_bh(&orig_node->ogm_cnt_lock);
+	spin_lock_bh(&orig_node->bat_iv.ogm_cnt_lock);
 	seq_diff = seqno - orig_node->last_real_seqno;
 
 	/* signalize caller that the packet is to be dropped. */
@@ -1033,7 +1087,7 @@ batadv_iv_ogm_update_seqnos(const struct ethhdr *ethhdr,
 	}
 
 out:
-	spin_unlock_bh(&orig_node->ogm_cnt_lock);
+	spin_unlock_bh(&orig_node->bat_iv.ogm_cnt_lock);
 	batadv_orig_node_free_ref(orig_node);
 	return ret;
 }
@@ -1129,8 +1183,8 @@ static void batadv_iv_ogm_process(const struct ethhdr *ethhdr,
 		int16_t if_num;
 		uint8_t *weight;
 
-		orig_neigh_node = batadv_get_orig_node(bat_priv,
-						       ethhdr->h_source);
+		orig_neigh_node = batadv_iv_ogm_orig_get(bat_priv,
+							 ethhdr->h_source);
 		if (!orig_neigh_node)
 			return;
 
@@ -1144,15 +1198,15 @@ static void batadv_iv_ogm_process(const struct ethhdr *ethhdr,
 			if_num = if_incoming->if_num;
 			offset = if_num * BATADV_NUM_WORDS;
 
-			spin_lock_bh(&orig_neigh_node->ogm_cnt_lock);
-			word = &(orig_neigh_node->bcast_own[offset]);
+			spin_lock_bh(&orig_neigh_node->bat_iv.ogm_cnt_lock);
+			word = &(orig_neigh_node->bat_iv.bcast_own[offset]);
 			bit_pos = if_incoming_seqno - 2;
 			bit_pos -= ntohl(batadv_ogm_packet->seqno);
 			batadv_set_bit(word, bit_pos);
-			weight = &orig_neigh_node->bcast_own_sum[if_num];
+			weight = &orig_neigh_node->bat_iv.bcast_own_sum[if_num];
 			*weight = bitmap_weight(word,
 						BATADV_TQ_LOCAL_WINDOW_SIZE);
-			spin_unlock_bh(&orig_neigh_node->ogm_cnt_lock);
+			spin_unlock_bh(&orig_neigh_node->bat_iv.ogm_cnt_lock);
 		}
 
 		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
@@ -1175,7 +1229,7 @@ static void batadv_iv_ogm_process(const struct ethhdr *ethhdr,
 		return;
 	}
 
-	orig_node = batadv_get_orig_node(bat_priv, batadv_ogm_packet->orig);
+	orig_node = batadv_iv_ogm_orig_get(bat_priv, batadv_ogm_packet->orig);
 	if (!orig_node)
 		return;
 
@@ -1225,8 +1279,8 @@ static void batadv_iv_ogm_process(const struct ethhdr *ethhdr,
 	if (is_single_hop_neigh)
 		orig_neigh_node = orig_node;
 	else
-		orig_neigh_node = batadv_get_orig_node(bat_priv,
-						       ethhdr->h_source);
+		orig_neigh_node = batadv_iv_ogm_orig_get(bat_priv,
+							 ethhdr->h_source);
 
 	if (!orig_neigh_node)
 		goto out;
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 50f6d99..aa14094 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -36,7 +36,7 @@ static struct lock_class_key batadv_orig_hash_lock_class_key;
 static void batadv_purge_orig(struct work_struct *work);
 
 /* returns 1 if they are the same originator */
-static int batadv_compare_orig(const struct hlist_node *node, const void *data2)
+int batadv_compare_orig(const struct hlist_node *node, const void *data2)
 {
 	const void *data1 = container_of(node, struct batadv_orig_node,
 					 hash_entry);
@@ -242,8 +242,8 @@ static void batadv_orig_node_free_rcu(struct rcu_head *rcu)
 				  "originator timed out");
 
 	kfree(orig_node->tt_buff);
-	kfree(orig_node->bcast_own);
-	kfree(orig_node->bcast_own_sum);
+	kfree(orig_node->bat_iv.bcast_own);
+	kfree(orig_node->bat_iv.bcast_own_sum);
 	kfree(orig_node);
 }
 
@@ -301,21 +301,22 @@ void batadv_originator_free(struct batadv_priv *bat_priv)
 	batadv_hash_destroy(hash);
 }
 
-/* this function finds or creates an originator entry for the given
- * address if it does not exits
+/**
+ * batadv_orig_node_new - creates a new orig_node
+ * @bat_priv: the bat priv with all the soft interface information
+ * @addr: the mac address of the originator
+ *
+ * Creates a new originator object and initialise all the generic fields.
+ * The new object is not added to the originator list.
+ * Returns the newly created object or NULL on failure.
  */
-struct batadv_orig_node *batadv_get_orig_node(struct batadv_priv *bat_priv,
+struct batadv_orig_node *batadv_orig_node_new(struct batadv_priv *bat_priv,
 					      const uint8_t *addr)
 {
 	struct batadv_orig_node *orig_node;
 	struct batadv_orig_node_vlan *vlan;
-	int size, i;
-	int hash_added;
 	unsigned long reset_time;
-
-	orig_node = batadv_orig_hash_find(bat_priv, addr);
-	if (orig_node)
-		return orig_node;
+	int i;
 
 	batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 		   "Creating new originator: %pM\n", addr);
@@ -327,7 +328,6 @@ struct batadv_orig_node *batadv_get_orig_node(struct batadv_priv *bat_priv,
 	INIT_HLIST_HEAD(&orig_node->neigh_list);
 	INIT_LIST_HEAD(&orig_node->bond_list);
 	INIT_LIST_HEAD(&orig_node->vlan_list);
-	spin_lock_init(&orig_node->ogm_cnt_lock);
 	spin_lock_init(&orig_node->bcast_seqno_lock);
 	spin_lock_init(&orig_node->neigh_list_lock);
 	spin_lock_init(&orig_node->tt_buff_lock);
@@ -363,37 +363,13 @@ struct batadv_orig_node *batadv_get_orig_node(struct batadv_priv *bat_priv,
 	 */
 	batadv_orig_node_vlan_free_ref(vlan);
 
-	size = bat_priv->num_ifaces * sizeof(unsigned long) * BATADV_NUM_WORDS;
-
-	orig_node->bcast_own = kzalloc(size, GFP_ATOMIC);
-	if (!orig_node->bcast_own)
-		goto free_vlan;
-
-	size = bat_priv->num_ifaces * sizeof(uint8_t);
-	orig_node->bcast_own_sum = kzalloc(size, GFP_ATOMIC);
-
 	for (i = 0; i < BATADV_FRAG_BUFFER_COUNT; i++) {
 		INIT_HLIST_HEAD(&orig_node->fragments[i].head);
 		spin_lock_init(&orig_node->fragments[i].lock);
 		orig_node->fragments[i].size = 0;
 	}
 
-	if (!orig_node->bcast_own_sum)
-		goto free_bcast_own;
-
-	hash_added = batadv_hash_add(bat_priv->orig_hash, batadv_compare_orig,
-				     batadv_choose_orig, orig_node,
-				     &orig_node->hash_entry);
-	if (hash_added != 0)
-		goto free_bcast_own_sum;
-
 	return orig_node;
-free_bcast_own_sum:
-	kfree(orig_node->bcast_own_sum);
-free_bcast_own:
-	kfree(orig_node->bcast_own);
-free_vlan:
-	batadv_orig_node_vlan_free_ref(vlan);
 free_orig_node:
 	kfree(orig_node);
 	return NULL;
@@ -619,18 +595,18 @@ static int batadv_orig_node_add_if(struct batadv_orig_node *orig_node,
 	if (!data_ptr)
 		return -ENOMEM;
 
-	memcpy(data_ptr, orig_node->bcast_own, old_size);
-	kfree(orig_node->bcast_own);
-	orig_node->bcast_own = data_ptr;
+	memcpy(data_ptr, orig_node->bat_iv.bcast_own, old_size);
+	kfree(orig_node->bat_iv.bcast_own);
+	orig_node->bat_iv.bcast_own = data_ptr;
 
 	data_ptr = kmalloc(max_if_num * sizeof(uint8_t), GFP_ATOMIC);
 	if (!data_ptr)
 		return -ENOMEM;
 
-	memcpy(data_ptr, orig_node->bcast_own_sum,
+	memcpy(data_ptr, orig_node->bat_iv.bcast_own_sum,
 	       (max_if_num - 1) * sizeof(uint8_t));
-	kfree(orig_node->bcast_own_sum);
-	orig_node->bcast_own_sum = data_ptr;
+	kfree(orig_node->bat_iv.bcast_own_sum);
+	orig_node->bat_iv.bcast_own_sum = data_ptr;
 
 	return 0;
 }
@@ -653,9 +629,9 @@ int batadv_orig_hash_add_if(struct batadv_hard_iface *hard_iface,
 
 		rcu_read_lock();
 		hlist_for_each_entry_rcu(orig_node, head, hash_entry) {
-			spin_lock_bh(&orig_node->ogm_cnt_lock);
+			spin_lock_bh(&orig_node->bat_iv.ogm_cnt_lock);
 			ret = batadv_orig_node_add_if(orig_node, max_if_num);
-			spin_unlock_bh(&orig_node->ogm_cnt_lock);
+			spin_unlock_bh(&orig_node->bat_iv.ogm_cnt_lock);
 
 			if (ret == -ENOMEM)
 				goto err;
@@ -673,8 +649,8 @@ err:
 static int batadv_orig_node_del_if(struct batadv_orig_node *orig_node,
 				   int max_if_num, int del_if_num)
 {
+	int chunk_size, if_offset;
 	void *data_ptr = NULL;
-	int chunk_size;
 
 	/* last interface was removed */
 	if (max_if_num == 0)
@@ -686,16 +662,16 @@ static int batadv_orig_node_del_if(struct batadv_orig_node *orig_node,
 		return -ENOMEM;
 
 	/* copy first part */
-	memcpy(data_ptr, orig_node->bcast_own, del_if_num * chunk_size);
+	memcpy(data_ptr, orig_node->bat_iv.bcast_own, del_if_num * chunk_size);
 
 	/* copy second part */
 	memcpy((char *)data_ptr + del_if_num * chunk_size,
-	       orig_node->bcast_own + ((del_if_num + 1) * chunk_size),
+	       orig_node->bat_iv.bcast_own + ((del_if_num + 1) * chunk_size),
 	       (max_if_num - del_if_num) * chunk_size);
 
 free_bcast_own:
-	kfree(orig_node->bcast_own);
-	orig_node->bcast_own = data_ptr;
+	kfree(orig_node->bat_iv.bcast_own);
+	orig_node->bat_iv.bcast_own = data_ptr;
 
 	if (max_if_num == 0)
 		goto free_own_sum;
@@ -704,16 +680,17 @@ free_bcast_own:
 	if (!data_ptr)
 		return -ENOMEM;
 
-	memcpy(data_ptr, orig_node->bcast_own_sum,
+	memcpy(data_ptr, orig_node->bat_iv.bcast_own_sum,
 	       del_if_num * sizeof(uint8_t));
 
+	if_offset = (del_if_num + 1) * sizeof(uint8_t);
 	memcpy((char *)data_ptr + del_if_num * sizeof(uint8_t),
-	       orig_node->bcast_own_sum + ((del_if_num + 1) * sizeof(uint8_t)),
+	       orig_node->bat_iv.bcast_own_sum + if_offset,
 	       (max_if_num - del_if_num) * sizeof(uint8_t));
 
 free_own_sum:
-	kfree(orig_node->bcast_own_sum);
-	orig_node->bcast_own_sum = data_ptr;
+	kfree(orig_node->bat_iv.bcast_own_sum);
+	orig_node->bat_iv.bcast_own_sum = data_ptr;
 
 	return 0;
 }
@@ -737,10 +714,10 @@ int batadv_orig_hash_del_if(struct batadv_hard_iface *hard_iface,
 
 		rcu_read_lock();
 		hlist_for_each_entry_rcu(orig_node, head, hash_entry) {
-			spin_lock_bh(&orig_node->ogm_cnt_lock);
+			spin_lock_bh(&orig_node->bat_iv.ogm_cnt_lock);
 			ret = batadv_orig_node_del_if(orig_node, max_if_num,
 						      hard_iface->if_num);
-			spin_unlock_bh(&orig_node->ogm_cnt_lock);
+			spin_unlock_bh(&orig_node->bat_iv.ogm_cnt_lock);
 
 			if (ret == -ENOMEM)
 				goto err;
diff --git a/net/batman-adv/originator.h b/net/batman-adv/originator.h
index 06e5a68..6f77d80 100644
--- a/net/batman-adv/originator.h
+++ b/net/batman-adv/originator.h
@@ -22,12 +22,13 @@
 
 #include "hash.h"
 
+int batadv_compare_orig(const struct hlist_node *node, const void *data2);
 int batadv_originator_init(struct batadv_priv *bat_priv);
 void batadv_originator_free(struct batadv_priv *bat_priv);
 void batadv_purge_orig_ref(struct batadv_priv *bat_priv);
 void batadv_orig_node_free_ref(struct batadv_orig_node *orig_node);
 void batadv_orig_node_free_ref_now(struct batadv_orig_node *orig_node);
-struct batadv_orig_node *batadv_get_orig_node(struct batadv_priv *bat_priv,
+struct batadv_orig_node *batadv_orig_node_new(struct batadv_priv *bat_priv,
 					      const uint8_t *addr);
 struct batadv_neigh_node *
 batadv_neigh_node_new(struct batadv_hard_iface *hard_iface,
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index a321334..97bde51 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -133,14 +133,28 @@ struct batadv_orig_node_vlan {
 };
 
 /**
+ * struct batadv_orig_bat_iv - B.A.T.M.A.N. IV private orig_node members
+ * @bcast_own: bitfield containing the number of our OGMs this orig_node
+ *  rebroadcasted "back" to us (relative to last_real_seqno)
+ * @bcast_own_sum: counted result of bcast_own
+ * @ogm_cnt_lock: lock protecting bcast_own, bcast_own_sum,
+ *  neigh_node->bat_iv.real_bits & neigh_node->bat_iv.real_packet_count
+ */
+struct batadv_orig_bat_iv {
+	unsigned long *bcast_own;
+	uint8_t *bcast_own_sum;
+	/* ogm_cnt_lock protects: bcast_own, bcast_own_sum,
+	 * neigh_node->bat_iv.real_bits & neigh_node->bat_iv.real_packet_count
+	 */
+	spinlock_t ogm_cnt_lock;
+};
+
+/**
  * struct batadv_orig_node - structure for orig_list maintaining nodes of mesh
  * @orig: originator ethernet address
  * @primary_addr: hosts primary interface address
  * @router: router that should be used to reach this originator
  * @batadv_dat_addr_t:  address of the orig node in the distributed hash
- * @bcast_own: bitfield containing the number of our OGMs this orig_node
- *  rebroadcasted "back" to us (relative to last_real_seqno)
- * @bcast_own_sum: counted result of bcast_own
  * @last_seen: time when last packet from this node was received
  * @bcast_seqno_reset: time when the broadcast seqno window was reset
  * @batman_seqno_reset: time when the batman seqno window was reset
@@ -166,8 +180,6 @@ struct batadv_orig_node_vlan {
  * @neigh_list_lock: lock protecting neigh_list, router and bonding_list
  * @hash_entry: hlist node for batadv_priv::orig_hash
  * @bat_priv: pointer to soft_iface this orig node belongs to
- * @ogm_cnt_lock: lock protecting bcast_own, bcast_own_sum,
- *  neigh_node->real_bits & neigh_node->real_packet_count
  * @bcast_seqno_lock: lock protecting bcast_bits & last_bcast_seqno
  * @bond_candidates: how many candidates are available
  * @bond_list: list of bonding candidates
@@ -181,6 +193,7 @@ struct batadv_orig_node_vlan {
  * @vlan_list: a list of orig_node_vlan structs, one per VLAN served by the
  *  originator represented by this object
  * @vlan_list_lock: lock protecting vlan_list
+ * @bat_iv: B.A.T.M.A.N. IV private structure
  */
 struct batadv_orig_node {
 	uint8_t orig[ETH_ALEN];
@@ -189,8 +202,6 @@ struct batadv_orig_node {
 #ifdef CONFIG_BATMAN_ADV_DAT
 	batadv_dat_addr_t dat_addr;
 #endif
-	unsigned long *bcast_own;
-	uint8_t *bcast_own_sum;
 	unsigned long last_seen;
 	unsigned long bcast_seqno_reset;
 	unsigned long batman_seqno_reset;
@@ -211,10 +222,6 @@ struct batadv_orig_node {
 	spinlock_t neigh_list_lock;
 	struct hlist_node hash_entry;
 	struct batadv_priv *bat_priv;
-	/* ogm_cnt_lock protects: bcast_own, bcast_own_sum,
-	 * neigh_node->real_bits & neigh_node->real_packet_count
-	 */
-	spinlock_t ogm_cnt_lock;
 	/* bcast_seqno_lock protects: bcast_bits & last_bcast_seqno */
 	spinlock_t bcast_seqno_lock;
 	atomic_t bond_candidates;
@@ -230,6 +237,7 @@ struct batadv_orig_node {
 	struct batadv_frag_table_entry fragments[BATADV_FRAG_BUFFER_COUNT];
 	struct list_head vlan_list;
 	spinlock_t vlan_list_lock; /* protects vlan_list */
+	struct batadv_orig_bat_iv bat_iv;
 };
 
 /**
-- 
1.8.4
