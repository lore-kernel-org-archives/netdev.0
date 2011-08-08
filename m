From: Tom Herbert <therbert@google.com>
Subject: [RFC PATCH v2 8/9] bnx2x: Support for byte queue limits
Date: Sun, 7 Aug 2011 21:53:44 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.1108072151330.13721@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:23068 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751241Ab1HHExr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 00:53:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes to bnx2x to use byte queue limits.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/bnx2x/bnx2x_cmn.c |   26 ++++++++++++++++++++++----
 1 files changed, 22 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index 5b0dba6..d4f921a 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -97,7 +97,8 @@ int load_count[2][3] = { {0} }; /* per-path: 0-common, 1-port0, 2-port1 */
  * return idx of last bd freed
  */
 static u16 bnx2x_free_tx_pkt(struct bnx2x *bp, struct bnx2x_fp_txdata *txdata,
-			     u16 idx)
+			     u16 idx, unsigned int *pkts_compl,
+			     unsigned int *bytes_compl)
 {
 	struct sw_tx_bd *tx_buf = &txdata->tx_buf_ring[idx];
 	struct eth_tx_start_bd *tx_start_bd;
@@ -154,6 +155,10 @@ static u16 bnx2x_free_tx_pkt(struct bnx2x *bp, struct bnx2x_fp_txdata *txdata,
 
 	/* release skb */
 	WARN_ON(!skb);
+	if (skb) {
+		(*pkts_compl)++;
+		(*bytes_compl) += skb->len;
+	}
 	dev_kfree_skb_any(skb);
 	tx_buf->first_bd = 0;
 	tx_buf->skb = NULL;
@@ -165,6 +170,7 @@ int bnx2x_tx_int(struct bnx2x *bp, struct bnx2x_fp_txdata *txdata)
 {
 	struct netdev_queue *txq;
 	u16 hw_cons, sw_cons, bd_cons = txdata->tx_bd_cons;
+	unsigned int pkts_compl = 0, bytes_compl = 0;
 
 #ifdef BNX2X_STOP_ON_ERROR
 	if (unlikely(bp->panic))
@@ -184,10 +190,13 @@ int bnx2x_tx_int(struct bnx2x *bp, struct bnx2x_fp_txdata *txdata)
 				      " pkt_cons %u\n",
 		   txdata->txq_index, hw_cons, sw_cons, pkt_cons);
 
-		bd_cons = bnx2x_free_tx_pkt(bp, txdata, pkt_cons);
+		bd_cons = bnx2x_free_tx_pkt(bp, txdata, pkt_cons,
+		    &pkts_compl, &bytes_compl);
 		sw_cons++;
 	}
 
+	netdev_tx_completed_queue(txq, pkts_compl, bytes_compl);
+
 	txdata->tx_pkt_cons = sw_cons;
 	txdata->tx_bd_cons = bd_cons;
 
@@ -1088,6 +1097,7 @@ static void bnx2x_free_tx_skbs(struct bnx2x *bp)
 		struct bnx2x_fastpath *fp = &bp->fp[i];
 		for_each_cos_in_tx_queue(fp, cos) {
 			struct bnx2x_fp_txdata *txdata = &fp->txdata[cos];
+			unsigned pkts_compl = 0, bytes_compl = 0;
 
 			u16 bd_cons = txdata->tx_bd_cons;
 			u16 sw_prod = txdata->tx_pkt_prod;
@@ -1095,9 +1105,13 @@ static void bnx2x_free_tx_skbs(struct bnx2x *bp)
 
 			while (sw_cons != sw_prod) {
 				bd_cons = bnx2x_free_tx_pkt(bp, txdata,
-							    TX_BD(sw_cons));
+							    TX_BD(sw_cons),
+							    &pkts_compl,
+							    &bytes_compl);
 				sw_cons++;
 			}
+			netdev_tx_reset_queue(
+			    netdev_get_tx_queue(bp->dev, txdata->txq_index));
 		}
 	}
 }
@@ -2771,6 +2785,7 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 				       frag->page_offset, frag->size,
 				       DMA_TO_DEVICE);
 		if (unlikely(dma_mapping_error(&bp->pdev->dev, mapping))) {
+			unsigned int pkts_compl = 0, bytes_compl = 0;
 
 			DP(NETIF_MSG_TX_QUEUED, "Unable to map page - "
 						"dropping packet...\n");
@@ -2782,7 +2797,8 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			 */
 			first_bd->nbd = cpu_to_le16(nbd);
 			bnx2x_free_tx_pkt(bp, txdata,
-					  TX_BD(txdata->tx_pkt_prod));
+					  TX_BD(txdata->tx_pkt_prod),
+					  &pkts_compl, &bytes_compl);
 			return NETDEV_TX_OK;
 		}
 
@@ -2843,6 +2859,8 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		   pbd_e2->parsing_data);
 	DP(NETIF_MSG_TX_QUEUED, "doorbell: nbd %d  bd %u\n", nbd, bd_prod);
 
+	netdev_tx_sent_queue(txq, 1, skb->len);
+
 	txdata->tx_pkt_prod++;
 	/*
 	 * Make sure that the BD data is updated before updating the producer
-- 
1.7.3.1

