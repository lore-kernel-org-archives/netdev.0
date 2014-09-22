From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 07/11 NEXT] rtlwifi: Update power-save routines for 062814 driver
Date: Mon, 22 Sep 2014 09:39:23 -0500
Message-ID: <1411396767-20611-8-git-send-email-Larry.Finger@lwfinger.net>
References: <1411396767-20611-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org, troy_tan@realsil.com.cn,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f43.google.com ([209.85.219.43]:38980 "EHLO
	mail-oa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754212AbaIVOkC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 10:40:02 -0400
In-Reply-To: <1411396767-20611-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Realtek released a new version of the drivers on 06/28/2014. This
patch implements the new power-save code. These changes also force
corresponding changes in the drivers.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/rtlwifi/ps.c                  | 284 +++++++++------------
 drivers/net/wireless/rtlwifi/ps.h                  |  71 +-----
 drivers/net/wireless/rtlwifi/rtl8188ee/Makefile    |   1 +
 drivers/net/wireless/rtlwifi/rtl8188ee/hw.c        |  17 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/pwrseq.h    |  18 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.c |   1 +
 drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.h |   4 -
 drivers/net/wireless/rtlwifi/rtl8723ae/Makefile    |   1 +
 drivers/net/wireless/rtlwifi/rtl8723ae/hw.c        |   1 +
 drivers/net/wireless/rtlwifi/rtl8723ae/pwrseqcmd.c |   1 +
 drivers/net/wireless/rtlwifi/rtl8723be/Makefile    |   1 +
 drivers/net/wireless/rtlwifi/rtl8723be/hw.c        |  15 +-
 drivers/net/wireless/rtlwifi/rtl8723be/pwrseqcmd.c |   1 +
 13 files changed, 163 insertions(+), 253 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/ps.c b/drivers/net/wireless/rtlwifi/ps.c
index 5050494..123f2be 100644
--- a/drivers/net/wireless/rtlwifi/ps.c
+++ b/drivers/net/wireless/rtlwifi/ps.c
@@ -11,10 +11,6 @@
  * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
  * more details.
  *
- * You should have received a copy of the GNU General Public License along with
- * this program; if not, write to the Free Software Foundation, Inc.,
- * 51 Franklin Street, Fifth Floor, Boston, MA 02110, USA
- *
  * The full GNU General Public License is included in this distribution in the
  * file called LICENSE.
  *
@@ -27,110 +23,11 @@
  *
  *****************************************************************************/
 
-#include <linux/export.h>
 #include "wifi.h"
 #include "base.h"
 #include "ps.h"
-
-/*	Description:
- *		This routine deals with the Power Configuration CMD
- *		 parsing for RTL8723/RTL8188E Series IC.
- *	Assumption:
- *		We should follow specific format that was released from HW SD.
- */
-bool rtl_hal_pwrseqcmdparsing(struct rtl_priv *rtlpriv, u8 cut_version,
-			      u8 faversion, u8 interface_type,
-			      struct wlan_pwr_cfg pwrcfgcmd[])
-{
-	struct wlan_pwr_cfg cfg_cmd = {0};
-	bool polling_bit = false;
-	u32 ary_idx = 0;
-	u8 value = 0;
-	u32 offset = 0;
-	u32 polling_count = 0;
-	u32 max_polling_cnt = 5000;
-
-	do {
-		cfg_cmd = pwrcfgcmd[ary_idx];
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			"rtl_hal_pwrseqcmdparsing(): offset(%#x),cut_msk(%#x), famsk(%#x),"
-			"interface_msk(%#x), base(%#x), cmd(%#x), msk(%#x), value(%#x)\n",
-			GET_PWR_CFG_OFFSET(cfg_cmd),
-					   GET_PWR_CFG_CUT_MASK(cfg_cmd),
-			GET_PWR_CFG_FAB_MASK(cfg_cmd),
-					     GET_PWR_CFG_INTF_MASK(cfg_cmd),
-			GET_PWR_CFG_BASE(cfg_cmd), GET_PWR_CFG_CMD(cfg_cmd),
-			GET_PWR_CFG_MASK(cfg_cmd), GET_PWR_CFG_VALUE(cfg_cmd));
-
-		if ((GET_PWR_CFG_FAB_MASK(cfg_cmd)&faversion) &&
-		    (GET_PWR_CFG_CUT_MASK(cfg_cmd)&cut_version) &&
-		    (GET_PWR_CFG_INTF_MASK(cfg_cmd)&interface_type)) {
-			switch (GET_PWR_CFG_CMD(cfg_cmd)) {
-			case PWR_CMD_READ:
-				RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-					"rtl_hal_pwrseqcmdparsing(): PWR_CMD_READ\n");
-				break;
-			case PWR_CMD_WRITE:
-				RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-					"rtl_hal_pwrseqcmdparsing(): PWR_CMD_WRITE\n");
-				offset = GET_PWR_CFG_OFFSET(cfg_cmd);
-
-				/*Read the value from system register*/
-				value = rtl_read_byte(rtlpriv, offset);
-				value &= (~(GET_PWR_CFG_MASK(cfg_cmd)));
-				value |= (GET_PWR_CFG_VALUE(cfg_cmd) &
-					  GET_PWR_CFG_MASK(cfg_cmd));
-
-				/*Write the value back to sytem register*/
-				rtl_write_byte(rtlpriv, offset, value);
-				break;
-			case PWR_CMD_POLLING:
-				RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-					"rtl_hal_pwrseqcmdparsing(): PWR_CMD_POLLING\n");
-				polling_bit = false;
-				offset = GET_PWR_CFG_OFFSET(cfg_cmd);
-
-				do {
-					value = rtl_read_byte(rtlpriv, offset);
-
-					value &= GET_PWR_CFG_MASK(cfg_cmd);
-					if (value ==
-					    (GET_PWR_CFG_VALUE(cfg_cmd)
-					    & GET_PWR_CFG_MASK(cfg_cmd)))
-						polling_bit = true;
-					else
-						udelay(10);
-
-					if (polling_count++ > max_polling_cnt)
-						return false;
-				} while (!polling_bit);
-				break;
-			case PWR_CMD_DELAY:
-				RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-					"rtl_hal_pwrseqcmdparsing(): PWR_CMD_DELAY\n");
-				if (GET_PWR_CFG_VALUE(cfg_cmd) ==
-				    PWRSEQ_DELAY_US)
-					udelay(GET_PWR_CFG_OFFSET(cfg_cmd));
-				else
-					mdelay(GET_PWR_CFG_OFFSET(cfg_cmd));
-				break;
-			case PWR_CMD_END:
-				RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-					 "rtl_hal_pwrseqcmdparsing(): PWR_CMD_END\n");
-				return true;
-			default:
-				RT_ASSERT(false,
-					 "rtl_hal_pwrseqcmdparsing(): Unknown CMD!!\n");
-				break;
-			}
-
-		}
-		ary_idx++;
-	} while (1);
-
-	return true;
-}
-EXPORT_SYMBOL(rtl_hal_pwrseqcmdparsing);
+#include <linux/export.h>
+#include "btcoexist/rtl_btc.h"
 
 bool rtl_ps_enable_nic(struct ieee80211_hw *hw)
 {
@@ -181,11 +78,49 @@ EXPORT_SYMBOL(rtl_ps_disable_nic);
 
 bool rtl_ps_set_rf_state(struct ieee80211_hw *hw,
 			 enum rf_pwrstate state_toset,
-			 u32 changesource)
+			 u32 changesource, bool protect_or_not)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
+	enum rf_pwrstate rtstate;
 	bool actionallowed = false;
