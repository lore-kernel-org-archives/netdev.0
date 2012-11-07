From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 03/12] batman-adv: add UNICAST_4ADDR packet type
Date: Wed,  7 Nov 2012 20:11:33 +0100
Message-ID: <1352315502-20324-4-git-send-email-ordex@autistici.org>
References: <1352315502-20324-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:44643 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753306Ab2KGTMd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2012 14:12:33 -0500
In-Reply-To: <1352315502-20324-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current unicast packet type does not contain the orig source address. This
patches add a new unicast packet (called UNICAST_4ADDR) which provides two new
fields: the originator source address and the subtype (the type of the data
contained in the packet payload). The former is useful to identify the node
which injected the packet into the network and the latter is useful to avoid
creating new unicast packet types in the future: a macro defining a new subtype
will be enough.

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/main.c           |   2 +
 net/batman-adv/packet.h         |  41 +++++++++---
 net/batman-adv/routing.c        |   8 ++-
 net/batman-adv/soft-interface.c |   2 +-
 net/batman-adv/unicast.c        | 135 +++++++++++++++++++++++++++++++++++-----
 net/batman-adv/unicast.h        |  32 +++++++++-
 6 files changed, 194 insertions(+), 26 deletions(-)

diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index f9bcfa1..afc07a8 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -300,6 +300,8 @@ static void batadv_recv_handler_init(void)
 
 	/* batman icmp packet */
 	batadv_rx_handler[BATADV_ICMP] = batadv_recv_icmp_packet;
+	/* unicast with 4 addresses packet */
+	batadv_rx_handler[BATADV_UNICAST_4ADDR] = batadv_recv_unicast_packet;
 	/* unicast packet */
 	batadv_rx_handler[BATADV_UNICAST] = batadv_recv_unicast_packet;
 	/* fragmented unicast packet */
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index b5f67a2..0f8dcf3 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -23,14 +23,23 @@
 #define BATADV_ETH_P_BATMAN  0x4305 /* unofficial/not registered Ethertype */
 
 enum batadv_packettype {
-	BATADV_IV_OGM	    = 0x01,
-	BATADV_ICMP	    = 0x02,
-	BATADV_UNICAST	    = 0x03,
-	BATADV_BCAST	    = 0x04,
-	BATADV_VIS	    = 0x05,
-	BATADV_UNICAST_FRAG = 0x06,
-	BATADV_TT_QUERY	    = 0x07,
-	BATADV_ROAM_ADV	    = 0x08,
+	BATADV_IV_OGM		= 0x01,
+	BATADV_ICMP		= 0x02,
+	BATADV_UNICAST		= 0x03,
+	BATADV_BCAST		= 0x04,
+	BATADV_VIS		= 0x05,
+	BATADV_UNICAST_FRAG	= 0x06,
+	BATADV_TT_QUERY		= 0x07,
+	BATADV_ROAM_ADV		= 0x08,
+	BATADV_UNICAST_4ADDR	= 0x09,
+};
+
+/**
+ * enum batadv_subtype - packet subtype for unicast4addr
+ * @BATADV_P_DATA: user payload
+ */
+enum batadv_subtype {
+	BATADV_P_DATA		= 0x01,
 };
 
 /* this file is included by batctl which needs these defines */
@@ -167,6 +176,22 @@ struct batadv_unicast_packet {
 	 */
 };
 
