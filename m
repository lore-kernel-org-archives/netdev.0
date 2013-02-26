From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [RFC/RFT 03/27] rtlwifi: Modify files for 2013.02.07 vendor version - part 3
Date: Mon, 25 Feb 2013 18:13:15 -0600
Message-ID: <1361837619-2985-4-git-send-email-Larry.Finger@lwfinger.net>
References: <1361837619-2985-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, jcheung@suse.com, machen@suse.com,
	mmarek@suse.cz
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f52.google.com ([209.85.219.52]:65368 "EHLO
	mail-oa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759155Ab3BZAOG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2013 19:14:06 -0500
In-Reply-To: <1361837619-2985-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates files ps.{c,h} for the changes in the newest vendor
driver.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: jcheung@suse.com
Cc: machen@suse.com
Cc: mmarek@suse.cz
---
 drivers/net/wireless/rtlwifi/ps.c | 330 +++++++++++++++++++++++++++++++++++---
 drivers/net/wireless/rtlwifi/ps.h |   2 +
 2 files changed, 306 insertions(+), 26 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/ps.c b/drivers/net/wireless/rtlwifi/ps.c
index 13ad33e..101b569 100644
--- a/drivers/net/wireless/rtlwifi/ps.c
+++ b/drivers/net/wireless/rtlwifi/ps.c
@@ -189,6 +189,9 @@ void rtl_ips_nic_off_wq_callback(void *data)
 	if (rtlpriv->sec.being_setkey)
 		return;
 
+	if (rtlpriv->cfg->ops->bt_coex_off_before_lps)
+		rtlpriv->cfg->ops->bt_coex_off_before_lps(hw);
+
 	if (ppsc->inactiveps) {
 		rtstate = ppsc->rfpwr_state;
 
@@ -231,6 +234,9 @@ void rtl_ips_nic_off(struct ieee80211_hw *hw)
 			   &rtlpriv->works.ips_nic_off_wq, MSECS(100));
 }
 
+/* NOTICE: any opmode should exc nic_on, or disable without
+ * nic_on may something wrong, like adhoc TP
+ */
 void rtl_ips_nic_on(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
@@ -299,7 +305,7 @@ static void rtl_lps_set_psmode(struct ieee80211_hw *hw, u8 rt_psmode)
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
-	u8 rpwm_val, fw_pwrmode;
+	bool enter_fwlps;
 
 	if (mac->opmode == NL80211_IFTYPE_ADHOC)
 		return;
@@ -324,43 +330,31 @@ static void rtl_lps_set_psmode(struct ieee80211_hw *hw, u8 rt_psmode)
 	 */
 
 	if ((ppsc->fwctrl_lps) && ppsc->report_linked) {
-		bool fw_current_inps;
 		if (ppsc->dot11_psmode == EACTIVE) {
 			RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
 				 "FW LPS leave ps_mode:%x\n",
 				 FW_PS_ACTIVE_MODE);
-
-			rpwm_val = 0x0C;	/* RF on */
-			fw_pwrmode = FW_PS_ACTIVE_MODE;
-			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_SET_RPWM,
-					&rpwm_val);
-			rtlpriv->cfg->ops->set_hw_reg(hw,
-					HW_VAR_H2C_FW_PWRMODE,
-					&fw_pwrmode);
-			fw_current_inps = false;
-
-			rtlpriv->cfg->ops->set_hw_reg(hw,
-					HW_VAR_FW_PSMODE_STATUS,
-					(u8 *) (&fw_current_inps));
+				enter_fwlps = false;
+				ppsc->pwr_mode = FW_PS_ACTIVE_MODE;
+				ppsc->smart_ps = 0;
+				rtlpriv->cfg->ops->set_hw_reg(hw,
+							HW_VAR_FW_LPS_ACTION,
+							(u8 *)(&enter_fwlps));
+				if (ppsc->p2p_ps_info.opp_ps)
+					rtl_p2p_ps_cmd(hw, P2P_PS_ENABLE);
 
 		} else {
 			if (rtl_get_fwlps_doze(hw)) {
 				RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
 					 "FW LPS enter ps_mode:%x\n",
 					 ppsc->fwctrl_psmode);
-
-				rpwm_val = 0x02;	/* RF off */
-				fw_current_inps = true;
+				enter_fwlps = true;
+				ppsc->pwr_mode = ppsc->fwctrl_psmode;
+				ppsc->smart_ps = 2;
 				rtlpriv->cfg->ops->set_hw_reg(hw,
-						HW_VAR_FW_PSMODE_STATUS,
-						(u8 *) (&fw_current_inps));
-				rtlpriv->cfg->ops->set_hw_reg(hw,
-						HW_VAR_H2C_FW_PWRMODE,
-						&ppsc->fwctrl_psmode);
+							HW_VAR_FW_LPS_ACTION,
+							(u8 *)(&enter_fwlps));
 
