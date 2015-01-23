From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH 6/6] rtlwifi: btcoexist: Enable new routines for RTL8812AE
Date: Fri, 23 Jan 2015 11:10:44 -0600
Message-ID: <1422033044-7461-7-git-send-email-Larry.Finger@lwfinger.net>
References: <1422033044-7461-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Troy Tan <troy_tan-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
To: kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1422033044-7461-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Troy Tan <troy_tan-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>

In addition to turning on the build of the new routines, there are several
fixes found by Realtek engineers.

Signed-off-by: Troy Tan <troy_tan-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>
Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---
 drivers/net/wireless/rtlwifi/btcoexist/Makefile    |   9 +
 .../net/wireless/rtlwifi/btcoexist/halbt_precomp.h |   3 +
 .../wireless/rtlwifi/btcoexist/halbtc8192e2ant.c   |   6 +-
 .../wireless/rtlwifi/btcoexist/halbtc8723b2ant.h   |   6 +-
 .../wireless/rtlwifi/btcoexist/halbtc8812a2ant.h   |   4 +-
 .../net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c  | 711 ++++++++++++++++-----
 .../net/wireless/rtlwifi/btcoexist/halbtcoutsrc.h  |  24 +
 drivers/net/wireless/rtlwifi/btcoexist/rtl_btc.c   |  37 ++
 drivers/net/wireless/rtlwifi/btcoexist/rtl_btc.h   |   6 +-
 drivers/net/wireless/rtlwifi/core.c                |  17 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/hal_btc.h   |  14 -
 drivers/net/wireless/rtlwifi/wifi.h                |  12 +-
 12 files changed, 676 insertions(+), 173 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/btcoexist/Makefile b/drivers/net/wireless/rtlwifi/btcoexist/Makefile
index 47ceecf..a86e0c2 100644
--- a/drivers/net/wireless/rtlwifi/btcoexist/Makefile
+++ b/drivers/net/wireless/rtlwifi/btcoexist/Makefile
@@ -1,5 +1,14 @@
 btcoexist-objs :=	halbtc8723b2ant.o	\
 			halbtcoutsrc.o		\
+			halbtc8192e2ant.o	\
+			halbtc8723b1ant.o	\
+			halbtc8723b2ant.o	\
+			halbtc8812a_ext.o	\
+			halbtc8821a1ant.o	\
+			halbtc8821a2ant.o	\
+			halbtc8812a2ant.o	\
+			halbtc8812a1ant.o	\
+			halbtcoutsrc.o		\
 			rtl_btc.o
 
 obj-$(CONFIG_RTLBTCOEXIST) += btcoexist.o
diff --git a/drivers/net/wireless/rtlwifi/btcoexist/halbt_precomp.h b/drivers/net/wireless/rtlwifi/btcoexist/halbt_precomp.h
index 39b9a33..c56ad98 100644
--- a/drivers/net/wireless/rtlwifi/btcoexist/halbt_precomp.h
+++ b/drivers/net/wireless/rtlwifi/btcoexist/halbt_precomp.h
@@ -42,6 +42,9 @@
 #include "halbtc8723b2ant.h"
 #include "halbtc8821a2ant.h"
 #include "halbtc8821a1ant.h"
+#include "halbtc8812a2ant.h"
+#include "halbtc8812a1ant.h"
+#include "halbtc8812a_ext.h"
 
 #define GetDefaultAdapter(padapter)	padapter
 
diff --git a/drivers/net/wireless/rtlwifi/btcoexist/halbtc8192e2ant.c b/drivers/net/wireless/rtlwifi/btcoexist/halbtc8192e2ant.c
index 53261d6..c33c37f 100644
--- a/drivers/net/wireless/rtlwifi/btcoexist/halbtc8192e2ant.c
+++ b/drivers/net/wireless/rtlwifi/btcoexist/halbtc8192e2ant.c
@@ -1367,16 +1367,14 @@ static void halbtc8192e2ant_set_switch_sstype(struct btc_coexist *btcoexist,
 		btcoexist->btc_write_1byte(btcoexist, 0xd04, 0x1);
 		btcoexist->btc_write_4byte(btcoexist, 0x90c, 0x81111111);
 		/* switch cck patch */
-		btcoexist->btc_write_1byte_bitmask(btcoexist, 0xe77, 0x4, 0x1);
-		btcoexist->btc_write_1byte(btcoexist, 0xa07, 0x81);
+
 		mimops = BTC_MIMO_PS_STATIC;
 	} else if (sstype == 2) {
 		halbtc8192e2ant_ps_tdma(btcoexist, FORCE_EXEC, false, 0);
 		btcoexist->btc_write_1byte(btcoexist, 0xc04, 0x33);
 		btcoexist->btc_write_1byte(btcoexist, 0xd04, 0x3);
 		btcoexist->btc_write_4byte(btcoexist, 0x90c, 0x81121313);
-		btcoexist->btc_write_1byte_bitmask(btcoexist, 0xe77, 0x4, 0x0);
-		btcoexist->btc_write_1byte(btcoexist, 0xa07, 0x41);
+
 		mimops = BTC_MIMO_PS_DYNAMIC;
 	}
 	/* set rx 1ss or 2ss */
diff --git a/drivers/net/wireless/rtlwifi/btcoexist/halbtc8723b2ant.h b/drivers/net/wireless/rtlwifi/btcoexist/halbtc8723b2ant.h
index 567f354..ea6e383 100644
--- a/drivers/net/wireless/rtlwifi/btcoexist/halbtc8723b2ant.h
+++ b/drivers/net/wireless/rtlwifi/btcoexist/halbtc8723b2ant.h
@@ -160,11 +160,11 @@ void ex_btc8723b2ant_lps_notify(struct btc_coexist *btcoexist, u8 type);
 void ex_btc8723b2ant_scan_notify(struct btc_coexist *btcoexist, u8 type);
 void ex_btc8723b2ant_connect_notify(struct btc_coexist *btcoexist, u8 type);
 void ex_btc8723b2ant_media_status_notify(struct btc_coexist *btcoexist,
-					 u8 type);
+					    u8 type);
 void ex_btc8723b2ant_special_packet_notify(struct btc_coexist *btcoexist,
-					   u8 type);
+					      u8 type);
 void ex_btc8723b2ant_bt_info_notify(struct btc_coexist *btcoexist,
-				    u8 *tmpbuf, u8 length);
+				       u8 *tmpbuf, u8 length);
 void ex_btc8723b2ant_halt_notify(struct btc_coexist *btcoexist);
 void ex_btc8723b2ant_periodical(struct btc_coexist *btcoexist);
 void ex_btc8723b2ant_display_coex_info(struct btc_coexist *btcoexist);
diff --git a/drivers/net/wireless/rtlwifi/btcoexist/halbtc8812a2ant.h b/drivers/net/wireless/rtlwifi/btcoexist/halbtc8812a2ant.h
index 0c02134..48ecdeb 100644
--- a/drivers/net/wireless/rtlwifi/btcoexist/halbtc8812a2ant.h
+++ b/drivers/net/wireless/rtlwifi/btcoexist/halbtc8812a2ant.h
@@ -162,8 +162,8 @@ void ex_halbtc8812a2ant_ips_notify(struct btc_coexist *btcoexist, u8 type);
 void ex_halbtc8812a2ant_lps_notify(struct btc_coexist *btcoexist, u8 type);
 void ex_halbtc8812a2ant_scan_notify(struct btc_coexist *btcoexist, u8 type);
 void ex_halbtc8812a2ant_connect_notify(struct btc_coexist *btcoexist, u8 type);
