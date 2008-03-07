From: Ondrej Zary <linux@rainbow-software.org>
Subject: [PATCH] 3c509: convert to isa_driver and pnp_driver v6
Date: Fri, 7 Mar 2008 17:46:40 +0100
Message-ID: <200803071746.49554.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.atlantis.sk ([80.94.52.35]:53618 "EHLO mail.atlantis.sk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758062AbYCGQrK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Mar 2008 11:47:10 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
this patch converts 3c509 driver to isa_driver and pnp_driver. The result is 
that autoloading using udev and hibernation works with ISA PnP cards. It also 
adds hibernation support for non-PnP ISA cards.

xcvr module parameter was removed as its value was not used.

Tested using 3 ISA cards in various combinations of PnP and non-PnP modes. 
EISA and MCA only compile-tested.

Signed-off-by: Ondrej Zary <linux@rainbow-software.org>

--- linux-2.6.24-orig/drivers/net/3c509.c	2008-02-25 18:27:17.000000000 +0100
+++ linux-2.6.24.3-pentium/drivers/net/3c509.c	2008-03-07 17:38:29.000000000 +0100
@@ -54,25 +54,24 @@
 		v1.19a 28Oct2002 Davud Ruggiero <jdr@farfalle.com>
 			- Increase *read_eeprom udelay to workaround oops with 2 cards.
 		v1.19b 08Nov2002 Marc Zyngier <maz@wild-wind.fr.eu.org>
-		    - Introduce driver model for EISA cards.
+			- Introduce driver model for EISA cards.
+		v1.20  04Feb2008 Ondrej Zary <linux@rainbow-software.org>
+			- convert to isa_driver and pnp_driver and some cleanups
 */
 
 #define DRV_NAME	"3c509"
-#define DRV_VERSION	"1.19b"
-#define DRV_RELDATE	"08Nov2002"
+#define DRV_VERSION	"1.20"
+#define DRV_RELDATE	"04Feb2008"
 
 /* A few values that may be tweaked. */
 
 /* Time in jiffies before concluding the transmitter is hung. */
 #define TX_TIMEOUT  (400*HZ/1000)
-/* Maximum events (Rx packets, etc.) to handle at each interrupt. */
-static int max_interrupt_work = 10;
 
 #include <linux/module.h>
-#ifdef CONFIG_MCA
 #include <linux/mca.h>
-#endif
-#include <linux/isapnp.h>
+#include <linux/isa.h>
+#include <linux/pnp.h>
 #include <linux/string.h>
 #include <linux/interrupt.h>
 #include <linux/errno.h>
@@ -97,10 +96,6 @@
 
 static char version[] __initdata = DRV_NAME ".c:" DRV_VERSION " " DRV_RELDATE " becker@scyld.com\n";
 
-#if defined(CONFIG_PM) && (defined(CONFIG_MCA) || defined(CONFIG_EISA))
-#define EL3_SUSPEND
-#endif
-
 #ifdef EL3_DEBUG
 static int el3_debug = EL3_DEBUG;
 #else
@@ -111,6 +106,7 @@
  * a global variable so that the mca/eisa probe routines can increment
  * it */
 static int el3_cards = 0;
+#define EL3_MAX_CARDS 8
 
 /* To minimize the size of the driver source I only define operating
    constants if they are used several times.  You'll need the manual
@@ -119,7 +115,7 @@
 #define EL3_DATA 0x00
 #define EL3_CMD 0x0e
 #define EL3_STATUS 0x0e
-#define	 EEPROM_READ 0x80
+#define	EEPROM_READ 0x80
 
 #define EL3_IO_EXTENT	16
 
@@ -168,23 +164,31 @@
  */
 #define SKB_QUEUE_SIZE	64
 
+enum el3_cardtype { EL3_ISA, EL3_PNP, EL3_MCA, EL3_EISA };
+
 struct el3_private {
 	struct net_device_stats stats;
-	struct net_device *next_dev;
 	spinlock_t lock;
 	/* skb send-queue */
 	int head, size;
 	struct sk_buff *queue[SKB_QUEUE_SIZE];
-	enum {
-		EL3_MCA,
-		EL3_PNP,
-		EL3_EISA,
-	} type;						/* type of device */
-	struct device *dev;
+	enum el3_cardtype type;
 };
-static int id_port __initdata = 0x110;	/* Start with 0x110 to avoid new sound cards.*/
-static struct net_device *el3_root_dev;
+static int id_port;
+static int current_tag;
+static struct net_device *el3_devs[EL3_MAX_CARDS];
+
+/* Parameters that may be passed into the module. */
+static int debug = -1;
+static int irq[] = {-1, -1, -1, -1, -1, -1, -1, -1};
+/* Maximum events (Rx packets, etc.) to handle at each interrupt. */
+static int max_interrupt_work = 10;
+#ifdef CONFIG_PNP
+static int nopnp;
+#endif
 
+static int __init el3_common_init(struct net_device *dev);
+static void el3_common_remove(struct net_device *dev);
 static ushort id_read_eeprom(int index);
 static ushort read_eeprom(int ioaddr, int index);
 static int el3_open(struct net_device *dev);
@@ -199,7 +203,7 @@
 static void el3_down(struct net_device *dev);
 static void el3_up(struct net_device *dev);
 static const struct ethtool_ops ethtool_ops;
-#ifdef EL3_SUSPEND
+#ifdef CONFIG_PM
 static int el3_suspend(struct device *, pm_message_t);
 static int el3_resume(struct device *);
 #else
@@ -209,13 +213,272 @@
 
 
 /* generic device remove for all device types */
-#if defined(CONFIG_EISA) || defined(CONFIG_MCA)
 static int el3_device_remove (struct device *device);
-#endif
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void el3_poll_controller(struct net_device *dev);
 #endif
 
+/* Return 0 on success, 1 on error, 2 when found already detected PnP card */
+static int el3_isa_id_sequence(__be16 *phys_addr)
+{
+	short lrs_state = 0xff;
+	int i;
+
+	/* ISA boards are detected by sending the ID sequence to the
+	   ID_PORT.  We find cards past the first by setting the 'current_tag'
+	   on cards as they are found.  Cards with their tag set will not
+	   respond to subsequent ID sequences. */
+
+	outb(0x00, id_port);
+	outb(0x00, id_port);
+	for (i = 0; i < 255; i++) {
+		outb(lrs_state, id_port);
+		lrs_state <<= 1;
+		lrs_state = lrs_state & 0x100 ? lrs_state ^ 0xcf : lrs_state;
+	}
+	/* For the first probe, clear all board's tag registers. */
+	if (current_tag == 0)
+		outb(0xd0, id_port);
+	else			/* Otherwise kill off already-found boards. */
+		outb(0xd8, id_port);
+	if (id_read_eeprom(7) != 0x6d50)
+		return 1;
+	/* Read in EEPROM data, which does contention-select.
+	   Only the lowest address board will stay "on-line".
+	   3Com got the byte order backwards. */
+	for (i = 0; i < 3; i++)
+		phys_addr[i] = htons(id_read_eeprom(i));
+#ifdef CONFIG_PNP
+	if (!nopnp) {
+		/* The ISA PnP 3c509 cards respond to the ID sequence too.
+		   This check is needed in order not to register them twice. */
+		for (i = 0; i < el3_cards; i++) {
+			struct el3_private *lp = netdev_priv(el3_devs[i]);
+			if (lp->type == EL3_PNP
+			    && !memcmp(phys_addr, el3_devs[i]->dev_addr,
+				       ETH_ALEN)) {
+				if (el3_debug > 3)
+					printk(KERN_DEBUG "3c509 with 
address %02x %02x %02x %02x %02x %02x was found by ISAPnP\n",
+						phys_addr[0] & 0xff, phys_addr[0] >> 8,
+						phys_addr[1] & 0xff, phys_addr[1] >> 8,
+						phys_addr[2] & 0xff, phys_addr[2] >> 8);
+				/* Set the adaptor tag so that the next card can be found. */
+				outb(0xd0 + ++current_tag, id_port);
+				return 2;
+			}
+		}
+	}
+#endif /* CONFIG_PNP */
+	return 0;
+
+}
+
+static void __devinit el3_dev_fill(struct net_device *dev, __be16 *phys_addr,
+				   int ioaddr, int irq, int if_port,
+				   enum el3_cardtype type)
+{
+	struct el3_private *lp = netdev_priv(dev);
+
+	memcpy(dev->dev_addr, phys_addr, ETH_ALEN);
+	dev->base_addr = ioaddr;
+	dev->irq = irq;
+	dev->if_port = if_port;
+	lp->type = type;
+}
+
+static int __devinit el3_isa_match(struct device *pdev,
+				   unsigned int ndev)
+{
+	struct net_device *dev;
+	int ioaddr, isa_irq, if_port, err;
+	unsigned int iobase;
+	__be16 phys_addr[3];
+
+	while ((err = el3_isa_id_sequence(phys_addr)) == 2)
+		;	/* Skip to next card when PnP card found */
+	if (err == 1)
+		return 0;
+
+	iobase = id_read_eeprom(8);
+	if_port = iobase >> 14;
+	ioaddr = 0x200 + ((iobase & 0x1f) << 4);
+	if (irq[el3_cards] > 1 && irq[el3_cards] < 16)
+		isa_irq = irq[el3_cards];
+	else
+		isa_irq = id_read_eeprom(9) >> 12;
+
+	dev = alloc_etherdev(sizeof(struct el3_private));
+	if (!dev)
+		return -ENOMEM;
+
+	netdev_boot_setup_check(dev);
+
+	if (!request_region(ioaddr, EL3_IO_EXTENT, "3c509-isa")) {
+		free_netdev(dev);
+		return 0;
+	}
+
+	/* Set the adaptor tag so that the next card can be found. */
+	outb(0xd0 + ++current_tag, id_port);
+
+	/* Activate the adaptor at the EEPROM location. */
+	outb((ioaddr >> 4) | 0xe0, id_port);
+
+	EL3WINDOW(0);
+	if (inw(ioaddr) != 0x6d50) {
+		free_netdev(dev);
+		return 0;
+	}
+
+	/* Free the interrupt so that some other card can use it. */
+	outw(0x0f00, ioaddr + WN0_IRQ);
+
+	el3_dev_fill(dev, phys_addr, ioaddr, isa_irq, if_port, EL3_ISA);
+	dev_set_drvdata(pdev, dev);
+	if (el3_common_init(dev)) {
+		free_netdev(dev);
+		return 0;
+	}
+
+	el3_devs[el3_cards++] = dev;
+	return 1;
+}
+
+static int __devexit el3_isa_remove(struct device *pdev,
+				    unsigned int ndev)
+{
+	el3_device_remove(pdev);
+	dev_set_drvdata(pdev, NULL);
+	return 0;
+}
+
+#ifdef CONFIG_PM
+static int el3_isa_suspend(struct device *dev, unsigned int n,
+			   pm_message_t state)
+{
+	current_tag = 0;
+	return el3_suspend(dev, state);
+}
+
+static int el3_isa_resume(struct device *dev, unsigned int n)
+{
+	struct net_device *ndev = dev_get_drvdata(dev);
+	int ioaddr = ndev->base_addr, err;
+	__be16 phys_addr[3];
+
+	while ((err = el3_isa_id_sequence(phys_addr)) == 2)
+		;	/* Skip to next card when PnP card found */
+	if (err == 1)
+		return 0;
+	/* Set the adaptor tag so that the next card can be found. */
+	outb(0xd0 + ++current_tag, id_port);
+	/* Enable the card */
+	outb((ioaddr >> 4) | 0xe0, id_port);
+	EL3WINDOW(0);
+	if (inw(ioaddr) != 0x6d50)
+		return 1;
+	/* Free the interrupt so that some other card can use it. */
+	outw(0x0f00, ioaddr + WN0_IRQ);
+	return el3_resume(dev);
+}
+#endif
+
+static struct isa_driver el3_isa_driver = {
+	.match		= el3_isa_match,
+	.remove		= __devexit_p(el3_isa_remove),
+#ifdef CONFIG_PM
+	.suspend	= el3_isa_suspend,
+	.resume		= el3_isa_resume,
+#endif
+	.driver		= {
+		.name	= "3c509"
+	},
+};
+static int isa_registered;
+
+#ifdef CONFIG_PNP
+static struct pnp_device_id el3_pnp_ids[] = {
+	{ .id = "TCM5090" }, /* 3Com Etherlink III (TP) */
+	{ .id = "TCM5091" }, /* 3Com Etherlink III */
+	{ .id = "TCM5094" }, /* 3Com Etherlink III (combo) */
+	{ .id = "TCM5095" }, /* 3Com Etherlink III (TPO) */
+	{ .id = "TCM5098" }, /* 3Com Etherlink III (TPC) */
+	{ .id = "PNP80f7" }, /* 3Com Etherlink III compatible */
+	{ .id = "PNP80f8" }, /* 3Com Etherlink III compatible */
+	{ .id = "" }
+};
+MODULE_DEVICE_TABLE(pnp, el3_pnp_ids);
+
+static int __devinit el3_pnp_probe(struct pnp_dev *pdev,
+				    const struct pnp_device_id *id)
+{
+	short i;
+	int ioaddr, irq, if_port;
+	u16 phys_addr[3];
+	struct net_device *dev = NULL;
+	int err;
+
+	ioaddr = pnp_port_start(pdev, 0);
+	if (!request_region(ioaddr, EL3_IO_EXTENT, "3c509-pnp"))
+		return -EBUSY;
+	irq = pnp_irq(pdev, 0);
+	EL3WINDOW(0);
+	for (i = 0; i < 3; i++)
+		phys_addr[i] = htons(read_eeprom(ioaddr, i));
+	if_port = read_eeprom(ioaddr, 8) >> 14;
+	dev = alloc_etherdev(sizeof(struct el3_private));
+	if (!dev) {
+		release_region(ioaddr, EL3_IO_EXTENT);
+		return -ENOMEM;
+	}
+	SET_NETDEV_DEV(dev, &pdev->dev);
+	netdev_boot_setup_check(dev);
+
+	el3_dev_fill(dev, phys_addr, ioaddr, irq, if_port, EL3_PNP);
+	pnp_set_drvdata(pdev, dev);
+	err = el3_common_init(dev);
+
+	if (err) {
+		pnp_set_drvdata(pdev, NULL);
+		free_netdev(dev);
+		return err;
+	}
+
+	el3_devs[el3_cards++] = dev;
+	return 0;
+}
+
+static void __devexit el3_pnp_remove(struct pnp_dev *pdev)
+{
+	el3_common_remove(pnp_get_drvdata(pdev));
+	pnp_set_drvdata(pdev, NULL);
+}
+
+#ifdef CONFIG_PM
+static int el3_pnp_suspend(struct pnp_dev *pdev, pm_message_t state)
+{
+	return el3_suspend(&pdev->dev, state);
+}
+
+static int el3_pnp_resume(struct pnp_dev *pdev)
+{
+	return el3_resume(&pdev->dev);
+}
+#endif
+
+static struct pnp_driver el3_pnp_driver = {
+	.name		= "3c509",
+	.id_table	= el3_pnp_ids,
+	.probe		= el3_pnp_probe,
+	.remove		= __devexit_p(el3_pnp_remove),
+#ifdef CONFIG_PM
+	.suspend	= el3_pnp_suspend,
+	.resume		= el3_pnp_resume,
+#endif
+};
+static int pnp_registered;
+#endif /* CONFIG_PNP */
+
 #ifdef CONFIG_EISA
 static struct eisa_device_id el3_eisa_ids[] = {
 		{ "TCM5092" },
@@ -230,13 +493,14 @@
 static struct eisa_driver el3_eisa_driver = {
 		.id_table = el3_eisa_ids,
 		.driver   = {
-				.name    = "3c509",
+				.name    = "3c579",
 				.probe   = el3_eisa_probe,
 				.remove  = __devexit_p (el3_device_remove),
 				.suspend = el3_suspend,
 				.resume  = el3_resume,
 		}
 };
+static int eisa_registered;
 #endif
 
 #ifdef CONFIG_MCA
@@ -271,45 +535,9 @@
 				.resume  = el3_resume,
 		},
 };
