From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 14/16] batman-adv: reorder packet types
Date: Wed,  9 Oct 2013 14:40:16 +0200
Message-ID: <1381322418-1349-15-git-send-email-antonio@meshcoding.com>
References: <1381322418-1349-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>,
	Simon Wunderlich <siwu@hrz.tu-chemnitz.de>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:38225 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752983Ab3JINXG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 09:23:06 -0400
In-Reply-To: <1381322418-1349-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>

Reordering the packet type numbers allows us to handle unicast
packets in a general way - even if we don't know the specific packet
type, we can still forward it. There was already code handling
this for a couple of unicast packets, and this is the more
generalized version to do that.

Signed-off-by: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/main.c    | 20 +++++++++++++++-----
 net/batman-adv/packet.h  | 31 +++++++++++++++++++++++--------
 net/batman-adv/routing.c | 28 ++++++++++++++++++++++++++++
 net/batman-adv/routing.h |  2 ++
 4 files changed, 68 insertions(+), 13 deletions(-)

diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index b22368e..8b195e6 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -393,6 +393,9 @@ static void batadv_recv_handler_init(void)
 	for (i = 0; i < ARRAY_SIZE(batadv_rx_handler); i++)
 		batadv_rx_handler[i] = batadv_recv_unhandled_packet;
 
+	for (i = BATADV_UNICAST_MIN; i <= BATADV_UNICAST_MAX; i++)
+		batadv_rx_handler[i] = batadv_recv_unhandled_unicast_packet;
+
 	/* compile time checks for struct member offsets */
 	BUILD_BUG_ON(offsetof(struct batadv_unicast_4addr_packet, src) != 10);
 	BUILD_BUG_ON(offsetof(struct batadv_unicast_packet, dest) != 4);
@@ -401,18 +404,20 @@ static void batadv_recv_handler_init(void)
 	BUILD_BUG_ON(offsetof(struct batadv_icmp_packet, dst) != 4);
 	BUILD_BUG_ON(offsetof(struct batadv_icmp_packet_rr, dst) != 4);
 
-	/* batman icmp packet */
-	batadv_rx_handler[BATADV_ICMP] = batadv_recv_icmp_packet;
+	/* broadcast packet */
+	batadv_rx_handler[BATADV_BCAST] = batadv_recv_bcast_packet;
+
+	/* unicast packets ... */
 	/* unicast with 4 addresses packet */
 	batadv_rx_handler[BATADV_UNICAST_4ADDR] = batadv_recv_unicast_packet;
 	/* unicast packet */
 	batadv_rx_handler[BATADV_UNICAST] = batadv_recv_unicast_packet;
 	/* fragmented unicast packet */
 	batadv_rx_handler[BATADV_UNICAST_FRAG] = batadv_recv_ucast_frag_packet;
-	/* broadcast packet */
-	batadv_rx_handler[BATADV_BCAST] = batadv_recv_bcast_packet;
 	/* unicast tvlv packet */
 	batadv_rx_handler[BATADV_UNICAST_TVLV] = batadv_recv_unicast_tvlv;
+	/* batman icmp packet */
+	batadv_rx_handler[BATADV_ICMP] = batadv_recv_icmp_packet;
 }
 
 int
