From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [RFC/RFT 07/27] rtlwifi: rtl8723ae: Update to vendor driver of 2013.02.07
Date: Mon, 25 Feb 2013 18:13:19 -0600
Message-ID: <1361837619-2985-8-git-send-email-Larry.Finger@lwfinger.net>
References: <1361837619-2985-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jcheung-IBi9RG/b67k@public.gmane.org, machen-IBi9RG/b67k@public.gmane.org,
	mmarek-AlSwsSmVLrQ@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1361837619-2985-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Cc: jcheung-IBi9RG/b67k@public.gmane.org
Cc: machen-IBi9RG/b67k@public.gmane.org
Cc: mmarek-AlSwsSmVLrQ@public.gmane.org
---
 drivers/net/wireless/rtlwifi/rtl8723ae/dm.c  | 76 +++++++++++++++++++++-
 drivers/net/wireless/rtlwifi/rtl8723ae/dm.h  |  6 ++
 drivers/net/wireless/rtlwifi/rtl8723ae/fw.c  | 97 +++++++++++++++++++++++++++-
 drivers/net/wireless/rtlwifi/rtl8723ae/fw.h  |  7 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/hw.c  | 36 +++++++++++
 drivers/net/wireless/rtlwifi/rtl8723ae/trx.c | 10 ++-
 drivers/net/wireless/rtlwifi/wifi.h          |  2 +-
 7 files changed, 226 insertions(+), 8 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/dm.c b/drivers/net/wireless/rtlwifi/rtl8723ae/dm.c
index 12e2a3c..f9b7467 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/dm.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/dm.c
@@ -707,6 +707,77 @@ void rtl8723ae_dm_init_rate_adaptive_mask(struct ieee80211_hw *hw)
 		rtlpriv->dm.useramask = false;
 }
 
+static void rtl8723ae_dm_refresh_rate_adaptive_mask(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
+	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
+	struct rate_adaptive *p_ra = &(rtlpriv->ra);
+	u32 low_rssithresh_for_ra, high_rssithresh_for_ra;
+	struct ieee80211_sta *sta = NULL;
+
+	if (is_hal_stop(rtlhal)) {
+		RT_TRACE(rtlpriv, COMP_RATE, DBG_LOUD,
+			 " driver is going to unload\n");
+		return;
+	}
+
+	if (!rtlpriv->dm.useramask) {
+		RT_TRACE(rtlpriv, COMP_RATE, DBG_LOUD,
+			 " driver does not control rate adaptive mask\n");
+		return;
+	}
+
+	if (mac->link_state == MAC80211_LINKED &&
+	    mac->opmode == NL80211_IFTYPE_STATION) {
+		switch (p_ra->pre_ratr_state) {
+		case DM_RATR_STA_HIGH:
+			high_rssithresh_for_ra = 50;
+			low_rssithresh_for_ra = 20;
+			break;
+		case DM_RATR_STA_MIDDLE:
+			high_rssithresh_for_ra = 55;
+			low_rssithresh_for_ra = 20;
+			break;
+		case DM_RATR_STA_LOW:
+			high_rssithresh_for_ra = 50;
+			low_rssithresh_for_ra = 25;
+			break;
+		default:
+			high_rssithresh_for_ra = 50;
+			low_rssithresh_for_ra = 20;
+			break;
+		}
+
+		if (rtlpriv->dm.undec_sm_pwdb > high_rssithresh_for_ra)
+			p_ra->ratr_state = DM_RATR_STA_HIGH;
+		else if (rtlpriv->dm.undec_sm_pwdb > low_rssithresh_for_ra)
+			p_ra->ratr_state = DM_RATR_STA_MIDDLE;
+		else
+			p_ra->ratr_state = DM_RATR_STA_LOW;
+
+		if (p_ra->pre_ratr_state != p_ra->ratr_state) {
+			RT_TRACE(rtlpriv, COMP_RATE, DBG_LOUD,
+				 "RSSI = %ld\n",
+				 rtlpriv->dm.undec_sm_pwdb);
+			RT_TRACE(rtlpriv, COMP_RATE, DBG_LOUD,
+				 "RSSI_LEVEL = %d\n", p_ra->ratr_state);
+			RT_TRACE(rtlpriv, COMP_RATE, DBG_LOUD,
+				 "PreState = %d, CurState = %d\n",
+				 p_ra->pre_ratr_state, p_ra->ratr_state);
+
+			rcu_read_lock();
+			sta = rtl_find_sta(hw, mac->bssid);
+			if (sta)
+				rtlpriv->cfg->ops->update_rate_tbl(hw, sta,
+							   p_ra->ratr_state);
+			rcu_read_unlock();
+
+			p_ra->pre_ratr_state = p_ra->ratr_state;
+		}
+	}
+}
+
 static void rtl8723ae_dm_init_dynamic_bpowersaving(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
@@ -853,6 +924,9 @@ void rtl8723ae_dm_watchdog(struct ieee80211_hw *hw)
 	rtlpriv->cfg->ops->get_hw_reg(hw, HW_VAR_FWLPS_RF_ON,
 				      (u8 *) (&fw_ps_awake));
 
+	if (ppsc->p2p_ps_info.p2p_ps_mode)
+		fw_ps_awake = false;
+
 	if ((ppsc->rfpwr_state == ERFON) &&
 	    ((!fw_current_inpsmode) && fw_ps_awake) &&
 	    (!ppsc->rfchange_inprogress)) {
@@ -861,7 +935,7 @@ void rtl8723ae_dm_watchdog(struct ieee80211_hw *hw)
 		rtl8723ae_dm_false_alarm_counter_statistics(hw);
 		rtl8723ae_dm_dynamic_bpowersaving(hw);
 		rtl8723ae_dm_dynamic_txpower(hw);
-		/* rtl92c_dm_refresh_rate_adaptive_mask(hw); */
+		rtl8723ae_dm_refresh_rate_adaptive_mask(hw);
 		rtl8723ae_dm_bt_coexist(hw);
 		rtl8723ae_dm_check_edca_turbo(hw);
 	}
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/dm.h b/drivers/net/wireless/rtlwifi/rtl8723ae/dm.h
index 39d2461..a372b02 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/dm.h
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/dm.h
@@ -55,7 +55,13 @@
 #define DM_DIG_BACKOFF_MIN			-4
 #define DM_DIG_BACKOFF_DEFAULT			10
 
+#define RXPATHSELECTION_SS_TH_LOW		30
+#define RXPATHSELECTION_DIFF_TH			18
+
 #define DM_RATR_STA_INIT			0
+#define DM_RATR_STA_HIGH			1
+#define DM_RATR_STA_MIDDLE			2
+#define DM_RATR_STA_LOW				3
 
 #define TXHIGHPWRLEVEL_NORMAL			0
 #define TXHIGHPWRLEVEL_LEVEL1			1
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/fw.c b/drivers/net/wireless/rtlwifi/rtl8723ae/fw.c
index 35cb8f8..dedfa1e 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/fw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/fw.c
@@ -494,7 +494,9 @@ void rtl8723ae_set_fw_pwrmode_cmd(struct ieee80211_hw *hw, u8 mode)
 	RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD, "FW LPS mode = %d\n", mode);
 
 	SET_H2CCMD_PWRMODE_PARM_MODE(u1_h2c_set_pwrmode, mode);
