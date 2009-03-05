From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 5/13] forcedeth: remove overhead
Date: Thu, 05 Mar 2009 13:02:06 -0500
Message-ID: <49B0139E.6080109@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060800030201060600090106"
To: Manfred Spraul <manfred@colorfullife.com>,
	Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>,
	"David S. Miller" <davem@davemloft.net>,
	nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate03.nvidia.com ([216.228.112.145]:8541 "EHLO
	hqemgate03.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755975AbZCEVCD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2009 16:02:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060800030201060600090106
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch removes unnecessary overhead code. Firstly, there is no nead 
to mask off unwanted interrupts as we will be checking against the 
irqmask field anyways. Secondly, there has been no value in last few 
years from detecting error or unknown interrupts.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>


--------------060800030201060600090106
Content-Type: text/plain;
 name="patch-forcedeth-remove-overhead"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-remove-overhead"

--- old/drivers/net/forcedeth.c	2009-03-05 10:40:41.000000000 -0800
+++ new/drivers/net/forcedeth.c	2009-03-05 10:40:58.000000000 -0800
@@ -120,10 +120,6 @@
 #define NVREG_IRQ_RX_ALL		(NVREG_IRQ_RX_ERROR|NVREG_IRQ_RX|NVREG_IRQ_RX_NOBUF|NVREG_IRQ_RX_FORCED)
 #define NVREG_IRQ_OTHER			(NVREG_IRQ_TIMER|NVREG_IRQ_LINK|NVREG_IRQ_RECOVER_ERROR)
 
-#define NVREG_IRQ_UNKNOWN	(~(NVREG_IRQ_RX_ERROR|NVREG_IRQ_RX|NVREG_IRQ_RX_NOBUF|NVREG_IRQ_TX_ERR| \
-					NVREG_IRQ_TX_OK|NVREG_IRQ_TIMER|NVREG_IRQ_LINK|NVREG_IRQ_RX_FORCED| \
-					NVREG_IRQ_TX_FORCED|NVREG_IRQ_RECOVER_ERROR))
-
 	NvRegUnknownSetupReg6 = 0x008,
 #define NVREG_UNKSETUP6_VAL		3
 
@@ -3424,10 +3420,10 @@
 
 	for (i=0; ; i++) {
 		if (!(np->msi_flags & NV_MSI_X_ENABLED)) {
-			np->events = readl(base + NvRegIrqStatus) & NVREG_IRQSTAT_MASK;
+			np->events = readl(base + NvRegIrqStatus);
 			writel(NVREG_IRQSTAT_MASK, base + NvRegIrqStatus);
 		} else {
-			np->events = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQSTAT_MASK;
+			np->events = readl(base + NvRegMSIXIrqStatus);
 			writel(NVREG_IRQSTAT_MASK, base + NvRegMSIXIrqStatus);
 		}
 		dprintk(KERN_DEBUG "%s: irq: %08x\n", dev->name, np->events);
@@ -3475,14 +3471,6 @@
 			spin_unlock(&np->lock);
 			np->link_timeout = jiffies + LINK_TIMEOUT;
 		}
-		if (unlikely(np->events & (NVREG_IRQ_TX_ERR))) {
-			dprintk(KERN_DEBUG "%s: received irq with events 0x%x. Probably TX fail.\n",
-						dev->name, np->events);
-		}
-		if (unlikely(np->events & (NVREG_IRQ_UNKNOWN))) {
-			printk(KERN_DEBUG "%s: received irq with unknown events 0x%x. Please report\n",
-						dev->name, np->events);
-		}
 		if (unlikely(np->events & NVREG_IRQ_RECOVER_ERROR)) {
 			spin_lock(&np->lock);
 			/* disable interrupts on the nic */
@@ -3540,10 +3528,10 @@
 
 	for (i=0; ; i++) {
 		if (!(np->msi_flags & NV_MSI_X_ENABLED)) {
-			np->events = readl(base + NvRegIrqStatus) & NVREG_IRQSTAT_MASK;
+			np->events = readl(base + NvRegIrqStatus);
 			writel(NVREG_IRQSTAT_MASK, base + NvRegIrqStatus);
 		} else {
-			np->events = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQSTAT_MASK;
+			np->events = readl(base + NvRegMSIXIrqStatus);
 			writel(NVREG_IRQSTAT_MASK, base + NvRegMSIXIrqStatus);
 		}
 		dprintk(KERN_DEBUG "%s: irq: %08x\n", dev->name, np->events);
@@ -3591,14 +3579,6 @@
 			spin_unlock(&np->lock);
 			np->link_timeout = jiffies + LINK_TIMEOUT;
 		}
-		if (unlikely(np->events & (NVREG_IRQ_TX_ERR))) {
-			dprintk(KERN_DEBUG "%s: received irq with events 0x%x. Probably TX fail.\n",
-						dev->name, np->events);
-		}
-		if (unlikely(np->events & (NVREG_IRQ_UNKNOWN))) {
-			printk(KERN_DEBUG "%s: received irq with unknown events 0x%x. Please report\n",
-						dev->name, np->events);
-		}
 		if (unlikely(np->events & NVREG_IRQ_RECOVER_ERROR)) {
 			spin_lock(&np->lock);
 			/* disable interrupts on the nic */
@@ -3663,10 +3643,6 @@
 		nv_tx_done_optimized(dev, TX_WORK_PER_LOOP);
 		spin_unlock_irqrestore(&np->lock, flags);
 
-		if (unlikely(events & (NVREG_IRQ_TX_ERR))) {
-			dprintk(KERN_DEBUG "%s: received irq with events 0x%x. Probably TX fail.\n",
-						dev->name, events);
-		}
 		if (unlikely(i > max_interrupt_work)) {
 			spin_lock_irqsave(&np->lock, flags);
 			/* disable interrupts on the nic */
@@ -3825,10 +3801,6 @@
 			spin_unlock_irq(&np->lock);
 			break;
 		}
-		if (events & (NVREG_IRQ_UNKNOWN)) {
-			printk(KERN_DEBUG "%s: received irq with unknown events 0x%x. Please report\n",
-						dev->name, events);
-		}
 		if (unlikely(i > max_interrupt_work)) {
 			spin_lock_irqsave(&np->lock, flags);
 			/* disable interrupts on the nic */

--------------060800030201060600090106--
