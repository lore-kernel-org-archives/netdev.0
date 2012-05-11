From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 12/15] batman-adv: avoid temporary routing loops by being strict on forwarded OGMs
Date: Fri, 11 May 2012 14:21:29 +0200
Message-ID: <1336738892-7401-13-git-send-email-ordex@autistici.org>
References: <1336738892-7401-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:58858 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758403Ab2EKMZg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2012 08:25:36 -0400
In-Reply-To: <1336738892-7401-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

batman-adv would forward OGMs from non-besthops while replacing the the TQ
and TTL values with the values from the best hop. In certain corner cases
this leads to a temporary routing loop.
This patch changes this behavior: Only packets from best next hops are
forwarded - TQ and TTL values won't be replaced anymore. However, the protocol
needs to rebroadcast OGMs from single hop neighbors regardless of whether or
not they are the best hop. To handle this case a new flag is introduced to
alert neighboring nodes about the forwarded OGM that is not from my best
next hop. It is to be discarded by all nodes except for the one originating
the OGM.

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Acked-by: Daniele Furlan <daniele.furlan@gmail.com>
Tested-by: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bat_iv_ogm.c |   60 ++++++++++++++++++++++---------------------
 net/batman-adv/packet.h     |    1 +
 2 files changed, 32 insertions(+), 29 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 9074e74..bafb473 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -507,11 +507,10 @@ static void bat_iv_ogm_forward(struct orig_node *orig_node,
 			       const struct ethhdr *ethhdr,
 			       struct batman_ogm_packet *batman_ogm_packet,
 			       bool is_single_hop_neigh,
+			       bool is_from_best_next_hop,
 			       struct hard_iface *if_incoming)
 {
 	struct bat_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
-	struct neigh_node *router;
-	uint8_t in_tq, in_ttl, tq_avg = 0;
 	uint8_t tt_num_changes;
 
 	if (batman_ogm_packet->header.ttl <= 1) {
@@ -519,41 +518,30 @@ static void bat_iv_ogm_forward(struct orig_node *orig_node,
 		return;
 	}
 
-	router = orig_node_get_router(orig_node);
+	if (!is_from_best_next_hop) {
+		/* Mark the forwarded packet when it is not coming from our
+		 * best next hop. We still need to forward the packet for our
+		 * neighbor link quality detection to work in case the packet
+		 * originated from a single hop neighbor. Otherwise we can
+		 * simply drop the ogm.
+		 */
+		if (is_single_hop_neigh)
+			batman_ogm_packet->flags |= NOT_BEST_NEXT_HOP;
+		else
+			return;
+	}
 
-	in_tq = batman_ogm_packet->tq;
-	in_ttl = batman_ogm_packet->header.ttl;
 	tt_num_changes = batman_ogm_packet->tt_num_changes;
 
 	batman_ogm_packet->header.ttl--;
 	memcpy(batman_ogm_packet->prev_sender, ethhdr->h_source, ETH_ALEN);
 
-	/* rebroadcast tq of our best ranking neighbor to ensure the rebroadcast
-	 * of our best tq value */
-	if (router && router->tq_avg != 0) {
-
-		/* rebroadcast ogm of best ranking neighbor as is */
-		if (!compare_eth(router->addr, ethhdr->h_source)) {
-			batman_ogm_packet->tq = router->tq_avg;
-
-			if (router->last_ttl)
-				batman_ogm_packet->header.ttl =
-					router->last_ttl - 1;
-		}
-
-		tq_avg = router->tq_avg;
-	}
-
-	if (router)
-		neigh_node_free_ref(router);
-
 	/* apply hop penalty */
 	batman_ogm_packet->tq = hop_penalty(batman_ogm_packet->tq, bat_priv);
 
 	bat_dbg(DBG_BATMAN, bat_priv,
-		"Forwarding packet: tq_orig: %i, tq_avg: %i, tq_forw: %i, ttl_orig: %i, ttl_forw: %i\n",
-		in_tq, tq_avg, batman_ogm_packet->tq, in_ttl - 1,
-		batman_ogm_packet->header.ttl);
+		"Forwarding packet: tq: %i, ttl: %i\n",
+		batman_ogm_packet->tq, batman_ogm_packet->header.ttl);
 
 	batman_ogm_packet->seqno = htonl(batman_ogm_packet->seqno);
 	batman_ogm_packet->tt_crc = htons(batman_ogm_packet->tt_crc);
@@ -949,6 +937,7 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 	int is_my_addr = 0, is_my_orig = 0, is_my_oldorig = 0;
 	int is_broadcast = 0, is_bidirectional;
 	bool is_single_hop_neigh = false;
+	bool is_from_best_next_hop = false;
 	int is_duplicate;
 	uint32_t if_incoming_seqno;
 
@@ -1070,6 +1059,13 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 		return;
 	}
 
+	if (batman_ogm_packet->flags & NOT_BEST_NEXT_HOP) {
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"Drop packet: ignoring all packets not forwarded from "
+			"the best next hop (sender: %pM)\n", ethhdr->h_source);
+		return;
+	}
+
 	orig_node = get_orig_node(bat_priv, batman_ogm_packet->orig);
 	if (!orig_node)
 		return;
@@ -1094,6 +1090,10 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 	if (router)
 		router_router = orig_node_get_router(router->orig_node);
 
+	if ((router && router->tq_avg != 0) &&
+	    (compare_eth(router->addr, ethhdr->h_source)))
+		is_from_best_next_hop = true;
+
 	/* avoid temporary routing loops */
 	if (router && router_router &&
 	    (compare_eth(router->addr, batman_ogm_packet->prev_sender)) &&
@@ -1144,7 +1144,8 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 
 		/* mark direct link on incoming interface */
 		bat_iv_ogm_forward(orig_node, ethhdr, batman_ogm_packet,
-				   is_single_hop_neigh, if_incoming);
+				   is_single_hop_neigh, is_from_best_next_hop,
+				   if_incoming);
 
 		bat_dbg(DBG_BATMAN, bat_priv,
 			"Forwarding packet: rebroadcast neighbor packet with direct link flag\n");
@@ -1167,7 +1168,8 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 	bat_dbg(DBG_BATMAN, bat_priv,
 		"Forwarding packet: rebroadcast originator packet\n");
 	bat_iv_ogm_forward(orig_node, ethhdr, batman_ogm_packet,
-			   is_single_hop_neigh, if_incoming);
+			   is_single_hop_neigh, is_from_best_next_hop,
+			   if_incoming);
 
 out_neigh:
 	if ((orig_neigh_node) && (!is_single_hop_neigh))
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index f54969c..0ee1af7 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -39,6 +39,7 @@ enum bat_packettype {
 #define COMPAT_VERSION 14
 
 enum batman_iv_flags {
+	NOT_BEST_NEXT_HOP   = 1 << 3,
 	PRIMARIES_FIRST_HOP = 1 << 4,
 	VIS_SERVER	    = 1 << 5,
 	DIRECTLINK	    = 1 << 6
-- 
1.7.9.4
