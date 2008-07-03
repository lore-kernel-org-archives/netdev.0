From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: [PATCH 22/39]: netdev: Move atomic queue state bits into
 netdev_queue.
Date: Thu, 03 Jul 2008 00:04:27 -0700 (PDT)
Message-ID: <20080703.000427.00358559.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vinay-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, krkumar2-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org, mchan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
	Matheos.Worku-UdXhSnd/wVw@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---
 include/linux/netdevice.h |   55 +++++++++++++++++++++++++++++++-------------
 include/net/pkt_sched.h   |    2 +-
 net/sched/sch_generic.c   |   20 +++++++++-------
 3 files changed, 51 insertions(+), 26 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index d43bfc6..89bab7e 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -281,14 +281,12 @@ struct header_ops {
 
 enum netdev_state_t
 {
-	__LINK_STATE_XOFF=0,
 	__LINK_STATE_START,
 	__LINK_STATE_PRESENT,
 	__LINK_STATE_SCHED,
 	__LINK_STATE_NOCARRIER,
 	__LINK_STATE_LINKWATCH_PENDING,
 	__LINK_STATE_DORMANT,
-	__LINK_STATE_QDISC_RUNNING,
 };
 
 
@@ -448,10 +446,17 @@ static inline void napi_synchronize(const struct napi_struct *n)
 # define napi_synchronize(n)	barrier()
 #endif
 
+enum netdev_queue_state_t
+{
+	__QUEUE_STATE_XOFF,
+	__QUEUE_STATE_QDISC_RUNNING,
+};
+
 struct netdev_queue {
 	spinlock_t		lock;
 	struct net_device	*dev;
 	struct Qdisc		*qdisc;
+	unsigned long		state;
 	struct sk_buff		*gso_skb;
 	spinlock_t		_xmit_lock;
 	int			xmit_lock_owner;
@@ -950,9 +955,7 @@ extern void __netif_schedule(struct netdev_queue *dev_queue);
 
 static inline void netif_schedule_queue(struct netdev_queue *dev_queue)
 {
-	struct net_device *dev = dev_queue->dev;
-
-	if (!test_bit(__LINK_STATE_XOFF, &dev->state))
+	if (!test_bit(__QUEUE_STATE_XOFF, &dev_queue->state))
 		__netif_schedule(dev_queue);
 }
 
@@ -967,9 +970,14 @@ static inline void netif_schedule(struct net_device *dev)
  *
  *	Allow upper layers to call the device hard_start_xmit routine.
  */
+static inline void netif_tx_start_queue(struct netdev_queue *dev_queue)
+{
+	clear_bit(__QUEUE_STATE_XOFF, &dev_queue->state);
+}
+
 static inline void netif_start_queue(struct net_device *dev)
 {
-	clear_bit(__LINK_STATE_XOFF, &dev->state);
+	netif_tx_start_queue(&dev->tx_queue);
 }
 
 /**
@@ -979,16 +987,21 @@ static inline void netif_start_queue(struct net_device *dev)
  *	Allow upper layers to call the device hard_start_xmit routine.
  *	Used for flow control when transmit resources are available.
  */
-static inline void netif_wake_queue(struct net_device *dev)
+static inline void netif_tx_wake_queue(struct netdev_queue *dev_queue)
 {
 #ifdef CONFIG_NETPOLL_TRAP
 	if (netpoll_trap()) {
-		clear_bit(__LINK_STATE_XOFF, &dev->state);
+		clear_bit(__QUEUE_STATE_XOFF, &dev_queue->state);
 		return;
 	}
 #endif
-	if (test_and_clear_bit(__LINK_STATE_XOFF, &dev->state))
-		__netif_schedule(&dev->tx_queue);
+	if (test_and_clear_bit(__QUEUE_STATE_XOFF, &dev_queue->state))
+		__netif_schedule(dev_queue);
+}
+
+static inline void netif_wake_queue(struct net_device *dev)
+{
+	netif_tx_wake_queue(&dev->tx_queue);
 }
 
 /**
@@ -998,9 +1011,14 @@ static inline void netif_wake_queue(struct net_device *dev)
  *	Stop upper layers calling the device hard_start_xmit routine.
  *	Used for flow control when transmit resources are unavailable.
  */
+static inline void netif_tx_stop_queue(struct netdev_queue *dev_queue)
+{
+	set_bit(__QUEUE_STATE_XOFF, &dev_queue->state);
+}
+
 static inline void netif_stop_queue(struct net_device *dev)
 {
-	set_bit(__LINK_STATE_XOFF, &dev->state);
+	netif_tx_stop_queue(&dev->tx_queue);
 }
 
 /**
@@ -1009,9 +1027,14 @@ static inline void netif_stop_queue(struct net_device *dev)
  *
  *	Test if transmit queue on device is currently unable to send.
  */
+static inline int netif_tx_queue_stopped(const struct netdev_queue *dev_queue)
+{
+	return test_bit(__QUEUE_STATE_XOFF, &dev_queue->state);
+}
+
 static inline int netif_queue_stopped(const struct net_device *dev)
 {
-	return test_bit(__LINK_STATE_XOFF, &dev->state);
+	return netif_tx_queue_stopped(&dev->tx_queue);
 }
 
 /**
@@ -1041,7 +1064,7 @@ static inline int netif_running(const struct net_device *dev)
  */
 static inline void netif_start_subqueue(struct net_device *dev, u16 queue_index)
 {
-	clear_bit(__LINK_STATE_XOFF, &dev->egress_subqueue[queue_index].state);
+	clear_bit(__QUEUE_STATE_XOFF, &dev->egress_subqueue[queue_index].state);
 }
 
 /**
@@ -1057,7 +1080,7 @@ static inline void netif_stop_subqueue(struct net_device *dev, u16 queue_index)
 	if (netpoll_trap())
 		return;
 #endif
-	set_bit(__LINK_STATE_XOFF, &dev->egress_subqueue[queue_index].state);
+	set_bit(__QUEUE_STATE_XOFF, &dev->egress_subqueue[queue_index].state);
 }
 
 /**
@@ -1070,7 +1093,7 @@ static inline void netif_stop_subqueue(struct net_device *dev, u16 queue_index)
 static inline int __netif_subqueue_stopped(const struct net_device *dev,
 					 u16 queue_index)
 {
-	return test_bit(__LINK_STATE_XOFF,
+	return test_bit(__QUEUE_STATE_XOFF,
 			&dev->egress_subqueue[queue_index].state);
 }
 
@@ -1093,7 +1116,7 @@ static inline void netif_wake_subqueue(struct net_device *dev, u16 queue_index)
 	if (netpoll_trap())
 		return;
 #endif
-	if (test_and_clear_bit(__LINK_STATE_XOFF,
+	if (test_and_clear_bit(__QUEUE_STATE_XOFF,
 			       &dev->egress_subqueue[queue_index].state))
 		__netif_schedule(&dev->tx_queue);
 }
diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index 554d6c9..1e2263c 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -87,7 +87,7 @@ static inline void qdisc_run(struct netdev_queue *dev_queue)
 	struct net_device *dev = dev_queue->dev;
 
 	if (!netif_queue_stopped(dev) &&
-	    !test_and_set_bit(__LINK_STATE_QDISC_RUNNING, &dev->state))
+	    !test_and_set_bit(__QUEUE_STATE_QDISC_RUNNING, &dev_queue->state))
 		__qdisc_run(dev_queue);
 }
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 00f4e3e..b919c0b 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -121,9 +121,9 @@ static inline int handle_dev_cpu_collision(struct sk_buff *skb,
 /*
  * NOTE: Called under queue->lock with locally disabled BH.
  *
- * __LINK_STATE_QDISC_RUNNING guarantees only one CPU can process this
- * device at a time. queue->lock serializes queue accesses for
- * this device AND dev_queue->qdisc pointer itself.
+ * __QUEUE_STATE_QDISC_RUNNING guarantees only one CPU can process
+ * this queue at a time. queue->lock serializes queue accesses for
+ * this queue AND dev_queue->qdisc pointer itself.
  *
  *  netif_tx_lock serializes accesses to device driver.
  *
@@ -206,7 +206,7 @@ void __qdisc_run(struct netdev_queue *dev_queue)
 		}
 	}
 
-	clear_bit(__LINK_STATE_QDISC_RUNNING, &dev->state);
+	clear_bit(__QUEUE_STATE_QDISC_RUNNING, &dev_queue->state);
 }
 
 static void dev_watchdog(unsigned long arg)
@@ -605,9 +605,10 @@ static void dev_deactivate_queue(struct netdev_queue *dev_queue,
 
 void dev_deactivate(struct net_device *dev)
 {
+	struct netdev_queue *dev_queue = &dev->tx_queue;
 	int running;
 
-	dev_deactivate_queue(&dev->tx_queue, &noop_qdisc);
+	dev_deactivate_queue(dev_queue, &noop_qdisc);
 
 	dev_watchdog_down(dev);
 
@@ -616,16 +617,17 @@ void dev_deactivate(struct net_device *dev)
 
 	/* Wait for outstanding qdisc_run calls. */
 	do {
-		while (test_bit(__LINK_STATE_QDISC_RUNNING, &dev->state))
+		while (test_bit(__QUEUE_STATE_QDISC_RUNNING, &dev_queue->state))
 			yield();
 
 		/*
 		 * Double-check inside queue lock to ensure that all effects
 		 * of the queue run are visible when we return.
 		 */
-		spin_lock_bh(&dev->tx_queue.lock);
-		running = test_bit(__LINK_STATE_QDISC_RUNNING, &dev->state);
-		spin_unlock_bh(&dev->tx_queue.lock);
+		spin_lock_bh(&dev_queue->lock);
+		running = test_bit(__QUEUE_STATE_QDISC_RUNNING,
+				   &dev_queue->state);
+		spin_unlock_bh(&dev_queue->lock);
 
 		/*
 		 * The running flag should never be set at this point because
-- 
1.5.6

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
