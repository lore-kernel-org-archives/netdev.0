From: Don Fry <brazilnut@us.ibm.com>
Subject: [RFT] pcnet32 NAPI changes
Date: Fri, 16 Jun 2006 12:11:54 -0700
Message-ID: <20060616191154.GA6227@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:31423 "EHLO e2.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1751448AbWFPTLy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2006 15:11:54 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k5GJBqEl020216
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 16 Jun 2006 15:11:52 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5GJBq6b283410
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 16 Jun 2006 15:11:52 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5GJBqH6028489
	for <netdev@vger.kernel.org>; Fri, 16 Jun 2006 15:11:52 -0400
To: lsorense@csclub.uwaterloo.ca, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch is a collection of changes to pcnet32 which does the
following: 

- Fix section mismatch warning.
- fix set_ringparam to correctly handle memory allocation failures
- fix off-by-one in get_ringparam.
- cleanup at end of loopback_test when not up.
- Add NAPI to driver, fixing set_ringparam and loopback_test to work
  correctly with poll.
- for multicast, do not reset the chip unless cannot enter suspend mode
  to avoid race with poll.

The set_ringparam code is larger than I would prefer, but it will not
leave null pointers around for the code to stumble over when memory
allocation fails.  If anyone has a better idea, please let me know.

Some complexity could be avoided by allocating memory for the maximum
number of tx and rx buffers at probe time.  Requiring 14k for the tx
ring and arrays, and another 14k for rx; instead of about 10k total for
the default sizes.

It is NAPI only, unlike Len Sorensen's version which allows for compile
time selection.  Some drivers are NAPI only, others have compile
options.  Which is preferred?

I have tested these changes with a 79C971, 973, 976, and 978 on a ppc64
machine, and 970A, 972, 973, 975, and 976 on an x86 machine.

I have not tested these changes with VMware or Xen.



--- linux-2.6.17-rc6/drivers/net/orig.pcnet32.c	2006-06-15 11:49:39.000000000 -0700
+++ linux-2.6.17-rc6/drivers/net/pcnet32.c	2006-06-16 11:30:45.000000000 -0700
@@ -22,8 +22,8 @@
  *************************************************************************/
 
 #define DRV_NAME	"pcnet32"
-#define DRV_VERSION	"1.32"
-#define DRV_RELDATE	"18.Mar.2006"
+#define DRV_VERSION	"1.33-NAPI"
+#define DRV_RELDATE	"16.Jun.2006"
 #define PFX		DRV_NAME ": "
 
 static const char *const version =
@@ -277,13 +277,12 @@ struct pcnet32_private {
 	u32			phymask;
 };
 
-static void pcnet32_probe_vlbus(void);
 static int pcnet32_probe_pci(struct pci_dev *, const struct pci_device_id *);
 static int pcnet32_probe1(unsigned long, int, struct pci_dev *);
 static int pcnet32_open(struct net_device *);
 static int pcnet32_init_ring(struct net_device *);
 static int pcnet32_start_xmit(struct sk_buff *, struct net_device *);
-static int pcnet32_rx(struct net_device *);
+static int pcnet32_poll(struct net_device *dev, int *budget);
 static void pcnet32_tx_timeout(struct net_device *dev);
 static irqreturn_t pcnet32_interrupt(int, void *, struct pt_regs *);
 static int pcnet32_close(struct net_device *);
