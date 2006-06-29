From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 5/9] pcnet32: Handle memory allocation failures cleanly when resizing tx/rx rings
Date: Thu, 29 Jun 2006 13:54:38 -0700
Message-ID: <20060629205438.GA22016@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:65205 "EHLO
	e34.co.us.ibm.com") by vger.kernel.org with ESMTP id S932522AbWF2UyX
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 16:54:23 -0400
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e34.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k5TKsMmd015830
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Thu, 29 Jun 2006 16:54:23 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5TKrmEo276772
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 29 Jun 2006 14:53:48 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5TKsMRp010700
	for <netdev@vger.kernel.org>; Thu, 29 Jun 2006 14:54:22 -0600
To: tsbogend@alpha.franken.de, jgarzik@pobox.com,
	netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Fix pcnet32_set_ringparam to handle memory allocation errors without
leaving the adapter in an inoperative state and null pointers waiting to
be dereferenced.

Tested ia32 and ppc64.

Signed-off-by:  Don Fry <brazilnut@us.ibm.com>

--- linux-2.6.17-git13/drivers/net/calloc.pcnet32.c	Wed Jun 28 11:55:52 2006
+++ linux-2.6.17-git13/drivers/net/pcnet32.c	Wed Jun 28 13:13:52 2006
@@ -185,6 +185,23 @@ static int homepna[MAX_UNITS];
 
 #define PCNET32_TOTAL_SIZE	0x20
 
+#define CSR0		0
+#define CSR0_INIT	0x1
+#define CSR0_START	0x2
+#define CSR0_STOP	0x4
+#define CSR0_TXPOLL	0x8
+#define CSR0_INTEN	0x40
+#define CSR0_IDON	0x0100
+#define CSR0_NORMAL	(CSR0_START | CSR0_INTEN)
+#define PCNET32_INIT_LOW	1
+#define PCNET32_INIT_HIGH	2
+#define CSR3		3
+#define CSR4		4
+#define CSR5		5
+#define CSR5_SUSPEND	0x0001
+#define CSR15		15
+#define PCNET32_MC_FILTER	8
+
 /* The PCNET32 Rx and Tx ring descriptors. */
 struct pcnet32_rx_head {
 	u32	base;
@@ -415,6 +432,219 @@ static struct pcnet32_access pcnet32_dwi
 	.reset = pcnet32_dwio_reset
 };
 
