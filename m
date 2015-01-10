From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: [PATCH 3/3] rtlwifi: btcoexist: Remove some unused functions
Date: Sat, 10 Jan 2015 17:24:39 +0100
Message-ID: <1420907079-27102-3-git-send-email-rickard_strandqvist@spectrumdigital.se>
References: <1420907079-27102-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	Kalle Valo <kvalo@adurom.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Masanari Iida <standby24x7@gmail.com>,
	Sachin Kamat <sachin.kamat@linaro.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f179.google.com ([74.125.82.179]:61473 "EHLO
	mail-we0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754070AbbAJQVj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jan 2015 11:21:39 -0500
Received: by mail-we0-f179.google.com with SMTP id q59so12661403wes.10
        for <netdev@vger.kernel.org>; Sat, 10 Jan 2015 08:21:37 -0800 (PST)
In-Reply-To: <1420907079-27102-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removes some functions that are not used anywhere:
ex_halbtc8821a2ant_periodical() ex_halbtc8821a2ant_halt_notify()
ex_halbtc8821a2ant_bt_info_notify()
ex_halbtc8821a2ant_special_packet_notify()
ex_halbtc8821a2ant_connect_notify() ex_halbtc8821a2ant_scan_notify()
ex_halbtc8821a2ant_lps_notify() ex_halbtc8821a2ant_ips_notify()
ex_halbtc8821a2ant_display_coex_info() ex_halbtc8821a2ant_init_coex_dm()
ex_halbtc8821a2ant_init_hwconfig()

This was partially found by using a static code analysis program called cppcheck.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
---
 .../wireless/rtlwifi/btcoexist/halbtc8821a2ant.c   |  548 --------------------
 .../wireless/rtlwifi/btcoexist/halbtc8821a2ant.h   |   51 --
 2 files changed, 599 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/btcoexist/halbtc8821a2ant.c b/drivers/net/wireless/rtlwifi/btcoexist/halbtc8821a2ant.c
index cf819f0..7d7b81d 100644
--- a/drivers/net/wireless/rtlwifi/btcoexist/halbtc8821a2ant.c
+++ b/drivers/net/wireless/rtlwifi/btcoexist/halbtc8821a2ant.c
@@ -3290,346 +3290,6 @@ static void halbtc8821a2ant_run_coexist_mechanism(struct btc_coexist *btcoexist)
  * extern function start with EXhalbtc8821a2ant_
  *============================================================
  */
-void ex_halbtc8821a2ant_init_hwconfig(struct btc_coexist *btcoexist)
-{
-	u8 u1tmp = 0;
-
-	BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
-		  "[BTCoex], 2Ant Init HW Config!!\n");
-
-	/* backup rf 0x1e value */
-	coex_dm->bt_rf0x1e_backup =
-		btcoexist->btc_get_rf_reg(btcoexist, BTC_RF_A, 0x1e, 0xfffff);
-
-	/* 0x790[5:0] = 0x5 */
-	u1tmp = btcoexist->btc_read_1byte(btcoexist, 0x790);
-	u1tmp &= 0xc0;
-	u1tmp |= 0x5;
-	btcoexist->btc_write_1byte(btcoexist, 0x790, u1tmp);
-
-	/*Antenna config */
-	halbtc8821a2ant_set_ant_path(btcoexist,
-				     BTC_ANT_WIFI_AT_MAIN, true, false);
-
-	/* PTA parameter */
-	halbtc8821a2ant_coex_table(btcoexist,
-				   FORCE_EXEC, 0x55555555, 0x55555555,
-				   0xffff, 0x3);
-
-	/* Enable counter statistics */
-	/*0x76e[3] = 1, WLAN_Act control by PTA*/
-	btcoexist->btc_write_1byte(btcoexist, 0x76e, 0xc);
-	btcoexist->btc_write_1byte(btcoexist, 0x778, 0x3);
-	btcoexist->btc_write_1byte_bitmask(btcoexist, 0x40, 0x20, 0x1);
-}
-
-void
-ex_halbtc8821a2ant_init_coex_dm(
-	struct btc_coexist *btcoexist
-	)
-{
-	BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
-		  "[BTCoex], Coex Mechanism Init!!\n");
-
-	halbtc8821a2ant_init_coex_dm(btcoexist);
-}
-
-void
-ex_halbtc8821a2ant_display_coex_info(
-	struct btc_coexist *btcoexist
-	)
-{
-	struct btc_board_info *board_info = &btcoexist->board_info;
-	struct btc_stack_info *stack_info = &btcoexist->stack_info;
-	struct rtl_priv *rtlpriv = btcoexist->adapter;
-	u8 u1tmp[4], i, bt_info_ext, ps_tdma_case = 0;
-	u32 u4tmp[4];
-	bool roam = false, scan = false, link = false, wifi_under_5g = false;
-	bool bt_hs_on = false, wifi_busy = false;
-	long wifi_rssi = 0, bt_hs_rssi = 0;
-	u32 wifi_bw, wifi_traffic_dir;
-	u8 wifi_dot_11_chnl, wifi_hs_chnl;
-	u32 fw_ver = 0, bt_patch_ver = 0;
-
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-		   "\r\n ============[BT Coexist info]============");
-
-	if (!board_info->bt_exist) {
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n BT not exists !!!");
-		return;
-	}
-
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-		   "\r\n %-35s = %d/ %d ", "Ant PG number/ Ant mechanism:",
-		   board_info->pg_ant_num, board_info->btdm_ant_num);
-
-	if (btcoexist->manual_control) {
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-			   "\r\n %-35s", "[Action Manual control]!!");
-	}
-
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-		   "\r\n %-35s = %s / %d", "BT stack/ hci ext ver",
-		   ((stack_info->profile_notified) ? "Yes" : "No"),
-		   stack_info->hci_version);
-
-	btcoexist->btc_get(btcoexist, BTC_GET_U4_BT_PATCH_VER, &bt_patch_ver);
-	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_FW_VER, &fw_ver);
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-		   "\r\n %-35s = %d_%d/ 0x%x/ 0x%x(%d)",
-		   "CoexVer/ FwVer/ PatchVer",
-		   glcoex_ver_date_8821a_2ant, glcoex_ver_8821a_2ant,
-		   fw_ver, bt_patch_ver, bt_patch_ver);
-
-	btcoexist->btc_get(btcoexist,
-		BTC_GET_BL_HS_OPERATION, &bt_hs_on);
-	btcoexist->btc_get(btcoexist,
-		BTC_GET_U1_WIFI_DOT11_CHNL, &wifi_dot_11_chnl);
-	btcoexist->btc_get(btcoexist,
-		BTC_GET_U1_WIFI_HS_CHNL, &wifi_hs_chnl);
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-		   "\r\n %-35s = %d / %d(%d)",
-		   "Dot11 channel / HsMode(HsChnl)",
-		   wifi_dot_11_chnl, bt_hs_on, wifi_hs_chnl);
-
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-		   "\r\n %-35s = %02x %02x %02x ",
-		   "H2C Wifi inform bt chnl Info",
-		   coex_dm->wifi_chnl_info[0], coex_dm->wifi_chnl_info[1],
-		   coex_dm->wifi_chnl_info[2]);
-
-	btcoexist->btc_get(btcoexist, BTC_GET_S4_WIFI_RSSI, &wifi_rssi);
-	btcoexist->btc_get(btcoexist, BTC_GET_S4_HS_RSSI, &bt_hs_rssi);
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-		   "\r\n %-35s = %ld/ %ld", "Wifi rssi/ HS rssi",
-		   wifi_rssi, bt_hs_rssi);
-
-	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_SCAN, &scan);
-	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_LINK, &link);
-	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_ROAM, &roam);
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-		   "\r\n %-35s = %d/ %d/ %d ", "Wifi link/ roam/ scan",
-		   link, roam, scan);
-
-	btcoexist->btc_get(btcoexist,
-		BTC_GET_BL_WIFI_UNDER_5G, &wifi_under_5g);
-	btcoexist->btc_get(btcoexist,
-		BTC_GET_U4_WIFI_BW, &wifi_bw);
-	btcoexist->btc_get(btcoexist,
-		BTC_GET_BL_WIFI_BUSY, &wifi_busy);
-	btcoexist->btc_get(btcoexist,
-		BTC_GET_U4_WIFI_TRAFFIC_DIRECTION, &wifi_traffic_dir);
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-		   "\r\n %-35s = %s / %s/ %s ", "Wifi status",
-		   (wifi_under_5g ? "5G" : "2.4G"),
-		   ((BTC_WIFI_BW_LEGACY == wifi_bw) ? "Legacy" :
-		    (((BTC_WIFI_BW_HT40 == wifi_bw) ? "HT40" : "HT20"))),
-		   ((!wifi_busy) ? "idle" :
-		    ((BTC_WIFI_TRAFFIC_TX == wifi_traffic_dir) ?
-		     "uplink" : "downlink")));
-
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-		   "\r\n %-35s = [%s/ %d/ %d] ", "BT [status/ rssi/ retryCnt]",
-		   ((coex_sta->c2h_bt_inquiry_page) ? ("inquiry/page scan") :
-		    ((BT_8821A_2ANT_BT_STATUS_IDLE == coex_dm->bt_status)
-		     ? "idle" : ((BT_8821A_2ANT_BT_STATUS_CON_IDLE ==
-		     coex_dm->bt_status) ? "connected-idle" : "busy"))),
-		    coex_sta->bt_rssi, coex_sta->bt_retry_cnt);
-
-	if (stack_info->profile_notified) {
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-			   "\r\n %-35s = %d / %d / %d / %d", "SCO/HID/PAN/A2DP",
-			   stack_info->sco_exist, stack_info->hid_exist,
-			   stack_info->pan_exist, stack_info->a2dp_exist);
-
-		btcoexist->btc_disp_dbg_msg(btcoexist,
-					    BTC_DBG_DISP_BT_LINK_INFO);
-	}
-
-	bt_info_ext = coex_sta->bt_info_ext;
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = %s",
-		   "BT Info A2DP rate",
-		   (bt_info_ext&BIT0) ? "Basic rate" : "EDR rate");
-
-	for (i = 0; i < BT_INFO_SRC_8821A_2ANT_MAX; i++) {
-		if (coex_sta->bt_info_c2h_cnt[i]) {
-			RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-				   "\r\n %-35s = %02x %02x %02x %02x %02x %02x %02x(%d)",
-				   glbt_info_src_8821a_2ant[i],
-				   coex_sta->bt_info_c2h[i][0],
-				   coex_sta->bt_info_c2h[i][1],
-				   coex_sta->bt_info_c2h[i][2],
-				   coex_sta->bt_info_c2h[i][3],
-				   coex_sta->bt_info_c2h[i][4],
-				   coex_sta->bt_info_c2h[i][5],
-				   coex_sta->bt_info_c2h[i][6],
-				   coex_sta->bt_info_c2h_cnt[i]);
-		}
-	}
-
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = %s/%s",
-		   "PS state, IPS/LPS",
-		   ((coex_sta->under_ips ? "IPS ON" : "IPS OFF")),
-		   ((coex_sta->under_lps ? "LPS ON" : "LPS OFF")));
-	btcoexist->btc_disp_dbg_msg(btcoexist, BTC_DBG_DISP_FW_PWR_MODE_CMD);
-
-	/* Sw mechanism*/
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s",
-		   "============[Sw mechanism]============");
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-		   "\r\n %-35s = %d/ %d/ %d/ %d ",
-		   "SM1[ShRf/ LpRA/ LimDig/ btLna]",
-		   coex_dm->cur_rf_rx_lpf_shrink, coex_dm->cur_low_penalty_ra,
-		   coex_dm->limited_dig, coex_dm->cur_bt_lna_constrain);
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-		   "\r\n %-35s = %d/ %d/ %d(0x%x) ",
-		   "SM2[AgcT/ AdcB/ SwDacSwing(lvl)]",
-		   coex_dm->cur_agc_table_en, coex_dm->cur_adc_back_off,
-		   coex_dm->cur_dac_swing_on, coex_dm->cur_dac_swing_lvl);
-
-	/* Fw mechanism*/
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s",
-		   "============[Fw mechanism]============");
-
-	if (!btcoexist->manual_control) {
-		ps_tdma_case = coex_dm->cur_ps_tdma;
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-			   "\r\n %-35s = %02x %02x %02x %02x %02x case-%d",
-			   "PS TDMA",
-			   coex_dm->ps_tdma_para[0], coex_dm->ps_tdma_para[1],
-			   coex_dm->ps_tdma_para[2], coex_dm->ps_tdma_para[3],
-			   coex_dm->ps_tdma_para[4], ps_tdma_case);
-
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-			   "\r\n %-35s = %d/ %d ", "DecBtPwr/ IgnWlanAct",
-			   coex_dm->cur_dec_bt_pwr,
-			   coex_dm->cur_ignore_wlan_act);
-	}
-
-	/* Hw setting*/
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-		   "\r\n %-35s", "============[Hw setting]============");
-
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-		   "\r\n %-35s = 0x%x", "RF-A, 0x1e initVal",
-		   coex_dm->bt_rf0x1e_backup);
-
-	u1tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x778);
-	u1tmp[1] = btcoexist->btc_read_1byte(btcoexist, 0x6cc);
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = 0x%x/ 0x%x ",
-		   "0x778 (W_Act)/ 0x6cc (CoTab Sel)",
-		   u1tmp[0], u1tmp[1]);
-
-	u1tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x8db);
-	u1tmp[1] = btcoexist->btc_read_1byte(btcoexist, 0xc5b);
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = 0x%x/ 0x%x",
-		   "0x8db(ADC)/0xc5b[29:25](DAC)",
-		   ((u1tmp[0]&0x60)>>5), ((u1tmp[1]&0x3e)>>1));
-
-	u4tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0xcb4);
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = 0x%x/ 0x%x",
-		   "0xcb4[7:0](ctrl)/ 0xcb4[29:28](val)",
-		   u4tmp[0]&0xff, ((u4tmp[0]&0x30000000)>>28));
-
-	u1tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x40);
-	u4tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x4c);
-	u4tmp[1] = btcoexist->btc_read_4byte(btcoexist, 0x974);
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = 0x%x/ 0x%x/ 0x%x",
-		   "0x40/ 0x4c[24:23]/ 0x974",
-		   u1tmp[0], ((u4tmp[0]&0x01800000)>>23), u4tmp[1]);
-
-	u4tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x550);
-	u1tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x522);
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = 0x%x/ 0x%x",
-		   "0x550(bcn ctrl)/0x522",
-		   u4tmp[0], u1tmp[0]);
-
-	u4tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0xc50);
-	u1tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0xa0a);
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = 0x%x/ 0x%x",
-		   "0xc50(DIG)/0xa0a(CCK-TH)",
-		   u4tmp[0], u1tmp[0]);
-
-	u4tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0xf48);
-	u1tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0xa5b);
-	u1tmp[1] = btcoexist->btc_read_1byte(btcoexist, 0xa5c);
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = 0x%x/ 0x%x",
-		   "OFDM-FA/ CCK-FA",
-		   u4tmp[0], (u1tmp[0]<<8) + u1tmp[1]);
-
-	u4tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x6c0);
-	u4tmp[1] = btcoexist->btc_read_4byte(btcoexist, 0x6c4);
-	u4tmp[2] = btcoexist->btc_read_4byte(btcoexist, 0x6c8);
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = 0x%x/ 0x%x/ 0x%x",
-		   "0x6c0/0x6c4/0x6c8",
-		   u4tmp[0], u4tmp[1], u4tmp[2]);
-
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = %d/ %d",
-		   "0x770 (hi-pri Rx/Tx)",
-		   coex_sta->high_priority_rx, coex_sta->high_priority_tx);
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = %d/ %d",
-		   "0x774(low-pri Rx/Tx)",
-		   coex_sta->low_priority_rx, coex_sta->low_priority_tx);
-
-	/* Tx mgnt queue hang or not, 0x41b should = 0xf, ex: 0xd ==>hang*/
-	u1tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x41b);
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = 0x%x",
-		   "0x41b (mgntQ hang chk == 0xf)",
-		   u1tmp[0]);
-
-	btcoexist->btc_disp_dbg_msg(btcoexist, BTC_DBG_DISP_COEX_STATISTICS);
-}
-
-void ex_halbtc8821a2ant_ips_notify(struct btc_coexist *btcoexist, u8 type)
-{
-	if (BTC_IPS_ENTER == type) {
-		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
-			  "[BTCoex], IPS ENTER notify\n");
-		coex_sta->under_ips = true;
-		halbtc8821a2ant_coex_all_off(btcoexist);
-	} else if (BTC_IPS_LEAVE == type) {
-		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
-			  "[BTCoex], IPS LEAVE notify\n");
-		coex_sta->under_ips = false;
-		/*halbtc8821a2ant_init_coex_dm(btcoexist);*/
-	}
-}
-
-void ex_halbtc8821a2ant_lps_notify(struct btc_coexist *btcoexist, u8 type)
-{
-	if (BTC_LPS_ENABLE == type) {
-		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
-			  "[BTCoex], LPS ENABLE notify\n");
-		coex_sta->under_lps = true;
-	} else if (BTC_LPS_DISABLE == type) {
-		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
-			  "[BTCoex], LPS DISABLE notify\n");
-		coex_sta->under_lps = false;
-	}
-}
-
-void ex_halbtc8821a2ant_scan_notify(struct btc_coexist *btcoexist, u8 type)
-{
-	if (BTC_SCAN_START == type) {
-		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
-			  "[BTCoex], SCAN START notify\n");
-	} else if (BTC_SCAN_FINISH == type) {
-		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
-			  "[BTCoex], SCAN FINISH notify\n");
-	}
-}
-
-void ex_halbtc8821a2ant_connect_notify(struct btc_coexist *btcoexist, u8 type)
-{
-	if (BTC_ASSOCIATE_START == type) {
-		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
-			  "[BTCoex], CONNECT START notify\n");
-	} else if (BTC_ASSOCIATE_FINISH == type) {
-		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
-			  "[BTCoex], CONNECT FINISH notify\n");
-	}
-}
-
 void ex_halbtc8821a2ant_media_status_notify(struct btc_coexist *btcoexist,
 					    u8 type)
 {
@@ -3669,211 +3329,3 @@ void ex_halbtc8821a2ant_media_status_notify(struct btc_coexist *btcoexist,
 
 	btcoexist->btc_fill_h2c(btcoexist, 0x66, 3, h2c_parameter);
 }
-
-void ex_halbtc8821a2ant_special_packet_notify(struct btc_coexist *btcoexist,
-					      u8 type) {
-	if (type == BTC_PACKET_DHCP) {
-		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
-			  "[BTCoex], DHCP Packet notify\n");
-	}
-}
-
-void ex_halbtc8821a2ant_bt_info_notify(struct btc_coexist *btcoexist,
-				       u8 *tmp_buf, u8 length)
-{
-	u8		bt_info = 0;
-	u8		i, rsp_source = 0;
-	static u32	set_bt_lna_cnt, set_bt_psd_mode;
-	bool		bt_busy = false, limited_dig = false;
-	bool		wifi_connected = false, bt_hs_on = false;
-
-	coex_sta->c2h_bt_info_req_sent = false;
-
-	rsp_source = tmp_buf[0]&0xf;
-	if (rsp_source >= BT_INFO_SRC_8821A_2ANT_MAX)
-		rsp_source = BT_INFO_SRC_8821A_2ANT_WIFI_FW;
-	coex_sta->bt_info_c2h_cnt[rsp_source]++;
-
-	BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
-		  "[BTCoex], Bt info[%d], length = %d, hex data = [",
-		  rsp_source, length);
-	for (i = 0; i < length; i++) {
-		coex_sta->bt_info_c2h[rsp_source][i] = tmp_buf[i];
-		if (i == 1)
-			bt_info = tmp_buf[i];
-		if (i == length-1) {
-			BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
-				  "0x%02x]\n", tmp_buf[i]);
-		} else {
-			BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
-				  "0x%02x, ", tmp_buf[i]);
-		}
-	}
-
-	if (BT_INFO_SRC_8821A_2ANT_WIFI_FW != rsp_source) {
-		coex_sta->bt_retry_cnt =	/* [3:0]*/
-			coex_sta->bt_info_c2h[rsp_source][2]&0xf;
-
-		coex_sta->bt_rssi =
-			coex_sta->bt_info_c2h[rsp_source][3]*2+10;
-
-		coex_sta->bt_info_ext =
-			coex_sta->bt_info_c2h[rsp_source][4];
-
-		/* Here we need to resend some wifi info to BT*/
-		/* because bt is reset and loss of the info.*/
-		if ((coex_sta->bt_info_ext & BIT1)) {
-			btcoexist->btc_get(btcoexist,
-				BTC_GET_BL_WIFI_CONNECTED, &wifi_connected);
-			if (wifi_connected) {
-				ex_halbtc8821a2ant_media_status_notify(btcoexist,
-					BTC_MEDIA_CONNECT);
-			} else {
-				ex_halbtc8821a2ant_media_status_notify(btcoexist,
-					BTC_MEDIA_DISCONNECT);
-			}
-
-			set_bt_psd_mode = 0;
-		}
-		if (set_bt_psd_mode <= 3) {
-			halbtc8821a2ant_set_bt_psd_mode(btcoexist, FORCE_EXEC,
-							0x0); /*fix CH-BW mode*/
-			set_bt_psd_mode++;
-		}
-
-		if (coex_dm->cur_bt_lna_constrain) {
-			if (!(coex_sta->bt_info_ext & BIT2)) {
-				if (set_bt_lna_cnt <= 3) {
-					btc8821a2_set_bt_lna_const(btcoexist,
-								   FORCE_EXEC,
-								   true);
-					set_bt_lna_cnt++;
-				}
-			}
-		} else {
-			set_bt_lna_cnt = 0;
-		}
-
-		if ((coex_sta->bt_info_ext & BIT3)) {
-			halbtc8821a2ant_ignore_wlan_act(btcoexist,
-							FORCE_EXEC, false);
-		} else {
-			/* BT already NOT ignore Wlan active, do nothing here.*/
-		}
-
-		if ((coex_sta->bt_info_ext & BIT4)) {
-			/* BT auto report already enabled, do nothing*/
-		} else {
-			halbtc8821a2ant_bt_auto_report(btcoexist,
-						       FORCE_EXEC, true);
-		}
-	}
-
-	btcoexist->btc_get(btcoexist, BTC_GET_BL_HS_OPERATION, &bt_hs_on);
-	/* check BIT2 first ==> check if bt is under inquiry or page scan*/
-	if (bt_info & BT_INFO_8821A_2ANT_B_INQ_PAGE) {
-		coex_sta->c2h_bt_inquiry_page = true;
-		coex_dm->bt_status = BT_8821A_2ANT_BT_STATUS_NON_IDLE;
-	} else {
-		coex_sta->c2h_bt_inquiry_page = false;
-		if (bt_info == 0x1) {
-			/* connection exists but not busy*/
-			coex_sta->bt_link_exist = true;
-			coex_dm->bt_status = BT_8821A_2ANT_BT_STATUS_CON_IDLE;
-		} else if (bt_info & BT_INFO_8821A_2ANT_B_CONNECTION) {
-			/* connection exists and some link is busy*/
-			coex_sta->bt_link_exist = true;
-			if (bt_info & BT_INFO_8821A_2ANT_B_FTP)
-				coex_sta->pan_exist = true;
-			else
-				coex_sta->pan_exist = false;
-			if (bt_info & BT_INFO_8821A_2ANT_B_A2DP)
-				coex_sta->a2dp_exist = true;
-			else
-				coex_sta->a2dp_exist = false;
-			if (bt_info & BT_INFO_8821A_2ANT_B_HID)
-				coex_sta->hid_exist = true;
-			else
-				coex_sta->hid_exist = false;
-			if (bt_info & BT_INFO_8821A_2ANT_B_SCO_ESCO)
-				coex_sta->sco_exist = true;
-			else
-				coex_sta->sco_exist = false;
-			coex_dm->bt_status = BT_8821A_2ANT_BT_STATUS_NON_IDLE;
-		} else {
-			coex_sta->bt_link_exist = false;
-			coex_sta->pan_exist = false;
-			coex_sta->a2dp_exist = false;
-			coex_sta->hid_exist = false;
-			coex_sta->sco_exist = false;
-			coex_dm->bt_status = BT_8821A_2ANT_BT_STATUS_IDLE;
-		}
-
-		if (bt_hs_on)
-			coex_dm->bt_status = BT_8821A_2ANT_BT_STATUS_NON_IDLE;
-	}
-
-	if (BT_8821A_2ANT_BT_STATUS_NON_IDLE == coex_dm->bt_status)
-		bt_busy = true;
-	else
-		bt_busy = false;
-	btcoexist->btc_set(btcoexist, BTC_SET_BL_BT_TRAFFIC_BUSY, &bt_busy);
-
-	if (BT_8821A_2ANT_BT_STATUS_IDLE != coex_dm->bt_status)
-		limited_dig = true;
-	else
-		limited_dig = false;
-	coex_dm->limited_dig = limited_dig;
-	btcoexist->btc_set(btcoexist,
-		BTC_SET_BL_BT_LIMITED_DIG, &limited_dig);
-
-	halbtc8821a2ant_run_coexist_mechanism(btcoexist);
-}
-
-void ex_halbtc8821a2ant_halt_notify(struct btc_coexist *btcoexist)
-{
-	BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
-		  "[BTCoex], Halt notify\n");
-
-	halbtc8821a2ant_ignore_wlan_act(btcoexist, FORCE_EXEC, true);
-	ex_halbtc8821a2ant_media_status_notify(btcoexist, BTC_MEDIA_DISCONNECT);
-}
-
-void ex_halbtc8821a2ant_periodical(struct btc_coexist *btcoexist)
-{
-	static u8	dis_ver_info_cnt;
-	u32		fw_ver = 0, bt_patch_ver = 0;
-	struct btc_board_info *board_info = &btcoexist->board_info;
-	struct btc_stack_info *stack_info = &btcoexist->stack_info;
-
-	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
-		  "[BTCoex], ==========================Periodical===========================\n");
-
-	if (dis_ver_info_cnt <= 5) {
-		dis_ver_info_cnt += 1;
-		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
-			  "[BTCoex], ****************************************************************\n");
-		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
-			  "[BTCoex], Ant PG Num/ Ant Mech/ Ant Pos = %d/ %d/ %d\n",
-			  board_info->pg_ant_num,
-			  board_info->btdm_ant_num,
-			  board_info->btdm_ant_pos);
-		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
-			  "[BTCoex], BT stack/ hci ext ver = %s / %d\n",
-			  ((stack_info->profile_notified) ? "Yes" : "No"),
-			  stack_info->hci_version);
-		btcoexist->btc_get(btcoexist, BTC_GET_U4_BT_PATCH_VER,
-				   &bt_patch_ver);
-		btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_FW_VER, &fw_ver);
-		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
-			  "[BTCoex], CoexVer/ FwVer/ PatchVer = %d_%x/ 0x%x/ 0x%x(%d)\n",
-			  glcoex_ver_date_8821a_2ant, glcoex_ver_8821a_2ant,
-			  fw_ver, bt_patch_ver, bt_patch_ver);
-		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
-			  "[BTCoex], ****************************************************************\n");
-	}
-
-	halbtc8821a2ant_query_bt_info(btcoexist);
-	halbtc8821a2ant_monitor_bt_ctr(btcoexist);
-	btc8821a2ant_mon_bt_en_dis(btcoexist);
-}
diff --git a/drivers/net/wireless/rtlwifi/btcoexist/halbtc8821a2ant.h b/drivers/net/wireless/rtlwifi/btcoexist/halbtc8821a2ant.h
index b4cf1f5..4c95842 100644
--- a/drivers/net/wireless/rtlwifi/btcoexist/halbtc8821a2ant.h
+++ b/drivers/net/wireless/rtlwifi/btcoexist/halbtc8821a2ant.h
@@ -148,58 +148,7 @@ struct coex_sta_8821a_2ant {
  *===========================================
  */
 void
-ex_halbtc8821a2ant_init_hwconfig(
-	struct btc_coexist *btcoexist
-	);
-void
-ex_halbtc8821a2ant_init_coex_dm(
-	struct btc_coexist *btcoexist
-	);
-void
-ex_halbtc8821a2ant_ips_notify(
-	struct btc_coexist *btcoexist,
-	u8 type
-	);
-void
-ex_halbtc8821a2ant_lps_notify(
-	struct btc_coexist *btcoexist,
-	u8 type
-	);
-void
-ex_halbtc8821a2ant_scan_notify(
-	struct btc_coexist *btcoexist,
-	u8 type
-	);
-void
-ex_halbtc8821a2ant_connect_notify(
-	struct btc_coexist *btcoexist,
-	u8 type
-	);
-void
 ex_halbtc8821a2ant_media_status_notify(
 	struct btc_coexist *btcoexist,
 	u8 type
 	);
-void
-ex_halbtc8821a2ant_special_packet_notify(
-	struct btc_coexist *btcoexist,
-	u8 type
-	);
-void
-ex_halbtc8821a2ant_bt_info_notify(
-	struct btc_coexist *btcoexist,
-	u8 *tmp_buf,
-	u8 length
-	);
-void
-ex_halbtc8821a2ant_halt_notify(
-	struct btc_coexist *btcoexist
-	);
-void
-ex_halbtc8821a2ant_periodical(
-	struct btc_coexist *btcoexist
-	);
-void
-ex_halbtc8821a2ant_display_coex_info(
-	struct btc_coexist *btcoexist
-	);
-- 
1.7.10.4
