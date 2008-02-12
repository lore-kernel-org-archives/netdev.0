From: Matti Linnanvuori <mattilinnanvuori@yahoo.com>
Subject: [Bug 9750] [patch 2.6.25] dev: avoid a race that triggers assertion failure
Date: Tue, 12 Feb 2008 02:45:22 -0800 (PST)
Message-ID: <190693.34289.qm@web52005.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bugme-daemon@kernel-bugs.osdl.org
To: jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web52005.mail.re2.yahoo.com ([206.190.49.252]:43116 "HELO
	web52005.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1761702AbYBLKwE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2008 05:52:04 -0500
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

--- linux-2.6.25/net/core/dev.c    2008-02-12 12:37:51.206833000 +0200
+++ b/net/core/dev.c    2008-02-12 12:38:48.727611400 +0200
@@ -1071,8 +1071,6 @@ int dev_close(struct net_device *dev)
      */
     call_netdevice_notifiers(NETDEV_GOING_DOWN, dev);
 
-    dev_deactivate(dev);
-
     clear_bit(__LINK_STATE_START, &dev->state);
 
     /* Synchronize to scheduled poll. We cannot touch poll list,
@@ -1083,6 +1081,7 @@ int dev_close(struct net_device *dev)
      */
     smp_mb__after_clear_bit(); /* Commit netif_running(). */
 
+    dev_deactivate(dev);
     /*
      *    Call the device specific close. This cannot fail.
      *    Only if device is UP





      ____________________________________________________________________________________
Be a better friend, newshound, and 
know-it-all with Yahoo! Mobile.  Try it now.  http://mobile.yahoo.com/;_ylt=Ahu06i62sR8HDtDypao8Wcj9tAcJ 

