From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 0/7] Pull request for 'davem-next.r8169' branch
Date: Tue, 17 Apr 2012 12:59:34 +0200
Message-ID: <1334659751.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:37849 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753179Ab2DQLEU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Apr 2012 07:04:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please pull from branch 'davem-next.r8169' in repository

git://violet.fr.zoreil.com/romieu/linux davem-next.r8169

to get the changes below.

Distance from 'davem-next' (ecffe75f934b4e3c5301fe5db278068e0efb0d6b)
---------------------------------------------------------------------

b3d7b2f2f07ff0ab87442f2d499f2860ef59bfaa
5f886e08901adaaaa1c79d1f964035aee6a29370
7e18dca16246b2891239cfc3c6e2dfcea715d353
beb1fe184f673fae83ddd9beca3fe662019ef876
0004299ad41885a0a1fd321715fe7396be17ce35
d387b427c973974dd619a33549c070ac5d0e089f
851e60221926a53344b4227879858bef841b0477

Diffstat
--------

 drivers/net/ethernet/realtek/r8169.c |  697 ++++++++++++++++++++++++++--------
 1 files changed, 538 insertions(+), 159 deletions(-)

Shortlog
--------

Francois Romieu (2):
      r8169: Config1 is read-only on 8168c and later.
      r8169: 8168c and later require bit 0x20 to be set in Config2 for PME signaling.

Hayes Wang (5):
      r8169: modify pll power function
      r8169: add device specific CSI access helpers.
      r8169: support the new RTL8402 chip.
      r8169: adjust some functions of 8111f
      r8169: support the new RTL8411 chip.

Patch
-----

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 71393ea..00628d8 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -44,6 +44,8 @@
 #define FIRMWARE_8168F_1	"rtl_nic/rtl8168f-1.fw"
 #define FIRMWARE_8168F_2	"rtl_nic/rtl8168f-2.fw"
 #define FIRMWARE_8105E_1	"rtl_nic/rtl8105e-1.fw"
+#define FIRMWARE_8402_1		"rtl_nic/rtl8402-1.fw"
+#define FIRMWARE_8411_1		"rtl_nic/rtl8411-1.fw"
 
 #ifdef RTL8169_DEBUG
 #define assert(expr) \
@@ -133,6 +135,8 @@ enum mac_version {
 	RTL_GIGA_MAC_VER_34,
 	RTL_GIGA_MAC_VER_35,
 	RTL_GIGA_MAC_VER_36,
+	RTL_GIGA_MAC_VER_37,
+	RTL_GIGA_MAC_VER_38,
 	RTL_GIGA_MAC_NONE   = 0xff,
 };
 
@@ -245,6 +249,12 @@ static const struct {
 	[RTL_GIGA_MAC_VER_36] =
 		_R("RTL8168f/8111f",	RTL_TD_1, FIRMWARE_8168F_2,
 							JUMBO_9K, false),
+	[RTL_GIGA_MAC_VER_37] =
+		_R("RTL8402",		RTL_TD_1, FIRMWARE_8402_1,
+							JUMBO_1K, true),
+	[RTL_GIGA_MAC_VER_38] =
+		_R("RTL8411",		RTL_TD_1, FIRMWARE_8411_1,
+							JUMBO_9K, false),
 };
 #undef _R
 
