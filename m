From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2009-11-23
Date: Mon, 23 Nov 2009 16:42:52 -0500
Message-ID: <20091123214251.GB9045@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757335AbZKWWAh@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

Here are a few more fixes intended for 2.6.32.  They are small and
self-contained and mostly speak for themselves.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit 70e3bb504ccfe6ba725ab120bdb516d205d834f9:
  Divy Le Ray (1):
        cxgb3: fix premature page unmap

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Johannes Berg (3):
      mac80211: fix addba timer (again...)
      mac80211: fix resume
      rfkill: fix miscdev ops

John W. Linville (1):
      ath9k: set ps_default as false

 drivers/net/wireless/ath/ath9k/main.c |    2 ++
 net/mac80211/agg-tx.c                 |   18 ++++++++----------
 net/mac80211/ieee80211_i.h            |    8 ++++++++
 net/mac80211/util.c                   |   19 +++++++++----------
 net/rfkill/core.c                     |    1 +
 5 files changed, 28 insertions(+), 20 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/ath/ath9k/main.c
index 52bed89..43d2be9 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -1555,6 +1555,8 @@ void ath_set_hw_capab(struct ath_softc *sc, struct ieee80211_hw *hw)
 		BIT(NL80211_IFTYPE_ADHOC) |
 		BIT(NL80211_IFTYPE_MESH_POINT);
 
+	hw->wiphy->ps_default = false;
+
 	hw->queues = 4;
 	hw->max_rates = 4;
 	hw->channel_change_time = 5000;
diff --git a/net/mac80211/agg-tx.c b/net/mac80211/agg-tx.c
index b09948c..206fd82 100644
--- a/net/mac80211/agg-tx.c
+++ b/net/mac80211/agg-tx.c
@@ -173,12 +173,14 @@ static void sta_addba_resp_timer_expired(unsigned long data)
 
 	/* check if the TID waits for addBA response */
 	spin_lock_bh(&sta->lock);
-	if (!(*state & HT_ADDBA_REQUESTED_MSK)) {
+	if ((*state & (HT_ADDBA_REQUESTED_MSK | HT_ADDBA_RECEIVED_MSK)) !=
+						HT_ADDBA_REQUESTED_MSK) {
 		spin_unlock_bh(&sta->lock);
 		*state = HT_AGG_STATE_IDLE;
 #ifdef CONFIG_MAC80211_HT_DEBUG
 		printk(KERN_DEBUG "timer expired on tid %d but we are not "
-				"expecting addBA response there", tid);
+				"(or no longer) expecting addBA response there",
+			tid);
 #endif
 		return;
 	}
@@ -666,21 +668,21 @@ void ieee80211_process_addba_resp(struct ieee80211_local *local,
 
 	state = &sta->ampdu_mlme.tid_state_tx[tid];
 
-	del_timer_sync(&sta->ampdu_mlme.tid_tx[tid]->addba_resp_timer);
-
 	spin_lock_bh(&sta->lock);
 
 	if (!(*state & HT_ADDBA_REQUESTED_MSK))
-		goto timer_still_needed;
+		goto out;
 
 	if (mgmt->u.action.u.addba_resp.dialog_token !=
 		sta->ampdu_mlme.tid_tx[tid]->dialog_token) {
 #ifdef CONFIG_MAC80211_HT_DEBUG
 		printk(KERN_DEBUG "wrong addBA response token, tid %d\n", tid);
 #endif /* CONFIG_MAC80211_HT_DEBUG */
-		goto timer_still_needed;
+		goto out;
 	}
 
+	del_timer(&sta->ampdu_mlme.tid_tx[tid]->addba_resp_timer);
+
 #ifdef CONFIG_MAC80211_HT_DEBUG
 	printk(KERN_DEBUG "switched off addBA timer for tid %d \n", tid);
 #endif /* CONFIG_MAC80211_HT_DEBUG */
@@ -699,10 +701,6 @@ void ieee80211_process_addba_resp(struct ieee80211_local *local,
 		___ieee80211_stop_tx_ba_session(sta, tid, WLAN_BACK_INITIATOR);
 	}
 
-	goto out;
-
- timer_still_needed:
-	add_timer(&sta->ampdu_mlme.tid_tx[tid]->addba_resp_timer);
  out:
 	spin_unlock_bh(&sta->lock);
 }
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index 588005c..a910bf1 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -662,6 +662,14 @@ struct ieee80211_local {
 	bool suspended;
 
 	/*
+	 * Resuming is true while suspended, but when we're reprogramming the
+	 * hardware -- at that time it's allowed to use ieee80211_queue_work()
+	 * again even though some other parts of the stack are still suspended
+	 * and we still drop received frames to avoid waking the stack.
+	 */
+	bool resuming;
+
+	/*
 	 * quiescing is true during the suspend process _only_ to
 	 * ease timer cancelling etc.
 	 */
diff --git a/net/mac80211/util.c b/net/mac80211/util.c
index aeb65b3..e6c08da 100644
--- a/net/mac80211/util.c
+++ b/net/mac80211/util.c
@@ -520,9 +520,9 @@ EXPORT_SYMBOL_GPL(ieee80211_iterate_active_interfaces_atomic);
  */
 static bool ieee80211_can_queue_work(struct ieee80211_local *local)
 {
-        if (WARN(local->suspended, "queueing ieee80211 work while "
-		 "going to suspend\n"))
-                return false;
+	if (WARN(local->suspended && !local->resuming,
+		 "queueing ieee80211 work while going to suspend\n"))
+		return false;
 
 	return true;
 }
@@ -1025,13 +1025,9 @@ int ieee80211_reconfig(struct ieee80211_local *local)
 	struct sta_info *sta;
 	unsigned long flags;
 	int res;
-	bool from_suspend = local->suspended;
 
-	/*
-	 * We're going to start the hardware, at that point
-	 * we are no longer suspended and can RX frames.
-	 */
-	local->suspended = false;
+	if (local->suspended)
+		local->resuming = true;
 
 	/* restart hardware */
 	if (local->open_count) {
@@ -1129,11 +1125,14 @@ int ieee80211_reconfig(struct ieee80211_local *local)
 	 * If this is for hw restart things are still running.
 	 * We may want to change that later, however.
 	 */
-	if (!from_suspend)
+	if (!local->suspended)
 		return 0;
 
 #ifdef CONFIG_PM
+	/* first set suspended false, then resuming */
 	local->suspended = false;
+	mb();
+	local->resuming = false;
 
 	list_for_each_entry(sdata, &local->interfaces, list) {
 		switch(sdata->vif.type) {
diff --git a/net/rfkill/core.c b/net/rfkill/core.c
index dbeaf29..7cb57ff 100644
--- a/net/rfkill/core.c
+++ b/net/rfkill/core.c
@@ -1188,6 +1188,7 @@ static long rfkill_fop_ioctl(struct file *file, unsigned int cmd,
 #endif
 
 static const struct file_operations rfkill_fops = {
+	.owner		= THIS_MODULE,
 	.open		= rfkill_fop_open,
 	.read		= rfkill_fop_read,
 	.write		= rfkill_fop_write,
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
