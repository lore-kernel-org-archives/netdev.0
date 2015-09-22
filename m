From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 21/33] arcnet: com20020: Use arcnet_<I/O> routines
Date: Tue, 22 Sep 2015 11:02:02 +0200
Message-ID: <1442912534-10821-22-git-send-email-m.grzeschik@pengutronix.de>
References: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, joe@perches.com, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:39890 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932659AbbIVJCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 05:02:42 -0400
In-Reply-To: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

Simplify and make consistent the current uses of inb/outb
by using the newly introduced arcnet_<I/O> equivalents.

o Add new #defines for register offsets
  There is an register offset, 8, that is unnamed and used as-is.
o Remove old #defines that included the ioaddr
o Remove obfuscating macros by expanding them in-place where appropriate
o Create static inline com20020_set_subaddress for the SET_SUBADR macro

There is an unused arcnet config entry CONFIGSA100_CT6001 which added a
special #define BUS_ALIGN which was introduced but never used in fullhist git
tree commit 22cfce4b82b0 ("[ARCNET]: Fixes.") in Nov 2004 for Linux v2.6.10.

This BUS_ALIGN #define tries to allow 8 bit devices to work on a 16 bit
bus by aligning addresses to 16 bit boundaries.

Move this currently unused CONFIG_SA1100_CT6001 BUS_ALIGN macro from
com20020.h to arcdevice.h.

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/arcdevice.h    |  22 +++++---
 drivers/net/arcnet/com20020-isa.c |  14 +++---
 drivers/net/arcnet/com20020-pci.c |   6 +--
 drivers/net/arcnet/com20020.c     | 103 +++++++++++++++++++++-----------------
 drivers/net/arcnet/com20020.h     |  74 +++++++++------------------
 drivers/net/arcnet/com20020_cs.c  |  17 ++++---
 6 files changed, 114 insertions(+), 122 deletions(-)

diff --git a/drivers/net/arcnet/arcdevice.h b/drivers/net/arcnet/arcdevice.h
index 95e7ed6..4afa32b 100644
--- a/drivers/net/arcnet/arcdevice.h
+++ b/drivers/net/arcnet/arcdevice.h
@@ -344,28 +344,34 @@ void arcnet_timeout(struct net_device *dev);
 
 /* I/O equivalents */
 
+#ifdef CONFIG_SA1100_CT6001
+#define BUS_ALIGN  2  /* 8 bit device on a 16 bit bus - needs padding */
+#else
+#define BUS_ALIGN  1
+#endif
+
 /* addr and offset allow register like names to define the actual IO  address.
  * A configuration option multiplies the offset for alignment.
  */
 #define arcnet_inb(addr, offset)					\
-	inb((addr) + (offset))
+	inb((addr) + BUS_ALIGN * (offset))
 #define arcnet_outb(value, addr, offset)				\
-	outb(value, (addr) + (offset))
+	outb(value, (addr) + BUS_ALIGN * (offset))
 
 #define arcnet_insb(addr, offset, buffer, count)			\
-	insb((addr) + (offset), buffer, count)
+	insb((addr) + BUS_ALIGN * (offset), buffer, count)
 #define arcnet_outsb(addr, offset, buffer, count)			\
-	outsb((addr) + (offset), buffer, count)
+	outsb((addr) + BUS_ALIGN * (offset), buffer, count)
 
 #define arcnet_inw(addr, offset)					\
-	inw((addr) + (offset))
+	inw((addr) + BUS_ALIGN * (offset))
 #define arcnet_outw(value, addr, offset)				\
-	outw(value, (addr) + (offset))
+	outw(value, (addr) + BUS_ALIGN * (offset))
 
 #define arcnet_insw(addr, offset, buffer, count)			\
-	insw((addr) + (offset), buffer, count)
+	insw((addr) + BUS_ALIGN * (offset), buffer, count)
 #define arcnet_outsw(addr, offset, buffer, count)			\
