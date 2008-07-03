From: David Miller <davem@davemloft.net>
Subject: [PATCH 31/39]: mac80211: Fix queue locking in
 ieee80211_start_tx_ba_session
Date: Thu, 03 Jul 2008 00:05:16 -0700 (PDT)
Message-ID: <20080703.000516.85569698.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vinay@linux.vnet.ibm.com, krkumar2@in.ibm.com, mchan@broadcom.com,
	Matheos.Worku@Sun.COM, linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50702
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755494AbYGCHFR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 03:05:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


What this code wants to do is completely block out transmit
queue handling on all queues while it does the most critical
work.

So that's what we make it do.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/mac80211/main.c |   32 +++++++++++++++++++++++++++-----
 1 files changed, 27 insertions(+), 5 deletions(-)

diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index 45b992a..c4d36fe 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -567,10 +567,33 @@ static int ieee80211_stop(struct net_device *dev)
 	return 0;
 }
 
+static void lock_all_queues_bh(struct net_device *dev)
+{
+	unsigned int i;
+
+	local_bh_disable();
+	for (i = 0; i < dev->num_tx_queues; i++) {
+		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
+
+		spin_lock(&txq->lock);
+	}
+}
+
+static void unlock_all_queues_bh(struct net_device *dev)
+{
+	unsigned int i;
+
+	for (i = 0; i < dev->num_tx_queues; i++) {
+		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
+
+		spin_unlock(&txq->lock);
+	}
+	local_bh_enable();
+}
+
 int ieee80211_start_tx_ba_session(struct ieee80211_hw *hw, u8 *ra, u16 tid)
 {
 	struct ieee80211_local *local = hw_to_local(hw);
-	struct netdev_queue *dev_queue;
 	struct sta_info *sta;
 	struct ieee80211_sub_if_data *sdata;
 	u16 start_seq_num = 0;
@@ -633,8 +656,7 @@ int ieee80211_start_tx_ba_session(struct ieee80211_hw *hw, u8 *ra, u16 tid)
 
 	/* ensure that TX flow won't interrupt us
 	 * until the end of the call to requeue function */
-	dev_queue = netdev_get_tx_queue(local->mdev, 0);
-	spin_lock_bh(&dev_queue->lock);
+	lock_all_queues_bh(local->mdev);
 
 	/* create a new queue for this aggregation */
 	ret = ieee80211_ht_agg_queue_add(local, sta, tid);
@@ -673,7 +695,7 @@ int ieee80211_start_tx_ba_session(struct ieee80211_hw *hw, u8 *ra, u16 tid)
 
 	/* Will put all the packets in the new SW queue */
 	ieee80211_requeue(local, ieee802_1d_to_ac[tid]);
-	spin_unlock_bh(&dev_queue->lock);
+	unlock_all_queues_bh(local->mdev);
 	spin_unlock_bh(&sta->lock);
 
 	/* send an addBA request */
@@ -697,7 +719,7 @@ int ieee80211_start_tx_ba_session(struct ieee80211_hw *hw, u8 *ra, u16 tid)
 err_unlock_queue:
 	kfree(sta->ampdu_mlme.tid_tx[tid]);
 	sta->ampdu_mlme.tid_tx[tid] = NULL;
-	spin_unlock_bh(&dev_queue->lock);
+	unlock_all_queues_bh(local->mdev);
 	ret = -EBUSY;
 err_unlock_sta:
 	spin_unlock_bh(&sta->lock);
-- 
1.5.6

