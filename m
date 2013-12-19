From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 3/6] batman-adv: fix header alignment by unrolling batadv_header
Date: Thu, 19 Dec 2013 01:15:29 +0100
Message-ID: <1387412132-889-4-git-send-email-antonio@meshcoding.com>
References: <1387412132-889-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <sw@simonwunderlich.de>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:8098 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751474Ab3LSASD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 19:18:03 -0500
In-Reply-To: <1387412132-889-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <sw@simonwunderlich.de>

The size of the batadv_header of 3 is problematic on some architectures
which automatically pad all structures to a 32 bit boundary. To not lose
performance by packing this struct, better embed it into the various
host structures.

Reported-by: Russell King <linux@arm.linux.org.uk>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/bat_iv_ogm.c            | 36 ++++++++---------
 net/batman-adv/distributed-arp-table.c |  6 +--
 net/batman-adv/fragmentation.c         |  8 ++--
 net/batman-adv/icmp_socket.c           |  6 +--
 net/batman-adv/main.c                  | 12 +++---
 net/batman-adv/network-coding.c        | 22 +++++-----
 net/batman-adv/packet.h                | 74 ++++++++++++++++++++++++----------
 net/batman-adv/routing.c               | 18 ++++-----
 net/batman-adv/send.c                  | 10 ++---
 net/batman-adv/soft-interface.c        | 11 ++---
 10 files changed, 118 insertions(+), 85 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index a2b480a..b9c8a6e 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -307,9 +307,9 @@ static int batadv_iv_ogm_iface_enable(struct batadv_hard_iface *hard_iface)
 	hard_iface->bat_iv.ogm_buff = ogm_buff;
 
 	batadv_ogm_packet = (struct batadv_ogm_packet *)ogm_buff;
-	batadv_ogm_packet->header.packet_type = BATADV_IV_OGM;
-	batadv_ogm_packet->header.version = BATADV_COMPAT_VERSION;
-	batadv_ogm_packet->header.ttl = 2;
+	batadv_ogm_packet->packet_type = BATADV_IV_OGM;
+	batadv_ogm_packet->version = BATADV_COMPAT_VERSION;
+	batadv_ogm_packet->ttl = 2;
 	batadv_ogm_packet->flags = BATADV_NO_FLAGS;
 	batadv_ogm_packet->reserved = 0;
 	batadv_ogm_packet->tq = BATADV_TQ_MAX_VALUE;
@@ -346,7 +346,7 @@ batadv_iv_ogm_primary_iface_set(struct batadv_hard_iface *hard_iface)
 
 	batadv_ogm_packet = (struct batadv_ogm_packet *)ogm_buff;
 	batadv_ogm_packet->flags = BATADV_PRIMARIES_FIRST_HOP;
-	batadv_ogm_packet->header.ttl = BATADV_TTL;
+	batadv_ogm_packet->ttl = BATADV_TTL;
 }
 
 /* when do we schedule our own ogm to be sent */
