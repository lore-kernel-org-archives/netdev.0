From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net-next V2 5/8] net: fec: add variable reg_desc_active to speed things up
Date: Fri,  5 Feb 2016 14:52:47 -0700
Message-ID: <1454709170-19527-6-git-send-email-troy.kisky@boundarydevices.com>
References: <1454709170-19527-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@freescale.com, l.stach@pengutronix.de,
	andrew@lunn.ch, tremyfr@gmail.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, laci@boundarydevices.com,
	shawnguo@kernel.org, johannes@sipsolutions.net, arnd@arndb.de,
	Troy Kisky <troy.kisky@boundarydevices.com>
To: netdev@vger.kernel.org, davem@davemloft.net, B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36776 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751406AbcBEVzN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2016 16:55:13 -0500
Received: by mail-pa0-f44.google.com with SMTP id yy13so40329020pab.3
        for <netdev@vger.kernel.org>; Fri, 05 Feb 2016 13:55:13 -0800 (PST)
In-Reply-To: <1454709170-19527-1-git-send-email-troy.kisky@boundarydevices.com>
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
index 53ec04f..bedd28a 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -310,12 +310,6 @@ struct bufdesc_ex {
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
 
@@ -454,6 +448,7 @@ struct bufdesc_prop {
 	struct bufdesc	*base;
 	struct bufdesc	*last;
 	struct bufdesc	*cur;
+	void __iomem	*reg_desc_active;
 	dma_addr_t	dma;
 	unsigned short ring_size;
 	unsigned char dsize;
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index b039288..712e3bb 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -328,7 +328,6 @@ fec_enet_txq_submit_frag_skb(struct fec_enet_priv_tx_q *txq,
 	struct bufdesc *bdp = txq->bd.cur;
 	struct bufdesc_ex *ebdp;
 	int nr_frags = skb_shinfo(skb)->nr_frags;
-	unsigned short queue = skb_get_queue_mapping(skb);
 	int frag, frag_len;
 	unsigned short status;
 	unsigned int estatus = 0;
@@ -361,7 +360,7 @@ fec_enet_txq_submit_frag_skb(struct fec_enet_priv_tx_q *txq,
 
 		if (fep->bufdesc_ex) {
 			if (fep->quirks & FEC_QUIRK_HAS_AVB)
-				estatus |= FEC_TX_BD_FTYPE(queue);
+				estatus |= FEC_TX_BD_FTYPE(txq->bd.qid);
 			if (skb->ip_summed == CHECKSUM_PARTIAL)
 				estatus |= BD_ENET_TX_PINS | BD_ENET_TX_IINS;
 			ebdp->cbd_bdu = 0;
@@ -415,7 +414,6 @@ static int fec_enet_txq_submit_skb(struct fec_enet_priv_tx_q *txq,
 	dma_addr_t addr;
 	unsigned short status;
 	unsigned short buflen;
-	unsigned short queue;
 	unsigned int estatus = 0;
 	unsigned int index;
 	int entries_free;
@@ -444,7 +442,6 @@ static int fec_enet_txq_submit_skb(struct fec_enet_priv_tx_q *txq,
 	bufaddr = skb->data;
 	buflen = skb_headlen(skb);
 
-	queue = skb_get_queue_mapping(skb);
 	index = fec_enet_get_bd_index(bdp, &txq->bd);
 	if (((unsigned long) bufaddr) & fep->tx_align ||
 		fep->quirks & FEC_QUIRK_SWAP_FRAME) {
@@ -487,7 +484,7 @@ static int fec_enet_txq_submit_skb(struct fec_enet_priv_tx_q *txq,
 			skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
 
 		if (fep->quirks & FEC_QUIRK_HAS_AVB)
-			estatus |= FEC_TX_BD_FTYPE(queue);
+			estatus |= FEC_TX_BD_FTYPE(txq->bd.qid);
 
 		if (skb->ip_summed == CHECKSUM_PARTIAL)
 			estatus |= BD_ENET_TX_PINS | BD_ENET_TX_IINS;
@@ -521,7 +518,7 @@ static int fec_enet_txq_submit_skb(struct fec_enet_priv_tx_q *txq,
 	txq->bd.cur = bdp;
 
 	/* Trigger transmission start */
-	writel(0, fep->hwp + FEC_X_DES_ACTIVE(queue));
+	writel(0, txq->bd.reg_desc_active);
 
 	return 0;
 }
@@ -534,7 +531,6 @@ fec_enet_txq_put_data_tso(struct fec_enet_priv_tx_q *txq, struct sk_buff *skb,
 {
 	struct fec_enet_private *fep = netdev_priv(ndev);
 	struct bufdesc_ex *ebdp = container_of(bdp, struct bufdesc_ex, desc);
-	unsigned short queue = skb_get_queue_mapping(skb);
 	unsigned short status;
 	unsigned int estatus = 0;
 	dma_addr_t addr;
@@ -566,7 +562,7 @@ fec_enet_txq_put_data_tso(struct fec_enet_priv_tx_q *txq, struct sk_buff *skb,
 
 	if (fep->bufdesc_ex) {
 		if (fep->quirks & FEC_QUIRK_HAS_AVB)
-			estatus |= FEC_TX_BD_FTYPE(queue);
+			estatus |= FEC_TX_BD_FTYPE(txq->bd.qid);
 		if (skb->ip_summed == CHECKSUM_PARTIAL)
 			estatus |= BD_ENET_TX_PINS | BD_ENET_TX_IINS;
 		ebdp->cbd_bdu = 0;
@@ -595,7 +591,6 @@ fec_enet_txq_put_hdr_tso(struct fec_enet_priv_tx_q *txq,
 	struct fec_enet_private *fep = netdev_priv(ndev);
 	int hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
 	struct bufdesc_ex *ebdp = container_of(bdp, struct bufdesc_ex, desc);
-	unsigned short queue = skb_get_queue_mapping(skb);
 	void *bufaddr;
 	unsigned long dmabuf;
 	unsigned short status;
@@ -630,7 +625,7 @@ fec_enet_txq_put_hdr_tso(struct fec_enet_priv_tx_q *txq,
 
 	if (fep->bufdesc_ex) {
 		if (fep->quirks & FEC_QUIRK_HAS_AVB)
-			estatus |= FEC_TX_BD_FTYPE(queue);
+			estatus |= FEC_TX_BD_FTYPE(txq->bd.qid);
 		if (skb->ip_summed == CHECKSUM_PARTIAL)
 			estatus |= BD_ENET_TX_PINS | BD_ENET_TX_IINS;
 		ebdp->cbd_bdu = 0;
@@ -650,7 +645,6 @@ static int fec_enet_txq_submit_tso(struct fec_enet_priv_tx_q *txq,
 	int hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
 	int total_len, data_left;
 	struct bufdesc *bdp = txq->bd.cur;
-	unsigned short queue = skb_get_queue_mapping(skb);
 	struct tso_t tso;
 	unsigned int index = 0;
 	int ret;
@@ -715,11 +709,11 @@ static int fec_enet_txq_submit_tso(struct fec_enet_priv_tx_q *txq,
 
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
 
@@ -819,7 +813,7 @@ static void fec_enet_active_rxring(struct net_device *ndev)
 	int i;
 
 	for (i = 0; i < fep->num_rx_queues; i++)
-		writel(0, fep->hwp + FEC_R_DES_ACTIVE(i));
+		writel(0, fep->rx_queue[i]->bd.reg_desc_active);
 }
 
 static void fec_enet_enable_ring(struct net_device *ndev)
@@ -1255,8 +1249,8 @@ fec_enet_tx_queue(struct net_device *ndev, u16 queue_id)
 
 	/* ERR006538: Keep the transmitter going */
 	if (bdp != txq->bd.cur &&
-	    readl(fep->hwp + FEC_X_DES_ACTIVE(queue_id)) == 0)
-		writel(0, fep->hwp + FEC_X_DES_ACTIVE(queue_id));
+	    readl(txq->bd.reg_desc_active) == 0)
+		writel(0, txq->bd.reg_desc_active);
 }
 
 static void
@@ -1498,7 +1492,7 @@ rx_processing_done:
 		 * incoming frames.  On a heavily loaded network, we should be
 		 * able to keep up at the expense of system resources.
 		 */
-		writel(0, fep->hwp + FEC_R_DES_ACTIVE(queue_id));
+		writel(0, rxq->bd.reg_desc_active);
 	}
 	rxq->bd.cur = bdp;
 	return pkt_received;
@@ -3061,6 +3055,14 @@ static const struct net_device_ops fec_netdev_ops = {
 	.ndo_set_features	= fec_set_features,
 };
 
+static const unsigned short offset_des_active_rxq[] = {
+	FEC_R_DES_ACTIVE_0, FEC_R_DES_ACTIVE_1, FEC_R_DES_ACTIVE_2
+};
+
+static const unsigned short offset_des_active_txq[] = {
+	FEC_X_DES_ACTIVE_0, FEC_X_DES_ACTIVE_1, FEC_X_DES_ACTIVE_2
+};
+
  /*
   * XXX:  We need to clean up on failure exits here.
   *
@@ -3114,6 +3116,7 @@ static int fec_enet_init(struct net_device *ndev)
 		rxq->bd.dma = bd_dma;
 		rxq->bd.dsize = dsize;
 		rxq->bd.dsize_log2 = dsize_log2;
+		rxq->bd.reg_desc_active = fep->hwp + offset_des_active_rxq[i];
 		bd_dma += size;
 		cbd_base = (struct bufdesc *)(((void *)cbd_base) + size);
 		rxq->bd.last = (struct bufdesc *)(((void *)cbd_base) - dsize);
@@ -3129,6 +3132,7 @@ static int fec_enet_init(struct net_device *ndev)
 		txq->bd.dma = bd_dma;
 		txq->bd.dsize = dsize;
 		txq->bd.dsize_log2 = dsize_log2;
+		txq->bd.reg_desc_active = fep->hwp + offset_des_active_txq[i];
 		bd_dma += size;
 		cbd_base = (struct bufdesc *)(((void *)cbd_base) + size);
 		txq->bd.last = (struct bufdesc *)(((void *)cbd_base) - dsize);
-- 
2.5.0