@@ -420,7 +425,12 @@ batadv_recv_handler_register(uint8_t packet_type,
 			     int (*recv_handler)(struct sk_buff *,
 						 struct batadv_hard_iface *))
 {
-	if (batadv_rx_handler[packet_type] != &batadv_recv_unhandled_packet)
+	int (*curr)(struct sk_buff *,
+		    struct batadv_hard_iface *);
+	curr = batadv_rx_handler[packet_type];
+
+	if ((curr != batadv_recv_unhandled_packet) &&
+	    (curr != batadv_recv_unhandled_unicast_packet))
 		return -EBUSY;
 
 	batadv_rx_handler[packet_type] = recv_handler;
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 87fcf2e..f02dbb1 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -22,17 +22,32 @@
 
 /**
  * enum batadv_packettype - types for batman-adv encapsulated packets
+ * @BATADV_IV_OGM: originator messages for B.A.T.M.A.N. IV
+ * @BATADV_BCAST: broadcast packets carrying broadcast payload
+ * @BATADV_CODED: network coded packets
+ *
+ * @BATADV_UNICAST: unicast packets carrying unicast payload traffic
+ * @BATADV_UNICAST_FRAG: unicast packets carrying a fragment of the original
+ *     payload packet
+ * @BATADV_UNICAST_4ADDR: unicast packet including the originator address of
+ *     the sender
+ * @BATADV_ICMP: unicast packet like IP ICMP used for ping or traceroute
  * @BATADV_UNICAST_TVLV: unicast packet carrying TVLV containers
  */
 enum batadv_packettype {
-	BATADV_IV_OGM		= 0x01,
-	BATADV_ICMP		= 0x02,
-	BATADV_UNICAST		= 0x03,
-	BATADV_BCAST		= 0x04,
-	BATADV_UNICAST_FRAG	= 0x06,
-	BATADV_UNICAST_4ADDR	= 0x09,
-	BATADV_CODED		= 0x0a,
-	BATADV_UNICAST_TVLV	= 0x0b,
+	/* 0x00 - 0x3f: local packets or special rules for handling */
+	BATADV_IV_OGM           = 0x00,
+	BATADV_BCAST            = 0x01,
+	BATADV_CODED            = 0x02,
+	/* 0x40 - 0x7f: unicast */
+#define BATADV_UNICAST_MIN     0x40
+	BATADV_UNICAST          = 0x40,
+	BATADV_UNICAST_FRAG     = 0x41,
+	BATADV_UNICAST_4ADDR    = 0x42,
+	BATADV_ICMP             = 0x43,
+	BATADV_UNICAST_TVLV     = 0x44,
+#define BATADV_UNICAST_MAX     0x7f
+	/* 0x80 - 0xff: reserved */
 };
 
 /**
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 2a9318b..457dfef 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -911,6 +911,34 @@ static int batadv_check_unicast_ttvn(struct batadv_priv *bat_priv,
 	return 1;
 }
 
+/**
+ * batadv_recv_unhandled_unicast_packet - receive and process packets which
+ *	are in the unicast number space but not yet known to the implementation
+ * @skb: unicast tvlv packet to process
+ * @recv_if: pointer to interface this packet was received on
+ *
+ * Returns NET_RX_SUCCESS if the packet has been consumed or NET_RX_DROP
+ * otherwise.
+ */
+int batadv_recv_unhandled_unicast_packet(struct sk_buff *skb,
+					 struct batadv_hard_iface *recv_if)
+{
+	struct batadv_unicast_packet *unicast_packet;
+	struct batadv_priv *bat_priv = netdev_priv(recv_if->soft_iface);
+	int check, hdr_size = sizeof(*unicast_packet);
+
+	check = batadv_check_unicast_packet(bat_priv, skb, hdr_size);
+	if (check < 0)
+		return NET_RX_DROP;
+
+	/* we don't know about this type, drop it. */
+	unicast_packet = (struct batadv_unicast_packet *)skb->data;
+	if (batadv_is_my_mac(bat_priv, unicast_packet->dest))
+		return NET_RX_DROP;
+
+	return batadv_route_unicast_packet(skb, recv_if);
+}
+
 int batadv_recv_unicast_packet(struct sk_buff *skb,
 			       struct batadv_hard_iface *recv_if)
 {
diff --git a/net/batman-adv/routing.h b/net/batman-adv/routing.h
index b3f53d4..ea15fa6 100644
--- a/net/batman-adv/routing.h
+++ b/net/batman-adv/routing.h
@@ -40,6 +40,8 @@ int batadv_recv_roam_adv(struct sk_buff *skb,
 			 struct batadv_hard_iface *recv_if);
 int batadv_recv_unicast_tvlv(struct sk_buff *skb,
 			     struct batadv_hard_iface *recv_if);
+int batadv_recv_unhandled_unicast_packet(struct sk_buff *skb,
+					 struct batadv_hard_iface *recv_if);
 struct batadv_neigh_node *
 batadv_find_router(struct batadv_priv *bat_priv,
 		   struct batadv_orig_node *orig_node,
-- 
1.8.3.2
