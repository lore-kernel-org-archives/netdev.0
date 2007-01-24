From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [rft] r8169: merge release 6.001.00 of Realtek's driver - take #1
Date: Thu, 25 Jan 2007 00:17:19 +0100
Message-ID: <20070124231719.GA10010@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jeff@garzik.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:38081 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932880AbXAXXU3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Jan 2007 18:20:29 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Untested, straight from the "release early" dept. You have been warned.

Realtek's driver restricts itself to 0x8169 and 0x8167.
It won't be surprising if it breaks on anything else until
I merge the new 0x8168 and 0x8136 bits.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/r8169.c |  159 ++++++++++++++++++++++++++++++++++++++------------
 1 files changed, 121 insertions(+), 38 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 577babd..2f320de 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -150,11 +150,13 @@ static const int multicast_filter_limit = 32;
 #define RTL_R32(reg)		((unsigned long) readl (ioaddr + (reg)))
 
 enum mac_version {
-	RTL_GIGA_MAC_VER_01 = 0x00,
-	RTL_GIGA_MAC_VER_02 = 0x01,
-	RTL_GIGA_MAC_VER_03 = 0x02,
-	RTL_GIGA_MAC_VER_04 = 0x03,
-	RTL_GIGA_MAC_VER_05 = 0x04,
+	RTL_GIGA_MAC_VER_00 = 0x00,	// 8169
+	RTL_GIGA_MAC_VER_01 = 0x01,	// 8169S
+	RTL_GIGA_MAC_VER_02 = 0x02,	// 8110S
+	RTL_GIGA_MAC_VER_03 = 0x03,
+	RTL_GIGA_MAC_VER_04 = 0x04,	// 8169SB
+	RTL_GIGA_MAC_VER_05 = 0x05,	// 8169SCd
+	RTL_GIGA_MAC_VER_06 = 0x06,	// 8169SCe
 	RTL_GIGA_MAC_VER_11 = 0x0b,
 	RTL_GIGA_MAC_VER_12 = 0x0c,
 	RTL_GIGA_MAC_VER_13 = 0x0d,
@@ -179,11 +181,13 @@ static const struct {
 	u8 mac_version;
 	u32 RxConfigMask;	/* Clears the bits supported by this chip */
 } rtl_chip_info[] = {
-	_R("RTL8169",		RTL_GIGA_MAC_VER_01, 0xff7e1880),
+	_R("RTL8169",		RTL_GIGA_MAC_VER_00, 0xff7e1880),
+	_R("RTL8169s/8110s",	RTL_GIGA_MAC_VER_01, 0xff7e1880),
 	_R("RTL8169s/8110s",	RTL_GIGA_MAC_VER_02, 0xff7e1880),
-	_R("RTL8169s/8110s",	RTL_GIGA_MAC_VER_03, 0xff7e1880),
-	_R("RTL8169sb/8110sb",	RTL_GIGA_MAC_VER_04, 0xff7e1880),
+	_R("RTL8169sb/8110sb",	RTL_GIGA_MAC_VER_03, 0xff7e1880),
+	_R("RTL8169sc/8110sc",	RTL_GIGA_MAC_VER_04, 0xff7e1880),
 	_R("RTL8169sc/8110sc",	RTL_GIGA_MAC_VER_05, 0xff7e1880),
+	_R("RTL8169sc/8110sc",	RTL_GIGA_MAC_VER_06, 0xff7e1880),
 	_R("RTL8168b/8111b",	RTL_GIGA_MAC_VER_11, 0xff7e1880), // PCI-E
 	_R("RTL8168b/8111b",	RTL_GIGA_MAC_VER_12, 0xff7e1880), // PCI-E
 	_R("RTL8101e",		RTL_GIGA_MAC_VER_13, 0xff7e1880), // PCI-E 8139
@@ -231,6 +235,7 @@ static struct {
 
 enum RTL8169_registers {
 	MAC0 = 0,		/* Ethernet hardware address. */
+	MAC4 = 4,
 	MAR0 = 8,		/* Multicast filter. */
 	CounterAddrLow = 0x10,
 	CounterAddrHigh = 0x14,
@@ -322,6 +327,11 @@ enum RTL8169_register_content {
 	/* Config1 register p.24 */
 	PMEnable	= (1 << 0),	/* Power Management Enable */
 
+	/* Config2 register p. 25 */
+	PCI_Clock_66MHz	= 0x01,
+	PCI_Clock_33MHz	= 0x00,
+
+
 	/* Config3 register p.25 */
 	MagicPacket	= (1 << 5),	/* Wake up when receives a Magic Packet */
 	LinkUp		= (1 << 4),	/* Wake up when the cable connection is re-established */
@@ -1172,15 +1182,17 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp, void __iomem *io
 		{ 0x34000000,	RTL_GIGA_MAC_VER_13 },
 		{ 0x30800000,	RTL_GIGA_MAC_VER_14 },
 		{ 0x30000000,	RTL_GIGA_MAC_VER_11 },
+		{ 0x98000000,	RTL_GIGA_MAC_VER_05 },
 		{ 0x18000000,	RTL_GIGA_MAC_VER_05 },
-		{ 0x10000000,	RTL_GIGA_MAC_VER_04 },
-		{ 0x04000000,	RTL_GIGA_MAC_VER_03 },
-		{ 0x00800000,	RTL_GIGA_MAC_VER_02 },
-		{ 0x00000000,	RTL_GIGA_MAC_VER_01 }	/* Catch-all */
+		{ 0x18000000,	RTL_GIGA_MAC_VER_04 },
+		{ 0x10000000,	RTL_GIGA_MAC_VER_03 },
+		{ 0x04000000,	RTL_GIGA_MAC_VER_02 },
+		{ 0x00800000,	RTL_GIGA_MAC_VER_01 },
+		{ 0x00000000,	RTL_GIGA_MAC_VER_00 }	/* Catch-all */
 	}, *p = mac_info;
 	u32 reg;
 
-	reg = RTL_R32(TxConfig) & 0x7c800000;
+	reg = RTL_R32(TxConfig) & 0xfc800000;
 	while ((reg & p->mask) != p->mask)
 		p++;
 	tp->mac_version = p->mac_version;
@@ -1273,7 +1285,7 @@ static void rtl8169_hw_phy_config(struct net_device *dev)
 	rtl8169_print_mac_version(tp);
 	rtl8169_print_phy_version(tp);
 
-	if (tp->mac_version <= RTL_GIGA_MAC_VER_01)
+	if (tp->mac_version <= RTL_GIGA_MAC_VER_00)
 		return;
 	if (tp->phy_version >= RTL_GIGA_PHY_VER_H)
 		return;
@@ -1283,7 +1295,7 @@ static void rtl8169_hw_phy_config(struct net_device *dev)
 
 	/* Shazam ! */
 
-	if (tp->mac_version == RTL_GIGA_MAC_VER_04) {
+	if (tp->mac_version == RTL_GIGA_MAC_VER_03) {
 		mdio_write(ioaddr, 31, 0x0002);
 		mdio_write(ioaddr,  1, 0x90d0);
 		mdio_write(ioaddr, 31, 0x0000);
@@ -1317,7 +1329,7 @@ static void rtl8169_phy_timer(unsigned long __opaque)
 	void __iomem *ioaddr = tp->mmio_addr;
 	unsigned long timeout = RTL8169_PHY_TIMEOUT;
 
-	assert(tp->mac_version > RTL_GIGA_MAC_VER_01);
+	assert(tp->mac_version > RTL_GIGA_MAC_VER_00);
 	assert(tp->phy_version < RTL_GIGA_PHY_VER_H);
 
 	if (!(tp->phy_1000_ctrl_reg & ADVERTISE_1000FULL))
@@ -1353,7 +1365,7 @@ static inline void rtl8169_delete_timer(struct net_device *dev)
 	struct rtl8169_private *tp = netdev_priv(dev);
 	struct timer_list *timer = &tp->timer;
 
-	if ((tp->mac_version <= RTL_GIGA_MAC_VER_01) ||
+	if ((tp->mac_version <= RTL_GIGA_MAC_VER_00) ||
 	    (tp->phy_version >= RTL_GIGA_PHY_VER_H))
 		return;
 
@@ -1365,7 +1377,7 @@ static inline void rtl8169_request_timer(struct net_device *dev)
 	struct rtl8169_private *tp = netdev_priv(dev);
 	struct timer_list *timer = &tp->timer;
 
-	if ((tp->mac_version <= RTL_GIGA_MAC_VER_01) ||
+	if ((tp->mac_version <= RTL_GIGA_MAC_VER_00) ||
 	    (tp->phy_version >= RTL_GIGA_PHY_VER_H))
 		return;
 
@@ -1432,12 +1444,14 @@ static void rtl8169_init_phy(struct net_device *dev, struct rtl8169_private *tp)
 	dprintk("Set MAC Reg C+CR Offset 0x82h = 0x01h\n");
 	RTL_W8(0x82, 0x01);
 
-	if (tp->mac_version < RTL_GIGA_MAC_VER_03) {
+	if (tp->mac_version < RTL_GIGA_MAC_VER_02) {
 		dprintk("Set PCI Latency=0x40\n");
 		pci_write_config_byte(tp->pci_dev, PCI_LATENCY_TIMER, 0x40);
 	}
 
-	if (tp->mac_version == RTL_GIGA_MAC_VER_02) {
+	pci_write_config_byte(tp->pci_dev, PCI_CACHE_LINE_SIZE, 0x08);
+
+	if (tp->mac_version == RTL_GIGA_MAC_VER_01) {
 		dprintk("Set MAC Reg C+CR Offset 0x82h = 0x01h\n");
 		RTL_W8(0x82, 0x01);
 		dprintk("Set PHY Reg 0x0bh = 0x00h\n");
@@ -1454,6 +1468,36 @@ static void rtl8169_init_phy(struct net_device *dev, struct rtl8169_private *tp)
 		printk(KERN_INFO PFX "%s: TBI auto-negotiating\n", dev->name);
 }
 
+static void rtl8169_rar_set(struct rtl8169_private *tp, u8 *addr)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+	u32 low;
+	u32 high;
+
+	low  = addr[0] | (addr[1] << 8) | (addr[2] << 16) | (addr[3] << 24);
+	high = addr[4] | (addr[5] << 8);
+
+	RTL_W8(Cfg9346, Cfg9346_Unlock);
+	RTL_W32(MAC0, low);
+	RTL_W32(MAC4, high);
+	RTL_W8(Cfg9346, Cfg9346_Lock);
+}
+
+static int rtl8169_set_mac_address(struct net_device *dev, void *p)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	struct sockaddr *addr = p;
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+
+	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
+
+	rtl8169_rar_set(tp, dev->dev_addr);
+
+	return 0;
+}
+
 static int rtl8169_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -1665,6 +1709,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->irq = pdev->irq;
 	dev->base_addr = (unsigned long) ioaddr;
 	dev->change_mtu = rtl8169_change_mtu;
+	dev->set_mac_address = rtl8169_set_mac_address;
 
 #ifdef CONFIG_R8169_NAPI
 	dev->poll = rtl8169_poll;
@@ -1825,6 +1870,41 @@ static void rtl8169_set_rx_tx_config_registers(struct rtl8169_private *tp)
 		(InterFrameGap << TxInterFrameGapShift));
 }
 
+static void rtl8169_set_magic_reg(void __iomem *ioaddr, unsigned mac_version)
+{
+	struct {
+		u32 mac_version;
+		u32 clk66;
+		u32 val;
+	} cfg2_info [] = {
+		{ RTL_GIGA_MAC_VER_05, 0, 0x000fff00 },
+		{ RTL_GIGA_MAC_VER_05, 1, 0x000fffff },
+		{ RTL_GIGA_MAC_VER_06, 0, 0x00ffffff },
+		{ RTL_GIGA_MAC_VER_06, 1, 0x00ffff00 }
+	}, *p = cfg2_info;
+	unsigned int i;
+	u32 clk66;
+
+	clk66 = RTL_R8(Config2) & PCI_Clock_66MHz;
+	for (i = 0; i < ARRAY_SIZE(cfg2_info); i++) {
+		if ((p->mac_version == mac_version) && (p->clk66 == clk66)) {
+			RTL_W32(0x7c, p->val);
+			break;
+		}
+	}
+}
+
+static bool rtl8169_plain_old_8169(unsigned int mac_version)
+{
+	return ((mac_version == RTL_GIGA_MAC_VER_00) ||
+		(mac_version == RTL_GIGA_MAC_VER_01) ||
+		(mac_version == RTL_GIGA_MAC_VER_02) ||
+		(mac_version == RTL_GIGA_MAC_VER_03) || // FIXME: remove ?
+		(mac_version == RTL_GIGA_MAC_VER_04) ||
+		(mac_version == RTL_GIGA_MAC_VER_05) ||
+		(mac_version == RTL_GIGA_MAC_VER_06)) ? true : false;
+}
+
 static void rtl8169_hw_start(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -1843,10 +1923,8 @@ static void rtl8169_hw_start(struct net_device *dev)
 		msleep_interruptible(1);
 	}
 
-	if (tp->mac_version == RTL_GIGA_MAC_VER_05) {
+	if (tp->mac_version == RTL_GIGA_MAC_VER_04)
 		RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) | PCIMulRW);
-		pci_write_config_byte(pdev, PCI_CACHE_LINE_SIZE, 0x08);
-	}
 
 	if (tp->mac_version == RTL_GIGA_MAC_VER_13) {
 		pci_write_config_word(pdev, 0x68, 0x00);
@@ -1854,7 +1932,7 @@ static void rtl8169_hw_start(struct net_device *dev)
 	}
 
 	/* Undocumented stuff. */
-	if (tp->mac_version == RTL_GIGA_MAC_VER_05) {
+	if (tp->mac_version == RTL_GIGA_MAC_VER_04) {
 		/* Realtek's r1000_n.c driver uses '&& 0x01' here. Well... */
 		if ((RTL_R8(Config2) & 0x07) & 0x01)
 			RTL_W32(0x7c, 0x0007ffff);
@@ -1867,10 +1945,8 @@ static void rtl8169_hw_start(struct net_device *dev)
 	}
 
 	RTL_W8(Cfg9346, Cfg9346_Unlock);
-	if ((tp->mac_version == RTL_GIGA_MAC_VER_01) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_02) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_03) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_04))
+
+	if (rtl8169_plain_old_8169(tp->mac_version))
 		RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
 
 	RTL_W8(EarlyTxThres, EarlyTxThld);
@@ -1878,10 +1954,7 @@ static void rtl8169_hw_start(struct net_device *dev)
 	/* Low hurts. Let's disable the filtering. */
 	RTL_W16(RxMaxSize, 16383);
 
-	if ((tp->mac_version == RTL_GIGA_MAC_VER_01) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_02) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_03) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_04))
+	if (rtl8169_plain_old_8169(tp->mac_version))
 		rtl8169_set_rx_tx_config_registers(tp);
 
 	cmd = RTL_R16(CPlusCmd);
