From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH 08/28] batman-adv: protect originator nodes with reference counters
Date: Sat,  5 Mar 2011 13:28:22 +0100
Message-ID: <1299328122-21468-9-git-send-email-sven@narfation.org>
References: <1299328122-21468-1-git-send-email-sven@narfation.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:36279 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753242Ab1CEM3k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Mar 2011 07:29:40 -0500
In-Reply-To: <1299328122-21468-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/originator.c |   61 ++++++++++++++++++++++++++++++++++++------
 net/batman-adv/originator.h |    1 +
 net/batman-adv/routing.c    |   33 ++++++++++++++++-------
 net/batman-adv/types.h      |    2 +
 4 files changed, 78 insertions(+), 19 deletions(-)

diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 5c32314..fcdb0b7 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -103,12 +103,13 @@ struct neigh_node *create_neighbor(struct orig_node *orig_node,
 	return neigh_node;
 }
 
-static void free_orig_node(void *data, void *arg)
+void orig_node_free_ref(struct kref *refcount)
 {
 	struct hlist_node *node, *node_tmp;
 	struct neigh_node *neigh_node;
-	struct orig_node *orig_node = (struct orig_node *)data;
-	struct bat_priv *bat_priv = (struct bat_priv *)arg;
+	struct orig_node *orig_node;
+
+	orig_node = container_of(refcount, struct orig_node, refcount);
 
 	spin_lock_bh(&orig_node->neigh_list_lock);
 
@@ -122,7 +123,8 @@ static void free_orig_node(void *data, void *arg)
 	spin_unlock_bh(&orig_node->neigh_list_lock);
 
 	frag_list_free(&orig_node->frag_list);
-	hna_global_del_orig(bat_priv, orig_node, "originator timed out");
+	hna_global_del_orig(orig_node->bat_priv, orig_node,
+			    "originator timed out");
 
 	kfree(orig_node->bcast_own);
 	kfree(orig_node->bcast_own_sum);
@@ -131,17 +133,53 @@ static void free_orig_node(void *data, void *arg)
 
 void originator_free(struct bat_priv *bat_priv)
 {
-	if (!bat_priv->orig_hash)
+	struct hashtable_t *hash = bat_priv->orig_hash;
+	struct hlist_node *walk, *safe;
+	struct hlist_head *head;
+	struct element_t *bucket;
+	spinlock_t *list_lock; /* spinlock to protect write access */
+	struct orig_node *orig_node;
+	int i;
+
+	if (!hash)
 		return;
 
 	cancel_delayed_work_sync(&bat_priv->orig_work);
 
 	spin_lock_bh(&bat_priv->orig_hash_lock);
-	hash_delete(bat_priv->orig_hash, free_orig_node, bat_priv);
 	bat_priv->orig_hash = NULL;
+
+	for (i = 0; i < hash->size; i++) {
+		head = &hash->table[i];
+		list_lock = &hash->list_locks[i];
+
+		spin_lock_bh(list_lock);
+		hlist_for_each_entry_safe(bucket, walk, safe, head, hlist) {
+			orig_node = bucket->data;
+
+			hlist_del_rcu(walk);
+			call_rcu(&bucket->rcu, bucket_free_rcu);
+			kref_put(&orig_node->refcount, orig_node_free_ref);
+		}
+		spin_unlock_bh(list_lock);
+	}
+
+	hash_destroy(hash);
 	spin_unlock_bh(&bat_priv->orig_hash_lock);
 }
 
+static void bucket_free_orig_rcu(struct rcu_head *rcu)
+{
+	struct element_t *bucket;
+	struct orig_node *orig_node;
+
+	bucket = container_of(rcu, struct element_t, rcu);
+	orig_node = bucket->data;
+
+	kref_put(&orig_node->refcount, orig_node_free_ref);
+	kfree(bucket);
+}
+
 /* this function finds or creates an originator entry for the given
  * address if it does not exits */
 struct orig_node *get_orig_node(struct bat_priv *bat_priv, uint8_t *addr)
@@ -156,8 +194,10 @@ struct orig_node *get_orig_node(struct bat_priv *bat_priv, uint8_t *addr)
 						   addr));
 	rcu_read_unlock();
 