@@ -315,6 +325,8 @@ enum rtl_registers {
 	Config0		= 0x51,
 	Config1		= 0x52,
 	Config2		= 0x53,
+#define PME_SIGNAL			(1 << 5)	/* 8168c and later */
+
 	Config3		= 0x54,
 	Config4		= 0x55,
 	Config5		= 0x56,
@@ -355,6 +367,9 @@ enum rtl8168_8101_registers {
 #define	CSIAR_BYTE_ENABLE		0x0f
 #define	CSIAR_BYTE_ENABLE_SHIFT		12
 #define	CSIAR_ADDR_MASK			0x0fff
+#define CSIAR_FUNC_CARD			0x00000000
+#define CSIAR_FUNC_SDIO			0x00010000
+#define CSIAR_FUNC_NIC			0x00020000
 	PMCH			= 0x6f,
 	EPHYAR			= 0x80,
 #define	EPHYAR_FLAG			0x80000000
@@ -716,6 +731,11 @@ struct rtl8169_private {
 		void (*disable)(struct rtl8169_private *);
 	} jumbo_ops;
 
+	struct csi_ops {
+		void (*write)(void __iomem *, int, int);
+		u32 (*read)(void __iomem *, int);
+	} csi_ops;
+
 	int (*set_speed)(struct net_device *, u8 aneg, u16 sp, u8 dpx, u32 adv);
 	int (*get_settings)(struct net_device *, struct ethtool_cmd *);
 	void (*phy_reset_enable)(struct rtl8169_private *tp);
@@ -768,6 +788,8 @@ MODULE_FIRMWARE(FIRMWARE_8168E_3);
 MODULE_FIRMWARE(FIRMWARE_8105E_1);
 MODULE_FIRMWARE(FIRMWARE_8168F_1);
 MODULE_FIRMWARE(FIRMWARE_8168F_2);
+MODULE_FIRMWARE(FIRMWARE_8402_1);
+MODULE_FIRMWARE(FIRMWARE_8411_1);
 
 static void rtl_lock_work(struct rtl8169_private *tp)
 {
@@ -1078,40 +1100,6 @@ static u16 rtl_ephy_read(void __iomem *ioaddr, int reg_addr)
 	return value;
 }
 
-static void rtl_csi_write(void __iomem *ioaddr, int addr, int value)
-{
-	unsigned int i;
-
-	RTL_W32(CSIDR, value);
-	RTL_W32(CSIAR, CSIAR_WRITE_CMD | (addr & CSIAR_ADDR_MASK) |
-		CSIAR_BYTE_ENABLE << CSIAR_BYTE_ENABLE_SHIFT);
-
-	for (i = 0; i < 100; i++) {
-		if (!(RTL_R32(CSIAR) & CSIAR_FLAG))
-			break;
-		udelay(10);
-	}
-}
-
-static u32 rtl_csi_read(void __iomem *ioaddr, int addr)
-{
-	u32 value = ~0x00;
-	unsigned int i;
-
-	RTL_W32(CSIAR, (addr & CSIAR_ADDR_MASK) |
-		CSIAR_BYTE_ENABLE << CSIAR_BYTE_ENABLE_SHIFT);
-
-	for (i = 0; i < 100; i++) {
-		if (RTL_R32(CSIAR) & CSIAR_FLAG) {
-			value = RTL_R32(CSIDR);
-			break;
-		}
-		udelay(10);
-	}
-
-	return value;
-}
-
 static
 void rtl_eri_write(void __iomem *ioaddr, int addr, u32 mask, u32 val, int type)
 {
@@ -1281,7 +1269,8 @@ static void rtl_link_chg_patch(struct rtl8169_private *tp)
 	if (!netif_running(dev))
 		return;
 
-	if (tp->mac_version == RTL_GIGA_MAC_VER_34) {
+	if (tp->mac_version == RTL_GIGA_MAC_VER_34 ||
+	    tp->mac_version == RTL_GIGA_MAC_VER_38) {
 		if (RTL_R8(PHYstatus) & _1000bpsF) {
 			rtl_eri_write(ioaddr, 0x1bc, ERIAR_MASK_1111,
 				      0x00000011, ERIAR_EXGMAC);
@@ -1316,6 +1305,16 @@ static void rtl_link_chg_patch(struct rtl8169_private *tp)
 			rtl_eri_write(ioaddr, 0x1dc, ERIAR_MASK_1111,
 				      0x0000003f, ERIAR_EXGMAC);
 		}
+	} else if (tp->mac_version == RTL_GIGA_MAC_VER_37) {
+		if (RTL_R8(PHYstatus) & _10bps) {
+			rtl_eri_write(ioaddr, 0x1d0, ERIAR_MASK_0011,
+				      0x4d02, ERIAR_EXGMAC);
+			rtl_eri_write(ioaddr, 0x1dc, ERIAR_MASK_0011,
+				      0x0060, ERIAR_EXGMAC);
+		} else {
+			rtl_eri_write(ioaddr, 0x1d0, ERIAR_MASK_0011,
+				      0x0000, ERIAR_EXGMAC);
+		}
 	}
 }
 
@@ -1396,7 +1395,6 @@ static void __rtl8169_set_wol(struct rtl8169_private *tp, u32 wolopts)
 		u16 reg;
 		u8  mask;
 	} cfg[] = {
-		{ WAKE_ANY,   Config1, PMEnable },
 		{ WAKE_PHY,   Config3, LinkUp },
 		{ WAKE_MAGIC, Config3, MagicPacket },
 		{ WAKE_UCAST, Config5, UWF },
@@ -1404,16 +1402,32 @@ static void __rtl8169_set_wol(struct rtl8169_private *tp, u32 wolopts)
 		{ WAKE_MCAST, Config5, MWF },
 		{ WAKE_ANY,   Config5, LanWake }
 	};
+	u8 options;
 
 	RTL_W8(Cfg9346, Cfg9346_Unlock);
 
 	for (i = 0; i < ARRAY_SIZE(cfg); i++) {
-		u8 options = RTL_R8(cfg[i].reg) & ~cfg[i].mask;
+		options = RTL_R8(cfg[i].reg) & ~cfg[i].mask;
 		if (wolopts & cfg[i].opt)
 			options |= cfg[i].mask;
 		RTL_W8(cfg[i].reg, options);
 	}
 
+	switch (tp->mac_version) {
+	case RTL_GIGA_MAC_VER_01 ... RTL_GIGA_MAC_VER_17:
+		options = RTL_R8(Config1) & ~PMEnable;
+		if (wolopts)
+			options |= PMEnable;
+		RTL_W8(Config1, options);
+		break;
+	default:
+		options = RTL_R8(Config2) & ~PME_SIGNAL;
+		if (wolopts)
+			options |= PME_SIGNAL;
+		RTL_W8(Config2, options);
+		break;
+	}
+
 	RTL_W8(Cfg9346, Cfg9346_Lock);
 }
 
@@ -1877,6 +1891,7 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp,
 		int mac_version;
 	} mac_info[] = {
 		/* 8168F family. */
+		{ 0x7c800000, 0x48800000,	RTL_GIGA_MAC_VER_38 },
 		{ 0x7cf00000, 0x48100000,	RTL_GIGA_MAC_VER_36 },
 		{ 0x7cf00000, 0x48000000,	RTL_GIGA_MAC_VER_35 },
 
@@ -1914,6 +1929,7 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp,
 		{ 0x7c800000, 0x30000000,	RTL_GIGA_MAC_VER_11 },
 
 		/* 8101 family. */
+		{ 0x7c800000, 0x44000000,	RTL_GIGA_MAC_VER_37 },
 		{ 0x7cf00000, 0x40b00000,	RTL_GIGA_MAC_VER_30 },
 		{ 0x7cf00000, 0x40a00000,	RTL_GIGA_MAC_VER_30 },
 		{ 0x7cf00000, 0x40900000,	RTL_GIGA_MAC_VER_29 },
@@ -3014,6 +3030,28 @@ static void rtl8168e_2_hw_phy_config(struct rtl8169_private *tp)
 	rtl_writephy(tp, 0x1f, 0x0000);
 }
 
