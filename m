From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/3] net: mac80211: Add and use ht_vdbg debugging macro
Date: Tue, 15 May 2012 14:20:31 -0700
Message-ID: <63e41e805cd2b78b6691dd9beaada97184996579.1337116579.git.joe@perches.com>
References: <1337106548.15553.8.camel@jlt3.sipsolutions.net> <cover.1337116578.git.joe@perches.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1337116578.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simplify the use of #ifdef CONFIG_MAC80211_HT_DEBUG/#endif
by adding a logging macro to encapsulate the test.

Convert the appropriate uses too.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/mac80211.h |   13 ++++++
 net/mac80211/agg-rx.c  |   24 ++++-------
 net/mac80211/agg-tx.c  |  103 +++++++++++++----------------------------------
 3 files changed, 50 insertions(+), 90 deletions(-)

diff --git a/include/net/mac80211.h b/include/net/mac80211.h
index 4d6e6c6..7d79fd0 100644
--- a/include/net/mac80211.h
+++ b/include/net/mac80211.h
@@ -3829,4 +3829,17 @@ int ieee80211_add_ext_srates_ie(struct ieee80211_vif *vif,
  */
 int ieee80211_ave_rssi(struct ieee80211_vif *vif);
 
+/* Extra debugging macros */
+
+#ifdef CONFIG_MAC80211_HT_DEBUG
+#define ht_vdbg(fmt, ...)			\
+	pr_debug(fmt, ##__VA_ARGS__)
+#else
+#define ht_vdbg(fmt, ...)			\
+do {						\
+	if (0)					\
+		pr_debug(fmt, ##__VA_ARGS__);	\
+} while (0)
+#endif
+
 #endif /* MAC80211_H */
diff --git a/net/mac80211/agg-rx.c b/net/mac80211/agg-rx.c
index ec55f42..a096b0d 100644
--- a/net/mac80211/agg-rx.c
+++ b/net/mac80211/agg-rx.c
@@ -74,12 +74,10 @@ void ___ieee80211_stop_rx_ba_session(struct sta_info *sta, u16 tid,
 
 	RCU_INIT_POINTER(sta->ampdu_mlme.tid_rx[tid], NULL);
 
-#ifdef CONFIG_MAC80211_HT_DEBUG
-	pr_debug("Rx BA session stop requested for %pM tid %u %s reason: %d\n",
-		 sta->sta.addr, tid,
-		 initiator == WLAN_BACK_RECIPIENT ? "recipient" : "inititator",
-		 (int)reason);
-#endif /* CONFIG_MAC80211_HT_DEBUG */
+	ht_vdbg("Rx BA session stop requested for %pM tid %u %s reason: %d\n",
+		sta->sta.addr, tid,
+		initiator == WLAN_BACK_RECIPIENT ? "recipient" : "inititator",
+		(int)reason);
 
 	if (drv_ampdu_action(local, sta->sdata, IEEE80211_AMPDU_RX_STOP,
 			     &sta->sta, tid, NULL, 0))
@@ -154,9 +152,8 @@ static void sta_rx_agg_session_timer_expired(unsigned long data)
 		return;
 	}
 
-#ifdef CONFIG_MAC80211_HT_DEBUG
-	pr_debug("rx session timer expired on tid %d\n", (u16)*ptid);
-#endif
+	ht_vdbg("rx session timer expired on tid %d\n", (u16)*ptid);
+
 	set_bit(*ptid, sta->ampdu_mlme.tid_rx_timer_expired);
 	ieee80211_queue_work(&sta->local->hw, &sta->ampdu_mlme.work);
 }
@@ -243,9 +240,7 @@ void ieee80211_process_addba_request(struct ieee80211_local *local,
 	status = WLAN_STATUS_REQUEST_DECLINED;
 
 	if (test_sta_flag(sta, WLAN_STA_BLOCK_BA)) {
-#ifdef CONFIG_MAC80211_HT_DEBUG
-		pr_debug("Suspend in progress - Denying ADDBA request\n");
-#endif
+		ht_vdbg("Suspend in progress - Denying ADDBA request\n");
 		goto end_no_lock;
 	}
 
@@ -317,10 +312,7 @@ void ieee80211_process_addba_request(struct ieee80211_local *local,
 
 	ret = drv_ampdu_action(local, sta->sdata, IEEE80211_AMPDU_RX_START,
 			       &sta->sta, tid, &start_seq_num, 0);
-#ifdef CONFIG_MAC80211_HT_DEBUG
-	pr_debug("Rx A-MPDU request on tid %d result %d\n", tid, ret);
-#endif /* CONFIG_MAC80211_HT_DEBUG */
-
+	ht_vdbg("Rx A-MPDU request on tid %d result %d\n", tid, ret);
 	if (ret) {
 		kfree(tid_agg_rx->reorder_buf);
 		kfree(tid_agg_rx->reorder_time);
diff --git a/net/mac80211/agg-tx.c b/net/mac80211/agg-tx.c
index 5794525..88ea574 100644
--- a/net/mac80211/agg-tx.c
+++ b/net/mac80211/agg-tx.c
@@ -184,10 +184,8 @@ int ___ieee80211_stop_tx_ba_session(struct sta_info *sta, u16 tid,
 
 	spin_unlock_bh(&sta->lock);
 
-#ifdef CONFIG_MAC80211_HT_DEBUG
-	pr_debug("Tx BA session stop requested for %pM tid %u\n",
-		 sta->sta.addr, tid);
-#endif /* CONFIG_MAC80211_HT_DEBUG */
+	ht_vdbg("Tx BA session stop requested for %pM tid %u\n",
+		sta->sta.addr, tid);
 
 	del_timer_sync(&tid_tx->addba_resp_timer);
 	del_timer_sync(&tid_tx->session_timer);
@@ -253,16 +251,12 @@ static void sta_addba_resp_timer_expired(unsigned long data)
 	if (!tid_tx ||
 	    test_bit(HT_AGG_STATE_RESPONSE_RECEIVED, &tid_tx->state)) {
 		rcu_read_unlock();
-#ifdef CONFIG_MAC80211_HT_DEBUG
-		pr_debug("timer expired on tid %d but we are not (or no longer) expecting addBA response there\n",
-			 tid);
-#endif
+		ht_vdbg("timer expired on tid %d but we are not (or no longer) expecting addBA response there\n",
+			tid);
 		return;
 	}
 
-#ifdef CONFIG_MAC80211_HT_DEBUG
-	pr_debug("addBA response timer expired on tid %d\n", tid);
-#endif
+	ht_vdbg("addBA response timer expired on tid %d\n", tid);
 
 	ieee80211_stop_tx_ba_session(&sta->sta, tid);
 	rcu_read_unlock();
@@ -371,10 +365,7 @@ void ieee80211_tx_ba_session_handle_start(struct sta_info *sta, int tid)
 	ret = drv_ampdu_action(local, sdata, IEEE80211_AMPDU_TX_START,
 			       &sta->sta, tid, &start_seq_num, 0);
 	if (ret) {
-#ifdef CONFIG_MAC80211_HT_DEBUG
-		pr_debug("BA request denied - HW unavailable for tid %d\n",
-			 tid);
-#endif
+		ht_vdbg("BA request denied - HW unavailable for tid %d\n", tid);
 		spin_lock_bh(&sta->lock);
 		ieee80211_agg_splice_packets(sdata, tid_tx, tid);
 		ieee80211_assign_tid_tx(sta, tid, NULL);
@@ -387,9 +378,7 @@ void ieee80211_tx_ba_session_handle_start(struct sta_info *sta, int tid)
 
 	/* activate the timer for the recipient's addBA response */
 	mod_timer(&tid_tx->addba_resp_timer, jiffies + ADDBA_RESP_INTERVAL);
-#ifdef CONFIG_MAC80211_HT_DEBUG
-	pr_debug("activated addBA response timer on tid %d\n", tid);
-#endif
+	ht_vdbg("activated addBA response timer on tid %d\n", tid);
 
 	spin_lock_bh(&sta->lock);
 	sta->ampdu_mlme.last_addba_req_time[tid] = jiffies;
@@ -430,9 +419,7 @@ static void sta_tx_agg_session_timer_expired(unsigned long data)
 		return;
 	}
 
-#ifdef CONFIG_MAC80211_HT_DEBUG
-	pr_debug("tx session timer expired on tid %d\n", (u16)*ptid);
-#endif
+	ht_vdbg("tx session timer expired on tid %d\n", (u16)*ptid);
 
 	ieee80211_stop_tx_ba_session(&sta->sta, *ptid);
 }
@@ -456,10 +443,8 @@ int ieee80211_start_tx_ba_session(struct ieee80211_sta *pubsta, u16 tid,
 	    (local->hw.flags & IEEE80211_HW_TX_AMPDU_SETUP_IN_HW))
 		return -EINVAL;
 
-#ifdef CONFIG_MAC80211_HT_DEBUG
-	pr_debug("Open BA session requested for %pM tid %u\n",
-		 pubsta->addr, tid);
-#endif /* CONFIG_MAC80211_HT_DEBUG */
+	ht_vdbg("Open BA session requested for %pM tid %u\n",
+		pubsta->addr, tid);
 
 	if (sdata->vif.type != NL80211_IFTYPE_STATION &&
 	    sdata->vif.type != NL80211_IFTYPE_MESH_POINT &&
@@ -469,9 +454,7 @@ int ieee80211_start_tx_ba_session(struct ieee80211_sta *pubsta, u16 tid,
 		return -EINVAL;
 
 	if (test_sta_flag(sta, WLAN_STA_BLOCK_BA)) {
-#ifdef CONFIG_MAC80211_HT_DEBUG
-		pr_debug("BA sessions blocked - Denying BA session request\n");
-#endif
+		ht_vdbg("BA sessions blocked - Denying BA session request\n");
 		return -EINVAL;
 	}
 
@@ -489,10 +472,8 @@ int ieee80211_start_tx_ba_session(struct ieee80211_sta *pubsta, u16 tid,
 	 */
 	if (sta->sdata->vif.type == NL80211_IFTYPE_ADHOC &&
 	    !sta->sta.ht_cap.ht_supported) {
-#ifdef CONFIG_MAC80211_HT_DEBUG
-		pr_debug("BA request denied - IBSS STA %pM does not advertise HT support\n",
-			 pubsta->addr);
-#endif /* CONFIG_MAC80211_HT_DEBUG */
+		ht_vdbg("BA request denied - IBSS STA %pM does not advertise HT support\n",
+			pubsta->addr);
 		return -EINVAL;
 	}
 
@@ -512,10 +493,8 @@ int ieee80211_start_tx_ba_session(struct ieee80211_sta *pubsta, u16 tid,
 	if (sta->ampdu_mlme.addba_req_num[tid] > HT_AGG_BURST_RETRIES &&
 	    time_before(jiffies, sta->ampdu_mlme.last_addba_req_time[tid] +
 			HT_AGG_RETRIES_PERIOD)) {
-#ifdef CONFIG_MAC80211_HT_DEBUG
-		pr_debug("BA request denied - waiting a grace period after %d failed requests on tid %u\n",
-			 sta->ampdu_mlme.addba_req_num[tid], tid);
-#endif /* CONFIG_MAC80211_HT_DEBUG */
+		ht_vdbg("BA request denied - waiting a grace period after %d failed requests on tid %u\n",
+			sta->ampdu_mlme.addba_req_num[tid], tid);
 		ret = -EBUSY;
 		goto err_unlock_sta;
 	}
@@ -523,10 +502,8 @@ int ieee80211_start_tx_ba_session(struct ieee80211_sta *pubsta, u16 tid,
 	tid_tx = rcu_dereference_protected_tid_tx(sta, tid);
 	/* check if the TID is not in aggregation flow already */
 	if (tid_tx || sta->ampdu_mlme.tid_start_tx[tid]) {
-#ifdef CONFIG_MAC80211_HT_DEBUG
-		pr_debug("BA request denied - session is not idle on tid %u\n",
-			 tid);
-#endif /* CONFIG_MAC80211_HT_DEBUG */
+		ht_vdbg("BA request denied - session is not idle on tid %u\n",
+			tid);
 		ret = -EAGAIN;
 		goto err_unlock_sta;
 	}
@@ -581,9 +558,7 @@ static void ieee80211_agg_tx_operational(struct ieee80211_local *local,
 
 	tid_tx = rcu_dereference_protected_tid_tx(sta, tid);
 
-#ifdef CONFIG_MAC80211_HT_DEBUG
-	pr_debug("Aggregation is on for tid %d\n", tid);
-#endif
+	ht_vdbg("Aggregation is on for tid %d\n", tid);
 
 	drv_ampdu_action(local, sta->sdata,
 			 IEEE80211_AMPDU_TX_OPERATIONAL,
@@ -617,9 +592,7 @@ void ieee80211_start_tx_ba_cb(struct ieee80211_vif *vif, u8 *ra, u16 tid)
 	trace_api_start_tx_ba_cb(sdata, ra, tid);
 
 	if (tid >= STA_TID_NUM) {
-#ifdef CONFIG_MAC80211_HT_DEBUG
-		pr_debug("Bad TID value: tid = %d (>= %d)\n", tid, STA_TID_NUM);
-#endif
+		ht_vdbg("Bad TID value: tid = %d (>= %d)\n", tid, STA_TID_NUM);
 		return;
 	}
 
@@ -627,9 +600,7 @@ void ieee80211_start_tx_ba_cb(struct ieee80211_vif *vif, u8 *ra, u16 tid)
 	sta = sta_info_get_bss(sdata, ra);
 	if (!sta) {
 		mutex_unlock(&local->sta_mtx);
-#ifdef CONFIG_MAC80211_HT_DEBUG
-		pr_debug("Could not find station: %pM\n", ra);
-#endif
+		ht_vdbg("Could not find station: %pM\n", ra);
 		return;
 	}
 
@@ -637,9 +608,7 @@ void ieee80211_start_tx_ba_cb(struct ieee80211_vif *vif, u8 *ra, u16 tid)
 	tid_tx = rcu_dereference_protected_tid_tx(sta, tid);
 
 	if (WARN_ON(!tid_tx)) {
-#ifdef CONFIG_MAC80211_HT_DEBUG
-		pr_debug("addBA was not requested!\n");
-#endif
+		ht_vdbg("addBA was not requested!\n");
 		goto unlock;
 	}
 
@@ -739,23 +708,17 @@ void ieee80211_stop_tx_ba_cb(struct ieee80211_vif *vif, u8 *ra, u8 tid)
 	trace_api_stop_tx_ba_cb(sdata, ra, tid);
 
 	if (tid >= STA_TID_NUM) {
-#ifdef CONFIG_MAC80211_HT_DEBUG
-		pr_debug("Bad TID value: tid = %d (>= %d)\n", tid, STA_TID_NUM);
-#endif
+		ht_vdbg("Bad TID value: tid = %d (>= %d)\n", tid, STA_TID_NUM);
 		return;
 	}
 
-#ifdef CONFIG_MAC80211_HT_DEBUG
-	pr_debug("Stopping Tx BA session for %pM tid %d\n", ra, tid);
-#endif /* CONFIG_MAC80211_HT_DEBUG */
+	ht_vdbg("Stopping Tx BA session for %pM tid %d\n", ra, tid);
 
 	mutex_lock(&local->sta_mtx);
 
 	sta = sta_info_get_bss(sdata, ra);
 	if (!sta) {
-#ifdef CONFIG_MAC80211_HT_DEBUG
-		pr_debug("Could not find station: %pM\n", ra);
-#endif
+		ht_vdbg("Could not find station: %pM\n", ra);
 		goto unlock;
 	}
 
@@ -764,9 +727,7 @@ void ieee80211_stop_tx_ba_cb(struct ieee80211_vif *vif, u8 *ra, u8 tid)
 	tid_tx = rcu_dereference_protected_tid_tx(sta, tid);
 
 	if (!tid_tx || !test_bit(HT_AGG_STATE_STOPPING, &tid_tx->state)) {
-#ifdef CONFIG_MAC80211_HT_DEBUG
-		pr_debug("unexpected callback to A-MPDU stop\n");
-#endif
+		ht_vdbg("unexpected callback to A-MPDU stop\n");
 		goto unlock_sta;
 	}
 
@@ -842,17 +803,13 @@ void ieee80211_process_addba_resp(struct ieee80211_local *local,
 		goto out;
 
 	if (mgmt->u.action.u.addba_resp.dialog_token != tid_tx->dialog_token) {
-#ifdef CONFIG_MAC80211_HT_DEBUG
-		pr_debug("wrong addBA response token, tid %d\n", tid);
-#endif
+		ht_vdbg("wrong addBA response token, tid %d\n", tid);
 		goto out;
 	}
 
 	del_timer_sync(&tid_tx->addba_resp_timer);
 
-#ifdef CONFIG_MAC80211_HT_DEBUG
-	pr_debug("switched off addBA timer for tid %d\n", tid);
-#endif
+	ht_vdbg("switched off addBA timer for tid %d\n", tid);
 
 	/*
 	 * addba_resp_timer may have fired before we got here, and
@@ -861,10 +818,8 @@ void ieee80211_process_addba_resp(struct ieee80211_local *local,
 	 */
 	if (test_bit(HT_AGG_STATE_WANT_STOP, &tid_tx->state) ||
 	    test_bit(HT_AGG_STATE_STOPPING, &tid_tx->state)) {
-#ifdef CONFIG_MAC80211_HT_DEBUG
-		pr_debug("got addBA resp for tid %d but we already gave up\n",
-			 tid);
-#endif
+		ht_vdbg("got addBA resp for tid %d but we already gave up\n",
+			tid);
 		goto out;
 	}
 
-- 
1.7.8.111.gad25c.dirty