+static int mca_registered;
 #endif /* CONFIG_MCA */
 
-#if defined(__ISAPNP__)
-static struct isapnp_device_id el3_isapnp_adapters[] __initdata = {
-	{	ISAPNP_ANY_ID, ISAPNP_ANY_ID,
-		ISAPNP_VENDOR('T', 'C', 'M'), ISAPNP_FUNCTION(0x5090),
-		(long) "3Com Etherlink III (TP)" },
-	{	ISAPNP_ANY_ID, ISAPNP_ANY_ID,
-		ISAPNP_VENDOR('T', 'C', 'M'), ISAPNP_FUNCTION(0x5091),
-		(long) "3Com Etherlink III" },
-	{	ISAPNP_ANY_ID, ISAPNP_ANY_ID,
-		ISAPNP_VENDOR('T', 'C', 'M'), ISAPNP_FUNCTION(0x5094),
-		(long) "3Com Etherlink III (combo)" },
-	{	ISAPNP_ANY_ID, ISAPNP_ANY_ID,
-		ISAPNP_VENDOR('T', 'C', 'M'), ISAPNP_FUNCTION(0x5095),
-		(long) "3Com Etherlink III (TPO)" },
-	{	ISAPNP_ANY_ID, ISAPNP_ANY_ID,
-		ISAPNP_VENDOR('T', 'C', 'M'), ISAPNP_FUNCTION(0x5098),
-		(long) "3Com Etherlink III (TPC)" },
-	{	ISAPNP_ANY_ID, ISAPNP_ANY_ID,
-		ISAPNP_VENDOR('P', 'N', 'P'), ISAPNP_FUNCTION(0x80f7),
-		(long) "3Com Etherlink III compatible" },
-	{	ISAPNP_ANY_ID, ISAPNP_ANY_ID,
-		ISAPNP_VENDOR('P', 'N', 'P'), ISAPNP_FUNCTION(0x80f8),
-		(long) "3Com Etherlink III compatible" },
-	{ }	/* terminate list */
-};
-
-static __be16 el3_isapnp_phys_addr[8][3];
-static int nopnp;
-#endif /* __ISAPNP__ */
-
-/* With the driver model introduction for EISA devices, both init
- * and cleanup have been split :
- * - EISA devices probe/remove starts in el3_eisa_probe/el3_device_remove
- * - MCA/ISA still use el3_probe
- *
- * Both call el3_common_init/el3_common_remove. */
-
 static int __init el3_common_init(struct net_device *dev)
 {
 	struct el3_private *lp = netdev_priv(dev);
@@ -360,231 +588,11 @@
 
 static void el3_common_remove (struct net_device *dev)
 {
-	struct el3_private *lp = netdev_priv(dev);
-
-	(void) lp;				/* Keep gcc quiet... */
-#if defined(__ISAPNP__)
-	if (lp->type == EL3_PNP)
-		pnp_device_detach(to_pnp_dev(lp->dev));
-#endif
-
 	unregister_netdev (dev);
 	release_region(dev->base_addr, EL3_IO_EXTENT);
 	free_netdev (dev);
 }
 
-static int __init el3_probe(int card_idx)
-{
-	struct net_device *dev;
-	struct el3_private *lp;
-	short lrs_state = 0xff, i;
-	int ioaddr, irq, if_port;
-	__be16 phys_addr[3];
-	static int current_tag;
-	int err = -ENODEV;
-#if defined(__ISAPNP__)
-	static int pnp_cards;
-	struct pnp_dev *idev = NULL;
-	int pnp_found = 0;
-
-	if (nopnp == 1)
-		goto no_pnp;
-
-	for (i=0; el3_isapnp_adapters[i].vendor != 0; i++) {
-		int j;
-		while ((idev = pnp_find_dev(NULL,
-					    el3_isapnp_adapters[i].vendor,
-					    el3_isapnp_adapters[i].function,
-					    idev))) {
-			if (pnp_device_attach(idev) < 0)
-				continue;
-			if (pnp_activate_dev(idev) < 0) {
-__again:
-				pnp_device_detach(idev);
-				continue;
-			}
-			if (!pnp_port_valid(idev, 0) || !pnp_irq_valid(idev, 0))
-				goto __again;
-			ioaddr = pnp_port_start(idev, 0);
-			if (!request_region(ioaddr, EL3_IO_EXTENT, "3c509 PnP")) {
-				pnp_device_detach(idev);
-				return -EBUSY;
-			}
-			irq = pnp_irq(idev, 0);
-			if (el3_debug > 3)
-				printk ("ISAPnP reports %s at i/o 0x%x, irq %d\n",
-					(char*) el3_isapnp_adapters[i].driver_data, ioaddr, irq);
-			EL3WINDOW(0);
-			for (j = 0; j < 3; j++)
-				el3_isapnp_phys_addr[pnp_cards][j] =
-					phys_addr[j] =
-						htons(read_eeprom(ioaddr, j));
-			if_port = read_eeprom(ioaddr, 8) >> 14;
-			dev = alloc_etherdev(sizeof (struct el3_private));
-			if (!dev) {
-					release_region(ioaddr, EL3_IO_EXTENT);
-					pnp_device_detach(idev);
-					return -ENOMEM;
-			}
-
-			SET_NETDEV_DEV(dev, &idev->dev);
-			pnp_cards++;
-
-			netdev_boot_setup_check(dev);
-			pnp_found = 1;
-			goto found;
-		}
-	}
-no_pnp:
-#endif /* __ISAPNP__ */
-
-	/* Select an open I/O location at 0x1*0 to do contention select. */
-	for ( ; id_port < 0x200; id_port += 0x10) {
-		if (!request_region(id_port, 1, "3c509"))
-			continue;
-		outb(0x00, id_port);
-		outb(0xff, id_port);
-		if (inb(id_port) & 0x01){
-			release_region(id_port, 1);
-			break;
-		} else
-			release_region(id_port, 1);
-	}
-	if (id_port >= 0x200) {
-		/* Rare -- do we really need a warning? */
-		printk(" WARNING: No I/O port available for 3c509 activation.\n");
-		return -ENODEV;
-	}
-
-	/* Next check for all ISA bus boards by sending the ID sequence to the
-	   ID_PORT.  We find cards past the first by setting the 'current_tag'
-	   on cards as they are found.  Cards with their tag set will not
-	   respond to subsequent ID sequences. */
-
-	outb(0x00, id_port);
-	outb(0x00, id_port);
-	for(i = 0; i < 255; i++) {
-		outb(lrs_state, id_port);
-		lrs_state <<= 1;
-		lrs_state = lrs_state & 0x100 ? lrs_state ^ 0xcf : lrs_state;
-	}
-
-	/* For the first probe, clear all board's tag registers. */
-	if (current_tag == 0)
-		outb(0xd0, id_port);
-	else				/* Otherwise kill off already-found boards. */
-		outb(0xd8, id_port);
-
-	if (id_read_eeprom(7) != 0x6d50) {
-		return -ENODEV;
-	}
-
-	/* Read in EEPROM data, which does contention-select.
-	   Only the lowest address board will stay "on-line".
-	   3Com got the byte order backwards. */
-	for (i = 0; i < 3; i++) {
-		phys_addr[i] = htons(id_read_eeprom(i));
-	}
-
-#if defined(__ISAPNP__)
-	if (nopnp == 0) {
-		/* The ISA PnP 3c509 cards respond to the ID sequence.
-		   This check is needed in order not to register them twice. */
-		for (i = 0; i < pnp_cards; i++) {
-			if (phys_addr[0] == el3_isapnp_phys_addr[i][0] &&
-			    phys_addr[1] == el3_isapnp_phys_addr[i][1] &&
-			    phys_addr[2] == el3_isapnp_phys_addr[i][2])
-			{
-				if (el3_debug > 3)
-					printk("3c509 with address %02x %02x %02x %02x %02x %02x was 
found by ISAPnP\n",
-						phys_addr[0] & 0xff, phys_addr[0] >> 8,
-						phys_addr[1] & 0xff, phys_addr[1] >> 8,
-						phys_addr[2] & 0xff, phys_addr[2] >> 8);
-				/* Set the adaptor tag so that the next card can be found. */
-				outb(0xd0 + ++current_tag, id_port);
-				goto no_pnp;
-			}
-		}
-	}
-#endif /* __ISAPNP__ */
-
-	{
-		unsigned int iobase = id_read_eeprom(8);
-		if_port = iobase >> 14;
-		ioaddr = 0x200 + ((iobase & 0x1f) << 4);
-	}
-	irq = id_read_eeprom(9) >> 12;
-
-	dev = alloc_etherdev(sizeof (struct el3_private));
-	if (!dev)
-		return -ENOMEM;
-
-	netdev_boot_setup_check(dev);
-
-	/* Set passed-in IRQ or I/O Addr. */
-	if (dev->irq > 1  &&  dev->irq < 16)
-			irq = dev->irq;
-
-	if (dev->base_addr) {
-		if (dev->mem_end == 0x3c509 	/* Magic key */
-		    && dev->base_addr >= 0x200  &&  dev->base_addr <= 0x3e0)
-			ioaddr = dev->base_addr & 0x3f0;
-		else if (dev->base_addr != ioaddr)
-			goto out;
-	}
-
-	if (!request_region(ioaddr, EL3_IO_EXTENT, "3c509")) {
-		err = -EBUSY;
-		goto out;
-	}
-
-	/* Set the adaptor tag so that the next card can be found. */
-	outb(0xd0 + ++current_tag, id_port);
-
-	/* Activate the adaptor at the EEPROM location. */
-	outb((ioaddr >> 4) | 0xe0, id_port);
-
-	EL3WINDOW(0);
-	if (inw(ioaddr) != 0x6d50)
-		goto out1;
-
-	/* Free the interrupt so that some other card can use it. */
-	outw(0x0f00, ioaddr + WN0_IRQ);
-
-#if defined(__ISAPNP__)
- found:							/* PNP jumps here... */
-#endif /* __ISAPNP__ */
-
-	memcpy(dev->dev_addr, phys_addr, sizeof(phys_addr));
-	dev->base_addr = ioaddr;
-	dev->irq = irq;
-	dev->if_port = if_port;
-	lp = netdev_priv(dev);
-#if defined(__ISAPNP__)
-	lp->dev = &idev->dev;
-	if (pnp_found)
-		lp->type = EL3_PNP;
-#endif
-	err = el3_common_init(dev);
-
-	if (err)
-		goto out1;
-
-	el3_cards++;
-	lp->next_dev = el3_root_dev;
-	el3_root_dev = dev;
-	return 0;
-
-out1:
-#if defined(__ISAPNP__)
-	if (idev)
-		pnp_device_detach(idev);
-#endif
-out:
-	free_netdev(dev);
-	return err;
-}
-
 #ifdef CONFIG_MCA
 static int __init el3_mca_probe(struct device *device)
 {
@@ -596,7 +604,6 @@
 	 * redone for multi-card detection by ZP Gu (zpg@castle.net)
 	 * now works as a module */
 
-	struct el3_private *lp;
 	short i;
 	int ioaddr, irq, if_port;
 	u16 phys_addr[3];
@@ -613,7 +620,7 @@
 	irq = pos5 & 0x0f;
 
 
-	printk("3c529: found %s at slot %d\n",
+	printk(KERN_INFO "3c529: found %s at slot %d\n",
 		   el3_mca_adapter_names[mdev->index], slot + 1);
 
 	/* claim the slot */
@@ -626,7 +633,7 @@
 	irq = mca_device_transform_irq(mdev, irq);
 	ioaddr = mca_device_transform_ioport(mdev, ioaddr);
 	if (el3_debug > 2) {
-			printk("3c529: irq %d  ioaddr 0x%x  ifport %d\n", irq, ioaddr, if_port);
+			printk(KERN_DEBUG "3c529: irq %d  ioaddr 0x%x  ifport %d\n", irq, ioaddr, 
if_port);
 	}
 	EL3WINDOW(0);
 	for (i = 0; i < 3; i++) {
@@ -641,13 +648,7 @@
 
 	netdev_boot_setup_check(dev);
 
-	memcpy(dev->dev_addr, phys_addr, sizeof(phys_addr));
-	dev->base_addr = ioaddr;
-	dev->irq = irq;
-	dev->if_port = if_port;
-	lp = netdev_priv(dev);
-	lp->dev = device;
-	lp->type = EL3_MCA;
+	el3_dev_fill(dev, phys_addr, ioaddr, irq, if_port, EL3_MCA);
 	device->driver_data = dev;
 	err = el3_common_init(dev);
 
@@ -657,7 +658,7 @@
 		return -ENOMEM;
 	}
 
-	el3_cards++;
+	el3_devs[el3_cards++] = dev;
 	return 0;
 }
 
@@ -666,7 +667,6 @@
 #ifdef CONFIG_EISA
 static int __init el3_eisa_probe (struct device *device)
 {
-	struct el3_private *lp;
 	short i;
 	int ioaddr, irq, if_port;
 	u16 phys_addr[3];
@@ -678,7 +678,7 @@
 	edev = to_eisa_device (device);
 	ioaddr = edev->base_addr;
 
-	if (!request_region(ioaddr, EL3_IO_EXTENT, "3c509"))
+	if (!request_region(ioaddr, EL3_IO_EXTENT, "3c579-eisa"))
 		return -EBUSY;
 
 	/* Change the register set to the configuration window 0. */
@@ -700,13 +700,7 @@
 
 	netdev_boot_setup_check(dev);
 
-	memcpy(dev->dev_addr, phys_addr, sizeof(phys_addr));
-	dev->base_addr = ioaddr;
-	dev->irq = irq;
-	dev->if_port = if_port;
-	lp = netdev_priv(dev);
-	lp->dev = device;
-	lp->type = EL3_EISA;
+	el3_dev_fill(dev, phys_addr, ioaddr, irq, if_port, EL3_EISA);
 	eisa_set_drvdata (edev, dev);
 	err = el3_common_init(dev);
 
@@ -716,12 +710,11 @@
 		return err;
 	}
 
-	el3_cards++;
+	el3_devs[el3_cards++] = dev;
 	return 0;
 }
 #endif
 
-#if defined(CONFIG_EISA) || defined(CONFIG_MCA)
 /* This remove works for all device types.
  *
  * The net dev must be stored in the driver_data field */
@@ -734,7 +727,6 @@
 	el3_common_remove (dev);
 	return 0;
 }
