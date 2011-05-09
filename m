From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 1/8] r8169: style cleanups.
Date: Mon, 9 May 2011 21:02:54 +0200
Message-ID: <20110509190254.GA20687@electric-eye.fr.zoreil.com>
References: <20110509190446.GA6053@electric-eye.fr.zoreil.com> <20110509190205.GA20677@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Hayes Wang <hayeswang@realtek.com>,
	Ciprian Docan <docan@eden.rutgers.edu>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:50150 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753900Ab1EITMd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 15:12:33 -0400
Content-Disposition: inline
In-Reply-To: <20110509190205.GA20677@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>
---
 drivers/net/r8169.c |  206 ++++++++++++++++++++++++---------------------------
 1 files changed, 98 insertions(+), 108 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index a8976a7..c51515f 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -345,7 +345,7 @@ enum rtl8168_registers {
 #define OCPAR_GPHY_READ_CMD		0x0000f060
 	RDSAR1			= 0xd0,	/* 8168c only. Undocumented on 8168dp */
 	MISC			= 0xf0,	/* 8168e only. */
-	txpla_rst			= (1 << 29)
+#define TXPLA_RST			(1 << 29)
 };
 
 enum rtl_register_content {
@@ -423,7 +423,7 @@ enum rtl_register_content {
 	BWF		= (1 << 6),	/* Accept Broadcast wakeup frame */
 	MWF		= (1 << 5),	/* Accept Multicast wakeup frame */
 	UWF		= (1 << 4),	/* Accept Unicast wakeup frame */
-	spi_en		= (1 << 3),
+	Spi_en		= (1 << 3),
 	LanWake		= (1 << 1),	/* LanWake enable/disable */
 	PMEStatus	= (1 << 0),	/* PME status can be reset by PCI RST# */
 
@@ -594,10 +594,10 @@ struct rtl8169_counters {
 
 struct rtl8169_private {
 	void __iomem *mmio_addr;	/* memory map physical address */
-	struct pci_dev *pci_dev;	/* Index of PCI device */
+	struct pci_dev *pci_dev;
 	struct net_device *dev;
 	struct napi_struct napi;
-	spinlock_t lock;		/* spin lock flag */
+	spinlock_t lock;
 	u32 msg_enable;
 	u16 txd_version;
 	u16 mac_version;
@@ -730,17 +730,19 @@ static void rtl8168_oob_notify(struct rtl8169_private *tp, u8 cmd)
 #define OOB_CMD_DRIVER_START	0x05
 #define OOB_CMD_DRIVER_STOP	0x06
 
+static u16 rtl8168_get_ocp_reg(struct rtl8169_private *tp)
+{
+	return (tp->mac_version == RTL_GIGA_MAC_VER_31) ? 0xb8 : 0x10;
+}
+
 static void rtl8168_driver_start(struct rtl8169_private *tp)
 {
+	u16 reg;
 	int i;
-	u32 reg;
 
 	rtl8168_oob_notify(tp, OOB_CMD_DRIVER_START);
 
-	if (tp->mac_version == RTL_GIGA_MAC_VER_31)
-		reg = 0xb8;
-	else
-		reg = 0x10;
+	reg = rtl8168_get_ocp_reg(tp);
 
 	for (i = 0; i < 10; i++) {
 		msleep(10);
@@ -751,15 +753,12 @@ static void rtl8168_driver_start(struct rtl8169_private *tp)
 
 static void rtl8168_driver_stop(struct rtl8169_private *tp)
 {
+	u16 reg;
 	int i;
-	u32 reg;
 
 	rtl8168_oob_notify(tp, OOB_CMD_DRIVER_STOP);
 
-	if (tp->mac_version == RTL_GIGA_MAC_VER_31)
-		reg = 0xb8;
-	else
-		reg = 0x10;
+	reg = rtl8168_get_ocp_reg(tp);
 
 	for (i = 0; i < 10; i++) {
 		msleep(10);
@@ -770,17 +769,9 @@ static void rtl8168_driver_stop(struct rtl8169_private *tp)
 
 static int r8168dp_check_dash(struct rtl8169_private *tp)
 {
-	u32 reg;
-
-	if (tp->mac_version == RTL_GIGA_MAC_VER_31)
-		reg = 0xb8;
-	else
-		reg = 0x10;
+	u16 reg = rtl8168_get_ocp_reg(tp);
 
-	if (ocp_read(tp, 0xF, reg) & 0x00008000)
-		return 1;
-	else
-		return 0;
+	return (ocp_read(tp, 0x0f, reg) & 0x00008000) ? 1 : 0;
 }
 
 static void r8169_mdio_write(void __iomem *ioaddr, int reg_addr, int value)
@@ -1080,9 +1071,8 @@ static void rtl8169_xmii_reset_enable(struct rtl8169_private *tp)
 }
 
 static void __rtl8169_check_link_status(struct net_device *dev,
-				      struct rtl8169_private *tp,
-				      void __iomem *ioaddr,
-				      bool pm)
+					struct rtl8169_private *tp,
+					void __iomem *ioaddr, bool pm)
 {
 	unsigned long flags;
 
@@ -1268,16 +1258,16 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 		giga_ctrl &= ~(ADVERTISE_1000FULL | ADVERTISE_1000HALF);
 
 		/* The 8100e/8101e/8102e do Fast Ethernet only. */
-		if ((tp->mac_version != RTL_GIGA_MAC_VER_07) &&
-		    (tp->mac_version != RTL_GIGA_MAC_VER_08) &&
-		    (tp->mac_version != RTL_GIGA_MAC_VER_09) &&
-		    (tp->mac_version != RTL_GIGA_MAC_VER_10) &&
-		    (tp->mac_version != RTL_GIGA_MAC_VER_13) &&
-		    (tp->mac_version != RTL_GIGA_MAC_VER_14) &&
-		    (tp->mac_version != RTL_GIGA_MAC_VER_15) &&
-		    (tp->mac_version != RTL_GIGA_MAC_VER_16) &&
-		    (tp->mac_version != RTL_GIGA_MAC_VER_29) &&
-		    (tp->mac_version != RTL_GIGA_MAC_VER_30)) {
+		if (tp->mac_version != RTL_GIGA_MAC_VER_07 &&
+		    tp->mac_version != RTL_GIGA_MAC_VER_08 &&
+		    tp->mac_version != RTL_GIGA_MAC_VER_09 &&
+		    tp->mac_version != RTL_GIGA_MAC_VER_10 &&
+		    tp->mac_version != RTL_GIGA_MAC_VER_13 &&
+		    tp->mac_version != RTL_GIGA_MAC_VER_14 &&
+		    tp->mac_version != RTL_GIGA_MAC_VER_15 &&
+		    tp->mac_version != RTL_GIGA_MAC_VER_16 &&
+		    tp->mac_version != RTL_GIGA_MAC_VER_29 &&
+		    tp->mac_version != RTL_GIGA_MAC_VER_30) {
 			if (adv & ADVERTISED_1000baseT_Half)
 				giga_ctrl |= ADVERTISE_1000HALF;
 			if (adv & ADVERTISED_1000baseT_Full)
@@ -1311,8 +1301,8 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 
 	rtl_writephy(tp, MII_BMCR, bmcr);
 
-	if ((tp->mac_version == RTL_GIGA_MAC_VER_02) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_03)) {
+	if (tp->mac_version == RTL_GIGA_MAC_VER_02 ||
+	    tp->mac_version == RTL_GIGA_MAC_VER_03) {
 		if ((speed == SPEED_100) && (autoneg != AUTONEG_ENABLE)) {
 			rtl_writephy(tp, 0x17, 0x2138);
 			rtl_writephy(tp, 0x0e, 0x0260);
@@ -1348,8 +1338,7 @@ static int rtl8169_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	int ret;
 
 	spin_lock_irqsave(&tp->lock, flags);
-	ret = rtl8169_set_speed(dev,
-				cmd->autoneg, ethtool_cmd_speed(cmd),
+	ret = rtl8169_set_speed(dev, cmd->autoneg, ethtool_cmd_speed(cmd),
 				cmd->duplex, cmd->advertising);
 	spin_unlock_irqrestore(&tp->lock, flags);
 
@@ -1507,11 +1496,11 @@ static void rtl8169_update_counters(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
+	struct device *d = &tp->pci_dev->dev;
 	struct rtl8169_counters *counters;
 	dma_addr_t paddr;
 	u32 cmd;
 	int wait = 1000;
-	struct device *d = &tp->pci_dev->dev;
 
 	/*
 	 * Some chips are unable to dump tally counters when the receiver
@@ -1531,7 +1520,6 @@ static void rtl8169_update_counters(struct net_device *dev)
 
 	while (wait--) {
 		if ((RTL_R32(CounterAddrLow) & CounterDump) == 0) {
-			/* copy updated counters */
 			memcpy(&tp->counters, counters, sizeof(*counters));
 			break;
 		}
@@ -1751,14 +1739,14 @@ rtl_phy_write_fw(struct rtl8169_private *tp, const struct firmware *fw)
 		case PHY_BJMPN:
 			if (regno > index) {
 				netif_err(tp, probe, tp->dev,
-					"Out of range of firmware\n");
+					  "Out of range of firmware\n");
 				return;
 			}
 			break;
 		case PHY_READCOUNT_EQ_SKIP:
 			if (index + 2 >= fw_size) {
 				netif_err(tp, probe, tp->dev,
-					"Out of range of firmware\n");
+					  "Out of range of firmware\n");
 				return;
 			}
 			break;
@@ -1767,7 +1755,7 @@ rtl_phy_write_fw(struct rtl8169_private *tp, const struct firmware *fw)
 		case PHY_SKIPN:
 			if (index + 1 + regno >= fw_size) {
 				netif_err(tp, probe, tp->dev,
-					"Out of range of firmware\n");
+					  "Out of range of firmware\n");
 				return;
 			}
 			break;
@@ -1823,10 +1811,7 @@ rtl_phy_write_fw(struct rtl8169_private *tp, const struct firmware *fw)
 			index++;
 			break;
 		case PHY_READCOUNT_EQ_SKIP:
-			if (count == data)
-				index += 2;
-			else
-				index += 1;
+			index += (count == data) ? 2 : 1;
 			break;
 		case PHY_COMP_EQ_SKIPN:
 			if (predata == data)
@@ -2237,7 +2222,7 @@ static void rtl8168d_1_hw_phy_config(struct rtl8169_private *tp)
 
 		/*
 		 * Tx Error Issue
-		 * enhance line driver power
+		 * Enhance line driver power
 		 */
 		{ 0x1f, 0x0002 },
 		{ 0x06, 0x5561 },
@@ -2349,7 +2334,7 @@ static void rtl8168d_2_hw_phy_config(struct rtl8169_private *tp)
 
 		/*
 		 * Tx Error Issue
-		 * enhance line driver power
+		 * Enhance line driver power
 		 */
 		{ 0x1f, 0x0002 },
 		{ 0x06, 0x5561 },
@@ -2548,7 +2533,7 @@ static void rtl8168e_hw_phy_config(struct rtl8169_private *tp)
 	/* For impedance matching */
 	rtl_writephy(tp, 0x1f, 0x0002);
 	rtl_w1w0_phy(tp, 0x08, 0x8000, 0x7f00);
-	rtl_writephy(tp, 0x1F, 0x0000);
+	rtl_writephy(tp, 0x1f, 0x0000);
 
 	/* PHY auto speed down */
 	rtl_writephy(tp, 0x1f, 0x0007);
@@ -2692,6 +2677,9 @@ static void rtl_hw_phy_config(struct net_device *dev)
 	case RTL_GIGA_MAC_VER_30:
 		rtl8105e_hw_phy_config(tp);
 		break;
+	case RTL_GIGA_MAC_VER_31:
+		/* None. */
+		break;
 	case RTL_GIGA_MAC_VER_32:
 	case RTL_GIGA_MAC_VER_33:
 		rtl8168e_hw_phy_config(tp);
@@ -2828,11 +2816,11 @@ static void rtl8169_init_phy(struct net_device *dev, struct rtl8169_private *tp)
 	rtl8169_phy_reset(dev, tp);
 
 	rtl8169_set_speed(dev, AUTONEG_ENABLE, SPEED_1000, DUPLEX_FULL,
-		ADVERTISED_10baseT_Half | ADVERTISED_10baseT_Full |
-		ADVERTISED_100baseT_Half | ADVERTISED_100baseT_Full |
-		(tp->mii.supports_gmii ?
-			ADVERTISED_1000baseT_Half |
-			ADVERTISED_1000baseT_Full : 0));
+			  ADVERTISED_10baseT_Half | ADVERTISED_10baseT_Full |
+			  ADVERTISED_100baseT_Half | ADVERTISED_100baseT_Full |
+			  (tp->mii.supports_gmii ?
+			   ADVERTISED_1000baseT_Half |
+			   ADVERTISED_1000baseT_Full : 0));
 
 	if (RTL_R8(PHYstatus) & TBI_Enable)
 		netif_info(tp, link, dev, "TBI auto-negotiating\n");
@@ -2885,7 +2873,8 @@ static int rtl8169_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	return netif_running(dev) ? tp->do_ioctl(tp, data, cmd) : -ENODEV;
 }
 
-static int rtl_xmii_ioctl(struct rtl8169_private *tp, struct mii_ioctl_data *data, int cmd)
+static int rtl_xmii_ioctl(struct rtl8169_private *tp,
+			  struct mii_ioctl_data *data, int cmd)
 {
 	switch (cmd) {
 	case SIOCGMIIPHY:
@@ -3107,15 +3096,15 @@ static void r8168_pll_power_down(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
 
-	if (((tp->mac_version == RTL_GIGA_MAC_VER_27) ||
-	     (tp->mac_version == RTL_GIGA_MAC_VER_28) ||
-	     (tp->mac_version == RTL_GIGA_MAC_VER_31)) &&
+	if ((tp->mac_version == RTL_GIGA_MAC_VER_27 ||
+	     tp->mac_version == RTL_GIGA_MAC_VER_28 ||
+	     tp->mac_version == RTL_GIGA_MAC_VER_31) &&
 	    r8168dp_check_dash(tp)) {
 		return;
 	}
 
-	if (((tp->mac_version == RTL_GIGA_MAC_VER_23) ||
-	     (tp->mac_version == RTL_GIGA_MAC_VER_24)) &&
+	if ((tp->mac_version == RTL_GIGA_MAC_VER_23 ||
+	     tp->mac_version == RTL_GIGA_MAC_VER_24) &&
 	    (RTL_R16(CPlusCmd) & ASF)) {
 		return;
 	}
@@ -3152,9 +3141,9 @@ static void r8168_pll_power_up(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
 
-	if (((tp->mac_version == RTL_GIGA_MAC_VER_27) ||
-	     (tp->mac_version == RTL_GIGA_MAC_VER_28) ||
-	     (tp->mac_version == RTL_GIGA_MAC_VER_31)) &&
+	if ((tp->mac_version == RTL_GIGA_MAC_VER_27 ||
+	     tp->mac_version == RTL_GIGA_MAC_VER_28 ||
+	     tp->mac_version == RTL_GIGA_MAC_VER_31) &&
 	    r8168dp_check_dash(tp)) {
 		return;
 	}
@@ -3469,9 +3458,9 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		   rtl_chip_info[chipset].name, dev->base_addr, dev->dev_addr,
 		   (u32)(RTL_R32(TxConfig) & 0x9cf0f8ff), dev->irq);
 
-	if ((tp->mac_version == RTL_GIGA_MAC_VER_27) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_28) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_31)) {
+	if (tp->mac_version == RTL_GIGA_MAC_VER_27 ||
+	    tp->mac_version == RTL_GIGA_MAC_VER_28 ||
+	    tp->mac_version == RTL_GIGA_MAC_VER_31) {
 		rtl8168_driver_start(tp);
 	}
 
@@ -3503,9 +3492,9 @@ static void __devexit rtl8169_remove_one(struct pci_dev *pdev)
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct rtl8169_private *tp = netdev_priv(dev);
 
-	if ((tp->mac_version == RTL_GIGA_MAC_VER_27) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_28) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_31)) {
+	if (tp->mac_version == RTL_GIGA_MAC_VER_27 ||
+	    tp->mac_version == RTL_GIGA_MAC_VER_28 ||
+	    tp->mac_version == RTL_GIGA_MAC_VER_31) {
 		rtl8168_driver_stop(tp);
 	}
 
@@ -3753,26 +3742,26 @@ static void rtl_hw_start_8169(struct net_device *dev)
 	}
 
 	RTL_W8(Cfg9346, Cfg9346_Unlock);
-	if ((tp->mac_version == RTL_GIGA_MAC_VER_01) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_02) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_03) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_04))
+	if (tp->mac_version == RTL_GIGA_MAC_VER_01 ||
+	    tp->mac_version == RTL_GIGA_MAC_VER_02 ||
+	    tp->mac_version == RTL_GIGA_MAC_VER_03 ||
+	    tp->mac_version == RTL_GIGA_MAC_VER_04)
 		RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
 
 	RTL_W8(EarlyTxThres, NoEarlyTx);
 
 	rtl_set_rx_max_size(ioaddr, rx_buf_sz);
 
-	if ((tp->mac_version == RTL_GIGA_MAC_VER_01) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_02) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_03) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_04))
+	if (tp->mac_version == RTL_GIGA_MAC_VER_01 ||
+	    tp->mac_version == RTL_GIGA_MAC_VER_02 ||
+	    tp->mac_version == RTL_GIGA_MAC_VER_03 ||
+	    tp->mac_version == RTL_GIGA_MAC_VER_04)
 		rtl_set_rx_tx_config_registers(tp);
 
 	tp->cp_cmd |= rtl_rw_cpluscmd(ioaddr) | PCIMulRW;
 
-	if ((tp->mac_version == RTL_GIGA_MAC_VER_02) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_03)) {
+	if (tp->mac_version == RTL_GIGA_MAC_VER_02 ||
+	    tp->mac_version == RTL_GIGA_MAC_VER_03) {
 		dprintk("Set MAC Reg C+CR Offset 0xE0. "
 			"Bit-3 and bit-14 MUST be 1\n");
 		tp->cp_cmd |= (1 << 14);
@@ -3790,10 +3779,10 @@ static void rtl_hw_start_8169(struct net_device *dev)
 
 	rtl_set_rx_tx_desc_registers(tp, ioaddr);
 
-	if ((tp->mac_version != RTL_GIGA_MAC_VER_01) &&
-	    (tp->mac_version != RTL_GIGA_MAC_VER_02) &&
-	    (tp->mac_version != RTL_GIGA_MAC_VER_03) &&
-	    (tp->mac_version != RTL_GIGA_MAC_VER_04)) {
+	if (tp->mac_version != RTL_GIGA_MAC_VER_01 &&
+	    tp->mac_version != RTL_GIGA_MAC_VER_02 &&
+	    tp->mac_version != RTL_GIGA_MAC_VER_03 &&
+	    tp->mac_version != RTL_GIGA_MAC_VER_04) {
 		RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
 		rtl_set_rx_tx_config_registers(tp);
 	}
@@ -4103,10 +4092,10 @@ static void rtl_hw_start_8168e(void __iomem *ioaddr, struct pci_dev *pdev)
 	rtl_disable_clock_request(pdev);
 
 	/* Reset tx FIFO pointer */
-	RTL_W32(MISC, RTL_R32(MISC) | txpla_rst);
-	RTL_W32(MISC, RTL_R32(MISC) & ~txpla_rst);
+	RTL_W32(MISC, RTL_R32(MISC) | TXPLA_RST);
+	RTL_W32(MISC, RTL_R32(MISC) & ~TXPLA_RST);
 
-	RTL_W8(Config5, RTL_R8(Config5) & ~spi_en);
+	RTL_W8(Config5, RTL_R8(Config5) & ~Spi_en);
 }
 
 static void rtl_hw_start_8168(struct net_device *dev)
@@ -4190,6 +4179,7 @@ static void rtl_hw_start_8168(struct net_device *dev)
 	case RTL_GIGA_MAC_VER_28:
 		rtl_hw_start_8168d_4(ioaddr, pdev);
 		break;
+
 	case RTL_GIGA_MAC_VER_31:
 		rtl_hw_start_8168dp(ioaddr, pdev);
 		break;
@@ -4286,10 +4276,10 @@ static void rtl_hw_start_8105e_1(void __iomem *ioaddr, struct pci_dev *pdev)
 		{ 0x0a,	0, 0x0020 }
 	};
 
-	/* Force LAN exit from ASPM if Rx/Tx are not idel */
+	/* Force LAN exit from ASPM if Rx/Tx are not idle */
 	RTL_W32(FuncEvent, RTL_R32(FuncEvent) | 0x002800);
 
-	/* disable Early Tally Counter */
+	/* Disable Early Tally Counter */
 	RTL_W32(FuncEvent, RTL_R32(FuncEvent) & ~0x010000);
 
 	RTL_W8(MCU, RTL_R8(MCU) | EN_NDP | EN_OOB_RESET);
@@ -4310,8 +4300,8 @@ static void rtl_hw_start_8101(struct net_device *dev)
 	void __iomem *ioaddr = tp->mmio_addr;
 	struct pci_dev *pdev = tp->pci_dev;
 
-	if ((tp->mac_version == RTL_GIGA_MAC_VER_13) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_16)) {
+	if (tp->mac_version == RTL_GIGA_MAC_VER_13 ||
+	    tp->mac_version == RTL_GIGA_MAC_VER_16) {
 		int cap = tp->pcie_cap;
 
 		if (cap) {
@@ -4677,7 +4667,7 @@ static int rtl8169_xmit_frags(struct rtl8169_private *tp, struct sk_buff *skb,
 			goto err_out;
 		}
 
-		/* anti gcc 2.95.3 bugware (sic) */
+		/* Anti gcc 2.95.3 bugware (sic) */
 		status = opts[0] | len |
 			(RingEnd * !((entry + 1) % NUM_TX_DESC));
 
@@ -4773,7 +4763,7 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 
 	wmb();
 
-	/* anti gcc 2.95.3 bugware (sic) */
+	/* Anti gcc 2.95.3 bugware (sic) */
 	status = opts[0] | len | (RingEnd * !((entry + 1) % NUM_TX_DESC));
 	txd->opts1 = cpu_to_le32(status);
 
@@ -4781,7 +4771,7 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 
 	wmb();
 
-	RTL_W8(TxPoll, NPQ);	/* set polling bit */
+	RTL_W8(TxPoll, NPQ);
 
 	if (TX_BUFFS_AVAIL(tp) < MAX_SKB_FRAGS) {
 		netif_stop_queue(dev);
@@ -5207,7 +5197,7 @@ static int rtl8169_close(struct net_device *dev)
 
 	pm_runtime_get_sync(&pdev->dev);
 
-	/* update counters before going down */
+	/* Update counters before going down */
 	rtl8169_update_counters(dev);
 
 	rtl8169_down(dev);
@@ -5400,15 +5390,15 @@ static int rtl8169_runtime_idle(struct device *device)
 }
 
 static const struct dev_pm_ops rtl8169_pm_ops = {
-	.suspend = rtl8169_suspend,
-	.resume = rtl8169_resume,
-	.freeze = rtl8169_suspend,
-	.thaw = rtl8169_resume,
-	.poweroff = rtl8169_suspend,
-	.restore = rtl8169_resume,
-	.runtime_suspend = rtl8169_runtime_suspend,
-	.runtime_resume = rtl8169_runtime_resume,
-	.runtime_idle = rtl8169_runtime_idle,
+	.suspend		= rtl8169_suspend,
+	.resume			= rtl8169_resume,
+	.freeze			= rtl8169_suspend,
+	.thaw			= rtl8169_resume,
+	.poweroff		= rtl8169_suspend,
+	.restore		= rtl8169_resume,
+	.runtime_suspend	= rtl8169_runtime_suspend,
+	.runtime_resume		= rtl8169_runtime_resume,
+	.runtime_idle		= rtl8169_runtime_idle,
 };
 
 #define RTL8169_PM_OPS	(&rtl8169_pm_ops)
@@ -5427,7 +5417,7 @@ static void rtl_shutdown(struct pci_dev *pdev)
 
 	rtl8169_net_suspend(dev);
 
-	/* restore original MAC address */
+	/* Restore original MAC address */
 	rtl_rar_set(tp, dev->perm_addr);
 
 	spin_lock_irq(&tp->lock);
-- 
1.7.4.4

