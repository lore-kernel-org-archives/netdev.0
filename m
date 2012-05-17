From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH 2/5] drivers/net: delete all code/drivers depending on CONFIG_MCA
Date: Thu, 17 May 2012 12:40:38 -0400
Message-ID: <1337272841-25931-3-git-send-email-paul.gortmaker@windriver.com>
References: <1337272841-25931-1-git-send-email-paul.gortmaker@windriver.com>
Cc: JBottomley@parallels.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	James Bottomley <JBottomley@parallels.com>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1337272841-25931-1-git-send-email-paul.gortmaker@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The support for CONFIG_MCA is being removed, since the 20
year old hardware simply isn't capable of meeting today's
software demands on CPU and memory resources.

This commit removes any MCA specific net drivers, and removes
any MCA specific probe/support code from drivers that were
doing a dual ISA/MCA role.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: James Bottomley <JBottomley@Parallels.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 Documentation/networking/3c509.txt     |    1 -
 Documentation/networking/fore200e.txt  |    6 +-
 drivers/net/Space.c                    |   16 +-
 drivers/net/ethernet/3com/3c509.c      |  123 +---
 drivers/net/ethernet/8390/Kconfig      |   24 -
 drivers/net/ethernet/8390/Makefile     |    1 -
 drivers/net/ethernet/8390/ne2.c        |  798 ---------------
 drivers/net/ethernet/8390/smc-mca.c    |  575 -----------
 drivers/net/ethernet/amd/depca.c       |  210 +----
 drivers/net/ethernet/fujitsu/at1700.c  |  120 +---
 drivers/net/ethernet/i825xx/3c523.c    | 1312 -------------------------
 drivers/net/ethernet/i825xx/3c523.h    |  355 -------
 drivers/net/ethernet/i825xx/3c527.c    | 1660 --------------------------------
 drivers/net/ethernet/i825xx/Kconfig    |   22 -
 drivers/net/ethernet/i825xx/Makefile   |    2 -
 drivers/net/ethernet/i825xx/eexpress.c |   60 +--
 drivers/net/ethernet/natsemi/Kconfig   |   20 +-
 drivers/net/ethernet/natsemi/Makefile  |    1 -
 18 files changed, 18 insertions(+), 5288 deletions(-)
 delete mode 100644 drivers/net/ethernet/8390/ne2.c
 delete mode 100644 drivers/net/ethernet/8390/smc-mca.c
 delete mode 100644 drivers/net/ethernet/i825xx/3c523.c
 delete mode 100644 drivers/net/ethernet/i825xx/3c523.h
 delete mode 100644 drivers/net/ethernet/i825xx/3c527.c

diff --git a/Documentation/networking/3c509.txt b/Documentation/networking/3c509.txt
index dcc9eaf..fbf722e 100644
--- a/Documentation/networking/3c509.txt
+++ b/Documentation/networking/3c509.txt
@@ -25,7 +25,6 @@ models:
   3c509B (later revision of the ISA card; supports full-duplex)
   3c589 (PCMCIA)
   3c589B (later revision of the 3c589; supports full-duplex)
-  3c529 (MCA)
   3c579 (EISA)
 
 Large portions of this documentation were heavily borrowed from the guide
diff --git a/Documentation/networking/fore200e.txt b/Documentation/networking/fore200e.txt
index f648eb2..d52af53 100644
--- a/Documentation/networking/fore200e.txt
+++ b/Documentation/networking/fore200e.txt
@@ -11,12 +11,10 @@ i386, alpha (untested), powerpc, sparc and sparc64 archs.
 
 The intent is to enable the use of different models of FORE adapters at the
 same time, by hosts that have several bus interfaces (such as PCI+SBUS,
-PCI+MCA or PCI+EISA).
+or PCI+EISA).
 
 Only PCI and SBUS devices are currently supported by the driver, but support
