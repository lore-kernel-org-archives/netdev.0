From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] mac80211: aggregation: Convert timers to use timer_setup()
Date: Tue, 17 Oct 2017 13:25:45 -0700
Message-ID: <20171017202545.GA115810@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

This removes the tid mapping array and expands the tid structures to
add a pointer back to the station, along with the tid index itself.

Cc: Johannes Berg <johannes@sipsolutions.net>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: linux-wireless@vger.kernel.org
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
Resend, with linux-wireless in Cc (no idea how it got missed before)
---
 net/mac80211/agg-rx.c   | 41 +++++++++++++++++------------------------
 net/mac80211/agg-tx.c   | 42 ++++++++++++++++--------------------------
 net/mac80211/sta_info.c |  8 --------
 net/mac80211/sta_info.h | 12 ++++++++++--
 4 files changed, 43 insertions(+), 60 deletions(-)

diff --git a/net/mac80211/agg-rx.c b/net/mac80211/agg-rx.c
index 88cc1ae935ea..63aba6dbc92a 100644
--- a/net/mac80211/agg-rx.c
+++ b/net/mac80211/agg-rx.c
@@ -151,21 +151,17 @@ EXPORT_SYMBOL(ieee80211_stop_rx_ba_session);
  * After accepting the AddBA Request we activated a timer,
  * resetting it after each frame that arrives from the originator.
  */
-static void sta_rx_agg_session_timer_expired(unsigned long data)
+static void sta_rx_agg_session_timer_expired(struct timer_list *t)
 {
-	/* not an elegant detour, but there is no choice as the timer passes
-	 * only one argument, and various sta_info are needed here, so init
-	 * flow in sta_info_create gives the TID as data, while the timer_to_id
-	 * array gives the sta through container_of */
-	u8 *ptid = (u8 *)data;
-	u8 *timer_to_id = ptid - *ptid;
-	struct sta_info *sta = container_of(timer_to_id, struct sta_info,
-					 timer_to_tid[0]);
+	struct tid_ampdu_rx *tid_rx_timer =
+		from_timer(tid_rx_timer, t, session_timer);
+	struct sta_info *sta = tid_rx_timer->sta;
+	u16 tid = tid_rx_timer->tid;
 	struct tid_ampdu_rx *tid_rx;
 	unsigned long timeout;
 
 	rcu_read_lock();
-	tid_rx = rcu_dereference(sta->ampdu_mlme.tid_rx[*ptid]);
+	tid_rx = rcu_dereference(sta->ampdu_mlme.tid_rx[tid]);
 	if (!tid_rx) {
 		rcu_read_unlock();
 		return;
@@ -180,21 +176,18 @@ static void sta_rx_agg_session_timer_expired(unsigned long data)
 	rcu_read_unlock();
 
 	ht_dbg(sta->sdata, "RX session timer expired on %pM tid %d\n",
-	       sta->sta.addr, (u16)*ptid);
+	       sta->sta.addr, tid);
 
-	set_bit(*ptid, sta->ampdu_mlme.tid_rx_timer_expired);
+	set_bit(tid, sta->ampdu_mlme.tid_rx_timer_expired);
 	ieee80211_queue_work(&sta->local->hw, &sta->ampdu_mlme.work);
 }
 
-static void sta_rx_agg_reorder_timer_expired(unsigned long data)
+static void sta_rx_agg_reorder_timer_expired(struct timer_list *t)
 {
-	u8 *ptid = (u8 *)data;
-	u8 *timer_to_id = ptid - *ptid;
-	struct sta_info *sta = container_of(timer_to_id, struct sta_info,
-			timer_to_tid[0]);
+	struct tid_ampdu_rx *tid_rx = from_timer(tid_rx, t, reorder_timer);
 
 	rcu_read_lock();
-	ieee80211_release_reorder_timeout(sta, *ptid);
+	ieee80211_release_reorder_timeout(tid_rx->sta, tid_rx->tid);
 	rcu_read_unlock();
 }
 
