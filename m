From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [RFC/RFT 06/27] rtlwifi: rtl8192se: Update driver to match vendor driver of 2013.02.07
Date: Mon, 25 Feb 2013 18:13:18 -0600
Message-ID: <1361837619-2985-7-git-send-email-Larry.Finger@lwfinger.net>
References: <1361837619-2985-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, jcheung@suse.com, machen@suse.com,
	mmarek@suse.cz
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f54.google.com ([209.85.219.54]:58931 "EHLO
	mail-oa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759692Ab3BZAOL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2013 19:14:11 -0500
In-Reply-To: <1361837619-2985-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: jcheung@suse.com
Cc: machen@suse.com
Cc: mmarek@suse.cz
---
 drivers/net/wireless/rtlwifi/rtl8192se/def.h |   7 -
 drivers/net/wireless/rtlwifi/rtl8192se/dm.c  |  35 +++-
 drivers/net/wireless/rtlwifi/rtl8192se/hw.c  | 124 +++++++----
 drivers/net/wireless/rtlwifi/rtl8192se/hw.h  |   3 +-
 drivers/net/wireless/rtlwifi/rtl8192se/phy.c |  61 ++++--
 drivers/net/wireless/rtlwifi/rtl8192se/phy.h |   1 +
 drivers/net/wireless/rtlwifi/rtl8192se/sw.c  |   1 +
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c | 296 +++------------------------
 8 files changed, 181 insertions(+), 347 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/def.h b/drivers/net/wireless/rtlwifi/rtl8192se/def.h
index 2d255e0..83c9867 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/def.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/def.h
@@ -36,9 +36,6 @@
 #define SHORT_SLOT_TIME				9
 #define NON_SHORT_SLOT_TIME			20
 
-/* Rx smooth factor */
-#define	RX_SMOOTH_FACTOR			20
-
 /* Queue Select Value in TxDesc */
 #define QSLT_BK					0x2
 #define QSLT_BE					0x0
@@ -49,10 +46,6 @@
 #define QSLT_MGNT				0x12
 #define QSLT_CMD				0x13
 
-#define	PHY_RSSI_SLID_WIN_MAX			100
-#define	PHY_LINKQUALITY_SLID_WIN_MAX		20
-#define	PHY_BEACON_RSSI_SLID_WIN_MAX		10
-
 /* Tx Desc */
 #define TX_DESC_SIZE_RTL8192S			(16 * 4)
 #define TX_CMDDESC_SIZE_RTL8192S		(16 * 4)
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/dm.c b/drivers/net/wireless/rtlwifi/rtl8192se/dm.c
index e551fe5..e2a0faa 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/dm.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/dm.c
@@ -163,6 +163,7 @@ static void _rtl92s_dm_txpowertracking_callback_thermalmeter(
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
 	u8 thermalvalue = 0;
+	u32 fw_cmd = 0;
 
 	rtlpriv->dm.txpower_trackinginit = true;
 
@@ -175,7 +176,19 @@ static void _rtl92s_dm_txpowertracking_callback_thermalmeter(
 
 	if (thermalvalue) {
 		rtlpriv->dm.thermalvalue = thermalvalue;
-		rtl92s_phy_set_fw_cmd(hw, FW_CMD_TXPWR_TRACK_THERMAL);
+		if (hal_get_firmwareversion(rtlpriv) >= 0x35) {
+			rtl92s_phy_set_fw_cmd(hw, FW_CMD_TXPWR_TRACK_THERMAL);
+		} else {
+			fw_cmd = (FW_TXPWR_TRACK_THERMAL |
+				 (rtlpriv->efuse.thermalmeter[0] << 8) |
+				 (thermalvalue << 16));
+
+			RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+				 "Write to FW Thermal Val = 0x%x\n", fw_cmd);
+
+			rtl_write_dword(rtlpriv, WFM5, fw_cmd);
+			rtl92s_phy_chk_fwcmd_iodone(hw);
+		}
 	}
 
 	rtlpriv->dm.txpowercount = 0;
@@ -217,11 +230,10 @@ static void _rtl92s_dm_refresh_rateadaptive_mask(struct ieee80211_hw *hw)
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	struct rate_adaptive *ra = &(rtlpriv->ra);
-
+	struct ieee80211_sta *sta = NULL;
 	u32 low_rssi_thresh = 0;
 	u32 middle_rssi_thresh = 0;
 	u32 high_rssi_thresh = 0;
-	struct ieee80211_sta *sta = NULL;
 
 	if (is_hal_stop(rtlhal))
 		return;
@@ -229,14 +241,12 @@ static void _rtl92s_dm_refresh_rateadaptive_mask(struct ieee80211_hw *hw)
 	if (!rtlpriv->dm.useramask)
 		return;
 
-	if (!rtlpriv->dm.inform_fw_driverctrldm) {
+	if (hal_get_firmwareversion(rtlpriv) >= 61 &&
+	    !rtlpriv->dm.inform_fw_driverctrldm) {
 		rtl92s_phy_set_fw_cmd(hw, FW_CMD_CTRL_DM_BY_DRIVER);
 		rtlpriv->dm.inform_fw_driverctrldm = true;
 	}
 
-	rcu_read_lock();
-	if (mac->opmode == NL80211_IFTYPE_STATION)
-		sta = get_sta(hw, mac->vif, mac->bssid);
 	if ((mac->link_state == MAC80211_LINKED) &&
 	    (mac->opmode == NL80211_IFTYPE_STATION)) {
 		switch (ra->pre_ratr_state) {
@@ -285,12 +295,16 @@ static void _rtl92s_dm_refresh_rateadaptive_mask(struct ieee80211_hw *hw)
 				 rtlpriv->dm.undec_sm_pwdb, ra->ratr_state,
 				 ra->pre_ratr_state, ra->ratr_state);
 
-			rtlpriv->cfg->ops->update_rate_tbl(hw, sta,
+			rcu_read_lock();
+			sta = rtl_find_sta(hw, mac->bssid);
+			if (sta)
+				rtlpriv->cfg->ops->update_rate_tbl(hw, sta,
 							   ra->ratr_state);
+			rcu_read_unlock();
+
 			ra->pre_ratr_state = ra->ratr_state;
 		}
 	}
-	rcu_read_unlock();
 }
 
 static void _rtl92s_dm_switch_baseband_mrc(struct ieee80211_hw *hw)
@@ -370,7 +384,8 @@ static void _rtl92s_dm_init_rate_adaptive_mask(struct ieee80211_hw *hw)
 	ra->ratr_state = DM_RATR_STA_MAX;
 	ra->pre_ratr_state = DM_RATR_STA_MAX;
 
-	if (rtlpriv->dm.dm_type == DM_TYPE_BYDRIVER)
+	if (rtlpriv->dm.dm_type == DM_TYPE_BYDRIVER &&
+	    hal_get_firmwareversion(rtlpriv) >= 60)
 		rtlpriv->dm.useramask = true;
 	else
 		rtlpriv->dm.useramask = false;
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/hw.c b/drivers/net/wireless/rtlwifi/rtl8192se/hw.c
index 084e777..a4f41b1 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/hw.c
@@ -400,6 +400,39 @@ void rtl92se_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 
 			break;
 		}
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
@@ -438,7 +471,7 @@ void rtl92se_enable_hw_security_config(struct ieee80211_hw *hw)
 
 }
 
