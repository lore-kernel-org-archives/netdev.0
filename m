From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Unknown chipsets from Realtek's 8168 driver
Date: Tue, 26 Jun 2012 12:26:35 +0200
Message-ID: <20120626102635.GB1854@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: hayeswang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:58678 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756001Ab2FZKhU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 06:37:20 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hayes,

  there appears to remain unknown chipsets in Realtek's own driver.
Namely:
- CFG_METHOD_21
- CFG_METHOD_22
- CFG_METHOD_23

Should support for some of those be added to the kernel driver ?

If so it would make sense to plan for those now as there are still a
couple of weeks ahead before the window for -next closes and everything
experiences more than 2 months of delay. You will find some incomplete
stuff below. Feel free to use or ignore it.


Some chipsets from Realtek's 8.031.00 8168 driver:
- CFG_METHOD_21 / RTL_GIGA_MAC_VER_39
- CFG_METHOD_22 / RTL_GIGA_MAC_VER_40
- CFG_METHOD_23 / RTL_GIGA_MAC_VER_41

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/realtek/r8169.c |  284 ++++++++++++++++++++++++++++++++--
 1 file changed, 269 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 7260aa7..8381640 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -46,6 +46,7 @@
 #define FIRMWARE_8105E_1	"rtl_nic/rtl8105e-1.fw"
 #define FIRMWARE_8402_1		"rtl_nic/rtl8402-1.fw"
 #define FIRMWARE_8411_1		"rtl_nic/rtl8411-1.fw"
+#define FIRMWARE_8168G_1	"rtl_nic/rtl8168g-1.fw"
 
 #ifdef RTL8169_DEBUG
 #define assert(expr) \
@@ -141,6 +142,9 @@ enum mac_version {
 	RTL_GIGA_MAC_VER_36,
 	RTL_GIGA_MAC_VER_37,
 	RTL_GIGA_MAC_VER_38,
+	RTL_GIGA_MAC_VER_39,
+	RTL_GIGA_MAC_VER_40,
+	RTL_GIGA_MAC_VER_41,
 	RTL_GIGA_MAC_NONE   = 0xff,
 };
 
@@ -259,6 +263,13 @@ static const struct {
 	[RTL_GIGA_MAC_VER_38] =
 		_R("RTL8411",		RTL_TD_1, FIRMWARE_8411_1,
 							JUMBO_9K, false),
+	[RTL_GIGA_MAC_VER_39] =
+		_R("RTL8168g/8111g",	RTL_TD_1, FIRMWARE_8168G_1,
+							JUMBO_9K, false),
+	[RTL_GIGA_MAC_VER_40] =
+		_R("RTL8168g/8111g",	RTL_TD_1, NULL, JUMBO_9K, false),
+	[RTL_GIGA_MAC_VER_41] =
+		_R("RTL8168ep/8111ep",	RTL_TD_1, NULL, JUMBO_9K, false),
 };
 #undef _R
 
