From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 03/11] rtlwifi: Create new routine to initialize the DM tables
Date: Fri,  2 Jan 2015 10:58:20 -0600
Message-ID: <1420217908-1382-4-git-send-email-Larry.Finger@lwfinger.net>
References: <1420217908-1382-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: kvalo@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:49903 "EHLO
	mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752048AbbABQ6h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 11:58:37 -0500
In-Reply-To: <1420217908-1382-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Each of the drivers contains a routine that initializes the dm_digtable
member of the driver's private area. As a first step toward reducing the
size of the drivers, a copy of this driver is created in rtlwifi, and the
definitions of the parameters are moved there.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/rtlwifi/core.c               | 34 +++++++++++++++++++++++
 drivers/net/wireless/rtlwifi/core.h               | 24 ++++++++++++++++
 drivers/net/wireless/rtlwifi/rtl8188ee/dm.c       |  1 +
 drivers/net/wireless/rtlwifi/rtl8188ee/dm.h       | 22 ---------------
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c |  1 +
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.h | 22 ---------------
 drivers/net/wireless/rtlwifi/rtl8192ce/dm.c       |  1 +
 drivers/net/wireless/rtlwifi/rtl8192ce/dm.h       | 13 ---------
 drivers/net/wireless/rtlwifi/rtl8192de/dm.c       |  1 +
 drivers/net/wireless/rtlwifi/rtl8192de/dm.h       | 22 ---------------
 drivers/net/wireless/rtlwifi/rtl8192ee/dm.c       |  1 +
 drivers/net/wireless/rtlwifi/rtl8192ee/dm.h       | 13 ---------
 drivers/net/wireless/rtlwifi/rtl8192se/dm.c       |  1 +
 drivers/net/wireless/rtlwifi/rtl8192se/dm.h       | 19 -------------
 drivers/net/wireless/rtlwifi/rtl8723ae/dm.c       |  1 +
 drivers/net/wireless/rtlwifi/rtl8723ae/dm.h       | 22 ---------------
 drivers/net/wireless/rtlwifi/rtl8723be/dm.c       |  1 +
 drivers/net/wireless/rtlwifi/rtl8723be/dm.h       | 22 ---------------
 drivers/net/wireless/rtlwifi/rtl8821ae/dm.c       |  1 +
 drivers/net/wireless/rtlwifi/rtl8821ae/dm.h       | 16 -----------
 20 files changed, 67 insertions(+), 171 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/core.c b/drivers/net/wireless/rtlwifi/core.c
index deab852..5aa3ab3 100644
--- a/drivers/net/wireless/rtlwifi/core.c
+++ b/drivers/net/wireless/rtlwifi/core.c
@@ -1871,3 +1871,37 @@ bool rtl_btc_status_false(void)
 	return false;
 }
 EXPORT_SYMBOL_GPL(rtl_btc_status_false);