+	u16 rfwait_cnt = 0;
+
+	if (protect_or_not)
+		goto no_protect;
+
+	/*Only one thread can change
+	 *the RF state at one time, and others
+	 *should wait to be executed.
+	 */
+	while (true) {
+		spin_lock(&rtlpriv->locks.rf_ps_lock);
+		if (ppsc->rfchange_inprogress) {
+			spin_unlock(&rtlpriv->locks.rf_ps_lock);
+
+			RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
+				 "RF Change in progress! Wait to set..state_toset(%d).\n",
+				  state_toset);
+
+			/* Set RF after the previous action is done.  */
+			while (ppsc->rfchange_inprogress) {
+				rfwait_cnt++;
+				mdelay(1);
+				/*Wait too long, return false to avoid
+				 *to be stuck here.
+				 */
+				if (rfwait_cnt > 100)
+					return false;
+			}
+		} else {
+			ppsc->rfchange_inprogress = true;
+			spin_unlock(&rtlpriv->locks.rf_ps_lock);
+			break;
+		}
+	}
+
+no_protect:
+	rtstate = ppsc->rfpwr_state;
 
 	switch (state_toset) {
 	case ERFON:
@@ -227,6 +162,12 @@ bool rtl_ps_set_rf_state(struct ieee80211_hw *hw,
 	if (actionallowed)
 		rtlpriv->cfg->ops->set_rf_power_state(hw, state_toset);
 
+	if (!protect_or_not) {
+		spin_lock(&rtlpriv->locks.rf_ps_lock);
+		ppsc->rfchange_inprogress = false;
+		spin_unlock(&rtlpriv->locks.rf_ps_lock);
+	}
+
 	return actionallowed;
 }
 EXPORT_SYMBOL(rtl_ps_set_rf_state);
@@ -249,12 +190,13 @@ static void _rtl_ps_inactive_ps(struct ieee80211_hw *hw)
 		}
 	}
 
-	rtl_ps_set_rf_state(hw, ppsc->inactive_pwrstate, RF_CHANGE_BY_IPS);
+	rtl_ps_set_rf_state(hw, ppsc->inactive_pwrstate,
+			    RF_CHANGE_BY_IPS, false);
 
 	if (ppsc->inactive_pwrstate == ERFOFF &&
 	    rtlhal->interface == INTF_PCI) {
 		if (ppsc->reg_rfps_level & RT_RF_OFF_LEVL_ASPM &&
-			!RT_IN_PS_LEVEL(ppsc, RT_PS_LEVEL_ASPM)) {
+		    !RT_IN_PS_LEVEL(ppsc, RT_PS_LEVEL_ASPM)) {
 			rtlpriv->intf_ops->enable_aspm(hw);
 			RT_SET_PS_LEVEL(ppsc, RT_PS_LEVEL_ASPM);
 		}
@@ -318,6 +260,11 @@ void rtl_ips_nic_off_wq_callback(void *data)
 			ppsc->inactive_pwrstate = ERFOFF;
 			ppsc->in_powersavemode = true;
 
+			/* call before RF off */
+			if (rtlpriv->cfg->ops->get_btc_status())
+				rtlpriv->btcoexist.btc_ops->btc_ips_notify(rtlpriv,
+									ppsc->inactive_pwrstate);
+
 			/*rtl_pci_reset_trx_ring(hw); */
 			_rtl_ps_inactive_ps(hw);
 		}
