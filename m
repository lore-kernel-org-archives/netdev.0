From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 4/6] r8169: ephy, eri and efuse functions signature changes.
Date: Tue, 10 Jul 2012 00:44:08 +0200
Message-ID: <fdf6fc067aaeb13aba89d1b56aa39d3bf06fde43.1341872752.git.romieu@fr.zoreil.com>
References: <cover.1341872752.git.romieu@fr.zoreil.com>
Cc: David Miller <davem@davemloft.net>,
	Hayes Wang <hayeswang@realtek.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:59233 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752583Ab2GIW4i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 18:56:38 -0400
In-Reply-To: <cover.1341872752.git.romieu@fr.zoreil.com>
In-Reply-To: <cover.1341872752.git.romieu@fr.zoreil.com>
References: <cover.1341872752.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/realtek/r8169.c |  211 ++++++++++++++++------------------
 1 file changed, 100 insertions(+), 111 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 3e07fa6..7c6c4b2 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -1086,8 +1086,9 @@ static int rtl_mdio_read(struct net_device *dev, int phy_id, int location)
 	return rtl_readphy(tp, location);
 }
 
-static void rtl_ephy_write(void __iomem *ioaddr, int reg_addr, int value)
+static void rtl_ephy_write(struct rtl8169_private *tp, int reg_addr, int value)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
 	unsigned int i;
 
 	RTL_W32(EPHYAR, EPHYAR_WRITE_CMD | (value & EPHYAR_DATA_MASK) |
@@ -1100,8 +1101,9 @@ static void rtl_ephy_write(void __iomem *ioaddr, int reg_addr, int value)
 	}
 }
 
-static u16 rtl_ephy_read(void __iomem *ioaddr, int reg_addr)
+static u16 rtl_ephy_read(struct rtl8169_private *tp, int reg_addr)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
 	u16 value = 0xffff;
 	unsigned int i;
 
@@ -1118,9 +1120,10 @@ static u16 rtl_ephy_read(void __iomem *ioaddr, int reg_addr)
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
@@ -1134,8 +1137,9 @@ void rtl_eri_write(void __iomem *ioaddr, int addr, u32 mask, u32 val, int type)
 	}
 }
 
-static u32 rtl_eri_read(void __iomem *ioaddr, int addr, int type)
+static u32 rtl_eri_read(struct rtl8169_private *tp, int addr, int type)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
 	u32 value = ~0x00;
 	unsigned int i;
 
@@ -1152,13 +1156,13 @@ static u32 rtl_eri_read(void __iomem *ioaddr, int addr, int type)
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
@@ -1167,17 +1171,18 @@ struct exgmac_reg {
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
 
@@ -1290,48 +1295,48 @@ static void rtl_link_chg_patch(struct rtl8169_private *tp)
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
@@ -2202,7 +2207,7 @@ static void rtl_phy_write_fw(struct rtl8169_private *tp, struct rtl_fw *rtl_fw)
 			index -= regno;
 			break;
 		case PHY_READ_EFUSE:
-			predata = rtl8168d_efuse_read(tp->mmio_addr, regno);
+			predata = rtl8168d_efuse_read(tp, regno);
 			index++;
 			break;
 		case PHY_CLEAR_READCOUNT:
@@ -2642,7 +2647,6 @@ static void rtl8168d_1_hw_phy_config(struct rtl8169_private *tp)
 		{ 0x1f, 0x0000 },
 		{ 0x0d, 0xf880 }
 	};
-	void __iomem *ioaddr = tp->mmio_addr;
 
 	rtl_writephy_batch(tp, phy_reg_init_0, ARRAY_SIZE(phy_reg_init_0));
 
@@ -2654,7 +2658,7 @@ static void rtl8168d_1_hw_phy_config(struct rtl8169_private *tp)
 	rtl_w1w0_phy(tp, 0x0b, 0x0010, 0x00ef);
 	rtl_w1w0_phy(tp, 0x0c, 0xa200, 0x5d00);
 
