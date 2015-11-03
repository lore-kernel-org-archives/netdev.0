From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] sh_eth: merge sh_eth_free_dma_buffer() into sh_eth_ring_free()
Date: Wed, 04 Nov 2015 00:55:13 +0300
Message-ID: <6672379.kyQ5eFYq8y@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

While the ring allocation is done by a single function, sh_eth_ring_init(),
the ring deallocation was split into two functions (almost always called
one after the other) for no good reason. Merge  sh_eth_free_dma_buffer()
into sh_eth_ring_free() which allows us  to save space not only on the
direct calls  of the former function but also on the sh_eth_ring_init()'s
simplified error path...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against DaveM's 'net-next.git' repo plus the patch just posted.

 drivers/net/ethernet/renesas/sh_eth.c |   60 ++++++++++++----------------------
 1 file changed, 22 insertions(+), 38 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -1098,7 +1098,7 @@ static struct mdiobb_ops bb_ops = {
 static void sh_eth_ring_free(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
-	int i;
+	int ringsize, i;
 
 	/* Free Rx skb ringbuffer */
 	if (mdp->rx_skbuff) {
@@ -1115,6 +1115,20 @@ static void sh_eth_ring_free(struct net_
 	}
 	kfree(mdp->tx_skbuff);
 	mdp->tx_skbuff = NULL;
+
+	if (mdp->rx_ring) {
+		ringsize = sizeof(struct sh_eth_rxdesc) * mdp->num_rx_ring;
+		dma_free_coherent(NULL, ringsize, mdp->rx_ring,
+				  mdp->rx_desc_dma);
+		mdp->rx_ring = NULL;
+	}
+
+	if (mdp->tx_ring) {
+		ringsize = sizeof(struct sh_eth_txdesc) * mdp->num_tx_ring;
+		dma_free_coherent(NULL, ringsize, mdp->tx_ring,
+				  mdp->tx_desc_dma);
+		mdp->tx_ring = NULL;
+	}
 }
 
 /* format skb and descriptor buffer */
@@ -1220,14 +1234,14 @@ static int sh_eth_ring_init(struct net_d
 	mdp->tx_skbuff = kcalloc(mdp->num_tx_ring, sizeof(*mdp->tx_skbuff),
 				 GFP_KERNEL);
 	if (!mdp->tx_skbuff)
-		goto skb_ring_free;
+		goto ring_free;
 
 	/* Allocate all Rx descriptors. */
 	rx_ringsize = sizeof(struct sh_eth_rxdesc) * mdp->num_rx_ring;
 	mdp->rx_ring = dma_alloc_coherent(NULL, rx_ringsize, &mdp->rx_desc_dma,
 					  GFP_KERNEL);
 	if (!mdp->rx_ring)
-		goto skb_ring_free;
+		goto ring_free;
 
 	mdp->dirty_rx = 0;
 
@@ -1236,41 +1250,16 @@ static int sh_eth_ring_init(struct net_d
 	mdp->tx_ring = dma_alloc_coherent(NULL, tx_ringsize, &mdp->tx_desc_dma,
 					  GFP_KERNEL);
 	if (!mdp->tx_ring)
-		goto desc_ring_free;
+		goto ring_free;
 	return 0;
 
-desc_ring_free:
-	/* free DMA buffer */
-	dma_free_coherent(NULL, rx_ringsize, mdp->rx_ring, mdp->rx_desc_dma);
-
-skb_ring_free:
-	/* Free Rx and Tx skb ring buffer */
+ring_free:
+	/* Free Rx and Tx skb ring buffer and DMA buffer */
 	sh_eth_ring_free(ndev);
-	mdp->tx_ring = NULL;
-	mdp->rx_ring = NULL;
 
 	return -ENOMEM;
 }
 
-static void sh_eth_free_dma_buffer(struct sh_eth_private *mdp)
-{
-	int ringsize;
-
-	if (mdp->rx_ring) {
-		ringsize = sizeof(struct sh_eth_rxdesc) * mdp->num_rx_ring;
-		dma_free_coherent(NULL, ringsize, mdp->rx_ring,
-				  mdp->rx_desc_dma);
-		mdp->rx_ring = NULL;
-	}
-
-	if (mdp->tx_ring) {
-		ringsize = sizeof(struct sh_eth_txdesc) * mdp->num_tx_ring;
-		dma_free_coherent(NULL, ringsize, mdp->tx_ring,
-				  mdp->tx_desc_dma);
-		mdp->tx_ring = NULL;
-	}
-}
-
 static int sh_eth_dev_init(struct net_device *ndev, bool start)
 {
 	int ret = 0;
@@ -2231,10 +2220,8 @@ static int sh_eth_set_ringparam(struct n
 
 		sh_eth_dev_exit(ndev);
 
-		/* Free all the skbuffs in the Rx queue. */
+		/* Free all the skbuffs in the Rx queue and the DMA buffers. */
 		sh_eth_ring_free(ndev);
-		/* Free DMA buffer */
-		sh_eth_free_dma_buffer(mdp);
 	}
 
 	/* Set new parameters */
@@ -2479,12 +2466,9 @@ static int sh_eth_close(struct net_devic
 
 	free_irq(ndev->irq, ndev);
 
-	/* Free all the skbuffs in the Rx queue. */
+	/* Free all the skbuffs in the Rx queue and the DMA buffer. */
 	sh_eth_ring_free(ndev);
 
-	/* free DMA buffer */
-	sh_eth_free_dma_buffer(mdp);
-
 	pm_runtime_put_sync(&mdp->pdev->dev);
 
 	mdp->is_opened = 0;

