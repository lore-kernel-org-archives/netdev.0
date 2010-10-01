From: frank.blaschka@de.ibm.com
Subject: [patch 1/1] [PATCH] qeth: tagging with VLAN-ID 0
Date: Fri, 01 Oct 2010 14:51:13 +0200
Message-ID: <20101001125142.037089467@de.ibm.com>
References: <20101001125112.459999476@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.17.163]:58561 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932311Ab0JAMvq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Oct 2010 08:51:46 -0400
Content-Disposition: inline; filename=vlan0.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

This patch adapts qeth to handle tagged frames with VLAN-ID 0 and
with or without priority information in the tag. It enables qeth to
receive priority-tagged frames on a base interface, for example from
z/OS, without configuring an additional VLAN interface.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---
 drivers/s390/net/qeth_l2_main.c |    2 ++
 drivers/s390/net/qeth_l3_main.c |   27 +++++++++++++--------------
 2 files changed, 15 insertions(+), 14 deletions(-)

--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -310,6 +310,8 @@ static void qeth_l2_vlan_rx_add_vid(stru
 	struct qeth_vlan_vid *id;
 
 	QETH_CARD_TEXT_(card, 4, "aid:%d", vid);
+	if (!vid)
+		return;
 	if (card->info.type == QETH_CARD_TYPE_OSM) {
 		QETH_CARD_TEXT(card, 3, "aidOSM");
 		return;
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -2013,13 +2013,14 @@ static void qeth_l3_vlan_rx_kill_vid(str
 	qeth_l3_set_multicast_list(card->dev);
 }
 
-static inline __u16 qeth_l3_rebuild_skb(struct qeth_card *card,
-			struct sk_buff *skb, struct qeth_hdr *hdr)
+static inline int qeth_l3_rebuild_skb(struct qeth_card *card,
+			struct sk_buff *skb, struct qeth_hdr *hdr,
+			unsigned short *vlan_id)
 {
-	unsigned short vlan_id = 0;
 	__be16 prot;
 	struct iphdr *ip_hdr;
 	unsigned char tg_addr[MAX_ADDR_LEN];
+	int is_vlan = 0;
 
 	if (!(hdr->hdr.l3.flags & QETH_HDR_PASSTHRU)) {
 		prot = htons((hdr->hdr.l3.flags & QETH_HDR_IPV6)? ETH_P_IPV6 :
@@ -2082,8 +2083,9 @@ static inline __u16 qeth_l3_rebuild_skb(
 
 	if (hdr->hdr.l3.ext_flags &
 	    (QETH_HDR_EXT_VLAN_FRAME | QETH_HDR_EXT_INCLUDE_VLAN_TAG)) {
-		vlan_id = (hdr->hdr.l3.ext_flags & QETH_HDR_EXT_VLAN_FRAME)?
+		*vlan_id = (hdr->hdr.l3.ext_flags & QETH_HDR_EXT_VLAN_FRAME) ?
 		 hdr->hdr.l3.vlan_id : *((u16 *)&hdr->hdr.l3.dest_addr[12]);
+		is_vlan = 1;
 	}
 
 	switch (card->options.checksum_type) {
@@ -2104,7 +2106,7 @@ static inline __u16 qeth_l3_rebuild_skb(
 			skb->ip_summed = CHECKSUM_NONE;
 	}
 
-	return vlan_id;
+	return is_vlan;
 }
 
 static int qeth_l3_process_inbound_buffer(struct qeth_card *card,
@@ -2114,6 +2116,7 @@ static int qeth_l3_process_inbound_buffe
 	struct sk_buff *skb;
 	struct qeth_hdr *hdr;
 	__u16 vlan_tag = 0;
+	int is_vlan;
 	unsigned int len;
 
 	*done = 0;
@@ -2129,16 +2132,12 @@ static int qeth_l3_process_inbound_buffe
 		skb->dev = card->dev;
 		switch (hdr->hdr.l3.id) {
 		case QETH_HEADER_TYPE_LAYER3:
-			vlan_tag = qeth_l3_rebuild_skb(card, skb, hdr);
+			is_vlan = qeth_l3_rebuild_skb(card, skb, hdr,
+						      &vlan_tag);
 			len = skb->len;
-			if (vlan_tag && !card->options.sniffer)
-				if (card->vlangrp)
-					vlan_gro_receive(&card->napi,
-						card->vlangrp, vlan_tag, skb);
-				else {
-					dev_kfree_skb_any(skb);
-					continue;
-				}
+			if (is_vlan && !card->options.sniffer)
+				vlan_gro_receive(&card->napi, card->vlangrp,
+					vlan_tag, skb);
 			else
 				napi_gro_receive(&card->napi, skb);
 			break;

