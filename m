From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 03/14] batman-adv: split out router from orig_node
Date: Mon, 13 Jan 2014 23:31:27 +0100
Message-ID: <1389652298-472-4-git-send-email-antonio@meshcoding.com>
References: <1389652298-472-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <simon@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:23702 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752419AbaAMWd0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 17:33:26 -0500
In-Reply-To: <1389652298-472-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <simon@open-mesh.com>

For the network wide multi interface optimization there are different
routers for each outgoing interface (outgoing from the OGM perspective,
incoming for payload traffic). To reflect this, change the router and
associated data to a list of routers.

While at it, rename batadv_orig_node_get_router() to
batadv_orig_router_get() to follow the new naming scheme.

Signed-off-by: Simon Wunderlich <simon@open-mesh.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/bat_iv_ogm.c            | 454 +++++++++++++++++++--------------
 net/batman-adv/distributed-arp-table.c |   3 +-
 net/batman-adv/gateway_client.c        |  11 +-
 net/batman-adv/icmp_socket.c           |   3 +-
 net/batman-adv/network-coding.c        |  25 +-
 net/batman-adv/originator.c            | 242 +++++++++++++++++-
 net/batman-adv/originator.h            |  12 +-
 net/batman-adv/routing.c               |  38 ++-
 net/batman-adv/routing.h               |   1 +
 net/batman-adv/translation-table.c     |   3 +-
 net/batman-adv/types.h                 |  32 ++-
 11 files changed, 605 insertions(+), 219 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 157cc11..1f9fe42 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -907,21 +907,21 @@ static void batadv_iv_ogm_schedule(struct batadv_hard_iface *hard_iface)
  *  originator
  * @bat_priv: the bat priv with all the soft interface information
  * @orig_node: the orig node who originally emitted the ogm packet
+ * @orig_ifinfo: ifinfo for the outgoing interface of the orig_node
  * @ethhdr: Ethernet header of the OGM
  * @batadv_ogm_packet: the ogm packet
  * @if_incoming: interface where the packet was received
  * @if_outgoing: interface for which the retransmission should be considered
