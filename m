From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH]: was Re: LLTX and netif_stop_queue
Date: Wed, 19 Jan 2005 23:05:26 -0800
Message-ID: <20050119230526.393a5184.davem@davemloft.net>
References: <5cac192f0412230110628749e3@mail.gmail.com>
	<41CAF444.3000305@trash.net>
	<5cac192f04122408102129af43@mail.gmail.com>
	<1104240717.1100.66.camel@jzny.localdomain>
	<5cac192f0501021530672a908a@mail.gmail.com>
	<1104764660.1048.578.camel@jzny.localdomain>
	<52brc68q05.fsf@topspin.com>
	<5cac192f05010308414a25b548@mail.gmail.com>
	<527jmu8nbw.fsf@topspin.com>
	<5cac192f0501030907c755135@mail.gmail.com>
	<20050103171227.GD7370@esmail.cup.hp.com>
	<1104812294.1085.53.camel@jzny.localdomain>
	<20050119144711.3fdd3d93.davem@davemloft.net>
	<20050119151853.259de49a@dxpl.pdx.osdl.net>
	<20050119164640.6c67bdfa.davem@davemloft.net>
	<52r7kgu5n5.fsf@topspin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, eric.lemoine@gmail.com, hadi@cyberus.ca,
	ak@suse.de, openib-general@openib.org, kaber@trash.net,
	shemminger@osdl.org
Return-path: <openib-general-bounces@openib.org>
To: Roland Dreier <roland@topspin.com>
In-Reply-To: <52r7kgu5n5.fsf@topspin.com>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

On Wed, 19 Jan 2005 19:43:42 -0800
Roland Dreier <roland@topspin.com> wrote:

> Looks reasonable to me.  I'll try the IPoIB changes out to make sure
> it still works.

Great.

I actually tested my patch out, and there was a deadlock added
to the tg3 and sungem drivers which is fixed in this updated
version.

Basically, since the multicast code now takes dev->xmit_lock
the ->set_multicast_list() routines should not grab it
anymore.

To prevent ABBA deadlock, I had to remove the acquisition of
the usual priv->lock in tg3 and sungem multicast list settings.
Grabbing priv->lock was overkill and this new scheme of just
holding dev->xmit_lock is OK, because:

1) Messing with the RX mode and multicast hash is safe even
   in parallel with RX packet processing.

2) All code paths that want to shut up all chip programming
   code paths still take both dev->xmit_lock and priv->lock
   thus still able to block out ->set_multicast_list() processing.

So I'm going to check this in and push upstream.  Let me know
if folks find any other errors.

Thanks.

===== Documentation/networking/netdevices.txt 1.5 vs edited =====
--- 1.5/Documentation/networking/netdevices.txt	2004-09-12 16:55:06 -07:00
+++ edited/Documentation/networking/netdevices.txt	2005-01-19 16:09:50 -08:00
@@ -45,10 +45,9 @@
 	Synchronization: dev->xmit_lock spinlock.
 	When the driver sets NETIF_F_LLTX in dev->features this will be
 	called without holding xmit_lock. In this case the driver 
-	has to lock by itself when needed. It is recommended to use a try lock
-	for this and return -1 when the spin lock fails. 
-	The locking there should also properly protect against 
-	set_multicast_list
+	has to execute it's transmission routine in a completely lockless
+	manner.  It is recommended only for queueless devices such
+	loopback and tunnels.
 	Context: BHs disabled
 	Notes: netif_queue_stopped() is guaranteed false
 	Return codes: 
@@ -56,8 +55,6 @@
 	o NETDEV_TX_BUSY Cannot transmit packet, try later 
 	  Usually a bug, means queue start/stop flow control is broken in
 	  the driver. Note: the driver must NOT put the skb in its DMA ring.
-	o NETDEV_TX_LOCKED Locking failed, please retry quickly.
-	  Only valid when NETIF_F_LLTX is set.
 
 dev->tx_timeout:
 	Synchronization: dev->xmit_lock spinlock.
===== drivers/infiniband/ulp/ipoib/ipoib.h 1.3 vs edited =====
--- 1.3/drivers/infiniband/ulp/ipoib/ipoib.h	2005-01-15 14:01:50 -08:00
+++ edited/drivers/infiniband/ulp/ipoib/ipoib.h	2005-01-19 15:50:47 -08:00
@@ -104,10 +104,10 @@
 };
 
 /*
- * Device private locking: tx_lock protects members used in TX fast
- * path (and we use LLTX so upper layers don't do extra locking).
- * lock protects everything else.  lock nests inside of tx_lock (ie
- * tx_lock must be acquired first if needed).
+ * Device private locking: netdev->xmit_lock protects members used
+ * in TX fast path.
+ * lock protects everything else.  lock nests inside of xmit_lock (ie
+ * xmit_lock must be acquired first if needed).
  */
 struct ipoib_dev_priv {
 	spinlock_t lock;
@@ -150,7 +150,6 @@
 
 	struct ipoib_buf *rx_ring;
 
-	spinlock_t        tx_lock;
 	struct ipoib_buf *tx_ring;
 	unsigned          tx_head;
 	unsigned          tx_tail;
===== drivers/infiniband/ulp/ipoib/ipoib_ib.c 1.4 vs edited =====
--- 1.4/drivers/infiniband/ulp/ipoib/ipoib_ib.c	2005-01-15 14:01:50 -08:00
+++ edited/drivers/infiniband/ulp/ipoib/ipoib_ib.c	2005-01-19 15:51:36 -08:00
@@ -247,12 +247,12 @@
 
 		dev_kfree_skb_any(tx_req->skb);
 
-		spin_lock_irqsave(&priv->tx_lock, flags);
+		spin_lock_irqsave(&dev->xmit_lock, flags);
 		++priv->tx_tail;
 		if (netif_queue_stopped(dev) &&
 		    priv->tx_head - priv->tx_tail <= IPOIB_TX_RING_SIZE / 2)
 			netif_wake_queue(dev);
-		spin_unlock_irqrestore(&priv->tx_lock, flags);
+		spin_unlock_irqrestore(&dev->xmit_lock, flags);
 
 		if (wc->status != IB_WC_SUCCESS &&
 		    wc->status != IB_WC_WR_FLUSH_ERR)
===== drivers/infiniband/ulp/ipoib/ipoib_main.c 1.3 vs edited =====
--- 1.3/drivers/infiniband/ulp/ipoib/ipoib_main.c	2005-01-15 14:01:48 -08:00
+++ edited/drivers/infiniband/ulp/ipoib/ipoib_main.c	2005-01-19 15:53:27 -08:00
@@ -411,7 +411,7 @@
 
 	/*
 	 * We can only be called from ipoib_start_xmit, so we're
-	 * inside tx_lock -- no need to save/restore flags.
+	 * inside dev->xmit_lock -- no need to save/restore flags.
 	 */
 	spin_lock(&priv->lock);
 
@@ -483,7 +483,7 @@
 
 	/*
 	 * We can only be called from ipoib_start_xmit, so we're
-	 * inside tx_lock -- no need to save/restore flags.
+	 * inside dev->xmit_lock -- no need to save/restore flags.
 	 */
 	spin_lock(&priv->lock);
 
@@ -526,27 +526,11 @@
 	spin_unlock(&priv->lock);
 }
 
+/* Called with dev->xmit_lock held and IRQs disabled.  */
 static int ipoib_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ipoib_dev_priv *priv = netdev_priv(dev);
 	struct ipoib_neigh *neigh;
-	unsigned long flags;
-
-	local_irq_save(flags);
-	if (!spin_trylock(&priv->tx_lock)) {
-		local_irq_restore(flags);
-		return NETDEV_TX_LOCKED;
-	}
-
-	/*
-	 * Check if our queue is stopped.  Since we have the LLTX bit
-	 * set, we can't rely on netif_stop_queue() preventing our
-	 * xmit function from being called with a full queue.
-	 */
-	if (unlikely(netif_queue_stopped(dev))) {
-		spin_unlock_irqrestore(&priv->tx_lock, flags);
-		return NETDEV_TX_BUSY;
-	}
 
 	if (skb->dst && skb->dst->neighbour) {
 		if (unlikely(!*to_ipoib_neigh(skb->dst->neighbour))) {
@@ -601,7 +585,6 @@
 	}
 
 out:
-	spin_unlock_irqrestore(&priv->tx_lock, flags);
 
 	return NETDEV_TX_OK;
 }
