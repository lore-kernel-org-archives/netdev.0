From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH/RFC] mac80211: convert to %pM away from print_mac
Date: Sat, 25 Oct 2008 01:50:43 +0200
Message-ID: <1224892243.3919.32.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	John Linville <linville@tuxdriver.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:49654 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751321AbYJXXuu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2008 19:50:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also remove a few stray DECLARE_MAC_BUF that were no longer
used at all.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
---
Not sure this will apply to your tree, I prepared it against John's tree
which might have more things. If you put the previous patch in, I
suppose John _could_ put it into his tree, but then he'd have to pull in
yours which he normally doesn't... No idea. I can also just postpone
this?

 net/mac80211/debugfs_key.c    |    4 -
 net/mac80211/debugfs_netdev.c |    3 -
 net/mac80211/debugfs_sta.c    |    5 -
 net/mac80211/event.c          |    5 -
 net/mac80211/ht.c             |   42 +++++---------
 net/mac80211/key.c            |   10 +--
 net/mac80211/mesh_plink.c     |   49 +++++-----------
 net/mac80211/mlme.c           |  125 ++++++++++++++++--------------------------
 net/mac80211/rx.c             |   38 ++++--------
 net/mac80211/sta_info.c       |   33 ++++-------
 net/mac80211/tkip.c           |   10 +--
 net/mac80211/tx.c             |   24 +++-----
 net/mac80211/wme.c            |    8 +-
 net/mac80211/wpa.c            |    3 -
 14 files changed, 132 insertions(+), 227 deletions(-)

