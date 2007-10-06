From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH 5/5] forcedeth: timer overhaul
Date: Sat, 6 Oct 2007 11:15:56 -0400
Message-ID: <20071006151556.GE17488@havoc.gtf.org>
References: <20071006151250.GA17020@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: netdev@vger.kernel.org, Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:34930 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763201AbXJFPP5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Oct 2007 11:15:57 -0400
Content-Disposition: inline
In-Reply-To: <20071006151250.GA17020@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


commit d7c766113ee2ec66ae8975e0acbad086d2c23594
Author: Jeff Garzik <jeff@garzik.org>
Date:   Sat Oct 6 10:57:56 2007 -0400

    [netdrvr] forcedeth: timer overhaul
    
    * convert stats_poll timer to a delayed-work workqueue stats_task
    
    * protect hw stats update with a lock
    
    * now that recovery is the only remaining use of nv_do_nic_poll(),
      rename it to nv_reset_task(), move it from a timer to a workqueue,
      and delete all non-recovery-related code from the function.
    
    * kill np->in_shutdown, it mirrors netif_running().  furthermore,
      the overwhelming majority of sites that tested np->in_shutdown
      were inside rtnl_lock() and guaranteed never to race against shutdown
      anyway.
    
    Signed-off-by: Jeff Garzik <jgarzik@redhat.com>

 drivers/net/forcedeth.c |  194 ++++++++++++++++++------------------------------
 1 file changed, 75 insertions(+), 119 deletions(-)

d7c766113ee2ec66ae8975e0acbad086d2c23594
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index d6eacd7..a037f49 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -62,6 +62,7 @@
 #include <linux/init.h>
 #include <linux/if_vlan.h>
 #include <linux/dma-mapping.h>
+#include <linux/workqueue.h>
 
 #include <asm/irq.h>
 #include <asm/io.h>
