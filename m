From: Florian Fainelli <florian.fainelli@telecomint.eu>
Subject: [PATCH 06/10] r6040: completely rework the RX path
Date: Sun, 13 Jul 2008 14:33:36 +0200
Message-ID: <200807131433.37413.florian.fainelli@telecomint.eu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.int-evry.fr ([157.159.10.71]:46647 "EHLO
	smtp4.int-evry.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753841AbYGMMeH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jul 2008 08:34:07 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch completely reworks the RX path in order to be
more accurate about what is going on with the MAC.
We no longer read the error from the MLSR register instead read
the descriptor status register which reflects, the error per descriptor.
We now allocate skbs on the fly in r6040_rx, and we handle allocation
failure instead of simply dropping the packet. Remove the
rx_free_desc counter of r6040_private structure since we
allocate skbs in the RX path.

r6040_rx_buf_alloc is now removed and becomes unuseless.

Signed-Off-By: Joerg Albert <jal2@gmx.de>
Signed-off-by: Florian Fainelli <florian.fainelli@telecomint.eu>
---
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 5eb057d..9061ec1 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -175,7 +175,7 @@ struct r6040_private {
 	struct r6040_descriptor *tx_ring;
 	dma_addr_t rx_ring_dma;
 	dma_addr_t tx_ring_dma;
-	u16	tx_free_desc, rx_free_desc, phy_addr, phy_mode;
+	u16	tx_free_desc, phy_addr, phy_mode;
 	u16	mcr0, mcr1;
 	u16	switch_sig;
 	struct net_device *dev;
@@ -291,27 +291,6 @@ static void r6040_init_ring_desc(struct r6040_descriptor *desc_ring,
 	desc->vndescp = desc_ring;
 }
 
-/* Allocate skb buffer for rx descriptor */
-static void r6040_rx_buf_alloc(struct r6040_private *lp, struct net_device *dev)
-{
-	struct r6040_descriptor *descptr;
-
-	descptr = lp->rx_insert_ptr;
-	while (lp->rx_free_desc < RX_DCNT) {
-		descptr->skb_ptr = netdev_alloc_skb(dev, MAX_BUF_SIZE);
-
-		if (!descptr->skb_ptr)
-			break;
-		descptr->buf = cpu_to_le32(pci_map_single(lp->pdev,
-			descptr->skb_ptr->data,
-			MAX_BUF_SIZE, PCI_DMA_FROMDEVICE));
-		descptr->status = 0x8000;
-		descptr = descptr->vndescp;
-		lp->rx_free_desc++;
-	}
-	lp->rx_insert_ptr = descptr;
-}
-
 static void r6040_init_txbufs(struct net_device *dev)
 {
 	struct r6040_private *lp = netdev_priv(dev);
@@ -556,71 +535,72 @@ static int r6040_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 static int r6040_rx(struct net_device *dev, int limit)
 {
 	struct r6040_private *priv = netdev_priv(dev);
-	int count;
-	void __iomem *ioaddr = priv->base;
+	struct r6040_descriptor *descptr = priv->rx_remove_ptr;
+	struct sk_buff *skb_ptr, *new_skb;
+	int count = 0;
 	u16 err;
 
-	for (count = 0; count < limit; ++count) {
-		struct r6040_descriptor *descptr = priv->rx_remove_ptr;
-		struct sk_buff *skb_ptr;
-
-		descptr = priv->rx_remove_ptr;
-
-		/* Check for errors */
-		err = ioread16(ioaddr + MLSR);
-		if (err & 0x0400)
-			dev->stats.rx_errors++;
-		/* RX FIFO over-run */
-		if (err & 0x8000)
-			dev->stats.rx_fifo_errors++;
-		/* RX descriptor unavailable */
-		if (err & 0x0080)
-			dev->stats.rx_frame_errors++;
-		/* Received packet with length over buffer lenght */
-		if (err & 0x0020)
-			dev->stats.rx_over_errors++;
-		/* Received packet with too long or short */
-		if (err & (0x0010 | 0x0008))
-			dev->stats.rx_length_errors++;
-		/* Received packet with CRC errors */
-		if (err & 0x0004) {
-			spin_lock(&priv->lock);
-			dev->stats.rx_crc_errors++;
-			spin_unlock(&priv->lock);
-		}
-
-		while (priv->rx_free_desc) {
-			/* No RX packet */
-			if (descptr->status & 0x8000)
-				break;
-			skb_ptr = descptr->skb_ptr;
-			if (!skb_ptr) {
-				printk(KERN_ERR "%s: Inconsistent RX"
-					"descriptor chain\n",
-					dev->name);
-				break;
+	/* Limit not reached and the descriptor belongs to the CPU */
+	while (count < limit && !(descptr->status & 0x8000)) {
+		/* Read the descriptor status */
+		err = descptr->status;
+		/* Global error status set */
+		if (err & 0x0800) {
+			/* RX dribble */
+			if (err & 0x0400)
+				dev->stats.rx_frame_errors++;
+			/* Buffer lenght exceeded */
+			if (err & 0x0200)
+				dev->stats.rx_length_errors++;
+			/* Packet too long */
+			if (err & 0x0100)
+				dev->stats.rx_length_errors++;
+			/* Packet < 64 bytes */
+			if (err & 0x0080)
+				dev->stats.rx_length_errors++;
+			/* CRC error */
+			if (err & 0x0040) {
+				spin_lock(&priv->lock);
+				dev->stats.rx_crc_errors++;
+				spin_unlock(&priv->lock);
 			}
-			descptr->skb_ptr = NULL;
-			skb_ptr->dev = priv->dev;
-			/* Do not count the CRC */
-			skb_put(skb_ptr, descptr->len - 4);
-			pci_unmap_single(priv->pdev, le32_to_cpu(descptr->buf),
-				MAX_BUF_SIZE, PCI_DMA_FROMDEVICE);
-			skb_ptr->protocol = eth_type_trans(skb_ptr, priv->dev);
-			/* Send to upper layer */
-			netif_receive_skb(skb_ptr);
-			dev->last_rx = jiffies;
-			dev->stats.rx_packets++;
-			dev->stats.rx_bytes += descptr->len;
-			/* To next descriptor */
-			descptr = descptr->vndescp;
-			priv->rx_free_desc--;
+			goto next_descr;
+		}
+		
+		/* Packet successfully received */
+		new_skb = netdev_alloc_skb(dev, MAX_BUF_SIZE);
+		if (!new_skb) {
+			dev->stats.rx_dropped++;
+			goto next_descr;
 		}
-		priv->rx_remove_ptr = descptr;
+		skb_ptr = descptr->skb_ptr;
+		skb_ptr->dev = priv->dev;
+		
+		/* Do not count the CRC */
+		skb_put(skb_ptr, descptr->len - 4);
+		pci_unmap_single(priv->pdev, le32_to_cpu(descptr->buf),
+					MAX_BUF_SIZE, PCI_DMA_FROMDEVICE);
+		skb_ptr->protocol = eth_type_trans(skb_ptr, priv->dev);
+		
+		/* Send to upper layer */
+		netif_receive_skb(skb_ptr);
+		dev->last_rx = jiffies;
+		dev->stats.rx_packets++;
+		dev->stats.rx_bytes += descptr->len - 4;
+
+		/* put new skb into descriptor */
+		descptr->skb_ptr = new_skb;
+		descptr->buf = cpu_to_le32(pci_map_single(priv->pdev,
+						descptr->skb_ptr->data,
+					MAX_BUF_SIZE, PCI_DMA_FROMDEVICE));
+
+next_descr:
+		/* put the descriptor back to the MAC */
+		descptr->status = 0x8000;
+		descptr = descptr->vndescp;
+		count++;
 	}
-	/* Allocate new RX buffer */
-	if (priv->rx_free_desc < RX_DCNT)
-		r6040_rx_buf_alloc(priv, priv->dev);
+	priv->rx_remove_ptr = descptr;
 
 	return count;
 }
