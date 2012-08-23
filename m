From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 14/18] batman-adv: Don't break statements after assignment operator
Date: Thu, 23 Aug 2012 15:10:23 +0200
Message-ID: <1345727427-20805-15-git-send-email-ordex@autistici.org>
References: <1345727427-20805-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:28932 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933710Ab2HWNLD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 09:11:03 -0400
In-Reply-To: <1345727427-20805-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bat_iv_ogm.c            |   39 +++++++++++++++++---------------
 net/batman-adv/bridge_loop_avoidance.c |    7 +++---
 net/batman-adv/send.c                  |    8 +++----
 net/batman-adv/soft-interface.c        |    5 ++--
 net/batman-adv/unicast.c               |   11 +++++----
 net/batman-adv/vis.c                   |    4 ++--
 6 files changed, 39 insertions(+), 35 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index daaccc1..616d52d 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -588,6 +588,8 @@ static void batadv_iv_ogm_schedule(struct batadv_hard_iface *hard_iface)
 	struct batadv_ogm_packet *batadv_ogm_packet;
 	struct batadv_hard_iface *primary_if;
 	int vis_server, tt_num_changes = 0;
+	uint32_t seqno;
+	uint8_t bandwidth;
 
 	vis_server = atomic_read(&bat_priv->vis_mode);
 	primary_if = batadv_primary_if_get_selected(bat_priv);
@@ -601,8 +603,8 @@ static void batadv_iv_ogm_schedule(struct batadv_hard_iface *hard_iface)
 	batadv_ogm_packet = (struct batadv_ogm_packet *)hard_iface->packet_buff;
 
 	/* change sequence number to network order */
-	batadv_ogm_packet->seqno =
-			htonl((uint32_t)atomic_read(&hard_iface->seqno));
+	seqno = (uint32_t)atomic_read(&hard_iface->seqno);
+	batadv_ogm_packet->seqno = htonl(seqno);
 	atomic_inc(&hard_iface->seqno);
 
 	batadv_ogm_packet->ttvn = atomic_read(&bat_priv->tt.vn);
@@ -615,12 +617,13 @@ static void batadv_iv_ogm_schedule(struct batadv_hard_iface *hard_iface)
 	else
 		batadv_ogm_packet->flags &= ~BATADV_VIS_SERVER;
 
