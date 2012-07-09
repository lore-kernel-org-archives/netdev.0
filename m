From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 0/6] Pull request for 'davem-next.r8169' branch
Date: Tue, 10 Jul 2012 00:44:04 +0200
Message-ID: <cover.1341872752.git.romieu@fr.zoreil.com>
Cc: David Miller <davem@davemloft.net>,
	Hayes Wang <hayeswang@realtek.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:59218 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751184Ab2GIW42 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 18:56:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please pull from branch 'davem-next.r8169' in repository

git://violet.fr.zoreil.com/romieu/linux davem-next.r8169

to get the changes below.

Distance from 'davem-next' (5c9df5fed198ad8b967f33a1e11862f2a1d08bf7)
---------------------------------------------------------------------

c558386b836ee97762e12495101c6e373f20e69d
ffc46952b313ff037debca1b4e3da9472ff4b441
fdf6fc067aaeb13aba89d1b56aa39d3bf06fde43
52989f0e429a97bc9075245e2e14ece2a4ebca5c
24192210a57a24a45b29dc3519dc42e073ea7b0a
5598bfe5191d09cdd622aeac39badc42508b227f

Diffstat
--------

 drivers/net/ethernet/realtek/r8169.c |  984 +++++++++++++++++++++++-----------
 1 file changed, 666 insertions(+), 318 deletions(-)

(Oops)

Shortlog
--------

Francois Romieu (4):
      r8169: mdio_ops signature change.
      r8169: csi_ops signature change.
      r8169: ephy, eri and efuse functions signature changes.
      r8169: abstract out loop conditions.

Hayes Wang (2):
      r8169: add RTL8106E support.
      r8169: support RTL8168G

Patch
-----

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index d7a04e0..7ff3423 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -46,6 +46,8 @@
 #define FIRMWARE_8105E_1	"rtl_nic/rtl8105e-1.fw"
 #define FIRMWARE_8402_1		"rtl_nic/rtl8402-1.fw"
 #define FIRMWARE_8411_1		"rtl_nic/rtl8411-1.fw"
+#define FIRMWARE_8106E_1	"rtl_nic/rtl8106e-1.fw"
+#define FIRMWARE_8168G_1	"rtl_nic/rtl8168g-1.fw"
 
 #ifdef RTL8169_DEBUG
 #define assert(expr) \
@@ -141,6 +143,9 @@ enum mac_version {
 	RTL_GIGA_MAC_VER_36,
 	RTL_GIGA_MAC_VER_37,
 	RTL_GIGA_MAC_VER_38,
+	RTL_GIGA_MAC_VER_39,
+	RTL_GIGA_MAC_VER_40,
+	RTL_GIGA_MAC_VER_41,
 	RTL_GIGA_MAC_NONE   = 0xff,
 };
 
@@ -259,6 +264,14 @@ static const struct {
 	[RTL_GIGA_MAC_VER_38] =
 		_R("RTL8411",		RTL_TD_1, FIRMWARE_8411_1,
 							JUMBO_9K, false),
+	[RTL_GIGA_MAC_VER_39] =
+		_R("RTL8106e",		RTL_TD_1, FIRMWARE_8106E_1,
+							JUMBO_1K, true),
+	[RTL_GIGA_MAC_VER_40] =
+		_R("RTL8168g/8111g",	RTL_TD_1, FIRMWARE_8168G_1,
+							JUMBO_9K, false),
+	[RTL_GIGA_MAC_VER_41] =
+		_R("RTL8168g/8111g",	RTL_TD_1, NULL, JUMBO_9K, false),
 };
 #undef _R
 
