From: David Miller <davem@davemloft.net>
Subject: [PATCH 9/13]: mac80211: Reimplement WME using ->select_queue().
Date: Thu, 10 Jul 2008 03:57:06 -0700 (PDT)
Message-ID: <20080710.035706.65804826.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60723
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754157AbYGJK5G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 06:57:06 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 7237BC8C17F
	for <netdev@vger.kernel.org>; Thu, 10 Jul 2008 03:57:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The only behavior change is that we do not drop packets under any
circumstances.  If that is absolutely needed, we could easily add it
back.

With cleanups and help from Johannes Berg.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/mac80211.h     |    8 -
 net/mac80211/Kconfig       |   11 -
 net/mac80211/Makefile      |    2 +-
 net/mac80211/ieee80211_i.h |   15 +-
 net/mac80211/main.c        |   61 ++----
 net/mac80211/util.c        |   14 +-
 net/mac80211/wme.c         |  602 ++++++++------------------------------------
 net/mac80211/wme.h         |   35 +---
 8 files changed, 124 insertions(+), 624 deletions(-)

diff --git a/include/net/mac80211.h b/include/net/mac80211.h
index 656442c..37cdc0b 100644
--- a/include/net/mac80211.h
+++ b/include/net/mac80211.h
@@ -837,20 +837,12 @@ static inline void SET_IEEE80211_PERM_ADDR(struct ieee80211_hw *hw, u8 *addr)
 
 static inline int ieee80211_num_regular_queues(struct ieee80211_hw *hw)
 {
-#ifdef CONFIG_MAC80211_QOS
 	return hw->queues;
-#else
-	return 1;
-#endif
 }
 
 static inline int ieee80211_num_queues(struct ieee80211_hw *hw)
 {
-#ifdef CONFIG_MAC80211_QOS
 	return hw->queues + hw->ampdu_queues;
-#else
-	return 1;
-#endif
 }
 
 static inline struct ieee80211_rate *
diff --git a/net/mac80211/Kconfig b/net/mac80211/Kconfig
index 10579de..80d6933 100644
--- a/net/mac80211/Kconfig
+++ b/net/mac80211/Kconfig
@@ -11,17 +11,6 @@ config MAC80211
 	  This option enables the hardware independent IEEE 802.11
 	  networking stack.
 
-config MAC80211_QOS
-	def_bool y
-	depends on MAC80211
-	depends on NET_SCHED
-	depends on BROKEN
-
-comment "QoS/HT support disabled"
-	depends on MAC80211 && !MAC80211_QOS
-comment "QoS/HT support needs CONFIG_NET_SCHED"
-	depends on MAC80211 && !NET_SCHED
-
 menu "Rate control algorithm selection"
 	depends on MAC80211 != n
 
diff --git a/net/mac80211/Makefile b/net/mac80211/Makefile
index fa47438..a169b02 100644
--- a/net/mac80211/Makefile
+++ b/net/mac80211/Makefile
@@ -18,10 +18,10 @@ mac80211-y := \
 	tx.o \
 	key.o \
 	util.o \
+	wme.o \
 	event.o
 
 mac80211-$(CONFIG_MAC80211_LEDS) += led.o
-mac80211-$(CONFIG_MAC80211_QOS) += wme.o
 mac80211-$(CONFIG_MAC80211_DEBUGFS) += \
 	debugfs.o \
 	debugfs_sta.o \
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index 02a8753..63e0607 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -25,6 +25,7 @@
 #include <linux/etherdevice.h>
 #include <net/wireless.h>
 #include <net/iw_handler.h>
+#include <net/mac80211.h>
 #include "key.h"
 #include "sta_info.h"
 
@@ -542,6 +543,9 @@ enum {
 	IEEE80211_ADDBA_MSG	= 4,
 };
 
+/* maximum number of hardware queues we support. */
+#define QD_MAX_QUEUES (IEEE80211_MAX_AMPDU_QUEUES + IEEE80211_MAX_QUEUES)
+
 struct ieee80211_local {
 	/* embed the driver visible part.
 	 * don't cast (use the static inlines below), but we keep
@@ -550,6 +554,8 @@ struct ieee80211_local {
 
 	const struct ieee80211_ops *ops;
 
+	unsigned long queue_pool[BITS_TO_LONGS(QD_MAX_QUEUES)];
+
 	struct net_device *mdev; /* wmaster# - "master" 802.11 device */
 	int open_count;
 	int monitors, cooked_mntrs;
@@ -751,15 +757,6 @@ struct ieee80211_local {
 #endif
 };
 
-static inline int ieee80211_is_multiqueue(struct ieee80211_local *local)
-{
-#ifdef CONFIG_MAC80211_QOS
-	return netif_is_multiqueue(local->mdev);
-#else
-	return 0;
-#endif
-}
-
 /* this struct represents 802.11n's RA/TID combination */
 struct ieee80211_ra_tid {
 	u8 ra[ETH_ALEN];
diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index 19cd94e..d5729ae 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -114,7 +114,7 @@ static int ieee80211_master_open(struct net_device *dev)
 	if (res)
 		return res;
 
-	netif_start_queue(local->mdev);
+	netif_tx_start_all_queues(local->mdev);
 
 	return 0;
 }
@@ -396,7 +396,7 @@ static int ieee80211_open(struct net_device *dev)
 		queue_work(local->hw.workqueue, &ifsta->work);
 	}
 
-	netif_start_queue(dev);
+	netif_tx_start_all_queues(dev);
 
 	return 0;
  err_del_interface:
@@ -417,7 +417,7 @@ static int ieee80211_stop(struct net_device *dev)
 	/*
 	 * Stop TX on this interface first.
 	 */
-	netif_stop_queue(dev);
+	netif_tx_stop_all_queues(dev);
 
 	/*
 	 * Now delete all active aggregation sessions.
@@ -570,7 +570,6 @@ static int ieee80211_stop(struct net_device *dev)
 int ieee80211_start_tx_ba_session(struct ieee80211_hw *hw, u8 *ra, u16 tid)
 {
 	struct ieee80211_local *local = hw_to_local(hw);
-	struct netdev_queue *txq;
 	struct sta_info *sta;
 	struct ieee80211_sub_if_data *sdata;
 	u16 start_seq_num = 0;
@@ -635,11 +634,6 @@ int ieee80211_start_tx_ba_session(struct ieee80211_hw *hw, u8 *ra, u16 tid)
 			(unsigned long)&sta->timer_to_tid[tid];
 	init_timer(&sta->ampdu_mlme.tid_tx[tid]->addba_resp_timer);
 
-	/* ensure that TX flow won't interrupt us
-	 * until the end of the call to requeue function */
-	txq = netdev_get_tx_queue(local->mdev, 0);
-	spin_lock_bh(&txq->lock);
-
 	/* create a new queue for this aggregation */
 	ret = ieee80211_ht_agg_queue_add(local, sta, tid);
 
@@ -666,7 +660,7 @@ int ieee80211_start_tx_ba_session(struct ieee80211_hw *hw, u8 *ra, u16 tid)
 		/* No need to requeue the packets in the agg queue, since we
 		 * held the tx lock: no packet could be enqueued to the newly
 		 * allocated queue */
-		 ieee80211_ht_agg_queue_remove(local, sta, tid, 0);
+		ieee80211_ht_agg_queue_remove(local, sta, tid, 0);
 #ifdef CONFIG_MAC80211_HT_DEBUG
 		printk(KERN_DEBUG "BA request denied - HW unavailable for"
 					" tid %d\n", tid);
@@ -677,7 +671,6 @@ int ieee80211_start_tx_ba_session(struct ieee80211_hw *hw, u8 *ra, u16 tid)
 
 	/* Will put all the packets in the new SW queue */
 	ieee80211_requeue(local, ieee802_1d_to_ac[tid]);
-	spin_unlock_bh(&txq->lock);
 	spin_unlock_bh(&sta->lock);
 
 	/* send an addBA request */
@@ -703,7 +696,6 @@ int ieee80211_start_tx_ba_session(struct ieee80211_hw *hw, u8 *ra, u16 tid)
 err_unlock_queue:
 	kfree(sta->ampdu_mlme.tid_tx[tid]);
 	sta->ampdu_mlme.tid_tx[tid] = NULL;
-	spin_unlock_bh(&txq->lock);
 	ret = -EBUSY;
 err_unlock_sta:
 	spin_unlock_bh(&sta->lock);
