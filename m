From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net 1/3] r8152: fix the issue about U1/U2
Date: Thu, 23 Jul 2015 15:09:05 +0800
Message-ID: <1394712342-15778-149-Taiwan-albertk@realtek.com>
References: <1394712342-15778-148-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:40235 "EHLO
	rtits2.realtek.com.tw" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751942AbbGWHIG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2015 03:08:06 -0400
In-Reply-To: <1394712342-15778-148-Taiwan-albertk@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Disable U1/U2 during initialization.
- Disable lpm when linking is on, and enable it when linking is off.
- Disable U1/U2 when enabling runtime suspend.

It is possible to let hw stop working, if the U1/U2 request occurs
during some situations. The patch is used to avoid it.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 94 ++++++++++++++++++++++++++++---------------------
 1 file changed, 54 insertions(+), 40 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 7f6419e..e3a0110 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -2166,6 +2166,7 @@ static int rtl8153_enable(struct r8152 *tp)
 	if (test_bit(RTL8152_UNPLUG, &tp->flags))
 		return -ENODEV;
 
+	usb_disable_lpm(tp->udev);
 	set_tx_qlen(tp);
 	rtl_set_eee_plus(tp);
 	r8153_set_rx_early_timeout(tp);
@@ -2337,11 +2338,54 @@ static void __rtl_set_wol(struct r8152 *tp, u32 wolopts)
 		device_set_wakeup_enable(&tp->udev->dev, false);
 }
 
+static void r8153_u1u2en(struct r8152 *tp, bool enable)
+{
+	u8 u1u2[8];
+
+	if (enable)
+		memset(u1u2, 0xff, sizeof(u1u2));
+	else
+		memset(u1u2, 0x00, sizeof(u1u2));
+
+	usb_ocp_write(tp, USB_TOLERANCE, BYTE_EN_SIX_BYTES, sizeof(u1u2), u1u2);
+}
+
+static void r8153_u2p3en(struct r8152 *tp, bool enable)
+{
+	u32 ocp_data;
+
+	ocp_data = ocp_read_word(tp, MCU_TYPE_USB, USB_U2P3_CTRL);
+	if (enable && tp->version != RTL_VER_03 && tp->version != RTL_VER_04)
+		ocp_data |= U2P3_ENABLE;
+	else
+		ocp_data &= ~U2P3_ENABLE;
+	ocp_write_word(tp, MCU_TYPE_USB, USB_U2P3_CTRL, ocp_data);
+}
+
+static void r8153_power_cut_en(struct r8152 *tp, bool enable)
+{
+	u32 ocp_data;
+
+	ocp_data = ocp_read_word(tp, MCU_TYPE_USB, USB_POWER_CUT);
+	if (enable)
+		ocp_data |= PWR_EN | PHASE2_EN;
+	else
+		ocp_data &= ~(PWR_EN | PHASE2_EN);
+	ocp_write_word(tp, MCU_TYPE_USB, USB_POWER_CUT, ocp_data);
+
+	ocp_data = ocp_read_word(tp, MCU_TYPE_USB, USB_MISC_0);
+	ocp_data &= ~PCUT_STATUS;
+	ocp_write_word(tp, MCU_TYPE_USB, USB_MISC_0, ocp_data);
+}
+
 static void rtl_runtime_suspend_enable(struct r8152 *tp, bool enable)
 {
 	if (enable) {
 		u32 ocp_data;
 
+		r8153_u1u2en(tp, false);
+		r8153_u2p3en(tp, false);
+
 		__rtl_set_wol(tp, WAKE_ANY);
 
 		ocp_write_byte(tp, MCU_TYPE_PLA, PLA_CRWECR, CRWECR_CONFIG);
@@ -2353,6 +2397,8 @@ static void rtl_runtime_suspend_enable(struct r8152 *tp, bool enable)
 		ocp_write_byte(tp, MCU_TYPE_PLA, PLA_CRWECR, CRWECR_NORAML);
 	} else {
 		__rtl_set_wol(tp, tp->saved_wolopts);
+		r8153_u2p3en(tp, true);
+		r8153_u1u2en(tp, true);
 	}
 }
 
