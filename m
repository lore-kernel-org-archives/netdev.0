From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net-next 2/2] gianfar: Bundle rx buffer allocation
Date: Mon, 11 Mar 2013 18:54:37 +0200
Message-ID: <1363020877-30223-2-git-send-email-claudiu.manoil@freescale.com>
References: <1363020877-30223-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe002.messaging.microsoft.com ([207.46.163.25]:58642
	"EHLO co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753245Ab3CKQyp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 12:54:45 -0400
In-Reply-To: <1363020877-30223-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use a more common and efficient pattern for rx buffer processing.
Instead of allocating one new buffer (skb) and processing (cleanning up)
the "current" buffer for each iteration, use a more efficient
approach that bundles the allocation of several rx buffers at a time.
This way the 2 rx jobs (buffer processing & buffer allocation) are
more localized along processing iterations.

So, for each Rx ring we have the next_to_clean index which points to
the first received buffer and gets updated by the buffer cleanup
routine. The next_to_alloc index is updated during buffer allocation.
Once a given number of Rx buffers have been cleaned up/ processed,
rx allocation is being invoked to refill the cleaned-up BDs with new
buffers to accommodate the subsequent Rx packets. This is how the
bundling effect is achieved.

The number of unused BDs to be refilled with new allocated buffers
can be computed based on the next_to_clean and next_to_alloc indexes.
The implementation follows a commonly used pattern in other drivers too.
gfar_alloc_rx_buff() is now the rx buffer allocation routine, the only
method that updates the next_to_alloc index of a given ring. It tries
(on a best effort basis) to refill/ alloc the requested number of
buffers, and updates next_to_alloc to reflect the actual number of allocated
buffers. While it has work to do, the rx cleanup routine requests buffer
allocations for a fixed number of buffers (bundle), and when there's
nothing left to clean it makes a final request to refill the remaining
unused BDs with new buffers before exiting.

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c |  126 +++++++++++++++---------------
 drivers/net/ethernet/freescale/gianfar.h |   14 +++-
 2 files changed, 73 insertions(+), 67 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index af91196..f117da6 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -110,7 +110,8 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev);
 static void gfar_reset_task(struct work_struct *work);
 static void gfar_timeout(struct net_device *dev);
 static int gfar_close(struct net_device *dev);
-static struct sk_buff *gfar_alloc_skb(struct net_device *dev);
+static void gfar_alloc_rx_buff(struct gfar_priv_rx_q *rx_queue,
+			       int alloc_cnt);
 static void gfar_new_rxbdp(struct gfar_priv_rx_q *rx_queue, struct rxbd8 *bdp,
 			   struct sk_buff *skb);
 static int gfar_set_mac_address(struct net_device *dev);
@@ -163,13 +164,12 @@ static void gfar_init_rxbdp(struct gfar_priv_rx_q *rx_queue, struct rxbd8 *bdp,
 	bdp->lstatus = lstatus;
 }
 
-static int gfar_init_bds(struct net_device *ndev)
+static void gfar_init_bds(struct net_device *ndev)
 {
 	struct gfar_private *priv = netdev_priv(ndev);
 	struct gfar_priv_tx_q *tx_queue = NULL;
 	struct gfar_priv_rx_q *rx_queue = NULL;
 	struct txbd8 *txbdp;
-	struct rxbd8 *rxbdp;
 	int i, j;
 
 	for (i = 0; i < priv->num_tx_queues; i++) {
@@ -196,33 +196,10 @@ static int gfar_init_bds(struct net_device *ndev)
 
 	for (i = 0; i < priv->num_rx_queues; i++) {
 		rx_queue = priv->rx_queue[i];
-		rx_queue->cur_rx = rx_queue->rx_bd_base;
-		rx_queue->skb_currx = 0;
-		rxbdp = rx_queue->rx_bd_base;
-
-		for (j = 0; j < rx_queue->rx_ring_size; j++) {
-			struct sk_buff *skb = rx_queue->rx_skbuff[j];
-
-			if (skb) {
-				gfar_init_rxbdp(rx_queue, rxbdp,
-						rxbdp->bufPtr);
-			} else {
-				skb = gfar_alloc_skb(ndev);
-				if (!skb) {
-					netdev_err(ndev, "Can't allocate RX buffers\n");
-					return -ENOMEM;
-				}
-				rx_queue->rx_skbuff[j] = skb;
-
-				gfar_new_rxbdp(rx_queue, rxbdp, skb);
-			}
-
-			rxbdp++;
-		}
-
+		rx_queue->next_to_clean = rx_queue->next_to_alloc = 0;
+		gfar_alloc_rx_buff(rx_queue, GFAR_RXBD_UNUSED(rx_queue));
 	}
 
-	return 0;
 }
 
 static int gfar_alloc_skb_resources(struct net_device *ndev)
@@ -301,8 +278,7 @@ static int gfar_alloc_skb_resources(struct net_device *ndev)
 			rx_queue->rx_skbuff[j] = NULL;
 	}
 
