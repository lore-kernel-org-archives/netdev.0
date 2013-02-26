From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [RFC/RFT 02/27] rtlwifi: Modify files for 2013.02.07 vendor version - part 2
Date: Mon, 25 Feb 2013 18:13:14 -0600
Message-ID: <1361837619-2985-3-git-send-email-Larry.Finger@lwfinger.net>
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

This patch updates files base.{c,h} for the changes in the newest vendor
driver.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Cc: jcheung-IBi9RG/b67k@public.gmane.org
Cc: machen-IBi9RG/b67k@public.gmane.org
Cc: mmarek-AlSwsSmVLrQ@public.gmane.org
---
 drivers/net/wireless/rtlwifi/base.c | 359 +++++++++++++++++++++++++++++++-----
 drivers/net/wireless/rtlwifi/base.h |  14 +-
 drivers/net/wireless/rtlwifi/wifi.h |   2 +-
 3 files changed, 329 insertions(+), 46 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/base.c b/drivers/net/wireless/rtlwifi/base.c
index 99c5cea..acea8e8 100644
--- a/drivers/net/wireless/rtlwifi/base.c
+++ b/drivers/net/wireless/rtlwifi/base.c
@@ -54,7 +54,8 @@
  *5) frame process functions
  *6) IOT functions
  *7) sysfs functions
- *8) ...
+ *8) vif functions
+ *9) ...
  */
 
 /*********************************************************
@@ -198,34 +199,46 @@ static void _rtl_init_hw_ht_capab(struct ieee80211_hw *hw,
 
 	ht_cap->mcs.tx_params = IEEE80211_HT_MCS_TX_DEFINED;
 
-	/*
-	 *hw->wiphy->bands[IEEE80211_BAND_2GHZ]
+	/*hw->wiphy->bands[IEEE80211_BAND_2GHZ]
 	 *base on ant_num
 	 *rx_mask: RX mask
-	 *if rx_ant =1 rx_mask[0]=0xff;==>MCS0-MCS7
-	 *if rx_ant =2 rx_mask[1]=0xff;==>MCS8-MCS15
-	 *if rx_ant >=3 rx_mask[2]=0xff;
-	 *if BW_40 rx_mask[4]=0x01;
+	 *if rx_ant = 1 rx_mask[0]= 0xff;==>MCS0-MCS7
+	 *if rx_ant = 2 rx_mask[1]= 0xff;==>MCS8-MCS15
+	 *if rx_ant >= 3 rx_mask[2]= 0xff;
+	 *if BW_40 rx_mask[4]= 0x01;
 	 *highest supported RX rate
 	 */
-	if (get_rf_type(rtlphy) == RF_1T2R || get_rf_type(rtlphy) == RF_2T2R) {
+	if (rtlpriv->dm.supp_phymode_switch) {
 
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "1T2R or 2T2R\n");
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_EMERG,
+			 "Support phy mode switch\n");
 
 		ht_cap->mcs.rx_mask[0] = 0xFF;
 		ht_cap->mcs.rx_mask[1] = 0xFF;
 		ht_cap->mcs.rx_mask[4] = 0x01;
 
 		ht_cap->mcs.rx_highest = cpu_to_le16(MAX_BIT_RATE_40MHZ_MCS15);
-	} else if (get_rf_type(rtlphy) == RF_1T1R) {
-
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "1T1R\n");
-
-		ht_cap->mcs.rx_mask[0] = 0xFF;
-		ht_cap->mcs.rx_mask[1] = 0x00;
-		ht_cap->mcs.rx_mask[4] = 0x01;
-
-		ht_cap->mcs.rx_highest = cpu_to_le16(MAX_BIT_RATE_40MHZ_MCS7);
+	} else {
+		if (get_rf_type(rtlphy) == RF_1T2R ||
+		    get_rf_type(rtlphy) == RF_2T2R) {
+			RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
+				 "1T2R or 2T2R\n");
+			ht_cap->mcs.rx_mask[0] = 0xFF;
+			ht_cap->mcs.rx_mask[1] = 0xFF;
+			ht_cap->mcs.rx_mask[4] = 0x01;
+
+			ht_cap->mcs.rx_highest =
+				 cpu_to_le16(MAX_BIT_RATE_40MHZ_MCS15);
+		} else if (get_rf_type(rtlphy) == RF_1T1R) {
+			RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "1T1R\n");
+
+			ht_cap->mcs.rx_mask[0] = 0xFF;
+			ht_cap->mcs.rx_mask[1] = 0x00;
+			ht_cap->mcs.rx_mask[4] = 0x01;
+
+			ht_cap->mcs.rx_highest =
+				 cpu_to_le16(MAX_BIT_RATE_40MHZ_MCS7);
+		}
 	}
 }
 
