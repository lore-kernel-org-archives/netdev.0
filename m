From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 9/12] forcedeth: irq data path optimization
Date: Sun, 21 Jan 2007 18:10:57 -0500
Message-ID: <45B3F301.6080202@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090703080609050009070108"
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate01.nvidia.com ([216.228.112.170]:6765 "EHLO
	HQEMGATE01.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751840AbXAVBGF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jan 2007 20:06:05 -0500
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090703080609050009070108
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch optimizes the irq data paths and cleans up the code.

Signed-Off-By: Ayaz Abdulla <aabdulla@nvidia.com>


--------------090703080609050009070108
Content-Type: text/plain;
 name="patch-irq-opti-cleanup"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-irq-opti-cleanup"

--- orig/drivers/net/forcedeth.c	2007-01-19 11:11:35.000000000 -0500
+++ new/drivers/net/forcedeth.c	2007-01-19 11:13:25.000000000 -0500
@@ -2777,7 +2777,6 @@
 			events = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQSTAT_MASK;
 			writel(NVREG_IRQSTAT_MASK, base + NvRegMSIXIrqStatus);
 		}
-		pci_push(base);
 		dprintk(KERN_DEBUG "%s: irq: %08x\n", dev->name, events);
 		if (!(events & np->irqmask))
 			break;
@@ -2786,22 +2785,46 @@
 		nv_tx_done(dev);
 		spin_unlock(&np->lock);
 
