From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH 22/28] batman-adv: Correct rcu refcounting for orig_node
Date: Sat,  5 Mar 2011 13:28:36 +0100
Message-ID: <1299328122-21468-23-git-send-email-sven@narfation.org>
References: <1299328122-21468-1-git-send-email-sven@narfation.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:36341 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753357Ab1CEMaN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Mar 2011 07:30:13 -0500
In-Reply-To: <1299328122-21468-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

It might be possible that 2 threads access the same data in the same
rcu grace period. The first thread calls call_rcu() to decrement the
refcount and free the data while the second thread increases the
refcount to use the data. To avoid this race condition all refcount
operations have to be atomic.

Reported-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/gateway_client.c    |    6 ++++--
 net/batman-adv/icmp_socket.c       |    2 +-
 net/batman-adv/originator.c        |   21 +++++++++++++--------
 net/batman-adv/originator.h        |    6 ++++--
 net/batman-adv/routing.c           |   24 ++++++++++++------------
 net/batman-adv/translation-table.c |   15 +++++++++------
 net/batman-adv/types.h             |    3 ++-
 net/batman-adv/unicast.c           |    6 +++---
 net/batman-adv/vis.c               |    2 +-
 9 files changed, 49 insertions(+), 36 deletions(-)

diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 41eba8a..3cc4355 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -53,9 +53,11 @@ void *gw_get_selected(struct bat_priv *bat_priv)
 		goto out;
 
 	orig_node = curr_gateway_tmp->orig_node;
+	if (!orig_node)
+		goto out;
 
-	if (orig_node)
-		kref_get(&orig_node->refcount);
+	if (!atomic_inc_not_zero(&orig_node->refcount))
+		orig_node = NULL;
 
 out:
 	rcu_read_unlock();
diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.c
index 139b733..a0a35b1 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -271,7 +271,7 @@ out:
 	if (neigh_node)
 		neigh_node_free_ref(neigh_node);
 	if (orig_node)
-		kref_put(&orig_node->refcount, orig_node_free_ref);
+		orig_node_free_ref(orig_node);
 	return len;
 }
 
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index bdcb399..a70debe 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -102,13 +102,13 @@ struct neigh_node *create_neighbor(struct orig_node *orig_node,
 	return neigh_node;
 }
 
-void orig_node_free_ref(struct kref *refcount)
+static void orig_node_free_rcu(struct rcu_head *rcu)
 {
 	struct hlist_node *node, *node_tmp;
 	struct neigh_node *neigh_node, *tmp_neigh_node;
 	struct orig_node *orig_node;
 
-	orig_node = container_of(refcount, struct orig_node, refcount);
+	orig_node = container_of(rcu, struct orig_node, rcu);
 
 	spin_lock_bh(&orig_node->neigh_list_lock);
 
@@ -137,6 +137,12 @@ void orig_node_free_ref(struct kref *refcount)
 	kfree(orig_node);
 }
 
+void orig_node_free_ref(struct orig_node *orig_node)
+{
+	if (atomic_dec_and_test(&orig_node->refcount))
+		call_rcu(&orig_node->rcu, orig_node_free_rcu);
+}
+
 void originator_free(struct bat_priv *bat_priv)
 {
 	struct hashtable_t *hash = bat_priv->orig_hash;
@@ -163,7 +169,7 @@ void originator_free(struct bat_priv *bat_priv)
 					  head, hash_entry) {
 
 			hlist_del_rcu(node);
-			kref_put(&orig_node->refcount, orig_node_free_ref);
+			orig_node_free_ref(orig_node);
 		}
 		spin_unlock_bh(list_lock);
 	}
@@ -196,7 +202,9 @@ struct orig_node *get_orig_node(struct bat_priv *bat_priv, uint8_t *addr)
 	spin_lock_init(&orig_node->ogm_cnt_lock);
 	spin_lock_init(&orig_node->bcast_seqno_lock);
 	spin_lock_init(&orig_node->neigh_list_lock);
-	kref_init(&orig_node->refcount);
+
+	/* extra reference for return */
+	atomic_set(&orig_node->refcount, 2);
 
 	orig_node->bat_priv = bat_priv;
 	memcpy(orig_node->orig, addr, ETH_ALEN);
@@ -229,8 +237,6 @@ struct orig_node *get_orig_node(struct bat_priv *bat_priv, uint8_t *addr)
 	if (hash_added < 0)
 		goto free_bcast_own_sum;
 
