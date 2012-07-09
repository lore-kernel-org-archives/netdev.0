From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 5/6] r8169: abstract out loop conditions.
Date: Tue, 10 Jul 2012 00:44:09 +0200
Message-ID: <ffc46952b313ff037debca1b4e3da9472ff4b441.1341872752.git.romieu@fr.zoreil.com>
References: <cover.1341872752.git.romieu@fr.zoreil.com>
Cc: David Miller <davem@davemloft.net>,
	Hayes Wang <hayeswang@realtek.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:59235 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752234Ab2GIW4t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 18:56:49 -0400
In-Reply-To: <cover.1341872752.git.romieu@fr.zoreil.com>
In-Reply-To: <cover.1341872752.git.romieu@fr.zoreil.com>
References: <cover.1341872752.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Twelve functions can fail silently. Now they have a chance to complain.

Macro and pasting abuse has been kept at a level where tags and
friends should not be hurt.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/realtek/r8169.c |  367 +++++++++++++++++-----------------
 1 file changed, 186 insertions(+), 181 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 7c6c4b2..eb6fdef 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -826,47 +826,113 @@ static void rtl_tx_performance_tweak(struct pci_dev *pdev, u16 force)
 	}
 }
 
+struct rtl_cond {
+	bool (*check)(struct rtl8169_private *);
+	const char *msg;
+};
+
+static void rtl_udelay(unsigned int d)
+{
+	udelay(d);
+}
+
+static bool rtl_loop_wait(struct rtl8169_private *tp, const struct rtl_cond *c,
+			  void (*delay)(unsigned int), unsigned int d, int n,
+			  bool high)
+{
+	int i;
+
+	for (i = 0; i < n; i++) {
+		delay(d);
+		if (c->check(tp) == high)
+			return true;
+	}
+	netif_err(tp, drv, tp->dev, c->msg);
+	return false;
+}
+
+static bool rtl_udelay_loop_wait_high(struct rtl8169_private *tp,
+				      const struct rtl_cond *c,
+				      unsigned int d, int n)
+{
+	return rtl_loop_wait(tp, c, rtl_udelay, d, n, true);
+}
+
+static bool rtl_udelay_loop_wait_low(struct rtl8169_private *tp,
+				     const struct rtl_cond *c,
+				     unsigned int d, int n)
+{
+	return rtl_loop_wait(tp, c, rtl_udelay, d, n, false);
+}
+
+static bool rtl_msleep_loop_wait_high(struct rtl8169_private *tp,
+				      const struct rtl_cond *c,
+				      unsigned int d, int n)
+{
+	return rtl_loop_wait(tp, c, msleep, d, n, true);
+}
+
+static bool rtl_msleep_loop_wait_low(struct rtl8169_private *tp,
+				     const struct rtl_cond *c,
+				     unsigned int d, int n)
+{
+	return rtl_loop_wait(tp, c, msleep, d, n, false);
+}
+
+#define DECLARE_RTL_COND(name)				\
+static bool name ## _check(struct rtl8169_private *);	\
+							\
+static const struct rtl_cond name = {			\
+	.check	= name ## _check,			\
+	.msg	= #name					\
+};							\
+							\
+static bool name ## _check(struct rtl8169_private *tp)
+
+DECLARE_RTL_COND(rtl_ocpar_cond)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	return RTL_R32(OCPAR) & OCPAR_FLAG;
+}
+
 static u32 ocp_read(struct rtl8169_private *tp, u8 mask, u16 reg)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
-	int i;
 
 	RTL_W32(OCPAR, ((u32)mask & 0x0f) << 12 | (reg & 0x0fff));
-	for (i = 0; i < 20; i++) {
-		udelay(100);
-		if (RTL_R32(OCPAR) & OCPAR_FLAG)
-			break;
-	}
-	return RTL_R32(OCPDR);
+
+	return rtl_udelay_loop_wait_high(tp, &rtl_ocpar_cond, 100, 20) ?
+		RTL_R32(OCPDR) : ~0;
 }
 
 static void ocp_write(struct rtl8169_private *tp, u8 mask, u16 reg, u32 data)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