@@ -356,14 +349,12 @@ void ___ieee80211_start_rx_ba_session(struct sta_info *sta,
 	spin_lock_init(&tid_agg_rx->reorder_lock);
 
 	/* rx timer */
-	setup_deferrable_timer(&tid_agg_rx->session_timer,
-			       sta_rx_agg_session_timer_expired,
-			       (unsigned long)&sta->timer_to_tid[tid]);
+	timer_setup(&tid_agg_rx->session_timer,
+		    sta_rx_agg_session_timer_expired, TIMER_DEFERRABLE);
 
 	/* rx reorder timer */
-	setup_timer(&tid_agg_rx->reorder_timer,
-		    sta_rx_agg_reorder_timer_expired,
-		    (unsigned long)&sta->timer_to_tid[tid]);
+	timer_setup(&tid_agg_rx->reorder_timer,
+		    sta_rx_agg_reorder_timer_expired, 0);
 
 	/* prepare reordering buffer */
 	tid_agg_rx->reorder_buf =
@@ -399,6 +390,8 @@ void ___ieee80211_start_rx_ba_session(struct sta_info *sta,
 	tid_agg_rx->auto_seq = auto_seq;
 	tid_agg_rx->started = false;
 	tid_agg_rx->reorder_buf_filtered = 0;
+	tid_agg_rx->tid = tid;
+	tid_agg_rx->sta = sta;
 	status = WLAN_STATUS_SUCCESS;
 
 	/* activate it for RX */
diff --git a/net/mac80211/agg-tx.c b/net/mac80211/agg-tx.c
index bef516ec47f9..dedbb1fb10e7 100644
--- a/net/mac80211/agg-tx.c
+++ b/net/mac80211/agg-tx.c
@@ -422,15 +422,12 @@ int ___ieee80211_stop_tx_ba_session(struct sta_info *sta, u16 tid,
  * add Block Ack response will arrive from the recipient.
  * If this timer expires sta_addba_resp_timer_expired will be executed.
  */
-static void sta_addba_resp_timer_expired(unsigned long data)
+static void sta_addba_resp_timer_expired(struct timer_list *t)
 {
-	/* not an elegant detour, but there is no choice as the timer passes
-	 * only one argument, and both sta_info and TID are needed, so init
-	 * flow in sta_info_create gives the TID as data, while the timer_to_id
-	 * array gives the sta through container_of */
-	u16 tid = *(u8 *)data;
-	struct sta_info *sta = container_of((void *)data,
-		struct sta_info, timer_to_tid[tid]);
+	struct tid_ampdu_tx *tid_tx_timer =
+		from_timer(tid_tx_timer, t, addba_resp_timer);
+	struct sta_info *sta = tid_tx_timer->sta;
+	u16 tid = tid_tx_timer->tid;
 	struct tid_ampdu_tx *tid_tx;
 
 	/* check if the TID waits for addBA response */
@@ -525,21 +522,17 @@ void ieee80211_tx_ba_session_handle_start(struct sta_info *sta, int tid)
  * After accepting the AddBA Response we activated a timer,
  * resetting it after each frame that we send.
  */
-static void sta_tx_agg_session_timer_expired(unsigned long data)
+static void sta_tx_agg_session_timer_expired(struct timer_list *t)
 {
-	/* not an elegant detour, but there is no choice as the timer passes
-	 * only one argument, and various sta_info are needed here, so init
-	 * flow in sta_info_create gives the TID as data, while the timer_to_id
-	 * array gives the sta through container_of */
-	u8 *ptid = (u8 *)data;
-	u8 *timer_to_id = ptid - *ptid;
-	struct sta_info *sta = container_of(timer_to_id, struct sta_info,
-					 timer_to_tid[0]);
+	struct tid_ampdu_tx *tid_tx_timer =
+		from_timer(tid_tx_timer, t, session_timer);
+	struct sta_info *sta = tid_tx_timer->sta;
+	u16 tid = tid_tx_timer->tid;
 	struct tid_ampdu_tx *tid_tx;
 	unsigned long timeout;
 
 	rcu_read_lock();
-	tid_tx = rcu_dereference(sta->ampdu_mlme.tid_tx[*ptid]);
+	tid_tx = rcu_dereference(sta->ampdu_mlme.tid_tx[tid]);
 	if (!tid_tx || test_bit(HT_AGG_STATE_STOPPING, &tid_tx->state)) {
 		rcu_read_unlock();
 		return;
@@ -555,9 +548,9 @@ static void sta_tx_agg_session_timer_expired(unsigned long data)
 	rcu_read_unlock();
 
 	ht_dbg(sta->sdata, "tx session timer expired on %pM tid %d\n",
-	       sta->sta.addr, (u16)*ptid);
+	       sta->sta.addr, tid);
 
-	ieee80211_stop_tx_ba_session(&sta->sta, *ptid);
+	ieee80211_stop_tx_ba_session(&sta->sta, tid);
 }
 
 int ieee80211_start_tx_ba_session(struct ieee80211_sta *pubsta, u16 tid,
@@ -672,14 +665,11 @@ int ieee80211_start_tx_ba_session(struct ieee80211_sta *pubsta, u16 tid,
 	tid_tx->timeout = timeout;
 
 	/* response timer */
-	setup_timer(&tid_tx->addba_resp_timer,
-		    sta_addba_resp_timer_expired,
-		    (unsigned long)&sta->timer_to_tid[tid]);
+	timer_setup(&tid_tx->addba_resp_timer, sta_addba_resp_timer_expired, 0);
 
 	/* tx timer */
-	setup_deferrable_timer(&tid_tx->session_timer,
-			       sta_tx_agg_session_timer_expired,
-			       (unsigned long)&sta->timer_to_tid[tid]);
+	timer_setup(&tid_tx->session_timer,
+		    sta_tx_agg_session_timer_expired, TIMER_DEFERRABLE);
 
 	/* assign a dialog token */
 	sta->ampdu_mlme.dialog_token_allocator++;
diff --git a/net/mac80211/sta_info.c b/net/mac80211/sta_info.c
index 877d35796776..b5add1464aeb 100644
--- a/net/mac80211/sta_info.c
+++ b/net/mac80211/sta_info.c
@@ -379,14 +379,6 @@ struct sta_info *sta_info_alloc(struct ieee80211_sub_if_data *sdata,
 	if (sta_prepare_rate_control(local, sta, gfp))
 		goto free_txq;
 
-	for (i = 0; i < IEEE80211_NUM_TIDS; i++) {
-		/*
-		 * timer_to_tid must be initialized with identity mapping
-		 * to enable session_timer's data differentiation. See
-		 * sta_rx_agg_session_timer_expired for usage.
-		 */
-		sta->timer_to_tid[i] = i;
-	}
 	for (i = 0; i < IEEE80211_NUM_ACS; i++) {
 		skb_queue_head_init(&sta->ps_tx_buf[i]);
 		skb_queue_head_init(&sta->tx_filtered[i]);
diff --git a/net/mac80211/sta_info.h b/net/mac80211/sta_info.h
index 5c54acd10562..1b9c1e81495d 100644
--- a/net/mac80211/sta_info.h
+++ b/net/mac80211/sta_info.h
@@ -126,6 +126,8 @@ enum ieee80211_agg_stop_reason {
 	AGG_STOP_DESTROY_STA,
 };
 
+struct sta_info;
+
 /**
  * struct tid_ampdu_tx - TID aggregation information (Tx).
  *
@@ -133,8 +135,10 @@ enum ieee80211_agg_stop_reason {
  * @session_timer: check if we keep Tx-ing on the TID (by timeout value)
  * @addba_resp_timer: timer for peer's response to addba request
  * @pending: pending frames queue -- use sta's spinlock to protect
+ * @sta: station we are attached to
  * @dialog_token: dialog token for aggregation session
  * @timeout: session timeout value to be filled in ADDBA requests
+ * @tid: index in station tid list
  * @state: session state (see above)
  * @last_tx: jiffies of last tx activity
  * @stop_initiator: initiator of a session stop
@@ -158,9 +162,11 @@ struct tid_ampdu_tx {
 	struct timer_list session_timer;
 	struct timer_list addba_resp_timer;
 	struct sk_buff_head pending;
+	struct sta_info *sta;
 	unsigned long state;
 	unsigned long last_tx;
 	u16 timeout;
+	u16 tid;
 	u8 dialog_token;
 	u8 stop_initiator;
 	bool tx_stop;
@@ -181,12 +187,14 @@ struct tid_ampdu_tx {
  * @reorder_time: jiffies when skb was added
  * @session_timer: check if peer keeps Tx-ing on the TID (by timeout value)
  * @reorder_timer: releases expired frames from the reorder buffer.
+ * @sta: station we are attached to
  * @last_rx: jiffies of last rx activity
  * @head_seq_num: head sequence number in reordering buffer.
  * @stored_mpdu_num: number of MPDUs in reordering buffer
  * @ssn: Starting Sequence Number expected to be aggregated.
  * @buf_size: buffer size for incoming A-MPDUs
  * @timeout: reset timer value (in TUs).
+ * @tid: index in station tid list
  * @rcu_head: RCU head used for freeing this struct
  * @reorder_lock: serializes access to reorder buffer, see below.
  * @auto_seq: used for offloaded BA sessions to automatically pick head_seq_and
@@ -208,6 +216,7 @@ struct tid_ampdu_rx {
 	u64 reorder_buf_filtered;
 	struct sk_buff_head *reorder_buf;
 	unsigned long *reorder_time;
+	struct sta_info *sta;
 	struct timer_list session_timer;
 	struct timer_list reorder_timer;
 	unsigned long last_rx;
@@ -216,6 +225,7 @@ struct tid_ampdu_rx {
 	u16 ssn;
 	u16 buf_size;
 	u16 timeout;
+	u16 tid;
 	u8 auto_seq:1,
 	   removed:1,
 	   started:1;
@@ -447,7 +457,6 @@ struct ieee80211_sta_rx_stats {
  *	plus one for non-QoS frames)
  * @tid_seq: per-TID sequence numbers for sending to this STA
  * @ampdu_mlme: A-MPDU state machine state
- * @timer_to_tid: identity mapping to ID timers
  * @mesh: mesh STA information
  * @debugfs_dir: debug filesystem directory dentry
  * @dead: set to true when sta is unlinked
@@ -554,7 +563,6 @@ struct sta_info {
 	 * Aggregation information, locked with lock.
 	 */
 	struct sta_ampdu_mlme ampdu_mlme;
-	u8 timer_to_tid[IEEE80211_NUM_TIDS];
 
 #ifdef CONFIG_MAC80211_DEBUGFS
 	struct dentry *debugfs_dir;
-- 
2.7.4


-- 
Kees Cook
Pixel Security
