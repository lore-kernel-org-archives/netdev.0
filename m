From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH 6/n] forcedeth: protect slow path with mutex
Date: Sun, 7 Oct 2007 07:23:47 -0400
Message-ID: <20071007112347.GA23577@havoc.gtf.org>
References: <20071006151250.GA17020@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: netdev@vger.kernel.org, Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:57830 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752492AbXJGLXs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Oct 2007 07:23:48 -0400
Content-Disposition: inline
In-Reply-To: <20071006151250.GA17020@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


commit abca163a14b28c234df9bf38034bc967ff81c3aa
Author: Jeff Garzik <jeff@garzik.org>
Date:   Sun Oct 7 07:22:14 2007 -0400

    [netdrvr] forcedeth: wrap slow path hw manipulation inside hw_mutex
    
    * This makes sure everybody who wants to start/stop the RX and TX engines
      first acquires this mutex.
    
    * tx_timeout code was deleted, replaced by scheduling reset_task.
    
    * linkchange moved to a workqueue (always inside hw_mutex)
    
    * simplified irq handling a bit
    
    * make sure to disable workqueues before NAPI
    
    Signed-off-by: Jeff Garzik <jgarzik@redhat.com>

 drivers/net/forcedeth.c |  272 ++++++++++++++++++++++++++++++------------------
 1 file changed, 175 insertions(+), 97 deletions(-)

abca163a14b28c234df9bf38034bc967ff81c3aa
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index a037f49..d1c1efa 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -63,6 +63,7 @@
 #include <linux/if_vlan.h>
 #include <linux/dma-mapping.h>
 #include <linux/workqueue.h>
+#include <linux/mutex.h>
 
 #include <asm/irq.h>
 #include <asm/io.h>
@@ -647,6 +648,12 @@ struct nv_skb_map {
 	unsigned int dma_len;
 };
 
+struct nv_mc_info {
+	u32 addr[2];
+	u32 mask[2];
+	u32 pff;
+};
+
 /*
  * SMP locking:
  * All hardware access under dev->priv->lock, except the performance
@@ -709,6 +716,8 @@ struct fe_priv {
 	unsigned int pkt_limit;
 	struct timer_list oom_kick;
 	struct work_struct reset_task;
+	struct work_struct linkchange_task;
+	struct work_struct mcast_task;
 	struct delayed_work stats_task;
 	u32 reset_task_irq;
 	int rx_ring_size;
@@ -731,14 +740,18 @@ struct fe_priv {
 	int tx_ring_size;
 
 	/* vlan fields */
-	struct vlan_group *vlangrp;
+	struct vlan_group	*vlangrp;
 
 	/* msi/msi-x fields */
-	u32 msi_flags;
-	struct msix_entry msi_x_entry[NV_MSI_X_MAX_VECTORS];
+	u32			msi_flags;
+	struct msix_entry	msi_x_entry[NV_MSI_X_MAX_VECTORS];
 
 	/* flow control */
-	u32 pause_flags;
+	u32			pause_flags;
+
+	struct mutex		hw_mutex;
+
+	struct nv_mc_info	mci;
 };
 
 /*
@@ -2120,27 +2133,9 @@ static void nv_tx_timeout(struct net_device *dev)
 
 	spin_lock_irq(&np->lock);
 
-	/* 1) stop tx engine */
-	nv_stop_tx(dev);
-
-	/* 2) process all pending tx completions */
-	if (!nv_optimized(np))
-		nv_tx_done(dev, np->tx_ring_size);
-	else
-		nv_tx_done_optimized(dev, np->tx_ring_size);
+	np->reset_task_irq = np->irqmask;
+	schedule_work(&np->reset_task);
 
-	/* 3) if there are dead entries: clear everything */
-	if (np->get_tx_ctx != np->put_tx_ctx) {
-		printk(KERN_DEBUG "%s: tx_timeout: dead entries!\n", dev->name);
-		nv_drain_tx(dev);
-		nv_init_tx(dev);
-		setup_hw_rings(dev, NV_SETUP_TX_RING);
-	}
-
-	netif_wake_queue(dev);
-
-	/* 4) restart tx engine */
-	nv_start_tx(dev);
 	spin_unlock_irq(&np->lock);
 }
 
@@ -2476,6 +2471,7 @@ static int nv_change_mtu(struct net_device *dev, int new_mtu)
 		 * guessed, there is probably a simpler approach.
 		 * Changing the MTU is a rare event, it shouldn't matter.
 		 */
