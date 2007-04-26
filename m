From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 03/12] r8169: merge with version 6.001.00 of Realtek's r8169 driver
Date: Thu, 26 Apr 2007 23:48:14 +0200
Message-ID: <20070426214814.GD7344@electric-eye.fr.zoreil.com>
References: <20070426205714.GA12701@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:58568 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755163AbXDZVwA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2007 17:52:00 -0400
Content-Disposition: inline
In-Reply-To: <20070426205714.GA12701@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- new identifier for the 8110SCe

- the PCI latency timer is set unconditionally. This part is identical
  in Realtek's r8168 (8.001.00) and r8101 (1.001.00)

- initialization of the cache line size register is for the 8169s only

- more magic in rtl_hw_start_8169

- it is not possible to factor out the setting of the the irq event mask
  with the 8168 and the 8101 any more. Pushed it into the hw_start handler.

- rtl_set_rx_tx_config_registers() and write to the ChipCmd register are
  issued identically for the whole 8169/8110 family: the 8110SCd/8110SCe
  are handled the same way

- work around for AMD platform.

Some registers definitions are let aside for later.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com>
---
 drivers/net/r8169.c |   90 +++++++++++++++++++++++++++++++--------------------
 1 files changed, 55 insertions(+), 35 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 05408f3..74973ef 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -156,6 +156,7 @@ enum mac_version {
 	RTL_GIGA_MAC_VER_03 = 0x03, // 8110S
 	RTL_GIGA_MAC_VER_04 = 0x04, // 8169SB
 	RTL_GIGA_MAC_VER_05 = 0x05, // 8110SCd
+	RTL_GIGA_MAC_VER_06 = 0x06, // 8110SCe
 	RTL_GIGA_MAC_VER_11 = 0x0b, // 8168Bb
 	RTL_GIGA_MAC_VER_12 = 0x0c, // 8168Be 8168Bf
 	RTL_GIGA_MAC_VER_13 = 0x0d, // 8101Eb 8101Ec
@@ -185,6 +186,7 @@ static const struct {
 	_R("RTL8169s/8110s",	RTL_GIGA_MAC_VER_03, 0xff7e1880), // 8110S
 	_R("RTL8169sb/8110sb",	RTL_GIGA_MAC_VER_04, 0xff7e1880), // 8169SB
 	_R("RTL8169sc/8110sc",	RTL_GIGA_MAC_VER_05, 0xff7e1880), // 8110SCd
+	_R("RTL8169sc/8110sc",	RTL_GIGA_MAC_VER_06, 0xff7e1880), // 8110SCe
 	_R("RTL8168b/8111b",	RTL_GIGA_MAC_VER_11, 0xff7e1880), // PCI-E
 	_R("RTL8168b/8111b",	RTL_GIGA_MAC_VER_12, 0xff7e1880), // PCI-E
 	_R("RTL8101e",		RTL_GIGA_MAC_VER_13, 0xff7e1880), // PCI-E 8139
@@ -328,6 +330,10 @@ enum RTL8169_register_content {
 	/* Config1 register p.24 */
 	PMEnable	= (1 << 0),	/* Power Management Enable */
 
+	/* Config2 register p. 25 */
+	PCI_Clock_66MHz = 0x01,
+	PCI_Clock_33MHz = 0x00,
+
 	/* Config3 register p.25 */
 	MagicPacket	= (1 << 5),	/* Wake up when receives a Magic Packet */
 	LinkUp		= (1 << 4),	/* Wake up when the cable connection is re-established */
@@ -1179,6 +1185,7 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp, void __iomem *io
 		{ 0x34000000,	RTL_GIGA_MAC_VER_13 },
 		{ 0x30800000,	RTL_GIGA_MAC_VER_14 },
 		{ 0x30000000,	RTL_GIGA_MAC_VER_11 },
+		{ 0x98000000,	RTL_GIGA_MAC_VER_06 },
 		{ 0x18000000,	RTL_GIGA_MAC_VER_05 },
 		{ 0x10000000,	RTL_GIGA_MAC_VER_04 },
 		{ 0x04000000,	RTL_GIGA_MAC_VER_03 },
@@ -1187,7 +1194,7 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp, void __iomem *io
 	}, *p = mac_info;
 	u32 reg;
 
-	reg = RTL_R32(TxConfig) & 0x7c800000;
+	reg = RTL_R32(TxConfig) & 0xfc800000;
 	while ((reg & p->mask) != p->mask)
 		p++;
 	tp->mac_version = p->mac_version;
@@ -1435,10 +1442,10 @@ static void rtl8169_init_phy(struct net_device *dev, struct rtl8169_private *tp)
 	dprintk("Set MAC Reg C+CR Offset 0x82h = 0x01h\n");
 	RTL_W8(0x82, 0x01);
 
-	if (tp->mac_version < RTL_GIGA_MAC_VER_03) {
-		dprintk("Set PCI Latency=0x40\n");
-		pci_write_config_byte(tp->pci_dev, PCI_LATENCY_TIMER, 0x40);
-	}
+	pci_write_config_byte(tp->pci_dev, PCI_LATENCY_TIMER, 0x40);
+
+	if (tp->mac_version <= RTL_GIGA_MAC_VER_06)
+		pci_write_config_byte(tp->pci_dev, PCI_CACHE_LINE_SIZE, 0x08);
 
 	if (tp->mac_version == RTL_GIGA_MAC_VER_02) {
 		dprintk("Set MAC Reg C+CR Offset 0x82h = 0x01h\n");
@@ -1855,9 +1862,6 @@ static void rtl_hw_start(struct net_device *dev)
 
 	tp->hw_start(dev);
 
-	/* Enable all known interrupts by setting the interrupt mask. */
-	RTL_W16(IntrMask, rtl8169_intr_mask);
-
 	netif_start_queue(dev);
 }
 
@@ -1891,31 +1895,41 @@ static void rtl_set_rx_max_size(void __iomem *ioaddr)
 	RTL_W16(RxMaxSize, 16383);
 }
 
+static void rtl8169_set_magic_reg(void __iomem *ioaddr, unsigned mac_version)
+{
+	struct {
+		u32 mac_version;
+		u32 clk;
+		u32 val;
+	} cfg2_info [] = {
+		{ RTL_GIGA_MAC_VER_05, PCI_Clock_33MHz, 0x000fff00 }, // 8110SCd
+		{ RTL_GIGA_MAC_VER_05, PCI_Clock_66MHz, 0x000fffff },
+		{ RTL_GIGA_MAC_VER_06, PCI_Clock_33MHz, 0x00ffff00 }, // 8110SCe
+		{ RTL_GIGA_MAC_VER_06, PCI_Clock_66MHz, 0x00ffffff }
+	}, *p = cfg2_info;
+	unsigned int i;
+	u32 clk;
+
+	clk = RTL_R8(Config2) & PCI_Clock_66MHz;
+	for (i = 0; i < ARRAY_SIZE(cfg2_info); i++) {
+		if ((p->mac_version == mac_version) && (p->clk == clk)) {
+			RTL_W32(0x7c, p->val);
+			break;
+		}
+	}
+}
+
 static void rtl_hw_start_8169(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
 	struct pci_dev *pdev = tp->pci_dev;
-	u16 cmd;
 
 	if (tp->mac_version == RTL_GIGA_MAC_VER_05) {
 		RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) | PCIMulRW);
 		pci_write_config_byte(pdev, PCI_CACHE_LINE_SIZE, 0x08);
 	}
 
