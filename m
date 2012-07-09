From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 6/6] r8169: support RTL8168G
Date: Tue, 10 Jul 2012 00:44:10 +0200
Message-ID: <c558386b836ee97762e12495101c6e373f20e69d.1341872752.git.romieu@fr.zoreil.com>
References: <cover.1341872752.git.romieu@fr.zoreil.com>
Cc: David Miller <davem@davemloft.net>,
	Hayes Wang <hayeswang@realtek.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:59234 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751912Ab2GIW4s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 18:56:48 -0400
In-Reply-To: <cover.1341872752.git.romieu@fr.zoreil.com>
In-Reply-To: <cover.1341872752.git.romieu@fr.zoreil.com>
References: <cover.1341872752.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hayes Wang <hayeswang@realtek.com>

For RTL8111G, the settings of phy and firmware are replaced with
ocp functions. r8168g_mdio_{write / read} redirects the relative
settings to suitable ocp functions. A per-device variable is needed
to evaluate the real address of ocp functions.
rtl_writephy(tp, 0x1f, xxxx) is dedicated to keeping said variable
up-to-date.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
Acked-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/realtek/r8169.c |  291 ++++++++++++++++++++++++++++++++++
 1 file changed, 291 insertions(+)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index eb6fdef..7ff3423 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -47,6 +47,7 @@
 #define FIRMWARE_8402_1		"rtl_nic/rtl8402-1.fw"
 #define FIRMWARE_8411_1		"rtl_nic/rtl8411-1.fw"
 #define FIRMWARE_8106E_1	"rtl_nic/rtl8106e-1.fw"
+#define FIRMWARE_8168G_1	"rtl_nic/rtl8168g-1.fw"
 
 #ifdef RTL8169_DEBUG
 #define assert(expr) \
@@ -143,6 +144,8 @@ enum mac_version {
 	RTL_GIGA_MAC_VER_37,
 	RTL_GIGA_MAC_VER_38,
 	RTL_GIGA_MAC_VER_39,
+	RTL_GIGA_MAC_VER_40,
+	RTL_GIGA_MAC_VER_41,
 	RTL_GIGA_MAC_NONE   = 0xff,
 };
 
@@ -264,6 +267,11 @@ static const struct {
 	[RTL_GIGA_MAC_VER_39] =
 		_R("RTL8106e",		RTL_TD_1, FIRMWARE_8106E_1,
 							JUMBO_1K, true),
+	[RTL_GIGA_MAC_VER_40] =
+		_R("RTL8168g/8111g",	RTL_TD_1, FIRMWARE_8168G_1,
+							JUMBO_9K, false),
+	[RTL_GIGA_MAC_VER_41] =
+		_R("RTL8168g/8111g",	RTL_TD_1, NULL, JUMBO_9K, false),
 };
 #undef _R
 
@@ -394,8 +402,12 @@ enum rtl8168_8101_registers {
 	TWSI			= 0xd2,
 	MCU			= 0xd3,
 #define	NOW_IS_OOB			(1 << 7)
+#define	TX_EMPTY			(1 << 5)
+#define	RX_EMPTY			(1 << 4)
+#define	RXTX_EMPTY			(TX_EMPTY | RX_EMPTY)
 #define	EN_NDP				(1 << 3)
 #define	EN_OOB_RESET			(1 << 2)
+#define	LINK_LIST_RDY			(1 << 1)
 	EFUSEAR			= 0xdc,
 #define	EFUSEAR_FLAG			0x80000000
 #define	EFUSEAR_WRITE_CMD		0x80000000
@@ -421,6 +433,7 @@ enum rtl8168_registers {
 #define ERIAR_MASK_SHIFT		12
 #define ERIAR_MASK_0001			(0x1 << ERIAR_MASK_SHIFT)
 #define ERIAR_MASK_0011			(0x3 << ERIAR_MASK_SHIFT)
+#define ERIAR_MASK_0101			(0x5 << ERIAR_MASK_SHIFT)
 #define ERIAR_MASK_1111			(0xf << ERIAR_MASK_SHIFT)
 	EPHY_RXER_NUM		= 0x7c,
 	OCPDR			= 0xb0,	/* OCP GPHY access */
@@ -433,11 +446,13 @@ enum rtl8168_registers {
 #define OCPAR_FLAG			0x80000000
 #define OCPAR_GPHY_WRITE_CMD		0x8000f060
 #define OCPAR_GPHY_READ_CMD		0x0000f060
+	GPHY_OCP		= 0xb8,
 	RDSAR1			= 0xd0,	/* 8168c only. Undocumented on 8168dp */
 	MISC			= 0xf0,	/* 8168e only. */
 #define TXPLA_RST			(1 << 29)
 #define DISABLE_LAN_EN			(1 << 23) /* Enable GPIO pin */
 #define PWM_EN				(1 << 22)
+#define RXDV_GATED_EN			(1 << 19)
 #define EARLY_TALLY_EN			(1 << 16)
 };
 
@@ -781,6 +796,8 @@ struct rtl8169_private {
 		} phy_action;
 	} *rtl_fw;
 #define RTL_FIRMWARE_UNKNOWN	ERR_PTR(-EAGAIN)
+
+	u32 ocp_base;
 };
 
 MODULE_AUTHOR("Realtek and the Linux r8169 crew <netdev@vger.kernel.org>");