-void ex_halbtc8812a2ant_media_status_notify(struct btc_coexist *btcoexist,
-					    u8 type);
+void ex_btc8812a2ant_media_stat_notify(struct btc_coexist *btcoexist,
+				       u8 type);
 void ex_halbtc8812a2ant_special_packet_notify(struct btc_coexist *btcoexist,
 					      u8 type);
 void ex_halbtc8812a2ant_bt_info_notify(struct btc_coexist *btcoexist,
diff --git a/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c b/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c
index 7a72636..c428a59 100644
--- a/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c
+++ b/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c
@@ -11,23 +11,58 @@
  * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
  * more details.
  *
- * The full GNU General Public License is included in this distribution in the
- * file called LICENSE.
- *
- * Contact Information:
- * wlanfae <wlanfae-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
- * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Park,
- * Hsinchu 300, Taiwan.
- *
- * Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
- *
  ******************************************************************************/
 
 #include "halbt_precomp.h"
 
+/*#if (BT_30_SUPPORT == 1)*/
+#if 1
 /***********************************************
  *		Global variables
  ***********************************************/
+static const char *const bt_profile_string[] = {
+	"NONE",
+	"A2DP",
+	"PAN",
+	"HID",
+	"SCO",
+};
+
+static const char *const bt_spec_string[] = {
+	"1.0b",
+	"1.1",
+	"1.2",
+	"2.0+EDR",
+	"2.1+EDR",
+	"3.0+HS",
+	"4.0",
+};
+
+static const char *const bt_link_role_string[] = {
+	"Master",
+	"Slave",
+};
+
+static const char *const h2c_state_string[] = {
+	"successful",
+	"h2c busy",
+	"rf off",
+	"fw not read",
+};
+
+static const char *const io_state_string[] = {
+	"IO_STATUS_SUCCESS",
+	"IO_STATUS_FAIL_CANNOT_IO",
+	"IO_STATUS_FAIL_RF_OFF",
+	"IO_STATUS_FAIL_FW_READ_CLEAR_TIMEOUT",
+	"IO_STATUS_FAIL_WAIT_IO_EVENT_TIMEOUT",
+	"IO_STATUS_INVALID_LEN",
+	"IO_STATUS_IO_IDLE_QUEUE_EMPTY",
+	"IO_STATUS_IO_INSERT_WAIT_QUEUE_FAIL",
+	"IO_STATUS_UNKNOWN_FAIL",
+	"IO_STATUS_WRONG_LEVEL",
+	"IO_STATUS_H2C_STOPPED",
+};
 
 struct btc_coexist gl_bt_coexist;
 
@@ -36,6 +71,34 @@ u32 btc_dbg_type[BTC_MSG_MAX];
 /***************************************************
  *		Debug related function
  ***************************************************/
+static bool is_any_client_connect_to_ap(struct btc_coexist *btcoexist)
+{
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+	struct rtl_mac *mac = rtl_mac(rtlpriv);
+	struct rtl_sta_info *drv_priv;
+	u8 cnt = 0;
+
+	if (mac->opmode == NL80211_IFTYPE_ADHOC ||
+	    mac->opmode == NL80211_IFTYPE_MESH_POINT ||
+	    mac->opmode == NL80211_IFTYPE_AP) {
+		if (in_interrupt() > 0) {
+			list_for_each_entry(drv_priv, &rtlpriv->entry_list,
+					    list)
+				cnt++;
+		} else {
+			spin_lock_bh(&rtlpriv->locks.entry_list_lock);
+			list_for_each_entry(drv_priv, &rtlpriv->entry_list,
+					    list)
+				cnt++;
+			spin_unlock_bh(&rtlpriv->locks.entry_list_lock);
+		}
+	}
+	if (cnt > 0)
+		return true;
+	else
+		return false;
+}
+
 static bool halbtc_is_bt_coexist_available(struct btc_coexist *btcoexist)
 {
 	if (!btcoexist->binded || NULL == btcoexist->adapter)
@@ -59,23 +122,9 @@ static void halbtc_dbg_init(void)
 	for (i = 0; i < BTC_MSG_MAX; i++)
 		btc_dbg_type[i] = 0;
 
-	btc_dbg_type[BTC_MSG_INTERFACE] =
-/*			INTF_INIT				| */
-/*			INTF_NOTIFY				| */
-			0;
-
-	btc_dbg_type[BTC_MSG_ALGORITHM] =
-/*			ALGO_BT_RSSI_STATE			| */
-/*			ALGO_WIFI_RSSI_STATE			| */
-/*			ALGO_BT_MONITOR				| */
-/*			ALGO_TRACE				| */
-/*			ALGO_TRACE_FW				| */
-/*			ALGO_TRACE_FW_DETAIL			| */
-/*			ALGO_TRACE_FW_EXEC			| */
-/*			ALGO_TRACE_SW				| */
-/*			ALGO_TRACE_SW_DETAIL			| */
-/*			ALGO_TRACE_SW_EXEC			| */
-			0;
+	btc_dbg_type[BTC_MSG_INTERFACE] = 0;
+
+	btc_dbg_type[BTC_MSG_ALGORITHM] = 0;
 }
 
 static bool halbtc_is_bt40(struct rtl_priv *adapter)
@@ -142,7 +191,7 @@ static u8 halbtc_get_wifi_central_chnl(struct btc_coexist *btcoexist)
 	if (rtlphy->current_channel != 0)
 		chnl = rtlphy->current_channel;
 	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
-		  "static halbtc_get_wifi_central_chnl:%d\n", chnl);
+		  "halbtc_get_wifi_central_chnl:%d\n", chnl);
 	return chnl;
 }
 
@@ -159,12 +208,14 @@ static void halbtc_leave_lps(struct btc_coexist *btcoexist)
 			   &ap_enable);
 
 	if (ap_enable) {
-		pr_info("halbtc_leave_lps()<--dont leave lps under AP mode\n");
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "halbtc_leave_lps()<--dont leave lps under AP mode\n");
 		return;
 	}
 
 	btcoexist->bt_info.bt_ctrl_lps = true;
 	btcoexist->bt_info.bt_lps_on = false;
+	rtl_lps_leave(rtlpriv->mac80211.hw);
 }
 
 static void halbtc_enter_lps(struct btc_coexist *btcoexist)
@@ -180,12 +231,14 @@ static void halbtc_enter_lps(struct btc_coexist *btcoexist)
 			   &ap_enable);
 
 	if (ap_enable) {
-		pr_info("halbtc_enter_lps()<--dont enter lps under AP mode\n");
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "halbtc_enter_lps()<--dont enter lps under AP mode\n");
 		return;
 	}
 
 	btcoexist->bt_info.bt_ctrl_lps = true;
 	btcoexist->bt_info.bt_lps_on = false;
+	rtl_lps_enter(rtlpriv->mac80211.hw);
 }
 
 static void halbtc_normal_lps(struct btc_coexist *btcoexist)
@@ -194,27 +247,54 @@ static void halbtc_normal_lps(struct btc_coexist *btcoexist)
 		btcoexist->bt_info.bt_lps_on = false;
 		btcoexist->bt_info.bt_ctrl_lps = false;
 	}
-}
 
-static void halbtc_leave_low_power(void)
-{
 }
 
-static void halbtc_nomal_low_power(void)
+static u32 halbtcoutsrc_get_wifi_link_status(struct btc_coexist *btcoexist)
 {
-}
+	/*------------------------------------
+	 * return value:
+	 * [31:16]=> connected port number
+	 * [15:0]=> port connected bit define
+	 *------------------------------------
+	 */
 