+static void rtl8168f_hw_phy_config(struct rtl8169_private *tp)
+{
+	/* For 4-corner performance improve */
+	rtl_writephy(tp, 0x1f, 0x0005);
+	rtl_writephy(tp, 0x05, 0x8b80);
+	rtl_w1w0_phy(tp, 0x06, 0x0006, 0x0000);
+	rtl_writephy(tp, 0x1f, 0x0000);
+
+	/* PHY auto speed down */
+	rtl_writephy(tp, 0x1f, 0x0007);
+	rtl_writephy(tp, 0x1e, 0x002d);
+	rtl_w1w0_phy(tp, 0x18, 0x0010, 0x0000);
+	rtl_writephy(tp, 0x1f, 0x0000);
+	rtl_w1w0_phy(tp, 0x14, 0x8000, 0x0000);
+
+	/* Improve 10M EEE waveform */
+	rtl_writephy(tp, 0x1f, 0x0005);
+	rtl_writephy(tp, 0x05, 0x8b86);
+	rtl_w1w0_phy(tp, 0x06, 0x0001, 0x0000);
+	rtl_writephy(tp, 0x1f, 0x0000);
+}
+
 static void rtl8168f_1_hw_phy_config(struct rtl8169_private *tp)
 {
 	static const struct phy_reg phy_reg_init[] = {
@@ -3055,24 +3093,7 @@ static void rtl8168f_1_hw_phy_config(struct rtl8169_private *tp)
 
 	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 
-	/* For 4-corner performance improve */
-	rtl_writephy(tp, 0x1f, 0x0005);
-	rtl_writephy(tp, 0x05, 0x8b80);
-	rtl_w1w0_phy(tp, 0x06, 0x0006, 0x0000);
-	rtl_writephy(tp, 0x1f, 0x0000);
-
-	/* PHY auto speed down */
-	rtl_writephy(tp, 0x1f, 0x0007);
-	rtl_writephy(tp, 0x1e, 0x002d);
-	rtl_w1w0_phy(tp, 0x18, 0x0010, 0x0000);
-	rtl_writephy(tp, 0x1f, 0x0000);
-	rtl_w1w0_phy(tp, 0x14, 0x8000, 0x0000);
-
-	/* Improve 10M EEE waveform */
-	rtl_writephy(tp, 0x1f, 0x0005);
-	rtl_writephy(tp, 0x05, 0x8b86);
-	rtl_w1w0_phy(tp, 0x06, 0x0001, 0x0000);
-	rtl_writephy(tp, 0x1f, 0x0000);
+	rtl8168f_hw_phy_config(tp);
 
 	/* Improve 2-pair detection performance */
 	rtl_writephy(tp, 0x1f, 0x0005);
@@ -3085,23 +3106,104 @@ static void rtl8168f_2_hw_phy_config(struct rtl8169_private *tp)
 {
 	rtl_apply_firmware(tp);
 
-	/* For 4-corner performance improve */
+	rtl8168f_hw_phy_config(tp);
+}
+
+static void rtl8411_hw_phy_config(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+	static const struct phy_reg phy_reg_init[] = {
+		/* Channel estimation fine tune */
+		{ 0x1f, 0x0003 },
+		{ 0x09, 0xa20f },
+		{ 0x1f, 0x0000 },
+
+		/* Modify green table for giga & fnet */
+		{ 0x1f, 0x0005 },
+		{ 0x05, 0x8b55 },
+		{ 0x06, 0x0000 },
+		{ 0x05, 0x8b5e },
+		{ 0x06, 0x0000 },
+		{ 0x05, 0x8b67 },
+		{ 0x06, 0x0000 },
+		{ 0x05, 0x8b70 },
+		{ 0x06, 0x0000 },
+		{ 0x1f, 0x0000 },
+		{ 0x1f, 0x0007 },
+		{ 0x1e, 0x0078 },
+		{ 0x17, 0x0000 },
+		{ 0x19, 0x00aa },
+		{ 0x1f, 0x0000 },
+
+		/* Modify green table for 10M */
+		{ 0x1f, 0x0005 },
+		{ 0x05, 0x8b79 },
+		{ 0x06, 0xaa00 },
+		{ 0x1f, 0x0000 },
+
+		/* Disable hiimpedance detection (RTCT) */
+		{ 0x1f, 0x0003 },
+		{ 0x01, 0x328a },
+		{ 0x1f, 0x0000 }
+	};
+
+
+	rtl_apply_firmware(tp);
+
+	rtl8168f_hw_phy_config(tp);
+
+	/* Improve 2-pair detection performance */
 	rtl_writephy(tp, 0x1f, 0x0005);
-	rtl_writephy(tp, 0x05, 0x8b80);
-	rtl_w1w0_phy(tp, 0x06, 0x0006, 0x0000);
+	rtl_writephy(tp, 0x05, 0x8b85);
+	rtl_w1w0_phy(tp, 0x06, 0x4000, 0x0000);
 	rtl_writephy(tp, 0x1f, 0x0000);
 
-	/* PHY auto speed down */
-	rtl_writephy(tp, 0x1f, 0x0007);
-	rtl_writephy(tp, 0x1e, 0x002d);
-	rtl_w1w0_phy(tp, 0x18, 0x0010, 0x0000);
+	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+
+	/* Modify green table for giga */
+	rtl_writephy(tp, 0x1f, 0x0005);
+	rtl_writephy(tp, 0x05, 0x8b54);
+	rtl_w1w0_phy(tp, 0x06, 0x0000, 0x0800);
+	rtl_writephy(tp, 0x05, 0x8b5d);
+	rtl_w1w0_phy(tp, 0x06, 0x0000, 0x0800);
+	rtl_writephy(tp, 0x05, 0x8a7c);
+	rtl_w1w0_phy(tp, 0x06, 0x0000, 0x0100);
+	rtl_writephy(tp, 0x05, 0x8a7f);
+	rtl_w1w0_phy(tp, 0x06, 0x0100, 0x0000);
+	rtl_writephy(tp, 0x05, 0x8a82);
+	rtl_w1w0_phy(tp, 0x06, 0x0000, 0x0100);
+	rtl_writephy(tp, 0x05, 0x8a85);
+	rtl_w1w0_phy(tp, 0x06, 0x0000, 0x0100);
+	rtl_writephy(tp, 0x05, 0x8a88);
+	rtl_w1w0_phy(tp, 0x06, 0x0000, 0x0100);
 	rtl_writephy(tp, 0x1f, 0x0000);
-	rtl_w1w0_phy(tp, 0x14, 0x8000, 0x0000);
 
-	/* Improve 10M EEE waveform */
+	/* uc same-seed solution */
 	rtl_writephy(tp, 0x1f, 0x0005);
-	rtl_writephy(tp, 0x05, 0x8b86);
-	rtl_w1w0_phy(tp, 0x06, 0x0001, 0x0000);
+	rtl_writephy(tp, 0x05, 0x8b85);
+	rtl_w1w0_phy(tp, 0x06, 0x8000, 0x0000);
+	rtl_writephy(tp, 0x1f, 0x0000);
+
+	/* eee setting */
+	rtl_w1w0_eri(ioaddr, 0x1b0, ERIAR_MASK_0001, 0x00, 0x03, ERIAR_EXGMAC);
+	rtl_writephy(tp, 0x1f, 0x0005);
+	rtl_writephy(tp, 0x05, 0x8b85);
+	rtl_w1w0_phy(tp, 0x06, 0x0000, 0x2000);
+	rtl_writephy(tp, 0x1f, 0x0004);
+	rtl_writephy(tp, 0x1f, 0x0007);
+	rtl_writephy(tp, 0x1e, 0x0020);
+	rtl_w1w0_phy(tp, 0x15, 0x0000, 0x0100);
+	rtl_writephy(tp, 0x1f, 0x0000);
+	rtl_writephy(tp, 0x0d, 0x0007);
+	rtl_writephy(tp, 0x0e, 0x003c);
+	rtl_writephy(tp, 0x0d, 0x4007);
+	rtl_writephy(tp, 0x0e, 0x0000);
+	rtl_writephy(tp, 0x0d, 0x0000);
+
+	/* Green feature */
+	rtl_writephy(tp, 0x1f, 0x0003);
+	rtl_w1w0_phy(tp, 0x19, 0x0000, 0x0001);
+	rtl_w1w0_phy(tp, 0x10, 0x0000, 0x0400);
 	rtl_writephy(tp, 0x1f, 0x0000);
 }
 
@@ -3148,6 +3250,25 @@ static void rtl8105e_hw_phy_config(struct rtl8169_private *tp)
 	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 }
 
+static void rtl8402_hw_phy_config(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	/* Disable ALDPS before setting firmware */
+	rtl_writephy(tp, 0x1f, 0x0000);
+	rtl_writephy(tp, 0x18, 0x0310);
+	msleep(20);
+
+	rtl_apply_firmware(tp);
+
+	/* EEE setting */
+	rtl_eri_write(ioaddr, 0x1b0, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
+	rtl_writephy(tp, 0x1f, 0x0004);
+	rtl_writephy(tp, 0x10, 0x401f);
+	rtl_writephy(tp, 0x19, 0x7030);
+	rtl_writephy(tp, 0x1f, 0x0000);
+}
+
 static void rtl_hw_phy_config(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -3236,6 +3357,14 @@ static void rtl_hw_phy_config(struct net_device *dev)
 		rtl8168f_2_hw_phy_config(tp);
 		break;
 
+	case RTL_GIGA_MAC_VER_37:
+		rtl8402_hw_phy_config(tp);
+		break;
+
+	case RTL_GIGA_MAC_VER_38:
+		rtl8411_hw_phy_config(tp);
+		break;
+
 	default:
 		break;
 	}
@@ -3473,6 +3602,8 @@ static void rtl_wol_suspend_quirk(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_32:
 	case RTL_GIGA_MAC_VER_33:
 	case RTL_GIGA_MAC_VER_34:
+	case RTL_GIGA_MAC_VER_37:
+	case RTL_GIGA_MAC_VER_38:
 		RTL_W32(RxConfig, RTL_R32(RxConfig) |
 			AcceptBroadcast | AcceptMulticast | AcceptMyPhys);
 		break;
@@ -3508,15 +3639,45 @@ static void r810x_phy_power_up(struct rtl8169_private *tp)
 
 static void r810x_pll_power_down(struct rtl8169_private *tp)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
+
 	if (rtl_wol_pll_power_down(tp))
 		return;
 
 	r810x_phy_power_down(tp);
+
+	switch (tp->mac_version) {
+	case RTL_GIGA_MAC_VER_07:
+	case RTL_GIGA_MAC_VER_08:
+	case RTL_GIGA_MAC_VER_09:
+	case RTL_GIGA_MAC_VER_10:
+	case RTL_GIGA_MAC_VER_13:
+	case RTL_GIGA_MAC_VER_16:
+		break;
+	default:
+		RTL_W8(PMCH, RTL_R8(PMCH) & ~0x80);
+		break;
+	}
 }
 
 static void r810x_pll_power_up(struct rtl8169_private *tp)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
+
 	r810x_phy_power_up(tp);
+
+	switch (tp->mac_version) {
+	case RTL_GIGA_MAC_VER_07:
+	case RTL_GIGA_MAC_VER_08:
+	case RTL_GIGA_MAC_VER_09:
+	case RTL_GIGA_MAC_VER_10:
+	case RTL_GIGA_MAC_VER_13:
+	case RTL_GIGA_MAC_VER_16:
+		break;
+	default:
+		RTL_W8(PMCH, RTL_R8(PMCH) | 0x80);
+		break;
+	}
 }
 
 static void r8168_phy_power_up(struct rtl8169_private *tp)
@@ -3620,13 +3781,6 @@ static void r8168_pll_power_up(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
 
-	if ((tp->mac_version == RTL_GIGA_MAC_VER_27 ||
-	     tp->mac_version == RTL_GIGA_MAC_VER_28 ||
-	     tp->mac_version == RTL_GIGA_MAC_VER_31) &&
-	    r8168dp_check_dash(tp)) {
-		return;
-	}
-
 	switch (tp->mac_version) {
 	case RTL_GIGA_MAC_VER_25:
 	case RTL_GIGA_MAC_VER_26:
@@ -3671,6 +3825,7 @@ static void __devinit rtl_init_pll_power_ops(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_16:
 	case RTL_GIGA_MAC_VER_29:
 	case RTL_GIGA_MAC_VER_30:
+	case RTL_GIGA_MAC_VER_37:
 		ops->down	= r810x_pll_power_down;
 		ops->up		= r810x_pll_power_up;
 		break;
@@ -3695,6 +3850,7 @@ static void __devinit rtl_init_pll_power_ops(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_34:
 	case RTL_GIGA_MAC_VER_35:
 	case RTL_GIGA_MAC_VER_36:
+	case RTL_GIGA_MAC_VER_38:
 		ops->down	= r8168_pll_power_down;
 		ops->up		= r8168_pll_power_up;
 		break;
@@ -3980,7 +4136,9 @@ static void rtl8169_hw_reset(struct rtl8169_private *tp)
 			udelay(20);
 	} else if (tp->mac_version == RTL_GIGA_MAC_VER_34 ||
 	           tp->mac_version == RTL_GIGA_MAC_VER_35 ||
-	           tp->mac_version == RTL_GIGA_MAC_VER_36) {
+	           tp->mac_version == RTL_GIGA_MAC_VER_36 ||
+	           tp->mac_version == RTL_GIGA_MAC_VER_37 ||
+	           tp->mac_version == RTL_GIGA_MAC_VER_38) {
 		RTL_W8(ChipCmd, RTL_R8(ChipCmd) | StopReq);
 		while (!(RTL_R32(TxConfig) & TXCFG_EMPTY))
 			udelay(100);
@@ -4186,22 +4344,141 @@ static void rtl_hw_start_8169(struct net_device *dev)
 	RTL_W16(MultiIntr, RTL_R16(MultiIntr) & 0xF000);
 }
 
-static void rtl_csi_access_enable(void __iomem *ioaddr, u32 bits)
+static void rtl_csi_write(struct rtl8169_private *tp, int addr, int value)
+{
+	if (tp->csi_ops.write)
+		tp->csi_ops.write(tp->mmio_addr, addr, value);
+}
+
+static u32 rtl_csi_read(struct rtl8169_private *tp, int addr)
+{
+	if (tp->csi_ops.read)
+		return tp->csi_ops.read(tp->mmio_addr, addr);
+	else
+		return ~0;
+}
+
+static void rtl_csi_access_enable(struct rtl8169_private *tp, u32 bits)
 {
 	u32 csi;
 
-	csi = rtl_csi_read(ioaddr, 0x070c) & 0x00ffffff;
-	rtl_csi_write(ioaddr, 0x070c, csi | bits);
+	csi = rtl_csi_read(tp, 0x070c) & 0x00ffffff;
+	rtl_csi_write(tp, 0x070c, csi | bits);
+}
+
+static void rtl_csi_access_enable_1(struct rtl8169_private *tp)
+{
+	rtl_csi_access_enable(tp, 0x17000000);
+}
+
+static void rtl_csi_access_enable_2(struct rtl8169_private *tp)
+{
+	rtl_csi_access_enable(tp, 0x27000000);
+}
+
+static void r8169_csi_write(void __iomem *ioaddr, int addr, int value)
+{
+	unsigned int i;
+
+	RTL_W32(CSIDR, value);
+	RTL_W32(CSIAR, CSIAR_WRITE_CMD | (addr & CSIAR_ADDR_MASK) |
+		CSIAR_BYTE_ENABLE << CSIAR_BYTE_ENABLE_SHIFT);
+
+	for (i = 0; i < 100; i++) {
+		if (!(RTL_R32(CSIAR) & CSIAR_FLAG))
+			break;
+		udelay(10);
+	}
+}
+
+static u32 r8169_csi_read(void __iomem *ioaddr, int addr)
+{
+	u32 value = ~0x00;
+	unsigned int i;
+
+	RTL_W32(CSIAR, (addr & CSIAR_ADDR_MASK) |
+		CSIAR_BYTE_ENABLE << CSIAR_BYTE_ENABLE_SHIFT);
+
+	for (i = 0; i < 100; i++) {
+		if (RTL_R32(CSIAR) & CSIAR_FLAG) {
+			value = RTL_R32(CSIDR);
+			break;
+		}
+		udelay(10);
+	}
+
+	return value;
+}
+
+static void r8402_csi_write(void __iomem *ioaddr, int addr, int value)
+{
+	unsigned int i;
+
+	RTL_W32(CSIDR, value);
+	RTL_W32(CSIAR, CSIAR_WRITE_CMD | (addr & CSIAR_ADDR_MASK) |
+		CSIAR_BYTE_ENABLE << CSIAR_BYTE_ENABLE_SHIFT |
+		CSIAR_FUNC_NIC);
+
+	for (i = 0; i < 100; i++) {
+		if (!(RTL_R32(CSIAR) & CSIAR_FLAG))
+			break;
+		udelay(10);
+	}
 }
 
-static void rtl_csi_access_enable_1(void __iomem *ioaddr)
+static u32 r8402_csi_read(void __iomem *ioaddr, int addr)
 {
-	rtl_csi_access_enable(ioaddr, 0x17000000);
+	u32 value = ~0x00;
+	unsigned int i;
+
+	RTL_W32(CSIAR, (addr & CSIAR_ADDR_MASK) | CSIAR_FUNC_NIC |
+		CSIAR_BYTE_ENABLE << CSIAR_BYTE_ENABLE_SHIFT);
+
+	for (i = 0; i < 100; i++) {
+		if (RTL_R32(CSIAR) & CSIAR_FLAG) {
+			value = RTL_R32(CSIDR);
+			break;
+		}
+		udelay(10);
+	}
+
+	return value;
 }
 
-static void rtl_csi_access_enable_2(void __iomem *ioaddr)
+static void __devinit rtl_init_csi_ops(struct rtl8169_private *tp)
 {
-	rtl_csi_access_enable(ioaddr, 0x27000000);
+	struct csi_ops *ops = &tp->csi_ops;
+
+	switch (tp->mac_version) {
+	case RTL_GIGA_MAC_VER_01:
+	case RTL_GIGA_MAC_VER_02:
+	case RTL_GIGA_MAC_VER_03:
+	case RTL_GIGA_MAC_VER_04:
+	case RTL_GIGA_MAC_VER_05:
+	case RTL_GIGA_MAC_VER_06:
+	case RTL_GIGA_MAC_VER_10:
+	case RTL_GIGA_MAC_VER_11:
+	case RTL_GIGA_MAC_VER_12:
+	case RTL_GIGA_MAC_VER_13:
+	case RTL_GIGA_MAC_VER_14:
+	case RTL_GIGA_MAC_VER_15:
+	case RTL_GIGA_MAC_VER_16:
+	case RTL_GIGA_MAC_VER_17:
+		ops->write	= NULL;
+		ops->read	= NULL;
+		break;
+
+	case RTL_GIGA_MAC_VER_37:
+	case RTL_GIGA_MAC_VER_38:
+		ops->write	= r8402_csi_write;
+		ops->read	= r8402_csi_read;
+		break;
+
+	default:
+		ops->write	= r8169_csi_write;
+		ops->read	= r8169_csi_read;
+		break;
+	}
 }
 
 struct ephy_info {
@@ -4258,8 +4535,11 @@ static void rtl_enable_clock_request(struct pci_dev *pdev)
 	PktCntrDisable | \
 	Mac_dbgo_sel)
 
-static void rtl_hw_start_8168bb(void __iomem *ioaddr, struct pci_dev *pdev)
+static void rtl_hw_start_8168bb(struct rtl8169_private *tp)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
+	struct pci_dev *pdev = tp->pci_dev;
+
 	RTL_W8(Config3, RTL_R8(Config3) & ~Beacon_en);
 
 	RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) & ~R8168_CPCMD_QUIRK_MASK);
@@ -4268,17 +4548,22 @@ static void rtl_hw_start_8168bb(void __iomem *ioaddr, struct pci_dev *pdev)
 		(0x5 << MAX_READ_REQUEST_SHIFT) | PCI_EXP_DEVCTL_NOSNOOP_EN);
 }
 
