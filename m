From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] sky2: netconsole suspend/resume interaction
Date: Fri, 16 Jun 2006 12:12:56 -0700
Message-ID: <20060616121256.70bcae13@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:55961 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751453AbWFPTM5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2006 15:12:57 -0400
Received: from shell0.pdx.osdl.net (fw.osdl.org [65.172.181.6])
	by smtp.osdl.org (8.12.8/8.12.8) with ESMTP id k5GJCugt021166
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 16 Jun 2006 12:12:57 -0700
Received: from localhost.localdomain (freekitty.pdx.osdl.net [10.8.0.54])
	by shell0.pdx.osdl.net (8.13.1/8.11.6) with ESMTP id k5GJCuR2027025
	for <netdev@vger.kernel.org>; Fri, 16 Jun 2006 12:12:56 -0700
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A couple of fixes that should prevent crashes when using netconsole and
suspend/resume. First, netconsole poll routine shouldn't run unless the
device is up; second, the NAPI poll should be disabled during suspend.

This is only an issue on sky2, because it has to have one NAPI poll
routine for both ports on dual port boards. Normal drivers use 
netif_rx_schedule_prep and that checks for netif_running.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- sky2.orig/drivers/net/sky2.c	2006-06-15 14:36:05.000000000 -0700
+++ sky2/drivers/net/sky2.c	2006-06-15 15:04:55.000000000 -0700
@@ -2255,8 +2255,10 @@
 static void sky2_netpoll(struct net_device *dev)
 {
 	struct sky2_port *sky2 = netdev_priv(dev);
+	struct net_device *dev0 = sky2->hw->dev[0];
 
-	sky2_intr(sky2->hw->pdev->irq, sky2->hw, NULL);
+	if (netif_running(dev) && __netif_rx_schedule_prep(dev0))
+		__netif_rx_schedule(dev0);
 }
 #endif
 
@@ -3446,6 +3448,7 @@
 
 			sky2_down(dev);
 			netif_device_detach(dev);
+			netif_poll_disable(dev);
 		}
 	}
 
@@ -3474,6 +3477,8 @@
 		struct net_device *dev = hw->dev[i];
 		if (dev && netif_running(dev)) {
 			netif_device_attach(dev);
+			netif_poll_enable(dev);
+
 			err = sky2_up(dev);
 			if (err) {
 				printk(KERN_ERR PFX "%s: could not up: %d\n",
