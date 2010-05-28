From: Finn Thain <fthain@telegraphics.com.au>
Subject: [PATCH] mac8390: change an error return code and some cleanup, take
 4
Date: Sat, 29 May 2010 03:29:01 +1000 (EST)
Message-ID: <alpine.OSX.2.00.1005290255580.691@localhost>
References: <alpine.OSX.2.00.1004161403160.271@localhost> <alpine.OSX.2.00.1004162347390.271@localhost> <alpine.OSX.2.00.1004171258330.358@localhost> <20100421.163041.158540277.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: joe@perches.com, p_gortmaker@yahoo.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-m68k@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <20100421.163041.158540277.davem@davemloft.net>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Propagate the request_irq() return code. Also promote the log level of the 
failure message. Likewise some other KERN_INFO messages.

Signed-off-by: Finn Thain <fthain@telegraphics.com.au>

Index: linux-2.6.34/drivers/net/mac8390.c
===================================================================
--- linux-2.6.34.orig/drivers/net/mac8390.c	2010-05-28 00:27:30.000000000 +1000
+++ linux-2.6.34/drivers/net/mac8390.c	2010-05-28 00:27:32.000000000 +1000
@@ -556,7 +556,7 @@ static int __init mac8390_initdev(struct
 	case MAC8390_APPLE:
 		switch (mac8390_testio(dev->mem_start)) {
 		case ACCESS_UNKNOWN:
-			pr_info("Don't know how to access card memory!\n");
+			pr_err("Don't know how to access card memory!\n");
 			return -ENODEV;
 			break;
 
@@ -643,10 +643,13 @@ static int __init mac8390_initdev(struct
 
 static int mac8390_open(struct net_device *dev)
 {
+	int err;
+
 	__ei_open(dev);
-	if (request_irq(dev->irq, __ei_interrupt, 0, "8390 Ethernet", dev)) {
-		pr_info("%s: unable to get IRQ %d.\n", dev->name, dev->irq);
-		return -EAGAIN;
+	err = request_irq(dev->irq, __ei_interrupt, 0, "8390 Ethernet", dev);
+	if (err) {
+		pr_err("%s: unable to get IRQ %d\n", dev->name, dev->irq);
+		return err;
 	}
 	return 0;
 }
@@ -662,7 +665,7 @@ static void mac8390_no_reset(struct net_
 {
 	ei_status.txing = 0;
 	if (ei_debug > 1)
-		pr_info("reset not supported\n");
+		printk(KERN_DEBUG pr_fmt("reset not supported\n"));
 	return;
 }
 
@@ -670,7 +673,7 @@ static void interlan_reset(struct net_de
 {
 	unsigned char *target = nubus_slot_addr(IRQ2SLOT(dev->irq));
 	if (ei_debug > 1)
-		pr_info("Need to reset the NS8390 t=%lu...", jiffies);
+		printk(KERN_DEBUG pr_fmt("Need to reset the NS8390 t=%lu..."), jiffies);
 	ei_status.txing = 0;
 	target[0xC0000] = 0;
 	if (ei_debug > 1)
@@ -871,5 +874,3 @@ static void word_memcpy_fromcard(void *t
 	while (count--)
 		*to++ = *from++;
 }
-
-