+static void pcnet32_netif_stop(struct net_device *dev)
+{
+	dev->trans_start = jiffies;
+	netif_poll_disable(dev);
+	netif_tx_disable(dev);
+}
+
+static void pcnet32_netif_start(struct net_device *dev)
+{
+	netif_wake_queue(dev);
+	netif_poll_enable(dev);
+}
+
+/*
+ * Allocate space for the new sized tx ring.
+ * Free old resources
+ * Save new resources.
+ * Any failure keeps old resources.
+ * Must be called with lp->lock held.
+ */
+static void pcnet32_realloc_tx_ring(struct net_device *dev,
+				    struct pcnet32_private *lp,
+				    unsigned int size)
+{
+	dma_addr_t new_ring_dma_addr;
+	dma_addr_t *new_dma_addr_list;
+	struct pcnet32_tx_head *new_tx_ring;
+	struct sk_buff **new_skb_list;
+
+	pcnet32_purge_tx_ring(dev);
+
+	new_tx_ring = pci_alloc_consistent(lp->pci_dev,
+					   sizeof(struct pcnet32_tx_head) *
+					   (1 << size),
+					   &new_ring_dma_addr);
+	if (new_tx_ring == NULL) {
+		if (netif_msg_drv(lp))
+			printk("\n" KERN_ERR
+			       "%s: Consistent memory allocation failed.\n",
+			       dev->name);
+		return;
+	}
+	memset(new_tx_ring, 0, sizeof(struct pcnet32_tx_head) * (1 << size));
+
+	new_dma_addr_list = kcalloc((1 << size), sizeof(dma_addr_t),
+				GFP_ATOMIC);
+	if (!new_dma_addr_list) {
+		if (netif_msg_drv(lp))
+			printk("\n" KERN_ERR
+			       "%s: Memory allocation failed.\n", dev->name);
+		goto free_new_tx_ring;
+	}
+
+	new_skb_list = kcalloc((1 << size), sizeof(struct sk_buff *),
+				GFP_ATOMIC);
+	if (!new_skb_list) {
+		if (netif_msg_drv(lp))
+			printk("\n" KERN_ERR
+			       "%s: Memory allocation failed.\n", dev->name);
+		goto free_new_lists;
+	}
+
+	kfree(lp->tx_skbuff);
+	kfree(lp->tx_dma_addr);
+	pci_free_consistent(lp->pci_dev,
+			    sizeof(struct pcnet32_tx_head) *
+			    lp->tx_ring_size, lp->tx_ring,
+			    lp->tx_ring_dma_addr);
+
+	lp->tx_ring_size = (1 << size);
+	lp->tx_mod_mask = lp->tx_ring_size - 1;
+	lp->tx_len_bits = (size << 12);
+	lp->tx_ring = new_tx_ring;
+	lp->tx_ring_dma_addr = new_ring_dma_addr;
+	lp->tx_dma_addr = new_dma_addr_list;
+	lp->tx_skbuff = new_skb_list;
+	return;
+
+    free_new_lists:
+	kfree(new_dma_addr_list);
+    free_new_tx_ring:
+	pci_free_consistent(lp->pci_dev,
+			    sizeof(struct pcnet32_tx_head) *
+			    (1 << size),
+			    new_tx_ring,
+			    new_ring_dma_addr);
+	return;
+}
+
+/*
+ * Allocate space for the new sized rx ring.
+ * Re-use old receive buffers.
+ *   alloc extra buffers
+ *   free unneeded buffers
+ *   free unneeded buffers
+ * Save new resources.
+ * Any failure keeps old resources.
+ * Must be called with lp->lock held.
+ */
+static void pcnet32_realloc_rx_ring(struct net_device *dev,
+				    struct pcnet32_private *lp,
+				    unsigned int size)
+{
+	dma_addr_t new_ring_dma_addr;
+	dma_addr_t *new_dma_addr_list;
+	struct pcnet32_rx_head *new_rx_ring;
+	struct sk_buff **new_skb_list;
+	int new, overlap;
+
+	new_rx_ring = pci_alloc_consistent(lp->pci_dev,
+					   sizeof(struct pcnet32_rx_head) *
+					   (1 << size),
+					   &new_ring_dma_addr);
+	if (new_rx_ring == NULL) {
+		if (netif_msg_drv(lp))
+			printk("\n" KERN_ERR
+			       "%s: Consistent memory allocation failed.\n",
+			       dev->name);
+		return;
+	}
+	memset(new_rx_ring, 0, sizeof(struct pcnet32_rx_head) * (1 << size));
+
+	new_dma_addr_list = kcalloc((1 << size), sizeof(dma_addr_t),
+				GFP_ATOMIC);
+	if (!new_dma_addr_list) {
+		if (netif_msg_drv(lp))
+			printk("\n" KERN_ERR
+			       "%s: Memory allocation failed.\n", dev->name);
+		goto free_new_rx_ring;
+	}
+
+	new_skb_list = kcalloc((1 << size), sizeof(struct sk_buff *),
+				GFP_ATOMIC);
+	if (!new_skb_list) {
+		if (netif_msg_drv(lp))
+			printk("\n" KERN_ERR
+			       "%s: Memory allocation failed.\n", dev->name);
+		goto free_new_lists;
+	}
+
+	/* first copy the current receive buffers */
+	overlap = min(size, lp->rx_ring_size);
+	for (new = 0; new < overlap; new++) {
+		new_rx_ring[new] = lp->rx_ring[new];
+		new_dma_addr_list[new] = lp->rx_dma_addr[new];
+		new_skb_list[new] = lp->rx_skbuff[new];
+	}
+	/* now allocate any new buffers needed */
+	for (; new < size; new++ ) {
+		struct sk_buff *rx_skbuff;
+		new_skb_list[new] = dev_alloc_skb(PKT_BUF_SZ);
+		if (!(rx_skbuff = new_skb_list[new])) {
+			/* keep the original lists and buffers */
+			if (netif_msg_drv(lp))
+				printk(KERN_ERR
+				       "%s: pcnet32_realloc_rx_ring dev_alloc_skb failed.\n",
+				       dev->name);
+			goto free_all_new;
+		}
+		skb_reserve(rx_skbuff, 2);
+
+		new_dma_addr_list[new] =
+			    pci_map_single(lp->pci_dev, rx_skbuff->data,
+					   PKT_BUF_SZ - 2, PCI_DMA_FROMDEVICE);
+		new_rx_ring[new].base = (u32) le32_to_cpu(new_dma_addr_list[new]);
+		new_rx_ring[new].buf_length = le16_to_cpu(2 - PKT_BUF_SZ);
+		new_rx_ring[new].status = le16_to_cpu(0x8000);
+	}
+	/* and free any unneeded buffers */
+	for (; new < lp->rx_ring_size; new++) {
+		if (lp->rx_skbuff[new]) {
+			pci_unmap_single(lp->pci_dev, lp->rx_dma_addr[new],
+					 PKT_BUF_SZ - 2, PCI_DMA_FROMDEVICE);
+			dev_kfree_skb(lp->rx_skbuff[new]);
+		}
+	}
+
+	kfree(lp->rx_skbuff);
+	kfree(lp->rx_dma_addr);
+	pci_free_consistent(lp->pci_dev,
+			    sizeof(struct pcnet32_rx_head) *
+			    lp->rx_ring_size, lp->rx_ring,
+			    lp->rx_ring_dma_addr);
+
+	lp->rx_ring_size = (1 << size);
+	lp->rx_mod_mask = lp->rx_ring_size - 1;
+	lp->rx_len_bits = (size << 4);
+	lp->rx_ring = new_rx_ring;
+	lp->rx_ring_dma_addr = new_ring_dma_addr;
+	lp->rx_dma_addr = new_dma_addr_list;
+	lp->rx_skbuff = new_skb_list;
+	return;
+
+    free_all_new:
+	for (; --new >= lp->rx_ring_size; ) {
+		if (new_skb_list[new]) {
+			pci_unmap_single(lp->pci_dev, new_dma_addr_list[new],
+					 PKT_BUF_SZ - 2, PCI_DMA_FROMDEVICE);
+			dev_kfree_skb(new_skb_list[new]);
+		}
+	}
+	kfree(new_skb_list);
+    free_new_lists:
+	kfree(new_dma_addr_list);
+    free_new_rx_ring:
+	pci_free_consistent(lp->pci_dev,
+			    sizeof(struct pcnet32_rx_head) *
+			    (1 << size),
+			    new_rx_ring,
+			    new_ring_dma_addr);
+	return;
+}
+
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void pcnet32_poll_controller(struct net_device *dev)
 {
@@ -526,56 +756,53 @@ static int pcnet32_set_ringparam(struct 
 {
 	struct pcnet32_private *lp = dev->priv;
 	unsigned long flags;
+	unsigned int size;
+	ulong ioaddr = dev->base_addr;
 	int i;
 
 	if (ering->rx_mini_pending || ering->rx_jumbo_pending)
 		return -EINVAL;
 
 	if (netif_running(dev))
-		pcnet32_close(dev);
+		pcnet32_netif_stop(dev);
 
 	spin_lock_irqsave(&lp->lock, flags);
-	pcnet32_free_ring(dev);
-	lp->tx_ring_size =
-	    min(ering->tx_pending, (unsigned int)TX_MAX_RING_SIZE);
-	lp->rx_ring_size =
-	    min(ering->rx_pending, (unsigned int)RX_MAX_RING_SIZE);
+	lp->a.write_csr(ioaddr, CSR0, CSR0_STOP);	/* stop the chip */
+
+	size = min(ering->tx_pending, (unsigned int)TX_MAX_RING_SIZE);
 
 	/* set the minimum ring size to 4, to allow the loopback test to work
 	 * unchanged.
 	 */
 	for (i = 2; i <= PCNET32_LOG_MAX_TX_BUFFERS; i++) {
-		if (lp->tx_ring_size <= (1 << i))
+		if (size <= (1 << i))
 			break;
 	}
-	lp->tx_ring_size = (1 << i);
-	lp->tx_mod_mask = lp->tx_ring_size - 1;
-	lp->tx_len_bits = (i << 12);
-
+	if ((1 << i) != lp->tx_ring_size)
+		pcnet32_realloc_tx_ring(dev, lp, i);
+	
+	size = min(ering->rx_pending, (unsigned int)RX_MAX_RING_SIZE);
 	for (i = 2; i <= PCNET32_LOG_MAX_RX_BUFFERS; i++) {
-		if (lp->rx_ring_size <= (1 << i))
+		if (size <= (1 << i))
 			break;
 	}
-	lp->rx_ring_size = (1 << i);
-	lp->rx_mod_mask = lp->rx_ring_size - 1;
-	lp->rx_len_bits = (i << 4);
-
-	if (pcnet32_alloc_ring(dev, dev->name)) {
-		pcnet32_free_ring(dev);
-		spin_unlock_irqrestore(&lp->lock, flags);
-		return -ENOMEM;
+	if ((1 << i) != lp->rx_ring_size)
+		pcnet32_realloc_rx_ring(dev, lp, i);
+	
+	dev->weight = lp->rx_ring_size / 2;
+
+	if (netif_running(dev)) {
+		pcnet32_netif_start(dev);
+		pcnet32_restart(dev, CSR0_NORMAL);
 	}
 
 	spin_unlock_irqrestore(&lp->lock, flags);
 
-	if (pcnet32_debug & NETIF_MSG_DRV)
-		printk(KERN_INFO PFX
+	if (netif_msg_drv(lp))
+		printk(KERN_INFO
 		       "%s: Ring Param Settings: RX: %d, TX: %d\n", dev->name,
 		       lp->rx_ring_size, lp->tx_ring_size);
 
-	if (netif_running(dev))
-		pcnet32_open(dev);
-
 	return 0;
 }
 
-- 
Don Fry
brazilnut@us.ibm.com