@@ -328,10 +275,9 @@ void rtl_ips_nic_off(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
-	/*
-	 *because when link with ap, mac80211 will ask us
-	 *to disable nic quickly after scan before linking,
-	 *this will cause link failed, so we delay 100ms here
+	/* because when link with ap, mac80211 will ask us
+	 * to disable nic quickly after scan before linking,
+	 * this will cause link failed, so we delay 100ms here
 	 */
 	queue_delayed_work(rtlpriv->works.rtl_wq,
 			   &rtlpriv->works.ips_nic_off_wq, MSECS(100));
@@ -343,16 +289,12 @@ void rtl_ips_nic_off(struct ieee80211_hw *hw)
 void rtl_ips_nic_on(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
 	enum rf_pwrstate rtstate;
-	unsigned long flags;
-
-	if (mac->opmode != NL80211_IFTYPE_STATION)
-		return;
 
-	spin_lock_irqsave(&rtlpriv->locks.ips_lock, flags);
+	cancel_delayed_work(&rtlpriv->works.ips_nic_off_wq);
 
+	spin_lock(&rtlpriv->locks.ips_lock);
 	if (ppsc->inactiveps) {
 		rtstate = ppsc->rfpwr_state;
 
@@ -362,12 +304,14 @@ void rtl_ips_nic_on(struct ieee80211_hw *hw)
 
 			ppsc->inactive_pwrstate = ERFON;
 			ppsc->in_powersavemode = false;
-
 			_rtl_ps_inactive_ps(hw);
+			/* call after RF on */
+			if (rtlpriv->cfg->ops->get_btc_status())
+				rtlpriv->btcoexist.btc_ops->btc_ips_notify(rtlpriv,
+									ppsc->inactive_pwrstate);
 		}
 	}
-
-	spin_unlock_irqrestore(&rtlpriv->locks.ips_lock, flags);
+	spin_unlock(&rtlpriv->locks.ips_lock);
 }
 EXPORT_SYMBOL_GPL(rtl_ips_nic_on);
 
@@ -404,7 +348,7 @@ static bool rtl_get_fwlps_doze(struct ieee80211_hw *hw)
 }
 
 /* Change current and default preamble mode.*/
-static void rtl_lps_set_psmode(struct ieee80211_hw *hw, u8 rt_psmode)
+void rtl_lps_set_psmode(struct ieee80211_hw *hw, u8 rt_psmode)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
@@ -437,21 +381,24 @@ static void rtl_lps_set_psmode(struct ieee80211_hw *hw, u8 rt_psmode)
 		if (ppsc->dot11_psmode == EACTIVE) {
 			RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
 				 "FW LPS leave ps_mode:%x\n",
-				 FW_PS_ACTIVE_MODE);
+				  FW_PS_ACTIVE_MODE);
 			enter_fwlps = false;
 			ppsc->pwr_mode = FW_PS_ACTIVE_MODE;
 			ppsc->smart_ps = 0;
-			rtlpriv->cfg->ops->set_hw_reg(hw,
-						HW_VAR_FW_LPS_ACTION,
-						(u8 *)(&enter_fwlps));
+			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_FW_LPS_ACTION,
+						      (u8 *)(&enter_fwlps));
 			if (ppsc->p2p_ps_info.opp_ps)
-				rtl_p2p_ps_cmd(hw, P2P_PS_ENABLE);
+				rtl_p2p_ps_cmd(hw , P2P_PS_ENABLE);
 
+			if (rtlpriv->cfg->ops->get_btc_status())
+				rtlpriv->btcoexist.btc_ops->btc_lps_notify(rtlpriv, rt_psmode);
 		} else {
 			if (rtl_get_fwlps_doze(hw)) {
 				RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
 					 "FW LPS enter ps_mode:%x\n",
 					 ppsc->fwctrl_psmode);
+				if (rtlpriv->cfg->ops->get_btc_status())
+					rtlpriv->btcoexist.btc_ops->btc_lps_notify(rtlpriv, rt_psmode);
 				enter_fwlps = true;
 				ppsc->pwr_mode = ppsc->fwctrl_psmode;
 				ppsc->smart_ps = 2;
@@ -473,6 +420,7 @@ void rtl_lps_enter(struct ieee80211_hw *hw)
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	unsigned long flag;
 
 	if (!ppsc->fwctrl_lps)
 		return;
@@ -493,7 +441,7 @@ void rtl_lps_enter(struct ieee80211_hw *hw)
 	if (mac->link_state != MAC80211_LINKED)
 		return;
 
-	mutex_lock(&rtlpriv->locks.ps_mutex);
+	spin_lock_irqsave(&rtlpriv->locks.lps_lock, flag);
 
 	/* Idle for a while if we connect to AP a while ago. */
 	if (mac->cnt_after_linked >= 2) {
@@ -505,8 +453,9 @@ void rtl_lps_enter(struct ieee80211_hw *hw)
 		}
 	}
 
-	mutex_unlock(&rtlpriv->locks.ps_mutex);
+	spin_unlock_irqrestore(&rtlpriv->locks.lps_lock, flag);
 }
+EXPORT_SYMBOL(rtl_lps_enter);
 
 /*Leave the leisure power save mode.*/
 void rtl_lps_leave(struct ieee80211_hw *hw)
@@ -514,14 +463,15 @@ void rtl_lps_leave(struct ieee80211_hw *hw)
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
+	unsigned long flag;
 
-	mutex_lock(&rtlpriv->locks.ps_mutex);
+	spin_lock_irqsave(&rtlpriv->locks.lps_lock, flag);
 
 	if (ppsc->fwctrl_lps) {
 		if (ppsc->dot11_psmode != EACTIVE) {
 
 			/*FIX ME */
-			rtlpriv->cfg->ops->enable_interrupt(hw);
+			/*rtlpriv->cfg->ops->enable_interrupt(hw); */
 
 			if (ppsc->reg_rfps_level & RT_RF_LPS_LEVEL_ASPM &&
 			    RT_IN_PS_LEVEL(ppsc, RT_PS_LEVEL_ASPM) &&
@@ -536,8 +486,9 @@ void rtl_lps_leave(struct ieee80211_hw *hw)
 			rtl_lps_set_psmode(hw, EACTIVE);
 		}
 	}
-	mutex_unlock(&rtlpriv->locks.ps_mutex);
+	spin_unlock_irqrestore(&rtlpriv->locks.lps_lock, flag);
 }
