From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] netpoll: drivers must not enable IRQ unconditionally in their NAPI handler
Date: Sun, 17 Dec 2006 23:03:15 +0100
Message-ID: <20061217220315.GA26485@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, akpm@osdl.org,
	Ayaz Abdulla <aabdulla@nvidia.com>,
	Gary Zambrano <zambrano@broadcom.com>,
	Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:43011 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753081AbWLQWGg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Dec 2006 17:06:36 -0500
To: jeff@garzik.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

net/core/netpoll.c::netpoll_send_skb() calls the poll handler when
it is available. As netconsole can be used from almost any context,
IRQ must not be enabled blindly in the NAPI handler of a driver which
supports netpoll.

b57bd06655a028aba7b92e1c19c2093e7fcfb341 fixed the issue for the
8139too.c driver.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/8139cp.c    |    6 ++++--
 drivers/net/b44.c       |    6 ++++--
 drivers/net/forcedeth.c |   11 +++++++----
 drivers/net/skge.c      |    5 +++--
 4 files changed, 18 insertions(+), 10 deletions(-)

diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index 458dd9f..e2cb19b 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -617,13 +617,15 @@ rx_next:
 	 * this round of polling
 	 */
 	if (rx_work) {
+		unsigned long flags;
+
 		if (cpr16(IntrStatus) & cp_rx_intr_mask)
 			goto rx_status_loop;
 
-		local_irq_disable();
+		local_irq_save(flags);
 		cpw16_f(IntrMask, cp_intr_mask);
 		__netif_rx_complete(dev);
-		local_irq_enable();
+		local_irq_restore(flags);
 
 		return 0;	/* done */
 	}
diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 474a4e3..5eb2ec6 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -879,12 +879,14 @@ static int b44_poll(struct net_device *n
 	}
 
 	if (bp->istat & ISTAT_ERRORS) {
-		spin_lock_irq(&bp->lock);
+		unsigned long flags;
+
+		spin_lock_irqsave(&bp->lock, flags);
 		b44_halt(bp);
 		b44_init_rings(bp);
 		b44_init_hw(bp, 1);
 		netif_wake_queue(bp->dev);
-		spin_unlock_irq(&bp->lock);
+		spin_unlock_irqrestore(&bp->lock, flags);
 		done = 1;
 	}
 
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 439f413..820f8c7 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -2576,14 +2576,15 @@ static int nv_napi_poll(struct net_devic
 	int pkts, limit = min(*budget, dev->quota);
 	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
+	unsigned long flags;
 
 	pkts = nv_rx_process(dev, limit);
 
 	if (nv_alloc_rx(dev)) {
-		spin_lock_irq(&np->lock);
+		spin_lock_irqsave(&np->lock, flags);
 		if (!np->in_shutdown)
 			mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
-		spin_unlock_irq(&np->lock);
+		spin_unlock_irqrestore(&np->lock, flags);
 	}
 
 	if (pkts < limit) {
@@ -2591,13 +2592,15 @@ static int nv_napi_poll(struct net_devic
 		netif_rx_complete(dev);
 
 		/* re-enable receive interrupts */
-		spin_lock_irq(&np->lock);
+		spin_lock_irqsave(&np->lock, flags);
+
 		np->irqmask |= NVREG_IRQ_RX_ALL;
 		if (np->msi_flags & NV_MSI_X_ENABLED)
 			writel(NVREG_IRQ_RX_ALL, base + NvRegIrqMask);
 		else
 			writel(np->irqmask, base + NvRegIrqMask);
-		spin_unlock_irq(&np->lock);
+
+		spin_unlock_irqrestore(&np->lock, flags);
 		return 0;
 	} else {
 		/* used up our quantum, so reschedule */
diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index 8a39376..deedfd5 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -2920,6 +2920,7 @@ static int skge_poll(struct net_device *
 	struct skge_hw *hw = skge->hw;
 	struct skge_ring *ring = &skge->rx_ring;
 	struct skge_element *e;
+	unsigned long flags;
 	int to_do = min(dev->quota, *budget);
 	int work_done = 0;
 
@@ -2957,12 +2958,12 @@ static int skge_poll(struct net_device *
 	if (work_done >=  to_do)
 		return 1; /* not done */
 
-	spin_lock_irq(&hw->hw_lock);
+	spin_lock_irqsave(&hw->hw_lock, flags);
 	__netif_rx_complete(dev);
 	hw->intr_mask |= irqmask[skge->port];
   	skge_write32(hw, B0_IMSK, hw->intr_mask);
 	skge_read32(hw, B0_IMSK);
-	spin_unlock_irq(&hw->hw_lock);
+	spin_unlock_irqrestore(&hw->hw_lock, flags);
 
 	return 0;
 }
-- 
1.4.4.1

