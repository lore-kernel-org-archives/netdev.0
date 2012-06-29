From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 2/2] r8169: support RTL8168G
Date: Fri, 29 Jun 2012 18:34:20 +0800
Message-ID: <1340966060-2749-2-git-send-email-hayeswang@realtek.com>
References: <1340966060-2749-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	hayes <hayes@fc17.localdomain>,
	Hayes Wang <hayeswang@realtek.com>
To: <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1340966060-2749-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: hayes <hayes@fc17.localdomain>

Support the new chip RTL8168G.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c |  344 +++++++++++++++++++++++++++++++++-
 1 file changed, 343 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 7afc593..fda4432 100644
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
 
@@ -394,8 +402,11 @@ enum rtl8168_8101_registers {
 	TWSI			= 0xd2,
 	MCU			= 0xd3,
 #define	NOW_IS_OOB			(1 << 7)
+#define TX_EMPTY			(1 << 5)
+#define RX_EMPTY			(1 << 4)
 #define	EN_NDP				(1 << 3)
 #define	EN_OOB_RESET			(1 << 2)
+#define LINK_LIST_RDY			(1 << 1)
 	EFUSEAR			= 0xdc,
 #define	EFUSEAR_FLAG			0x80000000
 #define	EFUSEAR_WRITE_CMD		0x80000000
@@ -421,6 +432,7 @@ enum rtl8168_registers {
 #define ERIAR_MASK_SHIFT		12
 #define ERIAR_MASK_0001			(0x1 << ERIAR_MASK_SHIFT)
 #define ERIAR_MASK_0011			(0x3 << ERIAR_MASK_SHIFT)
+#define ERIAR_MASK_0101			(0x5 << ERIAR_MASK_SHIFT)
 #define ERIAR_MASK_1111			(0xf << ERIAR_MASK_SHIFT)
 	EPHY_RXER_NUM		= 0x7c,
 	OCPDR			= 0xb0,	/* OCP GPHY access */
@@ -433,11 +445,13 @@ enum rtl8168_registers {
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
 
@@ -781,6 +795,8 @@ struct rtl8169_private {
 		} phy_action;
 	} *rtl_fw;
 #define RTL_FIRMWARE_UNKNOWN	ERR_PTR(-EAGAIN)
+
+	void (*write_fw)(struct rtl8169_private *, struct rtl_fw *);
 };
 
 MODULE_AUTHOR("Realtek and the Linux r8169 crew <netdev@vger.kernel.org>");
@@ -802,6 +818,7 @@ MODULE_FIRMWARE(FIRMWARE_8168F_2);
 MODULE_FIRMWARE(FIRMWARE_8402_1);
 MODULE_FIRMWARE(FIRMWARE_8411_1);
 MODULE_FIRMWARE(FIRMWARE_8106E_1);
+MODULE_FIRMWARE(FIRMWARE_8168G_1);
 
 static void rtl_lock_work(struct rtl8169_private *tp)
 {
@@ -919,6 +936,99 @@ static int r8168dp_check_dash(struct rtl8169_private *tp)
 	return (ocp_read(tp, 0x0f, reg) & 0x00008000) ? 1 : 0;
 }
 
+static void r8168_phy_ocp_write(void __iomem *ioaddr, u32 reg, u32 data)
+{
+	int i;
+
+	if (reg & 0xffff0001)
+		BUG();
+
+	RTL_W32(GPHY_OCP, OCPAR_FLAG | (reg << 15) | data);
+
+	for (i = 0; i < 10; i++) {
+		udelay(25);
+		if (!(RTL_R32(GPHY_OCP) & OCPAR_FLAG))
+			break;
+	}
+}
+
+static u16 r8168_phy_ocp_read(void __iomem *ioaddr, u32 reg)
+{
+	int i;
+	u32 data;
+
+	if (reg & 0xffff0001)
+		BUG();
+
+	RTL_W32(GPHY_OCP, (reg << 15));
+
+	for (i = 0; i < 10; i++) {
+		udelay(25);
+		data = RTL_R32(GPHY_OCP);
+		if (data & OCPAR_FLAG)
+			break;
+	}
+
+	return (u16)(data & 0xffff);
+}
+
+static void rtl_w1w0_phy_ocp(void __iomem *ioaddr, int reg_addr, int p, int m)
+{
+	int val;
+
+	val = r8168_phy_ocp_read(ioaddr, reg_addr);
+	r8168_phy_ocp_write(ioaddr, reg_addr, (val | p) & ~m);
+}
+
+static void r8168_mac_ocp_write(void __iomem *ioaddr, u32 reg, u32 data)
+{
+	int i;
+
+	if (reg & 0xffff0001)
+		BUG();
+
+	RTL_W32(OCPDR, OCPAR_FLAG | (reg << 15) | data);
+
+	for (i = 0; i < 10; i++) {
+		udelay(25);
+		if (!(RTL_R32(OCPDR) & OCPAR_FLAG))
+			break;
+	}
+}
+
+static u16 r8168_mac_ocp_read(void __iomem *ioaddr, u32 reg)
+{
+	int i;
+	u32 data;
+
+	if (reg & 0xffff0001)
+		BUG();
+
+	RTL_W32(OCPDR, (reg << 15));
+
+	for (i = 0; i < 10; i++) {
+		udelay(25);
+		data = RTL_R32(OCPDR);
+		if (data & OCPAR_FLAG)
+			break;
+	}
+
+	return (u16)(data & 0xffff);
+}
+
+static void r8168g_mdio_write(void __iomem *ioaddr, int reg_addr, int value)
+{
+	if (reg_addr == 0x1f)
+		return;
+
+	r8168_phy_ocp_write(ioaddr, 0xa400 + reg_addr * 2, value);
+}
+
+static int r8168g_mdio_read(void __iomem *ioaddr, int reg_addr)
+{
+	return r8168_phy_ocp_read(ioaddr, 0xa400 + reg_addr * 2);
+}
+
 static void r8169_mdio_write(void __iomem *ioaddr, int reg_addr, int value)
 {
 	int i;
@@ -1902,6 +2012,10 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp,
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
@@ -2241,6 +2355,92 @@ static void rtl_phy_write_fw(struct rtl8169_private *tp, struct rtl_fw *rtl_fw)
 	}
 }
 
