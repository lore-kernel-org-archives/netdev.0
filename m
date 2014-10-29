From: Murilo Opsfelder Araujo <mopsfelder@gmail.com>
Subject: [PATCH] rtlwifi: Add more checks for get_btc_status callback
Date: Wed, 29 Oct 2014 21:28:22 -0200
Message-ID: <1414625302-3654-1-git-send-email-mopsfelder@gmail.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	"John W. Linville" <linville@tuxdriver.com>,
	Mike Galbraith <umgwanakikbuti@gmail.com>,
	Thadeu Cascardo <cascardo@cascardo.eti.br>,
	troy_tan@realsil.com.cn,
	Murilo Opsfelder Araujo <mopsfelder@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a complement of commit 08054200117a95afc14c3d2ed3a38bf4e345bf78
"rtlwifi: Add check for get_btc_status callback".

With this patch, next-20141029 at least does not panic with rtl8192se
device.

Signed-off-by: Murilo Opsfelder Araujo <mopsfelder@gmail.com>
---

Hello, everyone.

Some days ago, I reported [1] that next-20140930 introduced an issue
with rtl8192se devices.

Later on, Larry Finger proposed [2] a fix that did not solve the
problem thoroughly.

This patch is based on Larry's one [3].  It also does not solve the
rtl8192se issue completely but I can at least boot next-20141029
without a panic.

The remaining issue is that the rtl8192se device does not associate.
It does not even show any wifi network available.  The device is shown
by iwconfig, but I cannot do anything with it.

I need help from someone out there that could provide me guidance or
possibly investigate the issue (I'm not a kernel expert yet).

I'd not like to see this regression landing on v3.18.

[1] http://marc.info/?l=linux-wireless&m=141403434929612
[2] http://marc.info/?l=linux-wireless&m=141408165513255
[3] http://marc.info/?l=linux-wireless&m=141416876810127

 drivers/net/wireless/rtlwifi/base.c |  6 ++++--
 drivers/net/wireless/rtlwifi/core.c |  9 ++++++---
 drivers/net/wireless/rtlwifi/pci.c  |  3 ++-
 drivers/net/wireless/rtlwifi/ps.c   | 12 ++++++++----
 4 files changed, 20 insertions(+), 10 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/base.c b/drivers/net/wireless/rtlwifi/base.c
index 40b6d1d..1a51577 100644
--- a/drivers/net/wireless/rtlwifi/base.c
+++ b/drivers/net/wireless/rtlwifi/base.c
@@ -1234,7 +1234,8 @@ EXPORT_SYMBOL_GPL(rtl_action_proc);
 static void setup_arp_tx(struct rtl_priv *rtlpriv, struct rtl_ps_ctl *ppsc)
 {
 	rtlpriv->ra.is_special_data = true;
-	if (rtlpriv->cfg->ops->get_btc_status())
+	if (rtlpriv->cfg->ops->get_btc_status &&
+	    rtlpriv->cfg->ops->get_btc_status())
 		rtlpriv->btcoexist.btc_ops->btc_special_packet_notify(
 					rtlpriv, 1);
 	rtlpriv->enter_ps = false;
@@ -1629,7 +1630,8 @@ void rtl_watchdog_wq_callback(void *data)
 		}
 	}

-	if (rtlpriv->cfg->ops->get_btc_status())
+	if (rtlpriv->cfg->ops->get_btc_status &&
+	    rtlpriv->cfg->ops->get_btc_status())
 		rtlpriv->btcoexist.btc_ops->btc_periodical(rtlpriv);

 	rtlpriv->link_info.bcn_rx_inperiod = 0;
diff --git a/drivers/net/wireless/rtlwifi/core.c b/drivers/net/wireless/rtlwifi/core.c
index f6179bc..686d256 100644
--- a/drivers/net/wireless/rtlwifi/core.c
+++ b/drivers/net/wireless/rtlwifi/core.c
@@ -1133,7 +1133,8 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
 		ppsc->report_linked = (mstatus == RT_MEDIA_CONNECT) ?
 				      true : false;

-		if (rtlpriv->cfg->ops->get_btc_status())
+		if (rtlpriv->cfg->ops->get_btc_status &&
+		    rtlpriv->cfg->ops->get_btc_status())
 			rtlpriv->btcoexist.btc_ops->btc_mediastatus_notify(
 							rtlpriv, mstatus);
 	}
