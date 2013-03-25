From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 09/25] rtlwifi: Rework rtl_lps_leave() and rtl_lps_enter() to use work queue
Date: Sun, 24 Mar 2013 22:06:41 -0500
Message-ID: <1364180817-8028-10-git-send-email-Larry.Finger@lwfinger.net>
References: <1364180817-8028-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, jcheung@suse.com, machen@suse.com,
	mmarek@suse.cz, zhiyuan_yang@realsil.com.cn, page_he@realsil.com.cn
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:64738 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756230Ab3CYDH3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Mar 2013 23:07:29 -0400
In-Reply-To: <1364180817-8028-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit a5ffbe0, some of the calls to rtl_lps_leave() were switched
to be called from a work queue to avoid a scheduling while atomic bug.
This patch converts the remaining calls to use the work queue. In
addition, the call to rtl_lps_enter() is also switched to the work
queue. None of these newly converted calls had triggered the bug (yet),
but this change make all of them fit a single pattern.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: jcheung@suse.com
Cc: machen@suse.com
Cc: mmarek@suse.cz
Cc: zhiyuan_yang@realsil.com.cn
Cc: page_he@realsil.com.cn
---
 drivers/net/wireless/rtlwifi/base.c | 19 +++++++++----------
 drivers/net/wireless/rtlwifi/core.c |  9 ++++++---
 drivers/net/wireless/rtlwifi/pci.c  | 27 +++++++++++++++++----------
 drivers/net/wireless/rtlwifi/wifi.h |  3 ++-
 4 files changed, 34 insertions(+), 24 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/base.c b/drivers/net/wireless/rtlwifi/base.c
index 270b27a..f8a2d9f 100644
--- a/drivers/net/wireless/rtlwifi/base.c
+++ b/drivers/net/wireless/rtlwifi/base.c
@@ -1088,8 +1088,9 @@ u8 rtl_is_special_data(struct ieee80211_hw *hw, struct sk_buff *skb, u8 is_tx)
 					 is_tx ? "Tx" : "Rx");
 
 				if (is_tx) {
+					rtlpriv->enter_ps = false;
 					schedule_work(&rtlpriv->
-						      works.lps_leave_work);
+						      works.lps_change_work);
 					ppsc->last_delaylps_stamp_jiffies =
 					    jiffies;
 				}
@@ -1099,7 +1100,8 @@ u8 rtl_is_special_data(struct ieee80211_hw *hw, struct sk_buff *skb, u8 is_tx)
 		}
 	} else if (ETH_P_ARP == ether_type) {
 		if (is_tx) {
-			schedule_work(&rtlpriv->works.lps_leave_work);
+			rtlpriv->enter_ps = false;
+			schedule_work(&rtlpriv->works.lps_change_work);
 			ppsc->last_delaylps_stamp_jiffies = jiffies;
 		}
 
@@ -1109,7 +1111,8 @@ u8 rtl_is_special_data(struct ieee80211_hw *hw, struct sk_buff *skb, u8 is_tx)
 			 "802.1X %s EAPOL pkt!!\n", is_tx ? "Tx" : "Rx");
 
 		if (is_tx) {
-			schedule_work(&rtlpriv->works.lps_leave_work);
+			rtlpriv->enter_ps = false;
+			schedule_work(&rtlpriv->works.lps_change_work);
 			ppsc->last_delaylps_stamp_jiffies = jiffies;
 		}
 
@@ -1318,7 +1321,6 @@ void rtl_watchdog_wq_callback(void *data)
 	u32 aver_tx_cnt_inperiod = 0;
 	u32 aver_tidtx_inperiod[MAX_TID_COUNT] = {0};
 	u32 tidtx_inp4eriod[MAX_TID_COUNT] = {0};
-	bool enter_ps = false;
 
 	if (is_hal_stop(rtlhal))
 		return;
@@ -1400,15 +1402,12 @@ void rtl_watchdog_wq_callback(void *data)
 		if (((rtlpriv->link_info.num_rx_inperiod +
 		      rtlpriv->link_info.num_tx_inperiod) > 8) ||
 		    (rtlpriv->link_info.num_rx_inperiod > 2))
-			enter_ps = false;
+			rtlpriv->enter_ps = true;
 		else
-			enter_ps = true;
+			rtlpriv->enter_ps = false;
 
 		/* LeisurePS only work in infra mode. */
-		if (enter_ps)
-			rtl_lps_enter(hw);
-		else
-			schedule_work(&rtlpriv->works.lps_leave_work);
+		schedule_work(&rtlpriv->works.lps_change_work);
 	}
 
 	rtlpriv->link_info.num_rx_inperiod = 0;
