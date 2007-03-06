From: Don Fry <pcnet32@verizon.net>
Subject: [PATCH] pcnet32: only allocate init_block dma consistent
Date: Mon, 5 Mar 2007 18:10:37 -0800
Message-ID: <20070306021037.GA7139@verizon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from [71.117.224.81] ([71.117.224.81]:16655 "EHLO linux.site"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S933862AbXCFCea (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2007 21:34:30 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The patch below moves the init_block out of the private struct and
only allocates init block with pci_alloc_consistent.

This has two effects:

1. Performance increase for non cache coherent machines, because the
   CPU only data in the private struct are now cached

2. locks are working now for platforms, which need to have locks
   in cached memory

Also use netdev_priv() instead of dev->priv

Signed-off-by: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Acked-by: Don Fry <pcnet32@verizon.net>
---

diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
index 36f9d98..8498c3b 100644
--- a/drivers/net/pcnet32.c
+++ b/drivers/net/pcnet32.c
@@ -253,12 +253,12 @@ struct pcnet32_access {
  * so the structure should be allocated using pci_alloc_consistent().
  */
 struct pcnet32_private {
-	struct pcnet32_init_block init_block;
+	struct pcnet32_init_block *init_block;
 	/* The Tx and Rx ring entries must be aligned on 16-byte boundaries in 32bit mode. */
 	struct pcnet32_rx_head	*rx_ring;
 	struct pcnet32_tx_head	*tx_ring;
-	dma_addr_t		dma_addr;/* DMA address of beginning of this
-				   object, returned by pci_alloc_consistent */
+	dma_addr_t		init_dma_addr;/* DMA address of beginning of the init block,
+				   returned by pci_alloc_consistent */
 	struct pci_dev		*pci_dev;
 	const char		*name;
 	/* The saved address of a sent-in-place packet/buffer, for skfree(). */
@@ -653,7 +653,7 @@ static void pcnet32_realloc_rx_ring(struct net_device *dev,
 
 static void pcnet32_purge_rx_ring(struct net_device *dev)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	int i;
 
 	/* free all allocated skbuffs */
@@ -681,7 +681,7 @@ static void pcnet32_poll_controller(struct net_device *dev)
 
 static int pcnet32_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	unsigned long flags;
 	int r = -EOPNOTSUPP;
 
@@ -696,7 +696,7 @@ static int pcnet32_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 static int pcnet32_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	unsigned long flags;
 	int r = -EOPNOTSUPP;
 
@@ -711,7 +711,7 @@ static int pcnet32_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 static void pcnet32_get_drvinfo(struct net_device *dev,
 				struct ethtool_drvinfo *info)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 
 	strcpy(info->driver, DRV_NAME);
 	strcpy(info->version, DRV_VERSION);
@@ -723,7 +723,7 @@ static void pcnet32_get_drvinfo(struct net_device *dev,
 
 static u32 pcnet32_get_link(struct net_device *dev)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	unsigned long flags;
 	int r;
 
@@ -743,19 +743,19 @@ static u32 pcnet32_get_link(struct net_device *dev)
 
 static u32 pcnet32_get_msglevel(struct net_device *dev)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	return lp->msg_enable;
 }
 
 static void pcnet32_set_msglevel(struct net_device *dev, u32 value)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	lp->msg_enable = value;
 }
 
 static int pcnet32_nway_reset(struct net_device *dev)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	unsigned long flags;
 	int r = -EOPNOTSUPP;
 
@@ -770,7 +770,7 @@ static int pcnet32_nway_reset(struct net_device *dev)
 static void pcnet32_get_ringparam(struct net_device *dev,
 				  struct ethtool_ringparam *ering)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 
 	ering->tx_max_pending = TX_MAX_RING_SIZE;
 	ering->tx_pending = lp->tx_ring_size;
@@ -781,7 +781,7 @@ static void pcnet32_get_ringparam(struct net_device *dev,
 static int pcnet32_set_ringparam(struct net_device *dev,
 				 struct ethtool_ringparam *ering)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	unsigned long flags;
 	unsigned int size;
 	ulong ioaddr = dev->base_addr;
@@ -847,7 +847,7 @@ static int pcnet32_self_test_count(struct net_device *dev)
 static void pcnet32_ethtool_test(struct net_device *dev,
 				 struct ethtool_test *test, u64 * data)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	int rc;
 
 	if (test->flags == ETH_TEST_FL_OFFLINE) {
@@ -868,7 +868,7 @@ static void pcnet32_ethtool_test(struct net_device *dev,
 
 static int pcnet32_loopback_test(struct net_device *dev, uint64_t * data1)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	struct pcnet32_access *a = &lp->a;	/* access to registers */
 	ulong ioaddr = dev->base_addr;	/* card base I/O address */
 	struct sk_buff *skb;	/* sk buff */
@@ -1047,7 +1047,7 @@ static int pcnet32_loopback_test(struct net_device *dev, uint64_t * data1)
 
 static void pcnet32_led_blink_callback(struct net_device *dev)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	struct pcnet32_access *a = &lp->a;
 	ulong ioaddr = dev->base_addr;
 	unsigned long flags;
@@ -1064,7 +1064,7 @@ static void pcnet32_led_blink_callback(struct net_device *dev)
 
 static int pcnet32_phys_id(struct net_device *dev, u32 data)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	struct pcnet32_access *a = &lp->a;
 	ulong ioaddr = dev->base_addr;
 	unsigned long flags;
@@ -1109,7 +1109,7 @@ static int pcnet32_suspend(struct net_device *dev, unsigned long *flags,
 		int can_sleep)
 {
 	int csr5;
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	struct pcnet32_access *a = &lp->a;
 	ulong ioaddr = dev->base_addr;
 	int ticks;
@@ -1258,7 +1258,7 @@ static void pcnet32_rx_entry(struct net_device *dev,
 
 static int pcnet32_rx(struct net_device *dev, int quota)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	int entry = lp->cur_rx & lp->rx_mod_mask;
 	struct pcnet32_rx_head *rxp = &lp->rx_ring[entry];
 	int npackets = 0;
@@ -1283,7 +1283,7 @@ static int pcnet32_rx(struct net_device *dev, int quota)
 
 static int pcnet32_tx(struct net_device *dev)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	unsigned int dirty_tx = lp->dirty_tx;
 	int delta;
 	int must_restart = 0;
@@ -1382,7 +1382,7 @@ static int pcnet32_tx(struct net_device *dev)
 #ifdef CONFIG_PCNET32_NAPI
 static int pcnet32_poll(struct net_device *dev, int *budget)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	int quota = min(dev->quota, *budget);
 	unsigned long ioaddr = dev->base_addr;
 	unsigned long flags;
@@ -1429,7 +1429,7 @@ static int pcnet32_poll(struct net_device *dev, int *budget)
 #define PCNET32_MAX_PHYS	32
 static int pcnet32_get_regs_len(struct net_device *dev)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	int j = lp->phycount * PCNET32_REGS_PER_PHY;
 
 	return ((PCNET32_NUM_REGS + j) * sizeof(u16));
@@ -1440,7 +1440,7 @@ static void pcnet32_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 {
 	int i, csr0;
 	u16 *buff = ptr;
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	struct pcnet32_access *a = &lp->a;
 	ulong ioaddr = dev->base_addr;
 	unsigned long flags;
@@ -1593,7 +1593,6 @@ static int __devinit
 pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 {
 	struct pcnet32_private *lp;
-	dma_addr_t lp_dma_addr;
 	int i, media;
 	int fdx, mii, fset, dxsuflo;
 	int chip_version;
@@ -1715,7 +1714,7 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 		dxsuflo = 1;
 	}
 
-	dev = alloc_etherdev(0);
+	dev = alloc_etherdev(sizeof(*lp));
 	if (!dev) {
 		if (pcnet32_debug & NETIF_MSG_PROBE)
 			printk(KERN_ERR PFX "Memory allocation failed.\n");
@@ -1806,25 +1805,22 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 	}
 
 	dev->base_addr = ioaddr;
+	lp = netdev_priv(dev);
 	/* pci_alloc_consistent returns page-aligned memory, so we do not have to check the alignment */
-	if ((lp =
-	     pci_alloc_consistent(pdev, sizeof(*lp), &lp_dma_addr)) == NULL) {
+	if ((lp->init_block =
+	     pci_alloc_consistent(pdev, sizeof(*lp->init_block), &lp->init_dma_addr)) == NULL) {
 		if (pcnet32_debug & NETIF_MSG_PROBE)
 			printk(KERN_ERR PFX
 			       "Consistent memory allocation failed.\n");
 		ret = -ENOMEM;
 		goto err_free_netdev;
 	}
-
-	memset(lp, 0, sizeof(*lp));
-	lp->dma_addr = lp_dma_addr;
 	lp->pci_dev = pdev;
 
 	spin_lock_init(&lp->lock);
 
 	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
-	dev->priv = lp;
 	lp->name = chipname;
 	lp->shared_irq = shared;
 	lp->tx_ring_size = TX_RING_SIZE;	/* default tx ring size */
@@ -1871,23 +1867,21 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 	    && dev->dev_addr[2] == 0x75)
 		lp->options = PCNET32_PORT_FD | PCNET32_PORT_GPSI;
 
-	lp->init_block.mode = le16_to_cpu(0x0003);	/* Disable Rx and Tx. */
-	lp->init_block.tlen_rlen =
+	lp->init_block->mode = le16_to_cpu(0x0003);	/* Disable Rx and Tx. */
+	lp->init_block->tlen_rlen =
 	    le16_to_cpu(lp->tx_len_bits | lp->rx_len_bits);
 	for (i = 0; i < 6; i++)
-		lp->init_block.phys_addr[i] = dev->dev_addr[i];
-	lp->init_block.filter[0] = 0x00000000;
-	lp->init_block.filter[1] = 0x00000000;
-	lp->init_block.rx_ring = (u32) le32_to_cpu(lp->rx_ring_dma_addr);
-	lp->init_block.tx_ring = (u32) le32_to_cpu(lp->tx_ring_dma_addr);
+		lp->init_block->phys_addr[i] = dev->dev_addr[i];
+	lp->init_block->filter[0] = 0x00000000;
+	lp->init_block->filter[1] = 0x00000000;
+	lp->init_block->rx_ring = (u32) le32_to_cpu(lp->rx_ring_dma_addr);
+	lp->init_block->tx_ring = (u32) le32_to_cpu(lp->tx_ring_dma_addr);
 
 	/* switch pcnet32 to 32bit mode */
 	a->write_bcr(ioaddr, 20, 2);
 
-	a->write_csr(ioaddr, 1, (lp->dma_addr + offsetof(struct pcnet32_private,
-							 init_block)) & 0xffff);
-	a->write_csr(ioaddr, 2, (lp->dma_addr + offsetof(struct pcnet32_private,
-							 init_block)) >> 16);
+	a->write_csr(ioaddr, 1, (lp->init_dma_addr & 0xffff));
+	a->write_csr(ioaddr, 2, (lp->init_dma_addr >> 16));
 
 	if (pdev) {		/* use the IRQ provided by PCI */
 		dev->irq = pdev->irq;
@@ -1993,7 +1987,8 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
       err_free_ring:
 	pcnet32_free_ring(dev);
       err_free_consistent:
-	pci_free_consistent(lp->pci_dev, sizeof(*lp), lp, lp->dma_addr);
+	pci_free_consistent(lp->pci_dev, sizeof(*lp->init_block), 
+			    lp->init_block, lp->init_dma_addr);
       err_free_netdev:
 	free_netdev(dev);
       err_release_region:
@@ -2004,7 +1999,7 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 /* if any allocation fails, caller must also call pcnet32_free_ring */
 static int pcnet32_alloc_ring(struct net_device *dev, char *name)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 
 	lp->tx_ring = pci_alloc_consistent(lp->pci_dev,
 					   sizeof(struct pcnet32_tx_head) *
@@ -2071,7 +2066,7 @@ static int pcnet32_alloc_ring(struct net_device *dev, char *name)
 
 static void pcnet32_free_ring(struct net_device *dev)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 
 	kfree(lp->tx_skbuff);
 	lp->tx_skbuff = NULL;
@@ -2104,7 +2099,7 @@ static void pcnet32_free_ring(struct net_device *dev)
 
 static int pcnet32_open(struct net_device *dev)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	unsigned long ioaddr = dev->base_addr;
 	u16 val;
 	int i;
@@ -2135,8 +2130,7 @@ static int pcnet32_open(struct net_device *dev)
 		       "%s: pcnet32_open() irq %d tx/rx rings %#x/%#x init %#x.\n",
 		       dev->name, dev->irq, (u32) (lp->tx_ring_dma_addr),
 		       (u32) (lp->rx_ring_dma_addr),
-		       (u32) (lp->dma_addr +
-			      offsetof(struct pcnet32_private, init_block)));
+		       (u32) (lp->init_dma_addr));
 
 	/* set/reset autoselect bit */
 	val = lp->a.read_bcr(ioaddr, 2) & ~2;
@@ -2275,7 +2269,7 @@ static int pcnet32_open(struct net_device *dev)
 	}
 #endif
 
-	lp->init_block.mode =
+	lp->init_block->mode =
 	    le16_to_cpu((lp->options & PCNET32_PORT_PORTSEL) << 7);
 	pcnet32_load_multicast(dev);
 
@@ -2285,12 +2279,8 @@ static int pcnet32_open(struct net_device *dev)
 	}
 
 	/* Re-initialize the PCNET32, and start it when done. */
-	lp->a.write_csr(ioaddr, 1, (lp->dma_addr +
-				    offsetof(struct pcnet32_private,
-					     init_block)) & 0xffff);
-	lp->a.write_csr(ioaddr, 2,
-			(lp->dma_addr +
-			 offsetof(struct pcnet32_private, init_block)) >> 16);
+	lp->a.write_csr(ioaddr, 1, (lp->init_dma_addr & 0xffff));
+	lp->a.write_csr(ioaddr, 2, (lp->init_dma_addr >> 16));
 
 	lp->a.write_csr(ioaddr, CSR4, 0x0915);	/* auto tx pad */
 	lp->a.write_csr(ioaddr, CSR0, CSR0_INIT);
@@ -2317,8 +2307,7 @@ static int pcnet32_open(struct net_device *dev)
 		printk(KERN_DEBUG
 		       "%s: pcnet32 open after %d ticks, init block %#x csr0 %4.4x.\n",
 		       dev->name, i,
-		       (u32) (lp->dma_addr +
-			      offsetof(struct pcnet32_private, init_block)),
+		       (u32) (lp->init_dma_addr),
 		       lp->a.read_csr(ioaddr, CSR0));
 
 	spin_unlock_irqrestore(&lp->lock, flags);
@@ -2356,7 +2345,7 @@ static int pcnet32_open(struct net_device *dev)
 
 static void pcnet32_purge_tx_ring(struct net_device *dev)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	int i;
 
 	for (i = 0; i < lp->tx_ring_size; i++) {
@@ -2376,7 +2365,7 @@ static void pcnet32_purge_tx_ring(struct net_device *dev)
 /* Initialize the PCNET32 Rx and Tx rings. */
 static int pcnet32_init_ring(struct net_device *dev)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	int i;
 
 	lp->tx_full = 0;
@@ -2418,12 +2407,12 @@ static int pcnet32_init_ring(struct net_device *dev)
 		lp->tx_dma_addr[i] = 0;
 	}
 
-	lp->init_block.tlen_rlen =
+	lp->init_block->tlen_rlen =
 	    le16_to_cpu(lp->tx_len_bits | lp->rx_len_bits);
 	for (i = 0; i < 6; i++)
-		lp->init_block.phys_addr[i] = dev->dev_addr[i];
-	lp->init_block.rx_ring = (u32) le32_to_cpu(lp->rx_ring_dma_addr);
-	lp->init_block.tx_ring = (u32) le32_to_cpu(lp->tx_ring_dma_addr);
+		lp->init_block->phys_addr[i] = dev->dev_addr[i];
+	lp->init_block->rx_ring = (u32) le32_to_cpu(lp->rx_ring_dma_addr);
+	lp->init_block->tx_ring = (u32) le32_to_cpu(lp->tx_ring_dma_addr);
 	wmb();			/* Make sure all changes are visible */
 	return 0;
 }
@@ -2434,7 +2423,7 @@ static int pcnet32_init_ring(struct net_device *dev)
  */
 static void pcnet32_restart(struct net_device *dev, unsigned int csr0_bits)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	unsigned long ioaddr = dev->base_addr;
 	int i;
 
@@ -2464,7 +2453,7 @@ static void pcnet32_restart(struct net_device *dev, unsigned int csr0_bits)
 
 static void pcnet32_tx_timeout(struct net_device *dev)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	unsigned long ioaddr = dev->base_addr, flags;
 
 	spin_lock_irqsave(&lp->lock, flags);
@@ -2505,7 +2494,7 @@ static void pcnet32_tx_timeout(struct net_device *dev)
 
 static int pcnet32_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	unsigned long ioaddr = dev->base_addr;
 	u16 status;
 	int entry;
@@ -2570,7 +2559,7 @@ pcnet32_interrupt(int irq, void *dev_id)
 	int boguscnt = max_interrupt_work;
 
 	ioaddr = dev->base_addr;
-	lp = dev->priv;
+	lp = netdev_priv(dev);
 
 	spin_lock(&lp->lock);
 
@@ -2652,7 +2641,7 @@ pcnet32_interrupt(int irq, void *dev_id)
 static int pcnet32_close(struct net_device *dev)
 {
 	unsigned long ioaddr = dev->base_addr;
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	unsigned long flags;
 
 	del_timer_sync(&lp->watchdog_timer);
@@ -2693,7 +2682,7 @@ static int pcnet32_close(struct net_device *dev)
 
 static struct net_device_stats *pcnet32_get_stats(struct net_device *dev)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	unsigned long ioaddr = dev->base_addr;
 	unsigned long flags;
 
@@ -2707,8 +2696,8 @@ static struct net_device_stats *pcnet32_get_stats(struct net_device *dev)
 /* taken from the sunlance driver, which it took from the depca driver */
 static void pcnet32_load_multicast(struct net_device *dev)
 {
-	struct pcnet32_private *lp = dev->priv;
-	volatile struct pcnet32_init_block *ib = &lp->init_block;
+	struct pcnet32_private *lp = netdev_priv(dev);
+	volatile struct pcnet32_init_block *ib = lp->init_block;
 	volatile u16 *mcast_table = (u16 *) & ib->filter;
 	struct dev_mc_list *dmi = dev->mc_list;
 	unsigned long ioaddr = dev->base_addr;
@@ -2757,7 +2746,7 @@ static void pcnet32_load_multicast(struct net_device *dev)
 static void pcnet32_set_multicast_list(struct net_device *dev)
 {
 	unsigned long ioaddr = dev->base_addr, flags;
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	int csr15, suspended;
 
 	spin_lock_irqsave(&lp->lock, flags);
@@ -2768,12 +2757,12 @@ static void pcnet32_set_multicast_list(struct net_device *dev)
 		if (netif_msg_hw(lp))
 			printk(KERN_INFO "%s: Promiscuous mode enabled.\n",
 			       dev->name);
-		lp->init_block.mode =
+		lp->init_block->mode =
 		    le16_to_cpu(0x8000 | (lp->options & PCNET32_PORT_PORTSEL) <<
 				7);
 		lp->a.write_csr(ioaddr, CSR15, csr15 | 0x8000);
 	} else {
-		lp->init_block.mode =
+		lp->init_block->mode =
 		    le16_to_cpu((lp->options & PCNET32_PORT_PORTSEL) << 7);
 		lp->a.write_csr(ioaddr, CSR15, csr15 & 0x7fff);
 		pcnet32_load_multicast(dev);
@@ -2796,7 +2785,7 @@ static void pcnet32_set_multicast_list(struct net_device *dev)
 /* This routine assumes that the lp->lock is held */
 static int mdio_read(struct net_device *dev, int phy_id, int reg_num)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	unsigned long ioaddr = dev->base_addr;
 	u16 val_out;
 
@@ -2812,7 +2801,7 @@ static int mdio_read(struct net_device *dev, int phy_id, int reg_num)
 /* This routine assumes that the lp->lock is held */
 static void mdio_write(struct net_device *dev, int phy_id, int reg_num, int val)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	unsigned long ioaddr = dev->base_addr;
 
 	if (!lp->mii)
@@ -2824,7 +2813,7 @@ static void mdio_write(struct net_device *dev, int phy_id, int reg_num, int val)
 
 static int pcnet32_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	int rc;
 	unsigned long flags;
 
@@ -2842,7 +2831,7 @@ static int pcnet32_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 
 static int pcnet32_check_otherphy(struct net_device *dev)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	struct mii_if_info mii = lp->mii_if;
 	u16 bmcr;
 	int i;
@@ -2889,7 +2878,7 @@ static int pcnet32_check_otherphy(struct net_device *dev)
 
 static void pcnet32_check_media(struct net_device *dev, int verbose)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	int curr_link;
 	int prev_link = netif_carrier_ok(dev) ? 1 : 0;
 	u32 bcr9;
@@ -2945,7 +2934,7 @@ static void pcnet32_check_media(struct net_device *dev, int verbose)
 
 static void pcnet32_watchdog(struct net_device *dev)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	unsigned long flags;
 
 	/* Print the link status if it has changed */
@@ -2961,12 +2950,13 @@ static void __devexit pcnet32_remove_one(struct pci_dev *pdev)
 	struct net_device *dev = pci_get_drvdata(pdev);
 
 	if (dev) {
-		struct pcnet32_private *lp = dev->priv;
+		struct pcnet32_private *lp = netdev_priv(dev);
 
 		unregister_netdev(dev);
 		pcnet32_free_ring(dev);
 		release_region(dev->base_addr, PCNET32_TOTAL_SIZE);
-		pci_free_consistent(lp->pci_dev, sizeof(*lp), lp, lp->dma_addr);
+		pci_free_consistent(lp->pci_dev, sizeof(*lp->init_block), 
+				    lp->init_block, lp->init_dma_addr);
 		free_netdev(dev);
 		pci_disable_device(pdev);
 		pci_set_drvdata(pdev, NULL);
@@ -3041,12 +3031,13 @@ static void __exit pcnet32_cleanup_module(void)
 	struct net_device *next_dev;
 
 	while (pcnet32_dev) {
-		struct pcnet32_private *lp = pcnet32_dev->priv;
+		struct pcnet32_private *lp = netdev_priv(pcnet32_dev);
 		next_dev = lp->next;
 		unregister_netdev(pcnet32_dev);
 		pcnet32_free_ring(pcnet32_dev);
 		release_region(pcnet32_dev->base_addr, PCNET32_TOTAL_SIZE);
-		pci_free_consistent(lp->pci_dev, sizeof(*lp), lp, lp->dma_addr);
+		pci_free_consistent(lp->pci_dev, sizeof(*lp->init_block), 
+				    lp->init_block, lp->init_dma_addr);
 		free_netdev(pcnet32_dev);
 		pcnet32_dev = next_dev;
 	}
-- 
Crap can work. Given enough thrust pigs will fly, but it's not necessary a
good idea.                                                [ RFC1925, 2.3 ]