-static u8 _rtl92ce_halset_sysclk(struct ieee80211_hw *hw, u8 data)
+static u8 _rtl92se_halset_sysclk(struct ieee80211_hw *hw, u8 data)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	u8 waitcount = 100;
@@ -547,7 +580,7 @@ static void _rtl92se_macconfig_before_fwdownload(struct ieee80211_hw *hw)
 		tmpu1b &= ~(BIT(6) | BIT(7));
 
 		/* Set failed, return to prevent hang. */
-		if (!_rtl92ce_halset_sysclk(hw, tmpu1b))
+		if (!_rtl92se_halset_sysclk(hw, tmpu1b))
 			return;
 	}
 
@@ -650,7 +683,7 @@ static void _rtl92se_macconfig_before_fwdownload(struct ieee80211_hw *hw)
 
 	tmpu1b = rtl_read_byte(rtlpriv, (SYS_CLKR + 1));
 	tmpu1b = ((tmpu1b | BIT(7)) & (~BIT(6)));
-	if (!_rtl92ce_halset_sysclk(hw, tmpu1b))
+	if (!_rtl92se_halset_sysclk(hw, tmpu1b))
 		return; /* Set failed, return to prevent hang. */
 
 	rtl_write_word(rtlpriv, CMDR, 0x07FC);
@@ -967,6 +1000,15 @@ int rtl92se_hw_init(struct ieee80211_hw *hw)
 		return rtstatus;
 	}
 
+	/* because last function modify RCR, so we update
+	 * rcr var here, or TP will unstable for receive_config
+	 * is wrong, RX RCR_ACRC32 will cause TP unstabel & Rx
+	 * RCR_APP_ICV will cause mac80211 unassoc for cisco 1252
+	 */
+	rtlpci->receive_config = rtl_read_dword(rtlpriv, RCR);
+	rtlpci->receive_config &= ~(RCR_ACRC32 | RCR_AICV);
+	rtl_write_dword(rtlpriv, RCR, rtlpci->receive_config);
+
 	/* Make sure BB/RF write OK. We should prevent enter IPS. radio off. */
 	/* We must set flag avoid BB/RF config period later!! */
 	rtl_write_dword(rtlpriv, CMDR, 0x37FC);
@@ -982,25 +1024,6 @@ int rtl92se_hw_init(struct ieee80211_hw *hw)
 
 	rtlphy->rf_mode = RF_OP_BY_SW_3WIRE;
 
