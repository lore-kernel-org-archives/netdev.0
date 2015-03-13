From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net 1/3] gianfar: Make BDs access endian safe
Date: Fri, 13 Mar 2015 10:36:28 +0200
Message-ID: <1426235790-7011-2-git-send-email-claudiu.manoil@freescale.com>
References: <1426235790-7011-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0137.outbound.protection.outlook.com ([157.56.110.137]:35360
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752082AbbCMIxL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Mar 2015 04:53:11 -0400
In-Reply-To: <1426235790-7011-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use conversion macros to correctly access the BE
fields of the Rx and Tx Buffer Descriptors on LE CPUs.

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 108 ++++++++++++++++++-------------
 drivers/net/ethernet/freescale/gianfar.h |  24 ++++---
 2 files changed, 78 insertions(+), 54 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 7bf3682..af063d8 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -158,7 +158,7 @@ static void gfar_init_rxbdp(struct gfar_priv_rx_q *rx_queue, struct rxbd8 *bdp,
 {
 	u32 lstatus;
 
-	bdp->bufPtr = buf;
+	bdp->bufPtr = cpu_to_be32(buf);
 
 	lstatus = BD_LFLAG(RXBD_EMPTY | RXBD_INTERRUPT);
 	if (bdp == rx_queue->rx_bd_base + rx_queue->rx_ring_size - 1)
@@ -166,7 +166,7 @@ static void gfar_init_rxbdp(struct gfar_priv_rx_q *rx_queue, struct rxbd8 *bdp,
 
 	gfar_wmb();
 
-	bdp->lstatus = lstatus;
+	bdp->lstatus = cpu_to_be32(lstatus);
 }
 
 static int gfar_init_bds(struct net_device *ndev)
@@ -200,7 +200,8 @@ static int gfar_init_bds(struct net_device *ndev)
 
 		/* Set the last descriptor in the ring to indicate wrap */
 		txbdp--;
-		txbdp->status |= TXBD_WRAP;
+		txbdp->status = cpu_to_be16(be16_to_cpu(txbdp->status) |
+					    TXBD_WRAP);
 	}
 
 	rfbptr = &regs->rfbptr0;
@@ -214,7 +215,7 @@ static int gfar_init_bds(struct net_device *ndev)
 			struct sk_buff *skb = rx_queue->rx_skbuff[j];
 
 			if (skb) {
-				bufaddr = rxbdp->bufPtr;
+				bufaddr = be32_to_cpu(rxbdp->bufPtr);
 			} else {
 				skb = gfar_new_skb(ndev, &bufaddr);
 				if (!skb) {
@@ -1884,14 +1885,15 @@ static void free_skb_tx_queue(struct gfar_priv_tx_q *tx_queue)
 		if (!tx_queue->tx_skbuff[i])
 			continue;
 
-		dma_unmap_single(priv->dev, txbdp->bufPtr,
-				 txbdp->length, DMA_TO_DEVICE);
+		dma_unmap_single(priv->dev, be32_to_cpu(txbdp->bufPtr),
+				 be16_to_cpu(txbdp->length), DMA_TO_DEVICE);
 		txbdp->lstatus = 0;
 		for (j = 0; j < skb_shinfo(tx_queue->tx_skbuff[i])->nr_frags;
 		     j++) {
 			txbdp++;
-			dma_unmap_page(priv->dev, txbdp->bufPtr,
-				       txbdp->length, DMA_TO_DEVICE);
+			dma_unmap_page(priv->dev, be32_to_cpu(txbdp->bufPtr),
+				       be16_to_cpu(txbdp->length),
+				       DMA_TO_DEVICE);
 		}
 		txbdp++;
 		dev_kfree_skb_any(tx_queue->tx_skbuff[i]);
@@ -1911,7 +1913,7 @@ static void free_skb_rx_queue(struct gfar_priv_rx_q *rx_queue)
 
 	for (i = 0; i < rx_queue->rx_ring_size; i++) {
 		if (rx_queue->rx_skbuff[i]) {
-			dma_unmap_single(priv->dev, rxbdp->bufPtr,
+			dma_unmap_single(priv->dev, be32_to_cpu(rxbdp->bufPtr),
 					 priv->rx_buffer_size,
 					 DMA_FROM_DEVICE);
 			dev_kfree_skb_any(rx_queue->rx_skbuff[i]);
@@ -2298,7 +2300,7 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	tx_queue->stats.tx_packets++;
 
 	txbdp = txbdp_start = tx_queue->cur_tx;
-	lstatus = txbdp->lstatus;
+	lstatus = be32_to_cpu(txbdp->lstatus);
 
 	/* Time stamp insertion requires one additional TxBD */
 	if (unlikely(do_tstamp))
@@ -2306,11 +2308,14 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 						 tx_queue->tx_ring_size);
 
 	if (nr_frags == 0) {
-		if (unlikely(do_tstamp))
-			txbdp_tstamp->lstatus |= BD_LFLAG(TXBD_LAST |
-							  TXBD_INTERRUPT);
-		else
+		if (unlikely(do_tstamp)) {
+			u32 lstatus_ts = be32_to_cpu(txbdp_tstamp->lstatus);
+
+			lstatus_ts |= BD_LFLAG(TXBD_LAST | TXBD_INTERRUPT);
+			txbdp_tstamp->lstatus = cpu_to_be32(lstatus_ts);
+		} else {
 			lstatus |= BD_LFLAG(TXBD_LAST | TXBD_INTERRUPT);
+		}
 	} else {
 		/* Place the fragment addresses and lengths into the TxBDs */
 		for (i = 0; i < nr_frags; i++) {
@@ -2320,7 +2325,7 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 			frag_len = skb_shinfo(skb)->frags[i].size;
 
-			lstatus = txbdp->lstatus | frag_len |
+			lstatus = be32_to_cpu(txbdp->lstatus) | frag_len |
 				  BD_LFLAG(TXBD_READY);
 
 			/* Handle the last BD specially */
@@ -2336,11 +2341,11 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 				goto dma_map_err;
 
 			/* set the TxBD length and buffer pointer */
-			txbdp->bufPtr = bufaddr;
-			txbdp->lstatus = lstatus;
+			txbdp->bufPtr = cpu_to_be32(bufaddr);
+			txbdp->lstatus = cpu_to_be32(lstatus);
 		}
 
-		lstatus = txbdp_start->lstatus;
+		lstatus = be32_to_cpu(txbdp_start->lstatus);
 	}
 
 	/* Add TxPAL between FCB and frame if required */
@@ -2388,7 +2393,7 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (unlikely(dma_mapping_error(priv->dev, bufaddr)))
 		goto dma_map_err;
 
-	txbdp_start->bufPtr = bufaddr;
+	txbdp_start->bufPtr = cpu_to_be32(bufaddr);
 
 	/* If time stamping is requested one additional TxBD must be set up. The
 	 * first TxBD points to the FCB and must have a data length of
@@ -2396,9 +2401,15 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 * the full frame length.
 	 */
 	if (unlikely(do_tstamp)) {
-		txbdp_tstamp->bufPtr = txbdp_start->bufPtr + fcb_len;
-		txbdp_tstamp->lstatus |= BD_LFLAG(TXBD_READY) |
-					 (skb_headlen(skb) - fcb_len);
+		u32 lstatus_ts = be32_to_cpu(txbdp_tstamp->lstatus);
+
+		bufaddr = be32_to_cpu(txbdp_start->bufPtr);
+		bufaddr += fcb_len;
+		lstatus_ts |= BD_LFLAG(TXBD_READY) |
+			      (skb_headlen(skb) - fcb_len);
+
+		txbdp_tstamp->bufPtr = cpu_to_be32(bufaddr);
+		txbdp_tstamp->lstatus = cpu_to_be32(lstatus_ts);
 		lstatus |= BD_LFLAG(TXBD_CRC | TXBD_READY) | GMAC_FCB_LEN;
 	} else {
 		lstatus |= BD_LFLAG(TXBD_CRC | TXBD_READY) | skb_headlen(skb);
@@ -2421,7 +2432,7 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	gfar_wmb();
 
-	txbdp_start->lstatus = lstatus;
+	txbdp_start->lstatus = cpu_to_be32(lstatus);
 
 	gfar_wmb(); /* force lstatus write before tx_skbuff */
 
@@ -2460,13 +2471,14 @@ dma_map_err:
 	if (do_tstamp)
 		txbdp = next_txbd(txbdp, base, tx_queue->tx_ring_size);
 	for (i = 0; i < nr_frags; i++) {
-		lstatus = txbdp->lstatus;
+		lstatus = be32_to_cpu(txbdp->lstatus);
 		if (!(lstatus & BD_LFLAG(TXBD_READY)))
 			break;
 
-		txbdp->lstatus = lstatus & ~BD_LFLAG(TXBD_READY);
-		bufaddr = txbdp->bufPtr;
-		dma_unmap_page(priv->dev, bufaddr, txbdp->length,
+		lstatus &= ~BD_LFLAG(TXBD_READY);
+		txbdp->lstatus = cpu_to_be32(lstatus);
+		bufaddr = be32_to_cpu(txbdp->bufPtr);
+		dma_unmap_page(priv->dev, bufaddr, be16_to_cpu(txbdp->length),
 			       DMA_TO_DEVICE);
 		txbdp = next_txbd(txbdp, base, tx_queue->tx_ring_size);
 	}
@@ -2607,7 +2619,7 @@ static void gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 
 		lbdp = skip_txbd(bdp, nr_txbds - 1, base, tx_ring_size);
 
-		lstatus = lbdp->lstatus;
+		lstatus = be32_to_cpu(lbdp->lstatus);
 
 		/* Only clean completed frames */
 		if ((lstatus & BD_LFLAG(TXBD_READY)) &&
@@ -2616,11 +2628,12 @@ static void gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 
 		if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS)) {
 			next = next_txbd(bdp, base, tx_ring_size);
-			buflen = next->length + GMAC_FCB_LEN + GMAC_TXPAL_LEN;
+			buflen = be16_to_cpu(next->length) +
+				 GMAC_FCB_LEN + GMAC_TXPAL_LEN;
 		} else
-			buflen = bdp->length;
+			buflen = be16_to_cpu(bdp->length);
 
-		dma_unmap_single(priv->dev, bdp->bufPtr,
+		dma_unmap_single(priv->dev, be32_to_cpu(bdp->bufPtr),
 				 buflen, DMA_TO_DEVICE);
 
 		if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS)) {
@@ -2631,17 +2644,18 @@ static void gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 			shhwtstamps.hwtstamp = ns_to_ktime(*ns);
 			skb_pull(skb, GMAC_FCB_LEN + GMAC_TXPAL_LEN);
 			skb_tstamp_tx(skb, &shhwtstamps);
-			bdp->lstatus &= BD_LFLAG(TXBD_WRAP);
+			gfar_clear_txbd_status(bdp);
 			bdp = next;
 		}
 
-		bdp->lstatus &= BD_LFLAG(TXBD_WRAP);
+		gfar_clear_txbd_status(bdp);
 		bdp = next_txbd(bdp, base, tx_ring_size);
 
 		for (i = 0; i < frags; i++) {
-			dma_unmap_page(priv->dev, bdp->bufPtr,
-				       bdp->length, DMA_TO_DEVICE);
-			bdp->lstatus &= BD_LFLAG(TXBD_WRAP);
+			dma_unmap_page(priv->dev, be32_to_cpu(bdp->bufPtr),
+				       be16_to_cpu(bdp->length),
+				       DMA_TO_DEVICE);
+			gfar_clear_txbd_status(bdp);
 			bdp = next_txbd(bdp, base, tx_ring_size);
 		}
 
@@ -2874,7 +2888,7 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
 
 	amount_pull = priv->uses_rxfcb ? GMAC_FCB_LEN : 0;
 
-	while (!((bdp->status & RXBD_EMPTY) || (--rx_work_limit < 0))) {
+	while (!(be16_to_cpu(bdp->status) & RXBD_EMPTY) && rx_work_limit--) {
 		struct sk_buff *newskb;
 		dma_addr_t bufaddr;
 
@@ -2885,21 +2899,22 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
 
 		skb = rx_queue->rx_skbuff[rx_queue->skb_currx];
 
-		dma_unmap_single(priv->dev, bdp->bufPtr,
+		dma_unmap_single(priv->dev, be32_to_cpu(bdp->bufPtr),
 				 priv->rx_buffer_size, DMA_FROM_DEVICE);
 
-		if (unlikely(!(bdp->status & RXBD_ERR) &&
-			     bdp->length > priv->rx_buffer_size))
-			bdp->status = RXBD_LARGE;
+		if (unlikely(!(be16_to_cpu(bdp->status) & RXBD_ERR) &&
+			     be16_to_cpu(bdp->length) > priv->rx_buffer_size))
+			bdp->status = cpu_to_be16(RXBD_LARGE);
 
 		/* We drop the frame if we failed to allocate a new buffer */
-		if (unlikely(!newskb || !(bdp->status & RXBD_LAST) ||
-			     bdp->status & RXBD_ERR)) {
-			count_errors(bdp->status, dev);
+		if (unlikely(!newskb ||
+			     !(be16_to_cpu(bdp->status) & RXBD_LAST) ||
+			     be16_to_cpu(bdp->status) & RXBD_ERR)) {
+			count_errors(be16_to_cpu(bdp->status), dev);
 
 			if (unlikely(!newskb)) {
 				newskb = skb;
-				bufaddr = bdp->bufPtr;
+				bufaddr = be32_to_cpu(bdp->bufPtr);
 			} else if (skb)
 				dev_kfree_skb(skb);
 		} else {
@@ -2908,7 +2923,8 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
 			howmany++;
 
 			if (likely(skb)) {
-				pkt_len = bdp->length - ETH_FCS_LEN;
+				pkt_len = be16_to_cpu(bdp->length) -
+					  ETH_FCS_LEN;
 				/* Remove the FCS from the packet length */
 				skb_put(skb, pkt_len);
 				rx_queue->stats.rx_bytes += pkt_len;
diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
index 9e18024..f792c79 100644
--- a/drivers/net/ethernet/freescale/gianfar.h
+++ b/drivers/net/ethernet/freescale/gianfar.h
@@ -544,12 +544,12 @@ struct txbd8
 {
 	union {
 		struct {
-			u16	status;	/* Status Fields */
-			u16	length;	/* Buffer length */
+			__be16	status;	/* Status Fields */
+			__be16	length;	/* Buffer length */
 		};
-		u32 lstatus;
+		__be32 lstatus;
 	};
-	u32	bufPtr;	/* Buffer Pointer */
+	__be32	bufPtr;	/* Buffer Pointer */
 };
 
 struct txfcb {
@@ -565,12 +565,12 @@ struct rxbd8
 {
 	union {
 		struct {
-			u16	status;	/* Status Fields */
-			u16	length;	/* Buffer Length */
+			__be16	status;	/* Status Fields */
+			__be16	length;	/* Buffer Length */
 		};
-		u32 lstatus;
+		__be32 lstatus;
 	};
-	u32	bufPtr;	/* Buffer Pointer */
+	__be32	bufPtr;	/* Buffer Pointer */
 };
 
 struct rxfcb {
@@ -1287,6 +1287,14 @@ static inline void gfar_wmb(void)
 #endif
 }
 
+static inline void gfar_clear_txbd_status(struct txbd8 *bdp)
+{
+	u32 lstatus = be32_to_cpu(bdp->lstatus);
+
+	lstatus &= BD_LFLAG(TXBD_WRAP);
+	bdp->lstatus = cpu_to_be32(lstatus);
+}
+
 irqreturn_t gfar_receive(int irq, void *dev_id);
 int startup_gfar(struct net_device *dev);
 void stop_gfar(struct net_device *dev);
-- 
1.7.11.7
