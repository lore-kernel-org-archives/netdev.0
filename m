From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next #2 34/39] sis900: stop using net_device.{base_addr, irq} and convert to __iomem.
Date: Fri,  6 Apr 2012 12:06:48 +0200
Message-ID: <ece290b1c52d06f3e336eb2677a7f374b1ec8036.1333704409.git.romieu@fr.zoreil.com>
References: <1333704408.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>,
	Daniele Venzano <venza@brownhat.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:43475 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755987Ab2DFKKj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Apr 2012 06:10:39 -0400
In-Reply-To: <1333704408.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- pci_resource_start() can be removed from sis900_get_mac_addr() because
  the IO range is maped and stored into the device private struct early
  in the device probe function.
- the driver contains a few direct accesses to low IO ports that forbid
  to re(#)define the usual out{l, w, b} macros.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Daniele Venzano <venza@brownhat.org>
---
 drivers/net/ethernet/sis/sis900.c |  375 ++++++++++++++++++++-----------------
 1 files changed, 201 insertions(+), 174 deletions(-)

diff --git a/drivers/net/ethernet/sis/sis900.c b/drivers/net/ethernet/sis/sis900.c
index 5ccf02e..203d9c6 100644
--- a/drivers/net/ethernet/sis/sis900.c
+++ b/drivers/net/ethernet/sis/sis900.c
@@ -168,6 +168,8 @@ struct sis900_private {
 	unsigned int cur_phy;
 	struct mii_if_info mii_info;
 
+	void __iomem	*ioaddr;
+
 	struct timer_list timer; /* Link status detection timer. */
 	u8 autong_complete; /* 1: auto-negotiate complete  */
 
@@ -201,13 +203,18 @@ MODULE_PARM_DESC(multicast_filter_limit, "SiS 900/7016 maximum number of filtere
 MODULE_PARM_DESC(max_interrupt_work, "SiS 900/7016 maximum events handled per interrupt");
 MODULE_PARM_DESC(sis900_debug, "SiS 900/7016 bitmapped debugging message level");
 
+#define sw32(reg, val)	iowrite32(val, ioaddr + (reg))
+#define sw8(reg, val)	iowrite8(val, ioaddr + (reg))
+#define sr32(reg)	ioread32(ioaddr + (reg))
+#define sr16(reg)	ioread16(ioaddr + (reg))
+
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void sis900_poll(struct net_device *dev);
 #endif
 static int sis900_open(struct net_device *net_dev);
 static int sis900_mii_probe (struct net_device * net_dev);
 static void sis900_init_rxfilter (struct net_device * net_dev);
-static u16 read_eeprom(long ioaddr, int location);
+static u16 read_eeprom(void __iomem *ioaddr, int location);
 static int mdio_read(struct net_device *net_dev, int phy_id, int location);
 static void mdio_write(struct net_device *net_dev, int phy_id, int location, int val);
 static void sis900_timer(unsigned long data);
@@ -231,7 +238,7 @@ static u16 sis900_default_phy(struct net_device * net_dev);
 static void sis900_set_capability( struct net_device *net_dev ,struct mii_phy *phy);
 static u16 sis900_reset_phy(struct net_device *net_dev, int phy_addr);
 static void sis900_auto_negotiate(struct net_device *net_dev, int phy_addr);
-static void sis900_set_mode (long ioaddr, int speed, int duplex);
+static void sis900_set_mode(struct sis900_private *, int speed, int duplex);
 static const struct ethtool_ops sis900_ethtool_ops;
 
 /**
@@ -246,7 +253,8 @@ static const struct ethtool_ops sis900_ethtool_ops;
 
 static int __devinit sis900_get_mac_addr(struct pci_dev * pci_dev, struct net_device *net_dev)
 {
-	long ioaddr = pci_resource_start(pci_dev, 0);
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
+	void __iomem *ioaddr = sis_priv->ioaddr;
 	u16 signature;
 	int i;
 
@@ -325,29 +333,30 @@ static int __devinit sis630e_get_mac_addr(struct pci_dev * pci_dev,
 static int __devinit sis635_get_mac_addr(struct pci_dev * pci_dev,
 					struct net_device *net_dev)
 {
-	long ioaddr = net_dev->base_addr;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
+	void __iomem *ioaddr = sis_priv->ioaddr;
 	u32 rfcrSave;
 	u32 i;
 
-	rfcrSave = inl(rfcr + ioaddr);
+	rfcrSave = sr32(rfcr);
 
-	outl(rfcrSave | RELOAD, ioaddr + cr);
-	outl(0, ioaddr + cr);
+	sw32(cr, rfcrSave | RELOAD);
+	sw32(cr, 0);
 
 	/* disable packet filtering before setting filter */
-	outl(rfcrSave & ~RFEN, rfcr + ioaddr);
+	sw32(rfcr, rfcrSave & ~RFEN);
 
 	/* load MAC addr to filter data register */
 	for (i = 0 ; i < 3 ; i++) {
-		outl((i << RFADDR_shift), ioaddr + rfcr);
-		*( ((u16 *)net_dev->dev_addr) + i) = inw(ioaddr + rfdr);
+		sw32(rfcr, (i << RFADDR_shift));
+		*( ((u16 *)net_dev->dev_addr) + i) = sr16(rfdr);
 	}
 
 	/* Store MAC Address in perm_addr */
 	memcpy(net_dev->perm_addr, net_dev->dev_addr, ETH_ALEN);
 
 	/* enable packet filtering */
-	outl(rfcrSave | RFEN, rfcr + ioaddr);
+	sw32(rfcr, rfcrSave | RFEN);
 
 	return 1;
 }
@@ -371,31 +380,30 @@ static int __devinit sis635_get_mac_addr(struct pci_dev * pci_dev,
 static int __devinit sis96x_get_mac_addr(struct pci_dev * pci_dev,
 					struct net_device *net_dev)
 {
-	long ioaddr = net_dev->base_addr;
-	long ee_addr = ioaddr + mear;
-	u32 waittime = 0;
-	int i;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
+	void __iomem *ioaddr = sis_priv->ioaddr;
+	int wait, rc = 0;
 
-	outl(EEREQ, ee_addr);
-	while(waittime < 2000) {
-		if(inl(ee_addr) & EEGNT) {
+	sw32(mear, EEREQ);
+	for (wait = 0; wait < 2000; wait++) {
+		if (sr32(mear) & EEGNT) {
+			u16 *mac = (u16 *)net_dev->dev_addr;
+			int i;
 
 			/* get MAC address from EEPROM */
 			for (i = 0; i < 3; i++)
-			        ((u16 *)(net_dev->dev_addr))[i] = read_eeprom(ioaddr, i+EEPROMMACAddr);
+			        mac[i] = read_eeprom(ioaddr, i + EEPROMMACAddr);
 
 			/* Store MAC Address in perm_addr */
 			memcpy(net_dev->perm_addr, net_dev->dev_addr, ETH_ALEN);
 
-			outl(EEDONE, ee_addr);
-			return 1;
-		} else {
-			udelay(1);
-			waittime ++;
+			rc = 1;
+			break;
 		}
+		udelay(1);
 	}
-	outl(EEDONE, ee_addr);
-	return 0;
+	sw32(mear, EEDONE);
+	return rc;
 }
 
 static const struct net_device_ops sis900_netdev_ops = {
@@ -433,7 +441,7 @@ static int __devinit sis900_probe(struct pci_dev *pci_dev,
 	struct pci_dev *dev;
 	dma_addr_t ring_dma;
 	void *ring_space;
-	long ioaddr;
+	void __iomem *ioaddr;
 	int i, ret;
 	const char *card_name = card_names[pci_id->driver_data];
 	const char *dev_name = pci_name(pci_dev);
@@ -464,14 +472,17 @@ static int __devinit sis900_probe(struct pci_dev *pci_dev,
 	SET_NETDEV_DEV(net_dev, &pci_dev->dev);
 
 	/* We do a request_region() to register /proc/ioports info. */
-	ioaddr = pci_resource_start(pci_dev, 0);
 	ret = pci_request_regions(pci_dev, "sis900");
 	if (ret)
 		goto err_out;
 
+	/* IO region. */
+	ioaddr = pci_iomap(pci_dev, 0, 0);
+	if (!ioaddr)
+		goto err_out_cleardev;
+
 	sis_priv = netdev_priv(net_dev);
-	net_dev->base_addr = ioaddr;
-	net_dev->irq = pci_dev->irq;
+	sis_priv->ioaddr = ioaddr;
 	sis_priv->pci_dev = pci_dev;
 	spin_lock_init(&sis_priv->lock);
 
@@ -480,7 +491,7 @@ static int __devinit sis900_probe(struct pci_dev *pci_dev,
 	ring_space = pci_alloc_consistent(pci_dev, TX_TOTAL_SIZE, &ring_dma);
 	if (!ring_space) {
 		ret = -ENOMEM;
-		goto err_out_cleardev;
+		goto err_out_unmap;
 	}
 	sis_priv->tx_ring = ring_space;
 	sis_priv->tx_ring_dma = ring_dma;
@@ -534,7 +545,7 @@ static int __devinit sis900_probe(struct pci_dev *pci_dev,
 
 	/* 630ET : set the mii access mode as software-mode */
 	if (sis_priv->chipset_rev == SIS630ET_900_REV)
-		outl(ACCESSMODE | inl(ioaddr + cr), ioaddr + cr);
+		sw32(cr, ACCESSMODE | sr32(cr));
 
 	/* probe for mii transceiver */
 	if (sis900_mii_probe(net_dev) == 0) {
@@ -556,25 +567,27 @@ static int __devinit sis900_probe(struct pci_dev *pci_dev,
 		goto err_unmap_rx;
 
 	/* print some information about our NIC */
-	printk(KERN_INFO "%s: %s at %#lx, IRQ %d, %pM\n",
-	       net_dev->name, card_name, ioaddr, net_dev->irq,
+	printk(KERN_INFO "%s: %s at 0x%p, IRQ %d, %pM\n",
+	       net_dev->name, card_name, ioaddr, pci_dev->irq,
 	       net_dev->dev_addr);
 
 	/* Detect Wake on Lan support */
-	ret = (inl(net_dev->base_addr + CFGPMC) & PMESP) >> 27;
+	ret = (sr32(CFGPMC) & PMESP) >> 27;
 	if (netif_msg_probe(sis_priv) && (ret & PME_D3C) == 0)
 		printk(KERN_INFO "%s: Wake on LAN only available from suspend to RAM.", net_dev->name);
 
 	return 0;
 
- err_unmap_rx:
+err_unmap_rx:
 	pci_free_consistent(pci_dev, RX_TOTAL_SIZE, sis_priv->rx_ring,
 		sis_priv->rx_ring_dma);
- err_unmap_tx:
+err_unmap_tx:
 	pci_free_consistent(pci_dev, TX_TOTAL_SIZE, sis_priv->tx_ring,
 		sis_priv->tx_ring_dma);
- err_out_cleardev:
- 	pci_set_drvdata(pci_dev, NULL);
+err_out_unmap:
+	pci_iounmap(pci_dev, ioaddr);
+err_out_cleardev:
+	pci_set_drvdata(pci_dev, NULL);
 	pci_release_regions(pci_dev);
  err_out:
 	free_netdev(net_dev);
@@ -798,7 +811,7 @@ static void sis900_set_capability(struct net_device *net_dev, struct mii_phy *ph
 
 
 /* Delay between EEPROM clock transitions. */
-#define eeprom_delay()  inl(ee_addr)
+#define eeprom_delay()	sr32(mear)
 
 /**
  *	read_eeprom - Read Serial EEPROM
@@ -809,41 +822,41 @@ static void sis900_set_capability(struct net_device *net_dev, struct mii_phy *ph
  *	Note that location is in word (16 bits) unit
  */
 
-static u16 __devinit read_eeprom(long ioaddr, int location)
+static u16 __devinit read_eeprom(void __iomem *ioaddr, int location)
 {
+	u32 read_cmd = location | EEread;
 	int i;
 	u16 retval = 0;
-	long ee_addr = ioaddr + mear;
-	u32 read_cmd = location | EEread;
 
-	outl(0, ee_addr);
+	sw32(mear, 0);
 	eeprom_delay();
-	outl(EECS, ee_addr);
+	sw32(mear, EECS);
 	eeprom_delay();
 
 	/* Shift the read command (9) bits out. */
 	for (i = 8; i >= 0; i--) {
 		u32 dataval = (read_cmd & (1 << i)) ? EEDI | EECS : EECS;
-		outl(dataval, ee_addr);
+
+		sw32(mear, dataval);
 		eeprom_delay();
-		outl(dataval | EECLK, ee_addr);
+		sw32(mear, dataval | EECLK);
 		eeprom_delay();
 	}
-	outl(EECS, ee_addr);
+	sw32(mear, EECS);
 	eeprom_delay();
 
 	/* read the 16-bits data in */
 	for (i = 16; i > 0; i--) {
-		outl(EECS, ee_addr);
+		sw32(mear, EECS);
 		eeprom_delay();
-		outl(EECS | EECLK, ee_addr);
+		sw32(mear, EECS | EECLK);
 		eeprom_delay();
-		retval = (retval << 1) | ((inl(ee_addr) & EEDO) ? 1 : 0);
+		retval = (retval << 1) | ((sr32(mear) & EEDO) ? 1 : 0);
 		eeprom_delay();
 	}
 
 	/* Terminate the EEPROM access. */
-	outl(0, ee_addr);
+	sw32(mear, 0);
 	eeprom_delay();
 
 	return retval;
@@ -852,24 +865,27 @@ static u16 __devinit read_eeprom(long ioaddr, int location)
 /* Read and write the MII management registers using software-generated
    serial MDIO protocol. Note that the command bits and data bits are
    send out separately */
-#define mdio_delay()    inl(mdio_addr)
+#define mdio_delay()	sr32(mear)
 
-static void mdio_idle(long mdio_addr)
+static void mdio_idle(struct sis900_private *sp)
 {
-	outl(MDIO | MDDIR, mdio_addr);
+	void __iomem *ioaddr = sp->ioaddr;
+
+	sw32(mear, MDIO | MDDIR);
 	mdio_delay();
-	outl(MDIO | MDDIR | MDC, mdio_addr);
+	sw32(mear, MDIO | MDDIR | MDC);
 }
 
-/* Syncronize the MII management interface by shifting 32 one bits out. */
-static void mdio_reset(long mdio_addr)
+/* Synchronize the MII management interface by shifting 32 one bits out. */
+static void mdio_reset(struct sis900_private *sp)
 {
+	void __iomem *ioaddr = sp->ioaddr;
 	int i;
 
 	for (i = 31; i >= 0; i--) {
-		outl(MDDIR | MDIO, mdio_addr);
+		sw32(mear, MDDIR | MDIO);
 		mdio_delay();
-		outl(MDDIR | MDIO | MDC, mdio_addr);
+		sw32(mear, MDDIR | MDIO | MDC);
 		mdio_delay();
 	}
 }
@@ -887,31 +903,33 @@ static void mdio_reset(long mdio_addr)
 
 static int mdio_read(struct net_device *net_dev, int phy_id, int location)
 {
-	long mdio_addr = net_dev->base_addr + mear;
 	int mii_cmd = MIIread|(phy_id<<MIIpmdShift)|(location<<MIIregShift);
+	struct sis900_private *sp = netdev_priv(net_dev);
+	void __iomem *ioaddr = sp->ioaddr;
 	u16 retval = 0;
 	int i;
 
-	mdio_reset(mdio_addr);
-	mdio_idle(mdio_addr);
+	mdio_reset(sp);
+	mdio_idle(sp);
 
 	for (i = 15; i >= 0; i--) {
 		int dataval = (mii_cmd & (1 << i)) ? MDDIR | MDIO : MDDIR;
-		outl(dataval, mdio_addr);
+
+		sw32(mear, dataval);
 		mdio_delay();
-		outl(dataval | MDC, mdio_addr);
+		sw32(mear, dataval | MDC);
 		mdio_delay();
 	}
 
 	/* Read the 16 data bits. */
 	for (i = 16; i > 0; i--) {
-		outl(0, mdio_addr);
+		sw32(mear, 0);
 		mdio_delay();
-		retval = (retval << 1) | ((inl(mdio_addr) & MDIO) ? 1 : 0);
-		outl(MDC, mdio_addr);
+		retval = (retval << 1) | ((sr32(mear) & MDIO) ? 1 : 0);
+		sw32(mear, MDC);
 		mdio_delay();
 	}
-	outl(0x00, mdio_addr);
+	sw32(mear, 0x00);
 
 	return retval;
 }
@@ -931,19 +949,21 @@ static int mdio_read(struct net_device *net_dev, int phy_id, int location)
 static void mdio_write(struct net_device *net_dev, int phy_id, int location,
 			int value)
 {
-	long mdio_addr = net_dev->base_addr + mear;
 	int mii_cmd = MIIwrite|(phy_id<<MIIpmdShift)|(location<<MIIregShift);
+	struct sis900_private *sp = netdev_priv(net_dev);
+	void __iomem *ioaddr = sp->ioaddr;
 	int i;
 
-	mdio_reset(mdio_addr);
-	mdio_idle(mdio_addr);
+	mdio_reset(sp);
+	mdio_idle(sp);
 
 	/* Shift the command bits out. */
 	for (i = 15; i >= 0; i--) {
 		int dataval = (mii_cmd & (1 << i)) ? MDDIR | MDIO : MDDIR;
-		outb(dataval, mdio_addr);
+
+		sw8(mear, dataval);
 		mdio_delay();
-		outb(dataval | MDC, mdio_addr);
+		sw8(mear, dataval | MDC);
 		mdio_delay();
 	}
 	mdio_delay();
@@ -951,21 +971,22 @@ static void mdio_write(struct net_device *net_dev, int phy_id, int location,
 	/* Shift the value bits out. */
 	for (i = 15; i >= 0; i--) {
 		int dataval = (value & (1 << i)) ? MDDIR | MDIO : MDDIR;
-		outl(dataval, mdio_addr);
+
+		sw32(mear, dataval);
 		mdio_delay();
-		outl(dataval | MDC, mdio_addr);
+		sw32(mear, dataval | MDC);
 		mdio_delay();
 	}
 	mdio_delay();
 
 	/* Clear out extra bits. */
 	for (i = 2; i > 0; i--) {
-		outb(0, mdio_addr);
+		sw8(mear, 0);
 		mdio_delay();
-		outb(MDC, mdio_addr);
+		sw8(mear, MDC);
 		mdio_delay();
 	}
-	outl(0x00, mdio_addr);
+	sw32(mear, 0x00);
 }
 
 
@@ -1000,9 +1021,12 @@ static u16 sis900_reset_phy(struct net_device *net_dev, int phy_addr)
 */
 static void sis900_poll(struct net_device *dev)
 {
-	disable_irq(dev->irq);
-	sis900_interrupt(dev->irq, dev);
-	enable_irq(dev->irq);
+	struct sis900_private *sp = netdev_priv(dev);
+	const int irq = sp->pci_dev->irq;
+
+	disable_irq(irq);
+	sis900_interrupt(irq, dev);
+	enable_irq(irq);
 }
 #endif
 
@@ -1018,7 +1042,7 @@ static int
 sis900_open(struct net_device *net_dev)
 {
 	struct sis900_private *sis_priv = netdev_priv(net_dev);
-	long ioaddr = net_dev->base_addr;
+	void __iomem *ioaddr = sis_priv->ioaddr;
 	int ret;
 
 	/* Soft reset the chip. */
@@ -1027,8 +1051,8 @@ sis900_open(struct net_device *net_dev)
 	/* Equalizer workaround Rule */
 	sis630_set_eq(net_dev, sis_priv->chipset_rev);
 
-	ret = request_irq(net_dev->irq, sis900_interrupt, IRQF_SHARED,
-						net_dev->name, net_dev);
+	ret = request_irq(sis_priv->pci_dev->irq, sis900_interrupt, IRQF_SHARED,
+			  net_dev->name, net_dev);
 	if (ret)
 		return ret;
 
@@ -1042,12 +1066,12 @@ sis900_open(struct net_device *net_dev)
 	netif_start_queue(net_dev);
 
 	/* Workaround for EDB */
-	sis900_set_mode(ioaddr, HW_SPEED_10_MBPS, FDX_CAPABLE_HALF_SELECTED);
+	sis900_set_mode(sis_priv, HW_SPEED_10_MBPS, FDX_CAPABLE_HALF_SELECTED);
 
 	/* Enable all known interrupts by setting the interrupt mask. */
-	outl((RxSOVR|RxORN|RxERR|RxOK|TxURN|TxERR|TxIDLE), ioaddr + imr);
-	outl(RxENA | inl(ioaddr + cr), ioaddr + cr);
-	outl(IE, ioaddr + ier);
+	sw32(imr, RxSOVR | RxORN | RxERR | RxOK | TxURN | TxERR | TxIDLE);
+	sw32(cr, RxENA | sr32(cr));
+	sw32(ier, IE);
 
 	sis900_check_mode(net_dev, sis_priv->mii);
 
@@ -1074,31 +1098,30 @@ static void
 sis900_init_rxfilter (struct net_device * net_dev)
 {
 	struct sis900_private *sis_priv = netdev_priv(net_dev);
-	long ioaddr = net_dev->base_addr;
+	void __iomem *ioaddr = sis_priv->ioaddr;
 	u32 rfcrSave;
 	u32 i;
 
-	rfcrSave = inl(rfcr + ioaddr);
+	rfcrSave = sr32(rfcr);
 
 	/* disable packet filtering before setting filter */
-	outl(rfcrSave & ~RFEN, rfcr + ioaddr);
+	sw32(rfcr, rfcrSave & ~RFEN);
 
 	/* load MAC addr to filter data register */
 	for (i = 0 ; i < 3 ; i++) {
-		u32 w;
+		u32 w = (u32) *((u16 *)(net_dev->dev_addr)+i);
 
-		w = (u32) *((u16 *)(net_dev->dev_addr)+i);
-		outl((i << RFADDR_shift), ioaddr + rfcr);
-		outl(w, ioaddr + rfdr);
+		sw32(rfcr, i << RFADDR_shift);
+		sw32(rfdr, w);
 
 		if (netif_msg_hw(sis_priv)) {
 			printk(KERN_DEBUG "%s: Receive Filter Addrss[%d]=%x\n",
-			       net_dev->name, i, inl(ioaddr + rfdr));
+			       net_dev->name, i, sr32(rfdr));
 		}
 	}
 
 	/* enable packet filtering */
-	outl(rfcrSave | RFEN, rfcr + ioaddr);
+	sw32(rfcr, rfcrSave | RFEN);
 }
 
 /**
@@ -1112,7 +1135,7 @@ static void
 sis900_init_tx_ring(struct net_device *net_dev)
 {
 	struct sis900_private *sis_priv = netdev_priv(net_dev);
-	long ioaddr = net_dev->base_addr;
+	void __iomem *ioaddr = sis_priv->ioaddr;
 	int i;
 
 	sis_priv->tx_full = 0;
@@ -1128,10 +1151,10 @@ sis900_init_tx_ring(struct net_device *net_dev)
 	}
 
 	/* load Transmit Descriptor Register */
-	outl(sis_priv->tx_ring_dma, ioaddr + txdp);
+	sw32(txdp, sis_priv->tx_ring_dma);
 	if (netif_msg_hw(sis_priv))
 		printk(KERN_DEBUG "%s: TX descriptor register loaded with: %8.8x\n",
-		       net_dev->name, inl(ioaddr + txdp));
+		       net_dev->name, sr32(txdp));
 }
 
 /**
@@ -1146,7 +1169,7 @@ static void
 sis900_init_rx_ring(struct net_device *net_dev)
 {
 	struct sis900_private *sis_priv = netdev_priv(net_dev);
-	long ioaddr = net_dev->base_addr;
+	void __iomem *ioaddr = sis_priv->ioaddr;
 	int i;
 
 	sis_priv->cur_rx = 0;
@@ -1181,10 +1204,10 @@ sis900_init_rx_ring(struct net_device *net_dev)
 	sis_priv->dirty_rx = (unsigned int) (i - NUM_RX_DESC);
 
 	/* load Receive Descriptor Register */
-	outl(sis_priv->rx_ring_dma, ioaddr + rxdp);
+	sw32(rxdp, sis_priv->rx_ring_dma);
 	if (netif_msg_hw(sis_priv))
 		printk(KERN_DEBUG "%s: RX descriptor register loaded with: %8.8x\n",
-		       net_dev->name, inl(ioaddr + rxdp));
+		       net_dev->name, sr32(rxdp));
 }
 
 /**
@@ -1298,7 +1321,7 @@ static void sis900_timer(unsigned long data)
 
 		sis900_read_mode(net_dev, &speed, &duplex);
 		if (duplex){
-			sis900_set_mode(net_dev->base_addr, speed, duplex);
+			sis900_set_mode(sis_priv, speed, duplex);
 			sis630_set_eq(net_dev, sis_priv->chipset_rev);
 			netif_start_queue(net_dev);
 		}
@@ -1359,25 +1382,25 @@ static void sis900_timer(unsigned long data)
 static void sis900_check_mode(struct net_device *net_dev, struct mii_phy *mii_phy)
 {
 	struct sis900_private *sis_priv = netdev_priv(net_dev);
-	long ioaddr = net_dev->base_addr;
+	void __iomem *ioaddr = sis_priv->ioaddr;
 	int speed, duplex;
 
 	if (mii_phy->phy_types == LAN) {
-		outl(~EXD & inl(ioaddr + cfg), ioaddr + cfg);
+		sw32(cfg, ~EXD & sr32(cfg));
 		sis900_set_capability(net_dev , mii_phy);
 		sis900_auto_negotiate(net_dev, sis_priv->cur_phy);
 	} else {
-		outl(EXD | inl(ioaddr + cfg), ioaddr + cfg);
+		sw32(cfg, EXD | sr32(cfg));
 		speed = HW_SPEED_HOME;
 		duplex = FDX_CAPABLE_HALF_SELECTED;
-		sis900_set_mode(ioaddr, speed, duplex);
+		sis900_set_mode(sis_priv, speed, duplex);
 		sis_priv->autong_complete = 1;
 	}
 }
 
 /**
  *	sis900_set_mode - Set the media mode of mac register.
- *	@ioaddr: the address of the device
+ *	@sp:     the device private data
  *	@speed : the transmit speed to be determined
  *	@duplex: the duplex mode to be determined
  *
@@ -1388,11 +1411,12 @@ static void sis900_check_mode(struct net_device *net_dev, struct mii_phy *mii_ph
  *	double words.
  */
 
-static void sis900_set_mode (long ioaddr, int speed, int duplex)
+static void sis900_set_mode(struct sis900_private *sp, int speed, int duplex)
 {
+	void __iomem *ioaddr = sp->ioaddr;
 	u32 tx_flags = 0, rx_flags = 0;
 
-	if (inl(ioaddr + cfg) & EDB_MASTER_EN) {
+	if (sr32( cfg) & EDB_MASTER_EN) {
 		tx_flags = TxATP | (DMA_BURST_64 << TxMXDMA_shift) |
 					(TX_FILL_THRESH << TxFILLT_shift);
 		rx_flags = DMA_BURST_64 << RxMXDMA_shift;
@@ -1420,8 +1444,8 @@ static void sis900_set_mode (long ioaddr, int speed, int duplex)
 	rx_flags |= RxAJAB;
 #endif
 
-	outl (tx_flags, ioaddr + txcfg);
-	outl (rx_flags, ioaddr + rxcfg);
+	sw32(txcfg, tx_flags);
+	sw32(rxcfg, rx_flags);
 }
 
 /**
@@ -1528,16 +1552,17 @@ static void sis900_read_mode(struct net_device *net_dev, int *speed, int *duplex
 static void sis900_tx_timeout(struct net_device *net_dev)
 {
 	struct sis900_private *sis_priv = netdev_priv(net_dev);
-	long ioaddr = net_dev->base_addr;
+	void __iomem *ioaddr = sis_priv->ioaddr;
 	unsigned long flags;
 	int i;
 
-	if(netif_msg_tx_err(sis_priv))
+	if (netif_msg_tx_err(sis_priv)) {
 		printk(KERN_INFO "%s: Transmit timeout, status %8.8x %8.8x\n",
-	       		net_dev->name, inl(ioaddr + cr), inl(ioaddr + isr));
+			net_dev->name, sr32(cr), sr32(isr));
+	}
 
 	/* Disable interrupts by clearing the interrupt mask. */
-	outl(0x0000, ioaddr + imr);
+	sw32(imr, 0x0000);
 
 	/* use spinlock to prevent interrupt handler accessing buffer ring */
 	spin_lock_irqsave(&sis_priv->lock, flags);
@@ -1566,10 +1591,10 @@ static void sis900_tx_timeout(struct net_device *net_dev)
 	net_dev->trans_start = jiffies; /* prevent tx timeout */
 
 	/* load Transmit Descriptor Register */
-	outl(sis_priv->tx_ring_dma, ioaddr + txdp);
+	sw32(txdp, sis_priv->tx_ring_dma);
 
 	/* Enable all known interrupts by setting the interrupt mask. */
-	outl((RxSOVR|RxORN|RxERR|RxOK|TxURN|TxERR|TxIDLE), ioaddr + imr);
+	sw32(imr, RxSOVR | RxORN | RxERR | RxOK | TxURN | TxERR | TxIDLE);
 }
 
 /**
@@ -1586,7 +1611,7 @@ static netdev_tx_t
 sis900_start_xmit(struct sk_buff *skb, struct net_device *net_dev)
 {
 	struct sis900_private *sis_priv = netdev_priv(net_dev);
-	long ioaddr = net_dev->base_addr;
+	void __iomem *ioaddr = sis_priv->ioaddr;
 	unsigned int  entry;
 	unsigned long flags;
 	unsigned int  index_cur_tx, index_dirty_tx;
@@ -1608,7 +1633,7 @@ sis900_start_xmit(struct sk_buff *skb, struct net_device *net_dev)
 	sis_priv->tx_ring[entry].bufptr = pci_map_single(sis_priv->pci_dev,
 		skb->data, skb->len, PCI_DMA_TODEVICE);
 	sis_priv->tx_ring[entry].cmdsts = (OWN | skb->len);
-	outl(TxENA | inl(ioaddr + cr), ioaddr + cr);
+	sw32(cr, TxENA | sr32(cr));
 
 	sis_priv->cur_tx ++;
 	index_cur_tx = sis_priv->cur_tx;
@@ -1654,14 +1679,14 @@ static irqreturn_t sis900_interrupt(int irq, void *dev_instance)
 	struct net_device *net_dev = dev_instance;
 	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	int boguscnt = max_interrupt_work;
-	long ioaddr = net_dev->base_addr;
+	void __iomem *ioaddr = sis_priv->ioaddr;
 	u32 status;
 	unsigned int handled = 0;
 
 	spin_lock (&sis_priv->lock);
 
 	do {
-		status = inl(ioaddr + isr);
+		status = sr32(isr);
 
 		if ((status & (HIBERR|TxURN|TxERR|TxIDLE|RxORN|RxERR|RxOK)) == 0)
 			/* nothing intresting happened */
@@ -1696,7 +1721,7 @@ static irqreturn_t sis900_interrupt(int irq, void *dev_instance)
 	if(netif_msg_intr(sis_priv))
 		printk(KERN_DEBUG "%s: exiting interrupt, "
 		       "interrupt status = 0x%#8.8x.\n",
-		       net_dev->name, inl(ioaddr + isr));
+		       net_dev->name, sr32(isr));
 
 	spin_unlock (&sis_priv->lock);
 	return IRQ_RETVAL(handled);
@@ -1715,7 +1740,7 @@ static irqreturn_t sis900_interrupt(int irq, void *dev_instance)
 static int sis900_rx(struct net_device *net_dev)
 {
 	struct sis900_private *sis_priv = netdev_priv(net_dev);
-	long ioaddr = net_dev->base_addr;
+	void __iomem *ioaddr = sis_priv->ioaddr;
 	unsigned int entry = sis_priv->cur_rx % NUM_RX_DESC;
 	u32 rx_status = sis_priv->rx_ring[entry].cmdsts;
 	int rx_work_limit;
@@ -1847,7 +1872,7 @@ refill_rx_ring:
 		}
 	}
 	/* re-enable the potentially idle receive state matchine */
-	outl(RxENA | inl(ioaddr + cr), ioaddr + cr );
+	sw32(cr , RxENA | sr32(cr));
 
 	return 0;
 }
@@ -1932,31 +1957,31 @@ static void sis900_finish_xmit (struct net_device *net_dev)
 
 static int sis900_close(struct net_device *net_dev)
 {
-	long ioaddr = net_dev->base_addr;
 	struct sis900_private *sis_priv = netdev_priv(net_dev);
+	struct pci_dev *pdev = sis_priv->pci_dev;
+	void __iomem *ioaddr = sis_priv->ioaddr;
 	struct sk_buff *skb;
 	int i;
 
 	netif_stop_queue(net_dev);
 
 	/* Disable interrupts by clearing the interrupt mask. */
-	outl(0x0000, ioaddr + imr);
-	outl(0x0000, ioaddr + ier);
+	sw32(imr, 0x0000);
+	sw32(ier, 0x0000);
 
 	/* Stop the chip's Tx and Rx Status Machine */
-	outl(RxDIS | TxDIS | inl(ioaddr + cr), ioaddr + cr);
+	sw32(cr, RxDIS | TxDIS | sr32(cr));
 
 	del_timer(&sis_priv->timer);
 
-	free_irq(net_dev->irq, net_dev);
+	free_irq(pdev->irq, net_dev);
 
 	/* Free Tx and RX skbuff */
 	for (i = 0; i < NUM_RX_DESC; i++) {
 		skb = sis_priv->rx_skbuff[i];
 		if (skb) {
-			pci_unmap_single(sis_priv->pci_dev,
-				sis_priv->rx_ring[i].bufptr,
-				RX_BUF_SIZE, PCI_DMA_FROMDEVICE);
+			pci_unmap_single(pdev, sis_priv->rx_ring[i].bufptr,
+					 RX_BUF_SIZE, PCI_DMA_FROMDEVICE);
 			dev_kfree_skb(skb);
 			sis_priv->rx_skbuff[i] = NULL;
 		}
@@ -1964,9 +1989,8 @@ static int sis900_close(struct net_device *net_dev)
 	for (i = 0; i < NUM_TX_DESC; i++) {
 		skb = sis_priv->tx_skbuff[i];
 		if (skb) {
-			pci_unmap_single(sis_priv->pci_dev,
-				sis_priv->tx_ring[i].bufptr, skb->len,
-				PCI_DMA_TODEVICE);
+			pci_unmap_single(pdev, sis_priv->tx_ring[i].bufptr,
+					 skb->len, PCI_DMA_TODEVICE);
 			dev_kfree_skb(skb);
 			sis_priv->tx_skbuff[i] = NULL;
 		}
@@ -2055,14 +2079,14 @@ static int sis900_nway_reset(struct net_device *net_dev)
 static int sis900_set_wol(struct net_device *net_dev, struct ethtool_wolinfo *wol)
 {
 	struct sis900_private *sis_priv = netdev_priv(net_dev);
-	long pmctrl_addr = net_dev->base_addr + pmctrl;
+	void __iomem *ioaddr = sis_priv->ioaddr;
 	u32 cfgpmcsr = 0, pmctrl_bits = 0;
 
 	if (wol->wolopts == 0) {
 		pci_read_config_dword(sis_priv->pci_dev, CFGPMCSR, &cfgpmcsr);
 		cfgpmcsr &= ~PME_EN;
 		pci_write_config_dword(sis_priv->pci_dev, CFGPMCSR, cfgpmcsr);
-		outl(pmctrl_bits, pmctrl_addr);
+		sw32(pmctrl, pmctrl_bits);
 		if (netif_msg_wol(sis_priv))
 			printk(KERN_DEBUG "%s: Wake on LAN disabled\n", net_dev->name);
 		return 0;
@@ -2077,7 +2101,7 @@ static int sis900_set_wol(struct net_device *net_dev, struct ethtool_wolinfo *wo
 	if (wol->wolopts & WAKE_PHY)
 		pmctrl_bits |= LINKON;
 
-	outl(pmctrl_bits, pmctrl_addr);
+	sw32(pmctrl, pmctrl_bits);
 
 	pci_read_config_dword(sis_priv->pci_dev, CFGPMCSR, &cfgpmcsr);
 	cfgpmcsr |= PME_EN;
@@ -2090,10 +2114,11 @@ static int sis900_set_wol(struct net_device *net_dev, struct ethtool_wolinfo *wo
 
 static void sis900_get_wol(struct net_device *net_dev, struct ethtool_wolinfo *wol)
 {
-	long pmctrl_addr = net_dev->base_addr + pmctrl;
+	struct sis900_private *sp = netdev_priv(net_dev);
+	void __iomem *ioaddr = sp->ioaddr;
 	u32 pmctrl_bits;
 
-	pmctrl_bits = inl(pmctrl_addr);
+	pmctrl_bits = sr32(pmctrl);
 	if (pmctrl_bits & MAGICPKT)
 		wol->wolopts |= WAKE_MAGIC;
 	if (pmctrl_bits & LINKON)
@@ -2279,8 +2304,8 @@ static inline u16 sis900_mcast_bitnr(u8 *addr, u8 revision)
 
 static void set_rx_mode(struct net_device *net_dev)
 {
-	long ioaddr = net_dev->base_addr;
 	struct sis900_private *sis_priv = netdev_priv(net_dev);
+	void __iomem *ioaddr = sis_priv->ioaddr;
 	u16 mc_filter[16] = {0};	/* 256/128 bits multicast hash table */
 	int i, table_entries;
 	u32 rx_mode;
@@ -2322,24 +2347,24 @@ static void set_rx_mode(struct net_device *net_dev)
 	/* update Multicast Hash Table in Receive Filter */
 	for (i = 0; i < table_entries; i++) {
                 /* why plus 0x04 ??, That makes the correct value for hash table. */
-		outl((u32)(0x00000004+i) << RFADDR_shift, ioaddr + rfcr);
-		outl(mc_filter[i], ioaddr + rfdr);
+		sw32(rfcr, (u32)(0x00000004 + i) << RFADDR_shift);
+		sw32(rfdr, mc_filter[i]);
 	}
 
-	outl(RFEN | rx_mode, ioaddr + rfcr);
+	sw32(rfcr, RFEN | rx_mode);
 
 	/* sis900 is capable of looping back packets at MAC level for
 	 * debugging purpose */
 	if (net_dev->flags & IFF_LOOPBACK) {
 		u32 cr_saved;
 		/* We must disable Tx/Rx before setting loopback mode */
-		cr_saved = inl(ioaddr + cr);
-		outl(cr_saved | TxDIS | RxDIS, ioaddr + cr);
+		cr_saved = sr32(cr);
+		sw32(cr, cr_saved | TxDIS | RxDIS);
 		/* enable loopback */
-		outl(inl(ioaddr + txcfg) | TxMLB, ioaddr + txcfg);
-		outl(inl(ioaddr + rxcfg) | RxATX, ioaddr + rxcfg);
+		sw32(txcfg, sr32(txcfg) | TxMLB);
+		sw32(rxcfg, sr32(rxcfg) | RxATX);
 		/* restore cr */
-		outl(cr_saved, ioaddr + cr);
+		sw32(cr, cr_saved);
 	}
 }
 
@@ -2355,26 +2380,25 @@ static void set_rx_mode(struct net_device *net_dev)
 static void sis900_reset(struct net_device *net_dev)
 {
 	struct sis900_private *sis_priv = netdev_priv(net_dev);
-	long ioaddr = net_dev->base_addr;
-	int i = 0;
+	void __iomem *ioaddr = sis_priv->ioaddr;
 	u32 status = TxRCMP | RxRCMP;
+	int i;
 
-	outl(0, ioaddr + ier);
-	outl(0, ioaddr + imr);
-	outl(0, ioaddr + rfcr);
+	sw32(ier, 0);
+	sw32(imr, 0);
+	sw32(rfcr, 0);
 
-	outl(RxRESET | TxRESET | RESET | inl(ioaddr + cr), ioaddr + cr);
+	sw32(cr, RxRESET | TxRESET | RESET | sr32(cr));
 
 	/* Check that the chip has finished the reset. */
-	while (status && (i++ < 1000)) {
-		status ^= (inl(isr + ioaddr) & status);
-	}
+	for (i = 0; status && (i < 1000); i++)
+		status ^= sr32(isr) & status;
 
-	if( (sis_priv->chipset_rev >= SIS635A_900_REV) ||
-			(sis_priv->chipset_rev == SIS900B_900_REV) )
-		outl(PESEL | RND_CNT, ioaddr + cfg);
+	if (sis_priv->chipset_rev >= SIS635A_900_REV ||
+	    sis_priv->chipset_rev == SIS900B_900_REV)
+		sw32(cfg, PESEL | RND_CNT);
 	else
-		outl(PESEL, ioaddr + cfg);
+		sw32(cfg, PESEL);
 }
 
 /**
@@ -2388,10 +2412,12 @@ static void __devexit sis900_remove(struct pci_dev *pci_dev)
 {
 	struct net_device *net_dev = pci_get_drvdata(pci_dev);
 	struct sis900_private *sis_priv = netdev_priv(net_dev);
-	struct mii_phy *phy = NULL;
+
+	unregister_netdev(net_dev);
 
 	while (sis_priv->first_mii) {
-		phy = sis_priv->first_mii;
+		struct mii_phy *phy = sis_priv->first_mii;
+
 		sis_priv->first_mii = phy->next;
 		kfree(phy);
 	}
@@ -2400,7 +2426,7 @@ static void __devexit sis900_remove(struct pci_dev *pci_dev)
 		sis_priv->rx_ring_dma);
 	pci_free_consistent(pci_dev, TX_TOTAL_SIZE, sis_priv->tx_ring,
 		sis_priv->tx_ring_dma);
-	unregister_netdev(net_dev);
+	pci_iounmap(pci_dev, sis_priv->ioaddr);
 	free_netdev(net_dev);
 	pci_release_regions(pci_dev);
 	pci_set_drvdata(pci_dev, NULL);
@@ -2411,7 +2437,8 @@ static void __devexit sis900_remove(struct pci_dev *pci_dev)
 static int sis900_suspend(struct pci_dev *pci_dev, pm_message_t state)
 {
 	struct net_device *net_dev = pci_get_drvdata(pci_dev);
-	long ioaddr = net_dev->base_addr;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
+	void __iomem *ioaddr = sis_priv->ioaddr;
 
 	if(!netif_running(net_dev))
 		return 0;
@@ -2420,7 +2447,7 @@ static int sis900_suspend(struct pci_dev *pci_dev, pm_message_t state)
 	netif_device_detach(net_dev);
 
 	/* Stop the chip's Tx and Rx Status Machine */
-	outl(RxDIS | TxDIS | inl(ioaddr + cr), ioaddr + cr);
+	sw32(cr, RxDIS | TxDIS | sr32(cr));
 
 	pci_set_power_state(pci_dev, PCI_D3hot);
 	pci_save_state(pci_dev);
@@ -2432,7 +2459,7 @@ static int sis900_resume(struct pci_dev *pci_dev)
 {
 	struct net_device *net_dev = pci_get_drvdata(pci_dev);
 	struct sis900_private *sis_priv = netdev_priv(net_dev);
-	long ioaddr = net_dev->base_addr;
+	void __iomem *ioaddr = sis_priv->ioaddr;
 
 	if(!netif_running(net_dev))
 		return 0;
@@ -2453,9 +2480,9 @@ static int sis900_resume(struct pci_dev *pci_dev)
 	sis900_set_mode(ioaddr, HW_SPEED_10_MBPS, FDX_CAPABLE_HALF_SELECTED);
 
 	/* Enable all known interrupts by setting the interrupt mask. */
-	outl((RxSOVR|RxORN|RxERR|RxOK|TxURN|TxERR|TxIDLE), ioaddr + imr);
-	outl(RxENA | inl(ioaddr + cr), ioaddr + cr);
-	outl(IE, ioaddr + ier);
+	sw32(imr, RxSOVR | RxORN | RxERR | RxOK | TxURN | TxERR | TxIDLE);
+	sw32(cr, RxENA | sr32(cr));
+	sw32(ier, IE);
 
 	sis900_check_mode(net_dev, sis_priv->mii);
 
-- 
1.7.7.6
