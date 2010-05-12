From: frank.blaschka@de.ibm.com
Subject: [patch 1/3] [PATCH] qeth: exploit HW TX checksumming
Date: Wed, 12 May 2010 07:34:45 +0200
Message-ID: <20100512053528.463770000@de.ibm.com>
References: <20100512053444.035939000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.17.166]:60856 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751391Ab0ELFfa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 May 2010 01:35:30 -0400
Content-Disposition: inline; filename=601-qeth-hw-tx-checksum.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

OSA supports HW TX checksumming in layer 3 mode. Enable this
feature and remove software fallback used for TSO. Cleanup
checksum bits to indicate OSA can do checksumming only for
IPv4 TCP and UDP.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core.h    |    3 -
 drivers/s390/net/qeth_l3_main.c |   92 +++++++++++++++++++++++++++++-----------
 2 files changed, 69 insertions(+), 26 deletions(-)

diff -urpN linux-2.6/drivers/s390/net/qeth_core.h linux-2.6-patched/drivers/s390/net/qeth_core.h
--- linux-2.6/drivers/s390/net/qeth_core.h	2010-05-11 22:10:12.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_core.h	2010-05-11 22:10:34.000000000 +0200
@@ -351,7 +351,7 @@ enum qeth_header_ids {
 #define QETH_HDR_EXT_SRC_MAC_ADDR     0x08
 #define QETH_HDR_EXT_CSUM_HDR_REQ     0x10
 #define QETH_HDR_EXT_CSUM_TRANSP_REQ  0x20
-#define QETH_HDR_EXT_UDP_TSO          0x40 /*bit off for TCP*/
+#define QETH_HDR_EXT_UDP	      0x40 /*bit off for TCP*/
 
 static inline int qeth_is_last_sbale(struct qdio_buffer_element *sbale)
 {
@@ -630,6 +630,7 @@ struct qeth_card_info {
 	int unique_id;
 	struct qeth_card_blkt blkt;
 	__u32 csum_mask;
+	__u32 tx_csum_mask;
 	enum qeth_ipa_promisc_modes promisc_mode;
 };
 
diff -urpN linux-2.6/drivers/s390/net/qeth_l3_main.c linux-2.6-patched/drivers/s390/net/qeth_l3_main.c
--- linux-2.6/drivers/s390/net/qeth_l3_main.c	2010-05-11 22:10:12.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_l3_main.c	2010-05-11 22:10:34.000000000 +0200
@@ -54,16 +54,16 @@ int qeth_l3_set_large_send(struct qeth_c
 	if (card->options.large_send == QETH_LARGE_SEND_TSO) {
 		if (qeth_is_supported(card, IPA_OUTBOUND_TSO)) {
 			card->dev->features |= NETIF_F_TSO | NETIF_F_SG |
-					NETIF_F_HW_CSUM;
+					NETIF_F_IP_CSUM;
 		} else {
 			card->dev->features &= ~(NETIF_F_TSO | NETIF_F_SG |
-					NETIF_F_HW_CSUM);
+					NETIF_F_IP_CSUM);
 			card->options.large_send = QETH_LARGE_SEND_NO;
 			rc = -EOPNOTSUPP;
 		}
 	} else {
 		card->dev->features &= ~(NETIF_F_TSO | NETIF_F_SG |
-					NETIF_F_HW_CSUM);
+					NETIF_F_IP_CSUM);
 		card->options.large_send = QETH_LARGE_SEND_NO;
 	}
 	return rc;
@@ -1108,6 +1108,13 @@ static int qeth_l3_default_setassparms_c
 		card->info.csum_mask = cmd->data.setassparms.data.flags_32bit;
 		QETH_DBF_TEXT_(TRACE, 3, "csum:%d", card->info.csum_mask);
 	}
+	if (cmd->data.setassparms.hdr.assist_no == IPA_OUTBOUND_CHECKSUM &&
+	    cmd->data.setassparms.hdr.command_code == IPA_CMD_ASS_START) {
+		card->info.tx_csum_mask =
+			cmd->data.setassparms.data.flags_32bit;
+		QETH_DBF_TEXT_(TRACE, 3, "tcsu:%d", card->info.tx_csum_mask);
+	}
+
 	return 0;
 }
 
@@ -1536,6 +1543,28 @@ static int qeth_l3_start_ipa_checksum(st
 	return rc;
 }
 
