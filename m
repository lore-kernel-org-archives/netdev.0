From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [RFC/RFT 09/27] rtlwifi: Rework rtl_lps_leave() and rtl_lps_enter() to use work queue
Date: Mon, 25 Feb 2013 18:13:21 -0600
Message-ID: <1361837619-2985-10-git-send-email-Larry.Finger@lwfinger.net>
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

In commit a5ffbe0, some of the calls to rtl_lps_leave() were switched
to be called from a work queue to avoid a scheduling while atomic bug.
This patch converts the remaining calls to use the work queue. In
addition, the call to rtl_lps_enter() is also switched to the work
queue. None of these newly converted calls had triggered the bug (yet),
but this change make all of them fit a single pattern.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Cc: jcheung-IBi9RG/b67k@public.gmane.org
Cc: machen-IBi9RG/b67k@public.gmane.org
Cc: mmarek-AlSwsSmVLrQ@public.gmane.org
---
 drivers/net/wireless/rtlwifi/base.c | 19 +++++++++----------
 drivers/net/wireless/rtlwifi/core.c |  9 ++++++---
 drivers/net/wireless/rtlwifi/pci.c  | 26 +++++++++++++++++---------
 drivers/net/wireless/rtlwifi/wifi.h |  3 ++-
 4 files changed, 34 insertions(+), 23 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/base.c b/drivers/net/wireless/rtlwifi/base.c
index acea8e8..e5b14b8 100644
--- a/drivers/net/wireless/rtlwifi/base.c
+++ b/drivers/net/wireless/rtlwifi/base.c
@@ -1086,8 +1086,9 @@ u8 rtl_is_special_data(struct ieee80211_hw *hw, struct sk_buff *skb, u8 is_tx)
 					 is_tx ? "Tx" : "Rx");
 
 				if (is_tx) {
+					rtlpriv->enter_ps = false;
 					schedule_work(&rtlpriv->
-						      works.lps_leave_work);
+						      works.lps_change_work);
 					ppsc->last_delaylps_stamp_jiffies =
 					    jiffies;
 				}
@@ -1097,7 +1098,8 @@ u8 rtl_is_special_data(struct ieee80211_hw *hw, struct sk_buff *skb, u8 is_tx)
 		}
 	} else if (ETH_P_ARP == ether_type) {
 		if (is_tx) {
-			schedule_work(&rtlpriv->works.lps_leave_work);
+			rtlpriv->enter_ps = false;
+			schedule_work(&rtlpriv->works.lps_change_work);
 			ppsc->last_delaylps_stamp_jiffies = jiffies;
 		}
 
@@ -1107,7 +1109,8 @@ u8 rtl_is_special_data(struct ieee80211_hw *hw, struct sk_buff *skb, u8 is_tx)
 			 "802.1X %s EAPOL pkt!!\n", is_tx ? "Tx" : "Rx");
 
 		if (is_tx) {
-			schedule_work(&rtlpriv->works.lps_leave_work);
+			rtlpriv->enter_ps = false;
+			schedule_work(&rtlpriv->works.lps_change_work);
 			ppsc->last_delaylps_stamp_jiffies = jiffies;
 		}
 
@@ -1316,7 +1319,6 @@ void rtl_watchdog_wq_callback(void *data)
 	u32 aver_tx_cnt_inperiod = 0;
 	u32 aver_tidtx_inperiod[MAX_TID_COUNT] = {0};
 	u32 tidtx_inp4eriod[MAX_TID_COUNT] = {0};
-	bool enter_ps = false;
 
 	if (is_hal_stop(rtlhal))
 		return;