-	/* Undocumented stuff. */
-	if (tp->mac_version == RTL_GIGA_MAC_VER_05) {
-		/* Realtek's r1000_n.c driver uses '&& 0x01' here. Well... */
-		if ((RTL_R8(Config2) & 0x07) & 0x01)
-			RTL_W32(0x7c, 0x0007ffff);
-
-		RTL_W32(0x7c, 0x0007ff00);
-
-		pci_read_config_word(pdev, PCI_COMMAND, &cmd);
-		cmd = cmd & 0xef;
-		pci_write_config_word(pdev, PCI_COMMAND, cmd);
-	}
-
 	RTL_W8(Cfg9346, Cfg9346_Unlock);
 	if ((tp->mac_version == RTL_GIGA_MAC_VER_01) ||
 	    (tp->mac_version == RTL_GIGA_MAC_VER_02) ||
@@ -1927,11 +1941,7 @@ static void rtl_hw_start_8169(struct net_device *dev)
 
 	rtl_set_rx_max_size(ioaddr);
 
-	if ((tp->mac_version == RTL_GIGA_MAC_VER_01) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_02) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_03) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_04))
-		rtl_set_rx_tx_config_registers(tp);
+	rtl_set_rx_tx_config_registers(tp);
 
 	tp->cp_cmd |= rtl_rw_cpluscmd(ioaddr) | PCIMulRW;
 
