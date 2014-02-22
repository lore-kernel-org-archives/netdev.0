From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 03/16 V2] rtlwifi: btcoexist: Add source for new mini driver - part 2
Date: Sat, 22 Feb 2014 11:16:59 -0600
Message-ID: <1393089433-28270-4-git-send-email-Larry.Finger@lwfinger.net>
References: <1393089433-28270-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:61590 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751896AbaBVRRY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Feb 2014 12:17:24 -0500
In-Reply-To: <1393089433-28270-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A new driver in the rtlwifi family for the RTL8723BE will soon be added.
The bluetooth coexistence code for this device has been split into a separate
mini driver as it will be shared with other devices. This commit adds the
rest of the sources, and modifies Kconfig and Makefile to configure and
build this driver.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/rtlwifi/Kconfig               |    8 +-
 drivers/net/wireless/rtlwifi/Makefile              |    1 +
 drivers/net/wireless/rtlwifi/btcoexist/Makefile    |    7 +
 .../net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c  | 1011 ++++++++++++++++++++
 drivers/net/wireless/rtlwifi/btcoexist/rtl_btc.c   |  218 +++++
 .../net/wireless/rtlwifi/rtl8723com/fw_common.c    |  849 ++++++++++++++++
 .../net/wireless/rtlwifi/rtl8723com/fw_common.h    |   50 +
 .../net/wireless/rtlwifi/rtl8723com/phy_common.h   |   75 ++
 8 files changed, 2218 insertions(+), 1 deletion(-)
 create mode 100644 drivers/net/wireless/rtlwifi/btcoexist/Makefile
 create mode 100644 drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c
 create mode 100644 drivers/net/wireless/rtlwifi/btcoexist/rtl_btc.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723com/fw_common.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723com/fw_common.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723com/phy_common.h

diff --git a/drivers/net/wireless/rtlwifi/Kconfig b/drivers/net/wireless/rtlwifi/Kconfig
index c2ffce7..29c6ce5 100644
--- a/drivers/net/wireless/rtlwifi/Kconfig
+++ b/drivers/net/wireless/rtlwifi/Kconfig
@@ -5,7 +5,7 @@ menuconfig RTL_CARDS
 	---help---
 	  This option will enable support for the Realtek mac80211-based
 	  wireless drivers. Drivers rtl8192ce, rtl8192cu, rtl8192se, rtl8192de,
-	  rtl8723eu, and rtl8188eu share some common code.
+	  rtl8723ae, and rtl8188ae share some common code.
 
 if RTL_CARDS
 
@@ -48,6 +48,7 @@ config RTL8723AE
 	depends on PCI
 	select RTLWIFI
 	select RTLWIFI_PCI
+	select RTLBTCOEXIST
 	---help---
 	This is the driver for Realtek RTL8723AE 802.11n PCIe
 	wireless network adapters.
@@ -101,4 +102,9 @@ config RTL8192C_COMMON
 	depends on RTL8192CE || RTL8192CU
 	default y
 
+config RTLBTCOEXIST
+	tristate
+	depends on RTL8723AE
+	default y
+
 endif
diff --git a/drivers/net/wireless/rtlwifi/Makefile b/drivers/net/wireless/rtlwifi/Makefile
index d56f023..f354c5f 100644
--- a/drivers/net/wireless/rtlwifi/Makefile
+++ b/drivers/net/wireless/rtlwifi/Makefile
@@ -25,5 +25,6 @@ obj-$(CONFIG_RTL8192SE)		+= rtl8192se/
 obj-$(CONFIG_RTL8192DE)		+= rtl8192de/
 obj-$(CONFIG_RTL8723AE)		+= rtl8723ae/
 obj-$(CONFIG_RTL8188EE)		+= rtl8188ee/
+obj-$(CONFIG_RTLBTCOEXIST)	+= btcoexist/
 
 ccflags-y += -D__CHECK_ENDIAN__
