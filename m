From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Pull request for 'davem-next.r8169' branch
Date: Fri, 15 Jul 2011 00:44:11 +0200
Message-ID: <20110714224411.GA6445@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Hayes Wang <hayeswang@realtek.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:37507 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932392Ab1GNW7G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2011 18:59:06 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please pull from branch 'davem-next.r8169' in repository

git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git davem-next.r8169

to get the changes below.

Patches have been tested with :
- RTL8102e           XID 04a00000 (RTL8102E-VB-GR)
- RTL8102e           XID 14c00000 (RTL8103E-GR)
- RTL8110s           XID 04000000
- RTL8169sb/8110sb   XID 10000000
- RTL8169sc/8110sc   XID 98000000 (RTL8110SC)
- RTL8168evl/8111evl XID 0c900880
- RTL8168b/8111b     XID 18000000
- RTL8168d/8111d     XID 083000c0 (RTL8111D-VB-GR)
- RTL8168d/8111d     XID 081000c0 (RTL8168D-GR)

The series include Hayes's fix for the missed RxConfig register writes
(included in e542a2269f232d61270ceddd42b73a4348dee2bb to avoid a
regression).

The 8110SC is not rock-solid and chipsets (XID 18000000, 083000c0 and
98000000) are sometimes unable to resume from sleep when sent a magic
packet : it seems to happen when the devices do not perform a link
down / up cycle fast enough when suspending. It is not a regression
though.

RTL8168evl has been tested without firmware and with both old and
new format firmwares.

Distance from 'davem-next' (d84e0bd7971eb8357c700151ee4e8e4101ee65fa)
---------------------------------------------------------------------

e542a2269f232d61270ceddd42b73a4348dee2bb
aaa89c08d9ffa3739c93d65d98b73ec2aa2e93a5
d4ed95d796e5126bba51466dc07e287cebc8bd19
70090424e59652c4b2e777b533cc23134b176b83
133ac40ac26a6cba957ad5765892f0531ba6ccee
92fc43b4159b518f5baae57301f26d770b0834c9
4f6b00e5f139d7be3ca8371b769778f94fa549dd

Diffstat
--------

 drivers/net/r8169.c |  392 ++++++++++++++++++++++++++++++++++++++++++--------
 1 files changed, 329 insertions(+), 63 deletions(-)

Shortlog
--------

Hayes Wang (7):
      r8169: adjust some registers.
      r8169: modify the flow of the hw reset.
      r8169: add ERI functions.
      r8169: support RTL8111E-VL.
      r8169: fix wake on lan setting for non-8111E.
      r8169: don't enable rx when shutdown.
      r8169: adjust the RxConfig settings.

Patch
-----

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index ef1a43d..3ddd339 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -41,6 +41,7 @@
 #define FIRMWARE_8168D_2	"rtl_nic/rtl8168d-2.fw"
 #define FIRMWARE_8168E_1	"rtl_nic/rtl8168e-1.fw"
 #define FIRMWARE_8168E_2	"rtl_nic/rtl8168e-2.fw"
+#define FIRMWARE_8168E_3	"rtl_nic/rtl8168e-3.fw"
 #define FIRMWARE_8105E_1	"rtl_nic/rtl8105e-1.fw"
 
 #ifdef RTL8169_DEBUG
@@ -70,8 +71,6 @@ static const int multicast_filter_limit = 32;
 #define MAC_ADDR_LEN	6
 
 #define MAX_READ_REQUEST_SHIFT	12
-#define RX_FIFO_THRESH	7	/* 7 means NO threshold, Rx buffer level before first PCI xfer. */
-#define RX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
 #define TX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
 #define SafeMtu		0x1c20	/* ... actually life sucks beyond ~7k */
 #define InterFrameGap	0x03	/* 3 means InterFrameGap = the shortest one */
@@ -133,6 +132,7 @@ enum mac_version {
 	RTL_GIGA_MAC_VER_31,
 	RTL_GIGA_MAC_VER_32,
 	RTL_GIGA_MAC_VER_33,
+	RTL_GIGA_MAC_VER_34,
 	RTL_GIGA_MAC_NONE   = 0xff,
 };
 
