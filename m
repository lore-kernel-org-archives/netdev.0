From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net-next 05/40] net: fec: add variable reg_desc_active to speed things up
Date: Thu, 28 Jan 2016 14:25:29 -0700
Message-ID: <1454016364-30985-6-git-send-email-troy.kisky@boundarydevices.com>
References: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@freescale.com, l.stach@pengutronix.de,
	andrew@lunn.ch, tremyfr@gmail.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, laci@boundarydevices.com,
	shawnguo@kernel.org, Troy Kisky <troy.kisky@boundarydevices.com>
To: netdev@vger.kernel.org, davem@davemloft.net, B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:36576 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966171AbcA1V2R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 16:28:17 -0500
Received: by mail-pa0-f41.google.com with SMTP id yy13so29096624pab.3
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2016 13:28:17 -0800 (PST)
In-Reply-To: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need for complex macros every time we need to activate
a queue. Also, no need to call skb_get_queue_mapping when we already
know which queue it is using.

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
---
 drivers/net/ethernet/freescale/fec.h      |  7 +----
 drivers/net/ethernet/freescale/fec_main.c | 44 +++++++++++++++++--------------
 2 files changed, 25 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index 6018d0e4..f8d7fdb 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -294,12 +294,6 @@ struct bufdesc_ex {
 #define FEC_R_BUFF_SIZE(X)	(((X) == 1) ? FEC_R_BUFF_SIZE_1 : \
 				(((X) == 2) ? \
 					FEC_R_BUFF_SIZE_2 : FEC_R_BUFF_SIZE_0))
-#define FEC_R_DES_ACTIVE(X)	(((X) == 1) ? FEC_R_DES_ACTIVE_1 : \
-				(((X) == 2) ? \
-				   FEC_R_DES_ACTIVE_2 : FEC_R_DES_ACTIVE_0))
-#define FEC_X_DES_ACTIVE(X)	(((X) == 1) ? FEC_X_DES_ACTIVE_1 : \
-				(((X) == 2) ? \
-				   FEC_X_DES_ACTIVE_2 : FEC_X_DES_ACTIVE_0))
 
 #define FEC_DMA_CFG(X)		(((X) == 2) ? FEC_DMA_CFG_2 : FEC_DMA_CFG_1)
 
