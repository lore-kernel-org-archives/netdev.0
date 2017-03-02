From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 11/26] rtlwifi: reduce stack usage for KASAN
Date: Thu,  2 Mar 2017 17:38:19 +0100
Message-ID: <20170302163834.2273519-12-arnd@arndb.de>
References: <20170302163834.2273519-1-arnd@arndb.de>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Alexander Potapenko <glider@google.com>,
        Dmitry Vyukov <dvyukov@google.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-media@vger.kernel.org,
        linux-wireless@vger.kernel.org,
        kernel-build-reports@lists.linaro.org,
        "David S . Miller" <davem@davemloft.net>,
        Arnd Bergmann <arnd@arndb.de>
To: kasan-dev@googlegroups.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.134]:55600 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752838AbdCBRLM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Mar 2017 12:11:12 -0500
In-Reply-To: <20170302163834.2273519-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When CONFIG_KASAN is set, we use a large amount of stack in the btcoexist code,
presumably due to lots of inlining of functions that each add to the kernel
stack.

net/wireless/realtek/rtlwifi/btcoexist/halbtc8192e2ant.c:3762:1: error: the frame size of 4032 bytes is larger than 3072 bytes
net/wireless/realtek/rtlwifi/btcoexist/halbtc8723b2ant.c:3076:1: error: the frame size of 4104 bytes is larger than 3072 bytes
net/wireless/realtek/rtlwifi/btcoexist/halbtc8821a2ant.c:3740:1: error: the frame size of 3408 bytes is larger than 3072 bytes

I went through these recursively and marked functions as noinline_for_kasan
until no function used more than a kilobyte. While I saw the warning only for
three of the five files, I'm changing all five the same way for consistency.
This should help in case gcc later makes different inlining decisions.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 .../realtek/rtlwifi/btcoexist/halbtc8192e2ant.c    | 41 +++++++++++-----------
 .../realtek/rtlwifi/btcoexist/halbtc8723b1ant.c    | 26 +++++++-------
 .../realtek/rtlwifi/btcoexist/halbtc8723b2ant.c    | 34 +++++++++---------
 .../realtek/rtlwifi/btcoexist/halbtc8821a1ant.c    | 36 +++++++++----------
 .../realtek/rtlwifi/btcoexist/halbtc8821a2ant.c    | 38 ++++++++++----------
 5 files changed, 88 insertions(+), 87 deletions(-)

diff --git a/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8192e2ant.c b/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8192e2ant.c
index ffa1f438424d..8433c406a3c0 100644
--- a/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8192e2ant.c
+++ b/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8192e2ant.c
@@ -455,7 +455,7 @@ static void halbtc8192e2ant_querybt_info(struct btc_coexist *btcoexist)
 	btcoexist->btc_fill_h2c(btcoexist, 0x61, 1, h2c_parameter);
 }
 
