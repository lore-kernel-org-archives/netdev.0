From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 15/18] batman-adv: Reduce accumulated length of simple statements
Date: Thu, 23 Aug 2012 15:10:24 +0200
Message-ID: <1345727427-20805-16-git-send-email-ordex@autistici.org>
References: <1345727427-20805-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:28945 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933717Ab2HWNLE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 09:11:04 -0400
In-Reply-To: <1345727427-20805-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bat_iv_ogm.c            |   41 ++++++++++++++++++++------------
 net/batman-adv/bridge_loop_avoidance.c |    3 +--
 net/batman-adv/gateway_client.c        |   21 +++++++++-------
 net/batman-adv/routing.c               |    3 +--
 net/batman-adv/translation-table.c     |   10 ++++----
 net/batman-adv/unicast.c               |    5 ++--
 net/batman-adv/vis.c                   |   10 ++++----
 7 files changed, 55 insertions(+), 38 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 616d52d..df79300 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -166,13 +166,15 @@ static void batadv_iv_ogm_send_to_if(struct batadv_forw_packet *forw_packet,
 	int16_t buff_pos;
 	struct batadv_ogm_packet *batadv_ogm_packet;
 	struct sk_buff *skb;
+	uint8_t *packet_pos;
 
 	if (hard_iface->if_status != BATADV_IF_ACTIVE)
 		return;
 
 	packet_num = 0;
 	buff_pos = 0;
-	batadv_ogm_packet = (struct batadv_ogm_packet *)forw_packet->skb->data;
+	packet_pos = forw_packet->skb->data;
+	batadv_ogm_packet = (struct batadv_ogm_packet *)packet_pos;
 
 	/* adjust all flags and log packets */
 	while (batadv_iv_ogm_aggr_packet(buff_pos, forw_packet->packet_len,
@@ -187,9 +189,11 @@ static void batadv_iv_ogm_send_to_if(struct batadv_forw_packet *forw_packet,
 		else
 			batadv_ogm_packet->flags &= ~BATADV_DIRECTLINK;
 
-		fwd_str = (packet_num > 0 ? "Forwarding" : (forw_packet->own ?
-							    "Sending own" :
-							    "Forwarding"));
+		if (packet_num > 0 || !forw_packet->own)
+			fwd_str = "Forwarding";
+		else
+			fwd_str = "Sending own";
+
 		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "%s %spacket (originator %pM, seqno %u, TQ %d, TTL %d, IDF %s, ttvn %d) on interface %s [%pM]\n",
 			   fwd_str, (packet_num > 0 ? "aggregated " : ""),
@@ -204,8 +208,8 @@ static void batadv_iv_ogm_send_to_if(struct batadv_forw_packet *forw_packet,
 		buff_pos += BATADV_OGM_HLEN;
 		buff_pos += batadv_tt_len(batadv_ogm_packet->tt_num_changes);
 		packet_num++;
-		batadv_ogm_packet = (struct batadv_ogm_packet *)
-					(forw_packet->skb->data + buff_pos);
+		packet_pos = forw_packet->skb->data + buff_pos;
+		batadv_ogm_packet = (struct batadv_ogm_packet *)packet_pos;
 	}
 
 	/* create clone because function is called more than once */
@@ -227,9 +231,10 @@ static void batadv_iv_ogm_emit(struct batadv_forw_packet *forw_packet)
 	struct batadv_hard_iface *primary_if = NULL;
 	struct batadv_ogm_packet *batadv_ogm_packet;
 	unsigned char directlink;
+	uint8_t *packet_pos;
 
-	batadv_ogm_packet = (struct batadv_ogm_packet *)
-						(forw_packet->skb->data);
+	packet_pos = forw_packet->skb->data;
+	batadv_ogm_packet = (struct batadv_ogm_packet *)packet_pos;
 	directlink = (batadv_ogm_packet->flags & BATADV_DIRECTLINK ? 1 : 0);
 
 	if (!forw_packet->if_incoming) {
@@ -839,8 +844,10 @@ static int batadv_iv_ogm_calc_tq(struct batadv_orig_node *orig_node,
 	spin_unlock_bh(&orig_node->ogm_cnt_lock);
 
 	/* pay attention to not get a value bigger than 100 % */
-	total_count = (orig_eq_count > neigh_rq_count ?
-		       neigh_rq_count : orig_eq_count);
+	if (orig_eq_count > neigh_rq_count)
+		total_count = neigh_rq_count;
+	else
+		total_count = orig_eq_count;
 
 	/* if we have too few packets (too less data) we set tq_own to zero
 	 * if we receive too few packets it is not considered bidirectional
@@ -1168,9 +1175,12 @@ static void batadv_iv_ogm_process(const struct ethhdr *ethhdr,
 	/* if sender is a direct neighbor the sender mac equals
 	 * originator mac
 	 */
-	orig_neigh_node = (is_single_hop_neigh ?
-			   orig_node :
-			   batadv_get_orig_node(bat_priv, ethhdr->h_source));
+	if (is_single_hop_neigh)
+		orig_neigh_node = orig_node;
+	else
+		orig_neigh_node = batadv_get_orig_node(bat_priv,
+						       ethhdr->h_source);
+
 	if (!orig_neigh_node)
 		goto out;
 
@@ -1256,6 +1266,7 @@ static int batadv_iv_ogm_receive(struct sk_buff *skb,
 	int buff_pos = 0, packet_len;
 	unsigned char *tt_buff, *packet_buff;
 	bool ret;
+	uint8_t *packet_pos;
 
 	ret = batadv_check_management_packet(skb, if_incoming, BATADV_OGM_HLEN);
 	if (!ret)
@@ -1286,8 +1297,8 @@ static int batadv_iv_ogm_receive(struct sk_buff *skb,
 		buff_pos += BATADV_OGM_HLEN;
 		buff_pos += batadv_tt_len(batadv_ogm_packet->tt_num_changes);
 
-		batadv_ogm_packet = (struct batadv_ogm_packet *)
-						(packet_buff + buff_pos);
+		packet_pos = packet_buff + buff_pos;
+		batadv_ogm_packet = (struct batadv_ogm_packet *)packet_pos;
 	} while (batadv_iv_ogm_aggr_packet(buff_pos, packet_len,
 					   batadv_ogm_packet->tt_num_changes));
 
diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 7a93b2a..0a9084a 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -1345,8 +1345,7 @@ int batadv_bla_is_backbone_gw(struct sk_buff *skb,
 		if (!pskb_may_pull(skb, hdr_size + sizeof(struct vlan_ethhdr)))
 			return 0;
 
-		vhdr = (struct vlan_ethhdr *)(((uint8_t *)skb->data) +
-					      hdr_size);
+		vhdr = (struct vlan_ethhdr *)(skb->data + hdr_size);
 		vid = ntohs(vhdr->h_vlan_TCI) & VLAN_VID_MASK;
 	}
 
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index eef7cc7..15d67ab 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -117,10 +117,15 @@ batadv_gw_get_best_gw_node(struct batadv_priv *bat_priv)
 	struct hlist_node *node;
 	struct batadv_gw_node *gw_node, *curr_gw = NULL;
 	uint32_t max_gw_factor = 0, tmp_gw_factor = 0;
+	uint32_t gw_divisor;
 	uint8_t max_tq = 0;
 	int down, up;
+	uint8_t tq_avg;
 	struct batadv_orig_node *orig_node;
 
+	gw_divisor = BATADV_TQ_LOCAL_WINDOW_SIZE * BATADV_TQ_LOCAL_WINDOW_SIZE;
+	gw_divisor *= 64;
+
 	rcu_read_lock();
 	hlist_for_each_entry_rcu(gw_node, node, &bat_priv->gw.list, list) {
 		if (gw_node->deleted)
@@ -134,19 +139,19 @@ batadv_gw_get_best_gw_node(struct batadv_priv *bat_priv)
 		if (!atomic_inc_not_zero(&gw_node->refcount))
 			goto next;
 
+		tq_avg = router->tq_avg;
+
 		switch (atomic_read(&bat_priv->gw_sel_class)) {
 		case 1: /* fast connection */
 			batadv_gw_bandwidth_to_kbit(orig_node->gw_flags,
 						    &down, &up);
 
-			tmp_gw_factor = (router->tq_avg * router->tq_avg *
-					 down * 100 * 100) /
-					 (BATADV_TQ_LOCAL_WINDOW_SIZE *
-					  BATADV_TQ_LOCAL_WINDOW_SIZE * 64);
+			tmp_gw_factor = tq_avg * tq_avg * down * 100 * 100;
+			tmp_gw_factor /= gw_divisor;
 
 			if ((tmp_gw_factor > max_gw_factor) ||
 			    ((tmp_gw_factor == max_gw_factor) &&
-			     (router->tq_avg > max_tq))) {
+			     (tq_avg > max_tq))) {
 				if (curr_gw)
 					batadv_gw_node_free_ref(curr_gw);
 				curr_gw = gw_node;
@@ -161,7 +166,7 @@ batadv_gw_get_best_gw_node(struct batadv_priv *bat_priv)
 			  *     soon as a better gateway appears which has
 			  *     $routing_class more tq points)
 			  */
-			if (router->tq_avg > max_tq) {
+			if (tq_avg > max_tq) {
 				if (curr_gw)
 					batadv_gw_node_free_ref(curr_gw);
 				curr_gw = gw_node;
@@ -170,8 +175,8 @@ batadv_gw_get_best_gw_node(struct batadv_priv *bat_priv)
 			break;
 		}
 
-		if (router->tq_avg > max_tq)
-			max_tq = router->tq_avg;
+		if (tq_avg > max_tq)
+			max_tq = tq_avg;
 
 		if (tmp_gw_factor > max_gw_factor)
 			max_gw_factor = tmp_gw_factor;
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 4961278..9f933c9 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -981,8 +981,7 @@ static int batadv_check_unicast_ttvn(struct batadv_priv *bat_priv,
 		} else {
 			memcpy(unicast_packet->dest, orig_node->orig,
 			       ETH_ALEN);
-			curr_ttvn = (uint8_t)
-				atomic_read(&orig_node->last_ttvn);
+			curr_ttvn = (uint8_t)atomic_read(&orig_node->last_ttvn);
 			batadv_orig_node_free_ref(orig_node);
 		}
 
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index b01049a..cb429d1 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -1559,6 +1559,7 @@ batadv_send_other_tt_response(struct batadv_priv *bat_priv,
 	uint16_t tt_len, tt_tot;
 	struct sk_buff *skb = NULL;
 	struct batadv_tt_query_packet *tt_response;
+	uint8_t *packet_pos;
 	size_t len;
 
 	batadv_dbg(BATADV_DBG_TT, bat_priv,
@@ -1612,8 +1613,8 @@ batadv_send_other_tt_response(struct batadv_priv *bat_priv,
 			goto unlock;
 
 		skb_reserve(skb, ETH_HLEN);
-		tt_response = (struct batadv_tt_query_packet *)skb_put(skb,
-								       len);
+		packet_pos = skb_put(skb, len);
+		tt_response = (struct batadv_tt_query_packet *)packet_pos;
 		tt_response->ttvn = req_ttvn;
 		tt_response->tt_data = htons(tt_tot);
 
@@ -1692,6 +1693,7 @@ batadv_send_my_tt_response(struct batadv_priv *bat_priv,
 	uint16_t tt_len, tt_tot;
 	struct sk_buff *skb = NULL;
 	struct batadv_tt_query_packet *tt_response;
+	uint8_t *packet_pos;
 	size_t len;
 
 	batadv_dbg(BATADV_DBG_TT, bat_priv,
@@ -1738,8 +1740,8 @@ batadv_send_my_tt_response(struct batadv_priv *bat_priv,
 			goto unlock;
 
 		skb_reserve(skb, ETH_HLEN);
-		tt_response = (struct batadv_tt_query_packet *)skb_put(skb,
-								       len);
+		packet_pos = skb_put(skb, len);
+		tt_response = (struct batadv_tt_query_packet *)packet_pos;
 		tt_response->ttvn = req_ttvn;
 		tt_response->tt_data = htons(tt_tot);
 
diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index d7904bd..f397232 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -39,6 +39,7 @@ batadv_frag_merge_packet(struct list_head *head,
 	struct batadv_unicast_packet *unicast_packet;
 	int hdr_len = sizeof(*unicast_packet);
 	int uni_diff = sizeof(*up) - hdr_len;
+	uint8_t *packet_pos;
 
 	up = (struct batadv_unicast_frag_packet *)skb->data;
 	/* set skb to the first part and tmp_skb to the second part */
@@ -65,8 +66,8 @@ batadv_frag_merge_packet(struct list_head *head,
 	kfree_skb(tmp_skb);
 
 	memmove(skb->data + uni_diff, skb->data, hdr_len);
-	unicast_packet = (struct batadv_unicast_packet *)skb_pull(skb,
-								  uni_diff);
+	packet_pos = skb_pull(skb, uni_diff);
+	unicast_packet = (struct batadv_unicast_packet *)packet_pos;
 	unicast_packet->header.packet_type = BATADV_UNICAST;
 
 	return skb;
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index 55cc51b..5abd145 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -578,6 +578,7 @@ static int batadv_generate_vis_packet(struct batadv_priv *bat_priv)
 	struct batadv_vis_packet *packet;
 	struct batadv_vis_info_entry *entry;
 	struct batadv_tt_common_entry *tt_common_entry;
+	uint8_t *packet_pos;
 	int best_tq = -1;
 	uint32_t i;
 
@@ -618,8 +619,8 @@ static int batadv_generate_vis_packet(struct batadv_priv *bat_priv)
 				goto next;
 
 			/* fill one entry into buffer. */
-			entry = (struct batadv_vis_info_entry *)
-				      skb_put(info->skb_packet, sizeof(*entry));
+			packet_pos = skb_put(info->skb_packet, sizeof(*entry));
+			entry = (struct batadv_vis_info_entry *)packet_pos;
 			memcpy(entry->src,
 			       router->if_incoming->net_dev->dev_addr,
 			       ETH_ALEN);
@@ -644,9 +645,8 @@ next:
 		rcu_read_lock();
 		hlist_for_each_entry_rcu(tt_common_entry, node, head,
 					 hash_entry) {
-			entry = (struct batadv_vis_info_entry *)
-					skb_put(info->skb_packet,
-						sizeof(*entry));
+			packet_pos = skb_put(info->skb_packet, sizeof(*entry));
+			entry = (struct batadv_vis_info_entry *)packet_pos;
 			memset(entry->src, 0, ETH_ALEN);
 			memcpy(entry->dest, tt_common_entry->addr, ETH_ALEN);
 			entry->quality = 0; /* 0 means TT */
-- 
1.7.9.4
