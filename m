From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 08/21] ARCNET: com90io: remove unneeded macros
Date: Fri, 24 Apr 2015 19:20:42 +0200
Message-ID: <1429896055-31680-9-git-send-email-m.grzeschik@pengutronix.de>
References: <1429896055-31680-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429896055-31680-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The simple macros ARCRESET, ACOMMAND, ASTATUS, AINTMASK are unnecessary
indirections to the use of registers. This patch removes them and
improves the readability of the code.

Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/com90io.c | 36 +++++++++++++-----------------------
 1 file changed, 13 insertions(+), 23 deletions(-)

diff --git a/drivers/net/arcnet/com90io.c b/drivers/net/arcnet/com90io.c
index b1279af..6bc6366 100644
--- a/drivers/net/arcnet/com90io.c
+++ b/drivers/net/arcnet/com90io.c
@@ -69,16 +69,6 @@ static void com90io_copy_from_card(struct net_device *dev, int bufnum, int offse
 #define _ADDR_LO  (ioaddr+14)
 #define _CONFIG  (ioaddr+2)	/* Configuration register */
 
-#undef ASTATUS
-#undef ACOMMAND
-#undef AINTMASK
-
-#define ASTATUS()	inb(_STATUS)
-#define ACOMMAND(cmd) outb((cmd),_COMMAND)
-#define AINTMASK(msk)	outb((msk),_INTMASK)
-#define SETCONF() 	outb((lp->config),_CONFIG)
-
-
 /****************************************************************************
  *                                                                          *
  * IO-mapped operation routines                                             *
@@ -164,14 +154,14 @@ static int __init com90io_probe(struct net_device *dev)
 		       ioaddr, ioaddr + ARCNET_TOTAL_SIZE - 1);
 		return -ENXIO;
 	}
-	if (ASTATUS() == 0xFF) {
+	if (inb(_STATUS) == 0xFF) {
 		BUGMSG(D_INIT_REASONS, "IO address %x empty\n", ioaddr);
 		goto err_out;
 	}
 	inb(_RESET);
 	mdelay(RESETtime);
 
-	status = ASTATUS();
+	status = inb(_STATUS);
 
 	if ((status & 0x9D) != (NORXflag | RECONflag | TXFREEflag | RESETflag)) {
 		BUGMSG(D_INIT_REASONS, "Status invalid (%Xh).\n", status);
@@ -179,11 +169,11 @@ static int __init com90io_probe(struct net_device *dev)
 	}
 	BUGMSG(D_INIT_REASONS, "Status after reset: %X\n", status);
 
-	ACOMMAND(CFLAGScmd | RESETclear | CONFIGclear);
+	outb(CFLAGScmd | RESETclear | CONFIGclear, _COMMAND);
 
 	BUGMSG(D_INIT_REASONS, "Status after reset acknowledged: %X\n", status);
 
-	status = ASTATUS();
+	status = inb(_STATUS);
 
 	if (status & RESETflag) {
 		BUGMSG(D_INIT_REASONS, "Eternal reset (status=%Xh)\n", status);
@@ -259,7 +249,7 @@ static int __init com90io_found(struct net_device *dev)
 	lp->hw.copy_from_card = com90io_copy_from_card;
 
 	lp->config = (0x16 | IOMAPflag) & ~ENABLE16flag;
-	SETCONF();
+	outb(lp->config, _CONFIG);
 
 	/* get and check the station ID from offset 1 in shmem */
 
@@ -293,7 +283,7 @@ static int com90io_reset(struct net_device *dev, int really_reset)
 	struct arcnet_local *lp = netdev_priv(dev);
 	short ioaddr = dev->base_addr;
 
-	BUGMSG(D_INIT, "Resetting %s (status=%02Xh)\n", dev->name, ASTATUS());
+	BUGMSG(D_INIT, "Resetting %s (status=%02Xh)\n", dev->name, inb(_STATUS));
 
 	if (really_reset) {
 		/* reset the card */
@@ -302,10 +292,10 @@ static int com90io_reset(struct net_device *dev, int really_reset)
 	}
 	/* Set the thing to IO-mapped, 8-bit  mode */
 	lp->config = (0x1C | IOMAPflag) & ~ENABLE16flag;
-	SETCONF();
+	outb(lp->config, _CONFIG);
 
-	ACOMMAND(CFLAGScmd | RESETclear);	/* clear flags & end reset */
-	ACOMMAND(CFLAGScmd | CONFIGclear);
+	outb(CFLAGScmd | RESETclear, _COMMAND); /* clear flags & end reset */
+	outb(CFLAGScmd | CONFIGclear, _COMMAND);
 
 	/* verify that the ARCnet signature byte is present */
 	if (get_buffer_byte(dev, 0) != TESTvalue) {
@@ -313,7 +303,7 @@ static int com90io_reset(struct net_device *dev, int really_reset)
 		return 1;
 	}
 	/* enable extended (512-byte) packets */
-	ACOMMAND(CONFIGcmd | EXTconf);
+	outb(CONFIGcmd | EXTconf, _COMMAND);
 
 	/* done!  return success. */
 	return 0;
@@ -324,7 +314,7 @@ static void com90io_command(struct net_device *dev, int cmd)
 {
 	short ioaddr = dev->base_addr;
 
-	ACOMMAND(cmd);
+	outb(cmd, _COMMAND);
 }
 
 
@@ -332,7 +322,7 @@ static int com90io_status(struct net_device *dev)
 {
 	short ioaddr = dev->base_addr;
 
-	return ASTATUS();
+	return inb(_STATUS);
 }
 
 
@@ -340,7 +330,7 @@ static void com90io_setmask(struct net_device *dev, int mask)
 {
 	short ioaddr = dev->base_addr;
 
-	AINTMASK(mask);
+	outb(mask, _INTMASK);
 }
 
 static void com90io_copy_to_card(struct net_device *dev, int bufnum, int offset,
-- 
2.1.4