@@ -389,8 +402,12 @@ enum rtl8168_8101_registers {
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
@@ -416,6 +433,7 @@ enum rtl8168_registers {
 #define ERIAR_MASK_SHIFT		12
 #define ERIAR_MASK_0001			(0x1 << ERIAR_MASK_SHIFT)
 #define ERIAR_MASK_0011			(0x3 << ERIAR_MASK_SHIFT)
+#define ERIAR_MASK_0101			(0x5 << ERIAR_MASK_SHIFT)
 #define ERIAR_MASK_1111			(0xf << ERIAR_MASK_SHIFT)
 	EPHY_RXER_NUM		= 0x7c,
 	OCPDR			= 0xb0,	/* OCP GPHY access */
@@ -428,10 +446,14 @@ enum rtl8168_registers {
 #define OCPAR_FLAG			0x80000000
 #define OCPAR_GPHY_WRITE_CMD		0x8000f060
 #define OCPAR_GPHY_READ_CMD		0x0000f060
+	GPHY_OCP		= 0xb8,
 	RDSAR1			= 0xd0,	/* 8168c only. Undocumented on 8168dp */
 	MISC			= 0xf0,	/* 8168e only. */
 #define TXPLA_RST			(1 << 29)
+#define DISABLE_LAN_EN			(1 << 23) /* Enable GPIO pin */
 #define PWM_EN				(1 << 22)
+#define RXDV_GATED_EN			(1 << 19)
+#define EARLY_TALLY_EN			(1 << 16)
 };
 
 enum rtl_register_content {
@@ -721,8 +743,8 @@ struct rtl8169_private {
 	u16 event_slow;
 
 	struct mdio_ops {
-		void (*write)(void __iomem *, int, int);
-		int (*read)(void __iomem *, int);
+		void (*write)(struct rtl8169_private *, int, int);
+		int (*read)(struct rtl8169_private *, int);
 	} mdio_ops;
 
 	struct pll_power_ops {
@@ -736,8 +758,8 @@ struct rtl8169_private {
 	} jumbo_ops;
 
 	struct csi_ops {
-		void (*write)(void __iomem *, int, int);
-		u32 (*read)(void __iomem *, int);
+		void (*write)(struct rtl8169_private *, int, int);
+		u32 (*read)(struct rtl8169_private *, int);
 	} csi_ops;
 
 	int (*set_speed)(struct net_device *, u8 aneg, u16 sp, u8 dpx, u32 adv);
@@ -774,6 +796,8 @@ struct rtl8169_private {
 		} phy_action;
 	} *rtl_fw;
 #define RTL_FIRMWARE_UNKNOWN	ERR_PTR(-EAGAIN)
+
+	u32 ocp_base;
 };
 
 MODULE_AUTHOR("Realtek and the Linux r8169 crew <netdev@vger.kernel.org>");
@@ -794,6 +818,8 @@ MODULE_FIRMWARE(FIRMWARE_8168F_1);
 MODULE_FIRMWARE(FIRMWARE_8168F_2);
 MODULE_FIRMWARE(FIRMWARE_8402_1);
 MODULE_FIRMWARE(FIRMWARE_8411_1);
+MODULE_FIRMWARE(FIRMWARE_8106E_1);
+MODULE_FIRMWARE(FIRMWARE_8168G_1);
 
 static void rtl_lock_work(struct rtl8169_private *tp)
 {
@@ -818,47 +844,113 @@ static void rtl_tx_performance_tweak(struct pci_dev *pdev, u16 force)
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
@@ -872,36 +964,27 @@ static u16 rtl8168_get_ocp_reg(struct rtl8169_private *tp)
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
@@ -911,21 +994,124 @@ static int r8168dp_check_dash(struct rtl8169_private *tp)
 	return (ocp_read(tp, 0x0f, reg) & 0x00008000) ? 1 : 0;
 }
 
-static void r8169_mdio_write(void __iomem *ioaddr, int reg_addr, int value)
+static bool rtl_ocp_reg_failure(struct rtl8169_private *tp, u32 reg)
 {
-	int i;
+	if (reg & 0xffff0001) {
+		netif_err(tp, drv, tp->dev, "Invalid ocp reg %x!\n", reg);
+		return true;
+	}
+	return false;
+}
 
-	RTL_W32(PHYAR, 0x80000000 | (reg_addr & 0x1f) << 16 | (value & 0xffff));
+DECLARE_RTL_COND(rtl_ocp_gphy_cond)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
 
-	for (i = 20; i > 0; i--) {
-		/*
-		 * Check if the RTL8169 has completed writing to the specified
-		 * MII register.
-		 */
-		if (!(RTL_R32(PHYAR) & 0x80000000))
-			break;
-		udelay(25);
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
 	}
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
+DECLARE_RTL_COND(rtl_phyar_cond)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	return RTL_R32(PHYAR) & 0x80000000;
+}
+
+static void r8169_mdio_write(struct rtl8169_private *tp, int reg, int value)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	RTL_W32(PHYAR, 0x80000000 | (reg & 0x1f) << 16 | (value & 0xffff));
+
+	rtl_udelay_loop_wait_low(tp, &rtl_phyar_cond, 25, 20);
 	/*
 	 * According to hardware specs a 20us delay is required after write
 	 * complete indication, but before sending next command.
@@ -933,23 +1119,16 @@ static void r8169_mdio_write(void __iomem *ioaddr, int reg_addr, int value)
 	udelay(20);
 }
 
-static int r8169_mdio_read(void __iomem *ioaddr, int reg_addr)
+static int r8169_mdio_read(struct rtl8169_private *tp, int reg)
 {
-	int i, value = -1;
+	void __iomem *ioaddr = tp->mmio_addr;
+	int value;
 
-	RTL_W32(PHYAR, 0x0 | (reg_addr & 0x1f) << 16);
+	RTL_W32(PHYAR, 0x0 | (reg & 0x1f) << 16);
+
+	value = rtl_udelay_loop_wait_high(tp, &rtl_phyar_cond, 25, 20) ?
+		RTL_R32(PHYAR) & 0xffff : ~0;
 
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
 	/*
 	 * According to hardware specs a 20us delay is required after read
 	 * complete indication, but before sending next command.
@@ -959,45 +1138,35 @@ static int r8169_mdio_read(void __iomem *ioaddr, int reg_addr)
 	return value;
 }
 
-static void r8168dp_1_mdio_access(void __iomem *ioaddr, int reg_addr, u32 data)
+static void r8168dp_1_mdio_access(struct rtl8169_private *tp, int reg, u32 data)
 {
-	int i;
+	void __iomem *ioaddr = tp->mmio_addr;
 
-	RTL_W32(OCPDR, data |
-		((reg_addr & OCPDR_REG_MASK) << OCPDR_GPHY_REG_SHIFT));
+	RTL_W32(OCPDR, data | ((reg & OCPDR_REG_MASK) << OCPDR_GPHY_REG_SHIFT));
 	RTL_W32(OCPAR, OCPAR_GPHY_WRITE_CMD);
 	RTL_W32(EPHY_RXER_NUM, 0);
 
-	for (i = 0; i < 100; i++) {
-		mdelay(1);
-		if (!(RTL_R32(OCPAR) & OCPAR_FLAG))
-			break;
-	}
+	rtl_udelay_loop_wait_low(tp, &rtl_ocpar_cond, 1000, 100);
 }
 
-static void r8168dp_1_mdio_write(void __iomem *ioaddr, int reg_addr, int value)
+static void r8168dp_1_mdio_write(struct rtl8169_private *tp, int reg, int value)
 {
-	r8168dp_1_mdio_access(ioaddr, reg_addr, OCPDR_WRITE_CMD |
-		(value & OCPDR_DATA_MASK));
+	r8168dp_1_mdio_access(tp, reg,
+			      OCPDR_WRITE_CMD | (value & OCPDR_DATA_MASK));
 }
 
-static int r8168dp_1_mdio_read(void __iomem *ioaddr, int reg_addr)
+static int r8168dp_1_mdio_read(struct rtl8169_private *tp, int reg)
 {
-	int i;
+	void __iomem *ioaddr = tp->mmio_addr;
 
-	r8168dp_1_mdio_access(ioaddr, reg_addr, OCPDR_READ_CMD);
+	r8168dp_1_mdio_access(tp, reg, OCPDR_READ_CMD);
 
 	mdelay(1);
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
@@ -1012,22 +1181,25 @@ static void r8168dp_2_mdio_stop(void __iomem *ioaddr)
 	RTL_W32(0xd0, RTL_R32(0xd0) | R8168DP_1_MDIO_ACCESS_BIT);
 }
 
-static void r8168dp_2_mdio_write(void __iomem *ioaddr, int reg_addr, int value)
+static void r8168dp_2_mdio_write(struct rtl8169_private *tp, int reg, int value)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
+
 	r8168dp_2_mdio_start(ioaddr);
 
-	r8169_mdio_write(ioaddr, reg_addr, value);
+	r8169_mdio_write(tp, reg, value);
 
 	r8168dp_2_mdio_stop(ioaddr);
 }
 
-static int r8168dp_2_mdio_read(void __iomem *ioaddr, int reg_addr)
+static int r8168dp_2_mdio_read(struct rtl8169_private *tp, int reg)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
 	int value;
 
 	r8168dp_2_mdio_start(ioaddr);
 
-	value = r8169_mdio_read(ioaddr, reg_addr);
+	value = r8169_mdio_read(tp, reg);
 
 	r8168dp_2_mdio_stop(ioaddr);
 
@@ -1036,12 +1208,12 @@ static int r8168dp_2_mdio_read(void __iomem *ioaddr, int reg_addr)
 
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
@@ -1072,79 +1244,64 @@ static int rtl_mdio_read(struct net_device *dev, int phy_id, int location)
 	return rtl_readphy(tp, location);
 }
 
-static void rtl_ephy_write(void __iomem *ioaddr, int reg_addr, int value)
+DECLARE_RTL_COND(rtl_ephyar_cond)
 {
-	unsigned int i;
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	return RTL_R32(EPHYAR) & EPHYAR_FLAG;
+}
+
+static void rtl_ephy_write(struct rtl8169_private *tp, int reg_addr, int value)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
 
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
 
-static u16 rtl_ephy_read(void __iomem *ioaddr, int reg_addr)
+static u16 rtl_ephy_read(struct rtl8169_private *tp, int reg_addr)
 {
-	u16 value = 0xffff;
-	unsigned int i;
+	void __iomem *ioaddr = tp->mmio_addr;
 
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
 
-static
-void rtl_eri_write(void __iomem *ioaddr, int addr, u32 mask, u32 val, int type)
+static void rtl_eri_write(struct rtl8169_private *tp, int addr, u32 mask,
+			  u32 val, int type)
 {
-	unsigned int i;
+	void __iomem *ioaddr = tp->mmio_addr;
 
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
 
-static u32 rtl_eri_read(void __iomem *ioaddr, int addr, int type)
+static u32 rtl_eri_read(struct rtl8169_private *tp, int addr, int type)
 {
-	u32 value = ~0x00;
-	unsigned int i;
+	void __iomem *ioaddr = tp->mmio_addr;
 
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
 
-static void
-rtl_w1w0_eri(void __iomem *ioaddr, int addr, u32 mask, u32 p, u32 m, int type)
+static void rtl_w1w0_eri(struct rtl8169_private *tp, int addr, u32 mask, u32 p,
+			 u32 m, int type)
 {
 	u32 val;
 
-	val = rtl_eri_read(ioaddr, addr, type);
-	rtl_eri_write(ioaddr, addr, mask, (val & ~m) | p, type);
+	val = rtl_eri_read(tp, addr, type);
+	rtl_eri_write(tp, addr, mask, (val & ~m) | p, type);
 }
 
 struct exgmac_reg {
@@ -1153,31 +1310,30 @@ struct exgmac_reg {
 	u32 val;
 };
 
-static void rtl_write_exgmac_batch(void __iomem *ioaddr,
+static void rtl_write_exgmac_batch(struct rtl8169_private *tp,
 				   const struct exgmac_reg *r, int len)
 {
 	while (len-- > 0) {
-		rtl_eri_write(ioaddr, r->addr, r->mask, r->val, ERIAR_EXGMAC);
+		rtl_eri_write(tp, r->addr, r->mask, r->val, ERIAR_EXGMAC);
 		r++;
 	}
 }
 
-static u8 rtl8168d_efuse_read(void __iomem *ioaddr, int reg_addr)
+DECLARE_RTL_COND(rtl_efusear_cond)
 {
-	u8 value = 0xff;
-	unsigned int i;
+	void __iomem *ioaddr = tp->mmio_addr;
 
-	RTL_W32(EFUSEAR, (reg_addr & EFUSEAR_REG_MASK) << EFUSEAR_REG_SHIFT);
+	return RTL_R32(EFUSEAR) & EFUSEAR_FLAG;
+}
 
-	for (i = 0; i < 300; i++) {
-		if (RTL_R32(EFUSEAR) & EFUSEAR_FLAG) {
-			value = RTL_R32(EFUSEAR) & EFUSEAR_DATA_MASK;
-			break;
-		}
-		udelay(100);
-	}
+static u8 rtl8168d_efuse_read(struct rtl8169_private *tp, int reg_addr)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
 
-	return value;
+	RTL_W32(EFUSEAR, (reg_addr & EFUSEAR_REG_MASK) << EFUSEAR_REG_SHIFT);
+
+	return rtl_udelay_loop_wait_high(tp, &rtl_efusear_cond, 100, 300) ?
+		RTL_R32(EFUSEAR) & EFUSEAR_DATA_MASK : ~0;
 }
 
 static u16 rtl_get_events(struct rtl8169_private *tp)
@@ -1276,48 +1432,48 @@ static void rtl_link_chg_patch(struct rtl8169_private *tp)
 	if (tp->mac_version == RTL_GIGA_MAC_VER_34 ||
 	    tp->mac_version == RTL_GIGA_MAC_VER_38) {
 		if (RTL_R8(PHYstatus) & _1000bpsF) {
-			rtl_eri_write(ioaddr, 0x1bc, ERIAR_MASK_1111,
-				      0x00000011, ERIAR_EXGMAC);
-			rtl_eri_write(ioaddr, 0x1dc, ERIAR_MASK_1111,
-				      0x00000005, ERIAR_EXGMAC);
+			rtl_eri_write(tp, 0x1bc, ERIAR_MASK_1111, 0x00000011,
+				      ERIAR_EXGMAC);
+			rtl_eri_write(tp, 0x1dc, ERIAR_MASK_1111, 0x00000005,
+				      ERIAR_EXGMAC);
 		} else if (RTL_R8(PHYstatus) & _100bps) {
-			rtl_eri_write(ioaddr, 0x1bc, ERIAR_MASK_1111,
-				      0x0000001f, ERIAR_EXGMAC);
-			rtl_eri_write(ioaddr, 0x1dc, ERIAR_MASK_1111,
-				      0x00000005, ERIAR_EXGMAC);
+			rtl_eri_write(tp, 0x1bc, ERIAR_MASK_1111, 0x0000001f,
+				      ERIAR_EXGMAC);
+			rtl_eri_write(tp, 0x1dc, ERIAR_MASK_1111, 0x00000005,
+				      ERIAR_EXGMAC);
 		} else {
-			rtl_eri_write(ioaddr, 0x1bc, ERIAR_MASK_1111,
-				      0x0000001f, ERIAR_EXGMAC);
-			rtl_eri_write(ioaddr, 0x1dc, ERIAR_MASK_1111,
-				      0x0000003f, ERIAR_EXGMAC);
+			rtl_eri_write(tp, 0x1bc, ERIAR_MASK_1111, 0x0000001f,
+				      ERIAR_EXGMAC);
+			rtl_eri_write(tp, 0x1dc, ERIAR_MASK_1111, 0x0000003f,
+				      ERIAR_EXGMAC);
 		}
 		/* Reset packet filter */
-		rtl_w1w0_eri(ioaddr, 0xdc, ERIAR_MASK_0001, 0x00, 0x01,
+		rtl_w1w0_eri(tp, 0xdc, ERIAR_MASK_0001, 0x00, 0x01,
 			     ERIAR_EXGMAC);
-		rtl_w1w0_eri(ioaddr, 0xdc, ERIAR_MASK_0001, 0x01, 0x00,
+		rtl_w1w0_eri(tp, 0xdc, ERIAR_MASK_0001, 0x01, 0x00,
 			     ERIAR_EXGMAC);
 	} else if (tp->mac_version == RTL_GIGA_MAC_VER_35 ||
 		   tp->mac_version == RTL_GIGA_MAC_VER_36) {
 		if (RTL_R8(PHYstatus) & _1000bpsF) {
-			rtl_eri_write(ioaddr, 0x1bc, ERIAR_MASK_1111,
-				      0x00000011, ERIAR_EXGMAC);
-			rtl_eri_write(ioaddr, 0x1dc, ERIAR_MASK_1111,
-				      0x00000005, ERIAR_EXGMAC);
+			rtl_eri_write(tp, 0x1bc, ERIAR_MASK_1111, 0x00000011,
+				      ERIAR_EXGMAC);
+			rtl_eri_write(tp, 0x1dc, ERIAR_MASK_1111, 0x00000005,
+				      ERIAR_EXGMAC);
 		} else {
-			rtl_eri_write(ioaddr, 0x1bc, ERIAR_MASK_1111,
-				      0x0000001f, ERIAR_EXGMAC);
-			rtl_eri_write(ioaddr, 0x1dc, ERIAR_MASK_1111,
-				      0x0000003f, ERIAR_EXGMAC);
+			rtl_eri_write(tp, 0x1bc, ERIAR_MASK_1111, 0x0000001f,
+				      ERIAR_EXGMAC);
+			rtl_eri_write(tp, 0x1dc, ERIAR_MASK_1111, 0x0000003f,
+				      ERIAR_EXGMAC);
 		}
 	} else if (tp->mac_version == RTL_GIGA_MAC_VER_37) {
 		if (RTL_R8(PHYstatus) & _10bps) {
-			rtl_eri_write(ioaddr, 0x1d0, ERIAR_MASK_0011,
-				      0x4d02, ERIAR_EXGMAC);
-			rtl_eri_write(ioaddr, 0x1dc, ERIAR_MASK_0011,
-				      0x0060, ERIAR_EXGMAC);
+			rtl_eri_write(tp, 0x1d0, ERIAR_MASK_0011, 0x4d02,
+				      ERIAR_EXGMAC);
+			rtl_eri_write(tp, 0x1dc, ERIAR_MASK_0011, 0x0060,
+				      ERIAR_EXGMAC);
 		} else {
-			rtl_eri_write(ioaddr, 0x1d0, ERIAR_MASK_0011,
-				      0x0000, ERIAR_EXGMAC);
+			rtl_eri_write(tp, 0x1d0, ERIAR_MASK_0011, 0x0000,
+				      ERIAR_EXGMAC);
 		}
 	}
 }
@@ -1784,6 +1940,13 @@ static int rtl8169_get_sset_count(struct net_device *dev, int sset)
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
@@ -1792,7 +1955,6 @@ static void rtl8169_update_counters(struct net_device *dev)
 	struct rtl8169_counters *counters;
 	dma_addr_t paddr;
 	u32 cmd;
-	int wait = 1000;
 
 	/*
 	 * Some chips are unable to dump tally counters when the receiver
@@ -1810,13 +1972,8 @@ static void rtl8169_update_counters(struct net_device *dev)
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
@@ -1894,6 +2051,10 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp,
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
@@ -1933,6 +2094,8 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp,
 		{ 0x7c800000, 0x30000000,	RTL_GIGA_MAC_VER_11 },
 
 		/* 8101 family. */
+		{ 0x7cf00000, 0x44900000,	RTL_GIGA_MAC_VER_39 },
+		{ 0x7c800000, 0x44800000,	RTL_GIGA_MAC_VER_39 },
 		{ 0x7c800000, 0x44000000,	RTL_GIGA_MAC_VER_37 },
 		{ 0x7cf00000, 0x40b00000,	RTL_GIGA_MAC_VER_30 },
 		{ 0x7cf00000, 0x40a00000,	RTL_GIGA_MAC_VER_30 },
@@ -2186,7 +2349,7 @@ static void rtl_phy_write_fw(struct rtl8169_private *tp, struct rtl_fw *rtl_fw)
 			index -= regno;
 			break;
 		case PHY_READ_EFUSE:
-			predata = rtl8168d_efuse_read(tp->mmio_addr, regno);
+			predata = rtl8168d_efuse_read(tp, regno);
 			index++;
 			break;
 		case PHY_CLEAR_READCOUNT:
@@ -2626,7 +2789,6 @@ static void rtl8168d_1_hw_phy_config(struct rtl8169_private *tp)
 		{ 0x1f, 0x0000 },
 		{ 0x0d, 0xf880 }
 	};
-	void __iomem *ioaddr = tp->mmio_addr;
 
 	rtl_writephy_batch(tp, phy_reg_init_0, ARRAY_SIZE(phy_reg_init_0));
 
@@ -2638,7 +2800,7 @@ static void rtl8168d_1_hw_phy_config(struct rtl8169_private *tp)
 	rtl_w1w0_phy(tp, 0x0b, 0x0010, 0x00ef);
 	rtl_w1w0_phy(tp, 0x0c, 0xa200, 0x5d00);
 
-	if (rtl8168d_efuse_read(ioaddr, 0x01) == 0xb1) {
+	if (rtl8168d_efuse_read(tp, 0x01) == 0xb1) {
 		static const struct phy_reg phy_reg_init[] = {
 			{ 0x1f, 0x0002 },
 			{ 0x05, 0x669a },
@@ -2738,11 +2900,10 @@ static void rtl8168d_2_hw_phy_config(struct rtl8169_private *tp)
 		{ 0x1f, 0x0000 },
 		{ 0x0d, 0xf880 }
 	};
-	void __iomem *ioaddr = tp->mmio_addr;
 
 	rtl_writephy_batch(tp, phy_reg_init_0, ARRAY_SIZE(phy_reg_init_0));
 
-	if (rtl8168d_efuse_read(ioaddr, 0x01) == 0xb1) {
+	if (rtl8168d_efuse_read(tp, 0x01) == 0xb1) {
 		static const struct phy_reg phy_reg_init[] = {
 			{ 0x1f, 0x0002 },
 			{ 0x05, 0x669a },
@@ -3010,8 +3171,7 @@ static void rtl8168e_2_hw_phy_config(struct rtl8169_private *tp)
 	rtl_writephy(tp, 0x1f, 0x0000);
 
 	/* EEE setting */
-	rtl_w1w0_eri(tp->mmio_addr, 0x1b0, ERIAR_MASK_1111, 0x0000, 0x0003,
-		     ERIAR_EXGMAC);
+	rtl_w1w0_eri(tp, 0x1b0, ERIAR_MASK_1111, 0x0000, 0x0003, ERIAR_EXGMAC);
 	rtl_writephy(tp, 0x1f, 0x0005);
 	rtl_writephy(tp, 0x05, 0x8b85);
 	rtl_w1w0_phy(tp, 0x06, 0x0000, 0x2000);
@@ -3115,7 +3275,6 @@ static void rtl8168f_2_hw_phy_config(struct rtl8169_private *tp)
 
 static void rtl8411_hw_phy_config(struct rtl8169_private *tp)
 {
-	void __iomem *ioaddr = tp->mmio_addr;
 	static const struct phy_reg phy_reg_init[] = {
 		/* Channel estimation fine tune */
 		{ 0x1f, 0x0003 },
@@ -3189,7 +3348,7 @@ static void rtl8411_hw_phy_config(struct rtl8169_private *tp)
 	rtl_writephy(tp, 0x1f, 0x0000);
 
 	/* eee setting */
-	rtl_w1w0_eri(ioaddr, 0x1b0, ERIAR_MASK_0001, 0x00, 0x03, ERIAR_EXGMAC);
+	rtl_w1w0_eri(tp, 0x1b0, ERIAR_MASK_0001, 0x00, 0x03, ERIAR_EXGMAC);
 	rtl_writephy(tp, 0x1f, 0x0005);
 	rtl_writephy(tp, 0x05, 0x8b85);
 	rtl_w1w0_phy(tp, 0x06, 0x0000, 0x2000);
@@ -3211,6 +3370,55 @@ static void rtl8411_hw_phy_config(struct rtl8169_private *tp)
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
@@ -3256,8 +3464,6 @@ static void rtl8105e_hw_phy_config(struct rtl8169_private *tp)
 
 static void rtl8402_hw_phy_config(struct rtl8169_private *tp)
 {
-	void __iomem *ioaddr = tp->mmio_addr;
-
 	/* Disable ALDPS before setting firmware */
 	rtl_writephy(tp, 0x1f, 0x0000);
 	rtl_writephy(tp, 0x18, 0x0310);
@@ -3266,13 +3472,35 @@ static void rtl8402_hw_phy_config(struct rtl8169_private *tp)
 	rtl_apply_firmware(tp);
 
 	/* EEE setting */
-	rtl_eri_write(ioaddr, 0x1b0, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
+	rtl_eri_write(tp, 0x1b0, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
 	rtl_writephy(tp, 0x1f, 0x0004);
 	rtl_writephy(tp, 0x10, 0x401f);
 	rtl_writephy(tp, 0x19, 0x7030);
 	rtl_writephy(tp, 0x1f, 0x0000);
 }
 
+static void rtl8106e_hw_phy_config(struct rtl8169_private *tp)
+{
+	static const struct phy_reg phy_reg_init[] = {
+		{ 0x1f, 0x0004 },
+		{ 0x10, 0xc07f },
+		{ 0x19, 0x7030 },
+		{ 0x1f, 0x0000 }
+	};
+
+	/* Disable ALDPS before ram code */
+	rtl_writephy(tp, 0x1f, 0x0000);
+	rtl_writephy(tp, 0x18, 0x0310);
+	msleep(100);
+
+	rtl_apply_firmware(tp);
+
+	rtl_eri_write(tp, 0x1b0, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
+	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+
+	rtl_eri_write(tp, 0x1d0, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
+}
+
 static void rtl_hw_phy_config(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -3369,6 +3597,15 @@ static void rtl_hw_phy_config(struct net_device *dev)
 		rtl8411_hw_phy_config(tp);
 		break;
 
+	case RTL_GIGA_MAC_VER_39:
+		rtl8106e_hw_phy_config(tp);
+		break;
+
+	case RTL_GIGA_MAC_VER_40:
+		rtl8168g_1_hw_phy_config(tp);
+		break;
+
+	case RTL_GIGA_MAC_VER_41:
 	default:
 		break;
 	}
@@ -3426,18 +3663,16 @@ static void rtl8169_release_board(struct pci_dev *pdev, struct net_device *dev,
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
@@ -3512,7 +3747,7 @@ static void rtl_rar_set(struct rtl8169_private *tp, u8 *addr)
 								low  >> 16 },
 		};
 
-		rtl_write_exgmac_batch(ioaddr, e, ARRAY_SIZE(e));
+		rtl_write_exgmac_batch(tp, e, ARRAY_SIZE(e));
 	}
 
 	RTL_W8(Cfg9346, Cfg9346_Lock);
@@ -3589,6 +3824,11 @@ static void __devinit rtl_init_mdio_ops(struct rtl8169_private *tp)
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
@@ -3608,6 +3848,9 @@ static void rtl_wol_suspend_quirk(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_34:
 	case RTL_GIGA_MAC_VER_37:
 	case RTL_GIGA_MAC_VER_38:
+	case RTL_GIGA_MAC_VER_39:
+	case RTL_GIGA_MAC_VER_40:
+	case RTL_GIGA_MAC_VER_41:
 		RTL_W32(RxConfig, RTL_R32(RxConfig) |
 			AcceptBroadcast | AcceptMulticast | AcceptMyPhys);
 		break;
@@ -3761,7 +4004,7 @@ static void r8168_pll_power_down(struct rtl8169_private *tp)
 
 	if (tp->mac_version == RTL_GIGA_MAC_VER_32 ||
 	    tp->mac_version == RTL_GIGA_MAC_VER_33)
-		rtl_ephy_write(ioaddr, 0x19, 0xff64);
+		rtl_ephy_write(tp, 0x19, 0xff64);
 
 	if (rtl_wol_pll_power_down(tp))
 		return;
@@ -3830,6 +4073,7 @@ static void __devinit rtl_init_pll_power_ops(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_29:
 	case RTL_GIGA_MAC_VER_30:
 	case RTL_GIGA_MAC_VER_37:
+	case RTL_GIGA_MAC_VER_39:
 		ops->down	= r810x_pll_power_down;
 		ops->up		= r810x_pll_power_up;
 		break;
@@ -3855,6 +4099,8 @@ static void __devinit rtl_init_pll_power_ops(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_35:
 	case RTL_GIGA_MAC_VER_36:
 	case RTL_GIGA_MAC_VER_38:
+	case RTL_GIGA_MAC_VER_40:
+	case RTL_GIGA_MAC_VER_41:
 		ops->down	= r8168_pll_power_down;
 		ops->up		= r8168_pll_power_up;
 		break;
@@ -4051,6 +4297,8 @@ static void __devinit rtl_init_jumbo_ops(struct rtl8169_private *tp)
 	 * No action needed for jumbo frames with 8169.
 	 * No jumbo for 810x at all.
 	 */
+	case RTL_GIGA_MAC_VER_40:
+	case RTL_GIGA_MAC_VER_41:
 	default:
 		ops->disable	= NULL;
 		ops->enable	= NULL;
@@ -4058,20 +4306,20 @@ static void __devinit rtl_init_jumbo_ops(struct rtl8169_private *tp)
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
@@ -4125,6 +4373,20 @@ static void rtl_rx_close(struct rtl8169_private *tp)
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
@@ -4137,16 +4399,16 @@ static void rtl8169_hw_reset(struct rtl8169_private *tp)
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
+	           tp->mac_version == RTL_GIGA_MAC_VER_40 ||
+	           tp->mac_version == RTL_GIGA_MAC_VER_41 ||
 	           tp->mac_version == RTL_GIGA_MAC_VER_38) {
 		RTL_W8(ChipCmd, RTL_R8(ChipCmd) | StopReq);
-		while (!(RTL_R32(TxConfig) & TXCFG_EMPTY))
-			udelay(100);
+		rtl_udelay_loop_wait_high(tp, &rtl_txcfg_empty_cond, 100, 666);
 	} else {
 		RTL_W8(ChipCmd, RTL_R8(ChipCmd) | StopReq);
 		udelay(100);
@@ -4352,15 +4614,12 @@ static void rtl_hw_start_8169(struct net_device *dev)
 static void rtl_csi_write(struct rtl8169_private *tp, int addr, int value)
 {
 	if (tp->csi_ops.write)
-		tp->csi_ops.write(tp->mmio_addr, addr, value);
+		tp->csi_ops.write(tp, addr, value);
 }
 
 static u32 rtl_csi_read(struct rtl8169_private *tp, int addr)
 {
-	if (tp->csi_ops.read)
-		return tp->csi_ops.read(tp->mmio_addr, addr);
-	else
-		return ~0;
+	return tp->csi_ops.read ? tp->csi_ops.read(tp, addr) : ~0;
 }
 
 static void rtl_csi_access_enable(struct rtl8169_private *tp, u32 bits)
@@ -4381,73 +4640,56 @@ static void rtl_csi_access_enable_2(struct rtl8169_private *tp)
 	rtl_csi_access_enable(tp, 0x27000000);
 }
 
-static void r8169_csi_write(void __iomem *ioaddr, int addr, int value)
+DECLARE_RTL_COND(rtl_csiar_cond)
 {
-	unsigned int i;
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	return RTL_R32(CSIAR) & CSIAR_FLAG;
+}
+
+static void r8169_csi_write(struct rtl8169_private *tp, int addr, int value)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
 
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
 
-static u32 r8169_csi_read(void __iomem *ioaddr, int addr)
+static u32 r8169_csi_read(struct rtl8169_private *tp, int addr)
 {
-	u32 value = ~0x00;
-	unsigned int i;
+	void __iomem *ioaddr = tp->mmio_addr;
 
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
 
-static void r8402_csi_write(void __iomem *ioaddr, int addr, int value)
+static void r8402_csi_write(struct rtl8169_private *tp, int addr, int value)
 {
-	unsigned int i;
+	void __iomem *ioaddr = tp->mmio_addr;
 
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
 
-static u32 r8402_csi_read(void __iomem *ioaddr, int addr)
+static u32 r8402_csi_read(struct rtl8169_private *tp, int addr)
 {
-	u32 value = ~0x00;
-	unsigned int i;
+	void __iomem *ioaddr = tp->mmio_addr;
 
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
@@ -4492,13 +4734,14 @@ struct ephy_info {
 	u16 bits;
 };
 
-static void rtl_ephy_init(void __iomem *ioaddr, const struct ephy_info *e, int len)
+static void rtl_ephy_init(struct rtl8169_private *tp, const struct ephy_info *e,
+			  int len)
 {
 	u16 w;
 
 	while (len-- > 0) {
-		w = (rtl_ephy_read(ioaddr, e->offset) & ~e->mask) | e->bits;
-		rtl_ephy_write(ioaddr, e->offset, w);
+		w = (rtl_ephy_read(tp, e->offset) & ~e->mask) | e->bits;
+		rtl_ephy_write(tp, e->offset, w);
 		e++;
 	}
 }
@@ -4582,7 +4825,6 @@ static void __rtl_hw_start_8168cp(struct rtl8169_private *tp)
 
 static void rtl_hw_start_8168cp_1(struct rtl8169_private *tp)
 {
-	void __iomem *ioaddr = tp->mmio_addr;
 	static const struct ephy_info e_info_8168cp[] = {
 		{ 0x01, 0,	0x0001 },
 		{ 0x02, 0x0800,	0x1000 },
@@ -4593,7 +4835,7 @@ static void rtl_hw_start_8168cp_1(struct rtl8169_private *tp)
 
 	rtl_csi_access_enable_2(tp);
 
-	rtl_ephy_init(ioaddr, e_info_8168cp, ARRAY_SIZE(e_info_8168cp));
+	rtl_ephy_init(tp, e_info_8168cp, ARRAY_SIZE(e_info_8168cp));
 
 	__rtl_hw_start_8168cp(tp);
 }
@@ -4644,14 +4886,13 @@ static void rtl_hw_start_8168c_1(struct rtl8169_private *tp)
 
 	RTL_W8(DBG_REG, 0x06 | FIX_NAK_1 | FIX_NAK_2);
 
-	rtl_ephy_init(ioaddr, e_info_8168c_1, ARRAY_SIZE(e_info_8168c_1));
+	rtl_ephy_init(tp, e_info_8168c_1, ARRAY_SIZE(e_info_8168c_1));
 
 	__rtl_hw_start_8168cp(tp);
 }
 
 static void rtl_hw_start_8168c_2(struct rtl8169_private *tp)
 {
-	void __iomem *ioaddr = tp->mmio_addr;
 	static const struct ephy_info e_info_8168c_2[] = {
 		{ 0x01, 0,	0x0001 },
 		{ 0x03, 0x0400,	0x0220 }
@@ -4659,7 +4900,7 @@ static void rtl_hw_start_8168c_2(struct rtl8169_private *tp)
 
 	rtl_csi_access_enable_2(tp);
 
-	rtl_ephy_init(ioaddr, e_info_8168c_2, ARRAY_SIZE(e_info_8168c_2));
+	rtl_ephy_init(tp, e_info_8168c_2, ARRAY_SIZE(e_info_8168c_2));
 
 	__rtl_hw_start_8168cp(tp);
 }
@@ -4727,8 +4968,8 @@ static void rtl_hw_start_8168d_4(struct rtl8169_private *tp)
 		const struct ephy_info *e = e_info_8168d_4 + i;
 		u16 w;
 
-		w = rtl_ephy_read(ioaddr, e->offset);
-		rtl_ephy_write(ioaddr, 0x03, (w & e->mask) | e->bits);
+		w = rtl_ephy_read(tp, e->offset);
+		rtl_ephy_write(tp, 0x03, (w & e->mask) | e->bits);
 	}
 
 	rtl_enable_clock_request(pdev);
@@ -4756,7 +4997,7 @@ static void rtl_hw_start_8168e_1(struct rtl8169_private *tp)
 
 	rtl_csi_access_enable_2(tp);
 
-	rtl_ephy_init(ioaddr, e_info_8168e_1, ARRAY_SIZE(e_info_8168e_1));
+	rtl_ephy_init(tp, e_info_8168e_1, ARRAY_SIZE(e_info_8168e_1));
 
 	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
 
@@ -4782,19 +5023,18 @@ static void rtl_hw_start_8168e_2(struct rtl8169_private *tp)
 
 	rtl_csi_access_enable_1(tp);
 
-	rtl_ephy_init(ioaddr, e_info_8168e_2, ARRAY_SIZE(e_info_8168e_2));
+	rtl_ephy_init(tp, e_info_8168e_2, ARRAY_SIZE(e_info_8168e_2));
 
 	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
 
-	rtl_eri_write(ioaddr, 0xc0, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
-	rtl_eri_write(ioaddr, 0xb8, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
-	rtl_eri_write(ioaddr, 0xc8, ERIAR_MASK_1111, 0x00100002, ERIAR_EXGMAC);
-	rtl_eri_write(ioaddr, 0xe8, ERIAR_MASK_1111, 0x00100006, ERIAR_EXGMAC);
-	rtl_eri_write(ioaddr, 0xcc, ERIAR_MASK_1111, 0x00000050, ERIAR_EXGMAC);
-	rtl_eri_write(ioaddr, 0xd0, ERIAR_MASK_1111, 0x07ff0060, ERIAR_EXGMAC);
-	rtl_w1w0_eri(ioaddr, 0x1b0, ERIAR_MASK_0001, 0x10, 0x00, ERIAR_EXGMAC);
-	rtl_w1w0_eri(ioaddr, 0x0d4, ERIAR_MASK_0011, 0x0c00, 0xff00,
-		     ERIAR_EXGMAC);
+	rtl_eri_write(tp, 0xc0, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
+	rtl_eri_write(tp, 0xb8, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
+	rtl_eri_write(tp, 0xc8, ERIAR_MASK_1111, 0x00100002, ERIAR_EXGMAC);
+	rtl_eri_write(tp, 0xe8, ERIAR_MASK_1111, 0x00100006, ERIAR_EXGMAC);
+	rtl_eri_write(tp, 0xcc, ERIAR_MASK_1111, 0x00000050, ERIAR_EXGMAC);
+	rtl_eri_write(tp, 0xd0, ERIAR_MASK_1111, 0x07ff0060, ERIAR_EXGMAC);
+	rtl_w1w0_eri(tp, 0x1b0, ERIAR_MASK_0001, 0x10, 0x00, ERIAR_EXGMAC);
+	rtl_w1w0_eri(tp, 0x0d4, ERIAR_MASK_0011, 0x0c00, 0xff00, ERIAR_EXGMAC);
 
 	RTL_W8(MaxTxPacketSize, EarlySize);
 
@@ -4820,16 +5060,16 @@ static void rtl_hw_start_8168f(struct rtl8169_private *tp)
 
 	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
 
-	rtl_eri_write(ioaddr, 0xc0, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
-	rtl_eri_write(ioaddr, 0xb8, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
-	rtl_eri_write(ioaddr, 0xc8, ERIAR_MASK_1111, 0x00100002, ERIAR_EXGMAC);
-	rtl_eri_write(ioaddr, 0xe8, ERIAR_MASK_1111, 0x00100006, ERIAR_EXGMAC);
-	rtl_w1w0_eri(ioaddr, 0xdc, ERIAR_MASK_0001, 0x00, 0x01, ERIAR_EXGMAC);
-	rtl_w1w0_eri(ioaddr, 0xdc, ERIAR_MASK_0001, 0x01, 0x00, ERIAR_EXGMAC);
-	rtl_w1w0_eri(ioaddr, 0x1b0, ERIAR_MASK_0001, 0x10, 0x00, ERIAR_EXGMAC);
-	rtl_w1w0_eri(ioaddr, 0x1d0, ERIAR_MASK_0001, 0x10, 0x00, ERIAR_EXGMAC);
-	rtl_eri_write(ioaddr, 0xcc, ERIAR_MASK_1111, 0x00000050, ERIAR_EXGMAC);
-	rtl_eri_write(ioaddr, 0xd0, ERIAR_MASK_1111, 0x00000060, ERIAR_EXGMAC);
+	rtl_eri_write(tp, 0xc0, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
+	rtl_eri_write(tp, 0xb8, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
+	rtl_eri_write(tp, 0xc8, ERIAR_MASK_1111, 0x00100002, ERIAR_EXGMAC);
+	rtl_eri_write(tp, 0xe8, ERIAR_MASK_1111, 0x00100006, ERIAR_EXGMAC);
+	rtl_w1w0_eri(tp, 0xdc, ERIAR_MASK_0001, 0x00, 0x01, ERIAR_EXGMAC);
+	rtl_w1w0_eri(tp, 0xdc, ERIAR_MASK_0001, 0x01, 0x00, ERIAR_EXGMAC);
+	rtl_w1w0_eri(tp, 0x1b0, ERIAR_MASK_0001, 0x10, 0x00, ERIAR_EXGMAC);
+	rtl_w1w0_eri(tp, 0x1d0, ERIAR_MASK_0001, 0x10, 0x00, ERIAR_EXGMAC);
+	rtl_eri_write(tp, 0xcc, ERIAR_MASK_1111, 0x00000050, ERIAR_EXGMAC);
+	rtl_eri_write(tp, 0xd0, ERIAR_MASK_1111, 0x00000060, ERIAR_EXGMAC);
 
 	RTL_W8(MaxTxPacketSize, EarlySize);
 
@@ -4854,10 +5094,9 @@ static void rtl_hw_start_8168f_1(struct rtl8169_private *tp)
 
 	rtl_hw_start_8168f(tp);
 
-	rtl_ephy_init(ioaddr, e_info_8168f_1, ARRAY_SIZE(e_info_8168f_1));
+	rtl_ephy_init(tp, e_info_8168f_1, ARRAY_SIZE(e_info_8168f_1));
 
-	rtl_w1w0_eri(ioaddr, 0x0d4, ERIAR_MASK_0011, 0x0c00, 0xff00,
-		     ERIAR_EXGMAC);
+	rtl_w1w0_eri(tp, 0x0d4, ERIAR_MASK_0011, 0x0c00, 0xff00, ERIAR_EXGMAC);
 
 	/* Adjust EEE LED frequency */
 	RTL_W8(EEE_LED, RTL_R8(EEE_LED) & ~0x07);
@@ -4865,7 +5104,6 @@ static void rtl_hw_start_8168f_1(struct rtl8169_private *tp)
 
 static void rtl_hw_start_8411(struct rtl8169_private *tp)
 {
-	void __iomem *ioaddr = tp->mmio_addr;
 	static const struct ephy_info e_info_8168f_1[] = {
 		{ 0x06, 0x00c0,	0x0020 },
 		{ 0x0f, 0xffff,	0x5200 },
@@ -4875,10 +5113,39 @@ static void rtl_hw_start_8411(struct rtl8169_private *tp)
 
 	rtl_hw_start_8168f(tp);
 
-	rtl_ephy_init(ioaddr, e_info_8168f_1, ARRAY_SIZE(e_info_8168f_1));
+	rtl_ephy_init(tp, e_info_8168f_1, ARRAY_SIZE(e_info_8168f_1));
 
-	rtl_w1w0_eri(ioaddr, 0x0d4, ERIAR_MASK_0011, 0x0c00, 0x0000,
-		     ERIAR_EXGMAC);
+	rtl_w1w0_eri(tp, 0x0d4, ERIAR_MASK_0011, 0x0c00, 0x0000, ERIAR_EXGMAC);
+}
+
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
 }
 
 static void rtl_hw_start_8168(struct net_device *dev)
@@ -4982,6 +5249,11 @@ static void rtl_hw_start_8168(struct net_device *dev)
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
@@ -5036,7 +5308,7 @@ static void rtl_hw_start_8102e_1(struct rtl8169_private *tp)
 	if ((cfg1 & LEDS0) && (cfg1 & LEDS1))
 		RTL_W8(Config1, cfg1 & ~LEDS0);
 
-	rtl_ephy_init(ioaddr, e_info_8102e_1, ARRAY_SIZE(e_info_8102e_1));
+	rtl_ephy_init(tp, e_info_8102e_1, ARRAY_SIZE(e_info_8102e_1));
 }
 
 static void rtl_hw_start_8102e_2(struct rtl8169_private *tp)
@@ -5056,7 +5328,7 @@ static void rtl_hw_start_8102e_3(struct rtl8169_private *tp)
 {
 	rtl_hw_start_8102e_2(tp);
 
-	rtl_ephy_write(tp->mmio_addr, 0x03, 0xc2f9);
+	rtl_ephy_write(tp, 0x03, 0xc2f9);
 }
 
 static void rtl_hw_start_8105e_1(struct rtl8169_private *tp)
@@ -5082,15 +5354,13 @@ static void rtl_hw_start_8105e_1(struct rtl8169_private *tp)
 	RTL_W8(MCU, RTL_R8(MCU) | EN_NDP | EN_OOB_RESET);
 	RTL_W8(DLLPR, RTL_R8(DLLPR) | PFM_EN);
 
-	rtl_ephy_init(ioaddr, e_info_8105e_1, ARRAY_SIZE(e_info_8105e_1));
+	rtl_ephy_init(tp, e_info_8105e_1, ARRAY_SIZE(e_info_8105e_1));
 }
 
 static void rtl_hw_start_8105e_2(struct rtl8169_private *tp)
 {
-	void __iomem *ioaddr = tp->mmio_addr;
-
 	rtl_hw_start_8105e_1(tp);
-	rtl_ephy_write(ioaddr, 0x1e, rtl_ephy_read(ioaddr, 0x1e) | 0x8000);
+	rtl_ephy_write(tp, 0x1e, rtl_ephy_read(tp, 0x1e) | 0x8000);
 }
 
 static void rtl_hw_start_8402(struct rtl8169_private *tp)
@@ -5109,18 +5379,29 @@ static void rtl_hw_start_8402(struct rtl8169_private *tp)
 	RTL_W32(TxConfig, RTL_R32(TxConfig) | TXCFG_AUTO_FIFO);
 	RTL_W8(MCU, RTL_R8(MCU) & ~NOW_IS_OOB);
 
-	rtl_ephy_init(ioaddr, e_info_8402, ARRAY_SIZE(e_info_8402));
+	rtl_ephy_init(tp, e_info_8402, ARRAY_SIZE(e_info_8402));
 
 	rtl_tx_performance_tweak(tp->pci_dev, 0x5 << MAX_READ_REQUEST_SHIFT);
 
-	rtl_eri_write(ioaddr, 0xc8, ERIAR_MASK_1111, 0x00000002, ERIAR_EXGMAC);
-	rtl_eri_write(ioaddr, 0xe8, ERIAR_MASK_1111, 0x00000006, ERIAR_EXGMAC);
-	rtl_w1w0_eri(ioaddr, 0xdc, ERIAR_MASK_0001, 0x00, 0x01, ERIAR_EXGMAC);
-	rtl_w1w0_eri(ioaddr, 0xdc, ERIAR_MASK_0001, 0x01, 0x00, ERIAR_EXGMAC);
-	rtl_eri_write(ioaddr, 0xc0, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
-	rtl_eri_write(ioaddr, 0xb8, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
-	rtl_w1w0_eri(ioaddr, 0x0d4, ERIAR_MASK_0011, 0x0e00, 0xff00,
-		     ERIAR_EXGMAC);
+	rtl_eri_write(tp, 0xc8, ERIAR_MASK_1111, 0x00000002, ERIAR_EXGMAC);
+	rtl_eri_write(tp, 0xe8, ERIAR_MASK_1111, 0x00000006, ERIAR_EXGMAC);
+	rtl_w1w0_eri(tp, 0xdc, ERIAR_MASK_0001, 0x00, 0x01, ERIAR_EXGMAC);
+	rtl_w1w0_eri(tp, 0xdc, ERIAR_MASK_0001, 0x01, 0x00, ERIAR_EXGMAC);
+	rtl_eri_write(tp, 0xc0, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
+	rtl_eri_write(tp, 0xb8, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
+	rtl_w1w0_eri(tp, 0x0d4, ERIAR_MASK_0011, 0x0e00, 0xff00, ERIAR_EXGMAC);
+}
+
+static void rtl_hw_start_8106(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	/* Force LAN exit from ASPM if Rx/Tx are not idle */
+	RTL_W32(FuncEvent, RTL_R32(FuncEvent) | 0x002800);
+
+	RTL_W32(MISC, (RTL_R32(MISC) | DISABLE_LAN_EN) & ~EARLY_TALLY_EN);
+	RTL_W8(MCU, RTL_R8(MCU) | EN_NDP | EN_OOB_RESET);
+	RTL_W8(DLLPR, RTL_R8(DLLPR) & ~PFM_EN);
 }
 
 static void rtl_hw_start_8101(struct net_device *dev)
@@ -5167,6 +5448,10 @@ static void rtl_hw_start_8101(struct net_device *dev)
 	case RTL_GIGA_MAC_VER_37:
 		rtl_hw_start_8402(tp);
 		break;
+
+	case RTL_GIGA_MAC_VER_39:
+		rtl_hw_start_8106(tp);
+		break;
 	}
 
 	RTL_W8(Cfg9346, Cfg9346_Lock);
@@ -6435,6 +6720,67 @@ static unsigned rtl_try_msi(struct rtl8169_private *tp,
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
@@ -6544,6 +6890,8 @@ rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	rtl_irq_disable(tp);
 
+	rtl_hw_initialize(tp);
+
 	rtl_hw_reset(tp);
 
 	rtl_ack_events(tp, 0xffff);
-- 
Ueimor
