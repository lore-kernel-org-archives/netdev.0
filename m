From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 09/21] ARCNET: com90xx: remove unneeded macros
Date: Fri, 24 Apr 2015 19:20:43 +0200
Message-ID: <1429896055-31680-10-git-send-email-m.grzeschik@pengutronix.de>
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
 drivers/net/arcnet/com90xx.c | 35 +++++++++++++----------------------
 1 file changed, 13 insertions(+), 22 deletions(-)

diff --git a/drivers/net/arcnet/com90xx.c b/drivers/net/arcnet/com90xx.c
index 03bd71c..2b99a04 100644
--- a/drivers/net/arcnet/com90xx.c
+++ b/drivers/net/arcnet/com90xx.c
@@ -89,15 +89,6 @@ static int numcards;
 #define _ADDR_HI (ioaddr+15)	/* Control registers for said */
 #define _ADDR_LO (ioaddr+14)
 
-#undef ASTATUS
-#undef ACOMMAND
-#undef AINTMASK
-
-#define ASTATUS()	inb(_STATUS)
-#define ACOMMAND(cmd) 	outb((cmd),_COMMAND)
-#define AINTMASK(msk)	outb((msk),_INTMASK)
-
-
 static int com90xx_skip_probe __initdata = 0;
 
 /* Module parameters */
@@ -175,7 +166,7 @@ static void __init com90xx_probe(void)
 			*port-- = ports[--numports];
 			continue;
 		}
-		if (ASTATUS() == 0xFF) {
+		if (inb(_STATUS) == 0xFF) {
 			BUGMSG2(D_INIT_REASONS, "(empty)\n");
 			BUGMSG2(D_INIT_REASONS, "S1: ");
 			BUGLVL(D_INIT_REASONS) numprint = 0;
@@ -317,7 +308,7 @@ static void __init com90xx_probe(void)
 		BUGMSG2(D_INIT, "%Xh ", *port);
 
 		ioaddr = *port;
-		status = ASTATUS();
+		status = inb(_STATUS);
 
 		if ((status & 0x9D)
 		    != (NORXflag | RECONflag | TXFREEflag | RESETflag)) {
@@ -328,8 +319,8 @@ static void __init com90xx_probe(void)
 			*port-- = ports[--numports];
 			continue;
 		}
-		ACOMMAND(CFLAGScmd | RESETclear | CONFIGclear);
-		status = ASTATUS();
+		outb(CFLAGScmd | RESETclear | CONFIGclear, _COMMAND);
+		status = inb(_STATUS);
 		if (status & RESETflag) {
 			BUGMSG2(D_INIT_REASONS, " (eternal reset, status=%Xh)\n",
 				status);
@@ -348,9 +339,9 @@ static void __init com90xx_probe(void)
 			 * we tell it to start receiving.
 			 */
 			airqmask = probe_irq_on();
-			AINTMASK(NORXflag);
+			outb(NORXflag, _INTMASK);
 			udelay(1);
-			AINTMASK(0);
+			outb(0, _INTMASK);
 			airq = probe_irq_off(airqmask);
 
 			if (airq <= 0) {
@@ -557,7 +548,7 @@ static void com90xx_command(struct net_device *dev, int cmd)
 {
 	short ioaddr = dev->base_addr;
 
-	ACOMMAND(cmd);
+	outb(cmd, _COMMAND);
 }
 
 
@@ -565,7 +556,7 @@ static int com90xx_status(struct net_device *dev)
 {
 	short ioaddr = dev->base_addr;
 
-	return ASTATUS();
+	return inb(_STATUS);
 }
 
 
@@ -573,7 +564,7 @@ static void com90xx_setmask(struct net_device *dev, int mask)
 {
 	short ioaddr = dev->base_addr;
 
-	AINTMASK(mask);
+	outb(mask, _INTMASK);
 }
 
 
@@ -590,15 +581,15 @@ static int com90xx_reset(struct net_device *dev, int really_reset)
 	struct arcnet_local *lp = netdev_priv(dev);
 	short ioaddr = dev->base_addr;
 
-	BUGMSG(D_INIT, "Resetting (status=%02Xh)\n", ASTATUS());
+	BUGMSG(D_INIT, "Resetting (status=%02Xh)\n", inb(_STATUS));
 
 	if (really_reset) {
 		/* reset the card */
 		inb(_RESET);
 		mdelay(RESETtime);
 	}
-	ACOMMAND(CFLAGScmd | RESETclear);	/* clear flags & end reset */
-	ACOMMAND(CFLAGScmd | CONFIGclear);
+	outb(CFLAGScmd | RESETclear, _COMMAND);	/* clear flags & end reset */
+	outb(CFLAGScmd | CONFIGclear, _COMMAND);
 
 	/* don't do this until we verify that it doesn't hurt older cards! */
 	/* outb(inb(_CONFIG) | ENABLE16flag, _CONFIG); */
@@ -610,7 +601,7 @@ static int com90xx_reset(struct net_device *dev, int really_reset)
 		return 1;
 	}
 	/* enable extended (512-byte) packets */
-	ACOMMAND(CONFIGcmd | EXTconf);
+	outb(CONFIGcmd | EXTconf, _COMMAND);
 
 	/* clean out all the memory to make debugging make more sense :) */
 	BUGLVL(D_DURING)
-- 
2.1.4