-	int i;
 
 	RTL_W32(OCPDR, data);
 	RTL_W32(OCPAR, OCPAR_FLAG | ((u32)mask & 0x0f) << 12 | (reg & 0x0fff));
-	for (i = 0; i < 20; i++) {
-		udelay(100);
-		if ((RTL_R32(OCPAR) & OCPAR_FLAG) == 0)
-			break;
-	}
+
+	rtl_udelay_loop_wait_low(tp, &rtl_ocpar_cond, 100, 20);
+}
+
+DECLARE_RTL_COND(rtl_eriar_cond)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	return RTL_R32(ERIAR) & ERIAR_FLAG;
 }
 
 static void rtl8168_oob_notify(struct rtl8169_private *tp, u8 cmd)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
-	int i;
 
 	RTL_W8(ERIDR, cmd);
 	RTL_W32(ERIAR, 0x800010e8);
 	msleep(2);
-	for (i = 0; i < 5; i++) {
-		udelay(100);
-		if (!(RTL_R32(ERIAR) & ERIAR_FLAG))
-			break;
-	}
+
+	if (!rtl_udelay_loop_wait_low(tp, &rtl_eriar_cond, 100, 5))
+		return;
 
 	ocp_write(tp, 0x1, 0x30, 0x00000001);
 }
@@ -880,36 +946,27 @@ static u16 rtl8168_get_ocp_reg(struct rtl8169_private *tp)
 	return (tp->mac_version == RTL_GIGA_MAC_VER_31) ? 0xb8 : 0x10;
 }
 
-static void rtl8168_driver_start(struct rtl8169_private *tp)
+DECLARE_RTL_COND(rtl_ocp_read_cond)
 {
 	u16 reg;
-	int i;
-
-	rtl8168_oob_notify(tp, OOB_CMD_DRIVER_START);
 
 	reg = rtl8168_get_ocp_reg(tp);
 
-	for (i = 0; i < 10; i++) {
-		msleep(10);
-		if (ocp_read(tp, 0x0f, reg) & 0x00000800)
-			break;
-	}
+	return ocp_read(tp, 0x0f, reg) & 0x00000800;
 }
 
-static void rtl8168_driver_stop(struct rtl8169_private *tp)
+static void rtl8168_driver_start(struct rtl8169_private *tp)
 {
-	u16 reg;
-	int i;
+	rtl8168_oob_notify(tp, OOB_CMD_DRIVER_START);
 
-	rtl8168_oob_notify(tp, OOB_CMD_DRIVER_STOP);
+	rtl_msleep_loop_wait_high(tp, &rtl_ocp_read_cond, 10, 10);
+}
 
-	reg = rtl8168_get_ocp_reg(tp);
+static void rtl8168_driver_stop(struct rtl8169_private *tp)
+{
+	rtl8168_oob_notify(tp, OOB_CMD_DRIVER_STOP);
 
-	for (i = 0; i < 10; i++) {
-		msleep(10);
-		if ((ocp_read(tp, 0x0f, reg) & 0x00000800) == 0)
-			break;
-	}
+	rtl_msleep_loop_wait_low(tp, &rtl_ocp_read_cond, 10, 10);
 }
 
 static int r8168dp_check_dash(struct rtl8169_private *tp)
@@ -919,22 +976,20 @@ static int r8168dp_check_dash(struct rtl8169_private *tp)
 	return (ocp_read(tp, 0x0f, reg) & 0x00008000) ? 1 : 0;
 }
 
+DECLARE_RTL_COND(rtl_phyar_cond)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	return RTL_R32(PHYAR) & 0x80000000;
+}
+
 static void r8169_mdio_write(struct rtl8169_private *tp, int reg, int value)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
-	int i;
 
 	RTL_W32(PHYAR, 0x80000000 | (reg & 0x1f) << 16 | (value & 0xffff));
 