-	if (gfar_init_bds(ndev))
-		goto cleanup;
+	gfar_init_bds(ndev);
 
 	return 0;
 
@@ -1366,10 +1342,7 @@ static int gfar_restore(struct device *dev)
 		return 0;
 	}
 
-	if (gfar_init_bds(ndev)) {
-		free_skb_resources(priv);
-		return -ENOMEM;
-	}
+	gfar_init_bds(ndev);
 
 	init_registers(ndev);
 	gfar_set_mac_address(ndev);
@@ -2612,18 +2585,46 @@ static void gfar_new_rxbdp(struct gfar_priv_rx_q *rx_queue, struct rxbd8 *bdp,
 	gfar_init_rxbdp(rx_queue, bdp, buf);
 }
 
-static struct sk_buff *gfar_alloc_skb(struct net_device *dev)
+/* Best effort Rx buff allocation routine. Updates the next_to_alloc
+ * index of the given ring with the # of completed skb allocations.
+ */
+static void gfar_alloc_rx_buff(struct gfar_priv_rx_q *rx_queue,
+			       int alloc_cnt)
 {
+	struct net_device *dev = rx_queue->dev;
 	struct gfar_private *priv = netdev_priv(dev);
-	struct sk_buff *skb;
+	struct rxbd8 *bdp, *base;
+	unsigned int i;
 
-	skb = netdev_alloc_skb(dev, priv->rx_buffer_size + RXBUF_ALIGNMENT);
-	if (!skb)
-		return NULL;
+	i = rx_queue->next_to_alloc;
+	base = rx_queue->rx_bd_base;
+	bdp = &rx_queue->rx_bd_base[i];
 
-	gfar_align_skb(skb);
+	while (alloc_cnt--) {
+		struct sk_buff *skb;
 
-	return skb;
+		skb = netdev_alloc_skb(dev,
+				       priv->rx_buffer_size + RXBUF_ALIGNMENT);
+		if (unlikely(!skb))
+			break; /* try again with the next alloc request */
+
+		gfar_align_skb(skb);
+
+		rx_queue->rx_skbuff[i] = skb;
+
+		/* Setup the new RxBD */
+		gfar_new_rxbdp(rx_queue, bdp, skb);
+
+		/* Update to the next pointer */
+		bdp = next_bd(bdp, base, rx_queue->rx_ring_size);
+
+		if (unlikely(++i == rx_queue->rx_ring_size))
+			i = 0;
+	}
+
+	rx_queue->next_to_alloc = i;
+
+	return;
 }
 
 static inline void count_errors(unsigned short status, struct net_device *dev)
@@ -2746,24 +2747,26 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
 	struct sk_buff *skb;
 	int pkt_len;
 	int amount_pull;
-	int howmany = 0;
+	unsigned int i;
+	int howmany = 0, cleaned_cnt = 0;
 	struct gfar_private *priv = netdev_priv(dev);
 
+	i = rx_queue->next_to_clean;
 	/* Get the first full descriptor */
-	bdp = rx_queue->cur_rx;
 	base = rx_queue->rx_bd_base;
+	bdp = &rx_queue->rx_bd_base[i];
 
 	amount_pull = priv->uses_rxfcb ? GMAC_FCB_LEN : 0;
 
 	while (!((bdp->status & RXBD_EMPTY) || (--rx_work_limit < 0))) {
-		struct sk_buff *newskb;
-
 		rmb();
 
-		/* Add another skb for the future */
-		newskb = gfar_alloc_skb(dev);
+		skb = rx_queue->rx_skbuff[i];
+		rx_queue->rx_skbuff[i] = NULL;
 
-		skb = rx_queue->rx_skbuff[rx_queue->skb_currx];
+		cleaned_cnt++;
+		if (unlikely(++i == rx_queue->rx_ring_size))
+			i = 0;
 
 		dma_unmap_single(priv->dev, bdp->bufPtr,
 				 priv->rx_buffer_size, DMA_FROM_DEVICE);
@@ -2772,15 +2775,13 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
 			     bdp->length > priv->rx_buffer_size))
 			bdp->status = RXBD_LARGE;
 
