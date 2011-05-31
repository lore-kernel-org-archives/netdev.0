From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [RFC/PATCH] sungem: Spring cleaning and GRO support
Date: Tue, 31 May 2011 17:59:05 +1000
Message-ID: <1306828745.7481.660.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"R. Herbst" <ruediger.herbst@googlemail.com>,
	Brian Hamilton <bhamilton04@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:35737 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755508Ab1EaH7V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 May 2011 03:59:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David !

For RFC only at this stage, see blow why.

This patch simplifies the logic and locking in sungem significantly:

 - LLTX is gone, private tx lock is gone
 - We don't poll the PHY while the interface is down
 - The above allowed me to get rid of a pile of state flags
   using the proper interface state provided by the networking
   stack when needed
 - Allocate the bulk of RX skbs at init time using GFP_KERNEL
 - Fix a bug where the dev->features were set after register_netdev()
 - Added GRO while at it

Now the results .... on a dual G5 machine with a 1000Mb link, no
measurable netperf difference on Rx and a 3% loss on Tx.

So taking the lock is the Tx path hurts... now the question is,
do we just ditch the patch and stick with LLTX or do we say too
bad, locks suck on power, code being simpler is still worth it
and we merge it (+/- more review & testing of course) ?

I've done some suspend/resume tests on a couple of powerbook,
tortured the link a bit and it seems to be solid.

Oh and David, I've bumped the version number (though it's more
or less pointless imho) and ditched the release date which I
really don't see the point of... let me know if you object.

Opinions ?

Cheers,
Ben.

Not-Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/sungem.c |  684 +++++++++++++++++++++++---------------------------
 drivers/net/sungem.h |   20 --
 2 files changed, 316 insertions(+), 388 deletions(-)

diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index ab59300..33cac54 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -10,25 +10,6 @@
  * NAPI and NETPOLL support
  * (C) 2004 by Eric Lemoine (eric.lemoine@gmail.com)
  *
- * TODO:
- *  - Now that the driver was significantly simplified, I need to rework
- *    the locking. I'm sure we don't need _2_ spinlocks, and we probably
- *    can avoid taking most of them for so long period of time (and schedule
- *    instead). The main issues at this point are caused by the netdev layer
- *    though:
- *
- *    gem_change_mtu() and gem_set_multicast() are called with a read_lock()
- *    help by net/core/dev.c, thus they can't schedule. That means they can't
- *    call napi_disable() neither, thus force gem_poll() to keep a spinlock
- *    where it could have been dropped. change_mtu especially would love also to
- *    be able to msleep instead of horrid locked delays when resetting the HW,
- *    but that read_lock() makes it impossible, unless I defer it's action to
- *    the reset task, which means it'll be asynchronous (won't take effect until
- *    the system schedules a bit).
- *
- *    Also, it would probably be possible to also remove most of the long-life
- *    locking in open/resume code path (gem_reinit_chip) by beeing more careful
- *    about when we can start taking interrupts or get xmit() called...
  */
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
@@ -95,12 +76,11 @@
 			 SUPPORTED_Pause | SUPPORTED_Autoneg)
 
 #define DRV_NAME	"sungem"
-#define DRV_VERSION	"0.98"
-#define DRV_RELDATE	"8/24/03"
-#define DRV_AUTHOR	"David S. Miller (davem@redhat.com)"
+#define DRV_VERSION	"1.0"
+#define DRV_AUTHOR	"David S. Miller <davem@redhat.com>"
 
 static char version[] __devinitdata =
-        DRV_NAME ".c:v" DRV_VERSION " " DRV_RELDATE " " DRV_AUTHOR "\n";
+        DRV_NAME ".c:v" DRV_VERSION " " DRV_AUTHOR "\n";
 
 MODULE_AUTHOR(DRV_AUTHOR);
 MODULE_DESCRIPTION("Sun GEM Gbit ethernet driver");
@@ -218,6 +198,7 @@ static inline void gem_disable_ints(struct gem *gp)
 {
 	/* Disable all interrupts, including TXDONE */
 	writel(GREG_STAT_NAPI | GREG_STAT_TXDONE, gp->regs + GREG_IMASK);
+	(void)readl(gp->regs + GREG_IMASK); /* write posting */
 }
 
 static void gem_get_cell(struct gem *gp)
@@ -247,6 +228,29 @@ static void gem_put_cell(struct gem *gp)
 #endif /* CONFIG_PPC_PMAC */
 }
 
+static inline void gem_netif_stop(struct gem *gp)
+{
+	gp->dev->trans_start = jiffies;	/* prevent tx timeout */
+	napi_disable(&gp->napi);
+	netif_tx_disable(gp->dev);
+}
+
+static inline void gem_netif_start(struct gem *gp)
+{
+	/* NOTE: unconditional netif_wake_queue is only
+	 * appropriate so long as all callers are assured to
+	 * have free tx slots.
+	 */
+	netif_wake_queue(gp->dev);
+	napi_enable(&gp->napi);
+}
+
+static void gem_schedule_reset(struct gem *gp)
+{
+	gp->reset_task_pending = 1;
+	schedule_work(&gp->reset_task);
+}
+
 static void gem_handle_mif_event(struct gem *gp, u32 reg_val, u32 changed_bits)
 {
 	if (netif_msg_intr(gp))
@@ -640,8 +644,7 @@ static int gem_abnormal_irq(struct net_device *dev, struct gem *gp, u32 gem_stat
 	return 0;
 
 do_reset:
-	gp->reset_task_pending = 1;
-	schedule_work(&gp->reset_task);
+	gem_schedule_reset(gp);
 
 	return 1;
 }
@@ -650,10 +653,6 @@ static __inline__ void gem_tx(struct net_device *dev, struct gem *gp, u32 gem_st
 {
 	int entry, limit;
 
-	if (netif_msg_intr(gp))
-		printk(KERN_DEBUG "%s: tx interrupt, gem_status: 0x%x\n",
-			gp->dev->name, gem_status);
-
 	entry = gp->tx_old;
 	limit = ((gem_status & GREG_STAT_TXNR) >> GREG_STAT_TXNR_SHIFT);
 	while (entry != limit) {
@@ -697,13 +696,25 @@ static __inline__ void gem_tx(struct net_device *dev, struct gem *gp, u32 gem_st
 		}
 
 		dev->stats.tx_packets++;
-		dev_kfree_skb_irq(skb);
+		dev_kfree_skb(skb);
 	}
 	gp->tx_old = entry;
 
-	if (netif_queue_stopped(dev) &&
-	    TX_BUFFS_AVAIL(gp) > (MAX_SKB_FRAGS + 1))
-		netif_wake_queue(dev);
+	/* Need to make the tx_old update visible to gem_start_xmit()
+	 * before checking for netif_queue_stopped().  Without the
+	 * memory barrier, there is a small possibility that gem_start_xmit()
+	 * will miss it and cause the queue to be stopped forever.
+	 */
+	smp_mb();
+
+	if (unlikely(netif_queue_stopped(dev) &&
+		     TX_BUFFS_AVAIL(gp) > (MAX_SKB_FRAGS + 1))) {
+		netif_tx_lock(dev);
+		if (netif_queue_stopped(dev) &&
+		    TX_BUFFS_AVAIL(gp) > (MAX_SKB_FRAGS + 1))
+			netif_wake_queue(dev);
+		netif_tx_unlock(dev);
+	}
 }
 
 static __inline__ void gem_post_rxds(struct gem *gp, int limit)
@@ -736,6 +747,22 @@ static __inline__ void gem_post_rxds(struct gem *gp, int limit)
 	}
 }
 
