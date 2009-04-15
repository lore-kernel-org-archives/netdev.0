From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: [PATCH 11/12] FEC Buffer rework
Date: Wed, 15 Apr 2009 13:32:24 +0200
Message-ID: <1239795145-27558-12-git-send-email-s.hauer@pengutronix.de>
References: <1239795145-27558-1-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-2-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-3-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-4-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-5-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-6-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-7-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-8-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-9-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-10-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-11-git-send-email-s.hauer@pengutronix.de>
Cc: Greg Ungerer <gerg@snapgear.com>,
	Sascha Hauer <s.hauer@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:37860 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759119AbZDOLdN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 07:33:13 -0400
In-Reply-To: <1239795145-27558-11-git-send-email-s.hauer@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allocate buffers in fec_open and free them again in fec_close. This makes
it possible to use this driver as a module.

Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
---
 drivers/net/fec.c |  139 +++++++++++++++++++++++++++++++++-------------------
 1 files changed, 88 insertions(+), 51 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index f4afbe9..0e1d268 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -172,6 +172,7 @@ struct fec_enet_private {
 	/* The saved address of a sent-in-place packet/buffer, for skfree(). */
 	unsigned char *tx_bounce[TX_RING_SIZE];
 	struct	sk_buff* tx_skbuff[TX_RING_SIZE];
+	struct	sk_buff* rx_skbuff[RX_RING_SIZE];
 	ushort	skb_cur;
 	ushort	skb_dirty;
 
@@ -335,8 +336,8 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Push the data cache so the CPM does not get stale memory
 	 * data.
 	 */
-	dma_sync_single(NULL, bdp->cbd_bufaddr,
-			bdp->cbd_datlen, DMA_TO_DEVICE);
+	bdp->cbd_bufaddr = dma_map_single(&dev->dev, skb->data,
+			FEC_ENET_TX_FRSIZE, DMA_TO_DEVICE);
 
 	/* Send it on its way.  Tell FEC it's ready, interrupt when done,
 	 * it's the last BD of the frame, and to put the CRC on the end.
@@ -429,7 +430,11 @@ fec_enet_tx(struct net_device *dev)
 	bdp = fep->dirty_tx;
 
 	while (((status = bdp->cbd_sc) & BD_ENET_TX_READY) == 0) {
-		if (bdp == fep->cur_tx && fep->tx_full == 0) break;
+		if (bdp == fep->cur_tx && fep->tx_full == 0)
+			break;
+
+		dma_unmap_single(&dev->dev, bdp->cbd_bufaddr, FEC_ENET_TX_FRSIZE, DMA_TO_DEVICE);
+		bdp->cbd_bufaddr = 0;
 
 		skb = fep->tx_skbuff[fep->skb_dirty];
 		/* Check for errors. */
@@ -553,8 +558,8 @@ fec_enet_rx(struct net_device *dev)
 		dev->stats.rx_bytes += pkt_len;
 		data = (__u8*)__va(bdp->cbd_bufaddr);
 
-		dma_sync_single(NULL, (unsigned long)__pa(data),
-			pkt_len - 4, DMA_FROM_DEVICE);
+	        dma_unmap_single(NULL, bdp->cbd_bufaddr, bdp->cbd_datlen,
+        			DMA_FROM_DEVICE);
 
 		/* This does 16 byte alignment, exactly what we need.
 		 * The packet length includes FCS, but we don't want to
@@ -574,6 +579,9 @@ fec_enet_rx(struct net_device *dev)
 			skb->protocol = eth_type_trans(skb, dev);
 			netif_rx(skb);
 		}
+
+        	bdp->cbd_bufaddr = dma_map_single(NULL, data, bdp->cbd_datlen,
+			DMA_FROM_DEVICE);
 rx_processing_done:
 		/* Clear the status flags for this buffer */
 		status &= ~BD_ENET_RX_STATS;
@@ -1399,15 +1407,86 @@ mii_link_interrupt(int irq, void * dev_id)
 }
 #endif
 
