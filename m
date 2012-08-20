From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next] net: Set device operstate at registration time
Date: Mon, 20 Aug 2012 22:16:51 +0100
Message-ID: <1345497411.2659.28.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Ilya Shchepetkov <shchepetkov@ispras.ru>, <bjorn@mork.no>,
	Michael Marineau <mike@marineau.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:42673 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754956Ab2HTVQ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2012 17:16:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The operstate of a device is initially IF_OPER_UNKNOWN and is updated
asynchronously by linkwatch after each change of carrier state
reported by the driver.  The default carrier state of a net device is
on, and this will never be changed on drivers that do not support
carrier detection, thus the operstate remains IF_OPER_UNKNOWN.

For devices that do support carrier detection, the driver must set the
carrier state to off initially, then poll the hardware state when the
device is opened.  However, we must not activate linkwatch for a
unregistered device, and commit b473001 ('net: Do not fire linkwatch
events until the device is registered.') ensured that we don't.  But
this means that the operstate for many devices that support carrier
detection remains IF_OPER_UNKNOWN when it should be IF_OPER_DOWN.

The same issue exists with the dormant state.

The proper initialisation sequence, avoiding a race with opening of
the device, is:

        rtnl_lock();
        rc = register_netdevice(dev);
        if (rc)
                goto out_unlock;
        netif_carrier_off(dev); /* or netif_dormant_on(dev) */
        rtnl_unlock();

but it seems silly that this should have to be repeated in so many
drivers.  Further, the operstate seen immediately after opening the
device may still be IF_OPER_UNKNOWN due to the asynchronous nature of
linkwatch.

Commit 22604c8 ('net: Fix for initial link state in 2.6.28') attempted
to fix this by setting the operstate synchronously, but it was
reverted as it could lead to deadlock.

This initialises the operstate synchronously at registration time
only.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
This seems to deal properly with the registration-time problem, but not
the case where a device is brought down and then up again.  Many but not
all drivers that support carrier detection call netif_carrier_off() in
their ndo_stop method.  Should the others be changed, or is there some
way we can make that automatic?

Ben.

 include/linux/netdevice.h |    1 +
 net/core/dev.c            |    2 ++
 net/core/link_watch.c     |    8 ++++++++
 3 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 1d6ab69..72ae4cf 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2224,6 +2224,7 @@ static inline void dev_hold(struct net_device *dev)
  * kind of lower layer not just hardware media.
  */
 
+extern void linkwatch_init_dev(struct net_device *dev);
 extern void linkwatch_fire_event(struct net_device *dev);
 extern void linkwatch_forget_dev(struct net_device *dev);
 
diff --git a/net/core/dev.c b/net/core/dev.c
index ce1bccb..2baeceb 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5639,6 +5639,8 @@ int register_netdevice(struct net_device *dev)
 
 	set_bit(__LINK_STATE_PRESENT, &dev->state);
 
+	linkwatch_init_dev(dev);
+
 	dev_init_scheduler(dev);
 	dev_hold(dev);
 	list_netdevice(dev);
diff --git a/net/core/link_watch.c b/net/core/link_watch.c
index c3519c6..a019222 100644
--- a/net/core/link_watch.c
+++ b/net/core/link_watch.c
@@ -76,6 +76,14 @@ static void rfc2863_policy(struct net_device *dev)
 }
 

+void linkwatch_init_dev(struct net_device *dev)
+{
+	/* Handle pre-registration link state changes */
+	if (!netif_carrier_ok(dev) || netif_dormant(dev))
+		rfc2863_policy(dev);
+}
+
+
 static bool linkwatch_urgent_event(struct net_device *dev)
 {
 	if (!netif_running(dev))
-- 
1.7.7.6