@@ -797,7 +780,7 @@
 	dev->addr_len 		 = INFINIBAND_ALEN;
 	dev->type 		 = ARPHRD_INFINIBAND;
 	dev->tx_queue_len 	 = IPOIB_TX_RING_SIZE * 2;
-	dev->features            = NETIF_F_VLAN_CHALLENGED | NETIF_F_LLTX;
+	dev->features            = NETIF_F_VLAN_CHALLENGED;
 
 	/* MTU will be reset when mcast join happens */
 	dev->mtu 		 = IPOIB_PACKET_SIZE - IPOIB_ENCAP_LEN;
@@ -812,7 +795,6 @@
 	priv->dev = dev;
 
 	spin_lock_init(&priv->lock);
-	spin_lock_init(&priv->tx_lock);
 
 	init_MUTEX(&priv->mcast_mutex);
 	init_MUTEX(&priv->vlan_mutex);
===== drivers/net/sungem.c 1.72 vs edited =====
--- 1.72/drivers/net/sungem.c	2004-11-05 15:56:15 -08:00
+++ edited/drivers/net/sungem.c	2005-01-19 22:29:14 -08:00
@@ -835,9 +835,9 @@
 		}
 
 		/* Run TX completion thread */
-		spin_lock(&gp->tx_lock);
+		spin_lock(&dev->xmit_lock);
 		gem_tx(dev, gp, gp->status);
-		spin_unlock(&gp->tx_lock);
+		spin_unlock(&dev->xmit_lock);
 
 		spin_unlock_irqrestore(&gp->lock, flags);
 
@@ -932,12 +932,12 @@
 	       readl(gp->regs + MAC_RXCFG));
 
 	spin_lock_irq(&gp->lock);
-	spin_lock(&gp->tx_lock);
+	spin_lock(&dev->xmit_lock);
 
 	gp->reset_task_pending = 2;
 	schedule_work(&gp->reset_task);
 
-	spin_unlock(&gp->tx_lock);
+	spin_unlock(&dev->xmit_lock);
 	spin_unlock_irq(&gp->lock);
 }
 
@@ -955,7 +955,6 @@
 	struct gem *gp = dev->priv;
 	int entry;
 	u64 ctrl;
-	unsigned long flags;
 
 	ctrl = 0;
 	if (skb->ip_summed == CHECKSUM_HW) {
@@ -969,17 +968,9 @@
 			(csum_stuff_off << 21));
 	}
 
-	local_irq_save(flags);
-	if (!spin_trylock(&gp->tx_lock)) {
-		/* Tell upper layer to requeue */
-		local_irq_restore(flags);
-		return NETDEV_TX_LOCKED;
-	}
-
 	/* This is a hard error, log it. */
 	if (TX_BUFFS_AVAIL(gp) <= (skb_shinfo(skb)->nr_frags + 1)) {
 		netif_stop_queue(dev);
-		spin_unlock_irqrestore(&gp->tx_lock, flags);
 		printk(KERN_ERR PFX "%s: BUG! Tx Ring full when queue awake!\n",
 		       dev->name);
 		return NETDEV_TX_BUSY;
@@ -1066,7 +1057,6 @@
 		       dev->name, entry, skb->len);
 	mb();
 	writel(gp->tx_new, gp->regs + TXDMA_KICK);
-	spin_unlock_irqrestore(&gp->tx_lock, flags);
 
 	dev->trans_start = jiffies;
 
@@ -1097,11 +1087,11 @@
 	}
 
 	spin_lock_irq(&gp->lock);
-	spin_lock(&gp->tx_lock);
+	spin_lock(&dev->xmit_lock);
 	dev->mtu = new_mtu;
 	gp->reset_task_pending = 1;
 	schedule_work(&gp->reset_task);
-	spin_unlock(&gp->tx_lock);
+	spin_unlock(&dev->xmit_lock);
 	spin_unlock_irq(&gp->lock);
 
 	flush_scheduled_work();
@@ -1111,7 +1101,7 @@
 
 #define STOP_TRIES 32
 
-/* Must be invoked under gp->lock and gp->tx_lock. */
+/* Must be invoked under gp->lock and dev->xmit_lock. */
 static void gem_stop(struct gem *gp)
 {
 	int limit;
@@ -1137,7 +1127,7 @@
 		printk(KERN_ERR "%s: SW reset is ghetto.\n", gp->dev->name);
 }
 
-/* Must be invoked under gp->lock and gp->tx_lock. */
+/* Must be invoked under gp->lock and dev->xmit_lock. */
 static void gem_start_dma(struct gem *gp)
 {
 	unsigned long val;
@@ -1162,7 +1152,7 @@
 }
 
 
-/* Must be invoked under gp->lock and gp->tx_lock. */
+/* Must be invoked under gp->lock and dev->xmit_lock. */
 // XXX dbl check what that function should do when called on PCS PHY
 static void gem_begin_auto_negotiation(struct gem *gp, struct ethtool_cmd *ep)
 {
@@ -1249,7 +1239,7 @@
 /* A link-up condition has occurred, initialize and enable the
  * rest of the chip.
  *
- * Must be invoked under gp->lock and gp->tx_lock.
+ * Must be invoked under gp->lock and dev->xmit_lock.
  */
 static int gem_set_link_modes(struct gem *gp)
 {
@@ -1356,7 +1346,7 @@
 	return 0;
 }
 
-/* Must be invoked under gp->lock and gp->tx_lock. */
+/* Must be invoked under gp->lock and dev->xmit_lock. */
 static int gem_mdio_link_not_up(struct gem *gp)
 {
 	switch (gp->lstate) {
@@ -1414,7 +1404,7 @@
 
 	netif_poll_disable(gp->dev);
 	spin_lock_irq(&gp->lock);
-	spin_lock(&gp->tx_lock);
+	spin_lock(&gp->dev->xmit_lock);
 
 	if (gp->hw_running && gp->opened) {
 		netif_stop_queue(gp->dev);
@@ -1430,7 +1420,7 @@
 	}
 	gp->reset_task_pending = 0;
 
-	spin_unlock(&gp->tx_lock);
+	spin_unlock(&gp->dev->xmit_lock);
 	spin_unlock_irq(&gp->lock);
 	netif_poll_enable(gp->dev);
 }
@@ -1444,7 +1434,7 @@
 		return;
 
 	spin_lock_irq(&gp->lock);
-	spin_lock(&gp->tx_lock);
+	spin_lock(&gp->dev->xmit_lock);
 
 	/* If the link of task is still pending, we just
 	 * reschedule the link timer
@@ -1514,11 +1504,11 @@
 restart:
 	mod_timer(&gp->link_timer, jiffies + ((12 * HZ) / 10));
 out_unlock:
-	spin_unlock(&gp->tx_lock);
+	spin_unlock(&gp->dev->xmit_lock);
 	spin_unlock_irq(&gp->lock);
 }
 
-/* Must be invoked under gp->lock and gp->tx_lock. */
+/* Must be invoked under gp->lock and dev->xmit_lock. */
 static void gem_clean_rings(struct gem *gp)
 {
 	struct gem_init_block *gb = gp->init_block;
@@ -1569,7 +1559,7 @@
 	}
 }
 
-/* Must be invoked under gp->lock and gp->tx_lock. */
+/* Must be invoked under gp->lock and dev->xmit_lock. */
 static void gem_init_rings(struct gem *gp)
 {
 	struct gem_init_block *gb = gp->init_block;
@@ -1619,7 +1609,7 @@
 	wmb();
 }
 
-/* Must be invoked under gp->lock and gp->tx_lock. */
+/* Must be invoked under gp->lock and dev->xmit_lock. */
 static void gem_init_phy(struct gem *gp)
 {
 	u32 mifcfg;
@@ -1757,7 +1747,7 @@
 	}
 }
 
