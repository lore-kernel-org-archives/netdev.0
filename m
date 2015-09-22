From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 22/33] arcnet: com90io: Use arcnet_<I/O> routines
Date: Tue, 22 Sep 2015 11:02:03 +0200
Message-ID: <1442912534-10821-23-git-send-email-m.grzeschik@pengutronix.de>
References: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, joe@perches.com, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:37173 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932647AbbIVJCm (ORCPT
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
 drivers/net/arcnet/com90io.c | 101 ++++++++++++++++++++-----------------------
 1 file changed, 48 insertions(+), 53 deletions(-)

diff --git a/drivers/net/arcnet/com90io.c b/drivers/net/arcnet/com90io.c
index ce15d191..7e084f1 100644
--- a/drivers/net/arcnet/com90io.c
+++ b/drivers/net/arcnet/com90io.c
@@ -59,23 +59,14 @@ static void com90io_copy_from_card(struct net_device *dev, int bufnum,
 #define ARCNET_TOTAL_SIZE 16
 
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
-#define ASTATUS()	inb(_STATUS)
-#define ACOMMAND(cmd)	outb((cmd), _COMMAND)
-#define AINTMASK(msk)	outb((msk), _INTMASK)
-#define SETCONF()	outb((lp->config), _CONFIG)
+#define COM9026_REG_W_INTMASK	0	/* writable */
+#define COM9026_REG_R_STATUS	0	/* readable */
+#define COM9026_REG_W_COMMAND	1	/* writable, returns random vals on read (?) */
+#define COM9026_REG_RW_CONFIG	2	/* Configuration register */
+#define COM9026_REG_R_RESET	8	/* software reset (on read) */
+#define COM9026_REG_RW_MEMDATA	12	/* Data port for IO-mapped memory */
+#define COM9026_REG_W_ADDR_LO	14	/* Control registers for said */
+#define COM9026_REG_W_ADDR_HI	15
 
 /****************************************************************************
  *                                                                          *
@@ -90,10 +81,10 @@ static u_char get_buffer_byte(struct net_device *dev, unsigned offset)
 {
 	int ioaddr = dev->base_addr;
 
-	outb(offset >> 8, _ADDR_HI);
-	outb(offset & 0xff, _ADDR_LO);
+	arcnet_outb(offset >> 8, ioaddr, COM9026_REG_W_ADDR_HI);
+	arcnet_outb(offset & 0xff, ioaddr, COM9026_REG_W_ADDR_LO);
 
-	return inb(_MEMDATA);
+	return arcnet_inb(ioaddr, COM9026_REG_RW_MEMDATA);
 }
 
 #ifdef ONE_AT_A_TIME_TX
@@ -102,10 +93,10 @@ static void put_buffer_byte(struct net_device *dev, unsigned offset,
 {
 	int ioaddr = dev->base_addr;
 
-	outb(offset >> 8, _ADDR_HI);
-	outb(offset & 0xff, _ADDR_LO);
+	arcnet_outb(offset >> 8, ioaddr, COM9026_REG_W_ADDR_HI);
+	arcnet_outb(offset & 0xff, ioaddr, COM9026_REG_W_ADDR_LO);
 
-	outb(datum, _MEMDATA);
+	arcnet_outb(datum, ioaddr, COM9026_REG_RW_MEMDATA);
 }
 
 #endif
@@ -115,14 +106,14 @@ static void get_whole_buffer(struct net_device *dev, unsigned offset,
 {
 	int ioaddr = dev->base_addr;
 
-	outb((offset >> 8) | AUTOINCflag, _ADDR_HI);
-	outb(offset & 0xff, _ADDR_LO);
+	arcnet_outb((offset >> 8) | AUTOINCflag, ioaddr, COM9026_REG_W_ADDR_HI);
+	arcnet_outb(offset & 0xff, ioaddr, COM9026_REG_W_ADDR_LO);
 
 	while (length--)
 #ifdef ONE_AT_A_TIME_RX
 		*(dest++) = get_buffer_byte(dev, offset++);
 #else
-		*(dest++) = inb(_MEMDATA);
+		*(dest++) = arcnet_inb(ioaddr, COM9026_REG_RW_MEMDATA);
 #endif
 }
 
@@ -131,14 +122,14 @@ static void put_whole_buffer(struct net_device *dev, unsigned offset,
 {
 	int ioaddr = dev->base_addr;
 
-	outb((offset >> 8) | AUTOINCflag, _ADDR_HI);
-	outb(offset & 0xff, _ADDR_LO);
+	arcnet_outb((offset >> 8) | AUTOINCflag, ioaddr, COM9026_REG_W_ADDR_HI);
+	arcnet_outb(offset & 0xff, ioaddr,COM9026_REG_W_ADDR_LO);
 
 	while (length--)
 #ifdef ONE_AT_A_TIME_TX
 		put_buffer_byte(dev, offset++, *(dest++));
 #else
-		outb(*(dest++), _MEMDATA);
+		arcnet_outb(*(dest++), ioaddr, COM9026_REG_RW_MEMDATA);
 #endif
 }
 
@@ -164,15 +155,15 @@ static int __init com90io_probe(struct net_device *dev)
 			   ioaddr, ioaddr + ARCNET_TOTAL_SIZE - 1);
 		return -ENXIO;
 	}
-	if (ASTATUS() == 0xFF) {
+	if (arcnet_inb(ioaddr, COM9026_REG_R_STATUS) == 0xFF) {
 		arc_printk(D_INIT_REASONS, dev, "IO address %x empty\n",
 			   ioaddr);
 		goto err_out;
 	}
-	inb(_RESET);
+	arcnet_inb(ioaddr, COM9026_REG_R_RESET);
 	mdelay(RESETtime);
 
-	status = ASTATUS();
+	status = arcnet_inb(ioaddr, COM9026_REG_R_STATUS);
 
 	if ((status & 0x9D) != (NORXflag | RECONflag | TXFREEflag | RESETflag)) {
 		arc_printk(D_INIT_REASONS, dev, "Status invalid (%Xh)\n",
@@ -181,26 +172,28 @@ static int __init com90io_probe(struct net_device *dev)
 	}
 	arc_printk(D_INIT_REASONS, dev, "Status after reset: %X\n", status);
 
-	ACOMMAND(CFLAGScmd | RESETclear | CONFIGclear);
+	arcnet_outb(CFLAGScmd | RESETclear | CONFIGclear,
+		    ioaddr, COM9026_REG_W_COMMAND);
 
 	arc_printk(D_INIT_REASONS, dev, "Status after reset acknowledged: %X\n",
 		   status);
 
-	status = ASTATUS();
+	status = arcnet_inb(ioaddr, COM9026_REG_R_STATUS);
 
 	if (status & RESETflag) {
 		arc_printk(D_INIT_REASONS, dev, "Eternal reset (status=%Xh)\n",
 			   status);
 		goto err_out;
 	}
-	outb((0x16 | IOMAPflag) & ~ENABLE16flag, _CONFIG);
+	arcnet_outb((0x16 | IOMAPflag) & ~ENABLE16flag,
+		    ioaddr, COM9026_REG_RW_CONFIG);
 
 	/* Read first loc'n of memory */
 
-	outb(AUTOINCflag, _ADDR_HI);
-	outb(0, _ADDR_LO);
+	arcnet_outb(AUTOINCflag, ioaddr, COM9026_REG_W_ADDR_HI);
+	arcnet_outb(0, ioaddr,  COM9026_REG_W_ADDR_LO);
 
-	status = inb(_MEMDATA);
+	status = arcnet_inb(ioaddr, COM9026_REG_RW_MEMDATA);
 	if (status != 0xd1) {
 		arc_printk(D_INIT_REASONS, dev, "Signature byte not found (%Xh instead).\n",
 			   status);
@@ -213,9 +206,9 @@ static int __init com90io_probe(struct net_device *dev)
 		 */
 
 		airqmask = probe_irq_on();
-		outb(NORXflag, _INTMASK);
+		arcnet_outb(NORXflag, ioaddr, COM9026_REG_W_INTMASK);
 		udelay(1);
-		outb(0, _INTMASK);
+		arcnet_outb(0, ioaddr, COM9026_REG_W_INTMASK);
 		dev->irq = probe_irq_off(airqmask);
 
 		if ((int)dev->irq <= 0) {
@@ -264,7 +257,7 @@ static int __init com90io_found(struct net_device *dev)
 	lp->hw.copy_from_card = com90io_copy_from_card;
 
 	lp->config = (0x16 | IOMAPflag) & ~ENABLE16flag;
-	SETCONF();
+	arcnet_outb(lp->config, ioaddr, COM9026_REG_RW_CONFIG);
 
 	/* get and check the station ID from offset 1 in shmem */
 
@@ -272,7 +265,8 @@ static int __init com90io_found(struct net_device *dev)
 
 	err = register_netdev(dev);
 	if (err) {
-		outb((inb(_CONFIG) & ~IOMAPflag), _CONFIG);
+		arcnet_outb(arcnet_inb(ioaddr, COM9026_REG_RW_CONFIG) & ~IOMAPflag,
+			    ioaddr, COM9026_REG_RW_CONFIG);
 		free_irq(dev->irq, dev);
 		release_region(dev->base_addr, ARCNET_TOTAL_SIZE);
 		return err;
@@ -297,19 +291,20 @@ static int com90io_reset(struct net_device *dev, int really_reset)
 	short ioaddr = dev->base_addr;
 
 	arc_printk(D_INIT, dev, "Resetting %s (status=%02Xh)\n",
-		   dev->name, ASTATUS());
+		   dev->name, arcnet_inb(ioaddr, COM9026_REG_R_STATUS));
 
 	if (really_reset) {
 		/* reset the card */
-		inb(_RESET);
+		arcnet_inb(ioaddr, COM9026_REG_R_RESET);
 		mdelay(RESETtime);
 	}
 	/* Set the thing to IO-mapped, 8-bit  mode */
 	lp->config = (0x1C | IOMAPflag) & ~ENABLE16flag;
-	SETCONF();
+	arcnet_outb(lp->config, ioaddr, COM9026_REG_RW_CONFIG);
 
-	ACOMMAND(CFLAGScmd | RESETclear);	/* clear flags & end reset */
-	ACOMMAND(CFLAGScmd | CONFIGclear);
+	arcnet_outb(CFLAGScmd | RESETclear, ioaddr, COM9026_REG_W_COMMAND);
+					/* clear flags & end reset */
+	arcnet_outb(CFLAGScmd | CONFIGclear, ioaddr, COM9026_REG_W_COMMAND);
 
 	/* verify that the ARCnet signature byte is present */
 	if (get_buffer_byte(dev, 0) != TESTvalue) {
@@ -317,8 +312,7 @@ static int com90io_reset(struct net_device *dev, int really_reset)
 		return 1;
 	}
 	/* enable extended (512-byte) packets */
-	ACOMMAND(CONFIGcmd | EXTconf);
-
+	arcnet_outb(CONFIGcmd | EXTconf, ioaddr, COM9026_REG_W_COMMAND);
 	/* done!  return success. */
 	return 0;
 }
@@ -327,21 +321,21 @@ static void com90io_command(struct net_device *dev, int cmd)
 {
 	short ioaddr = dev->base_addr;
 
-	ACOMMAND(cmd);
+	arcnet_outb(cmd, ioaddr, COM9026_REG_W_COMMAND);
 }
 
 static int com90io_status(struct net_device *dev)
 {
 	short ioaddr = dev->base_addr;
 
-	return ASTATUS();
+	return arcnet_inb(ioaddr, COM9026_REG_R_STATUS);
 }
 
 static void com90io_setmask(struct net_device *dev, int mask)
 {
 	short ioaddr = dev->base_addr;
 
-	AINTMASK(mask);
+	arcnet_outb(mask, ioaddr, COM9026_REG_W_INTMASK);
 }
 
 static void com90io_copy_to_card(struct net_device *dev, int bufnum,
@@ -427,7 +421,8 @@ static void __exit com90io_exit(void)
 	/* In case the old driver is loaded later,
 	 * set the thing back to MMAP mode
 	 */
-	outb((inb(_CONFIG) & ~IOMAPflag), _CONFIG);
+	arcnet_outb(arcnet_inb(ioaddr, COM9026_REG_RW_CONFIG) & ~IOMAPflag,
+		    ioaddr, COM9026_REG_RW_CONFIG);
 
 	free_irq(dev->irq, dev);
 	release_region(dev->base_addr, ARCNET_TOTAL_SIZE);
-- 
2.5.1