+
+void rtl_dm_diginit(struct ieee80211_hw *hw, u32 cur_igvalue)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct dig_t *dm_digtable = &rtlpriv->dm_digtable;
+
+	dm_digtable->dig_enable_flag = true;
+	dm_digtable->cur_igvalue = cur_igvalue;
+	dm_digtable->pre_igvalue = 0;
+	dm_digtable->cur_sta_cstate = DIG_STA_DISCONNECT;
+	dm_digtable->presta_cstate = DIG_STA_DISCONNECT;
+	dm_digtable->curmultista_cstate = DIG_MULTISTA_DISCONNECT;
+	dm_digtable->rssi_lowthresh = DM_DIG_THRESH_LOW;
+	dm_digtable->rssi_highthresh = DM_DIG_THRESH_HIGH;
+	dm_digtable->fa_lowthresh = DM_FALSEALARM_THRESH_LOW;
+	dm_digtable->fa_highthresh = DM_FALSEALARM_THRESH_HIGH;
+	dm_digtable->rx_gain_max = DM_DIG_MAX;
+	dm_digtable->rx_gain_min = DM_DIG_MIN;
+	dm_digtable->back_val = DM_DIG_BACKOFF_DEFAULT;
+	dm_digtable->back_range_max = DM_DIG_BACKOFF_MAX;
+	dm_digtable->back_range_min = DM_DIG_BACKOFF_MIN;
+	dm_digtable->pre_cck_cca_thres = 0xff;
+	dm_digtable->cur_cck_cca_thres = 0x83;
+	dm_digtable->forbidden_igi = DM_DIG_MIN;
+	dm_digtable->large_fa_hit = 0;
+	dm_digtable->recover_cnt = 0;
+	dm_digtable->dig_min_0 = 0x25;
+	dm_digtable->dig_min_1 = 0x25;
+	dm_digtable->media_connect_0 = false;
+	dm_digtable->media_connect_1 = false;
+	rtlpriv->dm.dm_initialgain_enable = true;
+	dm_digtable->bt30_cur_igi = 0x32;
+}
+EXPORT_SYMBOL(rtl_dm_diginit);
diff --git a/drivers/net/wireless/rtlwifi/core.h b/drivers/net/wireless/rtlwifi/core.h
index 8c87eb5..c0a0317 100644
--- a/drivers/net/wireless/rtlwifi/core.h
+++ b/drivers/net/wireless/rtlwifi/core.h
@@ -35,6 +35,29 @@
 
 #define RTL_SUPPORTED_CTRL_FILTER	0xFF
 
+#define DM_DIG_THRESH_HIGH		40
+#define DM_DIG_THRESH_LOW		35
+#define DM_FALSEALARM_THRESH_LOW	400
+#define DM_FALSEALARM_THRESH_HIGH	1000
+
+#define DM_DIG_MAX			0x3e
+#define DM_DIG_MIN			0x1e
+#define DM_DIG_BACKOFF_MAX		12
+#define DM_DIG_BACKOFF_MIN		-4
+#define DM_DIG_BACKOFF_DEFAULT		10
+
+enum dm_dig_connect_e {
+	DIG_STA_DISCONNECT,
+	DIG_STA_CONNECT,
+	DIG_STA_BEFORE_CONNECT,
+	DIG_MULTISTA_DISCONNECT,
+	DIG_MULTISTA_CONNECT,
+	DIG_AP_DISCONNECT,
+	DIG_AP_CONNECT,
+	DIG_AP_ADD_STATION,
+	DIG_CONNECT_MAX
+};
+
 extern const struct ieee80211_ops rtl_ops;
 void rtl_fw_cb(const struct firmware *firmware, void *context);
 void rtl_wowlan_fw_cb(const struct firmware *firmware, void *context);