-/* Must be invoked under gp->lock and gp->tx_lock. */
+/* Must be invoked under gp->lock and dev->xmit_lock. */
 static void gem_init_dma(struct gem *gp)
 {
 	u64 desc_dma = (u64) gp->gblock_dvma;
@@ -1795,7 +1785,7 @@
 		       gp->regs + RXDMA_BLANK);
 }
 
-/* Must be invoked under gp->lock and gp->tx_lock. */
+/* Must be invoked under dev->xmit_lock. */
 static u32
 gem_setup_multicast(struct gem *gp)
 {
@@ -1838,7 +1828,7 @@
 	return rxcfg;
 }
 
-/* Must be invoked under gp->lock and gp->tx_lock. */
+/* Must be invoked under gp->lock and dev->xmit_lock. */
 static void gem_init_mac(struct gem *gp)
 {
 	unsigned char *e = &gp->dev->dev_addr[0];
@@ -1916,7 +1906,7 @@
 	writel(0xffffffff, gp->regs + MAC_MCMASK);
 }
 
-/* Must be invoked under gp->lock and gp->tx_lock. */
+/* Must be invoked under gp->lock and dev->xmit_lock. */
 static void gem_init_pause_thresholds(struct gem *gp)
 {
        	u32 cfg;
@@ -2052,7 +2042,7 @@
 	return 0;
 }
 
-/* Must be invoked under gp->lock and gp->tx_lock. */
+/* Must be invoked under gp->lock and dev->xmit_lock. */
 static void gem_init_hw(struct gem *gp, int restart_link)
 {
 	/* On Apple's gmac, I initialize the PHY only after
@@ -2150,11 +2140,11 @@
 
 	if (!gp->wake_on_lan) {
 		spin_lock_irqsave(&gp->lock, flags);
-		spin_lock(&gp->tx_lock);
+		spin_lock(&gp->dev->xmit_lock);
 		gem_stop(gp);
 		writel(MAC_TXRST_CMD, gp->regs + MAC_TXRST);
 		writel(MAC_RXRST_CMD, gp->regs + MAC_RXRST);
-		spin_unlock(&gp->tx_lock);
+		spin_unlock(&gp->dev->xmit_lock);
 		spin_unlock_irqrestore(&gp->lock, flags);
 	}
 
@@ -2202,9 +2192,9 @@
 		unsigned long flags;
 
 		spin_lock_irqsave(&gp->lock, flags);
-		spin_lock(&gp->tx_lock);
+		spin_lock(&gp->dev->xmit_lock);
 		gem_stop(gp);
-		spin_unlock(&gp->tx_lock);
+		spin_unlock(&gp->dev->xmit_lock);
 		spin_unlock_irqrestore(&gp->lock, flags);
 	}
 }
@@ -2265,9 +2255,9 @@
 
 		/* Reset the chip */
 		spin_lock_irq(&gp->lock);
-		spin_lock(&gp->tx_lock);
+		spin_lock(&gp->dev->xmit_lock);
 		gem_stop(gp);
-		spin_unlock(&gp->tx_lock);
+		spin_unlock(&gp->dev->xmit_lock);
 		spin_unlock_irq(&gp->lock);
 
 		gp->hw_running = 1;
@@ -2281,7 +2271,7 @@
 		printk(KERN_ERR "%s: failed to request irq !\n", gp->dev->name);
 
 		spin_lock_irq(&gp->lock);
-		spin_lock(&gp->tx_lock);
+		spin_lock(&gp->dev->xmit_lock);
 #ifdef CONFIG_PPC_PMAC
 		if (!hw_was_up && gp->pdev->vendor == PCI_VENDOR_ID_APPLE)
 			gem_apple_powerdown(gp);
@@ -2290,14 +2280,14 @@
 		gp->pm_timer.expires = jiffies + 10*HZ;
 		add_timer(&gp->pm_timer);
 		up(&gp->pm_sem);
-		spin_unlock(&gp->tx_lock);
+		spin_unlock(&gp->dev->xmit_lock);
 		spin_unlock_irq(&gp->lock);
 
 		return -EAGAIN;
 	}
 
        	spin_lock_irq(&gp->lock);
-	spin_lock(&gp->tx_lock);
+	spin_lock(&gp->dev->xmit_lock);
 
 	/* Allocate & setup ring buffers */
 	gem_init_rings(gp);
@@ -2307,7 +2297,7 @@
 
 	gp->opened = 1;
 
-	spin_unlock(&gp->tx_lock);
+	spin_unlock(&gp->dev->xmit_lock);
 	spin_unlock_irq(&gp->lock);
 
 	up(&gp->pm_sem);
@@ -2328,7 +2318,7 @@
 
 	/* Stop traffic, mark us closed */
 	spin_lock_irq(&gp->lock);
-	spin_lock(&gp->tx_lock);
+	spin_lock(&gp->dev->xmit_lock);
 
 	gp->opened = 0;	
 
@@ -2343,7 +2333,7 @@
 	/* Bye, the pm timer will finish the job */
 	free_irq(gp->pdev->irq, (void *) dev);
 
-	spin_unlock(&gp->tx_lock);
+	spin_unlock(&gp->dev->xmit_lock);
 	spin_unlock_irq(&gp->lock);
 
 	/* Fire the PM timer that will shut us down in about 10 seconds */
@@ -2374,7 +2364,7 @@
 	/* If the driver is opened, we stop the DMA */
 	if (gp->opened) {
 		spin_lock_irq(&gp->lock);
-		spin_lock(&gp->tx_lock);
+		spin_lock(&gp->dev->xmit_lock);
 
 		/* Stop traffic, mark us closed */
 		netif_device_detach(dev);
@@ -2385,7 +2375,7 @@
 		/* Get rid of ring buffers */
 		gem_clean_rings(gp);
 
-		spin_unlock(&gp->tx_lock);
+		spin_unlock(&gp->dev->xmit_lock);
 		spin_unlock_irq(&gp->lock);
 
 		if (gp->pdev->vendor == PCI_VENDOR_ID_APPLE)
@@ -2419,14 +2409,14 @@
 		}
 #endif /* CONFIG_PPC_PMAC */
 		spin_lock_irq(&gp->lock);
-		spin_lock(&gp->tx_lock);
+		spin_lock(&gp->dev->xmit_lock);
 
 		gem_stop(gp);
 		gp->hw_running = 1;
 		gem_init_rings(gp);
 		gem_init_hw(gp, 1);
 
-		spin_unlock(&gp->tx_lock);
+		spin_unlock(&gp->dev->xmit_lock);
 		spin_unlock_irq(&gp->lock);
 
 		netif_device_attach(dev);
@@ -2447,7 +2437,7 @@
 	struct net_device_stats *stats = &gp->net_stats;
 
 	spin_lock_irq(&gp->lock);
-	spin_lock(&gp->tx_lock);
+	spin_lock(&dev->xmit_lock);
 
 	if (gp->hw_running) {
 		stats->rx_crc_errors += readl(gp->regs + MAC_FCSERR);
@@ -2467,12 +2457,13 @@
 		writel(0, gp->regs + MAC_LCOLL);
 	}
 
-	spin_unlock(&gp->tx_lock);
+	spin_unlock(&dev->xmit_lock);
 	spin_unlock_irq(&gp->lock);
 
 	return &gp->net_stats;
 }
 
+/* Called with dev->xmit_lock held and IRQs disabled.  */
 static void gem_set_multicast(struct net_device *dev)
 {
 	struct gem *gp = dev->priv;
@@ -2482,9 +2473,6 @@
 	if (!gp->hw_running)
 		return;
 		
-	spin_lock_irq(&gp->lock);
-	spin_lock(&gp->tx_lock);
-
 	netif_stop_queue(dev);
 
 	rxcfg = readl(gp->regs + MAC_RXCFG);
@@ -2507,9 +2495,6 @@
 	writel(rxcfg, gp->regs + MAC_RXCFG);
 
 	netif_wake_queue(dev);
-
-	spin_unlock(&gp->tx_lock);
-	spin_unlock_irq(&gp->lock);
 }
 
 static void gem_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