-	/* extra reference for return */
-	kref_get(&orig_node->refcount);
 	return orig_node;
 free_bcast_own_sum:
 	kfree(orig_node->bcast_own_sum);
@@ -348,8 +354,7 @@ static void _purge_orig(struct bat_priv *bat_priv)
 				if (orig_node->gw_flags)
 					gw_node_delete(bat_priv, orig_node);
 				hlist_del_rcu(node);
-				kref_put(&orig_node->refcount,
-					 orig_node_free_ref);
+				orig_node_free_ref(orig_node);
 				continue;
 			}
 
diff --git a/net/batman-adv/originator.h b/net/batman-adv/originator.h
index b4b9a09..3d7a39d 100644
--- a/net/batman-adv/originator.h
+++ b/net/batman-adv/originator.h
@@ -27,7 +27,7 @@
 int originator_init(struct bat_priv *bat_priv);
 void originator_free(struct bat_priv *bat_priv);
 void purge_orig_ref(struct bat_priv *bat_priv);
-void orig_node_free_ref(struct kref *refcount);
+void orig_node_free_ref(struct orig_node *orig_node);
 struct orig_node *get_orig_node(struct bat_priv *bat_priv, uint8_t *addr);
 struct neigh_node *create_neighbor(struct orig_node *orig_node,
 				   struct orig_node *orig_neigh_node,
@@ -88,8 +88,10 @@ static inline struct orig_node *orig_hash_find(struct bat_priv *bat_priv,
 		if (!compare_eth(orig_node, data))
 			continue;
 
+		if (!atomic_inc_not_zero(&orig_node->refcount))
+			continue;
+
 		orig_node_tmp = orig_node;
-		kref_get(&orig_node_tmp->refcount);
 		break;
 	}
 	rcu_read_unlock();
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index fc4c12a..9863c03 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -420,7 +420,7 @@ static void update_orig(struct bat_priv *bat_priv,
 		neigh_node = create_neighbor(orig_node, orig_tmp,
 					     ethhdr->h_source, if_incoming);
 
-		kref_put(&orig_tmp->refcount, orig_node_free_ref);
+		orig_node_free_ref(orig_tmp);
 		if (!neigh_node)
 			goto unlock;
 
@@ -604,7 +604,7 @@ static char count_real_packets(struct ethhdr *ethhdr,
 
 out:
 	spin_unlock_bh(&orig_node->ogm_cnt_lock);
-	kref_put(&orig_node->refcount, orig_node_free_ref);
+	orig_node_free_ref(orig_node);
 	return ret;
 }
 
@@ -730,7 +730,7 @@ void receive_bat_packet(struct ethhdr *ethhdr,
 
 		bat_dbg(DBG_BATMAN, bat_priv, "Drop packet: "
 			"originator packet from myself (via neighbor)\n");
-		kref_put(&orig_neigh_node->refcount, orig_node_free_ref);
+		orig_node_free_ref(orig_neigh_node);
 		return;
 	}
 
@@ -835,10 +835,10 @@ void receive_bat_packet(struct ethhdr *ethhdr,
 				0, hna_buff_len, if_incoming);
 
 out_neigh:
-	if (!is_single_hop_neigh)
-		kref_put(&orig_neigh_node->refcount, orig_node_free_ref);
+	if ((orig_neigh_node) && (!is_single_hop_neigh))
+		orig_node_free_ref(orig_neigh_node);
 out:
-	kref_put(&orig_node->refcount, orig_node_free_ref);
+	orig_node_free_ref(orig_node);
 }
 
 int recv_bat_packet(struct sk_buff *skb, struct batman_if *batman_if)
@@ -952,7 +952,7 @@ out:
 	if (neigh_node)
 		neigh_node_free_ref(neigh_node);
 	if (orig_node)
-		kref_put(&orig_node->refcount, orig_node_free_ref);
+		orig_node_free_ref(orig_node);
 	return ret;
 }
 
@@ -1028,7 +1028,7 @@ out:
 	if (neigh_node)
 		neigh_node_free_ref(neigh_node);
 	if (orig_node)
-		kref_put(&orig_node->refcount, orig_node_free_ref);
+		orig_node_free_ref(orig_node);
 	return ret;
 }
 