+EXPORT_SYMBOL(rtl_lps_leave);
 
 /* For sw LPS*/
 void rtl_swlps_beacon(struct ieee80211_hw *hw, void *data, unsigned int len)
@@ -613,7 +564,7 @@ void rtl_swlps_beacon(struct ieee80211_hw *hw, void *data, unsigned int len)
 		/* back to low-power land. and delay is
 		 * prevent null power save frame tx fail */
 		queue_delayed_work(rtlpriv->works.rtl_wq,
-				&rtlpriv->works.ps_work, MSECS(5));
+				   &rtlpriv->works.ps_work, MSECS(5));
 	} else {
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_DMESG,
 			 "u_bufferd: %x, m_buffered: %x\n", u_buffed, m_buffed);
@@ -626,6 +577,7 @@ void rtl_swlps_rf_awake(struct ieee80211_hw *hw)
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
+	unsigned long flag;
 
 	if (!rtlpriv->psc.swctrl_lps)
 		return;
@@ -633,14 +585,14 @@ void rtl_swlps_rf_awake(struct ieee80211_hw *hw)
 		return;
 
 	if (ppsc->reg_rfps_level & RT_RF_LPS_LEVEL_ASPM &&
-		RT_IN_PS_LEVEL(ppsc, RT_PS_LEVEL_ASPM)) {
+	    RT_IN_PS_LEVEL(ppsc, RT_PS_LEVEL_ASPM)) {
 		rtlpriv->intf_ops->disable_aspm(hw);
 		RT_CLEAR_PS_LEVEL(ppsc, RT_PS_LEVEL_ASPM);
 	}
 
-	mutex_lock(&rtlpriv->locks.ps_mutex);
-	rtl_ps_set_rf_state(hw, ERFON, RF_CHANGE_BY_PS);
-	mutex_unlock(&rtlpriv->locks.ps_mutex);
+	spin_lock_irqsave(&rtlpriv->locks.lps_lock, flag);
+	rtl_ps_set_rf_state(hw, ERFON, RF_CHANGE_BY_PS, false);
+	spin_unlock_irqrestore(&rtlpriv->locks.lps_lock, flag);
 }
 
 void rtl_swlps_rfon_wq_callback(void *data)
@@ -657,6 +609,7 @@ void rtl_swlps_rf_sleep(struct ieee80211_hw *hw)
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
+	unsigned long flag;
 	u8 sleep_intv;
 
 	if (!rtlpriv->psc.sw_ps_enabled)
@@ -673,12 +626,19 @@ void rtl_swlps_rf_sleep(struct ieee80211_hw *hw)
 	if (rtlpriv->link_info.busytraffic)
 		return;
 
-	mutex_lock(&rtlpriv->locks.ps_mutex);
-	rtl_ps_set_rf_state(hw, ERFSLEEP, RF_CHANGE_BY_PS);
-	mutex_unlock(&rtlpriv->locks.ps_mutex);
+	spin_lock(&rtlpriv->locks.rf_ps_lock);
+	if (rtlpriv->psc.rfchange_inprogress) {
+		spin_unlock(&rtlpriv->locks.rf_ps_lock);
+		return;
+	}
+	spin_unlock(&rtlpriv->locks.rf_ps_lock);
+
+	spin_lock_irqsave(&rtlpriv->locks.lps_lock, flag);
+	rtl_ps_set_rf_state(hw, ERFSLEEP, RF_CHANGE_BY_PS , false);
+	spin_unlock_irqrestore(&rtlpriv->locks.lps_lock, flag);
 
 	if (ppsc->reg_rfps_level & RT_RF_OFF_LEVL_ASPM &&
-		!RT_IN_PS_LEVEL(ppsc, RT_PS_LEVEL_ASPM)) {
+	    !RT_IN_PS_LEVEL(ppsc, RT_PS_LEVEL_ASPM)) {
 		rtlpriv->intf_ops->enable_aspm(hw);
 		RT_SET_PS_LEVEL(ppsc, RT_PS_LEVEL_ASPM);
 	}
@@ -706,7 +666,7 @@ void rtl_swlps_rf_sleep(struct ieee80211_hw *hw)
 	 * awake before every dtim */
 	RT_TRACE(rtlpriv, COMP_POWER, DBG_DMESG,
 		 "dtim_counter:%x will sleep :%d beacon_intv\n",
-		 rtlpriv->psc.dtim_counter, sleep_intv);
+		  rtlpriv->psc.dtim_counter, sleep_intv);
 
 	/* we tested that 40ms is enough for sw & hw sw delay */
 	queue_delayed_work(rtlpriv->works.rtl_wq, &rtlpriv->works.ps_rfon_wq,
@@ -744,7 +704,7 @@ void rtl_swlps_wq_callback(void *data)
 
 		if (rtlpriv->psc.state && !ps) {
 			rtlpriv->psc.sleep_ms = jiffies_to_msecs(jiffies -
-					rtlpriv->psc.last_action);
+						 rtlpriv->psc.last_action);
 		}
 
 		if (ps)