-	if (orig_node)
+	if (orig_node) {
+		kref_get(&orig_node->refcount);
 		return orig_node;
+	}
 
 	bat_dbg(DBG_BATMAN, bat_priv,
 		"Creating new originator: %pM\n", addr);
@@ -168,7 +208,9 @@ struct orig_node *get_orig_node(struct bat_priv *bat_priv, uint8_t *addr)
 
 	INIT_HLIST_HEAD(&orig_node->neigh_list);
 	spin_lock_init(&orig_node->neigh_list_lock);
+	kref_init(&orig_node->refcount);
 
+	orig_node->bat_priv = bat_priv;
 	memcpy(orig_node->orig, addr, ETH_ALEN);
 	orig_node->router = NULL;
 	orig_node->hna_buff = NULL;
@@ -197,6 +239,8 @@ struct orig_node *get_orig_node(struct bat_priv *bat_priv, uint8_t *addr)
 	if (hash_added < 0)
 		goto free_bcast_own_sum;
 
+	/* extra reference for return */
+	kref_get(&orig_node->refcount);
 	return orig_node;
 free_bcast_own_sum:
 	kfree(orig_node->bcast_own_sum);
@@ -318,8 +362,7 @@ static void _purge_orig(struct bat_priv *bat_priv)
 				if (orig_node->gw_flags)
 					gw_node_delete(bat_priv, orig_node);
 				hlist_del_rcu(walk);
-				call_rcu(&bucket->rcu, bucket_free_rcu);
-				free_orig_node(orig_node, bat_priv);
+				call_rcu(&bucket->rcu, bucket_free_orig_rcu);
 				continue;
 			}
 
diff --git a/net/batman-adv/originator.h b/net/batman-adv/originator.h
index 88e5c60..edc64dc 100644
--- a/net/batman-adv/originator.h
+++ b/net/batman-adv/originator.h
@@ -25,6 +25,7 @@
 int originator_init(struct bat_priv *bat_priv);
 void originator_free(struct bat_priv *bat_priv);
 void purge_orig_ref(struct bat_priv *bat_priv);
