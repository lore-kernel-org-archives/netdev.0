From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH 15/15] rtlwifi: rtl8192ce: rtl8192cu: rtl8192se: rtl81723ae: Turn on building of the new driver
Date: Mon, 17 Sep 2012 16:18:54 -0500
Message-ID: <1347916754-9219-15-git-send-email-Larry.Finger@lwfinger.net>
References: <1347483294-6943-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1347483294-6943-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch completes the addition of the new driver for the Realtek
RTL8723AE devices by adding the make file and by modifying Kconfig
and Makefile of rtlwifi. Some variable names were shortened to ease
the problem of limiting all lines to 80 characters, thus changes were
made to wifi.h and rtl8192{ce,cu,sw}/hw.c.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Cc: <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>
---
 drivers/net/wireless/rtlwifi/Kconfig            |   19 +++-
 drivers/net/wireless/rtlwifi/Makefile           |    4 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c     |   83 ++++++++++++++---
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c     |   10 +-
 drivers/net/wireless/rtlwifi/rtl8192se/hw.c     |    6 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/Makefile |   23 +++++
 drivers/net/wireless/rtlwifi/wifi.h             |  112 +++++++++++++++++++++--
 7 files changed, 225 insertions(+), 32 deletions(-)
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/Makefile

Index: wireless-testing-new/drivers/net/wireless/rtlwifi/Makefile
===================================================================
--- wireless-testing-new.orig/drivers/net/wireless/rtlwifi/Makefile
+++ wireless-testing-new/drivers/net/wireless/rtlwifi/Makefile
@@ -7,7 +7,8 @@ rtlwifi-objs	:=		\
 		efuse.o		\
 		ps.o		\
 		rc.o		\
-		regd.o
+		regd.o		\
+		stats.o
 
 rtl8192c_common-objs +=		\
 
@@ -24,5 +25,6 @@ obj-$(CONFIG_RTL8192CE)		+= rtl8192ce/
 obj-$(CONFIG_RTL8192CU)		+= rtl8192cu/
 obj-$(CONFIG_RTL8192SE)		+= rtl8192se/
 obj-$(CONFIG_RTL8192DE)		+= rtl8192de/
+obj-$(CONFIG_RTL8723AE)		+= rtl8723ae/
 
 ccflags-y += -D__CHECK_ENDIAN__
Index: wireless-testing-new/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
===================================================================
--- wireless-testing-new.orig/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
+++ wireless-testing-new/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
@@ -152,9 +152,9 @@ static void _rtl92cu_read_txpower_info_f
 			tempval = hwinfo[EEPROM_TXPOWERHT40_2SDIFF + i];
 		else
 			tempval = EEPROM_DEFAULT_HT40_2SDIFF;
-		rtlefuse->eeprom_chnlarea_txpwr_ht40_2sdiif[RF90_PATH_A][i] =
+		rtlefuse->eprom_chnl_txpwr_ht40_2sdf[RF90_PATH_A][i] =
 		    (tempval & 0xf);
-		rtlefuse->eeprom_chnlarea_txpwr_ht40_2sdiif[RF90_PATH_B][i] =
+		rtlefuse->eprom_chnl_txpwr_ht40_2sdf[RF90_PATH_B][i] =
 		    ((tempval & 0xf0) >> 4);
 	}
 	for (rf_path = 0; rf_path < 2; rf_path++)
@@ -177,7 +177,7 @@ static void _rtl92cu_read_txpower_info_f
 				"RF(%d) EEPROM HT40 2S Diff Area(%d) = 0x%x\n",
 				rf_path, i,
 				rtlefuse->