-static void halbtc_disable_low_power(void)
-{
-}
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+	struct rtl_mac *mac = rtl_mac(rtlpriv);
+	u32 ret_val = 0;
+	u32 port_connected_status = 0, num_of_connected_port = 0;
 
-static void halbtc_aggregation_check(void)
-{
+	if (mac->opmode == NL80211_IFTYPE_STATION &&
+	    mac->link_state >= MAC80211_LINKED) {
+		port_connected_status |= WIFI_STA_CONNECTED;
+		num_of_connected_port++;
+	}
+	/* AP & ADHOC & MESH */
+	if (is_any_client_connect_to_ap(btcoexist)) {
+		port_connected_status |= WIFI_AP_CONNECTED;
+		num_of_connected_port++;
+	}
+	/* TODO: * P2P Connected Status	*/
+
+	ret_val = (num_of_connected_port << 16) | port_connected_status;
+
+	return ret_val;
 }
 
 static u32 halbtc_get_bt_patch_version(struct btc_coexist *btcoexist)
 {
-	return 0;
+	u8	datalen = 2;
+	u8	buf[4] = {0};
+	u8	cnt = 0;
+
+	if (!btcoexist->bt_info.bt_real_fw_ver && cnt <= 5) {
+		buf[0] = 0x0;	/* OP_Code*/
+		buf[1] = 0x0;	/* OP_Code_Length*/
+		bt_sendeventextbtcoexcontrol(btcoexist->adapter, false,
+					     datalen, &buf[0]);
+		cnt++;
+	}
+	return btcoexist->bt_info.bt_real_fw_ver;
 }
 
 static s32 halbtc_get_wifi_rssi(struct rtl_priv *adapter)
@@ -244,7 +324,6 @@ static bool halbtc_get(void *void_btcoexist, u8 get_type, void *out_buf)
 
 	if (!halbtc_is_bt_coexist_available(btcoexist))
 		return false;
-
 	switch (get_type) {
 	case BTC_GET_BL_HS_OPERATION:
 		*bool_tmp = false;
@@ -253,7 +332,10 @@ static bool halbtc_get(void *void_btcoexist, u8 get_type, void *out_buf)
 		*bool_tmp = false;
 		break;
 	case BTC_GET_BL_WIFI_CONNECTED:
-		if (rtlpriv->mac80211.link_state >= MAC80211_LINKED)
+		if (rtlpriv->mac80211.opmode == NL80211_IFTYPE_STATION &&
+		    rtlpriv->mac80211.link_state >= MAC80211_LINKED)
+			tmp = true;
+		if (is_any_client_connect_to_ap(btcoexist))
 			tmp = true;
 		*bool_tmp = tmp;
 		break;
@@ -276,14 +358,10 @@ static bool halbtc_get(void *void_btcoexist, u8 get_type, void *out_buf)
 			*bool_tmp = false;
 		break;
 	case BTC_GET_BL_WIFI_ROAM:	/*TODO*/
-		if (mac->link_state == MAC80211_LINKING)
-			*bool_tmp = true;
-		else
-			*bool_tmp = false;
+		*bool_tmp = false;
 		break;
 	case BTC_GET_BL_WIFI_4_WAY_PROGRESS:	/*TODO*/
-			*bool_tmp = false;
-
+		*bool_tmp = false;
 		break;
 	case BTC_GET_BL_WIFI_UNDER_5G:
 		*bool_tmp = false; /*TODO*/
@@ -309,7 +387,10 @@ static bool halbtc_get(void *void_btcoexist, u8 get_type, void *out_buf)
 			*bool_tmp = true;
 		break;
 	case BTC_GET_BL_WIFI_UNDER_B_MODE:
-		*bool_tmp = false; /*TODO*/
+		if (WIRELESS_MODE_B == rtlpriv->mac80211.mode)
+			*bool_tmp = true;
+		else
+			*bool_tmp = false;
 		break;
 	case BTC_GET_BL_EXT_SWITCH:
 		*bool_tmp = false;
@@ -330,7 +411,10 @@ static bool halbtc_get(void *void_btcoexist, u8 get_type, void *out_buf)
 			*u32_tmp = BTC_WIFI_TRAFFIC_RX;
 		break;
 	case BTC_GET_U4_WIFI_FW_VER:
-		*u32_tmp = rtlhal->fw_version;
+		*u32_tmp = (rtlhal->fw_version << 16) | rtlhal->fw_subversion;
+		break;
+	case BTC_GET_U4_WIFI_LINK_STATUS:
+		*u32_tmp = halbtcoutsrc_get_wifi_link_status(btcoexist);
 		break;
 	case BTC_GET_U4_BT_PATCH_VER:
 		*u32_tmp = halbtc_get_bt_patch_version(btcoexist);
@@ -342,13 +426,19 @@ static bool halbtc_get(void *void_btcoexist, u8 get_type, void *out_buf)
 		*u8_tmp = halbtc_get_wifi_central_chnl(btcoexist);
 		break;
 	case BTC_GET_U1_WIFI_HS_CHNL:
-		*u8_tmp = 1;/*BT_OperateChnl(rtlpriv);*/
+		*u8_tmp = 1;/* BT_OperateChnl(rtlpriv); */
 		break;
 	case BTC_GET_U1_MAC_PHY_MODE:
 		*u8_tmp = BTC_MP_UNKNOWN;
 		break;
+	case BTC_GET_U1_AP_NUM:
+		/* driver don't know AP num in Linux,
+		 * So, the return value here is not right
+		 */
+		*u8_tmp = 1;/* pDefMgntInfo->NumBssDesc4Query; */
+		break;
 
-		/************* 1Ant **************/
+	/************* 1Ant **************/
 	case BTC_GET_U1_LPS_MODE:
 		*u8_tmp = btcoexist->pwr_mode_val[0];
 		break;
@@ -366,6 +456,7 @@ static bool halbtc_set(void *void_btcoexist, u8 set_type, void *in_buf)
 	bool *bool_tmp = (bool *)in_buf;
 	u8 *u8_tmp = (u8 *)in_buf;
 	u32 *u32_tmp = (u32 *)in_buf;
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
 
 	if (!halbtc_is_bt_coexist_available(btcoexist))
 		return false;
@@ -405,20 +496,16 @@ static bool halbtc_set(void *void_btcoexist, u8 set_type, void *in_buf)
 		/*BTHCI_SendGetBtRssiEvent(rtlpriv);*/
 		break;
 	case BTC_SET_ACT_AGGREGATE_CTRL:
-		halbtc_aggregation_check();
 		break;
 
 		/* 1Ant */
 	case BTC_SET_U1_RSSI_ADJ_VAL_FOR_1ANT_COEX_TYPE:
 		btcoexist->bt_info.rssi_adjust_for_1ant_coex_type = *u8_tmp;
 		break;
-	case BTC_SET_UI_SCAN_SIG_COMPENSATION:
-	/*	rtlpriv->mlmepriv.scan_compensation = *u8_tmp;  */
-		break;
-	case BTC_SET_U1_1ANT_LPS:
+	case BTC_SET_U1_LPS_VAL:
 		btcoexist->bt_info.lps_val = *u8_tmp;
 		break;
-	case BTC_SET_U1_1ANT_RPWM:
+	case BTC_SET_U1_RPWM_VAL:
 		btcoexist->bt_info.rpwm_val = *u8_tmp;
 		break;
 	/* the following are some action which will be triggered  */
@@ -432,7 +519,6 @@ static bool halbtc_set(void *void_btcoexist, u8 set_type, void *in_buf)
 		halbtc_normal_lps(btcoexist);
 		break;
 	case BTC_SET_ACT_DISABLE_LOW_POWER:
-		halbtc_disable_low_power();
 		break;
 	case BTC_SET_ACT_UPDATE_ra_mask:
 		btcoexist->bt_info.ra_mask = *u32_tmp;
@@ -442,9 +528,29 @@ static bool halbtc_set(void *void_btcoexist, u8 set_type, void *in_buf)
 	case BTC_SET_ACT_INC_FORCE_EXEC_PWR_CMD_CNT:
 		btcoexist->bt_info.force_exec_pwr_cmd_cnt++;
 		break;
-	case BTC_SET_ACT_CTRL_BT_INFO: /*wait for 8812/8821*/
+	/*8812 only*/
+	case BTC_SET_ACT_CTRL_BT_INFO:
+		{
+			u8 datalen = *u8_tmp;
+			u8 tmpbuf[20];
+
+			if (datalen)
+				memcpy(tmpbuf, u8_tmp+1, datalen);
+			bt_sendeventextbtinfocontrol(rtlpriv, datalen,
+						     &tmpbuf[0]);
+		}
 		break;
+	/*8812 only*/
 	case BTC_SET_ACT_CTRL_BT_COEX:
+		{
+			u8 datalen = *u8_tmp;
+			u8 tmpbuf[20];
+
+			if (datalen)
+				memcpy(tmpbuf, u8_tmp+1, datalen);
+			bt_sendeventextbtcoexcontrol(rtlpriv, false, datalen,
+						     &tmpbuf[0]);
+		}
 		break;
 	default:
 		break;
@@ -453,22 +559,6 @@ static bool halbtc_set(void *void_btcoexist, u8 set_type, void *in_buf)
 	return true;
 }
 