@@ -802,6 +819,7 @@ MODULE_FIRMWARE(FIRMWARE_8168F_2);
 MODULE_FIRMWARE(FIRMWARE_8402_1);
 MODULE_FIRMWARE(FIRMWARE_8411_1);
 MODULE_FIRMWARE(FIRMWARE_8106E_1);
+MODULE_FIRMWARE(FIRMWARE_8168G_1);
 
 static void rtl_lock_work(struct rtl8169_private *tp)
 {
@@ -976,6 +994,110 @@ static int r8168dp_check_dash(struct rtl8169_private *tp)
 	return (ocp_read(tp, 0x0f, reg) & 0x00008000) ? 1 : 0;
 }
 
+static bool rtl_ocp_reg_failure(struct rtl8169_private *tp, u32 reg)
+{
+	if (reg & 0xffff0001) {
+		netif_err(tp, drv, tp->dev, "Invalid ocp reg %x!\n", reg);
+		return true;
+	}
+	return false;
+}
+
+DECLARE_RTL_COND(rtl_ocp_gphy_cond)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	return RTL_R32(GPHY_OCP) & OCPAR_FLAG;
+}
+
+static void r8168_phy_ocp_write(struct rtl8169_private *tp, u32 reg, u32 data)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	if (rtl_ocp_reg_failure(tp, reg))
+		return;
+
+	RTL_W32(GPHY_OCP, OCPAR_FLAG | (reg << 15) | data);
+
+	rtl_udelay_loop_wait_low(tp, &rtl_ocp_gphy_cond, 25, 10);
+}
+
+static u16 r8168_phy_ocp_read(struct rtl8169_private *tp, u32 reg)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	if (rtl_ocp_reg_failure(tp, reg))
+		return 0;
+
+	RTL_W32(GPHY_OCP, reg << 15);
+
+	return rtl_udelay_loop_wait_high(tp, &rtl_ocp_gphy_cond, 25, 10) ?
+		(RTL_R32(GPHY_OCP) & 0xffff) : ~0;
+}
+
+static void rtl_w1w0_phy_ocp(struct rtl8169_private *tp, int reg, int p, int m)
+{
+	int val;
+
+	val = r8168_phy_ocp_read(tp, reg);
+	r8168_phy_ocp_write(tp, reg, (val | p) & ~m);
+}
+
+DECLARE_RTL_COND(rtl_ocpdr_cond)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	return RTL_R32(OCPDR) & OCPAR_FLAG;
+}
+
+static void r8168_mac_ocp_write(struct rtl8169_private *tp, u32 reg, u32 data)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	if (rtl_ocp_reg_failure(tp, reg))
+		return;
+
+	RTL_W32(OCPDR, OCPAR_FLAG | (reg << 15) | data);
+
+	rtl_udelay_loop_wait_low(tp, &rtl_ocpdr_cond, 25, 10);
+}
+
+static u16 r8168_mac_ocp_read(struct rtl8169_private *tp, u32 reg)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	if (rtl_ocp_reg_failure(tp, reg))
+		return 0;
+
+	RTL_W32(OCPDR, reg << 15);
+
+	return rtl_udelay_loop_wait_high(tp, &rtl_ocpdr_cond, 25, 10) ?
+		RTL_R32(OCPDR) : ~0;
+}
+
+#define OCP_STD_PHY_BASE	0xa400
+
+static void r8168g_mdio_write(struct rtl8169_private *tp, int reg, int value)
+{
+	if (reg == 0x1f) {
+		tp->ocp_base = value ? value << 4 : OCP_STD_PHY_BASE;
+		return;
+	}
+
+	if (tp->ocp_base != OCP_STD_PHY_BASE)
+		reg -= 0x10;
+
+	r8168_phy_ocp_write(tp, tp->ocp_base + reg * 2, value);
+}
+
+static int r8168g_mdio_read(struct rtl8169_private *tp, int reg)
+{
+	if (tp->ocp_base != OCP_STD_PHY_BASE)
+		reg -= 0x10;
+
+	return r8168_phy_ocp_read(tp, tp->ocp_base + reg * 2);
+}
+
 DECLARE_RTL_COND(rtl_phyar_cond)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