@@ -311,6 +324,8 @@ static void _rtl_init_mac80211(struct ieee80211_hw *hw)
 	    IEEE80211_HW_AMPDU_AGGREGATION |
 	    IEEE80211_HW_CONNECTION_MONITOR |
 	    /* IEEE80211_HW_SUPPORTS_CQM_RSSI | */
+	    IEEE80211_HW_CONNECTION_MONITOR |
+	    IEEE80211_HW_MFP_CAPABLE |
 	    IEEE80211_HW_REPORTS_TX_ACK_STATUS | 0;
 
 	/* swlps or hwlps has been set in diff chip in init_sw_vars */
@@ -323,8 +338,12 @@ static void _rtl_init_mac80211(struct ieee80211_hw *hw)
 	hw->wiphy->interface_modes =
 	    BIT(NL80211_IFTYPE_AP) |
 	    BIT(NL80211_IFTYPE_STATION) |
-	    BIT(NL80211_IFTYPE_ADHOC);
+	    BIT(NL80211_IFTYPE_ADHOC) |
+	    BIT(NL80211_IFTYPE_MESH_POINT) |
+	    BIT(NL80211_IFTYPE_P2P_CLIENT) |
+	    BIT(NL80211_IFTYPE_P2P_GO);
 
+	hw->wiphy->flags |= WIPHY_FLAG_IBSS_RSN;
 	hw->wiphy->rts_threshold = 2347;
 
 	hw->queues = AC_MAX;
@@ -354,9 +373,10 @@ static void _rtl_init_deferred_work(struct ieee80211_hw *hw)
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
 	/* <1> timer */
-	init_timer(&rtlpriv->works.watchdog_timer);
 	setup_timer(&rtlpriv->works.watchdog_timer,
 		    rtl_watch_dog_timer_callback, (unsigned long)hw);
+	setup_timer(&rtlpriv->works.dualmac_easyconcurrent_retrytimer,
+		    rtl_easy_concurrent_retrytimer_callback, (unsigned long)hw);
 
 	/* <2> work queue */
 	rtlpriv->works.hw = hw;
@@ -369,6 +389,8 @@ static void _rtl_init_deferred_work(struct ieee80211_hw *hw)
 			  (void *)rtl_swlps_wq_callback);
 	INIT_DELAYED_WORK(&rtlpriv->works.ps_rfon_wq,
 			  (void *)rtl_swlps_rfon_wq_callback);
+	INIT_DELAYED_WORK(&rtlpriv->works.fwevt_wq,
+			  (void *)rtl_fwevt_wq_callback);
 
 }
 
@@ -382,6 +404,7 @@ void rtl_deinit_deferred_work(struct ieee80211_hw *hw)
 	cancel_delayed_work(&rtlpriv->works.ips_nic_off_wq);
 	cancel_delayed_work(&rtlpriv->works.ps_work);
 	cancel_delayed_work(&rtlpriv->works.ps_rfon_wq);
+	cancel_delayed_work(&rtlpriv->works.fwevt_wq);
 }
 
 void rtl_init_rfkill(struct ieee80211_hw *hw)
@@ -436,12 +459,6 @@ int rtl_init_core(struct ieee80211_hw *hw)
 	if (rtl_regd_init(hw, rtl_reg_notifier)) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "REGD init failed\n");
 		return 1;
-	} else {
-		/* CRDA regd hint must after init CRDA */
-		if (regulatory_hint(hw->wiphy, rtlpriv->regd.alpha2)) {
-			RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-				 "regulatory_hint fail\n");
-		}
 	}
 
 	/* <4> locks */