@@ -1373,7 +1374,8 @@ static void rtl_op_sw_scan_start(struct ieee80211_hw *hw)
 		return;
 	}

-	if (rtlpriv->cfg->ops->get_btc_status())
+	if (rtlpriv->cfg->ops->get_btc_status &&
+	    rtlpriv->cfg->ops->get_btc_status())
 		rtlpriv->btcoexist.btc_ops->btc_scan_notify(rtlpriv, 1);

 	if (rtlpriv->dm.supp_phymode_switch) {
@@ -1425,7 +1427,8 @@ static void rtl_op_sw_scan_complete(struct ieee80211_hw *hw)
 	}

 	rtlpriv->cfg->ops->scan_operation_backup(hw, SCAN_OPT_RESTORE);
-	if (rtlpriv->cfg->ops->get_btc_status())
+	if (rtlpriv->cfg->ops->get_btc_status &&
+	    rtlpriv->cfg->ops->get_btc_status())
 		rtlpriv->btcoexist.btc_ops->btc_scan_notify(rtlpriv, 0);
 }

diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlwifi/pci.c
index 25daa87..ed3364d 100644
--- a/drivers/net/wireless/rtlwifi/pci.c
+++ b/drivers/net/wireless/rtlwifi/pci.c
@@ -1833,7 +1833,8 @@ static void rtl_pci_stop(struct ieee80211_hw *hw)
 	unsigned long flags;
 	u8 RFInProgressTimeOut = 0;

-	if (rtlpriv->cfg->ops->get_btc_status())
+	if (rtlpriv->cfg->ops->get_btc_status &&
+	    rtlpriv->cfg->ops->get_btc_status())
 		rtlpriv->btcoexist.btc_ops->btc_halt_notify();

 	/*
diff --git a/drivers/net/wireless/rtlwifi/ps.c b/drivers/net/wireless/rtlwifi/ps.c
index b69321d..2278af9 100644
--- a/drivers/net/wireless/rtlwifi/ps.c
+++ b/drivers/net/wireless/rtlwifi/ps.c
@@ -261,7 +261,8 @@ void rtl_ips_nic_off_wq_callback(void *data)
 			ppsc->in_powersavemode = true;

 			/* call before RF off */
-			if (rtlpriv->cfg->ops->get_btc_status())
+			if (rtlpriv->cfg->ops->get_btc_status &&
+			    rtlpriv->cfg->ops->get_btc_status())
 				rtlpriv->btcoexist.btc_ops->btc_ips_notify(rtlpriv,
 									ppsc->inactive_pwrstate);

@@ -306,7 +307,8 @@ void rtl_ips_nic_on(struct ieee80211_hw *hw)
 			ppsc->in_powersavemode = false;
 			_rtl_ps_inactive_ps(hw);
 			/* call after RF on */
-			if (rtlpriv->cfg->ops->get_btc_status())
+			if (rtlpriv->cfg->ops->get_btc_status &&
+			    rtlpriv->cfg->ops->get_btc_status())
 				rtlpriv->btcoexist.btc_ops->btc_ips_notify(rtlpriv,
 									ppsc->inactive_pwrstate);
 		}
@@ -390,14 +392,16 @@ void rtl_lps_set_psmode(struct ieee80211_hw *hw, u8 rt_psmode)
 			if (ppsc->p2p_ps_info.opp_ps)
 				rtl_p2p_ps_cmd(hw , P2P_PS_ENABLE);

-			if (rtlpriv->cfg->ops->get_btc_status())
+			if (rtlpriv->cfg->ops->get_btc_status &&
+			    rtlpriv->cfg->ops->get_btc_status())
 				rtlpriv->btcoexist.btc_ops->btc_lps_notify(rtlpriv, rt_psmode);
 		} else {
 			if (rtl_get_fwlps_doze(hw)) {
 				RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
 					 "FW LPS enter ps_mode:%x\n",
 					 ppsc->fwctrl_psmode);
-				if (rtlpriv->cfg->ops->get_btc_status())
+				if (rtlpriv->cfg->ops->get_btc_status &&
+				    rtlpriv->cfg->ops->get_btc_status())
 					rtlpriv->btcoexist.btc_ops->btc_lps_notify(rtlpriv, rt_psmode);
 				enter_fwlps = true;
 				ppsc->pwr_mode = ppsc->fwctrl_psmode;
--
2.1.2
