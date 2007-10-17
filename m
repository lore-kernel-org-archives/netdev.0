From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH 5/6] forcedeth: use NAPI for TX completion
Date: Wed, 17 Oct 2007 01:54:42 -0400
Message-ID: <20071017055442.GF20534@havoc.gtf.org>
References: <20071017055251.GA19972@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Manfred Spraul <manfred@colorfullife.com>,
	Ingo Molnar <mingo@elte.hu>, Ayaz Abdulla <aabdulla@nvidia.com>
To: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:36447 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933324AbXJQFyn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 01:54:43 -0400
Content-Disposition: inline
In-Reply-To: <20071017055251.GA19972@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


commit a7c00e796597b797ceac3c18e8b85c124196c5ab
Author: Jeff Garzik <jeff@garzik.org>
Date:   Tue Oct 16 17:33:19 2007 -0400

    [netdrvr] forcedeth: use NAPI for TX completion
    
    A hand-rolled TX poll & work limit system was already in place, so it
    was easy to convert the TX path to use NAPI.
    
    This simplifies the code, and enables future improvements and
    simplifications.
    
    Signed-off-by: Jeff Garzik <jgarzik@redhat.com>

 drivers/net/forcedeth.c |  170 +++++++++++++++++++++++++-----------------------
 1 file changed, 90 insertions(+), 80 deletions(-)

