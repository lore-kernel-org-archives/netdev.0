From: "Eric Lemoine" <eric.lemoine@gmail.com>
Subject: Re: [patch sungem] improved locking
Date: Mon, 13 Nov 2006 00:11:49 +0100
Message-ID: <5cac192f0611121511w6a8fec54pdf6124b5f2f79a08@mail.gmail.com>
References: <5cac192f0611091333w5740810bhe1966d6391c6d46a@mail.gmail.com>
	 <20061109.150436.94557169.davem@davemloft.net>
	 <5cac192f0611100528r4a53498emc8d866955cc36c8d@mail.gmail.com>
	 <20061110.124246.41636039.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_16288_1066592.1163373109053"
Cc: netdev@vger.kernel.org, benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:39774 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1753482AbWKLXLv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Nov 2006 18:11:51 -0500
Received: by nf-out-0910.google.com with SMTP id o25so1977631nfa
        for <netdev@vger.kernel.org>; Sun, 12 Nov 2006 15:11:49 -0800 (PST)
To: "David Miller" <davem@davemloft.net>
In-Reply-To: <20061110.124246.41636039.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_16288_1066592.1163373109053
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

> I think the second way is better because it clearly states
> your intentions.  The GREG_STAT_IACK 0x3f macro is still
> "magic" because it doesn't say what the bits actually mean.

New patch attached.

And provided inline for people to comment.

Signed-off-by: Eric Lemoine <eric.lemoine@gmail.com>

diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index 253e96e..31bd90d 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -9,26 +9,6 @@
  *
  * NAPI and NETPOLL support
  * (C) 2004 by Eric Lemoine (eric.lemoine@gmail.com)
- *
- * TODO:
- *  - Now that the driver was significantly simplified, I need to rework
- *    the locking. I'm sure we don't need _2_ spinlocks, and we probably
- *    can avoid taking most of them for so long period of time (and schedule
- *    instead). The main issues at this point are caused by the netdev layer
- *    though:
- *
- *    gem_change_mtu() and gem_set_multicast() are called with a read_lock()
- *    help by net/core/dev.c, thus they can't schedule. That means they can't
- *    call netif_poll_disable() neither, thus force gem_poll() to
keep a spinlock
- *    where it could have been dropped. change_mtu especially would
love also to
- *    be able to msleep instead of horrid locked delays when resetting the HW,
- *    but that read_lock() makes it impossible, unless I defer it's action to
- *    the reset task, which means it'll be asynchronous (won't take
effect until
- *    the system schedules a bit).
- *
- *    Also, it would probably be possible to also remove most of the long-life
- *    locking in open/resume code path (gem_reinit_chip) by beeing more careful
- *    about when we can start taking interrupts or get xmit() called...
  */

 #include <linux/module.h>
@@ -206,11 +186,18 @@ static inline void phy_write(struct gem
 	__phy_write(gp, gp->mii_phy_addr, reg, val);
 }

-static inline void gem_enable_ints(struct gem *gp)
+static inline void __gem_enable_ints(struct gem *gp)
 {
-	/* Enable all interrupts but TXDONE */
+	/* Enable all interrupts, but TXDONE */
 	writel(GREG_STAT_TXDONE, gp->regs + GREG_IMASK);
 }