@@ -216,7 +216,9 @@ static const struct {
 	[RTL_GIGA_MAC_VER_32] =
 		_R("RTL8168e/8111e",	RTL_TD_1, FIRMWARE_8168E_1),
 	[RTL_GIGA_MAC_VER_33] =
-		_R("RTL8168e/8111e",	RTL_TD_1, FIRMWARE_8168E_2)
+		_R("RTL8168e/8111e",	RTL_TD_1, FIRMWARE_8168E_2),
+	[RTL_GIGA_MAC_VER_34] =
+		_R("RTL8168evl/8111evl",RTL_TD_1, FIRMWARE_8168E_3)
 };
 #undef _R
 
@@ -270,10 +272,20 @@ enum rtl_registers {
 	TxPoll		= 0x38,
 	IntrMask	= 0x3c,
 	IntrStatus	= 0x3e,
+
 	TxConfig	= 0x40,
-	RxConfig	= 0x44,
+#define	TXCFG_AUTO_FIFO			(1 << 7)	/* 8111e-vl */
+#define	TXCFG_EMPTY			(1 << 11)	/* 8111e-vl */
 
-#define RTL_RX_CONFIG_MASK		0xff7e1880u
+	RxConfig	= 0x44,
+#define	RX128_INT_EN			(1 << 15)	/* 8111c and later */
+#define	RX_MULTI_EN			(1 << 14)	/* 8111c only */
+#define	RXCFG_FIFO_SHIFT		13
+					/* No threshold before first PCI xfer */
+#define	RX_FIFO_THRESH			(7 << RXCFG_FIFO_SHIFT)
+#define	RXCFG_DMA_SHIFT			8
+					/* Unlimited maximum PCI burst. */
+#define	RX_DMA_BURST			(7 << RXCFG_DMA_SHIFT)
 
 	RxMissed	= 0x4c,
 	Cfg9346		= 0x50,
@@ -327,12 +339,13 @@ enum rtl8168_8101_registers {
 #define	EPHYAR_REG_SHIFT		16
 #define	EPHYAR_DATA_MASK		0xffff
 	DLLPR			= 0xd0,
-#define	PM_SWITCH			(1 << 6)
+#define	PFM_EN				(1 << 6)
 	DBG_REG			= 0xd1,
 #define	FIX_NAK_1			(1 << 4)
 #define	FIX_NAK_2			(1 << 3)
 	TWSI			= 0xd2,
 	MCU			= 0xd3,
+#define	NOW_IS_OOB			(1 << 7)
 #define	EN_NDP				(1 << 3)
 #define	EN_OOB_RESET			(1 << 2)
 	EFUSEAR			= 0xdc,
@@ -345,18 +358,22 @@ enum rtl8168_8101_registers {
 };
 
 enum rtl8168_registers {
+	LED_FREQ		= 0x1a,
+	EEE_LED			= 0x1b,
 	ERIDR			= 0x70,
 	ERIAR			= 0x74,
 #define ERIAR_FLAG			0x80000000
 #define ERIAR_WRITE_CMD			0x80000000
 #define ERIAR_READ_CMD			0x00000000
 #define ERIAR_ADDR_BYTE_ALIGN		4
-#define ERIAR_EXGMAC			0
-#define ERIAR_MSIX			1
-#define ERIAR_ASF			2
 #define ERIAR_TYPE_SHIFT		16
-#define ERIAR_BYTEEN			0x0f
-#define ERIAR_BYTEEN_SHIFT		12
+#define ERIAR_EXGMAC			(0x00 << ERIAR_TYPE_SHIFT)
+#define ERIAR_MSIX			(0x01 << ERIAR_TYPE_SHIFT)
+#define ERIAR_ASF			(0x02 << ERIAR_TYPE_SHIFT)
+#define ERIAR_MASK_SHIFT		12
+#define ERIAR_MASK_0001			(0x1 << ERIAR_MASK_SHIFT)
+#define ERIAR_MASK_0011			(0x3 << ERIAR_MASK_SHIFT)
+#define ERIAR_MASK_1111			(0xf << ERIAR_MASK_SHIFT)
 	EPHY_RXER_NUM		= 0x7c,
 	OCPDR			= 0xb0,	/* OCP GPHY access */
 #define OCPDR_WRITE_CMD			0x80000000
@@ -371,6 +388,7 @@ enum rtl8168_registers {
 	RDSAR1			= 0xd0,	/* 8168c only. Undocumented on 8168dp */
 	MISC			= 0xf0,	/* 8168e only. */
 #define TXPLA_RST			(1 << 29)
+#define PWM_EN				(1 << 22)
 };
 
 enum rtl_register_content {
@@ -395,6 +413,7 @@ enum rtl_register_content {
 	RxCRC	= (1 << 19),
 
 	/* ChipCmdBits */
+	StopReq		= 0x80,
 	CmdReset	= 0x10,
 	CmdRxEnb	= 0x08,
 	CmdTxEnb	= 0x04,
@@ -417,10 +436,6 @@ enum rtl_register_content {
 	AcceptMyPhys	= 0x02,
 	AcceptAllPhys	= 0x01,
 
-	/* RxConfigBits */
-	RxCfgFIFOShift	= 13,
-	RxCfgDMAShift	=  8,
-
 	/* TxConfigBits */
 	TxInterFrameGapShift = 24,
 	TxDMAShift = 8,	/* DMA burst value (0-7) is shift this many bits */
@@ -712,9 +727,6 @@ static void rtl8169_down(struct net_device *dev);
 static void rtl8169_rx_clear(struct rtl8169_private *tp);
 static int rtl8169_poll(struct napi_struct *napi, int budget);
 
-static const unsigned int rtl8169_rx_config =
-	(RX_FIFO_THRESH << RxCfgFIFOShift) | (RX_DMA_BURST << RxCfgDMAShift);
-
 static u32 ocp_read(struct rtl8169_private *tp, u8 mask, u16 reg)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
@@ -1035,6 +1047,49 @@ static u32 rtl_csi_read(void __iomem *ioaddr, int addr)
 	return value;
 }
 
+static
+void rtl_eri_write(void __iomem *ioaddr, int addr, u32 mask, u32 val, int type)
+{
+	unsigned int i;
+
+	BUG_ON((addr & 3) || (mask == 0));
+	RTL_W32(ERIDR, val);
+	RTL_W32(ERIAR, ERIAR_WRITE_CMD | type | mask | addr);
+
+	for (i = 0; i < 100; i++) {
+		if (!(RTL_R32(ERIAR) & ERIAR_FLAG))
+			break;
+		udelay(100);
+	}
+}
+
+static u32 rtl_eri_read(void __iomem *ioaddr, int addr, int type)
+{
+	u32 value = ~0x00;
+	unsigned int i;
+
+	RTL_W32(ERIAR, ERIAR_READ_CMD | type | ERIAR_MASK_1111 | addr);
+
+	for (i = 0; i < 100; i++) {
+		if (RTL_R32(ERIAR) & ERIAR_FLAG) {
+			value = RTL_R32(ERIDR);
+			break;
+		}
+		udelay(100);
+	}
+
+	return value;
+}
+
+static void
+rtl_w1w0_eri(void __iomem *ioaddr, int addr, u32 mask, u32 p, u32 m, int type)
+{
+	u32 val;
+
+	val = rtl_eri_read(ioaddr, addr, type);
+	rtl_eri_write(ioaddr, addr, mask, (val & ~m) | p, type);
+}
+
 static u8 rtl8168d_efuse_read(void __iomem *ioaddr, int reg_addr)
 {
 	u8 value = 0xff;
@@ -1060,13 +1115,6 @@ static void rtl8169_irq_mask_and_ack(void __iomem *ioaddr)
 	RTL_W16(IntrStatus, 0xffff);
 }
 
-static void rtl8169_asic_down(void __iomem *ioaddr)
-{
-	RTL_W8(ChipCmd, 0x00);
-	rtl8169_irq_mask_and_ack(ioaddr);
-	RTL_R16(CPlusCmd);
-}
-
 static unsigned int rtl8169_tbi_reset_pending(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
@@ -1104,6 +1152,39 @@ static void rtl8169_xmii_reset_enable(struct rtl8169_private *tp)
 	rtl_writephy(tp, MII_BMCR, val & 0xffff);
 }
 
+static void rtl_link_chg_patch(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+	struct net_device *dev = tp->dev;
+
+	if (!netif_running(dev))
+		return;
+
+	if (tp->mac_version == RTL_GIGA_MAC_VER_34) {
+		if (RTL_R8(PHYstatus) & _1000bpsF) {
+			rtl_eri_write(ioaddr, 0x1bc, ERIAR_MASK_1111,
+				      0x00000011, ERIAR_EXGMAC);
+			rtl_eri_write(ioaddr, 0x1dc, ERIAR_MASK_1111,
+				      0x00000005, ERIAR_EXGMAC);
+		} else if (RTL_R8(PHYstatus) & _100bps) {
+			rtl_eri_write(ioaddr, 0x1bc, ERIAR_MASK_1111,
+				      0x0000001f, ERIAR_EXGMAC);
+			rtl_eri_write(ioaddr, 0x1dc, ERIAR_MASK_1111,
+				      0x00000005, ERIAR_EXGMAC);
+		} else {
+			rtl_eri_write(ioaddr, 0x1bc, ERIAR_MASK_1111,
+				      0x0000001f, ERIAR_EXGMAC);
+			rtl_eri_write(ioaddr, 0x1dc, ERIAR_MASK_1111,
+				      0x0000003f, ERIAR_EXGMAC);
+		}
+		/* Reset packet filter */
+		rtl_w1w0_eri(ioaddr, 0xdc, ERIAR_MASK_0001, 0x00, 0x01,
+			     ERIAR_EXGMAC);
+		rtl_w1w0_eri(ioaddr, 0xdc, ERIAR_MASK_0001, 0x01, 0x00,
+			     ERIAR_EXGMAC);
+	}
+}
+
 static void __rtl8169_check_link_status(struct net_device *dev,
 					struct rtl8169_private *tp,
 					void __iomem *ioaddr, bool pm)
@@ -1112,6 +1193,7 @@ static void __rtl8169_check_link_status(struct net_device *dev,
 
 	spin_lock_irqsave(&tp->lock, flags);
 	if (tp->link_ok(ioaddr)) {
+		rtl_link_chg_patch(tp);
 		/* This is to cancel a scheduled suspend if there's one. */
 		if (pm)
 			pm_request_resume(&tp->pci_dev->dev);
@@ -1640,6 +1722,7 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp,
 		int mac_version;
 	} mac_info[] = {
 		/* 8168E family. */
+		{ 0x7c800000, 0x2c800000,	RTL_GIGA_MAC_VER_34 },
 		{ 0x7cf00000, 0x2c200000,	RTL_GIGA_MAC_VER_33 },
 		{ 0x7cf00000, 0x2c100000,	RTL_GIGA_MAC_VER_32 },
 		{ 0x7c800000, 0x2c000000,	RTL_GIGA_MAC_VER_33 },
@@ -2617,7 +2700,7 @@ static void rtl8168d_4_hw_phy_config(struct rtl8169_private *tp)
 	rtl_patchphy(tp, 0x0d, 1 << 5);
 }
 
-static void rtl8168e_hw_phy_config(struct rtl8169_private *tp)
+static void rtl8168e_1_hw_phy_config(struct rtl8169_private *tp)
 {
 	static const struct phy_reg phy_reg_init[] = {
 		/* Enable Delay cap */
@@ -2690,6 +2773,91 @@ static void rtl8168e_hw_phy_config(struct rtl8169_private *tp)
 	rtl_writephy(tp, 0x0d, 0x0000);
 }
 
+static void rtl8168e_2_hw_phy_config(struct rtl8169_private *tp)
+{
+	static const struct phy_reg phy_reg_init[] = {
+		/* Enable Delay cap */
+		{ 0x1f, 0x0004 },
+		{ 0x1f, 0x0007 },
+		{ 0x1e, 0x00ac },
+		{ 0x18, 0x0006 },
+		{ 0x1f, 0x0002 },
+		{ 0x1f, 0x0000 },
+		{ 0x1f, 0x0000 },
+
+		/* Channel estimation fine tune */
+		{ 0x1f, 0x0003 },
+		{ 0x09, 0xa20f },
+		{ 0x1f, 0x0000 },
+		{ 0x1f, 0x0000 },
+
+		/* Green Setting */
+		{ 0x1f, 0x0005 },
+		{ 0x05, 0x8b5b },
+		{ 0x06, 0x9222 },
+		{ 0x05, 0x8b6d },
+		{ 0x06, 0x8000 },
+		{ 0x05, 0x8b76 },
+		{ 0x06, 0x8000 },
+		{ 0x1f, 0x0000 }
+	};
+
+	rtl_apply_firmware(tp);
+
+	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+
+	/* For 4-corner performance improve */
+	rtl_writephy(tp, 0x1f, 0x0005);
+	rtl_writephy(tp, 0x05, 0x8b80);
+	rtl_w1w0_phy(tp, 0x17, 0x0006, 0x0000);
+	rtl_writephy(tp, 0x1f, 0x0000);
+
+	/* PHY auto speed down */
+	rtl_writephy(tp, 0x1f, 0x0004);
+	rtl_writephy(tp, 0x1f, 0x0007);
+	rtl_writephy(tp, 0x1e, 0x002d);
+	rtl_w1w0_phy(tp, 0x18, 0x0010, 0x0000);
+	rtl_writephy(tp, 0x1f, 0x0002);
+	rtl_writephy(tp, 0x1f, 0x0000);
+	rtl_w1w0_phy(tp, 0x14, 0x8000, 0x0000);
+
+	/* improve 10M EEE waveform */
+	rtl_writephy(tp, 0x1f, 0x0005);
+	rtl_writephy(tp, 0x05, 0x8b86);
+	rtl_w1w0_phy(tp, 0x06, 0x0001, 0x0000);
+	rtl_writephy(tp, 0x1f, 0x0000);
+
+	/* Improve 2-pair detection performance */
+	rtl_writephy(tp, 0x1f, 0x0005);
+	rtl_writephy(tp, 0x05, 0x8b85);
+	rtl_w1w0_phy(tp, 0x06, 0x4000, 0x0000);
+	rtl_writephy(tp, 0x1f, 0x0000);
+
+	/* EEE setting */
+	rtl_w1w0_eri(tp->mmio_addr, 0x1b0, ERIAR_MASK_1111, 0x0000, 0x0003,
+		     ERIAR_EXGMAC);
+	rtl_writephy(tp, 0x1f, 0x0005);
+	rtl_writephy(tp, 0x05, 0x8b85);
+	rtl_w1w0_phy(tp, 0x06, 0x0000, 0x2000);
+	rtl_writephy(tp, 0x1f, 0x0004);
+	rtl_writephy(tp, 0x1f, 0x0007);
+	rtl_writephy(tp, 0x1e, 0x0020);
+	rtl_w1w0_phy(tp, 0x06, 0x0000, 0x0100);
+	rtl_writephy(tp, 0x1f, 0x0002);
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
+	rtl_writephy(tp, 0x1f, 0x0000);
+}
+
 static void rtl8102e_hw_phy_config(struct rtl8169_private *tp)
 {
 	static const struct phy_reg phy_reg_init[] = {
@@ -2809,7 +2977,10 @@ static void rtl_hw_phy_config(struct net_device *dev)
 		break;
 	case RTL_GIGA_MAC_VER_32:
 	case RTL_GIGA_MAC_VER_33:
-		rtl8168e_hw_phy_config(tp);
+		rtl8168e_1_hw_phy_config(tp);
+		break;
+	case RTL_GIGA_MAC_VER_34:
+		rtl8168e_2_hw_phy_config(tp);
 		break;
 
 	default:
@@ -3219,8 +3390,10 @@ static void r8168_pll_power_down(struct rtl8169_private *tp)
 		rtl_writephy(tp, 0x1f, 0x0000);
 		rtl_writephy(tp, MII_BMCR, 0x0000);
 
-		RTL_W32(RxConfig, RTL_R32(RxConfig) |
-			AcceptBroadcast | AcceptMulticast | AcceptMyPhys);
+		if (tp->mac_version == RTL_GIGA_MAC_VER_32 ||
+		    tp->mac_version == RTL_GIGA_MAC_VER_33)
+			RTL_W32(RxConfig, RTL_R32(RxConfig) | AcceptBroadcast |
+				AcceptMulticast | AcceptMyPhys);
 		return;
 	}
 
@@ -3315,6 +3488,7 @@ static void __devinit rtl_init_pll_power_ops(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_31:
 	case RTL_GIGA_MAC_VER_32:
 	case RTL_GIGA_MAC_VER_33:
+	case RTL_GIGA_MAC_VER_34:
 		ops->down	= r8168_pll_power_down;
 		ops->up		= r8168_pll_power_up;
 		break;
@@ -3326,6 +3500,47 @@ static void __devinit rtl_init_pll_power_ops(struct rtl8169_private *tp)
 	}
 }
 
+static void rtl_init_rxcfg(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
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
+		RTL_W32(RxConfig, RX_FIFO_THRESH | RX_DMA_BURST);
+		break;
+	case RTL_GIGA_MAC_VER_18:
+	case RTL_GIGA_MAC_VER_19:
+	case RTL_GIGA_MAC_VER_20:
+	case RTL_GIGA_MAC_VER_21:
+	case RTL_GIGA_MAC_VER_22:
+	case RTL_GIGA_MAC_VER_23:
+	case RTL_GIGA_MAC_VER_24:
+		RTL_W32(RxConfig, RX128_INT_EN | RX_MULTI_EN | RX_DMA_BURST);
+		break;
+	default:
+		RTL_W32(RxConfig, RX128_INT_EN | RX_DMA_BURST);
+		break;
+	}
+}
+
+static void rtl8169_init_ring_indexes(struct rtl8169_private *tp)
+{
+	tp->dirty_tx = tp->dirty_rx = tp->cur_tx = tp->cur_rx = 0;
+}
+
 static void rtl_hw_reset(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
@@ -3338,8 +3553,10 @@ static void rtl_hw_reset(struct rtl8169_private *tp)
 	for (i = 0; i < 100; i++) {
 		if ((RTL_R8(ChipCmd) & CmdReset) == 0)
 			break;
-		msleep_interruptible(1);
+		udelay(100);
 	}
+
+	rtl8169_init_ring_indexes(tp);
 }
 
 static int __devinit
@@ -3446,6 +3663,11 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (!pci_is_pcie(pdev))
 		netif_info(tp, probe, dev, "not PCI Express\n");
 
+	/* Identify chip attached to board */
+	rtl8169_get_mac_version(tp, dev, cfg->default_ver);
+
+	rtl_init_rxcfg(tp);
+
 	RTL_W16(IntrMask, 0x0000);
 
 	rtl_hw_reset(tp);
@@ -3454,9 +3676,6 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	pci_set_master(pdev);
 
-	/* Identify chip attached to board */
-	rtl8169_get_mac_version(tp, dev, cfg->default_ver);
-
 	/*
 	 * Pretend we are using VLANs; This bypasses a nasty bug where
 	 * Interrupts stop flowing on high load on 8110SCd controllers.
@@ -3721,6 +3940,16 @@ err_pm_runtime_put:
 	goto out;
 }
 
+static void rtl_rx_close(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+	u32 rxcfg = RTL_R32(RxConfig);
+
+	rxcfg &= ~(AcceptErr | AcceptRunt | AcceptBroadcast | AcceptMulticast |
+		   AcceptMyPhys | AcceptAllPhys);
+	RTL_W32(RxConfig, rxcfg);
+}
+
 static void rtl8169_hw_reset(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
@@ -3728,28 +3957,27 @@ static void rtl8169_hw_reset(struct rtl8169_private *tp)
 	/* Disable interrupts */
 	rtl8169_irq_mask_and_ack(ioaddr);
 
+	rtl_rx_close(tp);
+
 	if (tp->mac_version == RTL_GIGA_MAC_VER_27 ||
 	    tp->mac_version == RTL_GIGA_MAC_VER_28 ||
 	    tp->mac_version == RTL_GIGA_MAC_VER_31) {
 		while (RTL_R8(TxPoll) & NPQ)
 			udelay(20);
-
+	} else if (tp->mac_version == RTL_GIGA_MAC_VER_34) {
+		while (!(RTL_R32(TxConfig) & TXCFG_EMPTY))
+			udelay(100);
+	} else {
+		RTL_W8(ChipCmd, RTL_R8(ChipCmd) | StopReq);
+		udelay(100);
 	}
 
-	/* Reset the chipset */
-	RTL_W8(ChipCmd, CmdReset);
-
-	/* PCI commit */
-	RTL_R8(ChipCmd);
+	rtl_hw_reset(tp);
 }
 
 static void rtl_set_rx_tx_config_registers(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
-	u32 cfg = rtl8169_rx_config;
-
-	cfg |= (RTL_R32(RxConfig) & RTL_RX_CONFIG_MASK);
-	RTL_W32(RxConfig, cfg);
 
 	/* Set DMA burst size and Interframe Gap Time */
 	RTL_W32(TxConfig, (TX_DMA_BURST << TxDMAShift) |
@@ -3760,8 +3988,6 @@ static void rtl_hw_start(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 
-	rtl_hw_reset(tp);
-
 	tp->hw_start(dev);
 
 	netif_start_queue(dev);
@@ -3839,6 +4065,8 @@ static void rtl_hw_start_8169(struct net_device *dev)
 	    tp->mac_version == RTL_GIGA_MAC_VER_04)
 		RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
 
+	rtl_init_rxcfg(tp);
+
 	RTL_W8(EarlyTxThres, NoEarlyTx);
 
 	rtl_set_rx_max_size(ioaddr, rx_buf_sz);
@@ -4148,9 +4376,9 @@ static void rtl_hw_start_8168d_4(void __iomem *ioaddr, struct pci_dev *pdev)
 	rtl_enable_clock_request(pdev);
 }
 
-static void rtl_hw_start_8168e(void __iomem *ioaddr, struct pci_dev *pdev)
+static void rtl_hw_start_8168e_1(void __iomem *ioaddr, struct pci_dev *pdev)
 {
-	static const struct ephy_info e_info_8168e[] = {
+	static const struct ephy_info e_info_8168e_1[] = {
 		{ 0x00, 0x0200,	0x0100 },
 		{ 0x00, 0x0000,	0x0004 },
 		{ 0x06, 0x0002,	0x0001 },
@@ -4168,7 +4396,7 @@ static void rtl_hw_start_8168e(void __iomem *ioaddr, struct pci_dev *pdev)
 
 	rtl_csi_access_enable_2(ioaddr);
 
-	rtl_ephy_init(ioaddr, e_info_8168e, ARRAY_SIZE(e_info_8168e));
+	rtl_ephy_init(ioaddr, e_info_8168e_1, ARRAY_SIZE(e_info_8168e_1));
 
 	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
 
@@ -4183,6 +4411,44 @@ static void rtl_hw_start_8168e(void __iomem *ioaddr, struct pci_dev *pdev)
 	RTL_W8(Config5, RTL_R8(Config5) & ~Spi_en);
 }
 
+static void rtl_hw_start_8168e_2(void __iomem *ioaddr, struct pci_dev *pdev)
+{
+	static const struct ephy_info e_info_8168e_2[] = {
+		{ 0x09, 0x0000,	0x0080 },
+		{ 0x19, 0x0000,	0x0224 }
+	};
+
+	rtl_csi_access_enable_1(ioaddr);
+
+	rtl_ephy_init(ioaddr, e_info_8168e_2, ARRAY_SIZE(e_info_8168e_2));
+
+	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
+
+	rtl_eri_write(ioaddr, 0xc0, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
+	rtl_eri_write(ioaddr, 0xb8, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
+	rtl_eri_write(ioaddr, 0xc8, ERIAR_MASK_1111, 0x00100002, ERIAR_EXGMAC);
+	rtl_eri_write(ioaddr, 0xe8, ERIAR_MASK_1111, 0x00100006, ERIAR_EXGMAC);
+	rtl_eri_write(ioaddr, 0xcc, ERIAR_MASK_1111, 0x00000050, ERIAR_EXGMAC);
+	rtl_eri_write(ioaddr, 0xd0, ERIAR_MASK_1111, 0x07ff0060, ERIAR_EXGMAC);
+	rtl_w1w0_eri(ioaddr, 0x1b0, ERIAR_MASK_0001, 0x10, 0x00, ERIAR_EXGMAC);
+	rtl_w1w0_eri(ioaddr, 0x0d4, ERIAR_MASK_0011, 0x0c00, 0xff00,
+		     ERIAR_EXGMAC);
+
+	RTL_W8(MaxTxPacketSize, 0x27);
+
+	rtl_disable_clock_request(pdev);
+
+	RTL_W32(TxConfig, RTL_R32(TxConfig) | TXCFG_AUTO_FIFO);
+	RTL_W8(MCU, RTL_R8(MCU) & ~NOW_IS_OOB);
+
+	/* Adjust EEE LED frequency */
+	RTL_W8(EEE_LED, RTL_R8(EEE_LED) & ~0x07);
+
+	RTL_W8(DLLPR, RTL_R8(DLLPR) | PFM_EN);
+	RTL_W32(MISC, RTL_R32(MISC) | PWM_EN);
+	RTL_W8(Config5, RTL_R8(Config5) & ~Spi_en);
+}
+
 static void rtl_hw_start_8168(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -4271,7 +4537,10 @@ static void rtl_hw_start_8168(struct net_device *dev)
 
 	case RTL_GIGA_MAC_VER_32:
 	case RTL_GIGA_MAC_VER_33:
-		rtl_hw_start_8168e(ioaddr, pdev);
+		rtl_hw_start_8168e_1(ioaddr, pdev);
+		break;
+	case RTL_GIGA_MAC_VER_34:
+		rtl_hw_start_8168e_2(ioaddr, pdev);
 		break;
 
 	default:
@@ -4368,7 +4637,7 @@ static void rtl_hw_start_8105e_1(void __iomem *ioaddr, struct pci_dev *pdev)
 	RTL_W32(FuncEvent, RTL_R32(FuncEvent) & ~0x010000);
 
 	RTL_W8(MCU, RTL_R8(MCU) | EN_NDP | EN_OOB_RESET);
-	RTL_W8(DLLPR, RTL_R8(DLLPR) | PM_SWITCH);
+	RTL_W8(DLLPR, RTL_R8(DLLPR) | PFM_EN);
 
 	rtl_ephy_init(ioaddr, e_info_8105e_1, ARRAY_SIZE(e_info_8105e_1));
 }
@@ -4570,11 +4839,6 @@ err_out:
 	return -ENOMEM;
 }
 
-static void rtl8169_init_ring_indexes(struct rtl8169_private *tp)
-{
-	tp->dirty_tx = tp->dirty_rx = tp->cur_tx = tp->cur_rx = 0;
-}
-
 static int rtl8169_init_ring(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -4702,7 +4966,7 @@ static void rtl8169_reset_task(struct work_struct *work)
 
 	rtl8169_tx_clear(tp);
 
-	rtl8169_init_ring_indexes(tp);
+	rtl8169_hw_reset(tp);
 	rtl_hw_start(dev);
 	netif_wake_queue(dev);
 	rtl8169_check_link_status(dev, tp, tp->mmio_addr);
@@ -5116,7 +5380,7 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 		 * the chip, so just exit the loop.
 		 */
 		if (unlikely(!netif_running(dev))) {
-			rtl8169_asic_down(ioaddr);
+			rtl8169_hw_reset(tp);
 			break;
 		}
 
@@ -5239,7 +5503,7 @@ static void rtl8169_down(struct net_device *dev)
 
 	spin_lock_irq(&tp->lock);
 
-	rtl8169_asic_down(ioaddr);
+	rtl8169_hw_reset(tp);
 	/*
 	 * At this point device interrupts can not be enabled in any function,
 	 * as netif_running is not true (rtl8169_interrupt, rtl8169_reset_task,
@@ -5322,8 +5586,7 @@ static void rtl_set_rx_mode(struct net_device *dev)
 
 	spin_lock_irqsave(&tp->lock, flags);
 
-	tmp = rtl8169_rx_config | rx_mode |
-	      (RTL_R32(RxConfig) & RTL_RX_CONFIG_MASK);
+	tmp = RTL_R32(RxConfig) | rx_mode;
 
 	if (tp->mac_version > RTL_GIGA_MAC_VER_06) {
 		u32 data = mc_filter[0];
@@ -5493,13 +5756,16 @@ static void rtl_shutdown(struct pci_dev *pdev)
 
 	spin_lock_irq(&tp->lock);
 
-	rtl8169_asic_down(ioaddr);
+	rtl8169_hw_reset(tp);
 
 	spin_unlock_irq(&tp->lock);
 
 	if (system_state == SYSTEM_POWER_OFF) {
-		/* WoL fails with some 8168 when the receiver is disabled. */
-		if (tp->features & RTL_FEATURE_WOL) {
+		/* WoL fails with 8168b when the receiver is disabled. */
+		if ((tp->mac_version == RTL_GIGA_MAC_VER_11 ||
+		     tp->mac_version == RTL_GIGA_MAC_VER_12 ||
+		     tp->mac_version == RTL_GIGA_MAC_VER_17) &&
+		    (tp->features & RTL_FEATURE_WOL)) {
 			pci_clear_master(pdev);
 
 			RTL_W8(ChipCmd, CmdRxEnb);
-- 
Ueimor