-				eeprom_chnlarea_txpwr_ht40_2sdiif[rf_path][i]);
+				eprom_chnl_txpwr_ht40_2sdf[rf_path][i]);
 	for (rf_path = 0; rf_path < 2; rf_path++) {
 		for (i = 0; i < 14; i++) {
 			index = _rtl92c_get_chnl_group((u8) i);
@@ -189,13 +189,13 @@ static void _rtl92cu_read_txpower_info_f
 			if ((rtlefuse->
 			     eeprom_chnlarea_txpwr_ht40_1s[rf_path][index] -
 			     rtlefuse->
-			     eeprom_chnlarea_txpwr_ht40_2sdiif[rf_path][index])
+			     eprom_chnl_txpwr_ht40_2sdf[rf_path][index])
 			    > 0) {
 				rtlefuse->txpwrlevel_ht40_2s[rf_path][i] =
 				    rtlefuse->
 				    eeprom_chnlarea_txpwr_ht40_1s[rf_path]
 				    [index] - rtlefuse->
-				    eeprom_chnlarea_txpwr_ht40_2sdiif[rf_path]
+				    eprom_chnl_txpwr_ht40_2sdf[rf_path]
 				    [index];
 			} else {
 				rtlefuse->txpwrlevel_ht40_2s[rf_path][i] = 0;
Index: wireless-testing-new/drivers/net/wireless/rtlwifi/rtl8192se/hw.c
===================================================================
--- wireless-testing-new.orig/drivers/net/wireless/rtlwifi/rtl8192se/hw.c
+++ wireless-testing-new/drivers/net/wireless/rtlwifi/rtl8192se/hw.c
@@ -1697,7 +1697,7 @@ static void _rtl92se_read_adapter_info(s
 			hwinfo[EEPROM_TXPOWERBASE + 6 + rf_path * 3 + i];
 
 			/* Read OFDM RF A & B Tx power for 2T */
-			rtlefuse->eeprom_chnlarea_txpwr_ht40_2sdiif[rf_path][i]
+			rtlefuse->eprom_chnl_txpwr_ht40_2sdf[rf_path][i]
 				 = hwinfo[EEPROM_TXPOWERBASE + 12 +
 				   rf_path * 3 + i];
 		}
@@ -1722,7 +1722,7 @@ static void _rtl92se_read_adapter_info(s
 			RTPRINT(rtlpriv, FINIT, INIT_EEPROM,
 				"RF(%d) EEPROM HT40 2S Diff Area(%d) = 0x%x\n",
 				rf_path, i,
-				rtlefuse->eeprom_chnlarea_txpwr_ht40_2sdiif
+				rtlefuse->eprom_chnl_txpwr_ht40_2sdf
 				[rf_path][i]);
 
 	for (rf_path = 0; rf_path < 2; rf_path++) {
@@ -1748,7 +1748,7 @@ static void _rtl92se_read_adapter_info(s
 				rtlefuse->eeprom_chnlarea_txpwr_ht40_1s
 							[rf_path][index];
 			rtlefuse->txpwrlevel_ht40_2s[rf_path][i]  =
-				rtlefuse->eeprom_chnlarea_txpwr_ht40_2sdiif
+				rtlefuse->eprom_chnl_txpwr_ht40_2sdf
 							[rf_path][index];
 		}
 
Index: wireless-testing-new/drivers/net/wireless/rtlwifi/rtl8723ae/Makefile
===================================================================
--- /dev/null
+++ wireless-testing-new/drivers/net/wireless/rtlwifi/rtl8723ae/Makefile
@@ -0,0 +1,23 @@
+obj-m := rtl8723ae.o
+
+
+rtl8723ae-objs :=		\
+		dm.o		\
+		fw.o		\
+		hal_btc.o	\
+		hal_bt_coexist.o\
+		hw.o		\
+		led.o		\
+		phy.o		\
+		pwrseq.o	\
+		pwrseqcmd.o	\
+		rf.o		\
+		sw.o		\
+		table.o		\
+		trx.o		\
+
+
+obj-$(CONFIG_RTL8723AE) += rtl8723ae.o
+
+ccflags-y += -D__CHECK_ENDIAN__
+Index: wireless-testing-new/drivers/net/wireless/rtlwifi/Makefile
Index: wireless-testing-new/drivers/net/wireless/rtlwifi/wifi.h
===================================================================
--- wireless-testing-new.orig/drivers/net/wireless/rtlwifi/wifi.h
+++ wireless-testing-new/drivers/net/wireless/rtlwifi/wifi.h
@@ -350,6 +350,11 @@ enum rt_oem_id {
 	RT_CID_819x_WNC_COREGA = 31,
 	RT_CID_819x_Foxcoon = 32,
 	RT_CID_819x_DELL = 33,
+	RT_CID_819x_PRONETS = 34,
+	RT_CID_819x_Edimax_ASUS = 35,
+	RT_CID_NETGEAR = 36,
+	RT_CID_PLANEX = 37,
+	RT_CID_CC_C = 38,
 };
 
 enum hw_descs {
@@ -505,6 +510,7 @@ enum rtl_var_map {
 	RTL_IMR_ROK,		/*Receive DMA OK Interrupt */
 	RTL_IBSS_INT_MASKS,	/*(RTL_IMR_BcnInt | RTL_IMR_TBDOK |
 				 * RTL_IMR_TBDER) */
+	RTL_IMR_C2HCMD,		/*fw interrupt*/
 
 	/*CCK Rates, TxHT = 0 */
 	RTL_RC_CCK_RATE1M,
@@ -661,6 +667,11 @@ enum ba_action {
 	ACT_DELBA = 2,
 };
 
+enum rt_polarity_ctl {
+	RT_POLARITY_LOW_ACT = 0,
+	RT_POLARITY_HIGH_ACT = 1,
+};
+
 struct octet_string {
 	u8 *octet;
 	u16 length;
@@ -903,6 +914,8 @@ struct rtl_phy {
 	u8 num_total_rfpath;
 	struct phy_parameters hwparam_tables[MAX_TAB];
 	u16 rf_pathmap;
+
+	enum rt_polarity_ctl polarity_ctl;
 };
 
 #define MAX_TID_COUNT				9
@@ -1042,13 +1055,64 @@ struct rtl_mac {
 	/*QOS & EDCA */
 	struct ieee80211_tx_queue_params edca_param[RTL_MAC80211_NUM_QUEUE];
 	struct rtl_qos_parameters ac[AC_MAX];
+
+	/* counters */
+	u64 last_txok_cnt;
+	u64 last_rxok_cnt;
+	u32 last_bt_edca_ul;
+	u32 last_bt_edca_dl;
+};
+
+struct btdm_8723 {
+	bool all_off;
+	bool agc_table_en;
+	bool adc_back_off_on;
+	bool b2_ant_hid_en;
+	bool low_penalty_rate_adaptive;
+	bool rf_rx_lpf_shrink;
+	bool reject_aggre_pkt;
+	bool tra_tdma_on;
+	u8 tra_tdma_nav;
+	u8 tra_tdma_ant;
+	bool tdma_on;
+	u8 tdma_ant;
+	u8 tdma_nav;
+	u8 tdma_dac_swing;
+	u8 fw_dac_swing_lvl;
+	bool ps_tdma_on;
+	u8 ps_tdma_byte[5];
+	bool pta_on;
+	u32 val_0x6c0;
+	u32 val_0x6c8;
+	u32 val_0x6cc;
+	bool sw_dac_swing_on;
+	u32 sw_dac_swing_lvl;
+	u32 wlan_act_hi;
+	u32 wlan_act_lo;
+	u32 bt_retry_index;
+	bool dec_bt_pwr;
+	bool ignore_wlan_act;
+};
+
+struct bt_coexist_8723 {
+	u32 high_priority_tx;
+	u32 high_priority_rx;
+	u32 low_priority_tx;
+	u32 low_priority_rx;
+	u8 c2h_bt_info;
+	bool c2h_bt_info_req_sent;
+	bool c2h_bt_inquiry_page;
+	u32 bt_inq_page_start_time;
+	u8 bt_retry_cnt;
+	u8 c2h_bt_info_original;
+	u8 bt_inquiry_page_cnt;
+	struct btdm_8723 btdm;
 };
 
 struct rtl_hal {
 	struct ieee80211_hw *hw;
-
+	struct bt_coexist_8723 hal_coex_8723;
 	bool up_first_time;
-	bool first_init;
 	bool being_init_adapter;
 	bool bbrf_ready;
 
@@ -1209,7 +1273,7 @@ struct rtl_efuse {
 	u8 eeprom_pwrlimit_ht40[CHANNEL_GROUP_MAX];
 	u8 eeprom_chnlarea_txpwr_cck[2][CHANNEL_GROUP_MAX_2G];
 	u8 eeprom_chnlarea_txpwr_ht40_1s[2][CHANNEL_GROUP_MAX];
-	u8 eeprom_chnlarea_txpwr_ht40_2sdiif[2][CHANNEL_GROUP_MAX];
+	u8 eprom_chnl_txpwr_ht40_2sdf[2][CHANNEL_GROUP_MAX];
 	u8 txpwrlevel_cck[2][CHANNEL_MAX_NUMBER_2G];
 	u8 txpwrlevel_ht40_1s[2][CHANNEL_MAX_NUMBER];	/*For HT 40MHZ pwr */
 	u8 txpwrlevel_ht40_2s[2][CHANNEL_MAX_NUMBER];	/*For HT 40MHZ pwr */
@@ -1312,6 +1376,7 @@ struct rtl_ps_ctl {
 };
 
 struct rtl_stats {
+	u8 psaddr[ETH_ALEN];
 	u32 mac_time[2];
 	s8 rssi;
 	u8 signal;
@@ -1503,6 +1568,11 @@ struct rtl_hal_ops {
 	void (*phy_lc_calibrate) (struct ieee80211_hw *hw, bool is2t);
 	void (*phy_set_bw_mode_callback) (struct ieee80211_hw *hw);
 	void (*dm_dynamic_txpower) (struct ieee80211_hw *hw);
+	void (*c2h_command_handle) (struct ieee80211_hw *hw);
+	void (*bt_wifi_media_status_notify) (struct ieee80211_hw *hw,
+					     bool mstate);
+	void (*bt_turn_off_bt_coexist_before_enter_lps)
+					 (struct ieee80211_hw *hw);
 };
 
 struct rtl_intf_ops {
@@ -1781,9 +1851,22 @@ struct rtl_priv {
 	struct dig_t dm_digtable;
 	struct ps_t dm_pstable;
 
-	/* data buffer pointer for USB reads */
-	__le32 *usb_data;
-	int usb_data_index;
+	/* section shared by individual drivers */
+	union {
+		struct {	/* data buffer pointer for USB reads */
+			__le32 *usb_data;
+			int usb_data_index;
+			bool initialized;
+		};
+		struct {	/* section for 8723ae */
+			bool reg_init;	/* true if regs saved */
+			u32 reg_874;
+			u32 reg_c70;
+			u32 reg_85c;
+			u32 reg_a74;
+			bool bt_operation_on;
+		};
+	};
 
 	/*This must be the last item so
 	   that it points to the data allocated
@@ -1815,6 +1898,7 @@ enum bt_co_type {
 	BT_CSR_BC4 = 3,
 	BT_CSR_BC8 = 4,
 	BT_RTL8756 = 5,
+	BT_RTL8723A = 6,
 };
 
 enum bt_cur_state {
@@ -1873,13 +1957,27 @@ struct bt_coexist_info {
 
 	bool fw_coexist_all_off;
 	bool sw_coexist_all_off;
+	bool hw_coexist_all_off;
 	u32 current_state;
 	u32 previous_state;
+	u32 current_state_h;
+	u32 previous_state_h;
+
 	u8 bt_pre_rssi_state;
+	u8 bt_pre_rssi_state1;
 
 	u8 reg_bt_iso;
 	u8 reg_bt_sco;
-
+	bool balance_on;
+	u8 bt_active_zero_cnt;
+	bool cur_bt_disabled;
+	bool pre_bt_disabled;
+
+	u8 bt_profile_case;
+	u8 bt_profile_action;
+	bool bt_busy;
+	bool hold_for_bt_operation;
+	u8 lps_counter;
 };
 
 
Index: wireless-testing-new/drivers/net/wireless/rtlwifi/pci.c
===================================================================
--- wireless-testing-new.orig/drivers/net/wireless/rtlwifi/pci.c
+++ wireless-testing-new/drivers/net/wireless/rtlwifi/pci.c
@@ -1311,6 +1311,7 @@ static bool rtl_pci_tx_chk_waitq_insert(
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_sta_info *sta_entry = NULL;
 	u8 tid = rtl_get_tid(skb);
+	__le16 fc = rtl_get_fc(skb);
 
 	if (!sta)
 		return false;
@@ -1318,6 +1319,12 @@ static bool rtl_pci_tx_chk_waitq_insert(
 
 	if (!rtlpriv->rtlhal.earlymode_enable)
 		return false;
+	if (ieee80211_is_nullfunc(fc))
+		return false;
+	if (ieee80211_is_qos_nullfunc(fc))
+		return false;
+	if (ieee80211_is_pspoll(fc))
+ 		return false;
 	if (sta_entry->tids[tid].agg.agg_state != RTL_AGG_OPERATIONAL)
 		return false;
 	if (_rtl_mac_to_hwqueue(hw, skb) > VO_QUEUE)
@@ -1359,10 +1366,8 @@ static int rtl_pci_tx(struct ieee80211_h
 	u8 own;
 	u8 temp_one = 1;
 
-	if (ieee80211_is_auth(fc)) {
-		RT_TRACE(rtlpriv, COMP_SEND, DBG_DMESG, "MAC80211_LINKING\n");
-		rtl_ips_nic_on(hw);
-	}
+	if (ieee80211_is_mgmt(fc))
+		rtl_tx_mgmt_proc(hw, skb);
 
 	if (rtlpriv->psc.sw_ps_enabled) {
 		if (ieee80211_is_data(fc) && !ieee80211_is_nullfunc(fc) &&
@@ -1630,7 +1635,7 @@ static bool _rtl_pci_find_adapter(struct
 				 "8192 PCI-E is found - vid/did=%x/%x\n",
 				 venderid, deviceid);
 			rtlhal->hw_type = HARDWARE_TYPE_RTL8192E;
-			break;
+			return false;
 		case RTL_PCI_REVISION_ID_8192SE:
 			RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 				 "8192SE is found - vid/did=%x/%x\n",
@@ -1645,6 +1650,11 @@ static bool _rtl_pci_find_adapter(struct
 			break;
 
 		}
+	} else if (deviceid == RTL_PCI_8723AE_DID) {
+		rtlhal->hw_type = HARDWARE_TYPE_RTL8723AE;
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
+			 "8723AE PCI-E is found - "
+			 "vid/did=%x/%x\n", venderid, deviceid);
 	} else if (deviceid == RTL_PCI_8192CET_DID ||
 		   deviceid == RTL_PCI_8192CE_DID ||
 		   deviceid == RTL_PCI_8191CE_DID ||
Index: wireless-testing-new/drivers/net/wireless/rtlwifi/rc.c
===================================================================
--- wireless-testing-new.orig/drivers/net/wireless/rtlwifi/rc.c
+++ wireless-testing-new/drivers/net/wireless/rtlwifi/rc.c
@@ -55,7 +55,8 @@ static u8 _rtl_rc_get_highest_rix(struct
 	 *      1M we will not use FW rate but user rate.
 	 */
 	if (rtlmac->opmode == NL80211_IFTYPE_AP ||
-		rtlmac->opmode == NL80211_IFTYPE_ADHOC) {
+	    rtlmac->opmode == NL80211_IFTYPE_ADHOC ||
+	    rtlmac->opmode == NL80211_IFTYPE_MESH_POINT) {
 		if (sta) {
 			sta_entry = (struct rtl_sta_info *) sta->drv_priv;
 			wireless_mode = sta_entry->wireless_mode;
Index: wireless-testing-new/drivers/net/wireless/rtlwifi/pci.h
===================================================================
--- wireless-testing-new.orig/drivers/net/wireless/rtlwifi/pci.h
+++ wireless-testing-new/drivers/net/wireless/rtlwifi/pci.h
@@ -79,6 +79,7 @@
 #define RTL_PCI_8173_DID	0x8173	/*8191 SE Crab */
 #define RTL_PCI_8172_DID	0x8172	/*8191 SE RE */
 #define RTL_PCI_8171_DID	0x8171	/*8191 SE Unicron */
+#define RTL_PCI_8723AE_DID	0x8723	/*8723AE */
 #define RTL_PCI_0045_DID	0x0045	/*8190 PCI for Ceraga */
 #define RTL_PCI_0046_DID	0x0046	/*8190 Cardbus for Ceraga */
 #define RTL_PCI_0044_DID	0x0044	/*8192e PCIE for Ceraga */
Index: wireless-testing-new/drivers/net/wireless/rtlwifi/base.c
===================================================================
--- wireless-testing-new.orig/drivers/net/wireless/rtlwifi/base.c
+++ wireless-testing-new/drivers/net/wireless/rtlwifi/base.c
@@ -826,6 +826,30 @@ int rtlwifi_rate_mapping(struct ieee8021
 }
 EXPORT_SYMBOL(rtlwifi_rate_mapping);
 
+bool rtl_tx_mgmt_proc(struct ieee80211_hw *hw, struct sk_buff *skb)
+{
+	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	__le16 fc = rtl_get_fc(skb);
+
+	if (rtlpriv->dm.supp_phymode_switch &&
+	    mac->link_state < MAC80211_LINKED &&
+	    (ieee80211_is_auth(fc) || ieee80211_is_probe_req(fc))) {
+		if (rtlpriv->cfg->ops->check_switch_to_dmdp)
+			rtlpriv->cfg->ops->check_switch_to_dmdp(hw);
+	}
+	if (ieee80211_is_auth(fc)) {
+		RT_TRACE(rtlpriv, COMP_SEND, DBG_DMESG, "MAC80211_LINKING\n");
+		rtl_ips_nic_on(hw);
+
+		mac->link_state = MAC80211_LINKING;
+		/* Dual mac */
+		rtlpriv->phy.need_iqk = true;
+	}
+
+	return true;
+}
+
 void rtl_get_tcb_desc(struct ieee80211_hw *hw,
 		      struct ieee80211_tx_info *info,
 		      struct ieee80211_sta *sta,
Index: wireless-testing-new/drivers/net/wireless/rtlwifi/base.h
===================================================================
--- wireless-testing-new.orig/drivers/net/wireless/rtlwifi/base.h
+++ wireless-testing-new/drivers/net/wireless/rtlwifi/base.h
@@ -142,4 +142,6 @@ u8 rtl_tid_to_ac(u8 tid);
 extern struct attribute_group rtl_attribute_group;
 int rtlwifi_rate_mapping(struct ieee80211_hw *hw,
 			 bool isht, u8 desc_rate, bool first_ampdu);
+bool rtl_tx_mgmt_proc(struct ieee80211_hw *hw, struct sk_buff *skb);
+
 #endif
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