@@ -828,7 +820,6 @@ EXPORT_SYMBOL(ieee80211_start_tx_ba_cb);
 void ieee80211_stop_tx_ba_cb(struct ieee80211_hw *hw, u8 *ra, u8 tid)
 {
 	struct ieee80211_local *local = hw_to_local(hw);
-	struct netdev_queue *txq;
 	struct sta_info *sta;
 	u8 *state;
 	int agg_queue;
@@ -860,8 +851,9 @@ void ieee80211_stop_tx_ba_cb(struct ieee80211_hw *hw, u8 *ra, u8 tid)
 	state = &sta->ampdu_mlme.tid_state_tx[tid];
 
 	/* NOTE: no need to use sta->lock in this state check, as
-	 * ieee80211_stop_tx_ba_session will let only
-	 * one stop call to pass through per sta/tid */
+	 * ieee80211_stop_tx_ba_session will let only one stop call to
+	 * pass through per sta/tid
+	 */
 	if ((*state & HT_AGG_STATE_REQ_STOP_BA_MSK) == 0) {
 #ifdef CONFIG_MAC80211_HT_DEBUG
 		printk(KERN_DEBUG "unexpected callback to A-MPDU stop\n");
@@ -876,19 +868,14 @@ void ieee80211_stop_tx_ba_cb(struct ieee80211_hw *hw, u8 *ra, u8 tid)
 
 	agg_queue = sta->tid_to_tx_q[tid];
 
-	/* avoid ordering issues: we are the only one that can modify
-	 * the content of the qdiscs */
-	txq = netdev_get_tx_queue(local->mdev, 0);
-	spin_lock_bh(&txq->lock);
-	/* remove the queue for this aggregation */
 	ieee80211_ht_agg_queue_remove(local, sta, tid, 1);
-	spin_unlock_bh(&txq->lock);
 
-	/* we just requeued the all the frames that were in the removed
-	 * queue, and since we might miss a softirq we do netif_schedule_queue.
-	 * ieee80211_wake_queue is not used here as this queue is not
-	 * necessarily stopped */
-	netif_schedule_queue(txq);
+	/* We just requeued the all the frames that were in the
+	 * removed queue, and since we might miss a softirq we do
+	 * netif_schedule_queue.  ieee80211_wake_queue is not used
+	 * here as this queue is not necessarily stopped
+	 */
+	netif_schedule_queue(netdev_get_tx_queue(local->mdev, agg_queue));
 	spin_lock_bh(&sta->lock);
 	*state = HT_AGG_STATE_IDLE;
 	sta->ampdu_mlme.addba_req_num[tid] = 0;
@@ -1687,17 +1674,12 @@ int ieee80211_register_hw(struct ieee80211_hw *hw)
 	 * We use the number of queues for feature tests (QoS, HT) internally
 	 * so restrict them appropriately.
 	 */
-#ifdef CONFIG_MAC80211_QOS
 	if (hw->queues > IEEE80211_MAX_QUEUES)
 		hw->queues = IEEE80211_MAX_QUEUES;
 	if (hw->ampdu_queues > IEEE80211_MAX_AMPDU_QUEUES)
 		hw->ampdu_queues = IEEE80211_MAX_AMPDU_QUEUES;
 	if (hw->queues < 4)
 		hw->ampdu_queues = 0;
-#else
-	hw->queues = 1;
-	hw->ampdu_queues = 0;
-#endif
 
 	/* for now, mdev needs sub_if_data :/ */
 	mdev = alloc_netdev_mq(sizeof(struct ieee80211_sub_if_data),
@@ -1795,7 +1777,7 @@ int ieee80211_register_hw(struct ieee80211_hw *hw)
 		goto fail_wep;
 	}
 
-	ieee80211_install_qdisc(local->mdev);
+	local->mdev->select_queue = ieee80211_select_queue;
 
 	/* add one default STA interface */
 	result = ieee80211_if_add(local->mdev, "wlan%d", NULL,
@@ -1913,23 +1895,11 @@ static int __init ieee80211_init(void)
 
 	ret = rc80211_pid_init();
 	if (ret)
-		goto out;
-
-	ret = ieee80211_wme_register();
-	if (ret) {
-		printk(KERN_DEBUG "ieee80211_init: failed to "
-		       "initialize WME (err=%d)\n", ret);
-		goto out_cleanup_pid;
-	}
+		return ret;
 
 	ieee80211_debugfs_netdev_init();
 
 	return 0;
-
- out_cleanup_pid:
-	rc80211_pid_exit();
- out:
-	return ret;
 }
 
 static void __exit ieee80211_exit(void)
@@ -1945,7 +1915,6 @@ static void __exit ieee80211_exit(void)
 	if (mesh_allocated)
 		ieee80211s_stop();
 
-	ieee80211_wme_unregister();
 	ieee80211_debugfs_netdev_exit();
 }
 
diff --git a/net/mac80211/util.c b/net/mac80211/util.c
index ce62b16..fbc2af7 100644
--- a/net/mac80211/util.c
+++ b/net/mac80211/util.c
@@ -363,12 +363,7 @@ void ieee80211_wake_queue(struct ieee80211_hw *hw, int queue)
 	if (test_bit(queue, local->queues_pending)) {
 		tasklet_schedule(&local->tx_pending_tasklet);
 	} else {
-		if (ieee80211_is_multiqueue(local)) {
-			netif_wake_subqueue(local->mdev, queue);
-		} else {
-			WARN_ON(queue != 0);
-			netif_wake_queue(local->mdev);
-		}
+		netif_wake_subqueue(local->mdev, queue);
 	}
 }
 EXPORT_SYMBOL(ieee80211_wake_queue);
@@ -377,12 +372,7 @@ void ieee80211_stop_queue(struct ieee80211_hw *hw, int queue)
 {
 	struct ieee80211_local *local = hw_to_local(hw);
 
-	if (ieee80211_is_multiqueue(local)) {
-		netif_stop_subqueue(local->mdev, queue);
-	} else {
-		WARN_ON(queue != 0);
-		netif_stop_queue(local->mdev);
-	}
+	netif_stop_subqueue(local->mdev, queue);
 }
 EXPORT_SYMBOL(ieee80211_stop_queue);
 
diff --git a/net/mac80211/wme.c b/net/mac80211/wme.c
index f014cd3..b21cfec 100644
--- a/net/mac80211/wme.c
+++ b/net/mac80211/wme.c
@@ -18,67 +18,42 @@
 #include "ieee80211_i.h"
 #include "wme.h"
 
-/* maximum number of hardware queues we support. */
-#define QD_MAX_QUEUES (IEEE80211_MAX_AMPDU_QUEUES + IEEE80211_MAX_QUEUES)
-/* current number of hardware queues we support. */
-#define QD_NUM(hw) ((hw)->queues + (hw)->ampdu_queues)
-
-/*
- * Default mapping in classifier to work with default
+/* Default mapping in classifier to work with default
  * queue setup.
  */
 const int ieee802_1d_to_ac[8] = { 2, 3, 3, 2, 1, 1, 0, 0 };
 
-struct ieee80211_sched_data
-{
-	unsigned long qdisc_pool[BITS_TO_LONGS(QD_MAX_QUEUES)];
-	struct tcf_proto *filter_list;
-	struct Qdisc *queues[QD_MAX_QUEUES];
-	struct sk_buff_head requeued[QD_MAX_QUEUES];
-};
-
 static const char llc_ip_hdr[8] = {0xAA, 0xAA, 0x3, 0, 0, 0, 0x08, 0};
 