-static void rtl_hw_start_8168bef(void __iomem *ioaddr, struct pci_dev *pdev)
+static void rtl_hw_start_8168bef(struct rtl8169_private *tp)
 {
-	rtl_hw_start_8168bb(ioaddr, pdev);
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	rtl_hw_start_8168bb(tp);
 
 	RTL_W8(MaxTxPacketSize, TxPacketMax);
 
 	RTL_W8(Config4, RTL_R8(Config4) & ~(1 << 0));
 }
 
-static void __rtl_hw_start_8168cp(void __iomem *ioaddr, struct pci_dev *pdev)
+static void __rtl_hw_start_8168cp(struct rtl8169_private *tp)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
+	struct pci_dev *pdev = tp->pci_dev;
+
 	RTL_W8(Config1, RTL_R8(Config1) | Speed_down);
 
 	RTL_W8(Config3, RTL_R8(Config3) & ~Beacon_en);
@@ -4290,8 +4575,9 @@ static void __rtl_hw_start_8168cp(void __iomem *ioaddr, struct pci_dev *pdev)
 	RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) & ~R8168_CPCMD_QUIRK_MASK);
 }
 
-static void rtl_hw_start_8168cp_1(void __iomem *ioaddr, struct pci_dev *pdev)
+static void rtl_hw_start_8168cp_1(struct rtl8169_private *tp)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
 	static const struct ephy_info e_info_8168cp[] = {
 		{ 0x01, 0,	0x0001 },
 		{ 0x02, 0x0800,	0x1000 },
@@ -4300,16 +4586,19 @@ static void rtl_hw_start_8168cp_1(void __iomem *ioaddr, struct pci_dev *pdev)
 		{ 0x07, 0,	0x2000 }
 	};
 
