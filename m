From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH v2 net-next 08/11] qede: Don't check netdevice for rx-hash
Date: Tue, 29 Nov 2016 16:47:07 +0200
Message-ID: <1480430830-17671-9-git-send-email-Yuval.Mintz@cavium.com>
References: <1480430830-17671-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:52300 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1757745AbcK2Org (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 09:47:36 -0500
In-Reply-To: <1480430830-17671-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Receive-hashing is a fixed feature, so there's no need to check
during the ingress datapath whether it's set or not.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qede/qede_main.c | 34 ++++++++++------------------
 1 file changed, 12 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 615202f..ec01de2 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -997,22 +997,20 @@ void qede_update_rx_prod(struct qede_dev *edev, struct qede_rx_queue *rxq)
 	mmiowb();
 }
 
-static u32 qede_get_rxhash(struct qede_dev *edev,
-			   u8 bitfields,
-			   __le32 rss_hash, enum pkt_hash_types *rxhash_type)
+static void qede_get_rxhash(struct sk_buff *skb, u8 bitfields, __le32 rss_hash)
 {
+	enum pkt_hash_types hash_type = PKT_HASH_TYPE_NONE;
 	enum rss_hash_type htype;
+	u32 hash = 0;
 
 	htype = GET_FIELD(bitfields, ETH_FAST_PATH_RX_REG_CQE_RSS_HASH_TYPE);
-
-	if ((edev->ndev->features & NETIF_F_RXHASH) && htype) {
-		*rxhash_type = ((htype == RSS_HASH_TYPE_IPV4) ||
-				(htype == RSS_HASH_TYPE_IPV6)) ?
-				PKT_HASH_TYPE_L3 : PKT_HASH_TYPE_L4;
-		return le32_to_cpu(rss_hash);
+	if (htype) {
+		hash_type = ((htype == RSS_HASH_TYPE_IPV4) ||
+			     (htype == RSS_HASH_TYPE_IPV6)) ?
+			    PKT_HASH_TYPE_L3 : PKT_HASH_TYPE_L4;
+		hash = le32_to_cpu(rss_hash);
 	}
-	*rxhash_type = PKT_HASH_TYPE_NONE;
-	return 0;
+	skb_set_hash(skb, hash, hash_type);
 }
 
 static void qede_set_skb_csum(struct sk_buff *skb, u8 csum_flag)
@@ -1104,8 +1102,6 @@ static void qede_tpa_start(struct qede_dev *edev,
 	dma_addr_t mapping = tpa_info->buffer_mapping;
 	struct sw_rx_data *sw_rx_data_cons;
 	struct sw_rx_data *sw_rx_data_prod;
-	enum pkt_hash_types rxhash_type;
-	u32 rxhash;
 
 	sw_rx_data_cons = &rxq->sw_rx_ring[rxq->sw_rx_cons & NUM_RX_BDS_MAX];
 	sw_rx_data_prod = &rxq->sw_rx_ring[rxq->sw_rx_prod & NUM_RX_BDS_MAX];
@@ -1150,10 +1146,6 @@ static void qede_tpa_start(struct qede_dev *edev,
 	tpa_info->frag_id = 0;
 	tpa_info->state = QEDE_AGG_STATE_START;
 
-	rxhash = qede_get_rxhash(edev, cqe->bitfields,
-				 cqe->rss_hash, &rxhash_type);
-	skb_set_hash(tpa_info->skb, rxhash, rxhash_type);
-
 	/* Store some information from first CQE */
 	tpa_info->start_cqe_placement_offset = cqe->placement_offset;
 	tpa_info->start_cqe_bd_len = le16_to_cpu(cqe->len_on_first_bd);
@@ -1164,6 +1156,8 @@ static void qede_tpa_start(struct qede_dev *edev,
 	else
 		tpa_info->vlan_tag = 0;
 
+	qede_get_rxhash(tpa_info->skb, cqe->bitfields, cqe->rss_hash);
+
 	/* This is needed in order to enable forwarding support */
 	qede_set_gro_params(edev, tpa_info->skb, cqe);
 
@@ -1541,14 +1535,12 @@ static int qede_rx_process_cqe(struct qede_dev *edev,
 {
 	struct eth_fast_path_rx_reg_cqe *fp_cqe;
 	u16 len, pad, bd_cons_idx, parse_flag;
-	enum pkt_hash_types rxhash_type;
 	enum eth_rx_cqe_type cqe_type;
 	union eth_rx_cqe *cqe;
 	struct sw_rx_data *bd;
 	struct sk_buff *skb;
 	__le16 flags;
 	u8 csum_flag;
-	u32 rx_hash;
 
 	/* Get the CQE from the completion ring */
 	cqe = (union eth_rx_cqe *)qed_chain_consume(&rxq->rx_comp_ring);
@@ -1621,9 +1613,7 @@ static int qede_rx_process_cqe(struct qede_dev *edev,
 
 	/* The SKB contains all the data. Now prepare meta-magic */
 	skb->protocol = eth_type_trans(skb, edev->ndev);
-	rx_hash = qede_get_rxhash(edev, fp_cqe->bitfields,
-				  fp_cqe->rss_hash, &rxhash_type);
-	skb_set_hash(skb, rx_hash, rxhash_type);
+	qede_get_rxhash(skb, fp_cqe->bitfields, fp_cqe->rss_hash);
 	qede_set_skb_csum(skb, csum_flag);
 	skb_record_rx_queue(skb, rxq->rxq_id);
 
-- 
1.9.3
