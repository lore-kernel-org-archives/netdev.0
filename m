From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net-next 2/7] gianfar: Add device ref (dev) in gfar_private
Date: Thu, 14 Feb 2013 17:00:02 +0200
Message-ID: <1360854007-11094-3-git-send-email-claudiu.manoil@freescale.com>
References: <1360854007-11094-1-git-send-email-claudiu.manoil@freescale.com>
 <1360854007-11094-2-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe002.messaging.microsoft.com ([216.32.181.182]:13462
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758380Ab3BNPAS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 10:00:18 -0500
In-Reply-To: <1360854007-11094-2-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use device pointer (dev) to simplify the code and to
avoid double indirections, especially on the hot path.

Basically, instead of accessing priv to get the ofdev
reference and then accessing the ofdev structure to
dereference the needed dev pointer, we will get the
dev pointer directly from priv.

The dev pointer is required on the hot path, see gfar_new_rxbdp
or gfar_clean_rx_ring (or xmit), and this patch makes
it available directly from priv's 1st cacheline.

This change is reflected at asm level too, taking (the hot)
gfar_new_rxbdp():
initial version -
    18c0:	7c 7e 1b 78 	mr      r30,r3

    18d0:	81 69 04 3c 	lwz     r11,1084(r9)

    18d8:	34 6b 00 10 	addic.  r3,r11,16
    18dc:	41 82 00 08 	beq-    18e4

patched version -
    18d0:	80 69 04 38 	lwz     r3,1080(r9)

    18d8:	2f 83 00 00 	cmpwi   cr7,r3,0
    18dc:	41 9e 00 08 	beq-    cr7,18e4

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c |   25 +++++++++++++------------
 drivers/net/ethernet/freescale/gianfar.h |    1 +
 2 files changed, 14 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 2c6b569..592d297 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -231,7 +231,7 @@ static int gfar_alloc_skb_resources(struct net_device *ndev)
 	dma_addr_t addr;
 	int i, j, k;
 	struct gfar_private *priv = netdev_priv(ndev);
-	struct device *dev = &priv->ofdev->dev;
+	struct device *dev = priv->dev;
 	struct gfar_priv_tx_q *tx_queue = NULL;
 	struct gfar_priv_rx_q *rx_queue = NULL;
 
@@ -1000,6 +1000,7 @@ static int gfar_probe(struct platform_device *ofdev)
 	priv = netdev_priv(dev);
 	priv->ndev = dev;
 	priv->ofdev = ofdev;
+	priv->dev = &ofdev->dev;
 	SET_NETDEV_DEV(dev, &ofdev->dev);
 
 	spin_lock_init(&priv->bflock);
@@ -1713,13 +1714,13 @@ static void free_skb_tx_queue(struct gfar_priv_tx_q *tx_queue)
 		if (!tx_queue->tx_skbuff[i])
 			continue;
 
-		dma_unmap_single(&priv->ofdev->dev, txbdp->bufPtr,
+		dma_unmap_single(priv->dev, txbdp->bufPtr,
 				 txbdp->length, DMA_TO_DEVICE);
 		txbdp->lstatus = 0;
 		for (j = 0; j < skb_shinfo(tx_queue->tx_skbuff[i])->nr_frags;
 		     j++) {
 			txbdp++;
-			dma_unmap_page(&priv->ofdev->dev, txbdp->bufPtr,
+			dma_unmap_page(priv->dev, txbdp->bufPtr,
 				       txbdp->length, DMA_TO_DEVICE);
 		}
 		txbdp++;
@@ -1740,8 +1741,8 @@ static void free_skb_rx_queue(struct gfar_priv_rx_q *rx_queue)
 
 	for (i = 0; i < rx_queue->rx_ring_size; i++) {
 		if (rx_queue->rx_skbuff[i]) {
-			dma_unmap_single(&priv->ofdev->dev,
-					 rxbdp->bufPtr, priv->rx_buffer_size,
+			dma_unmap_single(priv->dev, rxbdp->bufPtr,
+					 priv->rx_buffer_size,
 					 DMA_FROM_DEVICE);
 			dev_kfree_skb_any(rx_queue->rx_skbuff[i]);
 			rx_queue->rx_skbuff[i] = NULL;
@@ -1780,7 +1781,7 @@ static void free_skb_resources(struct gfar_private *priv)
 			free_skb_rx_queue(rx_queue);
 	}
 
-	dma_free_coherent(&priv->ofdev->dev,
+	dma_free_coherent(priv->dev,
 			  sizeof(struct txbd8) * priv->total_tx_ring_size +
 			  sizeof(struct rxbd8) * priv->total_rx_ring_size,
 			  priv->tx_queue[0]->tx_bd_base,
@@ -2160,7 +2161,7 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			if (i == nr_frags - 1)
 				lstatus |= BD_LFLAG(TXBD_LAST | TXBD_INTERRUPT);
 
-			bufaddr = skb_frag_dma_map(&priv->ofdev->dev,
+			bufaddr = skb_frag_dma_map(priv->dev,
 						   &skb_shinfo(skb)->frags[i],
 						   0,
 						   length,
@@ -2212,7 +2213,7 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		lstatus |= BD_LFLAG(TXBD_TOE);
 	}
 
-	txbdp_start->bufPtr = dma_map_single(&priv->ofdev->dev, skb->data,
+	txbdp_start->bufPtr = dma_map_single(priv->dev, skb->data,
 					     skb_headlen(skb), DMA_TO_DEVICE);
 
 	/* If time stamping is requested one additional TxBD must be set up. The
@@ -2525,7 +2526,7 @@ static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 		} else
 			buflen = bdp->length;
 
-		dma_unmap_single(&priv->ofdev->dev, bdp->bufPtr,
+		dma_unmap_single(priv->dev, bdp->bufPtr,
 				 buflen, DMA_TO_DEVICE);
 
 		if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS)) {
@@ -2544,7 +2545,7 @@ static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 		bdp = next_txbd(bdp, base, tx_ring_size);
 
 		for (i = 0; i < frags; i++) {
-			dma_unmap_page(&priv->ofdev->dev, bdp->bufPtr,
+			dma_unmap_page(priv->dev, bdp->bufPtr,
 				       bdp->length, DMA_TO_DEVICE);
 			bdp->lstatus &= BD_LFLAG(TXBD_WRAP);
 			bdp = next_txbd(bdp, base, tx_ring_size);
@@ -2610,7 +2611,7 @@ static void gfar_new_rxbdp(struct gfar_priv_rx_q *rx_queue, struct rxbd8 *bdp,
 	struct gfar_private *priv = netdev_priv(dev);
 	dma_addr_t buf;
 
-	buf = dma_map_single(&priv->ofdev->dev, skb->data,
+	buf = dma_map_single(priv->dev, skb->data,
 			     priv->rx_buffer_size, DMA_FROM_DEVICE);
 	gfar_init_rxbdp(rx_queue, bdp, buf);
 }
@@ -2775,7 +2776,7 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
 
 		skb = rx_queue->rx_skbuff[rx_queue->skb_currx];
 
-		dma_unmap_single(&priv->ofdev->dev, bdp->bufPtr,
+		dma_unmap_single(priv->dev, bdp->bufPtr,
 				 priv->rx_buffer_size, DMA_FROM_DEVICE);
 
 		if (unlikely(!(bdp->status & RXBD_ERR) &&
diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
index 8b4de57..8b27e5f 100644
--- a/drivers/net/ethernet/freescale/gianfar.h
+++ b/drivers/net/ethernet/freescale/gianfar.h
@@ -1060,6 +1060,7 @@ struct gfar_private {
 	unsigned int total_tx_ring_size;
 	unsigned int total_rx_ring_size;
 
+	struct device *dev;
 	struct net_device *ndev;
 	struct platform_device *ofdev;
 	enum gfar_errata errata;
-- 
1.7.7.4