+static int qeth_l3_start_ipa_tx_checksum(struct qeth_card *card)
+{
+	int rc = 0;
+
+	if (!qeth_is_supported(card, IPA_OUTBOUND_CHECKSUM))
+		return rc;
+	rc = qeth_l3_send_simple_setassparms(card, IPA_OUTBOUND_CHECKSUM,
+			  IPA_CMD_ASS_START, 0);
+	if (rc)
+		goto err_out;
+	rc = qeth_l3_send_simple_setassparms(card, IPA_OUTBOUND_CHECKSUM,
+			  IPA_CMD_ASS_ENABLE, card->info.tx_csum_mask);
+	if (rc)
+		goto err_out;
+	dev_info(&card->gdev->dev, "HW TX Checksumming enabled\n");
+	return rc;
+err_out:
+	dev_warn(&card->gdev->dev, "Enabling HW TX checksumming for %s "
+		"failed, using SW TX checksumming\n", QETH_CARD_IFNAME(card));
+	return rc;
+}
+
 static int qeth_l3_start_ipa_tso(struct qeth_card *card)
 {
 	int rc;
@@ -1578,6 +1607,7 @@ static int qeth_l3_start_ipassists(struc
 	qeth_l3_start_ipa_ipv6(card);		/* go on*/
 	qeth_l3_start_ipa_broadcast(card);		/* go on*/
 	qeth_l3_start_ipa_checksum(card);		/* go on*/
+	qeth_l3_start_ipa_tx_checksum(card);
 	qeth_l3_start_ipa_tso(card);		/* go on*/
 	return 0;
 }
@@ -2817,6 +2847,21 @@ static void qeth_l3_fill_header(struct q
 	}
 }
 
+static inline void qeth_l3_hdr_csum(struct qeth_card *card,
+		struct qeth_hdr *hdr, struct sk_buff *skb)
+{
+	struct iphdr *iph = ip_hdr(skb);
+
+	/* tcph->check contains already the pseudo hdr checksum
+	 * so just set the header flags
+	 */
+	if (iph->protocol == IPPROTO_UDP)
+		hdr->hdr.l3.ext_flags |= QETH_HDR_EXT_UDP;
+	hdr->hdr.l3.ext_flags |= QETH_HDR_EXT_CSUM_TRANSP_REQ;
+	if (card->options.performance_stats)
+		card->perf_stats.tx_csum++;
+}
+
 static void qeth_tso_fill_header(struct qeth_card *card,
 		struct qeth_hdr *qhdr, struct sk_buff *skb)
 {
@@ -2852,21 +2897,6 @@ static void qeth_tso_fill_header(struct 
 	}
 }
 
-static void qeth_tx_csum(struct sk_buff *skb)
-{
-	__wsum csum;
-	int offset;
-
-	skb_set_transport_header(skb, skb->csum_start - skb_headroom(skb));
-	offset = skb->csum_start - skb_headroom(skb);
-	BUG_ON(offset >= skb_headlen(skb));
-	csum = skb_checksum(skb, offset, skb->len - offset, 0);
-
-	offset += skb->csum_offset;
-	BUG_ON(offset + sizeof(__sum16) > skb_headlen(skb));
-	*(__sum16 *)(skb->data + offset) = csum_fold(csum);
-}
-
 static inline int qeth_l3_tso_elements(struct sk_buff *skb)
 {
 	unsigned long tcpd = (unsigned long)tcp_hdr(skb) +
@@ -2923,12 +2953,6 @@ static int qeth_l3_hard_start_xmit(struc
 
 	if (skb_is_gso(skb))
 		large_send = card->options.large_send;
-	else
-		if (skb->ip_summed == CHECKSUM_PARTIAL) {
-			qeth_tx_csum(skb);
-			if (card->options.performance_stats)
-				card->perf_stats.tx_csum++;
-		}
 
 	if ((card->info.type == QETH_CARD_TYPE_IQD) && (!large_send) &&
 	    (skb_shinfo(skb)->nr_frags == 0)) {
@@ -3007,6 +3031,9 @@ static int qeth_l3_hard_start_xmit(struc
 						cast_type);
 			hdr->hdr.l3.length = new_skb->len - data_offset;
 		}
+
+		if (skb->ip_summed == CHECKSUM_PARTIAL)
+			qeth_l3_hdr_csum(card, hdr, new_skb);
 	}
 
 	elems = qeth_get_elements_no(card, (void *)hdr, new_skb,
@@ -3132,10 +3159,25 @@ static int qeth_l3_ethtool_set_tso(struc
 	return rc;
 }
 
+static int qeth_l3_ethtool_set_tx_csum(struct net_device *dev, u32 data)
+{
+	struct qeth_card *card = dev->ml_priv;
+
+	if (data) {
+		if (qeth_is_supported(card, IPA_OUTBOUND_CHECKSUM))
+			dev->features |= NETIF_F_IP_CSUM;
+		else
+			return -EPERM;
+	} else
+		dev->features &= ~NETIF_F_IP_CSUM;
+
+	return 0;
+}
+
 static const struct ethtool_ops qeth_l3_ethtool_ops = {
 	.get_link = ethtool_op_get_link,
 	.get_tx_csum = ethtool_op_get_tx_csum,
-	.set_tx_csum = ethtool_op_set_tx_hw_csum,
+	.set_tx_csum = qeth_l3_ethtool_set_tx_csum,
 	.get_rx_csum = qeth_l3_ethtool_get_rx_csum,
 	.set_rx_csum = qeth_l3_ethtool_set_rx_csum,
 	.get_sg      = ethtool_op_get_sg,