-static void halbtc_display_coex_statistics(struct btc_coexist *btcoexist)
-{
-}
-
-static void halbtc_display_bt_link_info(struct btc_coexist *btcoexist)
-{
-}
-
-static void halbtc_display_bt_fw_info(struct btc_coexist *btcoexist)
-{
-}
-
-static void halbtc_display_fw_pwr_mode_cmd(struct btc_coexist *btcoexist)
-{
-}
-
 /************************************************************
  *		IO related function
  ************************************************************/
@@ -512,10 +602,10 @@ static void halbtc_bitmask_write_1byte(void *bt_context, u32 reg_addr,
 	u8 original_value, bit_shift = 0;
 	u8 i;
 
-	if (bit_mask != MASKDWORD) {/*if not "double word" write*/
+	if (bit_mask != MASKBYTE0) {/*if not "byte" write*/
 		original_value = rtl_read_byte(rtlpriv, reg_addr);
 		for (i = 0; i <= 7; i++) {
-			if ((bit_mask>>i) & 0x1)
+			if ((bit_mask>>i)&0x1)
 				break;
 		}
 		bit_shift = i;
@@ -560,7 +650,7 @@ static u32 halbtc_get_bbreg(void *bt_context, u32 reg_addr, u32 bit_mask)
 }
 
 static void halbtc_set_rfreg(void *bt_context, u8 rf_path, u32 reg_addr,
-			     u32 bit_mask, u32 data)
+		      u32 bit_mask, u32 data)
 {
 	struct btc_coexist *btcoexist = (struct btc_coexist *)bt_context;
 	struct rtl_priv *rtlpriv = btcoexist->adapter;
@@ -578,7 +668,7 @@ static u32 halbtc_get_rfreg(void *bt_context, u8 rf_path, u32 reg_addr,
 }
 
 static void halbtc_fill_h2c_cmd(void *bt_context, u8 element_id,
-				u32 cmd_len, u8 *cmd_buf)
+			 u32 cmd_len, u8 *cmd_buf)
 {
 	struct btc_coexist *btcoexist = (struct btc_coexist *)bt_context;
 	struct rtl_priv *rtlpriv = btcoexist->adapter;
@@ -589,23 +679,22 @@ static void halbtc_fill_h2c_cmd(void *bt_context, u8 element_id,
 
 static void halbtc_display_dbg_msg(void *bt_context, u8 disp_type)
 {
-	struct btc_coexist *btcoexist =	(struct btc_coexist *)bt_context;
-	switch (disp_type) {
-	case BTC_DBG_DISP_COEX_STATISTICS:
-		halbtc_display_coex_statistics(btcoexist);
-		break;
-	case BTC_DBG_DISP_BT_LINK_INFO:
-		halbtc_display_bt_link_info(btcoexist);
-		break;
-	case BTC_DBG_DISP_BT_FW_VER:
-		halbtc_display_bt_fw_info(btcoexist);
-		break;
-	case BTC_DBG_DISP_FW_PWR_MODE_CMD:
-		halbtc_display_fw_pwr_mode_cmd(btcoexist);
-		break;
-	default:
-		break;
+}
+
+static bool halbtc_under_ips(struct btc_coexist *btcoexist)
+{
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+	struct rtl_ps_ctl *ppsc = rtl_psc(rtlpriv);
+	enum rf_pwrstate rtstate;
+
+	if (ppsc->inactiveps) {
+		rtstate = ppsc->rfpwr_state;
+
+		if (rtstate != ERFON &&
+		    ppsc->rfoff_reason == RF_CHANGE_BY_IPS)
+			return true;
 	}
+	return false;
 }
 
 /*****************************************************************
@@ -624,7 +713,7 @@ bool exhalbtc_initlize_variables(struct rtl_priv *adapter)
 	else
 		btcoexist->binded = true;
 
-	btcoexist->chip_interface = BTC_INTF_UNKNOWN;
+	btcoexist->chip_interface = BTC_INTF_PCI;
 
 	if (NULL == btcoexist->adapter)
 		btcoexist->adapter = adapter;
@@ -668,8 +757,25 @@ void exhalbtc_init_hw_config(struct btc_coexist *btcoexist)
 
 	btcoexist->statistics.cnt_init_hw_config++;
 
-	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723BE)
-		ex_btc8723b2ant_init_hwconfig(btcoexist);
+	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723BE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex_btc8723b2ant_init_hwconfig(btcoexist);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8723b1ant_init_hwconfig(btcoexist);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8192EE) {
+		ex_halbtc8192e2ant_init_hwconfig(btcoexist);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8821AE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex_halbtc8821a2ant_init_hwconfig(btcoexist);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8821a1ant_init_hwconfig(btcoexist);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8812AE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex_halbtc8812a2ant_init_hwconfig(btcoexist);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8812a1ant_init_hwconfig(btcoexist);
+	}
+
 }
 
 void exhalbtc_init_coex_dm(struct btc_coexist *btcoexist)
@@ -682,8 +788,24 @@ void exhalbtc_init_coex_dm(struct btc_coexist *btcoexist)
 
 	btcoexist->statistics.cnt_init_coex_dm++;
 
-	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723BE)
-		ex_btc8723b2ant_init_coex_dm(btcoexist);
+	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723BE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex_btc8723b2ant_init_coex_dm(btcoexist);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8723b1ant_init_coex_dm(btcoexist);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8192EE) {
+		ex_halbtc8192e2ant_init_coex_dm(btcoexist);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8821AE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex_halbtc8821a2ant_init_coex_dm(btcoexist);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8821a1ant_init_coex_dm(btcoexist);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8812AE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex_halbtc8812a2ant_init_coex_dm(btcoexist);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8812a1ant_init_coex_dm(btcoexist);
+	}
 
 	btcoexist->initilized = true;
 }
@@ -705,12 +827,24 @@ void exhalbtc_ips_notify(struct btc_coexist *btcoexist, u8 type)
 	else
 		ips_type = BTC_IPS_LEAVE;
 
-	halbtc_leave_low_power();
-
-	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723BE)
-		ex_btc8723b2ant_ips_notify(btcoexist, ips_type);
-
-	halbtc_nomal_low_power();
+	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723BE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex_btc8723b2ant_ips_notify(btcoexist, ips_type);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8723b1ant_ips_notify(btcoexist, ips_type);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8192EE) {
+		ex_halbtc8192e2ant_ips_notify(btcoexist, ips_type);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8821AE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex_halbtc8821a2ant_ips_notify(btcoexist, ips_type);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8821a1ant_ips_notify(btcoexist, ips_type);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8812AE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex_halbtc8812a2ant_ips_notify(btcoexist, ips_type);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8812a1ant_ips_notify(btcoexist, ips_type);
+	}
 }
 
 void exhalbtc_lps_notify(struct btc_coexist *btcoexist, u8 type)
@@ -730,8 +864,24 @@ void exhalbtc_lps_notify(struct btc_coexist *btcoexist, u8 type)
 	else
 		lps_type = BTC_LPS_ENABLE;
 
-	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723BE)
-		ex_btc8723b2ant_lps_notify(btcoexist, lps_type);
+	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723BE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex_btc8723b2ant_lps_notify(btcoexist, lps_type);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8723b1ant_lps_notify(btcoexist, lps_type);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8192EE) {
+		ex_halbtc8192e2ant_lps_notify(btcoexist, lps_type);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8821AE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex_halbtc8821a2ant_lps_notify(btcoexist, lps_type);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8821a1ant_lps_notify(btcoexist, lps_type);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8812AE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex_halbtc8812a2ant_lps_notify(btcoexist, lps_type);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8812a1ant_lps_notify(btcoexist, lps_type);
+	}
 }
 
 void exhalbtc_scan_notify(struct btc_coexist *btcoexist, u8 type)
@@ -751,12 +901,24 @@ void exhalbtc_scan_notify(struct btc_coexist *btcoexist, u8 type)
 	else
 		scan_type = BTC_SCAN_FINISH;
 
-	halbtc_leave_low_power();
-
-	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723BE)
-		ex_btc8723b2ant_scan_notify(btcoexist, scan_type);
-
-	halbtc_nomal_low_power();
+	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723BE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex_btc8723b2ant_scan_notify(btcoexist, scan_type);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8723b1ant_scan_notify(btcoexist, scan_type);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8192EE) {
+		ex_halbtc8192e2ant_scan_notify(btcoexist, scan_type);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8821AE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex_halbtc8821a2ant_scan_notify(btcoexist, scan_type);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8821a1ant_scan_notify(btcoexist, scan_type);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8812AE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex_halbtc8812a2ant_scan_notify(btcoexist, scan_type);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8812a1ant_scan_notify(btcoexist, scan_type);
+	}
 }
 
 void exhalbtc_connect_notify(struct btc_coexist *btcoexist, u8 action)
@@ -776,15 +938,31 @@ void exhalbtc_connect_notify(struct btc_coexist *btcoexist, u8 action)
 	else
 		asso_type = BTC_ASSOCIATE_FINISH;
 
-	halbtc_leave_low_power();
-
-	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723BE)
-		ex_btc8723b2ant_connect_notify(btcoexist, asso_type);
+	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723BE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex_btc8723b2ant_connect_notify(btcoexist, asso_type);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8723b1ant_connect_notify(btcoexist, asso_type);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8192EE) {
+		ex_halbtc8192e2ant_connect_notify(btcoexist, asso_type);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8821AE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex_halbtc8821a2ant_connect_notify(btcoexist, asso_type);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8821a1ant_connect_notify(btcoexist, asso_type);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8812AE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex_halbtc8812a2ant_connect_notify(btcoexist, asso_type);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8812a1ant_connect_notify(btcoexist, asso_type);
+	}
 }
 
 void exhalbtc_mediastatus_notify(struct btc_coexist *btcoexist,
 				 enum rt_media_status media_status)
 {
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
 	u8 status;
 
 	if (!halbtc_is_bt_coexist_available(btcoexist))
@@ -798,9 +976,30 @@ void exhalbtc_mediastatus_notify(struct btc_coexist *btcoexist,
 	else
 		status = BTC_MEDIA_DISCONNECT;
 
-	halbtc_leave_low_power();
-
-	halbtc_nomal_low_power();
+	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723BE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex_btc8723b2ant_media_status_notify(btcoexist,
+							    status);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8723b1ant_media_status_notify(btcoexist,
+							       status);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8192EE) {
+		ex_halbtc8192e2ant_media_status_notify(btcoexist, status);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8821AE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex_halbtc8821a2ant_media_status_notify(btcoexist,
+							       status);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8821a1ant_media_status_notify(btcoexist,
+							       status);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8812AE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex_btc8812a2ant_media_stat_notify(btcoexist,
+							  status);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_btc8812a1ant_media_stat_notify(btcoexist,
+							  status);
+	}
 }
 
 void exhalbtc_special_packet_notify(struct btc_coexist *btcoexist, u8 pkt_type)
@@ -815,15 +1014,39 @@ void exhalbtc_special_packet_notify(struct btc_coexist *btcoexist, u8 pkt_type)
 	if (btcoexist->manual_control)
 		return;
 
-	packet_type = BTC_PACKET_DHCP;
-
-	halbtc_leave_low_power();
-
-	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723BE)
-		ex_btc8723b2ant_special_packet_notify(btcoexist,
-						      packet_type);
+	if (PACKET_DHCP == pkt_type) {
+		packet_type = BTC_PACKET_DHCP;
+	} else if (PACKET_EAPOL == pkt_type) {
+		packet_type = BTC_PACKET_EAPOL;
+	} else if (PACKET_ARP == pkt_type) {
+		packet_type = BTC_PACKET_ARP;
+	} else {
+		packet_type = BTC_PACKET_UNKNOWN;
+		return;
+	}
 
-	halbtc_nomal_low_power();
+	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723BE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex_btc8723b2ant_special_packet_notify(btcoexist,
+							      packet_type);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8723b1ant_special_packet_notify(btcoexist,
+								 packet_type);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8821AE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex_halbtc8821a2ant_special_packet_notify(btcoexist,
+								 packet_type);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8821a1ant_special_packet_notify(btcoexist,
+								 packet_type);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8812AE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex_halbtc8812a2ant_special_packet_notify(btcoexist,
+								 packet_type);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8812a1ant_special_packet_notify(btcoexist,
+								 packet_type);
+	}
 }
 
 void exhalbtc_bt_info_notify(struct btc_coexist *btcoexist,
@@ -835,8 +1058,31 @@ void exhalbtc_bt_info_notify(struct btc_coexist *btcoexist,
 		return;
 	btcoexist->statistics.cnt_bt_info_notify++;
 
-	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723BE)
-		ex_btc8723b2ant_bt_info_notify(btcoexist, tmp_buf, length);
+	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723BE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex_btc8723b2ant_bt_info_notify(btcoexist, tmp_buf,
+						       length);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8723b1ant_bt_info_notify(btcoexist, tmp_buf,
+							  length);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8192EE) {
+			ex_halbtc8192e2ant_bt_info_notify(btcoexist, tmp_buf,
+							  length);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8821AE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex_halbtc8821a2ant_bt_info_notify(btcoexist, tmp_buf,
+							  length);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8821a1ant_bt_info_notify(btcoexist, tmp_buf,
+							  length);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8812AE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex_halbtc8812a2ant_bt_info_notify(btcoexist, tmp_buf,
+							  length);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8812a1ant_bt_info_notify(btcoexist, tmp_buf,
+							  length);
+	}
 }
 
 void exhalbtc_stack_operation_notify(struct btc_coexist *btcoexist, u8 type)
@@ -849,11 +1095,18 @@ void exhalbtc_stack_operation_notify(struct btc_coexist *btcoexist, u8 type)
 	if (btcoexist->manual_control)
 		return;
 
-	stack_op_type = BTC_STACK_OP_NONE;
-
-	halbtc_leave_low_power();
+	if ((HCI_BT_OP_INQUIRY_START == type) ||
+	    (HCI_BT_OP_PAGING_START == type) ||
+	    (HCI_BT_OP_PAIRING_START == type))
+		stack_op_type = BTC_STACK_OP_INQ_PAGE_PAIR_START;
+	else if ((HCI_BT_OP_INQUIRY_FINISH == type) ||
+		 (HCI_BT_OP_PAGING_SUCCESS == type) ||
+		 (HCI_BT_OP_PAGING_UNSUCCESS == type) ||
+		 (HCI_BT_OP_PAIRING_FINISH == type))
+		stack_op_type = BTC_STACK_OP_INQ_PAGE_PAIR_FINISH;
+	else
+		stack_op_type = BTC_STACK_OP_NONE;
 
-	halbtc_nomal_low_power();
 }
 
 void exhalbtc_halt_notify(struct btc_coexist *btcoexist)
@@ -863,42 +1116,168 @@ void exhalbtc_halt_notify(struct btc_coexist *btcoexist)
 	if (!halbtc_is_bt_coexist_available(btcoexist))
 		return;
 
-	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723BE)
-		ex_btc8723b2ant_halt_notify(btcoexist);
+	btcoexist->binded = false;
+
+	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723BE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex_btc8723b2ant_halt_notify(btcoexist);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8723b1ant_halt_notify(btcoexist);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8192EE) {
+		ex_halbtc8192e2ant_halt_notify(btcoexist);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8821AE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex_halbtc8821a2ant_halt_notify(btcoexist);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8821a1ant_halt_notify(btcoexist);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8812AE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex_halbtc8812a2ant_halt_notify(btcoexist);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8812a1ant_halt_notify(btcoexist);
+	}
 }
 
 void exhalbtc_pnp_notify(struct btc_coexist *btcoexist, u8 pnp_state)
 {
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
+
 	if (!halbtc_is_bt_coexist_available(btcoexist))
 		return;
+
+	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723BE) {
+		if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8723b1ant_pnp_notify(btcoexist, pnp_state);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8812AE) {
+		if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8812a1ant_pnp_notify(btcoexist, pnp_state);
+	}
 }
 
-void exhalbtc_periodical(struct btc_coexist *btcoexist)
+void exhalbtc_coex_dm_switch(struct btc_coexist *btcoexist)
 {
 	struct rtl_priv *rtlpriv = btcoexist->adapter;
 	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
+
 	if (!halbtc_is_bt_coexist_available(btcoexist))
 		return;
-	btcoexist->statistics.cnt_periodical++;
+	btcoexist->statistics.cnt_coex_dm_switch++;
+
+	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723BE) {
+		if (btcoexist->board_info.btdm_ant_num == 1) {
+			btcoexist->stop_coex_dm = true;
+			ex_halbtc8723b1ant_coex_dm_reset(btcoexist);
+			exhalbtc_set_ant_num(BT_COEX_ANT_TYPE_DETECTED, 2);
+			ex_btc8723b2ant_init_hwconfig(btcoexist);
+			ex_btc8723b2ant_init_coex_dm(btcoexist);
+			btcoexist->stop_coex_dm = false;
+		}
+	}
+}
 
-	halbtc_leave_low_power();
+void exhalbtc_periodical(struct btc_coexist *btcoexist)
+{
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
 
-	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723BE)
-		ex_btc8723b2ant_periodical(btcoexist);
+	if (!halbtc_is_bt_coexist_available(btcoexist))
+		return;
+	btcoexist->statistics.cnt_periodical++;
 
-	halbtc_nomal_low_power();
+	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723BE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex_btc8723b2ant_periodical(btcoexist);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8723b1ant_periodical(btcoexist);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8192EE) {
+		ex_halbtc8192e2ant_periodical(btcoexist);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8821AE) {
+		if (btcoexist->board_info.btdm_ant_num == 2) {
+			ex_halbtc8821a2ant_periodical(btcoexist);
+		} else if (btcoexist->board_info.btdm_ant_num == 1) {
+			if (!halbtc_under_ips(btcoexist))
+				ex_halbtc8821a1ant_periodical(btcoexist);
+		}
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8812AE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex_halbtc8812a2ant_periodical(btcoexist);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8812a1ant_periodical(btcoexist);
+	}
 }
 
 void exhalbtc_dbg_control(struct btc_coexist *btcoexist,
 			  u8 code, u8 len, u8 *data)
 {
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
+
 	if (!halbtc_is_bt_coexist_available(btcoexist))
 		return;
 	btcoexist->statistics.cnt_dbg_ctrl++;
+
+	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8812AE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex_halbtc8812a1ant_dbg_control(btcoexist, code,
+						       len, data);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8812a1ant_dbg_control(btcoexist, code,
+						       len, data);
+	}
 }
 
 void exhalbtc_stack_update_profile_info(void)
 {
+	struct btc_coexist *btcoexist = &gl_bt_coexist;
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+	struct bt_mgnt *btmgnt = &rtlpriv->coex_info.btmgnt;
+	u8 i;
+
+	if (!halbtc_is_bt_coexist_available(btcoexist))
+		return;
+
+	btcoexist->stack_info.profile_notified = true;
+
+	btcoexist->stack_info.num_of_link =
+		btmgnt->ext_config.number_of_acl +
+		btmgnt->ext_config.number_of_sco;
+
+	/* reset first*/
+	btcoexist->stack_info.bt_link_exist = false;
+	btcoexist->stack_info.sco_exist = false;
+	btcoexist->stack_info.acl_exist = false;
+	btcoexist->stack_info.a2dp_exist = false;
+	btcoexist->stack_info.hid_exist = false;
+	btcoexist->stack_info.num_of_hid = 0;
+	btcoexist->stack_info.pan_exist = false;
+
+	if (!btmgnt->ext_config.number_of_acl)
+		btcoexist->stack_info.min_bt_rssi = 0;
+
+	if (btcoexist->stack_info.num_of_link) {
+		btcoexist->stack_info.bt_link_exist = true;
+		if (btmgnt->ext_config.number_of_sco)
+			btcoexist->stack_info.sco_exist = true;
+		if (btmgnt->ext_config.number_of_acl)
+			btcoexist->stack_info.acl_exist = true;
+	}
+
+	for (i = 0; i < btmgnt->ext_config.number_of_acl; i++) {
+		if (BT_PROFILE_A2DP ==
+		    btmgnt->ext_config.acl_link[i].bt_profile) {
+			btcoexist->stack_info.a2dp_exist = true;
+		} else if (BT_PROFILE_PAN ==
+			   btmgnt->ext_config.acl_link[i].bt_profile) {
+			btcoexist->stack_info.pan_exist = true;
+		} else if (BT_PROFILE_HID ==
+			   btmgnt->ext_config.acl_link[i].bt_profile) {
+			btcoexist->stack_info.hid_exist = true;
+			btcoexist->stack_info.num_of_hid++;
+		} else {
+			btcoexist->stack_info.unknown_acl_exist = true;
+		}
+	}
 }
 
 void exhalbtc_update_min_bt_rssi(char bt_rssi)
@@ -970,8 +1349,29 @@ void exhalbtc_set_ant_num(u8 type, u8 ant_num)
 	if (BT_COEX_ANT_TYPE_PG == type) {
 		gl_bt_coexist.board_info.pg_ant_num = ant_num;
 		gl_bt_coexist.board_info.btdm_ant_num = ant_num;
+		/* The antenna position:
+		 * Main (default) or Aux for pgAntNum =2 && btdmAntNum =1.
+		 * The antenna position should be determined by
+		 * auto-detect mechanism.
+		 * The following is assumed to main,
+		 * and those must be modified
+		 * if y auto-detect mechanism is ready
+		 */
+		if ((gl_bt_coexist.board_info.pg_ant_num == 2) &&
+		    (gl_bt_coexist.board_info.btdm_ant_num == 1))
+			gl_bt_coexist.board_info.btdm_ant_pos =
+						       BTC_ANTENNA_AT_MAIN_PORT;
+		else
+			gl_bt_coexist.board_info.btdm_ant_pos =
+						       BTC_ANTENNA_AT_MAIN_PORT;
 	} else if (BT_COEX_ANT_TYPE_ANTDIV == type) {
 		gl_bt_coexist.board_info.btdm_ant_num = ant_num;
+		gl_bt_coexist.board_info.btdm_ant_pos =
+						       BTC_ANTENNA_AT_MAIN_PORT;
+	} else if (BT_COEX_ANT_TYPE_DETECTED == type) {
+		gl_bt_coexist.board_info.btdm_ant_num = ant_num;
+		gl_bt_coexist.board_info.btdm_ant_pos =
+						       BTC_ANTENNA_AT_MAIN_PORT;
 	}
 }
 
@@ -979,9 +1379,26 @@ void exhalbtc_display_bt_coex_info(struct btc_coexist *btcoexist)
 {
 	struct rtl_priv *rtlpriv = btcoexist->adapter;
 	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
+
 	if (!halbtc_is_bt_coexist_available(btcoexist))
 		return;
 
-	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723BE)
-		ex_btc8723b2ant_display_coex_info(btcoexist);
+	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723BE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex_btc8723b2ant_display_coex_info(btcoexist);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8723b1ant_display_coex_info(btcoexist);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8821AE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex_halbtc8821a2ant_display_coex_info(btcoexist);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8821a1ant_display_coex_info(btcoexist);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8812AE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex_halbtc8812a2ant_display_coex_info(btcoexist);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8812a1ant_display_coex_info(btcoexist);
+	}
 }
