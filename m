From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [RFT] Realtek 8168 ethernet support
Date: Mon, 12 Jun 2006 01:30:22 +0200
Message-ID: <20060611233022.GA11776@electric-eye.fr.zoreil.com>
References: <20060601200200.A0E0689D05D@zog.reactivated.net> <20060608143133.7e36a0b7.rdunlap@xenotime.net> <4488DF85.3090901@garzik.org> <20060609183358.GA5835@electric-eye.fr.zoreil.com> <4489C290.6020705@garzik.org> <20060610120523.GA24288@electric-eye.fr.zoreil.com> <20060610224811.GA3256@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Randy.Dunlap" <rdunlap@xenotime.net>,
	Daniel Drake <dsd@gentoo.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:50607 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1751133AbWFKXd1
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Jun 2006 19:33:27 -0400
To: Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
In-Reply-To: <20060610224811.GA3256@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The patch below agaisnt 2.6.17-rc6 includes the following changes:

commit 3072cc0aba3ac0c944e196a63c4154ca5746ec0b

    r8169: sync with vendor's driver
    
    - add several PCI ID for the PCI-E adapters ;
    - new identification strings ;
    - the RTL_GIGA_MAC_VER_ defines have been renamed to closely match the
      out-of-tree driver. It makes the comparison less hairy ;
    - various magic ;
    - the PCI region for the device with PCI ID 0x8136 is guessed.
      Explanation: the in-kernel Linux driver is written to allow MM register
      accesses and avoid the IO tax. The relevant BAR register was found at
      base address 1 for the plain-old PCI 8169. User reported lspci show that
      it is found at base address 2 for the new Gigabit PCI-E 816{8/9}.
      Typically:
      01:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd.: Unknown device 8168 (rev 01)
              Subsystem: Unknown device 1631:e015
              Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
              Status: Cap+ 66Mhz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
              Latency: 0, cache line size 20
              Interrupt: pin A routed to IRQ 16
              Region 0: I/O ports at b800 [size=256]
              Region 2: Memory at ff7ff000 (64-bit, non-prefetchable) [size=4K]
              ^^^^^^^^
      So far I have not received any lspci report for the 0x8136 and
      Realtek's driver do not help: be it under BSD or Linux, their r1000 driver
      include a USE_IO_SPACE #define but the bar address is always hardcoded
      to 1 in the MM case. :o/
    
    Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

commit 33857396c4f7d171f4ccaca86356df5fe2fdd304

    r8169: remove rtl8169_init_board
    
    Rationale:
    - its signature is not exactly pretty;
    - it has no knowledge of pci_device_id;
    - kiss 23 lines good bye.
    
    Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

commit af50f4372644c3c18c2af697a933c90f2a96be77

    r8169: hardware flow control
    
    The datasheet suggests that the device handles the hardware flow
    control almost automagically. User report a different story, so
    let's try to twiddle the mii registers.
    
    Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

commit d1e6ebbea2297df970e52823e1d8c9af62b0548d

    r8169: RX fifo overflow recovery
    
    Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

commit 17fb3bf33149eb2cb1a37ff94ab236ab01f91a40

    r8169: mac address change support
    
    Fix for http://bugzilla.kernel.org/show_bug.cgi?id=6032.
    
    Cc: Tim Mattox <tmattox@gmail.com>
    Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

The patch is for review only: mac address change apart, I need to
test it and it will surely conflict with jeff#netdev because of a
recently added PCI ID.

The patches are available at:
http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.17-rc6/r8169

or:

