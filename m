From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 13/19] batman-adv: don't bother flipping ->tt_data
Date: Mon, 18 Jun 2012 22:39:17 +0200
Message-ID: <1340051963-14836-14-git-send-email-ordex@autistici.org>
References: <1340051963-14836-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Al Viro <viro@ZenIV.linux.org.uk>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:41512 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753400Ab2FRUjO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2012 16:39:14 -0400
In-Reply-To: <1340051963-14836-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@ZenIV.linux.org.uk>

just keep it net-endian all along

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
[lindner_marek@yahoo.de: fix checkpatch warnings]
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/packet.h            |    2 +-
 net/batman-adv/routing.c           |   10 +++-------
 net/batman-adv/translation-table.c |   10 ++++++----
 3 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 5bf567b..372fc88 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -206,7 +206,7 @@ struct tt_query_packet {
 	 * if TT_REQUEST: crc associated with the
 	 *		  ttvn
 	 * if TT_RESPONSE: table_size */
-	uint16_t tt_data;
+	__be16   tt_data;
 } __packed;
 
 struct roam_adv_packet {
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 369604c..9cfd23c 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -573,7 +573,7 @@ int recv_tt_query(struct sk_buff *skb, struct hard_iface *recv_if)
 {
 	struct bat_priv *bat_priv = netdev_priv(recv_if->soft_iface);
 	struct tt_query_packet *tt_query;
-	uint16_t tt_len;
+	uint16_t tt_size;
 	struct ethhdr *ethhdr;
 
 	/* drop packet if it has not necessary minimum size */
@@ -596,8 +596,6 @@ int recv_tt_query(struct sk_buff *skb, struct hard_iface *recv_if)
 
 	tt_query = (struct tt_query_packet *)skb->data;
 
-	tt_query->tt_data = ntohs(tt_query->tt_data);
-
 	switch (tt_query->flags & TT_QUERY_TYPE_MASK) {
 	case TT_REQUEST:
 		batadv_inc_counter(bat_priv, BAT_CNT_TT_REQUEST_RX);
@@ -609,7 +607,6 @@ int recv_tt_query(struct sk_buff *skb, struct hard_iface *recv_if)
 				"Routing TT_REQUEST to %pM [%c]\n",
 				tt_query->dst,
 				(tt_query->flags & TT_FULL_TABLE ? 'F' : '.'));
-			tt_query->tt_data = htons(tt_query->tt_data);
 			return route_unicast_packet(skb, recv_if);
 		}
 		break;
@@ -624,11 +621,11 @@ int recv_tt_query(struct sk_buff *skb, struct hard_iface *recv_if)
 			/* skb_linearize() possibly changed skb->data */
 			tt_query = (struct tt_query_packet *)skb->data;
 
-			tt_len = tt_query->tt_data * sizeof(struct tt_change);
+			tt_size = tt_len(ntohs(tt_query->tt_data));
 
 			/* Ensure we have all the claimed data */
 			if (unlikely(skb_headlen(skb) <
-				     sizeof(struct tt_query_packet) + tt_len))
+				     sizeof(struct tt_query_packet) + tt_size))
 				goto out;
 
 			handle_tt_response(bat_priv, tt_query);
@@ -637,7 +634,6 @@ int recv_tt_query(struct sk_buff *skb, struct hard_iface *recv_if)
 				"Routing TT_RESPONSE to %pM [%c]\n",
 				tt_query->dst,
 				(tt_query->flags & TT_FULL_TABLE ? 'F' : '.'));
-			tt_query->tt_data = htons(tt_query->tt_data);
 			return route_unicast_packet(skb, recv_if);
 		}
 		break;
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 24e691d..88cfe2a 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -1418,7 +1418,7 @@ static bool send_other_tt_response(struct bat_priv *bat_priv,
 
 	/* I don't have the requested data */
 	if (orig_ttvn != req_ttvn ||
-	    tt_request->tt_data != req_dst_orig_node->tt_crc)
+	    tt_request->tt_data != htons(req_dst_orig_node->tt_crc))
 		goto out;
 
 	/* If the full table has been explicitly requested */
@@ -1678,7 +1678,7 @@ static void tt_fill_gtable(struct bat_priv *bat_priv,
 
 	_tt_update_changes(bat_priv, orig_node,
 			   (struct tt_change *)(tt_response + 1),
-			   tt_response->tt_data, tt_response->ttvn);
+			   ntohs(tt_response->tt_data), tt_response->ttvn);
 
 	spin_lock_bh(&orig_node->tt_buff_lock);
 	kfree(orig_node->tt_buff);
@@ -1733,7 +1733,8 @@ void handle_tt_response(struct bat_priv *bat_priv,
 
 	bat_dbg(DBG_TT, bat_priv,
 		"Received TT_RESPONSE from %pM for ttvn %d t_size: %d [%c]\n",
-		tt_response->src, tt_response->ttvn, tt_response->tt_data,
+		tt_response->src, tt_response->ttvn,
+		ntohs(tt_response->tt_data),
 		(tt_response->flags & TT_FULL_TABLE ? 'F' : '.'));
 
 	/* we should have never asked a backbone gw */
@@ -1747,7 +1748,8 @@ void handle_tt_response(struct bat_priv *bat_priv,
 	if (tt_response->flags & TT_FULL_TABLE)
 		tt_fill_gtable(bat_priv, tt_response);
 	else
-		tt_update_changes(bat_priv, orig_node, tt_response->tt_data,
+		tt_update_changes(bat_priv, orig_node,
+				  ntohs(tt_response->tt_data),
 				  tt_response->ttvn,
 				  (struct tt_change *)(tt_response + 1));
 
-- 
1.7.9.4