-/* given a data frame determine the 802.1p/1d tag to use */
-static inline unsigned classify_1d(struct sk_buff *skb, struct Qdisc *qd)
+/* Given a data frame determine the 802.1p/1d tag to use.  */
+static unsigned int classify_1d(struct sk_buff *skb)
 {
-	struct iphdr *ip;
-	int dscp;
-	int offset;
-
-	struct ieee80211_sched_data *q = qdisc_priv(qd);
-	struct tcf_result res = { -1, 0 };
-
-	/* if there is a user set filter list, call out to that */
-	if (q->filter_list) {
-		tc_classify(skb, q->filter_list, &res);
-		if (res.class != -1)
-			return res.class;
-	}
+	unsigned int dscp;
 
 	/* skb->priority values from 256->263 are magic values to
-	 * directly indicate a specific 802.1d priority.
-	 * This is used to allow 802.1d priority to be passed directly in
-	 * from VLAN tags, etc. */
+	 * directly indicate a specific 802.1d priority.  This is used
+	 * to allow 802.1d priority to be passed directly in from VLAN
+	 * tags, etc.
+	 */
 	if (skb->priority >= 256 && skb->priority <= 263)
 		return skb->priority - 256;
 
-	/* check there is a valid IP header present */
-	offset = ieee80211_get_hdrlen_from_skb(skb);
-	if (skb->len < offset + sizeof(llc_ip_hdr) + sizeof(*ip) ||
-	    memcmp(skb->data + offset, llc_ip_hdr, sizeof(llc_ip_hdr)))
-		return 0;
+	switch (skb->protocol) {
+	case __constant_htons(ETH_P_IP):
+		dscp = ip_hdr(skb)->tos & 0xfc;
+		break;
 
-	ip = (struct iphdr *) (skb->data + offset + sizeof(llc_ip_hdr));
+	default:
+		return 0;
+	}
 
-	dscp = ip->tos & 0xfc;
 	if (dscp & 0x1c)
 		return 0;
 	return dscp >> 5;
 }
 
 
