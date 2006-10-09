From: Al Viro <viro@ftp.linux.org.uk>
Subject: [PATCH 4/4] 8390 fixes - the final chunk (h8300)
Date: Tue, 10 Oct 2006 00:19:36 +0100
Message-ID: <E1GX4PI-0005Ml-CT@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:53482 "EHLO
	ZenIV.linux.org.uk") by vger.kernel.org with ESMTP id S1751925AbWJIXTh
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Oct 2006 19:19:37 -0400
To: jgarzik@pobox.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The rest of 8390 conversions; ifdef cascade in 8390.h is gone now.

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 drivers/net/8390.h     |    4 ----
 drivers/net/Makefile   |    2 +-
 drivers/net/ne-h8300.c |   23 +++++++++++++++--------
 3 files changed, 16 insertions(+), 13 deletions(-)

diff --git a/drivers/net/8390.h b/drivers/net/8390.h
index b8991fc..414de5b 100644
--- a/drivers/net/8390.h
+++ b/drivers/net/8390.h
@@ -107,10 +107,6 @@ #define E8390_PAGE2	0x80	/* Page 3 is in
  *      - removed AMIGA_PCMCIA from this list, handled as ISA io now
  */
 
-#if defined(CONFIG_NE_H8300) || defined(CONFIG_NE_H8300_MODULE)
-#define EI_SHIFT(x)	(ei_local->reg_offset[x])
-#endif
-
 #ifndef ei_inb
 #define ei_inb(_p)	inb(_p)
 #define ei_outb(_v,_p)	outb(_v,_p)
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 42bf31e..7d36184 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -106,7 +106,7 @@ obj-$(CONFIG_NE3210) += ne3210.o 8390.o
 obj-$(CONFIG_NET_SB1250_MAC) += sb1250-mac.o
 obj-$(CONFIG_B44) += b44.o
 obj-$(CONFIG_FORCEDETH) += forcedeth.o
-obj-$(CONFIG_NE_H8300) += ne-h8300.o 8390.o
+obj-$(CONFIG_NE_H8300) += ne-h8300.o
 
 obj-$(CONFIG_MV643XX_ETH) += mv643xx_eth.o
 obj-$(CONFIG_QLA3XXX) += qla3xxx.o
diff --git a/drivers/net/ne-h8300.c b/drivers/net/ne-h8300.c
index eb893d7..38fd525 100644
--- a/drivers/net/ne-h8300.c
+++ b/drivers/net/ne-h8300.c
@@ -33,6 +33,8 @@ #include <asm/system.h>
 #include <asm/io.h>
 #include <asm/irq.h>
 
+#define EI_SHIFT(x)	(ei_local->reg_offset[x])
+
 #include "8390.h"
 
 #define DRV_NAME "ne-h8300"
@@ -52,6 +54,11 @@ #define DRV_NAME "ne-h8300"
 
 /* ---- No user-serviceable parts below ---- */
 
+static const char version[] =
+    "8390.c:v1.10cvs 9/23/94 Donald Becker (becker@cesdis.gsfc.nasa.gov)\n";
+
+#include "lib8390.c"
+
 #define NE_BASE	 (dev->base_addr)
 #define NE_CMD	 	0x00
 #define NE_DATAPORT	(ei_status.word16?0x20:0x10)	/* NatSemi-defined port window offset. */
@@ -162,7 +169,7 @@ static void cleanup_card(struct net_devi
 #ifndef MODULE
 struct net_device * __init ne_probe(int unit)
 {
-	struct net_device *dev = alloc_ei_netdev();
+	struct net_device *dev = ____alloc_ei_netdev(0);
 	int err;
 
 	if (!dev)
@@ -283,7 +290,7 @@ static int __init ne_probe1(struct net_d
 
 	/* Snarf the interrupt now.  There's no point in waiting since we cannot
 	   share and the board will usually be enabled. */
-	ret = request_irq(dev->irq, ei_interrupt, 0, name, dev);
+	ret = request_irq(dev->irq, __ei_interrupt, 0, name, dev);
 	if (ret) {
 		printk (" unable to get IRQ %d (errno=%d).\n", dev->irq, ret);
 		goto err_out;
@@ -318,9 +325,9 @@ #endif
 	dev->open = &ne_open;
 	dev->stop = &ne_close;
 #ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = ei_poll;
+	dev->poll_controller = __ei_poll;
 #endif
-	NS8390_init(dev, 0);
+	__NS8390_init(dev, 0);
 
 	ret = register_netdev(dev);
 	if (ret)
@@ -335,7 +342,7 @@ err_out:
 
 static int ne_open(struct net_device *dev)
 {
-	ei_open(dev);
+	__ei_open(dev);
 	return 0;
 }
 
@@ -343,7 +350,7 @@ static int ne_close(struct net_device *d
 {
 	if (ei_debug > 1)
 		printk(KERN_DEBUG "%s: Shutting down ethercard.\n", dev->name);
-	ei_close(dev);
+	__ei_close(dev);
 	return 0;
 }
 
@@ -584,7 +591,7 @@ #endif
 		if (time_after(jiffies, dma_start + 2*HZ/100)) {		/* 20ms */
 			printk(KERN_WARNING "%s: timeout waiting for Tx RDC.\n", dev->name);
 			ne_reset_8390(dev);
-			NS8390_init(dev,1);
+			__NS8390_init(dev,1);
 			break;
 		}
 
@@ -620,7 +627,7 @@ int init_module(void)
 	int err;
 
 	for (this_dev = 0; this_dev < MAX_NE_CARDS; this_dev++) {
-		struct net_device *dev = alloc_ei_netdev();
+		struct net_device *dev = ____alloc_ei_netdev(0);
 		if (!dev)
 			break;
 		if (io[this_dev]) {
-- 
1.4.2.GIT
