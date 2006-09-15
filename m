From: Frank Pavlic <fpavlic@de.ibm.com>
Subject: [PATCH 4/9] s390: qeth driver fixes [1/6]
Date: Fri, 15 Sep 2006 16:25:56 +0200
Message-ID: <20060915142556.GD10043@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.uk.ibm.com ([195.212.29.135]:27005 "EHLO
	mtagate2.uk.ibm.com") by vger.kernel.org with ESMTP
	id S1751557AbWIOOhP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Sep 2006 10:37:15 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate2.uk.ibm.com (8.13.8/8.13.8) with ESMTP id k8FEbESC082264
	for <netdev@vger.kernel.org>; Fri, 15 Sep 2006 14:37:14 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8FEdPnu1892584
	for <netdev@vger.kernel.org>; Fri, 15 Sep 2006 15:39:25 +0100
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8FEbDc2022850
	for <netdev@vger.kernel.org>; Fri, 15 Sep 2006 15:37:13 +0100
To: jgarzik@pobox.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[PATCH 4/9] s390: qeth driver fixes [1/6]

From: Frank Pavlic <fpavlic@de.ibm.com>
	- Drop incoming packets with vlan_tag set
          if card->vlangrp is not set.
        - use always vlan_hwaccel_rx to pass 
	  vlan frames to the stack.
        - fix recovery problem. Device was recovered 
	  properly but still not working. 
	  netif_carrier_on call right before
          recovery start fixes it.

Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>
---

 drivers/s390/net/qeth_main.c |   49 ++++++++++++++++++++----------------------
 1 files changed, 23 insertions(+), 26 deletions(-)

aa7f6f1f5639e15a5bff562fbc19cbbd701c0078
diff --git a/drivers/s390/net/qeth_main.c b/drivers/s390/net/qeth_main.c
index e1327b8..ffff7a1 100644
--- a/drivers/s390/net/qeth_main.c
+++ b/drivers/s390/net/qeth_main.c
@@ -1708,6 +1708,7 @@ qeth_check_ipa_data(struct qeth_card *ca
 					   "IP address reset.\n",
 					   QETH_CARD_IFNAME(card),
 					   card->info.chpid);
+				netif_carrier_on(card->dev);
 				qeth_schedule_recovery(card);
 				return NULL;
 			case IPA_CMD_MODCCID:
@@ -2464,24 +2465,6 @@ qeth_rebuild_skb_fake_ll(struct qeth_car
 		qeth_rebuild_skb_fake_ll_eth(card, skb, hdr);
 }
 
-static inline void
-qeth_rebuild_skb_vlan(struct qeth_card *card, struct sk_buff *skb,
-		      struct qeth_hdr *hdr)
-{
-#ifdef CONFIG_QETH_VLAN
-	u16 *vlan_tag;
-
-	if (hdr->hdr.l3.ext_flags &
-	    (QETH_HDR_EXT_VLAN_FRAME | QETH_HDR_EXT_INCLUDE_VLAN_TAG)) {
-		vlan_tag = (u16 *) skb_push(skb, VLAN_HLEN);
-		*vlan_tag = (hdr->hdr.l3.ext_flags & QETH_HDR_EXT_VLAN_FRAME)?
-			hdr->hdr.l3.vlan_id : *((u16 *)&hdr->hdr.l3.dest_addr[12]);
-		*(vlan_tag + 1) = skb->protocol;
-		skb->protocol = __constant_htons(ETH_P_8021Q);
-	}
-#endif /* CONFIG_QETH_VLAN */
-}
-
 static inline __u16
 qeth_layer2_rebuild_skb(struct qeth_card *card, struct sk_buff *skb,
 			struct qeth_hdr *hdr)
@@ -2510,15 +2493,16 @@ qeth_layer2_rebuild_skb(struct qeth_card
 	return vlan_id;
 }
 
-static inline void
+static inline __u16
 qeth_rebuild_skb(struct qeth_card *card, struct sk_buff *skb,
 		 struct qeth_hdr *hdr)
 {
+	unsigned short vlan_id = 0;
 #ifdef CONFIG_QETH_IPV6
 	if (hdr->hdr.l3.flags & QETH_HDR_PASSTHRU) {
 		skb->pkt_type = PACKET_HOST;
 		skb->protocol = qeth_type_trans(skb, card->dev);
-		return;
+		return 0;
 	}
 #endif /* CONFIG_QETH_IPV6 */
 	skb->protocol = htons((hdr->hdr.l3.flags & QETH_HDR_IPV6)? ETH_P_IPV6 :
@@ -2540,7 +2524,13 @@ qeth_rebuild_skb(struct qeth_card *card,
 	default:
 		skb->pkt_type = PACKET_HOST;
 	}
-	qeth_rebuild_skb_vlan(card, skb, hdr);
+
+	if (hdr->hdr.l3.ext_flags &
+	    (QETH_HDR_EXT_VLAN_FRAME | QETH_HDR_EXT_INCLUDE_VLAN_TAG)) {
+		vlan_id = (hdr->hdr.l3.ext_flags & QETH_HDR_EXT_VLAN_FRAME)?
+			hdr->hdr.l3.vlan_id : *((u16 *)&hdr->hdr.l3.dest_addr[12]);
+	}
+
 	if (card->options.fake_ll)
 		qeth_rebuild_skb_fake_ll(card, skb, hdr);
 	else
@@ -2556,6 +2546,7 @@ qeth_rebuild_skb(struct qeth_card *card,
 		else
 			skb->ip_summed = SW_CHECKSUMMING;
 	}
+	return vlan_id;
 }
 
 static inline void
@@ -2568,6 +2559,7 @@ qeth_process_inbound_buffer(struct qeth_
 	int offset;
 	int rxrc;
 	__u16 vlan_tag = 0;
+	__u16 *vlan_addr;
 
 	/* get first element of current buffer */
 	element = (struct qdio_buffer_element *)&buf->buffer->element[0];
@@ -2581,7 +2573,7 @@ qeth_process_inbound_buffer(struct qeth_
 		if (hdr->hdr.l2.id == QETH_HEADER_TYPE_LAYER2)
 			vlan_tag = qeth_layer2_rebuild_skb(card, skb, hdr);
 		else if (hdr->hdr.l3.id == QETH_HEADER_TYPE_LAYER3)
-			qeth_rebuild_skb(card, skb, hdr);
+			vlan_tag = qeth_rebuild_skb(card, skb, hdr);
 		else { /*in case of OSN*/
 			skb_push(skb, sizeof(struct qeth_hdr));
 			memcpy(skb->data, hdr, sizeof(struct qeth_hdr));
@@ -2591,14 +2583,19 @@ qeth_process_inbound_buffer(struct qeth_
 			dev_kfree_skb_any(skb);
 			continue;
 		}
+		if (card->info.type == QETH_CARD_TYPE_OSN)
+			rxrc = card->osn_info.data_cb(skb);
+		else
 #ifdef CONFIG_QETH_VLAN
 		if (vlan_tag)
-			vlan_hwaccel_rx(skb, card->vlangrp, vlan_tag);
+			if (card->vlangrp)
+				vlan_hwaccel_rx(skb, card->vlangrp, vlan_tag);
+			else {
+				dev_kfree_skb_any(skb);
+				continue;
+			}
 		else
 #endif
-		if (card->info.type == QETH_CARD_TYPE_OSN)
-			rxrc = card->osn_info.data_cb(skb);
-		else
 			rxrc = netif_rx(skb);
 		card->dev->last_rx = jiffies;
 		card->stats.rx_packets++;
-- 
1.2.4

