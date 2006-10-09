From: Al Viro <viro@ftp.linux.org.uk>
Subject: [PATCH 2/4] 8390 fixes - m68k oddballs
Date: Tue, 10 Oct 2006 00:19:36 +0100
Message-ID: <E1GX4PI-0005Mh-CI@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:53738 "EHLO
	ZenIV.linux.org.uk") by vger.kernel.org with ESMTP id S1751927AbWJIXTh
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Oct 2006 19:19:37 -0400
To: jgarzik@pobox.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


more 8390 conversions - mac8390, zorro8390 and hydra got the same treatment
as arm etherh; one more case in 8390.h ifdef cascade is gone.

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 drivers/net/8390.h      |   16 +---------------
 drivers/net/Makefile    |    6 +++---
 drivers/net/hydra.c     |   23 ++++++++++++++++-------
 drivers/net/mac8390.c   |   26 ++++++++++++++++----------
 drivers/net/zorro8390.c |   24 ++++++++++++++++--------
 5 files changed, 52 insertions(+), 43 deletions(-)

diff --git a/drivers/net/8390.h b/drivers/net/8390.h
index fae4aa9..b8991fc 100644
--- a/drivers/net/8390.h
+++ b/drivers/net/8390.h
@@ -107,21 +107,7 @@ #define E8390_PAGE2	0x80	/* Page 3 is in
  *      - removed AMIGA_PCMCIA from this list, handled as ISA io now
  */
 
-#if defined(CONFIG_MAC) ||  \
-    defined(CONFIG_ZORRO8390) || defined(CONFIG_ZORRO8390_MODULE) || \
-    defined(CONFIG_HYDRA) || defined(CONFIG_HYDRA_MODULE)
-#define EI_SHIFT(x)	(ei_local->reg_offset[x])
-#undef inb
-#undef inb_p
-#undef outb
-#undef outb_p
-
-#define ei_inb(port)   in_8(port)
-#define ei_outb(val,port)  out_8(port,val)
-#define ei_inb_p(port)   in_8(port)
-#define ei_outb_p(val,port)  out_8(port,val)
-
-#elif defined(CONFIG_NE_H8300) || defined(CONFIG_NE_H8300_MODULE)
+#if defined(CONFIG_NE_H8300) || defined(CONFIG_NE_H8300_MODULE)
 #define EI_SHIFT(x)	(ei_local->reg_offset[x])
 #endif
 
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 53ccc33..42bf31e 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -82,7 +82,7 @@ obj-$(CONFIG_HAMACHI) += hamachi.o
 obj-$(CONFIG_NET) += Space.o loopback.o
 obj-$(CONFIG_SEEQ8005) += seeq8005.o
 obj-$(CONFIG_NET_SB1000) += sb1000.o
-obj-$(CONFIG_MAC8390) += mac8390.o 8390.o
+obj-$(CONFIG_MAC8390) += mac8390.o
 obj-$(CONFIG_APNE) += apne.o 8390.o
 obj-$(CONFIG_PCMCIA_PCNET) += 8390.o
 obj-$(CONFIG_SHAPER) += shaper.o
@@ -164,7 +164,7 @@ # This is also a 82596 and should probab
 obj-$(CONFIG_LP486E) += lp486e.o
 
 obj-$(CONFIG_ETH16I) += eth16i.o
-obj-$(CONFIG_ZORRO8390) += zorro8390.o 8390.o
+obj-$(CONFIG_ZORRO8390) += zorro8390.o
 obj-$(CONFIG_HPLANCE) += hplance.o 7990.o
 obj-$(CONFIG_MVME147_NET) += mvme147.o 7990.o
 obj-$(CONFIG_EQUALIZER) += eql.o
@@ -177,7 +177,7 @@ obj-$(CONFIG_ATARILANCE) += atarilance.o
 obj-$(CONFIG_ATARI_BIONET) += atari_bionet.o
 obj-$(CONFIG_ATARI_PAMSNET) += atari_pamsnet.o
 obj-$(CONFIG_A2065) += a2065.o
-obj-$(CONFIG_HYDRA) += hydra.o 8390.o
+obj-$(CONFIG_HYDRA) += hydra.o
 obj-$(CONFIG_ARIADNE) += ariadne.o
 obj-$(CONFIG_CS89x0) += cs89x0.o
 obj-$(CONFIG_MACSONIC) += macsonic.o
diff --git a/drivers/net/hydra.c b/drivers/net/hydra.c
index 91326ea..f970bfb 100644
--- a/drivers/net/hydra.c
+++ b/drivers/net/hydra.c
@@ -31,7 +31,16 @@ #include <asm/amigaints.h>
 #include <asm/amigahw.h>
 #include <linux/zorro.h>
 