+static void rtl_ocp_write_fw(struct rtl8169_private *tp, struct rtl_fw *rtl_fw)
+{
+	struct rtl_fw_phy_action *pa = &rtl_fw->phy_action;
+	void __iomem *ioaddr = tp->mmio_addr;
+	u32 predata, count;
+	u32 base_addr;
+	size_t index;
+
+	predata = count = 0;
+	base_addr = 0xa400;
+
+	for (index = 0; index < pa->size; ) {
+		u32 action = le32_to_cpu(pa->code[index]);
+		u32 data = action & 0x0000ffff;
+		u32 regno = (action & 0x0fff0000) >> 16;
+
+		if (!action)
+			break;
+
+		switch(action & 0xf0000000) {
+		case PHY_READ:
+			predata = r8168_phy_ocp_read(ioaddr,
+					base_addr + (regno -16) * 2);
+			count++;
+			index++;
+			break;
+		case PHY_DATA_OR:
+			predata |= data;
+			index++;
+			break;
+		case PHY_DATA_AND:
+			predata &= data;
+			index++;
+			break;
+		case PHY_BJMPN:
+			index -= regno;
+			break;
+		case PHY_CLEAR_READCOUNT:
+			count = 0;
+			index++;
+			break;
+		case PHY_WRITE:
+			if (regno == 0x1f)
+				base_addr = data << 4;
+			else
+				r8168_phy_ocp_write(ioaddr,
+						base_addr + (regno - 0x10) * 2,
+						data);
+			index++;
+			break;
+		case PHY_READCOUNT_EQ_SKIP:
+			index += (count == data) ? 2 : 1;
+			break;
+		case PHY_COMP_EQ_SKIPN:
+			if (predata == data)
+				index += regno;
+			index++;
+			break;
+		case PHY_COMP_NEQ_SKIPN:
+			if (predata != data)
+				index += regno;
+			index++;
+			break;
+		case PHY_WRITE_PREVIOUS:
+			r8168_phy_ocp_write(ioaddr, base_addr + (regno -16) * 2,
+					    predata);
+			index++;
+			break;
+		case PHY_SKIPN:
+			index += regno + 1;
+			break;
+		case PHY_DELAY_MS:
+			mdelay(data);
+			index++;
+			break;
+
+		case PHY_READ_MAC_BYTE:
+		case PHY_WRITE_MAC_BYTE:
+		case PHY_WRITE_ERI_WORD:
+		case PHY_READ_EFUSE:
+		default:
+			BUG();
+		}
+	}
+}
+
 static void rtl_release_firmware(struct rtl8169_private *tp)
 {
 	if (!IS_ERR_OR_NULL(tp->rtl_fw)) {
@@ -2256,7 +2456,7 @@ static void rtl_apply_firmware(struct rtl8169_private *tp)
 
 	/* TODO: release firmware once rtl_phy_write_fw signals failures. */
 	if (!IS_ERR_OR_NULL(rtl_fw))
-		rtl_phy_write_fw(tp, rtl_fw);
+		tp->write_fw(tp, rtl_fw);
 }
 
 static void rtl_apply_firmware_cond(struct rtl8169_private *tp, u8 reg, u16 val)
@@ -3221,6 +3421,56 @@ static void rtl8411_hw_phy_config(struct rtl8169_private *tp)
 	rtl_writephy(tp, 0x1f, 0x0000);
 }
 