git://electric-eye.fr.zoreil.com/home/romieu/linux-2.6.git r8169

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 0ad3310..53a33c5 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -150,11 +150,16 @@ #define RTL_R16(reg)		readw (ioaddr + (r
 #define RTL_R32(reg)		((unsigned long) readl (ioaddr + (reg)))
 
 enum mac_version {
-	RTL_GIGA_MAC_VER_B = 0x00,
-	/* RTL_GIGA_MAC_VER_C = 0x03, */
-	RTL_GIGA_MAC_VER_D = 0x01,
-	RTL_GIGA_MAC_VER_E = 0x02,
-	RTL_GIGA_MAC_VER_X = 0x04	/* Greater than RTL_GIGA_MAC_VER_E */
+	RTL_GIGA_MAC_VER_01 = 0x00,
+	RTL_GIGA_MAC_VER_02 = 0x01,
+	RTL_GIGA_MAC_VER_03 = 0x02,
+	RTL_GIGA_MAC_VER_04 = 0x03,
+	RTL_GIGA_MAC_VER_05 = 0x04,
+	RTL_GIGA_MAC_VER_11 = 0x0b,
+	RTL_GIGA_MAC_VER_12 = 0x0c,
+	RTL_GIGA_MAC_VER_13 = 0x0d,
+	RTL_GIGA_MAC_VER_14 = 0x0e,
+	RTL_GIGA_MAC_VER_15 = 0x0f
 };
 
 enum phy_version {
@@ -166,7 +171,6 @@ enum phy_version {
 	RTL_GIGA_PHY_VER_H = 0x08, /* PHY Reg 0x03 bit0-3 == 0x0003 */
 };
 
-
 #define _R(NAME,MAC,MASK) \
 	{ .name = NAME, .mac_version = MAC, .RxConfigMask = MASK }
 
@@ -175,18 +179,28 @@ static const struct {
 	u8 mac_version;
 	u32 RxConfigMask;	/* Clears the bits supported by this chip */
 } rtl_chip_info[] = {
-	_R("RTL8169",		RTL_GIGA_MAC_VER_B, 0xff7e1880),
-	_R("RTL8169s/8110s",	RTL_GIGA_MAC_VER_D, 0xff7e1880),
-	_R("RTL8169s/8110s",	RTL_GIGA_MAC_VER_E, 0xff7e1880),
-	_R("RTL8169s/8110s",	RTL_GIGA_MAC_VER_X, 0xff7e1880),
+	_R("RTL8169",		RTL_GIGA_MAC_VER_01, 0xff7e1880),
+	_R("RTL8169s/8110s",	RTL_GIGA_MAC_VER_02, 0xff7e1880),
+	_R("RTL8169s/8110s",	RTL_GIGA_MAC_VER_03, 0xff7e1880),
+	_R("RTL8169sb/8110sb",	RTL_GIGA_MAC_VER_04, 0xff7e1880),
+	_R("RTL8169sc/8110sc",	RTL_GIGA_MAC_VER_05, 0xff7e1880),
+	_R("RTL8168b/8111b",	RTL_GIGA_MAC_VER_11, 0xff7e1880), // PCI-E
+	_R("RTL8168b/8111b",	RTL_GIGA_MAC_VER_12, 0xff7e1880), // PCI-E
+	_R("RTL8101e",		RTL_GIGA_MAC_VER_13, 0xff7e1880), // PCI-E 8139
+	_R("RTL8100e",		RTL_GIGA_MAC_VER_14, 0xff7e1880), // PCI-E 8139
+	_R("RTL8100e",		RTL_GIGA_MAC_VER_15, 0xff7e1880)  // PCI-E 8139
 };
 #undef _R
 
 static struct pci_device_id rtl8169_pci_tbl[] = {
-	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8169), },
-	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK,	0x4300), },
-	{ PCI_DEVICE(0x16ec,			0x0116), },
-	{ PCI_VENDOR_ID_LINKSYS,		0x1032, PCI_ANY_ID, 0x0024, },
+	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8136), 0, 0, 2 },
+	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8167), 0, 0, 2 },
+	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8168), 0, 0, 2 },
+	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8169), 0, 0, 1 },
+	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK,	0x4300), 0, 0, 1 },
+	{ PCI_DEVICE(0x16ec,			0x0116), 0, 0, 1 },
+	{ PCI_VENDOR_ID_LINKSYS,		0x1032,
+		PCI_ANY_ID, 0x0024, 0, 0, 1 },
 	{0,},
 };
 
