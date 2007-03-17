From: Finn Thain <fthain@telegraphics.com.au>
Subject: [PATCH 13/13] mac68k: SONIC interrupt handling
Date: Sat, 17 Mar 2007 20:09:31 +1100 (EST)
Message-ID: <Pine.LNX.4.64.0703171734280.4875@loopy.telegraphics.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Thomas Bogendoerfer <tsbogend@alpha.franken.de>,
	netdev@vger.kernel.org, linux-m68k@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from loopy.telegraphics.com.au ([202.45.126.152]:36051 "EHLO
	loopy.telegraphics.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933791AbXCQJaq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Mar 2007 05:30:46 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Install the macsonic interrupt handler on both IRQs when using 
via_alt_mapping. Otherwise the rare interrupt that still goes to the nubus 
slot will wedge the nubus.

$ cat /proc/interrupts
auto       2:      89176 via2
auto       3:     744367 sonic
auto       4:          0 scc
auto       6:     318363 via1
auto       7:          0 NMI
mac        9:     119413 framebuffer vbl
mac       10:       1971 ADB
mac       14:     198517 timer
mac       17:      89104 nubus
mac       19:         72 Mac ESP SCSI
mac       56:        629 sonic
mac       62:    1142593 ide0

Signed-off-by: Finn Thain <fthain@telegraphics.com.au>

 drivers/net/jazzsonic.c |   21 +++++++++++++++---
 drivers/net/macsonic.c  |   54 ++++++++++++++++++++++++++++++++++++++++--------
 drivers/net/sonic.c     |   25 ----------------------
 3 files changed, 63 insertions(+), 37 deletions(-)

Index: linux-2.6.20/drivers/net/jazzsonic.c
===================================================================
--- linux-2.6.20.orig/drivers/net/jazzsonic.c	2007-03-05 23:01:33.000000000 +1100
+++ linux-2.6.20/drivers/net/jazzsonic.c	2007-03-05 23:01:33.000000000 +1100
@@ -88,6 +88,21 @@ static unsigned short known_revisions[] 
 	0xffff			/* end of list */
 };
 