@@ -450,7 +451,6 @@ union ring_type {
 #define NV_PKTLIMIT_2	9100	/* Actual limit according to NVidia: 9202 */
 
 #define OOM_REFILL	(1+HZ/20)
-#define POLL_WAIT	(1+HZ/100)
 #define LINK_TIMEOUT	(3*HZ)
 #define STATS_INTERVAL	(10*HZ)
 
@@ -670,7 +670,6 @@ struct fe_priv {
 	 * Locking: spin_lock(&np->lock); */
 	struct net_device_stats stats;
 	struct nv_ethtool_stats estats;
-	int in_shutdown;
 	u32 linkspeed;
 	int duplex;
 	int autoneg;
@@ -681,7 +680,6 @@ struct fe_priv {
 	unsigned int phy_model;
 	u16 gigabit;
 	int intr_test;
-	int recover_error;
 
 	/* General data: RO fields */
 	dma_addr_t ring_addr;
@@ -710,9 +708,9 @@ struct fe_priv {
 	unsigned int rx_buf_sz;
 	unsigned int pkt_limit;
 	struct timer_list oom_kick;
-	struct timer_list nic_poll;
-	struct timer_list stats_poll;
-	u32 nic_poll_irq;
+	struct work_struct reset_task;
+	struct delayed_work stats_task;
+	u32 reset_task_irq;
 	int rx_ring_size;
 
 	/* media detection workaround.
@@ -1388,7 +1386,7 @@ static void nv_mac_reset(struct net_device *dev)
 	pci_push(base);
 }
 
-static void nv_get_hw_stats(struct net_device *dev)
+static void __nv_get_hw_stats(struct net_device *dev)
 {
 	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
@@ -1443,6 +1441,16 @@ static void nv_get_hw_stats(struct net_device *dev)
 	}
 }
 
+static void nv_get_hw_stats(struct net_device *dev)
+{
+	struct fe_priv *np = netdev_priv(dev);
+	unsigned long flags;
+
+	spin_lock_irqsave(&np->lock, flags);
+	__nv_get_hw_stats(dev);
+	spin_unlock_irqrestore(&np->lock, flags);
+}
+
 /*
  * nv_get_stats: dev->get_stats function
  * Get latest stats value from the nic.
@@ -2478,10 +2486,9 @@ static int nv_change_mtu(struct net_device *dev, int new_mtu)
 		nv_drain_txrx(dev);
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
@@ -2957,10 +2964,9 @@ static irqreturn_t __nv_nic_irq(struct net_device *dev, bool optimized)
 			writel(np->irqmask, base + NvRegIrqMask);
 		pci_push(base);
 
-		if (!np->in_shutdown) {
-			np->nic_poll_irq = np->irqmask;
-			np->recover_error = 1;
-			mod_timer(&np->nic_poll, jiffies + POLL_WAIT);
+		if (netif_running(dev)) {
+			np->reset_task_irq = np->irqmask;
+			schedule_work(&np->reset_task);
 		}
 	}
 
@@ -3061,8 +3067,7 @@ static int nv_napi_poll(struct napi_struct *napi, int budget)
 
 	if (retcode) {
 		spin_lock_irqsave(&np->lock, flags);
-		if (!np->in_shutdown)
-			mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
+		mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
 		spin_unlock_irqrestore(&np->lock, flags);
 	}
 
@@ -3276,12 +3281,12 @@ static void nv_free_irq(struct net_device *dev)
 	}
 }
 
-static void nv_do_nic_poll(unsigned long data)
+static void nv_reset_task(struct work_struct *work)
 {
-	struct net_device *dev = (struct net_device *) data;
-	struct fe_priv *np = netdev_priv(dev);
+	struct fe_priv *np = container_of(work, struct fe_priv, reset_task);
+	struct net_device *dev = np->dev;
 	u8 __iomem *base = get_hwbase(dev);
-	u32 mask = 0;
+	u32 mask;
 
 	/*
 	 * First disable irq(s) and then
@@ -3290,88 +3295,51 @@ static void nv_do_nic_poll(unsigned long data)
 	 */
 
 	if (!using_multi_irqs(dev)) {
-		if (np->msi_flags & NV_MSI_X_ENABLED)
-			disable_irq_lockdep(np->msi_x_entry[NV_MSI_X_VECTOR_ALL].vector);
-		else
-			disable_irq_lockdep(dev->irq);
 		mask = np->irqmask;
 	} else {
-		if (np->nic_poll_irq & NVREG_IRQ_RX_ALL) {
-			disable_irq_lockdep(np->msi_x_entry[NV_MSI_X_VECTOR_RX].vector);
+		mask = 0;
+		if (np->reset_task_irq & NVREG_IRQ_RX_ALL)
 			mask |= NVREG_IRQ_RX_ALL;
-		}
-		if (np->nic_poll_irq & NVREG_IRQ_TX_ALL) {
-			disable_irq_lockdep(np->msi_x_entry[NV_MSI_X_VECTOR_TX].vector);
+		if (np->reset_task_irq & NVREG_IRQ_TX_ALL)
 			mask |= NVREG_IRQ_TX_ALL;
-		}
-		if (np->nic_poll_irq & NVREG_IRQ_OTHER) {
-			disable_irq_lockdep(np->msi_x_entry[NV_MSI_X_VECTOR_OTHER].vector);
+		if (np->reset_task_irq & NVREG_IRQ_OTHER)
 			mask |= NVREG_IRQ_OTHER;
-		}
 	}
-	np->nic_poll_irq = 0;
+	np->reset_task_irq = 0;
 
-	if (np->recover_error) {
-		np->recover_error = 0;
-		printk(KERN_INFO "forcedeth: MAC in recoverable error state\n");
-		if (netif_running(dev)) {
-			netif_tx_lock_bh(dev);
-			spin_lock(&np->lock);
-			/* stop engines */
-			nv_stop_txrx(dev);
-			nv_txrx_reset(dev);
-			/* drain rx queue */
-			nv_drain_txrx(dev);
-			/* reinit driver view of the rx queue */
-			set_bufsize(dev);
-			if (nv_init_ring(dev)) {
-				if (!np->in_shutdown)
-					mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
-			}
-			/* reinit nic view of the rx queue */
-			writel(np->rx_buf_sz, base + NvRegOffloadConfig);
-			setup_hw_rings(dev, NV_SETUP_RX_RING | NV_SETUP_TX_RING);
-			writel( ((np->rx_ring_size-1) << NVREG_RINGSZ_RXSHIFT) + ((np->tx_ring_size-1) << NVREG_RINGSZ_TXSHIFT),
-				base + NvRegRingSizes);
-			pci_push(base);
-			writel(NVREG_TXRXCTL_KICK|np->txrxctl_bits, get_hwbase(dev) + NvRegTxRxControl);
-			pci_push(base);
+	printk(KERN_INFO "forcedeth: MAC in recoverable error state\n");
+	if (!netif_running(dev))
+		goto out;
 
-			/* restart rx engine */
-			nv_start_txrx(dev);
-			spin_unlock(&np->lock);
-			netif_tx_unlock_bh(dev);
-		}
-	}
+	netif_tx_lock_bh(dev);
+	spin_lock(&np->lock);
+	/* stop engines */
+	nv_stop_txrx(dev);
+	nv_txrx_reset(dev);
+	/* drain rx queue */
+	nv_drain_txrx(dev);
+	/* reinit driver view of the rx queue */
+	set_bufsize(dev);
+	if (nv_init_ring(dev))
+		mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
 
-	/* FIXME: Do we need synchronize_irq(dev->irq) here? */
+	/* reinit nic view of the rx queue */
+	writel(np->rx_buf_sz, base + NvRegOffloadConfig);
+	setup_hw_rings(dev, NV_SETUP_RX_RING | NV_SETUP_TX_RING);
+	writel( ((np->rx_ring_size-1) << NVREG_RINGSZ_RXSHIFT) + ((np->tx_ring_size-1) << NVREG_RINGSZ_TXSHIFT),
+		base + NvRegRingSizes);
+	pci_push(base);
+	writel(NVREG_TXRXCTL_KICK|np->txrxctl_bits, get_hwbase(dev) + NvRegTxRxControl);
+	pci_push(base);
+
+	/* restart rx engine */
+	nv_start_txrx(dev);
+	spin_unlock(&np->lock);
+	netif_tx_unlock_bh(dev);
 
+out:
 	writel(mask, base + NvRegIrqMask);
 	pci_push(base);
-
-	if (!using_multi_irqs(dev)) {
-		if (nv_optimized(np))
-			nv_nic_irq_optimized(0, dev);
-		else
-			nv_nic_irq(0, dev);
-		if (np->msi_flags & NV_MSI_X_ENABLED)
-			enable_irq_lockdep(np->msi_x_entry[NV_MSI_X_VECTOR_ALL].vector);
-		else
-			enable_irq_lockdep(dev->irq);
-	} else {
-		if (np->nic_poll_irq & NVREG_IRQ_RX_ALL) {
-			nv_nic_irq_rx(0, dev);
-			enable_irq_lockdep(np->msi_x_entry[NV_MSI_X_VECTOR_RX].vector);
-		}
-		if (np->nic_poll_irq & NVREG_IRQ_TX_ALL) {
-			nv_nic_irq_tx(0, dev);
-			enable_irq_lockdep(np->msi_x_entry[NV_MSI_X_VECTOR_TX].vector);
-		}
-		if (np->nic_poll_irq & NVREG_IRQ_OTHER) {
-			nv_nic_irq_other(0, dev);
-			enable_irq_lockdep(np->msi_x_entry[NV_MSI_X_VECTOR_OTHER].vector);
-		}
-	}
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -3386,15 +3354,15 @@ static void nv_poll_controller(struct net_device *dev)
 }
 #endif
 
-static void nv_do_stats_poll(unsigned long data)
+static void nv_stats_task(struct work_struct *_work)
 {
-	struct net_device *dev = (struct net_device *) data;
-	struct fe_priv *np = netdev_priv(dev);
+	struct delayed_work *work = (struct delayed_work *) _work;
+	struct fe_priv *np = container_of(work, struct fe_priv, stats_task);
+	struct net_device *dev = np->dev;
 
 	nv_get_hw_stats(dev);
 
-	if (!np->in_shutdown)
-		mod_timer(&np->stats_poll, jiffies + STATS_INTERVAL);
+	schedule_delayed_work(work, STATS_INTERVAL);
 }
 
 static void nv_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
@@ -3840,10 +3808,8 @@ static int nv_set_ringparam(struct net_device *dev, struct ethtool_ringparam* ri
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
@@ -4024,7 +3990,7 @@ static void nv_get_ethtool_stats(struct net_device *dev, struct ethtool_stats *e
 	struct fe_priv *np = netdev_priv(dev);
 
 	/* update stats */
-	nv_do_stats_poll((unsigned long)dev);
+	nv_get_hw_stats(dev);
 
 	memcpy(buffer, &np->estats, nv_get_sset_count(dev, ETH_SS_STATS)*sizeof(u64));
 }
@@ -4322,10 +4288,9 @@ static void nv_self_test(struct net_device *dev, struct ethtool_test *test, u64
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
@@ -4473,8 +4438,6 @@ static int nv_open(struct net_device *dev)
 	nv_txrx_reset(dev);
 	writel(0, base + NvRegUnknownSetupReg6);
 
-	np->in_shutdown = 0;
-
 	/* give hw rings */
 	setup_hw_rings(dev, NV_SETUP_RX_RING | NV_SETUP_TX_RING);
 	writel( ((np->rx_ring_size-1) << NVREG_RINGSZ_RXSHIFT) + ((np->tx_ring_size-1) << NVREG_RINGSZ_TXSHIFT),
@@ -4579,7 +4542,7 @@ static int nv_open(struct net_device *dev)
 
 	/* start statistics timer */
 	if (np->driver_data & (DEV_HAS_STATISTICS_V1|DEV_HAS_STATISTICS_V2))
-		mod_timer(&np->stats_poll, jiffies + STATS_INTERVAL);
+		schedule_delayed_work(&np->stats_task, STATS_INTERVAL);
 
 	spin_unlock_irq(&np->lock);
 
@@ -4594,17 +4557,14 @@ static int nv_close(struct net_device *dev)
 	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base;
 
-	spin_lock_irq(&np->lock);
-	np->in_shutdown = 1;
-	spin_unlock_irq(&np->lock);
 	netif_stop_queue(dev);
 	napi_disable(&np->napi);
 	napi_disable(&np->tx_napi);
 	synchronize_irq(dev->irq);
 
 	del_timer_sync(&np->oom_kick);
-	del_timer_sync(&np->nic_poll);
-	del_timer_sync(&np->stats_poll);
+	cancel_rearming_delayed_work(&np->stats_task);
+	cancel_work_sync(&np->reset_task);
 
 	spin_lock_irq(&np->lock);
 	nv_stop_txrx(dev);
@@ -4658,12 +4618,8 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 	init_timer(&np->oom_kick);
 	np->oom_kick.data = (unsigned long) dev;
 	np->oom_kick.function = &nv_do_rx_refill;	/* timer handler */
-	init_timer(&np->nic_poll);
-	np->nic_poll.data = (unsigned long) dev;
-	np->nic_poll.function = &nv_do_nic_poll;	/* timer handler */
-	init_timer(&np->stats_poll);
-	np->stats_poll.data = (unsigned long) dev;
-	np->stats_poll.function = &nv_do_stats_poll;	/* timer handler */
+	INIT_WORK(&np->reset_task, nv_reset_task);
+	INIT_DELAYED_WORK(&np->stats_task, nv_stats_task);
 
 	err = pci_enable_device(pci_dev);
 	if (err) {
