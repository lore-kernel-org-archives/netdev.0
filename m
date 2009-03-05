From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 7/13] forcedeth: napi - handle all processing
Date: Thu, 05 Mar 2009 13:02:14 -0500
Message-ID: <49B013A6.6020507@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050309080407060609070205"
To: Manfred Spraul <manfred@colorfullife.com>,
	Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>,
	"David S. Miller" <davem@davemloft.net>,
	nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate03.nvidia.com ([216.228.112.145]:8401 "EHLO
	hqemgate03.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755433AbZCEVBK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2009 16:01:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050309080407060609070205
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

The napi poll routine has been modified to handle all interrupt events 
and process them accordingly. Therefore, the ISR will now only schedule 
the napi poll and disable all interrupts instead of just disabling rx 
interrupt.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>


--------------050309080407060609070205
Content-Type: text/plain;
 name="patch-forcedeth-napi-handle-all"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-napi-handle-all"

--- old/drivers/net/forcedeth.c	2009-03-05 10:41:51.000000000 -0800
+++ new/drivers/net/forcedeth.c	2009-03-05 10:42:05.000000000 -0800
@@ -3440,25 +3440,22 @@
 
 		nv_msi_workaround(np);
 
+#ifdef CONFIG_FORCEDETH_NAPI
 		spin_lock(&np->lock);
-		nv_tx_done(dev, np->tx_ring_size);
-		spin_unlock(&np->lock);
+		napi_schedule(&np->napi);
 
-#ifdef CONFIG_FORCEDETH_NAPI
-		if (np->events & NVREG_IRQ_RX_ALL) {
-			spin_lock(&np->lock);
-			napi_schedule(&np->napi);
+		/* Disable furthur irq's
+		   (msix not enabled with napi) */
+		writel(0, base + NvRegIrqMask);
 
-			/* Disable furthur receive irq's */
-			np->irqmask &= ~NVREG_IRQ_RX_ALL;
+		spin_unlock(&np->lock);
 
-			if (np->msi_flags & NV_MSI_X_ENABLED)
-				writel(NVREG_IRQ_RX_ALL, base + NvRegIrqMask);
-			else
-				writel(np->irqmask, base + NvRegIrqMask);
-			spin_unlock(&np->lock);
-		}
+		return IRQ_HANDLED;
 #else
+		spin_lock(&np->lock);
+		nv_tx_done(dev, np->tx_ring_size);
+		spin_unlock(&np->lock);
+
 		if (nv_rx_process(dev, RX_WORK_PER_LOOP)) {
 			if (unlikely(nv_alloc_rx(dev))) {
 				spin_lock(&np->lock);
@@ -3467,7 +3464,7 @@
 				spin_unlock(&np->lock);
 			}
 		}
-#endif
+
 		if (unlikely(np->events & NVREG_IRQ_LINK)) {
 			spin_lock(&np->lock);
 			nv_link_irq(dev);
@@ -3513,7 +3510,7 @@
 			printk(KERN_DEBUG "%s: too many iterations (%d) in nv_nic_irq.\n", dev->name, i);
 			break;
 		}
-
+#endif
 	}
 	dprintk(KERN_DEBUG "%s: nv_nic_irq completed\n", dev->name);
 
@@ -3548,25 +3545,22 @@
 
 		nv_msi_workaround(np);
 
+#ifdef CONFIG_FORCEDETH_NAPI
 		spin_lock(&np->lock);
-		nv_tx_done_optimized(dev, TX_WORK_PER_LOOP);
-		spin_unlock(&np->lock);
+		napi_schedule(&np->napi);
 
-#ifdef CONFIG_FORCEDETH_NAPI
-		if (np->events & NVREG_IRQ_RX_ALL) {
-			spin_lock(&np->lock);
-			napi_schedule(&np->napi);
+		/* Disable furthur irq's
+		   (msix not enabled with napi) */
+		writel(0, base + NvRegIrqMask);
 
-			/* Disable furthur receive irq's */
-			np->irqmask &= ~NVREG_IRQ_RX_ALL;
+		spin_unlock(&np->lock);
 
-			if (np->msi_flags & NV_MSI_X_ENABLED)
-				writel(NVREG_IRQ_RX_ALL, base + NvRegIrqMask);
-			else
-				writel(np->irqmask, base + NvRegIrqMask);
-			spin_unlock(&np->lock);
-		}
+		return IRQ_HANDLED;
 #else