+#define ALIGNED_RX_SKB_ADDR(addr) \
+        ((((unsigned long)(addr) + (64UL - 1UL)) & ~(64UL - 1UL)) - (unsigned long)(addr))
+static __inline__ struct sk_buff *gem_alloc_skb(struct net_device *dev, int size,
+						gfp_t gfp_flags)
+{
+	struct sk_buff *skb = alloc_skb(size + 64, gfp_flags);
+
+	if (likely(skb)) {
+		int offset = (int) ALIGNED_RX_SKB_ADDR(skb->data);
+		if (offset)
+			skb_reserve(skb, offset);
+		skb->dev = dev;
+	}
+	return skb;
+}
+
 static int gem_rx(struct gem *gp, int work_to_do)
 {
 	struct net_device *dev = gp->dev;
@@ -799,7 +826,7 @@ static int gem_rx(struct gem *gp, int work_to_do)
 		if (len > RX_COPY_THRESHOLD) {
 			struct sk_buff *new_skb;
 
-			new_skb = gem_alloc_skb(RX_BUF_ALLOC_SIZE(gp), GFP_ATOMIC);
+			new_skb = gem_alloc_skb(dev, RX_BUF_ALLOC_SIZE(gp), GFP_ATOMIC);
 			if (new_skb == NULL) {
 				drops++;
 				goto drop_it;
@@ -808,7 +835,6 @@ static int gem_rx(struct gem *gp, int work_to_do)
 				       RX_BUF_ALLOC_SIZE(gp),
 				       PCI_DMA_FROMDEVICE);
 			gp->rx_skbs[entry] = new_skb;
-			new_skb->dev = gp->dev;
 			skb_put(new_skb, (gp->rx_buf_sz + RX_OFFSET));
 			rxd->buffer = cpu_to_le64(pci_map_page(gp->pdev,
 							       virt_to_page(new_skb->data),
@@ -820,7 +846,7 @@ static int gem_rx(struct gem *gp, int work_to_do)
 			/* Trim the original skb for the netif. */
 			skb_trim(skb, len);
 		} else {
-			struct sk_buff *copy_skb = dev_alloc_skb(len + 2);
+			struct sk_buff *copy_skb = netdev_alloc_skb(dev, len + 2);
 
 			if (copy_skb == NULL) {
 				drops++;
@@ -842,7 +868,7 @@ static int gem_rx(struct gem *gp, int work_to_do)
 		skb->ip_summed = CHECKSUM_COMPLETE;
 		skb->protocol = eth_type_trans(skb, gp->dev);
 
-		netif_receive_skb(skb);
+		napi_gro_receive(&gp->napi, skb);
 
 		dev->stats.rx_packets++;
 		dev->stats.rx_bytes += len;
@@ -865,28 +891,20 @@ static int gem_poll(struct napi_struct *napi, int budget)
 {
 	struct gem *gp = container_of(napi, struct gem, napi);
 	struct net_device *dev = gp->dev;
-	unsigned long flags;
 	int work_done;
 
-	/*
-	 * NAPI locking nightmare: See comment at head of driver
-	 */
-	spin_lock_irqsave(&gp->lock, flags);
-
 	work_done = 0;
 	do {
 		/* Handle anomalies */
-		if (gp->status & GREG_STAT_ABNORMAL) {
-			if (gem_abnormal_irq(dev, gp, gp->status))
-				break;
+		if (unlikely(gp->status & GREG_STAT_ABNORMAL)) {
+			if (gem_abnormal_irq(dev, gp, gp->status)) {
+				napi_complete(napi);
+				return work_done;
+			}
 		}
 
 		/* Run TX completion thread */
-		spin_lock(&gp->tx_lock);
 		gem_tx(dev, gp, gp->status);
-		spin_unlock(&gp->tx_lock);
-
-		spin_unlock_irqrestore(&gp->lock, flags);
 
 		/* Run RX thread. We don't use any locking here,
 		 * code willing to do bad things - like cleaning the
@@ -898,16 +916,12 @@ static int gem_poll(struct napi_struct *napi, int budget)
 		if (work_done >= budget)
 			return work_done;
 
-		spin_lock_irqsave(&gp->lock, flags);
-
 		gp->status = readl(gp->regs + GREG_STAT);
 	} while (gp->status & GREG_STAT_NAPI);
 
-	__napi_complete(napi);
+	napi_complete(napi);
 	gem_enable_ints(gp);
 
-	spin_unlock_irqrestore(&gp->lock, flags);
-
 	return work_done;
 }
 
@@ -915,32 +929,23 @@ static irqreturn_t gem_interrupt(int irq, void *dev_id)
 {
 	struct net_device *dev = dev_id;
 	struct gem *gp = netdev_priv(dev);
-	unsigned long flags;
-
-	/* Swallow interrupts when shutting the chip down, though
-	 * that shouldn't happen, we should have done free_irq() at
-	 * this point...
-	 */
-	if (!gp->running)
-		return IRQ_HANDLED;
-
-	spin_lock_irqsave(&gp->lock, flags);
 
 	if (napi_schedule_prep(&gp->napi)) {
 		u32 gem_status = readl(gp->regs + GREG_STAT);
 
-		if (gem_status == 0) {
+		if (unlikely(gem_status == 0)) {
 			napi_enable(&gp->napi);
-			spin_unlock_irqrestore(&gp->lock, flags);
 			return IRQ_NONE;
 		}
+		if (netif_msg_intr(gp))
+			printk(KERN_DEBUG "%s: gem_interrupt() gem_status: 0x%x\n",
+			       gp->dev->name, gem_status);
+
 		gp->status = gem_status;
 		gem_disable_ints(gp);
 		__napi_schedule(&gp->napi);
 	}
 
-	spin_unlock_irqrestore(&gp->lock, flags);
-
 	/* If polling was disabled at the time we received that
 	 * interrupt, we may return IRQ_HANDLED here while we
 	 * should return IRQ_NONE. No big deal...
@@ -951,11 +956,12 @@ static irqreturn_t gem_interrupt(int irq, void *dev_id)
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void gem_poll_controller(struct net_device *dev)
 {
-	/* gem_interrupt is safe to reentrance so no need
-	 * to disable_irq here.
-	 */
-	gem_interrupt(dev->irq, dev);
-}
+	struct gem *gp = netdev_priv(dev);
+
+	disable_irq(gp->pdev->irq);
+	gem_interrupt(gp->pdev->irq, dev);
+	enable_irq(gp->pdev->irq);
+
 #endif
 
 static void gem_tx_timeout(struct net_device *dev)
@@ -963,10 +969,7 @@ static void gem_tx_timeout(struct net_device *dev)
 	struct gem *gp = netdev_priv(dev);
 
 	netdev_err(dev, "transmit timed out, resetting\n");
-	if (!gp->running) {
-		netdev_err(dev, "hrm.. hw not running !\n");
-		return;
-	}
+
 	netdev_err(dev, "TX_STATE[%08x:%08x:%08x]\n",
 		   readl(gp->regs + TXDMA_CFG),
 		   readl(gp->regs + MAC_TXSTAT),
@@ -976,14 +979,9 @@ static void gem_tx_timeout(struct net_device *dev)
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
+	spin_lock(&gp->lock);
+	gem_schedule_reset(gp);
+	spin_unlock(&gp->lock);
 }
 
 static __inline__ int gem_intme(int entry)
@@ -1001,7 +999,6 @@ static netdev_tx_t gem_start_xmit(struct sk_buff *skb,
 	struct gem *gp = netdev_priv(dev);
 	int entry;
 	u64 ctrl;
-	unsigned long flags;
 
 	ctrl = 0;
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
@@ -1013,21 +1010,12 @@ static netdev_tx_t gem_start_xmit(struct sk_buff *skb,
 			(csum_stuff_off << 21));
 	}
 
-	if (!spin_trylock_irqsave(&gp->tx_lock, flags)) {
-		/* Tell upper layer to requeue */
-		return NETDEV_TX_LOCKED;
-	}
-	/* We raced with gem_do_stop() */
-	if (!gp->running) {
-		spin_unlock_irqrestore(&gp->tx_lock, flags);
-		return NETDEV_TX_BUSY;
-	}
-
-	/* This is a hard error, log it. */
-	if (TX_BUFFS_AVAIL(gp) <= (skb_shinfo(skb)->nr_frags + 1)) {
-		netif_stop_queue(dev);
-		spin_unlock_irqrestore(&gp->tx_lock, flags);
-		netdev_err(dev, "BUG! Tx Ring full when queue awake!\n");
+	if (unlikely(TX_BUFFS_AVAIL(gp) <= (skb_shinfo(skb)->nr_frags + 1))) {
+		/* This is a hard error, log it. */
+		if (!netif_queue_stopped(dev)) {
+			netif_stop_queue(dev);
+			netdev_err(dev, "BUG! Tx Ring full when queue awake!\n");
+		}
 		return NETDEV_TX_BUSY;
 	}
 
@@ -1104,17 +1092,23 @@ static netdev_tx_t gem_start_xmit(struct sk_buff *skb,
 	}
 
 	gp->tx_new = entry;
-	if (TX_BUFFS_AVAIL(gp) <= (MAX_SKB_FRAGS + 1))
+	if (unlikely(TX_BUFFS_AVAIL(gp) <= (MAX_SKB_FRAGS + 1))) {
 		netif_stop_queue(dev);
 
+		/* netif_stop_queue() must be done before checking
+		 * checking tx index in TX_BUFFS_AVAIL() below, because
+		 * in gem_tx(), we update tx_old before checking for
+		 * netif_queue_stopped().
+		 */
+		smp_mb();
+		if (TX_BUFFS_AVAIL(gp) > (MAX_SKB_FRAGS + 1))
+			netif_wake_queue(dev);
+	}
 	if (netif_msg_tx_queued(gp))
 		printk(KERN_DEBUG "%s: tx queued, slot %d, skblen %d\n",
 		       dev->name, entry, skb->len);
 	mb();
 	writel(gp->tx_new, gp->regs + TXDMA_KICK);
-	spin_unlock_irqrestore(&gp->tx_lock, flags);
-
-	dev->trans_start = jiffies; /* NETIF_F_LLTX driver :( */
 
 	return NETDEV_TX_OK;
 }
@@ -1184,7 +1178,6 @@ static void gem_pcs_reinit_adv(struct gem *gp)
 
 #define STOP_TRIES 32
 
-/* Must be invoked under gp->lock and gp->tx_lock. */
 static void gem_reset(struct gem *gp)
 {
 	int limit;
@@ -1213,7 +1206,6 @@ static void gem_reset(struct gem *gp)
 		gem_pcs_reinit_adv(gp);
 }
 
-/* Must be invoked under gp->lock and gp->tx_lock. */
 static void gem_start_dma(struct gem *gp)
 {
 	u32 val;
@@ -1236,8 +1228,7 @@ static void gem_start_dma(struct gem *gp)
 	writel(RX_RING_SIZE - 4, gp->regs + RXDMA_KICK);
 }
 
-/* Must be invoked under gp->lock and gp->tx_lock. DMA won't be
- * actually stopped before about 4ms tho ...
+/* DMA won't be actually stopped before about 4ms tho ...
  */
 static void gem_stop_dma(struct gem *gp)
 {
@@ -1259,7 +1250,7 @@ static void gem_stop_dma(struct gem *gp)
 }
 
 
-/* Must be invoked under gp->lock and gp->tx_lock. */
+/* Must be invoked under gp->lock */
 // XXX dbl check what that function should do when called on PCS PHY
 static void gem_begin_auto_negotiation(struct gem *gp, struct ethtool_cmd *ep)
 {
@@ -1319,7 +1310,7 @@ start_aneg:
 	/* If we are asleep, we don't try to actually setup the PHY, we
 	 * just store the settings
 	 */
-	if (gp->asleep) {
+	if (!netif_device_present(gp->dev)) {
 		gp->phy_mii.autoneg = gp->want_autoneg = autoneg;
 		gp->phy_mii.speed = speed;
 		gp->phy_mii.duplex = duplex;
@@ -1345,8 +1336,6 @@ non_mii:
 
 /* A link-up condition has occurred, initialize and enable the
  * rest of the chip.
- *
- * Must be invoked under gp->lock and gp->tx_lock.
  */
 static int gem_set_link_modes(struct gem *gp)
 {
@@ -1375,7 +1364,11 @@ static int gem_set_link_modes(struct gem *gp)
 	netif_info(gp, link, gp->dev, "Link is up at %d Mbps, %s-duplex\n",
 		   speed, (full_duplex ? "full" : "half"));
 
-	if (!gp->running)
+	/* This can happen after the core makes netif_running true
+	 * and before we've taken the lock & enabled the cell so
+	 * guard against it here
+	 */
+	if (!netif_running(gp->dev) || !netif_device_present(gp->dev))
 		return 0;
 
 	val = (MAC_TXCFG_EIPG0 | MAC_TXCFG_NGU);
@@ -1453,7 +1446,6 @@ static int gem_set_link_modes(struct gem *gp)
 	return 0;
 }
 
-/* Must be invoked under gp->lock and gp->tx_lock. */
 static int gem_mdio_link_not_up(struct gem *gp)
 {
 	switch (gp->lstate) {
@@ -1501,13 +1493,14 @@ static int gem_mdio_link_not_up(struct gem *gp)
 static void gem_link_timer(unsigned long data)
 {
 	struct gem *gp = (struct gem *) data;
+	struct net_device *dev = gp->dev;
 	int restart_aneg = 0;
 
-	if (gp->asleep)
+	spin_lock(&gp->lock);
+	if (!netif_running(dev) || !netif_device_present(dev)) {
+		spin_unlock(&gp->lock);
 		return;
-
-	spin_lock_irq(&gp->lock);
-	spin_lock(&gp->tx_lock);
+	}
 	gem_get_cell(gp);
 
 	/* If the reset task is still pending, we just
@@ -1528,7 +1521,7 @@ static void gem_link_timer(unsigned long data)
 				goto restart;
 
 			gp->lstate = link_up;
-			netif_carrier_on(gp->dev);
+			netif_carrier_on(dev);
 			(void)gem_set_link_modes(gp);
 		}
 		goto restart;
@@ -1544,12 +1537,12 @@ static void gem_link_timer(unsigned long data)
 			gp->last_forced_speed = gp->phy_mii.speed;
 			gp->timer_ticks = 5;
 			if (netif_msg_link(gp))
-				netdev_info(gp->dev,
+				netdev_info(dev,
 					    "Got link after fallback, retrying autoneg once...\n");
 			gp->phy_mii.def->ops->setup_aneg(&gp->phy_mii, gp->phy_mii.advertising);
 		} else if (gp->lstate != link_up) {
 			gp->lstate = link_up;
-			netif_carrier_on(gp->dev);
+			netif_carrier_on(dev);
 			if (gem_set_link_modes(gp))
 				restart_aneg = 1;
 		}
@@ -1559,11 +1552,11 @@ static void gem_link_timer(unsigned long data)
 		 */
 		if (gp->lstate == link_up) {
 			gp->lstate = link_down;
-			netif_info(gp, link, gp->dev, "Link down\n");
-			netif_carrier_off(gp->dev);
-			gp->reset_task_pending = 1;
-			schedule_work(&gp->reset_task);
-			restart_aneg = 1;
+			netif_info(gp, link, dev, "Link down\n");
+			netif_carrier_off(dev);
+			gem_schedule_reset(gp);
+			/* The reset task will restart the timer */
+			goto out_unlock;
 		} else if (++gp->timer_ticks > 10) {
 			if (found_mii_phy(gp))
 				restart_aneg = gem_mdio_link_not_up(gp);
@@ -1579,11 +1572,9 @@ restart:
 	mod_timer(&gp->link_timer, jiffies + ((12 * HZ) / 10));
 out_unlock:
 	gem_put_cell(gp);
-	spin_unlock(&gp->tx_lock);
-	spin_unlock_irq(&gp->lock);
+	spin_unlock(&gp->lock);
 }
 
-/* Must be invoked under gp->lock and gp->tx_lock. */
 static void gem_clean_rings(struct gem *gp)
 {
 	struct gem_init_block *gb = gp->init_block;
@@ -1634,7 +1625,6 @@ static void gem_clean_rings(struct gem *gp)
 	}
 }
 
-/* Must be invoked under gp->lock and gp->tx_lock. */
 static void gem_init_rings(struct gem *gp)
 {
 	struct gem_init_block *gb = gp->init_block;
@@ -1653,7 +1643,7 @@ static void gem_init_rings(struct gem *gp)
 		struct sk_buff *skb;
 		struct gem_rxd *rxd = &gb->rxd[i];
 
-		skb = gem_alloc_skb(RX_BUF_ALLOC_SIZE(gp), GFP_ATOMIC);
+		skb = gem_alloc_skb(dev, RX_BUF_ALLOC_SIZE(gp), GFP_KERNEL);
 		if (!skb) {
 			rxd->buffer = 0;
 			rxd->status_word = 0;
@@ -1661,7 +1651,6 @@ static void gem_init_rings(struct gem *gp)
 		}
 
 		gp->rx_skbs[i] = skb;
-		skb->dev = dev;
 		skb_put(skb, (gp->rx_buf_sz + RX_OFFSET));
 		dma_addr = pci_map_page(gp->pdev,
 					virt_to_page(skb->data),
@@ -1753,13 +1742,17 @@ static void gem_init_phy(struct gem *gp)
 	gp->lstate = link_down;
 	netif_carrier_off(gp->dev);
 
-	/* Can I advertise gigabit here ? I'd need BCM PHY docs... */
-	spin_lock_irq(&gp->lock);
+	/* Print things out */
+	if (gp->phy_type == phy_mii_mdio0 ||
+     	    gp->phy_type == phy_mii_mdio1)
+		netdev_info(gp->dev, "Found %s PHY\n",
+			    gp->phy_mii.def ? gp->phy_mii.def->name : "no");
+
+	spin_lock_bh(&gp->lock);
 	gem_begin_auto_negotiation(gp, NULL);
-	spin_unlock_irq(&gp->lock);
+	spin_unlock_bh(&gp->lock);
 }
 
-/* Must be invoked under gp->lock and gp->tx_lock. */
 static void gem_init_dma(struct gem *gp)
 {
 	u64 desc_dma = (u64) gp->gblock_dvma;
@@ -1797,7 +1790,6 @@ static void gem_init_dma(struct gem *gp)
 		       gp->regs + RXDMA_BLANK);
 }
 
-/* Must be invoked under gp->lock and gp->tx_lock. */
 static u32 gem_setup_multicast(struct gem *gp)
 {
 	u32 rxcfg = 0;
@@ -1835,7 +1827,6 @@ static u32 gem_setup_multicast(struct gem *gp)
 	return rxcfg;
 }
 
-/* Must be invoked under gp->lock and gp->tx_lock. */
 static void gem_init_mac(struct gem *gp)
 {
 	unsigned char *e = &gp->dev->dev_addr[0];
@@ -1918,7 +1909,6 @@ static void gem_init_mac(struct gem *gp)
 		writel(0, gp->regs + WOL_WAKECSR);
 }
 
-/* Must be invoked under gp->lock and gp->tx_lock. */
 static void gem_init_pause_thresholds(struct gem *gp)
 {
        	u32 cfg;
@@ -2079,7 +2069,6 @@ static int gem_check_invariants(struct gem *gp)
 	return 0;
 }
 
-/* Must be invoked under gp->lock and gp->tx_lock. */
 static void gem_reinit_chip(struct gem *gp)
 {
 	/* Reset the chip */
@@ -2100,11 +2089,9 @@ static void gem_reinit_chip(struct gem *gp)
 }
 
 
-/* Must be invoked with no lock held. */
 static void gem_stop_phy(struct gem *gp, int wol)
 {
 	u32 mifcfg;
-	unsigned long flags;
 
 	/* Let the chip settle down a bit, it seems that helps
 	 * for sleep mode on some models
@@ -2150,15 +2137,9 @@ static void gem_stop_phy(struct gem *gp, int wol)
 	writel(0, gp->regs + RXDMA_CFG);
 
 	if (!wol) {
-		spin_lock_irqsave(&gp->lock, flags);
-		spin_lock(&gp->tx_lock);
 		gem_reset(gp);
 		writel(MAC_TXRST_CMD, gp->regs + MAC_TXRST);
 		writel(MAC_RXRST_CMD, gp->regs + MAC_RXRST);
-		spin_unlock(&gp->tx_lock);
-		spin_unlock_irqrestore(&gp->lock, flags);
-
-		/* No need to take the lock here */
 
 		if (found_mii_phy(gp) && gp->phy_mii.def->ops->suspend)
 			gp->phy_mii.def->ops->suspend(&gp->phy_mii);
@@ -2175,51 +2156,42 @@ static void gem_stop_phy(struct gem *gp, int wol)
 	}
 }
 
-
 static int gem_do_start(struct net_device *dev)
 {
 	struct gem *gp = netdev_priv(dev);
-	unsigned long flags;
 
-	spin_lock_irqsave(&gp->lock, flags);
-	spin_lock(&gp->tx_lock);
+	/* In case the HW off or reinit generates stray
+	 * interrupts.
+	 */
+	spin_lock_bh(&gp->lock);
 
 	/* Enable the cell */
 	gem_get_cell(gp);
+	gem_disable_ints(gp);
+
+	spin_unlock_bh(&gp->lock);
 
 	/* Init & setup chip hardware */
 	gem_reinit_chip(gp);
 
-	gp->running = 1;
-
-	napi_enable(&gp->napi);
-
-	if (gp->lstate == link_up) {
-		netif_carrier_on(gp->dev);
-		gem_set_link_modes(gp);
-	}
-
-	netif_wake_queue(gp->dev);
+	/* Detect & init PHY, start autoneg etc */
+	gem_init_phy(gp);
 
-	spin_unlock(&gp->tx_lock);
-	spin_unlock_irqrestore(&gp->lock, flags);
+	/* Restart NAPI & queues */
+	gem_netif_start(gp);
 
 	if (request_irq(gp->pdev->irq, gem_interrupt,
 				   IRQF_SHARED, dev->name, (void *)dev)) {
 		netdev_err(dev, "failed to request irq !\n");
 
-		spin_lock_irqsave(&gp->lock, flags);
-		spin_lock(&gp->tx_lock);
-
 		napi_disable(&gp->napi);
-
-		gp->running =  0;
+		netif_device_detach(dev);
 		gem_reset(gp);
 		gem_clean_rings(gp);
-		gem_put_cell(gp);
 
-		spin_unlock(&gp->tx_lock);
-		spin_unlock_irqrestore(&gp->lock, flags);
+		spin_lock_bh(&gp->lock);
+		gem_put_cell(gp);
+		spin_unlock_bh(&gp->lock);
 
 		return -EAGAIN;
 	}
@@ -2230,22 +2202,19 @@ static int gem_do_start(struct net_device *dev)
 static void gem_do_stop(struct net_device *dev, int wol)
 {
 	struct gem *gp = netdev_priv(dev);
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
+	/* Stop NAPI and stop tx queue */
+	gem_netif_stop(gp);
+	
+	/* Make sure ints are disabled. We don't care about
+	 * synchronizing as NAPI is disabled, thus a stray
+	 * interrupt will do nothing bad (our irq handler
+	 * just schedules NAPI)
+	 */
 	gem_disable_ints(gp);
 
-	/* We can drop the lock now */
-	spin_unlock(&gp->tx_lock);
-	spin_unlock_irqrestore(&gp->lock, flags);
+	/* Stop the link timer */
+	del_timer_sync(&gp->link_timer);
 
 	/* If we are going to sleep with WOL */
 	gem_stop_dma(gp);
@@ -2260,11 +2229,14 @@ static void gem_do_stop(struct net_device *dev, int wol)
 	/* No irq needed anymore */
 	free_irq(gp->pdev->irq, (void *) dev);
 
+	/* Shut the PHY down eventually and setup WOL */
+	gem_stop_phy(gp, wol);
+
 	/* Cell not needed neither if no WOL */
 	if (!wol) {
-		spin_lock_irqsave(&gp->lock, flags);
+		spin_lock_bh(&gp->lock);
 		gem_put_cell(gp);
-		spin_unlock_irqrestore(&gp->lock, flags);
+		spin_unlock_bh(&gp->lock);
 	}
 }
 
@@ -2274,29 +2246,38 @@ static void gem_reset_task(struct work_struct *work)
 
 	mutex_lock(&gp->pm_mutex);
 
-	if (gp->opened)
-		napi_disable(&gp->napi);
+	/* Skip the reset task if not opened or suspended */
+	if (!netif_running(gp->dev) || !netif_device_present(gp->dev)) {
+		mutex_unlock(&gp->pm_mutex);
+		return;
+	}
+	
+	/* Stop the link timer */
+	del_timer_sync(&gp->link_timer);
 
-	spin_lock_irq(&gp->lock);
-	spin_lock(&gp->tx_lock);
+	/* Stop NAPI and tx */
+	gem_netif_stop(gp);
 
-	if (gp->running) {
-		netif_stop_queue(gp->dev);
+	/* Reset the chip & rings */
+	gem_reinit_chip(gp);
+	if (gp->lstate == link_up)
+		gem_set_link_modes(gp);
 
-		/* Reset the chip & rings */
-		gem_reinit_chip(gp);
-		if (gp->lstate == link_up)
-			gem_set_link_modes(gp);
-		netif_wake_queue(gp->dev);
-	}
+	/* Restart NAPI and Tx */
+	gem_netif_start(gp);
 
+	/* We are back ! */
 	gp->reset_task_pending = 0;
 
-	spin_unlock(&gp->tx_lock);
-	spin_unlock_irq(&gp->lock);
-
-	if (gp->opened)
-		napi_enable(&gp->napi);
+	/* If the link is not up, restart autoneg, else restart the
+	 * polling timer
+	 */
+	if (gp->lstate != link_up) {
+		spin_lock_bh(&gp->lock);
+		gem_begin_auto_negotiation(gp, NULL);
+		spin_unlock_bh(&gp->lock);
+	} else
+		mod_timer(&gp->link_timer, jiffies + ((12 * HZ) / 10));
 
 	mutex_unlock(&gp->pm_mutex);
 }
@@ -2308,14 +2289,9 @@ static int gem_open(struct net_device *dev)
 	int rc = 0;
 
 	mutex_lock(&gp->pm_mutex);
-
-	/* We need the cell enabled */
-	if (!gp->asleep)
+	if (netif_device_present(dev))
 		rc = gem_do_start(dev);
-	gp->opened = (rc == 0);
-
 	mutex_unlock(&gp->pm_mutex);
-
 	return rc;
 }
 
@@ -2324,15 +2300,13 @@ static int gem_close(struct net_device *dev)
 	struct gem *gp = netdev_priv(dev);
 
 	mutex_lock(&gp->pm_mutex);
-
-	napi_disable(&gp->napi);
-
-	gp->opened = 0;
-	if (!gp->asleep)
+	if (netif_device_present(dev))
 		gem_do_stop(dev, 0);
-
 	mutex_unlock(&gp->pm_mutex);
 
+	/* Ensure reset task is truely gone */
+	cancel_work_sync(&gp->reset_task);
+
 	return 0;
 }
 
@@ -2341,59 +2315,54 @@ static int gem_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct gem *gp = netdev_priv(dev);
-	unsigned long flags;
 
+	/* Lock the network stack first to avoid races with open/close */
+	rtnl_lock();
 	mutex_lock(&gp->pm_mutex);
 
+	/* Not running, mark ourselves non-present, no need for
+	 * a lock here
+	 */
+	if (!netif_running(dev)) {
+		netif_device_detach(dev);
+		goto bail;
+	}
 	netdev_info(dev, "suspending, WakeOnLan %s\n",
-		    (gp->wake_on_lan && gp->opened) ? "enabled" : "disabled");
+		    (gp->wake_on_lan && netif_running(dev)) ?
+		    "enabled" : "disabled");
 
-	/* Keep the cell enabled during the entire operation */
-	spin_lock_irqsave(&gp->lock, flags);
-	spin_lock(&gp->tx_lock);
+	/* Keep the clocks enabled during the entire operation
+	 * mark us !present under lock
+	 */
+	spin_lock_bh(&gp->lock);
 	gem_get_cell(gp);
-	spin_unlock(&gp->tx_lock);
-	spin_unlock_irqrestore(&gp->lock, flags);
-
-	/* If the driver is opened, we stop the MAC */
-	if (gp->opened) {
-		napi_disable(&gp->napi);
+	netif_device_detach(dev);
+	spin_unlock_bh(&gp->lock);
 
-		/* Stop traffic, mark us closed */
-		netif_device_detach(dev);
+	/* Switch off chip, remember WOL setting */
+	gp->asleep_wol = gp->wake_on_lan;
+	gem_do_stop(dev, gp->asleep_wol);
 
-		/* Switch off MAC, remember WOL setting */
-		gp->asleep_wol = gp->wake_on_lan;
-		gem_do_stop(dev, gp->asleep_wol);
-	} else
-		gp->asleep_wol = 0;
-
-	/* Mark us asleep */
-	gp->asleep = 1;
-	wmb();
+	/* Make sure bus master is disabled */
+	pci_disable_device(gp->pdev);
 
-	/* Stop the link timer */
-	del_timer_sync(&gp->link_timer);
+	/* Stop the HW clocks */
+	spin_lock_bh(&gp->lock);
+	gem_put_cell(gp);
+	spin_unlock_bh(&gp->lock);
 
+ bail:
 	/* Now we release the mutex to not block the reset task who
 	 * can take it too. We are marked asleep, so there will be no
 	 * conflict here
 	 */
 	mutex_unlock(&gp->pm_mutex);
 
-	/* Wait for the pending reset task to complete */
-	flush_work_sync(&gp->reset_task);
-
-	/* Shut the PHY down eventually and setup WOL */
-	gem_stop_phy(gp, gp->asleep_wol);
+	/* Wait for a pending reset task to complete */
+	cancel_work_sync(&gp->reset_task);
 
-	/* Make sure bus master is disabled */
-	pci_disable_device(gp->pdev);
-
-	/* Release the cell, no need to take a lock at this point since
-	 * nothing else can happen now
-	 */
-	gem_put_cell(gp);
+	/* Unlock the network stack */
+	rtnl_unlock();
 
 	return 0;
 }
@@ -2402,17 +2371,26 @@ static int gem_resume(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct gem *gp = netdev_priv(dev);
-	unsigned long flags;
-
-	netdev_info(dev, "resuming\n");
 
+	/* See locking comment in gem_suspend */
+	rtnl_lock();
 	mutex_lock(&gp->pm_mutex);
 
+	/* Not running, mark ourselves present, no need for
+	 * a lock here
+	 */
+	if (!netif_running(dev)) {
+		netif_device_attach(dev);
+		goto bail;
+	}
+
 	/* Keep the cell enabled during the entire operation, no need to
 	 * take a lock here tho since nothing else can happen while we are
 	 * marked asleep
 	 */
+	spin_lock_bh(&gp->lock);
 	gem_get_cell(gp);
+	spin_unlock_bh(&gp->lock);
 
 	/* Make sure PCI access and bus master are enabled */
 	if (pci_enable_device(gp->pdev)) {
@@ -2430,25 +2408,12 @@ static int gem_resume(struct pci_dev *pdev)
 	gem_reset(gp);
 
 	/* Mark us woken up */
-	gp->asleep = 0;
-	wmb();
-
-	/* Bring the PHY back. Again, lock is useless at this point as
-	 * nothing can be happening until we restart the whole thing
-	 */
-	gem_init_phy(gp);
+	netif_device_attach(dev);	
 
-	/* If we were opened, bring everything back */
-	if (gp->opened) {
-		/* Restart MAC */
-		gem_do_start(dev);
-
-		/* Re-attach net device */
-		netif_device_attach(dev);
-	}
-
-	spin_lock_irqsave(&gp->lock, flags);
-	spin_lock(&gp->tx_lock);
+	/* Restart chip */
+	gem_do_start(dev);
+	
+	spin_lock_bh(&gp->lock);
 
 	/* If we had WOL enabled, the cell clock was never turned off during
 	 * sleep, so we end up beeing unbalanced. Fix that here
@@ -2460,11 +2425,10 @@ static int gem_resume(struct pci_dev *pdev)
 	 * driver is open by gem_do_start().
 	 */
 	gem_put_cell(gp);
-
-	spin_unlock(&gp->tx_lock);
-	spin_unlock_irqrestore(&gp->lock, flags);
-
+	spin_unlock_bh(&gp->lock);
+ bail:
 	mutex_unlock(&gp->pm_mutex);
+	rtnl_unlock();
 
 	return 0;
 }
@@ -2474,32 +2438,34 @@ static struct net_device_stats *gem_get_stats(struct net_device *dev)
 {
 	struct gem *gp = netdev_priv(dev);
 
-	spin_lock_irq(&gp->lock);
-	spin_lock(&gp->tx_lock);
+	spin_lock_bh(&gp->lock);
 
 	/* I have seen this being called while the PM was in progress,
-	 * so we shield against this
+	 * so we shield against this. Let's also not poke at registers
+	 * while the reset task is going on.
 	 */
-	if (gp->running) {
-		dev->stats.rx_crc_errors += readl(gp->regs + MAC_FCSERR);
-		writel(0, gp->regs + MAC_FCSERR);
+	if (!netif_device_present(dev) || gp->reset_task_pending)
+		goto bail;
+	gem_get_cell(gp);
 
-		dev->stats.rx_frame_errors += readl(gp->regs + MAC_AERR);
-		writel(0, gp->regs + MAC_AERR);
+	dev->stats.rx_crc_errors += readl(gp->regs + MAC_FCSERR);
+	writel(0, gp->regs + MAC_FCSERR);
 
-		dev->stats.rx_length_errors += readl(gp->regs + MAC_LERR);
-		writel(0, gp->regs + MAC_LERR);
+	dev->stats.rx_frame_errors += readl(gp->regs + MAC_AERR);
+	writel(0, gp->regs + MAC_AERR);
 
-		dev->stats.tx_aborted_errors += readl(gp->regs + MAC_ECOLL);
-		dev->stats.collisions +=
-			(readl(gp->regs + MAC_ECOLL) +
-			 readl(gp->regs + MAC_LCOLL));
-		writel(0, gp->regs + MAC_ECOLL);
-		writel(0, gp->regs + MAC_LCOLL);
-	}
+	dev->stats.rx_length_errors += readl(gp->regs + MAC_LERR);
+	writel(0, gp->regs + MAC_LERR);
 
-	spin_unlock(&gp->tx_lock);
-	spin_unlock_irq(&gp->lock);
+	dev->stats.tx_aborted_errors += readl(gp->regs + MAC_ECOLL);
+	dev->stats.collisions +=
+		(readl(gp->regs + MAC_ECOLL) + readl(gp->regs + MAC_LCOLL));
+	writel(0, gp->regs + MAC_ECOLL);
+	writel(0, gp->regs + MAC_LCOLL);
+
+	gem_put_cell(gp);
+ bail:
+	spin_unlock_bh(&gp->lock);
 
 	return &dev->stats;
 }
@@ -2513,21 +2479,26 @@ static int gem_set_mac_address(struct net_device *dev, void *addr)
 	if (!is_valid_ether_addr(macaddr->sa_data))
 		return -EADDRNOTAVAIL;
 
+	memcpy(dev->dev_addr, macaddr->sa_data, dev->addr_len);
+
 	if (!netif_running(dev) || !netif_device_present(dev)) {
 		/* We'll just catch it later when the
 		 * device is up'd or resumed.
 		 */
-		memcpy(dev->dev_addr, macaddr->sa_data, dev->addr_len);
 		return 0;
 	}
 
+	/* Mutex synchronizes us vs. suspend/resume & reset task */
 	mutex_lock(&gp->pm_mutex);
-	memcpy(dev->dev_addr, macaddr->sa_data, dev->addr_len);
-	if (gp->running) {
-		writel((e[4] << 8) | e[5], gp->regs + MAC_ADDR0);
-		writel((e[2] << 8) | e[3], gp->regs + MAC_ADDR1);
-		writel((e[0] << 8) | e[1], gp->regs + MAC_ADDR2);
-	}
+
+	/* Better safe than sorry... */
+	if (WARN_ON(!gp->cell_enabled))
+		goto bail;
+
+	writel((e[4] << 8) | e[5], gp->regs + MAC_ADDR0);
+	writel((e[2] << 8) | e[3], gp->regs + MAC_ADDR1);
+	writel((e[0] << 8) | e[1], gp->regs + MAC_ADDR2);
+ bail:
 	mutex_unlock(&gp->pm_mutex);
 
 	return 0;
@@ -2539,15 +2510,16 @@ static void gem_set_multicast(struct net_device *dev)
 	u32 rxcfg, rxcfg_new;
 	int limit = 10000;
 
+	if (!netif_running(dev) || !netif_device_present(dev))
+		return;
 
-	spin_lock_irq(&gp->lock);
-	spin_lock(&gp->tx_lock);
+	/* BH already blocked by caller */
+	spin_lock(&gp->lock);
 
-	if (!gp->running)
+	/* Better safe than sorry... */
+	if (gp->reset_task_pending || WARN_ON(!gp->cell_enabled))
 		goto bail;
 
-	netif_stop_queue(dev);
-
 	rxcfg = readl(gp->regs + MAC_RXCFG);
 	rxcfg_new = gem_setup_multicast(gp);
 #ifdef STRIP_FCS
@@ -2566,12 +2538,8 @@ static void gem_set_multicast(struct net_device *dev)
 	rxcfg |= rxcfg_new;
 
 	writel(rxcfg, gp->regs + MAC_RXCFG);
-
-	netif_wake_queue(dev);
-
  bail:
-	spin_unlock(&gp->tx_lock);
-	spin_unlock_irq(&gp->lock);
+	spin_unlock(&gp->lock);
 }
 
 /* Jumbo-grams don't seem to work :-( */
@@ -2597,17 +2565,20 @@ static int gem_change_mtu(struct net_device *dev, int new_mtu)
 		return 0;
 	}
 
+	/* Mutex synchronizes us vs. suspend/resume & reset task */
 	mutex_lock(&gp->pm_mutex);
-	spin_lock_irq(&gp->lock);
-	spin_lock(&gp->tx_lock);
 	dev->mtu = new_mtu;
-	if (gp->running) {
-		gem_reinit_chip(gp);
-		if (gp->lstate == link_up)
-			gem_set_link_modes(gp);
-	}
-	spin_unlock(&gp->tx_lock);
-	spin_unlock_irq(&gp->lock);
+
+	/* Better safe than sorry... */
+	if (WARN_ON(!gp->cell_enabled))
+		goto bail;
+
+	gem_netif_stop(gp);
+	gem_reinit_chip(gp);
+	if (gp->lstate == link_up)
+		gem_set_link_modes(gp);
+	gem_netif_start(gp);
+ bail:
 	mutex_unlock(&gp->pm_mutex);
 
 	return 0;
@@ -2640,7 +2611,7 @@ static int gem_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		cmd->phy_address = 0; /* XXX fixed PHYAD */
 
 		/* Return current PHY settings */
-		spin_lock_irq(&gp->lock);
+		spin_lock_bh(&gp->lock);
 		cmd->autoneg = gp->want_autoneg;
 		ethtool_cmd_speed_set(cmd, gp->phy_mii.speed);
 		cmd->duplex = gp->phy_mii.duplex;
@@ -2652,7 +2623,7 @@ static int gem_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		 */
 		if (cmd->advertising == 0)
 			cmd->advertising = cmd->supported;
-		spin_unlock_irq(&gp->lock);
+		spin_unlock_bh(&gp->lock);
 	} else { // XXX PCS ?
 		cmd->supported =
 			(SUPPORTED_10baseT_Half | SUPPORTED_10baseT_Full |
@@ -2706,11 +2677,10 @@ static int gem_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		return -EINVAL;
 
 	/* Apply settings and restart link process. */
-	spin_lock_irq(&gp->lock);
-	gem_get_cell(gp);
-	gem_begin_auto_negotiation(gp, cmd);
-	gem_put_cell(gp);
-	spin_unlock_irq(&gp->lock);
+	spin_lock_bh(&gp->lock);
+	if (netif_device_present(gp->dev) && !gp->reset_task_pending)
+		gem_begin_auto_negotiation(gp, cmd);
+	spin_unlock_bh(&gp->lock);
 
 	return 0;
 }
@@ -2723,11 +2693,10 @@ static int gem_nway_reset(struct net_device *dev)
 		return -EINVAL;
 
 	/* Restart link process. */
-	spin_lock_irq(&gp->lock);
-	gem_get_cell(gp);
-	gem_begin_auto_negotiation(gp, NULL);
-	gem_put_cell(gp);
-	spin_unlock_irq(&gp->lock);
+	spin_lock_bh(&gp->lock);
+	if (netif_device_present(gp->dev) && !gp->reset_task_pending)
+		gem_begin_auto_negotiation(gp, NULL);
+	spin_unlock_bh(&gp->lock);
 
 	return 0;
 }
@@ -2791,24 +2760,19 @@ static int gem_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	struct gem *gp = netdev_priv(dev);
 	struct mii_ioctl_data *data = if_mii(ifr);
 	int rc = -EOPNOTSUPP;
-	unsigned long flags;
 
 	/* Hold the PM mutex while doing ioctl's or we may collide
 	 * with power management.
 	 */
 	mutex_lock(&gp->pm_mutex);
 
-	spin_lock_irqsave(&gp->lock, flags);
-	gem_get_cell(gp);
-	spin_unlock_irqrestore(&gp->lock, flags);
-
 	switch (cmd) {
 	case SIOCGMIIPHY:		/* Get address of MII PHY in use. */
 		data->phy_id = gp->mii_phy_addr;
 		/* Fallthrough... */
 
 	case SIOCGMIIREG:		/* Read MII PHY register. */
-		if (!gp->running)
+		if (!netif_device_present(dev) || gp->reset_task_pending)
 			rc = -EAGAIN;
 		else {
 			data->val_out = __phy_read(gp, data->phy_id & 0x1f,
@@ -2818,7 +2782,7 @@ static int gem_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		break;
 
 	case SIOCSMIIREG:		/* Write MII PHY register. */
-		if (!gp->running)
+		if (!netif_device_present(dev) || gp->reset_task_pending)
 			rc = -EAGAIN;
 		else {
 			__phy_write(gp, data->phy_id & 0x1f, data->reg_num & 0x1f,
@@ -2828,10 +2792,6 @@ static int gem_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		break;
 	};
 
-	spin_lock_irqsave(&gp->lock, flags);
-	gem_put_cell(gp);
-	spin_unlock_irqrestore(&gp->lock, flags);
-
 	mutex_unlock(&gp->pm_mutex);
 
 	return rc;
@@ -3044,7 +3004,6 @@ static int __devinit gem_init_one(struct pci_dev *pdev,
 	gp->msg_enable = DEFAULT_MSG;
 
 	spin_lock_init(&gp->lock);
-	spin_lock_init(&gp->tx_lock);
 	mutex_init(&gp->pm_mutex);
 
 	init_timer(&gp->link_timer);
@@ -3122,14 +3081,11 @@ static int __devinit gem_init_one(struct pci_dev *pdev,
 	/* Set that now, in case PM kicks in now */
 	pci_set_drvdata(pdev, dev);
 
-	/* Detect & init PHY, start autoneg, we release the cell now
-	 * too, it will be managed by whoever needs it
-	 */
-	gem_init_phy(gp);
-
-	spin_lock_irq(&gp->lock);
-	gem_put_cell(gp);
-	spin_unlock_irq(&gp->lock);
+	/* We can do scatter/gather and HW checksum */
+	dev->hw_features = NETIF_F_SG | NETIF_F_HW_CSUM;
+	dev->features |= dev->hw_features | NETIF_F_RXCSUM;
+	if (pci_using_dac)
+		dev->features |= NETIF_F_HIGHDMA;
 
 	/* Register with kernel */
 	if (register_netdev(dev)) {
@@ -3138,20 +3094,12 @@ static int __devinit gem_init_one(struct pci_dev *pdev,
 		goto err_out_free_consistent;
 	}
 
+	spin_lock_bh(&gp->lock);
+	gem_put_cell(gp);
+	spin_unlock_bh(&gp->lock);
+
 	netdev_info(dev, "Sun GEM (PCI) 10/100/1000BaseT Ethernet %pM\n",
 		    dev->dev_addr);
-
-	if (gp->phy_type == phy_mii_mdio0 ||
-     	    gp->phy_type == phy_mii_mdio1)
-		netdev_info(dev, "Found %s PHY\n",
-			    gp->phy_mii.def ? gp->phy_mii.def->name : "no");
-
-	/* GEM can do it all... */
-	dev->hw_features = NETIF_F_SG | NETIF_F_HW_CSUM;
-	dev->features |= dev->hw_features | NETIF_F_RXCSUM | NETIF_F_LLTX;
-	if (pci_using_dac)
-		dev->features |= NETIF_F_HIGHDMA;
-
 	return 0;
 
 err_out_free_consistent:
diff --git a/drivers/net/sungem.h b/drivers/net/sungem.h
index d225077..4a83147 100644
--- a/drivers/net/sungem.h
+++ b/drivers/net/sungem.h
@@ -974,16 +974,12 @@ enum link_state {
 
 struct gem {
 	spinlock_t		lock;
-	spinlock_t		tx_lock;
 	void __iomem		*regs;
 	int			rx_new, rx_old;
 	int			tx_new, tx_old;
 
 	unsigned int has_wol : 1;	/* chip supports wake-on-lan */
-	unsigned int asleep : 1;	/* chip asleep, protected by pm_mutex */
 	unsigned int asleep_wol : 1;	/* was asleep with WOL enabled */
-	unsigned int opened : 1;	/* driver opened, protected by pm_mutex */
-	unsigned int running : 1;	/* chip running, protected by lock */
 
 	/* cell enable count, protected by lock */
 	int			cell_enabled;
@@ -1033,20 +1029,4 @@ struct gem {
 #define found_mii_phy(gp) ((gp->phy_type == phy_mii_mdio0 || gp->phy_type == phy_mii_mdio1) && \
 			   gp->phy_mii.def && gp->phy_mii.def->ops)
 
-#define ALIGNED_RX_SKB_ADDR(addr) \
-        ((((unsigned long)(addr) + (64UL - 1UL)) & ~(64UL - 1UL)) - (unsigned long)(addr))
-static __inline__ struct sk_buff *gem_alloc_skb(int size,
-						gfp_t gfp_flags)
-{
-	struct sk_buff *skb = alloc_skb(size + 64, gfp_flags);
-
-	if (skb) {
-		int offset = (int) ALIGNED_RX_SKB_ADDR(skb->data);
-		if (offset)
-			skb_reserve(skb, offset);
-	}
-
-	return skb;
-}
-
 #endif /* _SUNGEM_H */


