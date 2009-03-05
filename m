From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 4/13] forcedeth: save irq events for napi processing
Date: Thu, 05 Mar 2009 13:02:03 -0500
Message-ID: <49B0139B.5050405@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020503020803000004080101"
To: Manfred Spraul <manfred@colorfullife.com>,
	Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>,
	"David S. Miller" <davem@davemloft.net>,
	nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate03.nvidia.com ([216.228.112.145]:8446 "EHLO
	hqemgate03.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755520AbZCEVBU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2009 16:01:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020503020803000004080101
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch will save the irq events in the driver's context so that the 
napi routine knows which interrupts have occurred. Subsequent changes 
will be moving all interrupt processing into the napi poll routine.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>


--------------020503020803000004080101
Content-Type: text/plain;
 name="patch-forcedeth-napi-events"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-napi-events"

--- old/drivers/net/forcedeth.c	2009-03-05 10:39:55.000000000 -0800
+++ new/drivers/net/forcedeth.c	2009-03-05 10:40:17.000000000 -0800
@@ -759,6 +759,7 @@
 	dma_addr_t ring_addr;
 	struct pci_dev *pci_dev;
 	u32 orig_mac[2];
+	u32 events;
 	u32 irqmask;
 	u32 desc_ver;
 	u32 txrxctl_bits;
@@ -3417,21 +3418,20 @@
 	struct net_device *dev = (struct net_device *) data;
 	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
-	u32 events;
 	int i;
 
 	dprintk(KERN_DEBUG "%s: nv_nic_irq\n", dev->name);
 
 	for (i=0; ; i++) {
 		if (!(np->msi_flags & NV_MSI_X_ENABLED)) {
-			events = readl(base + NvRegIrqStatus) & NVREG_IRQSTAT_MASK;
+			np->events = readl(base + NvRegIrqStatus) & NVREG_IRQSTAT_MASK;
 			writel(NVREG_IRQSTAT_MASK, base + NvRegIrqStatus);
 		} else {
-			events = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQSTAT_MASK;
+			np->events = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQSTAT_MASK;
 			writel(NVREG_IRQSTAT_MASK, base + NvRegMSIXIrqStatus);
 		}
-		dprintk(KERN_DEBUG "%s: irq: %08x\n", dev->name, events);
-		if (!(events & np->irqmask))
+		dprintk(KERN_DEBUG "%s: irq: %08x\n", dev->name, np->events);
+		if (!(np->events & np->irqmask))
 			break;
 
 		nv_msi_workaround(np);
@@ -3441,7 +3441,7 @@
 		spin_unlock(&np->lock);
 
 #ifdef CONFIG_FORCEDETH_NAPI
-		if (events & NVREG_IRQ_RX_ALL) {
+		if (np->events & NVREG_IRQ_RX_ALL) {
 			spin_lock(&np->lock);
 			napi_schedule(&np->napi);
 
@@ -3464,7 +3464,7 @@
 			}
 		}
 #endif
-		if (unlikely(events & NVREG_IRQ_LINK)) {
+		if (unlikely(np->events & NVREG_IRQ_LINK)) {
 			spin_lock(&np->lock);
 			nv_link_irq(dev);
 			spin_unlock(&np->lock);
@@ -3475,15 +3475,15 @@
 			spin_unlock(&np->lock);
 			np->link_timeout = jiffies + LINK_TIMEOUT;
 		}
-		if (unlikely(events & (NVREG_IRQ_TX_ERR))) {
+		if (unlikely(np->events & (NVREG_IRQ_TX_ERR))) {
 			dprintk(KERN_DEBUG "%s: received irq with events 0x%x. Probably TX fail.\n",
-						dev->name, events);
+						dev->name, np->events);
 		}
-		if (unlikely(events & (NVREG_IRQ_UNKNOWN))) {
+		if (unlikely(np->events & (NVREG_IRQ_UNKNOWN))) {
 			printk(KERN_DEBUG "%s: received irq with unknown events 0x%x. Please report\n",
-						dev->name, events);
+						dev->name, np->events);
 		}
-		if (unlikely(events & NVREG_IRQ_RECOVER_ERROR)) {
+		if (unlikely(np->events & NVREG_IRQ_RECOVER_ERROR)) {
 			spin_lock(&np->lock);
 			/* disable interrupts on the nic */
 			if (!(np->msi_flags & NV_MSI_X_ENABLED))
@@ -3534,21 +3534,20 @@
 	struct net_device *dev = (struct net_device *) data;
 	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
-	u32 events;
 	int i;
 
 	dprintk(KERN_DEBUG "%s: nv_nic_irq_optimized\n", dev->name);
 
 	for (i=0; ; i++) {
 		if (!(np->msi_flags & NV_MSI_X_ENABLED)) {
-			events = readl(base + NvRegIrqStatus) & NVREG_IRQSTAT_MASK;
+			np->events = readl(base + NvRegIrqStatus) & NVREG_IRQSTAT_MASK;
 			writel(NVREG_IRQSTAT_MASK, base + NvRegIrqStatus);
 		} else {
-			events = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQSTAT_MASK;
+			np->events = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQSTAT_MASK;
 			writel(NVREG_IRQSTAT_MASK, base + NvRegMSIXIrqStatus);
 		}
-		dprintk(KERN_DEBUG "%s: irq: %08x\n", dev->name, events);
-		if (!(events & np->irqmask))
+		dprintk(KERN_DEBUG "%s: irq: %08x\n", dev->name, np->events);
+		if (!(np->events & np->irqmask))
 			break;
 
 		nv_msi_workaround(np);
@@ -3558,7 +3557,7 @@
 		spin_unlock(&np->lock);
 
 #ifdef CONFIG_FORCEDETH_NAPI
-		if (events & NVREG_IRQ_RX_ALL) {
+		if (np->events & NVREG_IRQ_RX_ALL) {
 			spin_lock(&np->lock);
 			napi_schedule(&np->napi);
 
@@ -3581,7 +3580,7 @@
 			}
 		}
 #endif
-		if (unlikely(events & NVREG_IRQ_LINK)) {
+		if (unlikely(np->events & NVREG_IRQ_LINK)) {
 			spin_lock(&np->lock);
 			nv_link_irq(dev);
 			spin_unlock(&np->lock);
@@ -3592,15 +3591,15 @@
 			spin_unlock(&np->lock);
 			np->link_timeout = jiffies + LINK_TIMEOUT;
 		}
-		if (unlikely(events & (NVREG_IRQ_TX_ERR))) {
+		if (unlikely(np->events & (NVREG_IRQ_TX_ERR))) {
 			dprintk(KERN_DEBUG "%s: received irq with events 0x%x. Probably TX fail.\n",
-						dev->name, events);
+						dev->name, np->events);
 		}
-		if (unlikely(events & (NVREG_IRQ_UNKNOWN))) {
+		if (unlikely(np->events & (NVREG_IRQ_UNKNOWN))) {
 			printk(KERN_DEBUG "%s: received irq with unknown events 0x%x. Please report\n",
-						dev->name, events);
+						dev->name, np->events);
 		}
-		if (unlikely(events & NVREG_IRQ_RECOVER_ERROR)) {
+		if (unlikely(np->events & NVREG_IRQ_RECOVER_ERROR)) {
 			spin_lock(&np->lock);
 			/* disable interrupts on the nic */
 			if (!(np->msi_flags & NV_MSI_X_ENABLED))

--------------020503020803000004080101--
