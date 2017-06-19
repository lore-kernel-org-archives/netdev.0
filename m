From: Joe Perches <joe@perches.com>
Subject: [PATCH 3/5] rtlwifi: Add and use convenience macro rtl_btc
Date: Mon, 19 Jun 2017 13:18:16 -0700
Message-ID: <31d4adfdbdfebdf09a9a765184267fb04e014a9a.1497903396.git.joe@perches.com>
References: <cover.1497903396.git.joe@perches.com>
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>,
        Chaoming Li <chaoming_li@realsil.com.cn>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1497903396.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

bluetooth coexistence functions always check get_btc_status before
accessing the function.  Centralize this via a convenience macro
to neaten the source code a little.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/realtek/rtlwifi/base.c |  8 ++------
 drivers/net/wireless/realtek/rtlwifi/core.c | 12 +++---------
 drivers/net/wireless/realtek/rtlwifi/pci.c  |  4 +---
 drivers/net/wireless/realtek/rtlwifi/ps.c   | 24 ++++++++++--------------
 drivers/net/wireless/realtek/rtlwifi/wifi.h |  7 +++++++
 5 files changed, 23 insertions(+), 32 deletions(-)

diff --git a/drivers/net/wireless/realtek/rtlwifi/base.c b/drivers/net/wireless/realtek/rtlwifi/base.c
index cc4b50e1b7e5..997dd692e6bb 100644
--- a/drivers/net/wireless/realtek/rtlwifi/base.c
+++ b/drivers/net/wireless/realtek/rtlwifi/base.c
@@ -1312,11 +1312,9 @@ static void setup_arp_tx(struct rtl_priv *rtlpriv, struct rtl_ps_ctl *ppsc)
 {
 	struct ieee80211_hw *hw = rtlpriv->hw;
 	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
-	struct rtl_btc_ops *btc_ops = rtlpriv->btcoexist.btc_ops;
 
 	rtlpriv->ra.is_special_data = true;
-	if (ops->get_btc_status())
-		btc_ops->btc_special_packet_notify(rtlpriv, 1);
+	rtl_btc(rtlpriv, ops, btc_special_packet_notify(rtlpriv, 1));
 	rtl_lps_leave(hw);
 	ppsc->last_delaylps_stamp_jiffies = jiffies;
 }
@@ -1575,7 +1573,6 @@ void rtl_watchdog_wq_callback(void *data)
 	struct ieee80211_hw *hw = rtlworks->hw;
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
-	struct rtl_btc_ops *btc_ops = rtlpriv->btcoexist.btc_ops;
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	bool busytraffic = false;
@@ -1714,8 +1711,7 @@ void rtl_watchdog_wq_callback(void *data)
 		}
 	}
 
-	if (ops->get_btc_status())
-		btc_ops->btc_periodical(rtlpriv);
+	rtl_btc(rtlpriv, ops, btc_periodical(rtlpriv));
 
 	rtlpriv->link_info.bcn_rx_inperiod = 0;
 }
diff --git a/drivers/net/wireless/realtek/rtlwifi/core.c b/drivers/net/wireless/realtek/rtlwifi/core.c
index e08febc2d0d6..8d3eddeeffea 100644
--- a/drivers/net/wireless/realtek/rtlwifi/core.c
+++ b/drivers/net/wireless/realtek/rtlwifi/core.c
@@ -1046,7 +1046,6 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
-	struct rtl_btc_ops *btc_ops = rtlpriv->btcoexist.btc_ops;
 	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
@@ -1193,8 +1192,7 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
 		ppsc->report_linked = (mstatus == RT_MEDIA_CONNECT) ?
 				      true : false;
 