-	outsw((addr) + (offset), buffer, count)
+	outsw((addr) + BUS_ALIGN * (offset), buffer, count)
 
 #endif				/* __KERNEL__ */
 #endif				/* _LINUX_ARCDEVICE_H */
diff --git a/drivers/net/arcnet/com20020-isa.c b/drivers/net/arcnet/com20020-isa.c
index ab5202b..b9e9931 100644
--- a/drivers/net/arcnet/com20020-isa.c
+++ b/drivers/net/arcnet/com20020-isa.c
@@ -67,7 +67,7 @@ static int __init com20020isa_probe(struct net_device *dev)
 			   ioaddr, ioaddr + ARCNET_TOTAL_SIZE - 1);
 		return -ENXIO;
 	}
-	if (ASTATUS() == 0xFF) {
+	if (arcnet_inb(ioaddr, COM20020_REG_R_STATUS) == 0xFF) {
 		arc_printk(D_NORMAL, dev, "IO address %x empty\n", ioaddr);
 		err = -ENODEV;
 		goto out;
@@ -83,20 +83,20 @@ static int __init com20020isa_probe(struct net_device *dev)
 		 * we tell it to start receiving.
 		 */
 		arc_printk(D_INIT_REASONS, dev, "intmask was %02Xh\n",
-			   inb(_INTMASK));
-		outb(0, _INTMASK);
+			   arcnet_inb(ioaddr, COM20020_REG_R_STATUS));
+		arcnet_outb(0, ioaddr, COM20020_REG_W_INTMASK);
 		airqmask = probe_irq_on();
-		outb(NORXflag, _INTMASK);
+		arcnet_outb(NORXflag, ioaddr, COM20020_REG_W_INTMASK);
 		udelay(1);
-		outb(0, _INTMASK);
+		arcnet_outb(0, ioaddr, COM20020_REG_W_INTMASK);
 		dev->irq = probe_irq_off(airqmask);
 
 		if ((int)dev->irq <= 0) {
 			arc_printk(D_INIT_REASONS, dev, "Autoprobe IRQ failed first time\n");
 			airqmask = probe_irq_on();
-			outb(NORXflag, _INTMASK);
+			arcnet_outb(NORXflag, ioaddr, COM20020_REG_W_INTMASK);
 			udelay(5);
-			outb(0, _INTMASK);
+			arcnet_outb(0, ioaddr, COM20020_REG_W_INTMASK);
 			dev->irq = probe_irq_off(airqmask);
 			if ((int)dev->irq <= 0) {
 				arc_printk(D_NORMAL, dev, "Autoprobe IRQ failed.\n");
diff --git a/drivers/net/arcnet/com20020-pci.c b/drivers/net/arcnet/com20020-pci.c
index 1a75a69..9b82126 100644
--- a/drivers/net/arcnet/com20020-pci.c
+++ b/drivers/net/arcnet/com20020-pci.c
@@ -117,8 +117,8 @@ static int com20020pci_probe(struct pci_dev *pdev,
 		 * ARCNET controller needs
 		 * this access to detect bustype
 		 */
-		outb(0x00, ioaddr + 1);
-		inb(ioaddr + 1);
+		arcnet_outb(0x00, ioaddr, COM20020_REG_W_COMMAND);
+		arcnet_inb(ioaddr, COM20020_REG_R_DIAGSTAT);
 
 		dev->base_addr = ioaddr;
 		dev->dev_addr[0] = node;
@@ -131,7 +131,7 @@ static int com20020pci_probe(struct pci_dev *pdev,
 		lp->timeout = timeout;
 		lp->hw.owner = THIS_MODULE;
 
-		if (ASTATUS() == 0xFF) {
+		if (arcnet_inb(ioaddr, COM20020_REG_R_STATUS) == 0xFF) {
 			pr_err("IO address %Xh is empty!\n", ioaddr);
 			ret = -EIO;
 			goto out_port;
diff --git a/drivers/net/arcnet/com20020.c b/drivers/net/arcnet/com20020.c
index ddd64bb..d416275 100644
--- a/drivers/net/arcnet/com20020.c
+++ b/drivers/net/arcnet/com20020.c
@@ -65,11 +65,13 @@ static void com20020_copy_from_card(struct net_device *dev, int bufnum,
 	int ioaddr = dev->base_addr, ofs = 512 * bufnum + offset;
 
 	/* set up the address register */
-	outb((ofs >> 8) | RDDATAflag | AUTOINCflag, _ADDR_HI);
-	outb(ofs & 0xff, _ADDR_LO);
+	arcnet_outb((ofs >> 8) | RDDATAflag | AUTOINCflag,
+		    ioaddr, COM20020_REG_W_ADDR_HI);
+	arcnet_outb(ofs & 0xff, ioaddr, COM20020_REG_W_ADDR_LO);
 
 	/* copy the data */
-	TIME(dev, "insb", count, insb(_MEMDATA, buf, count));
+	TIME(dev, "insb", count,
+	     arcnet_insb(ioaddr, COM20020_REG_RW_MEMDATA, buf, count));
 }
 
 static void com20020_copy_to_card(struct net_device *dev, int bufnum,
@@ -78,11 +80,12 @@ static void com20020_copy_to_card(struct net_device *dev, int bufnum,
 	int ioaddr = dev->base_addr, ofs = 512 * bufnum + offset;
 
 	/* set up the address register */
-	outb((ofs >> 8) | AUTOINCflag, _ADDR_HI);
-	outb(ofs & 0xff, _ADDR_LO);
+	arcnet_outb((ofs >> 8) | AUTOINCflag, ioaddr, COM20020_REG_W_ADDR_HI);
+	arcnet_outb(ofs & 0xff, ioaddr, COM20020_REG_W_ADDR_LO);
 
 	/* copy the data */
-	TIME(dev, "outsb", count, outsb(_MEMDATA, buf, count));
+	TIME(dev, "outsb", count,
+	     arcnet_outsb(ioaddr, COM20020_REG_RW_MEMDATA, buf, count));
 }
 
 /* Reset the card and check some basic stuff during the detection stage. */
@@ -91,7 +94,9 @@ int com20020_check(struct net_device *dev)
 	int ioaddr = dev->base_addr, status;
 	struct arcnet_local *lp = netdev_priv(dev);
 
-	ARCRESET0;
+	arcnet_outb(0x18 | 0x80, ioaddr, COM20020_REG_W_CONFIG);
+	udelay(5);
+	arcnet_outb(0x18 , ioaddr, COM20020_REG_W_CONFIG);
 	mdelay(RESETtime);
 
 	lp->setup = lp->clockm ? 0 : (lp->clockp << 1);
@@ -101,24 +106,24 @@ int com20020_check(struct net_device *dev)
 	/* Enable P1Mode for backplane mode */
 	lp->setup = lp->setup | P1MODE;
 
-	SET_SUBADR(SUB_SETUP1);
-	outb(lp->setup, _XREG);
+	com20020_set_subaddress(lp, ioaddr, SUB_SETUP1);
+	arcnet_outb(lp->setup, ioaddr, COM20020_REG_W_XREG);
 
 	if (lp->clockm != 0) {
-		SET_SUBADR(SUB_SETUP2);
-		outb(lp->setup2, _XREG);
+		com20020_set_subaddress(lp, ioaddr, SUB_SETUP2);
+		arcnet_outb(lp->setup2, ioaddr, COM20020_REG_W_XREG);
 
 		/* must now write the magic "restart operation" command */
 		mdelay(1);
-		outb(0x18, _COMMAND);
+		arcnet_outb(0x18, ioaddr, COM20020_REG_W_COMMAND);
 	}
 
 	lp->config = 0x21 | (lp->timeout << 3) | (lp->backplane << 2);
 	/* set node ID to 0x42 (but transmitter is disabled, so it's okay) */
-	SETCONF;
-	outb(0x42, ioaddr + BUS_ALIGN * 7);
+	arcnet_outb(lp->config, ioaddr, COM20020_REG_W_CONFIG);
+	arcnet_outb(0x42, ioaddr, COM20020_REG_W_XREG);
 
-	status = ASTATUS();
+	status = arcnet_inb(ioaddr, COM20020_REG_R_STATUS);
 
 	if ((status & 0x99) != (NORXflag | TXFREEflag | RESETflag)) {
 		arc_printk(D_NORMAL, dev, "status invalid (%Xh).\n", status);
@@ -127,20 +132,21 @@ int com20020_check(struct net_device *dev)
 	arc_printk(D_INIT_REASONS, dev, "status after reset: %X\n", status);
 
 	/* Enable TX */
-	outb(0x39, _CONFIG);
-	outb(inb(ioaddr + BUS_ALIGN * 8), ioaddr + BUS_ALIGN * 7);
+	arcnet_outb(0x39, ioaddr, COM20020_REG_W_CONFIG);
+	arcnet_outb(arcnet_inb(ioaddr, 8), ioaddr, COM20020_REG_W_XREG);
 
-	ACOMMAND(CFLAGScmd | RESETclear | CONFIGclear);
-
-	status = ASTATUS();
+	arcnet_outb(CFLAGScmd | RESETclear | CONFIGclear,
+		    ioaddr, COM20020_REG_W_COMMAND);
+	status = arcnet_inb(ioaddr, COM20020_REG_R_STATUS);
 	arc_printk(D_INIT_REASONS, dev, "status after reset acknowledged: %X\n",
 		   status);
 
 	/* Read first location of memory */
-	outb(0 | RDDATAflag | AUTOINCflag, _ADDR_HI);
-	outb(0, _ADDR_LO);
+	arcnet_outb(0 | RDDATAflag | AUTOINCflag,
+		    ioaddr, COM20020_REG_W_ADDR_HI);
+	arcnet_outb(0, ioaddr, COM20020_REG_W_ADDR_LO);
 
-	status = inb(_MEMDATA);
+	status = arcnet_inb(ioaddr, COM20020_REG_RW_MEMDATA);
 	if (status != TESTvalue) {
 		arc_printk(D_NORMAL, dev, "Signature byte not found (%02Xh != D1h).\n",
 			   status);
@@ -156,8 +162,8 @@ static int com20020_set_hwaddr(struct net_device *dev, void *addr)
 	struct sockaddr *hwaddr = addr;
 
 	memcpy(dev->dev_addr, hwaddr->sa_data, 1);
-	SET_SUBADR(SUB_NODE);
-	outb(dev->dev_addr[0], _XREG);
+	com20020_set_subaddress(lp, ioaddr, SUB_NODE);
+	arcnet_outb(dev->dev_addr[0], ioaddr, COM20020_REG_W_XREG);
 
 	return 0;
 }
@@ -194,24 +200,24 @@ int com20020_found(struct net_device *dev, int shared)
 
 	/* FIXME: do this some other way! */
 	if (!dev->dev_addr[0])
-		dev->dev_addr[0] = inb(ioaddr + BUS_ALIGN * 8);
+		dev->dev_addr[0] = arcnet_inb(ioaddr, 8);
 
-	SET_SUBADR(SUB_SETUP1);
-	outb(lp->setup, _XREG);
+	com20020_set_subaddress(lp, ioaddr, SUB_SETUP1);
+	arcnet_outb(lp->setup, ioaddr, COM20020_REG_W_XREG);
 
 	if (lp->card_flags & ARC_CAN_10MBIT) {
-		SET_SUBADR(SUB_SETUP2);
-		outb(lp->setup2, _XREG);
+		com20020_set_subaddress(lp, ioaddr, SUB_SETUP2);
+		arcnet_outb(lp->setup2, ioaddr, COM20020_REG_W_XREG);
 
 		/* must now write the magic "restart operation" command */
 		mdelay(1);
-		outb(0x18, _COMMAND);
+		arcnet_outb(0x18, ioaddr, COM20020_REG_W_COMMAND);
 	}
 
 	lp->config = 0x20 | (lp->timeout << 3) | (lp->backplane << 2) | 1;
 	/* Default 0x38 + register: Node ID */
-	SETCONF;
-	outb(dev->dev_addr[0], _XREG);
+	arcnet_outb(lp->config, ioaddr, COM20020_REG_W_CONFIG);
+	arcnet_outb(dev->dev_addr[0], ioaddr, COM20020_REG_W_XREG);
 
 	/* reserve the irq */
 	if (request_irq(dev->irq, arcnet_interrupt, shared,
@@ -264,23 +270,26 @@ static int com20020_reset(struct net_device *dev, int really_reset)
 	arc_printk(D_DEBUG, dev, "%s: %d: %s: dev: %p, lp: %p, dev->name: %s\n",
 		   __FILE__, __LINE__, __func__, dev, lp, dev->name);
 	arc_printk(D_INIT, dev, "Resetting %s (status=%02Xh)\n",
-		   dev->name, ASTATUS());
+		   dev->name, arcnet_inb(ioaddr, COM20020_REG_R_STATUS));
 
 	arc_printk(D_DEBUG, dev, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
 	lp->config = TXENcfg | (lp->timeout << 3) | (lp->backplane << 2);
 	/* power-up defaults */
-	SETCONF;
+	arcnet_outb(lp->config, ioaddr, COM20020_REG_W_CONFIG);
 	arc_printk(D_DEBUG, dev, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
 
 	if (really_reset) {
 		/* reset the card */
-		ARCRESET;
+		arcnet_outb(lp->config | 0x80, ioaddr, COM20020_REG_W_CONFIG);
+		udelay(5);
+		arcnet_outb(lp->config, ioaddr, COM20020_REG_W_CONFIG);
 		mdelay(RESETtime * 2);
 				/* COM20020 seems to be slower sometimes */
 	}
 	/* clear flags & end reset */
 	arc_printk(D_DEBUG, dev, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
-	ACOMMAND(CFLAGScmd | RESETclear | CONFIGclear);
+	arcnet_outb(CFLAGScmd | RESETclear | CONFIGclear,
+		    ioaddr, COM20020_REG_W_COMMAND);
 
 	/* verify that the ARCnet signature byte is present */
 	arc_printk(D_DEBUG, dev, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
@@ -294,7 +303,8 @@ static int com20020_reset(struct net_device *dev, int really_reset)
 		return 1;
 	}
 	/* enable extended (512-byte) packets */
-	ACOMMAND(CONFIGcmd | EXTconf);
+	arcnet_outb(CONFIGcmd | EXTconf, ioaddr, COM20020_REG_W_COMMAND);
+
 	arc_printk(D_DEBUG, dev, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
 
 	/* done!  return success. */
@@ -306,21 +316,22 @@ static void com20020_setmask(struct net_device *dev, int mask)
 	u_int ioaddr = dev->base_addr;
 
 	arc_printk(D_DURING, dev, "Setting mask to %x at %x\n", mask, ioaddr);
-	AINTMASK(mask);
+	arcnet_outb(mask, ioaddr, COM20020_REG_W_INTMASK);
 }
 
 static void com20020_command(struct net_device *dev, int cmd)
 {
 	u_int ioaddr = dev->base_addr;
 
-	ACOMMAND(cmd);
+	arcnet_outb(cmd, ioaddr, COM20020_REG_W_COMMAND);
 }
 
 static int com20020_status(struct net_device *dev)
 {
 	u_int ioaddr = dev->base_addr;
 
-	return ASTATUS() + (ADIAGSTATUS() << 8);
+	return arcnet_inb(ioaddr, COM20020_REG_R_STATUS) +
+		(arcnet_inb(ioaddr, COM20020_REG_R_DIAGSTAT) << 8);
 }
 
 static void com20020_close(struct net_device *dev)
@@ -330,7 +341,7 @@ static void com20020_close(struct net_device *dev)
 
 	/* disable transmitter */
 	lp->config &= ~TXENcfg;
-	SETCONF;
+	arcnet_outb(lp->config, ioaddr, COM20020_REG_W_CONFIG);
 }
 
 /* Set or clear the multicast filter for this adaptor.
@@ -349,16 +360,16 @@ static void com20020_set_mc_list(struct net_device *dev)
 		/* Enable promiscuous mode */
 		if (!(lp->setup & PROMISCset))
 			arc_printk(D_NORMAL, dev, "Setting promiscuous flag...\n");
-		SET_SUBADR(SUB_SETUP1);
+		com20020_set_subaddress(lp, ioaddr, SUB_SETUP1);
 		lp->setup |= PROMISCset;
-		outb(lp->setup, _XREG);
+		arcnet_outb(lp->setup, ioaddr, COM20020_REG_W_XREG);
 	} else {
 		/* Disable promiscuous mode, use normal mode */
 		if ((lp->setup & PROMISCset))
 			arc_printk(D_NORMAL, dev, "Resetting promiscuous flag...\n");
-		SET_SUBADR(SUB_SETUP1);
+		com20020_set_subaddress(lp, ioaddr, SUB_SETUP1);
 		lp->setup &= ~PROMISCset;
-		outb(lp->setup, _XREG);
+		arcnet_outb(lp->setup, ioaddr, COM20020_REG_W_XREG);
 	}
 }
 
diff --git a/drivers/net/arcnet/com20020.h b/drivers/net/arcnet/com20020.h
index 8589899..ffb1946 100644
--- a/drivers/net/arcnet/com20020.h
+++ b/drivers/net/arcnet/com20020.h
@@ -1,6 +1,6 @@
 /*
  * Linux ARCnet driver - COM20020 chipset support - function declarations
- * 
+ *
  * Written 1997 by David Woodhouse.
  * Written 1994-1999 by Avery Pennarun.
  * Derived from skeleton.c by Donald Becker.
@@ -34,13 +34,6 @@ extern const struct net_device_ops com20020_netdev_ops;
 /* The number of low I/O ports used by the card. */
 #define ARCNET_TOTAL_SIZE 8
 
-/* various register addresses */
-#ifdef CONFIG_SA1100_CT6001
-#define BUS_ALIGN  2  /* 8 bit device on a 16 bit bus - needs padding */
-#else
-#define BUS_ALIGN  1
-#endif
-
 #define PLX_PCI_MAX_CARDS 2
 
 struct com20020_pci_channel_map {
@@ -71,17 +64,18 @@ struct com20020_dev {
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
-  					or _SUBADR) */
+#define COM20020_REG_W_INTMASK	0	/* writable */
+#define COM20020_REG_R_STATUS	0	/* readable */
+#define COM20020_REG_W_COMMAND	1	/* standard arcnet commands */
+#define COM20020_REG_R_DIAGSTAT	1	/* diagnostic status */
+#define COM20020_REG_W_ADDR_HI	2	/* control for IO-mapped memory */
+#define COM20020_REG_W_ADDR_LO	3
+#define COM20020_REG_RW_MEMDATA	4	/* data port for IO-mapped memory */
+#define COM20020_REG_W_SUBADR	5	/* the extended port _XREG refers to */
+#define COM20020_REG_W_CONFIG	6	/* configuration */
+#define COM20020_REG_W_XREG	7	/* extra
+					 * (indexed by _CONFIG or _SUBADDR)
+					 */
 
 /* in the ADDR_HI register */
 #define RDDATAflag	0x80	/* next access is a read (not a write) */
@@ -109,37 +103,15 @@ struct com20020_dev {
 #define SUB_BUSCTL	5	/* bus control options */
 #define SUB_DMACOUNT	6	/* DMA count options */
 
-#define SET_SUBADR(x) do { \
-	if ((x) < 4) \
-	{ \
-		lp->config = (lp->config & ~0x03) | (x); \
-		SETCONF; \
-	} \
-	else \
-	{ \
-		outb(x, _SUBADR); \
-	} \
-} while (0)
-
-#undef ARCRESET
-#undef ASTATUS
-#undef ACOMMAND
-#undef AINTMASK
-
-#define ARCRESET { outb(lp->config | 0x80, _CONFIG); \
-		    udelay(5);                        \
-		    outb(lp->config , _CONFIG);       \
-                  }
-#define ARCRESET0 { outb(0x18 | 0x80, _CONFIG);   \
-		    udelay(5);                       \
-		    outb(0x18 , _CONFIG);            \
-                  }
-
-#define ASTATUS()	inb(_STATUS)
-#define ADIAGSTATUS()	inb(_DIAGSTAT)
-#define ACOMMAND(cmd)	outb((cmd),_COMMAND)
-#define AINTMASK(msk)	outb((msk),_INTMASK)
-
-#define SETCONF		outb(lp->config, _CONFIG)
+static inline void com20020_set_subaddress(struct arcnet_local *lp,
+					   int ioaddr, int val)
+{
+	if (val < 4) {
+		lp->config = (lp->config & ~0x03) | val;
+		arcnet_outb(lp->config, ioaddr, COM20020_REG_W_CONFIG);
+	} else {
+		arcnet_outb(val, ioaddr, COM20020_REG_W_SUBADR);
+	}
+}
 
 #endif /* __COM20020_H */
diff --git a/drivers/net/arcnet/com20020_cs.c b/drivers/net/arcnet/com20020_cs.c
index 5fdde69..cf607ff 100644
--- a/drivers/net/arcnet/com20020_cs.c
+++ b/drivers/net/arcnet/com20020_cs.c
@@ -56,25 +56,26 @@ static void regdump(struct net_device *dev)
 	int count;
 
 	netdev_dbg(dev, "register dump:\n");
-	for (count = ioaddr; count < ioaddr + 16; count++) {
+	for (count = 0; count < 16; count++) {
 		if (!(count % 16))
-			pr_cont("%04X:", count);
-		pr_cont(" %02X", inb(count));
+			pr_cont("%04X:", ioaddr + count);
+		pr_cont(" %02X", arcnet_inb(ioaddr, count));
 	}
 	pr_cont("\n");
 
 	netdev_dbg(dev, "buffer0 dump:\n");
 	/* set up the address register */
 	count = 0;
-	outb((count >> 8) | RDDATAflag | AUTOINCflag, _ADDR_HI);
-	outb(count & 0xff, _ADDR_LO);
+	arcnet_outb((count >> 8) | RDDATAflag | AUTOINCflag,
+		    ioaddr, com20020_REG_W_ADDR_HI);
+	arcnet_outb(count & 0xff, ioaddr, COM20020_REG_W_ADDR_LO);
 
 	for (count = 0; count < 256 + 32; count++) {
 		if (!(count % 16))
 			pr_cont("%04X:", count);
 
 		/* copy the data */
-		pr_cont(" %02X", inb(_MEMDATA));
+		pr_cont(" %02X", arcnet_inb(ioaddr, COM20020_REG_RW_MEMDATA));
 	}
 	pr_cont("\n");
 #endif
@@ -292,7 +293,9 @@ static int com20020_resume(struct pcmcia_device *link)
 		int ioaddr = dev->base_addr;
 		struct arcnet_local *lp = netdev_priv(dev);
 
-		ARCRESET;
+		arcnet_outb(lp->config | 0x80, ioaddr, COM20020_REG_W_CONFIG);
+		udelay(5);
+		arcnet_outb(lp->config, ioaddr, COM20020_REG_W_CONFIG);
 	}
 
 	return 0;
-- 
2.5.1
