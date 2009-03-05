From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 9/13] forcedeth: remove isr processing loop
Date: Thu, 05 Mar 2009 13:02:22 -0500
Message-ID: <49B013AE.9000604@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090909030706090605040303"
To: Manfred Spraul <manfred@colorfullife.com>,
	Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>,
	"David S. Miller" <davem@davemloft.net>,
	nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate04.nvidia.com ([216.228.112.152]:1506 "EHLO
	hqemgate04.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755391AbZCEVBP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2009 16:01:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090909030706090605040303
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch is only a subset of changes so that it is easier to see the 
modifications. This patch removes the isr 'for' loop and shifts all the 
logic to account for new tab spacing.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>


--------------090909030706090605040303
Content-Type: text/plain;
 name="patch-forcedeth-dynamic-2"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-dynamic-2"

--- old/drivers/net/forcedeth.c	2009-03-05 10:45:40.000000000 -0800
+++ new/drivers/net/forcedeth.c	2009-03-05 10:45:56.000000000 -0800
@@ -3423,99 +3423,78 @@
 	struct net_device *dev = (struct net_device *) data;
 	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
-	int i;
 
 	dprintk(KERN_DEBUG "%s: nv_nic_irq\n", dev->name);
 
-	for (i=0; ; i++) {
-		if (!(np->msi_flags & NV_MSI_X_ENABLED)) {
-			np->events = readl(base + NvRegIrqStatus);
-			writel(NVREG_IRQSTAT_MASK, base + NvRegIrqStatus);
-		} else {
-			np->events = readl(base + NvRegMSIXIrqStatus);
-			writel(NVREG_IRQSTAT_MASK, base + NvRegMSIXIrqStatus);
-		}
-		dprintk(KERN_DEBUG "%s: irq: %08x\n", dev->name, np->events);
-		if (!(np->events & np->irqmask))
-			break;
+	if (!(np->msi_flags & NV_MSI_X_ENABLED)) {
+		np->events = readl(base + NvRegIrqStatus);
+		writel(NVREG_IRQSTAT_MASK, base + NvRegIrqStatus);
+	} else {
+		np->events = readl(base + NvRegMSIXIrqStatus);
+		writel(NVREG_IRQSTAT_MASK, base + NvRegMSIXIrqStatus);
+	}
+	dprintk(KERN_DEBUG "%s: irq: %08x\n", dev->name, np->events);
+	if (!(np->events & np->irqmask))
+		return IRQ_NONE;
 
-		nv_msi_workaround(np);
+	nv_msi_workaround(np);
 
 #ifdef CONFIG_FORCEDETH_NAPI
-		spin_lock(&np->lock);
-		napi_schedule(&np->napi);
+	spin_lock(&np->lock);
+	napi_schedule(&np->napi);
 
-		/* Disable furthur irq's
-		   (msix not enabled with napi) */
-		writel(0, base + NvRegIrqMask);
+	/* Disable furthur irq's
+	   (msix not enabled with napi) */
+	writel(0, base + NvRegIrqMask);
 
-		spin_unlock(&np->lock);
+	spin_unlock(&np->lock);
 
-		return IRQ_HANDLED;
+	return IRQ_HANDLED;
 #else
-		spin_lock(&np->lock);
-		nv_tx_done(dev, np->tx_ring_size);
-		spin_unlock(&np->lock);
-
-		if (nv_rx_process(dev, RX_WORK_PER_LOOP)) {
-			if (unlikely(nv_alloc_rx(dev))) {
-				spin_lock(&np->lock);
-				if (!np->in_shutdown)
-					mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
-				spin_unlock(&np->lock);
-			}
-		}
+	spin_lock(&np->lock);
+	nv_tx_done(dev, np->tx_ring_size);
+	spin_unlock(&np->lock);
 
-		if (unlikely(np->events & NVREG_IRQ_LINK)) {
-			spin_lock(&np->lock);
-			nv_link_irq(dev);
-			spin_unlock(&np->lock);
-		}
-		if (unlikely(np->need_linktimer && time_after(jiffies, np->link_timeout))) {
+	if (nv_rx_process(dev, RX_WORK_PER_LOOP)) {
+		if (unlikely(nv_alloc_rx(dev))) {
 			spin_lock(&np->lock);
-			nv_linkchange(dev);
+			if (!np->in_shutdown)
+				mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
 			spin_unlock(&np->lock);
-			np->link_timeout = jiffies + LINK_TIMEOUT;
 		}
-		if (unlikely(np->events & NVREG_IRQ_RECOVER_ERROR)) {
-			spin_lock(&np->lock);
-			/* disable interrupts on the nic */
-			if (!(np->msi_flags & NV_MSI_X_ENABLED))
-				writel(0, base + NvRegIrqMask);
-			else
-				writel(np->irqmask, base + NvRegIrqMask);
-			pci_push(base);
+	}
 
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
+	if (unlikely(np->events & NVREG_IRQ_LINK)) {
+		spin_lock(&np->lock);
+		nv_link_irq(dev);
+		spin_unlock(&np->lock);
+	}
+	if (unlikely(np->need_linktimer && time_after(jiffies, np->link_timeout))) {
+		spin_lock(&np->lock);
+		nv_linkchange(dev);
+		spin_unlock(&np->lock);
+		np->link_timeout = jiffies + LINK_TIMEOUT;
+	}
+	if (unlikely(np->events & NVREG_IRQ_RECOVER_ERROR)) {
+		spin_lock(&np->lock);
+		/* disable interrupts on the nic */
+		if (!(np->msi_flags & NV_MSI_X_ENABLED))
+			writel(0, base + NvRegIrqMask);
+		else
+			writel(np->irqmask, base + NvRegIrqMask);
+		pci_push(base);
 
-			if (!np->in_shutdown) {
-				np->nic_poll_irq = np->irqmask;
-				mod_timer(&np->nic_poll, jiffies + POLL_WAIT);
-			}
-			spin_unlock(&np->lock);
-			printk(KERN_DEBUG "%s: too many iterations (%d) in nv_nic_irq.\n", dev->name, i);
-			break;
+		if (!np->in_shutdown) {
+			np->nic_poll_irq = np->irqmask;
+			np->recover_error = 1;
+			mod_timer(&np->nic_poll, jiffies + POLL_WAIT);
 		}
-#endif
+		spin_unlock(&np->lock);
 	}
+#endif
 	dprintk(KERN_DEBUG "%s: nv_nic_irq completed\n", dev->name);
 
-	return IRQ_RETVAL(i);
+	return IRQ_HANDLED;
 }
 
 /**
@@ -3528,100 +3507,79 @@
 	struct net_device *dev = (struct net_device *) data;
 	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
-	int i;
 
 	dprintk(KERN_DEBUG "%s: nv_nic_irq_optimized\n", dev->name);
 
-	for (i=0; ; i++) {
-		if (!(np->msi_flags & NV_MSI_X_ENABLED)) {
-			np->events = readl(base + NvRegIrqStatus);
-			writel(NVREG_IRQSTAT_MASK, base + NvRegIrqStatus);
-		} else {
-			np->events = readl(base + NvRegMSIXIrqStatus);
-			writel(NVREG_IRQSTAT_MASK, base + NvRegMSIXIrqStatus);
-		}
-		dprintk(KERN_DEBUG "%s: irq: %08x\n", dev->name, np->events);
-		if (!(np->events & np->irqmask))
-			break;
+	if (!(np->msi_flags & NV_MSI_X_ENABLED)) {
+		np->events = readl(base + NvRegIrqStatus);
+		writel(NVREG_IRQSTAT_MASK, base + NvRegIrqStatus);
+	} else {
+		np->events = readl(base + NvRegMSIXIrqStatus);
+		writel(NVREG_IRQSTAT_MASK, base + NvRegMSIXIrqStatus);
+	}
+	dprintk(KERN_DEBUG "%s: irq: %08x\n", dev->name, np->events);
+	if (!(np->events & np->irqmask))
+		return IRQ_NONE;
 
-		nv_msi_workaround(np);
+	nv_msi_workaround(np);
 
 #ifdef CONFIG_FORCEDETH_NAPI
-		spin_lock(&np->lock);
-		napi_schedule(&np->napi);
+	spin_lock(&np->lock);
+	napi_schedule(&np->napi);
 
-		/* Disable furthur irq's
-		   (msix not enabled with napi) */
-		writel(0, base + NvRegIrqMask);
+	/* Disable furthur irq's
+	   (msix not enabled with napi) */
+	writel(0, base + NvRegIrqMask);
 
-		spin_unlock(&np->lock);
+	spin_unlock(&np->lock);
 
-		return IRQ_HANDLED;
+	return IRQ_HANDLED;
 #else
-		spin_lock(&np->lock);
-		nv_tx_done_optimized(dev, TX_WORK_PER_LOOP);
-		spin_unlock(&np->lock);
-
-		if (nv_rx_process_optimized(dev, RX_WORK_PER_LOOP)) {
-			if (unlikely(nv_alloc_rx_optimized(dev))) {
-				spin_lock(&np->lock);
-				if (!np->in_shutdown)
-					mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
-				spin_unlock(&np->lock);
-			}
-		}
+	spin_lock(&np->lock);
+	nv_tx_done_optimized(dev, TX_WORK_PER_LOOP);
+	spin_unlock(&np->lock);
 
-		if (unlikely(np->events & NVREG_IRQ_LINK)) {
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
-		if (unlikely(np->events & NVREG_IRQ_RECOVER_ERROR)) {
+	if (nv_rx_process_optimized(dev, RX_WORK_PER_LOOP)) {
+		if (unlikely(nv_alloc_rx_optimized(dev))) {
 			spin_lock(&np->lock);
-			/* disable interrupts on the nic */
-			if (!(np->msi_flags & NV_MSI_X_ENABLED))
-				writel(0, base + NvRegIrqMask);
-			else
-				writel(np->irqmask, base + NvRegIrqMask);
-			pci_push(base);
-
-			if (!np->in_shutdown) {
-				np->nic_poll_irq = np->irqmask;
-				np->recover_error = 1;
-				mod_timer(&np->nic_poll, jiffies + POLL_WAIT);
-			}
+			if (!np->in_shutdown)
+				mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
 			spin_unlock(&np->lock);
-			break;
 		}
+	}
 
-		if (unlikely(i > max_interrupt_work)) {
-			spin_lock(&np->lock);
-			/* disable interrupts on the nic */
-			if (!(np->msi_flags & NV_MSI_X_ENABLED))
-				writel(0, base + NvRegIrqMask);
-			else
-				writel(np->irqmask, base + NvRegIrqMask);
-			pci_push(base);
+	if (unlikely(np->events & NVREG_IRQ_LINK)) {
+		spin_lock(&np->lock);
+		nv_link_irq(dev);
+		spin_unlock(&np->lock);
+	}
+	if (unlikely(np->need_linktimer && time_after(jiffies, np->link_timeout))) {
+		spin_lock(&np->lock);
+		nv_linkchange(dev);
+		spin_unlock(&np->lock);
+		np->link_timeout = jiffies + LINK_TIMEOUT;
+	}
+	if (unlikely(np->events & NVREG_IRQ_RECOVER_ERROR)) {
+		spin_lock(&np->lock);
+		/* disable interrupts on the nic */
+		if (!(np->msi_flags & NV_MSI_X_ENABLED))
+			writel(0, base + NvRegIrqMask);
+		else
+			writel(np->irqmask, base + NvRegIrqMask);
+		pci_push(base);
 
-			if (!np->in_shutdown) {
-				np->nic_poll_irq = np->irqmask;
-				mod_timer(&np->nic_poll, jiffies + POLL_WAIT);
-			}
-			spin_unlock(&np->lock);
-			printk(KERN_DEBUG "%s: too many iterations (%d) in nv_nic_irq.\n", dev->name, i);
-			break;
+		if (!np->in_shutdown) {
+			np->nic_poll_irq = np->irqmask;
+			np->recover_error = 1;
+			mod_timer(&np->nic_poll, jiffies + POLL_WAIT);
 		}
-#endif
+		spin_unlock(&np->lock);
 	}
+
+#endif
 	dprintk(KERN_DEBUG "%s: nv_nic_irq_optimized completed\n", dev->name);
 
-	return IRQ_RETVAL(i);
+	return IRQ_HANDLED;
 }
 
 static irqreturn_t nv_nic_irq_tx(int foo, void *data)

--------------090909030706090605040303--
