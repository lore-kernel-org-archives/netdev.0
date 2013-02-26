From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [RFC/RFT 08/27] rtlwifi: rtl8192c: rtl8192ce: Update to vendor driver of 2013.02.07
Date: Mon, 25 Feb 2013 18:13:20 -0600
Message-ID: <1361837619-2985-9-git-send-email-Larry.Finger@lwfinger.net>
References: <1361837619-2985-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, jcheung@suse.com, machen@suse.com,
	mmarek@suse.cz
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f53.google.com ([209.85.219.53]:64112 "EHLO
	mail-oa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759862Ab3BZAOP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2013 19:14:15 -0500
In-Reply-To: <1361837619-2985-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: jcheung@suse.com
Cc: machen@suse.com
Cc: mmarek@suse.cz
---
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c |  89 +-----
 drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c |  99 ++++++-
 drivers/net/wireless/rtlwifi/rtl8192c/fw_common.h |   4 +
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c       |  98 ++++++-
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.h       |   4 +
 drivers/net/wireless/rtlwifi/rtl8192ce/reg.h      |   1 +
 drivers/net/wireless/rtlwifi/rtl8192ce/sw.c       |   2 +
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c      | 324 ++++++----------------
 8 files changed, 298 insertions(+), 323 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c b/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c
index b793a65..b0b9f90 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c
@@ -1147,75 +1147,6 @@ void rtl92c_dm_init_rate_adaptive_mask(struct ieee80211_hw *hw)
 }
 EXPORT_SYMBOL(rtl92c_dm_init_rate_adaptive_mask);
 
-static void rtl92c_dm_refresh_rate_adaptive_mask(struct ieee80211_hw *hw)
-{
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
-	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
-	struct rate_adaptive *p_ra = &(rtlpriv->ra);
-	u32 low_rssi_thresh, high_rssi_thresh;
-	struct ieee80211_sta *sta = NULL;
-
-	if (is_hal_stop(rtlhal)) {
-		RT_TRACE(rtlpriv, COMP_RATE, DBG_LOUD,
-			 "<---- driver is going to unload\n");
-		return;
-	}
-
-	if (!rtlpriv->dm.useramask) {
-		RT_TRACE(rtlpriv, COMP_RATE, DBG_LOUD,
-			 "<---- driver does not control rate adaptive mask\n");
-		return;
-	}
-
-	if (mac->link_state == MAC80211_LINKED &&
-	    mac->opmode == NL80211_IFTYPE_STATION) {
-		switch (p_ra->pre_ratr_state) {
-		case DM_RATR_STA_HIGH:
-			high_rssi_thresh = 50;
-			low_rssi_thresh = 20;
-			break;
-		case DM_RATR_STA_MIDDLE:
-			high_rssi_thresh = 55;
-			low_rssi_thresh = 20;
-			break;
-		case DM_RATR_STA_LOW:
-			high_rssi_thresh = 50;
-			low_rssi_thresh = 25;
-			break;
-		default:
-			high_rssi_thresh = 50;
-			low_rssi_thresh = 20;
-			break;
-		}
-
-		if (rtlpriv->dm.undec_sm_pwdb > (long)high_rssi_thresh)
-			p_ra->ratr_state = DM_RATR_STA_HIGH;
-		else if (rtlpriv->dm.undec_sm_pwdb > (long)low_rssi_thresh)
-			p_ra->ratr_state = DM_RATR_STA_MIDDLE;
-		else
-			p_ra->ratr_state = DM_RATR_STA_LOW;
-
-		if (p_ra->pre_ratr_state != p_ra->ratr_state) {
-			RT_TRACE(rtlpriv, COMP_RATE, DBG_LOUD, "RSSI = %ld\n",
-				 rtlpriv->dm.undec_sm_pwdb);
-			RT_TRACE(rtlpriv, COMP_RATE, DBG_LOUD,
-				 "RSSI_LEVEL = %d\n", p_ra->ratr_state);
-			RT_TRACE(rtlpriv, COMP_RATE, DBG_LOUD,
-				 "PreState = %d, CurState = %d\n",
-				 p_ra->pre_ratr_state, p_ra->ratr_state);
-
-			rcu_read_lock();
-			sta = ieee80211_find_sta(mac->vif, mac->bssid);
-			rtlpriv->cfg->ops->update_rate_tbl(hw, sta,
-					p_ra->ratr_state);
-
-			p_ra->pre_ratr_state = p_ra->ratr_state;
-			rcu_read_unlock();
-		}
-	}
-}
-
 static void rtl92c_dm_init_dynamic_bb_powersaving(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
@@ -1437,6 +1368,9 @@ void rtl92c_dm_watchdog(struct ieee80211_hw *hw)
 	rtlpriv->cfg->ops->get_hw_reg(hw, HW_VAR_FWLPS_RF_ON,
 				      (u8 *) (&fw_ps_awake));
 
+	if (ppsc->p2p_ps_info.p2p_ps_mode)
+		fw_ps_awake = false;
+
 	if ((ppsc->rfpwr_state == ERFON) && ((!fw_current_inpsmode) &&
 					     fw_ps_awake)
 	    && (!ppsc->rfchange_inprogress)) {
@@ -1446,7 +1380,7 @@ void rtl92c_dm_watchdog(struct ieee80211_hw *hw)
 		rtl92c_dm_dynamic_bb_powersaving(hw);
 		rtl92c_dm_dynamic_txpower(hw);
 		rtl92c_dm_check_txpower_tracking(hw);
-		rtl92c_dm_refresh_rate_adaptive_mask(hw);
+		/* rtl92c_dm_refresh_rate_adaptive_mask(hw); */
 		rtl92c_dm_bt_coexist(hw);
 		rtl92c_dm_check_edca_turbo(hw);
 	}
@@ -1651,7 +1585,7 @@ static void rtl92c_bt_set_normal(struct ieee80211_hw *hw)
 	}
 }
 