@@ -425,6 +424,215 @@ static struct pcnet32_access pcnet32_dwi
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
+		if (pcnet32_debug & NETIF_MSG_DRV)
+			printk("\n" KERN_ERR PFX
+			       "%s: Consistent memory allocation failed.\n",
+			       dev->name);
+		return;
+	}
+	memset(new_tx_ring, 0, sizeof(struct pcnet32_tx_head) * (1 << size));
+
+	new_dma_addr_list = kcalloc(sizeof(dma_addr_t), (1 << size), GFP_ATOMIC);
+	if (!new_dma_addr_list) {
+		if (pcnet32_debug & NETIF_MSG_DRV)
+			printk("\n" KERN_ERR PFX
+			       "%s: Memory allocation failed.\n", dev->name);
+		goto free_new_tx_ring;
+	}
+
+	new_skb_list = kcalloc(sizeof(struct sk_buff *), (1 << size), GFP_ATOMIC);
+	if (!new_skb_list) {
+		if (pcnet32_debug & NETIF_MSG_DRV)
+			printk("\n" KERN_ERR PFX
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
+		if (pcnet32_debug & NETIF_MSG_DRV)
+			printk("\n" KERN_ERR PFX
+			       "%s: Consistent memory allocation failed.\n",
+			       dev->name);
+		return;
+	}
+	memset(new_rx_ring, 0, sizeof(struct pcnet32_rx_head) * (1 << size));
+
+	new_dma_addr_list = kcalloc(sizeof(dma_addr_t), (1 << size), GFP_ATOMIC);
+	if (!new_dma_addr_list) {
+		if (pcnet32_debug & NETIF_MSG_DRV)
+			printk("\n" KERN_ERR PFX
+			       "%s: Memory allocation failed.\n", dev->name);
+		goto free_new_rx_ring;
+	}
+
+	new_skb_list = kcalloc(sizeof(struct sk_buff *), (1 << size), GFP_ATOMIC);
+	if (!new_skb_list) {
+		if (pcnet32_debug & NETIF_MSG_DRV)
+			printk("\n" KERN_ERR PFX
+			       "%s: Memory allocation failed.\n", dev->name);
+		goto free_new_lists;
+	}
+
+	/* first copy the current receive buffers */
+	overlap = min(size, lp->rx_ring_size);
+	for (new=0; new<overlap; new++) {
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
@@ -525,10 +733,10 @@ static void pcnet32_get_ringparam(struct
 {
 	struct pcnet32_private *lp = dev->priv;
 
-	ering->tx_max_pending = TX_MAX_RING_SIZE - 1;
-	ering->tx_pending = lp->tx_ring_size - 1;
-	ering->rx_max_pending = RX_MAX_RING_SIZE - 1;
-	ering->rx_pending = lp->rx_ring_size - 1;
+	ering->tx_max_pending = TX_MAX_RING_SIZE;
+	ering->tx_pending = lp->tx_ring_size;
+	ering->rx_max_pending = RX_MAX_RING_SIZE;
+	ering->rx_pending = lp->rx_ring_size;
 }
 
 static int pcnet32_set_ringparam(struct net_device *dev,
@@ -536,44 +744,44 @@ static int pcnet32_set_ringparam(struct 
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
+	lp->a.write_csr(ioaddr, 0, 0x0004);	/* stop the chip */
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
+	if ((1 << i) != lp->rx_ring_size)
+		pcnet32_realloc_rx_ring(dev, lp, i);
+	
+	dev->weight = lp->rx_ring_size / 2;
 
-	if (pcnet32_alloc_ring(dev, dev->name)) {
-		pcnet32_free_ring(dev);
-		spin_unlock_irqrestore(&lp->lock, flags);
-		return -ENOMEM;
+	if (netif_running(dev)) {
+		pcnet32_netif_start(dev);
+		pcnet32_restart(dev, 0x0042);
 	}
 
 	spin_unlock_irqrestore(&lp->lock, flags);
@@ -583,9 +791,6 @@ static int pcnet32_set_ringparam(struct 
 		       "%s: Ring Param Settings: RX: %d, TX: %d\n", dev->name,
 		       lp->rx_ring_size, lp->tx_ring_size);
 
-	if (netif_running(dev))
-		pcnet32_open(dev);
-
 	return 0;
 }
 
@@ -643,21 +848,20 @@ static int pcnet32_loopback_test(struct 
 	rc = 1;			/* default to fail */
 
 	if (netif_running(dev))
-		pcnet32_close(dev);
+		pcnet32_netif_stop(dev);
 
 	spin_lock_irqsave(&lp->lock, flags);
+	lp->a.write_csr(ioaddr, 0, 0x0004);	/* stop the chip */
+
+	numbuffs = min(numbuffs, (int)min(lp->rx_ring_size, lp->tx_ring_size));
 
 	/* Reset the PCNET32 */
 	lp->a.reset(ioaddr);
+	lp->a.write_csr(ioaddr, 4, 0x0915);
 
 	/* switch pcnet32 to 32bit mode */
 	lp->a.write_bcr(ioaddr, 20, 2);
 
-	lp->init_block.mode =
-	    le16_to_cpu((lp->options & PCNET32_PORT_PORTSEL) << 7);
-	lp->init_block.filter[0] = 0;
-	lp->init_block.filter[1] = 0;
-
 	/* purge & init rings but don't actually restart */
 	pcnet32_restart(dev, 0x0000);
 
@@ -704,10 +908,10 @@ static int pcnet32_loopback_test(struct 
 	}
 
 	x = a->read_bcr(ioaddr, 32);	/* set internal loopback in BSR32 */
-	x = x | 0x0002;
-	a->write_bcr(ioaddr, 32, x);
+	a->write_bcr(ioaddr, 32, x | 0x0002);
 
-	lp->a.write_csr(ioaddr, 15, 0x0044);	/* set int loopback in CSR15 */
+	x = a->read_csr(ioaddr, 15);	/* set int loopback in CSR15 */
+	lp->a.write_csr(ioaddr, 15, x | 0x0044);
 
 	teststatus = le16_to_cpu(0x8000);
 	lp->a.write_csr(ioaddr, 0, 0x0002);	/* Set STRT bit */
@@ -770,21 +974,26 @@ static int pcnet32_loopback_test(struct 
 
       clean_up:
 	pcnet32_purge_tx_ring(dev);
+	for (x = 0; x < numbuffs; x++) {
+		lp->rx_ring[x].buf_length = le16_to_cpu(2 - PKT_BUF_SZ);
+		wmb();
+		lp->rx_ring[x].status = le16_to_cpu(0x8000);
+	}
 	x = a->read_csr(ioaddr, 15) & 0xFFFF;
 	a->write_csr(ioaddr, 15, (x & ~0x0044));	/* reset bits 6 and 2 */
 
 	x = a->read_bcr(ioaddr, 32);	/* reset internal loopback */
-	x = x & ~0x0002;
-	a->write_bcr(ioaddr, 32, x);
-
-	spin_unlock_irqrestore(&lp->lock, flags);
+	a->write_bcr(ioaddr, 32, (x & ~0x0002));
 
 	if (netif_running(dev)) {
-		pcnet32_open(dev);
+		pcnet32_netif_start(dev);
+		pcnet32_restart(dev, 0x0042);
 	} else {
 		lp->a.write_bcr(ioaddr, 20, 4);	/* return to 16bit mode */
 	}
 
+	spin_unlock_irqrestore(&lp->lock, flags);
+
 	return (rc);
 }				/* end pcnet32_loopback_test  */
 
@@ -855,6 +1064,39 @@ static int pcnet32_get_regs_len(struct n
 	return ((PCNET32_NUM_REGS + j) * sizeof(u16));
 }
 
+/*
+ * lp->lock must be held.
+ */
+static int pcnet32_suspend(struct net_device *dev, unsigned long *flags)
+{
+	int csr5;
+	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_access *a = &lp->a;
+	ulong ioaddr = dev->base_addr;
+	int ticks;
+
+	/* set SUSPEND (SPND) - CSR5 bit 0 */
+	csr5 = a->read_csr(ioaddr, 5);
+	a->write_csr(ioaddr, 5, csr5 | 0x0001);
+
+	/* poll waiting for bit to be set */
+	ticks = 0;
+	while (!(a->read_csr(ioaddr, 5) & 0x0001)) {
+		spin_unlock_irqrestore(&lp->lock, *flags);
+		mdelay(1);
+		spin_lock_irqsave(&lp->lock, *flags);
+		ticks++;
+		if (ticks > 200) {
+			if (netif_msg_hw(lp))
+				printk(KERN_DEBUG
+				       "%s: Error getting into suspend!\n",
+				       dev->name);
+			return 0;
+		}
+	}
+	return 1;
+}
+
 static void pcnet32_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 			     void *ptr)
 {
@@ -863,31 +1105,17 @@ static void pcnet32_get_regs(struct net_
 	struct pcnet32_private *lp = dev->priv;
 	struct pcnet32_access *a = &lp->a;
 	ulong ioaddr = dev->base_addr;
-	int ticks;
 	unsigned long flags;
 
 	spin_lock_irqsave(&lp->lock, flags);
 
 	csr0 = a->read_csr(ioaddr, 0);
 	if (!(csr0 & 0x0004)) {	/* If not stopped */
-		/* set SUSPEND (SPND) - CSR5 bit 0 */
-		a->write_csr(ioaddr, 5, 0x0001);
-
-		/* poll waiting for bit to be set */
-		ticks = 0;
-		while (!(a->read_csr(ioaddr, 5) & 0x0001)) {
-			spin_unlock_irqrestore(&lp->lock, flags);
-			mdelay(1);
-			spin_lock_irqsave(&lp->lock, flags);
-			ticks++;
-			if (ticks > 200) {
-				if (netif_msg_hw(lp))
-					printk(KERN_DEBUG
-					       "%s: Error getting into suspend!\n",
-					       dev->name);
-				break;
-			}
-		}
+		if (!pcnet32_suspend(dev, &flags))
+			if (netif_msg_hw(lp))
+				printk(KERN_DEBUG
+				       "%s: Error getting into suspend!\n",
+				       dev->name);
 	}
 
 	/* read address PROM */
@@ -926,8 +1154,11 @@ static void pcnet32_get_regs(struct net_
 	}
 
 	if (!(csr0 & 0x0004)) {	/* If not stopped */
+		int csr5;
+
 		/* clear SUSPEND (SPND) - CSR5 bit 0 */
-		a->write_csr(ioaddr, 5, 0x0000);
+		csr5 = a->read_csr(ioaddr, 5);
+		a->write_csr(ioaddr, 5, csr5 & (~0x0001));
 	}
 
 	spin_unlock_irqrestore(&lp->lock, flags);
@@ -958,7 +1189,7 @@ static struct ethtool_ops pcnet32_ethtoo
 /* only probes for non-PCI devices, the rest are handled by
  * pci_register_driver via pcnet32_probe_pci */
 
-static void __devinit pcnet32_probe_vlbus(void)
+static void __devinit pcnet32_probe_vlbus(unsigned int *pcnet32_portlist)
 {
 	unsigned int *port, ioaddr;
 
@@ -1396,6 +1627,8 @@ pcnet32_probe1(unsigned long ioaddr, int
 	dev->ethtool_ops = &pcnet32_ethtool_ops;
 	dev->tx_timeout = pcnet32_tx_timeout;
 	dev->watchdog_timeo = (5 * HZ);
+	dev->poll = pcnet32_poll;
+	dev->weight = lp->rx_ring_size / 2;
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = pcnet32_poll_controller;
@@ -2004,6 +2237,279 @@ static int pcnet32_start_xmit(struct sk_
 	return 0;
 }
 
+static int pcnet32_rx_entry(struct net_device *dev,
+			    struct pcnet32_private *lp,
+			    struct pcnet32_rx_head *rxp,
+			    int entry)
+{
+	int status = (short)le16_to_cpu(rxp->status) >> 8;
+	int rx_in_place = 0;
+	struct sk_buff *skb;
+	short pkt_len;
+
+	if (status != 0x03) {	/* There was an error. */
+		/*
+		 * There is a tricky error noted by John Murphy,
+		 * <murf@perftech.com> to Russ Nelson: Even with full-sized
+		 * buffers it's possible for a jabber packet to use two
+		 * buffers, with only the last correctly noting the error.
+		 */
+		if (status & 0x01)	/* Only count a general error at the */
+			lp->stats.rx_errors++;	/* end of a packet. */
+		if (status & 0x20)
+			lp->stats.rx_frame_errors++;
+		if (status & 0x10)
+			lp->stats.rx_over_errors++;
+		if (status & 0x08)
+			lp->stats.rx_crc_errors++;
+		if (status & 0x04)
+			lp->stats.rx_fifo_errors++;
+		return 1;
+	}
+
+	pkt_len = (le32_to_cpu(rxp->msg_length) & 0xfff) - 4;
+
+	/* Discard oversize frames. */
+	if (unlikely(pkt_len > PKT_BUF_SZ - 2)) {
+		if (netif_msg_drv(lp))
+			printk(KERN_ERR "%s: Impossible packet size %d!\n",
+			       dev->name, pkt_len);
+		lp->stats.rx_errors++;
+		return 1;
+	}
+	if (pkt_len < 60) {
+		if (netif_msg_rx_err(lp))
+			printk(KERN_ERR "%s: Runt packet!\n", dev->name);
+		lp->stats.rx_errors++;
+		return 1;
+	}
+
+	if (pkt_len > rx_copybreak) {
+		struct sk_buff *newskb;
+
+		if ((newskb = dev_alloc_skb(PKT_BUF_SZ))) {
+			skb_reserve(newskb, 2);
+			skb = lp->rx_skbuff[entry];
+			pci_unmap_single(lp->pci_dev,
+					 lp->rx_dma_addr[entry],
+					 PKT_BUF_SZ - 2,
+					 PCI_DMA_FROMDEVICE);
+			skb_put(skb, pkt_len);
+			lp->rx_skbuff[entry] = newskb;
+			newskb->dev = dev;
+			lp->rx_dma_addr[entry] =
+			    pci_map_single(lp->pci_dev,
+					   newskb->data,
+					   PKT_BUF_SZ - 2,
+					   PCI_DMA_FROMDEVICE);
+			rxp->base = le32_to_cpu(lp->rx_dma_addr[entry]);
+			rx_in_place = 1;
+		} else
+			skb = NULL;
+	} else {
+		skb = dev_alloc_skb(pkt_len + 2);
+	}
+
+	if (skb == NULL) {
+		if (netif_msg_drv(lp))
+			printk(KERN_ERR
+			       "%s: Memory squeeze, dropping packet.\n",
+			       dev->name);
+		lp->stats.rx_dropped++;
+		return 1;
+	}
+	skb->dev = dev;
+	if (!rx_in_place) {
+		skb_reserve(skb, 2);	/* 16 byte align */
+		skb_put(skb, pkt_len);	/* Make room */
+		pci_dma_sync_single_for_cpu(lp->pci_dev,
+					    lp->rx_dma_addr[entry],
+					    PKT_BUF_SZ - 2,
+					    PCI_DMA_FROMDEVICE);
+		eth_copy_and_sum(skb,
+				 (unsigned char *)(lp->rx_skbuff[entry]->data),
+				 pkt_len, 0);
+		pci_dma_sync_single_for_device(lp->pci_dev,
+					       lp->rx_dma_addr[entry],
+					       PKT_BUF_SZ - 2,
+					       PCI_DMA_FROMDEVICE);
+	}
+	lp->stats.rx_bytes += skb->len;
+	lp->stats.rx_packets++;
+	skb->protocol = eth_type_trans(skb, dev);
+	netif_receive_skb(skb);
+	dev->last_rx = jiffies;
+	return 1;
+}
+
+static int pcnet32_rx(struct net_device *dev, int quota)
+{
+	struct pcnet32_private *lp = dev->priv;
+	int entry = lp->cur_rx & lp->rx_mod_mask;
+	struct pcnet32_rx_head *rxp = &lp->rx_ring[entry];
+	int npackets = 0;
+
+	/* If we own the next entry, it's a new packet. Send it up. */
+	while (quota > npackets && (short)le16_to_cpu(rxp->status) >= 0) {
+		npackets += pcnet32_rx_entry(dev, lp, rxp, entry);
+		/*
+		 * The docs say that the buffer length isn't touched, but Andrew
+		 * Boyd of QNX reports that some revs of the 79C965 clear it.
+		 */
+		rxp->buf_length = le16_to_cpu(2 - PKT_BUF_SZ);
+		wmb();	/* Make sure owner changes after others are visible */
+		rxp->status = le16_to_cpu(0x8000);
+		entry = (++lp->cur_rx) & lp->rx_mod_mask;
+		rxp = &lp->rx_ring[entry];
+	}
+
+	return npackets;
+}
+
+static int pcnet32_tx(struct net_device *dev)
+{
+	struct pcnet32_private *lp = dev->priv;
+	unsigned int dirty_tx = lp->dirty_tx;
+	int delta;
+	int must_restart = 0;
+
+	while (dirty_tx != lp->cur_tx) {
+		int entry = dirty_tx & lp->tx_mod_mask;
+		int status = (short)le16_to_cpu(lp->tx_ring[entry].status);
+
+		if (status < 0)
+			break;	/* It still hasn't been Txed */
+
+		lp->tx_ring[entry].base = 0;
+
+		if (status & 0x4000) {
+			/* There was an major error, log it. */
+			int err_status =
+			    le32_to_cpu(lp->tx_ring[entry].
+					misc);
+			lp->stats.tx_errors++;
+			if (netif_msg_tx_err(lp))
+				printk(KERN_ERR
+				       "%s: Tx error status=%04x err_status=%08x\n",
+				       dev->name, status,
+				       err_status);
+			if (err_status & 0x04000000)
+				lp->stats.tx_aborted_errors++;
+			if (err_status & 0x08000000)
+				lp->stats.tx_carrier_errors++;
+			if (err_status & 0x10000000)
+				lp->stats.tx_window_errors++;
+#ifndef DO_DXSUFLO
+			if (err_status & 0x40000000) {
+				lp->stats.tx_fifo_errors++;
+				/* Ackk!  On FIFO errors the Tx unit is turned off! */
+				/* Remove this verbosity later! */
+				if (netif_msg_tx_err(lp))
+					printk(KERN_ERR
+					       "%s: Tx FIFO error!\n",
+						dev->name);
+				must_restart = 1;
+			}
+#else
+			if (err_status & 0x40000000) {
+				lp->stats.tx_fifo_errors++;
+				if (!lp->dxsuflo) {	/* If controller doesn't recover ... */
+					/* Ackk!  On FIFO errors the Tx unit is turned off! */
+					/* Remove this verbosity later! */
+					if (netif_msg_tx_err(lp))
+						printk(KERN_ERR
+						       "%s: Tx FIFO error!\n",
+						       dev->name);
+					must_restart = 1;
+				}
+			}
+#endif
+		} else {
+			if (status & 0x1800)
+				lp->stats.collisions++;
+			lp->stats.tx_packets++;
+		}
+
+		/* We must free the original skb */
+		if (lp->tx_skbuff[entry]) {
+			pci_unmap_single(lp->pci_dev,
+					 lp->tx_dma_addr[entry],
+					 lp->tx_skbuff[entry]->
+					 len, PCI_DMA_TODEVICE);
+			dev_kfree_skb_any(lp->tx_skbuff[entry]);
+			lp->tx_skbuff[entry] = NULL;
+			lp->tx_dma_addr[entry] = 0;
+		}
+		dirty_tx++;
+	}
+
+	delta = (lp->cur_tx - dirty_tx) & (lp->tx_mod_mask + lp->tx_ring_size);
+	if (delta > lp->tx_ring_size) {
+		if (netif_msg_drv(lp))
+			printk(KERN_ERR
+			       "%s: out-of-sync dirty pointer, %d vs. %d, full=%d.\n",
+			       dev->name, dirty_tx, lp->cur_tx,
+			       lp->tx_full);
+		dirty_tx += lp->tx_ring_size;
+		delta -= lp->tx_ring_size;
+	}
+
+	if (lp->tx_full &&
+	    netif_queue_stopped(dev) &&
+	    delta < lp->tx_ring_size - 2) {
+		/* The ring is no longer full, clear tbusy. */
+		lp->tx_full = 0;
+		netif_wake_queue(dev);
+	}
+	lp->dirty_tx = dirty_tx;
+
+	return must_restart;
+}
+
+static int pcnet32_poll(struct net_device *dev, int *budget)
+{
+	struct pcnet32_private *lp = dev->priv;
+	int quota = min(dev->quota, *budget);
+	unsigned long ioaddr = dev->base_addr;
+	u16 val;
+	unsigned long flags;
+
+	quota = pcnet32_rx(dev, quota);
+
+	spin_lock_irqsave(&lp->lock, flags);
+	if (pcnet32_tx(dev)) {
+		/* reset the chip to clear the error condition, then restart */
+		lp->a.reset(ioaddr);
+		lp->a.write_csr(ioaddr, 4, 0x0915);
+		pcnet32_restart(dev, 0x0002);
+		netif_wake_queue(dev);
+	}
+	spin_unlock_irqrestore(&lp->lock, flags);
+
+	*budget -= quota;
+	dev->quota -= quota;
+
+	if (dev->quota == 0) {
+		return 1;
+	}
+
+	netif_rx_complete(dev);
+
+	spin_lock_irqsave(&lp->lock, flags);
+
+	/* clear interrupt masks */
+	val = lp->a.read_csr(ioaddr, 3);
+	val &= 0x00ff;
+	lp->a.write_csr(ioaddr, 3, val);
+
+	/* Set interrupt enable. */
+	lp->a.write_csr(ioaddr, 0, 0x0040);
+
+	spin_unlock_irqrestore(&lp->lock, flags);
+
+	return 0;
+}
+
 /* The PCNET32 interrupt handler. */
 static irqreturn_t
 pcnet32_interrupt(int irq, void *dev_id, struct pt_regs *regs)
@@ -2011,9 +2517,8 @@ pcnet32_interrupt(int irq, void *dev_id,
 	struct net_device *dev = dev_id;
 	struct pcnet32_private *lp;
 	unsigned long ioaddr;
-	u16 csr0, rap;
-	int boguscnt = max_interrupt_work;
-	int must_restart;
+	u16 csr0;
+	irqreturn_t rc = IRQ_HANDLED;
 
 	if (!dev) {
 		if (pcnet32_debug & NETIF_MSG_INTR)
@@ -2027,124 +2532,27 @@ pcnet32_interrupt(int irq, void *dev_id,
 
 	spin_lock(&lp->lock);
 
-	rap = lp->a.read_rap(ioaddr);
-	while ((csr0 = lp->a.read_csr(ioaddr, 0)) & 0x8f00 && --boguscnt >= 0) {
-		if (csr0 == 0xffff) {
-			break;	/* PCMCIA remove happened */
-		}
+	csr0 = lp->a.read_csr(ioaddr, 0);
+	if (csr0 == 0xffff) {
+		rc = IRQ_NONE;
+	} else if (csr0 & 0x8f00) {
 		/* Acknowledge all of the current interrupt sources ASAP. */
 		lp->a.write_csr(ioaddr, 0, csr0 & ~0x004f);
 
-		must_restart = 0;
-
 		if (netif_msg_intr(lp))
 			printk(KERN_DEBUG
 			       "%s: interrupt  csr0=%#2.2x new csr=%#2.2x.\n",
 			       dev->name, csr0, lp->a.read_csr(ioaddr, 0));
 
-		if (csr0 & 0x0400)	/* Rx interrupt */
-			pcnet32_rx(dev);
-
-		if (csr0 & 0x0200) {	/* Tx-done interrupt */
-			unsigned int dirty_tx = lp->dirty_tx;
-			int delta;
-
-			while (dirty_tx != lp->cur_tx) {
-				int entry = dirty_tx & lp->tx_mod_mask;
-				int status =
-				    (short)le16_to_cpu(lp->tx_ring[entry].
-						       status);
-
-				if (status < 0)
-					break;	/* It still hasn't been Txed */
-
-				lp->tx_ring[entry].base = 0;
-
-				if (status & 0x4000) {
-					/* There was an major error, log it. */
-					int err_status =
-					    le32_to_cpu(lp->tx_ring[entry].
-							misc);
-					lp->stats.tx_errors++;
-					if (netif_msg_tx_err(lp))
-						printk(KERN_ERR
-						       "%s: Tx error status=%04x err_status=%08x\n",
-						       dev->name, status,
-						       err_status);
-					if (err_status & 0x04000000)
-						lp->stats.tx_aborted_errors++;
-					if (err_status & 0x08000000)
-						lp->stats.tx_carrier_errors++;
-					if (err_status & 0x10000000)
-						lp->stats.tx_window_errors++;
-#ifndef DO_DXSUFLO
-					if (err_status & 0x40000000) {
-						lp->stats.tx_fifo_errors++;
-						/* Ackk!  On FIFO errors the Tx unit is turned off! */
-						/* Remove this verbosity later! */
-						if (netif_msg_tx_err(lp))
-							printk(KERN_ERR
-							       "%s: Tx FIFO error! CSR0=%4.4x\n",
-							       dev->name, csr0);
-						must_restart = 1;
-					}
-#else
-					if (err_status & 0x40000000) {
-						lp->stats.tx_fifo_errors++;
-						if (!lp->dxsuflo) {	/* If controller doesn't recover ... */
-							/* Ackk!  On FIFO errors the Tx unit is turned off! */
-							/* Remove this verbosity later! */
-							if (netif_msg_tx_err
-							    (lp))
-								printk(KERN_ERR
-								       "%s: Tx FIFO error! CSR0=%4.4x\n",
-								       dev->
-								       name,
-								       csr0);
-							must_restart = 1;
-						}
-					}
-#endif
-				} else {
-					if (status & 0x1800)
-						lp->stats.collisions++;
-					lp->stats.tx_packets++;
-				}
-
-				/* We must free the original skb */
-				if (lp->tx_skbuff[entry]) {
-					pci_unmap_single(lp->pci_dev,
-							 lp->tx_dma_addr[entry],
-							 lp->tx_skbuff[entry]->
-							 len, PCI_DMA_TODEVICE);
-					dev_kfree_skb_irq(lp->tx_skbuff[entry]);
-					lp->tx_skbuff[entry] = NULL;
-					lp->tx_dma_addr[entry] = 0;
-				}
-				dirty_tx++;
-			}
-
-			delta =
-			    (lp->cur_tx - dirty_tx) & (lp->tx_mod_mask +
-						       lp->tx_ring_size);
-			if (delta > lp->tx_ring_size) {
-				if (netif_msg_drv(lp))
-					printk(KERN_ERR
-					       "%s: out-of-sync dirty pointer, %d vs. %d, full=%d.\n",
-					       dev->name, dirty_tx, lp->cur_tx,
-					       lp->tx_full);
-				dirty_tx += lp->tx_ring_size;
-				delta -= lp->tx_ring_size;
-			}
-
-			if (lp->tx_full &&
-			    netif_queue_stopped(dev) &&
-			    delta < lp->tx_ring_size - 2) {
-				/* The ring is no longer full, clear tbusy. */
-				lp->tx_full = 0;
-				netif_wake_queue(dev);
-			}
-			lp->dirty_tx = dirty_tx;
+		if (netif_rx_schedule_prep(dev)) {
+			u16 val;
+			/* set interrupt masks */
+			val = lp->a.read_csr(ioaddr, 3);
+			val |= 0x5f00;
+			lp->a.write_csr(ioaddr, 3, val);
+			__netif_rx_schedule(dev);
+		} else {
+			printk(KERN_DEBUG "%s: interrupt while in polling mode.\n", dev->name);
 		}
 
 		/* Log misc errors. */
@@ -2152,16 +2560,16 @@ pcnet32_interrupt(int irq, void *dev_id,
 			lp->stats.tx_errors++;	/* Tx babble. */
 		if (csr0 & 0x1000) {
 			/*
-			 * this happens when our receive ring is full. This shouldn't
-			 * be a problem as we will see normal rx interrupts for the frames
-			 * in the receive ring. But there are some PCI chipsets (I can
-			 * reproduce this on SP3G with Intel saturn chipset) which have
-			 * sometimes problems and will fill up the receive ring with
-			 * error descriptors. In this situation we don't get a rx
-			 * interrupt, but a missed frame interrupt sooner or later.
-			 * So we try to clean up our receive ring here.
+			 * This happens when our receive ring is full. This
+			 * shouldn't be a problem as we will see normal rx
+			 * interrupts for the frames in the receive ring. But
+			 * there are some PCI chipsets (I can reproduce this
+			 * on SP3G with Intel saturn chipset) which have
+			 * sometimes problems and will fill up the receive
+			 * ring with error descriptors. In this situation we
+			 * don't get a rx interrupt, but a missed frame
+			 * interrupt sooner or later.
 			 */
-			pcnet32_rx(dev);
 			lp->stats.rx_errors++;	/* Missed a Rx frame. */
 		}
 		if (csr0 & 0x0800) {
@@ -2171,183 +2579,15 @@ pcnet32_interrupt(int irq, void *dev_id,
 				       dev->name, csr0);
 			/* unlike for the lance, there is no restart needed */
 		}
-
-		if (must_restart) {
-			/* reset the chip to clear the error condition, then restart */
-			lp->a.reset(ioaddr);
-			lp->a.write_csr(ioaddr, 4, 0x0915);
-			pcnet32_restart(dev, 0x0002);
-			netif_wake_queue(dev);
-		}
 	}
 
-	/* Set interrupt enable. */
-	lp->a.write_csr(ioaddr, 0, 0x0040);
-	lp->a.write_rap(ioaddr, rap);
-
 	if (netif_msg_intr(lp))
 		printk(KERN_DEBUG "%s: exiting interrupt, csr0=%#4.4x.\n",
 		       dev->name, lp->a.read_csr(ioaddr, 0));
 
 	spin_unlock(&lp->lock);
 
-	return IRQ_HANDLED;
-}
-
-static int pcnet32_rx(struct net_device *dev)
-{
-	struct pcnet32_private *lp = dev->priv;
-	int entry = lp->cur_rx & lp->rx_mod_mask;
-	int boguscnt = lp->rx_ring_size / 2;
-
-	/* If we own the next entry, it's a new packet. Send it up. */
-	while ((short)le16_to_cpu(lp->rx_ring[entry].status) >= 0) {
-		int status = (short)le16_to_cpu(lp->rx_ring[entry].status) >> 8;
-
-		if (status != 0x03) {	/* There was an error. */
-			/*
-			 * There is a tricky error noted by John Murphy,
-			 * <murf@perftech.com> to Russ Nelson: Even with full-sized
-			 * buffers it's possible for a jabber packet to use two
-			 * buffers, with only the last correctly noting the error.
-			 */
-			if (status & 0x01)	/* Only count a general error at the */
-				lp->stats.rx_errors++;	/* end of a packet. */
-			if (status & 0x20)
-				lp->stats.rx_frame_errors++;
-			if (status & 0x10)
-				lp->stats.rx_over_errors++;
-			if (status & 0x08)
-				lp->stats.rx_crc_errors++;
-			if (status & 0x04)
-				lp->stats.rx_fifo_errors++;
-			lp->rx_ring[entry].status &= le16_to_cpu(0x03ff);
-		} else {
-			/* Malloc up new buffer, compatible with net-2e. */
-			short pkt_len =
-			    (le32_to_cpu(lp->rx_ring[entry].msg_length) & 0xfff)
-			    - 4;
-			struct sk_buff *skb;
-
-			/* Discard oversize frames. */
-			if (unlikely(pkt_len > PKT_BUF_SZ - 2)) {
-				if (netif_msg_drv(lp))
-					printk(KERN_ERR
-					       "%s: Impossible packet size %d!\n",
-					       dev->name, pkt_len);
-				lp->stats.rx_errors++;
-			} else if (pkt_len < 60) {
-				if (netif_msg_rx_err(lp))
-					printk(KERN_ERR "%s: Runt packet!\n",
-					       dev->name);
-				lp->stats.rx_errors++;
-			} else {
-				int rx_in_place = 0;
-
-				if (pkt_len > rx_copybreak) {
-					struct sk_buff *newskb;
-
-					if ((newskb =
-					     dev_alloc_skb(PKT_BUF_SZ))) {
-						skb_reserve(newskb, 2);
-						skb = lp->rx_skbuff[entry];
-						pci_unmap_single(lp->pci_dev,
-								 lp->
-								 rx_dma_addr
-								 [entry],
-								 PKT_BUF_SZ - 2,
-								 PCI_DMA_FROMDEVICE);
-						skb_put(skb, pkt_len);
-						lp->rx_skbuff[entry] = newskb;
-						newskb->dev = dev;
-						lp->rx_dma_addr[entry] =
-						    pci_map_single(lp->pci_dev,
-								   newskb->data,
-								   PKT_BUF_SZ -
-								   2,
-								   PCI_DMA_FROMDEVICE);
-						lp->rx_ring[entry].base =
-						    le32_to_cpu(lp->
-								rx_dma_addr
-								[entry]);
-						rx_in_place = 1;
-					} else
-						skb = NULL;
-				} else {
-					skb = dev_alloc_skb(pkt_len + 2);
-				}
-
-				if (skb == NULL) {
-					int i;
-					if (netif_msg_drv(lp))
-						printk(KERN_ERR
-						       "%s: Memory squeeze, deferring packet.\n",
-						       dev->name);
-					for (i = 0; i < lp->rx_ring_size; i++)
-						if ((short)
-						    le16_to_cpu(lp->
-								rx_ring[(entry +
-									 i)
-									& lp->
-									rx_mod_mask].
-								status) < 0)
-							break;
-
-					if (i > lp->rx_ring_size - 2) {
-						lp->stats.rx_dropped++;
-						lp->rx_ring[entry].status |=
-						    le16_to_cpu(0x8000);
-						wmb();	/* Make sure adapter sees owner change */
-						lp->cur_rx++;
-					}
-					break;
-				}
-				skb->dev = dev;
-				if (!rx_in_place) {
-					skb_reserve(skb, 2);	/* 16 byte align */
-					skb_put(skb, pkt_len);	/* Make room */
-					pci_dma_sync_single_for_cpu(lp->pci_dev,
-								    lp->
-								    rx_dma_addr
-								    [entry],
-								    PKT_BUF_SZ -
-								    2,
-								    PCI_DMA_FROMDEVICE);
-					eth_copy_and_sum(skb,
-							 (unsigned char *)(lp->
-									   rx_skbuff
-									   [entry]->
-									   data),
-							 pkt_len, 0);
-					pci_dma_sync_single_for_device(lp->
-								       pci_dev,
-								       lp->
-								       rx_dma_addr
-								       [entry],
-								       PKT_BUF_SZ
-								       - 2,
-								       PCI_DMA_FROMDEVICE);
-				}
-				lp->stats.rx_bytes += skb->len;
-				skb->protocol = eth_type_trans(skb, dev);
-				netif_rx(skb);
-				dev->last_rx = jiffies;
-				lp->stats.rx_packets++;
-			}
-		}
-		/*
-		 * The docs say that the buffer length isn't touched, but Andrew Boyd
-		 * of QNX reports that some revs of the 79C965 clear it.
-		 */
-		lp->rx_ring[entry].buf_length = le16_to_cpu(2 - PKT_BUF_SZ);
-		wmb();		/* Make sure owner changes after all others are visible */
-		lp->rx_ring[entry].status |= le16_to_cpu(0x8000);
-		entry = (++lp->cur_rx) & lp->rx_mod_mask;
-		if (--boguscnt <= 0)
-			break;	/* don't stay in loop forever */
-	}
-
-	return 0;
+	return rc;
 }
 
 static int pcnet32_close(struct net_device *dev)
@@ -2420,13 +2660,10 @@ static struct net_device_stats *pcnet32_
 {
 	struct pcnet32_private *lp = dev->priv;
 	unsigned long ioaddr = dev->base_addr;
-	u16 saved_addr;
 	unsigned long flags;
 
 	spin_lock_irqsave(&lp->lock, flags);
-	saved_addr = lp->a.read_rap(ioaddr);
 	lp->stats.rx_missed_errors = lp->a.read_csr(ioaddr, 112);
-	lp->a.write_rap(ioaddr, saved_addr);
 	spin_unlock_irqrestore(&lp->lock, flags);
 
 	return &lp->stats;
@@ -2439,6 +2676,7 @@ static void pcnet32_load_multicast(struc
 	volatile struct pcnet32_init_block *ib = &lp->init_block;
 	volatile u16 *mcast_table = (u16 *) & ib->filter;
 	struct dev_mc_list *dmi = dev->mc_list;
+	unsigned long ioaddr = dev->base_addr;
 	char *addrs;
 	int i;
 	u32 crc;
@@ -2447,6 +2685,10 @@ static void pcnet32_load_multicast(struc
 	if (dev->flags & IFF_ALLMULTI) {
 		ib->filter[0] = 0xffffffff;
 		ib->filter[1] = 0xffffffff;
+		lp->a.write_csr(ioaddr, 8, 0xffff);
+		lp->a.write_csr(ioaddr, 9, 0xffff);
+		lp->a.write_csr(ioaddr, 10, 0xffff);
+		lp->a.write_csr(ioaddr, 11, 0xffff);
 		return;
 	}
 	/* clear the multicast filter */
@@ -2468,6 +2710,8 @@ static void pcnet32_load_multicast(struc
 		    le16_to_cpu(le16_to_cpu(mcast_table[crc >> 4]) |
 				(1 << (crc & 0xf)));
 	}
+	for (i=0; i<4; i++)
+		lp->a.write_csr(ioaddr, 8+i, le16_to_cpu(mcast_table[i]));
 	return;
 }
 
@@ -2478,8 +2722,11 @@ static void pcnet32_set_multicast_list(s
 {
 	unsigned long ioaddr = dev->base_addr, flags;
 	struct pcnet32_private *lp = dev->priv;
+	int csr15, suspended;
 
 	spin_lock_irqsave(&lp->lock, flags);
+	suspended = pcnet32_suspend(dev, &flags);
+	csr15 = lp->a.read_csr(ioaddr, 15);
 	if (dev->flags & IFF_PROMISC) {
 		/* Log any net taps. */
 		if (netif_msg_hw(lp))
@@ -2488,15 +2735,24 @@ static void pcnet32_set_multicast_list(s
 		lp->init_block.mode =
 		    le16_to_cpu(0x8000 | (lp->options & PCNET32_PORT_PORTSEL) <<
 				7);
+		lp->a.write_csr(ioaddr, 15, csr15 | 0x8000);
 	} else {
 		lp->init_block.mode =
 		    le16_to_cpu((lp->options & PCNET32_PORT_PORTSEL) << 7);
+		lp->a.write_csr(ioaddr, 15, csr15 & 0x7fff);
 		pcnet32_load_multicast(dev);
 	}
 
-	lp->a.write_csr(ioaddr, 0, 0x0004);	/* Temporarily stop the lance. */
-	pcnet32_restart(dev, 0x0042);	/*  Resume normal operation */
-	netif_wake_queue(dev);
+	if (suspended) {
+		int csr5;
+		/* clear SUSPEND (SPND) - CSR5 bit 0 */
+		csr5 = lp->a.read_csr(ioaddr, 5);
+		lp->a.write_csr(ioaddr, 5, csr5 & (~0x0001));
+	} else { 
+		lp->a.write_csr(ioaddr, 0, 0x0004);	/* stop the lance. */
+		pcnet32_restart(dev, 0x0042);	/*  Resume normal operation */
+		netif_wake_queue(dev);
+	}
 
 	spin_unlock_irqrestore(&lp->lock, flags);
 }
@@ -2736,7 +2992,7 @@ static int __init pcnet32_init_module(vo
 
 	/* should we find any remaining VLbus devices ? */
 	if (pcnet32vlb)
-		pcnet32_probe_vlbus();
+		pcnet32_probe_vlbus(pcnet32_portlist);
 
 	if (cards_found && (pcnet32_debug & NETIF_MSG_PROBE))
 		printk(KERN_INFO PFX "%d cards_found.\n", cards_found);

-- 
Don Fry
brazilnut@us.ibm.com