+		mutex_lock(&np->hw_mutex);
 		nv_disable_irq(dev);
 		netif_tx_lock_bh(dev);
 		spin_lock(&np->lock);
@@ -2503,6 +2499,7 @@ static int nv_change_mtu(struct net_device *dev, int new_mtu)
 		spin_unlock(&np->lock);
 		netif_tx_unlock_bh(dev);
 		nv_enable_irq(dev);
+		mutex_unlock(&np->hw_mutex);
 	}
 	return 0;
 }
@@ -2535,6 +2532,8 @@ static int nv_set_mac_address(struct net_device *dev, void *addr)
 	/* synchronized against open : rtnl_lock() held by caller */
 	memcpy(dev->dev_addr, macaddr->sa_data, ETH_ALEN);
 
+	mutex_lock(&np->hw_mutex);
+
 	if (netif_running(dev)) {
 		netif_tx_lock_bh(dev);
 		spin_lock_irq(&np->lock);
@@ -2552,6 +2551,8 @@ static int nv_set_mac_address(struct net_device *dev, void *addr)
 	} else {
 		nv_copy_mac_to_hw(dev);
 	}
+
+	mutex_unlock(&np->hw_mutex);
 	return 0;
 }
 
@@ -2605,17 +2606,61 @@ static void nv_set_multicast(struct net_device *dev)
 	}
 	addr[0] |= NVREG_MCASTADDRA_FORCE;
 	pff |= NVREG_PFF_ALWAYS;
+
+	if (mutex_trylock(&np->hw_mutex)) {
+		spin_lock_irq(&np->lock);
+
+		nv_stop_rx(dev);
+
+		writel(addr[0], base + NvRegMulticastAddrA);
+		writel(addr[1], base + NvRegMulticastAddrB);
+		writel(mask[0], base + NvRegMulticastMaskA);
+		writel(mask[1], base + NvRegMulticastMaskB);
+		writel(pff, base + NvRegPacketFilterFlags);
+		dprintk(KERN_INFO "%s: reconfiguration for multicast lists.\n",
+			dev->name);
+
+		nv_start_rx(dev);
+
+		spin_unlock_irq(&np->lock);
+	} else {
+		spin_lock_irq(&np->lock);
+		np->mci.addr[0] = addr[0];
+		np->mci.addr[1] = addr[1];
+		np->mci.mask[0] = mask[0];
+		np->mci.mask[1] = mask[1];
+		np->mci.pff = pff;
+		spin_unlock_irq(&np->lock);
+
+		schedule_work(&np->mcast_task);
+	}
+}
+
+static void nv_mcast_task(struct work_struct *work)
+{
+	struct fe_priv *np = container_of(work, struct fe_priv, mcast_task);
+	struct net_device *dev = np->dev;
+	u8 __iomem *base = get_hwbase(dev);
+
+	mutex_lock(&np->hw_mutex);
+
 	spin_lock_irq(&np->lock);
+
 	nv_stop_rx(dev);
-	writel(addr[0], base + NvRegMulticastAddrA);
-	writel(addr[1], base + NvRegMulticastAddrB);
-	writel(mask[0], base + NvRegMulticastMaskA);
-	writel(mask[1], base + NvRegMulticastMaskB);
-	writel(pff, base + NvRegPacketFilterFlags);
+
+	writel(np->mci.addr[0], base + NvRegMulticastAddrA);
+	writel(np->mci.addr[1], base + NvRegMulticastAddrB);
+	writel(np->mci.mask[0], base + NvRegMulticastMaskA);
+	writel(np->mci.mask[1], base + NvRegMulticastMaskB);
+	writel(np->mci.pff, base + NvRegPacketFilterFlags);
 	dprintk(KERN_INFO "%s: reconfiguration for multicast lists.\n",
 		dev->name);
+
 	nv_start_rx(dev);
+
 	spin_unlock_irq(&np->lock);
+
+	mutex_unlock(&np->hw_mutex);
 }
 
 static void nv_update_pause(struct net_device *dev, u32 pause_flags)
@@ -2873,6 +2918,15 @@ static void nv_linkchange(struct net_device *dev)
 	}
 }
 