-static void rtl92c_bt_ant_isolation(struct ieee80211_hw *hw)
+static void rtl92c_bt_ant_isolation(struct ieee80211_hw *hw, u8 tmp1byte)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_pci_priv *rtlpcipriv = rtl_pcipriv(hw);
@@ -1673,9 +1607,9 @@ static void rtl92c_bt_ant_isolation(struct ieee80211_hw *hw)
 			    BT_RSSI_STATE_SPECIAL_LOW)) {
 			rtl_write_byte(rtlpriv, REG_GPIO_MUXCFG, 0xa0);
 		} else if (rtlpcipriv->bt_coexist.bt_service == BT_PAN) {
-			rtl_write_byte(rtlpriv, REG_GPIO_MUXCFG, 0x00);
+			rtl_write_byte(rtlpriv, REG_GPIO_MUXCFG, tmp1byte);
 		} else {
-			rtl_write_byte(rtlpriv, REG_GPIO_MUXCFG, 0x00);
+			rtl_write_byte(rtlpriv, REG_GPIO_MUXCFG, tmp1byte);
 		}
 	}
 
@@ -1726,12 +1660,17 @@ static void rtl92c_check_bt_change(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_pci_priv *rtlpcipriv = rtl_pcipriv(hw);
+	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
+	u8 tmp1byte = 0;
 
+	if (IS_81xxC_VENDOR_UMC_B_CUT(rtlhal->version) &&
+	    rtlpcipriv->bt_coexist.bt_coexistence)
+		tmp1byte |= BIT(5);
 	if (rtlpcipriv->bt_coexist.bt_cur_state) {
 		if (rtlpcipriv->bt_coexist.bt_ant_isolation)
-			rtl92c_bt_ant_isolation(hw);
+			rtl92c_bt_ant_isolation(hw, tmp1byte);
 	} else {
-		rtl_write_byte(rtlpriv, REG_GPIO_MUXCFG, 0x00);
+		rtl_write_byte(rtlpriv, REG_GPIO_MUXCFG, tmp1byte);
 		rtlpriv->cfg->ops->set_rfreg(hw, RF90_PATH_A, 0x1e, 0xf0,
 				rtlpcipriv->bt_coexist.bt_rfreg_origin_1e);
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c b/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c
index 883f23a..04a4162 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c
@@ -552,7 +552,9 @@ void rtl92c_set_fw_pwrmode_cmd(struct ieee80211_hw *hw, u8 mode)
 	RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD, "FW LPS mode = %d\n", mode);
 
 	SET_H2CCMD_PWRMODE_PARM_MODE(u1_h2c_set_pwrmode, mode);
-	SET_H2CCMD_PWRMODE_PARM_SMART_PS(u1_h2c_set_pwrmode, 1);
+	SET_H2CCMD_PWRMODE_PARM_SMART_PS(u1_h2c_set_pwrmode,
+					 (rtlpriv->mac80211.p2p) ?
+					 ppsc->smart_ps : 1);
 	SET_H2CCMD_PWRMODE_PARM_BCN_PASS_TIME(u1_h2c_set_pwrmode,
 					      ppsc->reg_max_lps_awakeintvl);
 
@@ -808,3 +810,98 @@ void rtl92c_set_fw_joinbss_report_cmd(struct ieee80211_hw *hw, u8 mstatus)
 	rtl92c_fill_h2c_cmd(hw, H2C_JOINBSSRPT, 1, u1_joinbssrpt_parm);
 }
 EXPORT_SYMBOL(rtl92c_set_fw_joinbss_report_cmd);
+
+static void rtl92c_set_p2p_ctw_period_cmd(struct ieee80211_hw *hw, u8 ctwindow)
+{
+	u8 u1_ctwindow_period[1] = {ctwindow};
+
+	rtl92c_fill_h2c_cmd(hw, H2C_P2P_PS_CTW_CMD, 1, u1_ctwindow_period);
+}
+
+void rtl92c_set_p2p_ps_offload_cmd(struct ieee80211_hw *hw, u8 p2p_ps_state)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_ps_ctl *rtlps = rtl_psc(rtl_priv(hw));
+	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
+	struct rtl_p2p_ps_info *p2pinfo = &(rtlps->p2p_ps_info);
+	struct p2p_ps_offload_t *p2p_ps_offload = &rtlhal->p2p_ps_offload;
+	u8	i;
+	u16	ctwindow;
+	u32	start_time, tsf_low;
+
+	switch (p2p_ps_state) {
+	case P2P_PS_DISABLE:
+		RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD, "P2P_PS_DISABLE\n");
+		memset(p2p_ps_offload, 0, sizeof(struct p2p_ps_offload_t));
+		break;
+	case P2P_PS_ENABLE:
+		RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD, "P2P_PS_ENABLE\n");
+		/* update CTWindow value. */
+		if (p2pinfo->ctwindow > 0) {
+			p2p_ps_offload->ctwindow_en = 1;
+			ctwindow = p2pinfo->ctwindow;
+			rtl92c_set_p2p_ctw_period_cmd(hw, ctwindow);
+		}
+		/* hw only support 2 set of NoA */
+		for (i = 0; i < p2pinfo->noa_num; i++) {
+			/* To control the register setting for which NOA*/
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
+				while (start_time <= (tsf_low+(50*1024))) {
+					start_time += p2pinfo->noa_interval[i];
+					if (p2pinfo->noa_count_type[i] != 255)
+						p2pinfo->noa_count_type[i]--;
+				}
+			}
+			rtl_write_dword(rtlpriv, 0x5E8, start_time);
+			rtl_write_dword(rtlpriv, 0x5EC,
+					p2pinfo->noa_count_type[i]);
+		}
+
+		if ((p2pinfo->opp_ps == 1) || (p2pinfo->noa_num > 0)) {
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
+
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
+
+	rtl92c_fill_h2c_cmd(hw, H2C_P2P_PS_OFFLOAD, 1, (u8 *)p2p_ps_offload);
+}
+EXPORT_SYMBOL_GPL(rtl92c_set_p2p_ps_offload_cmd);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.h b/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.h
index 780ea5b..15b2055 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.h
@@ -67,6 +67,9 @@ enum rtl8192c_h2c_cmd {
 	H2C_RSVDPAGE = 3,
 	H2C_RSSI_REPORT = 5,
 	H2C_RA_MASK = 6,
+	H2C_MACID_PS_MODE = 7,
+	H2C_P2P_PS_OFFLOAD = 8,
+	H2C_P2P_PS_CTW_CMD = 32,
 	MAX_H2CCMD
 };
 
