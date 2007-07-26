From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC]: napi_struct V4
Date: Wed, 25 Jul 2007 21:09:43 -0700 (PDT)
Message-ID: <20070725.210943.122860438.davem@davemloft.net>
References: <20070725.013154.34764933.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, jgarzik@pobox.com,
	hadi@cyberus.ca, rusty@rustcorp.com.au
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53788
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750728AbXGZEJp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2007 00:09:45 -0400
In-Reply-To: <20070725.013154.34764933.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Wed, 25 Jul 2007 01:31:54 -0700 (PDT)

> Besides that the only major issue is netpoll and I have some
> ideas on how to handle that, which I'll try to implement
> tonight and tomorrow.

Ok, here is how I'm trying to crack this nut.

The way I'll solve this is to just change the problem space
and therefore simplify things enough that it's actually sane
and implementable.

None of the receive packet handling of netpoll is even needed,
so we rip all of it out.  Every use was out of tree, and now
subsumed by another facility.  Basically that was kdump, which
is now done via kexec.

As a result there is no more messing around with fake NAPI polls and
all that other crap, instead ->poll_controller() merely has to try to
process TX queue acks to free up space and wake up the transmit
queue(s) of the device.

The downside is that TX ack processing has to run with the
netif_tx_lock() for this to work out.  Basically, netpoll carefully
grabs the TX lock first by disabling interrupts and using
netif_tx_trylock(), if successful it does dev->poll_controller() and
then tries to transmit the packet.

Non-NAPI driver should be able to continue functioning as-is,
they just run their interrupt handler which doesn't schedule
polls and will do the TX queue acking.

NAPI drivers do need to change their ->poll_controller() to do TX
queue acking directly.

I wanted to do this in a way that didn't require touching non-NAPI
drivers as this change is getting big enough as it is and the
change is incomplete if it makes netconsole totally broken in the
process.

Anyways, here are snippets of patch from my current tree that should
show generally what is going on, with bnx2 and tg3 as two converted
NAPI ->poll_controler() examples.  I'm about to boot this up and play
with netconsole to test out that it works properly.

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index a729da0..5187aaf 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -428,7 +428,7 @@ bnx2_netif_stop(struct bnx2 *bp)
 {
 	bnx2_disable_int_sync(bp);
 	if (netif_running(bp->dev)) {
-		netif_poll_disable(bp->dev);
+		napi_disable(&bp->napi);
 		netif_tx_disable(bp->dev);
 		bp->dev->trans_start = jiffies;	/* prevent tx timeout */
 	}
@@ -440,7 +440,7 @@ bnx2_netif_start(struct bnx2 *bp)
 	if (atomic_dec_and_test(&bp->intr_sem)) {
 		if (netif_running(bp->dev)) {
 			netif_wake_queue(bp->dev);
-			netif_poll_enable(bp->dev);
+			napi_enable(&bp->napi);
 			bnx2_enable_int(bp);
 		}
 	}
@@ -2268,7 +2268,7 @@ bnx2_phy_int(struct bnx2 *bp)
 }
 
 static void
-bnx2_tx_int(struct bnx2 *bp)
+__bnx2_tx_int(struct bnx2 *bp)
 {
 	struct status_block *sblk = bp->status_blk;
 	u16 hw_cons, sw_cons, sw_ring_cons;
@@ -2347,11 +2347,9 @@ bnx2_tx_int(struct bnx2 *bp)
 
 	if (unlikely(netif_queue_stopped(bp->dev)) &&
 		     (bnx2_tx_avail(bp) > bp->tx_wake_thresh)) {
-		netif_tx_lock(bp->dev);
 		if ((netif_queue_stopped(bp->dev)) &&
 		    (bnx2_tx_avail(bp) > bp->tx_wake_thresh))
 			netif_wake_queue(bp->dev);
-		netif_tx_unlock(bp->dev);
 	}
 }
 
@@ -2551,7 +2549,7 @@ bnx2_msi(int irq, void *dev_instance)
 	if (unlikely(atomic_read(&bp->intr_sem) != 0))
 		return IRQ_HANDLED;
 
-	netif_rx_schedule(dev);
+	netif_rx_schedule(dev, &bp->napi);
 
 	return IRQ_HANDLED;
 }
@@ -2568,7 +2566,7 @@ bnx2_msi_1shot(int irq, void *dev_instance)
 	if (unlikely(atomic_read(&bp->intr_sem) != 0))
 		return IRQ_HANDLED;
 
-	netif_rx_schedule(dev);
+	netif_rx_schedule(dev, &bp->napi);
 
 	return IRQ_HANDLED;
 }
