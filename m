From: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: [PATCH] drivers/wireless: iwlwifi/mvm: Convert timers to use
 timer_setup()
Date: Tue, 24 Oct 2017 02:29:37 -0700
Message-ID: <20171024092937.GA47262@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Emmanuel Grumbach <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Luca Coelho <luciano.coelho-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Intel Linux Wireless <linuxwifi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Sara Sharon <sara.sharon-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

The RCU lifetime on baid_data is unclear, so this adds a direct copy of the
rcu_ptr passed to the original callback. It may be possible to improve this
to just use baid_data->mvm->baid_map[baid_data->baid] instead.

Cc: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: Emmanuel Grumbach <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: Luca Coelho <luciano.coelho-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: Intel Linux Wireless <linuxwifi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Cc: Sara Sharon <sara.sharon-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
---
 drivers/net/wireless/intel/iwlwifi/mvm/mvm.h  |  3 ++-
 drivers/net/wireless/intel/iwlwifi/mvm/rxmq.c |  4 ++--
 drivers/net/wireless/intel/iwlwifi/mvm/sta.c  | 18 +++++++++---------
 3 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/drivers/net/wireless/intel/iwlwifi/mvm/mvm.h b/drivers/net/wireless/intel/iwlwifi/mvm/mvm.h
index bf25c3ce7c95..a22c0ecff324 100644
--- a/drivers/net/wireless/intel/iwlwifi/mvm/mvm.h
+++ b/drivers/net/wireless/intel/iwlwifi/mvm/mvm.h
@@ -636,6 +636,7 @@ struct iwl_mvm_baid_data {
 	u16 timeout;
 	unsigned long last_rx;
 	struct timer_list session_timer;
+	struct iwl_mvm_baid_data __rcu **rcu_ptr;
 	struct iwl_mvm *mvm;
 	struct iwl_mvm_reorder_buffer reorder_buf[];
 };
@@ -1829,7 +1830,7 @@ void iwl_mvm_tdls_ch_switch_work(struct work_struct *work);
 void iwl_mvm_sync_rx_queues_internal(struct iwl_mvm *mvm,
 				     struct iwl_mvm_internal_rxq_notif *notif,
 				     u32 size);
-void iwl_mvm_reorder_timer_expired(unsigned long data);
+void iwl_mvm_reorder_timer_expired(struct timer_list *t);
 struct ieee80211_vif *iwl_mvm_get_bss_vif(struct iwl_mvm *mvm);
 bool iwl_mvm_is_vif_assoc(struct iwl_mvm *mvm);
 
diff --git a/drivers/net/wireless/intel/iwlwifi/mvm/rxmq.c b/drivers/net/wireless/intel/iwlwifi/mvm/rxmq.c
index 5e679859f948..53485dc096b3 100644
--- a/drivers/net/wireless/intel/iwlwifi/mvm/rxmq.c
+++ b/drivers/net/wireless/intel/iwlwifi/mvm/rxmq.c
@@ -456,9 +456,9 @@ static void iwl_mvm_release_frames(struct iwl_mvm *mvm,
 	}
 }
 
-void iwl_mvm_reorder_timer_expired(unsigned long data)
+void iwl_mvm_reorder_timer_expired(struct timer_list *t)
 {
-	struct iwl_mvm_reorder_buffer *buf = (void *)data;
+	struct iwl_mvm_reorder_buffer *buf = from_timer(buf, t, reorder_timer);
 	int i;
 	u16 sn = 0, index = 0;
 	bool expired = false;
diff --git a/drivers/net/wireless/intel/iwlwifi/mvm/sta.c b/drivers/net/wireless/intel/iwlwifi/mvm/sta.c
index 282424f40c43..b95b24a03959 100644
--- a/drivers/net/wireless/intel/iwlwifi/mvm/sta.c
+++ b/drivers/net/wireless/intel/iwlwifi/mvm/sta.c
@@ -252,9 +252,11 @@ int iwl_mvm_sta_send_to_fw(struct iwl_mvm *mvm, struct ieee80211_sta *sta,
 	return ret;
 }
 
-static void iwl_mvm_rx_agg_session_expired(unsigned long data)
+static void iwl_mvm_rx_agg_session_expired(struct timer_list *t)
 {
-	struct iwl_mvm_baid_data __rcu **rcu_ptr = (void *)data;
+	struct iwl_mvm_baid_data *data =
+		from_timer(data, t, session_timer);
+	struct iwl_mvm_baid_data __rcu **rcu_ptr = data->rcu_ptr;
 	struct iwl_mvm_baid_data *ba_data;
 	struct ieee80211_sta *sta;
 	struct iwl_mvm_sta *mvm_sta;
@@ -2150,10 +2152,8 @@ static void iwl_mvm_init_reorder_buffer(struct iwl_mvm *mvm,
 		reorder_buf->head_sn = ssn;
 		reorder_buf->buf_size = buf_size;
 		/* rx reorder timer */
-		reorder_buf->reorder_timer.function =
-			iwl_mvm_reorder_timer_expired;
-		reorder_buf->reorder_timer.data = (unsigned long)reorder_buf;
-		init_timer(&reorder_buf->reorder_timer);
+		timer_setup(&reorder_buf->reorder_timer,
+			    iwl_mvm_reorder_timer_expired, 0);
 		spin_lock_init(&reorder_buf->lock);
 		reorder_buf->mvm = mvm;
 		reorder_buf->queue = i;
@@ -2250,9 +2250,9 @@ int iwl_mvm_sta_rx_agg(struct iwl_mvm *mvm, struct ieee80211_sta *sta,
 		baid_data->baid = baid;
 		baid_data->timeout = timeout;
 		baid_data->last_rx = jiffies;
-		setup_timer(&baid_data->session_timer,
-			    iwl_mvm_rx_agg_session_expired,
-			    (unsigned long)&mvm->baid_map[baid]);
+		baid_data->rcu_ptr = &mvm->baid_map[baid];
+		timer_setup(&baid_data->session_timer,
+			    iwl_mvm_rx_agg_session_expired, 0);
 		baid_data->mvm = mvm;
 		baid_data->tid = tid;
 		baid_data->sta_id = mvm_sta->sta_id;
-- 
2.7.4


-- 
Kees Cook
Pixel Security
