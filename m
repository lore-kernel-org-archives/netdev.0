From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH 2/5] forcedeth: interrupt handling cleanup
Date: Sat, 6 Oct 2007 11:14:00 -0400
Message-ID: <20071006151400.GB17488@havoc.gtf.org>
References: <20071006151250.GA17020@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: netdev@vger.kernel.org, Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:35967 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760432AbXJFPOB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Oct 2007 11:14:01 -0400
Content-Disposition: inline
In-Reply-To: <20071006151250.GA17020@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


commit a606d2a111cdf948da5d69eb1de5526c5c2dafef
Author: Jeff Garzik <jeff@garzik.org>
Date:   Fri Oct 5 22:56:05 2007 -0400

    [netdrvr] forcedeth: interrupt handling cleanup
    
    * nv_nic_irq_optimized() and nv_nic_irq_other() were complete duplicates
      of nv_nic_irq(), with the exception of one function call.  Consolidate
      all three into a single interrupt handler, deleting a lot of redundant
      code.
    
    * greatly simplify irq handler locking.
    
      Prior to this change, the irq handler(s) would acquire and release
      np->lock for each action (RX, TX, other events).
    
      For the common case -- RX or TX work -- the lock is always acquired,
      making all successive acquire/release combinations largely redundant.
    
      Acquire the lock at the beginning of the irq handler, and release it at
      the end of the irq handler.  This is simple, easy, and obvious.
    
    * remove irq handler work loop.
    
      All interesting events emanating from the irq handler either have
      their own work loops, or they poke a timer into action.
    
      Therefore, delete the pointless master interrupt handler work loop.
    
    Signed-off-by: Jeff Garzik <jgarzik@redhat.com>

 drivers/net/forcedeth.c |  325 +++++++++++-------------------------------------
 1 file changed, 77 insertions(+), 248 deletions(-)

a606d2a111cdf948da5d69eb1de5526c5c2dafef
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 49906cc..1d1a5f5 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -2917,208 +2917,110 @@ static void nv_link_irq(struct net_device *dev)
 	dprintk(KERN_DEBUG "%s: link change notification done.\n", dev->name);
 }
 
-static irqreturn_t nv_nic_irq(int foo, void *data)
+static irqreturn_t __nv_nic_irq(struct net_device *dev, bool optimized)
 {
-	struct net_device *dev = (struct net_device *) data;
 	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
 	u32 events;
-	int i;
+	int handled = 0;
 
-	dprintk(KERN_DEBUG "%s: nv_nic_irq\n", dev->name);
+	dprintk(KERN_DEBUG "%s: nv_nic_irq%s\n", dev->name,
+		optimized ? "_optimized" : "");
 
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
+	spin_lock(&np->lock);
 
-		spin_lock(&np->lock);
-		nv_tx_done(dev);
-		spin_unlock(&np->lock);
+	if (!(np->msi_flags & NV_MSI_X_ENABLED)) {
+		events = readl(base + NvRegIrqStatus) & NVREG_IRQSTAT_MASK;
+		writel(NVREG_IRQSTAT_MASK, base + NvRegIrqStatus);
+	} else {
+		events = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQSTAT_MASK;
+		writel(NVREG_IRQSTAT_MASK, base + NvRegMSIXIrqStatus);
+	}
 
-		if (events & NVREG_IRQ_RX_ALL) {
-			netif_rx_schedule(dev, &np->napi);
+	dprintk(KERN_DEBUG "%s: irq: %08x\n", dev->name, events);
 
-			/* Disable furthur receive irq's */
-			spin_lock(&np->lock);
-			np->irqmask &= ~NVREG_IRQ_RX_ALL;
+	if (!(events & np->irqmask))
+		goto out;
 
-			if (np->msi_flags & NV_MSI_X_ENABLED)
-				writel(NVREG_IRQ_RX_ALL, base + NvRegIrqMask);
-			else
-				writel(np->irqmask, base + NvRegIrqMask);
-			spin_unlock(&np->lock);
-		}
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
+	if (optimized)
+		nv_tx_done_optimized(dev, TX_WORK_PER_LOOP);
+	else
+		nv_tx_done(dev);
 
-			if (!np->in_shutdown) {
-				np->nic_poll_irq = np->irqmask;
-				np->recover_error = 1;
-				mod_timer(&np->nic_poll, jiffies + POLL_WAIT);
-			}
-			spin_unlock(&np->lock);
-			break;
-		}
-		if (unlikely(i > max_interrupt_work)) {
-			spin_lock(&np->lock);
-			/* disable interrupts on the nic */
-			if (!(np->msi_flags & NV_MSI_X_ENABLED))
-				writel(0, base + NvRegIrqMask);
-			else
-				writel(np->irqmask, base + NvRegIrqMask);
-			pci_push(base);
+	if (events & NVREG_IRQ_RX_ALL) {
+		netif_rx_schedule(dev, &np->napi);
 
-			if (!np->in_shutdown) {
-				np->nic_poll_irq = np->irqmask;
-				mod_timer(&np->nic_poll, jiffies + POLL_WAIT);
-			}
-			spin_unlock(&np->lock);
-			printk(KERN_DEBUG "%s: too many iterations (%d) in nv_nic_irq.\n", dev->name, i);
-			break;
-		}
+		/* Disable furthur receive irq's */
+		np->irqmask &= ~NVREG_IRQ_RX_ALL;
 
+		if (np->msi_flags & NV_MSI_X_ENABLED)
+			writel(NVREG_IRQ_RX_ALL, base + NvRegIrqMask);
+		else
+			writel(np->irqmask, base + NvRegIrqMask);
 	}