-	/* RF Power Save */
-#if 0
-	/* H/W or S/W RF OFF before sleep. */
-	if (rtlpriv->psc.rfoff_reason > RF_CHANGE_BY_PS) {
-		u32 rfoffreason = rtlpriv->psc.rfoff_reason;
-
-		rtlpriv->psc.rfoff_reason = RF_CHANGE_BY_INIT;
-		rtlpriv->psc.rfpwr_state = ERFON;
-		/* FIXME: check spinlocks if this block is uncommented */
-		rtl_ps_set_rf_state(hw, ERFOFF, rfoffreason);
-	} else {
-		/* gpio radio on/off is out of adapter start */
-		if (rtlpriv->psc.hwradiooff == false) {
-			rtlpriv->psc.rfpwr_state = ERFON;
-			rtlpriv->psc.rfoff_reason = 0;
-		}
-	}
-#endif
-
 	/* Before RF-R/W we must execute the IO from Scott's suggestion. */
 	rtl_write_byte(rtlpriv, AFE_XTAL_CTRL + 1, 0xDB);
 	if (rtlhal->version == VERSION_8192S_ACUT)
@@ -1058,7 +1081,22 @@ int rtl92se_hw_init(struct ieee80211_hw *hw)
 
 	/* We enable high power and RA related mechanism after NIC
 	 * initialized. */
-	rtl92s_phy_set_fw_cmd(hw, FW_CMD_RA_INIT);
+	if (hal_get_firmwareversion(rtlpriv) >= 0x35) {
+		/* Fw v.53 and later. */
+		rtl92s_phy_set_fw_cmd(hw, FW_CMD_RA_INIT);
+	} else if (hal_get_firmwareversion(rtlpriv) == 0x34) {
+		/* Fw v.52. */
+		rtl_write_dword(rtlpriv, WFM5, FW_RA_INIT);
+		rtl92s_phy_chk_fwcmd_iodone(hw);
+	} else {
+		/* Compatible earlier FW version. */
+		rtl_write_dword(rtlpriv, WFM5, FW_RA_RESET);
+		rtl92s_phy_chk_fwcmd_iodone(hw);
+		rtl_write_dword(rtlpriv, WFM5, FW_RA_ACTIVE);
+		rtl92s_phy_chk_fwcmd_iodone(hw);
+		rtl_write_dword(rtlpriv, WFM5, FW_RA_REFRESH);
+		rtl92s_phy_chk_fwcmd_iodone(hw);
+	}
 
 	/* Add to prevent ASPM bug. */
 	/* Always enable hst and NIC clock request. */
@@ -1229,7 +1267,6 @@ void rtl92se_disable_interrupt(struct ieee80211_hw *hw)
 	synchronize_irq(rtlpci->pdev->irq);
 }
 
-
 static u8 _rtl92s_set_sysclk(struct ieee80211_hw *hw, u8 data)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
@@ -1999,6 +2036,8 @@ static void rtl92se_update_hal_rate_table(struct ieee80211_hw *hw,
 		ratr_value = sta->supp_rates[1] << 4;
 	else
 		ratr_value = sta->supp_rates[0];
+	if (mac->opmode == NL80211_IFTYPE_ADHOC)
+		ratr_value = 0xfff;
 	ratr_value |= (sta->ht_cap.mcs.rx_mask[1] << 20 |
 			sta->ht_cap.mcs.rx_mask[0] << 12);
 	switch (wirelessmode) {
@@ -2112,6 +2151,8 @@ static void rtl92se_update_hal_rate_mask(struct ieee80211_hw *hw,
 		ratr_bitmap = sta->supp_rates[1] << 4;
 	else
 		ratr_bitmap = sta->supp_rates[0];
+	if (mac->opmode == NL80211_IFTYPE_ADHOC)
+		ratr_bitmap = 0xfff;
 	ratr_bitmap |= (sta->ht_cap.mcs.rx_mask[1] << 20 |
 			sta->ht_cap.mcs.rx_mask[0] << 12);
 	switch (wirelessmode) {
@@ -2200,6 +2241,7 @@ static void rtl92se_update_hal_rate_mask(struct ieee80211_hw *hw,
 			ratr_bitmap &= 0x0f8ff0ff;
 		break;
 	}
+	sta_entry->ratr_index = ratr_index;
 
 	if (rtlpriv->rtlhal.version >= VERSION_8192S_BCUT)
 		ratr_bitmap &= 0x0FFFFFFF;
@@ -2438,23 +2480,9 @@ void rtl92se_set_key(struct ieee80211_hw *hw, u32 key_index, u8 *p_macaddr,
 				rtl_cam_del_entry(hw, p_macaddr);
 			rtl_cam_delete_one_entry(hw, p_macaddr, entry_id);
 		} else {
-			RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD,
-				 "The insert KEY length is %d\n",
-				 rtlpriv->sec.key_len[PAIRWISE_KEYIDX]);
-			RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD,
-				 "The insert KEY is %x %x\n",
-				 rtlpriv->sec.key_buf[0][0],
-				 rtlpriv->sec.key_buf[0][1]);
-
 			RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
 				 "add one entry\n");
 			if (is_pairwise) {
-				RT_PRINT_DATA(rtlpriv, COMP_SEC, DBG_LOUD,
-					      "Pairwise Key content",
-					      rtlpriv->sec.pairwise_key,
-					      rtlpriv->sec.
-					      key_len[PAIRWISE_KEYIDX]);
-
 				RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
 					 "set Pairwise key\n");
 
@@ -2502,3 +2530,23 @@ void rtl92se_resume(struct ieee80211_hw *hw)
 		pci_write_config_dword(rtlpci->pdev, 0x40,
 			val & 0xffff00ff);
 }
+
+/* Turn on AAP (RCR:bit 0) for promicuous mode. */
+void rtl92se_allow_all_destaddr(struct ieee80211_hw *hw,
+				bool allow_all_da, bool write_into_reg)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
+
+	if (allow_all_da) /* Set BIT0 */
+		rtlpci->receive_config |= RCR_AAP;
+	else /* Clear BIT0 */
+		rtlpci->receive_config &= ~RCR_AAP;
+
+	if (write_into_reg)
+		rtl_write_dword(rtlpriv, RCR, rtlpci->receive_config);
+
+	RT_TRACE(rtlpriv, COMP_TURBO | COMP_INIT, DBG_LOUD,
+		 "receive_config=0x%08X, write_into_reg=%d\n",
+		 rtlpci->receive_config, write_into_reg);
+}
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/hw.h b/drivers/net/wireless/rtlwifi/rtl8192se/hw.h
index a8e068c..da48aa8 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/hw.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/hw.h
@@ -74,6 +74,7 @@ void rtl92se_set_key(struct ieee80211_hw *hw,
 		     u8 enc_algo, bool is_wepkey, bool clear_all);
 void rtl92se_suspend(struct ieee80211_hw *hw);
 void rtl92se_resume(struct ieee80211_hw *hw);