@@ -2540,7 +2525,7 @@
 
 		/* Return current PHY settings */
 		spin_lock_irq(&gp->lock);
-		spin_lock(&gp->tx_lock);
+		spin_lock(&dev->xmit_lock);
 		cmd->autoneg = gp->want_autoneg;
 		cmd->speed = gp->phy_mii.speed;
 		cmd->duplex = gp->phy_mii.duplex;			
@@ -2552,7 +2537,7 @@
 		 */
 		if (cmd->advertising == 0)
 			cmd->advertising = cmd->supported;
-		spin_unlock(&gp->tx_lock);
+		spin_unlock(&dev->xmit_lock);
 		spin_unlock_irq(&gp->lock);
 	} else { // XXX PCS ?
 		cmd->supported =
@@ -2592,9 +2577,9 @@
 	      
 	/* Apply settings and restart link process. */
 	spin_lock_irq(&gp->lock);
-	spin_lock(&gp->tx_lock);
+	spin_lock(&dev->xmit_lock);
 	gem_begin_auto_negotiation(gp, cmd);
-	spin_unlock(&gp->tx_lock);
+	spin_unlock(&dev->xmit_lock);
 	spin_unlock_irq(&gp->lock);
 
 	return 0;
@@ -2609,9 +2594,9 @@
 
 	/* Restart link process. */
 	spin_lock_irq(&gp->lock);
-	spin_lock(&gp->tx_lock);
+	spin_lock(&dev->xmit_lock);
 	gem_begin_auto_negotiation(gp, NULL);
-	spin_unlock(&gp->tx_lock);
+	spin_unlock(&dev->xmit_lock);
 	spin_unlock_irq(&gp->lock);
 
 	return 0;
@@ -2863,7 +2848,6 @@
 	gp->msg_enable = DEFAULT_MSG;
 
 	spin_lock_init(&gp->lock);
-	spin_lock_init(&gp->tx_lock);
 	init_MUTEX(&gp->pm_sem);
 
 	init_timer(&gp->link_timer);
@@ -2899,9 +2883,9 @@
 		gem_apple_powerup(gp);
 #endif
 	spin_lock_irq(&gp->lock);
-	spin_lock(&gp->tx_lock);
+	spin_lock(&dev->xmit_lock);
 	gem_stop(gp);
-	spin_unlock(&gp->tx_lock);
+	spin_unlock(&dev->xmit_lock);
 	spin_unlock_irq(&gp->lock);
 
 	/* Fill up the mii_phy structure (even if we won't use it) */
@@ -2967,11 +2951,11 @@
 
 	/* Detect & init PHY, start autoneg */
 	spin_lock_irq(&gp->lock);
-	spin_lock(&gp->tx_lock);
+	spin_lock(&dev->xmit_lock);
 	gp->hw_running = 1;
 	gem_init_phy(gp);
 	gem_begin_auto_negotiation(gp, NULL);
-	spin_unlock(&gp->tx_lock);
+	spin_unlock(&dev->xmit_lock);
 	spin_unlock_irq(&gp->lock);
 
 	if (gp->phy_type == phy_mii_mdio0 ||
@@ -2982,7 +2966,7 @@
 	pci_set_drvdata(pdev, dev);
 
 	/* GEM can do it all... */
-	dev->features |= NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_LLTX;
+	dev->features |= NETIF_F_SG | NETIF_F_HW_CSUM;
 	if (pci_using_dac)
 		dev->features |= NETIF_F_HIGHDMA;
 
===== drivers/net/sungem.h 1.18 vs edited =====
--- 1.18/drivers/net/sungem.h	2004-09-15 08:16:05 -07:00
+++ edited/drivers/net/sungem.h	2005-01-19 15:54:08 -08:00
@@ -953,7 +953,6 @@
 
 struct gem {
 	spinlock_t lock;
-	spinlock_t tx_lock;
 	void __iomem *regs;
 	int rx_new, rx_old;
 	int tx_new, tx_old;
===== drivers/net/tg3.c 1.227 vs edited =====
--- 1.227/drivers/net/tg3.c	2005-01-17 13:40:31 -08:00
+++ edited/drivers/net/tg3.c	2005-01-19 16:41:08 -08:00
@@ -2816,9 +2816,9 @@
 
 	/* run TX completion thread */
 	if (sblk->idx[0].tx_consumer != tp->tx_cons) {
-		spin_lock(&tp->tx_lock);
+		spin_lock(&netdev->xmit_lock);
 		tg3_tx(tp);
-		spin_unlock(&tp->tx_lock);
+		spin_unlock(&netdev->xmit_lock);
 	}
 
 	spin_unlock_irqrestore(&tp->lock, flags);
@@ -2939,7 +2939,7 @@
 	tg3_netif_stop(tp);
 
 	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+	spin_lock(&tp->dev->xmit_lock);
 
 	restart_timer = tp->tg3_flags2 & TG3_FLG2_RESTART_TIMER;
 	tp->tg3_flags2 &= ~TG3_FLG2_RESTART_TIMER;
@@ -2949,7 +2949,7 @@
 
 	tg3_netif_start(tp);
 
-	spin_unlock(&tp->tx_lock);
+	spin_unlock(&tp->dev->xmit_lock);
 	spin_unlock_irq(&tp->lock);
 
 	if (restart_timer)
@@ -3048,6 +3048,7 @@
 		(base + len + 8 < base));
 }
 
+/* dev->xmit_lock is held and IRQs are disabled.  */
 static int tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct tg3 *tp = netdev_priv(dev);
@@ -3055,39 +3056,12 @@
 	unsigned int i;
 	u32 len, entry, base_flags, mss;
 	int would_hit_hwbug;
-	unsigned long flags;
 
 	len = skb_headlen(skb);
 
-	/* No BH disabling for tx_lock here.  We are running in BH disabled
-	 * context and TX reclaim runs via tp->poll inside of a software
-	 * interrupt.  Rejoice!
-	 *
-	 * Actually, things are not so simple.  If we are to take a hw
-	 * IRQ here, we can deadlock, consider:
-	 *
-	 *       CPU1		CPU2
-	 *   tg3_start_xmit
-	 *   take tp->tx_lock
-	 *			tg3_timer
-	 *			take tp->lock
-	 *   tg3_interrupt
-	 *   spin on tp->lock
-	 *			spin on tp->tx_lock
-	 *
-	 * So we really do need to disable interrupts when taking
-	 * tx_lock here.
-	 */
-	local_irq_save(flags);
-	if (!spin_trylock(&tp->tx_lock)) { 
-		local_irq_restore(flags);
-		return NETDEV_TX_LOCKED; 
-	} 
-
 	/* This is a hard error, log it. */
 	if (unlikely(TX_BUFFS_AVAIL(tp) <= (skb_shinfo(skb)->nr_frags + 1))) {
 		netif_stop_queue(dev);
-		spin_unlock_irqrestore(&tp->tx_lock, flags);
 		printk(KERN_ERR PFX "%s: BUG! Tx Ring full when queue awake!\n",
 		       dev->name);
 		return NETDEV_TX_BUSY;
@@ -3224,7 +3198,7 @@
 						entry, len,
 						last_plus_one,
 						&start, mss))
-			goto out_unlock;
+			goto out;
 
 		entry = start;
 	}
@@ -3236,9 +3210,8 @@
 	if (TX_BUFFS_AVAIL(tp) <= (MAX_SKB_FRAGS + 1))
 		netif_stop_queue(dev);
 
-out_unlock:
+out:
     	mmiowb();
-	spin_unlock_irqrestore(&tp->tx_lock, flags);
 
 	dev->trans_start = jiffies;
 
@@ -3273,7 +3246,7 @@
 
 	tg3_netif_stop(tp);
 	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+	spin_lock(&dev->xmit_lock);
 
 	tg3_halt(tp);
 