-	for (i = 20; i > 0; i--) {
-		/*
-		 * Check if the RTL8169 has completed writing to the specified
-		 * MII register.
-		 */
-		if (!(RTL_R32(PHYAR) & 0x80000000))
-			break;
-		udelay(25);
-	}
+	rtl_udelay_loop_wait_low(tp, &rtl_phyar_cond, 25, 20);
 	/*
 	 * According to hardware specs a 20us delay is required after write
 	 * complete indication, but before sending next command.
@@ -945,21 +1000,13 @@ static void r8169_mdio_write(struct rtl8169_private *tp, int reg, int value)
 static int r8169_mdio_read(struct rtl8169_private *tp, int reg)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
-	int i, value = -1;
+	int value;
 
 	RTL_W32(PHYAR, 0x0 | (reg & 0x1f) << 16);
 
-	for (i = 20; i > 0; i--) {
-		/*
-		 * Check if the RTL8169 has completed retrieving data from
-		 * the specified MII register.
-		 */
-		if (RTL_R32(PHYAR) & 0x80000000) {
-			value = RTL_R32(PHYAR) & 0xffff;
-			break;
-		}
-		udelay(25);
-	}
+	value = rtl_udelay_loop_wait_high(tp, &rtl_phyar_cond, 25, 20) ?
+		RTL_R32(PHYAR) & 0xffff : ~0;
+
 	/*
 	 * According to hardware specs a 20us delay is required after read
 	 * complete indication, but before sending next command.
@@ -972,17 +1019,12 @@ static int r8169_mdio_read(struct rtl8169_private *tp, int reg)
 static void r8168dp_1_mdio_access(struct rtl8169_private *tp, int reg, u32 data)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
-	int i;
 
 	RTL_W32(OCPDR, data | ((reg & OCPDR_REG_MASK) << OCPDR_GPHY_REG_SHIFT));
 	RTL_W32(OCPAR, OCPAR_GPHY_WRITE_CMD);
 	RTL_W32(EPHY_RXER_NUM, 0);
 
-	for (i = 0; i < 100; i++) {
-		mdelay(1);
-		if (!(RTL_R32(OCPAR) & OCPAR_FLAG))
-			break;
-	}
+	rtl_udelay_loop_wait_low(tp, &rtl_ocpar_cond, 1000, 100);
 }
 
 static void r8168dp_1_mdio_write(struct rtl8169_private *tp, int reg, int value)
@@ -994,7 +1036,6 @@ static void r8168dp_1_mdio_write(struct rtl8169_private *tp, int reg, int value)
 static int r8168dp_1_mdio_read(struct rtl8169_private *tp, int reg)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
-	int i;
 
 	r8168dp_1_mdio_access(tp, reg, OCPDR_READ_CMD);
 
@@ -1002,13 +1043,8 @@ static int r8168dp_1_mdio_read(struct rtl8169_private *tp, int reg)
 	RTL_W32(OCPAR, OCPAR_GPHY_READ_CMD);
 	RTL_W32(EPHY_RXER_NUM, 0);
 
-	for (i = 0; i < 100; i++) {
-		mdelay(1);
-		if (RTL_R32(OCPAR) & OCPAR_FLAG)
-			break;
-	}
-
-	return RTL_R32(OCPDR) & OCPDR_DATA_MASK;
+	return rtl_udelay_loop_wait_high(tp, &rtl_ocpar_cond, 1000, 100) ?
+		RTL_R32(OCPDR) & OCPDR_DATA_MASK : ~0;
 }
 
 #define R8168DP_1_MDIO_ACCESS_BIT	0x00020000
@@ -1086,74 +1122,55 @@ static int rtl_mdio_read(struct net_device *dev, int phy_id, int location)
 	return rtl_readphy(tp, location);
 }
 
+DECLARE_RTL_COND(rtl_ephyar_cond)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	return RTL_R32(EPHYAR) & EPHYAR_FLAG;
+}
+
 static void rtl_ephy_write(struct rtl8169_private *tp, int reg_addr, int value)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
-	unsigned int i;
 
 	RTL_W32(EPHYAR, EPHYAR_WRITE_CMD | (value & EPHYAR_DATA_MASK) |
 		(reg_addr & EPHYAR_REG_MASK) << EPHYAR_REG_SHIFT);
 
-	for (i = 0; i < 100; i++) {
-		if (!(RTL_R32(EPHYAR) & EPHYAR_FLAG))
-			break;
-		udelay(10);
-	}
+	rtl_udelay_loop_wait_low(tp, &rtl_ephyar_cond, 10, 100);
+
+	udelay(10);
 }
 
 static u16 rtl_ephy_read(struct rtl8169_private *tp, int reg_addr)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
-	u16 value = 0xffff;
-	unsigned int i;
 
 	RTL_W32(EPHYAR, (reg_addr & EPHYAR_REG_MASK) << EPHYAR_REG_SHIFT);
 
-	for (i = 0; i < 100; i++) {
-		if (RTL_R32(EPHYAR) & EPHYAR_FLAG) {
-			value = RTL_R32(EPHYAR) & EPHYAR_DATA_MASK;
-			break;
-		}
-		udelay(10);
-	}
-
-	return value;
+	return rtl_udelay_loop_wait_high(tp, &rtl_ephyar_cond, 10, 100) ?
+		RTL_R32(EPHYAR) & EPHYAR_DATA_MASK : ~0;
 }
 
 static void rtl_eri_write(struct rtl8169_private *tp, int addr, u32 mask,
 			  u32 val, int type)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
-	unsigned int i;
 
 	BUG_ON((addr & 3) || (mask == 0));
 	RTL_W32(ERIDR, val);
 	RTL_W32(ERIAR, ERIAR_WRITE_CMD | type | mask | addr);
 
-	for (i = 0; i < 100; i++) {
-		if (!(RTL_R32(ERIAR) & ERIAR_FLAG))
-			break;
-		udelay(100);
-	}
+	rtl_udelay_loop_wait_low(tp, &rtl_eriar_cond, 100, 100);
 }
 
 static u32 rtl_eri_read(struct rtl8169_private *tp, int addr, int type)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
-	u32 value = ~0x00;
-	unsigned int i;
 
 	RTL_W32(ERIAR, ERIAR_READ_CMD | type | ERIAR_MASK_1111 | addr);
 
-	for (i = 0; i < 100; i++) {
-		if (RTL_R32(ERIAR) & ERIAR_FLAG) {
-			value = RTL_R32(ERIDR);
-			break;
-		}
-		udelay(100);
-	}
-
-	return value;
+	return rtl_udelay_loop_wait_high(tp, &rtl_eriar_cond, 100, 100) ?
+		RTL_R32(ERIDR) : ~0;
 }
 
 static void rtl_w1w0_eri(struct rtl8169_private *tp, int addr, u32 mask, u32 p,
@@ -1180,23 +1197,21 @@ static void rtl_write_exgmac_batch(struct rtl8169_private *tp,
 	}
 }
 
+DECLARE_RTL_COND(rtl_efusear_cond)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	return RTL_R32(EFUSEAR) & EFUSEAR_FLAG;
+}
+
 static u8 rtl8168d_efuse_read(struct rtl8169_private *tp, int reg_addr)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
-	u8 value = 0xff;
-	unsigned int i;
 
 	RTL_W32(EFUSEAR, (reg_addr & EFUSEAR_REG_MASK) << EFUSEAR_REG_SHIFT);
 
-	for (i = 0; i < 300; i++) {
-		if (RTL_R32(EFUSEAR) & EFUSEAR_FLAG) {
-			value = RTL_R32(EFUSEAR) & EFUSEAR_DATA_MASK;
-			break;
-		}
-		udelay(100);
-	}
-
-	return value;
+	return rtl_udelay_loop_wait_high(tp, &rtl_efusear_cond, 100, 300) ?
+		RTL_R32(EFUSEAR) & EFUSEAR_DATA_MASK : ~0;
 }
 
 static u16 rtl_get_events(struct rtl8169_private *tp)
@@ -1803,6 +1818,13 @@ static int rtl8169_get_sset_count(struct net_device *dev, int sset)
 	}
 }
 
+DECLARE_RTL_COND(rtl_counters_cond)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	return RTL_R32(CounterAddrLow) & CounterDump;
+}
+
 static void rtl8169_update_counters(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -1811,7 +1833,6 @@ static void rtl8169_update_counters(struct net_device *dev)
 	struct rtl8169_counters *counters;
 	dma_addr_t paddr;
 	u32 cmd;
-	int wait = 1000;
 
 	/*
 	 * Some chips are unable to dump tally counters when the receiver
@@ -1829,13 +1850,8 @@ static void rtl8169_update_counters(struct net_device *dev)
 	RTL_W32(CounterAddrLow, cmd);
 	RTL_W32(CounterAddrLow, cmd | CounterDump);
 
-	while (wait--) {
-		if ((RTL_R32(CounterAddrLow) & CounterDump) == 0) {
-			memcpy(&tp->counters, counters, sizeof(*counters));
-			break;
-		}
-		udelay(10);
-	}
+	if (rtl_udelay_loop_wait_low(tp, &rtl_counters_cond, 10, 1000))
+		memcpy(&tp->counters, counters, sizeof(*counters));
 
 	RTL_W32(CounterAddrLow, 0);
 	RTL_W32(CounterAddrHigh, 0);
@@ -3467,18 +3483,16 @@ static void rtl8169_release_board(struct pci_dev *pdev, struct net_device *dev,
 	free_netdev(dev);
 }
 
+DECLARE_RTL_COND(rtl_phy_reset_cond)
+{
+	return tp->phy_reset_pending(tp);
+}
+
 static void rtl8169_phy_reset(struct net_device *dev,
 			      struct rtl8169_private *tp)
 {
-	unsigned int i;
-
 	tp->phy_reset_enable(tp);
-	for (i = 0; i < 100; i++) {
-		if (!tp->phy_reset_pending(tp))
-			return;
-		msleep(1);
-	}
-	netif_err(tp, link, dev, "PHY reset failed\n");
+	rtl_msleep_loop_wait_low(tp, &rtl_phy_reset_cond, 1, 100);
 }
 
 static bool rtl_tbi_enabled(struct rtl8169_private *tp)
@@ -4101,20 +4115,20 @@ static void __devinit rtl_init_jumbo_ops(struct rtl8169_private *tp)
 	}
 }
 
+DECLARE_RTL_COND(rtl_chipcmd_cond)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	return RTL_R8(ChipCmd) & CmdReset;
+}
+
 static void rtl_hw_reset(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
-	int i;
 
-	/* Soft reset the chip. */
 	RTL_W8(ChipCmd, CmdReset);
 
