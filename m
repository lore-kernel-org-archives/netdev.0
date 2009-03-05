From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 10/13] forcedeth: add interrupt moderation logic
Date: Thu, 05 Mar 2009 13:02:26 -0500
Message-ID: <49B013B2.6050802@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080102030104020803060209"
To: Manfred Spraul <manfred@colorfullife.com>,
	Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>,
	"David S. Miller" <davem@davemloft.net>,
	nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate03.nvidia.com ([216.228.112.145]:8475 "EHLO
	hqemgate03.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755680AbZCEVBb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2009 16:01:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080102030104020803060209
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch adds the logic to moderate the interrupts by changing the 
mode between throughput and poll. If there has been a large amount of 
time without any burst of network load, the code will transition to pure 
throughput mode (where each tx/rx/other will cause an interrupt). If 
bursts of network load occurs, it will transition to poll based mode to 
help reduce cpu utilization (it will not interrupt on each packet) while 
maintaining the optimum network bandwidth utilization.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>


--------------080102030104020803060209
Content-Type: text/plain;
 name="patch-forcedeth-dynamic-3"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-dynamic-3"

--- old/drivers/net/forcedeth.c	2009-03-05 10:46:25.000000000 -0800
+++ new/drivers/net/forcedeth.c	2009-03-05 10:46:35.000000000 -0800
@@ -593,6 +593,9 @@
 
 #define NV_TX_LIMIT_COUNT     16
 
+#define NV_DYNAMIC_THRESHOLD        4
+#define NV_DYNAMIC_MAX_QUIET_COUNT  2048
+
 /* statistics */
 struct nv_ethtool_str {
 	char name[ETH_GSTRING_LEN];
@@ -750,6 +753,7 @@
 	u16 gigabit;
 	int intr_test;
 	int recover_error;
+	int quiet_count;
 
 	/* General data: RO fields */
 	dma_addr_t ring_addr;
@@ -832,7 +836,7 @@
  * Maximum number of loops until we assume that a bit in the irq mask
  * is stuck. Overridable with module param.
  */
-static int max_interrupt_work = 15;
+static int max_interrupt_work = 4;
 
 /*
  * Optimization can be either throuput mode or cpu mode
@@ -3418,11 +3422,43 @@
 	}
 }
 
+static inline int nv_change_interrupt_mode(struct net_device *dev, int total_work)
+{
+	struct fe_priv *np = netdev_priv(dev);
+
+	if (optimization_mode == NV_OPTIMIZATION_MODE_DYNAMIC) {
+		if (total_work > NV_DYNAMIC_THRESHOLD) {
+			/* transition to poll based interrupts */
+			np->quiet_count = 0;
+			if (np->irqmask != NVREG_IRQMASK_CPU) {
+				np->irqmask = NVREG_IRQMASK_CPU;
+				return 1;
+			}
+		} else {
+			if (np->quiet_count < NV_DYNAMIC_MAX_QUIET_COUNT) {
+				np->quiet_count++;
+			} else {
+				/* reached a period of low activity, switch
+				   to per tx/rx packet interrupts */
+				if (np->irqmask != NVREG_IRQMASK_THROUGHPUT) {
+					np->irqmask = NVREG_IRQMASK_THROUGHPUT;
+					return 1;
+				}
+			}
+		}
+	}
+	return 0;
+}
+
 static irqreturn_t nv_nic_irq(int foo, void *data)
 {
 	struct net_device *dev = (struct net_device *) data;
 	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
+#ifndef CONFIG_FORCEDETH_NAPI
+	int total_work = 0;
+	int loop_count = 0;
+#endif
 
 	dprintk(KERN_DEBUG "%s: nv_nic_irq\n", dev->name);
 
@@ -3449,19 +3485,35 @@
 
 	spin_unlock(&np->lock);
 
-	return IRQ_HANDLED;
 #else
-	spin_lock(&np->lock);
-	nv_tx_done(dev, np->tx_ring_size);
-	spin_unlock(&np->lock);
-
-	if (nv_rx_process(dev, RX_WORK_PER_LOOP)) {
-		if (unlikely(nv_alloc_rx(dev))) {
-			spin_lock(&np->lock);
-			if (!np->in_shutdown)
-				mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
-			spin_unlock(&np->lock);
+	do
+	{
+		int work = 0;
+		if ((work = nv_rx_process(dev, RX_WORK_PER_LOOP))) {
+			if (unlikely(nv_alloc_rx(dev))) {
+				spin_lock(&np->lock);
+				if (!np->in_shutdown)
+					mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
+				spin_unlock(&np->lock);
+			}
 		}
+
+		spin_lock(&np->lock);
+		work += nv_tx_done(dev, TX_WORK_PER_LOOP);
+		spin_unlock(&np->lock);
+
+		if (!work)
+			break;
+
+		total_work += work;
+
+		loop_count++;
+	}
+	while (loop_count < max_interrupt_work);
+
+	if (nv_change_interrupt_mode(dev, total_work)) {
+		/* setup new irq mask */
+		writel(np->irqmask, base + NvRegIrqMask);
 	}
 
 	if (unlikely(np->events & NVREG_IRQ_LINK)) {
@@ -3507,6 +3559,10 @@
 	struct net_device *dev = (struct net_device *) data;
 	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
+#ifndef CONFIG_FORCEDETH_NAPI
+	int total_work = 0;
+	int loop_count = 0;
+#endif
 
 	dprintk(KERN_DEBUG "%s: nv_nic_irq_optimized\n", dev->name);
 
@@ -3533,19 +3589,35 @@
 
 	spin_unlock(&np->lock);
 
-	return IRQ_HANDLED;
 #else
-	spin_lock(&np->lock);
-	nv_tx_done_optimized(dev, TX_WORK_PER_LOOP);
-	spin_unlock(&np->lock);
-
-	if (nv_rx_process_optimized(dev, RX_WORK_PER_LOOP)) {
-		if (unlikely(nv_alloc_rx_optimized(dev))) {
-			spin_lock(&np->lock);
-			if (!np->in_shutdown)
-				mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
-			spin_unlock(&np->lock);
+	do
+	{
+		int work = 0;
+		if ((work = nv_rx_process_optimized(dev, RX_WORK_PER_LOOP))) {
+			if (unlikely(nv_alloc_rx_optimized(dev))) {
+				spin_lock(&np->lock);
+				if (!np->in_shutdown)
+					mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
+				spin_unlock(&np->lock);
+			}
 		}
+
+		spin_lock(&np->lock);
+		work += nv_tx_done_optimized(dev, TX_WORK_PER_LOOP);
+		spin_unlock(&np->lock);
+
+		if (!work)
+			break;
+
+		total_work += work;
+
+		loop_count++;
+	}
+	while (loop_count < max_interrupt_work);
+
+	if (nv_change_interrupt_mode(dev, total_work)) {
+		/* setup new irq mask */
+		writel(np->irqmask, base + NvRegIrqMask);
 	}
 
 	if (unlikely(np->events & NVREG_IRQ_LINK)) {
@@ -3632,21 +3704,22 @@
 	struct net_device *dev = np->dev;
 	u8 __iomem *base = get_hwbase(dev);
 	unsigned long flags;
-	int pkts, retcode;
+	int retcode;
+	int tx_work, rx_work;
 
 	if (!nv_optimized(np)) {
 		spin_lock_irqsave(&np->lock, flags);
-		nv_tx_done(dev, np->tx_ring_size);
+		tx_work = nv_tx_done(dev, np->tx_ring_size);
 		spin_unlock_irqrestore(&np->lock, flags);
 
-		pkts = nv_rx_process(dev, budget);
+		rx_work = nv_rx_process(dev, budget);
 		retcode = nv_alloc_rx(dev);
 	} else {
 		spin_lock_irqsave(&np->lock, flags);
-		nv_tx_done_optimized(dev, np->tx_ring_size);
+		tx_work = nv_tx_done_optimized(dev, np->tx_ring_size);
 		spin_unlock_irqrestore(&np->lock, flags);
 
-		pkts = nv_rx_process_optimized(dev, budget);
+		rx_work = nv_rx_process_optimized(dev, budget);
 		retcode = nv_alloc_rx_optimized(dev);
 	}
 
@@ -3657,6 +3730,8 @@
 		spin_unlock_irqrestore(&np->lock, flags);
 	}
 
+	nv_change_interrupt_mode(dev, tx_work + rx_work);
+
 	if (unlikely(np->events & NVREG_IRQ_LINK)) {
 		spin_lock_irqsave(&np->lock, flags);
 		nv_link_irq(dev);
@@ -3677,10 +3752,10 @@
 		}
 		spin_unlock_irqrestore(&np->lock, flags);
 		__napi_complete(napi);
-		return pkts;
+		return rx_work;
 	}
 
-	if (pkts < budget) {
+	if (rx_work < budget) {
 		/* re-enable interrupts
 		   (msix not enabled in napi) */
 		spin_lock_irqsave(&np->lock, flags);
@@ -3691,7 +3766,7 @@
 
 		spin_unlock_irqrestore(&np->lock, flags);
 	}
-	return pkts;
+	return rx_work;
 }
 #endif
 

--------------080102030104020803060209--