- * @tt_buff: pointer to the tt buffer
  * @dup_status: the duplicate status of this ogm packet.
  */
 static void
 batadv_iv_ogm_orig_update(struct batadv_priv *bat_priv,
 			  struct batadv_orig_node *orig_node,
+			  struct batadv_orig_ifinfo *orig_ifinfo,
 			  const struct ethhdr *ethhdr,
 			  const struct batadv_ogm_packet *batadv_ogm_packet,
 			  struct batadv_hard_iface *if_incoming,
 			  struct batadv_hard_iface *if_outgoing,
-			  const unsigned char *tt_buff,
 			  enum batadv_dup_status dup_status)
 {
 	struct batadv_neigh_ifinfo *neigh_ifinfo = NULL;
@@ -1004,14 +1004,14 @@ batadv_iv_ogm_orig_update(struct batadv_priv *bat_priv,
 	spin_unlock_bh(&neigh_node->ifinfo_lock);
 
 	if (dup_status == BATADV_NO_DUP) {
-		orig_node->last_ttl = batadv_ogm_packet->ttl;
+		orig_ifinfo->last_ttl = batadv_ogm_packet->ttl;
 		neigh_ifinfo->last_ttl = batadv_ogm_packet->ttl;
 	}
 
 	/* if this neighbor already is our next hop there is nothing
 	 * to change
 	 */
-	router = batadv_orig_node_get_router(orig_node);
+	router = batadv_orig_router_get(orig_node, if_outgoing);
 	if (router == neigh_node)
 		goto out;
 
@@ -1048,7 +1048,7 @@ batadv_iv_ogm_orig_update(struct batadv_priv *bat_priv,
 			goto out;
 	}
 
-	batadv_update_route(bat_priv, orig_node, neigh_node);
+	batadv_update_route(bat_priv, orig_node, if_outgoing, neigh_node);
 	goto out;
 
 unlock:
@@ -1209,6 +1209,7 @@ batadv_iv_ogm_update_seqnos(const struct ethhdr *ethhdr,
 {
 	struct batadv_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
 	struct batadv_orig_node *orig_node;
+	struct batadv_orig_ifinfo *orig_ifinfo = NULL;
 	struct batadv_neigh_node *neigh_node;
 	struct batadv_neigh_ifinfo *neigh_ifinfo;
 	int is_dup;
@@ -1225,13 +1226,19 @@ batadv_iv_ogm_update_seqnos(const struct ethhdr *ethhdr,
 	if (!orig_node)
 		return BATADV_NO_DUP;
 
+	orig_ifinfo = batadv_orig_ifinfo_new(orig_node, if_outgoing);
+	if (WARN_ON(!orig_ifinfo)) {
+		batadv_orig_node_free_ref(orig_node);
+		return 0;
+	}
+
 	spin_lock_bh(&orig_node->bat_iv.ogm_cnt_lock);
-	seq_diff = seqno - orig_node->last_real_seqno;
+	seq_diff = seqno - orig_ifinfo->last_real_seqno;
 
 	/* signalize caller that the packet is to be dropped. */
 	if (!hlist_empty(&orig_node->neigh_list) &&
 	    batadv_window_protected(bat_priv, seq_diff,
-				    &orig_node->batman_seqno_reset)) {
+				    &orig_ifinfo->batman_seqno_reset)) {
 		ret = BATADV_PROTECTED;
 		goto out;
 	}
@@ -1245,7 +1252,7 @@ batadv_iv_ogm_update_seqnos(const struct ethhdr *ethhdr,
 
 		neigh_addr = neigh_node->addr;
 		is_dup = batadv_test_bit(neigh_ifinfo->bat_iv.real_bits,
-					 orig_node->last_real_seqno,
+					 orig_ifinfo->last_real_seqno,
 					 seqno);
 
 		if (batadv_compare_eth(neigh_addr, ethhdr->h_source) &&
@@ -1273,163 +1280,65 @@ batadv_iv_ogm_update_seqnos(const struct ethhdr *ethhdr,
 
 	if (need_update) {
 		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
-			   "updating last_seqno: old %u, new %u\n",
-			   orig_node->last_real_seqno, seqno);
-		orig_node->last_real_seqno = seqno;
+			   "%s updating last_seqno: old %u, new %u\n",
+			   if_outgoing ? if_outgoing->net_dev->name : "DEFAULT",
+			   orig_ifinfo->last_real_seqno, seqno);
+		orig_ifinfo->last_real_seqno = seqno;
 	}
 
 out:
 	spin_unlock_bh(&orig_node->bat_iv.ogm_cnt_lock);
 	batadv_orig_node_free_ref(orig_node);
+	if (orig_ifinfo)
+		batadv_orig_ifinfo_free_ref(orig_ifinfo);
 	return ret;
 }
 
-static void batadv_iv_ogm_process(const struct ethhdr *ethhdr,
-				  struct batadv_ogm_packet *batadv_ogm_packet,
-				  const unsigned char *tt_buff,
-				  struct batadv_hard_iface *if_incoming)
+
+/**
+ * batadv_iv_ogm_process_per_outif - process a batman iv OGM for an outgoing if
+ * @skb: the skb containing the OGM
+ * @orig_node: the (cached) orig node for the originator of this OGM
+ * @if_incoming: the interface where this packet was received
+ * @if_outgoing: the interface for which the packet should be considered
+ */
+static void
+batadv_iv_ogm_process_per_outif(const struct sk_buff *skb, int ogm_offset,
+				struct batadv_orig_node *orig_node,
+				struct batadv_hard_iface *if_incoming,
+				struct batadv_hard_iface *if_outgoing)
 {
 	struct batadv_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
-	struct batadv_hard_iface *hard_iface;
-	struct batadv_orig_node *orig_neigh_node, *orig_node, *orig_node_tmp;
 	struct batadv_neigh_node *router = NULL, *router_router = NULL;
+	struct batadv_orig_node *orig_neigh_node;
+	struct batadv_orig_ifinfo *orig_ifinfo;
 	struct batadv_neigh_node *orig_neigh_router = NULL;
 	struct batadv_neigh_ifinfo *router_ifinfo = NULL;
-	int has_directlink_flag;
-	int is_my_addr = 0, is_my_orig = 0, is_my_oldorig = 0;
-	int is_bidirect;
-	bool is_single_hop_neigh = false;
-	bool is_from_best_next_hop = false;
-	int sameseq, similar_ttl;
+	struct batadv_ogm_packet *ogm_packet;
 	enum batadv_dup_status dup_status;
-	uint32_t if_incoming_seqno;
+	bool is_from_best_next_hop = false;
+	bool is_single_hop_neigh = false;
+	bool sameseq, similar_ttl;
+	struct sk_buff *skb_priv;
+	struct ethhdr *ethhdr;
 	uint8_t *prev_sender;
+	int is_bidirect;
 
-	/* Silently drop when the batman packet is actually not a
-	 * correct packet.
-	 *
-	 * This might happen if a packet is padded (e.g. Ethernet has a
-	 * minimum frame length of 64 byte) and the aggregation interprets
-	 * it as an additional length.
-	 *
-	 * TODO: A more sane solution would be to have a bit in the
-	 * batadv_ogm_packet to detect whether the packet is the last
-	 * packet in an aggregation.  Here we expect that the padding
-	 * is always zero (or not 0x01)
+	/* create a private copy of the skb, as some functions change tq value
+	 * and/or flags.
 	 */
-	if (batadv_ogm_packet->packet_type != BATADV_IV_OGM)
+	skb_priv = skb_copy(skb, GFP_ATOMIC);
+	if (!skb_priv)
 		return;
 
-	/* could be changed by schedule_own_packet() */
-	if_incoming_seqno = atomic_read(&if_incoming->bat_iv.ogm_seqno);
+	ethhdr = eth_hdr(skb_priv);
+	ogm_packet = (struct batadv_ogm_packet *)(skb_priv->data + ogm_offset);
 
-	if (batadv_ogm_packet->flags & BATADV_DIRECTLINK)
-		has_directlink_flag = 1;
-	else
-		has_directlink_flag = 0;
-
-	if (batadv_compare_eth(ethhdr->h_source, batadv_ogm_packet->orig))
+	dup_status = batadv_iv_ogm_update_seqnos(ethhdr, ogm_packet,
+						 if_incoming, if_outgoing);
+	if (batadv_compare_eth(ethhdr->h_source, ogm_packet->orig))
 		is_single_hop_neigh = true;
 
-	batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
-		   "Received BATMAN packet via NB: %pM, IF: %s [%pM] (from OG: %pM, via prev OG: %pM, seqno %u, tq %d, TTL %d, V %d, IDF %d)\n",
-		   ethhdr->h_source, if_incoming->net_dev->name,
-		   if_incoming->net_dev->dev_addr, batadv_ogm_packet->orig,
-		   batadv_ogm_packet->prev_sender,
-		   ntohl(batadv_ogm_packet->seqno), batadv_ogm_packet->tq,
-		   batadv_ogm_packet->ttl,
-		   batadv_ogm_packet->version, has_directlink_flag);
-
-	rcu_read_lock();
-	list_for_each_entry_rcu(hard_iface, &batadv_hardif_list, list) {
-		if (hard_iface->if_status != BATADV_IF_ACTIVE)
-			continue;
-
-		if (hard_iface->soft_iface != if_incoming->soft_iface)
-			continue;
-
-		if (batadv_compare_eth(ethhdr->h_source,
-				       hard_iface->net_dev->dev_addr))
-			is_my_addr = 1;
-
-		if (batadv_compare_eth(batadv_ogm_packet->orig,
-				       hard_iface->net_dev->dev_addr))
-			is_my_orig = 1;
-
-		if (batadv_compare_eth(batadv_ogm_packet->prev_sender,
-				       hard_iface->net_dev->dev_addr))
-			is_my_oldorig = 1;
-	}
-	rcu_read_unlock();
-
-	if (is_my_addr) {
-		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
-			   "Drop packet: received my own broadcast (sender: %pM)\n",
-			   ethhdr->h_source);
-		return;
-	}
-
-	if (is_my_orig) {
-		unsigned long *word;
-		int offset;
-		int32_t bit_pos;
-		int16_t if_num;
-		uint8_t *weight;
-
-		orig_neigh_node = batadv_iv_ogm_orig_get(bat_priv,
-							 ethhdr->h_source);
-		if (!orig_neigh_node)
-			return;
-
-		/* neighbor has to indicate direct link and it has to
-		 * come via the corresponding interface
-		 * save packet seqno for bidirectional check
-		 */
-		if (has_directlink_flag &&
-		    batadv_compare_eth(if_incoming->net_dev->dev_addr,
-				       batadv_ogm_packet->orig)) {
-			if_num = if_incoming->if_num;
-			offset = if_num * BATADV_NUM_WORDS;
-
-			spin_lock_bh(&orig_neigh_node->bat_iv.ogm_cnt_lock);
-			word = &(orig_neigh_node->bat_iv.bcast_own[offset]);
-			bit_pos = if_incoming_seqno - 2;
-			bit_pos -= ntohl(batadv_ogm_packet->seqno);
-			batadv_set_bit(word, bit_pos);
-			weight = &orig_neigh_node->bat_iv.bcast_own_sum[if_num];
-			*weight = bitmap_weight(word,
-						BATADV_TQ_LOCAL_WINDOW_SIZE);
-			spin_unlock_bh(&orig_neigh_node->bat_iv.ogm_cnt_lock);
-		}
-
-		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
-			   "Drop packet: originator packet from myself (via neighbor)\n");
-		batadv_orig_node_free_ref(orig_neigh_node);
-		return;
-	}
-
-	if (is_my_oldorig) {
-		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
-			   "Drop packet: ignoring all rebroadcast echos (sender: %pM)\n",
-			   ethhdr->h_source);
-		return;
-	}
-
-	if (batadv_ogm_packet->flags & BATADV_NOT_BEST_NEXT_HOP) {
-		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
-			   "Drop packet: ignoring all packets not forwarded from the best next hop (sender: %pM)\n",
-			   ethhdr->h_source);
-		return;
-	}
-
-	orig_node = batadv_iv_ogm_orig_get(bat_priv, batadv_ogm_packet->orig);
-	if (!orig_node)
-		return;
-
-	dup_status = batadv_iv_ogm_update_seqnos(ethhdr, batadv_ogm_packet,
-						 if_incoming,
-						 BATADV_IF_DEFAULT);
-
 	if (dup_status == BATADV_PROTECTED) {
 		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "Drop packet: packet within seqno protection time (sender: %pM)\n",
@@ -1437,29 +1346,28 @@ static void batadv_iv_ogm_process(const struct ethhdr *ethhdr,
 		goto out;
 	}
 
-	if (batadv_ogm_packet->tq == 0) {
+	if (ogm_packet->tq == 0) {
 		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "Drop packet: originator packet with tq equal 0\n");
 		goto out;
 	}
 
-	router = batadv_orig_node_get_router(orig_node);
+	router = batadv_orig_router_get(orig_node, if_outgoing);
 	if (router) {
-		orig_node_tmp = router->orig_node;
-		router_router = batadv_orig_node_get_router(orig_node_tmp);
-		router_ifinfo = batadv_neigh_ifinfo_get(router,
-							BATADV_IF_DEFAULT);
+		router_router = batadv_orig_router_get(router->orig_node,
+						       if_outgoing);
+		router_ifinfo = batadv_neigh_ifinfo_get(router, if_outgoing);
 	}
 
-	if ((router && router_ifinfo->bat_iv.tq_avg != 0) &&
+	if ((router_ifinfo && router_ifinfo->bat_iv.tq_avg != 0) &&
 	    (batadv_compare_eth(router->addr, ethhdr->h_source)))
 		is_from_best_next_hop = true;
 
-	prev_sender = batadv_ogm_packet->prev_sender;
+	prev_sender = ogm_packet->prev_sender;
 	/* avoid temporary routing loops */
 	if (router && router_router &&
 	    (batadv_compare_eth(router->addr, prev_sender)) &&
-	    !(batadv_compare_eth(batadv_ogm_packet->orig, prev_sender)) &&
+	    !(batadv_compare_eth(ogm_packet->orig, prev_sender)) &&
 	    (batadv_compare_eth(router->addr, router_router->addr))) {
 		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "Drop packet: ignoring all rebroadcast packets that may make me loop (sender: %pM)\n",
@@ -1467,7 +1375,8 @@ static void batadv_iv_ogm_process(const struct ethhdr *ethhdr,
 		goto out;
 	}
 
-	batadv_tvlv_ogm_receive(bat_priv, batadv_ogm_packet, orig_node);
+	if (if_outgoing == BATADV_IF_DEFAULT)
+		batadv_tvlv_ogm_receive(bat_priv, ogm_packet, orig_node);
 
 	/* if sender is a direct neighbor the sender mac equals
 	 * originator mac
@@ -1483,9 +1392,10 @@ static void batadv_iv_ogm_process(const struct ethhdr *ethhdr,
 
 	/* Update nc_nodes of the originator */
 	batadv_nc_update_nc_node(bat_priv, orig_node, orig_neigh_node,
-				 batadv_ogm_packet, is_single_hop_neigh);
+				 ogm_packet, is_single_hop_neigh);
 
-	orig_neigh_router = batadv_orig_node_get_router(orig_neigh_node);
+	orig_neigh_router = batadv_orig_router_get(orig_neigh_node,
+						   if_outgoing);
 
 	/* drop packet if sender is not a direct neighbor and if we
 	 * don't route towards it
@@ -1497,25 +1407,41 @@ static void batadv_iv_ogm_process(const struct ethhdr *ethhdr,
 	}
 
 	is_bidirect = batadv_iv_ogm_calc_tq(orig_node, orig_neigh_node,
-					    batadv_ogm_packet, if_incoming,
-					    BATADV_IF_DEFAULT);
+					    ogm_packet, if_incoming,
+					    if_outgoing);
 
 	/* update ranking if it is not a duplicate or has the same
 	 * seqno and similar ttl as the non-duplicate
 	 */
-	sameseq = orig_node->last_real_seqno == ntohl(batadv_ogm_packet->seqno);
-	similar_ttl = orig_node->last_ttl - 3 <= batadv_ogm_packet->ttl;
+	orig_ifinfo = batadv_orig_ifinfo_new(orig_node, if_outgoing);
+	if (!orig_ifinfo)
+		goto out_neigh;
+
+	sameseq = orig_ifinfo->last_real_seqno == ntohl(ogm_packet->seqno);
+	similar_ttl = (orig_ifinfo->last_ttl - 3) <= ogm_packet->ttl;
+
 	if (is_bidirect && ((dup_status == BATADV_NO_DUP) ||
-			    (sameseq && similar_ttl)))
-		batadv_iv_ogm_orig_update(bat_priv, orig_node, ethhdr,
-					  batadv_ogm_packet, if_incoming,
-					  BATADV_IF_DEFAULT, tt_buff,
-					  dup_status);
+			    (sameseq && similar_ttl))) {
+		batadv_iv_ogm_orig_update(bat_priv, orig_node,
+					  orig_ifinfo, ethhdr,
+					  ogm_packet, if_incoming,
+					  if_outgoing, dup_status);
+	}
+	batadv_orig_ifinfo_free_ref(orig_ifinfo);
 
 	/* is single hop (direct) neighbor */
 	if (is_single_hop_neigh) {
+		/* OGMs from secondary interfaces should only scheduled once
+		 * per interface where it has been received, not multiple times
+		 */
+		if ((ogm_packet->ttl <= 2) &&
+		    (if_incoming != if_outgoing)) {
+			batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
+				   "Drop packet: OGM from secondary interface and wrong outgoing interface\n");
+			goto out_neigh;
+		}
 		/* mark direct link on incoming interface */