@@ -2604,9 +2602,9 @@ bnx2_interrupt(int irq, void *dev_instance)
 	if (unlikely(atomic_read(&bp->intr_sem) != 0))
 		return IRQ_HANDLED;
 
-	if (netif_rx_schedule_prep(dev)) {
+	if (netif_rx_schedule_prep(dev, &bp->napi)) {
 		bp->last_status_idx = sblk->status_idx;
-		__netif_rx_schedule(dev);
+		__netif_rx_schedule(dev, &bp->napi);
 	}
 
 	return IRQ_HANDLED;
@@ -2632,12 +2630,14 @@ bnx2_has_work(struct bnx2 *bp)
 }
 
 static int
-bnx2_poll(struct net_device *dev, int *budget)
+bnx2_poll(struct napi_struct *napi, int budget)
 {
-	struct bnx2 *bp = netdev_priv(dev);
+	struct bnx2 *bp = container_of(napi, struct bnx2, napi);
+	struct net_device *dev = bp->dev;
 	struct status_block *sblk = bp->status_blk;
 	u32 status_attn_bits = sblk->status_attn_bits;
 	u32 status_attn_bits_ack = sblk->status_attn_bits_ack;
+	int work_done = 0;
 
 	if ((status_attn_bits & STATUS_ATTN_EVENTS) !=
 	    (status_attn_bits_ack & STATUS_ATTN_EVENTS)) {
@@ -2652,26 +2652,20 @@ bnx2_poll(struct net_device *dev, int *budget)
 		REG_RD(bp, BNX2_HC_COMMAND);
 	}
 
-	if (bp->status_blk->status_tx_quick_consumer_index0 != bp->hw_tx_cons)
-		bnx2_tx_int(bp);
-
-	if (bp->status_blk->status_rx_quick_consumer_index0 != bp->hw_rx_cons) {
-		int orig_budget = *budget;
-		int work_done;
-
-		if (orig_budget > dev->quota)
-			orig_budget = dev->quota;
-
-		work_done = bnx2_rx_int(bp, orig_budget);
-		*budget -= work_done;
-		dev->quota -= work_done;
+	if (bp->status_blk->status_tx_quick_consumer_index0 != bp->hw_tx_cons) {
+		netif_tx_lock(dev);
+		__bnx2_tx_int(bp);
+		netif_tx_unlock(dev);
 	}
 
+	if (bp->status_blk->status_rx_quick_consumer_index0 != bp->hw_rx_cons)
+		work_done = bnx2_rx_int(bp, budget);
+
 	bp->last_status_idx = bp->status_blk->status_idx;
 	rmb();
 
 	if (!bnx2_has_work(bp)) {
-		netif_rx_complete(dev);
+		netif_rx_complete(dev, napi);
 		if (likely(bp->flags & USING_MSI_FLAG)) {
 			REG_WR(bp, BNX2_PCICFG_INT_ACK_CMD,
 			       BNX2_PCICFG_INT_ACK_CMD_INDEX_VALID |
@@ -2686,10 +2680,9 @@ bnx2_poll(struct net_device *dev, int *budget)
 		REG_WR(bp, BNX2_PCICFG_INT_ACK_CMD,
 		       BNX2_PCICFG_INT_ACK_CMD_INDEX_VALID |
 		       bp->last_status_idx);
-		return 0;
 	}
 
-	return 1;
+	return work_done;
 }
 
 /* Called with rtnl_lock from vlan functions and also netif_tx_lock
@@ -5146,10 +5139,7 @@ bnx2_vlan_rx_register(struct net_device *dev, struct vlan_group *vlgrp)
 }
 #endif
 
-/* Called with netif_tx_lock.
- * bnx2_tx_int() runs without netif_tx_lock unless it needs to call
- * netif_wake_queue().
- */
+/* Called with netif_tx_lock.  */
 static int
 bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
@@ -5292,6 +5282,8 @@ bnx2_close(struct net_device *dev)
 	struct bnx2 *bp = netdev_priv(dev);
 	u32 reset_code;
 
+	napi_disable(&bp->napi);
+
 	/* Calling flush_scheduled_work() may deadlock because
 	 * linkwatch_event() may be on the workqueue and it will try to get
 	 * the rtnl_lock which we are holding.
@@ -6370,9 +6362,7 @@ poll_bnx2(struct net_device *dev)
 {
 	struct bnx2 *bp = netdev_priv(dev);
 
-	disable_irq(bp->pdev->irq);
-	bnx2_interrupt(bp->pdev->irq, dev);
-	enable_irq(bp->pdev->irq);
+	__bnx2_tx_int(bp);
 }
 #endif
 
@@ -6856,11 +6846,10 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 #ifdef BCM_VLAN
 	dev->vlan_rx_register = bnx2_vlan_rx_register;
 #endif
-	dev->poll = bnx2_poll;
 	dev->ethtool_ops = &bnx2_ethtool_ops;
-	dev->weight = 64;
 
 	bp = netdev_priv(dev);
+	netif_napi_init(&bp->napi, bnx2_poll, 64);
 
 #if defined(HAVE_POLL_CONTROLLER) || defined(CONFIG_NET_POLL_CONTROLLER)
 	dev->poll_controller = poll_bnx2;
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 102adfe..fbae439 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6473,6 +6473,8 @@ struct bnx2 {
 	struct net_device	*dev;
 	struct pci_dev		*pdev;
 
+	struct napi_struct	napi;
+
 	atomic_t		intr_sem;
 
 	struct status_block	*status_blk;
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 887b9a5..efaa79e 100644
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
@@ -3107,7 +3107,7 @@ static inline u32 tg3_tx_avail(struct tg3 *tp)
  * need special logic to handle SKBs that have not had all
  * of their frags sent yet, like SunGEM does.
  */
-static void tg3_tx(struct tg3 *tp)
+static void __tg3_tx(struct tg3 *tp)
 {
 	u32 hw_idx = tp->hw_status->idx[0].tx_consumer;
 	u32 sw_idx = tp->tx_cons;
@@ -3163,11 +3163,9 @@ static void tg3_tx(struct tg3 *tp)
 
 	if (unlikely(netif_queue_stopped(tp->dev) &&
 		     (tg3_tx_avail(tp) > TG3_TX_WAKEUP_THRESH(tp)))) {
-		netif_tx_lock(tp->dev);
 		if (netif_queue_stopped(tp->dev) &&
 		    (tg3_tx_avail(tp) > TG3_TX_WAKEUP_THRESH(tp)))
 			netif_wake_queue(tp->dev);
-		netif_tx_unlock(tp->dev);
 	}
 }
 
@@ -3471,11 +3469,12 @@ next_pkt_nopost:
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
@@ -3492,9 +3491,11 @@ static int tg3_poll(struct net_device *netdev, int *budget)
 
 	/* run TX completion thread */
 	if (sblk->idx[0].tx_consumer != tp->tx_cons) {
-		tg3_tx(tp);
+		netif_tx_lock(netdev);
+		__tg3_tx(tp);
+		netif_tx_unlock(netdev);
 		if (unlikely(tp->tg3_flags & TG3_FLAG_TX_RECOVERY_PENDING)) {
-			netif_rx_complete(netdev);
+			netif_rx_complete(netdev, napi);
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
+		netif_rx_complete(netdev, napi);
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
@@ -3749,7 +3739,7 @@ static void tg3_poll_controller(struct net_device *dev)
 {
 	struct tg3 *tp = netdev_priv(dev);
 
-	tg3_interrupt(tp->pdev->irq, dev);
+	__tg3_tx(tp);
 }
 #endif
 
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
@@ -11897,9 +11888,8 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	dev->set_mac_address = tg3_set_mac_addr;
 	dev->do_ioctl = tg3_ioctl;
 	dev->tx_timeout = tg3_tx_timeout;
-	dev->poll = tg3_poll;
+	netif_napi_init(&tp->napi, tg3_poll, 64);
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
index 4a616d7..90c628e 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -31,6 +31,7 @@
 
 #ifdef __KERNEL__
 #include <linux/timer.h>
+#include <linux/delay.h>
 #include <asm/atomic.h>
 #include <asm/cache.h>
 #include <asm/byteorder.h>
@@ -38,6 +39,7 @@
 #include <linux/device.h>
 #include <linux/percpu.h>
 #include <linux/dmaengine.h>
+#include <linux/workqueue.h>
 
 struct vlan_group;
 struct ethtool_ops;
@@ -258,7 +260,6 @@ enum netdev_state_t
 	__LINK_STATE_PRESENT,
 	__LINK_STATE_SCHED,
 	__LINK_STATE_NOCARRIER,
-	__LINK_STATE_RX_SCHED,
 	__LINK_STATE_LINKWATCH_PENDING,
 	__LINK_STATE_DORMANT,
 	__LINK_STATE_QDISC_RUNNING,
@@ -278,6 +279,63 @@ struct netdev_boot_setup {
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
+};
+
+static inline void netif_napi_init(struct napi_struct *napi,
+				   int (*poll)(struct napi_struct *, int),
+				   int weight)
+{
+	napi->poll = poll;
+	napi->weight = weight;
+}
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
@@ -430,12 +488,6 @@ struct net_device
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
@@ -663,9 +715,6 @@ extern int		call_netdevice_notifiers(unsigned long val, void *v);
 extern struct net_device	*dev_get_by_index(int ifindex);
 extern struct net_device	*__dev_get_by_index(int ifindex);
 extern int		dev_restart(struct net_device *dev);
-#ifdef CONFIG_NETPOLL_TRAP
-extern int		netpoll_trap(void);
-#endif
 
 typedef int gifconf_func_t(struct net_device * dev, char __user * bufptr, int len);
 extern int		register_gifconf(unsigned int family, gifconf_func_t * gifconf);
@@ -678,7 +727,6 @@ static inline int unregister_gifconf(unsigned int family)
  * Incoming packets are placed on per-cpu queues so that
  * no locking is needed.
  */
-
 struct softnet_data
 {
 	struct net_device	*output_queue;
@@ -686,7 +734,7 @@ struct softnet_data
 	struct list_head	poll_list;
 	struct sk_buff		*completion_queue;
 
-	struct net_device	backlog_dev;	/* Sorry. 8) */
+	struct napi_struct	backlog;
 #ifdef CONFIG_NET_DMA
 	struct dma_chan		*net_dma;
 #endif
@@ -711,12 +759,6 @@ static inline void netif_start_queue(struct net_device *dev)
 
 static inline void netif_wake_queue(struct net_device *dev)
 {
-#ifdef CONFIG_NETPOLL_TRAP
-	if (netpoll_trap()) {
-		clear_bit(__LINK_STATE_XOFF, &dev->state);
-		return;
-	}
-#endif
 	if (test_and_clear_bit(__LINK_STATE_XOFF, &dev->state))
 		__netif_schedule(dev);
 }
@@ -752,10 +794,6 @@ static inline void netif_start_subqueue(struct net_device *dev, u16 queue_index)
 static inline void netif_stop_subqueue(struct net_device *dev, u16 queue_index)
 {
 #ifdef CONFIG_NETDEVICES_MULTIQUEUE
-#ifdef CONFIG_NETPOLL_TRAP
-	if (netpoll_trap())
-		return;
-#endif
 	set_bit(__LINK_STATE_XOFF, &dev->egress_subqueue[queue_index].state);
 #endif
 }
@@ -774,10 +812,6 @@ static inline int netif_subqueue_stopped(const struct net_device *dev,
 static inline void netif_wake_subqueue(struct net_device *dev, u16 queue_index)
 {
 #ifdef CONFIG_NETDEVICES_MULTIQUEUE
-#ifdef CONFIG_NETPOLL_TRAP
-	if (netpoll_trap())
-		return;
-#endif
 	if (test_and_clear_bit(__LINK_STATE_XOFF,
 			       &dev->egress_subqueue[queue_index].state))
 		__netif_schedule(dev);
@@ -796,20 +830,7 @@ static inline int netif_is_multiqueue(const struct net_device *dev)
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
@@ -955,60 +976,41 @@ static inline u32 netif_msg_init(int debug_value, int default_msg_enable_bits)
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
@@ -1016,28 +1018,16 @@ static inline void __netif_rx_complete(struct net_device *dev)
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
index 29930b7..ddae7c1 100644
--- a/include/linux/netpoll.h
+++ b/include/linux/netpoll.h
@@ -16,7 +16,6 @@ struct netpoll {
 	struct net_device *dev;
 	char dev_name[IFNAMSIZ];
 	const char *name;
-	void (*rx_hook)(struct netpoll *, int, char *, int);
 
 	u32 local_ip, remote_ip;
 	u16 local_port, remote_port;
@@ -25,71 +24,13 @@ struct netpoll {
 
 struct netpoll_info {
 	atomic_t refcnt;
-	spinlock_t poll_lock;
-	int poll_owner;
-	int rx_flags;
-	spinlock_t rx_lock;
-	struct netpoll *rx_np; /* netpoll that registered an rx_hook */
-	struct sk_buff_head arp_tx; /* list of arp requests to reply to */
 	struct sk_buff_head txq;
 	struct delayed_work tx_work;
 };
 
-void netpoll_poll(struct netpoll *np);
 void netpoll_send_udp(struct netpoll *np, const char *msg, int len);
 int netpoll_parse_options(struct netpoll *np, char *opt);
 int netpoll_setup(struct netpoll *np);
-int netpoll_trap(void);
-void netpoll_set_trap(int trap);
 void netpoll_cleanup(struct netpoll *np);
-int __netpoll_rx(struct sk_buff *skb);
-
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
 
 #endif
diff --git a/net/core/dev.c b/net/core/dev.c
index ee40355..591cccf 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -220,7 +220,8 @@ static RAW_NOTIFIER_HEAD(netdev_chain);
  *	Device drivers call our routines to queue packets here. We empty the
  *	queue in the local softnet handler.
  */
-DEFINE_PER_CPU(struct softnet_data, softnet_data) = { NULL };
+
+DEFINE_PER_CPU(struct softnet_data, softnet_data);
 
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
@@ -1661,10 +1658,6 @@ int netif_rx(struct sk_buff *skb)
 	struct softnet_data *queue;
 	unsigned long flags;
 
-	/* if netpoll wants it, pretend we never saw it */
-	if (netpoll_rx(skb))
-		return NET_RX_DROP;
-
 	if (!skb->tstamp.tv64)
 		net_timestamp(skb);
 
@@ -1685,7 +1678,7 @@ enqueue:
 			return NET_RX_SUCCESS;
 		}
 
-		netif_rx_schedule(&queue->backlog_dev);
+		napi_schedule(&queue->backlog);
 		goto enqueue;
 	}
 
@@ -1726,6 +1719,7 @@ static inline struct net_device *skb_bond(struct sk_buff *skb)
 	return dev;
 }
 
+
 static void net_tx_action(struct softirq_action *h)
 {
 	struct softnet_data *sd = &__get_cpu_var(softnet_data);
@@ -1881,10 +1875,6 @@ int netif_receive_skb(struct sk_buff *skb)
 	int ret = NET_RX_DROP;
 	__be16 type;
 
-	/* if we've gotten here through NAPI, check netpoll */
-	if (skb->dev->poll && netpoll_rx(skb))
-		return NET_RX_DROP;
-
 	if (!skb->tstamp.tv64)
 		net_timestamp(skb);
 
@@ -1972,90 +1962,96 @@ out:
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
+		list_del(&n->poll_list);
 
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
+		/* if quota not exhausted process work */
+		if (likely(n->quota > 0)) {
+			int work = n->poll(n, min(budget, n->quota));
+
+			budget -= work;
+			n->quota -= work;
 		}
+
+		/* if napi_complete not called, reschedule */
+		if (test_bit(NAPI_STATE_SCHED, &n->state))
+			__napi_schedule(n);
 	}
-out:
-	local_irq_enable();
 #ifdef CONFIG_NET_DMA
 	/*
 	 * There may not be any more sk_buffs coming right now, so push
@@ -2070,12 +2066,6 @@ out:
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
@@ -3980,10 +3970,8 @@ static int __init net_dev_init(void)
 		skb_queue_head_init(&queue->input_pkt_queue);
 		queue->completion_queue = NULL;
 		INIT_LIST_HEAD(&queue->poll_list);
-		set_bit(__LINK_STATE_START, &queue->backlog_dev.state);
-		queue->backlog_dev.weight = weight_p;
-		queue->backlog_dev.poll = process_backlog;
-		atomic_set(&queue->backlog_dev.refcnt, 1);
+
+		netif_napi_init(&queue->backlog, process_backlog, weight_p);
 	}
 
 	netdev_dma_register();
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index de1b26a..6737aba 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -32,23 +32,15 @@
 
 #define MAX_UDP_CHUNK 1460
 #define MAX_SKBS 32
-#define MAX_QUEUE_DEPTH (MAX_SKBS / 2)
 
 static struct sk_buff_head skb_pool;
 
-static atomic_t trapped;
-
 #define USEC_PER_POLL	50
-#define NETPOLL_RX_ENABLED  1
-#define NETPOLL_RX_DROP     2
 
 #define MAX_SKB_SIZE \
 		(MAX_UDP_CHUNK + sizeof(struct udphdr) + \
 				sizeof(struct iphdr) + sizeof(struct ethhdr))
 
-static void zap_completion_queue(void);
-static void arp_reply(struct sk_buff *skb);
-
 static void queue_process(struct work_struct *work)
 {
 	struct netpoll_info *npinfo =
@@ -81,90 +73,6 @@ static void queue_process(struct work_struct *work)
 	}
 }
 
-static __sum16 checksum_udp(struct sk_buff *skb, struct udphdr *uh,
-			    unsigned short ulen, __be32 saddr, __be32 daddr)
-{
-	__wsum psum;
-
-	if (uh->check == 0 || skb_csum_unnecessary(skb))
-		return 0;
-
-	psum = csum_tcpudp_nofold(saddr, daddr, ulen, IPPROTO_UDP, 0);
-
-	if (skb->ip_summed == CHECKSUM_COMPLETE &&
-	    !csum_fold(csum_add(psum, skb->csum)))
-		return 0;
-
-	skb->csum = psum;
-
-	return __skb_checksum_complete(skb);
-}
-
-/*
- * Check whether delayed processing was scheduled for our NIC. If so,
- * we attempt to grab the poll lock and use ->poll() to pump the card.
- * If this fails, either we've recursed in ->poll() or it's already
- * running on another CPU.
- *
- * Note: we don't mask interrupts with this lock because we're using
- * trylock here and interrupts are already disabled in the softirq
- * case. Further, we test the poll_owner to avoid recursion on UP
- * systems where the lock doesn't exist.
- *
- * In cases where there is bi-directional communications, reading only
- * one message at a time can lead to packets being dropped by the
- * network adapter, forcing superfluous retries and possibly timeouts.
- * Thus, we set our budget to greater than 1.
- */
-static void poll_napi(struct netpoll *np)
-{
-	struct netpoll_info *npinfo = np->dev->npinfo;
-	int budget = 16;
-
-	if (test_bit(__LINK_STATE_RX_SCHED, &np->dev->state) &&
-	    npinfo->poll_owner != smp_processor_id() &&
-	    spin_trylock(&npinfo->poll_lock)) {
-		npinfo->rx_flags |= NETPOLL_RX_DROP;
-		atomic_inc(&trapped);
-
-		np->dev->poll(np->dev, &budget);
-
-		atomic_dec(&trapped);
-		npinfo->rx_flags &= ~NETPOLL_RX_DROP;
-		spin_unlock(&npinfo->poll_lock);
-	}
-}
-
-static void service_arp_queue(struct netpoll_info *npi)
-{
-	struct sk_buff *skb;
-
-	if (unlikely(!npi))
-		return;
-
-	skb = skb_dequeue(&npi->arp_tx);
-
-	while (skb != NULL) {
-		arp_reply(skb);
-		skb = skb_dequeue(&npi->arp_tx);
-	}
-}
-
-void netpoll_poll(struct netpoll *np)
-{
-	if (!np->dev || !netif_running(np->dev) || !np->dev->poll_controller)
-		return;
-
-	/* Process pending work on NIC */
-	np->dev->poll_controller(np->dev);
-	if (np->dev->poll)
-		poll_napi(np);
-
-	service_arp_queue(np->dev->npinfo);
-
-	zap_completion_queue();
-}
-
 static void refill_skbs(void)
 {
 	struct sk_buff *skb;
@@ -181,52 +89,18 @@ static void refill_skbs(void)
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
-	int count = 0;
 	struct sk_buff *skb;
 
-	zap_completion_queue();
 	refill_skbs();
-repeat:
 
 	skb = alloc_skb(len, GFP_ATOMIC);
 	if (!skb)
 		skb = skb_dequeue(&skb_pool);
 
-	if (!skb) {
-		if (++count < 10) {
-			netpoll_poll(np);
-			goto repeat;
-		}
+	if (!skb)
 		return NULL;
-	}
 
 	atomic_set(&skb->users, 1);
 	skb_reserve(skb, reserve);
@@ -246,8 +120,7 @@ static void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb)
 	}
 
 	/* don't get messages out of order, and no recursion */
-	if (skb_queue_len(&npinfo->txq) == 0 &&
-		    npinfo->poll_owner != smp_processor_id()) {
+	if (skb_queue_len(&npinfo->txq) == 0) {
 		unsigned long flags;
 
 		local_irq_save(flags);
@@ -255,6 +128,7 @@ static void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb)
 		for (tries = jiffies_to_usecs(1)/USEC_PER_POLL;
 		     tries > 0; --tries) {
 			if (netif_tx_trylock(dev)) {
+				dev->poll_controller(dev);
 				if (!netif_queue_stopped(dev) &&
 				    !netif_subqueue_stopped(dev, skb->queue_mapping))
 					status = dev->hard_start_xmit(skb, dev);
@@ -265,9 +139,6 @@ static void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb)
 
 			}
 
-			/* tickle device maybe there is some cleanup */
-			netpoll_poll(np);
-
 			udelay(USEC_PER_POLL);
 		}
 		local_irq_restore(flags);
@@ -340,185 +211,6 @@ void netpoll_send_udp(struct netpoll *np, const char *msg, int len)
 	netpoll_send_skb(np, skb);
 }
 
-static void arp_reply(struct sk_buff *skb)
-{
-	struct netpoll_info *npinfo = skb->dev->npinfo;
-	struct arphdr *arp;
-	unsigned char *arp_ptr;
-	int size, type = ARPOP_REPLY, ptype = ETH_P_ARP;
-	__be32 sip, tip;
-	unsigned char *sha;
-	struct sk_buff *send_skb;
-	struct netpoll *np = NULL;
-
-	if (npinfo->rx_np && npinfo->rx_np->dev == skb->dev)
-		np = npinfo->rx_np;
-	if (!np)
-		return;
-
-	/* No arp on this interface */
-	if (skb->dev->flags & IFF_NOARP)
-		return;
-
-	if (!pskb_may_pull(skb, (sizeof(struct arphdr) +
-				 (2 * skb->dev->addr_len) +
-				 (2 * sizeof(u32)))))
-		return;
-
-	skb_reset_network_header(skb);
-	skb_reset_transport_header(skb);
-	arp = arp_hdr(skb);
-
-	if ((arp->ar_hrd != htons(ARPHRD_ETHER) &&
-	     arp->ar_hrd != htons(ARPHRD_IEEE802)) ||
-	    arp->ar_pro != htons(ETH_P_IP) ||
-	    arp->ar_op != htons(ARPOP_REQUEST))
-		return;
-
-	arp_ptr = (unsigned char *)(arp+1);
-	/* save the location of the src hw addr */
-	sha = arp_ptr;
-	arp_ptr += skb->dev->addr_len;
-	memcpy(&sip, arp_ptr, 4);
-	arp_ptr += 4;
-	/* if we actually cared about dst hw addr, it would get copied here */
-	arp_ptr += skb->dev->addr_len;
-	memcpy(&tip, arp_ptr, 4);
-
-	/* Should we ignore arp? */
-	if (tip != htonl(np->local_ip) || LOOPBACK(tip) || MULTICAST(tip))
-		return;
-
-	size = sizeof(struct arphdr) + 2 * (skb->dev->addr_len + 4);
-	send_skb = find_skb(np, size + LL_RESERVED_SPACE(np->dev),
-			    LL_RESERVED_SPACE(np->dev));
-
-	if (!send_skb)
-		return;
-
-	skb_reset_network_header(send_skb);
-	arp = (struct arphdr *) skb_put(send_skb, size);
-	send_skb->dev = skb->dev;
-	send_skb->protocol = htons(ETH_P_ARP);
-
-	/* Fill the device header for the ARP frame */
-
-	if (np->dev->hard_header &&
-	    np->dev->hard_header(send_skb, skb->dev, ptype,
-				 sha, np->local_mac,
-				 send_skb->len) < 0) {
-		kfree_skb(send_skb);
-		return;
-	}
-
-	/*
-	 * Fill out the arp protocol part.
-	 *
-	 * we only support ethernet device type,
-	 * which (according to RFC 1390) should always equal 1 (Ethernet).
-	 */
-
-	arp->ar_hrd = htons(np->dev->type);
-	arp->ar_pro = htons(ETH_P_IP);
-	arp->ar_hln = np->dev->addr_len;
-	arp->ar_pln = 4;
-	arp->ar_op = htons(type);
-
-	arp_ptr=(unsigned char *)(arp + 1);
-	memcpy(arp_ptr, np->dev->dev_addr, np->dev->addr_len);
-	arp_ptr += np->dev->addr_len;
-	memcpy(arp_ptr, &tip, 4);
-	arp_ptr += 4;
-	memcpy(arp_ptr, sha, np->dev->addr_len);
-	arp_ptr += np->dev->addr_len;
-	memcpy(arp_ptr, &sip, 4);
-
-	netpoll_send_skb(np, send_skb);
-}
-
-int __netpoll_rx(struct sk_buff *skb)
-{
-	int proto, len, ulen;
-	struct iphdr *iph;
-	struct udphdr *uh;
-	struct netpoll_info *npi = skb->dev->npinfo;
-	struct netpoll *np = npi->rx_np;
-
-	if (!np)
-		goto out;
-	if (skb->dev->type != ARPHRD_ETHER)
-		goto out;
-
-	/* check if netpoll clients need ARP */
-	if (skb->protocol == htons(ETH_P_ARP) &&
-	    atomic_read(&trapped)) {
-		skb_queue_tail(&npi->arp_tx, skb);
-		return 1;
-	}
-
-	proto = ntohs(eth_hdr(skb)->h_proto);
-	if (proto != ETH_P_IP)
-		goto out;
-	if (skb->pkt_type == PACKET_OTHERHOST)
-		goto out;
-	if (skb_shared(skb))
-		goto out;
-
-	iph = (struct iphdr *)skb->data;
-	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
-		goto out;
-	if (iph->ihl < 5 || iph->version != 4)
-		goto out;
-	if (!pskb_may_pull(skb, iph->ihl*4))
-		goto out;
-	if (ip_fast_csum((u8 *)iph, iph->ihl) != 0)
-		goto out;
-
-	len = ntohs(iph->tot_len);
-	if (skb->len < len || len < iph->ihl*4)
-		goto out;
-
-	/*
-	 * Our transport medium may have padded the buffer out.
-	 * Now We trim to the true length of the frame.
-	 */
-	if (pskb_trim_rcsum(skb, len))
-		goto out;
-
-	if (iph->protocol != IPPROTO_UDP)
-		goto out;
-
-	len -= iph->ihl*4;
-	uh = (struct udphdr *)(((char *)iph) + iph->ihl*4);
-	ulen = ntohs(uh->len);
-
-	if (ulen != len)
-		goto out;
-	if (checksum_udp(skb, uh, ulen, iph->saddr, iph->daddr))
-		goto out;
-	if (np->local_ip && np->local_ip != ntohl(iph->daddr))
-		goto out;
-	if (np->remote_ip && np->remote_ip != ntohl(iph->saddr))
-		goto out;
-	if (np->local_port && np->local_port != ntohs(uh->dest))
-		goto out;
-
-	np->rx_hook(np, ntohs(uh->source),
-		    (char *)(uh+1),
-		    ulen - sizeof(struct udphdr));
-
-	kfree_skb(skb);
-	return 1;
-
-out:
-	if (atomic_read(&trapped)) {
-		kfree_skb(skb);
-		return 1;
-	}
-
-	return 0;
-}
-
 int netpoll_parse_options(struct netpoll *np, char *opt)
 {
 	char *cur=opt, *delim;
@@ -631,7 +323,6 @@ int netpoll_setup(struct netpoll *np)
 	struct net_device *ndev = NULL;
 	struct in_device *in_dev;
 	struct netpoll_info *npinfo;
-	unsigned long flags;
 	int err;
 
 	if (np->dev_name)
@@ -650,13 +341,6 @@ int netpoll_setup(struct netpoll *np)
 			goto release;
 		}
 
-		npinfo->rx_flags = 0;
-		npinfo->rx_np = NULL;
-		spin_lock_init(&npinfo->poll_lock);
-		npinfo->poll_owner = -1;
-
-		spin_lock_init(&npinfo->rx_lock);
-		skb_queue_head_init(&npinfo->arp_tx);
 		skb_queue_head_init(&npinfo->txq);
 		INIT_DELAYED_WORK(&npinfo->tx_work, queue_process);
 
@@ -735,13 +419,6 @@ int netpoll_setup(struct netpoll *np)
 		       np->name, HIPQUAD(np->local_ip));
 	}
 
-	if (np->rx_hook) {
-		spin_lock_irqsave(&npinfo->rx_lock, flags);
-		npinfo->rx_flags |= NETPOLL_RX_ENABLED;
-		npinfo->rx_np = np;
-		spin_unlock_irqrestore(&npinfo->rx_lock, flags);
-	}
-
 	/* fill up the skb queue */
 	refill_skbs();
 
@@ -771,20 +448,11 @@ core_initcall(netpoll_init);
 void netpoll_cleanup(struct netpoll *np)
 {
 	struct netpoll_info *npinfo;
-	unsigned long flags;
 
 	if (np->dev) {
 		npinfo = np->dev->npinfo;
 		if (npinfo) {
-			if (npinfo->rx_np == np) {
-				spin_lock_irqsave(&npinfo->rx_lock, flags);
-				npinfo->rx_np = NULL;
-				npinfo->rx_flags &= ~NETPOLL_RX_ENABLED;
-				spin_unlock_irqrestore(&npinfo->rx_lock, flags);
-			}
-
 			if (atomic_dec_and_test(&npinfo->refcnt)) {
-				skb_queue_purge(&npinfo->arp_tx);
 				skb_queue_purge(&npinfo->txq);
 				cancel_rearming_delayed_work(&npinfo->tx_work);
 
@@ -805,23 +473,7 @@ void netpoll_cleanup(struct netpoll *np)
 	np->dev = NULL;
 }
 
-int netpoll_trap(void)
-{
-	return atomic_read(&trapped);
-}
-
-void netpoll_set_trap(int trap)
-{
-	if (trap)
-		atomic_inc(&trapped);
-	else
-		atomic_dec(&trapped);
-}
-
-EXPORT_SYMBOL(netpoll_set_trap);
-EXPORT_SYMBOL(netpoll_trap);
 EXPORT_SYMBOL(netpoll_parse_options);
 EXPORT_SYMBOL(netpoll_setup);
 EXPORT_SYMBOL(netpoll_cleanup);
 EXPORT_SYMBOL(netpoll_send_udp);
-EXPORT_SYMBOL(netpoll_poll);
