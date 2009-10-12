From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH 2/8] gianfar: Simplify skb resources freeing code
Date: Mon, 12 Oct 2009 20:00:30 +0400
Message-ID: <20091012160030.GB2463@oksana.dev.rtsoft.ru>
References: <20091012160000.GA32406@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Scott Wood <scottwood@freescale.com>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>
To: David Miller <davem@davemloft.net>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
Content-Disposition: inline
In-Reply-To: <20091012160000.GA32406@oksana.dev.rtsoft.ru>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

Remove dma_free_coherent() from stop_gfar() and gfar_start() calls,
place it into free_skb_resources(). That makes SKB resources management
more understandable, plus free_skb_resources() will be used as a cleanup
routine for gfar_alloc_skb_resources() that will be implemented soon.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/gianfar.c |   53 +++++++++++++++++++++++-------------------------
 1 files changed, 25 insertions(+), 28 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 8c7322f..b7881e6 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -806,7 +806,6 @@ void gfar_halt(struct net_device *dev)
 void stop_gfar(struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
-	struct gfar __iomem *regs = priv->regs;
 	unsigned long flags;
 
 	phy_stop(priv->phydev);
@@ -830,18 +829,13 @@ void stop_gfar(struct net_device *dev)
 	}
 
 	free_skb_resources(priv);
-
-	dma_free_coherent(&priv->ofdev->dev,
-			sizeof(struct txbd8)*priv->tx_ring_size
-			+ sizeof(struct rxbd8)*priv->rx_ring_size,
-			priv->tx_bd_base,
-			gfar_read(&regs->tbase0));
 }
 
 /* If there are any tx skbs or rx skbs still around, free them.
  * Then free tx_skbuff and rx_skbuff */
 static void free_skb_resources(struct gfar_private *priv)
 {
+	struct device *dev = &priv->ofdev->dev;
 	struct rxbd8 *rxbdp;
 	struct txbd8 *txbdp;
 	int i, j;
@@ -849,6 +843,9 @@ static void free_skb_resources(struct gfar_private *priv)
 	/* Go through all the buffer descriptors and free their data buffers */
 	txbdp = priv->tx_bd_base;
 
+	if (!priv->tx_skbuff)
+		goto skip_tx_skbuff;
+
 	for (i = 0; i < priv->tx_ring_size; i++) {
 		if (!priv->tx_skbuff[i])
 			continue;
@@ -867,30 +864,33 @@ static void free_skb_resources(struct gfar_private *priv)
 	}
 
 	kfree(priv->tx_skbuff);
+skip_tx_skbuff:
 
 	rxbdp = priv->rx_bd_base;
 
-	/* rx_skbuff is not guaranteed to be allocated, so only
-	 * free it and its contents if it is allocated */
-	if(priv->rx_skbuff != NULL) {
-		for (i = 0; i < priv->rx_ring_size; i++) {
-			if (priv->rx_skbuff[i]) {
-				dma_unmap_single(&priv->ofdev->dev, rxbdp->bufPtr,
-						priv->rx_buffer_size,
-						DMA_FROM_DEVICE);
-
-				dev_kfree_skb_any(priv->rx_skbuff[i]);
-				priv->rx_skbuff[i] = NULL;
-			}
-
-			rxbdp->lstatus = 0;
-			rxbdp->bufPtr = 0;
+	if (!priv->rx_skbuff)
+		goto skip_rx_skbuff;
 
-			rxbdp++;
+	for (i = 0; i < priv->rx_ring_size; i++) {
+		if (priv->rx_skbuff[i]) {
+			dma_unmap_single(&priv->ofdev->dev, rxbdp->bufPtr,
+					 priv->rx_buffer_size,
+					DMA_FROM_DEVICE);
+			dev_kfree_skb_any(priv->rx_skbuff[i]);
+			priv->rx_skbuff[i] = NULL;
 		}
 
-		kfree(priv->rx_skbuff);
+		rxbdp->lstatus = 0;
+		rxbdp->bufPtr = 0;
+		rxbdp++;
 	}
+
+	kfree(priv->rx_skbuff);
+skip_rx_skbuff:
+
+	dma_free_coherent(dev, sizeof(*txbdp) * priv->tx_ring_size +
+			       sizeof(*rxbdp) * priv->rx_ring_size,
+			  priv->tx_bd_base, gfar_read(&priv->regs->tbase0));
 }
 
 void gfar_start(struct net_device *dev)
@@ -1148,11 +1148,8 @@ tx_irq_fail:
 err_irq_fail:
 err_rxalloc_fail:
 rx_skb_fail:
-	free_skb_resources(priv);
 tx_skb_fail:
-	dma_free_coherent(dev, sizeof(*txbdp) * priv->tx_ring_size +
-			       sizeof(*rxbdp) * priv->rx_ring_size,
-			  priv->tx_bd_base, gfar_read(&regs->tbase0));
+	free_skb_resources(priv);
 	return err;
 }
 
-- 
1.6.3.3
