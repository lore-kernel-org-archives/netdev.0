From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] fix arcnet module refcounting
Date: Sun, 13 Jul 2003 14:57:48 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030713125748.GA24403@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

struct arnet_local needs a struct module *owner, that also cleans
up nicely lots of the code.


--- 1.6/drivers/net/arcnet/arc-rimi.c	Sat Jun 28 08:20:41 2003
+++ edited/drivers/net/arcnet/arc-rimi.c	Thu Jul 10 16:28:29 2003
@@ -47,7 +47,6 @@
 static int arcrimi_status(struct net_device *dev);
 static void arcrimi_setmask(struct net_device *dev, int mask);
 static int arcrimi_reset(struct net_device *dev, int really_reset);
-static void arcrimi_openclose(struct net_device *dev, bool open);
 static void arcrimi_copy_to_card(struct net_device *dev, int bufnum, int offset,
 				 void *buf, int count);
 static void arcrimi_copy_from_card(struct net_device *dev, int bufnum, int offset,
@@ -179,7 +178,7 @@
 	lp->hw.status = arcrimi_status;
 	lp->hw.intmask = arcrimi_setmask;
 	lp->hw.reset = arcrimi_reset;
-	lp->hw.open_close = arcrimi_openclose;
+	lp->hw.owner = THIS_MODULE;
 	lp->hw.copy_to_card = arcrimi_copy_to_card;
 	lp->hw.copy_from_card = arcrimi_copy_from_card;
 	lp->mem_start = ioremap(dev->mem_start, dev->mem_end - dev->mem_start + 1);
@@ -252,15 +251,6 @@
 
 	/* done!  return success. */
 	return 0;
-}
-
-
-static void arcrimi_openclose(struct net_device *dev, int open)
-{
-	if (open)
-		MOD_INC_USE_COUNT;
-	else
-		MOD_DEC_USE_COUNT;
 }
 
 static void arcrimi_setmask(struct net_device *dev, int mask)
