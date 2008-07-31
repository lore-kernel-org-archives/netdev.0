From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: Kernel WARNING: at net/core/dev.c:1330
 __netif_schedule+0x2c/0x98()
Date: Thu, 31 Jul 2008 05:29:32 -0700 (PDT)
Message-ID: <20080731.052932.110299354.davem@davemloft.net>
References: <20080726131838.GA2873@ami.dom.local>
	<20080726.173434.48036095.davem@davemloft.net>
	<20080727203757.GA2527@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, netdev-BkyiQQGWkgE@public.gmane.org, peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org,
	Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
	torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080727203757.GA2527-dUp/P3zyUuaNj9Bq2fkWzw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Sun, 27 Jul 2008 22:37:57 +0200

> Looks like enough to me. (Probably it could even share space with
> the state.)

So I made some progress on this, three things:

1) I remember why I choose a to use a bit in my design, it's so that
   it does not increase the costs of the checks in the fast paths.
   test_bit(X) && test_bit(Y) can be combined into a single test by
   the compiler.

2) We can't use the reference counting scheme, because we don't want
   to let a second cpu into these protected code paths just because
   another is in the middle of using a freeze too.

3) So we can simply put a top-level TX spinlock around these things.

Therefore all the hot paths:

a) grab _xmit_lock
b) check XOFF and FROZEN
c) only call ->hard_start_xmit() if both bits are clear

netif_tx_lock() does:

1) grab netdev->tx_global_lock
2) for_each_tx_queue() {
	lock(txq);
	set_bit(FROZEN);
	unlock(txq);
   }

and unlock does:

1) for_each_tx_queue() {
	clear_bit(FROZEN);
	if (!test_bit(XOFF))
		__netif_schedule();
   }
2) release netdev->tx_global_lock

And this seems to satisfy all the constraints which are:

1) Must act like a lock and protect execution of the code path
   which occurs inside of "netif_tx_{lock,unlock}()"

2) Must ensure no cpus are executing inside of ->hard_start_xmit()
   after netif_tx_lock() returns.

3) Must not try to grab all the TX queue locks at once.

This top-level tx_global_lock also simplifies the freezing, as
it makes sure only one cpu is initiating or finishing a freeze
at any given time.

I've also adjusted code that really and truly only wanted to
lock one queue at a time, which in particular was IFB and the
teql scheduler.

It's late here, but I'll start testing the following patch on my
multiqueue capable cards after some sleep.

diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index 0960e69..e4fbefc 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -69,18 +69,20 @@ static void ri_tasklet(unsigned long dev)
 	struct net_device *_dev = (struct net_device *)dev;
 	struct ifb_private *dp = netdev_priv(_dev);
 	struct net_device_stats *stats = &_dev->stats;
+	struct netdev_queue *txq;
 	struct sk_buff *skb;
 
