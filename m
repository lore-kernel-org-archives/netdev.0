From: Antonio Quartulli <antonio-x4xJYDvStAgysxA8WJXlww@public.gmane.org>
Subject: [PATCH 01/16] batman-adv: make struct
	batadv_neigh_node algorithm agnostic
Date: Wed, 23 Oct 2013 18:04:48 +0200
Message-ID: <1382544303-2694-2-git-send-email-antonio@meshcoding.com>
References: <1382544303-2694-1-git-send-email-antonio@meshcoding.com>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>,
 Antonio Quartulli <antonio-2BnEqQcu77q1Z/+hSey0Gg@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1382544303-2694-1-git-send-email-antonio-x4xJYDvStAgysxA8WJXlww@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Antonio Quartulli <antonio-2BnEqQcu77q1Z/+hSey0Gg@public.gmane.org>

some of the fields in struct batadv_neigh_node are strictly
related to the B.A.T.M.A.N. IV algorithm. In order to
make the struct usable by any routing algorithm it has to be
split and made more generic

Signed-off-by: Antonio Quartulli <antonio-2BnEqQcu77q1Z/+hSey0Gg@public.gmane.org>
Signed-off-by: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
---
 net/batman-adv/bat_iv_ogm.c        | 60 +++++++++++++++++++++-----------------
 net/batman-adv/gateway_client.c    | 16 +++++-----
 net/batman-adv/network-coding.c    |  8 +++--
 net/batman-adv/originator.c        | 33 ++++++++++++++-------
 net/batman-adv/originator.h        |  3 +-
 net/batman-adv/routing.c           |  9 ++++--
 net/batman-adv/translation-table.c |  4 +--
 net/batman-adv/types.h             | 41 ++++++++++++++++----------
 8 files changed, 103 insertions(+), 71 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 97b42d3..a2a0498 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -93,16 +93,18 @@ batadv_iv_ogm_neigh_new(struct batadv_hard_iface *hard_iface,
 			struct batadv_orig_node *orig_node,
 			struct batadv_orig_node *orig_neigh)
 {
+	struct batadv_priv *bat_priv = netdev_priv(hard_iface->soft_iface);
 	struct batadv_neigh_node *neigh_node;
 
-	neigh_node = batadv_neigh_node_new(hard_iface, neigh_addr);
+	neigh_node = batadv_neigh_node_new(hard_iface, neigh_addr, orig_node);
 	if (!neigh_node)
 		goto out;
 
-	INIT_LIST_HEAD(&neigh_node->bonding_list);
+	spin_lock_init(&neigh_node->bat_iv.lq_update_lock);
 
-	neigh_node->orig_node = orig_neigh;
-	neigh_node->if_incoming = hard_iface;
+	batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
+		   "Creating new neighbor %pM for orig_node %pM on interface %s\n",
+		   neigh_addr, orig_node->orig, hard_iface->net_dev->name);
 
 	spin_lock_bh(&orig_node->neigh_list_lock);
 	hlist_add_head_rcu(&neigh_node->list, &orig_node->neigh_list);