@@ -438,6 +432,7 @@ struct bufdesc_prop {
 	struct bufdesc	*base;
 	struct bufdesc	*last;
 	struct bufdesc	*cur;
+	void __iomem	*reg_desc_active;
 	dma_addr_t	dma;
 	unsigned short ring_size;
 	unsigned char dsize;
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index feff466..0e8c8b6 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -326,7 +326,6 @@ fec_enet_txq_submit_frag_skb(struct fec_enet_priv_tx_q *txq,
 	struct bufdesc *bdp = txq->bd.cur;
 	struct bufdesc_ex *ebdp;
 	int nr_frags = skb_shinfo(skb)->nr_frags;
-	unsigned short queue = skb_get_queue_mapping(skb);
 	int frag, frag_len;
 	unsigned short status;
 	unsigned int estatus = 0;
@@ -359,7 +358,7 @@ fec_enet_txq_submit_frag_skb(struct fec_enet_priv_tx_q *txq,
 
 		if (fep->bufdesc_ex) {
 			if (fep->quirks & FEC_QUIRK_HAS_AVB)
-				estatus |= FEC_TX_BD_FTYPE(queue);
+				estatus |= FEC_TX_BD_FTYPE(txq->bd.qid);
 			if (skb->ip_summed == CHECKSUM_PARTIAL)
 				estatus |= BD_ENET_TX_PINS | BD_ENET_TX_IINS;
 			ebdp->cbd_bdu = 0;
@@ -413,7 +412,6 @@ static int fec_enet_txq_submit_skb(struct fec_enet_priv_tx_q *txq,
 	dma_addr_t addr;
 	unsigned short status;
 	unsigned short buflen;
-	unsigned short queue;
 	unsigned int estatus = 0;
 	unsigned int index;
 	int entries_free;
@@ -442,7 +440,6 @@ static int fec_enet_txq_submit_skb(struct fec_enet_priv_tx_q *txq,
 	bufaddr = skb->data;
 	buflen = skb_headlen(skb);
 
-	queue = skb_get_queue_mapping(skb);
 	index = fec_enet_get_bd_index(bdp, &txq->bd);
 	if (((unsigned long) bufaddr) & fep->tx_align ||
 		fep->quirks & FEC_QUIRK_SWAP_FRAME) {
@@ -485,7 +482,7 @@ static int fec_enet_txq_submit_skb(struct fec_enet_priv_tx_q *txq,
 			skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
 
 		if (fep->quirks & FEC_QUIRK_HAS_AVB)
-			estatus |= FEC_TX_BD_FTYPE(queue);
+			estatus |= FEC_TX_BD_FTYPE(txq->bd.qid);
 
 		if (skb->ip_summed == CHECKSUM_PARTIAL)
 			estatus |= BD_ENET_TX_PINS | BD_ENET_TX_IINS;
@@ -519,7 +516,7 @@ static int fec_enet_txq_submit_skb(struct fec_enet_priv_tx_q *txq,
 	txq->bd.cur = bdp;
 
 	/* Trigger transmission start */
-	writel(0, fep->hwp + FEC_X_DES_ACTIVE(queue));
+	writel(0, txq->bd.reg_desc_active);
 
 	return 0;
 }
@@ -532,7 +529,6 @@ fec_enet_txq_put_data_tso(struct fec_enet_priv_tx_q *txq, struct sk_buff *skb,
 {
 	struct fec_enet_private *fep = netdev_priv(ndev);
 	struct bufdesc_ex *ebdp = container_of(bdp, struct bufdesc_ex, desc);
-	unsigned short queue = skb_get_queue_mapping(skb);
 	unsigned short status;
 	unsigned int estatus = 0;
 	dma_addr_t addr;
@@ -564,7 +560,7 @@ fec_enet_txq_put_data_tso(struct fec_enet_priv_tx_q *txq, struct sk_buff *skb,
 
 	if (fep->bufdesc_ex) {
 		if (fep->quirks & FEC_QUIRK_HAS_AVB)
-			estatus |= FEC_TX_BD_FTYPE(queue);
+			estatus |= FEC_TX_BD_FTYPE(txq->bd.qid);
 		if (skb->ip_summed == CHECKSUM_PARTIAL)
 			estatus |= BD_ENET_TX_PINS | BD_ENET_TX_IINS;
 		ebdp->cbd_bdu = 0;
@@ -593,7 +589,6 @@ fec_enet_txq_put_hdr_tso(struct fec_enet_priv_tx_q *txq,
 	struct fec_enet_private *fep = netdev_priv(ndev);
 	int hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
 	struct bufdesc_ex *ebdp = container_of(bdp, struct bufdesc_ex, desc);
-	unsigned short queue = skb_get_queue_mapping(skb);
 	void *bufaddr;
 	unsigned long dmabuf;
 	unsigned short status;
@@ -628,7 +623,7 @@ fec_enet_txq_put_hdr_tso(struct fec_enet_priv_tx_q *txq,
 
 	if (fep->bufdesc_ex) {
 		if (fep->quirks & FEC_QUIRK_HAS_AVB)
-			estatus |= FEC_TX_BD_FTYPE(queue);
+			estatus |= FEC_TX_BD_FTYPE(txq->bd.qid);
 		if (skb->ip_summed == CHECKSUM_PARTIAL)
 			estatus |= BD_ENET_TX_PINS | BD_ENET_TX_IINS;
 		ebdp->cbd_bdu = 0;
@@ -648,7 +643,6 @@ static int fec_enet_txq_submit_tso(struct fec_enet_priv_tx_q *txq,
 	int hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
 	int total_len, data_left;
 	struct bufdesc *bdp = txq->bd.cur;
-	unsigned short queue = skb_get_queue_mapping(skb);
 	struct tso_t tso;
 	unsigned int index = 0;
 	int ret;
@@ -713,11 +707,11 @@ static int fec_enet_txq_submit_tso(struct fec_enet_priv_tx_q *txq,
 
 	/* Trigger transmission start */
 	if (!(fep->quirks & FEC_QUIRK_ERR007885) ||
-	    !readl(fep->hwp + FEC_X_DES_ACTIVE(queue)) ||
-	    !readl(fep->hwp + FEC_X_DES_ACTIVE(queue)) ||
-	    !readl(fep->hwp + FEC_X_DES_ACTIVE(queue)) ||
-	    !readl(fep->hwp + FEC_X_DES_ACTIVE(queue)))
-		writel(0, fep->hwp + FEC_X_DES_ACTIVE(queue));
+	    !readl(txq->bd.reg_desc_active) ||
+	    !readl(txq->bd.reg_desc_active) ||
+	    !readl(txq->bd.reg_desc_active) ||
+	    !readl(txq->bd.reg_desc_active))
+		writel(0, txq->bd.reg_desc_active);
 
 	return 0;
 
@@ -817,7 +811,7 @@ static void fec_enet_active_rxring(struct net_device *ndev)
 	int i;
 
 	for (i = 0; i < fep->num_rx_queues; i++)
-		writel(0, fep->hwp + FEC_R_DES_ACTIVE(i));
+		writel(0, fep->rx_queue[i]->bd.reg_desc_active);
 }
 
 static void fec_enet_enable_ring(struct net_device *ndev)
@@ -1249,8 +1243,8 @@ fec_enet_tx_queue(struct net_device *ndev, u16 queue_id)
 
 	/* ERR006538: Keep the transmitter going */
 	if (bdp != txq->bd.cur &&
-	    readl(fep->hwp + FEC_X_DES_ACTIVE(queue_id)) == 0)
-		writel(0, fep->hwp + FEC_X_DES_ACTIVE(queue_id));
+	    readl(txq->bd.reg_desc_active) == 0)
+		writel(0, txq->bd.reg_desc_active);
 }
 
 static void
@@ -1490,7 +1484,7 @@ rx_processing_done:
 		 * incoming frames.  On a heavily loaded network, we should be
 		 * able to keep up at the expense of system resources.
 		 */
-		writel(0, fep->hwp + FEC_R_DES_ACTIVE(queue_id));
+		writel(0, rxq->bd.reg_desc_active);
 	}
 	rxq->bd.cur = bdp;
 	return pkt_received;
@@ -3054,6 +3048,14 @@ static const struct net_device_ops fec_netdev_ops = {
 	.ndo_set_features	= fec_set_features,
 };
 
+const unsigned short offset_des_active_rxq[] = {
+	FEC_R_DES_ACTIVE_0, FEC_R_DES_ACTIVE_1, FEC_R_DES_ACTIVE_2
+};
+
+const unsigned short offset_des_active_txq[] = {
+	FEC_X_DES_ACTIVE_0, FEC_X_DES_ACTIVE_1, FEC_X_DES_ACTIVE_2
+};
+
  /*
   * XXX:  We need to clean up on failure exits here.
   *
@@ -3107,6 +3109,7 @@ static int fec_enet_init(struct net_device *ndev)
 		rxq->bd.dma = bd_dma;
 		rxq->bd.dsize = dsize;
 		rxq->bd.dsize_log2 = dsize_log2;
+		rxq->bd.reg_desc_active = fep->hwp + offset_des_active_rxq[i];
 		bd_dma += size;
 		cbd_base = (struct bufdesc *)(((void *)cbd_base) + size);
 		rxq->bd.last = (struct bufdesc *)(((void *)cbd_base) - dsize);
@@ -3122,6 +3125,7 @@ static int fec_enet_init(struct net_device *ndev)
 		txq->bd.dma = bd_dma;
 		txq->bd.dsize = dsize;
 		txq->bd.dsize_log2 = dsize_log2;
+		txq->bd.reg_desc_active = fep->hwp + offset_des_active_txq[i];
 		bd_dma += size;
 		cbd_base = (struct bufdesc *)(((void *)cbd_base) + size);
 		txq->bd.last = (struct bufdesc *)(((void *)cbd_base) - dsize);
-- 
2.5.0
