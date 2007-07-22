From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Resurrect napi_poll patch.
Date: Sun, 22 Jul 2007 00:18:18 -0700 (PDT)
Message-ID: <20070722.001818.82052713.davem@davemloft.net>
References: <20070721.185905.18310463.davem@davemloft.net>
	<1185071972.6344.61.camel@localhost.localdomain>
	<20070721.205425.61337743.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	jgarzik@pobox.com
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43444
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753354AbXGVHST (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jul 2007 03:18:19 -0400
In-Reply-To: <20070721.205425.61337743.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Sat, 21 Jul 2007 20:54:25 -0700 (PDT)

> Ok, I'll put the napi_struct info the driver private and respin
> the patch.

To facilitate discussion I converted the core and tg3, and include
just that part of the patch below.

Consequences:

1) rtnetlink and sysfs control of napi->weight had to be removed,
   we only have a device to deal with and dev --> napi is not a
   one to one relationship any longer

2) netpoll is totally broken, it wants to go from a netdevice to
   a singular napi_struct and that simply is not possible any longer

   I made the netpoll disabled case compile for now.

   Note that netpoll would be broken in this regard even without
   Rusty's suggestion that we are implementing here, it simply
   made the issue un-ignorable which I think is fantastic.

Netpoll definitely needs to be dealt with, but as discussed with
Patrick the rtnetlink and sysfs knob drop isn't critial.  At worst, we
can at least preserve the sysfs case by creating some kind of
"napi_create()" that makes a sysfs directory and a "weight" file for a
driver so that the weight can still be set and observed from there.

Rusty, how does it look otherwise?

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 887b9a5..ee6c69c 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -574,7 +574,7 @@ static void tg3_restart_ints(struct tg3 *tp)
 static inline void tg3_netif_stop(struct tg3 *tp)
 {
 	tp->dev->trans_start = jiffies;	/* prevent tx timeout */
-	netif_poll_disable(tp->dev);
+	napi_disable(&tp->napi);
 	netif_tx_disable(tp->dev);
 }
 
@@ -585,7 +585,7 @@ static inline void tg3_netif_start(struct tg3 *tp)
 	 * so long as all callers are assured to have free tx slots
 	 * (such as after tg3_init_hw)
 	 */
-	netif_poll_enable(tp->dev);
+	napi_enable(&tp->napi);
 	tp->hw_status->status |= SD_STATUS_UPDATED;
 	tg3_enable_ints(tp);
 }
@@ -3471,11 +3471,12 @@ next_pkt_nopost:
 	return received;
 }
 