@@ -2599,46 +2645,6 @@ static void r8153_hw_phy_cfg(struct r8152 *tp)
 	set_bit(PHY_RESET, &tp->flags);
 }
 
-static void r8153_u1u2en(struct r8152 *tp, bool enable)
-{
-	u8 u1u2[8];
-
-	if (enable)
-		memset(u1u2, 0xff, sizeof(u1u2));
-	else
-		memset(u1u2, 0x00, sizeof(u1u2));
-
-	usb_ocp_write(tp, USB_TOLERANCE, BYTE_EN_SIX_BYTES, sizeof(u1u2), u1u2);
-}
-
-static void r8153_u2p3en(struct r8152 *tp, bool enable)
-{
-	u32 ocp_data;
-
-	ocp_data = ocp_read_word(tp, MCU_TYPE_USB, USB_U2P3_CTRL);
-	if (enable)
-		ocp_data |= U2P3_ENABLE;
-	else
-		ocp_data &= ~U2P3_ENABLE;
-	ocp_write_word(tp, MCU_TYPE_USB, USB_U2P3_CTRL, ocp_data);
-}
-
-static void r8153_power_cut_en(struct r8152 *tp, bool enable)
-{
-	u32 ocp_data;
-
-	ocp_data = ocp_read_word(tp, MCU_TYPE_USB, USB_POWER_CUT);
-	if (enable)
-		ocp_data |= PWR_EN | PHASE2_EN;
-	else
-		ocp_data &= ~(PWR_EN | PHASE2_EN);
-	ocp_write_word(tp, MCU_TYPE_USB, USB_POWER_CUT, ocp_data);
-
-	ocp_data = ocp_read_word(tp, MCU_TYPE_USB, USB_MISC_0);
-	ocp_data &= ~PCUT_STATUS;
-	ocp_write_word(tp, MCU_TYPE_USB, USB_MISC_0, ocp_data);
-}
-
 static void r8153_first_init(struct r8152 *tp)
 {
 	u32 ocp_data;
@@ -2781,6 +2787,7 @@ static void rtl8153_disable(struct r8152 *tp)
 	r8153_disable_aldps(tp);
 	rtl_disable(tp);
 	r8153_enable_aldps(tp);
+	usb_enable_lpm(tp->udev);
 }
 
 static int rtl8152_set_speed(struct r8152 *tp, u8 autoneg, u16 speed, u8 duplex)
@@ -2901,9 +2908,13 @@ static void rtl8153_up(struct r8152 *tp)
 	if (test_bit(RTL8152_UNPLUG, &tp->flags))
 		return;
 
+	r8153_u1u2en(tp, false);
 	r8153_disable_aldps(tp);
 	r8153_first_init(tp);
 	r8153_enable_aldps(tp);
+	r8153_u2p3en(tp, true);
+	r8153_u1u2en(tp, true);
+	usb_enable_lpm(tp->udev);
 }
 
 static void rtl8153_down(struct r8152 *tp)
@@ -2914,6 +2925,7 @@ static void rtl8153_down(struct r8152 *tp)
 	}
 
 	r8153_u1u2en(tp, false);
+	r8153_u2p3en(tp, false);
 	r8153_power_cut_en(tp, false);
 	r8153_disable_aldps(tp);
 	r8153_enter_oob(tp);
@@ -3252,6 +3264,7 @@ static void r8153_init(struct r8152 *tp)
 		msleep(20);
 	}
 
+	usb_disable_lpm(tp->udev);
 	r8153_u2p3en(tp, false);
 
 	if (tp->version == RTL_VER_04) {
@@ -3319,6 +3332,7 @@ static void r8153_init(struct r8152 *tp)
 	r8153_enable_aldps(tp);
 	r8152b_enable_fc(tp);
 	rtl_tally_reset(tp);
+	r8153_u2p3en(tp, true);
 }
 
 static int rtl8152_suspend(struct usb_interface *intf, pm_message_t message)
-- 
2.4.2