@@ -764,7 +724,7 @@ static void rtl_p2p_noa_ie(struct ieee80211_hw *hw, void *data,
 	u8 *pos, *end, *ie;
 	u16 noa_len;
 	static u8 p2p_oui_ie_type[4] = {0x50, 0x6f, 0x9a, 0x09};
-	u8 noa_num, index, i, noa_index = 0;
+	u8 noa_num, index , i, noa_index = 0;
 	bool find_p2p_ie = false , find_p2p_ps_ie = false;
 	pos = (u8 *)mgmt->u.beacon.variable;
 	end = data + len;
@@ -814,7 +774,7 @@ static void rtl_p2p_noa_ie(struct ieee80211_hw *hw, void *data,
 				index = 5;
 				for (i = 0; i < noa_num; i++) {
 					p2pinfo->noa_count_type[i] =
-						 READEF1BYTE(ie+index);
+							READEF1BYTE(ie+index);
 					index += 1;
 					p2pinfo->noa_duration[i] =
 						 READEF4BYTE((__le32 *)ie+index);
@@ -842,7 +802,7 @@ static void rtl_p2p_noa_ie(struct ieee80211_hw *hw, void *data,
 					rtl_p2p_ps_cmd(hw, P2P_PS_DISABLE);
 				}
 			}
-		break;
+			break;
 		}
 		ie += 3 + noa_len;
 	}
@@ -860,7 +820,7 @@ static void rtl_p2p_action_ie(struct ieee80211_hw *hw, void *data,
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct ieee80211_mgmt *mgmt = data;
 	struct rtl_p2p_ps_info *p2pinfo = &(rtlpriv->psc.p2p_ps_info);
-	u8 noa_num, index, i, noa_index = 0;
+	u8 noa_num, index , i , noa_index = 0;
 	u8 *pos, *end, *ie;
 	u16 noa_len;
 	static u8 p2p_oui_ie_type[4] = {0x50, 0x6f, 0x9a, 0x09};
@@ -906,7 +866,7 @@ static void rtl_p2p_action_ie(struct ieee80211_hw *hw, void *data,
 				index = 5;
 				for (i = 0; i < noa_num; i++) {
 					p2pinfo->noa_count_type[i] =
-							 READEF1BYTE(ie+index);
+							READEF1BYTE(ie+index);
 					index += 1;
 					p2pinfo->noa_duration[i] =
 							 READEF4BYTE((__le32 *)ie+index);
@@ -934,37 +894,37 @@ static void rtl_p2p_action_ie(struct ieee80211_hw *hw, void *data,
 					rtl_p2p_ps_cmd(hw, P2P_PS_DISABLE);
 				}
 			}
-		break;
+			break;
 		}
 		ie += 3 + noa_len;
 	}
 }
 
-void rtl_p2p_ps_cmd(struct ieee80211_hw *hw, u8 p2p_ps_state)
+void rtl_p2p_ps_cmd(struct ieee80211_hw *hw , u8 p2p_ps_state)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_ps_ctl *rtlps = rtl_psc(rtl_priv(hw));
 	struct rtl_p2p_ps_info  *p2pinfo = &(rtlpriv->psc.p2p_ps_info);
 
-	RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD, " p2p state %x\n", p2p_ps_state);
+	RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD, " p2p state %x\n" , p2p_ps_state);
 	switch (p2p_ps_state) {
 	case P2P_PS_DISABLE:
 		p2pinfo->p2p_ps_state = p2p_ps_state;
 		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_H2C_FW_P2P_PS_OFFLOAD,
 					      &p2p_ps_state);
-
 		p2pinfo->noa_index = 0;
 		p2pinfo->ctwindow = 0;
 		p2pinfo->opp_ps = 0;
 		p2pinfo->noa_num = 0;
 		p2pinfo->p2p_ps_mode = P2P_PS_NONE;
-		if (rtlps->fw_current_inpsmode == true) {
+		if (rtlps->fw_current_inpsmode) {
 			if (rtlps->smart_ps == 0) {
 				rtlps->smart_ps = 2;
 				rtlpriv->cfg->ops->set_hw_reg(hw,
 					 HW_VAR_H2C_FW_PWRMODE,
 					 &rtlps->pwr_mode);
 			}
+
 		}
 		break;
 	case P2P_PS_ENABLE:
@@ -982,6 +942,7 @@ void rtl_p2p_ps_cmd(struct ieee80211_hw *hw, u8 p2p_ps_state)
 			rtlpriv->cfg->ops->set_hw_reg(hw,
 				 HW_VAR_H2C_FW_P2P_PS_OFFLOAD,
 				 &p2p_ps_state);
+
 		}
 		break;
 	case P2P_PS_SCAN:
@@ -998,12 +959,16 @@ void rtl_p2p_ps_cmd(struct ieee80211_hw *hw, u8 p2p_ps_state)
 		break;
 	}
 	RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD,
-		 "ctwindow %x oppps %x\n", p2pinfo->ctwindow, p2pinfo->opp_ps);
+		 "ctwindow %x oppps %x\n",
+		 p2pinfo->ctwindow , p2pinfo->opp_ps);
 	RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD,
 		 "count %x duration %x index %x interval %x start time %x noa num %x\n",
-		 p2pinfo->noa_count_type[0], p2pinfo->noa_duration[0],
-		 p2pinfo->noa_index, p2pinfo->noa_interval[0],
-		 p2pinfo->noa_start_time[0], p2pinfo->noa_num);
+		 p2pinfo->noa_count_type[0],
+		 p2pinfo->noa_duration[0],
+		 p2pinfo->noa_index,
+		 p2pinfo->noa_interval[0],
+		 p2pinfo->noa_start_time[0],
+		 p2pinfo->noa_num);
 	RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD, "end\n");
 }
 
