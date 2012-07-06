From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v2 net-next 2/2] r8169: support RTL8168G
Date: Fri, 6 Jul 2012 17:20:46 +0200
Message-ID: <20120706152046.GB6981@electric-eye.fr.zoreil.com>
References: <1340966060-2749-1-git-send-email-hayeswang@realtek.com> <1341221002-1522-1-git-send-email-hayeswang@realtek.com> <1341221002-1522-2-git-send-email-hayeswang@realtek.com> <20120704220458.GA1621@electric-eye.fr.zoreil.com> <1341449507.2058.6.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="1yeeQ81UyVL57Vl7"
Cc: Hayes Wang <hayeswang@realtek.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:53654 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757623Ab2GFPc2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2012 11:32:28 -0400
Content-Disposition: inline
In-Reply-To: <1341449507.2058.6.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--1yeeQ81UyVL57Vl7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Joe Perches <joe@perches.com> :
[...]
> This pattern is used a couple more times.
> There's no failure handling either.

I can do something for the initialize path. Other than that it's mostly
deeply burried hardware failure so I'd rather concentrate a bit on 
current problem reports.

This series already took me a bit further than expected (see below).

> Maybe use a macro with RTL_R8/32, register and test?

Here is what I came up with. Completely untested. Attached patches #1 and
#2 should  be applied on top of the previous patch beforehand.

[PATCH 3/3] r8169: abstract out loop conditions.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/realtek/r8169.c |  460 +++++++++++++++++-----------------
 1 file changed, 225 insertions(+), 235 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 0759c76..4f350fc 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -844,47 +844,113 @@ static void rtl_tx_performance_tweak(struct pci_dev *pdev, u16 force)
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
+#define DECLARE_RTL_COND(name) \
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
@@ -898,36 +964,27 @@ static u16 rtl8168_get_ocp_reg(struct rtl8169_private *tp)
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
@@ -946,42 +1003,36 @@ static bool rtl_ocp_reg_failure(struct rtl8169_private *tp, u32 reg)
 	return false;
 }
 
+DECLARE_RTL_COND(rtl_ocp_gphy_cond)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	return RTL_R32(GPHY_OCP) & OCPAR_FLAG;
+}
+
 static void r8168_phy_ocp_write(struct rtl8169_private *tp, u32 reg, u32 data)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
-	int i;
 
 	if (rtl_ocp_reg_failure(tp, reg))
 		return;
 
 	RTL_W32(GPHY_OCP, OCPAR_FLAG | (reg << 15) | data);
 
-	for (i = 0; i < 10; i++) {
-		udelay(25);
-		if (!(RTL_R32(GPHY_OCP) & OCPAR_FLAG))
-			break;
-	}
+	rtl_udelay_loop_wait_low(tp, &rtl_ocp_gphy_cond, 25, 10);
 }
 
 static u16 r8168_phy_ocp_read(struct rtl8169_private *tp, u32 reg)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
-	u32 data;
-	int i;
 
 	if (rtl_ocp_reg_failure(tp, reg))
 		return 0;
 
 	RTL_W32(GPHY_OCP, reg << 15);
 
-	for (i = 0; i < 10; i++) {
-		udelay(25);
-		data = RTL_R32(GPHY_OCP);
-		if (data & OCPAR_FLAG)
-			break;
-	}
-
-	return (u16)(data & 0xffff);
+	return rtl_udelay_loop_wait_high(tp, &rtl_ocp_gphy_cond, 25, 10) ?
+		(RTL_R32(GPHY_OCP) & 0xffff) : ~0;
 }
 
 static void rtl_w1w0_phy_ocp(struct rtl8169_private *tp, int reg, int p, int m)
@@ -992,42 +1043,36 @@ static void rtl_w1w0_phy_ocp(struct rtl8169_private *tp, int reg, int p, int m)
 	r8168_phy_ocp_write(tp, reg, (val | p) & ~m);
 }
 
+DECLARE_RTL_COND(rtl_ocpdr_cond)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	return RTL_R32(OCPDR) & OCPAR_FLAG;
+}
+
 static void r8168_mac_ocp_write(struct rtl8169_private *tp, u32 reg, u32 data)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
-	int i;
 
 	if (rtl_ocp_reg_failure(tp, reg))
 		return;
 
 	RTL_W32(OCPDR, OCPAR_FLAG | (reg << 15) | data);
 
-	for (i = 0; i < 10; i++) {
-		udelay(25);
-		if (!(RTL_R32(OCPDR) & OCPAR_FLAG))
-			break;
-	}
+	rtl_udelay_loop_wait_low(tp, &rtl_ocpdr_cond, 25, 10);
 }
 
 static u16 r8168_mac_ocp_read(struct rtl8169_private *tp, u32 reg)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
-	u32 data;
-	int i;
 
 	if (rtl_ocp_reg_failure(tp, reg))
 		return 0;
 
 	RTL_W32(OCPDR, reg << 15);
 