-	if (rtl8168d_efuse_read(ioaddr, 0x01) == 0xb1) {
+	if (rtl8168d_efuse_read(tp, 0x01) == 0xb1) {
 		static const struct phy_reg phy_reg_init[] = {
 			{ 0x1f, 0x0002 },
 			{ 0x05, 0x669a },
@@ -2754,11 +2758,10 @@ static void rtl8168d_2_hw_phy_config(struct rtl8169_private *tp)
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
@@ -3026,8 +3029,7 @@ static void rtl8168e_2_hw_phy_config(struct rtl8169_private *tp)
 	rtl_writephy(tp, 0x1f, 0x0000);
 
 	/* EEE setting */
-	rtl_w1w0_eri(tp->mmio_addr, 0x1b0, ERIAR_MASK_1111, 0x0000, 0x0003,
-		     ERIAR_EXGMAC);
+	rtl_w1w0_eri(tp, 0x1b0, ERIAR_MASK_1111, 0x0000, 0x0003, ERIAR_EXGMAC);
 	rtl_writephy(tp, 0x1f, 0x0005);
 	rtl_writephy(tp, 0x05, 0x8b85);
 	rtl_w1w0_phy(tp, 0x06, 0x0000, 0x2000);
@@ -3131,7 +3133,6 @@ static void rtl8168f_2_hw_phy_config(struct rtl8169_private *tp)
 
 static void rtl8411_hw_phy_config(struct rtl8169_private *tp)
 {
-	void __iomem *ioaddr = tp->mmio_addr;
 	static const struct phy_reg phy_reg_init[] = {
 		/* Channel estimation fine tune */
 		{ 0x1f, 0x0003 },
@@ -3205,7 +3206,7 @@ static void rtl8411_hw_phy_config(struct rtl8169_private *tp)
 	rtl_writephy(tp, 0x1f, 0x0000);
 
 	/* eee setting */
-	rtl_w1w0_eri(ioaddr, 0x1b0, ERIAR_MASK_0001, 0x00, 0x03, ERIAR_EXGMAC);
+	rtl_w1w0_eri(tp, 0x1b0, ERIAR_MASK_0001, 0x00, 0x03, ERIAR_EXGMAC);
 	rtl_writephy(tp, 0x1f, 0x0005);
 	rtl_writephy(tp, 0x05, 0x8b85);
 	rtl_w1w0_phy(tp, 0x06, 0x0000, 0x2000);
@@ -3272,8 +3273,6 @@ static void rtl8105e_hw_phy_config(struct rtl8169_private *tp)
 
 static void rtl8402_hw_phy_config(struct rtl8169_private *tp)
 {
-	void __iomem *ioaddr = tp->mmio_addr;
-
 	/* Disable ALDPS before setting firmware */
 	rtl_writephy(tp, 0x1f, 0x0000);
 	rtl_writephy(tp, 0x18, 0x0310);
@@ -3282,7 +3281,7 @@ static void rtl8402_hw_phy_config(struct rtl8169_private *tp)
 	rtl_apply_firmware(tp);
 
 	/* EEE setting */
-	rtl_eri_write(ioaddr, 0x1b0, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
+	rtl_eri_write(tp, 0x1b0, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
 	rtl_writephy(tp, 0x1f, 0x0004);
 	rtl_writephy(tp, 0x10, 0x401f);
 	rtl_writephy(tp, 0x19, 0x7030);
@@ -3291,8 +3290,6 @@ static void rtl8402_hw_phy_config(struct rtl8169_private *tp)
 
 static void rtl8106e_hw_phy_config(struct rtl8169_private *tp)
 {
-	void __iomem *ioaddr = tp->mmio_addr;
-
 	static const struct phy_reg phy_reg_init[] = {
 		{ 0x1f, 0x0004 },
 		{ 0x10, 0xc07f },
@@ -3307,10 +3304,10 @@ static void rtl8106e_hw_phy_config(struct rtl8169_private *tp)
 
 	rtl_apply_firmware(tp);
 
-	rtl_eri_write(ioaddr, 0x1b0, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
+	rtl_eri_write(tp, 0x1b0, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
 	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 
-	rtl_eri_write(ioaddr, 0x1d0, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
+	rtl_eri_write(tp, 0x1d0, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
 }
 
 static void rtl_hw_phy_config(struct net_device *dev)
@@ -3556,7 +3553,7 @@ static void rtl_rar_set(struct rtl8169_private *tp, u8 *addr)
 								low  >> 16 },
 		};
 
-		rtl_write_exgmac_batch(ioaddr, e, ARRAY_SIZE(e));
+		rtl_write_exgmac_batch(tp, e, ARRAY_SIZE(e));
 	}
 
 	RTL_W8(Cfg9346, Cfg9346_Lock);
@@ -3806,7 +3803,7 @@ static void r8168_pll_power_down(struct rtl8169_private *tp)
 
 	if (tp->mac_version == RTL_GIGA_MAC_VER_32 ||
 	    tp->mac_version == RTL_GIGA_MAC_VER_33)
-		rtl_ephy_write(ioaddr, 0x19, 0xff64);
+		rtl_ephy_write(tp, 0x19, 0xff64);
 
 	if (rtl_wol_pll_power_down(tp))
 		return;
@@ -4539,13 +4536,14 @@ struct ephy_info {
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
@@ -4629,7 +4627,6 @@ static void __rtl_hw_start_8168cp(struct rtl8169_private *tp)
 
 static void rtl_hw_start_8168cp_1(struct rtl8169_private *tp)
 {
-	void __iomem *ioaddr = tp->mmio_addr;
 	static const struct ephy_info e_info_8168cp[] = {
 		{ 0x01, 0,	0x0001 },
 		{ 0x02, 0x0800,	0x1000 },
@@ -4640,7 +4637,7 @@ static void rtl_hw_start_8168cp_1(struct rtl8169_private *tp)
 
 	rtl_csi_access_enable_2(tp);
 
-	rtl_ephy_init(ioaddr, e_info_8168cp, ARRAY_SIZE(e_info_8168cp));
+	rtl_ephy_init(tp, e_info_8168cp, ARRAY_SIZE(e_info_8168cp));
 
 	__rtl_hw_start_8168cp(tp);
 }
@@ -4691,14 +4688,13 @@ static void rtl_hw_start_8168c_1(struct rtl8169_private *tp)
 
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
@@ -4706,7 +4702,7 @@ static void rtl_hw_start_8168c_2(struct rtl8169_private *tp)
 
 	rtl_csi_access_enable_2(tp);
 
-	rtl_ephy_init(ioaddr, e_info_8168c_2, ARRAY_SIZE(e_info_8168c_2));
+	rtl_ephy_init(tp, e_info_8168c_2, ARRAY_SIZE(e_info_8168c_2));
 
 	__rtl_hw_start_8168cp(tp);
 }
@@ -4774,8 +4770,8 @@ static void rtl_hw_start_8168d_4(struct rtl8169_private *tp)
 		const struct ephy_info *e = e_info_8168d_4 + i;
 		u16 w;
 
-		w = rtl_ephy_read(ioaddr, e->offset);
-		rtl_ephy_write(ioaddr, 0x03, (w & e->mask) | e->bits);
+		w = rtl_ephy_read(tp, e->offset);
+		rtl_ephy_write(tp, 0x03, (w & e->mask) | e->bits);
 	}
 
 	rtl_enable_clock_request(pdev);
@@ -4803,7 +4799,7 @@ static void rtl_hw_start_8168e_1(struct rtl8169_private *tp)
 
 	rtl_csi_access_enable_2(tp);
 
-	rtl_ephy_init(ioaddr, e_info_8168e_1, ARRAY_SIZE(e_info_8168e_1));
+	rtl_ephy_init(tp, e_info_8168e_1, ARRAY_SIZE(e_info_8168e_1));
 
 	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
 
@@ -4829,19 +4825,18 @@ static void rtl_hw_start_8168e_2(struct rtl8169_private *tp)
 
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
 
@@ -4867,16 +4862,16 @@ static void rtl_hw_start_8168f(struct rtl8169_private *tp)
 
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
 
@@ -4901,10 +4896,9 @@ static void rtl_hw_start_8168f_1(struct rtl8169_private *tp)
 
 	rtl_hw_start_8168f(tp);
 
-	rtl_ephy_init(ioaddr, e_info_8168f_1, ARRAY_SIZE(e_info_8168f_1));
+	rtl_ephy_init(tp, e_info_8168f_1, ARRAY_SIZE(e_info_8168f_1));
 
-	rtl_w1w0_eri(ioaddr, 0x0d4, ERIAR_MASK_0011, 0x0c00, 0xff00,
-		     ERIAR_EXGMAC);
+	rtl_w1w0_eri(tp, 0x0d4, ERIAR_MASK_0011, 0x0c00, 0xff00, ERIAR_EXGMAC);
 
 	/* Adjust EEE LED frequency */
 	RTL_W8(EEE_LED, RTL_R8(EEE_LED) & ~0x07);
@@ -4912,7 +4906,6 @@ static void rtl_hw_start_8168f_1(struct rtl8169_private *tp)
 
 static void rtl_hw_start_8411(struct rtl8169_private *tp)
 {
-	void __iomem *ioaddr = tp->mmio_addr;
 	static const struct ephy_info e_info_8168f_1[] = {
 		{ 0x06, 0x00c0,	0x0020 },
 		{ 0x0f, 0xffff,	0x5200 },
@@ -4922,10 +4915,9 @@ static void rtl_hw_start_8411(struct rtl8169_private *tp)
 
 	rtl_hw_start_8168f(tp);
 
-	rtl_ephy_init(ioaddr, e_info_8168f_1, ARRAY_SIZE(e_info_8168f_1));
+	rtl_ephy_init(tp, e_info_8168f_1, ARRAY_SIZE(e_info_8168f_1));
 
-	rtl_w1w0_eri(ioaddr, 0x0d4, ERIAR_MASK_0011, 0x0c00, 0x0000,
-		     ERIAR_EXGMAC);
+	rtl_w1w0_eri(tp, 0x0d4, ERIAR_MASK_0011, 0x0c00, 0x0000, ERIAR_EXGMAC);
 }
 
 static void rtl_hw_start_8168(struct net_device *dev)
@@ -5083,7 +5075,7 @@ static void rtl_hw_start_8102e_1(struct rtl8169_private *tp)
 	if ((cfg1 & LEDS0) && (cfg1 & LEDS1))
 		RTL_W8(Config1, cfg1 & ~LEDS0);
 
-	rtl_ephy_init(ioaddr, e_info_8102e_1, ARRAY_SIZE(e_info_8102e_1));
+	rtl_ephy_init(tp, e_info_8102e_1, ARRAY_SIZE(e_info_8102e_1));
 }
 
 static void rtl_hw_start_8102e_2(struct rtl8169_private *tp)
@@ -5103,7 +5095,7 @@ static void rtl_hw_start_8102e_3(struct rtl8169_private *tp)
 {
 	rtl_hw_start_8102e_2(tp);
 
-	rtl_ephy_write(tp->mmio_addr, 0x03, 0xc2f9);
+	rtl_ephy_write(tp, 0x03, 0xc2f9);
 }
 
 static void rtl_hw_start_8105e_1(struct rtl8169_private *tp)
@@ -5129,15 +5121,13 @@ static void rtl_hw_start_8105e_1(struct rtl8169_private *tp)
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
@@ -5156,18 +5146,17 @@ static void rtl_hw_start_8402(struct rtl8169_private *tp)
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