@@ -1032,8 +997,9 @@ void rtl_p2p_info(struct ieee80211_hw *hw, void *data, unsigned int len)
 		return;
 
 	if (ieee80211_is_action(hdr->frame_control))
-		rtl_p2p_action_ie(hw, data, len - FCS_LEN);
+		rtl_p2p_action_ie(hw , data , len - FCS_LEN);
 	else
-		rtl_p2p_noa_ie(hw, data, len - FCS_LEN);
+		rtl_p2p_noa_ie(hw , data , len - FCS_LEN);
 }
 EXPORT_SYMBOL_GPL(rtl_p2p_info);
+
diff --git a/drivers/net/wireless/rtlwifi/ps.h b/drivers/net/wireless/rtlwifi/ps.h
index 3bd41f9..29dfc51 100644
--- a/drivers/net/wireless/rtlwifi/ps.h
+++ b/drivers/net/wireless/rtlwifi/ps.h
@@ -11,10 +11,6 @@
  * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
  * more details.
  *
- * You should have received a copy of the GNU General Public License along with
- * this program; if not, write to the Free Software Foundation, Inc.,
- * 51 Franklin Street, Fifth Floor, Boston, MA 02110, USA
- *
  * The full GNU General Public License is included in this distribution in the
  * file called LICENSE.
  *
@@ -32,68 +28,9 @@
 
 #define MAX_SW_LPS_SLEEP_INTV	5
 
-/*---------------------------------------------
- * 3 The value of cmd: 4 bits
- *---------------------------------------------
- */
-#define    PWR_CMD_READ		0x00
-#define    PWR_CMD_WRITE	0x01
-#define    PWR_CMD_POLLING	0x02
-#define    PWR_CMD_DELAY	0x03
-#define    PWR_CMD_END		0x04
-
-/* define the base address of each block */
-#define	PWR_BASEADDR_MAC	0x00
-#define	PWR_BASEADDR_USB	0x01
-#define	PWR_BASEADDR_PCIE	0x02
-#define	PWR_BASEADDR_SDIO	0x03
-
-#define	PWR_FAB_ALL_MSK		(BIT(0)|BIT(1)|BIT(2)|BIT(3))
-#define	PWR_CUT_TESTCHIP_MSK	BIT(0)
-#define	PWR_CUT_A_MSK		BIT(1)
-#define	PWR_CUT_B_MSK		BIT(2)
-#define	PWR_CUT_C_MSK		BIT(3)
-#define	PWR_CUT_D_MSK		BIT(4)
-#define	PWR_CUT_E_MSK		BIT(5)
-#define	PWR_CUT_F_MSK		BIT(6)
-#define	PWR_CUT_G_MSK		BIT(7)
-#define	PWR_CUT_ALL_MSK		0xFF
-#define PWR_INTF_SDIO_MSK	BIT(0)
-#define PWR_INTF_USB_MSK	BIT(1)
-#define PWR_INTF_PCI_MSK	BIT(2)
-#define PWR_INTF_ALL_MSK	(BIT(0)|BIT(1)|BIT(2)|BIT(3))
-
-enum pwrseq_delay_unit {
-	PWRSEQ_DELAY_US,
-	PWRSEQ_DELAY_MS,
-};
-
-struct wlan_pwr_cfg {
-	u16 offset;
-	u8 cut_msk;
-	u8 fab_msk:4;
-	u8 interface_msk:4;
-	u8 base:4;
-	u8 cmd:4;
-	u8 msk;
-	u8 value;
-};
-
-#define	GET_PWR_CFG_OFFSET(__PWR_CMD)	(__PWR_CMD.offset)
-#define	GET_PWR_CFG_CUT_MASK(__PWR_CMD)	(__PWR_CMD.cut_msk)
-#define	GET_PWR_CFG_FAB_MASK(__PWR_CMD)	(__PWR_CMD.fab_msk)
-#define	GET_PWR_CFG_INTF_MASK(__PWR_CMD)	(__PWR_CMD.interface_msk)
-#define	GET_PWR_CFG_BASE(__PWR_CMD)	(__PWR_CMD.base)
-#define	GET_PWR_CFG_CMD(__PWR_CMD)	(__PWR_CMD.cmd)
-#define	GET_PWR_CFG_MASK(__PWR_CMD)	(__PWR_CMD.msk)
-#define	GET_PWR_CFG_VALUE(__PWR_CMD)	(__PWR_CMD.value)
-
-bool rtl_hal_pwrseqcmdparsing(struct rtl_priv *rtlpriv, u8 cut_version,
-			      u8 fab_version, u8 interface_type,
-			      struct wlan_pwr_cfg pwrcfgcmd[]);
-
 bool rtl_ps_set_rf_state(struct ieee80211_hw *hw,
-			 enum rf_pwrstate state_toset, u32 changesource);
+			 enum rf_pwrstate state_toset, u32 changesource,
+			 bool protect_or_not);
 bool rtl_ps_enable_nic(struct ieee80211_hw *hw);
 bool rtl_ps_disable_nic(struct ieee80211_hw *hw);
 void rtl_ips_nic_off(struct ieee80211_hw *hw);
@@ -102,12 +39,14 @@ void rtl_ips_nic_off_wq_callback(void *data);
 void rtl_lps_enter(struct ieee80211_hw *hw);
 void rtl_lps_leave(struct ieee80211_hw *hw);
 
+void rtl_lps_set_psmode(struct ieee80211_hw *hw, u8 rt_psmode);
+
 void rtl_swlps_beacon(struct ieee80211_hw *hw, void *data, unsigned int len);
 void rtl_swlps_wq_callback(void *data);
 void rtl_swlps_rfon_wq_callback(void *data);
 void rtl_swlps_rf_awake(struct ieee80211_hw *hw);
 void rtl_swlps_rf_sleep(struct ieee80211_hw *hw);