+
+#endif
diff --git a/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.h b/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.h
index 8c64acf..5bf7060 100644
--- a/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.h
+++ b/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.h
@@ -88,6 +88,7 @@ enum btc_chip_type {
 enum btc_msg_type {
 	BTC_MSG_INTERFACE	= 0x0,
 	BTC_MSG_ALGORITHM	= 0x1,
+	BTC_MSG_SOCKET	= 0x2,
 	BTC_MSG_MAX
 };
 
@@ -97,6 +98,11 @@ extern u32 btc_dbg_type[];
 #define		INTF_INIT				BIT0
 #define		INTF_NOTIFY				BIT2
 
+/* following is for BTC_MSG_SOCKET */
+#define		SOCKET_INIT				BIT0
+#define		SOCKET_CRITICAL				BIT1
+#define		SOCKET_NORMAL				BIT2
+
 /* following is for BTC_ALGORITHM */
 #define		ALGO_BT_RSSI_STATE			BIT0
 #define		ALGO_WIFI_RSSI_STATE			BIT1
@@ -508,4 +514,22 @@ void exhalbtc_signal_compensation(struct btc_coexist *btcoexist,
 void exhalbtc_lps_leave(struct btc_coexist *btcoexist);
 void exhalbtc_low_wifi_traffic_notify(struct btc_coexist *btcoexist);
 
+/**************for 8812AE BTCOEX**************/
+#define bt_sendeventextbtcoexcontrol(adap, needdbgrsp, datalen, data) \
+	rtl_btcoex_sendeventextbtcoexcontrol(adap, needdbgrsp, datalen, data)
+#define bt_sendeventextbtinfocontrol(adapter, datalen, pdata)		\
+	rtl_btcoex_sendeventextbtinfocontrol(adapter, datalen, pdata)
+void rtl_btcoex_sendeventextbtcoexcontrol(struct rtl_priv *rtlpriv,
+					  u8 needdbgrsp, u8 datalen,
+					  void *pdata);
+void rtl_btcoex_sendeventextbtinfocontrol(struct rtl_priv *rtlpriv, u8 datalen,
+					  void *pdata);
+
+void rtl_btcoex_dump_tx_msg(u8 *tx_msg, u8 len, u8 *msg_name);
+u8 rtl_btcoex_sendmsgbysocket(struct rtl_priv *rtlpriv, u8 *msg, u8 msg_size,
+			      bool force);
+void rtl_btcoex_sendscannotify(struct rtl_priv *rtlpriv, u8 scantype);
+void rtl_btcoex_init_socket(struct rtl_priv *rtlpriv);
+void rtl_btcoex_close_socket(struct rtl_priv *rtlpriv);
+
 #endif
diff --git a/drivers/net/wireless/rtlwifi/btcoexist/rtl_btc.c b/drivers/net/wireless/rtlwifi/btcoexist/rtl_btc.c
index b9b0cb7..a75b663 100644
--- a/drivers/net/wireless/rtlwifi/btcoexist/rtl_btc.c
+++ b/drivers/net/wireless/rtlwifi/btcoexist/rtl_btc.c
@@ -45,8 +45,23 @@ static struct rtl_btc_ops rtl_btc_operation = {
 	.btc_is_disable_edca_turbo = rtl_btc_is_disable_edca_turbo,
 	.btc_is_bt_disabled = rtl_btc_is_bt_disabled,
 	.btc_special_packet_notify = rtl_btc_special_packet_notify,
+	.btc_set_hci_version = rtl_btc_set_hci_version,
+	.btc_set_bt_patch_version = rtl_btc_set_bt_patch_version,
+	.btc_stack_update_profile_info = rtl_btc_stack_update_profile_info,
+	.btc_init_socket = rtl_btc_init_socket,
+	.btc_close_socket = rtl_btc_close_socket,
 };
 
+void rtl_btc_init_socket(struct rtl_priv *rtlpriv)
+{
+	rtl_btcoex_init_socket(rtlpriv);
+}
+
+void rtl_btc_close_socket(struct rtl_priv *rtlpriv)
+{
+	rtl_btcoex_close_socket(rtlpriv);
+}
+
 void rtl_btc_init_variables(struct rtl_priv *rtlpriv)
 {
 	exhalbtc_initlize_variables(rtlpriv);
@@ -75,6 +90,21 @@ void rtl_btc_init_hal_vars(struct rtl_priv *rtlpriv)
 	exhalbtc_set_ant_num(BT_COEX_ANT_TYPE_PG, ant_num);
 }
 
+void rtl_btc_stack_update_profile_info(void)
+{
+	exhalbtc_stack_update_profile_info();
+}
+
+void rtl_btc_set_bt_patch_version(u16 bt_hci_version, u16 bt_patch_version)
+{
+	exhalbtc_set_bt_patch_version(bt_hci_version, bt_patch_version);
+}
+
+void rtl_btc_set_hci_version(u16 hci_version)
+{
+	exhalbtc_set_hci_version(hci_version);
+}
+
 void rtl_btc_init_hw_config(struct rtl_priv *rtlpriv)
 {
 	exhalbtc_init_hw_config(&gl_bt_coexist);
@@ -93,6 +123,13 @@ void rtl_btc_lps_notify(struct rtl_priv *rtlpriv, u8 type)
 
 void rtl_btc_scan_notify(struct rtl_priv *rtlpriv, u8 scantype)
 {
+	/*for 8812AE+8761AU*/
+	struct bt_coex_info *pcoex_info = &rtlpriv->coex_info;
+	struct bt_mgnt *btmgnt = &pcoex_info->btmgnt;
+
+	if (btmgnt->ext_config.enable_wifi_scan_notify)
+		rtl_btcoex_sendscannotify(rtlpriv, scantype);
+
 	exhalbtc_scan_notify(&gl_bt_coexist, scantype);
 }
 
diff --git a/drivers/net/wireless/rtlwifi/btcoexist/rtl_btc.h b/drivers/net/wireless/rtlwifi/btcoexist/rtl_btc.h
index ccd5a0f..47b9837 100644
--- a/drivers/net/wireless/rtlwifi/btcoexist/rtl_btc.h
+++ b/drivers/net/wireless/rtlwifi/btcoexist/rtl_btc.h
@@ -43,7 +43,11 @@ bool rtl_btc_is_limited_dig(struct rtl_priv *rtlpriv);
 bool rtl_btc_is_disable_edca_turbo(struct rtl_priv *rtlpriv);
 bool rtl_btc_is_bt_disabled(struct rtl_priv *rtlpriv);
 void rtl_btc_special_packet_notify(struct rtl_priv *rtlpriv, u8 pkt_type);
-
+void rtl_btc_set_hci_version(u16 hci_version);
+void rtl_btc_set_bt_patch_version(u16 bt_hci_version, u16 bt_patch_version);
+void rtl_btc_stack_update_profile_info(void);
+void rtl_btc_init_socket(struct rtl_priv *rtlpriv);
+void rtl_btc_close_socket(struct rtl_priv *rtlpriv);
 struct rtl_btc_ops *rtl_btc_get_ops_pointer(void);
 
 u8 rtl_get_hwpg_ant_num(struct rtl_priv *rtlpriv);
diff --git a/drivers/net/wireless/rtlwifi/core.c b/drivers/net/wireless/rtlwifi/core.c
index 3c8d504..9d72911 100644
--- a/drivers/net/wireless/rtlwifi/core.c
+++ b/drivers/net/wireless/rtlwifi/core.c
@@ -164,8 +164,17 @@ static int rtl_op_start(struct ieee80211_hw *hw)
 		return 0;
 	mutex_lock(&rtlpriv->locks.conf_mutex);
 	err = rtlpriv->intf_ops->adapter_start(hw);
-	if (!err)
+	if (!err) {
+		/*add troy for 8812AE bt coex*/
+		if (1 == rtlpriv->btcoexist.btc_info.btcoexist &&
+		    rtlhal->hw_type == HARDWARE_TYPE_RTL8812AE) {
+			pr_info("now that bt exists, init socket for 8812AE");
+			rtlpriv->btcoexist.btc_ops->btc_init_socket(rtlpriv);
+			rtlpriv->coex_info.btmgnt.ext_config.hci_ext_ver = 0x04;
+			rtlpriv->btcoexist.btc_ops->btc_set_hci_version(0x04);
+		}
 		rtl_watch_dog_timer_callback((unsigned long)hw);
+	}
 	mutex_unlock(&rtlpriv->locks.conf_mutex);
 	return err;
 }
@@ -205,6 +214,12 @@ static void rtl_op_stop(struct ieee80211_hw *hw)
 	}
 	rtlpriv->intf_ops->adapter_stop(hw);
 
+	if (1 == rtlpriv->btcoexist.btc_info.btcoexist &&
+	    rtlhal->hw_type == HARDWARE_TYPE_RTL8812AE) {
+		pr_info("close socket for 8812AE + 8761AU\n");
+		/*troy add for 8812 btcoex*/
+		rtlpriv->btcoexist.btc_ops->btc_close_socket(rtlpriv);
+	}
 	mutex_unlock(&rtlpriv->locks.conf_mutex);
 }
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/hal_btc.h b/drivers/net/wireless/rtlwifi/rtl8723ae/hal_btc.h
index 3723d74..56936da 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/hal_btc.h
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/hal_btc.h
@@ -70,20 +70,6 @@
 #define C2H_EVT_HOST_CLOSE		0x00
 #define C2H_EVT_FW_CLOSE		0xFF
 