+static void rtl8168g_1_hw_phy_config(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+	u32 mac_ocp_addr, i;
+	static const u16 mac_ocp_patch[] = {
+		0xE008, 0xE01B, 0xE01D, 0xE01F,
+		0xE021, 0xE023, 0xE025, 0xE027,
+		0x49D2 ,0xF10D, 0x766C, 0x49E2,
+		0xF00A, 0x1EC0, 0x8EE1, 0xC60A,
+		0x77C0, 0x4870, 0x9FC0, 0x1EA0,
+		0xC707, 0x8EE1, 0x9D6C, 0xC603,
+		0xBE00, 0xB416, 0x0076, 0xE86C,
+		0xC602, 0xBE00, 0x0000, 0xC602,
+		0xBE00, 0x0000, 0xC602, 0xBE00,
+		0x0000, 0xC602, 0xBE00, 0x0000,
+		0xC602, 0xBE00, 0x0000, 0xC602,
+		0xBE00, 0x0000, 0xC602, 0xBE00,
+		0x0000, 0x0000, 0x0000, 0x0000
+	};
+
+	/* patch code for GPHY reset */
+	mac_ocp_addr = 0xf800;
+	for (i = 0; mac_ocp_addr < 0xf868; i++) {
+		r8168_mac_ocp_write(ioaddr, mac_ocp_addr, mac_ocp_patch[i]);
+		mac_ocp_addr += 2;
+	}
+	r8168_mac_ocp_write(ioaddr, 0xfc26, 0x8000);
+	r8168_mac_ocp_write(ioaddr, 0xfc28, 0x0075);
+
+	rtl_apply_firmware(tp);
+
+	if (r8168_phy_ocp_read(ioaddr, 0xa460) & 0x0100)
+		rtl_w1w0_phy_ocp(ioaddr, 0xbcc4, 0x0000, 0x8000);
+	else
+		rtl_w1w0_phy_ocp(ioaddr, 0xbcc4, 0x8000, 0x0000);
+
+	if (r8168_phy_ocp_read(ioaddr, 0xa466) & 0x0100)
+		rtl_w1w0_phy_ocp(ioaddr, 0xc41a, 0x0002, 0x0000);
+	else
+		rtl_w1w0_phy_ocp(ioaddr, 0xbcc4, 0x0000, 0x0002);
+
+	rtl_w1w0_phy_ocp(ioaddr, 0xa442, 0x000c, 0x0000);
+	rtl_w1w0_phy_ocp(ioaddr, 0xa4b2, 0x0004, 0x0000);
+
+	r8168_phy_ocp_write(ioaddr, 0xa436, 0x8012);
+	rtl_w1w0_phy_ocp(ioaddr, 0xa438, 0x8000, 0x0000);
+
+	rtl_w1w0_phy_ocp(ioaddr, 0xc422, 0x4000, 0x2000);
+}
+
 static void rtl8102e_hw_phy_config(struct rtl8169_private *tp)
 {
 	static const struct phy_reg phy_reg_init[] = {
@@ -3407,6 +3657,13 @@ static void rtl_hw_phy_config(struct net_device *dev)
 		rtl8106e_hw_phy_config(tp);
 		break;
 
+	case RTL_GIGA_MAC_VER_40:
+		rtl8168g_1_hw_phy_config(tp);
+		break;
+
+	case RTL_GIGA_MAC_VER_41:
+		break;
+
 	default:
 		break;
 	}
@@ -3621,15 +3878,24 @@ static void __devinit rtl_init_mdio_ops(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_27:
 		ops->write	= r8168dp_1_mdio_write;
 		ops->read	= r8168dp_1_mdio_read;
+		tp->write_fw	= rtl_phy_write_fw;
 		break;
 	case RTL_GIGA_MAC_VER_28:
 	case RTL_GIGA_MAC_VER_31:
 		ops->write	= r8168dp_2_mdio_write;
 		ops->read	= r8168dp_2_mdio_read;
+		tp->write_fw	= rtl_phy_write_fw;
+		break;
+	case RTL_GIGA_MAC_VER_40:
+	case RTL_GIGA_MAC_VER_41:
+		ops->write	= r8168g_mdio_write;
+		ops->read	= r8168g_mdio_read;
+		tp->write_fw	= rtl_ocp_write_fw;
 		break;
 	default:
 		ops->write	= r8169_mdio_write;
 		ops->read	= r8169_mdio_read;
+		tp->write_fw	= rtl_phy_write_fw;
 		break;
 	}
 }
