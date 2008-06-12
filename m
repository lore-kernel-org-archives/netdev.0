From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.25rc7 lockdep trace
Date: Wed, 11 Jun 2008 22:46:39 -0700 (PDT)
Message-ID: <20080611.224639.250054768.davem@davemloft.net>
References: <20080403.134813.201577998.davem@davemloft.net>
	<1207320492.19189.33.camel@johannes.berg>
	<20080610.224023.116817726.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davej@codemonkey.org.uk, netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33952
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751564AbYFLFqj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2008 01:46:39 -0400
In-Reply-To: <20080610.224023.116817726.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 10 Jun 2008 22:40:23 -0700 (PDT)

> I'm attempting to bring solving this problem back from the dead.

Here is my current patch with a proper changelog.

Any objections to my pushing this to Linus?

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
index 4b46e68..48ed410 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -5907,12 +5907,7 @@ bnx2_close(struct net_device *dev)
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
index 4e28002..5c71098 100644
--- a/drivers/net/smc911x.c
+++ b/drivers/net/smc911x.c
@@ -1531,16 +1531,8 @@ static int smc911x_close(struct net_device *dev)
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
index a188e33..5dbe4d3 100644
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
index 20d387f..57b800f 100644
--- a/drivers/net/wireless/hostap/hostap_main.c
+++ b/drivers/net/wireless/hostap/hostap_main.c
@@ -682,7 +682,11 @@ static int prism2_close(struct net_device *dev)
 		netif_device_detach(dev);
 	}
 
-	flush_scheduled_work();
+	cancel_work_sync(&local->reset_queue);
+	cancel_work_sync(&local->set_multicast_list_queue);
+	cancel_work_sync(&local->set_tim_queue);
+	cancel_work_sync(&local->info_queue);
+	cancel_work_sync(&local->comms_qual_update);
 
 	module_put(local->hw_module);
 
