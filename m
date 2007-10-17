From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH 2/6] forcedeth: timer overhaul
Date: Wed, 17 Oct 2007 01:53:39 -0400
Message-ID: <20071017055339.GC20534@havoc.gtf.org>
References: <20071017055251.GA19972@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Manfred Spraul <manfred@colorfullife.com>,
	Ingo Molnar <mingo@elte.hu>, Ayaz Abdulla <aabdulla@nvidia.com>
To: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:37703 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765506AbXJQFxk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 01:53:40 -0400
Content-Disposition: inline
In-Reply-To: <20071017055251.GA19972@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


commit 160511126b6be7f15da33f7cab7374b12cb59999
Author: Jeff Garzik <jeff@garzik.org>
Date:   Tue Oct 16 02:22:39 2007 -0400

    [netdrvr] forcedeth: timer overhaul
    
    * remove np->in_shutdown, it mirrors netif_running()
    
    * convert stats timer to delayed workqueue
    
    * retrieve hw stats inside spinlock
    
    * split out the 'stop' portions of nv_stop_rx() and nv_stop_rx(),
      to enable future calling of these operations without the reg_delay()
      that immediately follows.
    
    Signed-off-by: Jeff Garzik <jgarzik@redhat.com>

 drivers/net/forcedeth.c |  135 +++++++++++++++++++++++++++---------------------
 1 file changed, 77 insertions(+), 58 deletions(-)

160511126b6be7f15da33f7cab7374b12cb59999
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 2d518fc..39ade56 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -664,7 +664,7 @@ struct fe_priv {
 	/* General data:
 	 * Locking: spin_lock(&np->lock); */
 	struct nv_ethtool_stats estats;
-	int in_shutdown;
+
 	u32 linkspeed;
 	int duplex;
 	int autoneg;
@@ -705,7 +705,7 @@ struct fe_priv {
 	unsigned int pkt_limit;
 	struct timer_list oom_kick;
 	struct timer_list nic_poll;
-	struct timer_list stats_poll;
+	struct delayed_work stats_task;
 	u32 nic_poll_irq;
 	int rx_ring_size;
 
@@ -1264,18 +1264,28 @@ static void nv_start_rx(struct net_device *dev)
 	pci_push(base);
 }
 
-static void nv_stop_rx(struct net_device *dev)
+static void __nv_stop_rx(struct fe_priv *np)
 {
-	struct fe_priv *np = netdev_priv(dev);
-	u8 __iomem *base = get_hwbase(dev);
+	u8 __iomem *base = np->base;
 	u32 rx_ctrl = readl(base + NvRegReceiverControl);
 
-	dprintk(KERN_DEBUG "%s: nv_stop_rx\n", dev->name);
+	dprintk(KERN_DEBUG "%s: __nv_stop_rx\n", dev->name);
 	if (!np->mac_in_use)
 		rx_ctrl &= ~NVREG_RCVCTL_START;
 	else
 		rx_ctrl |= NVREG_RCVCTL_RX_PATH_EN;
 	writel(rx_ctrl, base + NvRegReceiverControl);
+}
+
+static void nv_stop_rx(struct net_device *dev)
+{
+	struct fe_priv *np = netdev_priv(dev);
+	u8 __iomem *base = get_hwbase(dev);
+
+	dprintk(KERN_DEBUG "%s: nv_stop_rx\n", dev->name);
+
+	__nv_stop_rx(np);
+
 	reg_delay(dev, NvRegReceiverStatus, NVREG_RCVSTAT_BUSY, 0,
 			NV_RXSTOP_DELAY1, NV_RXSTOP_DELAY1MAX,
 			KERN_INFO "nv_stop_rx: ReceiverStatus remained busy");
@@ -1299,18 +1309,29 @@ static void nv_start_tx(struct net_device *dev)
 	pci_push(base);
 }
 
-static void nv_stop_tx(struct net_device *dev)
+static void __nv_stop_tx(struct fe_priv *np)
 {
-	struct fe_priv *np = netdev_priv(dev);
-	u8 __iomem *base = get_hwbase(dev);
+	u8 __iomem *base = np->base;
 	u32 tx_ctrl = readl(base + NvRegTransmitterControl);
 
-	dprintk(KERN_DEBUG "%s: nv_stop_tx\n", dev->name);
+	dprintk(KERN_DEBUG "%s: __nv_stop_tx\n", dev->name);
+
 	if (!np->mac_in_use)
 		tx_ctrl &= ~NVREG_XMITCTL_START;
 	else
 		tx_ctrl |= NVREG_XMITCTL_TX_PATH_EN;
 	writel(tx_ctrl, base + NvRegTransmitterControl);
+}
+
+static void nv_stop_tx(struct net_device *dev)
+{
+	struct fe_priv *np = netdev_priv(dev);
+	u8 __iomem *base = get_hwbase(dev);
+
+	dprintk(KERN_DEBUG "%s: nv_stop_tx\n", dev->name);
+
+	__nv_stop_tx(np);
+
 	reg_delay(dev, NvRegTransmitterStatus, NVREG_XMITSTAT_BUSY, 0,
 			NV_TXSTOP_DELAY1, NV_TXSTOP_DELAY1MAX,
 			KERN_INFO "nv_stop_tx: TransmitterStatus remained busy");
@@ -1364,10 +1385,9 @@ static void nv_mac_reset(struct net_device *dev)
 	pci_push(base);
 }
 
-static void nv_get_hw_stats(struct net_device *dev)
+static void __nv_get_hw_stats(struct fe_priv *np)
 {
-	struct fe_priv *np = netdev_priv(dev);
-	u8 __iomem *base = get_hwbase(dev);
+	u8 __iomem *base = np->base;
 
 	np->estats.tx_bytes += readl(base + NvRegTxCnt);
 	np->estats.tx_zero_rexmt += readl(base + NvRegTxZeroReXmt);
@@ -1419,6 +1439,15 @@ static void nv_get_hw_stats(struct net_device *dev)
 	}
 }
 
