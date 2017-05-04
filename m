From: Joe Perches <joe@perches.com>
Subject: [PATCH] mac80211: Create ieee80211_if_process_skb from ieee80211_iface_work
Date: Thu,  4 May 2017 10:30:51 -0700
Message-ID: <401d68b9015dc036589c99a26ef4664000cc821e.1493919003.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This function is pretty long and the skb handling is a bit long too.
Create a new function just for the skb processing.

This isolates the code and reduces indentation a bit too.

No change in object size.

$ size net/mac80211/iface.o*
   text	   data	    bss	    dec	    hex	filename
  15736	     24	      0	  15760	   3d90	net/mac80211/iface.o.new
  15736	     24	      0	  15760	   3d90	net/mac80211/iface.o.old

Miscellanea:

o Use explicit casts to proper types instead of casts to (void *)
  and have the compiler do the implicit cast
o Rewrap comments

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/mac80211/iface.c | 253 ++++++++++++++++++++++++++-------------------------
 1 file changed, 127 insertions(+), 126 deletions(-)

diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index 3bd5b81f5d81..b51d3956feaa 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -1230,145 +1230,125 @@ static void ieee80211_if_setup_no_queue(struct net_device *dev)
 	dev->priv_flags |= IFF_NO_QUEUE;
 }
 