+static void nv_linkchange_task(struct work_struct *work)
+{
+	struct fe_priv *np = container_of(work, struct fe_priv, linkchange_task);
+
+	mutex_lock(&np->hw_mutex);
+	nv_linkchange(np->dev);
+	mutex_unlock(&np->hw_mutex);
+}
+
 static void nv_link_irq(struct net_device *dev)
 {
 	u8 __iomem *base = get_hwbase(dev);
@@ -2883,7 +2937,7 @@ static void nv_link_irq(struct net_device *dev)
 	dprintk(KERN_INFO "%s: link change irq, status 0x%x.\n", dev->name, miistat);
 
 	if (miistat & (NVREG_MIISTAT_LINKCHANGE))
-		nv_linkchange(dev);
+		schedule_work(&np->linkchange_task);
 	dprintk(KERN_DEBUG "%s: link change notification done.\n", dev->name);
 }
 
@@ -2894,34 +2948,39 @@ static irqreturn_t __nv_nic_irq(struct net_device *dev, bool optimized)
 	u32 events;
 	int handled = 0;
 	u32 upd_mask = 0;
+	bool msix = (np->msi_flags & NV_MSI_X_ENABLED);
 
 	dprintk(KERN_DEBUG "%s: nv_nic_irq%s\n", dev->name,
 		optimized ? "_optimized" : "");
 
-	spin_lock(&np->lock);
-
-	if (!(np->msi_flags & NV_MSI_X_ENABLED)) {
+	if (!msix)
 		events = readl(base + NvRegIrqStatus) & NVREG_IRQSTAT_MASK;
-		writel(NVREG_IRQSTAT_MASK, base + NvRegIrqStatus);
-	} else {
+	else
 		events = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQSTAT_MASK;
-		writel(NVREG_IRQSTAT_MASK, base + NvRegMSIXIrqStatus);
-	}
 
 	dprintk(KERN_DEBUG "%s: irq: %08x\n", dev->name, events);
 
+	spin_lock(&np->lock);
+
 	if (!(events & np->irqmask))
 		goto out;
 