-for other bus interfaces such as EISA should not be too hard to add (this may
-be more tricky for the MCA bus, though, as FORE made some MCA-specific
-modifications to the adapter's AALI interface).
+for other bus interfaces such as EISA should not be too hard to add.
 
 
 Firmware Copyright Notice
diff --git a/drivers/net/Space.c b/drivers/net/Space.c
index 486e2dc..e3f0fac 100644
--- a/drivers/net/Space.c
+++ b/drivers/net/Space.c
@@ -133,22 +133,9 @@ static struct devprobe2 eisa_probes[] __initdata = {
 	{NULL, 0},
 };
 
-static struct devprobe2 mca_probes[] __initdata = {
-#ifdef CONFIG_NE2_MCA
-	{ne2_probe, 0},
-#endif
-#ifdef CONFIG_ELMC		/* 3c523 */
-	{elmc_probe, 0},
-#endif
-#ifdef CONFIG_ELMC_II		/* 3c527 */
-	{mc32_probe, 0},
-#endif
-	{NULL, 0},
-};
-
 /*
  * ISA probes that touch addresses < 0x400 (including those that also
- * look for EISA/PCI/MCA cards in addition to ISA cards).
+ * look for EISA/PCI cards in addition to ISA cards).
  */
 static struct devprobe2 isa_probes[] __initdata = {
 #if defined(CONFIG_HP100) && defined(CONFIG_ISA)	/* ISA, EISA */
@@ -278,7 +265,6 @@ static void __init ethif_probe2(int unit)
 
 	(void)(	probe_list2(unit, m68k_probes, base_addr == 0) &&
 		probe_list2(unit, eisa_probes, base_addr == 0) &&
-		probe_list2(unit, mca_probes, base_addr == 0) &&
 		probe_list2(unit, isa_probes, base_addr == 0) &&
 		probe_list2(unit, parport_probes, base_addr == 0));
 }
diff --git a/drivers/net/ethernet/3com/3c509.c b/drivers/net/ethernet/3com/3c509.c
index 41719da..1a8eef2 100644
--- a/drivers/net/ethernet/3com/3c509.c
+++ b/drivers/net/ethernet/3com/3c509.c
@@ -69,7 +69,6 @@
 #define TX_TIMEOUT  (400*HZ/1000)
 
 #include <linux/module.h>
-#include <linux/mca.h>
 #include <linux/isa.h>
 #include <linux/pnp.h>
 #include <linux/string.h>
@@ -102,7 +101,7 @@ static int el3_debug = 2;
 #endif
 
 /* Used to do a global count of all the cards in the system.  Must be
- * a global variable so that the mca/eisa probe routines can increment
+ * a global variable so that the eisa probe routines can increment
  * it */
 static int el3_cards = 0;
 #define EL3_MAX_CARDS 8
@@ -163,7 +162,7 @@ enum RxFilter {
  */
 #define SKB_QUEUE_SIZE	64
 
-enum el3_cardtype { EL3_ISA, EL3_PNP, EL3_MCA, EL3_EISA };
+enum el3_cardtype { EL3_ISA, EL3_PNP, EL3_EISA };
 
 struct el3_private {
 	spinlock_t lock;
@@ -505,41 +504,6 @@ static struct eisa_driver el3_eisa_driver = {
 static int eisa_registered;
 #endif
 
-#ifdef CONFIG_MCA
-static int el3_mca_probe(struct device *dev);
-
-static short el3_mca_adapter_ids[] __initdata = {
-		0x627c,
-		0x627d,
-		0x62db,
-		0x62f6,
-		0x62f7,
-		0x0000
-};
-
-static char *el3_mca_adapter_names[] __initdata = {
-		"3Com 3c529 EtherLink III (10base2)",
-		"3Com 3c529 EtherLink III (10baseT)",
-		"3Com 3c529 EtherLink III (test mode)",
-		"3Com 3c529 EtherLink III (TP or coax)",
-		"3Com 3c529 EtherLink III (TP)",
-		NULL
-};
-
-static struct mca_driver el3_mca_driver = {
-		.id_table = el3_mca_adapter_ids,
-		.driver = {
-				.name = "3c529",
-				.bus = &mca_bus_type,
-				.probe = el3_mca_probe,
-				.remove = __devexit_p(el3_device_remove),
-				.suspend = el3_suspend,
-				.resume  = el3_resume,
-		},
-};
-static int mca_registered;
-#endif /* CONFIG_MCA */
-
 static const struct net_device_ops netdev_ops = {
 	.ndo_open 		= el3_open,
 	.ndo_stop	 	= el3_close,
@@ -600,76 +564,6 @@ static void el3_common_remove (struct net_device *dev)
 	free_netdev (dev);
 }
 
-#ifdef CONFIG_MCA
-static int __init el3_mca_probe(struct device *device)
-{
-	/* Based on Erik Nygren's (nygren@mit.edu) 3c529 patch,
-	 * heavily modified by Chris Beauregard
-	 * (cpbeaure@csclub.uwaterloo.ca) to support standard MCA
-	 * probing.
-	 *
-	 * redone for multi-card detection by ZP Gu (zpg@castle.net)
-	 * now works as a module */
-
-	short i;
-	int ioaddr, irq, if_port;
-	__be16 phys_addr[3];
-	struct net_device *dev = NULL;
-	u_char pos4, pos5;
-	struct mca_device *mdev = to_mca_device(device);
-	int slot = mdev->slot;
-	int err;
-
-	pos4 = mca_device_read_stored_pos(mdev, 4);
-	pos5 = mca_device_read_stored_pos(mdev, 5);
-
-	ioaddr = ((short)((pos4&0xfc)|0x02)) << 8;
-	irq = pos5 & 0x0f;
-
-
-	pr_info("3c529: found %s at slot %d\n",
-		el3_mca_adapter_names[mdev->index], slot + 1);
-
-	/* claim the slot */
-	strncpy(mdev->name, el3_mca_adapter_names[mdev->index],
-			sizeof(mdev->name));
-	mca_device_set_claim(mdev, 1);
-
-	if_port = pos4 & 0x03;
-
-	irq = mca_device_transform_irq(mdev, irq);
-	ioaddr = mca_device_transform_ioport(mdev, ioaddr);
-	if (el3_debug > 2) {
-		pr_debug("3c529: irq %d  ioaddr 0x%x  ifport %d\n", irq, ioaddr, if_port);
-	}
-	EL3WINDOW(0);
-	for (i = 0; i < 3; i++)
-		phys_addr[i] = htons(read_eeprom(ioaddr, i));
-
-	dev = alloc_etherdev(sizeof (struct el3_private));
-	if (dev == NULL) {
-		release_region(ioaddr, EL3_IO_EXTENT);
-		return -ENOMEM;
-	}
-
-	netdev_boot_setup_check(dev);
-
-	el3_dev_fill(dev, phys_addr, ioaddr, irq, if_port, EL3_MCA);
-	dev_set_drvdata(device, dev);
-	err = el3_common_init(dev);
-
-	if (err) {
-		dev_set_drvdata(device, NULL);
-		free_netdev(dev);
-		return -ENOMEM;
-	}
-
-	el3_devs[el3_cards++] = dev;
-	return 0;
-}
-
-#endif /* CONFIG_MCA */
-
 #ifdef CONFIG_EISA
 static int __init el3_eisa_probe (struct device *device)
 {
@@ -1547,11 +1441,6 @@ static int __init el3_init_module(void)
 	if (!ret)
 		eisa_registered = 1;
 #endif
-#ifdef CONFIG_MCA
-	ret = mca_register_driver(&el3_mca_driver);
-	if (!ret)
-		mca_registered = 1;
-#endif
 
 #ifdef CONFIG_PNP
 	if (pnp_registered)
@@ -1563,10 +1452,6 @@ static int __init el3_init_module(void)
 	if (eisa_registered)
 		ret = 0;
 #endif
-#ifdef CONFIG_MCA
-	if (mca_registered)
-		ret = 0;
-#endif
 	return ret;
 }
 
@@ -1584,10 +1469,6 @@ static void __exit el3_cleanup_module(void)
 	if (eisa_registered)
 		eisa_driver_unregister(&el3_eisa_driver);
 #endif
-#ifdef CONFIG_MCA
-	if (mca_registered)
-		mca_unregister_driver(&el3_mca_driver);
-#endif
 }
 
 module_init (el3_init_module);
diff --git a/drivers/net/ethernet/8390/Kconfig b/drivers/net/ethernet/8390/Kconfig
index 910895c..2e53867 100644
--- a/drivers/net/ethernet/8390/Kconfig
+++ b/drivers/net/ethernet/8390/Kconfig
@@ -182,18 +182,6 @@ config NE2000
 	  To compile this driver as a module, choose M here. The module
 	  will be called ne.
 
-config NE2_MCA
-	tristate "NE/2 (ne2000 MCA version) support"
-	depends on MCA_LEGACY
-	select CRC32
-	---help---
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called ne2.
-
 config NE2K_PCI
 	tristate "PCI NE2000 and clones support (see help)"
 	depends on PCI
@@ -267,18 +255,6 @@ config STNIC
 
 	  If unsure, say N.
 
-config ULTRAMCA
-	tristate "SMC Ultra MCA support"
-	depends on MCA
-	select CRC32
-	---help---
-	  If you have a network (Ethernet) card of this type and are running
-	  an MCA based system (PS/2), say Y and read the Ethernet-HOWTO,
-	  available from <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called smc-mca.
-
 config ULTRA
 	tristate "SMC Ultra support"
 	depends on ISA
diff --git a/drivers/net/ethernet/8390/Makefile b/drivers/net/ethernet/8390/Makefile
index 3337d7f..d13790b 100644
--- a/drivers/net/ethernet/8390/Makefile
+++ b/drivers/net/ethernet/8390/Makefile
@@ -24,6 +24,5 @@ obj-$(CONFIG_PCMCIA_PCNET) += pcnet_cs.o 8390.o
 obj-$(CONFIG_STNIC) += stnic.o 8390.o
 obj-$(CONFIG_ULTRA) += smc-ultra.o 8390.o
 obj-$(CONFIG_ULTRA32) += smc-ultra32.o 8390.o
-obj-$(CONFIG_ULTRAMCA) += smc-mca.o 8390.o
 obj-$(CONFIG_WD80x3) += wd.o 8390.o
 obj-$(CONFIG_ZORRO8390) += zorro8390.o 8390.o
diff --git a/drivers/net/ethernet/8390/ne2.c b/drivers/net/ethernet/8390/ne2.c
deleted file mode 100644
index ef85839..0000000
diff --git a/drivers/net/ethernet/8390/smc-mca.c b/drivers/net/ethernet/8390/smc-mca.c
deleted file mode 100644
index 7a68590..0000000
diff --git a/drivers/net/ethernet/amd/depca.c b/drivers/net/ethernet/amd/depca.c
index 7f7b99a..c771de7 100644
--- a/drivers/net/ethernet/amd/depca.c
+++ b/drivers/net/ethernet/amd/depca.c
@@ -155,23 +155,10 @@
     2 depca's in a PC).
 
     ************************************************************************
-    Support for MCA EtherWORKS cards added 11-3-98.
+    Support for MCA EtherWORKS cards added 11-3-98. (MCA since deleted)
     Verified to work with up to 2 DE212 cards in a system (although not
       fully stress-tested).
 
-    Currently known bugs/limitations:
-
-    Note:  with the MCA stuff as a module, it trusts the MCA configuration,
-           not the command line for IRQ and memory address.  You can
-           specify them if you want, but it will throw your values out.
-           You still have to pass the IO address it was configured as
-           though.
-
-    ************************************************************************
-    TO DO:
-    ------
-
-
     Revision History
     ----------------
 
@@ -261,10 +248,6 @@
 #include <asm/io.h>
 #include <asm/dma.h>
 
-#ifdef CONFIG_MCA
-#include <linux/mca.h>
-#endif
-
 #ifdef CONFIG_EISA
 #include <linux/eisa.h>
 #endif
@@ -360,44 +343,6 @@ static struct eisa_driver depca_eisa_driver = {
 };
 #endif
 
-#ifdef CONFIG_MCA
-/*
-** Adapter ID for the MCA EtherWORKS DE210/212 adapter
-*/
-#define DE210_ID 0x628d
-#define DE212_ID 0x6def
-
-static short depca_mca_adapter_ids[] = {
-	DE210_ID,
-	DE212_ID,
-	0x0000
-};
-
-static char *depca_mca_adapter_name[] = {
-	"DEC EtherWORKS MC Adapter (DE210)",
-	"DEC EtherWORKS MC Adapter (DE212)",
-	NULL
-};
-
-static enum depca_type depca_mca_adapter_type[] = {
-	de210,
-	de212,
-	0
-};
-
-static int depca_mca_probe (struct device *);
-
-static struct mca_driver depca_mca_driver = {
-	.id_table = depca_mca_adapter_ids,
-	.driver   = {
-		.name   = depca_string,
-		.bus    = &mca_bus_type,
-		.probe  = depca_mca_probe,
-		.remove = __devexit_p(depca_device_remove),
-	},
-};
-#endif
-
 static int depca_isa_probe (struct platform_device *);
 
 static int __devexit depca_isa_remove(struct platform_device *pdev)
@@ -464,8 +409,7 @@ struct depca_private {
 	char adapter_name[DEPCA_STRLEN];	/* /proc/ioports string                  */
 	enum depca_type adapter;		/* Adapter type */
 	enum {
-                DEPCA_BUS_MCA = 1,
-                DEPCA_BUS_ISA,
+                DEPCA_BUS_ISA = 1,
                 DEPCA_BUS_EISA,
         } depca_bus;	        /* type of bus */
 	struct depca_init init_block;	/* Shadow Initialization block            */
@@ -624,12 +568,6 @@ static int __init depca_hw_init (struct net_device *dev, struct device *device)
 	       dev_name(device), depca_signature[lp->adapter], ioaddr);
 
 	switch (lp->depca_bus) {
-#ifdef CONFIG_MCA
-	case DEPCA_BUS_MCA:
-		printk(" (MCA slot %d)", to_mca_device(device)->slot + 1);
-		break;
-#endif
-
 #ifdef CONFIG_EISA
 	case DEPCA_BUS_EISA:
 		printk(" (EISA slot %d)", to_eisa_device(device)->slot);
@@ -661,10 +599,7 @@ static int __init depca_hw_init (struct net_device *dev, struct device *device)
 	if (nicsr & BUF) {
 		nicsr &= ~BS;	/* DEPCA RAM in top 32k */
 		netRAM -= 32;
-
-		/* Only EISA/ISA needs start address to be re-computed */
-		if (lp->depca_bus != DEPCA_BUS_MCA)
-			mem_start += 0x8000;
+		mem_start += 0x8000;
 	}
 
 	if ((mem_len = (NUM_RX_DESC * (sizeof(struct depca_rx_desc) + RX_BUFF_SZ) + NUM_TX_DESC * (sizeof(struct depca_tx_desc) + TX_BUFF_SZ) + sizeof(struct depca_init)))
@@ -1325,130 +1260,6 @@ static int __init depca_common_init (u_long ioaddr, struct net_device **devp)
 	return status;
 }
 
-#ifdef CONFIG_MCA
-/*
-** Microchannel bus I/O device probe
-*/
-static int __init depca_mca_probe(struct device *device)
-{
-	unsigned char pos[2];
-	unsigned char where;
-	unsigned long iobase, mem_start;
-	int irq, err;
-	struct mca_device *mdev = to_mca_device (device);
-	struct net_device *dev;
-	struct depca_private *lp;
-
-	/*
-	** Search for the adapter.  If an address has been given, search
-	** specifically for the card at that address.  Otherwise find the
-	** first card in the system.
-	*/
-
-	pos[0] = mca_device_read_stored_pos(mdev, 2);
-	pos[1] = mca_device_read_stored_pos(mdev, 3);
-
-	/*
-	** IO of card is handled by bits 1 and 2 of pos0.
-	**
-	**    bit2 bit1    IO
-	**       0    0    0x2c00
-	**       0    1    0x2c10
-	**       1    0    0x2c20
-	**       1    1    0x2c30
-	*/
-	where = (pos[0] & 6) >> 1;
-	iobase = 0x2c00 + (0x10 * where);
-
-	/*
-	** Found the adapter we were looking for. Now start setting it up.
-	**
-	** First work on decoding the IRQ.  It's stored in the lower 4 bits
-	** of pos1.  Bits are as follows (from the ADF file):
-	**
-	**      Bits
-	**   3   2   1   0    IRQ
-	**   --------------------
-	**   0   0   1   0     5
-	**   0   0   0   1     9
-	**   0   1   0   0    10
-	**   1   0   0   0    11
-	*/
-	where = pos[1] & 0x0f;
-	switch (where) {
-	case 1:
-		irq = 9;
-		break;
-	case 2:
-		irq = 5;
-		break;
-	case 4:
-		irq = 10;
-		break;
-	case 8:
-		irq = 11;
-		break;
-	default:
-		printk("%s: mca_probe IRQ error.  You should never get here (%d).\n", mdev->name, where);
-		return -EINVAL;
-	}
-
-	/*
-	** Shared memory address of adapter is stored in bits 3-5 of pos0.
-	** They are mapped as follows:
-	**
-	**    Bit
-	**   5  4  3       Memory Addresses
-	**   0  0  0       C0000-CFFFF (64K)
-	**   1  0  0       C8000-CFFFF (32K)
-	**   0  0  1       D0000-DFFFF (64K)
-	**   1  0  1       D8000-DFFFF (32K)
-	**   0  1  0       E0000-EFFFF (64K)
-	**   1  1  0       E8000-EFFFF (32K)
-	*/
-	where = (pos[0] & 0x18) >> 3;
-	mem_start = 0xc0000 + (where * 0x10000);
-	if (pos[0] & 0x20) {
-		mem_start += 0x8000;
-	}
-
-	/* claim the slot */
-	strncpy(mdev->name, depca_mca_adapter_name[mdev->index],
-		sizeof(mdev->name));
-	mca_device_set_claim(mdev, 1);
-
-        /*
-	** Get everything allocated and initialized...  (almost just
-	** like the ISA and EISA probes)
-	*/
-	irq = mca_device_transform_irq(mdev, irq);
-	iobase = mca_device_transform_ioport(mdev, iobase);
-
-	if ((err = depca_common_init (iobase, &dev)))
-		goto out_unclaim;
-
-	dev->irq = irq;
-	dev->base_addr = iobase;
-	lp = netdev_priv(dev);
-	lp->depca_bus = DEPCA_BUS_MCA;
-	lp->adapter = depca_mca_adapter_type[mdev->index];
-	lp->mem_start = mem_start;
-
-	if ((err = depca_hw_init(dev, device)))
-		goto out_free;
-
-	return 0;
-
- out_free:
-	free_netdev (dev);
-	release_region (iobase, DEPCA_TOTAL_SIZE);
- out_unclaim:
-	mca_device_set_claim(mdev, 0);
-
-	return err;
-}
-#endif
-
 /*
 ** ISA bus I/O device probe
 */
@@ -2059,15 +1870,10 @@ static int __init depca_module_init (void)
 {
 	int err = 0;
 
-#ifdef CONFIG_MCA
-	err = mca_register_driver(&depca_mca_driver);
-	if (err)
-		goto err;
-#endif
 #ifdef CONFIG_EISA
 	err = eisa_driver_register(&depca_eisa_driver);
 	if (err)
-		goto err_mca;
+		goto err_eisa;
 #endif
 	err = platform_driver_register(&depca_isa_driver);
 	if (err)
@@ -2079,11 +1885,6 @@ static int __init depca_module_init (void)
 err_eisa:
 #ifdef CONFIG_EISA
 	eisa_driver_unregister(&depca_eisa_driver);
-err_mca:
-#endif
-#ifdef CONFIG_MCA
-	mca_unregister_driver(&depca_mca_driver);
-err:
 #endif
 	return err;
 }
@@ -2091,9 +1892,6 @@ err:
 static void __exit depca_module_exit (void)
 {
 	int i;
-#ifdef CONFIG_MCA
-        mca_unregister_driver (&depca_mca_driver);
-#endif
 #ifdef CONFIG_EISA
         eisa_driver_unregister (&depca_eisa_driver);
 #endif
diff --git a/drivers/net/ethernet/fujitsu/at1700.c b/drivers/net/ethernet/fujitsu/at1700.c
index 3d94797..4b80dc4 100644
--- a/drivers/net/ethernet/fujitsu/at1700.c
+++ b/drivers/net/ethernet/fujitsu/at1700.c
@@ -27,7 +27,7 @@
 	ATI provided their EEPROM configuration code header file.
     Thanks to NIIBE Yutaka <gniibe@mri.co.jp> for bug fixes.
 
-    MCA bus (AT1720) support by Rene Schmit <rene@bss.lu>
+    MCA bus (AT1720) support (now deleted) by Rene Schmit <rene@bss.lu>
 
   Bugs:
 	The MB86965 has a design flaw that makes all probes unreliable.  Not
@@ -38,7 +38,6 @@
 #include <linux/errno.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
-#include <linux/mca-legacy.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/types.h>
@@ -79,24 +78,6 @@ static unsigned at1700_probe_list[] __initdata = {
 	0x260, 0x280, 0x2a0, 0x240, 0x340, 0x320, 0x380, 0x300, 0
 };
 
-/*
- *	MCA
- */
-#ifdef CONFIG_MCA_LEGACY
-static int at1700_ioaddr_pattern[] __initdata = {
-	0x00, 0x04, 0x01, 0x05, 0x02, 0x06, 0x03, 0x07
-};
-
-static int at1700_mca_probe_list[] __initdata = {
-	0x400, 0x1400, 0x2400, 0x3400, 0x4400, 0x5400, 0x6400, 0x7400, 0
-};
-
-static int at1700_irq_pattern[] __initdata = {
-	0x00, 0x00, 0x00, 0x30, 0x70, 0xb0, 0x00, 0x00,
-	0x00, 0xf0, 0x34, 0x74, 0xb4, 0x00, 0x00, 0xf4, 0x00
-};
-#endif
-
 /* use 0 for production, 1 for verification, >2 for debug */
 #ifndef NET_DEBUG
 #define NET_DEBUG 1
@@ -114,7 +95,6 @@ struct net_local {
 	uint tx_queue_ready:1;			/* Tx queue is ready to be sent. */
 	uint rx_started:1;			/* Packets are Rxing. */
 	uchar tx_queue;				/* Number of packet on the Tx queue. */
-	char mca_slot;				/* -1 means ISA */
 	ushort tx_queue_len;			/* Current length of the Tx queue. */
 };
 
@@ -166,21 +146,6 @@ static void set_rx_mode(struct net_device *dev);
 static void net_tx_timeout (struct net_device *dev);
 
 
-#ifdef CONFIG_MCA_LEGACY
-struct at1720_mca_adapters_struct {
-	char* name;
-	int id;
-};
-/* rEnE : maybe there are others I don't know off... */
-
-static struct at1720_mca_adapters_struct at1720_mca_adapters[] __initdata = {
-	{ "Allied Telesys AT1720AT",	0x6410 },
-	{ "Allied Telesys AT1720BT", 	0x6413 },
-	{ "Allied Telesys AT1720T",	0x6416 },
-	{ NULL, 0 },
-};
-#endif
-
 /* Check for a network adaptor of this type, and return '0' iff one exists.
    If dev->base_addr == 0, probe all likely locations.
    If dev->base_addr == 1, always return failure.
@@ -194,11 +159,6 @@ static int irq;
 
 static void cleanup_card(struct net_device *dev)
 {
-#ifdef CONFIG_MCA_LEGACY
-	struct net_local *lp = netdev_priv(dev);
-	if (lp->mca_slot >= 0)
-		mca_mark_as_unused(lp->mca_slot);
-#endif
 	free_irq(dev->irq, NULL);
 	release_region(dev->base_addr, AT1700_IO_EXTENT);
 }
@@ -273,7 +233,7 @@ static int __init at1700_probe1(struct net_device *dev, int ioaddr)
 	static const char fmv_irqmap_pnp[8] = {3, 4, 5, 7, 9, 10, 11, 15};
 	static const char at1700_irqmap[8] = {3, 4, 5, 9, 10, 11, 14, 15};
 	unsigned int i, irq, is_fmv18x = 0, is_at1700 = 0;
-	int slot, ret = -ENODEV;
+	int ret = -ENODEV;
 	struct net_local *lp = netdev_priv(dev);
 
 	if (!request_region(ioaddr, AT1700_IO_EXTENT, DRV_NAME))
@@ -288,64 +248,6 @@ static int __init at1700_probe1(struct net_device *dev, int ioaddr)
 		   ioaddr, read_eeprom(ioaddr, 4), read_eeprom(ioaddr, 5),
 		   read_eeprom(ioaddr, 6), inw(ioaddr + EEPROM_Ctrl));
 #endif
-
-#ifdef CONFIG_MCA_LEGACY
-	/* rEnE (rene@bss.lu): got this from 3c509 driver source , adapted for AT1720 */
-
-    /* Based on Erik Nygren's (nygren@mit.edu) 3c529 patch, heavily
-	modified by Chris Beauregard (cpbeaure@csclub.uwaterloo.ca)
-	to support standard MCA probing. */
-
-	/* redone for multi-card detection by ZP Gu (zpg@castle.net) */
-	/* now works as a module */
-
-	if (MCA_bus) {
-		int j;
-		int l_i;
-		u_char pos3, pos4;
-
-		for (j = 0; at1720_mca_adapters[j].name != NULL; j ++) {
-			slot = 0;
-			while (slot != MCA_NOTFOUND) {
-
-				slot = mca_find_unused_adapter( at1720_mca_adapters[j].id, slot );
-				if (slot == MCA_NOTFOUND) break;
-
-				/* if we get this far, an adapter has been detected and is
-				enabled */
-
-				pos3 = mca_read_stored_pos( slot, 3 );
-				pos4 = mca_read_stored_pos( slot, 4 );
-
-				for (l_i = 0; l_i < 8; l_i++)
-					if (( pos3 & 0x07) == at1700_ioaddr_pattern[l_i])
-						break;
-				ioaddr = at1700_mca_probe_list[l_i];
-
-				for (irq = 0; irq < 0x10; irq++)
-					if (((((pos4>>4) & 0x0f) | (pos3 & 0xf0)) & 0xff) == at1700_irq_pattern[irq])
-						break;
-
-					/* probing for a card at a particular IO/IRQ */
-				if ((dev->irq && dev->irq != irq) ||
-				    (dev->base_addr && dev->base_addr != ioaddr)) {
-				  	slot++;		/* probing next slot */
-				  	continue;
-				}
-
-				dev->irq = irq;
-
-				/* claim the slot */
-				mca_set_adapter_name( slot, at1720_mca_adapters[j].name );
-				mca_mark_as_used(slot);
-
-				goto found;
-			}
-		}
-		/* if we get here, we didn't find an MCA adapter - try ISA */
-	}
-#endif
-	slot = -1;
 	/* We must check for the EEPROM-config boards first, else accessing
 	   IOCONFIG0 will move the board! */
 	if (at1700_probe_list[inb(ioaddr + IOCONFIG1) & 0x07] == ioaddr &&
@@ -360,11 +262,7 @@ static int __init at1700_probe1(struct net_device *dev, int ioaddr)
 		goto err_out;
 	}
 
-#ifdef CONFIG_MCA_LEGACY
-found:
-#endif
-
-		/* Reset the internal state machines. */
+	/* Reset the internal state machines. */
 	outb(0, ioaddr + RESET);
 
 	if (is_at1700) {
@@ -380,11 +278,11 @@ found:
 					break;
 			}
 			if (i == 8) {
-				goto err_mca;
+				goto err_out;
 			}
 		} else {
 			if (fmv18x_probe_list[inb(ioaddr + IOCONFIG) & 0x07] != ioaddr)
-				goto err_mca;
+				goto err_out;
 			irq = fmv_irqmap[(inb(ioaddr + IOCONFIG)>>6) & 0x03];
 		}
 	}
@@ -464,23 +362,17 @@ found:
 	spin_lock_init(&lp->lock);
 
 	lp->jumpered = is_fmv18x;
-	lp->mca_slot = slot;
 	/* Snarf the interrupt vector now. */
 	ret = request_irq(irq, net_interrupt, 0, DRV_NAME, dev);
 	if (ret) {
 		printk(KERN_ERR "AT1700 at %#3x is unusable due to a "
 		       "conflict on IRQ %d.\n",
 		       ioaddr, irq);
-		goto err_mca;
+		goto err_out;
 	}
 
 	return 0;
 
-err_mca:
-#ifdef CONFIG_MCA_LEGACY
-	if (slot >= 0)
-		mca_mark_as_unused(slot);
-#endif
 err_out:
 	release_region(ioaddr, AT1700_IO_EXTENT);
 	return ret;
diff --git a/drivers/net/ethernet/i825xx/3c523.c b/drivers/net/ethernet/i825xx/3c523.c
deleted file mode 100644
index 8451ecd..0000000
diff --git a/drivers/net/ethernet/i825xx/3c523.h b/drivers/net/ethernet/i825xx/3c523.h
deleted file mode 100644
index 6956441..0000000
diff --git a/drivers/net/ethernet/i825xx/3c527.c b/drivers/net/ethernet/i825xx/3c527.c
deleted file mode 100644
index 278e791..0000000
diff --git a/drivers/net/ethernet/i825xx/Kconfig b/drivers/net/ethernet/i825xx/Kconfig
index ca1ae98..fed5080 100644
--- a/drivers/net/ethernet/i825xx/Kconfig
+++ b/drivers/net/ethernet/i825xx/Kconfig
@@ -43,28 +43,6 @@ config EL16
 	  To compile this driver as a module, choose M here. The module
 	  will be called 3c507.
 
-config ELMC
-	tristate "3c523 \"EtherLink/MC\" support"
-	depends on MCA_LEGACY
-	---help---
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called 3c523.
-
-config ELMC_II
-	tristate "3c527 \"EtherLink/MC 32\" support (EXPERIMENTAL)"
-	depends on MCA && MCA_LEGACY
-	---help---
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called 3c527.
-
 config ARM_ETHER1
 	tristate "Acorn Ether1 support"
 	depends on ARM && ARCH_ACORN
diff --git a/drivers/net/ethernet/i825xx/Makefile b/drivers/net/ethernet/i825xx/Makefile
index f68a369..6adff85 100644
--- a/drivers/net/ethernet/i825xx/Makefile
+++ b/drivers/net/ethernet/i825xx/Makefile
@@ -7,8 +7,6 @@ obj-$(CONFIG_EEXPRESS) += eexpress.o
 obj-$(CONFIG_EEXPRESS_PRO) += eepro.o
 obj-$(CONFIG_ELPLUS) += 3c505.o
 obj-$(CONFIG_EL16) += 3c507.o
-obj-$(CONFIG_ELMC) += 3c523.o
-obj-$(CONFIG_ELMC_II) += 3c527.o
 obj-$(CONFIG_LP486E) += lp486e.o
 obj-$(CONFIG_NI52) += ni52.o
 obj-$(CONFIG_SUN3_82586) += sun3_82586.o
diff --git a/drivers/net/ethernet/i825xx/eexpress.c b/drivers/net/ethernet/i825xx/eexpress.c
index cc2e66a..7a6a2f0 100644
--- a/drivers/net/ethernet/i825xx/eexpress.c
+++ b/drivers/net/ethernet/i825xx/eexpress.c
@@ -9,7 +9,7 @@
  * Many modifications, and currently maintained, by
  *  Philip Blundell <philb@gnu.org>
  * Added the Compaq LTE  Alan Cox <alan@lxorguk.ukuu.org.uk>
- * Added MCA support Adam Fritzler
+ * Added MCA support Adam Fritzler (now deleted)
  *
  * Note - this driver is experimental still - it has problems on faster
  * machines. Someone needs to sit down and go through it line by line with
@@ -111,7 +111,6 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
-#include <linux/mca-legacy.h>
 #include <linux/spinlock.h>
 #include <linux/bitops.h>
 #include <linux/jiffies.h>
@@ -227,16 +226,6 @@ static unsigned short start_code[] = {
 /* maps irq number to EtherExpress magic value */
 static char irqrmap[] = { 0,0,1,2,3,4,0,0,0,1,5,6,0,0,0,0 };
 
-#ifdef CONFIG_MCA_LEGACY
-/* mapping of the first four bits of the second POS register */
-static unsigned short mca_iomap[] = {
-	0x270, 0x260, 0x250, 0x240, 0x230, 0x220, 0x210, 0x200,
-	0x370, 0x360, 0x350, 0x340, 0x330, 0x320, 0x310, 0x300
-};
-/* bits 5-7 of the second POS register */
-static char mca_irqmap[] = { 12, 9, 3, 4, 5, 10, 11, 15 };
-#endif
-
 /*
  * Prototypes for Linux interface
  */
@@ -340,53 +329,6 @@ static int __init do_express_probe(struct net_device *dev)
 
 	dev->if_port = 0xff; /* not set */
 
-#ifdef CONFIG_MCA_LEGACY
-	if (MCA_bus) {
-		int slot = 0;
-
-		/*
-		 * Only find one card at a time.  Subsequent calls
-		 * will find others, however, proper multicard MCA
-		 * probing and setup can't be done with the
-		 * old-style Space.c init routines.  -- ASF
-		 */
-		while (slot != MCA_NOTFOUND) {
-			int pos0, pos1;
-
-			slot = mca_find_unused_adapter(0x628B, slot);
-			if (slot == MCA_NOTFOUND)
-				break;
-
-			pos0 = mca_read_stored_pos(slot, 2);
-			pos1 = mca_read_stored_pos(slot, 3);
-			ioaddr = mca_iomap[pos1&0xf];
-
-			dev->irq = mca_irqmap[(pos1>>4)&0x7];
-
-			/*
-			 * XXX: Transceiver selection is done
-			 * differently on the MCA version.
-			 * How to get it to select something
-			 * other than external/AUI is currently
-			 * unknown.  This code is just for looks. -- ASF
-			 */
-			if ((pos0 & 0x7) == 0x1)
-				dev->if_port = AUI;
-			else if ((pos0 & 0x7) == 0x5) {
-				if (pos1 & 0x80)
-					dev->if_port = BNC;
-				else
-					dev->if_port = TPE;
-			}
-
-			mca_set_adapter_name(slot, "Intel EtherExpress 16 MCA");
-			mca_set_adapter_procfn(slot, NULL, dev);
-			mca_mark_as_used(slot);
-
-			break;
-		}
-	}
-#endif
 	if (ioaddr&0xfe00) {
 		if (!request_region(ioaddr, EEXP_IO_EXTENT, "EtherExpress"))
 			return -EBUSY;
diff --git a/drivers/net/ethernet/natsemi/Kconfig b/drivers/net/ethernet/natsemi/Kconfig
index eb836f7..f157334 100644
--- a/drivers/net/ethernet/natsemi/Kconfig
+++ b/drivers/net/ethernet/natsemi/Kconfig
@@ -6,9 +6,8 @@ config NET_VENDOR_NATSEMI
 	bool "National Semi-conductor devices"
 	default y
 	depends on AMIGA_PCMCIA || ARM || EISA || EXPERIMENTAL || H8300 || \
-		   ISA || M32R || MAC || MACH_JAZZ || MACH_TX49XX || MCA || \
-		   MCA_LEGACY || MIPS || PCI || PCMCIA || SUPERH || \
-		   XTENSA_PLATFORM_XT2000 || ZORRO
+		   ISA || M32R || MAC || MACH_JAZZ || MACH_TX49XX || MIPS || \
+		   PCI || PCMCIA || SUPERH || XTENSA_PLATFORM_XT2000 || ZORRO
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
 	  and read the Ethernet-HOWTO, available from
@@ -21,21 +20,6 @@ config NET_VENDOR_NATSEMI
 
 if NET_VENDOR_NATSEMI
 
-config IBMLANA
-	tristate "IBM LAN Adapter/A support"
-	depends on MCA
-	---help---
-	  This is a Micro Channel Ethernet adapter.  You need to set
-	  CONFIG_MCA to use this driver.  It is both available as an in-kernel
-	  driver and as a module.
-
-	  To compile this driver as a module, choose M here. The only
-	  currently supported card is the IBM LAN Adapter/A for Ethernet.  It
-	  will both support 16K and 32K memory windows, however a 32K window
-	  gives a better security against packet losses.  Usage of multiple
-	  boards with this driver should be possible, but has not been tested
-	  up to now due to lack of hardware.
-
 config MACSONIC
 	tristate "Macintosh SONIC based ethernet (onboard, NuBus, LC, CS)"
 	depends on MAC
diff --git a/drivers/net/ethernet/natsemi/Makefile b/drivers/net/ethernet/natsemi/Makefile
index 9aa5dea..764c532 100644
--- a/drivers/net/ethernet/natsemi/Makefile
+++ b/drivers/net/ethernet/natsemi/Makefile
@@ -2,7 +2,6 @@
 # Makefile for the National Semi-conductor Sonic devices.
 #
 
-obj-$(CONFIG_IBMLANA) += ibmlana.o
 obj-$(CONFIG_MACSONIC) += macsonic.o
 obj-$(CONFIG_MIPS_JAZZ_SONIC) += jazzsonic.o
 obj-$(CONFIG_NATSEMI) += natsemi.o
-- 
1.7.9.1