-	SET_H2CCMD_PWRMODE_PARM_SMART_PS(u1_h2c_set_pwrmode, 1);
+	SET_H2CCMD_PWRMODE_PARM_SMART_PS(u1_h2c_set_pwrmode,
+					 (rtlpriv->mac80211.p2p) ?
+					 ppsc->smart_ps : 1);
 	SET_H2CCMD_PWRMODE_PARM_BCN_PASS_TIME(u1_h2c_set_pwrmode,
 					      ppsc->reg_max_lps_awakeintvl);
 
@@ -741,3 +743,96 @@ void rtl8723ae_set_fw_joinbss_report_cmd(struct ieee80211_hw *hw, u8 mstatus)
 
 	rtl8723ae_fill_h2c_cmd(hw, H2C_JOINBSSRPT, 1, u1_joinbssrpt_parm);
 }
+
+static void rtl8723e_set_p2p_ctw_period_cmd(struct ieee80211_hw *hw,
+					    u8 ctwindow)
+{
+	u8 u1_ctwindow_period[1] = {ctwindow};
+
+	rtl8723ae_fill_h2c_cmd(hw, H2C_P2P_PS_CTW_CMD, 1, u1_ctwindow_period);
+}
+
+void rtl8723ae_set_p2p_ps_offload_cmd(struct ieee80211_hw *hw, u8 p2p_ps_state)
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
+			rtl8723e_set_p2p_ctw_period_cmd(hw, ctwindow);
+		}
+
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
+	rtl8723ae_fill_h2c_cmd(hw, H2C_P2P_PS_OFFLOAD, 1, (u8 *)p2p_ps_offload);
+}
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/fw.h b/drivers/net/wireless/rtlwifi/rtl8723ae/fw.h
index 89994e1..ed3b795 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/fw.h
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/fw.h
@@ -70,8 +70,10 @@ enum rtl8192c_h2c_cmd {
 	H2C_SETPWRMODE = 1,
 	H2C_JOINBSSRPT = 2,
 	H2C_RSVDPAGE = 3,
-	H2C_RSSI_REPORT = 5,
-	H2C_RA_MASK = 6,
+	H2C_RSSI_REPORT = 4,
+	H2C_P2P_PS_CTW_CMD = 5,
+	H2C_P2P_PS_OFFLOAD = 6,
+	H2C_RA_MASK = 7,
 	MAX_H2CCMD
 };
 