@@ -1398,15 +1400,12 @@ void rtl_watchdog_wq_callback(void *data)
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
index 70c2497..3bd98f7 100644
--- a/drivers/net/wireless/rtlwifi/pci.c
+++ b/drivers/net/wireless/rtlwifi/pci.c
@@ -655,7 +655,8 @@ tx_status_ok:
 	if (((rtlpriv->link_info.num_rx_inperiod +
 		rtlpriv->link_info.num_tx_inperiod) > 8) ||
 		(rtlpriv->link_info.num_rx_inperiod > 2)) {
-		schedule_work(&rtlpriv->works.lps_leave_work);
+		rtlpriv->enter_ps = false;
+		schedule_work(&rtlpriv->works.lps_change_work);
 	}
 }
 
@@ -837,8 +838,10 @@ static void _rtl_pci_rx_interrupt(struct ieee80211_hw *hw)
 
 			if (((rtlpriv->link_info.num_rx_inperiod +
 			      rtlpriv->link_info.num_tx_inperiod) > 8) ||
-			      (rtlpriv->link_info.num_rx_inperiod > 2))
-				schedule_work(&rtlpriv->works.lps_leave_work);
+			      (rtlpriv->link_info.num_rx_inperiod > 2)) {
+				rtlpriv->enter_ps = false;
+				schedule_work(&rtlpriv->works.lps_change_work);
+			}
 
 			_rtl_pci_init_one_rxdesc(hw, pdesc, rxring_idx,
 				rtlpci->rx_ring[rxring_idx].idx);
@@ -1029,13 +1032,17 @@ static void _rtl_pci_prepare_bcn_tasklet(struct ieee80211_hw *hw)
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
@@ -1099,7 +1106,8 @@ static void _rtl_pci_init_struct(struct ieee80211_hw *hw,
 	tasklet_init(&rtlpriv->works.irq_prepare_bcn_tasklet,
 		     (void (*)(unsigned long))_rtl_pci_prepare_bcn_tasklet,
 		     (unsigned long)hw);
-	INIT_WORK(&rtlpriv->works.lps_leave_work, rtl_lps_leave_work_callback);
+	INIT_WORK(&rtlpriv->works.lps_change_work,
+		  rtl_lps_change_work_callback);
 }
 
 static int _rtl_pci_init_tx_ring(struct ieee80211_hw *hw,
@@ -1530,7 +1538,7 @@ static void rtl_pci_deinit(struct ieee80211_hw *hw)
 
 	synchronize_irq(rtlpci->pdev->irq);
 	tasklet_kill(&rtlpriv->works.irq_tasklet);
-	cancel_work_sync(&rtlpriv->works.lps_leave_work);
+	cancel_work_sync(&rtlpriv->works.lps_change_work);
 
 	flush_workqueue(rtlpriv->works.rtl_wq);
 	destroy_workqueue(rtlpriv->works.rtl_wq);
@@ -1605,7 +1613,7 @@ static void rtl_pci_stop(struct ieee80211_hw *hw)
 	set_hal_stop(rtlhal);
 
 	rtlpriv->cfg->ops->disable_interrupt(hw);
-	cancel_work_sync(&rtlpriv->works.lps_leave_work);
+	cancel_work_sync(&rtlpriv->works.lps_change_work);
 
 	spin_lock_irqsave(&rtlpriv->locks.rf_ps_lock, flags);
 	while (ppsc->rfchange_inprogress) {
diff --git a/drivers/net/wireless/rtlwifi/wifi.h b/drivers/net/wireless/rtlwifi/wifi.h
index a57b876..f6825c1 100644
--- a/drivers/net/wireless/rtlwifi/wifi.h
+++ b/drivers/net/wireless/rtlwifi/wifi.h
@@ -1794,7 +1794,7 @@ struct rtl_works {
 	struct delayed_work ps_rfon_wq;
 	struct delayed_work fwevt_wq;
 
-	struct work_struct lps_leave_work;
+	struct work_struct lps_change_work;
 };
 
 struct rtl_debug {
@@ -1964,6 +1964,7 @@ struct rtl_priv {
 			bool bt_operation_on;
 		};
 	};
+	bool enter_ps;	/* true when entering PS */
 
 	/*This must be the last item so
 	   that it points to the data allocated
-- 
1.8.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
