From: Finn Thain <fthain@telegraphics.com.au>
Subject: [PATCH] mac8390: change an error return code and some cleanup, take
 3
Date: Sat, 17 Apr 2010 13:16:04 +1000 (EST)
Message-ID: <alpine.OSX.2.00.1004171258330.358@localhost>
References: <alpine.OSX.2.00.1004161214270.271@localhost> <20100415.200113.215578006.davem@davemloft.net> <alpine.OSX.2.00.1004161323340.271@localhost> <alpine.OSX.2.00.1004161403160.271@localhost> <alpine.OSX.2.00.1004162347390.271@localhost>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: joe@perches.com, p_gortmaker@yahoo.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-m68k@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.telegraphics.com.au ([204.15.192.19]:54128 "EHLO
	mail.telegraphics.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758713Ab0DQDQJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Apr 2010 23:16:09 -0400
In-Reply-To: <alpine.OSX.2.00.1004162347390.271@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Change an error return code from -EAGAIN to -EBUSY since the former is 
misleading.

Nubus slots are geographically addressed and their irqs are equally 
inflexible. -EAGAIN is misleading because retrying will not help fix 
whatever bug it was that made the irq unavailable.

Also promote the log message. Likewise some other KERN_INFO log messages.

Signed-off-by: Finn Thain <fthain@telegraphics.com.au>

--- a/drivers/net/mac8390.c	2010-04-16 13:31:04.000000000 +1000
+++ b/drivers/net/mac8390.c	2010-04-16 23:50:39.000000000 +1000
@@ -554,7 +554,7 @@
 	case MAC8390_APPLE:
 		switch (mac8390_testio(dev->mem_start)) {
 		case ACCESS_UNKNOWN:
-			pr_info("Don't know how to access card memory!\n");
+			pr_err("Don't know how to access card memory!\n");
 			return -ENODEV;
 			break;
 
@@ -643,8 +643,8 @@
 {
 	__ei_open(dev);
 	if (request_irq(dev->irq, __ei_interrupt, 0, "8390 Ethernet", dev)) {
-		pr_info("%s: unable to get IRQ %d.\n", dev->name, dev->irq);
-		return -EAGAIN;
+		pr_err("%s: unable to get IRQ %d.\n", dev->name, dev->irq);
+		return -EBUSY;
 	}
 	return 0;
 }
@@ -660,7 +660,7 @@
 {
 	ei_status.txing = 0;
 	if (ei_debug > 1)
-		pr_info("reset not supported\n");
+		printk(KERN_DEBUG pr_fmt("reset not supported\n"));
 	return;
 }
 
@@ -668,7 +668,7 @@
 {
 	unsigned char *target = nubus_slot_addr(IRQ2SLOT(dev->irq));
 	if (ei_debug > 1)
-		pr_info("Need to reset the NS8390 t=%lu...", jiffies);
+		printk(KERN_DEBUG pr_fmt("Need to reset the NS8390 t=%lu..."), jiffies);
 	ei_status.txing = 0;
 	target[0xC0000] = 0;
 	if (ei_debug > 1)
 
