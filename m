From: "Eric Lemoine" <eric.lemoine@gmail.com>
Subject: Re: [patch sungem] improved locking
Date: Wed, 29 Nov 2006 23:37:05 +0100
Message-ID: <5cac192f0611291437g26fefebdocdacbb0cd2aa2fdd@mail.gmail.com>
References: <5cac192f0611132328i52d6d615g28d8c493dc028621@mail.gmail.com>
	 <20061113.234456.78492515.davem@davemloft.net>
	 <5cac192f0611141354l3a4aa130ve741c9d6a7a49d0a@mail.gmail.com>
	 <20061128.144911.55733883.davem@davemloft.net>
	 <5cac192f0611290256l7067ce21r39881486f6e21289@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_39968_26552275.1164839825378"
Cc: netdev@vger.kernel.org, benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.238]:35581 "EHLO
	wr-out-0506.google.com") by vger.kernel.org with ESMTP
	id S1758878AbWK2WhI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Nov 2006 17:37:08 -0500
Received: by wr-out-0506.google.com with SMTP id i7so892620wra
        for <netdev@vger.kernel.org>; Wed, 29 Nov 2006 14:37:07 -0800 (PST)
To: "David Miller" <davem@davemloft.net>
In-Reply-To: <5cac192f0611290256l7067ce21r39881486f6e21289@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_39968_26552275.1164839825378
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On 11/29/06, Eric Lemoine <eric.lemoine@gmail.com> wrote:
> I think the following code for gem_interrupt should do the trick:
>
> static irqreturn_t gem_interrupt(int irq, void *dev_id)
> {
>     struct net_device *dev = dev_id;
>     struct gem *gp = dev->priv;
>     unsigned int handled = 1;
>
>     if (!gp->running)
>         goto out;
>
>     if (netif_rx_schedule_prep(dev)) {
>         u32 gem_status = gem_read_status(gp);
>         gem_disable_ints();
>
>         if (unlikely(!gem_status))
>             handled = 0;
>
>         if (gem_irq_sync(gp)) {
>             netif_poll_enable(dev);
>             goto out;
>         }
>
>         gp->status = gem_status;
>         __netif_rx_schedule(dev);
>     }
>
> out:
>     return IRQ_RETVAL(handled);
> }
>
> The important thing is: we __netif_rx_schedule even if gem_status is 0
> (shared irq case) because we don't want to miss events should the
> following scenario occur:
>
> CPU0                                                     CPU1
> gem interrupt
> prepare rx schedule
>                                                              gem_interrupt
>                                                              rx is
> already scheduled
> shared irq -> (we can miss NIC events
> if we don't __netif_rx_schedule before
> returning)

This new patch implements the above, and fixes a bug that was in the
previous patch. This bug made BUG_ON() in gem_irq_quiesce() trigger
when putting the link down while the device was closed.

Patch applies to current git net-2.6 (2.6.19-rc6). Dave, do you still
use that tree, or net-2.6.20 is your only working tree at this time?

Thanks,

--
Eric


Signed-off-by: Eric Lemoine <eric.lemoine@gmail.com>

diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index 253e96e..1085c3d 100644
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
@@ -206,18 +186,66 @@ static inline void phy_write(struct gem
 	__phy_write(gp, gp->mii_phy_addr, reg, val);
 }

-static inline void gem_enable_ints(struct gem *gp)
+static inline void __gem_enable_ints(struct gem *gp)
 {
-	/* Enable all interrupts but TXDONE */
+	/* Enable all interrupts, but TXDONE */
 	writel(GREG_STAT_TXDONE, gp->regs + GREG_IMASK);
 }

+static inline void gem_enable_ints(struct gem *gp)
+{
+	gp->irq_sync = 0;
+	wmb();
+	__gem_enable_ints(gp);
+}
+
 static inline void gem_disable_ints(struct gem *gp)
 {
 	/* Disable all interrupts, including TXDONE */
 	writel(GREG_STAT_NAPI | GREG_STAT_TXDONE, gp->regs + GREG_IMASK);
 }

