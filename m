From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver updates
Date: Fri, 28 Mar 2008 22:24:21 -0400
Message-ID: <20080329022421.GA22635@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:54923 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756302AbYC2CYj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 22:24:39 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Updates for net-2.6.26.


Please pull from 'upstream-net26' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-net26

to receive the following updates:

 drivers/net/3c509.c            |  729 ++++++++++++++++++++--------------------
 drivers/net/arcnet/arcnet.c    |    5 +-
 drivers/net/e1000e/82571.c     |  127 +++++---
 drivers/net/e1000e/Makefile    |    2 +-
 drivers/net/e1000e/defines.h   |  109 ++++---
 drivers/net/e1000e/e1000.h     |   29 +-
 drivers/net/e1000e/es2lan.c    |  105 ++++---
 drivers/net/e1000e/ethtool.c   |  161 ++++++----
 drivers/net/e1000e/hw.h        |  171 +++++-----
 drivers/net/e1000e/ich8lan.c   |  279 +++++++++-------
 drivers/net/e1000e/lib.c       |  286 ++++++++++-------
 drivers/net/e1000e/netdev.c    |  592 +++++++++++++++++++++------------
 drivers/net/e1000e/param.c     |   33 ++-
 drivers/net/e1000e/phy.c       |  164 ++++++----
 drivers/net/ehea/ehea.h        |    6 +-
 drivers/net/ehea/ehea_main.c   |   90 +++---
 drivers/net/ixgbe/ixgbe_main.c |    6 +-
 drivers/net/tokenring/3c359.c  |   21 +-
 drivers/net/yellowfin.c        |    4 +-
 include/linux/arcdevice.h      |    4 +-
 20 files changed, 1678 insertions(+), 1245 deletions(-)

Bruce Allan (1):
      e1000e: reformat comment blocks, cosmetic changes only

Daniel Walker (5):
      netdev: ehea: semaphore to mutex
      netdev: ehea: ehea_fw_handles semaphore to mutex
      netdev: ehea: locking order correction
      netdev: ehea: bcmc_regs semaphore to mutex
      netdev: ehea: port_lock semaphore to mutex

Denis V. Lunev (1):
      Compilation fix for ixgbe_main.c.

Jeff Kirsher (2):
      e1000e: rename mc_addr_list_update
      e1000e: reorganize PHY and flow control interface

Mariusz Kozlowski (1):
      net: yellowfin parenthesis fix

Ondrej Zary (1):
      3c509: convert to isa_driver and pnp_driver

S.Caglar Onur (2):
      drivers/net/arcnet/arcnet.c: use time_* macros
      drivers/net/tokenring/3c359.c: use time_* macros

diff --git a/drivers/net/3c509.c b/drivers/net/3c509.c
index 8fafac9..54dac06 100644
--- a/drivers/net/3c509.c
+++ b/drivers/net/3c509.c
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
@@ -97,10 +96,6 @@ static int max_interrupt_work = 10;
 
 static char version[] __initdata = DRV_NAME ".c:" DRV_VERSION " " DRV_RELDATE " becker@scyld.com\n";
 
-#if defined(CONFIG_PM) && (defined(CONFIG_MCA) || defined(CONFIG_EISA))
-#define EL3_SUSPEND
-#endif
-
 #ifdef EL3_DEBUG
 static int el3_debug = EL3_DEBUG;
 #else
@@ -111,6 +106,7 @@ static int el3_debug = 2;
  * a global variable so that the mca/eisa probe routines can increment
  * it */
 static int el3_cards = 0;
+#define EL3_MAX_CARDS 8
 
 /* To minimize the size of the driver source I only define operating
    constants if they are used several times.  You'll need the manual
@@ -119,7 +115,7 @@ static int el3_cards = 0;
 #define EL3_DATA 0x00
 #define EL3_CMD 0x0e
 #define EL3_STATUS 0x0e
-#define	 EEPROM_READ 0x80
+#define	EEPROM_READ 0x80
 
 #define EL3_IO_EXTENT	16
 
@@ -168,23 +164,31 @@ enum RxFilter {
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
@@ -199,7 +203,7 @@ static void el3_tx_timeout (struct net_device *dev);
 static void el3_down(struct net_device *dev);
 static void el3_up(struct net_device *dev);
 static const struct ethtool_ops ethtool_ops;
-#ifdef EL3_SUSPEND
+#ifdef CONFIG_PM
 static int el3_suspend(struct device *, pm_message_t);
 static int el3_resume(struct device *);
 #else
@@ -209,13 +213,272 @@ static int el3_resume(struct device *);
 
 
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
+					printk(KERN_DEBUG "3c509 with address %02x %02x %02x %02x %02x %02x was found by ISAPnP\n",
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
@@ -230,13 +493,14 @@ static int el3_eisa_probe (struct device *device);
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
@@ -271,45 +535,9 @@ static struct mca_driver el3_mca_driver = {
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
@@ -360,231 +588,11 @@ static int __init el3_common_init(struct net_device *dev)
 
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
-					printk("3c509 with address %02x %02x %02x %02x %02x %02x was found by ISAPnP\n",
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
@@ -596,7 +604,6 @@ static int __init el3_mca_probe(struct device *device)
 	 * redone for multi-card detection by ZP Gu (zpg@castle.net)
 	 * now works as a module */
 
-	struct el3_private *lp;
 	short i;
 	int ioaddr, irq, if_port;
 	u16 phys_addr[3];
@@ -613,7 +620,7 @@ static int __init el3_mca_probe(struct device *device)
 	irq = pos5 & 0x0f;
 
 
-	printk("3c529: found %s at slot %d\n",
+	printk(KERN_INFO "3c529: found %s at slot %d\n",
 		   el3_mca_adapter_names[mdev->index], slot + 1);
 
 	/* claim the slot */
@@ -626,7 +633,7 @@ static int __init el3_mca_probe(struct device *device)
 	irq = mca_device_transform_irq(mdev, irq);
 	ioaddr = mca_device_transform_ioport(mdev, ioaddr);
 	if (el3_debug > 2) {
-			printk("3c529: irq %d  ioaddr 0x%x  ifport %d\n", irq, ioaddr, if_port);
+			printk(KERN_DEBUG "3c529: irq %d  ioaddr 0x%x  ifport %d\n", irq, ioaddr, if_port);
 	}
 	EL3WINDOW(0);
 	for (i = 0; i < 3; i++) {
@@ -641,13 +648,7 @@ static int __init el3_mca_probe(struct device *device)
 
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
 
@@ -657,7 +658,7 @@ static int __init el3_mca_probe(struct device *device)
 		return -ENOMEM;
 	}
 
-	el3_cards++;
+	el3_devs[el3_cards++] = dev;
 	return 0;
 }
 
@@ -666,7 +667,6 @@ static int __init el3_mca_probe(struct device *device)
 #ifdef CONFIG_EISA
 static int __init el3_eisa_probe (struct device *device)
 {
-	struct el3_private *lp;
 	short i;
 	int ioaddr, irq, if_port;
 	u16 phys_addr[3];
@@ -678,7 +678,7 @@ static int __init el3_eisa_probe (struct device *device)
 	edev = to_eisa_device (device);
 	ioaddr = edev->base_addr;
 
-	if (!request_region(ioaddr, EL3_IO_EXTENT, "3c509"))
+	if (!request_region(ioaddr, EL3_IO_EXTENT, "3c579-eisa"))
 		return -EBUSY;
 
 	/* Change the register set to the configuration window 0. */
@@ -700,13 +700,7 @@ static int __init el3_eisa_probe (struct device *device)
 
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
 
@@ -716,12 +710,11 @@ static int __init el3_eisa_probe (struct device *device)
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
@@ -734,7 +727,6 @@ static int __devexit el3_device_remove (struct device *device)
 	el3_common_remove (dev);
 	return 0;
 }
-#endif
 
 /* Read a word from the EEPROM using the regular EEPROM access register.
    Assume that we are in register window zero.
@@ -749,7 +741,7 @@ static ushort read_eeprom(int ioaddr, int index)
 }
 
 /* Read a word from the EEPROM when in the ISA ID probe state. */
-static ushort __init id_read_eeprom(int index)
+static ushort id_read_eeprom(int index)
 {
 	int bit, word = 0;
 
@@ -765,7 +757,7 @@ static ushort __init id_read_eeprom(int index)
 		word = (word << 1) + (inb(id_port) & 0x01);
 
 	if (el3_debug > 3)
-		printk("  3c509 EEPROM word %d %#4.4x.\n", index, word);
+		printk(KERN_DEBUG "  3c509 EEPROM word %d %#4.4x.\n", index, word);
 
 	return word;
 }
@@ -787,13 +779,13 @@ el3_open(struct net_device *dev)
 
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
@@ -806,7 +798,7 @@ el3_tx_timeout (struct net_device *dev)
 	int ioaddr = dev->base_addr;
 
 	/* Transmitter timeout, serious problems. */