@@ -97,5 +99,6 @@ void rtl8723ae_firmware_selfreset(struct ieee80211_hw *hw);
 void rtl8723ae_set_fw_pwrmode_cmd(struct ieee80211_hw *hw, u8 mode);
 void rtl8723ae_set_fw_rsvdpagepkt(struct ieee80211_hw *hw, bool b_dl_finished);
 void rtl8723ae_set_fw_joinbss_report_cmd(struct ieee80211_hw *hw, u8 mstatus);
+void rtl8723ae_set_p2p_ps_offload_cmd(struct ieee80211_hw *hw, u8 p2p_ps_state);
 
 #endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/hw.c b/drivers/net/wireless/rtlwifi/rtl8723ae/hw.c
index 9a0c71c..1784622 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/hw.c
@@ -449,6 +449,9 @@ void rtl8723ae_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		rtl8723ae_set_fw_joinbss_report_cmd(hw, (*(u8 *) val));
 
 		break; }
+	case HW_VAR_H2C_FW_P2P_PS_OFFLOAD:
+		rtl8723ae_set_p2p_ps_offload_cmd(hw, (*(u8 *)val));
+		break;
 	case HW_VAR_AID:{
 		u16 u2btmp;
 		u2btmp = rtl_read_word(rtlpriv, REG_BCN_PSR_RPT);
@@ -474,6 +477,39 @@ void rtl8723ae_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		if (btype_ibss == true)
 			_rtl8723ae_resume_tx_beacon(hw);
 		break; }
+	case HW_VAR_FW_LPS_ACTION: {
+		bool enter_fwlps = *((bool *)val);
+		u8 rpwm_val, fw_pwrmode;
+		bool fw_current_inps;
+
+		if (enter_fwlps) {
+			rpwm_val = 0x02;	/* RF off */
+			fw_current_inps = true;
+			rtlpriv->cfg->ops->set_hw_reg(hw,
+					HW_VAR_FW_PSMODE_STATUS,
+					(u8 *)(&fw_current_inps));
+			rtlpriv->cfg->ops->set_hw_reg(hw,
+					HW_VAR_H2C_FW_PWRMODE,
+					(u8 *)(&ppsc->fwctrl_psmode));
+
+			rtlpriv->cfg->ops->set_hw_reg(hw,
+					HW_VAR_SET_RPWM,
+					(u8 *)(&rpwm_val));
+		} else {
+			rpwm_val = 0x0C;	/* RF on */
+			fw_pwrmode = FW_PS_ACTIVE_MODE;
+			fw_current_inps = false;
+			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_SET_RPWM,
+					(u8 *)(&rpwm_val));
+			rtlpriv->cfg->ops->set_hw_reg(hw,
+					HW_VAR_H2C_FW_PWRMODE,
+					(u8 *)(&fw_pwrmode));
+
+			rtlpriv->cfg->ops->set_hw_reg(hw,
+					HW_VAR_FW_PSMODE_STATUS,
+					(u8 *)(&fw_current_inps));
+		}
+		break; }
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
 			 "switch case not processed\n");
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c b/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c
index ac08129..6c64365 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c
@@ -307,9 +307,6 @@ bool rtl8723ae_rx_query_desc(struct ieee80211_hw *hw,
 	rx_status->freq = hw->conf.channel->center_freq;
 	rx_status->band = hw->conf.channel->band;
 
-	hdr = (struct ieee80211_hdr *)(skb->data + status->rx_drvinfo_size
-		+ status->rx_bufshift);
-
 	if (status->crc)
 		rx_status->flag |= RX_FLAG_FAILED_FCS_CRC;
 
@@ -330,6 +327,13 @@ bool rtl8723ae_rx_query_desc(struct ieee80211_hw *hw,
 	 * to decrypt it
 	 */
 	if (status->decrypted) {
+		hdr = (struct ieee80211_hdr *)(skb->data +
+		       status->rx_drvinfo_size + status->rx_bufshift);
+
+		if (!hdr) {
+			/* during testing, hdr could be NULL here */
+			return false;
+		}
 		if ((ieee80211_is_robust_mgmt_frame(hdr)) &&
 			(ieee80211_has_protected(hdr->frame_control)))
 			rx_status->flag &= ~RX_FLAG_DECRYPTED;
diff --git a/drivers/net/wireless/rtlwifi/wifi.h b/drivers/net/wireless/rtlwifi/wifi.h
index 9ec9c59..a57b876 100644
--- a/drivers/net/wireless/rtlwifi/wifi.h
+++ b/drivers/net/wireless/rtlwifi/wifi.h
@@ -1221,10 +1221,10 @@ struct rtl_hal {
 	bool set_fwcmd_inprogress;
 	u8 current_fwcmd_io;
 
+	struct p2p_ps_offload_t p2p_ps_offload;
 	bool fw_clk_change_in_progress;
 	bool allow_sw_to_change_hwclc;
 	u8 fw_ps_state;
-	struct p2p_ps_offload_t p2p_ps_offload;
 	/**/
 	bool driver_going2unload;
 
-- 
1.8.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