+	txq = netdev_get_tx_queue(_dev, 0);
 	dp->st_task_enter++;
 	if ((skb = skb_peek(&dp->tq)) == NULL) {
 		dp->st_txq_refl_try++;
-		if (netif_tx_trylock(_dev)) {
+		if (__netif_tx_trylock(txq)) {
 			dp->st_rxq_enter++;
 			while ((skb = skb_dequeue(&dp->rq)) != NULL) {
 				skb_queue_tail(&dp->tq, skb);
 				dp->st_rx2tx_tran++;
 			}
-			netif_tx_unlock(_dev);
+			__netif_tx_unlock(txq);
 		} else {
 			/* reschedule */
 			dp->st_rxq_notenter++;
@@ -115,7 +117,7 @@ static void ri_tasklet(unsigned long dev)
 			BUG();
 	}
 
-	if (netif_tx_trylock(_dev)) {
+	if (__netif_tx_trylock(txq)) {
 		dp->st_rxq_check++;
 		if ((skb = skb_peek(&dp->rq)) == NULL) {
 			dp->tasklet_pending = 0;
@@ -123,10 +125,10 @@ static void ri_tasklet(unsigned long dev)
 				netif_wake_queue(_dev);
 		} else {
 			dp->st_rxq_rsch++;
-			netif_tx_unlock(_dev);
+			__netif_tx_unlock(txq);
 			goto resched;
 		}
-		netif_tx_unlock(_dev);
+		__netif_tx_unlock(txq);
 	} else {
 resched:
 		dp->tasklet_pending = 1;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index b4d056c..ee583f6 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -440,6 +440,7 @@ static inline void napi_synchronize(const struct napi_struct *n)
 enum netdev_queue_state_t
 {
 	__QUEUE_STATE_XOFF,
+	__QUEUE_STATE_FROZEN,
 };
 
 struct netdev_queue {
@@ -636,7 +637,7 @@ struct net_device
 	unsigned int		real_num_tx_queues;
 
 	unsigned long		tx_queue_len;	/* Max frames per queue allowed */
-
+	spinlock_t		tx_global_lock;
 /*
  * One part is mostly used on xmit path (device)
  */
@@ -1099,6 +1100,11 @@ static inline int netif_queue_stopped(const struct net_device *dev)
 	return netif_tx_queue_stopped(netdev_get_tx_queue(dev, 0));
 }
 
+static inline int netif_tx_queue_frozen(const struct netdev_queue *dev_queue)
+{
+	return test_bit(__QUEUE_STATE_FROZEN, &dev_queue->state);
+}
+
 /**
  *	netif_running - test if up
  *	@dev: network device
@@ -1475,6 +1481,26 @@ static inline void __netif_tx_lock_bh(struct netdev_queue *txq)
 	txq->xmit_lock_owner = smp_processor_id();
 }
 
+static inline int __netif_tx_trylock(struct netdev_queue *txq)
+{
+	int ok = spin_trylock(&txq->_xmit_lock);
+	if (likely(ok))
+		txq->xmit_lock_owner = smp_processor_id();
+	return ok;
+}
+
+static inline void __netif_tx_unlock(struct netdev_queue *txq)
+{
+	txq->xmit_lock_owner = -1;
+	spin_unlock(&txq->_xmit_lock);
+}
+
+static inline void __netif_tx_unlock_bh(struct netdev_queue *txq)
+{
+	txq->xmit_lock_owner = -1;
+	spin_unlock_bh(&txq->_xmit_lock);
+}
+
 /**
  *	netif_tx_lock - grab network device transmit lock
  *	@dev: network device
@@ -1484,12 +1510,23 @@ static inline void __netif_tx_lock_bh(struct netdev_queue *txq)
  */
 static inline void netif_tx_lock(struct net_device *dev)
 {
-	int cpu = smp_processor_id();
 	unsigned int i;
+	int cpu;
 
+	spin_lock(&dev->tx_global_lock);
+	cpu = smp_processor_id();
 	for (i = 0; i < dev->num_tx_queues; i++) {
 		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
+
+		/* We are the only thread of execution doing a
+		 * freeze, but we have to grab the _xmit_lock in
+		 * order to synchronize with threads which are in
+		 * the ->hard_start_xmit() handler and already
+		 * checked the frozen bit.
+		 */
 		__netif_tx_lock(txq, cpu);
+		set_bit(__QUEUE_STATE_FROZEN, &txq->state);
+		__netif_tx_unlock(txq);
 	}
 }
 
@@ -1499,40 +1536,22 @@ static inline void netif_tx_lock_bh(struct net_device *dev)
 	netif_tx_lock(dev);
 }
 
-static inline int __netif_tx_trylock(struct netdev_queue *txq)
-{
-	int ok = spin_trylock(&txq->_xmit_lock);
-	if (likely(ok))
-		txq->xmit_lock_owner = smp_processor_id();
-	return ok;
-}
-
-static inline int netif_tx_trylock(struct net_device *dev)
-{
-	return __netif_tx_trylock(netdev_get_tx_queue(dev, 0));
-}
-
-static inline void __netif_tx_unlock(struct netdev_queue *txq)
-{
-	txq->xmit_lock_owner = -1;
-	spin_unlock(&txq->_xmit_lock);
-}
-
-static inline void __netif_tx_unlock_bh(struct netdev_queue *txq)
-{
-	txq->xmit_lock_owner = -1;
-	spin_unlock_bh(&txq->_xmit_lock);
-}
-
 static inline void netif_tx_unlock(struct net_device *dev)
 {
 	unsigned int i;
 
 	for (i = 0; i < dev->num_tx_queues; i++) {
 		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
-		__netif_tx_unlock(txq);
-	}
 
+		/* No need to grab the _xmit_lock here.  If the
+		 * queue is not stopped for another reason, we
+		 * force a schedule.
+		 */
+		clear_bit(__QUEUE_STATE_FROZEN, &txq->state);
+		if (!test_bit(__QUEUE_STATE_XOFF, &txq->state))
+			__netif_schedule(txq->qdisc);
+	}
+	spin_unlock(&dev->tx_global_lock);
 }
 
 static inline void netif_tx_unlock_bh(struct net_device *dev)
@@ -1556,13 +1575,18 @@ static inline void netif_tx_unlock_bh(struct net_device *dev)
 static inline void netif_tx_disable(struct net_device *dev)
 {
 	unsigned int i;
+	int cpu;
 
-	netif_tx_lock_bh(dev);
+	local_bh_disable();
+	cpu = smp_processor_id();
 	for (i = 0; i < dev->num_tx_queues; i++) {
 		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
+
+		__netif_tx_lock(txq, cpu);
 		netif_tx_stop_queue(txq);
+		__netif_tx_unlock(txq);
 	}
-	netif_tx_unlock_bh(dev);
+	local_bh_enable();
 }
 
 static inline void netif_addr_lock(struct net_device *dev)
diff --git a/net/core/dev.c b/net/core/dev.c
index 63d6bcd..69320a5 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4200,6 +4200,7 @@ static void netdev_init_queues(struct net_device *dev)
 {
 	netdev_init_one_queue(dev, &dev->rx_queue, NULL);
 	netdev_for_each_tx_queue(dev, netdev_init_one_queue, NULL);
+	spin_lock_init(&dev->tx_global_lock);
 }
 
 /**
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index c127208..6c7af39 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -70,6 +70,7 @@ static void queue_process(struct work_struct *work)
 		local_irq_save(flags);
 		__netif_tx_lock(txq, smp_processor_id());
 		if (netif_tx_queue_stopped(txq) ||
+		    netif_tx_queue_frozen(txq) ||
 		    dev->hard_start_xmit(skb, dev) != NETDEV_TX_OK) {
 			skb_queue_head(&npinfo->txq, skb);
 			__netif_tx_unlock(txq);
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index c7d484f..3284605 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -3305,6 +3305,7 @@ static __inline__ void pktgen_xmit(struct pktgen_dev *pkt_dev)
 
 	txq = netdev_get_tx_queue(odev, queue_map);
 	if (netif_tx_queue_stopped(txq) ||
+	    netif_tx_queue_frozen(txq) ||
 	    need_resched()) {
 		idle_start = getCurUs();
 
@@ -3320,7 +3321,8 @@ static __inline__ void pktgen_xmit(struct pktgen_dev *pkt_dev)
 
 		pkt_dev->idle_acc += getCurUs() - idle_start;
 
-		if (netif_tx_queue_stopped(txq)) {
+		if (netif_tx_queue_stopped(txq) ||
+		    netif_tx_queue_frozen(txq)) {
 			pkt_dev->next_tx_us = getCurUs();	/* TODO */
 			pkt_dev->next_tx_ns = 0;
 			goto out;	/* Try the next interface */
@@ -3352,7 +3354,8 @@ static __inline__ void pktgen_xmit(struct pktgen_dev *pkt_dev)
 	txq = netdev_get_tx_queue(odev, queue_map);
 
 	__netif_tx_lock_bh(txq);
-	if (!netif_tx_queue_stopped(txq)) {
+	if (!netif_tx_queue_stopped(txq) &&
+	    !netif_tx_queue_frozen(txq)) {
 
 		atomic_inc(&(pkt_dev->skb->users));
 	      retry_now:
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 345838a..9c9cd4d 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -135,7 +135,8 @@ static inline int qdisc_restart(struct Qdisc *q)
 	txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
 
 	HARD_TX_LOCK(dev, txq, smp_processor_id());
-	if (!netif_subqueue_stopped(dev, skb))
+	if (!netif_tx_queue_stopped(txq) &&
+	    !netif_tx_queue_frozen(txq))
 		ret = dev_hard_start_xmit(skb, dev, txq);
 	HARD_TX_UNLOCK(dev, txq);
 
@@ -162,7 +163,8 @@ static inline int qdisc_restart(struct Qdisc *q)
 		break;
 	}
 
-	if (ret && netif_tx_queue_stopped(txq))
+	if (ret && (netif_tx_queue_stopped(txq) ||
+		    netif_tx_queue_frozen(txq)))
 		ret = 0;
 
 	return ret;
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index 5372236..2c35c67 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -305,10 +305,11 @@ restart:
 
 		switch (teql_resolve(skb, skb_res, slave)) {
 		case 0:
-			if (netif_tx_trylock(slave)) {
-				if (!__netif_subqueue_stopped(slave, subq) &&
+			if (__netif_tx_trylock(slave_txq)) {
+				if (!netif_tx_queue_stopped(slave_txq) &&
+				    !netif_tx_queue_frozen(slave_txq) &&
 				    slave->hard_start_xmit(skb, slave) == 0) {
-					netif_tx_unlock(slave);
+					__netif_tx_unlock(slave_txq);
 					master->slaves = NEXT_SLAVE(q);
 					netif_wake_queue(dev);
 					master->stats.tx_packets++;
@@ -316,7 +317,7 @@ restart:
 						qdisc_pkt_len(skb);
 					return 0;
 				}
-				netif_tx_unlock(slave);
+				__netif_tx_unlock(slave_txq);
 			}
 			if (netif_queue_stopped(dev))
 				busy = 1;
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