-	for (i = 0; i < 10; i++) {
-		udelay(25);
-		data = RTL_R32(OCPDR);
-		if (data & OCPAR_FLAG)
-			break;
-	}
-
-	return (u16)(data & 0xffff);
+	return rtl_udelay_loop_wait_high(tp, &rtl_ocpdr_cond, 25, 10) ?
+		RTL_R32(OCPDR) : ~0;
 }
 
 #define OCP_STD_PHY_BASE	0xa400
@@ -1053,23 +1098,22 @@ static int r8168g_mdio_read(struct rtl8169_private *tp, int reg_addr)
 	return r8168_phy_ocp_read(tp, tp->ocp_base + reg_addr * 2);
 }
 
+DECLARE_RTL_COND(rtl_phyar_cond)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	return RTL_R32(PHYAR) & 0x80000000;
+}
+
 static
 void r8169_mdio_write(struct rtl8169_private *tp, int reg_addr, int value)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
-	int i;
 
 	RTL_W32(PHYAR, 0x80000000 | (reg_addr & 0x1f) << 16 | (value & 0xffff));
 
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
+
 	/*
 	 * According to hardware specs a 20us delay is required after write
 	 * complete indication, but before sending next command.
@@ -1080,21 +1124,13 @@ void r8169_mdio_write(struct rtl8169_private *tp, int reg_addr, int value)
 static int r8169_mdio_read(struct rtl8169_private *tp, int reg_addr)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
-	int i, value = -1;
+	int value;
 
 	RTL_W32(PHYAR, 0x0 | (reg_addr & 0x1f) << 16);
 
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
@@ -1107,17 +1143,12 @@ static int r8169_mdio_read(struct rtl8169_private *tp, int reg_addr)
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
@@ -1129,7 +1160,6 @@ static void r8168dp_1_mdio_write(struct rtl8169_private *tp, int reg, int value)
 static int r8168dp_1_mdio_read(struct rtl8169_private *tp, int reg_addr)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
-	int i;
 
 	r8168dp_1_mdio_access(tp, reg_addr, OCPDR_READ_CMD);
 
@@ -1137,13 +1167,8 @@ static int r8168dp_1_mdio_read(struct rtl8169_private *tp, int reg_addr)
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
@@ -1221,74 +1246,55 @@ static int rtl_mdio_read(struct net_device *dev, int phy_id, int location)
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
@@ -1315,23 +1321,21 @@ static void rtl_write_exgmac_batch(struct rtl8169_private *tp,
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
@@ -1938,6 +1942,13 @@ static int rtl8169_get_sset_count(struct net_device *dev, int sset)
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
@@ -1946,7 +1957,6 @@ static void rtl8169_update_counters(struct net_device *dev)
 	struct rtl8169_counters *counters;
 	dma_addr_t paddr;
 	u32 cmd;
-	int wait = 1000;
 
 	/*
 	 * Some chips are unable to dump tally counters when the receiver
@@ -1964,13 +1974,8 @@ static void rtl8169_update_counters(struct net_device *dev)
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
@@ -3662,18 +3667,16 @@ static void rtl8169_release_board(struct pci_dev *pdev, struct net_device *dev,
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
@@ -4307,20 +4310,20 @@ static void __devinit rtl_init_jumbo_ops(struct rtl8169_private *tp)
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
@@ -4374,6 +4377,20 @@ static void rtl_rx_close(struct rtl8169_private *tp)
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
@@ -4386,8 +4403,7 @@ static void rtl8169_hw_reset(struct rtl8169_private *tp)
 	if (tp->mac_version == RTL_GIGA_MAC_VER_27 ||
 	    tp->mac_version == RTL_GIGA_MAC_VER_28 ||
 	    tp->mac_version == RTL_GIGA_MAC_VER_31) {
-		while (RTL_R8(TxPoll) & NPQ)
-			udelay(20);
+		rtl_udelay_loop_wait_low(tp, &rtl_npq_cond, 20, 42*42);
 	} else if (tp->mac_version == RTL_GIGA_MAC_VER_34 ||
 	           tp->mac_version == RTL_GIGA_MAC_VER_35 ||
 	           tp->mac_version == RTL_GIGA_MAC_VER_36 ||
@@ -4396,8 +4412,7 @@ static void rtl8169_hw_reset(struct rtl8169_private *tp)
 	           tp->mac_version == RTL_GIGA_MAC_VER_41 ||
 	           tp->mac_version == RTL_GIGA_MAC_VER_38) {
 		RTL_W8(ChipCmd, RTL_R8(ChipCmd) | StopReq);
-		while (!(RTL_R32(TxConfig) & TXCFG_EMPTY))
-			udelay(100);
+		rtl_udelay_loop_wait_high(tp, &rtl_txcfg_empty_cond, 100, 666);
 	} else {
 		RTL_W8(ChipCmd, RTL_R8(ChipCmd) | StopReq);
 		udelay(100);
@@ -4608,7 +4623,7 @@ static void rtl_csi_write(struct rtl8169_private *tp, int addr, int value)
 
 static u32 rtl_csi_read(struct rtl8169_private *tp, int addr)
 {
-	return tp->csi_ops.read ? tp->csi_ops.read(tp, addr) :~0;
+	return tp->csi_ops.read ? tp->csi_ops.read(tp, addr) : ~0;
 }
 
 static void rtl_csi_access_enable(struct rtl8169_private *tp, u32 bits)
@@ -4629,77 +4644,56 @@ static void rtl_csi_access_enable_2(struct rtl8169_private *tp)
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
@@ -6731,17 +6725,18 @@ static unsigned rtl_try_msi(struct rtl8169_private *tp,
 	return msi;
 }
 
-#define	RTL_LOOP_MAX	10000
+DECLARE_RTL_COND(rtl_link_list_ready_cond)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
 
-static void rtl_mcu_wait_list_ready(void __iomem *ioaddr)
+	return RTL_R8(MCU) & LINK_LIST_RDY;
+}
+
+DECLARE_RTL_COND(rtl_rxtx_empty_cond)
 {
-	int i;
+	void __iomem *ioaddr = tp->mmio_addr;
 
-	for (i = 0; i < RTL_LOOP_MAX; i++) {
-		if (RTL_R8(MCU) & LINK_LIST_RDY)
-			return;
-		udelay(100);
-	}
+	return (RTL_R8(MCU) & RXTX_EMPTY) == RXTX_EMPTY;
 }
 
 #define PLOP		0xe8de
@@ -6750,21 +6745,14 @@ static void __devinit rtl_hw_init_8168g(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
 	u32 data;
-	int i;
 
 	RTL_W32(MISC, RTL_R32(MISC) | RXDV_GATED_EN);
 
-	for (i = 0; i < RTL_LOOP_MAX; i++) {
-		if (RTL_R32(TxConfig) & TXCFG_EMPTY)
-			break;
-		udelay(100);
-	}
+	if (!rtl_udelay_loop_wait_high(tp, &rtl_txcfg_empty_cond, 100, 42))
+		return;
 
-	for (i = 0; i < RTL_LOOP_MAX; i++) {
-		if ((RTL_R8(MCU) & RXTX_EMPTY) == RXTX_EMPTY)
-			break;
-		udelay(100);
-	}
+	if (!rtl_udelay_loop_wait_high(tp, &rtl_rxtx_empty_cond, 100, 42))
+		return;
 
 	RTL_W8(ChipCmd, RTL_R8(ChipCmd) & ~(CmdTxEnb | CmdRxEnb));
 	msleep(1);
@@ -6774,13 +6762,15 @@ static void __devinit rtl_hw_init_8168g(struct rtl8169_private *tp)
 	data &= ~(1 << 14);
 	r8168_mac_ocp_write(ioaddr, PLOP, data);
 
-	rtl_mcu_wait_list_ready(ioaddr);
+	if (!rtl_udelay_loop_wait_high(tp, &rtl_link_list_ready_cond, 100, 42))
+		return;
 
 	data = r8168_mac_ocp_read(ioaddr, PLOP);
 	data |= (1 << 15);
 	r8168_mac_ocp_write(ioaddr, PLOP, data);
 
-	rtl_mcu_wait_list_ready(ioaddr);
+	if (!rtl_udelay_loop_wait_high(tp, &rtl_link_list_ready_cond, 100, 42))
+		return;
 }
 
 static void __devinit rtl_hw_initialize(struct rtl8169_private *tp)
-- 
1.7.10.4


--1yeeQ81UyVL57Vl7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0001-r8169-csi_ops-signature-change.patch"

>From 29b8c48d9b08fbc0e751460b2a46d3de426db2f5 Mon Sep 17 00:00:00 2001
Message-Id: <29b8c48d9b08fbc0e751460b2a46d3de426db2f5.1341578247.git.romieu@fr.zoreil.com>
From: Francois Romieu <romieu@fr.zoreil.com>
Date: Fri, 6 Jul 2012 13:37:00 +0200
Subject: [PATCH 1/3] r8169: csi_ops signature change.
X-Organisation: Land of Sunshine Inc.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/realtek/r8169.c |   23 ++++++++++++-----------
 1 file changed, 12 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index c37aed9..adab11f 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -758,8 +758,8 @@ struct rtl8169_private {
 	} jumbo_ops;
 
 	struct csi_ops {
-		void (*write)(void __iomem *, int, int);
-		u32 (*read)(void __iomem *, int);
+		void (*write)(struct rtl8169_private *, int, int);
+		u32 (*read)(struct rtl8169_private *, int);
 	} csi_ops;
 
 	int (*set_speed)(struct net_device *, u8 aneg, u16 sp, u8 dpx, u32 adv);
@@ -4609,15 +4609,12 @@ static void rtl_hw_start_8169(struct net_device *dev)
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
+	return tp->csi_ops.read ? tp->csi_ops.read(tp, addr) :~0;
 }
 
 static void rtl_csi_access_enable(struct rtl8169_private *tp, u32 bits)
@@ -4638,8 +4635,9 @@ static void rtl_csi_access_enable_2(struct rtl8169_private *tp)
 	rtl_csi_access_enable(tp, 0x27000000);
 }
 
-static void r8169_csi_write(void __iomem *ioaddr, int addr, int value)
+static void r8169_csi_write(struct rtl8169_private *tp, int addr, int value)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
 	unsigned int i;
 
 	RTL_W32(CSIDR, value);
@@ -4653,8 +4651,9 @@ static void r8169_csi_write(void __iomem *ioaddr, int addr, int value)
 	}
 }
 
-static u32 r8169_csi_read(void __iomem *ioaddr, int addr)
+static u32 r8169_csi_read(struct rtl8169_private *tp, int addr)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
 	u32 value = ~0x00;
 	unsigned int i;
 
@@ -4672,8 +4671,9 @@ static u32 r8169_csi_read(void __iomem *ioaddr, int addr)
 	return value;
 }
 
-static void r8402_csi_write(void __iomem *ioaddr, int addr, int value)
+static void r8402_csi_write(struct rtl8169_private *tp, int addr, int value)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
 	unsigned int i;
 
 	RTL_W32(CSIDR, value);
@@ -4688,8 +4688,9 @@ static void r8402_csi_write(void __iomem *ioaddr, int addr, int value)
 	}
 }
 
-static u32 r8402_csi_read(void __iomem *ioaddr, int addr)
+static u32 r8402_csi_read(struct rtl8169_private *tp, int addr)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
 	u32 value = ~0x00;
 	unsigned int i;
 
-- 
1.7.10.4


--1yeeQ81UyVL57Vl7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0002-r8169-push-void-__iomem-deeper.patch"

>From 4f9e2c24bbcbb2b0ae1c902597e4855ad25e4673 Mon Sep 17 00:00:00 2001
Message-Id: <4f9e2c24bbcbb2b0ae1c902597e4855ad25e4673.1341578247.git.romieu@fr.zoreil.com>
In-Reply-To: <29b8c48d9b08fbc0e751460b2a46d3de426db2f5.1341578247.git.romieu@fr.zoreil.com>
References: <29b8c48d9b08fbc0e751460b2a46d3de426db2f5.1341578247.git.romieu@fr.zoreil.com>
From: Francois Romieu <romieu@fr.zoreil.com>
Date: Fri, 6 Jul 2012 13:56:55 +0200
Subject: [PATCH 2/3] r8169: push void __iomem * deeper.
X-Organisation: Land of Sunshine Inc.

I need more context than they carry and they are too easy to mess up
with anyway.

Concerned:
- r8168dp_1_mdio_access
- r8168dp_1_mdio_write
- rtl_ephy_write
- rtl_ephy_read
- rtl_eri_write
- rtl_eri_read
- rtl_w1w0_eri
- rtl_write_exgmac_batch
- rtl8168d_efuse_read

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/realtek/r8169.c |  245 ++++++++++++++++------------------
 1 file changed, 116 insertions(+), 129 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index adab11f..0759c76 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -1104,12 +1104,12 @@ static int r8169_mdio_read(struct rtl8169_private *tp, int reg_addr)
 	return value;
 }
 
-static void r8168dp_1_mdio_access(void __iomem *ioaddr, int reg_addr, u32 data)
+static void r8168dp_1_mdio_access(struct rtl8169_private *tp, int reg, u32 data)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
 	int i;
 
-	RTL_W32(OCPDR, data |
-		((reg_addr & OCPDR_REG_MASK) << OCPDR_GPHY_REG_SHIFT));
+	RTL_W32(OCPDR, data | ((reg & OCPDR_REG_MASK) << OCPDR_GPHY_REG_SHIFT));
 	RTL_W32(OCPAR, OCPAR_GPHY_WRITE_CMD);
 	RTL_W32(EPHY_RXER_NUM, 0);
 
@@ -1120,13 +1120,10 @@ static void r8168dp_1_mdio_access(void __iomem *ioaddr, int reg_addr, u32 data)
 	}
 }
 
-static
-void r8168dp_1_mdio_write(struct rtl8169_private *tp, int reg_addr, int value)
+static void r8168dp_1_mdio_write(struct rtl8169_private *tp, int reg, int value)
 {
-	void __iomem *ioaddr = tp->mmio_addr;
-
-	r8168dp_1_mdio_access(ioaddr, reg_addr, OCPDR_WRITE_CMD |
-		(value & OCPDR_DATA_MASK));
+	r8168dp_1_mdio_access(tp, reg,
+			      OCPDR_WRITE_CMD | (value & OCPDR_DATA_MASK));
 }
 
 static int r8168dp_1_mdio_read(struct rtl8169_private *tp, int reg_addr)
@@ -1134,7 +1131,7 @@ static int r8168dp_1_mdio_read(struct rtl8169_private *tp, int reg_addr)
 	void __iomem *ioaddr = tp->mmio_addr;
 	int i;
 
-	r8168dp_1_mdio_access(ioaddr, reg_addr, OCPDR_READ_CMD);
+	r8168dp_1_mdio_access(tp, reg_addr, OCPDR_READ_CMD);
 
 	mdelay(1);
 	RTL_W32(OCPAR, OCPAR_GPHY_READ_CMD);
@@ -1224,8 +1221,9 @@ static int rtl_mdio_read(struct net_device *dev, int phy_id, int location)
 	return rtl_readphy(tp, location);
 }
 
-static void rtl_ephy_write(void __iomem *ioaddr, int reg_addr, int value)
+static void rtl_ephy_write(struct rtl8169_private *tp, int reg_addr, int value)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
 	unsigned int i;
 
 	RTL_W32(EPHYAR, EPHYAR_WRITE_CMD | (value & EPHYAR_DATA_MASK) |
@@ -1238,8 +1236,9 @@ static void rtl_ephy_write(void __iomem *ioaddr, int reg_addr, int value)
 	}
 }
 
-static u16 rtl_ephy_read(void __iomem *ioaddr, int reg_addr)
+static u16 rtl_ephy_read(struct rtl8169_private *tp, int reg_addr)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
 	u16 value = 0xffff;
 	unsigned int i;
 
@@ -1256,9 +1255,10 @@ static u16 rtl_ephy_read(void __iomem *ioaddr, int reg_addr)
 	return value;
 }
 
-static
-void rtl_eri_write(void __iomem *ioaddr, int addr, u32 mask, u32 val, int type)
+static void rtl_eri_write(struct rtl8169_private *tp, int addr, u32 mask,
+			  u32 val, int type)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
 	unsigned int i;
 
 	BUG_ON((addr & 3) || (mask == 0));
@@ -1272,8 +1272,9 @@ void rtl_eri_write(void __iomem *ioaddr, int addr, u32 mask, u32 val, int type)
 	}
 }
 
-static u32 rtl_eri_read(void __iomem *ioaddr, int addr, int type)
+static u32 rtl_eri_read(struct rtl8169_private *tp, int addr, int type)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
 	u32 value = ~0x00;
 	unsigned int i;
 
@@ -1290,13 +1291,13 @@ static u32 rtl_eri_read(void __iomem *ioaddr, int addr, int type)
 	return value;
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
@@ -1305,17 +1306,18 @@ struct exgmac_reg {
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
+static u8 rtl8168d_efuse_read(struct rtl8169_private *tp, int reg_addr)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
 	u8 value = 0xff;
 	unsigned int i;
 
@@ -1428,48 +1430,48 @@ static void rtl_link_chg_patch(struct rtl8169_private *tp)
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
@@ -2344,7 +2346,7 @@ static void rtl_phy_write_fw(struct rtl8169_private *tp, struct rtl_fw *rtl_fw)
 			index -= regno;
 			break;
 		case PHY_READ_EFUSE:
-			predata = rtl8168d_efuse_read(tp->mmio_addr, regno);
+			predata = rtl8168d_efuse_read(tp, regno);
 			index++;
 			break;
 		case PHY_CLEAR_READCOUNT:
@@ -2784,7 +2786,6 @@ static void rtl8168d_1_hw_phy_config(struct rtl8169_private *tp)
 		{ 0x1f, 0x0000 },
 		{ 0x0d, 0xf880 }
 	};
-	void __iomem *ioaddr = tp->mmio_addr;
 
 	rtl_writephy_batch(tp, phy_reg_init_0, ARRAY_SIZE(phy_reg_init_0));
 
@@ -2796,7 +2797,7 @@ static void rtl8168d_1_hw_phy_config(struct rtl8169_private *tp)
 	rtl_w1w0_phy(tp, 0x0b, 0x0010, 0x00ef);
 	rtl_w1w0_phy(tp, 0x0c, 0xa200, 0x5d00);
 
-	if (rtl8168d_efuse_read(ioaddr, 0x01) == 0xb1) {
+	if (rtl8168d_efuse_read(tp, 0x01) == 0xb1) {
 		static const struct phy_reg phy_reg_init[] = {
 			{ 0x1f, 0x0002 },
 			{ 0x05, 0x669a },
@@ -2896,11 +2897,10 @@ static void rtl8168d_2_hw_phy_config(struct rtl8169_private *tp)
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
@@ -3168,8 +3168,7 @@ static void rtl8168e_2_hw_phy_config(struct rtl8169_private *tp)
 	rtl_writephy(tp, 0x1f, 0x0000);
 
 	/* EEE setting */