-	/* Check that the chip has finished the reset. */
-	for (i = 0; i < 100; i++) {
-		if ((RTL_R8(ChipCmd) & CmdReset) == 0)
-			break;
-		udelay(100);
-	}
+	rtl_udelay_loop_wait_low(tp, &rtl_chipcmd_cond, 100, 100);
 }
 
 static void rtl_request_uncached_firmware(struct rtl8169_private *tp)
@@ -4168,6 +4182,20 @@ static void rtl_rx_close(struct rtl8169_private *tp)
 	RTL_W32(RxConfig, RTL_R32(RxConfig) & ~RX_CONFIG_ACCEPT_MASK);
 }
 
+DECLARE_RTL_COND(rtl_npq_cond)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	return RTL_R8(TxPoll) & NPQ;
+}
+
+DECLARE_RTL_COND(rtl_txcfg_empty_cond)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	return RTL_R32(TxConfig) & TXCFG_EMPTY;
+}
+
 static void rtl8169_hw_reset(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
@@ -4180,16 +4208,14 @@ static void rtl8169_hw_reset(struct rtl8169_private *tp)
 	if (tp->mac_version == RTL_GIGA_MAC_VER_27 ||
 	    tp->mac_version == RTL_GIGA_MAC_VER_28 ||
 	    tp->mac_version == RTL_GIGA_MAC_VER_31) {
-		while (RTL_R8(TxPoll) & NPQ)
-			udelay(20);
+		rtl_udelay_loop_wait_low(tp, &rtl_npq_cond, 20, 42*42);
 	} else if (tp->mac_version == RTL_GIGA_MAC_VER_34 ||
 	           tp->mac_version == RTL_GIGA_MAC_VER_35 ||
 	           tp->mac_version == RTL_GIGA_MAC_VER_36 ||
 	           tp->mac_version == RTL_GIGA_MAC_VER_37 ||
 	           tp->mac_version == RTL_GIGA_MAC_VER_38) {
 		RTL_W8(ChipCmd, RTL_R8(ChipCmd) | StopReq);
-		while (!(RTL_R32(TxConfig) & TXCFG_EMPTY))
-			udelay(100);
+		rtl_udelay_loop_wait_high(tp, &rtl_txcfg_empty_cond, 100, 666);
 	} else {
 		RTL_W8(ChipCmd, RTL_R8(ChipCmd) | StopReq);
 		udelay(100);
@@ -4421,77 +4447,56 @@ static void rtl_csi_access_enable_2(struct rtl8169_private *tp)
 	rtl_csi_access_enable(tp, 0x27000000);
 }
 
+DECLARE_RTL_COND(rtl_csiar_cond)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	return RTL_R32(CSIAR) & CSIAR_FLAG;
+}
+
 static void r8169_csi_write(struct rtl8169_private *tp, int addr, int value)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
