From: Don Fry <pcnet32@verizon.net>
Subject: [PATCH 1/2] pcnet32: only allocate init_block dma consistent
Date: Tue, 6 Mar 2007 10:45:23 -0800
Message-ID: <20070306184523.GA23268@verizon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from [71.117.224.81] ([71.117.224.81]:13619 "EHLO linux.site"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S966004AbXCFSo4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 13:44:56 -0500
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

Signed-off-by: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Acked-by: Don Fry <pcnet32@verizon.net>
---
 drivers/net/pcnet32.c |   77 ++++++++++++++++++++++---------------------------
 1 files changed, 34 insertions(+), 43 deletions(-)

diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
index 36f9d98..04b0c44 100644
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
+	lp = dev->priv;
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
@@ -2708,7 +2697,7 @@ static struct net_device_stats *pcnet32_get_stats(struct net_device *dev)
 static void pcnet32_load_multicast(struct net_device *dev)
 {
 	struct pcnet32_private *lp = dev->priv;
-	volatile struct pcnet32_init_block *ib = &lp->init_block;
+	volatile struct pcnet32_init_block *ib = lp->init_block;
 	volatile u16 *mcast_table = (u16 *) & ib->filter;
 	struct dev_mc_list *dmi = dev->mc_list;
 	unsigned long ioaddr = dev->base_addr;
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
@@ -2966,7 +2955,8 @@ static void __devexit pcnet32_remove_one(struct pci_dev *pdev)
 		unregister_netdev(dev);
 		pcnet32_free_ring(dev);
 		release_region(dev->base_addr, PCNET32_TOTAL_SIZE);
-		pci_free_consistent(lp->pci_dev, sizeof(*lp), lp, lp->dma_addr);
+		pci_free_consistent(lp->pci_dev, sizeof(*lp->init_block), 
+				    lp->init_block, lp->init_dma_addr);
 		free_netdev(dev);
 		pci_disable_device(pdev);
 		pci_set_drvdata(pdev, NULL);
@@ -3046,7 +3036,8 @@ static void __exit pcnet32_cleanup_module(void)
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

