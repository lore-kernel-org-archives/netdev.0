From: Kumar Gala <galak@kernel.crashing.org>
Subject: [PATCH] gianfar: pass the proper dev to DMA ops
Date: Tue, 17 Mar 2009 11:16:07 -0500
Message-ID: <1237306567-32219-1-git-send-email-galak@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Becky Bruce <becky.bruce@freescale.com>, netdev@vger.kernel.org,
	Andy Fleming <afleming@freescale.com>, linuxppc-dev@ozlabs.org
To: davem@davemloft.net
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

We need to be passing the of_platform device struct into the DMA ops as
its the one that has the archdata setup to know which low-level DMA ops we
should be using (not the net_device one).  This isn't an issue until we
expect the archdata to be setup correctly.

Signed-off-by: Kumar Gala <galak@kernel.crashing.org>
---

Dave,

This is for net-next.  We are working on having per device dma ops for .30 and
expect the struct device archdata to be setup properly but in .29 we still
default to a direct DMA ops on ppc32 so this "bug" will never show up.

- k

 drivers/net/gianfar.c |   34 ++++++++++++++++++----------------
 drivers/net/gianfar.h |    3 ++-
 2 files changed, 20 insertions(+), 17 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index bed30ef..8659833 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -365,8 +365,10 @@ static int gfar_probe(struct of_device *ofdev,
 		return -ENOMEM;
 
 	priv = netdev_priv(dev);
-	priv->dev = dev;
+	priv->ndev = dev;
+	priv->ofdev = ofdev;
 	priv->node = ofdev->node;
+	SET_NETDEV_DEV(dev, &ofdev->dev);
 
 	err = gfar_of_init(dev);
 
@@ -538,7 +540,7 @@ static int gfar_remove(struct of_device *ofdev)
 	dev_set_drvdata(&ofdev->dev, NULL);
 
 	iounmap(priv->regs);
-	free_netdev(priv->dev);
+	free_netdev(priv->ndev);
 
 	return 0;
 }
@@ -870,7 +872,7 @@ void stop_gfar(struct net_device *dev)
 
 	free_skb_resources(priv);
 