--- 1.14/drivers/net/arcnet/arcnet.c	Sun Jun 15 01:16:09 2003
+++ edited/drivers/net/arcnet/arcnet.c	Thu Jul 10 16:53:24 2003
@@ -343,7 +343,10 @@
 static int arcnet_open(struct net_device *dev)
 {
 	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
-	int count, newmtu;
+	int count, newmtu, error;
+
+	if (!try_module_get(lp->hw.owner))
+		return -ENODEV;
 
 	BUGLVL(D_PROTO) {
 		int count;
@@ -360,8 +363,9 @@
 	/* try to put the card in a defined state - if it fails the first
 	 * time, actually reset it.
 	 */
+	error = -ENODEV;
 	if (ARCRESET(0) && ARCRESET(1))
-		return -ENODEV;
+		goto out_module_put;
 
 	newmtu = choose_mtu();
 	if (newmtu < dev->mtu)
@@ -391,7 +395,7 @@
 	lp->rfc1201.sequence = 1;
 
 	/* bring up the hardware driver */
-	ARCOPEN(1);
+	lp->hw.open(dev);
 
 	if (dev->dev_addr[0] == 0)
 		BUGMSG(D_NORMAL, "WARNING!  Station address 00 is reserved "
@@ -415,6 +419,10 @@
 	netif_start_queue(dev);
 
 	return 0;
+
+ out_module_put:
+	module_put(lp->hw.owner);
+	return error;
 }
 
 
@@ -432,8 +440,8 @@
 	mdelay(1);
 
 	/* shut down the card */
-	ARCOPEN(0);
-
+	lp->hw.close(dev);
+	module_put(lp->hw.owner);
 	return 0;
 }
 
--- 1.5/drivers/net/arcnet/com20020-isa.c	Thu May 22 10:08:06 2003
+++ edited/drivers/net/arcnet/com20020-isa.c	Thu Jul 10 16:30:53 2003
@@ -131,14 +131,6 @@
 MODULE_PARM(clockm, "i");
 MODULE_LICENSE("GPL");
 
-static void com20020isa_open_close(struct net_device *dev, bool open)
-{
-	if (open)
-		MOD_INC_USE_COUNT;
-	else
-		MOD_DEC_USE_COUNT;
-}
-
 int init_module(void)
 {
 	struct net_device *dev;
@@ -160,7 +152,7 @@
 	lp->clockp = clockp & 7;
 	lp->clockm = clockm & 3;
 	lp->timeout = timeout & 3;
-	lp->hw.open_close_ll = com20020isa_open_close;
+	lp->owner = THIS_MODULE;
 
 	dev->base_addr = io;
 	dev->irq = irq;
--- 1.13/drivers/net/arcnet/com20020-pci.c	Thu May 22 10:08:06 2003
+++ edited/drivers/net/arcnet/com20020-pci.c	Thu Jul 10 16:54:28 2003
@@ -60,14 +60,6 @@
 MODULE_PARM(clockm, "i");
 MODULE_LICENSE("GPL");
 
-static void com20020pci_open_close(struct net_device *dev, bool open)
-{
-	if (open)
-		MOD_INC_USE_COUNT;
-	else
-		MOD_DEC_USE_COUNT;
-}
-
 static int __devinit com20020pci_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 {
 	struct net_device *dev;
@@ -111,7 +103,7 @@
 	lp->clockp = clockp & 7;
 	lp->clockm = clockm & 3;
 	lp->timeout = timeout;
-	lp->hw.open_close_ll = com20020pci_open_close;
+	lp->hw.owner = THIS_MODULE;
 
 	if (check_region(ioaddr, ARCNET_TOTAL_SIZE)) {
 		BUGMSG(D_INIT, "IO region %xh-%xh already allocated.\n",
--- 1.5/drivers/net/arcnet/com20020.c	Sat Feb 15 00:22:10 2003
+++ edited/drivers/net/arcnet/com20020.c	Thu Jul 10 16:33:36 2003
@@ -50,13 +50,12 @@
 static int com20020_status(struct net_device *dev);
 static void com20020_setmask(struct net_device *dev, int mask);
 static int com20020_reset(struct net_device *dev, int really_reset);
-static void com20020_openclose(struct net_device *dev, bool open);
 static void com20020_copy_to_card(struct net_device *dev, int bufnum,
 				  int offset, void *buf, int count);
 static void com20020_copy_from_card(struct net_device *dev, int bufnum,
 				    int offset, void *buf, int count);
 static void com20020_set_mc_list(struct net_device *dev);
-
+static void com20020_close(struct net_device *, bool);
 
 static void com20020_copy_from_card(struct net_device *dev, int bufnum,
 				    int offset, void *buf, int count)
@@ -162,13 +161,14 @@
 
 	lp = (struct arcnet_local *) dev->priv;
 
+	lp->hw.owner = THIS_MODULE;
 	lp->hw.command = com20020_command;
 	lp->hw.status = com20020_status;
 	lp->hw.intmask = com20020_setmask;
 	lp->hw.reset = com20020_reset;
-	lp->hw.open_close = com20020_openclose;
 	lp->hw.copy_to_card = com20020_copy_to_card;
 	lp->hw.copy_from_card = com20020_copy_from_card;
+	lp->hw.close = com20020_close;
 
 	dev->set_multicast_list = com20020_set_mc_list;
 
@@ -298,24 +298,17 @@
 	return ASTATUS();
 }
 
-
-static void com20020_openclose(struct net_device *dev, bool open)
+static void com20020_close(struct net_device *dev, bool open)
 {
 	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
 	int ioaddr = dev->base_addr;
 
-	if (open) {
-		MOD_INC_USE_COUNT;
-	}
-	else {
+	if (!open) {
 		/* disable transmitter */
 		lp->config &= ~TXENcfg;
 		SETCONF;
-		MOD_DEC_USE_COUNT;
 	}
-	lp->hw.open_close_ll(dev, open);
 }
-
 
 /* Set or clear the multicast filter for this adaptor.
  * num_addrs == -1    Promiscuous mode, receive all packets
--- 1.7/drivers/net/arcnet/com90io.c	Thu May 22 10:08:06 2003
+++ edited/drivers/net/arcnet/com90io.c	Thu Jul 10 16:28:29 2003
@@ -47,7 +47,6 @@
 static int com90io_status(struct net_device *dev);
 static void com90io_setmask(struct net_device *dev, int mask);
 static int com90io_reset(struct net_device *dev, int really_reset);
-static void com90io_openclose(struct net_device *dev, bool open);
 static void com90io_copy_to_card(struct net_device *dev, int bufnum, int offset,
 				 void *buf, int count);
 static void com90io_copy_from_card(struct net_device *dev, int bufnum, int offset,
@@ -257,7 +256,7 @@
 	lp->hw.status = com90io_status;
 	lp->hw.intmask = com90io_setmask;
 	lp->hw.reset = com90io_reset;
-	lp->hw.open_close = com90io_openclose;
+	lp->hw.owner = THIS_MODULE;
 	lp->hw.copy_to_card = com90io_copy_to_card;
 	lp->hw.copy_from_card = com90io_copy_from_card;
 
@@ -342,14 +341,6 @@
 	short ioaddr = dev->base_addr;
 
 	AINTMASK(mask);
-}
-
-static void com90io_openclose(struct net_device *dev, int open)
-{
-	if (open)
-		MOD_INC_USE_COUNT;
-	else
-		MOD_DEC_USE_COUNT;
 }
 
 static void com90io_copy_to_card(struct net_device *dev, int bufnum, int offset,
--- 1.7/drivers/net/arcnet/com90xx.c	Thu May 22 10:08:06 2003
+++ edited/drivers/net/arcnet/com90xx.c	Thu Jul 10 16:28:29 2003
@@ -58,7 +58,6 @@
 static int com90xx_status(struct net_device *dev);
 static void com90xx_setmask(struct net_device *dev, int mask);
 static int com90xx_reset(struct net_device *dev, int really_reset);
-static void com90xx_openclose(struct net_device *dev, bool open);
 static void com90xx_copy_to_card(struct net_device *dev, int bufnum, int offset,
 				 void *buf, int count);
 static void com90xx_copy_from_card(struct net_device *dev, int bufnum, int offset,
@@ -450,7 +449,7 @@
 	lp->hw.status = com90xx_status;
 	lp->hw.intmask = com90xx_setmask;
 	lp->hw.reset = com90xx_reset;
-	lp->hw.open_close = com90xx_openclose;
+	lp->hw.owner = THIS_MODULE;
 	lp->hw.copy_to_card = com90xx_copy_to_card;
 	lp->hw.copy_from_card = com90xx_copy_from_card;
 	lp->mem_start = ioremap(dev->mem_start, dev->mem_end - dev->mem_start + 1);
@@ -569,16 +568,6 @@
 	/* done!  return success. */
 	return 0;
 }
-
-
-static void com90xx_openclose(struct net_device *dev, bool open)
-{
-	if (open)
-		MOD_INC_USE_COUNT;
-	else
-		MOD_DEC_USE_COUNT;
-}
-
 
 static void com90xx_copy_to_card(struct net_device *dev, int bufnum, int offset,
 				 void *buf, int count)
--- 1.4/include/linux/arcdevice.h	Sun Jun 15 01:16:09 2003
+++ edited/include/linux/arcdevice.h	Thu Jul 10 16:48:24 2003
@@ -291,12 +291,13 @@
 
 	/* hardware-specific functions */
 	struct {
+		struct module *owner;
 		void (*command) (struct net_device * dev, int cmd);
 		int (*status) (struct net_device * dev);
 		void (*intmask) (struct net_device * dev, int mask);
 		bool (*reset) (struct net_device * dev, bool really_reset);
-		void (*open_close) (struct net_device * dev, bool open);
-		void (*open_close_ll) (struct net_device * dev, bool open);
+		void (*open) (struct net_device * dev);
+		void (*close) (struct net_device * dev);
 
 		void (*copy_to_card) (struct net_device * dev, int bufnum, int offset,
 				      void *buf, int count);
@@ -312,7 +313,6 @@
 #define ACOMMAND(x)  (lp->hw.command(dev, (x)))
 #define ASTATUS()    (lp->hw.status(dev))
 #define AINTMASK(x)  (lp->hw.intmask(dev, (x)))
-#define ARCOPEN(x)   (lp->hw.open_close(dev, (x)))
 
 
 