@@ -95,5 +98,6 @@ void rtl92c_set_fw_pwrmode_cmd(struct ieee80211_hw *hw, u8 mode);
 void rtl92c_set_fw_rsvdpagepkt(struct ieee80211_hw *hw, bool b_dl_finished);
 void rtl92c_set_fw_joinbss_report_cmd(struct ieee80211_hw *hw, u8 mstatus);
 void usb_writeN_async(struct rtl_priv *rtlpriv, u32 addr, void *data, u16 len);
+void rtl92c_set_p2p_ps_offload_cmd(struct ieee80211_hw *hw, u8 p2p_ps_state);
 
 #endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
index 1b65db7..3da9a78 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
@@ -475,6 +475,9 @@ void rtl92ce_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 
 			break;
 		}
+	case HW_VAR_H2C_FW_P2P_PS_OFFLOAD:
+		rtl92c_set_p2p_ps_offload_cmd(hw, (*(u8 *)val));
+		break;
 	case HW_VAR_AID:{
 			u16 u2btmp;
 			u2btmp = rtl_read_word(rtlpriv, REG_BCN_PSR_RPT);
@@ -505,6 +508,40 @@ void rtl92ce_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 			break;
 
 		}
+	case HW_VAR_FW_LPS_ACTION: {
+			bool enter_fwlps = *((bool *)val);
+			u8 rpwm_val, fw_pwrmode;
+			bool fw_current_inps;
+
+			if (enter_fwlps) {
+				rpwm_val = 0x02;	/* RF off */
+				fw_current_inps = true;
+				rtlpriv->cfg->ops->set_hw_reg(hw,
+						HW_VAR_FW_PSMODE_STATUS,
+						(u8 *)(&fw_current_inps));
+				rtlpriv->cfg->ops->set_hw_reg(hw,
+						HW_VAR_H2C_FW_PWRMODE,
+						(u8 *)(&ppsc->fwctrl_psmode));
+
+				rtlpriv->cfg->ops->set_hw_reg(hw,
+						HW_VAR_SET_RPWM,
+						(u8 *)(&rpwm_val));
+			} else {
+				rpwm_val = 0x0C;	/* RF on */
+				fw_pwrmode = FW_PS_ACTIVE_MODE;
+				fw_current_inps = false;
+				rtlpriv->cfg->ops->set_hw_reg(hw,
+						HW_VAR_SET_RPWM,
+						(u8 *)(&rpwm_val));
+				rtlpriv->cfg->ops->set_hw_reg(hw,
+						HW_VAR_H2C_FW_PWRMODE,
+						(u8 *)(&fw_pwrmode));
+
+				rtlpriv->cfg->ops->set_hw_reg(hw,
+						HW_VAR_FW_PSMODE_STATUS,
+						(u8 *)(&fw_current_inps));
+			}
+		break; }
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
 			 "switch case not processed\n");
@@ -1105,7 +1142,8 @@ static int _rtl92ce_set_media_status(struct ieee80211_hw *hw,
 	    type == NL80211_IFTYPE_STATION) {
 		_rtl92ce_stop_tx_beacon(hw);
 		_rtl92ce_enable_bcn_sub_func(hw);
-	} else if (type == NL80211_IFTYPE_ADHOC || type == NL80211_IFTYPE_AP) {
+	} else if (type == NL80211_IFTYPE_ADHOC || type == NL80211_IFTYPE_AP ||
+		   type == NL80211_IFTYPE_MESH_POINT) {
 		_rtl92ce_resume_tx_beacon(hw);
 		_rtl92ce_disable_bcn_sub_func(hw);
 	} else {
@@ -1137,6 +1175,11 @@ static int _rtl92ce_set_media_status(struct ieee80211_hw *hw,
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
 			 "Set Network type to AP!\n");
 		break;
+	case NL80211_IFTYPE_MESH_POINT:
+		bt_msr |= MSR_ADHOC;
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+			 "Set Network type to Mesh Point!\n");
+		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
 			 "Network type %d not supported!\n", type);
