From: Marek Lindner <lindner_marek@yahoo.de>
Subject: [PATCH 02/10] batman-adv: Explicitly mark the common header structure
Date: Fri, 17 Feb 2012 15:18:22 +0800
Message-ID: <1329463110-856-3-git-send-email-lindner_marek@yahoo.de>
References: <1329463110-856-1-git-send-email-lindner_marek@yahoo.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm10-vm0.bullet.mail.ukl.yahoo.com ([217.146.183.242]:32596
	"HELO nm10-vm0.bullet.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751163Ab2BQHS7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2012 02:18:59 -0500
In-Reply-To: <1329463110-856-1-git-send-email-lindner_marek@yahoo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

All batman-adv packets have a common 3 byte header. It can be used to share
some code between different code paths, but it was never explicit stated that
this header has to be always the same for all packets. Therefore, new code
changes always have the problem that they may accidently introduce regressions
by moving some elements around.

A new structure is introduced that contains the common header and makes it
easier visible that these 3 bytes have to be the same for all on-wire packets.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/bat_iv_ogm.c        |   47 ++++++++++++++++++-----------------
 net/batman-adv/hard-interface.c    |    6 ++--
 net/batman-adv/icmp_socket.c       |    6 ++--
 net/batman-adv/packet.h            |   38 ++++++++++-------------------
 net/batman-adv/routing.c           |   18 +++++++-------
 net/batman-adv/send.c              |    2 +-
 net/batman-adv/soft-interface.c    |   14 +++++-----
 net/batman-adv/translation-table.c |   24 +++++++++---------
 net/batman-adv/unicast.c           |   16 ++++++------
 net/batman-adv/vis.c               |   14 +++++-----
 10 files changed, 87 insertions(+), 98 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 3512e25..d60e1ba 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -38,10 +38,10 @@ void bat_ogm_init(struct hard_iface *hard_iface)
 	hard_iface->packet_buff = kmalloc(hard_iface->packet_len, GFP_ATOMIC);
 
 	batman_ogm_packet = (struct batman_ogm_packet *)hard_iface->packet_buff;
-	batman_ogm_packet->packet_type = BAT_OGM;
-	batman_ogm_packet->version = COMPAT_VERSION;
+	batman_ogm_packet->header.packet_type = BAT_OGM;
+	batman_ogm_packet->header.version = COMPAT_VERSION;
+	batman_ogm_packet->header.ttl = 2;
 	batman_ogm_packet->flags = NO_FLAGS;
-	batman_ogm_packet->ttl = 2;
 	batman_ogm_packet->tq = TQ_MAX_VALUE;
 	batman_ogm_packet->tt_num_changes = 0;
 	batman_ogm_packet->ttvn = 0;
@@ -53,7 +53,7 @@ void bat_ogm_init_primary(struct hard_iface *hard_iface)
 
 	batman_ogm_packet = (struct batman_ogm_packet *)hard_iface->packet_buff;
 	batman_ogm_packet->flags = PRIMARIES_FIRST_HOP;
-	batman_ogm_packet->ttl = TTL;
+	batman_ogm_packet->header.ttl = TTL;
 }
 
 void bat_ogm_update_mac(struct hard_iface *hard_iface)
