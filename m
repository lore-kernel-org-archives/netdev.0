From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.25rc7 lockdep trace
Date: Thu, 12 Jun 2008 00:01:53 -0700 (PDT)
Message-ID: <20080612.000153.30878828.davem@davemloft.net>
References: <20080610.224023.116817726.davem@davemloft.net>
	<20080612061334.GA4005@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, davej@codemonkey.org.uk,
	netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60554
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752919AbYFLHBx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2008 03:01:53 -0400
In-Reply-To: <20080612061334.GA4005@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Thu, 12 Jun 2008 06:13:34 +0000

> It seems after this change bp->in_reset_task could be removed totally
> from the code.
 ...
> ... likewise lp->work_pending,
 ...
> ... likewise lp->work_pending.
 ...
> local->info_queue probably needs some #ifndef like in hostap_info_init()
> or could be skipped here at all (waiting for remove).

Thanks for the feedback, here's a new patch with your
suggestions added.

net: Eliminate flush_scheduled_work() calls while RTNL is held.

If the RTNL is held when we invoke flush_scheduled_work() we could
deadlock.  One such case is linkwatch, it is a workqueue which tries
to grab the RTNL semaphore.

The most common case are net driver ->stop() methods.  The
simplest conversion is to instead use cancel_{delayed_}work_sync()
explicitly on the various workqueues the driver uses.

This is an OK transformation because these workqueues are doing things
like resetting the chip, restarting link negotiation, and so forth.
And if we're bringing down the device, we're about to turn the chip
off and reset it anways.  So if we cancel a pending work event, that's
fine here.

Some drivers were working around this deadlock by using a msleep()
polling loop of some sort, and those cases are converted to instead
use cancel_{delayed_}work_sync() as well.

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 4b46e68..367b6d4 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -5724,14 +5724,12 @@ bnx2_reset_task(struct work_struct *work)
 	if (!netif_running(bp->dev))
 		return;
 
-	bp->in_reset_task = 1;
 	bnx2_netif_stop(bp);
 
 	bnx2_init_nic(bp);
 
 	atomic_set(&bp->intr_sem, 1);
 	bnx2_netif_start(bp);
-	bp->in_reset_task = 0;
 }
 
 static void
@@ -5907,12 +5905,7 @@ bnx2_close(struct net_device *dev)
 	struct bnx2 *bp = netdev_priv(dev);
 	u32 reset_code;
 
