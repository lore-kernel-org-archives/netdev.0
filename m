From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] Mark COMPAT_NET_DEV_OPS option for removal
Date: Sat, 23 May 2009 08:12:21 -0700
Message-ID: <20090523081221.61709ec5@nehalam>
References: <1243088259-16482-1-git-send-email-a.beregalov@gmail.com>
	<20090523074143.445ef830@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexander Beregalov <a.beregalov@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56597 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751743AbZEWPMZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 May 2009 11:12:25 -0400
In-Reply-To: <20090523074143.445ef830@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mark the flag as deprecated and default off so users won't use it
by default. Make the message that was a informational into a full
warning with backtrace, so any usage gets noticed.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/Documentation/feature-removal-schedule.txt	2009-05-23 07:45:26.920460911 -0700
+++ b/Documentation/feature-removal-schedule.txt	2009-05-23 07:48:53.043372890 -0700
@@ -437,3 +437,14 @@ Why:	Superseded by tdfxfb. I2C/DDC suppo
 	driver but this caused driver conflicts.
 Who:	Jean Delvare <khali@linux-fr.org>
 	Krzysztof Helt <krzysztof.h1@wp.pl>
+
+---------------------------
+
+What:   COMPAT_NET_DEV_OPS interface
+When:   December 2009
+Why:    All network drivers in tree have been converted to the net_device_ops
+        interface. The compatiablity interface is no longer needed.
+
+	The interface will maintained for a short period to get out of
+        tree drivers to convert.
+Who:    Stephen Hemminger <shemminger@vayatta.com>
--- a/drivers/net/Kconfig	2009-05-23 07:49:33.004641071 -0700
+++ b/drivers/net/Kconfig	2009-05-23 08:02:53.444272608 -0700
@@ -26,13 +26,12 @@ menuconfig NETDEVICES
 if NETDEVICES
 
 config COMPAT_NET_DEV_OPS
-       default y
-       bool "Enable older network device API compatibility"
+       bool "Enable older network device API compatibility (DEPRECATED)"
+       default n
        ---help---
-          This option enables kernel compatibility with older network devices
-          that do not use net_device_ops interface.
-
-	  If unsure, say Y.
+          This option enables backward compatibility with older network devices
+          that do not use net_device_ops interface. All devices should be
+          converted to the net_device_ops.
 
 config IFB
 	tristate "Intermediate Functional Block support"
--- a/net/core/dev.c	2009-05-23 07:51:58.131254792 -0700
+++ b/net/core/dev.c	2009-05-23 07:58:25.749465521 -0700
@@ -4653,20 +4653,16 @@ int register_netdevice(struct net_device
 	dev->iflink = -1;
 
 #ifdef CONFIG_COMPAT_NET_DEV_OPS
+	WARN(!dev->netdev_ops, "%s: not using net_device_ops\n", dev->name);
 	/* Netdevice_ops API compatibility support.
 	 * This is temporary until all network devices are converted.
 	 */
-	if (dev->netdev_ops) {
+	if (dev->netdev_ops)
 		netdev_resync_ops(dev);
-	} else {
-		char drivername[64];
-		pr_info("%s (%s): not using net_device_ops yet\n",
-			dev->name, netdev_drivername(dev, drivername, 64));
-
+	else
 		/* This works only because net_device_ops and the
 		   compatibility structure are the same. */
 		dev->netdev_ops = (void *) &(dev->init);
-	}
 #endif
 
 	/* Init, if this function is available */