@@ -3647,6 +3913,8 @@ static void rtl_wol_suspend_quirk(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_37:
 	case RTL_GIGA_MAC_VER_38:
 	case RTL_GIGA_MAC_VER_39:
+	case RTL_GIGA_MAC_VER_40:
+	case RTL_GIGA_MAC_VER_41:
 		RTL_W32(RxConfig, RTL_R32(RxConfig) |
 			AcceptBroadcast | AcceptMulticast | AcceptMyPhys);
 		break;
@@ -3895,6 +4163,8 @@ static void __devinit rtl_init_pll_power_ops(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_35:
 	case RTL_GIGA_MAC_VER_36:
 	case RTL_GIGA_MAC_VER_38:
+	case RTL_GIGA_MAC_VER_40:
+	case RTL_GIGA_MAC_VER_41:
 		ops->down	= r8168_pll_power_down;
 		ops->up		= r8168_pll_power_up;
 		break;
@@ -4183,6 +4453,8 @@ static void rtl8169_hw_reset(struct rtl8169_private *tp)
 	           tp->mac_version == RTL_GIGA_MAC_VER_35 ||
 	           tp->mac_version == RTL_GIGA_MAC_VER_36 ||
 	           tp->mac_version == RTL_GIGA_MAC_VER_37 ||
+	           tp->mac_version == RTL_GIGA_MAC_VER_40 ||
+	           tp->mac_version == RTL_GIGA_MAC_VER_41 ||
 	           tp->mac_version == RTL_GIGA_MAC_VER_38) {
 		RTL_W8(ChipCmd, RTL_R8(ChipCmd) | StopReq);
 		while (!(RTL_R32(TxConfig) & TXCFG_EMPTY))
@@ -4921,6 +5193,28 @@ static void rtl_hw_start_8411(struct rtl8169_private *tp)
 		     ERIAR_EXGMAC);
 }
 