@@ -1184,7 +1227,8 @@ int rtl92ce_set_network_type(struct ieee80211_hw *hw, enum nl80211_iftype type)
 		return -EOPNOTSUPP;
 
 	if (rtlpriv->mac80211.link_state == MAC80211_LINKED) {
-		if (type != NL80211_IFTYPE_AP)
+		if (type != NL80211_IFTYPE_AP &&
+		    type != NL80211_IFTYPE_MESH_POINT)
 			rtl92ce_set_check_bssid(hw, true);
 	} else {
 		rtl92ce_set_check_bssid(hw, false);
@@ -1629,6 +1673,21 @@ static void _rtl92ce_read_adapter_info(struct ieee80211_hw *hw)
 	if (rtlefuse->autoload_failflag)
 		return;
 
+	rtlefuse->eeprom_vid = *(u16 *)&hwinfo[EEPROM_VID];
+	rtlefuse->eeprom_did = *(u16 *)&hwinfo[EEPROM_DID];
+	rtlefuse->eeprom_svid = *(u16 *)&hwinfo[EEPROM_SVID];
+	rtlefuse->eeprom_smid = *(u16 *)&hwinfo[EEPROM_SMID];
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+		 "EEPROMId = 0x%4x\n", eeprom_id);
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+		 "EEPROM VID = 0x%4x\n", rtlefuse->eeprom_vid);
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+		 "EEPROM DID = 0x%4x\n", rtlefuse->eeprom_did);
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+		 "EEPROM SVID = 0x%4x\n", rtlefuse->eeprom_svid);
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+		 "EEPROM SMID = 0x%4x\n", rtlefuse->eeprom_smid);
+
 	for (i = 0; i < 6; i += 2) {
 		usvalue = *(u16 *)&hwinfo[EEPROM_MAC_ADDR + i];
 		*((u16 *) (&rtlefuse->dev_addr[i])) = usvalue;
@@ -1766,6 +1825,9 @@ static void rtl92ce_update_hal_rate_table(struct ieee80211_hw *hw,
 		ratr_value = sta->supp_rates[1] << 4;
 	else
 		ratr_value = sta->supp_rates[0];
+	if (mac->opmode == NL80211_IFTYPE_ADHOC)
+		ratr_value = 0xfff;
+
 	ratr_value |= (sta->ht_cap.mcs.rx_mask[1] << 20 |
 			sta->ht_cap.mcs.rx_mask[0] << 12);
 	switch (wirelessmode) {
@@ -1860,7 +1922,8 @@ static void rtl92ce_update_hal_rate_mask(struct ieee80211_hw *hw,
 
 	sta_entry = (struct rtl_sta_info *) sta->drv_priv;
 	wirelessmode = sta_entry->wireless_mode;
-	if (mac->opmode == NL80211_IFTYPE_STATION)
+	if (mac->opmode == NL80211_IFTYPE_STATION ||
+	    mac->opmode == NL80211_IFTYPE_MESH_POINT)
 		curtxbw_40mhz = mac->bw_40;
 	else if (mac->opmode == NL80211_IFTYPE_AP ||
 		mac->opmode == NL80211_IFTYPE_ADHOC)
@@ -1870,6 +1933,8 @@ static void rtl92ce_update_hal_rate_mask(struct ieee80211_hw *hw,
 		ratr_bitmap = sta->supp_rates[1] << 4;
 	else
 		ratr_bitmap = sta->supp_rates[0];
+	if (mac->opmode == NL80211_IFTYPE_ADHOC)
+		ratr_bitmap = 0xfff;
 	ratr_bitmap |= (sta->ht_cap.mcs.rx_mask[1] << 20 |
 			sta->ht_cap.mcs.rx_mask[0] << 12);
 	switch (wirelessmode) {
@@ -2135,7 +2200,8 @@ void rtl92ce_set_key(struct ieee80211_hw *hw, u32 key_index,
 				macaddr = cam_const_broad;
 				entry_id = key_index;
 			} else {
-				if (mac->opmode == NL80211_IFTYPE_AP) {
+				if (mac->opmode == NL80211_IFTYPE_AP ||
+				    mac->opmode == NL80211_IFTYPE_MESH_POINT) {
 					entry_id = rtl_cam_get_free_entry(hw,
 								 p_macaddr);
 					if (entry_id >=  TOTAL_CAM_ENTRY) {
@@ -2157,7 +2223,8 @@ void rtl92ce_set_key(struct ieee80211_hw *hw, u32 key_index,
 			RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
 				 "delete one entry, entry_id is %d\n",
 				 entry_id);
-			if (mac->opmode == NL80211_IFTYPE_AP)
+			if (mac->opmode == NL80211_IFTYPE_AP ||
+			    mac->opmode == NL80211_IFTYPE_MESH_POINT)
 				rtl_cam_del_entry(hw, p_macaddr);
 			rtl_cam_delete_one_entry(hw, p_macaddr, entry_id);
 		} else {
@@ -2338,3 +2405,24 @@ void rtl92ce_suspend(struct ieee80211_hw *hw)
 void rtl92ce_resume(struct ieee80211_hw *hw)
 {
 }
+
+/* Turn on AAP (RCR:bit 0) for promicuous mode. */
+void rtl92ce_allow_all_destaddr(struct ieee80211_hw *hw,
+	bool allow_all_da, bool write_into_reg)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
+
+	if (allow_all_da) {/* Set BIT0 */
+		rtlpci->receive_config |= RCR_AAP;
+	} else {/* Clear BIT0 */
+		rtlpci->receive_config &= ~RCR_AAP;
+	}
+
+	if (write_into_reg)
+		rtl_write_dword(rtlpriv, REG_RCR, rtlpci->receive_config);
+
+	RT_TRACE(rtlpriv, COMP_TURBO | COMP_INIT, DBG_LOUD,
+		 "receive_config=0x%08X, write_into_reg=%d\n",
+		 rtlpci->receive_config, write_into_reg);
+}
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.h b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.h
index 52a3aea..2d063b0 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.h
@@ -61,6 +61,8 @@ void rtl92ce_update_interrupt_mask(struct ieee80211_hw *hw,
 void rtl92ce_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val);
 void rtl92ce_update_hal_rate_tbl(struct ieee80211_hw *hw,
 				 struct ieee80211_sta *sta, u8 rssi_level);
+void rtl92ce_update_hal_rate_tbl(struct ieee80211_hw *hw,
+				 struct ieee80211_sta *sta, u8 rssi_level);
 void rtl92ce_update_channel_access_setting(struct ieee80211_hw *hw);
 bool rtl92ce_gpio_radio_on_off_checking(struct ieee80211_hw *hw, u8 *valid);
 void rtl92ce_enable_hw_security_config(struct ieee80211_hw *hw);
@@ -74,5 +76,7 @@ void rtl8192ce_bt_reg_init(struct ieee80211_hw *hw);
 void rtl8192ce_bt_hw_init(struct ieee80211_hw *hw);
 void rtl92ce_suspend(struct ieee80211_hw *hw);
 void rtl92ce_resume(struct ieee80211_hw *hw);
+void rtl92ce_allow_all_destaddr(struct ieee80211_hw *hw,
+				bool allow_all_da, bool write_into_reg);
 
 #endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/reg.h b/drivers/net/wireless/rtlwifi/rtl8192ce/reg.h
index e4d738f..bd4aef7 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/reg.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/reg.h
@@ -544,6 +544,7 @@
 #define	IMR_WLANOFF				BIT(0)
 
 #define EFUSE_REAL_CONTENT_LEN			512
+#define EFUSE_OOB_PROTECT_BYTES			15
 
 #define	EEPROM_DEFAULT_TSSI			0x0
 #define EEPROM_DEFAULT_TXPOWERDIFF		0x0
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c b/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c
index 49f663b..7347f59 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c
@@ -228,6 +228,7 @@ static struct rtl_hal_ops rtl8192ce_hal_ops = {
 	.enable_hw_sec = rtl92ce_enable_hw_security_config,
 	.set_key = rtl92ce_set_key,
 	.init_sw_leds = rtl92ce_init_sw_leds,
+	.allow_all_destaddr = rtl92ce_allow_all_destaddr,
 	.get_bbreg = rtl92c_phy_query_bb_reg,
 	.set_bbreg = rtl92c_phy_set_bb_reg,
 	.set_rfreg = rtl92ce_phy_set_rf_reg,
@@ -278,6 +279,7 @@ static struct rtl_hal_cfg rtl92ce_hal_cfg = {
 	.maps[EFUSE_HWSET_MAX_SIZE] = HWSET_MAX_SIZE,
 	.maps[EFUSE_MAX_SECTION_MAP] = EFUSE_MAX_SECTION,
 	.maps[EFUSE_REAL_CONTENT_SIZE] = EFUSE_REAL_CONTENT_LEN,
+	.maps[EFUSE_OOB_PROTECT_BYTES_LEN] = EFUSE_OOB_PROTECT_BYTES,
 
 	.maps[RWCAM] = REG_CAMCMD,
 	.maps[WCAMI] = REG_CAMWRITE,
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c b/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
index b9b1a6e..65bf5fb 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
@@ -30,6 +30,7 @@
 #include "../wifi.h"
 #include "../pci.h"
 #include "../base.h"
+#include "../stats.h"
 #include "reg.h"
 #include "def.h"
 #include "phy.h"
@@ -42,7 +43,7 @@ static u8 _rtl92ce_map_hwqueue_to_fwqueue(struct sk_buff *skb, u8 hw_queue)
 
 	if (unlikely(ieee80211_is_beacon(fc)))
 		return QSLT_BEACON;
-	if (ieee80211_is_mgmt(fc))
+	if (ieee80211_is_mgmt(fc) || ieee80211_is_ctl(fc))
 		return QSLT_MGNT;
 
 	return skb->priority;
@@ -78,16 +79,6 @@ static u8 _rtl92c_evm_db_to_percentage(char value)
 	return ret_val;
 }
 
-static long _rtl92ce_translate_todbm(struct ieee80211_hw *hw,
-				     u8 signal_strength_index)
-{
-	long signal_power;
-
-	signal_power = (long)((signal_strength_index + 1) >> 1);
-	signal_power -= 95;
-	return signal_power;
-}
-
 static long _rtl92ce_signal_scale_mapping(struct ieee80211_hw *hw,
 		long currsig)
 {
@@ -139,7 +130,6 @@ static void _rtl92ce_query_rxphystatus(struct ieee80211_hw *hw,
 	pstats->packet_toself = packet_toself;
 	pstats->is_cck = is_cck_rate;
 	pstats->packet_beacon = packet_beacon;
-	pstats->is_cck = is_cck_rate;
 	pstats->rx_mimo_sig_qual[0] = -1;
 	pstats->rx_mimo_sig_qual[1] = -1;
 
@@ -192,10 +182,30 @@ static void _rtl92ce_query_rxphystatus(struct ieee80211_hw *hw,
 			}
 		}
 
-		pwdb_all = _rtl92c_query_rxpwrpercentage(rx_pwr_all);
+		pwdb_all = rtl_query_rxpwrpercentage(rx_pwr_all);
+		/* CCK gain is smaller than OFDM/MCS gain,
+		 * so we add gain diff by experiences,
+		 * the val is 6
+		 */
+		pwdb_all += 6;
+		if (pwdb_all > 100)
+			pwdb_all = 100;
+		/* modify the offset to make the same
+		 * gain index with OFDM.
+		 */
+		if (pwdb_all > 34 && pwdb_all <= 42)
+			pwdb_all -= 2;
+		else if (pwdb_all > 26 && pwdb_all <= 34)
+			pwdb_all -= 6;
+		else if (pwdb_all > 14 && pwdb_all <= 26)
+			pwdb_all -= 8;
+		else if (pwdb_all > 4 && pwdb_all <= 14)
+			pwdb_all -= 4;
+
 		pstats->rx_pwdb_all = pwdb_all;
 		pstats->recvsignalpower = rx_pwr_all;
 
+		/* (3) Get Signal Quality (EVM) */
 		if (packet_match_bssid) {
 			u8 sq;
 			if (pstats->rx_pwdb_all > 40)
@@ -217,29 +227,38 @@ static void _rtl92ce_query_rxphystatus(struct ieee80211_hw *hw,
 	} else {
 		rtlpriv->dm.rfpath_rxenable[0] =
 		    rtlpriv->dm.rfpath_rxenable[1] = true;
+		/* (1)Get RSSI for HT rate */
 		for (i = RF90_PATH_A; i < RF90_PATH_MAX; i++) {
+			/* we will judge RF RX path now. */
 			if (rtlpriv->dm.rfpath_rxenable[i])
 				rf_rx_num++;
 
 			rx_pwr[i] =
 			    ((p_drvinfo->gain_trsw[i] & 0x3f) * 2) - 110;
+			/* Translate DBM to percentage. */
 			rssi = _rtl92c_query_rxpwrpercentage(rx_pwr[i]);
 			total_rssi += rssi;
+			/* Get Rx snr value in DB */
 			rtlpriv->stats.rx_snr_db[i] =
 			    (long)(p_drvinfo->rxsnr[i] / 2);
 
+			/* Record Signal Strength for next packet */
 			if (packet_match_bssid)
 				pstats->rx_mimo_signalstrength[i] = (u8) rssi;
 		}
 
+		/* (2)PWDB, Average PWDB cacluated by
+		 * hardware (for rate adaptive)
+		 */
 		rx_pwr_all = ((p_drvinfo->pwdb_all >> 1) & 0x7f) - 110;
 		pwdb_all = _rtl92c_query_rxpwrpercentage(rx_pwr_all);
 		pstats->rx_pwdb_all = pwdb_all;
 		pstats->rxpower = rx_pwr_all;
 		pstats->recvsignalpower = rx_pwr_all;
 
-		if (pdesc->rxht && pdesc->rxmcs >= DESC92_RATEMCS8 &&
-		    pdesc->rxmcs <= DESC92_RATEMCS15)
+		/* (3)EVM of HT rate */
+		if (pstats->is_ht && pstats->rate >= DESC92_RATEMCS8 &&
+		    pstats->rate <= DESC92_RATEMCS15)
 			max_spatial_stream = 2;
 		else
 			max_spatial_stream = 1;
@@ -248,6 +267,9 @@ static void _rtl92ce_query_rxphystatus(struct ieee80211_hw *hw,
 			evm = _rtl92c_evm_db_to_percentage(p_drvinfo->rxevm[i]);
 
 			if (packet_match_bssid) {
+				/* Fill value in RFD, Get the first
+				 * spatial stream only
+				 */
 				if (i == 0)
 					pstats->signalquality =
 					    (u8) (evm & 0xff);
@@ -256,6 +278,9 @@ static void _rtl92ce_query_rxphystatus(struct ieee80211_hw *hw,
 		}
 	}
 
+	/* UI BSS List signal strength(in percentage),
+	 * make it good looking, from 0~100.
+	 */
 	if (is_cck_rate)
 		pstats->signalstrength =
 		    (u8) (_rtl92ce_signal_scale_mapping(hw, pwdb_all));
@@ -265,215 +290,6 @@ static void _rtl92ce_query_rxphystatus(struct ieee80211_hw *hw,
 			  (hw, total_rssi /= rf_rx_num));
 }
 
-static void _rtl92ce_process_ui_rssi(struct ieee80211_hw *hw,
-		struct rtl_stats *pstats)
-{
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
-	u8 rfpath;
-	u32 last_rssi, tmpval;
-
-	if (pstats->packet_toself || pstats->packet_beacon) {
-		rtlpriv->stats.rssi_calculate_cnt++;
-
-		if (rtlpriv->stats.ui_rssi.total_num++ >=
-		    PHY_RSSI_SLID_WIN_MAX) {
-
-			rtlpriv->stats.ui_rssi.total_num =
-			    PHY_RSSI_SLID_WIN_MAX;
-			last_rssi =
-			    rtlpriv->stats.ui_rssi.elements[rtlpriv->
-						    stats.ui_rssi.index];
-			rtlpriv->stats.ui_rssi.total_val -= last_rssi;
-		}
-
-		rtlpriv->stats.ui_rssi.total_val += pstats->signalstrength;
-		rtlpriv->stats.ui_rssi.elements[rtlpriv->stats.ui_rssi.
-						index++] =
-		    pstats->signalstrength;
-
-		if (rtlpriv->stats.ui_rssi.index >= PHY_RSSI_SLID_WIN_MAX)
-			rtlpriv->stats.ui_rssi.index = 0;
-
-		tmpval = rtlpriv->stats.ui_rssi.total_val /
-		    rtlpriv->stats.ui_rssi.total_num;
-		rtlpriv->stats.signal_strength =
-		    _rtl92ce_translate_todbm(hw, (u8) tmpval);
-		pstats->rssi = rtlpriv->stats.signal_strength;
-	}
-
-	if (!pstats->is_cck && pstats->packet_toself) {
-		for (rfpath = RF90_PATH_A; rfpath < rtlphy->num_total_rfpath;
-		     rfpath++) {
-			if (rtlpriv->stats.rx_rssi_percentage[rfpath] == 0) {
-				rtlpriv->stats.rx_rssi_percentage[rfpath] =
-				    pstats->rx_mimo_signalstrength[rfpath];
-
-			}
-
-			if (pstats->rx_mimo_signalstrength[rfpath] >
-			    rtlpriv->stats.rx_rssi_percentage[rfpath]) {
-				rtlpriv->stats.rx_rssi_percentage[rfpath] =
-				    ((rtlpriv->stats.
-				      rx_rssi_percentage[rfpath] *
-				      (RX_SMOOTH_FACTOR - 1)) +
-				     (pstats->rx_mimo_signalstrength[rfpath])) /
-				    (RX_SMOOTH_FACTOR);
-
-				rtlpriv->stats.rx_rssi_percentage[rfpath] =
-				    rtlpriv->stats.rx_rssi_percentage[rfpath] +
-				    1;
-			} else {
-				rtlpriv->stats.rx_rssi_percentage[rfpath] =
-				    ((rtlpriv->stats.
-				      rx_rssi_percentage[rfpath] *
-				      (RX_SMOOTH_FACTOR - 1)) +
-				     (pstats->rx_mimo_signalstrength[rfpath])) /
-				    (RX_SMOOTH_FACTOR);
-			}
-
-		}
-	}
-}
-
-static void _rtl92ce_update_rxsignalstatistics(struct ieee80211_hw *hw,
-					       struct rtl_stats *pstats)
-{
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	int weighting = 0;
-
-	if (rtlpriv->stats.recv_signal_power == 0)
-		rtlpriv->stats.recv_signal_power = pstats->recvsignalpower;
-
-	if (pstats->recvsignalpower > rtlpriv->stats.recv_signal_power)
-		weighting = 5;
-
-	else if (pstats->recvsignalpower < rtlpriv->stats.recv_signal_power)
-		weighting = (-5);
-
-	rtlpriv->stats.recv_signal_power =
-	    (rtlpriv->stats.recv_signal_power * 5 +
-	     pstats->recvsignalpower + weighting) / 6;
-}
-
-static void _rtl92ce_process_pwdb(struct ieee80211_hw *hw,
-		struct rtl_stats *pstats)
-{
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
-	long undec_sm_pwdb;
-
-	if (mac->opmode == NL80211_IFTYPE_ADHOC) {
-		return;
-	} else {
-		undec_sm_pwdb = rtlpriv->dm.undec_sm_pwdb;
-	}
-
-	if (pstats->packet_toself || pstats->packet_beacon) {
-		if (undec_sm_pwdb < 0)
-			undec_sm_pwdb = pstats->rx_pwdb_all;
-
-		if (pstats->rx_pwdb_all > (u32) undec_sm_pwdb) {
-			undec_sm_pwdb = (((undec_sm_pwdb) *
-			      (RX_SMOOTH_FACTOR - 1)) +
-			     (pstats->rx_pwdb_all)) / (RX_SMOOTH_FACTOR);
-
-			undec_sm_pwdb += 1;
-		} else {
-			undec_sm_pwdb = (((undec_sm_pwdb) *
-			      (RX_SMOOTH_FACTOR - 1)) +
-			     (pstats->rx_pwdb_all)) / (RX_SMOOTH_FACTOR);
-		}
-
-		rtlpriv->dm.undec_sm_pwdb = undec_sm_pwdb;
-		_rtl92ce_update_rxsignalstatistics(hw, pstats);
-	}
-}
-
-static void _rtl92ce_process_ui_link_quality(struct ieee80211_hw *hw,
-					     struct rtl_stats *pstats)
-{
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	u32 last_evm, n_spatialstream, tmpval;
-
-	if (pstats->signalquality != 0) {
-		if (pstats->packet_toself || pstats->packet_beacon) {
-
-			if (rtlpriv->stats.ui_link_quality.total_num++ >=
-			    PHY_LINKQUALITY_SLID_WIN_MAX) {
-				rtlpriv->stats.ui_link_quality.total_num =
-				    PHY_LINKQUALITY_SLID_WIN_MAX;
-				last_evm =
-				    rtlpriv->stats.
-				    ui_link_quality.elements[rtlpriv->
-							  stats.ui_link_quality.
-							  index];
-				rtlpriv->stats.ui_link_quality.total_val -=
-				    last_evm;
-			}
-
-			rtlpriv->stats.ui_link_quality.total_val +=
-			    pstats->signalquality;
-			rtlpriv->stats.ui_link_quality.elements[rtlpriv->stats.
-								ui_link_quality.
-								index++] =
-			    pstats->signalquality;
-
-			if (rtlpriv->stats.ui_link_quality.index >=
-			    PHY_LINKQUALITY_SLID_WIN_MAX)
-				rtlpriv->stats.ui_link_quality.index = 0;
-
-			tmpval = rtlpriv->stats.ui_link_quality.total_val /
-			    rtlpriv->stats.ui_link_quality.total_num;
-			rtlpriv->stats.signal_quality = tmpval;
-
-			rtlpriv->stats.last_sigstrength_inpercent = tmpval;
-
-			for (n_spatialstream = 0; n_spatialstream < 2;
-			     n_spatialstream++) {
-				if (pstats->
-				    rx_mimo_sig_qual[n_spatialstream] != -1) {
-					if (rtlpriv->stats.
-					    rx_evm_percentage[n_spatialstream]
-					    == 0) {
-						rtlpriv->stats.
-						   rx_evm_percentage
-						   [n_spatialstream] =
-						   pstats->rx_mimo_sig_qual
-						   [n_spatialstream];
-					}
-
-					rtlpriv->stats.
-					    rx_evm_percentage[n_spatialstream] =
-					    ((rtlpriv->
-					      stats.rx_evm_percentage
-					      [n_spatialstream] *
-					      (RX_SMOOTH_FACTOR - 1)) +
-					     (pstats->rx_mimo_sig_qual
-					      [n_spatialstream] * 1)) /
-					    (RX_SMOOTH_FACTOR);
-				}
-			}
-		}
-	} else {
-		;
-	}
-}
-
-static void _rtl92ce_process_phyinfo(struct ieee80211_hw *hw,
-				     u8 *buffer,
-				     struct rtl_stats *pcurrent_stats)
-{
-
-	if (!pcurrent_stats->packet_matchbssid &&
-	    !pcurrent_stats->packet_beacon)
-		return;
-
-	_rtl92ce_process_ui_rssi(hw, pcurrent_stats);
-	_rtl92ce_process_pwdb(hw, pcurrent_stats);
-	_rtl92ce_process_ui_link_quality(hw, pcurrent_stats);
-}
-
 static void _rtl92ce_translate_rx_signal_stuff(struct ieee80211_hw *hw,
 					       struct sk_buff *skb,
 					       struct rtl_stats *pstats,
@@ -516,7 +332,7 @@ static void _rtl92ce_translate_rx_signal_stuff(struct ieee80211_hw *hw,
 				   packet_matchbssid, packet_toself,
 				   packet_beacon);
 
-	_rtl92ce_process_phyinfo(hw, tmp_buf, pstats);
+	rtl_process_phyinfo(hw, tmp_buf, pstats);
 }
 
 bool rtl92ce_rx_query_desc(struct ieee80211_hw *hw,
@@ -526,7 +342,7 @@ bool rtl92ce_rx_query_desc(struct ieee80211_hw *hw,
 {
 	struct rx_fwinfo_92c *p_drvinfo;
 	struct rx_desc_92c *pdesc = (struct rx_desc_92c *)p_desc;
-
+	struct ieee80211_hdr *hdr;
 	u32 phystatus = GET_RX_DESC_PHYST(pdesc);
 	stats->length = (u16) GET_RX_DESC_PKT_LEN(pdesc);
 	stats->rx_drvinfo_size = (u8) GET_RX_DESC_DRV_INFO_SIZE(pdesc) *
@@ -539,37 +355,60 @@ bool rtl92ce_rx_query_desc(struct ieee80211_hw *hw,
 	stats->rate = (u8) GET_RX_DESC_RXMCS(pdesc);
 	stats->shortpreamble = (u16) GET_RX_DESC_SPLCP(pdesc);
 	stats->isampdu = (bool) (GET_RX_DESC_PAGGR(pdesc) == 1);
-	stats->isampdu = (bool) ((GET_RX_DESC_PAGGR(pdesc) == 1)
+	stats->isfirst_ampdu = (bool) ((GET_RX_DESC_PAGGR(pdesc) == 1)
 				   && (GET_RX_DESC_FAGGR(pdesc) == 1));
 	stats->timestamp_low = GET_RX_DESC_TSFL(pdesc);
 	stats->rx_is40Mhzpacket = (bool) GET_RX_DESC_BW(pdesc);
+	stats->is_ht = (bool)GET_RX_DESC_RXHT(pdesc);
+
+	stats->is_cck = RX_HAL_IS_CCK_RATE(pdesc);
 
 	rx_status->freq = hw->conf.channel->center_freq;
 	rx_status->band = hw->conf.channel->band;
 
-	if (GET_RX_DESC_CRC32(pdesc))
-		rx_status->flag |= RX_FLAG_FAILED_FCS_CRC;
+	hdr = (struct ieee80211_hdr *)(skb->data + stats->rx_drvinfo_size
+			+ stats->rx_bufshift);
 
-	if (!GET_RX_DESC_SWDEC(pdesc))
-		rx_status->flag |= RX_FLAG_DECRYPTED;
+	if (stats->crc)
+		rx_status->flag |= RX_FLAG_FAILED_FCS_CRC;
 
-	if (GET_RX_DESC_BW(pdesc))
+	if (stats->rx_is40Mhzpacket)
 		rx_status->flag |= RX_FLAG_40MHZ;
 
-	if (GET_RX_DESC_RXHT(pdesc))
+	if (stats->is_ht)
 		rx_status->flag |= RX_FLAG_HT;
 
 	rx_status->flag |= RX_FLAG_MACTIME_START;
 
-	if (stats->decrypted)
-		rx_status->flag |= RX_FLAG_DECRYPTED;
-
+	/* hw will set stats->decrypted true, if it finds the
+	 * frame is open data frame or mgmt frame.
+	 * So hw will not decryption robust managment frame
+	 * for IEEE80211w but still set status->decrypted
+	 * true, so here we should set it back to undecrypted
+	 * for IEEE80211w frame, and mac80211 sw will help
+	 * to decrypt it
+	 */
+	if (stats->decrypted) {
+		if (!hdr) {
+			/* In testing, hdr was NULL here */
+			return false;
+		}
+		if ((ieee80211_is_robust_mgmt_frame(hdr)) &&
+		    (ieee80211_has_protected(hdr->frame_control)))
+			rx_status->flag &= ~RX_FLAG_DECRYPTED;
+		else
+			rx_status->flag |= RX_FLAG_DECRYPTED;
+	}
+	/* rate_idx: index of data rate into band's
+	 * supported rates or MCS index if HT rates
+	 * are use (RX_FLAG_HT)
+	 * Notice: this is diff with windows define
+	 */
 	rx_status->rate_idx = rtlwifi_rate_mapping(hw,
-				(bool)GET_RX_DESC_RXHT(pdesc),
-				(u8)GET_RX_DESC_RXMCS(pdesc),
-				(bool)GET_RX_DESC_PAGGR(pdesc));
+				stats->is_ht, stats->rate,
+				stats->isfirst_ampdu);
 
-	rx_status->mactime = GET_RX_DESC_TSFL(pdesc);
+	rx_status->mactime = stats->timestamp_low;
 	if (phystatus) {
 		p_drvinfo = (struct rx_fwinfo_92c *)(skb->data +
 						     stats->rx_bufshift);
@@ -580,7 +419,7 @@ bool rtl92ce_rx_query_desc(struct ieee80211_hw *hw,
 	}
 
 	/*rx_status->qual = stats->signal; */
-	rx_status->signal = stats->rssi + 10;
+	rx_status->signal = stats->recvsignalpower + 10;
 	/*rx_status->noise = -stats->noise; */
 
 	return true;
@@ -624,7 +463,8 @@ void rtl92ce_tx_fill_desc(struct ieee80211_hw *hw,
 	if (mac->opmode == NL80211_IFTYPE_STATION) {
 		bw_40 = mac->bw_40;
 	} else if (mac->opmode == NL80211_IFTYPE_AP ||
-		mac->opmode == NL80211_IFTYPE_ADHOC) {
+		   mac->opmode == NL80211_IFTYPE_ADHOC ||
+		   mac->opmode == NL80211_IFTYPE_MESH_POINT) {
 		if (sta)
 			bw_40 = sta->bandwidth >= IEEE80211_STA_RX_BW_40;
 	}
-- 
1.8.1.4
