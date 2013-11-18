From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 1/3] Bring _rtl92c_phy_iq_calibrate() in line with the vendor driver function _PHY_IQCalibrate().
Date: Mon, 18 Nov 2013 13:06:55 -0600
Message-ID: <1384801617-22920-2-git-send-email-Larry.Finger@lwfinger.net>
References: <1384801617-22920-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Mark Cave-Ayland <mark.cave-ayland@ilande.co.uk>,
	netdev@vger.kernel.org, Larry Finger <Larry.Finger@lwfinger.net>
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:52678 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752451Ab3KRTHS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 14:07:18 -0500
In-Reply-To: <1384801617-22920-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Cave-Ayland <mark.cave-ayland@ilande.co.uk>

Also fix incorrect initialisation for rtl8192cu.

Signed-of-by: Mark Cave-Ayland <mark.cave-ayland@ilande.co.uk>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c | 39 ++++++++++++++++------
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c        |  2 +-
 2 files changed, 29 insertions(+), 12 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c b/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c
index 0c0e782..9e32ac8 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c
@@ -1147,6 +1147,12 @@ static void _rtl92c_phy_iq_calibrate(struct ieee80211_hw *hw,
 		0x522, 0x550, 0x551, 0x040
 	};
 
+	u32 iqk_bb_reg_92C[9] = {
+		0xc04, 0xc08, 0x874, 0xb68,
+		0xb6c, 0x870, 0x860, 0x864,
+		0x800
+	};
+
 	const u32 retrycount = 2;
 
 	if (t == 0) {
@@ -1157,6 +1163,8 @@ static void _rtl92c_phy_iq_calibrate(struct ieee80211_hw *hw,
 						rtlphy->adda_backup, 16);
 		_rtl92c_phy_save_mac_registers(hw, iqk_mac_reg,
 					       rtlphy->iqk_mac_backup);
+		_rtl92c_phy_save_adda_registers(hw, iqk_bb_reg_92C,
+						rtlphy->iqk_bb_backup, 9);
 	}
 	_rtl92c_phy_path_adda_on(hw, adda_reg, true, is2t);
 	if (t == 0) {
@@ -1167,14 +1175,18 @@ static void _rtl92c_phy_iq_calibrate(struct ieee80211_hw *hw,
 
 	if (!rtlphy->rfpi_enable)
 		_rtl92c_phy_pi_mode_switch(hw, true);
-	if (t == 0) {
-		rtlphy->reg_c04 = rtl_get_bbreg(hw, 0xc04, MASKDWORD);
-		rtlphy->reg_c08 = rtl_get_bbreg(hw, 0xc08, MASKDWORD);
-		rtlphy->reg_874 = rtl_get_bbreg(hw, 0x874, MASKDWORD);
-	}
+
+	rtl_set_bbreg(hw, 0x800, BIT(24), 0x0);
+
 	rtl_set_bbreg(hw, 0xc04, MASKDWORD, 0x03a05600);
 	rtl_set_bbreg(hw, 0xc08, MASKDWORD, 0x000800e4);
 	rtl_set_bbreg(hw, 0x874, MASKDWORD, 0x22204000);
+
+	rtl_set_bbreg(hw, 0x870, BIT(10), 0x1);
+	rtl_set_bbreg(hw, 0x870, BIT(26), 0x1);
+	rtl_set_bbreg(hw, 0x860, BIT(10), 0x0);
+	rtl_set_bbreg(hw, 0x864, BIT(10), 0x0);
+
 	if (is2t) {
 		rtl_set_bbreg(hw, 0x840, MASKDWORD, 0x00010000);
 		rtl_set_bbreg(hw, 0x844, MASKDWORD, 0x00010000);
@@ -1239,13 +1251,9 @@ static void _rtl92c_phy_iq_calibrate(struct ieee80211_hw *hw,
 					0x3FF0000) >> 16;
 		}
 	}
-	rtl_set_bbreg(hw, 0xc04, MASKDWORD, rtlphy->reg_c04);
-	rtl_set_bbreg(hw, 0x874, MASKDWORD, rtlphy->reg_874);
-	rtl_set_bbreg(hw, 0xc08, MASKDWORD, rtlphy->reg_c08);
+
 	rtl_set_bbreg(hw, 0xe28, MASKDWORD, 0);
-	rtl_set_bbreg(hw, 0x840, MASKDWORD, 0x00032ed3);
-	if (is2t)
-		rtl_set_bbreg(hw, 0x844, MASKDWORD, 0x00032ed3);
+
 	if (t != 0) {
 		if (!rtlphy->rfpi_enable)
 			_rtl92c_phy_pi_mode_switch(hw, false);
@@ -1253,6 +1261,15 @@ static void _rtl92c_phy_iq_calibrate(struct ieee80211_hw *hw,
 						  rtlphy->adda_backup, 16);
 		_rtl92c_phy_reload_mac_registers(hw, iqk_mac_reg,
 						 rtlphy->iqk_mac_backup);
+		_rtl92c_phy_reload_adda_registers(hw, iqk_bb_reg_92C,
+						  rtlphy->iqk_bb_backup, 9);
+
+		rtl_set_bbreg(hw, 0x840, MASKDWORD, 0x00032ed3);
+		if (is2t)
+			rtl_set_bbreg(hw, 0x844, MASKDWORD, 0x00032ed3);
+
+		rtl_set_bbreg(hw, 0xe30, MASKDWORD, 0x01008c00);
+		rtl_set_bbreg(hw, 0xe34, MASKDWORD, 0x01008c00);
 	}
 }
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c b/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
index 189ba12..468bf73 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
@@ -1022,7 +1022,7 @@ int rtl92cu_hw_init(struct ieee80211_hw *hw)
 	if (ppsc->rfpwr_state == ERFON) {
 		rtl92c_phy_set_rfpath_switch(hw, 1);
 		if (iqk_initialized) {
-			rtl92c_phy_iq_calibrate(hw, false);
+			rtl92c_phy_iq_calibrate(hw, true);
 		} else {
 			rtl92c_phy_iq_calibrate(hw, false);
 			iqk_initialized = true;
-- 
1.8.4