-enum bt_traffic_mode {
-	BT_MOTOR_EXT_BE = 0x00,
-	BT_MOTOR_EXT_GUL = 0x01,
-	BT_MOTOR_EXT_GUB = 0x02,
-	BT_MOTOR_EXT_GULB = 0x03
-};
-
-enum bt_traffic_mode_profile {
-	BT_PROFILE_NONE,
-	BT_PROFILE_A2DP,
-	BT_PROFILE_PAN,
-	BT_PROFILE_HID,
-	BT_PROFILE_SCO
-};
 
 /*
 enum hci_ext_bt_operation {
diff --git a/drivers/net/wireless/rtlwifi/wifi.h b/drivers/net/wireless/rtlwifi/wifi.h
index 413c2ab..8d1a02c 100644
--- a/drivers/net/wireless/rtlwifi/wifi.h
+++ b/drivers/net/wireless/rtlwifi/wifi.h
@@ -36,7 +36,7 @@
 #include <net/mac80211.h>
 #include <linux/completion.h>
 #include "debug.h"
-
+#include "btcoexist/halbtc8812a_ext.h"
 #define	MASKBYTE0				0xff
 #define	MASKBYTE1				0xff00
 #define	MASKBYTE2				0xff0000
@@ -2311,6 +2311,7 @@ struct rtl_works {
 	struct workqueue_struct *rtl_wq;
 	struct delayed_work watchdog_wq;
 	struct delayed_work ips_nic_off_wq;
+	struct delayed_work socket_wq;
 
 	/* For SW LPS */
 	struct delayed_work ps_work;
@@ -2516,6 +2517,12 @@ struct rtl_btc_ops {
 	bool (*btc_is_bt_disabled) (struct rtl_priv *rtlpriv);
 	void (*btc_special_packet_notify)(struct rtl_priv *rtlpriv,
 					  u8 pkt_type);
+	void (*btc_set_hci_version)(u16 hci_version);
+	void (*btc_set_bt_patch_version)(u16 bt_hci_version,
+					 u16 bt_patch_version);
+	void (*btc_stack_update_profile_info)(void);
+	void (*btc_init_socket)(struct rtl_priv *rtlpriv);
+	void (*btc_close_socket)(struct rtl_priv *rtlpriv);
 };
 
 struct proxim {
@@ -2547,6 +2554,9 @@ struct rtl_priv {
 	struct rtl_security sec;
 	struct rtl_efuse efuse;
 
+	/*troy add for 8812AE+8761AU coex*/
+	struct bt_coex_info coex_info;
+
 	struct rtl_ps_ctl psc;
 	struct rate_adaptive ra;
 	struct dynamic_primary_cca primarycca;
-- 
2.1.2

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
