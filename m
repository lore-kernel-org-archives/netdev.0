From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v2 net-next 2/2] r8169: support RTL8168G
Date: Thu, 5 Jul 2012 00:04:58 +0200
Message-ID: <20120704220458.GA1621@electric-eye.fr.zoreil.com>
References: <1340966060-2749-1-git-send-email-hayeswang@realtek.com> <1341221002-1522-1-git-send-email-hayeswang@realtek.com> <1341221002-1522-2-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:49374 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755782Ab2GDWQ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2012 18:16:28 -0400
Content-Disposition: inline
In-Reply-To: <1341221002-1522-2-git-send-email-hayeswang@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hayes Wang <hayeswang@realtek.com> :
> Support the new chip RTL8168G.
[...]

Any objection against merging it with the patch below ?

- more BUG() avoidance
- save Joe P. some work
- remove useless parenthesis
- fix r8168g_mdio_write (if (reg_addr == 0x1f) { if (reg_addr == 0) snafu)
  -> Please check this one.
- long declarations before short ones
- avoid unbounded loops
- use a descriptive name for the 0xe8de value in rtl_hw_init_8168g.
  -> Please suggest something better than "PLOP"

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 0cf8626..c37aed9 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -937,14 +937,22 @@ static int r8168dp_check_dash(struct rtl8169_private *tp)
 	return (ocp_read(tp, 0x0f, reg) & 0x00008000) ? 1 : 0;
 }
 
-static void r8168_phy_ocp_write(void __iomem *ioaddr, u32 reg, u32 data)
+static bool rtl_ocp_reg_failure(struct rtl8169_private *tp, u32 reg)
 {
+	if (reg & 0xffff0001) {
+		netif_err(tp, drv, tp->dev, "Invalid ocp reg %x!\n", reg);
+		return true;
+	}
+	return false;
+}
+
+static void r8168_phy_ocp_write(struct rtl8169_private *tp, u32 reg, u32 data)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
 	int i;
 
-	if (reg & 0xffff0001) {
-		printk(KERN_ERR "Invalid ocp reg %x!\n", reg);
+	if (rtl_ocp_reg_failure(tp, reg))
 		return;
-	}
 
 	RTL_W32(GPHY_OCP, OCPAR_FLAG | (reg << 15) | data);
 
@@ -955,15 +963,14 @@ static void r8168_phy_ocp_write(void __iomem *ioaddr, u32 reg, u32 data)
 	}
 }
 
-static u16 r8168_phy_ocp_read(void __iomem *ioaddr, u32 reg)
+static u16 r8168_phy_ocp_read(struct rtl8169_private *tp, u32 reg)
 {
-	int i;
+	void __iomem *ioaddr = tp->mmio_addr;
 	u32 data;
+	int i;
 
-	if (reg & 0xffff0001) {
-		printk(KERN_ERR "Invalid ocp reg %x!\n", reg);
+	if (rtl_ocp_reg_failure(tp, reg))
 		return 0;
-	}
 
 	RTL_W32(GPHY_OCP, reg << 15);
 
@@ -977,20 +984,21 @@ static u16 r8168_phy_ocp_read(void __iomem *ioaddr, u32 reg)
 	return (u16)(data & 0xffff);
 }
 
-static void rtl_w1w0_phy_ocp(void __iomem *ioaddr, int reg_addr, int p, int m)
+static void rtl_w1w0_phy_ocp(struct rtl8169_private *tp, int reg, int p, int m)
 {
 	int val;
 
-	val = r8168_phy_ocp_read(ioaddr, reg_addr);
-	r8168_phy_ocp_write(ioaddr, reg_addr, (val | p) & ~m);
+	val = r8168_phy_ocp_read(tp, reg);
+	r8168_phy_ocp_write(tp, reg, (val | p) & ~m);
 }
 
-static void r8168_mac_ocp_write(void __iomem *ioaddr, u32 reg, u32 data)
+static void r8168_mac_ocp_write(struct rtl8169_private *tp, u32 reg, u32 data)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
 	int i;
 
-	if (reg & 0xffff0001)
-		BUG();
+	if (rtl_ocp_reg_failure(tp, reg))
+		return;
 
 	RTL_W32(OCPDR, OCPAR_FLAG | (reg << 15) | data);
 
@@ -1001,15 +1009,16 @@ static void r8168_mac_ocp_write(void __iomem *ioaddr, u32 reg, u32 data)
 	}
 }
 