-	rtl_csi_access_enable_2(ioaddr);
+	rtl_csi_access_enable_2(tp);
 
 	rtl_ephy_init(ioaddr, e_info_8168cp, ARRAY_SIZE(e_info_8168cp));
 
-	__rtl_hw_start_8168cp(ioaddr, pdev);
+	__rtl_hw_start_8168cp(tp);
 }
 
-static void rtl_hw_start_8168cp_2(void __iomem *ioaddr, struct pci_dev *pdev)
+static void rtl_hw_start_8168cp_2(struct rtl8169_private *tp)
 {
-	rtl_csi_access_enable_2(ioaddr);
+	void __iomem *ioaddr = tp->mmio_addr;
+	struct pci_dev *pdev = tp->pci_dev;
+
+	rtl_csi_access_enable_2(tp);
 
 	RTL_W8(Config3, RTL_R8(Config3) & ~Beacon_en);
 
@@ -4318,9 +4607,12 @@ static void rtl_hw_start_8168cp_2(void __iomem *ioaddr, struct pci_dev *pdev)
 	RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) & ~R8168_CPCMD_QUIRK_MASK);
 }
 
-static void rtl_hw_start_8168cp_3(void __iomem *ioaddr, struct pci_dev *pdev)
+static void rtl_hw_start_8168cp_3(struct rtl8169_private *tp)
 {
-	rtl_csi_access_enable_2(ioaddr);
+	void __iomem *ioaddr = tp->mmio_addr;
+	struct pci_dev *pdev = tp->pci_dev;
+
+	rtl_csi_access_enable_2(tp);
 
 	RTL_W8(Config3, RTL_R8(Config3) & ~Beacon_en);
 
@@ -4334,52 +4626,57 @@ static void rtl_hw_start_8168cp_3(void __iomem *ioaddr, struct pci_dev *pdev)
 	RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) & ~R8168_CPCMD_QUIRK_MASK);
 }
 