a7c00e796597b797ceac3c18e8b85c124196c5ab
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 32a8893..81fe016 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -660,6 +660,7 @@ struct fe_priv {
 
 	struct net_device *dev;
 	struct napi_struct napi;
+	struct napi_struct tx_napi;
 
 	/* General data:
 	 * Locking: spin_lock(&np->lock); */
@@ -725,7 +726,6 @@ struct fe_priv {
 	union ring_type tx_ring;
 	u32 tx_flags;
 	int tx_ring_size;
-	int tx_stop;
 
 	/* vlan fields */
 	struct vlan_group *vlangrp;
@@ -1732,10 +1732,7 @@ static int nv_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	empty_slots = nv_get_empty_tx_slots(np);
 	if (unlikely(empty_slots <= entries)) {
-		spin_lock_irq(&np->lock);
 		netif_stop_queue(dev);
-		np->tx_stop = 1;
-		spin_unlock_irq(&np->lock);
 		return NETDEV_TX_BUSY;
 	}
 
@@ -1848,10 +1845,7 @@ static int nv_start_xmit_optimized(struct sk_buff *skb, struct net_device *dev)
 
 	empty_slots = nv_get_empty_tx_slots(np);
 	if (unlikely(empty_slots <= entries)) {
-		spin_lock_irq(&np->lock);
 		netif_stop_queue(dev);
-		np->tx_stop = 1;
-		spin_unlock_irq(&np->lock);
 		return NETDEV_TX_BUSY;
 	}
 
@@ -1956,14 +1950,15 @@ static int nv_start_xmit_optimized(struct sk_buff *skb, struct net_device *dev)
  *
  * Caller must own np->lock.
  */
-static void nv_tx_done(struct net_device *dev)
+static int nv_tx_done(struct net_device *dev, int limit)
 {
 	struct fe_priv *np = netdev_priv(dev);
 	u32 flags;
-	struct ring_desc* orig_get_tx = np->get_tx.orig;
+	int tx_work = 0;
 
 	while ((np->get_tx.orig != np->put_tx.orig) &&
-	       !((flags = le32_to_cpu(np->get_tx.orig->flaglen)) & NV_TX_VALID)) {
+	       !((flags = le32_to_cpu(np->get_tx.orig->flaglen)) & NV_TX_VALID) &&
+	       (tx_work < limit)) {
 
 		dprintk(KERN_DEBUG "%s: nv_tx_done: flags 0x%x.\n",
 					dev->name, flags);
@@ -2008,22 +2003,25 @@ static void nv_tx_done(struct net_device *dev)
 			np->get_tx.orig = np->first_tx.orig;
 		if (unlikely(np->get_tx_ctx++ == np->last_tx_ctx))
 			np->get_tx_ctx = np->first_tx_ctx;
+
+		tx_work++;
 	}
-	if (unlikely((np->tx_stop == 1) && (np->get_tx.orig != orig_get_tx))) {
-		np->tx_stop = 0;
+
+	if (tx_work)
 		netif_wake_queue(dev);
-	}
+
+	return tx_work;
 }
 
-static void nv_tx_done_optimized(struct net_device *dev, int limit)
+static int nv_tx_done_optimized(struct net_device *dev, int limit)
 {
 	struct fe_priv *np = netdev_priv(dev);
 	u32 flags;
-	struct ring_desc_ex* orig_get_tx = np->get_tx.ex;
+	int tx_work = 0;
 
 	while ((np->get_tx.ex != np->put_tx.ex) &&
 	       !((flags = le32_to_cpu(np->get_tx.ex->flaglen)) & NV_TX_VALID) &&
-	       (limit-- > 0)) {
+	       (tx_work < limit)) {
 
 		dprintk(KERN_DEBUG "%s: nv_tx_done_optimized: flags 0x%x.\n",
 					dev->name, flags);
@@ -2043,11 +2041,14 @@ static void nv_tx_done_optimized(struct net_device *dev, int limit)
 			np->get_tx.ex = np->first_tx.ex;
 		if (unlikely(np->get_tx_ctx++ == np->last_tx_ctx))
 			np->get_tx_ctx = np->first_tx_ctx;
+
+		tx_work++;
 	}
-	if (unlikely((np->tx_stop == 1) && (np->get_tx.ex != orig_get_tx))) {
-		np->tx_stop = 0;
+
+	if (tx_work)
 		netif_wake_queue(dev);
-	}
+
+	return tx_work;
 }
 
 /*
@@ -2120,7 +2121,7 @@ static void nv_tx_timeout(struct net_device *dev)
 
 	/* 2) check that the packets were not sent already: */
 	if (!nv_optimized(np))
-		nv_tx_done(dev);
+		nv_tx_done(dev, np->tx_ring_size);
 	else
 		nv_tx_done_optimized(dev, np->tx_ring_size);
 
@@ -2888,7 +2889,7 @@ static irqreturn_t __nv_nic_irq(struct net_device *dev, bool optimized)
 {
 	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = np->base;
-	u32 events;
+	u32 events, updmask = 0;
 	int i;
 
 	dprintk(KERN_DEBUG "%s: __nv_nic_irq\n", dev->name);
@@ -2905,22 +2906,22 @@ static irqreturn_t __nv_nic_irq(struct net_device *dev, bool optimized)
 		if (!(events & np->irqmask))
 			break;
 
-		spin_lock(&np->lock);
-		if (optimized)
-			nv_tx_done_optimized(dev, TX_WORK_PER_LOOP);
-		else
-			nv_tx_done(dev);
-		spin_unlock(&np->lock);
-
 		if (events & NVREG_IRQ_RX_ALL) {
 			netif_rx_schedule(dev, &np->napi);
+			updmask |= NVREG_IRQ_RX_ALL;
+		}
+
+		if (events & NVREG_IRQ_TX_ALL) {
+			netif_rx_schedule(dev, &np->tx_napi);
+			updmask |= NVREG_IRQ_TX_ALL;
+		}
 
-			/* Disable furthur receive irq's */
+		if (updmask) {
 			spin_lock(&np->lock);
-			np->irqmask &= ~NVREG_IRQ_RX_ALL;
+			np->irqmask &= ~updmask;
 
 			if (np->msi_flags & NV_MSI_X_ENABLED)
-				writel(NVREG_IRQ_RX_ALL, base + NvRegIrqMask);
+				writel(updmask, base + NvRegIrqMask);
 			else
 				writel(np->irqmask, base + NvRegIrqMask);
 			spin_unlock(&np->lock);
@@ -2998,58 +2999,11 @@ static irqreturn_t nv_nic_irq_optimized(int foo, void *data)
 	return __nv_nic_irq(dev, true);
 }
 
-static irqreturn_t nv_nic_irq_tx(int foo, void *data)
-{
-	struct net_device *dev = data;
-	struct fe_priv *np = netdev_priv(dev);
-	u8 __iomem *base = get_hwbase(dev);
-	u32 events;
-	int i;
-	unsigned long flags;
-
-	dprintk(KERN_DEBUG "%s: nv_nic_irq_tx\n", dev->name);
-
-	for (i=0; ; i++) {
-		events = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQ_TX_ALL;
-		writel(NVREG_IRQ_TX_ALL, base + NvRegMSIXIrqStatus);
-		dprintk(KERN_DEBUG "%s: tx irq: %08x\n", dev->name, events);
-		if (!(events & np->irqmask))
-			break;
-
-		spin_lock_irqsave(&np->lock, flags);
-		nv_tx_done_optimized(dev, TX_WORK_PER_LOOP);
-		spin_unlock_irqrestore(&np->lock, flags);
-
-		if (unlikely(events & (NVREG_IRQ_TX_ERR))) {
-			dprintk(KERN_DEBUG "%s: received irq with events 0x%x. Probably TX fail.\n",
-						dev->name, events);
-		}
-		if (unlikely(i > max_interrupt_work)) {
-			spin_lock_irqsave(&np->lock, flags);
-			/* disable interrupts on the nic */
-			writel(NVREG_IRQ_TX_ALL, base + NvRegIrqMask);
-			pci_push(base);
-
-			if (netif_running(dev)) {
-				np->nic_poll_irq |= NVREG_IRQ_TX_ALL;
-				mod_timer(&np->nic_poll, jiffies + POLL_WAIT);
-			}
-			spin_unlock_irqrestore(&np->lock, flags);
-			printk(KERN_DEBUG "%s: too many iterations (%d) in nv_nic_irq_tx.\n", dev->name, i);
-			break;
-		}
-
-	}
-	dprintk(KERN_DEBUG "%s: nv_nic_irq_tx completed\n", dev->name);
-
-	return IRQ_RETVAL(i);
-}
-
 static int nv_napi_poll(struct napi_struct *napi, int budget)
 {
 	struct fe_priv *np = container_of(napi, struct fe_priv, napi);
 	struct net_device *dev = np->dev;
-	u8 __iomem *base = get_hwbase(dev);
+	u8 __iomem *base = np->base;
 	unsigned long flags;
 	int pkts, retcode;
 
@@ -3089,7 +3043,7 @@ static irqreturn_t nv_nic_irq_rx(int foo, void *data)
 {
 	struct net_device *dev = data;
 	struct fe_priv *np = netdev_priv(dev);
-	u8 __iomem *base = get_hwbase(dev);
+	u8 __iomem *base = np->base;
 	u32 events;
 
 	events = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQ_RX_ALL;
@@ -3104,6 +3058,57 @@ static irqreturn_t nv_nic_irq_rx(int foo, void *data)
 	return IRQ_HANDLED;
 }
 
+static irqreturn_t nv_nic_irq_tx(int foo, void *data)
+{
+	struct net_device *dev = data;
+	struct fe_priv *np = netdev_priv(dev);
+	u8 __iomem *base = np->base;
+	u32 events;
+
+	events = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQ_TX_ALL;
+	writel(NVREG_IRQ_TX_ALL, base + NvRegMSIXIrqStatus);
+
+	if (events) {
+		netif_rx_schedule(dev, &np->tx_napi);
+		/* disable receive interrupts on the nic */
+		writel(NVREG_IRQ_TX_ALL, base + NvRegIrqMask);
+		pci_push(base);
+	}
+	return IRQ_HANDLED;
+}
+
+static int nv_napi_tx_poll(struct napi_struct *napi, int budget)
+{
+	struct fe_priv *np = container_of(napi, struct fe_priv, tx_napi);
+	struct net_device *dev = np->dev;
+	u8 __iomem *base = np->base;
+	unsigned long flags;
+	int pkts;
+
+	spin_lock_irqsave(&np->lock, flags);
+
+	if (nv_optimized(np))
+		pkts = nv_tx_done_optimized(dev, budget);
+	else
+		pkts = nv_tx_done(dev, budget);
+
+	if (pkts < budget) {
+		/* re-enable receive interrupts */
+
+		__netif_rx_complete(dev, napi);
+
+		np->irqmask |= NVREG_IRQ_RX_ALL;
+		if (np->msi_flags & NV_MSI_X_ENABLED)
+			writel(NVREG_IRQ_RX_ALL, base + NvRegIrqMask);
+		else
+			writel(np->irqmask, base + NvRegIrqMask);
+	}
+
+	spin_unlock_irqrestore(&np->lock, flags);
+
+	return pkts;
+}
+
 static irqreturn_t nv_nic_irq_other(int foo, void *data)
 {
 	struct net_device *dev = data;
@@ -4348,6 +4353,7 @@ static void nv_self_test(struct net_device *dev, struct ethtool_test *test, u64
 		if (netif_running(dev)) {
 			netif_stop_queue(dev);
 
+			napi_disable(&np->tx_napi);
 			napi_disable(&np->napi);
 
 			netif_tx_lock_bh(dev);
@@ -4406,6 +4412,7 @@ static void nv_self_test(struct net_device *dev, struct ethtool_test *test, u64
 			netif_start_queue(dev);
 
 			napi_enable(&np->napi);
+			napi_enable(&np->tx_napi);
 
 			nv_enable_hw_interrupts(dev, np->irqmask);
 		}
@@ -4632,6 +4639,7 @@ static int nv_open(struct net_device *dev)
 	nv_start_rxtx(dev);
 	netif_start_queue(dev);
 	napi_enable(&np->napi);
+	napi_enable(&np->tx_napi);
 
 	if (ret) {
 		netif_carrier_on(dev);
@@ -4662,6 +4670,7 @@ static int nv_close(struct net_device *dev)
 	spin_lock_irq(&np->lock);
 	spin_unlock_irq(&np->lock);
 
+	napi_disable(&np->tx_napi);
 	napi_disable(&np->napi);
 	synchronize_irq(dev->irq);
 
@@ -4876,6 +4885,7 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 #endif
 
 	netif_napi_add(dev, &np->napi, nv_napi_poll, RX_WORK_PER_LOOP);
+	netif_napi_add(dev, &np->tx_napi, nv_napi_tx_poll, TX_WORK_PER_LOOP);
 
 	SET_ETHTOOL_OPS(dev, &ops);
 	dev->tx_timeout = nv_tx_timeout;
