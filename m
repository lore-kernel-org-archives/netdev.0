From: Ville Syrjala <ville.syrjala@linux.intel.com>
Subject: [PATCH v2 1/2] mac80211: Add rcu read side critical sections
Date: Wed, 20 Sep 2017 13:11:23 +0300
Message-ID: <20170920101123.23312-1-ville.syrjala@linux.intel.com>
References: <20170918195919.15860-1-ville.syrjala@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        =?UTF-8?q?Ville=20Syrj=C3=A4l=C3=A4?=
        <ville.syrjala@linux.intel.com>
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:58398 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751468AbdITKL1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 20 Sep 2017 06:11:27 -0400
In-Reply-To: <20170918195919.15860-1-ville.syrjala@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ville Syrjälä <ville.syrjala@linux.intel.com>

I got the following lockdep warning about the rcu_dereference()s in
ieee80211_tx_h_select_key(). After tracing all callers of
ieee80211_tx_h_select_key() I discovered that ieee80211_get_buffered_bc()
and ieee80211_build_data_template() had the rcu_read_lock/unlock() but
three other places did not. So I just blindly added them and made the
read side critical section extend as far as the lifetime of 'tx' which
is where we seem to be stuffing the rcu protected pointers. No real clue
whether this is correct or not.

[  854.573700] ../net/mac80211/tx.c:594 suspicious rcu_dereference_check() usage!
[  854.573704]
               other info that might help us debug this:

[  854.573707]
               rcu_scheduler_active = 2, debug_locks = 1
[  854.573712] 6 locks held by kworker/u2:0/2877:
[  854.573715]  #0:  ("%s"wiphy_name(local->hw.wiphy)){++++.+}, at: [<c1067f37>] process_one_work+0x127/0x580
[  854.573742]  #1:  ((&sdata->work)){+.+.+.}, at: [<c1067f37>] process_one_work+0x127/0x580
[  854.573758]  #2:  (&wdev->mtx){+.+.+.}, at: [<f83271c3>] ieee80211_sta_work+0x23/0x1c70 [mac80211]
[  854.573902]  #3:  (&local->sta_mtx){+.+.+.}, at: [<f82c9b10>] __sta_info_flush+0x60/0x160 [mac80211]
[  854.573947]  #4:  (&(&txq->axq_lock)->rlock){+.-...}, at: [<f825729c>] ath_tx_node_cleanup+0x5c/0x180 [ath9k]
[  854.573973]  #5:  (&(&fq->lock)->rlock){+.-...}, at: [<f82fb064>] ieee80211_tx_dequeue+0x24/0xa80 [mac80211]
[  854.574023]
               stack backtrace:
[  854.574028] CPU: 0 PID: 2877 Comm: kworker/u2:0 Not tainted 4.13.0-mgm-ovl+ #52
[  854.574032] Hardware name: FUJITSU SIEMENS LIFEBOOK S6120/FJNB16C, BIOS Version 1.26  05/10/2004
[  854.574070] Workqueue: phy0 ieee80211_iface_work [mac80211]
[  854.574076] Call Trace:
[  854.574086]  dump_stack+0x16/0x19
[  854.574092]  lockdep_rcu_suspicious+0xcb/0xf0
[  854.574131]  ieee80211_tx_h_select_key+0x1b5/0x500 [mac80211]
[  854.574171]  ieee80211_tx_dequeue+0x283/0xa80 [mac80211]
[  854.574181]  ath_tid_dequeue+0x84/0xf0 [ath9k]
[  854.574189]  ath_tx_node_cleanup+0xb8/0x180 [ath9k]
[  854.574199]  ath9k_sta_state+0x48/0xf0 [ath9k]
[  854.574207]  ? ath9k_del_ps_key.isra.19+0x60/0x60 [ath9k]
[  854.574240]  drv_sta_state+0xaf/0x8c0 [mac80211]
[  854.574275]  __sta_info_destroy_part2+0x10b/0x140 [mac80211]
[  854.574309]  __sta_info_flush+0xd5/0x160 [mac80211]
[  854.574349]  ieee80211_set_disassoc+0xd3/0x570 [mac80211]
[  854.574390]  ieee80211_sta_connection_lost+0x30/0x60 [mac80211]
[  854.574431]  ieee80211_sta_work+0x1ff/0x1c70 [mac80211]
[  854.574436]  ? mark_held_locks+0x62/0x90
[  854.574443]  ? _raw_spin_unlock_irqrestore+0x55/0x70
[  854.574447]  ? trace_hardirqs_on_caller+0x11c/0x1a0
[  854.574452]  ? trace_hardirqs_on+0xb/0x10
[  854.574459]  ? dev_mc_net_exit+0xe/0x20
[  854.574467]  ? skb_dequeue+0x48/0x70
[  854.574504]  ieee80211_iface_work+0x2d8/0x320 [mac80211]
[  854.574509]  process_one_work+0x1d1/0x580
[  854.574513]  ? process_one_work+0x127/0x580
[  854.574519]  worker_thread+0x31/0x380
[  854.574525]  kthread+0xd9/0x110
[  854.574529]  ? process_one_work+0x580/0x580
[  854.574534]  ? kthread_create_on_node+0x30/0x30
[  854.574540]  ret_from_fork+0x19/0x24

