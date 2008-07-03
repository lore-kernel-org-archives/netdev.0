From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: [PATCH 18/39]: netdev: Make netif_schedule() routines work with
 netdev_queue objects.
Date: Thu, 03 Jul 2008 00:04:08 -0700 (PDT)
Message-ID: <20080703.000408.204384909.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vinay-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, krkumar2-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org, mchan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
	Matheos.Worku-UdXhSnd/wVw@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Only plain netif_schedule() remains taking a net_device, mostly
as a compatability item.

Everything else calls netif_schedule_queue() or __netif_schedule(),
both of which take a netdev_queue pointer.

Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---
 include/linux/netdevice.h |   17 ++++++++++++-----
 net/core/dev.c            |   13 +++++++------
 net/mac80211/main.c       |    4 ++--
 net/sched/sch_api.c       |    4 ++--
 net/sched/sch_cbq.c       |    2 +-
 net/sched/sch_generic.c   |   10 +++++-----
 6 files changed, 29 insertions(+), 21 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e9e0cd4..140638c 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -950,12 +950,19 @@ DECLARE_PER_CPU(struct softnet_data,softnet_data);
 
 #define HAVE_NETIF_QUEUE
 
-extern void __netif_schedule(struct net_device *dev);
+extern void __netif_schedule(struct netdev_queue *dev_queue);
 
-static inline void netif_schedule(struct net_device *dev)
+static inline void netif_schedule_queue(struct netdev_queue *dev_queue)
 {
+	struct net_device *dev = dev_queue->dev;
+
 	if (!test_bit(__LINK_STATE_XOFF, &dev->state))
-		__netif_schedule(dev);
+		__netif_schedule(dev_queue);
+}
+
+static inline void netif_schedule(struct net_device *dev)
+{
+	netif_schedule_queue(&dev->tx_queue);
 }
 
 /**
@@ -985,7 +992,7 @@ static inline void netif_wake_queue(struct net_device *dev)
 	}
 #endif
 	if (test_and_clear_bit(__LINK_STATE_XOFF, &dev->state))
-		__netif_schedule(dev);
+		__netif_schedule(&dev->tx_queue);
 }
 
 /**
@@ -1101,7 +1108,7 @@ static inline void netif_wake_subqueue(struct net_device *dev, u16 queue_index)
 #endif
 	if (test_and_clear_bit(__LINK_STATE_XOFF,
 			       &dev->egress_subqueue[queue_index].state))
-		__netif_schedule(dev);
+		__netif_schedule(&dev->tx_queue);
 #endif
 }
 
diff --git a/net/core/dev.c b/net/core/dev.c
index c5e3532..1313eee 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1320,17 +1320,18 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
 }
 
 
-void __netif_schedule(struct net_device *dev)
+void __netif_schedule(struct netdev_queue *dev_queue)
 {
+	struct net_device *dev = dev_queue->dev;
+
 	if (!test_and_set_bit(__LINK_STATE_SCHED, &dev->state)) {
-		struct netdev_queue *txq = &dev->tx_queue;
-		unsigned long flags;
 		struct softnet_data *sd;
+		unsigned long flags;
 
 		local_irq_save(flags);
 		sd = &__get_cpu_var(softnet_data);
-		txq->next_sched = sd->output_queue;
-		sd->output_queue = txq;
+		dev_queue->next_sched = sd->output_queue;
+		sd->output_queue = dev_queue;
 		raise_softirq_irqoff(NET_TX_SOFTIRQ);
 		local_irq_restore(flags);
 	}
@@ -1932,7 +1933,7 @@ static void net_tx_action(struct softirq_action *h)
 				qdisc_run(dev);
 				spin_unlock(&txq->lock);
 			} else {
-				netif_schedule(dev);
+				netif_schedule_queue(txq);
 			}
 		}
 	}
diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index b00bb73..6439d3b 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -865,10 +865,10 @@ void ieee80211_stop_tx_ba_cb(struct ieee80211_hw *hw, u8 *ra, u8 tid)
 	spin_unlock_bh(&dev_queue->lock);
 
 	/* we just requeued the all the frames that were in the removed
-	 * queue, and since we might miss a softirq we do netif_schedule.
+	 * queue, and since we might miss a softirq we do netif_schedule_queue.
 	 * ieee80211_wake_queue is not used here as this queue is not
 	 * necessarily stopped */
-	netif_schedule(local->mdev);
+	netif_schedule_queue(dev_queue);
 	spin_lock_bh(&sta->lock);
 	*state = HT_AGG_STATE_IDLE;
 	sta->ampdu_mlme.addba_req_num[tid] = 0;
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index da3e1c8..8de8bf5 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -282,11 +282,11 @@ static enum hrtimer_restart qdisc_watchdog(struct hrtimer *timer)
 {
 	struct qdisc_watchdog *wd = container_of(timer, struct qdisc_watchdog,
 						 timer);
-	struct net_device *dev = qdisc_dev(wd->qdisc);
+	struct netdev_queue *dev_queue = wd->qdisc->dev_queue;
 
 	wd->qdisc->flags &= ~TCQ_F_THROTTLED;
 	smp_wmb();
-	netif_schedule(dev);
+	netif_schedule_queue(dev_queue);
 
 	return HRTIMER_NORESTART;
 }
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index abaa25d..e175c9f 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -659,7 +659,7 @@ static enum hrtimer_restart cbq_undelay(struct hrtimer *timer)
 	}
 
 	sch->flags &= ~TCQ_F_THROTTLED;
-	netif_schedule(qdisc_dev(sch));
+	netif_schedule_queue(sch->dev_queue);
 	return HRTIMER_NORESTART;
 }
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 96f16a8..b1b7422 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -62,7 +62,7 @@ static inline int qdisc_qlen(struct Qdisc *q)
 	return q->q.qlen;
 }
 
-static inline int dev_requeue_skb(struct sk_buff *skb, struct net_device *dev,
+static inline int dev_requeue_skb(struct sk_buff *skb,
 				  struct netdev_queue *dev_queue,
 				  struct Qdisc *q)
 {
@@ -71,7 +71,7 @@ static inline int dev_requeue_skb(struct sk_buff *skb, struct net_device *dev,
 	else
 		q->ops->requeue(skb, q);
 
-	netif_schedule(dev);
+	netif_schedule_queue(dev_queue);
 	return 0;
 }
 
@@ -114,7 +114,7 @@ static inline int handle_dev_cpu_collision(struct sk_buff *skb,
 		 * some time.
 		 */
 		__get_cpu_var(netdev_rx_stat).cpu_collision++;
-		ret = dev_requeue_skb(skb, dev, dev_queue, q);
+		ret = dev_requeue_skb(skb, dev_queue, q);
 	}
 
 	return ret;
@@ -179,7 +179,7 @@ static inline int qdisc_restart(struct net_device *dev)
 			printk(KERN_WARNING "BUG %s code %d qlen %d\n",
 			       dev->name, ret, q->q.qlen);
 
-		ret = dev_requeue_skb(skb, dev, dev_queue, q);
+		ret = dev_requeue_skb(skb, dev_queue, q);
 		break;
 	}
 
@@ -200,7 +200,7 @@ void __qdisc_run(struct net_device *dev)
 		 * 2. we've been doing it for too long.
 		 */
 		if (need_resched() || jiffies != start_time) {
-			netif_schedule(dev);
+			netif_schedule_queue(&dev->tx_queue);
 			break;
 		}
 	}
-- 
1.5.6

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
