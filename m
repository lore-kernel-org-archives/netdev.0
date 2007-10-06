From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH 3/5] forcedeth: process TX completions using NAPI
Date: Sat, 6 Oct 2007 11:14:38 -0400
Message-ID: <20071006151438.GC17488@havoc.gtf.org>
References: <20071006151250.GA17020@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: netdev@vger.kernel.org, Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:39797 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759460AbXJFPOj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Oct 2007 11:14:39 -0400
Content-Disposition: inline
In-Reply-To: <20071006151250.GA17020@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


commit 57cbfacc00d69be2ba02b65d1021442273b76263
Author: Jeff Garzik <jeff@garzik.org>
Date:   Fri Oct 5 23:25:56 2007 -0400

    [netdrvr] forcedeth: process TX completions using NAPI
    
    Signed-off-by: Jeff Garzik <jgarzik@redhat.com>

 drivers/net/forcedeth.c |  143 +++++++++++++++++++++++++++---------------------
 1 file changed, 83 insertions(+), 60 deletions(-)

57cbfacc00d69be2ba02b65d1021442273b76263
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 1d1a5f5..1c236e6 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -744,6 +744,7 @@ struct fe_priv {
 
 	struct net_device *dev;
 	struct napi_struct napi;
+	struct napi_struct tx_napi;
 
 	/* General data:
 	 * Locking: spin_lock(&np->lock); */
@@ -810,7 +811,6 @@ struct fe_priv {
 	union ring_type tx_ring;
 	u32 tx_flags;
 	int tx_ring_size;
-	int tx_stop;
 
 	/* vlan fields */
 	struct vlan_group *vlangrp;
@@ -1763,10 +1763,7 @@ static int nv_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	empty_slots = nv_get_empty_tx_slots(np);
 	if (unlikely(empty_slots <= entries)) {
-		spin_lock_irq(&np->lock);
 		netif_stop_queue(dev);
-		np->tx_stop = 1;
-		spin_unlock_irq(&np->lock);
 		return NETDEV_TX_BUSY;
 	}
 
@@ -1879,10 +1876,7 @@ static int nv_start_xmit_optimized(struct sk_buff *skb, struct net_device *dev)
 
 	empty_slots = nv_get_empty_tx_slots(np);
 	if (unlikely(empty_slots <= entries)) {
-		spin_lock_irq(&np->lock);
 		netif_stop_queue(dev);
-		np->tx_stop = 1;
-		spin_unlock_irq(&np->lock);
 		return NETDEV_TX_BUSY;
 	}
 
@@ -1987,12 +1981,16 @@ static int nv_start_xmit_optimized(struct sk_buff *skb, struct net_device *dev)
  *
  * Caller must own np->lock.
  */
-static void nv_tx_done(struct net_device *dev)
+static int nv_tx_done(struct net_device *dev, int limit)
 {
 	struct fe_priv *np = netdev_priv(dev);
 	u32 flags;
+	int orig_limit = limit;
 	struct ring_desc* orig_get_tx = np->get_tx.orig;
 
+	if (unlikely(limit < 1))
+		return 0;
+
 	while ((np->get_tx.orig != np->put_tx.orig) &&
 	       !((flags = le32_to_cpu(np->get_tx.orig->flaglen)) & NV_TX_VALID)) {
 
@@ -2039,19 +2037,28 @@ static void nv_tx_done(struct net_device *dev)
 			np->get_tx.orig = np->first_tx.orig;
 		if (unlikely(np->get_tx_ctx++ == np->last_tx_ctx))
 			np->get_tx_ctx = np->first_tx_ctx;
+
+		limit--;
+		if (limit == 0)
+			break;
 	}
-	if (unlikely((np->tx_stop == 1) && (np->get_tx.orig != orig_get_tx))) {
-		np->tx_stop = 0;
+
+	if (np->get_tx.orig != orig_get_tx)
 		netif_wake_queue(dev);
-	}
+
+	return orig_limit - limit;
 }
 
-static void nv_tx_done_optimized(struct net_device *dev, int limit)
+static int nv_tx_done_optimized(struct net_device *dev, int limit)
 {
 	struct fe_priv *np = netdev_priv(dev);
 	u32 flags;
+	int orig_limit = limit;
 	struct ring_desc_ex* orig_get_tx = np->get_tx.ex;
 
+	if (unlikely(limit < 1))
+		return 0;
+
 	while ((np->get_tx.ex != np->put_tx.ex) &&
 	       !((flags = le32_to_cpu(np->get_tx.ex->flaglen)) & NV_TX_VALID) &&
 	       (limit-- > 0)) {
@@ -2075,10 +2082,11 @@ static void nv_tx_done_optimized(struct net_device *dev, int limit)
 		if (unlikely(np->get_tx_ctx++ == np->last_tx_ctx))
 			np->get_tx_ctx = np->first_tx_ctx;
 	}
-	if (unlikely((np->tx_stop == 1) && (np->get_tx.ex != orig_get_tx))) {
-		np->tx_stop = 0;
+
+	if (np->get_tx.ex != orig_get_tx)
 		netif_wake_queue(dev);
-	}
+
+	return orig_limit - limit;
 }
 
 /*
@@ -2149,9 +2157,9 @@ static void nv_tx_timeout(struct net_device *dev)
 	/* 1) stop tx engine */
 	nv_stop_tx(dev);
 
-	/* 2) check that the packets were not sent already: */
+	/* 2) process all pending tx completions */
 	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
-		nv_tx_done(dev);
+		nv_tx_done(dev, np->tx_ring_size);
 	else
 		nv_tx_done_optimized(dev, np->tx_ring_size);
 
@@ -2923,6 +2931,7 @@ static irqreturn_t __nv_nic_irq(struct net_device *dev, bool optimized)
 	u8 __iomem *base = get_hwbase(dev);
 	u32 events;
 	int handled = 0;
+	u32 upd_mask = 0;
 
 	dprintk(KERN_DEBUG "%s: nv_nic_irq%s\n", dev->name,
 		optimized ? "_optimized" : "");
@@ -2942,19 +2951,25 @@ static irqreturn_t __nv_nic_irq(struct net_device *dev, bool optimized)
 	if (!(events & np->irqmask))
 		goto out;
 
-	if (optimized)
-		nv_tx_done_optimized(dev, TX_WORK_PER_LOOP);
-	else
-		nv_tx_done(dev);
-
 	if (events & NVREG_IRQ_RX_ALL) {
 		netif_rx_schedule(dev, &np->napi);
 
 		/* Disable furthur receive irq's */
-		np->irqmask &= ~NVREG_IRQ_RX_ALL;
+		upd_mask |= NVREG_IRQ_RX_ALL;
+	}
+
+	if (events & NVREG_IRQ_TX_ALL) {
+		netif_rx_schedule(dev, &np->tx_napi);
+
+		/* Disable furthur xmit irq's */
+		upd_mask |= NVREG_IRQ_TX_ALL;
+	}
+
+	if (upd_mask) {
+		np->irqmask &= ~upd_mask;
 
 		if (np->msi_flags & NV_MSI_X_ENABLED)
-			writel(NVREG_IRQ_RX_ALL, base + NvRegIrqMask);
+			writel(upd_mask, base + NvRegIrqMask);
 		else
 			writel(np->irqmask, base + NvRegIrqMask);
 	}
@@ -3019,7 +3034,7 @@ static irqreturn_t nv_nic_irq_optimized(int foo, void *data)
 
 static irqreturn_t nv_nic_irq_other(int foo, void *data)
 {
-	struct net_device *dev = (struct net_device *) data;
+	struct net_device *dev = data;
 	return __nv_nic_irq(dev, true);
 }
 
@@ -3029,45 +3044,48 @@ static irqreturn_t nv_nic_irq_tx(int foo, void *data)
 	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
 	u32 events;
-	int i;
-	unsigned long flags;
 
-	dprintk(KERN_DEBUG "%s: nv_nic_irq_tx\n", dev->name);
+	events = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQ_TX_ALL;
+	writel(NVREG_IRQ_TX_ALL, base + NvRegMSIXIrqStatus);
 
-	for (i=0; ; i++) {
-		events = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQ_TX_ALL;
-		writel(NVREG_IRQ_TX_ALL, base + NvRegMSIXIrqStatus);
-		dprintk(KERN_DEBUG "%s: tx irq: %08x\n", dev->name, events);
-		if (!(events & np->irqmask))
-			break;
+	if (events) {
+		netif_rx_schedule(dev, &np->tx_napi);
+		/* disable receive interrupts on the nic */
+		writel(NVREG_IRQ_TX_ALL, base + NvRegIrqMask);
+		pci_push(base);
+	}
+	return IRQ_HANDLED;
+}
 
-		spin_lock_irqsave(&np->lock, flags);
-		nv_tx_done_optimized(dev, TX_WORK_PER_LOOP);
-		spin_unlock_irqrestore(&np->lock, flags);
+static int nv_napi_tx_poll(struct napi_struct *napi, int budget)
+{
+	struct fe_priv *np = container_of(napi, struct fe_priv, napi);
+	struct net_device *dev = np->dev;
+	u8 __iomem *base = get_hwbase(dev);
+	unsigned long flags;
+	int pkts;
 
-		if (unlikely(events & (NVREG_IRQ_TX_ERR))) {
-			dprintk(KERN_DEBUG "%s: received irq with events 0x%x. Probably TX fail.\n",
-						dev->name, events);
-		}
-		if (unlikely(i > max_interrupt_work)) {
-			spin_lock_irqsave(&np->lock, flags);
-			/* disable interrupts on the nic */
-			writel(NVREG_IRQ_TX_ALL, base + NvRegIrqMask);
-			pci_push(base);
+	spin_lock_irqsave(&np->lock, flags);
 
-			if (!np->in_shutdown) {
-				np->nic_poll_irq |= NVREG_IRQ_TX_ALL;
-				mod_timer(&np->nic_poll, jiffies + POLL_WAIT);
-			}
-			spin_unlock_irqrestore(&np->lock, flags);
-			printk(KERN_DEBUG "%s: too many iterations (%d) in nv_nic_irq_tx.\n", dev->name, i);
-			break;
-		}
+	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
+		pkts = nv_tx_done(dev, budget);
+	else
+		pkts = nv_tx_done_optimized(dev, budget);
 
+	if (pkts < budget) {
+		/* re-enable receive interrupts */
+		__netif_rx_complete(dev, napi);
+
+		np->irqmask |= NVREG_IRQ_TX_ALL;
+		if (np->msi_flags & NV_MSI_X_ENABLED)
+			writel(NVREG_IRQ_TX_ALL, base + NvRegIrqMask);
+		else
+			writel(np->irqmask, base + NvRegIrqMask);
 	}
-	dprintk(KERN_DEBUG "%s: nv_nic_irq_tx completed\n", dev->name);
 
-	return IRQ_RETVAL(i);
+	spin_unlock_irqrestore(&np->lock, flags);
+
+	return pkts;
 }
 
 static int nv_napi_poll(struct napi_struct *napi, int budget)
@@ -4316,7 +4334,8 @@ static void nv_self_test(struct net_device *dev, struct ethtool_test *test, u64
 
 	if (test->flags & ETH_TEST_FL_OFFLINE) {
 		if (netif_running(dev)) {
-			netif_stop_queue(dev);
+			netif_tx_disable(dev);
+			napi_disable(&np->tx_napi);
 			napi_disable(&np->napi);
 			netif_tx_lock_bh(dev);
 			spin_lock_irq(&np->lock);
@@ -4375,8 +4394,9 @@ static void nv_self_test(struct net_device *dev, struct ethtool_test *test, u64
 			/* restart rx engine */
 			nv_start_rx(dev);
 			nv_start_tx(dev);
-			netif_start_queue(dev);
 			napi_enable(&np->napi);
+			napi_enable(&np->tx_napi);
+			netif_start_queue(dev);
 			nv_enable_hw_interrupts(dev, np->irqmask);
 		}
 	}
@@ -4603,8 +4623,9 @@ static int nv_open(struct net_device *dev)
 	ret = nv_update_linkspeed(dev);
 	nv_start_rx(dev);
 	nv_start_tx(dev);
-	netif_start_queue(dev);
 	napi_enable(&np->napi);
+	napi_enable(&np->tx_napi);
+	netif_start_queue(dev);
 
 	if (ret) {
 		netif_carrier_on(dev);
@@ -4635,14 +4656,15 @@ static int nv_close(struct net_device *dev)
 	spin_lock_irq(&np->lock);
 	np->in_shutdown = 1;
 	spin_unlock_irq(&np->lock);
+	netif_stop_queue(dev);
 	napi_disable(&np->napi);
+	napi_disable(&np->tx_napi);
 	synchronize_irq(dev->irq);
 
 	del_timer_sync(&np->oom_kick);
 	del_timer_sync(&np->nic_poll);
 	del_timer_sync(&np->stats_poll);
 
-	netif_stop_queue(dev);
 	spin_lock_irq(&np->lock);
 	nv_stop_tx(dev);
 	nv_stop_rx(dev);
@@ -4850,6 +4872,7 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 	dev->poll_controller = nv_poll_controller;
 #endif
 	netif_napi_add(dev, &np->napi, nv_napi_poll, RX_WORK_PER_LOOP);
+	netif_napi_add(dev, &np->tx_napi, nv_napi_tx_poll, RX_WORK_PER_LOOP);
 	SET_ETHTOOL_OPS(dev, &ops);
 	dev->tx_timeout = nv_tx_timeout;
 	dev->watchdog_timeo = NV_WATCHDOG_TIMEO;