@@ -3283,7 +3256,7 @@
 
 	tg3_netif_start(tp);
 
-	spin_unlock(&tp->tx_lock);
+	spin_unlock(&dev->xmit_lock);
 	spin_unlock_irq(&tp->lock);
 
 	return 0;
@@ -5574,7 +5547,7 @@
 	unsigned long flags;
 
 	spin_lock_irqsave(&tp->lock, flags);
-	spin_lock(&tp->tx_lock);
+	spin_lock(&tp->dev->xmit_lock);
 
 	/* All of this garbage is because when using non-tagged
 	 * IRQ status the mailbox/status_block protocol the chip
@@ -5590,7 +5563,7 @@
 
 	if (!(tr32(WDMAC_MODE) & WDMAC_MODE_ENABLE)) {
 		tp->tg3_flags2 |= TG3_FLG2_RESTART_TIMER;
-		spin_unlock(&tp->tx_lock);
+		spin_unlock(&tp->dev->xmit_lock);
 		spin_unlock_irqrestore(&tp->lock, flags);
 		schedule_work(&tp->reset_task);
 		return;
@@ -5659,7 +5632,7 @@
 		tp->asf_counter = tp->asf_multiplier;
 	}
 
-	spin_unlock(&tp->tx_lock);
+	spin_unlock(&tp->dev->xmit_lock);
 	spin_unlock_irqrestore(&tp->lock, flags);
 
 	tp->timer.expires = jiffies + tp->timer_offset;
@@ -5672,12 +5645,12 @@
 	int err;
 
 	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+	spin_lock(&dev->xmit_lock);
 
 	tg3_disable_ints(tp);
 	tp->tg3_flags &= ~TG3_FLAG_INIT_COMPLETE;
 
-	spin_unlock(&tp->tx_lock);
+	spin_unlock(&dev->xmit_lock);
 	spin_unlock_irq(&tp->lock);
 
 	/* The placement of this call is tied
@@ -5696,7 +5669,7 @@
 	}
 
 	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+	spin_lock(&dev->xmit_lock);
 
 	err = tg3_init_hw(tp);
 	if (err) {
@@ -5716,7 +5689,7 @@
 		tp->tg3_flags |= TG3_FLAG_INIT_COMPLETE;
 	}
 
-	spin_unlock(&tp->tx_lock);
+	spin_unlock(&dev->xmit_lock);
 	spin_unlock_irq(&tp->lock);
 
 	if (err) {
@@ -5726,11 +5699,11 @@
 	}
 
 	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+	spin_lock(&dev->xmit_lock);
 
 	tg3_enable_ints(tp);
 
-	spin_unlock(&tp->tx_lock);
+	spin_unlock(&dev->xmit_lock);
 	spin_unlock_irq(&tp->lock);
 
 	netif_start_queue(dev);
@@ -5978,7 +5951,7 @@
 	del_timer_sync(&tp->timer);
 
 	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+	spin_lock(&dev->xmit_lock);
 #if 0
 	tg3_dump_state(tp);
 #endif
@@ -5992,7 +5965,7 @@
 		  TG3_FLAG_GOT_SERDES_FLOWCTL);
 	netif_carrier_off(tp->dev);
 
-	spin_unlock(&tp->tx_lock);
+	spin_unlock(&dev->xmit_lock);
 	spin_unlock_irq(&tp->lock);
 
 	free_irq(dev->irq, dev);
@@ -6291,15 +6264,10 @@
 	}
 }
 
+/* Called with dev->xmit_lock held and IRQs disabled.  */
 static void tg3_set_rx_mode(struct net_device *dev)
 {
-	struct tg3 *tp = netdev_priv(dev);
-
-	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
 	__tg3_set_rx_mode(dev);
-	spin_unlock(&tp->tx_lock);
-	spin_unlock_irq(&tp->lock);
 }
 
 #define TG3_REGDUMP_LEN		(32 * 1024)
@@ -6322,7 +6290,7 @@
 	memset(p, 0, TG3_REGDUMP_LEN);
 
 	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+	spin_lock(&dev->xmit_lock);
 
 #define __GET_REG32(reg)	(*(p)++ = tr32(reg))
 #define GET_REG32_LOOP(base,len)		\
@@ -6372,7 +6340,7 @@
 #undef GET_REG32_LOOP
 #undef GET_REG32_1
 
-	spin_unlock(&tp->tx_lock);
+	spin_unlock(&dev->xmit_lock);
 	spin_unlock_irq(&tp->lock);
 }
 
@@ -6496,7 +6464,7 @@
 	}
 
 	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+	spin_lock(&dev->xmit_lock);
 
 	tp->link_config.autoneg = cmd->autoneg;
 	if (cmd->autoneg == AUTONEG_ENABLE) {
@@ -6510,7 +6478,7 @@
   	}
   
 	tg3_setup_phy(tp, 1);
-	spin_unlock(&tp->tx_lock);
+	spin_unlock(&dev->xmit_lock);
 	spin_unlock_irq(&tp->lock);
   
 	return 0;
@@ -6627,7 +6595,7 @@
   
 	tg3_netif_stop(tp);
 	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+	spin_lock(&dev->xmit_lock);
   
 	tp->rx_pending = ering->rx_pending;
 
@@ -6640,7 +6608,7 @@
 	tg3_halt(tp);
 	tg3_init_hw(tp);
 	tg3_netif_start(tp);
-	spin_unlock(&tp->tx_lock);
+	spin_unlock(&dev->xmit_lock);
 	spin_unlock_irq(&tp->lock);
   
 	return 0;
@@ -6661,7 +6629,7 @@
   
 	tg3_netif_stop(tp);
 	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+	spin_lock(&dev->xmit_lock);
 	if (epause->autoneg)
 		tp->tg3_flags |= TG3_FLAG_PAUSE_AUTONEG;
 	else
@@ -6677,7 +6645,7 @@
 	tg3_halt(tp);
 	tg3_init_hw(tp);
 	tg3_netif_start(tp);
-	spin_unlock(&tp->tx_lock);
+	spin_unlock(&dev->xmit_lock);
 	spin_unlock_irq(&tp->lock);
   
 	return 0;
@@ -6803,14 +6771,14 @@
 	struct tg3 *tp = netdev_priv(dev);
 
 	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+	spin_lock(&dev->xmit_lock);
 
 	tp->vlgrp = grp;
 
 	/* Update RX_MODE_KEEP_VLAN_TAG bit in RX_MODE register. */
 	__tg3_set_rx_mode(dev);
 
-	spin_unlock(&tp->tx_lock);
+	spin_unlock(&dev->xmit_lock);
 	spin_unlock_irq(&tp->lock);
 }
 
@@ -6819,10 +6787,10 @@
 	struct tg3 *tp = netdev_priv(dev);
 
 	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+	spin_lock(&dev->xmit_lock);
 	if (tp->vlgrp)
 		tp->vlgrp->vlan_devices[vid] = NULL;
-	spin_unlock(&tp->tx_lock);
+	spin_unlock(&dev->xmit_lock);
 	spin_unlock_irq(&tp->lock);
 }
 #endif
@@ -8241,7 +8209,6 @@
 
 	if (pci_using_dac)
 		dev->features |= NETIF_F_HIGHDMA;
-	dev->features |= NETIF_F_LLTX;
 #if TG3_VLAN_TAG_USED
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
 	dev->vlan_rx_register = tg3_vlan_rx_register;
@@ -8283,7 +8250,6 @@
 	tp->grc_mode |= GRC_MODE_BSWAP_NONFRM_DATA;
 #endif
 	spin_lock_init(&tp->lock);
-	spin_lock_init(&tp->tx_lock);
 	spin_lock_init(&tp->indirect_lock);
 	INIT_WORK(&tp->reset_task, tg3_reset_task, tp);
 
@@ -8496,23 +8462,23 @@
 	del_timer_sync(&tp->timer);
 
 	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+	spin_lock(&dev->xmit_lock);
 	tg3_disable_ints(tp);
