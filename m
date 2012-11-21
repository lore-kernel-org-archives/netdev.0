From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 7/9] batman-adv: Fix broadcast duplist for fragmentation
Date: Wed, 21 Nov 2012 13:11:57 +0100
Message-ID: <1353499919-28596-8-git-send-email-ordex@autistici.org>
References: <1353499919-28596-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>,
	Simon Wunderlich <siwu@hrz.tu-chemnitz.de>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:50712 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753329Ab2KUMNG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2012 07:13:06 -0500
In-Reply-To: <1353499919-28596-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>

If the skb is fragmented, the checksum must be computed on the
individual fragments, just using skb->data may fail on fragmented
data. Instead of doing linearizing the packet, use the new
batadv_crc32 to do that more efficiently- it should not hurt
replacing the old crc16 by the new crc32.

Reported-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bridge_loop_avoidance.c | 18 +++++++-----------
 net/batman-adv/bridge_loop_avoidance.h |  6 ++----
 net/batman-adv/routing.c               |  8 +-------
 net/batman-adv/types.h                 |  2 +-
 4 files changed, 11 insertions(+), 23 deletions(-)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 7ffef8b..5aebe93 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -1249,8 +1249,7 @@ int batadv_bla_init(struct batadv_priv *bat_priv)
 /**
  * batadv_bla_check_bcast_duplist
  * @bat_priv: the bat priv with all the soft interface information
- * @bcast_packet: encapsulated broadcast frame plus batman header
- * @bcast_packet_len: length of encapsulated broadcast frame plus batman header
+ * @skb: contains the bcast_packet to be checked
  *
  * check if it is on our broadcast list. Another gateway might
  * have sent the same packet because it is connected to the same backbone,
@@ -1262,20 +1261,17 @@ int batadv_bla_init(struct batadv_priv *bat_priv)
  * the same host however as this might be intended.
  */
 int batadv_bla_check_bcast_duplist(struct batadv_priv *bat_priv,
-				   struct batadv_bcast_packet *bcast_packet,
-				   int bcast_packet_len)
+				   struct sk_buff *skb)
 {
-	int i, length, curr, ret = 0;
-	uint8_t *content;
-	uint16_t crc;
+	int i, curr, ret = 0;
+	__be32 crc;
+	struct batadv_bcast_packet *bcast_packet;
 	struct batadv_bcast_duplist_entry *entry;
 
-	length = bcast_packet_len - sizeof(*bcast_packet);
-	content = (uint8_t *)bcast_packet;
-	content += sizeof(*bcast_packet);
+	bcast_packet = (struct batadv_bcast_packet *)skb->data;
 
 	/* calculate the crc ... */
-	crc = crc16(0, content, length);
+	crc = batadv_skb_crc32(skb, (u8 *)(bcast_packet + 1));
 
 	spin_lock_bh(&bat_priv->bla.bcast_duplist_lock);
 
diff --git a/net/batman-adv/bridge_loop_avoidance.h b/net/batman-adv/bridge_loop_avoidance.h
index 789cb73..196d9a0 100644
--- a/net/batman-adv/bridge_loop_avoidance.h
+++ b/net/batman-adv/bridge_loop_avoidance.h
@@ -31,8 +31,7 @@ int batadv_bla_backbone_table_seq_print_text(struct seq_file *seq,
 					     void *offset);
 int batadv_bla_is_backbone_gw_orig(struct batadv_priv *bat_priv, uint8_t *orig);
 int batadv_bla_check_bcast_duplist(struct batadv_priv *bat_priv,
-				   struct batadv_bcast_packet *bcast_packet,
-				   int hdr_size);
+				   struct sk_buff *skb);
 void batadv_bla_update_orig_address(struct batadv_priv *bat_priv,
 				    struct batadv_hard_iface *primary_if,
 				    struct batadv_hard_iface *oldif);
@@ -81,8 +80,7 @@ static inline int batadv_bla_is_backbone_gw_orig(struct batadv_priv *bat_priv,
 
 static inline int
 batadv_bla_check_bcast_duplist(struct batadv_priv *bat_priv,
-			       struct batadv_bcast_packet *bcast_packet,
-			       int hdr_size)
+			       struct sk_buff *skb)
 {
 	return 0;
 }
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 8d64348..1aa1722 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -1196,14 +1196,8 @@ int batadv_recv_bcast_packet(struct sk_buff *skb,
 
 	spin_unlock_bh(&orig_node->bcast_seqno_lock);
 
-	/* keep skb linear for crc calculation */
-	if (skb_linearize(skb) < 0)
-		goto out;
-
-	bcast_packet = (struct batadv_bcast_packet *)skb->data;
-
 	/* check whether this has been sent by another originator before */
-	if (batadv_bla_check_bcast_duplist(bat_priv, bcast_packet, skb->len))
+	if (batadv_bla_check_bcast_duplist(bat_priv, skb))
 		goto out;
 
 	/* rebroadcast packet */
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 7b3d0d7..ae9ac9a 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -156,7 +156,7 @@ struct batadv_neigh_node {
 #ifdef CONFIG_BATMAN_ADV_BLA
 struct batadv_bcast_duplist_entry {
 	uint8_t orig[ETH_ALEN];
-	uint16_t crc;
+	__be32 crc;
 	unsigned long entrytime;
 };
 #endif
-- 
1.8.0