@@ -1889,8 +1962,10 @@ static void rtl8169_hw_start(struct net_device *dev)
 
 	tp->cp_cmd |= cmd | PCIMulRW;
 
-	if ((tp->mac_version == RTL_GIGA_MAC_VER_02) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_03)) {
+	rtl8169_set_magic_reg(ioaddr, tp->mac_version);
+
+	if ((tp->mac_version == RTL_GIGA_MAC_VER_01) ||
+	    (tp->mac_version == RTL_GIGA_MAC_VER_02)) {
 		dprintk(KERN_INFO PFX "Set MAC Reg C+CR Offset 0xE0. "
 			"Bit-3 and bit-14 MUST be 1\n");
 		tp->cp_cmd |= (1 << 14);
@@ -1914,10 +1989,7 @@ static void rtl8169_hw_start(struct net_device *dev)
 	RTL_W32(RxDescAddrHigh, ((u64) tp->RxPhyAddr >> 32));
 	RTL_W32(RxDescAddrLow, ((u64) tp->RxPhyAddr & DMA_32BIT_MASK));
 
-	if ((tp->mac_version != RTL_GIGA_MAC_VER_01) &&
-	    (tp->mac_version != RTL_GIGA_MAC_VER_02) &&
-	    (tp->mac_version != RTL_GIGA_MAC_VER_03) &&
-	    (tp->mac_version != RTL_GIGA_MAC_VER_04)) {
+	if (!rtl8169_plain_old_8169(tp->mac_version)) {
 		RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
 		rtl8169_set_rx_tx_config_registers(tp);
 	}
@@ -1937,6 +2009,9 @@ static void rtl8169_hw_start(struct net_device *dev)
 	/* Enable all known interrupts by setting the interrupt mask. */
 	RTL_W16(IntrMask, rtl8169_intr_mask);
 
+	if (rtl8169_plain_old_8169(tp->mac_version))
+		RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
+
 	netif_start_queue(dev);
 }
 
@@ -2582,6 +2657,14 @@ rtl8169_rx_interrupt(struct net_device *dev, struct rtl8169_private *tp,
 			tp->stats.rx_bytes += pkt_size;
 			tp->stats.rx_packets++;
 		}
+
+		/* Work around for AMD plateform. */
+		if ((desc->opts2 & 0xfffe000) &&
+		    (tp->mac_version == RTL_GIGA_MAC_VER_05)) {
+			desc->opts2 = 0;
+			cur_rx++;
+		}
+
 	}
 
 	count = cur_rx - tp->cur_rx;
-- 
1.4.4.4

