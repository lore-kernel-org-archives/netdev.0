From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.25rc7 lockdep trace
Date: Tue, 10 Jun 2008 22:40:23 -0700 (PDT)
Message-ID: <20080610.224023.116817726.davem@davemloft.net>
References: <1206784948.22530.128.camel@johannes.berg>
	<20080403.134813.201577998.davem@davemloft.net>
	<1207320492.19189.33.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davej@codemonkey.org.uk, netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43855
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751559AbYFKFkX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2008 01:40:23 -0400
In-Reply-To: <1207320492.19189.33.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Fri, 04 Apr 2008 16:48:12 +0200

I'm attempting to bring solving this problem back from the dead.

Please help!

> On Thu, 2008-04-03 at 13:48 -0700, David Miller wrote:
> > From: Johannes Berg <johannes@sipsolutions.net>
> > Date: Sat, 29 Mar 2008 11:02:28 +0100
> > 
> > > However, as I just tried to explain, cancel_work_sync() _is_ safe to run
> > > while holding the RTNL because it doesn't need any runqueue lock.
> > 
> > So in theory we should be able to safely transform
> > flush_scheduled_work() calls in network driver close
> > methods into cancel_work_sync()?
> 
> Yes, more precisely cancel_work_sync() for each work struct the driver
> uses, unless the driver actually requires that the work runs before it
> goes down.

Ok, I did an audit of all the drivers under drivers/net that invoke
flush_scheduled_work().  Here is my audit analysis and the patch I
came up with.  The only deadlock'y case I couldn't fix right now is
the cassini driver, see below for details and the patch:

8139too: Calls flush_scheduled_work() in device remove method, OK.
libertas: Calls flush_scheduled_work() in device probe and remove methods, OK.
bnx2: Uses special polling mdelay() sequence instead of calling
      flush_scheduled_work() in close method, converted to
      cancel_work_sync().
cassini: Does flush_scheduled_work() from ->change_mtu() method, which
	 also holds RTNL semaphore.  Seems tricky to fix as it's trying
	 to schedule work and then immediately wait for it to
	 complete synchronously before returning from the ->change_mtu
	 method.  Maybe calling cas_reset_task() directly would work,
	 but this could conflict with reset tasks scheduled in other
	 contexts.  NOT FIXED
e1000e: Does flush_scheduled_work() from device remove method, OK.
ehea_main: Does flush_scheduled_work() in ->stop method, converted to
	   cancel_work_sync().
baycom_epp: Does flush_scheduled_work() from ->stop method, converted
	    to cancel_delayed_work()/cancel_work_sync() sequence.
ibm_newemac: Calls flush_scheduled_work() from device remove method, OK.
igb: Calls flush_scheduled_work() from device remove method, OK.
irda/mcs7780: Calls flush_scheduled_work() from USB disconnect, OK.
iseries_veth: Calls flush_scheduled_work() from device disconnect and module
	      exit, OK.
ixgbe: Calls flush_scheduled_work() from device remove method, OK.
mv643xx_eth: Calls flush_scheduled_work() from device remove method, OK.
myri10ge: Calls flush_scheduled_work() from device remove method, OK.
netxen: Has it's own hand-grown scheme to work around the flush_scheduled_work()
	deadlock.  Using a workqueue and flush_workqueue().
niu: Calls flush_scheduled_work() only from suspend handler, OK.
phy/phy.c: Avoids flush_scheduled_work() calls to avoid deadlock, uses
	   cancel_work_sync() instead.
r8169: Calls flush_scheduled_work() from device remove method, OK.
s2io: Calls flush_scheduled_work() from device remove method, OK.
sis190: Calls flush_scheduled_work() from device remove method, OK.
skge.c: Calls flush_scheduled_work() from device remove method, OK.
smc911x: Uses a similar polling loop like bnx2 did, converted to
	   cancel_work_sync().
smc91x: Same as smc911x
sungem: Calls flush_scheduled_work() only from suspend and device
	remove method, OK.
tg3: Calls flush_scheduled_work() only from suspend and device remove
     method, OK.
tulip_core: Calls flush_scheduled_work() from tulip_down(), converted to
	    cancel_work_sync().
kaweth: Calls flush_scheduled_work() from kaweth_kill_urbs() which can
	run from the ->stop() handler, converted to
	cancel_delayed_work/cancel_work_sync sequence.
usbnet:	Only calls flush_scheduled_work() from disconnect handler, OK.
hostap: Calls flush_scheduled_work() from ->stop, converted to
	cancel_work_sync()

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
index dde9c7e..b36ae41 100644
--- a/drivers/net/hamradio/baycom_epp.c
+++ b/drivers/net/hamradio/baycom_epp.c
@@ -959,7 +959,8 @@ static int epp_close(struct net_device *dev)
 	unsigned char tmp[1];
 
 	bc->work_running = 0;
-	flush_scheduled_work();
+	cancel_delayed_work(&bc->run_work);
+	cancel_work_sync(&bc->run_work.work);
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
index 0dcfc03..d776bcf 100644
--- a/drivers/net/usb/kaweth.c
+++ b/drivers/net/usb/kaweth.c
@@ -706,7 +706,8 @@ static void kaweth_kill_urbs(struct kaweth_device *kaweth)
 	usb_kill_urb(kaweth->rx_urb);
 	usb_kill_urb(kaweth->tx_urb);
 
-	flush_scheduled_work();
+	cancel_delayed_work(&kaweth->lowmem_work);
+	cancel_work_sync(&kaweth->lowmem_work.work);
 
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
 