-	spin_unlock(&tp->tx_lock);
+	spin_unlock(&dev->xmit_lock);
 	spin_unlock_irq(&tp->lock);
 
 	netif_device_detach(dev);
 
 	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+	spin_lock(&dev->xmit_lock);
 	tg3_halt(tp);
-	spin_unlock(&tp->tx_lock);
+	spin_unlock(&dev->xmit_lock);
 	spin_unlock_irq(&tp->lock);
 
 	err = tg3_set_power_state(tp, state);
 	if (err) {
 		spin_lock_irq(&tp->lock);
-		spin_lock(&tp->tx_lock);
+		spin_lock(&dev->xmit_lock);
 
 		tg3_init_hw(tp);
 
@@ -8522,7 +8488,7 @@
 		netif_device_attach(dev);
 		tg3_netif_start(tp);
 
-		spin_unlock(&tp->tx_lock);
+		spin_unlock(&dev->xmit_lock);
 		spin_unlock_irq(&tp->lock);
 	}
 
@@ -8547,7 +8513,7 @@
 	netif_device_attach(dev);
 
 	spin_lock_irq(&tp->lock);
-	spin_lock(&tp->tx_lock);
+	spin_lock(&dev->xmit_lock);
 
 	tg3_init_hw(tp);
 
@@ -8558,7 +8524,7 @@
 
 	tg3_netif_start(tp);
 
-	spin_unlock(&tp->tx_lock);
+	spin_unlock(&dev->xmit_lock);
 	spin_unlock_irq(&tp->lock);
 
 	return 0;
===== drivers/net/tg3.h 1.52 vs edited =====
--- 1.52/drivers/net/tg3.h	2004-11-15 15:41:31 -08:00
+++ edited/drivers/net/tg3.h	2005-01-19 15:37:29 -08:00
@@ -1980,12 +1980,11 @@
 	 * lock: Held during all operations except TX packet
 	 *       processing.
 	 *
-	 * tx_lock: Held during tg3_start_xmit{,_4gbug} and tg3_tx
+	 * dev->xmit_lock: Held during tg3_start_xmit and tg3_tx
 	 *
 	 * If you want to shut up all asynchronous processing you must
-	 * acquire both locks, 'lock' taken before 'tx_lock'.  IRQs must
-	 * be disabled to take 'lock' but only softirq disabling is
-	 * necessary for acquisition of 'tx_lock'.
+	 * acquire both locks, 'lock' taken before 'xmit_lock'.  IRQs must
+	 * be disabled to take either lock.
 	 */
 	spinlock_t			lock;
 	spinlock_t			indirect_lock;
@@ -2003,8 +2002,6 @@
 	u32				tx_prod;
 	u32				tx_cons;
 	u32				tx_pending;
-
-	spinlock_t			tx_lock;
 
 	struct tg3_tx_buffer_desc	*tx_ring;
 	struct tx_ring_info		*tx_buffers;
===== drivers/net/e1000/e1000.h 1.58 vs edited =====
--- 1.58/drivers/net/e1000/e1000.h	2004-10-25 18:13:57 -07:00
+++ edited/drivers/net/e1000/e1000.h	2005-01-19 15:45:31 -08:00
@@ -209,7 +209,6 @@
 
 	/* TX */
 	struct e1000_desc_ring tx_ring;
-	spinlock_t tx_lock;
 	uint32_t txd_cmd;
 	uint32_t tx_int_delay;
 	uint32_t tx_abs_int_delay;
===== drivers/net/e1000/e1000_main.c 1.145 vs edited =====
--- 1.145/drivers/net/e1000/e1000_main.c	2005-01-10 21:03:21 -08:00
+++ edited/drivers/net/e1000/e1000_main.c	2005-01-19 16:37:55 -08:00
@@ -291,7 +291,9 @@
 			e1000_phy_reset(&adapter->hw);
 	}
 
+	spin_lock_irq(&netdev->xmit_lock);
 	e1000_set_multi(netdev);
+	spin_unlock_irq(&netdev->xmit_lock);
 
 	e1000_restore_vlan(adapter);
 
@@ -520,9 +522,6 @@
 	if(pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
 
- 	/* hard_start_xmit is safe against parallel locking */
- 	netdev->features |= NETIF_F_LLTX; 
- 
 	/* before reading the EEPROM, reset the controller to 
 	 * put the device in a known good starting state */
 	
@@ -732,7 +731,6 @@
 
 	atomic_set(&adapter->irq_sem, 1);
 	spin_lock_init(&adapter->stats_lock);
-	spin_lock_init(&adapter->tx_lock);
 
 	return 0;
 }
@@ -1293,6 +1291,8 @@
  * list or the network interface flags are updated.  This routine is
  * responsible for configuring the hardware for proper multicast,
  * promiscuous mode, and all-multi behavior.
+ *
+ * Called with netdev->xmit_lock held and IRQs disabled.
  **/
 
 static void
@@ -1304,12 +1304,9 @@
 	uint32_t rctl;
 	uint32_t hash_value;
 	int i;
-	unsigned long flags;
 
 	/* Check for Promiscuous and All Multicast modes */
 
-	spin_lock_irqsave(&adapter->tx_lock, flags);
-
 	rctl = E1000_READ_REG(hw, RCTL);
 
 	if(netdev->flags & IFF_PROMISC) {
@@ -1358,8 +1355,6 @@
 
 	if(hw->mac_type == e1000_82542_rev2_0)
 		e1000_leave_82542_rst(adapter);
-
-	spin_unlock_irqrestore(&adapter->tx_lock, flags);
 }
 
 /* Need to wait a few seconds after link up to get diagnostic information from
@@ -1786,6 +1781,8 @@
 }
 
 #define TXD_USE_COUNT(S, X) (((S) >> (X)) + 1 )
+
+/* Called with dev->xmit_lock held and interrupts disabled.  */
 static int
 e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 {
@@ -1794,7 +1791,6 @@
 	unsigned int max_txd_pwr = E1000_MAX_TXD_PWR;
 	unsigned int tx_flags = 0;
 	unsigned int len = skb->len;
-	unsigned long flags;
 	unsigned int nr_frags = 0;
 	unsigned int mss = 0;
 	int count = 0;
@@ -1838,18 +1834,10 @@
 	if(adapter->pcix_82544)
 		count += nr_frags;
 
- 	local_irq_save(flags); 
- 	if (!spin_trylock(&adapter->tx_lock)) { 
- 		/* Collision - tell upper layer to requeue */ 
- 		local_irq_restore(flags); 
- 		return NETDEV_TX_LOCKED; 
- 	} 
-
 	/* need: count + 2 desc gap to keep tail from touching
 	 * head, otherwise try next time */
 	if(unlikely(E1000_DESC_UNUSED(&adapter->tx_ring) < count + 2)) {
 		netif_stop_queue(netdev);
-		spin_unlock_irqrestore(&adapter->tx_lock, flags);
 		return NETDEV_TX_BUSY;
 	}
 
@@ -1857,7 +1845,6 @@
 		if(unlikely(e1000_82547_fifo_workaround(adapter, skb))) {
 			netif_stop_queue(netdev);
 			mod_timer(&adapter->tx_fifo_stall_timer, jiffies);
-			spin_unlock_irqrestore(&adapter->tx_lock, flags);
 			return NETDEV_TX_BUSY;
 		}
 	}
@@ -1884,7 +1871,6 @@
 	if(unlikely(E1000_DESC_UNUSED(&adapter->tx_ring) < MAX_SKB_FRAGS + 2))
 		netif_stop_queue(netdev);
 
-	spin_unlock_irqrestore(&adapter->tx_lock, flags);
 	return NETDEV_TX_OK;
 }
 
@@ -2234,13 +2220,13 @@
 
 	tx_ring->next_to_clean = i;
 
-	spin_lock(&adapter->tx_lock);
+	spin_lock(&netdev->xmit_lock);
 
 	if(unlikely(cleaned && netif_queue_stopped(netdev) &&
 		    netif_carrier_ok(netdev)))
 		netif_wake_queue(netdev);
 
