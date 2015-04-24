From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 12/21] ARCNET: com90io: fix ioaddr prefixes
Date: Fri, 24 Apr 2015 19:20:46 +0200
Message-ID: <1429896055-31680-13-git-send-email-m.grzeschik@pengutronix.de>
References: <1429896055-31680-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429896055-31680-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch removes the use of the variable ioaddr in the macros
and uses it directly in the calling functions. This improves
the readability of the code and changes the macros to be used as
offsets.

Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/com90io.c | 86 ++++++++++++++++++++++----------------------
 1 file changed, 43 insertions(+), 43 deletions(-)

diff --git a/drivers/net/arcnet/com90io.c b/drivers/net/arcnet/com90io.c
index 6bc6366..df7314d 100644
--- a/drivers/net/arcnet/com90io.c
+++ b/drivers/net/arcnet/com90io.c
@@ -60,14 +60,14 @@ static void com90io_copy_from_card(struct net_device *dev, int bufnum, int offse
 #define ARCNET_TOTAL_SIZE 16
 
 /* COM 9026 controller chip --> ARCnet register addresses */
-#define _INTMASK (ioaddr+0)	/* writable */
-#define _STATUS  (ioaddr+0)	/* readable */
-#define _COMMAND (ioaddr+1)	/* writable, returns random vals on read (?) */
-#define _RESET  (ioaddr+8)	/* software reset (on read) */
-#define _MEMDATA  (ioaddr+12)	/* Data port for IO-mapped memory */
-#define _ADDR_HI  (ioaddr+15)	/* Control registers for said */
-#define _ADDR_LO  (ioaddr+14)
-#define _CONFIG  (ioaddr+2)	/* Configuration register */
+#define _INTMASK	0	/* writable */
+#define _STATUS		0	/* readable */
+#define _COMMAND	1	/* writable, returns random vals on read (?) */
+#define _RESET		8	/* software reset (on read) */
+#define _MEMDATA	12	/* Data port for IO-mapped memory */
+#define _ADDR_HI	15	/* Control registers for said */
+#define _ADDR_LO	14
+#define _CONFIG		2	/* Configuration register */
 
 /****************************************************************************
  *                                                                          *
@@ -82,10 +82,10 @@ static u_char get_buffer_byte(struct net_device *dev, unsigned offset)
 {
 	int ioaddr = dev->base_addr;
 
-	outb(offset >> 8, _ADDR_HI);
-	outb(offset & 0xff, _ADDR_LO);
+	outb(offset >> 8, ioaddr + _ADDR_HI);
+	outb(offset & 0xff, ioaddr + _ADDR_LO);
 
-	return inb(_MEMDATA);
+	return inb(ioaddr + _MEMDATA);
 }
 
 #ifdef ONE_AT_A_TIME_TX
@@ -93,10 +93,10 @@ static void put_buffer_byte(struct net_device *dev, unsigned offset, u_char datu
 {
 	int ioaddr = dev->base_addr;
 
-	outb(offset >> 8, _ADDR_HI);
-	outb(offset & 0xff, _ADDR_LO);
+	outb(offset >> 8, ioaddr + _ADDR_HI);
+	outb(offset & 0xff, ioaddr + _ADDR_LO);
 
-	outb(datum, _MEMDATA);
+	outb(datum, ioaddr + _MEMDATA);
 }
 
 #endif
@@ -106,14 +106,14 @@ static void get_whole_buffer(struct net_device *dev, unsigned offset, unsigned l
 {
 	int ioaddr = dev->base_addr;
 
-	outb((offset >> 8) | AUTOINCflag, _ADDR_HI);
-	outb(offset & 0xff, _ADDR_LO);
+	outb((offset >> 8) | AUTOINCflag, ioaddr + _ADDR_HI);
+	outb(offset & 0xff, ioaddr + _ADDR_LO);
 
 	while (length--)
 #ifdef ONE_AT_A_TIME_RX
 		*(dest++) = get_buffer_byte(dev, offset++);
 #else
-		*(dest++) = inb(_MEMDATA);
+		*(dest++) = inb(ioaddr + _MEMDATA);
 #endif
 }
 
@@ -121,14 +121,14 @@ static void put_whole_buffer(struct net_device *dev, unsigned offset, unsigned l
 {
 	int ioaddr = dev->base_addr;
 
-	outb((offset >> 8) | AUTOINCflag, _ADDR_HI);
-	outb(offset & 0xff, _ADDR_LO);
+	outb((offset >> 8) | AUTOINCflag, ioaddr + _ADDR_HI);
+	outb(offset & 0xff, ioaddr + _ADDR_LO);
 
 	while (length--)
 #ifdef ONE_AT_A_TIME_TX
 		put_buffer_byte(dev, offset++, *(dest++));
 #else
-		outb(*(dest++), _MEMDATA);
+		outb(*(dest++), ioaddr + _MEMDATA);
 #endif
 }
 
@@ -154,14 +154,14 @@ static int __init com90io_probe(struct net_device *dev)
 		       ioaddr, ioaddr + ARCNET_TOTAL_SIZE - 1);
 		return -ENXIO;
 	}
-	if (inb(_STATUS) == 0xFF) {
+	if (inb(ioaddr + _STATUS) == 0xFF) {
 		BUGMSG(D_INIT_REASONS, "IO address %x empty\n", ioaddr);
 		goto err_out;
 	}
-	inb(_RESET);
+	inb(ioaddr + _RESET);
 	mdelay(RESETtime);
 
-	status = inb(_STATUS);
+	status = inb(ioaddr + _STATUS);
 
 	if ((status & 0x9D) != (NORXflag | RECONflag | TXFREEflag | RESETflag)) {
 		BUGMSG(D_INIT_REASONS, "Status invalid (%Xh).\n", status);
@@ -169,24 +169,24 @@ static int __init com90io_probe(struct net_device *dev)
 	}
 	BUGMSG(D_INIT_REASONS, "Status after reset: %X\n", status);
 
-	outb(CFLAGScmd | RESETclear | CONFIGclear, _COMMAND);
+	outb(CFLAGScmd | RESETclear | CONFIGclear, ioaddr + _COMMAND);
 
 	BUGMSG(D_INIT_REASONS, "Status after reset acknowledged: %X\n", status);
 
-	status = inb(_STATUS);
+	status = inb(ioaddr + _STATUS);
 
 	if (status & RESETflag) {
 		BUGMSG(D_INIT_REASONS, "Eternal reset (status=%Xh)\n", status);
 		goto err_out;
 	}
-	outb((0x16 | IOMAPflag) & ~ENABLE16flag, _CONFIG);
+	outb((0x16 | IOMAPflag) & ~ENABLE16flag, ioaddr + _CONFIG);
 
 	/* Read first loc'n of memory */
 
-	outb(AUTOINCflag, _ADDR_HI);
-	outb(0, _ADDR_LO);
+	outb(AUTOINCflag, ioaddr + _ADDR_HI);
+	outb(0, ioaddr + _ADDR_LO);
 
-	if ((status = inb(_MEMDATA)) != 0xd1) {
+	if ((status = inb(ioaddr + _MEMDATA)) != 0xd1) {
 		BUGMSG(D_INIT_REASONS, "Signature byte not found"
 		       " (%Xh instead).\n", status);
 		goto err_out;
@@ -199,9 +199,9 @@ static int __init com90io_probe(struct net_device *dev)
 		 */
 
 		airqmask = probe_irq_on();
-		outb(NORXflag, _INTMASK);
+		outb(NORXflag, ioaddr + _INTMASK);
 		udelay(1);
-		outb(0, _INTMASK);
+		outb(0, ioaddr + _INTMASK);
 		dev->irq = probe_irq_off(airqmask);
 
 		if ((int)dev->irq <= 0) {
@@ -249,7 +249,7 @@ static int __init com90io_found(struct net_device *dev)
 	lp->hw.copy_from_card = com90io_copy_from_card;
 
 	lp->config = (0x16 | IOMAPflag) & ~ENABLE16flag;
-	outb(lp->config, _CONFIG);
+	outb(lp->config, ioaddr + _CONFIG);
 
 	/* get and check the station ID from offset 1 in shmem */
 
@@ -257,7 +257,7 @@ static int __init com90io_found(struct net_device *dev)
 
 	err = register_netdev(dev);
 	if (err) {
-		outb((inb(_CONFIG) & ~IOMAPflag), _CONFIG);
+		outb((inb(ioaddr + _CONFIG) & ~IOMAPflag), ioaddr + _CONFIG);
 		free_irq(dev->irq, dev);
 		release_region(dev->base_addr, ARCNET_TOTAL_SIZE);
 		return err;
@@ -283,19 +283,19 @@ static int com90io_reset(struct net_device *dev, int really_reset)
 	struct arcnet_local *lp = netdev_priv(dev);
 	short ioaddr = dev->base_addr;
 
-	BUGMSG(D_INIT, "Resetting %s (status=%02Xh)\n", dev->name, inb(_STATUS));
+	BUGMSG(D_INIT, "Resetting %s (status=%02Xh)\n", dev->name, inb(ioaddr + _STATUS));
 
 	if (really_reset) {
 		/* reset the card */
-		inb(_RESET);
+		inb(ioaddr + _RESET);
 		mdelay(RESETtime);
 	}
 	/* Set the thing to IO-mapped, 8-bit  mode */
 	lp->config = (0x1C | IOMAPflag) & ~ENABLE16flag;
-	outb(lp->config, _CONFIG);
+	outb(lp->config, ioaddr + _CONFIG);
 
-	outb(CFLAGScmd | RESETclear, _COMMAND); /* clear flags & end reset */
-	outb(CFLAGScmd | CONFIGclear, _COMMAND);
+	outb(CFLAGScmd | RESETclear, ioaddr + _COMMAND); /* clear flags & end reset */
+	outb(CFLAGScmd | CONFIGclear, ioaddr + _COMMAND);
 
 	/* verify that the ARCnet signature byte is present */
 	if (get_buffer_byte(dev, 0) != TESTvalue) {
@@ -303,7 +303,7 @@ static int com90io_reset(struct net_device *dev, int really_reset)
 		return 1;
 	}
 	/* enable extended (512-byte) packets */
-	outb(CONFIGcmd | EXTconf, _COMMAND);
+	outb(CONFIGcmd | EXTconf, ioaddr + _COMMAND);
 
 	/* done!  return success. */
 	return 0;
@@ -314,7 +314,7 @@ static void com90io_command(struct net_device *dev, int cmd)
 {
 	short ioaddr = dev->base_addr;
 
-	outb(cmd, _COMMAND);
+	outb(cmd, ioaddr + _COMMAND);
 }
 
 
@@ -322,7 +322,7 @@ static int com90io_status(struct net_device *dev)
 {
 	short ioaddr = dev->base_addr;
 
-	return inb(_STATUS);
+	return inb(ioaddr + _STATUS);
 }
 
 
@@ -330,7 +330,7 @@ static void com90io_setmask(struct net_device *dev, int mask)
 {
 	short ioaddr = dev->base_addr;
 
-	outb(mask, _INTMASK);
+	outb(mask, ioaddr + _INTMASK);
 }
 
 static void com90io_copy_to_card(struct net_device *dev, int bufnum, int offset,
@@ -412,7 +412,7 @@ static void __exit com90io_exit(void)
 	unregister_netdev(dev);
 
 	/* Set the thing back to MMAP mode, in case the old driver is loaded later */
-	outb((inb(_CONFIG) & ~IOMAPflag), _CONFIG);
+	outb((inb(ioaddr + _CONFIG) & ~IOMAPflag), ioaddr + _CONFIG);
 
 	free_irq(dev->irq, dev);
 	release_region(dev->base_addr, ARCNET_TOTAL_SIZE);
-- 
2.1.4