@@ -256,10 +270,11 @@ enum RTL8169_register_content {
 	RxOK = 0x01,
 
 	/* RxStatusDesc */
-	RxRES = 0x00200000,
-	RxCRC = 0x00080000,
-	RxRUNT = 0x00100000,
-	RxRWT = 0x00400000,
+	RxFOVF	= (1 << 23),
+	RxRWT	= (1 << 22),
+	RxRES	= (1 << 21),
+	RxRUNT	= (1 << 20),
+	RxCRC	= (1 << 19),
 
 	/* ChipCmdBits */
 	CmdReset = 0x10,
@@ -345,6 +360,7 @@ enum RTL8169_register_content {
 	PHY_Cap_100_Full = 0x0100,
 
 	/* PHY_1000_CTRL_REG = 9 */
+	PHY_Cap_1000_Half = 0x0100,
 	PHY_Cap_1000_Full = 0x0200,
 
 	PHY_Cap_Null = 0x0,
@@ -748,27 +764,47 @@ static int rtl8169_set_speed_xmii(struct
 	auto_nego &= ~(PHY_Cap_10_Half | PHY_Cap_10_Full |
 		       PHY_Cap_100_Half | PHY_Cap_100_Full);
 	giga_ctrl = mdio_read(ioaddr, PHY_1000_CTRL_REG);
-	giga_ctrl &= ~(PHY_Cap_1000_Full | PHY_Cap_Null);
+	giga_ctrl &= ~(PHY_Cap_1000_Full | PHY_Cap_1000_Half | PHY_Cap_Null);
 
 	if (autoneg == AUTONEG_ENABLE) {
 		auto_nego |= (PHY_Cap_10_Half | PHY_Cap_10_Full |
 			      PHY_Cap_100_Half | PHY_Cap_100_Full);
-		giga_ctrl |= PHY_Cap_1000_Full;
+		giga_ctrl |= PHY_Cap_1000_Full | PHY_Cap_1000_Half;
 	} else {
 		if (speed == SPEED_10)
 			auto_nego |= PHY_Cap_10_Half | PHY_Cap_10_Full;
 		else if (speed == SPEED_100)
 			auto_nego |= PHY_Cap_100_Half | PHY_Cap_100_Full;
 		else if (speed == SPEED_1000)
-			giga_ctrl |= PHY_Cap_1000_Full;
+			giga_ctrl |= PHY_Cap_1000_Full | PHY_Cap_1000_Half;
 
 		if (duplex == DUPLEX_HALF)
 			auto_nego &= ~(PHY_Cap_10_Full | PHY_Cap_100_Full);
 
 		if (duplex == DUPLEX_FULL)
 			auto_nego &= ~(PHY_Cap_10_Half | PHY_Cap_100_Half);
+
+		/* This tweak comes straight from Realtek's driver. */
+		if ((speed == SPEED_100) && (duplex == DUPLEX_HALF) &&
+		    (tp->mac_version == RTL_GIGA_MAC_VER_13)) {
+			auto_nego = PHY_Cap_100_Half | 0x01;
+		}
 	}
 
+	/* The 8100e/8101e do Fast Ethernet only. */
+	if ((tp->mac_version == RTL_GIGA_MAC_VER_13) ||
+	    (tp->mac_version == RTL_GIGA_MAC_VER_14) ||
+	    (tp->mac_version == RTL_GIGA_MAC_VER_15)) {
+		if ((giga_ctrl & (PHY_Cap_1000_Full | PHY_Cap_1000_Half)) &&
+		    netif_msg_link(tp)) {
+			printk(KERN_INFO "%s: PHY does not support 1000Mbps.\n",
+			       dev->name);
+		}
+		giga_ctrl &= ~(PHY_Cap_1000_Full | PHY_Cap_1000_Half);
+	}
+
+	auto_nego |= ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM;
+
 	tp->phy_auto_nego_reg = auto_nego;
 	tp->phy_1000_ctrl_reg = giga_ctrl;
 
@@ -960,6 +996,11 @@ static void rtl8169_gset_xmii(struct net
 	else if (status & _10bps)
 		cmd->speed = SPEED_10;
 
+	if (status & TxFlowCtrl)
+		cmd->advertising |= ADVERTISED_Asym_Pause;
+	if (status & RxFlowCtrl)
+		cmd->advertising |= ADVERTISED_Pause;
+
 	cmd->duplex = ((status & _1000bpsF) || (status & FullDup)) ?
 		      DUPLEX_FULL : DUPLEX_HALF;
 }
@@ -1139,10 +1180,16 @@ static void rtl8169_get_mac_version(stru
 		u32 mask;
 		int mac_version;
 	} mac_info[] = {
-		{ 0x1 << 28,	RTL_GIGA_MAC_VER_X },
-		{ 0x1 << 26,	RTL_GIGA_MAC_VER_E },
-		{ 0x1 << 23,	RTL_GIGA_MAC_VER_D }, 
-		{ 0x00000000,	RTL_GIGA_MAC_VER_B } /* Catch-all */
+		{ 0x38800000,	RTL_GIGA_MAC_VER_15 },
+		{ 0x38000000,	RTL_GIGA_MAC_VER_12 },
+		{ 0x34000000,	RTL_GIGA_MAC_VER_13 },
+		{ 0x30800000,	RTL_GIGA_MAC_VER_14 },
+		{ 0x30000000,   RTL_GIGA_MAC_VER_11 },
+		{ 0x18000000,	RTL_GIGA_MAC_VER_05 },
+		{ 0x10000000,	RTL_GIGA_MAC_VER_04 },
+		{ 0x04000000,	RTL_GIGA_MAC_VER_03 },
+		{ 0x00800000,	RTL_GIGA_MAC_VER_02 },
+		{ 0x00000000,	RTL_GIGA_MAC_VER_01 }	/* Catch-all */
 	}, *p = mac_info;
 	u32 reg;
 
@@ -1154,24 +1201,7 @@ static void rtl8169_get_mac_version(stru
 
 static void rtl8169_print_mac_version(struct rtl8169_private *tp)
 {
-	struct {
-		int version;
-		char *msg;
-	} mac_print[] = {
-		{ RTL_GIGA_MAC_VER_E, "RTL_GIGA_MAC_VER_E" },
-		{ RTL_GIGA_MAC_VER_D, "RTL_GIGA_MAC_VER_D" },
-		{ RTL_GIGA_MAC_VER_B, "RTL_GIGA_MAC_VER_B" },
-		{ 0, NULL }
-	}, *p;
-
-	for (p = mac_print; p->msg; p++) {
-		if (tp->mac_version == p->version) {
-			dprintk("mac_version == %s (%04d)\n", p->msg,
-				  p->version);
-			return;
-		}
-	}
-	dprintk("mac_version == Unknown\n");
+	dprintk("mac_version = 0x%02x\n", tp->mac_version);
 }
 
 static void rtl8169_get_phy_version(struct rtl8169_private *tp, void __iomem *ioaddr)
@@ -1256,7 +1286,7 @@ static void rtl8169_hw_phy_config(struct
 	rtl8169_print_mac_version(tp);
 	rtl8169_print_phy_version(tp);
 
-	if (tp->mac_version <= RTL_GIGA_MAC_VER_B)
+	if (tp->mac_version <= RTL_GIGA_MAC_VER_01)
 		return;
 	if (tp->phy_version >= RTL_GIGA_PHY_VER_H)
 		return;
@@ -1266,7 +1296,7 @@ static void rtl8169_hw_phy_config(struct
 
 	/* Shazam ! */
 
-	if (tp->mac_version == RTL_GIGA_MAC_VER_X) {
+	if (tp->mac_version == RTL_GIGA_MAC_VER_04) {
 		mdio_write(ioaddr, 31, 0x0001);
 		mdio_write(ioaddr,  9, 0x273a);
 		mdio_write(ioaddr, 14, 0x7bfb);
@@ -1305,7 +1335,7 @@ static void rtl8169_phy_timer(unsigned l
 	void __iomem *ioaddr = tp->mmio_addr;
 	unsigned long timeout = RTL8169_PHY_TIMEOUT;
 
-	assert(tp->mac_version > RTL_GIGA_MAC_VER_B);
+	assert(tp->mac_version > RTL_GIGA_MAC_VER_01);
 	assert(tp->phy_version < RTL_GIGA_PHY_VER_H);
 
 	if (!(tp->phy_1000_ctrl_reg & PHY_Cap_1000_Full))
@@ -1341,7 +1371,7 @@ static inline void rtl8169_delete_timer(
 	struct rtl8169_private *tp = netdev_priv(dev);
 	struct timer_list *timer = &tp->timer;
 
-	if ((tp->mac_version <= RTL_GIGA_MAC_VER_B) ||
+	if ((tp->mac_version <= RTL_GIGA_MAC_VER_01) ||
 	    (tp->phy_version >= RTL_GIGA_PHY_VER_H))
 		return;
 
@@ -1353,7 +1383,7 @@ static inline void rtl8169_request_timer
 	struct rtl8169_private *tp = netdev_priv(dev);
 	struct timer_list *timer = &tp->timer;
 
-	if ((tp->mac_version <= RTL_GIGA_MAC_VER_B) ||
+	if ((tp->mac_version <= RTL_GIGA_MAC_VER_01) ||
 	    (tp->phy_version >= RTL_GIGA_PHY_VER_H))
 		return;
 
@@ -1381,6 +1411,41 @@ static void rtl8169_netpoll(struct net_d
 }
 #endif
 
+static void __rtl8169_set_mac_addr(struct net_device *dev, void __iomem *ioaddr)
+{
+	unsigned int i, j;
+
+	RTL_W8(Cfg9346, Cfg9346_Unlock);
+	for (i = 0; i < 2; i++) {
+		__le32 l = 0;
+
+		for (j = 0; j < 4; j++) {
+			l <<= 8;
+			l |= dev->dev_addr[4*i + j];
+		}
+		RTL_W32(MAC0 + 4*i, cpu_to_be32(l));
+	}
+	RTL_W8(Cfg9346, Cfg9346_Lock);
+}
+
+static int rtl8169_set_mac_addr(struct net_device *dev, void *p)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	struct sockaddr *addr = p;
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EINVAL;
+
+	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
+
+	if (netif_running(dev)) {
+		spin_lock_irq(&tp->lock);
+		__rtl8169_set_mac_addr(dev, tp->mmio_addr);
+		spin_unlock_irq(&tp->lock);
+	}
+	return 0;
+}
+
 static void rtl8169_release_board(struct pci_dev *pdev, struct net_device *dev,
 				  void __iomem *ioaddr)
 {
@@ -1390,23 +1455,61 @@ static void rtl8169_release_board(struct
 	free_netdev(dev);
 }
 
+static void rtl8169_init_phy(struct net_device *dev, struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+	static int board_idx = -1;
+	u8 autoneg, duplex;
+	u16 speed;
+
+	board_idx++;
+
+	rtl8169_hw_phy_config(dev);
+
+	dprintk("Set MAC Reg C+CR Offset 0x82h = 0x01h\n");
+	RTL_W8(0x82, 0x01);
+
+	if (tp->mac_version < RTL_GIGA_MAC_VER_03) {
+		dprintk("Set PCI Latency=0x40\n");
+		pci_write_config_byte(tp->pci_dev, PCI_LATENCY_TIMER, 0x40);
+	}
+
+	if (tp->mac_version == RTL_GIGA_MAC_VER_02) {
+		dprintk("Set MAC Reg C+CR Offset 0x82h = 0x01h\n");
+		RTL_W8(0x82, 0x01);
+		dprintk("Set PHY Reg 0x0bh = 0x00h\n");
+		mdio_write(ioaddr, 0x0b, 0x0000); //w 0x0b 15 0 0
+	}
+
+	rtl8169_link_option(board_idx, &autoneg, &speed, &duplex);
+
+	rtl8169_set_speed(dev, autoneg, speed, duplex);
+
+	if ((RTL_R8(PHYstatus) & TBI_Enable) && netif_msg_link(tp))
+		printk(KERN_INFO PFX "%s: TBI auto-negotiating\n", dev->name);
+}
+
 static int __devinit
-rtl8169_init_board(struct pci_dev *pdev, struct net_device **dev_out,
-		   void __iomem **ioaddr_out)
+rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
-	void __iomem *ioaddr;
-	struct net_device *dev;
+	const unsigned int region = ent->driver_data;
 	struct rtl8169_private *tp;
-	int rc = -ENOMEM, i, acpi_idle_state = 0, pm_cap;
+	struct net_device *dev;
+	void __iomem *ioaddr;
+	unsigned int i, pm_cap;
+	int rc;
 
-	assert(ioaddr_out != NULL);
+	if (netif_msg_drv(&debug)) {
+		printk(KERN_INFO "%s Gigabit Ethernet driver %s loaded\n",
+		       MODULENAME, RTL8169_VERSION);
+	}
 
-	/* dev zeroed in alloc_etherdev */
 	dev = alloc_etherdev(sizeof (*tp));
-	if (dev == NULL) {
+	if (!dev) {
 		if (netif_msg_drv(&debug))
 			printk(KERN_ERR PFX "unable to alloc new ethernet\n");
-		goto err_out;
+		rc = -ENOMEM;
+		goto out;
 	}
 
 	SET_MODULE_OWNER(dev);
@@ -1421,17 +1524,17 @@ rtl8169_init_board(struct pci_dev *pdev,
 			printk(KERN_ERR PFX "%s: enable failure\n",
 			       pci_name(pdev));
 		}
-		goto err_out_free_dev;
+		goto err_out_free_dev_1;
 	}
 
 	rc = pci_set_mwi(pdev);
 	if (rc < 0)
-		goto err_out_disable;
+		goto err_out_disable_2;
 
 	/* save power state before pci_enable_device overwrites it */
 	pm_cap = pci_find_capability(pdev, PCI_CAP_ID_PM);
 	if (pm_cap) {
-		u16 pwr_command;
+		u16 pwr_command, acpi_idle_state;
 
 		pci_read_config_word(pdev, pm_cap + PCI_PM_CTRL, &pwr_command);
 		acpi_idle_state = pwr_command & PCI_PM_CTRL_STATE_MASK;
@@ -1443,22 +1546,24 @@ rtl8169_init_board(struct pci_dev *pdev,
 	}
 
 	/* make sure PCI base addr 1 is MMIO */
-	if (!(pci_resource_flags(pdev, 1) & IORESOURCE_MEM)) {
+	if (!(pci_resource_flags(pdev, region) & IORESOURCE_MEM)) {
 		if (netif_msg_probe(tp)) {
 			printk(KERN_ERR PFX
-			       "region #1 not an MMIO resource, aborting\n");
+			       "region #%d not an MMIO resource, aborting\n",
+			       region);
 		}
 		rc = -ENODEV;
-		goto err_out_mwi;
+		goto err_out_mwi_3;
 	}
+
 	/* check for weird/broken PCI region reporting */
-	if (pci_resource_len(pdev, 1) < R8169_REGS_SIZE) {
+	if (pci_resource_len(pdev, region) < R8169_REGS_SIZE) {
 		if (netif_msg_probe(tp)) {
 			printk(KERN_ERR PFX
 			       "Invalid PCI region size(s), aborting\n");
 		}
 		rc = -ENODEV;
-		goto err_out_mwi;
+		goto err_out_mwi_3;
 	}
 
 	rc = pci_request_regions(pdev, MODULENAME);
@@ -1467,7 +1572,7 @@ rtl8169_init_board(struct pci_dev *pdev,
 			printk(KERN_ERR PFX "%s: could not request regions.\n",
 			       pci_name(pdev));
 		}
-		goto err_out_mwi;
+		goto err_out_mwi_3;
 	}
 
 	tp->cp_cmd = PCIMulRW | RxChkSum;
@@ -1483,19 +1588,19 @@ rtl8169_init_board(struct pci_dev *pdev,
 				printk(KERN_ERR PFX
 				       "DMA configuration failed.\n");
 			}
-			goto err_out_free_res;
+			goto err_out_free_res_4;
 		}
 	}
 
 	pci_set_master(pdev);
 
 	/* ioremap MMIO region */
-	ioaddr = ioremap(pci_resource_start(pdev, 1), R8169_REGS_SIZE);
-	if (ioaddr == NULL) {
+	ioaddr = ioremap(pci_resource_start(pdev, region), R8169_REGS_SIZE);
+	if (!ioaddr) {
 		if (netif_msg_probe(tp))
 			printk(KERN_ERR PFX "cannot remap MMIO, aborting\n");
 		rc = -EIO;
-		goto err_out_free_res;
+		goto err_out_free_res_4;
 	}
 
 	/* Unneeded ? Don't mess with Mrs. Murphy. */
@@ -1538,56 +1643,6 @@ rtl8169_init_board(struct pci_dev *pdev,
 	RTL_W8(Config5, RTL_R8(Config5) & PMEStatus);
 	RTL_W8(Cfg9346, Cfg9346_Lock);
 
-	*ioaddr_out = ioaddr;
-	*dev_out = dev;
-out:
-	return rc;
-
-err_out_free_res:
-	pci_release_regions(pdev);
-
-err_out_mwi:
-	pci_clear_mwi(pdev);
-
-err_out_disable:
-	pci_disable_device(pdev);
-
-err_out_free_dev:
-	free_netdev(dev);
-err_out:
-	*ioaddr_out = NULL;
-	*dev_out = NULL;
-	goto out;
-}
-
-static int __devinit
-rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
-{
-	struct net_device *dev = NULL;
-	struct rtl8169_private *tp;
-	void __iomem *ioaddr = NULL;
-	static int board_idx = -1;
-	u8 autoneg, duplex;
-	u16 speed;
-	int i, rc;
-
-	assert(pdev != NULL);
-	assert(ent != NULL);
-
-	board_idx++;
-
-	if (netif_msg_drv(&debug)) {
-		printk(KERN_INFO "%s Gigabit Ethernet driver %s loaded\n",
-		       MODULENAME, RTL8169_VERSION);
-	}
-
-	rc = rtl8169_init_board(pdev, &dev, &ioaddr);
-	if (rc)
-		return rc;
-
-	tp = netdev_priv(dev);
-	assert(ioaddr != NULL);
-
 	if (RTL_R8(PHYstatus) & TBI_Enable) {
 		tp->set_speed = rtl8169_set_speed_tbi;
 		tp->get_settings = rtl8169_gset_tbi;
@@ -1616,6 +1671,7 @@ rtl8169_init_one(struct pci_dev *pdev, c
 	dev->stop = rtl8169_close;
 	dev->tx_timeout = rtl8169_tx_timeout;
 	dev->set_multicast_list = rtl8169_set_rx_mode;
+	dev->set_mac_address = rtl8169_set_mac_addr;
 	dev->watchdog_timeo = RTL8169_TX_TIMEOUT;
 	dev->irq = pdev->irq;
 	dev->base_addr = (unsigned long) ioaddr;
@@ -1643,15 +1699,8 @@ #endif
 	spin_lock_init(&tp->lock);
 
 	rc = register_netdev(dev);
-	if (rc) {
-		rtl8169_release_board(pdev, dev, ioaddr);
-		return rc;
-	}
-
-	if (netif_msg_probe(tp)) {
-		printk(KERN_DEBUG "%s: Identified chip type is '%s'.\n",
-		       dev->name, rtl_chip_info[tp->chipset].name);
-	}
+	if (rc < 0)
+		goto err_out_unmap_5;
 
 	pci_set_drvdata(pdev, dev);
 
@@ -1660,38 +1709,29 @@ #endif
 		       "%2.2x:%2.2x:%2.2x:%2.2x:%2.2x:%2.2x, "
 		       "IRQ %d\n",
 		       dev->name,
-		       rtl_chip_info[ent->driver_data].name,
+		       rtl_chip_info[tp->chipset].name,
 		       dev->base_addr,
 		       dev->dev_addr[0], dev->dev_addr[1],
 		       dev->dev_addr[2], dev->dev_addr[3],
 		       dev->dev_addr[4], dev->dev_addr[5], dev->irq);
 	}
 
-	rtl8169_hw_phy_config(dev);
-
-	dprintk("Set MAC Reg C+CR Offset 0x82h = 0x01h\n");
-	RTL_W8(0x82, 0x01);
-
-	if (tp->mac_version < RTL_GIGA_MAC_VER_E) {
-		dprintk("Set PCI Latency=0x40\n");
-		pci_write_config_byte(pdev, PCI_LATENCY_TIMER, 0x40);
-	}
+	rtl8169_init_phy(dev, tp);
 
-	if (tp->mac_version == RTL_GIGA_MAC_VER_D) {
-		dprintk("Set MAC Reg C+CR Offset 0x82h = 0x01h\n");
-		RTL_W8(0x82, 0x01);
-		dprintk("Set PHY Reg 0x0bh = 0x00h\n");
-		mdio_write(ioaddr, 0x0b, 0x0000); //w 0x0b 15 0 0
-	}
-
-	rtl8169_link_option(board_idx, &autoneg, &speed, &duplex);
-
-	rtl8169_set_speed(dev, autoneg, speed, duplex);
-	
-	if ((RTL_R8(PHYstatus) & TBI_Enable) && netif_msg_link(tp))
-		printk(KERN_INFO PFX "%s: TBI auto-negotiating\n", dev->name);
+out:
+	return rc;
 
-	return 0;
+err_out_unmap_5:
+	iounmap(ioaddr);
+err_out_free_res_4:
+	pci_release_regions(pdev);
+err_out_mwi_3:
+	pci_clear_mwi(pdev);
+err_out_disable_2:
+	pci_disable_device(pdev);
+err_out_free_dev_1:
+	free_netdev(dev);
+	goto out;
 }
 
 static void __devexit
@@ -1787,6 +1827,7 @@ rtl8169_hw_start(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
+	struct pci_dev *pdev = tp->pci_dev;
 	u32 i;
 
 	/* Soft reset the chip. */
@@ -1799,8 +1840,28 @@ rtl8169_hw_start(struct net_device *dev)
 		udelay(10);
 	}
 
+	if (tp->mac_version == RTL_GIGA_MAC_VER_13) {
+		pci_write_config_word(pdev, 0x68, 0x00);
+		pci_write_config_word(pdev, 0x69, 0x08);
+	}
+
+	/* Undocumented stuff. */
+	if (tp->mac_version == RTL_GIGA_MAC_VER_05) {
+		u16 cmd;
+
+		/* Realtek's r1000_n.c driver uses '&& 0x01' here. Well... */
+		if ((RTL_R8(Config2) & 0x07) & 0x01)
+			RTL_W32(0x7c, 0x0007ffff);
+
+		RTL_W32(0x7c, 0x0007ff00);
+
+		pci_read_config_word(pdev, PCI_COMMAND, &cmd);
+		cmd = cmd & 0xef;
+		pci_write_config_word(pdev, PCI_COMMAND, cmd);
+	}
+
+
 	RTL_W8(Cfg9346, Cfg9346_Unlock);
-	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
 	RTL_W8(EarlyTxThres, EarlyTxThld);
 
 	/* Low hurts. Let's disable the filtering. */
@@ -1815,17 +1876,18 @@ rtl8169_hw_start(struct net_device *dev)
 	RTL_W32(TxConfig,
 		(TX_DMA_BURST << TxDMAShift) | (InterFrameGap <<
 						TxInterFrameGapShift));
-	tp->cp_cmd |= RTL_R16(CPlusCmd);
-	RTL_W16(CPlusCmd, tp->cp_cmd);
 
-	if ((tp->mac_version == RTL_GIGA_MAC_VER_D) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_E)) {
+	tp->cp_cmd |= RTL_R16(CPlusCmd) | PCIMulRW;
+
+	if ((tp->mac_version == RTL_GIGA_MAC_VER_02) ||
+	    (tp->mac_version == RTL_GIGA_MAC_VER_03)) {
 		dprintk(KERN_INFO PFX "Set MAC Reg C+CR Offset 0xE0. "
 			"Bit-3 and bit-14 MUST be 1\n");
-		tp->cp_cmd |= (1 << 14) | PCIMulRW;
-		RTL_W16(CPlusCmd, tp->cp_cmd);
+		tp->cp_cmd |= (1 << 14);
 	}
 
+	RTL_W16(CPlusCmd, tp->cp_cmd);
+
 	/*
 	 * Undocumented corner. Supposedly:
 	 * (TxTimer << 12) | (TxPackets << 8) | (RxTimer << 4) | RxPackets
@@ -1836,6 +1898,7 @@ rtl8169_hw_start(struct net_device *dev)
 	RTL_W32(TxDescStartAddrHigh, ((u64) tp->TxPhyAddr >> 32));
 	RTL_W32(RxDescAddrLow, ((u64) tp->RxPhyAddr & DMA_32BIT_MASK));
 	RTL_W32(RxDescAddrHigh, ((u64) tp->RxPhyAddr >> 32));
+	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
 	RTL_W8(Cfg9346, Cfg9346_Lock);
 	udelay(10);
 
@@ -1849,6 +1912,8 @@ rtl8169_hw_start(struct net_device *dev)
 	/* Enable all known interrupts by setting the interrupt mask. */
 	RTL_W16(IntrMask, rtl8169_intr_mask);
 
+	__rtl8169_set_mac_addr(dev, ioaddr);
+
 	netif_start_queue(dev);
 }
 
@@ -2435,6 +2500,10 @@ rtl8169_rx_interrupt(struct net_device *
 				tp->stats.rx_length_errors++;
 			if (status & RxCRC)
 				tp->stats.rx_crc_errors++;
+			if (status & RxFOVF) {
+				rtl8169_schedule_work(dev, rtl8169_reset_task);
+				tp->stats.rx_fifo_errors++;
+			}
 			rtl8169_mark_to_asic(desc, tp->rx_buf_sz);
 		} else {
 			struct sk_buff *skb = tp->Rx_skbuff[entry];
@@ -2724,6 +2793,15 @@ rtl8169_set_rx_mode(struct net_device *d
 	tmp = rtl8169_rx_config | rx_mode |
 	      (RTL_R32(RxConfig) & rtl_chip_info[tp->chipset].RxConfigMask);
 
+	if ((tp->mac_version == RTL_GIGA_MAC_VER_11) ||
+	    (tp->mac_version == RTL_GIGA_MAC_VER_12) ||
+	    (tp->mac_version == RTL_GIGA_MAC_VER_13) ||
+	    (tp->mac_version == RTL_GIGA_MAC_VER_14) ||
+	    (tp->mac_version == RTL_GIGA_MAC_VER_15)) {
+		mc_filter[0] = 0xffffffff;
+		mc_filter[1] = 0xffffffff;
+	}
+
 	RTL_W32(RxConfig, tmp);
 	RTL_W32(MAR0 + 0, mc_filter[0]);
 	RTL_W32(MAR0 + 4, mc_filter[1]);
