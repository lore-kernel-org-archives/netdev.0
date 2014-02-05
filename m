From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 07/16] rtlwifi: rtl8723ae: rtl8723-common: Copy common dynamic power management code
Date: Wed,  5 Feb 2014 13:54:51 -0600
Message-ID: <1391630100-13504-8-git-send-email-Larry.Finger@lwfinger.net>
References: <1391630100-13504-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f49.google.com ([209.85.219.49]:59536 "EHLO
	mail-oa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752575AbaBETzd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Feb 2014 14:55:33 -0500
In-Reply-To: <1391630100-13504-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The drivers for RTL8723AE and RTL8723BE have some code in common.
This commit copies the common power management routines into the shared
code.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/rtlwifi/rtl8723ae/dm.c        | 42 ++------------
 drivers/net/wireless/rtlwifi/rtl8723ae/dm.h        |  1 -
 drivers/net/wireless/rtlwifi/rtl8723ae/hw.c        |  5 +-
 drivers/net/wireless/rtlwifi/rtl8723com/Makefile   |  1 +
 .../net/wireless/rtlwifi/rtl8723com/dm_common.c    | 65 ++++++++++++++++++++++
 .../net/wireless/rtlwifi/rtl8723com/dm_common.h    | 33 +++++++++++
 6 files changed, 106 insertions(+), 41 deletions(-)
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723com/dm_common.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723com/dm_common.h

diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/dm.c b/drivers/net/wireless/rtlwifi/rtl8723ae/dm.c
index a36eee2..863ddb3 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/dm.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/dm.c
@@ -35,6 +35,7 @@
 #include "def.h"
 #include "phy.h"
 #include "dm.h"
+#include "../rtl8723com/dm_common.h"
 #include "fw.h"
 #include "hal_btc.h"
 
@@ -483,16 +484,6 @@ static void rtl8723ae_dm_dig(struct ieee80211_hw *hw)
 	rtl8723ae_dm_ctrl_initgain_by_twoport(hw);
 }
 
-static void rtl8723ae_dm_init_dynamic_txpower(struct ieee80211_hw *hw)
-{
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-
-	rtlpriv->dm.dynamic_txpower_enable = false;
-
-	rtlpriv->dm.last_dtp_lvl = TXHIGHPWRLEVEL_NORMAL;
-	rtlpriv->dm.dynamic_txhighpower_lvl = TXHIGHPWRLEVEL_NORMAL;
-}
-
 static void rtl8723ae_dm_dynamic_txpower(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
@@ -585,19 +576,6 @@ void rtl8723ae_dm_write_dig(struct ieee80211_hw *hw)
 	}
 }
 
-static void rtl8723ae_dm_pwdmonitor(struct ieee80211_hw *hw)
-{
-}
-
-void rtl8723ae_dm_init_edca_turbo(struct ieee80211_hw *hw)
-{
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-
-	rtlpriv->dm.current_turbo_edca = false;
-	rtlpriv->dm.is_any_nonbepkts = false;
-	rtlpriv->dm.is_cur_rdlstate = false;
-}
-
 static void rtl8723ae_dm_check_edca_turbo(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
@@ -778,17 +756,6 @@ static void rtl8723ae_dm_refresh_rate_adaptive_mask(struct ieee80211_hw *hw)
 	}
 }
 
-static void rtl8723ae_dm_init_dynamic_bpowersaving(struct ieee80211_hw *hw)
-{
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-
-	rtlpriv->dm_pstable.pre_ccastate = CCA_MAX;
-	rtlpriv->dm_pstable.cur_ccasate = CCA_MAX;
-	rtlpriv->dm_pstable.pre_rfstate = RF_MAX;
-	rtlpriv->dm_pstable.cur_rfstate = RF_MAX;
-	rtlpriv->dm_pstable.rssi_val_min = 0;
-}
-
 void rtl8723ae_dm_rf_saving(struct ieee80211_hw *hw, u8 force_in_normal)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
@@ -905,11 +872,11 @@ void rtl8723ae_dm_init(struct ieee80211_hw *hw)
 
 	rtlpriv->dm.dm_type = DM_TYPE_BYDRIVER;
 	rtl8723ae_dm_diginit(hw);
-	rtl8723ae_dm_init_dynamic_txpower(hw);
-	rtl8723ae_dm_init_edca_turbo(hw);
+	rtl8723_dm_init_dynamic_txpower(hw);
+	rtl8723_dm_init_edca_turbo(hw);
 	rtl8723ae_dm_init_rate_adaptive_mask(hw);
 	rtl8723ae_dm_initialize_txpower_tracking(hw);
-	rtl8723ae_dm_init_dynamic_bpowersaving(hw);
+	rtl8723_dm_init_dynamic_bb_powersaving(hw);
 }
 
 void rtl8723ae_dm_watchdog(struct ieee80211_hw *hw)