-		if (ops->get_btc_status())
-			btc_ops->btc_mediastatus_notify(rtlpriv, mstatus);
+		rtl_btc(rtlpriv, ops, btc_mediastatus_notify(rtlpriv, mstatus));
 	}
 
 	if (changed & BSS_CHANGED_ERP_CTS_PROT) {
@@ -1428,7 +1426,6 @@ static void rtl_op_sw_scan_start(struct ieee80211_hw *hw,
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
-	struct rtl_btc_ops *btc_ops = rtlpriv->btcoexist.btc_ops;
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 
 	RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD, "\n");
@@ -1438,8 +1435,7 @@ static void rtl_op_sw_scan_start(struct ieee80211_hw *hw,
 		return;
 	}
 
-	if (ops->get_btc_status())
-		btc_ops->btc_scan_notify(rtlpriv, 1);
+	rtl_btc(rtlpriv, ops, btc_scan_notify(rtlpriv, 1));
 
 	if (rtlpriv->dm.supp_phymode_switch) {
 		if (ops->chk_switch_dmdp)
@@ -1465,7 +1461,6 @@ static void rtl_op_sw_scan_complete(struct ieee80211_hw *hw,
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
-	struct rtl_btc_ops *btc_ops = rtlpriv->btcoexist.btc_ops;
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 
 	RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD, "\n");
@@ -1492,8 +1487,7 @@ static void rtl_op_sw_scan_complete(struct ieee80211_hw *hw,
 	}
 
 	ops->scan_operation_backup(hw, SCAN_OPT_RESTORE);
-	if (ops->get_btc_status())
-		btc_ops->btc_scan_notify(rtlpriv, 0);
+	rtl_btc(rtlpriv, ops, btc_scan_notify(rtlpriv, 0));
 }
 
 static int rtl_op_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
diff --git a/drivers/net/wireless/realtek/rtlwifi/pci.c b/drivers/net/wireless/realtek/rtlwifi/pci.c
index f129c4c76c05..fa93401acdab 100644
--- a/drivers/net/wireless/realtek/rtlwifi/pci.c
+++ b/drivers/net/wireless/realtek/rtlwifi/pci.c
@@ -1859,15 +1859,13 @@ static void rtl_pci_stop(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
-	struct rtl_btc_ops *btc_ops = rtlpriv->btcoexist.btc_ops;
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 	unsigned long flags;
 	u8 RFInProgressTimeOut = 0;
 
-	if (ops->get_btc_status())
-		btc_ops->btc_halt_notify();
+	rtl_btc(rtlpriv, ops, btc_halt_notify());
 
 	/*
 	 *should be before disable interrupt&adapter
diff --git a/drivers/net/wireless/realtek/rtlwifi/ps.c b/drivers/net/wireless/realtek/rtlwifi/ps.c
index 3cd8a387c845..8babc4a70ac2 100644
--- a/drivers/net/wireless/realtek/rtlwifi/ps.c
+++ b/drivers/net/wireless/realtek/rtlwifi/ps.c
@@ -210,7 +210,6 @@ void rtl_ips_nic_off_wq_callback(void *data)
 	struct ieee80211_hw *hw = rtlworks->hw;
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
-	struct rtl_btc_ops *btc_ops = rtlpriv->btcoexist.btc_ops;
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
@@ -261,9 +260,9 @@ void rtl_ips_nic_off_wq_callback(void *data)
 			ppsc->in_powersavemode = true;
 
 			/* call before RF off */
-			if (ops->get_btc_status())
-				btc_ops->btc_ips_notify(rtlpriv,
-							ppsc->inactive_pwrstate);
+			rtl_btc(rtlpriv, ops,
+				btc_ips_notify(rtlpriv,
+					       ppsc->inactive_pwrstate));
 
 			/*rtl_pci_reset_trx_ring(hw); */
 			_rtl_ps_inactive_ps(hw);
@@ -290,7 +289,6 @@ void rtl_ips_nic_on(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
-	struct rtl_btc_ops *btc_ops = rtlpriv->btcoexist.btc_ops;
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
 	enum rf_pwrstate rtstate;
 
@@ -308,9 +306,9 @@ void rtl_ips_nic_on(struct ieee80211_hw *hw)
 			ppsc->in_powersavemode = false;
 			_rtl_ps_inactive_ps(hw);
 			/* call after RF on */
-			if (ops->get_btc_status())
-				btc_ops->btc_ips_notify(rtlpriv,
-							ppsc->inactive_pwrstate);
+			rtl_btc(rtlpriv, ops,
+				btc_ips_notify(rtlpriv,
+					       ppsc->inactive_pwrstate));
 		}
 	}
 	spin_unlock(&rtlpriv->locks.ips_lock);
@@ -354,7 +352,6 @@ void rtl_lps_set_psmode(struct ieee80211_hw *hw, u8 rt_psmode)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
-	struct rtl_btc_ops *btc_ops = rtlpriv->btcoexist.btc_ops;
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
 	bool enter_fwlps;
@@ -394,16 +391,15 @@ void rtl_lps_set_psmode(struct ieee80211_hw *hw, u8 rt_psmode)
 			if (ppsc->p2p_ps_info.opp_ps)
 				rtl_p2p_ps_cmd(hw , P2P_PS_ENABLE);
 
-			if (ops->get_btc_status())
-				btc_ops->btc_lps_notify(rtlpriv, rt_psmode);
+			rtl_btc(rtlpriv, ops,
+				btc_lps_notify(rtlpriv, rt_psmode));
 		} else {
 			if (rtl_get_fwlps_doze(hw)) {
 				RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
 					 "FW LPS enter ps_mode:%x\n",
 					 ppsc->fwctrl_psmode);
-				if (ops->get_btc_status())
-					btc_ops->btc_lps_notify(rtlpriv,
-								rt_psmode);
+				rtl_btc(rtlpriv, ops,
+					btc_lps_notify(rtlpriv, rt_psmode));
 				enter_fwlps = true;
 				ppsc->pwr_mode = ppsc->fwctrl_psmode;
 				ppsc->smart_ps = 2;
diff --git a/drivers/net/wireless/realtek/rtlwifi/wifi.h b/drivers/net/wireless/realtek/rtlwifi/wifi.h
index c0d2601bc55f..9a916188a703 100644
--- a/drivers/net/wireless/realtek/rtlwifi/wifi.h
+++ b/drivers/net/wireless/realtek/rtlwifi/wifi.h
@@ -2552,6 +2552,13 @@ struct rtl_btc_ops {
 					  u8 pkt_type);
 };
 
+/* Convenience macro for accessing rtl_btc_ops() functions */
+#define rtl_btc(rtlpriv, ops, func)					\
+do {									\
+	if ((ops)->get_btc_status())					\
+		(rtlpriv)->btcoexist.btc_ops->func;			\
+} while (0)
+
 struct proxim {
 	bool proxim_on;
 
-- 
2.10.0.rc2.1.g053435c