-static void rtl_hw_start_8168c_1(void __iomem *ioaddr, struct pci_dev *pdev)
+static void rtl_hw_start_8168c_1(struct rtl8169_private *tp)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
 	static const struct ephy_info e_info_8168c_1[] = {
 		{ 0x02, 0x0800,	0x1000 },
 		{ 0x03, 0,	0x0002 },
 		{ 0x06, 0x0080,	0x0000 }
 	};
 
-	rtl_csi_access_enable_2(ioaddr);
+	rtl_csi_access_enable_2(tp);
 
 	RTL_W8(DBG_REG, 0x06 | FIX_NAK_1 | FIX_NAK_2);
 
 	rtl_ephy_init(ioaddr, e_info_8168c_1, ARRAY_SIZE(e_info_8168c_1));
 
-	__rtl_hw_start_8168cp(ioaddr, pdev);
+	__rtl_hw_start_8168cp(tp);
 }
 
-static void rtl_hw_start_8168c_2(void __iomem *ioaddr, struct pci_dev *pdev)
+static void rtl_hw_start_8168c_2(struct rtl8169_private *tp)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
 	static const struct ephy_info e_info_8168c_2[] = {
 		{ 0x01, 0,	0x0001 },
 		{ 0x03, 0x0400,	0x0220 }
 	};
 
-	rtl_csi_access_enable_2(ioaddr);
+	rtl_csi_access_enable_2(tp);
 
 	rtl_ephy_init(ioaddr, e_info_8168c_2, ARRAY_SIZE(e_info_8168c_2));
 
-	__rtl_hw_start_8168cp(ioaddr, pdev);
+	__rtl_hw_start_8168cp(tp);
 }
 
-static void rtl_hw_start_8168c_3(void __iomem *ioaddr, struct pci_dev *pdev)
+static void rtl_hw_start_8168c_3(struct rtl8169_private *tp)
 {
-	rtl_hw_start_8168c_2(ioaddr, pdev);
+	rtl_hw_start_8168c_2(tp);
 }
 
-static void rtl_hw_start_8168c_4(void __iomem *ioaddr, struct pci_dev *pdev)
+static void rtl_hw_start_8168c_4(struct rtl8169_private *tp)
 {
-	rtl_csi_access_enable_2(ioaddr);
+	rtl_csi_access_enable_2(tp);
 
-	__rtl_hw_start_8168cp(ioaddr, pdev);
+	__rtl_hw_start_8168cp(tp);
 }
 
-static void rtl_hw_start_8168d(void __iomem *ioaddr, struct pci_dev *pdev)
+static void rtl_hw_start_8168d(struct rtl8169_private *tp)
 {
-	rtl_csi_access_enable_2(ioaddr);
+	void __iomem *ioaddr = tp->mmio_addr;
+	struct pci_dev *pdev = tp->pci_dev;
+
+	rtl_csi_access_enable_2(tp);
 
 	rtl_disable_clock_request(pdev);
 
@@ -4390,9 +4687,12 @@ static void rtl_hw_start_8168d(void __iomem *ioaddr, struct pci_dev *pdev)
 	RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) & ~R8168_CPCMD_QUIRK_MASK);
 }
 
-static void rtl_hw_start_8168dp(void __iomem *ioaddr, struct pci_dev *pdev)
+static void rtl_hw_start_8168dp(struct rtl8169_private *tp)
 {
-	rtl_csi_access_enable_1(ioaddr);
+	void __iomem *ioaddr = tp->mmio_addr;
+	struct pci_dev *pdev = tp->pci_dev;
+
+	rtl_csi_access_enable_1(tp);
 
 	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
 
@@ -4401,8 +4701,10 @@ static void rtl_hw_start_8168dp(void __iomem *ioaddr, struct pci_dev *pdev)
 	rtl_disable_clock_request(pdev);
 }
 
-static void rtl_hw_start_8168d_4(void __iomem *ioaddr, struct pci_dev *pdev)
+static void rtl_hw_start_8168d_4(struct rtl8169_private *tp)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
+	struct pci_dev *pdev = tp->pci_dev;
 	static const struct ephy_info e_info_8168d_4[] = {
 		{ 0x0b, ~0,	0x48 },
 		{ 0x19, 0x20,	0x50 },
@@ -4410,7 +4712,7 @@ static void rtl_hw_start_8168d_4(void __iomem *ioaddr, struct pci_dev *pdev)
 	};
 	int i;
 
-	rtl_csi_access_enable_1(ioaddr);
+	rtl_csi_access_enable_1(tp);
 
 	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
 
@@ -4427,8 +4729,10 @@ static void rtl_hw_start_8168d_4(void __iomem *ioaddr, struct pci_dev *pdev)
 	rtl_enable_clock_request(pdev);
 }
 
-static void rtl_hw_start_8168e_1(void __iomem *ioaddr, struct pci_dev *pdev)
+static void rtl_hw_start_8168e_1(struct rtl8169_private *tp)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
+	struct pci_dev *pdev = tp->pci_dev;
 	static const struct ephy_info e_info_8168e_1[] = {
 		{ 0x00, 0x0200,	0x0100 },
 		{ 0x00, 0x0000,	0x0004 },
@@ -4445,7 +4749,7 @@ static void rtl_hw_start_8168e_1(void __iomem *ioaddr, struct pci_dev *pdev)
 		{ 0x0a, 0x0000,	0x0040 }
 	};
 
-	rtl_csi_access_enable_2(ioaddr);
+	rtl_csi_access_enable_2(tp);
 
 	rtl_ephy_init(ioaddr, e_info_8168e_1, ARRAY_SIZE(e_info_8168e_1));
 
@@ -4462,14 +4766,16 @@ static void rtl_hw_start_8168e_1(void __iomem *ioaddr, struct pci_dev *pdev)
 	RTL_W8(Config5, RTL_R8(Config5) & ~Spi_en);
 }
 
-static void rtl_hw_start_8168e_2(void __iomem *ioaddr, struct pci_dev *pdev)
+static void rtl_hw_start_8168e_2(struct rtl8169_private *tp)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
+	struct pci_dev *pdev = tp->pci_dev;
 	static const struct ephy_info e_info_8168e_2[] = {
 		{ 0x09, 0x0000,	0x0080 },
 		{ 0x19, 0x0000,	0x0224 }
 	};
 
-	rtl_csi_access_enable_1(ioaddr);
+	rtl_csi_access_enable_1(tp);
 
 	rtl_ephy_init(ioaddr, e_info_8168e_2, ARRAY_SIZE(e_info_8168e_2));
 
@@ -4500,18 +4806,12 @@ static void rtl_hw_start_8168e_2(void __iomem *ioaddr, struct pci_dev *pdev)
 	RTL_W8(Config5, RTL_R8(Config5) & ~Spi_en);
 }
 
