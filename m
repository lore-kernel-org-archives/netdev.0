From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/2] via_rhine: Use netdev_<level> and pr_<level>
Date: Sat, 16 Apr 2011 17:15:25 -0700
Message-ID: <15b0ca3fc5ba6a16b207fb32b0c2e3c809f376d1.1302998994.git.joe@perches.com>
References: <4DAA12C0.7030106@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexandru Gagniuc <mr.nuke.me@gmail.com>,
	Roger Luethi <rl@hellgate.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:4756 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752965Ab1DQAPa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Apr 2011 20:15:30 -0400
In-Reply-To: <4DAA12C0.7030106@gmail.com>
In-Reply-To: <cover.1302998994.git.joe@perches.com>
References: <cover.1302998994.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the more current logging styles.

Add #define DEBUG to make netdev_dbg always active.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/via-rhine.c |  230 ++++++++++++++++++++++-------------------------
 1 files changed, 108 insertions(+), 122 deletions(-)

diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
index 0422a79..40f394c 100644
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -29,6 +29,8 @@
 
 */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #define DRV_NAME	"via-rhine"
 #define DRV_VERSION	"1.5.0"
 #define DRV_RELDATE	"2010-10-09"
@@ -37,6 +39,7 @@
 /* A few user-configurable values.
    These may be modified when a driver module is loaded. */
 
+#define DEBUG
 static int debug = 1;	/* 1 normal messages, 0 quiet .. 7 verbose. */
 static int max_interrupt_work = 20;
 
@@ -111,8 +114,7 @@ static const int multicast_filter_limit = 32;
 
 /* These identify the driver base version and may not be removed. */
 static const char version[] __devinitconst =
-	KERN_INFO DRV_NAME ".c:v1.10-LK" DRV_VERSION " " DRV_RELDATE
-	" Written by Donald Becker\n";
+	"v1.10-LK" DRV_VERSION " " DRV_RELDATE " Written by Donald Becker";
 
 /* This driver was written to use PCI memory space. Some early versions
    of the Rhine may only work correctly with I/O space accesses. */
@@ -495,14 +497,15 @@ static void rhine_set_vlan_cam_mask(void __iomem *ioaddr, u32 mask);
 static void rhine_init_cam_filter(struct net_device *dev);
 static void rhine_update_vcam(struct net_device *dev);
 
-#define RHINE_WAIT_FOR(condition) do {					\
-	int i=1024;							\
-	while (!(condition) && --i)					\
-		;							\
-	if (debug > 1 && i < 512)					\
-		printk(KERN_INFO "%s: %4d cycles used @ %s:%d\n",	\
-				DRV_NAME, 1024-i, __func__, __LINE__);	\
-} while(0)
+#define RHINE_WAIT_FOR(condition)				\
+do {								\
+	int i = 1024;						\
+	while (!(condition) && --i)				\
+		;						\
+	if (debug > 1 && i < 512)				\
+		pr_info("%4d cycles used @ %s:%d\n",		\
+			1024 - i, __func__, __LINE__);		\
+} while (0)
 
 static inline u32 get_intr_status(struct net_device *dev)
 {
@@ -571,8 +574,8 @@ static void rhine_power_init(struct net_device *dev)
 			default:
 				reason = "Unknown";
 			}
-			printk(KERN_INFO "%s: Woke system up. Reason: %s.\n",
-			       DRV_NAME, reason);
+			netdev_info(dev, "Woke system up. Reason: %s\n",
+				    reason);
 		}
 	}
 }
@@ -586,8 +589,7 @@ static void rhine_chip_reset(struct net_device *dev)
 	IOSYNC;
 
 	if (ioread8(ioaddr + ChipCmd1) & Cmd1Reset) {
-		printk(KERN_INFO "%s: Reset not complete yet. "
-			"Trying harder.\n", DRV_NAME);
+		netdev_info(dev, "Reset not complete yet. Trying harder.\n");
 
 		/* Force reset */
 		if (rp->quirks & rqForceReset)
@@ -598,9 +600,9 @@ static void rhine_chip_reset(struct net_device *dev)
 	}
 
 	if (debug > 1)
-		printk(KERN_INFO "%s: Reset %s.\n", dev->name,
-			(ioread8(ioaddr + ChipCmd1) & Cmd1Reset) ?
-			"failed" : "succeeded");
+		netdev_info(dev, "Reset %s\n",
+			    (ioread8(ioaddr + ChipCmd1) & Cmd1Reset) ?
+			    "failed" : "succeeded");
 }
 
 #ifdef USE_MMIO