diff --git a/drivers/net/wireless/rtlwifi/btcoexist/Makefile b/drivers/net/wireless/rtlwifi/btcoexist/Makefile
new file mode 100644
index 0000000..47ceecf
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/btcoexist/Makefile
@@ -0,0 +1,7 @@
+btcoexist-objs :=	halbtc8723b2ant.o	\
+			halbtcoutsrc.o		\
+			rtl_btc.o
+
+obj-$(CONFIG_RTLBTCOEXIST) += btcoexist.o
+
+ccflags-y += -D__CHECK_ENDIAN__
diff --git a/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c b/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c
new file mode 100644
index 0000000..9e1217f
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c
@@ -0,0 +1,1011 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2007 - 2013 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
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
+ ******************************************************************************/
+
+#include "halbt_precomp.h"
+
+/***********************************************
+ *		Global variables
+ ***********************************************/
+
+struct btc_coexist gl_bt_coexist;
+
+u32 btc_dbg_type[BTC_MSG_MAX];
+static u8 btc_dbg_buf[100];
+
+/***************************************************
+ *		Debug related function
+ ***************************************************/
+static bool halbtc_is_bt_coexist_available(struct btc_coexist *btcoexist)
+{
+	if (!btcoexist->binded || NULL == btcoexist->adapter)
+		return false;
+
+	return true;
+}
+
+static bool halbtc_is_wifi_busy(struct rtl_priv *rtlpriv)
+{
+	if (rtlpriv->link_info.busytraffic)
+		return true;
+	else
+		return false;
+}
+
+static void halbtc_dbg_init(void)
+{
+	u8 i;
+
+	for (i = 0; i < BTC_MSG_MAX; i++)
+		btc_dbg_type[i] = 0;
+
+	btc_dbg_type[BTC_MSG_INTERFACE] =
+/*			INTF_INIT				| */
+/*			INTF_NOTIFY				| */
+			0;
+
+	btc_dbg_type[BTC_MSG_ALGORITHM] =
+/*			ALGO_BT_RSSI_STATE			| */
+/*			ALGO_WIFI_RSSI_STATE			| */
+/*			ALGO_BT_MONITOR				| */
+/*			ALGO_TRACE				| */
+/*			ALGO_TRACE_FW				| */
+/*			ALGO_TRACE_FW_DETAIL			| */
+/*			ALGO_TRACE_FW_EXEC			| */
+/*			ALGO_TRACE_SW				| */
+/*			ALGO_TRACE_SW_DETAIL			| */
+/*			ALGO_TRACE_SW_EXEC			| */
+			0;
+}
+
+static bool halbtc_is_bt40(struct rtl_priv *adapter)
+{
+	struct rtl_priv *rtlpriv = adapter;
+	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	bool is_ht40 = true;
+	enum ht_channel_width bw = rtlphy->current_chan_bw;
+
+	if (bw == HT_CHANNEL_WIDTH_20)
+		is_ht40 = false;
+	else if (bw == HT_CHANNEL_WIDTH_20_40)
+		is_ht40 = true;
+
+	return is_ht40;
+}
+
+static bool halbtc_legacy(struct rtl_priv *adapter)
+{
+	struct rtl_priv *rtlpriv = adapter;
+	struct rtl_mac *mac = rtl_mac(rtlpriv);
+
+	bool is_legacy = false;
+
+	if ((mac->mode == WIRELESS_MODE_B) || (mac->mode == WIRELESS_MODE_B))
+		is_legacy = true;
+
+	return is_legacy;
+}
+
+bool halbtc_is_wifi_uplink(struct rtl_priv *adapter)
+{
+	struct rtl_priv *rtlpriv = adapter;
+
+	if (rtlpriv->link_info.tx_busy_traffic)
+		return true;
+	else
+		return false;
+}
+
+static u32 halbtc_get_wifi_bw(struct btc_coexist *btcoexist)
+{
+	struct rtl_priv *rtlpriv =
+		(struct rtl_priv *)btcoexist->adapter;
+	u32 wifi_bw = BTC_WIFI_BW_HT20;
+
+	if (halbtc_is_bt40(rtlpriv)) {
+		wifi_bw = BTC_WIFI_BW_HT40;
+	} else {
+		if (halbtc_legacy(rtlpriv))
+			wifi_bw = BTC_WIFI_BW_LEGACY;
+		else
+			wifi_bw = BTC_WIFI_BW_HT20;
+	}
+	return wifi_bw;
+}
+
+static u8 halbtc_get_wifi_central_chnl(struct btc_coexist *btcoexist)
+{
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+	struct rtl_phy	*rtlphy = &(rtlpriv->phy);
+	u8 chnl = 1;
+
+	if (rtlphy->current_channel != 0)
+		chnl = rtlphy->current_channel;
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+		  "static halbtc_get_wifi_central_chnl:%d\n", chnl);
+	return chnl;
+}
+
+static void halbtc_leave_lps(struct btc_coexist *btcoexist)
+{
+	struct rtl_priv *rtlpriv;
+	struct rtl_ps_ctl *ppsc;
+	bool ap_enable = false;
+
+	rtlpriv = btcoexist->adapter;
+	ppsc = rtl_psc(rtlpriv);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_AP_MODE_ENABLE,
+			   &ap_enable);
+
+	if (ap_enable) {
+		pr_info("halbtc_leave_lps()<--dont leave lps under AP mode\n");
+		return;
+	}
+
+	btcoexist->bt_info.bt_ctrl_lps = true;
+	btcoexist->bt_info.bt_lps_on = false;
+}
+
+static void halbtc_enter_lps(struct btc_coexist *btcoexist)
+{
+	struct rtl_priv *rtlpriv;
+	struct rtl_ps_ctl *ppsc;
+	bool ap_enable = false;
+
+	rtlpriv = btcoexist->adapter;
+	ppsc = rtl_psc(rtlpriv);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_AP_MODE_ENABLE,
+			   &ap_enable);
+
+	if (ap_enable) {
+		pr_info("halbtc_enter_lps()<--dont enter lps under AP mode\n");
+		return;
+	}
+
+	btcoexist->bt_info.bt_ctrl_lps = true;
+	btcoexist->bt_info.bt_lps_on = false;
+}
+
+static void halbtc_normal_lps(struct btc_coexist *btcoexist)
+{
+	if (btcoexist->bt_info.bt_ctrl_lps) {
+		btcoexist->bt_info.bt_lps_on = false;
+		btcoexist->bt_info.bt_ctrl_lps = false;
+	}
+}
+
+static void halbtc_leave_low_power(void)
+{
+}
+
+static void halbtc_nomal_low_power(void)
+{
+}
+
+static void halbtc_disable_low_power(void)
+{
+}
+
+static void halbtc_aggregation_check(void)
+{
+}
+
+static u32 halbtc_get_bt_patch_version(struct btc_coexist *btcoexist)
+{
+	return 0;
+}
+
+static s32 halbtc_get_wifi_rssi(struct rtl_priv *adapter)
+{
+	struct rtl_priv *rtlpriv = adapter;
+	s32	undec_sm_pwdb = 0;
+
+	if (rtlpriv->mac80211.link_state >= MAC80211_LINKED)
+		undec_sm_pwdb = rtlpriv->dm.undec_sm_pwdb;
+	else /* associated entry pwdb */
+		undec_sm_pwdb = rtlpriv->dm.undec_sm_pwdb;
+	return undec_sm_pwdb;
+}
+
+static bool halbtc_get(void *void_btcoexist, u8 get_type, void *out_buf)
+{
+	struct btc_coexist *btcoexist = (struct btc_coexist *)void_btcoexist;
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_mac *mac = rtl_mac(rtlpriv);
+	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
+	bool *bool_tmp = (bool *)out_buf;
+	int *s32_tmp = (int *)out_buf;
+	u32 *u32_tmp = (u32 *)out_buf;
+	u8 *u8_tmp = (u8 *)out_buf;
+	bool tmp = false;
+
+	if (!halbtc_is_bt_coexist_available(btcoexist))
+		return false;
+
+	switch (get_type) {
+	case BTC_GET_BL_HS_OPERATION:
+		*bool_tmp = false;
+		break;
+	case BTC_GET_BL_HS_CONNECTING:
+		*bool_tmp = false;
+		break;
+	case BTC_GET_BL_WIFI_CONNECTED:
+		if (rtlpriv->mac80211.link_state >= MAC80211_LINKED)
+			tmp = true;
+		*bool_tmp = tmp;
+		break;
+	case BTC_GET_BL_WIFI_BUSY:
+		if (halbtc_is_wifi_busy(rtlpriv))
+			*bool_tmp = true;
+		else
+			*bool_tmp = false;
+		break;
+	case BTC_GET_BL_WIFI_SCAN:
+		if (mac->act_scanning)
+			*bool_tmp = true;
+		else
+			*bool_tmp = false;
+		break;
+	case BTC_GET_BL_WIFI_LINK:
+		if (mac->link_state == MAC80211_LINKING)
+			*bool_tmp = true;
+		else
+			*bool_tmp = false;
+		break;
+	case BTC_GET_BL_WIFI_ROAM:	/*TODO*/
+		if (mac->link_state == MAC80211_LINKING)
+			*bool_tmp = true;
+		else
+			*bool_tmp = false;
+		break;
+	case BTC_GET_BL_WIFI_4_WAY_PROGRESS:	/*TODO*/
+			*bool_tmp = false;
+
+		break;
+	case BTC_GET_BL_WIFI_UNDER_5G:
+		*bool_tmp = false; /*TODO*/
+
+	case BTC_GET_BL_WIFI_DHCP:	/*TODO*/
+		break;
+	case BTC_GET_BL_WIFI_SOFTAP_IDLE:
+		*bool_tmp = true;
+		break;
+	case BTC_GET_BL_WIFI_SOFTAP_LINKING:
+		*bool_tmp = false;
+		break;
+	case BTC_GET_BL_WIFI_IN_EARLY_SUSPEND:
+		*bool_tmp = false;
+		break;
+	case BTC_GET_BL_WIFI_AP_MODE_ENABLE:
+		*bool_tmp = false;
+		break;
+	case BTC_GET_BL_WIFI_ENABLE_ENCRYPTION:
+		if (NO_ENCRYPTION == rtlpriv->sec.pairwise_enc_algorithm)
+			*bool_tmp = false;
+		else
+			*bool_tmp = true;
+		break;
+	case BTC_GET_BL_WIFI_UNDER_B_MODE:
+		*bool_tmp = false; /*TODO*/
+		break;
+	case BTC_GET_BL_EXT_SWITCH:
+		*bool_tmp = false;
+		break;
+	case BTC_GET_S4_WIFI_RSSI:
+		*s32_tmp = halbtc_get_wifi_rssi(rtlpriv);
+		break;
+	case BTC_GET_S4_HS_RSSI:	/*TODO*/
+		*s32_tmp = halbtc_get_wifi_rssi(rtlpriv);
+		break;
+	case BTC_GET_U4_WIFI_BW:
+		*u32_tmp = halbtc_get_wifi_bw(btcoexist);
+		break;
+	case BTC_GET_U4_WIFI_TRAFFIC_DIRECTION:
+		if (halbtc_is_wifi_uplink(rtlpriv))
+			*u32_tmp = BTC_WIFI_TRAFFIC_TX;
+		else
+			*u32_tmp = BTC_WIFI_TRAFFIC_RX;
+		break;
+	case BTC_GET_U4_WIFI_FW_VER:
+		*u32_tmp = rtlhal->fw_version;
+		break;
+	case BTC_GET_U4_BT_PATCH_VER:
+		*u32_tmp = halbtc_get_bt_patch_version(btcoexist);
+		break;
+	case BTC_GET_U1_WIFI_DOT11_CHNL:
+		*u8_tmp = rtlphy->current_channel;
+		break;
+	case BTC_GET_U1_WIFI_CENTRAL_CHNL:
+		*u8_tmp = halbtc_get_wifi_central_chnl(btcoexist);
+		break;
+	case BTC_GET_U1_WIFI_HS_CHNL:
+		*u8_tmp = 1;/*BT_OperateChnl(rtlpriv);*/
+		break;
+	case BTC_GET_U1_MAC_PHY_MODE:
+		*u8_tmp = BTC_MP_UNKNOWN;
+		break;
+
+		/************* 1Ant **************/
+	case BTC_GET_U1_LPS_MODE:
+		*u8_tmp = btcoexist->pwr_mode_val[0];
+		break;
+
+	default:
+		break;
+	}
+
+	return true;
+}
+
+static bool halbtc_set(void *void_btcoexist, u8 set_type, void *in_buf)
+{
+	struct btc_coexist *btcoexist = (struct btc_coexist *)void_btcoexist;
+	bool *bool_tmp = (bool *)in_buf;
+	u8 *u8_tmp = (u8 *)in_buf;
+	u32 *u32_tmp = (u32 *)in_buf;
+
+	if (!halbtc_is_bt_coexist_available(btcoexist))
+		return false;
+
+	switch (set_type) {
+	/* set some bool type variables. */
+	case BTC_SET_BL_BT_DISABLE:
+		btcoexist->bt_info.bt_disabled = *bool_tmp;
+		break;
+	case BTC_SET_BL_BT_TRAFFIC_BUSY:
+		btcoexist->bt_info.bt_busy = *bool_tmp;
+		break;
+	case BTC_SET_BL_BT_LIMITED_DIG:
+		btcoexist->bt_info.limited_dig = *bool_tmp;
+		break;
+	case BTC_SET_BL_FORCE_TO_ROAM:
+		btcoexist->bt_info.force_to_roam = *bool_tmp;
+		break;
+	case BTC_SET_BL_TO_REJ_AP_AGG_PKT:
+		btcoexist->bt_info.reject_agg_pkt = *bool_tmp;
+		break;
+	case BTC_SET_BL_BT_CTRL_AGG_SIZE:
+		btcoexist->bt_info.b_bt_ctrl_buf_size = *bool_tmp;
+		break;
+	case BTC_SET_BL_INC_SCAN_DEV_NUM:
+		btcoexist->bt_info.increase_scan_dev_num = *bool_tmp;
+		break;
+		/* set some u1Byte type variables. */
+	case BTC_SET_U1_RSSI_ADJ_VAL_FOR_AGC_TABLE_ON:
+		btcoexist->bt_info.rssi_adjust_for_agc_table_on = *u8_tmp;
+		break;
+	case BTC_SET_U1_AGG_BUF_SIZE:
+		btcoexist->bt_info.agg_buf_size = *u8_tmp;
+		break;
+		/* the following are some action which will be triggered */
+	case BTC_SET_ACT_GET_BT_RSSI:
+		/*BTHCI_SendGetBtRssiEvent(rtlpriv);*/
+		break;
+	case BTC_SET_ACT_AGGREGATE_CTRL:
+		halbtc_aggregation_check();
+		break;
+
+		/* 1Ant */
+	case BTC_SET_U1_RSSI_ADJ_VAL_FOR_1ANT_COEX_TYPE:
+		btcoexist->bt_info.rssi_adjust_for_1ant_coex_type = *u8_tmp;
+		break;
+	case BTC_SET_UI_SCAN_SIG_COMPENSATION:
+	/*	rtlpriv->mlmepriv.scan_compensation = *u8_tmp;  */
+		break;
+	case BTC_SET_U1_1ANT_LPS:
+		btcoexist->bt_info.lps_1ant = *u8_tmp;
+		break;
+	case BTC_SET_U1_1ANT_RPWM:
+		btcoexist->bt_info.rpwm_1ant = *u8_tmp;
+		break;
+	/* the following are some action which will be triggered  */
+	case BTC_SET_ACT_LEAVE_LPS:
+		halbtc_leave_lps(btcoexist);
+		break;
+	case BTC_SET_ACT_ENTER_LPS:
+		halbtc_enter_lps(btcoexist);
+		break;
+	case BTC_SET_ACT_NORMAL_LPS:
+		halbtc_normal_lps(btcoexist);
+		break;
+	case BTC_SET_ACT_DISABLE_LOW_POWER:
+		halbtc_disable_low_power();
+		break;
+	case BTC_SET_ACT_UPDATE_ra_mask:
+		btcoexist->bt_info.ra_mask = *u32_tmp;
+		break;
+	case BTC_SET_ACT_SEND_MIMO_PS:
+		break;
+	case BTC_SET_ACT_INC_FORCE_EXEC_PWR_CMD_CNT:
+		btcoexist->bt_info.force_exec_pwr_cmd_cnt++;
+		break;
+	case BTC_SET_ACT_CTRL_BT_INFO: /*wait for 8812/8821*/
+		break;
+	case BTC_SET_ACT_CTRL_BT_COEX:
+		break;
+	default:
+		break;
+	}
+
+	return true;
+}
+
+static void halbtc_display_coex_statistics(struct btc_coexist *btcoexist)
+{
+}
+
+static void halbtc_display_bt_link_info(struct btc_coexist *btcoexist)
+{
+}
+
+static void halbtc_display_bt_fw_info(struct btc_coexist *btcoexist)
+{
+}
+
+static void halbtc_display_fw_pwr_mode_cmd(struct btc_coexist *btcoexist)
+{
+}
+
+/************************************************************
+ *		IO related function
+ ************************************************************/
+static u8 halbtc_read_1byte(void *bt_context, u32 reg_addr)
+{
+	struct btc_coexist *btcoexist = (struct btc_coexist *)bt_context;
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+
+	return	rtl_read_byte(rtlpriv, reg_addr);
+}
+
+static u16 halbtc_read_2byte(void *bt_context, u32 reg_addr)
+{
+	struct btc_coexist *btcoexist = (struct btc_coexist *)bt_context;
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+
+	return	rtl_read_word(rtlpriv, reg_addr);
+}
+
+static u32 halbtc_read_4byte(void *bt_context, u32 reg_addr)
+{
+	struct btc_coexist *btcoexist = (struct btc_coexist *)bt_context;
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+
+	return	rtl_read_dword(rtlpriv, reg_addr);
+}
+
+static void halbtc_write_1byte(void *bt_context, u32 reg_addr, u8 data)
+{
+	struct btc_coexist *btcoexist = (struct btc_coexist *)bt_context;
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+
+	rtl_write_byte(rtlpriv, reg_addr, data);
+}
+
+static void halbtc_bitmask_write_1byte(void *bt_context, u32 reg_addr,
+				       u32 bit_mask, u8 data)
+{
+	struct btc_coexist *btcoexist = (struct btc_coexist *)bt_context;
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+	u8 original_value, bit_shift = 0;
+	u8 i;
+
+	if (bit_mask != MASKDWORD) {/*if not "double word" write*/
+		original_value = rtl_read_byte(rtlpriv, reg_addr);
+		for (i = 0; i <= 7; i++) {
+			if ((bit_mask>>i) & 0x1)
+				break;
+		}
+		bit_shift = i;
+		data = (original_value & (~bit_mask)) |
+			((data << bit_shift) & bit_mask);
+	}
+	rtl_write_byte(rtlpriv, reg_addr, data);
+}
+
+static void halbtc_write_2byte(void *bt_context, u32 reg_addr, u16 data)
+{
+	struct btc_coexist *btcoexist = (struct btc_coexist *)bt_context;
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+
+	rtl_write_word(rtlpriv, reg_addr, data);
+}
+
+static void halbtc_write_4byte(void *bt_context, u32 reg_addr, u32 data)
+{
+	struct btc_coexist *btcoexist =
+		(struct btc_coexist *)bt_context;
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+
+	rtl_write_dword(rtlpriv, reg_addr, data);
+}
+
+static void halbtc_set_bbreg(void *bt_context, u32 reg_addr, u32 bit_mask,
+			     u32 data)
+{
+	struct btc_coexist *btcoexist = (struct btc_coexist *)bt_context;
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+
+	rtl_set_bbreg(rtlpriv->mac80211.hw, reg_addr, bit_mask, data);
+}
+
+static u32 halbtc_get_bbreg(void *bt_context, u32 reg_addr, u32 bit_mask)
+{
+	struct btc_coexist *btcoexist = (struct btc_coexist *)bt_context;
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+
+	return rtl_get_bbreg(rtlpriv->mac80211.hw, reg_addr, bit_mask);
+}
+
+static void halbtc_set_rfreg(void *bt_context, u8 rf_path, u32 reg_addr,
+			     u32 bit_mask, u32 data)
+{
+	struct btc_coexist *btcoexist = (struct btc_coexist *)bt_context;
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+
+	rtl_set_rfreg(rtlpriv->mac80211.hw, rf_path, reg_addr, bit_mask, data);
+}
+
+static u32 halbtc_get_rfreg(void *bt_context, u8 rf_path, u32 reg_addr,
+			    u32 bit_mask)
+{
+	struct btc_coexist *btcoexist = (struct btc_coexist *)bt_context;
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+
+	return rtl_get_rfreg(rtlpriv->mac80211.hw, rf_path, reg_addr, bit_mask);
+}
+
+static void halbtc_fill_h2c_cmd(void *bt_context, u8 element_id,
+				u32 cmd_len, u8 *cmd_buf)
+{
+	struct btc_coexist *btcoexist = (struct btc_coexist *)bt_context;
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+
+	rtlpriv->cfg->ops->fill_h2c_cmd(rtlpriv->mac80211.hw, element_id,
+					cmd_len, cmd_buf);
+}
+
+static void halbtc_display_dbg_msg(void *bt_context, u8 disp_type)
+{
+	struct btc_coexist *btcoexist =	(struct btc_coexist *)bt_context;
+	switch (disp_type) {
+	case BTC_DBG_DISP_COEX_STATISTICS:
+		halbtc_display_coex_statistics(btcoexist);
+		break;
+	case BTC_DBG_DISP_BT_LINK_INFO:
+		halbtc_display_bt_link_info(btcoexist);
+		break;
+	case BTC_DBG_DISP_BT_FW_VER:
+		halbtc_display_bt_fw_info(btcoexist);
+		break;
+	case BTC_DBG_DISP_FW_PWR_MODE_CMD:
+		halbtc_display_fw_pwr_mode_cmd(btcoexist);
+		break;
+	default:
+		break;
+	}
+}
+
+/*****************************************************************
+ *         Extern functions called by other module
+ *****************************************************************/
+bool exhalbtc_initlize_variables(struct rtl_priv *adapter)
+{
+	struct btc_coexist *btcoexist = &gl_bt_coexist;
+
+	btcoexist->statistics.cnt_bind++;
+
+	halbtc_dbg_init();
+
+	if (btcoexist->binded)
+		return false;
+	else
+		btcoexist->binded = true;
+
+#if (defined(CONFIG_PCI_HCI))
+	btcoexist->chip_interface = BTC_INTF_PCI;
+#elif (defined(CONFIG_USB_HCI))
+	btcoexist->chip_interface = BTC_INTF_USB;
+#elif (defined(CONFIG_SDIO_HCI))
+	btcoexist->chip_interface = BTC_INTF_SDIO;
+#elif (defined(CONFIG_GSPI_HCI))
+	btcoexist->chip_interface = BTC_INTF_GSPI;
+#else
+	btcoexist->chip_interface = BTC_INTF_UNKNOWN;
+#endif
+
+	if (NULL == btcoexist->adapter)
+		btcoexist->adapter = adapter;
+
+	btcoexist->stack_info.profile_notified = false;
+
+	btcoexist->btc_read_1byte = halbtc_read_1byte;
+	btcoexist->btc_write_1byte = halbtc_write_1byte;
+	btcoexist->btc_write_1byte_bitmask = halbtc_bitmask_write_1byte;
+	btcoexist->btc_read_2byte = halbtc_read_2byte;
+	btcoexist->btc_write_2byte = halbtc_write_2byte;
+	btcoexist->btc_read_4byte = halbtc_read_4byte;
+	btcoexist->btc_write_4byte = halbtc_write_4byte;
+
+	btcoexist->btc_set_bb_reg = halbtc_set_bbreg;
+	btcoexist->btc_get_bb_reg = halbtc_get_bbreg;
+
+	btcoexist->btc_set_rf_reg = halbtc_set_rfreg;
+	btcoexist->btc_get_rf_reg = halbtc_get_rfreg;
+
+	btcoexist->btc_fill_h2c = halbtc_fill_h2c_cmd;
+	btcoexist->btc_disp_dbg_msg = halbtc_display_dbg_msg;
+
+	btcoexist->btc_get = halbtc_get;
+	btcoexist->btc_set = halbtc_set;
+
+	btcoexist->cli_buf = &btc_dbg_buf[0];
+
+	btcoexist->bt_info.b_bt_ctrl_buf_size = false;
+	btcoexist->bt_info.agg_buf_size = 5;
+
+	btcoexist->bt_info.increase_scan_dev_num = false;
+	return true;
+}
+
+void exhalbtc_init_hw_config(struct btc_coexist *btcoexist)
+{
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
+
+	if (!halbtc_is_bt_coexist_available(btcoexist))
+		return;
+
+	btcoexist->statistics.cnt_init_hw_config++;
+
+	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723BE)
+		ex_halbtc8723b2ant_init_hwconfig(btcoexist);
+}
+
+void exhalbtc_init_coex_dm(struct btc_coexist *btcoexist)
+{
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
+
+	if (!halbtc_is_bt_coexist_available(btcoexist))
+		return;
+
+	btcoexist->statistics.cnt_init_coex_dm++;
+
+	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723BE)
+		ex_halbtc8723b2ant_init_coex_dm(btcoexist);
+
+	btcoexist->initilized = true;
+}
+
+void exhalbtc_ips_notify(struct btc_coexist *btcoexist, u8 type)
+{
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
+	u8 ips_type;
+
+	if (!halbtc_is_bt_coexist_available(btcoexist))
+		return;
+	btcoexist->statistics.cnt_ips_notify++;
+	if (btcoexist->manual_control)
+		return;
+
+	if (ERFOFF == type)
+		ips_type = BTC_IPS_ENTER;
+	else
+		ips_type = BTC_IPS_LEAVE;
+
+	halbtc_leave_low_power();
+
+	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723BE)
+		ex_halbtc8723b2ant_ips_notify(btcoexist, ips_type);
+
+	halbtc_nomal_low_power();
+}
+
+void exhalbtc_lps_notify(struct btc_coexist *btcoexist, u8 type)
+{
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
+	u8 lps_type;
+
+	if (!halbtc_is_bt_coexist_available(btcoexist))
+		return;
+	btcoexist->statistics.cnt_lps_notify++;
+	if (btcoexist->manual_control)
+		return;
+
+	if (EACTIVE == type)
+		lps_type = BTC_LPS_DISABLE;
+	else
+		lps_type = BTC_LPS_ENABLE;
+
+	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723BE)
+		ex_halbtc8723b2ant_lps_notify(btcoexist, lps_type);
+}
+
+void exhalbtc_scan_notify(struct btc_coexist *btcoexist, u8 type)
+{
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
+	u8 scan_type;
+
+	if (!halbtc_is_bt_coexist_available(btcoexist))
+		return;
+	btcoexist->statistics.cnt_scan_notify++;
+	if (btcoexist->manual_control)
+		return;
+
+	if (type)
+		scan_type = BTC_SCAN_START;
+	else
+		scan_type = BTC_SCAN_FINISH;
+
+	halbtc_leave_low_power();
+
+	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723BE)
+		ex_halbtc8723b2ant_scan_notify(btcoexist, scan_type);
+
+	halbtc_nomal_low_power();
+}
+
+void exhalbtc_connect_notify(struct btc_coexist *btcoexist, u8 action)
+{
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
+	u8 asso_type;
+
+	if (!halbtc_is_bt_coexist_available(btcoexist))
+		return;
+	btcoexist->statistics.cnt_connect_notify++;
+	if (btcoexist->manual_control)
+		return;
+
+	if (action)
+		asso_type = BTC_ASSOCIATE_START;
+	else
+		asso_type = BTC_ASSOCIATE_FINISH;
+
+	halbtc_leave_low_power();
+
+	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723BE)
+		ex_halbtc8723b2ant_connect_notify(btcoexist, asso_type);
+}
+
+void exhalbtc_mediastatus_notify(struct btc_coexist *btcoexist,
+				 enum _RT_MEDIA_STATUS media_status)
+{
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
+	u8 status;
+
+	if (!halbtc_is_bt_coexist_available(btcoexist))
+		return;
+	btcoexist->statistics.cnt_media_status_notify++;
+	if (btcoexist->manual_control)
+		return;
+
+	if (RT_MEDIA_CONNECT == media_status)
+		status = BTC_MEDIA_CONNECT;
+	else
+		status = BTC_MEDIA_DISCONNECT;
+
+	halbtc_leave_low_power();
+
+	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723BE)
+		btc8723b_med_stat_notify(btcoexist, status);
+
+	halbtc_nomal_low_power();
+}
+
+void exhalbtc_special_packet_notify(struct btc_coexist *btcoexist, u8 pkt_type)
+{
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
+	u8 packet_type;
+
+	if (!halbtc_is_bt_coexist_available(btcoexist))
+		return;
+	btcoexist->statistics.cnt_special_packet_notify++;
+	if (btcoexist->manual_control)
+		return;
+
+	packet_type = BTC_PACKET_DHCP;
+
+	halbtc_leave_low_power();
+
+	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723BE)
+		ex_halbtc8723b2ant_special_packet_notify(btcoexist,
+							 packet_type);
+
+	halbtc_nomal_low_power();
+}
+
+void exhalbtc_bt_info_notify(struct btc_coexist *btcoexist,
+			     u8 *tmp_buf, u8 length)
+{
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
+	if (!halbtc_is_bt_coexist_available(btcoexist))
+		return;
+	btcoexist->statistics.cnt_bt_info_notify++;
+
+	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723BE)
+		ex_halbtc8723b2ant_bt_info_notify(btcoexist, tmp_buf, length);
+}
+
+void exhalbtc_stack_operation_notify(struct btc_coexist *btcoexist, u8 type)
+{
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
+	u8 stack_op_type;
+
+	if (!halbtc_is_bt_coexist_available(btcoexist))
+		return;
+	btcoexist->statistics.cnt_stack_operation_notify++;
+	if (btcoexist->manual_control)
+		return;
+
+	stack_op_type = BTC_STACK_OP_NONE;
+
+	halbtc_leave_low_power();
+
+	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723BE)
+		ex_halbtc8723b2ant_stack_operation_notify(btcoexist,
+							  stack_op_type);
+
+	halbtc_nomal_low_power();
+}
+
+void exhalbtc_halt_notify(struct btc_coexist *btcoexist)
+{
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
+	if (!halbtc_is_bt_coexist_available(btcoexist))
+		return;
+
+	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723BE)
+		ex_halbtc8723b2ant_halt_notify(btcoexist);
+}
+
+void exhalbtc_pnp_notify(struct btc_coexist *btcoexist, u8 pnp_state)
+{
+	if (!halbtc_is_bt_coexist_available(btcoexist))
+		return;
+}
+
+void exhalbtc_periodical(struct btc_coexist *btcoexist)
+{
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
+	if (!halbtc_is_bt_coexist_available(btcoexist))
+		return;
+	btcoexist->statistics.cnt_periodical++;
+
+	halbtc_leave_low_power();
+
+	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723BE)
+		ex_halbtc8723b2ant_periodical(btcoexist);
+
+	halbtc_nomal_low_power();
+}
+
+void exhalbtc_dbg_control(struct btc_coexist *btcoexist,
+			  u8 code, u8 len, u8 *data)
+{
+	if (!halbtc_is_bt_coexist_available(btcoexist))
+		return;
+	btcoexist->statistics.cnt_dbg_ctrl++;
+}
+
+void exhalbtc_stack_update_profile_info(void)
+{
+}
+
+void exhalbtc_update_min_bt_rssi(char bt_rssi)
+{
+	struct btc_coexist *btcoexist = &gl_bt_coexist;
+
+	if (!halbtc_is_bt_coexist_available(btcoexist))
+		return;
+
+	btcoexist->stack_info.min_bt_rssi = bt_rssi;
+}
+
+void exhalbtc_set_hci_version(u16 hci_version)
+{
+	struct btc_coexist *btcoexist = &gl_bt_coexist;
+
+	if (!halbtc_is_bt_coexist_available(btcoexist))
+		return;
+
+	btcoexist->stack_info.hci_version = hci_version;
+}
+
+void exhalbtc_set_bt_patch_version(u16 bt_hci_version, u16 bt_patch_version)
+{
+	struct btc_coexist *btcoexist = &gl_bt_coexist;
+
+	if (!halbtc_is_bt_coexist_available(btcoexist))
+		return;
+
+	btcoexist->bt_info.bt_real_fw_ver = bt_patch_version;
+	btcoexist->bt_info.bt_hci_ver = bt_hci_version;
+}
+
+void exhalbtc_set_bt_exist(bool bt_exist)
+{
+	gl_bt_coexist.board_info.bt_exist = bt_exist;
+}
+
+void exhalbtc_set_chip_type(u8 chip_type)
+{
+	switch (chip_type) {
+	default:
+	case BT_2WIRE:
+	case BT_ISSC_3WIRE:
+	case BT_ACCEL:
+	case BT_RTL8756:
+		gl_bt_coexist.board_info.bt_chip_type = BTC_CHIP_UNDEF;
+		break;
+	case BT_CSR_BC4:
+		gl_bt_coexist.board_info.bt_chip_type = BTC_CHIP_CSR_BC4;
+		break;
+	case BT_CSR_BC8:
+		gl_bt_coexist.board_info.bt_chip_type = BTC_CHIP_CSR_BC8;
+		break;
+	case BT_RTL8723A:
+		gl_bt_coexist.board_info.bt_chip_type = BTC_CHIP_RTL8723A;
+		break;
+	case BT_RTL8821:
+		gl_bt_coexist.board_info.bt_chip_type = BTC_CHIP_RTL8821;
+		break;
+	case BT_RTL8723B:
+		gl_bt_coexist.board_info.bt_chip_type = BTC_CHIP_RTL8723B;
+		break;
+	}
+}
+
+void exhalbtc_set_ant_num(u8 type, u8 ant_num)
+{
+	if (BT_COEX_ANT_TYPE_PG == type) {
+		gl_bt_coexist.board_info.pg_ant_num = ant_num;
+		gl_bt_coexist.board_info.btdm_ant_num = ant_num;
+	} else if (BT_COEX_ANT_TYPE_ANTDIV == type) {
+		gl_bt_coexist.board_info.btdm_ant_num = ant_num;
+	}
+}
+
+void exhalbtc_display_bt_coex_info(struct btc_coexist *btcoexist)
+{
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
+	if (!halbtc_is_bt_coexist_available(btcoexist))
+		return;
+
+	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723BE)
+		ex_halbtc8723b2ant_display_coex_info(btcoexist);
+}
diff --git a/drivers/net/wireless/rtlwifi/btcoexist/rtl_btc.c b/drivers/net/wireless/rtlwifi/btcoexist/rtl_btc.c
new file mode 100644
index 0000000..0ab94fe
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/btcoexist/rtl_btc.c
@@ -0,0 +1,218 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2013  Realtek Corporation.
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
+#include "rtl_btc.h"
+#include "halbt_precomp.h"
+
+#include <linux/vmalloc.h>
+#include <linux/module.h>
+
+static struct rtl_btc_ops rtl_btc_operation = {
+	.btc_init_variables = rtl_btc_init_variables,
+	.btc_init_hal_vars = rtl_btc_init_hal_vars,
+	.btc_init_hw_config = rtl_btc_init_hw_config,
+	.btc_ips_notify = rtl_btc_ips_notify,
+	.btc_scan_notify = rtl_btc_scan_notify,
+	.btc_connect_notify = rtl_btc_connect_notify,
+	.btc_mediastatus_notify = rtl_btc_mediastatus_notify,
+	.btc_periodical = rtl_btc_periodical,
+	.btc_halt_notify = rtl_btc_halt_notify,
+	.btc_btinfo_notify = rtl_btc_btinfo_notify,
+	.btc_is_limited_dig = rtl_btc_is_limited_dig,
+	.btc_is_disable_edca_turbo = rtl_btc_is_disable_edca_turbo,
+	.btc_is_bt_disabled = rtl_btc_is_bt_disabled,
+};
+
+void rtl_btc_init_variables(struct rtl_priv *rtlpriv)
+{
+	exhalbtc_initlize_variables(rtlpriv);
+}
+
+void rtl_btc_init_hal_vars(struct rtl_priv *rtlpriv)
+{
+	u8 ant_num;
+	u8 bt_exist;
+	u8 bt_type;
+
+	ant_num = rtl_get_hwpg_ant_num(rtlpriv);
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
+		 "%s, antNum is %d\n", __func__, ant_num);
+
+	bt_exist = rtl_get_hwpg_bt_exist(rtlpriv);
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
+		 "%s, bt_exist is %d\n", __func__, bt_exist);
+	exhalbtc_set_bt_exist(bt_exist);
+
+	bt_type = rtl_get_hwpg_bt_type(rtlpriv);
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "%s, bt_type is %d\n",
+		 __func__, bt_type);
+	exhalbtc_set_chip_type(bt_type);
+
+	exhalbtc_set_ant_num(BT_COEX_ANT_TYPE_PG, ant_num);
+}
+
+void rtl_btc_init_hw_config(struct rtl_priv *rtlpriv)
+{
+	exhalbtc_init_hw_config(&gl_bt_coexist);
+	exhalbtc_init_coex_dm(&gl_bt_coexist);
+}
+
+void rtl_btc_ips_notify(struct rtl_priv *rtlpriv, u8 type)
+{
+	exhalbtc_ips_notify(&gl_bt_coexist, type);
+}
+
+void rtl_btc_scan_notify(struct rtl_priv *rtlpriv, u8 scantype)
+{
+	exhalbtc_scan_notify(&gl_bt_coexist, scantype);
+}
+
+void rtl_btc_connect_notify(struct rtl_priv *rtlpriv, u8 action)
+{
+	exhalbtc_connect_notify(&gl_bt_coexist, action);
+}
+
+void rtl_btc_mediastatus_notify(struct rtl_priv *rtlpriv,
+				enum _RT_MEDIA_STATUS mstatus)
+{
+	exhalbtc_mediastatus_notify(&gl_bt_coexist, mstatus);
+}
+
+void rtl_btc_periodical(struct rtl_priv *rtlpriv)
+{
+	exhalbtc_periodical(&gl_bt_coexist);
+}
+
+void rtl_btc_halt_notify(void)
+{
+	exhalbtc_halt_notify(&gl_bt_coexist);
+}
+
+void rtl_btc_btinfo_notify(struct rtl_priv *rtlpriv, u8 *tmp_buf, u8 length)
+{
+	exhalbtc_bt_info_notify(&gl_bt_coexist, tmp_buf, length);
+}
+
+bool rtl_btc_is_limited_dig(struct rtl_priv *rtlpriv)
+{
+	return gl_bt_coexist.bt_info.limited_dig;
+}
+
+bool rtl_btc_is_disable_edca_turbo(struct rtl_priv *rtlpriv)
+{
+	bool bt_change_edca = false;
+	u32 cur_edca_val;
+	u32 edca_bt_hs_uplink = 0x5ea42b, edca_bt_hs_downlink = 0x5ea42b;
+	u32 edca_hs;
+	u32 edca_addr = 0x504;
+
+	cur_edca_val = rtl_read_dword(rtlpriv, edca_addr);
+	if (halbtc_is_wifi_uplink(rtlpriv)) {
+		if (cur_edca_val != edca_bt_hs_uplink) {
+			edca_hs = edca_bt_hs_uplink;
+			bt_change_edca = true;
+		}
+	} else {
+		if (cur_edca_val != edca_bt_hs_downlink) {
+			edca_hs = edca_bt_hs_downlink;
+			bt_change_edca = true;
+		}
+	}
+
+	if (bt_change_edca)
+		rtl_write_dword(rtlpriv, edca_addr, edca_hs);
+
+	return true;
+}
+
+bool rtl_btc_is_bt_disabled(struct rtl_priv *rtlpriv)
+{
+	if (gl_bt_coexist.bt_info.bt_disabled)
+		return true;
+	else
+		return false;
+}
+
+struct rtl_btc_ops *rtl_btc_get_ops_pointer(void)
+{
+	return &rtl_btc_operation;
+}
+EXPORT_SYMBOL(rtl_btc_get_ops_pointer);
+
+u8 rtl_get_hwpg_ant_num(struct rtl_priv *rtlpriv)
+{
+	u8 num;
+
+	if (rtlpriv->btcoexist.btc_info.ant_num == ANT_X2)
+		num = 2;
+	else
+		num = 1;
+
+	return num;
+}
+
+enum _RT_MEDIA_STATUS mgnt_link_status_query(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
+	enum _RT_MEDIA_STATUS    m_status = RT_MEDIA_DISCONNECT;
+
+	u8 bibss = (mac->opmode == NL80211_IFTYPE_ADHOC) ? 1 : 0;
+
+	if (bibss || rtlpriv->mac80211.link_state >= MAC80211_LINKED)
+		m_status = RT_MEDIA_CONNECT;
+
+	return m_status;
+}
+
+u8 rtl_get_hwpg_bt_exist(struct rtl_priv *rtlpriv)
+{
+	return rtlpriv->btcoexist.btc_info.btcoexist;
+}
+
+u8 rtl_get_hwpg_bt_type(struct rtl_priv *rtlpriv)
+{
+	return rtlpriv->btcoexist.btc_info.bt_type;
+}
+
+MODULE_AUTHOR("Page He	<page_he@realsil.com.cn>");
+MODULE_AUTHOR("Realtek WlanFAE	<wlanfae@realtek.com>");
+MODULE_AUTHOR("Larry Finger	<Larry.FInger@lwfinger.net>");
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("Realtek 802.11n PCI wireless core");
+
+static int __init rtl_btcoexist_module_init(void)
+{
+	return 0;
+}
+
+static void __exit rtl_btcoexist_module_exit(void)
+{
+	return;
+}
+
+module_init(rtl_btcoexist_module_init);
+module_exit(rtl_btcoexist_module_exit);
diff --git a/drivers/net/wireless/rtlwifi/rtl8723com/fw_common.c b/drivers/net/wireless/rtlwifi/rtl8723com/fw_common.c
new file mode 100644
index 0000000..83ca4e2
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/rtl8723com/fw_common.c
@@ -0,0 +1,849 @@
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
+#include "fw_common.h"
+#include <linux/module.h>
+
+#define BEACON_PG		0 /* ->1 */
+#define PSPOLL_PG		2
+#define NULL_PG			3
+#define PROBERSP_PG		4 /* ->5 */
+
+#define TOTAL_RESERVED_PKT_LEN	768
+
+static u8 reserved_page_packet[TOTAL_RESERVED_PKT_LEN] = {
+	/* page 0 beacon */
+	0x80, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF,
+	0xFF, 0xFF, 0x00, 0xE0, 0x4C, 0x02, 0xB1, 0x78,
+	0xEC, 0x1A, 0x59, 0x0B, 0xAD, 0xD4, 0x20, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x64, 0x00, 0x10, 0x04, 0x00, 0x05, 0x54, 0x65,
+	0x73, 0x74, 0x32, 0x01, 0x08, 0x82, 0x84, 0x0B,
+	0x16, 0x24, 0x30, 0x48, 0x6C, 0x03, 0x01, 0x06,
+	0x06, 0x02, 0x00, 0x00, 0x2A, 0x01, 0x02, 0x32,
+	0x04, 0x0C, 0x12, 0x18, 0x60, 0x2D, 0x1A, 0x6C,
+	0x09, 0x03, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x3D, 0x00, 0xDD, 0x07, 0x00, 0xE0, 0x4C,
+	0x02, 0x02, 0x00, 0x00, 0xDD, 0x18, 0x00, 0x50,
+	0xF2, 0x01, 0x01, 0x00, 0x00, 0x50, 0xF2, 0x04,
+	0x01, 0x00, 0x00, 0x50, 0xF2, 0x04, 0x01, 0x00,
+
+	/* page 1 beacon */
+	0x00, 0x50, 0xF2, 0x02, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x10, 0x00, 0x28, 0x8C, 0x00, 0x12, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x81, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+
+	/* page 2  ps-poll */
+	0xA4, 0x10, 0x01, 0xC0, 0xEC, 0x1A, 0x59, 0x0B,
+	0xAD, 0xD4, 0x00, 0xE0, 0x4C, 0x02, 0xB1, 0x78,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x18, 0x00, 0x28, 0x8C, 0x00, 0x12, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+
+	/* page 3  null */
+	0x48, 0x01, 0x00, 0x00, 0xEC, 0x1A, 0x59, 0x0B,
+	0xAD, 0xD4, 0x00, 0xE0, 0x4C, 0x02, 0xB1, 0x78,
+	0xEC, 0x1A, 0x59, 0x0B, 0xAD, 0xD4, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x72, 0x00, 0x28, 0x8C, 0x00, 0x12, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+
+	/* page 4  probe_resp */
+	0x50, 0x00, 0x00, 0x00, 0x00, 0x40, 0x10, 0x10,
+	0x00, 0x03, 0x00, 0xE0, 0x4C, 0x76, 0x00, 0x42,
+	0x00, 0x40, 0x10, 0x10, 0x00, 0x03, 0x00, 0x00,
+	0x9E, 0x46, 0x15, 0x32, 0x27, 0xF2, 0x2D, 0x00,
+	0x64, 0x00, 0x00, 0x04, 0x00, 0x0C, 0x6C, 0x69,
+	0x6E, 0x6B, 0x73, 0x79, 0x73, 0x5F, 0x77, 0x6C,
+	0x61, 0x6E, 0x01, 0x04, 0x82, 0x84, 0x8B, 0x96,
+	0x03, 0x01, 0x01, 0x06, 0x02, 0x00, 0x00, 0x2A,
+	0x01, 0x00, 0x32, 0x08, 0x24, 0x30, 0x48, 0x6C,
+	0x0C, 0x12, 0x18, 0x60, 0x2D, 0x1A, 0x6C, 0x18,
+	0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x3D, 0x00, 0xDD, 0x06, 0x00, 0xE0, 0x4C, 0x02,
+	0x01, 0x70, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+
+	/* page 5  probe_resp */
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+};
+
+void rtl8723_enable_fw_download(struct ieee80211_hw *hw, bool enable)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u8 tmp;
+
+	if (enable) {
+		tmp = rtl_read_byte(rtlpriv, REG_SYS_FUNC_EN + 1);
+		rtl_write_byte(rtlpriv, REG_SYS_FUNC_EN + 1, tmp | 0x04);
+
+		tmp = rtl_read_byte(rtlpriv, REG_MCUFWDL);
+		rtl_write_byte(rtlpriv, REG_MCUFWDL, tmp | 0x01);
+
+		tmp = rtl_read_byte(rtlpriv, REG_MCUFWDL + 2);
+		rtl_write_byte(rtlpriv, REG_MCUFWDL + 2, tmp & 0xf7);
+	} else {
+		tmp = rtl_read_byte(rtlpriv, REG_MCUFWDL);
+		rtl_write_byte(rtlpriv, REG_MCUFWDL, tmp & 0xfe);
+
+		rtl_write_byte(rtlpriv, REG_MCUFWDL + 1, 0x00);
+	}
+}
+EXPORT_SYMBOL_GPL(rtl8723_enable_fw_download);
+
+void rtl8723_fw_block_write(struct ieee80211_hw *hw,
+			    const u8 *buffer, u32 size)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u32 blocksize = sizeof(u32);
+	u8 *bufferptr = (u8 *)buffer;
+	u32 *pu4byteptr = (u32 *)buffer;
+	u32 i, offset, blockcount, remainsize;
+
+	blockcount = size / blocksize;
+	remainsize = size % blocksize;
+
+	for (i = 0; i < blockcount; i++) {
+		offset = i * blocksize;
+		rtl_write_dword(rtlpriv, (FW_8192C_START_ADDRESS + offset),
+				*(pu4byteptr + i));
+	}
+	if (remainsize) {
+		offset = blockcount * blocksize;
+		bufferptr += offset;
+		for (i = 0; i < remainsize; i++) {
+			rtl_write_byte(rtlpriv,
+				       (FW_8192C_START_ADDRESS + offset + i),
+				       *(bufferptr + i));
+		}
+	}
+}
+EXPORT_SYMBOL_GPL(rtl8723_fw_block_write);
+
+void rtl8723_fw_page_write(struct ieee80211_hw *hw,
+			   u32 page, const u8 *buffer, u32 size)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u8 value8;
+	u8 u8page = (u8) (page & 0x07);
+
+	value8 = (rtl_read_byte(rtlpriv, REG_MCUFWDL + 2) & 0xF8) | u8page;
+
+	rtl_write_byte(rtlpriv, (REG_MCUFWDL + 2), value8);
+	rtl8723_fw_block_write(hw, buffer, size);
+}
+EXPORT_SYMBOL_GPL(rtl8723_fw_page_write);
+
+static void rtl8723_fill_dummy(u8 *pfwbuf, u32 *pfwlen)
+{
+	u32 fwlen = *pfwlen;
+	u8 remain = (u8) (fwlen % 4);
+
+	remain = (remain == 0) ? 0 : (4 - remain);
+
+	while (remain > 0) {
+		pfwbuf[fwlen] = 0;
+		fwlen++;
+		remain--;
+	}
+	*pfwlen = fwlen;
+}
+
+void rtl8723_write_fw(struct ieee80211_hw *hw,
+		      enum version_8723be version,
+		      u8 *buffer, u32 size)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u8 *bufferptr = (u8 *)buffer;
+	u32 pagenums, remainsize;
+	u32 page, offset;
+
+	RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD, "FW size is %d bytes,\n", size);
+
+	_rtl8723be_fill_dummy(bufferptr, &size);
+
+	pagenums = size / FW_8192C_PAGE_SIZE;
+	remainsize = size % FW_8192C_PAGE_SIZE;
+
+	if (pagenums > 8) {
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+			 "Page numbers should not greater then 8\n");
+	}
+	for (page = 0; page < pagenums; page++) {
+		offset = page * FW_8192C_PAGE_SIZE;
+		rtl8723_fw_page_write(hw, page, (bufferptr + offset),
+				      FW_8192C_PAGE_SIZE);
+	}
+	if (remainsize) {
+		offset = pagenums * FW_8192C_PAGE_SIZE;
+		page = pagenums;
+		rtl8723_fw_page_write(hw, page, (bufferptr + offset),
+				      remainsize);
+	}
+}
+EXPORT_SYMBOL_GPL(rtl8723_write_fw);
+
+void rtl8723ae_firmware_selfreset(struct ieee80211_hw *hw)
+{
+	u8 u1tmp;
+	u8 delay = 100;
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+
+	rtl_write_byte(rtlpriv, REG_HMETFR + 3, 0x20);
+	u1tmp = rtl_read_byte(rtlpriv, REG_SYS_FUNC_EN + 1);
+
+	while (u1tmp & BIT(2)) {
+		delay--;
+		if (delay == 0)
+			break;
+		udelay(50);
+		u1tmp = rtl_read_byte(rtlpriv, REG_SYS_FUNC_EN + 1);
+	}
+	if (delay == 0) {
+		u1tmp = rtl_read_byte(rtlpriv, REG_SYS_FUNC_EN + 1);
+		rtl_write_byte(rtlpriv, REG_SYS_FUNC_EN + 1, u1tmp&(~BIT(2)));
+	}
+}
+EXPORT_SYMBOL_GPL(rtl8723ae_firmware_selfreset);
+
+void rtl8723be_firmware_selfreset(struct ieee80211_hw *hw)
+{
+	u8 u1b_tmp;
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+
+	u1b_tmp = rtl_read_byte(rtlpriv, REG_RSV_CTRL + 1);
+	rtl_write_byte(rtlpriv, REG_RSV_CTRL + 1, (u1b_tmp & (~BIT(0))));
+
+	u1b_tmp = rtl_read_byte(rtlpriv, REG_SYS_FUNC_EN + 1);
+	rtl_write_byte(rtlpriv, REG_SYS_FUNC_EN + 1, (u1b_tmp & (~BIT(2))));
+	udelay(50);
+
+	u1b_tmp = rtl_read_byte(rtlpriv, REG_RSV_CTRL + 1);
+	rtl_write_byte(rtlpriv, REG_RSV_CTRL + 1, (u1b_tmp | BIT(0)));
+
+	u1b_tmp = rtl_read_byte(rtlpriv, REG_SYS_FUNC_EN + 1);
+	rtl_write_byte(rtlpriv, REG_SYS_FUNC_EN + 1, (u1b_tmp | BIT(2)));
+
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+		 "  _8051Reset8723be(): 8051 reset success .\n");
+}
+EXPORT_SYMBOL_GPL(rtl8723be_firmware_selfreset);
+
+int rtl8723_fw_free_to_go(struct ieee80211_hw *hw, bool is_8723be)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	int err = -EIO;
+	u32 counter = 0;
+	u32 value32;
+
+	do {
+		value32 = rtl_read_dword(rtlpriv, REG_MCUFWDL);
+	} while ((counter++ < FW_8192C_POLLING_TIMEOUT_COUNT) &&
+		 (!(value32 & FWDL_CHKSUM_RPT)));
+
+	if (counter >= FW_8192C_POLLING_TIMEOUT_COUNT) {
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+			 "chksum report faill ! REG_MCUFWDL:0x%08x .\n",
+			 value32);
+		goto exit;
+	}
+	RT_TRACE(rtlpriv, COMP_FW, DBG_TRACE,
+		 "Checksum report OK ! REG_MCUFWDL:0x%08x .\n", value32);
+
+	value32 = rtl_read_dword(rtlpriv, REG_MCUFWDL);
+	value32 |= MCUFWDL_RDY;
+	value32 &= ~WINTINI_RDY;
+	rtl_write_dword(rtlpriv, REG_MCUFWDL, value32);
+
+	if (is_8723be)
+		rtl8723be_firmware_selfreset(hw);
+	counter = 0;
+
+	do {
+		value32 = rtl_read_dword(rtlpriv, REG_MCUFWDL);
+		if (value32 & WINTINI_RDY) {
+			RT_TRACE(rtlpriv, COMP_FW, DBG_TRACE,
+				 "Polling FW ready success!! "
+				 "REG_MCUFWDL:0x%08x .\n",
+				 value32);
+			err = 0;
+			goto exit;
+		}
+		udelay(FW_8192C_POLLING_DELAY);
+
+	} while (counter++ < FW_8192C_POLLING_TIMEOUT_COUNT);
+
+	RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+		 "Polling FW ready fail!! REG_MCUFWDL:0x%08x .\n",
+		 value32);
+
+exit:
+	return err;
+}
+EXPORT_SYMBOL_GPL(rtl8723_fw_free_to_go);
+
+int rtl8723_download_fw(struct ieee80211_hw *hw,
+			bool is_8723be)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
+	struct rtl92c_firmware_header *pfwheader;
+	u8 *pfwdata;
+	u32 fwsize;
+	int err;
+	enum version_8723e version = rtlhal->version;
+
+	if (!rtlhal->pfirmware)
+		return 1;
+
+	pfwheader = (struct rtl92c_firmware_header *)rtlhal->pfirmware;
+	pfwdata = (u8 *)rtlhal->pfirmware;
+	fwsize = rtlhal->fwsize;
+	RT_TRACE(rtlpriv, COMP_FW, DBG_DMESG,
+		 "normal Firmware SIZE %d\n", fwsize);
+
+	if (IS_FW_HEADER_EXIST(pfwheader)) {
+		RT_TRACE(rtlpriv, COMP_FW, DBG_DMESG,
+			 "Firmware Version(%d), Signature(%#x), Size(%d)\n",
+			 pfwheader->version, pfwheader->signature,
+			 (int)sizeof(struct rtl92c_firmware_header));
+
+		pfwdata = pfwdata + sizeof(struct rtl92c_firmware_header);
+		fwsize = fwsize - sizeof(struct rtl92c_firmware_header);
+	}
+	if (rtl_read_byte(rtlpriv, REG_MCUFWDL) & BIT(7)) {
+		rtl_write_byte(rtlpriv, REG_MCUFWDL, 0);
+		if (is_8723be)
+			rtl8723be_firmware_selfreset(hw);
+		else
+			rtl8723ae_firmware_selfreset(hw);
+	}
+	rtl8723_enable_fw_download(hw, is_8723be);
+	rtl8723_write_fw(hw, version, pfwdata, fwsize);
+	rtl8723_enable_fw_download(hw, is_8723be);
+
+	err = rtl8723_fw_free_to_go(hw, is_8723be);
+	if (err) {
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+			 "Firmware is not ready to run!\n");
+	} else {
+		RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD,
+			 "Firmware is ready to run!\n");
+	}
+	return 0;
+}
+EXPORT_SYMBOL_GPL(rtl8723_download_fw);
+
+bool rtl8723_check_fw_read_last_h2c(struct ieee80211_hw *hw, u8 boxnum)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u8 val_hmetfr, val_mcutst_1;
+	bool result = false;
+
+	val_hmetfr = rtl_read_byte(rtlpriv, REG_HMETFR);
+	val_mcutst_1 = rtl_read_byte(rtlpriv, (REG_MCUTST_1 + boxnum));
+
+	if (((val_hmetfr >> boxnum) & BIT(0)) == 0 && val_mcutst_1 == 0)
+		result = true;
+	return result;
+}
+EXPORT_SYMBOL_GPL(rtl8723_check_fw_read_last_h2c);
+
+void rtl8723_fill_h2c_command(struct ieee80211_hw *hw, u8 element_id,
+			      u32 cmd_len, u8 *p_cmdbuffer)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
+	u8 boxnum;
+	u16 box_reg = 0, box_extreg = 0;
+	u8 u1b_tmp;
+	bool isfw_read = false;
+	u8 buf_index = 0;
+	bool bwrite_sucess = false;
+	u8 wait_h2c_limit = 100;
+	u8 wait_writeh2c_limit = 100;
+	u8 boxcontent[4], boxextcontent[4];
+	u32 h2c_waitcounter = 0;
+	unsigned long flag;
+	u8 idx;
+
+	RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD, "come in\n");
+
+	while (true) {
+		spin_lock_irqsave(&rtlpriv->locks.h2c_lock, flag);
+		if (rtlhal->h2c_setinprogress) {
+			RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
+				 "H2C set in progress! Wait to set.."
+				 "element_id(%d).\n", element_id);
+
+			while (rtlhal->h2c_setinprogress) {
+				spin_unlock_irqrestore(&rtlpriv->locks.h2c_lock,
+						       flag);
+				h2c_waitcounter++;
+				RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
+					 "Wait 100 us (%d times)...\n",
+					 h2c_waitcounter);
+				udelay(100);
+
+				if (h2c_waitcounter > 1000)
+					return;
+				spin_lock_irqsave(&rtlpriv->locks.h2c_lock,
+						  flag);
+			}
+			spin_unlock_irqrestore(&rtlpriv->locks.h2c_lock, flag);
+		} else {
+			rtlhal->h2c_setinprogress = true;
+			spin_unlock_irqrestore(&rtlpriv->locks.h2c_lock, flag);
+			break;
+		}
+	}
+	while (!bwrite_sucess) {
+		wait_writeh2c_limit--;
+		if (wait_writeh2c_limit == 0) {
+			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+				 "Write H2C fail because no trigger "
+				 "for FW INT!\n");
+			break;
+		}
+		boxnum = rtlhal->last_hmeboxnum;
+		switch (boxnum) {
+		case 0:
+			box_reg = REG_HMEBOX_0;
+			box_extreg = REG_HMEBOX_EXT_0;
+			break;
+		case 1:
+			box_reg = REG_HMEBOX_1;
+			box_extreg = REG_HMEBOX_EXT_1;
+			break;
+		case 2:
+			box_reg = REG_HMEBOX_2;
+			box_extreg = REG_HMEBOX_EXT_2;
+			break;
+		case 3:
+			box_reg = REG_HMEBOX_3;
+			box_extreg = REG_HMEBOX_EXT_3;
+			break;
+		default:
+			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+				 "switch case not processed\n");
+			break;
+		}
+		isfw_read = rtl8723_check_fw_read_last_h2c(hw, boxnum);
+		while (!isfw_read) {
+			wait_h2c_limit--;
+			if (wait_h2c_limit == 0) {
+				RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
+					 "Waiting too long for FW read "
+					 "clear HMEBox(%d)!\n", boxnum);
+				break;
+			}
+			udelay(10);
+
+			isfw_read = rtl8723_check_fw_read_last_h2c(hw,
+								boxnum);
+		}
+		if (!isfw_read) {
+			RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
+				 "Write H2C register BOX[%d] fail!!!!! "
+				 "Fw do not read.\n", boxnum);
+			break;
+		}
+		memset(boxcontent, 0, sizeof(boxcontent));
+		memset(boxextcontent, 0, sizeof(boxextcontent));
+		boxcontent[0] = element_id;
+		RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
+			 "Write element_id box_reg(%4x) = %2x\n",
+			 box_reg, element_id);
+
+		switch (cmd_len) {
+		case 1:
+		case 2:
+		case 3:
+			/*boxcontent[0] &= ~(BIT(7));*/
+			memcpy((u8 *)(boxcontent) + 1,
+			       p_cmdbuffer + buf_index, cmd_len);
+
+			for (idx = 0; idx < 4; idx++) {
+				rtl_write_byte(rtlpriv, box_reg + idx,
+					       boxcontent[idx]);
+			}
+			break;
+		case 4:
+		case 5:
+		case 6:
+		case 7:
+			/*boxcontent[0] |= (BIT(7));*/
+			memcpy((u8 *)(boxextcontent),
+			       p_cmdbuffer + buf_index+3, cmd_len-3);
+			memcpy((u8 *)(boxcontent) + 1,
+			       p_cmdbuffer + buf_index, 3);
+
+			for (idx = 0; idx < 4; idx++) {
+				rtl_write_byte(rtlpriv, box_extreg + idx,
+					       boxextcontent[idx]);
+			}
+			for (idx = 0; idx < 4; idx++) {
+				rtl_write_byte(rtlpriv, box_reg + idx,
+					       boxcontent[idx]);
+			}
+			break;
+		default:
+			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+				 "switch case not process\n");
+			break;
+		}
+		bwrite_sucess = true;
+
+		rtlhal->last_hmeboxnum = boxnum + 1;
+		if (rtlhal->last_hmeboxnum == 4)
+			rtlhal->last_hmeboxnum = 0;
+
+		RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
+			 "pHalData->last_hmeboxnum  = %d\n",
+			 rtlhal->last_hmeboxnum);
+	}
+	if (!rtlpriv) {
+		pr_err("rtlpriv bad\n");
+		return;
+	}
+	if (!rtlhal) {
+		pr_err("rtlhal bad\n");
+		return;
+	}
+	spin_lock_irqsave(&rtlpriv->locks.h2c_lock, flag);
+	rtlhal->h2c_setinprogress = false;
+	spin_unlock_irqrestore(&rtlpriv->locks.h2c_lock, flag);
+
+	RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD, "go out\n");
+}
+EXPORT_SYMBOL_GPL(rtl8723_fill_h2c_command);
+
+void rtl8723_fill_h2c_cmd(struct ieee80211_hw *hw, u8 element_id,
+			  u32 cmd_len, u8 *p_cmdbuffer)
+{
+	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
+	u32 tmp_cmdbuf[2];
+
+	if (!rtlhal->fw_ready) {
+		RT_ASSERT(false,
+			  "return H2C cmd because of Fw download fail!!!\n");
+		return;
+	}
+	memset(tmp_cmdbuf, 0, 8);
+	memcpy(tmp_cmdbuf, p_cmdbuffer, cmd_len);
+	rtl8723_fill_h2c_command(hw, element_id, cmd_len,
+				 (u8 *)&tmp_cmdbuf);
+	return;
+}
+EXPORT_SYMBOL_GPL(rtl8723_fill_h2c_cmd);
+
+void rtl8723_set_fw_joinbss_report_cmd(struct ieee80211_hw *hw, u8 mstatus)
+{
+	u8 u1_joinbssrpt_parm[1] = { 0 };
+
+	SET_H2CCMD_JOINBSSRPT_PARM_OPMODE(u1_joinbssrpt_parm, mstatus);
+
+	rtl8723_fill_h2c_cmd(hw, H2C_JOINBSSRPT, 1, u1_joinbssrpt_parm);
+}
+EXPORT_SYMBOL_GPL(rtl8723_set_fw_joinbss_report_cmd);
+
+bool rtl8723_cmd_send_packet(struct ieee80211_hw *hw,
+			     struct sk_buff *skb)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
+	struct rtl8192_tx_ring *ring;
+	struct rtl_tx_desc *pdesc;
+	struct sk_buff *pskb = NULL;
+	u8 own;
+	unsigned long flags;
+
+	ring = &rtlpci->tx_ring[BEACON_QUEUE];
+
+	pskb = __skb_dequeue(&ring->queue);
+	if (pskb)
+		kfree_skb(pskb);
+
+	spin_lock_irqsave(&rtlpriv->locks.irq_th_lock, flags);
+
+	pdesc = &ring->desc[0];
+	own = (u8) rtlpriv->cfg->ops->get_desc((u8 *)pdesc, true, HW_DESC_OWN);
+
+	rtlpriv->cfg->ops->fill_tx_cmddesc(hw, (u8 *)pdesc, 1, 1, skb);
+
+	__skb_queue_tail(&ring->queue, skb);
+
+	spin_unlock_irqrestore(&rtlpriv->locks.irq_th_lock, flags);
+
+	rtlpriv->cfg->ops->tx_polling(hw, BEACON_QUEUE);
+
+	return true;
+}
+EXPORT_SYMBOL_GPL(rtl8723_cmd_send_packet);
+
+void rtl8723_set_fw_rsvdpagepkt(struct ieee80211_hw *hw, bool dl_finished)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
+	struct sk_buff *skb = NULL;
+
+	u32 totalpacketlen;
+	bool rtstatus;
+	u8 u1rsvdpageloc[5] = { 0 };
+	bool dlok = false;
+
+	u8 *beacon;
+	u8 *p_pspoll;
+	u8 *nullfunc;
+	u8 *p_probersp;
+	/*---------------------------------------------------------
+	 *			(1) beacon
+	 *---------------------------------------------------------
+	 */
+	beacon = &reserved_page_packet[BEACON_PG * 128];
+	SET_80211_HDR_ADDRESS2(beacon, mac->mac_addr);
+	SET_80211_HDR_ADDRESS3(beacon, mac->bssid);
+
+	/*-------------------------------------------------------
+	 *			(2) ps-poll
+	 *-------------------------------------------------------
+	 */
+	p_pspoll = &reserved_page_packet[PSPOLL_PG * 128];
+	SET_80211_PS_POLL_AID(p_pspoll, (mac->assoc_id | 0xc000));
+	SET_80211_PS_POLL_BSSID(p_pspoll, mac->bssid);
+	SET_80211_PS_POLL_TA(p_pspoll, mac->mac_addr);
+
+	SET_H2CCMD_RSVDPAGE_LOC_PSPOLL(u1rsvdpageloc, PSPOLL_PG);
+
+	/*--------------------------------------------------------
+	 *			(3) null data
+	 *--------------------------------------------------------
+	 */
+	nullfunc = &reserved_page_packet[NULL_PG * 128];
+	SET_80211_HDR_ADDRESS1(nullfunc, mac->bssid);
+	SET_80211_HDR_ADDRESS2(nullfunc, mac->mac_addr);
+	SET_80211_HDR_ADDRESS3(nullfunc, mac->bssid);
+
+	SET_H2CCMD_RSVDPAGE_LOC_NULL_DATA(u1rsvdpageloc, NULL_PG);
+
+	/*---------------------------------------------------------
+	 *			(4) probe response
+	 *---------------------------------------------------------
+	 */
+	p_probersp = &reserved_page_packet[PROBERSP_PG * 128];
+	SET_80211_HDR_ADDRESS1(p_probersp, mac->bssid);
+	SET_80211_HDR_ADDRESS2(p_probersp, mac->mac_addr);
+	SET_80211_HDR_ADDRESS3(p_probersp, mac->bssid);
+
+	SET_H2CCMD_RSVDPAGE_LOC_PROBE_RSP(u1rsvdpageloc, PROBERSP_PG);
+
+	totalpacketlen = TOTAL_RESERVED_PKT_LEN;
+
+	RT_PRINT_DATA(rtlpriv, COMP_CMD, DBG_LOUD,
+		      "rtl8723be_set_fw_rsvdpagepkt(): "
+		      "HW_VAR_SET_TX_CMD: ALL\n",
+		      &reserved_page_packet[0], totalpacketlen);
+	RT_PRINT_DATA(rtlpriv, COMP_CMD, DBG_DMESG,
+		      "rtl8723be_set_fw_rsvdpagepkt(): "
+		      "HW_VAR_SET_TX_CMD: ALL\n", u1rsvdpageloc, 3);
+
+
+	skb = dev_alloc_skb(totalpacketlen);
+	memcpy((u8 *)skb_put(skb, totalpacketlen),
+	       &reserved_page_packet, totalpacketlen);
+
+	rtstatus = rtl8723_cmd_send_packet(hw, skb);
+
+	if (rtstatus)
+		dlok = true;
+
+	if (dlok) {
+		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
+			 "Set RSVD page location to Fw.\n");
+		RT_PRINT_DATA(rtlpriv, COMP_CMD, DBG_DMESG, "H2C_RSVDPAGE:\n",
+			      u1rsvdpageloc, 3);
+		rtl8723_fill_h2c_cmd(hw, H2C_88E_RSVDPAGE,
+				     sizeof(u1rsvdpageloc), u1rsvdpageloc);
+	} else {
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
+			 "Set RSVD page location to Fw FAIL!!!!!!.\n");
+	}
+}
+EXPORT_SYMBOL_GPL(rtl8723_set_fw_rsvdpagepkt);
+
+/*Should check FW support p2p or not.*/
+void rtl8723_set_p2p_ctw_period_cmd(struct ieee80211_hw *hw, u8 ctwindow)
+{
+	u8 u1_ctwindow_period[1] = {ctwindow};
+
+	rtl8723_fill_h2c_cmd(hw, H2C_88E_P2P_PS_CTW_CMD, 1,
+			     u1_ctwindow_period);
+}
+EXPORT_SYMBOL_GPL(rtl8723_set_p2p_ctw_period_cmd);
+
+void rtl8723_set_p2p_ps_offload_cmd(struct ieee80211_hw *hw, u8 p2p_ps_state)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_ps_ctl *rtlps = rtl_psc(rtl_priv(hw));
+	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
+	struct rtl_p2p_ps_info *p2pinfo = &(rtlps->p2p_ps_info);
+	struct p2p_ps_offload_t *p2p_ps_offload = &rtlhal->p2p_ps_offload;
+	u8 i;
+	u16 ctwindow;
+	u32 start_time, tsf_low;
+
+	switch (p2p_ps_state) {
+	case P2P_PS_DISABLE:
+		RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD, "P2P_PS_DISABLE\n");
+		memset(p2p_ps_offload, 0, sizeof(struct p2p_ps_offload_t *));
+		break;
+	case P2P_PS_ENABLE:
+		RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD, "P2P_PS_ENABLE\n");
+		/* update CTWindow value. */
+		if (p2pinfo->ctwindow > 0) {
+			p2p_ps_offload->ctwindow_en = 1;
+			ctwindow = p2pinfo->ctwindow;
+			rtl8723_set_p2p_ctw_period_cmd(hw, ctwindow);
+		}
+		/* hw only support 2 set of NoA */
+		for (i = 0; i < p2pinfo->noa_num; i++) {
+			/* To control the register setting
+			 * for which NOA
+			 */
+			rtl_write_byte(rtlpriv, 0x5cf, (i << 4));
+			if (i == 0)
+				p2p_ps_offload->noa0_en = 1;
+			else
+				p2p_ps_offload->noa1_en = 1;
+
+			/* config P2P NoA Descriptor Register */
+			rtl_write_dword(rtlpriv, 0x5E0,
+					p2pinfo->noa_duration[i]);
+			rtl_write_dword(rtlpriv, 0x5E4,
+					p2pinfo->noa_interval[i]);
+
+			/*Get Current TSF value */
+			tsf_low = rtl_read_dword(rtlpriv, REG_TSFTR);
+
+			start_time = p2pinfo->noa_start_time[i];
+			if (p2pinfo->noa_count_type[i] != 1) {
+				while (start_time <= (tsf_low + (50 * 1024))) {
+					start_time += p2pinfo->noa_interval[i];
+					if (p2pinfo->noa_count_type[i] != 255)
+						p2pinfo->noa_count_type[i]--;
+				}
+			}
+			rtl_write_dword(rtlpriv, 0x5E8, start_time);
+			rtl_write_dword(rtlpriv, 0x5EC,
+					p2pinfo->noa_count_type[i]);
+		}
+		if ((p2pinfo->opp_ps == 1) ||
+		    (p2pinfo->noa_num > 0)) {
+			/* rst p2p circuit */
+			rtl_write_byte(rtlpriv, REG_DUAL_TSF_RST, BIT(4));
+
+			p2p_ps_offload->offload_en = 1;
+
+			if (P2P_ROLE_GO == rtlpriv->mac80211.p2p) {
+				p2p_ps_offload->role = 1;
+				p2p_ps_offload->allstasleep = 0;
+			} else {
+				p2p_ps_offload->role = 0;
+			}
+			p2p_ps_offload->discovery = 0;
+		}
+		break;
+	case P2P_PS_SCAN:
+		RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD, "P2P_PS_SCAN\n");
+		p2p_ps_offload->discovery = 1;
+		break;
+	case P2P_PS_SCAN_DONE:
+		RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD, "P2P_PS_SCAN_DONE\n");
+		p2p_ps_offload->discovery = 0;
+		p2pinfo->p2p_ps_state = P2P_PS_ENABLE;
+		break;
+	default:
+		break;
+	}
+	rtl8723_fill_h2c_cmd(hw, H2C_88E_P2P_PS_OFFLOAD, 1,
+			     (u8 *)p2p_ps_offload);
+}
+EXPORT_SYMBOL_GPL(rtl8723_set_p2p_ps_offload_cmd);
+
+#endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8723com/fw_common.h b/drivers/net/wireless/rtlwifi/rtl8723com/fw_common.h
new file mode 100644
index 0000000..0890e5d
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/rtl8723com/fw_common.h
@@ -0,0 +1,50 @@
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
+#ifndef __FW_COMMON_H__
+#define __FW_COMMON_H__#endif
+
+void rtl8723_enable_fw_download(struct ieee80211_hw *hw, bool enable);
+void rtl8723_fw_block_write(struct ieee80211_hw *hw,
+			    const u8 *buffer, u32 size);
+void rtl8723_fw_page_write(struct ieee80211_hw *hw,
+			   u32 page, const u8 *buffer, u32 size);
+void rtl8723_write_fw(struct ieee80211_hw *hw,
+		      enum version_8723be version,
+		      u8 *buffer, u32 size);
+int rtl8723_fw_free_to_go(struct ieee80211_hw *hw, bool is_8723be);
+int rtl8723_download_fw(struct ieee80211_hw *hw,
+			bool buse_wake_on_wlan_fw, bool is_8723be);
+bool rtl8723_check_fw_read_last_h2c(struct ieee80211_hw *hw, u8 boxnum);
+void rtl8723_fill_h2c_command(struct ieee80211_hw *hw, u8 element_id,
+			      u32 cmd_len, u8 *p_cmdbuffer);
+void rtl8723_fill_h2c_cmd(struct ieee80211_hw *hw, u8 element_id,
+			  u32 cmd_len, u8 *p_cmdbuffer);
+void rtl8723_set_fw_joinbss_report_cmd(struct ieee80211_hw *hw, u8 mstatus);
+bool rtl8723_cmd_send_packet(struct ieee80211_hw *hw,
+			     struct sk_buff *skb);
+void rtl8723_set_fw_rsvdpagepkt(struct ieee80211_hw *hw, bool dl_finished);
+void rtl8723_set_p2p_ctw_period_cmd(struct ieee80211_hw *hw, u8 ctwindow);
+void rtl8723_set_p2p_ps_offload_cmd(struct ieee80211_hw *hw, u8 p2p_ps_state);
diff --git a/drivers/net/wireless/rtlwifi/rtl8723com/phy_common.h b/drivers/net/wireless/rtlwifi/rtl8723com/phy_common.h
new file mode 100644
index 0000000..8f451d0
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/rtl8723com/phy_common.h
@@ -0,0 +1,75 @@
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
+#ifndef __PHY_COMMON__
+#define __PHY_COMMON__
+
+u32 rtl8723_phy_query_bb_reg(struct ieee80211_hw *hw,
+			     u32 regaddr, u32 bitmask);
+void rtl8723_phy_set_bb_reg(struct ieee80211_hw *hw, u32 regaddr,
+			      u32 bitmask, u32 data);
+u32 rtl8723_phy_calculate_bit_shift(u32 bitmask);
+u32 rtl8723_phy_rf_serial_read(struct ieee80211_hw *hw,
+			       enum radio_path rfpath, u32 offset);
+void rtl8723_phy_rf_serial_write(struct ieee80211_hw *hw,
+				 enum radio_path rfpath,
+				 u32 offset, u32 data);
+u32 rtl8723_phy_query_bb_reg(struct ieee80211_hw *hw,
+			     u32 regaddr, u32 bitmask);
+u32 rtl8723_phy_calculate_bit_shift(u32 bitmask);
+void rtl8723_phy_set_bb_reg(struct ieee80211_hw *hw, u32 regaddr,
+			    u32 bitmask, u32 data);
+long rtl8723_phy_txpwr_idx_to_dbm(struct ieee80211_hw *hw,
+				  enum wireless_mode wirelessmode,
+				  u8 txpwridx);
+void rtl8723_phy_init_bb_rf_reg_def(struct ieee80211_hw *hw);
+bool rtl8723_phy_set_sw_chnl_cmdarray(struct swchnlcmd *cmdtable,
+				      u32 cmdtableidx,
+				      u32 cmdtablesz,
+				      enum swchnlcmd_id cmdid,
+				      u32 para1, u32 para2,
+				      u32 msdelay);
+void rtl8723_phy_path_a_fill_iqk_matrix(struct ieee80211_hw *hw,
+					bool iqk_ok,
+					long result[][8],
+					u8 final_candidate,
+					bool btxonly);
+void rtl8723_save_adda_registers(struct ieee80211_hw *hw, u32 *addareg,
+				 u32 *addabackup, u32 registernum);
+static void rtl8723_phy_save_mac_registers(struct ieee80211_hw *hw,
+					   u32 *macreg, u32 *macbackup);
+void rtl8723_phy_reload_adda_registers(struct ieee80211_hw *hw,
+				       u32 *addareg, u32 *addabackup,
+				       u32 regiesternum);
+void rtl8723_phy_reload_mac_registers(struct ieee80211_hw *hw,
+				      u32 *macreg, u32 *macbackup);
+void rtl8723_phy_path_adda_on(struct ieee80211_hw *hw, u32 *addareg,
+			      bool is_patha_on, bool is2t);
+void rtl8723_phy_mac_setting_calibration(struct ieee80211_hw *hw,
+					 u32 *macreg, u32 *macbackup);
+void rtl8723_phy_path_a_standby(struct ieee80211_hw *hw);
+void rtl8723_phy_pi_mode_switch(struct ieee80211_hw *hw, bool pi_mode);
+
+#endif
-- 
1.8.4.5