-	if ((hard_iface == primary_if) &&
-	    (atomic_read(&bat_priv->gw_mode) == BATADV_GW_MODE_SERVER))
-		batadv_ogm_packet->gw_flags =
-				(uint8_t)atomic_read(&bat_priv->gw_bandwidth);
-	else
+	if (hard_iface == primary_if &&
+	    atomic_read(&bat_priv->gw_mode) == BATADV_GW_MODE_SERVER) {
+		bandwidth = (uint8_t)atomic_read(&bat_priv->gw_bandwidth);
+		batadv_ogm_packet->gw_flags = bandwidth;
+	} else {
 		batadv_ogm_packet->gw_flags = BATADV_NO_FLAGS;
+	}
 
 	batadv_slide_own_bcast_window(hard_iface);
 	batadv_iv_ogm_queue_add(bat_priv, hard_iface->packet_buff,
@@ -644,8 +647,9 @@ batadv_iv_ogm_orig_update(struct batadv_priv *bat_priv,
 	struct batadv_neigh_node *router = NULL;
 	struct batadv_orig_node *orig_node_tmp;
 	struct hlist_node *node;
-	uint8_t bcast_own_sum_orig, bcast_own_sum_neigh;
+	uint8_t sum_orig, sum_neigh;
 	uint8_t *neigh_addr;
+	uint8_t tq_avg;
 
 	batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 		   "update_originator(): Searching and updating originator entry of received packet\n");
@@ -669,8 +673,8 @@ batadv_iv_ogm_orig_update(struct batadv_priv *bat_priv,
 		spin_lock_bh(&tmp_neigh_node->lq_update_lock);
 		batadv_ring_buffer_set(tmp_neigh_node->tq_recv,
 				       &tmp_neigh_node->tq_index, 0);
-		tmp_neigh_node->tq_avg =
-			batadv_ring_buffer_avg(tmp_neigh_node->tq_recv);
+		tq_avg = batadv_ring_buffer_avg(tmp_neigh_node->tq_recv);
+		tmp_neigh_node->tq_avg = tq_avg;
 		spin_unlock_bh(&tmp_neigh_node->lq_update_lock);
 	}
 
@@ -729,17 +733,15 @@ batadv_iv_ogm_orig_update(struct batadv_priv *bat_priv,
 	if (router && (neigh_node->tq_avg == router->tq_avg)) {
 		orig_node_tmp = router->orig_node;
 		spin_lock_bh(&orig_node_tmp->ogm_cnt_lock);
-		bcast_own_sum_orig =
-			orig_node_tmp->bcast_own_sum[if_incoming->if_num];
+		sum_orig = orig_node_tmp->bcast_own_sum[if_incoming->if_num];
 		spin_unlock_bh(&orig_node_tmp->ogm_cnt_lock);
 
 		orig_node_tmp = neigh_node->orig_node;
 		spin_lock_bh(&orig_node_tmp->ogm_cnt_lock);
-		bcast_own_sum_neigh =
-			orig_node_tmp->bcast_own_sum[if_incoming->if_num];
+		sum_neigh = orig_node_tmp->bcast_own_sum[if_incoming->if_num];
 		spin_unlock_bh(&orig_node_tmp->ogm_cnt_lock);
 
-		if (bcast_own_sum_orig >= bcast_own_sum_neigh)
+		if (sum_orig >= sum_neigh)
 			goto update_tt;
 	}
 
@@ -912,6 +914,7 @@ batadv_iv_ogm_update_seqnos(const struct ethhdr *ethhdr,
 	int set_mark, ret = -1;
 	uint32_t seqno = ntohl(batadv_ogm_packet->seqno);
 	uint8_t *neigh_addr;
+	uint8_t packet_count;
 
 	orig_node = batadv_get_orig_node(bat_priv, batadv_ogm_packet->orig);
 	if (!orig_node)
@@ -946,9 +949,9 @@ batadv_iv_ogm_update_seqnos(const struct ethhdr *ethhdr,
 						     tmp_neigh_node->real_bits,
 						     seq_diff, set_mark);
 
-		tmp_neigh_node->real_packet_count =
-			bitmap_weight(tmp_neigh_node->real_bits,
-				      BATADV_TQ_LOCAL_WINDOW_SIZE);
+		packet_count = bitmap_weight(tmp_neigh_node->real_bits,
+					     BATADV_TQ_LOCAL_WINDOW_SIZE);
+		tmp_neigh_node->real_packet_count = packet_count;
 	}
 	rcu_read_unlock();
 
diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index ad18017..7a93b2a 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -579,8 +579,7 @@ static void batadv_bla_add_claim(struct batadv_priv *bat_priv,
 			   "bla_add_claim(): changing ownership for %pM, vid %d\n",
 			   mac, vid);
 
-		claim->backbone_gw->crc ^=
-			crc16(0, claim->addr, ETH_ALEN);
+		claim->backbone_gw->crc ^= crc16(0, claim->addr, ETH_ALEN);
 		batadv_backbone_gw_free_ref(claim->backbone_gw);
 
 	}
@@ -1102,8 +1101,7 @@ static void batadv_bla_start_timer(struct batadv_priv *bat_priv)
  */
 static void batadv_bla_periodic_work(struct work_struct *work)
 {
-	struct delayed_work *delayed_work =
-		container_of(work, struct delayed_work, work);
+	struct delayed_work *delayed_work;
 	struct batadv_priv *bat_priv;
 	struct batadv_priv_bla *priv_bla;
 	struct hlist_node *node;
@@ -1113,6 +1111,7 @@ static void batadv_bla_periodic_work(struct work_struct *work)
 	struct batadv_hard_iface *primary_if;
 	int i;
 
+	delayed_work = container_of(work, struct delayed_work, work);
 	priv_bla = container_of(delayed_work, struct batadv_priv_bla, work);
 	bat_priv = container_of(priv_bla, struct batadv_priv, bla);
 	primary_if = batadv_primary_if_get_selected(bat_priv);
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 3b4b2da..570a8bc 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -190,13 +190,13 @@ out:
 static void batadv_send_outstanding_bcast_packet(struct work_struct *work)
 {
 	struct batadv_hard_iface *hard_iface;
-	struct delayed_work *delayed_work =
-		container_of(work, struct delayed_work, work);
+	struct delayed_work *delayed_work;
 	struct batadv_forw_packet *forw_packet;
 	struct sk_buff *skb1;
 	struct net_device *soft_iface;
 	struct batadv_priv *bat_priv;
 
+	delayed_work = container_of(work, struct delayed_work, work);
 	forw_packet = container_of(delayed_work, struct batadv_forw_packet,
 				   delayed_work);
 	soft_iface = forw_packet->if_incoming->soft_iface;
@@ -239,11 +239,11 @@ out:
 
 void batadv_send_outstanding_bat_ogm_packet(struct work_struct *work)
 {
-	struct delayed_work *delayed_work =
-		container_of(work, struct delayed_work, work);
+	struct delayed_work *delayed_work;
 	struct batadv_forw_packet *forw_packet;
 	struct batadv_priv *bat_priv;
 
+	delayed_work = container_of(work, struct delayed_work, work);
 	forw_packet = container_of(delayed_work, struct batadv_forw_packet,
 				   delayed_work);
 	bat_priv = netdev_priv(forw_packet->if_incoming->soft_iface);
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 6d44625..03b0763 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -149,6 +149,7 @@ static int batadv_interface_tx(struct sk_buff *skb,
 	int data_len = skb->len, ret;
 	short vid __maybe_unused = -1;
 	bool do_bcast = false;
+	uint32_t seqno;
 
 	if (atomic_read(&bat_priv->mesh_state) != BATADV_MESH_ACTIVE)
 		goto dropped;
@@ -230,8 +231,8 @@ static int batadv_interface_tx(struct sk_buff *skb,
 		       primary_if->net_dev->dev_addr, ETH_ALEN);
 
 		/* set broadcast sequence number */
-		bcast_packet->seqno =
-			htonl(atomic_inc_return(&bat_priv->bcast_seqno));
+		seqno = atomic_inc_return(&bat_priv->bcast_seqno);
+		bcast_packet->seqno = htonl(seqno);
 
 		batadv_add_bcast_packet_to_list(bat_priv, skb, 1);
 
diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index 0016464..d7904bd 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -121,6 +121,7 @@ batadv_frag_search_packet(struct list_head *head,
 {
 	struct batadv_frag_packet_list_entry *tfp;
 	struct batadv_unicast_frag_packet *tmp_up = NULL;
+	int is_head_tmp, is_head;
 	uint16_t search_seqno;
 
 	if (up->flags & BATADV_UNI_FRAG_HEAD)
@@ -128,6 +129,8 @@ batadv_frag_search_packet(struct list_head *head,
 	else
 		search_seqno = ntohs(up->seqno)-1;
 
+	is_head = !!(up->flags & BATADV_UNI_FRAG_HEAD);
+
 	list_for_each_entry(tfp, head, list) {
 
 		if (!tfp->skb)
@@ -139,9 +142,8 @@ batadv_frag_search_packet(struct list_head *head,
 		tmp_up = (struct batadv_unicast_frag_packet *)tfp->skb->data;
 
 		if (tfp->seqno == search_seqno) {
-
-			if ((tmp_up->flags & BATADV_UNI_FRAG_HEAD) !=
-			    (up->flags & BATADV_UNI_FRAG_HEAD))
+			is_head_tmp = !!(tmp_up->flags & BATADV_UNI_FRAG_HEAD);
+			if (is_head_tmp != is_head)
 				return tfp;
 			else
 				goto mov_tail;
@@ -334,8 +336,7 @@ find_router:
 	/* copy the destination for faster routing */
 	memcpy(unicast_packet->dest, orig_node->orig, ETH_ALEN);
 	/* set the destination tt version number */
-	unicast_packet->ttvn =
-		(uint8_t)atomic_read(&orig_node->last_ttvn);
+	unicast_packet->ttvn = (uint8_t)atomic_read(&orig_node->last_ttvn);
 
 	/* inform the destination node that we are still missing a correct route
 	 * for this client. The destination will receive this packet and will
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index 4608c1b2..55cc51b 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -814,12 +814,12 @@ out:
 /* called from timer; send (and maybe generate) vis packet. */
 static void batadv_send_vis_packets(struct work_struct *work)
 {
-	struct delayed_work *delayed_work =
-		container_of(work, struct delayed_work, work);
+	struct delayed_work *delayed_work;
 	struct batadv_priv *bat_priv;
 	struct batadv_priv_vis *priv_vis;
 	struct batadv_vis_info *info;
 
+	delayed_work = container_of(work, struct delayed_work, work);
 	priv_vis = container_of(delayed_work, struct batadv_priv_vis, work);
 	bat_priv = container_of(priv_vis, struct batadv_priv, vis);
 	spin_lock_bh(&bat_priv->vis.hash_lock);
-- 
1.7.9.4
