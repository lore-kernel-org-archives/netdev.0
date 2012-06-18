From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 14/19] batman-adv: don't bother flipping ->tt_crc
Date: Mon, 18 Jun 2012 22:39:18 +0200
Message-ID: <1340051963-14836-15-git-send-email-ordex@autistici.org>
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
	with ESMTP id S1753413Ab2FRUjP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2012 16:39:15 -0400
In-Reply-To: <1340051963-14836-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@ZenIV.linux.org.uk>

Keep it net-endian

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bat_iv_ogm.c |   10 ++--------
 net/batman-adv/packet.h     |    2 +-
 2 files changed, 3 insertions(+), 9 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 896287e..ec3542c 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -547,8 +547,6 @@ static void bat_iv_ogm_forward(struct orig_node *orig_node,
 		"Forwarding packet: tq: %i, ttl: %i\n",
 		batman_ogm_packet->tq, batman_ogm_packet->header.ttl);
 
-	batman_ogm_packet->tt_crc = htons(batman_ogm_packet->tt_crc);
-
 	/* switch of primaries first hop flag when forwarding */
 	batman_ogm_packet->flags &= ~PRIMARIES_FIRST_HOP;
 	if (is_single_hop_neigh)
@@ -724,7 +722,7 @@ update_tt:
 		tt_update_orig(bat_priv, orig_node, tt_buff,
 			       batman_ogm_packet->tt_num_changes,
 			       batman_ogm_packet->ttvn,
-			       batman_ogm_packet->tt_crc);
+			       ntohs(batman_ogm_packet->tt_crc));
 
 	if (orig_node->gw_flags != batman_ogm_packet->gw_flags)
 		gw_node_update(bat_priv, orig_node,
@@ -972,7 +970,7 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 		ethhdr->h_source, if_incoming->net_dev->name,
 		if_incoming->net_dev->dev_addr, batman_ogm_packet->orig,
 		batman_ogm_packet->prev_sender, ntohl(batman_ogm_packet->seqno),
-		batman_ogm_packet->ttvn, batman_ogm_packet->tt_crc,
+		batman_ogm_packet->ttvn, ntohs(batman_ogm_packet->tt_crc),
 		batman_ogm_packet->tt_num_changes, batman_ogm_packet->tq,
 		batman_ogm_packet->header.ttl,
 		batman_ogm_packet->header.version, has_directlink_flag);
@@ -1219,10 +1217,6 @@ static int bat_iv_ogm_receive(struct sk_buff *skb,
 
 	/* unpack the aggregated packets and process them one by one */
 	do {
-		/* network to host order for our 32bit seqno and the
-		   orig_interval */
-		batman_ogm_packet->tt_crc = ntohs(batman_ogm_packet->tt_crc);
-
 		tt_buff = packet_buff + buff_pos + BATMAN_OGM_HLEN;
 
 		bat_iv_ogm_process(ethhdr, batman_ogm_packet,
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 372fc88..033d994 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -124,7 +124,7 @@ struct batman_ogm_packet {
 	uint8_t  tq;
 	uint8_t  tt_num_changes;
 	uint8_t  ttvn; /* translation table version number */
-	uint16_t tt_crc;
+	__be16   tt_crc;
 } __packed;
 
 #define BATMAN_OGM_HLEN sizeof(struct batman_ogm_packet)
-- 
1.7.9.4