-				rtlpriv->cfg->ops->set_hw_reg(hw,
-						HW_VAR_SET_RPWM,
-						&rpwm_val);
 			} else {
 				/* Reset the power save related parameters. */
 				ppsc->dot11_psmode = EACTIVE;
@@ -642,3 +636,287 @@ void rtl_swlps_wq_callback(void *data)
 		rtlpriv->psc.state = ps;
 	}
 }
+
+void rtl_p2p_noa_ie(struct ieee80211_hw *hw, void *data, unsigned int len)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct ieee80211_mgmt *mgmt = (void *)data;
+	struct rtl_p2p_ps_info *p2pinfo = &(rtlpriv->psc.p2p_ps_info);
+	u8 *pos, *end, *ie;
+	u16 noa_len;
+	static u8 p2p_oui_ie_type[4] = {0x50, 0x6f, 0x9a, 0x09};
+	u8 noa_num, index, i, noa_index = 0;
+	bool find_p2p_ie = false , find_p2p_ps_ie = false;
+	pos = (u8 *)mgmt->u.beacon.variable;
+	end = data + len;
+	ie = NULL;
+
+	while (pos + 1 < end) {
+		if (pos + 2 + pos[1] > end)
+			return;
+
+		if (pos[0] == 221 && pos[1] > 4) {
+			if (memcmp(&pos[2], p2p_oui_ie_type, 4) == 0) {
+				ie = pos + 2+4;
+				break;
+			}
+		}
+		pos += 2 + pos[1];
+	}
+
+	if (ie == NULL)
+		return;
+	find_p2p_ie = true;
+	/*to find noa ie*/
+	while (ie + 1 < end) {
+		noa_len = READEF2BYTE(&ie[1]);
+		if (ie + 3 + ie[1] > end)
+			return;
+
+		if (ie[0] == 12) {
+			find_p2p_ps_ie = true;
+			if ((noa_len - 2) % 13 != 0) {
+				RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+					 "P2P notice of absence: invalid length.%d\n",
+					 noa_len);
+				return;
+			} else {
+				noa_num = (noa_len - 2) / 13;
+			}
+			noa_index = ie[3];
+			if (rtlpriv->psc.p2p_ps_info.p2p_ps_mode ==
+			    P2P_PS_NONE || noa_index != p2pinfo->noa_index) {
+				RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD,
+					 "update NOA ie.\n");
+				p2pinfo->noa_index = noa_index;
+				p2pinfo->opp_ps = (ie[4] >> 7);
+				p2pinfo->ctwindow = ie[4] & 0x7F;
+				p2pinfo->noa_num = noa_num;
+				index = 5;
+				for (i = 0; i < noa_num; i++) {
+					p2pinfo->noa_count_type[i] =
+						 READEF1BYTE(ie+index);
+					index += 1;
+					p2pinfo->noa_duration[i] =
+						 READEF4BYTE(ie+index);
+					index += 4;
+					p2pinfo->noa_interval[i] =
+						 READEF4BYTE(ie+index);
+					index += 4;
+					p2pinfo->noa_start_time[i] =
+						 READEF4BYTE(ie+index);
+					index += 4;
+				}
+
+				if (p2pinfo->opp_ps == 1) {
+					p2pinfo->p2p_ps_mode = P2P_PS_CTWINDOW;
+					/* Driver should wait LPS entering
+					 * CTWindow
+					 */
+					if (rtlpriv->psc.fw_current_inpsmode)
+						rtl_p2p_ps_cmd(hw,
+							       P2P_PS_ENABLE);
+				} else if (p2pinfo->noa_num > 0) {
+					p2pinfo->p2p_ps_mode = P2P_PS_NOA;
+					rtl_p2p_ps_cmd(hw, P2P_PS_ENABLE);
+				} else if (p2pinfo->p2p_ps_mode > P2P_PS_NONE) {
+					rtl_p2p_ps_cmd(hw, P2P_PS_DISABLE);
+				}
+			}
+		break;
+		}
+		ie += 3 + noa_len;
+	}
+
+	if (find_p2p_ie == true) {
+		if ((p2pinfo->p2p_ps_mode > P2P_PS_NONE) &&
+		    (find_p2p_ps_ie == false))
+			rtl_p2p_ps_cmd(hw, P2P_PS_DISABLE);
+	}
+}
+
+void rtl_p2p_action_ie(struct ieee80211_hw *hw, void *data, unsigned int len)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct ieee80211_mgmt *mgmt = (void *)data;
+	struct rtl_p2p_ps_info *p2pinfo = &(rtlpriv->psc.p2p_ps_info);
+	bool find_p2p_ie = false , find_p2p_ps_ie = false;
+	u8 noa_num, index, i, noa_index = 0;
+	u8 *pos, *end, *ie;
+	u16 noa_len;
+	static u8 p2p_oui_ie_type[4] = {0x50, 0x6f, 0x9a, 0x09};
+
+	pos = (u8 *)&mgmt->u.action.category;
+	end = data + len;
+	ie = NULL;
+
+	if (pos[0] == 0x7f) {
+		if (memcmp(&pos[1], p2p_oui_ie_type, 4) == 0)
+			ie = pos + 3+4;
+	}
+
+	if (ie == NULL)
+		return;
+	find_p2p_ie = true;
+
+	RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD, "action frame find P2P IE.\n");
+	/*to find noa ie*/
+	while (ie + 1 < end) {
+		noa_len = READEF2BYTE(&ie[1]);
+		if (ie + 3 + ie[1] > end)
+			return;
+
+		if (ie[0] == 12) {
+			RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD, "find NOA IE.\n");
+			RT_PRINT_DATA(rtlpriv, COMP_FW, DBG_LOUD, "noa ie ",
+				      ie, noa_len);
+			find_p2p_ps_ie = true;
+			if ((noa_len - 2) % 13 != 0) {
+				RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD,
+					 "P2P notice of absence: invalid length.%d\n",
+					 noa_len);
+				return;
+			} else {
+				noa_num = (noa_len - 2) / 13;
+			}
+			noa_index = ie[3];
+			if (rtlpriv->psc.p2p_ps_info.p2p_ps_mode ==
+			    P2P_PS_NONE || noa_index != p2pinfo->noa_index) {
+				p2pinfo->noa_index = noa_index;
+				p2pinfo->opp_ps = (ie[4] >> 7);
+				p2pinfo->ctwindow = ie[4] & 0x7F;
+				p2pinfo->noa_num = noa_num;
+				index = 5;
+				for (i = 0; i < noa_num; i++) {
+					p2pinfo->noa_count_type[i] =
+							 READEF1BYTE(ie+index);
+					index += 1;
+					p2pinfo->noa_duration[i] =
+							 READEF4BYTE(ie+index);
+					index += 4;
+					p2pinfo->noa_interval[i] =
+							 READEF4BYTE(ie+index);
+					index += 4;
+					p2pinfo->noa_start_time[i] =
+							 READEF4BYTE(ie+index);
+					index += 4;
+				}
+
+				if (p2pinfo->opp_ps == 1) {
+					p2pinfo->p2p_ps_mode = P2P_PS_CTWINDOW;
+					/* Driver should wait LPS entering
+					 * CTWindow
+					 */
+					if (rtlpriv->psc.fw_current_inpsmode)
+						rtl_p2p_ps_cmd(hw,
+							       P2P_PS_ENABLE);
+				} else if (p2pinfo->noa_num > 0) {
+					p2pinfo->p2p_ps_mode = P2P_PS_NOA;
+					rtl_p2p_ps_cmd(hw, P2P_PS_ENABLE);
+				} else if (p2pinfo->p2p_ps_mode > P2P_PS_NONE) {
+					rtl_p2p_ps_cmd(hw, P2P_PS_DISABLE);
+				}
+			}
+		break;
+		}
+		ie += 3 + noa_len;
+	}
+}
+
+void rtl_p2p_ps_cmd(struct ieee80211_hw *hw, u8 p2p_ps_state)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_ps_ctl *rtlps = rtl_psc(rtl_priv(hw));
+	struct rtl_p2p_ps_info  *p2pinfo = &(rtlpriv->psc.p2p_ps_info);
+
+	RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD, " p2p state %x\n", p2p_ps_state);
+	switch (p2p_ps_state) {
+	case P2P_PS_DISABLE:
+		p2pinfo->p2p_ps_state = p2p_ps_state;
+		rtlpriv->cfg->ops->set_hw_reg(hw,
+				 HW_VAR_H2C_FW_P2P_PS_OFFLOAD,
+				 (u8 *)(&p2p_ps_state));
+
+		p2pinfo->noa_index = 0;
+		p2pinfo->ctwindow = 0;
+		p2pinfo->opp_ps = 0;
+		p2pinfo->noa_num = 0;
+		p2pinfo->p2p_ps_mode = P2P_PS_NONE;
+		if (rtlps->fw_current_inpsmode == true) {
+			if (rtlps->smart_ps == 0) {
+				rtlps->smart_ps = 2;
+				rtlpriv->cfg->ops->set_hw_reg(hw,
+					 HW_VAR_H2C_FW_PWRMODE,
+					 (u8 *)(&rtlps->pwr_mode));
+			}
+		}
+		break;
+	case P2P_PS_ENABLE:
+		if (p2pinfo->p2p_ps_mode > P2P_PS_NONE) {
+			p2pinfo->p2p_ps_state = p2p_ps_state;
+
+			if (p2pinfo->ctwindow > 0) {
+				if (rtlps->smart_ps != 0) {
+					rtlps->smart_ps = 0;
+					rtlpriv->cfg->ops->set_hw_reg(hw,
+						 HW_VAR_H2C_FW_PWRMODE,
+						 (u8 *)(&rtlps->pwr_mode));
+				}
+			}
+			rtlpriv->cfg->ops->set_hw_reg(hw,
+				 HW_VAR_H2C_FW_P2P_PS_OFFLOAD,
+				 (u8 *)(&p2p_ps_state));
+		}
+		break;
+	case P2P_PS_SCAN:
+	case P2P_PS_SCAN_DONE:
+	case P2P_PS_ALLSTASLEEP:
+		if (p2pinfo->p2p_ps_mode > P2P_PS_NONE) {
+			p2pinfo->p2p_ps_state = p2p_ps_state;
+			rtlpriv->cfg->ops->set_hw_reg(hw,
+				 HW_VAR_H2C_FW_P2P_PS_OFFLOAD,
+				 (u8 *)(&p2p_ps_state));
+		}
+		break;
+	default:
+		break;
+	}
+	RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD,
+		 "ctwindow %x oppps %x\n", p2pinfo->ctwindow, p2pinfo->opp_ps);
+	RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD,
+		 "count %x duration %x index %x interval %x start time %x noa num %x\n",
+		 p2pinfo->noa_count_type[0], p2pinfo->noa_duration[0],
+		 p2pinfo->noa_index, p2pinfo->noa_interval[0],
+		 p2pinfo->noa_start_time[0], p2pinfo->noa_num);
+	RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD, "end\n");
+}
+
+void rtl_p2p_info(struct ieee80211_hw *hw, void *data, unsigned int len)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
+	struct ieee80211_hdr *hdr = (void *)data;
+
+	if (!mac->p2p)
+		return;
+	if (mac->link_state != MAC80211_LINKED)
+		return;
+	/* min. beacon length + FCS_LEN */
+	if (len <= 40 + FCS_LEN)
+		return;
+
+	/* and only beacons from the associated BSSID, please */
+	if (compare_ether_addr(hdr->addr3, rtlpriv->mac80211.bssid))
+		return;
+
+	/* check if this really is a beacon */
+	if (!(ieee80211_is_beacon(hdr->frame_control) ||
+	      ieee80211_is_probe_resp(hdr->frame_control) ||
+	      ieee80211_is_action(hdr->frame_control)))
+		return;
+
+	if (ieee80211_is_action(hdr->frame_control))
+		rtl_p2p_action_ie(hw, data, len - FCS_LEN);
+	else
+		rtl_p2p_noa_ie(hw, data, len - FCS_LEN);
+}
diff --git a/drivers/net/wireless/rtlwifi/ps.h b/drivers/net/wireless/rtlwifi/ps.h
index 1357856..4d682b7 100644
--- a/drivers/net/wireless/rtlwifi/ps.h
+++ b/drivers/net/wireless/rtlwifi/ps.h
@@ -47,5 +47,7 @@ void rtl_swlps_wq_callback(void *data);
 void rtl_swlps_rfon_wq_callback(void *data);
 void rtl_swlps_rf_awake(struct ieee80211_hw *hw);
 void rtl_swlps_rf_sleep(struct ieee80211_hw *hw);
+void rtl_p2p_ps_cmd(struct ieee80211_hw *hw, u8 p2p_ps_state);
+void rtl_p2p_info(struct ieee80211_hw *hw, void *data, unsigned int len);
 
 #endif
-- 
1.8.1.4