@@ -1929,6 +2051,10 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp,
 		u32 val;
 		int mac_version;
 	} mac_info[] = {
+		/* 8168G family. */
+		{ 0x7cf00000, 0x4c100000,	RTL_GIGA_MAC_VER_41 },
+		{ 0x7cf00000, 0x4c000000,	RTL_GIGA_MAC_VER_40 },
+
 		/* 8168F family. */
 		{ 0x7c800000, 0x48800000,	RTL_GIGA_MAC_VER_38 },
 		{ 0x7cf00000, 0x48100000,	RTL_GIGA_MAC_VER_36 },
@@ -3244,6 +3370,55 @@ static void rtl8411_hw_phy_config(struct rtl8169_private *tp)
 	rtl_writephy(tp, 0x1f, 0x0000);
 }
 
+static void rtl8168g_1_hw_phy_config(struct rtl8169_private *tp)
+{
+	static const u16 mac_ocp_patch[] = {
+		0xe008, 0xe01b, 0xe01d, 0xe01f,
+		0xe021, 0xe023, 0xe025, 0xe027,
+		0x49d2, 0xf10d, 0x766c, 0x49e2,
+		0xf00a, 0x1ec0, 0x8ee1, 0xc60a,
+
+		0x77c0, 0x4870, 0x9fc0, 0x1ea0,
+		0xc707, 0x8ee1, 0x9d6c, 0xc603,
+		0xbe00, 0xb416, 0x0076, 0xe86c,
+		0xc602, 0xbe00, 0x0000, 0xc602,
+
+		0xbe00, 0x0000, 0xc602, 0xbe00,
+		0x0000, 0xc602, 0xbe00, 0x0000,
+		0xc602, 0xbe00, 0x0000, 0xc602,
+		0xbe00, 0x0000, 0xc602, 0xbe00,
+
+		0x0000, 0x0000, 0x0000, 0x0000
+	};
+	u32 i;
+
+	/* Patch code for GPHY reset */
+	for (i = 0; i < ARRAY_SIZE(mac_ocp_patch); i++)
+		r8168_mac_ocp_write(tp, 0xf800 + 2*i, mac_ocp_patch[i]);
+	r8168_mac_ocp_write(tp, 0xfc26, 0x8000);
+	r8168_mac_ocp_write(tp, 0xfc28, 0x0075);
+
+	rtl_apply_firmware(tp);
+
+	if (r8168_phy_ocp_read(tp, 0xa460) & 0x0100)
+		rtl_w1w0_phy_ocp(tp, 0xbcc4, 0x0000, 0x8000);
+	else
+		rtl_w1w0_phy_ocp(tp, 0xbcc4, 0x8000, 0x0000);
+
+	if (r8168_phy_ocp_read(tp, 0xa466) & 0x0100)
+		rtl_w1w0_phy_ocp(tp, 0xc41a, 0x0002, 0x0000);
+	else
+		rtl_w1w0_phy_ocp(tp, 0xbcc4, 0x0000, 0x0002);
+
+	rtl_w1w0_phy_ocp(tp, 0xa442, 0x000c, 0x0000);
+	rtl_w1w0_phy_ocp(tp, 0xa4b2, 0x0004, 0x0000);
+
+	r8168_phy_ocp_write(tp, 0xa436, 0x8012);
+	rtl_w1w0_phy_ocp(tp, 0xa438, 0x8000, 0x0000);
+
+	rtl_w1w0_phy_ocp(tp, 0xc422, 0x4000, 0x2000);
+}
+
 static void rtl8102e_hw_phy_config(struct rtl8169_private *tp)
 {
 	static const struct phy_reg phy_reg_init[] = {
@@ -3426,6 +3601,11 @@ static void rtl_hw_phy_config(struct net_device *dev)
 		rtl8106e_hw_phy_config(tp);
 		break;
 
+	case RTL_GIGA_MAC_VER_40:
+		rtl8168g_1_hw_phy_config(tp);
+		break;
+
+	case RTL_GIGA_MAC_VER_41:
 	default:
 		break;
 	}
@@ -3644,6 +3824,11 @@ static void __devinit rtl_init_mdio_ops(struct rtl8169_private *tp)
 		ops->write	= r8168dp_2_mdio_write;
 		ops->read	= r8168dp_2_mdio_read;
 		break;
+	case RTL_GIGA_MAC_VER_40:
+	case RTL_GIGA_MAC_VER_41:
+		ops->write	= r8168g_mdio_write;
+		ops->read	= r8168g_mdio_read;
+		break;
 	default:
 		ops->write	= r8169_mdio_write;
 		ops->read	= r8169_mdio_read;
@@ -3664,6 +3849,8 @@ static void rtl_wol_suspend_quirk(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_37:
 	case RTL_GIGA_MAC_VER_38:
 	case RTL_GIGA_MAC_VER_39:
+	case RTL_GIGA_MAC_VER_40:
+	case RTL_GIGA_MAC_VER_41:
 		RTL_W32(RxConfig, RTL_R32(RxConfig) |
 			AcceptBroadcast | AcceptMulticast | AcceptMyPhys);
 		break;
@@ -3912,6 +4099,8 @@ static void __devinit rtl_init_pll_power_ops(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_35:
 	case RTL_GIGA_MAC_VER_36:
 	case RTL_GIGA_MAC_VER_38:
+	case RTL_GIGA_MAC_VER_40:
+	case RTL_GIGA_MAC_VER_41:
 		ops->down	= r8168_pll_power_down;
 		ops->up		= r8168_pll_power_up;
 		break;
@@ -4108,6 +4297,8 @@ static void __devinit rtl_init_jumbo_ops(struct rtl8169_private *tp)
 	 * No action needed for jumbo frames with 8169.
 	 * No jumbo for 810x at all.
 	 */
+	case RTL_GIGA_MAC_VER_40:
+	case RTL_GIGA_MAC_VER_41:
 	default:
 		ops->disable	= NULL;
 		ops->enable	= NULL;
@@ -4213,6 +4404,8 @@ static void rtl8169_hw_reset(struct rtl8169_private *tp)
 	           tp->mac_version == RTL_GIGA_MAC_VER_35 ||
 	           tp->mac_version == RTL_GIGA_MAC_VER_36 ||
 	           tp->mac_version == RTL_GIGA_MAC_VER_37 ||
+	           tp->mac_version == RTL_GIGA_MAC_VER_40 ||
+	           tp->mac_version == RTL_GIGA_MAC_VER_41 ||
 	           tp->mac_version == RTL_GIGA_MAC_VER_38) {
 		RTL_W8(ChipCmd, RTL_R8(ChipCmd) | StopReq);
 		rtl_udelay_loop_wait_high(tp, &rtl_txcfg_empty_cond, 100, 666);
@@ -4925,6 +5118,36 @@ static void rtl_hw_start_8411(struct rtl8169_private *tp)
 	rtl_w1w0_eri(tp, 0x0d4, ERIAR_MASK_0011, 0x0c00, 0x0000, ERIAR_EXGMAC);
 }
 
+static void rtl_hw_start_8168g_1(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+	struct pci_dev *pdev = tp->pci_dev;
+
+	rtl_eri_write(tp, 0xc8, ERIAR_MASK_0101, 0x080002, ERIAR_EXGMAC);
+	rtl_eri_write(tp, 0xcc, ERIAR_MASK_0001, 0x38, ERIAR_EXGMAC);
+	rtl_eri_write(tp, 0xd0, ERIAR_MASK_0001, 0x48, ERIAR_EXGMAC);
+	rtl_eri_write(tp, 0xe8, ERIAR_MASK_1111, 0x00100006, ERIAR_EXGMAC);
+
+	rtl_csi_access_enable_1(tp);
+
+	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
+
+	rtl_w1w0_eri(tp, 0xdc, ERIAR_MASK_0001, 0x00, 0x01, ERIAR_EXGMAC);
+	rtl_w1w0_eri(tp, 0xdc, ERIAR_MASK_0001, 0x01, 0x00, ERIAR_EXGMAC);
+
+	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
+	RTL_W32(MISC, RTL_R32(MISC) & ~RXDV_GATED_EN);
+	RTL_W8(MaxTxPacketSize, EarlySize);
+
+	rtl_eri_write(tp, 0xc0, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
+	rtl_eri_write(tp, 0xb8, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
+
+	/* Adjust EEE LED frequency */
+	RTL_W8(EEE_LED, RTL_R8(EEE_LED) & ~0x07);
+
+	rtl_w1w0_eri(tp, 0x2fc, ERIAR_MASK_0001, 0x01, 0x02, ERIAR_EXGMAC);
+}
+
 static void rtl_hw_start_8168(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -5026,6 +5249,11 @@ static void rtl_hw_start_8168(struct net_device *dev)
 		rtl_hw_start_8411(tp);
 		break;
 
+	case RTL_GIGA_MAC_VER_40:
+	case RTL_GIGA_MAC_VER_41:
+		rtl_hw_start_8168g_1(tp);
+		break;
+
 	default:
 		printk(KERN_ERR PFX "%s: unknown chipset (mac_version = %d).\n",
 			dev->name, tp->mac_version);
@@ -6492,6 +6720,67 @@ static unsigned rtl_try_msi(struct rtl8169_private *tp,
 	return msi;
 }
 
+DECLARE_RTL_COND(rtl_link_list_ready_cond)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	return RTL_R8(MCU) & LINK_LIST_RDY;
+}
+
+DECLARE_RTL_COND(rtl_rxtx_empty_cond)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	return (RTL_R8(MCU) & RXTX_EMPTY) == RXTX_EMPTY;
+}
+
+static void __devinit rtl_hw_init_8168g(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+	u32 data;
+
+	tp->ocp_base = OCP_STD_PHY_BASE;
+
+	RTL_W32(MISC, RTL_R32(MISC) | RXDV_GATED_EN);
+
+	if (!rtl_udelay_loop_wait_high(tp, &rtl_txcfg_empty_cond, 100, 42))
+		return;
+
+	if (!rtl_udelay_loop_wait_high(tp, &rtl_rxtx_empty_cond, 100, 42))
+		return;
+
+	RTL_W8(ChipCmd, RTL_R8(ChipCmd) & ~(CmdTxEnb | CmdRxEnb));
+	msleep(1);
+	RTL_W8(MCU, RTL_R8(MCU) & ~NOW_IS_OOB);
+
+	data = r8168_mac_ocp_read(ioaddr, 0xe8de);
+	data &= ~(1 << 14);
+	r8168_mac_ocp_write(tp, 0xe8de, data);
+
+	if (!rtl_udelay_loop_wait_high(tp, &rtl_link_list_ready_cond, 100, 42))
+		return;
+
+	data = r8168_mac_ocp_read(ioaddr, 0xe8de);
+	data |= (1 << 15);
+	r8168_mac_ocp_write(tp, 0xe8de, data);
+
+	if (!rtl_udelay_loop_wait_high(tp, &rtl_link_list_ready_cond, 100, 42))
+		return;
+}
+
+static void __devinit rtl_hw_initialize(struct rtl8169_private *tp)
+{
+	switch (tp->mac_version) {
+	case RTL_GIGA_MAC_VER_40:
+	case RTL_GIGA_MAC_VER_41:
+		rtl_hw_init_8168g(tp);
+		break;
+
+	default:
+		break;
+	}
+}
+
 static int __devinit
 rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
@@ -6601,6 +6890,8 @@ rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	rtl_irq_disable(tp);
 
+	rtl_hw_initialize(tp);
+
 	rtl_hw_reset(tp);
 
 	rtl_ack_events(tp, 0xffff);
-- 
1.7.10.4