+void orig_node_free_ref(struct kref *refcount);
 struct orig_node *get_orig_node(struct bat_priv *bat_priv, uint8_t *addr);
 struct neigh_node *create_neighbor(struct orig_node *orig_node,
 				   struct orig_node *orig_neigh_node,
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 32ae04e..1c31a0e 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -311,6 +311,8 @@ static void update_orig(struct bat_priv *bat_priv,
 
 		neigh_node = create_neighbor(orig_node, orig_tmp,
 					     ethhdr->h_source, if_incoming);
+
+		kref_put(&orig_tmp->refcount, orig_node_free_ref);
 		if (!neigh_node)
 			goto unlock;
 	} else
@@ -438,7 +440,7 @@ static char count_real_packets(struct ethhdr *ethhdr,
 	/* signalize caller that the packet is to be dropped. */
 	if (window_protected(bat_priv, seq_diff,
 			     &orig_node->batman_seqno_reset))
-		return -1;
+		goto err;
 
 	rcu_read_lock();
 	hlist_for_each_entry_rcu(tmp_neigh_node, node,
@@ -471,7 +473,12 @@ static char count_real_packets(struct ethhdr *ethhdr,
 		orig_node->last_real_seqno = batman_packet->seqno;
 	}
 
+	kref_put(&orig_node->refcount, orig_node_free_ref);
 	return is_duplicate;
+
+err:
+	kref_put(&orig_node->refcount, orig_node_free_ref);
+	return -1;
 }
 
 /* copy primary address for bonding */
@@ -686,7 +693,6 @@ void receive_bat_packet(struct ethhdr *ethhdr,
 		int offset;
 
 		orig_neigh_node = get_orig_node(bat_priv, ethhdr->h_source);
-
 		if (!orig_neigh_node)
 			return;
 
@@ -707,6 +713,7 @@ void receive_bat_packet(struct ethhdr *ethhdr,
 
 		bat_dbg(DBG_BATMAN, bat_priv, "Drop packet: "
 			"originator packet from myself (via neighbor)\n");
+		kref_put(&orig_neigh_node->refcount, orig_node_free_ref);
 		return;
 	}
 
@@ -727,13 +734,13 @@ void receive_bat_packet(struct ethhdr *ethhdr,
 		bat_dbg(DBG_BATMAN, bat_priv,
 			"Drop packet: packet within seqno protection time "
 			"(sender: %pM)\n", ethhdr->h_source);
-		return;
+		goto out;
 	}
 
 	if (batman_packet->tq == 0) {
 		bat_dbg(DBG_BATMAN, bat_priv,
 			"Drop packet: originator packet with tq equal 0\n");
-		return;
+		goto out;
 	}
 
 	/* avoid temporary routing loops */
@@ -747,7 +754,7 @@ void receive_bat_packet(struct ethhdr *ethhdr,
 		bat_dbg(DBG_BATMAN, bat_priv,
 			"Drop packet: ignoring all rebroadcast packets that "
 			"may make me loop (sender: %pM)\n", ethhdr->h_source);
-		return;
+		goto out;
 	}
 
 	/* if sender is a direct neighbor the sender mac equals
@@ -756,14 +763,14 @@ void receive_bat_packet(struct ethhdr *ethhdr,
 			   orig_node :
 			   get_orig_node(bat_priv, ethhdr->h_source));
 	if (!orig_neigh_node)
-		return;
+		goto out_neigh;
 
 	/* drop packet if sender is not a direct neighbor and if we
 	 * don't route towards it */
 	if (!is_single_hop_neigh && (!orig_neigh_node->router)) {
 		bat_dbg(DBG_BATMAN, bat_priv,
 			"Drop packet: OGM via unknown neighbor!\n");
-		return;
+		goto out_neigh;
 	}
 
 	is_bidirectional = is_bidirectional_neigh(orig_node, orig_neigh_node,
@@ -790,26 +797,32 @@ void receive_bat_packet(struct ethhdr *ethhdr,
 
 		bat_dbg(DBG_BATMAN, bat_priv, "Forwarding packet: "
 			"rebroadcast neighbor packet with direct link flag\n");
-		return;
+		goto out_neigh;
 	}
 
 	/* multihop originator */
 	if (!is_bidirectional) {
 		bat_dbg(DBG_BATMAN, bat_priv,
 			"Drop packet: not received via bidirectional link\n");
-		return;
+		goto out_neigh;
 	}
 
 	if (is_duplicate) {
 		bat_dbg(DBG_BATMAN, bat_priv,
 			"Drop packet: duplicate packet received\n");
-		return;
+		goto out_neigh;
 	}
 
 	bat_dbg(DBG_BATMAN, bat_priv,
 		"Forwarding packet: rebroadcast originator packet\n");
 	schedule_forward_packet(orig_node, ethhdr, batman_packet,
 				0, hna_buff_len, if_incoming);
+
+out_neigh:
+	if (!is_single_hop_neigh)
+		kref_put(&orig_neigh_node->refcount, orig_node_free_ref);
+out:
+	kref_put(&orig_node->refcount, orig_node_free_ref);
 }
 
 int recv_bat_packet(struct sk_buff *skb, struct batman_if *batman_if)
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index d4fa727..ca4d42d 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -86,6 +86,8 @@ struct orig_node {
 	struct hlist_head neigh_list;
 	struct list_head frag_list;
 	spinlock_t neigh_list_lock; /* protects neighbor list */
+	struct kref refcount;
+	struct bat_priv *bat_priv;
 	unsigned long last_frag_packet;
 	struct {
 		uint8_t candidates;
-- 
1.7.2.3