-	printk("%s: transmit timed out, Tx_status %2.2x status %4.4x "
+	printk(KERN_WARNING "%s: transmit timed out, Tx_status %2.2x status %4.4x "
 		   "Tx FIFO room %d.\n",
 		   dev->name, inb(ioaddr + TX_STATUS), inw(ioaddr + EL3_STATUS),
 		   inw(ioaddr + TX_FREE));
@@ -831,7 +823,7 @@ el3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	lp->stats.tx_bytes += skb->len;
 
 	if (el3_debug > 4) {
-		printk("%s: el3_start_xmit(length = %u) called, status %4.4x.\n",
+		printk(KERN_DEBUG "%s: el3_start_xmit(length = %u) called, status %4.4x.\n",
 			   dev->name, skb->len, inw(ioaddr + EL3_STATUS));
 	}
 #if 0
@@ -840,7 +832,7 @@ el3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		ushort status = inw(ioaddr + EL3_STATUS);
 		if (status & 0x0001 		/* IRQ line active, missed one. */
 			&& inw(ioaddr + EL3_STATUS) & 1) { 			/* Make sure. */
-			printk("%s: Missed interrupt, status then %04x now %04x"
+			printk(KERN_DEBUG "%s: Missed interrupt, status then %04x now %04x"
 				   "  Tx %2.2x Rx %4.4x.\n", dev->name, status,
 				   inw(ioaddr + EL3_STATUS), inb(ioaddr + TX_STATUS),
 				   inw(ioaddr + RX_STATUS));
@@ -914,7 +906,7 @@ el3_interrupt(int irq, void *dev_id)
 
 	if (el3_debug > 4) {
 		status = inw(ioaddr + EL3_STATUS);
-		printk("%s: interrupt, status %4.4x.\n", dev->name, status);
+		printk(KERN_DEBUG "%s: interrupt, status %4.4x.\n", dev->name, status);
 	}
 
 	while ((status = inw(ioaddr + EL3_STATUS)) &
@@ -925,7 +917,7 @@ el3_interrupt(int irq, void *dev_id)
 
 		if (status & TxAvailable) {
 			if (el3_debug > 5)
-				printk("	TX room bit was handled.\n");
+				printk(KERN_DEBUG "	TX room bit was handled.\n");
 			/* There's room in the FIFO for a full-sized packet. */
 			outw(AckIntr | TxAvailable, ioaddr + EL3_CMD);
 			netif_wake_queue (dev);
@@ -964,7 +956,7 @@ el3_interrupt(int irq, void *dev_id)
 		}
 
 		if (--i < 0) {
-			printk("%s: Infinite loop in interrupt, status %4.4x.\n",
+			printk(KERN_ERR "%s: Infinite loop in interrupt, status %4.4x.\n",
 				   dev->name, status);
 			/* Clear all interrupts. */
 			outw(AckIntr | 0xFF, ioaddr + EL3_CMD);
@@ -975,7 +967,7 @@ el3_interrupt(int irq, void *dev_id)
 	}
 
 	if (el3_debug > 4) {
-		printk("%s: exiting interrupt, status %4.4x.\n", dev->name,
+		printk(KERN_DEBUG "%s: exiting interrupt, status %4.4x.\n", dev->name,
 			   inw(ioaddr + EL3_STATUS));
 	}
 	spin_unlock(&lp->lock);
@@ -1450,7 +1442,7 @@ el3_up(struct net_device *dev)
 }
 
 /* Power Management support functions */
-#ifdef EL3_SUSPEND
+#ifdef CONFIG_PM
 
 static int
 el3_suspend(struct device *pdev, pm_message_t state)
@@ -1500,79 +1492,102 @@ el3_resume(struct device *pdev)
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
diff --git a/drivers/net/arcnet/arcnet.c b/drivers/net/arcnet/arcnet.c
index c59c806..bdc4c0b 100644
--- a/drivers/net/arcnet/arcnet.c
+++ b/drivers/net/arcnet/arcnet.c
@@ -940,7 +940,7 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 
 			/* is the RECON info empty or old? */
 			if (!lp->first_recon || !lp->last_recon ||
-			    jiffies - lp->last_recon > HZ * 10) {
+			    time_after(jiffies, lp->last_recon + HZ * 10)) {
 				if (lp->network_down)
 					BUGMSG(D_NORMAL, "reconfiguration detected: cabling restored?\n");
 				lp->first_recon = lp->last_recon = jiffies;
@@ -974,7 +974,8 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 					lp->num_recons = 1;
 				}
 			}
-		} else if (lp->network_down && jiffies - lp->last_recon > HZ * 10) {
+		} else if (lp->network_down &&
+				time_after(jiffies, lp->last_recon + HZ * 10)) {
 			if (lp->network_down)
 				BUGMSG(D_NORMAL, "cabling restored?\n");
 			lp->first_recon = lp->last_recon = 0;
diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index 7fe2031..f7e1619 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2007 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -29,6 +29,9 @@
 /*
  * 82571EB Gigabit Ethernet Controller
  * 82571EB Gigabit Ethernet Controller (Fiber)
+ * 82571EB Dual Port Gigabit Mezzanine Adapter
+ * 82571EB Quad Port Gigabit Mezzanine Adapter
+ * 82571PT Gigabit PT Quad Port Server ExpressModule
  * 82572EI Gigabit Ethernet Controller (Copper)
  * 82572EI Gigabit Ethernet Controller (Fiber)
  * 82572EI Gigabit Ethernet Controller
@@ -72,7 +75,7 @@ static s32 e1000_init_phy_params_82571(struct e1000_hw *hw)
 	struct e1000_phy_info *phy = &hw->phy;
 	s32 ret_val;
 
-	if (hw->media_type != e1000_media_type_copper) {
+	if (hw->phy.media_type != e1000_media_type_copper) {
 		phy->type = e1000_phy_none;
 		return 0;
 	}
@@ -150,7 +153,8 @@ static s32 e1000_init_nvm_params_82571(struct e1000_hw *hw)
 		if (((eecd >> 15) & 0x3) == 0x3) {
 			nvm->type = e1000_nvm_flash_hw;
 			nvm->word_size = 2048;
-			/* Autonomous Flash update bit must be cleared due
+			/*
+			 * Autonomous Flash update bit must be cleared due
 			 * to Flash update issue.
 			 */
 			eecd &= ~E1000_EECD_AUPDEN;
@@ -159,10 +163,11 @@ static s32 e1000_init_nvm_params_82571(struct e1000_hw *hw)
 		}
 		/* Fall Through */
 	default:
-		nvm->type	= e1000_nvm_eeprom_spi;
+		nvm->type = e1000_nvm_eeprom_spi;
 		size = (u16)((eecd & E1000_EECD_SIZE_EX_MASK) >>
 				  E1000_EECD_SIZE_EX_SHIFT);
-		/* Added to a constant, "size" becomes the left-shift value
+		/*
+		 * Added to a constant, "size" becomes the left-shift value
 		 * for setting word_size.
 		 */
 		size += NVM_WORD_SIZE_BASE_SHIFT;
@@ -190,16 +195,16 @@ static s32 e1000_init_mac_params_82571(struct e1000_adapter *adapter)
 	case E1000_DEV_ID_82571EB_FIBER:
 	case E1000_DEV_ID_82572EI_FIBER:
 	case E1000_DEV_ID_82571EB_QUAD_FIBER:
-		hw->media_type = e1000_media_type_fiber;
+		hw->phy.media_type = e1000_media_type_fiber;
 		break;
 	case E1000_DEV_ID_82571EB_SERDES:
 	case E1000_DEV_ID_82572EI_SERDES:
 	case E1000_DEV_ID_82571EB_SERDES_DUAL:
 	case E1000_DEV_ID_82571EB_SERDES_QUAD:
-		hw->media_type = e1000_media_type_internal_serdes;
+		hw->phy.media_type = e1000_media_type_internal_serdes;
 		break;
 	default:
-		hw->media_type = e1000_media_type_copper;
+		hw->phy.media_type = e1000_media_type_copper;
 		break;
 	}
 
@@ -208,25 +213,28 @@ static s32 e1000_init_mac_params_82571(struct e1000_adapter *adapter)
 	/* Set rar entry count */
 	mac->rar_entry_count = E1000_RAR_ENTRIES;
 	/* Set if manageability features are enabled. */
-	mac->arc_subsystem_valid =
-		(er32(FWSM) & E1000_FWSM_MODE_MASK) ? 1 : 0;
+	mac->arc_subsystem_valid = (er32(FWSM) & E1000_FWSM_MODE_MASK) ? 1 : 0;
 
 	/* check for link */
-	switch (hw->media_type) {
+	switch (hw->phy.media_type) {
 	case e1000_media_type_copper:
 		func->setup_physical_interface = e1000_setup_copper_link_82571;
 		func->check_for_link = e1000e_check_for_copper_link;
 		func->get_link_up_info = e1000e_get_speed_and_duplex_copper;
 		break;
 	case e1000_media_type_fiber:
-		func->setup_physical_interface = e1000_setup_fiber_serdes_link_82571;
+		func->setup_physical_interface =
+			e1000_setup_fiber_serdes_link_82571;
 		func->check_for_link = e1000e_check_for_fiber_link;
-		func->get_link_up_info = e1000e_get_speed_and_duplex_fiber_serdes;
+		func->get_link_up_info =
+			e1000e_get_speed_and_duplex_fiber_serdes;
 		break;
 	case e1000_media_type_internal_serdes:
-		func->setup_physical_interface = e1000_setup_fiber_serdes_link_82571;
+		func->setup_physical_interface =
+			e1000_setup_fiber_serdes_link_82571;
 		func->check_for_link = e1000e_check_for_serdes_link;
-		func->get_link_up_info = e1000e_get_speed_and_duplex_fiber_serdes;
+		func->get_link_up_info =
+			e1000e_get_speed_and_duplex_fiber_serdes;
 		break;
 	default:
 		return -E1000_ERR_CONFIG;
@@ -322,10 +330,12 @@ static s32 e1000_get_phy_id_82571(struct e1000_hw *hw)
 	switch (hw->mac.type) {
 	case e1000_82571:
 	case e1000_82572:
-		/* The 82571 firmware may still be configuring the PHY.
+		/*
+		 * The 82571 firmware may still be configuring the PHY.
 		 * In this case, we cannot access the PHY until the
 		 * configuration is done.  So we explicitly set the
-		 * PHY ID. */
+		 * PHY ID.
+		 */
 		phy->id = IGP01E1000_I_PHY_ID;
 		break;
 	case e1000_82573:
@@ -479,8 +489,10 @@ static s32 e1000_update_nvm_checksum_82571(struct e1000_hw *hw)
 	if (ret_val)
 		return ret_val;
 
-	/* If our nvm is an EEPROM, then we're done
-	 * otherwise, commit the checksum to the flash NVM. */
+	/*
+	 * If our nvm is an EEPROM, then we're done
+	 * otherwise, commit the checksum to the flash NVM.
+	 */
 	if (hw->nvm.type != e1000_nvm_flash_hw)
 		return ret_val;
 
@@ -496,7 +508,8 @@ static s32 e1000_update_nvm_checksum_82571(struct e1000_hw *hw)
 
 	/* Reset the firmware if using STM opcode. */
 	if ((er32(FLOP) & 0xFF00) == E1000_STM_OPCODE) {
-		/* The enabling of and the actual reset must be done
+		/*
+		 * The enabling of and the actual reset must be done
 		 * in two write cycles.
 		 */
 		ew32(HICR, E1000_HICR_FW_RESET_ENABLE);
@@ -557,8 +570,10 @@ static s32 e1000_write_nvm_eewr_82571(struct e1000_hw *hw, u16 offset,
 	u32 eewr = 0;
 	s32 ret_val = 0;
 
-	/* A check for invalid values:  offset too large, too many words,
-	 * and not enough words. */
+	/*
+	 * A check for invalid values:  offset too large, too many words,
+	 * and not enough words.
+	 */
 	if ((offset >= nvm->word_size) || (words > (nvm->word_size - offset)) ||
 	    (words == 0)) {
 		hw_dbg(hw, "nvm parameter(s) out of bounds\n");
@@ -645,30 +660,32 @@ static s32 e1000_set_d0_lplu_state_82571(struct e1000_hw *hw, bool active)
 	} else {
 		data &= ~IGP02E1000_PM_D0_LPLU;
 		ret_val = e1e_wphy(hw, IGP02E1000_PHY_POWER_MGMT, data);
-		/* LPLU and SmartSpeed are mutually exclusive.  LPLU is used
+		/*
+		 * LPLU and SmartSpeed are mutually exclusive.  LPLU is used
 		 * during Dx states where the power conservation is most
 		 * important.  During driver activity we should enable
-		 * SmartSpeed, so performance is maintained. */
+		 * SmartSpeed, so performance is maintained.
+		 */
 		if (phy->smart_speed == e1000_smart_speed_on) {
 			ret_val = e1e_rphy(hw, IGP01E1000_PHY_PORT_CONFIG,
-						     &data);
+					   &data);
 			if (ret_val)
 				return ret_val;
 
 			data |= IGP01E1000_PSCFR_SMART_SPEED;
 			ret_val = e1e_wphy(hw, IGP01E1000_PHY_PORT_CONFIG,
-						     data);
+					   data);
 			if (ret_val)
 				return ret_val;
 		} else if (phy->smart_speed == e1000_smart_speed_off) {
 			ret_val = e1e_rphy(hw, IGP01E1000_PHY_PORT_CONFIG,
-						     &data);
+					   &data);
 			if (ret_val)
 				return ret_val;
 
 			data &= ~IGP01E1000_PSCFR_SMART_SPEED;
 			ret_val = e1e_wphy(hw, IGP01E1000_PHY_PORT_CONFIG,
-						     data);
+					   data);
 			if (ret_val)
 				return ret_val;
 		}
@@ -693,7 +710,8 @@ static s32 e1000_reset_hw_82571(struct e1000_hw *hw)
 	s32 ret_val;
 	u16 i = 0;
 
-	/* Prevent the PCI-E bus from sticking if there is no TLP connection
+	/*
+	 * Prevent the PCI-E bus from sticking if there is no TLP connection
 	 * on the last TLP read/write transaction when MAC is reset.
 	 */
 	ret_val = e1000e_disable_pcie_master(hw);
@@ -709,8 +727,10 @@ static s32 e1000_reset_hw_82571(struct e1000_hw *hw)
 
 	msleep(10);
 
-	/* Must acquire the MDIO ownership before MAC reset.
-	 * Ownership defaults to firmware after a reset. */
+	/*
+	 * Must acquire the MDIO ownership before MAC reset.
+	 * Ownership defaults to firmware after a reset.
+	 */
 	if (hw->mac.type == e1000_82573) {
 		extcnf_ctrl = er32(EXTCNF_CTRL);
 		extcnf_ctrl |= E1000_EXTCNF_CTRL_MDIO_SW_OWNERSHIP;
@@ -747,7 +767,8 @@ static s32 e1000_reset_hw_82571(struct e1000_hw *hw)
 		/* We don't want to continue accessing MAC registers. */
 		return ret_val;
 
-	/* Phy configuration from NVM just starts after EECD_AUTO_RD is set.
+	/*
+	 * Phy configuration from NVM just starts after EECD_AUTO_RD is set.
 	 * Need to wait for Phy configuration completion before accessing
 	 * NVM and Phy.
 	 */
@@ -793,7 +814,8 @@ static s32 e1000_init_hw_82571(struct e1000_hw *hw)
 	e1000e_clear_vfta(hw);
 
 	/* Setup the receive address. */
-	/* If, however, a locally administered address was assigned to the
+	/*
+	 * If, however, a locally administered address was assigned to the
 	 * 82571, we must reserve a RAR for it to work around an issue where
 	 * resetting one port will reload the MAC on the other port.
 	 */
@@ -830,7 +852,8 @@ static s32 e1000_init_hw_82571(struct e1000_hw *hw)
 		ew32(GCR, reg_data);
 	}
 
-	/* Clear all of the statistics registers (clear on read).  It is
+	/*
+	 * Clear all of the statistics registers (clear on read).  It is
 	 * important that we do this after we have tried to establish link
 	 * because the symbol error count will increment wildly if there
 	 * is no link.
@@ -922,7 +945,8 @@ void e1000e_clear_vfta(struct e1000_hw *hw)
 
 	if (hw->mac.type == e1000_82573) {
 		if (hw->mng_cookie.vlan_id != 0) {
-			/* The VFTA is a 4096b bit-field, each identifying
+			/*
+			 * The VFTA is a 4096b bit-field, each identifying
 			 * a single VLAN ID.  The following operations
 			 * determine which 32b entry (i.e. offset) into the
 			 * array we want to set the VLAN ID (i.e. bit) of
@@ -936,7 +960,8 @@ void e1000e_clear_vfta(struct e1000_hw *hw)
 		}
 	}
 	for (offset = 0; offset < E1000_VLAN_FILTER_TBL_SIZE; offset++) {
-		/* If the offset we want to clear is the same offset of the
+		/*
+		 * If the offset we want to clear is the same offset of the
 		 * manageability VLAN ID, then clear all bits except that of
 		 * the manageability unit.
 		 */
@@ -947,7 +972,7 @@ void e1000e_clear_vfta(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_mc_addr_list_update_82571 - Update Multicast addresses
+ *  e1000_update_mc_addr_list_82571 - Update Multicast addresses
  *  @hw: pointer to the HW structure
  *  @mc_addr_list: array of multicast addresses to program
  *  @mc_addr_count: number of multicast addresses to program
@@ -959,7 +984,7 @@ void e1000e_clear_vfta(struct e1000_hw *hw)
  *  The parameter rar_count will usually be hw->mac.rar_entry_count
  *  unless there are workarounds that change this.
  **/
-static void e1000_mc_addr_list_update_82571(struct e1000_hw *hw,
+static void e1000_update_mc_addr_list_82571(struct e1000_hw *hw,
 					    u8 *mc_addr_list,
 					    u32 mc_addr_count,
 					    u32 rar_used_count,
@@ -968,8 +993,8 @@ static void e1000_mc_addr_list_update_82571(struct e1000_hw *hw,
 	if (e1000e_get_laa_state_82571(hw))
 		rar_count--;
 
-	e1000e_mc_addr_list_update_generic(hw, mc_addr_list, mc_addr_count,
-					  rar_used_count, rar_count);
+	e1000e_update_mc_addr_list_generic(hw, mc_addr_list, mc_addr_count,
+					   rar_used_count, rar_count);
 }
 
 /**
@@ -984,12 +1009,13 @@ static void e1000_mc_addr_list_update_82571(struct e1000_hw *hw,
  **/
 static s32 e1000_setup_link_82571(struct e1000_hw *hw)
 {
-	/* 82573 does not have a word in the NVM to determine
+	/*
+	 * 82573 does not have a word in the NVM to determine
 	 * the default flow control setting, so we explicitly
 	 * set it to full.
 	 */
 	if (hw->mac.type == e1000_82573)
-		hw->mac.fc = e1000_fc_full;
+		hw->fc.type = e1000_fc_full;
 
 	return e1000e_setup_link(hw);
 }
@@ -1050,14 +1076,14 @@ static s32 e1000_setup_fiber_serdes_link_82571(struct e1000_hw *hw)
 	switch (hw->mac.type) {
 	case e1000_82571:
 	case e1000_82572:
-		/* If SerDes loopback mode is entered, there is no form
+		/*
+		 * If SerDes loopback mode is entered, there is no form
 		 * of reset to take the adapter out of that mode.  So we
 		 * have to explicitly take the adapter out of loopback
 		 * mode.  This prevents drivers from twiddling their thumbs
 		 * if another tool failed to take it out of loopback mode.
 		 */
-		ew32(SCTL,
-				E1000_SCTL_DISABLE_SERDES_LOOPBACK);
+		ew32(SCTL, E1000_SCTL_DISABLE_SERDES_LOOPBACK);
 		break;
 	default:
 		break;
@@ -1124,7 +1150,8 @@ void e1000e_set_laa_state_82571(struct e1000_hw *hw, bool state)
 
 	/* If workaround is activated... */
 	if (state)
-		/* Hold a copy of the LAA in RAR[14] This is done so that
+		/*
+		 * Hold a copy of the LAA in RAR[14] This is done so that
 		 * between the time RAR[0] gets clobbered and the time it
 		 * gets fixed, the actual LAA is in one of the RARs and no
 		 * incoming packets directed to this port are dropped.
@@ -1152,7 +1179,8 @@ static s32 e1000_fix_nvm_checksum_82571(struct e1000_hw *hw)
 	if (nvm->type != e1000_nvm_flash_hw)
 		return 0;
 
-	/* Check bit 4 of word 10h.  If it is 0, firmware is done updating
+	/*
+	 * Check bit 4 of word 10h.  If it is 0, firmware is done updating
 	 * 10h-12h.  Checksum may need to be fixed.
 	 */
 	ret_val = e1000_read_nvm(hw, 0x10, 1, &data);
@@ -1160,7 +1188,8 @@ static s32 e1000_fix_nvm_checksum_82571(struct e1000_hw *hw)
 		return ret_val;
 
 	if (!(data & 0x10)) {
-		/* Read 0x23 and check bit 15.  This bit is a 1
+		/*
+		 * Read 0x23 and check bit 15.  This bit is a 1
 		 * when the checksum has already been fixed.  If
 		 * the checksum is still wrong and this bit is a
 		 * 1, we need to return bad checksum.  Otherwise,
@@ -1240,7 +1269,7 @@ static struct e1000_mac_operations e82571_mac_ops = {
 	/* .get_link_up_info: media type dependent */
 	.led_on			= e1000e_led_on_generic,
 	.led_off		= e1000e_led_off_generic,
-	.mc_addr_list_update	= e1000_mc_addr_list_update_82571,
+	.update_mc_addr_list	= e1000_update_mc_addr_list_82571,
 	.reset_hw		= e1000_reset_hw_82571,
 	.init_hw		= e1000_init_hw_82571,
 	.setup_link		= e1000_setup_link_82571,
diff --git a/drivers/net/e1000e/Makefile b/drivers/net/e1000e/Makefile
index 650f866..360c913 100644
--- a/drivers/net/e1000e/Makefile
+++ b/drivers/net/e1000e/Makefile
@@ -1,7 +1,7 @@
 ################################################################################
 #
 # Intel PRO/1000 Linux driver
-# Copyright(c) 1999 - 2007 Intel Corporation.
+# Copyright(c) 1999 - 2008 Intel Corporation.
 #
 # This program is free software; you can redistribute it and/or modify it
 # under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/e1000e/defines.h b/drivers/net/e1000e/defines.h
index a4f511f..572cfd4 100644
--- a/drivers/net/e1000e/defines.h
+++ b/drivers/net/e1000e/defines.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2007 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -120,10 +120,10 @@
 #define E1000_MANC_ARP_EN        0x00002000 /* Enable ARP Request Filtering */
 #define E1000_MANC_RCV_TCO_EN    0x00020000 /* Receive TCO Packets Enabled */
 #define E1000_MANC_BLK_PHY_RST_ON_IDE   0x00040000 /* Block phy resets */
-#define E1000_MANC_EN_MAC_ADDR_FILTER   0x00100000 /* Enable MAC address
-						    * filtering */
-#define E1000_MANC_EN_MNG2HOST   0x00200000 /* Enable MNG packets to host
-					     * memory */
+/* Enable MAC address filtering */
+#define E1000_MANC_EN_MAC_ADDR_FILTER   0x00100000
+/* Enable MNG packets to host memory */
+#define E1000_MANC_EN_MNG2HOST   0x00200000
 
 /* Receive Control */
 #define E1000_RCTL_EN             0x00000002    /* enable */
@@ -135,25 +135,26 @@
 #define E1000_RCTL_LBM_MAC        0x00000040    /* MAC loopback mode */
 #define E1000_RCTL_LBM_TCVR       0x000000C0    /* tcvr loopback mode */
 #define E1000_RCTL_DTYP_PS        0x00000400    /* Packet Split descriptor */
-#define E1000_RCTL_RDMTS_HALF     0x00000000    /* rx desc min threshold size */
+#define E1000_RCTL_RDMTS_HALF     0x00000000    /* Rx desc min threshold size */
 #define E1000_RCTL_MO_SHIFT       12            /* multicast offset shift */
 #define E1000_RCTL_BAM            0x00008000    /* broadcast enable */
 /* these buffer sizes are valid if E1000_RCTL_BSEX is 0 */
-#define E1000_RCTL_SZ_2048        0x00000000    /* rx buffer size 2048 */
-#define E1000_RCTL_SZ_1024        0x00010000    /* rx buffer size 1024 */
-#define E1000_RCTL_SZ_512         0x00020000    /* rx buffer size 512 */
-#define E1000_RCTL_SZ_256         0x00030000    /* rx buffer size 256 */
+#define E1000_RCTL_SZ_2048        0x00000000    /* Rx buffer size 2048 */
+#define E1000_RCTL_SZ_1024        0x00010000    /* Rx buffer size 1024 */
+#define E1000_RCTL_SZ_512         0x00020000    /* Rx buffer size 512 */
+#define E1000_RCTL_SZ_256         0x00030000    /* Rx buffer size 256 */
 /* these buffer sizes are valid if E1000_RCTL_BSEX is 1 */
-#define E1000_RCTL_SZ_16384       0x00010000    /* rx buffer size 16384 */
-#define E1000_RCTL_SZ_8192        0x00020000    /* rx buffer size 8192 */
-#define E1000_RCTL_SZ_4096        0x00030000    /* rx buffer size 4096 */
+#define E1000_RCTL_SZ_16384       0x00010000    /* Rx buffer size 16384 */
+#define E1000_RCTL_SZ_8192        0x00020000    /* Rx buffer size 8192 */
+#define E1000_RCTL_SZ_4096        0x00030000    /* Rx buffer size 4096 */
 #define E1000_RCTL_VFE            0x00040000    /* vlan filter enable */
 #define E1000_RCTL_CFIEN          0x00080000    /* canonical form enable */
 #define E1000_RCTL_CFI            0x00100000    /* canonical form indicator */
 #define E1000_RCTL_BSEX           0x02000000    /* Buffer size extension */
 #define E1000_RCTL_SECRC          0x04000000    /* Strip Ethernet CRC */
 
-/* Use byte values for the following shift parameters
+/*
+ * Use byte values for the following shift parameters
  * Usage:
  *     psrctl |= (((ROUNDUP(value0, 128) >> E1000_PSRCTL_BSIZE0_SHIFT) &
  *                  E1000_PSRCTL_BSIZE0_MASK) |
@@ -206,7 +207,8 @@
 #define E1000_CTRL_VME      0x40000000  /* IEEE VLAN mode enable */
 #define E1000_CTRL_PHY_RST  0x80000000  /* PHY Reset */
 
-/* Bit definitions for the Management Data IO (MDIO) and Management Data
+/*
+ * Bit definitions for the Management Data IO (MDIO) and Management Data
  * Clock (MDC) pins in the Device Control Register.
  */
 
@@ -279,7 +281,7 @@
 #define E1000_TXD_STAT_TC    0x00000004 /* Tx Underrun */
 
 /* Transmit Control */
-#define E1000_TCTL_EN     0x00000002    /* enable tx */
+#define E1000_TCTL_EN     0x00000002    /* enable Tx */
 #define E1000_TCTL_PSP    0x00000008    /* pad short packets */
 #define E1000_TCTL_CT     0x00000ff0    /* collision threshold */
 #define E1000_TCTL_COLD   0x003ff000    /* collision distance */
@@ -337,8 +339,8 @@
 #define E1000_KABGTXD_BGSQLBIAS           0x00050000
 
 /* PBA constants */
-#define E1000_PBA_8K  0x0008    /* 8KB, default Rx allocation */
-#define E1000_PBA_16K 0x0010    /* 16KB, default TX allocation */
+#define E1000_PBA_8K  0x0008    /* 8KB */
+#define E1000_PBA_16K 0x0010    /* 16KB */
 
 #define E1000_PBS_16K E1000_PBA_16K
 
@@ -356,12 +358,13 @@
 /* Interrupt Cause Read */
 #define E1000_ICR_TXDW          0x00000001 /* Transmit desc written back */
 #define E1000_ICR_LSC           0x00000004 /* Link Status Change */
-#define E1000_ICR_RXSEQ         0x00000008 /* rx sequence error */
-#define E1000_ICR_RXDMT0        0x00000010 /* rx desc min. threshold (0) */
-#define E1000_ICR_RXT0          0x00000080 /* rx timer intr (ring 0) */
+#define E1000_ICR_RXSEQ         0x00000008 /* Rx sequence error */
+#define E1000_ICR_RXDMT0        0x00000010 /* Rx desc min. threshold (0) */
+#define E1000_ICR_RXT0          0x00000080 /* Rx timer intr (ring 0) */
 #define E1000_ICR_INT_ASSERTED  0x80000000 /* If this bit asserted, the driver should claim the interrupt */
 
-/* This defines the bits that are set in the Interrupt Mask
+/*
+ * This defines the bits that are set in the Interrupt Mask
  * Set/Read Register.  Each bit is documented below:
  *   o RXT0   = Receiver Timer Interrupt (ring 0)
  *   o TXDW   = Transmit Descriptor Written Back
@@ -379,21 +382,22 @@
 /* Interrupt Mask Set */
 #define E1000_IMS_TXDW      E1000_ICR_TXDW      /* Transmit desc written back */
 #define E1000_IMS_LSC       E1000_ICR_LSC       /* Link Status Change */
-#define E1000_IMS_RXSEQ     E1000_ICR_RXSEQ     /* rx sequence error */
-#define E1000_IMS_RXDMT0    E1000_ICR_RXDMT0    /* rx desc min. threshold */
-#define E1000_IMS_RXT0      E1000_ICR_RXT0      /* rx timer intr */
+#define E1000_IMS_RXSEQ     E1000_ICR_RXSEQ     /* Rx sequence error */
+#define E1000_IMS_RXDMT0    E1000_ICR_RXDMT0    /* Rx desc min. threshold */
+#define E1000_IMS_RXT0      E1000_ICR_RXT0      /* Rx timer intr */
 
 /* Interrupt Cause Set */
 #define E1000_ICS_LSC       E1000_ICR_LSC       /* Link Status Change */
 #define E1000_ICS_RXDMT0    E1000_ICR_RXDMT0    /* rx desc min. threshold */
+#define E1000_ICS_RXDMT0    E1000_ICR_RXDMT0    /* Rx desc min. threshold */
 
 /* Transmit Descriptor Control */
 #define E1000_TXDCTL_PTHRESH 0x0000003F /* TXDCTL Prefetch Threshold */
 #define E1000_TXDCTL_WTHRESH 0x003F0000 /* TXDCTL Writeback Threshold */
 #define E1000_TXDCTL_FULL_TX_DESC_WB 0x01010000 /* GRAN=1, WTHRESH=1 */
 #define E1000_TXDCTL_MAX_TX_DESC_PREFETCH 0x0100001F /* GRAN=1, PTHRESH=31 */
-#define E1000_TXDCTL_COUNT_DESC 0x00400000 /* Enable the counting of desc.
-					      still to be processed. */
+/* Enable the counting of desc. still to be processed. */
+#define E1000_TXDCTL_COUNT_DESC 0x00400000
 
 /* Flow Control Constants */
 #define FLOW_CONTROL_ADDRESS_LOW  0x00C28001
@@ -404,7 +408,8 @@
 #define E1000_VLAN_FILTER_TBL_SIZE 128  /* VLAN Filter Table (4096 bits) */
 
 /* Receive Address */
-/* Number of high/low register pairs in the RAR. The RAR (Receive Address
+/*
+ * Number of high/low register pairs in the RAR. The RAR (Receive Address
  * Registers) holds the directed and multicast addresses that we monitor.
  * Technically, we have 16 spots.  However, we reserve one of these spots
  * (RAR[15]) for our directed address used by controllers with
@@ -533,8 +538,8 @@
 #define E1000_EECD_REQ       0x00000040 /* NVM Access Request */
 #define E1000_EECD_GNT       0x00000080 /* NVM Access Grant */
 #define E1000_EECD_SIZE      0x00000200 /* NVM Size (0=64 word 1=256 word) */
-#define E1000_EECD_ADDR_BITS 0x00000400 /* NVM Addressing bits based on type
-					 * (0-small, 1-large) */
+/* NVM Addressing bits based on type (0-small, 1-large) */
+#define E1000_EECD_ADDR_BITS 0x00000400
 #define E1000_NVM_GRANT_ATTEMPTS   1000 /* NVM # attempts to gain grant */
 #define E1000_EECD_AUTO_RD          0x00000200  /* NVM Auto Read done */
 #define E1000_EECD_SIZE_EX_MASK     0x00007800  /* NVM Size */
@@ -626,7 +631,8 @@
 #define MAX_PHY_MULTI_PAGE_REG 0xF
 
 /* Bit definitions for valid PHY IDs. */
-/* I = Integrated
+/*
+ * I = Integrated
  * E = External
  */
 #define M88E1000_E_PHY_ID    0x01410C50
@@ -653,37 +659,37 @@
 #define M88E1000_PSCR_MDI_MANUAL_MODE  0x0000  /* MDI Crossover Mode bits 6:5 */
 					       /* Manual MDI configuration */
 #define M88E1000_PSCR_MDIX_MANUAL_MODE 0x0020  /* Manual MDIX configuration */
-#define M88E1000_PSCR_AUTO_X_1000T     0x0040  /* 1000BASE-T: Auto crossover,
-						*  100BASE-TX/10BASE-T:
-						*  MDI Mode
-						*/
-#define M88E1000_PSCR_AUTO_X_MODE      0x0060  /* Auto crossover enabled
-						* all speeds.
-						*/
-					/* 1=Enable Extended 10BASE-T distance
-					 * (Lower 10BASE-T RX Threshold)
-					 * 0=Normal 10BASE-T RX Threshold */
-					/* 1=5-Bit interface in 100BASE-TX
-					 * 0=MII interface in 100BASE-TX */
-#define M88E1000_PSCR_ASSERT_CRS_ON_TX     0x0800 /* 1=Assert CRS on Transmit */
+/* 1000BASE-T: Auto crossover, 100BASE-TX/10BASE-T: MDI Mode */
+#define M88E1000_PSCR_AUTO_X_1000T     0x0040
+/* Auto crossover enabled all speeds */
+#define M88E1000_PSCR_AUTO_X_MODE      0x0060
+/*
+ * 1=Enable Extended 10BASE-T distance (Lower 10BASE-T Rx Threshold)
+ * 0=Normal 10BASE-T Rx Threshold
+ */
+#define M88E1000_PSCR_ASSERT_CRS_ON_TX 0x0800 /* 1=Assert CRS on Transmit */
 
 /* M88E1000 PHY Specific Status Register */
 #define M88E1000_PSSR_REV_POLARITY       0x0002 /* 1=Polarity reversed */
 #define M88E1000_PSSR_DOWNSHIFT          0x0020 /* 1=Downshifted */
 #define M88E1000_PSSR_MDIX               0x0040 /* 1=MDIX; 0=MDI */
-#define M88E1000_PSSR_CABLE_LENGTH       0x0380 /* 0=<50M;1=50-80M;2=80-110M;
-					    * 3=110-140M;4=>140M */
+/* 0=<50M; 1=50-80M; 2=80-110M; 3=110-140M; 4=>140M */
+#define M88E1000_PSSR_CABLE_LENGTH       0x0380
 #define M88E1000_PSSR_SPEED              0xC000 /* Speed, bits 14:15 */
 #define M88E1000_PSSR_1000MBS            0x8000 /* 10=1000Mbs */
 
 #define M88E1000_PSSR_CABLE_LENGTH_SHIFT 7
 
-/* Number of times we will attempt to autonegotiate before downshifting if we
- * are the master */
+/*
+ * Number of times we will attempt to autonegotiate before downshifting if we
+ * are the master
+ */
 #define M88E1000_EPSCR_MASTER_DOWNSHIFT_MASK 0x0C00
 #define M88E1000_EPSCR_MASTER_DOWNSHIFT_1X   0x0000
-/* Number of times we will attempt to autonegotiate before downshifting if we
- * are the slave */
+/*
+ * Number of times we will attempt to autonegotiate before downshifting if we
+ * are the slave
+ */
 #define M88E1000_EPSCR_SLAVE_DOWNSHIFT_MASK  0x0300
 #define M88E1000_EPSCR_SLAVE_DOWNSHIFT_1X    0x0100
 #define M88E1000_EPSCR_TX_CLK_25      0x0070 /* 25  MHz TX_CLK */
@@ -692,7 +698,8 @@
 #define M88EC018_EPSCR_DOWNSHIFT_COUNTER_MASK  0x0E00
 #define M88EC018_EPSCR_DOWNSHIFT_COUNTER_5X    0x0800
 
-/* Bits...
+/*
+ * Bits...
  * 15-5: page
  * 4-0: register offset
  */
diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index 4bf0c6c..b941a6b 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2007 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -61,7 +61,7 @@ struct e1000_info;
 	ndev_printk(KERN_NOTICE , netdev, format, ## arg)
 
 
-/* TX/RX descriptor defines */
+/* Tx/Rx descriptor defines */
 #define E1000_DEFAULT_TXD		256
 #define E1000_MAX_TXD			4096
 #define E1000_MIN_TXD			80
@@ -114,13 +114,13 @@ struct e1000_buffer {
 	dma_addr_t dma;
 	struct sk_buff *skb;
 	union {
-		/* TX */
+		/* Tx */
 		struct {
 			unsigned long time_stamp;
 			u16 length;
 			u16 next_to_watch;
 		};
-		/* RX */
+		/* Rx */
 		/* arrays of page information for packet split */
 		struct e1000_ps_page *ps_pages;
 	};
@@ -177,7 +177,7 @@ struct e1000_adapter {
 	u16 rx_itr;
 
 	/*
-	 * TX
+	 * Tx
 	 */
 	struct e1000_ring *tx_ring /* One per active queue */
 						____cacheline_aligned_in_smp;
@@ -199,7 +199,7 @@ struct e1000_adapter {
 	unsigned int total_rx_bytes;
 	unsigned int total_rx_packets;
 
-	/* TX stats */
+	/* Tx stats */
 	u64 tpt_old;
 	u64 colc_old;
 	u64 gotcl_old;
@@ -211,7 +211,7 @@ struct e1000_adapter {
 	u32 tx_dma_failed;
 
 	/*
-	 * RX
+	 * Rx
 	 */
 	bool (*clean_rx) (struct e1000_adapter *adapter,
 			  int *work_done, int work_to_do)
@@ -223,7 +223,7 @@ struct e1000_adapter {
 	u32 rx_int_delay;
 	u32 rx_abs_int_delay;
 
-	/* RX stats */
+	/* Rx stats */
 	u64 hw_csum_err;
 	u64 hw_csum_good;
 	u64 rx_hdr_split;
@@ -234,6 +234,8 @@ struct e1000_adapter {
 
 	unsigned int rx_ps_pages;
 	u16 rx_ps_bsize0;
+	u32 max_frame_size;
+	u32 min_frame_size;
 
 	/* OS defined structs */
 	struct net_device *netdev;
@@ -258,7 +260,7 @@ struct e1000_adapter {
 	u32 wol;
 	u32 pba;
 
-	u8 fc_autoneg;
+	bool fc_autoneg;
 
 	unsigned long led_status;
 
@@ -305,6 +307,7 @@ struct e1000_info {
 #define FLAG_MSI_ENABLED                  (1 << 27)
 #define FLAG_RX_CSUM_ENABLED              (1 << 28)
 #define FLAG_TSO_FORCE                    (1 << 29)
+#define FLAG_RX_RESTART_NOW               (1 << 30)
 
 #define E1000_RX_DESC_PS(R, i)	    \
 	(&(((union e1000_rx_desc_packet_split *)((R).desc))[i]))
@@ -387,9 +390,11 @@ extern s32 e1000e_copper_link_setup_igp(struct e1000_hw *hw);
 extern s32 e1000e_setup_link(struct e1000_hw *hw);
 extern void e1000e_clear_vfta(struct e1000_hw *hw);
 extern void e1000e_init_rx_addrs(struct e1000_hw *hw, u16 rar_count);
-extern void e1000e_mc_addr_list_update_generic(struct e1000_hw *hw,
-				       u8 *mc_addr_list, u32 mc_addr_count,
-				       u32 rar_used_count, u32 rar_count);
+extern void e1000e_update_mc_addr_list_generic(struct e1000_hw *hw,
+					       u8 *mc_addr_list,
+					       u32 mc_addr_count,
+					       u32 rar_used_count,
+					       u32 rar_count);
 extern void e1000e_rar_set(struct e1000_hw *hw, u8 *addr, u32 index);
 extern s32 e1000e_set_fc_watermarks(struct e1000_hw *hw);
 extern void e1000e_set_pcie_no_snoop(struct e1000_hw *hw, u32 no_snoop);
diff --git a/drivers/net/e1000e/es2lan.c b/drivers/net/e1000e/es2lan.c
index 88657ad..e3f4aee 100644
--- a/drivers/net/e1000e/es2lan.c
+++ b/drivers/net/e1000e/es2lan.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2007 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -92,7 +92,8 @@
 /* In-Band Control Register (Page 194, Register 18) */
 #define GG82563_ICR_DIS_PADDING			 0x0010 /* Disable Padding */
 
-/* A table for the GG82563 cable length where the range is defined
+/*
+ * A table for the GG82563 cable length where the range is defined
  * with a lower bound at "index" and the upper bound at
  * "index + 5".
  */
@@ -118,7 +119,7 @@ static s32 e1000_init_phy_params_80003es2lan(struct e1000_hw *hw)
 	struct e1000_phy_info *phy = &hw->phy;
 	s32 ret_val;
 
-	if (hw->media_type != e1000_media_type_copper) {
+	if (hw->phy.media_type != e1000_media_type_copper) {
 		phy->type	= e1000_phy_none;
 		return 0;
 	}
@@ -167,12 +168,13 @@ static s32 e1000_init_nvm_params_80003es2lan(struct e1000_hw *hw)
 		break;
 	}
 
-	nvm->type	       = e1000_nvm_eeprom_spi;
+	nvm->type = e1000_nvm_eeprom_spi;
 
 	size = (u16)((eecd & E1000_EECD_SIZE_EX_MASK) >>
 			  E1000_EECD_SIZE_EX_SHIFT);
 
-	/* Added to a constant, "size" becomes the left-shift value
+	/*
+	 * Added to a constant, "size" becomes the left-shift value
 	 * for setting word_size.
 	 */
 	size += NVM_WORD_SIZE_BASE_SHIFT;
@@ -196,10 +198,10 @@ static s32 e1000_init_mac_params_80003es2lan(struct e1000_adapter *adapter)
 	/* Set media type */
 	switch (adapter->pdev->device) {
 	case E1000_DEV_ID_80003ES2LAN_SERDES_DPT:
-		hw->media_type = e1000_media_type_internal_serdes;
+		hw->phy.media_type = e1000_media_type_internal_serdes;
 		break;
 	default:
-		hw->media_type = e1000_media_type_copper;
+		hw->phy.media_type = e1000_media_type_copper;
 		break;
 	}
 
@@ -208,11 +210,10 @@ static s32 e1000_init_mac_params_80003es2lan(struct e1000_adapter *adapter)
 	/* Set rar entry count */
 	mac->rar_entry_count = E1000_RAR_ENTRIES;
 	/* Set if manageability features are enabled. */
-	mac->arc_subsystem_valid =
-		(er32(FWSM) & E1000_FWSM_MODE_MASK) ? 1 : 0;
+	mac->arc_subsystem_valid = (er32(FWSM) & E1000_FWSM_MODE_MASK) ? 1 : 0;
 
 	/* check for link */
-	switch (hw->media_type) {
+	switch (hw->phy.media_type) {
 	case e1000_media_type_copper:
 		func->setup_physical_interface = e1000_setup_copper_link_80003es2lan;
 		func->check_for_link = e1000e_check_for_copper_link;
@@ -344,8 +345,10 @@ static s32 e1000_acquire_swfw_sync_80003es2lan(struct e1000_hw *hw, u16 mask)
 		if (!(swfw_sync & (fwmask | swmask)))
 			break;
 
-		/* Firmware currently using resource (fwmask)
-		 * or other software thread using resource (swmask) */
+		/*
+		 * Firmware currently using resource (fwmask)
+		 * or other software thread using resource (swmask)
+		 */
 		e1000e_put_hw_semaphore(hw);
 		mdelay(5);
 		i++;
@@ -407,7 +410,8 @@ static s32 e1000_read_phy_reg_gg82563_80003es2lan(struct e1000_hw *hw,
 	if ((offset & MAX_PHY_REG_ADDRESS) < GG82563_MIN_ALT_REG)
 		page_select = GG82563_PHY_PAGE_SELECT;
 	else
-		/* Use Alternative Page Select register to access
+		/*
+		 * Use Alternative Page Select register to access
 		 * registers 30 and 31
 		 */
 		page_select = GG82563_PHY_PAGE_SELECT_ALT;
@@ -417,7 +421,8 @@ static s32 e1000_read_phy_reg_gg82563_80003es2lan(struct e1000_hw *hw,
 	if (ret_val)
 		return ret_val;
 
-	/* The "ready" bit in the MDIC register may be incorrectly set
+	/*
+	 * The "ready" bit in the MDIC register may be incorrectly set
 	 * before the device has completed the "Page Select" MDI
 	 * transaction.  So we wait 200us after each MDI command...
 	 */
@@ -462,7 +467,8 @@ static s32 e1000_write_phy_reg_gg82563_80003es2lan(struct e1000_hw *hw,
 	if ((offset & MAX_PHY_REG_ADDRESS) < GG82563_MIN_ALT_REG)
 		page_select = GG82563_PHY_PAGE_SELECT;
 	else
-		/* Use Alternative Page Select register to access
+		/*
+		 * Use Alternative Page Select register to access
 		 * registers 30 and 31
 		 */
 		page_select = GG82563_PHY_PAGE_SELECT_ALT;
@@ -473,7 +479,8 @@ static s32 e1000_write_phy_reg_gg82563_80003es2lan(struct e1000_hw *hw,
 		return ret_val;
 
 
-	/* The "ready" bit in the MDIC register may be incorrectly set
+	/*
+	 * The "ready" bit in the MDIC register may be incorrectly set
 	 * before the device has completed the "Page Select" MDI
 	 * transaction.  So we wait 200us after each MDI command...
 	 */
@@ -554,7 +561,8 @@ static s32 e1000_phy_force_speed_duplex_80003es2lan(struct e1000_hw *hw)
 	u16 phy_data;
 	bool link;
 
-	/* Clear Auto-Crossover to force MDI manually.  M88E1000 requires MDI
+	/*
+	 * Clear Auto-Crossover to force MDI manually.  M88E1000 requires MDI
 	 * forced whenever speed and duplex are forced.
 	 */
 	ret_val = e1e_rphy(hw, M88E1000_PHY_SPEC_CTRL, &phy_data);
@@ -583,7 +591,7 @@ static s32 e1000_phy_force_speed_duplex_80003es2lan(struct e1000_hw *hw)
 
 	udelay(1);
 
-	if (hw->phy.wait_for_link) {
+	if (hw->phy.autoneg_wait_to_complete) {
 		hw_dbg(hw, "Waiting for forced speed/duplex link "
 			 "on GG82563 phy.\n");
 
@@ -593,7 +601,8 @@ static s32 e1000_phy_force_speed_duplex_80003es2lan(struct e1000_hw *hw)
 			return ret_val;
 
 		if (!link) {
-			/* We didn't get link.
+			/*
+			 * We didn't get link.
 			 * Reset the DSP and cross our fingers.
 			 */
 			ret_val = e1000e_phy_reset_dsp(hw);
@@ -612,7 +621,8 @@ static s32 e1000_phy_force_speed_duplex_80003es2lan(struct e1000_hw *hw)
 	if (ret_val)
 		return ret_val;
 
-	/* Resetting the phy means we need to verify the TX_CLK corresponds
+	/*
+	 * Resetting the phy means we need to verify the TX_CLK corresponds
 	 * to the link speed.  10Mbps -> 2.5MHz, else 25MHz.
 	 */
 	phy_data &= ~GG82563_MSCR_TX_CLK_MASK;
@@ -621,7 +631,8 @@ static s32 e1000_phy_force_speed_duplex_80003es2lan(struct e1000_hw *hw)
 	else
 		phy_data |= GG82563_MSCR_TX_CLK_100MBPS_25;
 
-	/* In addition, we must re-enable CRS on Tx for both half and full
+	/*
+	 * In addition, we must re-enable CRS on Tx for both half and full
 	 * duplex.
 	 */
 	phy_data |= GG82563_MSCR_ASSERT_CRS_ON_TX;
@@ -671,7 +682,7 @@ static s32 e1000_get_link_up_info_80003es2lan(struct e1000_hw *hw, u16 *speed,
 {
 	s32 ret_val;
 
-	if (hw->media_type == e1000_media_type_copper) {
+	if (hw->phy.media_type == e1000_media_type_copper) {
 		ret_val = e1000e_get_speed_and_duplex_copper(hw,
 								    speed,
 								    duplex);
@@ -704,7 +715,8 @@ static s32 e1000_reset_hw_80003es2lan(struct e1000_hw *hw)
 	u32 icr;
 	s32 ret_val;
 
-	/* Prevent the PCI-E bus from sticking if there is no TLP connection
+	/*
+	 * Prevent the PCI-E bus from sticking if there is no TLP connection
 	 * on the last TLP read/write transaction when MAC is reset.
 	 */
 	ret_val = e1000e_disable_pcie_master(hw);
@@ -808,7 +820,8 @@ static s32 e1000_init_hw_80003es2lan(struct e1000_hw *hw)
 	reg_data &= ~0x00100000;
 	E1000_WRITE_REG_ARRAY(hw, E1000_FFLT, 0x0001, reg_data);
 
-	/* Clear all of the statistics registers (clear on read).  It is
+	/*
+	 * Clear all of the statistics registers (clear on read).  It is
 	 * important that we do this after we have tried to establish link
 	 * because the symbol error count will increment wildly if there
 	 * is no link.
@@ -841,7 +854,7 @@ static void e1000_initialize_hw_bits_80003es2lan(struct e1000_hw *hw)
 	/* Transmit Arbitration Control 0 */
 	reg = er32(TARC0);
 	reg &= ~(0xF << 27); /* 30:27 */
-	if (hw->media_type != e1000_media_type_copper)
+	if (hw->phy.media_type != e1000_media_type_copper)
 		reg &= ~(1 << 20);
 	ew32(TARC0, reg);
 
@@ -881,7 +894,8 @@ static s32 e1000_copper_link_setup_gg82563_80003es2lan(struct e1000_hw *hw)
 	if (ret_val)
 		return ret_val;
 
-	/* Options:
+	/*
+	 * Options:
 	 *   MDI/MDI-X = 0 (default)
 	 *   0 - Auto for all speeds
 	 *   1 - MDI mode
@@ -907,7 +921,8 @@ static s32 e1000_copper_link_setup_gg82563_80003es2lan(struct e1000_hw *hw)
 		break;
 	}
 
-	/* Options:
+	/*
+	 * Options:
 	 *   disable_polarity_correction = 0 (default)
 	 *       Automatic Correction for Reversed Cable Polarity
 	 *   0 - Disabled
@@ -928,10 +943,9 @@ static s32 e1000_copper_link_setup_gg82563_80003es2lan(struct e1000_hw *hw)
 		return ret_val;
 	}
 
-	/* Bypass RX and TX FIFO's */
-	ret_val = e1000e_write_kmrn_reg(hw,
-				E1000_KMRNCTRLSTA_OFFSET_FIFO_CTRL,
-				E1000_KMRNCTRLSTA_FIFO_CTRL_RX_BYPASS |
+	/* Bypass Rx and Tx FIFO's */
+	ret_val = e1000e_write_kmrn_reg(hw, E1000_KMRNCTRLSTA_OFFSET_FIFO_CTRL,
+					E1000_KMRNCTRLSTA_FIFO_CTRL_RX_BYPASS |
 					E1000_KMRNCTRLSTA_FIFO_CTRL_TX_BYPASS);
 	if (ret_val)
 		return ret_val;
@@ -953,7 +967,8 @@ static s32 e1000_copper_link_setup_gg82563_80003es2lan(struct e1000_hw *hw)
 	if (ret_val)
 		return ret_val;
 
-	/* Do not init these registers when the HW is in IAMT mode, since the
+	/*
+	 * Do not init these registers when the HW is in IAMT mode, since the
 	 * firmware will have already initialized them.  We only initialize
 	 * them if the HW is not in IAMT mode.
 	 */
@@ -974,7 +989,8 @@ static s32 e1000_copper_link_setup_gg82563_80003es2lan(struct e1000_hw *hw)
 			return ret_val;
 	}
 
-	/* Workaround: Disable padding in Kumeran interface in the MAC
+	/*
+	 * Workaround: Disable padding in Kumeran interface in the MAC
 	 * and in the PHY to avoid CRC errors.
 	 */
 	ret_val = e1e_rphy(hw, GG82563_PHY_INBAND_CTRL, &data);
@@ -1007,9 +1023,11 @@ static s32 e1000_setup_copper_link_80003es2lan(struct e1000_hw *hw)
 	ctrl &= ~(E1000_CTRL_FRCSPD | E1000_CTRL_FRCDPX);
 	ew32(CTRL, ctrl);
 
-	/* Set the mac to wait the maximum time between each
+	/*
+	 * Set the mac to wait the maximum time between each
 	 * iteration and increase the max iterations when
-	 * polling the phy; this fixes erroneous timeouts at 10Mbps. */
+	 * polling the phy; this fixes erroneous timeouts at 10Mbps.
+	 */
 	ret_val = e1000e_write_kmrn_reg(hw, GG82563_REG(0x34, 4), 0xFFFF);
 	if (ret_val)
 		return ret_val;
@@ -1026,9 +1044,8 @@ static s32 e1000_setup_copper_link_80003es2lan(struct e1000_hw *hw)
 	if (ret_val)
 		return ret_val;
 	reg_data |= E1000_KMRNCTRLSTA_INB_CTRL_DIS_PADDING;
-	ret_val = e1000e_write_kmrn_reg(hw,
-				       E1000_KMRNCTRLSTA_OFFSET_INB_CTRL,
-				       reg_data);
+	ret_val = e1000e_write_kmrn_reg(hw, E1000_KMRNCTRLSTA_OFFSET_INB_CTRL,
+					reg_data);
 	if (ret_val)
 		return ret_val;
 
@@ -1056,9 +1073,8 @@ static s32 e1000_cfg_kmrn_10_100_80003es2lan(struct e1000_hw *hw, u16 duplex)
 	u16 reg_data;
 
 	reg_data = E1000_KMRNCTRLSTA_HD_CTRL_10_100_DEFAULT;
-	ret_val = e1000e_write_kmrn_reg(hw,
-				       E1000_KMRNCTRLSTA_OFFSET_HD_CTRL,
-				       reg_data);
+	ret_val = e1000e_write_kmrn_reg(hw, E1000_KMRNCTRLSTA_OFFSET_HD_CTRL,
+					reg_data);
 	if (ret_val)
 		return ret_val;
 
@@ -1096,9 +1112,8 @@ static s32 e1000_cfg_kmrn_1000_80003es2lan(struct e1000_hw *hw)
 	u32 tipg;
 
 	reg_data = E1000_KMRNCTRLSTA_HD_CTRL_1000_DEFAULT;
-	ret_val = e1000e_write_kmrn_reg(hw,
-				       E1000_KMRNCTRLSTA_OFFSET_HD_CTRL,
-				       reg_data);
+	ret_val = e1000e_write_kmrn_reg(hw, E1000_KMRNCTRLSTA_OFFSET_HD_CTRL,
+					reg_data);
 	if (ret_val)
 		return ret_val;
 
@@ -1175,7 +1190,7 @@ static struct e1000_mac_operations es2_mac_ops = {
 	.get_link_up_info	= e1000_get_link_up_info_80003es2lan,
 	.led_on			= e1000e_led_on_generic,
 	.led_off		= e1000e_led_off_generic,
-	.mc_addr_list_update	= e1000e_mc_addr_list_update_generic,
+	.update_mc_addr_list	= e1000e_update_mc_addr_list_generic,
 	.reset_hw		= e1000_reset_hw_80003es2lan,
 	.init_hw		= e1000_init_hw_80003es2lan,
 	.setup_link		= e1000e_setup_link,
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index f77a742..4ae0056 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2007 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -102,7 +102,7 @@ static const char e1000_gstrings_test[][ETH_GSTRING_LEN] = {
 	"Interrupt test (offline)", "Loopback test  (offline)",
 	"Link test   (on/offline)"
 };
-#define E1000_TEST_LEN	ARRAY_SIZE(e1000_gstrings_test)
+#define E1000_TEST_LEN ARRAY_SIZE(e1000_gstrings_test)
 
 static int e1000_get_settings(struct net_device *netdev,
 			      struct ethtool_cmd *ecmd)
@@ -111,7 +111,7 @@ static int e1000_get_settings(struct net_device *netdev,
 	struct e1000_hw *hw = &adapter->hw;
 	u32 status;
 
-	if (hw->media_type == e1000_media_type_copper) {
+	if (hw->phy.media_type == e1000_media_type_copper) {
 
 		ecmd->supported = (SUPPORTED_10baseT_Half |
 				   SUPPORTED_10baseT_Full |
@@ -165,7 +165,7 @@ static int e1000_get_settings(struct net_device *netdev,
 		ecmd->duplex = -1;
 	}
 
-	ecmd->autoneg = ((hw->media_type == e1000_media_type_fiber) ||
+	ecmd->autoneg = ((hw->phy.media_type == e1000_media_type_fiber) ||
 			 hw->mac.autoneg) ? AUTONEG_ENABLE : AUTONEG_DISABLE;
 	return 0;
 }
@@ -187,7 +187,7 @@ static int e1000_set_spd_dplx(struct e1000_adapter *adapter, u16 spddplx)
 	mac->autoneg = 0;
 
 	/* Fiber NICs only allow 1000 gbps Full duplex */
-	if ((adapter->hw.media_type == e1000_media_type_fiber) &&
+	if ((adapter->hw.phy.media_type == e1000_media_type_fiber) &&
 		spddplx != (SPEED_1000 + DUPLEX_FULL)) {
 		ndev_err(adapter->netdev, "Unsupported Speed/Duplex "
 			 "configuration\n");
@@ -226,8 +226,10 @@ static int e1000_set_settings(struct net_device *netdev,
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 
-	/* When SoL/IDER sessions are active, autoneg/speed/duplex
-	 * cannot be changed */
+	/*
+	 * When SoL/IDER sessions are active, autoneg/speed/duplex
+	 * cannot be changed
+	 */
 	if (e1000_check_reset_block(hw)) {
 		ndev_err(netdev, "Cannot change link "
 			 "characteristics when SoL/IDER is active.\n");
@@ -239,7 +241,7 @@ static int e1000_set_settings(struct net_device *netdev,
 
 	if (ecmd->autoneg == AUTONEG_ENABLE) {
 		hw->mac.autoneg = 1;
-		if (hw->media_type == e1000_media_type_fiber)
+		if (hw->phy.media_type == e1000_media_type_fiber)
 			hw->phy.autoneg_advertised = ADVERTISED_1000baseT_Full |
 						     ADVERTISED_FIBRE |
 						     ADVERTISED_Autoneg;
@@ -248,6 +250,8 @@ static int e1000_set_settings(struct net_device *netdev,
 						     ADVERTISED_TP |
 						     ADVERTISED_Autoneg;
 		ecmd->advertising = hw->phy.autoneg_advertised;
+		if (adapter->fc_autoneg)
+			hw->fc.original_type = e1000_fc_default;
 	} else {
 		if (e1000_set_spd_dplx(adapter, ecmd->speed + ecmd->duplex)) {
 			clear_bit(__E1000_RESETTING, &adapter->state);
@@ -277,11 +281,11 @@ static void e1000_get_pauseparam(struct net_device *netdev,
 	pause->autoneg =
 		(adapter->fc_autoneg ? AUTONEG_ENABLE : AUTONEG_DISABLE);
 
-	if (hw->mac.fc == e1000_fc_rx_pause) {
+	if (hw->fc.type == e1000_fc_rx_pause) {
 		pause->rx_pause = 1;
-	} else if (hw->mac.fc == e1000_fc_tx_pause) {
+	} else if (hw->fc.type == e1000_fc_tx_pause) {
 		pause->tx_pause = 1;
-	} else if (hw->mac.fc == e1000_fc_full) {
+	} else if (hw->fc.type == e1000_fc_full) {
 		pause->rx_pause = 1;
 		pause->tx_pause = 1;
 	}
@@ -300,18 +304,18 @@ static int e1000_set_pauseparam(struct net_device *netdev,
 		msleep(1);
 
 	if (pause->rx_pause && pause->tx_pause)
-		hw->mac.fc = e1000_fc_full;
+		hw->fc.type = e1000_fc_full;
 	else if (pause->rx_pause && !pause->tx_pause)
-		hw->mac.fc = e1000_fc_rx_pause;
+		hw->fc.type = e1000_fc_rx_pause;
 	else if (!pause->rx_pause && pause->tx_pause)
-		hw->mac.fc = e1000_fc_tx_pause;
+		hw->fc.type = e1000_fc_tx_pause;
 	else if (!pause->rx_pause && !pause->tx_pause)
-		hw->mac.fc = e1000_fc_none;
+		hw->fc.type = e1000_fc_none;
 
-	hw->mac.original_fc = hw->mac.fc;
+	hw->fc.original_type = hw->fc.type;
 
 	if (adapter->fc_autoneg == AUTONEG_ENABLE) {
-		hw->mac.fc = e1000_fc_default;
+		hw->fc.type = e1000_fc_default;
 		if (netif_running(adapter->netdev)) {
 			e1000e_down(adapter);
 			e1000e_up(adapter);
@@ -319,7 +323,7 @@ static int e1000_set_pauseparam(struct net_device *netdev,
 			e1000e_reset(adapter);
 		}
 	} else {
-		retval = ((hw->media_type == e1000_media_type_fiber) ?
+		retval = ((hw->phy.media_type == e1000_media_type_fiber) ?
 			  hw->mac.ops.setup_link(hw) : e1000e_force_mac_fc(hw));
 	}
 
@@ -558,8 +562,10 @@ static int e1000_set_eeprom(struct net_device *netdev,
 	ret_val = e1000_write_nvm(hw, first_word,
 				  last_word - first_word + 1, eeprom_buff);
 
-	/* Update the checksum over the first part of the EEPROM if needed
-	 * and flush shadow RAM for 82573 controllers */
+	/*
+	 * Update the checksum over the first part of the EEPROM if needed
+	 * and flush shadow RAM for 82573 controllers
+	 */
 	if ((ret_val == 0) && ((first_word <= NVM_CHECKSUM_REG) ||
 			       (hw->mac.type == e1000_82573)))
 		e1000e_update_nvm_checksum(hw);
@@ -578,8 +584,10 @@ static void e1000_get_drvinfo(struct net_device *netdev,
 	strncpy(drvinfo->driver,  e1000e_driver_name, 32);
 	strncpy(drvinfo->version, e1000e_driver_version, 32);
 
-	/* EEPROM image version # is reported as firmware version # for
-	 * PCI-E controllers */
+	/*
+	 * EEPROM image version # is reported as firmware version # for
+	 * PCI-E controllers
+	 */
 	e1000_read_nvm(&adapter->hw, 5, 1, &eeprom_data);
 	sprintf(firmware_version, "%d.%d-%d",
 		(eeprom_data & 0xF000) >> 12,
@@ -658,8 +666,10 @@ static int e1000_set_ringparam(struct net_device *netdev,
 		if (err)
 			goto err_setup_tx;
 
-		/* save the new, restore the old in order to free it,
-		 * then restore the new back again */
+		/*
+		 * restore the old in order to free it,
+		 * then add in the new
+		 */
 		adapter->rx_ring = rx_old;
 		adapter->tx_ring = tx_old;
 		e1000e_free_rx_resources(adapter);
@@ -758,7 +768,8 @@ static int e1000_reg_test(struct e1000_adapter *adapter, u64 *data)
 	u32 i;
 	u32 toggle;
 
-	/* The status register is Read Only, so a write should fail.
+	/*
+	 * The status register is Read Only, so a write should fail.
 	 * Some bits that get toggled are ignored.
 	 */
 	switch (mac->type) {
@@ -908,7 +919,8 @@ static int e1000_intr_test(struct e1000_adapter *adapter, u64 *data)
 		mask = 1 << i;
 
 		if (!shared_int) {
-			/* Disable the interrupt to be reported in
+			/*
+			 * Disable the interrupt to be reported in
 			 * the cause register and then force the same
 			 * interrupt and see if one gets posted.  If
 			 * an interrupt was posted to the bus, the
@@ -925,7 +937,8 @@ static int e1000_intr_test(struct e1000_adapter *adapter, u64 *data)
 			}
 		}
 
-		/* Enable the interrupt to be reported in
+		/*
+		 * Enable the interrupt to be reported in
 		 * the cause register and then force the same
 		 * interrupt and see if one gets posted.  If
 		 * an interrupt was not posted to the bus, the
@@ -942,7 +955,8 @@ static int e1000_intr_test(struct e1000_adapter *adapter, u64 *data)
 		}
 
 		if (!shared_int) {
-			/* Disable the other interrupts to be reported in
+			/*
+			 * Disable the other interrupts to be reported in
 			 * the cause register and then force the other
 			 * interrupts and see if any get posted.  If
 			 * an interrupt was posted to the bus, the
@@ -1175,21 +1189,21 @@ static int e1000_integrated_phy_loopback(struct e1000_adapter *adapter)
 	u32 ctrl_reg = 0;
 	u32 stat_reg = 0;
 
-	adapter->hw.mac.autoneg = 0;
+	hw->mac.autoneg = 0;
 
-	if (adapter->hw.phy.type == e1000_phy_m88) {
+	if (hw->phy.type == e1000_phy_m88) {
 		/* Auto-MDI/MDIX Off */
 		e1e_wphy(hw, M88E1000_PHY_SPEC_CTRL, 0x0808);
 		/* reset to update Auto-MDI/MDIX */
 		e1e_wphy(hw, PHY_CONTROL, 0x9140);
 		/* autoneg off */
 		e1e_wphy(hw, PHY_CONTROL, 0x8140);
-	} else if (adapter->hw.phy.type == e1000_phy_gg82563)
+	} else if (hw->phy.type == e1000_phy_gg82563)
 		e1e_wphy(hw, GG82563_PHY_KMRN_MODE_CTRL, 0x1CC);
 
 	ctrl_reg = er32(CTRL);
 
-	if (adapter->hw.phy.type == e1000_phy_ife) {
+	if (hw->phy.type == e1000_phy_ife) {
 		/* force 100, set loopback */
 		e1e_wphy(hw, PHY_CONTROL, 0x6100);
 
@@ -1212,12 +1226,14 @@ static int e1000_integrated_phy_loopback(struct e1000_adapter *adapter)
 			     E1000_CTRL_FD);	 /* Force Duplex to FULL */
 	}
 
-	if (adapter->hw.media_type == e1000_media_type_copper &&
-	   adapter->hw.phy.type == e1000_phy_m88) {
+	if (hw->phy.media_type == e1000_media_type_copper &&
+	    hw->phy.type == e1000_phy_m88) {
 		ctrl_reg |= E1000_CTRL_ILOS; /* Invert Loss of Signal */
 	} else {
-		/* Set the ILOS bit on the fiber Nic if half duplex link is
-		 * detected. */
+		/*
+		 * Set the ILOS bit on the fiber Nic if half duplex link is
+		 * detected.
+		 */
 		stat_reg = er32(STATUS);
 		if ((stat_reg & E1000_STATUS_FD) == 0)
 			ctrl_reg |= (E1000_CTRL_ILOS | E1000_CTRL_SLU);
@@ -1225,10 +1241,11 @@ static int e1000_integrated_phy_loopback(struct e1000_adapter *adapter)
 
 	ew32(CTRL, ctrl_reg);
 
-	/* Disable the receiver on the PHY so when a cable is plugged in, the
+	/*
+	 * Disable the receiver on the PHY so when a cable is plugged in, the
 	 * PHY does not begin to autoneg when a cable is reconnected to the NIC.
 	 */
-	if (adapter->hw.phy.type == e1000_phy_m88)
+	if (hw->phy.type == e1000_phy_m88)
 		e1000_phy_disable_receiver(adapter);
 
 	udelay(500);
@@ -1244,8 +1261,10 @@ static int e1000_set_82571_fiber_loopback(struct e1000_adapter *adapter)
 
 	/* special requirements for 82571/82572 fiber adapters */
 
-	/* jump through hoops to make sure link is up because serdes
-	 * link is hardwired up */
+	/*
+	 * jump through hoops to make sure link is up because serdes
+	 * link is hardwired up
+	 */
 	ctrl |= E1000_CTRL_SLU;
 	ew32(CTRL, ctrl);
 
@@ -1263,8 +1282,10 @@ static int e1000_set_82571_fiber_loopback(struct e1000_adapter *adapter)
 		ew32(CTRL, ctrl);
 	}
 
-	/* special write to serdes control register to enable SerDes analog
-	 * loopback */
+	/*
+	 * special write to serdes control register to enable SerDes analog
+	 * loopback
+	 */
 #define E1000_SERDES_LB_ON 0x410
 	ew32(SCTL, E1000_SERDES_LB_ON);
 	msleep(10);
@@ -1279,8 +1300,10 @@ static int e1000_set_es2lan_mac_loopback(struct e1000_adapter *adapter)
 	u32 ctrlext = er32(CTRL_EXT);
 	u32 ctrl = er32(CTRL);
 
-	/* save CTRL_EXT to restore later, reuse an empty variable (unused
-	   on mac_type 80003es2lan) */
+	/*
+	 * save CTRL_EXT to restore later, reuse an empty variable (unused
+	 * on mac_type 80003es2lan)
+	 */
 	adapter->tx_fifo_head = ctrlext;
 
 	/* clear the serdes mode bits, putting the device into mac loopback */
@@ -1312,8 +1335,8 @@ static int e1000_setup_loopback_test(struct e1000_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 	u32 rctl;
 
-	if (hw->media_type == e1000_media_type_fiber ||
-	    hw->media_type == e1000_media_type_internal_serdes) {
+	if (hw->phy.media_type == e1000_media_type_fiber ||
+	    hw->phy.media_type == e1000_media_type_internal_serdes) {
 		switch (hw->mac.type) {
 		case e1000_80003es2lan:
 			return e1000_set_es2lan_mac_loopback(adapter);
@@ -1328,7 +1351,7 @@ static int e1000_setup_loopback_test(struct e1000_adapter *adapter)
 			ew32(RCTL, rctl);
 			return 0;
 		}
-	} else if (hw->media_type == e1000_media_type_copper) {
+	} else if (hw->phy.media_type == e1000_media_type_copper) {
 		return e1000_integrated_phy_loopback(adapter);
 	}
 
@@ -1347,18 +1370,17 @@ static void e1000_loopback_cleanup(struct e1000_adapter *adapter)
 
 	switch (hw->mac.type) {
 	case e1000_80003es2lan:
-		if (hw->media_type == e1000_media_type_fiber ||
-		    hw->media_type == e1000_media_type_internal_serdes) {
+		if (hw->phy.media_type == e1000_media_type_fiber ||
+		    hw->phy.media_type == e1000_media_type_internal_serdes) {
 			/* restore CTRL_EXT, stealing space from tx_fifo_head */
-			ew32(CTRL_EXT,
-					adapter->tx_fifo_head);
+			ew32(CTRL_EXT, adapter->tx_fifo_head);
 			adapter->tx_fifo_head = 0;
 		}
 		/* fall through */
 	case e1000_82571:
 	case e1000_82572:
-		if (hw->media_type == e1000_media_type_fiber ||
-		    hw->media_type == e1000_media_type_internal_serdes) {
+		if (hw->phy.media_type == e1000_media_type_fiber ||
+		    hw->phy.media_type == e1000_media_type_internal_serdes) {
 #define E1000_SERDES_LB_OFF 0x400
 			ew32(SCTL, E1000_SERDES_LB_OFF);
 			msleep(10);
@@ -1414,7 +1436,8 @@ static int e1000_run_loopback_test(struct e1000_adapter *adapter)
 
 	ew32(RDT, rx_ring->count - 1);
 
-	/* Calculate the loop count based on the largest descriptor ring
+	/*
+	 * Calculate the loop count based on the largest descriptor ring
 	 * The idea is to wrap the largest ring a number of times using 64
 	 * send/receive pairs during each loop
 	 */
@@ -1454,7 +1477,8 @@ static int e1000_run_loopback_test(struct e1000_adapter *adapter)
 			l++;
 			if (l == rx_ring->count)
 				l = 0;
-			/* time + 20 msecs (200 msecs on 2.4) is more than
+			/*
+			 * time + 20 msecs (200 msecs on 2.4) is more than
 			 * enough time to complete the receives, if it's
 			 * exceeded, break and error off
 			 */
@@ -1473,8 +1497,10 @@ static int e1000_run_loopback_test(struct e1000_adapter *adapter)
 
 static int e1000_loopback_test(struct e1000_adapter *adapter, u64 *data)
 {
-	/* PHY loopback cannot be performed if SoL/IDER
-	 * sessions are active */
+	/*
+	 * PHY loopback cannot be performed if SoL/IDER
+	 * sessions are active
+	 */
 	if (e1000_check_reset_block(&adapter->hw)) {
 		ndev_err(adapter->netdev, "Cannot do PHY loopback test "
 			 "when SoL/IDER is active.\n");
@@ -1504,12 +1530,14 @@ static int e1000_link_test(struct e1000_adapter *adapter, u64 *data)
 	struct e1000_hw *hw = &adapter->hw;
 
 	*data = 0;
-	if (hw->media_type == e1000_media_type_internal_serdes) {
+	if (hw->phy.media_type == e1000_media_type_internal_serdes) {
 		int i = 0;
 		hw->mac.serdes_has_link = 0;
 
-		/* On some blade server designs, link establishment
-		 * could take as long as 2-3 minutes */
+		/*
+		 * On some blade server designs, link establishment
+		 * could take as long as 2-3 minutes
+		 */
 		do {
 			hw->mac.ops.check_for_link(hw);
 			if (hw->mac.serdes_has_link)
@@ -1562,8 +1590,10 @@ static void e1000_diag_test(struct net_device *netdev,
 
 		ndev_info(netdev, "offline testing starting\n");
 
-		/* Link test performed before hardware reset so autoneg doesn't
-		 * interfere with test result */
+		/*
+		 * Link test performed before hardware reset so autoneg doesn't
+		 * interfere with test result
+		 */
 		if (e1000_link_test(adapter, &data[4]))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
 
@@ -1596,9 +1626,9 @@ static void e1000_diag_test(struct net_device *netdev,
 		adapter->hw.mac.autoneg = autoneg;
 
 		/* force this routine to wait until autoneg complete/timeout */
-		adapter->hw.phy.wait_for_link = 1;
+		adapter->hw.phy.autoneg_wait_to_complete = 1;
 		e1000e_reset(adapter);
-		adapter->hw.phy.wait_for_link = 0;
+		adapter->hw.phy.autoneg_wait_to_complete = 0;
 
 		clear_bit(__E1000_TESTING, &adapter->state);
 		if (if_running)
@@ -1768,8 +1798,7 @@ static void e1000_get_strings(struct net_device *netdev, u32 stringset,
 
 	switch (stringset) {
 	case ETH_SS_TEST:
-		memcpy(data, *e1000_gstrings_test,
-			sizeof(e1000_gstrings_test));
+		memcpy(data, *e1000_gstrings_test, sizeof(e1000_gstrings_test));
 		break;
 	case ETH_SS_STATS:
 		for (i = 0; i < E1000_GLOBAL_STATS_LEN; i++) {
diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index 916025b..0b4145a 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2007 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -66,14 +66,14 @@ enum e1e_registers {
 	E1000_IMS      = 0x000D0, /* Interrupt Mask Set - RW */
 	E1000_IMC      = 0x000D8, /* Interrupt Mask Clear - WO */
 	E1000_IAM      = 0x000E0, /* Interrupt Acknowledge Auto Mask */
-	E1000_RCTL     = 0x00100, /* RX Control - RW */
+	E1000_RCTL     = 0x00100, /* Rx Control - RW */
 	E1000_FCTTV    = 0x00170, /* Flow Control Transmit Timer Value - RW */
-	E1000_TXCW     = 0x00178, /* TX Configuration Word - RW */
-	E1000_RXCW     = 0x00180, /* RX Configuration Word - RO */
-	E1000_TCTL     = 0x00400, /* TX Control - RW */
-	E1000_TCTL_EXT = 0x00404, /* Extended TX Control - RW */
-	E1000_TIPG     = 0x00410, /* TX Inter-packet gap -RW */
-	E1000_AIT      = 0x00458, /* Adaptive Interframe Spacing Throttle - RW */
+	E1000_TXCW     = 0x00178, /* Tx Configuration Word - RW */
+	E1000_RXCW     = 0x00180, /* Rx Configuration Word - RO */
+	E1000_TCTL     = 0x00400, /* Tx Control - RW */
+	E1000_TCTL_EXT = 0x00404, /* Extended Tx Control - RW */
+	E1000_TIPG     = 0x00410, /* Tx Inter-packet gap -RW */
+	E1000_AIT      = 0x00458, /* Adaptive Interframe Spacing Throttle -RW */
 	E1000_LEDCTL   = 0x00E00, /* LED Control - RW */
 	E1000_EXTCNF_CTRL  = 0x00F00, /* Extended Configuration Control */
 	E1000_EXTCNF_SIZE  = 0x00F08, /* Extended Configuration Size */
@@ -87,12 +87,12 @@ enum e1e_registers {
 	E1000_FCRTL    = 0x02160, /* Flow Control Receive Threshold Low - RW */
 	E1000_FCRTH    = 0x02168, /* Flow Control Receive Threshold High - RW */
 	E1000_PSRCTL   = 0x02170, /* Packet Split Receive Control - RW */
-	E1000_RDBAL    = 0x02800, /* RX Descriptor Base Address Low - RW */
-	E1000_RDBAH    = 0x02804, /* RX Descriptor Base Address High - RW */
-	E1000_RDLEN    = 0x02808, /* RX Descriptor Length - RW */
-	E1000_RDH      = 0x02810, /* RX Descriptor Head - RW */
-	E1000_RDT      = 0x02818, /* RX Descriptor Tail - RW */
-	E1000_RDTR     = 0x02820, /* RX Delay Timer - RW */
+	E1000_RDBAL    = 0x02800, /* Rx Descriptor Base Address Low - RW */
+	E1000_RDBAH    = 0x02804, /* Rx Descriptor Base Address High - RW */
+	E1000_RDLEN    = 0x02808, /* Rx Descriptor Length - RW */
+	E1000_RDH      = 0x02810, /* Rx Descriptor Head - RW */
+	E1000_RDT      = 0x02818, /* Rx Descriptor Tail - RW */
+	E1000_RDTR     = 0x02820, /* Rx Delay Timer - RW */
 	E1000_RADV     = 0x0282C, /* RX Interrupt Absolute Delay Timer - RW */
 
 /* Convenience macros
@@ -105,17 +105,17 @@ enum e1e_registers {
  */
 #define E1000_RDBAL_REG(_n)   (E1000_RDBAL + (_n << 8))
 	E1000_KABGTXD  = 0x03004, /* AFE Band Gap Transmit Ref Data */
-	E1000_TDBAL    = 0x03800, /* TX Descriptor Base Address Low - RW */
-	E1000_TDBAH    = 0x03804, /* TX Descriptor Base Address High - RW */
-	E1000_TDLEN    = 0x03808, /* TX Descriptor Length - RW */
-	E1000_TDH      = 0x03810, /* TX Descriptor Head - RW */
-	E1000_TDT      = 0x03818, /* TX Descriptor Tail - RW */
-	E1000_TIDV     = 0x03820, /* TX Interrupt Delay Value - RW */
-	E1000_TXDCTL   = 0x03828, /* TX Descriptor Control - RW */
-	E1000_TADV     = 0x0382C, /* TX Interrupt Absolute Delay Val - RW */
-	E1000_TARC0    = 0x03840, /* TX Arbitration Count (0) */
-	E1000_TXDCTL1  = 0x03928, /* TX Descriptor Control (1) - RW */
-	E1000_TARC1    = 0x03940, /* TX Arbitration Count (1) */
+	E1000_TDBAL    = 0x03800, /* Tx Descriptor Base Address Low - RW */
+	E1000_TDBAH    = 0x03804, /* Tx Descriptor Base Address High - RW */
+	E1000_TDLEN    = 0x03808, /* Tx Descriptor Length - RW */
+	E1000_TDH      = 0x03810, /* Tx Descriptor Head - RW */
+	E1000_TDT      = 0x03818, /* Tx Descriptor Tail - RW */
+	E1000_TIDV     = 0x03820, /* Tx Interrupt Delay Value - RW */
+	E1000_TXDCTL   = 0x03828, /* Tx Descriptor Control - RW */
+	E1000_TADV     = 0x0382C, /* Tx Interrupt Absolute Delay Val - RW */
+	E1000_TARC0    = 0x03840, /* Tx Arbitration Count (0) */
+	E1000_TXDCTL1  = 0x03928, /* Tx Descriptor Control (1) - RW */
+	E1000_TARC1    = 0x03940, /* Tx Arbitration Count (1) */
 	E1000_CRCERRS  = 0x04000, /* CRC Error Count - R/clr */
 	E1000_ALGNERRC = 0x04004, /* Alignment Error Count - R/clr */
 	E1000_SYMERRS  = 0x04008, /* Symbol Error Count - R/clr */
@@ -127,53 +127,53 @@ enum e1e_registers {
 	E1000_LATECOL  = 0x04020, /* Late Collision Count - R/clr */
 	E1000_COLC     = 0x04028, /* Collision Count - R/clr */
 	E1000_DC       = 0x04030, /* Defer Count - R/clr */
-	E1000_TNCRS    = 0x04034, /* TX-No CRS - R/clr */
+	E1000_TNCRS    = 0x04034, /* Tx-No CRS - R/clr */
 	E1000_SEC      = 0x04038, /* Sequence Error Count - R/clr */
 	E1000_CEXTERR  = 0x0403C, /* Carrier Extension Error Count - R/clr */
 	E1000_RLEC     = 0x04040, /* Receive Length Error Count - R/clr */
-	E1000_XONRXC   = 0x04048, /* XON RX Count - R/clr */
-	E1000_XONTXC   = 0x0404C, /* XON TX Count - R/clr */
-	E1000_XOFFRXC  = 0x04050, /* XOFF RX Count - R/clr */
-	E1000_XOFFTXC  = 0x04054, /* XOFF TX Count - R/clr */
-	E1000_FCRUC    = 0x04058, /* Flow Control RX Unsupported Count- R/clr */
-	E1000_PRC64    = 0x0405C, /* Packets RX (64 bytes) - R/clr */
-	E1000_PRC127   = 0x04060, /* Packets RX (65-127 bytes) - R/clr */
-	E1000_PRC255   = 0x04064, /* Packets RX (128-255 bytes) - R/clr */
-	E1000_PRC511   = 0x04068, /* Packets RX (255-511 bytes) - R/clr */
-	E1000_PRC1023  = 0x0406C, /* Packets RX (512-1023 bytes) - R/clr */
-	E1000_PRC1522  = 0x04070, /* Packets RX (1024-1522 bytes) - R/clr */
-	E1000_GPRC     = 0x04074, /* Good Packets RX Count - R/clr */
-	E1000_BPRC     = 0x04078, /* Broadcast Packets RX Count - R/clr */
-	E1000_MPRC     = 0x0407C, /* Multicast Packets RX Count - R/clr */
-	E1000_GPTC     = 0x04080, /* Good Packets TX Count - R/clr */
-	E1000_GORCL    = 0x04088, /* Good Octets RX Count Low - R/clr */
-	E1000_GORCH    = 0x0408C, /* Good Octets RX Count High - R/clr */
-	E1000_GOTCL    = 0x04090, /* Good Octets TX Count Low - R/clr */
-	E1000_GOTCH    = 0x04094, /* Good Octets TX Count High - R/clr */
-	E1000_RNBC     = 0x040A0, /* RX No Buffers Count - R/clr */
-	E1000_RUC      = 0x040A4, /* RX Undersize Count - R/clr */
-	E1000_RFC      = 0x040A8, /* RX Fragment Count - R/clr */
-	E1000_ROC      = 0x040AC, /* RX Oversize Count - R/clr */
-	E1000_RJC      = 0x040B0, /* RX Jabber Count - R/clr */
-	E1000_MGTPRC   = 0x040B4, /* Management Packets RX Count - R/clr */
+	E1000_XONRXC   = 0x04048, /* XON Rx Count - R/clr */
+	E1000_XONTXC   = 0x0404C, /* XON Tx Count - R/clr */
+	E1000_XOFFRXC  = 0x04050, /* XOFF Rx Count - R/clr */
+	E1000_XOFFTXC  = 0x04054, /* XOFF Tx Count - R/clr */
+	E1000_FCRUC    = 0x04058, /* Flow Control Rx Unsupported Count- R/clr */
+	E1000_PRC64    = 0x0405C, /* Packets Rx (64 bytes) - R/clr */
+	E1000_PRC127   = 0x04060, /* Packets Rx (65-127 bytes) - R/clr */
+	E1000_PRC255   = 0x04064, /* Packets Rx (128-255 bytes) - R/clr */
+	E1000_PRC511   = 0x04068, /* Packets Rx (255-511 bytes) - R/clr */
+	E1000_PRC1023  = 0x0406C, /* Packets Rx (512-1023 bytes) - R/clr */
+	E1000_PRC1522  = 0x04070, /* Packets Rx (1024-1522 bytes) - R/clr */
+	E1000_GPRC     = 0x04074, /* Good Packets Rx Count - R/clr */
+	E1000_BPRC     = 0x04078, /* Broadcast Packets Rx Count - R/clr */
+	E1000_MPRC     = 0x0407C, /* Multicast Packets Rx Count - R/clr */
+	E1000_GPTC     = 0x04080, /* Good Packets Tx Count - R/clr */
+	E1000_GORCL    = 0x04088, /* Good Octets Rx Count Low - R/clr */
+	E1000_GORCH    = 0x0408C, /* Good Octets Rx Count High - R/clr */
+	E1000_GOTCL    = 0x04090, /* Good Octets Tx Count Low - R/clr */
+	E1000_GOTCH    = 0x04094, /* Good Octets Tx Count High - R/clr */
+	E1000_RNBC     = 0x040A0, /* Rx No Buffers Count - R/clr */
+	E1000_RUC      = 0x040A4, /* Rx Undersize Count - R/clr */
+	E1000_RFC      = 0x040A8, /* Rx Fragment Count - R/clr */
+	E1000_ROC      = 0x040AC, /* Rx Oversize Count - R/clr */
+	E1000_RJC      = 0x040B0, /* Rx Jabber Count - R/clr */
+	E1000_MGTPRC   = 0x040B4, /* Management Packets Rx Count - R/clr */
 	E1000_MGTPDC   = 0x040B8, /* Management Packets Dropped Count - R/clr */
-	E1000_MGTPTC   = 0x040BC, /* Management Packets TX Count - R/clr */
-	E1000_TORL     = 0x040C0, /* Total Octets RX Low - R/clr */
-	E1000_TORH     = 0x040C4, /* Total Octets RX High - R/clr */
-	E1000_TOTL     = 0x040C8, /* Total Octets TX Low - R/clr */
-	E1000_TOTH     = 0x040CC, /* Total Octets TX High - R/clr */
-	E1000_TPR      = 0x040D0, /* Total Packets RX - R/clr */
-	E1000_TPT      = 0x040D4, /* Total Packets TX - R/clr */
-	E1000_PTC64    = 0x040D8, /* Packets TX (64 bytes) - R/clr */
-	E1000_PTC127   = 0x040DC, /* Packets TX (65-127 bytes) - R/clr */
-	E1000_PTC255   = 0x040E0, /* Packets TX (128-255 bytes) - R/clr */
-	E1000_PTC511   = 0x040E4, /* Packets TX (256-511 bytes) - R/clr */
-	E1000_PTC1023  = 0x040E8, /* Packets TX (512-1023 bytes) - R/clr */
-	E1000_PTC1522  = 0x040EC, /* Packets TX (1024-1522 Bytes) - R/clr */
-	E1000_MPTC     = 0x040F0, /* Multicast Packets TX Count - R/clr */
-	E1000_BPTC     = 0x040F4, /* Broadcast Packets TX Count - R/clr */
-	E1000_TSCTC    = 0x040F8, /* TCP Segmentation Context TX - R/clr */
-	E1000_TSCTFC   = 0x040FC, /* TCP Segmentation Context TX Fail - R/clr */
+	E1000_MGTPTC   = 0x040BC, /* Management Packets Tx Count - R/clr */
+	E1000_TORL     = 0x040C0, /* Total Octets Rx Low - R/clr */
+	E1000_TORH     = 0x040C4, /* Total Octets Rx High - R/clr */
+	E1000_TOTL     = 0x040C8, /* Total Octets Tx Low - R/clr */
+	E1000_TOTH     = 0x040CC, /* Total Octets Tx High - R/clr */
+	E1000_TPR      = 0x040D0, /* Total Packets Rx - R/clr */
+	E1000_TPT      = 0x040D4, /* Total Packets Tx - R/clr */
+	E1000_PTC64    = 0x040D8, /* Packets Tx (64 bytes) - R/clr */
+	E1000_PTC127   = 0x040DC, /* Packets Tx (65-127 bytes) - R/clr */
+	E1000_PTC255   = 0x040E0, /* Packets Tx (128-255 bytes) - R/clr */
+	E1000_PTC511   = 0x040E4, /* Packets Tx (256-511 bytes) - R/clr */
+	E1000_PTC1023  = 0x040E8, /* Packets Tx (512-1023 bytes) - R/clr */
+	E1000_PTC1522  = 0x040EC, /* Packets Tx (1024-1522 Bytes) - R/clr */
+	E1000_MPTC     = 0x040F0, /* Multicast Packets Tx Count - R/clr */
+	E1000_BPTC     = 0x040F4, /* Broadcast Packets Tx Count - R/clr */
+	E1000_TSCTC    = 0x040F8, /* TCP Segmentation Context Tx - R/clr */
+	E1000_TSCTFC   = 0x040FC, /* TCP Segmentation Context Tx Fail - R/clr */
 	E1000_IAC      = 0x04100, /* Interrupt Assertion Count */
 	E1000_ICRXPTC  = 0x04104, /* Irq Cause Rx Packet Timer Expire Count */
 	E1000_ICRXATC  = 0x04108, /* Irq Cause Rx Abs Timer Expire Count */
@@ -183,7 +183,7 @@ enum e1e_registers {
 	E1000_ICTXQMTC = 0x0411C, /* Irq Cause Tx Queue MinThreshold Count */
 	E1000_ICRXDMTC = 0x04120, /* Irq Cause Rx Desc MinThreshold Count */
 	E1000_ICRXOC   = 0x04124, /* Irq Cause Receiver Overrun Count */
-	E1000_RXCSUM   = 0x05000, /* RX Checksum Control - RW */
+	E1000_RXCSUM   = 0x05000, /* Rx Checksum Control - RW */
 	E1000_RFCTL    = 0x05008, /* Receive Filter Control */
 	E1000_MTA      = 0x05200, /* Multicast Table Array - RW Array */
 	E1000_RA       = 0x05400, /* Receive Address - RW Array */
@@ -250,8 +250,8 @@ enum e1e_registers {
 #define E1000_VFTA_ENTRY_BIT_SHIFT_MASK	0x1F
 
 #define E1000_HICR_EN			0x01  /* Enable bit - RO */
-#define E1000_HICR_C			0x02  /* Driver sets this bit when done
-					       * to put command in RAM */
+/* Driver sets this bit when done to put command in RAM */
+#define E1000_HICR_C			0x02
 #define E1000_HICR_FW_RESET_ENABLE	0x40
 #define E1000_HICR_FW_RESET		0x80
 
@@ -400,7 +400,7 @@ enum e1000_rev_polarity{
 	e1000_rev_polarity_undefined = 0xFF
 };
 
-enum e1000_fc_mode {
+enum e1000_fc_type {
 	e1000_fc_none = 0,
 	e1000_fc_rx_pause,
 	e1000_fc_tx_pause,
@@ -685,8 +685,7 @@ struct e1000_mac_operations {
 	s32  (*get_link_up_info)(struct e1000_hw *, u16 *, u16 *);
 	s32  (*led_on)(struct e1000_hw *);
 	s32  (*led_off)(struct e1000_hw *);
-	void (*mc_addr_list_update)(struct e1000_hw *, u8 *, u32, u32,
-					 u32);
+	void (*update_mc_addr_list)(struct e1000_hw *, u8 *, u32, u32, u32);
 	s32  (*reset_hw)(struct e1000_hw *);
 	s32  (*init_hw)(struct e1000_hw *);
 	s32  (*setup_link)(struct e1000_hw *);
@@ -728,16 +727,12 @@ struct e1000_mac_info {
 	u8 perm_addr[6];
 
 	enum e1000_mac_type type;
-	enum e1000_fc_mode  fc;
-	enum e1000_fc_mode  original_fc;
 
 	u32 collision_delta;
 	u32 ledctl_default;
 	u32 ledctl_mode1;
 	u32 ledctl_mode2;
-	u32 max_frame_size;
 	u32 mc_filter_type;
-	u32 min_frame_size;
 	u32 tx_packet_delta;
 	u32 txcw;
 
@@ -748,9 +743,6 @@ struct e1000_mac_info {
 	u16 ifs_step_size;
 	u16 mta_reg_count;
 	u16 rar_entry_count;
-	u16 fc_high_water;
-	u16 fc_low_water;
-	u16 fc_pause_time;
 
 	u8  forced_speed_duplex;
 
@@ -780,6 +772,8 @@ struct e1000_phy_info {
 	u32 reset_delay_us; /* in usec */
 	u32 revision;
 
+	enum e1000_media_type media_type;
+
 	u16 autoneg_advertised;
 	u16 autoneg_mask;
 	u16 cable_length;
@@ -792,7 +786,7 @@ struct e1000_phy_info {
 	bool is_mdix;
 	bool polarity_correction;
 	bool speed_downgraded;
-	bool wait_for_link;
+	bool autoneg_wait_to_complete;
 };
 
 struct e1000_nvm_info {
@@ -817,6 +811,16 @@ struct e1000_bus_info {
 	u16 func;
 };
 
+struct e1000_fc_info {
+	u32 high_water;          /* Flow control high-water mark */
+	u32 low_water;           /* Flow control low-water mark */
+	u16 pause_time;          /* Flow control pause timer */
+	bool send_xon;           /* Flow control send XON */
+	bool strict_ieee;        /* Strict IEEE mode */
+	enum e1000_fc_type type; /* Type of flow control */
+	enum e1000_fc_type original_type;
+};
+
 struct e1000_dev_spec_82571 {
 	bool laa_is_present;
 	bool alt_mac_addr_is_present;
@@ -841,6 +845,7 @@ struct e1000_hw {
 	u8 __iomem *flash_address;
 
 	struct e1000_mac_info  mac;
+	struct e1000_fc_info   fc;
 	struct e1000_phy_info  phy;
 	struct e1000_nvm_info  nvm;
 	struct e1000_bus_info  bus;
@@ -850,8 +855,6 @@ struct e1000_hw {
 		struct e1000_dev_spec_82571	e82571;
 		struct e1000_dev_spec_ich8lan	ich8lan;
 	} dev_spec;
-
-	enum e1000_media_type media_type;
 };
 
 #ifdef DEBUG
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 0ae3955..e358a77 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2007 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -243,8 +243,7 @@ static s32 e1000_init_nvm_params_ich8lan(struct e1000_hw *hw)
 	u32 sector_end_addr;
 	u16 i;
 
-	/* Can't read flash registers if the register set isn't mapped.
-	 */
+	/* Can't read flash registers if the register set isn't mapped. */
 	if (!hw->flash_address) {
 		hw_dbg(hw, "ERROR: Flash registers not mapped\n");
 		return -E1000_ERR_CONFIG;
@@ -254,17 +253,21 @@ static s32 e1000_init_nvm_params_ich8lan(struct e1000_hw *hw)
 
 	gfpreg = er32flash(ICH_FLASH_GFPREG);
 
-	/* sector_X_addr is a "sector"-aligned address (4096 bytes)
+	/*
+	 * sector_X_addr is a "sector"-aligned address (4096 bytes)
 	 * Add 1 to sector_end_addr since this sector is included in
-	 * the overall size. */
+	 * the overall size.
+	 */
 	sector_base_addr = gfpreg & FLASH_GFPREG_BASE_MASK;
 	sector_end_addr = ((gfpreg >> 16) & FLASH_GFPREG_BASE_MASK) + 1;
 
 	/* flash_base_addr is byte-aligned */
 	nvm->flash_base_addr = sector_base_addr << FLASH_SECTOR_ADDR_SHIFT;
 
-	/* find total size of the NVM, then cut in half since the total
-	 * size represents two separate NVM banks. */
+	/*
+	 * find total size of the NVM, then cut in half since the total
+	 * size represents two separate NVM banks.
+	 */
 	nvm->flash_bank_size = (sector_end_addr - sector_base_addr)
 				<< FLASH_SECTOR_ADDR_SHIFT;
 	nvm->flash_bank_size /= 2;
@@ -295,7 +298,7 @@ static s32 e1000_init_mac_params_ich8lan(struct e1000_adapter *adapter)
 	struct e1000_mac_info *mac = &hw->mac;
 
 	/* Set media type function pointer */
-	hw->media_type = e1000_media_type_copper;
+	hw->phy.media_type = e1000_media_type_copper;
 
 	/* Set mta register count */
 	mac->mta_reg_count = 32;
@@ -450,7 +453,7 @@ static s32 e1000_phy_force_speed_duplex_ich8lan(struct e1000_hw *hw)
 
 	udelay(1);
 
-	if (phy->wait_for_link) {
+	if (phy->autoneg_wait_to_complete) {
 		hw_dbg(hw, "Waiting for forced speed/duplex link on IFE phy.\n");
 
 		ret_val = e1000e_phy_has_link_generic(hw,
@@ -496,7 +499,8 @@ static s32 e1000_phy_hw_reset_ich8lan(struct e1000_hw *hw)
 	if (ret_val)
 		return ret_val;
 
-	/* Initialize the PHY from the NVM on ICH platforms.  This
+	/*
+	 * Initialize the PHY from the NVM on ICH platforms.  This
 	 * is needed due to an issue where the NVM configuration is
 	 * not properly autoloaded after power transitions.
 	 * Therefore, after each PHY reset, we will load the
@@ -523,7 +527,8 @@ static s32 e1000_phy_hw_reset_ich8lan(struct e1000_hw *hw)
 			udelay(100);
 		} while ((!data) && --loop);
 
-		/* If basic configuration is incomplete before the above loop
+		/*
+		 * If basic configuration is incomplete before the above loop
 		 * count reaches 0, loading the configuration from NVM will
 		 * leave the PHY in a bad state possibly resulting in no link.
 		 */
@@ -536,8 +541,10 @@ static s32 e1000_phy_hw_reset_ich8lan(struct e1000_hw *hw)
 		data &= ~E1000_STATUS_LAN_INIT_DONE;
 		ew32(STATUS, data);
 
-		/* Make sure HW does not configure LCD from PHY
-		 * extended configuration before SW configuration */
+		/*
+		 * Make sure HW does not configure LCD from PHY
+		 * extended configuration before SW configuration
+		 */
 		data = er32(EXTCNF_CTRL);
 		if (data & E1000_EXTCNF_CTRL_LCD_WRITE_ENABLE)
 			return 0;
@@ -551,8 +558,7 @@ static s32 e1000_phy_hw_reset_ich8lan(struct e1000_hw *hw)
 		cnf_base_addr = data & E1000_EXTCNF_CTRL_EXT_CNF_POINTER_MASK;
 		cnf_base_addr >>= E1000_EXTCNF_CTRL_EXT_CNF_POINTER_SHIFT;
 
-		/* Configure LCD from extended configuration
-		 * region. */
+		/* Configure LCD from extended configuration region. */
 
 		/* cnf_base_addr is in DWORD */
 		word_addr = (u16)(cnf_base_addr << 1);
@@ -681,8 +687,8 @@ static s32 e1000_check_polarity_ife_ich8lan(struct e1000_hw *hw)
 	s32 ret_val;
 	u16 phy_data, offset, mask;
 
-	/* Polarity is determined based on the reversal feature
-	 * being enabled.
+	/*
+	 * Polarity is determined based on the reversal feature being enabled.
 	 */
 	if (phy->polarity_correction) {
 		offset	= IFE_PHY_EXTENDED_STATUS_CONTROL;
@@ -731,8 +737,10 @@ static s32 e1000_set_d0_lplu_state_ich8lan(struct e1000_hw *hw, bool active)
 		phy_ctrl |= E1000_PHY_CTRL_D0A_LPLU;
 		ew32(PHY_CTRL, phy_ctrl);
 
-		/* Call gig speed drop workaround on LPLU before accessing
-		 * any PHY registers */
+		/*
+		 * Call gig speed drop workaround on LPLU before accessing
+		 * any PHY registers
+		 */
 		if ((hw->mac.type == e1000_ich8lan) &&
 		    (hw->phy.type == e1000_phy_igp_3))
 			e1000e_gig_downshift_workaround_ich8lan(hw);
@@ -747,30 +755,32 @@ static s32 e1000_set_d0_lplu_state_ich8lan(struct e1000_hw *hw, bool active)
 		phy_ctrl &= ~E1000_PHY_CTRL_D0A_LPLU;
 		ew32(PHY_CTRL, phy_ctrl);
 
-		/* LPLU and SmartSpeed are mutually exclusive.  LPLU is used
+		/*
+		 * LPLU and SmartSpeed are mutually exclusive.  LPLU is used
 		 * during Dx states where the power conservation is most
 		 * important.  During driver activity we should enable
-		 * SmartSpeed, so performance is maintained. */
+		 * SmartSpeed, so performance is maintained.
+		 */
 		if (phy->smart_speed == e1000_smart_speed_on) {
 			ret_val = e1e_rphy(hw, IGP01E1000_PHY_PORT_CONFIG,
-						    &data);
+					   &data);
 			if (ret_val)
 				return ret_val;
 
 			data |= IGP01E1000_PSCFR_SMART_SPEED;
 			ret_val = e1e_wphy(hw, IGP01E1000_PHY_PORT_CONFIG,
-						     data);
+					   data);
 			if (ret_val)
 				return ret_val;
 		} else if (phy->smart_speed == e1000_smart_speed_off) {
 			ret_val = e1e_rphy(hw, IGP01E1000_PHY_PORT_CONFIG,
-						    &data);
+					   &data);
 			if (ret_val)
 				return ret_val;
 
 			data &= ~IGP01E1000_PSCFR_SMART_SPEED;
 			ret_val = e1e_wphy(hw, IGP01E1000_PHY_PORT_CONFIG,
-						     data);
+					   data);
 			if (ret_val)
 				return ret_val;
 		}
@@ -804,34 +814,32 @@ static s32 e1000_set_d3_lplu_state_ich8lan(struct e1000_hw *hw, bool active)
 	if (!active) {
 		phy_ctrl &= ~E1000_PHY_CTRL_NOND0A_LPLU;
 		ew32(PHY_CTRL, phy_ctrl);
-		/* LPLU and SmartSpeed are mutually exclusive.  LPLU is used
+		/*
+		 * LPLU and SmartSpeed are mutually exclusive.  LPLU is used
 		 * during Dx states where the power conservation is most
 		 * important.  During driver activity we should enable
-		 * SmartSpeed, so performance is maintained. */
+		 * SmartSpeed, so performance is maintained.
+		 */
 		if (phy->smart_speed == e1000_smart_speed_on) {
-			ret_val = e1e_rphy(hw,
-						    IGP01E1000_PHY_PORT_CONFIG,
-						    &data);
+			ret_val = e1e_rphy(hw, IGP01E1000_PHY_PORT_CONFIG,
+					   &data);
 			if (ret_val)
 				return ret_val;
 
 			data |= IGP01E1000_PSCFR_SMART_SPEED;
-			ret_val = e1e_wphy(hw,
-						     IGP01E1000_PHY_PORT_CONFIG,
-						     data);
+			ret_val = e1e_wphy(hw, IGP01E1000_PHY_PORT_CONFIG,
+					   data);
 			if (ret_val)
 				return ret_val;
 		} else if (phy->smart_speed == e1000_smart_speed_off) {
-			ret_val = e1e_rphy(hw,
-						    IGP01E1000_PHY_PORT_CONFIG,
-						    &data);
+			ret_val = e1e_rphy(hw, IGP01E1000_PHY_PORT_CONFIG,
+					   &data);
 			if (ret_val)
 				return ret_val;
 
 			data &= ~IGP01E1000_PSCFR_SMART_SPEED;
-			ret_val = e1e_wphy(hw,
-						     IGP01E1000_PHY_PORT_CONFIG,
-						     data);
+			ret_val = e1e_wphy(hw, IGP01E1000_PHY_PORT_CONFIG,
+					   data);
 			if (ret_val)
 				return ret_val;
 		}
@@ -841,23 +849,21 @@ static s32 e1000_set_d3_lplu_state_ich8lan(struct e1000_hw *hw, bool active)
 		phy_ctrl |= E1000_PHY_CTRL_NOND0A_LPLU;
 		ew32(PHY_CTRL, phy_ctrl);
 
-		/* Call gig speed drop workaround on LPLU before accessing
-		 * any PHY registers */
+		/*
+		 * Call gig speed drop workaround on LPLU before accessing
+		 * any PHY registers
+		 */
 		if ((hw->mac.type == e1000_ich8lan) &&
 		    (hw->phy.type == e1000_phy_igp_3))
 			e1000e_gig_downshift_workaround_ich8lan(hw);
 
 		/* When LPLU is enabled, we should disable SmartSpeed */
-		ret_val = e1e_rphy(hw,
-					    IGP01E1000_PHY_PORT_CONFIG,
-					    &data);
+		ret_val = e1e_rphy(hw, IGP01E1000_PHY_PORT_CONFIG, &data);
 		if (ret_val)
 			return ret_val;
 
 		data &= ~IGP01E1000_PSCFR_SMART_SPEED;
-		ret_val = e1e_wphy(hw,
-					     IGP01E1000_PHY_PORT_CONFIG,
-					     data);
+		ret_val = e1e_wphy(hw, IGP01E1000_PHY_PORT_CONFIG, data);
 	}
 
 	return 0;
@@ -944,7 +950,8 @@ static s32 e1000_flash_cycle_init_ich8lan(struct e1000_hw *hw)
 
 	ew16flash(ICH_FLASH_HSFSTS, hsfsts.regval);
 
-	/* Either we should have a hardware SPI cycle in progress
+	/*
+	 * Either we should have a hardware SPI cycle in progress
 	 * bit to check against, in order to start a new cycle or
 	 * FDONE bit should be changed in the hardware so that it
 	 * is 1 after hardware reset, which can then be used as an
@@ -953,15 +960,19 @@ static s32 e1000_flash_cycle_init_ich8lan(struct e1000_hw *hw)
 	 */
 
 	if (hsfsts.hsf_status.flcinprog == 0) {
-		/* There is no cycle running at present,
-		 * so we can start a cycle */
-		/* Begin by setting Flash Cycle Done. */
+		/*
+		 * There is no cycle running at present,
+		 * so we can start a cycle
+		 * Begin by setting Flash Cycle Done.
+		 */
 		hsfsts.hsf_status.flcdone = 1;
 		ew16flash(ICH_FLASH_HSFSTS, hsfsts.regval);
 		ret_val = 0;
 	} else {
-		/* otherwise poll for sometime so the current
-		 * cycle has a chance to end before giving up. */
+		/*
+		 * otherwise poll for sometime so the current
+		 * cycle has a chance to end before giving up.
+		 */
 		for (i = 0; i < ICH_FLASH_READ_COMMAND_TIMEOUT; i++) {
 			hsfsts.regval = __er16flash(hw, ICH_FLASH_HSFSTS);
 			if (hsfsts.hsf_status.flcinprog == 0) {
@@ -971,8 +982,10 @@ static s32 e1000_flash_cycle_init_ich8lan(struct e1000_hw *hw)
 			udelay(1);
 		}
 		if (ret_val == 0) {
-			/* Successful in waiting for previous cycle to timeout,
-			 * now set the Flash Cycle Done. */
+			/*
+			 * Successful in waiting for previous cycle to timeout,
+			 * now set the Flash Cycle Done.
+			 */
 			hsfsts.hsf_status.flcdone = 1;
 			ew16flash(ICH_FLASH_HSFSTS, hsfsts.regval);
 		} else {
@@ -1077,10 +1090,12 @@ static s32 e1000_read_flash_data_ich8lan(struct e1000_hw *hw, u32 offset,
 		ret_val = e1000_flash_cycle_ich8lan(hw,
 						ICH_FLASH_READ_COMMAND_TIMEOUT);
 
-		/* Check if FCERR is set to 1, if set to 1, clear it
+		/*
+		 * Check if FCERR is set to 1, if set to 1, clear it
 		 * and try the whole sequence a few more times, else
 		 * read in (shift in) the Flash Data0, the order is
-		 * least significant byte first msb to lsb */
+		 * least significant byte first msb to lsb
+		 */
 		if (ret_val == 0) {
 			flash_data = er32flash(ICH_FLASH_FDATA0);
 			if (size == 1) {
@@ -1090,7 +1105,8 @@ static s32 e1000_read_flash_data_ich8lan(struct e1000_hw *hw, u32 offset,
 			}
 			break;
 		} else {
-			/* If we've gotten here, then things are probably
+			/*
+			 * If we've gotten here, then things are probably
 			 * completely hosed, but if the error condition is
 			 * detected, it won't hurt to give it another try...
 			 * ICH_FLASH_CYCLE_REPEAT_COUNT times.
@@ -1168,18 +1184,20 @@ static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
 
 	ret_val = e1000e_update_nvm_checksum_generic(hw);
 	if (ret_val)
-		return ret_val;;
+		return ret_val;
 
 	if (nvm->type != e1000_nvm_flash_sw)
-		return ret_val;;
+		return ret_val;
 
 	ret_val = e1000_acquire_swflag_ich8lan(hw);
 	if (ret_val)
-		return ret_val;;
+		return ret_val;
 
-	/* We're writing to the opposite bank so if we're on bank 1,
+	/*
+	 * We're writing to the opposite bank so if we're on bank 1,
 	 * write to bank 0 etc.  We also need to erase the segment that
-	 * is going to be written */
+	 * is going to be written
+	 */
 	if (!(er32(EECD) & E1000_EECD_SEC1VAL)) {
 		new_bank_offset = nvm->flash_bank_size;
 		old_bank_offset = 0;
@@ -1191,9 +1209,11 @@ static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
 	}
 
 	for (i = 0; i < E1000_ICH8_SHADOW_RAM_WORDS; i++) {
-		/* Determine whether to write the value stored
+		/*
+		 * Determine whether to write the value stored
 		 * in the other NVM bank or a modified value stored
-		 * in the shadow RAM */
+		 * in the shadow RAM
+		 */
 		if (dev_spec->shadow_ram[i].modified) {
 			data = dev_spec->shadow_ram[i].value;
 		} else {
@@ -1202,12 +1222,14 @@ static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
 						      &data);
 		}
 
-		/* If the word is 0x13, then make sure the signature bits
+		/*
+		 * If the word is 0x13, then make sure the signature bits
 		 * (15:14) are 11b until the commit has completed.
 		 * This will allow us to write 10b which indicates the
 		 * signature is valid.  We want to do this after the write
 		 * has completed so that we don't mark the segment valid
-		 * while the write is still in progress */
+		 * while the write is still in progress
+		 */
 		if (i == E1000_ICH_NVM_SIG_WORD)
 			data |= E1000_ICH_NVM_SIG_MASK;
 
@@ -1230,18 +1252,22 @@ static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
 			break;
 	}
 
-	/* Don't bother writing the segment valid bits if sector
-	 * programming failed. */
+	/*
+	 * Don't bother writing the segment valid bits if sector
+	 * programming failed.
+	 */
 	if (ret_val) {
 		hw_dbg(hw, "Flash commit failed.\n");
 		e1000_release_swflag_ich8lan(hw);
 		return ret_val;
 	}
 
-	/* Finally validate the new segment by setting bit 15:14
+	/*
+	 * Finally validate the new segment by setting bit 15:14
 	 * to 10b in word 0x13 , this can be done without an
 	 * erase as well since these bits are 11 to start with
-	 * and we need to change bit 14 to 0b */
+	 * and we need to change bit 14 to 0b
+	 */
 	act_offset = new_bank_offset + E1000_ICH_NVM_SIG_WORD;
 	e1000_read_flash_word_ich8lan(hw, act_offset, &data);
 	data &= 0xBFFF;
@@ -1253,10 +1279,12 @@ static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
 		return ret_val;
 	}
 
-	/* And invalidate the previously valid segment by setting
+	/*
+	 * And invalidate the previously valid segment by setting
 	 * its signature word (0x13) high_byte to 0b. This can be
 	 * done without an erase because flash erase sets all bits
-	 * to 1's. We can write 1's to 0's without an erase */
+	 * to 1's. We can write 1's to 0's without an erase
+	 */
 	act_offset = (old_bank_offset + E1000_ICH_NVM_SIG_WORD) * 2 + 1;
 	ret_val = e1000_retry_write_flash_byte_ich8lan(hw, act_offset, 0);
 	if (ret_val) {
@@ -1272,7 +1300,8 @@ static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
 
 	e1000_release_swflag_ich8lan(hw);
 
-	/* Reload the EEPROM, or else modifications will not appear
+	/*
+	 * Reload the EEPROM, or else modifications will not appear
 	 * until after the next adapter reset.
 	 */
 	e1000e_reload_nvm(hw);
@@ -1294,7 +1323,8 @@ static s32 e1000_validate_nvm_checksum_ich8lan(struct e1000_hw *hw)
 	s32 ret_val;
 	u16 data;
 
-	/* Read 0x19 and check bit 6.  If this bit is 0, the checksum
+	/*
+	 * Read 0x19 and check bit 6.  If this bit is 0, the checksum
 	 * needs to be fixed.  This bit is an indication that the NVM
 	 * was prepared by OEM software and did not calculate the
 	 * checksum...a likely scenario.
@@ -1364,14 +1394,17 @@ static s32 e1000_write_flash_data_ich8lan(struct e1000_hw *hw, u32 offset,
 
 		ew32flash(ICH_FLASH_FDATA0, flash_data);
 
-		/* check if FCERR is set to 1 , if set to 1, clear it
-		 * and try the whole sequence a few more times else done */
+		/*
+		 * check if FCERR is set to 1 , if set to 1, clear it
+		 * and try the whole sequence a few more times else done
+		 */
 		ret_val = e1000_flash_cycle_ich8lan(hw,
 					       ICH_FLASH_WRITE_COMMAND_TIMEOUT);
 		if (!ret_val)
 			break;
 
-		/* If we're here, then things are most likely
+		/*
+		 * If we're here, then things are most likely
 		 * completely hosed, but if the error condition
 		 * is detected, it won't hurt to give it another
 		 * try...ICH_FLASH_CYCLE_REPEAT_COUNT times.
@@ -1462,9 +1495,10 @@ static s32 e1000_erase_flash_bank_ich8lan(struct e1000_hw *hw, u32 bank)
 
 	hsfsts.regval = er16flash(ICH_FLASH_HSFSTS);
 
-	/* Determine HW Sector size: Read BERASE bits of hw flash status
-	 * register */
-	/* 00: The Hw sector is 256 bytes, hence we need to erase 16
+	/*
+	 * Determine HW Sector size: Read BERASE bits of hw flash status
+	 * register
+	 * 00: The Hw sector is 256 bytes, hence we need to erase 16
 	 *     consecutive sectors.  The start index for the nth Hw sector
 	 *     can be calculated as = bank * 4096 + n * 256
 	 * 01: The Hw sector is 4K bytes, hence we need to erase 1 sector.
@@ -1511,13 +1545,16 @@ static s32 e1000_erase_flash_bank_ich8lan(struct e1000_hw *hw, u32 bank)
 			if (ret_val)
 				return ret_val;
 
-			/* Write a value 11 (block Erase) in Flash
-			 * Cycle field in hw flash control */
+			/*
+			 * Write a value 11 (block Erase) in Flash
+			 * Cycle field in hw flash control
+			 */
 			hsflctl.regval = er16flash(ICH_FLASH_HSFCTL);
 			hsflctl.hsf_ctrl.flcycle = ICH_CYCLE_ERASE;
 			ew16flash(ICH_FLASH_HSFCTL, hsflctl.regval);
 
-			/* Write the last 24 bits of an index within the
+			/*
+			 * Write the last 24 bits of an index within the
 			 * block into Flash Linear address field in Flash
 			 * Address.
 			 */
@@ -1529,13 +1566,14 @@ static s32 e1000_erase_flash_bank_ich8lan(struct e1000_hw *hw, u32 bank)
 			if (ret_val == 0)
 				break;
 
-			/* Check if FCERR is set to 1.  If 1,
+			/*
+			 * Check if FCERR is set to 1.  If 1,
 			 * clear it and try the whole sequence
-			 * a few more times else Done */
+			 * a few more times else Done
+			 */
 			hsfsts.regval = er16flash(ICH_FLASH_HSFSTS);
 			if (hsfsts.hsf_status.flcerr == 1)
-				/* repeat for some time before
-				 * giving up */
+				/* repeat for some time before giving up */
 				continue;
 			else if (hsfsts.hsf_status.flcdone == 0)
 				return ret_val;
@@ -1585,7 +1623,8 @@ static s32 e1000_get_bus_info_ich8lan(struct e1000_hw *hw)
 
 	ret_val = e1000e_get_bus_info_pcie(hw);
 
-	/* ICH devices are "PCI Express"-ish.  They have
+	/*
+	 * ICH devices are "PCI Express"-ish.  They have
 	 * a configuration space, but do not contain
 	 * PCI Express Capability registers, so bus width
 	 * must be hardcoded.
@@ -1608,7 +1647,8 @@ static s32 e1000_reset_hw_ich8lan(struct e1000_hw *hw)
 	u32 ctrl, icr, kab;
 	s32 ret_val;
 
-	/* Prevent the PCI-E bus from sticking if there is no TLP connection
+	/*
+	 * Prevent the PCI-E bus from sticking if there is no TLP connection
 	 * on the last TLP read/write transaction when MAC is reset.
 	 */
 	ret_val = e1000e_disable_pcie_master(hw);
@@ -1619,7 +1659,8 @@ static s32 e1000_reset_hw_ich8lan(struct e1000_hw *hw)
 	hw_dbg(hw, "Masking off all interrupts\n");
 	ew32(IMC, 0xffffffff);
 
-	/* Disable the Transmit and Receive units.  Then delay to allow
+	/*
+	 * Disable the Transmit and Receive units.  Then delay to allow
 	 * any pending transactions to complete before we hit the MAC
 	 * with the global reset.
 	 */
@@ -1640,7 +1681,8 @@ static s32 e1000_reset_hw_ich8lan(struct e1000_hw *hw)
 	ctrl = er32(CTRL);
 
 	if (!e1000_check_reset_block(hw)) {
-		/* PHY HW reset requires MAC CORE reset at the same
+		/*
+		 * PHY HW reset requires MAC CORE reset at the same
 		 * time to make sure the interface between MAC and the
 		 * external PHY is reset.
 		 */
@@ -1724,8 +1766,10 @@ static s32 e1000_init_hw_ich8lan(struct e1000_hw *hw)
 		 E1000_TXDCTL_MAX_TX_DESC_PREFETCH;
 	ew32(TXDCTL1, txdctl);
 
-	/* ICH8 has opposite polarity of no_snoop bits.
-	 * By default, we should use snoop behavior. */
+	/*
+	 * ICH8 has opposite polarity of no_snoop bits.
+	 * By default, we should use snoop behavior.
+	 */
 	if (mac->type == e1000_ich8lan)
 		snoop = PCIE_ICH8_SNOOP_ALL;
 	else
@@ -1736,7 +1780,8 @@ static s32 e1000_init_hw_ich8lan(struct e1000_hw *hw)
 	ctrl_ext |= E1000_CTRL_EXT_RO_DIS;
 	ew32(CTRL_EXT, ctrl_ext);
 
-	/* Clear all of the statistics registers (clear on read).  It is
+	/*
+	 * Clear all of the statistics registers (clear on read).  It is
 	 * important that we do this after we have tried to establish link
 	 * because the symbol error count will increment wildly if there
 	 * is no link.
@@ -1807,29 +1852,29 @@ static void e1000_initialize_hw_bits_ich8lan(struct e1000_hw *hw)
  **/
 static s32 e1000_setup_link_ich8lan(struct e1000_hw *hw)
 {
-	struct e1000_mac_info *mac = &hw->mac;
 	s32 ret_val;
 
 	if (e1000_check_reset_block(hw))
 		return 0;
 
-	/* ICH parts do not have a word in the NVM to determine
+	/*
+	 * ICH parts do not have a word in the NVM to determine
 	 * the default flow control setting, so we explicitly
 	 * set it to full.
 	 */
-	if (mac->fc == e1000_fc_default)
-		mac->fc = e1000_fc_full;
+	if (hw->fc.type == e1000_fc_default)
+		hw->fc.type = e1000_fc_full;
 
-	mac->original_fc = mac->fc;
+	hw->fc.original_type = hw->fc.type;
 
-	hw_dbg(hw, "After fix-ups FlowControl is now = %x\n", mac->fc);
+	hw_dbg(hw, "After fix-ups FlowControl is now = %x\n", hw->fc.type);
 
 	/* Continue to configure the copper link. */
 	ret_val = e1000_setup_copper_link_ich8lan(hw);
 	if (ret_val)
 		return ret_val;
 
-	ew32(FCTTV, mac->fc_pause_time);
+	ew32(FCTTV, hw->fc.pause_time);
 
 	return e1000e_set_fc_watermarks(hw);
 }
@@ -1853,9 +1898,11 @@ static s32 e1000_setup_copper_link_ich8lan(struct e1000_hw *hw)
 	ctrl &= ~(E1000_CTRL_FRCSPD | E1000_CTRL_FRCDPX);
 	ew32(CTRL, ctrl);
 
-	/* Set the mac to wait the maximum time between each iteration
+	/*
+	 * Set the mac to wait the maximum time between each iteration
 	 * and increase the max iterations when polling the phy;
-	 * this fixes erroneous timeouts at 10Mbps. */
+	 * this fixes erroneous timeouts at 10Mbps.
+	 */
 	ret_val = e1000e_write_kmrn_reg(hw, GG82563_REG(0x34, 4), 0xFFFF);
 	if (ret_val)
 		return ret_val;
@@ -1882,7 +1929,7 @@ static s32 e1000_setup_copper_link_ich8lan(struct e1000_hw *hw)
  *  @speed: pointer to store current link speed
  *  @duplex: pointer to store the current link duplex
  *
- *  Calls the generic get_speed_and_duplex to retreive the current link
+ *  Calls the generic get_speed_and_duplex to retrieve the current link
  *  information and then calls the Kumeran lock loss workaround for links at
  *  gigabit speeds.
  **/
@@ -1930,9 +1977,11 @@ static s32 e1000_kmrn_lock_loss_workaround_ich8lan(struct e1000_hw *hw)
 	if (!dev_spec->kmrn_lock_loss_workaround_enabled)
 		return 0;
 
-	/* Make sure link is up before proceeding.  If not just return.
+	/*
+	 * Make sure link is up before proceeding.  If not just return.
 	 * Attempting this while link is negotiating fouled up link
-	 * stability */
+	 * stability
+	 */
 	ret_val = e1000e_phy_has_link_generic(hw, 1, 0, &link);
 	if (!link)
 		return 0;
@@ -1961,8 +2010,10 @@ static s32 e1000_kmrn_lock_loss_workaround_ich8lan(struct e1000_hw *hw)
 		     E1000_PHY_CTRL_NOND0A_GBE_DISABLE);
 	ew32(PHY_CTRL, phy_ctrl);
 
-	/* Call gig speed drop workaround on Gig disable before accessing
-	 * any PHY registers */
+	/*
+	 * Call gig speed drop workaround on Gig disable before accessing
+	 * any PHY registers
+	 */
 	e1000e_gig_downshift_workaround_ich8lan(hw);
 
 	/* unable to acquire PCS lock */
@@ -1970,7 +2021,7 @@ static s32 e1000_kmrn_lock_loss_workaround_ich8lan(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_set_kmrn_lock_loss_workaound_ich8lan - Set Kumeran workaround state
+ *  e1000_set_kmrn_lock_loss_workaround_ich8lan - Set Kumeran workaround state
  *  @hw: pointer to the HW structure
  *  @state: boolean value used to set the current Kumeran workaround state
  *
@@ -2017,8 +2068,10 @@ void e1000e_igp3_phy_powerdown_workaround_ich8lan(struct e1000_hw *hw)
 			E1000_PHY_CTRL_NOND0A_GBE_DISABLE);
 		ew32(PHY_CTRL, reg);
 
-		/* Call gig speed drop workaround on Gig disable before
-		 * accessing any PHY registers */
+		/*
+		 * Call gig speed drop workaround on Gig disable before
+		 * accessing any PHY registers
+		 */
 		if (hw->mac.type == e1000_ich8lan)
 			e1000e_gig_downshift_workaround_ich8lan(hw);
 
@@ -2158,7 +2211,7 @@ static struct e1000_mac_operations ich8_mac_ops = {
 	.get_link_up_info	= e1000_get_link_up_info_ich8lan,
 	.led_on			= e1000_led_on_ich8lan,
 	.led_off		= e1000_led_off_ich8lan,
-	.mc_addr_list_update	= e1000e_mc_addr_list_update_generic,
+	.update_mc_addr_list	= e1000e_update_mc_addr_list_generic,
 	.reset_hw		= e1000_reset_hw_ich8lan,
 	.init_hw		= e1000_init_hw_ich8lan,
 	.setup_link		= e1000_setup_link_ich8lan,
diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index 073934c..ea3ff63 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2007 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -43,8 +43,8 @@ enum e1000_mng_mode {
 
 #define E1000_FACTPS_MNGCG		0x20000000
 
-#define E1000_IAMT_SIGNATURE		0x544D4149 /* Intel(R) Active Management
-						    * Technology signature */
+/* Intel(R) Active Management Technology signature */
+#define E1000_IAMT_SIGNATURE		0x544D4149
 
 /**
  *  e1000e_get_bus_info_pcie - Get PCIe bus information
@@ -142,7 +142,8 @@ void e1000e_rar_set(struct e1000_hw *hw, u8 *addr, u32 index)
 {
 	u32 rar_low, rar_high;
 
-	/* HW expects these in little endian so we reverse the byte order
+	/*
+	 * HW expects these in little endian so we reverse the byte order
 	 * from network order (big endian) to little endian
 	 */
 	rar_low = ((u32) addr[0] |
@@ -171,7 +172,8 @@ static void e1000_mta_set(struct e1000_hw *hw, u32 hash_value)
 {
 	u32 hash_bit, hash_reg, mta;
 
-	/* The MTA is a register array of 32-bit registers. It is
+	/*
+	 * The MTA is a register array of 32-bit registers. It is
 	 * treated like an array of (32*mta_reg_count) bits.  We want to
 	 * set bit BitArray[hash_value]. So we figure out what register
 	 * the bit is in, read it, OR in the new bit, then write
@@ -208,12 +210,15 @@ static u32 e1000_hash_mc_addr(struct e1000_hw *hw, u8 *mc_addr)
 	/* Register count multiplied by bits per register */
 	hash_mask = (hw->mac.mta_reg_count * 32) - 1;
 
-	/* For a mc_filter_type of 0, bit_shift is the number of left-shifts
-	 * where 0xFF would still fall within the hash mask. */
+	/*
+	 * For a mc_filter_type of 0, bit_shift is the number of left-shifts
+	 * where 0xFF would still fall within the hash mask.
+	 */
 	while (hash_mask >> bit_shift != 0xFF)
 		bit_shift++;
 
-	/* The portion of the address that is used for the hash table
+	/*
+	 * The portion of the address that is used for the hash table
 	 * is determined by the mc_filter_type setting.
 	 * The algorithm is such that there is a total of 8 bits of shifting.
 	 * The bit_shift for a mc_filter_type of 0 represents the number of
@@ -224,8 +229,8 @@ static u32 e1000_hash_mc_addr(struct e1000_hw *hw, u8 *mc_addr)
 	 * cases are a variation of this algorithm...essentially raising the
 	 * number of bits to shift mc_addr[5] left, while still keeping the
 	 * 8-bit shifting total.
-	 */
-	/* For example, given the following Destination MAC Address and an
+	 *
+	 * For example, given the following Destination MAC Address and an
 	 * mta register count of 128 (thus a 4096-bit vector and 0xFFF mask),
 	 * we can see that the bit_shift for case 0 is 4.  These are the hash
 	 * values resulting from each mc_filter_type...
@@ -260,7 +265,7 @@ static u32 e1000_hash_mc_addr(struct e1000_hw *hw, u8 *mc_addr)
 }
 
 /**
- *  e1000e_mc_addr_list_update_generic - Update Multicast addresses
+ *  e1000e_update_mc_addr_list_generic - Update Multicast addresses
  *  @hw: pointer to the HW structure
  *  @mc_addr_list: array of multicast addresses to program
  *  @mc_addr_count: number of multicast addresses to program
@@ -272,14 +277,15 @@ static u32 e1000_hash_mc_addr(struct e1000_hw *hw, u8 *mc_addr)
  *  The parameter rar_count will usually be hw->mac.rar_entry_count
  *  unless there are workarounds that change this.
  **/
-void e1000e_mc_addr_list_update_generic(struct e1000_hw *hw,
-				       u8 *mc_addr_list, u32 mc_addr_count,
-				       u32 rar_used_count, u32 rar_count)
+void e1000e_update_mc_addr_list_generic(struct e1000_hw *hw,
+					u8 *mc_addr_list, u32 mc_addr_count,
+					u32 rar_used_count, u32 rar_count)
 {
 	u32 hash_value;
 	u32 i;
 
-	/* Load the first set of multicast addresses into the exact
+	/*
+	 * Load the first set of multicast addresses into the exact
 	 * filters (RAR).  If there are not enough to fill the RAR
 	 * array, clear the filters.
 	 */
@@ -375,7 +381,8 @@ s32 e1000e_check_for_copper_link(struct e1000_hw *hw)
 	s32 ret_val;
 	bool link;
 
-	/* We only want to go out to the PHY registers to see if Auto-Neg
+	/*
+	 * We only want to go out to the PHY registers to see if Auto-Neg
 	 * has completed and/or if our link status has changed.  The
 	 * get_link_status flag is set upon receiving a Link Status
 	 * Change or Rx Sequence Error interrupt.
@@ -383,7 +390,8 @@ s32 e1000e_check_for_copper_link(struct e1000_hw *hw)
 	if (!mac->get_link_status)
 		return 0;
 
-	/* First we want to see if the MII Status Register reports
+	/*
+	 * First we want to see if the MII Status Register reports
 	 * link.  If so, then we want to get the current speed/duplex
 	 * of the PHY.
 	 */
@@ -396,11 +404,14 @@ s32 e1000e_check_for_copper_link(struct e1000_hw *hw)
 
 	mac->get_link_status = 0;
 
-	/* Check if there was DownShift, must be checked
-	 * immediately after link-up */
+	/*
+	 * Check if there was DownShift, must be checked
+	 * immediately after link-up
+	 */
 	e1000e_check_downshift(hw);
 
-	/* If we are forcing speed/duplex, then we simply return since
+	/*
+	 * If we are forcing speed/duplex, then we simply return since
 	 * we have already determined whether we have link or not.
 	 */
 	if (!mac->autoneg) {
@@ -408,13 +419,15 @@ s32 e1000e_check_for_copper_link(struct e1000_hw *hw)
 		return ret_val;
 	}
 
-	/* Auto-Neg is enabled.  Auto Speed Detection takes care
+	/*
+	 * Auto-Neg is enabled.  Auto Speed Detection takes care
 	 * of MAC speed/duplex configuration.  So we only need to
 	 * configure Collision Distance in the MAC.
 	 */
 	e1000e_config_collision_dist(hw);
 
-	/* Configure Flow Control now that Auto-Neg has completed.
+	/*
+	 * Configure Flow Control now that Auto-Neg has completed.
 	 * First, we need to restore the desired flow control
 	 * settings because we may have had to re-autoneg with a
 	 * different link partner.
@@ -446,7 +459,8 @@ s32 e1000e_check_for_fiber_link(struct e1000_hw *hw)
 	status = er32(STATUS);
 	rxcw = er32(RXCW);
 
-	/* If we don't have link (auto-negotiation failed or link partner
+	/*
+	 * If we don't have link (auto-negotiation failed or link partner
 	 * cannot auto-negotiate), the cable is plugged in (we have signal),
 	 * and our link partner is not trying to auto-negotiate with us (we
 	 * are receiving idles or data), we need to force link up. We also
@@ -477,7 +491,8 @@ s32 e1000e_check_for_fiber_link(struct e1000_hw *hw)
 			return ret_val;
 		}
 	} else if ((ctrl & E1000_CTRL_SLU) && (rxcw & E1000_RXCW_C)) {
-		/* If we are forcing link and we are receiving /C/ ordered
+		/*
+		 * If we are forcing link and we are receiving /C/ ordered
 		 * sets, re-enable auto-negotiation in the TXCW register
 		 * and disable forced link in the Device Control register
 		 * in an attempt to auto-negotiate with our link partner.
@@ -511,7 +526,8 @@ s32 e1000e_check_for_serdes_link(struct e1000_hw *hw)
 	status = er32(STATUS);
 	rxcw = er32(RXCW);
 
-	/* If we don't have link (auto-negotiation failed or link partner
+	/*
+	 * If we don't have link (auto-negotiation failed or link partner
 	 * cannot auto-negotiate), and our link partner is not trying to
 	 * auto-negotiate with us (we are receiving idles or data),
 	 * we need to force link up. We also need to give auto-negotiation
@@ -540,7 +556,8 @@ s32 e1000e_check_for_serdes_link(struct e1000_hw *hw)
 			return ret_val;
 		}
 	} else if ((ctrl & E1000_CTRL_SLU) && (rxcw & E1000_RXCW_C)) {
-		/* If we are forcing link and we are receiving /C/ ordered
+		/*
+		 * If we are forcing link and we are receiving /C/ ordered
 		 * sets, re-enable auto-negotiation in the TXCW register
 		 * and disable forced link in the Device Control register
 		 * in an attempt to auto-negotiate with our link partner.
@@ -551,7 +568,8 @@ s32 e1000e_check_for_serdes_link(struct e1000_hw *hw)
 
 		mac->serdes_has_link = 1;
 	} else if (!(E1000_TXCW_ANE & er32(TXCW))) {
-		/* If we force link for non-auto-negotiation switch, check
+		/*
+		 * If we force link for non-auto-negotiation switch, check
 		 * link status based on MAC synchronization for internal
 		 * serdes media type.
 		 */
@@ -585,11 +603,11 @@ s32 e1000e_check_for_serdes_link(struct e1000_hw *hw)
  **/
 static s32 e1000_set_default_fc_generic(struct e1000_hw *hw)
 {
-	struct e1000_mac_info *mac = &hw->mac;
 	s32 ret_val;
 	u16 nvm_data;
 
-	/* Read and store word 0x0F of the EEPROM. This word contains bits
+	/*
+	 * Read and store word 0x0F of the EEPROM. This word contains bits
 	 * that determine the hardware's default PAUSE (flow control) mode,
 	 * a bit that determines whether the HW defaults to enabling or
 	 * disabling auto-negotiation, and the direction of the
@@ -605,12 +623,12 @@ static s32 e1000_set_default_fc_generic(struct e1000_hw *hw)
 	}
 
 	if ((nvm_data & NVM_WORD0F_PAUSE_MASK) == 0)
-		mac->fc = e1000_fc_none;
+		hw->fc.type = e1000_fc_none;
 	else if ((nvm_data & NVM_WORD0F_PAUSE_MASK) ==
 		 NVM_WORD0F_ASM_DIR)
-		mac->fc = e1000_fc_tx_pause;
+		hw->fc.type = e1000_fc_tx_pause;
 	else
-		mac->fc = e1000_fc_full;
+		hw->fc.type = e1000_fc_full;
 
 	return 0;
 }
@@ -630,7 +648,8 @@ s32 e1000e_setup_link(struct e1000_hw *hw)
 	struct e1000_mac_info *mac = &hw->mac;
 	s32 ret_val;
 
-	/* In the case of the phy reset being blocked, we already have a link.
+	/*
+	 * In the case of the phy reset being blocked, we already have a link.
 	 * We do not need to set it up again.
 	 */
 	if (e1000_check_reset_block(hw))
@@ -640,26 +659,28 @@ s32 e1000e_setup_link(struct e1000_hw *hw)
 	 * If flow control is set to default, set flow control based on
 	 * the EEPROM flow control settings.
 	 */
-	if (mac->fc == e1000_fc_default) {
+	if (hw->fc.type == e1000_fc_default) {
 		ret_val = e1000_set_default_fc_generic(hw);
 		if (ret_val)
 			return ret_val;
 	}
 
-	/* We want to save off the original Flow Control configuration just
+	/*
+	 * We want to save off the original Flow Control configuration just
 	 * in case we get disconnected and then reconnected into a different
 	 * hub or switch with different Flow Control capabilities.
 	 */
-	mac->original_fc = mac->fc;
+	hw->fc.original_type = hw->fc.type;
 
-	hw_dbg(hw, "After fix-ups FlowControl is now = %x\n", mac->fc);
+	hw_dbg(hw, "After fix-ups FlowControl is now = %x\n", hw->fc.type);
 
 	/* Call the necessary media_type subroutine to configure the link. */
 	ret_val = mac->ops.setup_physical_interface(hw);
 	if (ret_val)
 		return ret_val;
 
-	/* Initialize the flow control address, type, and PAUSE timer
+	/*
+	 * Initialize the flow control address, type, and PAUSE timer
 	 * registers to their default values.  This is done even if flow
 	 * control is disabled, because it does not hurt anything to
 	 * initialize these registers.
@@ -669,7 +690,7 @@ s32 e1000e_setup_link(struct e1000_hw *hw)
 	ew32(FCAH, FLOW_CONTROL_ADDRESS_HIGH);
 	ew32(FCAL, FLOW_CONTROL_ADDRESS_LOW);
 
-	ew32(FCTTV, mac->fc_pause_time);
+	ew32(FCTTV, hw->fc.pause_time);
 
 	return e1000e_set_fc_watermarks(hw);
 }
@@ -686,7 +707,8 @@ static s32 e1000_commit_fc_settings_generic(struct e1000_hw *hw)
 	struct e1000_mac_info *mac = &hw->mac;
 	u32 txcw;
 
-	/* Check for a software override of the flow control settings, and
+	/*
+	 * Check for a software override of the flow control settings, and
 	 * setup the device accordingly.  If auto-negotiation is enabled, then
 	 * software will have to set the "PAUSE" bits to the correct value in
 	 * the Transmit Config Word Register (TXCW) and re-start auto-
@@ -700,31 +722,34 @@ static s32 e1000_commit_fc_settings_generic(struct e1000_hw *hw)
 	 *	  but not send pause frames).
 	 *      2:  Tx flow control is enabled (we can send pause frames but we
 	 *	  do not support receiving pause frames).
-	 *      3:  Both Rx and TX flow control (symmetric) are enabled.
+	 *      3:  Both Rx and Tx flow control (symmetric) are enabled.
 	 */
-	switch (mac->fc) {
+	switch (hw->fc.type) {
 	case e1000_fc_none:
 		/* Flow control completely disabled by a software over-ride. */
 		txcw = (E1000_TXCW_ANE | E1000_TXCW_FD);
 		break;
 	case e1000_fc_rx_pause:
-		/* RX Flow control is enabled and TX Flow control is disabled
+		/*
+		 * Rx Flow control is enabled and Tx Flow control is disabled
 		 * by a software over-ride. Since there really isn't a way to
-		 * advertise that we are capable of RX Pause ONLY, we will
-		 * advertise that we support both symmetric and asymmetric RX
+		 * advertise that we are capable of Rx Pause ONLY, we will
+		 * advertise that we support both symmetric and asymmetric Rx
 		 * PAUSE.  Later, we will disable the adapter's ability to send
 		 * PAUSE frames.
 		 */
 		txcw = (E1000_TXCW_ANE | E1000_TXCW_FD | E1000_TXCW_PAUSE_MASK);
 		break;
 	case e1000_fc_tx_pause:
-		/* TX Flow control is enabled, and RX Flow control is disabled,
+		/*
+		 * Tx Flow control is enabled, and Rx Flow control is disabled,
 		 * by a software over-ride.
 		 */
 		txcw = (E1000_TXCW_ANE | E1000_TXCW_FD | E1000_TXCW_ASM_DIR);
 		break;
 	case e1000_fc_full:
-		/* Flow control (both RX and TX) is enabled by a software
+		/*
+		 * Flow control (both Rx and Tx) is enabled by a software
 		 * over-ride.
 		 */
 		txcw = (E1000_TXCW_ANE | E1000_TXCW_FD | E1000_TXCW_PAUSE_MASK);
@@ -754,7 +779,8 @@ static s32 e1000_poll_fiber_serdes_link_generic(struct e1000_hw *hw)
 	u32 i, status;
 	s32 ret_val;
 
-	/* If we have a signal (the cable is plugged in, or assumed true for
+	/*
+	 * If we have a signal (the cable is plugged in, or assumed true for
 	 * serdes media) then poll for a "Link-Up" indication in the Device
 	 * Status Register.  Time-out if a link isn't seen in 500 milliseconds
 	 * seconds (Auto-negotiation should complete in less than 500
@@ -769,7 +795,8 @@ static s32 e1000_poll_fiber_serdes_link_generic(struct e1000_hw *hw)
 	if (i == FIBER_LINK_UP_LIMIT) {
 		hw_dbg(hw, "Never got a valid link from auto-neg!!!\n");
 		mac->autoneg_failed = 1;
-		/* AutoNeg failed to achieve a link, so we'll call
+		/*
+		 * AutoNeg failed to achieve a link, so we'll call
 		 * mac->check_for_link. This routine will force the
 		 * link up if we detect a signal. This will allow us to
 		 * communicate with non-autonegotiating link partners.
@@ -811,7 +838,8 @@ s32 e1000e_setup_fiber_serdes_link(struct e1000_hw *hw)
 	if (ret_val)
 		return ret_val;
 
-	/* Since auto-negotiation is enabled, take the link out of reset (the
+	/*
+	 * Since auto-negotiation is enabled, take the link out of reset (the
 	 * link will be in reset, because we previously reset the chip). This
 	 * will restart auto-negotiation.  If auto-negotiation is successful
 	 * then the link-up status bit will be set and the flow control enable
@@ -823,11 +851,12 @@ s32 e1000e_setup_fiber_serdes_link(struct e1000_hw *hw)
 	e1e_flush();
 	msleep(1);
 
-	/* For these adapters, the SW defineable pin 1 is set when the optics
+	/*
+	 * For these adapters, the SW definable pin 1 is set when the optics
 	 * detect a signal.  If we have a signal, then poll for a "Link-Up"
 	 * indication.
 	 */
-	if (hw->media_type == e1000_media_type_internal_serdes ||
+	if (hw->phy.media_type == e1000_media_type_internal_serdes ||
 	    (er32(CTRL) & E1000_CTRL_SWDPIN1)) {
 		ret_val = e1000_poll_fiber_serdes_link_generic(hw);
 	} else {
@@ -864,27 +893,28 @@ void e1000e_config_collision_dist(struct e1000_hw *hw)
  *
  *  Sets the flow control high/low threshold (watermark) registers.  If
  *  flow control XON frame transmission is enabled, then set XON frame
- *  tansmission as well.
+ *  transmission as well.
  **/
 s32 e1000e_set_fc_watermarks(struct e1000_hw *hw)
 {
-	struct e1000_mac_info *mac = &hw->mac;
 	u32 fcrtl = 0, fcrth = 0;
 
-	/* Set the flow control receive threshold registers.  Normally,
+	/*
+	 * Set the flow control receive threshold registers.  Normally,
 	 * these registers will be set to a default threshold that may be
 	 * adjusted later by the driver's runtime code.  However, if the
 	 * ability to transmit pause frames is not enabled, then these
 	 * registers will be set to 0.
 	 */
-	if (mac->fc & e1000_fc_tx_pause) {
-		/* We need to set up the Receive Threshold high and low water
+	if (hw->fc.type & e1000_fc_tx_pause) {
+		/*
+		 * We need to set up the Receive Threshold high and low water
 		 * marks as well as (optionally) enabling the transmission of
 		 * XON frames.
 		 */
-		fcrtl = mac->fc_low_water;
+		fcrtl = hw->fc.low_water;
 		fcrtl |= E1000_FCRTL_XONE;
-		fcrth = mac->fc_high_water;
+		fcrth = hw->fc.high_water;
 	}
 	ew32(FCRTL, fcrtl);
 	ew32(FCRTH, fcrth);
@@ -904,18 +934,18 @@ s32 e1000e_set_fc_watermarks(struct e1000_hw *hw)
  **/
 s32 e1000e_force_mac_fc(struct e1000_hw *hw)
 {
-	struct e1000_mac_info *mac = &hw->mac;
 	u32 ctrl;
 
 	ctrl = er32(CTRL);
 
-	/* Because we didn't get link via the internal auto-negotiation
+	/*
+	 * Because we didn't get link via the internal auto-negotiation
 	 * mechanism (we either forced link or we got link via PHY
 	 * auto-neg), we have to manually enable/disable transmit an
 	 * receive flow control.
 	 *
 	 * The "Case" statement below enables/disable flow control
-	 * according to the "mac->fc" parameter.
+	 * according to the "hw->fc.type" parameter.
 	 *
 	 * The possible values of the "fc" parameter are:
 	 *      0:  Flow control is completely disabled
@@ -923,12 +953,12 @@ s32 e1000e_force_mac_fc(struct e1000_hw *hw)
 	 *	  frames but not send pause frames).
 	 *      2:  Tx flow control is enabled (we can send pause frames
 	 *	  frames but we do not receive pause frames).
-	 *      3:  Both Rx and TX flow control (symmetric) is enabled.
+	 *      3:  Both Rx and Tx flow control (symmetric) is enabled.
 	 *  other:  No other values should be possible at this point.
 	 */
-	hw_dbg(hw, "mac->fc = %u\n", mac->fc);
+	hw_dbg(hw, "hw->fc.type = %u\n", hw->fc.type);
 
-	switch (mac->fc) {
+	switch (hw->fc.type) {
 	case e1000_fc_none:
 		ctrl &= (~(E1000_CTRL_TFCE | E1000_CTRL_RFCE));
 		break;
@@ -970,16 +1000,17 @@ s32 e1000e_config_fc_after_link_up(struct e1000_hw *hw)
 	u16 mii_status_reg, mii_nway_adv_reg, mii_nway_lp_ability_reg;
 	u16 speed, duplex;
 
-	/* Check for the case where we have fiber media and auto-neg failed
+	/*
+	 * Check for the case where we have fiber media and auto-neg failed
 	 * so we had to force link.  In this case, we need to force the
 	 * configuration of the MAC to match the "fc" parameter.
 	 */
 	if (mac->autoneg_failed) {
-		if (hw->media_type == e1000_media_type_fiber ||
-		    hw->media_type == e1000_media_type_internal_serdes)
+		if (hw->phy.media_type == e1000_media_type_fiber ||
+		    hw->phy.media_type == e1000_media_type_internal_serdes)
 			ret_val = e1000e_force_mac_fc(hw);
 	} else {
-		if (hw->media_type == e1000_media_type_copper)
+		if (hw->phy.media_type == e1000_media_type_copper)
 			ret_val = e1000e_force_mac_fc(hw);
 	}
 
@@ -988,13 +1019,15 @@ s32 e1000e_config_fc_after_link_up(struct e1000_hw *hw)
 		return ret_val;
 	}
 
-	/* Check for the case where we have copper media and auto-neg is
+	/*
+	 * Check for the case where we have copper media and auto-neg is
 	 * enabled.  In this case, we need to check and see if Auto-Neg
 	 * has completed, and if so, how the PHY and link partner has
 	 * flow control configured.
 	 */
-	if ((hw->media_type == e1000_media_type_copper) && mac->autoneg) {
-		/* Read the MII Status Register and check to see if AutoNeg
+	if ((hw->phy.media_type == e1000_media_type_copper) && mac->autoneg) {
+		/*
+		 * Read the MII Status Register and check to see if AutoNeg
 		 * has completed.  We read this twice because this reg has
 		 * some "sticky" (latched) bits.
 		 */
@@ -1011,7 +1044,8 @@ s32 e1000e_config_fc_after_link_up(struct e1000_hw *hw)
 			return ret_val;
 		}
 
-		/* The AutoNeg process has completed, so we now need to
+		/*
+		 * The AutoNeg process has completed, so we now need to
 		 * read both the Auto Negotiation Advertisement
 		 * Register (Address 4) and the Auto_Negotiation Base
 		 * Page Ability Register (Address 5) to determine how
@@ -1024,7 +1058,8 @@ s32 e1000e_config_fc_after_link_up(struct e1000_hw *hw)
 		if (ret_val)
 			return ret_val;
 
-		/* Two bits in the Auto Negotiation Advertisement Register
+		/*
+		 * Two bits in the Auto Negotiation Advertisement Register
 		 * (Address 4) and two bits in the Auto Negotiation Base
 		 * Page Ability Register (Address 5) determine flow control
 		 * for both the PHY and the link partner.  The following
@@ -1045,8 +1080,8 @@ s32 e1000e_config_fc_after_link_up(struct e1000_hw *hw)
 		 *   1   |    1    |   0   |    0    | e1000_fc_none
 		 *   1   |    1    |   0   |    1    | e1000_fc_rx_pause
 		 *
-		 */
-		/* Are both PAUSE bits set to 1?  If so, this implies
+		 *
+		 * Are both PAUSE bits set to 1?  If so, this implies
 		 * Symmetric Flow Control is enabled at both ends.  The
 		 * ASM_DIR bits are irrelevant per the spec.
 		 *
@@ -1060,22 +1095,24 @@ s32 e1000e_config_fc_after_link_up(struct e1000_hw *hw)
 		 */
 		if ((mii_nway_adv_reg & NWAY_AR_PAUSE) &&
 		    (mii_nway_lp_ability_reg & NWAY_LPAR_PAUSE)) {
-			/* Now we need to check if the user selected RX ONLY
+			/*
+			 * Now we need to check if the user selected Rx ONLY
 			 * of pause frames.  In this case, we had to advertise
-			 * FULL flow control because we could not advertise RX
+			 * FULL flow control because we could not advertise Rx
 			 * ONLY. Hence, we must now check to see if we need to
 			 * turn OFF  the TRANSMISSION of PAUSE frames.
 			 */
-			if (mac->original_fc == e1000_fc_full) {
-				mac->fc = e1000_fc_full;
+			if (hw->fc.original_type == e1000_fc_full) {
+				hw->fc.type = e1000_fc_full;
 				hw_dbg(hw, "Flow Control = FULL.\r\n");
 			} else {
-				mac->fc = e1000_fc_rx_pause;
+				hw->fc.type = e1000_fc_rx_pause;
 				hw_dbg(hw, "Flow Control = "
 					 "RX PAUSE frames only.\r\n");
 			}
 		}
-		/* For receiving PAUSE frames ONLY.
+		/*
+		 * For receiving PAUSE frames ONLY.
 		 *
 		 *   LOCAL DEVICE  |   LINK PARTNER
 		 * PAUSE | ASM_DIR | PAUSE | ASM_DIR | Result
@@ -1087,10 +1124,11 @@ s32 e1000e_config_fc_after_link_up(struct e1000_hw *hw)
 			  (mii_nway_adv_reg & NWAY_AR_ASM_DIR) &&
 			  (mii_nway_lp_ability_reg & NWAY_LPAR_PAUSE) &&
 			  (mii_nway_lp_ability_reg & NWAY_LPAR_ASM_DIR)) {
-			mac->fc = e1000_fc_tx_pause;
-			hw_dbg(hw, "Flow Control = TX PAUSE frames only.\r\n");
+			hw->fc.type = e1000_fc_tx_pause;
+			hw_dbg(hw, "Flow Control = Tx PAUSE frames only.\r\n");
 		}
-		/* For transmitting PAUSE frames ONLY.
+		/*
+		 * For transmitting PAUSE frames ONLY.
 		 *
 		 *   LOCAL DEVICE  |   LINK PARTNER
 		 * PAUSE | ASM_DIR | PAUSE | ASM_DIR | Result
@@ -1102,18 +1140,19 @@ s32 e1000e_config_fc_after_link_up(struct e1000_hw *hw)
 			 (mii_nway_adv_reg & NWAY_AR_ASM_DIR) &&
 			 !(mii_nway_lp_ability_reg & NWAY_LPAR_PAUSE) &&
 			 (mii_nway_lp_ability_reg & NWAY_LPAR_ASM_DIR)) {
-			mac->fc = e1000_fc_rx_pause;
-			hw_dbg(hw, "Flow Control = RX PAUSE frames only.\r\n");
+			hw->fc.type = e1000_fc_rx_pause;
+			hw_dbg(hw, "Flow Control = Rx PAUSE frames only.\r\n");
 		} else {
 			/*
 			 * Per the IEEE spec, at this point flow control
 			 * should be disabled.
 			 */
-			mac->fc = e1000_fc_none;
+			hw->fc.type = e1000_fc_none;
 			hw_dbg(hw, "Flow Control = NONE.\r\n");
 		}
 
-		/* Now we need to do one last check...  If we auto-
+		/*
+		 * Now we need to do one last check...  If we auto-
 		 * negotiated to HALF DUPLEX, flow control should not be
 		 * enabled per IEEE 802.3 spec.
 		 */
@@ -1124,9 +1163,10 @@ s32 e1000e_config_fc_after_link_up(struct e1000_hw *hw)
 		}
 
 		if (duplex == HALF_DUPLEX)
-			mac->fc = e1000_fc_none;
+			hw->fc.type = e1000_fc_none;
 
-		/* Now we call a subroutine to actually force the MAC
+		/*
+		 * Now we call a subroutine to actually force the MAC
 		 * controller to use the correct flow control settings.
 		 */
 		ret_val = e1000e_force_mac_fc(hw);
@@ -1393,13 +1433,15 @@ s32 e1000e_blink_led(struct e1000_hw *hw)
 	u32 ledctl_blink = 0;
 	u32 i;
 
-	if (hw->media_type == e1000_media_type_fiber) {
+	if (hw->phy.media_type == e1000_media_type_fiber) {
 		/* always blink LED0 for PCI-E fiber */
 		ledctl_blink = E1000_LEDCTL_LED0_BLINK |
 		     (E1000_LEDCTL_MODE_LED_ON << E1000_LEDCTL_LED0_MODE_SHIFT);
 	} else {
-		/* set the blink bit for each LED that's "on" (0x0E)
-		 * in ledctl_mode2 */
+		/*
+		 * set the blink bit for each LED that's "on" (0x0E)
+		 * in ledctl_mode2
+		 */
 		ledctl_blink = hw->mac.ledctl_mode2;
 		for (i = 0; i < 4; i++)
 			if (((hw->mac.ledctl_mode2 >> (i * 8)) & 0xFF) ==
@@ -1423,7 +1465,7 @@ s32 e1000e_led_on_generic(struct e1000_hw *hw)
 {
 	u32 ctrl;
 
-	switch (hw->media_type) {
+	switch (hw->phy.media_type) {
 	case e1000_media_type_fiber:
 		ctrl = er32(CTRL);
 		ctrl &= ~E1000_CTRL_SWDPIN0;
@@ -1450,7 +1492,7 @@ s32 e1000e_led_off_generic(struct e1000_hw *hw)
 {
 	u32 ctrl;
 
-	switch (hw->media_type) {
+	switch (hw->phy.media_type) {
 	case e1000_media_type_fiber:
 		ctrl = er32(CTRL);
 		ctrl |= E1000_CTRL_SWDPIN0;
@@ -1562,8 +1604,7 @@ void e1000e_update_adaptive(struct e1000_hw *hw)
 				else
 					mac->current_ifs_val +=
 						mac->ifs_step_size;
-				ew32(AIT,
-						mac->current_ifs_val);
+				ew32(AIT, mac->current_ifs_val);
 			}
 		}
 	} else {
@@ -1826,10 +1867,12 @@ static s32 e1000_ready_nvm_eeprom(struct e1000_hw *hw)
 		udelay(1);
 		timeout = NVM_MAX_RETRY_SPI;
 
-		/* Read "Status Register" repeatedly until the LSB is cleared.
+		/*
+		 * Read "Status Register" repeatedly until the LSB is cleared.
 		 * The EEPROM will signal that the command has been completed
 		 * by clearing bit 0 of the internal status register.  If it's
-		 * not cleared within 'timeout', then error out. */
+		 * not cleared within 'timeout', then error out.
+		 */
 		while (timeout) {
 			e1000_shift_out_eec_bits(hw, NVM_RDSR_OPCODE_SPI,
 						 hw->nvm.opcode_bits);
@@ -1866,8 +1909,10 @@ s32 e1000e_read_nvm_eerd(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 	u32 i, eerd = 0;
 	s32 ret_val = 0;
 
-	/* A check for invalid values:  offset too large, too many words,
-	 * and not enough words. */
+	/*
+	 * A check for invalid values:  offset too large, too many words,
+	 * too many words for the offset, and not enough words.
+	 */
 	if ((offset >= nvm->word_size) || (words > (nvm->word_size - offset)) ||
 	    (words == 0)) {
 		hw_dbg(hw, "nvm parameter(s) out of bounds\n");
@@ -1883,8 +1928,7 @@ s32 e1000e_read_nvm_eerd(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 		if (ret_val)
 			break;
 
-		data[i] = (er32(EERD) >>
-			   E1000_NVM_RW_REG_DATA);
+		data[i] = (er32(EERD) >> E1000_NVM_RW_REG_DATA);
 	}
 
 	return ret_val;
@@ -1908,8 +1952,10 @@ s32 e1000e_write_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 	s32 ret_val;
 	u16 widx = 0;
 
-	/* A check for invalid values:  offset too large, too many words,
-	 * and not enough words. */
+	/*
+	 * A check for invalid values:  offset too large, too many words,
+	 * and not enough words.
+	 */
 	if ((offset >= nvm->word_size) || (words > (nvm->word_size - offset)) ||
 	    (words == 0)) {
 		hw_dbg(hw, "nvm parameter(s) out of bounds\n");
@@ -1939,8 +1985,10 @@ s32 e1000e_write_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 
 		e1000_standby_nvm(hw);
 
-		/* Some SPI eeproms use the 8th address bit embedded in the
-		 * opcode */
+		/*
+		 * Some SPI eeproms use the 8th address bit embedded in the
+		 * opcode
+		 */
 		if ((nvm->address_bits == 8) && (offset >= 128))
 			write_opcode |= NVM_A8_OPCODE_SPI;
 
@@ -1985,9 +2033,9 @@ s32 e1000e_read_mac_addr(struct e1000_hw *hw)
 		/* Check for an alternate MAC address.  An alternate MAC
 		 * address can be setup by pre-boot software and must be
 		 * treated like a permanent address and must override the
-		 * actual permanent MAC address. */
+		 * actual permanent MAC address.*/
 		ret_val = e1000_read_nvm(hw, NVM_ALT_MAC_ADDR_PTR, 1,
-						&mac_addr_offset);
+					 &mac_addr_offset);
 		if (ret_val) {
 			hw_dbg(hw, "NVM Read Error\n");
 			return ret_val;
@@ -2000,7 +2048,7 @@ s32 e1000e_read_mac_addr(struct e1000_hw *hw)
 				mac_addr_offset += ETH_ALEN/sizeof(u16);
 
 			/* make sure we have a valid mac address here
-			 * before using it */
+			* before using it */
 			ret_val = e1000_read_nvm(hw, mac_addr_offset, 1,
 						 &nvm_data);
 			if (ret_val) {
@@ -2012,7 +2060,7 @@ s32 e1000e_read_mac_addr(struct e1000_hw *hw)
 		}
 
 		if (mac_addr_offset)
-			hw->dev_spec.e82571.alt_mac_addr_is_present = 1;
+		hw->dev_spec.e82571.alt_mac_addr_is_present = 1;
 	}
 
 	for (i = 0; i < ETH_ALEN; i += 2) {
@@ -2188,7 +2236,7 @@ bool e1000e_check_mng_mode(struct e1000_hw *hw)
 }
 
 /**
- *  e1000e_enable_tx_pkt_filtering - Enable packet filtering on TX
+ *  e1000e_enable_tx_pkt_filtering - Enable packet filtering on Tx
  *  @hw: pointer to the HW structure
  *
  *  Enables packet filtering on transmit packets if manageability is enabled
@@ -2208,7 +2256,8 @@ bool e1000e_enable_tx_pkt_filtering(struct e1000_hw *hw)
 		return 0;
 	}
 
-	/* If we can't read from the host interface for whatever
+	/*
+	 * If we can't read from the host interface for whatever
 	 * reason, disable filtering.
 	 */
 	ret_val = e1000_mng_enable_host_if(hw);
@@ -2226,7 +2275,8 @@ bool e1000e_enable_tx_pkt_filtering(struct e1000_hw *hw)
 	hdr->checksum = 0;
 	csum = e1000_calculate_checksum((u8 *)hdr,
 					E1000_MNG_DHCP_COOKIE_LENGTH);
-	/* If either the checksums or signature don't match, then
+	/*
+	 * If either the checksums or signature don't match, then
 	 * the cookie area isn't considered valid, in which case we
 	 * take the safe route of assuming Tx filtering is enabled.
 	 */
@@ -2318,8 +2368,10 @@ static s32 e1000_mng_host_if_write(struct e1000_hw *hw, u8 *buffer,
 	/* Calculate length in DWORDs */
 	length >>= 2;
 
-	/* The device driver writes the relevant command block into the
-	 * ram area. */
+	/*
+	 * The device driver writes the relevant command block into the
+	 * ram area.
+	 */
 	for (i = 0; i < length; i++) {
 		for (j = 0; j < sizeof(u32); j++) {
 			*(tmp + j) = *bufptr++;
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index f501dd5..d70bde0 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2007 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -82,7 +82,7 @@ static int e1000_desc_unused(struct e1000_ring *ring)
 }
 
 /**
- * e1000_receive_skb - helper function to handle rx indications
+ * e1000_receive_skb - helper function to handle Rx indications
  * @adapter: board private structure
  * @status: descriptor status field as written by hardware
  * @vlan: descriptor vlan field as written by hardware (no le/be conversion)
@@ -138,8 +138,9 @@ static void e1000_rx_checksum(struct e1000_adapter *adapter, u32 status_err,
 		/* TCP checksum is good */
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 	} else {
-		/* IP fragment with UDP payload */
-		/* Hardware complements the payload checksum, so we undo it
+		/*
+		 * IP fragment with UDP payload
+		 * Hardware complements the payload checksum, so we undo it
 		 * and then put the value in host order for further stack use.
 		 */
 		__sum16 sum = (__force __sum16)htons(csum);
@@ -182,7 +183,8 @@ static void e1000_alloc_rx_buffers(struct e1000_adapter *adapter,
 			break;
 		}
 
-		/* Make buffer alignment 2 beyond a 16 byte boundary
+		/*
+		 * Make buffer alignment 2 beyond a 16 byte boundary
 		 * this will result in a 16 byte aligned IP header after
 		 * the 14 byte MAC header is removed
 		 */
@@ -213,10 +215,12 @@ map_skb:
 		if (i-- == 0)
 			i = (rx_ring->count - 1);
 
-		/* Force memory writes to complete before letting h/w
+		/*
+		 * Force memory writes to complete before letting h/w
 		 * know there are new descriptors to fetch.  (Only
 		 * applicable for weak-ordered memory model archs,
-		 * such as IA-64). */
+		 * such as IA-64).
+		 */
 		wmb();
 		writel(i, adapter->hw.hw_addr + rx_ring->tail);
 	}
@@ -285,7 +289,8 @@ static void e1000_alloc_rx_buffers_ps(struct e1000_adapter *adapter,
 			break;
 		}
 
-		/* Make buffer alignment 2 beyond a 16 byte boundary
+		/*
+		 * Make buffer alignment 2 beyond a 16 byte boundary
 		 * this will result in a 16 byte aligned IP header after
 		 * the 14 byte MAC header is removed
 		 */
@@ -319,12 +324,15 @@ no_buffers:
 		if (!(i--))
 			i = (rx_ring->count - 1);
 
-		/* Force memory writes to complete before letting h/w
+		/*
+		 * Force memory writes to complete before letting h/w
 		 * know there are new descriptors to fetch.  (Only
 		 * applicable for weak-ordered memory model archs,
-		 * such as IA-64). */
+		 * such as IA-64).
+		 */
 		wmb();
-		/* Hardware increments by 16 bytes, but packet split
+		/*
+		 * Hardware increments by 16 bytes, but packet split
 		 * descriptors are 32 bytes...so we increment tail
 		 * twice as much.
 		 */
@@ -409,9 +417,11 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 		total_rx_bytes += length;
 		total_rx_packets++;
 
-		/* code added for copybreak, this should improve
+		/*
+		 * code added for copybreak, this should improve
 		 * performance for small packets with large amounts
-		 * of reassembly being done in the stack */
+		 * of reassembly being done in the stack
+		 */
 		if (length < copybreak) {
 			struct sk_buff *new_skb =
 			    netdev_alloc_skb(netdev, length + NET_IP_ALIGN);
@@ -581,14 +591,15 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter)
 	}
 
 	if (adapter->detect_tx_hung) {
-		/* Detect a transmit hang in hardware, this serializes the
-		 * check with the clearing of time_stamp and movement of i */
+		/*
+		 * Detect a transmit hang in hardware, this serializes the
+		 * check with the clearing of time_stamp and movement of i
+		 */
 		adapter->detect_tx_hung = 0;
 		if (tx_ring->buffer_info[eop].dma &&
 		    time_after(jiffies, tx_ring->buffer_info[eop].time_stamp
 			       + (adapter->tx_timeout_factor * HZ))
-		    && !(er32(STATUS) &
-			 E1000_STATUS_TXOFF)) {
+		    && !(er32(STATUS) & E1000_STATUS_TXOFF)) {
 			e1000_print_tx_hang(adapter);
 			netif_stop_queue(netdev);
 		}
@@ -677,21 +688,28 @@ static bool e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
 		skb_put(skb, length);
 
 		{
-		/* this looks ugly, but it seems compiler issues make it
-		   more efficient than reusing j */
+		/*
+		 * this looks ugly, but it seems compiler issues make it
+		 * more efficient than reusing j
+		 */
 		int l1 = le16_to_cpu(rx_desc->wb.upper.length[0]);
 
-		/* page alloc/put takes too long and effects small packet
-		 * throughput, so unsplit small packets and save the alloc/put*/
+		/*
+		 * page alloc/put takes too long and effects small packet
+		 * throughput, so unsplit small packets and save the alloc/put
+		 * only valid in softirq (napi) context to call kmap_*
+		 */
 		if (l1 && (l1 <= copybreak) &&
 		    ((length + l1) <= adapter->rx_ps_bsize0)) {
 			u8 *vaddr;
 
 			ps_page = &buffer_info->ps_pages[0];
 
-			/* there is no documentation about how to call
+			/*
+			 * there is no documentation about how to call
 			 * kmap_atomic, so we can't hold the mapping
-			 * very long */
+			 * very long
+			 */
 			pci_dma_sync_single_for_cpu(pdev, ps_page->dma,
 				PAGE_SIZE, PCI_DMA_FROMDEVICE);
 			vaddr = kmap_atomic(ps_page->page, KM_SKB_DATA_SOFTIRQ);
@@ -836,24 +854,31 @@ static irqreturn_t e1000_intr_msi(int irq, void *data)
 	struct e1000_hw *hw = &adapter->hw;
 	u32 icr = er32(ICR);
 
-	/* read ICR disables interrupts using IAM */
+	/*
+	 * read ICR disables interrupts using IAM
+	 */
 
 	if (icr & (E1000_ICR_RXSEQ | E1000_ICR_LSC)) {
 		hw->mac.get_link_status = 1;
-		/* ICH8 workaround-- Call gig speed drop workaround on cable
-		 * disconnect (LSC) before accessing any PHY registers */
+		/*
+		 * ICH8 workaround-- Call gig speed drop workaround on cable
+		 * disconnect (LSC) before accessing any PHY registers
+		 */
 		if ((adapter->flags & FLAG_LSC_GIG_SPEED_DROP) &&
 		    (!(er32(STATUS) & E1000_STATUS_LU)))
 			e1000e_gig_downshift_workaround_ich8lan(hw);
 
-		/* 80003ES2LAN workaround-- For packet buffer work-around on
+		/*
+		 * 80003ES2LAN workaround-- For packet buffer work-around on
 		 * link down event; disable receives here in the ISR and reset
-		 * adapter in watchdog */
+		 * adapter in watchdog
+		 */
 		if (netif_carrier_ok(netdev) &&
 		    adapter->flags & FLAG_RX_NEEDS_RESTART) {
 			/* disable receives */
 			u32 rctl = er32(RCTL);
 			ew32(RCTL, rctl & ~E1000_RCTL_EN);
+			adapter->flags |= FLAG_RX_RESTART_NOW;
 		}
 		/* guard against interrupt when we're going down */
 		if (!test_bit(__E1000_DOWN, &adapter->state))
@@ -886,23 +911,31 @@ static irqreturn_t e1000_intr(int irq, void *data)
 	if (!icr)
 		return IRQ_NONE;  /* Not our interrupt */
 
-	/* IMS will not auto-mask if INT_ASSERTED is not set, and if it is
-	 * not set, then the adapter didn't send an interrupt */
+	/*
+	 * IMS will not auto-mask if INT_ASSERTED is not set, and if it is
+	 * not set, then the adapter didn't send an interrupt
+	 */
 	if (!(icr & E1000_ICR_INT_ASSERTED))
 		return IRQ_NONE;
 
-	/* Interrupt Auto-Mask...upon reading ICR, interrupts are masked.  No
-	 * need for the IMC write */
+	/*
+	 * Interrupt Auto-Mask...upon reading ICR,
+	 * interrupts are masked.  No need for the
+	 * IMC write
+	 */
 
 	if (icr & (E1000_ICR_RXSEQ | E1000_ICR_LSC)) {
 		hw->mac.get_link_status = 1;
-		/* ICH8 workaround-- Call gig speed drop workaround on cable
-		 * disconnect (LSC) before accessing any PHY registers */
+		/*
+		 * ICH8 workaround-- Call gig speed drop workaround on cable
+		 * disconnect (LSC) before accessing any PHY registers
+		 */
 		if ((adapter->flags & FLAG_LSC_GIG_SPEED_DROP) &&
 		    (!(er32(STATUS) & E1000_STATUS_LU)))
 			e1000e_gig_downshift_workaround_ich8lan(hw);
 
-		/* 80003ES2LAN workaround--
+		/*
+		 * 80003ES2LAN workaround--
 		 * For packet buffer work-around on link down event;
 		 * disable receives here in the ISR and
 		 * reset adapter in watchdog
@@ -912,6 +945,7 @@ static irqreturn_t e1000_intr(int irq, void *data)
 			/* disable receives */
 			rctl = er32(RCTL);
 			ew32(RCTL, rctl & ~E1000_RCTL_EN);
+			adapter->flags |= FLAG_RX_RESTART_NOW;
 		}
 		/* guard against interrupt when we're going down */
 		if (!test_bit(__E1000_DOWN, &adapter->state))
@@ -1011,8 +1045,7 @@ static void e1000_get_hw_control(struct e1000_adapter *adapter)
 		ew32(SWSM, swsm | E1000_SWSM_DRV_LOAD);
 	} else if (adapter->flags & FLAG_HAS_CTRLEXT_ON_LOAD) {
 		ctrl_ext = er32(CTRL_EXT);
-		ew32(CTRL_EXT,
-				ctrl_ext | E1000_CTRL_EXT_DRV_LOAD);
+		ew32(CTRL_EXT, ctrl_ext | E1000_CTRL_EXT_DRV_LOAD);
 	}
 }
 
@@ -1038,8 +1071,7 @@ static void e1000_release_hw_control(struct e1000_adapter *adapter)
 		ew32(SWSM, swsm & ~E1000_SWSM_DRV_LOAD);
 	} else if (adapter->flags & FLAG_HAS_CTRLEXT_ON_LOAD) {
 		ctrl_ext = er32(CTRL_EXT);
-		ew32(CTRL_EXT,
-				ctrl_ext & ~E1000_CTRL_EXT_DRV_LOAD);
+		ew32(CTRL_EXT, ctrl_ext & ~E1000_CTRL_EXT_DRV_LOAD);
 	}
 }
 
@@ -1341,9 +1373,11 @@ static void e1000_set_itr(struct e1000_adapter *adapter)
 
 set_itr_now:
 	if (new_itr != adapter->itr) {
-		/* this attempts to bias the interrupt rate towards Bulk
+		/*
+		 * this attempts to bias the interrupt rate towards Bulk
 		 * by adding intermediate steps when interrupt rate is
-		 * increasing */
+		 * increasing
+		 */
 		new_itr = new_itr > adapter->itr ?
 			     min(adapter->itr + (new_itr >> 2), new_itr) :
 			     new_itr;
@@ -1354,7 +1388,7 @@ set_itr_now:
 
 /**
  * e1000_clean - NAPI Rx polling callback
- * @adapter: board private structure
+ * @napi: struct associated with this polling callback
  * @budget: amount of packets driver is allowed to process this poll
  **/
 static int e1000_clean(struct napi_struct *napi, int budget)
@@ -1366,10 +1400,12 @@ static int e1000_clean(struct napi_struct *napi, int budget)
 	/* Must NOT use netdev_priv macro here. */
 	adapter = poll_dev->priv;
 
-	/* e1000_clean is called per-cpu.  This lock protects
+	/*
+	 * e1000_clean is called per-cpu.  This lock protects
 	 * tx_ring from being cleaned by multiple cpus
 	 * simultaneously.  A failure obtaining the lock means
-	 * tx_ring is currently being cleaned anyway. */
+	 * tx_ring is currently being cleaned anyway.
+	 */
 	if (spin_trylock(&adapter->tx_queue_lock)) {
 		tx_cleaned = e1000_clean_tx_irq(adapter);
 		spin_unlock(&adapter->tx_queue_lock);
@@ -1539,9 +1575,11 @@ static void e1000_init_manageability(struct e1000_adapter *adapter)
 
 	manc = er32(MANC);
 
-	/* enable receiving management packets to the host. this will probably
+	/*
+	 * enable receiving management packets to the host. this will probably
 	 * generate destination unreachable messages from the host OS, but
-	 * the packets will be handled on SMBUS */
+	 * the packets will be handled on SMBUS
+	 */
 	manc |= E1000_MANC_EN_MNG2HOST;
 	manc2h = er32(MANC2H);
 #define E1000_MNG2HOST_PORT_623 (1 << 5)
@@ -1591,7 +1629,7 @@ static void e1000_configure_tx(struct e1000_adapter *adapter)
 
 	/* Set the Tx Interrupt Delay register */
 	ew32(TIDV, adapter->tx_int_delay);
-	/* tx irq moderation */
+	/* Tx irq moderation */
 	ew32(TADV, adapter->tx_abs_int_delay);
 
 	/* Program the Transmit Control Register */
@@ -1602,8 +1640,10 @@ static void e1000_configure_tx(struct e1000_adapter *adapter)
 
 	if (adapter->flags & FLAG_TARC_SPEED_MODE_BIT) {
 		tarc = er32(TARC0);
-		/* set the speed mode bit, we'll clear it if we're not at
-		 * gigabit link later */
+		/*
+		 * set the speed mode bit, we'll clear it if we're not at
+		 * gigabit link later
+		 */
 #define SPEED_MODE_BIT (1 << 21)
 		tarc |= SPEED_MODE_BIT;
 		ew32(TARC0, tarc);
@@ -1724,8 +1764,10 @@ static void e1000_setup_rctl(struct e1000_adapter *adapter)
 		/* Configure extra packet-split registers */
 		rfctl = er32(RFCTL);
 		rfctl |= E1000_RFCTL_EXTEN;
-		/* disable packet split support for IPv6 extension headers,
-		 * because some malformed IPv6 headers can hang the RX */
+		/*
+		 * disable packet split support for IPv6 extension headers,
+		 * because some malformed IPv6 headers can hang the Rx
+		 */
 		rfctl |= (E1000_RFCTL_IPV6_EX_DIS |
 			  E1000_RFCTL_NEW_IPV6_EXT_DIS);
 
@@ -1754,6 +1796,8 @@ static void e1000_setup_rctl(struct e1000_adapter *adapter)
 	}
 
 	ew32(RCTL, rctl);
+	/* just started the receive unit, no need to restart */
+	adapter->flags &= ~FLAG_RX_RESTART_NOW;
 }
 
 /**
@@ -1794,8 +1838,7 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
 	/* irq moderation */
 	ew32(RADV, adapter->rx_abs_int_delay);
 	if (adapter->itr_setting != 0)
-		ew32(ITR,
-			1000000000 / (adapter->itr * 256));
+		ew32(ITR, 1000000000 / (adapter->itr * 256));
 
 	ctrl_ext = er32(CTRL_EXT);
 	/* Reset delay timers after every interrupt */
@@ -1806,8 +1849,10 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
 	ew32(CTRL_EXT, ctrl_ext);
 	e1e_flush();
 
-	/* Setup the HW Rx Head and Tail Descriptor Pointers and
-	 * the Base and Length of the Rx Descriptor Ring */
+	/*
+	 * Setup the HW Rx Head and Tail Descriptor Pointers and
+	 * the Base and Length of the Rx Descriptor Ring
+	 */
 	rdba = rx_ring->dma;
 	ew32(RDBAL, (rdba & DMA_32BIT_MASK));
 	ew32(RDBAH, (rdba >> 32));
@@ -1822,8 +1867,10 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
 	if (adapter->flags & FLAG_RX_CSUM_ENABLED) {
 		rxcsum |= E1000_RXCSUM_TUOFL;
 
-		/* IPv4 payload checksum for UDP fragments must be
-		 * used in conjunction with packet-split. */
+		/*
+		 * IPv4 payload checksum for UDP fragments must be
+		 * used in conjunction with packet-split.
+		 */
 		if (adapter->rx_ps_pages)
 			rxcsum |= E1000_RXCSUM_IPPCSE;
 	} else {
@@ -1832,9 +1879,11 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
 	}
 	ew32(RXCSUM, rxcsum);
 
-	/* Enable early receives on supported devices, only takes effect when
+	/*
+	 * Enable early receives on supported devices, only takes effect when
 	 * packet size is equal or larger than the specified value (in 8 byte
-	 * units), e.g. using jumbo frames when setting to E1000_ERT_2048 */
+	 * units), e.g. using jumbo frames when setting to E1000_ERT_2048
+	 */
 	if ((adapter->flags & FLAG_HAS_ERT) &&
 	    (adapter->netdev->mtu > ETH_DATA_LEN))
 		ew32(ERT, E1000_ERT_2048);
@@ -1844,7 +1893,7 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
 }
 
 /**
- *  e1000_mc_addr_list_update - Update Multicast addresses
+ *  e1000_update_mc_addr_list - Update Multicast addresses
  *  @hw: pointer to the HW structure
  *  @mc_addr_list: array of multicast addresses to program
  *  @mc_addr_count: number of multicast addresses to program
@@ -1858,11 +1907,11 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
  *  exists and all implementations are handled in the generic version of this
  *  function.
  **/
-static void e1000_mc_addr_list_update(struct e1000_hw *hw, u8 *mc_addr_list,
-			       u32 mc_addr_count, u32 rar_used_count,
-			       u32 rar_count)
+static void e1000_update_mc_addr_list(struct e1000_hw *hw, u8 *mc_addr_list,
+				      u32 mc_addr_count, u32 rar_used_count,
+				      u32 rar_count)
 {
-	hw->mac.ops.mc_addr_list_update(hw, mc_addr_list, mc_addr_count,
+	hw->mac.ops.update_mc_addr_list(hw, mc_addr_list, mc_addr_count,
 				        rar_used_count, rar_count);
 }
 
@@ -1916,7 +1965,7 @@ static void e1000_set_multi(struct net_device *netdev)
 			mc_ptr = mc_ptr->next;
 		}
 
-		e1000_mc_addr_list_update(hw, mta_list, i, 1,
+		e1000_update_mc_addr_list(hw, mta_list, i, 1,
 					  mac->rar_entry_count);
 		kfree(mta_list);
 	} else {
@@ -1924,13 +1973,12 @@ static void e1000_set_multi(struct net_device *netdev)
 		 * if we're called from probe, we might not have
 		 * anything to do here, so clear out the list
 		 */
-		e1000_mc_addr_list_update(hw, NULL, 0, 1,
-					  mac->rar_entry_count);
+		e1000_update_mc_addr_list(hw, NULL, 0, 1, mac->rar_entry_count);
 	}
 }
 
 /**
- * e1000_configure - configure the hardware for RX and TX
+ * e1000_configure - configure the hardware for Rx and Tx
  * @adapter: private board structure
  **/
 static void e1000_configure(struct e1000_adapter *adapter)
@@ -1943,8 +1991,7 @@ static void e1000_configure(struct e1000_adapter *adapter)
 	e1000_configure_tx(adapter);
 	e1000_setup_rctl(adapter);
 	e1000_configure_rx(adapter);
-	adapter->alloc_rx_buf(adapter,
-			      e1000_desc_unused(adapter->rx_ring));
+	adapter->alloc_rx_buf(adapter, e1000_desc_unused(adapter->rx_ring));
 }
 
 /**
@@ -1960,9 +2007,11 @@ void e1000e_power_up_phy(struct e1000_adapter *adapter)
 	u16 mii_reg = 0;
 
 	/* Just clear the power down bit to wake the phy back up */
-	if (adapter->hw.media_type == e1000_media_type_copper) {
-		/* according to the manual, the phy will retain its
-		 * settings across a power-down/up cycle */
+	if (adapter->hw.phy.media_type == e1000_media_type_copper) {
+		/*
+		 * According to the manual, the phy will retain its
+		 * settings across a power-down/up cycle
+		 */
 		e1e_rphy(&adapter->hw, PHY_CONTROL, &mii_reg);
 		mii_reg &= ~MII_CR_POWER_DOWN;
 		e1e_wphy(&adapter->hw, PHY_CONTROL, mii_reg);
@@ -1987,12 +2036,11 @@ static void e1000_power_down_phy(struct e1000_adapter *adapter)
 		return;
 
 	/* non-copper PHY? */
-	if (adapter->hw.media_type != e1000_media_type_copper)
+	if (adapter->hw.phy.media_type != e1000_media_type_copper)
 		return;
 
 	/* reset is blocked because of a SoL/IDER session */
-	if (e1000e_check_mng_mode(hw) ||
-	    e1000_check_reset_block(hw))
+	if (e1000e_check_mng_mode(hw) || e1000_check_reset_block(hw))
 		return;
 
 	/* manageability (AMT) is enabled */
@@ -2012,51 +2060,61 @@ static void e1000_power_down_phy(struct e1000_adapter *adapter)
  * This function boots the hardware and enables some settings that
  * require a configuration cycle of the hardware - those cannot be
  * set/changed during runtime. After reset the device needs to be
- * properly configured for rx, tx etc.
+ * properly configured for Rx, Tx etc.
  */
 void e1000e_reset(struct e1000_adapter *adapter)
 {
 	struct e1000_mac_info *mac = &adapter->hw.mac;
+	struct e1000_fc_info *fc = &adapter->hw.fc;
 	struct e1000_hw *hw = &adapter->hw;
 	u32 tx_space, min_tx_space, min_rx_space;
-	u32 pba;
+	u32 pba = adapter->pba;
 	u16 hwm;
 
-	ew32(PBA, adapter->pba);
+	/* reset Packet Buffer Allocation to default */
+	ew32(PBA, pba);
 
-	if (mac->max_frame_size > ETH_FRAME_LEN + ETH_FCS_LEN ) {
-		/* To maintain wire speed transmits, the Tx FIFO should be
+	if (adapter->max_frame_size > ETH_FRAME_LEN + ETH_FCS_LEN) {
+		/*
+		 * To maintain wire speed transmits, the Tx FIFO should be
 		 * large enough to accommodate two full transmit packets,
 		 * rounded up to the next 1KB and expressed in KB.  Likewise,
 		 * the Rx FIFO should be large enough to accommodate at least
 		 * one full receive packet and is similarly rounded up and
-		 * expressed in KB. */
+		 * expressed in KB.
+		 */
 		pba = er32(PBA);
 		/* upper 16 bits has Tx packet buffer allocation size in KB */
 		tx_space = pba >> 16;
 		/* lower 16 bits has Rx packet buffer allocation size in KB */
 		pba &= 0xffff;
-		/* the tx fifo also stores 16 bytes of information about the tx
-		 * but don't include ethernet FCS because hardware appends it */
-		min_tx_space = (mac->max_frame_size +
+		/*
+		 * the Tx fifo also stores 16 bytes of information about the tx
+		 * but don't include ethernet FCS because hardware appends it
+		 */
+		min_tx_space = (adapter->max_frame_size +
 				sizeof(struct e1000_tx_desc) -
 				ETH_FCS_LEN) * 2;
 		min_tx_space = ALIGN(min_tx_space, 1024);
 		min_tx_space >>= 10;
 		/* software strips receive CRC, so leave room for it */
-		min_rx_space = mac->max_frame_size;
+		min_rx_space = adapter->max_frame_size;
 		min_rx_space = ALIGN(min_rx_space, 1024);
 		min_rx_space >>= 10;
 
-		/* If current Tx allocation is less than the min Tx FIFO size,
+		/*
+		 * If current Tx allocation is less than the min Tx FIFO size,
 		 * and the min Tx FIFO size is less than the current Rx FIFO
-		 * allocation, take space away from current Rx allocation */
+		 * allocation, take space away from current Rx allocation
+		 */
 		if ((tx_space < min_tx_space) &&
 		    ((min_tx_space - tx_space) < pba)) {
 			pba -= min_tx_space - tx_space;
 
-			/* if short on rx space, rx wins and must trump tx
-			 * adjustment or use Early Receive if available */
+			/*
+			 * if short on Rx space, Rx wins and must trump tx
+			 * adjustment or use Early Receive if available
+			 */
 			if ((pba < min_rx_space) &&
 			    (!(adapter->flags & FLAG_HAS_ERT)))
 				/* ERT enabled in e1000_configure_rx */
@@ -2067,29 +2125,33 @@ void e1000e_reset(struct e1000_adapter *adapter)
 	}
 
 
-	/* flow control settings */
-	/* The high water mark must be low enough to fit one full frame
+	/*
+	 * flow control settings
+	 *
+	 * The high water mark must be low enough to fit one full frame
 	 * (or the size used for early receive) above it in the Rx FIFO.
 	 * Set it to the lower of:
 	 * - 90% of the Rx FIFO size, and
 	 * - the full Rx FIFO size minus the early receive size (for parts
 	 *   with ERT support assuming ERT set to E1000_ERT_2048), or
-	 * - the full Rx FIFO size minus one full frame */
+	 * - the full Rx FIFO size minus one full frame
+	 */
 	if (adapter->flags & FLAG_HAS_ERT)
-		hwm = min(((adapter->pba << 10) * 9 / 10),
-			  ((adapter->pba << 10) - (E1000_ERT_2048 << 3)));
+		hwm = min(((pba << 10) * 9 / 10),
+			  ((pba << 10) - (E1000_ERT_2048 << 3)));
 	else
-		hwm = min(((adapter->pba << 10) * 9 / 10),
-			  ((adapter->pba << 10) - mac->max_frame_size));
+		hwm = min(((pba << 10) * 9 / 10),
+			  ((pba << 10) - adapter->max_frame_size));
 
-	mac->fc_high_water = hwm & 0xFFF8; /* 8-byte granularity */
-	mac->fc_low_water = mac->fc_high_water - 8;
+	fc->high_water = hwm & 0xFFF8; /* 8-byte granularity */
+	fc->low_water = fc->high_water - 8;
 
 	if (adapter->flags & FLAG_DISABLE_FC_PAUSE_TIME)
-		mac->fc_pause_time = 0xFFFF;
+		fc->pause_time = 0xFFFF;
 	else
-		mac->fc_pause_time = E1000_FC_PAUSE_TIME;
-	mac->fc = mac->original_fc;
+		fc->pause_time = E1000_FC_PAUSE_TIME;
+	fc->send_xon = 1;
+	fc->type = fc->original_type;
 
 	/* Allow time for pending master requests to run */
 	mac->ops.reset_hw(hw);
@@ -2108,9 +2170,11 @@ void e1000e_reset(struct e1000_adapter *adapter)
 
 	if (!(adapter->flags & FLAG_SMART_POWER_DOWN)) {
 		u16 phy_data = 0;
-		/* speed up time to link by disabling smart power down, ignore
+		/*
+		 * speed up time to link by disabling smart power down, ignore
 		 * the return value of this function because there is nothing
-		 * different we would do if it failed */
+		 * different we would do if it failed
+		 */
 		e1e_rphy(hw, IGP02E1000_PHY_POWER_MGMT, &phy_data);
 		phy_data &= ~IGP02E1000_PM_SPD;
 		e1e_wphy(hw, IGP02E1000_PHY_POWER_MGMT, phy_data);
@@ -2140,8 +2204,10 @@ void e1000e_down(struct e1000_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 	u32 tctl, rctl;
 
-	/* signal that we're down so the interrupt handler does not
-	 * reschedule our watchdog timer */
+	/*
+	 * signal that we're down so the interrupt handler does not
+	 * reschedule our watchdog timer
+	 */
 	set_bit(__E1000_DOWN, &adapter->state);
 
 	/* disable receives in the hardware */
@@ -2200,13 +2266,12 @@ void e1000e_reinit_locked(struct e1000_adapter *adapter)
  **/
 static int __devinit e1000_sw_init(struct e1000_adapter *adapter)
 {
-	struct e1000_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
 
 	adapter->rx_buffer_len = ETH_FRAME_LEN + VLAN_HLEN + ETH_FCS_LEN;
 	adapter->rx_ps_bsize0 = 128;
-	hw->mac.max_frame_size = netdev->mtu + ETH_HLEN + ETH_FCS_LEN;
-	hw->mac.min_frame_size = ETH_ZLEN + ETH_FCS_LEN;
+	adapter->max_frame_size = netdev->mtu + ETH_HLEN + ETH_FCS_LEN;
+	adapter->min_frame_size = ETH_ZLEN + ETH_FCS_LEN;
 
 	adapter->tx_ring = kzalloc(sizeof(struct e1000_ring), GFP_KERNEL);
 	if (!adapter->tx_ring)
@@ -2272,16 +2337,20 @@ static int e1000_open(struct net_device *netdev)
 	     E1000_MNG_DHCP_COOKIE_STATUS_VLAN))
 		e1000_update_mng_vlan(adapter);
 
-	/* If AMT is enabled, let the firmware know that the network
-	 * interface is now open */
+	/*
+	 * If AMT is enabled, let the firmware know that the network
+	 * interface is now open
+	 */
 	if ((adapter->flags & FLAG_HAS_AMT) &&
 	    e1000e_check_mng_mode(&adapter->hw))
 		e1000_get_hw_control(adapter);
 
-	/* before we allocate an interrupt, we must be ready to handle it.
+	/*
+	 * before we allocate an interrupt, we must be ready to handle it.
 	 * Setting DEBUG_SHIRQ in the kernel makes it fire an interrupt
 	 * as soon as we call pci_request_irq, so we have to setup our
-	 * clean_rx handler before we do so.  */
+	 * clean_rx handler before we do so.
+	 */
 	e1000_configure(adapter);
 
 	err = e1000_request_irq(adapter);
@@ -2335,16 +2404,20 @@ static int e1000_close(struct net_device *netdev)
 	e1000e_free_tx_resources(adapter);
 	e1000e_free_rx_resources(adapter);
 
-	/* kill manageability vlan ID if supported, but not if a vlan with
-	 * the same ID is registered on the host OS (let 8021q kill it) */
+	/*
+	 * kill manageability vlan ID if supported, but not if a vlan with
+	 * the same ID is registered on the host OS (let 8021q kill it)
+	 */
 	if ((adapter->hw.mng_cookie.status &
 			  E1000_MNG_DHCP_COOKIE_STATUS_VLAN) &&
 	     !(adapter->vlgrp &&
 	       vlan_group_get_device(adapter->vlgrp, adapter->mng_vlan_id)))
 		e1000_vlan_rx_kill_vid(netdev, adapter->mng_vlan_id);
 
-	/* If AMT is enabled, let the firmware know that the network
-	 * interface is now closed */
+	/*
+	 * If AMT is enabled, let the firmware know that the network
+	 * interface is now closed
+	 */
 	if ((adapter->flags & FLAG_HAS_AMT) &&
 	    e1000e_check_mng_mode(&adapter->hw))
 		e1000_release_hw_control(adapter);
@@ -2375,12 +2448,14 @@ static int e1000_set_mac(struct net_device *netdev, void *p)
 		/* activate the work around */
 		e1000e_set_laa_state_82571(&adapter->hw, 1);
 
-		/* Hold a copy of the LAA in RAR[14] This is done so that
+		/*
+		 * Hold a copy of the LAA in RAR[14] This is done so that
 		 * between the time RAR[0] gets clobbered  and the time it
 		 * gets fixed (in e1000_watchdog), the actual LAA is in one
 		 * of the RARs and no incoming packets directed to this port
 		 * are dropped. Eventually the LAA will be in RAR[0] and
-		 * RAR[14] */
+		 * RAR[14]
+		 */
 		e1000e_rar_set(&adapter->hw,
 			      adapter->hw.mac.addr,
 			      adapter->hw.mac.rar_entry_count - 1);
@@ -2389,8 +2464,10 @@ static int e1000_set_mac(struct net_device *netdev, void *p)
 	return 0;
 }
 
-/* Need to wait a few seconds after link up to get diagnostic information from
- * the phy */
+/*
+ * Need to wait a few seconds after link up to get diagnostic information from
+ * the phy
+ */
 static void e1000_update_phy_info(unsigned long data)
 {
 	struct e1000_adapter *adapter = (struct e1000_adapter *) data;
@@ -2421,7 +2498,8 @@ void e1000e_update_stats(struct e1000_adapter *adapter)
 
 	spin_lock_irqsave(&adapter->stats_lock, irq_flags);
 
-	/* these counters are modified from e1000_adjust_tbi_stats,
+	/*
+	 * these counters are modified from e1000_adjust_tbi_stats,
 	 * called from the interrupt context, so they must only
 	 * be written while holding adapter->stats_lock
 	 */
@@ -2515,8 +2593,10 @@ void e1000e_update_stats(struct e1000_adapter *adapter)
 
 	/* Rx Errors */
 
-	/* RLEC on some newer hardware can be incorrect so build
-	* our own version based on RUC and ROC */
+	/*
+	 * RLEC on some newer hardware can be incorrect so build
+	 * our own version based on RUC and ROC
+	 */
 	adapter->net_stats.rx_errors = adapter->stats.rxerrc +
 		adapter->stats.crcerrs + adapter->stats.algnerrc +
 		adapter->stats.ruc + adapter->stats.roc +
@@ -2537,7 +2617,7 @@ void e1000e_update_stats(struct e1000_adapter *adapter)
 	/* Tx Dropped needs to be maintained elsewhere */
 
 	/* Phy Stats */
-	if (hw->media_type == e1000_media_type_copper) {
+	if (hw->phy.media_type == e1000_media_type_copper) {
 		if ((adapter->link_speed == SPEED_1000) &&
 		   (!e1e_rphy(hw, PHY_1000T_STATUS, &phy_tmp))) {
 			phy_tmp &= PHY_IDLE_ERROR_COUNT_MASK;
@@ -2555,8 +2635,8 @@ void e1000e_update_stats(struct e1000_adapter *adapter)
 
 static void e1000_print_link_info(struct e1000_adapter *adapter)
 {
-	struct net_device *netdev = adapter->netdev;
 	struct e1000_hw *hw = &adapter->hw;
+	struct net_device *netdev = adapter->netdev;
 	u32 ctrl = er32(CTRL);
 
 	ndev_info(netdev,
@@ -2570,6 +2650,62 @@ static void e1000_print_link_info(struct e1000_adapter *adapter)
 		((ctrl & E1000_CTRL_TFCE) ? "TX" : "None" )));
 }
 
+static bool e1000_has_link(struct e1000_adapter *adapter)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	bool link_active = 0;
+	s32 ret_val = 0;
+
+	/*
+	 * get_link_status is set on LSC (link status) interrupt or
+	 * Rx sequence error interrupt.  get_link_status will stay
+	 * false until the check_for_link establishes link
+	 * for copper adapters ONLY
+	 */
+	switch (hw->phy.media_type) {
+	case e1000_media_type_copper:
+		if (hw->mac.get_link_status) {
+			ret_val = hw->mac.ops.check_for_link(hw);
+			link_active = !hw->mac.get_link_status;
+		} else {
+			link_active = 1;
+		}
+		break;
+	case e1000_media_type_fiber:
+		ret_val = hw->mac.ops.check_for_link(hw);
+		link_active = !!(er32(STATUS) & E1000_STATUS_LU);
+		break;
+	case e1000_media_type_internal_serdes:
+		ret_val = hw->mac.ops.check_for_link(hw);
+		link_active = adapter->hw.mac.serdes_has_link;
+		break;
+	default:
+	case e1000_media_type_unknown:
+		break;
+	}
+
+	if ((ret_val == E1000_ERR_PHY) && (hw->phy.type == e1000_phy_igp_3) &&
+	    (er32(CTRL) & E1000_PHY_CTRL_GBE_DISABLE)) {
+		/* See e1000_kmrn_lock_loss_workaround_ich8lan() */
+		ndev_info(adapter->netdev,
+			  "Gigabit has been disabled, downgrading speed\n");
+	}
+
+	return link_active;
+}
+
+static void e1000e_enable_receives(struct e1000_adapter *adapter)
+{
+	/* make sure the receive unit is started */
+	if ((adapter->flags & FLAG_RX_NEEDS_RESTART) &&
+	    (adapter->flags & FLAG_RX_RESTART_NOW)) {
+		struct e1000_hw *hw = &adapter->hw;
+		u32 rctl = er32(RCTL);
+		ew32(RCTL, rctl | E1000_RCTL_EN);
+		adapter->flags &= ~FLAG_RX_RESTART_NOW;
+	}
+}
+
 /**
  * e1000_watchdog - Timer Call-back
  * @data: pointer to adapter cast into an unsigned long
@@ -2588,48 +2724,35 @@ static void e1000_watchdog_task(struct work_struct *work)
 {
 	struct e1000_adapter *adapter = container_of(work,
 					struct e1000_adapter, watchdog_task);
-
 	struct net_device *netdev = adapter->netdev;
 	struct e1000_mac_info *mac = &adapter->hw.mac;
 	struct e1000_ring *tx_ring = adapter->tx_ring;
 	struct e1000_hw *hw = &adapter->hw;
 	u32 link, tctl;
-	s32 ret_val;
 	int tx_pending = 0;
 
-	if ((netif_carrier_ok(netdev)) &&
-	    (er32(STATUS) & E1000_STATUS_LU))
+	link = e1000_has_link(adapter);
+	if ((netif_carrier_ok(netdev)) && link) {
+		e1000e_enable_receives(adapter);
 		goto link_up;
-
-	ret_val = mac->ops.check_for_link(hw);
-	if ((ret_val == E1000_ERR_PHY) &&
-	    (adapter->hw.phy.type == e1000_phy_igp_3) &&
-	    (er32(CTRL) &
-	     E1000_PHY_CTRL_GBE_DISABLE)) {
-		/* See e1000_kmrn_lock_loss_workaround_ich8lan() */
-		ndev_info(netdev,
-			"Gigabit has been disabled, downgrading speed\n");
 	}
 
 	if ((e1000e_enable_tx_pkt_filtering(hw)) &&
 	    (adapter->mng_vlan_id != adapter->hw.mng_cookie.vlan_id))
 		e1000_update_mng_vlan(adapter);
 
-	if ((adapter->hw.media_type == e1000_media_type_internal_serdes) &&
-	   !(er32(TXCW) & E1000_TXCW_ANE))
-		link = adapter->hw.mac.serdes_has_link;
-	else
-		link = er32(STATUS) & E1000_STATUS_LU;
-
 	if (link) {
 		if (!netif_carrier_ok(netdev)) {
 			bool txb2b = 1;
+			/* update snapshot of PHY registers on LSC */
 			mac->ops.get_link_up_info(&adapter->hw,
 						   &adapter->link_speed,
 						   &adapter->link_duplex);
 			e1000_print_link_info(adapter);
-			/* tweak tx_queue_len according to speed/duplex
-			 * and adjust the timeout factor */
+			/*
+			 * tweak tx_queue_len according to speed/duplex
+			 * and adjust the timeout factor
+			 */
 			netdev->tx_queue_len = adapter->tx_queue_len;
 			adapter->tx_timeout_factor = 1;
 			switch (adapter->link_speed) {
@@ -2645,8 +2768,10 @@ static void e1000_watchdog_task(struct work_struct *work)
 				break;
 			}
 
-			/* workaround: re-program speed mode bit after
-			 * link-up event */
+			/*
+			 * workaround: re-program speed mode bit after
+			 * link-up event
+			 */
 			if ((adapter->flags & FLAG_TARC_SPEED_MODE_BIT) &&
 			    !txb2b) {
 				u32 tarc0;
@@ -2655,8 +2780,10 @@ static void e1000_watchdog_task(struct work_struct *work)
 				ew32(TARC0, tarc0);
 			}
 
-			/* disable TSO for pcie and 10/100 speeds, to avoid
-			 * some hardware issues */
+			/*
+			 * disable TSO for pcie and 10/100 speeds, to avoid
+			 * some hardware issues
+			 */
 			if (!(adapter->flags & FLAG_TSO_FORCE)) {
 				switch (adapter->link_speed) {
 				case SPEED_10:
@@ -2676,8 +2803,10 @@ static void e1000_watchdog_task(struct work_struct *work)
 				}
 			}
 
-			/* enable transmits in the hardware, need to do this
-			 * after setting TARC0 */
+			/*
+			 * enable transmits in the hardware, need to do this
+			 * after setting TARC(0)
+			 */
 			tctl = er32(TCTL);
 			tctl |= E1000_TCTL_EN;
 			ew32(TCTL, tctl);
@@ -2688,13 +2817,6 @@ static void e1000_watchdog_task(struct work_struct *work)
 			if (!test_bit(__E1000_DOWN, &adapter->state))
 				mod_timer(&adapter->phy_info_timer,
 					  round_jiffies(jiffies + 2 * HZ));
-		} else {
-			/* make sure the receive unit is started */
-			if (adapter->flags & FLAG_RX_NEEDS_RESTART) {
-				u32 rctl = er32(RCTL);
-				ew32(RCTL, rctl |
-						E1000_RCTL_EN);
-			}
 		}
 	} else {
 		if (netif_carrier_ok(netdev)) {
@@ -2731,23 +2853,27 @@ link_up:
 		tx_pending = (e1000_desc_unused(tx_ring) + 1 <
 			       tx_ring->count);
 		if (tx_pending) {
-			/* We've lost link, so the controller stops DMA,
+			/*
+			 * We've lost link, so the controller stops DMA,
 			 * but we've got queued Tx work that's never going
 			 * to get done, so reset controller to flush Tx.
-			 * (Do the reset outside of interrupt context). */
+			 * (Do the reset outside of interrupt context).
+			 */
 			adapter->tx_timeout_count++;
 			schedule_work(&adapter->reset_task);
 		}
 	}
 
-	/* Cause software interrupt to ensure rx ring is cleaned */
+	/* Cause software interrupt to ensure Rx ring is cleaned */
 	ew32(ICS, E1000_ICS_RXDMT0);
 
 	/* Force detection of hung controller every watchdog period */
 	adapter->detect_tx_hung = 1;
 
-	/* With 82571 controllers, LAA may be overwritten due to controller
-	 * reset from the other port. Set the appropriate LAA in RAR[0] */
+	/*
+	 * With 82571 controllers, LAA may be overwritten due to controller
+	 * reset from the other port. Set the appropriate LAA in RAR[0]
+	 */
 	if (e1000e_get_laa_state_82571(hw))
 		e1000e_rar_set(hw, adapter->hw.mac.addr, 0);
 
@@ -3023,16 +3149,20 @@ static void e1000_tx_queue(struct e1000_adapter *adapter,
 
 	tx_desc->lower.data |= cpu_to_le32(adapter->txd_cmd);
 
-	/* Force memory writes to complete before letting h/w
+	/*
+	 * Force memory writes to complete before letting h/w
 	 * know there are new descriptors to fetch.  (Only
 	 * applicable for weak-ordered memory model archs,
-	 * such as IA-64). */
+	 * such as IA-64).
+	 */
 	wmb();
 
 	tx_ring->next_to_use = i;
 	writel(i, adapter->hw.hw_addr + tx_ring->tail);
-	/* we need this if more than one processor can write to our tail
-	 * at a time, it synchronizes IO on IA64/Altix systems */
+	/*
+	 * we need this if more than one processor can write to our tail
+	 * at a time, it synchronizes IO on IA64/Altix systems
+	 */
 	mmiowb();
 }
 
@@ -3080,13 +3210,17 @@ static int __e1000_maybe_stop_tx(struct net_device *netdev, int size)
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 
 	netif_stop_queue(netdev);
-	/* Herbert's original patch had:
+	/*
+	 * Herbert's original patch had:
 	 *  smp_mb__after_netif_stop_queue();
-	 * but since that doesn't exist yet, just open code it. */
+	 * but since that doesn't exist yet, just open code it.
+	 */
 	smp_mb();
 
-	/* We need to check again in a case another CPU has just
-	 * made room available. */
+	/*
+	 * We need to check again in a case another CPU has just
+	 * made room available.
+	 */
 	if (e1000_desc_unused(adapter->tx_ring) < size)
 		return -EBUSY;
 
@@ -3133,21 +3267,29 @@ static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	}
 
 	mss = skb_shinfo(skb)->gso_size;
-	/* The controller does a simple calculation to
+	/*
+	 * The controller does a simple calculation to
 	 * make sure there is enough room in the FIFO before
 	 * initiating the DMA for each buffer.  The calc is:
 	 * 4 = ceil(buffer len/mss).  To make sure we don't
 	 * overrun the FIFO, adjust the max buffer len if mss
-	 * drops. */
+	 * drops.
+	 */
 	if (mss) {
 		u8 hdr_len;
 		max_per_txd = min(mss << 2, max_per_txd);
 		max_txd_pwr = fls(max_per_txd) - 1;
 
-		/* TSO Workaround for 82571/2/3 Controllers -- if skb->data
-		* points to just header, pull a few bytes of payload from
-		* frags into skb->data */
+		/*
+		 * TSO Workaround for 82571/2/3 Controllers -- if skb->data
+		 * points to just header, pull a few bytes of payload from
+		 * frags into skb->data
+		 */
 		hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
+		/*
+		 * we do this workaround for ES2LAN, but it is un-necessary,
+		 * avoiding it could save a lot of cycles
+		 */
 		if (skb->data_len && (hdr_len == len)) {
 			unsigned int pull_size;
 
@@ -3181,8 +3323,10 @@ static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		/* Collision - tell upper layer to requeue */
 		return NETDEV_TX_LOCKED;
 
-	/* need: count + 2 desc gap to keep tail from touching
-	 * head, otherwise try next time */
+	/*
+	 * need: count + 2 desc gap to keep tail from touching
+	 * head, otherwise try next time
+	 */
 	if (e1000_maybe_stop_tx(netdev, count + 2)) {
 		spin_unlock_irqrestore(&adapter->tx_queue_lock, irq_flags);
 		return NETDEV_TX_BUSY;
@@ -3207,9 +3351,11 @@ static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	else if (e1000_tx_csum(adapter, skb))
 		tx_flags |= E1000_TX_FLAGS_CSUM;
 
-	/* Old method was to assume IPv4 packet by default if TSO was enabled.
+	/*
+	 * Old method was to assume IPv4 packet by default if TSO was enabled.
 	 * 82571 hardware supports TSO capabilities for IPv6 as well...
-	 * no longer assume, we must. */
+	 * no longer assume, we must.
+	 */
 	if (skb->protocol == htons(ETH_P_IP))
 		tx_flags |= E1000_TX_FLAGS_IPV4;
 
@@ -3307,14 +3453,16 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 	while (test_and_set_bit(__E1000_RESETTING, &adapter->state))
 		msleep(1);
 	/* e1000e_down has a dependency on max_frame_size */
-	adapter->hw.mac.max_frame_size = max_frame;
+	adapter->max_frame_size = max_frame;
 	if (netif_running(netdev))
 		e1000e_down(adapter);
 
-	/* NOTE: netdev_alloc_skb reserves 16 bytes, and typically NET_IP_ALIGN
+	/*
+	 * NOTE: netdev_alloc_skb reserves 16 bytes, and typically NET_IP_ALIGN
 	 * means we reserve 2 more, this pushes us to allocate from the next
 	 * larger slab size.
-	 * i.e. RXBUFFER_2048 --> size-4096 slab */
+	 * i.e. RXBUFFER_2048 --> size-4096 slab
+	 */
 
 	if (max_frame <= 256)
 		adapter->rx_buffer_len = 256;
@@ -3331,7 +3479,7 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 	if ((max_frame == ETH_FRAME_LEN + ETH_FCS_LEN) ||
 	     (max_frame == ETH_FRAME_LEN + VLAN_HLEN + ETH_FCS_LEN))
 		adapter->rx_buffer_len = ETH_FRAME_LEN + VLAN_HLEN
-					 + ETH_FCS_LEN ;
+					 + ETH_FCS_LEN;
 
 	ndev_info(netdev, "changing MTU from %d to %d\n",
 		netdev->mtu, new_mtu);
@@ -3354,7 +3502,7 @@ static int e1000_mii_ioctl(struct net_device *netdev, struct ifreq *ifr,
 	struct mii_ioctl_data *data = if_mii(ifr);
 	unsigned long irq_flags;
 
-	if (adapter->hw.media_type != e1000_media_type_copper)
+	if (adapter->hw.phy.media_type != e1000_media_type_copper)
 		return -EOPNOTSUPP;
 
 	switch (cmd) {
@@ -3436,8 +3584,9 @@ static int e1000_suspend(struct pci_dev *pdev, pm_message_t state)
 			E1000_CTRL_EN_PHY_PWR_MGMT;
 		ew32(CTRL, ctrl);
 
-		if (adapter->hw.media_type == e1000_media_type_fiber ||
-		   adapter->hw.media_type == e1000_media_type_internal_serdes) {
+		if (adapter->hw.phy.media_type == e1000_media_type_fiber ||
+		    adapter->hw.phy.media_type ==
+		    e1000_media_type_internal_serdes) {
 			/* keep the laser running in D3 */
 			ctrl_ext = er32(CTRL_EXT);
 			ctrl_ext |= E1000_CTRL_EXT_SDP7_DATA;
@@ -3467,8 +3616,10 @@ static int e1000_suspend(struct pci_dev *pdev, pm_message_t state)
 	if (adapter->hw.phy.type == e1000_phy_igp_3)
 		e1000e_igp3_phy_powerdown_workaround_ich8lan(&adapter->hw);
 
-	/* Release control of h/w to f/w.  If f/w is AMT enabled, this
-	 * would have already happened in close and is redundant. */
+	/*
+	 * Release control of h/w to f/w.  If f/w is AMT enabled, this
+	 * would have already happened in close and is redundant.
+	 */
 	e1000_release_hw_control(adapter);
 
 	pci_disable_device(pdev);
@@ -3543,9 +3694,11 @@ static int e1000_resume(struct pci_dev *pdev)
 
 	netif_device_attach(netdev);
 
-	/* If the controller has AMT, do not set DRV_LOAD until the interface
+	/*
+	 * If the controller has AMT, do not set DRV_LOAD until the interface
 	 * is up.  For all other cases, let the f/w know that the h/w is now
-	 * under the control of the driver. */
+	 * under the control of the driver.
+	 */
 	if (!(adapter->flags & FLAG_HAS_AMT) || !e1000e_check_mng_mode(&adapter->hw))
 		e1000_get_hw_control(adapter);
 
@@ -3656,9 +3809,11 @@ static void e1000_io_resume(struct pci_dev *pdev)
 
 	netif_device_attach(netdev);
 
-	/* If the controller has AMT, do not set DRV_LOAD until the interface
+	/*
+	 * If the controller has AMT, do not set DRV_LOAD until the interface
 	 * is up.  For all other cases, let the f/w know that the h/w is now
-	 * under the control of the driver. */
+	 * under the control of the driver.
+	 */
 	if (!(adapter->flags & FLAG_HAS_AMT) ||
 	    !e1000e_check_mng_mode(&adapter->hw))
 		e1000_get_hw_control(adapter);
@@ -3825,10 +3980,10 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 
 	hw->mac.ops.get_bus_info(&adapter->hw);
 
-	adapter->hw.phy.wait_for_link = 0;
+	adapter->hw.phy.autoneg_wait_to_complete = 0;
 
 	/* Copper options */
-	if (adapter->hw.media_type == e1000_media_type_copper) {
+	if (adapter->hw.phy.media_type == e1000_media_type_copper) {
 		adapter->hw.phy.mdix = AUTO_ALL_MODES;
 		adapter->hw.phy.disable_polarity_correction = 0;
 		adapter->hw.phy.ms_type = e1000_ms_hw_default;
@@ -3852,15 +4007,19 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	if (pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
 
-	/* We should not be using LLTX anymore, but we are still TX faster with
-	 * it. */
+	/*
+	 * We should not be using LLTX anymore, but we are still Tx faster with
+	 * it.
+	 */
 	netdev->features |= NETIF_F_LLTX;
 
 	if (e1000e_enable_mng_pass_thru(&adapter->hw))
 		adapter->flags |= FLAG_MNG_PT_ENABLED;
 
-	/* before reading the NVM, reset the controller to
-	 * put the device in a known good starting state */
+	/*
+	 * before reading the NVM, reset the controller to
+	 * put the device in a known good starting state
+	 */
 	adapter->hw.mac.ops.reset_hw(&adapter->hw);
 
 	/*
@@ -3910,8 +4069,8 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	/* Initialize link parameters. User can change them with ethtool */
 	adapter->hw.mac.autoneg = 1;
 	adapter->fc_autoneg = 1;
-	adapter->hw.mac.original_fc = e1000_fc_default;
-	adapter->hw.mac.fc = e1000_fc_default;
+	adapter->hw.fc.original_type = e1000_fc_default;
+	adapter->hw.fc.type = e1000_fc_default;
 	adapter->hw.phy.autoneg_advertised = 0x2f;
 
 	/* ring size defaults */
@@ -3954,9 +4113,11 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	/* reset the hardware with the new settings */
 	e1000e_reset(adapter);
 
-	/* If the controller has AMT, do not set DRV_LOAD until the interface
+	/*
+	 * If the controller has AMT, do not set DRV_LOAD until the interface
 	 * is up.  For all other cases, let the f/w know that the h/w is now
-	 * under the control of the driver. */
+	 * under the control of the driver.
+	 */
 	if (!(adapter->flags & FLAG_HAS_AMT) ||
 	    !e1000e_check_mng_mode(&adapter->hw))
 		e1000_get_hw_control(adapter);
@@ -4013,16 +4174,20 @@ static void __devexit e1000_remove(struct pci_dev *pdev)
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 
-	/* flush_scheduled work may reschedule our watchdog task, so
-	 * explicitly disable watchdog tasks from being rescheduled  */
+	/*
+	 * flush_scheduled work may reschedule our watchdog task, so
+	 * explicitly disable watchdog tasks from being rescheduled
+	 */
 	set_bit(__E1000_DOWN, &adapter->state);
 	del_timer_sync(&adapter->watchdog_timer);
 	del_timer_sync(&adapter->phy_info_timer);
 
 	flush_scheduled_work();
 
-	/* Release control of h/w to f/w.  If f/w is AMT enabled, this
-	 * would have already happened in close and is redundant. */
+	/*
+	 * Release control of h/w to f/w.  If f/w is AMT enabled, this
+	 * would have already happened in close and is redundant.
+	 */
 	e1000_release_hw_control(adapter);
 
 	unregister_netdev(netdev);
@@ -4060,13 +4225,16 @@ static struct pci_device_id e1000_pci_tbl[] = {
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82571EB_SERDES_DUAL), board_82571 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82571EB_SERDES_QUAD), board_82571 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82571PT_QUAD_COPPER), board_82571 },
+
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82572EI), board_82572 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82572EI_COPPER), board_82572 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82572EI_FIBER), board_82572 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82572EI_SERDES), board_82572 },
+
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82573E), board_82573 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82573E_IAMT), board_82573 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82573L), board_82573 },
+
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_80003ES2LAN_COPPER_DPT),
 	  board_80003es2lan },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_80003ES2LAN_COPPER_SPT),
@@ -4075,6 +4243,7 @@ static struct pci_device_id e1000_pci_tbl[] = {
 	  board_80003es2lan },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_80003ES2LAN_SERDES_SPT),
 	  board_80003es2lan },
+
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH8_IFE), board_ich8lan },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH8_IFE_G), board_ich8lan },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH8_IFE_GT), board_ich8lan },
@@ -4082,6 +4251,7 @@ static struct pci_device_id e1000_pci_tbl[] = {
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH8_IGP_C), board_ich8lan },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH8_IGP_M), board_ich8lan },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH8_IGP_M_AMT), board_ich8lan },
+
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH9_IFE), board_ich9lan },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH9_IFE_G), board_ich9lan },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH9_IFE_GT), board_ich9lan },
@@ -4099,7 +4269,7 @@ static struct pci_driver e1000_driver = {
 	.probe    = e1000_probe,
 	.remove   = __devexit_p(e1000_remove),
 #ifdef CONFIG_PM
-	/* Power Managment Hooks */
+	/* Power Management Hooks */
 	.suspend  = e1000_suspend,
 	.resume   = e1000_resume,
 #endif
@@ -4118,7 +4288,7 @@ static int __init e1000_init_module(void)
 	int ret;
 	printk(KERN_INFO "%s: Intel(R) PRO/1000 Network Driver - %s\n",
 	       e1000e_driver_name, e1000e_driver_version);
-	printk(KERN_INFO "%s: Copyright (c) 1999-2007 Intel Corporation.\n",
+	printk(KERN_INFO "%s: Copyright (c) 1999-2008 Intel Corporation.\n",
 	       e1000e_driver_name);
 	ret = pci_register_driver(&e1000_driver);
 
diff --git a/drivers/net/e1000e/param.c b/drivers/net/e1000e/param.c
index df266c3..a66b92e 100644
--- a/drivers/net/e1000e/param.c
+++ b/drivers/net/e1000e/param.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2007 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -30,7 +30,8 @@
 
 #include "e1000.h"
 
-/* This is the only thing that needs to be changed to adjust the
+/*
+ * This is the only thing that needs to be changed to adjust the
  * maximum number of ports that the driver can manage.
  */
 
@@ -46,7 +47,8 @@ module_param(copybreak, uint, 0644);
 MODULE_PARM_DESC(copybreak,
 	"Maximum size of packet that is copied to a new buffer on receive");
 
-/* All parameters are treated the same, as an integer array of values.
+/*
+ * All parameters are treated the same, as an integer array of values.
  * This macro just reduces the need to repeat the same declaration code
  * over and over (plus this helps to avoid typo bugs).
  */
@@ -60,8 +62,9 @@ MODULE_PARM_DESC(copybreak,
 	MODULE_PARM_DESC(X, desc);
 
 
-/* Transmit Interrupt Delay in units of 1.024 microseconds
- *  Tx interrupt delay needs to typically be set to something non zero
+/*
+ * Transmit Interrupt Delay in units of 1.024 microseconds
+ * Tx interrupt delay needs to typically be set to something non zero
  *
  * Valid Range: 0-65535
  */
@@ -70,7 +73,8 @@ E1000_PARAM(TxIntDelay, "Transmit Interrupt Delay");
 #define MAX_TXDELAY 0xFFFF
 #define MIN_TXDELAY 0
 
-/* Transmit Absolute Interrupt Delay in units of 1.024 microseconds
+/*
+ * Transmit Absolute Interrupt Delay in units of 1.024 microseconds
  *
  * Valid Range: 0-65535
  */
@@ -79,8 +83,9 @@ E1000_PARAM(TxAbsIntDelay, "Transmit Absolute Interrupt Delay");
 #define MAX_TXABSDELAY 0xFFFF
 #define MIN_TXABSDELAY 0
 
-/* Receive Interrupt Delay in units of 1.024 microseconds
- *   hardware will likely hang if you set this to anything but zero.
+/*
+ * Receive Interrupt Delay in units of 1.024 microseconds
+ * hardware will likely hang if you set this to anything but zero.
  *
  * Valid Range: 0-65535
  */
@@ -89,7 +94,8 @@ E1000_PARAM(RxIntDelay, "Receive Interrupt Delay");
 #define MAX_RXDELAY 0xFFFF
 #define MIN_RXDELAY 0
 
-/* Receive Absolute Interrupt Delay in units of 1.024 microseconds
+/*
+ * Receive Absolute Interrupt Delay in units of 1.024 microseconds
  *
  * Valid Range: 0-65535
  */
@@ -98,7 +104,8 @@ E1000_PARAM(RxAbsIntDelay, "Receive Absolute Interrupt Delay");
 #define MAX_RXABSDELAY 0xFFFF
 #define MIN_RXABSDELAY 0
 
-/* Interrupt Throttle Rate (interrupts/sec)
+/*
+ * Interrupt Throttle Rate (interrupts/sec)
  *
  * Valid Range: 100-100000 (0=off, 1=dynamic, 3=dynamic conservative)
  */
@@ -107,7 +114,8 @@ E1000_PARAM(InterruptThrottleRate, "Interrupt Throttling Rate");
 #define MAX_ITR 100000
 #define MIN_ITR 100
 
-/* Enable Smart Power Down of the PHY
+/*
+ * Enable Smart Power Down of the PHY
  *
  * Valid Range: 0, 1
  *
@@ -115,7 +123,8 @@ E1000_PARAM(InterruptThrottleRate, "Interrupt Throttling Rate");
  */
 E1000_PARAM(SmartPowerDownEnable, "Enable PHY smart power down");
 
-/* Enable Kumeran Lock Loss workaround
+/*
+ * Enable Kumeran Lock Loss workaround
  *
  * Valid Range: 0, 1
  *
diff --git a/drivers/net/e1000e/phy.c b/drivers/net/e1000e/phy.c
index dab3c46..3a4574c 100644
--- a/drivers/net/e1000e/phy.c
+++ b/drivers/net/e1000e/phy.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2007 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -134,7 +134,8 @@ static s32 e1000_read_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 *data)
 		return -E1000_ERR_PARAM;
 	}
 
-	/* Set up Op-code, Phy Address, and register offset in the MDI
+	/*
+	 * Set up Op-code, Phy Address, and register offset in the MDI
 	 * Control register.  The MAC will take care of interfacing with the
 	 * PHY to retrieve the desired data.
 	 */
@@ -144,7 +145,11 @@ static s32 e1000_read_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 *data)
 
 	ew32(MDIC, mdic);
 
-	/* Poll the ready bit to see if the MDI read completed */
+	/*
+	 * Poll the ready bit to see if the MDI read completed
+	 * Increasing the time out as testing showed failures with
+	 * the lower time out
+	 */
 	for (i = 0; i < 64; i++) {
 		udelay(50);
 		mdic = er32(MDIC);
@@ -182,7 +187,8 @@ static s32 e1000_write_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 data)
 		return -E1000_ERR_PARAM;
 	}
 
-	/* Set up Op-code, Phy Address, and register offset in the MDI
+	/*
+	 * Set up Op-code, Phy Address, and register offset in the MDI
 	 * Control register.  The MAC will take care of interfacing with the
 	 * PHY to retrieve the desired data.
 	 */
@@ -409,14 +415,15 @@ s32 e1000e_copper_link_setup_m88(struct e1000_hw *hw)
 	s32 ret_val;
 	u16 phy_data;
 
-	/* Enable CRS on TX. This must be set for half-duplex operation. */
+	/* Enable CRS on Tx. This must be set for half-duplex operation. */
 	ret_val = e1e_rphy(hw, M88E1000_PHY_SPEC_CTRL, &phy_data);
 	if (ret_val)
 		return ret_val;
 
 	phy_data |= M88E1000_PSCR_ASSERT_CRS_ON_TX;
 
-	/* Options:
+	/*
+	 * Options:
 	 *   MDI/MDI-X = 0 (default)
 	 *   0 - Auto for all speeds
 	 *   1 - MDI mode
@@ -441,7 +448,8 @@ s32 e1000e_copper_link_setup_m88(struct e1000_hw *hw)
 		break;
 	}
 
-	/* Options:
+	/*
+	 * Options:
 	 *   disable_polarity_correction = 0 (default)
 	 *       Automatic Correction for Reversed Cable Polarity
 	 *   0 - Disabled
@@ -456,7 +464,8 @@ s32 e1000e_copper_link_setup_m88(struct e1000_hw *hw)
 		return ret_val;
 
 	if (phy->revision < 4) {
-		/* Force TX_CLK in the Extended PHY Specific Control Register
+		/*
+		 * Force TX_CLK in the Extended PHY Specific Control Register
 		 * to 25MHz clock.
 		 */
 		ret_val = e1e_rphy(hw, M88E1000_EXT_PHY_SPEC_CTRL, &phy_data);
@@ -543,19 +552,21 @@ s32 e1000e_copper_link_setup_igp(struct e1000_hw *hw)
 
 	/* set auto-master slave resolution settings */
 	if (hw->mac.autoneg) {
-		/* when autonegotiation advertisement is only 1000Mbps then we
+		/*
+		 * when autonegotiation advertisement is only 1000Mbps then we
 		 * should disable SmartSpeed and enable Auto MasterSlave
-		 * resolution as hardware default. */
+		 * resolution as hardware default.
+		 */
 		if (phy->autoneg_advertised == ADVERTISE_1000_FULL) {
 			/* Disable SmartSpeed */
 			ret_val = e1e_rphy(hw, IGP01E1000_PHY_PORT_CONFIG,
-						     &data);
+					   &data);
 			if (ret_val)
 				return ret_val;
 
 			data &= ~IGP01E1000_PSCFR_SMART_SPEED;
 			ret_val = e1e_wphy(hw, IGP01E1000_PHY_PORT_CONFIG,
-						     data);
+					   data);
 			if (ret_val)
 				return ret_val;
 
@@ -630,14 +641,16 @@ static s32 e1000_phy_setup_autoneg(struct e1000_hw *hw)
 			return ret_val;
 	}
 
-	/* Need to parse both autoneg_advertised and fc and set up
+	/*
+	 * Need to parse both autoneg_advertised and fc and set up
 	 * the appropriate PHY registers.  First we will parse for
 	 * autoneg_advertised software override.  Since we can advertise
 	 * a plethora of combinations, we need to check each bit
 	 * individually.
 	 */
 
-	/* First we clear all the 10/100 mb speed bits in the Auto-Neg
+	/*
+	 * First we clear all the 10/100 mb speed bits in the Auto-Neg
 	 * Advertisement Register (Address 4) and the 1000 mb speed bits in
 	 * the  1000Base-T Control Register (Address 9).
 	 */
@@ -683,7 +696,8 @@ static s32 e1000_phy_setup_autoneg(struct e1000_hw *hw)
 		mii_1000t_ctrl_reg |= CR_1000T_FD_CAPS;
 	}
 
-	/* Check for a software override of the flow control settings, and
+	/*
+	 * Check for a software override of the flow control settings, and
 	 * setup the PHY advertisement registers accordingly.  If
 	 * auto-negotiation is enabled, then software will have to set the
 	 * "PAUSE" bits to the correct value in the Auto-Negotiation
@@ -696,38 +710,42 @@ static s32 e1000_phy_setup_autoneg(struct e1000_hw *hw)
 	 *	  but not send pause frames).
 	 *      2:  Tx flow control is enabled (we can send pause frames
 	 *	  but we do not support receiving pause frames).
-	 *      3:  Both Rx and TX flow control (symmetric) are enabled.
+	 *      3:  Both Rx and Tx flow control (symmetric) are enabled.
 	 *  other:  No software override.  The flow control configuration
 	 *	  in the EEPROM is used.
 	 */
-	switch (hw->mac.fc) {
+	switch (hw->fc.type) {
 	case e1000_fc_none:
-		/* Flow control (RX & TX) is completely disabled by a
+		/*
+		 * Flow control (Rx & Tx) is completely disabled by a
 		 * software over-ride.
 		 */
 		mii_autoneg_adv_reg &= ~(NWAY_AR_ASM_DIR | NWAY_AR_PAUSE);
 		break;
 	case e1000_fc_rx_pause:
-		/* RX Flow control is enabled, and TX Flow control is
+		/*
+		 * Rx Flow control is enabled, and Tx Flow control is
 		 * disabled, by a software over-ride.
-		 */
-		/* Since there really isn't a way to advertise that we are
-		 * capable of RX Pause ONLY, we will advertise that we
-		 * support both symmetric and asymmetric RX PAUSE.  Later
+		 *
+		 * Since there really isn't a way to advertise that we are
+		 * capable of Rx Pause ONLY, we will advertise that we
+		 * support both symmetric and asymmetric Rx PAUSE.  Later
 		 * (in e1000e_config_fc_after_link_up) we will disable the
 		 * hw's ability to send PAUSE frames.
 		 */
 		mii_autoneg_adv_reg |= (NWAY_AR_ASM_DIR | NWAY_AR_PAUSE);
 		break;
 	case e1000_fc_tx_pause:
-		/* TX Flow control is enabled, and RX Flow control is
+		/*
+		 * Tx Flow control is enabled, and Rx Flow control is
 		 * disabled, by a software over-ride.
 		 */
 		mii_autoneg_adv_reg |= NWAY_AR_ASM_DIR;
 		mii_autoneg_adv_reg &= ~NWAY_AR_PAUSE;
 		break;
 	case e1000_fc_full:
-		/* Flow control (both RX and TX) is enabled by a software
+		/*
+		 * Flow control (both Rx and Tx) is enabled by a software
 		 * over-ride.
 		 */
 		mii_autoneg_adv_reg |= (NWAY_AR_ASM_DIR | NWAY_AR_PAUSE);
@@ -758,7 +776,7 @@ static s32 e1000_phy_setup_autoneg(struct e1000_hw *hw)
  *  Performs initial bounds checking on autoneg advertisement parameter, then
  *  configure to advertise the full capability.  Setup the PHY to autoneg
  *  and restart the negotiation process between the link partner.  If
- *  wait_for_link, then wait for autoneg to complete before exiting.
+ *  autoneg_wait_to_complete, then wait for autoneg to complete before exiting.
  **/
 static s32 e1000_copper_link_autoneg(struct e1000_hw *hw)
 {
@@ -766,12 +784,14 @@ static s32 e1000_copper_link_autoneg(struct e1000_hw *hw)
 	s32 ret_val;
 	u16 phy_ctrl;
 
-	/* Perform some bounds checking on the autoneg advertisement
+	/*
+	 * Perform some bounds checking on the autoneg advertisement
 	 * parameter.
 	 */
 	phy->autoneg_advertised &= phy->autoneg_mask;
 
-	/* If autoneg_advertised is zero, we assume it was not defaulted
+	/*
+	 * If autoneg_advertised is zero, we assume it was not defaulted
 	 * by the calling code so we set to advertise full capability.
 	 */
 	if (phy->autoneg_advertised == 0)
@@ -785,7 +805,8 @@ static s32 e1000_copper_link_autoneg(struct e1000_hw *hw)
 	}
 	hw_dbg(hw, "Restarting Auto-Neg\n");
 
-	/* Restart auto-negotiation by setting the Auto Neg Enable bit and
+	/*
+	 * Restart auto-negotiation by setting the Auto Neg Enable bit and
 	 * the Auto Neg Restart bit in the PHY control register.
 	 */
 	ret_val = e1e_rphy(hw, PHY_CONTROL, &phy_ctrl);
@@ -797,10 +818,11 @@ static s32 e1000_copper_link_autoneg(struct e1000_hw *hw)
 	if (ret_val)
 		return ret_val;
 
-	/* Does the user want to wait for Auto-Neg to complete here, or
+	/*
+	 * Does the user want to wait for Auto-Neg to complete here, or
 	 * check at a later time (for example, callback routine).
 	 */
-	if (phy->wait_for_link) {
+	if (phy->autoneg_wait_to_complete) {
 		ret_val = e1000_wait_autoneg(hw);
 		if (ret_val) {
 			hw_dbg(hw, "Error while waiting for "
@@ -829,14 +851,18 @@ s32 e1000e_setup_copper_link(struct e1000_hw *hw)
 	bool link;
 
 	if (hw->mac.autoneg) {
-		/* Setup autoneg and flow control advertisement and perform
-		 * autonegotiation. */
+		/*
+		 * Setup autoneg and flow control advertisement and perform
+		 * autonegotiation.
+		 */
 		ret_val = e1000_copper_link_autoneg(hw);
 		if (ret_val)
 			return ret_val;
 	} else {
-		/* PHY will be set to 10H, 10F, 100H or 100F
-		 * depending on user settings. */
+		/*
+		 * PHY will be set to 10H, 10F, 100H or 100F
+		 * depending on user settings.
+		 */
 		hw_dbg(hw, "Forcing Speed and Duplex\n");
 		ret_val = e1000_phy_force_speed_duplex(hw);
 		if (ret_val) {
@@ -845,7 +871,8 @@ s32 e1000e_setup_copper_link(struct e1000_hw *hw)
 		}
 	}
 
-	/* Check link status. Wait up to 100 microseconds for link to become
+	/*
+	 * Check link status. Wait up to 100 microseconds for link to become
 	 * valid.
 	 */
 	ret_val = e1000e_phy_has_link_generic(hw,
@@ -891,7 +918,8 @@ s32 e1000e_phy_force_speed_duplex_igp(struct e1000_hw *hw)
 	if (ret_val)
 		return ret_val;
 
-	/* Clear Auto-Crossover to force MDI manually.  IGP requires MDI
+	/*
+	 * Clear Auto-Crossover to force MDI manually.  IGP requires MDI
 	 * forced whenever speed and duplex are forced.
 	 */
 	ret_val = e1e_rphy(hw, IGP01E1000_PHY_PORT_CTRL, &phy_data);
@@ -909,7 +937,7 @@ s32 e1000e_phy_force_speed_duplex_igp(struct e1000_hw *hw)
 
 	udelay(1);
 
-	if (phy->wait_for_link) {
+	if (phy->autoneg_wait_to_complete) {
 		hw_dbg(hw, "Waiting for forced speed/duplex link on IGP phy.\n");
 
 		ret_val = e1000e_phy_has_link_generic(hw,
@@ -941,7 +969,7 @@ s32 e1000e_phy_force_speed_duplex_igp(struct e1000_hw *hw)
  *  Calls the PHY setup function to force speed and duplex.  Clears the
  *  auto-crossover to force MDI manually.  Resets the PHY to commit the
  *  changes.  If time expires while waiting for link up, we reset the DSP.
- *  After reset, TX_CLK and CRS on TX must be set.  Return successful upon
+ *  After reset, TX_CLK and CRS on Tx must be set.  Return successful upon
  *  successful completion, else return corresponding error code.
  **/
 s32 e1000e_phy_force_speed_duplex_m88(struct e1000_hw *hw)
@@ -951,7 +979,8 @@ s32 e1000e_phy_force_speed_duplex_m88(struct e1000_hw *hw)
 	u16 phy_data;
 	bool link;
 
-	/* Clear Auto-Crossover to force MDI manually.  M88E1000 requires MDI
+	/*
+	 * Clear Auto-Crossover to force MDI manually.  M88E1000 requires MDI
 	 * forced whenever speed and duplex are forced.
 	 */
 	ret_val = e1e_rphy(hw, M88E1000_PHY_SPEC_CTRL, &phy_data);
@@ -980,7 +1009,7 @@ s32 e1000e_phy_force_speed_duplex_m88(struct e1000_hw *hw)
 
 	udelay(1);
 
-	if (phy->wait_for_link) {
+	if (phy->autoneg_wait_to_complete) {
 		hw_dbg(hw, "Waiting for forced speed/duplex link on M88 phy.\n");
 
 		ret_val = e1000e_phy_has_link_generic(hw, PHY_FORCE_LIMIT,
@@ -989,10 +1018,12 @@ s32 e1000e_phy_force_speed_duplex_m88(struct e1000_hw *hw)
 			return ret_val;
 
 		if (!link) {
-			/* We didn't get link.
+			/*
+			 * We didn't get link.
 			 * Reset the DSP and cross our fingers.
 			 */
-			ret_val = e1e_wphy(hw, M88E1000_PHY_PAGE_SELECT, 0x001d);
+			ret_val = e1e_wphy(hw, M88E1000_PHY_PAGE_SELECT,
+					   0x001d);
 			if (ret_val)
 				return ret_val;
 			ret_val = e1000e_phy_reset_dsp(hw);
@@ -1011,7 +1042,8 @@ s32 e1000e_phy_force_speed_duplex_m88(struct e1000_hw *hw)
 	if (ret_val)
 		return ret_val;
 
-	/* Resetting the phy means we need to re-force TX_CLK in the
+	/*
+	 * Resetting the phy means we need to re-force TX_CLK in the
 	 * Extended PHY Specific Control Register to 25MHz clock from
 	 * the reset value of 2.5MHz.
 	 */
@@ -1020,7 +1052,8 @@ s32 e1000e_phy_force_speed_duplex_m88(struct e1000_hw *hw)
 	if (ret_val)
 		return ret_val;
 
-	/* In addition, we must re-enable CRS on Tx for both half and full
+	/*
+	 * In addition, we must re-enable CRS on Tx for both half and full
 	 * duplex.
 	 */
 	ret_val = e1e_rphy(hw, M88E1000_PHY_SPEC_CTRL, &phy_data);
@@ -1051,7 +1084,7 @@ void e1000e_phy_force_speed_duplex_setup(struct e1000_hw *hw, u16 *phy_ctrl)
 	u32 ctrl;
 
 	/* Turn off flow control when forcing speed/duplex */
-	mac->fc = e1000_fc_none;
+	hw->fc.type = e1000_fc_none;
 
 	/* Force speed/duplex on the mac */
 	ctrl = er32(CTRL);
@@ -1124,30 +1157,32 @@ s32 e1000e_set_d3_lplu_state(struct e1000_hw *hw, bool active)
 					     data);
 		if (ret_val)
 			return ret_val;
-		/* LPLU and SmartSpeed are mutually exclusive.  LPLU is used
+		/*
+		 * LPLU and SmartSpeed are mutually exclusive.  LPLU is used
 		 * during Dx states where the power conservation is most
 		 * important.  During driver activity we should enable
-		 * SmartSpeed, so performance is maintained. */
+		 * SmartSpeed, so performance is maintained.
+		 */
 		if (phy->smart_speed == e1000_smart_speed_on) {
 			ret_val = e1e_rphy(hw, IGP01E1000_PHY_PORT_CONFIG,
-						    &data);
+					   &data);
 			if (ret_val)
 				return ret_val;
 
 			data |= IGP01E1000_PSCFR_SMART_SPEED;
 			ret_val = e1e_wphy(hw, IGP01E1000_PHY_PORT_CONFIG,
-						     data);
+					   data);
 			if (ret_val)
 				return ret_val;
 		} else if (phy->smart_speed == e1000_smart_speed_off) {
 			ret_val = e1e_rphy(hw, IGP01E1000_PHY_PORT_CONFIG,
-						     &data);
+					   &data);
 			if (ret_val)
 				return ret_val;
 
 			data &= ~IGP01E1000_PSCFR_SMART_SPEED;
 			ret_val = e1e_wphy(hw, IGP01E1000_PHY_PORT_CONFIG,
-						     data);
+					   data);
 			if (ret_val)
 				return ret_val;
 		}
@@ -1249,8 +1284,10 @@ static s32 e1000_check_polarity_igp(struct e1000_hw *hw)
 	s32 ret_val;
 	u16 data, offset, mask;
 
-	/* Polarity is determined based on the speed of
-	 * our connection. */
+	/*
+	 * Polarity is determined based on the speed of
+	 * our connection.
+	 */
 	ret_val = e1e_rphy(hw, IGP01E1000_PHY_PORT_STATUS, &data);
 	if (ret_val)
 		return ret_val;
@@ -1260,7 +1297,8 @@ static s32 e1000_check_polarity_igp(struct e1000_hw *hw)
 		offset	= IGP01E1000_PHY_PCS_INIT_REG;
 		mask	= IGP01E1000_PHY_POLARITY_MASK;
 	} else {
-		/* This really only applies to 10Mbps since
+		/*
+		 * This really only applies to 10Mbps since
 		 * there is no polarity for 100Mbps (always 0).
 		 */
 		offset	= IGP01E1000_PHY_PORT_STATUS;
@@ -1278,7 +1316,7 @@ static s32 e1000_check_polarity_igp(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_wait_autoneg - Wait for auto-neg compeletion
+ *  e1000_wait_autoneg - Wait for auto-neg completion
  *  @hw: pointer to the HW structure
  *
  *  Waits for auto-negotiation to complete or for the auto-negotiation time
@@ -1302,7 +1340,8 @@ static s32 e1000_wait_autoneg(struct e1000_hw *hw)
 		msleep(100);
 	}
 
-	/* PHY_AUTO_NEG_TIME expiration doesn't guarantee auto-negotiation
+	/*
+	 * PHY_AUTO_NEG_TIME expiration doesn't guarantee auto-negotiation
 	 * has completed.
 	 */
 	return ret_val;
@@ -1324,7 +1363,8 @@ s32 e1000e_phy_has_link_generic(struct e1000_hw *hw, u32 iterations,
 	u16 i, phy_status;
 
 	for (i = 0; i < iterations; i++) {
-		/* Some PHYs require the PHY_STATUS register to be read
+		/*
+		 * Some PHYs require the PHY_STATUS register to be read
 		 * twice due to the link bit being sticky.  No harm doing
 		 * it across the board.
 		 */
@@ -1412,10 +1452,12 @@ s32 e1000e_get_cable_length_igp_2(struct e1000_hw *hw)
 		if (ret_val)
 			return ret_val;
 
-		/* Getting bits 15:9, which represent the combination of
+		/*
+		 * Getting bits 15:9, which represent the combination of
 		 * course and fine gain values.  The result is a number
 		 * that can be put into the lookup table to obtain the
-		 * approximate cable length. */
+		 * approximate cable length.
+		 */
 		cur_agc_index = (phy_data >> IGP02E1000_AGC_LENGTH_SHIFT) &
 				IGP02E1000_AGC_LENGTH_MASK;
 
@@ -1466,7 +1508,7 @@ s32 e1000e_get_phy_info_m88(struct e1000_hw *hw)
 	u16 phy_data;
 	bool link;
 
-	if (hw->media_type != e1000_media_type_copper) {
+	if (hw->phy.media_type != e1000_media_type_copper) {
 		hw_dbg(hw, "Phy info is only valid for copper media\n");
 		return -E1000_ERR_CONFIG;
 	}
diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index 93b7fb2..26acd05 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -421,7 +421,7 @@ struct ehea_fw_handle_entry {
 struct ehea_fw_handle_array {
 	struct ehea_fw_handle_entry *arr;
 	int num_entries;
-	struct semaphore lock;
+	struct mutex lock;
 };
 
 struct ehea_bcmc_reg_entry {
@@ -434,7 +434,7 @@ struct ehea_bcmc_reg_entry {
 struct ehea_bcmc_reg_array {
 	struct ehea_bcmc_reg_entry *arr;
 	int num_entries;
-	struct semaphore lock;
+	struct mutex lock;
 };
 
 #define EHEA_PORT_UP 1
@@ -452,7 +452,7 @@ struct ehea_port {
 	struct vlan_group *vgrp;
 	struct ehea_eq *qp_eq;
 	struct work_struct reset_task;
-	struct semaphore port_lock;
+	struct mutex port_lock;
 	char int_aff_name[EHEA_IRQ_NAME_SIZE];
 	int allmulti;			 /* Indicates IFF_ALLMULTI state */
 	int promisc;		 	 /* Indicates IFF_PROMISC state */
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 07c742d..0c1c360 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -36,6 +36,7 @@
 #include <linux/notifier.h>
 #include <linux/reboot.h>
 #include <asm/kexec.h>
+#include <linux/mutex.h>
 
 #include <net/ip.h>
 
@@ -99,7 +100,7 @@ static int port_name_cnt;
 static LIST_HEAD(adapter_list);
 u64 ehea_driver_flags;
 struct work_struct ehea_rereg_mr_task;
-struct semaphore dlpar_mem_lock;
+static DEFINE_MUTEX(dlpar_mem_lock);
 struct ehea_fw_handle_array ehea_fw_handles;
 struct ehea_bcmc_reg_array ehea_bcmc_regs;
 
@@ -1758,7 +1759,7 @@ static int ehea_set_mac_addr(struct net_device *dev, void *sa)
 
 	memcpy(dev->dev_addr, mac_addr->sa_data, dev->addr_len);
 
-	down(&ehea_bcmc_regs.lock);
+	mutex_lock(&ehea_bcmc_regs.lock);
 
 	/* Deregister old MAC in pHYP */
 	ret = ehea_broadcast_reg_helper(port, H_DEREG_BCMC);
@@ -1776,7 +1777,7 @@ static int ehea_set_mac_addr(struct net_device *dev, void *sa)
 
 out_upregs:
 	ehea_update_bcmc_registrations();
-	up(&ehea_bcmc_regs.lock);
+	mutex_unlock(&ehea_bcmc_regs.lock);
 out_free:
 	kfree(cb0);
 out:
@@ -1938,7 +1939,7 @@ static void ehea_set_multicast_list(struct net_device *dev)
 	}
 	ehea_promiscuous(dev, 0);
 
-	down(&ehea_bcmc_regs.lock);
+	mutex_lock(&ehea_bcmc_regs.lock);
 
 	if (dev->flags & IFF_ALLMULTI) {
 		ehea_allmulti(dev, 1);
@@ -1969,7 +1970,7 @@ static void ehea_set_multicast_list(struct net_device *dev)
 	}
 out:
 	ehea_update_bcmc_registrations();
-	up(&ehea_bcmc_regs.lock);
+	mutex_unlock(&ehea_bcmc_regs.lock);
 	return;
 }
 
@@ -2452,7 +2453,7 @@ static int ehea_up(struct net_device *dev)
 	if (port->state == EHEA_PORT_UP)
 		return 0;
 
-	down(&ehea_fw_handles.lock);
+	mutex_lock(&ehea_fw_handles.lock);
 
 	ret = ehea_port_res_setup(port, port->num_def_qps,
 				  port->num_add_tx_qps);
@@ -2490,7 +2491,7 @@ static int ehea_up(struct net_device *dev)
 		}
 	}
 
-	down(&ehea_bcmc_regs.lock);
+	mutex_lock(&ehea_bcmc_regs.lock);
 
 	ret = ehea_broadcast_reg_helper(port, H_REG_BCMC);
 	if (ret) {
@@ -2513,10 +2514,10 @@ out:
 		ehea_info("Failed starting %s. ret=%i", dev->name, ret);
 
 	ehea_update_bcmc_registrations();
-	up(&ehea_bcmc_regs.lock);
+	mutex_unlock(&ehea_bcmc_regs.lock);
 
 	ehea_update_firmware_handles();
-	up(&ehea_fw_handles.lock);
+	mutex_unlock(&ehea_fw_handles.lock);
 
 	return ret;
 }
@@ -2542,7 +2543,7 @@ static int ehea_open(struct net_device *dev)
 	int ret;
 	struct ehea_port *port = netdev_priv(dev);
 
-	down(&port->port_lock);
+	mutex_lock(&port->port_lock);
 
 	if (netif_msg_ifup(port))
 		ehea_info("enabling port %s", dev->name);
@@ -2553,7 +2554,7 @@ static int ehea_open(struct net_device *dev)
 		netif_start_queue(dev);
 	}
 
-	up(&port->port_lock);
+	mutex_unlock(&port->port_lock);
 
 	return ret;
 }
@@ -2566,18 +2567,18 @@ static int ehea_down(struct net_device *dev)
 	if (port->state == EHEA_PORT_DOWN)
 		return 0;
 
-	down(&ehea_bcmc_regs.lock);
+	mutex_lock(&ehea_fw_handles.lock);
+
+	mutex_lock(&ehea_bcmc_regs.lock);
 	ehea_drop_multicast_list(dev);
 	ehea_broadcast_reg_helper(port, H_DEREG_BCMC);
 
 	ehea_free_interrupts(dev);
 
-	down(&ehea_fw_handles.lock);
-
 	port->state = EHEA_PORT_DOWN;
 
 	ehea_update_bcmc_registrations();
-	up(&ehea_bcmc_regs.lock);
+	mutex_unlock(&ehea_bcmc_regs.lock);
 
 	ret = ehea_clean_all_portres(port);
 	if (ret)
@@ -2585,7 +2586,7 @@ static int ehea_down(struct net_device *dev)
 			  dev->name, ret);
 
 	ehea_update_firmware_handles();
-	up(&ehea_fw_handles.lock);
+	mutex_unlock(&ehea_fw_handles.lock);
 
 	return ret;
 }
@@ -2599,11 +2600,11 @@ static int ehea_stop(struct net_device *dev)
 		ehea_info("disabling port %s", dev->name);
 
 	flush_scheduled_work();
-	down(&port->port_lock);
+	mutex_lock(&port->port_lock);
 	netif_stop_queue(dev);
 	port_napi_disable(port);
 	ret = ehea_down(dev);
-	up(&port->port_lock);
+	mutex_unlock(&port->port_lock);
 	return ret;
 }
 
@@ -2801,7 +2802,7 @@ static void ehea_reset_port(struct work_struct *work)
 	struct net_device *dev = port->netdev;
 
 	port->resets++;
-	down(&port->port_lock);
+	mutex_lock(&port->port_lock);
 	netif_stop_queue(dev);
 
 	port_napi_disable(port);
@@ -2821,7 +2822,7 @@ static void ehea_reset_port(struct work_struct *work)
 
 	netif_wake_queue(dev);
 out:
-	up(&port->port_lock);
+	mutex_unlock(&port->port_lock);
 	return;
 }
 
@@ -2830,7 +2831,7 @@ static void ehea_rereg_mrs(struct work_struct *work)
 	int ret, i;
 	struct ehea_adapter *adapter;
 
-	down(&dlpar_mem_lock);
+	mutex_lock(&dlpar_mem_lock);
 	ehea_info("LPAR memory enlarged - re-initializing driver");
 
 	list_for_each_entry(adapter, &adapter_list, list)
@@ -2838,21 +2839,23 @@ static void ehea_rereg_mrs(struct work_struct *work)
 			/* Shutdown all ports */
 			for (i = 0; i < EHEA_MAX_PORTS; i++) {
 				struct ehea_port *port = adapter->port[i];
+				struct net_device *dev;
 
-				if (port) {
-					struct net_device *dev = port->netdev;
+				if (!port)
+					continue;
 
-					if (dev->flags & IFF_UP) {
-						down(&port->port_lock);
-						netif_stop_queue(dev);
-						ret = ehea_stop_qps(dev);
-						if (ret) {
-							up(&port->port_lock);
-							goto out;
-						}
-						port_napi_disable(port);
-						up(&port->port_lock);
+				dev = port->netdev;
+
+				if (dev->flags & IFF_UP) {
+					mutex_lock(&port->port_lock);
+					netif_stop_queue(dev);
+					ret = ehea_stop_qps(dev);
+					if (ret) {
+						mutex_unlock(&port->port_lock);
+						goto out;
 					}
+					port_napi_disable(port);
+					mutex_unlock(&port->port_lock);
 				}
 			}
 
@@ -2892,17 +2895,17 @@ static void ehea_rereg_mrs(struct work_struct *work)
 					struct net_device *dev = port->netdev;
 
 					if (dev->flags & IFF_UP) {
-						down(&port->port_lock);
+						mutex_lock(&port->port_lock);
 						port_napi_enable(port);
 						ret = ehea_restart_qps(dev);
 						if (!ret)
 							netif_wake_queue(dev);
-						up(&port->port_lock);
+						mutex_unlock(&port->port_lock);
 					}
 				}
 			}
 		}
-       up(&dlpar_mem_lock);
+       mutex_unlock(&dlpar_mem_lock);
        ehea_info("re-initializing driver complete");
 out:
 	return;
@@ -3063,7 +3066,7 @@ struct ehea_port *ehea_setup_single_port(struct ehea_adapter *adapter,
 
 	port = netdev_priv(dev);
 
-	sema_init(&port->port_lock, 1);
+	mutex_init(&port->port_lock);
 	port->state = EHEA_PORT_DOWN;
 	port->sig_comp_iv = sq_entries / 10;
 
@@ -3342,7 +3345,7 @@ static int __devinit ehea_probe_adapter(struct of_device *dev,
 		ehea_error("Invalid ibmebus device probed");
 		return -EINVAL;
 	}
-	down(&ehea_fw_handles.lock);
+	mutex_lock(&ehea_fw_handles.lock);
 
 	adapter = kzalloc(sizeof(*adapter), GFP_KERNEL);
 	if (!adapter) {
@@ -3426,7 +3429,7 @@ out_free_ad:
 
 out:
 	ehea_update_firmware_handles();
-	up(&ehea_fw_handles.lock);
+	mutex_unlock(&ehea_fw_handles.lock);
 	return ret;
 }
 
@@ -3445,7 +3448,7 @@ static int __devexit ehea_remove(struct of_device *dev)
 
 	flush_scheduled_work();
 
-	down(&ehea_fw_handles.lock);
+	mutex_lock(&ehea_fw_handles.lock);
 
 	ibmebus_free_irq(adapter->neq->attr.ist1, adapter);
 	tasklet_kill(&adapter->neq_tasklet);
@@ -3456,7 +3459,7 @@ static int __devexit ehea_remove(struct of_device *dev)
 	kfree(adapter);
 
 	ehea_update_firmware_handles();
-	up(&ehea_fw_handles.lock);
+	mutex_unlock(&ehea_fw_handles.lock);
 
 	return 0;
 }
@@ -3543,9 +3546,8 @@ int __init ehea_module_init(void)
 	memset(&ehea_fw_handles, 0, sizeof(ehea_fw_handles));
 	memset(&ehea_bcmc_regs, 0, sizeof(ehea_bcmc_regs));
 
-	sema_init(&dlpar_mem_lock, 1);
-	sema_init(&ehea_fw_handles.lock, 1);
-	sema_init(&ehea_bcmc_regs.lock, 1);
+	mutex_init(&ehea_fw_handles.lock);
+	mutex_init(&ehea_bcmc_regs.lock);
 
 	ret = check_module_parm();
 	if (ret)
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 7ad2993..cb371a8 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -367,7 +367,7 @@ static int __ixgbe_notify_dca(struct device *dev, void *data)
 		/* Always use CB2 mode, difference is masked
 		 * in the CB driver. */
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_DCA_CTRL, 2);
-		if (dca_add_requester(dev) == IXGBE_SUCCESS) {
+		if (dca_add_requester(dev) == 0) {
 			ixgbe_setup_dca(adapter);
 			break;
 		}
@@ -381,7 +381,7 @@ static int __ixgbe_notify_dca(struct device *dev, void *data)
 		break;
 	}
 
-	return IXGBE_SUCCESS;
+	return 0;
 }
 
 #endif /* CONFIG_DCA */
@@ -3605,7 +3605,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 		goto err_register;
 
 #ifdef CONFIG_DCA
-	if (dca_add_requester(&pdev->dev) == IXGBE_SUCCESS) {
+	if (dca_add_requester(&pdev->dev) == 0) {
 		adapter->flags |= IXGBE_FLAG_DCA_ENABLED;
 		/* always use CB2 mode, difference is masked
 		 * in the CB driver */
diff --git a/drivers/net/tokenring/3c359.c b/drivers/net/tokenring/3c359.c
index 44a06f8..45208a0 100644
--- a/drivers/net/tokenring/3c359.c
+++ b/drivers/net/tokenring/3c359.c
@@ -42,6 +42,7 @@
 
 #define XL_DEBUG 0
 
+#include <linux/jiffies.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/errno.h>
@@ -408,7 +409,7 @@ static int xl_hw_reset(struct net_device *dev)
 	t=jiffies;
 	while (readw(xl_mmio + MMIO_INTSTATUS) & INTSTAT_CMD_IN_PROGRESS) { 
 		schedule();		
-		if(jiffies-t > 40*HZ) {
+		if (time_after(jiffies, t + 40 * HZ)) {
 			printk(KERN_ERR "%s: 3COM 3C359 Velocity XL  card not responding to global reset.\n", dev->name);
 			return -ENODEV;
 		}
@@ -519,7 +520,7 @@ static int xl_hw_reset(struct net_device *dev)
 	t=jiffies;
 	while ( !(readw(xl_mmio + MMIO_INTSTATUS_AUTO) & INTSTAT_SRB) ) { 
 		schedule();		
-		if(jiffies-t > 15*HZ) {
+		if (time_after(jiffies, t + 15 * HZ)) {
 			printk(KERN_ERR "3COM 3C359 Velocity XL  card not responding.\n");
 			return -ENODEV; 
 		}
@@ -790,7 +791,7 @@ static int xl_open_hw(struct net_device *dev)
 	t=jiffies;
 	while (! (readw(xl_mmio + MMIO_INTSTATUS) & INTSTAT_SRB)) { 
 		schedule();		
-		if(jiffies-t > 40*HZ) {
+		if (time_after(jiffies, t + 40 * HZ)) {
 			printk(KERN_ERR "3COM 3C359 Velocity XL  card not responding.\n");
 			break ; 
 		}
@@ -1003,7 +1004,7 @@ static void xl_reset(struct net_device *dev)
 
 	t=jiffies;
 	while (readw(xl_mmio + MMIO_INTSTATUS) & INTSTAT_CMD_IN_PROGRESS) { 
-		if(jiffies-t > 40*HZ) {
+		if (time_after(jiffies, t + 40 * HZ)) {
 			printk(KERN_ERR "3COM 3C359 Velocity XL  card not responding.\n");
 			break ; 
 		}
@@ -1270,7 +1271,7 @@ static int xl_close(struct net_device *dev)
 	t=jiffies;
 	while (readw(xl_mmio + MMIO_INTSTATUS) & INTSTAT_CMD_IN_PROGRESS) { 
 		schedule();		
-		if(jiffies-t > 10*HZ) {
+		if (time_after(jiffies, t + 10 * HZ)) {
 			printk(KERN_ERR "%s: 3COM 3C359 Velocity XL-DNSTALL not responding.\n", dev->name);
 			break ; 
 		}
@@ -1279,7 +1280,7 @@ static int xl_close(struct net_device *dev)
 	t=jiffies;
 	while (readw(xl_mmio + MMIO_INTSTATUS) & INTSTAT_CMD_IN_PROGRESS) { 
 		schedule();		
-		if(jiffies-t > 10*HZ) {
+		if (time_after(jiffies, t + 10 * HZ)) {
 			printk(KERN_ERR "%s: 3COM 3C359 Velocity XL-DNDISABLE not responding.\n", dev->name);
 			break ;
 		}
@@ -1288,7 +1289,7 @@ static int xl_close(struct net_device *dev)
 	t=jiffies;
 	while (readw(xl_mmio + MMIO_INTSTATUS) & INTSTAT_CMD_IN_PROGRESS) { 
 		schedule();		
-		if(jiffies-t > 10*HZ) {
+		if (time_after(jiffies, t + 10 * HZ)) {
 			printk(KERN_ERR "%s: 3COM 3C359 Velocity XL-UPSTALL not responding.\n", dev->name);
 			break ; 
 		}
@@ -1305,7 +1306,7 @@ static int xl_close(struct net_device *dev)
 	t=jiffies;
 	while (!(readw(xl_mmio + MMIO_INTSTATUS) & INTSTAT_SRB)) { 
 		schedule();		
-		if(jiffies-t > 10*HZ) {
+		if (time_after(jiffies, t + 10 * HZ)) {
 			printk(KERN_ERR "%s: 3COM 3C359 Velocity XL-CLOSENIC not responding.\n", dev->name);
 			break ; 
 		}
@@ -1334,7 +1335,7 @@ static int xl_close(struct net_device *dev)
 	t=jiffies;
 	while (readw(xl_mmio + MMIO_INTSTATUS) & INTSTAT_CMD_IN_PROGRESS) { 
 		schedule();		
-		if(jiffies-t > 10*HZ) {
+		if (time_after(jiffies, t + 10 * HZ)) {
 			printk(KERN_ERR "%s: 3COM 3C359 Velocity XL-UPRESET not responding.\n", dev->name);
 			break ; 
 		}
@@ -1343,7 +1344,7 @@ static int xl_close(struct net_device *dev)
 	t=jiffies;
 	while (readw(xl_mmio + MMIO_INTSTATUS) & INTSTAT_CMD_IN_PROGRESS) { 
 		schedule();		
-		if(jiffies-t > 10*HZ) {
+		if (time_after(jiffies, t + 10 * HZ)) {
 			printk(KERN_ERR "%s: 3COM 3C359 Velocity XL-DNRESET not responding.\n", dev->name);
 			break ; 
 		}
diff --git a/drivers/net/yellowfin.c b/drivers/net/yellowfin.c
index fe6ff3e..2464072 100644
--- a/drivers/net/yellowfin.c
+++ b/drivers/net/yellowfin.c
@@ -770,14 +770,14 @@ static void yellowfin_init_ring(struct net_device *dev)
 		/* Branch on Tx error. */
 		yp->tx_ring[j].dbdma_cmd = cpu_to_le32(CMD_STOP);
 		yp->tx_ring[j].branch_addr = cpu_to_le32(yp->tx_ring_dma +
-			(j+1)*sizeof(struct yellowfin_desc);
+			(j+1)*sizeof(struct yellowfin_desc));
 		j++;
 		if (yp->flags & FullTxStatus) {
 			yp->tx_ring[j].dbdma_cmd =
 				cpu_to_le32(CMD_TXSTATUS | sizeof(*yp->tx_status));
 			yp->tx_ring[j].request_cnt = sizeof(*yp->tx_status);
 			yp->tx_ring[j].addr = cpu_to_le32(yp->tx_status_dma +
-				i*sizeof(struct tx_status_words);
+				i*sizeof(struct tx_status_words));
 		} else {
 			/* Symbios chips write only tx_errs word. */
 			yp->tx_ring[j].dbdma_cmd =
diff --git a/include/linux/arcdevice.h b/include/linux/arcdevice.h
index fde6758..a191607 100644
--- a/include/linux/arcdevice.h
+++ b/include/linux/arcdevice.h
@@ -283,8 +283,8 @@ struct arcnet_local {
 	int next_buf, first_free_buf;
 
 	/* network "reconfiguration" handling */
-	time_t first_recon,	/* time of "first" RECON message to count */
-		last_recon;	/* time of most recent RECON */
+	unsigned long first_recon; /* time of "first" RECON message to count */
+	unsigned long last_recon;  /* time of most recent RECON */
 	int num_recons;		/* number of RECONs between first and last. */
 	bool network_down;	/* do we think the network is down? */
 
