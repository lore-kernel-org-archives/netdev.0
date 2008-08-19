From: Sebastian Siewior <bigeasy@linutronix.de>
Subject: [PATCH] net: don't grab a mutex within a timer context in gianfar
Date: Tue, 19 Aug 2008 21:12:45 +0200
Message-ID: <20080819191245.GA11595@www.tglx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.tglx.de ([62.245.132.106]:48641 "EHLO www.tglx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757617AbYHSTNX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Aug 2008 15:13:23 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I got the following backtrace while network was unavailble:

|NETDEV WATCHDOG: eth0: transmit timed out
|BUG: sleeping function called from invalid context at /home/bigeasy/git/linux-2.6-powerpc/kernel/mutex.c:87
|in_atomic():1, irqs_disabled():0
|Call Trace:
|[c0383d90] [c0006dd8] show_stack+0x48/0x184 (unreliable)
|[c0383db0] [c001e938] __might_sleep+0xe0/0xf4
|[c0383dc0] [c025a43c] mutex_lock+0x24/0x3c
|[c0383de0] [c019005c] phy_stop+0x20/0x70
|[c0383df0] [c018d4ec] stop_gfar+0x28/0xf4
|[c0383e10] [c018e8c4] gfar_timeout+0x30/0x60
|[c0383e20] [c01fe7c0] dev_watchdog+0xa8/0x144
|[c0383e30] [c002f93c] run_timer_softirq+0x148/0x1c8
|[c0383e60] [c002b084] __do_softirq+0x5c/0xc4
|[c0383e80] [c00046fc] do_softirq+0x3c/0x54
|[c0383e90] [c002ac60] irq_exit+0x3c/0x5c
|[c0383ea0] [c000b378] timer_interrupt+0xe0/0xf8
|[c0383ec0] [c000e5ac] ret_from_except+0x0/0x18
|[c0383f80] [c000804c] cpu_idle+0xcc/0xdc
|[c0383fa0] [c025c07c] etext+0x7c/0x90
|[c0383fc0] [c0338960] start_kernel+0x294/0x2a8
|[c0383ff0] [c00003dc] skpinv+0x304/0x340
|------------[ cut here ]------------

The phylock was once a spinlock but got changed into a mutex via
commit 35b5f6b1a aka [PHYLIB: Locking fixes for PHY I/O potentially sleeping]

Signed-off-by: Sebastian Siewior <bigeasy@linutronix.de>
---
Jeff, this is a rebased post of [1]. The initial patch was acked by Andy
Fleming. I just noticed that the initial does not apply due to David's
NAPI changes. The initial patch is still usefull for the stable tree since
the bug was introduced in the .25 merge window.

[1] http://patchwork.ozlabs.org/linuxppc/patch?id=19808

 drivers/net/gianfar.c |   22 ++++++++++++++++++----
 drivers/net/gianfar.h |    1 +
 2 files changed, 19 insertions(+), 4 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 999d691..4320a98 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -105,6 +105,7 @@ const char gfar_driver_version[] = "1.3";
 
 static int gfar_enet_open(struct net_device *dev);
 static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev);
+static void gfar_reset_task(struct work_struct *work);
 static void gfar_timeout(struct net_device *dev);
 static int gfar_close(struct net_device *dev);
 struct sk_buff *gfar_new_skb(struct net_device *dev);
@@ -209,6 +210,7 @@ static int gfar_probe(struct platform_device *pdev)
 	spin_lock_init(&priv->txlock);
 	spin_lock_init(&priv->rxlock);
 	spin_lock_init(&priv->bflock);
+	INIT_WORK(&priv->reset_task, gfar_reset_task);
 
 	platform_set_drvdata(pdev, dev);
 
@@ -1212,6 +1214,7 @@ static int gfar_close(struct net_device *dev)
 
 	napi_disable(&priv->napi);
 
+	cancel_work_sync(&priv->reset_task);
 	stop_gfar(dev);
 
 	/* Disconnect from the PHY */
@@ -1326,13 +1329,16 @@ static int gfar_change_mtu(struct net_device *dev, int new_mtu)
 	return 0;
 }
 
-/* gfar_timeout gets called when a packet has not been
+/* gfar_reset_task gets scheduled when a packet has not been
  * transmitted after a set amount of time.
  * For now, assume that clearing out all the structures, and
- * starting over will fix the problem. */
-static void gfar_timeout(struct net_device *dev)
+ * starting over will fix the problem.
+ */
+static void gfar_reset_task(struct work_struct *work)
 {
-	dev->stats.tx_errors++;
+	struct gfar_private *priv = container_of(work, struct gfar_private,
+			reset_task);
+	struct net_device *dev = priv->dev;
 
 	if (dev->flags & IFF_UP) {
 		stop_gfar(dev);
@@ -1342,6 +1348,14 @@ static void gfar_timeout(struct net_device *dev)
 	netif_tx_schedule_all(dev);
 }
 
+static void gfar_timeout(struct net_device *dev)
+{
+	struct gfar_private *priv = netdev_priv(dev);
+
+	dev->stats.tx_errors++;
+	schedule_work(&priv->reset_task);
+}
+
 /* Interrupt Handler for Transmit complete */
 static int gfar_clean_tx_ring(struct net_device *dev)
 {
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index d59df98..f46e9b6 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -756,6 +756,7 @@ struct gfar_private {
 
 	uint32_t msg_enable;
 
+	struct work_struct reset_task;
 	/* Network Statistics */
 	struct gfar_extra_stats extra_stats;
 };
-- 
1.5.5.2