@@ -755,12 +757,12 @@ batadv_iv_ogm_orig_update(struct batadv_priv *bat_priv,
 		if (dup_status != BATADV_NO_DUP)
 			continue;
 
-		spin_lock_bh(&tmp_neigh_node->lq_update_lock);
-		batadv_ring_buffer_set(tmp_neigh_node->tq_recv,
-				       &tmp_neigh_node->tq_index, 0);
-		tq_avg = batadv_ring_buffer_avg(tmp_neigh_node->tq_recv);
-		tmp_neigh_node->tq_avg = tq_avg;
-		spin_unlock_bh(&tmp_neigh_node->lq_update_lock);
+		spin_lock_bh(&tmp_neigh_node->bat_iv.lq_update_lock);
+		batadv_ring_buffer_set(tmp_neigh_node->bat_iv.tq_recv,
+				       &tmp_neigh_node->bat_iv.tq_index, 0);
+		tq_avg = batadv_ring_buffer_avg(tmp_neigh_node->bat_iv.tq_recv);
+		tmp_neigh_node->bat_iv.tq_avg = tq_avg;
+		spin_unlock_bh(&tmp_neigh_node->bat_iv.lq_update_lock);
 	}
 
 	if (!neigh_node) {
@@ -785,12 +787,13 @@ batadv_iv_ogm_orig_update(struct batadv_priv *bat_priv,
 
 	neigh_node->last_seen = jiffies;
 
-	spin_lock_bh(&neigh_node->lq_update_lock);
-	batadv_ring_buffer_set(neigh_node->tq_recv,
-			       &neigh_node->tq_index,
+	spin_lock_bh(&neigh_node->bat_iv.lq_update_lock);
+	batadv_ring_buffer_set(neigh_node->bat_iv.tq_recv,
+			       &neigh_node->bat_iv.tq_index,
 			       batadv_ogm_packet->tq);
-	neigh_node->tq_avg = batadv_ring_buffer_avg(neigh_node->tq_recv);
-	spin_unlock_bh(&neigh_node->lq_update_lock);
+	tq_avg = batadv_ring_buffer_avg(neigh_node->bat_iv.tq_recv);
+	neigh_node->bat_iv.tq_avg = tq_avg;
+	spin_unlock_bh(&neigh_node->bat_iv.lq_update_lock);
 
 	if (dup_status == BATADV_NO_DUP) {
 		orig_node->last_ttl = batadv_ogm_packet->header.ttl;
@@ -807,13 +810,13 @@ batadv_iv_ogm_orig_update(struct batadv_priv *bat_priv,
 		goto out;
 
 	/* if this neighbor does not offer a better TQ we won't consider it */
-	if (router && (router->tq_avg > neigh_node->tq_avg))
+	if (router && (router->bat_iv.tq_avg > neigh_node->bat_iv.tq_avg))
 		goto out;
 
 	/* if the TQ is the same and the link not more symmetric we
 	 * won't consider it either
 	 */
-	if (router && (neigh_node->tq_avg == router->tq_avg)) {
+	if (router && (neigh_node->bat_iv.tq_avg == router->bat_iv.tq_avg)) {
 		orig_node_tmp = router->orig_node;
 		spin_lock_bh(&orig_node_tmp->ogm_cnt_lock);
 		if_num = router->if_incoming->if_num;
@@ -892,7 +895,7 @@ static int batadv_iv_ogm_calc_tq(struct batadv_orig_node *orig_node,
 	/* find packet count of corresponding one hop neighbor */
 	spin_lock_bh(&orig_node->ogm_cnt_lock);
 	orig_eq_count = orig_neigh_node->bcast_own_sum[if_incoming->if_num];
-	neigh_rq_count = neigh_node->real_packet_count;
+	neigh_rq_count = neigh_node->bat_iv.real_packet_count;
 	spin_unlock_bh(&orig_node->ogm_cnt_lock);
 
 	/* pay attention to not get a value bigger than 100 % */
@@ -975,6 +978,7 @@ batadv_iv_ogm_update_seqnos(const struct ethhdr *ethhdr,
 	uint32_t seqno = ntohl(batadv_ogm_packet->seqno);
 	uint8_t *neigh_addr;
 	uint8_t packet_count;
+	unsigned long *bitmap;
 
 	orig_node = batadv_get_orig_node(bat_priv, batadv_ogm_packet->orig);
 	if (!orig_node)
@@ -995,7 +999,7 @@ batadv_iv_ogm_update_seqnos(const struct ethhdr *ethhdr,
 	hlist_for_each_entry_rcu(tmp_neigh_node,
 				 &orig_node->neigh_list, list) {
 		neigh_addr = tmp_neigh_node->addr;
-		is_dup = batadv_test_bit(tmp_neigh_node->real_bits,
+		is_dup = batadv_test_bit(tmp_neigh_node->bat_iv.real_bits,
 					 orig_node->last_real_seqno,
 					 seqno);
 
@@ -1011,13 +1015,13 @@ batadv_iv_ogm_update_seqnos(const struct ethhdr *ethhdr,
 		}
 
 		/* if the window moved, set the update flag. */
-		need_update |= batadv_bit_get_packet(bat_priv,
-						     tmp_neigh_node->real_bits,
+		bitmap = tmp_neigh_node->bat_iv.real_bits;
+		need_update |= batadv_bit_get_packet(bat_priv, bitmap,
 						     seq_diff, set_mark);
 
-		packet_count = bitmap_weight(tmp_neigh_node->real_bits,
+		packet_count = bitmap_weight(tmp_neigh_node->bat_iv.real_bits,
 					     BATADV_TQ_LOCAL_WINDOW_SIZE);
-		tmp_neigh_node->real_packet_count = packet_count;
+		tmp_neigh_node->bat_iv.real_packet_count = packet_count;
 	}
 	rcu_read_unlock();
 
@@ -1041,7 +1045,7 @@ static void batadv_iv_ogm_process(const struct ethhdr *ethhdr,
 {
 	struct batadv_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
 	struct batadv_hard_iface *hard_iface;
-	struct batadv_orig_node *orig_neigh_node, *orig_node;
+	struct batadv_orig_node *orig_neigh_node, *orig_node, *orig_node_tmp;
 	struct batadv_neigh_node *router = NULL, *router_router = NULL;
 	struct batadv_neigh_node *orig_neigh_router = NULL;
 	int has_directlink_flag;
@@ -1192,10 +1196,12 @@ static void batadv_iv_ogm_process(const struct ethhdr *ethhdr,
 	}
 
 	router = batadv_orig_node_get_router(orig_node);
-	if (router)
-		router_router = batadv_orig_node_get_router(router->orig_node);
+	if (router) {
+		orig_node_tmp = router->orig_node;
+		router_router = batadv_orig_node_get_router(orig_node_tmp);
+	}
 
-	if ((router && router->tq_avg != 0) &&
+	if ((router && router->bat_iv.tq_avg != 0) &&
 	    (batadv_compare_eth(router->addr, ethhdr->h_source)))
 		is_from_best_next_hop = true;
 
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 20fa053..2449afa 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -137,7 +137,7 @@ batadv_gw_get_best_gw_node(struct batadv_priv *bat_priv)
 		if (!atomic_inc_not_zero(&gw_node->refcount))
 			goto next;
 
-		tq_avg = router->tq_avg;
+		tq_avg = router->bat_iv.tq_avg;
 
 		switch (atomic_read(&bat_priv->gw_sel_class)) {
 		case 1: /* fast connection */
@@ -256,7 +256,7 @@ void batadv_gw_election(struct batadv_priv *bat_priv)
 			   next_gw->bandwidth_down / 10,
 			   next_gw->bandwidth_down % 10,
 			   next_gw->bandwidth_up / 10,
-			   next_gw->bandwidth_up % 10, router->tq_avg);
+			   next_gw->bandwidth_up % 10, router->bat_iv.tq_avg);
 		batadv_throw_uevent(bat_priv, BATADV_UEV_GW, BATADV_UEV_ADD,
 				    gw_addr);
 	} else {
@@ -266,7 +266,7 @@ void batadv_gw_election(struct batadv_priv *bat_priv)
 			   next_gw->bandwidth_down / 10,
 			   next_gw->bandwidth_down % 10,
 			   next_gw->bandwidth_up / 10,
-			   next_gw->bandwidth_up % 10, router->tq_avg);
+			   next_gw->bandwidth_up % 10, router->bat_iv.tq_avg);
 		batadv_throw_uevent(bat_priv, BATADV_UEV_GW, BATADV_UEV_CHANGE,
 				    gw_addr);
 	}
@@ -305,8 +305,8 @@ void batadv_gw_check_election(struct batadv_priv *bat_priv,
 	if (!router_orig)
 		goto out;
 
-	gw_tq_avg = router_gw->tq_avg;
-	orig_tq_avg = router_orig->tq_avg;
+	gw_tq_avg = router_gw->bat_iv.tq_avg;
+	orig_tq_avg = router_orig->bat_iv.tq_avg;
 
 	/* the TQ value has to be better */
 	if (orig_tq_avg < gw_tq_avg)
@@ -528,7 +528,7 @@ static int batadv_write_buffer_text(struct batadv_priv *bat_priv,
 	ret = seq_printf(seq, "%s %pM (%3i) %pM [%10s]: %u.%u/%u.%u MBit\n",
 			 (curr_gw == gw_node ? "=>" : "  "),
 			 gw_node->orig_node->orig,
-			 router->tq_avg, router->addr,
+			 router->bat_iv.tq_avg, router->addr,
 			 router->if_incoming->net_dev->name,
 			 gw_node->bandwidth_down / 10,
 			 gw_node->bandwidth_down % 10,
@@ -792,7 +792,7 @@ bool batadv_gw_out_of_range(struct batadv_priv *bat_priv,
 		if (!neigh_curr)
 			goto out;
 
-		curr_tq_avg = neigh_curr->tq_avg;
+		curr_tq_avg = neigh_curr->bat_iv.tq_avg;
 		break;
 	case BATADV_GW_MODE_OFF:
 	default:
@@ -803,7 +803,7 @@ bool batadv_gw_out_of_range(struct batadv_priv *bat_priv,
 	if (!neigh_old)
 		goto out;
 
-	if (curr_tq_avg - neigh_old->tq_avg > BATADV_GW_THRESHOLD)
+	if (curr_tq_avg - neigh_old->bat_iv.tq_avg > BATADV_GW_THRESHOLD)
 		out_of_range = true;
 
 out:
diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-coding.c
index 23f611b..351e199 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -1003,7 +1003,7 @@ static bool batadv_nc_code_packets(struct batadv_priv *bat_priv,
 				   struct batadv_nc_packet *nc_packet,
 				   struct batadv_neigh_node *neigh_node)
 {
-	uint8_t tq_weighted_neigh, tq_weighted_coding;
+	uint8_t tq_weighted_neigh, tq_weighted_coding, tq_tmp;
 	struct sk_buff *skb_dest, *skb_src;
 	struct batadv_unicast_packet *packet1;
 	struct batadv_unicast_packet *packet2;
@@ -1028,8 +1028,10 @@ static bool batadv_nc_code_packets(struct batadv_priv *bat_priv,
 	if (!router_coding)
 		goto out;
 
-	tq_weighted_neigh = batadv_nc_random_weight_tq(router_neigh->tq_avg);
-	tq_weighted_coding = batadv_nc_random_weight_tq(router_coding->tq_avg);
+	tq_tmp = batadv_nc_random_weight_tq(router_neigh->bat_iv.tq_avg);
+	tq_weighted_neigh = tq_tmp;
+	tq_tmp = batadv_nc_random_weight_tq(router_coding->bat_iv.tq_avg);
+	tq_weighted_coding = tq_tmp;
 
 	/* Select one destination for the MAC-header dst-field based on
 	 * weighted TQ-values.
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index ee1d847..50f6d99 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -172,11 +172,20 @@ batadv_orig_node_get_router(struct batadv_orig_node *orig_node)
 	return router;
 }
 
+/**
+ * batadv_neigh_node_new - create and init a new neigh_node object
+ * @hard_iface: the interface where the neighbour is connected to
+ * @neigh_addr: the mac address of the neighbour interface
+ * @orig_node: originator object representing the neighbour
+ *
+ * Allocates a new neigh_node object and initialises all the generic fields.
+ * Returns the new object or NULL on failure.
+ */
 struct batadv_neigh_node *
 batadv_neigh_node_new(struct batadv_hard_iface *hard_iface,
-		      const uint8_t *neigh_addr)
+		      const uint8_t *neigh_addr,
+		      struct batadv_orig_node *orig_node)
 {
-	struct batadv_priv *bat_priv = netdev_priv(hard_iface->soft_iface);
 	struct batadv_neigh_node *neigh_node;
 
 	neigh_node = kzalloc(sizeof(*neigh_node), GFP_ATOMIC);
@@ -186,15 +195,14 @@ batadv_neigh_node_new(struct batadv_hard_iface *hard_iface,
 	INIT_HLIST_NODE(&neigh_node->list);
 
 	memcpy(neigh_node->addr, neigh_addr, ETH_ALEN);
-	spin_lock_init(&neigh_node->lq_update_lock);
+	neigh_node->if_incoming = hard_iface;
+	neigh_node->orig_node = orig_node;
+
+	INIT_LIST_HEAD(&neigh_node->bonding_list);
 
 	/* extra reference for return */
 	atomic_set(&neigh_node->refcount, 2);
 
-	batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
-		   "Creating new neighbor %pM on interface %s\n", neigh_addr,
-		   hard_iface->net_dev->name);
-
 out:
 	return neigh_node;
 }
@@ -401,6 +409,7 @@ batadv_purge_orig_neighbors(struct batadv_priv *bat_priv,
 	bool neigh_purged = false;
 	unsigned long last_seen;
 	struct batadv_hard_iface *if_incoming;
+	uint8_t best_metric = 0;
 
 	*best_neigh_node = NULL;
 
@@ -436,8 +445,10 @@ batadv_purge_orig_neighbors(struct batadv_priv *bat_priv,
 			batadv_neigh_node_free_ref(neigh_node);
 		} else {
 			if ((!*best_neigh_node) ||
-			    (neigh_node->tq_avg > (*best_neigh_node)->tq_avg))
+			    (neigh_node->bat_iv.tq_avg > best_metric)) {
 				*best_neigh_node = neigh_node;
+				best_metric = neigh_node->bat_iv.tq_avg;
+			}
 		}
 	}
 
@@ -557,7 +568,7 @@ int batadv_orig_seq_print_text(struct seq_file *seq, void *offset)
 			if (!neigh_node)
 				continue;
 
-			if (neigh_node->tq_avg == 0)
+			if (neigh_node->bat_iv.tq_avg == 0)
 				goto next;
 
 			last_seen_jiffies = jiffies - orig_node->last_seen;
@@ -567,7 +578,7 @@ int batadv_orig_seq_print_text(struct seq_file *seq, void *offset)
 
 			seq_printf(seq, "%pM %4i.%03is   (%3i) %pM [%10s]:",
 				   orig_node->orig, last_seen_secs,
-				   last_seen_msecs, neigh_node->tq_avg,
+				   last_seen_msecs, neigh_node->bat_iv.tq_avg,
 				   neigh_node->addr,
 				   neigh_node->if_incoming->net_dev->name);
 
@@ -575,7 +586,7 @@ int batadv_orig_seq_print_text(struct seq_file *seq, void *offset)
 						 &orig_node->neigh_list, list) {
 				seq_printf(seq, " %pM (%3i)",
 					   neigh_node_tmp->addr,
-					   neigh_node_tmp->tq_avg);
+					   neigh_node_tmp->bat_iv.tq_avg);
 			}
 
 			seq_puts(seq, "\n");
diff --git a/net/batman-adv/originator.h b/net/batman-adv/originator.h
index cc6d686..06e5a68 100644
--- a/net/batman-adv/originator.h
+++ b/net/batman-adv/originator.h
@@ -31,7 +31,8 @@ struct batadv_orig_node *batadv_get_orig_node(struct batadv_priv *bat_priv,
 					      const uint8_t *addr);
 struct batadv_neigh_node *
 batadv_neigh_node_new(struct batadv_hard_iface *hard_iface,
-		      const uint8_t *neigh_addr);
+		      const uint8_t *neigh_addr,
+		      struct batadv_orig_node *orig_node);
 void batadv_neigh_node_free_ref(struct batadv_neigh_node *neigh_node);
 struct batadv_neigh_node *
 batadv_orig_node_get_router(struct batadv_orig_node *orig_node);
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 4bcf221..5b78a71 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -119,7 +119,7 @@ void batadv_bonding_candidate_add(struct batadv_orig_node *orig_node,
 				  struct batadv_neigh_node *neigh_node)
 {
 	struct batadv_neigh_node *tmp_neigh_node, *router = NULL;
-	uint8_t interference_candidate = 0;
+	uint8_t interference_candidate = 0, tq;
 
 	spin_lock_bh(&orig_node->neigh_list_lock);
 
@@ -132,8 +132,10 @@ void batadv_bonding_candidate_add(struct batadv_orig_node *orig_node,
 	if (!router)
 		goto candidate_del;
 
+
 	/* ... and is good enough to be considered */
-	if (neigh_node->tq_avg < router->tq_avg - BATADV_BONDING_TQ_THRESHOLD)
+	tq = router->bat_iv.tq_avg - BATADV_BONDING_TQ_THRESHOLD;
+	if (neigh_node->bat_iv.tq_avg < tq)
 		goto candidate_del;
 
 	/* check if we have another candidate with the same mac address or
@@ -502,7 +504,8 @@ batadv_find_ifalter_router(struct batadv_orig_node *primary_orig,
 		if (tmp_neigh_node->if_incoming == recv_if)
 			continue;
 
-		if (router && tmp_neigh_node->tq_avg <= router->tq_avg)
+		if (router &&
+		    tmp_neigh_node->bat_iv.tq_avg <= router->bat_iv.tq_avg)
 			continue;
 
 		if (!atomic_inc_not_zero(&tmp_neigh_node->refcount))
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 7731eae..1d5a4f5 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -1299,9 +1299,9 @@ batadv_transtable_best_orig(struct batadv_tt_global_entry *tt_global_entry)
 		if (!router)
 			continue;
 
-		if (router->tq_avg > best_tq) {
+		if (router->bat_iv.tq_avg > best_tq) {
 			best_entry = orig_entry;
-			best_tq = router->tq_avg;
+			best_tq = router->bat_iv.tq_avg;
 		}
 
 		batadv_neigh_node_free_ref(router);
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index ff53933..a321334 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -263,40 +263,49 @@ struct batadv_gw_node {
 };
 
 /**
- * struct batadv_neigh_node - structure for single hop neighbors
- * @list: list node for batadv_orig_node::neigh_list
- * @addr: mac address of neigh node
+ * struct batadv_neigh_bat_iv - B.A.T.M.A.N. IV specific structure for single
+ *  hop neighbors
  * @tq_recv: ring buffer of received TQ values from this neigh node
  * @tq_index: ring buffer index
  * @tq_avg: averaged tq of all tq values in the ring buffer (tq_recv)
- * @last_ttl: last received ttl from this neigh node
- * @bonding_list: list node for batadv_orig_node::bond_list
- * @last_seen: when last packet via this neighbor was received
  * @real_bits: bitfield containing the number of OGMs received from this neigh
  *  node (relative to orig_node->last_real_seqno)
  * @real_packet_count: counted result of real_bits
+ * @lq_update_lock: lock protecting tq_recv & tq_index
+ */
+struct batadv_neigh_bat_iv {
+	uint8_t tq_recv[BATADV_TQ_GLOBAL_WINDOW_SIZE];
+	uint8_t tq_index;
+	uint8_t tq_avg;
+	DECLARE_BITMAP(real_bits, BATADV_TQ_LOCAL_WINDOW_SIZE);
+	uint8_t real_packet_count;
+	spinlock_t lq_update_lock; /* protects tq_recv & tq_index */
+};
+
+/**
+ * struct batadv_neigh_node - structure for single hops neighbors
+ * @list: list node for batadv_orig_node::neigh_list
  * @orig_node: pointer to corresponding orig_node
+ * @addr: the MAC address of the neighboring interface
  * @if_incoming: pointer to incoming hard interface
- * @lq_update_lock: lock protecting tq_recv & tq_index
+ * @last_seen: when last packet via this neighbor was received
+ * @last_ttl: last received ttl from this neigh node
+ * @bonding_list: list node for batadv_orig_node::bond_list
  * @refcount: number of contexts the object is used
  * @rcu: struct used for freeing in an RCU-safe manner
+ * @bat_iv: B.A.T.M.A.N. IV private structure
  */
 struct batadv_neigh_node {
 	struct hlist_node list;
+	struct batadv_orig_node *orig_node;
 	uint8_t addr[ETH_ALEN];
-	uint8_t tq_recv[BATADV_TQ_GLOBAL_WINDOW_SIZE];
-	uint8_t tq_index;
-	uint8_t tq_avg;
+	struct batadv_hard_iface *if_incoming;
+	unsigned long last_seen;
 	uint8_t last_ttl;
 	struct list_head bonding_list;
-	unsigned long last_seen;
-	DECLARE_BITMAP(real_bits, BATADV_TQ_LOCAL_WINDOW_SIZE);
-	uint8_t real_packet_count;
-	struct batadv_orig_node *orig_node;
-	struct batadv_hard_iface *if_incoming;
-	spinlock_t lq_update_lock; /* protects tq_recv & tq_index */
 	atomic_t refcount;
 	struct rcu_head rcu;
+	struct batadv_neigh_bat_iv bat_iv;
 };
 
 /**
-- 
1.8.4