@@ -424,11 +435,22 @@ enum rtl8168_registers {
 #define OCPDR_REG_MASK			0x7f
 #define OCPDR_GPHY_REG_SHIFT		16
 #define OCPDR_DATA_MASK			0xffff
+	MACOCP			= 0xb0,
+	/* Shared with PHYOCP. */
+#define OCPR_FLAG			0x80000000
+#define OCPR_WRITE_CMD			0x80000000
+#define OCPR_READ_CMD			0x00000000
+#define OCPR_ADDR_REG_SHIFT		16
 	OCPAR			= 0xb4,
 #define OCPAR_FLAG			0x80000000
 #define OCPAR_GPHY_WRITE_CMD		0x8000f060
 #define OCPAR_GPHY_READ_CMD		0x0000f060
+	PHYOCP			= 0xb8,
 	RDSAR1			= 0xd0,	/* 8168c only. Undocumented on 8168dp */
+	MCUCMD			= 0xd3,
+#define	MCUCMD_NOW_IS_OOB		(1 << 7)
+#define	MCUCMD_TXFIFO_EMPTY		(1 << 5)
+#define	MCUCMD_RXFIFO_EMPTY		(1 << 4)
 	MISC			= 0xf0,	/* 8168e only. */
 #define TXPLA_RST			(1 << 29)
 #define PWM_EN				(1 << 22)
@@ -721,8 +743,8 @@ struct rtl8169_private {
 	u16 event_slow;
 
 	struct mdio_ops {
-		void (*write)(void __iomem *, int, int);
-		int (*read)(void __iomem *, int);
+		void (*write)(struct rtl8169_private *, int, int);
+		int (*read)(struct rtl8169_private *, int);
 	} mdio_ops;
 
 	struct pll_power_ops {
@@ -774,6 +796,8 @@ struct rtl8169_private {
 		} phy_action;
 	} *rtl_fw;
 #define RTL_FIRMWARE_UNKNOWN	ERR_PTR(-EAGAIN)
+
+	int mii_page;
 };
 
 MODULE_AUTHOR("Realtek and the Linux r8169 crew <netdev@vger.kernel.org>");
@@ -872,6 +896,27 @@ static u16 rtl8168_get_ocp_reg(struct rtl8169_private *tp)
 	return (tp->mac_version == RTL_GIGA_MAC_VER_31) ? 0xb8 : 0x10;
 }
 
+static u32 rtl_ocp_wrap_cmd(u16 addr, u32 cmd)
+{
+	return ((addr >> 1) << OCPR_ADDR_REG_SHIFT) | cmd;
+}
+
+static void rtl_mac_ocp_write(struct rtl8169_private *tp, u16 reg_addr, u16 value)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	RTL_W32(MACOCP, rtl_ocp_wrap_cmd(reg_addr, OCPR_WRITE_CMD | value));
+}
+
+static u16 rtl_mac_ocp_read(struct rtl8169_private *tp, u16 reg_addr)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	RTL_W32(MACOCP, rtl_ocp_wrap_cmd(reg_addr, OCPR_READ_CMD));
+
+	return (u16)RTL_R32(MACOCP);
+}
+
 static void rtl8168_driver_start(struct rtl8169_private *tp)
 {
 	u16 reg;
@@ -911,8 +956,9 @@ static int r8168dp_check_dash(struct rtl8169_private *tp)
 	return (ocp_read(tp, 0x0f, reg) & 0x00008000) ? 1 : 0;
 }
 
-static void r8169_mdio_write(void __iomem *ioaddr, int reg_addr, int value)
+static void r8169_mdio_write(struct rtl8169_private *tp, int reg_addr, int value)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
 	int i;
 
 	RTL_W32(PHYAR, 0x80000000 | (reg_addr & 0x1f) << 16 | (value & 0xffff));
@@ -933,8 +979,9 @@ static void r8169_mdio_write(void __iomem *ioaddr, int reg_addr, int value)
 	udelay(20);
 }
 
-static int r8169_mdio_read(void __iomem *ioaddr, int reg_addr)
+static int r8169_mdio_read(struct rtl8169_private *tp, int reg_addr)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
 	int i, value = -1;
 
 	RTL_W32(PHYAR, 0x0 | (reg_addr & 0x1f) << 16);
@@ -975,14 +1022,15 @@ static void r8168dp_1_mdio_access(void __iomem *ioaddr, int reg_addr, u32 data)
 	}
 }
 
-static void r8168dp_1_mdio_write(void __iomem *ioaddr, int reg_addr, int value)
+static void r8168dp_1_mdio_write(struct rtl8169_private *tp, int reg_addr, int value)
 {
-	r8168dp_1_mdio_access(ioaddr, reg_addr, OCPDR_WRITE_CMD |
-		(value & OCPDR_DATA_MASK));
+	r8168dp_1_mdio_access(tp->mmio_addr, reg_addr,
+			      OCPDR_WRITE_CMD | (value & OCPDR_DATA_MASK));
 }
 
-static int r8168dp_1_mdio_read(void __iomem *ioaddr, int reg_addr)
+static int r8168dp_1_mdio_read(struct rtl8169_private *tp, int reg_addr)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
 	int i;
 
 	r8168dp_1_mdio_access(ioaddr, reg_addr, OCPDR_READ_CMD);