@@ -453,11 +470,18 @@ int rtl_init_core(struct ieee80211_hw *hw)
 	spin_lock_init(&rtlpriv->locks.rf_ps_lock);
 	spin_lock_init(&rtlpriv->locks.rf_lock);
 	spin_lock_init(&rtlpriv->locks.waitq_lock);
+	spin_lock_init(&rtlpriv->locks.entry_list_lock);
 	spin_lock_init(&rtlpriv->locks.cck_and_rw_pagea_lock);
+	spin_lock_init(&rtlpriv->locks.check_sendpkt_lock);
+	spin_lock_init(&rtlpriv->locks.fw_ps_lock);
+	spin_lock_init(&rtlpriv->locks.lps_lock);
+
+	/* <5> init list */
+	INIT_LIST_HEAD(&rtlpriv->entry_list);
 
 	rtlmac->link_state = MAC80211_NOLINK;
 
-	/* <5> init deferred work */
+	/* <6> init deferred work */
 	_rtl_init_deferred_work(hw);
 
 	return 0;
@@ -523,7 +547,8 @@ static void _rtl_query_shortgi(struct ieee80211_hw *hw,
 	if (mac->opmode == NL80211_IFTYPE_STATION)
 		bw_40 = mac->bw_40;
 	else if (mac->opmode == NL80211_IFTYPE_AP ||
-		 mac->opmode == NL80211_IFTYPE_ADHOC)
+		 mac->opmode == NL80211_IFTYPE_ADHOC ||
+		 mac->opmode == NL80211_IFTYPE_MESH_POINT)
 		bw_40 = sta->bandwidth >= IEEE80211_STA_RX_BW_40;
 
 	if (bw_40 && sgi_40)