-		batadv_iv_ogm_forward(orig_node, ethhdr, batadv_ogm_packet,
+		batadv_iv_ogm_forward(orig_node, ethhdr, ogm_packet,
 				      is_single_hop_neigh,
 				      is_from_best_next_hop, if_incoming);
 
@@ -1537,9 +1463,14 @@ static void batadv_iv_ogm_process(const struct ethhdr *ethhdr,
 		goto out_neigh;
 	}
 
+	/* only forward the packet on the default interface until the
+	 * OGM forwarding has been reworked to send on specific interfaces.
+	 */
+	if (if_outgoing != BATADV_IF_DEFAULT)
+		goto out_neigh;
 	batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 		   "Forwarding packet: rebroadcast originator packet\n");
-	batadv_iv_ogm_forward(orig_node, ethhdr, batadv_ogm_packet,
+	batadv_iv_ogm_forward(orig_node, ethhdr, ogm_packet,
 			      is_single_hop_neigh, is_from_best_next_hop,
 			      if_incoming);
 
@@ -1554,6 +1485,165 @@ out:
 	if (orig_neigh_router)
 		batadv_neigh_node_free_ref(orig_neigh_router);
 
+	kfree_skb(skb_priv);
+}
+
+/**
+ * batadv_iv_ogm_process - process an incoming batman iv OGM
+ * @skb: the skb containing the OGM
+ * @ogm_offset: offset to the OGM which should be processed (for aggregates)
+ * @if_incoming: the interface where this packet was receved
+ */
+static void batadv_iv_ogm_process(const struct sk_buff *skb, int ogm_offset,
+				  struct batadv_hard_iface *if_incoming)
+{
+	struct batadv_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
+	struct batadv_orig_node *orig_neigh_node, *orig_node;
+	struct batadv_hard_iface *hard_iface;
+	struct batadv_ogm_packet *ogm_packet;
+	uint32_t if_incoming_seqno;
+	bool has_directlink_flag;
+	struct ethhdr *ethhdr;
+	bool is_my_oldorig = false;
+	bool is_my_addr = false;
+	bool is_my_orig = false;
+
+	ogm_packet = (struct batadv_ogm_packet *)(skb->data + ogm_offset);
+	ethhdr = eth_hdr(skb);
+
+	/* Silently drop when the batman packet is actually not a
+	 * correct packet.
+	 *
+	 * This might happen if a packet is padded (e.g. Ethernet has a
+	 * minimum frame length of 64 byte) and the aggregation interprets
+	 * it as an additional length.
+	 *
+	 * TODO: A more sane solution would be to have a bit in the
+	 * batadv_ogm_packet to detect whether the packet is the last
+	 * packet in an aggregation.  Here we expect that the padding
+	 * is always zero (or not 0x01)
+	 */
+	if (ogm_packet->packet_type != BATADV_IV_OGM)
+		return;
+
+	/* could be changed by schedule_own_packet() */
+	if_incoming_seqno = atomic_read(&if_incoming->bat_iv.ogm_seqno);
+
+	if (ogm_packet->flags & BATADV_DIRECTLINK)
+		has_directlink_flag = true;
+	else
+		has_directlink_flag = false;
+
+	batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
+		   "Received BATMAN packet via NB: %pM, IF: %s [%pM] (from OG: %pM, via prev OG: %pM, seqno %u, tq %d, TTL %d, V %d, IDF %d)\n",
+		   ethhdr->h_source, if_incoming->net_dev->name,
+		   if_incoming->net_dev->dev_addr, ogm_packet->orig,
+		   ogm_packet->prev_sender, ntohl(ogm_packet->seqno),
+		   ogm_packet->tq, ogm_packet->ttl,
+		   ogm_packet->version, has_directlink_flag);
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(hard_iface, &batadv_hardif_list, list) {
+		if (hard_iface->if_status != BATADV_IF_ACTIVE)
+			continue;
+
+		if (hard_iface->soft_iface != if_incoming->soft_iface)
+			continue;
+
+		if (batadv_compare_eth(ethhdr->h_source,
+				       hard_iface->net_dev->dev_addr))
+			is_my_addr = true;
+
+		if (batadv_compare_eth(ogm_packet->orig,
+				       hard_iface->net_dev->dev_addr))
+			is_my_orig = true;
+
+		if (batadv_compare_eth(ogm_packet->prev_sender,
+				       hard_iface->net_dev->dev_addr))
+			is_my_oldorig = true;
+	}
+	rcu_read_unlock();
+
+	if (is_my_addr) {
+		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
+			   "Drop packet: received my own broadcast (sender: %pM)\n",
+			   ethhdr->h_source);
+		return;
+	}
+
+	if (is_my_orig) {
+		unsigned long *word;
+		int offset;
+		int32_t bit_pos;
+		int16_t if_num;
+		uint8_t *weight;
+
+		orig_neigh_node = batadv_iv_ogm_orig_get(bat_priv,
+							 ethhdr->h_source);
+		if (!orig_neigh_node)
+			return;
+
+		/* neighbor has to indicate direct link and it has to
+		 * come via the corresponding interface
+		 * save packet seqno for bidirectional check
+		 */
+		if (has_directlink_flag &&
+		    batadv_compare_eth(if_incoming->net_dev->dev_addr,
+				       ogm_packet->orig)) {
+			if_num = if_incoming->if_num;
+			offset = if_num * BATADV_NUM_WORDS;
+
+			spin_lock_bh(&orig_neigh_node->bat_iv.ogm_cnt_lock);
+			word = &(orig_neigh_node->bat_iv.bcast_own[offset]);
+			bit_pos = if_incoming_seqno - 2;
+			bit_pos -= ntohl(ogm_packet->seqno);
+			batadv_set_bit(word, bit_pos);
+			weight = &orig_neigh_node->bat_iv.bcast_own_sum[if_num];
+			*weight = bitmap_weight(word,
+						BATADV_TQ_LOCAL_WINDOW_SIZE);
+			spin_unlock_bh(&orig_neigh_node->bat_iv.ogm_cnt_lock);
+		}
+
+		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
+			   "Drop packet: originator packet from myself (via neighbor)\n");
+		batadv_orig_node_free_ref(orig_neigh_node);
+		return;
+	}
+
+	if (is_my_oldorig) {
+		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
+			   "Drop packet: ignoring all rebroadcast echos (sender: %pM)\n",
+			   ethhdr->h_source);
+		return;
+	}
+
+	if (ogm_packet->flags & BATADV_NOT_BEST_NEXT_HOP) {
+		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
+			   "Drop packet: ignoring all packets not forwarded from the best next hop (sender: %pM)\n",
+			   ethhdr->h_source);
+		return;
+	}
+
+	orig_node = batadv_iv_ogm_orig_get(bat_priv, ogm_packet->orig);
+	if (!orig_node)
+		return;
+
+	batadv_iv_ogm_process_per_outif(skb, ogm_offset, orig_node,
+					if_incoming, BATADV_IF_DEFAULT);
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(hard_iface, &batadv_hardif_list, list) {
+		if (hard_iface->if_status != BATADV_IF_ACTIVE)
+			continue;
+
+		if (hard_iface->soft_iface != bat_priv->soft_iface)
+			continue;
+
+		batadv_iv_ogm_process_per_outif(skb, ogm_offset, orig_node,
+						if_incoming, hard_iface);
+	}
+	rcu_read_unlock();
+
 	batadv_orig_node_free_ref(orig_node);
 }
 
