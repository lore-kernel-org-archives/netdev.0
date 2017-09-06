From: Stefano Brivio <sbrivio@redhat.com>
Subject: Re: hung task in mac80211
Date: Wed, 6 Sep 2017 16:27:48 +0200
Message-ID: <20170906162748.071b040e@elisabeth>
References: <CAGnkfhwi9MmtLneeU23iWEGLj9cb1ODb3KzzOqTDvA6nNVsugg@mail.gmail.com>
        <1504702728.13457.17.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Matteo Croce <mcroce@redhat.com>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1504702728.13457.17.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 06 Sep 2017 14:58:48 +0200
Johannes Berg <johannes@sipsolutions.net> wrote:

> +void __ieee80211_start_rx_ba_session(struct sta_info *sta,
> +				     u8 dialog_token, u16 timeout,
> +				     u16 start_seq_num, u16 ba_policy, u16 tid,
> +				     u16 buf_size, bool tx, bool auto_seq)
> +{
> +	mutex_lock(&sta->ampdu_mlme.mtx);
> +	___ieee80211_start_rx_ba_session(sta, dialog_token, timeout,
> +					 start_seq_num, ba_policy, tid,
> +					 buf_size, tx, auto_seq);
> +	mutex_unlock(&sta->ampdu_mlme.mtx);
> +}
> +

Sorry for the extended bothering :) but here, you're extending quite a
bit the scope of the lock also when__ieee80211_start_rx_ba_session() is
called by ieee80211_process_addba_request(). No idea what the hit can
be, but we can't safely assume it's nothing either. What about simply
introducing a 'ampdu_mlme_lock_held' argument instead? Something like:

diff --git a/net/mac80211/agg-rx.c b/net/mac80211/agg-rx.c
index 2b36eff5d97e..35a9eff1ec66 100644
--- a/net/mac80211/agg-rx.c
+++ b/net/mac80211/agg-rx.c
@@ -248,7 +248,8 @@ static void ieee80211_send_addba_resp(struct ieee80211_sub_if_data *sdata, u8 *d
 void __ieee80211_start_rx_ba_session(struct sta_info *sta,
 				     u8 dialog_token, u16 timeout,
 				     u16 start_seq_num, u16 ba_policy, u16 tid,
-				     u16 buf_size, bool tx, bool auto_seq)
+				     u16 buf_size, bool tx, bool auto_seq,
+				     bool ampdu_mlme_lock_held)
 {
 	struct ieee80211_local *local = sta->sdata->local;
 	struct tid_ampdu_rx *tid_agg_rx;
@@ -311,7 +312,8 @@ void __ieee80211_start_rx_ba_session(struct sta_info *sta,
 	       buf_size, sta->sta.addr);
 
 	/* examine state machine */
-	mutex_lock(&sta->ampdu_mlme.mtx);
+	if (!ampdu_mlme_lock_held)
+		mutex_lock(&sta->ampdu_mlme.mtx);
 
 	if (test_bit(tid, sta->ampdu_mlme.agg_session_valid)) {
 		if (sta->ampdu_mlme.tid_rx_token[tid] == dialog_token) {
@@ -415,7 +417,8 @@ void __ieee80211_start_rx_ba_session(struct sta_info *sta,
 		__clear_bit(tid, sta->ampdu_mlme.unexpected_agg);
 		sta->ampdu_mlme.tid_rx_token[tid] = dialog_token;
 	}
-	mutex_unlock(&sta->ampdu_mlme.mtx);
+	if (!ampdu_mlme_lock_held)
+		mutex_unlock(&sta->ampdu_mlme.mtx);
 
 end_no_lock:
 	if (tx)
@@ -445,7 +448,7 @@ void ieee80211_process_addba_request(struct ieee80211_local *local,
 
 	__ieee80211_start_rx_ba_session(sta, dialog_token, timeout,
 					start_seq_num, ba_policy, tid,
-					buf_size, true, false);
+					buf_size, true, false, false);
 }
 
 void ieee80211_manage_rx_ba_offl(struct ieee80211_vif *vif,
diff --git a/net/mac80211/ht.c b/net/mac80211/ht.c
index c92df492e898..59ba67e8942f 100644
--- a/net/mac80211/ht.c
+++ b/net/mac80211/ht.c
@@ -335,7 +335,7 @@ void ieee80211_ba_session_work(struct work_struct *work)
 				       sta->ampdu_mlme.tid_rx_manage_offl))
 			__ieee80211_start_rx_ba_session(sta, 0, 0, 0, 1, tid,
 							IEEE80211_MAX_AMPDU_BUF,
-							false, true);
+							false, true, true);
 
 		if (test_and_clear_bit(tid + IEEE80211_NUM_TIDS,
 				       sta->ampdu_mlme.tid_rx_manage_offl))
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index 2197c62a0a6e..5d494ac65853 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -1759,7 +1759,8 @@ void __ieee80211_stop_rx_ba_session(struct sta_info *sta, u16 tid,
 void __ieee80211_start_rx_ba_session(struct sta_info *sta,
 				     u8 dialog_token, u16 timeout,
 				     u16 start_seq_num, u16 ba_policy, u16 tid,
-				     u16 buf_size, bool tx, bool auto_seq);
+				     u16 buf_size, bool tx, bool auto_seq,
+				     bool ampdu_mlme_lock_held);
 void ieee80211_sta_tear_down_BA_sessions(struct sta_info *sta,
 					 enum ieee80211_agg_stop_reason reason);
 void ieee80211_process_delba(struct ieee80211_sub_if_data *sdata,

-- 
Stefano