@@ -1012,8 +1060,10 @@ static void r8168dp_2_mdio_stop(void __iomem *ioaddr)
 	RTL_W32(0xd0, RTL_R32(0xd0) | R8168DP_1_MDIO_ACCESS_BIT);
 }
 
-static void r8168dp_2_mdio_write(void __iomem *ioaddr, int reg_addr, int value)
+static void r8168dp_2_mdio_write(struct rtl8169_private *tp, int reg_addr, int value)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
+
 	r8168dp_2_mdio_start(ioaddr);
 
 	r8169_mdio_write(ioaddr, reg_addr, value);
@@ -1021,8 +1071,9 @@ static void r8168dp_2_mdio_write(void __iomem *ioaddr, int reg_addr, int value)
 	r8168dp_2_mdio_stop(ioaddr);
 }
 
-static int r8168dp_2_mdio_read(void __iomem *ioaddr, int reg_addr)
+static int r8168dp_2_mdio_read(struct rtl8169_private *tp, int reg_addr)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
 	int value;
 
 	r8168dp_2_mdio_start(ioaddr);
@@ -1034,14 +1085,81 @@ static int r8168dp_2_mdio_read(void __iomem *ioaddr, int reg_addr)
 	return value;
 }
 
+static u16 rtl_map_phy_ocp_addr(u16 page, u8 reg)
+{
+	if (!page) {
+		// FIXME: use some #define here ?
+		page = 0x0a40 + (reg / 8);
+		reg  = 0x0010 + (reg % 8);
+	}
+
+	page <<= 4;
+
+	reg -= 16;
+	reg <<= 1;
+
+	return page + reg;
+}
+
+static void rtl_phy_ocp_cmd(struct rtl8169_private *tp, u8 reg, u32 cmd)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+	u32 data;
+
+	data = rtl_map_phy_ocp_addr(tp->mii_page, reg);
+
+	RTL_W32(PHYOCP, rtl_ocp_wrap_cmd(data, cmd));
+}
+
+static bool rtl_phy_ocp_wait_bit(struct rtl8169_private *tp, bool low)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+	bool done;
+	int i;
+
+	for (i = 0; i < 10; i++) {
+		bool set;
+
+		udelay(100);
+
+		set = !!(RTL_R32(PHYOCP) & OCPR_FLAG);
+		done = set ^ low;
+		if (done)
+			break;
+	}
+	return done;
+}
+
+static void r8168g_mdio_write(struct rtl8169_private *tp, int reg_addr, int value)
+{
+	if (reg_addr == 0x1f) {
+		tp->mii_page = value;
+		return;
+	}
+
+	rtl_phy_ocp_cmd(tp, reg_addr, OCPR_WRITE_CMD | value);
+
+	rtl_phy_ocp_wait_bit(tp, true);
+}
+
+static int r8168g_mdio_read(struct rtl8169_private *tp, int reg_addr)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	rtl_phy_ocp_cmd(tp, reg_addr, OCPR_READ_CMD);
+
+	return rtl_phy_ocp_wait_bit(tp, false) ?
+		RTL_R32(PHYOCP) & OCPDR_DATA_MASK : -1;
+}
+
 static void rtl_writephy(struct rtl8169_private *tp, int location, u32 val)
 {
-	tp->mdio_ops.write(tp->mmio_addr, location, val);
+	tp->mdio_ops.write(tp, location, val);
 }
 
 static int rtl_readphy(struct rtl8169_private *tp, int location)
 {
-	return tp->mdio_ops.read(tp->mmio_addr, location);
+	return tp->mdio_ops.read(tp, location);
 }
 
 static void rtl_patchphy(struct rtl8169_private *tp, int reg_addr, int value)
@@ -1319,6 +1437,11 @@ static void rtl_link_chg_patch(struct rtl8169_private *tp)
 			rtl_eri_write(ioaddr, 0x1d0, ERIAR_MASK_0011,
 				      0x0000, ERIAR_EXGMAC);
 		}