@@ -1134,7 +1134,7 @@ out:
 	if (neigh_node)
 		neigh_node_free_ref(neigh_node);
 	if (orig_node)
-		kref_put(&orig_node->refcount, orig_node_free_ref);
+		orig_node_free_ref(orig_node);
 	return ret;
 }
 
@@ -1189,7 +1189,7 @@ struct neigh_node *find_router(struct bat_priv *bat_priv,
 		if (!primary_orig_node)
 			goto return_router;
 
-		kref_put(&primary_orig_node->refcount, orig_node_free_ref);
+		orig_node_free_ref(primary_orig_node);
 	}
 
 	/* with less than 2 candidates, we can't do any
@@ -1401,7 +1401,7 @@ out:
 	if (neigh_node)
 		neigh_node_free_ref(neigh_node);
 	if (orig_node)
-		kref_put(&orig_node->refcount, orig_node_free_ref);
+		orig_node_free_ref(orig_node);
 	return ret;
 }
 
@@ -1543,7 +1543,7 @@ spin_unlock:
 	spin_unlock_bh(&bat_priv->orig_hash_lock);
 out:
 	if (orig_node)
-		kref_put(&orig_node->refcount, orig_node_free_ref);
+		orig_node_free_ref(orig_node);
 	return ret;
 }
 
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index cd8a583..8d15b48 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -589,17 +589,20 @@ void hna_global_free(struct bat_priv *bat_priv)
 struct orig_node *transtable_search(struct bat_priv *bat_priv, uint8_t *addr)
 {
 	struct hna_global_entry *hna_global_entry;
+	struct orig_node *orig_node = NULL;
 
 	spin_lock_bh(&bat_priv->hna_ghash_lock);
 	hna_global_entry = hna_global_hash_find(bat_priv, addr);
 
-	if (hna_global_entry)
-		kref_get(&hna_global_entry->orig_node->refcount);
+	if (!hna_global_entry)
+		goto out;
 
-	spin_unlock_bh(&bat_priv->hna_ghash_lock);
+	if (!atomic_inc_not_zero(&hna_global_entry->orig_node->refcount))
+		goto out;
 
-	if (!hna_global_entry)
-		return NULL;
+	orig_node = hna_global_entry->orig_node;
 
-	return hna_global_entry->orig_node;
+out:
+	spin_unlock_bh(&bat_priv->hna_ghash_lock);
+	return orig_node;
 }
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 40365b8..1be76fe 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -84,7 +84,8 @@ struct orig_node {
 	struct hlist_head neigh_list;
 	struct list_head frag_list;
 	spinlock_t neigh_list_lock; /* protects neighbor list */
-	struct kref refcount;
+	atomic_t refcount;
+	struct rcu_head rcu;
 	struct hlist_node hash_entry;
 	struct bat_priv *bat_priv;
 	unsigned long last_frag_packet;
diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index 2d5daac..2ab8198 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -211,7 +211,7 @@ unlock:
 	spin_unlock_bh(&bat_priv->orig_hash_lock);
 out:
 	if (orig_node)
-		kref_put(&orig_node->refcount, orig_node_free_ref);
+		orig_node_free_ref(orig_node);
 	return ret;
 }
 
@@ -280,7 +280,7 @@ int unicast_send_skb(struct sk_buff *skb, struct bat_priv *bat_priv)
 {
 	struct ethhdr *ethhdr = (struct ethhdr *)skb->data;
 	struct unicast_packet *unicast_packet;
-	struct orig_node *orig_node = NULL;
+	struct orig_node *orig_node;
 	struct batman_if *batman_if;
 	struct neigh_node *neigh_node;
 	int data_len = skb->len;
@@ -347,7 +347,7 @@ out:
 	if (neigh_node)
 		neigh_node_free_ref(neigh_node);
 	if (orig_node)
-		kref_put(&orig_node->refcount, orig_node_free_ref);
+		orig_node_free_ref(orig_node);
 	if (ret == 1)
 		kfree_skb(skb);
 	return ret;
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index d179aca..8972242 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -826,7 +826,7 @@ out:
 	if (neigh_node)
 		neigh_node_free_ref(neigh_node);
 	if (orig_node)
-		kref_put(&orig_node->refcount, orig_node_free_ref);
+		orig_node_free_ref(orig_node);
 	return;
 }
 
-- 
1.7.2.3

