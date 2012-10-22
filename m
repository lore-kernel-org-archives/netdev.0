From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 1/2] r8169: enable ALDPS for power saving
Date: Mon, 22 Oct 2012 16:05:53 +0800
Message-ID: <1350893153-18320-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jean@google.com>, Hayes Wang <hayeswang@realtek.com>
To: <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Enable ALDPS function to save power when link down. Note that the
feature should be set after the other PHY settings. And the firmware
is necessary. Don't enable it without loading the firmware.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 46 +++++++++++++++++++++++++++++++++++-
 1 file changed, 45 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index e7ff886..ba29e4d 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -687,6 +687,7 @@ enum features {
 	RTL_FEATURE_WOL		= (1 << 0),
 	RTL_FEATURE_MSI		= (1 << 1),
 	RTL_FEATURE_GMII	= (1 << 2),
+	RTL_FEATURE_EXTENDED	= (1 << 3),
 };
 
 struct rtl8169_counters {
@@ -2394,8 +2395,10 @@ static void rtl_apply_firmware(struct rtl8169_private *tp)
 	struct rtl_fw *rtl_fw = tp->rtl_fw;
 
 	/* TODO: release firmware once rtl_phy_write_fw signals failures. */
-	if (!IS_ERR_OR_NULL(rtl_fw))
+	if (!IS_ERR_OR_NULL(rtl_fw)) {
 		rtl_phy_write_fw(tp, rtl_fw);
+		tp->features |= RTL_FEATURE_EXTENDED;
+	}
 }
 
 static void rtl_apply_firmware_cond(struct rtl8169_private *tp, u8 reg, u16 val)
@@ -3178,6 +3181,12 @@ static void rtl8168e_2_hw_phy_config(struct rtl8169_private *tp)
 	rtl_w1w0_phy(tp, 0x19, 0x0000, 0x0001);
 	rtl_w1w0_phy(tp, 0x10, 0x0000, 0x0400);
 	rtl_writephy(tp, 0x1f, 0x0000);
+
+	/* ALDPS enable */
+	if (tp->features & RTL_FEATURE_EXTENDED) {
+		rtl_writephy(tp, 0x1f, 0x0000);
+		rtl_w1w0_phy(tp, 0x15, 0x1000, 0x0000);
+	}
 }
 
 static void rtl8168f_hw_phy_config(struct rtl8169_private *tp)
@@ -3250,6 +3259,12 @@ static void rtl8168f_1_hw_phy_config(struct rtl8169_private *tp)
 	rtl_writephy(tp, 0x05, 0x8b85);
 	rtl_w1w0_phy(tp, 0x06, 0x4000, 0x0000);
 	rtl_writephy(tp, 0x1f, 0x0000);
+
+	/* ALDPS enable */
+	if (tp->features & RTL_FEATURE_EXTENDED) {
+		rtl_writephy(tp, 0x1f, 0x0000);
+		rtl_w1w0_phy(tp, 0x15, 0x1000, 0x0000);
+	}
 }
 
 static void rtl8168f_2_hw_phy_config(struct rtl8169_private *tp)
@@ -3257,6 +3272,12 @@ static void rtl8168f_2_hw_phy_config(struct rtl8169_private *tp)
 	rtl_apply_firmware(tp);
 
 	rtl8168f_hw_phy_config(tp);
+
+	/* ALDPS enable */
+	if (tp->features & RTL_FEATURE_EXTENDED) {
+		rtl_writephy(tp, 0x1f, 0x0000);
+		rtl_w1w0_phy(tp, 0x15, 0x1000, 0x0000);
+	}
 }
 
 static void rtl8411_hw_phy_config(struct rtl8169_private *tp)
@@ -3354,6 +3375,12 @@ static void rtl8411_hw_phy_config(struct rtl8169_private *tp)
 	rtl_w1w0_phy(tp, 0x19, 0x0000, 0x0001);
 	rtl_w1w0_phy(tp, 0x10, 0x0000, 0x0400);
 	rtl_writephy(tp, 0x1f, 0x0000);
+
+	/* ALDPS enable */
+	if (tp->features & RTL_FEATURE_EXTENDED) {
+		rtl_writephy(tp, 0x1f, 0x0000);
+		rtl_w1w0_phy(tp, 0x15, 0x1000, 0x0000);
+	}
 }
 
 static void rtl8168g_1_hw_phy_config(struct rtl8169_private *tp)
@@ -3446,6 +3473,11 @@ static void rtl8105e_hw_phy_config(struct rtl8169_private *tp)
 	rtl_apply_firmware(tp);
 
 	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+
+	if (tp->features & RTL_FEATURE_EXTENDED) {
+		rtl_writephy(tp, 0x1f, 0x0000);
+		rtl_writephy(tp, 0x18, 0x8310);
+	}
 }
 
 static void rtl8402_hw_phy_config(struct rtl8169_private *tp)
@@ -3463,6 +3495,11 @@ static void rtl8402_hw_phy_config(struct rtl8169_private *tp)
 	rtl_writephy(tp, 0x10, 0x401f);
 	rtl_writephy(tp, 0x19, 0x7030);
 	rtl_writephy(tp, 0x1f, 0x0000);
+
+	if (tp->features & RTL_FEATURE_EXTENDED) {
+		rtl_writephy(tp, 0x1f, 0x0000);
+		rtl_writephy(tp, 0x18, 0x8310);
+	}
 }
 
 static void rtl8106e_hw_phy_config(struct rtl8169_private *tp)
@@ -3485,6 +3522,11 @@ static void rtl8106e_hw_phy_config(struct rtl8169_private *tp)
 	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 
 	rtl_eri_write(tp, 0x1d0, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
+
+	if (tp->features & RTL_FEATURE_EXTENDED) {
+		rtl_writephy(tp, 0x1f, 0x0000);
+		rtl_writephy(tp, 0x18, 0x8310);
+	}
 }
 
 static void rtl_hw_phy_config(struct net_device *dev)
@@ -6391,6 +6433,8 @@ static void rtl8169_net_suspend(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 
+	tp->features &= ~RTL_FEATURE_EXTENDED;
+
 	if (!netif_running(dev))
 		return;
 
-- 
1.7.11.4