-	rtl_w1w0_eri(tp->mmio_addr, 0x1b0, ERIAR_MASK_1111, 0x0000, 0x0003,
-		     ERIAR_EXGMAC);
+	rtl_w1w0_eri(tp, 0x1b0, ERIAR_MASK_1111, 0x0000, 0x0003, ERIAR_EXGMAC);
 	rtl_writephy(tp, 0x1f, 0x0005);
 	rtl_writephy(tp, 0x05, 0x8b85);
 	rtl_w1w0_phy(tp, 0x06, 0x0000, 0x2000);
@@ -3273,7 +3272,6 @@ static void rtl8168f_2_hw_phy_config(struct rtl8169_private *tp)
 
 static void rtl8411_hw_phy_config(struct rtl8169_private *tp)
 {
-	void __iomem *ioaddr = tp->mmio_addr;
 	static const struct phy_reg phy_reg_init[] = {
 		/* Channel estimation fine tune */
 		{ 0x1f, 0x0003 },
@@ -3347,7 +3345,7 @@ static void rtl8411_hw_phy_config(struct rtl8169_private *tp)
 	rtl_writephy(tp, 0x1f, 0x0000);
 
 	/* eee setting */
-	rtl_w1w0_eri(ioaddr, 0x1b0, ERIAR_MASK_0001, 0x00, 0x03, ERIAR_EXGMAC);
+	rtl_w1w0_eri(tp, 0x1b0, ERIAR_MASK_0001, 0x00, 0x03, ERIAR_EXGMAC);
 	rtl_writephy(tp, 0x1f, 0x0005);
 	rtl_writephy(tp, 0x05, 0x8b85);
 	rtl_w1w0_phy(tp, 0x06, 0x0000, 0x2000);
@@ -3463,8 +3461,6 @@ static void rtl8105e_hw_phy_config(struct rtl8169_private *tp)
 
 static void rtl8402_hw_phy_config(struct rtl8169_private *tp)
 {
-	void __iomem *ioaddr = tp->mmio_addr;
-
 	/* Disable ALDPS before setting firmware */
 	rtl_writephy(tp, 0x1f, 0x0000);
 	rtl_writephy(tp, 0x18, 0x0310);
@@ -3473,7 +3469,7 @@ static void rtl8402_hw_phy_config(struct rtl8169_private *tp)
 	rtl_apply_firmware(tp);
 
 	/* EEE setting */
-	rtl_eri_write(ioaddr, 0x1b0, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
+	rtl_eri_write(tp, 0x1b0, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
 	rtl_writephy(tp, 0x1f, 0x0004);
 	rtl_writephy(tp, 0x10, 0x401f);
 	rtl_writephy(tp, 0x19, 0x7030);
@@ -3482,8 +3478,6 @@ static void rtl8402_hw_phy_config(struct rtl8169_private *tp)
 
 static void rtl8106e_hw_phy_config(struct rtl8169_private *tp)
 {
-	void __iomem *ioaddr = tp->mmio_addr;
-
 	static const struct phy_reg phy_reg_init[] = {
 		{ 0x1f, 0x0004 },
 		{ 0x10, 0xc07f },
@@ -3498,10 +3492,10 @@ static void rtl8106e_hw_phy_config(struct rtl8169_private *tp)
 
 	rtl_apply_firmware(tp);
 
-	rtl_eri_write(ioaddr, 0x1b0, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
+	rtl_eri_write(tp, 0x1b0, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
 	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 
-	rtl_eri_write(ioaddr, 0x1d0, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
+	rtl_eri_write(tp, 0x1d0, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
 }
 
 static void rtl_hw_phy_config(struct net_device *dev)
@@ -3754,7 +3748,7 @@ static void rtl_rar_set(struct rtl8169_private *tp, u8 *addr)
 								low  >> 16 },
 		};
 
-		rtl_write_exgmac_batch(ioaddr, e, ARRAY_SIZE(e));
+		rtl_write_exgmac_batch(tp, e, ARRAY_SIZE(e));
 	}
 
 	RTL_W8(Cfg9346, Cfg9346_Lock);
@@ -4011,7 +4005,7 @@ static void r8168_pll_power_down(struct rtl8169_private *tp)
 
 	if (tp->mac_version == RTL_GIGA_MAC_VER_32 ||
 	    tp->mac_version == RTL_GIGA_MAC_VER_33)
-		rtl_ephy_write(ioaddr, 0x19, 0xff64);
+		rtl_ephy_write(tp, 0x19, 0xff64);
 
 	if (rtl_wol_pll_power_down(tp))
 		return;
@@ -4750,13 +4744,14 @@ struct ephy_info {
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
@@ -4840,7 +4835,6 @@ static void __rtl_hw_start_8168cp(struct rtl8169_private *tp)
 
 static void rtl_hw_start_8168cp_1(struct rtl8169_private *tp)
 {
-	void __iomem *ioaddr = tp->mmio_addr;
 	static const struct ephy_info e_info_8168cp[] = {
 		{ 0x01, 0,	0x0001 },
 		{ 0x02, 0x0800,	0x1000 },
@@ -4851,7 +4845,7 @@ static void rtl_hw_start_8168cp_1(struct rtl8169_private *tp)
 
 	rtl_csi_access_enable_2(tp);
 
-	rtl_ephy_init(ioaddr, e_info_8168cp, ARRAY_SIZE(e_info_8168cp));
+	rtl_ephy_init(tp, e_info_8168cp, ARRAY_SIZE(e_info_8168cp));
 
 	__rtl_hw_start_8168cp(tp);
 }
@@ -4902,14 +4896,13 @@ static void rtl_hw_start_8168c_1(struct rtl8169_private *tp)
 
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
@@ -4917,7 +4910,7 @@ static void rtl_hw_start_8168c_2(struct rtl8169_private *tp)
 
 	rtl_csi_access_enable_2(tp);
 
-	rtl_ephy_init(ioaddr, e_info_8168c_2, ARRAY_SIZE(e_info_8168c_2));
+	rtl_ephy_init(tp, e_info_8168c_2, ARRAY_SIZE(e_info_8168c_2));
 
 	__rtl_hw_start_8168cp(tp);
 }
@@ -4985,8 +4978,8 @@ static void rtl_hw_start_8168d_4(struct rtl8169_private *tp)
 		const struct ephy_info *e = e_info_8168d_4 + i;
 		u16 w;
 
-		w = rtl_ephy_read(ioaddr, e->offset);
-		rtl_ephy_write(ioaddr, 0x03, (w & e->mask) | e->bits);
+		w = rtl_ephy_read(tp, e->offset);
+		rtl_ephy_write(tp, 0x03, (w & e->mask) | e->bits);
 	}
 
 	rtl_enable_clock_request(pdev);
@@ -5014,7 +5007,7 @@ static void rtl_hw_start_8168e_1(struct rtl8169_private *tp)
 
 	rtl_csi_access_enable_2(tp);
 
-	rtl_ephy_init(ioaddr, e_info_8168e_1, ARRAY_SIZE(e_info_8168e_1));
+	rtl_ephy_init(tp, e_info_8168e_1, ARRAY_SIZE(e_info_8168e_1));
 
 	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
 
@@ -5040,18 +5033,18 @@ static void rtl_hw_start_8168e_2(struct rtl8169_private *tp)
 
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
+	rtl_eri_write(tp, 0xc0, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
+	rtl_eri_write(tp, 0xb8, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
+	rtl_eri_write(tp, 0xc8, ERIAR_MASK_1111, 0x00100002, ERIAR_EXGMAC);
+	rtl_eri_write(tp, 0xe8, ERIAR_MASK_1111, 0x00100006, ERIAR_EXGMAC);
+	rtl_eri_write(tp, 0xcc, ERIAR_MASK_1111, 0x00000050, ERIAR_EXGMAC);
+	rtl_eri_write(tp, 0xd0, ERIAR_MASK_1111, 0x07ff0060, ERIAR_EXGMAC);
+	rtl_w1w0_eri(tp, 0x1b0, ERIAR_MASK_0001, 0x10, 0x00, ERIAR_EXGMAC);
+	rtl_w1w0_eri(tp, 0x0d4, ERIAR_MASK_0011, 0x0c00, 0xff00,
 		     ERIAR_EXGMAC);
 
 	RTL_W8(MaxTxPacketSize, EarlySize);
@@ -5078,16 +5071,16 @@ static void rtl_hw_start_8168f(struct rtl8169_private *tp)
 
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
 
@@ -5112,10 +5105,9 @@ static void rtl_hw_start_8168f_1(struct rtl8169_private *tp)
 
 	rtl_hw_start_8168f(tp);
 
-	rtl_ephy_init(ioaddr, e_info_8168f_1, ARRAY_SIZE(e_info_8168f_1));
+	rtl_ephy_init(tp, e_info_8168f_1, ARRAY_SIZE(e_info_8168f_1));
 
-	rtl_w1w0_eri(ioaddr, 0x0d4, ERIAR_MASK_0011, 0x0c00, 0xff00,
-		     ERIAR_EXGMAC);
+	rtl_w1w0_eri(tp, 0x0d4, ERIAR_MASK_0011, 0x0c00, 0xff00, ERIAR_EXGMAC);
 
 	/* Adjust EEE LED frequency */
 	RTL_W8(EEE_LED, RTL_R8(EEE_LED) & ~0x07);
@@ -5123,7 +5115,6 @@ static void rtl_hw_start_8168f_1(struct rtl8169_private *tp)
 
 static void rtl_hw_start_8411(struct rtl8169_private *tp)
 {
-	void __iomem *ioaddr = tp->mmio_addr;
 	static const struct ephy_info e_info_8168f_1[] = {
 		{ 0x06, 0x00c0,	0x0020 },
 		{ 0x0f, 0xffff,	0x5200 },
@@ -5133,10 +5124,9 @@ static void rtl_hw_start_8411(struct rtl8169_private *tp)
 
 	rtl_hw_start_8168f(tp);
 
-	rtl_ephy_init(ioaddr, e_info_8168f_1, ARRAY_SIZE(e_info_8168f_1));
+	rtl_ephy_init(tp, e_info_8168f_1, ARRAY_SIZE(e_info_8168f_1));
 
-	rtl_w1w0_eri(ioaddr, 0x0d4, ERIAR_MASK_0011, 0x0c00, 0x0000,
-		     ERIAR_EXGMAC);
+	rtl_w1w0_eri(tp, 0x0d4, ERIAR_MASK_0011, 0x0c00, 0x0000, ERIAR_EXGMAC);
 }
 
 static void rtl_hw_start_8168g_1(struct rtl8169_private *tp)
@@ -5144,29 +5134,29 @@ static void rtl_hw_start_8168g_1(struct rtl8169_private *tp)
 	void __iomem *ioaddr = tp->mmio_addr;
 	struct pci_dev *pdev = tp->pci_dev;
 
-	rtl_eri_write(ioaddr, 0xc8, ERIAR_MASK_0101, 0x080002, ERIAR_EXGMAC);
-	rtl_eri_write(ioaddr, 0xcc, ERIAR_MASK_0001, 0x38, ERIAR_EXGMAC);
-	rtl_eri_write(ioaddr, 0xd0, ERIAR_MASK_0001, 0x48, ERIAR_EXGMAC);
-	rtl_eri_write(ioaddr, 0xe8, ERIAR_MASK_1111, 0x00100006, ERIAR_EXGMAC);
+	rtl_eri_write(tp, 0xc8, ERIAR_MASK_0101, 0x080002, ERIAR_EXGMAC);
+	rtl_eri_write(tp, 0xcc, ERIAR_MASK_0001, 0x38, ERIAR_EXGMAC);
+	rtl_eri_write(tp, 0xd0, ERIAR_MASK_0001, 0x48, ERIAR_EXGMAC);
+	rtl_eri_write(tp, 0xe8, ERIAR_MASK_1111, 0x00100006, ERIAR_EXGMAC);
 
 	rtl_csi_access_enable_1(tp);
 
 	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
 
-	rtl_w1w0_eri(ioaddr, 0xdc, ERIAR_MASK_0001, 0x00, 0x01, ERIAR_EXGMAC);
-	rtl_w1w0_eri(ioaddr, 0xdc, ERIAR_MASK_0001, 0x01, 0x00, ERIAR_EXGMAC);
+	rtl_w1w0_eri(tp, 0xdc, ERIAR_MASK_0001, 0x00, 0x01, ERIAR_EXGMAC);
+	rtl_w1w0_eri(tp, 0xdc, ERIAR_MASK_0001, 0x01, 0x00, ERIAR_EXGMAC);
 
 	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
 	RTL_W32(MISC, RTL_R32(MISC) & ~RXDV_GATED_EN);
 	RTL_W8(MaxTxPacketSize, EarlySize);
 
-	rtl_eri_write(ioaddr, 0xc0, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
-	rtl_eri_write(ioaddr, 0xb8, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
+	rtl_eri_write(tp, 0xc0, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
+	rtl_eri_write(tp, 0xb8, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
 
 	/* Adjust EEE LED frequency */
 	RTL_W8(EEE_LED, RTL_R8(EEE_LED) & ~0x07);
 
-	rtl_w1w0_eri(ioaddr, 0x2fc, ERIAR_MASK_0001, 0x01, 0x02, ERIAR_EXGMAC);
+	rtl_w1w0_eri(tp, 0x2fc, ERIAR_MASK_0001, 0x01, 0x02, ERIAR_EXGMAC);
 }
 
 static void rtl_hw_start_8168(struct net_device *dev)
@@ -5329,7 +5319,7 @@ static void rtl_hw_start_8102e_1(struct rtl8169_private *tp)
 	if ((cfg1 & LEDS0) && (cfg1 & LEDS1))
 		RTL_W8(Config1, cfg1 & ~LEDS0);
 
-	rtl_ephy_init(ioaddr, e_info_8102e_1, ARRAY_SIZE(e_info_8102e_1));
+	rtl_ephy_init(tp, e_info_8102e_1, ARRAY_SIZE(e_info_8102e_1));
 }
 
 static void rtl_hw_start_8102e_2(struct rtl8169_private *tp)
@@ -5349,7 +5339,7 @@ static void rtl_hw_start_8102e_3(struct rtl8169_private *tp)
 {
 	rtl_hw_start_8102e_2(tp);
 
-	rtl_ephy_write(tp->mmio_addr, 0x03, 0xc2f9);
+	rtl_ephy_write(tp, 0x03, 0xc2f9);
 }
 
 static void rtl_hw_start_8105e_1(struct rtl8169_private *tp)
@@ -5375,15 +5365,13 @@ static void rtl_hw_start_8105e_1(struct rtl8169_private *tp)
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
@@ -5402,18 +5390,17 @@ static void rtl_hw_start_8402(struct rtl8169_private *tp)
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
 }
 
 static void rtl_hw_start_8106(struct rtl8169_private *tp)
-- 
1.7.10.4


--1yeeQ81UyVL57Vl7--