-	if (events & NVREG_IRQ_RX_ALL) {
-		netif_rx_schedule(dev, &np->napi);
+	if (!msix)
+		writel(NVREG_IRQSTAT_MASK, base + NvRegIrqStatus);
+	else
+		writel(NVREG_IRQSTAT_MASK, base + NvRegMSIXIrqStatus);
+
+	if ((events & NVREG_IRQ_RX_ALL) &&
+	    (netif_rx_schedule_prep(dev, &np->tx_napi))) {
+		__netif_rx_schedule(dev, &np->napi);
 
 		/* Disable furthur receive irq's */
 		upd_mask |= NVREG_IRQ_RX_ALL;
 	}
 
-	if (events & NVREG_IRQ_TX_ALL) {
-		netif_rx_schedule(dev, &np->tx_napi);
+	if ((events & NVREG_IRQ_TX_ALL) &&
+	    (netif_rx_schedule_prep(dev, &np->tx_napi))) {
+		__netif_rx_schedule(dev, &np->tx_napi);
 
 		/* Disable furthur xmit irq's */
 		upd_mask |= NVREG_IRQ_TX_ALL;
@@ -2930,7 +2989,7 @@ static irqreturn_t __nv_nic_irq(struct net_device *dev, bool optimized)
 	if (upd_mask) {
 		np->irqmask &= ~upd_mask;
 
-		if (np->msi_flags & NV_MSI_X_ENABLED)
+		if (msix)
 			writel(upd_mask, base + NvRegIrqMask);
 		else
 			writel(np->irqmask, base + NvRegIrqMask);
@@ -2940,7 +2999,7 @@ static irqreturn_t __nv_nic_irq(struct net_device *dev, bool optimized)
 		nv_link_irq(dev);
 
 	if (unlikely(np->need_linktimer && time_after(jiffies, np->link_timeout))) {
-		nv_linkchange(dev);
+		schedule_work(&np->linkchange_task);
 		np->link_timeout = jiffies + LINK_TIMEOUT;
 	}
 
@@ -2958,7 +3017,7 @@ static irqreturn_t __nv_nic_irq(struct net_device *dev, bool optimized)
 
 	if (unlikely(events & NVREG_IRQ_RECOVER_ERROR)) {
 		/* disable interrupts on the nic */
-		if (!(np->msi_flags & NV_MSI_X_ENABLED))
+		if (!msix)
 			writel(0, base + NvRegIrqMask);
 		else
 			writel(np->irqmask, base + NvRegIrqMask);
@@ -3001,20 +3060,15 @@ static irqreturn_t nv_nic_irq_other(int foo, void *data)
 
 static irqreturn_t nv_nic_irq_tx(int foo, void *data)
 {
-	struct net_device *dev = (struct net_device *) data;
+	struct net_device *dev = data;
 	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
-	u32 events;
 
-	events = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQ_TX_ALL;
-	writel(NVREG_IRQ_TX_ALL, base + NvRegMSIXIrqStatus);
+	writel(NVREG_IRQ_TX_ALL, base + NvRegMSIXIrqStatus);	/* ack ints */
+	writel(NVREG_IRQ_TX_ALL, base + NvRegIrqMask);	    /* disable ints */
+
+	netif_rx_schedule(dev, &np->tx_napi);
 
-	if (events) {
-		netif_rx_schedule(dev, &np->tx_napi);
-		/* disable receive interrupts on the nic */
-		writel(NVREG_IRQ_TX_ALL, base + NvRegIrqMask);
-		pci_push(base);
-	}
 	return IRQ_HANDLED;
 }
 
@@ -3090,26 +3144,21 @@ static int nv_napi_poll(struct napi_struct *napi, int budget)
 
 static irqreturn_t nv_nic_irq_rx(int foo, void *data)
 {
-	struct net_device *dev = (struct net_device *) data;
+	struct net_device *dev = data;
 	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
-	u32 events;
 
-	events = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQ_RX_ALL;
-	writel(NVREG_IRQ_RX_ALL, base + NvRegMSIXIrqStatus);
+	writel(NVREG_IRQ_RX_ALL, base + NvRegMSIXIrqStatus);	/* ack ints */
+	writel(NVREG_IRQ_RX_ALL, base + NvRegIrqMask);	    /* disable ints */
+
+	netif_rx_schedule(dev, &np->napi);
 
-	if (events) {
-		netif_rx_schedule(dev, &np->napi);
-		/* disable receive interrupts on the nic */
-		writel(NVREG_IRQ_RX_ALL, base + NvRegIrqMask);
-		pci_push(base);
-	}
 	return IRQ_HANDLED;
 }
 
 static irqreturn_t nv_nic_irq_test(int foo, void *data)
 {
-	struct net_device *dev = (struct net_device *) data;
+	struct net_device *dev = data;
 	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
 	u32 events;
@@ -3287,12 +3336,17 @@ static void nv_reset_task(struct work_struct *work)
 	struct net_device *dev = np->dev;
 	u8 __iomem *base = get_hwbase(dev);
 	u32 mask;
+	unsigned long flags;
+
+	mutex_lock(&np->hw_mutex);
 
 	/*
 	 * First disable irq(s) and then
 	 * reenable interrupts on the nic, we have to do this before calling
 	 * nv_nic_irq because that may decide to do otherwise
 	 */
+	netif_tx_lock_bh(dev);
+	spin_lock_irqsave(&np->lock, flags);
 
 	if (!using_multi_irqs(dev)) {
 		mask = np->irqmask;
@@ -3308,11 +3362,7 @@ static void nv_reset_task(struct work_struct *work)
 	np->reset_task_irq = 0;
 
 	printk(KERN_INFO "forcedeth: MAC in recoverable error state\n");
-	if (!netif_running(dev))
-		goto out;
 
-	netif_tx_lock_bh(dev);
-	spin_lock(&np->lock);
 	/* stop engines */
 	nv_stop_txrx(dev);
 	nv_txrx_reset(dev);
@@ -3334,12 +3384,14 @@ static void nv_reset_task(struct work_struct *work)
 
 	/* restart rx engine */
 	nv_start_txrx(dev);
-	spin_unlock(&np->lock);
-	netif_tx_unlock_bh(dev);
 
-out:
 	writel(mask, base + NvRegIrqMask);
 	pci_push(base);
+
+	spin_unlock_irqrestore(&np->lock, flags);
+	netif_tx_unlock_bh(dev);
+
+	mutex_unlock(&np->hw_mutex);
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -4321,29 +4373,45 @@ static void nv_get_strings(struct net_device *dev, u32 stringset, u8 *buffer)
 	}
 }
 
+static int nv_ethtool_begin (struct net_device *dev)
+{
+	struct fe_priv *np = get_nvpriv(dev);
+
+	mutex_lock(&np->hw_mutex);
+}
+
+static void nv_ethtool_complete (struct net_device *dev)
+{
+	struct fe_priv *np = get_nvpriv(dev);
+
+	mutex_unlock(&np->hw_mutex);
+}
+
 static const struct ethtool_ops ops = {
-	.get_drvinfo = nv_get_drvinfo,
-	.get_link = ethtool_op_get_link,
-	.get_wol = nv_get_wol,
-	.set_wol = nv_set_wol,
-	.get_settings = nv_get_settings,
-	.set_settings = nv_set_settings,
-	.get_regs_len = nv_get_regs_len,
-	.get_regs = nv_get_regs,
-	.nway_reset = nv_nway_reset,
-	.set_tso = nv_set_tso,
-	.get_ringparam = nv_get_ringparam,
-	.set_ringparam = nv_set_ringparam,
-	.get_pauseparam = nv_get_pauseparam,
-	.set_pauseparam = nv_set_pauseparam,
-	.get_rx_csum = nv_get_rx_csum,
-	.set_rx_csum = nv_set_rx_csum,
-	.set_tx_csum = nv_set_tx_csum,
-	.set_sg = nv_set_sg,
-	.get_strings = nv_get_strings,
-	.get_ethtool_stats = nv_get_ethtool_stats,
-	.get_sset_count = nv_get_sset_count,
-	.self_test = nv_self_test,
+	.begin			= nv_ethtool_begin,
+	.complete		= nv_ethtool_complete,
+	.get_drvinfo		= nv_get_drvinfo,
+	.get_link		= ethtool_op_get_link,
+	.get_wol		= nv_get_wol,
+	.set_wol		= nv_set_wol,
+	.get_settings		= nv_get_settings,
+	.set_settings		= nv_set_settings,
+	.get_regs_len		= nv_get_regs_len,
+	.get_regs		= nv_get_regs,
+	.nway_reset		= nv_nway_reset,
+	.set_tso		= nv_set_tso,
+	.get_ringparam		= nv_get_ringparam,
+	.set_ringparam		= nv_set_ringparam,
+	.get_pauseparam		= nv_get_pauseparam,
+	.set_pauseparam		= nv_set_pauseparam,
+	.get_rx_csum		= nv_get_rx_csum,
+	.set_rx_csum		= nv_set_rx_csum,
+	.set_tx_csum		= nv_set_tx_csum,
+	.set_sg			= nv_set_sg,
+	.get_strings		= nv_get_strings,
+	.get_ethtool_stats	= nv_get_ethtool_stats,
+	.get_sset_count		= nv_get_sset_count,
+	.self_test		= nv_self_test,
 };
 
 static void nv_vlan_rx_register(struct net_device *dev, struct vlan_group *grp)
@@ -4524,9 +4592,13 @@ static int nv_open(struct net_device *dev)
 	}
 	/* set linkspeed to invalid value, thus force nv_update_linkspeed
 	 * to init hw */
+	mutex_lock(&np->hw_mutex);
 	np->linkspeed = 0;
 	ret = nv_update_linkspeed(dev);
+	mutex_unlock(&np->hw_mutex);
+
 	nv_start_txrx(dev);
+
 	napi_enable(&np->napi);
 	napi_enable(&np->tx_napi);
 	netif_start_queue(dev);
@@ -4558,13 +4630,17 @@ static int nv_close(struct net_device *dev)
 	u8 __iomem *base;
 
 	netif_stop_queue(dev);
-	napi_disable(&np->napi);
-	napi_disable(&np->tx_napi);
-	synchronize_irq(dev->irq);
 
 	del_timer_sync(&np->oom_kick);
 	cancel_rearming_delayed_work(&np->stats_task);
 	cancel_work_sync(&np->reset_task);
+	cancel_work_sync(&np->linkchange_task);
+	cancel_work_sync(&np->mcast_task);
+
+	napi_disable(&np->napi);
+	napi_disable(&np->tx_napi);
+
+	synchronize_irq(dev->irq);
 
 	spin_lock_irq(&np->lock);
 	nv_stop_txrx(dev);
@@ -4619,6 +4695,8 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 	np->oom_kick.data = (unsigned long) dev;
 	np->oom_kick.function = &nv_do_rx_refill;	/* timer handler */
 	INIT_WORK(&np->reset_task, nv_reset_task);
+	INIT_WORK(&np->linkchange_task, nv_linkchange_task);
+	INIT_WORK(&np->mcast_task, nv_mcast_task);
 	INIT_DELAYED_WORK(&np->stats_task, nv_stats_task);
 
 	err = pci_enable_device(pci_dev);
