From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 02/12] r8169: add per-device hw_start handler (2/2)
Date: Thu, 26 Apr 2007 23:48:03 +0200
Message-ID: <20070426214803.GC7344@electric-eye.fr.zoreil.com>
References: <20070426205714.GA12701@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:58567 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755160AbXDZVv6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2007 17:51:58 -0400
Content-Disposition: inline
In-Reply-To: <20070426205714.GA12701@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Part 2: populate the hw_start handlers for the 8168 and the 8101.

- annotate mac_version
- factor out the initialization of the receive and transmit ring
  descriptor registers (rtl_set_rx_tx_desc_registers)
- access to the CPlusCmd and setting of the maximum receive size are
  idiomatic too (rtl_rw_cpluscmd and rtl_set_rx_max_size)

Each chipset should run through the same code as before in its
dedicated hw_start handler.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com>
---
 drivers/net/r8169.c |  154 +++++++++++++++++++++++++++++++++++++-------------
 1 files changed, 114 insertions(+), 40 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index ba8e04c..05408f3 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -151,16 +151,16 @@ static const int multicast_filter_limit = 32;
 #define RTL_R32(reg)		((unsigned long) readl (ioaddr + (reg)))
 
 enum mac_version {
-	RTL_GIGA_MAC_VER_01 = 0x00,
-	RTL_GIGA_MAC_VER_02 = 0x01,
-	RTL_GIGA_MAC_VER_03 = 0x02,
-	RTL_GIGA_MAC_VER_04 = 0x03,
-	RTL_GIGA_MAC_VER_05 = 0x04,
-	RTL_GIGA_MAC_VER_11 = 0x0b,
-	RTL_GIGA_MAC_VER_12 = 0x0c,
-	RTL_GIGA_MAC_VER_13 = 0x0d,
-	RTL_GIGA_MAC_VER_14 = 0x0e,
-	RTL_GIGA_MAC_VER_15 = 0x0f
+	RTL_GIGA_MAC_VER_01 = 0x01, // 8169
+	RTL_GIGA_MAC_VER_02 = 0x02, // 8169S
+	RTL_GIGA_MAC_VER_03 = 0x03, // 8110S
+	RTL_GIGA_MAC_VER_04 = 0x04, // 8169SB
+	RTL_GIGA_MAC_VER_05 = 0x05, // 8110SCd
+	RTL_GIGA_MAC_VER_11 = 0x0b, // 8168Bb
+	RTL_GIGA_MAC_VER_12 = 0x0c, // 8168Be 8168Bf
+	RTL_GIGA_MAC_VER_13 = 0x0d, // 8101Eb 8101Ec
+	RTL_GIGA_MAC_VER_14 = 0x0e, // 8101
+	RTL_GIGA_MAC_VER_15 = 0x0f  // 8101
 };
 
 enum phy_version {
@@ -180,11 +180,11 @@ static const struct {
 	u8 mac_version;
 	u32 RxConfigMask;	/* Clears the bits supported by this chip */
 } rtl_chip_info[] = {
-	_R("RTL8169",		RTL_GIGA_MAC_VER_01, 0xff7e1880),
-	_R("RTL8169s/8110s",	RTL_GIGA_MAC_VER_02, 0xff7e1880),
-	_R("RTL8169s/8110s",	RTL_GIGA_MAC_VER_03, 0xff7e1880),
-	_R("RTL8169sb/8110sb",	RTL_GIGA_MAC_VER_04, 0xff7e1880),
-	_R("RTL8169sc/8110sc",	RTL_GIGA_MAC_VER_05, 0xff7e1880),
+	_R("RTL8169",		RTL_GIGA_MAC_VER_01, 0xff7e1880), // 8169
+	_R("RTL8169s/8110s",	RTL_GIGA_MAC_VER_02, 0xff7e1880), // 8169S
+	_R("RTL8169s/8110s",	RTL_GIGA_MAC_VER_03, 0xff7e1880), // 8110S
+	_R("RTL8169sb/8110sb",	RTL_GIGA_MAC_VER_04, 0xff7e1880), // 8169SB
+	_R("RTL8169sc/8110sc",	RTL_GIGA_MAC_VER_05, 0xff7e1880), // 8110SCd
 	_R("RTL8168b/8111b",	RTL_GIGA_MAC_VER_11, 0xff7e1880), // PCI-E
 	_R("RTL8168b/8111b",	RTL_GIGA_MAC_VER_12, 0xff7e1880), // PCI-E
 	_R("RTL8101e",		RTL_GIGA_MAC_VER_13, 0xff7e1880), // PCI-E 8139
@@ -1824,7 +1824,7 @@ static void rtl8169_hw_reset(void __iomem *ioaddr)
 	RTL_R8(ChipCmd);
 }
 
-static void rtl8169_set_rx_tx_config_registers(struct rtl8169_private *tp)
+static void rtl_set_rx_tx_config_registers(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
 	u32 cfg = rtl8169_rx_config;
@@ -1862,6 +1862,35 @@ static void rtl_hw_start(struct net_device *dev)
 }
 
 
+static void rtl_set_rx_tx_desc_registers(struct rtl8169_private *tp,
+					 void __iomem *ioaddr)
+{
+	/*
+	 * Magic spell: some iop3xx ARM board needs the TxDescAddrHigh
+	 * register to be written before TxDescAddrLow to work.
+	 * Switching from MMIO to I/O access fixes the issue as well.
+	 */
+	RTL_W32(TxDescStartAddrHigh, ((u64) tp->TxPhyAddr) >> 32);
+	RTL_W32(TxDescStartAddrLow, ((u64) tp->TxPhyAddr) & DMA_32BIT_MASK);
+	RTL_W32(RxDescAddrHigh, ((u64) tp->RxPhyAddr) >> 32);
+	RTL_W32(RxDescAddrLow, ((u64) tp->RxPhyAddr) & DMA_32BIT_MASK);
+}
+
+static u16 rtl_rw_cpluscmd(void __iomem *ioaddr)
+{
+	u16 cmd;
+
+	cmd = RTL_R16(CPlusCmd);
+	RTL_W16(CPlusCmd, cmd);
+	return cmd;
+}
+
+static void rtl_set_rx_max_size(void __iomem *ioaddr)
+{
+	/* Low hurts. Let's disable the filtering. */
+	RTL_W16(RxMaxSize, 16383);
+}
+
 static void rtl_hw_start_8169(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -1874,11 +1903,6 @@ static void rtl_hw_start_8169(struct net_device *dev)
 		pci_write_config_byte(pdev, PCI_CACHE_LINE_SIZE, 0x08);
 	}
 
-	if (tp->mac_version == RTL_GIGA_MAC_VER_13) {
-		pci_write_config_word(pdev, 0x68, 0x00);
-		pci_write_config_word(pdev, 0x69, 0x08);
-	}
-
 	/* Undocumented stuff. */
 	if (tp->mac_version == RTL_GIGA_MAC_VER_05) {
 		/* Realtek's r1000_n.c driver uses '&& 0x01' here. Well... */
@@ -1901,19 +1925,15 @@ static void rtl_hw_start_8169(struct net_device *dev)
 
 	RTL_W8(EarlyTxThres, EarlyTxThld);
 
-	/* Low hurts. Let's disable the filtering. */
-	RTL_W16(RxMaxSize, 16383);
+	rtl_set_rx_max_size(ioaddr);
 
 	if ((tp->mac_version == RTL_GIGA_MAC_VER_01) ||
 	    (tp->mac_version == RTL_GIGA_MAC_VER_02) ||
 	    (tp->mac_version == RTL_GIGA_MAC_VER_03) ||
 	    (tp->mac_version == RTL_GIGA_MAC_VER_04))
-		rtl8169_set_rx_tx_config_registers(tp);
+		rtl_set_rx_tx_config_registers(tp);
 
-	cmd = RTL_R16(CPlusCmd);
-	RTL_W16(CPlusCmd, cmd);
-
-	tp->cp_cmd |= cmd | PCIMulRW;
+	tp->cp_cmd |= rtl_rw_cpluscmd(ioaddr) | PCIMulRW;
 
 	if ((tp->mac_version == RTL_GIGA_MAC_VER_02) ||
 	    (tp->mac_version == RTL_GIGA_MAC_VER_03)) {
@@ -1930,22 +1950,14 @@ static void rtl_hw_start_8169(struct net_device *dev)
 	 */
 	RTL_W16(IntrMitigate, 0x0000);
 
-	/*
-	 * Magic spell: some iop3xx ARM board needs the TxDescAddrHigh
-	 * register to be written before TxDescAddrLow to work.
-	 * Switching from MMIO to I/O access fixes the issue as well.
-	 */
-	RTL_W32(TxDescStartAddrHigh, ((u64) tp->TxPhyAddr >> 32));
-	RTL_W32(TxDescStartAddrLow, ((u64) tp->TxPhyAddr & DMA_32BIT_MASK));
-	RTL_W32(RxDescAddrHigh, ((u64) tp->RxPhyAddr >> 32));
-	RTL_W32(RxDescAddrLow, ((u64) tp->RxPhyAddr & DMA_32BIT_MASK));
+	rtl_set_rx_tx_desc_registers(tp, ioaddr);
 
 	if ((tp->mac_version != RTL_GIGA_MAC_VER_01) &&
 	    (tp->mac_version != RTL_GIGA_MAC_VER_02) &&
 	    (tp->mac_version != RTL_GIGA_MAC_VER_03) &&
 	    (tp->mac_version != RTL_GIGA_MAC_VER_04)) {
 		RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
-		rtl8169_set_rx_tx_config_registers(tp);
+		rtl_set_rx_tx_config_registers(tp);
 	}
 
 	RTL_W8(Cfg9346, Cfg9346_Lock);
@@ -1963,12 +1975,74 @@ static void rtl_hw_start_8169(struct net_device *dev)
 
 static void rtl_hw_start_8168(struct net_device *dev)
 {
-	rtl_hw_start_8169(dev);
+	struct rtl8169_private *tp = netdev_priv(dev);
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	RTL_W8(Cfg9346, Cfg9346_Unlock);
+
+	RTL_W8(EarlyTxThres, EarlyTxThld);
+
+	rtl_set_rx_max_size(ioaddr);
+
+	tp->cp_cmd |= rtl_rw_cpluscmd(ioaddr) | PCIMulRW;
+
+	RTL_W16(CPlusCmd, tp->cp_cmd);
+
+	RTL_W16(IntrMitigate, 0x0000);
+
+	rtl_set_rx_tx_desc_registers(tp, ioaddr);
+
+	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
+	rtl_set_rx_tx_config_registers(tp);
+
+	RTL_W8(Cfg9346, Cfg9346_Lock);
+
+	RTL_R8(IntrMask);
+
+	RTL_W32(RxMissed, 0);
+
+	rtl_set_rx_mode(dev);
+
+	RTL_W16(MultiIntr, RTL_R16(MultiIntr) & 0xF000);
 }
 
 static void rtl_hw_start_8101(struct net_device *dev)
 {
-	rtl_hw_start_8169(dev);
+	struct rtl8169_private *tp = netdev_priv(dev);
+	void __iomem *ioaddr = tp->mmio_addr;
+	struct pci_dev *pdev = tp->pci_dev;
+
+	if (tp->mac_version == RTL_GIGA_MAC_VER_13) {
+		pci_write_config_word(pdev, 0x68, 0x00);
+		pci_write_config_word(pdev, 0x69, 0x08);
+	}
+
+	RTL_W8(Cfg9346, Cfg9346_Unlock);
+
+	RTL_W8(EarlyTxThres, EarlyTxThld);
+
+	rtl_set_rx_max_size(ioaddr);
+
+	tp->cp_cmd |= rtl_rw_cpluscmd(ioaddr) | PCIMulRW;
+
+	RTL_W16(CPlusCmd, tp->cp_cmd);
+
+	RTL_W16(IntrMitigate, 0x0000);
+
+	rtl_set_rx_tx_desc_registers(tp, ioaddr);
+
+	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
+	rtl_set_rx_tx_config_registers(tp);
+
+	RTL_W8(Cfg9346, Cfg9346_Lock);
+
+	RTL_R8(IntrMask);
+
+	RTL_W32(RxMissed, 0);
+
+	rtl_set_rx_mode(dev);
+
+	RTL_W16(MultiIntr, RTL_R16(MultiIntr) & 0xF000);
 }
 
 static int rtl8169_change_mtu(struct net_device *dev, int new_mtu)
-- 
1.4.4.2