-	spin_unlock(&adapter->tx_lock);
+	spin_unlock(&netdev->xmit_lock);
 
 	return cleaned;
 }
@@ -2819,7 +2805,10 @@
 
 	if(wufc) {
 		e1000_setup_rctl(adapter);
+
+		spin_lock_irq(&netdev->xmit_lock);
 		e1000_set_multi(netdev);
+		spin_unlock_irq(&netdev->xmit_lock);
 
 		/* turn on all-multi mode if wake on multicast is enabled */
 		if(adapter->wol & E1000_WUFC_MC) {
===== include/linux/netdevice.h 1.96 vs edited =====
--- 1.96/include/linux/netdevice.h	2005-01-17 13:13:31 -08:00
+++ edited/include/linux/netdevice.h	2005-01-19 16:07:45 -08:00
@@ -76,7 +76,6 @@
 /* Driver transmit return codes */
 #define NETDEV_TX_OK 0		/* driver took care of packet */
 #define NETDEV_TX_BUSY 1	/* driver tx path was busy*/
-#define NETDEV_TX_LOCKED -1	/* driver tx lock was already taken */
 
 /*
  *	Compute the worst case header length according to the protocols
@@ -415,7 +414,7 @@
 #define NETIF_F_HW_VLAN_FILTER	512	/* Receive filtering on VLAN */
 #define NETIF_F_VLAN_CHALLENGED	1024	/* Device cannot handle VLAN packets */
 #define NETIF_F_TSO		2048	/* Can offload TCP/IP segmentation */
-#define NETIF_F_LLTX		4096	/* LockLess TX */
+#define NETIF_F_LLTX		4096	/* Do not grab xmit_lock during ->hard_start_xmit */
 
 	/* Called after device is detached from network. */
 	void			(*uninit)(struct net_device *dev);
@@ -894,9 +893,11 @@
 
 static inline void netif_tx_disable(struct net_device *dev)
 {
-	spin_lock_bh(&dev->xmit_lock);
+	unsigned long flags;
+
+	spin_lock_irqsave(&dev->xmit_lock, flags);
 	netif_stop_queue(dev);
-	spin_unlock_bh(&dev->xmit_lock);
+	spin_unlock_irqrestore(&dev->xmit_lock, flags);
 }
 
 /* These functions live elsewhere (drivers/net/net_init.c, but related) */
===== net/atm/clip.c 1.43 vs edited =====
--- 1.43/net/atm/clip.c	2004-10-01 14:50:07 -07:00
+++ edited/net/atm/clip.c	2005-01-19 16:04:55 -08:00
@@ -97,7 +97,7 @@
 		printk(KERN_CRIT "!clip_vcc->entry (clip_vcc %p)\n",clip_vcc);
 		return;
 	}
-	spin_lock_bh(&entry->neigh->dev->xmit_lock);	/* block clip_start_xmit() */
+	spin_lock_irq(&entry->neigh->dev->xmit_lock);	/* block clip_start_xmit() */
 	entry->neigh->used = jiffies;
 	for (walk = &entry->vccs; *walk; walk = &(*walk)->next)
 		if (*walk == clip_vcc) {
@@ -121,7 +121,7 @@
 	printk(KERN_CRIT "ATMARP: unlink_clip_vcc failed (entry %p, vcc "
 	  "0x%p)\n",entry,clip_vcc);
 out:
-	spin_unlock_bh(&entry->neigh->dev->xmit_lock);
+	spin_unlock_irq(&entry->neigh->dev->xmit_lock);
 }
 
 /* The neighbour entry n->lock is held. */
===== net/core/dev.c 1.181 vs edited =====
--- 1.181/net/core/dev.c	2005-01-13 20:41:04 -08:00
+++ edited/net/core/dev.c	2005-01-19 16:00:08 -08:00
@@ -1190,7 +1190,7 @@
 
 #define HARD_TX_LOCK(dev, cpu) {			\
 	if ((dev->features & NETIF_F_LLTX) == 0) {	\
-		spin_lock(&dev->xmit_lock);		\
+		spin_lock_irq(&dev->xmit_lock);		\
 		dev->xmit_lock_owner = cpu;		\
 	}						\
 }
@@ -1198,7 +1198,7 @@
 #define HARD_TX_UNLOCK(dev) {				\
 	if ((dev->features & NETIF_F_LLTX) == 0) {	\
 		dev->xmit_lock_owner = -1;		\
-		spin_unlock(&dev->xmit_lock);		\
+		spin_unlock_irq(&dev->xmit_lock);	\
 	}						\
 }
 
===== net/core/dev_mcast.c 1.4 vs edited =====
--- 1.4/net/core/dev_mcast.c	2004-10-20 01:37:15 -07:00
+++ edited/net/core/dev_mcast.c	2005-01-19 16:05:35 -08:00
@@ -93,9 +93,9 @@
 
 void dev_mc_upload(struct net_device *dev)
 {
-	spin_lock_bh(&dev->xmit_lock);
+	spin_lock_irq(&dev->xmit_lock);
 	__dev_mc_upload(dev);
-	spin_unlock_bh(&dev->xmit_lock);
+	spin_unlock_irq(&dev->xmit_lock);
 }
 
 /*
@@ -107,7 +107,7 @@
 	int err = 0;
 	struct dev_mc_list *dmi, **dmip;
 
-	spin_lock_bh(&dev->xmit_lock);
+	spin_lock_irq(&dev->xmit_lock);
 
 	for (dmip = &dev->mc_list; (dmi = *dmip) != NULL; dmip = &dmi->next) {
 		/*
@@ -139,13 +139,13 @@
 			 */
 			__dev_mc_upload(dev);
 			
-			spin_unlock_bh(&dev->xmit_lock);
+			spin_unlock_irq(&dev->xmit_lock);
 			return 0;
 		}
 	}
 	err = -ENOENT;
 done:
-	spin_unlock_bh(&dev->xmit_lock);
+	spin_unlock_irq(&dev->xmit_lock);
 	return err;
 }
 
@@ -160,7 +160,7 @@
 
 	dmi1 = (struct dev_mc_list *)kmalloc(sizeof(*dmi), GFP_ATOMIC);
 
-	spin_lock_bh(&dev->xmit_lock);
+	spin_lock_irq(&dev->xmit_lock);
 	for (dmi = dev->mc_list; dmi != NULL; dmi = dmi->next) {
 		if (memcmp(dmi->dmi_addr, addr, dmi->dmi_addrlen) == 0 &&
 		    dmi->dmi_addrlen == alen) {
@@ -176,7 +176,7 @@
 	}
 
 	if ((dmi = dmi1) == NULL) {
-		spin_unlock_bh(&dev->xmit_lock);
+		spin_unlock_irq(&dev->xmit_lock);
 		return -ENOMEM;
 	}
 	memcpy(dmi->dmi_addr, addr, alen);
@@ -189,11 +189,11 @@
 
 	__dev_mc_upload(dev);
 	
-	spin_unlock_bh(&dev->xmit_lock);
+	spin_unlock_irq(&dev->xmit_lock);
 	return 0;
 
 done:
-	spin_unlock_bh(&dev->xmit_lock);
+	spin_unlock_irq(&dev->xmit_lock);
 	if (dmi1)
 		kfree(dmi1);
 	return err;
@@ -205,7 +205,7 @@
 
 void dev_mc_discard(struct net_device *dev)
 {
-	spin_lock_bh(&dev->xmit_lock);
+	spin_lock_irq(&dev->xmit_lock);
 	
 	while (dev->mc_list != NULL) {
 		struct dev_mc_list *tmp = dev->mc_list;
@@ -216,7 +216,7 @@
 	}
 	dev->mc_count = 0;
 
-	spin_unlock_bh(&dev->xmit_lock);
+	spin_unlock_irq(&dev->xmit_lock);
 }
 
 #ifdef CONFIG_PROC_FS
@@ -251,7 +251,7 @@
 	struct dev_mc_list *m;
 	struct net_device *dev = v;
 
-	spin_lock_bh(&dev->xmit_lock);
+	spin_lock_irq(&dev->xmit_lock);
 	for (m = dev->mc_list; m; m = m->next) {
 		int i;
 
@@ -263,7 +263,7 @@
 
 		seq_putc(seq, '\n');
 	}
-	spin_unlock_bh(&dev->xmit_lock);
+	spin_unlock_irq(&dev->xmit_lock);
 	return 0;
 }
 
