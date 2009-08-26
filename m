From: frank.blaschka@de.ibm.com
Subject: [patch 3/5] [PATCH] qeth: Cleanup for cast-type determination.
Date: Wed, 26 Aug 2009 14:01:08 +0200
Message-ID: <20090826120136.252541000@de.ibm.com>
References: <20090826120105.727838000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Klaus-Dieter Wacker <kdwacker@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.17.164]:43146 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756078AbZHZMBj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 08:01:39 -0400
Content-Disposition: inline; filename=609-qeth-cast-type.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Klaus-Dieter Wacker <kdwacker@de.ibm.com>

Clear separation of cast-type determination (send path) for layer-2
resp. layer-3. Allowing to have inline functions for qeth layer-
discipline.

Signed-off-by: Klaus-Dieter Wacker <kdwacker@de.ibm.com> 
---

 drivers/s390/net/qeth_core.h      |    1 
 drivers/s390/net/qeth_core_main.c |   49 --------------------------------------
 drivers/s390/net/qeth_l2_main.c   |   42 ++++++++------------------------
 drivers/s390/net/qeth_l3_main.c   |   47 +++++++++++++++++++++++++++++++++++-
 4 files changed, 57 insertions(+), 82 deletions(-)

Index: git_net-next/drivers/s390/net/qeth_core.h
===================================================================
--- git_net-next.orig/drivers/s390/net/qeth_core.h
+++ git_net-next/drivers/s390/net/qeth_core.h
@@ -843,7 +843,6 @@ int qeth_default_setadapterparms_cb(stru
 int qeth_send_control_data(struct qeth_card *, int, struct qeth_cmd_buffer *,
 	int (*reply_cb)(struct qeth_card *, struct qeth_reply*, unsigned long),
 	void *reply_param);
-int qeth_get_cast_type(struct qeth_card *, struct sk_buff *);
 int qeth_get_priority_queue(struct qeth_card *, struct sk_buff *, int, int);
 int qeth_get_elements_no(struct qeth_card *, void *, struct sk_buff *, int);
 int qeth_do_send_packet_fast(struct qeth_card *, struct qeth_qdio_out_q *,
Index: git_net-next/drivers/s390/net/qeth_core_main.c
===================================================================
--- git_net-next.orig/drivers/s390/net/qeth_core_main.c
+++ git_net-next/drivers/s390/net/qeth_core_main.c
@@ -2952,55 +2952,6 @@ void qeth_qdio_output_handler(struct ccw
 }
 EXPORT_SYMBOL_GPL(qeth_qdio_output_handler);
 
-int qeth_get_cast_type(struct qeth_card *card, struct sk_buff *skb)
-{
-	int cast_type = RTN_UNSPEC;
-
-	if (card->info.type == QETH_CARD_TYPE_OSN)
-		return cast_type;
-
-	if (skb_dst(skb) && skb_dst(skb)->neighbour) {
-		cast_type = skb_dst(skb)->neighbour->type;
-		if ((cast_type == RTN_BROADCAST) ||
-		    (cast_type == RTN_MULTICAST) ||
-		    (cast_type == RTN_ANYCAST))
-			return cast_type;
-		else
-			return RTN_UNSPEC;
-	}
-	/* try something else */
-	if (skb->protocol == ETH_P_IPV6)
-		return (skb_network_header(skb)[24] == 0xff) ?
-				RTN_MULTICAST : 0;
-	else if (skb->protocol == ETH_P_IP)
-		return ((skb_network_header(skb)[16] & 0xf0) == 0xe0) ?
-				RTN_MULTICAST : 0;
-	/* ... */
-	if (!memcmp(skb->data, skb->dev->broadcast, 6))
-		return RTN_BROADCAST;
-	else {
-		u16 hdr_mac;
-
-		hdr_mac = *((u16 *)skb->data);
-		/* tr multicast? */
-		switch (card->info.link_type) {
-		case QETH_LINK_TYPE_HSTR:
-		case QETH_LINK_TYPE_LANE_TR:
-			if ((hdr_mac == QETH_TR_MAC_NC) ||
-			    (hdr_mac == QETH_TR_MAC_C))
-				return RTN_MULTICAST;
-			break;
-		/* eth or so multicast? */
-		default:
-		if ((hdr_mac == QETH_ETH_MAC_V4) ||
-			    (hdr_mac == QETH_ETH_MAC_V6))
-				return RTN_MULTICAST;
-		}
-	}
-	return cast_type;
-}
-EXPORT_SYMBOL_GPL(qeth_get_cast_type);
-
 int qeth_get_priority_queue(struct qeth_card *card, struct sk_buff *skb,
 			int ipv, int cast_type)
 {
Index: git_net-next/drivers/s390/net/qeth_l2_main.c
===================================================================
--- git_net-next.orig/drivers/s390/net/qeth_l2_main.c
+++ git_net-next/drivers/s390/net/qeth_l2_main.c
@@ -216,36 +216,16 @@ static void qeth_l2_del_all_mc(struct qe
 	spin_unlock_bh(&card->mclock);
 }
 
-static void qeth_l2_get_packet_type(struct qeth_card *card,
-			struct qeth_hdr *hdr, struct sk_buff *skb)
+static inline int qeth_l2_get_cast_type(struct qeth_card *card,
+			struct sk_buff *skb)
 {
-	__u16 hdr_mac;
-
-	if (!memcmp(skb->data + QETH_HEADER_SIZE,
-		    skb->dev->broadcast, 6)) {
-		/* broadcast? */
-		hdr->hdr.l2.flags[2] |= QETH_LAYER2_FLAG_BROADCAST;
-		return;
-	}
-	hdr_mac = *((__u16 *)skb->data);
-	/* tr multicast? */
-	switch (card->info.link_type) {
-	case QETH_LINK_TYPE_HSTR:
-	case QETH_LINK_TYPE_LANE_TR:
-		if ((hdr_mac == QETH_TR_MAC_NC) ||
-		    (hdr_mac == QETH_TR_MAC_C))
-			hdr->hdr.l2.flags[2] |= QETH_LAYER2_FLAG_MULTICAST;
-		else
-			hdr->hdr.l2.flags[2] |= QETH_LAYER2_FLAG_UNICAST;
-		break;
-		/* eth or so multicast? */
-	default:
-		if ((hdr_mac == QETH_ETH_MAC_V4) ||
-		     (hdr_mac == QETH_ETH_MAC_V6))
-			hdr->hdr.l2.flags[2] |= QETH_LAYER2_FLAG_MULTICAST;
-		else
-			hdr->hdr.l2.flags[2] |= QETH_LAYER2_FLAG_UNICAST;
-	}
+	if (card->info.type == QETH_CARD_TYPE_OSN)
+		return RTN_UNSPEC;
+	if (is_broadcast_ether_addr(skb->data))
+		return RTN_BROADCAST;
+	if (is_multicast_ether_addr(skb->data))
+		return RTN_MULTICAST;
+	return RTN_UNSPEC;
 }
 
 static void qeth_l2_fill_header(struct qeth_card *card, struct qeth_hdr *hdr,
@@ -262,7 +242,7 @@ static void qeth_l2_fill_header(struct q
 	else if (cast_type == RTN_BROADCAST)
 		hdr->hdr.l2.flags[2] |= QETH_LAYER2_FLAG_BROADCAST;
 	else
-		qeth_l2_get_packet_type(card, hdr, skb);
+		hdr->hdr.l2.flags[2] |= QETH_LAYER2_FLAG_UNICAST;
 
 	hdr->hdr.l2.pkt_length = skb->len-QETH_HEADER_SIZE;
 	/* VSWITCH relies on the VLAN
@@ -672,7 +652,7 @@ static int qeth_l2_hard_start_xmit(struc
 	struct qeth_card *card = dev->ml_priv;
 	struct sk_buff *new_skb = skb;
 	int ipv = qeth_get_ip_version(skb);
-	int cast_type = qeth_get_cast_type(card, skb);
+	int cast_type = qeth_l2_get_cast_type(card, skb);
 	struct qeth_qdio_out_q *queue = card->qdio.out_qs
 		[qeth_get_priority_queue(card, skb, ipv, cast_type)];
 	int tx_bytes = skb->len;
Index: git_net-next/drivers/s390/net/qeth_l3_main.c
===================================================================
--- git_net-next.orig/drivers/s390/net/qeth_l3_main.c
+++ git_net-next/drivers/s390/net/qeth_l3_main.c
@@ -2525,6 +2525,51 @@ static int qeth_l3_do_ioctl(struct net_d
 	return rc;
 }
 
+int inline qeth_l3_get_cast_type(struct qeth_card *card, struct sk_buff *skb)
+{
+	int cast_type = RTN_UNSPEC;
+
+	if (skb_dst(skb) && skb_dst(skb)->neighbour) {
+		cast_type = skb_dst(skb)->neighbour->type;
+		if ((cast_type == RTN_BROADCAST) ||
+		    (cast_type == RTN_MULTICAST) ||
+		    (cast_type == RTN_ANYCAST))
+			return cast_type;
+		else
+			return RTN_UNSPEC;
+	}
+	/* try something else */
+	if (skb->protocol == ETH_P_IPV6)
+		return (skb_network_header(skb)[24] == 0xff) ?
+				RTN_MULTICAST : 0;
+	else if (skb->protocol == ETH_P_IP)
+		return ((skb_network_header(skb)[16] & 0xf0) == 0xe0) ?
+				RTN_MULTICAST : 0;
+	/* ... */
+	if (!memcmp(skb->data, skb->dev->broadcast, 6))
+		return RTN_BROADCAST;
+	else {
+		u16 hdr_mac;
+
+		hdr_mac = *((u16 *)skb->data);
+		/* tr multicast? */
+		switch (card->info.link_type) {
+		case QETH_LINK_TYPE_HSTR:
+		case QETH_LINK_TYPE_LANE_TR:
+			if ((hdr_mac == QETH_TR_MAC_NC) ||
+			    (hdr_mac == QETH_TR_MAC_C))
+				return RTN_MULTICAST;
+			break;
+		/* eth or so multicast? */
+		default:
+		if ((hdr_mac == QETH_ETH_MAC_V4) ||
+			    (hdr_mac == QETH_ETH_MAC_V6))
+				return RTN_MULTICAST;
+		}
+	}
+	return cast_type;
+}
+
 static void qeth_l3_fill_header(struct qeth_card *card, struct qeth_hdr *hdr,
 		struct sk_buff *skb, int ipv, int cast_type)
 {
@@ -2650,7 +2695,7 @@ static int qeth_l3_hard_start_xmit(struc
 	struct qeth_card *card = dev->ml_priv;
 	struct sk_buff *new_skb = NULL;
 	int ipv = qeth_get_ip_version(skb);
-	int cast_type = qeth_get_cast_type(card, skb);
+	int cast_type = qeth_l3_get_cast_type(card, skb);
 	struct qeth_qdio_out_q *queue = card->qdio.out_qs
 		[qeth_get_priority_queue(card, skb, ipv, cast_type)];
 	int tx_bytes = skb->len;