-static void halbtc8192e2ant_update_btlink_info(struct btc_coexist *btcoexist)
+static noinline_for_kasan void halbtc8192e2ant_update_btlink_info(struct btc_coexist *btcoexist)
 {
 	struct btc_bt_link_info *bt_link_info = &btcoexist->bt_link_info;
 	bool bt_hson = false;
@@ -751,7 +751,7 @@ static void halbtc8192e2ant_set_fwdec_btpwr(struct btc_coexist *btcoexist,
 	btcoexist->btc_fill_h2c(btcoexist, 0x62, 1, h2c_parameter);
 }
 
-static void halbtc8192e2ant_dec_btpwr(struct btc_coexist *btcoexist,
+static noinline_for_kasan void halbtc8192e2ant_dec_btpwr(struct btc_coexist *btcoexist,
 				      bool force_exec, u8 dec_btpwr_lvl)
 {
 	struct rtl_priv *rtlpriv = btcoexist->adapter;
@@ -817,7 +817,7 @@ static void halbtc8192e2ant_bt_autoreport(struct btc_coexist *btcoexist,
 	coex_dm->pre_bt_auto_report = coex_dm->cur_bt_auto_report;
 }
 
-static void halbtc8192e2ant_fw_dac_swinglvl(struct btc_coexist *btcoexist,
+static noinline_for_kasan void halbtc8192e2ant_fw_dac_swinglvl(struct btc_coexist *btcoexist,
 					    bool force_exec, u8 fw_dac_swinglvl)
 {
 	struct rtl_priv *rtlpriv = btcoexist->adapter;
@@ -1145,8 +1145,9 @@ static void halbtc8192e2ant_IgnoreWlanAct(struct btc_coexist *btcoexist,
 	coex_dm->pre_ignore_wlan_act = coex_dm->cur_ignore_wlan_act;
 }
 
-static void halbtc8192e2ant_SetFwPstdma(struct btc_coexist *btcoexist, u8 byte1,
-					u8 byte2, u8 byte3, u8 byte4, u8 byte5)
+static noinline_for_kasan void
+halbtc8192e2ant_SetFwPstdma(struct btc_coexist *btcoexist, u8 byte1,
+			    u8 byte2, u8 byte3, u8 byte4, u8 byte5)
 {
 	struct rtl_priv *rtlpriv = btcoexist->adapter;
 
@@ -1328,7 +1329,7 @@ static void halbtc8192e2ant_ps_tdma(struct btc_coexist *btcoexist,
 	coex_dm->pre_ps_tdma = coex_dm->cur_ps_tdma;
 }
 
-static void halbtc8192e2ant_set_switch_sstype(struct btc_coexist *btcoexist,
+static noinline_for_kasan void halbtc8192e2ant_set_switch_sstype(struct btc_coexist *btcoexist,
 					      u8 sstype)
 {
 	struct rtl_priv *rtlpriv = btcoexist->adapter;
@@ -1365,7 +1366,7 @@ static void halbtc8192e2ant_set_switch_sstype(struct btc_coexist *btcoexist,
 	btcoexist->btc_set(btcoexist, BTC_SET_ACT_SEND_MIMO_PS, &mimops);
 }
 
-static void halbtc8192e2ant_switch_sstype(struct btc_coexist *btcoexist,
+static noinline_for_kasan void halbtc8192e2ant_switch_sstype(struct btc_coexist *btcoexist,
 					  bool force_exec, u8 new_sstype)
 {
 	struct rtl_priv *rtlpriv = btcoexist->adapter;
@@ -1432,7 +1433,7 @@ static void halbtc8192e2ant_action_bt_inquiry(struct btc_coexist *btcoexist)
 	btc8192e2ant_sw_mec2(btcoexist, false, false, false, 0x18);
 }
 
-static bool halbtc8192e2ant_is_common_action(struct btc_coexist *btcoexist)
+static noinline_for_kasan bool halbtc8192e2ant_is_common_action(struct btc_coexist *btcoexist)
 {
 	struct rtl_priv *rtlpriv = btcoexist->adapter;
 	struct btc_bt_link_info *bt_link_info = &btcoexist->bt_link_info;
@@ -2358,7 +2359,7 @@ static void halbtc8192e2ant_tdma_duration_adjust(struct btc_coexist *btcoexist,
 }
 
 /* SCO only or SCO+PAN(HS) */
-static void halbtc8192e2ant_action_sco(struct btc_coexist *btcoexist)
+static noinline_for_kasan void halbtc8192e2ant_action_sco(struct btc_coexist *btcoexist)
 {
 	u8 wifirssi_state, btrssi_state = BTC_RSSI_STATE_STAY_LOW;
 	u32 wifi_bw;
@@ -2420,7 +2421,7 @@ static void halbtc8192e2ant_action_sco(struct btc_coexist *btcoexist)
 	}
 }
 
-static void halbtc8192e2ant_action_sco_pan(struct btc_coexist *btcoexist)
+static noinline_for_kasan void halbtc8192e2ant_action_sco_pan(struct btc_coexist *btcoexist)
 {
 	u8 wifirssi_state, btrssi_state = BTC_RSSI_STATE_STAY_LOW;
 	u32 wifi_bw;
@@ -2482,7 +2483,7 @@ static void halbtc8192e2ant_action_sco_pan(struct btc_coexist *btcoexist)
 	}
 }
 
-static void halbtc8192e2ant_action_hid(struct btc_coexist *btcoexist)
+static noinline_for_kasan void halbtc8192e2ant_action_hid(struct btc_coexist *btcoexist)
 {
 	u8 wifirssi_state, btrssi_state = BTC_RSSI_STATE_HIGH;
 	u32 wifi_bw;
@@ -2544,7 +2545,7 @@ static void halbtc8192e2ant_action_hid(struct btc_coexist *btcoexist)
 }
 
 /* A2DP only / PAN(EDR) only/ A2DP+PAN(HS) */
-static void halbtc8192e2ant_action_a2dp(struct btc_coexist *btcoexist)
+static noinline_for_kasan void halbtc8192e2ant_action_a2dp(struct btc_coexist *btcoexist)
 {
 	struct rtl_priv *rtlpriv = btcoexist->adapter;
 	u8 wifirssi_state, btrssi_state = BTC_RSSI_STATE_HIGH;
@@ -2633,7 +2634,7 @@ static void halbtc8192e2ant_action_a2dp(struct btc_coexist *btcoexist)
 	}
 }
 
-static void halbtc8192e2ant_action_a2dp_pan_hs(struct btc_coexist *btcoexist)
+static noinline_for_kasan void halbtc8192e2ant_action_a2dp_pan_hs(struct btc_coexist *btcoexist)
 {
 	u8 wifirssi_state, btrssi_state = BTC_RSSI_STATE_HIGH;
 	u32 wifi_bw;
@@ -2694,7 +2695,7 @@ static void halbtc8192e2ant_action_a2dp_pan_hs(struct btc_coexist *btcoexist)
 	}
 }
 
-static void halbtc8192e2ant_action_pan_edr(struct btc_coexist *btcoexist)
+static noinline_for_kasan void halbtc8192e2ant_action_pan_edr(struct btc_coexist *btcoexist)
 {
 	u8 wifirssi_state, btrssi_state = BTC_RSSI_STATE_HIGH;
 	u32 wifi_bw;
@@ -2755,7 +2756,7 @@ static void halbtc8192e2ant_action_pan_edr(struct btc_coexist *btcoexist)
 }
 
 /* PAN(HS) only */
-static void halbtc8192e2ant_action_pan_hs(struct btc_coexist *btcoexist)
+static noinline_for_kasan void halbtc8192e2ant_action_pan_hs(struct btc_coexist *btcoexist)
 {
 	u8 wifirssi_state, btrssi_state = BTC_RSSI_STATE_HIGH;
 	u32 wifi_bw;
@@ -2813,7 +2814,7 @@ static void halbtc8192e2ant_action_pan_hs(struct btc_coexist *btcoexist)
 }
 
 /* PAN(EDR)+A2DP */
-static void halbtc8192e2ant_action_pan_edr_a2dp(struct btc_coexist *btcoexist)
+static noinline_for_kasan void halbtc8192e2ant_action_pan_edr_a2dp(struct btc_coexist *btcoexist)
 {
 	u8 wifirssi_state, btrssi_state = BTC_RSSI_STATE_HIGH;
 	u32 wifi_bw;
@@ -2876,7 +2877,7 @@ static void halbtc8192e2ant_action_pan_edr_a2dp(struct btc_coexist *btcoexist)
 	}
 }
 
-static void halbtc8192e2ant_action_pan_edr_hid(struct btc_coexist *btcoexist)
+static noinline_for_kasan void halbtc8192e2ant_action_pan_edr_hid(struct btc_coexist *btcoexist)
 {
 	u8 wifirssi_state, btrssi_state = BTC_RSSI_STATE_HIGH;
 	u32 wifi_bw;
@@ -2940,7 +2941,7 @@ static void halbtc8192e2ant_action_pan_edr_hid(struct btc_coexist *btcoexist)
 }
 
 /* HID+A2DP+PAN(EDR) */
-static void btc8192e2ant_action_hid_a2dp_pan_edr(struct btc_coexist *btcoexist)
+static noinline_for_kasan void btc8192e2ant_action_hid_a2dp_pan_edr(struct btc_coexist *btcoexist)
 {
 	u8 wifirssi_state, btrssi_state = BTC_RSSI_STATE_HIGH;
 	u32 wifi_bw;
@@ -3001,7 +3002,7 @@ static void btc8192e2ant_action_hid_a2dp_pan_edr(struct btc_coexist *btcoexist)
 	}
 }
 
-static void halbtc8192e2ant_action_hid_a2dp(struct btc_coexist *btcoexist)
+static noinline_for_kasan void halbtc8192e2ant_action_hid_a2dp(struct btc_coexist *btcoexist)
 {
 	u8 wifirssi_state, btrssi_state = BTC_RSSI_STATE_HIGH;
 	u32 wifi_bw;
@@ -3060,7 +3061,7 @@ static void halbtc8192e2ant_action_hid_a2dp(struct btc_coexist *btcoexist)
 	}
 }
 
-static void halbtc8192e2ant_run_coexist_mechanism(struct btc_coexist *btcoexist)
+static noinline_for_kasan void halbtc8192e2ant_run_coexist_mechanism(struct btc_coexist *btcoexist)
 {
 	struct rtl_priv *rtlpriv = btcoexist->adapter;
 	u8 algorithm = 0;
diff --git a/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8723b1ant.c b/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8723b1ant.c
index d67bbfb6ad8e..583933f10af2 100644
--- a/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8723b1ant.c
+++ b/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8723b1ant.c
@@ -862,7 +862,7 @@ static void halbtc8723b1ant_SetFwIgnoreWlanAct(struct btc_coexist *btcoexist,
 	btcoexist->btc_fill_h2c(btcoexist, 0x63, 1, h2c_parameter);
 }
 
-static void halbtc8723b1ant_ignore_wlan_act(struct btc_coexist *btcoexist,
+static noinline_for_kasan void halbtc8723b1ant_ignore_wlan_act(struct btc_coexist *btcoexist,
 					    bool force_exec, bool enable)
 {
 	struct rtl_priv *rtlpriv = btcoexist->adapter;
@@ -1407,7 +1407,7 @@ static void halbtc8723b1ant_ps_tdma(struct btc_coexist *btcoexist,
 	coex_dm->pre_ps_tdma = coex_dm->cur_ps_tdma;
 }
 
-static bool halbtc8723b1ant_is_common_action(struct btc_coexist *btcoexist)
+static noinline_for_kasan bool halbtc8723b1ant_is_common_action(struct btc_coexist *btcoexist)
 {
 	struct rtl_priv *rtlpriv = btcoexist->adapter;
 	bool commom = false, wifi_connected = false;
@@ -1706,56 +1706,56 @@ static void halbtc8723b1ant_power_save_state(struct btc_coexist *btcoexist,
  *
  ***************************************************/
 /* SCO only or SCO+PAN(HS) */
-static void halbtc8723b1ant_action_sco(struct btc_coexist *btcoexist)
+static noinline_for_kasan void halbtc8723b1ant_action_sco(struct btc_coexist *btcoexist)
 {
 	halbtc8723b1ant_sw_mechanism(btcoexist, true);
 }
 
-static void halbtc8723b1ant_action_hid(struct btc_coexist *btcoexist)
+static noinline_for_kasan void halbtc8723b1ant_action_hid(struct btc_coexist *btcoexist)
 {
 	halbtc8723b1ant_sw_mechanism(btcoexist, true);
 }
 
 /*A2DP only / PAN(EDR) only/ A2DP+PAN(HS) */
-static void halbtc8723b1ant_action_a2dp(struct btc_coexist *btcoexist)
+static noinline_for_kasan void halbtc8723b1ant_action_a2dp(struct btc_coexist *btcoexist)
 {
 	halbtc8723b1ant_sw_mechanism(btcoexist, false);
 }
 
-static void halbtc8723b1ant_action_a2dp_pan_hs(struct btc_coexist *btcoexist)
+static noinline_for_kasan noinline_for_kasan void halbtc8723b1ant_action_a2dp_pan_hs(struct btc_coexist *btcoexist)
 {
 	halbtc8723b1ant_sw_mechanism(btcoexist, false);
 }
 
-static void halbtc8723b1ant_action_pan_edr(struct btc_coexist *btcoexist)
+static noinline_for_kasan void halbtc8723b1ant_action_pan_edr(struct btc_coexist *btcoexist)
 {
 	halbtc8723b1ant_sw_mechanism(btcoexist, false);
 }
 
 /* PAN(HS) only */
-static void halbtc8723b1ant_action_pan_hs(struct btc_coexist *btcoexist)
+static noinline_for_kasan void halbtc8723b1ant_action_pan_hs(struct btc_coexist *btcoexist)
 {
 	halbtc8723b1ant_sw_mechanism(btcoexist, false);
 }
 
 /*PAN(EDR)+A2DP */
-static void halbtc8723b1ant_action_pan_edr_a2dp(struct btc_coexist *btcoexist)
+static noinline_for_kasan noinline_for_kasan void halbtc8723b1ant_action_pan_edr_a2dp(struct btc_coexist *btcoexist)
 {
 	halbtc8723b1ant_sw_mechanism(btcoexist, false);
 }
 
-static void halbtc8723b1ant_action_pan_edr_hid(struct btc_coexist *btcoexist)
+static noinline_for_kasan noinline_for_kasan void halbtc8723b1ant_action_pan_edr_hid(struct btc_coexist *btcoexist)
 {
 	halbtc8723b1ant_sw_mechanism(btcoexist, true);
 }
 
 /* HID+A2DP+PAN(EDR) */
-static void btc8723b1ant_action_hid_a2dp_pan_edr(struct btc_coexist *btcoexist)
+static noinline_for_kasan void btc8723b1ant_action_hid_a2dp_pan_edr(struct btc_coexist *btcoexist)
 {
 	halbtc8723b1ant_sw_mechanism(btcoexist, true);
 }
 
-static void halbtc8723b1ant_action_hid_a2dp(struct btc_coexist *btcoexist)
+static noinline_for_kasan noinline_for_kasan void halbtc8723b1ant_action_hid_a2dp(struct btc_coexist *btcoexist)
 {
 	halbtc8723b1ant_sw_mechanism(btcoexist, true);
 }
@@ -2178,7 +2178,7 @@ static void btc8723b1ant_run_sw_coex_mech(struct btc_coexist *btcoexist)
 	}
 }
 
-static void halbtc8723b1ant_run_coexist_mechanism(struct btc_coexist *btcoexist)
+static noinline_for_kasan void halbtc8723b1ant_run_coexist_mechanism(struct btc_coexist *btcoexist)
 {
 	struct rtl_priv *rtlpriv = btcoexist->adapter;
 	struct btc_bt_link_info *bt_link_info = &btcoexist->bt_link_info;
diff --git a/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8723b2ant.c b/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8723b2ant.c
index 12125966a911..8459add3576f 100644
--- a/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8723b2ant.c
+++ b/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8723b2ant.c
@@ -659,7 +659,7 @@ static void btc8723b2ant_set_fw_dec_bt_pwr(struct btc_coexist *btcoexist,
 	btcoexist->btc_fill_h2c(btcoexist, 0x62, 1, h2c_parameter);
 }
 
-static void btc8723b2ant_dec_bt_pwr(struct btc_coexist *btcoexist,
+static noinline_for_kasan void btc8723b2ant_dec_bt_pwr(struct btc_coexist *btcoexist,
 				    bool force_exec, bool dec_bt_pwr)
 {
 	struct rtl_priv *rtlpriv = btcoexist->adapter;
@@ -1087,7 +1087,7 @@ static void btc8723b_coex_tbl_type(struct btc_coexist *btcoexist,
 	}
 }
 
-static void btc8723b2ant_set_fw_ignore_wlan_act(struct btc_coexist *btcoexist,
+static noinline_for_kasan void btc8723b2ant_set_fw_ignore_wlan_act(struct btc_coexist *btcoexist,
 						bool enable)
 {
 	struct rtl_priv *rtlpriv = btcoexist->adapter;
@@ -1103,7 +1103,7 @@ static void btc8723b2ant_set_fw_ignore_wlan_act(struct btc_coexist *btcoexist,
 	btcoexist->btc_fill_h2c(btcoexist, 0x63, 1, h2c_parameter);
 }
 
-static void btc8723b2ant_ignore_wlan_act(struct btc_coexist *btcoexist,
+static noinline_for_kasan void btc8723b2ant_ignore_wlan_act(struct btc_coexist *btcoexist,
 					 bool force_exec, bool enable)
 {
 	struct rtl_priv *rtlpriv = btcoexist->adapter;
@@ -1128,7 +1128,7 @@ static void btc8723b2ant_ignore_wlan_act(struct btc_coexist *btcoexist,
 	coex_dm->pre_ignore_wlan_act = coex_dm->cur_ignore_wlan_act;
 }
 
-static void btc8723b2ant_set_fw_ps_tdma(struct btc_coexist *btcoexist, u8 byte1,
+static noinline_for_kasan void btc8723b2ant_set_fw_ps_tdma(struct btc_coexist *btcoexist, u8 byte1,
 					u8 byte2, u8 byte3, u8 byte4, u8 byte5)
 {
 	struct rtl_priv *rtlpriv = btcoexist->adapter;
@@ -1398,7 +1398,7 @@ static void btc8723b2ant_ps_tdma(struct btc_coexist *btcoexist, bool force_exec,
 	coex_dm->pre_ps_tdma = coex_dm->cur_ps_tdma;
 }
 
-static void btc8723b2ant_coex_alloff(struct btc_coexist *btcoexist)
+static noinline_for_kasan void btc8723b2ant_coex_alloff(struct btc_coexist *btcoexist)
 {
 	/* fw all off */
 	btc8723b2ant_ps_tdma(btcoexist, NORMAL_EXEC, false, 1);
@@ -1456,7 +1456,7 @@ static void btc8723b2ant_action_bt_inquiry(struct btc_coexist *btcoexist)
 				  false, false);
 }
 
-static bool btc8723b2ant_is_common_action(struct btc_coexist *btcoexist)
+static noinline_for_kasan bool btc8723b2ant_is_common_action(struct btc_coexist *btcoexist)
 {
 	struct rtl_priv *rtlpriv = btcoexist->adapter;
 	bool common = false, wifi_connected = false;
@@ -2333,7 +2333,7 @@ static void btc8723b2ant_tdma_duration_adjust(struct btc_coexist *btcoexist,
 }
 
 /* SCO only or SCO+PAN(HS) */
-static void btc8723b2ant_action_sco(struct btc_coexist *btcoexist)
+static noinline_for_kasan void btc8723b2ant_action_sco(struct btc_coexist *btcoexist)
 {
 	u8 wifi_rssi_state;
 	u32 wifi_bw;
@@ -2391,7 +2391,7 @@ static void btc8723b2ant_action_sco(struct btc_coexist *btcoexist)
 	}
 }
 
-static void btc8723b2ant_action_hid(struct btc_coexist *btcoexist)
+static noinline_for_kasan void btc8723b2ant_action_hid(struct btc_coexist *btcoexist)
 {
 	u8 wifi_rssi_state, bt_rssi_state;
 	u32 wifi_bw;
@@ -2453,7 +2453,7 @@ static void btc8723b2ant_action_hid(struct btc_coexist *btcoexist)
 }
 
 /*A2DP only / PAN(EDR) only/ A2DP+PAN(HS)*/
-static void btc8723b2ant_action_a2dp(struct btc_coexist *btcoexist)
+static noinline_for_kasan void btc8723b2ant_action_a2dp(struct btc_coexist *btcoexist)
 {
 	u8 wifi_rssi_state, wifi_rssi_state1, bt_rssi_state;
 	u32 wifi_bw;
@@ -2542,7 +2542,7 @@ static void btc8723b2ant_action_a2dp(struct btc_coexist *btcoexist)
 	}
 }
 
-static void btc8723b2ant_action_a2dp_pan_hs(struct btc_coexist *btcoexist)
+static noinline_for_kasan void btc8723b2ant_action_a2dp_pan_hs(struct btc_coexist *btcoexist)
 {
 	u8 wifi_rssi_state;
 	u32 wifi_bw;
@@ -2595,7 +2595,7 @@ static void btc8723b2ant_action_a2dp_pan_hs(struct btc_coexist *btcoexist)
 	}
 }
 
-static void btc8723b2ant_action_pan_edr(struct btc_coexist *btcoexist)
+static noinline_for_kasan void btc8723b2ant_action_pan_edr(struct btc_coexist *btcoexist)
 {
 	u8 wifi_rssi_state, bt_rssi_state;
 	u32 wifi_bw;
@@ -2653,7 +2653,7 @@ static void btc8723b2ant_action_pan_edr(struct btc_coexist *btcoexist)
 }
 
 /*PAN(HS) only*/
-static void btc8723b2ant_action_pan_hs(struct btc_coexist *btcoexist)
+static noinline_for_kasan void btc8723b2ant_action_pan_hs(struct btc_coexist *btcoexist)
 {
 	u8 wifi_rssi_state;
 	u32 wifi_bw;
@@ -2706,7 +2706,7 @@ static void btc8723b2ant_action_pan_hs(struct btc_coexist *btcoexist)
 }
 
 /*PAN(EDR)+A2DP*/
-static void btc8723b2ant_action_pan_edr_a2dp(struct btc_coexist *btcoexist)
+static noinline_for_kasan void btc8723b2ant_action_pan_edr_a2dp(struct btc_coexist *btcoexist)
 {
 	u8 wifi_rssi_state, bt_rssi_state;
 	u32 wifi_bw;
@@ -2770,7 +2770,7 @@ static void btc8723b2ant_action_pan_edr_a2dp(struct btc_coexist *btcoexist)
 	}
 }
 
-static void btc8723b2ant_action_pan_edr_hid(struct btc_coexist *btcoexist)
+static noinline_for_kasan void btc8723b2ant_action_pan_edr_hid(struct btc_coexist *btcoexist)
 {
 	u8 wifi_rssi_state, bt_rssi_state;
 	u32 wifi_bw;
@@ -2840,7 +2840,7 @@ static void btc8723b2ant_action_pan_edr_hid(struct btc_coexist *btcoexist)
 }
 
 /* HID+A2DP+PAN(EDR) */
-static void btc8723b2ant_action_hid_a2dp_pan_edr(struct btc_coexist *btcoexist)
+static noinline_for_kasan void btc8723b2ant_action_hid_a2dp_pan_edr(struct btc_coexist *btcoexist)
 {
 	u8 wifi_rssi_state, bt_rssi_state;
 	u32 wifi_bw;
@@ -2904,7 +2904,7 @@ static void btc8723b2ant_action_hid_a2dp_pan_edr(struct btc_coexist *btcoexist)
 	}
 }
 
-static void btc8723b2ant_action_hid_a2dp(struct btc_coexist *btcoexist)
+static noinline_for_kasan void btc8723b2ant_action_hid_a2dp(struct btc_coexist *btcoexist)
 {
 	u8 wifi_rssi_state, bt_rssi_state;
 	u32 wifi_bw;
@@ -2962,7 +2962,7 @@ static void btc8723b2ant_action_hid_a2dp(struct btc_coexist *btcoexist)
 	}
 }
 
-static void btc8723b2ant_run_coexist_mechanism(struct btc_coexist *btcoexist)
+static noinline_for_kasan void btc8723b2ant_run_coexist_mechanism(struct btc_coexist *btcoexist)
 {
 	struct rtl_priv *rtlpriv = btcoexist->adapter;
 	u8 algorithm = 0;
diff --git a/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8821a1ant.c b/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8821a1ant.c
index 8b689ed9a629..b3f24226f165 100644
--- a/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8821a1ant.c
+++ b/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8821a1ant.c
@@ -670,7 +670,7 @@ static u8 halbtc8821a1ant_action_algorithm(struct btc_coexist *btcoexist)
 	return algorithm;
 }
 
-static void halbtc8821a1ant_set_bt_auto_report(struct btc_coexist *btcoexist,
+static noinline_for_kasan void halbtc8821a1ant_set_bt_auto_report(struct btc_coexist *btcoexist,
 					       bool enable_auto_report)
 {
 	struct rtl_priv *rtlpriv = btcoexist->adapter;
@@ -689,7 +689,7 @@ static void halbtc8821a1ant_set_bt_auto_report(struct btc_coexist *btcoexist,
 	btcoexist->btc_fill_h2c(btcoexist, 0x68, 1, h2c_parameter);
 }
 
-static void halbtc8821a1ant_bt_auto_report(struct btc_coexist *btcoexist,
+static noinline_for_kasan void halbtc8821a1ant_bt_auto_report(struct btc_coexist *btcoexist,
 					   bool force_exec,
 					   bool enable_auto_report)
 {
@@ -849,7 +849,7 @@ static void halbtc8821a1ant_coex_table_with_type(struct btc_coexist *btcoexist,
 	}
 }
 
-static void btc8821a1ant_set_fw_ignore_wlan_act(struct btc_coexist *btcoexist,
+static noinline_for_kasan void btc8821a1ant_set_fw_ignore_wlan_act(struct btc_coexist *btcoexist,
 						bool enable)
 {
 	struct rtl_priv *rtlpriv = btcoexist->adapter;
@@ -865,7 +865,7 @@ static void btc8821a1ant_set_fw_ignore_wlan_act(struct btc_coexist *btcoexist,
 	btcoexist->btc_fill_h2c(btcoexist, 0x63, 1, h2c_parameter);
 }
 
-static void halbtc8821a1ant_ignore_wlan_act(struct btc_coexist *btcoexist,
+static noinline_for_kasan void halbtc8821a1ant_ignore_wlan_act(struct btc_coexist *btcoexist,
 					    bool force_exec, bool enable)
 {
 	struct rtl_priv *rtlpriv = btcoexist->adapter;
@@ -890,7 +890,7 @@ static void halbtc8821a1ant_ignore_wlan_act(struct btc_coexist *btcoexist,
 	coex_dm->pre_ignore_wlan_act = coex_dm->cur_ignore_wlan_act;
 }
 
-static void halbtc8821a1ant_set_fw_pstdma(struct btc_coexist *btcoexist,
+static noinline_for_kasan void halbtc8821a1ant_set_fw_pstdma(struct btc_coexist *btcoexist,
 					  u8 byte1, u8 byte2, u8 byte3,
 					  u8 byte4, u8 byte5)
 {
@@ -1269,7 +1269,7 @@ static void halbtc8821a1ant_ps_tdma(struct btc_coexist *btcoexist,
 	coex_dm->pre_ps_tdma = coex_dm->cur_ps_tdma;
 }
 
-static bool halbtc8821a1ant_is_common_action(struct btc_coexist *btcoexist)
+static noinline_for_kasan bool halbtc8821a1ant_is_common_action(struct btc_coexist *btcoexist)
 {
 	struct rtl_priv *rtlpriv = btcoexist->adapter;
 	bool	common = false, wifi_connected = false, wifi_busy = false;
@@ -1669,56 +1669,56 @@ static void btc8821a1ant_mon_bt_en_dis(struct btc_coexist *btcoexist)
 /*=============================================*/
 
 /* SCO only or SCO+PAN(HS)*/
-static void halbtc8821a1ant_action_sco(struct btc_coexist *btcoexist)
+static noinline_for_kasan void halbtc8821a1ant_action_sco(struct btc_coexist *btcoexist)
 {
 	halbtc8821a1ant_sw_mechanism(btcoexist, true);
 }
 
-static void halbtc8821a1ant_action_hid(struct btc_coexist *btcoexist)
+static noinline_for_kasan void halbtc8821a1ant_action_hid(struct btc_coexist *btcoexist)
 {
 	halbtc8821a1ant_sw_mechanism(btcoexist, true);
 }
 
 /*A2DP only / PAN(EDR) only/ A2DP+PAN(HS)*/
-static void halbtc8821a1ant_action_a2dp(struct btc_coexist *btcoexist)
+static noinline_for_kasan void halbtc8821a1ant_action_a2dp(struct btc_coexist *btcoexist)
 {
 	halbtc8821a1ant_sw_mechanism(btcoexist, false);
 }
 
-static void halbtc8821a1ant_action_a2dp_pan_hs(struct btc_coexist *btcoexist)
+static noinline_for_kasan noinline_for_kasan void halbtc8821a1ant_action_a2dp_pan_hs(struct btc_coexist *btcoexist)
 {
 	halbtc8821a1ant_sw_mechanism(btcoexist, false);
 }
 
-static void halbtc8821a1ant_action_pan_edr(struct btc_coexist *btcoexist)
+static noinline_for_kasan void halbtc8821a1ant_action_pan_edr(struct btc_coexist *btcoexist)
 {
 	halbtc8821a1ant_sw_mechanism(btcoexist, false);
 }
 
 /*PAN(HS) only*/
-static void halbtc8821a1ant_action_pan_hs(struct btc_coexist *btcoexist)
+static noinline_for_kasan void halbtc8821a1ant_action_pan_hs(struct btc_coexist *btcoexist)
 {
 	halbtc8821a1ant_sw_mechanism(btcoexist, false);
 }
 
 /*PAN(EDR)+A2DP*/
-static void halbtc8821a1ant_action_pan_edr_a2dp(struct btc_coexist *btcoexist)
+static noinline_for_kasan noinline_for_kasan void halbtc8821a1ant_action_pan_edr_a2dp(struct btc_coexist *btcoexist)
 {
 	halbtc8821a1ant_sw_mechanism(btcoexist, false);
 }
 
-static void halbtc8821a1ant_action_pan_edr_hid(struct btc_coexist *btcoexist)
+static noinline_for_kasan noinline_for_kasan void halbtc8821a1ant_action_pan_edr_hid(struct btc_coexist *btcoexist)
 {
 	halbtc8821a1ant_sw_mechanism(btcoexist, true);
 }
 
 /* HID+A2DP+PAN(EDR)*/
-static void btc8821a1ant_action_hid_a2dp_pan_edr(struct btc_coexist *btcoexist)
+static noinline_for_kasan void btc8821a1ant_action_hid_a2dp_pan_edr(struct btc_coexist *btcoexist)
 {
 	halbtc8821a1ant_sw_mechanism(btcoexist, true);
 }
 
-static void halbtc8821a1ant_action_hid_a2dp(struct btc_coexist *btcoexist)
+static noinline_for_kasan noinline_for_kasan void halbtc8821a1ant_action_hid_a2dp(struct btc_coexist *btcoexist)
 {
 	halbtc8821a1ant_sw_mechanism(btcoexist, true);
 }
@@ -1991,7 +1991,7 @@ static void halbtc8821a1ant_action_wifi_connected(struct btc_coexist *btcoexist)
 	}
 }
 
-static void btc8821a1ant_run_sw_coex_mech(struct btc_coexist *btcoexist)
+static noinline_for_kasan void btc8821a1ant_run_sw_coex_mech(struct btc_coexist *btcoexist)
 {
 	struct rtl_priv *rtlpriv = btcoexist->adapter;
 	u8	algorithm = 0;
@@ -2061,7 +2061,7 @@ static void btc8821a1ant_run_sw_coex_mech(struct btc_coexist *btcoexist)
 	}
 }
 
-static void halbtc8821a1ant_run_coexist_mechanism(struct btc_coexist *btcoexist)
+static noinline_for_kasan void halbtc8821a1ant_run_coexist_mechanism(struct btc_coexist *btcoexist)
 {
 	struct rtl_priv *rtlpriv = btcoexist->adapter;
 	struct btc_bt_link_info *bt_link_info = &btcoexist->bt_link_info;
diff --git a/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8821a2ant.c b/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8821a2ant.c
index 1717e9ce96ca..9da9f5df7690 100644
--- a/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8821a2ant.c
+++ b/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8821a2ant.c
@@ -610,7 +610,7 @@ static void halbtc8821a2ant_set_fw_dec_bt_pwr(struct btc_coexist *btcoexist,
 	btcoexist->btc_fill_h2c(btcoexist, 0x62, 1, h2c_parameter);
 }
 
-static void halbtc8821a2ant_dec_bt_pwr(struct btc_coexist *btcoexist,
+static noinline_for_kasan void halbtc8821a2ant_dec_bt_pwr(struct btc_coexist *btcoexist,
 				       bool force_exec, bool dec_bt_pwr)
 {
 	struct rtl_priv *rtlpriv = btcoexist->adapter;
@@ -722,7 +722,7 @@ static void halbtc8821a2ant_set_bt_psd_mode(struct btc_coexist *btcoexist,
 	coex_dm->pre_bt_psd_mode = coex_dm->cur_bt_psd_mode;
 }
 
-static void halbtc8821a2ant_set_bt_auto_report(struct btc_coexist *btcoexist,
+static noinline_for_kasan void halbtc8821a2ant_set_bt_auto_report(struct btc_coexist *btcoexist,
 					       bool enable_auto_report)
 {
 	struct rtl_priv *rtlpriv = btcoexist->adapter;
@@ -741,7 +741,7 @@ static void halbtc8821a2ant_set_bt_auto_report(struct btc_coexist *btcoexist,
 	btcoexist->btc_fill_h2c(btcoexist, 0x68, 1, h2c_parameter);
 }
 
-static void halbtc8821a2ant_bt_auto_report(struct btc_coexist *btcoexist,
+static noinline_for_kasan void halbtc8821a2ant_bt_auto_report(struct btc_coexist *btcoexist,
 					   bool force_exec,
 					   bool enable_auto_report)
 {
@@ -1066,7 +1066,7 @@ static void halbtc8821a2ant_coex_table(struct btc_coexist *btcoexist,
 	coex_dm->pre_val0x6cc = coex_dm->cur_val0x6cc;
 }
 
-static void halbtc8821a2ant_set_fw_ignore_wlan_act(struct btc_coexist *btcoex,
+static noinline_for_kasan void halbtc8821a2ant_set_fw_ignore_wlan_act(struct btc_coexist *btcoex,
 						   bool enable)
 {
 	struct rtl_priv *rtlpriv = btcoex->adapter;
@@ -1082,7 +1082,7 @@ static void halbtc8821a2ant_set_fw_ignore_wlan_act(struct btc_coexist *btcoex,
 	btcoex->btc_fill_h2c(btcoex, 0x63, 1, h2c_parameter);
 }
 
-static void halbtc8821a2ant_ignore_wlan_act(struct btc_coexist *btcoexist,
+static noinline_for_kasan void halbtc8821a2ant_ignore_wlan_act(struct btc_coexist *btcoexist,
 					    bool force_exec, bool enable)
 {
 	struct rtl_priv *rtlpriv = btcoexist->adapter;
@@ -1107,7 +1107,7 @@ static void halbtc8821a2ant_ignore_wlan_act(struct btc_coexist *btcoexist,
 	coex_dm->pre_ignore_wlan_act = coex_dm->cur_ignore_wlan_act;
 }
 
-static void halbtc8821a2ant_set_fw_pstdma(struct btc_coexist *btcoexist,
+static noinline_for_kasan void halbtc8821a2ant_set_fw_pstdma(struct btc_coexist *btcoexist,
 					  u8 byte1, u8 byte2, u8 byte3,
 					  u8 byte4, u8 byte5)
 {
@@ -1362,7 +1362,7 @@ static void halbtc8821a2ant_ps_tdma(struct btc_coexist *btcoexist,
 	coex_dm->pre_ps_tdma = coex_dm->cur_ps_tdma;
 }
 
-static void halbtc8821a2ant_coex_all_off(struct btc_coexist *btcoexist)
+static noinline_for_kasan void halbtc8821a2ant_coex_all_off(struct btc_coexist *btcoexist)
 {
 	/* fw all off */
 	halbtc8821a2ant_ps_tdma(btcoexist, NORMAL_EXEC, false, 1);
@@ -1409,7 +1409,7 @@ static void halbtc8821a2ant_bt_inquiry_page(struct btc_coexist *btcoexist)
 	halbtc8821a2ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 3);
 }
 
-static bool halbtc8821a2ant_is_common_action(struct btc_coexist *btcoexist)
+static noinline_for_kasan bool halbtc8821a2ant_is_common_action(struct btc_coexist *btcoexist)
 {
 	struct rtl_priv *rtlpriv = btcoexist->adapter;
 	bool common = false, wifi_connected = false, wifi_busy = false;
@@ -2355,7 +2355,7 @@ static void btc8821a2ant_tdma_dur_adj(struct btc_coexist *btcoexist,
 }
 
 /* SCO only or SCO+PAN(HS)*/
-static void halbtc8821a2ant_action_sco(struct btc_coexist *btcoexist)
+static noinline_for_kasan void halbtc8821a2ant_action_sco(struct btc_coexist *btcoexist)
 {
 	u8	wifi_rssi_state, bt_rssi_state;
 	u32 wifi_bw;
@@ -2433,7 +2433,7 @@ static void halbtc8821a2ant_action_sco(struct btc_coexist *btcoexist)
 	}
 }
 
-static void halbtc8821a2ant_action_hid(struct btc_coexist *btcoexist)
+static noinline_for_kasan void halbtc8821a2ant_action_hid(struct btc_coexist *btcoexist)
 {
 	u8	wifi_rssi_state, bt_rssi_state;
 	u32	wifi_bw;
@@ -2513,7 +2513,7 @@ static void halbtc8821a2ant_action_hid(struct btc_coexist *btcoexist)
 }
 
 /* A2DP only / PAN(EDR) only/ A2DP+PAN(HS) */
-static void halbtc8821a2ant_action_a2dp(struct btc_coexist *btcoexist)
+static noinline_for_kasan void halbtc8821a2ant_action_a2dp(struct btc_coexist *btcoexist)
 {
 	u8		wifi_rssi_state, bt_rssi_state;
 	u32		wifi_bw;
@@ -2580,7 +2580,7 @@ static void halbtc8821a2ant_action_a2dp(struct btc_coexist *btcoexist)
 	}
 }
 
-static void halbtc8821a2ant_action_a2dp_pan_hs(struct btc_coexist *btcoexist)
+static noinline_for_kasan void halbtc8821a2ant_action_a2dp_pan_hs(struct btc_coexist *btcoexist)
 {
 	u8		wifi_rssi_state, bt_rssi_state, bt_info_ext;
 	u32		wifi_bw;
@@ -2650,7 +2650,7 @@ static void halbtc8821a2ant_action_a2dp_pan_hs(struct btc_coexist *btcoexist)
 	}
 }
 
-static void halbtc8821a2ant_action_pan_edr(struct btc_coexist *btcoexist)
+static noinline_for_kasan void halbtc8821a2ant_action_pan_edr(struct btc_coexist *btcoexist)
 {
 	u8		wifi_rssi_state, bt_rssi_state;
 	u32		wifi_bw;
@@ -2730,7 +2730,7 @@ static void halbtc8821a2ant_action_pan_edr(struct btc_coexist *btcoexist)
 }
 
 /* PAN(HS) only */
-static void halbtc8821a2ant_action_pan_hs(struct btc_coexist *btcoexist)
+static noinline_for_kasan void halbtc8821a2ant_action_pan_hs(struct btc_coexist *btcoexist)
 {
 	u8		wifi_rssi_state, bt_rssi_state;
 	u32		wifi_bw;
@@ -2798,7 +2798,7 @@ static void halbtc8821a2ant_action_pan_hs(struct btc_coexist *btcoexist)
 }
 
 /* PAN(EDR)+A2DP */
-static void halbtc8821a2ant_action_pan_edr_a2dp(struct btc_coexist *btcoexist)
+static noinline_for_kasan void halbtc8821a2ant_action_pan_edr_a2dp(struct btc_coexist *btcoexist)
 {
 	u8	wifi_rssi_state, bt_rssi_state, bt_info_ext;
 	u32	wifi_bw;
@@ -2867,7 +2867,7 @@ static void halbtc8821a2ant_action_pan_edr_a2dp(struct btc_coexist *btcoexist)
 	}
 }
 
-static void halbtc8821a2ant_action_pan_edr_hid(struct btc_coexist *btcoexist)
+static noinline_for_kasan void halbtc8821a2ant_action_pan_edr_hid(struct btc_coexist *btcoexist)
 {
 	u8	wifi_rssi_state, bt_rssi_state;
 	u32	wifi_bw;
@@ -2942,7 +2942,7 @@ static void halbtc8821a2ant_action_pan_edr_hid(struct btc_coexist *btcoexist)
 }
 
 /* HID+A2DP+PAN(EDR) */
-static void btc8821a2ant_act_hid_a2dp_pan_edr(struct btc_coexist *btcoexist)
+static noinline_for_kasan void btc8821a2ant_act_hid_a2dp_pan_edr(struct btc_coexist *btcoexist)
 {
 	u8	wifi_rssi_state, bt_rssi_state, bt_info_ext;
 	u32	wifi_bw;
@@ -3022,7 +3022,7 @@ static void btc8821a2ant_act_hid_a2dp_pan_edr(struct btc_coexist *btcoexist)
 	}
 }
 
-static void halbtc8821a2ant_action_hid_a2dp(struct btc_coexist *btcoexist)
+static noinline_for_kasan void halbtc8821a2ant_action_hid_a2dp(struct btc_coexist *btcoexist)
 {
 	u8	wifi_rssi_state, bt_rssi_state, bt_info_ext;
 	u32	wifi_bw;
@@ -3079,7 +3079,7 @@ static void halbtc8821a2ant_action_hid_a2dp(struct btc_coexist *btcoexist)
 	}
 }
 
-static void halbtc8821a2ant_run_coexist_mechanism(struct btc_coexist *btcoexist)
+static noinline_for_kasan void halbtc8821a2ant_run_coexist_mechanism(struct btc_coexist *btcoexist)
 {
 	struct rtl_priv *rtlpriv = btcoexist->adapter;
 	bool	wifi_under_5g = false;
-- 
2.9.0