diff --git a/drivers/net/wireless/rtlwifi/core.c b/drivers/net/wireless/rtlwifi/core.c
index 470a67d..3706182 100644
--- a/drivers/net/wireless/rtlwifi/core.c
+++ b/drivers/net/wireless/rtlwifi/core.c
@@ -742,8 +742,10 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
 			RT_TRACE(rtlpriv, COMP_MAC80211, DBG_DMESG,
 				 "BSS_CHANGED_ASSOC\n");
 		} else {
-			if (mac->link_state == MAC80211_LINKED)
-				schedule_work(&rtlpriv->works.lps_leave_work);
+			if (mac->link_state == MAC80211_LINKED) {
+				rtlpriv->enter_ps = false;
+				schedule_work(&rtlpriv->works.lps_change_work);
+			}
 
 			if (ppsc->p2p_ps_info.p2p_ps_mode > P2P_PS_NONE)
 				rtl_p2p_ps_cmd(hw, P2P_PS_DISABLE);
@@ -1018,7 +1020,8 @@ static void rtl_op_sw_scan_start(struct ieee80211_hw *hw)
 			rtlpriv->cfg->ops->chk_switch_dmdp(hw);
 	}
 	if (mac->link_state == MAC80211_LINKED) {
-		schedule_work(&rtlpriv->works.lps_leave_work);
+		rtlpriv->enter_ps = false;
+		schedule_work(&rtlpriv->works.lps_change_work);
 		mac->link_state = MAC80211_LINKED_SCANNING;
 	} else {
 		rtl_ips_nic_on(hw);
diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlwifi/pci.c
index 4af6abd..b449d41 100644
--- a/drivers/net/wireless/rtlwifi/pci.c
+++ b/drivers/net/wireless/rtlwifi/pci.c
@@ -654,7 +654,8 @@ tx_status_ok:
 	if (((rtlpriv->link_info.num_rx_inperiod +
 		rtlpriv->link_info.num_tx_inperiod) > 8) ||
 		(rtlpriv->link_info.num_rx_inperiod > 2)) {
-		schedule_work(&rtlpriv->works.lps_leave_work);
+		rtlpriv->enter_ps = false;
+		schedule_work(&rtlpriv->works.lps_change_work);
 	}
 }
 
@@ -783,9 +784,10 @@ static void _rtl_pci_rx_interrupt(struct ieee80211_hw *hw)
 		_rtl_receive_one(hw, skb, rx_status);
 
 		if (((rtlpriv->link_info.num_rx_inperiod +
-			rtlpriv->link_info.num_tx_inperiod) > 8) ||
-			(rtlpriv->link_info.num_rx_inperiod > 2)) {
-			schedule_work(&rtlpriv->works.lps_leave_work);
+		      rtlpriv->link_info.num_tx_inperiod) > 8) ||
+		      (rtlpriv->link_info.num_rx_inperiod > 2)) {
+			rtlpriv->enter_ps = false;
+			schedule_work(&rtlpriv->works.lps_change_work);
 		}
 
 		dev_kfree_skb_any(skb);
@@ -1005,13 +1007,17 @@ static void _rtl_pci_prepare_bcn_tasklet(struct ieee80211_hw *hw)
 	return;
 }
 
-static void rtl_lps_leave_work_callback(struct work_struct *work)
+static void rtl_lps_change_work_callback(struct work_struct *work)
 {
 	struct rtl_works *rtlworks =
-	    container_of(work, struct rtl_works, lps_leave_work);
+	    container_of(work, struct rtl_works, lps_change_work);
 	struct ieee80211_hw *hw = rtlworks->hw;
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
-	rtl_lps_leave(hw);
+	if (rtlpriv->enter_ps)
+		rtl_lps_enter(hw);
+	else
+		rtl_lps_leave(hw);
 }
 
 static void _rtl_pci_init_trx_var(struct ieee80211_hw *hw)
@@ -1075,7 +1081,8 @@ static void _rtl_pci_init_struct(struct ieee80211_hw *hw,
 	tasklet_init(&rtlpriv->works.irq_prepare_bcn_tasklet,
 		     (void (*)(unsigned long))_rtl_pci_prepare_bcn_tasklet,
 		     (unsigned long)hw);
-	INIT_WORK(&rtlpriv->works.lps_leave_work, rtl_lps_leave_work_callback);
+	INIT_WORK(&rtlpriv->works.lps_change_work,
+		  rtl_lps_change_work_callback);
 }
 
 static int _rtl_pci_init_tx_ring(struct ieee80211_hw *hw,
@@ -1561,7 +1568,7 @@ static void rtl_pci_deinit(struct ieee80211_hw *hw)
 
 	synchronize_irq(rtlpci->pdev->irq);
 	tasklet_kill(&rtlpriv->works.irq_tasklet);
-	cancel_work_sync(&rtlpriv->works.lps_leave_work);
+	cancel_work_sync(&rtlpriv->works.lps_change_work);
 
 	flush_workqueue(rtlpriv->works.rtl_wq);
 	destroy_workqueue(rtlpriv->works.rtl_wq);
@@ -1636,7 +1643,7 @@ static void rtl_pci_stop(struct ieee80211_hw *hw)
 	set_hal_stop(rtlhal);
 
 	rtlpriv->cfg->ops->disable_interrupt(hw);
-	cancel_work_sync(&rtlpriv->works.lps_leave_work);
+	cancel_work_sync(&rtlpriv->works.lps_change_work);
 
 	spin_lock_irqsave(&rtlpriv->locks.rf_ps_lock, flags);
 	while (ppsc->rfchange_inprogress) {
diff --git a/drivers/net/wireless/rtlwifi/wifi.h b/drivers/net/wireless/rtlwifi/wifi.h
index 7ec95cb..70193a5 100644
--- a/drivers/net/wireless/rtlwifi/wifi.h
+++ b/drivers/net/wireless/rtlwifi/wifi.h
@@ -1796,7 +1796,7 @@ struct rtl_works {
 	struct delayed_work ps_rfon_wq;
 	struct delayed_work fwevt_wq;
 
-	struct work_struct lps_leave_work;
+	struct work_struct lps_change_work;
 };
 
 struct rtl_debug {
@@ -1966,6 +1966,7 @@ struct rtl_priv {
 			bool bt_operation_on;
 		};
 	};
+	bool enter_ps;	/* true when entering PS */
 
 	/*This must be the last item so
 	   that it points to the data allocated
-- 
1.8.1.4
