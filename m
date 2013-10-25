From: Drew McGowen <quantumdude836@gmail.com>
Subject: [PATCH net-next] WD80x3: fix printk() calls to netdev_*() calls
Date: Fri, 25 Oct 2013 21:56:05 +0000
Message-ID: <1382738165-27852-1-git-send-email-quantumdude836@gmail.com>
Cc: Drew McGowen <quantumdude836@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f47.google.com ([209.85.216.47]:42635 "EHLO
	mail-qa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752135Ab3JYV4S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Oct 2013 17:56:18 -0400
Received: by mail-qa0-f47.google.com with SMTP id k15so902983qaq.20
        for <netdev@vger.kernel.org>; Fri, 25 Oct 2013 14:56:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace legacy-style printk() calls to use netdev_<level> functions. Also fix
version printing to use pr_info_once().

Reviewed-by: Ben Pringle <ben.pringle@gmail.com>
Signed-off-by: Drew McGowen <quantumdude836@gmail.com>
---
 drivers/net/ethernet/8390/wd.c | 31 ++++++++++++++++---------------
 1 file changed, 16 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/8390/wd.c b/drivers/net/ethernet/8390/wd.c
index 03eb3ee..38d3110 100644
--- a/drivers/net/ethernet/8390/wd.c
+++ b/drivers/net/ethernet/8390/wd.c
@@ -26,7 +26,7 @@
 */
 
 static const char version[] =
-	"wd.c:v1.10 9/23/94 Donald Becker (becker@cesdis.gsfc.nasa.gov)\n";
+	"wd.c:v1.10 9/23/94 Donald Becker (becker@cesdis.gsfc.nasa.gov)";
 
 #include <linux/module.h>
 #include <linux/kernel.h>
@@ -169,7 +169,6 @@ static int __init wd_probe1(struct net_device *dev, int ioaddr)
 	int ancient = 0;			/* An old card without config registers. */
 	int word16 = 0;				/* 0 = 8 bit, 1 = 16 bit */
 	const char *model_name;
-	static unsigned version_printed;
 
 	for (i = 0; i < 8; i++)
 		checksum += inb(ioaddr + 8 + i);
@@ -180,19 +179,19 @@ static int __init wd_probe1(struct net_device *dev, int ioaddr)
 
 	/* Check for semi-valid mem_start/end values if supplied. */
 	if ((dev->mem_start % 0x2000) || (dev->mem_end % 0x2000)) {
-		printk(KERN_WARNING "wd.c: user supplied mem_start or mem_end not on 8kB boundary - ignored.\n");
+		netdev_warn(dev, "wd.c: user supplied mem_start or mem_end not on 8kB boundary - ignored.\n");
 		dev->mem_start = 0;
 		dev->mem_end = 0;
 	}
 
-	if (ei_debug  &&  version_printed++ == 0)
-		printk(version);
+	if (ei_debug)
+		pr_info_once("%s\n", version);
 
 	for (i = 0; i < 6; i++)
 		dev->dev_addr[i] = inb(ioaddr + 8 + i);
 
-	printk("%s: WD80x3 at %#3x, %pM",
-	       dev->name, ioaddr, dev->dev_addr);
+	netdev_info(dev, "WD80x3 at %#3x, %pM",
+		ioaddr, dev->dev_addr);
 
 	/* The following PureData probe code was contributed by
 	   Mike Jagdis <jaggy@purplet.demon.co.uk>. Puredata does software
@@ -244,7 +243,7 @@ static int __init wd_probe1(struct net_device *dev, int ioaddr)
 		}
 #ifndef final_version
 		if ( !ancient && (inb(ioaddr+1) & 0x01) != (word16 & 0x01))
-			printk("\nWD80?3: Bus width conflict, %d (probe) != %d (reg report).",
+			netdev_warn(dev, "\nWD80?3: Bus width conflict, %d (probe) != %d (reg report).",
 				   word16 ? 16 : 8, (inb(ioaddr+1) & 0x01) ? 16 : 8);
 #endif
 	}
@@ -259,7 +258,7 @@ static int __init wd_probe1(struct net_device *dev, int ioaddr)
 		if (reg0 == 0xff || reg0 == 0) {
 			/* Future plan: this could check a few likely locations first. */
 			dev->mem_start = 0xd0000;
-			printk(" assigning address %#lx", dev->mem_start);
+			pr_cont(" assigning address %#lx", dev->mem_start);
 		} else {
 			int high_addr_bits = inb(ioaddr+WD_CMDREG5) & 0x1f;
 			/* Some boards don't have the register 5 -- it returns 0xff. */
@@ -298,7 +297,7 @@ static int __init wd_probe1(struct net_device *dev, int ioaddr)
 			outb_p(0x00, nic_addr+EN0_IMR);	/* Mask all intrs. again. */
 
 			if (ei_debug > 2)
-				printk(" autoirq is %d", dev->irq);
+				pr_cont(" autoirq is %d", dev->irq);
 			if (dev->irq < 2)
 				dev->irq = word16 ? 10 : 5;
 		} else
@@ -310,7 +309,7 @@ static int __init wd_probe1(struct net_device *dev, int ioaddr)
 	   share and the board will usually be enabled. */
 	i = request_irq(dev->irq, ei_interrupt, 0, DRV_NAME, dev);
 	if (i) {
-		printk (" unable to get IRQ %d.\n", dev->irq);
+		pr_cont(" unable to get IRQ %d.\n", dev->irq);
 		return i;
 	}
 
@@ -338,7 +337,7 @@ static int __init wd_probe1(struct net_device *dev, int ioaddr)
 		return -ENOMEM;
 	}
 
-	printk(" %s, IRQ %d, shared memory at %#lx-%#lx.\n",
+	pr_cont(" %s, IRQ %d, shared memory at %#lx-%#lx.\n",
 		   model_name, dev->irq, dev->mem_start, dev->mem_end-1);
 
 	ei_status.reset_8390 = wd_reset_8390;
@@ -387,7 +386,8 @@ wd_reset_8390(struct net_device *dev)
 	int wd_cmd_port = dev->base_addr - WD_NIC_OFFSET; /* WD_CMDREG */
 
 	outb(WD_RESET, wd_cmd_port);
-	if (ei_debug > 1) printk("resetting the WD80x3 t=%lu...", jiffies);
+	if (ei_debug > 1)
+		netdev_dbg(dev, "resetting the WD80x3 t=%lu...", jiffies);
 	ei_status.txing = 0;
 
 	/* Set up the ASIC registers, just in case something changed them. */
@@ -395,7 +395,8 @@ wd_reset_8390(struct net_device *dev)
 	if (ei_status.word16)
 		outb(NIC16 | ((dev->mem_start>>19) & 0x1f), wd_cmd_port+WD_CMDREG5);
 
-	if (ei_debug > 1) printk("reset done\n");
+	if (ei_debug > 1)
+		pr_cont("reset done\n");
 }
 
 /* Grab the 8390 specific header. Similar to the block_input routine, but
@@ -476,7 +477,7 @@ wd_close(struct net_device *dev)
 	int wd_cmdreg = dev->base_addr - WD_NIC_OFFSET; /* WD_CMDREG */
 
 	if (ei_debug > 1)
-		printk("%s: Shutting down ethercard.\n", dev->name);
+		netdev_info(dev, "Shutting down ethercard.\n");
 	ei_close(dev);
 
 	/* Change from 16-bit to 8-bit shared memory so reboot works. */
-- 
1.8.1.2
