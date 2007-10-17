From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH 3/6] forcedeth: eliminate some duplicate irq handling code
Date: Wed, 17 Oct 2007 01:54:01 -0400
Message-ID: <20071017055401.GD20534@havoc.gtf.org>
References: <20071017055251.GA19972@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Manfred Spraul <manfred@colorfullife.com>,
	Ingo Molnar <mingo@elte.hu>, Ayaz Abdulla <aabdulla@nvidia.com>
To: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:40761 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762583AbXJQFyF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 01:54:05 -0400
Content-Disposition: inline
In-Reply-To: <20071017055251.GA19972@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


commit c6ad879c65e6f91c7f61b86936e2ea39b16711da
Author: Jeff Garzik <jeff@garzik.org>
Date:   Tue Oct 16 11:43:27 2007 -0400

    [netdrvr] forcedeth: eliminate some duplicate irq handling code
    
    * nv_nic_irq_optimized() is the exactly same as nv_nic_irq(), save
      for three function calls.  Consolidate together into a single function
      __nv_nic_irq().
    
    * remove pointless casts from void* in other irq handling code
    
    Signed-off-by: Jeff Garzik <jgarzik@redhat.com>

 drivers/net/forcedeth.c |  167 ++++++++++--------------------------------------
 1 file changed, 38 insertions(+), 129 deletions(-)

c6ad879c65e6f91c7f61b86936e2ea39b16711da
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 39ade56..a4baad7 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -2937,15 +2937,14 @@ static void nv_link_irq(struct net_device *dev)
 	dprintk(KERN_DEBUG "%s: link change notification done.\n", dev->name);
 }
 