+static void fec_enet_free_buffers(struct net_device *dev)
+{
+	struct fec_enet_private *fep = netdev_priv(dev);
+	int i;
+	struct sk_buff *skb;
+	struct bufdesc	*bdp;
+
+	bdp = fep->rx_bd_base;
+	for (i = 0; i < RX_RING_SIZE; i++) {
+		skb = fep->rx_skbuff[i];
+
+		if (bdp->cbd_bufaddr)
+			dma_unmap_single(&dev->dev, bdp->cbd_bufaddr,
+					FEC_ENET_RX_FRSIZE, DMA_FROM_DEVICE);
+		if (skb)
+			dev_kfree_skb(skb);
+		bdp++;
+	}
+
+	bdp = fep->tx_bd_base;
+	for (i = 0; i < TX_RING_SIZE; i++)
+		kfree(fep->tx_bounce[i]);
+}
+
+static int fec_enet_alloc_buffers(struct net_device *dev)
+{
+	struct fec_enet_private *fep = netdev_priv(dev);
+	int i;
+	struct sk_buff *skb;
+	struct bufdesc	*bdp;
+
+	bdp = fep->rx_bd_base;
+	for (i = 0; i < RX_RING_SIZE; i++) {
+		skb = dev_alloc_skb(FEC_ENET_RX_FRSIZE);
+		if (!skb) {
+			fec_enet_free_buffers(dev);
+			return -ENOMEM;
+		}
+		fep->rx_skbuff[i] = skb;
+
+		bdp->cbd_bufaddr = dma_map_single(&dev->dev, skb->data,
+				FEC_ENET_RX_FRSIZE, DMA_FROM_DEVICE);
+		bdp->cbd_sc = BD_ENET_RX_EMPTY;
+		bdp++;
+	}
+
+	/* Set the last buffer to wrap. */
+	bdp--;
+	bdp->cbd_sc |= BD_SC_WRAP;
+
+	bdp = fep->tx_bd_base;
+	for (i = 0; i < TX_RING_SIZE; i++) {
+		fep->tx_bounce[i] = kmalloc(FEC_ENET_TX_FRSIZE, GFP_KERNEL);
+
+		bdp->cbd_sc = 0;
+		bdp->cbd_bufaddr = 0;
+		bdp++;
+	}
+
+	/* Set the last buffer to wrap. */
+	bdp--;
+	bdp->cbd_sc |= BD_SC_WRAP;
+
+	return 0;
+}
+
 static int
 fec_enet_open(struct net_device *dev)
 {
 	struct fec_enet_private *fep = netdev_priv(dev);
+	int ret;
 
 	/* I should reset the ring buffers here, but I don't yet know
 	 * a simple way to do that.
 	 */
 
+	ret = fec_enet_alloc_buffers(dev);
+	if (ret)
+		return ret;
+
 	fep->sequence_done = 0;
 	fep->link = 0;
 
@@ -1454,6 +1533,8 @@ fec_enet_close(struct net_device *dev)
 	netif_stop_queue(dev);
 	fec_stop(dev);
 
+        fec_enet_free_buffers(dev);
+
 	return 0;
 }
 
@@ -1576,9 +1657,8 @@ static const struct net_device_ops fec_netdev_ops = {
 int __init fec_enet_init(struct net_device *dev, int index)
 {
 	struct fec_enet_private *fep = netdev_priv(dev);
-	unsigned long	mem_addr;
-	struct bufdesc *bdp, *cbd_base;
-	int 		i, j;
+	struct bufdesc *cbd_base;
+	int i;
 
 	/* Allocate memory for buffer descriptors. */
 	cbd_base = dma_alloc_coherent(NULL, PAGE_SIZE, &fep->bd_dma,
@@ -1616,49 +1696,6 @@ int __init fec_enet_init(struct net_device *dev, int index)
 	fep->rx_bd_base = cbd_base;
 	fep->tx_bd_base = cbd_base + RX_RING_SIZE;
 
-	/* Initialize the receive buffer descriptors. */
-	bdp = fep->rx_bd_base;
-	for (i=0; i<FEC_ENET_RX_PAGES; i++) {
-
-		/* Allocate a page */
-		mem_addr = __get_free_page(GFP_KERNEL);
-		/* XXX: missing check for allocation failure */
-
-		/* Initialize the BD for every fragment in the page */
-		for (j=0; j<FEC_ENET_RX_FRPPG; j++) {
-			bdp->cbd_sc = BD_ENET_RX_EMPTY;
-			bdp->cbd_bufaddr = __pa(mem_addr);
-			mem_addr += FEC_ENET_RX_FRSIZE;
-			bdp++;
-		}
-	}
-
-	/* Set the last buffer to wrap */
-	bdp--;
-	bdp->cbd_sc |= BD_SC_WRAP;
-
-	/* ...and the same for transmit */
-	bdp = fep->tx_bd_base;
-	for (i=0, j=FEC_ENET_TX_FRPPG; i<TX_RING_SIZE; i++) {
-		if (j >= FEC_ENET_TX_FRPPG) {
-			mem_addr = __get_free_page(GFP_KERNEL);
-			j = 1;
-		} else {
-			mem_addr += FEC_ENET_TX_FRSIZE;
-			j++;
-		}
-		fep->tx_bounce[i] = (unsigned char *) mem_addr;
-
-		/* Initialize the BD for every fragment in the page */
-		bdp->cbd_sc = 0;
-		bdp->cbd_bufaddr = 0;
-		bdp++;
-	}
-
-	/* Set the last buffer to wrap */
-	bdp--;
-	bdp->cbd_sc |= BD_SC_WRAP;
-
 #ifdef HAVE_mii_link_interrupt
 	fec_request_mii_intr(dev);
 #endif
-- 
1.6.2.1

