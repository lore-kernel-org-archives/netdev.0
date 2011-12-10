From: Finn Thain <fthain@telegraphics.com.au>
Subject: [PATCH 03/16] mac_sonic: add irq resources and cleanup
Date: Sat, 10 Dec 2011 16:23:43 +1100 (EST)
Message-ID: <alpine.LNX.2.00.1112101605000.13274@nippy.intranet>
References: <20111023141108.856998818@telegraphics.com.au> <20111023141124.538715283@telegraphics.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-m68k@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <20111023141124.538715283@telegraphics.com.au>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make better use of the SONIC platform device by adding irq resources. 
This moves the via_type logic out of the NIC device driver which 
improves modularity.

Since interrupt handlers now run with CPU interrupts disabled, we don't 
need the macsonic_interrupt() wrapper. Remove it.

For consistency, rename retval as err.

Signed-off-by: Finn Thain <fthain@telegraphics.com.au>

---

Re-sending unchanged. Still needs the right ack.


Index: linux-m68k/arch/m68k/mac/config.c
===================================================================
--- linux-m68k.orig/arch/m68k/mac/config.c	2011-10-22 23:02:22.000000000 +1100
+++ linux-m68k/arch/m68k/mac/config.c	2011-10-23 00:51:11.000000000 +1100
@@ -936,9 +936,16 @@ static struct platform_device esp_1_pdev
 	.id		= 1,
 };
 