-	dprintk(KERN_DEBUG "%s: nv_nic_irq completed\n", dev->name);
 
-	return IRQ_RETVAL(i);
-}
+	if (unlikely(events & NVREG_IRQ_LINK))
+		nv_link_irq(dev);
 
-/**
- * All _optimized functions are used to help increase performance
- * (reduce CPU and increase throughput). They use descripter version 3,
- * compiler directives, and reduce memory accesses.
- */
-static irqreturn_t nv_nic_irq_optimized(int foo, void *data)
-{
-	struct net_device *dev = (struct net_device *) data;
-	struct fe_priv *np = netdev_priv(dev);
-	u8 __iomem *base = get_hwbase(dev);
-	u32 events;
-	int i;
+	if (unlikely(np->need_linktimer && time_after(jiffies, np->link_timeout))) {
+		nv_linkchange(dev);
+		np->link_timeout = jiffies + LINK_TIMEOUT;
+	}
 
-	dprintk(KERN_DEBUG "%s: nv_nic_irq_optimized\n", dev->name);
+	if (unlikely(events & (NVREG_IRQ_TX_ERR))) {
+		dprintk(KERN_DEBUG "%s: received irq with events 0x%x. "
+			"Probably TX fail.\n",
+			dev->name, events);
+	}
 
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
+	if (unlikely(events & (NVREG_IRQ_UNKNOWN))) {
+		printk(KERN_DEBUG "%s: received irq with unknown events 0x%x. "
+			"Please report\n",
+			dev->name, events);
+	}
 
-		spin_lock(&np->lock);
-		nv_tx_done_optimized(dev, TX_WORK_PER_LOOP);
-		spin_unlock(&np->lock);
+	if (unlikely(events & NVREG_IRQ_RECOVER_ERROR)) {
+		/* disable interrupts on the nic */
+		if (!(np->msi_flags & NV_MSI_X_ENABLED))
+			writel(0, base + NvRegIrqMask);
+		else
+			writel(np->irqmask, base + NvRegIrqMask);
+		pci_push(base);
 
-		if (events & NVREG_IRQ_RX_ALL) {
-			netif_rx_schedule(dev, &np->napi);
+		if (!np->in_shutdown) {
+			np->nic_poll_irq = np->irqmask;
+			np->recover_error = 1;
+			mod_timer(&np->nic_poll, jiffies + POLL_WAIT);
+		}
+	}
 
-			/* Disable furthur receive irq's */
-			spin_lock(&np->lock);
-			np->irqmask &= ~NVREG_IRQ_RX_ALL;
+	handled = 1;
 
-			if (np->msi_flags & NV_MSI_X_ENABLED)
-				writel(NVREG_IRQ_RX_ALL, base + NvRegIrqMask);
-			else
-				writel(np->irqmask, base + NvRegIrqMask);
-			spin_unlock(&np->lock);
-		}
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
+out:
+	spin_unlock(&np->lock);
 
-			if (!np->in_shutdown) {
-				np->nic_poll_irq = np->irqmask;
-				np->recover_error = 1;
-				mod_timer(&np->nic_poll, jiffies + POLL_WAIT);
-			}
-			spin_unlock(&np->lock);
-			break;
-		}
+	dprintk(KERN_DEBUG "%s: nv_nic_irq%s completed\n", dev->name,
+		optimized ? "_optimized" : "");
 
-		if (unlikely(i > max_interrupt_work)) {
-			spin_lock(&np->lock);
-			/* disable interrupts on the nic */
-			if (!(np->msi_flags & NV_MSI_X_ENABLED))
-				writel(0, base + NvRegIrqMask);
-			else
-				writel(np->irqmask, base + NvRegIrqMask);
-			pci_push(base);
+	return IRQ_RETVAL(handled);
+}
 
