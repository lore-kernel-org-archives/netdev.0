From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] sky2: netpoll on dual port cards
Date: Wed, 18 Oct 2006 13:39:28 -0700
Message-ID: <20061018133928.60052617@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:38579 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1422940AbWJRUoD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 16:44:03 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The sky2 driver uses a single NAPI poll routine for both ports on dual ported
cards (because there is a single IRQ and status ring). Netpoll makes assumptions
about the relationship between network device and NAPI that aren't correct
on the second port, this will cause the port to never clear work.

Most systems, just have single port, so not a big issue.
The easy fix is just make the second port, not netpoll capable.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- sky2.orig/drivers/net/sky2.c	2006-10-18 13:25:22.000000000 -0700
+++ sky2/drivers/net/sky2.c	2006-10-18 13:27:06.000000000 -0700
@@ -3255,7 +3255,11 @@
 		dev->poll = sky2_poll;
 	dev->weight = NAPI_WEIGHT;
 #ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = sky2_netpoll;
+	/* Network console (only works on port 0)
+	 * because netpoll makes assumptions about NAPI
+	 */
+	if (port == 0)
+		dev->poll_controller = sky2_netpoll;
 #endif
 
 	sky2 = netdev_priv(dev);
