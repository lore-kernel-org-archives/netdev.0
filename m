From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next #2 32/39] epic100: stop using net_device.{base_addr, irq} and convert to __iomem.
Date: Fri,  6 Apr 2012 12:06:46 +0200
Message-ID: <6b7afbabfb5dc03aca2fea47cae8db27239bb589.1333704409.git.romieu@fr.zoreil.com>
References: <1333704408.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:43473 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755926Ab2DFKKj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Apr 2012 06:10:39 -0400
In-Reply-To: <1333704408.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/smsc/epic100.c |  403 +++++++++++++++++------------------
 1 files changed, 201 insertions(+), 202 deletions(-)

diff --git a/drivers/net/ethernet/smsc/epic100.c b/drivers/net/ethernet/smsc/epic100.c
index 2a662e6..1710b4b 100644
--- a/drivers/net/ethernet/smsc/epic100.c
+++ b/drivers/net/ethernet/smsc/epic100.c
@@ -146,6 +146,12 @@ enum chip_capability_flags { MII_PWRDWN=1, TYPE2_INTR=2, NO_MII=4 };
 #define EPIC_TOTAL_SIZE 0x100
 #define USE_IO_OPS 1
 
+#ifdef USE_IO_OPS
+#define EPIC_BAR	0
+#else
+#define EPIC_BAR	1
+#endif
+
 typedef enum {
 	SMSC_83C170_0,
 	SMSC_83C170,
@@ -176,21 +182,11 @@ static DEFINE_PCI_DEVICE_TABLE(epic_pci_tbl) = {
 };
 MODULE_DEVICE_TABLE (pci, epic_pci_tbl);
 
-
-#ifndef USE_IO_OPS
-#undef inb
-#undef inw
-#undef inl
-#undef outb
-#undef outw
-#undef outl
-#define inb readb
-#define inw readw
-#define inl readl
-#define outb writeb
-#define outw writew
-#define outl writel
-#endif
+#define ew16(reg, val)	iowrite16(val, ioaddr + (reg))
+#define ew32(reg, val)	iowrite32(val, ioaddr + (reg))
+#define er8(reg)	ioread8(ioaddr + (reg))
+#define er16(reg)	ioread16(ioaddr + (reg))
+#define er32(reg)	ioread32(ioaddr + (reg))
 
 /* Offsets to registers, using the (ugh) SMC names. */
 enum epic_registers {
@@ -275,6 +271,7 @@ struct epic_private {
 	u32 irq_mask;
 	unsigned int rx_buf_sz;				/* Based on MTU+slack. */
 
+	void __iomem *ioaddr;
 	struct pci_dev *pci_dev;			/* PCI bus location. */
 	int chip_id, chip_flags;
 
@@ -290,7 +287,7 @@ struct epic_private {
 };
 
 static int epic_open(struct net_device *dev);
-static int read_eeprom(long ioaddr, int location);
+static int read_eeprom(struct epic_private *, int);
 static int mdio_read(struct net_device *dev, int phy_id, int location);
 static void mdio_write(struct net_device *dev, int phy_id, int loc, int val);
 static void epic_restart(struct net_device *dev);
@@ -321,11 +318,11 @@ static const struct net_device_ops epic_netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
-static int __devinit epic_init_one (struct pci_dev *pdev,
-				    const struct pci_device_id *ent)
+static int __devinit epic_init_one(struct pci_dev *pdev,
+				   const struct pci_device_id *ent)
 {
 	static int card_idx = -1;
-	long ioaddr;
+	void __iomem *ioaddr;
 	int chip_idx = (int) ent->driver_data;
 	int irq;
 	struct net_device *dev;
@@ -368,19 +365,15 @@ static int __devinit epic_init_one (struct pci_dev *pdev,
 
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
-#ifdef USE_IO_OPS
-	ioaddr = pci_resource_start (pdev, 0);
-#else
-	ioaddr = pci_resource_start (pdev, 1);
-	ioaddr = (long) pci_ioremap_bar(pdev, 1);
+	ioaddr = pci_iomap(pdev, EPIC_BAR, 0);
 	if (!ioaddr) {
 		dev_err(&pdev->dev, "ioremap failed\n");
 		goto err_out_free_netdev;
 	}
-#endif
 
 	pci_set_drvdata(pdev, dev);
 	ep = netdev_priv(dev);
+	ep->ioaddr = ioaddr;
 	ep->mii.dev = dev;
 	ep->mii.mdio_read = mdio_read;
 	ep->mii.mdio_write = mdio_write;
@@ -409,34 +402,31 @@ static int __devinit epic_init_one (struct pci_dev *pdev,
 			duplex = full_duplex[card_idx];
 	}
 
-	dev->base_addr = ioaddr;
-	dev->irq = irq;
-
 	spin_lock_init(&ep->lock);
 	spin_lock_init(&ep->napi_lock);
 	ep->reschedule_in_poll = 0;
 
 	/* Bring the chip out of low-power mode. */
-	outl(0x4200, ioaddr + GENCTL);
+	ew32(GENCTL, 0x4200);
 	/* Magic?!  If we don't set this bit the MII interface won't work. */
 	/* This magic is documented in SMSC app note 7.15 */
 	for (i = 16; i > 0; i--)
-		outl(0x0008, ioaddr + TEST1);
+		ew32(TEST1, 0x0008);
 
 	/* Turn on the MII transceiver. */
-	outl(0x12, ioaddr + MIICfg);
+	ew32(MIICfg, 0x12);
 	if (chip_idx == 1)
-		outl((inl(ioaddr + NVCTL) & ~0x003C) | 0x4800, ioaddr + NVCTL);
-	outl(0x0200, ioaddr + GENCTL);
+		ew32(NVCTL, (er32(NVCTL) & ~0x003c) | 0x4800);
+	ew32(GENCTL, 0x0200);
 
 	/* Note: the '175 does not have a serial EEPROM. */
 	for (i = 0; i < 3; i++)
-		((__le16 *)dev->dev_addr)[i] = cpu_to_le16(inw(ioaddr + LAN0 + i*4));
+		((__le16 *)dev->dev_addr)[i] = cpu_to_le16(er16(LAN0 + i*4));
 
 	if (debug > 2) {
 		dev_printk(KERN_DEBUG, &pdev->dev, "EEPROM contents:\n");
 		for (i = 0; i < 64; i++)
-			printk(" %4.4x%s", read_eeprom(ioaddr, i),
+			printk(" %4.4x%s", read_eeprom(ep, i),
 				   i % 16 == 15 ? "\n" : "");
 	}
 
@@ -481,8 +471,8 @@ static int __devinit epic_init_one (struct pci_dev *pdev,
 
 	/* Turn off the MII xcvr (175 only!), leave the chip in low-power mode. */
 	if (ep->chip_flags & MII_PWRDWN)
-		outl(inl(ioaddr + NVCTL) & ~0x483C, ioaddr + NVCTL);
-	outl(0x0008, ioaddr + GENCTL);
+		ew32(NVCTL, er32(NVCTL) & ~0x483c);
+	ew32(GENCTL, 0x0008);
 
 	/* The lower four bits are the media type. */
 	if (duplex) {
@@ -501,8 +491,9 @@ static int __devinit epic_init_one (struct pci_dev *pdev,
 	if (ret < 0)
 		goto err_out_unmap_rx;
 
-	printk(KERN_INFO "%s: %s at %#lx, IRQ %d, %pM\n",
-	       dev->name, pci_id_tbl[chip_idx].name, ioaddr, dev->irq,
+	printk(KERN_INFO "%s: %s at %lx, IRQ %d, %pM\n",
+	       dev->name, pci_id_tbl[chip_idx].name,
+	       (long)pci_resource_start(pdev, EPIC_BAR), pdev->irq,
 	       dev->dev_addr);
 
 out:
@@ -513,10 +504,8 @@ err_out_unmap_rx:
 err_out_unmap_tx:
 	pci_free_consistent(pdev, TX_TOTAL_SIZE, ep->tx_ring, ep->tx_ring_dma);
 err_out_iounmap:
-#ifndef USE_IO_OPS
-	iounmap(ioaddr);
+	pci_iounmap(pdev, ioaddr);
 err_out_free_netdev:
-#endif
 	free_netdev(dev);
 err_out_free_res:
 	pci_release_regions(pdev);
@@ -540,7 +529,7 @@ err_out_disable:
    This serves to flush the operation to the PCI bus.
  */
 
-#define eeprom_delay()	inl(ee_addr)
+#define eeprom_delay()	er32(EECTL)
 
 /* The EEPROM commands include the alway-set leading bit. */
 #define EE_WRITE_CMD	(5 << 6)
@@ -550,67 +539,67 @@ err_out_disable:
 
 static void epic_disable_int(struct net_device *dev, struct epic_private *ep)
 {
-	long ioaddr = dev->base_addr;
+	void __iomem *ioaddr = ep->ioaddr;
 
-	outl(0x00000000, ioaddr + INTMASK);
+	ew32(INTMASK, 0x00000000);
 }
 
-static inline void __epic_pci_commit(long ioaddr)
+static inline void __epic_pci_commit(void __iomem *ioaddr)
 {
 #ifndef USE_IO_OPS
-	inl(ioaddr + INTMASK);
+	er32(INTMASK);
 #endif
 }
 
 static inline void epic_napi_irq_off(struct net_device *dev,
 				     struct epic_private *ep)
 {
-	long ioaddr = dev->base_addr;
+	void __iomem *ioaddr = ep->ioaddr;
 
-	outl(ep->irq_mask & ~EpicNapiEvent, ioaddr + INTMASK);
+	ew32(INTMASK, ep->irq_mask & ~EpicNapiEvent);
 	__epic_pci_commit(ioaddr);
 }
 
 static inline void epic_napi_irq_on(struct net_device *dev,
 				    struct epic_private *ep)
 {
-	long ioaddr = dev->base_addr;
+	void __iomem *ioaddr = ep->ioaddr;
 
 	/* No need to commit possible posted write */
-	outl(ep->irq_mask | EpicNapiEvent, ioaddr + INTMASK);
+	ew32(INTMASK, ep->irq_mask | EpicNapiEvent);
 }
 
-static int __devinit read_eeprom(long ioaddr, int location)
+static int __devinit read_eeprom(struct epic_private *ep, int location)
 {
+	void __iomem *ioaddr = ep->ioaddr;
 	int i;
 	int retval = 0;
-	long ee_addr = ioaddr + EECTL;
 	int read_cmd = location |
-		(inl(ee_addr) & 0x40 ? EE_READ64_CMD : EE_READ256_CMD);
+		(er32(EECTL) & 0x40 ? EE_READ64_CMD : EE_READ256_CMD);
 
-	outl(EE_ENB & ~EE_CS, ee_addr);
-	outl(EE_ENB, ee_addr);
+	ew32(EECTL, EE_ENB & ~EE_CS);
+	ew32(EECTL, EE_ENB);
 
 	/* Shift the read command bits out. */
 	for (i = 12; i >= 0; i--) {
 		short dataval = (read_cmd & (1 << i)) ? EE_WRITE_1 : EE_WRITE_0;
-		outl(EE_ENB | dataval, ee_addr);
+		ew32(EECTL, EE_ENB | dataval);
 		eeprom_delay();
-		outl(EE_ENB | dataval | EE_SHIFT_CLK, ee_addr);
+		ew32(EECTL, EE_ENB | dataval | EE_SHIFT_CLK);
 		eeprom_delay();
 	}
-	outl(EE_ENB, ee_addr);
+	ew32(EECTL, EE_ENB);
 
 	for (i = 16; i > 0; i--) {
-		outl(EE_ENB | EE_SHIFT_CLK, ee_addr);
+		ew32(EECTL, EE_ENB | EE_SHIFT_CLK);
 		eeprom_delay();
-		retval = (retval << 1) | ((inl(ee_addr) & EE_DATA_READ) ? 1 : 0);
-		outl(EE_ENB, ee_addr);
+		retval = (retval << 1) | ((er32(EECTL) & EE_DATA_READ) ? 1 : 0);
+		ew32(EECTL, EE_ENB);
 		eeprom_delay();
 	}
 
 	/* Terminate the EEPROM access. */
-	outl(EE_ENB & ~EE_CS, ee_addr);
+	ew32(EECTL, EE_ENB & ~EE_CS);
 	return retval;
 }
 
@@ -618,22 +607,23 @@ static int __devinit read_eeprom(long ioaddr, int location)
 #define MII_WRITEOP		2
 static int mdio_read(struct net_device *dev, int phy_id, int location)
 {
-	long ioaddr = dev->base_addr;
+	struct epic_private *ep = netdev_priv(dev);
+	void __iomem *ioaddr = ep->ioaddr;
 	int read_cmd = (phy_id << 9) | (location << 4) | MII_READOP;
 	int i;
 
-	outl(read_cmd, ioaddr + MIICtrl);
+	ew32(MIICtrl, read_cmd);
 	/* Typical operation takes 25 loops. */
 	for (i = 400; i > 0; i--) {
 		barrier();
-		if ((inl(ioaddr + MIICtrl) & MII_READOP) == 0) {
+		if ((er32(MIICtrl) & MII_READOP) == 0) {
 			/* Work around read failure bug. */
 			if (phy_id == 1 && location < 6 &&
-			    inw(ioaddr + MIIData) == 0xffff) {
-				outl(read_cmd, ioaddr + MIICtrl);
+			    er16(MIIData) == 0xffff) {
+				ew32(MIICtrl, read_cmd);
 				continue;
 			}
-			return inw(ioaddr + MIIData);
+			return er16(MIIData);
 		}
 	}
 	return 0xffff;
@@ -641,14 +631,15 @@ static int mdio_read(struct net_device *dev, int phy_id, int location)
 
 static void mdio_write(struct net_device *dev, int phy_id, int loc, int value)
 {
-	long ioaddr = dev->base_addr;
+	struct epic_private *ep = netdev_priv(dev);
+	void __iomem *ioaddr = ep->ioaddr;
 	int i;
 
-	outw(value, ioaddr + MIIData);
-	outl((phy_id << 9) | (loc << 4) | MII_WRITEOP, ioaddr + MIICtrl);
+	ew16(MIIData, value);
+	ew32(MIICtrl, (phy_id << 9) | (loc << 4) | MII_WRITEOP);
 	for (i = 10000; i > 0; i--) {
 		barrier();
-		if ((inl(ioaddr + MIICtrl) & MII_WRITEOP) == 0)
+		if ((er32(MIICtrl) & MII_WRITEOP) == 0)
 			break;
 	}
 }
@@ -657,25 +648,26 @@ static void mdio_write(struct net_device *dev, int phy_id, int loc, int value)
 static int epic_open(struct net_device *dev)
 {
 	struct epic_private *ep = netdev_priv(dev);
-	long ioaddr = dev->base_addr;
-	int i;
-	int retval;
+	void __iomem *ioaddr = ep->ioaddr;
+	const int irq = ep->pci_dev->irq;
+	int rc, i;
 
 	/* Soft reset the chip. */
-	outl(0x4001, ioaddr + GENCTL);
+	ew32(GENCTL, 0x4001);
 
 	napi_enable(&ep->napi);
-	if ((retval = request_irq(dev->irq, epic_interrupt, IRQF_SHARED, dev->name, dev))) {
+	rc = request_irq(irq, epic_interrupt, IRQF_SHARED, dev->name, dev);
+	if (rc < 0) {
 		napi_disable(&ep->napi);
-		return retval;
+		return rc;
 	}
 
 	epic_init_ring(dev);
 
-	outl(0x4000, ioaddr + GENCTL);
+	ew32(GENCTL, 0x4000);
 	/* This magic is documented in SMSC app note 7.15 */
 	for (i = 16; i > 0; i--)
-		outl(0x0008, ioaddr + TEST1);
+		ew32(TEST1, 0x0008);
 
 	/* Pull the chip out of low-power mode, enable interrupts, and set for
 	   PCI read multiple.  The MIIcfg setting and strange write order are
@@ -683,29 +675,29 @@ static int epic_open(struct net_device *dev)
 	   wiring on the Ositech CardBus card.
 	*/
 #if 0
-	outl(dev->if_port == 1 ? 0x13 : 0x12, ioaddr + MIICfg);
+	ew32(MIICfg, dev->if_port == 1 ? 0x13 : 0x12);
 #endif
 	if (ep->chip_flags & MII_PWRDWN)
-		outl((inl(ioaddr + NVCTL) & ~0x003C) | 0x4800, ioaddr + NVCTL);
+		ew32(NVCTL, (er32(NVCTL) & ~0x003c) | 0x4800);
 
 	/* Tell the chip to byteswap descriptors on big-endian hosts */
 #ifdef __BIG_ENDIAN
-	outl(0x4432 | (RX_FIFO_THRESH<<8), ioaddr + GENCTL);
-	inl(ioaddr + GENCTL);
-	outl(0x0432 | (RX_FIFO_THRESH<<8), ioaddr + GENCTL);
+	ew32(GENCTL, 0x4432 | (RX_FIFO_THRESH << 8));
+	er32(GENCTL);
+	ew32(GENCTL, 0x0432 | (RX_FIFO_THRESH << 8));
 #else
-	outl(0x4412 | (RX_FIFO_THRESH<<8), ioaddr + GENCTL);
-	inl(ioaddr + GENCTL);
-	outl(0x0412 | (RX_FIFO_THRESH<<8), ioaddr + GENCTL);
+	ew32(GENCTL, 0x4412 | (RX_FIFO_THRESH << 8));
+	er32(GENCTL);
+	ew32(GENCTL, 0x0412 | (RX_FIFO_THRESH << 8));
 #endif
 
 	udelay(20); /* Looks like EPII needs that if you want reliable RX init. FIXME: pci posting bug? */
 
 	for (i = 0; i < 3; i++)
-		outl(le16_to_cpu(((__le16*)dev->dev_addr)[i]), ioaddr + LAN0 + i*4);
+		ew32(LAN0 + i*4, le16_to_cpu(((__le16*)dev->dev_addr)[i]));
 
 	ep->tx_threshold = TX_FIFO_THRESH;
-	outl(ep->tx_threshold, ioaddr + TxThresh);
+	ew32(TxThresh, ep->tx_threshold);
 
 	if (media2miictl[dev->if_port & 15]) {
 		if (ep->mii_phy_cnt)
@@ -731,26 +723,27 @@ static int epic_open(struct net_device *dev)
 		}
 	}
 
-	outl(ep->mii.full_duplex ? 0x7F : 0x79, ioaddr + TxCtrl);
-	outl(ep->rx_ring_dma, ioaddr + PRxCDAR);
-	outl(ep->tx_ring_dma, ioaddr + PTxCDAR);
+	ew32(TxCtrl, ep->mii.full_duplex ? 0x7f : 0x79);
+	ew32(PRxCDAR, ep->rx_ring_dma);
+	ew32(PTxCDAR, ep->tx_ring_dma);
 
 	/* Start the chip's Rx process. */
 	set_rx_mode(dev);
-	outl(StartRx | RxQueued, ioaddr + COMMAND);
+	ew32(COMMAND, StartRx | RxQueued);
 
 	netif_start_queue(dev);
 
 	/* Enable interrupts by setting the interrupt mask. */
-	outl((ep->chip_flags & TYPE2_INTR ? PCIBusErr175 : PCIBusErr170)
-		 | CntFull | TxUnderrun
-		 | RxError | RxHeader | EpicNapiEvent, ioaddr + INTMASK);
-
-	if (debug > 1)
-		printk(KERN_DEBUG "%s: epic_open() ioaddr %lx IRQ %d status %4.4x "
-			   "%s-duplex.\n",
-			   dev->name, ioaddr, dev->irq, (int)inl(ioaddr + GENCTL),
-			   ep->mii.full_duplex ? "full" : "half");
+	ew32(INTMASK, RxError | RxHeader | EpicNapiEvent | CntFull |
+	     ((ep->chip_flags & TYPE2_INTR) ? PCIBusErr175 : PCIBusErr170) |
+	     TxUnderrun);
+
+	if (debug > 1) {
+		printk(KERN_DEBUG "%s: epic_open() ioaddr %p IRQ %d "
+		       "status %4.4x %s-duplex.\n",
+		       dev->name, ioaddr, irq, er32(GENCTL),
+		       ep->mii.full_duplex ? "full" : "half");
+	}
 
 	/* Set the timer to switch to check for link beat and perhaps switch
 	   to an alternate media type. */
@@ -760,27 +753,29 @@ static int epic_open(struct net_device *dev)
 	ep->timer.function = epic_timer;				/* timer handler */
 	add_timer(&ep->timer);
 
-	return 0;
+	return rc;
 }
 
 /* Reset the chip to refrom a PCI transaction error.
    This may occur at interrupt time. */
 static void epic_pause(struct net_device *dev)
 {
-	long ioaddr = dev->base_addr;
+	struct net_device_stats *stats = &dev->stats;
+	struct epic_private *ep = netdev_priv(dev);
+	void __iomem *ioaddr = ep->ioaddr;
 
 	netif_stop_queue (dev);
 
 	/* Disable interrupts by clearing the interrupt mask. */
-	outl(0x00000000, ioaddr + INTMASK);
+	ew32(INTMASK, 0x00000000);
 	/* Stop the chip's Tx and Rx DMA processes. */
-	outw(StopRx | StopTxDMA | StopRxDMA, ioaddr + COMMAND);
+	ew16(COMMAND, StopRx | StopTxDMA | StopRxDMA);
 
 	/* Update the error counts. */
-	if (inw(ioaddr + COMMAND) != 0xffff) {
-		dev->stats.rx_missed_errors += inb(ioaddr + MPCNT);
-		dev->stats.rx_frame_errors += inb(ioaddr + ALICNT);
-		dev->stats.rx_crc_errors += inb(ioaddr + CRCCNT);
+	if (er16(COMMAND) != 0xffff) {
+		stats->rx_missed_errors	+= er8(MPCNT);
+		stats->rx_frame_errors	+= er8(ALICNT);
+		stats->rx_crc_errors	+= er8(CRCCNT);
 	}
 
 	/* Remove the packets on the Rx queue. */
@@ -789,12 +784,12 @@ static void epic_pause(struct net_device *dev)
 
 static void epic_restart(struct net_device *dev)
 {
-	long ioaddr = dev->base_addr;
 	struct epic_private *ep = netdev_priv(dev);
+	void __iomem *ioaddr = ep->ioaddr;
 	int i;
 
 	/* Soft reset the chip. */
-	outl(0x4001, ioaddr + GENCTL);
+	ew32(GENCTL, 0x4001);
 
 	printk(KERN_DEBUG "%s: Restarting the EPIC chip, Rx %d/%d Tx %d/%d.\n",
 		   dev->name, ep->cur_rx, ep->dirty_rx, ep->dirty_tx, ep->cur_tx);
@@ -802,47 +797,46 @@ static void epic_restart(struct net_device *dev)
 
 	/* This magic is documented in SMSC app note 7.15 */
 	for (i = 16; i > 0; i--)
-		outl(0x0008, ioaddr + TEST1);
+		ew32(TEST1, 0x0008);
 
 #ifdef __BIG_ENDIAN
-	outl(0x0432 | (RX_FIFO_THRESH<<8), ioaddr + GENCTL);
+	ew32(GENCTL, 0x0432 | (RX_FIFO_THRESH << 8));
 #else
-	outl(0x0412 | (RX_FIFO_THRESH<<8), ioaddr + GENCTL);
+	ew32(GENCTL, 0x0412 | (RX_FIFO_THRESH << 8));
 #endif
-	outl(dev->if_port == 1 ? 0x13 : 0x12, ioaddr + MIICfg);
+	ew32(MIICfg, dev->if_port == 1 ? 0x13 : 0x12);
 	if (ep->chip_flags & MII_PWRDWN)
-		outl((inl(ioaddr + NVCTL) & ~0x003C) | 0x4800, ioaddr + NVCTL);
+		ew32(NVCTL, (er32(NVCTL) & ~0x003c) | 0x4800);
 
 	for (i = 0; i < 3; i++)
-		outl(le16_to_cpu(((__le16*)dev->dev_addr)[i]), ioaddr + LAN0 + i*4);
+		ew32(LAN0 + i*4, le16_to_cpu(((__le16*)dev->dev_addr)[i]));
 
 	ep->tx_threshold = TX_FIFO_THRESH;
-	outl(ep->tx_threshold, ioaddr + TxThresh);
-	outl(ep->mii.full_duplex ? 0x7F : 0x79, ioaddr + TxCtrl);
-	outl(ep->rx_ring_dma + (ep->cur_rx%RX_RING_SIZE)*
-		sizeof(struct epic_rx_desc), ioaddr + PRxCDAR);
-	outl(ep->tx_ring_dma + (ep->dirty_tx%TX_RING_SIZE)*
-		 sizeof(struct epic_tx_desc), ioaddr + PTxCDAR);
+	ew32(TxThresh, ep->tx_threshold);
+	ew32(TxCtrl, ep->mii.full_duplex ? 0x7f : 0x79);
+	ew32(PRxCDAR, ep->rx_ring_dma +
+	     (ep->cur_rx % RX_RING_SIZE) * sizeof(struct epic_rx_desc));
+	ew32(PTxCDAR, ep->tx_ring_dma +
+	     (ep->dirty_tx % TX_RING_SIZE) * sizeof(struct epic_tx_desc));
 
 	/* Start the chip's Rx process. */
 	set_rx_mode(dev);
-	outl(StartRx | RxQueued, ioaddr + COMMAND);
+	ew32(COMMAND, StartRx | RxQueued);
 
 	/* Enable interrupts by setting the interrupt mask. */
-	outl((ep->chip_flags & TYPE2_INTR ? PCIBusErr175 : PCIBusErr170)
-		 | CntFull | TxUnderrun
-		 | RxError | RxHeader | EpicNapiEvent, ioaddr + INTMASK);
+	ew32(INTMASK, RxError | RxHeader | EpicNapiEvent | CntFull |
+	     ((ep->chip_flags & TYPE2_INTR) ? PCIBusErr175 : PCIBusErr170) |
+	     TxUnderrun);
 
 	printk(KERN_DEBUG "%s: epic_restart() done, cmd status %4.4x, ctl %4.4x"
 		   " interrupt %4.4x.\n",
-		   dev->name, (int)inl(ioaddr + COMMAND), (int)inl(ioaddr + GENCTL),
-		   (int)inl(ioaddr + INTSTAT));
+		   dev->name, er32(COMMAND), er32(GENCTL), er32(INTSTAT));
 }
 
 static void check_media(struct net_device *dev)
 {
 	struct epic_private *ep = netdev_priv(dev);
-	long ioaddr = dev->base_addr;
+	void __iomem *ioaddr = ep->ioaddr;
 	int mii_lpa = ep->mii_phy_cnt ? mdio_read(dev, ep->phys[0], MII_LPA) : 0;
 	int negotiated = mii_lpa & ep->mii.advertising;
 	int duplex = (negotiated & 0x0100) || (negotiated & 0x01C0) == 0x0040;
@@ -856,7 +850,7 @@ static void check_media(struct net_device *dev)
 		printk(KERN_INFO "%s: Setting %s-duplex based on MII #%d link"
 			   " partner capability of %4.4x.\n", dev->name,
 			   ep->mii.full_duplex ? "full" : "half", ep->phys[0], mii_lpa);
-		outl(ep->mii.full_duplex ? 0x7F : 0x79, ioaddr + TxCtrl);
+		ew32(TxCtrl, ep->mii.full_duplex ? 0x7F : 0x79);
 	}
 }
 
@@ -864,16 +858,15 @@ static void epic_timer(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *)data;
 	struct epic_private *ep = netdev_priv(dev);
-	long ioaddr = dev->base_addr;
+	void __iomem *ioaddr = ep->ioaddr;
 	int next_tick = 5*HZ;
 
 	if (debug > 3) {
 		printk(KERN_DEBUG "%s: Media monitor tick, Tx status %8.8x.\n",
-			   dev->name, (int)inl(ioaddr + TxSTAT));
+		       dev->name, er32(TxSTAT));
 		printk(KERN_DEBUG "%s: Other registers are IntMask %4.4x "
-			   "IntStatus %4.4x RxStatus %4.4x.\n",
-			   dev->name, (int)inl(ioaddr + INTMASK),
-			   (int)inl(ioaddr + INTSTAT), (int)inl(ioaddr + RxSTAT));
+		       "IntStatus %4.4x RxStatus %4.4x.\n", dev->name,
+		       er32(INTMASK), er32(INTSTAT), er32(RxSTAT));
 	}
 
 	check_media(dev);
@@ -885,23 +878,22 @@ static void epic_timer(unsigned long data)
 static void epic_tx_timeout(struct net_device *dev)
 {
 	struct epic_private *ep = netdev_priv(dev);
-	long ioaddr = dev->base_addr;
+	void __iomem *ioaddr = ep->ioaddr;
 
 	if (debug > 0) {
 		printk(KERN_WARNING "%s: Transmit timeout using MII device, "
-			   "Tx status %4.4x.\n",
-			   dev->name, (int)inw(ioaddr + TxSTAT));
+		       "Tx status %4.4x.\n", dev->name, er16(TxSTAT));
 		if (debug > 1) {
 			printk(KERN_DEBUG "%s: Tx indices: dirty_tx %d, cur_tx %d.\n",
 				   dev->name, ep->dirty_tx, ep->cur_tx);
 		}
 	}
-	if (inw(ioaddr + TxSTAT) & 0x10) {		/* Tx FIFO underflow. */
+	if (er16(TxSTAT) & 0x10) {		/* Tx FIFO underflow. */
 		dev->stats.tx_fifo_errors++;
-		outl(RestartTx, ioaddr + COMMAND);
+		ew32(COMMAND, RestartTx);
 	} else {
 		epic_restart(dev);
-		outl(TxQueued, dev->base_addr + COMMAND);
+		ew32(COMMAND, TxQueued);
 	}
 
 	dev->trans_start = jiffies; /* prevent tx timeout */
@@ -959,6 +951,7 @@ static void epic_init_ring(struct net_device *dev)
 static netdev_tx_t epic_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct epic_private *ep = netdev_priv(dev);
+	void __iomem *ioaddr = ep->ioaddr;
 	int entry, free_count;
 	u32 ctrl_word;
 	unsigned long flags;
@@ -999,13 +992,12 @@ static netdev_tx_t epic_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	spin_unlock_irqrestore(&ep->lock, flags);
 	/* Trigger an immediate transmit demand. */
-	outl(TxQueued, dev->base_addr + COMMAND);
+	ew32(COMMAND, TxQueued);
 
 	if (debug > 4)
 		printk(KERN_DEBUG "%s: Queued Tx packet size %d to slot %d, "
-			   "flag %2.2x Tx status %8.8x.\n",
-			   dev->name, (int)skb->len, entry, ctrl_word,
-			   (int)inl(dev->base_addr + TxSTAT));
+		       "flag %2.2x Tx status %8.8x.\n", dev->name, skb->len,
+		       entry, ctrl_word, er32(TxSTAT));
 
 	return NETDEV_TX_OK;
 }
@@ -1086,18 +1078,17 @@ static irqreturn_t epic_interrupt(int irq, void *dev_instance)
 {
 	struct net_device *dev = dev_instance;
 	struct epic_private *ep = netdev_priv(dev);
-	long ioaddr = dev->base_addr;
+	void __iomem *ioaddr = ep->ioaddr;
 	unsigned int handled = 0;
 	int status;
 
-	status = inl(ioaddr + INTSTAT);
+	status = er32(INTSTAT);
 	/* Acknowledge all of the current interrupt sources ASAP. */
-	outl(status & EpicNormalEvent, ioaddr + INTSTAT);
+	ew32(INTSTAT, status & EpicNormalEvent);
 
 	if (debug > 4) {
 		printk(KERN_DEBUG "%s: Interrupt, status=%#8.8x new "
-				   "intstat=%#8.8x.\n", dev->name, status,
-				   (int)inl(ioaddr + INTSTAT));
+		       "intstat=%#8.8x.\n", dev->name, status, er32(INTSTAT));
 	}
 
 	if ((status & IntrSummary) == 0)
@@ -1118,19 +1109,21 @@ static irqreturn_t epic_interrupt(int irq, void *dev_instance)
 
 	/* Check uncommon events all at once. */
 	if (status & (CntFull | TxUnderrun | PCIBusErr170 | PCIBusErr175)) {
+		struct net_device_stats *stats = &dev->stats;
+
 		if (status == EpicRemoved)
 			goto out;
 
 		/* Always update the error counts to avoid overhead later. */
-		dev->stats.rx_missed_errors += inb(ioaddr + MPCNT);
-		dev->stats.rx_frame_errors += inb(ioaddr + ALICNT);
-		dev->stats.rx_crc_errors += inb(ioaddr + CRCCNT);
+		stats->rx_missed_errors	+= er8(MPCNT);
+		stats->rx_frame_errors	+= er8(ALICNT);
+		stats->rx_crc_errors	+= er8(CRCCNT);
 
 		if (status & TxUnderrun) { /* Tx FIFO underflow. */
-			dev->stats.tx_fifo_errors++;
-			outl(ep->tx_threshold += 128, ioaddr + TxThresh);
+			stats->tx_fifo_errors++;
+			ew32(TxThresh, ep->tx_threshold += 128);
 			/* Restart the transmit process. */
-			outl(RestartTx, ioaddr + COMMAND);
+			ew32(COMMAND, RestartTx);
 		}
 		if (status & PCIBusErr170) {
 			printk(KERN_ERR "%s: PCI Bus Error! status %4.4x.\n",
@@ -1139,7 +1132,7 @@ static irqreturn_t epic_interrupt(int irq, void *dev_instance)
 			epic_restart(dev);
 		}
 		/* Clear all error sources. */
-		outl(status & 0x7f18, ioaddr + INTSTAT);
+		ew32(INTSTAT, status & 0x7f18);
 	}
 
 out:
@@ -1248,17 +1241,17 @@ static int epic_rx(struct net_device *dev, int budget)
 
 static void epic_rx_err(struct net_device *dev, struct epic_private *ep)
 {
-	long ioaddr = dev->base_addr;
+	void __iomem *ioaddr = ep->ioaddr;
 	int status;
 
-	status = inl(ioaddr + INTSTAT);
+	status = er32(INTSTAT);
 
 	if (status == EpicRemoved)
 		return;
 	if (status & RxOverflow) 	/* Missed a Rx frame. */
 		dev->stats.rx_errors++;
 	if (status & (RxOverflow | RxFull))
-		outw(RxQueued, ioaddr + COMMAND);
+		ew16(COMMAND, RxQueued);
 }
 
 static int epic_poll(struct napi_struct *napi, int budget)
@@ -1266,7 +1259,7 @@ static int epic_poll(struct napi_struct *napi, int budget)
 	struct epic_private *ep = container_of(napi, struct epic_private, napi);
 	struct net_device *dev = ep->mii.dev;
 	int work_done = 0;
-	long ioaddr = dev->base_addr;
+	void __iomem *ioaddr = ep->ioaddr;
 
 rx_action:
 
@@ -1287,7 +1280,7 @@ rx_action:
 		more = ep->reschedule_in_poll;
 		if (!more) {
 			__napi_complete(napi);
-			outl(EpicNapiEvent, ioaddr + INTSTAT);
+			ew32(INTSTAT, EpicNapiEvent);
 			epic_napi_irq_on(dev, ep);
 		} else
 			ep->reschedule_in_poll--;
@@ -1303,8 +1296,9 @@ rx_action:
 
 static int epic_close(struct net_device *dev)
 {
-	long ioaddr = dev->base_addr;
 	struct epic_private *ep = netdev_priv(dev);
+	struct pci_dev *pdev = ep->pci_dev;
+	void __iomem *ioaddr = ep->ioaddr;
 	struct sk_buff *skb;
 	int i;
 
@@ -1313,13 +1307,13 @@ static int epic_close(struct net_device *dev)
 
 	if (debug > 1)
 		printk(KERN_DEBUG "%s: Shutting down ethercard, status was %2.2x.\n",
-			   dev->name, (int)inl(ioaddr + INTSTAT));
+		       dev->name, er32(INTSTAT));
 
 	del_timer_sync(&ep->timer);
 
 	epic_disable_int(dev, ep);
 
-	free_irq(dev->irq, dev);
+	free_irq(pdev->irq, dev);
 
 	epic_pause(dev);
 
@@ -1330,7 +1324,7 @@ static int epic_close(struct net_device *dev)
 		ep->rx_ring[i].rxstatus = 0;		/* Not owned by Epic chip. */
 		ep->rx_ring[i].buflength = 0;
 		if (skb) {
-			pci_unmap_single(ep->pci_dev, ep->rx_ring[i].bufaddr,
+			pci_unmap_single(pdev, ep->rx_ring[i].bufaddr,
 				 	 ep->rx_buf_sz, PCI_DMA_FROMDEVICE);
 			dev_kfree_skb(skb);
 		}
@@ -1341,26 +1335,28 @@ static int epic_close(struct net_device *dev)
 		ep->tx_skbuff[i] = NULL;
 		if (!skb)
 			continue;
-		pci_unmap_single(ep->pci_dev, ep->tx_ring[i].bufaddr,
-				 skb->len, PCI_DMA_TODEVICE);
+		pci_unmap_single(pdev, ep->tx_ring[i].bufaddr, skb->len,
+				 PCI_DMA_TODEVICE);
 		dev_kfree_skb(skb);
 	}
 
 	/* Green! Leave the chip in low-power mode. */
-	outl(0x0008, ioaddr + GENCTL);
+	ew32(GENCTL, 0x0008);
 
 	return 0;
 }
 
 static struct net_device_stats *epic_get_stats(struct net_device *dev)
 {
-	long ioaddr = dev->base_addr;
+	struct epic_private *ep = netdev_priv(dev);
+	void __iomem *ioaddr = ep->ioaddr;
 
 	if (netif_running(dev)) {
-		/* Update the error counts. */
-		dev->stats.rx_missed_errors += inb(ioaddr + MPCNT);
-		dev->stats.rx_frame_errors += inb(ioaddr + ALICNT);
-		dev->stats.rx_crc_errors += inb(ioaddr + CRCCNT);
+		struct net_device_stats *stats = &dev->stats;
+
+		stats->rx_missed_errors	+= er8(MPCNT);
+		stats->rx_frame_errors	+= er8(ALICNT);
+		stats->rx_crc_errors	+= er8(CRCCNT);
 	}
 
 	return &dev->stats;
@@ -1373,13 +1369,13 @@ static struct net_device_stats *epic_get_stats(struct net_device *dev)
 
 static void set_rx_mode(struct net_device *dev)
 {
-	long ioaddr = dev->base_addr;
 	struct epic_private *ep = netdev_priv(dev);
+	void __iomem *ioaddr = ep->ioaddr;
 	unsigned char mc_filter[8];		 /* Multicast hash filter */
 	int i;
 
 	if (dev->flags & IFF_PROMISC) {			/* Set promiscuous. */
-		outl(0x002C, ioaddr + RxCtrl);
+		ew32(RxCtrl, 0x002c);
 		/* Unconditionally log net taps. */
 		memset(mc_filter, 0xff, sizeof(mc_filter));
 	} else if ((!netdev_mc_empty(dev)) || (dev->flags & IFF_ALLMULTI)) {
@@ -1387,9 +1383,9 @@ static void set_rx_mode(struct net_device *dev)
 		   is never enabled. */
 		/* Too many to filter perfectly -- accept all multicasts. */
 		memset(mc_filter, 0xff, sizeof(mc_filter));
-		outl(0x000C, ioaddr + RxCtrl);
+		ew32(RxCtrl, 0x000c);
 	} else if (netdev_mc_empty(dev)) {
-		outl(0x0004, ioaddr + RxCtrl);
+		ew32(RxCtrl, 0x0004);
 		return;
 	} else {					/* Never executed, for now. */
 		struct netdev_hw_addr *ha;
@@ -1404,7 +1400,7 @@ static void set_rx_mode(struct net_device *dev)
 	/* ToDo: perhaps we need to stop the Tx and Rx process here? */
 	if (memcmp(mc_filter, ep->mc_filter, sizeof(mc_filter))) {
 		for (i = 0; i < 4; i++)
-			outw(((u16 *)mc_filter)[i], ioaddr + MC0 + i*4);
+			ew16(MC0 + i*4, ((u16 *)mc_filter)[i]);
 		memcpy(ep->mc_filter, mc_filter, sizeof(mc_filter));
 	}
 }
@@ -1466,22 +1462,26 @@ static void netdev_set_msglevel(struct net_device *dev, u32 value)
 
 static int ethtool_begin(struct net_device *dev)
 {
-	unsigned long ioaddr = dev->base_addr;
+	struct epic_private *ep = netdev_priv(dev);
+	void __iomem *ioaddr = ep->ioaddr;
+
 	/* power-up, if interface is down */
-	if (! netif_running(dev)) {
-		outl(0x0200, ioaddr + GENCTL);
-		outl((inl(ioaddr + NVCTL) & ~0x003C) | 0x4800, ioaddr + NVCTL);
+	if (!netif_running(dev)) {
+		ew32(GENCTL, 0x0200);
+		ew32(NVCTL, (er32(NVCTL) & ~0x003c) | 0x4800);
 	}
 	return 0;
 }
 
 static void ethtool_complete(struct net_device *dev)
 {
-	unsigned long ioaddr = dev->base_addr;
+	struct epic_private *ep = netdev_priv(dev);
+	void __iomem *ioaddr = ep->ioaddr;
+
 	/* power-down, if interface is down */
-	if (! netif_running(dev)) {
-		outl(0x0008, ioaddr + GENCTL);
-		outl((inl(ioaddr + NVCTL) & ~0x483C) | 0x0000, ioaddr + NVCTL);
+	if (!netif_running(dev)) {
+		ew32(GENCTL, 0x0008);
+		ew32(NVCTL, (er32(NVCTL) & ~0x483c) | 0x0000);
 	}
 }
 
@@ -1500,14 +1500,14 @@ static const struct ethtool_ops netdev_ethtool_ops = {
 static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 	struct epic_private *np = netdev_priv(dev);
-	long ioaddr = dev->base_addr;
+	void __iomem *ioaddr = np->ioaddr;
 	struct mii_ioctl_data *data = if_mii(rq);
 	int rc;
 
 	/* power-up, if interface is down */
 	if (! netif_running(dev)) {
-		outl(0x0200, ioaddr + GENCTL);
-		outl((inl(ioaddr + NVCTL) & ~0x003C) | 0x4800, ioaddr + NVCTL);
+		ew32(GENCTL, 0x0200);
+		ew32(NVCTL, (er32(NVCTL) & ~0x003c) | 0x4800);
 	}
 
 	/* all non-ethtool ioctls (the SIOC[GS]MIIxxx ioctls) */
@@ -1517,14 +1517,14 @@ static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 
 	/* power-down, if interface is down */
 	if (! netif_running(dev)) {
-		outl(0x0008, ioaddr + GENCTL);
-		outl((inl(ioaddr + NVCTL) & ~0x483C) | 0x0000, ioaddr + NVCTL);
+		ew32(GENCTL, 0x0008);
+		ew32(NVCTL, (er32(NVCTL) & ~0x483c) | 0x0000);
 	}
 	return rc;
 }
 
 
-static void __devexit epic_remove_one (struct pci_dev *pdev)
+static void __devexit epic_remove_one(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct epic_private *ep = netdev_priv(dev);
@@ -1532,9 +1532,7 @@ static void __devexit epic_remove_one (struct pci_dev *pdev)
 	pci_free_consistent(pdev, TX_TOTAL_SIZE, ep->tx_ring, ep->tx_ring_dma);
 	pci_free_consistent(pdev, RX_TOTAL_SIZE, ep->rx_ring, ep->rx_ring_dma);
 	unregister_netdev(dev);
-#ifndef USE_IO_OPS
-	iounmap((void*) dev->base_addr);
-#endif
+	pci_iounmap(pdev, ep->ioaddr);
 	pci_release_regions(pdev);
 	free_netdev(dev);
 	pci_disable_device(pdev);
@@ -1548,13 +1546,14 @@ static void __devexit epic_remove_one (struct pci_dev *pdev)
 static int epic_suspend (struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
-	long ioaddr = dev->base_addr;
+	struct epic_private *ep = netdev_priv(dev);
+	void __iomem *ioaddr = ep->ioaddr;
 
 	if (!netif_running(dev))
 		return 0;
 	epic_pause(dev);
 	/* Put the chip into low-power mode. */
-	outl(0x0008, ioaddr + GENCTL);
+	ew32(GENCTL, 0x0008);
 	/* pci_power_off(pdev, -1); */
 	return 0;
 }
-- 
1.7.7.6