-#include "8390.h"
+#define EI_SHIFT(x)	(ei_local->reg_offset[x])
+#define ei_inb(port)   in_8(port)
+#define ei_outb(val,port)  out_8(port,val)
+#define ei_inb_p(port)   in_8(port)
+#define ei_outb_p(val,port)  out_8(port,val)
+
+static const char version[] =
+    "8390.c:v1.10cvs 9/23/94 Donald Becker (becker@cesdis.gsfc.nasa.gov)\n";
+
+#include "lib8390.c"
 
 #define NE_EN0_DCFG     (0x0e*2)
 
@@ -100,7 +109,7 @@ static int __devinit hydra_init(struct z
 	0x10, 0x12, 0x14, 0x16, 0x18, 0x1a, 0x1c, 0x1e,
     };
 
-    dev = alloc_ei_netdev();
+    dev = ____alloc_ei_netdev(0);
     if (!dev)
 	return -ENOMEM;
     SET_MODULE_OWNER(dev);
@@ -117,7 +126,7 @@ static int __devinit hydra_init(struct z
     dev->irq = IRQ_AMIGA_PORTS;
 
     /* Install the Interrupt handler */
-    if (request_irq(IRQ_AMIGA_PORTS, ei_interrupt, IRQF_SHARED, "Hydra Ethernet",
+    if (request_irq(IRQ_AMIGA_PORTS, __ei_interrupt, IRQF_SHARED, "Hydra Ethernet",
 		    dev)) {
 	free_netdev(dev);
 	return -EAGAIN;
@@ -139,10 +148,10 @@ static int __devinit hydra_init(struct z
     dev->open = &hydra_open;
     dev->stop = &hydra_close;
 #ifdef CONFIG_NET_POLL_CONTROLLER
-    dev->poll_controller = ei_poll;
+    dev->poll_controller = __ei_poll;
 #endif
 
-    NS8390_init(dev, 0);
+    __NS8390_init(dev, 0);
 
     err = register_netdev(dev);
     if (err) {
@@ -164,7 +173,7 @@ #endif
 
 static int hydra_open(struct net_device *dev)
 {
-    ei_open(dev);
+    __ei_open(dev);
     return 0;
 }
 
@@ -172,7 +181,7 @@ static int hydra_close(struct net_device
 {
     if (ei_debug > 1)
 	printk(KERN_DEBUG "%s: Shutting down ethercard.\n", dev->name);
-    ei_close(dev);
+    __ei_close(dev);
     return 0;
 }
 
diff --git a/drivers/net/mac8390.c b/drivers/net/mac8390.c
index ade6ff8..a12bb64 100644
--- a/drivers/net/mac8390.c
+++ b/drivers/net/mac8390.c
@@ -39,7 +39,16 @@ #include <asm/dma.h>
 #include <asm/hwtest.h>
 #include <asm/macints.h>
 
-#include "8390.h"
+static char version[] =
+	"mac8390.c: v0.4 2001-05-15 David Huggins-Daines <dhd@debian.org> and others\n";
+
+#define EI_SHIFT(x)	(ei_local->reg_offset[x])
+#define ei_inb(port)   in_8(port)
+#define ei_outb(val,port)  out_8(port,val)
+#define ei_inb_p(port)   in_8(port)
+#define ei_outb_p(val,port)  out_8(port,val)
+
+#include "lib8390.c"
 
 #define WD_START_PG			0x00	/* First page of TX buffer */
 #define CABLETRON_RX_START_PG		0x00    /* First page of RX buffer */
@@ -116,9 +125,6 @@ static int useresources[] = {
 	1, /* dayna-lc */
 };
 
-static char version[] __initdata =
-	"mac8390.c: v0.4 2001-05-15 David Huggins-Daines <dhd@debian.org> and others\n";
-
 extern enum mac8390_type mac8390_ident(struct nubus_dev * dev);
 extern int mac8390_memsize(unsigned long membase);
 extern int mac8390_memtest(struct net_device * dev);
@@ -237,7 +243,7 @@ struct net_device * __init mac8390_probe
 	if (!MACH_IS_MAC)
 		return ERR_PTR(-ENODEV);
 
-	dev = alloc_ei_netdev();
+	dev = ____alloc_ei_netdev(0);
 	if (!dev)
 		return ERR_PTR(-ENOMEM);
 
@@ -438,7 +444,7 @@ static int __init mac8390_initdev(struct
 	dev->open = &mac8390_open;
 	dev->stop = &mac8390_close;
 #ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = ei_poll;
+	dev->poll_controller = __ei_poll;
 #endif
 
 	/* GAR, ei_status is actually a macro even though it looks global */
@@ -510,7 +516,7 @@ #endif
 		return -ENODEV;
 	}
 
-	NS8390_init(dev, 0);
+	__NS8390_init(dev, 0);
 
 	/* Good, done, now spit out some messages */
 	printk(KERN_INFO "%s: %s in slot %X (type %s)\n",
@@ -532,8 +538,8 @@ #endif
 
 static int mac8390_open(struct net_device *dev)
 {
-	ei_open(dev);
-	if (request_irq(dev->irq, ei_interrupt, 0, "8390 Ethernet", dev)) {
+	__ei_open(dev);
+	if (request_irq(dev->irq, __ei_interrupt, 0, "8390 Ethernet", dev)) {
 		printk ("%s: unable to get IRQ %d.\n", dev->name, dev->irq);
 		return -EAGAIN;
 	}
@@ -543,7 +549,7 @@ static int mac8390_open(struct net_devic
 static int mac8390_close(struct net_device *dev)
 {
 	free_irq(dev->irq, dev);
-	ei_close(dev);
+	__ei_close(dev);
 	return 0;
 }
 
diff --git a/drivers/net/zorro8390.c b/drivers/net/zorro8390.c
index df04e05..d85e2ea 100644
--- a/drivers/net/zorro8390.c
+++ b/drivers/net/zorro8390.c
@@ -34,8 +34,16 @@ #include <asm/irq.h>
 #include <asm/amigaints.h>
 #include <asm/amigahw.h>
 
-#include "8390.h"
+#define EI_SHIFT(x)	(ei_local->reg_offset[x])
+#define ei_inb(port)   in_8(port)
+#define ei_outb(val,port)  out_8(port,val)
+#define ei_inb_p(port)   in_8(port)
+#define ei_outb_p(val,port)  out_8(port,val)
 
+static const char version[] =
+    "8390.c:v1.10cvs 9/23/94 Donald Becker (becker@cesdis.gsfc.nasa.gov)\n";
+
+#include "lib8390.c"
 
 #define DRV_NAME	"zorro8390"
 
@@ -114,7 +122,7 @@ static int __devinit zorro8390_init_one(
 	    break;
     board = z->resource.start;
     ioaddr = board+cards[i].offset;
-    dev = alloc_ei_netdev();
+    dev = ____alloc_ei_netdev(0);
     if (!dev)
 	return -ENOMEM;
     SET_MODULE_OWNER(dev);
@@ -201,7 +209,7 @@ static int __devinit zorro8390_init(stru
     dev->irq = IRQ_AMIGA_PORTS;
 
     /* Install the Interrupt handler */
-    i = request_irq(IRQ_AMIGA_PORTS, ei_interrupt, IRQF_SHARED, DRV_NAME, dev);
+    i = request_irq(IRQ_AMIGA_PORTS, __ei_interrupt, IRQF_SHARED, DRV_NAME, dev);
     if (i) return i;
 
     for(i = 0; i < ETHER_ADDR_LEN; i++) {
@@ -226,10 +234,10 @@ #endif
     dev->open = &zorro8390_open;
     dev->stop = &zorro8390_close;
 #ifdef CONFIG_NET_POLL_CONTROLLER
-    dev->poll_controller = ei_poll;
+    dev->poll_controller = __ei_poll;
 #endif
 
-    NS8390_init(dev, 0);
+    __NS8390_init(dev, 0);
     err = register_netdev(dev);
     if (err) {
 	free_irq(IRQ_AMIGA_PORTS, dev);
@@ -246,7 +254,7 @@ #endif
 
 static int zorro8390_open(struct net_device *dev)
 {
-    ei_open(dev);
+    __ei_open(dev);
     return 0;
 }
 
@@ -254,7 +262,7 @@ static int zorro8390_close(struct net_de
 {
     if (ei_debug > 1)
 	printk(KERN_DEBUG "%s: Shutting down ethercard.\n", dev->name);
-    ei_close(dev);
+    __ei_close(dev);
     return 0;
 }
 
@@ -405,7 +413,7 @@ static void zorro8390_block_output(struc
 		printk(KERN_ERR "%s: timeout waiting for Tx RDC.\n",
 		       dev->name);
 		zorro8390_reset_8390(dev);
-		NS8390_init(dev,1);
+		__NS8390_init(dev,1);
 		break;
 	}
 
-- 
1.4.2.GIT