@@ -728,9 +730,7 @@ static int __devinit rhine_init_one(struct pci_dev *pdev,
 
 /* when built into the kernel, we only print version if device is found */
 #ifndef MODULE
-	static int printed_version;
-	if (!printed_version++)
-		printk(version);
+	pr_info_once("%s\n", version);
 #endif
 
 	io_size = 256;
@@ -765,8 +765,8 @@ static int __devinit rhine_init_one(struct pci_dev *pdev,
 	/* this should always be supported */
 	rc = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 	if (rc) {
-		printk(KERN_ERR "32-bit PCI DMA addresses not supported by "
-		       "the card!?\n");
+		dev_err(&pdev->dev,
+			"32-bit PCI DMA addresses not supported by the card!?\n");
 		goto err_out;
 	}
 
@@ -774,7 +774,7 @@ static int __devinit rhine_init_one(struct pci_dev *pdev,
 	if ((pci_resource_len(pdev, 0) < io_size) ||
 	    (pci_resource_len(pdev, 1) < io_size)) {
 		rc = -EIO;
-		printk(KERN_ERR "Insufficient PCI resources, aborting\n");
+		dev_err(&pdev->dev, "Insufficient PCI resources, aborting\n");
 		goto err_out;
 	}
 
@@ -786,7 +786,7 @@ static int __devinit rhine_init_one(struct pci_dev *pdev,
 	dev = alloc_etherdev(sizeof(struct rhine_private));
 	if (!dev) {
 		rc = -ENOMEM;
-		printk(KERN_ERR "alloc_etherdev failed\n");
+		dev_err(&pdev->dev, "alloc_etherdev failed\n");
 		goto err_out;
 	}
 	SET_NETDEV_DEV(dev, &pdev->dev);
@@ -804,8 +804,9 @@ static int __devinit rhine_init_one(struct pci_dev *pdev,
 	ioaddr = pci_iomap(pdev, bar, io_size);
 	if (!ioaddr) {
 		rc = -EIO;
-		printk(KERN_ERR "ioremap failed for device %s, region 0x%X "
-		       "@ 0x%lX\n", pci_name(pdev), io_size, memaddr);
+		dev_err(&pdev->dev,
+			"ioremap failed for device %s, region 0x%X @ 0x%lX\n",
+			pci_name(pdev), io_size, memaddr);
 		goto err_out_free_res;
 	}
 
@@ -820,8 +821,9 @@ static int __devinit rhine_init_one(struct pci_dev *pdev,
 		unsigned char b = readb(ioaddr+reg);
 		if (a != b) {
 			rc = -EIO;
-			printk(KERN_ERR "MMIO do not match PIO [%02x] "
-			       "(%02x != %02x)\n", reg, a, b);
+			dev_err(&pdev->dev,
+				"MMIO do not match PIO [%02x] (%02x != %02x)\n",
+				reg, a, b);
 			goto err_out_unmap;
 		}
 	}
@@ -840,7 +842,7 @@ static int __devinit rhine_init_one(struct pci_dev *pdev,
 
 	if (!is_valid_ether_addr(dev->perm_addr)) {
 		rc = -EIO;
-		printk(KERN_ERR "Invalid MAC address\n");
+		dev_err(&pdev->dev, "Invalid MAC address\n");
 		goto err_out_unmap;
 	}
 
@@ -878,14 +880,14 @@ static int __devinit rhine_init_one(struct pci_dev *pdev,
 	if (rc)
 		goto err_out_unmap;
 
-	printk(KERN_INFO "%s: VIA %s at 0x%lx, %pM, IRQ %d.\n",
-	       dev->name, name,
+	netdev_info(dev, "VIA %s at 0x%lx, %pM, IRQ %d\n",
+		    name,
 #ifdef USE_MMIO
-	       memaddr,
+		    memaddr,
 #else
-	       (long)ioaddr,
+		    (long)ioaddr,
 #endif
-	       dev->dev_addr, pdev->irq);
+		    dev->dev_addr, pdev->irq);
 
 	pci_set_drvdata(pdev, dev);
 
@@ -896,11 +898,11 @@ static int __devinit rhine_init_one(struct pci_dev *pdev,
 		mdio_write(dev, phy_id, MII_BMCR, mii_cmd);
 		if (mii_status != 0xffff && mii_status != 0x0000) {
 			rp->mii_if.advertising = mdio_read(dev, phy_id, 4);
-			printk(KERN_INFO "%s: MII PHY found at address "
-			       "%d, status 0x%4.4x advertising %4.4x "
-			       "Link %4.4x.\n", dev->name, phy_id,
-			       mii_status, rp->mii_if.advertising,
-			       mdio_read(dev, phy_id, 5));
+			netdev_info(dev,
+				    "MII PHY found at address %d, status 0x%04x advertising %04x Link %04x\n",
+				    phy_id,
+				    mii_status, rp->mii_if.advertising,
+				    mdio_read(dev, phy_id, 5));
 
 			/* set IFF_RUNNING */
 			if (mii_status & BMSR_LSTATUS)
@@ -912,8 +914,7 @@ static int __devinit rhine_init_one(struct pci_dev *pdev,
 	}
 	rp->mii_if.phy_id = phy_id;
 	if (debug > 1 && avoid_D3)
-		printk(KERN_INFO "%s: No D3 power state at shutdown.\n",
-		       dev->name);
+		netdev_info(dev, "No D3 power state at shutdown\n");
 
 	return 0;
 
@@ -938,7 +939,7 @@ static int alloc_ring(struct net_device* dev)
 				    TX_RING_SIZE * sizeof(struct tx_desc),
 				    &ring_dma);
 	if (!ring) {
-		printk(KERN_ERR "Could not allocate DMA memory.\n");
+		netdev_err(dev, "Could not allocate DMA memory\n");
 		return -ENOMEM;
 	}
 	if (rp->quirks & rqRhineI) {
@@ -1098,8 +1099,8 @@ static void rhine_check_media(struct net_device *dev, unsigned int init_media)
 	    iowrite8(ioread8(ioaddr + ChipCmd1) & ~Cmd1FDuplex,
 		   ioaddr + ChipCmd1);
 	if (debug > 1)
-		printk(KERN_INFO "%s: force_media %d, carrier %d\n", dev->name,
-			rp->mii_if.force_media, netif_carrier_ok(dev));
+		netdev_info(dev, "force_media %d, carrier %d\n",
+			    rp->mii_if.force_media, netif_carrier_ok(dev));
 }
 
 /* Called after status of force_media possibly changed */
@@ -1113,9 +1114,8 @@ static void rhine_set_carrier(struct mii_if_info *mii)
 	else	/* Let MMI library update carrier status */
 		rhine_check_media(mii->dev, 0);
 	if (debug > 1)
-		printk(KERN_INFO "%s: force_media %d, carrier %d\n",
-		       mii->dev->name, mii->force_media,
-		       netif_carrier_ok(mii->dev));
+		netdev_info(mii->dev, "force_media %d, carrier %d\n",
+			    mii->force_media, netif_carrier_ok(mii->dev));
 }
 
 /**
@@ -1402,8 +1402,7 @@ static int rhine_open(struct net_device *dev)
 		return rc;
 
 	if (debug > 1)
-		printk(KERN_DEBUG "%s: rhine_open() irq %d.\n",
-		       dev->name, rp->pdev->irq);
+		netdev_dbg(dev, "%s() irq %d\n", __func__, rp->pdev->irq);
 
 	rc = alloc_ring(dev);
 	if (rc) {
@@ -1415,10 +1414,9 @@ static int rhine_open(struct net_device *dev)
 	rhine_chip_reset(dev);
 	init_registers(dev);
 	if (debug > 2)
-		printk(KERN_DEBUG "%s: Done rhine_open(), status %4.4x "
-		       "MII status: %4.4x.\n",
-		       dev->name, ioread16(ioaddr + ChipCmd),
-		       mdio_read(dev, rp->mii_if.phy_id, MII_BMSR));
+		netdev_dbg(dev, "%s() Done - status %04x MII status: %04x\n",
+			   __func__, ioread16(ioaddr + ChipCmd),
+			   mdio_read(dev, rp->mii_if.phy_id, MII_BMSR));
 
 	netif_start_queue(dev);
 
@@ -1461,10 +1459,9 @@ static void rhine_tx_timeout(struct net_device *dev)
 	struct rhine_private *rp = netdev_priv(dev);
 	void __iomem *ioaddr = rp->base;
 
-	printk(KERN_WARNING "%s: Transmit timed out, status %4.4x, PHY status "
-	       "%4.4x, resetting...\n",
-	       dev->name, ioread16(ioaddr + IntrStatus),
-	       mdio_read(dev, rp->mii_if.phy_id, MII_BMSR));
+	netdev_warn(dev, "Transmit timed out, status %04x, PHY status %04x, resetting...\n",
+		    ioread16(ioaddr + IntrStatus),
+		    mdio_read(dev, rp->mii_if.phy_id, MII_BMSR));
 
 	schedule_work(&rp->reset_task);
 }
@@ -1551,8 +1548,8 @@ static netdev_tx_t rhine_start_tx(struct sk_buff *skb,
 	spin_unlock_irqrestore(&rp->lock, flags);
 
 	if (debug > 4) {
-		printk(KERN_DEBUG "%s: Transmit frame #%d queued in slot %d.\n",
-		       dev->name, rp->cur_tx-1, entry);
+		netdev_dbg(dev, "Transmit frame #%d queued in slot %d\n",
+			   rp->cur_tx-1, entry);
 	}
 	return NETDEV_TX_OK;
 }
@@ -1578,8 +1575,8 @@ static irqreturn_t rhine_interrupt(int irq, void *dev_instance)
 		IOSYNC;
 
 		if (debug > 4)
-			printk(KERN_DEBUG "%s: Interrupt, status %8.8x.\n",
-			       dev->name, intr_status);
+			netdev_dbg(dev, "Interrupt, status %08x\n",
+				   intr_status);
 
 		if (intr_status & (IntrRxDone | IntrRxErr | IntrRxDropped |
 				   IntrRxWakeUp | IntrRxEmpty | IntrRxNoBuf)) {
@@ -1597,9 +1594,9 @@ static irqreturn_t rhine_interrupt(int irq, void *dev_instance)
 				RHINE_WAIT_FOR(!(ioread8(ioaddr+ChipCmd) & CmdTxOn));
 				if (debug > 2 &&
 				    ioread8(ioaddr+ChipCmd) & CmdTxOn)
-					printk(KERN_WARNING "%s: "
-					       "rhine_interrupt() Tx engine "
-					       "still on.\n", dev->name);
+					netdev_warn(dev,
+						    "%s: Tx engine still on\n",
+						    __func__);
 			}
 			rhine_tx(dev);
 		}
@@ -1611,16 +1608,15 @@ static irqreturn_t rhine_interrupt(int irq, void *dev_instance)
 			rhine_error(dev, intr_status);
 
 		if (--boguscnt < 0) {
-			printk(KERN_WARNING "%s: Too much work at interrupt, "
-			       "status=%#8.8x.\n",
-			       dev->name, intr_status);
+			netdev_warn(dev, "Too much work at interrupt, status=%#08x\n",
+				    intr_status);
 			break;
 		}
 	}
 
 	if (debug > 3)
-		printk(KERN_DEBUG "%s: exiting interrupt, status=%8.8x.\n",
-		       dev->name, ioread16(ioaddr + IntrStatus));
+		netdev_dbg(dev, "exiting interrupt, status=%08x\n",
+			   ioread16(ioaddr + IntrStatus));
 	return IRQ_RETVAL(handled);
 }
 
@@ -1637,15 +1633,14 @@ static void rhine_tx(struct net_device *dev)
 	while (rp->dirty_tx != rp->cur_tx) {
 		txstatus = le32_to_cpu(rp->tx_ring[entry].tx_status);
 		if (debug > 6)
-			printk(KERN_DEBUG "Tx scavenge %d status %8.8x.\n",
-			       entry, txstatus);
+			netdev_dbg(dev, "Tx scavenge %d status %08x\n",
+				   entry, txstatus);
 		if (txstatus & DescOwn)
 			break;
 		if (txstatus & 0x8000) {
 			if (debug > 1)
-				printk(KERN_DEBUG "%s: Transmit error, "
-				       "Tx status %8.8x.\n",
-				       dev->name, txstatus);
+				netdev_dbg(dev, "Transmit error, Tx status %08x\n",
+					   txstatus);
 			dev->stats.tx_errors++;
 			if (txstatus & 0x0400)
 				dev->stats.tx_carrier_errors++;
@@ -1668,9 +1663,9 @@ static void rhine_tx(struct net_device *dev)
 			else
 				dev->stats.collisions += txstatus & 0x0F;
 			if (debug > 6)
-				printk(KERN_DEBUG "collisions: %1.1x:%1.1x\n",
-				       (txstatus >> 3) & 0xF,
-				       txstatus & 0xF);
+				netdev_dbg(dev, "collisions: %1.1x:%1.1x\n",
+					   (txstatus >> 3) & 0xF,
+					   txstatus & 0xF);
 			dev->stats.tx_bytes += rp->tx_skbuff[entry]->len;
 			dev->stats.tx_packets++;
 		}
@@ -1714,9 +1709,9 @@ static int rhine_rx(struct net_device *dev, int limit)
 	int entry = rp->cur_rx % RX_RING_SIZE;
 
 	if (debug > 4) {
-		printk(KERN_DEBUG "%s: rhine_rx(), entry %d status %8.8x.\n",
-		       dev->name, entry,
-		       le32_to_cpu(rp->rx_head_desc->rx_status));
+		netdev_dbg(dev, "%s(), entry %d status %08x\n",
+			   __func__, entry,
+			   le32_to_cpu(rp->rx_head_desc->rx_status));
 	}
 
 	/* If EOP is set on the next entry, it's a new packet. Send it up. */
@@ -1730,26 +1725,26 @@ static int rhine_rx(struct net_device *dev, int limit)
 			break;
 
 		if (debug > 4)
-			printk(KERN_DEBUG "rhine_rx() status is %8.8x.\n",
-			       desc_status);
+			netdev_dbg(dev, "%s() status is %08x\n",
+				   __func__, desc_status);
 
 		if ((desc_status & (RxWholePkt | RxErr)) != RxWholePkt) {
 			if ((desc_status & RxWholePkt) != RxWholePkt) {
-				printk(KERN_WARNING "%s: Oversized Ethernet "
-				       "frame spanned multiple buffers, entry "
-				       "%#x length %d status %8.8x!\n",
-				       dev->name, entry, data_size,
-				       desc_status);
-				printk(KERN_WARNING "%s: Oversized Ethernet "
-				       "frame %p vs %p.\n", dev->name,
-				       rp->rx_head_desc, &rp->rx_ring[entry]);
+				netdev_warn(dev,
+	"Oversized Ethernet frame spanned multiple buffers, "
+	"entry %#x length %d status %08x!\n",
+					    entry, data_size,
+					    desc_status);
+				netdev_warn(dev,
+					    "Oversized Ethernet frame %p vs %p\n",
+					    rp->rx_head_desc,
+					    &rp->rx_ring[entry]);
 				dev->stats.rx_length_errors++;
 			} else if (desc_status & RxErr) {
 				/* There was a error. */
 				if (debug > 2)
-					printk(KERN_DEBUG "rhine_rx() Rx "
-					       "error was %8.8x.\n",
-					       desc_status);
+					netdev_dbg(dev, "%s() Rx error was %08x\n",
+						   __func__, desc_status);
 				dev->stats.rx_errors++;
 				if (desc_status & 0x0030)
 					dev->stats.rx_length_errors++;
@@ -1791,9 +1786,7 @@ static int rhine_rx(struct net_device *dev, int limit)
 			} else {
 				skb = rp->rx_skbuff[entry];
 				if (skb == NULL) {
-					printk(KERN_ERR "%s: Inconsistent Rx "
-					       "descriptor chain.\n",
-					       dev->name);
+					netdev_err(dev, "Inconsistent Rx descriptor chain\n");
 					break;
 				}
 				rp->rx_skbuff[entry] = NULL;
@@ -1886,9 +1879,8 @@ static void rhine_restart_tx(struct net_device *dev) {
 	else {
 		/* This should never happen */
 		if (debug > 1)
-			printk(KERN_WARNING "%s: rhine_restart_tx() "
-			       "Another error occurred %8.8x.\n",
-			       dev->name, intr_status);
+			netdev_warn(dev, "%s() Another error occurred %08x\n",
+				   __func__, intr_status);
 	}
 
 }
@@ -1909,21 +1901,19 @@ static void rhine_error(struct net_device *dev, int intr_status)
 	}
 	if (intr_status & IntrTxAborted) {
 		if (debug > 1)
-			printk(KERN_INFO "%s: Abort %8.8x, frame dropped.\n",
-			       dev->name, intr_status);
+			netdev_info(dev, "Abort %08x, frame dropped\n",
+				    intr_status);
 	}
 	if (intr_status & IntrTxUnderrun) {
 		if (rp->tx_thresh < 0xE0)
 			BYTE_REG_BITS_SET((rp->tx_thresh += 0x20), 0x80, ioaddr + TxConfig);
 		if (debug > 1)
-			printk(KERN_INFO "%s: Transmitter underrun, Tx "
-			       "threshold now %2.2x.\n",
-			       dev->name, rp->tx_thresh);
+			netdev_info(dev, "Transmitter underrun, Tx threshold now %02x\n",
+				    rp->tx_thresh);
 	}
 	if (intr_status & IntrTxDescRace) {
 		if (debug > 2)
-			printk(KERN_INFO "%s: Tx descriptor write-back race.\n",
-			       dev->name);
+			netdev_info(dev, "Tx descriptor write-back race\n");
 	}
 	if ((intr_status & IntrTxError) &&
 	    (intr_status & (IntrTxAborted |
@@ -1932,9 +1922,8 @@ static void rhine_error(struct net_device *dev, int intr_status)
 			BYTE_REG_BITS_SET((rp->tx_thresh += 0x20), 0x80, ioaddr + TxConfig);
 		}
 		if (debug > 1)
-			printk(KERN_INFO "%s: Unspecified error. Tx "
-			       "threshold now %2.2x.\n",
-			       dev->name, rp->tx_thresh);
+			netdev_info(dev, "Unspecified error. Tx threshold now %02x\n",
+				    rp->tx_thresh);
 	}
 	if (intr_status & (IntrTxAborted | IntrTxUnderrun | IntrTxDescRace |
 			   IntrTxError))
@@ -1944,8 +1933,8 @@ static void rhine_error(struct net_device *dev, int intr_status)
 			    IntrTxError | IntrTxAborted | IntrNormalSummary |
 			    IntrTxDescRace)) {
 		if (debug > 1)
-			printk(KERN_ERR "%s: Something Wicked happened! "
-			       "%8.8x.\n", dev->name, intr_status);
+			netdev_err(dev, "Something Wicked happened! %08x\n",
+				   intr_status);
 	}
 
 	spin_unlock(&rp->lock);
@@ -2145,9 +2134,8 @@ static int rhine_close(struct net_device *dev)
 	spin_lock_irq(&rp->lock);
 
 	if (debug > 1)
-		printk(KERN_DEBUG "%s: Shutting down ethercard, "
-		       "status was %4.4x.\n",
-		       dev->name, ioread16(ioaddr + ChipCmd));
+		netdev_dbg(dev, "Shutting down ethercard, status was %04x\n",
+			   ioread16(ioaddr + ChipCmd));
 
 	/* Switch to loopback mode to avoid hardware races. */
 	iowrite8(rp->tx_thresh | 0x02, ioaddr + TxConfig);
@@ -2265,12 +2253,12 @@ static int rhine_resume(struct pci_dev *pdev)
 		return 0;
 
 	if (request_irq(dev->irq, rhine_interrupt, IRQF_SHARED, dev->name, dev))
-		printk(KERN_ERR "via-rhine %s: request_irq failed\n", dev->name);
+		netdev_err(dev, "request_irq failed\n");
 
 	ret = pci_set_power_state(pdev, PCI_D0);
 	if (debug > 1)
-		printk(KERN_INFO "%s: Entering power state D0 %s (%d).\n",
-			dev->name, ret ? "failed" : "succeeded", ret);
+		netdev_info(dev, "Entering power state D0 %s (%d)\n",
+			    ret ? "failed" : "succeeded", ret);
 
 	pci_restore_state(pdev);
 
@@ -2326,17 +2314,15 @@ static int __init rhine_init(void)
 {
 /* when a module, this is printed whether or not devices are found in probe */
 #ifdef MODULE
-	printk(version);
+	pr_info("%s\n", version);
 #endif
 	if (dmi_check_system(rhine_dmi_table)) {
 		/* these BIOSes fail at PXE boot if chip is in D3 */
 		avoid_D3 = 1;
-		printk(KERN_WARNING "%s: Broken BIOS detected, avoid_D3 "
-				    "enabled.\n",
-		       DRV_NAME);
+		pr_warn("Broken BIOS detected, avoid_D3 enabled\n");
 	}
 	else if (avoid_D3)
-		printk(KERN_INFO "%s: avoid_D3 set.\n", DRV_NAME);
+		pr_info("avoid_D3 set\n");
 
 	return pci_register_driver(&rhine_driver);
 }
-- 
1.7.4.2.g597a6.dirty