+static void nv_get_hw_stats(struct fe_priv *np)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&np->lock, flags);
+	__nv_get_hw_stats(np);
+	spin_unlock_irqrestore(&np->lock, flags);
+}
+
 /*
  * nv_get_stats: dev->get_stats function
  * Get latest stats value from the nic.
@@ -1431,7 +1460,7 @@ static struct net_device_stats *nv_get_stats(struct net_device *dev)
 
 	/* If the nic supports hw counters then retrieve latest values */
 	if (np->driver_data & (DEV_HAS_STATISTICS_V1|DEV_HAS_STATISTICS_V2)) {
-		nv_get_hw_stats(dev);
+		nv_get_hw_stats(np);
 
 		/* copy to net_device stats */
 		dev->stats.tx_bytes = np->estats.tx_bytes;
@@ -1547,7 +1576,7 @@ static void nv_do_rx_refill(unsigned long data)
 		retcode = nv_alloc_rx_optimized(dev);
 	if (retcode) {
 		spin_lock_irq(&np->lock);
-		if (!np->in_shutdown)
+		if (netif_running(dev))
 			mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
 		spin_unlock_irq(&np->lock);
 	}
@@ -2507,10 +2536,9 @@ static int nv_change_mtu(struct net_device *dev, int new_mtu)
 		nv_drain_rxtx(dev);
 		/* reinit driver view of the rx queue */
 		set_bufsize(dev);
-		if (nv_init_ring(dev)) {
-			if (!np->in_shutdown)
-				mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
-		}
+		if (nv_init_ring(dev))
+			mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
+
 		/* reinit nic view of the rx queue */
 		writel(np->rx_buf_sz, base + NvRegOffloadConfig);
 		setup_hw_rings(dev, NV_SETUP_RX_RING | NV_SETUP_TX_RING);
@@ -2953,7 +2981,7 @@ static irqreturn_t nv_nic_irq(int foo, void *data)
 		if (nv_rx_process(dev, RX_WORK_PER_LOOP)) {
 			if (unlikely(nv_alloc_rx(dev))) {
 				spin_lock(&np->lock);
-				if (!np->in_shutdown)
+				if (netif_running(dev))
 					mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
 				spin_unlock(&np->lock);
 			}
@@ -2987,7 +3015,7 @@ static irqreturn_t nv_nic_irq(int foo, void *data)
 				writel(np->irqmask, base + NvRegIrqMask);
 			pci_push(base);
 
-			if (!np->in_shutdown) {
+			if (netif_running(dev)) {
 				np->nic_poll_irq = np->irqmask;
 				np->recover_error = 1;
 				mod_timer(&np->nic_poll, jiffies + POLL_WAIT);
@@ -3004,7 +3032,7 @@ static irqreturn_t nv_nic_irq(int foo, void *data)
 				writel(np->irqmask, base + NvRegIrqMask);
 			pci_push(base);
 
-			if (!np->in_shutdown) {
+			if (netif_running(dev)) {
 				np->nic_poll_irq = np->irqmask;
 				mod_timer(&np->nic_poll, jiffies + POLL_WAIT);
 			}
@@ -3068,7 +3096,7 @@ static irqreturn_t nv_nic_irq_optimized(int foo, void *data)
 		if (nv_rx_process_optimized(dev, RX_WORK_PER_LOOP)) {
 			if (unlikely(nv_alloc_rx_optimized(dev))) {
 				spin_lock(&np->lock);
-				if (!np->in_shutdown)
+				if (netif_running(dev))
 					mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
 				spin_unlock(&np->lock);
 			}
@@ -3102,7 +3130,7 @@ static irqreturn_t nv_nic_irq_optimized(int foo, void *data)
 				writel(np->irqmask, base + NvRegIrqMask);
 			pci_push(base);
 
-			if (!np->in_shutdown) {
+			if (netif_running(dev)) {
 				np->nic_poll_irq = np->irqmask;
 				np->recover_error = 1;
 				mod_timer(&np->nic_poll, jiffies + POLL_WAIT);
@@ -3120,7 +3148,7 @@ static irqreturn_t nv_nic_irq_optimized(int foo, void *data)
 				writel(np->irqmask, base + NvRegIrqMask);
 			pci_push(base);
 
-			if (!np->in_shutdown) {
+			if (netif_running(dev)) {
 				np->nic_poll_irq = np->irqmask;
 				mod_timer(&np->nic_poll, jiffies + POLL_WAIT);
 			}
@@ -3167,7 +3195,7 @@ static irqreturn_t nv_nic_irq_tx(int foo, void *data)
 			writel(NVREG_IRQ_TX_ALL, base + NvRegIrqMask);
 			pci_push(base);
 
-			if (!np->in_shutdown) {
+			if (netif_running(dev)) {
 				np->nic_poll_irq |= NVREG_IRQ_TX_ALL;
 				mod_timer(&np->nic_poll, jiffies + POLL_WAIT);
 			}
@@ -3201,7 +3229,7 @@ static int nv_napi_poll(struct napi_struct *napi, int budget)
 
 	if (retcode) {
 		spin_lock_irqsave(&np->lock, flags);
-		if (!np->in_shutdown)
+		if (netif_running(dev))
 			mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
 		spin_unlock_irqrestore(&np->lock, flags);
 	}
@@ -3265,7 +3293,7 @@ static irqreturn_t nv_nic_irq_rx(int foo, void *data)
 		if (nv_rx_process_optimized(dev, RX_WORK_PER_LOOP)) {
 			if (unlikely(nv_alloc_rx_optimized(dev))) {
 				spin_lock_irqsave(&np->lock, flags);
-				if (!np->in_shutdown)
+				if (netif_running(dev))
 					mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
 				spin_unlock_irqrestore(&np->lock, flags);
 			}
@@ -3277,7 +3305,7 @@ static irqreturn_t nv_nic_irq_rx(int foo, void *data)
 			writel(NVREG_IRQ_RX_ALL, base + NvRegIrqMask);
 			pci_push(base);
 
-			if (!np->in_shutdown) {
+			if (netif_running(dev)) {
 				np->nic_poll_irq |= NVREG_IRQ_RX_ALL;
 				mod_timer(&np->nic_poll, jiffies + POLL_WAIT);
 			}
@@ -3332,7 +3360,7 @@ static irqreturn_t nv_nic_irq_other(int foo, void *data)
 			writel(NVREG_IRQ_OTHER, base + NvRegIrqMask);
 			pci_push(base);
 
-			if (!np->in_shutdown) {
+			if (netif_running(dev)) {
 				np->nic_poll_irq |= NVREG_IRQ_OTHER;
 				np->recover_error = 1;
 				mod_timer(&np->nic_poll, jiffies + POLL_WAIT);
@@ -3350,7 +3378,7 @@ static irqreturn_t nv_nic_irq_other(int foo, void *data)
 			writel(NVREG_IRQ_OTHER, base + NvRegIrqMask);
 			pci_push(base);
 
-			if (!np->in_shutdown) {
+			if (netif_running(dev)) {
 				np->nic_poll_irq |= NVREG_IRQ_OTHER;
 				mod_timer(&np->nic_poll, jiffies + POLL_WAIT);
 			}
@@ -3587,10 +3615,9 @@ static void nv_do_nic_poll(unsigned long data)
 			nv_drain_rxtx(dev);
 			/* reinit driver view of the rx queue */
 			set_bufsize(dev);
-			if (nv_init_ring(dev)) {
-				if (!np->in_shutdown)
-					mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
-			}
+			if (nv_init_ring(dev))
+				mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
+
 			/* reinit nic view of the rx queue */
 			writel(np->rx_buf_sz, base + NvRegOffloadConfig);
 			setup_hw_rings(dev, NV_SETUP_RX_RING | NV_SETUP_TX_RING);
@@ -3644,15 +3671,14 @@ static void nv_poll_controller(struct net_device *dev)
 }
 #endif
 
-static void nv_do_stats_poll(unsigned long data)
+static void nv_stats_task(struct work_struct *work)
 {
-	struct net_device *dev = (struct net_device *) data;
-	struct fe_priv *np = netdev_priv(dev);
+	struct fe_priv *np =
+		container_of(work, struct fe_priv, stats_task.work);
 
-	nv_get_hw_stats(dev);
+	nv_get_hw_stats(np);
 
-	if (!np->in_shutdown)
-		mod_timer(&np->stats_poll, jiffies + STATS_INTERVAL);
+	schedule_delayed_work(&np->stats_task, STATS_INTERVAL);
 }
 
 static void nv_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
@@ -4099,10 +4125,8 @@ static int nv_set_ringparam(struct net_device *dev, struct ethtool_ringparam* ri
 	if (netif_running(dev)) {
 		/* reinit driver view of the queues */
 		set_bufsize(dev);
-		if (nv_init_ring(dev)) {
-			if (!np->in_shutdown)
-				mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
-		}
+		if (nv_init_ring(dev))
+			mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
 
 		/* reinit nic view of the queues */
 		writel(np->rx_buf_sz, base + NvRegOffloadConfig);
@@ -4283,7 +4307,7 @@ static void nv_get_ethtool_stats(struct net_device *dev, struct ethtool_stats *e
 	struct fe_priv *np = netdev_priv(dev);
 
 	/* update stats */
-	nv_do_stats_poll((unsigned long)dev);
+	nv_get_hw_stats(np);
 
 	memcpy(buffer, &np->estats, nv_get_sset_count(dev, ETH_SS_STATS)*sizeof(u64));
 }
@@ -4582,10 +4606,9 @@ static void nv_self_test(struct net_device *dev, struct ethtool_test *test, u64
 		if (netif_running(dev)) {
 			/* reinit driver view of the rx queue */
 			set_bufsize(dev);
-			if (nv_init_ring(dev)) {
-				if (!np->in_shutdown)
-					mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
-			}
+			if (nv_init_ring(dev))
+				mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
+
 			/* reinit nic view of the rx queue */
 			writel(np->rx_buf_sz, base + NvRegOffloadConfig);
 			setup_hw_rings(dev, NV_SETUP_RX_RING | NV_SETUP_TX_RING);
@@ -4734,8 +4757,6 @@ static int nv_open(struct net_device *dev)
 	nv_txrx_reset(dev);
 	writel(0, base + NvRegUnknownSetupReg6);
 
-	np->in_shutdown = 0;
-
 	/* give hw rings */
 	setup_hw_rings(dev, NV_SETUP_RX_RING | NV_SETUP_TX_RING);
 	writel( ((np->rx_ring_size-1) << NVREG_RINGSZ_RXSHIFT) + ((np->tx_ring_size-1) << NVREG_RINGSZ_TXSHIFT),
@@ -4841,7 +4862,7 @@ static int nv_open(struct net_device *dev)
 
 	/* start statistics timer */
 	if (np->driver_data & (DEV_HAS_STATISTICS_V1|DEV_HAS_STATISTICS_V2))
-		mod_timer(&np->stats_poll, jiffies + STATS_INTERVAL);
+		schedule_delayed_work(&np->stats_task, STATS_INTERVAL);
 
 	spin_unlock_irq(&np->lock);
 
@@ -4857,8 +4878,8 @@ static int nv_close(struct net_device *dev)
 	u8 __iomem *base;
 
 	spin_lock_irq(&np->lock);
-	np->in_shutdown = 1;
 	spin_unlock_irq(&np->lock);
+
 #ifdef CONFIG_FORCEDETH_NAPI
 	napi_disable(&np->napi);
 #endif
@@ -4866,7 +4887,7 @@ static int nv_close(struct net_device *dev)
 
 	del_timer_sync(&np->oom_kick);
 	del_timer_sync(&np->nic_poll);
-	del_timer_sync(&np->stats_poll);
+	cancel_delayed_work_sync(&np->stats_task);
 
 	netif_stop_queue(dev);
 	spin_lock_irq(&np->lock);
@@ -4929,9 +4950,7 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 	init_timer(&np->nic_poll);
 	np->nic_poll.data = (unsigned long) dev;
 	np->nic_poll.function = &nv_do_nic_poll;	/* timer handler */
-	init_timer(&np->stats_poll);
-	np->stats_poll.data = (unsigned long) dev;
-	np->stats_poll.function = &nv_do_stats_poll;	/* timer handler */
+	INIT_DELAYED_WORK(&np->stats_task, nv_stats_task);
 
 	err = pci_enable_device(pci_dev);
 	if (err)
