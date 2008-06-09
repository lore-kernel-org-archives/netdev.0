From: akpm@linux-foundation.org
Subject: [patch 04/13] 8390: Split 8390 support into a pausing and a non pausing driver core
Date: Mon, 09 Jun 2008 16:33:49 -0700
Message-ID: <200806092333.m59NXnTe014676@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	alan@lxorguk.ukuu.org.uk, alan@redhat.com, randy.dunlap@oracle.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:45869 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757462AbYFIXej (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2008 19:34:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@lxorguk.ukuu.org.uk>

Only a few ISA controllers need the pausing version of the 8390 core
while PCMCIA, later ISA and PCI do not. More importantly the ISA delays
can break non ISA boxes so we must use a different build of 8390.c for
the two sets of controllers.

No changes since last time as all the points of concerns raised proved to
be invalid

[randy.dunlap@oracle.com: ne2 (MCA) needs both 8390.o and 8390p.o functions]
Signed-off-by: Alan Cox <alan@redhat.com>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/3c503.c  |   14 ++++----
 drivers/net/8390.h   |   18 +++++++++--
 drivers/net/8390p.c  |   66 +++++++++++++++++++++++++++++++++++++++++
 drivers/net/Makefile |   10 +++---
 drivers/net/hp.c     |   14 ++++----
 drivers/net/ne.c     |   14 ++++----
 drivers/net/ne2.c    |   12 +++----
 7 files changed, 114 insertions(+), 34 deletions(-)

diff -puN drivers/net/3c503.c~8390-split-8390-support-into-a-pausing-and-a-non-pausing-driver-core drivers/net/3c503.c
--- a/drivers/net/3c503.c~8390-split-8390-support-into-a-pausing-and-a-non-pausing-driver-core
+++ a/drivers/net/3c503.c
@@ -149,7 +149,7 @@ el2_pio_probe(struct net_device *dev)
 #ifndef MODULE
 struct net_device * __init el2_probe(int unit)
 {
-	struct net_device *dev = alloc_ei_netdev();
+	struct net_device *dev = alloc_eip_netdev();
 	int err;
 
 	if (!dev)
@@ -340,7 +340,7 @@ el2_probe1(struct net_device *dev, int i
     dev->stop = &el2_close;
     dev->ethtool_ops = &netdev_ethtool_ops;
 #ifdef CONFIG_NET_POLL_CONTROLLER
-    dev->poll_controller = ei_poll;
+    dev->poll_controller = eip_poll;
 #endif
 
     retval = register_netdev(dev);
@@ -386,7 +386,7 @@ el2_open(struct net_device *dev)
 		outb_p(0x00, E33G_IDCFR);
 		if (*irqp == probe_irq_off(cookie)	/* It's a good IRQ line! */
 		    && ((retval = request_irq(dev->irq = *irqp,
-		    ei_interrupt, 0, dev->name, dev)) == 0))
+		    eip_interrupt, 0, dev->name, dev)) == 0))
 		    break;
 	    }
 	} while (*++irqp);
@@ -395,13 +395,13 @@ el2_open(struct net_device *dev)
 	    return retval;
 	}
     } else {
-	if ((retval = request_irq(dev->irq, ei_interrupt, 0, dev->name, dev))) {
+	if ((retval = request_irq(dev->irq, eip_interrupt, 0, dev->name, dev))) {
 	    return retval;
 	}
     }
 
     el2_init_card(dev);
-    ei_open(dev);
+    eip_open(dev);
     return 0;
 }
 
@@ -412,7 +412,7 @@ el2_close(struct net_device *dev)
     dev->irq = ei_status.saved_irq;
     outb(EGACFR_IRQOFF, E33G_GACFR);	/* disable interrupts. */
 
-    ei_close(dev);
+    eip_close(dev);
     return 0;
 }
 
@@ -698,7 +698,7 @@ init_module(void)
 			if (this_dev != 0) break; /* only autoprobe 1st one */
 			printk(KERN_NOTICE "3c503.c: Presently autoprobing (not recommended) for a single card.\n");
 		}
-		dev = alloc_ei_netdev();
+		dev = alloc_eip_netdev();
 		if (!dev)
 			break;
 		dev->irq = irq[this_dev];
diff -puN drivers/net/8390.h~8390-split-8390-support-into-a-pausing-and-a-non-pausing-driver-core drivers/net/8390.h
--- a/drivers/net/8390.h~8390-split-8390-support-into-a-pausing-and-a-non-pausing-driver-core
+++ a/drivers/net/8390.h
@@ -30,8 +30,10 @@ extern int ei_debug;
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
 extern void ei_poll(struct net_device *dev);