@@ -1561,11 +1651,9 @@ static int batadv_iv_ogm_receive(struct sk_buff *skb,
 				 struct batadv_hard_iface *if_incoming)
 {
 	struct batadv_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
-	struct batadv_ogm_packet *batadv_ogm_packet;
-	struct ethhdr *ethhdr;
-	int buff_pos = 0, packet_len;
-	unsigned char *tvlv_buff, *packet_buff;
+	struct batadv_ogm_packet *ogm_packet;
 	uint8_t *packet_pos;
+	int ogm_offset;
 	bool ret;
 
 	ret = batadv_check_management_packet(skb, if_incoming, BATADV_OGM_HLEN);
@@ -1582,24 +1670,19 @@ static int batadv_iv_ogm_receive(struct sk_buff *skb,
 	batadv_add_counter(bat_priv, BATADV_CNT_MGMT_RX_BYTES,
 			   skb->len + ETH_HLEN);
 
-	packet_len = skb_headlen(skb);
-	ethhdr = eth_hdr(skb);
-	packet_buff = skb->data;
-	batadv_ogm_packet = (struct batadv_ogm_packet *)packet_buff;
+	ogm_offset = 0;
+	ogm_packet = (struct batadv_ogm_packet *)skb->data;
 
 	/* unpack the aggregated packets and process them one by one */
-	while (batadv_iv_ogm_aggr_packet(buff_pos, packet_len,
-					 batadv_ogm_packet->tvlv_len)) {
-		tvlv_buff = packet_buff + buff_pos + BATADV_OGM_HLEN;
+	while (batadv_iv_ogm_aggr_packet(ogm_offset, skb_headlen(skb),
+					 ogm_packet->tvlv_len)) {
+		batadv_iv_ogm_process(skb, ogm_offset, if_incoming);
 
-		batadv_iv_ogm_process(ethhdr, batadv_ogm_packet,
-				      tvlv_buff, if_incoming);
+		ogm_offset += BATADV_OGM_HLEN;
+		ogm_offset += ntohs(ogm_packet->tvlv_len);
 
-		buff_pos += BATADV_OGM_HLEN;
-		buff_pos += ntohs(batadv_ogm_packet->tvlv_len);
-
-		packet_pos = packet_buff + buff_pos;
-		batadv_ogm_packet = (struct batadv_ogm_packet *)packet_pos;
+		packet_pos = skb->data + ogm_offset;
+		ogm_packet = (struct batadv_ogm_packet *)packet_pos;
 	}
 
 	kfree_skb(skb);
@@ -1661,7 +1744,8 @@ static void batadv_iv_ogm_orig_print(struct batadv_priv *bat_priv,
 
 		rcu_read_lock();
 		hlist_for_each_entry_rcu(orig_node, head, hash_entry) {
-			neigh_node = batadv_orig_node_get_router(orig_node);
+			neigh_node = batadv_orig_router_get(orig_node,
+							    BATADV_IF_DEFAULT);
 			if (!neigh_node)
 				continue;
 
diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index 997ae6a..1d214cd 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -589,7 +589,8 @@ static bool batadv_dat_send_data(struct batadv_priv *bat_priv,
 		if (cand[i].type == BATADV_DAT_CANDIDATE_NOT_FOUND)
 			continue;
 
-		neigh_node = batadv_orig_node_get_router(cand[i].orig_node);
+		neigh_node = batadv_orig_router_get(cand[i].orig_node,
+						    BATADV_IF_DEFAULT);
 		if (!neigh_node)
 			goto free_orig;
 
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 4e8f5b1..9ece204 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -146,7 +146,7 @@ batadv_gw_get_best_gw_node(struct batadv_priv *bat_priv)
 			continue;
 
 		orig_node = gw_node->orig_node;
-		router = batadv_orig_node_get_router(orig_node);
+		router = batadv_orig_router_get(orig_node, BATADV_IF_DEFAULT);
 		if (!router)
 			continue;
 
@@ -266,7 +266,8 @@ void batadv_gw_election(struct batadv_priv *bat_priv)
 	if (next_gw) {
 		sprintf(gw_addr, "%pM", next_gw->orig_node->orig);
 
-		router = batadv_orig_node_get_router(next_gw->orig_node);
+		router = batadv_orig_router_get(next_gw->orig_node,
+						BATADV_IF_DEFAULT);
 		if (!router) {
 			batadv_gw_reselect(bat_priv);
 			goto out;
@@ -335,7 +336,7 @@ void batadv_gw_check_election(struct batadv_priv *bat_priv,
 	if (!curr_gw_orig)
 		goto reselect;
 
-	router_gw = batadv_orig_node_get_router(curr_gw_orig);
+	router_gw = batadv_orig_router_get(curr_gw_orig, BATADV_IF_DEFAULT);
 	if (!router_gw)
 		goto reselect;
 
@@ -348,7 +349,7 @@ void batadv_gw_check_election(struct batadv_priv *bat_priv,
 	if (curr_gw_orig == orig_node)
 		goto out;
 
-	router_orig = batadv_orig_node_get_router(orig_node);
+	router_orig = batadv_orig_router_get(orig_node, BATADV_IF_DEFAULT);
 	if (!router_orig)
 		goto out;
 
@@ -576,7 +577,7 @@ static int batadv_write_buffer_text(struct batadv_priv *bat_priv,
 	struct batadv_neigh_ifinfo *router_ifinfo = NULL;
 	int ret = -1;
 
-	router = batadv_orig_node_get_router(gw_node->orig_node);
+	router = batadv_orig_router_get(gw_node->orig_node, BATADV_IF_DEFAULT);
 	if (!router)
 		goto out;
 
diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.c
index 3c08eee..b384cb8 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -215,7 +215,8 @@ static ssize_t batadv_socket_write(struct file *file, const char __user *buff,
 		if (!orig_node)
 			goto dst_unreach;
 
-		neigh_node = batadv_orig_node_get_router(orig_node);
+		neigh_node = batadv_orig_router_get(orig_node,
+						    BATADV_IF_DEFAULT);
 		if (!neigh_node)
 			goto dst_unreach;
 
diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-coding.c
index aec3fa5..6a0b328 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -718,9 +718,21 @@ static bool batadv_can_nc_with_orig(struct batadv_priv *bat_priv,
 				    struct batadv_orig_node *orig_node,
 				    struct batadv_ogm_packet *ogm_packet)
 {
-	if (orig_node->last_real_seqno != ntohl(ogm_packet->seqno))
+	struct batadv_orig_ifinfo *orig_ifinfo;
+	uint32_t last_real_seqno;
+	uint8_t last_ttl;
+
+	orig_ifinfo = batadv_orig_ifinfo_get(orig_node, BATADV_IF_DEFAULT);
+	if (!orig_ifinfo)
 		return false;
-	if (orig_node->last_ttl != ogm_packet->ttl + 1)
+
+	last_ttl = orig_ifinfo->last_ttl;
+	last_real_seqno = orig_ifinfo->last_real_seqno;
+	batadv_orig_ifinfo_free_ref(orig_ifinfo);
+
+	if (last_real_seqno != ntohl(ogm_packet->seqno))
+		return false;
+	if (last_ttl != ogm_packet->ttl + 1)
 		return false;
 	if (!batadv_compare_eth(ogm_packet->orig, ogm_packet->prev_sender))
 		return false;
@@ -1019,7 +1031,11 @@ static bool batadv_nc_code_packets(struct batadv_priv *bat_priv,
 	int coded_size = sizeof(*coded_packet);
 	int header_add = coded_size - unicast_size;
 
-	router_neigh = batadv_orig_node_get_router(neigh_node->orig_node);
+	/* TODO: do we need to consider the outgoing interface for
+	 * coded packets?
+	 */
+	router_neigh = batadv_orig_router_get(neigh_node->orig_node,
+					      BATADV_IF_DEFAULT);
 	if (!router_neigh)
 		goto out;
 
@@ -1029,7 +1045,8 @@ static bool batadv_nc_code_packets(struct batadv_priv *bat_priv,
 		goto out;
 
 	neigh_tmp = nc_packet->neigh_node;
-	router_coding = batadv_orig_node_get_router(neigh_tmp->orig_node);
+	router_coding = batadv_orig_router_get(neigh_tmp->orig_node,
+					       BATADV_IF_DEFAULT);
 	if (!router_coding)
 		goto out;
 
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 1a4725f..b8ef416 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -231,14 +231,31 @@ void batadv_neigh_node_free_ref(struct batadv_neigh_node *neigh_node)
 		call_rcu(&neigh_node->rcu, batadv_neigh_node_free_rcu);
 }
 
-/* increases the refcounter of a found router */
+/**
+ * batadv_orig_node_get_router - router to the originator depending on iface
+ * @orig_node: the orig node for the router
+ * @if_outgoing: the interface where the payload packet has been received or
+ *  the OGM should be sent to
+ *
+ * Returns the neighbor which should be router for this orig_node/iface.
+ *
+ * The object is returned with refcounter increased by 1.
+ */
 struct batadv_neigh_node *
-batadv_orig_node_get_router(struct batadv_orig_node *orig_node)
+batadv_orig_router_get(struct batadv_orig_node *orig_node,
+		       const struct batadv_hard_iface *if_outgoing)
 {
-	struct batadv_neigh_node *router;
+	struct batadv_orig_ifinfo *orig_ifinfo;
+	struct batadv_neigh_node *router = NULL;
 
 	rcu_read_lock();
-	router = rcu_dereference(orig_node->router);
+	hlist_for_each_entry_rcu(orig_ifinfo, &orig_node->ifinfo_list, list) {
+		if (orig_ifinfo->if_outgoing != if_outgoing)
+			continue;
+
+		router = rcu_dereference(orig_ifinfo->router);
+		break;
+	}
 
 	if (router && !atomic_inc_not_zero(&router->refcount))
 		router = NULL;
@@ -248,6 +265,86 @@ batadv_orig_node_get_router(struct batadv_orig_node *orig_node)
 }
 
 /**
+ * batadv_orig_ifinfo_get - find the ifinfo from an orig_node
+ * @orig_node: the orig node to be queried
+ * @if_outgoing: the interface for which the ifinfo should be acquired
+ *
+ * Returns the requested orig_ifinfo or NULL if not found.
+ *
+ * The object is returned with refcounter increased by 1.
+ */
+struct batadv_orig_ifinfo *
+batadv_orig_ifinfo_get(struct batadv_orig_node *orig_node,
+		       struct batadv_hard_iface *if_outgoing)
+{
+	struct batadv_orig_ifinfo *tmp, *orig_ifinfo = NULL;
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(tmp, &orig_node->ifinfo_list,
+				 list) {
+		if (tmp->if_outgoing != if_outgoing)
+			continue;
+
+		if (!atomic_inc_not_zero(&tmp->refcount))
+			continue;
+
+		orig_ifinfo = tmp;
+		break;
+	}
+	rcu_read_unlock();
+
+	return orig_ifinfo;
+}
+
+/**
+ * batadv_orig_ifinfo_new - search and possibly create an orig_ifinfo object
+ * @orig_node: the orig node to be queried
+ * @if_outgoing: the interface for which the ifinfo should be acquired
+ *
+ * Returns NULL in case of failure or the orig_ifinfo object for the if_outgoing
+ * interface otherwise. The object is created and added to the list
+ * if it does not exist.
+ *
+ * The object is returned with refcounter increased by 1.
+ */
+struct batadv_orig_ifinfo *
+batadv_orig_ifinfo_new(struct batadv_orig_node *orig_node,
+		       struct batadv_hard_iface *if_outgoing)
+{
+	struct batadv_orig_ifinfo *orig_ifinfo = NULL;
+	unsigned long reset_time;
+
+	spin_lock_bh(&orig_node->neigh_list_lock);
+
+	orig_ifinfo = batadv_orig_ifinfo_get(orig_node, if_outgoing);
+	if (orig_ifinfo)
+		goto out;
+
+	orig_ifinfo = kzalloc(sizeof(*orig_ifinfo), GFP_ATOMIC);
+	if (!orig_ifinfo)
+		goto out;
+
+	if (if_outgoing != BATADV_IF_DEFAULT &&
+	    !atomic_inc_not_zero(&if_outgoing->refcount)) {
+		kfree(orig_ifinfo);
+		orig_ifinfo = NULL;
+		goto out;
+	}
+
+	reset_time = jiffies - 1;
+	reset_time -= msecs_to_jiffies(BATADV_RESET_PROTECTION_MS);
+	orig_ifinfo->batman_seqno_reset = reset_time;
+	orig_ifinfo->if_outgoing = if_outgoing;
+	INIT_HLIST_NODE(&orig_ifinfo->list);
+	atomic_set(&orig_ifinfo->refcount, 2);
+	hlist_add_head_rcu(&orig_ifinfo->list,
+			   &orig_node->ifinfo_list);
+out:
+	spin_unlock_bh(&orig_node->neigh_list_lock);
+	return orig_ifinfo;
+}
+
+/**
  * batadv_neigh_ifinfo_get - find the ifinfo from an neigh_node
  * @neigh_node: the neigh node to be queried
  * @if_outgoing: the interface for which the ifinfo should be acquired
@@ -360,11 +457,51 @@ out:
 	return neigh_node;
 }
 
+/**
+ * batadv_orig_ifinfo_free_rcu - free the orig_ifinfo object
+ * @rcu: rcu pointer of the orig_ifinfo object
+ */
+static void batadv_orig_ifinfo_free_rcu(struct rcu_head *rcu)
+{
+	struct batadv_orig_ifinfo *orig_ifinfo;
+
+	orig_ifinfo = container_of(rcu, struct batadv_orig_ifinfo, rcu);
+
+	if (orig_ifinfo->if_outgoing != BATADV_IF_DEFAULT)
+		batadv_hardif_free_ref_now(orig_ifinfo->if_outgoing);
+
+	kfree(orig_ifinfo);
+}
+
+/**
+ * batadv_orig_ifinfo_free_ref - decrement the refcounter and possibly free
+ *  the orig_ifinfo (without rcu callback)
+ * @orig_ifinfo: the orig_ifinfo object to release
+ */
+static void
+batadv_orig_ifinfo_free_ref_now(struct batadv_orig_ifinfo *orig_ifinfo)
+{
+	if (atomic_dec_and_test(&orig_ifinfo->refcount))
+		batadv_orig_ifinfo_free_rcu(&orig_ifinfo->rcu);
+}
+
+/**
+ * batadv_orig_ifinfo_free_ref - decrement the refcounter and possibly free
+ *  the orig_ifinfo
+ * @orig_ifinfo: the orig_ifinfo object to release
+ */
+void batadv_orig_ifinfo_free_ref(struct batadv_orig_ifinfo *orig_ifinfo)
+{
+	if (atomic_dec_and_test(&orig_ifinfo->refcount))
+		call_rcu(&orig_ifinfo->rcu, batadv_orig_ifinfo_free_rcu);
+}
+
 static void batadv_orig_node_free_rcu(struct rcu_head *rcu)
 {
 	struct hlist_node *node_tmp;
 	struct batadv_neigh_node *neigh_node;
 	struct batadv_orig_node *orig_node;
+	struct batadv_orig_ifinfo *orig_ifinfo;
 
 	orig_node = container_of(rcu, struct batadv_orig_node, rcu);
 
@@ -377,6 +514,11 @@ static void batadv_orig_node_free_rcu(struct rcu_head *rcu)
 		batadv_neigh_node_free_ref_now(neigh_node);
 	}
 
+	hlist_for_each_entry_safe(orig_ifinfo, node_tmp,
+				  &orig_node->ifinfo_list, list) {
+		hlist_del_rcu(&orig_ifinfo->list);
+		batadv_orig_ifinfo_free_ref_now(orig_ifinfo);
+	}
 	spin_unlock_bh(&orig_node->neigh_list_lock);
 
 	/* Free nc_nodes */
@@ -474,6 +616,7 @@ struct batadv_orig_node *batadv_orig_node_new(struct batadv_priv *bat_priv,
 
 	INIT_HLIST_HEAD(&orig_node->neigh_list);
 	INIT_LIST_HEAD(&orig_node->vlan_list);
+	INIT_HLIST_HEAD(&orig_node->ifinfo_list);
 	spin_lock_init(&orig_node->bcast_seqno_lock);
 	spin_lock_init(&orig_node->neigh_list_lock);
 	spin_lock_init(&orig_node->tt_buff_lock);
@@ -489,13 +632,11 @@ struct batadv_orig_node *batadv_orig_node_new(struct batadv_priv *bat_priv,
 	orig_node->bat_priv = bat_priv;
 	memcpy(orig_node->orig, addr, ETH_ALEN);
 	batadv_dat_init_orig_node_addr(orig_node);
-	orig_node->router = NULL;
 	atomic_set(&orig_node->last_ttvn, 0);
 	orig_node->tt_buff = NULL;
 	orig_node->tt_buff_len = 0;
 	reset_time = jiffies - 1 - msecs_to_jiffies(BATADV_RESET_PROTECTION_MS);
 	orig_node->bcast_seqno_reset = reset_time;
-	orig_node->batman_seqno_reset = reset_time;
 
 	/* create a vlan object for the "untagged" LAN */
 	vlan = batadv_orig_node_vlan_new(orig_node, BATADV_NO_FLAGS);
@@ -520,6 +661,55 @@ free_orig_node:
 }
 
 /**
+ * batadv_purge_orig_ifinfo - purge obsolete ifinfo entries from originator
+ * @bat_priv: the bat priv with all the soft interface information
+ * @orig_node: orig node which is to be checked
+ *
+ * Returns true if any ifinfo entry was purged, false otherwise.
+ */
+static bool
+batadv_purge_orig_ifinfo(struct batadv_priv *bat_priv,
+			 struct batadv_orig_node *orig_node)
+{
+	struct batadv_orig_ifinfo *orig_ifinfo;
+	struct batadv_hard_iface *if_outgoing;
+	struct hlist_node *node_tmp;
+	bool ifinfo_purged = false;
+
+	spin_lock_bh(&orig_node->neigh_list_lock);
+
+	/* for all ifinfo objects for this originator */
+	hlist_for_each_entry_safe(orig_ifinfo, node_tmp,
+				  &orig_node->ifinfo_list, list) {
+		if_outgoing = orig_ifinfo->if_outgoing;
+
+		/* always keep the default interface */
+		if (if_outgoing == BATADV_IF_DEFAULT)
+			continue;
+
+		/* don't purge if the interface is not (going) down */
+		if ((if_outgoing->if_status != BATADV_IF_INACTIVE) &&
+		    (if_outgoing->if_status != BATADV_IF_NOT_IN_USE) &&
+		    (if_outgoing->if_status != BATADV_IF_TO_BE_REMOVED))
+			continue;
+
+		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
+			   "router/ifinfo purge: originator %pM, iface: %s\n",
+			   orig_node->orig, if_outgoing->net_dev->name);
+
+		ifinfo_purged = true;
+
+		hlist_del_rcu(&orig_ifinfo->list);
+		batadv_orig_ifinfo_free_ref(orig_ifinfo);
+	}
+
+	spin_unlock_bh(&orig_node->neigh_list_lock);
+
+	return ifinfo_purged;
+}
+
+
+/**
  * batadv_purge_orig_neighbors - purges neighbors from originator
  * @bat_priv: the bat priv with all the soft interface information
  * @orig_node: orig node which is to be checked
@@ -607,10 +797,22 @@ batadv_find_best_neighbor(struct batadv_priv *bat_priv,
 	return best;
 }
 
+/**
+ * batadv_purge_orig_node - purges obsolete information from an orig_node
+ * @bat_priv: the bat priv with all the soft interface information
+ * @orig_node: orig node which is to be checked
+ *
+ * This function checks if the orig_node or substructures of it have become
+ * obsolete, and purges this information if that's the case.
+ *
+ * Returns true if the orig_node is to be removed, false otherwise.
+ */
 static bool batadv_purge_orig_node(struct batadv_priv *bat_priv,
 				   struct batadv_orig_node *orig_node)
 {
 	struct batadv_neigh_node *best_neigh_node;
+	struct batadv_hard_iface *hard_iface;
+	bool changed;
 
 	if (batadv_has_timed_out(orig_node->last_seen,
 				 2 * BATADV_PURGE_TIMEOUT)) {
@@ -620,15 +822,39 @@ static bool batadv_purge_orig_node(struct batadv_priv *bat_priv,
 			   jiffies_to_msecs(orig_node->last_seen));
 		return true;
 	}
-	if (!batadv_purge_orig_neighbors(bat_priv, orig_node))
+	changed = batadv_purge_orig_ifinfo(bat_priv, orig_node);
+	changed = changed || batadv_purge_orig_neighbors(bat_priv, orig_node);
+
+	if (!changed)
 		return false;
 
+	/* first for NULL ... */
 	best_neigh_node = batadv_find_best_neighbor(bat_priv, orig_node,
 						    BATADV_IF_DEFAULT);
-	batadv_update_route(bat_priv, orig_node, best_neigh_node);
+	batadv_update_route(bat_priv, orig_node, BATADV_IF_DEFAULT,
+			    best_neigh_node);
 	if (best_neigh_node)
 		batadv_neigh_node_free_ref(best_neigh_node);
 
+	/* ... then for all other interfaces. */
+	rcu_read_lock();
+	list_for_each_entry_rcu(hard_iface, &batadv_hardif_list, list) {
+		if (hard_iface->if_status != BATADV_IF_ACTIVE)
+			continue;
+
+		if (hard_iface->soft_iface != bat_priv->soft_iface)
+			continue;
+
+		best_neigh_node = batadv_find_best_neighbor(bat_priv,
+							    orig_node,
+							    hard_iface);
+		batadv_update_route(bat_priv, orig_node, hard_iface,
+				    best_neigh_node);
+		if (best_neigh_node)
+			batadv_neigh_node_free_ref(best_neigh_node);
+	}
+	rcu_read_unlock();
+
 	return false;
 }
 
diff --git a/net/batman-adv/originator.h b/net/batman-adv/originator.h
index 29fa4c4..75a4d7b 100644
--- a/net/batman-adv/originator.h
+++ b/net/batman-adv/originator.h
@@ -34,7 +34,8 @@ batadv_neigh_node_new(struct batadv_hard_iface *hard_iface,
 		      struct batadv_orig_node *orig_node);
 void batadv_neigh_node_free_ref(struct batadv_neigh_node *neigh_node);
 struct batadv_neigh_node *
-batadv_orig_node_get_router(struct batadv_orig_node *orig_node);
+batadv_orig_router_get(struct batadv_orig_node *orig_node,
+		       const struct batadv_hard_iface *if_outgoing);
 struct batadv_neigh_ifinfo *
 batadv_neigh_ifinfo_new(struct batadv_neigh_node *neigh,
 			struct batadv_hard_iface *if_outgoing);
@@ -42,6 +43,15 @@ struct batadv_neigh_ifinfo *
 batadv_neigh_ifinfo_get(struct batadv_neigh_node *neigh,
 			struct batadv_hard_iface *if_outgoing);
 void batadv_neigh_ifinfo_free_ref(struct batadv_neigh_ifinfo *neigh_ifinfo);
+
+struct batadv_orig_ifinfo *
+batadv_orig_ifinfo_get(struct batadv_orig_node *orig_node,
+		       struct batadv_hard_iface *if_outgoing);
+struct batadv_orig_ifinfo *
+batadv_orig_ifinfo_new(struct batadv_orig_node *orig_node,
+		       struct batadv_hard_iface *if_outgoing);
+void batadv_orig_ifinfo_free_ref(struct batadv_orig_ifinfo *orig_ifinfo);
+
 int batadv_orig_seq_print_text(struct seq_file *seq, void *offset);
 int batadv_orig_hash_add_if(struct batadv_hard_iface *hard_iface,
 			    int max_if_num);
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 4fd2687..55e9aeb 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -33,13 +33,32 @@
 static int batadv_route_unicast_packet(struct sk_buff *skb,
 				       struct batadv_hard_iface *recv_if);
 
+/**
+ * _batadv_update_route - set the router for this originator
+ * @bat_priv: the bat priv with all the soft interface information
+ * @orig_node: orig node which is to be configured
+ * @recv_if: the receive interface for which this route is set
+ * @neigh_node: neighbor which should be the next router
+ *
+ * This function does not perform any error checks
+ */
 static void _batadv_update_route(struct batadv_priv *bat_priv,
 				 struct batadv_orig_node *orig_node,
+				 struct batadv_hard_iface *recv_if,
 				 struct batadv_neigh_node *neigh_node)
 {
+	struct batadv_orig_ifinfo *orig_ifinfo;
 	struct batadv_neigh_node *curr_router;
 
-	curr_router = batadv_orig_node_get_router(orig_node);
+	orig_ifinfo = batadv_orig_ifinfo_get(orig_node, recv_if);
+	if (!orig_ifinfo)
+		return;
+
+	rcu_read_lock();
+	curr_router = rcu_dereference(orig_ifinfo->router);
+	if (curr_router && !atomic_inc_not_zero(&curr_router->refcount))
+		curr_router = NULL;
+	rcu_read_unlock();
 
 	/* route deleted */
 	if ((curr_router) && (!neigh_node)) {
@@ -69,16 +88,25 @@ static void _batadv_update_route(struct batadv_priv *bat_priv,
 		neigh_node = NULL;
 
 	spin_lock_bh(&orig_node->neigh_list_lock);
-	rcu_assign_pointer(orig_node->router, neigh_node);
+	rcu_assign_pointer(orig_ifinfo->router, neigh_node);
 	spin_unlock_bh(&orig_node->neigh_list_lock);
+	batadv_orig_ifinfo_free_ref(orig_ifinfo);
 
 	/* decrease refcount of previous best neighbor */
 	if (curr_router)
 		batadv_neigh_node_free_ref(curr_router);
 }
 
+/**
+ * batadv_update_route - set the router for this originator
+ * @bat_priv: the bat priv with all the soft interface information
+ * @orig_node: orig node which is to be configured
+ * @recv_if: the receive interface for which this route is set
+ * @neigh_node: neighbor which should be the next router
+ */
 void batadv_update_route(struct batadv_priv *bat_priv,
 			 struct batadv_orig_node *orig_node,
+			 struct batadv_hard_iface *recv_if,
 			 struct batadv_neigh_node *neigh_node)
 {
 	struct batadv_neigh_node *router = NULL;
@@ -86,10 +114,10 @@ void batadv_update_route(struct batadv_priv *bat_priv,
 	if (!orig_node)
 		goto out;
 
-	router = batadv_orig_node_get_router(orig_node);
+	router = batadv_orig_router_get(orig_node, recv_if);
 
 	if (router != neigh_node)
-		_batadv_update_route(bat_priv, orig_node, neigh_node);
+		_batadv_update_route(bat_priv, orig_node, recv_if, neigh_node);
 
 out:
 	if (router)
@@ -406,7 +434,7 @@ batadv_find_router(struct batadv_priv *bat_priv,
 	if (!orig_node)
 		return NULL;
 
-	router = batadv_orig_node_get_router(orig_node);
+	router = batadv_orig_router_get(orig_node, recv_if);
 
 	/* TODO: fill this later with new bonding mechanism */
 
diff --git a/net/batman-adv/routing.h b/net/batman-adv/routing.h
index 192f0aa..8920d0b 100644
--- a/net/batman-adv/routing.h
+++ b/net/batman-adv/routing.h
@@ -23,6 +23,7 @@ bool batadv_check_management_packet(struct sk_buff *skb,
 				    int header_len);
 void batadv_update_route(struct batadv_priv *bat_priv,
 			 struct batadv_orig_node *orig_node,
+			 struct batadv_hard_iface *recv_if,
 			 struct batadv_neigh_node *neigh_node);
 int batadv_recv_icmp_packet(struct sk_buff *skb,
 			    struct batadv_hard_iface *recv_if);
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 22c32ae..ec89a1b 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -1400,7 +1400,8 @@ batadv_transtable_best_orig(struct batadv_priv *bat_priv,
 
 	head = &tt_global_entry->orig_list;
 	hlist_for_each_entry_rcu(orig_entry, head, list) {
-		router = batadv_orig_node_get_router(orig_entry->orig_node);
+		router = batadv_orig_router_get(orig_entry->orig_node,
+						BATADV_IF_DEFAULT);
 		if (!router)
 			continue;
 
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 8435d7c..d3e2bf4 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -101,6 +101,28 @@ struct batadv_hard_iface {
 };
 
 /**
+ * struct batadv_orig_ifinfo - originator info per outgoing interface
+ * @list: list node for orig_node::ifinfo_list
+ * @if_outgoing: pointer to outgoing hard interface
+ * @router: router that should be used to reach this originator
+ * @last_real_seqno: last and best known sequence number
+ * @last_ttl: ttl of last received packet
+ * @batman_seqno_reset: time when the batman seqno window was reset
+ * @refcount: number of contexts the object is used
+ * @rcu: struct used for freeing in an RCU-safe manner
+ */
+struct batadv_orig_ifinfo {
+	struct hlist_node list;
+	struct batadv_hard_iface *if_outgoing;
+	struct batadv_neigh_node __rcu *router; /* rcu protected pointer */
+	uint32_t last_real_seqno;
+	uint8_t last_ttl;
+	unsigned long batman_seqno_reset;
+	atomic_t refcount;
+	struct rcu_head rcu;
+};
+
+/**
  * struct batadv_frag_table_entry - head in the fragment buffer table
  * @head: head of list with fragments
  * @lock: lock to protect the list of fragments
@@ -175,11 +197,10 @@ struct batadv_orig_bat_iv {
  * struct batadv_orig_node - structure for orig_list maintaining nodes of mesh
  * @orig: originator ethernet address
  * @primary_addr: hosts primary interface address
- * @router: router that should be used to reach this originator
+ * @ifinfo_list: list for routers per outgoing interface
  * @batadv_dat_addr_t:  address of the orig node in the distributed hash
  * @last_seen: time when last packet from this node was received
  * @bcast_seqno_reset: time when the broadcast seqno window was reset
- * @batman_seqno_reset: time when the batman seqno window was reset
  * @capabilities: announced capabilities of this originator
  * @last_ttvn: last seen translation table version number
  * @tt_buff: last tt changeset this node received from the orig node
@@ -192,8 +213,6 @@ struct batadv_orig_bat_iv {
  *  made up by two operations (data structure update and metdata -CRC/TTVN-
  *  recalculation) and they have to be executed atomically in order to avoid
  *  another thread to read the table/metadata between those.
- * @last_real_seqno: last and best known sequence number
- * @last_ttl: ttl of last received packet
  * @bcast_bits: bitfield containing the info which payload broadcast originated
  *  from this orig node this host already has seen (relative to
  *  last_bcast_seqno)
@@ -218,13 +237,12 @@ struct batadv_orig_bat_iv {
 struct batadv_orig_node {
 	uint8_t orig[ETH_ALEN];
 	uint8_t primary_addr[ETH_ALEN];
-	struct batadv_neigh_node __rcu *router; /* rcu protected pointer */
+	struct hlist_head ifinfo_list;
 #ifdef CONFIG_BATMAN_ADV_DAT
 	batadv_dat_addr_t dat_addr;
 #endif
 	unsigned long last_seen;
 	unsigned long bcast_seqno_reset;
-	unsigned long batman_seqno_reset;
 	uint8_t capabilities;
 	atomic_t last_ttvn;
 	unsigned char *tt_buff;
@@ -233,8 +251,6 @@ struct batadv_orig_node {
 	bool tt_initialised;
 	/* prevents from changing the table while reading it */
 	spinlock_t tt_lock;
-	uint32_t last_real_seqno;
-	uint8_t last_ttl;
 	DECLARE_BITMAP(bcast_bits, BATADV_TQ_LOCAL_WINDOW_SIZE);
 	uint32_t last_bcast_seqno;
 	struct hlist_head neigh_list;
-- 
1.8.5.2