@@ -435,7 +435,7 @@ static void batadv_iv_ogm_send_to_if(struct batadv_forw_packet *forw_packet,
 			   fwd_str, (packet_num > 0 ? "aggregated " : ""),
 			   batadv_ogm_packet->orig,
 			   ntohl(batadv_ogm_packet->seqno),
-			   batadv_ogm_packet->tq, batadv_ogm_packet->header.ttl,
+			   batadv_ogm_packet->tq, batadv_ogm_packet->ttl,
 			   (batadv_ogm_packet->flags & BATADV_DIRECTLINK ?
 			    "on" : "off"),
 			   hard_iface->net_dev->name,
@@ -491,7 +491,7 @@ static void batadv_iv_ogm_emit(struct batadv_forw_packet *forw_packet)
 	/* multihomed peer assumed
 	 * non-primary OGMs are only broadcasted on their interface
 	 */
-	if ((directlink && (batadv_ogm_packet->header.ttl == 1)) ||
+	if ((directlink && (batadv_ogm_packet->ttl == 1)) ||
 	    (forw_packet->own && (forw_packet->if_incoming != primary_if))) {
 		/* FIXME: what about aggregated packets ? */
 		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
@@ -499,7 +499,7 @@ static void batadv_iv_ogm_emit(struct batadv_forw_packet *forw_packet)
 			   (forw_packet->own ? "Sending own" : "Forwarding"),
 			   batadv_ogm_packet->orig,
 			   ntohl(batadv_ogm_packet->seqno),
-			   batadv_ogm_packet->header.ttl,
+			   batadv_ogm_packet->ttl,
 			   forw_packet->if_incoming->net_dev->name,
 			   forw_packet->if_incoming->net_dev->dev_addr);
 
@@ -572,7 +572,7 @@ batadv_iv_ogm_can_aggregate(const struct batadv_ogm_packet *new_bat_ogm_packet,
 		 */
 		if ((!directlink) &&
 		    (!(batadv_ogm_packet->flags & BATADV_DIRECTLINK)) &&
-		    (batadv_ogm_packet->header.ttl != 1) &&
+		    (batadv_ogm_packet->ttl != 1) &&
 
 		    /* own packets originating non-primary
 		     * interfaces leave only that interface
@@ -587,7 +587,7 @@ batadv_iv_ogm_can_aggregate(const struct batadv_ogm_packet *new_bat_ogm_packet,
 		 * interface only - we still can aggregate
 		 */
 		if ((directlink) &&
-		    (new_bat_ogm_packet->header.ttl == 1) &&
+		    (new_bat_ogm_packet->ttl == 1) &&
 		    (forw_packet->if_incoming == if_incoming) &&
 
 		    /* packets from direct neighbors or
@@ -778,7 +778,7 @@ static void batadv_iv_ogm_forward(struct batadv_orig_node *orig_node,
 	struct batadv_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
 	uint16_t tvlv_len;
 
-	if (batadv_ogm_packet->header.ttl <= 1) {
+	if (batadv_ogm_packet->ttl <= 1) {
 		batadv_dbg(BATADV_DBG_BATMAN, bat_priv, "ttl exceeded\n");
 		return;
 	}
@@ -798,7 +798,7 @@ static void batadv_iv_ogm_forward(struct batadv_orig_node *orig_node,
 
 	tvlv_len = ntohs(batadv_ogm_packet->tvlv_len);
 
-	batadv_ogm_packet->header.ttl--;
+	batadv_ogm_packet->ttl--;
 	memcpy(batadv_ogm_packet->prev_sender, ethhdr->h_source, ETH_ALEN);
 
 	/* apply hop penalty */
@@ -807,7 +807,7 @@ static void batadv_iv_ogm_forward(struct batadv_orig_node *orig_node,
 
 	batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 		   "Forwarding packet: tq: %i, ttl: %i\n",
-		   batadv_ogm_packet->tq, batadv_ogm_packet->header.ttl);
+		   batadv_ogm_packet->tq, batadv_ogm_packet->ttl);
 
 	/* switch of primaries first hop flag when forwarding */
 	batadv_ogm_packet->flags &= ~BATADV_PRIMARIES_FIRST_HOP;
@@ -972,8 +972,8 @@ batadv_iv_ogm_orig_update(struct batadv_priv *bat_priv,
 	spin_unlock_bh(&neigh_node->bat_iv.lq_update_lock);
 
 	if (dup_status == BATADV_NO_DUP) {
-		orig_node->last_ttl = batadv_ogm_packet->header.ttl;
-		neigh_node->last_ttl = batadv_ogm_packet->header.ttl;
+		orig_node->last_ttl = batadv_ogm_packet->ttl;
+		neigh_node->last_ttl = batadv_ogm_packet->ttl;
 	}
 
 	batadv_bonding_candidate_add(bat_priv, orig_node, neigh_node);
@@ -1247,7 +1247,7 @@ static void batadv_iv_ogm_process(const struct ethhdr *ethhdr,
 	 * packet in an aggregation.  Here we expect that the padding
 	 * is always zero (or not 0x01)
 	 */
-	if (batadv_ogm_packet->header.packet_type != BATADV_IV_OGM)
+	if (batadv_ogm_packet->packet_type != BATADV_IV_OGM)
 		return;
 
 	/* could be changed by schedule_own_packet() */
@@ -1267,8 +1267,8 @@ static void batadv_iv_ogm_process(const struct ethhdr *ethhdr,
 		   if_incoming->net_dev->dev_addr, batadv_ogm_packet->orig,
 		   batadv_ogm_packet->prev_sender,
 		   ntohl(batadv_ogm_packet->seqno), batadv_ogm_packet->tq,
-		   batadv_ogm_packet->header.ttl,
-		   batadv_ogm_packet->header.version, has_directlink_flag);
+		   batadv_ogm_packet->ttl,
+		   batadv_ogm_packet->version, has_directlink_flag);
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(hard_iface, &batadv_hardif_list, list) {
@@ -1433,7 +1433,7 @@ static void batadv_iv_ogm_process(const struct ethhdr *ethhdr,
 	 * seqno and similar ttl as the non-duplicate
 	 */
 	sameseq = orig_node->last_real_seqno == ntohl(batadv_ogm_packet->seqno);
-	similar_ttl = orig_node->last_ttl - 3 <= batadv_ogm_packet->header.ttl;
+	similar_ttl = orig_node->last_ttl - 3 <= batadv_ogm_packet->ttl;
 	if (is_bidirect && ((dup_status == BATADV_NO_DUP) ||
 			    (sameseq && similar_ttl)))
 		batadv_iv_ogm_orig_update(bat_priv, orig_node, ethhdr,
diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index 6c8c393..b316a4c 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -349,7 +349,7 @@ static void batadv_dbg_arp(struct batadv_priv *bat_priv, struct sk_buff *skb,
 
 	unicast_4addr_packet = (struct batadv_unicast_4addr_packet *)skb->data;
 
-	switch (unicast_4addr_packet->u.header.packet_type) {
+	switch (unicast_4addr_packet->u.packet_type) {
 	case BATADV_UNICAST:
 		batadv_dbg(BATADV_DBG_DAT, bat_priv,
 			   "* encapsulated within a UNICAST packet\n");
@@ -374,7 +374,7 @@ static void batadv_dbg_arp(struct batadv_priv *bat_priv, struct sk_buff *skb,
 			break;
 		default:
 			batadv_dbg(BATADV_DBG_DAT, bat_priv, "* type: Unknown (%u)!\n",
-				   unicast_4addr_packet->u.header.packet_type);
+				   unicast_4addr_packet->u.packet_type);
 		}
 		break;
 	case BATADV_BCAST:
@@ -387,7 +387,7 @@ static void batadv_dbg_arp(struct batadv_priv *bat_priv, struct sk_buff *skb,
 	default:
 		batadv_dbg(BATADV_DBG_DAT, bat_priv,
 			   "* encapsulated within an unknown packet type (0x%x)\n",
-			   unicast_4addr_packet->u.header.packet_type);
+			   unicast_4addr_packet->u.packet_type);
 	}
 }
 
diff --git a/net/batman-adv/fragmentation.c b/net/batman-adv/fragmentation.c
index 271d321..6ddb614 100644
--- a/net/batman-adv/fragmentation.c
+++ b/net/batman-adv/fragmentation.c
@@ -355,7 +355,7 @@ bool batadv_frag_skb_fwd(struct sk_buff *skb,
 		batadv_add_counter(bat_priv, BATADV_CNT_FRAG_FWD_BYTES,
 				   skb->len + ETH_HLEN);
 
-		packet->header.ttl--;
+		packet->ttl--;
 		batadv_send_skb_packet(skb, neigh_node->if_incoming,
 				       neigh_node->addr);
 		ret = true;
@@ -444,9 +444,9 @@ bool batadv_frag_send_packet(struct sk_buff *skb,
 		goto out_err;
 
 	/* Create one header to be copied to all fragments */
-	frag_header.header.packet_type = BATADV_UNICAST_FRAG;
-	frag_header.header.version = BATADV_COMPAT_VERSION;
-	frag_header.header.ttl = BATADV_TTL;
+	frag_header.packet_type = BATADV_UNICAST_FRAG;
+	frag_header.version = BATADV_COMPAT_VERSION;
+	frag_header.ttl = BATADV_TTL;
 	frag_header.seqno = htons(atomic_inc_return(&bat_priv->frag_seqno));
 	frag_header.reserved = 0;
 	frag_header.no = 0;
diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.c
index 29ae4ef..130cc32 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -194,7 +194,7 @@ static ssize_t batadv_socket_write(struct file *file, const char __user *buff,
 		goto free_skb;
 	}
 
-	if (icmp_header->header.packet_type != BATADV_ICMP) {
+	if (icmp_header->packet_type != BATADV_ICMP) {
 		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "Error - can't send packet from char device: got bogus packet type (expected: BAT_ICMP)\n");
 		len = -EINVAL;
@@ -243,9 +243,9 @@ static ssize_t batadv_socket_write(struct file *file, const char __user *buff,
 
 	icmp_header->uid = socket_client->index;
 
-	if (icmp_header->header.version != BATADV_COMPAT_VERSION) {
+	if (icmp_header->version != BATADV_COMPAT_VERSION) {
 		icmp_header->msg_type = BATADV_PARAMETER_PROBLEM;
-		icmp_header->header.version = BATADV_COMPAT_VERSION;
+		icmp_header->version = BATADV_COMPAT_VERSION;
 		batadv_socket_add_packet(socket_client, icmp_header,
 					 packet_len);
 		goto free_skb;
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index c51a5e5..d87778b 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -383,17 +383,17 @@ int batadv_batman_skb_recv(struct sk_buff *skb, struct net_device *dev,
 
 	batadv_ogm_packet = (struct batadv_ogm_packet *)skb->data;
 
-	if (batadv_ogm_packet->header.version != BATADV_COMPAT_VERSION) {
+	if (batadv_ogm_packet->version != BATADV_COMPAT_VERSION) {
 		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "Drop packet: incompatible batman version (%i)\n",
-			   batadv_ogm_packet->header.version);
+			   batadv_ogm_packet->version);
 		goto err_free;
 	}
 
 	/* all receive handlers return whether they received or reused
 	 * the supplied skb. if not, we have to free the skb.
 	 */
-	idx = batadv_ogm_packet->header.packet_type;
+	idx = batadv_ogm_packet->packet_type;
 	ret = (*batadv_rx_handler[idx])(skb, hard_iface);
 
 	if (ret == NET_RX_DROP)
@@ -1119,9 +1119,9 @@ void batadv_tvlv_unicast_send(struct batadv_priv *bat_priv, uint8_t *src,
 	skb_reserve(skb, ETH_HLEN);
 	tvlv_buff = skb_put(skb, sizeof(*unicast_tvlv_packet) + tvlv_len);
 	unicast_tvlv_packet = (struct batadv_unicast_tvlv_packet *)tvlv_buff;
-	unicast_tvlv_packet->header.packet_type = BATADV_UNICAST_TVLV;
-	unicast_tvlv_packet->header.version = BATADV_COMPAT_VERSION;
-	unicast_tvlv_packet->header.ttl = BATADV_TTL;
+	unicast_tvlv_packet->packet_type = BATADV_UNICAST_TVLV;
+	unicast_tvlv_packet->version = BATADV_COMPAT_VERSION;
+	unicast_tvlv_packet->ttl = BATADV_TTL;
 	unicast_tvlv_packet->reserved = 0;
 	unicast_tvlv_packet->tvlv_len = htons(tvlv_len);
 	unicast_tvlv_packet->align = 0;
diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-coding.c
index 351e199..511d7e1 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -722,7 +722,7 @@ static bool batadv_can_nc_with_orig(struct batadv_priv *bat_priv,
 {
 	if (orig_node->last_real_seqno != ntohl(ogm_packet->seqno))
 		return false;
-	if (orig_node->last_ttl != ogm_packet->header.ttl + 1)
+	if (orig_node->last_ttl != ogm_packet->ttl + 1)
 		return false;
 	if (!batadv_compare_eth(ogm_packet->orig, ogm_packet->prev_sender))
 		return false;
@@ -1082,9 +1082,9 @@ static bool batadv_nc_code_packets(struct batadv_priv *bat_priv,
 	coded_packet = (struct batadv_coded_packet *)skb_dest->data;
 	skb_reset_mac_header(skb_dest);
 
-	coded_packet->header.packet_type = BATADV_CODED;
-	coded_packet->header.version = BATADV_COMPAT_VERSION;
-	coded_packet->header.ttl = packet1->header.ttl;
+	coded_packet->packet_type = BATADV_CODED;
+	coded_packet->version = BATADV_COMPAT_VERSION;
+	coded_packet->ttl = packet1->ttl;
 
 	/* Info about first unicast packet */
 	memcpy(coded_packet->first_source, first_source, ETH_ALEN);
@@ -1097,7 +1097,7 @@ static bool batadv_nc_code_packets(struct batadv_priv *bat_priv,
 	memcpy(coded_packet->second_source, second_source, ETH_ALEN);
 	memcpy(coded_packet->second_orig_dest, packet2->dest, ETH_ALEN);
 	coded_packet->second_crc = packet_id2;
-	coded_packet->second_ttl = packet2->header.ttl;
+	coded_packet->second_ttl = packet2->ttl;
 	coded_packet->second_ttvn = packet2->ttvn;
 	coded_packet->coded_len = htons(coding_len);
 
@@ -1452,7 +1452,7 @@ bool batadv_nc_skb_forward(struct sk_buff *skb,
 	/* We only handle unicast packets */
 	payload = skb_network_header(skb);
 	packet = (struct batadv_unicast_packet *)payload;
-	if (packet->header.packet_type != BATADV_UNICAST)
+	if (packet->packet_type != BATADV_UNICAST)
 		goto out;
 
 	/* Try to find a coding opportunity and send the skb if one is found */
@@ -1505,7 +1505,7 @@ void batadv_nc_skb_store_for_decoding(struct batadv_priv *bat_priv,
 	/* Check for supported packet type */
 	payload = skb_network_header(skb);
 	packet = (struct batadv_unicast_packet *)payload;
-	if (packet->header.packet_type != BATADV_UNICAST)
+	if (packet->packet_type != BATADV_UNICAST)
 		goto out;
 
 	/* Find existing nc_path or create a new */
@@ -1623,7 +1623,7 @@ batadv_nc_skb_decode_packet(struct batadv_priv *bat_priv, struct sk_buff *skb,
 		ttvn = coded_packet_tmp.second_ttvn;
 	} else {
 		orig_dest = coded_packet_tmp.first_orig_dest;
-		ttl = coded_packet_tmp.header.ttl;
+		ttl = coded_packet_tmp.ttl;
 		ttvn = coded_packet_tmp.first_ttvn;
 	}
 
@@ -1648,9 +1648,9 @@ batadv_nc_skb_decode_packet(struct batadv_priv *bat_priv, struct sk_buff *skb,
 
 	/* Create decoded unicast packet */
 	unicast_packet = (struct batadv_unicast_packet *)skb->data;
-	unicast_packet->header.packet_type = BATADV_UNICAST;
-	unicast_packet->header.version = BATADV_COMPAT_VERSION;
-	unicast_packet->header.ttl = ttl;
+	unicast_packet->packet_type = BATADV_UNICAST;
+	unicast_packet->version = BATADV_COMPAT_VERSION;
+	unicast_packet->ttl = ttl;
 	memcpy(unicast_packet->dest, orig_dest, ETH_ALEN);
 	unicast_packet->ttvn = ttvn;
 
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 10597a6..175ce7d 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -164,23 +164,18 @@ struct batadv_bla_claim_dst {
 	__be16 group;		/* group id */
 };
 
-struct batadv_header {
-	uint8_t  packet_type;
-	uint8_t  version;  /* batman version field */
-	uint8_t  ttl;
-	/* the parent struct has to add a byte after the header to make
-	 * everything 4 bytes aligned again
-	 */
-};
-
 /**
  * struct batadv_ogm_packet - ogm (routing protocol) packet
- * @header: common batman packet header
+ * @packet_type: batman-adv packet type, part of the general header
+ * @version: batman-adv protocol version, part of the genereal header
+ * @ttl: time to live for this packet, part of the genereal header
  * @flags: contains routing relevant flags - see enum batadv_iv_flags
  * @tvlv_len: length of tvlv data following the ogm header
  */
 struct batadv_ogm_packet {
-	struct batadv_header header;
+	uint8_t  packet_type;
+	uint8_t  version;
+	uint8_t  ttl;
 	uint8_t  flags;
 	__be32   seqno;
 	uint8_t  orig[ETH_ALEN];
@@ -197,14 +192,18 @@ struct batadv_ogm_packet {
 
 /**
  * batadv_icmp_header - common ICMP header
- * @header: common batman header
+ * @packet_type: batman-adv packet type, part of the general header
+ * @version: batman-adv protocol version, part of the genereal header
+ * @ttl: time to live for this packet, part of the genereal header
  * @msg_type: ICMP packet type
  * @dst: address of the destination node
  * @orig: address of the source node
  * @uid: local ICMP socket identifier
  */
 struct batadv_icmp_header {
-	struct batadv_header header;
+	uint8_t  packet_type;
+	uint8_t  version;
+	uint8_t  ttl;
 	uint8_t  msg_type; /* see ICMP message types above */
 	uint8_t  dst[ETH_ALEN];
 	uint8_t  orig[ETH_ALEN];
@@ -253,8 +252,18 @@ struct batadv_icmp_packet_rr {
  */
 #pragma pack(2)
 
+/**
+ * struct batadv_unicast_packet - unicast packet for network payload
+ * @packet_type: batman-adv packet type, part of the general header
+ * @version: batman-adv protocol version, part of the genereal header
+ * @ttl: time to live for this packet, part of the genereal header
+ * @ttvn: translation table version number
+ * @dest: originator destination of the unicast packet
+ */
 struct batadv_unicast_packet {
-	struct batadv_header header;
+	uint8_t  packet_type;
+	uint8_t  version;
+	uint8_t  ttl;
 	uint8_t  ttvn; /* destination translation table version number */
 	uint8_t  dest[ETH_ALEN];
 	/* "4 bytes boundary + 2 bytes" long to make the payload after the
@@ -280,7 +289,9 @@ struct batadv_unicast_4addr_packet {
 
 /**
  * struct batadv_frag_packet - fragmented packet
- * @header: common batman packet header with type, compatversion, and ttl
+ * @packet_type: batman-adv packet type, part of the general header
+ * @version: batman-adv protocol version, part of the genereal header
+ * @ttl: time to live for this packet, part of the genereal header
  * @dest: final destination used when routing fragments
  * @orig: originator of the fragment used when merging the packet
  * @no: fragment number within this sequence
@@ -289,7 +300,9 @@ struct batadv_unicast_4addr_packet {
  * @total_size: size of the merged packet
  */
 struct batadv_frag_packet {
-	struct  batadv_header header;
+	uint8_t packet_type;
+	uint8_t version;  /* batman version field */
+	uint8_t ttl;
 #if defined(__BIG_ENDIAN_BITFIELD)
 	uint8_t no:4;
 	uint8_t reserved:4;
@@ -305,8 +318,19 @@ struct batadv_frag_packet {
 	__be16  total_size;
 };
 
+/**
+ * struct batadv_bcast_packet - broadcast packet for network payload
+ * @packet_type: batman-adv packet type, part of the general header
+ * @version: batman-adv protocol version, part of the genereal header
+ * @ttl: time to live for this packet, part of the genereal header
+ * @reserved: reserved byte for alignment
+ * @seqno: sequence identification
+ * @orig: originator of the broadcast packet
+ */
 struct batadv_bcast_packet {
-	struct batadv_header header;
+	uint8_t  packet_type;
+	uint8_t  version;  /* batman version field */
+	uint8_t  ttl;
 	uint8_t  reserved;
 	__be32   seqno;
 	uint8_t  orig[ETH_ALEN];
@@ -317,7 +341,9 @@ struct batadv_bcast_packet {
 
 /**
  * struct batadv_coded_packet - network coded packet
- * @header: common batman packet header and ttl of first included packet
+ * @packet_type: batman-adv packet type, part of the general header
+ * @version: batman-adv protocol version, part of the genereal header
+ * @ttl: time to live for this packet, part of the genereal header
  * @reserved: Align following fields to 2-byte boundaries
  * @first_source: original source of first included packet
  * @first_orig_dest: original destinal of first included packet
@@ -332,7 +358,9 @@ struct batadv_bcast_packet {
  * @coded_len: length of network coded part of the payload
  */
 struct batadv_coded_packet {
-	struct batadv_header header;
+	uint8_t  packet_type;
+	uint8_t  version;  /* batman version field */
+	uint8_t  ttl;
 	uint8_t  first_ttvn;
 	/* uint8_t  first_dest[ETH_ALEN]; - saved in mac header destination */
 	uint8_t  first_source[ETH_ALEN];
@@ -351,7 +379,9 @@ struct batadv_coded_packet {
 
 /**
  * struct batadv_unicast_tvlv - generic unicast packet with tvlv payload
- * @header: common batman packet header
+ * @packet_type: batman-adv packet type, part of the general header
+ * @version: batman-adv protocol version, part of the genereal header
+ * @ttl: time to live for this packet, part of the genereal header
  * @reserved: reserved field (for packet alignment)
  * @src: address of the source
  * @dst: address of the destination
@@ -359,7 +389,9 @@ struct batadv_coded_packet {
  * @align: 2 bytes to align the header to a 4 byte boundry
  */
 struct batadv_unicast_tvlv_packet {
-	struct batadv_header header;
+	uint8_t  packet_type;
+	uint8_t  version;  /* batman version field */
+	uint8_t  ttl;
 	uint8_t  reserved;
 	uint8_t  dst[ETH_ALEN];
 	uint8_t  src[ETH_ALEN];
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index d4114d7..5b52d71 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -308,7 +308,7 @@ static int batadv_recv_my_icmp_packet(struct batadv_priv *bat_priv,
 		memcpy(icmph->dst, icmph->orig, ETH_ALEN);
 		memcpy(icmph->orig, primary_if->net_dev->dev_addr, ETH_ALEN);
 		icmph->msg_type = BATADV_ECHO_REPLY;
-		icmph->header.ttl = BATADV_TTL;
+		icmph->ttl = BATADV_TTL;
 
 		res = batadv_send_skb_to_orig(skb, orig_node, NULL);
 		if (res != NET_XMIT_DROP)
@@ -363,7 +363,7 @@ static int batadv_recv_icmp_ttl_exceeded(struct batadv_priv *bat_priv,
 	memcpy(icmp_packet->icmph.orig, primary_if->net_dev->dev_addr,
 	       ETH_ALEN);
 	icmp_packet->icmph.msg_type = BATADV_TTL_EXCEEDED;
-	icmp_packet->icmph.header.ttl = BATADV_TTL;
+	icmp_packet->icmph.ttl = BATADV_TTL;
 
 	if (batadv_send_skb_to_orig(skb, orig_node, NULL) != NET_XMIT_DROP)
 		ret = NET_RX_SUCCESS;
@@ -434,7 +434,7 @@ int batadv_recv_icmp_packet(struct sk_buff *skb,
 		return batadv_recv_my_icmp_packet(bat_priv, skb);
 
 	/* TTL exceeded */
-	if (icmph->header.ttl < 2)
+	if (icmph->ttl < 2)
 		return batadv_recv_icmp_ttl_exceeded(bat_priv, skb);
 
 	/* get routing information */
@@ -449,7 +449,7 @@ int batadv_recv_icmp_packet(struct sk_buff *skb,
 	icmph = (struct batadv_icmp_header *)skb->data;
 
 	/* decrement ttl */
-	icmph->header.ttl--;
+	icmph->ttl--;
 
 	/* route it */
 	if (batadv_send_skb_to_orig(skb, orig_node, recv_if) != NET_XMIT_DROP)
@@ -709,7 +709,7 @@ static int batadv_route_unicast_packet(struct sk_buff *skb,
 	unicast_packet = (struct batadv_unicast_packet *)skb->data;
 
 	/* TTL exceeded */
-	if (unicast_packet->header.ttl < 2) {
+	if (unicast_packet->ttl < 2) {
 		pr_debug("Warning - can't forward unicast packet from %pM to %pM: ttl exceeded\n",
 			 ethhdr->h_source, unicast_packet->dest);
 		goto out;
@@ -727,9 +727,9 @@ static int batadv_route_unicast_packet(struct sk_buff *skb,
 
 	/* decrement ttl */
 	unicast_packet = (struct batadv_unicast_packet *)skb->data;
-	unicast_packet->header.ttl--;
+	unicast_packet->ttl--;
 
-	switch (unicast_packet->header.packet_type) {
+	switch (unicast_packet->packet_type) {
 	case BATADV_UNICAST_4ADDR:
 		hdr_len = sizeof(struct batadv_unicast_4addr_packet);
 		break;
@@ -970,7 +970,7 @@ int batadv_recv_unicast_packet(struct sk_buff *skb,
 	unicast_packet = (struct batadv_unicast_packet *)skb->data;
 	unicast_4addr_packet = (struct batadv_unicast_4addr_packet *)skb->data;
 
-	is4addr = unicast_packet->header.packet_type == BATADV_UNICAST_4ADDR;
+	is4addr = unicast_packet->packet_type == BATADV_UNICAST_4ADDR;
 	/* the caller function should have already pulled 2 bytes */
 	if (is4addr)
 		hdr_size = sizeof(*unicast_4addr_packet);
@@ -1160,7 +1160,7 @@ int batadv_recv_bcast_packet(struct sk_buff *skb,
 	if (batadv_is_my_mac(bat_priv, bcast_packet->orig))
 		goto out;
 
-	if (bcast_packet->header.ttl < 2)
+	if (bcast_packet->ttl < 2)
 		goto out;
 
 	orig_node = batadv_orig_hash_find(bat_priv, bcast_packet->orig);
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index c83be5e..fba4dcf 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -161,11 +161,11 @@ batadv_send_skb_push_fill_unicast(struct sk_buff *skb, int hdr_size,
 		return false;
 
 	unicast_packet = (struct batadv_unicast_packet *)skb->data;
-	unicast_packet->header.version = BATADV_COMPAT_VERSION;
+	unicast_packet->version = BATADV_COMPAT_VERSION;
 	/* batman packet type: unicast */
-	unicast_packet->header.packet_type = BATADV_UNICAST;
+	unicast_packet->packet_type = BATADV_UNICAST;
 	/* set unicast ttl */
-	unicast_packet->header.ttl = BATADV_TTL;
+	unicast_packet->ttl = BATADV_TTL;
 	/* copy the destination for faster routing */
 	memcpy(unicast_packet->dest, orig_node->orig, ETH_ALEN);
 	/* set the destination tt version number */
@@ -221,7 +221,7 @@ bool batadv_send_skb_prepare_unicast_4addr(struct batadv_priv *bat_priv,
 		goto out;
 
 	uc_4addr_packet = (struct batadv_unicast_4addr_packet *)skb->data;
-	uc_4addr_packet->u.header.packet_type = BATADV_UNICAST_4ADDR;
+	uc_4addr_packet->u.packet_type = BATADV_UNICAST_4ADDR;
 	memcpy(uc_4addr_packet->src, primary_if->net_dev->dev_addr, ETH_ALEN);
 	uc_4addr_packet->subtype = packet_subtype;
 	uc_4addr_packet->reserved = 0;
@@ -436,7 +436,7 @@ int batadv_add_bcast_packet_to_list(struct batadv_priv *bat_priv,
 
 	/* as we have a copy now, it is safe to decrease the TTL */
 	bcast_packet = (struct batadv_bcast_packet *)newskb->data;
-	bcast_packet->header.ttl--;
+	bcast_packet->ttl--;
 
 	skb_reset_mac_header(newskb);
 
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 59b7397..74f4630 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -264,11 +264,11 @@ static int batadv_interface_tx(struct sk_buff *skb,
 			goto dropped;
 
 		bcast_packet = (struct batadv_bcast_packet *)skb->data;
-		bcast_packet->header.version = BATADV_COMPAT_VERSION;
-		bcast_packet->header.ttl = BATADV_TTL;
+		bcast_packet->version = BATADV_COMPAT_VERSION;
+		bcast_packet->ttl = BATADV_TTL;
 
 		/* batman packet type: broadcast */
-		bcast_packet->header.packet_type = BATADV_BCAST;
+		bcast_packet->packet_type = BATADV_BCAST;
 		bcast_packet->reserved = 0;
 
 		/* hw address of first interface is the orig mac because only
@@ -328,7 +328,7 @@ void batadv_interface_rx(struct net_device *soft_iface,
 			 struct sk_buff *skb, struct batadv_hard_iface *recv_if,
 			 int hdr_size, struct batadv_orig_node *orig_node)
 {
-	struct batadv_header *batadv_header = (struct batadv_header *)skb->data;
+	struct batadv_bcast_packet *batadv_bcast_packet;
 	struct batadv_priv *bat_priv = netdev_priv(soft_iface);
 	__be16 ethertype = htons(ETH_P_BATMAN);
 	struct vlan_ethhdr *vhdr;
@@ -336,7 +336,8 @@ void batadv_interface_rx(struct net_device *soft_iface,
 	unsigned short vid;
 	bool is_bcast;
 
-	is_bcast = (batadv_header->packet_type == BATADV_BCAST);
+	batadv_bcast_packet = (struct batadv_bcast_packet *)skb->data;
+	is_bcast = (batadv_bcast_packet->packet_type == BATADV_BCAST);
 
 	/* check if enough space is available for pulling, and pull */
 	if (!pskb_may_pull(skb, hdr_size))
-- 
1.8.5.1