-	unsigned int i;
 
 	RTL_W32(CSIDR, value);
 	RTL_W32(CSIAR, CSIAR_WRITE_CMD | (addr & CSIAR_ADDR_MASK) |
 		CSIAR_BYTE_ENABLE << CSIAR_BYTE_ENABLE_SHIFT);
 
-	for (i = 0; i < 100; i++) {
-		if (!(RTL_R32(CSIAR) & CSIAR_FLAG))
-			break;
-		udelay(10);
-	}
+	rtl_udelay_loop_wait_low(tp, &rtl_csiar_cond, 10, 100);
 }
 
 static u32 r8169_csi_read(struct rtl8169_private *tp, int addr)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
-	u32 value = ~0x00;
-	unsigned int i;
 
 	RTL_W32(CSIAR, (addr & CSIAR_ADDR_MASK) |
 		CSIAR_BYTE_ENABLE << CSIAR_BYTE_ENABLE_SHIFT);
 
-	for (i = 0; i < 100; i++) {
-		if (RTL_R32(CSIAR) & CSIAR_FLAG) {
-			value = RTL_R32(CSIDR);
-			break;
-		}
-		udelay(10);
-	}
-
-	return value;
+	return rtl_udelay_loop_wait_high(tp, &rtl_csiar_cond, 10, 100) ?
+		RTL_R32(CSIDR) : ~0;
 }
 
 static void r8402_csi_write(struct rtl8169_private *tp, int addr, int value)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
