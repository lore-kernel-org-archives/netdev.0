From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 06/21] ARCNET: com20020: remove unneeded macros
Date: Fri, 24 Apr 2015 19:20:40 +0200
Message-ID: <1429896055-31680-7-git-send-email-m.grzeschik@pengutronix.de>
References: <1429896055-31680-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429896055-31680-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The macros SET_SUBADR, ARCRESET, ARCRESET0, ACOMMAND, ASTATUS, AINTMASK
and ADIAGSTATUS are unnecessary indirections to the use of registers.
This patch removes them and improves the readability of the code.

Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/com20020-isa.c |  2 +-
 drivers/net/arcnet/com20020-pci.c |  2 +-
 drivers/net/arcnet/com20020.c     | 56 ++++++++++++++++++++++-----------------
 include/linux/com20020.h          | 33 -----------------------
 4 files changed, 34 insertions(+), 59 deletions(-)

diff --git a/drivers/net/arcnet/com20020-isa.c b/drivers/net/arcnet/com20020-isa.c
index d8746ca..c674511 100644
--- a/drivers/net/arcnet/com20020-isa.c
+++ b/drivers/net/arcnet/com20020-isa.c
@@ -68,7 +68,7 @@ static int __init com20020isa_probe(struct net_device *dev)
 		       ioaddr, ioaddr + ARCNET_TOTAL_SIZE - 1);
 		return -ENXIO;
 	}
