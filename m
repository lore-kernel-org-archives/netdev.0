From: "Eric Lemoine" <eric.lemoine@gmail.com>
Subject: Re: [patch sungem] improved locking
Date: Tue, 14 Nov 2006 22:54:40 +0100
Message-ID: <5cac192f0611141354l3a4aa130ve741c9d6a7a49d0a@mail.gmail.com>
References: <5cac192f0611121511w6a8fec54pdf6124b5f2f79a08@mail.gmail.com>
	 <20061113.164622.28395064.davem@davemloft.net>
	 <5cac192f0611132328i52d6d615g28d8c493dc028621@mail.gmail.com>
	 <20061113.234456.78492515.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_54207_22012202.1163541280161"
Cc: netdev@vger.kernel.org, benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:7998 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S966405AbWKNVyn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Nov 2006 16:54:43 -0500
Received: by ug-out-1314.google.com with SMTP id m3so1467927ugc
        for <netdev@vger.kernel.org>; Tue, 14 Nov 2006 13:54:41 -0800 (PST)
To: "David Miller" <davem@davemloft.net>
In-Reply-To: <20061113.234456.78492515.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_54207_22012202.1163541280161
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On 11/14/06, David Miller <davem@davemloft.net> wrote:
> From: "Eric Lemoine" <eric.lemoine@gmail.com>
> Date: Tue, 14 Nov 2006 08:28:42 +0100
>
> > because it makes it explicit that only bits 0 through 6 are taken into
> > account when writing the IACK register.
>
> The phrase "bits 0 through 6" doesn't make any sense when bit 3 DOES
> NOT EXIST in the hardware, it's reserved, it's not there, so including
> it only confuses people and obfuscates the code.
>
> Please use the explicit bit mask composed of existing macros, which
> not only makes sure that the mask has meaning, but it also makes sure
> that reserved and non-existing bits are never referenced.

Patch attached.

Remember, the GEM_INTERRUPT_LOCKLESS isn't there to stay. It's
currently there because I'm not sure the lockless implementation of
gem_interrupt() will work with poll_net_controller.

Thanks,

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
@@ -1775,12 +1865,9 @@ #endif
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
@@ -1943,7 +2028,6 @@ #endif
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
@@ -2562,11 +2618,8 @@ #endif

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
@@ -3132,9 +3193,7 @@ #endif
 	 */
 	gem_init_phy(gp);

-	spin_lock_irq(&gp->lock);
 	gem_put_cell(gp);
-	spin_unlock_irq(&gp->lock);

 	/* Register with kernel */
 	if (register_netdev(dev)) {
@@ -3156,8 +3215,7 @@ #endif
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
index a70067c..49d3aa5 100644
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
@@ -71,6 +73,11 @@ #define GREG_STAT_NAPI		(GREG_STAT_TXALL
  * on GREG_STAT.
  */

+#if GEM_INTERRUPT_LOCKLESS
+#define GREG_STAT_IACK		(GREG_STAT_TXALL  | GREG_STAT_TXINTME | \
+				 GREG_STAT_RXDONE | GREG_STAT_RXNOBUF)
+#endif
+
 /* Global PCI Error Status Register */
 #define GREG_PCIESTAT_BADACK	0x00000001	/* No ACK64# during ABS64 cycle	*/
 #define GREG_PCIESTAT_DTRTO	0x00000002	/* Delayed transaction timeout	*/