-		/* We drop the frame if we failed to allocate a new buffer */
-		if (unlikely(!newskb || !(bdp->status & RXBD_LAST) ||
+		if (unlikely(!(bdp->status & RXBD_LAST) ||
 			     bdp->status & RXBD_ERR)) {
 			count_errors(bdp->status, dev);
 
-			if (unlikely(!newskb))
-				newskb = skb;
-			else if (skb)
-				dev_kfree_skb(skb);
+			/* discard faulty buffer */
+			dev_kfree_skb(skb);
+
 		} else {
 			/* Increment the number of packets */
 			rx_queue->stats.rx_packets++;
@@ -2803,21 +2804,20 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
 
 		}
 
-		rx_queue->rx_skbuff[rx_queue->skb_currx] = newskb;
-
-		/* Setup the new bdp */
-		gfar_new_rxbdp(rx_queue, bdp, newskb);
+		if (unlikely(cleaned_cnt >= GFAR_RX_BUFF_ALLOC)) {
+			gfar_alloc_rx_buff(rx_queue, cleaned_cnt);
+			cleaned_cnt = 0;
+		}
 
 		/* Update to the next pointer */
 		bdp = next_bd(bdp, base, rx_queue->rx_ring_size);
 
-		/* update to point at the next skb */
-		rx_queue->skb_currx = (rx_queue->skb_currx + 1) &
-				      RX_RING_MOD_MASK(rx_queue->rx_ring_size);
 	}
+	rx_queue->next_to_clean = i;
 
-	/* Update the current rxbd pointer to be the next one */
-	rx_queue->cur_rx = bdp;
+	cleaned_cnt = GFAR_RXBD_UNUSED(rx_queue);
+	if (cleaned_cnt)
+		gfar_alloc_rx_buff(rx_queue, cleaned_cnt);
 
 	return howmany;
 }
diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
index 63a28d2..9adc1ce 100644
--- a/drivers/net/ethernet/freescale/gianfar.h
+++ b/drivers/net/ethernet/freescale/gianfar.h
@@ -93,6 +93,9 @@ extern const char gfar_driver_version[];
 #define DEFAULT_TX_RING_SIZE	256
 #define DEFAULT_RX_RING_SIZE	256
 
+/* Rx buffer allocation bundle size */
+#define GFAR_RX_BUFF_ALLOC	16
+
 #define GFAR_RX_MAX_RING_SIZE   256
 #define GFAR_TX_MAX_RING_SIZE   256
 
@@ -964,9 +967,9 @@ struct rx_q_stats {
  *	struct gfar_priv_rx_q - per rx queue structure
  *	@rxlock: per queue rx spin lock
  *	@rx_skbuff: skb pointers
- *	@skb_currx: currently use skb pointer
  *	@rx_bd_base: First rx buffer descriptor
- *	@cur_rx: Next free rx ring entry
+ *	@next_to_alloc: index of the next buffer to be alloc'd
+ *	@next_to_clean: index of the next buffer to be cleaned
  *	@qindex: index of this queue
  *	@dev: back pointer to the dev structure
  *	@rx_ring_size: Rx ring size
@@ -979,11 +982,11 @@ struct gfar_priv_rx_q {
 	struct	sk_buff ** rx_skbuff;
 	dma_addr_t rx_bd_dma_base;
 	struct	rxbd8 *rx_bd_base;
-	struct	rxbd8 *cur_rx;
+	u16 next_to_clean;
+	u16 next_to_alloc;
 	struct	net_device *dev;
 	struct gfar_priv_grp *grp;
 	struct rx_q_stats stats;
-	u16	skb_currx;
 	u16	qindex;
 	unsigned int	rx_ring_size;
 	/* RX Coalescing values */
@@ -991,6 +994,9 @@ struct gfar_priv_rx_q {
 	unsigned long rxic;
 };
 
+#define GFAR_RXBD_UNUSED(Q)	((((Q)->next_to_clean > (Q)->next_to_alloc) ? \
+	0 : (Q)->rx_ring_size) + (Q)->next_to_clean - (Q)->next_to_alloc - 1)
+
 enum gfar_irqinfo_id {
 	GFAR_TX = 0,
 	GFAR_RX = 1,
-- 
1.7.7.4