@@ -137,7 +137,7 @@ static void bat_ogm_send_to_if(struct forw_packet *forw_packet,
 			fwd_str, (packet_num > 0 ? "aggregated " : ""),
 			batman_ogm_packet->orig,
 			ntohl(batman_ogm_packet->seqno),
-			batman_ogm_packet->tq, batman_ogm_packet->ttl,
+			batman_ogm_packet->tq, batman_ogm_packet->header.ttl,
 			(batman_ogm_packet->flags & DIRECTLINK ?
 			 "on" : "off"),
 			batman_ogm_packet->ttvn, hard_iface->net_dev->name,
@@ -188,7 +188,7 @@ void bat_ogm_emit(struct forw_packet *forw_packet)
 
 	/* multihomed peer assumed */
 	/* non-primary OGMs are only broadcasted on their interface */
-	if ((directlink && (batman_ogm_packet->ttl == 1)) ||
+	if ((directlink && (batman_ogm_packet->header.ttl == 1)) ||
 	    (forw_packet->own && (forw_packet->if_incoming != primary_if))) {
 
 		/* FIXME: what about aggregated packets ? */
@@ -198,7 +198,7 @@ void bat_ogm_emit(struct forw_packet *forw_packet)
 			(forw_packet->own ? "Sending own" : "Forwarding"),
 			batman_ogm_packet->orig,
 			ntohl(batman_ogm_packet->seqno),
-			batman_ogm_packet->ttl,
+			batman_ogm_packet->header.ttl,
 			forw_packet->if_incoming->net_dev->name,
 			forw_packet->if_incoming->net_dev->dev_addr);
 
@@ -272,7 +272,7 @@ static bool bat_ogm_can_aggregate(const struct batman_ogm_packet
 		 * are flooded through the net  */
 		if ((!directlink) &&
 		    (!(batman_ogm_packet->flags & DIRECTLINK)) &&
-		    (batman_ogm_packet->ttl != 1) &&
+		    (batman_ogm_packet->header.ttl != 1) &&
 
 		    /* own packets originating non-primary
 		     * interfaces leave only that interface */
@@ -285,7 +285,7 @@ static bool bat_ogm_can_aggregate(const struct batman_ogm_packet
 		/* if the incoming packet is sent via this one
 		 * interface only - we still can aggregate */
 		if ((directlink) &&
-		    (new_batman_ogm_packet->ttl == 1) &&
+		    (new_batman_ogm_packet->header.ttl == 1) &&
 		    (forw_packet->if_incoming == if_incoming) &&
 
 		    /* packets from direct neighbors or
@@ -471,7 +471,7 @@ static void bat_ogm_forward(struct orig_node *orig_node,
 	uint8_t in_tq, in_ttl, tq_avg = 0;
 	uint8_t tt_num_changes;
 
-	if (batman_ogm_packet->ttl <= 1) {
+	if (batman_ogm_packet->header.ttl <= 1) {
 		bat_dbg(DBG_BATMAN, bat_priv, "ttl exceeded\n");
 		return;
 	}
@@ -479,10 +479,10 @@ static void bat_ogm_forward(struct orig_node *orig_node,
 	router = orig_node_get_router(orig_node);
 
 	in_tq = batman_ogm_packet->tq;
-	in_ttl = batman_ogm_packet->ttl;
+	in_ttl = batman_ogm_packet->header.ttl;
 	tt_num_changes = batman_ogm_packet->tt_num_changes;
 
-	batman_ogm_packet->ttl--;
+	batman_ogm_packet->header.ttl--;
 	memcpy(batman_ogm_packet->prev_sender, ethhdr->h_source, ETH_ALEN);
 
 	/* rebroadcast tq of our best ranking neighbor to ensure the rebroadcast
@@ -494,7 +494,8 @@ static void bat_ogm_forward(struct orig_node *orig_node,
 			batman_ogm_packet->tq = router->tq_avg;
 
 			if (router->last_ttl)
-				batman_ogm_packet->ttl = router->last_ttl - 1;
+				batman_ogm_packet->header.ttl =
+					router->last_ttl - 1;
 		}
 
 		tq_avg = router->tq_avg;
@@ -510,7 +511,7 @@ static void bat_ogm_forward(struct orig_node *orig_node,
 		"Forwarding packet: tq_orig: %i, tq_avg: %i, "
 		"tq_forw: %i, ttl_orig: %i, ttl_forw: %i\n",
 		in_tq, tq_avg, batman_ogm_packet->tq, in_ttl - 1,
-		batman_ogm_packet->ttl);
+		batman_ogm_packet->header.ttl);
 
 	batman_ogm_packet->seqno = htonl(batman_ogm_packet->seqno);
 	batman_ogm_packet->tt_crc = htons(batman_ogm_packet->tt_crc);
@@ -642,8 +643,8 @@ static void bat_ogm_orig_update(struct bat_priv *bat_priv,
 	spin_unlock_bh(&neigh_node->tq_lock);
 
 	if (!is_duplicate) {
-		orig_node->last_ttl = batman_ogm_packet->ttl;
-		neigh_node->last_ttl = batman_ogm_packet->ttl;
+		orig_node->last_ttl = batman_ogm_packet->header.ttl;
+		neigh_node->last_ttl = batman_ogm_packet->header.ttl;
 	}
 
 	bonding_candidate_add(orig_node, neigh_node);
@@ -683,7 +684,7 @@ update_tt:
 	/* I have to check for transtable changes only if the OGM has been
 	 * sent through a primary interface */
 	if (((batman_ogm_packet->orig != ethhdr->h_source) &&
-	     (batman_ogm_packet->ttl > 2)) ||
+	     (batman_ogm_packet->header.ttl > 2)) ||
 	    (batman_ogm_packet->flags & PRIMARIES_FIRST_HOP))
 		tt_update_orig(bat_priv, orig_node, tt_buff,
 			       batman_ogm_packet->tt_num_changes,
@@ -918,7 +919,7 @@ static void bat_ogm_process(const struct ethhdr *ethhdr,
 	 * packet in an aggregation.  Here we expect that the padding
 	 * is always zero (or not 0x01)
 	 */
-	if (batman_ogm_packet->packet_type != BAT_OGM)
+	if (batman_ogm_packet->header.packet_type != BAT_OGM)
 		return;
 
 	/* could be changed by schedule_own_packet() */
@@ -938,8 +939,8 @@ static void bat_ogm_process(const struct ethhdr *ethhdr,
 		batman_ogm_packet->prev_sender, batman_ogm_packet->seqno,
 		batman_ogm_packet->ttvn, batman_ogm_packet->tt_crc,
 		batman_ogm_packet->tt_num_changes, batman_ogm_packet->tq,
-		batman_ogm_packet->ttl, batman_ogm_packet->version,
-		has_directlink_flag);
+		batman_ogm_packet->header.ttl,
+		batman_ogm_packet->header.version, has_directlink_flag);
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(hard_iface, &hardif_list, list) {
@@ -966,10 +967,10 @@ static void bat_ogm_process(const struct ethhdr *ethhdr,
 	}
 	rcu_read_unlock();
 
-	if (batman_ogm_packet->version != COMPAT_VERSION) {
+	if (batman_ogm_packet->header.version != COMPAT_VERSION) {
 		bat_dbg(DBG_BATMAN, bat_priv,
 			"Drop packet: incompatible batman version (%i)\n",
-			batman_ogm_packet->version);
+			batman_ogm_packet->header.version);
 		return;
 	}
 
@@ -1091,7 +1092,7 @@ static void bat_ogm_process(const struct ethhdr *ethhdr,
 	if (is_bidirectional &&
 	    (!is_duplicate ||
 	     ((orig_node->last_real_seqno == batman_ogm_packet->seqno) &&
-	      (orig_node->last_ttl - 3 <= batman_ogm_packet->ttl))))
+	      (orig_node->last_ttl - 3 <= batman_ogm_packet->header.ttl))))
 		bat_ogm_orig_update(bat_priv, orig_node, ethhdr,
 				    batman_ogm_packet, if_incoming,
 				    tt_buff, is_duplicate);
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 7704df4..d3e0e32 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -590,17 +590,17 @@ static int batman_skb_recv(struct sk_buff *skb, struct net_device *dev,
 
 	batman_ogm_packet = (struct batman_ogm_packet *)skb->data;
 
-	if (batman_ogm_packet->version != COMPAT_VERSION) {
+	if (batman_ogm_packet->header.version != COMPAT_VERSION) {
 		bat_dbg(DBG_BATMAN, bat_priv,
 			"Drop packet: incompatible batman version (%i)\n",
-			batman_ogm_packet->version);
+			batman_ogm_packet->header.version);
 		goto err_free;
 	}
 
 	/* all receive handlers return whether they received or reused
 	 * the supplied skb. if not, we have to free the skb. */
 
-	switch (batman_ogm_packet->packet_type) {
+	switch (batman_ogm_packet->header.packet_type) {
 		/* batman originator packet */
 	case BAT_OGM:
 		ret = recv_bat_ogm_packet(skb, hard_iface);
diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.c
index d9c1e7b..5d69e10 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -191,7 +191,7 @@ static ssize_t bat_socket_write(struct file *file, const char __user *buff,
 		goto free_skb;
 	}
 
-	if (icmp_packet->packet_type != BAT_ICMP) {
+	if (icmp_packet->header.packet_type != BAT_ICMP) {
 		bat_dbg(DBG_BATMAN, bat_priv,
 			"Error - can't send packet from char device: "
 			"got bogus packet type (expected: BAT_ICMP)\n");
@@ -209,9 +209,9 @@ static ssize_t bat_socket_write(struct file *file, const char __user *buff,
 
 	icmp_packet->uid = socket_client->index;
 
-	if (icmp_packet->version != COMPAT_VERSION) {
+	if (icmp_packet->header.version != COMPAT_VERSION) {
 		icmp_packet->msg_type = PARAMETER_PROBLEM;
-		icmp_packet->version = COMPAT_VERSION;
+		icmp_packet->header.version = COMPAT_VERSION;
 		bat_socket_add_packet(socket_client, icmp_packet, packet_len);
 		goto free_skb;
 	}
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 4d9e54c..88c717b 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -90,10 +90,14 @@ enum tt_client_flags {
 	TT_CLIENT_PENDING = 1 << 10
 };
 
-struct batman_ogm_packet {
+struct batman_header {
 	uint8_t  packet_type;
 	uint8_t  version;  /* batman version field */
 	uint8_t  ttl;
+} __packed;
+
+struct batman_ogm_packet {
+	struct batman_header header;
 	uint8_t  flags;    /* 0x40: DIRECTLINK flag, 0x20 VIS_SERVER flag... */
 	uint32_t seqno;
 	uint8_t  orig[6];
@@ -108,9 +112,7 @@ struct batman_ogm_packet {
 #define BATMAN_OGM_LEN sizeof(struct batman_ogm_packet)
 
 struct icmp_packet {
-	uint8_t  packet_type;
-	uint8_t  version;  /* batman version field */
-	uint8_t  ttl;
+	struct batman_header header;
 	uint8_t  msg_type; /* see ICMP message types above */
 	uint8_t  dst[6];
 	uint8_t  orig[6];
@@ -124,9 +126,7 @@ struct icmp_packet {
 /* icmp_packet_rr must start with all fields from imcp_packet
  * as this is assumed by code that handles ICMP packets */
 struct icmp_packet_rr {
-	uint8_t  packet_type;
-	uint8_t  version;  /* batman version field */
-	uint8_t  ttl;
+	struct batman_header header;
 	uint8_t  msg_type; /* see ICMP message types above */
 	uint8_t  dst[6];
 	uint8_t  orig[6];
@@ -137,17 +137,13 @@ struct icmp_packet_rr {
 } __packed;
 
 struct unicast_packet {
-	uint8_t  packet_type;
-	uint8_t  version;  /* batman version field */
-	uint8_t  ttl;
+	struct batman_header header;
 	uint8_t  ttvn; /* destination translation table version number */
 	uint8_t  dest[6];
 } __packed;
 
 struct unicast_frag_packet {
-	uint8_t  packet_type;
-	uint8_t  version;  /* batman version field */
-	uint8_t  ttl;
+	struct batman_header header;
 	uint8_t  ttvn; /* destination translation table version number */
 	uint8_t  dest[6];
 	uint8_t  flags;
@@ -157,18 +153,14 @@ struct unicast_frag_packet {
 } __packed;
 
 struct bcast_packet {
-	uint8_t  packet_type;
-	uint8_t  version;  /* batman version field */
-	uint8_t  ttl;
+	struct batman_header header;
 	uint8_t  reserved;
 	uint32_t seqno;
 	uint8_t  orig[6];
 } __packed;
 
 struct vis_packet {
-	uint8_t  packet_type;
-	uint8_t  version;        /* batman version field */
-	uint8_t  ttl;		 /* TTL */
+	struct batman_header header;
 	uint8_t  vis_type;	 /* which type of vis-participant sent this? */
 	uint32_t seqno;		 /* sequence number */
 	uint8_t  entries;	 /* number of entries behind this struct */
@@ -179,9 +171,7 @@ struct vis_packet {
 } __packed;
 
 struct tt_query_packet {
-	uint8_t  packet_type;
-	uint8_t  version;  /* batman version field */
-	uint8_t  ttl;
+	struct batman_header header;
 	/* the flag field is a combination of:
 	 * - TT_REQUEST or TT_RESPONSE
 	 * - TT_FULL_TABLE */
@@ -202,9 +192,7 @@ struct tt_query_packet {
 } __packed;
 
 struct roam_adv_packet {
-	uint8_t  packet_type;
-	uint8_t  version;
-	uint8_t  ttl;
+	struct batman_header header;
 	uint8_t  reserved;
 	uint8_t  dst[ETH_ALEN];
 	uint8_t  src[ETH_ALEN];
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 773e606..4363d19 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -320,7 +320,7 @@ static int recv_my_icmp_packet(struct bat_priv *bat_priv,
 	memcpy(icmp_packet->dst, icmp_packet->orig, ETH_ALEN);
 	memcpy(icmp_packet->orig, primary_if->net_dev->dev_addr, ETH_ALEN);
 	icmp_packet->msg_type = ECHO_REPLY;
-	icmp_packet->ttl = TTL;
+	icmp_packet->header.ttl = TTL;
 
 	send_skb_packet(skb, router->if_incoming, router->addr);
 	ret = NET_RX_SUCCESS;
@@ -376,7 +376,7 @@ static int recv_icmp_ttl_exceeded(struct bat_priv *bat_priv,
 	memcpy(icmp_packet->dst, icmp_packet->orig, ETH_ALEN);
 	memcpy(icmp_packet->orig, primary_if->net_dev->dev_addr, ETH_ALEN);
 	icmp_packet->msg_type = TTL_EXCEEDED;
-	icmp_packet->ttl = TTL;
+	icmp_packet->header.ttl = TTL;
 
 	send_skb_packet(skb, router->if_incoming, router->addr);
 	ret = NET_RX_SUCCESS;
@@ -441,7 +441,7 @@ int recv_icmp_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 		return recv_my_icmp_packet(bat_priv, skb, hdr_size);
 
 	/* TTL exceeded */
-	if (icmp_packet->ttl < 2)
+	if (icmp_packet->header.ttl < 2)
 		return recv_icmp_ttl_exceeded(bat_priv, skb);
 
 	/* get routing information */
@@ -460,7 +460,7 @@ int recv_icmp_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 	icmp_packet = (struct icmp_packet_rr *)skb->data;
 
 	/* decrement ttl */
-	icmp_packet->ttl--;
+	icmp_packet->header.ttl--;
 
 	/* route it */
 	send_skb_packet(skb, router->if_incoming, router->addr);
@@ -815,7 +815,7 @@ int route_unicast_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 	unicast_packet = (struct unicast_packet *)skb->data;
 
 	/* TTL exceeded */
-	if (unicast_packet->ttl < 2) {
+	if (unicast_packet->header.ttl < 2) {
 		pr_debug("Warning - can't forward unicast packet from %pM to "
 			 "%pM: ttl exceeded\n", ethhdr->h_source,
 			 unicast_packet->dest);
@@ -840,7 +840,7 @@ int route_unicast_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 
 	unicast_packet = (struct unicast_packet *)skb->data;
 
-	if (unicast_packet->packet_type == BAT_UNICAST &&
+	if (unicast_packet->header.packet_type == BAT_UNICAST &&
 	    atomic_read(&bat_priv->fragmentation) &&
 	    skb->len > neigh_node->if_incoming->net_dev->mtu) {
 		ret = frag_send_skb(skb, bat_priv,
@@ -848,7 +848,7 @@ int route_unicast_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 		goto out;
 	}
 
-	if (unicast_packet->packet_type == BAT_UNICAST_FRAG &&
+	if (unicast_packet->header.packet_type == BAT_UNICAST_FRAG &&
 	    frag_can_reassemble(skb, neigh_node->if_incoming->net_dev->mtu)) {
 
 		ret = frag_reassemble_skb(skb, bat_priv, &new_skb);
@@ -867,7 +867,7 @@ int route_unicast_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 	}
 
 	/* decrement ttl */
-	unicast_packet->ttl--;
+	unicast_packet->header.ttl--;
 
 	/* route it */
 	send_skb_packet(skb, neigh_node->if_incoming, neigh_node->addr);
@@ -1041,7 +1041,7 @@ int recv_bcast_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 	if (is_my_mac(bcast_packet->orig))
 		goto out;
 
-	if (bcast_packet->ttl < 2)
+	if (bcast_packet->header.ttl < 2)
 		goto out;
 
 	orig_node = orig_hash_find(bat_priv, bcast_packet->orig);
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 8a684eb..b00a0f5 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -234,7 +234,7 @@ int add_bcast_packet_to_list(struct bat_priv *bat_priv,
 
 	/* as we have a copy now, it is safe to decrease the TTL */
 	bcast_packet = (struct bcast_packet *)newskb->data;
-	bcast_packet->ttl--;
+	bcast_packet->header.ttl--;
 
 	skb_reset_mac_header(newskb);
 
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 987c75a..bd8c7cf 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -457,10 +457,10 @@ static void softif_batman_recv(struct sk_buff *skb, struct net_device *dev,
 		batman_ogm_packet = (struct batman_ogm_packet *)
 							(skb->data + ETH_HLEN);
 
-	if (batman_ogm_packet->version != COMPAT_VERSION)
+	if (batman_ogm_packet->header.version != COMPAT_VERSION)
 		goto out;
 
-	if (batman_ogm_packet->packet_type != BAT_OGM)
+	if (batman_ogm_packet->header.packet_type != BAT_OGM)
 		goto out;
 
 	if (!(batman_ogm_packet->flags & PRIMARIES_FIRST_HOP))
@@ -632,11 +632,11 @@ static int interface_tx(struct sk_buff *skb, struct net_device *soft_iface)
 			goto dropped;
 
 		bcast_packet = (struct bcast_packet *)skb->data;
-		bcast_packet->version = COMPAT_VERSION;
-		bcast_packet->ttl = TTL;
+		bcast_packet->header.version = COMPAT_VERSION;
+		bcast_packet->header.ttl = TTL;
 
 		/* batman packet type: broadcast */
-		bcast_packet->packet_type = BAT_BCAST;
+		bcast_packet->header.packet_type = BAT_BCAST;
 
 		/* hw address of first interface is the orig mac because only
 		 * this mac is known throughout the mesh */
@@ -725,8 +725,8 @@ void interface_rx(struct net_device *soft_iface,
 		skb_push(skb, hdr_size);
 		unicast_packet = (struct unicast_packet *)skb->data;
 
-		if ((unicast_packet->packet_type != BAT_UNICAST) &&
-		    (unicast_packet->packet_type != BAT_UNICAST_FRAG))
+		if ((unicast_packet->header.packet_type != BAT_UNICAST) &&
+		    (unicast_packet->header.packet_type != BAT_UNICAST_FRAG))
 			goto dropped;
 
 		skb_reset_mac_header(skb);
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index c632475..bc518fc 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -1135,11 +1135,11 @@ static int send_tt_request(struct bat_priv *bat_priv,
 	tt_request = (struct tt_query_packet *)skb_put(skb,
 				sizeof(struct tt_query_packet));
 
-	tt_request->packet_type = BAT_TT_QUERY;
-	tt_request->version = COMPAT_VERSION;
+	tt_request->header.packet_type = BAT_TT_QUERY;
+	tt_request->header.version = COMPAT_VERSION;
 	memcpy(tt_request->src, primary_if->net_dev->dev_addr, ETH_ALEN);
 	memcpy(tt_request->dst, dst_orig_node->orig, ETH_ALEN);
-	tt_request->ttl = TTL;
+	tt_request->header.ttl = TTL;
 	tt_request->ttvn = ttvn;
 	tt_request->tt_data = tt_crc;
 	tt_request->flags = TT_REQUEST;
@@ -1265,9 +1265,9 @@ static bool send_other_tt_response(struct bat_priv *bat_priv,
 		tt_response = (struct tt_query_packet *)skb->data;
 	}
 
-	tt_response->packet_type = BAT_TT_QUERY;
-	tt_response->version = COMPAT_VERSION;
-	tt_response->ttl = TTL;
+	tt_response->header.packet_type = BAT_TT_QUERY;
+	tt_response->header.version = COMPAT_VERSION;
+	tt_response->header.ttl = TTL;
 	memcpy(tt_response->src, req_dst_orig_node->orig, ETH_ALEN);
 	memcpy(tt_response->dst, tt_request->src, ETH_ALEN);
 	tt_response->flags = TT_RESPONSE;
@@ -1382,9 +1382,9 @@ static bool send_my_tt_response(struct bat_priv *bat_priv,
 		tt_response = (struct tt_query_packet *)skb->data;
 	}
 
-	tt_response->packet_type = BAT_TT_QUERY;
-	tt_response->version = COMPAT_VERSION;
-	tt_response->ttl = TTL;
+	tt_response->header.packet_type = BAT_TT_QUERY;
+	tt_response->header.version = COMPAT_VERSION;
+	tt_response->header.ttl = TTL;
 	memcpy(tt_response->src, primary_if->net_dev->dev_addr, ETH_ALEN);
 	memcpy(tt_response->dst, tt_request->src, ETH_ALEN);
 	tt_response->flags = TT_RESPONSE;
@@ -1671,9 +1671,9 @@ void send_roam_adv(struct bat_priv *bat_priv, uint8_t *client,
 	roam_adv_packet = (struct roam_adv_packet *)skb_put(skb,
 					sizeof(struct roam_adv_packet));
 
-	roam_adv_packet->packet_type = BAT_ROAM_ADV;
-	roam_adv_packet->version = COMPAT_VERSION;
-	roam_adv_packet->ttl = TTL;
+	roam_adv_packet->header.packet_type = BAT_ROAM_ADV;
+	roam_adv_packet->header.version = COMPAT_VERSION;
+	roam_adv_packet->header.ttl = TTL;
 	primary_if = primary_if_get_selected(bat_priv);
 	if (!primary_if)
 		goto out;
diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index 07d1c1d..6f3c659 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -67,7 +67,7 @@ static struct sk_buff *frag_merge_packet(struct list_head *head,
 
 	memmove(skb->data + uni_diff, skb->data, hdr_len);
 	unicast_packet = (struct unicast_packet *) skb_pull(skb, uni_diff);
-	unicast_packet->packet_type = BAT_UNICAST;
+	unicast_packet->header.packet_type = BAT_UNICAST;
 
 	return skb;
 
@@ -251,9 +251,9 @@ int frag_send_skb(struct sk_buff *skb, struct bat_priv *bat_priv,
 
 	memcpy(frag1, &tmp_uc, sizeof(tmp_uc));
 
-	frag1->ttl--;
-	frag1->version = COMPAT_VERSION;
-	frag1->packet_type = BAT_UNICAST_FRAG;
+	frag1->header.ttl--;
+	frag1->header.version = COMPAT_VERSION;
+	frag1->header.packet_type = BAT_UNICAST_FRAG;
 
 	memcpy(frag1->orig, primary_if->net_dev->dev_addr, ETH_ALEN);
 	memcpy(frag2, frag1, sizeof(*frag2));
@@ -320,11 +320,11 @@ find_router:
 
 	unicast_packet = (struct unicast_packet *)skb->data;
 
-	unicast_packet->version = COMPAT_VERSION;
+	unicast_packet->header.version = COMPAT_VERSION;
 	/* batman packet type: unicast */
-	unicast_packet->packet_type = BAT_UNICAST;
+	unicast_packet->header.packet_type = BAT_UNICAST;
 	/* set unicast ttl */
-	unicast_packet->ttl = TTL;
+	unicast_packet->header.ttl = TTL;
 	/* copy the destination for faster routing */
 	memcpy(unicast_packet->dest, orig_node->orig, ETH_ALEN);
 	/* set the destination tt version number */
@@ -335,7 +335,7 @@ find_router:
 	    data_len + sizeof(*unicast_packet) >
 				neigh_node->if_incoming->net_dev->mtu) {
 		/* send frag skb decreases ttl */
-		unicast_packet->ttl++;
+		unicast_packet->header.ttl++;
 		ret = frag_send_skb(skb, bat_priv,
 				    neigh_node->if_incoming, neigh_node->addr);
 		goto out;
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index cc3b9f2..ac7e661 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -617,7 +617,7 @@ static int generate_vis_packet(struct bat_priv *bat_priv)
 	packet->vis_type = atomic_read(&bat_priv->vis_mode);
 
 	memcpy(packet->target_orig, broadcast_addr, ETH_ALEN);
-	packet->ttl = TTL;
+	packet->header.ttl = TTL;
 	packet->seqno = htonl(ntohl(packet->seqno) + 1);
 	packet->entries = 0;
 	skb_trim(info->skb_packet, sizeof(*packet));
@@ -818,19 +818,19 @@ static void send_vis_packet(struct bat_priv *bat_priv, struct vis_info *info)
 		goto out;
 
 	packet = (struct vis_packet *)info->skb_packet->data;
-	if (packet->ttl < 2) {
+	if (packet->header.ttl < 2) {
 		pr_debug("Error - can't send vis packet: ttl exceeded\n");
 		goto out;
 	}
 
 	memcpy(packet->sender_orig, primary_if->net_dev->dev_addr, ETH_ALEN);
-	packet->ttl--;
+	packet->header.ttl--;
 
 	if (is_broadcast_ether_addr(packet->target_orig))
 		broadcast_vis_packet(bat_priv, info);
 	else
 		unicast_vis_packet(bat_priv, info);
-	packet->ttl++; /* restore TTL */
+	packet->header.ttl++; /* restore TTL */
 
 out:
 	if (primary_if)
@@ -910,9 +910,9 @@ int vis_init(struct bat_priv *bat_priv)
 	INIT_LIST_HEAD(&bat_priv->my_vis_info->send_list);
 	kref_init(&bat_priv->my_vis_info->refcount);
 	bat_priv->my_vis_info->bat_priv = bat_priv;
-	packet->version = COMPAT_VERSION;
-	packet->packet_type = BAT_VIS;
-	packet->ttl = TTL;
+	packet->header.version = COMPAT_VERSION;
+	packet->header.packet_type = BAT_VIS;
+	packet->header.ttl = TTL;
 	packet->seqno = 0;
 	packet->entries = 0;
 
-- 
1.7.9