-#endif
 
 /* Read a word from the EEPROM using the regular EEPROM access register.
    Assume that we are in register window zero.
@@ -749,7 +741,7 @@
 }
 
 /* Read a word from the EEPROM when in the ISA ID probe state. */
-static ushort __init id_read_eeprom(int index)
+static ushort id_read_eeprom(int index)
 {
 	int bit, word = 0;
 
@@ -765,7 +757,7 @@
 		word = (word << 1) + (inb(id_port) & 0x01);
 
 	if (el3_debug > 3)
-		printk("  3c509 EEPROM word %d %#4.4x.\n", index, word);
+		printk(KERN_DEBUG "  3c509 EEPROM word %d %#4.4x.\n", index, word);
 
 	return word;
 }
@@ -787,13 +779,13 @@
 
 	EL3WINDOW(0);
 	if (el3_debug > 3)
-		printk("%s: Opening, IRQ %d	 status@%x %4.4x.\n", dev->name,
+		printk(KERN_DEBUG "%s: Opening, IRQ %d	 status@%x %4.4x.\n", dev->name,
 			   dev->irq, ioaddr + EL3_STATUS, inw(ioaddr + EL3_STATUS));
 
 	el3_up(dev);
 
 	if (el3_debug > 3)
-		printk("%s: Opened 3c509  IRQ %d  status %4.4x.\n",
+		printk(KERN_DEBUG "%s: Opened 3c509  IRQ %d  status %4.4x.\n",
 			   dev->name, dev->irq, inw(ioaddr + EL3_STATUS));
 
 	return 0;
@@ -806,7 +798,7 @@
 	int ioaddr = dev->base_addr;
 
 	/* Transmitter timeout, serious problems. */
-	printk("%s: transmit timed out, Tx_status %2.2x status %4.4x "
+	printk(KERN_WARNING "%s: transmit timed out, Tx_status %2.2x status %4.4x "
 		   "Tx FIFO room %d.\n",
 		   dev->name, inb(ioaddr + TX_STATUS), inw(ioaddr + EL3_STATUS),
 		   inw(ioaddr + TX_FREE));
@@ -831,7 +823,7 @@
 	lp->stats.tx_bytes += skb->len;
 
 	if (el3_debug > 4) {
-		printk("%s: el3_start_xmit(length = %u) called, status %4.4x.\n",
+		printk(KERN_DEBUG "%s: el3_start_xmit(length = %u) called, status %4.4x.\n",
 			   dev->name, skb->len, inw(ioaddr + EL3_STATUS));
 	}
 #if 0
@@ -840,7 +832,7 @@
 		ushort status = inw(ioaddr + EL3_STATUS);
 		if (status & 0x0001 		/* IRQ line active, missed one. */
 			&& inw(ioaddr + EL3_STATUS) & 1) { 			/* Make sure. */
-			printk("%s: Missed interrupt, status then %04x now %04x"
+			printk(KERN_DEBUG "%s: Missed interrupt, status then %04x now %04x"
 				   "  Tx %2.2x Rx %4.4x.\n", dev->name, status,
 				   inw(ioaddr + EL3_STATUS), inb(ioaddr + TX_STATUS),
 				   inw(ioaddr + RX_STATUS));
@@ -914,7 +906,7 @@
 
 	if (el3_debug > 4) {
 		status = inw(ioaddr + EL3_STATUS);
-		printk("%s: interrupt, status %4.4x.\n", dev->name, status);
+		printk(KERN_DEBUG "%s: interrupt, status %4.4x.\n", dev->name, status);
 	}
 
 	while ((status = inw(ioaddr + EL3_STATUS)) &
@@ -925,7 +917,7 @@
 
 		if (status & TxAvailable) {
 			if (el3_debug > 5)
-				printk("	TX room bit was handled.\n");
+				printk(KERN_DEBUG "	TX room bit was handled.\n");
 			/* There's room in the FIFO for a full-sized packet. */
 			outw(AckIntr | TxAvailable, ioaddr + EL3_CMD);
 			netif_wake_queue (dev);
@@ -964,7 +956,7 @@
 		}
 
 		if (--i < 0) {
-			printk("%s: Infinite loop in interrupt, status %4.4x.\n",
+			printk(KERN_ERR "%s: Infinite loop in interrupt, status %4.4x.\n",
 				   dev->name, status);
 			/* Clear all interrupts. */
 			outw(AckIntr | 0xFF, ioaddr + EL3_CMD);
@@ -975,7 +967,7 @@
 	}
 
 	if (el3_debug > 4) {
-		printk("%s: exiting interrupt, status %4.4x.\n", dev->name,
+		printk(KERN_DEBUG "%s: exiting interrupt, status %4.4x.\n", dev->name,
 			   inw(ioaddr + EL3_STATUS));
 	}
 	spin_unlock(&lp->lock);
@@ -1450,7 +1442,7 @@
 }
 
 /* Power Management support functions */
-#ifdef EL3_SUSPEND
+#ifdef CONFIG_PM
 
 static int
 el3_suspend(struct device *pdev, pm_message_t state)
@@ -1500,79 +1492,102 @@
 	return 0;
 }
 
-#endif /* EL3_SUSPEND */
-
-/* Parameters that may be passed into the module. */
-static int debug = -1;
-static int irq[] = {-1, -1, -1, -1, -1, -1, -1, -1};
-static int xcvr[] = {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1};
+#endif /* CONFIG_PM */
 
 module_param(debug,int, 0);
 module_param_array(irq, int, NULL, 0);
-module_param_array(xcvr, int, NULL, 0);
 module_param(max_interrupt_work, int, 0);
 MODULE_PARM_DESC(debug, "debug level (0-6)");
 MODULE_PARM_DESC(irq, "IRQ number(s) (assigned)");
-MODULE_PARM_DESC(xcvr,"transceiver(s) (0=internal, 1=external)");
 MODULE_PARM_DESC(max_interrupt_work, "maximum events handled per interrupt");
-#if defined(__ISAPNP__)
+#ifdef CONFIG_PNP
 module_param(nopnp, int, 0);
 MODULE_PARM_DESC(nopnp, "disable ISA PnP support (0-1)");
-MODULE_DEVICE_TABLE(isapnp, el3_isapnp_adapters);
-#endif	/* __ISAPNP__ */
-MODULE_DESCRIPTION("3Com Etherlink III (3c509, 3c509B) ISA/PnP ethernet driver");
+#endif	/* CONFIG_PNP */
+MODULE_DESCRIPTION("3Com Etherlink III (3c509, 3c509B, 3c529, 3c579) ethernet driver");
 MODULE_LICENSE("GPL");
 
 static int __init el3_init_module(void)
 {
 	int ret = 0;
-	el3_cards = 0;
 
 	if (debug >= 0)
 		el3_debug = debug;
 
-	el3_root_dev = NULL;
-	while (el3_probe(el3_cards) == 0) {
-		if (irq[el3_cards] > 1)
-			el3_root_dev->irq = irq[el3_cards];
-		if (xcvr[el3_cards] >= 0)
-			el3_root_dev->if_port = xcvr[el3_cards];
-		el3_cards++;
+#ifdef CONFIG_PNP
+	if (!nopnp) {
+		ret = pnp_register_driver(&el3_pnp_driver);
+		if (!ret)
+			pnp_registered = 1;
+	}
+#endif
+	/* Select an open I/O location at 0x1*0 to do ISA contention select. */
+	/* Start with 0x110 to avoid some sound cards.*/
+	for (id_port = 0x110 ; id_port < 0x200; id_port += 0x10) {
+		if (!request_region(id_port, 1, "3c509-control"))
+			continue;
+		outb(0x00, id_port);
+		outb(0xff, id_port);
+		if (inb(id_port) & 0x01)
+			break;
+		else
+			release_region(id_port, 1);
+	}
+	if (id_port >= 0x200) {
+		id_port = 0;
+		printk(KERN_ERR "No I/O port available for 3c509 activation.\n");
+	} else {
+		ret = isa_register_driver(&el3_isa_driver, EL3_MAX_CARDS);
+		if (!ret)
+			isa_registered = 1;
 	}
-
 #ifdef CONFIG_EISA
 	ret = eisa_driver_register(&el3_eisa_driver);
+	if (!ret)
+		eisa_registered = 1;
 #endif
 #ifdef CONFIG_MCA
-	{
-		int err = mca_register_driver(&el3_mca_driver);
-		if (ret == 0)
-			ret = err;
-	}
+	ret = mca_register_driver(&el3_mca_driver);
+	if (!ret)
+		mca_registered = 1;
+#endif
+
+#ifdef CONFIG_PNP
+	if (pnp_registered)
+		ret = 0;
+#endif
+	if (isa_registered)
+		ret = 0;
+#ifdef CONFIG_EISA
+	if (eisa_registered)
+		ret = 0;
+#endif
+#ifdef CONFIG_MCA
+	if (mca_registered)
+		ret = 0;
 #endif
 	return ret;
 }
 
 static void __exit el3_cleanup_module(void)
 {
-	struct net_device *next_dev;
-
-	while (el3_root_dev) {
-		struct el3_private *lp = netdev_priv(el3_root_dev);
-
-		next_dev = lp->next_dev;
-		el3_common_remove (el3_root_dev);
-		el3_root_dev = next_dev;
-	}
-
+#ifdef CONFIG_PNP
+	if (pnp_registered)
+		pnp_unregister_driver(&el3_pnp_driver);
+#endif
+	if (isa_registered)
+		isa_unregister_driver(&el3_isa_driver);
+	if (id_port)
+		release_region(id_port, 1);
 #ifdef CONFIG_EISA
-	eisa_driver_unregister (&el3_eisa_driver);
+	if (eisa_registered)
+		eisa_driver_unregister(&el3_eisa_driver);
 #endif
 #ifdef CONFIG_MCA
-	mca_unregister_driver(&el3_mca_driver);
+	if (mca_registered)
+		mca_unregister_driver(&el3_mca_driver);
 #endif
 }
 
 module_init (el3_init_module);
 module_exit (el3_cleanup_module);
-

-- 
Ondrej Zary