+static void rtl_hw_start_8168g_1(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+	struct pci_dev *pdev = tp->pci_dev;
+
+	rtl_eri_write(ioaddr, 0xc8, ERIAR_MASK_0101, 0x080002, ERIAR_EXGMAC);
+	rtl_eri_write(ioaddr, 0xcc, ERIAR_MASK_0001, 0x38, ERIAR_EXGMAC);
+	rtl_eri_write(ioaddr, 0xd0, ERIAR_MASK_0001, 0x48, ERIAR_EXGMAC);
+	rtl_eri_write(ioaddr, 0xe8, ERIAR_MASK_1111, 0x00100006, ERIAR_EXGMAC);
+	rtl_csi_access_enable_1(tp);
+	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
+	rtl_w1w0_eri(ioaddr, 0xdc, ERIAR_MASK_0001, 0x00, 0x01, ERIAR_EXGMAC);
+	rtl_w1w0_eri(ioaddr, 0xdc, ERIAR_MASK_0001, 0x01, 0x00, ERIAR_EXGMAC);
+	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
+	RTL_W32(MISC, RTL_R32(MISC) & ~RXDV_GATED_EN);
+	RTL_W8(MaxTxPacketSize, EarlySize);
+	rtl_eri_write(ioaddr, 0xc0, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
+	rtl_eri_write(ioaddr, 0xb8, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
+	RTL_W8(EEE_LED, RTL_R8(EEE_LED) & ~0x07);
+	rtl_w1w0_eri(ioaddr, 0x2fc, ERIAR_MASK_0001, 0x01, 0x02, ERIAR_EXGMAC);
+}
+
 static void rtl_hw_start_8168(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -5022,6 +5316,11 @@ static void rtl_hw_start_8168(struct net_device *dev)
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
@@ -6491,6 +6790,47 @@ static unsigned rtl_try_msi(struct rtl8169_private *tp,
 	return msi;
 }
 
+static void __devinit rtl_hw_init_8168g(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+	u32 tmp_data;
+
+	RTL_W32(MISC, RTL_R32(MISC) | RXDV_GATED_EN);
+	while (!(RTL_R32(TxConfig) & TXCFG_EMPTY))
+		udelay(100);
+
+	while ((RTL_R8(MCU) & (TX_EMPTY | RX_EMPTY)) != (TX_EMPTY | RX_EMPTY))
+		udelay(100);
+
+	RTL_W8(ChipCmd, RTL_R8(ChipCmd) & ~(CmdTxEnb | CmdRxEnb));
+	msleep(1);
+	RTL_W8(MCU, RTL_R8(MCU) & ~NOW_IS_OOB);
+
+	tmp_data = r8168_mac_ocp_read(ioaddr, 0xe8de);
+	tmp_data &= ~(1 << 14);
+	r8168_mac_ocp_write(ioaddr, 0xe8de, tmp_data);
+	while (!(RTL_R8(MCU) & LINK_LIST_RDY))
+		udelay(100);
+
+	tmp_data = r8168_mac_ocp_read(ioaddr, 0xe8de);
+	tmp_data |= (1 << 15);
+	r8168_mac_ocp_write(ioaddr, 0xe8de, tmp_data);
+	while (!(RTL_R8(MCU) & LINK_LIST_RDY))
+		udelay(100);
+}
+
+static void __devinit rtl_hw_initialize(struct rtl8169_private *tp)
+{
+	switch (tp->mac_version) {
+	case RTL_GIGA_MAC_VER_40:
+	case RTL_GIGA_MAC_VER_41:
+		rtl_hw_init_8168g(tp);
+		break;
+	default:
+		break;
+	}
+}
+
 static int __devinit
 rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
@@ -6600,6 +6940,8 @@ rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	rtl_irq_disable(tp);
 
+	rtl_hw_initialize(tp);
+
 	rtl_hw_reset(tp);
 
 	rtl_ack_events(tp, 0xffff);
-- 
1.7.10.2