-static void rtl_hw_start_8168f_1(void __iomem *ioaddr, struct pci_dev *pdev)
+static void rtl_hw_start_8168f(struct rtl8169_private *tp)
 {
-	static const struct ephy_info e_info_8168f_1[] = {
-		{ 0x06, 0x00c0,	0x0020 },
-		{ 0x08, 0x0001,	0x0002 },
-		{ 0x09, 0x0000,	0x0080 },
-		{ 0x19, 0x0000,	0x0224 }
-	};
-
-	rtl_csi_access_enable_1(ioaddr);
+	void __iomem *ioaddr = tp->mmio_addr;
+	struct pci_dev *pdev = tp->pci_dev;
 
-	rtl_ephy_init(ioaddr, e_info_8168f_1, ARRAY_SIZE(e_info_8168f_1));
+	rtl_csi_access_enable_2(tp);
 
 	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
 
@@ -4525,8 +4825,6 @@ static void rtl_hw_start_8168f_1(void __iomem *ioaddr, struct pci_dev *pdev)
 	rtl_w1w0_eri(ioaddr, 0x1d0, ERIAR_MASK_0001, 0x10, 0x00, ERIAR_EXGMAC);
 	rtl_eri_write(ioaddr, 0xcc, ERIAR_MASK_1111, 0x00000050, ERIAR_EXGMAC);
 	rtl_eri_write(ioaddr, 0xd0, ERIAR_MASK_1111, 0x00000060, ERIAR_EXGMAC);
-	rtl_w1w0_eri(ioaddr, 0x0d4, ERIAR_MASK_0011, 0x0c00, 0xff00,
-		     ERIAR_EXGMAC);
 
 	RTL_W8(MaxTxPacketSize, EarlySize);
 
@@ -4534,20 +4832,54 @@ static void rtl_hw_start_8168f_1(void __iomem *ioaddr, struct pci_dev *pdev)
 
 	RTL_W32(TxConfig, RTL_R32(TxConfig) | TXCFG_AUTO_FIFO);
 	RTL_W8(MCU, RTL_R8(MCU) & ~NOW_IS_OOB);
+	RTL_W8(DLLPR, RTL_R8(DLLPR) | PFM_EN);
+	RTL_W32(MISC, RTL_R32(MISC) | PWM_EN);
+	RTL_W8(Config5, RTL_R8(Config5) & ~Spi_en);
+}
+
+static void rtl_hw_start_8168f_1(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+	static const struct ephy_info e_info_8168f_1[] = {
+		{ 0x06, 0x00c0,	0x0020 },
+		{ 0x08, 0x0001,	0x0002 },
+		{ 0x09, 0x0000,	0x0080 },
+		{ 0x19, 0x0000,	0x0224 }
+	};
+
+	rtl_hw_start_8168f(tp);
+
+	rtl_ephy_init(ioaddr, e_info_8168f_1, ARRAY_SIZE(e_info_8168f_1));
+
+	rtl_w1w0_eri(ioaddr, 0x0d4, ERIAR_MASK_0011, 0x0c00, 0xff00,
+		     ERIAR_EXGMAC);
 
 	/* Adjust EEE LED frequency */
 	RTL_W8(EEE_LED, RTL_R8(EEE_LED) & ~0x07);
+}
 
-	RTL_W8(DLLPR, RTL_R8(DLLPR) | PFM_EN);
-	RTL_W32(MISC, RTL_R32(MISC) | PWM_EN);
-	RTL_W8(Config5, RTL_R8(Config5) & ~Spi_en);
+static void rtl_hw_start_8411(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+	static const struct ephy_info e_info_8168f_1[] = {
+		{ 0x06, 0x00c0,	0x0020 },
+		{ 0x0f, 0xffff,	0x5200 },
+		{ 0x1e, 0x0000,	0x4000 },
+		{ 0x19, 0x0000,	0x0224 }
+	};
+
+	rtl_hw_start_8168f(tp);
+
+	rtl_ephy_init(ioaddr, e_info_8168f_1, ARRAY_SIZE(e_info_8168f_1));
+
+	rtl_w1w0_eri(ioaddr, 0x0d4, ERIAR_MASK_0011, 0x0c00, 0x0000,
+		     ERIAR_EXGMAC);
 }
 
 static void rtl_hw_start_8168(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
-	struct pci_dev *pdev = tp->pci_dev;
 
 	RTL_W8(Cfg9346, Cfg9346_Unlock);
 
@@ -4578,67 +4910,71 @@ static void rtl_hw_start_8168(struct net_device *dev)
 
 	switch (tp->mac_version) {
 	case RTL_GIGA_MAC_VER_11:
-		rtl_hw_start_8168bb(ioaddr, pdev);
+		rtl_hw_start_8168bb(tp);
 		break;
 
 	case RTL_GIGA_MAC_VER_12:
 	case RTL_GIGA_MAC_VER_17:
-		rtl_hw_start_8168bef(ioaddr, pdev);
+		rtl_hw_start_8168bef(tp);
 		break;
 
 	case RTL_GIGA_MAC_VER_18:
-		rtl_hw_start_8168cp_1(ioaddr, pdev);
+		rtl_hw_start_8168cp_1(tp);
 		break;
 
 	case RTL_GIGA_MAC_VER_19:
-		rtl_hw_start_8168c_1(ioaddr, pdev);
+		rtl_hw_start_8168c_1(tp);
 		break;
 
 	case RTL_GIGA_MAC_VER_20:
-		rtl_hw_start_8168c_2(ioaddr, pdev);
+		rtl_hw_start_8168c_2(tp);
 		break;
 
 	case RTL_GIGA_MAC_VER_21:
-		rtl_hw_start_8168c_3(ioaddr, pdev);
+		rtl_hw_start_8168c_3(tp);
 		break;
 
 	case RTL_GIGA_MAC_VER_22:
-		rtl_hw_start_8168c_4(ioaddr, pdev);
+		rtl_hw_start_8168c_4(tp);
 		break;
 
 	case RTL_GIGA_MAC_VER_23:
-		rtl_hw_start_8168cp_2(ioaddr, pdev);
+		rtl_hw_start_8168cp_2(tp);
 		break;
 
 	case RTL_GIGA_MAC_VER_24:
-		rtl_hw_start_8168cp_3(ioaddr, pdev);
+		rtl_hw_start_8168cp_3(tp);
 		break;
 
 	case RTL_GIGA_MAC_VER_25:
 	case RTL_GIGA_MAC_VER_26:
 	case RTL_GIGA_MAC_VER_27:
-		rtl_hw_start_8168d(ioaddr, pdev);
+		rtl_hw_start_8168d(tp);
 		break;
 
 	case RTL_GIGA_MAC_VER_28:
-		rtl_hw_start_8168d_4(ioaddr, pdev);
+		rtl_hw_start_8168d_4(tp);
 		break;
 
 	case RTL_GIGA_MAC_VER_31:
-		rtl_hw_start_8168dp(ioaddr, pdev);
+		rtl_hw_start_8168dp(tp);
 		break;
 
 	case RTL_GIGA_MAC_VER_32:
 	case RTL_GIGA_MAC_VER_33:
-		rtl_hw_start_8168e_1(ioaddr, pdev);
+		rtl_hw_start_8168e_1(tp);
 		break;
 	case RTL_GIGA_MAC_VER_34:
-		rtl_hw_start_8168e_2(ioaddr, pdev);
+		rtl_hw_start_8168e_2(tp);
 		break;
 
 	case RTL_GIGA_MAC_VER_35:
 	case RTL_GIGA_MAC_VER_36:
-		rtl_hw_start_8168f_1(ioaddr, pdev);
+		rtl_hw_start_8168f_1(tp);
+		break;
+
+	case RTL_GIGA_MAC_VER_38:
+		rtl_hw_start_8411(tp);
 		break;
 
 	default:
@@ -4665,8 +5001,10 @@ static void rtl_hw_start_8168(struct net_device *dev)
 	PktCntrDisable | \
 	Mac_dbgo_sel)
 
-static void rtl_hw_start_8102e_1(void __iomem *ioaddr, struct pci_dev *pdev)
+static void rtl_hw_start_8102e_1(struct rtl8169_private *tp)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
+	struct pci_dev *pdev = tp->pci_dev;
 	static const struct ephy_info e_info_8102e_1[] = {
 		{ 0x01,	0, 0x6e65 },
 		{ 0x02,	0, 0x091f },
@@ -4679,7 +5017,7 @@ static void rtl_hw_start_8102e_1(void __iomem *ioaddr, struct pci_dev *pdev)
 	};
 	u8 cfg1;
 
-	rtl_csi_access_enable_2(ioaddr);
+	rtl_csi_access_enable_2(tp);
 
 	RTL_W8(DBG_REG, FIX_NAK_1);
 
@@ -4696,9 +5034,12 @@ static void rtl_hw_start_8102e_1(void __iomem *ioaddr, struct pci_dev *pdev)
 	rtl_ephy_init(ioaddr, e_info_8102e_1, ARRAY_SIZE(e_info_8102e_1));
 }
 
