From: Matti Linnanvuori <mattilinnanvuori@yahoo.com>
Subject: [Bug 9750] [patch 2.6.24] dev: avoid a race that triggers assertion failure
Date: Tue, 22 Jan 2008 22:34:05 -0800 (PST)
Message-ID: <912509.75954.qm@web52011.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bugme-daemon@kernel-bugs.osdl.org
To: netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from web52011.mail.re2.yahoo.com ([206.190.48.27]:31402 "HELO
	web52011.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753338AbYAWGeH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 01:34:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matti Linnanvuori <mattilinnanvuori@yahoo.com>

There is a race in Linux kernel file net/core/dev.c, function dev_close.
The function calls function dev_deactivate, which calls function
dev_watchdog_down that deletes the watchdog timer. However, after that, a
driver can call netif_carrier_ok, which calls function
__netdev_watchdog_up that can add the watchdog timer again. Function
unregister_netdevice calls function dev_shutdown that traps the bug
!timer_pending(&dev->watchdog_timer). Moving dev_deactivate after
netif_running() has been cleared prevents function netif_carrier_on
from calling __netdev_watchdog_up and adding the watchdog timer again.

Signed-off-by: Matti Linnanvuori <mattilinnanvuori@yahoo.com>

---

--- linux-2.6.24/net/core/dev.c    2008-01-23 08:20:55.733012300 +0200
+++ b/net/core/dev.c    2008-01-23 08:24:32.818766600 +0200
@@ -1068,8 +1068,6 @@ int dev_close(struct net_device *dev)
      */
     call_netdevice_notifiers(NETDEV_GOING_DOWN, dev);
 
-    dev_deactivate(dev);
-
     clear_bit(__LINK_STATE_START, &dev->state);
 
     /* Synchronize to scheduled poll. We cannot touch poll list,
@@ -1080,6 +1078,8 @@ int dev_close(struct net_device *dev)
      */
     smp_mb__after_clear_bit(); /* Commit netif_running(). */
 
+    dev_deactivate(dev);
+
     /*
      *    Call the device specific close. This cannot fail.
      *    Only if device is UP





      ____________________________________________________________________________________
Never miss a thing.  Make Yahoo your home page. 
http://www.yahoo.com/r/hs