-void rtl_p2p_ps_cmd(struct ieee80211_hw *hw, u8 p2p_ps_state);
+void rtl_p2p_ps_cmd(struct ieee80211_hw *hw , u8 p2p_ps_state);
 void rtl_p2p_info(struct ieee80211_hw *hw, void *data, unsigned int len);
 void rtl_lps_change_work_callback(struct work_struct *work);
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/Makefile b/drivers/net/wireless/rtlwifi/rtl8188ee/Makefile
index a85419a..5b194e9 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/Makefile
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/Makefile
@@ -5,6 +5,7 @@ rtl8188ee-objs :=		\
 		led.o		\
 		phy.o		\
 		pwrseq.o	\
+		pwrseqcmd.o	\
 		rf.o		\
 		sw.o		\
 		table.o		\
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/hw.c b/drivers/net/wireless/rtlwifi/rtl8188ee/hw.c
index d840ad7..ba639bb 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/hw.c
@@ -41,6 +41,7 @@
 #include "fw.h"
 #include "led.h"
 #include "hw.h"
+#include "pwrseqcmd.h"
 #include "pwrseq.h"
 
 #define LLT_CONFIG		5
@@ -809,9 +810,9 @@ static bool _rtl88ee_init_mac(struct ieee80211_hw *hw)
 
 	rtl_write_byte(rtlpriv, REG_RSV_CTRL, 0x00);
 	/* HW Power on sequence */
-	if (!rtl_hal_pwrseqcmdparsing(rtlpriv, PWR_CUT_ALL_MSK,
-				      PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,
-				      Rtl8188E_NIC_ENABLE_FLOW)) {
+	if (!rtl88_hal_pwrseqcmdparsing(rtlpriv, PWR_CUT_ALL_MSK,
+					PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,
+					RTL8188E_NIC_ENABLE_FLOW)) {
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
 			 "init MAC Fail as rtl_hal_pwrseqcmdparsing\n");
 		return false;
@@ -1352,9 +1353,9 @@ static void _rtl88ee_poweroff_adapter(struct ieee80211_hw *hw)
 	}
 	rtl_write_byte(rtlpriv, REG_PCIE_CTRL_REG+1, 0xFF);
 
-	rtl_hal_pwrseqcmdparsing(rtlpriv, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,
-				 PWR_INTF_PCI_MSK,
-				 Rtl8188E_NIC_LPS_ENTER_FLOW);
+	rtl88_hal_pwrseqcmdparsing(rtlpriv, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,
+				   PWR_INTF_PCI_MSK,
+				   RTL8188E_NIC_LPS_ENTER_FLOW);
 
 	rtl_write_byte(rtlpriv, REG_RF_CTRL, 0x00);
 
@@ -1368,8 +1369,8 @@ static void _rtl88ee_poweroff_adapter(struct ieee80211_hw *hw)
 	u1b_tmp = rtl_read_byte(rtlpriv, REG_32K_CTRL);
 	rtl_write_byte(rtlpriv, REG_32K_CTRL, (u1b_tmp & (~BIT(0))));
 
-	rtl_hal_pwrseqcmdparsing(rtlpriv, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,
-				 PWR_INTF_PCI_MSK, Rtl8188E_NIC_DISABLE_FLOW);
+	rtl88_hal_pwrseqcmdparsing(rtlpriv, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,
+				   PWR_INTF_PCI_MSK, RTL8188E_NIC_DISABLE_FLOW);
 
 	u1b_tmp = rtl_read_byte(rtlpriv, REG_RSV_CTRL+1);
 	rtl_write_byte(rtlpriv, REG_RSV_CTRL+1, (u1b_tmp & (~BIT(3))));
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseq.h b/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseq.h
index 32e135a..45c7f4a 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseq.h
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseq.h
@@ -313,14 +313,14 @@ extern struct wlan_pwr_cfg rtl8188e_leave_lps_flow
 		RTL8188E_TRANS_END_STEPS];
 
 /* RTL8723 Power Configuration CMDs for PCIe interface */
-#define Rtl8188E_NIC_PWR_ON_FLOW	rtl8188e_power_on_flow
-#define Rtl8188E_NIC_RF_OFF_FLOW	rtl8188e_radio_off_flow
-#define Rtl8188E_NIC_DISABLE_FLOW	rtl8188e_card_disable_flow
-#define Rtl8188E_NIC_ENABLE_FLOW	rtl8188e_card_enable_flow
-#define Rtl8188E_NIC_SUSPEND_FLOW	rtl8188e_suspend_flow
-#define Rtl8188E_NIC_RESUME_FLOW	rtl8188e_resume_flow
-#define Rtl8188E_NIC_PDN_FLOW		rtl8188e_hwpdn_flow
-#define Rtl8188E_NIC_LPS_ENTER_FLOW	rtl8188e_enter_lps_flow
-#define Rtl8188E_NIC_LPS_LEAVE_FLOW	rtl8188e_leave_lps_flow
+#define RTL8188E_NIC_PWR_ON_FLOW	rtl8188e_power_on_flow
+#define RTL8188E_NIC_RF_OFF_FLOW	rtl8188e_radio_off_flow
+#define RTL8188E_NIC_DISABLE_FLOW	rtl8188e_card_disable_flow
+#define RTL8188E_NIC_ENABLE_FLOW	rtl8188e_card_enable_flow
+#define RTL8188E_NIC_SUSPEND_FLOW	rtl8188e_suspend_flow
+#define RTL8188E_NIC_RESUME_FLOW	rtl8188e_resume_flow
+#define RTL8188E_NIC_PDN_FLOW		rtl8188e_hwpdn_flow
+#define RTL8188E_NIC_LPS_ENTER_FLOW	rtl8188e_enter_lps_flow
+#define RTL8188E_NIC_LPS_LEAVE_FLOW	rtl8188e_leave_lps_flow
 
 #endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.c b/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.c