+	} else if (tp->mac_version == RTL_GIGA_MAC_VER_39 ||
+		   tp->mac_version == RTL_GIGA_MAC_VER_40) {
+		// ...
+	} else if (tp->mac_version == RTL_GIGA_MAC_VER_41) {
+		// ...
 	}
 }
 
@@ -1425,6 +1548,7 @@ static void __rtl8169_set_wol(struct rtl8169_private *tp, u32 wolopts)
 		RTL_W8(Config1, options);
 		break;
 	default:
+		// Is it ok for RTL_GIGA_MAC_VER_39..41 ?
 		options = RTL_R8(Config2) & ~PME_SIGNAL;
 		if (wolopts)
 			options |= PME_SIGNAL;
@@ -1894,6 +2018,11 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp,
 		u32 val;
 		int mac_version;
 	} mac_info[] = {
+		{ 0x7cf00000, 0x50000000,	RTL_GIGA_MAC_VER_41 },
+
+		{ 0x7cf00000, 0x4c100000,	RTL_GIGA_MAC_VER_40 },
+		{ 0x7cf00000, 0x4c000000,	RTL_GIGA_MAC_VER_39 },
+
 		/* 8168F family. */
 		{ 0x7c800000, 0x48800000,	RTL_GIGA_MAC_VER_38 },
 		{ 0x7cf00000, 0x48100000,	RTL_GIGA_MAC_VER_36 },
@@ -3273,6 +3402,32 @@ static void rtl8402_hw_phy_config(struct rtl8169_private *tp)
 	rtl_writephy(tp, 0x1f, 0x0000);
 }
 
+static void rtl8168g_1_hw_phy_config(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	rtl_apply_firmware(tp);
+}
+
+static void rtl8168g_2_hw_phy_config(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+}
+
+static void rtl8168ep_hw_phy_config(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+	static const struct phy_reg phy_reg_init[] = {
+		{ 0x1f, 0x0a40 },
+		{ 0x1b, 0x809c },
+		{ 0x1c, 0xa700 },
+		{ 0x1b, 0x80a5 },
+		{ 0x1c, 0xa700 }
+	};
+
+	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+}
+
 static void rtl_hw_phy_config(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -3369,6 +3524,18 @@ static void rtl_hw_phy_config(struct net_device *dev)
 		rtl8411_hw_phy_config(tp);
 		break;
 
+	case RTL_GIGA_MAC_VER_39:
+		rtl8168g_1_hw_phy_config(tp);
+		break;
+
+	case RTL_GIGA_MAC_VER_40:
+		rtl8168g_2_hw_phy_config(tp);
+		break;
+
+	case RTL_GIGA_MAC_VER_41:
+		rtl8168ep_hw_phy_config(tp);
+		break;
+
 	default:
 		break;
 	}
@@ -3589,6 +3756,12 @@ static void __devinit rtl_init_mdio_ops(struct rtl8169_private *tp)
 		ops->write	= r8168dp_2_mdio_write;
 		ops->read	= r8168dp_2_mdio_read;
 		break;
+	case RTL_GIGA_MAC_VER_39:
+	case RTL_GIGA_MAC_VER_40:
+	case RTL_GIGA_MAC_VER_41:
+		ops->write	= r8168g_mdio_write;
+		ops->read	= r8168g_mdio_read;
+		break;
 	default:
 		ops->write	= r8169_mdio_write;
 		ops->read	= r8169_mdio_read;
@@ -3611,6 +3784,10 @@ static void rtl_wol_suspend_quirk(struct rtl8169_private *tp)
 		RTL_W32(RxConfig, RTL_R32(RxConfig) |
 			AcceptBroadcast | AcceptMulticast | AcceptMyPhys);
 		break;
+	// Is it ok for RTL_GIGA_MAC_VER_39..41 ?
+	case RTL_GIGA_MAC_VER_39:
+	case RTL_GIGA_MAC_VER_40:
+	case RTL_GIGA_MAC_VER_41:
 	default:
 		break;
 	}