-	/* Calling flush_scheduled_work() may deadlock because
-	 * linkwatch_event() may be on the workqueue and it will try to get
-	 * the rtnl_lock which we are holding.
-	 */
-	while (bp->in_reset_task)
-		msleep(1);
+	cancel_work_sync(&bp->reset_task);
 
 	bnx2_disable_int_sync(bp);
 	bnx2_napi_disable(bp);
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 1eaf5bb..2377cc1 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6656,7 +6656,6 @@ struct bnx2 {
 	int			current_interval;
 	struct			timer_list timer;
 	struct work_struct	reset_task;
-	int			in_reset_task;
 
 	/* Used to synchronize phy accesses. */
 	spinlock_t		phy_lock;
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index faae01d..075fd54 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -2605,7 +2605,8 @@ static int ehea_stop(struct net_device *dev)
 	if (netif_msg_ifdown(port))
 		ehea_info("disabling port %s", dev->name);
 
-	flush_scheduled_work();
+	cancel_work_sync(&port->reset_task);
+
 	mutex_lock(&port->port_lock);
 	netif_stop_queue(dev);
 	port_napi_disable(port);
diff --git a/drivers/net/hamradio/baycom_epp.c b/drivers/net/hamradio/baycom_epp.c
index dde9c7e..00bc7fb 100644
--- a/drivers/net/hamradio/baycom_epp.c
+++ b/drivers/net/hamradio/baycom_epp.c
@@ -959,7 +959,7 @@ static int epp_close(struct net_device *dev)
 	unsigned char tmp[1];
 
 	bc->work_running = 0;
-	flush_scheduled_work();
+	cancel_delayed_work_sync(&bc->run_work);
 	bc->stat = EPP_DCDBIT;
 	tmp[0] = 0;
 	pp->ops->epp_write_addr(pp, tmp, 1, 0);
diff --git a/drivers/net/smc911x.c b/drivers/net/smc911x.c
index 4e28002..e2ee91a 100644
--- a/drivers/net/smc911x.c
+++ b/drivers/net/smc911x.c
@@ -136,7 +136,6 @@ struct smc911x_local {
 
 	/* work queue */
 	struct work_struct phy_configure;
-	int work_pending;
 
 	int tx_throttle;
 	spinlock_t lock;
@@ -960,11 +959,11 @@ static void smc911x_phy_configure(struct work_struct *work)
 	 * We should not be called if phy_type is zero.
 	 */
 	if (lp->phy_type == 0)
-		 goto smc911x_phy_configure_exit_nolock;
+		return;
 
 	if (smc911x_phy_reset(dev, phyaddr)) {
 		printk("%s: PHY reset timed out\n", dev->name);
-		goto smc911x_phy_configure_exit_nolock;
+		return;
 	}
 	spin_lock_irqsave(&lp->lock, flags);
 
@@ -1033,8 +1032,6 @@ static void smc911x_phy_configure(struct work_struct *work)
 
 smc911x_phy_configure_exit:
 	spin_unlock_irqrestore(&lp->lock, flags);
-smc911x_phy_configure_exit_nolock:
-	lp->work_pending = 0;
 }
 
 /*
@@ -1356,11 +1353,8 @@ static void smc911x_timeout(struct net_device *dev)
 	 * smc911x_phy_configure() calls msleep() which calls schedule_timeout()
 	 * which calls schedule().	 Hence we use a work queue.
 	 */
-	if (lp->phy_type != 0) {
-		if (schedule_work(&lp->phy_configure)) {
-			lp->work_pending = 1;
-		}
-	}
+	if (lp->phy_type != 0)
+		schedule_work(&lp->phy_configure);
 
 	/* We can accept TX packets again */
 	dev->trans_start = jiffies;
@@ -1531,16 +1525,8 @@ static int smc911x_close(struct net_device *dev)
 	if (lp->phy_type != 0) {
 		/* We need to ensure that no calls to
 		 * smc911x_phy_configure are pending.
-
-		 * flush_scheduled_work() cannot be called because we
-		 * are running with the netlink semaphore held (from
-		 * devinet_ioctl()) and the pending work queue
-		 * contains linkwatch_event() (scheduled by
-		 * netif_carrier_off() above). linkwatch_event() also
-		 * wants the netlink semaphore.
 		 */
-		while (lp->work_pending)
-			schedule();
+		cancel_work_sync(&lp->phy_configure);
 		smc911x_phy_powerdown(dev, lp->mii.phy_id);
 	}
 
diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
index a188e33..f2051b2 100644
--- a/drivers/net/smc91x.c
+++ b/drivers/net/smc91x.c
@@ -1016,15 +1016,8 @@ static void smc_phy_powerdown(struct net_device *dev)
 
 	/* We need to ensure that no calls to smc_phy_configure are
 	   pending.
-
-	   flush_scheduled_work() cannot be called because we are
-	   running with the netlink semaphore held (from
-	   devinet_ioctl()) and the pending work queue contains
-	   linkwatch_event() (scheduled by netif_carrier_off()
-	   above). linkwatch_event() also wants the netlink semaphore.
 	*/
-	while(lp->work_pending)
-		yield();
+	cancel_work_sync(&lp->phy_configure);
 
 	bmcr = smc_phy_read(dev, phy, MII_BMCR);
 	smc_phy_write(dev, phy, MII_BMCR, bmcr | BMCR_PDOWN);
@@ -1161,7 +1154,6 @@ static void smc_phy_configure(struct work_struct *work)
 smc_phy_configure_exit:
 	SMC_SELECT_BANK(lp, 2);
 	spin_unlock_irq(&lp->lock);
-	lp->work_pending = 0;
 }
 
 /*
@@ -1389,11 +1381,8 @@ static void smc_timeout(struct net_device *dev)
 	 * smc_phy_configure() calls msleep() which calls schedule_timeout()
 	 * which calls schedule().  Hence we use a work queue.
 	 */
-	if (lp->phy_type != 0) {
-		if (schedule_work(&lp->phy_configure)) {
-			lp->work_pending = 1;
-		}
-	}
+	if (lp->phy_type != 0)
+		schedule_work(&lp->phy_configure);
 
 	/* We can accept TX packets again */
 	dev->trans_start = jiffies;
diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
index 55670b5..af8d2c4 100644
--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -731,7 +731,7 @@ static void tulip_down (struct net_device *dev)
 	void __iomem *ioaddr = tp->base_addr;
 	unsigned long flags;
 
-	flush_scheduled_work();
+	cancel_work_sync(&tp->media_work);
 
 #ifdef CONFIG_TULIP_NAPI
 	napi_disable(&tp->napi);
diff --git a/drivers/net/usb/kaweth.c b/drivers/net/usb/kaweth.c
index 0dcfc03..7c66b05 100644
--- a/drivers/net/usb/kaweth.c
+++ b/drivers/net/usb/kaweth.c
@@ -706,7 +706,7 @@ static void kaweth_kill_urbs(struct kaweth_device *kaweth)
 	usb_kill_urb(kaweth->rx_urb);
 	usb_kill_urb(kaweth->tx_urb);
 
-	flush_scheduled_work();
+	cancel_delayed_work_sync(&kaweth->lowmem_work);
 
 	/* a scheduled work may have resubmitted,
 	   we hit them again */
diff --git a/drivers/net/wireless/hostap/hostap_main.c b/drivers/net/wireless/hostap/hostap_main.c
index 20d387f..f7aec93 100644
--- a/drivers/net/wireless/hostap/hostap_main.c
+++ b/drivers/net/wireless/hostap/hostap_main.c
@@ -682,7 +682,13 @@ static int prism2_close(struct net_device *dev)
 		netif_device_detach(dev);
 	}
 
-	flush_scheduled_work();
+	cancel_work_sync(&local->reset_queue);
+	cancel_work_sync(&local->set_multicast_list_queue);
+	cancel_work_sync(&local->set_tim_queue);
+#ifndef PRISM2_NO_STATION_MODES
+	cancel_work_sync(&local->info_queue);
+#endif
+	cancel_work_sync(&local->comms_qual_update);
 
 	module_put(local->hw_module);
 
