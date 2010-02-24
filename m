From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: [PATCH] tc35815: Fix double locking on NAPI
Date: Thu, 25 Feb 2010 01:00:34 +0900
Message-ID: <1267027234-7853-1-git-send-email-anemo@mba.ocn.ne.jp>
Cc: David Miller <davem@davemloft.net>,
	Ralf Roesch <ralf.roesch@rw-gmbh.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mv-drv-hcb003.ocn.ad.jp ([118.23.109.133]:34859 "EHLO
	mv-drv-hcb003.ocn.ad.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756886Ab0BXQAk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2010 11:00:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Isolate spinlock for tx and rx to resolve double-locking.

This is potential bug while this controller does not exist on any
SMP platforms, but lockdep or rt-preempt reveals this bug.

Reported-by: Ralf Roesch <ralf.roesch@rw-gmbh.de>
Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
---
 drivers/net/tc35815.c |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index d71c197..2fa364d 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -402,6 +402,7 @@ struct tc35815_local {
 	 * by this lock as well.
 	 */
 	spinlock_t lock;
+	spinlock_t rx_lock;
 
 	struct mii_bus *mii_bus;
 	struct phy_device *phy_dev;
@@ -835,6 +836,7 @@ static int __devinit tc35815_init_one(struct pci_dev *pdev,
 
 	INIT_WORK(&lp->restart_work, tc35815_restart_work);
 	spin_lock_init(&lp->lock);
+	spin_lock_init(&lp->rx_lock);
 	lp->pci_dev = pdev;
 	lp->chiptype = ent->driver_data;
 
@@ -1186,6 +1188,7 @@ static void tc35815_restart(struct net_device *dev)
 			printk(KERN_ERR "%s: BMCR reset failed.\n", dev->name);
 	}
 
+	spin_lock_bh(&lp->rx_lock);
 	spin_lock_irq(&lp->lock);
 	tc35815_chip_reset(dev);
 	tc35815_clear_queues(dev);
@@ -1193,6 +1196,7 @@ static void tc35815_restart(struct net_device *dev)
 	/* Reconfigure CAM again since tc35815_chip_init() initialize it. */
 	tc35815_set_multicast_list(dev);
 	spin_unlock_irq(&lp->lock);
+	spin_unlock_bh(&lp->rx_lock);
 
 	netif_wake_queue(dev);
 }
@@ -1211,11 +1215,14 @@ static void tc35815_schedule_restart(struct net_device *dev)
 	struct tc35815_local *lp = netdev_priv(dev);
 	struct tc35815_regs __iomem *tr =
 		(struct tc35815_regs __iomem *)dev->base_addr;
+	unsigned long flags;
 
 	/* disable interrupts */
+	spin_lock_irqsave(&lp->lock, flags);
 	tc_writel(0, &tr->Int_En);
 	tc_writel(tc_readl(&tr->DMA_Ctl) | DMA_IntMask, &tr->DMA_Ctl);
 	schedule_work(&lp->restart_work);
+	spin_unlock_irqrestore(&lp->lock, flags);
 }
 
 static void tc35815_tx_timeout(struct net_device *dev)
@@ -1436,7 +1443,9 @@ static int tc35815_do_interrupt(struct net_device *dev, u32 status, int limit)
 	if (status & Int_IntMacTx) {
 		/* Transmit complete. */
 		lp->lstats.tx_ints++;
+		spin_lock_irq(&lp->lock);
 		tc35815_txdone(dev);
+		spin_unlock_irq(&lp->lock);
 		if (ret < 0)
 			ret = 0;
 	}
@@ -1649,7 +1658,7 @@ static int tc35815_poll(struct napi_struct *napi, int budget)
 	int received = 0, handled;
 	u32 status;
 
-	spin_lock(&lp->lock);
+	spin_lock(&lp->rx_lock);
 	status = tc_readl(&tr->Int_Src);
 	do {
 		/* BLEx, FDAEx will be cleared later */
@@ -1667,7 +1676,7 @@ static int tc35815_poll(struct napi_struct *napi, int budget)
 		}
 		status = tc_readl(&tr->Int_Src);
 	} while (status);
-	spin_unlock(&lp->lock);
+	spin_unlock(&lp->rx_lock);
 
 	if (received < budget) {
 		napi_complete(napi);
-- 
1.5.6.5