@@ -973,8 +980,11 @@ enum link_state {
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

------=_Part_54207_22012202.1163541280161
Content-Type: text/x-patch; name=sungem-locking.patch;
	charset=ANSI_X3.4-1968
Content-Transfer-Encoding: base64
X-Attachment-Id: f_euiu5ude
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
ICpnYiA9IGdwLT5pbml0X2Jsb2NrOwpAQCAtMTc3NSwxMiArMTg2NSw5IEBAICNlbmRpZgogCW5l
dGlmX2NhcnJpZXJfb2ZmKGdwLT5kZXYpOwogCiAJLyogQ2FuIEkgYWR2ZXJ0aXNlIGdpZ2FiaXQg
aGVyZSA/IEknZCBuZWVkIEJDTSBQSFkgZG9jcy4uLiAqLwotCXNwaW5fbG9ja19pcnEoJmdwLT5s
b2NrKTsKIAlnZW1fYmVnaW5fYXV0b19uZWdvdGlhdGlvbihncCwgTlVMTCk7Ci0Jc3Bpbl91bmxv
Y2tfaXJxKCZncC0+bG9jayk7CiB9CiAKLS8qIE11c3QgYmUgaW52b2tlZCB1bmRlciBncC0+bG9j
ayBhbmQgZ3AtPnR4X2xvY2suICovCiBzdGF0aWMgdm9pZCBnZW1faW5pdF9kbWEoc3RydWN0IGdl
bSAqZ3ApCiB7CiAJdTY0IGRlc2NfZG1hID0gKHU2NCkgZ3AtPmdibG9ja19kdm1hOwpAQCAtMTgx
OCw3ICsxOTA1LDYgQEAgc3RhdGljIHZvaWQgZ2VtX2luaXRfZG1hKHN0cnVjdCBnZW0gKmdwKQog
CQkgICAgICAgZ3AtPnJlZ3MgKyBSWERNQV9CTEFOSyk7CiB9CiAKLS8qIE11c3QgYmUgaW52b2tl
ZCB1bmRlciBncC0+bG9jayBhbmQgZ3AtPnR4X2xvY2suICovCiBzdGF0aWMgdTMyIGdlbV9zZXR1
cF9tdWx0aWNhc3Qoc3RydWN0IGdlbSAqZ3ApCiB7CiAJdTMyIHJ4Y2ZnID0gMDsKQEAgLTE4NjAs
NyArMTk0Niw2IEBAIHN0YXRpYyB1MzIgZ2VtX3NldHVwX211bHRpY2FzdChzdHJ1Y3QgZ2UKIAly
ZXR1cm4gcnhjZmc7CiB9CiAKLS8qIE11c3QgYmUgaW52b2tlZCB1bmRlciBncC0+bG9jayBhbmQg
Z3AtPnR4X2xvY2suICovCiBzdGF0aWMgdm9pZCBnZW1faW5pdF9tYWMoc3RydWN0IGdlbSAqZ3Ap
CiB7CiAJdW5zaWduZWQgY2hhciAqZSA9ICZncC0+ZGV2LT5kZXZfYWRkclswXTsKQEAgLTE5NDMs
NyArMjAyOCw2IEBAICNlbmRpZgogCQl3cml0ZWwoMCwgZ3AtPnJlZ3MgKyBXT0xfV0FLRUNTUik7
CiB9CiAKLS8qIE11c3QgYmUgaW52b2tlZCB1bmRlciBncC0+bG9jayBhbmQgZ3AtPnR4X2xvY2su
ICovCiBzdGF0aWMgdm9pZCBnZW1faW5pdF9wYXVzZV90aHJlc2hvbGRzKHN0cnVjdCBnZW0gKmdw
KQogewogICAgICAgIAl1MzIgY2ZnOwpAQCAtMjA5Niw3ICsyMTgwLDYgQEAgc3RhdGljIGludCBn
ZW1fY2hlY2tfaW52YXJpYW50cyhzdHJ1Y3QgZwogCXJldHVybiAwOwogfQogCi0vKiBNdXN0IGJl
IGludm9rZWQgdW5kZXIgZ3AtPmxvY2sgYW5kIGdwLT50eF9sb2NrLiAqLwogc3RhdGljIHZvaWQg
Z2VtX3JlaW5pdF9jaGlwKHN0cnVjdCBnZW0gKmdwKQogewogCS8qIFJlc2V0IHRoZSBjaGlwICov
CkBAIC0yMTE2LDEyICsyMTk5LDEwIEBAIHN0YXRpYyB2b2lkIGdlbV9yZWluaXRfY2hpcChzdHJ1
Y3QgZ2VtICoKIAlnZW1faW5pdF9tYWMoZ3ApOwogfQogCi0KIC8qIE11c3QgYmUgaW52b2tlZCB3
aXRoIG5vIGxvY2sgaGVsZC4gKi8KIHN0YXRpYyB2b2lkIGdlbV9zdG9wX3BoeShzdHJ1Y3QgZ2Vt
ICpncCwgaW50IHdvbCkKIHsKIAl1MzIgbWlmY2ZnOwotCXVuc2lnbmVkIGxvbmcgZmxhZ3M7CiAK
IAkvKiBMZXQgdGhlIGNoaXAgc2V0dGxlIGRvd24gYSBiaXQsIGl0IHNlZW1zIHRoYXQgaGVscHMK
IAkgKiBmb3Igc2xlZXAgbW9kZSBvbiBzb21lIG1vZGVscwpAQCAtMjE2NywxMyArMjI0OCwxMyBA
QCBzdGF0aWMgdm9pZCBnZW1fc3RvcF9waHkoc3RydWN0IGdlbSAqZ3AsCiAJd3JpdGVsKDAsIGdw
LT5yZWdzICsgUlhETUFfQ0ZHKTsKIAogCWlmICghd29sKSB7Ci0JCXNwaW5fbG9ja19pcnFzYXZl
KCZncC0+bG9jaywgZmxhZ3MpOwotCQlzcGluX2xvY2soJmdwLT50eF9sb2NrKTsKKwkJZ2VtX2Z1
bGxfbG9jayhncCwgMCk7CisKIAkJZ2VtX3Jlc2V0KGdwKTsKIAkJd3JpdGVsKE1BQ19UWFJTVF9D
TUQsIGdwLT5yZWdzICsgTUFDX1RYUlNUKTsKIAkJd3JpdGVsKE1BQ19SWFJTVF9DTUQsIGdwLT5y
ZWdzICsgTUFDX1JYUlNUKTsKLQkJc3Bpbl91bmxvY2soJmdwLT50eF9sb2NrKTsKLQkJc3Bpbl91
bmxvY2tfaXJxcmVzdG9yZSgmZ3AtPmxvY2ssIGZsYWdzKTsKKworCQlnZW1fZnVsbF91bmxvY2so
Z3ApOwogCiAJCS8qIE5vIG5lZWQgdG8gdGFrZSB0aGUgbG9jayBoZXJlICovCiAKQEAgLTIxOTIs
MTQgKzIyNzMsMTEgQEAgc3RhdGljIHZvaWQgZ2VtX3N0b3BfcGh5KHN0cnVjdCBnZW0gKmdwLAog
CX0KIH0KIAotCiBzdGF0aWMgaW50IGdlbV9kb19zdGFydChzdHJ1Y3QgbmV0X2RldmljZSAqZGV2
KQogewogCXN0cnVjdCBnZW0gKmdwID0gZGV2LT5wcml2OwotCXVuc2lnbmVkIGxvbmcgZmxhZ3M7
CiAKLQlzcGluX2xvY2tfaXJxc2F2ZSgmZ3AtPmxvY2ssIGZsYWdzKTsKLQlzcGluX2xvY2soJmdw
LT50eF9sb2NrKTsKKwlnZW1fZnVsbF9sb2NrKGdwLCAwKTsKIAogCS8qIEVuYWJsZSB0aGUgY2Vs
bCAqLwogCWdlbV9nZXRfY2VsbChncCk7CkBAIC0yMjExLDI4ICsyMjg5LDI1IEBAIHN0YXRpYyBp
bnQgZ2VtX2RvX3N0YXJ0KHN0cnVjdCBuZXRfZGV2aWMKIAogCWlmIChncC0+bHN0YXRlID09IGxp
bmtfdXApIHsKIAkJbmV0aWZfY2Fycmllcl9vbihncC0+ZGV2KTsKKwkJLyogZ2VtX3NldF9saW5r
X21vZGVzIHN0YXJ0cyBETUEgYW5kIGVuYWJsZWQgaW50cyAqLwogCQlnZW1fc2V0X2xpbmtfbW9k
ZXMoZ3ApOwogCX0KIAotCW5ldGlmX3dha2VfcXVldWUoZ3AtPmRldik7Ci0KLQlzcGluX3VubG9j
aygmZ3AtPnR4X2xvY2spOwotCXNwaW5fdW5sb2NrX2lycXJlc3RvcmUoJmdwLT5sb2NrLCBmbGFn
cyk7CisJZ2VtX2Z1bGxfdW5sb2NrKGdwKTsKIAogCWlmIChyZXF1ZXN0X2lycShncC0+cGRldi0+
aXJxLCBnZW1faW50ZXJydXB0LAotCQkJCSAgIElSUUZfU0hBUkVELCBkZXYtPm5hbWUsICh2b2lk
ICopZGV2KSkgeworCQkgICAgICAgIElSUUZfU0hBUkVELCBkZXYtPm5hbWUsICh2b2lkICopZGV2
KSkgeworCiAJCXByaW50ayhLRVJOX0VSUiAiJXM6IGZhaWxlZCB0byByZXF1ZXN0IGlycSAhXG4i
LCBncC0+ZGV2LT5uYW1lKTsKIAotCQlzcGluX2xvY2tfaXJxc2F2ZSgmZ3AtPmxvY2ssIGZsYWdz
KTsKLQkJc3Bpbl9sb2NrKCZncC0+dHhfbG9jayk7CisJCWdlbV9mdWxsX2xvY2soZ3AsIDApOwog
CiAJCWdwLT5ydW5uaW5nID0gIDA7CiAJCWdlbV9yZXNldChncCk7CiAJCWdlbV9jbGVhbl9yaW5n
cyhncCk7CiAJCWdlbV9wdXRfY2VsbChncCk7CiAKLQkJc3Bpbl91bmxvY2soJmdwLT50eF9sb2Nr
KTsKLQkJc3Bpbl91bmxvY2tfaXJxcmVzdG9yZSgmZ3AtPmxvY2ssIGZsYWdzKTsKKwkJZ2VtX2Z1
bGxfdW5sb2NrKGdwKTsKIAogCQlyZXR1cm4gLUVBR0FJTjsKIAl9CkBAIC0yMjQzLDIyICsyMzE4
LDE0IEBAIHN0YXRpYyBpbnQgZ2VtX2RvX3N0YXJ0KHN0cnVjdCBuZXRfZGV2aWMKIHN0YXRpYyB2
b2lkIGdlbV9kb19zdG9wKHN0cnVjdCBuZXRfZGV2aWNlICpkZXYsIGludCB3b2wpCiB7CiAJc3Ry
dWN0IGdlbSAqZ3AgPSBkZXYtPnByaXY7Ci0JdW5zaWduZWQgbG9uZyBmbGFnczsKLQotCXNwaW5f
bG9ja19pcnFzYXZlKCZncC0+bG9jaywgZmxhZ3MpOwotCXNwaW5fbG9jaygmZ3AtPnR4X2xvY2sp
OwotCi0JZ3AtPnJ1bm5pbmcgPSAwOwotCi0JLyogU3RvcCBuZXRpZiBxdWV1ZSAqLwotCW5ldGlm
X3N0b3BfcXVldWUoZGV2KTsKIAotCS8qIE1ha2Ugc3VyZSBpbnRzIGFyZSBkaXNhYmxlZCAqLwor
CWdlbV9mdWxsX2xvY2soZ3AsIDEpOwogCWdlbV9kaXNhYmxlX2ludHMoZ3ApOworCQorCWdwLT5y
dW5uaW5nID0gMDsKIAotCS8qIFdlIGNhbiBkcm9wIHRoZSBsb2NrIG5vdyAqLwotCXNwaW5fdW5s
b2NrKCZncC0+dHhfbG9jayk7Ci0Jc3Bpbl91bmxvY2tfaXJxcmVzdG9yZSgmZ3AtPmxvY2ssIGZs
YWdzKTsKKwkvKiBXZSBjYW4gZHJvcCB0aGUgbG9jayBub3cgdGhhdCBydW5uaW5nIGlzIHNldCB0
byAwICovCisJZ2VtX2Z1bGxfdW5sb2NrKGdwKTsKIAogCS8qIElmIHdlIGFyZSBnb2luZyB0byBz
bGVlcCB3aXRoIFdPTCAqLwogCWdlbV9zdG9wX2RtYShncCk7CkBAIC0yMjc1LDkgKzIzNDIsOSBA
QCBzdGF0aWMgdm9pZCBnZW1fZG9fc3RvcChzdHJ1Y3QgbmV0X2RldmljCiAKIAkvKiBDZWxsIG5v
dCBuZWVkZWQgbmVpdGhlciBpZiBubyBXT0wgKi8KIAlpZiAoIXdvbCkgewotCQlzcGluX2xvY2tf
aXJxc2F2ZSgmZ3AtPmxvY2ssIGZsYWdzKTsKKwkJZ2VtX2Z1bGxfbG9jayhncCwgMCk7CiAJCWdl
bV9wdXRfY2VsbChncCk7Ci0JCXNwaW5fdW5sb2NrX2lycXJlc3RvcmUoJmdwLT5sb2NrLCBmbGFn
cyk7CisJCWdlbV9mdWxsX3VubG9jayhncCk7CiAJfQogfQogCkBAIC0yMjg3LDMwICsyMzU0LDI2
IEBAIHN0YXRpYyB2b2lkIGdlbV9yZXNldF90YXNrKHZvaWQgKmRhdGEpCiAKIAltdXRleF9sb2Nr
KCZncC0+cG1fbXV0ZXgpOwogCi0JbmV0aWZfcG9sbF9kaXNhYmxlKGdwLT5kZXYpOwotCi0Jc3Bp
bl9sb2NrX2lycSgmZ3AtPmxvY2spOwotCXNwaW5fbG9jaygmZ3AtPnR4X2xvY2spOworCWdlbV9m
dWxsX2xvY2soZ3AsIDEpOworCWdlbV9kaXNhYmxlX2ludHMoZ3ApOwogCiAJaWYgKGdwLT5ydW5u
aW5nID09IDApCiAJCWdvdG8gbm90X3J1bm5pbmc7CiAKLQlpZiAoZ3AtPnJ1bm5pbmcpIHsKLQkJ
bmV0aWZfc3RvcF9xdWV1ZShncC0+ZGV2KTsKKwlnZW1fbmV0aWZfc3RvcChncCk7CiAKLQkJLyog
UmVzZXQgdGhlIGNoaXAgJiByaW5ncyAqLwotCQlnZW1fcmVpbml0X2NoaXAoZ3ApOwotCQlpZiAo
Z3AtPmxzdGF0ZSA9PSBsaW5rX3VwKQotCQkJZ2VtX3NldF9saW5rX21vZGVzKGdwKTsKLQkJbmV0
aWZfd2FrZV9xdWV1ZShncC0+ZGV2KTsKLQl9Ci0gbm90X3J1bm5pbmc6Ci0JZ3AtPnJlc2V0X3Rh
c2tfcGVuZGluZyA9IDA7CisJLyogUmVzZXQgdGhlIGNoaXAgJiByaW5ncyAqLworCWdlbV9yZWlu
aXRfY2hpcChncCk7CisJaWYgKGdwLT5sc3RhdGUgPT0gbGlua191cCkKKwkJZ2VtX3NldF9saW5r
X21vZGVzKGdwKTsKIAotCXNwaW5fdW5sb2NrKCZncC0+dHhfbG9jayk7Ci0Jc3Bpbl91bmxvY2tf
aXJxKCZncC0+bG9jayk7CisJZ2VtX25ldGlmX3N0YXJ0KGdwKTsKIAotCW5ldGlmX3BvbGxfZW5h
YmxlKGdwLT5kZXYpOworbm90X3J1bm5pbmc6CisJZ3AtPnJlc2V0X3Rhc2tfcGVuZGluZyA9IDA7
CisKKwlnZW1fZW5hYmxlX2ludHMoZ3ApOworCWdlbV9mdWxsX3VubG9jayhncCk7CiAKIAltdXRl
eF91bmxvY2soJmdwLT5wbV9tdXRleCk7CiB9CkBAIC0yMzI0LDggKzIzODcsMTIgQEAgc3RhdGlj
IGludCBnZW1fb3BlbihzdHJ1Y3QgbmV0X2RldmljZSAqZAogCW11dGV4X2xvY2soJmdwLT5wbV9t
dXRleCk7CiAKIAkvKiBXZSBuZWVkIHRoZSBjZWxsIGVuYWJsZWQgKi8KLQlpZiAoIWdwLT5hc2xl
ZXApCisJaWYgKCFncC0+YXNsZWVwKSB7CiAJCXJjID0gZ2VtX2RvX3N0YXJ0KGRldik7CisJCWlm
IChyYyA9PSAwKQorCQkJbmV0aWZfc3RhcnRfcXVldWUoZGV2KTsKKwl9CisKIAlncC0+b3BlbmVk
ID0gKHJjID09IDApOwogCiAJbXV0ZXhfdW5sb2NrKCZncC0+cG1fbXV0ZXgpOwpAQCAtMjMzNywx
NSArMjQwNCwxNCBAQCBzdGF0aWMgaW50IGdlbV9jbG9zZShzdHJ1Y3QgbmV0X2RldmljZSAqCiB7
CiAJc3RydWN0IGdlbSAqZ3AgPSBkZXYtPnByaXY7CiAKLQkvKiBOb3RlOiB3ZSBkb24ndCBuZWVk
IHRvIGNhbGwgbmV0aWZfcG9sbF9kaXNhYmxlKCkgaGVyZSBiZWNhdXNlCi0JICogb3VyIGNhbGxl
ciAoZGV2X2Nsb3NlKSBhbHJlYWR5IGRpZCBpdCBmb3IgdXMKLQkgKi8KLQogCW11dGV4X2xvY2so
JmdwLT5wbV9tdXRleCk7CiAKIAlncC0+b3BlbmVkID0gMDsKLQlpZiAoIWdwLT5hc2xlZXApCisJ
aWYgKCFncC0+YXNsZWVwKSB7CisJCS8qIFVwcGVyIGxheWVyIHRvb2sgY2FyZSBvZiBkaXNhYmxp
bmcgcG9sbGluZyAqLworCQluZXRpZl9zdG9wX3F1ZXVlKGRldik7CiAJCWdlbV9kb19zdG9wKGRl
diwgMCk7CisJfQogCiAJbXV0ZXhfdW5sb2NrKCZncC0+cG1fbXV0ZXgpOwogCkBAIC0yMzU3LDIy
ICsyNDIzLDE3IEBAIHN0YXRpYyBpbnQgZ2VtX3N1c3BlbmQoc3RydWN0IHBjaV9kZXYgKnAKIHsK
IAlzdHJ1Y3QgbmV0X2RldmljZSAqZGV2ID0gcGNpX2dldF9kcnZkYXRhKHBkZXYpOwogCXN0cnVj
dCBnZW0gKmdwID0gZGV2LT5wcml2OwotCXVuc2lnbmVkIGxvbmcgZmxhZ3M7CiAKIAltdXRleF9s
b2NrKCZncC0+cG1fbXV0ZXgpOwogCi0JbmV0aWZfcG9sbF9kaXNhYmxlKGRldik7Ci0KIAlwcmlu
dGsoS0VSTl9JTkZPICIlczogc3VzcGVuZGluZywgV2FrZU9uTGFuICVzXG4iLAogCSAgICAgICBk
ZXYtPm5hbWUsCiAJICAgICAgIChncC0+d2FrZV9vbl9sYW4gJiYgZ3AtPm9wZW5lZCkgPyAiZW5h
YmxlZCIgOiAiZGlzYWJsZWQiKTsKIAogCS8qIEtlZXAgdGhlIGNlbGwgZW5hYmxlZCBkdXJpbmcg
dGhlIGVudGlyZSBvcGVyYXRpb24gKi8KLQlzcGluX2xvY2tfaXJxc2F2ZSgmZ3AtPmxvY2ssIGZs
YWdzKTsKLQlzcGluX2xvY2soJmdwLT50eF9sb2NrKTsKKwlnZW1fZnVsbF9sb2NrKGdwLCAwKTsK
IAlnZW1fZ2V0X2NlbGwoZ3ApOwotCXNwaW5fdW5sb2NrKCZncC0+dHhfbG9jayk7Ci0Jc3Bpbl91
bmxvY2tfaXJxcmVzdG9yZSgmZ3AtPmxvY2ssIGZsYWdzKTsKKwlnZW1fZnVsbF91bmxvY2soZ3Ap
OwogCiAJLyogSWYgdGhlIGRyaXZlciBpcyBvcGVuZWQsIHdlIHN0b3AgdGhlIE1BQyAqLwogCWlm
IChncC0+b3BlbmVkKSB7CkBAIC0yMzgxLDYgKzI0NDIsNyBAQCBzdGF0aWMgaW50IGdlbV9zdXNw
ZW5kKHN0cnVjdCBwY2lfZGV2ICpwCiAKIAkJLyogU3dpdGNoIG9mZiBNQUMsIHJlbWVtYmVyIFdP
TCBzZXR0aW5nICovCiAJCWdwLT5hc2xlZXBfd29sID0gZ3AtPndha2Vfb25fbGFuOworCQlnZW1f
bmV0aWZfc3RvcChncCk7CiAJCWdlbV9kb19zdG9wKGRldiwgZ3AtPmFzbGVlcF93b2wpOwogCX0g
ZWxzZQogCQlncC0+YXNsZWVwX3dvbCA9IDA7CkBAIC0yMzk5LDggKzI0NjEsNyBAQCBzdGF0aWMg
aW50IGdlbV9zdXNwZW5kKHN0cnVjdCBwY2lfZGV2ICpwCiAJbXV0ZXhfdW5sb2NrKCZncC0+cG1f
bXV0ZXgpOwogCiAJLyogV2FpdCBmb3IgYSBwZW5kaW5nIHJlc2V0IHRhc2sgdG8gY29tcGxldGUg
Ki8KLQl3aGlsZSAoZ3AtPnJlc2V0X3Rhc2tfcGVuZGluZykKLQkJeWllbGQoKTsKKwlnZW1fd2Fp
dF9yZXNldF90YXNrKGdwKTsKIAlmbHVzaF9zY2hlZHVsZWRfd29yaygpOwogCiAJLyogU2h1dCB0
aGUgUEhZIGRvd24gZXZlbnR1YWxseSBhbmQgc2V0dXAgV09MICovCkBAIC0yNDIxLDcgKzI0ODIs
NiBAQCBzdGF0aWMgaW50IGdlbV9yZXN1bWUoc3RydWN0IHBjaV9kZXYgKnBkCiB7CiAJc3RydWN0
IG5ldF9kZXZpY2UgKmRldiA9IHBjaV9nZXRfZHJ2ZGF0YShwZGV2KTsKIAlzdHJ1Y3QgZ2VtICpn
cCA9IGRldi0+cHJpdjsKLQl1bnNpZ25lZCBsb25nIGZsYWdzOwogCiAJcHJpbnRrKEtFUk5fSU5G
TyAiJXM6IHJlc3VtaW5nXG4iLCBkZXYtPm5hbWUpOwogCkBAIC0yNDY1LDExICsyNTI1LDkgQEAg
c3RhdGljIGludCBnZW1fcmVzdW1lKHN0cnVjdCBwY2lfZGV2ICpwZAogCiAJCS8qIFJlLWF0dGFj
aCBuZXQgZGV2aWNlICovCiAJCW5ldGlmX2RldmljZV9hdHRhY2goZGV2KTsKLQogCX0KIAotCXNw
aW5fbG9ja19pcnFzYXZlKCZncC0+bG9jaywgZmxhZ3MpOwotCXNwaW5fbG9jaygmZ3AtPnR4X2xv
Y2spOworCWdlbV9mdWxsX2xvY2soZ3AsIDApOwogCiAJLyogSWYgd2UgaGFkIFdPTCBlbmFibGVk
LCB0aGUgY2VsbCBjbG9jayB3YXMgbmV2ZXIgdHVybmVkIG9mZiBkdXJpbmcKIAkgKiBzbGVlcCwg
c28gd2UgZW5kIHVwIGJlZWluZyB1bmJhbGFuY2VkLiBGaXggdGhhdCBoZXJlCkBAIC0yNDgyLDEw
ICsyNTQwLDkgQEAgc3RhdGljIGludCBnZW1fcmVzdW1lKHN0cnVjdCBwY2lfZGV2ICpwZAogCSAq
LwogCWdlbV9wdXRfY2VsbChncCk7CiAKLQlzcGluX3VubG9jaygmZ3AtPnR4X2xvY2spOwotCXNw
aW5fdW5sb2NrX2lycXJlc3RvcmUoJmdwLT5sb2NrLCBmbGFncyk7CisJZ2VtX2Z1bGxfdW5sb2Nr
KGdwKTsKIAotCW5ldGlmX3BvbGxfZW5hYmxlKGRldik7CisJZ2VtX25ldGlmX3N0YXJ0KGdwKTsK
IAogCW11dGV4X3VubG9jaygmZ3AtPnBtX211dGV4KTsKIApAQCAtMjQ5OCw4ICsyNTU1LDggQEAg
c3RhdGljIHN0cnVjdCBuZXRfZGV2aWNlX3N0YXRzICpnZW1fZ2V0XwogCXN0cnVjdCBnZW0gKmdw
ID0gZGV2LT5wcml2OwogCXN0cnVjdCBuZXRfZGV2aWNlX3N0YXRzICpzdGF0cyA9ICZncC0+bmV0
X3N0YXRzOwogCi0Jc3Bpbl9sb2NrX2lycSgmZ3AtPmxvY2spOwotCXNwaW5fbG9jaygmZ3AtPnR4
X2xvY2spOworCWdlbV9uZXRpZl9zdG9wKGdwKTsKKwlnZW1fZnVsbF9sb2NrKGdwLCAwKTsKIAog
CS8qIEkgaGF2ZSBzZWVuIHRoaXMgYmVpbmcgY2FsbGVkIHdoaWxlIHRoZSBQTSB3YXMgaW4gcHJv
Z3Jlc3MsCiAJICogc28gd2Ugc2hpZWxkIGFnYWluc3QgdGhpcwpAQCAtMjUyMiwyNyArMjU3OSwy
NiBAQCBzdGF0aWMgc3RydWN0IG5ldF9kZXZpY2Vfc3RhdHMgKmdlbV9nZXRfCiAJCXdyaXRlbCgw
LCBncC0+cmVncyArIE1BQ19MQ09MTCk7CiAJfQogCi0Jc3Bpbl91bmxvY2soJmdwLT50eF9sb2Nr
KTsKLQlzcGluX3VubG9ja19pcnEoJmdwLT5sb2NrKTsKKwlnZW1fZnVsbF91bmxvY2soZ3ApOwor
CWdlbV9uZXRpZl9zdGFydChncCk7CiAKIAlyZXR1cm4gJmdwLT5uZXRfc3RhdHM7CiB9CiAKKy8q
IGdlbV9zZXRfbXVsdGljYXN0IGlzIGNhbGxlZCB3aXRoIG5ldGlmX3R4X2xvY2sgaGVsZC4gVGh1
cywgaXQKKyAqIGNhbm5vdCBzbGVlcC4KKyAqLwogc3RhdGljIHZvaWQgZ2VtX3NldF9tdWx0aWNh
c3Qoc3RydWN0IG5ldF9kZXZpY2UgKmRldikKIHsKIAlzdHJ1Y3QgZ2VtICpncCA9IGRldi0+cHJp
djsKIAl1MzIgcnhjZmcsIHJ4Y2ZnX25ldzsKIAlpbnQgbGltaXQgPSAxMDAwMDsKIAotCi0Jc3Bp
bl9sb2NrX2lycSgmZ3AtPmxvY2spOwotCXNwaW5fbG9jaygmZ3AtPnR4X2xvY2spOworCWdlbV9m
dWxsX2xvY2soZ3AsIDApOwogCiAJaWYgKCFncC0+cnVubmluZykKIAkJZ290byBiYWlsOwogCi0J
bmV0aWZfc3RvcF9xdWV1ZShkZXYpOwotCiAJcnhjZmcgPSByZWFkbChncC0+cmVncyArIE1BQ19S
WENGRyk7CiAJcnhjZmdfbmV3ID0gZ2VtX3NldHVwX211bHRpY2FzdChncCk7CiAjaWZkZWYgU1RS
SVBfRkNTCkBAIC0yNTYyLDExICsyNjE4LDggQEAgI2VuZGlmCiAKIAl3cml0ZWwocnhjZmcsIGdw
LT5yZWdzICsgTUFDX1JYQ0ZHKTsKIAotCW5ldGlmX3dha2VfcXVldWUoZGV2KTsKLQogIGJhaWw6
Ci0Jc3Bpbl91bmxvY2soJmdwLT50eF9sb2NrKTsKLQlzcGluX3VubG9ja19pcnEoJmdwLT5sb2Nr
KTsKKwlnZW1fZnVsbF91bmxvY2soZ3ApOwogfQogCiAvKiBKdW1iby1ncmFtcyBkb24ndCBzZWVt
IHRvIHdvcmsgOi0oICovCkBAIC0yNTkzLDE2ICsyNjQ2LDIyIEBAIHN0YXRpYyBpbnQgZ2VtX2No
YW5nZV9tdHUoc3RydWN0IG5ldF9kZXYKIAl9CiAKIAltdXRleF9sb2NrKCZncC0+cG1fbXV0ZXgp
OwotCXNwaW5fbG9ja19pcnEoJmdwLT5sb2NrKTsKLQlzcGluX2xvY2soJmdwLT50eF9sb2NrKTsK
KworCWdlbV9uZXRpZl9zdG9wKGdwKTsKKwlnZW1fZnVsbF9sb2NrKGdwLCAxKTsKKwlnZW1fZGlz
YWJsZV9pbnRzKGdwKTsKKwkKIAlkZXYtPm10dSA9IG5ld19tdHU7CiAJaWYgKGdwLT5ydW5uaW5n
KSB7CiAJCWdlbV9yZWluaXRfY2hpcChncCk7CiAJCWlmIChncC0+bHN0YXRlID09IGxpbmtfdXAp
CiAJCQlnZW1fc2V0X2xpbmtfbW9kZXMoZ3ApOwogCX0KLQlzcGluX3VubG9jaygmZ3AtPnR4X2xv
Y2spOwotCXNwaW5fdW5sb2NrX2lycSgmZ3AtPmxvY2spOworCisJZ2VtX25ldGlmX3N0YXJ0KGdw
KTsKKwlnZW1fZW5hYmxlX2ludHMoZ3ApOworCWdlbV9mdWxsX3VubG9jayhncCk7CisKIAltdXRl
eF91bmxvY2soJmdwLT5wbV9tdXRleCk7CiAKIAlyZXR1cm4gMDsKQEAgLTI2MzUsNyArMjY5NCw3
IEBAIHN0YXRpYyBpbnQgZ2VtX2dldF9zZXR0aW5ncyhzdHJ1Y3QgbmV0X2QKIAkJY21kLT5waHlf
YWRkcmVzcyA9IDA7IC8qIFhYWCBmaXhlZCBQSFlBRCAqLwogCiAJCS8qIFJldHVybiBjdXJyZW50
IFBIWSBzZXR0aW5ncyAqLwotCQlzcGluX2xvY2tfaXJxKCZncC0+bG9jayk7CisJCWdlbV9mdWxs
X2xvY2soZ3AsIDApOwogCQljbWQtPmF1dG9uZWcgPSBncC0+d2FudF9hdXRvbmVnOwogCQljbWQt
PnNwZWVkID0gZ3AtPnBoeV9taWkuc3BlZWQ7CiAJCWNtZC0+ZHVwbGV4ID0gZ3AtPnBoeV9taWku
ZHVwbGV4OwpAQCAtMjY0Nyw3ICsyNzA2LDcgQEAgc3RhdGljIGludCBnZW1fZ2V0X3NldHRpbmdz
KHN0cnVjdCBuZXRfZAogCQkgKi8KIAkJaWYgKGNtZC0+YWR2ZXJ0aXNpbmcgPT0gMCkKIAkJCWNt
ZC0+YWR2ZXJ0aXNpbmcgPSBjbWQtPnN1cHBvcnRlZDsKLQkJc3Bpbl91bmxvY2tfaXJxKCZncC0+
bG9jayk7CisJCWdlbV9mdWxsX3VubG9jayhncCk7CiAJfSBlbHNlIHsgLy8gWFhYIFBDUyA/CiAJ
CWNtZC0+c3VwcG9ydGVkID0KIAkJCShTVVBQT1JURURfMTBiYXNlVF9IYWxmIHwgU1VQUE9SVEVE
XzEwYmFzZVRfRnVsbCB8CkBAIC0yNjg1LDExICsyNzQ0LDExIEBAIHN0YXRpYyBpbnQgZ2VtX3Nl
dF9zZXR0aW5ncyhzdHJ1Y3QgbmV0X2QKIAkJcmV0dXJuIC1FSU5WQUw7CiAKIAkvKiBBcHBseSBz
ZXR0aW5ncyBhbmQgcmVzdGFydCBsaW5rIHByb2Nlc3MuICovCi0Jc3Bpbl9sb2NrX2lycSgmZ3At
PmxvY2spOworCWdlbV9mdWxsX2xvY2soZ3AsIDApOwogCWdlbV9nZXRfY2VsbChncCk7CiAJZ2Vt
X2JlZ2luX2F1dG9fbmVnb3RpYXRpb24oZ3AsIGNtZCk7CiAJZ2VtX3B1dF9jZWxsKGdwKTsKLQlz
cGluX3VubG9ja19pcnEoJmdwLT5sb2NrKTsKKwlnZW1fZnVsbF91bmxvY2soZ3ApOwogCiAJcmV0
dXJuIDA7CiB9CkBAIC0yNzAyLDExICsyNzYxLDExIEBAIHN0YXRpYyBpbnQgZ2VtX253YXlfcmVz
ZXQoc3RydWN0IG5ldF9kZXYKIAkJcmV0dXJuIC1FSU5WQUw7CiAKIAkvKiBSZXN0YXJ0IGxpbmsg
cHJvY2Vzcy4gKi8KLQlzcGluX2xvY2tfaXJxKCZncC0+bG9jayk7CisJZ2VtX2Z1bGxfbG9jayhn
cCwgMCk7CiAJZ2VtX2dldF9jZWxsKGdwKTsKIAlnZW1fYmVnaW5fYXV0b19uZWdvdGlhdGlvbihn
cCwgTlVMTCk7CiAJZ2VtX3B1dF9jZWxsKGdwKTsKLQlzcGluX3VubG9ja19pcnEoJmdwLT5sb2Nr
KTsKKwlnZW1fZnVsbF91bmxvY2soZ3ApOwogCiAJcmV0dXJuIDA7CiB9CkBAIC0yNzcwLDE2ICsy
ODI5LDE1IEBAIHN0YXRpYyBpbnQgZ2VtX2lvY3RsKHN0cnVjdCBuZXRfZGV2aWNlICoKIAlzdHJ1
Y3QgZ2VtICpncCA9IGRldi0+cHJpdjsKIAlzdHJ1Y3QgbWlpX2lvY3RsX2RhdGEgKmRhdGEgPSBp
Zl9taWkoaWZyKTsKIAlpbnQgcmMgPSAtRU9QTk9UU1VQUDsKLQl1bnNpZ25lZCBsb25nIGZsYWdz
OwogCiAJLyogSG9sZCB0aGUgUE0gbXV0ZXggd2hpbGUgZG9pbmcgaW9jdGwncyBvciB3ZSBtYXkg
Y29sbGlkZQogCSAqIHdpdGggcG93ZXIgbWFuYWdlbWVudC4KIAkgKi8KIAltdXRleF9sb2NrKCZn
cC0+cG1fbXV0ZXgpOwogCi0Jc3Bpbl9sb2NrX2lycXNhdmUoJmdwLT5sb2NrLCBmbGFncyk7CisJ
Z2VtX2Z1bGxfbG9jayhncCwgMCk7CiAJZ2VtX2dldF9jZWxsKGdwKTsKLQlzcGluX3VubG9ja19p
cnFyZXN0b3JlKCZncC0+bG9jaywgZmxhZ3MpOworCWdlbV9mdWxsX3VubG9jayhncCk7CiAKIAlz
d2l0Y2ggKGNtZCkgewogCWNhc2UgU0lPQ0dNSUlQSFk6CQkvKiBHZXQgYWRkcmVzcyBvZiBNSUkg
UEhZIGluIHVzZS4gKi8KQEAgLTI4MDksOSArMjg2Nyw5IEBAIHN0YXRpYyBpbnQgZ2VtX2lvY3Rs
KHN0cnVjdCBuZXRfZGV2aWNlICoKIAkJYnJlYWs7CiAJfTsKIAotCXNwaW5fbG9ja19pcnFzYXZl
KCZncC0+bG9jaywgZmxhZ3MpOworCWdlbV9mdWxsX2xvY2soZ3AsIDApOwogCWdlbV9wdXRfY2Vs
bChncCk7Ci0Jc3Bpbl91bmxvY2tfaXJxcmVzdG9yZSgmZ3AtPmxvY2ssIGZsYWdzKTsKKwlnZW1f
ZnVsbF91bmxvY2soZ3ApOwogCiAJbXV0ZXhfdW5sb2NrKCZncC0+cG1fbXV0ZXgpOwogCkBAIC0y
OTE4LDYgKzI5NzYsNyBAQCBzdGF0aWMgdm9pZCBnZW1fcmVtb3ZlX29uZShzdHJ1Y3QgcGNpX2Rl
CiAJaWYgKGRldikgewogCQlzdHJ1Y3QgZ2VtICpncCA9IGRldi0+cHJpdjsKIAorCQkvKiB1bnJl
Z2lzdGVyX25ldGRldiB3aWxsIGNsb3NlIHRoZSBkZXZpY2UgaWYgaXQncyBvcGVuICovCiAJCXVu
cmVnaXN0ZXJfbmV0ZGV2KGRldik7CiAKIAkJLyogU3RvcCB0aGUgbGluayB0aW1lciAqLwpAQCAt
MjkyNyw4ICsyOTg2LDcgQEAgc3RhdGljIHZvaWQgZ2VtX3JlbW92ZV9vbmUoc3RydWN0IHBjaV9k
ZQogCQlnZW1fZ2V0X2NlbGwoZ3ApOwogCiAJCS8qIFdhaXQgZm9yIGEgcGVuZGluZyByZXNldCB0
YXNrIHRvIGNvbXBsZXRlICovCi0JCXdoaWxlIChncC0+cmVzZXRfdGFza19wZW5kaW5nKQotCQkJ
eWllbGQoKTsKKwkJZ2VtX3dhaXRfcmVzZXRfdGFzayhncCk7CiAJCWZsdXNoX3NjaGVkdWxlZF93
b3JrKCk7CiAKIAkJLyogU2h1dCB0aGUgUEhZIGRvd24gKi8KQEAgLTMwMzUsOCArMzA5MywxMSBA
QCBzdGF0aWMgaW50IF9fZGV2aW5pdCBnZW1faW5pdF9vbmUoc3RydWN0CiAKIAlncC0+bXNnX2Vu
YWJsZSA9IERFRkFVTFRfTVNHOwogCisJZ3AtPmlycV9zeW5jID0gMDsKIAlzcGluX2xvY2tfaW5p
dCgmZ3AtPmxvY2spOwotCXNwaW5fbG9ja19pbml0KCZncC0+dHhfbG9jayk7CisjaWYgIUdFTV9J
TlRFUlJVUFRfTE9DS0xFU1MKKwlzcGluX2xvY2tfaW5pdCgmZ3AtPmludF9sb2NrKTsKKyNlbmRp
ZgogCW11dGV4X2luaXQoJmdwLT5wbV9tdXRleCk7CiAKIAlpbml0X3RpbWVyKCZncC0+bGlua190
aW1lcik7CkBAIC0zMTMyLDkgKzMxOTMsNyBAQCAjZW5kaWYKIAkgKi8KIAlnZW1faW5pdF9waHko
Z3ApOwogCi0Jc3Bpbl9sb2NrX2lycSgmZ3AtPmxvY2spOwogCWdlbV9wdXRfY2VsbChncCk7Ci0J
c3Bpbl91bmxvY2tfaXJxKCZncC0+bG9jayk7CiAKIAkvKiBSZWdpc3RlciB3aXRoIGtlcm5lbCAq
LwogCWlmIChyZWdpc3Rlcl9uZXRkZXYoZGV2KSkgewpAQCAtMzE1Niw4ICszMjE1LDcgQEAgI2Vu
ZGlmCiAJCXByaW50ayhLRVJOX0lORk8gIiVzOiBGb3VuZCAlcyBQSFlcbiIsIGRldi0+bmFtZSwK
IAkJCWdwLT5waHlfbWlpLmRlZiA/IGdwLT5waHlfbWlpLmRlZi0+bmFtZSA6ICJubyIpOwogCi0J
LyogR0VNIGNhbiBkbyBpdCBhbGwuLi4gKi8KLQlkZXYtPmZlYXR1cmVzIHw9IE5FVElGX0ZfU0cg
fCBORVRJRl9GX0hXX0NTVU0gfCBORVRJRl9GX0xMVFg7CisJZGV2LT5mZWF0dXJlcyB8PSBORVRJ
Rl9GX1NHIHwgTkVUSUZfRl9IV19DU1VNOwogCWlmIChwY2lfdXNpbmdfZGFjKQogCQlkZXYtPmZl
YXR1cmVzIHw9IE5FVElGX0ZfSElHSERNQTsKIApAQCAtMzE3Nyw3ICszMjM1LDYgQEAgZXJyX291
dF9mcmVlX25ldGRldjoKIGVycl9kaXNhYmxlX2RldmljZToKIAlwY2lfZGlzYWJsZV9kZXZpY2Uo
cGRldik7CiAJcmV0dXJuIGVycjsKLQogfQogCiAKZGlmZiAtLWdpdCBhL2RyaXZlcnMvbmV0L3N1
bmdlbS5oIGIvZHJpdmVycy9uZXQvc3VuZ2VtLmgKaW5kZXggYTcwMDY3Yy4uNDlkM2FhNSAxMDA2
NDQKLS0tIGEvZHJpdmVycy9uZXQvc3VuZ2VtLmgKKysrIGIvZHJpdmVycy9uZXQvc3VuZ2VtLmgK
QEAgLTcsNiArNyw4IEBACiAjaWZuZGVmIF9TVU5HRU1fSAogI2RlZmluZSBfU1VOR0VNX0gKIAor
I2RlZmluZSBHRU1fSU5URVJSVVBUX0xPQ0tMRVNTIDEgLyogVE9ETyAqLworCiAvKiBHbG9iYWwg
UmVnaXN0ZXJzICovCiAjZGVmaW5lIEdSRUdfU0VCU1RBVEUJMHgwMDAwVUwJLyogU0VCIFN0YXRl
IFJlZ2lzdGVyCQkqLwogI2RlZmluZSBHUkVHX0NGRwkweDAwMDRVTAkvKiBDb25maWd1cmF0aW9u
IFJlZ2lzdGVyCSovCkBAIC03MSw2ICs3MywxMSBAQCAjZGVmaW5lIEdSRUdfU1RBVF9OQVBJCQko
R1JFR19TVEFUX1RYQUxMCiAgKiBvbiBHUkVHX1NUQVQuCiAgKi8KIAorI2lmIEdFTV9JTlRFUlJV
UFRfTE9DS0xFU1MKKyNkZWZpbmUgR1JFR19TVEFUX0lBQ0sJCShHUkVHX1NUQVRfVFhBTEwgIHwg
R1JFR19TVEFUX1RYSU5UTUUgfCBcCisJCQkJIEdSRUdfU1RBVF9SWERPTkUgfCBHUkVHX1NUQVRf
UlhOT0JVRikKKyNlbmRpZgorCiAvKiBHbG9iYWwgUENJIEVycm9yIFN0YXR1cyBSZWdpc3RlciAq
LwogI2RlZmluZSBHUkVHX1BDSUVTVEFUX0JBREFDSwkweDAwMDAwMDAxCS8qIE5vIEFDSzY0IyBk
dXJpbmcgQUJTNjQgY3ljbGUJKi8KICNkZWZpbmUgR1JFR19QQ0lFU1RBVF9EVFJUTwkweDAwMDAw
MDAyCS8qIERlbGF5ZWQgdHJhbnNhY3Rpb24gdGltZW91dAkqLwpAQCAtOTczLDggKzk4MCwxMSBA
QCBlbnVtIGxpbmtfc3RhdGUgewogfTsKIAogc3RydWN0IGdlbSB7CisJaW50CQkJaXJxX3N5bmM7
CiAJc3BpbmxvY2tfdAkJbG9jazsKLQlzcGlubG9ja190CQl0eF9sb2NrOworI2lmICFHRU1fSU5U
RVJSVVBUX0xPQ0tMRVNTCisJc3BpbmxvY2tfdAkJaW50X2xvY2s7CisjZW5kaWYKIAl2b2lkIF9f
aW9tZW0JCSpyZWdzOwogCWludAkJCXJ4X25ldywgcnhfb2xkOwogCWludAkJCXR4X25ldywgdHhf
b2xkOwo=
------=_Part_54207_22012202.1163541280161--