-static irqreturn_t nv_nic_irq(int foo, void *data)
+static irqreturn_t __nv_nic_irq(struct net_device *dev, bool optimized)
 {
-	struct net_device *dev = (struct net_device *) data;
 	struct fe_priv *np = netdev_priv(dev);
-	u8 __iomem *base = get_hwbase(dev);
+	u8 __iomem *base = np->base;
 	u32 events;
 	int i;
 
-	dprintk(KERN_DEBUG "%s: nv_nic_irq\n", dev->name);
+	dprintk(KERN_DEBUG "%s: __nv_nic_irq\n", dev->name);
 
 	for (i=0; ; i++) {
 		if (!(np->msi_flags & NV_MSI_X_ENABLED)) {
@@ -2960,7 +2959,10 @@ static irqreturn_t nv_nic_irq(int foo, void *data)
 			break;
 
 		spin_lock(&np->lock);
-		nv_tx_done(dev);
+		if (optimized)
+			nv_tx_done_optimized(dev, TX_WORK_PER_LOOP);
+		else
+			nv_tx_done(dev);
 		spin_unlock(&np->lock);
 
 #ifdef CONFIG_FORCEDETH_NAPI
@@ -2978,12 +2980,23 @@ static irqreturn_t nv_nic_irq(int foo, void *data)
 			spin_unlock(&np->lock);
 		}
 #else
-		if (nv_rx_process(dev, RX_WORK_PER_LOOP)) {
-			if (unlikely(nv_alloc_rx(dev))) {
-				spin_lock(&np->lock);
-				if (netif_running(dev))
-					mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
-				spin_unlock(&np->lock);
+		if (optimized) {
+			if (nv_rx_process_optimized(dev, RX_WORK_PER_LOOP)) {
+				if (unlikely(nv_alloc_rx_optimized(dev))) {
+					spin_lock(&np->lock);
+					if (netif_running(dev))
+						mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
+					spin_unlock(&np->lock);
+				}
+			}
+		} else {
+			if (nv_rx_process(dev, RX_WORK_PER_LOOP)) {
+				if (unlikely(nv_alloc_rx(dev))) {
+					spin_lock(&np->lock);
+					if (netif_running(dev))
+						mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
+					spin_unlock(&np->lock);
+				}
 			}
 		}
 #endif
@@ -3042,130 +3055,26 @@ static irqreturn_t nv_nic_irq(int foo, void *data)
 		}
 
 	}
-	dprintk(KERN_DEBUG "%s: nv_nic_irq completed\n", dev->name);
+	dprintk(KERN_DEBUG "%s: __nv_nic_irq completed\n", dev->name);
 
 	return IRQ_RETVAL(i);
 }
 
-/**
- * All _optimized functions are used to help increase performance
- * (reduce CPU and increase throughput). They use descripter version 3,
- * compiler directives, and reduce memory accesses.
- */
-static irqreturn_t nv_nic_irq_optimized(int foo, void *data)
+static irqreturn_t nv_nic_irq(int foo, void *data)
 {
-	struct net_device *dev = (struct net_device *) data;
-	struct fe_priv *np = netdev_priv(dev);
-	u8 __iomem *base = get_hwbase(dev);
-	u32 events;
-	int i;
-
-	dprintk(KERN_DEBUG "%s: nv_nic_irq_optimized\n", dev->name);
-
-	for (i=0; ; i++) {
-		if (!(np->msi_flags & NV_MSI_X_ENABLED)) {
-			events = readl(base + NvRegIrqStatus) & NVREG_IRQSTAT_MASK;
-			writel(NVREG_IRQSTAT_MASK, base + NvRegIrqStatus);
-		} else {
-			events = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQSTAT_MASK;
-			writel(NVREG_IRQSTAT_MASK, base + NvRegMSIXIrqStatus);
-		}
-		dprintk(KERN_DEBUG "%s: irq: %08x\n", dev->name, events);
-		if (!(events & np->irqmask))
-			break;
-
-		spin_lock(&np->lock);
-		nv_tx_done_optimized(dev, TX_WORK_PER_LOOP);
-		spin_unlock(&np->lock);
-
-#ifdef CONFIG_FORCEDETH_NAPI
-		if (events & NVREG_IRQ_RX_ALL) {
-			netif_rx_schedule(dev, &np->napi);
-
-			/* Disable furthur receive irq's */
-			spin_lock(&np->lock);
-			np->irqmask &= ~NVREG_IRQ_RX_ALL;
-
-			if (np->msi_flags & NV_MSI_X_ENABLED)
-				writel(NVREG_IRQ_RX_ALL, base + NvRegIrqMask);
-			else
-				writel(np->irqmask, base + NvRegIrqMask);
-			spin_unlock(&np->lock);
-		}
-#else
-		if (nv_rx_process_optimized(dev, RX_WORK_PER_LOOP)) {
-			if (unlikely(nv_alloc_rx_optimized(dev))) {
-				spin_lock(&np->lock);
-				if (netif_running(dev))
-					mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
-				spin_unlock(&np->lock);
-			}
-		}
-#endif
-		if (unlikely(events & NVREG_IRQ_LINK)) {
-			spin_lock(&np->lock);
-			nv_link_irq(dev);
-			spin_unlock(&np->lock);
-		}
-		if (unlikely(np->need_linktimer && time_after(jiffies, np->link_timeout))) {
-			spin_lock(&np->lock);
-			nv_linkchange(dev);
-			spin_unlock(&np->lock);
-			np->link_timeout = jiffies + LINK_TIMEOUT;
-		}
-		if (unlikely(events & (NVREG_IRQ_TX_ERR))) {
-			dprintk(KERN_DEBUG "%s: received irq with events 0x%x. Probably TX fail.\n",
-						dev->name, events);
-		}
-		if (unlikely(events & (NVREG_IRQ_UNKNOWN))) {
-			printk(KERN_DEBUG "%s: received irq with unknown events 0x%x. Please report\n",
-						dev->name, events);
-		}
-		if (unlikely(events & NVREG_IRQ_RECOVER_ERROR)) {
-			spin_lock(&np->lock);
-			/* disable interrupts on the nic */
-			if (!(np->msi_flags & NV_MSI_X_ENABLED))
-				writel(0, base + NvRegIrqMask);
-			else
-				writel(np->irqmask, base + NvRegIrqMask);
-			pci_push(base);
-
-			if (netif_running(dev)) {
-				np->nic_poll_irq = np->irqmask;
-				np->recover_error = 1;
-				mod_timer(&np->nic_poll, jiffies + POLL_WAIT);
-			}
-			spin_unlock(&np->lock);
-			break;
-		}
-
-		if (unlikely(i > max_interrupt_work)) {
-			spin_lock(&np->lock);
-			/* disable interrupts on the nic */
-			if (!(np->msi_flags & NV_MSI_X_ENABLED))
-				writel(0, base + NvRegIrqMask);
-			else
-				writel(np->irqmask, base + NvRegIrqMask);
-			pci_push(base);
-
-			if (netif_running(dev)) {
-				np->nic_poll_irq = np->irqmask;
-				mod_timer(&np->nic_poll, jiffies + POLL_WAIT);
-			}
-			spin_unlock(&np->lock);
-			printk(KERN_DEBUG "%s: too many iterations (%d) in nv_nic_irq.\n", dev->name, i);
-			break;
-		}
-
-	}
-	dprintk(KERN_DEBUG "%s: nv_nic_irq_optimized completed\n", dev->name);
+	struct net_device *dev = data;
+	return __nv_nic_irq(dev, false);
+}
 
-	return IRQ_RETVAL(i);
+static irqreturn_t nv_nic_irq_optimized(int foo, void *data)
+{
+	struct net_device *dev = data;
+	return __nv_nic_irq(dev, true);
 }
 
 static irqreturn_t nv_nic_irq_tx(int foo, void *data)
 {
-	struct net_device *dev = (struct net_device *) data;
+	struct net_device *dev = data;
 	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
 	u32 events;
@@ -3255,7 +3164,7 @@ static int nv_napi_poll(struct napi_struct *napi, int budget)
 #ifdef CONFIG_FORCEDETH_NAPI
 static irqreturn_t nv_nic_irq_rx(int foo, void *data)
 {
-	struct net_device *dev = (struct net_device *) data;
+	struct net_device *dev = data;
 	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
 	u32 events;
@@ -3274,7 +3183,7 @@ static irqreturn_t nv_nic_irq_rx(int foo, void *data)
 #else
 static irqreturn_t nv_nic_irq_rx(int foo, void *data)
 {
-	struct net_device *dev = (struct net_device *) data;
+	struct net_device *dev = data;
 	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
 	u32 events;
@@ -3322,7 +3231,7 @@ static irqreturn_t nv_nic_irq_rx(int foo, void *data)
 
 static irqreturn_t nv_nic_irq_other(int foo, void *data)
 {
-	struct net_device *dev = (struct net_device *) data;
+	struct net_device *dev = data;
 	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
 	u32 events;
@@ -3395,7 +3304,7 @@ static irqreturn_t nv_nic_irq_other(int foo, void *data)
 
 static irqreturn_t nv_nic_irq_test(int foo, void *data)
 {
-	struct net_device *dev = (struct net_device *) data;
+	struct net_device *dev = data;
 	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
 	u32 events;