+static inline u32 gem_read_status(struct gem *gp)
+{
+	return readl(gp->regs + GREG_STAT);
+}
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
@@ -658,12 +686,20 @@ static int gem_abnormal_irq(struct net_d
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
@@ -717,11 +753,20 @@ static __inline__ void gem_tx(struct net
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
@@ -882,12 +927,6 @@ static int gem_rx(struct gem *gp, int wo
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
@@ -899,19 +938,10 @@ static int gem_poll(struct net_device *d
 		}

 		/* Run TX completion thread */
-		spin_lock(&gp->tx_lock);
 		gem_tx(dev, gp, gp->status);
-		spin_unlock(&gp->tx_lock);

-		spin_unlock_irqrestore(&gp->lock, flags);
-
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
@@ -920,53 +950,90 @@ static int gem_poll(struct net_device *d
 		if (work_done >= work_to_do)
 			return 1;

-		spin_lock_irqsave(&gp->lock, flags);
-
-		gp->status = readl(gp->regs + GREG_STAT);
+		gp->status = gem_read_status(gp);
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
 static irqreturn_t gem_interrupt(int irq, void *dev_id)
 {
 	struct net_device *dev = dev_id;
 	struct gem *gp = dev->priv;
-	unsigned long flags;
+	unsigned int handled = 1;

 	/* Swallow interrupts when shutting the chip down, though
 	 * that shouldn't happen, we should have done free_irq() at
 	 * this point...
 	 */
 	if (!gp->running)
-		return IRQ_HANDLED;
-
-	spin_lock_irqsave(&gp->lock, flags);
+		goto out;

 	if (netif_rx_schedule_prep(dev)) {
-		u32 gem_status = readl(gp->regs + GREG_STAT);
+		u32 gem_status;
+		
+		gem_status = gem_read_status(gp);
+		if (unlikely(!gem_status)) {
+			/* Shared IRQ. We still want to __netif_rx_schedule
+			 * here, because we don't want to miss NIC events
+			 * should the following scenario occur:
+			 *
+			 * CPU0				CPU1
+			 * interrupt
+			 * prepare rx schedule
+			 * 				interrupt
+			 * 				rx is already scheduled
+			 * gem_status is 0 (we can
+			 * miss NIC events if we
+			 * don't __netif_rx_schedule
+			 * and return right away here)
+			 */
+			handled = 0;
+		}
+
+		gem_disable_ints(gp);

-		if (gem_status == 0) {
+		if (gem_irq_sync(gp)) {
 			netif_poll_enable(dev);
-			spin_unlock_irqrestore(&gp->lock, flags);
-			return IRQ_NONE;
+			goto out;
 		}
+
 		gp->status = gem_status;
-		gem_disable_ints(gp);
 		__netif_rx_schedule(dev);
 	}

-	spin_unlock_irqrestore(&gp->lock, flags);
-
-	/* If polling was disabled at the time we received that
-	 * interrupt, we may return IRQ_HANDLED here while we
-	 * should return IRQ_NONE. No big deal...
-	 */
-	return IRQ_HANDLED;
+out:
+	return IRQ_RETVAL(handled);
 }

 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -999,14 +1066,7 @@ static void gem_tx_timeout(struct net_de
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
+	gem_schedule_reset_task(gp);
 }

 static __inline__ int gem_intme(int entry)
@@ -1023,7 +1083,6 @@ static int gem_start_xmit(struct sk_buff
 	struct gem *gp = dev->priv;
 	int entry;
 	u64 ctrl;
-	unsigned long flags;

 	ctrl = 0;
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
@@ -1037,24 +1096,13 @@ static int gem_start_xmit(struct sk_buff
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

@@ -1131,15 +1179,17 @@ static int gem_start_xmit(struct sk_buff
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

@@ -1148,7 +1198,6 @@ static int gem_start_xmit(struct sk_buff

 #define STOP_TRIES 32

-/* Must be invoked under gp->lock and gp->tx_lock. */
 static void gem_reset(struct gem *gp)
 {
 	int limit;
@@ -1174,7 +1223,6 @@ static void gem_reset(struct gem *gp)
 		printk(KERN_ERR "%s: SW reset is ghetto.\n", gp->dev->name);
 }

-/* Must be invoked under gp->lock and gp->tx_lock. */
 static void gem_start_dma(struct gem *gp)
 {
 	u32 val;
@@ -1197,9 +1245,7 @@ static void gem_start_dma(struct gem *gp
 	writel(RX_RING_SIZE - 4, gp->regs + RXDMA_KICK);
 }

-/* Must be invoked under gp->lock and gp->tx_lock. DMA won't be
- * actually stopped before about 4ms tho ...
- */
+/* DMA won't be actually stopped before about 4ms tho ... */
 static void gem_stop_dma(struct gem *gp)
 {
 	u32 val;
@@ -1220,8 +1266,7 @@ static void gem_stop_dma(struct gem *gp)
 }


-/* Must be invoked under gp->lock and gp->tx_lock. */
-// XXX dbl check what that function should do when called on PCS PHY
+/* XXX dbl check what that function should do when called on PCS PHY */
 static void gem_begin_auto_negotiation(struct gem *gp, struct ethtool_cmd *ep)
 {
 	u32 advertise, features;
@@ -1306,8 +1351,6 @@ non_mii:

 /* A link-up condition has occurred, initialize and enable the
  * rest of the chip.
- *
- * Must be invoked under gp->lock and gp->tx_lock.
  */
 static int gem_set_link_modes(struct gem *gp)
 {
@@ -1417,7 +1460,6 @@ static int gem_set_link_modes(struct gem
 	return 0;
 }

-/* Must be invoked under gp->lock and gp->tx_lock. */
 static int gem_mdio_link_not_up(struct gem *gp)
 {
 	switch (gp->lstate) {
@@ -1474,13 +1516,13 @@ static void gem_link_timer(unsigned long
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

@@ -1528,8 +1570,7 @@ static void gem_link_timer(unsigned long
 				printk(KERN_INFO "%s: Link down\n",
 					gp->dev->name);
 			netif_carrier_off(gp->dev);
-			gp->reset_task_pending = 1;
-			schedule_work(&gp->reset_task);
+			gem_schedule_reset_task(gp);
 			restart_aneg = 1;
 		} else if (++gp->timer_ticks > 10) {
 			if (found_mii_phy(gp))
@@ -1546,11 +1587,9 @@ restart:
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
@@ -1601,7 +1640,6 @@ static void gem_clean_rings(struct gem *
 	}
 }

-/* Must be invoked under gp->lock and gp->tx_lock. */
 static void gem_init_rings(struct gem *gp)
 {
 	struct gem_init_block *gb = gp->init_block;
@@ -1775,12 +1813,9 @@ #endif
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
@@ -1818,7 +1853,6 @@ static void gem_init_dma(struct gem *gp)
 		       gp->regs + RXDMA_BLANK);
 }

-/* Must be invoked under gp->lock and gp->tx_lock. */
 static u32 gem_setup_multicast(struct gem *gp)
 {
 	u32 rxcfg = 0;
@@ -1860,7 +1894,6 @@ static u32 gem_setup_multicast(struct ge
 	return rxcfg;
 }

-/* Must be invoked under gp->lock and gp->tx_lock. */
 static void gem_init_mac(struct gem *gp)
 {
 	unsigned char *e = &gp->dev->dev_addr[0];
@@ -1943,7 +1976,6 @@ #endif
 		writel(0, gp->regs + WOL_WAKECSR);
 }

-/* Must be invoked under gp->lock and gp->tx_lock. */
 static void gem_init_pause_thresholds(struct gem *gp)
 {
        	u32 cfg;
@@ -2096,7 +2128,6 @@ static int gem_check_invariants(struct g
 	return 0;
 }

-/* Must be invoked under gp->lock and gp->tx_lock. */
 static void gem_reinit_chip(struct gem *gp)
 {
 	/* Reset the chip */
@@ -2116,12 +2147,10 @@ static void gem_reinit_chip(struct gem *
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
@@ -2167,13 +2196,13 @@ static void gem_stop_phy(struct gem *gp,
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

@@ -2192,14 +2221,11 @@ static void gem_stop_phy(struct gem *gp,
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
@@ -2211,28 +2237,26 @@ static int gem_do_start(struct net_devic

 	if (gp->lstate == link_up) {
 		netif_carrier_on(gp->dev);
+		/* gem_set_link_modes starts DMA and enabled ints */
 		gem_set_link_modes(gp);
 	}

-	netif_wake_queue(gp->dev);
-
-	spin_unlock(&gp->tx_lock);
-	spin_unlock_irqrestore(&gp->lock, flags);
+	gp->irq_sync = 0;
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
@@ -2243,22 +2267,14 @@ static int gem_do_start(struct net_devic
 static void gem_do_stop(struct net_device *dev, int wol)
 {
 	struct gem *gp = dev->priv;
-	unsigned long flags;
-
-	spin_lock_irqsave(&gp->lock, flags);
-	spin_lock(&gp->tx_lock);
-
-	gp->running = 0;

-	/* Stop netif queue */
-	netif_stop_queue(dev);
-
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
@@ -2275,9 +2291,9 @@ static void gem_do_stop(struct net_devic

 	/* Cell not needed neither if no WOL */
 	if (!wol) {
-		spin_lock_irqsave(&gp->lock, flags);
+		gem_full_lock(gp, 0);
 		gem_put_cell(gp);
-		spin_unlock_irqrestore(&gp->lock, flags);
+		gem_full_unlock(gp);
 	}
 }

@@ -2287,31 +2303,26 @@ static void gem_reset_task(void *data)

 	mutex_lock(&gp->pm_mutex);

-	netif_poll_disable(gp->dev);
-
-	spin_lock_irq(&gp->lock);
-	spin_lock(&gp->tx_lock);
-
 	if (gp->running == 0)
 		goto not_running;

-	if (gp->running) {
-		netif_stop_queue(gp->dev);
+	gem_full_lock(gp, 1);
+	gem_disable_ints(gp);

-		/* Reset the chip & rings */
-		gem_reinit_chip(gp);
-		if (gp->lstate == link_up)
-			gem_set_link_modes(gp);
-		netif_wake_queue(gp->dev);
-	}
- not_running:
-	gp->reset_task_pending = 0;
+	gem_netif_stop(gp);
+
+	/* Reset the chip & rings */
+	gem_reinit_chip(gp);
+	if (gp->lstate == link_up)
+		gem_set_link_modes(gp);

-	spin_unlock(&gp->tx_lock);
-	spin_unlock_irq(&gp->lock);
+	gem_netif_start(gp);

-	netif_poll_enable(gp->dev);
+	gem_enable_ints(gp);
+	gem_full_unlock(gp);

+not_running:
+	gp->reset_task_pending = 0;
 	mutex_unlock(&gp->pm_mutex);
 }

@@ -2324,8 +2335,12 @@ static int gem_open(struct net_device *d
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
@@ -2337,15 +2352,14 @@ static int gem_close(struct net_device *
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

@@ -2357,22 +2371,17 @@ static int gem_suspend(struct pci_dev *p
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
@@ -2381,6 +2390,7 @@ static int gem_suspend(struct pci_dev *p

 		/* Switch off MAC, remember WOL setting */
 		gp->asleep_wol = gp->wake_on_lan;
+		gem_netif_stop(gp);
 		gem_do_stop(dev, gp->asleep_wol);
 	} else
 		gp->asleep_wol = 0;
@@ -2399,8 +2409,7 @@ static int gem_suspend(struct pci_dev *p
 	mutex_unlock(&gp->pm_mutex);

 	/* Wait for a pending reset task to complete */
-	while (gp->reset_task_pending)
-		yield();
+	gem_wait_reset_task(gp);
 	flush_scheduled_work();

 	/* Shut the PHY down eventually and setup WOL */
@@ -2421,7 +2430,6 @@ static int gem_resume(struct pci_dev *pd
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct gem *gp = dev->priv;
-	unsigned long flags;

 	printk(KERN_INFO "%s: resuming\n", dev->name);

@@ -2465,11 +2473,9 @@ static int gem_resume(struct pci_dev *pd

 		/* Re-attach net device */
 		netif_device_attach(dev);
-
 	}

-	spin_lock_irqsave(&gp->lock, flags);
-	spin_lock(&gp->tx_lock);
+	gem_full_lock(gp, 0);

 	/* If we had WOL enabled, the cell clock was never turned off during
 	 * sleep, so we end up beeing unbalanced. Fix that here
@@ -2482,10 +2488,9 @@ static int gem_resume(struct pci_dev *pd
 	 */
 	gem_put_cell(gp);

-	spin_unlock(&gp->tx_lock);
-	spin_unlock_irqrestore(&gp->lock, flags);
+	gem_full_unlock(gp);

-	netif_poll_enable(dev);
+	gem_netif_start(gp);

 	mutex_unlock(&gp->pm_mutex);

@@ -2498,8 +2503,8 @@ static struct net_device_stats *gem_get_
 	struct gem *gp = dev->priv;
 	struct net_device_stats *stats = &gp->net_stats;

-	spin_lock_irq(&gp->lock);
-	spin_lock(&gp->tx_lock);
+	gem_netif_stop(gp);
+	gem_full_lock(gp, 0);

 	/* I have seen this being called while the PM was in progress,
 	 * so we shield against this
@@ -2522,27 +2527,26 @@ static struct net_device_stats *gem_get_
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
@@ -2562,11 +2566,8 @@ #endif

 	writel(rxcfg, gp->regs + MAC_RXCFG);

-	netif_wake_queue(dev);
-
  bail:
-	spin_unlock(&gp->tx_lock);
-	spin_unlock_irq(&gp->lock);
+	gem_full_unlock(gp);
 }

 /* Jumbo-grams don't seem to work :-( */
@@ -2593,16 +2594,22 @@ static int gem_change_mtu(struct net_dev
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
@@ -2635,7 +2642,7 @@ static int gem_get_settings(struct net_d
 		cmd->phy_address = 0; /* XXX fixed PHYAD */

 		/* Return current PHY settings */
-		spin_lock_irq(&gp->lock);
+		gem_full_lock(gp, 0);
 		cmd->autoneg = gp->want_autoneg;
 		cmd->speed = gp->phy_mii.speed;
 		cmd->duplex = gp->phy_mii.duplex;
@@ -2647,7 +2654,7 @@ static int gem_get_settings(struct net_d
 		 */
 		if (cmd->advertising == 0)
 			cmd->advertising = cmd->supported;
-		spin_unlock_irq(&gp->lock);
+		gem_full_unlock(gp);
 	} else { // XXX PCS ?
 		cmd->supported =
 			(SUPPORTED_10baseT_Half | SUPPORTED_10baseT_Full |
@@ -2685,11 +2692,11 @@ static int gem_set_settings(struct net_d
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
@@ -2702,11 +2709,11 @@ static int gem_nway_reset(struct net_dev
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
@@ -2770,16 +2777,15 @@ static int gem_ioctl(struct net_device *
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
@@ -2809,9 +2815,9 @@ static int gem_ioctl(struct net_device *
 		break;
 	};

-	spin_lock_irqsave(&gp->lock, flags);
+	gem_full_lock(gp, 0);
 	gem_put_cell(gp);
-	spin_unlock_irqrestore(&gp->lock, flags);
+	gem_full_unlock(gp);

 	mutex_unlock(&gp->pm_mutex);

@@ -2918,6 +2924,7 @@ static void gem_remove_one(struct pci_de
 	if (dev) {
 		struct gem *gp = dev->priv;

+		/* unregister_netdev will close the device if it's open */
 		unregister_netdev(dev);

 		/* Stop the link timer */
@@ -2927,8 +2934,7 @@ static void gem_remove_one(struct pci_de
 		gem_get_cell(gp);

 		/* Wait for a pending reset task to complete */
-		while (gp->reset_task_pending)
-			yield();
+		gem_wait_reset_task(gp);
 		flush_scheduled_work();

 		/* Shut the PHY down */
@@ -3035,8 +3041,8 @@ static int __devinit gem_init_one(struct

 	gp->msg_enable = DEFAULT_MSG;

+	gp->irq_sync = 0;
 	spin_lock_init(&gp->lock);
-	spin_lock_init(&gp->tx_lock);
 	mutex_init(&gp->pm_mutex);

 	init_timer(&gp->link_timer);
@@ -3132,9 +3138,7 @@ #endif
 	 */
 	gem_init_phy(gp);

-	spin_lock_irq(&gp->lock);
 	gem_put_cell(gp);
-	spin_unlock_irq(&gp->lock);

 	/* Register with kernel */
 	if (register_netdev(dev)) {
@@ -3156,8 +3160,7 @@ #endif
 		printk(KERN_INFO "%s: Found %s PHY\n", dev->name,
 			gp->phy_mii.def ? gp->phy_mii.def->name : "no");

-	/* GEM can do it all... */
-	dev->features |= NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_LLTX;
+	dev->features |= NETIF_F_SG | NETIF_F_HW_CSUM;
 	if (pci_using_dac)
 		dev->features |= NETIF_F_HIGHDMA;

@@ -3177,7 +3180,6 @@ err_out_free_netdev:
 err_disable_device:
 	pci_disable_device(pdev);
 	return err;
-
 }


diff --git a/drivers/net/sungem.h b/drivers/net/sungem.h
index a70067c..5869818 100644
--- a/drivers/net/sungem.h
+++ b/drivers/net/sungem.h
@@ -929,11 +929,6 @@ #endif
 #define NEXT_TX(N)	(((N) + 1) & (TX_RING_SIZE - 1))
 #define NEXT_RX(N)	(((N) + 1) & (RX_RING_SIZE - 1))

-#define TX_BUFFS_AVAIL(GP)					\
-	(((GP)->tx_old <= (GP)->tx_new) ?			\
-	  (GP)->tx_old + (TX_RING_SIZE - 1) - (GP)->tx_new :	\
-	  (GP)->tx_old - (GP)->tx_new - 1)
-
 #define RX_OFFSET          2
 #define RX_BUF_ALLOC_SIZE(gp)	((gp)->rx_buf_sz + 28 + RX_OFFSET + 64)

@@ -973,8 +968,8 @@ enum link_state {
 };

 struct gem {
+	int			irq_sync;
 	spinlock_t		lock;
-	spinlock_t		tx_lock;
 	void __iomem		*regs;
 	int			rx_new, rx_old;
 	int			tx_new, tx_old;

------=_Part_39968_26552275.1164839825378
Content-Type: text/x-patch; name=sungem-locking-take2.patch;
	charset=ANSI_X3.4-1968
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ev4bfuzg
Content-Disposition: attachment; filename="sungem-locking-take2.patch"

ZGlmZiAtLWdpdCBhL2RyaXZlcnMvbmV0L3N1bmdlbS5jIGIvZHJpdmVycy9uZXQvc3VuZ2VtLmMK
aW5kZXggMjUzZTk2ZS4uMTA4NWMzZCAxMDA2NDQKLS0tIGEvZHJpdmVycy9uZXQvc3VuZ2VtLmMK
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
CiAjaW5jbHVkZSA8bGludXgvbW9kdWxlLmg+CkBAIC0yMDYsMTggKzE4Niw2NiBAQCBzdGF0aWMg
aW5saW5lIHZvaWQgcGh5X3dyaXRlKHN0cnVjdCBnZW0gCiAJX19waHlfd3JpdGUoZ3AsIGdwLT5t
aWlfcGh5X2FkZHIsIHJlZywgdmFsKTsKIH0KIAotc3RhdGljIGlubGluZSB2b2lkIGdlbV9lbmFi
bGVfaW50cyhzdHJ1Y3QgZ2VtICpncCkKK3N0YXRpYyBpbmxpbmUgdm9pZCBfX2dlbV9lbmFibGVf
aW50cyhzdHJ1Y3QgZ2VtICpncCkKIHsKLQkvKiBFbmFibGUgYWxsIGludGVycnVwdHMgYnV0IFRY
RE9ORSAqLworCS8qIEVuYWJsZSBhbGwgaW50ZXJydXB0cywgYnV0IFRYRE9ORSAqLwogCXdyaXRl
bChHUkVHX1NUQVRfVFhET05FLCBncC0+cmVncyArIEdSRUdfSU1BU0spOwogfQogCitzdGF0aWMg
aW5saW5lIHZvaWQgZ2VtX2VuYWJsZV9pbnRzKHN0cnVjdCBnZW0gKmdwKQoreworCWdwLT5pcnFf
c3luYyA9IDA7CisJd21iKCk7CisJX19nZW1fZW5hYmxlX2ludHMoZ3ApOworfQorCiBzdGF0aWMg
aW5saW5lIHZvaWQgZ2VtX2Rpc2FibGVfaW50cyhzdHJ1Y3QgZ2VtICpncCkKIHsKIAkvKiBEaXNh
YmxlIGFsbCBpbnRlcnJ1cHRzLCBpbmNsdWRpbmcgVFhET05FICovCiAJd3JpdGVsKEdSRUdfU1RB
VF9OQVBJIHwgR1JFR19TVEFUX1RYRE9ORSwgZ3AtPnJlZ3MgKyBHUkVHX0lNQVNLKTsKIH0KIAor
c3RhdGljIGlubGluZSB1MzIgZ2VtX3JlYWRfc3RhdHVzKHN0cnVjdCBnZW0gKmdwKQoreworCXJl
dHVybiByZWFkbChncC0+cmVncyArIEdSRUdfU1RBVCk7Cit9CisKK3N0YXRpYyBpbmxpbmUgdm9p
ZCBnZW1fbmV0aWZfc3RvcChzdHJ1Y3QgZ2VtICpncCkKK3sKKwlzdHJ1Y3QgbmV0X2RldmljZSAq
ZGV2ID0gZ3AtPmRldjsKKworCWRldi0+dHJhbnNfc3RhcnQgPSBqaWZmaWVzOyAvKiBwcmV2ZW50
IHR4IHRpbWVvdXQgKi8KKwluZXRpZl9wb2xsX2Rpc2FibGUoZGV2KTsKKwluZXRpZl90eF9kaXNh
YmxlKGRldik7Cit9CisKK3N0YXRpYyBpbmxpbmUgdm9pZCBnZW1fbmV0aWZfc3RhcnQoc3RydWN0
IGdlbSAqZ3ApCit7CisJc3RydWN0IG5ldF9kZXZpY2UgKmRldiA9IGdwLT5kZXY7CisKKwkvKiBV
bmNvbmRpdGlvbm5hbHkgbmV0aWZfd2FrZV9xdWV1ZSBpcyBvayBzbyBsb25nIGFzIGNhbGxlciBo
YXMKKwkgKiBmcmVlZCB0eCBzbG90cywgd2hpcyBkb25lIGluIGdlbV9yZWluaXRfY2hpcCgpLgor
CSAqLworCW5ldGlmX3dha2VfcXVldWUoZGV2KTsKKwluZXRpZl9wb2xsX2VuYWJsZShkZXYpOwor
fQorCitzdGF0aWMgaW5saW5lIHZvaWQgZ2VtX3NjaGVkdWxlX3Jlc2V0X3Rhc2soc3RydWN0IGdl
bSAqZ3ApCit7CisJZ3AtPnJlc2V0X3Rhc2tfcGVuZGluZyA9IDE7CisJc21wX21iKCk7CisJc2No
ZWR1bGVfd29yaygmZ3AtPnJlc2V0X3Rhc2spOworfQorCitzdGF0aWMgaW5saW5lIHZvaWQgZ2Vt
X3dhaXRfcmVzZXRfdGFzayhzdHJ1Y3QgZ2VtICpncCkKK3sKKwltYigpOworCXdoaWxlIChncC0+
cmVzZXRfdGFza19wZW5kaW5nKSB7CisJCXlpZWxkKCk7CisJCW1iKCk7CisJfQorfQorCiBzdGF0
aWMgdm9pZCBnZW1fZ2V0X2NlbGwoc3RydWN0IGdlbSAqZ3ApCiB7CiAJQlVHX09OKGdwLT5jZWxs
X2VuYWJsZWQgPCAwKTsKQEAgLTY1OCwxMiArNjg2LDIwIEBAIHN0YXRpYyBpbnQgZ2VtX2Fibm9y
bWFsX2lycShzdHJ1Y3QgbmV0X2QKIAlyZXR1cm4gMDsKIAogZG9fcmVzZXQ6Ci0JZ3AtPnJlc2V0
X3Rhc2tfcGVuZGluZyA9IDE7Ci0Jc2NoZWR1bGVfd29yaygmZ3AtPnJlc2V0X3Rhc2spOworCWdl
bV9zY2hlZHVsZV9yZXNldF90YXNrKGdwKTsKIAogCXJldHVybiAxOwogfQogCitzdGF0aWMgaW5s
aW5lIHUzMiBnZW1fdHhfYXZhaWwoc3RydWN0IGdlbSAqZ3ApCit7CisJc21wX21iKCk7CisJcmV0
dXJuIChncC0+dHhfb2xkIDw9IGdwLT50eF9uZXcpID8KKwkJZ3AtPnR4X29sZCArIChUWF9SSU5H
X1NJWkUgLSAxKSAtIGdwLT50eF9uZXcgOgorCQlncC0+dHhfb2xkIC0gZ3AtPnR4X25ldyAtIDE7
Cit9CisKKwogc3RhdGljIF9faW5saW5lX18gdm9pZCBnZW1fdHgoc3RydWN0IG5ldF9kZXZpY2Ug
KmRldiwgc3RydWN0IGdlbSAqZ3AsIHUzMiBnZW1fc3RhdHVzKQogewogCWludCBlbnRyeSwgbGlt
aXQ7CkBAIC03MTcsMTEgKzc1MywyMCBAQCBzdGF0aWMgX19pbmxpbmVfXyB2b2lkIGdlbV90eChz
dHJ1Y3QgbmV0CiAJCWdwLT5uZXRfc3RhdHMudHhfcGFja2V0cysrOwogCQlkZXZfa2ZyZWVfc2ti
X2lycShza2IpOwogCX0KKwogCWdwLT50eF9vbGQgPSBlbnRyeTsKIAotCWlmIChuZXRpZl9xdWV1
ZV9zdG9wcGVkKGRldikgJiYKLQkgICAgVFhfQlVGRlNfQVZBSUwoZ3ApID4gKE1BWF9TS0JfRlJB
R1MgKyAxKSkKLQkJbmV0aWZfd2FrZV9xdWV1ZShkZXYpOworCS8qIE5lZWQgdG8gbWFrZSB0eF9v
bGQgdXBkYXRlIHZpc2libGUgdG8gZ2VtX3N0YXJ0X3htaXQoKSAqLworCXNtcF9tYigpOworCisJ
aWYgKHVubGlrZWx5KG5ldGlmX3F1ZXVlX3N0b3BwZWQoZGV2KSAmJgorCSAgICBnZW1fdHhfYXZh
aWwoZ3ApID4gKE1BWF9TS0JfRlJBR1MgKyAxKSkpIHsKKwkJbmV0aWZfdHhfbG9jayhkZXYpOwor
CQlpZiAobmV0aWZfcXVldWVfc3RvcHBlZChkZXYpICYmCisJICAgIAkgICAgZ2VtX3R4X2F2YWls
KGdwKSA+IChNQVhfU0tCX0ZSQUdTICsgMSkpCisJCQluZXRpZl93YWtlX3F1ZXVlKGRldik7CisJ
CW5ldGlmX3R4X3VubG9jayhkZXYpOworCX0KIH0KIAogc3RhdGljIF9faW5saW5lX18gdm9pZCBn
ZW1fcG9zdF9yeGRzKHN0cnVjdCBnZW0gKmdwLCBpbnQgbGltaXQpCkBAIC04ODIsMTIgKzkyNyw2
IEBAIHN0YXRpYyBpbnQgZ2VtX3J4KHN0cnVjdCBnZW0gKmdwLCBpbnQgd28KIHN0YXRpYyBpbnQg
Z2VtX3BvbGwoc3RydWN0IG5ldF9kZXZpY2UgKmRldiwgaW50ICpidWRnZXQpCiB7CiAJc3RydWN0
IGdlbSAqZ3AgPSBkZXYtPnByaXY7Ci0JdW5zaWduZWQgbG9uZyBmbGFnczsKLQotCS8qCi0JICog
TkFQSSBsb2NraW5nIG5pZ2h0bWFyZTogU2VlIGNvbW1lbnQgYXQgaGVhZCBvZiBkcml2ZXIKLQkg
Ki8KLQlzcGluX2xvY2tfaXJxc2F2ZSgmZ3AtPmxvY2ssIGZsYWdzKTsKIAogCWRvIHsKIAkJaW50
IHdvcmtfdG9fZG8sIHdvcmtfZG9uZTsKQEAgLTg5OSwxOSArOTM4LDEwIEBAIHN0YXRpYyBpbnQg
Z2VtX3BvbGwoc3RydWN0IG5ldF9kZXZpY2UgKmQKIAkJfQogCiAJCS8qIFJ1biBUWCBjb21wbGV0
aW9uIHRocmVhZCAqLwotCQlzcGluX2xvY2soJmdwLT50eF9sb2NrKTsKIAkJZ2VtX3R4KGRldiwg
Z3AsIGdwLT5zdGF0dXMpOwotCQlzcGluX3VubG9jaygmZ3AtPnR4X2xvY2spOwogCi0JCXNwaW5f
dW5sb2NrX2lycXJlc3RvcmUoJmdwLT5sb2NrLCBmbGFncyk7Ci0KLQkJLyogUnVuIFJYIHRocmVh
ZC4gV2UgZG9uJ3QgdXNlIGFueSBsb2NraW5nIGhlcmUsCi0JCSAqIGNvZGUgd2lsbGluZyB0byBk
byBiYWQgdGhpbmdzIC0gbGlrZSBjbGVhbmluZyB0aGUKLQkJICogcnggcmluZyAtIG11c3QgY2Fs
bCBuZXRpZl9wb2xsX2Rpc2FibGUoKSwgd2hpY2gKLQkJICogc2NoZWR1bGVfdGltZW91dCgpJ3Mg
aWYgcG9sbGluZyBpcyBhbHJlYWR5IGRpc2FibGVkLgotCQkgKi8KKwkJLyogUnVuIFJYIHRocmVh
ZCAqLwogCQl3b3JrX3RvX2RvID0gbWluKCpidWRnZXQsIGRldi0+cXVvdGEpOwotCiAJCXdvcmtf
ZG9uZSA9IGdlbV9yeChncCwgd29ya190b19kbyk7CiAKIAkJKmJ1ZGdldCAtPSB3b3JrX2RvbmU7
CkBAIC05MjAsNTMgKzk1MCw5MCBAQCBzdGF0aWMgaW50IGdlbV9wb2xsKHN0cnVjdCBuZXRfZGV2
aWNlICpkCiAJCWlmICh3b3JrX2RvbmUgPj0gd29ya190b19kbykKIAkJCXJldHVybiAxOwogCi0J
CXNwaW5fbG9ja19pcnFzYXZlKCZncC0+bG9jaywgZmxhZ3MpOwotCi0JCWdwLT5zdGF0dXMgPSBy
ZWFkbChncC0+cmVncyArIEdSRUdfU1RBVCk7CisJCWdwLT5zdGF0dXMgPSBnZW1fcmVhZF9zdGF0
dXMoZ3ApOwogCX0gd2hpbGUgKGdwLT5zdGF0dXMgJiBHUkVHX1NUQVRfTkFQSSk7CiAKIAlfX25l
dGlmX3J4X2NvbXBsZXRlKGRldik7Ci0JZ2VtX2VuYWJsZV9pbnRzKGdwKTsKKwlfX2dlbV9lbmFi
bGVfaW50cyhncCk7CiAKLQlzcGluX3VubG9ja19pcnFyZXN0b3JlKCZncC0+bG9jaywgZmxhZ3Mp
OwogCXJldHVybiAwOwogfQogCitzdGF0aWMgdm9pZCBnZW1faXJxX3F1aWVzY2Uoc3RydWN0IGdl
bSAqZ3ApCit7CisJQlVHX09OKGdwLT5pcnFfc3luYyk7CisKKwlncC0+aXJxX3N5bmMgPSAxOwor
CXNtcF9tYigpOworCisJc3luY2hyb25pemVfaXJxKGdwLT5wZGV2LT5pcnEpOworfQorCitzdGF0
aWMgaW5saW5lIGludCBnZW1faXJxX3N5bmMoc3RydWN0IGdlbSAqZ3ApCit7CisJcmV0dXJuIGdw
LT5pcnFfc3luYzsKK30KKworc3RhdGljIGlubGluZSB2b2lkIGdlbV9mdWxsX2xvY2soc3RydWN0
IGdlbSAqZ3AsIGludCBpcnFfc3luYykKK3sKKwlzcGluX2xvY2tfYmgoJmdwLT5sb2NrKTsKKwlp
ZiAoaXJxX3N5bmMpCisJCWdlbV9pcnFfcXVpZXNjZShncCk7Cit9CisKK3N0YXRpYyBpbmxpbmUg
dm9pZCBnZW1fZnVsbF91bmxvY2soc3RydWN0IGdlbSAqZ3ApCit7CisJc3Bpbl91bmxvY2tfYmgo
JmdwLT5sb2NrKTsKK30KKwogc3RhdGljIGlycXJldHVybl90IGdlbV9pbnRlcnJ1cHQoaW50IGly
cSwgdm9pZCAqZGV2X2lkKQogewogCXN0cnVjdCBuZXRfZGV2aWNlICpkZXYgPSBkZXZfaWQ7CiAJ
c3RydWN0IGdlbSAqZ3AgPSBkZXYtPnByaXY7Ci0JdW5zaWduZWQgbG9uZyBmbGFnczsKKwl1bnNp
Z25lZCBpbnQgaGFuZGxlZCA9IDE7CiAKIAkvKiBTd2FsbG93IGludGVycnVwdHMgd2hlbiBzaHV0
dGluZyB0aGUgY2hpcCBkb3duLCB0aG91Z2gKIAkgKiB0aGF0IHNob3VsZG4ndCBoYXBwZW4sIHdl
IHNob3VsZCBoYXZlIGRvbmUgZnJlZV9pcnEoKSBhdAogCSAqIHRoaXMgcG9pbnQuLi4KIAkgKi8K
IAlpZiAoIWdwLT5ydW5uaW5nKQotCQlyZXR1cm4gSVJRX0hBTkRMRUQ7Ci0KLQlzcGluX2xvY2tf
aXJxc2F2ZSgmZ3AtPmxvY2ssIGZsYWdzKTsKKwkJZ290byBvdXQ7CiAKIAlpZiAobmV0aWZfcnhf
c2NoZWR1bGVfcHJlcChkZXYpKSB7Ci0JCXUzMiBnZW1fc3RhdHVzID0gcmVhZGwoZ3AtPnJlZ3Mg
KyBHUkVHX1NUQVQpOworCQl1MzIgZ2VtX3N0YXR1czsKKwkJCisJCWdlbV9zdGF0dXMgPSBnZW1f
cmVhZF9zdGF0dXMoZ3ApOworCQlpZiAodW5saWtlbHkoIWdlbV9zdGF0dXMpKSB7CisJCQkvKiBT
aGFyZWQgSVJRLiBXZSBzdGlsbCB3YW50IHRvIF9fbmV0aWZfcnhfc2NoZWR1bGUKKwkJCSAqIGhl
cmUsIGJlY2F1c2Ugd2UgZG9uJ3Qgd2FudCB0byBtaXNzIE5JQyBldmVudHMKKwkJCSAqIHNob3Vs
ZCB0aGUgZm9sbG93aW5nIHNjZW5hcmlvIG9jY3VyOgorCQkJICoKKwkJCSAqIENQVTAJCQkJQ1BV
MQorCQkJICogaW50ZXJydXB0CisJCQkgKiBwcmVwYXJlIHJ4IHNjaGVkdWxlCisJCQkgKiAJCQkJ
aW50ZXJydXB0CisJCQkgKiAJCQkJcnggaXMgYWxyZWFkeSBzY2hlZHVsZWQKKwkJCSAqIGdlbV9z
dGF0dXMgaXMgMCAod2UgY2FuCisJCQkgKiBtaXNzIE5JQyBldmVudHMgaWYgd2UgCisJCQkgKiBk
b24ndCBfX25ldGlmX3J4X3NjaGVkdWxlCisJCQkgKiBhbmQgcmV0dXJuIHJpZ2h0IGF3YXkgaGVy
ZSkKKwkJCSAqLworCQkJaGFuZGxlZCA9IDA7CisJCX0KKworCQlnZW1fZGlzYWJsZV9pbnRzKGdw
KTsKIAotCQlpZiAoZ2VtX3N0YXR1cyA9PSAwKSB7CisJCWlmIChnZW1faXJxX3N5bmMoZ3ApKSB7
CiAJCQluZXRpZl9wb2xsX2VuYWJsZShkZXYpOwotCQkJc3Bpbl91bmxvY2tfaXJxcmVzdG9yZSgm
Z3AtPmxvY2ssIGZsYWdzKTsKLQkJCXJldHVybiBJUlFfTk9ORTsKKwkJCWdvdG8gb3V0OwogCQl9
CisKIAkJZ3AtPnN0YXR1cyA9IGdlbV9zdGF0dXM7Ci0JCWdlbV9kaXNhYmxlX2ludHMoZ3ApOwog
CQlfX25ldGlmX3J4X3NjaGVkdWxlKGRldik7CiAJfQogCi0Jc3Bpbl91bmxvY2tfaXJxcmVzdG9y
ZSgmZ3AtPmxvY2ssIGZsYWdzKTsKLQotCS8qIElmIHBvbGxpbmcgd2FzIGRpc2FibGVkIGF0IHRo
ZSB0aW1lIHdlIHJlY2VpdmVkIHRoYXQKLQkgKiBpbnRlcnJ1cHQsIHdlIG1heSByZXR1cm4gSVJR
X0hBTkRMRUQgaGVyZSB3aGlsZSB3ZQotCSAqIHNob3VsZCByZXR1cm4gSVJRX05PTkUuIE5vIGJp
ZyBkZWFsLi4uCi0JICovCi0JcmV0dXJuIElSUV9IQU5ETEVEOworb3V0OgorCXJldHVybiBJUlFf
UkVUVkFMKGhhbmRsZWQpOwogfQogCiAjaWZkZWYgQ09ORklHX05FVF9QT0xMX0NPTlRST0xMRVIK
QEAgLTk5OSwxNCArMTA2Niw3IEBAIHN0YXRpYyB2b2lkIGdlbV90eF90aW1lb3V0KHN0cnVjdCBu
ZXRfZGUKIAkgICAgICAgcmVhZGwoZ3AtPnJlZ3MgKyBNQUNfUlhTVEFUKSwKIAkgICAgICAgcmVh
ZGwoZ3AtPnJlZ3MgKyBNQUNfUlhDRkcpKTsKIAotCXNwaW5fbG9ja19pcnEoJmdwLT5sb2NrKTsK
LQlzcGluX2xvY2soJmdwLT50eF9sb2NrKTsKLQotCWdwLT5yZXNldF90YXNrX3BlbmRpbmcgPSAx
OwotCXNjaGVkdWxlX3dvcmsoJmdwLT5yZXNldF90YXNrKTsKLQotCXNwaW5fdW5sb2NrKCZncC0+
dHhfbG9jayk7Ci0Jc3Bpbl91bmxvY2tfaXJxKCZncC0+bG9jayk7CisJZ2VtX3NjaGVkdWxlX3Jl
c2V0X3Rhc2soZ3ApOwogfQogCiBzdGF0aWMgX19pbmxpbmVfXyBpbnQgZ2VtX2ludG1lKGludCBl
bnRyeSkKQEAgLTEwMjMsNyArMTA4Myw2IEBAIHN0YXRpYyBpbnQgZ2VtX3N0YXJ0X3htaXQoc3Ry
dWN0IHNrX2J1ZmYKIAlzdHJ1Y3QgZ2VtICpncCA9IGRldi0+cHJpdjsKIAlpbnQgZW50cnk7CiAJ
dTY0IGN0cmw7Ci0JdW5zaWduZWQgbG9uZyBmbGFnczsKIAogCWN0cmwgPSAwOwogCWlmIChza2It
PmlwX3N1bW1lZCA9PSBDSEVDS1NVTV9QQVJUSUFMKSB7CkBAIC0xMDM3LDI0ICsxMDk2LDEzIEBA
IHN0YXRpYyBpbnQgZ2VtX3N0YXJ0X3htaXQoc3RydWN0IHNrX2J1ZmYKIAkJCShjc3VtX3N0dWZm
X29mZiA8PCAyMSkpOwogCX0KIAotCWxvY2FsX2lycV9zYXZlKGZsYWdzKTsKLQlpZiAoIXNwaW5f
dHJ5bG9jaygmZ3AtPnR4X2xvY2spKSB7Ci0JCS8qIFRlbGwgdXBwZXIgbGF5ZXIgdG8gcmVxdWV1
ZSAqLwotCQlsb2NhbF9pcnFfcmVzdG9yZShmbGFncyk7Ci0JCXJldHVybiBORVRERVZfVFhfTE9D
S0VEOwotCX0KLQkvKiBXZSByYWNlZCB3aXRoIGdlbV9kb19zdG9wKCkgKi8KLQlpZiAoIWdwLT5y
dW5uaW5nKSB7Ci0JCXNwaW5fdW5sb2NrX2lycXJlc3RvcmUoJmdwLT50eF9sb2NrLCBmbGFncyk7
Ci0JCXJldHVybiBORVRERVZfVFhfQlVTWTsKLQl9Ci0KIAkvKiBUaGlzIGlzIGEgaGFyZCBlcnJv
ciwgbG9nIGl0LiAqLwotCWlmIChUWF9CVUZGU19BVkFJTChncCkgPD0gKHNrYl9zaGluZm8oc2ti
KS0+bnJfZnJhZ3MgKyAxKSkgewotCQluZXRpZl9zdG9wX3F1ZXVlKGRldik7Ci0JCXNwaW5fdW5s
b2NrX2lycXJlc3RvcmUoJmdwLT50eF9sb2NrLCBmbGFncyk7Ci0JCXByaW50ayhLRVJOX0VSUiBQ
RlggIiVzOiBCVUchIFR4IFJpbmcgZnVsbCB3aGVuIHF1ZXVlIGF3YWtlIVxuIiwKLQkJICAgICAg
IGRldi0+bmFtZSk7CisJaWYgKGdlbV90eF9hdmFpbChncCkgPD0gKHNrYl9zaGluZm8oc2tiKS0+
bnJfZnJhZ3MgKyAxKSkgeworCQlpZiAoIW5ldGlmX3F1ZXVlX3N0b3BwZWQoZGV2KSkgeworCQkJ
bmV0aWZfc3RvcF9xdWV1ZShkZXYpOworCQkJcHJpbnRrKEtFUk5fRVJSIFBGWCAiJXM6IEJVRyEg
VHggUmluZyBmdWxsIHdoZW4gIgorCQkJICAgICAgICJxdWV1ZSBhd2FrZSFcbiIsIGRldi0+bmFt
ZSk7CisJCX0KIAkJcmV0dXJuIE5FVERFVl9UWF9CVVNZOwogCX0KIApAQCAtMTEzMSwxNSArMTE3
OSwxNyBAQCBzdGF0aWMgaW50IGdlbV9zdGFydF94bWl0KHN0cnVjdCBza19idWZmCiAJfQogCiAJ
Z3AtPnR4X25ldyA9IGVudHJ5OwotCWlmIChUWF9CVUZGU19BVkFJTChncCkgPD0gKE1BWF9TS0Jf
RlJBR1MgKyAxKSkKKwlpZiAodW5saWtlbHkoZ2VtX3R4X2F2YWlsKGdwKSA8PSAoTUFYX1NLQl9G
UkFHUyArIDEpKSkgewogCQluZXRpZl9zdG9wX3F1ZXVlKGRldik7CisJCWlmIChnZW1fdHhfYXZh
aWwoZ3ApID4gKE1BWF9TS0JfRlJBR1MgKyAxKSkKKwkJCW5ldGlmX3dha2VfcXVldWUoZGV2KTsK
Kwl9CiAKIAlpZiAobmV0aWZfbXNnX3R4X3F1ZXVlZChncCkpCiAJCXByaW50ayhLRVJOX0RFQlVH
ICIlczogdHggcXVldWVkLCBzbG90ICVkLCBza2JsZW4gJWRcbiIsCiAJCSAgICAgICBkZXYtPm5h
bWUsIGVudHJ5LCBza2ItPmxlbik7CiAJbWIoKTsKIAl3cml0ZWwoZ3AtPnR4X25ldywgZ3AtPnJl
Z3MgKyBUWERNQV9LSUNLKTsKLQlzcGluX3VubG9ja19pcnFyZXN0b3JlKCZncC0+dHhfbG9jaywg
ZmxhZ3MpOwogCiAJZGV2LT50cmFuc19zdGFydCA9IGppZmZpZXM7CiAKQEAgLTExNDgsNyArMTE5
OCw2IEBAIHN0YXRpYyBpbnQgZ2VtX3N0YXJ0X3htaXQoc3RydWN0IHNrX2J1ZmYKIAogI2RlZmlu
ZSBTVE9QX1RSSUVTIDMyCiAKLS8qIE11c3QgYmUgaW52b2tlZCB1bmRlciBncC0+bG9jayBhbmQg
Z3AtPnR4X2xvY2suICovCiBzdGF0aWMgdm9pZCBnZW1fcmVzZXQoc3RydWN0IGdlbSAqZ3ApCiB7
CiAJaW50IGxpbWl0OwpAQCAtMTE3NCw3ICsxMjIzLDYgQEAgc3RhdGljIHZvaWQgZ2VtX3Jlc2V0
KHN0cnVjdCBnZW0gKmdwKQogCQlwcmludGsoS0VSTl9FUlIgIiVzOiBTVyByZXNldCBpcyBnaGV0
dG8uXG4iLCBncC0+ZGV2LT5uYW1lKTsKIH0KIAotLyogTXVzdCBiZSBpbnZva2VkIHVuZGVyIGdw
LT5sb2NrIGFuZCBncC0+dHhfbG9jay4gKi8KIHN0YXRpYyB2b2lkIGdlbV9zdGFydF9kbWEoc3Ry
dWN0IGdlbSAqZ3ApCiB7CiAJdTMyIHZhbDsKQEAgLTExOTcsOSArMTI0NSw3IEBAIHN0YXRpYyB2
b2lkIGdlbV9zdGFydF9kbWEoc3RydWN0IGdlbSAqZ3AKIAl3cml0ZWwoUlhfUklOR19TSVpFIC0g
NCwgZ3AtPnJlZ3MgKyBSWERNQV9LSUNLKTsKIH0KIAotLyogTXVzdCBiZSBpbnZva2VkIHVuZGVy
IGdwLT5sb2NrIGFuZCBncC0+dHhfbG9jay4gRE1BIHdvbid0IGJlCi0gKiBhY3R1YWxseSBzdG9w
cGVkIGJlZm9yZSBhYm91dCA0bXMgdGhvIC4uLgotICovCisvKiBETUEgd29uJ3QgYmUgYWN0dWFs
bHkgc3RvcHBlZCBiZWZvcmUgYWJvdXQgNG1zIHRobyAuLi4gKi8KIHN0YXRpYyB2b2lkIGdlbV9z
dG9wX2RtYShzdHJ1Y3QgZ2VtICpncCkKIHsKIAl1MzIgdmFsOwpAQCAtMTIyMCw4ICsxMjY2LDcg
QEAgc3RhdGljIHZvaWQgZ2VtX3N0b3BfZG1hKHN0cnVjdCBnZW0gKmdwKQogfQogCiAKLS8qIE11
c3QgYmUgaW52b2tlZCB1bmRlciBncC0+bG9jayBhbmQgZ3AtPnR4X2xvY2suICovCi0vLyBYWFgg
ZGJsIGNoZWNrIHdoYXQgdGhhdCBmdW5jdGlvbiBzaG91bGQgZG8gd2hlbiBjYWxsZWQgb24gUENT
IFBIWQorLyogWFhYIGRibCBjaGVjayB3aGF0IHRoYXQgZnVuY3Rpb24gc2hvdWxkIGRvIHdoZW4g
Y2FsbGVkIG9uIFBDUyBQSFkgKi8KIHN0YXRpYyB2b2lkIGdlbV9iZWdpbl9hdXRvX25lZ290aWF0
aW9uKHN0cnVjdCBnZW0gKmdwLCBzdHJ1Y3QgZXRodG9vbF9jbWQgKmVwKQogewogCXUzMiBhZHZl
cnRpc2UsIGZlYXR1cmVzOwpAQCAtMTMwNiw4ICsxMzUxLDYgQEAgbm9uX21paToKIAogLyogQSBs
aW5rLXVwIGNvbmRpdGlvbiBoYXMgb2NjdXJyZWQsIGluaXRpYWxpemUgYW5kIGVuYWJsZSB0aGUK
ICAqIHJlc3Qgb2YgdGhlIGNoaXAuCi0gKgotICogTXVzdCBiZSBpbnZva2VkIHVuZGVyIGdwLT5s
b2NrIGFuZCBncC0+dHhfbG9jay4KICAqLwogc3RhdGljIGludCBnZW1fc2V0X2xpbmtfbW9kZXMo
c3RydWN0IGdlbSAqZ3ApCiB7CkBAIC0xNDE3LDcgKzE0NjAsNiBAQCBzdGF0aWMgaW50IGdlbV9z
ZXRfbGlua19tb2RlcyhzdHJ1Y3QgZ2VtCiAJcmV0dXJuIDA7CiB9CiAKLS8qIE11c3QgYmUgaW52
b2tlZCB1bmRlciBncC0+bG9jayBhbmQgZ3AtPnR4X2xvY2suICovCiBzdGF0aWMgaW50IGdlbV9t
ZGlvX2xpbmtfbm90X3VwKHN0cnVjdCBnZW0gKmdwKQogewogCXN3aXRjaCAoZ3AtPmxzdGF0ZSkg
ewpAQCAtMTQ3NCwxMyArMTUxNiwxMyBAQCBzdGF0aWMgdm9pZCBnZW1fbGlua190aW1lcih1bnNp
Z25lZCBsb25nCiAJaWYgKGdwLT5hc2xlZXApCiAJCXJldHVybjsKIAotCXNwaW5fbG9ja19pcnEo
JmdwLT5sb2NrKTsKLQlzcGluX2xvY2soJmdwLT50eF9sb2NrKTsKKwlnZW1fZnVsbF9sb2NrKGdw
LCAwKTsKIAlnZW1fZ2V0X2NlbGwoZ3ApOwogCiAJLyogSWYgdGhlIHJlc2V0IHRhc2sgaXMgc3Rp
bGwgcGVuZGluZywgd2UganVzdAogCSAqIHJlc2NoZWR1bGUgdGhlIGxpbmsgdGltZXIKIAkgKi8K
KwlzbXBfbWIoKTsKIAlpZiAoZ3AtPnJlc2V0X3Rhc2tfcGVuZGluZykKIAkJZ290byByZXN0YXJ0
OwogCkBAIC0xNTI4LDggKzE1NzAsNyBAQCBzdGF0aWMgdm9pZCBnZW1fbGlua190aW1lcih1bnNp
Z25lZCBsb25nCiAJCQkJcHJpbnRrKEtFUk5fSU5GTyAiJXM6IExpbmsgZG93blxuIiwKIAkJCQkJ
Z3AtPmRldi0+bmFtZSk7CiAJCQluZXRpZl9jYXJyaWVyX29mZihncC0+ZGV2KTsKLQkJCWdwLT5y
ZXNldF90YXNrX3BlbmRpbmcgPSAxOwotCQkJc2NoZWR1bGVfd29yaygmZ3AtPnJlc2V0X3Rhc2sp
OworCQkJZ2VtX3NjaGVkdWxlX3Jlc2V0X3Rhc2soZ3ApOwogCQkJcmVzdGFydF9hbmVnID0gMTsK
IAkJfSBlbHNlIGlmICgrK2dwLT50aW1lcl90aWNrcyA+IDEwKSB7CiAJCQlpZiAoZm91bmRfbWlp
X3BoeShncCkpCkBAIC0xNTQ2LDExICsxNTg3LDkgQEAgcmVzdGFydDoKIAltb2RfdGltZXIoJmdw
LT5saW5rX3RpbWVyLCBqaWZmaWVzICsgKCgxMiAqIEhaKSAvIDEwKSk7CiBvdXRfdW5sb2NrOgog
CWdlbV9wdXRfY2VsbChncCk7Ci0Jc3Bpbl91bmxvY2soJmdwLT50eF9sb2NrKTsKLQlzcGluX3Vu
bG9ja19pcnEoJmdwLT5sb2NrKTsKKwlnZW1fZnVsbF91bmxvY2soZ3ApOwogfQogCi0vKiBNdXN0
IGJlIGludm9rZWQgdW5kZXIgZ3AtPmxvY2sgYW5kIGdwLT50eF9sb2NrLiAqLwogc3RhdGljIHZv
aWQgZ2VtX2NsZWFuX3JpbmdzKHN0cnVjdCBnZW0gKmdwKQogewogCXN0cnVjdCBnZW1faW5pdF9i
bG9jayAqZ2IgPSBncC0+aW5pdF9ibG9jazsKQEAgLTE2MDEsNyArMTY0MCw2IEBAIHN0YXRpYyB2
b2lkIGdlbV9jbGVhbl9yaW5ncyhzdHJ1Y3QgZ2VtICoKIAl9CiB9CiAKLS8qIE11c3QgYmUgaW52
b2tlZCB1bmRlciBncC0+bG9jayBhbmQgZ3AtPnR4X2xvY2suICovCiBzdGF0aWMgdm9pZCBnZW1f
aW5pdF9yaW5ncyhzdHJ1Y3QgZ2VtICpncCkKIHsKIAlzdHJ1Y3QgZ2VtX2luaXRfYmxvY2sgKmdi
ID0gZ3AtPmluaXRfYmxvY2s7CkBAIC0xNzc1LDEyICsxODEzLDkgQEAgI2VuZGlmCiAJbmV0aWZf
Y2Fycmllcl9vZmYoZ3AtPmRldik7CiAKIAkvKiBDYW4gSSBhZHZlcnRpc2UgZ2lnYWJpdCBoZXJl
ID8gSSdkIG5lZWQgQkNNIFBIWSBkb2NzLi4uICovCi0Jc3Bpbl9sb2NrX2lycSgmZ3AtPmxvY2sp
OwogCWdlbV9iZWdpbl9hdXRvX25lZ290aWF0aW9uKGdwLCBOVUxMKTsKLQlzcGluX3VubG9ja19p
cnEoJmdwLT5sb2NrKTsKIH0KIAotLyogTXVzdCBiZSBpbnZva2VkIHVuZGVyIGdwLT5sb2NrIGFu
ZCBncC0+dHhfbG9jay4gKi8KIHN0YXRpYyB2b2lkIGdlbV9pbml0X2RtYShzdHJ1Y3QgZ2VtICpn
cCkKIHsKIAl1NjQgZGVzY19kbWEgPSAodTY0KSBncC0+Z2Jsb2NrX2R2bWE7CkBAIC0xODE4LDcg
KzE4NTMsNiBAQCBzdGF0aWMgdm9pZCBnZW1faW5pdF9kbWEoc3RydWN0IGdlbSAqZ3ApCiAJCSAg
ICAgICBncC0+cmVncyArIFJYRE1BX0JMQU5LKTsKIH0KIAotLyogTXVzdCBiZSBpbnZva2VkIHVu
ZGVyIGdwLT5sb2NrIGFuZCBncC0+dHhfbG9jay4gKi8KIHN0YXRpYyB1MzIgZ2VtX3NldHVwX211
bHRpY2FzdChzdHJ1Y3QgZ2VtICpncCkKIHsKIAl1MzIgcnhjZmcgPSAwOwpAQCAtMTg2MCw3ICsx
ODk0LDYgQEAgc3RhdGljIHUzMiBnZW1fc2V0dXBfbXVsdGljYXN0KHN0cnVjdCBnZQogCXJldHVy
biByeGNmZzsKIH0KIAotLyogTXVzdCBiZSBpbnZva2VkIHVuZGVyIGdwLT5sb2NrIGFuZCBncC0+
dHhfbG9jay4gKi8KIHN0YXRpYyB2b2lkIGdlbV9pbml0X21hYyhzdHJ1Y3QgZ2VtICpncCkKIHsK
IAl1bnNpZ25lZCBjaGFyICplID0gJmdwLT5kZXYtPmRldl9hZGRyWzBdOwpAQCAtMTk0Myw3ICsx
OTc2LDYgQEAgI2VuZGlmCiAJCXdyaXRlbCgwLCBncC0+cmVncyArIFdPTF9XQUtFQ1NSKTsKIH0K
IAotLyogTXVzdCBiZSBpbnZva2VkIHVuZGVyIGdwLT5sb2NrIGFuZCBncC0+dHhfbG9jay4gKi8K
IHN0YXRpYyB2b2lkIGdlbV9pbml0X3BhdXNlX3RocmVzaG9sZHMoc3RydWN0IGdlbSAqZ3ApCiB7
CiAgICAgICAgCXUzMiBjZmc7CkBAIC0yMDk2LDcgKzIxMjgsNiBAQCBzdGF0aWMgaW50IGdlbV9j
aGVja19pbnZhcmlhbnRzKHN0cnVjdCBnCiAJcmV0dXJuIDA7CiB9CiAKLS8qIE11c3QgYmUgaW52
b2tlZCB1bmRlciBncC0+bG9jayBhbmQgZ3AtPnR4X2xvY2suICovCiBzdGF0aWMgdm9pZCBnZW1f
cmVpbml0X2NoaXAoc3RydWN0IGdlbSAqZ3ApCiB7CiAJLyogUmVzZXQgdGhlIGNoaXAgKi8KQEAg
LTIxMTYsMTIgKzIxNDcsMTAgQEAgc3RhdGljIHZvaWQgZ2VtX3JlaW5pdF9jaGlwKHN0cnVjdCBn
ZW0gKgogCWdlbV9pbml0X21hYyhncCk7CiB9CiAKLQogLyogTXVzdCBiZSBpbnZva2VkIHdpdGgg
bm8gbG9jayBoZWxkLiAqLwogc3RhdGljIHZvaWQgZ2VtX3N0b3BfcGh5KHN0cnVjdCBnZW0gKmdw
LCBpbnQgd29sKQogewogCXUzMiBtaWZjZmc7Ci0JdW5zaWduZWQgbG9uZyBmbGFnczsKIAogCS8q
IExldCB0aGUgY2hpcCBzZXR0bGUgZG93biBhIGJpdCwgaXQgc2VlbXMgdGhhdCBoZWxwcwogCSAq
IGZvciBzbGVlcCBtb2RlIG9uIHNvbWUgbW9kZWxzCkBAIC0yMTY3LDEzICsyMTk2LDEzIEBAIHN0
YXRpYyB2b2lkIGdlbV9zdG9wX3BoeShzdHJ1Y3QgZ2VtICpncCwKIAl3cml0ZWwoMCwgZ3AtPnJl
Z3MgKyBSWERNQV9DRkcpOwogCiAJaWYgKCF3b2wpIHsKLQkJc3Bpbl9sb2NrX2lycXNhdmUoJmdw
LT5sb2NrLCBmbGFncyk7Ci0JCXNwaW5fbG9jaygmZ3AtPnR4X2xvY2spOworCQlnZW1fZnVsbF9s
b2NrKGdwLCAwKTsKKwogCQlnZW1fcmVzZXQoZ3ApOwogCQl3cml0ZWwoTUFDX1RYUlNUX0NNRCwg
Z3AtPnJlZ3MgKyBNQUNfVFhSU1QpOwogCQl3cml0ZWwoTUFDX1JYUlNUX0NNRCwgZ3AtPnJlZ3Mg
KyBNQUNfUlhSU1QpOwotCQlzcGluX3VubG9jaygmZ3AtPnR4X2xvY2spOwotCQlzcGluX3VubG9j
a19pcnFyZXN0b3JlKCZncC0+bG9jaywgZmxhZ3MpOworCisJCWdlbV9mdWxsX3VubG9jayhncCk7
CiAKIAkJLyogTm8gbmVlZCB0byB0YWtlIHRoZSBsb2NrIGhlcmUgKi8KIApAQCAtMjE5MiwxNCAr
MjIyMSwxMSBAQCBzdGF0aWMgdm9pZCBnZW1fc3RvcF9waHkoc3RydWN0IGdlbSAqZ3AsCiAJfQog
fQogCi0KIHN0YXRpYyBpbnQgZ2VtX2RvX3N0YXJ0KHN0cnVjdCBuZXRfZGV2aWNlICpkZXYpCiB7
CiAJc3RydWN0IGdlbSAqZ3AgPSBkZXYtPnByaXY7Ci0JdW5zaWduZWQgbG9uZyBmbGFnczsKIAot
CXNwaW5fbG9ja19pcnFzYXZlKCZncC0+bG9jaywgZmxhZ3MpOwotCXNwaW5fbG9jaygmZ3AtPnR4
X2xvY2spOworCWdlbV9mdWxsX2xvY2soZ3AsIDApOwogCiAJLyogRW5hYmxlIHRoZSBjZWxsICov
CiAJZ2VtX2dldF9jZWxsKGdwKTsKQEAgLTIyMTEsMjggKzIyMzcsMjYgQEAgc3RhdGljIGludCBn
ZW1fZG9fc3RhcnQoc3RydWN0IG5ldF9kZXZpYwogCiAJaWYgKGdwLT5sc3RhdGUgPT0gbGlua191
cCkgewogCQluZXRpZl9jYXJyaWVyX29uKGdwLT5kZXYpOworCQkvKiBnZW1fc2V0X2xpbmtfbW9k
ZXMgc3RhcnRzIERNQSBhbmQgZW5hYmxlZCBpbnRzICovCiAJCWdlbV9zZXRfbGlua19tb2Rlcyhn
cCk7CiAJfQogCi0JbmV0aWZfd2FrZV9xdWV1ZShncC0+ZGV2KTsKLQotCXNwaW5fdW5sb2NrKCZn
cC0+dHhfbG9jayk7Ci0Jc3Bpbl91bmxvY2tfaXJxcmVzdG9yZSgmZ3AtPmxvY2ssIGZsYWdzKTsK
KwlncC0+aXJxX3N5bmMgPSAwOworCWdlbV9mdWxsX3VubG9jayhncCk7CiAKIAlpZiAocmVxdWVz
dF9pcnEoZ3AtPnBkZXYtPmlycSwgZ2VtX2ludGVycnVwdCwKLQkJCQkgICBJUlFGX1NIQVJFRCwg
ZGV2LT5uYW1lLCAodm9pZCAqKWRldikpIHsKKwkJICAgICAgICBJUlFGX1NIQVJFRCwgZGV2LT5u
YW1lLCAodm9pZCAqKWRldikpIHsKKwogCQlwcmludGsoS0VSTl9FUlIgIiVzOiBmYWlsZWQgdG8g
cmVxdWVzdCBpcnEgIVxuIiwgZ3AtPmRldi0+bmFtZSk7CiAKLQkJc3Bpbl9sb2NrX2lycXNhdmUo
JmdwLT5sb2NrLCBmbGFncyk7Ci0JCXNwaW5fbG9jaygmZ3AtPnR4X2xvY2spOworCQlnZW1fZnVs
bF9sb2NrKGdwLCAwKTsKIAogCQlncC0+cnVubmluZyA9ICAwOwogCQlnZW1fcmVzZXQoZ3ApOwog
CQlnZW1fY2xlYW5fcmluZ3MoZ3ApOwogCQlnZW1fcHV0X2NlbGwoZ3ApOwogCi0JCXNwaW5fdW5s
b2NrKCZncC0+dHhfbG9jayk7Ci0JCXNwaW5fdW5sb2NrX2lycXJlc3RvcmUoJmdwLT5sb2NrLCBm
bGFncyk7CisJCWdlbV9mdWxsX3VubG9jayhncCk7CiAKIAkJcmV0dXJuIC1FQUdBSU47CiAJfQpA
QCAtMjI0MywyMiArMjI2NywxNCBAQCBzdGF0aWMgaW50IGdlbV9kb19zdGFydChzdHJ1Y3QgbmV0
X2RldmljCiBzdGF0aWMgdm9pZCBnZW1fZG9fc3RvcChzdHJ1Y3QgbmV0X2RldmljZSAqZGV2LCBp
bnQgd29sKQogewogCXN0cnVjdCBnZW0gKmdwID0gZGV2LT5wcml2OwotCXVuc2lnbmVkIGxvbmcg
ZmxhZ3M7Ci0KLQlzcGluX2xvY2tfaXJxc2F2ZSgmZ3AtPmxvY2ssIGZsYWdzKTsKLQlzcGluX2xv
Y2soJmdwLT50eF9sb2NrKTsKLQotCWdwLT5ydW5uaW5nID0gMDsKIAotCS8qIFN0b3AgbmV0aWYg
cXVldWUgKi8KLQluZXRpZl9zdG9wX3F1ZXVlKGRldik7Ci0KLQkvKiBNYWtlIHN1cmUgaW50cyBh
cmUgZGlzYWJsZWQgKi8KKwlnZW1fZnVsbF9sb2NrKGdwLCAxKTsKIAlnZW1fZGlzYWJsZV9pbnRz
KGdwKTsKKwkKKwlncC0+cnVubmluZyA9IDA7CiAKLQkvKiBXZSBjYW4gZHJvcCB0aGUgbG9jayBu
b3cgKi8KLQlzcGluX3VubG9jaygmZ3AtPnR4X2xvY2spOwotCXNwaW5fdW5sb2NrX2lycXJlc3Rv
cmUoJmdwLT5sb2NrLCBmbGFncyk7CisJLyogV2UgY2FuIGRyb3AgdGhlIGxvY2sgbm93IHRoYXQg
cnVubmluZyBpcyBzZXQgdG8gMCAqLworCWdlbV9mdWxsX3VubG9jayhncCk7CiAKIAkvKiBJZiB3
ZSBhcmUgZ29pbmcgdG8gc2xlZXAgd2l0aCBXT0wgKi8KIAlnZW1fc3RvcF9kbWEoZ3ApOwpAQCAt
MjI3NSw5ICsyMjkxLDkgQEAgc3RhdGljIHZvaWQgZ2VtX2RvX3N0b3Aoc3RydWN0IG5ldF9kZXZp
YwogCiAJLyogQ2VsbCBub3QgbmVlZGVkIG5laXRoZXIgaWYgbm8gV09MICovCiAJaWYgKCF3b2wp
IHsKLQkJc3Bpbl9sb2NrX2lycXNhdmUoJmdwLT5sb2NrLCBmbGFncyk7CisJCWdlbV9mdWxsX2xv
Y2soZ3AsIDApOwogCQlnZW1fcHV0X2NlbGwoZ3ApOwotCQlzcGluX3VubG9ja19pcnFyZXN0b3Jl
KCZncC0+bG9jaywgZmxhZ3MpOworCQlnZW1fZnVsbF91bmxvY2soZ3ApOwogCX0KIH0KIApAQCAt
MjI4NywzMSArMjMwMywyNiBAQCBzdGF0aWMgdm9pZCBnZW1fcmVzZXRfdGFzayh2b2lkICpkYXRh
KQogCiAJbXV0ZXhfbG9jaygmZ3AtPnBtX211dGV4KTsKIAotCW5ldGlmX3BvbGxfZGlzYWJsZShn
cC0+ZGV2KTsKLQotCXNwaW5fbG9ja19pcnEoJmdwLT5sb2NrKTsKLQlzcGluX2xvY2soJmdwLT50
eF9sb2NrKTsKLQogCWlmIChncC0+cnVubmluZyA9PSAwKQogCQlnb3RvIG5vdF9ydW5uaW5nOwog
Ci0JaWYgKGdwLT5ydW5uaW5nKSB7Ci0JCW5ldGlmX3N0b3BfcXVldWUoZ3AtPmRldik7CisJZ2Vt
X2Z1bGxfbG9jayhncCwgMSk7CisJZ2VtX2Rpc2FibGVfaW50cyhncCk7CiAKLQkJLyogUmVzZXQg
dGhlIGNoaXAgJiByaW5ncyAqLwotCQlnZW1fcmVpbml0X2NoaXAoZ3ApOwotCQlpZiAoZ3AtPmxz
dGF0ZSA9PSBsaW5rX3VwKQotCQkJZ2VtX3NldF9saW5rX21vZGVzKGdwKTsKLQkJbmV0aWZfd2Fr
ZV9xdWV1ZShncC0+ZGV2KTsKLQl9Ci0gbm90X3J1bm5pbmc6Ci0JZ3AtPnJlc2V0X3Rhc2tfcGVu
ZGluZyA9IDA7CisJZ2VtX25ldGlmX3N0b3AoZ3ApOworCisJLyogUmVzZXQgdGhlIGNoaXAgJiBy
aW5ncyAqLworCWdlbV9yZWluaXRfY2hpcChncCk7CisJaWYgKGdwLT5sc3RhdGUgPT0gbGlua191
cCkKKwkJZ2VtX3NldF9saW5rX21vZGVzKGdwKTsKIAotCXNwaW5fdW5sb2NrKCZncC0+dHhfbG9j
ayk7Ci0Jc3Bpbl91bmxvY2tfaXJxKCZncC0+bG9jayk7CisJZ2VtX25ldGlmX3N0YXJ0KGdwKTsK
IAotCW5ldGlmX3BvbGxfZW5hYmxlKGdwLT5kZXYpOworCWdlbV9lbmFibGVfaW50cyhncCk7CisJ
Z2VtX2Z1bGxfdW5sb2NrKGdwKTsKIAorbm90X3J1bm5pbmc6CisJZ3AtPnJlc2V0X3Rhc2tfcGVu
ZGluZyA9IDA7CiAJbXV0ZXhfdW5sb2NrKCZncC0+cG1fbXV0ZXgpOwogfQogCkBAIC0yMzI0LDgg
KzIzMzUsMTIgQEAgc3RhdGljIGludCBnZW1fb3BlbihzdHJ1Y3QgbmV0X2RldmljZSAqZAogCW11
dGV4X2xvY2soJmdwLT5wbV9tdXRleCk7CiAKIAkvKiBXZSBuZWVkIHRoZSBjZWxsIGVuYWJsZWQg
Ki8KLQlpZiAoIWdwLT5hc2xlZXApCisJaWYgKCFncC0+YXNsZWVwKSB7CiAJCXJjID0gZ2VtX2Rv
X3N0YXJ0KGRldik7CisJCWlmIChyYyA9PSAwKQorCQkJbmV0aWZfc3RhcnRfcXVldWUoZGV2KTsK
Kwl9CisKIAlncC0+b3BlbmVkID0gKHJjID09IDApOwogCiAJbXV0ZXhfdW5sb2NrKCZncC0+cG1f
bXV0ZXgpOwpAQCAtMjMzNywxNSArMjM1MiwxNCBAQCBzdGF0aWMgaW50IGdlbV9jbG9zZShzdHJ1
Y3QgbmV0X2RldmljZSAqCiB7CiAJc3RydWN0IGdlbSAqZ3AgPSBkZXYtPnByaXY7CiAKLQkvKiBO
b3RlOiB3ZSBkb24ndCBuZWVkIHRvIGNhbGwgbmV0aWZfcG9sbF9kaXNhYmxlKCkgaGVyZSBiZWNh
dXNlCi0JICogb3VyIGNhbGxlciAoZGV2X2Nsb3NlKSBhbHJlYWR5IGRpZCBpdCBmb3IgdXMKLQkg
Ki8KLQogCW11dGV4X2xvY2soJmdwLT5wbV9tdXRleCk7CiAKIAlncC0+b3BlbmVkID0gMDsKLQlp
ZiAoIWdwLT5hc2xlZXApCisJaWYgKCFncC0+YXNsZWVwKSB7CisJCS8qIFVwcGVyIGxheWVyIHRv
b2sgY2FyZSBvZiBkaXNhYmxpbmcgcG9sbGluZyAqLworCQluZXRpZl9zdG9wX3F1ZXVlKGRldik7
CiAJCWdlbV9kb19zdG9wKGRldiwgMCk7CisJfQogCiAJbXV0ZXhfdW5sb2NrKCZncC0+cG1fbXV0
ZXgpOwogCkBAIC0yMzU3LDIyICsyMzcxLDE3IEBAIHN0YXRpYyBpbnQgZ2VtX3N1c3BlbmQoc3Ry
dWN0IHBjaV9kZXYgKnAKIHsKIAlzdHJ1Y3QgbmV0X2RldmljZSAqZGV2ID0gcGNpX2dldF9kcnZk
YXRhKHBkZXYpOwogCXN0cnVjdCBnZW0gKmdwID0gZGV2LT5wcml2OwotCXVuc2lnbmVkIGxvbmcg
ZmxhZ3M7CiAKIAltdXRleF9sb2NrKCZncC0+cG1fbXV0ZXgpOwogCi0JbmV0aWZfcG9sbF9kaXNh
YmxlKGRldik7Ci0KIAlwcmludGsoS0VSTl9JTkZPICIlczogc3VzcGVuZGluZywgV2FrZU9uTGFu
ICVzXG4iLAogCSAgICAgICBkZXYtPm5hbWUsCiAJICAgICAgIChncC0+d2FrZV9vbl9sYW4gJiYg
Z3AtPm9wZW5lZCkgPyAiZW5hYmxlZCIgOiAiZGlzYWJsZWQiKTsKIAogCS8qIEtlZXAgdGhlIGNl
bGwgZW5hYmxlZCBkdXJpbmcgdGhlIGVudGlyZSBvcGVyYXRpb24gKi8KLQlzcGluX2xvY2tfaXJx
c2F2ZSgmZ3AtPmxvY2ssIGZsYWdzKTsKLQlzcGluX2xvY2soJmdwLT50eF9sb2NrKTsKKwlnZW1f
ZnVsbF9sb2NrKGdwLCAwKTsKIAlnZW1fZ2V0X2NlbGwoZ3ApOwotCXNwaW5fdW5sb2NrKCZncC0+
dHhfbG9jayk7Ci0Jc3Bpbl91bmxvY2tfaXJxcmVzdG9yZSgmZ3AtPmxvY2ssIGZsYWdzKTsKKwln
ZW1fZnVsbF91bmxvY2soZ3ApOwogCiAJLyogSWYgdGhlIGRyaXZlciBpcyBvcGVuZWQsIHdlIHN0
b3AgdGhlIE1BQyAqLwogCWlmIChncC0+b3BlbmVkKSB7CkBAIC0yMzgxLDYgKzIzOTAsNyBAQCBz
dGF0aWMgaW50IGdlbV9zdXNwZW5kKHN0cnVjdCBwY2lfZGV2ICpwCiAKIAkJLyogU3dpdGNoIG9m
ZiBNQUMsIHJlbWVtYmVyIFdPTCBzZXR0aW5nICovCiAJCWdwLT5hc2xlZXBfd29sID0gZ3AtPndh
a2Vfb25fbGFuOworCQlnZW1fbmV0aWZfc3RvcChncCk7CiAJCWdlbV9kb19zdG9wKGRldiwgZ3At
PmFzbGVlcF93b2wpOwogCX0gZWxzZQogCQlncC0+YXNsZWVwX3dvbCA9IDA7CkBAIC0yMzk5LDgg
KzI0MDksNyBAQCBzdGF0aWMgaW50IGdlbV9zdXNwZW5kKHN0cnVjdCBwY2lfZGV2ICpwCiAJbXV0
ZXhfdW5sb2NrKCZncC0+cG1fbXV0ZXgpOwogCiAJLyogV2FpdCBmb3IgYSBwZW5kaW5nIHJlc2V0
IHRhc2sgdG8gY29tcGxldGUgKi8KLQl3aGlsZSAoZ3AtPnJlc2V0X3Rhc2tfcGVuZGluZykKLQkJ
eWllbGQoKTsKKwlnZW1fd2FpdF9yZXNldF90YXNrKGdwKTsKIAlmbHVzaF9zY2hlZHVsZWRfd29y
aygpOwogCiAJLyogU2h1dCB0aGUgUEhZIGRvd24gZXZlbnR1YWxseSBhbmQgc2V0dXAgV09MICov
CkBAIC0yNDIxLDcgKzI0MzAsNiBAQCBzdGF0aWMgaW50IGdlbV9yZXN1bWUoc3RydWN0IHBjaV9k
ZXYgKnBkCiB7CiAJc3RydWN0IG5ldF9kZXZpY2UgKmRldiA9IHBjaV9nZXRfZHJ2ZGF0YShwZGV2
KTsKIAlzdHJ1Y3QgZ2VtICpncCA9IGRldi0+cHJpdjsKLQl1bnNpZ25lZCBsb25nIGZsYWdzOwog
CiAJcHJpbnRrKEtFUk5fSU5GTyAiJXM6IHJlc3VtaW5nXG4iLCBkZXYtPm5hbWUpOwogCkBAIC0y
NDY1LDExICsyNDczLDkgQEAgc3RhdGljIGludCBnZW1fcmVzdW1lKHN0cnVjdCBwY2lfZGV2ICpw
ZAogCiAJCS8qIFJlLWF0dGFjaCBuZXQgZGV2aWNlICovCiAJCW5ldGlmX2RldmljZV9hdHRhY2go
ZGV2KTsKLQogCX0KIAotCXNwaW5fbG9ja19pcnFzYXZlKCZncC0+bG9jaywgZmxhZ3MpOwotCXNw
aW5fbG9jaygmZ3AtPnR4X2xvY2spOworCWdlbV9mdWxsX2xvY2soZ3AsIDApOwogCiAJLyogSWYg
d2UgaGFkIFdPTCBlbmFibGVkLCB0aGUgY2VsbCBjbG9jayB3YXMgbmV2ZXIgdHVybmVkIG9mZiBk
dXJpbmcKIAkgKiBzbGVlcCwgc28gd2UgZW5kIHVwIGJlZWluZyB1bmJhbGFuY2VkLiBGaXggdGhh
dCBoZXJlCkBAIC0yNDgyLDEwICsyNDg4LDkgQEAgc3RhdGljIGludCBnZW1fcmVzdW1lKHN0cnVj
dCBwY2lfZGV2ICpwZAogCSAqLwogCWdlbV9wdXRfY2VsbChncCk7CiAKLQlzcGluX3VubG9jaygm
Z3AtPnR4X2xvY2spOwotCXNwaW5fdW5sb2NrX2lycXJlc3RvcmUoJmdwLT5sb2NrLCBmbGFncyk7
CisJZ2VtX2Z1bGxfdW5sb2NrKGdwKTsKIAotCW5ldGlmX3BvbGxfZW5hYmxlKGRldik7CisJZ2Vt
X25ldGlmX3N0YXJ0KGdwKTsKIAogCW11dGV4X3VubG9jaygmZ3AtPnBtX211dGV4KTsKIApAQCAt
MjQ5OCw4ICsyNTAzLDggQEAgc3RhdGljIHN0cnVjdCBuZXRfZGV2aWNlX3N0YXRzICpnZW1fZ2V0
XwogCXN0cnVjdCBnZW0gKmdwID0gZGV2LT5wcml2OwogCXN0cnVjdCBuZXRfZGV2aWNlX3N0YXRz
ICpzdGF0cyA9ICZncC0+bmV0X3N0YXRzOwogCi0Jc3Bpbl9sb2NrX2lycSgmZ3AtPmxvY2spOwot
CXNwaW5fbG9jaygmZ3AtPnR4X2xvY2spOworCWdlbV9uZXRpZl9zdG9wKGdwKTsKKwlnZW1fZnVs
bF9sb2NrKGdwLCAwKTsKIAogCS8qIEkgaGF2ZSBzZWVuIHRoaXMgYmVpbmcgY2FsbGVkIHdoaWxl
IHRoZSBQTSB3YXMgaW4gcHJvZ3Jlc3MsCiAJICogc28gd2Ugc2hpZWxkIGFnYWluc3QgdGhpcwpA
QCAtMjUyMiwyNyArMjUyNywyNiBAQCBzdGF0aWMgc3RydWN0IG5ldF9kZXZpY2Vfc3RhdHMgKmdl
bV9nZXRfCiAJCXdyaXRlbCgwLCBncC0+cmVncyArIE1BQ19MQ09MTCk7CiAJfQogCi0Jc3Bpbl91
bmxvY2soJmdwLT50eF9sb2NrKTsKLQlzcGluX3VubG9ja19pcnEoJmdwLT5sb2NrKTsKKwlnZW1f
ZnVsbF91bmxvY2soZ3ApOworCWdlbV9uZXRpZl9zdGFydChncCk7CiAKIAlyZXR1cm4gJmdwLT5u
ZXRfc3RhdHM7CiB9CiAKKy8qIGdlbV9zZXRfbXVsdGljYXN0IGlzIGNhbGxlZCB3aXRoIG5ldGlm
X3R4X2xvY2sgaGVsZC4gVGh1cywgaXQKKyAqIGNhbm5vdCBzbGVlcC4KKyAqLwogc3RhdGljIHZv
aWQgZ2VtX3NldF9tdWx0aWNhc3Qoc3RydWN0IG5ldF9kZXZpY2UgKmRldikKIHsKIAlzdHJ1Y3Qg
Z2VtICpncCA9IGRldi0+cHJpdjsKIAl1MzIgcnhjZmcsIHJ4Y2ZnX25ldzsKIAlpbnQgbGltaXQg
PSAxMDAwMDsKIAotCi0Jc3Bpbl9sb2NrX2lycSgmZ3AtPmxvY2spOwotCXNwaW5fbG9jaygmZ3At
PnR4X2xvY2spOworCWdlbV9mdWxsX2xvY2soZ3AsIDApOwogCiAJaWYgKCFncC0+cnVubmluZykK
IAkJZ290byBiYWlsOwogCi0JbmV0aWZfc3RvcF9xdWV1ZShkZXYpOwotCiAJcnhjZmcgPSByZWFk
bChncC0+cmVncyArIE1BQ19SWENGRyk7CiAJcnhjZmdfbmV3ID0gZ2VtX3NldHVwX211bHRpY2Fz
dChncCk7CiAjaWZkZWYgU1RSSVBfRkNTCkBAIC0yNTYyLDExICsyNTY2LDggQEAgI2VuZGlmCiAK
IAl3cml0ZWwocnhjZmcsIGdwLT5yZWdzICsgTUFDX1JYQ0ZHKTsKIAotCW5ldGlmX3dha2VfcXVl
dWUoZGV2KTsKLQogIGJhaWw6Ci0Jc3Bpbl91bmxvY2soJmdwLT50eF9sb2NrKTsKLQlzcGluX3Vu
bG9ja19pcnEoJmdwLT5sb2NrKTsKKwlnZW1fZnVsbF91bmxvY2soZ3ApOwogfQogCiAvKiBKdW1i
by1ncmFtcyBkb24ndCBzZWVtIHRvIHdvcmsgOi0oICovCkBAIC0yNTkzLDE2ICsyNTk0LDIyIEBA
IHN0YXRpYyBpbnQgZ2VtX2NoYW5nZV9tdHUoc3RydWN0IG5ldF9kZXYKIAl9CiAKIAltdXRleF9s
b2NrKCZncC0+cG1fbXV0ZXgpOwotCXNwaW5fbG9ja19pcnEoJmdwLT5sb2NrKTsKLQlzcGluX2xv
Y2soJmdwLT50eF9sb2NrKTsKKworCWdlbV9uZXRpZl9zdG9wKGdwKTsKKwlnZW1fZnVsbF9sb2Nr
KGdwLCAxKTsKKwlnZW1fZGlzYWJsZV9pbnRzKGdwKTsKKwkKIAlkZXYtPm10dSA9IG5ld19tdHU7
CiAJaWYgKGdwLT5ydW5uaW5nKSB7CiAJCWdlbV9yZWluaXRfY2hpcChncCk7CiAJCWlmIChncC0+
bHN0YXRlID09IGxpbmtfdXApCiAJCQlnZW1fc2V0X2xpbmtfbW9kZXMoZ3ApOwogCX0KLQlzcGlu
X3VubG9jaygmZ3AtPnR4X2xvY2spOwotCXNwaW5fdW5sb2NrX2lycSgmZ3AtPmxvY2spOworCisJ
Z2VtX25ldGlmX3N0YXJ0KGdwKTsKKwlnZW1fZW5hYmxlX2ludHMoZ3ApOworCWdlbV9mdWxsX3Vu
bG9jayhncCk7CisKIAltdXRleF91bmxvY2soJmdwLT5wbV9tdXRleCk7CiAKIAlyZXR1cm4gMDsK
QEAgLTI2MzUsNyArMjY0Miw3IEBAIHN0YXRpYyBpbnQgZ2VtX2dldF9zZXR0aW5ncyhzdHJ1Y3Qg
bmV0X2QKIAkJY21kLT5waHlfYWRkcmVzcyA9IDA7IC8qIFhYWCBmaXhlZCBQSFlBRCAqLwogCiAJ
CS8qIFJldHVybiBjdXJyZW50IFBIWSBzZXR0aW5ncyAqLwotCQlzcGluX2xvY2tfaXJxKCZncC0+
bG9jayk7CisJCWdlbV9mdWxsX2xvY2soZ3AsIDApOwogCQljbWQtPmF1dG9uZWcgPSBncC0+d2Fu
dF9hdXRvbmVnOwogCQljbWQtPnNwZWVkID0gZ3AtPnBoeV9taWkuc3BlZWQ7CiAJCWNtZC0+ZHVw
bGV4ID0gZ3AtPnBoeV9taWkuZHVwbGV4OwpAQCAtMjY0Nyw3ICsyNjU0LDcgQEAgc3RhdGljIGlu
dCBnZW1fZ2V0X3NldHRpbmdzKHN0cnVjdCBuZXRfZAogCQkgKi8KIAkJaWYgKGNtZC0+YWR2ZXJ0
aXNpbmcgPT0gMCkKIAkJCWNtZC0+YWR2ZXJ0aXNpbmcgPSBjbWQtPnN1cHBvcnRlZDsKLQkJc3Bp
bl91bmxvY2tfaXJxKCZncC0+bG9jayk7CisJCWdlbV9mdWxsX3VubG9jayhncCk7CiAJfSBlbHNl
IHsgLy8gWFhYIFBDUyA/CiAJCWNtZC0+c3VwcG9ydGVkID0KIAkJCShTVVBQT1JURURfMTBiYXNl
VF9IYWxmIHwgU1VQUE9SVEVEXzEwYmFzZVRfRnVsbCB8CkBAIC0yNjg1LDExICsyNjkyLDExIEBA
IHN0YXRpYyBpbnQgZ2VtX3NldF9zZXR0aW5ncyhzdHJ1Y3QgbmV0X2QKIAkJcmV0dXJuIC1FSU5W
QUw7CiAKIAkvKiBBcHBseSBzZXR0aW5ncyBhbmQgcmVzdGFydCBsaW5rIHByb2Nlc3MuICovCi0J
c3Bpbl9sb2NrX2lycSgmZ3AtPmxvY2spOworCWdlbV9mdWxsX2xvY2soZ3AsIDApOwogCWdlbV9n
ZXRfY2VsbChncCk7CiAJZ2VtX2JlZ2luX2F1dG9fbmVnb3RpYXRpb24oZ3AsIGNtZCk7CiAJZ2Vt
X3B1dF9jZWxsKGdwKTsKLQlzcGluX3VubG9ja19pcnEoJmdwLT5sb2NrKTsKKwlnZW1fZnVsbF91
bmxvY2soZ3ApOwogCiAJcmV0dXJuIDA7CiB9CkBAIC0yNzAyLDExICsyNzA5LDExIEBAIHN0YXRp
YyBpbnQgZ2VtX253YXlfcmVzZXQoc3RydWN0IG5ldF9kZXYKIAkJcmV0dXJuIC1FSU5WQUw7CiAK
IAkvKiBSZXN0YXJ0IGxpbmsgcHJvY2Vzcy4gKi8KLQlzcGluX2xvY2tfaXJxKCZncC0+bG9jayk7
CisJZ2VtX2Z1bGxfbG9jayhncCwgMCk7CiAJZ2VtX2dldF9jZWxsKGdwKTsKIAlnZW1fYmVnaW5f
YXV0b19uZWdvdGlhdGlvbihncCwgTlVMTCk7CiAJZ2VtX3B1dF9jZWxsKGdwKTsKLQlzcGluX3Vu
bG9ja19pcnEoJmdwLT5sb2NrKTsKKwlnZW1fZnVsbF91bmxvY2soZ3ApOwogCiAJcmV0dXJuIDA7
CiB9CkBAIC0yNzcwLDE2ICsyNzc3LDE1IEBAIHN0YXRpYyBpbnQgZ2VtX2lvY3RsKHN0cnVjdCBu
ZXRfZGV2aWNlICoKIAlzdHJ1Y3QgZ2VtICpncCA9IGRldi0+cHJpdjsKIAlzdHJ1Y3QgbWlpX2lv
Y3RsX2RhdGEgKmRhdGEgPSBpZl9taWkoaWZyKTsKIAlpbnQgcmMgPSAtRU9QTk9UU1VQUDsKLQl1
bnNpZ25lZCBsb25nIGZsYWdzOwogCiAJLyogSG9sZCB0aGUgUE0gbXV0ZXggd2hpbGUgZG9pbmcg
aW9jdGwncyBvciB3ZSBtYXkgY29sbGlkZQogCSAqIHdpdGggcG93ZXIgbWFuYWdlbWVudC4KIAkg
Ki8KIAltdXRleF9sb2NrKCZncC0+cG1fbXV0ZXgpOwogCi0Jc3Bpbl9sb2NrX2lycXNhdmUoJmdw
LT5sb2NrLCBmbGFncyk7CisJZ2VtX2Z1bGxfbG9jayhncCwgMCk7CiAJZ2VtX2dldF9jZWxsKGdw
KTsKLQlzcGluX3VubG9ja19pcnFyZXN0b3JlKCZncC0+bG9jaywgZmxhZ3MpOworCWdlbV9mdWxs
X3VubG9jayhncCk7CiAKIAlzd2l0Y2ggKGNtZCkgewogCWNhc2UgU0lPQ0dNSUlQSFk6CQkvKiBH
ZXQgYWRkcmVzcyBvZiBNSUkgUEhZIGluIHVzZS4gKi8KQEAgLTI4MDksOSArMjgxNSw5IEBAIHN0
YXRpYyBpbnQgZ2VtX2lvY3RsKHN0cnVjdCBuZXRfZGV2aWNlICoKIAkJYnJlYWs7CiAJfTsKIAot
CXNwaW5fbG9ja19pcnFzYXZlKCZncC0+bG9jaywgZmxhZ3MpOworCWdlbV9mdWxsX2xvY2soZ3As
IDApOwogCWdlbV9wdXRfY2VsbChncCk7Ci0Jc3Bpbl91bmxvY2tfaXJxcmVzdG9yZSgmZ3AtPmxv
Y2ssIGZsYWdzKTsKKwlnZW1fZnVsbF91bmxvY2soZ3ApOwogCiAJbXV0ZXhfdW5sb2NrKCZncC0+
cG1fbXV0ZXgpOwogCkBAIC0yOTE4LDYgKzI5MjQsNyBAQCBzdGF0aWMgdm9pZCBnZW1fcmVtb3Zl
X29uZShzdHJ1Y3QgcGNpX2RlCiAJaWYgKGRldikgewogCQlzdHJ1Y3QgZ2VtICpncCA9IGRldi0+
cHJpdjsKIAorCQkvKiB1bnJlZ2lzdGVyX25ldGRldiB3aWxsIGNsb3NlIHRoZSBkZXZpY2UgaWYg
aXQncyBvcGVuICovCiAJCXVucmVnaXN0ZXJfbmV0ZGV2KGRldik7CiAKIAkJLyogU3RvcCB0aGUg
bGluayB0aW1lciAqLwpAQCAtMjkyNyw4ICsyOTM0LDcgQEAgc3RhdGljIHZvaWQgZ2VtX3JlbW92
ZV9vbmUoc3RydWN0IHBjaV9kZQogCQlnZW1fZ2V0X2NlbGwoZ3ApOwogCiAJCS8qIFdhaXQgZm9y
IGEgcGVuZGluZyByZXNldCB0YXNrIHRvIGNvbXBsZXRlICovCi0JCXdoaWxlIChncC0+cmVzZXRf
dGFza19wZW5kaW5nKQotCQkJeWllbGQoKTsKKwkJZ2VtX3dhaXRfcmVzZXRfdGFzayhncCk7CiAJ
CWZsdXNoX3NjaGVkdWxlZF93b3JrKCk7CiAKIAkJLyogU2h1dCB0aGUgUEhZIGRvd24gKi8KQEAg
LTMwMzUsOCArMzA0MSw4IEBAIHN0YXRpYyBpbnQgX19kZXZpbml0IGdlbV9pbml0X29uZShzdHJ1
Y3QKIAogCWdwLT5tc2dfZW5hYmxlID0gREVGQVVMVF9NU0c7CiAKKwlncC0+aXJxX3N5bmMgPSAw
OwogCXNwaW5fbG9ja19pbml0KCZncC0+bG9jayk7Ci0Jc3Bpbl9sb2NrX2luaXQoJmdwLT50eF9s
b2NrKTsKIAltdXRleF9pbml0KCZncC0+cG1fbXV0ZXgpOwogCiAJaW5pdF90aW1lcigmZ3AtPmxp
bmtfdGltZXIpOwpAQCAtMzEzMiw5ICszMTM4LDcgQEAgI2VuZGlmCiAJICovCiAJZ2VtX2luaXRf
cGh5KGdwKTsKIAotCXNwaW5fbG9ja19pcnEoJmdwLT5sb2NrKTsKIAlnZW1fcHV0X2NlbGwoZ3Ap
OwotCXNwaW5fdW5sb2NrX2lycSgmZ3AtPmxvY2spOwogCiAJLyogUmVnaXN0ZXIgd2l0aCBrZXJu
ZWwgKi8KIAlpZiAocmVnaXN0ZXJfbmV0ZGV2KGRldikpIHsKQEAgLTMxNTYsOCArMzE2MCw3IEBA
ICNlbmRpZgogCQlwcmludGsoS0VSTl9JTkZPICIlczogRm91bmQgJXMgUEhZXG4iLCBkZXYtPm5h
bWUsCiAJCQlncC0+cGh5X21paS5kZWYgPyBncC0+cGh5X21paS5kZWYtPm5hbWUgOiAibm8iKTsK
IAotCS8qIEdFTSBjYW4gZG8gaXQgYWxsLi4uICovCi0JZGV2LT5mZWF0dXJlcyB8PSBORVRJRl9G
X1NHIHwgTkVUSUZfRl9IV19DU1VNIHwgTkVUSUZfRl9MTFRYOworCWRldi0+ZmVhdHVyZXMgfD0g
TkVUSUZfRl9TRyB8IE5FVElGX0ZfSFdfQ1NVTTsKIAlpZiAocGNpX3VzaW5nX2RhYykKIAkJZGV2
LT5mZWF0dXJlcyB8PSBORVRJRl9GX0hJR0hETUE7CiAKQEAgLTMxNzcsNyArMzE4MCw2IEBAIGVy
cl9vdXRfZnJlZV9uZXRkZXY6CiBlcnJfZGlzYWJsZV9kZXZpY2U6CiAJcGNpX2Rpc2FibGVfZGV2
aWNlKHBkZXYpOwogCXJldHVybiBlcnI7Ci0KIH0KIAogCmRpZmYgLS1naXQgYS9kcml2ZXJzL25l
dC9zdW5nZW0uaCBiL2RyaXZlcnMvbmV0L3N1bmdlbS5oCmluZGV4IGE3MDA2N2MuLjU4Njk4MTgg
MTAwNjQ0Ci0tLSBhL2RyaXZlcnMvbmV0L3N1bmdlbS5oCisrKyBiL2RyaXZlcnMvbmV0L3N1bmdl
bS5oCkBAIC05MjksMTEgKzkyOSw2IEBAICNlbmRpZgogI2RlZmluZSBORVhUX1RYKE4pCSgoKE4p
ICsgMSkgJiAoVFhfUklOR19TSVpFIC0gMSkpCiAjZGVmaW5lIE5FWFRfUlgoTikJKCgoTikgKyAx
KSAmIChSWF9SSU5HX1NJWkUgLSAxKSkKIAotI2RlZmluZSBUWF9CVUZGU19BVkFJTChHUCkJCQkJ
CVwKLQkoKChHUCktPnR4X29sZCA8PSAoR1ApLT50eF9uZXcpID8JCQlcCi0JICAoR1ApLT50eF9v
bGQgKyAoVFhfUklOR19TSVpFIC0gMSkgLSAoR1ApLT50eF9uZXcgOglcCi0JICAoR1ApLT50eF9v
bGQgLSAoR1ApLT50eF9uZXcgLSAxKQotCiAjZGVmaW5lIFJYX09GRlNFVCAgICAgICAgICAyCiAj
ZGVmaW5lIFJYX0JVRl9BTExPQ19TSVpFKGdwKQkoKGdwKS0+cnhfYnVmX3N6ICsgMjggKyBSWF9P
RkZTRVQgKyA2NCkKIApAQCAtOTczLDggKzk2OCw4IEBAIGVudW0gbGlua19zdGF0ZSB7CiB9Owog
CiBzdHJ1Y3QgZ2VtIHsKKwlpbnQJCQlpcnFfc3luYzsKIAlzcGlubG9ja190CQlsb2NrOwotCXNw
aW5sb2NrX3QJCXR4X2xvY2s7CiAJdm9pZCBfX2lvbWVtCQkqcmVnczsKIAlpbnQJCQlyeF9uZXcs
IHJ4X29sZDsKIAlpbnQJCQl0eF9uZXcsIHR4X29sZDsK
------=_Part_39968_26552275.1164839825378--
