From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 23/33] arcnet: com90xx: Use arcnet_<I/O> routines
Date: Tue, 22 Sep 2015 11:02:04 +0200
Message-ID: <1442912534-10821-24-git-send-email-m.grzeschik@pengutronix.de>
References: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, joe@perches.com, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:37814 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932687AbbIVJCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 05:02:42 -0400
In-Reply-To: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

Simplify and make consistent the current uses of inb/outb
by using the newly introduced arcnet_<I/O> equivalents.

o Add new #defines for register offsets
o Remove old #defines that included the ioaddr
o Remove obfuscating macros by expanding them in-place where appropriate

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/com90xx.c | 67 ++++++++++++++++++++++----------------------
 1 file changed, 33 insertions(+), 34 deletions(-)

diff --git a/drivers/net/arcnet/com90xx.c b/drivers/net/arcnet/com90xx.c
index b672795..f1cfeb0 100644
--- a/drivers/net/arcnet/com90xx.c
+++ b/drivers/net/arcnet/com90xx.c
@@ -79,22 +79,14 @@ static int numcards;
 #define MIRROR_SIZE (BUFFER_SIZE * 4)
 
 /* COM 9026 controller chip --> ARCnet register addresses */
-#define _INTMASK	(ioaddr + 0)	/* writable */
-#define _STATUS		(ioaddr + 0)	/* readable */
-#define _COMMAND	(ioaddr + 1)	/* writable, returns random vals on read (?) */
-#define _CONFIG		(ioaddr + 2)	/* Configuration register */
-#define _RESET		(ioaddr + 8)	/* software reset (on read) */
-#define _MEMDATA	(ioaddr + 12)	/* Data port for IO-mapped memory */
-#define _ADDR_HI	(ioaddr + 15)	/* Control registers for said */
-#define _ADDR_LO	(ioaddr + 14)
-
-#undef ASTATUS
-#undef ACOMMAND
-#undef AINTMASK
-
-#define ASTATUS()	inb(_STATUS)
-#define ACOMMAND(cmd)	outb((cmd), _COMMAND)
-#define AINTMASK(msk)	outb((msk), _INTMASK)
+#define COM9026_REG_W_INTMASK	0	/* writable */
+#define COM9026_REG_R_STATUS	0	/* readable */
+#define COM9026_REG_W_COMMAND	1	/* writable, returns random vals on read (?) */
+#define COM9026_REG_RW_CONFIG	2	/* Configuration register */
+#define COM9026_REG_R_RESET	8	/* software reset (on read) */
+#define COM9026_REG_RW_MEMDATA	12	/* Data port for IO-mapped memory */
+#define COM9026_REG_W_ADDR_LO	14	/* Control registers for said */
+#define COM9026_REG_W_ADDR_HI	15
 
 static int com90xx_skip_probe __initdata = 0;
 
@@ -175,7 +167,7 @@ static void __init com90xx_probe(void)
 			*port-- = ports[--numports];
 			continue;
 		}