@@ -44,5 +67,6 @@ void rtl_rfreg_delay(struct ieee80211_hw *hw, enum radio_path rfpath, u32 addr,
 void rtl_bb_delay(struct ieee80211_hw *hw, u32 addr, u32 data);
 bool rtl_cmd_send_packet(struct ieee80211_hw *hw, struct sk_buff *skb);
 bool rtl_btc_status_false(void);
+void rtl_dm_diginit(struct ieee80211_hw *hw, u32 cur_igval);
 
 #endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/dm.c b/drivers/net/wireless/rtlwifi/rtl8188ee/dm.c
index 2aa34d9..7ebf6e0 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/dm.c
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/dm.c
@@ -26,6 +26,7 @@
 #include "../wifi.h"
 #include "../base.h"
 #include "../pci.h"
+#include "../core.h"
 #include "reg.h"
 #include "def.h"
 #include "phy.h"
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/dm.h b/drivers/net/wireless/rtlwifi/rtl8188ee/dm.h
index 64f1f3ea..6217b7c 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/dm.h
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/dm.h
@@ -186,15 +186,6 @@
 #define BW_AUTO_SWITCH_HIGH_LOW				25
 #define BW_AUTO_SWITCH_LOW_HIGH				30
 
-#define DM_DIG_THRESH_HIGH				40
-#define DM_DIG_THRESH_LOW				35
-
-#define DM_FALSEALARM_THRESH_LOW			400
-#define DM_FALSEALARM_THRESH_HIGH			1000
-
-#define DM_DIG_MAX					0x3e
-#define DM_DIG_MIN					0x1e
-
 #define DM_DIG_MAX_AP					0x32
 #define DM_DIG_MIN_AP					0x20
 
@@ -204,10 +195,6 @@
 #define DM_DIG_FA_TH1					0x300
 #define DM_DIG_FA_TH2					0x400
 
-#define DM_DIG_BACKOFF_MAX				12
-#define DM_DIG_BACKOFF_MIN				-4
-#define DM_DIG_BACKOFF_DEFAULT				10
-
 #define RXPATHSELECTION_SS_TH_W				30
 #define RXPATHSELECTION_DIFF_TH				18
 
@@ -296,15 +283,6 @@ enum dm_dig_ext_port_alg_e {
 	DIG_EXT_PORT_STAGE_MAX = 4,
 };
 
-enum dm_dig_connect_e {
-	DIG_STA_DISCONNECT = 0,
-	DIG_STA_CONNECT = 1,
-	DIG_STA_BEFORE_CONNECT = 2,
-	DIG_MULTISTA_DISCONNECT = 3,
-	DIG_MULTISTA_CONNECT = 4,
-	DIG_CONNECT_MAX
-};
-
 enum pwr_track_control_method {
 	BBSWING,
 	TXAGC
diff --git a/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c b/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c
index c3aad76..dabe18f 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c
@@ -32,6 +32,7 @@
 #include "phy_common.h"
 #include "../pci.h"
 #include "../base.h"
+#include "../core.h"
 
 #define BT_RSSI_STATE_NORMAL_POWER	BIT_OFFSET_LEN_MASK_32(0, 1)
 #define BT_RSSI_STATE_AMDPU_OFF		BIT_OFFSET_LEN_MASK_32(1, 1)
diff --git a/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.h b/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.h
index 4f232a0..55ebffd 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.h
@@ -47,25 +47,12 @@
 #define BW_AUTO_SWITCH_HIGH_LOW			25
 #define BW_AUTO_SWITCH_LOW_HIGH			30
 
-#define DM_DIG_THRESH_HIGH			40
-#define DM_DIG_THRESH_LOW			35
-
-#define DM_FALSEALARM_THRESH_LOW		400
-#define DM_FALSEALARM_THRESH_HIGH		1000
-
-#define DM_DIG_MAX				0x3e
-#define DM_DIG_MIN				0x1e
-
 #define DM_DIG_FA_UPPER				0x32
 #define DM_DIG_FA_LOWER				0x20
 #define DM_DIG_FA_TH0				0x20
 #define DM_DIG_FA_TH1				0x100
 #define DM_DIG_FA_TH2				0x200
 
-#define DM_DIG_BACKOFF_MAX			12
-#define DM_DIG_BACKOFF_MIN			-4
-#define DM_DIG_BACKOFF_DEFAULT			10
-
 #define RXPATHSELECTION_SS_TH_lOW		30
 #define RXPATHSELECTION_DIFF_TH			18
 
@@ -157,15 +144,6 @@ enum dm_dig_ext_port_alg_e {
 	DIG_EXT_PORT_STAGE_MAX = 4,
 };
 
-enum dm_dig_connect_e {
-	DIG_STA_DISCONNECT = 0,
-	DIG_STA_CONNECT = 1,
-	DIG_STA_BEFORE_CONNECT = 2,
-	DIG_MULTISTA_DISCONNECT = 3,
-	DIG_MULTISTA_CONNECT = 4,
-	DIG_CONNECT_MAX
-};
-
 void rtl92c_dm_init(struct ieee80211_hw *hw);
 void rtl92c_dm_watchdog(struct ieee80211_hw *hw);
 void rtl92c_dm_write_dig(struct ieee80211_hw *hw);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/dm.c b/drivers/net/wireless/rtlwifi/rtl8192ce/dm.c
index 74f9c08..09898cf 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/dm.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/dm.c
@@ -30,6 +30,7 @@
 #include "../wifi.h"
 #include "../base.h"
 #include "../pci.h"
+#include "../core.h"
 #include "reg.h"
 #include "def.h"
 #include "phy.h"
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/dm.h b/drivers/net/wireless/rtlwifi/rtl8192ce/dm.h
index 9c5311c..38ba707 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/dm.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/dm.h
@@ -42,25 +42,12 @@
 #define BW_AUTO_SWITCH_HIGH_LOW			25
 #define BW_AUTO_SWITCH_LOW_HIGH			30
 
-#define DM_DIG_THRESH_HIGH			40
-#define DM_DIG_THRESH_LOW			35
-
-#define DM_FALSEALARM_THRESH_LOW		400
-#define DM_FALSEALARM_THRESH_HIGH		1000
-
-#define DM_DIG_MAX				0x3e
-#define DM_DIG_MIN				0x1e
-
 #define DM_DIG_FA_UPPER				0x32
 #define DM_DIG_FA_LOWER				0x20
 #define DM_DIG_FA_TH0				0x20
 #define DM_DIG_FA_TH1				0x100
 #define DM_DIG_FA_TH2				0x200
 
-#define DM_DIG_BACKOFF_MAX			12
-#define DM_DIG_BACKOFF_MIN			-4
-#define DM_DIG_BACKOFF_DEFAULT			10
-
 #define RXPATHSELECTION_SS_TH_lOW		30
 #define RXPATHSELECTION_DIFF_TH			18
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/dm.c b/drivers/net/wireless/rtlwifi/rtl8192de/dm.c
index 304c443..75643ab 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/dm.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/dm.c
@@ -29,6 +29,7 @@
 
 #include "../wifi.h"
 #include "../base.h"
+#include "../core.h"
 #include "reg.h"
 #include "def.h"
 #include "phy.h"
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/dm.h b/drivers/net/wireless/rtlwifi/rtl8192de/dm.h
index 3fea0c1..d21b3bc 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/dm.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/dm.h
@@ -42,25 +42,12 @@
 #define BW_AUTO_SWITCH_HIGH_LOW			25
 #define BW_AUTO_SWITCH_LOW_HIGH			30
 
-#define DM_DIG_THRESH_HIGH			40
-#define DM_DIG_THRESH_LOW			35
-
-#define DM_FALSEALARM_THRESH_LOW		400
-#define DM_FALSEALARM_THRESH_HIGH		1000
-
-#define DM_DIG_MAX				0x3e
-#define DM_DIG_MIN				0x1c
-
 #define DM_DIG_FA_UPPER				0x32
 #define DM_DIG_FA_LOWER				0x20
 #define DM_DIG_FA_TH0				0x100
 #define DM_DIG_FA_TH1				0x400
 #define DM_DIG_FA_TH2				0x600
 
-#define DM_DIG_BACKOFF_MAX			12
-#define DM_DIG_BACKOFF_MIN			-4
-#define DM_DIG_BACKOFF_DEFAULT			10
-
 #define RXPATHSELECTION_SS_TH_lOW		30
 #define RXPATHSELECTION_DIFF_TH			18
 
@@ -142,15 +129,6 @@ enum dm_dig_ext_port_alg {
 	DIG_EXT_PORT_STAGE_MAX = 4,
 };
 
-enum dm_dig_connect {
-	DIG_STA_DISCONNECT = 0,
-	DIG_STA_CONNECT = 1,
-	DIG_STA_BEFORE_CONNECT = 2,
-	DIG_MULTISTA_DISCONNECT = 3,
-	DIG_MULTISTA_CONNECT = 4,
-	DIG_CONNECT_MAX
-};
-
 void rtl92d_dm_init(struct ieee80211_hw *hw);
 void rtl92d_dm_watchdog(struct ieee80211_hw *hw);
 void rtl92d_dm_init_edca_turbo(struct ieee80211_hw *hw);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ee/dm.c b/drivers/net/wireless/rtlwifi/rtl8192ee/dm.c
index 2fa4c45..70e58d1 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ee/dm.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ee/dm.c
@@ -26,6 +26,7 @@
 #include "../wifi.h"
 #include "../base.h"
 #include "../pci.h"
+#include "../core.h"
 #include "reg.h"
 #include "def.h"
 #include "phy.h"
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ee/dm.h b/drivers/net/wireless/rtlwifi/rtl8192ee/dm.h
index 881db7d..4880e19 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ee/dm.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192ee/dm.h
@@ -189,15 +189,6 @@
 #define BW_AUTO_SWITCH_HIGH_LOW			25
 #define BW_AUTO_SWITCH_LOW_HIGH			30
 
-#define DM_DIG_THRESH_HIGH			40
-#define DM_DIG_THRESH_LOW			35
-
-#define DM_FALSEALARM_THRESH_LOW		400
-#define DM_FALSEALARM_THRESH_HIGH		1000
-
-#define DM_DIG_MAX				0x3e
-#define DM_DIG_MIN				0x1e
-
 #define DM_DIG_MAX_AP				0x32
 #define DM_DIG_MIN_AP				0x20
 
@@ -207,10 +198,6 @@
 #define DM_DIG_FA_TH1				0x300
 #define DM_DIG_FA_TH2				0x400
 
-#define DM_DIG_BACKOFF_MAX			12
-#define DM_DIG_BACKOFF_MIN			-4
-#define DM_DIG_BACKOFF_DEFAULT			10
-
 #define RXPATHSELECTION_SS_TH_LOW		30
 #define RXPATHSELECTION_DIFF_TH			18
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/dm.c b/drivers/net/wireless/rtlwifi/rtl8192se/dm.c
index b3a2d5e..6cac70b 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/dm.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/dm.c
@@ -29,6 +29,7 @@
 
 #include "../wifi.h"
 #include "../base.h"
+#include "../core.h"
 #include "reg.h"
 #include "def.h"
 #include "phy.h"
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/dm.h b/drivers/net/wireless/rtlwifi/rtl8192se/dm.h
index 2e9052c..7d778d3 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/dm.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/dm.h
@@ -54,16 +54,6 @@ enum dm_dig_sta {
 	DM_STA_DIG_MAX
 };
 
-enum dm_dig_connect {
-	DIG_STA_DISCONNECT = 0,
-	DIG_STA_CONNECT = 1,
-	DIG_STA_BEFORE_CONNECT = 2,
-	DIG_AP_DISCONNECT = 3,
-	DIG_AP_CONNECT = 4,
-	DIG_AP_ADD_STATION = 5,
-	DIG_CONNECT_MAX
-};
-
 enum dm_dig_ext_port_alg {
 	DIG_EXT_PORT_STAGE_0 = 0,
 	DIG_EXT_PORT_STAGE_1 = 1,
@@ -99,22 +89,13 @@ enum dm_ratr_sta {
 #define	TX_POWER_NEAR_FIELD_THRESH_LVL2	74
 #define	TX_POWER_NEAR_FIELD_THRESH_LVL1	67
 
-#define DM_DIG_THRESH_HIGH		40
-#define DM_DIG_THRESH_LOW		35
-#define	DM_FALSEALARM_THRESH_LOW	40
-#define	DM_FALSEALARM_THRESH_HIGH	1000
 #define	DM_DIG_HIGH_PWR_THRESH_HIGH	75
 #define	DM_DIG_HIGH_PWR_THRESH_LOW	70
 #define	DM_DIG_BACKOFF			12
-#define	DM_DIG_MAX			0x3e
-#define	DM_DIG_MIN			0x1c
 #define	DM_DIG_MIN_Netcore		0x12
-#define	DM_DIG_BACKOFF_MAX		12
-#define	DM_DIG_BACKOFF_MIN		-4
 
 void rtl92s_dm_watchdog(struct ieee80211_hw *hw);
 void rtl92s_dm_init(struct ieee80211_hw *hw);
 void rtl92s_dm_init_edca_turbo(struct ieee80211_hw *hw);
 
 #endif
-
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/dm.c b/drivers/net/wireless/rtlwifi/rtl8723ae/dm.c
index a0e8692..80f4c54 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/dm.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/dm.c
@@ -26,6 +26,7 @@
 #include "../wifi.h"
 #include "../base.h"
 #include "../pci.h"
+#include "../core.h"
 #include "reg.h"
 #include "def.h"
 #include "phy.h"
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/dm.h b/drivers/net/wireless/rtlwifi/rtl8723ae/dm.h
index 6fa0feb..c54024e 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/dm.h
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/dm.h
@@ -42,25 +42,12 @@
 #define BW_AUTO_SWITCH_HIGH_LOW			25
 #define BW_AUTO_SWITCH_LOW_HIGH			30
 
-#define DM_DIG_THRESH_HIGH			40
-#define DM_DIG_THRESH_LOW			35
-
-#define DM_FALSEALARM_THRESH_LOW		400
-#define DM_FALSEALARM_THRESH_HIGH		1000
-
-#define DM_DIG_MAX				0x3e
-#define DM_DIG_MIN				0x1e
-
 #define DM_DIG_FA_UPPER				0x32
 #define DM_DIG_FA_LOWER				0x20
 #define DM_DIG_FA_TH0				0x20
 #define DM_DIG_FA_TH1				0x100
 #define DM_DIG_FA_TH2				0x200
 
-#define DM_DIG_BACKOFF_MAX			12
-#define DM_DIG_BACKOFF_MIN			-4
-#define DM_DIG_BACKOFF_DEFAULT			10
-
 #define RXPATHSELECTION_SS_TH_LOW		30
 #define RXPATHSELECTION_DIFF_TH			18
 
@@ -142,15 +129,6 @@ enum dm_dig_ext_port_alg_e {
 	DIG_EXT_PORT_STAGE_MAX = 4,
 };
 
-enum dm_dig_connect_e {
-	DIG_STA_DISCONNECT = 0,
-	DIG_STA_CONNECT = 1,
-	DIG_STA_BEFORE_CONNECT = 2,
-	DIG_MULTISTA_DISCONNECT = 3,
-	DIG_MULTISTA_CONNECT = 4,
-	DIG_CONNECT_MAX
-};
-
 #define BT_RSSI_STATE_NORMAL_POWER      BIT_OFFSET_LEN_MASK_32(0, 1)
 #define BT_RSSI_STATE_AMDPU_OFF         BIT_OFFSET_LEN_MASK_32(1, 1)
 #define BT_RSSI_STATE_SPECIAL_LOW       BIT_OFFSET_LEN_MASK_32(2, 1)
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/dm.c b/drivers/net/wireless/rtlwifi/rtl8723be/dm.c
index b92c521e..ddf45d9 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/dm.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/dm.c
@@ -26,6 +26,7 @@
 #include "../wifi.h"
 #include "../base.h"
 #include "../pci.h"
+#include "../core.h"
 #include "reg.h"
 #include "def.h"
 #include "phy.h"
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/dm.h b/drivers/net/wireless/rtlwifi/rtl8723be/dm.h
index e4c0e8a..f3e47ab 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/dm.h
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/dm.h
@@ -180,15 +180,6 @@
 #define BW_AUTO_SWITCH_HIGH_LOW			25
 #define BW_AUTO_SWITCH_LOW_HIGH			30
 
-#define DM_DIG_THRESH_HIGH			40
-#define DM_DIG_THRESH_LOW			35
-
-#define DM_FALSEALARM_THRESH_LOW		400
-#define DM_FALSEALARM_THRESH_HIGH		1000
-
-#define DM_DIG_MAX				0x3e
-#define DM_DIG_MIN				0x1e
-
 #define DM_DIG_MAX_AP				0x32
 #define DM_DIG_MIN_AP				0x20
 
@@ -198,10 +189,6 @@
 #define DM_DIG_FA_TH1				0x300
 #define DM_DIG_FA_TH2				0x400
 
-#define DM_DIG_BACKOFF_MAX			12
-#define DM_DIG_BACKOFF_MIN			-4
-#define DM_DIG_BACKOFF_DEFAULT			10
-
 #define RXPATHSELECTION_SS_TH_LOW		30
 #define RXPATHSELECTION_DIFF_TH			18
 
@@ -260,15 +247,6 @@ enum dm_dig_ext_port_alg_e {
 	DIG_EXT_PORT_STAGE_MAX	= 4,
 };
 
-enum dm_dig_connect_e {
-	DIG_STA_DISCONNECT	= 0,
-	DIG_STA_CONNECT		= 1,
-	DIG_STA_BEFORE_CONNECT	= 2,
-	DIG_MULTISTA_DISCONNECT	= 3,
-	DIG_MULTISTA_CONNECT	= 4,
-	DIG_CONNECT_MAX
-};
-
 enum pwr_track_control_method {
 	BBSWING,
 	TXAGC
diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/dm.c b/drivers/net/wireless/rtlwifi/rtl8821ae/dm.c
index 8b0bfb2..4af4613 100644
--- a/drivers/net/wireless/rtlwifi/rtl8821ae/dm.c
+++ b/drivers/net/wireless/rtlwifi/rtl8821ae/dm.c
@@ -26,6 +26,7 @@
 #include "../wifi.h"
 #include "../base.h"
 #include "../pci.h"
+#include "../core.h"
 #include "reg.h"
 #include "def.h"
 #include "phy.h"
diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/dm.h b/drivers/net/wireless/rtlwifi/rtl8821ae/dm.h
index 9dd40dd..f311887 100644
--- a/drivers/net/wireless/rtlwifi/rtl8821ae/dm.h
+++ b/drivers/net/wireless/rtlwifi/rtl8821ae/dm.h
@@ -187,9 +187,6 @@
 #define BW_AUTO_SWITCH_HIGH_LOW		25
 #define BW_AUTO_SWITCH_LOW_HIGH		30
 
-#define DM_DIG_THRESH_HIGH			40
-#define DM_DIG_THRESH_LOW			35
-
 #define DM_FALSEALARM_THRESH_LOW	400
 #define DM_FALSEALARM_THRESH_HIGH	1000
 
@@ -205,10 +202,6 @@
 #define DM_DIG_FA_TH1				0x300
 #define DM_DIG_FA_TH2				0x400
 
-#define DM_DIG_BACKOFF_MAX			12
-#define DM_DIG_BACKOFF_MIN			-4
-#define DM_DIG_BACKOFF_DEFAULT		10
-
 #define RXPATHSELECTION_SS_TH_LOW	30
 #define RXPATHSELECTION_DIFF_TH		18
 
@@ -296,15 +289,6 @@ enum dm_dig_ext_port_alg_e {
 	DIG_EXT_PORT_STAGE_MAX = 4,
 };
 
-enum dm_dig_connect_e {
-	DIG_STA_DISCONNECT = 0,
-	DIG_STA_CONNECT = 1,
-	DIG_STA_BEFORE_CONNECT = 2,
-	DIG_MULTISTA_DISCONNECT = 3,
-	DIG_MULTISTA_CONNECT = 4,
-	DIG_CONNECT_MAX
-};
-
 enum pwr_track_control_method {
 	BBSWING,
 	TXAGC,
-- 
2.1.2