===== net/core/netpoll.c 1.24 vs edited =====
--- 1.24/net/core/netpoll.c	2005-01-13 20:41:04 -08:00
+++ edited/net/core/netpoll.c	2005-01-19 16:05:56 -08:00
@@ -188,7 +188,7 @@
 		return;
 	}
 
-	spin_lock(&np->dev->xmit_lock);
+	spin_lock_irq(&np->dev->xmit_lock);
 	np->dev->xmit_lock_owner = smp_processor_id();
 
 	/*
@@ -197,7 +197,7 @@
 	 */
 	if (netif_queue_stopped(np->dev)) {
 		np->dev->xmit_lock_owner = -1;
-		spin_unlock(&np->dev->xmit_lock);
+		spin_unlock_irq(&np->dev->xmit_lock);
 
 		netpoll_poll(np);
 		goto repeat;
@@ -205,7 +205,7 @@
 
 	status = np->dev->hard_start_xmit(skb, np->dev);
 	np->dev->xmit_lock_owner = -1;
-	spin_unlock(&np->dev->xmit_lock);
+	spin_unlock_irq(&np->dev->xmit_lock);
 
 	/* transmit busy */
 	if(status) {
===== net/core/pktgen.c 1.21 vs edited =====
--- 1.21/net/core/pktgen.c	2005-01-10 11:32:10 -08:00
+++ edited/net/core/pktgen.c	2005-01-19 16:07:58 -08:00
@@ -2664,12 +2664,11 @@
 		}
 	}
 	
-	spin_lock_bh(&odev->xmit_lock);
+	spin_lock_irq(&odev->xmit_lock);
 	if (!netif_queue_stopped(odev)) {
 		u64 now;
 
 		atomic_inc(&(pkt_dev->skb->users));
-retry_now:
 		ret = odev->hard_start_xmit(pkt_dev->skb, odev);
 		if (likely(ret == NETDEV_TX_OK)) {
 			pkt_dev->last_ok = 1;    
@@ -2677,10 +2676,6 @@
 			pkt_dev->seq_num++;
 			pkt_dev->tx_bytes += pkt_dev->cur_pkt_size;
 			
-		} else if (ret == NETDEV_TX_LOCKED 
-			   && (odev->features & NETIF_F_LLTX)) {
-			cpu_relax();
-			goto retry_now;
 		} else {  /* Retry it next time */
 			
 			atomic_dec(&(pkt_dev->skb->users));
@@ -2716,7 +2711,7 @@
 		pkt_dev->next_tx_ns = 0;
         }
 
-	spin_unlock_bh(&odev->xmit_lock);
+	spin_unlock_irq(&odev->xmit_lock);
 	
 	/* If pkt_dev->count is zero, then run forever */
 	if ((pkt_dev->count != 0) && (pkt_dev->sofar >= pkt_dev->count)) {
===== net/sched/sch_generic.c 1.33 vs edited =====
--- 1.33/net/sched/sch_generic.c	2005-01-13 20:41:07 -08:00
+++ edited/net/sched/sch_generic.c	2005-01-19 16:25:02 -08:00
@@ -99,17 +99,11 @@
 	if ((skb = q->dequeue(q)) != NULL) {
 		unsigned nolock = (dev->features & NETIF_F_LLTX);
 		/*
-		 * When the driver has LLTX set it does its own locking
-		 * in start_xmit. No need to add additional overhead by
-		 * locking again. These checks are worth it because
-		 * even uncongested locks can be quite expensive.
-		 * The driver can do trylock like here too, in case
-		 * of lock congestion it should return -1 and the packet
-		 * will be requeued.
+		 * When the driver has LLTX set it does not require any
+		 * locking in start_xmit.
 		 */
 		if (!nolock) {
-			if (!spin_trylock(&dev->xmit_lock)) {
-			collision:
+			if (!spin_trylock_irq(&dev->xmit_lock)) {
 				/* So, someone grabbed the driver. */
 				
 				/* It may be transient configuration error,
@@ -143,22 +137,18 @@
 				if (ret == NETDEV_TX_OK) { 
 					if (!nolock) {
 						dev->xmit_lock_owner = -1;
-						spin_unlock(&dev->xmit_lock);
+						spin_unlock_irq(&dev->xmit_lock);
 					}
 					spin_lock(&dev->queue_lock);
 					return -1;
 				}
-				if (ret == NETDEV_TX_LOCKED && nolock) {
-					spin_lock(&dev->queue_lock);
-					goto collision; 
-				}
 			}
 
 			/* NETDEV_TX_BUSY - we need to requeue */
 			/* Release the driver */
 			if (!nolock) { 
 				dev->xmit_lock_owner = -1;
-				spin_unlock(&dev->xmit_lock);
+				spin_unlock_irq(&dev->xmit_lock);
 			} 
 			spin_lock(&dev->queue_lock);
 			q = dev->qdisc;
@@ -186,7 +176,7 @@
 {
 	struct net_device *dev = (struct net_device *)arg;
 
-	spin_lock(&dev->xmit_lock);
+	spin_lock_irq(&dev->xmit_lock);
 	if (dev->qdisc != &noop_qdisc) {
 		if (netif_device_present(dev) &&
 		    netif_running(dev) &&
@@ -200,7 +190,7 @@
 				dev_hold(dev);
 		}
 	}
-	spin_unlock(&dev->xmit_lock);
+	spin_unlock_irq(&dev->xmit_lock);
 
 	dev_put(dev);
 }
@@ -224,17 +214,17 @@
 
 static void dev_watchdog_up(struct net_device *dev)
 {
-	spin_lock_bh(&dev->xmit_lock);
+	spin_lock_irq(&dev->xmit_lock);
 	__netdev_watchdog_up(dev);
-	spin_unlock_bh(&dev->xmit_lock);
+	spin_unlock_irq(&dev->xmit_lock);
 }
 
 static void dev_watchdog_down(struct net_device *dev)
 {
-	spin_lock_bh(&dev->xmit_lock);
+	spin_lock_irq(&dev->xmit_lock);
 	if (del_timer(&dev->watchdog_timer))
 		__dev_put(dev);
-	spin_unlock_bh(&dev->xmit_lock);
+	spin_unlock_irq(&dev->xmit_lock);
 }
 
 /* "NOOP" scheduler: the best scheduler, recommended for all interfaces
===== net/sched/sch_teql.c 1.16 vs edited =====
--- 1.16/net/sched/sch_teql.c	2004-10-21 22:21:24 -07:00
+++ edited/net/sched/sch_teql.c	2005-01-19 16:06:11 -08:00
@@ -301,12 +301,12 @@
 
 		switch (teql_resolve(skb, skb_res, slave)) {
 		case 0:
-			if (spin_trylock(&slave->xmit_lock)) {
+			if (spin_trylock_irq(&slave->xmit_lock)) {
 				slave->xmit_lock_owner = smp_processor_id();
 				if (!netif_queue_stopped(slave) &&
 				    slave->hard_start_xmit(skb, slave) == 0) {
 					slave->xmit_lock_owner = -1;
-					spin_unlock(&slave->xmit_lock);
+					spin_unlock_irq(&slave->xmit_lock);
 					master->slaves = NEXT_SLAVE(q);
 					netif_wake_queue(dev);
 					master->stats.tx_packets++;
@@ -314,7 +314,7 @@
 					return 0;
 				}
 				slave->xmit_lock_owner = -1;
-				spin_unlock(&slave->xmit_lock);
+				spin_unlock_irq(&slave->xmit_lock);
 			}
 			if (netif_queue_stopped(dev))
 				busy = 1;