--- everything.orig/net/mac80211/debugfs_key.c	2008-10-25 01:42:52.000000000 +0200
+++ everything/net/mac80211/debugfs_key.c	2008-10-25 01:44:43.000000000 +0200
@@ -188,7 +188,6 @@ void ieee80211_debugfs_key_add(struct ie
   {
 	static int keycount;
 	char buf[50];
-	DECLARE_MAC_BUF(mac);
 	struct sta_info *sta;
 
 	if (!key->local->debugfs.keys)
@@ -206,8 +205,7 @@ void ieee80211_debugfs_key_add(struct ie
 	rcu_read_lock();
 	sta = rcu_dereference(key->sta);
 	if (sta)
-		sprintf(buf, "../../stations/%s",
-			print_mac(mac, sta->sta.addr));
+		sprintf(buf, "../../stations/%pM", sta->sta.addr);
 	rcu_read_unlock();
 
 	/* using sta as a boolean is fine outside RCU lock */
--- everything.orig/net/mac80211/debugfs_netdev.c	2008-10-25 01:42:51.000000000 +0200
+++ everything/net/mac80211/debugfs_netdev.c	2008-10-25 01:44:43.000000000 +0200
@@ -68,8 +68,7 @@ static ssize_t ieee80211_if_fmt_##name(	
 	const struct ieee80211_sub_if_data *sdata, char *buf,		\
 	int buflen)							\
 {									\
-	DECLARE_MAC_BUF(mac);						\
-	return scnprintf(buf, buflen, "%s\n", print_mac(mac, sdata->field));\
+	return scnprintf(buf, buflen, "%pM\n", sdata->field);		\
 }
 
 #define __IEEE80211_IF_FILE(name)					\
--- everything.orig/net/mac80211/debugfs_sta.c	2008-10-25 01:42:51.000000000 +0200
+++ everything/net/mac80211/debugfs_sta.c	2008-10-25 01:44:43.000000000 +0200
@@ -175,15 +175,14 @@ STA_OPS(agg_status);
 void ieee80211_sta_debugfs_add(struct sta_info *sta)
 {
 	struct dentry *stations_dir = sta->local->debugfs.stations;
-	DECLARE_MAC_BUF(mbuf);
-	u8 *mac;
+	u8 mac[3*ETH_ALEN];
 
 	sta->debugfs.add_has_run = true;
 
 	if (!stations_dir)
 		return;
 
-	mac = print_mac(mbuf, sta->sta.addr);
+	snprintf(mac, sizeof(mac), "%pM", sta->sta.addr);
 
 	/*
 	 * This might fail due to a race condition:
--- everything.orig/net/mac80211/event.c	2008-10-25 01:42:52.000000000 +0200
+++ everything/net/mac80211/event.c	2008-10-25 01:44:43.000000000 +0200
@@ -21,14 +21,13 @@ void mac80211_ev_michael_mic_failure(str
 {
 	union iwreq_data wrqu;
 	char *buf = kmalloc(128, GFP_ATOMIC);
-	DECLARE_MAC_BUF(mac);
 
 	if (buf) {
 		/* TODO: needed parameters: count, key type, TSC */
 		sprintf(buf, "MLME-MICHAELMICFAILURE.indication("
-			"keyid=%d %scast addr=%s)",
+			"keyid=%d %scast addr=%pM)",
 			keyidx, hdr->addr1[0] & 0x01 ? "broad" : "uni",
-			print_mac(mac, hdr->addr2));
+			hdr->addr2);
 		memset(&wrqu, 0, sizeof(wrqu));
 		wrqu.data.length = strlen(buf);
 		wireless_send_event(sdata->dev, IWEVCUSTOM, &wrqu, buf);
--- everything.orig/net/mac80211/ht.c	2008-10-25 01:42:52.000000000 +0200
+++ everything/net/mac80211/ht.c	2008-10-25 01:44:43.000000000 +0200
@@ -316,7 +316,6 @@ void ieee80211_sta_stop_rx_ba_session(st
 	struct ieee80211_hw *hw = &local->hw;
 	struct sta_info *sta;
 	int ret, i;
-	DECLARE_MAC_BUF(mac);
 
 	rcu_read_lock();
 
@@ -344,8 +343,8 @@ void ieee80211_sta_stop_rx_ba_session(st
 	BUG_ON(!local->ops->ampdu_action);
 
 #ifdef CONFIG_MAC80211_HT_DEBUG
-	printk(KERN_DEBUG "Rx BA session stop requested for %s tid %u\n",
-				print_mac(mac, ra), tid);
+	printk(KERN_DEBUG "Rx BA session stop requested for %pM tid %u\n",
+	       ra, tid);
 #endif /* CONFIG_MAC80211_HT_DEBUG */
 
 	ret = local->ops->ampdu_action(hw, IEEE80211_AMPDU_RX_STOP,
@@ -458,14 +457,13 @@ int ieee80211_start_tx_ba_session(struct
 	u16 start_seq_num;
 	u8 *state;
 	int ret;
-	DECLARE_MAC_BUF(mac);
 
 	if (tid >= STA_TID_NUM)
 		return -EINVAL;
 
 #ifdef CONFIG_MAC80211_HT_DEBUG
-	printk(KERN_DEBUG "Open BA session requested for %s tid %u\n",
-				print_mac(mac, ra), tid);
+	printk(KERN_DEBUG "Open BA session requested for %pM tid %u\n",
+	       ra, tid);
 #endif /* CONFIG_MAC80211_HT_DEBUG */
 
 	rcu_read_lock();
@@ -599,7 +597,6 @@ int ieee80211_stop_tx_ba_session(struct 
 	struct sta_info *sta;
 	u8 *state;
 	int ret = 0;
-	DECLARE_MAC_BUF(mac);
 
 	if (tid >= STA_TID_NUM)
 		return -EINVAL;
@@ -621,8 +618,8 @@ int ieee80211_stop_tx_ba_session(struct 
 	}
 
 #ifdef CONFIG_MAC80211_HT_DEBUG
-	printk(KERN_DEBUG "Tx BA session stop requested for %s tid %u\n",
-				print_mac(mac, ra), tid);
+	printk(KERN_DEBUG "Tx BA session stop requested for %pM tid %u\n",
+	       ra, tid);
 #endif /* CONFIG_MAC80211_HT_DEBUG */
 
 	ieee80211_stop_queue(hw, sta->tid_to_tx_q[tid]);
@@ -654,7 +651,6 @@ void ieee80211_start_tx_ba_cb(struct iee
 	struct ieee80211_local *local = hw_to_local(hw);
 	struct sta_info *sta;
 	u8 *state;
-	DECLARE_MAC_BUF(mac);
 
 	if (tid >= STA_TID_NUM) {
 #ifdef CONFIG_MAC80211_HT_DEBUG
@@ -669,8 +665,7 @@ void ieee80211_start_tx_ba_cb(struct iee
 	if (!sta) {
 		rcu_read_unlock();
 #ifdef CONFIG_MAC80211_HT_DEBUG
-		printk(KERN_DEBUG "Could not find station: %s\n",
-				print_mac(mac, ra));
+		printk(KERN_DEBUG "Could not find station: %pM\n", ra);
 #endif
 		return;
 	}
@@ -709,7 +704,6 @@ void ieee80211_stop_tx_ba_cb(struct ieee
 	struct sta_info *sta;
 	u8 *state;
 	int agg_queue;
-	DECLARE_MAC_BUF(mac);
 
 	if (tid >= STA_TID_NUM) {
 #ifdef CONFIG_MAC80211_HT_DEBUG
@@ -720,16 +714,15 @@ void ieee80211_stop_tx_ba_cb(struct ieee
 	}
 
 #ifdef CONFIG_MAC80211_HT_DEBUG
-	printk(KERN_DEBUG "Stopping Tx BA session for %s tid %d\n",
-				print_mac(mac, ra), tid);
+	printk(KERN_DEBUG "Stopping Tx BA session for %pM tid %d\n",
+	       ra, tid);
 #endif /* CONFIG_MAC80211_HT_DEBUG */
 
 	rcu_read_lock();
 	sta = sta_info_get(local, ra);
 	if (!sta) {
 #ifdef CONFIG_MAC80211_HT_DEBUG
-		printk(KERN_DEBUG "Could not find station: %s\n",
-				print_mac(mac, ra));
+		printk(KERN_DEBUG "Could not find station: %pM\n", ra);
 #endif
 		rcu_read_unlock();
 		return;
@@ -858,7 +851,6 @@ void ieee80211_process_addba_request(str
 	u16 capab, tid, timeout, ba_policy, buf_size, start_seq_num, status;
 	u8 dialog_token;
 	int ret = -EOPNOTSUPP;
-	DECLARE_MAC_BUF(mac);
 
 	/* extract session parameters from addba request frame */
 	dialog_token = mgmt->u.action.u.addba_req.dialog_token;
@@ -884,8 +876,8 @@ void ieee80211_process_addba_request(str
 #ifdef CONFIG_MAC80211_HT_DEBUG
 		if (net_ratelimit())
 			printk(KERN_DEBUG "AddBA Req with bad params from "
-				"%s on tid %u. policy %d, buffer size %d\n",
-				print_mac(mac, mgmt->sa), tid, ba_policy,
+				"%pM on tid %u. policy %d, buffer size %d\n",
+				mgmt->sa, tid, ba_policy,
 				buf_size);
 #endif /* CONFIG_MAC80211_HT_DEBUG */
 		goto end_no_lock;
@@ -907,8 +899,8 @@ void ieee80211_process_addba_request(str
 #ifdef CONFIG_MAC80211_HT_DEBUG
 		if (net_ratelimit())
 			printk(KERN_DEBUG "unexpected AddBA Req from "
-				"%s on tid %u\n",
-				print_mac(mac, mgmt->sa), tid);
+				"%pM on tid %u\n",
+				mgmt->sa, tid);
 #endif /* CONFIG_MAC80211_HT_DEBUG */
 		goto end;
 	}
@@ -1040,7 +1032,6 @@ void ieee80211_process_delba(struct ieee
 	struct ieee80211_local *local = sdata->local;
 	u16 tid, params;
 	u16 initiator;
-	DECLARE_MAC_BUF(mac);
 
 	params = le16_to_cpu(mgmt->u.action.u.delba.params);
 	tid = (params & IEEE80211_DELBA_PARAM_TID_MASK) >> 12;
@@ -1048,9 +1039,8 @@ void ieee80211_process_delba(struct ieee
 
 #ifdef CONFIG_MAC80211_HT_DEBUG
 	if (net_ratelimit())
-		printk(KERN_DEBUG "delba from %s (%s) tid %d reason code %d\n",
-			print_mac(mac, mgmt->sa),
-			initiator ? "initiator" : "recipient", tid,
+		printk(KERN_DEBUG "delba from %pM (%s) tid %d reason code %d\n",
+			mgmt->sa, initiator ? "initiator" : "recipient", tid,
 			mgmt->u.action.u.delba.reason_code);
 #endif /* CONFIG_MAC80211_HT_DEBUG */
 
--- everything.orig/net/mac80211/key.c	2008-10-25 01:42:52.000000000 +0200
+++ everything/net/mac80211/key.c	2008-10-25 01:44:43.000000000 +0200
@@ -132,7 +132,6 @@ static void ieee80211_key_enable_hw_acce
 {
 	const u8 *addr;
 	int ret;
-	DECLARE_MAC_BUF(mac);
 
 	assert_key_lock();
 	might_sleep();
@@ -154,16 +153,15 @@ static void ieee80211_key_enable_hw_acce
 
 	if (ret && ret != -ENOSPC && ret != -EOPNOTSUPP)
 		printk(KERN_ERR "mac80211-%s: failed to set key "
-		       "(%d, %s) to hardware (%d)\n",
+		       "(%d, %pM) to hardware (%d)\n",
 		       wiphy_name(key->local->hw.wiphy),
-		       key->conf.keyidx, print_mac(mac, addr), ret);
+		       key->conf.keyidx, addr, ret);
 }
 
 static void ieee80211_key_disable_hw_accel(struct ieee80211_key *key)
 {
 	const u8 *addr;
 	int ret;
-	DECLARE_MAC_BUF(mac);
 
 	assert_key_lock();
 	might_sleep();
@@ -186,9 +184,9 @@ static void ieee80211_key_disable_hw_acc
 
 	if (ret)
 		printk(KERN_ERR "mac80211-%s: failed to remove key "
-		       "(%d, %s) from hardware (%d)\n",
+		       "(%d, %pM) from hardware (%d)\n",
 		       wiphy_name(key->local->hw.wiphy),
-		       key->conf.keyidx, print_mac(mac, addr), ret);
+		       key->conf.keyidx, addr, ret);
 
 	spin_lock(&todo_lock);
 	key->flags &= ~KEY_FLAG_UPLOADED_TO_HARDWARE;
--- everything.orig/net/mac80211/mesh_plink.c	2008-10-25 01:42:51.000000000 +0200
+++ everything/net/mac80211/mesh_plink.c	2008-10-25 01:44:43.000000000 +0200
@@ -257,9 +257,6 @@ static void mesh_plink_timer(unsigned lo
 	struct sta_info *sta;
 	__le16 llid, plid, reason;
 	struct ieee80211_sub_if_data *sdata;
-#ifdef CONFIG_MAC80211_VERBOSE_MPL_DEBUG
-	DECLARE_MAC_BUF(mac);
-#endif
 
 	/*
 	 * This STA is valid because sta_info_destroy() will
@@ -274,8 +271,8 @@ static void mesh_plink_timer(unsigned lo
 		spin_unlock_bh(&sta->lock);
 		return;
 	}
-	mpl_dbg("Mesh plink timer for %s fired on state %d\n",
-			print_mac(mac, sta->sta.addr), sta->plink_state);
+	mpl_dbg("Mesh plink timer for %pM fired on state %d\n",
+		sta->sta.addr, sta->plink_state);
 	reason = 0;
 	llid = sta->llid;
 	plid = sta->plid;
@@ -287,9 +284,9 @@ static void mesh_plink_timer(unsigned lo
 		/* retry timer */
 		if (sta->plink_retries < dot11MeshMaxRetries(sdata)) {
 			u32 rand;
-			mpl_dbg("Mesh plink for %s (retry, timeout): %d %d\n",
-					print_mac(mac, sta->sta.addr),
-					sta->plink_retries, sta->plink_timeout);
+			mpl_dbg("Mesh plink for %pM (retry, timeout): %d %d\n",
+				sta->sta.addr, sta->plink_retries,
+				sta->plink_timeout);
 			get_random_bytes(&rand, sizeof(u32));
 			sta->plink_timeout = sta->plink_timeout +
 					     rand % sta->plink_timeout;
@@ -337,9 +334,6 @@ int mesh_plink_open(struct sta_info *sta
 {
 	__le16 llid;
 	struct ieee80211_sub_if_data *sdata = sta->sdata;
-#ifdef CONFIG_MAC80211_VERBOSE_MPL_DEBUG
-	DECLARE_MAC_BUF(mac);
-#endif
 
 	spin_lock_bh(&sta->lock);
 	get_random_bytes(&llid, 2);
@@ -351,8 +345,8 @@ int mesh_plink_open(struct sta_info *sta
 	sta->plink_state = PLINK_OPN_SNT;
 	mesh_plink_timer_set(sta, dot11MeshRetryTimeout(sdata));
 	spin_unlock_bh(&sta->lock);
-	mpl_dbg("Mesh plink: starting establishment with %s\n",
-		print_mac(mac, sta->sta.addr));
+	mpl_dbg("Mesh plink: starting establishment with %pM\n",
+		sta->sta.addr);
 
 	return mesh_plink_frame_tx(sdata, PLINK_OPEN,
 				   sta->sta.addr, llid, 0, 0);
@@ -360,10 +354,6 @@ int mesh_plink_open(struct sta_info *sta
 
 void mesh_plink_block(struct sta_info *sta)
 {
-#ifdef CONFIG_MAC80211_VERBOSE_MPL_DEBUG
-	DECLARE_MAC_BUF(mac);
-#endif
-
 	spin_lock_bh(&sta->lock);
 	__mesh_plink_deactivate(sta);
 	sta->plink_state = PLINK_BLOCKED;
@@ -374,12 +364,8 @@ int mesh_plink_close(struct sta_info *st
 {
 	struct ieee80211_sub_if_data *sdata = sta->sdata;
 	__le16 llid, plid, reason;
-#ifdef CONFIG_MAC80211_VERBOSE_MPL_DEBUG
-	DECLARE_MAC_BUF(mac);
-#endif
 
-	mpl_dbg("Mesh plink: closing link with %s\n",
-			print_mac(mac, sta->sta.addr));
+	mpl_dbg("Mesh plink: closing link with %pM\n", sta->sta.addr);
 	spin_lock_bh(&sta->lock);
 	sta->reason = cpu_to_le16(MESH_LINK_CANCELLED);
 	reason = sta->reason;
@@ -417,9 +403,6 @@ void mesh_rx_plink_frame(struct ieee8021
 	u8 ie_len;
 	u8 *baseaddr;
 	__le16 plid, llid, reason;
-#ifdef CONFIG_MAC80211_VERBOSE_MPL_DEBUG
-	DECLARE_MAC_BUF(mac);
-#endif
 
 	/* need action_code, aux */
 	if (len < IEEE80211_MIN_ACTION_SIZE + 3)
@@ -557,10 +540,10 @@ void mesh_rx_plink_frame(struct ieee8021
 		}
 	}
 
-	mpl_dbg("Mesh plink (peer, state, llid, plid, event): %s %d %d %d %d\n",
-			print_mac(mac, mgmt->sa), sta->plink_state,
-			le16_to_cpu(sta->llid), le16_to_cpu(sta->plid),
-			event);
+	mpl_dbg("Mesh plink (peer, state, llid, plid, event): %pM %d %d %d %d\n",
+		mgmt->sa, sta->plink_state,
+		le16_to_cpu(sta->llid), le16_to_cpu(sta->plid),
+		event);
 	reason = 0;
 	switch (sta->plink_state) {
 		/* spin_unlock as soon as state is updated at each case */
@@ -660,8 +643,8 @@ void mesh_rx_plink_frame(struct ieee8021
 			sta->plink_state = PLINK_ESTAB;
 			mesh_plink_inc_estab_count(sdata);
 			spin_unlock_bh(&sta->lock);
-			mpl_dbg("Mesh plink with %s ESTABLISHED\n",
-					print_mac(mac, sta->sta.addr));
+			mpl_dbg("Mesh plink with %pM ESTABLISHED\n",
+				sta->sta.addr);
 			break;
 		default:
 			spin_unlock_bh(&sta->lock);
@@ -693,8 +676,8 @@ void mesh_rx_plink_frame(struct ieee8021
 			sta->plink_state = PLINK_ESTAB;
 			mesh_plink_inc_estab_count(sdata);
 			spin_unlock_bh(&sta->lock);
-			mpl_dbg("Mesh plink with %s ESTABLISHED\n",
-					print_mac(mac, sta->sta.addr));
+			mpl_dbg("Mesh plink with %pM ESTABLISHED\n",
+				sta->sta.addr);
 			mesh_plink_frame_tx(sdata, PLINK_CONFIRM, sta->sta.addr, llid,
 					    plid, 0);
 			break;
--- everything.orig/net/mac80211/mlme.c	2008-10-25 01:42:50.000000000 +0200
+++ everything/net/mac80211/mlme.c	2008-10-25 01:44:43.000000000 +0200
@@ -575,7 +575,6 @@ static u32 ieee80211_handle_bss_capabili
 	struct ieee80211_bss_conf *bss_conf = &sdata->vif.bss_conf;
 #ifdef CONFIG_MAC80211_VERBOSE_DEBUG
 	struct ieee80211_if_sta *ifsta = &sdata->u.sta;
-	DECLARE_MAC_BUF(mac);
 #endif
 	u32 changed = 0;
 	bool use_protection;
@@ -595,11 +594,10 @@ static u32 ieee80211_handle_bss_capabili
 	if (use_protection != bss_conf->use_cts_prot) {
 #ifdef CONFIG_MAC80211_VERBOSE_DEBUG
 		if (net_ratelimit()) {
-			printk(KERN_DEBUG "%s: CTS protection %s (BSSID="
-			       "%s)\n",
+			printk(KERN_DEBUG "%s: CTS protection %s (BSSID=%pM)\n",
 			       sdata->dev->name,
 			       use_protection ? "enabled" : "disabled",
-			       print_mac(mac, ifsta->bssid));
+			       ifsta->bssid);
 		}
 #endif
 		bss_conf->use_cts_prot = use_protection;
@@ -610,10 +608,10 @@ static u32 ieee80211_handle_bss_capabili
 #ifdef CONFIG_MAC80211_VERBOSE_DEBUG
 		if (net_ratelimit()) {
 			printk(KERN_DEBUG "%s: switched to %s barker preamble"
-			       " (BSSID=%s)\n",
+			       " (BSSID=%pM)\n",
 			       sdata->dev->name,
 			       use_short_preamble ? "short" : "long",
-			       print_mac(mac, ifsta->bssid));
+			       ifsta->bssid);
 		}
 #endif
 		bss_conf->use_short_preamble = use_short_preamble;
@@ -624,10 +622,10 @@ static u32 ieee80211_handle_bss_capabili
 #ifdef CONFIG_MAC80211_VERBOSE_DEBUG
 		if (net_ratelimit()) {
 			printk(KERN_DEBUG "%s: switched to %s slot"
-			       " (BSSID=%s)\n",
+			       " (BSSID=%pM)\n",
 			       sdata->dev->name,
 			       use_short_slot ? "short" : "long",
-			       print_mac(mac, ifsta->bssid));
+			       ifsta->bssid);
 		}
 #endif
 		bss_conf->use_short_slot = use_short_slot;
@@ -756,19 +754,17 @@ static void ieee80211_set_associated(str
 static void ieee80211_direct_probe(struct ieee80211_sub_if_data *sdata,
 				   struct ieee80211_if_sta *ifsta)
 {
-	DECLARE_MAC_BUF(mac);
-
 	ifsta->direct_probe_tries++;
 	if (ifsta->direct_probe_tries > IEEE80211_AUTH_MAX_TRIES) {
-		printk(KERN_DEBUG "%s: direct probe to AP %s timed out\n",
-		       sdata->dev->name, print_mac(mac, ifsta->bssid));
+		printk(KERN_DEBUG "%s: direct probe to AP %pM timed out\n",
+		       sdata->dev->name, ifsta->bssid);
 		ifsta->state = IEEE80211_STA_MLME_DISABLED;
 		ieee80211_sta_send_apinfo(sdata, ifsta);
 		return;
 	}
 
-	printk(KERN_DEBUG "%s: direct probe to AP %s try %d\n",
-			sdata->dev->name, print_mac(mac, ifsta->bssid),
+	printk(KERN_DEBUG "%s: direct probe to AP %pM try %d\n",
+			sdata->dev->name, ifsta->bssid,
 			ifsta->direct_probe_tries);
 
 	ifsta->state = IEEE80211_STA_MLME_DIRECT_PROBE;
@@ -788,21 +784,19 @@ static void ieee80211_direct_probe(struc
 static void ieee80211_authenticate(struct ieee80211_sub_if_data *sdata,
 				   struct ieee80211_if_sta *ifsta)
 {
-	DECLARE_MAC_BUF(mac);
-
 	ifsta->auth_tries++;
 	if (ifsta->auth_tries > IEEE80211_AUTH_MAX_TRIES) {
-		printk(KERN_DEBUG "%s: authentication with AP %s"
+		printk(KERN_DEBUG "%s: authentication with AP %pM"
 		       " timed out\n",
-		       sdata->dev->name, print_mac(mac, ifsta->bssid));
+		       sdata->dev->name, ifsta->bssid);
 		ifsta->state = IEEE80211_STA_MLME_DISABLED;
 		ieee80211_sta_send_apinfo(sdata, ifsta);
 		return;
 	}
 
 	ifsta->state = IEEE80211_STA_MLME_AUTHENTICATE;
-	printk(KERN_DEBUG "%s: authenticate with AP %s\n",
-	       sdata->dev->name, print_mac(mac, ifsta->bssid));
+	printk(KERN_DEBUG "%s: authenticate with AP %pM\n",
+	       sdata->dev->name, ifsta->bssid);
 
 	ieee80211_send_auth(sdata, ifsta, 1, NULL, 0, 0);
 
@@ -911,21 +905,19 @@ static int ieee80211_privacy_mismatch(st
 static void ieee80211_associate(struct ieee80211_sub_if_data *sdata,
 				struct ieee80211_if_sta *ifsta)
 {
-	DECLARE_MAC_BUF(mac);
-
 	ifsta->assoc_tries++;
 	if (ifsta->assoc_tries > IEEE80211_ASSOC_MAX_TRIES) {
-		printk(KERN_DEBUG "%s: association with AP %s"
+		printk(KERN_DEBUG "%s: association with AP %pM"
 		       " timed out\n",
-		       sdata->dev->name, print_mac(mac, ifsta->bssid));
+		       sdata->dev->name, ifsta->bssid);
 		ifsta->state = IEEE80211_STA_MLME_DISABLED;
 		ieee80211_sta_send_apinfo(sdata, ifsta);
 		return;
 	}
 
 	ifsta->state = IEEE80211_STA_MLME_ASSOCIATE;
-	printk(KERN_DEBUG "%s: associate with AP %s\n",
-	       sdata->dev->name, print_mac(mac, ifsta->bssid));
+	printk(KERN_DEBUG "%s: associate with AP %pM\n",
+	       sdata->dev->name, ifsta->bssid);
 	if (ieee80211_privacy_mismatch(sdata, ifsta)) {
 		printk(KERN_DEBUG "%s: mismatch in privacy configuration and "
 		       "mixed-cell disabled - abort association\n", sdata->dev->name);
@@ -945,7 +937,6 @@ static void ieee80211_associated(struct 
 	struct ieee80211_local *local = sdata->local;
 	struct sta_info *sta;
 	int disassoc;
-	DECLARE_MAC_BUF(mac);
 
 	/* TODO: start monitoring current AP signal quality and number of
 	 * missed beacons. Scan other channels every now and then and search
@@ -958,8 +949,8 @@ static void ieee80211_associated(struct 
 
 	sta = sta_info_get(local, ifsta->bssid);
 	if (!sta) {
-		printk(KERN_DEBUG "%s: No STA entry for own AP %s\n",
-		       sdata->dev->name, print_mac(mac, ifsta->bssid));
+		printk(KERN_DEBUG "%s: No STA entry for own AP %pM\n",
+		       sdata->dev->name, ifsta->bssid);
 		disassoc = 1;
 	} else {
 		disassoc = 0;
@@ -967,9 +958,9 @@ static void ieee80211_associated(struct 
 			       sta->last_rx + IEEE80211_MONITORING_INTERVAL)) {
 			if (ifsta->flags & IEEE80211_STA_PROBEREQ_POLL) {
 				printk(KERN_DEBUG "%s: No ProbeResp from "
-				       "current AP %s - assume out of "
+				       "current AP %pM - assume out of "
 				       "range\n",
-				       sdata->dev->name, print_mac(mac, ifsta->bssid));
+				       sdata->dev->name, ifsta->bssid);
 				disassoc = 1;
 			} else
 				ieee80211_send_probe_req(sdata, ifsta->bssid,
@@ -1030,7 +1021,6 @@ static void ieee80211_rx_mgmt_auth(struc
 				   size_t len)
 {
 	u16 auth_alg, auth_transaction, status_code;
-	DECLARE_MAC_BUF(mac);
 
 	if (ifsta->state != IEEE80211_STA_MLME_AUTHENTICATE &&
 	    sdata->vif.type != NL80211_IFTYPE_ADHOC)
@@ -1123,7 +1113,6 @@ static void ieee80211_rx_mgmt_deauth(str
 				     size_t len)
 {
 	u16 reason_code;
-	DECLARE_MAC_BUF(mac);
 
 	if (len < 24 + 2)
 		return;
@@ -1155,7 +1144,6 @@ static void ieee80211_rx_mgmt_disassoc(s
 				       size_t len)
 {
 	u16 reason_code;
-	DECLARE_MAC_BUF(mac);
 
 	if (len < 24 + 2)
 		return;
@@ -1194,7 +1182,6 @@ static void ieee80211_rx_mgmt_assoc_resp
 	u8 *pos;
 	u32 changed = 0;
 	int i, j;
-	DECLARE_MAC_BUF(mac);
 	bool have_higher_than_11mbit = false, newsta = false;
 	u16 ap_ht_cap_flags;
 
@@ -1214,9 +1201,9 @@ static void ieee80211_rx_mgmt_assoc_resp
 	status_code = le16_to_cpu(mgmt->u.assoc_resp.status_code);
 	aid = le16_to_cpu(mgmt->u.assoc_resp.aid);
 
-	printk(KERN_DEBUG "%s: RX %sssocResp from %s (capab=0x%x "
+	printk(KERN_DEBUG "%s: RX %sssocResp from %pM (capab=0x%x "
 	       "status=%d aid=%d)\n",
-	       sdata->dev->name, reassoc ? "Rea" : "A", print_mac(mac, mgmt->sa),
+	       sdata->dev->name, reassoc ? "Rea" : "A", mgmt->sa,
 	       capab_info, status_code, (u16)(aid & ~(BIT(15) | BIT(14))));
 
 	if (status_code != WLAN_STATUS_SUCCESS) {
@@ -1513,8 +1500,6 @@ static void ieee80211_rx_bss_info(struct
 	u64 beacon_timestamp, rx_timestamp;
 	u64 supp_rates = 0;
 	enum ieee80211_band band = rx_status->band;
-	DECLARE_MAC_BUF(mac);
-	DECLARE_MAC_BUF(mac2);
 
 	if (elems->ds_params && elems->ds_params_len == 1)
 		freq = ieee80211_channel_to_frequency(elems->ds_params[0]);
@@ -1544,10 +1529,10 @@ static void ieee80211_rx_bss_info(struct
 #ifdef CONFIG_MAC80211_IBSS_DEBUG
 			if (sta->sta.supp_rates[band] != prev_rates)
 				printk(KERN_DEBUG "%s: updated supp_rates set "
-				    "for %s based on beacon info (0x%llx | "
+				    "for %pM based on beacon info (0x%llx | "
 				    "0x%llx -> 0x%llx)\n",
 				    sdata->dev->name,
-				    print_mac(mac, sta->sta.addr),
+				    sta->sta.addr,
 				    (unsigned long long) prev_rates,
 				    (unsigned long long) supp_rates,
 				    (unsigned long long) sta->sta.supp_rates[band]);
@@ -1611,10 +1596,9 @@ static void ieee80211_rx_bss_info(struct
 			/* can't merge without knowing the TSF */
 			rx_timestamp = -1LLU;
 #ifdef CONFIG_MAC80211_IBSS_DEBUG
-		printk(KERN_DEBUG "RX beacon SA=%s BSSID="
-		       "%s TSF=0x%llx BCN=0x%llx diff=%lld @%lu\n",
-		       print_mac(mac, mgmt->sa),
-		       print_mac(mac2, mgmt->bssid),
+		printk(KERN_DEBUG "RX beacon SA=%pM BSSID="
+		       "%pM TSF=0x%llx BCN=0x%llx diff=%lld @%lu\n",
+		       mgmt->sa, mgmt->bssid,
 		       (unsigned long long)rx_timestamp,
 		       (unsigned long long)beacon_timestamp,
 		       (unsigned long long)(rx_timestamp - beacon_timestamp),
@@ -1623,8 +1607,8 @@ static void ieee80211_rx_bss_info(struct
 		if (beacon_timestamp > rx_timestamp) {
 #ifdef CONFIG_MAC80211_IBSS_DEBUG
 			printk(KERN_DEBUG "%s: beacon TSF higher than "
-			       "local TSF - IBSS merge with BSSID %s\n",
-			       sdata->dev->name, print_mac(mac, mgmt->bssid));
+			       "local TSF - IBSS merge with BSSID %pM\n",
+			       sdata->dev->name, mgmt->bssid);
 #endif
 			ieee80211_sta_join_ibss(sdata, &sdata->u.sta, bss);
 			ieee80211_ibss_add_sta(sdata, NULL,
@@ -1754,11 +1738,6 @@ static void ieee80211_rx_mgmt_probe_req(
 	struct sk_buff *skb;
 	struct ieee80211_mgmt *resp;
 	u8 *pos, *end;
-	DECLARE_MAC_BUF(mac);
-#ifdef CONFIG_MAC80211_IBSS_DEBUG
-	DECLARE_MAC_BUF(mac2);
-	DECLARE_MAC_BUF(mac3);
-#endif
 
 	if (sdata->vif.type != NL80211_IFTYPE_ADHOC ||
 	    ifsta->state != IEEE80211_STA_MLME_IBSS_JOINED ||
@@ -1771,10 +1750,10 @@ static void ieee80211_rx_mgmt_probe_req(
 		tx_last_beacon = 1;
 
 #ifdef CONFIG_MAC80211_IBSS_DEBUG
-	printk(KERN_DEBUG "%s: RX ProbeReq SA=%s DA=%s BSSID="
-	       "%s (tx_last_beacon=%d)\n",
-	       sdata->dev->name, print_mac(mac, mgmt->sa), print_mac(mac2, mgmt->da),
-	       print_mac(mac3, mgmt->bssid), tx_last_beacon);
+	printk(KERN_DEBUG "%s: RX ProbeReq SA=%pM DA=%pM BSSID=%pM"
+	       " (tx_last_beacon=%d)\n",
+	       sdata->dev->name, mgmt->sa, mgmt->da,
+	       mgmt->bssid, tx_last_beacon);
 #endif /* CONFIG_MAC80211_IBSS_DEBUG */
 
 	if (!tx_last_beacon)
@@ -1790,8 +1769,8 @@ static void ieee80211_rx_mgmt_probe_req(
 	    pos + 2 + pos[1] > end) {
 #ifdef CONFIG_MAC80211_IBSS_DEBUG
 		printk(KERN_DEBUG "%s: Invalid SSID IE in ProbeReq "
-		       "from %s\n",
-		       sdata->dev->name, print_mac(mac, mgmt->sa));
+		       "from %pM\n",
+		       sdata->dev->name, mgmt->sa);
 #endif
 		return;
 	}
@@ -1810,8 +1789,8 @@ static void ieee80211_rx_mgmt_probe_req(
 	resp = (struct ieee80211_mgmt *) skb->data;
 	memcpy(resp->da, mgmt->sa, ETH_ALEN);
 #ifdef CONFIG_MAC80211_IBSS_DEBUG
-	printk(KERN_DEBUG "%s: Sending ProbeResp to %s\n",
-	       sdata->dev->name, print_mac(mac, resp->da));
+	printk(KERN_DEBUG "%s: Sending ProbeResp to %pM\n",
+	       sdata->dev->name, resp->da);
 #endif /* CONFIG_MAC80211_IBSS_DEBUG */
 	ieee80211_tx_skb(sdata, skb, 0);
 }
@@ -2017,7 +1996,6 @@ static int ieee80211_sta_create_ibss(str
 	u8 bssid[ETH_ALEN], *pos;
 	int i;
 	int ret;
-	DECLARE_MAC_BUF(mac);
 
 #if 0
 	/* Easier testing, use fixed BSSID. */
@@ -2033,8 +2011,8 @@ static int ieee80211_sta_create_ibss(str
 	bssid[0] |= 0x02;
 #endif
 
-	printk(KERN_DEBUG "%s: Creating new IBSS network, BSSID %s\n",
-	       sdata->dev->name, print_mac(mac, bssid));
+	printk(KERN_DEBUG "%s: Creating new IBSS network, BSSID %pM\n",
+	       sdata->dev->name, bssid);
 
 	bss = ieee80211_rx_bss_add(local, bssid,
 				   local->hw.conf.channel->center_freq,
@@ -2077,8 +2055,6 @@ static int ieee80211_sta_find_ibss(struc
 	int found = 0;
 	u8 bssid[ETH_ALEN];
 	int active_ibss;
-	DECLARE_MAC_BUF(mac);
-	DECLARE_MAC_BUF(mac2);
 
 	if (ifsta->ssid_len == 0)
 		return -EINVAL;
@@ -2095,8 +2071,7 @@ static int ieee80211_sta_find_ibss(struc
 		    || !(bss->capability & WLAN_CAPABILITY_IBSS))
 			continue;
 #ifdef CONFIG_MAC80211_IBSS_DEBUG
-		printk(KERN_DEBUG "   bssid=%s found\n",
-		       print_mac(mac, bss->bssid));
+		printk(KERN_DEBUG "   bssid=%pM found\n", bss->bssid);
 #endif /* CONFIG_MAC80211_IBSS_DEBUG */
 		memcpy(bssid, bss->bssid, ETH_ALEN);
 		found = 1;
@@ -2107,9 +2082,8 @@ static int ieee80211_sta_find_ibss(struc
 
 #ifdef CONFIG_MAC80211_IBSS_DEBUG
 	if (found)
-		printk(KERN_DEBUG "   sta_find_ibss: selected %s current "
-		       "%s\n", print_mac(mac, bssid),
-		       print_mac(mac2, ifsta->bssid));
+		printk(KERN_DEBUG "   sta_find_ibss: selected %pM current "
+		       "%pM\n", bssid, ifsta->bssid);
 #endif /* CONFIG_MAC80211_IBSS_DEBUG */
 
 	if (found && memcmp(ifsta->bssid, bssid, ETH_ALEN) != 0) {
@@ -2126,9 +2100,9 @@ static int ieee80211_sta_find_ibss(struc
 		if (!bss)
 			goto dont_join;
 
-		printk(KERN_DEBUG "%s: Selected IBSS BSSID %s"
+		printk(KERN_DEBUG "%s: Selected IBSS BSSID %pM"
 		       " based on configured SSID\n",
-		       sdata->dev->name, print_mac(mac, bssid));
+		       sdata->dev->name, bssid);
 		ret = ieee80211_sta_join_ibss(sdata, ifsta, bss);
 		ieee80211_rx_bss_put(local, bss);
 		return ret;
@@ -2370,7 +2344,6 @@ struct sta_info *ieee80211_ibss_add_sta(
 {
 	struct ieee80211_local *local = sdata->local;
 	struct sta_info *sta;
-	DECLARE_MAC_BUF(mac);
 	int band = local->hw.conf.channel->band;
 
 	/* TODO: Could consider removing the least recently used entry and
@@ -2378,7 +2351,7 @@ struct sta_info *ieee80211_ibss_add_sta(
 	if (local->num_sta >= IEEE80211_IBSS_MAX_STA_ENTRIES) {
 		if (net_ratelimit()) {
 			printk(KERN_DEBUG "%s: No room for a new IBSS STA "
-			       "entry %s\n", sdata->dev->name, print_mac(mac, addr));
+			       "entry %pM\n", sdata->dev->name, addr);
 		}
 		return NULL;
 	}
@@ -2387,8 +2360,8 @@ struct sta_info *ieee80211_ibss_add_sta(
 		return NULL;
 
 #ifdef CONFIG_MAC80211_VERBOSE_DEBUG
-	printk(KERN_DEBUG "%s: Adding new IBSS station %s (dev=%s)\n",
-	       wiphy_name(local->hw.wiphy), print_mac(mac, addr), sdata->dev->name);
+	printk(KERN_DEBUG "%s: Adding new IBSS station %pM (dev=%s)\n",
+	       wiphy_name(local->hw.wiphy), addr, sdata->dev->name);
 #endif
 
 	sta = sta_info_alloc(sdata, addr, GFP_ATOMIC);
--- everything.orig/net/mac80211/rx.c	2008-10-25 01:42:51.000000000 +0200
+++ everything/net/mac80211/rx.c	2008-10-25 01:44:43.000000000 +0200
@@ -655,13 +655,12 @@ ieee80211_rx_h_decrypt(struct ieee80211_
 static void ap_sta_ps_start(struct sta_info *sta)
 {
 	struct ieee80211_sub_if_data *sdata = sta->sdata;
-	DECLARE_MAC_BUF(mac);
 
 	atomic_inc(&sdata->bss->num_sta_ps);
 	set_and_clear_sta_flags(sta, WLAN_STA_PS, WLAN_STA_PSPOLL);
 #ifdef CONFIG_MAC80211_VERBOSE_PS_DEBUG
-	printk(KERN_DEBUG "%s: STA %s aid %d enters power save mode\n",
-	       sdata->dev->name, print_mac(mac, sta->sta.addr), sta->sta.aid);
+	printk(KERN_DEBUG "%s: STA %pM aid %d enters power save mode\n",
+	       sdata->dev->name, sta->sta.addr, sta->sta.aid);
 #endif /* CONFIG_MAC80211_VERBOSE_PS_DEBUG */
 }
 
@@ -672,7 +671,6 @@ static int ap_sta_ps_end(struct sta_info
 	struct sk_buff *skb;
 	int sent = 0;
 	struct ieee80211_tx_info *info;
-	DECLARE_MAC_BUF(mac);
 
 	atomic_dec(&sdata->bss->num_sta_ps);
 
@@ -682,8 +680,8 @@ static int ap_sta_ps_end(struct sta_info
 		sta_info_clear_tim_bit(sta);
 
 #ifdef CONFIG_MAC80211_VERBOSE_PS_DEBUG
-	printk(KERN_DEBUG "%s: STA %s aid %d exits power save mode\n",
-	       sdata->dev->name, print_mac(mac, sta->sta.addr), sta->sta.aid);
+	printk(KERN_DEBUG "%s: STA %pM aid %d exits power save mode\n",
+	       sdata->dev->name, sta->sta.addr, sta->sta.aid);
 #endif /* CONFIG_MAC80211_VERBOSE_PS_DEBUG */
 
 	/* Send all buffered frames to the station */
@@ -698,9 +696,9 @@ static int ap_sta_ps_end(struct sta_info
 		local->total_ps_buffered--;
 		sent++;
 #ifdef CONFIG_MAC80211_VERBOSE_PS_DEBUG
-		printk(KERN_DEBUG "%s: STA %s aid %d send PS frame "
+		printk(KERN_DEBUG "%s: STA %pM aid %d send PS frame "
 		       "since STA not sleeping anymore\n", sdata->dev->name,
-		       print_mac(mac, sta->sta.addr), sta->sta.aid);
+		       sta->sta.addr, sta->sta.aid);
 #endif /* CONFIG_MAC80211_VERBOSE_PS_DEBUG */
 		info->flags |= IEEE80211_TX_CTL_REQUEUE;
 		dev_queue_xmit(skb);
@@ -791,15 +789,12 @@ ieee80211_reassemble_add(struct ieee8021
 #ifdef CONFIG_MAC80211_VERBOSE_DEBUG
 		struct ieee80211_hdr *hdr =
 			(struct ieee80211_hdr *) entry->skb_list.next->data;
-		DECLARE_MAC_BUF(mac);
-		DECLARE_MAC_BUF(mac2);
 		printk(KERN_DEBUG "%s: RX reassembly removed oldest "
 		       "fragment entry (idx=%d age=%lu seq=%d last_frag=%d "
-		       "addr1=%s addr2=%s\n",
+		       "addr1=%pM addr2=%pM\n",
 		       sdata->dev->name, idx,
 		       jiffies - entry->first_frag_time, entry->seq,
-		       entry->last_frag, print_mac(mac, hdr->addr1),
-		       print_mac(mac2, hdr->addr2));
+		       entry->last_frag, hdr->addr1, hdr->addr2);
 #endif
 		__skb_queue_purge(&entry->skb_list);
 	}
@@ -868,7 +863,6 @@ ieee80211_rx_h_defragment(struct ieee802
 	unsigned int frag, seq;
 	struct ieee80211_fragment_entry *entry;
 	struct sk_buff *skb;
-	DECLARE_MAC_BUF(mac);
 
 	hdr = (struct ieee80211_hdr *)rx->skb->data;
 	fc = hdr->frame_control;
@@ -972,7 +966,6 @@ ieee80211_rx_h_ps_poll(struct ieee80211_
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(rx->dev);
 	struct sk_buff *skb;
 	int no_pending_pkts;
-	DECLARE_MAC_BUF(mac);
 	__le16 fc = ((struct ieee80211_hdr *)rx->skb->data)->frame_control;
 
 	if (likely(!rx->sta || !ieee80211_is_pspoll(fc) ||
@@ -1003,8 +996,8 @@ ieee80211_rx_h_ps_poll(struct ieee80211_
 		set_sta_flags(rx->sta, WLAN_STA_PSPOLL);
 
 #ifdef CONFIG_MAC80211_VERBOSE_PS_DEBUG
-		printk(KERN_DEBUG "STA %s aid %d: PS Poll (entries after %d)\n",
-		       print_mac(mac, rx->sta->sta.addr), rx->sta->sta.aid,
+		printk(KERN_DEBUG "STA %pM aid %d: PS Poll (entries after %d)\n",
+		       rx->sta->sta.addr, rx->sta->sta.aid,
 		       skb_queue_len(&rx->sta->ps_tx_buf));
 #endif /* CONFIG_MAC80211_VERBOSE_PS_DEBUG */
 
@@ -1027,9 +1020,9 @@ ieee80211_rx_h_ps_poll(struct ieee80211_
 		 *	  Should we send it a null-func frame indicating we
 		 *	  have nothing buffered for it?
 		 */
-		printk(KERN_DEBUG "%s: STA %s sent PS Poll even "
+		printk(KERN_DEBUG "%s: STA %pM sent PS Poll even "
 		       "though there are no buffered frames for it\n",
-		       rx->dev->name, print_mac(mac, rx->sta->sta.addr));
+		       rx->dev->name, rx->sta->sta.addr);
 #endif /* CONFIG_MAC80211_VERBOSE_PS_DEBUG */
 	}
 
@@ -1099,10 +1092,6 @@ ieee80211_data_to_8023(struct ieee80211_
 	u8 src[ETH_ALEN] __aligned(2);
 	struct sk_buff *skb = rx->skb;
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-	DECLARE_MAC_BUF(mac);
-	DECLARE_MAC_BUF(mac2);
-	DECLARE_MAC_BUF(mac3);
-	DECLARE_MAC_BUF(mac4);
 
 	if (unlikely(!ieee80211_is_data_present(hdr->frame_control)))
 		return -1;
@@ -1281,7 +1270,6 @@ ieee80211_rx_h_amsdu(struct ieee80211_rx
 	int remaining, err;
 	u8 dst[ETH_ALEN];
 	u8 src[ETH_ALEN];
-	DECLARE_MAC_BUF(mac);
 
 	if (unlikely(!ieee80211_is_data(fc)))
 		return RX_CONTINUE;
@@ -1634,8 +1622,6 @@ static void ieee80211_rx_michael_mic_rep
 {
 	int keyidx;
 	unsigned int hdrlen;
-	DECLARE_MAC_BUF(mac);
-	DECLARE_MAC_BUF(mac2);
 
 	hdrlen = ieee80211_hdrlen(hdr->frame_control);
 	if (rx->skb->len >= hdrlen + 4)
--- everything.orig/net/mac80211/sta_info.c	2008-10-25 01:42:52.000000000 +0200
+++ everything/net/mac80211/sta_info.c	2008-10-25 01:44:43.000000000 +0200
@@ -137,14 +137,12 @@ struct sta_info *sta_info_get_by_idx(str
 static void __sta_info_free(struct ieee80211_local *local,
 			    struct sta_info *sta)
 {
-	DECLARE_MAC_BUF(mbuf);
-
 	rate_control_free_sta(sta);
 	rate_control_put(sta->rate_ctrl);
 
 #ifdef CONFIG_MAC80211_VERBOSE_DEBUG
-	printk(KERN_DEBUG "%s: Destroyed STA %s\n",
-	       wiphy_name(local->hw.wiphy), print_mac(mbuf, sta->sta.addr));
+	printk(KERN_DEBUG "%s: Destroyed STA %pM\n",
+	       wiphy_name(local->hw.wiphy), sta->sta.addr);
 #endif /* CONFIG_MAC80211_VERBOSE_DEBUG */
 
 	kfree(sta);
@@ -222,7 +220,6 @@ struct sta_info *sta_info_alloc(struct i
 	struct ieee80211_local *local = sdata->local;
 	struct sta_info *sta;
 	int i;
-	DECLARE_MAC_BUF(mbuf);
 
 	sta = kzalloc(sizeof(*sta) + local->hw.sta_data_size, gfp);
 	if (!sta)
@@ -263,8 +260,8 @@ struct sta_info *sta_info_alloc(struct i
 	skb_queue_head_init(&sta->tx_filtered);
 
 #ifdef CONFIG_MAC80211_VERBOSE_DEBUG
-	printk(KERN_DEBUG "%s: Allocated STA %s\n",
-	       wiphy_name(local->hw.wiphy), print_mac(mbuf, sta->sta.addr));
+	printk(KERN_DEBUG "%s: Allocated STA %pM\n",
+	       wiphy_name(local->hw.wiphy), sta->sta.addr);
 #endif /* CONFIG_MAC80211_VERBOSE_DEBUG */
 
 #ifdef CONFIG_MAC80211_MESH
@@ -281,7 +278,6 @@ int sta_info_insert(struct sta_info *sta
 	struct ieee80211_sub_if_data *sdata = sta->sdata;
 	unsigned long flags;
 	int err = 0;
-	DECLARE_MAC_BUF(mac);
 
 	/*
 	 * Can't be a WARN_ON because it can be triggered through a race:
@@ -322,8 +318,8 @@ int sta_info_insert(struct sta_info *sta
 	}
 
 #ifdef CONFIG_MAC80211_VERBOSE_DEBUG
-	printk(KERN_DEBUG "%s: Inserted STA %s\n",
-	       wiphy_name(local->hw.wiphy), print_mac(mac, sta->sta.addr));
+	printk(KERN_DEBUG "%s: Inserted STA %pM\n",
+	       wiphy_name(local->hw.wiphy), sta->sta.addr);
 #endif /* CONFIG_MAC80211_VERBOSE_DEBUG */
 
 	spin_unlock_irqrestore(&local->sta_lock, flags);
@@ -423,9 +419,6 @@ static void __sta_info_unlink(struct sta
 {
 	struct ieee80211_local *local = (*sta)->local;
 	struct ieee80211_sub_if_data *sdata = (*sta)->sdata;
-#ifdef CONFIG_MAC80211_VERBOSE_DEBUG
-	DECLARE_MAC_BUF(mbuf);
-#endif
 	/*
 	 * pull caller's reference if we're already gone.
 	 */
@@ -468,8 +461,8 @@ static void __sta_info_unlink(struct sta
 	}
 
 #ifdef CONFIG_MAC80211_VERBOSE_DEBUG
-	printk(KERN_DEBUG "%s: Removed STA %s\n",
-	       wiphy_name(local->hw.wiphy), print_mac(mbuf, (*sta)->sta.addr));
+	printk(KERN_DEBUG "%s: Removed STA %pM\n",
+	       wiphy_name(local->hw.wiphy), (*sta)->sta.addr);
 #endif /* CONFIG_MAC80211_VERBOSE_DEBUG */
 
 	/*
@@ -544,7 +537,6 @@ static void sta_info_cleanup_expire_buff
 	unsigned long flags;
 	struct sk_buff *skb;
 	struct ieee80211_sub_if_data *sdata;
-	DECLARE_MAC_BUF(mac);
 
 	if (skb_queue_empty(&sta->ps_tx_buf))
 		return;
@@ -564,8 +556,8 @@ static void sta_info_cleanup_expire_buff
 		sdata = sta->sdata;
 		local->total_ps_buffered--;
 #ifdef CONFIG_MAC80211_VERBOSE_PS_DEBUG
-		printk(KERN_DEBUG "Buffered frame expired (STA "
-		       "%s)\n", print_mac(mac, sta->sta.addr));
+		printk(KERN_DEBUG "Buffered frame expired (STA %pM)\n",
+		       sta->sta.addr);
 #endif
 		dev_kfree_skb(skb);
 
@@ -809,15 +801,14 @@ void ieee80211_sta_expire(struct ieee802
 	struct ieee80211_local *local = sdata->local;
 	struct sta_info *sta, *tmp;
 	LIST_HEAD(tmp_list);
-	DECLARE_MAC_BUF(mac);
 	unsigned long flags;
 
 	spin_lock_irqsave(&local->sta_lock, flags);
 	list_for_each_entry_safe(sta, tmp, &local->sta_list, list)
 		if (time_after(jiffies, sta->last_rx + exp_time)) {
 #ifdef CONFIG_MAC80211_IBSS_DEBUG
-			printk(KERN_DEBUG "%s: expiring inactive STA %s\n",
-			       sdata->dev->name, print_mac(mac, sta->sta.addr));
+			printk(KERN_DEBUG "%s: expiring inactive STA %pM\n",
+			       sdata->dev->name, sta->sta.addr);
 #endif
 			__sta_info_unlink(&sta);
 			if (sta)
--- everything.orig/net/mac80211/tkip.c	2008-10-25 01:42:51.000000000 +0200
+++ everything/net/mac80211/tkip.c	2008-10-25 01:44:43.000000000 +0200
@@ -263,10 +263,9 @@ int ieee80211_tkip_decrypt_data(struct c
 	     (iv32 == key->u.tkip.rx[queue].iv32 &&
 	      iv16 <= key->u.tkip.rx[queue].iv16))) {
 #ifdef CONFIG_MAC80211_TKIP_DEBUG
-		DECLARE_MAC_BUF(mac);
 		printk(KERN_DEBUG "TKIP replay detected for RX frame from "
-		       "%s (RX IV (%04x,%02x) <= prev. IV (%04x,%02x)\n",
-		       print_mac(mac, ta),
+		       "%pM (RX IV (%04x,%02x) <= prev. IV (%04x,%02x)\n",
+		       ta,
 		       iv32, iv16, key->u.tkip.rx[queue].iv32,
 		       key->u.tkip.rx[queue].iv16);
 #endif
@@ -287,9 +286,8 @@ int ieee80211_tkip_decrypt_data(struct c
 		{
 			int i;
 			u8 key_offset = NL80211_TKIP_DATA_OFFSET_ENCR_KEY;
-			DECLARE_MAC_BUF(mac);
-			printk(KERN_DEBUG "TKIP decrypt: Phase1 TA=%s"
-			       " TK=", print_mac(mac, ta));
+			printk(KERN_DEBUG "TKIP decrypt: Phase1 TA=%pM"
+			       " TK=", ta);
 			for (i = 0; i < 16; i++)
 				printk("%02x ",
 				       key->conf.key[key_offset + i]);
--- everything.orig/net/mac80211/tx.c	2008-10-25 01:42:51.000000000 +0200
+++ everything/net/mac80211/tx.c	2008-10-25 01:44:43.000000000 +0200
@@ -208,10 +208,9 @@ ieee80211_tx_h_check_assoc(struct ieee80
 			     tx->sdata->vif.type != NL80211_IFTYPE_ADHOC &&
 			     ieee80211_is_data(hdr->frame_control))) {
 #ifdef CONFIG_MAC80211_VERBOSE_DEBUG
-			DECLARE_MAC_BUF(mac);
 			printk(KERN_DEBUG "%s: dropped data frame to not "
-			       "associated station %s\n",
-			       tx->dev->name, print_mac(mac, hdr->addr1));
+			       "associated station %pM\n",
+			       tx->dev->name, hdr->addr1);
 #endif /* CONFIG_MAC80211_VERBOSE_DEBUG */
 			I802_DEBUG_INC(tx->local->tx_handlers_drop_not_assoc);
 			return TX_DROP;
@@ -338,7 +337,6 @@ ieee80211_tx_h_unicast_ps_buf(struct iee
 	struct ieee80211_tx_info *info = IEEE80211_SKB_CB(tx->skb);
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *)tx->skb->data;
 	u32 staflags;
-	DECLARE_MAC_BUF(mac);
 
 	if (unlikely(!sta || ieee80211_is_probe_resp(hdr->frame_control)))
 		return TX_CONTINUE;
@@ -348,9 +346,9 @@ ieee80211_tx_h_unicast_ps_buf(struct iee
 	if (unlikely((staflags & WLAN_STA_PS) &&
 		     !(staflags & WLAN_STA_PSPOLL))) {
 #ifdef CONFIG_MAC80211_VERBOSE_PS_DEBUG
-		printk(KERN_DEBUG "STA %s aid %d: PS buffer (entries "
+		printk(KERN_DEBUG "STA %pM aid %d: PS buffer (entries "
 		       "before %d)\n",
-		       print_mac(mac, sta->sta.addr), sta->sta.aid,
+		       sta->sta.addr, sta->sta.aid,
 		       skb_queue_len(&sta->ps_tx_buf));
 #endif /* CONFIG_MAC80211_VERBOSE_PS_DEBUG */
 		if (tx->local->total_ps_buffered >= TOTAL_MAX_TX_BUFFER)
@@ -359,9 +357,9 @@ ieee80211_tx_h_unicast_ps_buf(struct iee
 			struct sk_buff *old = skb_dequeue(&sta->ps_tx_buf);
 #ifdef CONFIG_MAC80211_VERBOSE_PS_DEBUG
 			if (net_ratelimit()) {
-				printk(KERN_DEBUG "%s: STA %s TX "
+				printk(KERN_DEBUG "%s: STA %pM TX "
 				       "buffer full - dropping oldest frame\n",
-				       tx->dev->name, print_mac(mac, sta->sta.addr));
+				       tx->dev->name, sta->sta.addr);
 			}
 #endif
 			dev_kfree_skb(old);
@@ -378,9 +376,9 @@ ieee80211_tx_h_unicast_ps_buf(struct iee
 	}
 #ifdef CONFIG_MAC80211_VERBOSE_PS_DEBUG
 	else if (unlikely(test_sta_flags(sta, WLAN_STA_PS))) {
-		printk(KERN_DEBUG "%s: STA %s in PS mode, but pspoll "
+		printk(KERN_DEBUG "%s: STA %pM in PS mode, but pspoll "
 		       "set -> send frame\n", tx->dev->name,
-		       print_mac(mac, sta->sta.addr));
+		       sta->sta.addr);
 	}
 #endif /* CONFIG_MAC80211_VERBOSE_PS_DEBUG */
 	clear_sta_flags(sta, WLAN_STA_PSPOLL);
@@ -1596,12 +1594,10 @@ int ieee80211_subif_start_xmit(struct sk
 		       compare_ether_addr(dev->dev_addr,
 					  skb->data + ETH_ALEN) == 0))) {
 #ifdef CONFIG_MAC80211_VERBOSE_DEBUG
-		DECLARE_MAC_BUF(mac);
-
 		if (net_ratelimit())
-			printk(KERN_DEBUG "%s: dropped frame to %s"
+			printk(KERN_DEBUG "%s: dropped frame to %pM"
 			       " (unauthorized port)\n", dev->name,
-			       print_mac(mac, hdr.addr1));
+			       hdr.addr1);
 #endif
 
 		I802_DEBUG_INC(local->tx_handlers_drop_unauth_port);
--- everything.orig/net/mac80211/wme.c	2008-10-25 01:42:51.000000000 +0200
+++ everything/net/mac80211/wme.c	2008-10-25 01:44:43.000000000 +0200
@@ -206,13 +206,11 @@ int ieee80211_ht_agg_queue_add(struct ie
 			 * on the previous queue
 			 * since HT is strict in order */
 #ifdef CONFIG_MAC80211_HT_DEBUG
-			if (net_ratelimit()) {
-				DECLARE_MAC_BUF(mac);
+			if (net_ratelimit())
 				printk(KERN_DEBUG "allocated aggregation queue"
-					" %d tid %d addr %s pool=0x%lX\n",
-					i, tid, print_mac(mac, sta->sta.addr),
+					" %d tid %d addr %pM pool=0x%lX\n",
+					i, tid, sta->sta.addr,
 					local->queue_pool[0]);
-			}
 #endif /* CONFIG_MAC80211_HT_DEBUG */
 			return 0;
 		}
--- everything.orig/net/mac80211/wpa.c	2008-10-25 01:42:52.000000000 +0200
+++ everything/net/mac80211/wpa.c	2008-10-25 01:44:43.000000000 +0200
@@ -87,7 +87,6 @@ ieee80211_rx_h_michael_mic_verify(struct
 	u8 mic[MICHAEL_MIC_LEN];
 	struct sk_buff *skb = rx->skb;
 	int authenticator = 1, wpa_test = 0;
-	DECLARE_MAC_BUF(mac);
 
 	/* No way to verify the MIC if the hardware stripped it */
 	if (rx->status->flag & RX_FLAG_MMIC_STRIPPED)
@@ -220,7 +219,6 @@ ieee80211_crypto_tkip_decrypt(struct iee
 	int hdrlen, res, hwaccel = 0, wpa_test = 0;
 	struct ieee80211_key *key = rx->key;
 	struct sk_buff *skb = rx->skb;
-	DECLARE_MAC_BUF(mac);
 
 	hdrlen = ieee80211_hdrlen(hdr->frame_control);
 
@@ -445,7 +443,6 @@ ieee80211_crypto_ccmp_decrypt(struct iee
 	struct sk_buff *skb = rx->skb;
 	u8 pn[CCMP_PN_LEN];
 	int data_len;
-	DECLARE_MAC_BUF(mac);
 
 	hdrlen = ieee80211_hdrlen(hdr->frame_control);
 