+static int jazzsonic_open(struct net_device* dev) {
+	if (request_irq(dev->irq, &sonic_interrupt, IRQF_DISABLED, "sonic", dev)) {
+		printk(KERN_ERR "\n%s: unable to get IRQ %d .\n", dev->name, dev->irq);
+		return -EAGAIN;
+	}
+	return sonic_open(dev);
+}
+
+static int jazzsonic_close(struct net_device* dev) {
+	int err;
+	err = sonic_close(dev);
+	free_irq(dev->irq, dev);
+	return err;
+}
+
 static int __init sonic_probe1(struct net_device *dev)
 {
 	static unsigned version_printed;
@@ -169,8 +184,8 @@ static int __init sonic_probe1(struct ne
 	lp->rra_laddr = lp->rda_laddr + (SIZEOF_SONIC_RD * SONIC_NUM_RDS
 	                     * SONIC_BUS_SCALE(lp->dma_bitmode));
 
-	dev->open = sonic_open;
-	dev->stop = sonic_close;
+	dev->open = jazzsonic_open;
+	dev->stop = jazzsonic_close;
 	dev->hard_start_xmit = sonic_send_packet;
 	dev->get_stats = sonic_get_stats;
 	dev->set_multicast_list = &sonic_multicast_list;
@@ -260,8 +275,6 @@ MODULE_DESCRIPTION("Jazz SONIC ethernet 
 module_param(sonic_debug, int, 0);
 MODULE_PARM_DESC(sonic_debug, "jazzsonic debug level (1-4)");
 
-#define SONIC_IRQ_FLAG IRQF_DISABLED
-
 #include "sonic.c"
 
 static int __devexit jazz_sonic_device_remove (struct platform_device *pdev)
Index: linux-2.6.20/drivers/net/macsonic.c
===================================================================
--- linux-2.6.20.orig/drivers/net/macsonic.c	2007-03-05 23:01:33.000000000 +1100
+++ linux-2.6.20/drivers/net/macsonic.c	2007-03-05 23:01:33.000000000 +1100
@@ -133,6 +133,49 @@ static inline void bit_reverse_addr(unsi
 			   nibbletab[(addr[i] >> 4) &0xf]);
 }
 
+static irqreturn_t macsonic_interrupt(int irq, void *dev_id) {
+	/* Under the A/UX interrupt scheme, the SONIC interrupt comes in at
+	 * priority level 3. However, we sometimes get the level 2 interrupt
+	 * as well, which must prevent re-enterance of the sonic handler.
+	 */
+	irqreturn_t result;
+	unsigned long flags;
+
+	local_irq_save(flags);
+	result = sonic_interrupt(irq, dev_id);
+	local_irq_restore(flags);
+	return result;
+}
+
+static int macsonic_open(struct net_device* dev) {
+	if (via_alt_mapping) {
+		if (request_irq(dev->irq, &macsonic_interrupt, IRQ_FLG_FAST, "sonic", dev)) {
+			printk(KERN_ERR "\n%s: unable to get IRQ %d .\n", dev->name, dev->irq);
+			return -EAGAIN;
+		}
+		if (request_irq(IRQ_AUTO_3, &sonic_interrupt, IRQ_FLG_FAST, "sonic", dev)) {
+			printk(KERN_ERR "\n%s: unable to get IRQ %d .\n", dev->name, IRQ_AUTO_3);
+			free_irq(dev->irq, dev);
+			return -EAGAIN;
+		}
+	} else {
+		if (request_irq(dev->irq, &sonic_interrupt, IRQ_FLG_FAST, "sonic", dev)) {
+			printk(KERN_ERR "\n%s: unable to get IRQ %d .\n", dev->name, dev->irq);
+			return -EAGAIN;
+		}
+	}
+	return sonic_open(dev);
+}
+
+static int macsonic_close(struct net_device* dev) {
+	int err;
+	err = sonic_close(dev);
+	free_irq(dev->irq, dev);
+	if (via_alt_mapping)
+		free_irq(IRQ_AUTO_3, dev);
+	return err;
+}
+
 int __init macsonic_init(struct net_device* dev)
 {
 	struct sonic_local* lp = netdev_priv(dev);
@@ -163,8 +206,8 @@ int __init macsonic_init(struct net_devi
 	lp->rra_laddr = lp->rda_laddr + (SIZEOF_SONIC_RD * SONIC_NUM_RDS
 	                     * SONIC_BUS_SCALE(lp->dma_bitmode));
 
-	dev->open = sonic_open;
-	dev->stop = sonic_close;
+	dev->open = macsonic_open;
+	dev->stop = macsonic_close;
 	dev->hard_start_xmit = sonic_send_packet;
 	dev->get_stats = sonic_get_stats;
 	dev->set_multicast_list = &sonic_multicast_list;
@@ -298,10 +341,7 @@ int __init mac_onboard_sonic_probe(struc
 	/* Danger!  My arms are flailing wildly!  You *must* set lp->reg_offset
 	 * and dev->base_addr before using SONIC_READ() or SONIC_WRITE() */
 	dev->base_addr = ONBOARD_SONIC_REGISTERS;
-	if (via_alt_mapping)
-		dev->irq = IRQ_AUTO_3;
-	else
-		dev->irq = IRQ_NUBUS_9;
+	dev->irq = IRQ_NUBUS_9;
 
 	if (!sonic_version_printed) {
 		printk(KERN_INFO "%s", version);
@@ -575,8 +615,6 @@ MODULE_DESCRIPTION("Macintosh SONIC ethe
 module_param(sonic_debug, int, 0);
 MODULE_PARM_DESC(sonic_debug, "macsonic debug level (1-4)");
 
-#define SONIC_IRQ_FLAG IRQ_FLG_FAST
-
 #include "sonic.c"
 
 static int __devexit mac_sonic_device_remove (struct platform_device *pdev)
Index: linux-2.6.20/drivers/net/sonic.c
===================================================================
--- linux-2.6.20.orig/drivers/net/sonic.c	2007-03-05 23:01:33.000000000 +1100
+++ linux-2.6.20/drivers/net/sonic.c	2007-03-05 23:01:33.000000000 +1100
@@ -50,29 +50,6 @@ static int sonic_open(struct net_device 
 	if (sonic_debug > 2)
 		printk("sonic_open: initializing sonic driver.\n");
 
-	/*
-	 * We don't need to deal with auto-irq stuff since we
-	 * hardwire the sonic interrupt.
-	 */
-/*
- * XXX Horrible work around:  We install sonic_interrupt as fast interrupt.
- * This means that during execution of the handler interrupt are disabled
- * covering another bug otherwise corrupting data.  This doesn't mean
- * this glue works ok under all situations.
- *
- * Note (dhd): this also appears to prevent lockups on the Macintrash
- * when more than one Ethernet card is installed (knock on wood)
- *
- * Note (fthain): whether the above is still true is anyones guess. Certainly
- * the buffer handling algorithms will not tolerate re-entrance without some
- * mutual exclusion added. Anyway, the memcpy has now been eliminated from the
- * rx code to make this a faster "fast interrupt".
- */
-	if (request_irq(dev->irq, &sonic_interrupt, SONIC_IRQ_FLAG, "sonic", dev)) {
-		printk(KERN_ERR "\n%s: unable to get IRQ %d .\n", dev->name, dev->irq);
-		return -EAGAIN;
-	}
-
 	for (i = 0; i < SONIC_NUM_RRS; i++) {
 		struct sk_buff *skb = dev_alloc_skb(SONIC_RBSIZE + 2);
 		if (skb == NULL) {
@@ -170,8 +147,6 @@ static int sonic_close(struct net_device
 		}
 	}
 
-	free_irq(dev->irq, dev);	/* release the IRQ */
-
 	return 0;
 }
 