+	
+static inline void gem_enable_ints(struct gem *gp)
+{
+	gp->irq_sync = 0;
+	wmb();
+	__gem_enable_ints(gp);
+}

 static inline void gem_disable_ints(struct gem *gp)
 {
@@ -218,6 +205,60 @@ static inline void gem_disable_ints(stru
 	writel(GREG_STAT_NAPI | GREG_STAT_TXDONE, gp->regs + GREG_IMASK);
 }

+#if GEM_INTERRUPT_LOCKLESS
+static inline u32 gem_read_status2(struct gem *gp)
+{
+	return readl(gp->regs + GREG_STAT2);
+}
+
+static inline void gem_ack_int(struct gem *gp)
+{
+	writel(GREG_STAT_IACK, gp->regs + GREG_IACK);
+}
+
+#else
+static inline u32 gem_read_status(struct gem *gp)
+{
+	return readl(gp->regs + GREG_STAT);
+}
+#endif
+
+static inline void gem_netif_stop(struct gem *gp)
+{
+	struct net_device *dev = gp->dev;
+
+	dev->trans_start = jiffies; /* prevent tx timeout */
+	netif_poll_disable(dev);
+	netif_tx_disable(dev);
+}
+
+static inline void gem_netif_start(struct gem *gp)
+{
+	struct net_device *dev = gp->dev;
+
+	/* Unconditionnaly netif_wake_queue is ok so long as caller has
+	 * freed tx slots, whis done in gem_reinit_chip().
+	 */
+	netif_wake_queue(dev);
+	netif_poll_enable(dev);
+}
+
+static inline void gem_schedule_reset_task(struct gem *gp)
+{
+	gp->reset_task_pending = 1;
+	smp_mb();
+	schedule_work(&gp->reset_task);
+}
+
+static inline void gem_wait_reset_task(struct gem *gp)
+{
+	mb();
+	while (gp->reset_task_pending) {
+		yield();
+		mb();
+	}
+}
+
 static void gem_get_cell(struct gem *gp)
 {
 	BUG_ON(gp->cell_enabled < 0);
@@ -658,12 +699,20 @@ static int gem_abnormal_irq(struct net_d
 	return 0;

 do_reset:
-	gp->reset_task_pending = 1;
-	schedule_work(&gp->reset_task);
+	gem_schedule_reset_task(gp);

 	return 1;
 }

+static inline u32 gem_tx_avail(struct gem *gp)
+{
+	smp_mb();
+	return (gp->tx_old <= gp->tx_new) ?
+		gp->tx_old + (TX_RING_SIZE - 1) - gp->tx_new :
+		gp->tx_old - gp->tx_new - 1;
+}
+
+
 static __inline__ void gem_tx(struct net_device *dev, struct gem *gp,
u32 gem_status)
 {
 	int entry, limit;
@@ -717,11 +766,20 @@ static __inline__ void gem_tx(struct net
 		gp->net_stats.tx_packets++;
 		dev_kfree_skb_irq(skb);
 	}
+
 	gp->tx_old = entry;

-	if (netif_queue_stopped(dev) &&
-	    TX_BUFFS_AVAIL(gp) > (MAX_SKB_FRAGS + 1))
-		netif_wake_queue(dev);
+	/* Need to make tx_old update visible to gem_start_xmit() */
+	smp_mb();
+
+	if (unlikely(netif_queue_stopped(dev) &&
+	    gem_tx_avail(gp) > (MAX_SKB_FRAGS + 1))) {
+		netif_tx_lock(dev);
+		if (netif_queue_stopped(dev) &&
+	    	    gem_tx_avail(gp) > (MAX_SKB_FRAGS + 1))
+			netif_wake_queue(dev);
+		netif_tx_unlock(dev);
+	}
 }

 static __inline__ void gem_post_rxds(struct gem *gp, int limit)
@@ -882,12 +940,6 @@ static int gem_rx(struct gem *gp, int wo
 static int gem_poll(struct net_device *dev, int *budget)
 {
 	struct gem *gp = dev->priv;
-	unsigned long flags;
-
-	/*
-	 * NAPI locking nightmare: See comment at head of driver
-	 */
-	spin_lock_irqsave(&gp->lock, flags);

 	do {
 		int work_to_do, work_done;
@@ -899,19 +951,10 @@ static int gem_poll(struct net_device *d
 		}

 		/* Run TX completion thread */
-		spin_lock(&gp->tx_lock);
 		gem_tx(dev, gp, gp->status);
-		spin_unlock(&gp->tx_lock);
-
-		spin_unlock_irqrestore(&gp->lock, flags);

-		/* Run RX thread. We don't use any locking here,
-		 * code willing to do bad things - like cleaning the
-		 * rx ring - must call netif_poll_disable(), which
-		 * schedule_timeout()'s if polling is already disabled.
-		 */
+		/* Run RX thread */
 		work_to_do = min(*budget, dev->quota);
-
 		work_done = gem_rx(gp, work_to_do);

 		*budget -= work_done;
@@ -920,23 +963,57 @@ static int gem_poll(struct net_device *d
 		if (work_done >= work_to_do)
 			return 1;

-		spin_lock_irqsave(&gp->lock, flags);
-
 		gp->status = readl(gp->regs + GREG_STAT);
 	} while (gp->status & GREG_STAT_NAPI);

 	__netif_rx_complete(dev);
-	gem_enable_ints(gp);
+	__gem_enable_ints(gp);

-	spin_unlock_irqrestore(&gp->lock, flags);
 	return 0;
 }

+static void gem_irq_quiesce(struct gem *gp)
+{
+	BUG_ON(gp->irq_sync);
+
+	gp->irq_sync = 1;
+	smp_mb();
+
+	synchronize_irq(gp->pdev->irq);
+}
+
+static inline int gem_irq_sync(struct gem *gp)
+{
+	return gp->irq_sync;
+}
+
+static inline void gem_full_lock(struct gem *gp, int irq_sync)
+{
+	spin_lock_bh(&gp->lock);
+	if (irq_sync)
+		gem_irq_quiesce(gp);
+}
+
+static inline void gem_full_unlock(struct gem *gp)
+{
+	spin_unlock_bh(&gp->lock);
+}
+
+#if GEM_INTERRUPT_LOCKLESS
+
+/* Lockless implementation of IRQ handler.
+ *
+ * The downside of this implementation is that it requires three PIO
+ * operations: read status, disable interrupts and ack interrupt.
+ *
+ * Also, this implementation may not work with NET_POLL_CONTROLLER.
+ * TODO: need further investigation.
+ */
 static irqreturn_t gem_interrupt(int irq, void *dev_id)
 {
 	struct net_device *dev = dev_id;
 	struct gem *gp = dev->priv;
-	unsigned long flags;
+	u32 gem_status;

 	/* Swallow interrupts when shutting the chip down, though
 	 * that shouldn't happen, we should have done free_irq() at
@@ -945,29 +1022,70 @@ static irqreturn_t gem_interrupt(int irq
 	if (!gp->running)
 		return IRQ_HANDLED;

-	spin_lock_irqsave(&gp->lock, flags);
+	gem_status = gem_read_status2(gp);
+	if (unlikely(!gem_status)) /* shared irq? */
+		return IRQ_NONE;

 	if (netif_rx_schedule_prep(dev)) {
-		u32 gem_status = readl(gp->regs + GREG_STAT);
+		gem_disable_ints(gp);
+		gem_ack_int(gp);

-		if (gem_status == 0) {
+		if (gem_irq_sync(gp)) {
+			/* We are sure that *we* disabled polling, so we can
+			 * safely reenable it before returning.
+			 */
 			netif_poll_enable(dev);
-			spin_unlock_irqrestore(&gp->lock, flags);
-			return IRQ_NONE;
+			return IRQ_HANDLED;
 		}
+
 		gp->status = gem_status;
-		gem_disable_ints(gp);
 		__netif_rx_schedule(dev);
 	}

-	spin_unlock_irqrestore(&gp->lock, flags);
+	return IRQ_HANDLED;
+}
+#else
+static irqreturn_t gem_interrupt(int irq, void *dev_id)
+{
+	struct net_device *dev = dev_id;
+	struct gem *gp = dev->priv;
+	unsigned int handled = 1;
+	unsigned long flags;

-	/* If polling was disabled at the time we received that
-	 * interrupt, we may return IRQ_HANDLED here while we
-	 * should return IRQ_NONE. No big deal...
+	/* Swallow interrupts when shutting the chip down, though
+	 * that shouldn't happen, we should have done free_irq() at
+	 * this point...
 	 */
+	if (!gp->running)
+		return IRQ_HANDLED;
+
+	spin_lock_irqsave(&gp->int_lock, flags);
+
+	if (netif_rx_schedule_prep(dev)) {
+		u32 gem_status = gem_read_status(gp);
+
+		if (unlikely(!gem_status)) {
+			netif_poll_enable(dev);
+			handled = 0;
+			goto out;
+		}
+
+		gem_disable_ints(gp);
+
+		if (gem_irq_sync(gp)) {
+			netif_poll_enable(dev);
+			goto out;
+		}
+
+		gp->status = gem_status;
+		__netif_rx_schedule(dev);
+	}
+
+out:
+	spin_unlock_irqrestore(&gp->int_lock, flags);
 	return IRQ_HANDLED;
 }
+#endif

 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void gem_poll_controller(struct net_device *dev)
@@ -999,14 +1117,8 @@ static void gem_tx_timeout(struct net_de
 	       readl(gp->regs + MAC_RXSTAT),
 	       readl(gp->regs + MAC_RXCFG));

-	spin_lock_irq(&gp->lock);
-	spin_lock(&gp->tx_lock);
-
-	gp->reset_task_pending = 1;
-	schedule_work(&gp->reset_task);
-
-	spin_unlock(&gp->tx_lock);
-	spin_unlock_irq(&gp->lock);
+	printk(KERN_INFO "%s: gem_tx_timeout\n", dev->name);
+	gem_schedule_reset_task(gp);
 }

 static __inline__ int gem_intme(int entry)
@@ -1023,7 +1135,6 @@ static int gem_start_xmit(struct sk_buff
 	struct gem *gp = dev->priv;
 	int entry;
 	u64 ctrl;
-	unsigned long flags;

 	ctrl = 0;
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
@@ -1037,24 +1148,13 @@ static int gem_start_xmit(struct sk_buff
 			(csum_stuff_off << 21));
 	}

-	local_irq_save(flags);
-	if (!spin_trylock(&gp->tx_lock)) {
-		/* Tell upper layer to requeue */
-		local_irq_restore(flags);
-		return NETDEV_TX_LOCKED;
-	}
-	/* We raced with gem_do_stop() */
-	if (!gp->running) {
-		spin_unlock_irqrestore(&gp->tx_lock, flags);
-		return NETDEV_TX_BUSY;
-	}
-
 	/* This is a hard error, log it. */
-	if (TX_BUFFS_AVAIL(gp) <= (skb_shinfo(skb)->nr_frags + 1)) {
-		netif_stop_queue(dev);
-		spin_unlock_irqrestore(&gp->tx_lock, flags);
-		printk(KERN_ERR PFX "%s: BUG! Tx Ring full when queue awake!\n",
-		       dev->name);
+	if (gem_tx_avail(gp) <= (skb_shinfo(skb)->nr_frags + 1)) {
+		if (!netif_queue_stopped(dev)) {
+			netif_stop_queue(dev);
+			printk(KERN_ERR PFX "%s: BUG! Tx Ring full when "
+			       "queue awake!\n", dev->name);
+		}
 		return NETDEV_TX_BUSY;
 	}

@@ -1131,15 +1231,17 @@ static int gem_start_xmit(struct sk_buff
 	}

 	gp->tx_new = entry;
-	if (TX_BUFFS_AVAIL(gp) <= (MAX_SKB_FRAGS + 1))
+	if (unlikely(gem_tx_avail(gp) <= (MAX_SKB_FRAGS + 1))) {
 		netif_stop_queue(dev);
+		if (gem_tx_avail(gp) > (MAX_SKB_FRAGS + 1))
+			netif_wake_queue(dev);
+	}

 	if (netif_msg_tx_queued(gp))
 		printk(KERN_DEBUG "%s: tx queued, slot %d, skblen %d\n",
 		       dev->name, entry, skb->len);
 	mb();
 	writel(gp->tx_new, gp->regs + TXDMA_KICK);
-	spin_unlock_irqrestore(&gp->tx_lock, flags);

 	dev->trans_start = jiffies;

@@ -1148,7 +1250,6 @@ static int gem_start_xmit(struct sk_buff

 #define STOP_TRIES 32

-/* Must be invoked under gp->lock and gp->tx_lock. */
 static void gem_reset(struct gem *gp)
 {
 	int limit;
@@ -1174,7 +1275,6 @@ static void gem_reset(struct gem *gp)
 		printk(KERN_ERR "%s: SW reset is ghetto.\n", gp->dev->name);
 }

-/* Must be invoked under gp->lock and gp->tx_lock. */
 static void gem_start_dma(struct gem *gp)
 {
 	u32 val;
@@ -1197,9 +1297,7 @@ static void gem_start_dma(struct gem *gp
 	writel(RX_RING_SIZE - 4, gp->regs + RXDMA_KICK);
 }

-/* Must be invoked under gp->lock and gp->tx_lock. DMA won't be
- * actually stopped before about 4ms tho ...
- */
+/* DMA won't be actually stopped before about 4ms tho ... */
 static void gem_stop_dma(struct gem *gp)
 {
 	u32 val;
@@ -1220,8 +1318,7 @@ static void gem_stop_dma(struct gem *gp)
 }


-/* Must be invoked under gp->lock and gp->tx_lock. */
-// XXX dbl check what that function should do when called on PCS PHY
+/* XXX dbl check what that function should do when called on PCS PHY */
 static void gem_begin_auto_negotiation(struct gem *gp, struct ethtool_cmd *ep)
 {
 	u32 advertise, features;
@@ -1306,8 +1403,6 @@ non_mii:

 /* A link-up condition has occurred, initialize and enable the
  * rest of the chip.
- *
- * Must be invoked under gp->lock and gp->tx_lock.
  */
 static int gem_set_link_modes(struct gem *gp)
 {
@@ -1417,7 +1512,6 @@ static int gem_set_link_modes(struct gem
 	return 0;
 }

-/* Must be invoked under gp->lock and gp->tx_lock. */
 static int gem_mdio_link_not_up(struct gem *gp)
 {
 	switch (gp->lstate) {
@@ -1474,13 +1568,13 @@ static void gem_link_timer(unsigned long
 	if (gp->asleep)
 		return;

-	spin_lock_irq(&gp->lock);
-	spin_lock(&gp->tx_lock);
+	gem_full_lock(gp, 0);
 	gem_get_cell(gp);

 	/* If the reset task is still pending, we just
 	 * reschedule the link timer
 	 */
+	smp_mb();
 	if (gp->reset_task_pending)
 		goto restart;

@@ -1528,8 +1622,7 @@ static void gem_link_timer(unsigned long
 				printk(KERN_INFO "%s: Link down\n",
 					gp->dev->name);
 			netif_carrier_off(gp->dev);
-			gp->reset_task_pending = 1;
-			schedule_work(&gp->reset_task);
+			gem_schedule_reset_task(gp);
 			restart_aneg = 1;
 		} else if (++gp->timer_ticks > 10) {
 			if (found_mii_phy(gp))
@@ -1546,11 +1639,9 @@ restart:
 	mod_timer(&gp->link_timer, jiffies + ((12 * HZ) / 10));
 out_unlock:
 	gem_put_cell(gp);
-	spin_unlock(&gp->tx_lock);
-	spin_unlock_irq(&gp->lock);
+	gem_full_unlock(gp);
 }

-/* Must be invoked under gp->lock and gp->tx_lock. */
 static void gem_clean_rings(struct gem *gp)
 {
 	struct gem_init_block *gb = gp->init_block;
@@ -1601,7 +1692,6 @@ static void gem_clean_rings(struct gem *
 	}
 }

-/* Must be invoked under gp->lock and gp->tx_lock. */
 static void gem_init_rings(struct gem *gp)
 {
 	struct gem_init_block *gb = gp->init_block;
@@ -1775,12 +1865,9 @@ static void gem_init_phy(struct gem *gp)
 	netif_carrier_off(gp->dev);

 	/* Can I advertise gigabit here ? I'd need BCM PHY docs... */
-	spin_lock_irq(&gp->lock);
 	gem_begin_auto_negotiation(gp, NULL);
-	spin_unlock_irq(&gp->lock);
 }

-/* Must be invoked under gp->lock and gp->tx_lock. */
 static void gem_init_dma(struct gem *gp)
 {
 	u64 desc_dma = (u64) gp->gblock_dvma;
@@ -1818,7 +1905,6 @@ static void gem_init_dma(struct gem *gp)
 		       gp->regs + RXDMA_BLANK);
 }

-/* Must be invoked under gp->lock and gp->tx_lock. */
 static u32 gem_setup_multicast(struct gem *gp)
 {
 	u32 rxcfg = 0;
@@ -1860,7 +1946,6 @@ static u32 gem_setup_multicast(struct ge
 	return rxcfg;
 }

-/* Must be invoked under gp->lock and gp->tx_lock. */
 static void gem_init_mac(struct gem *gp)
 {
 	unsigned char *e = &gp->dev->dev_addr[0];
@@ -1943,7 +2028,6 @@ static void gem_init_mac(struct gem *gp)
 		writel(0, gp->regs + WOL_WAKECSR);
 }

-/* Must be invoked under gp->lock and gp->tx_lock. */
 static void gem_init_pause_thresholds(struct gem *gp)
 {
        	u32 cfg;
@@ -2096,7 +2180,6 @@ static int gem_check_invariants(struct g
 	return 0;
 }

-/* Must be invoked under gp->lock and gp->tx_lock. */
 static void gem_reinit_chip(struct gem *gp)
 {
 	/* Reset the chip */
@@ -2116,12 +2199,10 @@ static void gem_reinit_chip(struct gem *
 	gem_init_mac(gp);
 }

-
 /* Must be invoked with no lock held. */
 static void gem_stop_phy(struct gem *gp, int wol)
 {
 	u32 mifcfg;
-	unsigned long flags;

 	/* Let the chip settle down a bit, it seems that helps
 	 * for sleep mode on some models
@@ -2167,13 +2248,13 @@ static void gem_stop_phy(struct gem *gp,
 	writel(0, gp->regs + RXDMA_CFG);

 	if (!wol) {
-		spin_lock_irqsave(&gp->lock, flags);
-		spin_lock(&gp->tx_lock);
+		gem_full_lock(gp, 0);
+
 		gem_reset(gp);
 		writel(MAC_TXRST_CMD, gp->regs + MAC_TXRST);
 		writel(MAC_RXRST_CMD, gp->regs + MAC_RXRST);
-		spin_unlock(&gp->tx_lock);
-		spin_unlock_irqrestore(&gp->lock, flags);
+
+		gem_full_unlock(gp);

 		/* No need to take the lock here */

@@ -2192,14 +2273,11 @@ static void gem_stop_phy(struct gem *gp,
 	}
 }

-
 static int gem_do_start(struct net_device *dev)
 {
 	struct gem *gp = dev->priv;
-	unsigned long flags;

-	spin_lock_irqsave(&gp->lock, flags);
-	spin_lock(&gp->tx_lock);
+	gem_full_lock(gp, 0);

 	/* Enable the cell */
 	gem_get_cell(gp);
@@ -2211,28 +2289,25 @@ static int gem_do_start(struct net_devic

 	if (gp->lstate == link_up) {
 		netif_carrier_on(gp->dev);
+		/* gem_set_link_modes starts DMA and enabled ints */
 		gem_set_link_modes(gp);
 	}

-	netif_wake_queue(gp->dev);
-
-	spin_unlock(&gp->tx_lock);
-	spin_unlock_irqrestore(&gp->lock, flags);
+	gem_full_unlock(gp);

 	if (request_irq(gp->pdev->irq, gem_interrupt,
-				   IRQF_SHARED, dev->name, (void *)dev)) {
+		        IRQF_SHARED, dev->name, (void *)dev)) {
+
 		printk(KERN_ERR "%s: failed to request irq !\n", gp->dev->name);

-		spin_lock_irqsave(&gp->lock, flags);
-		spin_lock(&gp->tx_lock);
+		gem_full_lock(gp, 0);

 		gp->running =  0;
 		gem_reset(gp);
 		gem_clean_rings(gp);
 		gem_put_cell(gp);

-		spin_unlock(&gp->tx_lock);
-		spin_unlock_irqrestore(&gp->lock, flags);
+		gem_full_unlock(gp);

 		return -EAGAIN;
 	}
@@ -2243,22 +2318,14 @@ static int gem_do_start(struct net_devic
 static void gem_do_stop(struct net_device *dev, int wol)
 {
 	struct gem *gp = dev->priv;
-	unsigned long flags;
-
-	spin_lock_irqsave(&gp->lock, flags);
-	spin_lock(&gp->tx_lock);
-
-	gp->running = 0;
-
-	/* Stop netif queue */
-	netif_stop_queue(dev);

-	/* Make sure ints are disabled */
+	gem_full_lock(gp, 1);
 	gem_disable_ints(gp);
+	
+	gp->running = 0;

-	/* We can drop the lock now */
-	spin_unlock(&gp->tx_lock);
-	spin_unlock_irqrestore(&gp->lock, flags);
+	/* We can drop the lock now that running is set to 0 */
+	gem_full_unlock(gp);

 	/* If we are going to sleep with WOL */
 	gem_stop_dma(gp);
@@ -2275,9 +2342,9 @@ static void gem_do_stop(struct net_devic

 	/* Cell not needed neither if no WOL */
 	if (!wol) {
-		spin_lock_irqsave(&gp->lock, flags);
+		gem_full_lock(gp, 0);
 		gem_put_cell(gp);
-		spin_unlock_irqrestore(&gp->lock, flags);
+		gem_full_unlock(gp);
 	}
 }

@@ -2287,30 +2354,26 @@ static void gem_reset_task(void *data)

 	mutex_lock(&gp->pm_mutex);

-	netif_poll_disable(gp->dev);
-
-	spin_lock_irq(&gp->lock);
-	spin_lock(&gp->tx_lock);
+	gem_full_lock(gp, 1);
+	gem_disable_ints(gp);

 	if (gp->running == 0)
 		goto not_running;

-	if (gp->running) {
-		netif_stop_queue(gp->dev);
+	gem_netif_stop(gp);

-		/* Reset the chip & rings */
-		gem_reinit_chip(gp);
-		if (gp->lstate == link_up)
-			gem_set_link_modes(gp);
-		netif_wake_queue(gp->dev);
-	}
- not_running:
-	gp->reset_task_pending = 0;
+	/* Reset the chip & rings */
+	gem_reinit_chip(gp);
+	if (gp->lstate == link_up)
+		gem_set_link_modes(gp);

-	spin_unlock(&gp->tx_lock);
-	spin_unlock_irq(&gp->lock);
+	gem_netif_start(gp);

-	netif_poll_enable(gp->dev);
+not_running:
+	gp->reset_task_pending = 0;
+
+	gem_enable_ints(gp);
+	gem_full_unlock(gp);

 	mutex_unlock(&gp->pm_mutex);
 }
@@ -2324,8 +2387,12 @@ static int gem_open(struct net_device *d
 	mutex_lock(&gp->pm_mutex);

 	/* We need the cell enabled */
-	if (!gp->asleep)
+	if (!gp->asleep) {
 		rc = gem_do_start(dev);
+		if (rc == 0)
+			netif_start_queue(dev);
+	}
+
 	gp->opened = (rc == 0);

 	mutex_unlock(&gp->pm_mutex);
@@ -2337,15 +2404,14 @@ static int gem_close(struct net_device *
 {
 	struct gem *gp = dev->priv;

-	/* Note: we don't need to call netif_poll_disable() here because
-	 * our caller (dev_close) already did it for us
-	 */
-
 	mutex_lock(&gp->pm_mutex);

 	gp->opened = 0;
-	if (!gp->asleep)
+	if (!gp->asleep) {
+		/* Upper layer took care of disabling polling */
+		netif_stop_queue(dev);
 		gem_do_stop(dev, 0);
+	}

 	mutex_unlock(&gp->pm_mutex);

@@ -2357,22 +2423,17 @@ static int gem_suspend(struct pci_dev *p
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct gem *gp = dev->priv;
-	unsigned long flags;

 	mutex_lock(&gp->pm_mutex);

-	netif_poll_disable(dev);
-
 	printk(KERN_INFO "%s: suspending, WakeOnLan %s\n",
 	       dev->name,
 	       (gp->wake_on_lan && gp->opened) ? "enabled" : "disabled");

 	/* Keep the cell enabled during the entire operation */
-	spin_lock_irqsave(&gp->lock, flags);
-	spin_lock(&gp->tx_lock);
+	gem_full_lock(gp, 0);
 	gem_get_cell(gp);
-	spin_unlock(&gp->tx_lock);
-	spin_unlock_irqrestore(&gp->lock, flags);
+	gem_full_unlock(gp);

 	/* If the driver is opened, we stop the MAC */
 	if (gp->opened) {
@@ -2381,6 +2442,7 @@ static int gem_suspend(struct pci_dev *p

 		/* Switch off MAC, remember WOL setting */
 		gp->asleep_wol = gp->wake_on_lan;
+		gem_netif_stop(gp);
 		gem_do_stop(dev, gp->asleep_wol);
 	} else
 		gp->asleep_wol = 0;
@@ -2399,8 +2461,7 @@ static int gem_suspend(struct pci_dev *p
 	mutex_unlock(&gp->pm_mutex);

 	/* Wait for a pending reset task to complete */
-	while (gp->reset_task_pending)
-		yield();
+	gem_wait_reset_task(gp);
 	flush_scheduled_work();

 	/* Shut the PHY down eventually and setup WOL */
@@ -2421,7 +2482,6 @@ static int gem_resume(struct pci_dev *pd
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct gem *gp = dev->priv;
-	unsigned long flags;

 	printk(KERN_INFO "%s: resuming\n", dev->name);

@@ -2465,11 +2525,9 @@ static int gem_resume(struct pci_dev *pd

 		/* Re-attach net device */
 		netif_device_attach(dev);
-
 	}

-	spin_lock_irqsave(&gp->lock, flags);
-	spin_lock(&gp->tx_lock);
+	gem_full_lock(gp, 0);

 	/* If we had WOL enabled, the cell clock was never turned off during
 	 * sleep, so we end up beeing unbalanced. Fix that here
@@ -2482,10 +2540,9 @@ static int gem_resume(struct pci_dev *pd
 	 */
 	gem_put_cell(gp);

-	spin_unlock(&gp->tx_lock);
-	spin_unlock_irqrestore(&gp->lock, flags);
+	gem_full_unlock(gp);

-	netif_poll_enable(dev);
+	gem_netif_start(gp);

 	mutex_unlock(&gp->pm_mutex);

@@ -2498,8 +2555,8 @@ static struct net_device_stats *gem_get_
 	struct gem *gp = dev->priv;
 	struct net_device_stats *stats = &gp->net_stats;

-	spin_lock_irq(&gp->lock);
-	spin_lock(&gp->tx_lock);
+	gem_netif_stop(gp);
+	gem_full_lock(gp, 0);

 	/* I have seen this being called while the PM was in progress,
 	 * so we shield against this
@@ -2522,27 +2579,26 @@ static struct net_device_stats *gem_get_
 		writel(0, gp->regs + MAC_LCOLL);
 	}

-	spin_unlock(&gp->tx_lock);
-	spin_unlock_irq(&gp->lock);
+	gem_full_unlock(gp);
+	gem_netif_start(gp);

 	return &gp->net_stats;
 }

+/* gem_set_multicast is called with netif_tx_lock held. Thus, it
+ * cannot sleep.
+ */
 static void gem_set_multicast(struct net_device *dev)
 {
 	struct gem *gp = dev->priv;
 	u32 rxcfg, rxcfg_new;
 	int limit = 10000;

-
-	spin_lock_irq(&gp->lock);
-	spin_lock(&gp->tx_lock);
+	gem_full_lock(gp, 0);

 	if (!gp->running)
 		goto bail;

-	netif_stop_queue(dev);
-
 	rxcfg = readl(gp->regs + MAC_RXCFG);
 	rxcfg_new = gem_setup_multicast(gp);
 #ifdef STRIP_FCS
@@ -2562,11 +2618,8 @@ static void gem_set_multicast(struct net

 	writel(rxcfg, gp->regs + MAC_RXCFG);

-	netif_wake_queue(dev);
-
  bail:
-	spin_unlock(&gp->tx_lock);
-	spin_unlock_irq(&gp->lock);
+	gem_full_unlock(gp);
 }

 /* Jumbo-grams don't seem to work :-( */
@@ -2593,16 +2646,22 @@ static int gem_change_mtu(struct net_dev
 	}

 	mutex_lock(&gp->pm_mutex);
-	spin_lock_irq(&gp->lock);
-	spin_lock(&gp->tx_lock);
+
+	gem_netif_stop(gp);
+	gem_full_lock(gp, 1);
+	gem_disable_ints(gp);
+	
 	dev->mtu = new_mtu;
 	if (gp->running) {
 		gem_reinit_chip(gp);
 		if (gp->lstate == link_up)
 			gem_set_link_modes(gp);
 	}
-	spin_unlock(&gp->tx_lock);
-	spin_unlock_irq(&gp->lock);
+
+	gem_netif_start(gp);
+	gem_enable_ints(gp);
+	gem_full_unlock(gp);
+
 	mutex_unlock(&gp->pm_mutex);

 	return 0;
@@ -2635,7 +2694,7 @@ static int gem_get_settings(struct net_d
 		cmd->phy_address = 0; /* XXX fixed PHYAD */

 		/* Return current PHY settings */
-		spin_lock_irq(&gp->lock);
+		gem_full_lock(gp, 0);
 		cmd->autoneg = gp->want_autoneg;
 		cmd->speed = gp->phy_mii.speed;
 		cmd->duplex = gp->phy_mii.duplex;
@@ -2647,7 +2706,7 @@ static int gem_get_settings(struct net_d
 		 */
 		if (cmd->advertising == 0)
 			cmd->advertising = cmd->supported;
-		spin_unlock_irq(&gp->lock);
+		gem_full_unlock(gp);
 	} else { // XXX PCS ?
 		cmd->supported =
 			(SUPPORTED_10baseT_Half | SUPPORTED_10baseT_Full |
@@ -2685,11 +2744,11 @@ static int gem_set_settings(struct net_d
 		return -EINVAL;

 	/* Apply settings and restart link process. */
-	spin_lock_irq(&gp->lock);
+	gem_full_lock(gp, 0);
 	gem_get_cell(gp);
 	gem_begin_auto_negotiation(gp, cmd);
 	gem_put_cell(gp);
-	spin_unlock_irq(&gp->lock);
+	gem_full_unlock(gp);

 	return 0;
 }
@@ -2702,11 +2761,11 @@ static int gem_nway_reset(struct net_dev
 		return -EINVAL;

 	/* Restart link process. */
-	spin_lock_irq(&gp->lock);
+	gem_full_lock(gp, 0);
 	gem_get_cell(gp);
 	gem_begin_auto_negotiation(gp, NULL);
 	gem_put_cell(gp);
-	spin_unlock_irq(&gp->lock);
+	gem_full_unlock(gp);

 	return 0;
 }
@@ -2770,16 +2829,15 @@ static int gem_ioctl(struct net_device *
 	struct gem *gp = dev->priv;
 	struct mii_ioctl_data *data = if_mii(ifr);
 	int rc = -EOPNOTSUPP;
-	unsigned long flags;

 	/* Hold the PM mutex while doing ioctl's or we may collide
 	 * with power management.
 	 */
 	mutex_lock(&gp->pm_mutex);

-	spin_lock_irqsave(&gp->lock, flags);
+	gem_full_lock(gp, 0);
 	gem_get_cell(gp);
-	spin_unlock_irqrestore(&gp->lock, flags);
+	gem_full_unlock(gp);

 	switch (cmd) {
 	case SIOCGMIIPHY:		/* Get address of MII PHY in use. */
@@ -2809,9 +2867,9 @@ static int gem_ioctl(struct net_device *
 		break;
 	};

-	spin_lock_irqsave(&gp->lock, flags);
+	gem_full_lock(gp, 0);
 	gem_put_cell(gp);
-	spin_unlock_irqrestore(&gp->lock, flags);
+	gem_full_unlock(gp);

 	mutex_unlock(&gp->pm_mutex);

@@ -2918,6 +2976,7 @@ static void gem_remove_one(struct pci_de
 	if (dev) {
 		struct gem *gp = dev->priv;

+		/* unregister_netdev will close the device if it's open */
 		unregister_netdev(dev);

 		/* Stop the link timer */
@@ -2927,8 +2986,7 @@ static void gem_remove_one(struct pci_de
 		gem_get_cell(gp);

 		/* Wait for a pending reset task to complete */
-		while (gp->reset_task_pending)
-			yield();
+		gem_wait_reset_task(gp);
 		flush_scheduled_work();

 		/* Shut the PHY down */
@@ -3035,8 +3093,11 @@ static int __devinit gem_init_one(struct

 	gp->msg_enable = DEFAULT_MSG;

+	gp->irq_sync = 0;
 	spin_lock_init(&gp->lock);
-	spin_lock_init(&gp->tx_lock);
+#if !GEM_INTERRUPT_LOCKLESS
+	spin_lock_init(&gp->int_lock);
+#endif
 	mutex_init(&gp->pm_mutex);

 	init_timer(&gp->link_timer);
@@ -3132,9 +3193,7 @@ static int __devinit gem_init_one(struct
 	 */
 	gem_init_phy(gp);

-	spin_lock_irq(&gp->lock);
 	gem_put_cell(gp);
-	spin_unlock_irq(&gp->lock);

 	/* Register with kernel */
 	if (register_netdev(dev)) {
@@ -3156,8 +3215,7 @@ static int __devinit gem_init_one(struct
 		printk(KERN_INFO "%s: Found %s PHY\n", dev->name,
 			gp->phy_mii.def ? gp->phy_mii.def->name : "no");

-	/* GEM can do it all... */
-	dev->features |= NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_LLTX;
+	dev->features |= NETIF_F_SG | NETIF_F_HW_CSUM;
 	if (pci_using_dac)
 		dev->features |= NETIF_F_HIGHDMA;

@@ -3177,7 +3235,6 @@ err_out_free_netdev:
 err_disable_device:
 	pci_disable_device(pdev);
 	return err;
-
 }


diff --git a/drivers/net/sungem.h b/drivers/net/sungem.h
index a70067c..c04a320 100644
--- a/drivers/net/sungem.h
+++ b/drivers/net/sungem.h
@@ -7,6 +7,8 @@
 #ifndef _SUNGEM_H
 #define _SUNGEM_H

+#define GEM_INTERRUPT_LOCKLESS 1 /* TODO */
+
 /* Global Registers */
 #define GREG_SEBSTATE	0x0000UL	/* SEB State Register		*/
 #define GREG_CFG	0x0004UL	/* Configuration Register	*/
@@ -60,6 +62,10 @@
 				 GREG_STAT_PCS | GREG_STAT_TXMAC | GREG_STAT_RXMAC | \
 				 GREG_STAT_MAC | GREG_STAT_MIF | GREG_STAT_PCIERR)

+/* Bitmask representing the interrupt conditions the driver handles. The TXDONE
+ * interrupt condition isn't handled as we want to avoid having one interrupt
+ * per transmitted frame.
+ */
 #define GREG_STAT_NAPI		(GREG_STAT_TXALL  | GREG_STAT_TXINTME | \
 				 GREG_STAT_RXDONE | GREG_STAT_ABNORMAL)

@@ -71,6 +77,15 @@
  * on GREG_STAT.
  */

+#if GEM_INTERRUPT_LOCKLESS
+
+/* Bitmask representing the interrupt conditions that we clear using GREG_IACK.
+ * We clear all the top-level interrupt conditions (bits 0 through 6) that we
+ * handle.
+ */
+#define GREG_STAT_IACK		(GREG_STAT_NAPI & 0x3f)
+#endif
+
 /* Global PCI Error Status Register */
 #define GREG_PCIESTAT_BADACK	0x00000001	/* No ACK64# during ABS64 cycle	*/
 #define GREG_PCIESTAT_DTRTO	0x00000002	/* Delayed transaction timeout	*/
@@ -973,8 +988,11 @@ enum link_state {
 };

 struct gem {
+	int			irq_sync;
 	spinlock_t		lock;
-	spinlock_t		tx_lock;
+#if !GEM_INTERRUPT_LOCKLESS
+	spinlock_t		int_lock;
+#endif
 	void __iomem		*regs;
 	int			rx_new, rx_old;
 	int			tx_new, tx_old;


-- 
Eric

------=_Part_16288_1066592.1163373109053
Content-Type: application/octet-stream; name=sungem-locking.patch
Content-Transfer-Encoding: base64
X-Attachment-Id: f_eug2a098
Content-Disposition: attachment; filename="sungem-locking.patch"

ZGlmZiAtLWdpdCBhL2RyaXZlcnMvbmV0L3N1bmdlbS5jIGIvZHJpdmVycy9uZXQvc3VuZ2VtLmMK
aW5kZXggMjUzZTk2ZS4uMzFiZDkwZCAxMDA2NDQKLS0tIGEvZHJpdmVycy9uZXQvc3VuZ2VtLmMK
KysrIGIvZHJpdmVycy9uZXQvc3VuZ2VtLmMKQEAgLTksMjYgKzksNiBAQAogICoKICAqIE5BUEkg
YW5kIE5FVFBPTEwgc3VwcG9ydAogICogKEMpIDIwMDQgYnkgRXJpYyBMZW1vaW5lIChlcmljLmxl
bW9pbmVAZ21haWwuY29tKQotICoKLSAqIFRPRE86Ci0gKiAgLSBOb3cgdGhhdCB0aGUgZHJpdmVy
IHdhcyBzaWduaWZpY2FudGx5IHNpbXBsaWZpZWQsIEkgbmVlZCB0byByZXdvcmsKLSAqICAgIHRo
ZSBsb2NraW5nLiBJJ20gc3VyZSB3ZSBkb24ndCBuZWVkIF8yXyBzcGlubG9ja3MsIGFuZCB3ZSBw
cm9iYWJseQotICogICAgY2FuIGF2b2lkIHRha2luZyBtb3N0IG9mIHRoZW0gZm9yIHNvIGxvbmcg
cGVyaW9kIG9mIHRpbWUgKGFuZCBzY2hlZHVsZQotICogICAgaW5zdGVhZCkuIFRoZSBtYWluIGlz
c3VlcyBhdCB0aGlzIHBvaW50IGFyZSBjYXVzZWQgYnkgdGhlIG5ldGRldiBsYXllcgotICogICAg
dGhvdWdoOgotICoKLSAqICAgIGdlbV9jaGFuZ2VfbXR1KCkgYW5kIGdlbV9zZXRfbXVsdGljYXN0
KCkgYXJlIGNhbGxlZCB3aXRoIGEgcmVhZF9sb2NrKCkKLSAqICAgIGhlbHAgYnkgbmV0L2NvcmUv
ZGV2LmMsIHRodXMgdGhleSBjYW4ndCBzY2hlZHVsZS4gVGhhdCBtZWFucyB0aGV5IGNhbid0Ci0g
KiAgICBjYWxsIG5ldGlmX3BvbGxfZGlzYWJsZSgpIG5laXRoZXIsIHRodXMgZm9yY2UgZ2VtX3Bv
bGwoKSB0byBrZWVwIGEgc3BpbmxvY2sKLSAqICAgIHdoZXJlIGl0IGNvdWxkIGhhdmUgYmVlbiBk
cm9wcGVkLiBjaGFuZ2VfbXR1IGVzcGVjaWFsbHkgd291bGQgbG92ZSBhbHNvIHRvCi0gKiAgICBi
ZSBhYmxlIHRvIG1zbGVlcCBpbnN0ZWFkIG9mIGhvcnJpZCBsb2NrZWQgZGVsYXlzIHdoZW4gcmVz
ZXR0aW5nIHRoZSBIVywKLSAqICAgIGJ1dCB0aGF0IHJlYWRfbG9jaygpIG1ha2VzIGl0IGltcG9z
c2libGUsIHVubGVzcyBJIGRlZmVyIGl0J3MgYWN0aW9uIHRvCi0gKiAgICB0aGUgcmVzZXQgdGFz
aywgd2hpY2ggbWVhbnMgaXQnbGwgYmUgYXN5bmNocm9ub3VzICh3b24ndCB0YWtlIGVmZmVjdCB1
bnRpbAotICogICAgdGhlIHN5c3RlbSBzY2hlZHVsZXMgYSBiaXQpLgotICoKLSAqICAgIEFsc28s
IGl0IHdvdWxkIHByb2JhYmx5IGJlIHBvc3NpYmxlIHRvIGFsc28gcmVtb3ZlIG1vc3Qgb2YgdGhl
IGxvbmctbGlmZQotICogICAgbG9ja2luZyBpbiBvcGVuL3Jlc3VtZSBjb2RlIHBhdGggKGdlbV9y
ZWluaXRfY2hpcCkgYnkgYmVlaW5nIG1vcmUgY2FyZWZ1bAotICogICAgYWJvdXQgd2hlbiB3ZSBj
YW4gc3RhcnQgdGFraW5nIGludGVycnVwdHMgb3IgZ2V0IHhtaXQoKSBjYWxsZWQuLi4KICAqLwog
CiAjaW5jbHVkZSA8bGludXgvbW9kdWxlLmg+CkBAIC0yMDYsMTEgKzE4NiwxOCBAQCBzdGF0aWMg
aW5saW5lIHZvaWQgcGh5X3dyaXRlKHN0cnVjdCBnZW0gCiAJX19waHlfd3JpdGUoZ3AsIGdwLT5t
aWlfcGh5X2FkZHIsIHJlZywgdmFsKTsKIH0KIAotc3RhdGljIGlubGluZSB2b2lkIGdlbV9lbmFi
bGVfaW50cyhzdHJ1Y3QgZ2VtICpncCkKK3N0YXRpYyBpbmxpbmUgdm9pZCBfX2dlbV9lbmFibGVf
aW50cyhzdHJ1Y3QgZ2VtICpncCkKIHsKLQkvKiBFbmFibGUgYWxsIGludGVycnVwdHMgYnV0IFRY
RE9ORSAqLworCS8qIEVuYWJsZSBhbGwgaW50ZXJydXB0cywgYnV0IFRYRE9ORSAqLwogCXdyaXRl
bChHUkVHX1NUQVRfVFhET05FLCBncC0+cmVncyArIEdSRUdfSU1BU0spOwogfQorCQorc3RhdGlj
IGlubGluZSB2b2lkIGdlbV9lbmFibGVfaW50cyhzdHJ1Y3QgZ2VtICpncCkKK3sKKwlncC0+aXJx
X3N5bmMgPSAwOworCXdtYigpOworCV9fZ2VtX2VuYWJsZV9pbnRzKGdwKTsKK30KIAogc3RhdGlj
IGlubGluZSB2b2lkIGdlbV9kaXNhYmxlX2ludHMoc3RydWN0IGdlbSAqZ3ApCiB7CkBAIC0yMTgs
NiArMjA1LDYwIEBAIHN0YXRpYyBpbmxpbmUgdm9pZCBnZW1fZGlzYWJsZV9pbnRzKHN0cnUKIAl3
cml0ZWwoR1JFR19TVEFUX05BUEkgfCBHUkVHX1NUQVRfVFhET05FLCBncC0+cmVncyArIEdSRUdf
SU1BU0spOwogfQogCisjaWYgR0VNX0lOVEVSUlVQVF9MT0NLTEVTUworc3RhdGljIGlubGluZSB1
MzIgZ2VtX3JlYWRfc3RhdHVzMihzdHJ1Y3QgZ2VtICpncCkKK3sKKwlyZXR1cm4gcmVhZGwoZ3At
PnJlZ3MgKyBHUkVHX1NUQVQyKTsKK30KKworc3RhdGljIGlubGluZSB2b2lkIGdlbV9hY2tfaW50
KHN0cnVjdCBnZW0gKmdwKQoreworCXdyaXRlbChHUkVHX1NUQVRfSUFDSywgZ3AtPnJlZ3MgKyBH
UkVHX0lBQ0spOworfQorCisjZWxzZQorc3RhdGljIGlubGluZSB1MzIgZ2VtX3JlYWRfc3RhdHVz
KHN0cnVjdCBnZW0gKmdwKQoreworCXJldHVybiByZWFkbChncC0+cmVncyArIEdSRUdfU1RBVCk7
Cit9CisjZW5kaWYKKworc3RhdGljIGlubGluZSB2b2lkIGdlbV9uZXRpZl9zdG9wKHN0cnVjdCBn
ZW0gKmdwKQoreworCXN0cnVjdCBuZXRfZGV2aWNlICpkZXYgPSBncC0+ZGV2OworCisJZGV2LT50
cmFuc19zdGFydCA9IGppZmZpZXM7IC8qIHByZXZlbnQgdHggdGltZW91dCAqLworCW5ldGlmX3Bv
bGxfZGlzYWJsZShkZXYpOworCW5ldGlmX3R4X2Rpc2FibGUoZGV2KTsKK30KKworc3RhdGljIGlu
bGluZSB2b2lkIGdlbV9uZXRpZl9zdGFydChzdHJ1Y3QgZ2VtICpncCkKK3sKKwlzdHJ1Y3QgbmV0
X2RldmljZSAqZGV2ID0gZ3AtPmRldjsKKworCS8qIFVuY29uZGl0aW9ubmFseSBuZXRpZl93YWtl
X3F1ZXVlIGlzIG9rIHNvIGxvbmcgYXMgY2FsbGVyIGhhcworCSAqIGZyZWVkIHR4IHNsb3RzLCB3
aGlzIGRvbmUgaW4gZ2VtX3JlaW5pdF9jaGlwKCkuCisJICovCisJbmV0aWZfd2FrZV9xdWV1ZShk
ZXYpOworCW5ldGlmX3BvbGxfZW5hYmxlKGRldik7Cit9CisKK3N0YXRpYyBpbmxpbmUgdm9pZCBn
ZW1fc2NoZWR1bGVfcmVzZXRfdGFzayhzdHJ1Y3QgZ2VtICpncCkKK3sKKwlncC0+cmVzZXRfdGFz
a19wZW5kaW5nID0gMTsKKwlzbXBfbWIoKTsKKwlzY2hlZHVsZV93b3JrKCZncC0+cmVzZXRfdGFz
ayk7Cit9CisKK3N0YXRpYyBpbmxpbmUgdm9pZCBnZW1fd2FpdF9yZXNldF90YXNrKHN0cnVjdCBn
ZW0gKmdwKQoreworCW1iKCk7CisJd2hpbGUgKGdwLT5yZXNldF90YXNrX3BlbmRpbmcpIHsKKwkJ
eWllbGQoKTsKKwkJbWIoKTsKKwl9Cit9CisKIHN0YXRpYyB2b2lkIGdlbV9nZXRfY2VsbChzdHJ1
Y3QgZ2VtICpncCkKIHsKIAlCVUdfT04oZ3AtPmNlbGxfZW5hYmxlZCA8IDApOwpAQCAtNjU4LDEy
ICs2OTksMjAgQEAgc3RhdGljIGludCBnZW1fYWJub3JtYWxfaXJxKHN0cnVjdCBuZXRfZAogCXJl
dHVybiAwOwogCiBkb19yZXNldDoKLQlncC0+cmVzZXRfdGFza19wZW5kaW5nID0gMTsKLQlzY2hl
ZHVsZV93b3JrKCZncC0+cmVzZXRfdGFzayk7CisJZ2VtX3NjaGVkdWxlX3Jlc2V0X3Rhc2soZ3Ap
OwogCiAJcmV0dXJuIDE7CiB9CiAKK3N0YXRpYyBpbmxpbmUgdTMyIGdlbV90eF9hdmFpbChzdHJ1
Y3QgZ2VtICpncCkKK3sKKwlzbXBfbWIoKTsKKwlyZXR1cm4gKGdwLT50eF9vbGQgPD0gZ3AtPnR4
X25ldykgPworCQlncC0+dHhfb2xkICsgKFRYX1JJTkdfU0laRSAtIDEpIC0gZ3AtPnR4X25ldyA6
CisJCWdwLT50eF9vbGQgLSBncC0+dHhfbmV3IC0gMTsKK30KKworCiBzdGF0aWMgX19pbmxpbmVf
XyB2b2lkIGdlbV90eChzdHJ1Y3QgbmV0X2RldmljZSAqZGV2LCBzdHJ1Y3QgZ2VtICpncCwgdTMy
IGdlbV9zdGF0dXMpCiB7CiAJaW50IGVudHJ5LCBsaW1pdDsKQEAgLTcxNywxMSArNzY2LDIwIEBA
IHN0YXRpYyBfX2lubGluZV9fIHZvaWQgZ2VtX3R4KHN0cnVjdCBuZXQKIAkJZ3AtPm5ldF9zdGF0
cy50eF9wYWNrZXRzKys7CiAJCWRldl9rZnJlZV9za2JfaXJxKHNrYik7CiAJfQorCiAJZ3AtPnR4
X29sZCA9IGVudHJ5OwogCi0JaWYgKG5ldGlmX3F1ZXVlX3N0b3BwZWQoZGV2KSAmJgotCSAgICBU
WF9CVUZGU19BVkFJTChncCkgPiAoTUFYX1NLQl9GUkFHUyArIDEpKQotCQluZXRpZl93YWtlX3F1
ZXVlKGRldik7CisJLyogTmVlZCB0byBtYWtlIHR4X29sZCB1cGRhdGUgdmlzaWJsZSB0byBnZW1f
c3RhcnRfeG1pdCgpICovCisJc21wX21iKCk7CisKKwlpZiAodW5saWtlbHkobmV0aWZfcXVldWVf
c3RvcHBlZChkZXYpICYmCisJICAgIGdlbV90eF9hdmFpbChncCkgPiAoTUFYX1NLQl9GUkFHUyAr
IDEpKSkgeworCQluZXRpZl90eF9sb2NrKGRldik7CisJCWlmIChuZXRpZl9xdWV1ZV9zdG9wcGVk
KGRldikgJiYKKwkgICAgCSAgICBnZW1fdHhfYXZhaWwoZ3ApID4gKE1BWF9TS0JfRlJBR1MgKyAx
KSkKKwkJCW5ldGlmX3dha2VfcXVldWUoZGV2KTsKKwkJbmV0aWZfdHhfdW5sb2NrKGRldik7CisJ
fQogfQogCiBzdGF0aWMgX19pbmxpbmVfXyB2b2lkIGdlbV9wb3N0X3J4ZHMoc3RydWN0IGdlbSAq
Z3AsIGludCBsaW1pdCkKQEAgLTg4MiwxMiArOTQwLDYgQEAgc3RhdGljIGludCBnZW1fcngoc3Ry
dWN0IGdlbSAqZ3AsIGludCB3bwogc3RhdGljIGludCBnZW1fcG9sbChzdHJ1Y3QgbmV0X2Rldmlj
ZSAqZGV2LCBpbnQgKmJ1ZGdldCkKIHsKIAlzdHJ1Y3QgZ2VtICpncCA9IGRldi0+cHJpdjsKLQl1
bnNpZ25lZCBsb25nIGZsYWdzOwotCi0JLyoKLQkgKiBOQVBJIGxvY2tpbmcgbmlnaHRtYXJlOiBT
ZWUgY29tbWVudCBhdCBoZWFkIG9mIGRyaXZlcgotCSAqLwotCXNwaW5fbG9ja19pcnFzYXZlKCZn
cC0+bG9jaywgZmxhZ3MpOwogCiAJZG8gewogCQlpbnQgd29ya190b19kbywgd29ya19kb25lOwpA
QCAtODk5LDE5ICs5NTEsMTAgQEAgc3RhdGljIGludCBnZW1fcG9sbChzdHJ1Y3QgbmV0X2Rldmlj
ZSAqZAogCQl9CiAKIAkJLyogUnVuIFRYIGNvbXBsZXRpb24gdGhyZWFkICovCi0JCXNwaW5fbG9j
aygmZ3AtPnR4X2xvY2spOwogCQlnZW1fdHgoZGV2LCBncCwgZ3AtPnN0YXR1cyk7Ci0JCXNwaW5f
dW5sb2NrKCZncC0+dHhfbG9jayk7Ci0KLQkJc3Bpbl91bmxvY2tfaXJxcmVzdG9yZSgmZ3AtPmxv
Y2ssIGZsYWdzKTsKIAotCQkvKiBSdW4gUlggdGhyZWFkLiBXZSBkb24ndCB1c2UgYW55IGxvY2tp
bmcgaGVyZSwKLQkJICogY29kZSB3aWxsaW5nIHRvIGRvIGJhZCB0aGluZ3MgLSBsaWtlIGNsZWFu
aW5nIHRoZQotCQkgKiByeCByaW5nIC0gbXVzdCBjYWxsIG5ldGlmX3BvbGxfZGlzYWJsZSgpLCB3
aGljaAotCQkgKiBzY2hlZHVsZV90aW1lb3V0KCkncyBpZiBwb2xsaW5nIGlzIGFscmVhZHkgZGlz
YWJsZWQuCi0JCSAqLworCQkvKiBSdW4gUlggdGhyZWFkICovCiAJCXdvcmtfdG9fZG8gPSBtaW4o
KmJ1ZGdldCwgZGV2LT5xdW90YSk7Ci0KIAkJd29ya19kb25lID0gZ2VtX3J4KGdwLCB3b3JrX3Rv
X2RvKTsKIAogCQkqYnVkZ2V0IC09IHdvcmtfZG9uZTsKQEAgLTkyMCwyMyArOTYzLDU3IEBAIHN0
YXRpYyBpbnQgZ2VtX3BvbGwoc3RydWN0IG5ldF9kZXZpY2UgKmQKIAkJaWYgKHdvcmtfZG9uZSA+
PSB3b3JrX3RvX2RvKQogCQkJcmV0dXJuIDE7CiAKLQkJc3Bpbl9sb2NrX2lycXNhdmUoJmdwLT5s
b2NrLCBmbGFncyk7Ci0KIAkJZ3AtPnN0YXR1cyA9IHJlYWRsKGdwLT5yZWdzICsgR1JFR19TVEFU
KTsKIAl9IHdoaWxlIChncC0+c3RhdHVzICYgR1JFR19TVEFUX05BUEkpOwogCiAJX19uZXRpZl9y
eF9jb21wbGV0ZShkZXYpOwotCWdlbV9lbmFibGVfaW50cyhncCk7CisJX19nZW1fZW5hYmxlX2lu
dHMoZ3ApOwogCi0Jc3Bpbl91bmxvY2tfaXJxcmVzdG9yZSgmZ3AtPmxvY2ssIGZsYWdzKTsKIAly
ZXR1cm4gMDsKIH0KIAorc3RhdGljIHZvaWQgZ2VtX2lycV9xdWllc2NlKHN0cnVjdCBnZW0gKmdw
KQoreworCUJVR19PTihncC0+aXJxX3N5bmMpOworCisJZ3AtPmlycV9zeW5jID0gMTsKKwlzbXBf
bWIoKTsKKworCXN5bmNocm9uaXplX2lycShncC0+cGRldi0+aXJxKTsKK30KKworc3RhdGljIGlu
bGluZSBpbnQgZ2VtX2lycV9zeW5jKHN0cnVjdCBnZW0gKmdwKQoreworCXJldHVybiBncC0+aXJx
X3N5bmM7Cit9CisKK3N0YXRpYyBpbmxpbmUgdm9pZCBnZW1fZnVsbF9sb2NrKHN0cnVjdCBnZW0g
KmdwLCBpbnQgaXJxX3N5bmMpCit7CisJc3Bpbl9sb2NrX2JoKCZncC0+bG9jayk7CisJaWYgKGly
cV9zeW5jKQorCQlnZW1faXJxX3F1aWVzY2UoZ3ApOworfQorCitzdGF0aWMgaW5saW5lIHZvaWQg
Z2VtX2Z1bGxfdW5sb2NrKHN0cnVjdCBnZW0gKmdwKQoreworCXNwaW5fdW5sb2NrX2JoKCZncC0+
bG9jayk7Cit9CisKKyNpZiBHRU1fSU5URVJSVVBUX0xPQ0tMRVNTCisKKy8qIExvY2tsZXNzIGlt
cGxlbWVudGF0aW9uIG9mIElSUSBoYW5kbGVyLgorICoKKyAqIFRoZSBkb3duc2lkZSBvZiB0aGlz
IGltcGxlbWVudGF0aW9uIGlzIHRoYXQgaXQgcmVxdWlyZXMgdGhyZWUgUElPCisgKiBvcGVyYXRp
b25zOiByZWFkIHN0YXR1cywgZGlzYWJsZSBpbnRlcnJ1cHRzIGFuZCBhY2sgaW50ZXJydXB0Lgor
ICoKKyAqIEFsc28sIHRoaXMgaW1wbGVtZW50YXRpb24gbWF5IG5vdCB3b3JrIHdpdGggTkVUX1BP
TExfQ09OVFJPTExFUi4gCisgKiBUT0RPOiBuZWVkIGZ1cnRoZXIgaW52ZXN0aWdhdGlvbi4KKyAq
Lwogc3RhdGljIGlycXJldHVybl90IGdlbV9pbnRlcnJ1cHQoaW50IGlycSwgdm9pZCAqZGV2X2lk
KQogewogCXN0cnVjdCBuZXRfZGV2aWNlICpkZXYgPSBkZXZfaWQ7CiAJc3RydWN0IGdlbSAqZ3Ag
PSBkZXYtPnByaXY7Ci0JdW5zaWduZWQgbG9uZyBmbGFnczsKKwl1MzIgZ2VtX3N0YXR1czsKIAog
CS8qIFN3YWxsb3cgaW50ZXJydXB0cyB3aGVuIHNodXR0aW5nIHRoZSBjaGlwIGRvd24sIHRob3Vn
aAogCSAqIHRoYXQgc2hvdWxkbid0IGhhcHBlbiwgd2Ugc2hvdWxkIGhhdmUgZG9uZSBmcmVlX2ly
cSgpIGF0CkBAIC05NDUsMjkgKzEwMjIsNzAgQEAgc3RhdGljIGlycXJldHVybl90IGdlbV9pbnRl
cnJ1cHQoaW50IGlycQogCWlmICghZ3AtPnJ1bm5pbmcpCiAJCXJldHVybiBJUlFfSEFORExFRDsK
IAotCXNwaW5fbG9ja19pcnFzYXZlKCZncC0+bG9jaywgZmxhZ3MpOworCWdlbV9zdGF0dXMgPSBn
ZW1fcmVhZF9zdGF0dXMyKGdwKTsKKwlpZiAodW5saWtlbHkoIWdlbV9zdGF0dXMpKSAvKiBzaGFy
ZWQgaXJxPyAqLworCQlyZXR1cm4gSVJRX05PTkU7CiAKIAlpZiAobmV0aWZfcnhfc2NoZWR1bGVf
cHJlcChkZXYpKSB7Ci0JCXUzMiBnZW1fc3RhdHVzID0gcmVhZGwoZ3AtPnJlZ3MgKyBHUkVHX1NU
QVQpOworCQlnZW1fZGlzYWJsZV9pbnRzKGdwKTsKKwkJZ2VtX2Fja19pbnQoZ3ApOwogCi0JCWlm
IChnZW1fc3RhdHVzID09IDApIHsKKwkJaWYgKGdlbV9pcnFfc3luYyhncCkpIHsKKwkJCS8qIFdl
IGFyZSBzdXJlIHRoYXQgKndlKiBkaXNhYmxlZCBwb2xsaW5nLCBzbyB3ZSBjYW4KKwkJCSAqIHNh
ZmVseSByZWVuYWJsZSBpdCBiZWZvcmUgcmV0dXJuaW5nLgorCQkJICovCiAJCQluZXRpZl9wb2xs
X2VuYWJsZShkZXYpOwotCQkJc3Bpbl91bmxvY2tfaXJxcmVzdG9yZSgmZ3AtPmxvY2ssIGZsYWdz
KTsKLQkJCXJldHVybiBJUlFfTk9ORTsKKwkJCXJldHVybiBJUlFfSEFORExFRDsKIAkJfQorCiAJ
CWdwLT5zdGF0dXMgPSBnZW1fc3RhdHVzOwotCQlnZW1fZGlzYWJsZV9pbnRzKGdwKTsKIAkJX19u
ZXRpZl9yeF9zY2hlZHVsZShkZXYpOwogCX0KIAotCXNwaW5fdW5sb2NrX2lycXJlc3RvcmUoJmdw
LT5sb2NrLCBmbGFncyk7CisJcmV0dXJuIElSUV9IQU5ETEVEOworfQorI2Vsc2UKK3N0YXRpYyBp
cnFyZXR1cm5fdCBnZW1faW50ZXJydXB0KGludCBpcnEsIHZvaWQgKmRldl9pZCkKK3sKKwlzdHJ1
Y3QgbmV0X2RldmljZSAqZGV2ID0gZGV2X2lkOworCXN0cnVjdCBnZW0gKmdwID0gZGV2LT5wcml2
OworCXVuc2lnbmVkIGludCBoYW5kbGVkID0gMTsKKwl1bnNpZ25lZCBsb25nIGZsYWdzOwogCi0J
LyogSWYgcG9sbGluZyB3YXMgZGlzYWJsZWQgYXQgdGhlIHRpbWUgd2UgcmVjZWl2ZWQgdGhhdAot
CSAqIGludGVycnVwdCwgd2UgbWF5IHJldHVybiBJUlFfSEFORExFRCBoZXJlIHdoaWxlIHdlCi0J
ICogc2hvdWxkIHJldHVybiBJUlFfTk9ORS4gTm8gYmlnIGRlYWwuLi4KKwkvKiBTd2FsbG93IGlu
dGVycnVwdHMgd2hlbiBzaHV0dGluZyB0aGUgY2hpcCBkb3duLCB0aG91Z2gKKwkgKiB0aGF0IHNo
b3VsZG4ndCBoYXBwZW4sIHdlIHNob3VsZCBoYXZlIGRvbmUgZnJlZV9pcnEoKSBhdAorCSAqIHRo
aXMgcG9pbnQuLi4KIAkgKi8KKwlpZiAoIWdwLT5ydW5uaW5nKQorCQlyZXR1cm4gSVJRX0hBTkRM
RUQ7CisKKwlzcGluX2xvY2tfaXJxc2F2ZSgmZ3AtPmludF9sb2NrLCBmbGFncyk7CisKKwlpZiAo
bmV0aWZfcnhfc2NoZWR1bGVfcHJlcChkZXYpKSB7CisJCXUzMiBnZW1fc3RhdHVzID0gZ2VtX3Jl
YWRfc3RhdHVzKGdwKTsKKworCQlpZiAodW5saWtlbHkoIWdlbV9zdGF0dXMpKSB7CisJCQluZXRp
Zl9wb2xsX2VuYWJsZShkZXYpOworCQkJaGFuZGxlZCA9IDA7CisJCQlnb3RvIG91dDsKKwkJfQor
CisJCWdlbV9kaXNhYmxlX2ludHMoZ3ApOworCisJCWlmIChnZW1faXJxX3N5bmMoZ3ApKSB7CisJ
CQluZXRpZl9wb2xsX2VuYWJsZShkZXYpOworCQkJZ290byBvdXQ7CisJCX0KKworCQlncC0+c3Rh
dHVzID0gZ2VtX3N0YXR1czsKKwkJX19uZXRpZl9yeF9zY2hlZHVsZShkZXYpOworCX0KKworb3V0
OgorCXNwaW5fdW5sb2NrX2lycXJlc3RvcmUoJmdwLT5pbnRfbG9jaywgZmxhZ3MpOwogCXJldHVy
biBJUlFfSEFORExFRDsKIH0KKyNlbmRpZgogCiAjaWZkZWYgQ09ORklHX05FVF9QT0xMX0NPTlRS
T0xMRVIKIHN0YXRpYyB2b2lkIGdlbV9wb2xsX2NvbnRyb2xsZXIoc3RydWN0IG5ldF9kZXZpY2Ug
KmRldikKQEAgLTk5OSwxNCArMTExNyw4IEBAIHN0YXRpYyB2b2lkIGdlbV90eF90aW1lb3V0KHN0
cnVjdCBuZXRfZGUKIAkgICAgICAgcmVhZGwoZ3AtPnJlZ3MgKyBNQUNfUlhTVEFUKSwKIAkgICAg
ICAgcmVhZGwoZ3AtPnJlZ3MgKyBNQUNfUlhDRkcpKTsKIAotCXNwaW5fbG9ja19pcnEoJmdwLT5s
b2NrKTsKLQlzcGluX2xvY2soJmdwLT50eF9sb2NrKTsKLQotCWdwLT5yZXNldF90YXNrX3BlbmRp
bmcgPSAxOwotCXNjaGVkdWxlX3dvcmsoJmdwLT5yZXNldF90YXNrKTsKLQotCXNwaW5fdW5sb2Nr
KCZncC0+dHhfbG9jayk7Ci0Jc3Bpbl91bmxvY2tfaXJxKCZncC0+bG9jayk7CisJcHJpbnRrKEtF
Uk5fSU5GTyAiJXM6IGdlbV90eF90aW1lb3V0XG4iLCBkZXYtPm5hbWUpOworCWdlbV9zY2hlZHVs
ZV9yZXNldF90YXNrKGdwKTsKIH0KIAogc3RhdGljIF9faW5saW5lX18gaW50IGdlbV9pbnRtZShp
bnQgZW50cnkpCkBAIC0xMDIzLDcgKzExMzUsNiBAQCBzdGF0aWMgaW50IGdlbV9zdGFydF94bWl0
KHN0cnVjdCBza19idWZmCiAJc3RydWN0IGdlbSAqZ3AgPSBkZXYtPnByaXY7CiAJaW50IGVudHJ5
OwogCXU2NCBjdHJsOwotCXVuc2lnbmVkIGxvbmcgZmxhZ3M7CiAKIAljdHJsID0gMDsKIAlpZiAo
c2tiLT5pcF9zdW1tZWQgPT0gQ0hFQ0tTVU1fUEFSVElBTCkgewpAQCAtMTAzNywyNCArMTE0OCwx
MyBAQCBzdGF0aWMgaW50IGdlbV9zdGFydF94bWl0KHN0cnVjdCBza19idWZmCiAJCQkoY3N1bV9z
dHVmZl9vZmYgPDwgMjEpKTsKIAl9CiAKLQlsb2NhbF9pcnFfc2F2ZShmbGFncyk7Ci0JaWYgKCFz
cGluX3RyeWxvY2soJmdwLT50eF9sb2NrKSkgewotCQkvKiBUZWxsIHVwcGVyIGxheWVyIHRvIHJl
cXVldWUgKi8KLQkJbG9jYWxfaXJxX3Jlc3RvcmUoZmxhZ3MpOwotCQlyZXR1cm4gTkVUREVWX1RY
X0xPQ0tFRDsKLQl9Ci0JLyogV2UgcmFjZWQgd2l0aCBnZW1fZG9fc3RvcCgpICovCi0JaWYgKCFn
cC0+cnVubmluZykgewotCQlzcGluX3VubG9ja19pcnFyZXN0b3JlKCZncC0+dHhfbG9jaywgZmxh
Z3MpOwotCQlyZXR1cm4gTkVUREVWX1RYX0JVU1k7Ci0JfQotCiAJLyogVGhpcyBpcyBhIGhhcmQg
ZXJyb3IsIGxvZyBpdC4gKi8KLQlpZiAoVFhfQlVGRlNfQVZBSUwoZ3ApIDw9IChza2Jfc2hpbmZv
KHNrYiktPm5yX2ZyYWdzICsgMSkpIHsKLQkJbmV0aWZfc3RvcF9xdWV1ZShkZXYpOwotCQlzcGlu
X3VubG9ja19pcnFyZXN0b3JlKCZncC0+dHhfbG9jaywgZmxhZ3MpOwotCQlwcmludGsoS0VSTl9F
UlIgUEZYICIlczogQlVHISBUeCBSaW5nIGZ1bGwgd2hlbiBxdWV1ZSBhd2FrZSFcbiIsCi0JCSAg
ICAgICBkZXYtPm5hbWUpOworCWlmIChnZW1fdHhfYXZhaWwoZ3ApIDw9IChza2Jfc2hpbmZvKHNr
YiktPm5yX2ZyYWdzICsgMSkpIHsKKwkJaWYgKCFuZXRpZl9xdWV1ZV9zdG9wcGVkKGRldikpIHsK
KwkJCW5ldGlmX3N0b3BfcXVldWUoZGV2KTsKKwkJCXByaW50ayhLRVJOX0VSUiBQRlggIiVzOiBC
VUchIFR4IFJpbmcgZnVsbCB3aGVuICIKKwkJCSAgICAgICAicXVldWUgYXdha2UhXG4iLCBkZXYt
Pm5hbWUpOworCQl9CiAJCXJldHVybiBORVRERVZfVFhfQlVTWTsKIAl9CiAKQEAgLTExMzEsMTUg
KzEyMzEsMTcgQEAgc3RhdGljIGludCBnZW1fc3RhcnRfeG1pdChzdHJ1Y3Qgc2tfYnVmZgogCX0K
IAogCWdwLT50eF9uZXcgPSBlbnRyeTsKLQlpZiAoVFhfQlVGRlNfQVZBSUwoZ3ApIDw9IChNQVhf
U0tCX0ZSQUdTICsgMSkpCisJaWYgKHVubGlrZWx5KGdlbV90eF9hdmFpbChncCkgPD0gKE1BWF9T
S0JfRlJBR1MgKyAxKSkpIHsKIAkJbmV0aWZfc3RvcF9xdWV1ZShkZXYpOworCQlpZiAoZ2VtX3R4
X2F2YWlsKGdwKSA+IChNQVhfU0tCX0ZSQUdTICsgMSkpCisJCQluZXRpZl93YWtlX3F1ZXVlKGRl
dik7CisJfQogCiAJaWYgKG5ldGlmX21zZ190eF9xdWV1ZWQoZ3ApKQogCQlwcmludGsoS0VSTl9E
RUJVRyAiJXM6IHR4IHF1ZXVlZCwgc2xvdCAlZCwgc2tibGVuICVkXG4iLAogCQkgICAgICAgZGV2
LT5uYW1lLCBlbnRyeSwgc2tiLT5sZW4pOwogCW1iKCk7CiAJd3JpdGVsKGdwLT50eF9uZXcsIGdw
LT5yZWdzICsgVFhETUFfS0lDSyk7Ci0Jc3Bpbl91bmxvY2tfaXJxcmVzdG9yZSgmZ3AtPnR4X2xv
Y2ssIGZsYWdzKTsKIAogCWRldi0+dHJhbnNfc3RhcnQgPSBqaWZmaWVzOwogCkBAIC0xMTQ4LDcg
KzEyNTAsNiBAQCBzdGF0aWMgaW50IGdlbV9zdGFydF94bWl0KHN0cnVjdCBza19idWZmCiAKICNk
ZWZpbmUgU1RPUF9UUklFUyAzMgogCi0vKiBNdXN0IGJlIGludm9rZWQgdW5kZXIgZ3AtPmxvY2sg
YW5kIGdwLT50eF9sb2NrLiAqLwogc3RhdGljIHZvaWQgZ2VtX3Jlc2V0KHN0cnVjdCBnZW0gKmdw
KQogewogCWludCBsaW1pdDsKQEAgLTExNzQsNyArMTI3NSw2IEBAIHN0YXRpYyB2b2lkIGdlbV9y
ZXNldChzdHJ1Y3QgZ2VtICpncCkKIAkJcHJpbnRrKEtFUk5fRVJSICIlczogU1cgcmVzZXQgaXMg
Z2hldHRvLlxuIiwgZ3AtPmRldi0+bmFtZSk7CiB9CiAKLS8qIE11c3QgYmUgaW52b2tlZCB1bmRl
ciBncC0+bG9jayBhbmQgZ3AtPnR4X2xvY2suICovCiBzdGF0aWMgdm9pZCBnZW1fc3RhcnRfZG1h
KHN0cnVjdCBnZW0gKmdwKQogewogCXUzMiB2YWw7CkBAIC0xMTk3LDkgKzEyOTcsNyBAQCBzdGF0
aWMgdm9pZCBnZW1fc3RhcnRfZG1hKHN0cnVjdCBnZW0gKmdwCiAJd3JpdGVsKFJYX1JJTkdfU0la
RSAtIDQsIGdwLT5yZWdzICsgUlhETUFfS0lDSyk7CiB9CiAKLS8qIE11c3QgYmUgaW52b2tlZCB1
bmRlciBncC0+bG9jayBhbmQgZ3AtPnR4X2xvY2suIERNQSB3b24ndCBiZQotICogYWN0dWFsbHkg
c3RvcHBlZCBiZWZvcmUgYWJvdXQgNG1zIHRobyAuLi4KLSAqLworLyogRE1BIHdvbid0IGJlIGFj
dHVhbGx5IHN0b3BwZWQgYmVmb3JlIGFib3V0IDRtcyB0aG8gLi4uICovCiBzdGF0aWMgdm9pZCBn
ZW1fc3RvcF9kbWEoc3RydWN0IGdlbSAqZ3ApCiB7CiAJdTMyIHZhbDsKQEAgLTEyMjAsOCArMTMx
OCw3IEBAIHN0YXRpYyB2b2lkIGdlbV9zdG9wX2RtYShzdHJ1Y3QgZ2VtICpncCkKIH0KIAogCi0v
KiBNdXN0IGJlIGludm9rZWQgdW5kZXIgZ3AtPmxvY2sgYW5kIGdwLT50eF9sb2NrLiAqLwotLy8g
WFhYIGRibCBjaGVjayB3aGF0IHRoYXQgZnVuY3Rpb24gc2hvdWxkIGRvIHdoZW4gY2FsbGVkIG9u
IFBDUyBQSFkKKy8qIFhYWCBkYmwgY2hlY2sgd2hhdCB0aGF0IGZ1bmN0aW9uIHNob3VsZCBkbyB3
aGVuIGNhbGxlZCBvbiBQQ1MgUEhZICovCiBzdGF0aWMgdm9pZCBnZW1fYmVnaW5fYXV0b19uZWdv
dGlhdGlvbihzdHJ1Y3QgZ2VtICpncCwgc3RydWN0IGV0aHRvb2xfY21kICplcCkKIHsKIAl1MzIg
YWR2ZXJ0aXNlLCBmZWF0dXJlczsKQEAgLTEzMDYsOCArMTQwMyw2IEBAIG5vbl9taWk6CiAKIC8q
IEEgbGluay11cCBjb25kaXRpb24gaGFzIG9jY3VycmVkLCBpbml0aWFsaXplIGFuZCBlbmFibGUg
dGhlCiAgKiByZXN0IG9mIHRoZSBjaGlwLgotICoKLSAqIE11c3QgYmUgaW52b2tlZCB1bmRlciBn
cC0+bG9jayBhbmQgZ3AtPnR4X2xvY2suCiAgKi8KIHN0YXRpYyBpbnQgZ2VtX3NldF9saW5rX21v
ZGVzKHN0cnVjdCBnZW0gKmdwKQogewpAQCAtMTQxNyw3ICsxNTEyLDYgQEAgc3RhdGljIGludCBn
ZW1fc2V0X2xpbmtfbW9kZXMoc3RydWN0IGdlbQogCXJldHVybiAwOwogfQogCi0vKiBNdXN0IGJl
IGludm9rZWQgdW5kZXIgZ3AtPmxvY2sgYW5kIGdwLT50eF9sb2NrLiAqLwogc3RhdGljIGludCBn
ZW1fbWRpb19saW5rX25vdF91cChzdHJ1Y3QgZ2VtICpncCkKIHsKIAlzd2l0Y2ggKGdwLT5sc3Rh
dGUpIHsKQEAgLTE0NzQsMTMgKzE1NjgsMTMgQEAgc3RhdGljIHZvaWQgZ2VtX2xpbmtfdGltZXIo
dW5zaWduZWQgbG9uZwogCWlmIChncC0+YXNsZWVwKQogCQlyZXR1cm47CiAKLQlzcGluX2xvY2tf
aXJxKCZncC0+bG9jayk7Ci0Jc3Bpbl9sb2NrKCZncC0+dHhfbG9jayk7CisJZ2VtX2Z1bGxfbG9j
ayhncCwgMCk7CiAJZ2VtX2dldF9jZWxsKGdwKTsKIAogCS8qIElmIHRoZSByZXNldCB0YXNrIGlz
IHN0aWxsIHBlbmRpbmcsIHdlIGp1c3QKIAkgKiByZXNjaGVkdWxlIHRoZSBsaW5rIHRpbWVyCiAJ
ICovCisJc21wX21iKCk7CiAJaWYgKGdwLT5yZXNldF90YXNrX3BlbmRpbmcpCiAJCWdvdG8gcmVz
dGFydDsKIApAQCAtMTUyOCw4ICsxNjIyLDcgQEAgc3RhdGljIHZvaWQgZ2VtX2xpbmtfdGltZXIo
dW5zaWduZWQgbG9uZwogCQkJCXByaW50ayhLRVJOX0lORk8gIiVzOiBMaW5rIGRvd25cbiIsCiAJ
CQkJCWdwLT5kZXYtPm5hbWUpOwogCQkJbmV0aWZfY2Fycmllcl9vZmYoZ3AtPmRldik7Ci0JCQln
cC0+cmVzZXRfdGFza19wZW5kaW5nID0gMTsKLQkJCXNjaGVkdWxlX3dvcmsoJmdwLT5yZXNldF90
YXNrKTsKKwkJCWdlbV9zY2hlZHVsZV9yZXNldF90YXNrKGdwKTsKIAkJCXJlc3RhcnRfYW5lZyA9
IDE7CiAJCX0gZWxzZSBpZiAoKytncC0+dGltZXJfdGlja3MgPiAxMCkgewogCQkJaWYgKGZvdW5k
X21paV9waHkoZ3ApKQpAQCAtMTU0NiwxMSArMTYzOSw5IEBAIHJlc3RhcnQ6CiAJbW9kX3RpbWVy
KCZncC0+bGlua190aW1lciwgamlmZmllcyArICgoMTIgKiBIWikgLyAxMCkpOwogb3V0X3VubG9j
azoKIAlnZW1fcHV0X2NlbGwoZ3ApOwotCXNwaW5fdW5sb2NrKCZncC0+dHhfbG9jayk7Ci0Jc3Bp
bl91bmxvY2tfaXJxKCZncC0+bG9jayk7CisJZ2VtX2Z1bGxfdW5sb2NrKGdwKTsKIH0KIAotLyog
TXVzdCBiZSBpbnZva2VkIHVuZGVyIGdwLT5sb2NrIGFuZCBncC0+dHhfbG9jay4gKi8KIHN0YXRp
YyB2b2lkIGdlbV9jbGVhbl9yaW5ncyhzdHJ1Y3QgZ2VtICpncCkKIHsKIAlzdHJ1Y3QgZ2VtX2lu
aXRfYmxvY2sgKmdiID0gZ3AtPmluaXRfYmxvY2s7CkBAIC0xNjAxLDcgKzE2OTIsNiBAQCBzdGF0
aWMgdm9pZCBnZW1fY2xlYW5fcmluZ3Moc3RydWN0IGdlbSAqCiAJfQogfQogCi0vKiBNdXN0IGJl
IGludm9rZWQgdW5kZXIgZ3AtPmxvY2sgYW5kIGdwLT50eF9sb2NrLiAqLwogc3RhdGljIHZvaWQg
Z2VtX2luaXRfcmluZ3Moc3RydWN0IGdlbSAqZ3ApCiB7CiAJc3RydWN0IGdlbV9pbml0X2Jsb2Nr
ICpnYiA9IGdwLT5pbml0X2Jsb2NrOwpAQCAtMTc3NSwxMiArMTg2NSw5IEBAIHN0YXRpYyB2b2lk
IGdlbV9pbml0X3BoeShzdHJ1Y3QgZ2VtICpncCkKIAluZXRpZl9jYXJyaWVyX29mZihncC0+ZGV2
KTsKIAogCS8qIENhbiBJIGFkdmVydGlzZSBnaWdhYml0IGhlcmUgPyBJJ2QgbmVlZCBCQ00gUEhZ
IGRvY3MuLi4gKi8KLQlzcGluX2xvY2tfaXJxKCZncC0+bG9jayk7CiAJZ2VtX2JlZ2luX2F1dG9f
bmVnb3RpYXRpb24oZ3AsIE5VTEwpOwotCXNwaW5fdW5sb2NrX2lycSgmZ3AtPmxvY2spOwogfQog
Ci0vKiBNdXN0IGJlIGludm9rZWQgdW5kZXIgZ3AtPmxvY2sgYW5kIGdwLT50eF9sb2NrLiAqLwog
c3RhdGljIHZvaWQgZ2VtX2luaXRfZG1hKHN0cnVjdCBnZW0gKmdwKQogewogCXU2NCBkZXNjX2Rt
YSA9ICh1NjQpIGdwLT5nYmxvY2tfZHZtYTsKQEAgLTE4MTgsNyArMTkwNSw2IEBAIHN0YXRpYyB2
b2lkIGdlbV9pbml0X2RtYShzdHJ1Y3QgZ2VtICpncCkKIAkJICAgICAgIGdwLT5yZWdzICsgUlhE
TUFfQkxBTkspOwogfQogCi0vKiBNdXN0IGJlIGludm9rZWQgdW5kZXIgZ3AtPmxvY2sgYW5kIGdw
LT50eF9sb2NrLiAqLwogc3RhdGljIHUzMiBnZW1fc2V0dXBfbXVsdGljYXN0KHN0cnVjdCBnZW0g
KmdwKQogewogCXUzMiByeGNmZyA9IDA7CkBAIC0xODYwLDcgKzE5NDYsNiBAQCBzdGF0aWMgdTMy
IGdlbV9zZXR1cF9tdWx0aWNhc3Qoc3RydWN0IGdlCiAJcmV0dXJuIHJ4Y2ZnOwogfQogCi0vKiBN
dXN0IGJlIGludm9rZWQgdW5kZXIgZ3AtPmxvY2sgYW5kIGdwLT50eF9sb2NrLiAqLwogc3RhdGlj
IHZvaWQgZ2VtX2luaXRfbWFjKHN0cnVjdCBnZW0gKmdwKQogewogCXVuc2lnbmVkIGNoYXIgKmUg
PSAmZ3AtPmRldi0+ZGV2X2FkZHJbMF07CkBAIC0xOTQzLDcgKzIwMjgsNiBAQCBzdGF0aWMgdm9p
ZCBnZW1faW5pdF9tYWMoc3RydWN0IGdlbSAqZ3ApCiAJCXdyaXRlbCgwLCBncC0+cmVncyArIFdP
TF9XQUtFQ1NSKTsKIH0KIAotLyogTXVzdCBiZSBpbnZva2VkIHVuZGVyIGdwLT5sb2NrIGFuZCBn
cC0+dHhfbG9jay4gKi8KIHN0YXRpYyB2b2lkIGdlbV9pbml0X3BhdXNlX3RocmVzaG9sZHMoc3Ry
dWN0IGdlbSAqZ3ApCiB7CiAgICAgICAgCXUzMiBjZmc7CkBAIC0yMDk2LDcgKzIxODAsNiBAQCBz
dGF0aWMgaW50IGdlbV9jaGVja19pbnZhcmlhbnRzKHN0cnVjdCBnCiAJcmV0dXJuIDA7CiB9CiAK
LS8qIE11c3QgYmUgaW52b2tlZCB1bmRlciBncC0+bG9jayBhbmQgZ3AtPnR4X2xvY2suICovCiBz
dGF0aWMgdm9pZCBnZW1fcmVpbml0X2NoaXAoc3RydWN0IGdlbSAqZ3ApCiB7CiAJLyogUmVzZXQg
dGhlIGNoaXAgKi8KQEAgLTIxMTYsMTIgKzIxOTksMTAgQEAgc3RhdGljIHZvaWQgZ2VtX3JlaW5p
dF9jaGlwKHN0cnVjdCBnZW0gKgogCWdlbV9pbml0X21hYyhncCk7CiB9CiAKLQogLyogTXVzdCBi
ZSBpbnZva2VkIHdpdGggbm8gbG9jayBoZWxkLiAqLwogc3RhdGljIHZvaWQgZ2VtX3N0b3BfcGh5
KHN0cnVjdCBnZW0gKmdwLCBpbnQgd29sKQogewogCXUzMiBtaWZjZmc7Ci0JdW5zaWduZWQgbG9u
ZyBmbGFnczsKIAogCS8qIExldCB0aGUgY2hpcCBzZXR0bGUgZG93biBhIGJpdCwgaXQgc2VlbXMg
dGhhdCBoZWxwcwogCSAqIGZvciBzbGVlcCBtb2RlIG9uIHNvbWUgbW9kZWxzCkBAIC0yMTY3LDEz
ICsyMjQ4LDEzIEBAIHN0YXRpYyB2b2lkIGdlbV9zdG9wX3BoeShzdHJ1Y3QgZ2VtICpncCwKIAl3
cml0ZWwoMCwgZ3AtPnJlZ3MgKyBSWERNQV9DRkcpOwogCiAJaWYgKCF3b2wpIHsKLQkJc3Bpbl9s
b2NrX2lycXNhdmUoJmdwLT5sb2NrLCBmbGFncyk7Ci0JCXNwaW5fbG9jaygmZ3AtPnR4X2xvY2sp
OworCQlnZW1fZnVsbF9sb2NrKGdwLCAwKTsKKwogCQlnZW1fcmVzZXQoZ3ApOwogCQl3cml0ZWwo
TUFDX1RYUlNUX0NNRCwgZ3AtPnJlZ3MgKyBNQUNfVFhSU1QpOwogCQl3cml0ZWwoTUFDX1JYUlNU
X0NNRCwgZ3AtPnJlZ3MgKyBNQUNfUlhSU1QpOwotCQlzcGluX3VubG9jaygmZ3AtPnR4X2xvY2sp
OwotCQlzcGluX3VubG9ja19pcnFyZXN0b3JlKCZncC0+bG9jaywgZmxhZ3MpOworCisJCWdlbV9m
dWxsX3VubG9jayhncCk7CiAKIAkJLyogTm8gbmVlZCB0byB0YWtlIHRoZSBsb2NrIGhlcmUgKi8K
IApAQCAtMjE5MiwxNCArMjI3MywxMSBAQCBzdGF0aWMgdm9pZCBnZW1fc3RvcF9waHkoc3RydWN0
IGdlbSAqZ3AsCiAJfQogfQogCi0KIHN0YXRpYyBpbnQgZ2VtX2RvX3N0YXJ0KHN0cnVjdCBuZXRf
ZGV2aWNlICpkZXYpCiB7CiAJc3RydWN0IGdlbSAqZ3AgPSBkZXYtPnByaXY7Ci0JdW5zaWduZWQg
bG9uZyBmbGFnczsKIAotCXNwaW5fbG9ja19pcnFzYXZlKCZncC0+bG9jaywgZmxhZ3MpOwotCXNw
aW5fbG9jaygmZ3AtPnR4X2xvY2spOworCWdlbV9mdWxsX2xvY2soZ3AsIDApOwogCiAJLyogRW5h
YmxlIHRoZSBjZWxsICovCiAJZ2VtX2dldF9jZWxsKGdwKTsKQEAgLTIyMTEsMjggKzIyODksMjUg
QEAgc3RhdGljIGludCBnZW1fZG9fc3RhcnQoc3RydWN0IG5ldF9kZXZpYwogCiAJaWYgKGdwLT5s
c3RhdGUgPT0gbGlua191cCkgewogCQluZXRpZl9jYXJyaWVyX29uKGdwLT5kZXYpOworCQkvKiBn
ZW1fc2V0X2xpbmtfbW9kZXMgc3RhcnRzIERNQSBhbmQgZW5hYmxlZCBpbnRzICovCiAJCWdlbV9z
ZXRfbGlua19tb2RlcyhncCk7CiAJfQogCi0JbmV0aWZfd2FrZV9xdWV1ZShncC0+ZGV2KTsKLQot
CXNwaW5fdW5sb2NrKCZncC0+dHhfbG9jayk7Ci0Jc3Bpbl91bmxvY2tfaXJxcmVzdG9yZSgmZ3At
PmxvY2ssIGZsYWdzKTsKKwlnZW1fZnVsbF91bmxvY2soZ3ApOwogCiAJaWYgKHJlcXVlc3RfaXJx
KGdwLT5wZGV2LT5pcnEsIGdlbV9pbnRlcnJ1cHQsCi0JCQkJICAgSVJRRl9TSEFSRUQsIGRldi0+
bmFtZSwgKHZvaWQgKilkZXYpKSB7CisJCSAgICAgICAgSVJRRl9TSEFSRUQsIGRldi0+bmFtZSwg
KHZvaWQgKilkZXYpKSB7CisKIAkJcHJpbnRrKEtFUk5fRVJSICIlczogZmFpbGVkIHRvIHJlcXVl
c3QgaXJxICFcbiIsIGdwLT5kZXYtPm5hbWUpOwogCi0JCXNwaW5fbG9ja19pcnFzYXZlKCZncC0+
bG9jaywgZmxhZ3MpOwotCQlzcGluX2xvY2soJmdwLT50eF9sb2NrKTsKKwkJZ2VtX2Z1bGxfbG9j
ayhncCwgMCk7CiAKIAkJZ3AtPnJ1bm5pbmcgPSAgMDsKIAkJZ2VtX3Jlc2V0KGdwKTsKIAkJZ2Vt
X2NsZWFuX3JpbmdzKGdwKTsKIAkJZ2VtX3B1dF9jZWxsKGdwKTsKIAotCQlzcGluX3VubG9jaygm
Z3AtPnR4X2xvY2spOwotCQlzcGluX3VubG9ja19pcnFyZXN0b3JlKCZncC0+bG9jaywgZmxhZ3Mp
OworCQlnZW1fZnVsbF91bmxvY2soZ3ApOwogCiAJCXJldHVybiAtRUFHQUlOOwogCX0KQEAgLTIy
NDMsMjIgKzIzMTgsMTQgQEAgc3RhdGljIGludCBnZW1fZG9fc3RhcnQoc3RydWN0IG5ldF9kZXZp
Ywogc3RhdGljIHZvaWQgZ2VtX2RvX3N0b3Aoc3RydWN0IG5ldF9kZXZpY2UgKmRldiwgaW50IHdv
bCkKIHsKIAlzdHJ1Y3QgZ2VtICpncCA9IGRldi0+cHJpdjsKLQl1bnNpZ25lZCBsb25nIGZsYWdz
OwotCi0Jc3Bpbl9sb2NrX2lycXNhdmUoJmdwLT5sb2NrLCBmbGFncyk7Ci0Jc3Bpbl9sb2NrKCZn
cC0+dHhfbG9jayk7Ci0KLQlncC0+cnVubmluZyA9IDA7Ci0KLQkvKiBTdG9wIG5ldGlmIHF1ZXVl
ICovCi0JbmV0aWZfc3RvcF9xdWV1ZShkZXYpOwogCi0JLyogTWFrZSBzdXJlIGludHMgYXJlIGRp
c2FibGVkICovCisJZ2VtX2Z1bGxfbG9jayhncCwgMSk7CiAJZ2VtX2Rpc2FibGVfaW50cyhncCk7
CisJCisJZ3AtPnJ1bm5pbmcgPSAwOwogCi0JLyogV2UgY2FuIGRyb3AgdGhlIGxvY2sgbm93ICov
Ci0Jc3Bpbl91bmxvY2soJmdwLT50eF9sb2NrKTsKLQlzcGluX3VubG9ja19pcnFyZXN0b3JlKCZn
cC0+bG9jaywgZmxhZ3MpOworCS8qIFdlIGNhbiBkcm9wIHRoZSBsb2NrIG5vdyB0aGF0IHJ1bm5p
bmcgaXMgc2V0IHRvIDAgKi8KKwlnZW1fZnVsbF91bmxvY2soZ3ApOwogCiAJLyogSWYgd2UgYXJl
IGdvaW5nIHRvIHNsZWVwIHdpdGggV09MICovCiAJZ2VtX3N0b3BfZG1hKGdwKTsKQEAgLTIyNzUs
OSArMjM0Miw5IEBAIHN0YXRpYyB2b2lkIGdlbV9kb19zdG9wKHN0cnVjdCBuZXRfZGV2aWMKIAog
CS8qIENlbGwgbm90IG5lZWRlZCBuZWl0aGVyIGlmIG5vIFdPTCAqLwogCWlmICghd29sKSB7Ci0J
CXNwaW5fbG9ja19pcnFzYXZlKCZncC0+bG9jaywgZmxhZ3MpOworCQlnZW1fZnVsbF9sb2NrKGdw
LCAwKTsKIAkJZ2VtX3B1dF9jZWxsKGdwKTsKLQkJc3Bpbl91bmxvY2tfaXJxcmVzdG9yZSgmZ3At
PmxvY2ssIGZsYWdzKTsKKwkJZ2VtX2Z1bGxfdW5sb2NrKGdwKTsKIAl9CiB9CiAKQEAgLTIyODcs
MzAgKzIzNTQsMjYgQEAgc3RhdGljIHZvaWQgZ2VtX3Jlc2V0X3Rhc2sodm9pZCAqZGF0YSkKIAog
CW11dGV4X2xvY2soJmdwLT5wbV9tdXRleCk7CiAKLQluZXRpZl9wb2xsX2Rpc2FibGUoZ3AtPmRl
dik7Ci0KLQlzcGluX2xvY2tfaXJxKCZncC0+bG9jayk7Ci0Jc3Bpbl9sb2NrKCZncC0+dHhfbG9j
ayk7CisJZ2VtX2Z1bGxfbG9jayhncCwgMSk7CisJZ2VtX2Rpc2FibGVfaW50cyhncCk7CiAKIAlp
ZiAoZ3AtPnJ1bm5pbmcgPT0gMCkKIAkJZ290byBub3RfcnVubmluZzsKIAotCWlmIChncC0+cnVu
bmluZykgewotCQluZXRpZl9zdG9wX3F1ZXVlKGdwLT5kZXYpOworCWdlbV9uZXRpZl9zdG9wKGdw
KTsKIAotCQkvKiBSZXNldCB0aGUgY2hpcCAmIHJpbmdzICovCi0JCWdlbV9yZWluaXRfY2hpcChn
cCk7Ci0JCWlmIChncC0+bHN0YXRlID09IGxpbmtfdXApCi0JCQlnZW1fc2V0X2xpbmtfbW9kZXMo
Z3ApOwotCQluZXRpZl93YWtlX3F1ZXVlKGdwLT5kZXYpOwotCX0KLSBub3RfcnVubmluZzoKLQln
cC0+cmVzZXRfdGFza19wZW5kaW5nID0gMDsKKwkvKiBSZXNldCB0aGUgY2hpcCAmIHJpbmdzICov
CisJZ2VtX3JlaW5pdF9jaGlwKGdwKTsKKwlpZiAoZ3AtPmxzdGF0ZSA9PSBsaW5rX3VwKQorCQln
ZW1fc2V0X2xpbmtfbW9kZXMoZ3ApOwogCi0Jc3Bpbl91bmxvY2soJmdwLT50eF9sb2NrKTsKLQlz
cGluX3VubG9ja19pcnEoJmdwLT5sb2NrKTsKKwlnZW1fbmV0aWZfc3RhcnQoZ3ApOwogCi0JbmV0
aWZfcG9sbF9lbmFibGUoZ3AtPmRldik7Citub3RfcnVubmluZzoKKwlncC0+cmVzZXRfdGFza19w
ZW5kaW5nID0gMDsKKworCWdlbV9lbmFibGVfaW50cyhncCk7CisJZ2VtX2Z1bGxfdW5sb2NrKGdw
KTsKIAogCW11dGV4X3VubG9jaygmZ3AtPnBtX211dGV4KTsKIH0KQEAgLTIzMjQsOCArMjM4Nywx
MiBAQCBzdGF0aWMgaW50IGdlbV9vcGVuKHN0cnVjdCBuZXRfZGV2aWNlICpkCiAJbXV0ZXhfbG9j
aygmZ3AtPnBtX211dGV4KTsKIAogCS8qIFdlIG5lZWQgdGhlIGNlbGwgZW5hYmxlZCAqLwotCWlm
ICghZ3AtPmFzbGVlcCkKKwlpZiAoIWdwLT5hc2xlZXApIHsKIAkJcmMgPSBnZW1fZG9fc3RhcnQo
ZGV2KTsKKwkJaWYgKHJjID09IDApCisJCQluZXRpZl9zdGFydF9xdWV1ZShkZXYpOworCX0KKwog
CWdwLT5vcGVuZWQgPSAocmMgPT0gMCk7CiAKIAltdXRleF91bmxvY2soJmdwLT5wbV9tdXRleCk7
CkBAIC0yMzM3LDE1ICsyNDA0LDE0IEBAIHN0YXRpYyBpbnQgZ2VtX2Nsb3NlKHN0cnVjdCBuZXRf
ZGV2aWNlICoKIHsKIAlzdHJ1Y3QgZ2VtICpncCA9IGRldi0+cHJpdjsKIAotCS8qIE5vdGU6IHdl
IGRvbid0IG5lZWQgdG8gY2FsbCBuZXRpZl9wb2xsX2Rpc2FibGUoKSBoZXJlIGJlY2F1c2UKLQkg
KiBvdXIgY2FsbGVyIChkZXZfY2xvc2UpIGFscmVhZHkgZGlkIGl0IGZvciB1cwotCSAqLwotCiAJ
bXV0ZXhfbG9jaygmZ3AtPnBtX211dGV4KTsKIAogCWdwLT5vcGVuZWQgPSAwOwotCWlmICghZ3At
PmFzbGVlcCkKKwlpZiAoIWdwLT5hc2xlZXApIHsKKwkJLyogVXBwZXIgbGF5ZXIgdG9vayBjYXJl
IG9mIGRpc2FibGluZyBwb2xsaW5nICovCisJCW5ldGlmX3N0b3BfcXVldWUoZGV2KTsKIAkJZ2Vt
X2RvX3N0b3AoZGV2LCAwKTsKKwl9CiAKIAltdXRleF91bmxvY2soJmdwLT5wbV9tdXRleCk7CiAK
QEAgLTIzNTcsMjIgKzI0MjMsMTcgQEAgc3RhdGljIGludCBnZW1fc3VzcGVuZChzdHJ1Y3QgcGNp
X2RldiAqcAogewogCXN0cnVjdCBuZXRfZGV2aWNlICpkZXYgPSBwY2lfZ2V0X2RydmRhdGEocGRl
dik7CiAJc3RydWN0IGdlbSAqZ3AgPSBkZXYtPnByaXY7Ci0JdW5zaWduZWQgbG9uZyBmbGFnczsK
IAogCW11dGV4X2xvY2soJmdwLT5wbV9tdXRleCk7CiAKLQluZXRpZl9wb2xsX2Rpc2FibGUoZGV2
KTsKLQogCXByaW50ayhLRVJOX0lORk8gIiVzOiBzdXNwZW5kaW5nLCBXYWtlT25MYW4gJXNcbiIs
CiAJICAgICAgIGRldi0+bmFtZSwKIAkgICAgICAgKGdwLT53YWtlX29uX2xhbiAmJiBncC0+b3Bl
bmVkKSA/ICJlbmFibGVkIiA6ICJkaXNhYmxlZCIpOwogCiAJLyogS2VlcCB0aGUgY2VsbCBlbmFi
bGVkIGR1cmluZyB0aGUgZW50aXJlIG9wZXJhdGlvbiAqLwotCXNwaW5fbG9ja19pcnFzYXZlKCZn
cC0+bG9jaywgZmxhZ3MpOwotCXNwaW5fbG9jaygmZ3AtPnR4X2xvY2spOworCWdlbV9mdWxsX2xv
Y2soZ3AsIDApOwogCWdlbV9nZXRfY2VsbChncCk7Ci0Jc3Bpbl91bmxvY2soJmdwLT50eF9sb2Nr
KTsKLQlzcGluX3VubG9ja19pcnFyZXN0b3JlKCZncC0+bG9jaywgZmxhZ3MpOworCWdlbV9mdWxs
X3VubG9jayhncCk7CiAKIAkvKiBJZiB0aGUgZHJpdmVyIGlzIG9wZW5lZCwgd2Ugc3RvcCB0aGUg
TUFDICovCiAJaWYgKGdwLT5vcGVuZWQpIHsKQEAgLTIzODEsNiArMjQ0Miw3IEBAIHN0YXRpYyBp
bnQgZ2VtX3N1c3BlbmQoc3RydWN0IHBjaV9kZXYgKnAKIAogCQkvKiBTd2l0Y2ggb2ZmIE1BQywg
cmVtZW1iZXIgV09MIHNldHRpbmcgKi8KIAkJZ3AtPmFzbGVlcF93b2wgPSBncC0+d2FrZV9vbl9s
YW47CisJCWdlbV9uZXRpZl9zdG9wKGdwKTsKIAkJZ2VtX2RvX3N0b3AoZGV2LCBncC0+YXNsZWVw
X3dvbCk7CiAJfSBlbHNlCiAJCWdwLT5hc2xlZXBfd29sID0gMDsKQEAgLTIzOTksOCArMjQ2MSw3
IEBAIHN0YXRpYyBpbnQgZ2VtX3N1c3BlbmQoc3RydWN0IHBjaV9kZXYgKnAKIAltdXRleF91bmxv
Y2soJmdwLT5wbV9tdXRleCk7CiAKIAkvKiBXYWl0IGZvciBhIHBlbmRpbmcgcmVzZXQgdGFzayB0
byBjb21wbGV0ZSAqLwotCXdoaWxlIChncC0+cmVzZXRfdGFza19wZW5kaW5nKQotCQl5aWVsZCgp
OworCWdlbV93YWl0X3Jlc2V0X3Rhc2soZ3ApOwogCWZsdXNoX3NjaGVkdWxlZF93b3JrKCk7CiAK
IAkvKiBTaHV0IHRoZSBQSFkgZG93biBldmVudHVhbGx5IGFuZCBzZXR1cCBXT0wgKi8KQEAgLTI0
MjEsNyArMjQ4Miw2IEBAIHN0YXRpYyBpbnQgZ2VtX3Jlc3VtZShzdHJ1Y3QgcGNpX2RldiAqcGQK
IHsKIAlzdHJ1Y3QgbmV0X2RldmljZSAqZGV2ID0gcGNpX2dldF9kcnZkYXRhKHBkZXYpOwogCXN0
cnVjdCBnZW0gKmdwID0gZGV2LT5wcml2OwotCXVuc2lnbmVkIGxvbmcgZmxhZ3M7CiAKIAlwcmlu
dGsoS0VSTl9JTkZPICIlczogcmVzdW1pbmdcbiIsIGRldi0+bmFtZSk7CiAKQEAgLTI0NjUsMTEg
KzI1MjUsOSBAQCBzdGF0aWMgaW50IGdlbV9yZXN1bWUoc3RydWN0IHBjaV9kZXYgKnBkCiAKIAkJ
LyogUmUtYXR0YWNoIG5ldCBkZXZpY2UgKi8KIAkJbmV0aWZfZGV2aWNlX2F0dGFjaChkZXYpOwot
CiAJfQogCi0Jc3Bpbl9sb2NrX2lycXNhdmUoJmdwLT5sb2NrLCBmbGFncyk7Ci0Jc3Bpbl9sb2Nr
KCZncC0+dHhfbG9jayk7CisJZ2VtX2Z1bGxfbG9jayhncCwgMCk7CiAKIAkvKiBJZiB3ZSBoYWQg
V09MIGVuYWJsZWQsIHRoZSBjZWxsIGNsb2NrIHdhcyBuZXZlciB0dXJuZWQgb2ZmIGR1cmluZwog
CSAqIHNsZWVwLCBzbyB3ZSBlbmQgdXAgYmVlaW5nIHVuYmFsYW5jZWQuIEZpeCB0aGF0IGhlcmUK
QEAgLTI0ODIsMTAgKzI1NDAsOSBAQCBzdGF0aWMgaW50IGdlbV9yZXN1bWUoc3RydWN0IHBjaV9k
ZXYgKnBkCiAJICovCiAJZ2VtX3B1dF9jZWxsKGdwKTsKIAotCXNwaW5fdW5sb2NrKCZncC0+dHhf
bG9jayk7Ci0Jc3Bpbl91bmxvY2tfaXJxcmVzdG9yZSgmZ3AtPmxvY2ssIGZsYWdzKTsKKwlnZW1f
ZnVsbF91bmxvY2soZ3ApOwogCi0JbmV0aWZfcG9sbF9lbmFibGUoZGV2KTsKKwlnZW1fbmV0aWZf
c3RhcnQoZ3ApOwogCiAJbXV0ZXhfdW5sb2NrKCZncC0+cG1fbXV0ZXgpOwogCkBAIC0yNDk4LDgg
KzI1NTUsOCBAQCBzdGF0aWMgc3RydWN0IG5ldF9kZXZpY2Vfc3RhdHMgKmdlbV9nZXRfCiAJc3Ry
dWN0IGdlbSAqZ3AgPSBkZXYtPnByaXY7CiAJc3RydWN0IG5ldF9kZXZpY2Vfc3RhdHMgKnN0YXRz
ID0gJmdwLT5uZXRfc3RhdHM7CiAKLQlzcGluX2xvY2tfaXJxKCZncC0+bG9jayk7Ci0Jc3Bpbl9s
b2NrKCZncC0+dHhfbG9jayk7CisJZ2VtX25ldGlmX3N0b3AoZ3ApOworCWdlbV9mdWxsX2xvY2so
Z3AsIDApOwogCiAJLyogSSBoYXZlIHNlZW4gdGhpcyBiZWluZyBjYWxsZWQgd2hpbGUgdGhlIFBN
IHdhcyBpbiBwcm9ncmVzcywKIAkgKiBzbyB3ZSBzaGllbGQgYWdhaW5zdCB0aGlzCkBAIC0yNTIy
LDI3ICsyNTc5LDI2IEBAIHN0YXRpYyBzdHJ1Y3QgbmV0X2RldmljZV9zdGF0cyAqZ2VtX2dldF8K
IAkJd3JpdGVsKDAsIGdwLT5yZWdzICsgTUFDX0xDT0xMKTsKIAl9CiAKLQlzcGluX3VubG9jaygm
Z3AtPnR4X2xvY2spOwotCXNwaW5fdW5sb2NrX2lycSgmZ3AtPmxvY2spOworCWdlbV9mdWxsX3Vu
bG9jayhncCk7CisJZ2VtX25ldGlmX3N0YXJ0KGdwKTsKIAogCXJldHVybiAmZ3AtPm5ldF9zdGF0
czsKIH0KIAorLyogZ2VtX3NldF9tdWx0aWNhc3QgaXMgY2FsbGVkIHdpdGggbmV0aWZfdHhfbG9j
ayBoZWxkLiBUaHVzLCBpdAorICogY2Fubm90IHNsZWVwLgorICovCiBzdGF0aWMgdm9pZCBnZW1f
c2V0X211bHRpY2FzdChzdHJ1Y3QgbmV0X2RldmljZSAqZGV2KQogewogCXN0cnVjdCBnZW0gKmdw
ID0gZGV2LT5wcml2OwogCXUzMiByeGNmZywgcnhjZmdfbmV3OwogCWludCBsaW1pdCA9IDEwMDAw
OwogCi0KLQlzcGluX2xvY2tfaXJxKCZncC0+bG9jayk7Ci0Jc3Bpbl9sb2NrKCZncC0+dHhfbG9j
ayk7CisJZ2VtX2Z1bGxfbG9jayhncCwgMCk7CiAKIAlpZiAoIWdwLT5ydW5uaW5nKQogCQlnb3Rv
IGJhaWw7CiAKLQluZXRpZl9zdG9wX3F1ZXVlKGRldik7Ci0KIAlyeGNmZyA9IHJlYWRsKGdwLT5y
ZWdzICsgTUFDX1JYQ0ZHKTsKIAlyeGNmZ19uZXcgPSBnZW1fc2V0dXBfbXVsdGljYXN0KGdwKTsK
ICNpZmRlZiBTVFJJUF9GQ1MKQEAgLTI1NjIsMTEgKzI2MTgsOCBAQCBzdGF0aWMgdm9pZCBnZW1f
c2V0X211bHRpY2FzdChzdHJ1Y3QgbmV0CiAKIAl3cml0ZWwocnhjZmcsIGdwLT5yZWdzICsgTUFD
X1JYQ0ZHKTsKIAotCW5ldGlmX3dha2VfcXVldWUoZGV2KTsKLQogIGJhaWw6Ci0Jc3Bpbl91bmxv
Y2soJmdwLT50eF9sb2NrKTsKLQlzcGluX3VubG9ja19pcnEoJmdwLT5sb2NrKTsKKwlnZW1fZnVs
bF91bmxvY2soZ3ApOwogfQogCiAvKiBKdW1iby1ncmFtcyBkb24ndCBzZWVtIHRvIHdvcmsgOi0o
ICovCkBAIC0yNTkzLDE2ICsyNjQ2LDIyIEBAIHN0YXRpYyBpbnQgZ2VtX2NoYW5nZV9tdHUoc3Ry
dWN0IG5ldF9kZXYKIAl9CiAKIAltdXRleF9sb2NrKCZncC0+cG1fbXV0ZXgpOwotCXNwaW5fbG9j
a19pcnEoJmdwLT5sb2NrKTsKLQlzcGluX2xvY2soJmdwLT50eF9sb2NrKTsKKworCWdlbV9uZXRp
Zl9zdG9wKGdwKTsKKwlnZW1fZnVsbF9sb2NrKGdwLCAxKTsKKwlnZW1fZGlzYWJsZV9pbnRzKGdw
KTsKKwkKIAlkZXYtPm10dSA9IG5ld19tdHU7CiAJaWYgKGdwLT5ydW5uaW5nKSB7CiAJCWdlbV9y
ZWluaXRfY2hpcChncCk7CiAJCWlmIChncC0+bHN0YXRlID09IGxpbmtfdXApCiAJCQlnZW1fc2V0
X2xpbmtfbW9kZXMoZ3ApOwogCX0KLQlzcGluX3VubG9jaygmZ3AtPnR4X2xvY2spOwotCXNwaW5f
dW5sb2NrX2lycSgmZ3AtPmxvY2spOworCisJZ2VtX25ldGlmX3N0YXJ0KGdwKTsKKwlnZW1fZW5h
YmxlX2ludHMoZ3ApOworCWdlbV9mdWxsX3VubG9jayhncCk7CisKIAltdXRleF91bmxvY2soJmdw
LT5wbV9tdXRleCk7CiAKIAlyZXR1cm4gMDsKQEAgLTI2MzUsNyArMjY5NCw3IEBAIHN0YXRpYyBp
bnQgZ2VtX2dldF9zZXR0aW5ncyhzdHJ1Y3QgbmV0X2QKIAkJY21kLT5waHlfYWRkcmVzcyA9IDA7
IC8qIFhYWCBmaXhlZCBQSFlBRCAqLwogCiAJCS8qIFJldHVybiBjdXJyZW50IFBIWSBzZXR0aW5n
cyAqLwotCQlzcGluX2xvY2tfaXJxKCZncC0+bG9jayk7CisJCWdlbV9mdWxsX2xvY2soZ3AsIDAp
OwogCQljbWQtPmF1dG9uZWcgPSBncC0+d2FudF9hdXRvbmVnOwogCQljbWQtPnNwZWVkID0gZ3At
PnBoeV9taWkuc3BlZWQ7CiAJCWNtZC0+ZHVwbGV4ID0gZ3AtPnBoeV9taWkuZHVwbGV4OwpAQCAt
MjY0Nyw3ICsyNzA2LDcgQEAgc3RhdGljIGludCBnZW1fZ2V0X3NldHRpbmdzKHN0cnVjdCBuZXRf
ZAogCQkgKi8KIAkJaWYgKGNtZC0+YWR2ZXJ0aXNpbmcgPT0gMCkKIAkJCWNtZC0+YWR2ZXJ0aXNp
bmcgPSBjbWQtPnN1cHBvcnRlZDsKLQkJc3Bpbl91bmxvY2tfaXJxKCZncC0+bG9jayk7CisJCWdl
bV9mdWxsX3VubG9jayhncCk7CiAJfSBlbHNlIHsgLy8gWFhYIFBDUyA/CiAJCWNtZC0+c3VwcG9y
dGVkID0KIAkJCShTVVBQT1JURURfMTBiYXNlVF9IYWxmIHwgU1VQUE9SVEVEXzEwYmFzZVRfRnVs
bCB8CkBAIC0yNjg1LDExICsyNzQ0LDExIEBAIHN0YXRpYyBpbnQgZ2VtX3NldF9zZXR0aW5ncyhz
dHJ1Y3QgbmV0X2QKIAkJcmV0dXJuIC1FSU5WQUw7CiAKIAkvKiBBcHBseSBzZXR0aW5ncyBhbmQg
cmVzdGFydCBsaW5rIHByb2Nlc3MuICovCi0Jc3Bpbl9sb2NrX2lycSgmZ3AtPmxvY2spOworCWdl
bV9mdWxsX2xvY2soZ3AsIDApOwogCWdlbV9nZXRfY2VsbChncCk7CiAJZ2VtX2JlZ2luX2F1dG9f
bmVnb3RpYXRpb24oZ3AsIGNtZCk7CiAJZ2VtX3B1dF9jZWxsKGdwKTsKLQlzcGluX3VubG9ja19p
cnEoJmdwLT5sb2NrKTsKKwlnZW1fZnVsbF91bmxvY2soZ3ApOwogCiAJcmV0dXJuIDA7CiB9CkBA
IC0yNzAyLDExICsyNzYxLDExIEBAIHN0YXRpYyBpbnQgZ2VtX253YXlfcmVzZXQoc3RydWN0IG5l
dF9kZXYKIAkJcmV0dXJuIC1FSU5WQUw7CiAKIAkvKiBSZXN0YXJ0IGxpbmsgcHJvY2Vzcy4gKi8K
LQlzcGluX2xvY2tfaXJxKCZncC0+bG9jayk7CisJZ2VtX2Z1bGxfbG9jayhncCwgMCk7CiAJZ2Vt
X2dldF9jZWxsKGdwKTsKIAlnZW1fYmVnaW5fYXV0b19uZWdvdGlhdGlvbihncCwgTlVMTCk7CiAJ
Z2VtX3B1dF9jZWxsKGdwKTsKLQlzcGluX3VubG9ja19pcnEoJmdwLT5sb2NrKTsKKwlnZW1fZnVs
bF91bmxvY2soZ3ApOwogCiAJcmV0dXJuIDA7CiB9CkBAIC0yNzcwLDE2ICsyODI5LDE1IEBAIHN0
YXRpYyBpbnQgZ2VtX2lvY3RsKHN0cnVjdCBuZXRfZGV2aWNlICoKIAlzdHJ1Y3QgZ2VtICpncCA9
IGRldi0+cHJpdjsKIAlzdHJ1Y3QgbWlpX2lvY3RsX2RhdGEgKmRhdGEgPSBpZl9taWkoaWZyKTsK
IAlpbnQgcmMgPSAtRU9QTk9UU1VQUDsKLQl1bnNpZ25lZCBsb25nIGZsYWdzOwogCiAJLyogSG9s
ZCB0aGUgUE0gbXV0ZXggd2hpbGUgZG9pbmcgaW9jdGwncyBvciB3ZSBtYXkgY29sbGlkZQogCSAq
IHdpdGggcG93ZXIgbWFuYWdlbWVudC4KIAkgKi8KIAltdXRleF9sb2NrKCZncC0+cG1fbXV0ZXgp
OwogCi0Jc3Bpbl9sb2NrX2lycXNhdmUoJmdwLT5sb2NrLCBmbGFncyk7CisJZ2VtX2Z1bGxfbG9j
ayhncCwgMCk7CiAJZ2VtX2dldF9jZWxsKGdwKTsKLQlzcGluX3VubG9ja19pcnFyZXN0b3JlKCZn
cC0+bG9jaywgZmxhZ3MpOworCWdlbV9mdWxsX3VubG9jayhncCk7CiAKIAlzd2l0Y2ggKGNtZCkg
ewogCWNhc2UgU0lPQ0dNSUlQSFk6CQkvKiBHZXQgYWRkcmVzcyBvZiBNSUkgUEhZIGluIHVzZS4g
Ki8KQEAgLTI4MDksOSArMjg2Nyw5IEBAIHN0YXRpYyBpbnQgZ2VtX2lvY3RsKHN0cnVjdCBuZXRf
ZGV2aWNlICoKIAkJYnJlYWs7CiAJfTsKIAotCXNwaW5fbG9ja19pcnFzYXZlKCZncC0+bG9jaywg
ZmxhZ3MpOworCWdlbV9mdWxsX2xvY2soZ3AsIDApOwogCWdlbV9wdXRfY2VsbChncCk7Ci0Jc3Bp
bl91bmxvY2tfaXJxcmVzdG9yZSgmZ3AtPmxvY2ssIGZsYWdzKTsKKwlnZW1fZnVsbF91bmxvY2so
Z3ApOwogCiAJbXV0ZXhfdW5sb2NrKCZncC0+cG1fbXV0ZXgpOwogCkBAIC0yOTE4LDYgKzI5NzYs
NyBAQCBzdGF0aWMgdm9pZCBnZW1fcmVtb3ZlX29uZShzdHJ1Y3QgcGNpX2RlCiAJaWYgKGRldikg
ewogCQlzdHJ1Y3QgZ2VtICpncCA9IGRldi0+cHJpdjsKIAorCQkvKiB1bnJlZ2lzdGVyX25ldGRl
diB3aWxsIGNsb3NlIHRoZSBkZXZpY2UgaWYgaXQncyBvcGVuICovCiAJCXVucmVnaXN0ZXJfbmV0
ZGV2KGRldik7CiAKIAkJLyogU3RvcCB0aGUgbGluayB0aW1lciAqLwpAQCAtMjkyNyw4ICsyOTg2
LDcgQEAgc3RhdGljIHZvaWQgZ2VtX3JlbW92ZV9vbmUoc3RydWN0IHBjaV9kZQogCQlnZW1fZ2V0
X2NlbGwoZ3ApOwogCiAJCS8qIFdhaXQgZm9yIGEgcGVuZGluZyByZXNldCB0YXNrIHRvIGNvbXBs
ZXRlICovCi0JCXdoaWxlIChncC0+cmVzZXRfdGFza19wZW5kaW5nKQotCQkJeWllbGQoKTsKKwkJ
Z2VtX3dhaXRfcmVzZXRfdGFzayhncCk7CiAJCWZsdXNoX3NjaGVkdWxlZF93b3JrKCk7CiAKIAkJ
LyogU2h1dCB0aGUgUEhZIGRvd24gKi8KQEAgLTMwMzUsOCArMzA5MywxMSBAQCBzdGF0aWMgaW50
IF9fZGV2aW5pdCBnZW1faW5pdF9vbmUoc3RydWN0CiAKIAlncC0+bXNnX2VuYWJsZSA9IERFRkFV
TFRfTVNHOwogCisJZ3AtPmlycV9zeW5jID0gMDsKIAlzcGluX2xvY2tfaW5pdCgmZ3AtPmxvY2sp
OwotCXNwaW5fbG9ja19pbml0KCZncC0+dHhfbG9jayk7CisjaWYgIUdFTV9JTlRFUlJVUFRfTE9D
S0xFU1MKKwlzcGluX2xvY2tfaW5pdCgmZ3AtPmludF9sb2NrKTsKKyNlbmRpZgogCW11dGV4X2lu
aXQoJmdwLT5wbV9tdXRleCk7CiAKIAlpbml0X3RpbWVyKCZncC0+bGlua190aW1lcik7CkBAIC0z
MTMyLDkgKzMxOTMsNyBAQCBzdGF0aWMgaW50IF9fZGV2aW5pdCBnZW1faW5pdF9vbmUoc3RydWN0
CiAJICovCiAJZ2VtX2luaXRfcGh5KGdwKTsKIAotCXNwaW5fbG9ja19pcnEoJmdwLT5sb2NrKTsK
IAlnZW1fcHV0X2NlbGwoZ3ApOwotCXNwaW5fdW5sb2NrX2lycSgmZ3AtPmxvY2spOwogCiAJLyog
UmVnaXN0ZXIgd2l0aCBrZXJuZWwgKi8KIAlpZiAocmVnaXN0ZXJfbmV0ZGV2KGRldikpIHsKQEAg
LTMxNTYsOCArMzIxNSw3IEBAIHN0YXRpYyBpbnQgX19kZXZpbml0IGdlbV9pbml0X29uZShzdHJ1
Y3QKIAkJcHJpbnRrKEtFUk5fSU5GTyAiJXM6IEZvdW5kICVzIFBIWVxuIiwgZGV2LT5uYW1lLAog
CQkJZ3AtPnBoeV9taWkuZGVmID8gZ3AtPnBoeV9taWkuZGVmLT5uYW1lIDogIm5vIik7CiAKLQkv
KiBHRU0gY2FuIGRvIGl0IGFsbC4uLiAqLwotCWRldi0+ZmVhdHVyZXMgfD0gTkVUSUZfRl9TRyB8
IE5FVElGX0ZfSFdfQ1NVTSB8IE5FVElGX0ZfTExUWDsKKwlkZXYtPmZlYXR1cmVzIHw9IE5FVElG
X0ZfU0cgfCBORVRJRl9GX0hXX0NTVU07CiAJaWYgKHBjaV91c2luZ19kYWMpCiAJCWRldi0+ZmVh
dHVyZXMgfD0gTkVUSUZfRl9ISUdIRE1BOwogCkBAIC0zMTc3LDcgKzMyMzUsNiBAQCBlcnJfb3V0
X2ZyZWVfbmV0ZGV2OgogZXJyX2Rpc2FibGVfZGV2aWNlOgogCXBjaV9kaXNhYmxlX2RldmljZShw
ZGV2KTsKIAlyZXR1cm4gZXJyOwotCiB9CiAKIApkaWZmIC0tZ2l0IGEvZHJpdmVycy9uZXQvc3Vu
Z2VtLmggYi9kcml2ZXJzL25ldC9zdW5nZW0uaAppbmRleCBhNzAwNjdjLi5jMDRhMzIwIDEwMDY0
NAotLS0gYS9kcml2ZXJzL25ldC9zdW5nZW0uaAorKysgYi9kcml2ZXJzL25ldC9zdW5nZW0uaApA
QCAtNyw2ICs3LDggQEAKICNpZm5kZWYgX1NVTkdFTV9ICiAjZGVmaW5lIF9TVU5HRU1fSAogCisj
ZGVmaW5lIEdFTV9JTlRFUlJVUFRfTE9DS0xFU1MgMSAvKiBUT0RPICovCisKIC8qIEdsb2JhbCBS
ZWdpc3RlcnMgKi8KICNkZWZpbmUgR1JFR19TRUJTVEFURQkweDAwMDBVTAkvKiBTRUIgU3RhdGUg
UmVnaXN0ZXIJCSovCiAjZGVmaW5lIEdSRUdfQ0ZHCTB4MDAwNFVMCS8qIENvbmZpZ3VyYXRpb24g
UmVnaXN0ZXIJKi8KQEAgLTYwLDYgKzYyLDEwIEBACiAJCQkJIEdSRUdfU1RBVF9QQ1MgfCBHUkVH
X1NUQVRfVFhNQUMgfCBHUkVHX1NUQVRfUlhNQUMgfCBcCiAJCQkJIEdSRUdfU1RBVF9NQUMgfCBH
UkVHX1NUQVRfTUlGIHwgR1JFR19TVEFUX1BDSUVSUikKIAorLyogQml0bWFzayByZXByZXNlbnRp
bmcgdGhlIGludGVycnVwdCBjb25kaXRpb25zIHRoZSBkcml2ZXIgaGFuZGxlcy4gVGhlIFRYRE9O
RQorICogaW50ZXJydXB0IGNvbmRpdGlvbiBpc24ndCBoYW5kbGVkIGFzIHdlIHdhbnQgdG8gYXZv
aWQgaGF2aW5nIG9uZSBpbnRlcnJ1cHQKKyAqIHBlciB0cmFuc21pdHRlZCBmcmFtZS4KKyAqLwog
I2RlZmluZSBHUkVHX1NUQVRfTkFQSQkJKEdSRUdfU1RBVF9UWEFMTCAgfCBHUkVHX1NUQVRfVFhJ
TlRNRSB8IFwKIAkJCQkgR1JFR19TVEFUX1JYRE9ORSB8IEdSRUdfU1RBVF9BQk5PUk1BTCkKIApA
QCAtNzEsNiArNzcsMTUgQEAKICAqIG9uIEdSRUdfU1RBVC4KICAqLwogCisjaWYgR0VNX0lOVEVS
UlVQVF9MT0NLTEVTUworCisvKiBCaXRtYXNrIHJlcHJlc2VudGluZyB0aGUgaW50ZXJydXB0IGNv
bmRpdGlvbnMgdGhhdCB3ZSBjbGVhciB1c2luZyBHUkVHX0lBQ0suCisgKiBXZSBjbGVhciBhbGwg
dGhlIHRvcC1sZXZlbCBpbnRlcnJ1cHQgY29uZGl0aW9ucyAoYml0cyAwIHRocm91Z2ggNikgdGhh
dCB3ZQorICogaGFuZGxlLgorICovCisjZGVmaW5lIEdSRUdfU1RBVF9JQUNLCQkoR1JFR19TVEFU
X05BUEkgJiAweDNmKQorI2VuZGlmCisKIC8qIEdsb2JhbCBQQ0kgRXJyb3IgU3RhdHVzIFJlZ2lz
dGVyICovCiAjZGVmaW5lIEdSRUdfUENJRVNUQVRfQkFEQUNLCTB4MDAwMDAwMDEJLyogTm8gQUNL
NjQjIGR1cmluZyBBQlM2NCBjeWNsZQkqLwogI2RlZmluZSBHUkVHX1BDSUVTVEFUX0RUUlRPCTB4
MDAwMDAwMDIJLyogRGVsYXllZCB0cmFuc2FjdGlvbiB0aW1lb3V0CSovCkBAIC05NzMsOCArOTg4
LDExIEBAIGVudW0gbGlua19zdGF0ZSB7CiB9OwogCiBzdHJ1Y3QgZ2VtIHsKKwlpbnQJCQlpcnFf
c3luYzsKIAlzcGlubG9ja190CQlsb2NrOwotCXNwaW5sb2NrX3QJCXR4X2xvY2s7CisjaWYgIUdF
TV9JTlRFUlJVUFRfTE9DS0xFU1MKKwlzcGlubG9ja190CQlpbnRfbG9jazsKKyNlbmRpZgogCXZv
aWQgX19pb21lbQkJKnJlZ3M7CiAJaW50CQkJcnhfbmV3LCByeF9vbGQ7CiAJaW50CQkJdHhfbmV3
LCB0eF9vbGQ7Cg==
------=_Part_16288_1066592.1163373109053--