-		if (ASTATUS() == 0xFF) {
+		if (arcnet_inb(ioaddr, COM9026_REG_R_STATUS) == 0xFF) {
 			arc_cont(D_INIT_REASONS, "(empty)\n");
 			arc_cont(D_INIT_REASONS, "S1: ");
 			if (BUGLVL(D_INIT_REASONS))
@@ -184,7 +176,8 @@ static void __init com90xx_probe(void)
 			*port-- = ports[--numports];
 			continue;
 		}
-		inb(_RESET);	/* begin resetting card */
+		/* begin resetting card */
+		arcnet_inb(ioaddr, COM9026_REG_R_RESET);
 
 		arc_cont(D_INIT_REASONS, "\n");
 		arc_cont(D_INIT_REASONS, "S1: ");
@@ -324,7 +317,7 @@ static void __init com90xx_probe(void)
 		arc_cont(D_INIT, "%Xh ", *port);
 
 		ioaddr = *port;
-		status = ASTATUS();
+		status = arcnet_inb(ioaddr, COM9026_REG_R_STATUS);
 
 		if ((status & 0x9D)
 		    != (NORXflag | RECONflag | TXFREEflag | RESETflag)) {
@@ -336,8 +329,9 @@ static void __init com90xx_probe(void)
 			*port-- = ports[--numports];
 			continue;
 		}
-		ACOMMAND(CFLAGScmd | RESETclear | CONFIGclear);
-		status = ASTATUS();
+		arcnet_outb(CFLAGScmd | RESETclear | CONFIGclear,
+			    ioaddr, COM9026_REG_W_COMMAND);
+		status = arcnet_inb(ioaddr, COM9026_REG_R_STATUS);
 		if (status & RESETflag) {
 			arc_cont(D_INIT_REASONS, " (eternal reset, status=%Xh)\n",
 				 status);
@@ -357,9 +351,9 @@ static void __init com90xx_probe(void)
 			 * we tell it to start receiving.
 			 */
 			airqmask = probe_irq_on();
-			AINTMASK(NORXflag);
+			arcnet_outb(NORXflag, ioaddr, COM9026_REG_W_INTMASK);
 			udelay(1);
-			AINTMASK(0);
+			arcnet_outb(0, ioaddr, COM9026_REG_W_INTMASK);
 			airq = probe_irq_off(airqmask);
 
 			if (airq <= 0) {
@@ -386,14 +380,14 @@ static void __init com90xx_probe(void)
 		 */
 #ifdef FAST_PROBE
 		if (numports > 1 || numshmems > 1) {
-			inb(_RESET);
+			arcnet_inb(ioaddr, COM9026_REG_R_RESET);
 			mdelay(RESETtime);
 		} else {
 			/* just one shmem and port, assume they match */
 			writeb(TESTvalue, iomem[0]);
 		}
 #else
-		inb(_RESET);
+		arcnet_inb(ioaddr, COM9026_REG_R_RESET);
 		mdelay(RESETtime);
 #endif
 
@@ -574,21 +568,21 @@ static void com90xx_command(struct net_device *dev, int cmd)
 {
 	short ioaddr = dev->base_addr;
 
-	ACOMMAND(cmd);
+	arcnet_outb(cmd, ioaddr, COM9026_REG_W_COMMAND);
 }
 
 static int com90xx_status(struct net_device *dev)
 {
 	short ioaddr = dev->base_addr;
 
-	return ASTATUS();
+	return arcnet_inb(ioaddr, COM9026_REG_R_STATUS);
 }
 
 static void com90xx_setmask(struct net_device *dev, int mask)
 {
 	short ioaddr = dev->base_addr;
 
-	AINTMASK(mask);
+	arcnet_outb(mask, ioaddr, COM9026_REG_W_INTMASK);
 }
 
 /* Do a hardware reset on the card, and set up necessary registers.
@@ -603,18 +597,23 @@ static int com90xx_reset(struct net_device *dev, int really_reset)
 	struct arcnet_local *lp = netdev_priv(dev);
 	short ioaddr = dev->base_addr;
 
-	arc_printk(D_INIT, dev, "Resetting (status=%02Xh)\n", ASTATUS());
+	arc_printk(D_INIT, dev, "Resetting (status=%02Xh)\n",
+		   arcnet_inb(ioaddr, COM9026_REG_R_STATUS));
 
 	if (really_reset) {
 		/* reset the card */
-		inb(_RESET);
+		arcnet_inb(ioaddr, COM9026_REG_R_RESET);
 		mdelay(RESETtime);
 	}
-	ACOMMAND(CFLAGScmd | RESETclear);	/* clear flags & end reset */
-	ACOMMAND(CFLAGScmd | CONFIGclear);
+	/* clear flags & end reset */
+	arcnet_outb(CFLAGScmd | RESETclear, ioaddr, COM9026_REG_W_COMMAND);
+	arcnet_outb(CFLAGScmd | CONFIGclear, ioaddr, COM9026_REG_W_COMMAND);
 
+#if 0
 	/* don't do this until we verify that it doesn't hurt older cards! */
-	/* outb(inb(_CONFIG) | ENABLE16flag, _CONFIG); */
+	arcnet_outb(arcnet_inb(ioaddr, COM9026_REG_RW_CONFIG) | ENABLE16flag,
+		    ioaddr, COM9026_REG_RW_CONFIG);
+#endif
 
 	/* verify that the ARCnet signature byte is present */
 	if (readb(lp->mem_start) != TESTvalue) {
@@ -623,7 +622,7 @@ static int com90xx_reset(struct net_device *dev, int really_reset)
 		return 1;
 	}
 	/* enable extended (512-byte) packets */
-	ACOMMAND(CONFIGcmd | EXTconf);
+	arcnet_outb(CONFIGcmd | EXTconf, ioaddr, COM9026_REG_W_COMMAND);
 
 	/* clean out all the memory to make debugging make more sense :) */
 	if (BUGLVL(D_DURING))
-- 
2.5.1