-		if (events & NVREG_IRQ_LINK) {
+#ifdef CONFIG_FORCEDETH_NAPI
+		if (events & NVREG_IRQ_RX_ALL) {
+			netif_rx_schedule(dev);
+
+			/* Disable furthur receive irq's */
+			spin_lock(&np->lock);
+			np->irqmask &= ~NVREG_IRQ_RX_ALL;
+
+			if (np->msi_flags & NV_MSI_X_ENABLED)
+				writel(NVREG_IRQ_RX_ALL, base + NvRegIrqMask);
+			else
+				writel(np->irqmask, base + NvRegIrqMask);
+			spin_unlock(&np->lock);
+		}
+#else
+		if (nv_rx_process(dev, dev->weight)) {
+			if (unlikely(nv_alloc_rx(dev))) {
+				spin_lock(&np->lock);
+				if (!np->in_shutdown)
+					mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
+				spin_unlock(&np->lock);
+			}
+		}
+#endif
+		if (unlikely(events & NVREG_IRQ_LINK)) {
 			spin_lock(&np->lock);
 			nv_link_irq(dev);
 			spin_unlock(&np->lock);
 		}
-		if (np->need_linktimer && time_after(jiffies, np->link_timeout)) {
+		if (unlikely(np->need_linktimer && time_after(jiffies, np->link_timeout))) {
 			spin_lock(&np->lock);
 			nv_linkchange(dev);
 			spin_unlock(&np->lock);
 			np->link_timeout = jiffies + LINK_TIMEOUT;
 		}
-		if (events & (NVREG_IRQ_TX_ERR)) {
+		if (unlikely(events & (NVREG_IRQ_TX_ERR))) {
 			dprintk(KERN_DEBUG "%s: received irq with events 0x%x. Probably TX fail.\n",
 						dev->name, events);
 		}
-		if (events & (NVREG_IRQ_UNKNOWN)) {
+		if (unlikely(events & (NVREG_IRQ_UNKNOWN))) {
 			printk(KERN_DEBUG "%s: received irq with unknown events 0x%x. Please report\n",
 						dev->name, events);
 		}
@@ -2822,30 +2845,7 @@
 			spin_unlock(&np->lock);
 			break;
 		}
-#ifdef CONFIG_FORCEDETH_NAPI
-		if (events & NVREG_IRQ_RX_ALL) {
-			netif_rx_schedule(dev);
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
-		nv_rx_process(dev, dev->weight);
-		if (nv_alloc_rx(dev)) {
-			spin_lock(&np->lock);
-			if (!np->in_shutdown)
-				mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
-			spin_unlock(&np->lock);
-		}
-#endif
-		if (i > max_interrupt_work) {
+		if (unlikely(i > max_interrupt_work)) {
 			spin_lock(&np->lock);
 			/* disable interrupts on the nic */
 			if (!(np->msi_flags & NV_MSI_X_ENABLED))
@@ -2869,6 +2869,13 @@
 	return IRQ_RETVAL(i);
 }
 
+#define TX_WORK_PER_LOOP  64
+#define RX_WORK_PER_LOOP  64
+/**
+ * All _optimized functions are used to help increase performance
+ * (reduce CPU and increase throughput). They use descripter version 3,
+ * compiler directives, and reduce memory accesses.
+ */
 static irqreturn_t nv_nic_irq_optimized(int foo, void *data)
 {
 	struct net_device *dev = (struct net_device *) data;
@@ -2887,7 +2894,6 @@
 			events = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQSTAT_MASK;
 			writel(NVREG_IRQSTAT_MASK, base + NvRegMSIXIrqStatus);
 		}
-		pci_push(base);
 		dprintk(KERN_DEBUG "%s: irq: %08x\n", dev->name, events);
 		if (!(events & np->irqmask))
 			break;
@@ -2896,22 +2902,46 @@
 		nv_tx_done_optimized(dev);
 		spin_unlock(&np->lock);
 
-		if (events & NVREG_IRQ_LINK) {
+#ifdef CONFIG_FORCEDETH_NAPI
+		if (events & NVREG_IRQ_RX_ALL) {
+			netif_rx_schedule(dev);
+
+			/* Disable furthur receive irq's */
+			spin_lock(&np->lock);
+			np->irqmask &= ~NVREG_IRQ_RX_ALL;
+
+			if (np->msi_flags & NV_MSI_X_ENABLED)
+				writel(NVREG_IRQ_RX_ALL, base + NvRegIrqMask);
+			else
+				writel(np->irqmask, base + NvRegIrqMask);
+			spin_unlock(&np->lock);
+		}
+#else
+		if (nv_rx_process_optimized(dev, dev->weight)) {
+			if (unlikely(nv_alloc_rx_optimized(dev))) {
+				spin_lock(&np->lock);
+				if (!np->in_shutdown)
+					mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
+				spin_unlock(&np->lock);
+			}
+		}
+#endif
+		if (unlikely(events & NVREG_IRQ_LINK)) {
 			spin_lock(&np->lock);
 			nv_link_irq(dev);
 			spin_unlock(&np->lock);
 		}
-		if (np->need_linktimer && time_after(jiffies, np->link_timeout)) {
+		if (unlikely(np->need_linktimer && time_after(jiffies, np->link_timeout))) {
 			spin_lock(&np->lock);
 			nv_linkchange(dev);
 			spin_unlock(&np->lock);
 			np->link_timeout = jiffies + LINK_TIMEOUT;
 		}
-		if (events & (NVREG_IRQ_TX_ERR)) {
+		if (unlikely(events & (NVREG_IRQ_TX_ERR))) {
 			dprintk(KERN_DEBUG "%s: received irq with events 0x%x. Probably TX fail.\n",
 						dev->name, events);
 		}
-		if (events & (NVREG_IRQ_UNKNOWN)) {
+		if (unlikely(events & (NVREG_IRQ_UNKNOWN))) {
 			printk(KERN_DEBUG "%s: received irq with unknown events 0x%x. Please report\n",
 						dev->name, events);
 		}
@@ -2933,30 +2963,7 @@
 			break;
 		}
 
-#ifdef CONFIG_FORCEDETH_NAPI
-		if (events & NVREG_IRQ_RX_ALL) {
-			netif_rx_schedule(dev);
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
-		nv_rx_process_optimized(dev, dev->weight);
-		if (nv_alloc_rx_optimized(dev)) {
-			spin_lock(&np->lock);
-			if (!np->in_shutdown)
-				mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
-			spin_unlock(&np->lock);
-		}
-#endif
-		if (i > max_interrupt_work) {
+		if (unlikely(i > max_interrupt_work)) {
 			spin_lock(&np->lock);
 			/* disable interrupts on the nic */
 			if (!(np->msi_flags & NV_MSI_X_ENABLED))
@@ -2994,7 +3001,6 @@
 	for (i=0; ; i++) {
 		events = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQ_TX_ALL;
 		writel(NVREG_IRQ_TX_ALL, base + NvRegMSIXIrqStatus);
-		pci_push(base);
 		dprintk(KERN_DEBUG "%s: tx irq: %08x\n", dev->name, events);
 		if (!(events & np->irqmask))
 			break;
@@ -3003,11 +3009,11 @@
 		nv_tx_done_optimized(dev);
 		spin_unlock_irqrestore(&np->lock, flags);
 
-		if (events & (NVREG_IRQ_TX_ERR)) {
+		if (unlikely(events & (NVREG_IRQ_TX_ERR))) {
 			dprintk(KERN_DEBUG "%s: received irq with events 0x%x. Probably TX fail.\n",
 						dev->name, events);
 		}
-		if (i > max_interrupt_work) {
+		if (unlikely(i > max_interrupt_work)) {
 			spin_lock_irqsave(&np->lock, flags);
 			/* disable interrupts on the nic */
 			writel(NVREG_IRQ_TX_ALL, base + NvRegIrqMask);
@@ -3105,20 +3111,20 @@
 	for (i=0; ; i++) {
 		events = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQ_RX_ALL;
 		writel(NVREG_IRQ_RX_ALL, base + NvRegMSIXIrqStatus);
-		pci_push(base);
 		dprintk(KERN_DEBUG "%s: rx irq: %08x\n", dev->name, events);
 		if (!(events & np->irqmask))
 			break;
 
-		nv_rx_process_optimized(dev, dev->weight);
-		if (nv_alloc_rx_optimized(dev)) {
-			spin_lock_irqsave(&np->lock, flags);
-			if (!np->in_shutdown)
-				mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
-			spin_unlock_irqrestore(&np->lock, flags);
+		if (nv_rx_process_optimized(dev, dev->weight)) {
+			if (unlikely(nv_alloc_rx_optimized(dev))) {
+				spin_lock_irqsave(&np->lock, flags);
+				if (!np->in_shutdown)
+					mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
+				spin_unlock_irqrestore(&np->lock, flags);
+			}
 		}
 
-		if (i > max_interrupt_work) {
+		if (unlikely(i > max_interrupt_work)) {
 			spin_lock_irqsave(&np->lock, flags);
 			/* disable interrupts on the nic */
 			writel(NVREG_IRQ_RX_ALL, base + NvRegIrqMask);
@@ -3153,7 +3159,6 @@
 	for (i=0; ; i++) {
 		events = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQ_OTHER;
 		writel(NVREG_IRQ_OTHER, base + NvRegMSIXIrqStatus);
-		pci_push(base);
 		dprintk(KERN_DEBUG "%s: irq: %08x\n", dev->name, events);
 		if (!(events & np->irqmask))
 			break;
@@ -3187,7 +3192,7 @@
 			printk(KERN_DEBUG "%s: received irq with unknown events 0x%x. Please report\n",
 						dev->name, events);
 		}
-		if (i > max_interrupt_work) {
+		if (unlikely(i > max_interrupt_work)) {
 			spin_lock_irqsave(&np->lock, flags);
 			/* disable interrupts on the nic */
 			writel(NVREG_IRQ_OTHER, base + NvRegIrqMask);
@@ -4969,7 +4974,7 @@
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = nv_poll_controller;
 #endif
-	dev->weight = 64;
+	dev->weight = RX_WORK_PER_LOOP;
 #ifdef CONFIG_FORCEDETH_NAPI
 	dev->poll = nv_napi_poll;
 #endif

--------------090703080609050009070108--