@@ -930,7 +897,6 @@ void rtl8723ae_dm_watchdog(struct ieee80211_hw *hw)
 	if ((ppsc->rfpwr_state == ERFON) &&
 	    ((!fw_current_inpsmode) && fw_ps_awake) &&
 	    (!ppsc->rfchange_inprogress)) {
-		rtl8723ae_dm_pwdmonitor(hw);
 		rtl8723ae_dm_dig(hw);
 		rtl8723ae_dm_false_alarm_counter_statistics(hw);
 		rtl8723ae_dm_dynamic_bpowersaving(hw);
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/dm.h b/drivers/net/wireless/rtlwifi/rtl8723ae/dm.h
index a372b02..d253bb5 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/dm.h
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/dm.h
@@ -147,7 +147,6 @@ enum dm_dig_connect_e {
 void rtl8723ae_dm_init(struct ieee80211_hw *hw);
 void rtl8723ae_dm_watchdog(struct ieee80211_hw *hw);
 void rtl8723ae_dm_write_dig(struct ieee80211_hw *hw);
-void rtl8723ae_dm_init_edca_turbo(struct ieee80211_hw *hw);
 void rtl8723ae_dm_init_rate_adaptive_mask(struct ieee80211_hw *hw);
 void rtl8723ae_dm_rf_saving(struct ieee80211_hw *hw, u8 bforce_in_normal);
 void rtl8723ae_dm_bt_coexist(struct ieee80211_hw *hw);
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/hw.c b/drivers/net/wireless/rtlwifi/rtl8723ae/hw.c
index b8bce94..763f2f8 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/hw.c
@@ -38,6 +38,7 @@
 #include "def.h"
 #include "phy.h"
 #include "dm.h"
+#include "../rtl8723com/dm_common.h"
 #include "fw.h"
 #include "../rtl8723com/fw_common.h"
 #include "led.h"
@@ -305,7 +306,7 @@ void rtl8723ae_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		break; }
 	case HW_VAR_AC_PARAM:{
 		u8 e_aci = *((u8 *) val);
-		rtl8723ae_dm_init_edca_turbo(hw);
+		rtl8723_dm_init_edca_turbo(hw);
 
 		if (rtlpci->acm_method != EACMWAY2_SW)
 			rtlpriv->cfg->ops->set_hw_reg(hw,
@@ -1154,7 +1155,7 @@ void rtl8723ae_set_qos(struct ieee80211_hw *hw, int aci)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
-	rtl8723ae_dm_init_edca_turbo(hw);
+	rtl8723_dm_init_edca_turbo(hw);
 	switch (aci) {
 	case AC1_BK:
 		rtl_write_dword(rtlpriv, REG_EDCA_BK_PARAM, 0xa44f);
diff --git a/drivers/net/wireless/rtlwifi/rtl8723com/Makefile b/drivers/net/wireless/rtlwifi/rtl8723com/Makefile
index 97c7eac..345a68a 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723com/Makefile
+++ b/drivers/net/wireless/rtlwifi/rtl8723com/Makefile
@@ -1,5 +1,6 @@
 rtl8723-common-objs :=		\
 		main.o		\
+		dm_common.o	\
 		fw_common.o	\
 		phy_common.o
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8723com/dm_common.c b/drivers/net/wireless/rtlwifi/rtl8723com/dm_common.c
new file mode 100644
index 0000000..4e254b7
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/rtl8723com/dm_common.c
@@ -0,0 +1,65 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2014  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae@realtek.com>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Park,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger@lwfinger.net>
+ *
+ *****************************************************************************/
+
+#include "../wifi.h"
+#include "dm_common.h"
+#include "../rtl8723ae/dm.h"
+#include <linux/module.h>
+
+/* These routines are common to RTL8723AE and RTL8723bE */
+
+void rtl8723_dm_init_dynamic_txpower(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+
+	rtlpriv->dm.dynamic_txpower_enable = false;
+
+	rtlpriv->dm.last_dtp_lvl = TXHIGHPWRLEVEL_NORMAL;
+	rtlpriv->dm.dynamic_txhighpower_lvl = TXHIGHPWRLEVEL_NORMAL;
+}
+EXPORT_SYMBOL_GPL(rtl8723_dm_init_dynamic_txpower);
+
+void rtl8723_dm_init_edca_turbo(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+
+	rtlpriv->dm.current_turbo_edca = false;
+	rtlpriv->dm.is_any_nonbepkts = false;
+	rtlpriv->dm.is_cur_rdlstate = false;
+}
+EXPORT_SYMBOL_GPL(rtl8723_dm_init_edca_turbo);
+
+void rtl8723_dm_init_dynamic_bb_powersaving(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+
+	rtlpriv->dm_pstable.pre_ccastate = CCA_MAX;
+	rtlpriv->dm_pstable.cur_ccasate = CCA_MAX;
+	rtlpriv->dm_pstable.pre_rfstate = RF_MAX;
+	rtlpriv->dm_pstable.cur_rfstate = RF_MAX;
+	rtlpriv->dm_pstable.rssi_val_min = 0;
+	rtlpriv->dm_pstable.initialize = 0;
+}
+EXPORT_SYMBOL_GPL(rtl8723_dm_init_dynamic_bb_powersaving);
diff --git a/drivers/net/wireless/rtlwifi/rtl8723com/dm_common.h b/drivers/net/wireless/rtlwifi/rtl8723com/dm_common.h
new file mode 100644
index 0000000..5c1b94c
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/rtl8723com/dm_common.h
@@ -0,0 +1,33 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2014  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae@realtek.com>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Park,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger@lwfinger.net>
+ *
+ *****************************************************************************/
+
+#ifndef __DM_COMMON_H__
+#define __DM_COMMON_H__
+
+void rtl8723_dm_init_dynamic_txpower(struct ieee80211_hw *hw);
+void rtl8723_dm_init_edca_turbo(struct ieee80211_hw *hw);
+void rtl8723_dm_init_dynamic_bb_powersaving(struct ieee80211_hw *hw);
+
+#endif
-- 
1.8.4
