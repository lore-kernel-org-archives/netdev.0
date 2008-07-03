From: David Miller <davem@davemloft.net>
Subject: [PATCH 16/39]: mac80211: Decrease number of explicit ->tx_queue
 references.
Date: Thu, 03 Jul 2008 00:03:58 -0700 (PDT)
Message-ID: <20080703.000358.13934940.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vinay@linux.vnet.ibm.com, krkumar2@in.ibm.com, mchan@broadcom.com,
	Matheos.Worku@Sun.COM, linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47556
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757592AbYGCHD7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 03:03:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Accomplish this by using local variables.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/mac80211/main.c |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index 81fe145..b00bb73 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -570,6 +570,7 @@ static int ieee80211_stop(struct net_device *dev)
 int ieee80211_start_tx_ba_session(struct ieee80211_hw *hw, u8 *ra, u16 tid)
 {
 	struct ieee80211_local *local = hw_to_local(hw);
+	struct netdev_queue *dev_queue;
 	struct sta_info *sta;
 	struct ieee80211_sub_if_data *sdata;
 	u16 start_seq_num = 0;
@@ -632,7 +633,8 @@ int ieee80211_start_tx_ba_session(struct ieee80211_hw *hw, u8 *ra, u16 tid)
 
 	/* ensure that TX flow won't interrupt us
 	 * until the end of the call to requeue function */
-	spin_lock_bh(&local->mdev->tx_queue.lock);
+	dev_queue = &local->mdev->tx_queue;
+	spin_lock_bh(&dev_queue->lock);
 
 	/* create a new queue for this aggregation */
 	ret = ieee80211_ht_agg_queue_add(local, sta, tid);
@@ -671,7 +673,7 @@ int ieee80211_start_tx_ba_session(struct ieee80211_hw *hw, u8 *ra, u16 tid)
 
 	/* Will put all the packets in the new SW queue */
 	ieee80211_requeue(local, ieee802_1d_to_ac[tid]);
-	spin_unlock_bh(&local->mdev->tx_queue.lock);
+	spin_unlock_bh(&dev_queue->lock);
 	spin_unlock_bh(&sta->lock);
 
 	/* send an addBA request */
@@ -695,7 +697,7 @@ int ieee80211_start_tx_ba_session(struct ieee80211_hw *hw, u8 *ra, u16 tid)
 err_unlock_queue:
 	kfree(sta->ampdu_mlme.tid_tx[tid]);
 	sta->ampdu_mlme.tid_tx[tid] = NULL;
-	spin_unlock_bh(&local->mdev->tx_queue.lock);
+	spin_unlock_bh(&dev_queue->lock);
 	ret = -EBUSY;
 err_unlock_sta:
 	spin_unlock_bh(&sta->lock);
@@ -812,6 +814,7 @@ EXPORT_SYMBOL(ieee80211_start_tx_ba_cb);
 void ieee80211_stop_tx_ba_cb(struct ieee80211_hw *hw, u8 *ra, u8 tid)
 {
 	struct ieee80211_local *local = hw_to_local(hw);
+	struct netdev_queue *dev_queue;
 	struct sta_info *sta;
 	u8 *state;
 	int agg_queue;
@@ -855,10 +858,11 @@ void ieee80211_stop_tx_ba_cb(struct ieee80211_hw *hw, u8 *ra, u8 tid)
 
 	/* avoid ordering issues: we are the only one that can modify
 	 * the content of the qdiscs */
-	spin_lock_bh(&local->mdev->tx_queue.lock);
+	dev_queue = &local->mdev->tx_queue;
+	spin_lock_bh(&dev_queue->lock);
 	/* remove the queue for this aggregation */
 	ieee80211_ht_agg_queue_remove(local, sta, tid, 1);
-	spin_unlock_bh(&local->mdev->tx_queue.lock);
+	spin_unlock_bh(&dev_queue->lock);
 
 	/* we just requeued the all the frames that were in the removed
 	 * queue, and since we might miss a softirq we do netif_schedule.
-- 
1.5.6

