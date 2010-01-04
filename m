From: Joe Perches <joe@perches.com>
Subject: [PATCH 5/5] drivers/net/mac8390.c: Add mac8390_init function
Date: Mon,  4 Jan 2010 13:53:03 -0800
Message-ID: <cae9035503ce905e61c016c266bde68f3a781550.1262630406.git.joe@perches.com>
References: <cover.1262630406.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: Paul Gortmaker <p_gortmaker@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1498 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753541Ab0ADVxJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2010 16:53:09 -0500
In-Reply-To: <cover.1262630406.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reduce indentation, make code a little neater.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/mac8390.c |  207 +++++++++++++++++++++++++------------------------
 1 files changed, 105 insertions(+), 102 deletions(-)

diff --git a/drivers/net/mac8390.c b/drivers/net/mac8390.c
index 8f16889..c70bd68 100644
--- a/drivers/net/mac8390.c
+++ b/drivers/net/mac8390.c
@@ -295,16 +295,114 @@ static int __init mac8390_memsize(unsigned long membase)
 	return i * 0x1000;
 }
 
+static bool __init mac8390_init(struct net_device *dev, struct nubus_dev *ndev,
+				enum mac8390_type cardtype)
+{
+	struct nubus_dir dir;
+	struct nubus_dirent ent;
+	int offset;
+	volatile unsigned short *i;
+
+	printk_once(KERN_INFO pr_fmt(version));
+
+	dev->irq = SLOT2IRQ(ndev->board->slot);
+	/* This is getting to be a habit */
+	dev->base_addr = (ndev->board->slot_addr |
+			  ((ndev->board->slot & 0xf) << 20));
+
+	/*
+	 * Get some Nubus info - we will trust the card's idea
+	 * of where its memory and registers are.
+	 */
+
+	if (nubus_get_func_dir(ndev, &dir) == -1) {
+		pr_err("%s: Unable to get Nubus functional directory for slot %X!\n",
+		       dev->name, ndev->board->slot);
+		return false;
+	}
+
+	/* Get the MAC address */
+	if (nubus_find_rsrc(&dir, NUBUS_RESID_MAC_ADDRESS, &ent) == -1) {
+		pr_info("%s: Couldn't get MAC address!\n", dev->name);
+		return false;
+	}
+
+	nubus_get_rsrc_mem(dev->dev_addr, &ent, 6);
+
+	if (useresources[cardtype] == 1) {
+		nubus_rewinddir(&dir);
+		if (nubus_find_rsrc(&dir, NUBUS_RESID_MINOR_BASEOS,
+				    &ent) == -1) {
+			pr_err("%s: Memory offset resource for slot %X not found!\n",
+			       dev->name, ndev->board->slot);
+			return false;
+		}
+		nubus_get_rsrc_mem(&offset, &ent, 4);
+		dev->mem_start = dev->base_addr + offset;
+		/* yes, this is how the Apple driver does it */
+		dev->base_addr = dev->mem_start + 0x10000;
+		nubus_rewinddir(&dir);
+		if (nubus_find_rsrc(&dir, NUBUS_RESID_MINOR_LENGTH,
+				    &ent) == -1) {
+			pr_info("%s: Memory length resource for slot %X not found, probing\n",
+				dev->name, ndev->board->slot);
+			offset = mac8390_memsize(dev->mem_start);
+		} else {
+			nubus_get_rsrc_mem(&offset, &ent, 4);
+		}
+		dev->mem_end = dev->mem_start + offset;
+	} else {
+		switch (cardtype) {
+		case MAC8390_KINETICS:
+		case MAC8390_DAYNA: /* it's the same */
+			dev->base_addr = (int)(ndev->board->slot_addr +
+					       DAYNA_8390_BASE);
+			dev->mem_start = (int)(ndev->board->slot_addr +
+					       DAYNA_8390_MEM);
+			dev->mem_end = dev->mem_start +
+				       mac8390_memsize(dev->mem_start);
+			break;
+		case MAC8390_INTERLAN:
+			dev->base_addr = (int)(ndev->board->slot_addr +
+					       INTERLAN_8390_BASE);
+			dev->mem_start = (int)(ndev->board->slot_addr +
+					       INTERLAN_8390_MEM);
+			dev->mem_end = dev->mem_start +
+				       mac8390_memsize(dev->mem_start);
+			break;
+		case MAC8390_CABLETRON:
+			dev->base_addr = (int)(ndev->board->slot_addr +
+					       CABLETRON_8390_BASE);
+			dev->mem_start = (int)(ndev->board->slot_addr +
+					       CABLETRON_8390_MEM);
+			/* The base address is unreadable if 0x00
+			 * has been written to the command register
+			 * Reset the chip by writing E8390_NODMA +
+			 *   E8390_PAGE0 + E8390_STOP just to be
+			 *   sure
+			 */
+			i = (void *)dev->base_addr;
+			*i = 0x21;
+			dev->mem_end = dev->mem_start +
+				       mac8390_memsize(dev->mem_start);
+			break;
+
+		default:
+			pr_err("Card type %s is unsupported, sorry\n",
+			       ndev->board->name);
+			return false;
+		}
+	}
+
+	return true;
+}
+
 struct net_device * __init mac8390_probe(int unit)
 {
 	struct net_device *dev;
-	volatile unsigned short *i;
 	struct nubus_dev *ndev = NULL;
 	int err = -ENODEV;
 
-	struct nubus_dir dir;
-	struct nubus_dirent ent;
-	int offset;
 	static unsigned int slots;
 
 	enum mac8390_type cardtype;
@@ -324,111 +422,16 @@ struct net_device * __init mac8390_probe(int unit)
 	while ((ndev = nubus_find_type(NUBUS_CAT_NETWORK, NUBUS_TYPE_ETHERNET,
 				       ndev))) {
 		/* Have we seen it already? */
-		if (slots & (1<<ndev->board->slot))
+		if (slots & (1 << ndev->board->slot))
 			continue;
-		slots |= 1<<ndev->board->slot;
+		slots |= 1 << ndev->board->slot;
 
 		cardtype = mac8390_ident(ndev);
 		if (cardtype == MAC8390_NONE)
 			continue;
 
-		printk_once(KERN_INFO pr_fmt(version));
-
-		dev->irq = SLOT2IRQ(ndev->board->slot);
-		/* This is getting to be a habit */
-		dev->base_addr = (ndev->board->slot_addr |
-				  ((ndev->board->slot & 0xf) << 20));
-
-		/* Get some Nubus info - we will trust the card's idea
-		   of where its memory and registers are. */
-
-		if (nubus_get_func_dir(ndev, &dir) == -1) {
-			pr_err("%s: Unable to get Nubus functional directory for slot %X!\n",
-			       dev->name, ndev->board->slot);
-			continue;
-		}
-
-		/* Get the MAC address */
-		if (nubus_find_rsrc(&dir, NUBUS_RESID_MAC_ADDRESS, &ent) == -1) {
-			pr_info("%s: Couldn't get MAC address!\n", dev->name);
+		if (!mac8390_init(dev, ndev, cardtype))
 			continue;
-		} else {
-			nubus_get_rsrc_mem(dev->dev_addr, &ent, 6);
-		}
-
-		if (useresources[cardtype] == 1) {
-			nubus_rewinddir(&dir);
-			if (nubus_find_rsrc(&dir, NUBUS_RESID_MINOR_BASEOS,
-					    &ent) == -1) {
-				pr_err("%s: Memory offset resource for slot %X not found!\n",
-				       dev->name, ndev->board->slot);
-				continue;
-			}
-			nubus_get_rsrc_mem(&offset, &ent, 4);
-			dev->mem_start = dev->base_addr + offset;
-			/* yes, this is how the Apple driver does it */
-			dev->base_addr = dev->mem_start + 0x10000;
-			nubus_rewinddir(&dir);
-			if (nubus_find_rsrc(&dir, NUBUS_RESID_MINOR_LENGTH,
-					    &ent) == -1) {
-				pr_info("%s: Memory length resource for slot %X not found, probing\n",
-					dev->name, ndev->board->slot);
-				offset = mac8390_memsize(dev->mem_start);
-				} else {
-					nubus_get_rsrc_mem(&offset, &ent, 4);
-				}
-			dev->mem_end = dev->mem_start + offset;
-		} else {
-			switch (cardtype) {
-			case MAC8390_KINETICS:
-			case MAC8390_DAYNA: /* it's the same */
-				dev->base_addr =
-					(int)(ndev->board->slot_addr +
-					      DAYNA_8390_BASE);
-				dev->mem_start =
-					(int)(ndev->board->slot_addr +
-					      DAYNA_8390_MEM);
-				dev->mem_end =
-					dev->mem_start +
-					mac8390_memsize(dev->mem_start);
-				break;
-			case MAC8390_INTERLAN:
-				dev->base_addr =
-					(int)(ndev->board->slot_addr +
-					      INTERLAN_8390_BASE);
-				dev->mem_start =
-					(int)(ndev->board->slot_addr +
-					      INTERLAN_8390_MEM);
-				dev->mem_end =
-					dev->mem_start +
-					mac8390_memsize(dev->mem_start);
-				break;
-			case MAC8390_CABLETRON:
-				dev->base_addr =
-					(int)(ndev->board->slot_addr +
-					      CABLETRON_8390_BASE);
-				dev->mem_start =
-					(int)(ndev->board->slot_addr +
-					      CABLETRON_8390_MEM);
-				/* The base address is unreadable if 0x00
-				 * has been written to the command register
-				 * Reset the chip by writing E8390_NODMA +
-				 *   E8390_PAGE0 + E8390_STOP just to be
-				 *   sure
-				 */
-				i = (void *)dev->base_addr;
-				*i = 0x21;
-				dev->mem_end =
-					dev->mem_start +
-					mac8390_memsize(dev->mem_start);
-				break;
-
-			default:
-				pr_err("Card type %s is unsupported, sorry\n",
-				       ndev->board->name);
-				continue;
-			}
-		}
 
 		/* Do the nasty 8390 stuff */
 		if (!mac8390_initdev(dev, ndev, cardtype))
-- 
1.6.6.rc0.57.gad7a