+static struct resource sonic_rsrcs[] = {
+	{ .flags = IORESOURCE_IRQ },
+	{ .flags = IORESOURCE_IRQ },
+};
+
 static struct platform_device sonic_pdev = {
 	.name		= "macsonic",
 	.id		= -1,
+	.num_resources  = ARRAY_SIZE(sonic_rsrcs),
+	.resource       = sonic_rsrcs,
 };
 
 static struct platform_device mace_pdev = {
@@ -1002,6 +1009,10 @@ int __init mac_platform_init(void)
 
 	switch (macintosh_config->ether_type) {
 	case MAC_ETHER_SONIC:
+		sonic_rsrcs[0].start = sonic_rsrcs[0].end = IRQ_NUBUS_9;
+		if (via_alt_mapping)
+			sonic_rsrcs[1].start = sonic_rsrcs[1].end = IRQ_AUTO_3;
+
 		platform_device_register(&sonic_pdev);
 		break;
 	case MAC_ETHER_MACE:
Index: linux-m68k/drivers/net/macsonic.c
===================================================================
--- linux-m68k.orig/drivers/net/macsonic.c	2011-10-22 23:02:38.000000000 +1100
+++ linux-m68k/drivers/net/macsonic.c	2011-10-22 23:02:38.000000000 +1100
@@ -60,7 +60,6 @@
 #include <asm/dma.h>
 #include <asm/macintosh.h>
 #include <asm/macints.h>
-#include <asm/mac_via.h>
 
 static char mac_sonic_string[] = "macsonic";
 
@@ -127,61 +126,49 @@ static inline void bit_reverse_addr(unsi
 		addr[i] = bitrev8(addr[i]);
 }
 
-static irqreturn_t macsonic_interrupt(int irq, void *dev_id)
-{
-	irqreturn_t result;
-	unsigned long flags;
-
-	local_irq_save(flags);
-	result = sonic_interrupt(irq, dev_id);
-	local_irq_restore(flags);
-	return result;
-}
-
 static int macsonic_open(struct net_device* dev)
 {
-	int retval;
+	struct sonic_local *lp = netdev_priv(dev);
+	int err;
 
-	retval = request_irq(dev->irq, sonic_interrupt, 0, "sonic", dev);
-	if (retval) {
-		printk(KERN_ERR "%s: unable to get IRQ %d.\n",
-				dev->name, dev->irq);
-		goto err;
-	}
-	/* Under the A/UX interrupt scheme, the onboard SONIC interrupt comes
-	 * in at priority level 3. However, we sometimes get the level 2 inter-
-	 * rupt as well, which must prevent re-entrance of the sonic handler.
-	 */
-	if (dev->irq == IRQ_AUTO_3) {
-		retval = request_irq(IRQ_NUBUS_9, macsonic_interrupt, 0,
-				     "sonic", dev);
-		if (retval) {
-			printk(KERN_ERR "%s: unable to get IRQ %d.\n",
-					dev->name, IRQ_NUBUS_9);
-			goto err_irq;
+	err = request_irq(dev->irq, sonic_interrupt, 0, "SONIC", dev);
+	if (err) {
+		pr_err("%s: unable to get IRQ %d\n", dev->name, dev->irq);
+		goto out;
+	}
+	if (lp->irq1) {
+		err = request_irq(lp->irq1, sonic_interrupt, 0, "SONIC", dev);
+		if (err) {
+			pr_err("%s: unable to get IRQ %d\n",
+			       dev->name, lp->irq1);
+			goto out_irq;
 		}
 	}
-	retval = sonic_open(dev);
-	if (retval)
-		goto err_irq_nubus;
+	err = sonic_open(dev);
+	if (err)
+		goto out_irq1;
+
 	return 0;
 
-err_irq_nubus:
-	if (dev->irq == IRQ_AUTO_3)
-		free_irq(IRQ_NUBUS_9, dev);
-err_irq:
+out_irq1:
+	if (lp->irq1)
+		free_irq(lp->irq1, dev);
+out_irq:
 	free_irq(dev->irq, dev);
-err:
-	return retval;
+out:
+	return err;
 }
 
 static int macsonic_close(struct net_device* dev)
 {
+	struct sonic_local *lp = netdev_priv(dev);
 	int err;
+
 	err = sonic_close(dev);
+
+	if (lp->irq1)
+		free_irq(lp->irq1, dev);
 	free_irq(dev->irq, dev);
-	if (dev->irq == IRQ_AUTO_3)
-		free_irq(IRQ_NUBUS_9, dev);
 	return err;
 }
 
@@ -310,8 +297,9 @@ static void __devinit mac_onboard_sonic_
 	random_ether_addr(dev->dev_addr);
 }
 
-static int __devinit mac_onboard_sonic_probe(struct net_device *dev)
+static int __devinit mac_onboard_sonic_probe(struct platform_device *pdev)
 {
+	struct net_device *dev = platform_get_drvdata(pdev);
 	struct sonic_local* lp = netdev_priv(dev);
 	int sr;
 	int commslot = 0;
@@ -348,10 +336,12 @@ static int __devinit mac_onboard_sonic_p
 	/* Danger!  My arms are flailing wildly!  You *must* set lp->reg_offset
 	 * and dev->base_addr before using SONIC_READ() or SONIC_WRITE() */
 	dev->base_addr = ONBOARD_SONIC_REGISTERS;
-	if (via_alt_mapping)
-		dev->irq = IRQ_AUTO_3;
-	else
-		dev->irq = IRQ_NUBUS_9;
+
+	dev->irq = platform_get_irq(pdev, 0);
+	lp->irq1 = platform_get_irq(pdev, 1);
+
+	if (!dev->irq)
+		return -ENODEV;
 
 	if (!sonic_version_printed) {
 		printk(KERN_INFO "%s", version);
@@ -590,7 +580,7 @@ static int __devinit mac_sonic_probe(str
 	platform_set_drvdata(pdev, dev);
 
 	/* This will catch fatal stuff like -ENOMEM as well as success */
-	err = mac_onboard_sonic_probe(dev);
+	err = mac_onboard_sonic_probe(pdev);
 	if (err == 0)
 		goto found;
 	if (err != -ENODEV)
Index: linux-m68k/drivers/net/sonic.h
===================================================================
--- linux-m68k.orig/drivers/net/sonic.h	2011-10-22 23:02:22.000000000 +1100
+++ linux-m68k/drivers/net/sonic.h	2011-10-22 23:02:38.000000000 +1100
@@ -318,6 +318,9 @@ struct sonic_local {
 	unsigned int eol_rx;
 	unsigned int eol_tx;           /* last unacked transmit packet */
 	unsigned int next_tx;          /* next free TD */
+#ifdef CONFIG_MAC
+	int irq1;                      /* Second IRQ for Mac Quadras */
+#endif
 	struct device *device;         /* generic device */
 	struct net_device_stats stats;
 };
Index: linux-m68k/arch/m68k/mac/via.c
===================================================================
--- linux-m68k.orig/arch/m68k/mac/via.c	2011-10-22 23:02:38.000000000 +1100
+++ linux-m68k/arch/m68k/mac/via.c	2011-10-23 00:51:10.000000000 +1100
@@ -40,7 +40,6 @@
 volatile __u8 *via1, *via2;
 int rbv_present;
 int via_alt_mapping;
-EXPORT_SYMBOL(via_alt_mapping);
 static __u8 rbv_clear;
 
 /*