-static void rtl_hw_start_8102e_2(void __iomem *ioaddr, struct pci_dev *pdev)
+static void rtl_hw_start_8102e_2(struct rtl8169_private *tp)
 {
-	rtl_csi_access_enable_2(ioaddr);
+	void __iomem *ioaddr = tp->mmio_addr;
+	struct pci_dev *pdev = tp->pci_dev;
+
+	rtl_csi_access_enable_2(tp);
 
 	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
 
@@ -4706,15 +5047,16 @@ static void rtl_hw_start_8102e_2(void __iomem *ioaddr, struct pci_dev *pdev)
 	RTL_W8(Config3, RTL_R8(Config3) & ~Beacon_en);
 }
 
-static void rtl_hw_start_8102e_3(void __iomem *ioaddr, struct pci_dev *pdev)
+static void rtl_hw_start_8102e_3(struct rtl8169_private *tp)
 {
-	rtl_hw_start_8102e_2(ioaddr, pdev);
+	rtl_hw_start_8102e_2(tp);
 
-	rtl_ephy_write(ioaddr, 0x03, 0xc2f9);
+	rtl_ephy_write(tp->mmio_addr, 0x03, 0xc2f9);
 }
 
-static void rtl_hw_start_8105e_1(void __iomem *ioaddr, struct pci_dev *pdev)
+static void rtl_hw_start_8105e_1(struct rtl8169_private *tp)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
 	static const struct ephy_info e_info_8105e_1[] = {
 		{ 0x07,	0, 0x4000 },
 		{ 0x19,	0, 0x0200 },
@@ -4738,12 +5080,44 @@ static void rtl_hw_start_8105e_1(void __iomem *ioaddr, struct pci_dev *pdev)
 	rtl_ephy_init(ioaddr, e_info_8105e_1, ARRAY_SIZE(e_info_8105e_1));
 }
 
-static void rtl_hw_start_8105e_2(void __iomem *ioaddr, struct pci_dev *pdev)
+static void rtl_hw_start_8105e_2(struct rtl8169_private *tp)
 {
-	rtl_hw_start_8105e_1(ioaddr, pdev);
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	rtl_hw_start_8105e_1(tp);
 	rtl_ephy_write(ioaddr, 0x1e, rtl_ephy_read(ioaddr, 0x1e) | 0x8000);
 }
 
+static void rtl_hw_start_8402(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+	static const struct ephy_info e_info_8402[] = {
+		{ 0x19,	0xffff, 0xff64 },
+		{ 0x1e,	0, 0x4000 }
+	};
+
+	rtl_csi_access_enable_2(tp);
+
+	/* Force LAN exit from ASPM if Rx/Tx are not idle */
+	RTL_W32(FuncEvent, RTL_R32(FuncEvent) | 0x002800);
+
+	RTL_W32(TxConfig, RTL_R32(TxConfig) | TXCFG_AUTO_FIFO);
+	RTL_W8(MCU, RTL_R8(MCU) & ~NOW_IS_OOB);
+
+	rtl_ephy_init(ioaddr, e_info_8402, ARRAY_SIZE(e_info_8402));
+
+	rtl_tx_performance_tweak(tp->pci_dev, 0x5 << MAX_READ_REQUEST_SHIFT);
+
+	rtl_eri_write(ioaddr, 0xc8, ERIAR_MASK_1111, 0x00000002, ERIAR_EXGMAC);
+	rtl_eri_write(ioaddr, 0xe8, ERIAR_MASK_1111, 0x00000006, ERIAR_EXGMAC);
+	rtl_w1w0_eri(ioaddr, 0xdc, ERIAR_MASK_0001, 0x00, 0x01, ERIAR_EXGMAC);
+	rtl_w1w0_eri(ioaddr, 0xdc, ERIAR_MASK_0001, 0x01, 0x00, ERIAR_EXGMAC);
+	rtl_eri_write(ioaddr, 0xc0, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
+	rtl_eri_write(ioaddr, 0xb8, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
+	rtl_w1w0_eri(ioaddr, 0x0d4, ERIAR_MASK_0011, 0x0e00, 0xff00,
+		     ERIAR_EXGMAC);
+}
+
 static void rtl_hw_start_8101(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -4767,22 +5141,26 @@ static void rtl_hw_start_8101(struct net_device *dev)
 
 	switch (tp->mac_version) {
 	case RTL_GIGA_MAC_VER_07:
-		rtl_hw_start_8102e_1(ioaddr, pdev);
+		rtl_hw_start_8102e_1(tp);
 		break;
 
 	case RTL_GIGA_MAC_VER_08:
-		rtl_hw_start_8102e_3(ioaddr, pdev);
+		rtl_hw_start_8102e_3(tp);
 		break;
 
 	case RTL_GIGA_MAC_VER_09:
-		rtl_hw_start_8102e_2(ioaddr, pdev);
+		rtl_hw_start_8102e_2(tp);
 		break;
 
 	case RTL_GIGA_MAC_VER_29:
-		rtl_hw_start_8105e_1(ioaddr, pdev);
+		rtl_hw_start_8105e_1(tp);
 		break;
 	case RTL_GIGA_MAC_VER_30:
-		rtl_hw_start_8105e_2(ioaddr, pdev);
+		rtl_hw_start_8105e_2(tp);
+		break;
+
+	case RTL_GIGA_MAC_VER_37:
+		rtl_hw_start_8402(tp);
 		break;
 	}
 
@@ -6179,6 +6557,7 @@ rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	rtl_init_mdio_ops(tp);
 	rtl_init_pll_power_ops(tp);
 	rtl_init_jumbo_ops(tp);
+	rtl_init_csi_ops(tp);
 
 	rtl8169_print_mac_version(tp);
 
-- 
Ueimor

Will code drivers for food.
