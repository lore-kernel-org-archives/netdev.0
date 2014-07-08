From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net] r8169: disable L23
Date: Tue, 8 Jul 2014 16:26:10 +0800
Message-ID: <1394712342-15778-6-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<nic_swsd@realtek.com>, Hayes Wang <hayeswang@realtek.com>
To: <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For RTL8411, RTL8111G, RTL8402, RTL8105, and RTL8106, the nic couldn't
leave the power saving mode of L23 for certain situation. This causes
the device lost for the system. Disable the L23 mode to avoid it.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index be425ad..38144ee 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -538,6 +538,7 @@ enum rtl_register_content {
 	MagicPacket	= (1 << 5),	/* Wake up when receives a Magic Packet */
 	LinkUp		= (1 << 4),	/* Wake up when the cable connection is re-established */
 	Jumbo_En0	= (1 << 2),	/* 8168 only. Reserved in the 8168b */
+	Rdy_to_L23	= (1 << 1),	/* L23 Enable */
 	Beacon_en	= (1 << 0),	/* 8168 only. Reserved in the 8168b */
 
 	/* Config4 register */
@@ -4897,6 +4898,21 @@ static void rtl_enable_clock_request(struct pci_dev *pdev)
 				 PCI_EXP_LNKCTL_CLKREQ_EN);
 }
 
+static void rtl_l23_enable(struct rtl8169_private *tp, bool enable)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+	u8 data;
+
+	data = RTL_R8(Config3);
+
+	if (enable)
+		data |= Rdy_to_L23;
+	else
+		data &= ~Rdy_to_L23;
+
+	RTL_W8(Config3, data);
+}
+
 #define R8168_CPCMD_QUIRK_MASK (\
 	EnableBist | \
 	Mac_dbgo_oe | \
@@ -5246,6 +5262,7 @@ static void rtl_hw_start_8411(struct rtl8169_private *tp)
 	};
 
 	rtl_hw_start_8168f(tp);
+	rtl_l23_enable(tp, false);
 
 	rtl_ephy_init(tp, e_info_8168f_1, ARRAY_SIZE(e_info_8168f_1));
 
@@ -5284,6 +5301,8 @@ static void rtl_hw_start_8168g_1(struct rtl8169_private *tp)
 
 	rtl_w1w0_eri(tp, 0x2fc, ERIAR_MASK_0001, 0x01, 0x06, ERIAR_EXGMAC);
 	rtl_w1w0_eri(tp, 0x1b0, ERIAR_MASK_0011, 0x0000, 0x1000, ERIAR_EXGMAC);
+
+	rtl_l23_enable(tp, false);
 }
 
 static void rtl_hw_start_8168g_2(struct rtl8169_private *tp)
@@ -5536,6 +5555,8 @@ static void rtl_hw_start_8105e_1(struct rtl8169_private *tp)
 	RTL_W8(DLLPR, RTL_R8(DLLPR) | PFM_EN);
 
 	rtl_ephy_init(tp, e_info_8105e_1, ARRAY_SIZE(e_info_8105e_1));
+
+	rtl_l23_enable(tp, false);
 }
 
 static void rtl_hw_start_8105e_2(struct rtl8169_private *tp)
@@ -5571,6 +5592,8 @@ static void rtl_hw_start_8402(struct rtl8169_private *tp)
 	rtl_eri_write(tp, 0xc0, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
 	rtl_eri_write(tp, 0xb8, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
 	rtl_w1w0_eri(tp, 0x0d4, ERIAR_MASK_0011, 0x0e00, 0xff00, ERIAR_EXGMAC);
+
+	rtl_l23_enable(tp, false);
 }
 
 static void rtl_hw_start_8106(struct rtl8169_private *tp)
@@ -5583,6 +5606,8 @@ static void rtl_hw_start_8106(struct rtl8169_private *tp)
 	RTL_W32(MISC, (RTL_R32(MISC) | DISABLE_LAN_EN) & ~EARLY_TALLY_EN);
 	RTL_W8(MCU, RTL_R8(MCU) | EN_NDP | EN_OOB_RESET);
 	RTL_W8(DLLPR, RTL_R8(DLLPR) & ~PFM_EN);
+
+	rtl_l23_enable(tp, false);
 }
 
 static void rtl_hw_start_8101(struct net_device *dev)
-- 
1.9.3
