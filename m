From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH 09/28] batman-adv: protect ogm counter arrays with spinlock
Date: Sat,  5 Mar 2011 13:28:23 +0100
Message-ID: <1299328122-21468-10-git-send-email-sven@narfation.org>
References: <1299328122-21468-1-git-send-email-sven@narfation.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:36284 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753248Ab1CEM3l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Mar 2011 07:29:41 -0500
In-Reply-To: <1299328122-21468-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/originator.c |   11 +++++++++--
 net/batman-adv/routing.c    |   27 +++++++++++++++++++++++----
 net/batman-adv/types.h      |    1 +
 3 files changed, 33 insertions(+), 6 deletions(-)

diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index fcdb0b7..71dfc24 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -207,6 +207,7 @@ struct orig_node *get_orig_node(struct bat_priv *bat_priv, uint8_t *addr)
 		return NULL;
 
 	INIT_HLIST_HEAD(&orig_node->neigh_list);
+	spin_lock_init(&orig_node->ogm_cnt_lock);
 	spin_lock_init(&orig_node->neigh_list_lock);
 	kref_init(&orig_node->refcount);
 
@@ -517,7 +518,7 @@ int orig_hash_add_if(struct batman_if *batman_if, int max_if_num)
 	struct hlist_head *head;
 	struct element_t *bucket;
 	struct orig_node *orig_node;
-	int i;
+	int i, ret;
 
 	/* resize all orig nodes because orig_node->bcast_own(_sum) depend on
 	 * if_num */
@@ -530,7 +531,11 @@ int orig_hash_add_if(struct batman_if *batman_if, int max_if_num)
 		hlist_for_each_entry_rcu(bucket, walk, head, hlist) {
 			orig_node = bucket->data;
 
-			if (orig_node_add_if(orig_node, max_if_num) == -1)
+			spin_lock_bh(&orig_node->ogm_cnt_lock);
+			ret = orig_node_add_if(orig_node, max_if_num);
+			spin_unlock_bh(&orig_node->ogm_cnt_lock);
+
+			if (ret == -1)
 				goto err;
 		}
 		rcu_read_unlock();
@@ -619,8 +624,10 @@ int orig_hash_del_if(struct batman_if *batman_if, int max_if_num)
 		hlist_for_each_entry_rcu(bucket, walk, head, hlist) {
 			orig_node = bucket->data;
 
+			spin_lock_bh(&orig_node->ogm_cnt_lock);
 			ret = orig_node_del_if(orig_node, max_if_num,
 					batman_if->if_num);
+			spin_unlock_bh(&orig_node->ogm_cnt_lock);
 
 			if (ret == -1)
 				goto err;
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 1c31a0e..7627ebe 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -55,12 +55,14 @@ void slide_own_bcast_window(struct batman_if *batman_if)
 		rcu_read_lock();
 		hlist_for_each_entry_rcu(bucket, walk, head, hlist) {
 			orig_node = bucket->data;
+			spin_lock_bh(&orig_node->ogm_cnt_lock);
 			word_index = batman_if->if_num * NUM_WORDS;
 			word = &(orig_node->bcast_own[word_index]);
 
 			bit_get_packet(bat_priv, word, 1, 0);
 			orig_node->bcast_own_sum[batman_if->if_num] =
 				bit_packet_count(word);
+			spin_unlock_bh(&orig_node->ogm_cnt_lock);
 		}
 		rcu_read_unlock();
 	}
@@ -278,8 +280,10 @@ static void update_orig(struct bat_priv *bat_priv,
 			char is_duplicate)
 {
 	struct neigh_node *neigh_node = NULL, *tmp_neigh_node = NULL;
+	struct orig_node *orig_node_tmp;
 	struct hlist_node *node;
 	int tmp_hna_buff_len;
+	uint8_t bcast_own_sum_orig, bcast_own_sum_neigh;
 
 	bat_dbg(DBG_BATMAN, bat_priv, "update_originator(): "
 		"Searching and updating originator entry of received packet\n");
@@ -351,10 +355,22 @@ static void update_orig(struct bat_priv *bat_priv,
 	/* if the TQ is the same and the link not more symetric we
 	 * won't consider it either */
 	if ((orig_node->router) &&
-	     ((neigh_node->tq_avg == orig_node->router->tq_avg) &&
-	     (orig_node->router->orig_node->bcast_own_sum[if_incoming->if_num]
-	      >= neigh_node->orig_node->bcast_own_sum[if_incoming->if_num])))
-		goto update_hna;
+	     (neigh_node->tq_avg == orig_node->router->tq_avg)) {
+		orig_node_tmp = orig_node->router->orig_node;
+		spin_lock_bh(&orig_node_tmp->ogm_cnt_lock);
+		bcast_own_sum_orig =
+			orig_node_tmp->bcast_own_sum[if_incoming->if_num];
+		spin_unlock_bh(&orig_node_tmp->ogm_cnt_lock);
+
+		orig_node_tmp = neigh_node->orig_node;
+		spin_lock_bh(&orig_node_tmp->ogm_cnt_lock);
+		bcast_own_sum_neigh =
+			orig_node_tmp->bcast_own_sum[if_incoming->if_num];
+		spin_unlock_bh(&orig_node_tmp->ogm_cnt_lock);
+
+		if (bcast_own_sum_orig >= bcast_own_sum_neigh)
+			goto update_hna;
+	}
 
 	update_routes(bat_priv, orig_node, neigh_node,
 		      hna_buff, tmp_hna_buff_len);
@@ -705,10 +721,13 @@ void receive_bat_packet(struct ethhdr *ethhdr,
 				 batman_packet->orig) &&
 		    (batman_packet->seqno - if_incoming_seqno + 2 == 0)) {
 			offset = if_incoming->if_num * NUM_WORDS;
+
+			spin_lock_bh(&orig_neigh_node->ogm_cnt_lock);
 			word = &(orig_neigh_node->bcast_own[offset]);
 			bit_mark(word, 0);
 			orig_neigh_node->bcast_own_sum[if_incoming->if_num] =
 				bit_packet_count(word);
+			spin_unlock_bh(&orig_neigh_node->ogm_cnt_lock);
 		}
 
 		bat_dbg(DBG_BATMAN, bat_priv, "Drop packet: "
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index ca4d42d..ff70afc 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -89,6 +89,7 @@ struct orig_node {
 	struct kref refcount;
 	struct bat_priv *bat_priv;
 	unsigned long last_frag_packet;
+	spinlock_t ogm_cnt_lock; /* protects ogm counter */
 	struct {
 		uint8_t candidates;
 		struct neigh_node *selected;
-- 
1.7.2.3