[  854.574548] =============================
[  854.574551] WARNING: suspicious RCU usage
[  854.574555] 4.13.0-mgm-ovl+ #52 Not tainted
[  854.574558] -----------------------------
[  854.574561] ../net/mac80211/tx.c:608 suspicious rcu_dereference_check() usage!
[  854.574564]
               other info that might help us debug this:

[  854.574568]
               rcu_scheduler_active = 2, debug_locks = 1
[  854.574572] 6 locks held by kworker/u2:0/2877:
[  854.574574]  #0:  ("%s"wiphy_name(local->hw.wiphy)){++++.+}, at: [<c1067f37>] process_one_work+0x127/0x580
[  854.574590]  #1:  ((&sdata->work)){+.+.+.}, at: [<c1067f37>] process_one_work+0x127/0x580
[  854.574606]  #2:  (&wdev->mtx){+.+.+.}, at: [<f83271c3>] ieee80211_sta_work+0x23/0x1c70 [mac80211]
[  854.574657]  #3:  (&local->sta_mtx){+.+.+.}, at: [<f82c9b10>] __sta_info_flush+0x60/0x160 [mac80211]
[  854.574702]  #4:  (&(&txq->axq_lock)->rlock){+.-...}, at: [<f825729c>] ath_tx_node_cleanup+0x5c/0x180 [ath9k]
[  854.574721]  #5:  (&(&fq->lock)->rlock){+.-...}, at: [<f82fb064>] ieee80211_tx_dequeue+0x24/0xa80 [mac80211]
[  854.574771]
               stack backtrace:
[  854.574775] CPU: 0 PID: 2877 Comm: kworker/u2:0 Not tainted 4.13.0-mgm-ovl+ #52
[  854.574779] Hardware name: FUJITSU SIEMENS LIFEBOOK S6120/FJNB16C, BIOS Version 1.26  05/10/2004
[  854.574814] Workqueue: phy0 ieee80211_iface_work [mac80211]
[  854.574821] Call Trace:
[  854.574825]  dump_stack+0x16/0x19
[  854.574830]  lockdep_rcu_suspicious+0xcb/0xf0
[  854.574869]  ieee80211_tx_h_select_key+0x44e/0x500 [mac80211]
[  854.574908]  ieee80211_tx_dequeue+0x283/0xa80 [mac80211]
[  854.574919]  ath_tid_dequeue+0x84/0xf0 [ath9k]
[  854.574927]  ath_tx_node_cleanup+0xb8/0x180 [ath9k]
[  854.574936]  ath9k_sta_state+0x48/0xf0 [ath9k]
[  854.574945]  ? ath9k_del_ps_key.isra.19+0x60/0x60 [ath9k]
[  854.574978]  drv_sta_state+0xaf/0x8c0 [mac80211]
[  854.575012]  __sta_info_destroy_part2+0x10b/0x140 [mac80211]
[  854.575046]  __sta_info_flush+0xd5/0x160 [mac80211]
[  854.575087]  ieee80211_set_disassoc+0xd3/0x570 [mac80211]
[  854.575127]  ieee80211_sta_connection_lost+0x30/0x60 [mac80211]
[  854.575168]  ieee80211_sta_work+0x1ff/0x1c70 [mac80211]
[  854.575173]  ? mark_held_locks+0x62/0x90
[  854.575178]  ? _raw_spin_unlock_irqrestore+0x55/0x70
[  854.575182]  ? trace_hardirqs_on_caller+0x11c/0x1a0
[  854.575187]  ? trace_hardirqs_on+0xb/0x10
[  854.575192]  ? dev_mc_net_exit+0xe/0x20
[  854.575197]  ? skb_dequeue+0x48/0x70
[  854.575233]  ieee80211_iface_work+0x2d8/0x320 [mac80211]
[  854.575238]  process_one_work+0x1d1/0x580
[  854.575243]  ? process_one_work+0x127/0x580
[  854.575248]  worker_thread+0x31/0x380
[  854.575253]  kthread+0xd9/0x110
[  854.575257]  ? process_one_work+0x580/0x580
[  854.575262]  ? kthread_create_on_node+0x30/0x30
[  854.575267]  ret_from_fork+0x19/0x24

v2: Callers of ieee80211_tx() already have the
    rcu_read_lock/unlock()
    Move the rcu critical section inside the spinlock in
    ieee80211_tx_dequeue() (Johannes Berg)

Cc: Johannes Berg <johannes@sipsolutions.net>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Signed-off-by: Ville Syrjälä <ville.syrjala@linux.intel.com>
---
 net/mac80211/tx.c | 17 +++++++++++++++--
 1 file changed, 15 insertions(+), 2 deletions(-)

diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index 94826680cf2b..fc4d8294d664 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -1770,15 +1770,21 @@ bool ieee80211_tx_prepare_skb(struct ieee80211_hw *hw,
 	struct ieee80211_tx_data tx;
 	struct sk_buff *skb2;
 
-	if (ieee80211_tx_prepare(sdata, &tx, NULL, skb) == TX_DROP)
+	rcu_read_lock();
+
+	if (ieee80211_tx_prepare(sdata, &tx, NULL, skb) == TX_DROP) {
+		rcu_read_unlock();
 		return false;
+	}
 
 	info->band = band;
 	info->control.vif = vif;
 	info->hw_queue = vif->hw_queue[skb_get_queue_mapping(skb)];
 
-	if (invoke_tx_handlers(&tx))
+	if (invoke_tx_handlers(&tx)) {
+		rcu_read_unlock();
 		return false;
+	}
 
 	if (sta) {
 		if (tx.sta)
@@ -1792,9 +1798,12 @@ bool ieee80211_tx_prepare_skb(struct ieee80211_hw *hw,
 	if (WARN_ON(skb2 != skb || !skb_queue_empty(&tx.skbs))) {
 		ieee80211_free_txskb(hw, skb2);
 		ieee80211_purge_tx_queue(hw, &tx.skbs);
+		rcu_read_unlock();
 		return false;
 	}
 
+	rcu_read_unlock();
+
 	return true;
 }
 EXPORT_SYMBOL(ieee80211_tx_prepare_skb);
@@ -3413,6 +3422,8 @@ struct sk_buff *ieee80211_tx_dequeue(struct ieee80211_hw *hw,
 
 	spin_lock_bh(&fq->lock);
 
+	rcu_read_lock();
+
 	if (test_bit(IEEE80211_TXQ_STOP, &txqi->flags))
 		goto out;
 
@@ -3511,6 +3522,8 @@ struct sk_buff *ieee80211_tx_dequeue(struct ieee80211_hw *hw,
 
 	IEEE80211_SKB_CB(skb)->control.vif = vif;
 out:
+	rcu_read_unlock();
+
 	spin_unlock_bh(&fq->lock);
 
 	return skb;
-- 
2.13.5