+void rtl92se_allow_all_destaddr(struct ieee80211_hw *hw,
+				bool allow_all_da, bool write_into_reg);
 
 #endif
-
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/phy.c b/drivers/net/wireless/rtlwifi/rtl8192se/phy.c
index 6740497..9c092e6 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/phy.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/phy.c
@@ -1307,6 +1307,8 @@ static void _rtl92s_phy_set_fwcmd_io(struct ieee80211_hw *hw)
 	if (is_hal_stop(rtlhal))
 		return;
 
+	if (hal_get_firmwareversion(rtlpriv) < 0x34)
+		goto skip;
 	/* We re-map RA related CMD IO to combinational ones */
 	/* if FW version is v.52 or later. */
 	switch (rtlhal->current_fwcmd_io) {
@@ -1320,6 +1322,7 @@ static void _rtl92s_phy_set_fwcmd_io(struct ieee80211_hw *hw)
 		break;
 	}
 
+skip:
 	switch (rtlhal->current_fwcmd_io) {
 	case FW_CMD_RA_RESET:
 		RT_TRACE(rtlpriv, COMP_CMD, DBG_DMESG, "FW_CMD_RA_RESET\n");
@@ -1440,7 +1443,7 @@ bool rtl92s_phy_set_fw_cmd(struct ieee80211_hw *hw, enum fwcmd_iotype fw_cmdio)
 	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
 	u32	fw_param = FW_CMD_IO_PARA_QUERY(rtlpriv);
 	u16	fw_cmdmap = FW_CMD_IO_QUERY(rtlpriv);
-	bool bPostProcessing = false;
+	bool postprocessing = false;
 
 	RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
 		 "Set FW Cmd(%#x), set_fwcmd_inprogress(%d)\n",
@@ -1449,15 +1452,24 @@ bool rtl92s_phy_set_fw_cmd(struct ieee80211_hw *hw, enum fwcmd_iotype fw_cmdio)
 	do {
 		/* We re-map to combined FW CMD ones if firmware version */
 		/* is v.53 or later. */
-		switch (fw_cmdio) {
-		case FW_CMD_RA_REFRESH_N:
-			fw_cmdio = FW_CMD_RA_REFRESH_N_COMB;
-			break;
-		case FW_CMD_RA_REFRESH_BG:
-			fw_cmdio = FW_CMD_RA_REFRESH_BG_COMB;
-			break;
-		default:
-			break;
+		if (hal_get_firmwareversion(rtlpriv) >= 0x35) {
+			switch (fw_cmdio) {
+			case FW_CMD_RA_REFRESH_N:
+				fw_cmdio = FW_CMD_RA_REFRESH_N_COMB;
+				break;
+			case FW_CMD_RA_REFRESH_BG:
+				fw_cmdio = FW_CMD_RA_REFRESH_BG_COMB;
+				break;
+			default:
+				break;
+			}
+		} else {
+			if ((fw_cmdio == FW_CMD_IQK_ENABLE) ||
+			    (fw_cmdio == FW_CMD_RA_REFRESH_N) ||
+			    (fw_cmdio == FW_CMD_RA_REFRESH_BG)) {
+				postprocessing = true;
+				break;
+			}
 		}
 
 		/* If firmware version is v.62 or later,
@@ -1588,19 +1600,19 @@ bool rtl92s_phy_set_fw_cmd(struct ieee80211_hw *hw, enum fwcmd_iotype fw_cmdio)
 				fw_cmdmap &= ~FW_DIG_ENABLE_CTL;
 
 			FW_CMD_IO_SET(rtlpriv, fw_cmdmap);
-			bPostProcessing = true;
+			postprocessing = true;
 			break;
 		case FW_CMD_PAUSE_DM_BY_SCAN:
 			fw_cmdmap &= ~(FW_DIG_ENABLE_CTL |
 				       FW_HIGH_PWR_ENABLE_CTL |
 				       FW_SS_CTL);
 			FW_CMD_IO_SET(rtlpriv, fw_cmdmap);
-			bPostProcessing = true;
+			postprocessing = true;
 			break;
 		case FW_CMD_HIGH_PWR_DISABLE:
 			fw_cmdmap &= ~FW_HIGH_PWR_ENABLE_CTL;
 			FW_CMD_IO_SET(rtlpriv, fw_cmdmap);
-			bPostProcessing = true;
+			postprocessing = true;
 			break;
 		case FW_CMD_HIGH_PWR_ENABLE:
 			if (!(rtlpriv->dm.dm_flag & HAL_DM_HIPWR_DISABLE) &&
@@ -1608,7 +1620,7 @@ bool rtl92s_phy_set_fw_cmd(struct ieee80211_hw *hw, enum fwcmd_iotype fw_cmdio)
 				fw_cmdmap |= (FW_HIGH_PWR_ENABLE_CTL |
 					      FW_SS_CTL);
 				FW_CMD_IO_SET(rtlpriv, fw_cmdmap);
-				bPostProcessing = true;
+				postprocessing = true;
 			}
 			break;
 		case FW_CMD_DIG_MODE_FA:
@@ -1629,14 +1641,15 @@ bool rtl92s_phy_set_fw_cmd(struct ieee80211_hw *hw, enum fwcmd_iotype fw_cmdio)
 		default:
 			/* Pass to original FW CMD processing callback
 			 * routine. */
-			bPostProcessing = true;
+			postprocessing = true;
 			break;
 		}
 	} while (false);
 
 	/* We shall post processing these FW CMD if
-	 * variable bPostProcessing is set. */
-	if (bPostProcessing && !rtlhal->set_fwcmd_inprogress) {
+	 * variable postprocessing is set.
+	 */
+	if (postprocessing && !rtlhal->set_fwcmd_inprogress) {
 		rtlhal->set_fwcmd_inprogress = true;
 		/* Update current FW Cmd for callback use. */
 		rtlhal->current_fwcmd_io = fw_cmdio;
@@ -1697,8 +1710,18 @@ void rtl92s_phy_switch_ephy_parameter(struct ieee80211_hw *hw)
 
 }
 
-void rtl92s_phy_set_beacon_hwreg(struct ieee80211_hw *hw, u16 BeaconInterval)
+void rtl92s_phy_set_beacon_hwreg(struct ieee80211_hw *hw, u16 beaconinterval)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	rtl_write_dword(rtlpriv, WFM5, 0xF1000000 | (BeaconInterval << 8));
+	u32 new_bcn_num = 0;
+
+	if (hal_get_firmwareversion(rtlpriv) >= 0x33) {
+		/* Fw v.51 and later. */
+		rtl_write_dword(rtlpriv, WFM5, 0xF1000000 |
+				(beaconinterval << 8));
+	} else {
+		new_bcn_num = beaconinterval * 32 - 64;
+		rtl_write_dword(rtlpriv, WFM3 + 4, new_bcn_num);
+		rtl_write_dword(rtlpriv, WFM3, 0xB026007C);
+	}
 }
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/phy.h b/drivers/net/wireless/rtlwifi/rtl8192se/phy.h
index ac03877..8acf476 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/phy.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/phy.h
@@ -39,6 +39,7 @@
 #define MAX_POSTCMD_CNT			16
 
 #define RF90_PATH_MAX			4
+#define RF6052_MAX_PATH			2
 
 enum version_8192s {
 	VERSION_8192S_ACUT,
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/sw.c b/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
index cecc377..2c115b0 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
@@ -290,6 +290,7 @@ static struct rtl_hal_ops rtl8192se_hal_ops = {
 	.enable_hw_sec = rtl92se_enable_hw_security_config,
 	.set_key = rtl92se_set_key,
 	.init_sw_leds = rtl92se_init_sw_leds,
+	.allow_all_destaddr = rtl92se_allow_all_destaddr,
 	.get_bbreg = rtl92s_phy_query_bb_reg,
 	.set_bbreg = rtl92s_phy_set_bb_reg,
 	.get_rfreg = rtl92s_phy_query_rf_reg,
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/trx.c b/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
index 7b0a2e7..960bc28 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
@@ -30,6 +30,7 @@
 #include "../wifi.h"
 #include "../pci.h"
 #include "../base.h"
+#include "../stats.h"
 #include "reg.h"
 #include "def.h"
 #include "phy.h"
@@ -43,7 +44,7 @@ static u8 _rtl92se_map_hwqueue_to_fwqueue(struct sk_buff *skb,	u8 skb_queue)
 
 	if (unlikely(ieee80211_is_beacon(fc)))
 		return QSLT_BEACON;
-	if (ieee80211_is_mgmt(fc))
+	if (ieee80211_is_mgmt(fc) || ieee80211_is_ctl(fc))
 		return QSLT_MGNT;
 	if (ieee80211_is_nullfunc(fc))
 		return QSLT_HIGH;
@@ -51,65 +52,6 @@ static u8 _rtl92se_map_hwqueue_to_fwqueue(struct sk_buff *skb,	u8 skb_queue)
 	return skb->priority;
 }
 
-static u8 _rtl92s_query_rxpwrpercentage(char antpower)
-{
-	if ((antpower <= -100) || (antpower >= 20))
-		return 0;
-	else if (antpower >= 0)
-		return 100;
-	else
-		return 100 + antpower;
-}
-
-static u8 _rtl92s_evm_db_to_percentage(char value)
-{
-	char ret_val;
-	ret_val = value;
-
-	if (ret_val >= 0)
-		ret_val = 0;
-
-	if (ret_val <= -33)
-		ret_val = -33;
-
-	ret_val = 0 - ret_val;
-	ret_val *= 3;
-
-	if (ret_val == 99)
-		ret_val = 100;
-
-	return ret_val;
-}
-
-static long _rtl92se_translate_todbm(struct ieee80211_hw *hw,
-				     u8 signal_strength_index)
-{
-	long signal_power;
-
-	signal_power = (long)((signal_strength_index + 1) >> 1);
-	signal_power -= 95;
-	return signal_power;
-}
-
-static long _rtl92se_signal_scale_mapping(struct ieee80211_hw *hw,
-		long currsig)
-{
-	long retsig = 0;
-
-	/* Step 1. Scale mapping. */
-	if (currsig > 47)
-		retsig = 100;
-	else if (currsig > 14 && currsig <= 47)
-		retsig = 100 - ((47 - currsig) * 3) / 2;
-	else if (currsig > 2 && currsig <= 14)
-		retsig = 48 - ((14 - currsig) * 15) / 7;
-	else if (currsig >= 0)
-		retsig = currsig * 9 + 1;
-
-	return retsig;
-}
-
-
 static void _rtl92se_query_rxphystatus(struct ieee80211_hw *hw,
 				       struct rtl_stats *pstats, u8 *pdesc,
 				       struct rx_fwinfo *p_drvinfo,
@@ -119,11 +61,11 @@ static void _rtl92se_query_rxphystatus(struct ieee80211_hw *hw,
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct phy_sts_cck_8192s_t *cck_buf;
+	struct rtl_ps_ctl *ppsc = rtl_psc(rtlpriv);
 	s8 rx_pwr_all = 0, rx_pwr[4];
 	u8 rf_rx_num = 0, evm, pwdb_all;
 	u8 i, max_spatial_stream;
 	u32 rssi, total_rssi = 0;
-	bool in_powersavemode = false;
 	bool is_cck = pstats->is_cck;
 
 	pstats->packet_matchbssid = packet_match_bssid;
@@ -136,7 +78,7 @@ static void _rtl92se_query_rxphystatus(struct ieee80211_hw *hw,
 		u8 report, cck_highpwr;
 		cck_buf = (struct phy_sts_cck_8192s_t *)p_drvinfo;
 
-		if (!in_powersavemode)
+		if (ppsc->rfpwr_state == ERFON)
 			cck_highpwr = (u8) rtl_get_bbreg(hw,
 						RFPGA0_XA_HSSIPARAMETER2,
 						0x200);
@@ -181,7 +123,7 @@ static void _rtl92se_query_rxphystatus(struct ieee80211_hw *hw,
 			}
 		}
 
-		pwdb_all = _rtl92s_query_rxpwrpercentage(rx_pwr_all);
+		pwdb_all = rtl_query_rxpwrpercentage(rx_pwr_all);
 
 		/* CCK gain is smaller than OFDM/MCS gain,  */
 		/* so we add gain diff by experiences, the val is 6 */
@@ -222,13 +164,13 @@ static void _rtl92se_query_rxphystatus(struct ieee80211_hw *hw,
 	} else {
 		rtlpriv->dm.rfpath_rxenable[0] =
 		    rtlpriv->dm.rfpath_rxenable[1] = true;
-		for (i = RF90_PATH_A; i < RF90_PATH_MAX; i++) {
+		for (i = RF90_PATH_A; i < RF6052_MAX_PATH; i++) {
 			if (rtlpriv->dm.rfpath_rxenable[i])
 				rf_rx_num++;
 
 			rx_pwr[i] = ((p_drvinfo->gain_trsw[i] &
 				    0x3f) * 2) - 110;
-			rssi = _rtl92s_query_rxpwrpercentage(rx_pwr[i]);
+			rssi = rtl_query_rxpwrpercentage(rx_pwr[i]);
 			total_rssi += rssi;
 			rtlpriv->stats.rx_snr_db[i] =
 					 (long)(p_drvinfo->rxsnr[i] / 2);
@@ -238,7 +180,7 @@ static void _rtl92se_query_rxphystatus(struct ieee80211_hw *hw,
 		}
 
 		rx_pwr_all = ((p_drvinfo->pwdb_all >> 1) & 0x7f) - 110;
-		pwdb_all = _rtl92s_query_rxpwrpercentage(rx_pwr_all);
+		pwdb_all = rtl_query_rxpwrpercentage(rx_pwr_all);
 		pstats->rx_pwdb_all = pwdb_all;
 		pstats->rxpower = rx_pwr_all;
 		pstats->recvsignalpower = rx_pwr_all;
@@ -250,7 +192,7 @@ static void _rtl92se_query_rxphystatus(struct ieee80211_hw *hw,
 			max_spatial_stream = 1;
 
 		for (i = 0; i < max_spatial_stream; i++) {
-			evm = _rtl92s_evm_db_to_percentage(p_drvinfo->rxevm[i]);
+			evm = rtl_evm_db_to_percentage(p_drvinfo->rxevm[i]);
 
 			if (packet_match_bssid) {
 				if (i == 0)
@@ -262,212 +204,13 @@ static void _rtl92se_query_rxphystatus(struct ieee80211_hw *hw,
 	}
 
 	if (is_cck)
-		pstats->signalstrength = (u8)(_rtl92se_signal_scale_mapping(hw,
+		pstats->signalstrength = (u8)(rtl_signal_scale_mapping(hw,
 					 pwdb_all));
 	else if (rf_rx_num != 0)
-		pstats->signalstrength = (u8) (_rtl92se_signal_scale_mapping(hw,
+		pstats->signalstrength = (u8) (rtl_signal_scale_mapping(hw,
 				total_rssi /= rf_rx_num));
 }
 
-static void _rtl92se_process_ui_rssi(struct ieee80211_hw *hw,
-				     struct rtl_stats *pstats)
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
-			rtlpriv->stats.ui_rssi.total_num =
-					 PHY_RSSI_SLID_WIN_MAX;
-			last_rssi = rtlpriv->stats.ui_rssi.elements[
-				rtlpriv->stats.ui_rssi.index];
-			rtlpriv->stats.ui_rssi.total_val -= last_rssi;
-		}
-
-		rtlpriv->stats.ui_rssi.total_val += pstats->signalstrength;
-		rtlpriv->stats.ui_rssi.elements[rtlpriv->stats.ui_rssi.index++]
-			 = pstats->signalstrength;
-
-		if (rtlpriv->stats.ui_rssi.index >= PHY_RSSI_SLID_WIN_MAX)
-			rtlpriv->stats.ui_rssi.index = 0;
-
-		tmpval = rtlpriv->stats.ui_rssi.total_val /
-			rtlpriv->stats.ui_rssi.total_num;
-		rtlpriv->stats.signal_strength = _rtl92se_translate_todbm(hw,
-								(u8) tmpval);
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
-				    ((rtlpriv->stats.rx_rssi_percentage[rfpath]
-				    * (RX_SMOOTH_FACTOR - 1)) +
-				    (pstats->rx_mimo_signalstrength[rfpath])) /
-				    (RX_SMOOTH_FACTOR);
-
-				rtlpriv->stats.rx_rssi_percentage[rfpath] =
-				    rtlpriv->stats.rx_rssi_percentage[rfpath]
-				    + 1;
-			} else {
-				rtlpriv->stats.rx_rssi_percentage[rfpath] =
-				    ((rtlpriv->stats.rx_rssi_percentage[rfpath]
-				    * (RX_SMOOTH_FACTOR - 1)) +
-				    (pstats->rx_mimo_signalstrength[rfpath])) /
-				    (RX_SMOOTH_FACTOR);
-			}
-
-		}
-	}
-}
-
-static void _rtl92se_update_rxsignalstatistics(struct ieee80211_hw *hw,
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
-	else if (pstats->recvsignalpower < rtlpriv->stats.recv_signal_power)
-		weighting = (-5);
-
-	rtlpriv->stats.recv_signal_power = (rtlpriv->stats.recv_signal_power * 5
-					   + pstats->recvsignalpower +
-					   weighting) / 6;
-}
-
-static void _rtl92se_process_pwdb(struct ieee80211_hw *hw,
-				  struct rtl_stats *pstats)
-{
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
-	long undec_sm_pwdb = 0;
-
-	if (mac->opmode == NL80211_IFTYPE_ADHOC) {
-		return;
-	} else {
-		undec_sm_pwdb =
-		    rtlpriv->dm.undec_sm_pwdb;
-	}
-
-	if (pstats->packet_toself || pstats->packet_beacon) {
-		if (undec_sm_pwdb < 0)
-			undec_sm_pwdb = pstats->rx_pwdb_all;
-
-		if (pstats->rx_pwdb_all > (u32) undec_sm_pwdb) {
-			undec_sm_pwdb =
-			    (((undec_sm_pwdb) *
-			    (RX_SMOOTH_FACTOR - 1)) +
-			    (pstats->rx_pwdb_all)) / (RX_SMOOTH_FACTOR);
-
-			undec_sm_pwdb = undec_sm_pwdb + 1;
-		} else {
-			undec_sm_pwdb = (((undec_sm_pwdb) *
-			      (RX_SMOOTH_FACTOR - 1)) + (pstats->rx_pwdb_all)) /
-			      (RX_SMOOTH_FACTOR);
-		}
-
-		rtlpriv->dm.undec_sm_pwdb = undec_sm_pwdb;
-		_rtl92se_update_rxsignalstatistics(hw, pstats);
-	}
-}
-
-static void rtl_92s_process_streams(struct ieee80211_hw *hw,
-				    struct rtl_stats *pstats)
-{
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	u32 stream;
-
-	for (stream = 0; stream < 2; stream++) {
-		if (pstats->rx_mimo_sig_qual[stream] != -1) {
-			if (rtlpriv->stats.rx_evm_percentage[stream] == 0) {
-				rtlpriv->stats.rx_evm_percentage[stream] =
-				    pstats->rx_mimo_sig_qual[stream];
-			}
-
-			rtlpriv->stats.rx_evm_percentage[stream] =
-			    ((rtlpriv->stats.rx_evm_percentage[stream] *
-					(RX_SMOOTH_FACTOR - 1)) +
-			     (pstats->rx_mimo_sig_qual[stream] *
-					1)) / (RX_SMOOTH_FACTOR);
-		}
-	}
-}
-
-static void _rtl92se_process_ui_link_quality(struct ieee80211_hw *hw,
-					     struct rtl_stats *pstats)
-{
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	u32 last_evm = 0, tmpval;
-
-	if (pstats->signalquality != 0) {
-		if (pstats->packet_toself || pstats->packet_beacon) {
-
-			if (rtlpriv->stats.ui_link_quality.total_num++ >=
-			    PHY_LINKQUALITY_SLID_WIN_MAX) {
-				rtlpriv->stats.ui_link_quality.total_num =
-				    PHY_LINKQUALITY_SLID_WIN_MAX;
-				last_evm =
-				    rtlpriv->stats.ui_link_quality.elements[
-				    rtlpriv->stats.ui_link_quality.index];
-				rtlpriv->stats.ui_link_quality.total_val -=
-				    last_evm;
-			}
-
-			rtlpriv->stats.ui_link_quality.total_val +=
-			    pstats->signalquality;
-			rtlpriv->stats.ui_link_quality.elements[
-				rtlpriv->stats.ui_link_quality.index++] =
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
-			rtl_92s_process_streams(hw, pstats);
-
-		}
-	}
-}
-
-static void _rtl92se_process_phyinfo(struct ieee80211_hw *hw,
-				     u8 *buffer,
-				     struct rtl_stats *pcurrent_stats)
-{
-
-	if (!pcurrent_stats->packet_matchbssid &&
-	    !pcurrent_stats->packet_beacon)
-		return;
-
-	_rtl92se_process_ui_rssi(hw, pcurrent_stats);
-	_rtl92se_process_pwdb(hw, pcurrent_stats);
-	_rtl92se_process_ui_link_quality(hw, pcurrent_stats);
-}
-
 static void _rtl92se_translate_rx_signal_stuff(struct ieee80211_hw *hw,
 		struct sk_buff *skb, struct rtl_stats *pstats,
 		u8 *pdesc, struct rx_fwinfo *p_drvinfo)
@@ -505,7 +248,7 @@ static void _rtl92se_translate_rx_signal_stuff(struct ieee80211_hw *hw,
 
 	_rtl92se_query_rxphystatus(hw, pstats, pdesc, p_drvinfo,
 			packet_matchbssid, packet_toself, packet_beacon);
-	_rtl92se_process_phyinfo(hw, tmp_buf, pstats);
+	rtl_process_phyinfo(hw, tmp_buf, pstats);
 }
 
 bool rtl92se_rx_query_desc(struct ieee80211_hw *hw, struct rtl_stats *stats,
@@ -541,9 +284,6 @@ bool rtl92se_rx_query_desc(struct ieee80211_hw *hw, struct rtl_stats *stats,
 	rx_status->freq = hw->conf.channel->center_freq;
 	rx_status->band = hw->conf.channel->band;
 
-	hdr = (struct ieee80211_hdr *)(skb->data + stats->rx_drvinfo_size
-	      + stats->rx_bufshift);
-
 	if (stats->crc)
 		rx_status->flag |= RX_FLAG_FAILED_FCS_CRC;
 
@@ -563,6 +303,13 @@ bool rtl92se_rx_query_desc(struct ieee80211_hw *hw, struct rtl_stats *stats,
 	 * for IEEE80211w frame, and mac80211 sw will help
 	 * to decrypt it */
 	if (stats->decrypted) {
+		hdr = (struct ieee80211_hdr *)(skb->data +
+		       stats->rx_drvinfo_size + stats->rx_bufshift);
+
+		if (!hdr) {
+			/* during testing, hdr was NULL here */
+			return false;
+		}
 		if ((ieee80211_is_robust_mgmt_frame(hdr)) &&
 			(ieee80211_has_protected(hdr->frame_control)))
 			rx_status->flag &= ~RX_FLAG_DECRYPTED;
@@ -630,6 +377,11 @@ void rtl92se_tx_fill_desc(struct ieee80211_hw *hw,
 
 	CLEAR_PCI_TX_DESC_CONTENT(pdesc, TX_DESC_SIZE_RTL8192S);
 
+	if (ieee80211_is_nullfunc(fc) || ieee80211_is_ctl(fc)) {
+		firstseg = true;
+		lastseg = true;
+	}
+
 	if (firstseg) {
 		if (rtlpriv->dm.useramask) {
 			/* set txdesc macId */
-- 
1.8.1.4