@@ -1944,6 +1954,8 @@ static void rtl_hw_start_8169(struct net_device *dev)
 
 	RTL_W16(CPlusCmd, tp->cp_cmd);
 
+	rtl8169_set_magic_reg(ioaddr, tp->mac_version);
+
 	/*
 	 * Undocumented corner. Supposedly:
 	 * (TxTimer << 12) | (TxPackets << 8) | (RxTimer << 4) | RxPackets
@@ -1952,14 +1964,6 @@ static void rtl_hw_start_8169(struct net_device *dev)
 
 	rtl_set_rx_tx_desc_registers(tp, ioaddr);
 
-	if ((tp->mac_version != RTL_GIGA_MAC_VER_01) &&
-	    (tp->mac_version != RTL_GIGA_MAC_VER_02) &&
-	    (tp->mac_version != RTL_GIGA_MAC_VER_03) &&
-	    (tp->mac_version != RTL_GIGA_MAC_VER_04)) {
-		RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
-		rtl_set_rx_tx_config_registers(tp);
-	}
-
 	RTL_W8(Cfg9346, Cfg9346_Lock);
 
 	/* Initially a 10 us delay. Turned it into a PCI commit. - FR */
@@ -1971,6 +1975,11 @@ static void rtl_hw_start_8169(struct net_device *dev)
 
 	/* no early-rx interrupts */
 	RTL_W16(MultiIntr, RTL_R16(MultiIntr) & 0xF000);
+
+	/* Enable all known interrupts by setting the interrupt mask. */
+	RTL_W16(IntrMask, rtl8169_intr_mask);
+
+	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
 }
 
 static void rtl_hw_start_8168(struct net_device *dev)
@@ -2004,6 +2013,8 @@ static void rtl_hw_start_8168(struct net_device *dev)
 	rtl_set_rx_mode(dev);
 
 	RTL_W16(MultiIntr, RTL_R16(MultiIntr) & 0xF000);
+
+	RTL_W16(IntrMask, rtl8169_intr_mask);
 }
 
 static void rtl_hw_start_8101(struct net_device *dev)
@@ -2043,6 +2054,8 @@ static void rtl_hw_start_8101(struct net_device *dev)
 	rtl_set_rx_mode(dev);
 
 	RTL_W16(MultiIntr, RTL_R16(MultiIntr) & 0xF000);
+
+	RTL_W16(IntrMask, rtl8169_intr_mask);
 }
 
 static int rtl8169_change_mtu(struct net_device *dev, int new_mtu)
@@ -2698,6 +2711,13 @@ rtl8169_rx_interrupt(struct net_device *dev, struct rtl8169_private *tp,
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
 	}
 
 	count = cur_rx - tp->cur_rx;
-- 
1.4.4.2
