From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: [PATCH 19/39]: pkt_sched: Make qdisc_run take a netdev_queue.
Date: Thu, 03 Jul 2008 00:04:13 -0700 (PDT)
Message-ID: <20080703.000413.44636387.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vinay-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, krkumar2-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org, mchan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
	Matheos.Worku-UdXhSnd/wVw@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


This allows us to use this calling convention all the
way down into qdisc_restart().

Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---
 include/net/pkt_sched.h |    8 +++++---
 net/core/dev.c          |    4 ++--
 net/sched/sch_generic.c |   26 ++++++++++++++------------
 3 files changed, 21 insertions(+), 17 deletions(-)

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index 46fb4d8..554d6c9 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -80,13 +80,15 @@ extern struct qdisc_rate_table *qdisc_get_rtab(struct tc_ratespec *r,
 		struct nlattr *tab);
 extern void qdisc_put_rtab(struct qdisc_rate_table *tab);
 
-extern void __qdisc_run(struct net_device *dev);
+extern void __qdisc_run(struct netdev_queue *dev_queue);
 
-static inline void qdisc_run(struct net_device *dev)
+static inline void qdisc_run(struct netdev_queue *dev_queue)
 {
+	struct net_device *dev = dev_queue->dev;
+
 	if (!netif_queue_stopped(dev) &&
 	    !test_and_set_bit(__LINK_STATE_QDISC_RUNNING, &dev->state))
-		__qdisc_run(dev);
+		__qdisc_run(dev_queue);
 }
 
 extern int tc_classify_compat(struct sk_buff *skb, struct tcf_proto *tp,
diff --git a/net/core/dev.c b/net/core/dev.c
index 1313eee..bb4a724 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1734,7 +1734,7 @@ gso:
 			/* reset queue_mapping to zero */
 			skb_set_queue_mapping(skb, 0);
 			rc = q->enqueue(skb, q);
-			qdisc_run(dev);
+			qdisc_run(txq);
 			spin_unlock(&txq->lock);
 
 			rc = rc == NET_XMIT_BYPASS ? NET_XMIT_SUCCESS : rc;
@@ -1930,7 +1930,7 @@ static void net_tx_action(struct softirq_action *h)
 			clear_bit(__LINK_STATE_SCHED, &dev->state);
 
 			if (spin_trylock(&txq->lock)) {
-				qdisc_run(dev);
+				qdisc_run(txq);
 				spin_unlock(&txq->lock);
 			} else {
 				netif_schedule_queue(txq);
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index b1b7422..3f3e699 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -75,9 +75,8 @@ static inline int dev_requeue_skb(struct sk_buff *skb,
 	return 0;
 }
 
-static inline struct sk_buff *dev_dequeue_skb(struct net_device *dev,
-					      struct netdev_queue *dev_queue,
-					      struct Qdisc *q)
+static inline struct sk_buff *dequeue_skb(struct netdev_queue *dev_queue,
+					  struct Qdisc *q)
 {
 	struct sk_buff *skb;
 
@@ -90,10 +89,10 @@ static inline struct sk_buff *dev_dequeue_skb(struct net_device *dev,
 }
 
 static inline int handle_dev_cpu_collision(struct sk_buff *skb,
-					   struct net_device *dev,
 					   struct netdev_queue *dev_queue,
 					   struct Qdisc *q)
 {
+	struct net_device *dev = dev_queue->dev;
 	int ret;
 
 	if (unlikely(dev->xmit_lock_owner == smp_processor_id())) {
@@ -139,21 +138,23 @@ static inline int handle_dev_cpu_collision(struct sk_buff *skb,
  *				>0 - queue is not empty.
  *
  */
-static inline int qdisc_restart(struct net_device *dev)
+static inline int qdisc_restart(struct netdev_queue *dev_queue)
 {
-	struct netdev_queue *dev_queue = &dev->tx_queue;
 	struct Qdisc *q = dev_queue->qdisc;
-	struct sk_buff *skb;
 	int ret = NETDEV_TX_BUSY;
+	struct net_device *dev;
+	struct sk_buff *skb;
 
 	/* Dequeue packet */
-	if (unlikely((skb = dev_dequeue_skb(dev, dev_queue, q)) == NULL))
+	if (unlikely((skb = dequeue_skb(dev_queue, q)) == NULL))
 		return 0;
 
 
 	/* And release queue */
 	spin_unlock(&dev_queue->lock);
 
+	dev = dev_queue->dev;
+
 	HARD_TX_LOCK(dev, smp_processor_id());
 	if (!netif_subqueue_stopped(dev, skb))
 		ret = dev_hard_start_xmit(skb, dev);
@@ -170,7 +171,7 @@ static inline int qdisc_restart(struct net_device *dev)
 
 	case NETDEV_TX_LOCKED:
 		/* Driver try lock failed */
-		ret = handle_dev_cpu_collision(skb, dev, dev_queue, q);
+		ret = handle_dev_cpu_collision(skb, dev_queue, q);
 		break;
 
 	default:
@@ -186,11 +187,12 @@ static inline int qdisc_restart(struct net_device *dev)
 	return ret;
 }
 
-void __qdisc_run(struct net_device *dev)
+void __qdisc_run(struct netdev_queue *dev_queue)
 {
+	struct net_device *dev = dev_queue->dev;
 	unsigned long start_time = jiffies;
 
-	while (qdisc_restart(dev)) {
+	while (qdisc_restart(dev_queue)) {
 		if (netif_queue_stopped(dev))
 			break;
 
@@ -200,7 +202,7 @@ void __qdisc_run(struct net_device *dev)
 		 * 2. we've been doing it for too long.
 		 */
 		if (need_resched() || jiffies != start_time) {
-			netif_schedule_queue(&dev->tx_queue);
+			netif_schedule_queue(dev_queue);
 			break;
 		}
 	}
-- 
1.5.6

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
