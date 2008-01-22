From: Matti Linnanvuori <mattilinnanvuori@yahoo.com>
Subject: [Bug 9750] dev: avoid a race that triggers assertion failure
Date: Tue, 22 Jan 2008 03:27:00 -0800 (PST)
Message-ID: <265315.88937.qm@web52009.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bugme-daemon@kernel-bugs.osdl.org
To: netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from web52009.mail.re2.yahoo.com ([206.190.48.58]:26729 "HELO
	web52009.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750823AbYAVL1D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 06:27:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matti Linnanvuori <mattilinnanvuori@yahoo.com>

There is a race in Linux kernel file net/core/dev.c, function dev_close.
The function calls function dev_deactivate, which calls function
dev_watchdog_down that deletes the watchdog timer. However, after that, a
driver can call netif_carrier_ok, which calls function
__netdev_watchdog_up that can add the watchdog timer again. Function
unregister_netdevice calls function dev_shutdown that traps the bug
!timer_pending(&dev->watchdog_timer).

Signed-off-by: Matti Linnanvuori <mattilinnanvuori@yahoo.com>

---

--- linux-2.6.23.8/net/core/dev.c    2007-11-16 20:14:27.000000000 +0200
+++ linux-2.6.23.15/net/core/dev.c    2008-01-22 13:16:12.347125794 +0200
@@ -1013,8 +1013,6 @@ int dev_close(struct net_device *dev)
      */
     raw_notifier_call_chain(&netdev_chain, NETDEV_GOING_DOWN, dev);
 
-    dev_deactivate(dev);
-
     clear_bit(__LINK_STATE_START, &dev->state);
 
     /* Synchronize to scheduled poll. We cannot touch poll list,
@@ -1029,6 +1027,8 @@ int dev_close(struct net_device *dev)
         msleep(1);
     }
 
+    dev_deactivate(dev);
+
     /*
      *    Call the device specific close. This cannot fail.
      *    Only if device is UP





      ____________________________________________________________________________________
Looking for last minute shopping deals?  
Find them fast with Yahoo! Search.  http://tools.search.yahoo.com/newsearch/category.php?category=shopping