-static void ieee80211_iface_work(struct work_struct *work)
+static void ieee80211_if_process_skb(struct sk_buff *skb,
+				     struct ieee80211_sub_if_data *sdata,
+				     struct ieee80211_local *local)
 {
-	struct ieee80211_sub_if_data *sdata =
-		container_of(work, struct ieee80211_sub_if_data, work);
-	struct ieee80211_local *local = sdata->local;
-	struct sk_buff *skb;
-	struct sta_info *sta;
 	struct ieee80211_ra_tid *ra_tid;
 	struct ieee80211_rx_agg *rx_agg;
-
-	if (!ieee80211_sdata_running(sdata))
-		return;
-
-	if (test_bit(SCAN_SW_SCANNING, &local->scanning))
-		return;
-
-	if (!ieee80211_can_run_worker(local))
-		return;
-
-	/* first process frames */
-	while ((skb = skb_dequeue(&sdata->skb_queue))) {
-		struct ieee80211_mgmt *mgmt = (void *)skb->data;
-
-		if (skb->pkt_type == IEEE80211_SDATA_QUEUE_AGG_START) {
-			ra_tid = (void *)&skb->cb;
-			ieee80211_start_tx_ba_cb(&sdata->vif, ra_tid->ra,
-						 ra_tid->tid);
-		} else if (skb->pkt_type == IEEE80211_SDATA_QUEUE_AGG_STOP) {
-			ra_tid = (void *)&skb->cb;
-			ieee80211_stop_tx_ba_cb(&sdata->vif, ra_tid->ra,
-						ra_tid->tid);
-		} else if (skb->pkt_type == IEEE80211_SDATA_QUEUE_RX_AGG_START) {
-			rx_agg = (void *)&skb->cb;
-			mutex_lock(&local->sta_mtx);
-			sta = sta_info_get_bss(sdata, rx_agg->addr);
-			if (sta)
-				__ieee80211_start_rx_ba_session(sta,
-						0, 0, 0, 1, rx_agg->tid,
-						IEEE80211_MAX_AMPDU_BUF,
-						false, true);
-			mutex_unlock(&local->sta_mtx);
-		} else if (skb->pkt_type == IEEE80211_SDATA_QUEUE_RX_AGG_STOP) {
-			rx_agg = (void *)&skb->cb;
-			mutex_lock(&local->sta_mtx);
-			sta = sta_info_get_bss(sdata, rx_agg->addr);
-			if (sta)
-				__ieee80211_stop_rx_ba_session(sta,
-							rx_agg->tid,
-							WLAN_BACK_RECIPIENT, 0,
-							false);
-			mutex_unlock(&local->sta_mtx);
-		} else if (ieee80211_is_action(mgmt->frame_control) &&
-			   mgmt->u.action.category == WLAN_CATEGORY_BACK) {
-			int len = skb->len;
-
-			mutex_lock(&local->sta_mtx);
-			sta = sta_info_get_bss(sdata, mgmt->sa);
-			if (sta) {
-				switch (mgmt->u.action.u.addba_req.action_code) {
-				case WLAN_ACTION_ADDBA_REQ:
-					ieee80211_process_addba_request(
-							local, sta, mgmt, len);
-					break;
-				case WLAN_ACTION_ADDBA_RESP:
-					ieee80211_process_addba_resp(local, sta,
-								     mgmt, len);
-					break;
-				case WLAN_ACTION_DELBA:
-					ieee80211_process_delba(sdata, sta,
+	struct sta_info *sta;
+	struct ieee80211_mgmt *mgmt = (void *)skb->data;
+
+	if (skb->pkt_type == IEEE80211_SDATA_QUEUE_AGG_START) {
+		ra_tid = (struct ieee80211_ra_tid *)&skb->cb;
+		ieee80211_start_tx_ba_cb(&sdata->vif, ra_tid->ra, ra_tid->tid);
+	} else if (skb->pkt_type == IEEE80211_SDATA_QUEUE_AGG_STOP) {
+		ra_tid = (struct ieee80211_ra_tid *)&skb->cb;
+		ieee80211_stop_tx_ba_cb(&sdata->vif, ra_tid->ra, ra_tid->tid);
+	} else if (skb->pkt_type == IEEE80211_SDATA_QUEUE_RX_AGG_START) {
+		rx_agg = (struct ieee80211_rx_agg *)&skb->cb;
+		mutex_lock(&local->sta_mtx);
+		sta = sta_info_get_bss(sdata, rx_agg->addr);
+		if (sta)
+			__ieee80211_start_rx_ba_session(sta,
+							0, 0, 0, 1, rx_agg->tid,
+							IEEE80211_MAX_AMPDU_BUF,
+							false, true);
+		mutex_unlock(&local->sta_mtx);
+	} else if (skb->pkt_type == IEEE80211_SDATA_QUEUE_RX_AGG_STOP) {
+		rx_agg = (struct ieee80211_rx_agg *)&skb->cb;
+		mutex_lock(&local->sta_mtx);
+		sta = sta_info_get_bss(sdata, rx_agg->addr);
+		if (sta)
+			__ieee80211_stop_rx_ba_session(sta, rx_agg->tid,
+						       WLAN_BACK_RECIPIENT, 0,
+						       false);
+		mutex_unlock(&local->sta_mtx);
+	} else if (ieee80211_is_action(mgmt->frame_control) &&
+		   mgmt->u.action.category == WLAN_CATEGORY_BACK) {
+		int len = skb->len;
+
+		mutex_lock(&local->sta_mtx);
+		sta = sta_info_get_bss(sdata, mgmt->sa);
+		if (sta) {
+			switch (mgmt->u.action.u.addba_req.action_code) {
+			case WLAN_ACTION_ADDBA_REQ:
+				ieee80211_process_addba_request(local, sta,
 								mgmt, len);
-					break;
-				default:
-					WARN_ON(1);
-					break;
-				}
-			}
-			mutex_unlock(&local->sta_mtx);
-		} else if (ieee80211_is_action(mgmt->frame_control) &&
-			   mgmt->u.action.category == WLAN_CATEGORY_VHT) {
-			switch (mgmt->u.action.u.vht_group_notif.action_code) {
-			case WLAN_VHT_ACTION_OPMODE_NOTIF: {
-				struct ieee80211_rx_status *status;
-				enum nl80211_band band;
-				u8 opmode;
-
-				status = IEEE80211_SKB_RXCB(skb);
-				band = status->band;
-				opmode = mgmt->u.action.u.vht_opmode_notif.operating_mode;
-
-				mutex_lock(&local->sta_mtx);
-				sta = sta_info_get_bss(sdata, mgmt->sa);
-
-				if (sta)
-					ieee80211_vht_handle_opmode(sdata, sta,
-								    opmode,
-								    band);
-
-				mutex_unlock(&local->sta_mtx);
 				break;
-			}
-			case WLAN_VHT_ACTION_GROUPID_MGMT:
-				ieee80211_process_mu_groups(sdata, mgmt);
+			case WLAN_ACTION_ADDBA_RESP:
+				ieee80211_process_addba_resp(local, sta,
+							     mgmt, len);
+				break;
+			case WLAN_ACTION_DELBA:
+				ieee80211_process_delba(sdata, sta, mgmt, len);
 				break;
 			default:
 				WARN_ON(1);
 				break;
 			}
-		} else if (ieee80211_is_data_qos(mgmt->frame_control)) {
-			struct ieee80211_hdr *hdr = (void *)mgmt;
-			/*
-			 * So the frame isn't mgmt, but frame_control
-			 * is at the right place anyway, of course, so
-			 * the if statement is correct.
-			 *
-			 * Warn if we have other data frame types here,
-			 * they must not get here.
-			 */
-			WARN_ON(hdr->frame_control &
-					cpu_to_le16(IEEE80211_STYPE_NULLFUNC));
-			WARN_ON(!(hdr->seq_ctrl &
-					cpu_to_le16(IEEE80211_SCTL_FRAG)));
-			/*
-			 * This was a fragment of a frame, received while
-			 * a block-ack session was active. That cannot be
-			 * right, so terminate the session.
-			 */
+		}
+		mutex_unlock(&local->sta_mtx);
+	} else if (ieee80211_is_action(mgmt->frame_control) &&
+		   mgmt->u.action.category == WLAN_CATEGORY_VHT) {
+		switch (mgmt->u.action.u.vht_group_notif.action_code) {
+		case WLAN_VHT_ACTION_OPMODE_NOTIF: {
+			struct ieee80211_rx_status *status;
+			enum nl80211_band band;
+			u8 opmode;
+
+			status = IEEE80211_SKB_RXCB(skb);
+			band = status->band;
+			opmode = mgmt->u.action.u.vht_opmode_notif.operating_mode;
+
 			mutex_lock(&local->sta_mtx);
 			sta = sta_info_get_bss(sdata, mgmt->sa);
-			if (sta) {
-				u16 tid = *ieee80211_get_qos_ctl(hdr) &
-						IEEE80211_QOS_CTL_TID_MASK;
-
-				__ieee80211_stop_rx_ba_session(
-					sta, tid, WLAN_BACK_RECIPIENT,
-					WLAN_REASON_QSTA_REQUIRE_SETUP,
-					true);
-			}
+
+			if (sta)
+				ieee80211_vht_handle_opmode(sdata, sta,
+							    opmode, band);
+
 			mutex_unlock(&local->sta_mtx);
-		} else switch (sdata->vif.type) {
+			break;
+		}
+		case WLAN_VHT_ACTION_GROUPID_MGMT:
+			ieee80211_process_mu_groups(sdata, mgmt);
+			break;
+		default:
+			WARN_ON(1);
+			break;
+		}
+	} else if (ieee80211_is_data_qos(mgmt->frame_control)) {
+		struct ieee80211_hdr *hdr = (void *)mgmt;
+		/*
+		 * So the frame isn't mgmt, but frame_control is at the right
+		 * place anyway, of course, so the if statement is correct.
+		 *
+		 * Warn if we have other data frame types here,
+		 * they must not get here.
+		 */
+		WARN_ON(hdr->frame_control &
+			cpu_to_le16(IEEE80211_STYPE_NULLFUNC));
+		WARN_ON(!(hdr->seq_ctrl & cpu_to_le16(IEEE80211_SCTL_FRAG)));
+		/*
+		 * This was a fragment of a frame,
+		 * received while a block-ack session was active.
+		 * That cannot be right, so terminate the session.
+		 */
+		mutex_lock(&local->sta_mtx);
+		sta = sta_info_get_bss(sdata, mgmt->sa);
+		if (sta) {
+			u16 tid = *ieee80211_get_qos_ctl(hdr) &
+				IEEE80211_QOS_CTL_TID_MASK;
+
+			__ieee80211_stop_rx_ba_session(sta, tid,
+						       WLAN_BACK_RECIPIENT,
+						       WLAN_REASON_QSTA_REQUIRE_SETUP,
+						       true);
+		}
+		mutex_unlock(&local->sta_mtx);
+	} else {
+		switch (sdata->vif.type) {
 		case NL80211_IFTYPE_STATION:
 			ieee80211_sta_rx_queued_mgmt(sdata, skb);
 			break;
@@ -1384,7 +1364,28 @@ static void ieee80211_iface_work(struct work_struct *work)
 			WARN(1, "frame for unexpected interface type");
 			break;
 		}
+	}
+}
+
+static void ieee80211_iface_work(struct work_struct *work)
+{
+	struct ieee80211_sub_if_data *sdata =
+		container_of(work, struct ieee80211_sub_if_data, work);
+	struct ieee80211_local *local = sdata->local;
+	struct sk_buff *skb;
+
+	if (!ieee80211_sdata_running(sdata))
+		return;
+
+	if (test_bit(SCAN_SW_SCANNING, &local->scanning))
+		return;
 
+	if (!ieee80211_can_run_worker(local))
+		return;
+
+	/* first process frames */
+	while ((skb = skb_dequeue(&sdata->skb_queue))) {
+		ieee80211_if_process_skb(skb, sdata, local);
 		kfree_skb(skb);
 	}
 
-- 
2.10.0.rc2.1.g053435c
