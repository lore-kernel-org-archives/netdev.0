From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH 1/3] korina: fix deadlock on RX FIFO overrun
Date: Sun, 30 May 2010 01:23:34 +0200
Message-ID: <20100529232343.ABC1D4CD45@orbit.nwl.cc>
Cc: Florian Fainelli <florian@openwrt.org>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([91.121.169.95]:42759 "EHLO orbit.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754381Ab0E2XXr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 May 2010 19:23:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By calling korina_restart(), the IRQ handler tries to disable the
interrupt it's currently serving. This leads to a deadlock since
disable_irq() waits for any running IRQ handlers to finish before
returning. This patch addresses the issue by turning korina_restart()
into a workqueue task, which is then scheduled when needed.

Reproducing the deadlock is easily done using e.g. GNU netcat to send
large amounts of UDP data to the host running this driver.

Note that the same problem (and fix) applies to TX FIFO underruns, but
apparently these are less easy to trigger.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 drivers/net/korina.c |   27 +++++++++++++--------------
 1 files changed, 13 insertions(+), 14 deletions(-)

diff --git a/drivers/net/korina.c b/drivers/net/korina.c
index 26bf1b7..13533f9 100644
--- a/drivers/net/korina.c
+++ b/drivers/net/korina.c
@@ -135,6 +135,7 @@ struct korina_private {
 	struct napi_struct napi;
 	struct timer_list media_check_timer;
 	struct mii_if_info mii_if;
+	struct work_struct restart_task;
 	struct net_device *dev;
 	int phy_addr;
 };
@@ -890,12 +891,12 @@ static int korina_init(struct net_device *dev)
 
 /*
  * Restart the RC32434 ethernet controller.
- * FIXME: check the return status where we call it
  */
-static int korina_restart(struct net_device *dev)
+static void korina_restart_task(struct work_struct *work)
 {
-	struct korina_private *lp = netdev_priv(dev);
-	int ret;
+	struct korina_private *lp = container_of(work,
+			struct korina_private, restart_task);
+	struct net_device *dev = lp->dev;
 
 	/*
 	 * Disable interrupts
@@ -916,10 +917,9 @@ static int korina_restart(struct net_device *dev)
 
 	napi_disable(&lp->napi);
 
-	ret = korina_init(dev);
-	if (ret < 0) {
+	if (korina_init(dev) < 0) {
 		printk(KERN_ERR "%s: cannot restart device\n", dev->name);
-		return ret;
+		return;
 	}
 	korina_multicast_list(dev);
 
@@ -927,8 +927,6 @@ static int korina_restart(struct net_device *dev)
 	enable_irq(lp->ovr_irq);
 	enable_irq(lp->tx_irq);
 	enable_irq(lp->rx_irq);
-
-	return ret;
 }
 
 static void korina_clear_and_restart(struct net_device *dev, u32 value)
@@ -937,7 +935,7 @@ static void korina_clear_and_restart(struct net_device *dev, u32 value)
 
 	netif_stop_queue(dev);
 	writel(value, &lp->eth_regs->ethintfc);
-	korina_restart(dev);
+	schedule_work(&lp->restart_task);
 }
 
 /* Ethernet Tx Underflow interrupt */
@@ -962,11 +960,8 @@ static irqreturn_t korina_und_interrupt(int irq, void *dev_id)
 static void korina_tx_timeout(struct net_device *dev)
 {
 	struct korina_private *lp = netdev_priv(dev);
-	unsigned long flags;
 
-	spin_lock_irqsave(&lp->lock, flags);
-	korina_restart(dev);
-	spin_unlock_irqrestore(&lp->lock, flags);
+	schedule_work(&lp->restart_task);
 }
 
 /* Ethernet Rx Overflow interrupt */
@@ -1086,6 +1081,8 @@ static int korina_close(struct net_device *dev)
 
 	napi_disable(&lp->napi);
 
+	cancel_work_sync(&lp->restart_task);
+
 	free_irq(lp->rx_irq, dev);
 	free_irq(lp->tx_irq, dev);
 	free_irq(lp->ovr_irq, dev);
@@ -1198,6 +1195,8 @@ static int korina_probe(struct platform_device *pdev)
 	}
 	setup_timer(&lp->media_check_timer, korina_poll_media, (unsigned long) dev);
 
+	INIT_WORK(&lp->restart_task, korina_restart_task);
+
 	printk(KERN_INFO "%s: " DRV_NAME "-" DRV_VERSION " " DRV_RELDATE "\n",
 			dev->name);
 out:
-- 
1.6.4.4