-	if (ASTATUS() == 0xFF) {
+	if (inb(_STATUS) == 0xFF) {
 		BUGMSG(D_NORMAL, "IO address %x empty\n", ioaddr);
 		err = -ENODEV;
 		goto out;
diff --git a/drivers/net/arcnet/com20020-pci.c b/drivers/net/arcnet/com20020-pci.c
index 9fa4eee..18c0b1f 100644
--- a/drivers/net/arcnet/com20020-pci.c
+++ b/drivers/net/arcnet/com20020-pci.c
@@ -132,7 +132,7 @@ static int com20020pci_probe(struct pci_dev *pdev, const struct pci_device_id *i
 		lp->timeout = timeout;
 		lp->hw.owner = THIS_MODULE;
 
-		if (ASTATUS() == 0xFF) {
+		if (inb(_STATUS) == 0xFF) {
 			pr_err("IO address %Xh is empty!\n", ioaddr);
 			ret = -EIO;
 			goto out_port;
diff --git a/drivers/net/arcnet/com20020.c b/drivers/net/arcnet/com20020.c
index 0d84f6c..ed0cdd3 100644
--- a/drivers/net/arcnet/com20020.c
+++ b/drivers/net/arcnet/com20020.c
@@ -91,7 +91,10 @@ int com20020_check(struct net_device *dev)
 	int ioaddr = dev->base_addr, status;
 	struct arcnet_local *lp = netdev_priv(dev);
 
-	ARCRESET0;
+	/* reset the card */
+	outb(0x18 | 0x80, _CONFIG);
+	udelay(5);
+	outb(0x18, _CONFIG);
 	mdelay(RESETtime);
 
 	lp->setup = lp->clockm ? 0 : (lp->clockp << 1);
@@ -101,12 +104,13 @@ int com20020_check(struct net_device *dev)
 	/* Enable P1Mode for backplane mode */
 	lp->setup = lp->setup | P1MODE;
 
-	SET_SUBADR(SUB_SETUP1);
+	lp->config = (lp->config & ~0x03) | SUB_SETUP1;
+	outb(lp->config, _CONFIG);
 	outb(lp->setup, _XREG);
 
 	if (lp->clockm != 0)
 	{
-		SET_SUBADR(SUB_SETUP2);
+		outb(SUB_SETUP2, _SUBADR);
 		outb(lp->setup2, _XREG);
 
 		/* must now write the magic "restart operation" command */
@@ -116,10 +120,10 @@ int com20020_check(struct net_device *dev)
 
 	lp->config = 0x21 | (lp->timeout << 3) | (lp->backplane << 2);
 	/* set node ID to 0x42 (but transmitter is disabled, so it's okay) */
-	SETCONF;
+	outb(lp->config, _CONFIG);
 	outb(0x42, ioaddr + BUS_ALIGN*7);
 
-	status = ASTATUS();
+	status = inb(_STATUS);
 
 	if ((status & 0x99) != (NORXflag | TXFREEflag | RESETflag)) {
 		BUGMSG(D_NORMAL, "status invalid (%Xh).\n", status);
@@ -131,9 +135,9 @@ int com20020_check(struct net_device *dev)
 	outb(0x39, _CONFIG);
 	outb(inb(ioaddr + BUS_ALIGN*8), ioaddr + BUS_ALIGN*7);
 
-	ACOMMAND(CFLAGScmd | RESETclear | CONFIGclear);
+	outb((CFLAGScmd | RESETclear | CONFIGclear), _COMMAND);
 
-	status = ASTATUS();
+	status = inb(_STATUS);
 	BUGMSG(D_INIT_REASONS, "status after reset acknowledged: %X\n",
 	       status);
 
@@ -156,7 +160,8 @@ static int com20020_set_hwaddr(struct net_device *dev, void *addr)
 	struct sockaddr *hwaddr = addr;
 
 	memcpy(dev->dev_addr, hwaddr->sa_data, 1);
-	SET_SUBADR(SUB_NODE);
+	lp->config = (lp->config & ~0x03) | SUB_NODE;
+	outb(lp->config, _CONFIG);
 	outb(dev->dev_addr[0], _XREG);
 
 	return 0;
@@ -195,12 +200,13 @@ int com20020_found(struct net_device *dev, int shared)
 	if (!dev->dev_addr[0])
 		dev->dev_addr[0] = inb(ioaddr + BUS_ALIGN*8);	/* FIXME: do this some other way! */
 
-	SET_SUBADR(SUB_SETUP1);
+	lp->config = (lp->config & ~0x03) | SUB_SETUP1;
+	outb(lp->config, _CONFIG);
 	outb(lp->setup, _XREG);
 
 	if (lp->card_flags & ARC_CAN_10MBIT)
 	{
-		SET_SUBADR(SUB_SETUP2);
+		outb(SUB_SETUP2, _SUBADR);
 		outb(lp->setup2, _XREG);
 
 		/* must now write the magic "restart operation" command */
@@ -210,7 +216,7 @@ int com20020_found(struct net_device *dev, int shared)
 
 	lp->config = 0x20 | (lp->timeout << 3) | (lp->backplane << 2) | 1;
 	/* Default 0x38 + register: Node ID */
-	SETCONF;
+	outb(lp->config, _CONFIG);
 	outb(dev->dev_addr[0], _XREG);
 
 	/* reserve the irq */
@@ -259,22 +265,24 @@ static int com20020_reset(struct net_device *dev, int really_reset)
 	BUGMSG(D_DEBUG, "%s: %d: %s: dev: %p, lp: %p, dev->name: %s\n",
 		__FILE__,__LINE__,__func__,dev,lp,dev->name);
 	BUGMSG(D_INIT, "Resetting %s (status=%02Xh)\n",
-	       dev->name, ASTATUS());
+	       dev->name, inb(_STATUS));
 
 	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
 	lp->config = TXENcfg | (lp->timeout << 3) | (lp->backplane << 2);
 	/* power-up defaults */
-	SETCONF;
+	outb(lp->config, _CONFIG);
 	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
 
 	if (really_reset) {
 		/* reset the card */
-		ARCRESET;
+		outb(lp->config | 0x80, _CONFIG);
+		udelay(5);
+		outb(lp->config, _CONFIG);
 		mdelay(RESETtime * 2);	/* COM20020 seems to be slower sometimes */
 	}
 	/* clear flags & end reset */
 	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
-	ACOMMAND(CFLAGScmd | RESETclear | CONFIGclear);
+	outb((CFLAGScmd | RESETclear | CONFIGclear), _COMMAND);
 
 	/* verify that the ARCnet signature byte is present */
 	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
@@ -287,26 +295,24 @@ static int com20020_reset(struct net_device *dev, int really_reset)
 		return 1;
 	}
 	/* enable extended (512-byte) packets */
-	ACOMMAND(CONFIGcmd | EXTconf);
+	outb((CONFIGcmd | EXTconf), _COMMAND);
 	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
 
 	/* done!  return success. */
 	return 0;
 }
 
-
 static void com20020_setmask(struct net_device *dev, int mask)
 {
 	u_int ioaddr = dev->base_addr;
 	BUGMSG(D_DURING, "Setting mask to %x at %x\n",mask,ioaddr);
-	AINTMASK(mask);
+	outb((mask), _INTMASK);
 }
 
-
 static void com20020_command(struct net_device *dev, int cmd)
 {
 	u_int ioaddr = dev->base_addr;
-	ACOMMAND(cmd);
+	outb(cmd, _COMMAND);
 }
 
 
@@ -314,7 +320,7 @@ static int com20020_status(struct net_device *dev)
 {
 	u_int ioaddr = dev->base_addr;
 
-	return ASTATUS() + (ADIAGSTATUS()<<8);
+	return inb(_STATUS) + (inb(_DIAGSTAT) << 8);
 }
 
 static void com20020_close(struct net_device *dev)
@@ -324,7 +330,7 @@ static void com20020_close(struct net_device *dev)
 
 	/* disable transmitter */
 	lp->config &= ~TXENcfg;
-	SETCONF;
+	outb(lp->config, _CONFIG);
 }
 
 /* Set or clear the multicast filter for this adaptor.
@@ -342,7 +348,8 @@ static void com20020_set_mc_list(struct net_device *dev)
 	if ((dev->flags & IFF_PROMISC) && (dev->flags & IFF_UP)) {	/* Enable promiscuous mode */
 		if (!(lp->setup & PROMISCset))
 			BUGMSG(D_NORMAL, "Setting promiscuous flag...\n");
-		SET_SUBADR(SUB_SETUP1);
+		lp->config = (lp->config & ~0x03) | SUB_SETUP1;
+		outb(lp->config, _CONFIG);
 		lp->setup |= PROMISCset;
 		outb(lp->setup, _XREG);
 	} else
@@ -350,7 +357,8 @@ static void com20020_set_mc_list(struct net_device *dev)
 	{
 		if ((lp->setup & PROMISCset))
 			BUGMSG(D_NORMAL, "Resetting promiscuous flag...\n");
-		SET_SUBADR(SUB_SETUP1);
+		lp->config = (lp->config & ~0x03) | SUB_SETUP1;
+		outb(lp->config, _CONFIG);
 		lp->setup &= ~PROMISCset;
 		outb(lp->setup, _XREG);
 	}
diff --git a/include/linux/com20020.h b/include/linux/com20020.h
index 5ce5c7d..2aaa57d 100644
--- a/include/linux/com20020.h
+++ b/include/linux/com20020.h
@@ -109,37 +109,4 @@ struct com20020_dev {
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
-
 #endif /* __COM20020_H */
-- 
2.1.4