index 0f93142..3a95ddb 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.c
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.c
@@ -27,6 +27,7 @@
  *
  *****************************************************************************/
 
+#include "pwrseqcmd.h"
 #include "pwrseq.h"
 
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.h b/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.h
index d9ae280..a6cdb0d 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.h
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.h
@@ -11,10 +11,6 @@
  * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
  * more details.
  *
- * You should have received a copy of the GNU General Public License along with
- * this program; if not, write to the Free Software Foundation, Inc.,
- * 51 Franklin Street, Fifth Floor, Boston, MA 02110, USA
- *
  * The full GNU General Public License is included in this distribution in the
  * file called LICENSE.
  *
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/Makefile b/drivers/net/wireless/rtlwifi/rtl8723ae/Makefile
index 9c34a85..4ed731f 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/Makefile
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/Makefile
@@ -10,6 +10,7 @@ rtl8723ae-objs :=		\
 		led.o		\
 		phy.o		\
 		pwrseq.o	\
+		pwrseqcmd.o	\
 		rf.o		\
 		sw.o		\
 		table.o		\
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/hw.c b/drivers/net/wireless/rtlwifi/rtl8723ae/hw.c
index 662a079..dd8e76c 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/hw.c
@@ -43,6 +43,7 @@
 #include "../rtl8723com/fw_common.h"
 #include "led.h"
 #include "hw.h"
+#include "pwrseqcmd.h"
 #include "pwrseq.h"
 #include "btc.h"
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/pwrseqcmd.c b/drivers/net/wireless/rtlwifi/rtl8723ae/pwrseqcmd.c
index 2044b59..239eb44 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/pwrseqcmd.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/pwrseqcmd.c
@@ -27,6 +27,7 @@
  *
  *****************************************************************************/
 
+#include "pwrseqcmd.h"
 #include "pwrseq.h"
 
 /*	Description:
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/Makefile b/drivers/net/wireless/rtlwifi/rtl8723be/Makefile
index 59e416a..4a75aab 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/Makefile
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/Makefile
@@ -8,6 +8,7 @@ rtl8723be-objs :=		\
 		led.o		\
 		phy.o		\
 		pwrseq.o	\
+		pwrseqcmd.o	\
 		rf.o		\
 		sw.o		\
 		table.o		\
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/hw.c b/drivers/net/wireless/rtlwifi/rtl8723be/hw.c
index 3cd2869..1b93918 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/hw.c
@@ -39,6 +39,7 @@
 #include "../rtl8723com/fw_common.h"
 #include "led.h"
 #include "hw.h"
+#include "pwrseqcmd.h"
 #include "pwrseq.h"
 #include "../btcoexist/rtl_btc.h"
 
@@ -814,9 +815,9 @@ static bool _rtl8723be_init_mac(struct ieee80211_hw *hw)
 		mac_func_enable = false;
 
 	/* HW Power on sequence */
-	if (!rtl_hal_pwrseqcmdparsing(rtlpriv, PWR_CUT_ALL_MSK,
-				      PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,
-				      RTL8723_NIC_ENABLE_FLOW)) {
+	if (!rtlbe_hal_pwrseqcmdparsing(rtlpriv, PWR_CUT_ALL_MSK,
+					PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,
+					RTL8723_NIC_ENABLE_FLOW)) {
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
 			 "init MAC Fail as power on failure\n");
 		return false;
@@ -1305,8 +1306,8 @@ static void _rtl8723be_poweroff_adapter(struct ieee80211_hw *hw)
 
 	/* Combo (PCIe + USB) Card and PCIe-MF Card */
 	/* 1. Run LPS WL RFOFF flow */
-	rtl_hal_pwrseqcmdparsing(rtlpriv, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,
-				 PWR_INTF_PCI_MSK, RTL8723_NIC_LPS_ENTER_FLOW);
+	rtlbe_hal_pwrseqcmdparsing(rtlpriv, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,
+				   PWR_INTF_PCI_MSK, RTL8723_NIC_LPS_ENTER_FLOW);
 
 	/* 2. 0x1F[7:0] = 0 */
 	/* turn off RF */
@@ -1324,8 +1325,8 @@ static void _rtl8723be_poweroff_adapter(struct ieee80211_hw *hw)
 	rtl_write_byte(rtlpriv, REG_MCUFWDL, 0x00);
 
 	/* HW card disable configuration. */
-	rtl_hal_pwrseqcmdparsing(rtlpriv, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,
-				 PWR_INTF_PCI_MSK, RTL8723_NIC_DISABLE_FLOW);
+	rtlbe_hal_pwrseqcmdparsing(rtlpriv, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,
+				   PWR_INTF_PCI_MSK, RTL8723_NIC_DISABLE_FLOW);
 
 	/* Reset MCU IO Wrapper */
 	u1b_tmp = rtl_read_byte(rtlpriv, REG_RSV_CTRL + 1);
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/pwrseqcmd.c b/drivers/net/wireless/rtlwifi/rtl8723be/pwrseqcmd.c
index 4573310..cf57a49 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/pwrseqcmd.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/pwrseqcmd.c
@@ -23,6 +23,7 @@
  *
  *****************************************************************************/
 
+#include "pwrseqcmd.h"
 #include "pwrseq.h"
 
 /*	Description:
-- 
1.8.4.5
