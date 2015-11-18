From: Ondrej Zary <linux@rainbow-software.org>
Subject: [PATCH 1/3 v2] dl2k: Handle memory allocation errors in alloc_list
Date: Wed, 18 Nov 2015 22:36:27 +0100
Message-ID: <1447882589-11264-1-git-send-email-linux@rainbow-software.org>
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	David Miller <davem@davemloft.net>,
	Kernel development list <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If memory allocation fails in alloc_list(), free the already allocated
memory and return -ENOMEM. In rio_open(), call alloc_list() first and
abort if it fails. Move HW access (set RFDListPtr) out ot alloc_list().

Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
---
 drivers/net/ethernet/dlink/dl2k.c |  182 ++++++++++++++++++++-----------------
 1 file changed, 97 insertions(+), 85 deletions(-)

diff --git a/drivers/net/ethernet/dlink/dl2k.c b/drivers/net/ethernet/dlink/dl2k.c
index ccca479..ec0eb7f 100644
--- a/drivers/net/ethernet/dlink/dl2k.c
+++ b/drivers/net/ethernet/dlink/dl2k.c
@@ -70,7 +70,6 @@ static const int multicast_filter_limit = 0x40;
 static int rio_open (struct net_device *dev);
 static void rio_timer (unsigned long data);
 static void rio_tx_timeout (struct net_device *dev);
-static void alloc_list (struct net_device *dev);
 static netdev_tx_t start_xmit (struct sk_buff *skb, struct net_device *dev);
 static irqreturn_t rio_interrupt (int irq, void *dev_instance);
 static void rio_free_tx (struct net_device *dev, int irq);
@@ -446,6 +445,92 @@ static void rio_set_led_mode(struct net_device *dev)
 	dw32(ASICCtrl, mode);
 }
 
+static inline dma_addr_t desc_to_dma(struct netdev_desc *desc)
+{
+	return le64_to_cpu(desc->fraginfo) & DMA_BIT_MASK(48);
+}
+
+static void free_list(struct net_device *dev)
+{
+	struct netdev_private *np = netdev_priv(dev);
+	struct sk_buff *skb;
+	int i;
+
+	/* Free all the skbuffs in the queue. */
+	for (i = 0; i < RX_RING_SIZE; i++) {
+		skb = np->rx_skbuff[i];
+		if (skb) {
+			pci_unmap_single(np->pdev, desc_to_dma(&np->rx_ring[i]),
+					 skb->len, PCI_DMA_FROMDEVICE);
+			dev_kfree_skb(skb);
+			np->rx_skbuff[i] = NULL;
+		}
+		np->rx_ring[i].status = 0;
+		np->rx_ring[i].fraginfo = 0;
+	}
+	for (i = 0; i < TX_RING_SIZE; i++) {
+		skb = np->tx_skbuff[i];
+		if (skb) {
+			pci_unmap_single(np->pdev, desc_to_dma(&np->tx_ring[i]),
+					 skb->len, PCI_DMA_TODEVICE);
+			dev_kfree_skb(skb);
+			np->tx_skbuff[i] = NULL;
+		}
+	}
+}
+
+ /* allocate and initialize Tx and Rx descriptors */
+static int alloc_list(struct net_device *dev)
+{
+	struct netdev_private *np = netdev_priv(dev);
+	int i;
+
+	np->cur_rx = np->cur_tx = 0;
+	np->old_rx = np->old_tx = 0;
+	np->rx_buf_sz = (dev->mtu <= 1500 ? PACKET_SIZE : dev->mtu + 32);
+
+	/* Initialize Tx descriptors, TFDListPtr leaves in start_xmit(). */
+	for (i = 0; i < TX_RING_SIZE; i++) {
+		np->tx_skbuff[i] = NULL;
+		np->tx_ring[i].status = cpu_to_le64(TFDDone);
+		np->tx_ring[i].next_desc = cpu_to_le64(np->tx_ring_dma +
+					      ((i + 1) % TX_RING_SIZE) *
+					      sizeof(struct netdev_desc));
+	}
+
+	/* Initialize Rx descriptors */
+	for (i = 0; i < RX_RING_SIZE; i++) {
+		np->rx_ring[i].next_desc = cpu_to_le64(np->rx_ring_dma +
+						((i + 1) % RX_RING_SIZE) *
+						sizeof(struct netdev_desc));
+		np->rx_ring[i].status = 0;
+		np->rx_ring[i].fraginfo = 0;
+		np->rx_skbuff[i] = NULL;
+	}
+
+	/* Allocate the rx buffers */
+	for (i = 0; i < RX_RING_SIZE; i++) {
+		/* Allocated fixed size of skbuff */
+		struct sk_buff *skb;
+
+		skb = netdev_alloc_skb_ip_align(dev, np->rx_buf_sz);
+		np->rx_skbuff[i] = skb;
+		if (!skb) {
+			free_list(dev);
+			return -ENOMEM;
+		}
+
+		/* Rubicon now supports 40 bits of addressing space. */
+		np->rx_ring[i].fraginfo =
+		    cpu_to_le64(pci_map_single(
+				  np->pdev, skb->data, np->rx_buf_sz,
+				  PCI_DMA_FROMDEVICE));
+		np->rx_ring[i].fraginfo |= cpu_to_le64((u64)np->rx_buf_sz << 48);
+	}
+
+	return 0;
+}
+
 static int
 rio_open (struct net_device *dev)
 {
@@ -455,10 +540,16 @@ rio_open (struct net_device *dev)
 	int i;
 	u16 macctrl;
 
-	i = request_irq(irq, rio_interrupt, IRQF_SHARED, dev->name, dev);
+	i = alloc_list(dev);
 	if (i)
 		return i;
 
+	i = request_irq(irq, rio_interrupt, IRQF_SHARED, dev->name, dev);
+	if (i) {
+		free_list(dev);
+		return i;
+	}
+
 	/* Reset all logic functions */
 	dw16(ASICCtrl + 2,
 	     GlobalReset | DMAReset | FIFOReset | NetworkReset | HostReset);
@@ -473,7 +564,9 @@ rio_open (struct net_device *dev)
 	if (np->jumbo != 0)
 		dw16(MaxFrameSize, MAX_JUMBO+14);
 
-	alloc_list (dev);
+	/* Set RFDListPtr */
+	dw32(RFDListPtr0, np->rx_ring_dma);
+	dw32(RFDListPtr1, 0);
 
 	/* Set station address */
 	/* 16 or 32-bit access is required by TC9020 datasheet but 8-bit works
@@ -586,60 +679,6 @@ rio_tx_timeout (struct net_device *dev)
 	dev->trans_start = jiffies; /* prevent tx timeout */
 }
 
