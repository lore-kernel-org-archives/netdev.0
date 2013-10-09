From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 09/16] batman-adv: tvlv - convert roaming adv packet to use tvlv unicast packets
Date: Wed,  9 Oct 2013 14:40:11 +0200
Message-ID: <1381322418-1349-10-git-send-email-antonio@meshcoding.com>
References: <1381322418-1349-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:16417 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753988Ab3JIMlb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 08:41:31 -0400
In-Reply-To: <1381322418-1349-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

Instead of generating roaming specific packets the TVLV unicast API is
used to send roaming information.

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/main.c              |   2 -
 net/batman-adv/packet.h            |  21 ++++----
 net/batman-adv/routing.c           |  42 ---------------
 net/batman-adv/translation-table.c | 105 ++++++++++++++++++++++++++-----------
 4 files changed, 86 insertions(+), 84 deletions(-)

diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 39d9b44..fc55acb 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -414,8 +414,6 @@ static void batadv_recv_handler_init(void)
 	batadv_rx_handler[BATADV_BCAST] = batadv_recv_bcast_packet;
 	/* vis packet */
 	batadv_rx_handler[BATADV_VIS] = batadv_recv_vis_packet;
-	/* Roaming advertisement */
-	batadv_rx_handler[BATADV_ROAM_ADV] = batadv_recv_roam_adv;
 	/* unicast tvlv packet */
 	batadv_rx_handler[BATADV_UNICAST_TVLV] = batadv_recv_unicast_tvlv;
 }
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index a602efc..5c08d26 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -31,7 +31,6 @@ enum batadv_packettype {
 	BATADV_BCAST		= 0x04,
 	BATADV_VIS		= 0x05,
 	BATADV_UNICAST_FRAG	= 0x06,
-	BATADV_ROAM_ADV		= 0x08,
 	BATADV_UNICAST_4ADDR	= 0x09,
 	BATADV_CODED		= 0x0a,
 	BATADV_UNICAST_TVLV	= 0x0b,
@@ -127,12 +126,14 @@ enum batadv_bla_claimframe {
  * @BATADV_TVLV_DAT: distributed arp table tvlv
  * @BATADV_TVLV_NC: network coding tvlv
  * @BATADV_TVLV_TT: translation table tvlv
+ * @BATADV_TVLV_ROAM: roaming advertisement tvlv
  */
 enum batadv_tvlv_type {
 	BATADV_TVLV_GW		= 0x01,
 	BATADV_TVLV_DAT		= 0x02,
 	BATADV_TVLV_NC		= 0x03,
 	BATADV_TVLV_TT		= 0x04,
+	BATADV_TVLV_ROAM	= 0x05,
 };
 
 /* the destination hardware field in the ARP frame is used to
@@ -267,14 +268,6 @@ struct batadv_vis_packet {
 	uint8_t  sender_orig[ETH_ALEN]; /* who sent or forwarded this packet */
 };
 
-struct batadv_roam_adv_packet {
-	struct batadv_header header;
-	uint8_t  reserved;
-	uint8_t  dst[ETH_ALEN];
-	uint8_t  src[ETH_ALEN];
-	uint8_t  client[ETH_ALEN];
-} __packed;
-
 /**
  * struct batadv_coded_packet - network coded packet
  * @header: common batman packet header and ttl of first included packet
@@ -373,4 +366,14 @@ struct batadv_tvlv_tt_change {
 	uint8_t addr[ETH_ALEN];
 };
 
+/**
+ * struct batadv_tvlv_roam_adv - roaming advertisement
+ * @client: mac address of roaming client
+ * @reserved: field reserved for future use
+ */
+struct batadv_tvlv_roam_adv {
+	uint8_t  client[ETH_ALEN];
+	uint16_t reserved;
+};
+
 #endif /* _NET_BATMAN_ADV_PACKET_H_ */
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index d128581..a5bf8ff 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -557,48 +557,6 @@ static int batadv_check_unicast_packet(struct batadv_priv *bat_priv,
 	return 0;
 }
 
-int batadv_recv_roam_adv(struct sk_buff *skb, struct batadv_hard_iface *recv_if)
-{
-	struct batadv_priv *bat_priv = netdev_priv(recv_if->soft_iface);
-	struct batadv_roam_adv_packet *roam_adv_packet;
-	struct batadv_orig_node *orig_node;
-
-	if (batadv_check_unicast_packet(bat_priv, skb,
-					sizeof(*roam_adv_packet)) < 0)
-		goto out;
-
-	batadv_inc_counter(bat_priv, BATADV_CNT_TT_ROAM_ADV_RX);
-
-	roam_adv_packet = (struct batadv_roam_adv_packet *)skb->data;
-
-	if (!batadv_is_my_mac(bat_priv, roam_adv_packet->dst))
-		return batadv_route_unicast_packet(skb, recv_if);
-
-	/* check if it is a backbone gateway. we don't accept
-	 * roaming advertisement from it, as it has the same
-	 * entries as we have.
-	 */
-	if (batadv_bla_is_backbone_gw_orig(bat_priv, roam_adv_packet->src))
-		goto out;
-
-	orig_node = batadv_orig_hash_find(bat_priv, roam_adv_packet->src);
-	if (!orig_node)
-		goto out;
-
-	batadv_dbg(BATADV_DBG_TT, bat_priv,
-		   "Received ROAMING_ADV from %pM (client %pM)\n",
-		   roam_adv_packet->src, roam_adv_packet->client);
-
-	batadv_tt_global_add(bat_priv, orig_node, roam_adv_packet->client,
-			     BATADV_TT_CLIENT_ROAM,
-			     atomic_read(&orig_node->last_ttvn) + 1);
-
-	batadv_orig_node_free_ref(orig_node);
-out:
-	/* returning NET_RX_DROP will make the caller function kfree the skb */
-	return NET_RX_DROP;
-}
-
 /* find a suitable router for this originator, and use
  * bonding if possible. increases the found neighbors
  * refcount.
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 22fce8a..cb3c58e 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -2189,11 +2189,12 @@ unlock:
 static void batadv_send_roam_adv(struct batadv_priv *bat_priv, uint8_t *client,
 				 struct batadv_orig_node *orig_node)
 {
-	struct sk_buff *skb = NULL;
-	struct batadv_roam_adv_packet *roam_adv_packet;
-	int ret = 1;
 	struct batadv_hard_iface *primary_if;
-	size_t len = sizeof(*roam_adv_packet);
+	struct batadv_tvlv_roam_adv tvlv_roam;
+
+	primary_if = batadv_primary_if_get_selected(bat_priv);
+	if (!primary_if)
+		goto out;
 
 	/* before going on we have to check whether the client has
 	 * already roamed to us too many times
@@ -2201,40 +2202,21 @@ static void batadv_send_roam_adv(struct batadv_priv *bat_priv, uint8_t *client,
 	if (!batadv_tt_check_roam_count(bat_priv, client))
 		goto out;
 
-	skb = netdev_alloc_skb_ip_align(NULL, len + ETH_HLEN);
-	if (!skb)
-		goto out;
-
-	skb->priority = TC_PRIO_CONTROL;
-	skb_reserve(skb, ETH_HLEN);
-
-	roam_adv_packet = (struct batadv_roam_adv_packet *)skb_put(skb, len);
-
-	roam_adv_packet->header.packet_type = BATADV_ROAM_ADV;
-	roam_adv_packet->header.version = BATADV_COMPAT_VERSION;
-	roam_adv_packet->header.ttl = BATADV_TTL;
-	roam_adv_packet->reserved = 0;
-	primary_if = batadv_primary_if_get_selected(bat_priv);
-	if (!primary_if)
-		goto out;
-	memcpy(roam_adv_packet->src, primary_if->net_dev->dev_addr, ETH_ALEN);
-	batadv_hardif_free_ref(primary_if);
-	memcpy(roam_adv_packet->dst, orig_node->orig, ETH_ALEN);
-	memcpy(roam_adv_packet->client, client, ETH_ALEN);
-
-	batadv_dbg(BATADV_DBG_TT, bat_priv,
 		   "Sending ROAMING_ADV to %pM (client %pM)\n",
 		   orig_node->orig, client);
 
 	batadv_inc_counter(bat_priv, BATADV_CNT_TT_ROAM_ADV_TX);
 
-	if (batadv_send_skb_to_orig(skb, orig_node, NULL) != NET_XMIT_DROP)
-		ret = 0;
+	memcpy(tvlv_roam.client, client, sizeof(tvlv_roam.client));
+	tvlv_roam.reserved = 0;
+
+	batadv_tvlv_unicast_send(bat_priv, primary_if->net_dev->dev_addr,
+				 orig_node->orig, BATADV_TVLV_ROAM, 1,
+				 &tvlv_roam, sizeof(tvlv_roam));
 
 out:
-	if (ret && skb)
-		kfree_skb(skb);
-	return;
+	if (primary_if)
+		batadv_hardif_free_ref(primary_if);
 }
 
 static void batadv_tt_purge(struct work_struct *work)
@@ -2668,6 +2650,63 @@ static int batadv_tt_tvlv_unicast_handler_v1(struct batadv_priv *bat_priv,
 }
 
 /**
+ * batadv_roam_tvlv_unicast_handler_v1 - process incoming tt roam tvlv container
+ * @bat_priv: the bat priv with all the soft interface information
+ * @src: mac address of tt tvlv sender
+ * @dst: mac address of tt tvlv recipient
+ * @tvlv_value: tvlv buffer containing the tt data
+ * @tvlv_value_len: tvlv buffer length
+ *
+ * Returns NET_RX_DROP if the tt roam tvlv is to be re-routed, NET_RX_SUCCESS
+ * otherwise.
+ */
+static int batadv_roam_tvlv_unicast_handler_v1(struct batadv_priv *bat_priv,
+					       uint8_t *src, uint8_t *dst,
+					       void *tvlv_value,
+					       uint16_t tvlv_value_len)
+{
+	struct batadv_tvlv_roam_adv *roaming_adv;
+	struct batadv_orig_node *orig_node = NULL;
+
+	/* If this node is not the intended recipient of the
+	 * roaming advertisement the packet is forwarded
+	 * (the tvlv API will re-route the packet).
+	 */
+	if (!batadv_is_my_mac(bat_priv, dst))
+		return NET_RX_DROP;
+
+	/* check if it is a backbone gateway. we don't accept
+	 * roaming advertisement from it, as it has the same
+	 * entries as we have.
+	 */
+	if (batadv_bla_is_backbone_gw_orig(bat_priv, src))
+		goto out;
+
+	if (tvlv_value_len < sizeof(*roaming_adv))
+		goto out;
+
+	orig_node = batadv_orig_hash_find(bat_priv, src);
+	if (!orig_node)
+		goto out;
+
+	batadv_inc_counter(bat_priv, BATADV_CNT_TT_ROAM_ADV_RX);
+	roaming_adv = (struct batadv_tvlv_roam_adv *)tvlv_value;
+
+	batadv_dbg(BATADV_DBG_TT, bat_priv,
+		   "Received ROAMING_ADV from %pM (client %pM)\n",
+		   src, roaming_adv->client);
+
+	batadv_tt_global_add(bat_priv, orig_node, roaming_adv->client,
+			     BATADV_TT_CLIENT_ROAM,
+			     atomic_read(&orig_node->last_ttvn) + 1);
+
+out:
+	if (orig_node)
+		batadv_orig_node_free_ref(orig_node);
+	return NET_RX_SUCCESS;
+}
+
+/**
  * batadv_tt_init - initialise the translation table internals
  * @bat_priv: the bat priv with all the soft interface information
  *
@@ -2689,6 +2728,10 @@ int batadv_tt_init(struct batadv_priv *bat_priv)
 				     batadv_tt_tvlv_unicast_handler_v1,
 				     BATADV_TVLV_TT, 1, BATADV_NO_FLAGS);
 
+	batadv_tvlv_handler_register(bat_priv, NULL,
+				     batadv_roam_tvlv_unicast_handler_v1,
+				     BATADV_TVLV_ROAM, 1, BATADV_NO_FLAGS);
+
 	INIT_DELAYED_WORK(&bat_priv->tt.work, batadv_tt_purge);
 	queue_delayed_work(batadv_event_workqueue, &bat_priv->tt.work,
 			   msecs_to_jiffies(BATADV_TT_WORK_PERIOD));
-- 
1.8.3.2
