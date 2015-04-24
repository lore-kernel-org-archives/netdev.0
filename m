From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 10/21] ARCNET: com20020: fix ioaddr prefixes
Date: Fri, 24 Apr 2015 19:20:44 +0200
Message-ID: <1429896055-31680-11-git-send-email-m.grzeschik@pengutronix.de>
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
 drivers/net/arcnet/com20020-isa.c |  2 +-
 drivers/net/arcnet/com20020.c     | 89 ++++++++++++++++++++-------------------
 drivers/net/arcnet/com20020_cs.c  |  6 +--
 include/linux/com20020.h          | 20 ++++-----
 4 files changed, 59 insertions(+), 58 deletions(-)

diff --git a/drivers/net/arcnet/com20020-isa.c b/drivers/net/arcnet/com20020-isa.c
index c674511..3e5be24 100644
--- a/drivers/net/arcnet/com20020-isa.c
+++ b/drivers/net/arcnet/com20020-isa.c
@@ -68,7 +68,7 @@ static int __init com20020isa_probe(struct net_device *dev)
 		       ioaddr, ioaddr + ARCNET_TOTAL_SIZE - 1);
 		return -ENXIO;
 	}
-	if (inb(_STATUS) == 0xFF) {
+	if (inb(ioaddr + _STATUS) == 0xFF) {
 		BUGMSG(D_NORMAL, "IO address %x empty\n", ioaddr);
 		err = -ENODEV;
 		goto out;
diff --git a/drivers/net/arcnet/com20020.c b/drivers/net/arcnet/com20020.c
index ed0cdd3..4b4bb96 100644
--- a/drivers/net/arcnet/com20020.c
+++ b/drivers/net/arcnet/com20020.c
@@ -63,11 +63,11 @@ static void com20020_copy_from_card(struct net_device *dev, int bufnum,
 	int ioaddr = dev->base_addr, ofs = 512 * bufnum + offset;
 
 	/* set up the address register */
-	outb((ofs >> 8) | RDDATAflag | AUTOINCflag, _ADDR_HI);
-	outb(ofs & 0xff, _ADDR_LO);
+	outb((ofs >> 8) | RDDATAflag | AUTOINCflag, ioaddr + _ADDR_HI);
+	outb(ofs & 0xff, ioaddr + _ADDR_LO);
 
 	/* copy the data */
-	TIME("insb", count, insb(_MEMDATA, buf, count));
+	TIME("insb", count, insb(ioaddr + _MEMDATA, buf, count));
 }
 
 
@@ -77,11 +77,11 @@ static void com20020_copy_to_card(struct net_device *dev, int bufnum,
 	int ioaddr = dev->base_addr, ofs = 512 * bufnum + offset;
 
 	/* set up the address register */
-	outb((ofs >> 8) | AUTOINCflag, _ADDR_HI);
-	outb(ofs & 0xff, _ADDR_LO);
+	outb((ofs >> 8) | AUTOINCflag, ioaddr + _ADDR_HI);
+	outb(ofs & 0xff, ioaddr + _ADDR_LO);
 
 	/* copy the data */
-	TIME("outsb", count, outsb(_MEMDATA, buf, count));
+	TIME("outsb", count, outsb(ioaddr + _MEMDATA, buf, count));
 }
 
 
@@ -92,9 +92,9 @@ int com20020_check(struct net_device *dev)
 	struct arcnet_local *lp = netdev_priv(dev);
 
 	/* reset the card */
-	outb(0x18 | 0x80, _CONFIG);
+	outb(0x18 | 0x80, ioaddr + _CONFIG);
 	udelay(5);
-	outb(0x18, _CONFIG);
+	outb(0x18, ioaddr + _CONFIG);
 	mdelay(RESETtime);
 
 	lp->setup = lp->clockm ? 0 : (lp->clockp << 1);
@@ -105,25 +105,25 @@ int com20020_check(struct net_device *dev)
 	lp->setup = lp->setup | P1MODE;
 
 	lp->config = (lp->config & ~0x03) | SUB_SETUP1;
-	outb(lp->config, _CONFIG);
-	outb(lp->setup, _XREG);
+	outb(lp->config, ioaddr + _CONFIG);
+	outb(lp->setup, ioaddr + _XREG);
 
 	if (lp->clockm != 0)
 	{
-		outb(SUB_SETUP2, _SUBADR);
-		outb(lp->setup2, _XREG);
+		outb(SUB_SETUP2, ioaddr + _SUBADR);
+		outb(lp->setup2, ioaddr + _XREG);
 
 		/* must now write the magic "restart operation" command */
 		mdelay(1);
-		outb(0x18, _COMMAND);
+		outb(0x18, ioaddr + _COMMAND);
 	}
 
 	lp->config = 0x21 | (lp->timeout << 3) | (lp->backplane << 2);
 	/* set node ID to 0x42 (but transmitter is disabled, so it's okay) */
-	outb(lp->config, _CONFIG);
+	outb(lp->config, ioaddr + _CONFIG);
 	outb(0x42, ioaddr + BUS_ALIGN*7);
 
-	status = inb(_STATUS);
+	status = inb(ioaddr + _STATUS);
 
 	if ((status & 0x99) != (NORXflag | TXFREEflag | RESETflag)) {
 		BUGMSG(D_NORMAL, "status invalid (%Xh).\n", status);
@@ -132,20 +132,21 @@ int com20020_check(struct net_device *dev)
 	BUGMSG(D_INIT_REASONS, "status after reset: %X\n", status);
 
 	/* Enable TX */
-	outb(0x39, _CONFIG);
+	outb(0x39, ioaddr + _CONFIG);
 	outb(inb(ioaddr + BUS_ALIGN*8), ioaddr + BUS_ALIGN*7);
 
-	outb((CFLAGScmd | RESETclear | CONFIGclear), _COMMAND);
+	outb((CFLAGScmd | RESETclear | CONFIGclear), ioaddr + _COMMAND);
 
-	status = inb(_STATUS);
+	status = inb(ioaddr + _STATUS);
 	BUGMSG(D_INIT_REASONS, "status after reset acknowledged: %X\n",
 	       status);
 
 	/* Read first location of memory */
-	outb(0 | RDDATAflag | AUTOINCflag, _ADDR_HI);
-	outb(0, _ADDR_LO);
+	outb(0 | RDDATAflag | AUTOINCflag, ioaddr + _ADDR_HI);
+	outb(0, ioaddr + _ADDR_LO);
 
-	if ((status = inb(_MEMDATA)) != TESTvalue) {
+	status = inb(ioaddr + _MEMDATA);
+	if (status != TESTvalue) {
 		BUGMSG(D_NORMAL, "Signature byte not found (%02Xh != D1h).\n",
 		       status);
 		return -ENODEV;
@@ -161,8 +162,8 @@ static int com20020_set_hwaddr(struct net_device *dev, void *addr)
 
 	memcpy(dev->dev_addr, hwaddr->sa_data, 1);
 	lp->config = (lp->config & ~0x03) | SUB_NODE;
-	outb(lp->config, _CONFIG);
-	outb(dev->dev_addr[0], _XREG);
+	outb(lp->config, ioaddr + _CONFIG);
+	outb(dev->dev_addr[0], ioaddr + _XREG);
 
 	return 0;
 }
@@ -201,23 +202,23 @@ int com20020_found(struct net_device *dev, int shared)
 		dev->dev_addr[0] = inb(ioaddr + BUS_ALIGN*8);	/* FIXME: do this some other way! */
 
 	lp->config = (lp->config & ~0x03) | SUB_SETUP1;
-	outb(lp->config, _CONFIG);
-	outb(lp->setup, _XREG);
+	outb(lp->config, ioaddr + _CONFIG);
+	outb(lp->setup, ioaddr + _XREG);
 
 	if (lp->card_flags & ARC_CAN_10MBIT)
 	{
-		outb(SUB_SETUP2, _SUBADR);
-		outb(lp->setup2, _XREG);
+		outb(SUB_SETUP2, ioaddr + _SUBADR);
+		outb(lp->setup2, ioaddr + _XREG);
 
 		/* must now write the magic "restart operation" command */
 		mdelay(1);
-		outb(0x18, _COMMAND);
+		outb(0x18, ioaddr + _COMMAND);
 	}
 
 	lp->config = 0x20 | (lp->timeout << 3) | (lp->backplane << 2) | 1;
 	/* Default 0x38 + register: Node ID */
-	outb(lp->config, _CONFIG);
-	outb(dev->dev_addr[0], _XREG);
+	outb(lp->config, ioaddr + _CONFIG);
+	outb(dev->dev_addr[0], ioaddr + _XREG);
 
 	/* reserve the irq */
 	if (request_irq(dev->irq, arcnet_interrupt, shared,
@@ -265,24 +266,24 @@ static int com20020_reset(struct net_device *dev, int really_reset)
 	BUGMSG(D_DEBUG, "%s: %d: %s: dev: %p, lp: %p, dev->name: %s\n",
 		__FILE__,__LINE__,__func__,dev,lp,dev->name);
 	BUGMSG(D_INIT, "Resetting %s (status=%02Xh)\n",
-	       dev->name, inb(_STATUS));
+	       dev->name, inb(ioaddr + _STATUS));
 
 	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
 	lp->config = TXENcfg | (lp->timeout << 3) | (lp->backplane << 2);
 	/* power-up defaults */
-	outb(lp->config, _CONFIG);
+	outb(lp->config, ioaddr + _CONFIG);
 	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
 
 	if (really_reset) {
 		/* reset the card */
-		outb(lp->config | 0x80, _CONFIG);
+		outb(lp->config | 0x80, ioaddr + _CONFIG);
 		udelay(5);
-		outb(lp->config, _CONFIG);
+		outb(lp->config, ioaddr + _CONFIG);
 		mdelay(RESETtime * 2);	/* COM20020 seems to be slower sometimes */
 	}
 	/* clear flags & end reset */
 	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
-	outb((CFLAGScmd | RESETclear | CONFIGclear), _COMMAND);
+	outb((CFLAGScmd | RESETclear | CONFIGclear), ioaddr + _COMMAND);
 
 	/* verify that the ARCnet signature byte is present */
 	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
@@ -295,7 +296,7 @@ static int com20020_reset(struct net_device *dev, int really_reset)
 		return 1;
 	}
 	/* enable extended (512-byte) packets */
-	outb((CONFIGcmd | EXTconf), _COMMAND);
+	outb((CONFIGcmd | EXTconf), ioaddr + _COMMAND);
 	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
 
 	/* done!  return success. */
@@ -306,13 +307,13 @@ static void com20020_setmask(struct net_device *dev, int mask)
 {
 	u_int ioaddr = dev->base_addr;
 	BUGMSG(D_DURING, "Setting mask to %x at %x\n",mask,ioaddr);
-	outb((mask), _INTMASK);
+	outb((mask), ioaddr + _INTMASK);
 }
 
 static void com20020_command(struct net_device *dev, int cmd)
 {
 	u_int ioaddr = dev->base_addr;
-	outb(cmd, _COMMAND);
+	outb(cmd, ioaddr + _COMMAND);
 }
 
 
@@ -320,7 +321,7 @@ static int com20020_status(struct net_device *dev)
 {
 	u_int ioaddr = dev->base_addr;
 
-	return inb(_STATUS) + (inb(_DIAGSTAT) << 8);
+	return inb(ioaddr + _STATUS) + (inb(ioaddr + _DIAGSTAT) << 8);
 }
 
 static void com20020_close(struct net_device *dev)
@@ -330,7 +331,7 @@ static void com20020_close(struct net_device *dev)
 
 	/* disable transmitter */
 	lp->config &= ~TXENcfg;
-	outb(lp->config, _CONFIG);
+	outb(lp->config, ioaddr + _CONFIG);
 }
 
 /* Set or clear the multicast filter for this adaptor.
@@ -349,18 +350,18 @@ static void com20020_set_mc_list(struct net_device *dev)
 		if (!(lp->setup & PROMISCset))
 			BUGMSG(D_NORMAL, "Setting promiscuous flag...\n");
 		lp->config = (lp->config & ~0x03) | SUB_SETUP1;
-		outb(lp->config, _CONFIG);
+		outb(lp->config, ioaddr + _CONFIG);
 		lp->setup |= PROMISCset;
-		outb(lp->setup, _XREG);
+		outb(lp->setup, ioaddr + _XREG);
 	} else
 		/* Disable promiscuous mode, use normal mode */
 	{
 		if ((lp->setup & PROMISCset))
 			BUGMSG(D_NORMAL, "Resetting promiscuous flag...\n");
 		lp->config = (lp->config & ~0x03) | SUB_SETUP1;
-		outb(lp->config, _CONFIG);
+		outb(lp->config, ioaddr + _CONFIG);
 		lp->setup &= ~PROMISCset;
-		outb(lp->setup, _XREG);
+		outb(lp->setup, ioaddr + _XREG);
 	}
 }
 
diff --git a/drivers/net/arcnet/com20020_cs.c b/drivers/net/arcnet/com20020_cs.c
index aee4455..dfde685 100644
--- a/drivers/net/arcnet/com20020_cs.c
+++ b/drivers/net/arcnet/com20020_cs.c
@@ -67,15 +67,15 @@ static void regdump(struct net_device *dev)
 	netdev_dbg(dev, "buffer0 dump:\n");
 	/* set up the address register */
 	count = 0;
-	outb((count >> 8) | RDDATAflag | AUTOINCflag, _ADDR_HI);
-	outb(count & 0xff, _ADDR_LO);
+	outb((count >> 8) | RDDATAflag | AUTOINCflag, ioaddr + _ADDR_HI);
+	outb(count & 0xff, ioaddr + _ADDR_LO);
 
 	for (count = 0; count < 256 + 32; count++) {
 		if (!(count % 16))
 			pr_cont("%04X:", count);
 
 		/* copy the data */
-		pr_cont(" %02X", inb(_MEMDATA));
+		pr_cont(" %02X", inb(ioaddr + _MEMDATA));
 	}
 	pr_cont("\n");
 #endif
diff --git a/include/linux/com20020.h b/include/linux/com20020.h
index 2aaa57d..c2d8647 100644
--- a/include/linux/com20020.h
+++ b/include/linux/com20020.h
@@ -71,16 +71,16 @@ struct com20020_dev {
 	int index;
 };
 
-#define _INTMASK  (ioaddr+BUS_ALIGN*0)	/* writable */
-#define _STATUS   (ioaddr+BUS_ALIGN*0)	/* readable */
-#define _COMMAND  (ioaddr+BUS_ALIGN*1)	/* standard arcnet commands */
-#define _DIAGSTAT (ioaddr+BUS_ALIGN*1)	/* diagnostic status register */
-#define _ADDR_HI  (ioaddr+BUS_ALIGN*2)	/* control registers for IO-mapped memory */
-#define _ADDR_LO  (ioaddr+BUS_ALIGN*3)
-#define _MEMDATA  (ioaddr+BUS_ALIGN*4)	/* data port for IO-mapped memory */
-#define _SUBADR   (ioaddr+BUS_ALIGN*5)	/* the extended port _XREG refers to */
-#define _CONFIG   (ioaddr+BUS_ALIGN*6)	/* configuration register */
-#define _XREG     (ioaddr+BUS_ALIGN*7)	/* extra registers (indexed by _CONFIG
+#define _INTMASK  (BUS_ALIGN*0)	/* writable */
+#define _STATUS   (BUS_ALIGN*0)	/* readable */
+#define _COMMAND  (BUS_ALIGN*1)	/* standard arcnet commands */
+#define _DIAGSTAT (BUS_ALIGN*1)	/* diagnostic status register */
+#define _ADDR_HI  (BUS_ALIGN*2)	/* control registers for IO-mapped memory */
+#define _ADDR_LO  (BUS_ALIGN*3)
+#define _MEMDATA  (BUS_ALIGN*4)	/* data port for IO-mapped memory */
+#define _SUBADR   (BUS_ALIGN*5)	/* the extended port _XREG refers to */
+#define _CONFIG   (BUS_ALIGN*6)	/* configuration register */
+#define _XREG     (BUS_ALIGN*7)	/* extra registers (indexed by _CONFIG
 					or _SUBADR) */
 
 /* in the ADDR_HI register */
-- 
2.1.4