+/**
+ * struct batadv_unicast_4addr_packet - extended unicast packet
+ * @u: common unicast packet header
+ * @src: address of the source
+ * @subtype: packet subtype
+ */
+struct batadv_unicast_4addr_packet {
+	struct batadv_unicast_packet u;
+	uint8_t src[ETH_ALEN];
+	uint8_t subtype;
+	uint8_t reserved;
+	/* "4 bytes boundary + 2 bytes" long to make the payload after the
+	 * following ethernet header again 4 bytes boundary aligned
+	 */
+};
+
 struct batadv_unicast_frag_packet {
 	struct batadv_header header;
 	uint8_t  ttvn; /* destination translation table version number */
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 46dd5b4..859679b 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -986,14 +986,18 @@ int batadv_recv_unicast_packet(struct sk_buff *skb,
 	struct batadv_unicast_packet *unicast_packet;
 	int hdr_size = sizeof(*unicast_packet);
 
+	unicast_packet = (struct batadv_unicast_packet *)skb->data;
+
+	/* the caller function should have already pulled 2 bytes */
+	if (unicast_packet->header.packet_type == BATADV_UNICAST_4ADDR)
+		hdr_size = sizeof(struct batadv_unicast_4addr_packet);
+
 	if (batadv_check_unicast_packet(skb, hdr_size) < 0)
 		return NET_RX_DROP;
 
 	if (!batadv_check_unicast_ttvn(bat_priv, skb))
 		return NET_RX_DROP;
 
-	unicast_packet = (struct batadv_unicast_packet *)skb->data;
-
 	/* packet for me */
 	if (batadv_is_my_mac(unicast_packet->dest)) {
 		batadv_interface_rx(recv_if->soft_iface, skb, recv_if, hdr_size,
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 22bc651..2f123a1 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -260,7 +260,7 @@ static int batadv_interface_tx(struct sk_buff *skb,
 				goto dropped;
 		}
 
-		ret = batadv_unicast_send_skb(skb, bat_priv);
+		ret = batadv_unicast_send_skb(bat_priv, skb);
 		if (ret != 0)
 			goto dropped_freed;
 	}
diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index f397232..c0d318b 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -291,7 +291,111 @@ out:
 	return ret;
 }
 
-int batadv_unicast_send_skb(struct sk_buff *skb, struct batadv_priv *bat_priv)
+/**
+ * batadv_unicast_push_and_fill_skb - extends the buffer and initializes the
+ * common fields for unicast packets
+ * @skb: packet
+ * @hdr_size: amount of bytes to push at the beginning of the skb
+ * @orig_node: the destination node
+ *
+ * Returns false if the buffer extension was not possible or true otherwise
+ */
+static bool batadv_unicast_push_and_fill_skb(struct sk_buff *skb, int hdr_size,
+					     struct batadv_orig_node *orig_node)
+{
+	struct batadv_unicast_packet *unicast_packet;
+	uint8_t ttvn = (uint8_t)atomic_read(&orig_node->last_ttvn);
+
+	if (batadv_skb_head_push(skb, hdr_size) < 0)
+		return false;
+
+	unicast_packet = (struct batadv_unicast_packet *)skb->data;
+	unicast_packet->header.version = BATADV_COMPAT_VERSION;
+	/* batman packet type: unicast */
+	unicast_packet->header.packet_type = BATADV_UNICAST;
+	/* set unicast ttl */
+	unicast_packet->header.ttl = BATADV_TTL;
+	/* copy the destination for faster routing */
+	memcpy(unicast_packet->dest, orig_node->orig, ETH_ALEN);
+	/* set the destination tt version number */
+	unicast_packet->ttvn = ttvn;
+
+	return true;
+}
+
+/**
+ * batadv_unicast_prepare_skb - encapsulate an skb with a unicast header
+ * @skb: the skb containing the payload to encapsulate
+ * @orig_node: the destination node
+ *
+ * Returns false if the payload could not be encapsulated or true otherwise
+ */
+static bool batadv_unicast_prepare_skb(struct sk_buff *skb,
+				       struct batadv_orig_node *orig_node)
+{
+	size_t uni_size = sizeof(struct batadv_unicast_packet);
+	return batadv_unicast_push_and_fill_skb(skb, uni_size, orig_node);
+}
+
+/**
+ * batadv_unicast_4addr_prepare_skb - encapsulate an skb with a unicast4addr
+ * header
+ * @bat_priv: the bat priv with all the soft interface information
+ * @skb: the skb containing the payload to encapsulate
+ * @orig_node: the destination node
+ * @packet_subtype: the batman 4addr packet subtype to use
+ *
+ * Returns false if the payload could not be encapsulated or true otherwise
+ */
+static bool batadv_unicast_4addr_prepare_skb(struct batadv_priv *bat_priv,
+					     struct sk_buff *skb,
+					     struct batadv_orig_node *orig,
+					     int packet_subtype)
+{
+	struct batadv_hard_iface *primary_if;
+	struct batadv_unicast_4addr_packet *unicast_4addr_packet;
+	bool ret = false;
+
+	primary_if = batadv_primary_if_get_selected(bat_priv);
+	if (!primary_if)
+		goto out;
+
+	/* pull the header space and fill the unicast_packet substructure.
+	 * We can do that because the first member of the unicast_4addr_packet
+	 * is of type struct unicast_packet
+	 */
+	if (!batadv_unicast_push_and_fill_skb(skb,
+					      sizeof(*unicast_4addr_packet),
+					      orig))
+		goto out;
+
+	unicast_4addr_packet = (struct batadv_unicast_4addr_packet *)skb->data;
+	unicast_4addr_packet->u.header.packet_type = BATADV_UNICAST_4ADDR;
+	memcpy(unicast_4addr_packet->src, primary_if->net_dev->dev_addr,
+	       ETH_ALEN);
+	unicast_4addr_packet->subtype = packet_subtype;
+	unicast_4addr_packet->reserved = 0;
+
+	ret = true;
+out:
+	if (primary_if)
+		batadv_hardif_free_ref(primary_if);
+	return ret;
+}
+
+/**
+ * batadv_unicast_generic_send_skb - send an skb as unicast
+ * @bat_priv: the bat priv with all the soft interface information
+ * @skb: payload to send
+ * @packet_type: the batman unicast packet type to use
+ * @packet_subtype: the batman packet subtype. It is ignored if packet_type is
+ *		    not BATADV_UNICAT_4ADDR
+ *
+ * Returns 1 in case of error or 0 otherwise
+ */
+int batadv_unicast_generic_send_skb(struct batadv_priv *bat_priv,
+				    struct sk_buff *skb, int packet_type,
+				    int packet_subtype)
 {
 	struct ethhdr *ethhdr = (struct ethhdr *)skb->data;
 	struct batadv_unicast_packet *unicast_packet;
@@ -324,21 +428,23 @@ find_router:
 	if (!neigh_node)
 		goto out;
 
-	if (batadv_skb_head_push(skb, sizeof(*unicast_packet)) < 0)
+	switch (packet_type) {
+	case BATADV_UNICAST:
+		batadv_unicast_prepare_skb(skb, orig_node);
+		break;
+	case BATADV_UNICAST_4ADDR:
+		batadv_unicast_4addr_prepare_skb(bat_priv, skb, orig_node,
+						 packet_subtype);
+		break;
+	default:
+		/* this function supports UNICAST and UNICAST_4ADDR only. It
+		 * should never be invoked with any other packet type
+		 */
 		goto out;
+	}
 
 	unicast_packet = (struct batadv_unicast_packet *)skb->data;
 
-	unicast_packet->header.version = BATADV_COMPAT_VERSION;
-	/* batman packet type: unicast */
-	unicast_packet->header.packet_type = BATADV_UNICAST;
-	/* set unicast ttl */
-	unicast_packet->header.ttl = BATADV_TTL;
-	/* copy the destination for faster routing */
-	memcpy(unicast_packet->dest, orig_node->orig, ETH_ALEN);
-	/* set the destination tt version number */
-	unicast_packet->ttvn = (uint8_t)atomic_read(&orig_node->last_ttvn);
-
 	/* inform the destination node that we are still missing a correct route
 	 * for this client. The destination will receive this packet and will
 	 * try to reroute it because the ttvn contained in the header is less
@@ -348,7 +454,9 @@ find_router:
 		unicast_packet->ttvn = unicast_packet->ttvn - 1;
 
 	dev_mtu = neigh_node->if_incoming->net_dev->mtu;
-	if (atomic_read(&bat_priv->fragmentation) &&
+	/* fragmentation mechanism only works for UNICAST (now) */
+	if (packet_type == BATADV_UNICAST &&
+	    atomic_read(&bat_priv->fragmentation) &&
 	    data_len + sizeof(*unicast_packet) > dev_mtu) {
 		/* send frag skb decreases ttl */
 		unicast_packet->header.ttl++;
@@ -360,7 +468,6 @@ find_router:
 
 	batadv_send_skb_packet(skb, neigh_node->if_incoming, neigh_node->addr);
 	ret = 0;
-	goto out;
 
 out:
 	if (neigh_node)
diff --git a/net/batman-adv/unicast.h b/net/batman-adv/unicast.h
index 1c46e2e..a88ed29 100644
--- a/net/batman-adv/unicast.h
+++ b/net/batman-adv/unicast.h
@@ -29,10 +29,40 @@ int batadv_frag_reassemble_skb(struct sk_buff *skb,
 			       struct batadv_priv *bat_priv,
 			       struct sk_buff **new_skb);
 void batadv_frag_list_free(struct list_head *head);
-int batadv_unicast_send_skb(struct sk_buff *skb, struct batadv_priv *bat_priv);
 int batadv_frag_send_skb(struct sk_buff *skb, struct batadv_priv *bat_priv,
 			 struct batadv_hard_iface *hard_iface,
 			 const uint8_t dstaddr[]);
+int batadv_unicast_generic_send_skb(struct batadv_priv *bat_priv,
+				    struct sk_buff *skb, int packet_type,
+				    int packet_subtype);
+
+
+/**
+ * batadv_unicast_send_skb - send the skb encapsulated in a unicast packet
+ * @bat_priv: the bat priv with all the soft interface information
+ * @skb: the payload to send
+ */
+static inline int batadv_unicast_send_skb(struct batadv_priv *bat_priv,
+					  struct sk_buff *skb)
+{
+	return batadv_unicast_generic_send_skb(bat_priv, skb, BATADV_UNICAST,
+					       0);
+}
+
+/**
+ * batadv_unicast_send_skb - send the skb encapsulated in a unicast4addr packet
+ * @bat_priv: the bat priv with all the soft interface information
+ * @skb: the payload to send
+ * @packet_subtype: the batman 4addr packet subtype to use
+ */
+static inline int batadv_unicast_4addr_send_skb(struct batadv_priv *bat_priv,
+						struct sk_buff *skb,
+						int packet_subtype)
+{
+	return batadv_unicast_generic_send_skb(bat_priv, skb,
+					       BATADV_UNICAST_4ADDR,
+					       packet_subtype);
+}
 
 static inline int batadv_frag_can_reassemble(const struct sk_buff *skb, int mtu)
 {
-- 
1.8.0
