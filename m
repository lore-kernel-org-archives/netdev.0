From: akpm@osdl.org
Subject: [patch 7/7] netpoll: drivers must not enable IRQ unconditionally in their NAPI handler
Date: Tue, 19 Dec 2006 13:08:51 -0800
Message-ID: <200612192108.kBJL8pQo010507@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, romieu@fr.zoreil.com,
	aabdulla@nvidia.com, shemminger@osdl.org, zambrano@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:35435 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932973AbWLSVJ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Dec 2006 16:09:29 -0500
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Francois Romieu <romieu@fr.zoreil.com>

net/core/netpoll.c::netpoll_send_skb() calls the poll handler when it is
available.  As netconsole can be used from almost any context, IRQ must not
be enabled blindly in the NAPI handler of a driver which supports netpoll.

b57bd06655a028aba7b92e1c19c2093e7fcfb341 fixed the issue for the
8139too.c driver.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Stephen Hemminger <shemminger@osdl.org>
Cc: Ayaz Abdulla <aabdulla@nvidia.com>
Cc: Gary Zambrano <zambrano@broadcom.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/8139cp.c    |    6 ++++--
 drivers/net/b44.c       |    6 ++++--
 drivers/net/forcedeth.c |   11 +++++++----
 drivers/net/skge.c      |    5 +++--
 4 files changed, 18 insertions(+), 10 deletions(-)

diff -puN drivers/net/8139cp.c~netpoll-drivers-must-not-enable-irq-unconditionally-in-their-napi-handler drivers/net/8139cp.c
--- a/drivers/net/8139cp.c~netpoll-drivers-must-not-enable-irq-unconditionally-in-their-napi-handler
+++ a/drivers/net/8139cp.c
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
diff -puN drivers/net/b44.c~netpoll-drivers-must-not-enable-irq-unconditionally-in-their-napi-handler drivers/net/b44.c
--- a/drivers/net/b44.c~netpoll-drivers-must-not-enable-irq-unconditionally-in-their-napi-handler
+++ a/drivers/net/b44.c
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
 
diff -puN drivers/net/forcedeth.c~netpoll-drivers-must-not-enable-irq-unconditionally-in-their-napi-handler drivers/net/forcedeth.c
--- a/drivers/net/forcedeth.c~netpoll-drivers-must-not-enable-irq-unconditionally-in-their-napi-handler
+++ a/drivers/net/forcedeth.c
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
diff -puN drivers/net/skge.c~netpoll-drivers-must-not-enable-irq-unconditionally-in-their-napi-handler drivers/net/skge.c
--- a/drivers/net/skge.c~netpoll-drivers-must-not-enable-irq-unconditionally-in-their-napi-handler
+++ a/drivers/net/skge.c
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
_
