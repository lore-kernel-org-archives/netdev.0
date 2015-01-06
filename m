From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 05/11 V2] rtlwifi: rtl8192c-common: Convert driver to use common DM table initialization
Date: Tue,  6 Jan 2015 09:58:06 -0600
Message-ID: <1420559892-12384-6-git-send-email-Larry.Finger@lwfinger.net>
References: <1420559892-12384-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: kvalo@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:42378 "EHLO
	mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756035AbbAFP62 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 10:58:28 -0500
In-Reply-To: <1420559892-12384-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These changes convert both rtl8192ce and rtl8192cu to use the new routine.
Some additional definitions are needed in the core, thus several of the
headers for other drivers are affected, but no other executable code is
changed.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---

V2 - unchanged from V1
---

 drivers/net/wireless/rtlwifi/core.c               |  3 ++
 drivers/net/wireless/rtlwifi/core.h               | 16 +++++++++
 drivers/net/wireless/rtlwifi/rtl8188ee/dm.h       | 16 ---------
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c | 44 ++++-------------------
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.h | 16 ---------
 drivers/net/wireless/rtlwifi/rtl8192de/dm.h       | 16 ---------
 drivers/net/wireless/rtlwifi/rtl8192se/dm.h       |  8 -----
 drivers/net/wireless/rtlwifi/rtl8723ae/dm.c       | 14 ++++----
 drivers/net/wireless/rtlwifi/rtl8723ae/dm.h       | 16 ---------
 drivers/net/wireless/rtlwifi/rtl8723be/dm.h       |  8 -----
 drivers/net/wireless/rtlwifi/rtl8821ae/dm.h       | 16 ---------
 11 files changed, 33 insertions(+), 140 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/core.c b/drivers/net/wireless/rtlwifi/core.c
index 5aa3ab3..eb20316 100644
--- a/drivers/net/wireless/rtlwifi/core.c
+++ b/drivers/net/wireless/rtlwifi/core.c
@@ -1878,6 +1878,7 @@ void rtl_dm_diginit(struct ieee80211_hw *hw, u32 cur_igvalue)
 	struct dig_t *dm_digtable = &rtlpriv->dm_digtable;
 
 	dm_digtable->dig_enable_flag = true;
+	dm_digtable->dig_ext_port_stage = DIG_EXT_PORT_STAGE_MAX;
 	dm_digtable->cur_igvalue = cur_igvalue;
 	dm_digtable->pre_igvalue = 0;
 	dm_digtable->cur_sta_cstate = DIG_STA_DISCONNECT;
@@ -1903,5 +1904,7 @@ void rtl_dm_diginit(struct ieee80211_hw *hw, u32 cur_igvalue)
 	dm_digtable->media_connect_1 = false;
 	rtlpriv->dm.dm_initialgain_enable = true;
 	dm_digtable->bt30_cur_igi = 0x32;
+	dm_digtable->pre_cck_pd_state = CCK_PD_STAGE_MAX;
+	dm_digtable->cur_cck_pd_state = CCK_PD_STAGE_LOWRSSI;
 }
 EXPORT_SYMBOL(rtl_dm_diginit);
diff --git a/drivers/net/wireless/rtlwifi/core.h b/drivers/net/wireless/rtlwifi/core.h
index c0a0317..1cde356 100644
--- a/drivers/net/wireless/rtlwifi/core.h
+++ b/drivers/net/wireless/rtlwifi/core.h
@@ -46,6 +46,22 @@
 #define DM_DIG_BACKOFF_MIN		-4
 #define DM_DIG_BACKOFF_DEFAULT		10
 