+		spin_lock(&np->lock);
+		nv_tx_done_optimized(dev, TX_WORK_PER_LOOP);
+		spin_unlock(&np->lock);
+
 		if (nv_rx_process_optimized(dev, RX_WORK_PER_LOOP)) {
 			if (unlikely(nv_alloc_rx_optimized(dev))) {
 				spin_lock(&np->lock);
@@ -3575,7 +3569,7 @@
 				spin_unlock(&np->lock);
 			}
 		}
-#endif
+
 		if (unlikely(np->events & NVREG_IRQ_LINK)) {
 			spin_lock(&np->lock);
 			nv_link_irq(dev);
@@ -3622,7 +3616,7 @@
 			printk(KERN_DEBUG "%s: too many iterations (%d) in nv_nic_irq.\n", dev->name, i);
 			break;
 		}
-
+#endif
 	}
 	dprintk(KERN_DEBUG "%s: nv_nic_irq_optimized completed\n", dev->name);
 
@@ -3682,9 +3676,17 @@
 	int pkts, retcode;
 
 	if (!nv_optimized(np)) {
+		spin_lock_irqsave(&np->lock, flags);
+		nv_tx_done(dev, np->tx_ring_size);
+		spin_unlock_irqrestore(&np->lock, flags);
+
 		pkts = nv_rx_process(dev, budget);
 		retcode = nv_alloc_rx(dev);
 	} else {
+		spin_lock_irqsave(&np->lock, flags);
+		nv_tx_done_optimized(dev, np->tx_ring_size);
+		spin_unlock_irqrestore(&np->lock, flags);
+
 		pkts = nv_rx_process_optimized(dev, budget);
 		retcode = nv_alloc_rx_optimized(dev);
 	}
@@ -3696,17 +3698,37 @@
 		spin_unlock_irqrestore(&np->lock, flags);
 	}
 
+	if (unlikely(np->events & NVREG_IRQ_LINK)) {
+		spin_lock_irqsave(&np->lock, flags);
+		nv_link_irq(dev);
+		spin_unlock_irqrestore(&np->lock, flags);
+	}
+	if (unlikely(np->need_linktimer && time_after(jiffies, np->link_timeout))) {
+		spin_lock_irqsave(&np->lock, flags);
+		nv_linkchange(dev);
+		spin_unlock_irqrestore(&np->lock, flags);
+		np->link_timeout = jiffies + LINK_TIMEOUT;
+	}
+	if (unlikely(np->events & NVREG_IRQ_RECOVER_ERROR)) {
+		spin_lock_irqsave(&np->lock, flags);
+		if (!np->in_shutdown) {
+			np->nic_poll_irq = np->irqmask;
+			np->recover_error = 1;
+			mod_timer(&np->nic_poll, jiffies + POLL_WAIT);
+		}
+		spin_unlock_irqrestore(&np->lock, flags);
+		__napi_complete(napi);
+		return pkts;
+	}
+
 	if (pkts < budget) {
-		/* re-enable receive interrupts */
+		/* re-enable interrupts
+		   (msix not enabled in napi) */
 		spin_lock_irqsave(&np->lock, flags);
 
 		__napi_complete(napi);
 
-		np->irqmask |= NVREG_IRQ_RX_ALL;
-		if (np->msi_flags & NV_MSI_X_ENABLED)
-			writel(NVREG_IRQ_RX_ALL, base + NvRegIrqMask);
-		else
-			writel(np->irqmask, base + NvRegIrqMask);
+		writel(np->irqmask, base + NvRegIrqMask);
 
 		spin_unlock_irqrestore(&np->lock, flags);
 	}

--------------050309080407060609070205--
