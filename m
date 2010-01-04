From: Joe Perches <joe@perches.com>
Subject: [PATCH 3/5] drivers/net/mac8390.c: Convert printk(KERN_<level> to pr_<level>(
Date: Mon,  4 Jan 2010 13:53:01 -0800
Message-ID: <cbb476c8d11f5c018e5616c9aadc86b30963d1c3.1262630406.git.joe@perches.com>
References: <cover.1262630406.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: Paul Gortmaker <p_gortmaker@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1492 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753435Ab0ADVxI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2010 16:53:08 -0500
In-Reply-To: <cover.1262630406.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use printk_once
Add #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
Convert printks without KERN_<level> to pr_info and pr_cont

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/mac8390.c |   57 +++++++++++++++++++++---------------------------
 1 files changed, 25 insertions(+), 32 deletions(-)

diff --git a/drivers/net/mac8390.c b/drivers/net/mac8390.c
index 517cee4..8bd09e2 100644
--- a/drivers/net/mac8390.c
+++ b/drivers/net/mac8390.c
@@ -17,6 +17,8 @@
 /* 2002-12-30: Try to support more cards, some clues from NetBSD driver */
 /* 2003-12-26: Make sure Asante cards always work. */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/types.h>
@@ -42,7 +44,7 @@
 #include <asm/macints.h>
 
 static char version[] =
-	"mac8390.c: v0.4 2001-05-15 David Huggins-Daines <dhd@debian.org> and others\n";
+	"v0.4 2001-05-15 David Huggins-Daines <dhd@debian.org> and others\n";
 
 #define EI_SHIFT(x)	(ei_local->reg_offset[x])
 #define ei_inb(port)   in_8(port)
@@ -288,7 +290,6 @@ struct net_device * __init mac8390_probe(int unit)
 {
 	struct net_device *dev;
 	volatile unsigned short *i;
-	int version_disp = 0;
 	struct nubus_dev * ndev = NULL;
 	int err = -ENODEV;
 
@@ -320,10 +321,7 @@ struct net_device * __init mac8390_probe(int unit)
 		if ((cardtype = mac8390_ident(ndev)) == MAC8390_NONE)
 			continue;
 
-		if (version_disp == 0) {
-			version_disp = 1;
-			printk(version);
-		}
+		printk_once(KERN_INFO pr_fmt(version));
 
 		dev->irq = SLOT2IRQ(ndev->board->slot);
 		/* This is getting to be a habit */
@@ -333,16 +331,14 @@ struct net_device * __init mac8390_probe(int unit)
 		   of where its memory and registers are. */
 
 		if (nubus_get_func_dir(ndev, &dir) == -1) {
-			printk(KERN_ERR "%s: Unable to get Nubus functional"
-					" directory for slot %X!\n",
+			pr_err("%s: Unable to get Nubus functional directory for slot %X!\n",
 			       dev->name, ndev->board->slot);
 			continue;
 		}
 
 		/* Get the MAC address */
 		if ((nubus_find_rsrc(&dir, NUBUS_RESID_MAC_ADDRESS, &ent)) == -1) {
-			printk(KERN_INFO "%s: Couldn't get MAC address!\n",
-					dev->name);
+			pr_info("%s: Couldn't get MAC address!\n", dev->name);
 			continue;
 		} else {
 			nubus_get_rsrc_mem(dev->dev_addr, &ent, 6);
@@ -351,8 +347,7 @@ struct net_device * __init mac8390_probe(int unit)
 		if (useresources[cardtype] == 1) {
 			nubus_rewinddir(&dir);
 			if (nubus_find_rsrc(&dir, NUBUS_RESID_MINOR_BASEOS, &ent) == -1) {
-				printk(KERN_ERR "%s: Memory offset resource"
-						" for slot %X not found!\n",
+				pr_err("%s: Memory offset resource for slot %X not found!\n",
 				       dev->name, ndev->board->slot);
 				continue;
 			}
@@ -362,10 +357,8 @@ struct net_device * __init mac8390_probe(int unit)
 			dev->base_addr = dev->mem_start + 0x10000;
 			nubus_rewinddir(&dir);
 			if (nubus_find_rsrc(&dir, NUBUS_RESID_MINOR_LENGTH, &ent) == -1) {
-				printk(KERN_INFO "%s: Memory length resource"
-						 " for slot %X not found"
-						 ", probing\n",
-				       dev->name, ndev->board->slot);
+				pr_info("%s: Memory length resource for slot %X not found, probing\n",
+					dev->name, ndev->board->slot);
 				offset = mac8390_memsize(dev->mem_start);
 				} else {
 					nubus_get_rsrc_mem(&offset, &ent, 4);
@@ -417,8 +410,7 @@ struct net_device * __init mac8390_probe(int unit)
 				break;
 
 			default:
-				printk(KERN_ERR "Card type %s is"
-				       " unsupported, sorry\n",
+				pr_err("Card type %s is unsupported, sorry\n",
 				       ndev->board->name);
 				continue;
 			}
@@ -458,7 +450,7 @@ int init_module(void)
 		dev_mac890[i] = dev;
 	}
 	if (!i) {
-		printk(KERN_NOTICE "mac8390.c: No useable cards found, driver NOT installed.\n");
+		pr_notice("No useable cards found, driver NOT installed.\n");
 		return -ENODEV;
 	}
 	return 0;
@@ -545,7 +537,7 @@ static int __init mac8390_initdev(struct net_device * dev, struct nubus_dev * nd
 	case MAC8390_APPLE:
 		switch (mac8390_testio(dev->mem_start)) {
 		case ACCESS_UNKNOWN:
-			printk("Don't know how to access card memory!\n");
+			pr_info("Don't know how to access card memory!\n");
 			return -ENODEV;
 			break;
 
@@ -612,20 +604,21 @@ static int __init mac8390_initdev(struct net_device * dev, struct nubus_dev * nd
 	        break;
 
 	default:
-		printk(KERN_ERR "Card type %s is unsupported, sorry\n", ndev->board->name);
+		pr_err("Card type %s is unsupported, sorry\n",
+		       ndev->board->name);
 		return -ENODEV;
 	}
 
 	__NS8390_init(dev, 0);
 
 	/* Good, done, now spit out some messages */
-	printk(KERN_INFO "%s: %s in slot %X (type %s)\n",
-	       dev->name, ndev->board->name, ndev->board->slot, cardname[type]);
-	printk(KERN_INFO
-	       "MAC %pM IRQ %d, %d KB shared memory at %#lx, %d-bit access.\n",
-	       dev->dev_addr, dev->irq,
-	       (unsigned int)(dev->mem_end - dev->mem_start) >> 10,
-	       dev->mem_start, access_bitmode ? 32 : 16);
+	pr_info("%s: %s in slot %X (type %s)\n",
+		dev->name, ndev->board->name, ndev->board->slot,
+		cardname[type]);
+	pr_info("MAC %pM IRQ %d, %d KB shared memory at %#lx, %d-bit access.\n",
+		dev->dev_addr, dev->irq,
+		(unsigned int)(dev->mem_end - dev->mem_start) >> 10,
+		dev->mem_start, access_bitmode ? 32 : 16);
 	return 0;
 }
 
@@ -633,7 +626,7 @@ static int mac8390_open(struct net_device *dev)
 {
 	__ei_open(dev);
 	if (request_irq(dev->irq, __ei_interrupt, 0, "8390 Ethernet", dev)) {
-		printk ("%s: unable to get IRQ %d.\n", dev->name, dev->irq);
+		pr_info("%s: unable to get IRQ %d.\n", dev->name, dev->irq);
 		return -EAGAIN;
 	}
 	return 0;
@@ -650,7 +643,7 @@ static void mac8390_no_reset(struct net_device *dev)
 {
 	ei_status.txing = 0;
 	if (ei_debug > 1)
-		printk("reset not supported\n");
+		pr_info("reset not supported\n");
 	return;
 }
 
@@ -658,11 +651,11 @@ static void interlan_reset(struct net_device *dev)
 {
 	unsigned char *target=nubus_slot_addr(IRQ2SLOT(dev->irq));
 	if (ei_debug > 1)
-		printk("Need to reset the NS8390 t=%lu...", jiffies);
+		pr_info("Need to reset the NS8390 t=%lu...", jiffies);
 	ei_status.txing = 0;
 	target[0xC0000] = 0;
 	if (ei_debug > 1)
-		printk("reset complete\n");
+		pr_cont("reset complete\n");
 	return;
 }
 
-- 
1.6.6.rc0.57.gad7a

