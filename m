From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/3] net: mac80211: Convert printk(KERN_DEBUG to pr_debug
Date: Tue, 15 May 2012 14:20:30 -0700
Message-ID: <1135dd69acb7a7f21005d1d7c856ba8aceb0ac53.1337116579.git.joe@perches.com>
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

Standardize the debugging to be able to use dynamic_debug.

Coalesce formats, align arguments.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/mac80211/agg-rx.c         |   20 +++----
 net/mac80211/agg-tx.c         |   68 +++++++++------------
 net/mac80211/cfg.c            |    4 +-
 net/mac80211/debugfs_netdev.c |    2 +-
 net/mac80211/ibss.c           |   88 ++++++++++++---------------
 net/mac80211/iface.c          |    4 +-
 net/mac80211/mesh.c           |    3 +-
 net/mac80211/mesh_hwmp.c      |    2 +-
 net/mac80211/mesh_pathtbl.c   |    2 +-
 net/mac80211/mesh_plink.c     |    2 +-
 net/mac80211/mesh_sync.c      |    2 +-
 net/mac80211/mlme.c           |  131 ++++++++++++++++++-----------------------
 net/mac80211/rx.c             |   22 +++----
 net/mac80211/sta_info.c       |   21 +++----
 net/mac80211/status.c         |    2 +-
 net/mac80211/tkip.c           |   21 +++----
 net/mac80211/tx.c             |   14 ++---
 17 files changed, 181 insertions(+), 227 deletions(-)

diff --git a/net/mac80211/agg-rx.c b/net/mac80211/agg-rx.c
index 26ddb69..ec55f42 100644
--- a/net/mac80211/agg-rx.c
+++ b/net/mac80211/agg-rx.c
@@ -75,17 +75,16 @@ void ___ieee80211_stop_rx_ba_session(struct sta_info *sta, u16 tid,
 	RCU_INIT_POINTER(sta->ampdu_mlme.tid_rx[tid], NULL);
 
 #ifdef CONFIG_MAC80211_HT_DEBUG
-	printk(KERN_DEBUG
-	       "Rx BA session stop requested for %pM tid %u %s reason: %d\n",
-	       sta->sta.addr, tid,
-	       initiator == WLAN_BACK_RECIPIENT ? "recipient" : "inititator",
-	       (int)reason);
+	pr_debug("Rx BA session stop requested for %pM tid %u %s reason: %d\n",
+		 sta->sta.addr, tid,
+		 initiator == WLAN_BACK_RECIPIENT ? "recipient" : "inititator",
+		 (int)reason);
 #endif /* CONFIG_MAC80211_HT_DEBUG */
 
 	if (drv_ampdu_action(local, sta->sdata, IEEE80211_AMPDU_RX_STOP,
 			     &sta->sta, tid, NULL, 0))
-		printk(KERN_DEBUG "HW problem - can not stop rx "
-				"aggregation for tid %d\n", tid);
+		pr_debug("HW problem - can not stop rx aggregation for tid %d\n",
+			 tid);
 
 	/* check if this is a self generated aggregation halt */
 	if (initiator == WLAN_BACK_RECIPIENT && tx)
@@ -156,7 +155,7 @@ static void sta_rx_agg_session_timer_expired(unsigned long data)
 	}
 
 #ifdef CONFIG_MAC80211_HT_DEBUG
-	printk(KERN_DEBUG "rx session timer expired on tid %d\n", (u16)*ptid);
+	pr_debug("rx session timer expired on tid %d\n", (u16)*ptid);
 #endif
 	set_bit(*ptid, sta->ampdu_mlme.tid_rx_timer_expired);
 	ieee80211_queue_work(&sta->local->hw, &sta->ampdu_mlme.work);
@@ -245,8 +244,7 @@ void ieee80211_process_addba_request(struct ieee80211_local *local,
 
 	if (test_sta_flag(sta, WLAN_STA_BLOCK_BA)) {
 #ifdef CONFIG_MAC80211_HT_DEBUG
-		printk(KERN_DEBUG "Suspend in progress. "
-		       "Denying ADDBA request\n");
+		pr_debug("Suspend in progress - Denying ADDBA request\n");
 #endif
 		goto end_no_lock;
 	}
@@ -320,7 +318,7 @@ void ieee80211_process_addba_request(struct ieee80211_local *local,
 	ret = drv_ampdu_action(local, sta->sdata, IEEE80211_AMPDU_RX_START,
 			       &sta->sta, tid, &start_seq_num, 0);
 #ifdef CONFIG_MAC80211_HT_DEBUG
-	printk(KERN_DEBUG "Rx A-MPDU request on tid %d result %d\n", tid, ret);
+	pr_debug("Rx A-MPDU request on tid %d result %d\n", tid, ret);
 #endif /* CONFIG_MAC80211_HT_DEBUG */
 
 	if (ret) {
diff --git a/net/mac80211/agg-tx.c b/net/mac80211/agg-tx.c
index 5b7053c..5794525 100644
--- a/net/mac80211/agg-tx.c
+++ b/net/mac80211/agg-tx.c
@@ -185,8 +185,8 @@ int ___ieee80211_stop_tx_ba_session(struct sta_info *sta, u16 tid,
 	spin_unlock_bh(&sta->lock);
 
 #ifdef CONFIG_MAC80211_HT_DEBUG
-	printk(KERN_DEBUG "Tx BA session stop requested for %pM tid %u\n",
-	       sta->sta.addr, tid);
+	pr_debug("Tx BA session stop requested for %pM tid %u\n",
+		 sta->sta.addr, tid);
 #endif /* CONFIG_MAC80211_HT_DEBUG */
 
 	del_timer_sync(&tid_tx->addba_resp_timer);
@@ -254,15 +254,14 @@ static void sta_addba_resp_timer_expired(unsigned long data)
 	    test_bit(HT_AGG_STATE_RESPONSE_RECEIVED, &tid_tx->state)) {
 		rcu_read_unlock();
 #ifdef CONFIG_MAC80211_HT_DEBUG
-		printk(KERN_DEBUG "timer expired on tid %d but we are not "
-				"(or no longer) expecting addBA response there\n",
-			tid);
+		pr_debug("timer expired on tid %d but we are not (or no longer) expecting addBA response there\n",
+			 tid);
 #endif
 		return;
 	}
 
 #ifdef CONFIG_MAC80211_HT_DEBUG
-	printk(KERN_DEBUG "addBA response timer expired on tid %d\n", tid);
+	pr_debug("addBA response timer expired on tid %d\n", tid);
 #endif
 
 	ieee80211_stop_tx_ba_session(&sta->sta, tid);
@@ -373,8 +372,8 @@ void ieee80211_tx_ba_session_handle_start(struct sta_info *sta, int tid)
 			       &sta->sta, tid, &start_seq_num, 0);
 	if (ret) {
 #ifdef CONFIG_MAC80211_HT_DEBUG
-		printk(KERN_DEBUG "BA request denied - HW unavailable for"
-					" tid %d\n", tid);
+		pr_debug("BA request denied - HW unavailable for tid %d\n",
+			 tid);
 #endif
 		spin_lock_bh(&sta->lock);
 		ieee80211_agg_splice_packets(sdata, tid_tx, tid);
@@ -389,7 +388,7 @@ void ieee80211_tx_ba_session_handle_start(struct sta_info *sta, int tid)
 	/* activate the timer for the recipient's addBA response */
 	mod_timer(&tid_tx->addba_resp_timer, jiffies + ADDBA_RESP_INTERVAL);
 #ifdef CONFIG_MAC80211_HT_DEBUG
-	printk(KERN_DEBUG "activated addBA response timer on tid %d\n", tid);
+	pr_debug("activated addBA response timer on tid %d\n", tid);
 #endif
 
 	spin_lock_bh(&sta->lock);
@@ -432,7 +431,7 @@ static void sta_tx_agg_session_timer_expired(unsigned long data)
 	}
 
 #ifdef CONFIG_MAC80211_HT_DEBUG
-	printk(KERN_DEBUG "tx session timer expired on tid %d\n", (u16)*ptid);
+	pr_debug("tx session timer expired on tid %d\n", (u16)*ptid);
 #endif
 
 	ieee80211_stop_tx_ba_session(&sta->sta, *ptid);
@@ -458,8 +457,8 @@ int ieee80211_start_tx_ba_session(struct ieee80211_sta *pubsta, u16 tid,
 		return -EINVAL;
 
 #ifdef CONFIG_MAC80211_HT_DEBUG
-	printk(KERN_DEBUG "Open BA session requested for %pM tid %u\n",
-	       pubsta->addr, tid);
+	pr_debug("Open BA session requested for %pM tid %u\n",
+		 pubsta->addr, tid);
 #endif /* CONFIG_MAC80211_HT_DEBUG */
 
 	if (sdata->vif.type != NL80211_IFTYPE_STATION &&
@@ -471,8 +470,7 @@ int ieee80211_start_tx_ba_session(struct ieee80211_sta *pubsta, u16 tid,
 
 	if (test_sta_flag(sta, WLAN_STA_BLOCK_BA)) {
 #ifdef CONFIG_MAC80211_HT_DEBUG
-		printk(KERN_DEBUG "BA sessions blocked. "
-		       "Denying BA session request\n");
+		pr_debug("BA sessions blocked - Denying BA session request\n");
 #endif
 		return -EINVAL;
 	}
@@ -492,8 +490,8 @@ int ieee80211_start_tx_ba_session(struct ieee80211_sta *pubsta, u16 tid,
 	if (sta->sdata->vif.type == NL80211_IFTYPE_ADHOC &&
 	    !sta->sta.ht_cap.ht_supported) {
 #ifdef CONFIG_MAC80211_HT_DEBUG
-		printk(KERN_DEBUG "BA request denied - IBSS STA %pM"
-		       "does not advertise HT support\n", pubsta->addr);
+		pr_debug("BA request denied - IBSS STA %pM does not advertise HT support\n",
+			 pubsta->addr);
 #endif /* CONFIG_MAC80211_HT_DEBUG */
 		return -EINVAL;
 	}
@@ -515,10 +513,8 @@ int ieee80211_start_tx_ba_session(struct ieee80211_sta *pubsta, u16 tid,
 	    time_before(jiffies, sta->ampdu_mlme.last_addba_req_time[tid] +
 			HT_AGG_RETRIES_PERIOD)) {
 #ifdef CONFIG_MAC80211_HT_DEBUG
-		printk(KERN_DEBUG "BA request denied - "
-		       "waiting a grace period after %d failed requests "
-		       "on tid %u\n",
-		       sta->ampdu_mlme.addba_req_num[tid], tid);
+		pr_debug("BA request denied - waiting a grace period after %d failed requests on tid %u\n",
+			 sta->ampdu_mlme.addba_req_num[tid], tid);
 #endif /* CONFIG_MAC80211_HT_DEBUG */
 		ret = -EBUSY;
 		goto err_unlock_sta;
@@ -528,8 +524,8 @@ int ieee80211_start_tx_ba_session(struct ieee80211_sta *pubsta, u16 tid,
 	/* check if the TID is not in aggregation flow already */
 	if (tid_tx || sta->ampdu_mlme.tid_start_tx[tid]) {
 #ifdef CONFIG_MAC80211_HT_DEBUG
-		printk(KERN_DEBUG "BA request denied - session is not "
-				 "idle on tid %u\n", tid);
+		pr_debug("BA request denied - session is not idle on tid %u\n",
+			 tid);
 #endif /* CONFIG_MAC80211_HT_DEBUG */
 		ret = -EAGAIN;
 		goto err_unlock_sta;
@@ -586,7 +582,7 @@ static void ieee80211_agg_tx_operational(struct ieee80211_local *local,
 	tid_tx = rcu_dereference_protected_tid_tx(sta, tid);
 
 #ifdef CONFIG_MAC80211_HT_DEBUG
-	printk(KERN_DEBUG "Aggregation is on for tid %d\n", tid);
+	pr_debug("Aggregation is on for tid %d\n", tid);
 #endif
 
 	drv_ampdu_action(local, sta->sdata,
@@ -622,8 +618,7 @@ void ieee80211_start_tx_ba_cb(struct ieee80211_vif *vif, u8 *ra, u16 tid)
 
 	if (tid >= STA_TID_NUM) {
 #ifdef CONFIG_MAC80211_HT_DEBUG
-		printk(KERN_DEBUG "Bad TID value: tid = %d (>= %d)\n",
-				tid, STA_TID_NUM);
+		pr_debug("Bad TID value: tid = %d (>= %d)\n", tid, STA_TID_NUM);
 #endif
 		return;
 	}
@@ -633,7 +628,7 @@ void ieee80211_start_tx_ba_cb(struct ieee80211_vif *vif, u8 *ra, u16 tid)
 	if (!sta) {
 		mutex_unlock(&local->sta_mtx);
 #ifdef CONFIG_MAC80211_HT_DEBUG
-		printk(KERN_DEBUG "Could not find station: %pM\n", ra);
+		pr_debug("Could not find station: %pM\n", ra);
 #endif
 		return;
 	}
@@ -643,7 +638,7 @@ void ieee80211_start_tx_ba_cb(struct ieee80211_vif *vif, u8 *ra, u16 tid)
 
 	if (WARN_ON(!tid_tx)) {
 #ifdef CONFIG_MAC80211_HT_DEBUG
-		printk(KERN_DEBUG "addBA was not requested!\n");
+		pr_debug("addBA was not requested!\n");
 #endif
 		goto unlock;
 	}
@@ -745,15 +740,13 @@ void ieee80211_stop_tx_ba_cb(struct ieee80211_vif *vif, u8 *ra, u8 tid)
 
 	if (tid >= STA_TID_NUM) {
 #ifdef CONFIG_MAC80211_HT_DEBUG
-		printk(KERN_DEBUG "Bad TID value: tid = %d (>= %d)\n",
-				tid, STA_TID_NUM);
+		pr_debug("Bad TID value: tid = %d (>= %d)\n", tid, STA_TID_NUM);
 #endif
 		return;
 	}
 
 #ifdef CONFIG_MAC80211_HT_DEBUG
-	printk(KERN_DEBUG "Stopping Tx BA session for %pM tid %d\n",
-	       ra, tid);
+	pr_debug("Stopping Tx BA session for %pM tid %d\n", ra, tid);
 #endif /* CONFIG_MAC80211_HT_DEBUG */
 
 	mutex_lock(&local->sta_mtx);
@@ -761,7 +754,7 @@ void ieee80211_stop_tx_ba_cb(struct ieee80211_vif *vif, u8 *ra, u8 tid)
 	sta = sta_info_get_bss(sdata, ra);
 	if (!sta) {
 #ifdef CONFIG_MAC80211_HT_DEBUG
-		printk(KERN_DEBUG "Could not find station: %pM\n", ra);
+		pr_debug("Could not find station: %pM\n", ra);
 #endif
 		goto unlock;
 	}
@@ -772,7 +765,7 @@ void ieee80211_stop_tx_ba_cb(struct ieee80211_vif *vif, u8 *ra, u8 tid)
 
 	if (!tid_tx || !test_bit(HT_AGG_STATE_STOPPING, &tid_tx->state)) {
 #ifdef CONFIG_MAC80211_HT_DEBUG
-		printk(KERN_DEBUG "unexpected callback to A-MPDU stop\n");
+		pr_debug("unexpected callback to A-MPDU stop\n");
 #endif
 		goto unlock_sta;
 	}
@@ -850,7 +843,7 @@ void ieee80211_process_addba_resp(struct ieee80211_local *local,
 
 	if (mgmt->u.action.u.addba_resp.dialog_token != tid_tx->dialog_token) {
 #ifdef CONFIG_MAC80211_HT_DEBUG
-		printk(KERN_DEBUG "wrong addBA response token, tid %d\n", tid);
+		pr_debug("wrong addBA response token, tid %d\n", tid);
 #endif
 		goto out;
 	}
@@ -858,7 +851,7 @@ void ieee80211_process_addba_resp(struct ieee80211_local *local,
 	del_timer_sync(&tid_tx->addba_resp_timer);
 
 #ifdef CONFIG_MAC80211_HT_DEBUG
-	printk(KERN_DEBUG "switched off addBA timer for tid %d\n", tid);
+	pr_debug("switched off addBA timer for tid %d\n", tid);
 #endif
 
 	/*
@@ -869,9 +862,8 @@ void ieee80211_process_addba_resp(struct ieee80211_local *local,
 	if (test_bit(HT_AGG_STATE_WANT_STOP, &tid_tx->state) ||
 	    test_bit(HT_AGG_STATE_STOPPING, &tid_tx->state)) {
 #ifdef CONFIG_MAC80211_HT_DEBUG
-		printk(KERN_DEBUG
-		       "got addBA resp for tid %d but we already gave up\n",
-		       tid);
+		pr_debug("got addBA resp for tid %d but we already gave up\n",
+			 tid);
 #endif
 		goto out;
 	}
diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index 495831e..8299b12 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -2677,7 +2677,7 @@ static int ieee80211_tdls_mgmt(struct wiphy *wiphy, struct net_device *dev,
 		return -EINVAL;
 
 #ifdef CONFIG_MAC80211_VERBOSE_TDLS_DEBUG
-	printk(KERN_DEBUG "TDLS mgmt action %d peer %pM\n", action_code, peer);
+	pr_debug("TDLS mgmt action %d peer %pM\n", action_code, peer);
 #endif
 
 	skb = dev_alloc_skb(local->hw.extra_tx_headroom +
@@ -2788,7 +2788,7 @@ static int ieee80211_tdls_oper(struct wiphy *wiphy, struct net_device *dev,
 		return -EINVAL;
 
 #ifdef CONFIG_MAC80211_VERBOSE_TDLS_DEBUG
-	printk(KERN_DEBUG "TDLS oper %d peer %pM\n", oper, peer);
+	pr_debug("TDLS oper %d peer %pM\n", oper, peer);
 #endif
 
 	switch (oper) {
diff --git a/net/mac80211/debugfs_netdev.c b/net/mac80211/debugfs_netdev.c
index ea0122d..6185301 100644
--- a/net/mac80211/debugfs_netdev.c
+++ b/net/mac80211/debugfs_netdev.c
@@ -683,6 +683,6 @@ void ieee80211_debugfs_rename_netdev(struct ieee80211_sub_if_data *sdata)
 
 	sprintf(buf, "netdev:%s", sdata->name);
 	if (!debugfs_rename(dir->d_parent, dir, dir->d_parent, buf))
-		printk(KERN_ERR "mac80211: debugfs: failed to rename debugfs "
+		pr_err("mac80211: debugfs: failed to rename debugfs "
 		       "dir to %s\n", buf);
 }
diff --git a/net/mac80211/ibss.c b/net/mac80211/ibss.c
index 3ad33a8..33e0566 100644
--- a/net/mac80211/ibss.c
+++ b/net/mac80211/ibss.c
@@ -277,9 +277,8 @@ static struct sta_info *ieee80211_ibss_finish_sta(struct sta_info *sta,
 		return sta_info_get(sdata, addr);
 	if (auth) {
 #ifdef CONFIG_MAC80211_IBSS_DEBUG
-		printk(KERN_DEBUG "TX Auth SA=%pM DA=%pM BSSID=%pM"
-		       "(auth_transaction=1)\n", sdata->vif.addr,
-		       sdata->u.ibss.bssid, addr);
+		pr_debug("TX Auth SA=%pM DA=%pM BSSID=%pM (auth_transaction=1)\n",
+			 sdata->vif.addr, sdata->u.ibss.bssid, addr);
 #endif
 		ieee80211_send_auth(sdata, 1, WLAN_AUTH_OPEN, NULL, 0,
 				    addr, sdata->u.ibss.bssid, NULL, 0, 0);
@@ -351,9 +350,9 @@ static void ieee80211_rx_mgmt_auth_ibss(struct ieee80211_sub_if_data *sdata,
 	if (auth_alg != WLAN_AUTH_OPEN || auth_transaction != 1)
 		return;
 #ifdef CONFIG_MAC80211_IBSS_DEBUG
-	printk(KERN_DEBUG "%s: RX Auth SA=%pM DA=%pM BSSID=%pM."
-	       "(auth_transaction=%d)\n",
-	       sdata->name, mgmt->sa, mgmt->da, mgmt->bssid, auth_transaction);
+	pr_debug("%s: RX Auth SA=%pM DA=%pM BSSID=%pM (auth_transaction=%d)\n",
+		 sdata->name, mgmt->sa, mgmt->da, mgmt->bssid,
+		 auth_transaction);
 #endif
 	sta_info_destroy_addr(sdata, mgmt->sa);
 	ieee80211_ibss_add_sta(sdata, mgmt->bssid, mgmt->sa, 0, false);
@@ -418,13 +417,10 @@ static void ieee80211_rx_bss_info(struct ieee80211_sub_if_data *sdata,
 
 				if (sta->sta.supp_rates[band] != prev_rates) {
 #ifdef CONFIG_MAC80211_IBSS_DEBUG
-					printk(KERN_DEBUG
-						"%s: updated supp_rates set "
-						"for %pM based on beacon"
-						"/probe_resp (0x%x -> 0x%x)\n",
-						sdata->name, sta->sta.addr,
-						prev_rates,
-						sta->sta.supp_rates[band]);
+					pr_debug("%s: updated supp_rates set for %pM based on beacon/probe_resp (0x%x -> 0x%x)\n",
+						 sdata->name, sta->sta.addr,
+						 prev_rates,
+						 sta->sta.supp_rates[band]);
 #endif
 					rates_updated = true;
 				}
@@ -541,20 +537,18 @@ static void ieee80211_rx_bss_info(struct ieee80211_sub_if_data *sdata,
 	}
 
 #ifdef CONFIG_MAC80211_IBSS_DEBUG
-	printk(KERN_DEBUG "RX beacon SA=%pM BSSID="
-	       "%pM TSF=0x%llx BCN=0x%llx diff=%lld @%lu\n",
-	       mgmt->sa, mgmt->bssid,
-	       (unsigned long long)rx_timestamp,
-	       (unsigned long long)beacon_timestamp,
-	       (unsigned long long)(rx_timestamp - beacon_timestamp),
-	       jiffies);
+	pr_debug("RX beacon SA=%pM BSSID=%pM TSF=0x%llx BCN=0x%llx diff=%lld @%lu\n",
+		 mgmt->sa, mgmt->bssid,
+		 (unsigned long long)rx_timestamp,
+		 (unsigned long long)beacon_timestamp,
+		 (unsigned long long)(rx_timestamp - beacon_timestamp),
+		 jiffies);
 #endif
 
 	if (beacon_timestamp > rx_timestamp) {
 #ifdef CONFIG_MAC80211_IBSS_DEBUG
-		printk(KERN_DEBUG "%s: beacon TSF higher than "
-		       "local TSF - IBSS merge with BSSID %pM\n",
-		       sdata->name, mgmt->bssid);
+		pr_debug("%s: beacon TSF higher than local TSF - IBSS merge with BSSID %pM\n",
+			 sdata->name, mgmt->bssid);
 #endif
 		ieee80211_sta_join_ibss(sdata, bss);
 		supp_rates = ieee80211_sta_get_rates(local, elems, band, NULL);
@@ -657,8 +651,8 @@ static void ieee80211_sta_merge_ibss(struct ieee80211_sub_if_data *sdata)
 	if (ifibss->fixed_channel)
 		return;
 
-	printk(KERN_DEBUG "%s: No active IBSS STAs - trying to scan for other "
-	       "IBSS networks with same SSID (merge)\n", sdata->name);
+	pr_debug("%s: No active IBSS STAs - trying to scan for other IBSS networks with same SSID (merge)\n",
+		 sdata->name);
 
 	ieee80211_request_internal_scan(sdata,
 			ifibss->ssid, ifibss->ssid_len, NULL);
@@ -686,8 +680,8 @@ static void ieee80211_sta_create_ibss(struct ieee80211_sub_if_data *sdata)
 		bssid[0] |= 0x02;
 	}
 
-	printk(KERN_DEBUG "%s: Creating new IBSS network, BSSID %pM\n",
-	       sdata->name, bssid);
+	pr_debug("%s: Creating new IBSS network, BSSID %pM\n",
+		 sdata->name, bssid);
 
 	capability = WLAN_CAPABILITY_IBSS;
 
@@ -719,8 +713,8 @@ static void ieee80211_sta_find_ibss(struct ieee80211_sub_if_data *sdata)
 
 	active_ibss = ieee80211_sta_active_ibss(sdata);
 #ifdef CONFIG_MAC80211_IBSS_DEBUG
-	printk(KERN_DEBUG "%s: sta_find_ibss (active_ibss=%d)\n",
-	       sdata->name, active_ibss);
+	pr_debug("%s: sta_find_ibss (active_ibss=%d)\n",
+		 sdata->name, active_ibss);
 #endif /* CONFIG_MAC80211_IBSS_DEBUG */
 
 	if (active_ibss)
@@ -745,13 +739,12 @@ static void ieee80211_sta_find_ibss(struct ieee80211_sub_if_data *sdata)
 
 		bss = (void *)cbss->priv;
 #ifdef CONFIG_MAC80211_IBSS_DEBUG
-		printk(KERN_DEBUG "   sta_find_ibss: selected %pM current "
-		       "%pM\n", cbss->bssid, ifibss->bssid);
+		pr_debug("   sta_find_ibss: selected %pM current %pM\n",
+			 cbss->bssid, ifibss->bssid);
 #endif /* CONFIG_MAC80211_IBSS_DEBUG */
 
-		printk(KERN_DEBUG "%s: Selected IBSS BSSID %pM"
-		       " based on configured SSID\n",
-		       sdata->name, cbss->bssid);
+		pr_debug("%s: Selected IBSS BSSID %pM based on configured SSID\n",
+			 sdata->name, cbss->bssid);
 
 		ieee80211_sta_join_ibss(sdata, bss);
 		ieee80211_rx_bss_put(local, bss);
@@ -759,14 +752,14 @@ static void ieee80211_sta_find_ibss(struct ieee80211_sub_if_data *sdata)
 	}
 
 #ifdef CONFIG_MAC80211_IBSS_DEBUG
-	printk(KERN_DEBUG "   did not try to join ibss\n");
+	pr_debug("   did not try to join ibss\n");
 #endif /* CONFIG_MAC80211_IBSS_DEBUG */
 
 	/* Selected IBSS not found in current scan results - try to scan */
 	if (time_after(jiffies, ifibss->last_scan_completed +
 					IEEE80211_SCAN_INTERVAL)) {
-		printk(KERN_DEBUG "%s: Trigger new scan to find an IBSS to "
-		       "join\n", sdata->name);
+		pr_debug("%s: Trigger new scan to find an IBSS to join\n",
+			 sdata->name);
 
 		ieee80211_request_internal_scan(sdata,
 				ifibss->ssid, ifibss->ssid_len,
@@ -780,9 +773,9 @@ static void ieee80211_sta_find_ibss(struct ieee80211_sub_if_data *sdata)
 				ieee80211_sta_create_ibss(sdata);
 				return;
 			}
-			printk(KERN_DEBUG "%s: IBSS not allowed on"
-			       " %d MHz\n", sdata->name,
-			       local->hw.conf.channel->center_freq);
+			pr_debug("%s: IBSS not allowed on %d MHz\n",
+				 sdata->name,
+				 local->hw.conf.channel->center_freq);
 
 			/* No IBSS found - decrease scan interval and continue
 			 * scanning. */
@@ -818,10 +811,9 @@ static void ieee80211_rx_mgmt_probe_req(struct ieee80211_sub_if_data *sdata,
 	tx_last_beacon = drv_tx_last_beacon(local);
 
 #ifdef CONFIG_MAC80211_IBSS_DEBUG
-	printk(KERN_DEBUG "%s: RX ProbeReq SA=%pM DA=%pM BSSID=%pM"
-	       " (tx_last_beacon=%d)\n",
-	       sdata->name, mgmt->sa, mgmt->da,
-	       mgmt->bssid, tx_last_beacon);
+	pr_debug("%s: RX ProbeReq SA=%pM DA=%pM BSSID=%pM (tx_last_beacon=%d)\n",
+		 sdata->name, mgmt->sa, mgmt->da,
+		 mgmt->bssid, tx_last_beacon);
 #endif /* CONFIG_MAC80211_IBSS_DEBUG */
 
 	if (!tx_last_beacon && is_multicast_ether_addr(mgmt->da))
@@ -836,9 +828,8 @@ static void ieee80211_rx_mgmt_probe_req(struct ieee80211_sub_if_data *sdata,
 	if (pos[0] != WLAN_EID_SSID ||
 	    pos + 2 + pos[1] > end) {
 #ifdef CONFIG_MAC80211_IBSS_DEBUG
-		printk(KERN_DEBUG "%s: Invalid SSID IE in ProbeReq "
-		       "from %pM\n",
-		       sdata->name, mgmt->sa);
+		pr_debug("%s: Invalid SSID IE in ProbeReq from %pM\n",
+			 sdata->name, mgmt->sa);
 #endif
 		return;
 	}
@@ -857,8 +848,7 @@ static void ieee80211_rx_mgmt_probe_req(struct ieee80211_sub_if_data *sdata,
 	resp = (struct ieee80211_mgmt *) skb->data;
 	memcpy(resp->da, mgmt->sa, ETH_ALEN);
 #ifdef CONFIG_MAC80211_IBSS_DEBUG
-	printk(KERN_DEBUG "%s: Sending ProbeResp to %pM\n",
-	       sdata->name, resp->da);
+	pr_debug("%s: Sending ProbeResp to %pM\n", sdata->name, resp->da);
 #endif /* CONFIG_MAC80211_IBSS_DEBUG */
 	IEEE80211_SKB_CB(skb)->flags |= IEEE80211_TX_INTFL_DONT_ENCRYPT;
 	ieee80211_tx_skb(sdata, skb);
diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index 856237c..9230ccf 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -58,7 +58,7 @@ static int ieee80211_change_mtu(struct net_device *dev, int new_mtu)
 	}
 
 #ifdef CONFIG_MAC80211_VERBOSE_DEBUG
-	printk(KERN_DEBUG "%s: setting MTU %d\n", dev->name, new_mtu);
+	pr_debug("%s: setting MTU %d\n", dev->name, new_mtu);
 #endif /* CONFIG_MAC80211_VERBOSE_DEBUG */
 	dev->mtu = new_mtu;
 	return 0;
@@ -1224,7 +1224,7 @@ static void ieee80211_assign_perm_addr(struct ieee80211_local *local,
 
 		if (__ffs64(mask) + hweight64(mask) != fls64(mask)) {
 			/* not a contiguous mask ... not handled now! */
-			printk(KERN_DEBUG "not contiguous\n");
+			pr_debug("not contiguous\n");
 			break;
 		}
 
diff --git a/net/mac80211/mesh.c b/net/mac80211/mesh.c
index 0675a2f..7c253c0 100644
--- a/net/mac80211/mesh.c
+++ b/net/mac80211/mesh.c
@@ -522,8 +522,7 @@ static void ieee80211_mesh_housekeeping(struct ieee80211_sub_if_data *sdata,
 	bool free_plinks;
 
 #ifdef CONFIG_MAC80211_VERBOSE_DEBUG
-	printk(KERN_DEBUG "%s: running mesh housekeeping\n",
-	       sdata->name);
+	pr_debug("%s: running mesh housekeeping\n", sdata->name);
 #endif
 
 	ieee80211_sta_expire(sdata, IEEE80211_MESH_PEER_INACTIVITY_LIMIT);
diff --git a/net/mac80211/mesh_hwmp.c b/net/mac80211/mesh_hwmp.c
index 27e0c2f..b344178 100644
--- a/net/mac80211/mesh_hwmp.c
+++ b/net/mac80211/mesh_hwmp.c
@@ -15,7 +15,7 @@
 
 #ifdef CONFIG_MAC80211_VERBOSE_MHWMP_DEBUG
 #define mhwmp_dbg(fmt, args...) \
-	printk(KERN_DEBUG "Mesh HWMP (%s): " fmt "\n", sdata->name, ##args)
+	pr_debug("Mesh HWMP (%s): " fmt "\n", sdata->name, ##args)
 #else
 #define mhwmp_dbg(fmt, args...)   do { (void)(0); } while (0)
 #endif
diff --git a/net/mac80211/mesh_pathtbl.c b/net/mac80211/mesh_pathtbl.c
index b39224d..572f706 100644
--- a/net/mac80211/mesh_pathtbl.c
+++ b/net/mac80211/mesh_pathtbl.c
@@ -19,7 +19,7 @@
 #include "mesh.h"
 
 #ifdef CONFIG_MAC80211_VERBOSE_MPATH_DEBUG
-#define mpath_dbg(fmt, args...)	printk(KERN_DEBUG fmt, ##args)
+#define mpath_dbg(fmt, args...)	pr_debug(fmt, ##args)
 #else
 #define mpath_dbg(fmt, args...)	do { (void)(0); } while (0)
 #endif
diff --git a/net/mac80211/mesh_plink.c b/net/mac80211/mesh_plink.c
index 8cc8461..4979019 100644
--- a/net/mac80211/mesh_plink.c
+++ b/net/mac80211/mesh_plink.c
@@ -14,7 +14,7 @@
 #include "mesh.h"
 
 #ifdef CONFIG_MAC80211_VERBOSE_MPL_DEBUG
-#define mpl_dbg(fmt, args...)	printk(KERN_DEBUG fmt, ##args)
+#define mpl_dbg(fmt, args...)	pr_debug(fmt, ##args)
 #else
 #define mpl_dbg(fmt, args...)	do { (void)(0); } while (0)
 #endif
diff --git a/net/mac80211/mesh_sync.c b/net/mac80211/mesh_sync.c
index 38d30e8..0ccdad4 100644
--- a/net/mac80211/mesh_sync.c
+++ b/net/mac80211/mesh_sync.c
@@ -14,7 +14,7 @@
 
 #ifdef CONFIG_MAC80211_VERBOSE_MESH_SYNC_DEBUG
 #define msync_dbg(fmt, args...) \
-	printk(KERN_DEBUG "Mesh sync (%s): " fmt "\n", sdata->name, ##args)
+	pr_debug("Mesh sync (%s): " fmt "\n", sdata->name, ##args)
 #else
 #define msync_dbg(fmt, args...)   do { (void)(0); } while (0)
 #endif
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index b3b3c26..5ec40b1 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -1653,8 +1653,7 @@ static void __ieee80211_connection_loss(struct ieee80211_sub_if_data *sdata)
 
 	memcpy(bssid, ifmgd->associated->bssid, ETH_ALEN);
 
-	printk(KERN_DEBUG "%s: Connection to AP %pM lost.\n",
-	       sdata->name, bssid);
+	pr_debug("%s: Connection to AP %pM lost\n", sdata->name, bssid);
 
 	ieee80211_set_disassoc(sdata, IEEE80211_STYPE_DEAUTH,
 			       WLAN_REASON_DISASSOC_DUE_TO_INACTIVITY,
@@ -1788,8 +1787,8 @@ ieee80211_rx_mgmt_auth(struct ieee80211_sub_if_data *sdata,
 		return RX_MGMT_NONE;
 
 	if (status_code != WLAN_STATUS_SUCCESS) {
-		printk(KERN_DEBUG "%s: %pM denied authentication (status %d)\n",
-		       sdata->name, mgmt->sa, status_code);
+		pr_debug("%s: %pM denied authentication (status %d)\n",
+			 sdata->name, mgmt->sa, status_code);
 		goto out;
 	}
 
@@ -1811,7 +1810,7 @@ ieee80211_rx_mgmt_auth(struct ieee80211_sub_if_data *sdata,
 		return RX_MGMT_NONE;
 	}
 
-	printk(KERN_DEBUG "%s: authenticated\n", sdata->name);
+	pr_debug("%s: authenticated\n", sdata->name);
  out:
 	ifmgd->auth_data->done = true;
 	ifmgd->auth_data->timeout = jiffies + IEEE80211_AUTH_WAIT_ASSOC;
@@ -1825,8 +1824,7 @@ ieee80211_rx_mgmt_auth(struct ieee80211_sub_if_data *sdata,
 		goto out_err;
 	}
 	if (sta_info_move_state(sta, IEEE80211_STA_AUTH)) {
-		printk(KERN_DEBUG "%s: failed moving %pM to auth\n",
-		       sdata->name, bssid);
+		pr_debug("%s: failed moving %pM to auth\n", sdata->name, bssid);
 		goto out_err;
 	}
 	mutex_unlock(&sdata->local->sta_mtx);
@@ -1860,8 +1858,8 @@ ieee80211_rx_mgmt_deauth(struct ieee80211_sub_if_data *sdata,
 
 	reason_code = le16_to_cpu(mgmt->u.deauth.reason_code);
 
-	printk(KERN_DEBUG "%s: deauthenticated from %pM (Reason: %u)\n",
-			sdata->name, bssid, reason_code);
+	pr_debug("%s: deauthenticated from %pM (Reason: %u)\n",
+		 sdata->name, bssid, reason_code);
 
 	ieee80211_set_disassoc(sdata, 0, 0, false, NULL);
 
@@ -1891,8 +1889,8 @@ ieee80211_rx_mgmt_disassoc(struct ieee80211_sub_if_data *sdata,
 
 	reason_code = le16_to_cpu(mgmt->u.disassoc.reason_code);
 
-	printk(KERN_DEBUG "%s: disassociated from %pM (Reason: %u)\n",
-			sdata->name, mgmt->sa, reason_code);
+	pr_debug("%s: disassociated from %pM (Reason: %u)\n",
+		 sdata->name, mgmt->sa, reason_code);
 
 	ieee80211_set_disassoc(sdata, 0, 0, false, NULL);
 
@@ -1984,17 +1982,15 @@ static bool ieee80211_assoc_success(struct ieee80211_sub_if_data *sdata,
 	capab_info = le16_to_cpu(mgmt->u.assoc_resp.capab_info);
 
 	if ((aid & (BIT(15) | BIT(14))) != (BIT(15) | BIT(14)))
-		printk(KERN_DEBUG
-		       "%s: invalid AID value 0x%x; bits 15:14 not set\n",
-		       sdata->name, aid);
+		pr_debug("%s: invalid AID value 0x%x; bits 15:14 not set\n",
+			 sdata->name, aid);
 	aid &= ~(BIT(15) | BIT(14));
 
 	ifmgd->broken_ap = false;
 
 	if (aid == 0 || aid > IEEE80211_MAX_AID) {
-		printk(KERN_DEBUG
-		       "%s: invalid AID value %d (out of range), turn off PS\n",
-		       sdata->name, aid);
+		pr_debug("%s: invalid AID value %d (out of range), turn off PS\n",
+			 sdata->name, aid);
 		aid = 0;
 		ifmgd->broken_ap = true;
 	}
@@ -2003,8 +1999,8 @@ static bool ieee80211_assoc_success(struct ieee80211_sub_if_data *sdata,
 	ieee802_11_parse_elems(pos, len - (pos - (u8 *) mgmt), &elems);
 
 	if (!elems.supp_rates) {
-		printk(KERN_DEBUG "%s: no SuppRates element in AssocResp\n",
-		       sdata->name);
+		pr_debug("%s: no SuppRates element in AssocResp\n",
+			 sdata->name);
 		return false;
 	}
 
@@ -2044,9 +2040,8 @@ static bool ieee80211_assoc_success(struct ieee80211_sub_if_data *sdata,
 	if (!err && !(ifmgd->flags & IEEE80211_STA_CONTROL_PORT))
 		err = sta_info_move_state(sta, IEEE80211_STA_AUTHORIZED);
 	if (err) {
-		printk(KERN_DEBUG
-		       "%s: failed to move station %pM to desired state\n",
-		       sdata->name, sta->sta.addr);
+		pr_debug("%s: failed to move station %pM to desired state\n",
+			 sdata->name, sta->sta.addr);
 		WARN_ON(__sta_info_destroy(sta));
 		mutex_unlock(&sdata->local->sta_mtx);
 		return false;
@@ -2129,10 +2124,9 @@ ieee80211_rx_mgmt_assoc_resp(struct ieee80211_sub_if_data *sdata,
 	status_code = le16_to_cpu(mgmt->u.assoc_resp.status_code);
 	aid = le16_to_cpu(mgmt->u.assoc_resp.aid);
 
-	printk(KERN_DEBUG "%s: RX %sssocResp from %pM (capab=0x%x "
-	       "status=%d aid=%d)\n",
-	       sdata->name, reassoc ? "Rea" : "A", mgmt->sa,
-	       capab_info, status_code, (u16)(aid & ~(BIT(15) | BIT(14))));
+	pr_debug("%s: RX %sssocResp from %pM (capab=0x%x status=%d aid=%d)\n",
+		 sdata->name, reassoc ? "Rea" : "A", mgmt->sa,
+		 capab_info, status_code, (u16)(aid & ~(BIT(15) | BIT(14))));
 
 	pos = mgmt->u.assoc_resp.variable;
 	ieee802_11_parse_elems(pos, len - (pos - (u8 *) mgmt), &elems);
@@ -2143,9 +2137,8 @@ ieee80211_rx_mgmt_assoc_resp(struct ieee80211_sub_if_data *sdata,
 		u32 tu, ms;
 		tu = get_unaligned_le32(elems.timeout_int + 1);
 		ms = tu * 1024 / 1000;
-		printk(KERN_DEBUG "%s: %pM rejected association temporarily; "
-		       "comeback duration %u TU (%u ms)\n",
-		       sdata->name, mgmt->sa, tu, ms);
+		pr_debug("%s: %pM rejected association temporarily; comeback duration %u TU (%u ms)\n",
+			 sdata->name, mgmt->sa, tu, ms);
 		assoc_data->timeout = jiffies + msecs_to_jiffies(ms);
 		if (ms > IEEE80211_ASSOC_TIMEOUT)
 			run_again(ifmgd, assoc_data->timeout);
@@ -2155,11 +2148,11 @@ ieee80211_rx_mgmt_assoc_resp(struct ieee80211_sub_if_data *sdata,
 	*bss = assoc_data->bss;
 
 	if (status_code != WLAN_STATUS_SUCCESS) {
-		printk(KERN_DEBUG "%s: %pM denied association (code=%d)\n",
-		       sdata->name, mgmt->sa, status_code);
+		pr_debug("%s: %pM denied association (code=%d)\n",
+			 sdata->name, mgmt->sa, status_code);
 		ieee80211_destroy_assoc_data(sdata, false);
 	} else {
-		printk(KERN_DEBUG "%s: associated\n", sdata->name);
+		pr_debug("%s: associated\n", sdata->name);
 
 		if (!ieee80211_assoc_success(sdata, *bss, mgmt, len)) {
 			/* oops -- internal error -- send timeout for now */
@@ -2267,7 +2260,7 @@ static void ieee80211_rx_mgmt_probe_resp(struct ieee80211_sub_if_data *sdata,
 	if (ifmgd->auth_data && !ifmgd->auth_data->bss->proberesp_ies &&
 	    ether_addr_equal(mgmt->bssid, ifmgd->auth_data->bss->bssid)) {
 		/* got probe response, continue with auth */
-		printk(KERN_DEBUG "%s: direct probe responded\n", sdata->name);
+		pr_debug("%s: direct probe responded\n", sdata->name);
 		ifmgd->auth_data->tries = 0;
 		ifmgd->auth_data->timeout = jiffies;
 		run_again(ifmgd, ifmgd->auth_data->timeout);
@@ -2628,8 +2621,8 @@ static int ieee80211_probe_auth(struct ieee80211_sub_if_data *sdata)
 	auth_data->tries++;
 
 	if (auth_data->tries > IEEE80211_AUTH_MAX_TRIES) {
-		printk(KERN_DEBUG "%s: authentication with %pM timed out\n",
-		       sdata->name, auth_data->bss->bssid);
+		pr_debug("%s: authentication with %pM timed out\n",
+			 sdata->name, auth_data->bss->bssid);
 
 		/*
 		 * Most likely AP is not in the range so remove the
@@ -2641,9 +2634,9 @@ static int ieee80211_probe_auth(struct ieee80211_sub_if_data *sdata)
 	}
 
 	if (auth_data->bss->proberesp_ies) {
-		printk(KERN_DEBUG "%s: send auth to %pM (try %d/%d)\n",
-		       sdata->name, auth_data->bss->bssid, auth_data->tries,
-		       IEEE80211_AUTH_MAX_TRIES);
+		pr_debug("%s: send auth to %pM (try %d/%d)\n",
+			 sdata->name, auth_data->bss->bssid, auth_data->tries,
+			 IEEE80211_AUTH_MAX_TRIES);
 
 		auth_data->expected_transaction = 2;
 		ieee80211_send_auth(sdata, 1, auth_data->algorithm,
@@ -2653,9 +2646,9 @@ static int ieee80211_probe_auth(struct ieee80211_sub_if_data *sdata)
 	} else {
 		const u8 *ssidie;
 
-		printk(KERN_DEBUG "%s: direct probe to %pM (try %d/%i)\n",
-		       sdata->name, auth_data->bss->bssid, auth_data->tries,
-		       IEEE80211_AUTH_MAX_TRIES);
+		pr_debug("%s: direct probe to %pM (try %d/%i)\n",
+			 sdata->name, auth_data->bss->bssid, auth_data->tries,
+			 IEEE80211_AUTH_MAX_TRIES);
 
 		ssidie = ieee80211_bss_get_ie(auth_data->bss, WLAN_EID_SSID);
 		if (!ssidie)
@@ -2683,8 +2676,8 @@ static int ieee80211_do_assoc(struct ieee80211_sub_if_data *sdata)
 
 	assoc_data->tries++;
 	if (assoc_data->tries > IEEE80211_ASSOC_MAX_TRIES) {
-		printk(KERN_DEBUG "%s: association with %pM timed out\n",
-		       sdata->name, assoc_data->bss->bssid);
+		pr_debug("%s: association with %pM timed out\n",
+			 sdata->name, assoc_data->bss->bssid);
 
 		/*
 		 * Most likely AP is not in the range so remove the
@@ -2695,9 +2688,9 @@ static int ieee80211_do_assoc(struct ieee80211_sub_if_data *sdata)
 		return -ETIMEDOUT;
 	}
 
-	printk(KERN_DEBUG "%s: associate with %pM (try %d/%d)\n",
-	       sdata->name, assoc_data->bss->bssid, assoc_data->tries,
-	       IEEE80211_ASSOC_MAX_TRIES);
+	pr_debug("%s: associate with %pM (try %d/%d)\n",
+		 sdata->name, assoc_data->bss->bssid, assoc_data->tries,
+		 IEEE80211_ASSOC_MAX_TRIES);
 	ieee80211_send_assoc(sdata);
 
 	assoc_data->timeout = jiffies + IEEE80211_ASSOC_TIMEOUT;
@@ -3066,13 +3059,10 @@ static int ieee80211_prep_connection(struct ieee80211_sub_if_data *sdata,
 			 * since we look at probe response/beacon data here
 			 * it should be OK.
 			 */
-			printk(KERN_DEBUG
-			       "%s: Wrong control channel: center-freq: %d"
-			       " ht-cfreq: %d ht->primary_chan: %d"
-			       " band: %d. Disabling HT.\n",
-			       sdata->name, cbss->channel->center_freq,
-			       ht_cfreq, ht_oper->primary_chan,
-			       cbss->channel->band);
+			pr_debug("%s: Wrong control channel: center-freq: %d ht-cfreq: %d ht->primary_chan: %d band: %d - Disabling HT\n",
+				 sdata->name, cbss->channel->center_freq,
+				 ht_cfreq, ht_oper->primary_chan,
+				 cbss->channel->band);
 			ht_oper = NULL;
 		}
 	}
@@ -3096,9 +3086,8 @@ static int ieee80211_prep_connection(struct ieee80211_sub_if_data *sdata,
 	if (!ieee80211_set_channel_type(local, sdata, channel_type)) {
 		/* can only fail due to HT40+/- mismatch */
 		channel_type = NL80211_CHAN_HT20;
-		printk(KERN_DEBUG
-		       "%s: disabling 40 MHz due to multi-vif mismatch\n",
-		       sdata->name);
+		pr_debug("%s: disabling 40 MHz due to multi-vif mismatch\n",
+			 sdata->name);
 		ifmgd->flags |= IEEE80211_STA_DISABLE_40MHZ;
 		WARN_ON(!ieee80211_set_channel_type(local, sdata,
 						    channel_type));
@@ -3127,9 +3116,8 @@ static int ieee80211_prep_connection(struct ieee80211_sub_if_data *sdata,
 		 * we can connect -- with a warning.
 		 */
 		if (!basic_rates && min_rate_index >= 0) {
-			printk(KERN_DEBUG
-			       "%s: No basic rates, using min rate instead.\n",
-			       sdata->name);
+			pr_debug("%s: No basic rates, using min rate instead\n",
+				 sdata->name);
 			basic_rates = BIT(min_rate_index);
 		}
 
@@ -3155,9 +3143,8 @@ static int ieee80211_prep_connection(struct ieee80211_sub_if_data *sdata,
 		err = sta_info_insert(sta);
 		sta = NULL;
 		if (err) {
-			printk(KERN_DEBUG
-			       "%s: failed to insert STA entry for the AP (error %d)\n",
-			       sdata->name, err);
+			pr_debug("%s: failed to insert STA entry for the AP (error %d)\n",
+				 sdata->name, err);
 			return err;
 		}
 	} else
@@ -3235,8 +3222,7 @@ int ieee80211_mgd_auth(struct ieee80211_sub_if_data *sdata,
 	if (ifmgd->associated)
 		ieee80211_set_disassoc(sdata, 0, 0, false, NULL);
 
-	printk(KERN_DEBUG "%s: authenticate with %pM\n",
-	       sdata->name, req->bss->bssid);
+	pr_debug("%s: authenticate with %pM\n", sdata->name, req->bss->bssid);
 
 	err = ieee80211_prep_connection(sdata, req->bss, false);
 	if (err)
@@ -3406,8 +3392,8 @@ int ieee80211_mgd_assoc(struct ieee80211_sub_if_data *sdata,
 		 * Wait up to one beacon interval ...
 		 * should this be more if we miss one?
 		 */
-		printk(KERN_DEBUG "%s: waiting for beacon from %pM\n",
-		       sdata->name, ifmgd->bssid);
+		pr_debug("%s: waiting for beacon from %pM\n",
+			 sdata->name, ifmgd->bssid);
 		assoc_data->timeout = TU_TO_EXP_TIME(req->bss->beacon_interval);
 	} else {
 		assoc_data->have_beacon = true;
@@ -3426,8 +3412,8 @@ int ieee80211_mgd_assoc(struct ieee80211_sub_if_data *sdata,
 				corrupt_type = "beacon";
 		} else if (bss->corrupt_data & IEEE80211_BSS_CORRUPT_PROBE_RESP)
 			corrupt_type = "probe response";
-		printk(KERN_DEBUG "%s: associating with AP with corrupt %s\n",
-		       sdata->name, corrupt_type);
+		pr_debug("%s: associating with AP with corrupt %s\n",
+			 sdata->name, corrupt_type);
 	}
 
 	err = 0;
@@ -3456,9 +3442,8 @@ int ieee80211_mgd_deauth(struct ieee80211_sub_if_data *sdata,
 		return 0;
 	}
 
-	printk(KERN_DEBUG
-	       "%s: deauthenticating from %pM by local choice (reason=%d)\n",
-	       sdata->name, req->bssid, req->reason_code);
+	pr_debug("%s: deauthenticating from %pM by local choice (reason=%d)\n",
+		 sdata->name, req->bssid, req->reason_code);
 
 	if (ifmgd->associated &&
 	    ether_addr_equal(ifmgd->associated->bssid, req->bssid))
@@ -3500,8 +3485,8 @@ int ieee80211_mgd_disassoc(struct ieee80211_sub_if_data *sdata,
 		return -ENOLINK;
 	}
 
-	printk(KERN_DEBUG "%s: disassociating from %pM by local choice (reason=%d)\n",
-	       sdata->name, req->bss->bssid, req->reason_code);
+	pr_debug("%s: disassociating from %pM by local choice (reason=%d)\n",
+		 sdata->name, req->bss->bssid, req->reason_code);
 
 	memcpy(bssid, req->bss->bssid, ETH_ALEN);
 	ieee80211_set_disassoc(sdata, IEEE80211_STYPE_DISASSOC,
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 8257a09..3c07a3f 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -1137,22 +1137,22 @@ static void ap_sta_ps_start(struct sta_info *sta)
 	if (!(local->hw.flags & IEEE80211_HW_AP_LINK_PS))
 		drv_sta_notify(local, sdata, STA_NOTIFY_SLEEP, &sta->sta);
 #ifdef CONFIG_MAC80211_VERBOSE_PS_DEBUG
-	printk(KERN_DEBUG "%s: STA %pM aid %d enters power save mode\n",
-	       sdata->name, sta->sta.addr, sta->sta.aid);
+	pr_debug("%s: STA %pM aid %d enters power save mode\n",
+		 sdata->name, sta->sta.addr, sta->sta.aid);
 #endif /* CONFIG_MAC80211_VERBOSE_PS_DEBUG */
 }
 
 static void ap_sta_ps_end(struct sta_info *sta)
 {
 #ifdef CONFIG_MAC80211_VERBOSE_PS_DEBUG
-	printk(KERN_DEBUG "%s: STA %pM aid %d exits power save mode\n",
-	       sta->sdata->name, sta->sta.addr, sta->sta.aid);
+	pr_debug("%s: STA %pM aid %d exits power save mode\n",
+		 sta->sdata->name, sta->sta.addr, sta->sta.aid);
 #endif /* CONFIG_MAC80211_VERBOSE_PS_DEBUG */
 
 	if (test_sta_flag(sta, WLAN_STA_PS_DRIVER)) {
 #ifdef CONFIG_MAC80211_VERBOSE_PS_DEBUG
-		printk(KERN_DEBUG "%s: STA %pM aid %d driver-ps-blocked\n",
-		       sta->sdata->name, sta->sta.addr, sta->sta.aid);
+		pr_debug("%s: STA %pM aid %d driver-ps-blocked\n",
+			 sta->sdata->name, sta->sta.addr, sta->sta.aid);
 #endif /* CONFIG_MAC80211_VERBOSE_PS_DEBUG */
 		return;
 	}
@@ -1387,12 +1387,10 @@ ieee80211_reassemble_add(struct ieee80211_sub_if_data *sdata,
 #ifdef CONFIG_MAC80211_VERBOSE_DEBUG
 		struct ieee80211_hdr *hdr =
 			(struct ieee80211_hdr *) entry->skb_list.next->data;
-		printk(KERN_DEBUG "%s: RX reassembly removed oldest "
-		       "fragment entry (idx=%d age=%lu seq=%d last_frag=%d "
-		       "addr1=%pM addr2=%pM\n",
-		       sdata->name, idx,
-		       jiffies - entry->first_frag_time, entry->seq,
-		       entry->last_frag, hdr->addr1, hdr->addr2);
+		pr_debug("%s: RX reassembly removed oldest fragment entry (idx=%d age=%lu seq=%d last_frag=%d addr1=%pM addr2=%pM\n",
+			 sdata->name, idx,
+			 jiffies - entry->first_frag_time, entry->seq,
+			 entry->last_frag, hdr->addr1, hdr->addr2);
 #endif
 		__skb_queue_purge(&entry->skb_list);
 	}
diff --git a/net/mac80211/sta_info.c b/net/mac80211/sta_info.c
index f5b1638..4be5098 100644
--- a/net/mac80211/sta_info.c
+++ b/net/mac80211/sta_info.c
@@ -333,9 +333,8 @@ static int sta_info_insert_drv_state(struct ieee80211_local *local,
 	}
 
 	if (sdata->vif.type == NL80211_IFTYPE_ADHOC) {
-		printk(KERN_DEBUG
-		       "%s: failed to move IBSS STA %pM to state %d (%d) - keeping it anyway.\n",
-		       sdata->name, sta->sta.addr, state + 1, err);
+		pr_debug("%s: failed to move IBSS STA %pM to state %d (%d) - keeping it anyway\n",
+			 sdata->name, sta->sta.addr, state + 1, err);
 		err = 0;
 	}
 
@@ -619,8 +618,7 @@ static bool sta_info_cleanup_expire_buffered_ac(struct ieee80211_local *local,
 
 		local->total_ps_buffered--;
 #ifdef CONFIG_MAC80211_VERBOSE_PS_DEBUG
-		printk(KERN_DEBUG "Buffered frame expired (STA %pM)\n",
-		       sta->sta.addr);
+		pr_debug("Buffered frame expired (STA %pM)\n", sta->sta.addr);
 #endif
 		dev_kfree_skb(skb);
 	}
@@ -890,8 +888,8 @@ void ieee80211_sta_expire(struct ieee80211_sub_if_data *sdata,
 
 		if (time_after(jiffies, sta->last_rx + exp_time)) {
 #ifdef CONFIG_MAC80211_IBSS_DEBUG
-			printk(KERN_DEBUG "%s: expiring inactive STA %pM\n",
-			       sdata->name, sta->sta.addr);
+			pr_debug("%s: expiring inactive STA %pM\n",
+				 sdata->name, sta->sta.addr);
 #endif
 			WARN_ON(__sta_info_destroy(sta));
 		}
@@ -991,9 +989,8 @@ void ieee80211_sta_ps_deliver_wakeup(struct sta_info *sta)
 	sta_info_recalc_tim(sta);
 
 #ifdef CONFIG_MAC80211_VERBOSE_PS_DEBUG
-	printk(KERN_DEBUG "%s: STA %pM aid %d sending %d filtered/%d PS frames "
-	       "since STA not sleeping anymore\n", sdata->name,
-	       sta->sta.addr, sta->sta.aid, filtered, buffered);
+	pr_debug("%s: STA %pM aid %d sending %d filtered/%d PS frames since STA not sleeping anymore\n",
+		 sdata->name, sta->sta.addr, sta->sta.aid, filtered, buffered);
 #endif /* CONFIG_MAC80211_VERBOSE_PS_DEBUG */
 }
 
@@ -1385,8 +1382,8 @@ int sta_info_move_state(struct sta_info *sta,
 	}
 
 #ifdef CONFIG_MAC80211_VERBOSE_DEBUG
-	printk(KERN_DEBUG "%s: moving STA %pM to state %d\n",
-		sta->sdata->name, sta->sta.addr, new_state);
+	pr_debug("%s: moving STA %pM to state %d\n",
+		 sta->sdata->name, sta->sta.addr, new_state);
 #endif
 
 	/*
diff --git a/net/mac80211/status.c b/net/mac80211/status.c
index 28cfa98..63a7690 100644
--- a/net/mac80211/status.c
+++ b/net/mac80211/status.c
@@ -589,7 +589,7 @@ void ieee80211_tx_status(struct ieee80211_hw *hw, struct sk_buff *skb)
 	/* send frame to monitor interfaces now */
 	rtap_len = ieee80211_tx_radiotap_len(info);
 	if (WARN_ON_ONCE(skb_headroom(skb) < rtap_len)) {
-		printk(KERN_ERR "ieee80211_tx_status: headroom too small\n");
+		pr_err("ieee80211_tx_status: headroom too small\n");
 		dev_kfree_skb(skb);
 		return;
 	}
diff --git a/net/mac80211/tkip.c b/net/mac80211/tkip.c
index 51077a9..68be47c 100644
--- a/net/mac80211/tkip.c
+++ b/net/mac80211/tkip.c
@@ -263,12 +263,11 @@ int ieee80211_tkip_decrypt_data(struct crypto_cipher *tfm,
 #ifdef CONFIG_MAC80211_TKIP_DEBUG
 	{
 		int i;
-		printk(KERN_DEBUG "TKIP decrypt: data(len=%zd)", payload_len);
+		pr_debug("TKIP decrypt: data(len=%zd)", payload_len);
 		for (i = 0; i < payload_len; i++)
 			printk(" %02x", payload[i]);
 		printk("\n");
-		printk(KERN_DEBUG "TKIP decrypt: iv16=%04x iv32=%08x\n",
-		       iv16, iv32);
+		pr_debug("TKIP decrypt: iv16=%04x iv32=%08x\n", iv16, iv32);
 	}
 #endif
 
@@ -283,11 +282,10 @@ int ieee80211_tkip_decrypt_data(struct crypto_cipher *tfm,
 	     (iv32 == key->u.tkip.rx[queue].iv32 &&
 	      iv16 <= key->u.tkip.rx[queue].iv16))) {
 #ifdef CONFIG_MAC80211_TKIP_DEBUG
-		printk(KERN_DEBUG "TKIP replay detected for RX frame from "
-		       "%pM (RX IV (%04x,%02x) <= prev. IV (%04x,%02x)\n",
-		       ta,
-		       iv32, iv16, key->u.tkip.rx[queue].iv32,
-		       key->u.tkip.rx[queue].iv16);
+		pr_debug("TKIP replay detected for RX frame from %pM (RX IV (%04x,%02x) <= prev. IV (%04x,%02x)\n",
+			 ta, iv32, iv16,
+			 key->u.tkip.rx[queue].iv32,
+			 key->u.tkip.rx[queue].iv16);
 #endif
 		return TKIP_DECRYPT_REPLAY;
 	}
@@ -306,13 +304,12 @@ int ieee80211_tkip_decrypt_data(struct crypto_cipher *tfm,
 		{
 			int i;
 			u8 key_offset = NL80211_TKIP_DATA_OFFSET_ENCR_KEY;
-			printk(KERN_DEBUG "TKIP decrypt: Phase1 TA=%pM"
-			       " TK=", ta);
+			pr_debug("TKIP decrypt: Phase1 TA=%pM TK=", ta);
 			for (i = 0; i < 16; i++)
 				printk("%02x ",
 				       key->conf.key[key_offset + i]);
 			printk("\n");
-			printk(KERN_DEBUG "TKIP decrypt: P1K=");
+			pr_debug("TKIP decrypt: P1K=");
 			for (i = 0; i < 5; i++)
 				printk("%04x ", key->u.tkip.rx[queue].p1k[i]);
 			printk("\n");
@@ -336,7 +333,7 @@ int ieee80211_tkip_decrypt_data(struct crypto_cipher *tfm,
 #ifdef CONFIG_MAC80211_TKIP_DEBUG
 	{
 		int i;
-		printk(KERN_DEBUG "TKIP decrypt: Phase2 rc4key=");
+		pr_debug("TKIP decrypt: Phase2 rc4key=");
 		for (i = 0; i < 16; i++)
 			printk("%02x ", rc4key[i]);
 		printk("\n");
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index 5f827a6..9194d54 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -297,9 +297,8 @@ ieee80211_tx_h_check_assoc(struct ieee80211_tx_data *tx)
 		if (unlikely(!assoc &&
 			     ieee80211_is_data(hdr->frame_control))) {
 #ifdef CONFIG_MAC80211_VERBOSE_DEBUG
-			printk(KERN_DEBUG "%s: dropped data frame to not "
-			       "associated station %pM\n",
-			       tx->sdata->name, hdr->addr1);
+			pr_debug("%s: dropped data frame to not associated station %pM\n",
+				 tx->sdata->name, hdr->addr1);
 #endif /* CONFIG_MAC80211_VERBOSE_DEBUG */
 			I802_DEBUG_INC(tx->local->tx_handlers_drop_not_assoc);
 			return TX_DROP;
@@ -467,8 +466,8 @@ ieee80211_tx_h_unicast_ps_buf(struct ieee80211_tx_data *tx)
 		}
 
 #ifdef CONFIG_MAC80211_VERBOSE_PS_DEBUG
-		printk(KERN_DEBUG "STA %pM aid %d: PS buffer for AC %d\n",
-		       sta->sta.addr, sta->sta.aid, ac);
+		pr_debug("STA %pM aid %d: PS buffer for AC %d\n",
+			 sta->sta.addr, sta->sta.aid, ac);
 #endif /* CONFIG_MAC80211_VERBOSE_PS_DEBUG */
 		if (tx->local->total_ps_buffered >= TOTAL_MAX_TX_BUFFER)
 			purge_old_ps_buffers(tx->local);
@@ -502,9 +501,8 @@ ieee80211_tx_h_unicast_ps_buf(struct ieee80211_tx_data *tx)
 	}
 #ifdef CONFIG_MAC80211_VERBOSE_PS_DEBUG
 	else if (unlikely(test_sta_flag(sta, WLAN_STA_PS_STA))) {
-		printk(KERN_DEBUG
-		       "%s: STA %pM in PS mode, but polling/in SP -> send frame\n",
-		       tx->sdata->name, sta->sta.addr);
+		pr_debug("%s: STA %pM in PS mode, but polling/in SP -> send frame\n",
+			 tx->sdata->name, sta->sta.addr);
 	}
 #endif /* CONFIG_MAC80211_VERBOSE_PS_DEBUG */
 
-- 
1.7.8.111.gad25c.dirty
