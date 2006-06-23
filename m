From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 3/5] d80211: handle full queue when sending fragments
Date: Fri, 23 Jun 2006 15:01:20 +0200 (CEST)
Message-ID: <20060623130120.BC934483AD@silver.suse.cz>
References: <20060623150047.368594000.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:11911 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S964800AbWFWM76 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2006 08:59:58 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060623150047.368594000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When the queue gets filled up while sending fragments, do not discard the
frame.

Partially sent frames are stored in a buffer in ieee80211_local (there is
place for one frame for each queue there). When the space in hw queue gets
available again, stored frame for that queue is sent first.

Also, the case when driver returns NETDEV_TX_BUSY is handled properly now.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c   |  227 ++++++++++++++++++++++++++++++++++++----------
 net/d80211/ieee80211_i.h |   14 +++
 net/d80211/wme.c         |    5 +
 3 files changed, 198 insertions(+), 48 deletions(-)

975a964398a0beb665747691350282b0a0b809c1
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 65f32a8..0f01311 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -1153,6 +1153,74 @@ static void inline ieee80211_tx_prepare(
 	__ieee80211_tx_prepare(tx, skb, dev, control);
 }
 
+static inline int __ieee80211_queue_stopped(struct ieee80211_local *local,
+					    int queue)
+{
+	return test_bit(IEEE80211_LINK_STATE_XOFF, &local->state[queue]);
+}
+
+static inline int __ieee80211_queue_pending(struct ieee80211_local *local,
+					    int queue)
+{
+	return test_bit(IEEE80211_LINK_STATE_PENDING, &local->state[queue]);
+}
+
+#define IEEE80211_TX_OK		0
+#define IEEE80211_TX_AGAIN	1
+#define IEEE80211_TX_FRAG_AGAIN	2
+
+static int __ieee80211_tx(struct ieee80211_local *local, struct sk_buff *skb,
+			  struct ieee80211_txrx_data *tx)
+{
+	struct ieee80211_tx_control *control = tx->u.tx.control;
+	int ret, i;
+
+	if (skb) {
+		ieee80211_dump_frame(local->mdev->name, "TX to low-level driver", skb);
+		ret = local->hw->tx(local->mdev, skb, control);
+		if (ret)
+			return IEEE80211_TX_AGAIN;
+#ifdef IEEE80211_LEDS
+		if (local->tx_led_counter++ == 0) {
+			ieee80211_tx_led(1, local->mdev);
+		}
+#endif /* IEEE80211_LEDS */
+	}
+	if (tx->u.tx.extra_frag) {
+		control->use_rts_cts = 0;
+		control->use_cts_protect = 0;
+		control->clear_dst_mask = 0;
+		for (i = 0; i < tx->u.tx.num_extra_frag; i++) {
+			if (!tx->u.tx.extra_frag[i])
+				continue;
+			if (__ieee80211_queue_stopped(local, control->queue))
+				return IEEE80211_TX_FRAG_AGAIN;
+			if (i == tx->u.tx.num_extra_frag) {
+				control->tx_rate = tx->u.tx.last_frag_hwrate;
+				control->rateidx = tx->u.tx.last_frag_rateidx;
+				control->rate_ctrl_probe =
+					tx->u.tx.probe_last_frag;
+			}
+
+			ieee80211_dump_frame(local->mdev->name,
+					     "TX to low-level driver", skb);
+			ret = local->hw->tx(local->mdev, tx->u.tx.extra_frag[i],
+					    control);
+			if (ret)
+				return IEEE80211_TX_FRAG_AGAIN;
+#ifdef IEEE80211_LEDS
+			if (local->tx_led_counter++ == 0) {
+				ieee80211_tx_led(1, local->mdev);
+			}
+#endif /* IEEE80211_LEDS */
+			tx->u.tx.extra_frag[i] = NULL;
+		}
+		kfree(tx->u.tx.extra_frag);
+		tx->u.tx.extra_frag = NULL;
+	}
+	return IEEE80211_TX_OK;
+}
+
 static int ieee80211_tx(struct net_device *dev, struct sk_buff *skb,
 			struct ieee80211_tx_control *control, int mgmt)
 {
@@ -1163,6 +1231,8 @@ static int ieee80211_tx(struct net_devic
 	ieee80211_txrx_result res = TXRX_DROP;
         int ret, i;
 
+	WARN_ON(__ieee80211_queue_pending(local, control->queue));
+
 	if (unlikely(skb->len < 10)) {
 		dev_kfree_skb(skb);
 		return 0;
@@ -1193,65 +1263,60 @@ static int ieee80211_tx(struct net_devic
 		return 0;
 	}
 
-	ieee80211_dump_frame(local->mdev->name, "TX to low-level driver", skb);
-	ret = local->hw->tx(local->mdev, skb, control);
-#ifdef IEEE80211_LEDS
-	if (!ret && local->tx_led_counter++ == 0) {
-                ieee80211_tx_led(1, dev);
-        }
-#endif /* IEEE80211_LEDS */
 	if (tx.u.tx.extra_frag) {
-		if (ret > 0) {
-			/* Must free all fragments and return 0 since skb data
-			 * has been fragmented into multiple buffers.
-			 * TODO: could free extra fragments and restore skb to
-			 * the original form since the data is still there and
-			 * then return nonzero so that Linux netif would
-			 * retry. */
-			goto drop;
-		}
-
-		skb = NULL; /* skb is now owned by low-level driver */
-		control->use_rts_cts = 0;
-		control->use_cts_protect = 0;
-		control->clear_dst_mask = 0;
 		for (i = 0; i < tx.u.tx.num_extra_frag; i++) {
 			int next_len, dur;
 			struct ieee80211_hdr *hdr =
 				(struct ieee80211_hdr *)
 				tx.u.tx.extra_frag[i]->data;
-			if (i + 1 < tx.u.tx.num_extra_frag)
+
+			if (i + 1 < tx.u.tx.num_extra_frag) {
 				next_len = tx.u.tx.extra_frag[i + 1]->len;
-			else {
+			} else {
 				next_len = 0;
 				tx.u.tx.rate = tx.u.tx.last_frag_rate;
-				tx.u.tx.control->tx_rate = tx.u.tx.rate->val;
-				tx.u.tx.control->rateidx =
-					tx.u.tx.last_frag_rateidx;
-				tx.u.tx.control->rate_ctrl_probe =
-					tx.u.tx.probe_last_frag;
+				tx.u.tx.last_frag_hwrate = tx.u.tx.rate->val;
 			}
 			dur = ieee80211_duration(&tx, 0, next_len);
 			hdr->duration_id = cpu_to_le16(dur);
+		}
+	}
 
-			ieee80211_dump_frame(local->mdev->name,
-					     "TX to low-level driver", skb);
-			ret = local->hw->tx(local->mdev, tx.u.tx.extra_frag[i],
-					    control);
-			if (ret > 0)
-				goto drop;
-#ifdef IEEE80211_LEDS
-			if (local->tx_led_counter++ == 0) {
-                                ieee80211_tx_led(1, dev);
-                        }
-#endif /* IEEE80211_LEDS */
-			tx.u.tx.extra_frag[i] = NULL;
+retry:
+	ret = __ieee80211_tx(local, skb, &tx);
+	if (ret) {
+		struct ieee80211_tx_stored_packet *store =
+			&local->pending_packet[control->queue];
+
+		if (ret == IEEE80211_TX_FRAG_AGAIN)
+			skb = NULL;
+		set_bit(IEEE80211_LINK_STATE_PENDING,
+			&local->state[control->queue]);
+		smp_mb();
+		/* When the driver gets out of buffers during sending of
+		 * fragments and calls ieee80211_stop_queue, there is
+		 * a small window between IEEE80211_LINK_STATE_XOFF and
+		 * IEEE80211_LINK_STATE_PENDING flags are set. If a buffer
+		 * gets available in that window (i.e. driver calls
+		 * ieee80211_wake_queue), we would end up with ieee80211_tx
+		 * called with IEEE80211_LINK_STATE_PENDING. Prevent this by
+		 * continuing transmitting here when that situation is
+		 * possible to have happened. */
+		if (!__ieee80211_queue_stopped(local, control->queue)) {
+			clear_bit(IEEE80211_LINK_STATE_PENDING,
+				  &local->state[control->queue]);
+			goto retry;
 		}
-		kfree(tx.u.tx.extra_frag);
-        }
-        if (ret == -1)
-		ret = 0;
-	return ret;
+		memcpy(&store->control, control,
+		       sizeof(struct ieee80211_tx_control));
+		store->skb = skb;
+		store->extra_frag = tx.u.tx.extra_frag;
+		store->num_extra_frag = tx.u.tx.num_extra_frag;
+		store->last_frag_hwrate = tx.u.tx.last_frag_hwrate;
+		store->last_frag_rateidx = tx.u.tx.last_frag_rateidx;
+		store->last_frag_rate_ctrl_probe = tx.u.tx.probe_last_frag;
+	}
+	return 0;
 
  drop:
 	if (skb)
@@ -1263,6 +1328,62 @@ #endif /* IEEE80211_LEDS */
 	return 0;
 }
 
+static void ieee80211_tx_pending(unsigned long data)
+{
+	struct ieee80211_local *local = (struct ieee80211_local *)data;
+	struct net_device *dev = local->mdev;
+	struct ieee80211_tx_stored_packet *store;
+	struct ieee80211_txrx_data tx;
+	int i, ret, reschedule = 0;
+
+	spin_lock_bh(&dev->xmit_lock);
+	dev->xmit_lock_owner = smp_processor_id();
+	for (i = 0; i < local->hw->queues; i++) {
+		if (__ieee80211_queue_stopped(local, i))
+			continue;
+		if (!__ieee80211_queue_pending(local, i)) {
+			reschedule = 1;
+			continue;
+		}
+		store = &local->pending_packet[i];
+		tx.u.tx.control = &store->control;
+		tx.u.tx.extra_frag = store->extra_frag;
+		tx.u.tx.num_extra_frag = store->num_extra_frag;
+		tx.u.tx.last_frag_hwrate = store->last_frag_hwrate;
+		tx.u.tx.last_frag_rateidx = store->last_frag_rateidx;
+		tx.u.tx.probe_last_frag = store->last_frag_rate_ctrl_probe;
+		ret = __ieee80211_tx(local, store->skb, &tx);
+		if (ret) {
+			if (ret == IEEE80211_TX_FRAG_AGAIN)
+				store->skb = NULL;
+		} else {
+			clear_bit(IEEE80211_LINK_STATE_PENDING,
+				  &local->state[i]);
+			reschedule = 1;
+		}
+	}
+	dev->xmit_lock_owner = -1;
+	spin_unlock_bh(&dev->xmit_lock);
+	if (reschedule)
+		netif_schedule(dev);
+}
+
+static void ieee80211_clear_tx_pending(struct ieee80211_local *local)
+{
+	int i, j;
+	struct ieee80211_tx_stored_packet *store;
+
+	for (i = 0; i < local->hw->queues; i++) {
+		if (!__ieee80211_queue_pending(local, i))
+			continue;
+		store = &local->pending_packet[i];
+		kfree_skb(store->skb);
+		for (j = 0; j < store->num_extra_frag; j++)
+			kfree_skb(store->extra_frag[j]);
+		kfree(store->extra_frag);
+		clear_bit(IEEE80211_LINK_STATE_PENDING, &local->state[i]);
+	}
+}
 
 static int ieee80211_master_start_xmit(struct sk_buff *skb,
 				       struct net_device *dev)
@@ -1999,6 +2120,7 @@ static int ieee80211_master_open(struct 
 	list_for_each_entry(sdata, &local->sub_if_list, list) {
 		if (sdata->dev != dev && netif_running(sdata->dev)) {
 			res = 0;
+			tasklet_enable(&local->tx_pending_tasklet);
 			break;
 		}
 	}
@@ -2010,6 +2132,7 @@ static int ieee80211_master_stop(struct 
 	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct ieee80211_sub_if_data *sdata;
 
+	tasklet_disable(&local->tx_pending_tasklet);
 	list_for_each_entry(sdata, &local->sub_if_list, list) {
 		if (sdata->dev != dev && netif_running(sdata->dev))
 			return -EOPNOTSUPP;
@@ -4175,6 +4298,10 @@ struct net_device *ieee80211_alloc_hw(si
         sdata->local = local;
         list_add_tail(&sdata->list, &local->sub_if_list);
 
+	tasklet_init(&local->tx_pending_tasklet, ieee80211_tx_pending,
+		     (unsigned long)local);
+	tasklet_disable(&local->tx_pending_tasklet);
+
         tasklet_init(&local->tasklet,
 		     ieee80211_tasklet_handler,
 		     (unsigned long) local);
@@ -4344,6 +4471,7 @@ void ieee80211_unregister_hw(struct net_
 	}
 	rtnl_unlock();
 
+	ieee80211_clear_tx_pending(local);
 	sta_info_stop(local);
 	rate_control_remove_attrs(local, local->rate_ctrl_priv,
 				  &local->class_dev.kobj);
@@ -4426,8 +4554,13 @@ void ieee80211_wake_queue(struct net_dev
 	struct ieee80211_local *local = dev->ieee80211_ptr;
 
 	if (test_and_clear_bit(IEEE80211_LINK_STATE_XOFF,
-			       &local->state[queue]))
-		__netif_schedule(dev);
+			       &local->state[queue])) {
+		if (test_bit(IEEE80211_LINK_STATE_PENDING,
+			     &local->state[queue]))
+			tasklet_schedule(&local->tx_pending_tasklet);
+		else
+			__netif_schedule(dev);
+	}
 }
 
 void ieee80211_stop_queue(struct net_device *dev, int queue)
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index 722860c..0409c52 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -125,6 +125,7 @@ struct ieee80211_txrx_data {
 			 * when using CTS protection with IEEE 802.11g. */
 			struct ieee80211_rate *last_frag_rate;
 			int last_frag_rateidx;
+			int last_frag_hwrate;
 			int mgmt_interface;
 
 			/* Extra fragments (in addition to the first fragment
@@ -155,6 +156,16 @@ struct ieee80211_tx_packet_data {
 	unsigned int mgmt_iface:1;
 };
 
+struct ieee80211_tx_stored_packet {
+	struct ieee80211_tx_control control;
+	struct sk_buff *skb;
+	int num_extra_frag;
+	struct sk_buff **extra_frag;
+	int last_frag_rateidx;
+	int last_frag_hwrate;
+	unsigned int last_frag_rate_ctrl_probe:1;
+};
+
 struct ieee80211_passive_scan {
         unsigned int in_scan:1; /* this must be cleared before calling
 				 * netif_oper(WAKEUP) */
@@ -354,6 +365,8 @@ #define IEEE80211_IRQSAFE_QUEUE_LIMIT 12
 	struct timer_list sta_cleanup;
 
 	unsigned long state[NUM_TX_DATA_QUEUES];
+	struct ieee80211_tx_stored_packet pending_packet[NUM_TX_DATA_QUEUES];
+	struct tasklet_struct tx_pending_tasklet;
 
 	int mc_count;	/* total count of multicast entries in all interfaces */
 	int iff_allmultis, iff_promiscs;
@@ -518,6 +531,7 @@ #endif /* CONFIG_D80211_DEBUG_COUNTERS *
 
 enum ieee80211_link_state_t {
 	IEEE80211_LINK_STATE_XOFF = 0,
+	IEEE80211_LINK_STATE_PENDING,
 };
 
 struct sta_attribute {
diff --git a/net/d80211/wme.c b/net/d80211/wme.c
index 87437cc..76de062 100644
--- a/net/d80211/wme.c
+++ b/net/d80211/wme.c
@@ -323,7 +323,10 @@ static struct sk_buff *wme_qdiscop_deque
 	/* check all the h/w queues in numeric/priority order */
 	for (queue = 0; queue < hw->queues; queue++) {
 		/* see if there is room in this hardware queue */
-		if (test_bit(IEEE80211_LINK_STATE_XOFF, &local->state[queue]))
+		if (test_bit(IEEE80211_LINK_STATE_XOFF,
+			     &local->state[queue]) ||
+		    test_bit(IEEE80211_LINK_STATE_PENDING,
+			     &local->state[queue]))
 			continue;
 
 		/* there is space - try and get a frame */
-- 
1.3.0

