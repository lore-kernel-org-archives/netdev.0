From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 5/7] sky2: NAPI suspend/resume of dual port cards
Date: Wed, 12 Jul 2006 15:23:46 -0700
Message-ID: <20060712222646.467993013@localhost.localdomain>
References: <20060712222341.686007133@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:18313 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751266AbWGLWb6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jul 2006 18:31:58 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-suspend-dev0-poll.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The changes to handle suspend/resume didn't handle the case where
a dual port card has the first port down, but the second is running.
In this driver, all NAPI polling is done on the primary port.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- sky2.orig/drivers/net/sky2.c	2006-07-07 16:31:29.000000000 -0700
+++ sky2/drivers/net/sky2.c	2006-07-07 16:35:29.000000000 -0700
@@ -3437,17 +3437,14 @@
 		return -EINVAL;
 
 	del_timer_sync(&hw->idle_timer);
+	netif_poll_disable(hw->dev[0]);
 
 	for (i = 0; i < hw->ports; i++) {
 		struct net_device *dev = hw->dev[i];
 
-		if (dev) {
-			if (!netif_running(dev))
-				continue;
-
+		if (netif_running(dev)) {
 			sky2_down(dev);
 			netif_device_detach(dev);
-			netif_poll_disable(dev);
 		}
 	}
 
@@ -3474,9 +3471,8 @@
 
 	for (i = 0; i < hw->ports; i++) {
 		struct net_device *dev = hw->dev[i];
-		if (dev && netif_running(dev)) {
+		if (netif_running(dev)) {
 			netif_device_attach(dev);
-			netif_poll_enable(dev);
 
 			err = sky2_up(dev);
 			if (err) {
@@ -3488,6 +3484,7 @@
 		}
 	}
 
+	netif_poll_enable(hw->dev[0]);
 	sky2_idle_start(hw);
 out:
 	return err;

--