-static u16 r8168_mac_ocp_read(void __iomem *ioaddr, u32 reg)
+static u16 r8168_mac_ocp_read(struct rtl8169_private *tp, u32 reg)
 {
-	int i;
+	void __iomem *ioaddr = tp->mmio_addr;
 	u32 data;
+	int i;
 
-	if (reg & 0xffff0001)
-		BUG();
+	if (rtl_ocp_reg_failure(tp, reg))
+		return 0;
 
-	RTL_W32(OCPDR, (reg << 15));
+	RTL_W32(OCPDR, reg << 15);
 
 	for (i = 0; i < 10; i++) {
 		udelay(25);
@@ -1023,39 +1032,32 @@ static u16 r8168_mac_ocp_read(void __iomem *ioaddr, u32 reg)
 
 #define OCP_STD_PHY_BASE	0xa400
 
-static
-void r8168g_mdio_write(struct rtl8169_private *tp, int reg_addr, int value)
+static void r8168g_mdio_write(struct rtl8169_private *tp, int reg, int value)
 {
-	void __iomem *ioaddr = tp->mmio_addr;
-
-	if (reg_addr == 0x1f) {
-		if (reg_addr == 0)
-			tp->ocp_base = OCP_STD_PHY_BASE;
-		else
-			tp->ocp_base = value << 4;
-
+	if (reg == 0x1f) {
+		tp->ocp_base = value ? value << 4 : OCP_STD_PHY_BASE;
 		return;
-	} else if (tp->ocp_base != OCP_STD_PHY_BASE)
-		reg_addr -= 0x10;
+	}
+
+	if (tp->ocp_base != OCP_STD_PHY_BASE)
+		reg -= 0x10;
 
-	r8168_phy_ocp_write(ioaddr, tp->ocp_base + reg_addr * 2, value);
+	r8168_phy_ocp_write(tp, tp->ocp_base + reg * 2, value);
 }
 
 static int r8168g_mdio_read(struct rtl8169_private *tp, int reg_addr)
 {
-	void __iomem *ioaddr = tp->mmio_addr;
-
 	if (tp->ocp_base != OCP_STD_PHY_BASE)
 		reg_addr -= 0x10;
 
-	return r8168_phy_ocp_read(ioaddr, tp->ocp_base + reg_addr * 2);
+	return r8168_phy_ocp_read(tp, tp->ocp_base + reg_addr * 2);
 }
 
 static
 void r8169_mdio_write(struct rtl8169_private *tp, int reg_addr, int value)
 {
-	int i;
 	void __iomem *ioaddr = tp->mmio_addr;
+	int i;
 
 	RTL_W32(PHYAR, 0x80000000 | (reg_addr & 0x1f) << 16 | (value & 0xffff));
 
@@ -1077,8 +1079,8 @@ void r8169_mdio_write(struct rtl8169_private *tp, int reg_addr, int value)
 
 static int r8169_mdio_read(struct rtl8169_private *tp, int reg_addr)
 {
-	int i, value = -1;
 	void __iomem *ioaddr = tp->mmio_addr;
+	int i, value = -1;
 
 	RTL_W32(PHYAR, 0x0 | (reg_addr & 0x1f) << 16);
 
@@ -1129,8 +1131,8 @@ void r8168dp_1_mdio_write(struct rtl8169_private *tp, int reg_addr, int value)
 
 static int r8168dp_1_mdio_read(struct rtl8169_private *tp, int reg_addr)
 {
-	int i;
 	void __iomem *ioaddr = tp->mmio_addr;
+	int i;
 
 	r8168dp_1_mdio_access(ioaddr, reg_addr, OCPDR_READ_CMD);
 
@@ -1159,26 +1161,25 @@ static void r8168dp_2_mdio_stop(void __iomem *ioaddr)
 	RTL_W32(0xd0, RTL_R32(0xd0) | R8168DP_1_MDIO_ACCESS_BIT);
 }
 
-static
-void r8168dp_2_mdio_write(struct rtl8169_private *tp, int reg_addr, int value)
+static void r8168dp_2_mdio_write(struct rtl8169_private *tp, int reg, int value)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
 
 	r8168dp_2_mdio_start(ioaddr);
 
-	r8169_mdio_write(tp, reg_addr, value);
+	r8169_mdio_write(tp, reg, value);
 
 	r8168dp_2_mdio_stop(ioaddr);
 }
 
-static int r8168dp_2_mdio_read(struct rtl8169_private *tp, int reg_addr)
+static int r8168dp_2_mdio_read(struct rtl8169_private *tp, int reg)
 {
-	int value;
 	void __iomem *ioaddr = tp->mmio_addr;
+	int value;
 
 	r8168dp_2_mdio_start(ioaddr);
 
-	value = r8169_mdio_read(tp, reg_addr);
+	value = r8169_mdio_read(tp, reg);
 
 	r8168dp_2_mdio_stop(ioaddr);
 
@@ -3370,49 +3371,51 @@ static void rtl8411_hw_phy_config(struct rtl8169_private *tp)
 
 static void rtl8168g_1_hw_phy_config(struct rtl8169_private *tp)
 {
-	void __iomem *ioaddr = tp->mmio_addr;
 	u32 i;
 	static const u16 mac_ocp_patch[] = {
 		0xe008, 0xe01b, 0xe01d, 0xe01f,
 		0xe021, 0xe023, 0xe025, 0xe027,
 		0x49d2 ,0xf10d, 0x766c, 0x49e2,
 		0xf00a, 0x1ec0, 0x8ee1, 0xc60a,
+
 		0x77c0, 0x4870, 0x9fc0, 0x1ea0,
 		0xc707, 0x8ee1, 0x9d6c, 0xc603,
 		0xbe00, 0xb416, 0x0076, 0xe86c,
 		0xc602, 0xbe00, 0x0000, 0xc602,
+
 		0xbe00, 0x0000, 0xc602, 0xbe00,
 		0x0000, 0xc602, 0xbe00, 0x0000,
 		0xc602, 0xbe00, 0x0000, 0xc602,
 		0xbe00, 0x0000, 0xc602, 0xbe00,
+
 		0x0000, 0x0000, 0x0000, 0x0000
 	};
 
 	/* patch code for GPHY reset */
 	for (i = 0; ARRAY_SIZE(mac_ocp_patch); i++)
-		r8168_mac_ocp_write(ioaddr, 0xf800 + 2*i, mac_ocp_patch[i]);
-	r8168_mac_ocp_write(ioaddr, 0xfc26, 0x8000);
-	r8168_mac_ocp_write(ioaddr, 0xfc28, 0x0075);
+		r8168_mac_ocp_write(tp, 0xf800 + 2*i, mac_ocp_patch[i]);
+	r8168_mac_ocp_write(tp, 0xfc26, 0x8000);
+	r8168_mac_ocp_write(tp, 0xfc28, 0x0075);
 
 	rtl_apply_firmware(tp);
 
-	if (r8168_phy_ocp_read(ioaddr, 0xa460) & 0x0100)
-		rtl_w1w0_phy_ocp(ioaddr, 0xbcc4, 0x0000, 0x8000);
+	if (r8168_phy_ocp_read(tp, 0xa460) & 0x0100)
+		rtl_w1w0_phy_ocp(tp, 0xbcc4, 0x0000, 0x8000);
 	else
-		rtl_w1w0_phy_ocp(ioaddr, 0xbcc4, 0x8000, 0x0000);
+		rtl_w1w0_phy_ocp(tp, 0xbcc4, 0x8000, 0x0000);
 
-	if (r8168_phy_ocp_read(ioaddr, 0xa466) & 0x0100)
-		rtl_w1w0_phy_ocp(ioaddr, 0xc41a, 0x0002, 0x0000);
+	if (r8168_phy_ocp_read(tp, 0xa466) & 0x0100)
+		rtl_w1w0_phy_ocp(tp, 0xc41a, 0x0002, 0x0000);
 	else
-		rtl_w1w0_phy_ocp(ioaddr, 0xbcc4, 0x0000, 0x0002);
+		rtl_w1w0_phy_ocp(tp, 0xbcc4, 0x0000, 0x0002);
 
-	rtl_w1w0_phy_ocp(ioaddr, 0xa442, 0x000c, 0x0000);
-	rtl_w1w0_phy_ocp(ioaddr, 0xa4b2, 0x0004, 0x0000);
+	rtl_w1w0_phy_ocp(tp, 0xa442, 0x000c, 0x0000);
+	rtl_w1w0_phy_ocp(tp, 0xa4b2, 0x0004, 0x0000);
 
-	r8168_phy_ocp_write(ioaddr, 0xa436, 0x8012);
-	rtl_w1w0_phy_ocp(ioaddr, 0xa438, 0x8000, 0x0000);
+	r8168_phy_ocp_write(tp, 0xa436, 0x8012);
+	rtl_w1w0_phy_ocp(tp, 0xa438, 0x8000, 0x0000);
 
-	rtl_w1w0_phy_ocp(ioaddr, 0xc422, 0x4000, 0x2000);
+	rtl_w1w0_phy_ocp(tp, 0xc422, 0x4000, 0x2000);
 }
 
 static void rtl8102e_hw_phy_config(struct rtl8169_private *tp)
@@ -5144,16 +5147,24 @@ static void rtl_hw_start_8168g_1(struct rtl8169_private *tp)
 	rtl_eri_write(ioaddr, 0xcc, ERIAR_MASK_0001, 0x38, ERIAR_EXGMAC);
 	rtl_eri_write(ioaddr, 0xd0, ERIAR_MASK_0001, 0x48, ERIAR_EXGMAC);
 	rtl_eri_write(ioaddr, 0xe8, ERIAR_MASK_1111, 0x00100006, ERIAR_EXGMAC);
+
 	rtl_csi_access_enable_1(tp);
+
 	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
+
 	rtl_w1w0_eri(ioaddr, 0xdc, ERIAR_MASK_0001, 0x00, 0x01, ERIAR_EXGMAC);
 	rtl_w1w0_eri(ioaddr, 0xdc, ERIAR_MASK_0001, 0x01, 0x00, ERIAR_EXGMAC);
+
 	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
 	RTL_W32(MISC, RTL_R32(MISC) & ~RXDV_GATED_EN);
 	RTL_W8(MaxTxPacketSize, EarlySize);
+
 	rtl_eri_write(ioaddr, 0xc0, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
 	rtl_eri_write(ioaddr, 0xb8, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
+
+	/* Adjust EEE LED frequency */
 	RTL_W8(EEE_LED, RTL_R8(EEE_LED) & ~0x07);
+
 	rtl_w1w0_eri(ioaddr, 0x2fc, ERIAR_MASK_0001, 0x01, 0x02, ERIAR_EXGMAC);
 }
 
@@ -6732,33 +6743,56 @@ static unsigned rtl_try_msi(struct rtl8169_private *tp,
 	return msi;
 }
 
+#define	RTL_LOOP_MAX	10000
+
+static void rtl_mcu_wait_list_ready(void __iomem *ioaddr)
+{
+	int i;
+
+	for (i = 0; i < RTL_LOOP_MAX; i++) {
+		if (RTL_R8(MCU) & LINK_LIST_RDY)
+			return;
+		udelay(100);
+	}
+}
+
+#define PLOP		0xe8de
+
 static void __devinit rtl_hw_init_8168g(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
-	u32 tmp_data;
+	u32 data;
+	int i;
 
 	RTL_W32(MISC, RTL_R32(MISC) | RXDV_GATED_EN);
-	while (!(RTL_R32(TxConfig) & TXCFG_EMPTY))
+
+	for (i = 0; i < RTL_LOOP_MAX; i++) {
+		if (RTL_R32(TxConfig) & TXCFG_EMPTY)
+			break;
 		udelay(100);
+	}
 
-	while ((RTL_R8(MCU) & RXTX_EMPTY) != RXTX_EMPTY)
+	for (i = 0; i < RTL_LOOP_MAX; i++) {
+		if ((RTL_R8(MCU) & RXTX_EMPTY) == RXTX_EMPTY)
+			break;
 		udelay(100);
+	}
 
 	RTL_W8(ChipCmd, RTL_R8(ChipCmd) & ~(CmdTxEnb | CmdRxEnb));
 	msleep(1);
 	RTL_W8(MCU, RTL_R8(MCU) & ~NOW_IS_OOB);
 
-	tmp_data = r8168_mac_ocp_read(ioaddr, 0xe8de);
-	tmp_data &= ~(1 << 14);
-	r8168_mac_ocp_write(ioaddr, 0xe8de, tmp_data);
-	while (!(RTL_R8(MCU) & LINK_LIST_RDY))
-		udelay(100);
+	data = r8168_mac_ocp_read(ioaddr, PLOP);
+	data &= ~(1 << 14);
+	r8168_mac_ocp_write(ioaddr, PLOP, data);
 
-	tmp_data = r8168_mac_ocp_read(ioaddr, 0xe8de);
-	tmp_data |= (1 << 15);
-	r8168_mac_ocp_write(ioaddr, 0xe8de, tmp_data);
-	while (!(RTL_R8(MCU) & LINK_LIST_RDY))
-		udelay(100);
+	rtl_mcu_wait_list_ready(ioaddr);
+
+	data = r8168_mac_ocp_read(ioaddr, PLOP);
+	data |= (1 << 15);
+	r8168_mac_ocp_write(ioaddr, PLOP, data);
+
+	rtl_mcu_wait_list_ready(ioaddr);
 }
 
 static void __devinit rtl_hw_initialize(struct rtl8169_private *tp)