@@ -3705,6 +3882,10 @@ static void r8168_phy_power_up(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_31:
 		rtl_writephy(tp, 0x0e, 0x0000);
 		break;
+	// Is it ok for RTL_GIGA_MAC_VER_39..41 ?
+	case RTL_GIGA_MAC_VER_39:
+	case RTL_GIGA_MAC_VER_40:
+	case RTL_GIGA_MAC_VER_41:
 	default:
 		break;
 	}
@@ -3736,6 +3917,9 @@ static void r8168_phy_power_down(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_28:
 	case RTL_GIGA_MAC_VER_31:
 		rtl_writephy(tp, 0x0e, 0x0200);
+	case RTL_GIGA_MAC_VER_39:
+	case RTL_GIGA_MAC_VER_40:
+	case RTL_GIGA_MAC_VER_41:
 	default:
 		rtl_writephy(tp, MII_BMCR, BMCR_PDOWN);
 		break;
@@ -3855,6 +4039,9 @@ static void __devinit rtl_init_pll_power_ops(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_35:
 	case RTL_GIGA_MAC_VER_36:
 	case RTL_GIGA_MAC_VER_38:
+	case RTL_GIGA_MAC_VER_39:
+	case RTL_GIGA_MAC_VER_40:
+	case RTL_GIGA_MAC_VER_41:
 		ops->down	= r8168_pll_power_down;
 		ops->up		= r8168_pll_power_up;
 		break;
@@ -3896,6 +4083,9 @@ static void rtl_init_rxcfg(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_24:
 		RTL_W32(RxConfig, RX128_INT_EN | RX_MULTI_EN | RX_DMA_BURST);
 		break;
+	case RTL_GIGA_MAC_VER_39:
+	case RTL_GIGA_MAC_VER_40:
+	case RTL_GIGA_MAC_VER_41:
 	default:
 		RTL_W32(RxConfig, RX128_INT_EN | RX_DMA_BURST);
 		break;
@@ -4050,6 +4240,9 @@ static void __devinit rtl_init_jumbo_ops(struct rtl8169_private *tp)
 	 * No action needed for jumbo frames with 8169.
 	 * No jumbo for 810x at all.
 	 */
+	case RTL_GIGA_MAC_VER_39:
+	case RTL_GIGA_MAC_VER_40:
+	case RTL_GIGA_MAC_VER_41:
 	default:
 		ops->disable	= NULL;
 		ops->enable	= NULL;
@@ -4142,7 +4335,10 @@ static void rtl8169_hw_reset(struct rtl8169_private *tp)
 	           tp->mac_version == RTL_GIGA_MAC_VER_35 ||
 	           tp->mac_version == RTL_GIGA_MAC_VER_36 ||
 	           tp->mac_version == RTL_GIGA_MAC_VER_37 ||
-	           tp->mac_version == RTL_GIGA_MAC_VER_38) {
+	           tp->mac_version == RTL_GIGA_MAC_VER_38 ||
+	           tp->mac_version == RTL_GIGA_MAC_VER_39 ||
+	           tp->mac_version == RTL_GIGA_MAC_VER_40 ||
+	           tp->mac_version == RTL_GIGA_MAC_VER_41) {
 		RTL_W8(ChipCmd, RTL_R8(ChipCmd) | StopReq);
 		while (!(RTL_R32(TxConfig) & TXCFG_EMPTY))
 			udelay(100);
@@ -4478,6 +4674,9 @@ static void __devinit rtl_init_csi_ops(struct rtl8169_private *tp)
 		ops->read	= r8402_csi_read;
 		break;
 
+	case RTL_GIGA_MAC_VER_39:
+	case RTL_GIGA_MAC_VER_40:
+	case RTL_GIGA_MAC_VER_41:
 	default:
 		ops->write	= r8169_csi_write;
 		ops->read	= r8169_csi_read;
@@ -4810,6 +5009,38 @@ static void rtl_hw_start_8168e_2(struct rtl8169_private *tp)
 	RTL_W8(Config5, RTL_R8(Config5) & ~Spi_en);
 }
 
+static void rtl_hw_start_8168e_3(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+	struct pci_dev *pdev = tp->pci_dev;
+	static const struct ephy_info e_info_8168e_3[] = {
+		{ 0x00, 0x0000, 0x10a3 },
+		{ 0x06, 0x0000, 0xf030 },
+		{ 0x08, 0x0000, 0x2006 },
+		{ 0x0d, 0x0000, 0x1666 }
+	};
+
+	rtl_csi_access_enable_1(tp);
+
+	rtl_ephy_init(ioaddr, e_info_8168e_3, ARRAY_SIZE(e_info_8168e_3));
+
+	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
+
+	rtl_eri_write(ioaddr, 0xc8, ERIAR_MASK_0001, 0x02, ERIAR_EXGMAC);
+	rtl_eri_write(ioaddr, 0xca, ERIAR_MASK_0001, 0x08, ERIAR_EXGMAC);
+	rtl_eri_write(ioaddr, 0xcc, ERIAR_MASK_0001, 0x2f, ERIAR_EXGMAC);
+	rtl_eri_write(ioaddr, 0xd0, ERIAR_MASK_0001, 0x5f, ERIAR_EXGMAC);
+	rtl_eri_write(ioaddr, 0xe8, ERIAR_MASK_1111, 0x00100006, ERIAR_EXGMAC);
+
+	rtl_w1w0_eri(ioaddr, 0xdc, ERIAR_MASK_0001, 0x00, 0x01, ERIAR_EXGMAC);
+	rtl_w1w0_eri(ioaddr, 0xdc, ERIAR_MASK_0001, 0x01, 0x00, ERIAR_EXGMAC);
+
+	RTL_W8(MaxTxPacketSize, EarlySize);
+
+	/* Adjust EEE LED frequency */
+	RTL_W8(EEE_LED, RTL_R8(EEE_LED) & ~0x07);
+}
+
 static void rtl_hw_start_8168f(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
@@ -4880,6 +5111,18 @@ static void rtl_hw_start_8411(struct rtl8169_private *tp)
 		     ERIAR_EXGMAC);
 }
 
+static void rtl_hw_start_8168g(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+	struct pci_dev *pdev = tp->pci_dev;
+	static const struct ephy_info e_info_8168g[] = {
+		{ 0x00, 0xffff,	0x0000 },
+		{ 0x00, 0xffff,	0x0000 }
+	};
+
+	rtl_ephy_init(ioaddr, e_info_8168g, ARRAY_SIZE(e_info_8168g));
+}
+
 static void rtl_hw_start_8168(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -4981,6 +5224,15 @@ static void rtl_hw_start_8168(struct net_device *dev)
 		rtl_hw_start_8411(tp);
 		break;
 
+	case RTL_GIGA_MAC_VER_39:
+	case RTL_GIGA_MAC_VER_40:
+		rtl_hw_start_8168g(tp);
+		break;
+
+	case RTL_GIGA_MAC_VER_41:
+		rtl_hw_start_8168e_3(tp);
+		break;
+
 	default:
 		printk(KERN_ERR PFX "%s: unknown chipset (mac_version = %d).\n",
 			dev->name, tp->mac_version);
@@ -6335,7 +6587,8 @@ static void __devexit rtl_remove_one(struct pci_dev *pdev)
 
 	if (tp->mac_version == RTL_GIGA_MAC_VER_27 ||
 	    tp->mac_version == RTL_GIGA_MAC_VER_28 ||
-	    tp->mac_version == RTL_GIGA_MAC_VER_31) {
+	    tp->mac_version == RTL_GIGA_MAC_VER_31 ||
+	    tp->mac_version == RTL_GIGA_MAC_VER_41) {
 		rtl8168_driver_stop(tp);
 	}
 
@@ -6651,7 +6904,8 @@ rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	if (tp->mac_version == RTL_GIGA_MAC_VER_27 ||
 	    tp->mac_version == RTL_GIGA_MAC_VER_28 ||
-	    tp->mac_version == RTL_GIGA_MAC_VER_31) {
+	    tp->mac_version == RTL_GIGA_MAC_VER_31 ||
+	    tp->mac_version == RTL_GIGA_MAC_VER_41) {
 		rtl8168_driver_start(tp);
 	}
 
-- 
1.7.10.2
