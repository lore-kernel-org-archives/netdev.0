From: Sebastian Siewior <netdev@ml.breakpoint.cc>
Subject: [PATCH / RFC] net: don't grab a mutex within a timer context in
	gianfar
Date: Wed, 23 Jul 2008 22:03:37 +0200
Message-ID: <20080723200337.GA5122@Chamillionaire.breakpoint.cc>
References: <20080718121008.GA28871@Chamillionaire.breakpoint.cc> <1216681028.7559.993.camel@localhost.localdomain> <20080722205911.GA29840@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Nate Case <ncase@xes-inc.com>, netdev@vger.kernel.org,
	Li Yang <leoli@freescale.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	Pantelis Antoniou <pantelis.antoniou@gmail.com>,
	Vitaly Bordug <vbordug@ru.mvista.com>, linuxppc-dev@ozlabs.org,
	Jeff Garzik <jgarzik@pobox.com>
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:53625 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753475AbYGWUDt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 16:03:49 -0400
Content-Disposition: inline
In-Reply-To: <20080722205911.GA29840@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Siewior <bigeasy@linutronix.de>

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
bug report @ http://marc.info/?l=linux-netdev&m=121638307116389&w=2
I moved it into a workqueue, this is what tg3 does.
I would convert the other three drivers unless $dude suggests a better
method or somebody else takes care....

 drivers/net/gianfar.c |   22 ++++++++++++++++++----
 drivers/net/gianfar.h |    2 ++
 2 files changed, 20 insertions(+), 4 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 25bdd08..caa6cbd 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -112,6 +112,7 @@ const char gfar_driver_version[] = "1.3";
 
 static int gfar_enet_open(struct net_device *dev);
 static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev);
+static void gfar_reset_task(struct work_struct *work);
 static void gfar_timeout(struct net_device *dev);
 static int gfar_close(struct net_device *dev);
 struct sk_buff *gfar_new_skb(struct net_device *dev);
@@ -216,6 +217,7 @@ static int gfar_probe(struct platform_device *pdev)
 
 	spin_lock_init(&priv->txlock);
 	spin_lock_init(&priv->rxlock);
+	INIT_WORK(&priv->reset_task, gfar_reset_task);
 
 	platform_set_drvdata(pdev, dev);
 
@@ -1132,6 +1134,7 @@ static int gfar_close(struct net_device *dev)
 	napi_disable(&priv->napi);
 #endif
 
+	cancel_work_sync(&priv->reset_task);
 	stop_gfar(dev);
 
 	/* Disconnect from the PHY */
@@ -1246,13 +1249,16 @@ static int gfar_change_mtu(struct net_device *dev, int new_mtu)
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
@@ -1262,6 +1268,14 @@ static void gfar_timeout(struct net_device *dev)
 	netif_schedule(dev);
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
index 27f37c8..d983a6a 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -759,6 +759,8 @@ struct gfar_private {
 
 	uint32_t msg_enable;
 
+	struct work_struct reset_task;
+
 	/* Network Statistics */
 	struct gfar_extra_stats extra_stats;
 };
-- 
1.5.5.2

