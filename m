From: Frank Pavlic <fpavlic@de.ibm.com>
Subject: [PATCH 1/5] s390: qeth driver fixes
Date: Mon, 8 Jan 2007 17:29:34 +0100
Message-ID: <20070108162934.GA21639@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:55772 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161353AbXAHQbZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jan 2007 11:31:25 -0500
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e35.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id l08GVM6E030112
	for <netdev@vger.kernel.org>; Mon, 8 Jan 2007 11:31:22 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id l08GVMLS551954
	for <netdev@vger.kernel.org>; Mon, 8 Jan 2007 09:31:22 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l08GVLCI010846
	for <netdev@vger.kernel.org>; Mon, 8 Jan 2007 09:31:22 -0700
To: jgarzik@pobox.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi ,

please apply following 5 patches for s390 network device drivers.
Sorry for the fifth patch containing some lines which just remove
whitespaces. Another patch will follow in the next couple of days
with more whitespace and coding style cleanups in drivers/s390/net.

Thank you 

Frank

[PATCH 1/5] s390: qeth driver fixes

From: Frank Blaschka <Frank.Blaschka@de.ibm.com>
From: Ursula Braun <braunu@de.ibm.com>
        - VLAN header reordering did not work on packets
          received through qeth interface in layer 2 mode.
          This caused dhcpcd not to work with VLAN devices.
	- set qeth performance statistics initally inactive

Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>
---
 drivers/s390/net/qeth_main.c |   21 +++------------------
 1 files changed, 3 insertions(+), 18 deletions(-)

diff --git a/drivers/s390/net/qeth_main.c b/drivers/s390/net/qeth_main.c
index 2bde4f1..67062d5 100644
--- a/drivers/s390/net/qeth_main.c
+++ b/drivers/s390/net/qeth_main.c
@@ -1074,7 +1074,7 @@ #endif /* QETH_IPV6 */
 		card->options.layer2 = 1;
 	else
 		card->options.layer2 = 0;
-	card->options.performance_stats = 1;
+	card->options.performance_stats = 0;
 }
 
 /**
@@ -2466,32 +2466,17 @@ qeth_rebuild_skb_fake_ll(struct qeth_car
 		qeth_rebuild_skb_fake_ll_eth(card, skb, hdr);
 }
 
-static inline __u16
+static inline void
 qeth_layer2_rebuild_skb(struct qeth_card *card, struct sk_buff *skb,
 			struct qeth_hdr *hdr)
 {
-	unsigned short vlan_id = 0;
-#ifdef CONFIG_QETH_VLAN
-	struct vlan_hdr *vhdr;
-#endif
-
 	skb->pkt_type = PACKET_HOST;
 	skb->protocol = qeth_type_trans(skb, skb->dev);
 	if (card->options.checksum_type == NO_CHECKSUMMING)
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 	else
 		skb->ip_summed = CHECKSUM_NONE;
-#ifdef CONFIG_QETH_VLAN
-	if (hdr->hdr.l2.flags[2] & (QETH_LAYER2_FLAG_VLAN)) {
-		vhdr = (struct vlan_hdr *) skb->data;
-		skb->protocol =
-			__constant_htons(vhdr->h_vlan_encapsulated_proto);
-		vlan_id = hdr->hdr.l2.vlan_id;
-		skb_pull(skb, VLAN_HLEN);
-	}
-#endif
 	*((__u32 *)skb->cb) = ++card->seqno.pkt_seqno;
-	return vlan_id;
 }
 
 static inline __u16
@@ -2571,7 +2556,7 @@ qeth_process_inbound_buffer(struct qeth_
 				       &offset, &hdr))) {
 		skb->dev = card->dev;
 		if (hdr->hdr.l2.id == QETH_HEADER_TYPE_LAYER2)
-			vlan_tag = qeth_layer2_rebuild_skb(card, skb, hdr);
+			qeth_layer2_rebuild_skb(card, skb, hdr);
 		else if (hdr->hdr.l3.id == QETH_HEADER_TYPE_LAYER3)
 			vlan_tag = qeth_rebuild_skb(card, skb, hdr);
 		else { /*in case of OSN*/
-- 
1.4.2.3