-	dma_free_coherent(&dev->dev,
+	dma_free_coherent(&priv->ofdev->dev,
 			sizeof(struct txbd8)*priv->tx_ring_size
 			+ sizeof(struct rxbd8)*priv->rx_ring_size,
 			priv->tx_bd_base,
@@ -892,12 +894,12 @@ static void free_skb_resources(struct gfar_private *priv)
 		if (!priv->tx_skbuff[i])
 			continue;
 
-		dma_unmap_single(&priv->dev->dev, txbdp->bufPtr,
+		dma_unmap_single(&priv->ofdev->dev, txbdp->bufPtr,
 				txbdp->length, DMA_TO_DEVICE);
 		txbdp->lstatus = 0;
 		for (j = 0; j < skb_shinfo(priv->tx_skbuff[i])->nr_frags; j++) {
 			txbdp++;
-			dma_unmap_page(&priv->dev->dev, txbdp->bufPtr,
+			dma_unmap_page(&priv->ofdev->dev, txbdp->bufPtr,
 					txbdp->length, DMA_TO_DEVICE);
 		}
 		txbdp++;
@@ -914,7 +916,7 @@ static void free_skb_resources(struct gfar_private *priv)
 	if(priv->rx_skbuff != NULL) {
 		for (i = 0; i < priv->rx_ring_size; i++) {
 			if (priv->rx_skbuff[i]) {
-				dma_unmap_single(&priv->dev->dev, rxbdp->bufPtr,
+				dma_unmap_single(&priv->ofdev->dev, rxbdp->bufPtr,
 						priv->rx_buffer_size,
 						DMA_FROM_DEVICE);
 
@@ -980,7 +982,7 @@ int startup_gfar(struct net_device *dev)
 	gfar_write(&regs->imask, IMASK_INIT_CLEAR);
 
 	/* Allocate memory for the buffer descriptors */
-	vaddr = (unsigned long) dma_alloc_coherent(&dev->dev,
+	vaddr = (unsigned long) dma_alloc_coherent(&priv->ofdev->dev,
 			sizeof (struct txbd8) * priv->tx_ring_size +
 			sizeof (struct rxbd8) * priv->rx_ring_size,
 			&addr, GFP_KERNEL);
@@ -1192,7 +1194,7 @@ err_rxalloc_fail:
 rx_skb_fail:
 	free_skb_resources(priv);
 tx_skb_fail:
-	dma_free_coherent(&dev->dev,
+	dma_free_coherent(&priv->ofdev->dev,
 			sizeof(struct txbd8)*priv->tx_ring_size
 			+ sizeof(struct rxbd8)*priv->rx_ring_size,
 			priv->tx_bd_base,
@@ -1345,7 +1347,7 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			if (i == nr_frags - 1)
 				lstatus |= BD_LFLAG(TXBD_LAST | TXBD_INTERRUPT);
 
-			bufaddr = dma_map_page(&dev->dev,
+			bufaddr = dma_map_page(&priv->ofdev->dev,
 					skb_shinfo(skb)->frags[i].page,
 					skb_shinfo(skb)->frags[i].page_offset,
 					length,
@@ -1377,7 +1379,7 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* setup the TxBD length and buffer pointer for the first BD */
 	priv->tx_skbuff[priv->skb_curtx] = skb;
-	txbdp_start->bufPtr = dma_map_single(&dev->dev, skb->data,
+	txbdp_start->bufPtr = dma_map_single(&priv->ofdev->dev, skb->data,
 			skb_headlen(skb), DMA_TO_DEVICE);
 
 	lstatus |= BD_LFLAG(TXBD_CRC | TXBD_READY) | skb_headlen(skb);
@@ -1563,7 +1565,7 @@ static void gfar_reset_task(struct work_struct *work)
 {
 	struct gfar_private *priv = container_of(work, struct gfar_private,
 			reset_task);
-	struct net_device *dev = priv->dev;
+	struct net_device *dev = priv->ndev;
 
 	if (dev->flags & IFF_UP) {
 		stop_gfar(dev);
@@ -1610,7 +1612,7 @@ static int gfar_clean_tx_ring(struct net_device *dev)
 				(lstatus & BD_LENGTH_MASK))
 			break;
 
-		dma_unmap_single(&dev->dev,
+		dma_unmap_single(&priv->ofdev->dev,
 				bdp->bufPtr,
 				bdp->length,
 				DMA_TO_DEVICE);
@@ -1619,7 +1621,7 @@ static int gfar_clean_tx_ring(struct net_device *dev)
 		bdp = next_txbd(bdp, base, tx_ring_size);
 
 		for (i = 0; i < frags; i++) {
-			dma_unmap_page(&dev->dev,
+			dma_unmap_page(&priv->ofdev->dev,
 					bdp->bufPtr,
 					bdp->length,
 					DMA_TO_DEVICE);
@@ -1696,7 +1698,7 @@ static void gfar_new_rxbdp(struct net_device *dev, struct rxbd8 *bdp,
 	struct gfar_private *priv = netdev_priv(dev);
 	u32 lstatus;
 
-	bdp->bufPtr = dma_map_single(&dev->dev, skb->data,
+	bdp->bufPtr = dma_map_single(&priv->ofdev->dev, skb->data,
 			priv->rx_buffer_size, DMA_FROM_DEVICE);
 
 	lstatus = BD_LFLAG(RXBD_EMPTY | RXBD_INTERRUPT);
@@ -1856,7 +1858,7 @@ int gfar_clean_rx_ring(struct net_device *dev, int rx_work_limit)
 
 		skb = priv->rx_skbuff[priv->skb_currx];
 
-		dma_unmap_single(&priv->dev->dev, bdp->bufPtr,
+		dma_unmap_single(&priv->ofdev->dev, bdp->bufPtr,
 				priv->rx_buffer_size, DMA_FROM_DEVICE);
 
 		/* We drop the frame if we failed to allocate a new buffer */
@@ -1916,7 +1918,7 @@ int gfar_clean_rx_ring(struct net_device *dev, int rx_work_limit)
 static int gfar_poll(struct napi_struct *napi, int budget)
 {
 	struct gfar_private *priv = container_of(napi, struct gfar_private, napi);
-	struct net_device *dev = priv->dev;
+	struct net_device *dev = priv->ndev;
 	int tx_cleaned = 0;
 	int rx_cleaned = 0;
 	unsigned long flags;
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index 54332b0..dd499d7 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -738,7 +738,8 @@ struct gfar_private {
 	spinlock_t rxlock;
 
 	struct device_node *node;
-	struct net_device *dev;
+	struct net_device *ndev;
+	struct of_device *ofdev;
 	struct napi_struct napi;
 
 	/* skb array and index */
-- 
1.5.6.6