@@ -578,23 +603,26 @@ static void _rtl_txrate_selectmode(struct ieee80211_hw *hw,
 	if (!tcb_desc->disable_ratefallback || !tcb_desc->use_driver_rate) {
 		if (mac->opmode == NL80211_IFTYPE_STATION) {
 			tcb_desc->ratr_index = 0;
-		} else if (mac->opmode == NL80211_IFTYPE_ADHOC) {
+		} else if (mac->opmode == NL80211_IFTYPE_ADHOC ||
+			   mac->opmode == NL80211_IFTYPE_MESH_POINT) {
 			if (tcb_desc->multicast || tcb_desc->broadcast) {
 				tcb_desc->hw_rate =
 				    rtlpriv->cfg->maps[RTL_RC_CCK_RATE2M];
 				tcb_desc->use_driver_rate = 1;
+				tcb_desc->ratr_index = RATR_INX_WIRELESS_MC;
 			} else {
-				/* TODO */
+				tcb_desc->ratr_index = ratr_index;
 			}
-			tcb_desc->ratr_index = ratr_index;
 		} else if (mac->opmode == NL80211_IFTYPE_AP) {
 			tcb_desc->ratr_index = ratr_index;
 		}
 	}
 
 	if (rtlpriv->dm.useramask) {
-		/* TODO we will differentiate adhoc and station futrue  */
-		if (mac->opmode == NL80211_IFTYPE_STATION) {
+		tcb_desc->ratr_index = ratr_index;
+		/* TODO we will differentiate adhoc and station future  */
+		if (mac->opmode == NL80211_IFTYPE_STATION ||
+		    mac->opmode == NL80211_IFTYPE_MESH_POINT) {
 			tcb_desc->mac_id = 0;
 
 			if (mac->mode == WIRELESS_MODE_N_24G)
@@ -608,7 +636,7 @@ static void _rtl_txrate_selectmode(struct ieee80211_hw *hw,
 			else if (mac->mode & WIRELESS_MODE_A)
 				tcb_desc->ratr_index = RATR_INX_WIRELESS_G;
 		} else if (mac->opmode == NL80211_IFTYPE_AP ||
-			mac->opmode == NL80211_IFTYPE_ADHOC) {
+			   mac->opmode == NL80211_IFTYPE_ADHOC) {
 			if (NULL != sta) {
 				if (sta->aid > 0)
 					tcb_desc->mac_id = sta->aid + 1;
@@ -619,7 +647,6 @@ static void _rtl_txrate_selectmode(struct ieee80211_hw *hw,
 			}
 		}
 	}
-
 }
 
 static void _rtl_query_bandwidth_mode(struct ieee80211_hw *hw,
@@ -633,7 +660,8 @@ static void _rtl_query_bandwidth_mode(struct ieee80211_hw *hw,
 	if (!sta)
 		return;
 	if (mac->opmode == NL80211_IFTYPE_AP ||
-	    mac->opmode == NL80211_IFTYPE_ADHOC) {
+	    mac->opmode == NL80211_IFTYPE_ADHOC ||
+	    mac->opmode == NL80211_IFTYPE_MESH_POINT) {
 		if (sta->bandwidth == IEEE80211_STA_RX_BW_20)
 			return;
 	} else if (mac->opmode == NL80211_IFTYPE_STATION) {
@@ -834,8 +862,8 @@ bool rtl_tx_mgmt_proc(struct ieee80211_hw *hw, struct sk_buff *skb)
 	if (rtlpriv->dm.supp_phymode_switch &&
 	    mac->link_state < MAC80211_LINKED &&
 	    (ieee80211_is_auth(fc) || ieee80211_is_probe_req(fc))) {
-		if (rtlpriv->cfg->ops->check_switch_to_dmdp)
-			rtlpriv->cfg->ops->check_switch_to_dmdp(hw);
+		if (rtlpriv->cfg->ops->chk_switch_dmdp)
+			rtlpriv->cfg->ops->chk_switch_dmdp(hw);
 	}
 	if (ieee80211_is_auth(fc)) {
 		RT_TRACE(rtlpriv, COMP_SEND, DBG_DMESG, "MAC80211_LINKING\n");
@@ -924,6 +952,56 @@ void rtl_get_tcb_desc(struct ieee80211_hw *hw,
 }
 EXPORT_SYMBOL(rtl_get_tcb_desc);
 
+static bool addbareq_rx(struct ieee80211_hw *hw, struct sk_buff *skb)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct ieee80211_sta *sta = NULL;
+	struct ieee80211_hdr *hdr = rtl_get_hdr(skb);
+	struct rtl_sta_info *sta_entry = NULL;
+	struct ieee80211_mgmt *mgmt = (void *)skb->data;
+	u16 capab = 0, tid = 0;
+	struct rtl_tid_data *tid_data;
+	struct sk_buff *skb_delba = NULL;
+	struct ieee80211_rx_status rx_status = { 0 };
+
+	rcu_read_lock();
+	sta = rtl_find_sta(hw, hdr->addr3);
+	if (sta == NULL) {
+		RT_TRACE(rtlpriv, (COMP_SEND | COMP_RECV), DBG_EMERG,
+			 "sta is NULL\n");
+		rcu_read_unlock();
+		return true;
+	}
+
+	sta_entry = (struct rtl_sta_info *)sta->drv_priv;
+	if (!sta_entry) {
+		rcu_read_unlock();
+		return true;
+	}
+	capab = le16_to_cpu(mgmt->u.action.u.addba_req.capab);
+	tid = (capab & IEEE80211_ADDBA_PARAM_TID_MASK) >> 2;
+	tid_data = &sta_entry->tids[tid];
+	if (tid_data->agg.rx_agg_state == RTL_RX_AGG_START) {
+		skb_delba = rtl_make_del_ba(hw, hdr->addr2, hdr->addr3, tid);
+		if (skb_delba) {
+			rx_status.freq = hw->conf.channel->center_freq;
+			rx_status.band = hw->conf.channel->band;
+			rx_status.flag |= RX_FLAG_DECRYPTED;
+			rx_status.flag |= RX_FLAG_MACTIME_END;
+			rx_status.rate_idx = 0;
+			rx_status.signal = 50 + 10;
+			memcpy(IEEE80211_SKB_RXCB(skb_delba), &rx_status,
+			       sizeof(rx_status));
+			RT_PRINT_DATA(rtlpriv, COMP_INIT, DBG_DMESG,
+				      "fake del\n", skb_delba->data,
+				      skb_delba->len);
+			ieee80211_rx_irqsafe(hw, skb_delba);
+		}
+	}
+	rcu_read_unlock();
+	return false;
+}
+
 bool rtl_action_proc(struct ieee80211_hw *hw, struct sk_buff *skb, u8 is_tx)
 {
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
@@ -948,6 +1026,11 @@ bool rtl_action_proc(struct ieee80211_hw *hw, struct sk_buff *skb, u8 is_tx)
 			RT_TRACE(rtlpriv, (COMP_SEND | COMP_RECV), DBG_DMESG,
 				 "%s ACT_ADDBAREQ From :%pM\n",
 				 is_tx ? "Tx" : "Rx", hdr->addr2);
+			RT_PRINT_DATA(rtlpriv, COMP_INIT, DBG_DMESG, "req\n",
+				      skb->data, skb->len);
+			if (!is_tx)
+				if (addbareq_rx(hw, skb))
+					return true;
 			break;
 		case ACT_ADDBARSP:
 			RT_TRACE(rtlpriv, (COMP_SEND | COMP_RECV), DBG_DMESG,
@@ -1101,6 +1184,58 @@ int rtl_tx_agg_stop(struct ieee80211_hw *hw,
 	return 0;
 }
 
+int rtl_rx_agg_start(struct ieee80211_hw *hw,
+		     struct ieee80211_sta *sta, u16 tid)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_tid_data *tid_data;
+	struct rtl_sta_info *sta_entry = NULL;
+
+	if (sta == NULL)
+		return -EINVAL;
+
+	if (unlikely(tid >= MAX_TID_COUNT))
+		return -EINVAL;
+
+	sta_entry = (struct rtl_sta_info *)sta->drv_priv;
+	if (!sta_entry)
+		return -ENXIO;
+	tid_data = &sta_entry->tids[tid];
+
+	RT_TRACE(rtlpriv, COMP_RECV, DBG_DMESG,
+		 "on ra = %pM tid = %d seq:%d\n", sta->addr, tid,
+		 tid_data->seq_number);
+
+	tid_data->agg.rx_agg_state = RTL_RX_AGG_START;
+	return 0;
+}
+
+int rtl_rx_agg_stop(struct ieee80211_hw *hw,
+		    struct ieee80211_sta *sta, u16 tid)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_sta_info *sta_entry = NULL;
+
+	if (sta == NULL)
+		return -EINVAL;
+
+	if (!sta->addr) {
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "ra = NULL\n");
+		return -EINVAL;
+	}
+
+	RT_TRACE(rtlpriv, COMP_SEND, DBG_DMESG,
+		 "on ra = %pM tid = %d\n", sta->addr, tid);
+
+	if (unlikely(tid >= MAX_TID_COUNT))
+		return -EINVAL;
+
+	sta_entry = (struct rtl_sta_info *)sta->drv_priv;
+	sta_entry->tids[tid].agg.rx_agg_state = RTL_RX_AGG_STOP;
+
+	return 0;
+}
+
 int rtl_tx_agg_oper(struct ieee80211_hw *hw,
 		struct ieee80211_sta *sta, u16 tid)
 {
@@ -1132,6 +1267,34 @@ int rtl_tx_agg_oper(struct ieee80211_hw *hw,
  * wq & timer callback functions
  *
  *********************************************************/
+/* this function is used for roaming */
+void rtl_beacon_statistic(struct ieee80211_hw *hw, struct sk_buff *skb)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *)skb->data;
+
+	if (rtlpriv->mac80211.opmode != NL80211_IFTYPE_STATION)
+		return;
+
+	if (rtlpriv->mac80211.link_state < MAC80211_LINKED)
+		return;
+
+	/* check if this really is a beacon */
+	if (!ieee80211_is_beacon(hdr->frame_control) &&
+	    !ieee80211_is_probe_resp(hdr->frame_control))
+		return;
+
+	/* min. beacon length + FCS_LEN */
+	if (skb->len <= 40 + FCS_LEN)
+		return;
+
+	/* and only beacons from the associated BSSID, please */
+	if (compare_ether_addr(hdr->addr3, rtlpriv->mac80211.bssid))
+		return;
+
+	rtlpriv->link_info.bcn_rx_inperiod++;
+}
+
 void rtl_watchdog_wq_callback(void *data)
 {
 	struct rtl_works *rtlworks = container_of_dwork_rtl(data,
@@ -1142,6 +1305,8 @@ void rtl_watchdog_wq_callback(void *data)
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	bool busytraffic = false;
+	bool tx_busy_traffic = false;
+	bool rx_busy_traffic = false;
 	bool higher_busytraffic = false;
 	bool higher_busyrxtraffic = false;
 	u8 idx, tid;
@@ -1191,8 +1356,13 @@ void rtl_watchdog_wq_callback(void *data)
 		aver_tx_cnt_inperiod = tx_cnt_inp4eriod / 4;
 
 		/* (2) check traffic busy */
-		if (aver_rx_cnt_inperiod > 100 || aver_tx_cnt_inperiod > 100)
+		if (aver_rx_cnt_inperiod > 100 || aver_tx_cnt_inperiod > 100) {
 			busytraffic = true;
+			if (aver_rx_cnt_inperiod > aver_tx_cnt_inperiod)
+				rx_busy_traffic = true;
+			else
+				tx_busy_traffic = false;
+		}
 
 		/* Higher Tx/Rx data. */
 		if (aver_rx_cnt_inperiod > 4000 ||
@@ -1236,7 +1406,7 @@ void rtl_watchdog_wq_callback(void *data)
 		if (enter_ps)
 			rtl_lps_enter(hw);
 		else
-			rtl_lps_leave(hw);
+			schedule_work(&rtlpriv->works.lps_leave_work);
 	}
 
 	rtlpriv->link_info.num_rx_inperiod = 0;
@@ -1246,10 +1416,37 @@ void rtl_watchdog_wq_callback(void *data)
 
 	rtlpriv->link_info.busytraffic = busytraffic;
 	rtlpriv->link_info.higher_busytraffic = higher_busytraffic;
+	rtlpriv->link_info.rx_busy_traffic = rx_busy_traffic;
+	rtlpriv->link_info.tx_busy_traffic = tx_busy_traffic;
 	rtlpriv->link_info.higher_busyrxtraffic = higher_busyrxtraffic;
 
 	/* <3> DM */
 	rtlpriv->cfg->ops->dm_watchdog(hw);
+
+	/* <4> roaming */
+	if (mac->link_state == MAC80211_LINKED &&
+	    mac->opmode == NL80211_IFTYPE_STATION) {
+		if ((rtlpriv->link_info.bcn_rx_inperiod +
+		     rtlpriv->link_info.num_rx_inperiod) == 0) {
+			rtlpriv->link_info.roam_times++;
+			RT_TRACE(rtlpriv, COMP_ERR, DBG_DMESG,
+				 "AP off for %d s\n",
+				 (rtlpriv->link_info.roam_times * 2));
+
+			/* if we can't recv beacon for 6s, we should
+			 * reconnect this AP
+			 */
+			if (rtlpriv->link_info.roam_times >= 3) {
+				RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+					 "AP off, try to reconnect now\n");
+				rtlpriv->link_info.roam_times = 0;
+				ieee80211_connection_loss(rtlpriv->mac80211.vif);
+			}
+		} else {
+			rtlpriv->link_info.roam_times = 0;
+		}
+	}
+	rtlpriv->link_info.bcn_rx_inperiod = 0;
 }
 
 void rtl_watch_dog_timer_callback(unsigned long data)
@@ -1264,6 +1461,28 @@ void rtl_watch_dog_timer_callback(unsigned long data)
 		  jiffies + MSECS(RTL_WATCH_DOG_TIME));
 }
 
+void rtl_fwevt_wq_callback(void *data)
+{
+	struct rtl_works *rtlworks =
+		container_of_dwork_rtl(data, struct rtl_works, fwevt_wq);
+	struct ieee80211_hw *hw = rtlworks->hw;
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+
+	rtlpriv->cfg->ops->c2h_command_handle(hw);
+}
+
+void rtl_easy_concurrent_retrytimer_callback(unsigned long data)
+{
+	struct ieee80211_hw *hw = (struct ieee80211_hw *)data;
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_priv *buddy_priv = rtlpriv->buddy_priv;
+
+	if (buddy_priv == NULL)
+		return;
+
+	rtlpriv->cfg->ops->dualmac_easy_concurrent(hw);
+}
+
 /*********************************************************
  *
  * frame process functions
@@ -1334,14 +1553,16 @@ static struct sk_buff *rtl_make_smps_action(struct ieee80211_hw *hw,
 }
 
 int rtl_send_smps_action(struct ieee80211_hw *hw,
-		struct ieee80211_sta *sta, u8 *da, u8 *bssid,
+		struct ieee80211_sta *sta,
 		enum ieee80211_smps_mode smps)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
-	struct sk_buff *skb = rtl_make_smps_action(hw, smps, da, bssid);
+	struct sk_buff *skb = NULL;
 	struct rtl_tcb_desc tcb_desc;
+	u8 bssid[ETH_ALEN] = {0};
+
 	memset(&tcb_desc, 0, sizeof(struct rtl_tcb_desc));
 
 	if (rtlpriv->mac80211.act_scanning)
@@ -1356,21 +1577,67 @@ int rtl_send_smps_action(struct ieee80211_hw *hw,
 	if (!test_bit(RTL_STATUS_INTERFACE_START, &rtlpriv->status))
 		goto err_free;
 
+	if (rtlpriv->mac80211.opmode == NL80211_IFTYPE_AP)
+		memcpy(bssid, rtlpriv->efuse.dev_addr, ETH_ALEN);
+	else
+		memcpy(bssid, rtlpriv->mac80211.bssid, ETH_ALEN);
+
+	skb = rtl_make_smps_action(hw, smps, sta->addr, bssid);
 	/* this is a type = mgmt * stype = action frame */
 	if (skb) {
 		struct ieee80211_tx_info *info = IEEE80211_SKB_CB(skb);
 		struct rtl_sta_info *sta_entry =
 			(struct rtl_sta_info *) sta->drv_priv;
 		sta_entry->mimo_ps = smps;
-		rtlpriv->cfg->ops->update_rate_tbl(hw, sta, 0);
 
 		info->control.rates[0].idx = 0;
 		info->band = hw->conf.channel->band;
 		rtlpriv->intf_ops->adapter_tx(hw, sta, skb, &tcb_desc);
 	}
+	return 1;
+
 err_free:
 	return 0;
 }
+EXPORT_SYMBOL(rtl_send_smps_action);
+
+/* There seem to be issues in mac80211 regarding when del ba frames can be
+ * received. As a work around, we make a fake del_ba if we receive a ba_req;
+ * however, rx_agg was opened to let mac80211 release some ba related
+ * resources. This del_ba is for tx only.
+ */
+struct sk_buff *rtl_make_del_ba(struct ieee80211_hw *hw,
+				u8 *sa, u8 *bssid, u16 tid)
+{
+	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
+	struct sk_buff *skb;
+	struct ieee80211_mgmt *action_frame;
+	u16 params;
+
+	/* 27 = header + category + action + smps mode */
+	skb = dev_alloc_skb(34 + hw->extra_tx_headroom);
+	if (!skb)
+		return NULL;
+
+	skb_reserve(skb, hw->extra_tx_headroom);
+	action_frame = (void *)skb_put(skb, 34);
+	memset(action_frame, 0, 34);
+	memcpy(action_frame->sa, sa, ETH_ALEN);
+	memcpy(action_frame->da, rtlefuse->dev_addr, ETH_ALEN);
+	memcpy(action_frame->bssid, bssid, ETH_ALEN);
+	action_frame->frame_control = cpu_to_le16(IEEE80211_FTYPE_MGMT |
+						  IEEE80211_STYPE_ACTION);
+	action_frame->u.action.category = WLAN_CATEGORY_BACK;
+	action_frame->u.action.u.delba.action_code = WLAN_ACTION_DELBA;
+	params = (u16)(1 << 11);	/* bit 11 initiator */
+	params |= (u16)(tid << 12);		/* bit 15:12 TID number */
+
+	action_frame->u.action.u.delba.params = cpu_to_le16(params);
+	action_frame->u.action.u.delba.reason_code =
+		cpu_to_le16(WLAN_REASON_QSTA_TIMEOUT);
+
+	return skb;
+}
 
 /*********************************************************
  *
@@ -1587,11 +1854,17 @@ MODULE_AUTHOR("Larry Finger	<Larry.FInger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>");
 MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("Realtek 802.11n PCI wireless core");
 
+struct rtl_global_var global_var = {};
+
 static int __init rtl_core_module_init(void)
 {
 	if (rtl_rate_control_register())
 		pr_err("Unable to register rtl_rc, use default RC !!\n");
 
+	/* init some global vars */
+	INIT_LIST_HEAD(&global_var.glb_priv_list);
+	spin_lock_init(&global_var.glb_list_lock);
+
 	return 0;
 }
 
diff --git a/drivers/net/wireless/rtlwifi/base.h b/drivers/net/wireless/rtlwifi/base.h
index 5a8c80e..8576bc3 100644
--- a/drivers/net/wireless/rtlwifi/base.h
+++ b/drivers/net/wireless/rtlwifi/base.h
@@ -113,6 +113,7 @@ void rtl_init_rx_config(struct ieee80211_hw *hw);
 void rtl_init_rfkill(struct ieee80211_hw *hw);
 void rtl_deinit_rfkill(struct ieee80211_hw *hw);
 
+void rtl_beacon_statistic(struct ieee80211_hw *hw, struct sk_buff *skb);
 void rtl_watch_dog_timer_callback(unsigned long data);
 void rtl_deinit_deferred_work(struct ieee80211_hw *hw);
 
@@ -126,7 +127,12 @@ int rtl_tx_agg_stop(struct ieee80211_hw *hw, struct ieee80211_sta *sta,
 		    u16 tid);
 int rtl_tx_agg_oper(struct ieee80211_hw *hw, struct ieee80211_sta *sta,
 		    u16 tid);
+int rtl_rx_agg_start(struct ieee80211_hw *hw, struct ieee80211_sta *sta,
+		     u16 tid);
+int rtl_rx_agg_stop(struct ieee80211_hw *hw, struct ieee80211_sta *sta,
+		    u16 tid);
 void rtl_watchdog_wq_callback(void *data);
+void rtl_fwevt_wq_callback(void *data);
 
 void rtl_get_tcb_desc(struct ieee80211_hw *hw,
 		      struct ieee80211_tx_info *info,
@@ -134,14 +140,18 @@ void rtl_get_tcb_desc(struct ieee80211_hw *hw,
 		      struct sk_buff *skb, struct rtl_tcb_desc *tcb_desc);
 
 int rtl_send_smps_action(struct ieee80211_hw *hw,
-		struct ieee80211_sta *sta, u8 *da, u8 *bssid,
-		enum ieee80211_smps_mode smps);
+			 struct ieee80211_sta *sta,
+			 enum ieee80211_smps_mode smps);
 u8 *rtl_find_ie(u8 *data, unsigned int len, u8 ie);
 void rtl_recognize_peer(struct ieee80211_hw *hw, u8 *data, unsigned int len);
 u8 rtl_tid_to_ac(u8 tid);
 extern struct attribute_group rtl_attribute_group;
+void rtl_easy_concurrent_retrytimer_callback(unsigned long data);
+extern struct rtl_global_var global_var;
 int rtlwifi_rate_mapping(struct ieee80211_hw *hw,
 			 bool isht, u8 desc_rate, bool first_ampdu);
 bool rtl_tx_mgmt_proc(struct ieee80211_hw *hw, struct sk_buff *skb);
+struct sk_buff *rtl_make_del_ba(struct ieee80211_hw *hw,
+				u8 *sa, u8 *bssid, u16 tid);
 
 #endif
diff --git a/drivers/net/wireless/rtlwifi/wifi.h b/drivers/net/wireless/rtlwifi/wifi.h
index 9536963..3cc2c08 100644
--- a/drivers/net/wireless/rtlwifi/wifi.h
+++ b/drivers/net/wireless/rtlwifi/wifi.h
@@ -1624,7 +1624,7 @@ struct rtl_hal_ops {
 	void (*allow_all_destaddr)(struct ieee80211_hw *hw,
 		bool allow_all_da, bool write_into_reg);
 	void (*linked_set_reg) (struct ieee80211_hw *hw);
-	void (*check_switch_to_dmdp) (struct ieee80211_hw *hw);
+	void (*chk_switch_dmdp) (struct ieee80211_hw *hw);
 	void (*dualmac_easy_concurrent) (struct ieee80211_hw *hw);
 	void (*dualmac_switch_to_dmdp) (struct ieee80211_hw *hw);
 	bool (*phy_rf6052_config) (struct ieee80211_hw *hw);
-- 
1.8.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
