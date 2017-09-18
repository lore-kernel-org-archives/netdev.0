From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 8/9] s390/qeth: fold VLAN handling into l3_rebuild_skb()
Date: Mon, 18 Sep 2017 21:18:21 +0200
Message-ID: <20170918191822.65142-9-jwi@linux.vnet.ibm.com>
References: <20170918191822.65142-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:42559 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750790AbdIRTUF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 15:20:05 -0400
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8IJK2DB097370
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 15:20:05 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2d2m1b8mdw-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 15:20:04 -0400
Received: from localhost
        by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Mon, 18 Sep 2017 20:19:30 +0100
In-Reply-To: <20170918191822.65142-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the overly complicated VLAN processing from the L3 RX handler into
its l3_rebuild_skb() helper. No change in functionality.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Reviewed-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_l3_main.c | 27 +++++++++++----------------
 1 file changed, 11 insertions(+), 16 deletions(-)

diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index 733f94cbd4d4..270ac9515f6b 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -1646,13 +1646,12 @@ static int qeth_l3_vlan_rx_kill_vid(struct net_device *dev,
 	return 0;
 }
 
-static int qeth_l3_rebuild_skb(struct qeth_card *card, struct sk_buff *skb,
-			       struct qeth_hdr *hdr, unsigned short *vlan_id)
+static void qeth_l3_rebuild_skb(struct qeth_card *card, struct sk_buff *skb,
+				struct qeth_hdr *hdr)
 {
 	__u16 prot;
 	struct iphdr *ip_hdr;
 	unsigned char tg_addr[MAX_ADDR_LEN];
-	int is_vlan = 0;
 
 	if (!(hdr->hdr.l3.flags & QETH_HDR_PASSTHRU)) {
 		prot = (hdr->hdr.l3.flags & QETH_HDR_IPV6) ? ETH_P_IPV6 :
@@ -1706,11 +1705,14 @@ static int qeth_l3_rebuild_skb(struct qeth_card *card, struct sk_buff *skb,
 
 	skb->protocol = eth_type_trans(skb, card->dev);
 
-	if (hdr->hdr.l3.ext_flags &
-	    (QETH_HDR_EXT_VLAN_FRAME | QETH_HDR_EXT_INCLUDE_VLAN_TAG)) {
-		*vlan_id = (hdr->hdr.l3.ext_flags & QETH_HDR_EXT_VLAN_FRAME) ?
-		 hdr->hdr.l3.vlan_id : *((u16 *)&hdr->hdr.l3.dest_addr[12]);
-		is_vlan = 1;
+	/* copy VLAN tag from hdr into skb */
+	if (!card->options.sniffer &&
+	    (hdr->hdr.l3.ext_flags & (QETH_HDR_EXT_VLAN_FRAME |
+				      QETH_HDR_EXT_INCLUDE_VLAN_TAG))) {
+		u16 tag = (hdr->hdr.l3.ext_flags & QETH_HDR_EXT_VLAN_FRAME) ?
+				hdr->hdr.l3.vlan_id :
+				*((u16 *)&hdr->hdr.l3.dest_addr[12]);
+		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), tag);
 	}
 
 	if (card->dev->features & NETIF_F_RXCSUM) {
@@ -1724,7 +1726,6 @@ static int qeth_l3_rebuild_skb(struct qeth_card *card, struct sk_buff *skb,
 			skb->ip_summed = CHECKSUM_NONE;
 	} else
 		skb->ip_summed = CHECKSUM_NONE;
-	return is_vlan;
 }
 
 static int qeth_l3_process_inbound_buffer(struct qeth_card *card,
@@ -1733,8 +1734,6 @@ static int qeth_l3_process_inbound_buffer(struct qeth_card *card,
 	int work_done = 0;
 	struct sk_buff *skb;
 	struct qeth_hdr *hdr;
-	__u16 vlan_tag = 0;
-	int is_vlan;
 	unsigned int len;
 	__u16 magic;
 
@@ -1764,12 +1763,8 @@ static int qeth_l3_process_inbound_buffer(struct qeth_card *card,
 					card->dev->addr_len);
 				netif_receive_skb(skb);
 			} else {
-				is_vlan = qeth_l3_rebuild_skb(card, skb, hdr,
-						      &vlan_tag);
+				qeth_l3_rebuild_skb(card, skb, hdr);
 				len = skb->len;
-				if (is_vlan && !card->options.sniffer)
-					__vlan_hwaccel_put_tag(skb,
-						htons(ETH_P_8021Q), vlan_tag);
 				napi_gro_receive(&card->napi, skb);
 			}
 			break;
-- 
2.13.5