+extern void eip_poll(struct net_device *dev);
 #endif
 
+/* Without I/O delay - non ISA or later chips */
 extern void NS8390_init(struct net_device *dev, int startp);
 extern int ei_open(struct net_device *dev);
 extern int ei_close(struct net_device *dev);
@@ -42,6 +44,17 @@ static inline struct net_device *alloc_e
 	return __alloc_ei_netdev(0);
 }
 
+/* With I/O delay form */
+extern void NS8390p_init(struct net_device *dev, int startp);
+extern int eip_open(struct net_device *dev);
+extern int eip_close(struct net_device *dev);
+extern irqreturn_t eip_interrupt(int irq, void *dev_id);
+extern struct net_device *__alloc_eip_netdev(int size);
+static inline struct net_device *alloc_eip_netdev(void)
+{
+	return __alloc_eip_netdev(0);
+}
+
 /* You have one of these per-board */
 struct ei_device {
 	const char *name;
@@ -115,13 +128,14 @@ struct ei_device {
 /*
  *	Only generate indirect loads given a machine that needs them.
  *      - removed AMIGA_PCMCIA from this list, handled as ISA io now
+ *	- the _p for generates no delay by default 8390p.c overrides this.
  */
 
 #ifndef ei_inb
 #define ei_inb(_p)	inb(_p)
 #define ei_outb(_v,_p)	outb(_v,_p)
-#define ei_inb_p(_p)	inb_p(_p)
-#define ei_outb_p(_v,_p) outb_p(_v,_p)
+#define ei_inb_p(_p)	inb(_p)
+#define ei_outb_p(_v,_p) outb(_v,_p)
 #endif
 
 #ifndef EI_SHIFT
diff -puN /dev/null drivers/net/8390p.c
--- /dev/null
+++ a/drivers/net/8390p.c
@@ -0,0 +1,66 @@
+/* 8390 core for ISA devices needing bus delays */
+
+static const char version[] =
+    "8390p.c:v1.10cvs 9/23/94 Donald Becker (becker@cesdis.gsfc.nasa.gov)\n";
+
+#define ei_inb(_p)	inb(_p)
+#define ei_outb(_v,_p)	outb(_v,_p)
+#define ei_inb_p(_p)	inb_p(_p)
+#define ei_outb_p(_v,_p) outb_p(_v,_p)
+
+#include "lib8390.c"
+
+int eip_open(struct net_device *dev)
+{
+	return __ei_open(dev);
+}
+
+int eip_close(struct net_device *dev)
+{
+	return __ei_close(dev);
+}
+
+irqreturn_t eip_interrupt(int irq, void *dev_id)
+{
+	return __ei_interrupt(irq, dev_id);
+}
+
+#ifdef CONFIG_NET_POLL_CONTROLLER
+void eip_poll(struct net_device *dev)
+{
+	__ei_poll(dev);
+}
+#endif
+
+struct net_device *__alloc_eip_netdev(int size)
+{
+	return ____alloc_ei_netdev(size);
+}
+
+void NS8390p_init(struct net_device *dev, int startp)
+{
+	return __NS8390_init(dev, startp);
+}
+
+EXPORT_SYMBOL(eip_open);
+EXPORT_SYMBOL(eip_close);
+EXPORT_SYMBOL(eip_interrupt);
+#ifdef CONFIG_NET_POLL_CONTROLLER
+EXPORT_SYMBOL(eip_poll);
+#endif
+EXPORT_SYMBOL(NS8390p_init);
+EXPORT_SYMBOL(__alloc_eip_netdev);
+
+#if defined(MODULE)
+
+int init_module(void)
+{
+	return 0;
+}
+
+void cleanup_module(void)
+{
+}
+
+#endif /* MODULE */
+MODULE_LICENSE("GPL");
diff -puN drivers/net/Makefile~8390-split-8390-support-into-a-pausing-and-a-non-pausing-driver-core drivers/net/Makefile
--- a/drivers/net/Makefile~8390-split-8390-support-into-a-pausing-and-a-non-pausing-driver-core
+++ a/drivers/net/Makefile
@@ -105,11 +105,11 @@ ifeq ($(CONFIG_FEC_MPC52xx_MDIO),y)
 endif
 obj-$(CONFIG_68360_ENET) += 68360enet.o
 obj-$(CONFIG_WD80x3) += wd.o 8390.o
-obj-$(CONFIG_EL2) += 3c503.o 8390.o
-obj-$(CONFIG_NE2000) += ne.o 8390.o
-obj-$(CONFIG_NE2_MCA) += ne2.o 8390.o
-obj-$(CONFIG_HPLAN) += hp.o 8390.o
-obj-$(CONFIG_HPLAN_PLUS) += hp-plus.o 8390.o
+obj-$(CONFIG_EL2) += 3c503.o 8390p.o
+obj-$(CONFIG_NE2000) += ne.o 8390p.o
+obj-$(CONFIG_NE2_MCA) += ne2.o 8390.o 8390p.o
+obj-$(CONFIG_HPLAN) += hp.o 8390p.o
+obj-$(CONFIG_HPLAN_PLUS) += hp-plus.o 8390p.o
 obj-$(CONFIG_ULTRA) += smc-ultra.o 8390.o
 obj-$(CONFIG_ULTRAMCA) += smc-mca.o 8390.o
 obj-$(CONFIG_ULTRA32) += smc-ultra32.o 8390.o
diff -puN drivers/net/hp.c~8390-split-8390-support-into-a-pausing-and-a-non-pausing-driver-core drivers/net/hp.c
--- a/drivers/net/hp.c~8390-split-8390-support-into-a-pausing-and-a-non-pausing-driver-core
+++ a/drivers/net/hp.c
@@ -103,7 +103,7 @@ static int __init do_hp_probe(struct net
 #ifndef MODULE
 struct net_device * __init hp_probe(int unit)
 {
-	struct net_device *dev = alloc_ei_netdev();
+	struct net_device *dev = alloc_eip_netdev();
 	int err;
 
 	if (!dev)
@@ -176,7 +176,7 @@ static int __init hp_probe1(struct net_d
 				outb_p(irqmap[irq] | HP_RUN, ioaddr + HP_CONFIGURE);
 				outb_p( 0x00 | HP_RUN, ioaddr + HP_CONFIGURE);
 				if (irq == probe_irq_off(cookie)		 /* It's a good IRQ line! */
-					&& request_irq (irq, ei_interrupt, 0, DRV_NAME, dev) == 0) {
+					&& request_irq (irq, eip_interrupt, 0, DRV_NAME, dev) == 0) {
 					printk(" selecting IRQ %d.\n", irq);
 					dev->irq = *irqp;
 					break;
@@ -191,7 +191,7 @@ static int __init hp_probe1(struct net_d
 	} else {
 		if (dev->irq == 2)
 			dev->irq = 9;
-		if ((retval = request_irq(dev->irq, ei_interrupt, 0, DRV_NAME, dev))) {
+		if ((retval = request_irq(dev->irq, eip_interrupt, 0, DRV_NAME, dev))) {
 			printk (" unable to get IRQ %d.\n", dev->irq);
 			goto out;
 		}
@@ -202,7 +202,7 @@ static int __init hp_probe1(struct net_d
 	dev->open = &hp_open;
 	dev->stop = &hp_close;
 #ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = ei_poll;
+	dev->poll_controller = eip_poll;
 #endif
 
 	ei_status.name = name;
@@ -231,14 +231,14 @@ out:
 static int
 hp_open(struct net_device *dev)
 {
-	ei_open(dev);
+	eip_open(dev);
 	return 0;
 }
 
 static int
 hp_close(struct net_device *dev)
 {
-	ei_close(dev);
+	eip_close(dev);
 	return 0;
 }
 
@@ -421,7 +421,7 @@ init_module(void)
 			if (this_dev != 0) break; /* only autoprobe 1st one */
 			printk(KERN_NOTICE "hp.c: Presently autoprobing (not recommended) for a single card.\n");
 		}
-		dev = alloc_ei_netdev();
+		dev = alloc_eip_netdev();
 		if (!dev)
 			break;
 		dev->irq = irq[this_dev];
diff -puN drivers/net/ne.c~8390-split-8390-support-into-a-pausing-and-a-non-pausing-driver-core drivers/net/ne.c
--- a/drivers/net/ne.c~8390-split-8390-support-into-a-pausing-and-a-non-pausing-driver-core
+++ a/drivers/net/ne.c
@@ -217,7 +217,7 @@ static int __init do_ne_probe(struct net
 #ifndef MODULE
 struct net_device * __init ne_probe(int unit)
 {
-	struct net_device *dev = alloc_ei_netdev();
+	struct net_device *dev = alloc_eip_netdev();
 	int err;
 
 	if (!dev)
@@ -490,7 +490,7 @@ static int __init ne_probe1(struct net_d
 
 	/* Snarf the interrupt now.  There's no point in waiting since we cannot
 	   share and the board will usually be enabled. */
-	ret = request_irq(dev->irq, ei_interrupt, 0, name, dev);
+	ret = request_irq(dev->irq, eip_interrupt, 0, name, dev);
 	if (ret) {
 		printk (" unable to get IRQ %d (errno=%d).\n", dev->irq, ret);
 		goto err_out;
@@ -534,7 +534,7 @@ static int __init ne_probe1(struct net_d
 	dev->open = &ne_open;
 	dev->stop = &ne_close;
 #ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = ei_poll;
+	dev->poll_controller = eip_poll;
 #endif
 	NS8390_init(dev, 0);
 
@@ -554,7 +554,7 @@ err_out:
 
 static int ne_open(struct net_device *dev)
 {
-	ei_open(dev);
+	eip_open(dev);
 	return 0;
 }
 
@@ -562,7 +562,7 @@ static int ne_close(struct net_device *d
 {
 	if (ei_debug > 1)
 		printk(KERN_DEBUG "%s: Shutting down ethercard.\n", dev->name);
-	ei_close(dev);
+	eip_close(dev);
 	return 0;
 }
 
@@ -814,7 +814,7 @@ static int __init ne_drv_probe(struct pl
 	if (!res || irq < 0)
 		return -ENODEV;
 
-	dev = alloc_ei_netdev();
+	dev = alloc_eip_netdev();
 	if (!dev)
 		return -ENOMEM;
 	dev->irq = irq;
@@ -912,7 +912,7 @@ int __init init_module(void)
 	int plat_found = !ne_init();
 
 	for (this_dev = 0; this_dev < MAX_NE_CARDS; this_dev++) {
-		struct net_device *dev = alloc_ei_netdev();
+		struct net_device *dev = alloc_eip_netdev();
 		if (!dev)
 			break;
 		dev->irq = irq[this_dev];
diff -puN drivers/net/ne2.c~8390-split-8390-support-into-a-pausing-and-a-non-pausing-driver-core drivers/net/ne2.c
--- a/drivers/net/ne2.c~8390-split-8390-support-into-a-pausing-and-a-non-pausing-driver-core
+++ a/drivers/net/ne2.c
@@ -280,7 +280,7 @@ static int __init do_ne2_probe(struct ne
 #ifndef MODULE
 struct net_device * __init ne2_probe(int unit)
 {
-	struct net_device *dev = alloc_ei_netdev();
+	struct net_device *dev = alloc_eip_netdev();
 	int err;
 
 	if (!dev)
@@ -457,7 +457,7 @@ static int __init ne2_probe1(struct net_
 
 	/* Snarf the interrupt now.  There's no point in waiting since we cannot
 	   share and the board will usually be enabled. */
-	retval = request_irq(dev->irq, ei_interrupt, 0, DRV_NAME, dev);
+	retval = request_irq(dev->irq, eip_interrupt, 0, DRV_NAME, dev);
 	if (retval) {
 		printk (" unable to get IRQ %d (irqval=%d).\n",
 				dev->irq, retval);
@@ -497,7 +497,7 @@ static int __init ne2_probe1(struct net_
 	dev->open = &ne_open;
 	dev->stop = &ne_close;
 #ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = ei_poll;
+	dev->poll_controller = eip_poll;
 #endif
 	NS8390_init(dev, 0);
 
@@ -515,7 +515,7 @@ out:
 
 static int ne_open(struct net_device *dev)
 {
-	ei_open(dev);
+	eip_open(dev);
 	return 0;
 }
 
@@ -523,7 +523,7 @@ static int ne_close(struct net_device *d
 {
 	if (ei_debug > 1)
 		printk("%s: Shutting down ethercard.\n", dev->name);
-	ei_close(dev);
+	eip_close(dev);
 	return 0;
 }
 
@@ -781,7 +781,7 @@ int __init init_module(void)
 	int this_dev, found = 0;
 
 	for (this_dev = 0; this_dev < MAX_NE_CARDS; this_dev++) {
-		dev = alloc_ei_netdev();
+		dev = alloc_eip_netdev();
 		if (!dev)
 			break;
 		dev->irq = irq[this_dev];
_