-static int tg3_poll(struct net_device *netdev, int *budget)
+static int tg3_poll(struct napi_struct *napi, int budget)
 {
-	struct tg3 *tp = netdev_priv(netdev);
+	struct tg3 *tp = container_of(napi, struct tg3, napi);
+	struct net_device *netdev = tp->dev;
 	struct tg3_hw_status *sblk = tp->hw_status;
-	int done;
+	int work_done = 0;
 
 	/* handle link change and other phy events */
 	if (!(tp->tg3_flags &
@@ -3494,7 +3495,7 @@ static int tg3_poll(struct net_device *netdev, int *budget)
 	if (sblk->idx[0].tx_consumer != tp->tx_cons) {
 		tg3_tx(tp);
 		if (unlikely(tp->tg3_flags & TG3_FLAG_TX_RECOVERY_PENDING)) {
-			netif_rx_complete(netdev);
+			netif_rx_complete(netdev, &tp->napi);
 			schedule_work(&tp->reset_task);
 			return 0;
 		}
@@ -3502,20 +3503,10 @@ static int tg3_poll(struct net_device *netdev, int *budget)
 
 	/* run RX thread, within the bounds set by NAPI.
 	 * All RX "locking" is done by ensuring outside
-	 * code synchronizes with dev->poll()
+	 * code synchronizes with tg3->napi.poll()
 	 */
-	if (sblk->idx[0].rx_producer != tp->rx_rcb_ptr) {
-		int orig_budget = *budget;
-		int work_done;
-
-		if (orig_budget > netdev->quota)
-			orig_budget = netdev->quota;
-
-		work_done = tg3_rx(tp, orig_budget);
-
-		*budget -= work_done;
-		netdev->quota -= work_done;
-	}
+	if (sblk->idx[0].rx_producer != tp->rx_rcb_ptr)
+		work_done = tg3_rx(tp, budget);
 
 	if (tp->tg3_flags & TG3_FLAG_TAGGED_STATUS) {
 		tp->last_tag = sblk->status_tag;
@@ -3524,13 +3515,12 @@ static int tg3_poll(struct net_device *netdev, int *budget)
 		sblk->status &= ~SD_STATUS_UPDATED;
 
 	/* if no more work, tell net stack and NIC we're done */
-	done = !tg3_has_work(tp);
-	if (done) {
-		netif_rx_complete(netdev);
+	if (!tg3_has_work(tp)) {
+		netif_rx_complete(netdev, &tp->napi);
 		tg3_restart_ints(tp);
 	}
 
-	return (done ? 0 : 1);
+	return work_done;
 }
 
 static void tg3_irq_quiesce(struct tg3 *tp)
@@ -3577,7 +3567,7 @@ static irqreturn_t tg3_msi_1shot(int irq, void *dev_id)
 	prefetch(&tp->rx_rcb[tp->rx_rcb_ptr]);
 
 	if (likely(!tg3_irq_sync(tp)))
-		netif_rx_schedule(dev);		/* schedule NAPI poll */
+		netif_rx_schedule(dev, &tp->napi);
 
 	return IRQ_HANDLED;
 }
@@ -3602,7 +3592,7 @@ static irqreturn_t tg3_msi(int irq, void *dev_id)
 	 */
 	tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW, 0x00000001);
 	if (likely(!tg3_irq_sync(tp)))
-		netif_rx_schedule(dev);		/* schedule NAPI poll */
+		netif_rx_schedule(dev, &tp->napi);
 
 	return IRQ_RETVAL(1);
 }
@@ -3644,7 +3634,7 @@ static irqreturn_t tg3_interrupt(int irq, void *dev_id)
 	sblk->status &= ~SD_STATUS_UPDATED;
 	if (likely(tg3_has_work(tp))) {
 		prefetch(&tp->rx_rcb[tp->rx_rcb_ptr]);
-		netif_rx_schedule(dev);		/* schedule NAPI poll */
+		netif_rx_schedule(dev, &tp->napi);
 	} else {
 		/* No work, shared interrupt perhaps?  re-enable
 		 * interrupts, and flush that PCI write
@@ -3690,7 +3680,7 @@ static irqreturn_t tg3_interrupt_tagged(int irq, void *dev_id)
 	tw32_mailbox_f(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW, 0x00000001);
 	if (tg3_irq_sync(tp))
 		goto out;
-	if (netif_rx_schedule_prep(dev)) {
+	if (netif_rx_schedule_prep(dev, &tp->napi)) {
 		prefetch(&tp->rx_rcb[tp->rx_rcb_ptr]);
 		/* Update last_tag to mark that this status has been
 		 * seen. Because interrupt may be shared, we may be
@@ -3698,7 +3688,7 @@ static irqreturn_t tg3_interrupt_tagged(int irq, void *dev_id)
 		 * if tg3_poll() is not scheduled.
 		 */
 		tp->last_tag = sblk->status_tag;
-		__netif_rx_schedule(dev);
+		__netif_rx_schedule(dev, &tp->napi);
 	}
 out:
 	return IRQ_RETVAL(handled);
@@ -3737,7 +3727,7 @@ static int tg3_restart_hw(struct tg3 *tp, int reset_phy)
 		tg3_full_unlock(tp);
 		del_timer_sync(&tp->timer);
 		tp->irq_sync = 0;
-		netif_poll_enable(tp->dev);
+		napi_enable(&tp->napi);
 		dev_close(tp->dev);
 		tg3_full_lock(tp, 0);
 	}
@@ -3932,7 +3922,7 @@ static int tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	len = skb_headlen(skb);
 
 	/* We are running in BH disabled context with netif_tx_lock
-	 * and TX reclaim runs via tp->poll inside of a software
+	 * and TX reclaim runs via tp->napi.poll inside of a software
 	 * interrupt.  Furthermore, IRQ processing runs lockless so we have
 	 * no IRQ context deadlocks to worry about either.  Rejoice!
 	 */
@@ -4087,7 +4077,7 @@ static int tg3_start_xmit_dma_bug(struct sk_buff *skb, struct net_device *dev)
 	len = skb_headlen(skb);
 
 	/* We are running in BH disabled context with netif_tx_lock
-	 * and TX reclaim runs via tp->poll inside of a software
+	 * and TX reclaim runs via tp->napi.poll inside of a software
 	 * interrupt.  Furthermore, IRQ processing runs lockless so we have
 	 * no IRQ context deadlocks to worry about either.  Rejoice!
 	 */
@@ -7456,6 +7446,7 @@ static int tg3_close(struct net_device *dev)
 {
 	struct tg3 *tp = netdev_priv(dev);
 
+	napi_disable(&tp->napi);
 	cancel_work_sync(&tp->reset_task);
 
 	netif_stop_queue(dev);
@@ -11897,9 +11888,9 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	dev->set_mac_address = tg3_set_mac_addr;
 	dev->do_ioctl = tg3_ioctl;
 	dev->tx_timeout = tg3_tx_timeout;
-	dev->poll = tg3_poll;
+	tp->napi.weight = 64;
+	tp->napi.poll = tg3_poll;
 	dev->ethtool_ops = &tg3_ethtool_ops;
-	dev->weight = 64;
 	dev->watchdog_timeo = TG3_TX_TIMEOUT;
 	dev->change_mtu = tg3_change_mtu;
 	dev->irq = pdev->irq;
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 5c21f49..a6a23bb 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2176,6 +2176,7 @@ struct tg3 {
 	dma_addr_t			tx_desc_mapping;
 
 	/* begin "rx thread" cacheline section */
+	struct napi_struct		napi;
 	void				(*write32_rx_mbox) (struct tg3 *, u32,
 							    u32);
 	u32				rx_rcb_ptr;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 4a616d7..aae2083 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -31,6 +31,7 @@
 
 #ifdef __KERNEL__
 #include <linux/timer.h>
+#include <linux/delay.h>
 #include <asm/atomic.h>
 #include <asm/cache.h>
 #include <asm/byteorder.h>
@@ -258,7 +259,6 @@ enum netdev_state_t
 	__LINK_STATE_PRESENT,
 	__LINK_STATE_SCHED,
 	__LINK_STATE_NOCARRIER,
-	__LINK_STATE_RX_SCHED,
 	__LINK_STATE_LINKWATCH_PENDING,
 	__LINK_STATE_DORMANT,
 	__LINK_STATE_QDISC_RUNNING,
@@ -278,6 +278,73 @@ struct netdev_boot_setup {
 extern int __init netdev_boot_setup(char *str);
 
 /*
+ * Structure for NAPI scheduling similar to tasklet but with weighting
+ */
+struct napi_struct {
+	struct list_head	poll_list;
+	unsigned long		state;
+	int			weight;
+	int			quota;
+	int			(*poll)(struct napi_struct *, int);
+};
+
+enum
+{
+	NAPI_STATE_SCHED,	/* Poll is scheduled */
+	NAPI_STATE_RUN,		/* Poll function is running (only NETPOLL)*/
+};
+
+/* If using netpoll it may "steal" entries that are already scheduled */
+#ifdef CONFIG_NETPOLL
+static inline int napi_trylock(struct napi_struct *n)
+{
+	return !test_and_set_bit(NAPI_STATE_RUN, &n->state);
+}
+
+static inline void napi_unlock(struct napi_struct *n)
+{
+	smp_mb__before_clear_bit();
+	clear_bit(NAPI_STATE_RUN, &n->state);
+}
+#else
+#define napi_trylock(t)	1
+#define napi_unlock(t) do { } while (0)
+#endif
+
+extern void FASTCALL(__napi_schedule(struct napi_struct *n));
+
+static inline int napi_schedule_prep(struct napi_struct *n)
+{
+	return !test_and_set_bit(NAPI_STATE_SCHED, &n->state);
+}
+
+static inline void napi_schedule(struct napi_struct *n)
+{
+	if (napi_schedule_prep(n))
+		__napi_schedule(n);
+}
+
+static inline void napi_complete(struct napi_struct *n)
+{
+	BUG_ON(!test_bit(NAPI_STATE_SCHED, &n->state));
+	smp_mb__before_clear_bit();
+	clear_bit(NAPI_STATE_SCHED, &n->state);
+}
+
+static inline void napi_disable(struct napi_struct *n)
+{
+	while (test_and_set_bit(NAPI_STATE_SCHED, &n->state))
+		msleep_interruptible(1);
+}
+
+static inline void napi_enable(struct napi_struct *n)
+{
+	BUG_ON(!test_bit(NAPI_STATE_SCHED, &n->state));
+	smp_mb__before_clear_bit();
+	clear_bit(NAPI_STATE_SCHED, &n->state);
+}
+
+/*
  *	The DEVICE structure.
  *	Actually, this whole structure is a big mistake.  It mixes I/O
  *	data with strictly "high-level" data, and it has to know about
@@ -430,12 +497,6 @@ struct net_device
 /*
  * Cache line mostly used on receive path (including eth_type_trans())
  */
-	struct list_head	poll_list ____cacheline_aligned_in_smp;
-					/* Link to poll list	*/
-
-	int			(*poll) (struct net_device *dev, int *quota);
-	int			quota;
-	int			weight;
 	unsigned long		last_rx;	/* Time of last Rx	*/
 	/* Interface address info used in eth_type_trans() */
 	unsigned char		dev_addr[MAX_ADDR_LEN];	/* hw address, (before bcast 
@@ -678,7 +739,6 @@ static inline int unregister_gifconf(unsigned int family)
  * Incoming packets are placed on per-cpu queues so that
  * no locking is needed.
  */
-
 struct softnet_data
 {
 	struct net_device	*output_queue;
@@ -686,7 +746,7 @@ struct softnet_data
 	struct list_head	poll_list;
 	struct sk_buff		*completion_queue;
 
-	struct net_device	backlog_dev;	/* Sorry. 8) */
+	struct napi_struct	backlog;
 #ifdef CONFIG_NET_DMA
 	struct dma_chan		*net_dma;
 #endif
@@ -796,20 +856,7 @@ static inline int netif_is_multiqueue(const struct net_device *dev)
 /* Use this variant when it is known for sure that it
  * is executing from interrupt context.
  */
-static inline void dev_kfree_skb_irq(struct sk_buff *skb)
-{
-	if (atomic_dec_and_test(&skb->users)) {
-		struct softnet_data *sd;
-		unsigned long flags;
-
-		local_irq_save(flags);
-		sd = &__get_cpu_var(softnet_data);
-		skb->next = sd->completion_queue;
-		sd->completion_queue = skb;
-		raise_softirq_irqoff(NET_TX_SOFTIRQ);
-		local_irq_restore(flags);
-	}
-}
+extern void dev_kfree_skb_irq(struct sk_buff *skb);
 
 /* Use this variant in places where it could be invoked
  * either from interrupt or non-interrupt context.
@@ -955,60 +1002,41 @@ static inline u32 netif_msg_init(int debug_value, int default_msg_enable_bits)
 	return (1 << debug_value) - 1;
 }
 
-/* Test if receive needs to be scheduled */
-static inline int __netif_rx_schedule_prep(struct net_device *dev)
-{
-	return !test_and_set_bit(__LINK_STATE_RX_SCHED, &dev->state);
-}
 
 /* Test if receive needs to be scheduled but only if up */
-static inline int netif_rx_schedule_prep(struct net_device *dev)
+static inline int netif_rx_schedule_prep(struct net_device *dev,
+					 struct napi_struct *napi)
 {
-	return netif_running(dev) && __netif_rx_schedule_prep(dev);
+	return netif_running(dev) && napi_schedule_prep(napi);
 }
 
 /* Add interface to tail of rx poll list. This assumes that _prep has
  * already been called and returned 1.
  */
-
-extern void __netif_rx_schedule(struct net_device *dev);
-
-/* Try to reschedule poll. Called by irq handler. */
-
-static inline void netif_rx_schedule(struct net_device *dev)
+static inline void __netif_rx_schedule(struct net_device *dev,
+				       struct napi_struct *napi)
 {
-	if (netif_rx_schedule_prep(dev))
-		__netif_rx_schedule(dev);
+	dev_hold(dev);
+	__napi_schedule(napi);
 }
 
-/* Try to reschedule poll. Called by dev->poll() after netif_rx_complete().
- * Do not inline this?
- */
-static inline int netif_rx_reschedule(struct net_device *dev, int undo)
-{
-	if (netif_rx_schedule_prep(dev)) {
-		unsigned long flags;
-
-		dev->quota += undo;
+/* Try to reschedule poll. Called by irq handler. */
 
-		local_irq_save(flags);
-		list_add_tail(&dev->poll_list, &__get_cpu_var(softnet_data).poll_list);
-		__raise_softirq_irqoff(NET_RX_SOFTIRQ);
-		local_irq_restore(flags);
-		return 1;
-	}
-	return 0;
+static inline void netif_rx_schedule(struct net_device *dev,
+				     struct napi_struct *napi)
+{
+	if (netif_rx_schedule_prep(dev, napi))
+		__netif_rx_schedule(dev, napi);
 }
 
 /* same as netif_rx_complete, except that local_irq_save(flags)
  * has already been issued
  */
-static inline void __netif_rx_complete(struct net_device *dev)
+static inline void __netif_rx_complete(struct net_device *dev,
+				       struct napi_struct *napi)
 {
-	BUG_ON(!test_bit(__LINK_STATE_RX_SCHED, &dev->state));
-	list_del(&dev->poll_list);
-	smp_mb__before_clear_bit();
-	clear_bit(__LINK_STATE_RX_SCHED, &dev->state);
+	napi_complete(napi);
+	dev_put(dev);
 }
 
 /* Remove interface from poll list: it must be in the poll list
@@ -1016,28 +1044,16 @@ static inline void __netif_rx_complete(struct net_device *dev)
  * it completes the work. The device cannot be out of poll list at this
  * moment, it is BUG().
  */
-static inline void netif_rx_complete(struct net_device *dev)
+static inline void netif_rx_complete(struct net_device *dev,
+				     struct napi_struct *napi)
 {
 	unsigned long flags;
 
 	local_irq_save(flags);
-	__netif_rx_complete(dev);
+	__netif_rx_complete(dev, napi);
 	local_irq_restore(flags);
 }
 
-static inline void netif_poll_disable(struct net_device *dev)
-{
-	while (test_and_set_bit(__LINK_STATE_RX_SCHED, &dev->state))
-		/* No hurry. */
-		schedule_timeout_interruptible(1);
-}
-
-static inline void netif_poll_enable(struct net_device *dev)
-{
-	smp_mb__before_clear_bit();
-	clear_bit(__LINK_STATE_RX_SCHED, &dev->state);
-}
-
 static inline void netif_tx_lock(struct net_device *dev)
 {
 	spin_lock(&dev->_xmit_lock);
diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
index 29930b7..bbd31f7 100644
--- a/include/linux/netpoll.h
+++ b/include/linux/netpoll.h
@@ -25,8 +25,6 @@ struct netpoll {
 
 struct netpoll_info {
 	atomic_t refcnt;
-	spinlock_t poll_lock;
-	int poll_owner;
 	int rx_flags;
 	spinlock_t rx_lock;
 	struct netpoll *rx_np; /* netpoll that registered an rx_hook */
@@ -44,52 +42,4 @@ void netpoll_set_trap(int trap);
 void netpoll_cleanup(struct netpoll *np);
 int __netpoll_rx(struct sk_buff *skb);
 
-
-#ifdef CONFIG_NETPOLL
-static inline int netpoll_rx(struct sk_buff *skb)
-{
-	struct netpoll_info *npinfo = skb->dev->npinfo;
-	unsigned long flags;
-	int ret = 0;
-
-	if (!npinfo || (!npinfo->rx_np && !npinfo->rx_flags))
-		return 0;
-
-	spin_lock_irqsave(&npinfo->rx_lock, flags);
-	/* check rx_flags again with the lock held */
-	if (npinfo->rx_flags && __netpoll_rx(skb))
-		ret = 1;
-	spin_unlock_irqrestore(&npinfo->rx_lock, flags);
-
-	return ret;
-}
-
-static inline void *netpoll_poll_lock(struct net_device *dev)
-{
-	rcu_read_lock(); /* deal with race on ->npinfo */
-	if (dev->npinfo) {
-		spin_lock(&dev->npinfo->poll_lock);
-		dev->npinfo->poll_owner = smp_processor_id();
-		return dev->npinfo;
-	}
-	return NULL;
-}
-
-static inline void netpoll_poll_unlock(void *have)
-{
-	struct netpoll_info *npi = have;
-
-	if (npi) {
-		npi->poll_owner = -1;
-		spin_unlock(&npi->poll_lock);
-	}
-	rcu_read_unlock();
-}
-
-#else
-#define netpoll_rx(a) 0
-#define netpoll_poll_lock(a) NULL
-#define netpoll_poll_unlock(a)
-#endif
-
 #endif
diff --git a/net/core/dev.c b/net/core/dev.c
index ee40355..afbc38d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -220,7 +220,8 @@ static RAW_NOTIFIER_HEAD(netdev_chain);
  *	Device drivers call our routines to queue packets here. We empty the
  *	queue in the local softnet handler.
  */
-DEFINE_PER_CPU(struct softnet_data, softnet_data) = { NULL };
+
+DEFINE_PER_CPU(struct softnet_data, softnet_data) = { NULL, };
 
 #ifdef CONFIG_SYSFS
 extern int netdev_sysfs_init(void);
@@ -996,16 +997,12 @@ int dev_close(struct net_device *dev)
 	clear_bit(__LINK_STATE_START, &dev->state);
 
 	/* Synchronize to scheduled poll. We cannot touch poll list,
-	 * it can be even on different cpu. So just clear netif_running(),
-	 * and wait when poll really will happen. Actually, the best place
-	 * for this is inside dev->stop() after device stopped its irq
-	 * engine, but this requires more changes in devices. */
-
+	 * it can be even on different cpu. So just clear netif_running().
+	 *
+	 * dev->stop() will invoke napi_disable() on all of it's
+	 * napi_struct instances on this device.
+	 */
 	smp_mb__after_clear_bit(); /* Commit netif_running(). */
-	while (test_bit(__LINK_STATE_RX_SCHED, &dev->state)) {
-		/* No hurry. */
-		msleep(1);
-	}
 
 	/*
 	 *	Call the device specific close. This cannot fail.
@@ -1188,21 +1185,21 @@ void __netif_schedule(struct net_device *dev)
 }
 EXPORT_SYMBOL(__netif_schedule);
 
-void __netif_rx_schedule(struct net_device *dev)
+void dev_kfree_skb_irq(struct sk_buff *skb)
 {
-	unsigned long flags;
+	if (atomic_dec_and_test(&skb->users)) {
+		struct softnet_data *sd;
+		unsigned long flags;
 
-	local_irq_save(flags);
-	dev_hold(dev);
-	list_add_tail(&dev->poll_list, &__get_cpu_var(softnet_data).poll_list);
-	if (dev->quota < 0)
-		dev->quota += dev->weight;
-	else
-		dev->quota = dev->weight;
-	__raise_softirq_irqoff(NET_RX_SOFTIRQ);
-	local_irq_restore(flags);
+		local_irq_save(flags);
+		sd = &__get_cpu_var(softnet_data);
+		skb->next = sd->completion_queue;
+		sd->completion_queue = skb;
+		raise_softirq_irqoff(NET_TX_SOFTIRQ);
+		local_irq_restore(flags);
+	}
 }
-EXPORT_SYMBOL(__netif_rx_schedule);
+EXPORT_SYMBOL(dev_kfree_skb_irq);
 
 void dev_kfree_skb_any(struct sk_buff *skb)
 {
@@ -1638,6 +1635,28 @@ int weight_p __read_mostly = 64;            /* old backlog weight */
 DEFINE_PER_CPU(struct netif_rx_stats, netdev_rx_stat) = { 0, };
 
 
+#ifdef CONFIG_NETPOLL
+static inline int netpoll_rx(struct sk_buff *skb)
+{
+	struct netpoll_info *npinfo = skb->dev->npinfo;
+	unsigned long flags;
+	int ret = 0;
+
+	if (!npinfo || (!npinfo->rx_np && !npinfo->rx_flags))
+		return 0;
+
+	spin_lock_irqsave(&npinfo->rx_lock, flags);
+	/* check rx_flags again with the lock held */
+	if (npinfo->rx_flags && __netpoll_rx(skb))
+		ret = 1;
+	spin_unlock_irqrestore(&npinfo->rx_lock, flags);
+
+	return ret;
+}
+#else 
+#define netpoll_rx(skb)	(0)
+#endif
+
 /**
  *	netif_rx	-	post buffer to the network code
  *	@skb: buffer to post
@@ -1685,7 +1704,7 @@ enqueue:
 			return NET_RX_SUCCESS;
 		}
 
-		netif_rx_schedule(&queue->backlog_dev);
+		napi_schedule(&queue->backlog);
 		goto enqueue;
 	}
 
@@ -1726,6 +1745,38 @@ static inline struct net_device *skb_bond(struct sk_buff *skb)
 	return dev;
 }
 
+
+#ifdef CONFIG_NETPOLL
+/* Netpoll is out of skb's, try and do a quick reclaim on the ones pending
+ * to be cleaned up by softirq.
+ */
+void netpoll_zap_completion_queue(void)
+{
+	struct softnet_data *sd = &get_cpu_var(softnet_data);
+	unsigned long flags;
+
+	if (sd->completion_queue) {
+		struct sk_buff *clist;
+
+		local_irq_save(flags);
+		clist = sd->completion_queue;
+		sd->completion_queue = NULL;
+		local_irq_restore(flags);
+
+		while (clist != NULL) {
+			struct sk_buff *skb = clist;
+			clist = clist->next;
+			if (skb->destructor)
+				dev_kfree_skb_any(skb); /* put this one back */
+			else
+				__kfree_skb(skb);
+		}
+	}
+
+	put_cpu_var(softnet_data);
+}
+#endif
+
 static void net_tx_action(struct softirq_action *h)
 {
 	struct softnet_data *sd = &__get_cpu_var(softnet_data);
@@ -1882,7 +1933,7 @@ int netif_receive_skb(struct sk_buff *skb)
 	__be16 type;
 
 	/* if we've gotten here through NAPI, check netpoll */
-	if (skb->dev->poll && netpoll_rx(skb))
+	if (netpoll_rx(skb))
 		return NET_RX_DROP;
 
 	if (!skb->tstamp.tv64)
@@ -1972,90 +2023,101 @@ out:
 	return ret;
 }
 
-static int process_backlog(struct net_device *backlog_dev, int *budget)
+static int process_backlog(struct napi_struct *napi, int quota)
 {
 	int work = 0;
-	int quota = min(backlog_dev->quota, *budget);
 	struct softnet_data *queue = &__get_cpu_var(softnet_data);
 	unsigned long start_time = jiffies;
 
-	backlog_dev->weight = weight_p;
-	for (;;) {
+	napi->weight = weight_p;
+	do {
 		struct sk_buff *skb;
 		struct net_device *dev;
 
 		local_irq_disable();
 		skb = __skb_dequeue(&queue->input_pkt_queue);
-		if (!skb)
-			goto job_done;
 		local_irq_enable();
-
+		if (!skb) {
+			napi_complete(napi);
+			break;
+		}
+	
 		dev = skb->dev;
 
 		netif_receive_skb(skb);
 
 		dev_put(dev);
+	} while (++work < quota && jiffies == start_time);
 
-		work++;
-
-		if (work >= quota || jiffies - start_time > 1)
-			break;
-
-	}
-
-	backlog_dev->quota -= work;
-	*budget -= work;
-	return -1;
+	return work;
+}
 
-job_done:
-	backlog_dev->quota -= work;
-	*budget -= work;
+/**
+ * __napi_schedule - schedule for receive
+ * @napi: entry to schedule
+ *
+ * The entry's receive function will be scheduled to run
+ */
+void fastcall __napi_schedule(struct napi_struct *n)
+{
+	unsigned long flags;
 
-	list_del(&backlog_dev->poll_list);
-	smp_mb__before_clear_bit();
-	netif_poll_enable(backlog_dev);
+	if (n->quota < 0)
+		n->quota += n->weight;
+	else
+		n->quota = n->weight;
 
-	local_irq_enable();
-	return 0;
+	local_irq_save(flags);
+	list_add_tail(&n->poll_list, &__get_cpu_var(softnet_data).poll_list);
+	__raise_softirq_irqoff(NET_RX_SOFTIRQ);
+	local_irq_restore(flags);
 }
+EXPORT_SYMBOL(__napi_schedule);
+
 
 static void net_rx_action(struct softirq_action *h)
 {
-	struct softnet_data *queue = &__get_cpu_var(softnet_data);
+	struct list_head list;
 	unsigned long start_time = jiffies;
 	int budget = netdev_budget;
-	void *have;
 
 	local_irq_disable();
+	list_replace_init(&__get_cpu_var(softnet_data).poll_list, &list);
+	local_irq_enable();
 
-	while (!list_empty(&queue->poll_list)) {
-		struct net_device *dev;
+	while (!list_empty(&list)) {
+		struct napi_struct *n;
 
-		if (budget <= 0 || jiffies - start_time > 1)
-			goto softnet_break;
+		/* if softirq window is exhuasted then punt */
+		if (unlikely(budget <= 0 || jiffies != start_time)) {
+			local_irq_disable();
+			list_splice(&list, &__get_cpu_var(softnet_data).poll_list);
+			__raise_softirq_irqoff(NET_RX_SOFTIRQ);
+			local_irq_enable();
+			break;
+		}
 
-		local_irq_enable();
+		n = list_entry(list.next, struct napi_struct, poll_list);
 
-		dev = list_entry(queue->poll_list.next,
-				 struct net_device, poll_list);
-		have = netpoll_poll_lock(dev);
+		/* if not racing with netpoll */
+		if (likely(napi_trylock(n))) {
+			list_del(&n->poll_list);
 
-		if (dev->quota <= 0 || dev->poll(dev, &budget)) {
-			netpoll_poll_unlock(have);
-			local_irq_disable();
-			list_move_tail(&dev->poll_list, &queue->poll_list);
-			if (dev->quota < 0)
-				dev->quota += dev->weight;
-			else
-				dev->quota = dev->weight;
-		} else {
-			netpoll_poll_unlock(have);
-			dev_put(dev);
-			local_irq_disable();
-		}
+			/* if quota not exhausted process work */
+			if (likely(n->quota > 0)) {
+				int work = n->poll(n, min(budget, n->quota));
+
+				budget -= work;
+				n->quota -= work;
+			}
+
+			/* if napi_complete not called, reschedule */
+			if (test_bit(NAPI_STATE_SCHED, &n->state))
+				__napi_schedule(n);
+
+			napi_unlock(n);
+		} 
 	}
-out:
-	local_irq_enable();
 #ifdef CONFIG_NET_DMA
 	/*
 	 * There may not be any more sk_buffs coming right now, so push
@@ -2070,12 +2132,6 @@ out:
 		}
 	}
 #endif
-	return;
-
-softnet_break:
-	__get_cpu_var(netdev_rx_stat).time_squeeze++;
-	__raise_softirq_irqoff(NET_RX_SOFTIRQ);
-	goto out;
 }
 
 static gifconf_func_t * gifconf_list [NPROTO];
@@ -3980,10 +4036,9 @@ static int __init net_dev_init(void)
 		skb_queue_head_init(&queue->input_pkt_queue);
 		queue->completion_queue = NULL;
 		INIT_LIST_HEAD(&queue->poll_list);
-		set_bit(__LINK_STATE_START, &queue->backlog_dev.state);
-		queue->backlog_dev.weight = weight_p;
-		queue->backlog_dev.poll = process_backlog;
-		atomic_set(&queue->backlog_dev.refcnt, 1);
+
+		queue->backlog.weight = weight_p;
+		queue->backlog.poll = process_backlog;
 	}
 
 	netdev_dma_register();
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 5c19b06..79159db 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -216,20 +216,6 @@ static ssize_t store_tx_queue_len(struct device *dev,
 	return netdev_store(dev, attr, buf, len, change_tx_queue_len);
 }
 
-NETDEVICE_SHOW(weight, fmt_dec);
-
-static int change_weight(struct net_device *net, unsigned long new_weight)
-{
-	net->weight = new_weight;
-	return 0;
-}
-
-static ssize_t store_weight(struct device *dev, struct device_attribute *attr,
-			    const char *buf, size_t len)
-{
-	return netdev_store(dev, attr, buf, len, change_weight);
-}
-
 static struct device_attribute net_class_attributes[] = {
 	__ATTR(addr_len, S_IRUGO, show_addr_len, NULL),
 	__ATTR(iflink, S_IRUGO, show_iflink, NULL),
@@ -246,7 +232,6 @@ static struct device_attribute net_class_attributes[] = {
 	__ATTR(flags, S_IRUGO | S_IWUSR, show_flags, store_flags),
 	__ATTR(tx_queue_len, S_IRUGO | S_IWUSR, show_tx_queue_len,
 	       store_tx_queue_len),
-	__ATTR(weight, S_IRUGO | S_IWUSR, show_weight, store_weight),
 	{}
 };
 
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index de1b26a..549ffd5 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -46,7 +46,6 @@ static atomic_t trapped;
 		(MAX_UDP_CHUNK + sizeof(struct udphdr) + \
 				sizeof(struct iphdr) + sizeof(struct ethhdr))
 
-static void zap_completion_queue(void);
 static void arp_reply(struct sk_buff *skb);
 
 static void queue_process(struct work_struct *work)
@@ -114,24 +113,26 @@ static __sum16 checksum_udp(struct sk_buff *skb, struct udphdr *uh,
  * In cases where there is bi-directional communications, reading only
  * one message at a time can lead to packets being dropped by the
  * network adapter, forcing superfluous retries and possibly timeouts.
- * Thus, we set our budget to greater than 1.
  */
 static void poll_napi(struct netpoll *np)
 {
-	struct netpoll_info *npinfo = np->dev->npinfo;
-	int budget = 16;
+	struct net_device *dev = np->dev;
+	struct netpoll_info *npinfo = dev->npinfo;
+	struct napi_struct *napi = &dev->napi;
 
-	if (test_bit(__LINK_STATE_RX_SCHED, &np->dev->state) &&
-	    npinfo->poll_owner != smp_processor_id() &&
-	    spin_trylock(&npinfo->poll_lock)) {
+	if (napi->poll && test_bit(NAPI_STATE_SCHED, &napi->state) && napi_trylock(napi)) {
 		npinfo->rx_flags |= NETPOLL_RX_DROP;
 		atomic_inc(&trapped);
 
-		np->dev->poll(np->dev, &budget);
+		list_del(&napi->poll_list);
+
+		napi->poll(napi, napi->quota);
+		if (test_bit(NAPI_STATE_SCHED, &napi->state))
+			__napi_schedule(napi);
 
 		atomic_dec(&trapped);
 		npinfo->rx_flags &= ~NETPOLL_RX_DROP;
-		spin_unlock(&npinfo->poll_lock);
+		napi_unlock(napi);
 	}
 }
 
@@ -150,6 +151,9 @@ static void service_arp_queue(struct netpoll_info *npi)
 	}
 }
 
+extern void netpoll_zap_completion_queue(void);
+
+
 void netpoll_poll(struct netpoll *np)
 {
 	if (!np->dev || !netif_running(np->dev) || !np->dev->poll_controller)
@@ -157,12 +161,11 @@ void netpoll_poll(struct netpoll *np)
 
 	/* Process pending work on NIC */
 	np->dev->poll_controller(np->dev);
-	if (np->dev->poll)
-		poll_napi(np);
+	poll_napi(np);
 
 	service_arp_queue(np->dev->npinfo);
 
-	zap_completion_queue();
+	netpoll_zap_completion_queue();
 }
 
 static void refill_skbs(void)
@@ -181,38 +184,12 @@ static void refill_skbs(void)
 	spin_unlock_irqrestore(&skb_pool.lock, flags);
 }
 
-static void zap_completion_queue(void)
-{
-	unsigned long flags;
-	struct softnet_data *sd = &get_cpu_var(softnet_data);
-
-	if (sd->completion_queue) {
-		struct sk_buff *clist;
-
-		local_irq_save(flags);
-		clist = sd->completion_queue;
-		sd->completion_queue = NULL;
-		local_irq_restore(flags);
-
-		while (clist != NULL) {
-			struct sk_buff *skb = clist;
-			clist = clist->next;
-			if (skb->destructor)
-				dev_kfree_skb_any(skb); /* put this one back */
-			else
-				__kfree_skb(skb);
-		}
-	}
-
-	put_cpu_var(softnet_data);
-}
-
 static struct sk_buff *find_skb(struct netpoll *np, int len, int reserve)
 {
 	int count = 0;
 	struct sk_buff *skb;
 
-	zap_completion_queue();
+	netpoll_zap_completion_queue();
 	refill_skbs();
 repeat:
 
@@ -246,8 +223,7 @@ static void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb)
 	}
 
 	/* don't get messages out of order, and no recursion */
-	if (skb_queue_len(&npinfo->txq) == 0 &&
-		    npinfo->poll_owner != smp_processor_id()) {
+	if (skb_queue_len(&npinfo->txq) == 0) {
 		unsigned long flags;
 
 		local_irq_save(flags);
@@ -652,8 +628,6 @@ int netpoll_setup(struct netpoll *np)
 
 		npinfo->rx_flags = 0;
 		npinfo->rx_np = NULL;
-		spin_lock_init(&npinfo->poll_lock);
-		npinfo->poll_owner = -1;
 
 		spin_lock_init(&npinfo->rx_lock);
 		skb_queue_head_init(&npinfo->arp_tx);
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 06eccca..b6b3618 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -634,7 +634,6 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 
 	NLA_PUT_STRING(skb, IFLA_IFNAME, dev->name);
 	NLA_PUT_U32(skb, IFLA_TXQLEN, dev->tx_queue_len);
-	NLA_PUT_U32(skb, IFLA_WEIGHT, dev->weight);
 	NLA_PUT_U8(skb, IFLA_OPERSTATE,
 		   netif_running(dev) ? dev->operstate : IF_OPER_DOWN);
 	NLA_PUT_U8(skb, IFLA_LINKMODE, dev->link_mode);
@@ -834,9 +833,6 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 	if (tb[IFLA_TXQLEN])
 		dev->tx_queue_len = nla_get_u32(tb[IFLA_TXQLEN]);
 
-	if (tb[IFLA_WEIGHT])
-		dev->weight = nla_get_u32(tb[IFLA_WEIGHT]);
-
 	if (tb[IFLA_OPERSTATE])
 		set_operstate(dev, nla_get_u8(tb[IFLA_OPERSTATE]));
 
@@ -1072,8 +1068,6 @@ replay:
 			       nla_len(tb[IFLA_BROADCAST]));
 		if (tb[IFLA_TXQLEN])
 			dev->tx_queue_len = nla_get_u32(tb[IFLA_TXQLEN]);
-		if (tb[IFLA_WEIGHT])
-			dev->weight = nla_get_u32(tb[IFLA_WEIGHT]);
 		if (tb[IFLA_OPERSTATE])
 			set_operstate(dev, nla_get_u8(tb[IFLA_OPERSTATE]));
 		if (tb[IFLA_LINKMODE])
