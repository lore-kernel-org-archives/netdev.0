From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 11/19] batman-adv: keep batman_ogm_packet ->seqno net-endian all along
Date: Mon, 18 Jun 2012 22:39:15 +0200
Message-ID: <1340051963-14836-12-git-send-email-ordex@autistici.org>
References: <1340051963-14836-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Al Viro <viro@ZenIV.linux.org.uk>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:41527 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753304Ab2FRUjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2012 16:39:13 -0400
In-Reply-To: <1340051963-14836-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@ZenIV.linux.org.uk>

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bat_iv_ogm.c |   22 +++++++++++-----------
 net/batman-adv/packet.h     |    2 +-
 2 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index e94ac0b..56b6d78 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -34,11 +34,12 @@ static struct neigh_node *bat_iv_ogm_neigh_new(struct hard_iface *hard_iface,
 					       const uint8_t *neigh_addr,
 					       struct orig_node *orig_node,
 					       struct orig_node *orig_neigh,
-					       uint32_t seqno)
+					       __be32 seqno)
 {
 	struct neigh_node *neigh_node;
 
-	neigh_node = batadv_neigh_node_new(hard_iface, neigh_addr, seqno);
+	neigh_node = batadv_neigh_node_new(hard_iface, neigh_addr,
+					   ntohl(seqno));
 	if (!neigh_node)
 		goto out;
 
@@ -546,7 +547,6 @@ static void bat_iv_ogm_forward(struct orig_node *orig_node,
 		"Forwarding packet: tq: %i, ttl: %i\n",
 		batman_ogm_packet->tq, batman_ogm_packet->header.ttl);
 
-	batman_ogm_packet->seqno = htonl(batman_ogm_packet->seqno);
 	batman_ogm_packet->tt_crc = htons(batman_ogm_packet->tt_crc);
 
 	/* switch of primaries first hop flag when forwarding */
@@ -871,13 +871,14 @@ static int bat_iv_ogm_update_seqnos(const struct ethhdr *ethhdr,
 	int32_t seq_diff;
 	int need_update = 0;
 	int set_mark, ret = -1;
+	uint32_t seqno = ntohl(batman_ogm_packet->seqno);
 
 	orig_node = get_orig_node(bat_priv, batman_ogm_packet->orig);
 	if (!orig_node)
 		return 0;
 
 	spin_lock_bh(&orig_node->ogm_cnt_lock);
-	seq_diff = batman_ogm_packet->seqno - orig_node->last_real_seqno;
+	seq_diff = seqno - orig_node->last_real_seqno;
 
 	/* signalize caller that the packet is to be dropped. */
 	if (!hlist_empty(&orig_node->neigh_list) &&
@@ -891,7 +892,7 @@ static int bat_iv_ogm_update_seqnos(const struct ethhdr *ethhdr,
 
 		is_duplicate |= bat_test_bit(tmp_neigh_node->real_bits,
 					     orig_node->last_real_seqno,
-					     batman_ogm_packet->seqno);
+					     seqno);
 
 		if (compare_eth(tmp_neigh_node->addr, ethhdr->h_source) &&
 		    (tmp_neigh_node->if_incoming == if_incoming))
@@ -913,8 +914,8 @@ static int bat_iv_ogm_update_seqnos(const struct ethhdr *ethhdr,
 	if (need_update) {
 		bat_dbg(DBG_BATMAN, bat_priv,
 			"updating last_seqno: old %u, new %u\n",
-			orig_node->last_real_seqno, batman_ogm_packet->seqno);
-		orig_node->last_real_seqno = batman_ogm_packet->seqno;
+			orig_node->last_real_seqno, seqno);
+		orig_node->last_real_seqno = seqno;
 	}
 
 	ret = is_duplicate;
@@ -970,7 +971,7 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 		"Received BATMAN packet via NB: %pM, IF: %s [%pM] (from OG: %pM, via prev OG: %pM, seqno %u, ttvn %u, crc %u, changes %u, td %d, TTL %d, V %d, IDF %d)\n",
 		ethhdr->h_source, if_incoming->net_dev->name,
 		if_incoming->net_dev->dev_addr, batman_ogm_packet->orig,
-		batman_ogm_packet->prev_sender, batman_ogm_packet->seqno,
+		batman_ogm_packet->prev_sender, ntohl(batman_ogm_packet->seqno),
 		batman_ogm_packet->ttvn, batman_ogm_packet->tt_crc,
 		batman_ogm_packet->tt_num_changes, batman_ogm_packet->tq,
 		batman_ogm_packet->header.ttl,
@@ -1042,7 +1043,7 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 			word = &(orig_neigh_node->bcast_own[offset]);
 			bat_set_bit(word,
 				    if_incoming_seqno -
-						batman_ogm_packet->seqno - 2);
+					ntohl(batman_ogm_packet->seqno) - 2);
 			orig_neigh_node->bcast_own_sum[if_incoming->if_num] =
 				bitmap_weight(word, TQ_LOCAL_WINDOW_SIZE);
 			spin_unlock_bh(&orig_neigh_node->ogm_cnt_lock);
@@ -1135,7 +1136,7 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 	 * seqno and similar ttl as the non-duplicate */
 	if (is_bidirectional &&
 	    (!is_duplicate ||
-	     ((orig_node->last_real_seqno == batman_ogm_packet->seqno) &&
+	     ((orig_node->last_real_seqno == ntohl(batman_ogm_packet->seqno)) &&
 	      (orig_node->last_ttl - 3 <= batman_ogm_packet->header.ttl))))
 		bat_iv_ogm_orig_update(bat_priv, orig_node, ethhdr,
 				       batman_ogm_packet, if_incoming,
@@ -1220,7 +1221,6 @@ static int bat_iv_ogm_receive(struct sk_buff *skb,
 	do {
 		/* network to host order for our 32bit seqno and the
 		   orig_interval */
-		batman_ogm_packet->seqno = ntohl(batman_ogm_packet->seqno);
 		batman_ogm_packet->tt_crc = ntohs(batman_ogm_packet->tt_crc);
 
 		tt_buff = packet_buff + buff_pos + BATMAN_OGM_HLEN;
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index eaa6028..5bf567b 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -117,7 +117,7 @@ struct batman_header {
 struct batman_ogm_packet {
 	struct batman_header header;
 	uint8_t  flags;    /* 0x40: DIRECTLINK flag, 0x20 VIS_SERVER flag... */
-	uint32_t seqno;
+	__be32   seqno;
 	uint8_t  orig[ETH_ALEN];
 	uint8_t  prev_sender[ETH_ALEN];
 	uint8_t  gw_flags;  /* flags related to gateway class */
-- 
1.7.9.4