-	unsigned int i;
 
 	RTL_W32(CSIDR, value);
 	RTL_W32(CSIAR, CSIAR_WRITE_CMD | (addr & CSIAR_ADDR_MASK) |
 		CSIAR_BYTE_ENABLE << CSIAR_BYTE_ENABLE_SHIFT |
 		CSIAR_FUNC_NIC);
 
-	for (i = 0; i < 100; i++) {
-		if (!(RTL_R32(CSIAR) & CSIAR_FLAG))
-			break;
-		udelay(10);
-	}
+	rtl_udelay_loop_wait_low(tp, &rtl_csiar_cond, 10, 100);
 }
 
 static u32 r8402_csi_read(struct rtl8169_private *tp, int addr)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
-	u32 value = ~0x00;
-	unsigned int i;
 
 	RTL_W32(CSIAR, (addr & CSIAR_ADDR_MASK) | CSIAR_FUNC_NIC |
 		CSIAR_BYTE_ENABLE << CSIAR_BYTE_ENABLE_SHIFT);
 
-	for (i = 0; i < 100; i++) {
-		if (RTL_R32(CSIAR) & CSIAR_FLAG) {
-			value = RTL_R32(CSIDR);
-			break;
-		}
-		udelay(10);
-	}
-
-	return value;
+	return rtl_udelay_loop_wait_high(tp, &rtl_csiar_cond, 10, 100) ?
+		RTL_R32(CSIDR) : ~0;
 }
 
 static void __devinit rtl_init_csi_ops(struct rtl8169_private *tp)
-- 
1.7.10.4