-			if (!np->in_shutdown) {
-				np->nic_poll_irq = np->irqmask;
-				mod_timer(&np->nic_poll, jiffies + POLL_WAIT);
-			}
-			spin_unlock(&np->lock);
-			printk(KERN_DEBUG "%s: too many iterations (%d) in nv_nic_irq.\n", dev->name, i);
-			break;
-		}
+static irqreturn_t nv_nic_irq(int foo, void *data)
+{
+	struct net_device *dev = data;
+	return __nv_nic_irq(dev, false);
+}
 
-	}
-	dprintk(KERN_DEBUG "%s: nv_nic_irq_optimized completed\n", dev->name);
+static irqreturn_t nv_nic_irq_optimized(int foo, void *data)
+{
+	struct net_device *dev = data;
+	return __nv_nic_irq(dev, true);
+}
 
-	return IRQ_RETVAL(i);
+static irqreturn_t nv_nic_irq_other(int foo, void *data)
+{
+	struct net_device *dev = (struct net_device *) data;
+	return __nv_nic_irq(dev, true);
 }
 
 static irqreturn_t nv_nic_irq_tx(int foo, void *data)
@@ -3227,79 +3129,6 @@ static irqreturn_t nv_nic_irq_rx(int foo, void *data)
 	return IRQ_HANDLED;
 }
 
-static irqreturn_t nv_nic_irq_other(int foo, void *data)
-{
-	struct net_device *dev = (struct net_device *) data;
-	struct fe_priv *np = netdev_priv(dev);
-	u8 __iomem *base = get_hwbase(dev);
-	u32 events;
-	int i;
-	unsigned long flags;
-
-	dprintk(KERN_DEBUG "%s: nv_nic_irq_other\n", dev->name);
-
-	for (i=0; ; i++) {
-		events = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQ_OTHER;
-		writel(NVREG_IRQ_OTHER, base + NvRegMSIXIrqStatus);
-		dprintk(KERN_DEBUG "%s: irq: %08x\n", dev->name, events);
-		if (!(events & np->irqmask))
-			break;
-
-		/* check tx in case we reached max loop limit in tx isr */
-		spin_lock_irqsave(&np->lock, flags);
-		nv_tx_done_optimized(dev, TX_WORK_PER_LOOP);
-		spin_unlock_irqrestore(&np->lock, flags);
-
-		if (events & NVREG_IRQ_LINK) {
-			spin_lock_irqsave(&np->lock, flags);
-			nv_link_irq(dev);
-			spin_unlock_irqrestore(&np->lock, flags);
-		}
-		if (np->need_linktimer && time_after(jiffies, np->link_timeout)) {
-			spin_lock_irqsave(&np->lock, flags);
-			nv_linkchange(dev);
-			spin_unlock_irqrestore(&np->lock, flags);
-			np->link_timeout = jiffies + LINK_TIMEOUT;
-		}
-		if (events & NVREG_IRQ_RECOVER_ERROR) {
-			spin_lock_irq(&np->lock);
-			/* disable interrupts on the nic */
-			writel(NVREG_IRQ_OTHER, base + NvRegIrqMask);
-			pci_push(base);
-
-			if (!np->in_shutdown) {
-				np->nic_poll_irq |= NVREG_IRQ_OTHER;
-				np->recover_error = 1;
-				mod_timer(&np->nic_poll, jiffies + POLL_WAIT);
-			}
-			spin_unlock_irq(&np->lock);
-			break;
-		}
-		if (events & (NVREG_IRQ_UNKNOWN)) {
-			printk(KERN_DEBUG "%s: received irq with unknown events 0x%x. Please report\n",
-						dev->name, events);
-		}
-		if (unlikely(i > max_interrupt_work)) {
-			spin_lock_irqsave(&np->lock, flags);
-			/* disable interrupts on the nic */
-			writel(NVREG_IRQ_OTHER, base + NvRegIrqMask);
-			pci_push(base);
-
-			if (!np->in_shutdown) {
-				np->nic_poll_irq |= NVREG_IRQ_OTHER;
-				mod_timer(&np->nic_poll, jiffies + POLL_WAIT);
-			}
-			spin_unlock_irqrestore(&np->lock, flags);
-			printk(KERN_DEBUG "%s: too many iterations (%d) in nv_nic_irq_other.\n", dev->name, i);
-			break;
-		}
-
-	}
-	dprintk(KERN_DEBUG "%s: nv_nic_irq_other completed\n", dev->name);
-
-	return IRQ_RETVAL(i);
-}
-
 static irqreturn_t nv_nic_irq_test(int foo, void *data)
 {
 	struct net_device *dev = (struct net_device *) data;