- /* allocate and initialize Tx and Rx descriptors */
-static void
-alloc_list (struct net_device *dev)
-{
-	struct netdev_private *np = netdev_priv(dev);
-	void __iomem *ioaddr = np->ioaddr;
-	int i;
-
-	np->cur_rx = np->cur_tx = 0;
-	np->old_rx = np->old_tx = 0;
-	np->rx_buf_sz = (dev->mtu <= 1500 ? PACKET_SIZE : dev->mtu + 32);
-
-	/* Initialize Tx descriptors, TFDListPtr leaves in start_xmit(). */
-	for (i = 0; i < TX_RING_SIZE; i++) {
-		np->tx_skbuff[i] = NULL;
-		np->tx_ring[i].status = cpu_to_le64 (TFDDone);
-		np->tx_ring[i].next_desc = cpu_to_le64 (np->tx_ring_dma +
-					      ((i+1)%TX_RING_SIZE) *
-					      sizeof (struct netdev_desc));
-	}
-
-	/* Initialize Rx descriptors */
-	for (i = 0; i < RX_RING_SIZE; i++) {
-		np->rx_ring[i].next_desc = cpu_to_le64 (np->rx_ring_dma +
-						((i + 1) % RX_RING_SIZE) *
-						sizeof (struct netdev_desc));
-		np->rx_ring[i].status = 0;
-		np->rx_ring[i].fraginfo = 0;
-		np->rx_skbuff[i] = NULL;
-	}
-
-	/* Allocate the rx buffers */
-	for (i = 0; i < RX_RING_SIZE; i++) {
-		/* Allocated fixed size of skbuff */
-		struct sk_buff *skb;
-
-		skb = netdev_alloc_skb_ip_align(dev, np->rx_buf_sz);
-		np->rx_skbuff[i] = skb;
-		if (skb == NULL)
-			break;
-
-		/* Rubicon now supports 40 bits of addressing space. */
-		np->rx_ring[i].fraginfo =
-		    cpu_to_le64 ( pci_map_single (
-			 	  np->pdev, skb->data, np->rx_buf_sz,
-				  PCI_DMA_FROMDEVICE));
-		np->rx_ring[i].fraginfo |= cpu_to_le64((u64)np->rx_buf_sz << 48);
-	}
-
-	/* Set RFDListPtr */
-	dw32(RFDListPtr0, np->rx_ring_dma);
-	dw32(RFDListPtr1, 0);
-}
-
 static netdev_tx_t
 start_xmit (struct sk_buff *skb, struct net_device *dev)
 {
@@ -748,11 +787,6 @@ rio_interrupt (int irq, void *dev_instance)
 	return IRQ_RETVAL(handled);
 }
 
-static inline dma_addr_t desc_to_dma(struct netdev_desc *desc)
-{
-	return le64_to_cpu(desc->fraginfo) & DMA_BIT_MASK(48);
-}
-
 static void
 rio_free_tx (struct net_device *dev, int irq)
 {
@@ -1733,8 +1767,6 @@ rio_close (struct net_device *dev)
 	void __iomem *ioaddr = np->ioaddr;
 
 	struct pci_dev *pdev = np->pdev;
-	struct sk_buff *skb;
-	int i;
 
 	netif_stop_queue (dev);
 
@@ -1747,27 +1779,7 @@ rio_close (struct net_device *dev)
 	free_irq(pdev->irq, dev);
 	del_timer_sync (&np->timer);
 
-	/* Free all the skbuffs in the queue. */
-	for (i = 0; i < RX_RING_SIZE; i++) {
-		skb = np->rx_skbuff[i];
-		if (skb) {
-			pci_unmap_single(pdev, desc_to_dma(&np->rx_ring[i]),
-					 skb->len, PCI_DMA_FROMDEVICE);
-			dev_kfree_skb (skb);
-			np->rx_skbuff[i] = NULL;
-		}
-		np->rx_ring[i].status = 0;
-		np->rx_ring[i].fraginfo = 0;
-	}
-	for (i = 0; i < TX_RING_SIZE; i++) {
-		skb = np->tx_skbuff[i];
-		if (skb) {
-			pci_unmap_single(pdev, desc_to_dma(&np->tx_ring[i]),
-					 skb->len, PCI_DMA_TODEVICE);
-			dev_kfree_skb (skb);
-			np->tx_skbuff[i] = NULL;
-		}
-	}
+	free_list(dev);
 
 	return 0;
 }
-- 
Ondrej Zary