+enum cck_packet_detection_threshold {
+	CCK_PD_STAGE_LOWRSSI = 0,
+	CCK_PD_STAGE_HIGHRSSI = 1,
+	CCK_FA_STAGE_LOW = 2,
+	CCK_FA_STAGE_HIGH = 3,
+	CCK_PD_STAGE_MAX = 4,
+};
+
+enum dm_dig_ext_port_alg_e {
+	DIG_EXT_PORT_STAGE_0 = 0,
+	DIG_EXT_PORT_STAGE_1 = 1,
+	DIG_EXT_PORT_STAGE_2 = 2,
+	DIG_EXT_PORT_STAGE_3 = 3,
+	DIG_EXT_PORT_STAGE_MAX = 4,
+};
+
 enum dm_dig_connect_e {
 	DIG_STA_DISCONNECT,
 	DIG_STA_CONNECT,
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/dm.h b/drivers/net/wireless/rtlwifi/rtl8188ee/dm.h
index 6217b7c..51ad3f9 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/dm.h
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/dm.h
@@ -249,14 +249,6 @@ enum tag_dynamic_init_gain_operation_type_definition {
 	DIG_OP_TYPE_MAX
 };
 
-enum tag_cck_packet_detection_threshold_type_definition {
-	CCK_PD_STAGE_LOWRSSI = 0,
-	CCK_PD_STAGE_HIGHRSSI = 1,
-	CCK_FA_STAGE_LOW = 2,
-	CCK_FA_STAGE_HIGH = 3,
-	CCK_PD_STAGE_MAX = 4,
-};
-
 enum dm_1r_cca_e {
 	CCA_1R = 0,
 	CCA_2R = 1,
@@ -275,14 +267,6 @@ enum dm_sw_ant_switch_e {
 	ANS_ANTENNA_MAX = 3,
 };
 
-enum dm_dig_ext_port_alg_e {
-	DIG_EXT_PORT_STAGE_0 = 0,
-	DIG_EXT_PORT_STAGE_1 = 1,
-	DIG_EXT_PORT_STAGE_2 = 2,
-	DIG_EXT_PORT_STAGE_3 = 3,
-	DIG_EXT_PORT_STAGE_MAX = 4,
-};
-
 enum pwr_track_control_method {
 	BBSWING,
 	TXAGC
diff --git a/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c b/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c
index dabe18f..f5ee67c 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c
@@ -195,36 +195,6 @@ void dm_savepowerindex(struct ieee80211_hw *hw)
 }
 EXPORT_SYMBOL_GPL(dm_savepowerindex);
 
-static void rtl92c_dm_diginit(struct ieee80211_hw *hw)
-{
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct dig_t *dm_digtable = &rtlpriv->dm_digtable;
-
-	dm_digtable->dig_enable_flag = true;
-	dm_digtable->dig_ext_port_stage = DIG_EXT_PORT_STAGE_MAX;
-	dm_digtable->cur_igvalue = 0x20;
-	dm_digtable->pre_igvalue = 0x0;
-	dm_digtable->cursta_cstate = DIG_STA_DISCONNECT;
-	dm_digtable->presta_cstate = DIG_STA_DISCONNECT;
-	dm_digtable->curmultista_cstate = DIG_MULTISTA_DISCONNECT;
-	dm_digtable->rssi_lowthresh = DM_DIG_THRESH_LOW;
-	dm_digtable->rssi_highthresh = DM_DIG_THRESH_HIGH;
-	dm_digtable->fa_lowthresh = DM_FALSEALARM_THRESH_LOW;
-	dm_digtable->fa_highthresh = DM_FALSEALARM_THRESH_HIGH;
-	dm_digtable->rx_gain_max = DM_DIG_MAX;
-	dm_digtable->rx_gain_min = DM_DIG_MIN;
-	dm_digtable->back_val = DM_DIG_BACKOFF_DEFAULT;
-	dm_digtable->back_range_max = DM_DIG_BACKOFF_MAX;
-	dm_digtable->back_range_min = DM_DIG_BACKOFF_MIN;
-	dm_digtable->pre_cck_pd_state = CCK_PD_STAGE_MAX;
-	dm_digtable->cur_cck_pd_state = CCK_PD_STAGE_LowRssi;
-
-	dm_digtable->forbidden_igi = DM_DIG_MIN;
-	dm_digtable->large_fa_hit = 0;
-	dm_digtable->recover_cnt = 0;
-	dm_digtable->dig_min_0  = 0x25;
-}
-
 static u8 rtl92c_dm_initial_gain_min_pwdb(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
@@ -508,27 +478,27 @@ static void rtl92c_dm_cck_packet_detection_thresh(struct ieee80211_hw *hw)
 		if (dm_digtable->rssi_val_min > 100)
 			dm_digtable->rssi_val_min = 100;
 
-		if (dm_digtable->pre_cck_pd_state == CCK_PD_STAGE_LowRssi) {
+		if (dm_digtable->pre_cck_pd_state == CCK_PD_STAGE_LOWRSSI) {
 			if (dm_digtable->rssi_val_min <= 25)
 				dm_digtable->cur_cck_pd_state =
-				    CCK_PD_STAGE_LowRssi;
+				    CCK_PD_STAGE_LOWRSSI;
 			else
 				dm_digtable->cur_cck_pd_state =
-				    CCK_PD_STAGE_HighRssi;
+				    CCK_PD_STAGE_HIGHRSSI;
 		} else {
 			if (dm_digtable->rssi_val_min <= 20)
 				dm_digtable->cur_cck_pd_state =
-				    CCK_PD_STAGE_LowRssi;
+				    CCK_PD_STAGE_LOWRSSI;
 			else
 				dm_digtable->cur_cck_pd_state =
-				    CCK_PD_STAGE_HighRssi;
+				    CCK_PD_STAGE_HIGHRSSI;
 		}
 	} else {
 		dm_digtable->cur_cck_pd_state = CCK_PD_STAGE_MAX;
 	}
 
 	if (dm_digtable->pre_cck_pd_state != dm_digtable->cur_cck_pd_state) {
-		if ((dm_digtable->cur_cck_pd_state == CCK_PD_STAGE_LowRssi) ||
+		if ((dm_digtable->cur_cck_pd_state == CCK_PD_STAGE_LOWRSSI) ||
 		    (dm_digtable->cur_cck_pd_state == CCK_PD_STAGE_MAX))
 			rtl_set_bbreg(hw, RCCK0_CCA, MASKBYTE2, 0x83);
 		else
@@ -1375,7 +1345,7 @@ void rtl92c_dm_init(struct ieee80211_hw *hw)
 	rtlpriv->dm.undec_sm_pwdb = -1;
 	rtlpriv->dm.undec_sm_cck = -1;
 	rtlpriv->dm.dm_initialgain_enable = true;
-	rtl92c_dm_diginit(hw);
+	rtl_dm_diginit(hw, 0x20);
 
 	rtlpriv->dm.dm_flag |= HAL_DM_HIPWR_DISABLE;
 	rtl92c_dm_init_dynamic_txpower(hw);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.h b/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.h
index 55ebffd..4422e31 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.h
@@ -110,14 +110,6 @@ enum tag_dynamic_init_gain_operation_type_definition {
 	DIG_OP_TYPE_MAX
 };
 
-enum tag_cck_packet_detection_threshold_type_definition {
-	CCK_PD_STAGE_LowRssi = 0,
-	CCK_PD_STAGE_HighRssi = 1,
-	CCK_FA_STAGE_Low = 2,
-	CCK_FA_STAGE_High = 3,
-	CCK_PD_STAGE_MAX = 4,
-};
-
 enum dm_1r_cca_e {
 	CCA_1R = 0,
 	CCA_2R = 1,
@@ -136,14 +128,6 @@ enum dm_sw_ant_switch_e {
 	ANS_ANTENNA_MAX = 3,
 };
 
-enum dm_dig_ext_port_alg_e {
-	DIG_EXT_PORT_STAGE_0 = 0,
-	DIG_EXT_PORT_STAGE_1 = 1,
-	DIG_EXT_PORT_STAGE_2 = 2,
-	DIG_EXT_PORT_STAGE_3 = 3,
-	DIG_EXT_PORT_STAGE_MAX = 4,
-};
-
 void rtl92c_dm_init(struct ieee80211_hw *hw);
 void rtl92c_dm_watchdog(struct ieee80211_hw *hw);
 void rtl92c_dm_write_dig(struct ieee80211_hw *hw);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/dm.h b/drivers/net/wireless/rtlwifi/rtl8192de/dm.h
index d21b3bc..f2d318c 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/dm.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/dm.h
@@ -95,14 +95,6 @@ enum tag_dynamic_init_gain_operation_type_definition {
 	DIG_OP_TYPE_MAX
 };
 
-enum tag_cck_packet_detection_threshold_type_definition {
-	CCK_PD_STAGE_LOWRSSI = 0,
-	CCK_PD_STAGE_HIGHRSSI = 1,
-	CCK_FA_STAGE_LOW = 2,
-	CCK_FA_STAGE_HIGH = 3,
-	CCK_PD_STAGE_MAX = 4,
-};
-
 enum dm_1r_cca {
 	CCA_1R = 0,
 	CCA_2R = 1,
@@ -121,14 +113,6 @@ enum dm_sw_ant_switch {
 	ANS_ANTENNA_MAX = 3,
 };
 
-enum dm_dig_ext_port_alg {
-	DIG_EXT_PORT_STAGE_0 = 0,
-	DIG_EXT_PORT_STAGE_1 = 1,
-	DIG_EXT_PORT_STAGE_2 = 2,
-	DIG_EXT_PORT_STAGE_3 = 3,
-	DIG_EXT_PORT_STAGE_MAX = 4,
-};
-
 void rtl92d_dm_init(struct ieee80211_hw *hw);
 void rtl92d_dm_watchdog(struct ieee80211_hw *hw);
 void rtl92d_dm_init_edca_turbo(struct ieee80211_hw *hw);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/dm.h b/drivers/net/wireless/rtlwifi/rtl8192se/dm.h
index 7d778d3..be07d81 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/dm.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/dm.h
@@ -54,14 +54,6 @@ enum dm_dig_sta {
 	DM_STA_DIG_MAX
 };
 
-enum dm_dig_ext_port_alg {
-	DIG_EXT_PORT_STAGE_0 = 0,
-	DIG_EXT_PORT_STAGE_1 = 1,
-	DIG_EXT_PORT_STAGE_2 = 2,
-	DIG_EXT_PORT_STAGE_3 = 3,
-	DIG_EXT_PORT_STAGE_MAX = 4,
-};
-
 enum dm_ratr_sta {
 	DM_RATR_STA_HIGH = 0,
 	DM_RATR_STA_MIDDLEHIGH = 1,
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/dm.c b/drivers/net/wireless/rtlwifi/rtl8723ae/dm.c
index 80f4c54..8bd124c 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/dm.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/dm.c
@@ -396,30 +396,30 @@ static void rtl8723e_dm_cck_packet_detection_thresh(struct ieee80211_hw *hw)
 	if (dm_digtable->cursta_cstate == DIG_STA_CONNECT) {
 		dm_digtable->rssi_val_min = rtl8723e_dm_initial_gain_min_pwdb(hw);
 
-		if (dm_digtable->pre_cck_pd_state == CCK_PD_STAGE_LowRssi) {
+		if (dm_digtable->pre_cck_pd_state == CCK_PD_STAGE_LOWRSSI) {
 			if (dm_digtable->rssi_val_min <= 25)
 				dm_digtable->cur_cck_pd_state =
-				    CCK_PD_STAGE_LowRssi;
+				    CCK_PD_STAGE_LOWRSSI;
 			else
 				dm_digtable->cur_cck_pd_state =
-				    CCK_PD_STAGE_HighRssi;
+				    CCK_PD_STAGE_HIGHRSSI;
 		} else {
 			if (dm_digtable->rssi_val_min <= 20)
 				dm_digtable->cur_cck_pd_state =
-				    CCK_PD_STAGE_LowRssi;
+				    CCK_PD_STAGE_LOWRSSI;
 			else
 				dm_digtable->cur_cck_pd_state =
-				    CCK_PD_STAGE_HighRssi;
+				    CCK_PD_STAGE_HIGHRSSI;
 		}
 	} else {
 		dm_digtable->cur_cck_pd_state = CCK_PD_STAGE_MAX;
 	}
 
 	if (dm_digtable->pre_cck_pd_state != dm_digtable->cur_cck_pd_state) {
-		if (dm_digtable->cur_cck_pd_state == CCK_PD_STAGE_LowRssi) {
+		if (dm_digtable->cur_cck_pd_state == CCK_PD_STAGE_LOWRSSI) {
 			if (rtlpriv->falsealm_cnt.cnt_cck_fail > 800)
 				dm_digtable->cur_cck_fa_state =
-				    CCK_FA_STAGE_High;
+				    CCK_FA_STAGE_HIGH;
 			else
 				dm_digtable->cur_cck_fa_state =
 				    CCK_FA_STAGE_LOW;
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/dm.h b/drivers/net/wireless/rtlwifi/rtl8723ae/dm.h
index c54024e..5711105 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/dm.h
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/dm.h
@@ -95,14 +95,6 @@ enum tag_dynamic_init_gain_operation_type_definition {
 	DIG_OP_TYPE_MAX
 };
 
-enum tag_cck_packet_detection_threshold_type_definition {
-	CCK_PD_STAGE_LowRssi = 0,
-	CCK_PD_STAGE_HighRssi = 1,
-	CCK_FA_STAGE_LOW = 2,
-	CCK_FA_STAGE_High = 3,
-	CCK_PD_STAGE_MAX = 4,
-};
-
 enum dm_1r_cca_e {
 	CCA_1R = 0,
 	CCA_2R = 1,
@@ -121,14 +113,6 @@ enum dm_sw_ant_switch_e {
 	ANS_ANTENNA_MAX = 3,
 };
 
-enum dm_dig_ext_port_alg_e {
-	DIG_EXT_PORT_STAGE_0 = 0,
-	DIG_EXT_PORT_STAGE_1 = 1,
-	DIG_EXT_PORT_STAGE_2 = 2,
-	DIG_EXT_PORT_STAGE_3 = 3,
-	DIG_EXT_PORT_STAGE_MAX = 4,
-};
-
 #define BT_RSSI_STATE_NORMAL_POWER      BIT_OFFSET_LEN_MASK_32(0, 1)
 #define BT_RSSI_STATE_AMDPU_OFF         BIT_OFFSET_LEN_MASK_32(1, 1)
 #define BT_RSSI_STATE_SPECIAL_LOW       BIT_OFFSET_LEN_MASK_32(2, 1)
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/dm.h b/drivers/net/wireless/rtlwifi/rtl8723be/dm.h
index f3e47ab..533b4f2 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/dm.h
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/dm.h
@@ -239,14 +239,6 @@ enum dm_sw_ant_switch_e {
 	ANS_ANTENNA_MAX	= 3,
 };
 
-enum dm_dig_ext_port_alg_e {
-	DIG_EXT_PORT_STAGE_0	= 0,
-	DIG_EXT_PORT_STAGE_1	= 1,
-	DIG_EXT_PORT_STAGE_2	= 2,
-	DIG_EXT_PORT_STAGE_3	= 3,
-	DIG_EXT_PORT_STAGE_MAX	= 4,
-};
-
 enum pwr_track_control_method {
 	BBSWING,
 	TXAGC
diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/dm.h b/drivers/net/wireless/rtlwifi/rtl8821ae/dm.h
index f311887..5516557 100644
--- a/drivers/net/wireless/rtlwifi/rtl8821ae/dm.h
+++ b/drivers/net/wireless/rtlwifi/rtl8821ae/dm.h
@@ -255,14 +255,6 @@ enum tag_dynamic_init_gain_operation_type_definition {
 	DIG_OP_TYPE_MAX
 };
 
-enum tag_cck_packet_detection_threshold_type_definition {
-	CCK_PD_STAGE_LOWRSSI = 0,
-	CCK_PD_STAGE_HIGHRSSI = 1,
-	CCK_FA_STAGE_LOW = 2,
-	CCK_FA_STAGE_HIGH = 3,
-	CCK_PD_STAGE_MAX = 4,
-};
-
 enum dm_1r_cca_e {
 	CCA_1R = 0,
 	CCA_2R = 1,
@@ -281,14 +273,6 @@ enum dm_sw_ant_switch_e {
 	ANS_ANTENNA_MAX = 3,
 };
 
-enum dm_dig_ext_port_alg_e {
-	DIG_EXT_PORT_STAGE_0 = 0,
-	DIG_EXT_PORT_STAGE_1 = 1,
-	DIG_EXT_PORT_STAGE_2 = 2,
-	DIG_EXT_PORT_STAGE_3 = 3,
-	DIG_EXT_PORT_STAGE_MAX = 4,
-};
-
 enum pwr_track_control_method {
 	BBSWING,
 	TXAGC,
-- 
2.1.2
