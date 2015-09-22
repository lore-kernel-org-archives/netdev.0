From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 25/33] arcnet: arc-rimi: Use arcnet_<I/O> routines
Date: Tue, 22 Sep 2015 11:02:06 +0200
Message-ID: <1442912534-10821-26-git-send-email-m.grzeschik@pengutronix.de>
References: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, joe@perches.com, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:42296 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932703AbbIVJCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 05:02:42 -0400
In-Reply-To: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

Simplify and make consistent the current uses of readb/writeb
by using the newly introduced arcnet_<I/O> equivalents.

o Add new #defines for register offsets
o Remove old #defines that included the ioaddr
o Remove obfuscating macros by expanding them in-place where appropriate

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/arc-rimi.c | 55 ++++++++++++++++++++-----------------------
 1 file changed, 25 insertions(+), 30 deletions(-)

diff --git a/drivers/net/arcnet/arc-rimi.c b/drivers/net/arcnet/arc-rimi.c
index 37406ff..4c35a7e 100644
--- a/drivers/net/arcnet/arc-rimi.c
+++ b/drivers/net/arcnet/arc-rimi.c
@@ -60,23 +60,16 @@ static void arcrimi_copy_from_card(struct net_device *dev, int bufnum,
 #define MIRROR_SIZE	(BUFFER_SIZE * 4)
 
 /* COM 9026 controller chip --> ARCnet register addresses */
-#define _INTMASK	(ioaddr + 0)	/* writable */
-#define _STATUS		(ioaddr + 0)	/* readable */
-#define _COMMAND	(ioaddr + 1)	/* writable, returns random vals on read (?) */
-#define _RESET		(ioaddr + 8)	/* software reset (on read) */
-#define _MEMDATA	(ioaddr + 12)	/* Data port for IO-mapped memory */
-#define _ADDR_HI	(ioaddr + 15)	/* Control registers for said */
-#define _ADDR_LO	(ioaddr + 14)
-#define _CONFIG		(ioaddr + 2)	/* Configuration register */
-
-#undef ASTATUS
-#undef ACOMMAND
-#undef AINTMASK
-
-#define ASTATUS()	readb(_STATUS)
-#define ACOMMAND(cmd)	writeb((cmd), _COMMAND)
-#define AINTMASK(msk)	writeb((msk), _INTMASK)
-#define SETCONF()	writeb(lp->config, _CONFIG)
+#define COM9026_REG_W_INTMASK	0	/* writable */
+#define COM9026_REG_R_STATUS	0	/* readable */
+#define COM9026_REG_W_COMMAND	1	/* writable, returns random vals on read (?) */
+#define COM9026_REG_RW_CONFIG	2	/* Configuration register */
+#define COM9026_REG_R_RESET	8	/* software reset (on read) */
+#define COM9026_REG_RW_MEMDATA	12	/* Data port for IO-mapped memory */
+#define COM9026_REG_W_ADDR_LO	14	/* Control registers for said */
+#define COM9026_REG_W_ADDR_HI	15
+
+#define COM9026_REG_R_STATION	1	/* Station ID */
 
 /* We cannot probe for a RIM I card; one reason is I don't know how to reset
  * them.  In fact, we can't even get their node ID automatically.  So, we
@@ -124,7 +117,7 @@ static int check_mirror(unsigned long addr, size_t size)
 
 	p = ioremap(addr, size);
 	if (p) {
-		if (readb(p) == TESTvalue)
+		if (arcnet_readb(p, COM9026_REG_R_STATUS) == TESTvalue)
 			res = 1;
 		else
 			res = 0;
@@ -162,8 +155,9 @@ static int __init arcrimi_found(struct net_device *dev)
 	}
 
 	shmem = dev->mem_start;
-	writeb(TESTvalue, p);
-	writeb(dev->dev_addr[0], p + 1);	/* actually the node ID */
+	arcnet_writeb(TESTvalue, p, COM9026_REG_W_INTMASK);
+	arcnet_writeb(TESTvalue, p, COM9026_REG_W_COMMAND);
+					/* actually the station/node ID */
 
 	/* find the real shared memory start/end points, including mirrors */
 
@@ -172,7 +166,7 @@ static int __init arcrimi_found(struct net_device *dev)
 	 * 2k (or there are no mirrors at all) but on some, it's 4k.
 	 */
 	mirror_size = MIRROR_SIZE;
-	if (readb(p) == TESTvalue &&
+	if (arcnet_readb(p, COM9026_REG_R_STATUS) == TESTvalue &&
 	    check_mirror(shmem - MIRROR_SIZE, MIRROR_SIZE) == 0 &&
 	    check_mirror(shmem - 2 * MIRROR_SIZE, MIRROR_SIZE) == 1)
 		mirror_size = 2 * MIRROR_SIZE;
@@ -224,7 +218,7 @@ static int __init arcrimi_found(struct net_device *dev)
 	}
 
 	/* get and check the station ID from offset 1 in shmem */
-	dev->dev_addr[0] = readb(lp->mem_start + 1);
+	dev->dev_addr[0] = arcnet_readb(lp->mem_start, COM9026_REG_R_STATION);
 
 	arc_printk(D_NORMAL, dev, "ARCnet RIM I: station %02Xh found at IRQ %d, ShMem %lXh (%ld*%d bytes)\n",
 		   dev->dev_addr[0],
@@ -260,17 +254,18 @@ static int arcrimi_reset(struct net_device *dev, int really_reset)
 	void __iomem *ioaddr = lp->mem_start + 0x800;
 
 	arc_printk(D_INIT, dev, "Resetting %s (status=%02Xh)\n",
-		   dev->name, ASTATUS());
+		   dev->name, arcnet_readb(ioaddr, COM9026_REG_R_STATUS));
 
 	if (really_reset) {
-		writeb(TESTvalue, ioaddr - 0x800);	/* fake reset */
+		arcnet_writeb(TESTvalue, ioaddr, -0x800);	/* fake reset */
 		return 0;
 	}
-	ACOMMAND(CFLAGScmd | RESETclear);	/* clear flags & end reset */
-	ACOMMAND(CFLAGScmd | CONFIGclear);
+	/* clear flags & end reset */
+	arcnet_writeb(CFLAGScmd | RESETclear, ioaddr, COM9026_REG_W_COMMAND);
+	arcnet_writeb(CFLAGScmd | CONFIGclear, ioaddr, COM9026_REG_W_COMMAND);
 
 	/* enable extended (512-byte) packets */
-	ACOMMAND(CONFIGcmd | EXTconf);
+	arcnet_writeb(CONFIGcmd | EXTconf, ioaddr, COM9026_REG_W_COMMAND);
 
 	/* done!  return success. */
 	return 0;
@@ -281,7 +276,7 @@ static void arcrimi_setmask(struct net_device *dev, int mask)
 	struct arcnet_local *lp = netdev_priv(dev);
 	void __iomem *ioaddr = lp->mem_start + 0x800;
 
-	AINTMASK(mask);
+	arcnet_writeb(mask, ioaddr, COM9026_REG_W_INTMASK);
 }
 
 static int arcrimi_status(struct net_device *dev)
@@ -289,7 +284,7 @@ static int arcrimi_status(struct net_device *dev)
 	struct arcnet_local *lp = netdev_priv(dev);
 	void __iomem *ioaddr = lp->mem_start + 0x800;
 
-	return ASTATUS();
+	return arcnet_readb(ioaddr, COM9026_REG_R_STATUS);
 }
 
 static void arcrimi_command(struct net_device *dev, int cmd)
@@ -297,7 +292,7 @@ static void arcrimi_command(struct net_device *dev, int cmd)
 	struct arcnet_local *lp = netdev_priv(dev);
 	void __iomem *ioaddr = lp->mem_start + 0x800;
 
-	ACOMMAND(cmd);
+	arcnet_writeb(cmd, ioaddr, COM9026_REG_W_COMMAND);
 }
 
 static void arcrimi_copy_to_card(struct net_device *dev, int bufnum, int offset,
-- 
2.5.1