-static inline int wme_downgrade_ac(struct sk_buff *skb)
+static int wme_downgrade_ac(struct sk_buff *skb)
 {
 	switch (skb->priority) {
 	case 6:
@@ -99,11 +74,10 @@ static inline int wme_downgrade_ac(struct sk_buff *skb)
 }
 
 
-/* positive return value indicates which queue to use
- * negative return value indicates to drop the frame */
-static int classify80211(struct sk_buff *skb, struct Qdisc *qd)
+/* Indicate which queue to use.  */
+static u16 classify80211(struct sk_buff *skb, struct net_device *dev)
 {
-	struct ieee80211_local *local = wdev_priv(qdisc_dev(qd)->ieee80211_ptr);
+	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
 
 	if (!ieee80211_is_data(hdr->frame_control)) {
@@ -123,13 +97,15 @@ static int classify80211(struct sk_buff *skb, struct Qdisc *qd)
 
 	/* use the data classifier to determine what 802.1d tag the
 	 * data frame has */
-	skb->priority = classify_1d(skb, qd);
+	skb->priority = classify_1d(skb);
 
 	/* in case we are a client verify acm is not set for this ac */
 	while (unlikely(local->wmm_acm & BIT(skb->priority))) {
 		if (wme_downgrade_ac(skb)) {
-			/* No AC with lower priority has acm=0, drop packet. */
-			return -1;
+			/* The old code would drop the packet in this
+			 * case.
+			 */
+			return 0;
 		}
 	}
 
@@ -137,28 +113,29 @@ static int classify80211(struct sk_buff *skb, struct Qdisc *qd)
 	return ieee802_1d_to_ac[skb->priority];
 }
 
-
-static int wme_qdiscop_enqueue(struct sk_buff *skb, struct Qdisc* qd)
+u16 ieee80211_select_queue(struct net_device *dev, struct sk_buff *skb)
 {
-	struct ieee80211_local *local = wdev_priv(qdisc_dev(qd)->ieee80211_ptr);
-	struct ieee80211_hw *hw = &local->hw;
-	struct ieee80211_sched_data *q = qdisc_priv(qd);
-	struct ieee80211_tx_info *info = IEEE80211_SKB_CB(skb);
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
-	struct Qdisc *qdisc;
+	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
+	struct ieee80211_tx_info *info = IEEE80211_SKB_CB(skb);
 	struct sta_info *sta;
-	int err, queue;
+	u16 queue;
 	u8 tid;
 
+	queue = classify80211(skb, dev);
+	if (unlikely(queue >= local->hw.queues))
+		queue = local->hw.queues - 1;
+
 	if (info->flags & IEEE80211_TX_CTL_REQUEUE) {
-		queue = skb_get_queue_mapping(skb);
 		rcu_read_lock();
 		sta = sta_info_get(local, hdr->addr1);
 		tid = skb->priority & IEEE80211_QOS_CTL_TAG1D_MASK;
 		if (sta) {
+			struct ieee80211_hw *hw = &local->hw;
 			int ampdu_queue = sta->tid_to_tx_q[tid];
-			if ((ampdu_queue < QD_NUM(hw)) &&
-			    test_bit(ampdu_queue, q->qdisc_pool)) {
+
+			if ((ampdu_queue < ieee80211_num_queues(hw)) &&
+			    test_bit(ampdu_queue, local->queue_pool)) {
 				queue = ampdu_queue;
 				info->flags |= IEEE80211_TX_CTL_AMPDU;
 			} else {
@@ -166,17 +143,12 @@ static int wme_qdiscop_enqueue(struct sk_buff *skb, struct Qdisc* qd)
 			}
 		}
 		rcu_read_unlock();
-		skb_queue_tail(&q->requeued[queue], skb);
-		qd->q.qlen++;
-		return 0;
-	}
-
-	queue = classify80211(skb, qd);
 
-	if (unlikely(queue >= local->hw.queues))
-		queue = local->hw.queues - 1;
+		return queue;
+	}
 
-	/* now we know the 1d priority, fill in the QoS header if there is one
+	/* Now we know the 1d priority, fill in the QoS header if
+	 * there is one.
 	 */
 	if (ieee80211_is_data_qos(hdr->frame_control)) {
 		u8 *p = ieee80211_get_qos_ctl(hdr);
@@ -194,8 +166,10 @@ static int wme_qdiscop_enqueue(struct sk_buff *skb, struct Qdisc* qd)
 		sta = sta_info_get(local, hdr->addr1);
 		if (sta) {
 			int ampdu_queue = sta->tid_to_tx_q[tid];
-			if ((ampdu_queue < QD_NUM(hw)) &&
-			    test_bit(ampdu_queue, q->qdisc_pool)) {
+			struct ieee80211_hw *hw = &local->hw;
+
+			if ((ampdu_queue < ieee80211_num_queues(hw)) &&
+			    test_bit(ampdu_queue, local->queue_pool)) {
 				queue = ampdu_queue;
 				info->flags |= IEEE80211_TX_CTL_AMPDU;
 			} else {
@@ -206,421 +180,13 @@ static int wme_qdiscop_enqueue(struct sk_buff *skb, struct Qdisc* qd)
 		rcu_read_unlock();
 	}
 
-	if (unlikely(queue < 0)) {
-			kfree_skb(skb);
-			err = NET_XMIT_DROP;
-	} else {
-		skb_set_queue_mapping(skb, queue);
-		qdisc = q->queues[queue];
-		err = qdisc->enqueue(skb, qdisc);
-		if (err == NET_XMIT_SUCCESS) {
-			qd->q.qlen++;
-			qd->bstats.bytes += skb->len;
-			qd->bstats.packets++;
-			return NET_XMIT_SUCCESS;
-		}
-	}
-	qd->qstats.drops++;
-	return err;
-}
-
-
-/* TODO: clean up the cases where master_hard_start_xmit
- * returns non 0 - it shouldn't ever do that. Once done we
- * can remove this function */
-static int wme_qdiscop_requeue(struct sk_buff *skb, struct Qdisc* qd)
-{
-	struct ieee80211_sched_data *q = qdisc_priv(qd);
-	struct Qdisc *qdisc;
-	int err;
-
-	/* we recorded which queue to use earlier! */
-	qdisc = q->queues[skb_get_queue_mapping(skb)];
-
-	if ((err = qdisc->ops->requeue(skb, qdisc)) == 0) {
-		qd->q.qlen++;
-		return 0;
-	}
-	qd->qstats.drops++;
-	return err;
-}
-
-
-static struct sk_buff *wme_qdiscop_dequeue(struct Qdisc* qd)
-{
-	struct ieee80211_sched_data *q = qdisc_priv(qd);
-	struct net_device *dev = qdisc_dev(qd);
-	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
-	struct ieee80211_hw *hw = &local->hw;
-	struct sk_buff *skb;
-	struct Qdisc *qdisc;
-	int queue;
-
-	/* check all the h/w queues in numeric/priority order */
-	for (queue = 0; queue < QD_NUM(hw); queue++) {
-		/* see if there is room in this hardware queue */
-		if (__netif_subqueue_stopped(local->mdev, queue) ||
-		    !test_bit(queue, q->qdisc_pool))
-			continue;
-
-		/* there is space - try and get a frame */
-		skb = skb_dequeue(&q->requeued[queue]);
-		if (skb) {
-			qd->q.qlen--;
-			return skb;
-		}
-
-		qdisc = q->queues[queue];
-		skb = qdisc->dequeue(qdisc);
-		if (skb) {
-			qd->q.qlen--;
-			return skb;
-		}
-	}
-	/* returning a NULL here when all the h/w queues are full means we
-	 * never need to call netif_stop_queue in the driver */
-	return NULL;
-}
-
-
-static void wme_qdiscop_reset(struct Qdisc* qd)
-{
-	struct ieee80211_sched_data *q = qdisc_priv(qd);
-	struct ieee80211_local *local = wdev_priv(qdisc_dev(qd)->ieee80211_ptr);
-	struct ieee80211_hw *hw = &local->hw;
-	int queue;
-
-	/* QUESTION: should we have some hardware flush functionality here? */
-
-	for (queue = 0; queue < QD_NUM(hw); queue++) {
-		skb_queue_purge(&q->requeued[queue]);
-		qdisc_reset(q->queues[queue]);
-	}
-	qd->q.qlen = 0;
-}
-
-
-static void wme_qdiscop_destroy(struct Qdisc* qd)
-{
-	struct ieee80211_sched_data *q = qdisc_priv(qd);
-	struct ieee80211_local *local = wdev_priv(qdisc_dev(qd)->ieee80211_ptr);
-	struct ieee80211_hw *hw = &local->hw;
-	int queue;
-
-	tcf_destroy_chain(&q->filter_list);
-
-	for (queue = 0; queue < QD_NUM(hw); queue++) {
-		skb_queue_purge(&q->requeued[queue]);
-		qdisc_destroy(q->queues[queue]);
-		q->queues[queue] = &noop_qdisc;
-	}
-}
-
-
-/* called whenever parameters are updated on existing qdisc */
-static int wme_qdiscop_tune(struct Qdisc *qd, struct nlattr *opt)
-{
-	return 0;
-}
-
-
-/* called during initial creation of qdisc on device */
-static int wme_qdiscop_init(struct Qdisc *qd, struct nlattr *opt)
-{
-	struct ieee80211_sched_data *q = qdisc_priv(qd);
-	struct net_device *dev = qdisc_dev(qd);
-	struct ieee80211_local *local;
-	struct ieee80211_hw *hw;
-	int err = 0, i;
-
-	/* check that device is a mac80211 device */
-	if (!dev->ieee80211_ptr ||
-	    dev->ieee80211_ptr->wiphy->privid != mac80211_wiphy_privid)
-		return -EINVAL;
-
-	local = wdev_priv(dev->ieee80211_ptr);
-	hw = &local->hw;
-
-	/* only allow on master dev */
-	if (dev != local->mdev)
-		return -EINVAL;
-
-	/* ensure that we are root qdisc */
-	if (qd->parent != TC_H_ROOT)
-		return -EINVAL;
-
-	if (qd->flags & TCQ_F_INGRESS)
-		return -EINVAL;
-
-	/* if options were passed in, set them */
-	if (opt)
-		err = wme_qdiscop_tune(qd, opt);
-
-	/* create child queues */
-	for (i = 0; i < QD_NUM(hw); i++) {
-		skb_queue_head_init(&q->requeued[i]);
-		q->queues[i] = qdisc_create_dflt(qdisc_dev(qd), qd->dev_queue,
-						 &pfifo_qdisc_ops,
-						 qd->handle);
-		if (!q->queues[i]) {
-			q->queues[i] = &noop_qdisc;
-			printk(KERN_ERR "%s child qdisc %i creation failed\n",
-			       dev->name, i);
-		}
-	}
-
-	/* non-aggregation queues: reserve/mark as used */
-	for (i = 0; i < local->hw.queues; i++)
-		set_bit(i, q->qdisc_pool);
-
-	return err;
-}
-
-static int wme_qdiscop_dump(struct Qdisc *qd, struct sk_buff *skb)
-{
-	return -1;
-}
-
-
-static int wme_classop_graft(struct Qdisc *qd, unsigned long arg,
-			     struct Qdisc *new, struct Qdisc **old)
-{
-	struct ieee80211_sched_data *q = qdisc_priv(qd);
-	struct ieee80211_local *local = wdev_priv(qdisc_dev(qd)->ieee80211_ptr);
-	struct ieee80211_hw *hw = &local->hw;
-	unsigned long queue = arg - 1;
-
-	if (queue >= QD_NUM(hw))
-		return -EINVAL;
-
-	if (!new)
-		new = &noop_qdisc;
-
-	sch_tree_lock(qd);
-	*old = q->queues[queue];
-	q->queues[queue] = new;
-	qdisc_reset(*old);
-	sch_tree_unlock(qd);
-
-	return 0;
-}
-
-
-static struct Qdisc *
-wme_classop_leaf(struct Qdisc *qd, unsigned long arg)
-{
-	struct ieee80211_sched_data *q = qdisc_priv(qd);
-	struct ieee80211_local *local = wdev_priv(qdisc_dev(qd)->ieee80211_ptr);
-	struct ieee80211_hw *hw = &local->hw;
-	unsigned long queue = arg - 1;
-
-	if (queue >= QD_NUM(hw))
-		return NULL;
-
-	return q->queues[queue];
-}
-
-
-static unsigned long wme_classop_get(struct Qdisc *qd, u32 classid)
-{
-	struct ieee80211_local *local = wdev_priv(qdisc_dev(qd)->ieee80211_ptr);
-	struct ieee80211_hw *hw = &local->hw;
-	unsigned long queue = TC_H_MIN(classid);
-
-	if (queue - 1 >= QD_NUM(hw))
-		return 0;
-
 	return queue;
 }
 
-
-static unsigned long wme_classop_bind(struct Qdisc *qd, unsigned long parent,
-				      u32 classid)
-{
-	return wme_classop_get(qd, classid);
-}
-
-
-static void wme_classop_put(struct Qdisc *q, unsigned long cl)
-{
-}
-
-
-static int wme_classop_change(struct Qdisc *qd, u32 handle, u32 parent,
-			      struct nlattr **tca, unsigned long *arg)
-{
-	unsigned long cl = *arg;
-	struct ieee80211_local *local = wdev_priv(qdisc_dev(qd)->ieee80211_ptr);
-	struct ieee80211_hw *hw = &local->hw;
-
-	if (cl - 1 > QD_NUM(hw))
-		return -ENOENT;
-
-	/* TODO: put code to program hardware queue parameters here,
-	 * to allow programming from tc command line */
-
-	return 0;
-}
-
-
-/* we don't support deleting hardware queues
- * when we add WMM-SA support - TSPECs may be deleted here */
-static int wme_classop_delete(struct Qdisc *qd, unsigned long cl)
-{
-	struct ieee80211_local *local = wdev_priv(qdisc_dev(qd)->ieee80211_ptr);
-	struct ieee80211_hw *hw = &local->hw;
-
-	if (cl - 1 > QD_NUM(hw))
-		return -ENOENT;
-	return 0;
-}
-
-
-static int wme_classop_dump_class(struct Qdisc *qd, unsigned long cl,
-				  struct sk_buff *skb, struct tcmsg *tcm)
-{
-	struct ieee80211_sched_data *q = qdisc_priv(qd);
-	struct ieee80211_local *local = wdev_priv(qdisc_dev(qd)->ieee80211_ptr);
-	struct ieee80211_hw *hw = &local->hw;
-
-	if (cl - 1 > QD_NUM(hw))
-		return -ENOENT;
-	tcm->tcm_handle = TC_H_MIN(cl);
-	tcm->tcm_parent = qd->handle;
-	tcm->tcm_info = q->queues[cl-1]->handle; /* do we need this? */
-	return 0;
-}
-
-
-static void wme_classop_walk(struct Qdisc *qd, struct qdisc_walker *arg)
-{
-	struct ieee80211_local *local = wdev_priv(qdisc_dev(qd)->ieee80211_ptr);
-	struct ieee80211_hw *hw = &local->hw;
-	int queue;
-
-	if (arg->stop)
-		return;
-
-	for (queue = 0; queue < QD_NUM(hw); queue++) {
-		if (arg->count < arg->skip) {
-			arg->count++;
-			continue;
-		}
-		/* we should return classids for our internal queues here
-		 * as well as the external ones */
-		if (arg->fn(qd, queue+1, arg) < 0) {
-			arg->stop = 1;
-			break;
-		}
-		arg->count++;
-	}
-}
-
-
-static struct tcf_proto ** wme_classop_find_tcf(struct Qdisc *qd,
-						unsigned long cl)
-{
-	struct ieee80211_sched_data *q = qdisc_priv(qd);
-
-	if (cl)
-		return NULL;
-
-	return &q->filter_list;
-}
-
-
-/* this qdisc is classful (i.e. has classes, some of which may have leaf qdiscs attached)
- * - these are the operations on the classes */
-static const struct Qdisc_class_ops class_ops =
-{
-	.graft = wme_classop_graft,
-	.leaf = wme_classop_leaf,
-
-	.get = wme_classop_get,
-	.put = wme_classop_put,
-	.change = wme_classop_change,
-	.delete = wme_classop_delete,
-	.walk = wme_classop_walk,
-
-	.tcf_chain = wme_classop_find_tcf,
-	.bind_tcf = wme_classop_bind,
-	.unbind_tcf = wme_classop_put,
-
-	.dump = wme_classop_dump_class,
-};
-
-
-/* queueing discipline operations */
-static struct Qdisc_ops wme_qdisc_ops __read_mostly =
-{
-	.next = NULL,
-	.cl_ops = &class_ops,
-	.id = "ieee80211",
-	.priv_size = sizeof(struct ieee80211_sched_data),
-
-	.enqueue = wme_qdiscop_enqueue,
-	.dequeue = wme_qdiscop_dequeue,
-	.requeue = wme_qdiscop_requeue,
-	.drop = NULL, /* drop not needed since we are always the root qdisc */
-
-	.init = wme_qdiscop_init,
-	.reset = wme_qdiscop_reset,
-	.destroy = wme_qdiscop_destroy,
-	.change = wme_qdiscop_tune,
-
-	.dump = wme_qdiscop_dump,
-};
-
-
-void ieee80211_install_qdisc(struct net_device *dev)
-{
-	struct netdev_queue *txq = netdev_get_tx_queue(dev, 0);
-	struct Qdisc *qdisc;
-
-	qdisc = qdisc_create_dflt(dev, txq,
-				  &wme_qdisc_ops, TC_H_ROOT);
-	if (!qdisc) {
-		printk(KERN_ERR "%s: qdisc installation failed\n", dev->name);
-		return;
-	}
-
-	/* same handle as would be allocated by qdisc_alloc_handle() */
-	qdisc->handle = 0x80010000;
-
-	qdisc_lock_tree(dev);
-	list_add_tail(&qdisc->list, &txq->qdisc_list);
-	txq->qdisc_sleeping = qdisc;
-	qdisc_unlock_tree(dev);
-}
-
-
-int ieee80211_qdisc_installed(struct net_device *dev)
-{
-	struct netdev_queue *txq = netdev_get_tx_queue(dev, 0);
-
-	return txq->qdisc_sleeping->ops == &wme_qdisc_ops;
-}
-
-
-int ieee80211_wme_register(void)
-{
-	return register_qdisc(&wme_qdisc_ops);
-}
-
-
-void ieee80211_wme_unregister(void)
-{
-	unregister_qdisc(&wme_qdisc_ops);
-}
-
 int ieee80211_ht_agg_queue_add(struct ieee80211_local *local,
-			struct sta_info *sta, u16 tid)
+			       struct sta_info *sta, u16 tid)
 {
 	int i;
-	struct netdev_queue *txq = netdev_get_tx_queue(local->mdev, 0);
-	struct ieee80211_sched_data *q =
-			qdisc_priv(txq->qdisc_sleeping);
-	DECLARE_MAC_BUF(mac);
 
 	/* prepare the filter and save it for the SW queue
 	 * matching the received HW queue */
@@ -629,8 +195,8 @@ int ieee80211_ht_agg_queue_add(struct ieee80211_local *local,
 		return -EPERM;
 
 	/* try to get a Qdisc from the pool */
-	for (i = local->hw.queues; i < QD_NUM(&local->hw); i++)
-		if (!test_and_set_bit(i, q->qdisc_pool)) {
+	for (i = local->hw.queues; i < ieee80211_num_queues(&local->hw); i++)
+		if (!test_and_set_bit(i, local->queue_pool)) {
 			ieee80211_stop_queue(local_to_hw(local), i);
 			sta->tid_to_tx_q[tid] = i;
 
@@ -639,11 +205,13 @@ int ieee80211_ht_agg_queue_add(struct ieee80211_local *local,
 			 * on the previous queue
 			 * since HT is strict in order */
 #ifdef CONFIG_MAC80211_HT_DEBUG
-			if (net_ratelimit())
+			if (net_ratelimit()) {
+				DECLARE_MAC_BUF(mac);
 				printk(KERN_DEBUG "allocated aggregation queue"
 					" %d tid %d addr %s pool=0x%lX\n",
 					i, tid, print_mac(mac, sta->addr),
-					q->qdisc_pool[0]);
+					local->queue_pool[0]);
+			}
 #endif /* CONFIG_MAC80211_HT_DEBUG */
 			return 0;
 		}
@@ -658,40 +226,68 @@ void ieee80211_ht_agg_queue_remove(struct ieee80211_local *local,
 				   struct sta_info *sta, u16 tid,
 				   u8 requeue)
 {
-	struct ieee80211_hw *hw = &local->hw;
-	struct netdev_queue *txq = netdev_get_tx_queue(local->mdev, 0);
-	struct ieee80211_sched_data *q =
-		qdisc_priv(txq->qdisc_sleeping);
 	int agg_queue = sta->tid_to_tx_q[tid];
+	struct ieee80211_hw *hw = &local->hw;
 
 	/* return the qdisc to the pool */
-	clear_bit(agg_queue, q->qdisc_pool);
-	sta->tid_to_tx_q[tid] = QD_NUM(hw);
+	clear_bit(agg_queue, local->queue_pool);
+	sta->tid_to_tx_q[tid] = ieee80211_num_queues(hw);
 
-	if (requeue)
+	if (requeue) {
 		ieee80211_requeue(local, agg_queue);
-	else
-		q->queues[agg_queue]->ops->reset(q->queues[agg_queue]);
+	} else {
+		struct netdev_queue *txq;
+
+		txq = netdev_get_tx_queue(local->mdev, agg_queue);
+
+		spin_lock_bh(&txq->lock);
+		qdisc_reset(txq->qdisc);
+		spin_unlock_bh(&txq->lock);
+	}
 }
 
 void ieee80211_requeue(struct ieee80211_local *local, int queue)
 {
-	struct netdev_queue *txq = netdev_get_tx_queue(local->mdev, 0);
-	struct Qdisc *root_qd = txq->qdisc_sleeping;
-	struct ieee80211_sched_data *q = qdisc_priv(root_qd);
-	struct Qdisc *qdisc = q->queues[queue];
-	struct sk_buff *skb = NULL;
+	struct netdev_queue *txq = netdev_get_tx_queue(local->mdev, queue);
+	struct sk_buff_head list;
+	struct Qdisc *qdisc;
 	u32 len;
 
+	rcu_read_lock_bh();
+
+	qdisc = rcu_dereference(txq->qdisc);
 	if (!qdisc || !qdisc->dequeue)
-		return;
+		goto out_unlock;
+
+	skb_queue_head_init(&list);
 
+	spin_lock(&txq->lock);
 	for (len = qdisc->q.qlen; len > 0; len--) {
-		skb = qdisc->dequeue(qdisc);
-		root_qd->q.qlen--;
-		/* packet will be classified again and */
-		/* skb->packet_data->queue will be overridden if needed */
+		struct sk_buff *skb = qdisc->dequeue(qdisc);
+
 		if (skb)
-			wme_qdiscop_enqueue(skb, root_qd);
+			__skb_queue_tail(&list, skb);
+	}
+	spin_unlock(&txq->lock);
+
+	for (len = list.qlen; len > 0; len--) {
+		struct sk_buff *skb = __skb_dequeue(&list);
+		u16 new_queue;
+
+		BUG_ON(!skb);
+		new_queue = ieee80211_select_queue(local->mdev, skb);
+		skb_set_queue_mapping(skb, new_queue);
+
+		txq = netdev_get_tx_queue(local->mdev, new_queue);
+
+		spin_lock(&txq->lock);
+
+		qdisc = rcu_dereference(txq->qdisc);
+		qdisc->enqueue(skb, qdisc);
+
+		spin_unlock(&txq->lock);
 	}
+
+out_unlock:
+	rcu_read_unlock_bh();
 }
diff --git a/net/mac80211/wme.h b/net/mac80211/wme.h
index 1aca609..04de28c 100644
--- a/net/mac80211/wme.h
+++ b/net/mac80211/wme.h
@@ -23,45 +23,12 @@
 
 extern const int ieee802_1d_to_ac[8];
 
-#ifdef CONFIG_MAC80211_QOS
-void ieee80211_install_qdisc(struct net_device *dev);
-int ieee80211_qdisc_installed(struct net_device *dev);
+u16 ieee80211_select_queue(struct net_device *dev, struct sk_buff *skb);
 int ieee80211_ht_agg_queue_add(struct ieee80211_local *local,
 			       struct sta_info *sta, u16 tid);
 void ieee80211_ht_agg_queue_remove(struct ieee80211_local *local,
 				   struct sta_info *sta, u16 tid,
 				   u8 requeue);
 void ieee80211_requeue(struct ieee80211_local *local, int queue);
-int ieee80211_wme_register(void);
-void ieee80211_wme_unregister(void);
-#else
-static inline void ieee80211_install_qdisc(struct net_device *dev)
-{
-}
-static inline int ieee80211_qdisc_installed(struct net_device *dev)
-{
-	return 0;
-}
-static inline int ieee80211_ht_agg_queue_add(struct ieee80211_local *local,
-					     struct sta_info *sta, u16 tid)
-{
-	return -EAGAIN;
-}
-static inline void ieee80211_ht_agg_queue_remove(struct ieee80211_local *local,
-						 struct sta_info *sta, u16 tid,
-						 u8 requeue)
-{
-}
-static inline void ieee80211_requeue(struct ieee80211_local *local, int queue)
-{
-}
-static inline int ieee80211_wme_register(void)
-{
-	return 0;
-}
-static inline void ieee80211_wme_unregister(void)
-{
-}
-#endif /* CONFIG_NET_SCHED */
 
 #endif /* _WME_H */
-- 
1.5.6.2.255.gbed62

