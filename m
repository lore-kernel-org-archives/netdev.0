From: Jeff Garzik <jgarzik@pobox.com>
Subject: [BK PATCHES] 2.6.x net driver updates
Date: Tue, 11 Jan 2005 00:01:44 -0500
Message-ID: <41E35DB8.3090004@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090609000705090202000403"
Cc: Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090609000705090202000403
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit


gcc 4 fixes, driver updates: ixgb, eepro, emac, ...



--------------090609000705090202000403
Content-Type: text/plain;
 name="changelog.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="changelog.txt"

Please do a

	bk pull bk://gkernel.bkbits.net/net-drivers-2.6

This will update the following files:

 drivers/net/arcnet/arcnet.c          |    3 
 drivers/net/eepro.c                  |  144 +++++--
 drivers/net/ibm_emac/ibm_emac.h      |    2 
 drivers/net/ibm_emac/ibm_emac_core.c |   15 
 drivers/net/ibm_emac/ibm_emac_phy.c  |   19 
 drivers/net/ixgb/ixgb.h              |   25 +
 drivers/net/ixgb/ixgb_ee.c           |  192 +++++----
 drivers/net/ixgb/ixgb_ethtool.c      |  518 ++++++++++++++++---------
 drivers/net/ixgb/ixgb_hw.c           |  231 ++++++-----
 drivers/net/ixgb/ixgb_hw.h           |   50 +-
 drivers/net/ixgb/ixgb_ids.h          |   21 -
 drivers/net/ixgb/ixgb_main.c         |  705 +++++++++++++++++------------------
 drivers/net/ixgb/ixgb_osdep.h        |   10 
 drivers/net/ixgb/ixgb_param.c        |  316 +++++++--------
 drivers/net/s2io.c                   |   22 -
 drivers/net/s2io.h                   |    4 
 drivers/net/smc-ultra.c              |    2 
 drivers/net/smc91x.c                 |   16 
 drivers/net/wireless/orinoco.c       |  203 +++-------
 drivers/net/wireless/wl3501_cs.c     |    4 
 include/linux/arcdevice.h            |    1 
 21 files changed, 1415 insertions(+), 1088 deletions(-)

through these ChangeSets:

Andi Kleen:
  o Fix gcc4 compilation in s2io net driver

Aristeu Sergio Rozanski Filho:
  o eepro: fix auto-detection option
  o eepro: fix return value in init_module()
  o eepro: basic ethtool support
  o eepro: use module_param macros
  o eepro: cache EEPROM values

Christoph Hellwig:
  o mark arcdev_setup static

David Gibson:
  o Another trivial orinoco update

Ganesh Venkatesan:
  o ixgb: White space corrections
  o ixgb: Driver version number update
  o ixgb: Support for 2.6.x style module parameters
  o ixgb: Fix Tx cleanup logic
  o ixgb: Shrink size and fix ordering of elements in ixgb_buffer
  o ixgb: ethtool_ops support
  o ixgb: Replace kmalloc with vmalloc (one time alloc)
  o ixgb: Remove support for RAIDC interrupt mitigation
  o ixgb: Limit Rx Address Filter Array entries to 3
  o ixgb: Fix infinite loop trying to re-establish link
  o ixgb: Fix error in setting MFS register
  o ixgb: Poll Routine cleanup
  o ixgb: Fix memory leak in NAPI mode
  o ixgb: Fix VLAN filter setup errors (while running on PPC)
  o ixgb: Add support for 10GbE LR device ID
  o ixgb: Enable Message Signalled Interrupts
  o ixgb: Limit number of Rx Descriptors to 512

Hirokazu Takata:
  o net: netconsole support for smc91x

Matt Porter:
  o Add netpoll support
  o allow rx of the maximum sized VLAN tagged packets
  o EMAC: fix ibm_emac autonegotiation result parsing

Paul Gortmaker:
  o smc-ultra.c too-verbose driver

Raghavendra Koushik:
  o S2io: fixes in free_shared_mem function

Randy Dunlap:
  o wl3501: fix module_param types/warnings


--------------090609000705090202000403
Content-Type: text/plain;
 name="patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch"

diff -Nru a/drivers/net/arcnet/arcnet.c b/drivers/net/arcnet/arcnet.c
--- a/drivers/net/arcnet/arcnet.c	2005-01-10 23:54:12 -05:00
+++ b/drivers/net/arcnet/arcnet.c	2005-01-10 23:54:12 -05:00
@@ -93,7 +93,6 @@
 EXPORT_SYMBOL(arc_proto_null);
 EXPORT_SYMBOL(arcnet_unregister_proto);
 EXPORT_SYMBOL(arcnet_debug);
-EXPORT_SYMBOL(arcdev_setup);
 EXPORT_SYMBOL(alloc_arcdev);
 EXPORT_SYMBOL(arcnet_interrupt);
 
@@ -317,7 +316,7 @@
 
 
 /* Setup a struct device for ARCnet. */
-void arcdev_setup(struct net_device *dev)
+static void arcdev_setup(struct net_device *dev)
 {
 	dev->type = ARPHRD_ARCNET;
 	dev->hard_header_len = sizeof(struct archdr);
diff -Nru a/drivers/net/eepro.c b/drivers/net/eepro.c
--- a/drivers/net/eepro.c	2005-01-10 23:54:12 -05:00
+++ b/drivers/net/eepro.c	2005-01-10 23:54:12 -05:00
@@ -23,6 +23,7 @@
 	This is a compatibility hardware problem.
 
 	Versions:
+	0.13b	basic ethtool support (aris, 09/13/2004)
 	0.13a   in memory shortage, drop packets also in board
 		(Michael Westermann <mw@microdata-pos.de>, 07/30/2002)
 	0.13    irq sharing, rewrote probe function, fixed a nasty bug in
@@ -104,7 +105,7 @@
 */
 
 static const char version[] =
-	"eepro.c: v0.13 11/08/2001 aris@cathedrallabs.org\n";
+	"eepro.c: v0.13b 09/13/2004 aris@cathedrallabs.org\n";
 
 #include <linux/module.h>
 
@@ -146,19 +147,21 @@
 #include <linux/init.h>
 #include <linux/delay.h>
 #include <linux/bitops.h>
+#include <linux/ethtool.h>
 
 #include <asm/system.h>
 #include <asm/io.h>
 #include <asm/dma.h>
 
 #define DRV_NAME "eepro"
+#define DRV_VERSION "0.13b"
 
 #define compat_dev_kfree_skb( skb, mode ) dev_kfree_skb( (skb) )
 /* I had reports of looong delays with SLOW_DOWN defined as udelay(2) */
 #define SLOW_DOWN inb(0x80)
 /* udelay(2) */
 #define compat_init_data     __initdata
-
+enum iftype { AUI=0, BNC=1, TPE=2 };
 
 /* First, a few definitions that the brave might change. */
 /* A zero-terminated list of I/O addresses to be probed. */
@@ -214,6 +217,7 @@
 	short rcv_lower_limit;
 	short rcv_upper_limit;
 	unsigned char eeprom_reg;
+	unsigned short word[8];
 };
 
 /* The station (ethernet) address prefix, used for IDing the board. */
@@ -608,16 +612,22 @@
 }
 #endif
 
-static void __init printEEPROMInfo(short ioaddr, struct net_device *dev)
+static void __init printEEPROMInfo(struct net_device *dev)
 {
+	struct eepro_local *lp = (struct eepro_local *)dev->priv;
+	int ioaddr = dev->base_addr;
 	unsigned short Word;
 	int i,j;
 
-	for (i=0, j=ee_Checksum; i<ee_SIZE; i++)
-		j+=read_eeprom(ioaddr,i,dev);
+	j = ee_Checksum;
+	for (i = 0; i < 8; i++)
+		j += lp->word[i];
+	for ( ; i < ee_SIZE; i++)
+		j += read_eeprom(ioaddr, i, dev);
+
 	printk(KERN_DEBUG "Checksum: %#x\n",j&0xffff);
 
-	Word=read_eeprom(ioaddr, 0, dev);
+	Word = lp->word[0];
 	printk(KERN_DEBUG "Word0:\n");
 	printk(KERN_DEBUG " Plug 'n Pray: %d\n",GetBit(Word,ee_PnP));
 	printk(KERN_DEBUG " Buswidth: %d\n",(GetBit(Word,ee_BusWidth)+1)*8 );
@@ -625,7 +635,7 @@
 	printk(KERN_DEBUG " IO Address: %#x\n", (Word>>ee_IO0)<<4);
 
 	if (net_debug>4)  {
-		Word=read_eeprom(ioaddr, 1, dev);
+		Word = lp->word[1];
 		printk(KERN_DEBUG "Word1:\n");
 		printk(KERN_DEBUG " INT: %d\n", Word & ee_IntMask);
 		printk(KERN_DEBUG " LI: %d\n", GetBit(Word,ee_LI));
@@ -636,7 +646,7 @@
 		printk(KERN_DEBUG " Duplex: %d\n", GetBit(Word,ee_Duplex));
 	}
 
-	Word=read_eeprom(ioaddr, 5, dev);
+	Word = lp->word[5];
 	printk(KERN_DEBUG "Word5:\n");
 	printk(KERN_DEBUG " BNC: %d\n",GetBit(Word,ee_BNC_TPE));
 	printk(KERN_DEBUG " NumConnectors: %d\n",GetBit(Word,ee_NumConn));
@@ -646,12 +656,12 @@
 	if (GetBit(Word,ee_PortAUI)) printk(KERN_DEBUG "AUI ");
 	printk(KERN_DEBUG "port(s) \n");
 
-	Word=read_eeprom(ioaddr, 6, dev);
+	Word = lp->word[6];
 	printk(KERN_DEBUG "Word6:\n");
 	printk(KERN_DEBUG " Stepping: %d\n",Word & ee_StepMask);
 	printk(KERN_DEBUG " BoardID: %d\n",Word>>ee_BoardID);
 
-	Word=read_eeprom(ioaddr, 7, dev);
+	Word = lp->word[7];
 	printk(KERN_DEBUG "Word7:\n");
 	printk(KERN_DEBUG " INT to IRQ:\n");
 
@@ -725,7 +735,7 @@
 		printk(", %s.\n", ifmap[dev->if_port]);
 
 	if (net_debug > 3) {
-		i = read_eeprom(dev->base_addr, 5, dev);
+		i = lp->word[5];
 		if (i & 0x2000) /* bit 13 of EEPROM word 5 */
 			printk(KERN_DEBUG "%s: Concurrent Processing is "
 				"enabled but not used!\n", dev->name);
@@ -733,19 +743,20 @@
 
 	/* Check the station address for the manufacturer's code */
 	if (net_debug>3)
-		printEEPROMInfo(dev->base_addr, dev);
+		printEEPROMInfo(dev);
 }
 
+static struct ethtool_ops eepro_ethtool_ops;
+
 /* This is the real probe routine.  Linux has a history of friendly device
    probes on the ISA bus.  A good device probe avoids doing writes, and
    verifies that the correct device exists and functions.  */
 
 static int __init eepro_probe1(struct net_device *dev, int autoprobe)
 {
-	unsigned short station_addr[6], id, counter;
+	unsigned short station_addr[3], id, counter;
 	int i;
 	struct eepro_local *lp;
-	enum iftype { AUI=0, BNC=1, TPE=2 };
 	int ioaddr = dev->base_addr;
 
 	/* Grab the region so we can find another board if autoIRQ fails. */
@@ -796,11 +807,16 @@
 		lp->xmt_bar = XMT_BAR_10;
 		station_addr[0] = read_eeprom(ioaddr, 2, dev);
 	}
-	station_addr[1] = read_eeprom(ioaddr, 3, dev);
-	station_addr[2] = read_eeprom(ioaddr, 4, dev);
+
+	/* get all words at once. will be used here and for ethtool */
+	for (i = 0; i < 8; i++) {
+		lp->word[i] = read_eeprom(ioaddr, i, dev);
+	}
+	station_addr[1] = lp->word[3];
+	station_addr[2] = lp->word[4];
 
 	if (!lp->eepro) {
-		if (read_eeprom(ioaddr,7,dev)== ee_FX_INT2IRQ)
+		if (lp->word[7] == ee_FX_INT2IRQ)
 			lp->eepro = 2;
 		else if (station_addr[2] == SA_ADDR1)
 			lp->eepro = 1;
@@ -817,15 +833,15 @@
 	/* calculate {xmt,rcv}_{lower,upper}_limit */
 	eepro_recalc(dev);
 
-	if (GetBit( read_eeprom(ioaddr, 5, dev),ee_BNC_TPE))
+	if (GetBit(lp->word[5], ee_BNC_TPE))
 		dev->if_port = BNC;
 	else
 		dev->if_port = TPE;
 
  	if (dev->irq < 2 && lp->eepro != 0) {
  		/* Mask off INT number */
- 		int count = read_eeprom(ioaddr, 1, dev) & 7;
- 		unsigned irqMask = read_eeprom(ioaddr, 7, dev);
+ 		int count = lp->word[1] & 7;
+ 		unsigned irqMask = lp->word[7];
  
  		while (count--)
  			irqMask &= irqMask - 1;
@@ -850,6 +866,7 @@
  	dev->set_multicast_list = &set_multicast_list;
  	dev->tx_timeout		= eepro_tx_timeout;
  	dev->watchdog_timeo	= TX_TIMEOUT;
+	dev->ethtool_ops	= &eepro_ethtool_ops;
  
 	/* print boot time info */
 	eepro_print_info(dev);
@@ -941,7 +958,7 @@
 	if (net_debug > 3)
 		printk(KERN_DEBUG "%s: entering eepro_open routine.\n", dev->name);
 
-	irqMask = read_eeprom(ioaddr,7,dev);
+	irqMask = lp->word[7];
 
 	if (lp->eepro == LAN595FX_10ISA) {
 		if (net_debug > 3) printk(KERN_DEBUG "p->eepro = 3;\n");
@@ -1070,8 +1087,6 @@
 		old9 = inb(ioaddr + 9);
 
 		if (irqMask==ee_FX_INT2IRQ) {
-			enum iftype { AUI=0, BNC=1, TPE=2 };
-
 			if (net_debug > 3) {
 				printk(KERN_DEBUG "IrqMask: %#x\n",irqMask);
 				printk(KERN_DEBUG "i82595FX detected!\n");
@@ -1701,12 +1716,72 @@
 	}
 }
 
+static int eepro_ethtool_get_settings(struct net_device *dev,
+					struct ethtool_cmd *cmd)
+{
+	struct eepro_local	*lp = (struct eepro_local *)dev->priv;
+
+	cmd->supported = 	SUPPORTED_10baseT_Half | 
+				SUPPORTED_10baseT_Full |
+				SUPPORTED_Autoneg;
+	cmd->advertising =	ADVERTISED_10baseT_Half |
+				ADVERTISED_10baseT_Full |
+				ADVERTISED_Autoneg;
+
+	if (GetBit(lp->word[5], ee_PortTPE)) {
+		cmd->supported |= SUPPORTED_TP;
+		cmd->advertising |= ADVERTISED_TP;
+	}
+	if (GetBit(lp->word[5], ee_PortBNC)) {
+		cmd->supported |= SUPPORTED_BNC;
+		cmd->advertising |= ADVERTISED_BNC;
+	}
+	if (GetBit(lp->word[5], ee_PortAUI)) {
+		cmd->supported |= SUPPORTED_AUI;
+		cmd->advertising |= ADVERTISED_AUI;
+	}
+
+	cmd->speed = SPEED_10;
+
+	if (dev->if_port == TPE && lp->word[1] & ee_Duplex) {
+		cmd->duplex = DUPLEX_FULL;
+	}
+	else {
+		cmd->duplex = DUPLEX_HALF;
+	}
+
+	cmd->port = dev->if_port;
+	cmd->phy_address = dev->base_addr;
+	cmd->transceiver = XCVR_INTERNAL;
+
+	if (lp->word[0] & ee_AutoNeg) {
+		cmd->autoneg = 1;
+	}
+
+	return 0;
+}
+
+static void eepro_ethtool_get_drvinfo(struct net_device *dev,
+					struct ethtool_drvinfo *drvinfo)
+{
+	strcpy(drvinfo->driver, DRV_NAME);
+	strcpy(drvinfo->version, DRV_VERSION);
+	sprintf(drvinfo->bus_info, "ISA 0x%lx", dev->base_addr);
+}
+
+static struct ethtool_ops eepro_ethtool_ops = {
+	.get_settings	= eepro_ethtool_get_settings,
+	.get_drvinfo 	= eepro_ethtool_get_drvinfo,
+};
+
 #ifdef MODULE
 
 #define MAX_EEPRO 8
 static struct net_device *dev_eepro[MAX_EEPRO];
 
-static int io[MAX_EEPRO];
+static int io[MAX_EEPRO] = {
+  [0 ... MAX_EEPRO-1] = -1
+};
 static int irq[MAX_EEPRO];
 static int mem[MAX_EEPRO] = {	/* Size of the rx buffer in KB */
   [0 ... MAX_EEPRO-1] = RCV_DEFAULT_RAM/1024
@@ -1716,14 +1791,15 @@
 static int n_eepro;
 /* For linux 2.1.xx */
 
-MODULE_AUTHOR("Pascal Dupuis, and aris@cathedrallabs.org");
+MODULE_AUTHOR("Pascal Dupuis and others");
 MODULE_DESCRIPTION("Intel i82595 ISA EtherExpressPro10/10+ driver");
 MODULE_LICENSE("GPL");
 
-MODULE_PARM(io, "1-" __MODULE_STRING(MAX_EEPRO) "i");
-MODULE_PARM(irq, "1-" __MODULE_STRING(MAX_EEPRO) "i");
-MODULE_PARM(mem, "1-" __MODULE_STRING(MAX_EEPRO) "i");
-MODULE_PARM(autodetect, "1-" __MODULE_STRING(1) "i");
+static int num_params;
+module_param_array(io, int, num_params, 0);
+module_param_array(irq, int, num_params, 0);
+module_param_array(mem, int, num_params, 0);
+module_param(autodetect, int, 0);
 MODULE_PARM_DESC(io, "EtherExpress Pro/10 I/O base addres(es)");
 MODULE_PARM_DESC(irq, "EtherExpress Pro/10 IRQ number(s)");
 MODULE_PARM_DESC(mem, "EtherExpress Pro/10 Rx buffer size(es) in kB (3-29)");
@@ -1734,19 +1810,21 @@
 {
 	struct net_device *dev;
 	int i;
-	if (io[0] == 0 && autodetect == 0) {
+	if (io[0] == -1 && autodetect == 0) {
 		printk(KERN_WARNING "eepro_init_module: Probe is very dangerous in ISA boards!\n");
 		printk(KERN_WARNING "eepro_init_module: Please add \"autodetect=1\" to force probe\n");
-		return 1;
+		return -ENODEV;
 	}
 	else if (autodetect) {
 		/* if autodetect is set then we must force detection */
-		io[0] = 0;
+		for (i = 0; i < MAX_EEPRO; i++) {
+			io[i] = 0;
+		}
 
 		printk(KERN_INFO "eepro_init_module: Auto-detecting boards (May God protect us...)\n");
 	}
 
-	for (i = 0; i < MAX_EEPRO; i++) {
+	for (i = 0; io[i] != -1 && i < MAX_EEPRO; i++) {
 		dev = alloc_etherdev(sizeof(struct eepro_local));
 		if (!dev)
 			break;
diff -Nru a/drivers/net/ibm_emac/ibm_emac.h b/drivers/net/ibm_emac/ibm_emac.h
--- a/drivers/net/ibm_emac/ibm_emac.h	2005-01-10 23:54:12 -05:00
+++ b/drivers/net/ibm_emac/ibm_emac.h	2005-01-10 23:54:12 -05:00
@@ -98,7 +98,7 @@
 #endif				/* CONFIG_IBM_EMAC4 */
 #define EMAC_M1_BASE			(EMAC_M1_TX_FIFO_2K | \
 					EMAC_M1_APP | \
-					EMAC_M1_TR)
+					EMAC_M1_TR | EMAC_M1_VLE)
 
 /* Transmit Mode Register 0 */
 #define EMAC_TMR0_GNP0			0x80000000
diff -Nru a/drivers/net/ibm_emac/ibm_emac_core.c b/drivers/net/ibm_emac/ibm_emac_core.c
--- a/drivers/net/ibm_emac/ibm_emac_core.c	2005-01-10 23:54:12 -05:00
+++ b/drivers/net/ibm_emac/ibm_emac_core.c	2005-01-10 23:54:12 -05:00
@@ -1363,6 +1363,9 @@
 
 	/* set frame gap */
 	out_be32(&emacp->em0ipgvr, CONFIG_IBM_EMAC_FGAP);
+	
+	/* set VLAN Tag Protocol Identifier */
+	out_be32(&emacp->em0vtpid, 0x8100);
 
 	/* Init ring buffers */
 	emac_init_rings(fep->ndev);
@@ -1700,6 +1703,15 @@
 	.rxde = &emac_rxde_dev,
 };
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static int emac_netpoll(struct net_device *ndev)
+{
+	emac_rxeob_dev((void *)ndev, 0);
+	emac_txeob_dev((void *)ndev, 0);
+	return 0;
+}
+#endif
+
 static int emac_init_device(struct ocp_device *ocpdev, struct ibm_ocp_mal *mal)
 {
 	int deferred_init = 0;
@@ -1882,6 +1894,9 @@
 	SET_ETHTOOL_OPS(ndev, &emac_ethtool_ops);
 	if (emacdata->tah_idx >= 0)
 		ndev->features = NETIF_F_IP_CSUM | NETIF_F_SG;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	ndev->poll_controller = emac_netpoll;
+#endif
 
 	SET_MODULE_OWNER(ndev);
 
diff -Nru a/drivers/net/ibm_emac/ibm_emac_phy.c b/drivers/net/ibm_emac/ibm_emac_phy.c
--- a/drivers/net/ibm_emac/ibm_emac_phy.c	2005-01-10 23:54:12 -05:00
+++ b/drivers/net/ibm_emac/ibm_emac_phy.c	2005-01-10 23:54:12 -05:00
@@ -191,17 +191,18 @@
 	u16 lpa;
 
 	if (phy->autoneg) {
-		lpa = phy_read(phy, MII_LPA);
+		lpa = phy_read(phy, MII_LPA) & phy_read(phy, MII_ADVERTISE);
 
-		if (lpa & (LPA_10FULL | LPA_100FULL))
-			phy->duplex = DUPLEX_FULL;
-		else
-			phy->duplex = DUPLEX_HALF;
-		if (lpa & (LPA_100FULL | LPA_100HALF))
-			phy->speed = SPEED_100;
-		else
-			phy->speed = SPEED_10;
+		phy->speed = SPEED_10;
+		phy->duplex = DUPLEX_HALF;
 		phy->pause = 0;
+
+		if (lpa & (LPA_100FULL | LPA_100HALF)) {
+			phy->speed = SPEED_100;
+			if (lpa & LPA_100FULL)
+				phy->duplex = DUPLEX_FULL;
+		} else if (lpa & LPA_10FULL)
+			phy->duplex = DUPLEX_FULL;
 	}
 	/* On non-aneg, we assume what we put in BMCR is the speed,
 	 * though magic-aneg shouldn't prevent this case from occurring
diff -Nru a/drivers/net/ixgb/ixgb.h b/drivers/net/ixgb/ixgb.h
--- a/drivers/net/ixgb/ixgb.h	2005-01-10 23:54:12 -05:00
+++ b/drivers/net/ixgb/ixgb.h	2005-01-10 23:54:12 -05:00
@@ -46,6 +46,7 @@
 #include <linux/delay.h>
 #include <linux/timer.h>
 #include <linux/slab.h>
+#include <linux/vmalloc.h>
 #include <linux/interrupt.h>
 #include <linux/string.h>
 #include <linux/pagemap.h>
@@ -85,6 +86,20 @@
 
 #define IXGB_ERR(args...) printk(KERN_ERR "ixgb: " args)
 
+/* TX/RX descriptor defines */
+#define DEFAULT_TXD	 256
+#define MAX_TXD   	4096
+#define MIN_TXD	  64
+
+/* hardware cannot reliably support more than 512 descriptors owned by
+ * hardware descrioptor cache otherwise an unreliable ring under heavy 
+ * recieve load may result */
+/* #define DEFAULT_RXD	   1024 */
+/* #define MAX_RXD	   4096 */
+#define DEFAULT_RXD	512
+#define MAX_RXD	512
+#define MIN_RXD	 64
+
 /* Supported Rx Buffer Sizes */
 #define IXGB_RXBUFFER_2048  2048
 #define IXGB_RXBUFFER_4096  4096
@@ -105,9 +120,9 @@
 struct ixgb_buffer {
 	struct sk_buff *skb;
 	uint64_t dma;
-	unsigned long length;
 	unsigned long time_stamp;
-	unsigned int next_to_watch;
+	uint16_t length;
+	uint16_t next_to_watch;
 };
 
 struct ixgb_desc_ring {
@@ -167,7 +182,6 @@
 	uint64_t hw_csum_rx_error;
 	uint64_t hw_csum_rx_good;
 	uint32_t rx_int_delay;
-	boolean_t raidc;
 	boolean_t rx_csum;
 
 	/* OS defined structs */
@@ -178,5 +192,8 @@
 	/* structs defined in ixgb_hw.h */
 	struct ixgb_hw hw;
 	struct ixgb_hw_stats stats;
+#ifdef CONFIG_PCI_MSI
+	boolean_t have_msi;
+#endif
 };
-#endif				/* _IXGB_H_ */
+#endif /* _IXGB_H_ */
diff -Nru a/drivers/net/ixgb/ixgb_ee.c b/drivers/net/ixgb/ixgb_ee.c
--- a/drivers/net/ixgb/ixgb_ee.c	2005-01-10 23:54:12 -05:00
+++ b/drivers/net/ixgb/ixgb_ee.c	2005-01-10 23:54:12 -05:00
@@ -32,7 +32,8 @@
 static uint16_t ixgb_shift_in_bits(struct ixgb_hw *hw);
 
 static void ixgb_shift_out_bits(struct ixgb_hw *hw,
-				uint16_t data, uint16_t count);
+				uint16_t data,
+				uint16_t count);
 static void ixgb_standby_eeprom(struct ixgb_hw *hw);
 
 static boolean_t ixgb_wait_eeprom_command(struct ixgb_hw *hw);
@@ -45,7 +46,9 @@
  * hw - Struct containing variables accessed by shared code
  * eecd_reg - EECD's current value
  *****************************************************************************/
-static void ixgb_raise_clock(struct ixgb_hw *hw, uint32_t * eecd_reg)
+static void
+ixgb_raise_clock(struct ixgb_hw *hw,
+		  uint32_t *eecd_reg)
 {
 	/* Raise the clock input to the EEPROM (by setting the SK bit), and then
 	 *  wait 50 microseconds.
@@ -62,7 +65,9 @@
  * hw - Struct containing variables accessed by shared code
  * eecd_reg - EECD's current value
  *****************************************************************************/
-static void ixgb_lower_clock(struct ixgb_hw *hw, uint32_t * eecd_reg)
+static void
+ixgb_lower_clock(struct ixgb_hw *hw,
+		  uint32_t *eecd_reg)
 {
 	/* Lower the clock input to the EEPROM (by clearing the SK bit), and then
 	 * wait 50 microseconds.
@@ -81,7 +86,9 @@
  * count - number of bits to shift out
  *****************************************************************************/
 static void
-ixgb_shift_out_bits(struct ixgb_hw *hw, uint16_t data, uint16_t count)
+ixgb_shift_out_bits(struct ixgb_hw *hw,
+					 uint16_t data,
+					 uint16_t count)
 {
 	uint32_t eecd_reg;
 	uint32_t mask;
@@ -101,7 +108,7 @@
 		 */
 		eecd_reg &= ~IXGB_EECD_DI;
 
-		if (data & mask)
+		if(data & mask)
 			eecd_reg |= IXGB_EECD_DI;
 
 		IXGB_WRITE_REG(hw, EECD, eecd_reg);
@@ -113,7 +120,7 @@
 
 		mask = mask >> 1;
 
-	} while (mask);
+	} while(mask);
 
 	/* We leave the "DI" bit set to "0" when we leave this routine. */
 	eecd_reg &= ~IXGB_EECD_DI;
@@ -126,7 +133,8 @@
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-static uint16_t ixgb_shift_in_bits(struct ixgb_hw *hw)
+static uint16_t
+ixgb_shift_in_bits(struct ixgb_hw *hw)
 {
 	uint32_t eecd_reg;
 	uint32_t i;
@@ -144,14 +152,14 @@
 	eecd_reg &= ~(IXGB_EECD_DO | IXGB_EECD_DI);
 	data = 0;
 
-	for (i = 0; i < 16; i++) {
+	for(i = 0; i < 16; i++) {
 		data = data << 1;
 		ixgb_raise_clock(hw, &eecd_reg);
 
 		eecd_reg = IXGB_READ_REG(hw, EECD);
 
 		eecd_reg &= ~(IXGB_EECD_DI);
-		if (eecd_reg & IXGB_EECD_DO)
+		if(eecd_reg & IXGB_EECD_DO)
 			data |= 1;
 
 		ixgb_lower_clock(hw, &eecd_reg);
@@ -168,7 +176,8 @@
  * Lowers EEPROM clock. Clears input pin. Sets the chip select pin. This
  * function should be called before issuing a command to the EEPROM.
  *****************************************************************************/
-static void ixgb_setup_eeprom(struct ixgb_hw *hw)
+static void
+ixgb_setup_eeprom(struct ixgb_hw *hw)
 {
 	uint32_t eecd_reg;
 
@@ -189,7 +198,8 @@
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-static void ixgb_standby_eeprom(struct ixgb_hw *hw)
+static void
+ixgb_standby_eeprom(struct ixgb_hw *hw)
 {
 	uint32_t eecd_reg;
 
@@ -222,7 +232,8 @@
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-static void ixgb_clock_eeprom(struct ixgb_hw *hw)
+static void
+ixgb_clock_eeprom(struct ixgb_hw *hw)
 {
 	uint32_t eecd_reg;
 
@@ -245,7 +256,8 @@
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-static void ixgb_cleanup_eeprom(struct ixgb_hw *hw)
+static void
+ixgb_cleanup_eeprom(struct ixgb_hw *hw)
 {
 	uint32_t eecd_reg;
 
@@ -270,7 +282,8 @@
  *      TRUE: EEPROM data pin is high before timeout.
  *      FALSE:  Time expired.
  *****************************************************************************/
-static boolean_t ixgb_wait_eeprom_command(struct ixgb_hw *hw)
+static boolean_t
+ixgb_wait_eeprom_command(struct ixgb_hw *hw)
 {
 	uint32_t eecd_reg;
 	uint32_t i;
@@ -284,10 +297,10 @@
 	 * signal that the command has been completed by raising the DO signal.
 	 * If DO does not go high in 10 milliseconds, then error out.
 	 */
-	for (i = 0; i < 200; i++) {
+	for(i = 0; i < 200; i++) {
 		eecd_reg = IXGB_READ_REG(hw, EECD);
 
-		if (eecd_reg & IXGB_EECD_DO)
+		if(eecd_reg & IXGB_EECD_DO)
 			return (TRUE);
 
 		udelay(50);
@@ -309,15 +322,16 @@
  *  TRUE: Checksum is valid
  *  FALSE: Checksum is not valid.
  *****************************************************************************/
-boolean_t ixgb_validate_eeprom_checksum(struct ixgb_hw * hw)
+boolean_t
+ixgb_validate_eeprom_checksum(struct ixgb_hw *hw)
 {
 	uint16_t checksum = 0;
 	uint16_t i;
 
-	for (i = 0; i < (EEPROM_CHECKSUM_REG + 1); i++)
+	for(i = 0; i < (EEPROM_CHECKSUM_REG + 1); i++)
 		checksum += ixgb_read_eeprom(hw, i);
 
-	if (checksum == (uint16_t) EEPROM_SUM)
+	if(checksum == (uint16_t) EEPROM_SUM)
 		return (TRUE);
 	else
 		return (FALSE);
@@ -331,12 +345,13 @@
  * Sums the first 63 16 bit words of the EEPROM. Subtracts the sum from 0xBABA.
  * Writes the difference to word offset 63 of the EEPROM.
  *****************************************************************************/
-void ixgb_update_eeprom_checksum(struct ixgb_hw *hw)
+void
+ixgb_update_eeprom_checksum(struct ixgb_hw *hw)
 {
 	uint16_t checksum = 0;
 	uint16_t i;
 
-	for (i = 0; i < EEPROM_CHECKSUM_REG; i++)
+	for(i = 0; i < EEPROM_CHECKSUM_REG; i++)
 		checksum += ixgb_read_eeprom(hw, i);
 
 	checksum = (uint16_t) EEPROM_SUM - checksum;
@@ -356,7 +371,10 @@
  * EEPROM will most likely contain an invalid checksum.
  *
  *****************************************************************************/
-void ixgb_write_eeprom(struct ixgb_hw *hw, uint16_t offset, uint16_t data)
+void
+ixgb_write_eeprom(struct ixgb_hw *hw,
+		   uint16_t offset,
+		   uint16_t data)
 {
 	/*  Prepare the EEPROM for writing  */
 	ixgb_setup_eeprom(hw);
@@ -404,7 +422,9 @@
  * Returns:
  *  The 16-bit value read from the eeprom
  *****************************************************************************/
-uint16_t ixgb_read_eeprom(struct ixgb_hw * hw, uint16_t offset)
+uint16_t
+ixgb_read_eeprom(struct ixgb_hw *hw,
+		  uint16_t offset)
 {
 	uint16_t data;
 
@@ -437,7 +457,8 @@
  *      TRUE: if eeprom read is successful
  *      FALSE: otherwise.
  *****************************************************************************/
-boolean_t ixgb_get_eeprom_data(struct ixgb_hw * hw)
+boolean_t
+ixgb_get_eeprom_data(struct ixgb_hw *hw)
 {
 	uint16_t i;
 	uint16_t checksum = 0;
@@ -448,7 +469,7 @@
 	ee_map = (struct ixgb_ee_map_type *)hw->eeprom;
 
 	DEBUGOUT("ixgb_ee: Reading eeprom data\n");
-	for (i = 0; i < IXGB_EEPROM_SIZE; i++) {
+	for(i = 0; i < IXGB_EEPROM_SIZE ; i++) {
 		uint16_t ee_data;
 		ee_data = ixgb_read_eeprom(hw, i);
 		checksum += ee_data;
@@ -461,12 +482,12 @@
 	}
 
 	if ((ee_map->init_ctrl_reg_1 & le16_to_cpu(EEPROM_ICW1_SIGNATURE_MASK))
-	    != le16_to_cpu(EEPROM_ICW1_SIGNATURE_VALID)) {
+		 != le16_to_cpu(EEPROM_ICW1_SIGNATURE_VALID)) {
 		DEBUGOUT("ixgb_ee: Signature invalid.\n");
-		return (FALSE);
+		return(FALSE);
 	}
 
-	return (TRUE);
+	return(TRUE);
 }
 
 /******************************************************************************
@@ -479,7 +500,8 @@
  *      TRUE: eeprom signature was good and the eeprom read was successful
  *      FALSE: otherwise.
  ******************************************************************************/
-static boolean_t ixgb_check_and_get_eeprom_data(struct ixgb_hw *hw)
+static boolean_t
+ixgb_check_and_get_eeprom_data (struct ixgb_hw* hw)
 {
 	struct ixgb_ee_map_type *ee_map = (struct ixgb_ee_map_type *)hw->eeprom;
 
@@ -500,15 +522,16 @@
  * Returns:
  *          Word at indexed offset in eeprom, if valid, 0 otherwise.
  ******************************************************************************/
-uint16_t ixgb_get_eeprom_word(struct ixgb_hw * hw, uint16_t index)
+uint16_t
+ixgb_get_eeprom_word(struct ixgb_hw *hw, uint16_t index)
 {
 
 	if ((index < IXGB_EEPROM_SIZE) &&
-	    (ixgb_check_and_get_eeprom_data(hw) == TRUE)) {
-		return (hw->eeprom[index]);
+		(ixgb_check_and_get_eeprom_data(hw) == TRUE)) {
+	   return(hw->eeprom[index]);
 	}
 
-	return (0);
+	return(0);
 }
 
 /******************************************************************************
@@ -519,7 +542,9 @@
  *
  * Returns: None.
  ******************************************************************************/
-void ixgb_get_ee_mac_addr(struct ixgb_hw *hw, uint8_t * mac_addr)
+void
+ixgb_get_ee_mac_addr(struct ixgb_hw *hw,
+			uint8_t *mac_addr)
 {
 	int i;
 	struct ixgb_ee_map_type *ee_map = (struct ixgb_ee_map_type *)hw->eeprom;
@@ -542,14 +567,15 @@
  * Returns:
  *          compatibility flags if EEPROM contents are valid, 0 otherwise
  ******************************************************************************/
-uint16_t ixgb_get_ee_compatibility(struct ixgb_hw *hw)
+uint16_t
+ixgb_get_ee_compatibility(struct ixgb_hw *hw)
 {
 	struct ixgb_ee_map_type *ee_map = (struct ixgb_ee_map_type *)hw->eeprom;
 
-	if (ixgb_check_and_get_eeprom_data(hw) == TRUE)
-		return (ee_map->compatibility);
+	if(ixgb_check_and_get_eeprom_data(hw) == TRUE)
+		return(ee_map->compatibility);
 
-	return (0);
+	return(0);
 }
 
 /******************************************************************************
@@ -560,13 +586,14 @@
  * Returns:
  *          PBA number if EEPROM contents are valid, 0 otherwise
  ******************************************************************************/
-uint32_t ixgb_get_ee_pba_number(struct ixgb_hw * hw)
+uint32_t
+ixgb_get_ee_pba_number(struct ixgb_hw *hw)
 {
-	if (ixgb_check_and_get_eeprom_data(hw) == TRUE)
+	if(ixgb_check_and_get_eeprom_data(hw) == TRUE)
 		return (le16_to_cpu(hw->eeprom[EEPROM_PBA_1_2_REG])
-			| (le16_to_cpu(hw->eeprom[EEPROM_PBA_3_4_REG]) << 16));
+			| (le16_to_cpu(hw->eeprom[EEPROM_PBA_3_4_REG])<<16));
 
-	return (0);
+	return(0);
 }
 
 /******************************************************************************
@@ -577,14 +604,15 @@
  * Returns:
  *          Initialization Control Word 1 if EEPROM contents are valid, 0 otherwise
  ******************************************************************************/
-uint16_t ixgb_get_ee_init_ctrl_reg_1(struct ixgb_hw * hw)
+uint16_t
+ixgb_get_ee_init_ctrl_reg_1(struct ixgb_hw *hw)
 {
 	struct ixgb_ee_map_type *ee_map = (struct ixgb_ee_map_type *)hw->eeprom;
 
-	if (ixgb_check_and_get_eeprom_data(hw) == TRUE)
-		return (ee_map->init_ctrl_reg_1);
+	if(ixgb_check_and_get_eeprom_data(hw) == TRUE)
+		return(ee_map->init_ctrl_reg_1);
 
-	return (0);
+	return(0);
 }
 
 /******************************************************************************
@@ -595,14 +623,15 @@
  * Returns:
  *          Initialization Control Word 2 if EEPROM contents are valid, 0 otherwise
  ******************************************************************************/
-uint16_t ixgb_get_ee_init_ctrl_reg_2(struct ixgb_hw * hw)
+uint16_t
+ixgb_get_ee_init_ctrl_reg_2(struct ixgb_hw *hw)
 {
 	struct ixgb_ee_map_type *ee_map = (struct ixgb_ee_map_type *)hw->eeprom;
 
-	if (ixgb_check_and_get_eeprom_data(hw) == TRUE)
-		return (ee_map->init_ctrl_reg_2);
+	if(ixgb_check_and_get_eeprom_data(hw) == TRUE)
+		return(ee_map->init_ctrl_reg_2);
 
-	return (0);
+	return(0);
 }
 
 /******************************************************************************
@@ -613,14 +642,15 @@
  * Returns:
  *          Subsystem Id if EEPROM contents are valid, 0 otherwise
  ******************************************************************************/
-uint16_t ixgb_get_ee_subsystem_id(struct ixgb_hw * hw)
+uint16_t
+ixgb_get_ee_subsystem_id(struct ixgb_hw *hw)
 {
 	struct ixgb_ee_map_type *ee_map = (struct ixgb_ee_map_type *)hw->eeprom;
 
-	if (ixgb_check_and_get_eeprom_data(hw) == TRUE)
-		return (ee_map->subsystem_id);
+	if(ixgb_check_and_get_eeprom_data(hw) == TRUE)
+	   return(ee_map->subsystem_id);
 
-	return (0);
+	return(0);
 }
 
 /******************************************************************************
@@ -631,14 +661,15 @@
  * Returns:
  *          Sub Vendor Id if EEPROM contents are valid, 0 otherwise
  ******************************************************************************/
-uint16_t ixgb_get_ee_subvendor_id(struct ixgb_hw * hw)
+uint16_t
+ixgb_get_ee_subvendor_id(struct ixgb_hw *hw)
 {
 	struct ixgb_ee_map_type *ee_map = (struct ixgb_ee_map_type *)hw->eeprom;
 
-	if (ixgb_check_and_get_eeprom_data(hw) == TRUE)
-		return (ee_map->subvendor_id);
+	if(ixgb_check_and_get_eeprom_data(hw) == TRUE)
+		return(ee_map->subvendor_id);
 
-	return (0);
+	return(0);
 }
 
 /******************************************************************************
@@ -649,14 +680,15 @@
  * Returns:
  *          Device Id if EEPROM contents are valid, 0 otherwise
  ******************************************************************************/
-uint16_t ixgb_get_ee_device_id(struct ixgb_hw * hw)
+uint16_t
+ixgb_get_ee_device_id(struct ixgb_hw *hw)
 {
 	struct ixgb_ee_map_type *ee_map = (struct ixgb_ee_map_type *)hw->eeprom;
 
-	if (ixgb_check_and_get_eeprom_data(hw) == TRUE)
-		return (ee_map->device_id);
+	if(ixgb_check_and_get_eeprom_data(hw) == TRUE)
+		return(ee_map->device_id);
 
-	return (0);
+	return(0);
 }
 
 /******************************************************************************
@@ -667,14 +699,15 @@
  * Returns:
  *          Device Id if EEPROM contents are valid, 0 otherwise
  ******************************************************************************/
-uint16_t ixgb_get_ee_vendor_id(struct ixgb_hw * hw)
+uint16_t
+ixgb_get_ee_vendor_id(struct ixgb_hw *hw)
 {
 	struct ixgb_ee_map_type *ee_map = (struct ixgb_ee_map_type *)hw->eeprom;
 
-	if (ixgb_check_and_get_eeprom_data(hw) == TRUE)
-		return (ee_map->vendor_id);
+	if(ixgb_check_and_get_eeprom_data(hw) == TRUE)
+		return(ee_map->vendor_id);
 
-	return (0);
+	return(0);
 }
 
 /******************************************************************************
@@ -685,14 +718,15 @@
  * Returns:
  *          SDP Register if EEPROM contents are valid, 0 otherwise
  ******************************************************************************/
-uint16_t ixgb_get_ee_swdpins_reg(struct ixgb_hw * hw)
+uint16_t
+ixgb_get_ee_swdpins_reg(struct ixgb_hw *hw)
 {
 	struct ixgb_ee_map_type *ee_map = (struct ixgb_ee_map_type *)hw->eeprom;
 
-	if (ixgb_check_and_get_eeprom_data(hw) == TRUE)
-		return (ee_map->swdpins_reg);
+	if(ixgb_check_and_get_eeprom_data(hw) == TRUE)
+		return(ee_map->swdpins_reg);
 
-	return (0);
+	return(0);
 }
 
 /******************************************************************************
@@ -703,14 +737,15 @@
  * Returns:
  *          D3 Power Management Bits if EEPROM contents are valid, 0 otherwise
  ******************************************************************************/
-uint8_t ixgb_get_ee_d3_power(struct ixgb_hw * hw)
+uint8_t
+ixgb_get_ee_d3_power(struct ixgb_hw *hw)
 {
 	struct ixgb_ee_map_type *ee_map = (struct ixgb_ee_map_type *)hw->eeprom;
 
-	if (ixgb_check_and_get_eeprom_data(hw) == TRUE)
-		return (ee_map->d3_power);
+	if(ixgb_check_and_get_eeprom_data(hw) == TRUE)
+		return(ee_map->d3_power);
 
-	return (0);
+	return(0);
 }
 
 /******************************************************************************
@@ -721,12 +756,13 @@
  * Returns:
  *          D0 Power Management Bits if EEPROM contents are valid, 0 otherwise
  ******************************************************************************/
-uint8_t ixgb_get_ee_d0_power(struct ixgb_hw * hw)
+uint8_t
+ixgb_get_ee_d0_power(struct ixgb_hw *hw)
 {
 	struct ixgb_ee_map_type *ee_map = (struct ixgb_ee_map_type *)hw->eeprom;
 
-	if (ixgb_check_and_get_eeprom_data(hw) == TRUE)
-		return (ee_map->d0_power);
+	if(ixgb_check_and_get_eeprom_data(hw) == TRUE)
+		return(ee_map->d0_power);
 
-	return (0);
+	return(0);
 }
diff -Nru a/drivers/net/ixgb/ixgb_ethtool.c b/drivers/net/ixgb/ixgb_ethtool.c
--- a/drivers/net/ixgb/ixgb_ethtool.c	2005-01-10 23:54:12 -05:00
+++ b/drivers/net/ixgb/ixgb_ethtool.c	2005-01-10 23:54:12 -05:00
@@ -37,6 +37,12 @@
 
 extern int ixgb_up(struct ixgb_adapter *adapter);
 extern void ixgb_down(struct ixgb_adapter *adapter, boolean_t kill_watchdog);
+extern void ixgb_reset(struct ixgb_adapter *adapter);
+extern int ixgb_setup_rx_resources(struct ixgb_adapter *adapter);
+extern int ixgb_setup_tx_resources(struct ixgb_adapter *adapter);
+extern void ixgb_free_rx_resources(struct ixgb_adapter *adapter);
+extern void ixgb_free_tx_resources(struct ixgb_adapter *adapter);
+extern void ixgb_update_stats(struct ixgb_adapter *adapter);
 
 struct ixgb_stats {
 	char stat_string[ETH_GSTRING_LEN];
@@ -89,7 +95,7 @@
 	sizeof(ixgb_gstrings_stats) / sizeof(struct ixgb_stats)
 
 static int
-ixgb_ethtool_gset(struct net_device *netdev, struct ethtool_cmd *ecmd)
+ixgb_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 {
 	struct ixgb_adapter *adapter = netdev->priv;
 	ecmd->supported = (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);
@@ -97,7 +103,7 @@
 	ecmd->port = PORT_FIBRE;
 	ecmd->transceiver = XCVR_EXTERNAL;
 
-	if (netif_carrier_ok(adapter->netdev)) {
+	if(netif_carrier_ok(adapter->netdev)) {
 		ecmd->speed = SPEED_10000;
 		ecmd->duplex = DUPLEX_FULL;
 	} else {
@@ -110,86 +116,140 @@
 }
 
 static int
-ixgb_ethtool_sset(struct net_device *netdev, struct ethtool_cmd *ecmd)
+ixgb_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 {
 	struct ixgb_adapter *adapter = netdev->priv;
-	if (ecmd->autoneg == AUTONEG_ENABLE ||
-	    ecmd->speed + ecmd->duplex != SPEED_10000 + DUPLEX_FULL)
+	if(ecmd->autoneg == AUTONEG_ENABLE ||
+	   ecmd->speed + ecmd->duplex != SPEED_10000 + DUPLEX_FULL)
 		return -EINVAL;
-	else {
+	
+	if(netif_running(adapter->netdev)) {
 		ixgb_down(adapter, TRUE);
+		ixgb_reset(adapter);
 		ixgb_up(adapter);
-	}
+	} else
+		ixgb_reset(adapter);
+
 	return 0;
 }
 
 static void
-ixgb_ethtool_gpause(struct net_device *dev,
-		    struct ethtool_pauseparam *epause)
+ixgb_get_pauseparam(struct net_device *netdev,
+			 struct ethtool_pauseparam *pause)
 {
-	struct ixgb_adapter *adapter = dev->priv;
+	struct ixgb_adapter *adapter = netdev->priv;
 	struct ixgb_hw *hw = &adapter->hw;
-
-	epause->autoneg = AUTONEG_DISABLE;
-
-	if (hw->fc.type == ixgb_fc_rx_pause)
-		epause->rx_pause = 1;
-	else if (hw->fc.type == ixgb_fc_tx_pause)
-		epause->tx_pause = 1;
-	else if (hw->fc.type == ixgb_fc_full) {
-		epause->rx_pause = 1;
-		epause->tx_pause = 1;
+	
+	pause->autoneg = AUTONEG_DISABLE;
+		
+	if(hw->fc.type == ixgb_fc_rx_pause)
+		pause->rx_pause = 1;
+	else if(hw->fc.type == ixgb_fc_tx_pause)
+		pause->tx_pause = 1;
+	else if(hw->fc.type == ixgb_fc_full) {
+		pause->rx_pause = 1;
+		pause->tx_pause = 1;
 	}
 }
 
 static int
-ixgb_ethtool_spause(struct net_device *dev,
-		    struct ethtool_pauseparam *epause)
+ixgb_set_pauseparam(struct net_device *netdev,
+			 struct ethtool_pauseparam *pause)
 {
-	struct ixgb_adapter *adapter = dev->priv;
+	struct ixgb_adapter *adapter = netdev->priv;
 	struct ixgb_hw *hw = &adapter->hw;
-
-	if (epause->autoneg == AUTONEG_ENABLE)
+	
+	if(pause->autoneg == AUTONEG_ENABLE)
 		return -EINVAL;
 
-	if (epause->rx_pause && epause->tx_pause)
+	if(pause->rx_pause && pause->tx_pause)
 		hw->fc.type = ixgb_fc_full;
-	else if (epause->rx_pause && !epause->tx_pause)
+	else if(pause->rx_pause && !pause->tx_pause)
 		hw->fc.type = ixgb_fc_rx_pause;
-	else if (!epause->rx_pause && epause->tx_pause)
+	else if(!pause->rx_pause && pause->tx_pause)
 		hw->fc.type = ixgb_fc_tx_pause;
-	else if (!epause->rx_pause && !epause->tx_pause)
+	else if(!pause->rx_pause && !pause->tx_pause)
 		hw->fc.type = ixgb_fc_none;
 
-	ixgb_down(adapter, TRUE);
-	ixgb_up(adapter);
-
+	if(netif_running(adapter->netdev)) {
+		ixgb_down(adapter, TRUE);
+		ixgb_up(adapter);
+	} else
+		ixgb_reset(adapter);
+		
 	return 0;
 }
 
-static void
-ixgb_ethtool_gdrvinfo(struct net_device *netdev,
-		      struct ethtool_drvinfo *drvinfo)
+static uint32_t
+ixgb_get_rx_csum(struct net_device *netdev)
 {
 	struct ixgb_adapter *adapter = netdev->priv;
-	strncpy(drvinfo->driver, ixgb_driver_name, 32);
-	strncpy(drvinfo->version, ixgb_driver_version, 32);
-	strncpy(drvinfo->fw_version, "N/A", 32);
-	strncpy(drvinfo->bus_info, pci_name(adapter->pdev), 32);
+	return adapter->rx_csum;
 }
 
+static int
+ixgb_set_rx_csum(struct net_device *netdev, uint32_t data)
+{
+	struct ixgb_adapter *adapter = netdev->priv;
+	adapter->rx_csum = data;
+
+	if(netif_running(netdev)) {
+		ixgb_down(adapter,TRUE);
+		ixgb_up(adapter);
+	} else
+		ixgb_reset(adapter);
+	return 0;
+}
+	
+static uint32_t
+ixgb_get_tx_csum(struct net_device *netdev)
+{
+	return (netdev->features & NETIF_F_HW_CSUM) != 0;
+}
+
+static int
+ixgb_set_tx_csum(struct net_device *netdev, uint32_t data)
+{
+	if (data)
+		netdev->features |= NETIF_F_HW_CSUM;
+	else
+		netdev->features &= ~NETIF_F_HW_CSUM;
+
+	return 0;
+}
+
+#ifdef NETIF_F_TSO
+static int
+ixgb_set_tso(struct net_device *netdev, uint32_t data)
+{
+	if(data)
+		netdev->features |= NETIF_F_TSO;
+	else
+		netdev->features &= ~NETIF_F_TSO;
+	return 0;
+} 
+#endif /* NETIF_F_TSO */
+
 #define IXGB_GET_STAT(_A_, _R_) _A_->stats._R_
+
+static int 
+ixgb_get_regs_len(struct net_device *netdev)
+{
+#define IXGB_REG_DUMP_LEN  136*sizeof(uint32_t)
+	return IXGB_REG_DUMP_LEN;
+}
+
 static void
-ixgb_ethtool_gregs(struct net_device *dev, struct ethtool_regs *regs, void *buf)
+ixgb_get_regs(struct net_device *netdev,
+		   struct ethtool_regs *regs, void *p)
 {
-	struct ixgb_adapter *adapter = dev->priv;
+	struct ixgb_adapter *adapter = netdev->priv;
 	struct ixgb_hw *hw = &adapter->hw;
-	uint32_t *reg = buf;
+	uint32_t *reg = p;
 	uint32_t *reg_start = reg;
 	uint8_t i;
 
-	regs->version =
-	    (adapter->hw.device_id << 16) | adapter->hw.subsystem_id;
+	regs->version = (adapter->hw.device_id << 16) | adapter->hw.subsystem_id;
 
 	/* General Registers */
 	*reg++ = IXGB_READ_REG(hw, CTRL0);	/*   0 */
@@ -219,8 +279,8 @@
 	*reg++ = IXGB_READ_REG(hw, RXCSUM);	/*  20 */
 
 	for (i = 0; i < IXGB_RAR_ENTRIES; i++) {
-		*reg++ = IXGB_READ_REG_ARRAY(hw, RAL, (i << 1));	/*21,...,51 */
-		*reg++ = IXGB_READ_REG_ARRAY(hw, RAH, (i << 1));	/*22,...,52 */
+		*reg++ = IXGB_READ_REG_ARRAY(hw, RAL, (i << 1)); /*21,...,51 */
+		*reg++ = IXGB_READ_REG_ARRAY(hw, RAH, (i << 1)); /*22,...,52 */
 	}
 
 	/* Transmit */
@@ -316,73 +376,222 @@
 }
 
 static int
-ixgb_ethtool_geeprom(struct net_device *dev,
-		     struct ethtool_eeprom *eeprom, u8 *data)
+ixgb_get_eeprom_len(struct net_device *netdev)
 {
-	struct ixgb_adapter *adapter = dev->priv;
+	/* return size in bytes */
+	return (IXGB_EEPROM_SIZE << 1);
+}
+
+static int
+ixgb_get_eeprom(struct net_device *netdev,
+		  struct ethtool_eeprom *eeprom, uint8_t *bytes)
+{
+	struct ixgb_adapter *adapter = netdev->priv;
 	struct ixgb_hw *hw = &adapter->hw;
+	uint16_t *eeprom_buff;
+	int i, max_len, first_word, last_word;
+	int ret_val = 0;
+
+	if(eeprom->len == 0) {
+		ret_val = -EINVAL;
+		goto geeprom_error;
+	}
 
 	eeprom->magic = hw->vendor_id | (hw->device_id << 16);
 
-	/* use our function to read the eeprom and update our cache */
-	ixgb_get_eeprom_data(hw);
-	memcpy(data, (char *)hw->eeprom + eeprom->offset, eeprom->len);
-	return 0;
+	max_len = ixgb_get_eeprom_len(netdev);
+
+	if(eeprom->offset > eeprom->offset + eeprom->len) {
+		ret_val = -EINVAL;
+		goto geeprom_error;
+	}
+
+	if((eeprom->offset + eeprom->len) > max_len)
+		eeprom->len = (max_len - eeprom->offset);
+
+	first_word = eeprom->offset >> 1;
+	last_word = (eeprom->offset + eeprom->len - 1) >> 1;
+
+	eeprom_buff = kmalloc(sizeof(uint16_t) *
+			(last_word - first_word + 1), GFP_KERNEL);
+	if(!eeprom_buff)
+		return -ENOMEM;
+
+	/* note the eeprom was good because the driver loaded */
+	for(i = 0; i <= (last_word - first_word); i++) {
+		eeprom_buff[i] = ixgb_get_eeprom_word(hw, (first_word + i));
+	}
+
+	memcpy(bytes, (uint8_t *)eeprom_buff + (eeprom->offset & 1),
+			eeprom->len);
+	kfree(eeprom_buff);
+
+geeprom_error:
+	return ret_val;
 }
 
 static int
-ixgb_ethtool_seeprom(struct net_device *dev,
-		     struct ethtool_eeprom *eeprom, u8 *data)
+ixgb_set_eeprom(struct net_device *netdev,
+		  struct ethtool_eeprom *eeprom, uint8_t *bytes)
 {
-	struct ixgb_adapter *adapter = dev->priv;
+	struct ixgb_adapter *adapter = netdev->priv;
 	struct ixgb_hw *hw = &adapter->hw;
-	/* We are under rtnl, so static is OK */
-	static uint16_t eeprom_buff[IXGB_EEPROM_SIZE];
-	int i, first_word, last_word;
-	char *ptr;
+	uint16_t *eeprom_buff;
+	void *ptr;
+	int max_len, first_word, last_word;
+	uint16_t i;
+
+	if(eeprom->len == 0)
+		return -EINVAL;
 
-	if (eeprom->magic != (hw->vendor_id | (hw->device_id << 16)))
+	if(eeprom->magic != (hw->vendor_id | (hw->device_id << 16)))
 		return -EFAULT;
 
+	max_len = ixgb_get_eeprom_len(netdev);
+
+	if(eeprom->offset > eeprom->offset + eeprom->len)
+		return -EINVAL;
+
+	if((eeprom->offset + eeprom->len) > max_len)
+		eeprom->len = (max_len - eeprom->offset);
+
 	first_word = eeprom->offset >> 1;
 	last_word = (eeprom->offset + eeprom->len - 1) >> 1;
-	ptr = (char *)eeprom_buff;
+	eeprom_buff = kmalloc(max_len, GFP_KERNEL);
+	if(!eeprom_buff)
+		return -ENOMEM;
+
+	ptr = (void *)eeprom_buff;
 
-	if (eeprom->offset & 1) {
+	if(eeprom->offset & 1) {
 		/* need read/modify/write of first changed EEPROM word */
 		/* only the second byte of the word is being modified */
 		eeprom_buff[0] = ixgb_read_eeprom(hw, first_word);
 		ptr++;
 	}
-	if ((eeprom->offset + eeprom->len) & 1) {
+	if((eeprom->offset + eeprom->len) & 1) {
 		/* need read/modify/write of last changed EEPROM word */
 		/* only the first byte of the word is being modified */
-		eeprom_buff[last_word - first_word]
-		    = ixgb_read_eeprom(hw, last_word);
+		eeprom_buff[last_word - first_word] 
+			= ixgb_read_eeprom(hw, last_word);
 	}
-	memcpy(ptr, data, eeprom->len);
 
-	for (i = 0; i <= (last_word - first_word); i++)
+	memcpy(ptr, bytes, eeprom->len);
+	for(i = 0; i <= (last_word - first_word); i++)
 		ixgb_write_eeprom(hw, first_word + i, eeprom_buff[i]);
 
 	/* Update the checksum over the first part of the EEPROM if needed */
-	if (first_word <= EEPROM_CHECKSUM_REG)
+	if(first_word <= EEPROM_CHECKSUM_REG)
 		ixgb_update_eeprom_checksum(hw);
 
+	kfree(eeprom_buff);
 	return 0;
 }
 
+static void
+ixgb_get_drvinfo(struct net_device *netdev,
+		   struct ethtool_drvinfo *drvinfo)
+{
+	struct ixgb_adapter *adapter = netdev->priv;
+
+	strncpy(drvinfo->driver,  ixgb_driver_name, 32);
+	strncpy(drvinfo->version, ixgb_driver_version, 32);
+	strncpy(drvinfo->fw_version, "N/A", 32);
+	strncpy(drvinfo->bus_info, pci_name(adapter->pdev), 32);
+	drvinfo->n_stats = IXGB_STATS_LEN;
+	drvinfo->regdump_len = ixgb_get_regs_len(netdev);
+	drvinfo->eedump_len = ixgb_get_eeprom_len(netdev);
+}
+
+static void
+ixgb_get_ringparam(struct net_device *netdev,
+		struct ethtool_ringparam *ring)
+{
+	struct ixgb_adapter *adapter = netdev->priv;
+	struct ixgb_desc_ring *txdr = &adapter->tx_ring;
+	struct ixgb_desc_ring *rxdr = &adapter->rx_ring;
+
+	ring->rx_max_pending = MAX_RXD; 
+	ring->tx_max_pending = MAX_TXD;
+	ring->rx_mini_max_pending = 0;
+	ring->rx_jumbo_max_pending = 0;
+	ring->rx_pending = rxdr->count;
+	ring->tx_pending = txdr->count;
+	ring->rx_mini_pending = 0;
+	ring->rx_jumbo_pending = 0;
+}
+
+static int 
+ixgb_set_ringparam(struct net_device *netdev,
+		struct ethtool_ringparam *ring)
+{
+	struct ixgb_adapter *adapter = netdev->priv;
+	struct ixgb_desc_ring *txdr = &adapter->tx_ring;
+	struct ixgb_desc_ring *rxdr = &adapter->rx_ring;
+	struct ixgb_desc_ring tx_old, tx_new, rx_old, rx_new;
+	int err;
+
+	tx_old = adapter->tx_ring;
+	rx_old = adapter->rx_ring;
+
+	if((ring->rx_mini_pending) || (ring->rx_jumbo_pending)) 
+		return -EINVAL;
+
+	if(netif_running(adapter->netdev))
+		ixgb_down(adapter,TRUE);
+
+	rxdr->count = max(ring->rx_pending,(uint32_t)MIN_RXD);
+	rxdr->count = min(rxdr->count,(uint32_t)MAX_RXD);
+	IXGB_ROUNDUP(rxdr->count, IXGB_REQ_RX_DESCRIPTOR_MULTIPLE); 
+
+	txdr->count = max(ring->tx_pending,(uint32_t)MIN_TXD);
+	txdr->count = min(txdr->count,(uint32_t)MAX_TXD);
+	IXGB_ROUNDUP(txdr->count, IXGB_REQ_TX_DESCRIPTOR_MULTIPLE); 
+
+	if(netif_running(adapter->netdev)) {
+		/* Try to get new resources before deleting old */
+		if((err = ixgb_setup_rx_resources(adapter)))
+			goto err_setup_rx;
+		if((err = ixgb_setup_tx_resources(adapter)))
+			goto err_setup_tx;
+
+		/* save the new, restore the old in order to free it,
+		 * then restore the new back again */
+
+		rx_new = adapter->rx_ring;
+		tx_new = adapter->tx_ring;
+		adapter->rx_ring = rx_old;
+		adapter->tx_ring = tx_old;
+		ixgb_free_rx_resources(adapter);
+		ixgb_free_tx_resources(adapter);
+		adapter->rx_ring = rx_new;
+		adapter->tx_ring = tx_new;
+		if((err = ixgb_up(adapter)))
+			return err;
+	}
+
+	return 0;
+err_setup_tx:
+	ixgb_free_rx_resources(adapter);
+err_setup_rx:
+	adapter->rx_ring = rx_old;
+	adapter->tx_ring = tx_old;
+	ixgb_up(adapter);
+	return err;
+}
+
 /* toggle LED 4 times per second = 2 "blinks" per second */
 #define IXGB_ID_INTERVAL	(HZ/4)
 
 /* bit defines for adapter->led_status */
 #define IXGB_LED_ON		0
 
-static void ixgb_led_blink_callback(unsigned long data)
+static void
+ixgb_led_blink_callback(unsigned long data)
 {
 	struct ixgb_adapter *adapter = (struct ixgb_adapter *)data;
 
-	if (test_and_change_bit(IXGB_LED_ON, &adapter->led_status))
+	if(test_and_change_bit(IXGB_LED_ON, &adapter->led_status))
 		ixgb_led_off(&adapter->hw);
 	else
 		ixgb_led_on(&adapter->hw);
@@ -391,10 +600,14 @@
 }
 
 static int
-ixgb_ethtool_led_blink(struct net_device *netdev, u32 data)
+ixgb_phys_id(struct net_device *netdev, uint32_t data)
 {
 	struct ixgb_adapter *adapter = netdev->priv;
-	if (!adapter->blink_timer.function) {
+
+	if(!data || data > (uint32_t)(MAX_SCHEDULE_TIMEOUT / HZ))
+		data = (uint32_t)(MAX_SCHEDULE_TIMEOUT / HZ);
+
+	if(!adapter->blink_timer.function) {
 		init_timer(&adapter->blink_timer);
 		adapter->blink_timer.function = ixgb_led_blink_callback;
 		adapter->blink_timer.data = (unsigned long)adapter;
@@ -403,7 +616,7 @@
 	mod_timer(&adapter->blink_timer, jiffies);
 
 	set_current_state(TASK_INTERRUPTIBLE);
-	if (data)
+	if(data)
 		schedule_timeout(data * HZ);
 	else
 		schedule_timeout(MAX_SCHEDULE_TIMEOUT);
@@ -415,141 +628,74 @@
 	return 0;
 }
 
-static int ixgb_nway_reset(struct net_device *netdev)
-{
-	if (netif_running(netdev)) {
-		struct ixgb_adapter *adapter = netdev->priv;
-		ixgb_down(adapter, TRUE);
-		ixgb_up(adapter);
-	}
-	return 0;
-}
-
-static int ixgb_get_stats_count(struct net_device *dev)
+static int 
+ixgb_get_stats_count(struct net_device *netdev)
 {
 	return IXGB_STATS_LEN;
 }
 
-static void ixgb_get_strings(struct net_device *dev, u32 stringset, u8 *data)
+static void 
+ixgb_get_ethtool_stats(struct net_device *netdev, 
+		struct ethtool_stats *stats, uint64_t *data)
 {
+	struct ixgb_adapter *adapter = netdev->priv;
 	int i;
-	for (i = 0; i < IXGB_STATS_LEN; i++) {
-		memcpy(data + i * ETH_GSTRING_LEN,
-		       ixgb_gstrings_stats[i].stat_string,
-		       ETH_GSTRING_LEN);
-	}
-}
-
-static int ixgb_get_regs_len(struct net_device *dev)
-{
-	return 136*sizeof(uint32_t);
-}
 
-static int ixgb_get_eeprom_len(struct net_device *dev)
-{
-	/* return size in bytes */
-	return (IXGB_EEPROM_SIZE << 1);
+	ixgb_update_stats(adapter);
+	for(i = 0; i < IXGB_STATS_LEN; i++) {
+		char *p = (char *)adapter+ixgb_gstrings_stats[i].stat_offset;	
+		data[i] = (ixgb_gstrings_stats[i].sizeof_stat == 
+			sizeof(uint64_t)) ? *(uint64_t *)p : *(uint32_t *)p;
+	}
 }
 
-static void get_ethtool_stats(struct net_device *dev,
-		struct ethtool_stats *stats, u64 *data)
+static void 
+ixgb_get_strings(struct net_device *netdev, uint32_t stringset, uint8_t *data)
 {
-	struct ixgb_adapter *adapter = dev->priv;
 	int i;
 
-	for (i = 0; i < IXGB_STATS_LEN; i++) {
-		void *p = (char *)adapter + ixgb_gstrings_stats[i].stat_offset;
-		stats->data[i] =
-		    (ixgb_gstrings_stats[i].sizeof_stat == sizeof(uint64_t))
-		    ? *(uint64_t *) p
-		    : *(uint32_t *) p;
+	switch(stringset) {
+	case ETH_SS_STATS:
+		for(i=0; i < IXGB_STATS_LEN; i++) {
+			memcpy(data + i * ETH_GSTRING_LEN, 
+			ixgb_gstrings_stats[i].stat_string,
+			ETH_GSTRING_LEN);
+		}
+		break;
 	}
 }
 
-static u32 ixgb_get_rx_csum(struct net_device *dev)
-{
-	struct ixgb_adapter *adapter = dev->priv;
-	return adapter->rx_csum;
-}
-
-static int ixgb_set_rx_csum(struct net_device *dev, u32 sum)
-{
-	struct ixgb_adapter *adapter = dev->priv;
-	adapter->rx_csum = sum;
-	ixgb_down(adapter, TRUE);
-	ixgb_up(adapter);
-	return 0;
-}
-
-static u32 ixgb_get_tx_csum(struct net_device *dev)
-{
-	return (dev->features & NETIF_F_HW_CSUM) != 0;
-}
-
-static int ixgb_set_tx_csum(struct net_device *dev, u32 sum)
-{
-	if (sum)
-		dev->features |= NETIF_F_HW_CSUM;
-	else
-		dev->features &= ~NETIF_F_HW_CSUM;
-	return 0;
-}
-
-static u32 ixgb_get_sg(struct net_device *dev)
-{
-	return (dev->features & NETIF_F_SG) != 0;
-}
-
-static int ixgb_set_sg(struct net_device *dev, u32 sum)
-{
-	if (sum)
-		dev->features |= NETIF_F_SG;
-	else
-		dev->features &= ~NETIF_F_SG;
-	return 0;
-}
-
-#ifdef NETIF_F_TSO
-static u32 ixgb_get_tso(struct net_device *dev)
-{
-	return (dev->features & NETIF_F_TSO) != 0;
-}
-
-static int ixgb_set_tso(struct net_device *dev, u32 sum)
-{
-	if (sum)
-		dev->features |= NETIF_F_TSO;
-	else
-		dev->features &= ~NETIF_F_TSO;
-	return 0;
-}
-#endif
-
 struct ethtool_ops ixgb_ethtool_ops = {
-	.get_settings = ixgb_ethtool_gset,
-	.set_settings = ixgb_ethtool_sset,
-	.get_drvinfo = ixgb_ethtool_gdrvinfo,
-	.nway_reset = ixgb_nway_reset,
-	.get_link = ethtool_op_get_link,
-	.phys_id = ixgb_ethtool_led_blink,
-	.get_strings = ixgb_get_strings,
-	.get_stats_count = ixgb_get_stats_count,
-	.get_regs = ixgb_ethtool_gregs,
+	.get_settings = ixgb_get_settings,
+	.set_settings = ixgb_set_settings,
+	.get_drvinfo = ixgb_get_drvinfo,
 	.get_regs_len = ixgb_get_regs_len,
+	.get_regs = ixgb_get_regs,
+	.get_link = ethtool_op_get_link,
 	.get_eeprom_len = ixgb_get_eeprom_len,
-	.get_eeprom = ixgb_ethtool_geeprom,
-	.set_eeprom = ixgb_ethtool_seeprom,
-	.get_pauseparam = ixgb_ethtool_gpause,
-	.set_pauseparam = ixgb_ethtool_spause,
-	.get_ethtool_stats = get_ethtool_stats,
+	.get_eeprom = ixgb_get_eeprom,
+	.set_eeprom = ixgb_set_eeprom,
+	.get_ringparam = ixgb_get_ringparam,
+	.set_ringparam = ixgb_set_ringparam,
+	.get_pauseparam	= ixgb_get_pauseparam,
+	.set_pauseparam	= ixgb_set_pauseparam,
 	.get_rx_csum = ixgb_get_rx_csum,
 	.set_rx_csum = ixgb_set_rx_csum,
 	.get_tx_csum = ixgb_get_tx_csum,
 	.set_tx_csum = ixgb_set_tx_csum,
-	.get_sg = ixgb_get_sg,
-	.set_sg = ixgb_set_sg,
+	.get_sg	= ethtool_op_get_sg,
+	.set_sg	= ethtool_op_set_sg,
 #ifdef NETIF_F_TSO
-	.get_tso = ixgb_get_tso,
+	.get_tso = ethtool_op_get_tso,
 	.set_tso = ixgb_set_tso,
 #endif
+	.get_strings = ixgb_get_strings,
+	.phys_id = ixgb_phys_id,
+	.get_stats_count = ixgb_get_stats_count,
+	.get_ethtool_stats = ixgb_get_ethtool_stats,
 };
+
+void set_ethtool_ops(struct net_device *netdev)
+{
+	SET_ETHTOOL_OPS(netdev, &ixgb_ethtool_ops);
+}
diff -Nru a/drivers/net/ixgb/ixgb_hw.c b/drivers/net/ixgb/ixgb_hw.c
--- a/drivers/net/ixgb/ixgb_hw.c	2005-01-10 23:54:12 -05:00
+++ b/drivers/net/ixgb/ixgb_hw.c	2005-01-10 23:54:12 -05:00
@@ -53,9 +53,14 @@
 {
 	uint32_t ctrl_reg;
 
-	ctrl_reg = IXGB_CTRL0_RST | IXGB_CTRL0_SDP3_DIR |	/* All pins are Output=1 */
-	    IXGB_CTRL0_SDP2_DIR | IXGB_CTRL0_SDP1_DIR | IXGB_CTRL0_SDP0_DIR | IXGB_CTRL0_SDP3 |	/* Initial value 1101   */
-	    IXGB_CTRL0_SDP2 | IXGB_CTRL0_SDP0;
+	ctrl_reg =  IXGB_CTRL0_RST |
+				IXGB_CTRL0_SDP3_DIR |   /* All pins are Output=1 */
+				IXGB_CTRL0_SDP2_DIR |
+				IXGB_CTRL0_SDP1_DIR |
+				IXGB_CTRL0_SDP0_DIR |
+				IXGB_CTRL0_SDP3	 |   /* Initial value 1101   */
+				IXGB_CTRL0_SDP2	 |
+				IXGB_CTRL0_SDP0;
 
 #ifdef HP_ZX1
 	/* Workaround for 82597EX reset errata */
@@ -84,7 +89,8 @@
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-boolean_t ixgb_adapter_stop(struct ixgb_hw * hw)
+boolean_t
+ixgb_adapter_stop(struct ixgb_hw *hw)
 {
 	uint32_t ctrl_reg;
 	uint32_t icr_reg;
@@ -94,7 +100,7 @@
 	/* If we are stopped or resetting exit gracefully and wait to be
 	 * started again before accessing the hardware.
 	 */
-	if (hw->adapter_stopped) {
+	if(hw->adapter_stopped) {
 		DEBUGOUT("Exiting because the adapter is already stopped!!!\n");
 		return FALSE;
 	}
@@ -135,6 +141,7 @@
 	return (ctrl_reg & IXGB_CTRL0_RST);
 }
 
+
 /******************************************************************************
  * Identifies the vendor of the optics module on the adapter.  The SR adapters
  * support two different types of XPAK optics, so it is necessary to determine
@@ -144,7 +151,8 @@
  *
  * Returns: the vendor of the XPAK optics module.
  *****************************************************************************/
-static ixgb_xpak_vendor ixgb_identify_xpak_vendor(struct ixgb_hw *hw)
+static ixgb_xpak_vendor
+ixgb_identify_xpak_vendor(struct ixgb_hw *hw)
 {
 	uint32_t i;
 	uint16_t vendor_name[5];
@@ -183,7 +191,8 @@
  *
  * Returns: the phy type of the adapter.
  *****************************************************************************/
-static ixgb_phy_type ixgb_identify_phy(struct ixgb_hw *hw)
+static ixgb_phy_type
+ixgb_identify_phy(struct ixgb_hw *hw)
 {
 	ixgb_phy_type phy_type;
 	ixgb_xpak_vendor xpak_vendor;
@@ -210,6 +219,11 @@
 			phy_type = ixgb_phy_type_g6005;
 		}
 		break;
+		case IXGB_DEVICE_ID_82597EX_LR:
+			DEBUGOUT("Identified G6104 optics\n");
+			phy_type = ixgb_phy_type_g6104;
+			break;
+
 
 	default:
 		DEBUGOUT("Unknown physical layer module\n");
@@ -237,7 +251,8 @@
  *      TRUE if successful,
  *      FALSE if unrecoverable problems were encountered.
  *****************************************************************************/
-boolean_t ixgb_init_hw(struct ixgb_hw * hw)
+boolean_t
+ixgb_init_hw(struct ixgb_hw *hw)
 {
 	uint32_t i;
 	uint32_t ctrl_reg;
@@ -266,7 +281,7 @@
 	msec_delay(IXGB_DELAY_AFTER_EE_RESET);
 
 	if (ixgb_get_eeprom_data(hw) == FALSE) {
-		return (FALSE);
+		return(FALSE);
 	}
 
 	/* Use the device id to determine the type of phy/transceiver. */
@@ -284,7 +299,7 @@
 	 */
 	if (!mac_addr_valid(hw->curr_mac_addr)) {
 		DEBUGOUT("MAC address invalid after ixgb_init_rx_addrs\n");
-		return (FALSE);
+		return(FALSE);
 	}
 
 	/* tell the routines in this file they can access hardware again */
@@ -295,7 +310,7 @@
 
 	/* Zero out the Multicast HASH table */
 	DEBUGOUT("Zeroing the MTA\n");
-	for (i = 0; i < IXGB_MC_TBL_SIZE; i++)
+	for(i = 0; i < IXGB_MC_TBL_SIZE; i++)
 		IXGB_WRITE_REG_ARRAY(hw, MTA, i, 0);
 
 	/* Zero out the VLAN Filter Table Array */
@@ -322,7 +337,8 @@
  * of the receive addresss registers. Clears the multicast table. Assumes
  * the receiver is in reset when the routine is called.
  *****************************************************************************/
-void ixgb_init_rx_addrs(struct ixgb_hw *hw)
+void
+ixgb_init_rx_addrs(struct ixgb_hw *hw)
 {
 	uint32_t i;
 
@@ -360,7 +376,7 @@
 
 	/* Zero out the other 15 receive addresses. */
 	DEBUGOUT("Clearing RAR[1-15]\n");
-	for (i = 1; i < IXGB_RAR_ENTRIES; i++) {
+	for(i = 1; i < IXGB_RAR_ENTRIES; i++) {
 		IXGB_WRITE_REG_ARRAY(hw, RA, (i << 1), 0);
 		IXGB_WRITE_REG_ARRAY(hw, RA, ((i << 1) + 1), 0);
 	}
@@ -383,12 +399,13 @@
  *****************************************************************************/
 void
 ixgb_mc_addr_list_update(struct ixgb_hw *hw,
-			 uint8_t * mc_addr_list,
-			 uint32_t mc_addr_count, uint32_t pad)
+			  uint8_t *mc_addr_list,
+			  uint32_t mc_addr_count,
+			  uint32_t pad)
 {
 	uint32_t hash_value;
 	uint32_t i;
-	uint32_t rar_used_count = 1;	/* RAR[0] is used for our MAC address */
+	uint32_t rar_used_count = 1;		/* RAR[0] is used for our MAC address */
 
 	DEBUGFUNC("ixgb_mc_addr_list_update");
 
@@ -397,19 +414,19 @@
 
 	/* Clear RAR[1-15] */
 	DEBUGOUT(" Clearing RAR[1-15]\n");
-	for (i = rar_used_count; i < IXGB_RAR_ENTRIES; i++) {
+	for(i = rar_used_count; i < IXGB_RAR_ENTRIES; i++) {
 		IXGB_WRITE_REG_ARRAY(hw, RA, (i << 1), 0);
 		IXGB_WRITE_REG_ARRAY(hw, RA, ((i << 1) + 1), 0);
 	}
 
 	/* Clear the MTA */
 	DEBUGOUT(" Clearing MTA\n");
-	for (i = 0; i < IXGB_MC_TBL_SIZE; i++) {
+	for(i = 0; i < IXGB_MC_TBL_SIZE; i++) {
 		IXGB_WRITE_REG_ARRAY(hw, MTA, i, 0);
 	}
 
 	/* Add the new addresses */
-	for (i = 0; i < mc_addr_count; i++) {
+	for(i = 0; i < mc_addr_count; i++) {
 		DEBUGOUT(" Adding the multicast addresses:\n");
 		DEBUGOUT7(" MC Addr #%d =%.2X %.2X %.2X %.2X %.2X %.2X\n", i,
 			  mc_addr_list[i * (IXGB_ETH_LENGTH_OF_ADDRESS + pad)],
@@ -427,7 +444,7 @@
 		/* Place this multicast address in the RAR if there is room, *
 		 * else put it in the MTA
 		 */
-		if (rar_used_count < IXGB_RAR_ENTRIES) {
+		if(rar_used_count < IXGB_RAR_ENTRIES) {
 			ixgb_rar_set(hw,
 				     mc_addr_list +
 				     (i * (IXGB_ETH_LENGTH_OF_ADDRESS + pad)),
@@ -460,7 +477,9 @@
  * Returns:
  *      The hash value
  *****************************************************************************/
-static uint32_t ixgb_hash_mc_addr(struct ixgb_hw *hw, uint8_t * mc_addr)
+static uint32_t
+ixgb_hash_mc_addr(struct ixgb_hw *hw,
+		   uint8_t *mc_addr)
 {
 	uint32_t hash_value = 0;
 
@@ -506,7 +525,9 @@
  * hw - Struct containing variables accessed by shared code
  * hash_value - Multicast address hash value
  *****************************************************************************/
-static void ixgb_mta_set(struct ixgb_hw *hw, uint32_t hash_value)
+static void
+ixgb_mta_set(struct ixgb_hw *hw,
+		  uint32_t hash_value)
 {
 	uint32_t hash_bit, hash_reg;
 	uint32_t mta_reg;
@@ -538,7 +559,10 @@
  * addr - Address to put into receive address register
  * index - Receive address register to write
  *****************************************************************************/
-void ixgb_rar_set(struct ixgb_hw *hw, uint8_t * addr, uint32_t index)
+void
+ixgb_rar_set(struct ixgb_hw *hw,
+		  uint8_t *addr,
+		  uint32_t index)
 {
 	uint32_t rar_low, rar_high;
 
@@ -548,11 +572,13 @@
 	 * from network order (big endian) to little endian
 	 */
 	rar_low = ((uint32_t) addr[0] |
-		   ((uint32_t) addr[1] << 8) |
-		   ((uint32_t) addr[2] << 16) | ((uint32_t) addr[3] << 24));
+		   ((uint32_t)addr[1] << 8) |
+		   ((uint32_t)addr[2] << 16) |
+		   ((uint32_t)addr[3] << 24));
 
 	rar_high = ((uint32_t) addr[4] |
-		    ((uint32_t) addr[5] << 8) | IXGB_RAH_AV);
+			((uint32_t)addr[5] << 8) |
+			IXGB_RAH_AV);
 
 	IXGB_WRITE_REG_ARRAY(hw, RA, (index << 1), rar_low);
 	IXGB_WRITE_REG_ARRAY(hw, RA, ((index << 1) + 1), rar_high);
@@ -566,7 +592,10 @@
  * offset - Offset in VLAN filer table to write
  * value - Value to write into VLAN filter table
  *****************************************************************************/
-void ixgb_write_vfta(struct ixgb_hw *hw, uint32_t offset, uint32_t value)
+void
+ixgb_write_vfta(struct ixgb_hw *hw,
+		 uint32_t offset,
+		 uint32_t value)
 {
 	IXGB_WRITE_REG_ARRAY(hw, VFTA, offset, value);
 	return;
@@ -577,11 +606,12 @@
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-void ixgb_clear_vfta(struct ixgb_hw *hw)
+void
+ixgb_clear_vfta(struct ixgb_hw *hw)
 {
 	uint32_t offset;
 
-	for (offset = 0; offset < IXGB_VLAN_FILTER_TBL_SIZE; offset++)
+	for(offset = 0; offset < IXGB_VLAN_FILTER_TBL_SIZE; offset++)
 		IXGB_WRITE_REG_ARRAY(hw, VFTA, offset, 0);
 	return;
 }
@@ -592,10 +622,11 @@
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
 
-boolean_t ixgb_setup_fc(struct ixgb_hw * hw)
+boolean_t
+ixgb_setup_fc(struct ixgb_hw *hw)
 {
 	uint32_t ctrl_reg;
-	uint32_t pap_reg = 0;	/* by default, assume no pause time */
+	uint32_t pap_reg = 0;   /* by default, assume no pause time */
 	boolean_t status = TRUE;
 
 	DEBUGFUNC("ixgb_setup_fc");
@@ -660,16 +691,16 @@
 	 * ability to transmit pause frames in not enabled, then these
 	 * registers will be set to 0.
 	 */
-	if (!(hw->fc.type & ixgb_fc_tx_pause)) {
+	if(!(hw->fc.type & ixgb_fc_tx_pause)) {
 		IXGB_WRITE_REG(hw, FCRTL, 0);
 		IXGB_WRITE_REG(hw, FCRTH, 0);
 	} else {
-		/* We need to set up the Receive Threshold high and low water
-		 * marks as well as (optionally) enabling the transmission of XON frames.
-		 */
-		if (hw->fc.send_xon) {
+	   /* We need to set up the Receive Threshold high and low water
+	    * marks as well as (optionally) enabling the transmission of XON
+	    * frames. */
+		if(hw->fc.send_xon) {
 			IXGB_WRITE_REG(hw, FCRTL,
-				       (hw->fc.low_water | IXGB_FCRTL_XONE));
+				(hw->fc.low_water | IXGB_FCRTL_XONE));
 		} else {
 			IXGB_WRITE_REG(hw, FCRTL, hw->fc.low_water);
 		}
@@ -694,9 +725,10 @@
  * read command.
  *****************************************************************************/
 uint16_t
-ixgb_read_phy_reg(struct ixgb_hw * hw,
-		  uint32_t reg_address,
-		  uint32_t phy_address, uint32_t device_type)
+ixgb_read_phy_reg(struct ixgb_hw *hw,
+		uint32_t reg_address,
+		uint32_t phy_address,
+		uint32_t device_type)
 {
 	uint32_t i;
 	uint32_t data;
@@ -721,7 +753,8 @@
     ** from the CPU Write to the Ready bit assertion.
     **************************************************************/
 
-	for (i = 0; i < 10; i++) {
+	for(i = 0; i < 10; i++)
+	{
 		udelay(10);
 
 		command = IXGB_READ_REG(hw, MSCA);
@@ -747,7 +780,8 @@
     ** from the CPU Write to the Ready bit assertion.
     **************************************************************/
 
-	for (i = 0; i < 10; i++) {
+	for(i = 0; i < 10; i++)
+	{
 		udelay(10);
 
 		command = IXGB_READ_REG(hw, MSCA);
@@ -763,7 +797,7 @@
 	 */
 	data = IXGB_READ_REG(hw, MSRWD);
 	data >>= IXGB_MSRWD_READ_DATA_SHIFT;
-	return ((uint16_t) data);
+	return((uint16_t) data);
 }
 
 /******************************************************************************
@@ -785,8 +819,10 @@
  *****************************************************************************/
 void
 ixgb_write_phy_reg(struct ixgb_hw *hw,
-		   uint32_t reg_address,
-		   uint32_t phy_address, uint32_t device_type, uint16_t data)
+			uint32_t reg_address,
+			uint32_t phy_address,
+			uint32_t device_type,
+			uint16_t data)
 {
 	uint32_t i;
 	uint32_t command = 0;
@@ -796,24 +832,25 @@
 	ASSERT(device_type <= IXGB_MAX_PHY_DEV_TYPE);
 
 	/* Put the data in the MDIO Read/Write Data register */
-	IXGB_WRITE_REG(hw, MSRWD, (uint32_t) data);
+	IXGB_WRITE_REG(hw, MSRWD, (uint32_t)data);
 
 	/* Setup and write the address cycle command */
-	command = ((reg_address << IXGB_MSCA_NP_ADDR_SHIFT) |
-		   (device_type << IXGB_MSCA_DEV_TYPE_SHIFT) |
-		   (phy_address << IXGB_MSCA_PHY_ADDR_SHIFT) |
-		   (IXGB_MSCA_ADDR_CYCLE | IXGB_MSCA_MDI_COMMAND));
+	command = ((reg_address << IXGB_MSCA_NP_ADDR_SHIFT)  |
+			   (device_type << IXGB_MSCA_DEV_TYPE_SHIFT) |
+			   (phy_address << IXGB_MSCA_PHY_ADDR_SHIFT) |
+			   (IXGB_MSCA_ADDR_CYCLE | IXGB_MSCA_MDI_COMMAND));
 
 	IXGB_WRITE_REG(hw, MSCA, command);
 
-    /**************************************************************
-    ** Check every 10 usec to see if the address cycle completed
-    ** The COMMAND bit will clear when the operation is complete.
-    ** This may take as long as 64 usecs (we'll wait 100 usecs max)
-    ** from the CPU Write to the Ready bit assertion.
-    **************************************************************/
+	/**************************************************************
+	** Check every 10 usec to see if the address cycle completed
+	** The COMMAND bit will clear when the operation is complete.
+	** This may take as long as 64 usecs (we'll wait 100 usecs max)
+	** from the CPU Write to the Ready bit assertion.
+	**************************************************************/
 
-	for (i = 0; i < 10; i++) {
+	for(i = 0; i < 10; i++)
+	{
 		udelay(10);
 
 		command = IXGB_READ_REG(hw, MSCA);
@@ -825,21 +862,22 @@
 	ASSERT((command & IXGB_MSCA_MDI_COMMAND) == 0);
 
 	/* Address cycle complete, setup and write the write command */
-	command = ((reg_address << IXGB_MSCA_NP_ADDR_SHIFT) |
-		   (device_type << IXGB_MSCA_DEV_TYPE_SHIFT) |
-		   (phy_address << IXGB_MSCA_PHY_ADDR_SHIFT) |
-		   (IXGB_MSCA_WRITE | IXGB_MSCA_MDI_COMMAND));
+	command = ((reg_address << IXGB_MSCA_NP_ADDR_SHIFT)  |
+			   (device_type << IXGB_MSCA_DEV_TYPE_SHIFT) |
+			   (phy_address << IXGB_MSCA_PHY_ADDR_SHIFT) |
+			   (IXGB_MSCA_WRITE | IXGB_MSCA_MDI_COMMAND));
 
 	IXGB_WRITE_REG(hw, MSCA, command);
 
-    /**************************************************************
-    ** Check every 10 usec to see if the read command completed
-    ** The COMMAND bit will clear when the operation is complete.
-    ** The write may take as long as 64 usecs (we'll wait 100 usecs max)
-    ** from the CPU Write to the Ready bit assertion.
-    **************************************************************/
+	/**************************************************************
+	** Check every 10 usec to see if the read command completed
+	** The COMMAND bit will clear when the operation is complete.
+	** The write may take as long as 64 usecs (we'll wait 100 usecs max)
+	** from the CPU Write to the Ready bit assertion.
+	**************************************************************/
 
-	for (i = 0; i < 10; i++) {
+	for(i = 0; i < 10; i++)
+	{
 		udelay(10);
 
 		command = IXGB_READ_REG(hw, MSCA);
@@ -860,7 +898,8 @@
  *
  * Called by any function that needs to check the link status of the adapter.
  *****************************************************************************/
-void ixgb_check_for_link(struct ixgb_hw *hw)
+void
+ixgb_check_for_link(struct ixgb_hw *hw)
 {
 	uint32_t status_reg;
 	uint32_t xpcss_reg;
@@ -922,14 +961,15 @@
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-void ixgb_clear_hw_cntrs(struct ixgb_hw *hw)
+void
+ixgb_clear_hw_cntrs(struct ixgb_hw *hw)
 {
 	volatile uint32_t temp_reg;
 
 	DEBUGFUNC("ixgb_clear_hw_cntrs");
 
 	/* if we are stopped or resetting exit gracefully */
-	if (hw->adapter_stopped) {
+	if(hw->adapter_stopped) {
 		DEBUGOUT("Exiting because the adapter is stopped!!!\n");
 		return;
 	}
@@ -1002,7 +1042,8 @@
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-void ixgb_led_on(struct ixgb_hw *hw)
+void
+ixgb_led_on(struct ixgb_hw *hw)
 {
 	uint32_t ctrl0_reg = IXGB_READ_REG(hw, CTRL0);
 
@@ -1017,7 +1058,8 @@
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-void ixgb_led_off(struct ixgb_hw *hw)
+void
+ixgb_led_off(struct ixgb_hw *hw)
 {
 	uint32_t ctrl0_reg = IXGB_READ_REG(hw, CTRL0);
 
@@ -1032,18 +1074,19 @@
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-static void ixgb_get_bus_info(struct ixgb_hw *hw)
+static void
+ixgb_get_bus_info(struct ixgb_hw *hw)
 {
 	uint32_t status_reg;
 
 	status_reg = IXGB_READ_REG(hw, STATUS);
 
 	hw->bus.type = (status_reg & IXGB_STATUS_PCIX_MODE) ?
-	    ixgb_bus_type_pcix : ixgb_bus_type_pci;
+		ixgb_bus_type_pcix : ixgb_bus_type_pci;
 
 	if (hw->bus.type == ixgb_bus_type_pci) {
 		hw->bus.speed = (status_reg & IXGB_STATUS_PCI_SPD) ?
-		    ixgb_bus_speed_66 : ixgb_bus_speed_33;
+			ixgb_bus_speed_66 : ixgb_bus_speed_33;
 	} else {
 		switch (status_reg & IXGB_STATUS_PCIX_SPD_MASK) {
 		case IXGB_STATUS_PCIX_SPD_66:
@@ -1062,7 +1105,7 @@
 	}
 
 	hw->bus.width = (status_reg & IXGB_STATUS_BUS64) ?
-	    ixgb_bus_width_64 : ixgb_bus_width_32;
+		ixgb_bus_width_64 : ixgb_bus_width_32;
 
 	return;
 }
@@ -1073,7 +1116,8 @@
  * mac_addr - pointer to MAC address.
  *
  *****************************************************************************/
-boolean_t mac_addr_valid(uint8_t * mac_addr)
+boolean_t
+mac_addr_valid(uint8_t *mac_addr)
 {
 	boolean_t is_valid = TRUE;
 	DEBUGFUNC("mac_addr_valid");
@@ -1090,9 +1134,11 @@
 	}
 	/* Reject the zero address */
 	else if (mac_addr[0] == 0 &&
-		 mac_addr[1] == 0 &&
-		 mac_addr[2] == 0 &&
-		 mac_addr[3] == 0 && mac_addr[4] == 0 && mac_addr[5] == 0) {
+			 mac_addr[1] == 0 &&
+			 mac_addr[2] == 0 &&
+			 mac_addr[3] == 0 &&
+			 mac_addr[4] == 0 &&
+			 mac_addr[5] == 0) {
 		DEBUGOUT("MAC address is all zeros\n");
 		is_valid = FALSE;
 	}
@@ -1105,7 +1151,8 @@
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-boolean_t ixgb_link_reset(struct ixgb_hw * hw)
+boolean_t
+ixgb_link_reset(struct ixgb_hw *hw)
 {
 	boolean_t link_status = FALSE;
 	uint8_t wait_retries = MAX_RESET_ITERATIONS;
@@ -1135,20 +1182,22 @@
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-void ixgb_optics_reset(struct ixgb_hw *hw)
+void
+ixgb_optics_reset(struct ixgb_hw *hw)
 {
 	if (hw->phy_type == ixgb_phy_type_txn17401) {
 		uint16_t mdio_reg;
 
 		ixgb_write_phy_reg(hw,
-				   MDIO_PMA_PMD_CR1,
-				   IXGB_PHY_ADDRESS,
-				   MDIO_PMA_PMD_DID, MDIO_PMA_PMD_CR1_RESET);
-
-		mdio_reg = ixgb_read_phy_reg(hw,
-					     MDIO_PMA_PMD_CR1,
-					     IXGB_PHY_ADDRESS,
-					     MDIO_PMA_PMD_DID);
+					MDIO_PMA_PMD_CR1,
+					IXGB_PHY_ADDRESS,
+					MDIO_PMA_PMD_DID,
+					MDIO_PMA_PMD_CR1_RESET);
+
+		mdio_reg = ixgb_read_phy_reg( hw,
+						MDIO_PMA_PMD_CR1,
+						IXGB_PHY_ADDRESS,
+						MDIO_PMA_PMD_DID);
 	}
 
 	return;
diff -Nru a/drivers/net/ixgb/ixgb_hw.h b/drivers/net/ixgb/ixgb_hw.h
--- a/drivers/net/ixgb/ixgb_hw.h	2005-01-10 23:54:12 -05:00
+++ b/drivers/net/ixgb/ixgb_hw.h	2005-01-10 23:54:12 -05:00
@@ -616,17 +616,17 @@
 #define IXGB_CONTEXT_DESC_STATUS_DD 0x01
 
 /* Filters */
-#define IXGB_RAR_ENTRIES          16	/* Number of entries in Rx Address array */
 #define IXGB_MC_TBL_SIZE          128	/* Multicast Filter Table (4096 bits) */
 #define IXGB_VLAN_FILTER_TBL_SIZE 128	/* VLAN Filter Table (4096 bits) */
+#define IXGB_RAR_ENTRIES		  3	/* Number of entries in Rx Address array */
 
 #define IXGB_MEMORY_REGISTER_BASE_ADDRESS   0
-#define ENET_HEADER_SIZE            14
-#define ENET_FCS_LENGTH             4
-#define IXGB_MAX_NUM_MULTICAST_ADDRESSES    128
-#define IXGB_MIN_ENET_FRAME_SIZE_WITHOUT_FCS    60
-#define IXGB_MAX_ENET_FRAME_SIZE_WITHOUT_FCS    1514
-#define IXGB_MAX_JUMBO_FRAME_SIZE       0x3F00
+#define ENET_HEADER_SIZE			14
+#define ENET_FCS_LENGTH			 4
+#define IXGB_MAX_NUM_MULTICAST_ADDRESSES	128
+#define IXGB_MIN_ENET_FRAME_SIZE_WITHOUT_FCS	60
+#define IXGB_MAX_ENET_FRAME_SIZE_WITHOUT_FCS	1514
+#define IXGB_MAX_JUMBO_FRAME_SIZE		0x3F00
 
 /* Phy Addresses */
 #define IXGB_OPTICAL_PHY_ADDR 0x0	/* Optical Module phy address */
@@ -789,32 +789,39 @@
 extern boolean_t ixgb_check_for_bad_link(struct ixgb_hw *hw);
 extern boolean_t ixgb_setup_fc(struct ixgb_hw *hw);
 extern void ixgb_clear_hw_cntrs(struct ixgb_hw *hw);
-extern boolean_t mac_addr_valid(uint8_t * mac_addr);
+extern boolean_t mac_addr_valid(uint8_t *mac_addr);
 
 extern uint16_t ixgb_read_phy_reg(struct ixgb_hw *hw,
-				  uint32_t reg_addr,
-				  uint32_t phy_addr, uint32_t device_type);
+				uint32_t reg_addr,
+				uint32_t phy_addr,
+				uint32_t device_type);
 
 extern void ixgb_write_phy_reg(struct ixgb_hw *hw,
-			       uint32_t reg_addr,
-			       uint32_t phy_addr,
-			       uint32_t device_type, uint16_t data);
+				uint32_t reg_addr,
+				uint32_t phy_addr,
+				uint32_t device_type,
+				uint16_t data);
+
+extern void ixgb_rar_set(struct ixgb_hw *hw,
+				uint8_t *addr,
+				uint32_t index);
 
-extern void ixgb_rar_set(struct ixgb_hw *hw, uint8_t * addr, uint32_t index);
 
 /* Filters (multicast, vlan, receive) */
 extern void ixgb_mc_addr_list_update(struct ixgb_hw *hw,
-				     uint8_t * mc_addr_list,
-				     uint32_t mc_addr_count, uint32_t pad);
+				   uint8_t *mc_addr_list,
+				   uint32_t mc_addr_count,
+				   uint32_t pad);
 
 /* Vfta functions */
 extern void ixgb_write_vfta(struct ixgb_hw *hw,
-			    uint32_t offset, uint32_t value);
+				 uint32_t offset,
+				 uint32_t value);
 
 extern void ixgb_clear_vfta(struct ixgb_hw *hw);
 
 /* Access functions to eeprom data */
-void ixgb_get_ee_mac_addr(struct ixgb_hw *hw, uint8_t * mac_addr);
+void ixgb_get_ee_mac_addr(struct ixgb_hw *hw, uint8_t *mac_addr);
 uint16_t ixgb_get_ee_compatibility(struct ixgb_hw *hw);
 uint32_t ixgb_get_ee_pba_number(struct ixgb_hw *hw);
 uint16_t ixgb_get_ee_init_ctrl_reg_1(struct ixgb_hw *hw);
@@ -832,6 +839,9 @@
 /* Everything else */
 void ixgb_led_on(struct ixgb_hw *hw);
 void ixgb_led_off(struct ixgb_hw *hw);
-void ixgb_write_pci_cfg(struct ixgb_hw *hw, uint32_t reg, uint16_t * value);
+void ixgb_write_pci_cfg(struct ixgb_hw *hw,
+			 uint32_t reg,
+			 uint16_t * value);
 
-#endif				/* _IXGB_HW_H_ */
+
+#endif /* _IXGB_HW_H_ */
diff -Nru a/drivers/net/ixgb/ixgb_ids.h b/drivers/net/ixgb/ixgb_ids.h
--- a/drivers/net/ixgb/ixgb_ids.h	2005-01-10 23:54:12 -05:00
+++ b/drivers/net/ixgb/ixgb_ids.h	2005-01-10 23:54:12 -05:00
@@ -33,21 +33,16 @@
 ** The Device and Vendor IDs for 10 Gigabit MACs
 **********************************************************************/
 
-#define INTEL_VENDOR_ID         0x8086
-#define INTEL_SUBVENDOR_ID      0x8086
+#define INTEL_VENDOR_ID             0x8086
+#define INTEL_SUBVENDOR_ID          0x8086
 
-#define IXGB_DEVICE_ID_82597EX      0x1048
-#define IXGB_DEVICE_ID_82597EX_SR   0x1A48
 
-#define IXGB_SUBDEVICE_ID_A11F  0xA11F
-#define IXGB_SUBDEVICE_ID_A01F  0xA01F
+#define IXGB_DEVICE_ID_82597EX      0x1048   
+#define IXGB_DEVICE_ID_82597EX_SR   0x1A48   
+#define IXGB_DEVICE_ID_82597EX_LR   0x1B48
+#define IXGB_SUBDEVICE_ID_A11F      0xA11F   
+#define IXGB_SUBDEVICE_ID_A01F      0xA01F   
 
-#define IXGB_SUBDEVICE_ID_A15F  0xA15F
-#define IXGB_SUBDEVICE_ID_A05F  0xA05F
-
-#define IXGB_SUBDEVICE_ID_A12F  0xA12F
-#define IXGB_SUBDEVICE_ID_A02F  0xA02F
-
-#endif				/* #ifndef _IXGB_IDS_H_ */
+#endif /* #ifndef _IXGB_IDS_H_ */
 
 /* End of File */
diff -Nru a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
--- a/drivers/net/ixgb/ixgb_main.c	2005-01-10 23:54:12 -05:00
+++ b/drivers/net/ixgb/ixgb_main.c	2005-01-10 23:54:12 -05:00
@@ -28,10 +28,23 @@
 
 #include "ixgb.h"
 
+/* Change Log
+ * 1.0.84 10/26/04
+ * - reset buffer_info->dma in Tx resource cleanup logic
+ * 1.0.83 10/12/04
+ * - sparse cleanup - shemminger@osdl.org
+ * - fix tx resource cleanup logic
+ */
+
 char ixgb_driver_name[] = "ixgb";
 char ixgb_driver_string[] = "Intel(R) PRO/10GbE Network Driver";
-char ixgb_driver_version[] = "1.0.66-k2";
-char ixgb_copyright[] = "Copyright (c) 2001-2004 Intel Corporation.";
+#ifndef CONFIG_IXGB_NAPI
+#define DRIVERNAPI
+#else
+#define DRIVERNAPI "-NAPI"
+#endif
+char ixgb_driver_version[] = "1.0.87-k2"DRIVERNAPI;
+char ixgb_copyright[] = "Copyright (c) 1999-2004 Intel Corporation.";
 
 /* ixgb_pci_tbl - PCI Device ID Table
  *
@@ -46,6 +59,8 @@
 	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
 	{INTEL_VENDOR_ID, IXGB_DEVICE_ID_82597EX_SR,
 	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
+	{INTEL_VENDOR_ID, IXGB_DEVICE_ID_82597EX_LR,  
+	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
 
 	/* required last entry */
 	{0,}
@@ -55,11 +70,14 @@
 
 /* Local Function Prototypes */
 
-static inline void ixgb_irq_disable(struct ixgb_adapter *adapter);
-static inline void ixgb_irq_enable(struct ixgb_adapter *adapter);
 int ixgb_up(struct ixgb_adapter *adapter);
 void ixgb_down(struct ixgb_adapter *adapter, boolean_t kill_watchdog);
 void ixgb_reset(struct ixgb_adapter *adapter);
+int ixgb_setup_tx_resources(struct ixgb_adapter *adapter);
+int ixgb_setup_rx_resources(struct ixgb_adapter *adapter);
+void ixgb_free_tx_resources(struct ixgb_adapter *adapter);
+void ixgb_free_rx_resources(struct ixgb_adapter *adapter);
+void ixgb_update_stats(struct ixgb_adapter *adapter);
 
 static int ixgb_init_module(void);
 static void ixgb_exit_module(void);
@@ -68,27 +86,19 @@
 static int ixgb_sw_init(struct ixgb_adapter *adapter);
 static int ixgb_open(struct net_device *netdev);
 static int ixgb_close(struct net_device *netdev);
-static int ixgb_setup_tx_resources(struct ixgb_adapter *adapter);
-static int ixgb_setup_rx_resources(struct ixgb_adapter *adapter);
 static void ixgb_configure_tx(struct ixgb_adapter *adapter);
 static void ixgb_configure_rx(struct ixgb_adapter *adapter);
 static void ixgb_setup_rctl(struct ixgb_adapter *adapter);
 static void ixgb_clean_tx_ring(struct ixgb_adapter *adapter);
 static void ixgb_clean_rx_ring(struct ixgb_adapter *adapter);
-static void ixgb_free_tx_resources(struct ixgb_adapter *adapter);
-static void ixgb_free_rx_resources(struct ixgb_adapter *adapter);
 static void ixgb_set_multi(struct net_device *netdev);
 static void ixgb_watchdog(unsigned long data);
 static int ixgb_xmit_frame(struct sk_buff *skb, struct net_device *netdev);
 static struct net_device_stats *ixgb_get_stats(struct net_device *netdev);
 static int ixgb_change_mtu(struct net_device *netdev, int new_mtu);
 static int ixgb_set_mac(struct net_device *netdev, void *p);
-static void ixgb_update_stats(struct ixgb_adapter *adapter);
 static irqreturn_t ixgb_intr(int irq, void *data, struct pt_regs *regs);
 static boolean_t ixgb_clean_tx_irq(struct ixgb_adapter *adapter);
-static inline void ixgb_rx_checksum(struct ixgb_adapter *adapter,
-				    struct ixgb_rx_desc *rx_desc,
-				    struct sk_buff *skb);
 #ifdef CONFIG_IXGB_NAPI
 static int ixgb_clean(struct net_device *netdev, int *budget);
 static boolean_t ixgb_clean_rx_irq(struct ixgb_adapter *adapter,
@@ -97,6 +107,7 @@
 static boolean_t ixgb_clean_rx_irq(struct ixgb_adapter *adapter);
 #endif
 static void ixgb_alloc_rx_buffers(struct ixgb_adapter *adapter);
+void set_ethtool_ops(struct net_device *netdev);
 static void ixgb_tx_timeout(struct net_device *dev);
 static void ixgb_tx_timeout_task(struct net_device *dev);
 static void ixgb_vlan_rx_register(struct net_device *netdev,
@@ -123,7 +134,6 @@
 /* Exported from other modules */
 
 extern void ixgb_check_options(struct ixgb_adapter *adapter);
-extern struct ethtool_ops ixgb_ethtool_ops;
 
 static struct pci_driver ixgb_driver = {
 	.name = ixgb_driver_name,
@@ -152,7 +162,8 @@
  * loaded. All it does is register with the PCI subsystem.
  **/
 
-static int __init ixgb_init_module(void)
+static int __init
+ixgb_init_module(void)
 {
 	int ret;
 	printk(KERN_INFO "%s - version %s\n",
@@ -161,7 +172,7 @@
 	printk(KERN_INFO "%s\n", ixgb_copyright);
 
 	ret = pci_module_init(&ixgb_driver);
-	if (ret >= 0) {
+	if(ret >= 0) {
 		register_reboot_notifier(&ixgb_notifier_reboot);
 	}
 	return ret;
@@ -176,7 +187,8 @@
  * from memory.
  **/
 
-static void __exit ixgb_exit_module(void)
+static void __exit
+ixgb_exit_module(void)
 {
 	unregister_reboot_notifier(&ixgb_notifier_reboot);
 	pci_unregister_driver(&ixgb_driver);
@@ -189,7 +201,8 @@
  * @adapter: board private structure
  **/
 
-static inline void ixgb_irq_disable(struct ixgb_adapter *adapter)
+static inline void
+ixgb_irq_disable(struct ixgb_adapter *adapter)
 {
 	atomic_inc(&adapter->irq_sem);
 	IXGB_WRITE_REG(&adapter->hw, IMC, ~0);
@@ -202,17 +215,19 @@
  * @adapter: board private structure
  **/
 
-static inline void ixgb_irq_enable(struct ixgb_adapter *adapter)
+static inline void
+ixgb_irq_enable(struct ixgb_adapter *adapter)
 {
-	if (atomic_dec_and_test(&adapter->irq_sem)) {
+	if(atomic_dec_and_test(&adapter->irq_sem)) {
 		IXGB_WRITE_REG(&adapter->hw, IMS,
-			       IXGB_INT_RXT0 | IXGB_INT_RXDMT0 | IXGB_INT_TXDW |
-			       IXGB_INT_RXO | IXGB_INT_LSC);
+			   IXGB_INT_RXT0 | IXGB_INT_RXDMT0 | IXGB_INT_TXDW |
+			   IXGB_INT_RXO | IXGB_INT_LSC);
 		IXGB_WRITE_FLUSH(&adapter->hw);
 	}
 }
 
-int ixgb_up(struct ixgb_adapter *adapter)
+int
+ixgb_up(struct ixgb_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 	int err;
@@ -230,27 +245,44 @@
 	ixgb_configure_rx(adapter);
 	ixgb_alloc_rx_buffers(adapter);
 
-	if ((err = request_irq(adapter->pdev->irq, &ixgb_intr,
-			       SA_SHIRQ | SA_SAMPLE_RANDOM,
-			       netdev->name, netdev)))
+#ifdef CONFIG_PCI_MSI
+	{
+	boolean_t pcix = (IXGB_READ_REG(&adapter->hw, STATUS) & 
+						  IXGB_STATUS_PCIX_MODE) ? TRUE : FALSE;
+	adapter->have_msi = TRUE;
+
+	if (!pcix)
+	   adapter->have_msi = FALSE;
+	else if((err = pci_enable_msi(adapter->pdev))) {
+		printk (KERN_ERR
+		 "Unable to allocate MSI interrupt Error: %d\n", err);
+		adapter->have_msi = FALSE;
+		/* proceed to try to request regular interrupt */
+	}
+	}
+
+#endif
+	if((err = request_irq(adapter->pdev->irq, &ixgb_intr,
+				  SA_SHIRQ | SA_SAMPLE_RANDOM,
+				  netdev->name, netdev)))
 		return err;
 
 	/* disable interrupts and get the hardware into a known state */
 	IXGB_WRITE_REG(&adapter->hw, IMC, 0xffffffff);
 
-	if ((hw->max_frame_size != max_frame) ||
-	    (hw->max_frame_size !=
-	     (IXGB_READ_REG(hw, MFS) >> IXGB_MFS_SHIFT))) {
+	if((hw->max_frame_size != max_frame) ||
+		(hw->max_frame_size !=
+		(IXGB_READ_REG(hw, MFS) >> IXGB_MFS_SHIFT))) {
 
 		hw->max_frame_size = max_frame;
 
 		IXGB_WRITE_REG(hw, MFS, hw->max_frame_size << IXGB_MFS_SHIFT);
 
-		if (hw->max_frame_size >
-		    IXGB_MAX_ENET_FRAME_SIZE_WITHOUT_FCS + ENET_FCS_LENGTH) {
+		if(hw->max_frame_size >
+		   IXGB_MAX_ENET_FRAME_SIZE_WITHOUT_FCS + ENET_FCS_LENGTH) {
 			uint32_t ctrl0 = IXGB_READ_REG(hw, CTRL0);
 
-			if (!(ctrl0 & IXGB_CTRL0_JFE)) {
+			if(!(ctrl0 & IXGB_CTRL0_JFE)) {
 				ctrl0 |= IXGB_CTRL0_JFE;
 				IXGB_WRITE_REG(hw, CTRL0, ctrl0);
 			}
@@ -263,13 +295,19 @@
 	return 0;
 }
 
-void ixgb_down(struct ixgb_adapter *adapter, boolean_t kill_watchdog)
+void
+ixgb_down(struct ixgb_adapter *adapter, boolean_t kill_watchdog)
 {
 	struct net_device *netdev = adapter->netdev;
 
 	ixgb_irq_disable(adapter);
 	free_irq(adapter->pdev->irq, netdev);
-	if (kill_watchdog)
+#ifdef CONFIG_PCI_MSI
+	if(adapter->have_msi == TRUE)
+		pci_disable_msi(adapter->pdev);
+
+#endif
+	if(kill_watchdog)
 		del_timer_sync(&adapter->watchdog_timer);
 	adapter->link_speed = 0;
 	adapter->link_duplex = 0;
@@ -281,11 +319,12 @@
 	ixgb_clean_rx_ring(adapter);
 }
 
-void ixgb_reset(struct ixgb_adapter *adapter)
+void
+ixgb_reset(struct ixgb_adapter *adapter)
 {
 
 	ixgb_adapter_stop(&adapter->hw);
-	if (!ixgb_init_hw(&adapter->hw))
+	if(!ixgb_init_hw(&adapter->hw))
 		IXGB_DBG("ixgb_init_hw failed.\n");
 }
 
@@ -302,7 +341,8 @@
  **/
 
 static int __devinit
-ixgb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
+ixgb_probe(struct pci_dev *pdev,
+		const struct pci_device_id *ent)
 {
 	struct net_device *netdev = NULL;
 	struct ixgb_adapter *adapter;
@@ -313,26 +353,26 @@
 	int i;
 	int err;
 
-	if ((err = pci_enable_device(pdev)))
+	if((err = pci_enable_device(pdev)))
 		return err;
 
-	if (!(err = pci_set_dma_mask(pdev, DMA_64BIT_MASK))) {
+	if(!(err = pci_set_dma_mask(pdev, DMA_64BIT_MASK))) {
 		pci_using_dac = 1;
 	} else {
-		if ((err = pci_set_dma_mask(pdev, DMA_32BIT_MASK))) {
+		if((err = pci_set_dma_mask(pdev, DMA_32BIT_MASK))) {
 			IXGB_ERR("No usable DMA configuration, aborting\n");
 			return err;
 		}
 		pci_using_dac = 0;
 	}
 
-	if ((err = pci_request_regions(pdev, ixgb_driver_name)))
+	if((err = pci_request_regions(pdev, ixgb_driver_name)))
 		return err;
 
 	pci_set_master(pdev);
 
 	netdev = alloc_etherdev(sizeof(struct ixgb_adapter));
-	if (!netdev) {
+	if(!netdev) {
 		err = -ENOMEM;
 		goto err_alloc_etherdev;
 	}
@@ -350,15 +390,15 @@
 	mmio_len = pci_resource_len(pdev, BAR_0);
 
 	adapter->hw.hw_addr = ioremap(mmio_start, mmio_len);
-	if (!adapter->hw.hw_addr) {
+	if(!adapter->hw.hw_addr) {
 		err = -EIO;
 		goto err_ioremap;
 	}
 
-	for (i = BAR_1; i <= BAR_5; i++) {
-		if (pci_resource_len(pdev, i) == 0)
+	for(i = BAR_1; i <= BAR_5; i++) {
+		if(pci_resource_len(pdev, i) == 0)
 			continue;
-		if (pci_resource_flags(pdev, i) & IORESOURCE_IO) {
+		if(pci_resource_flags(pdev, i) & IORESOURCE_IO) {
 			adapter->hw.io_base = pci_resource_start(pdev, i);
 			break;
 		}
@@ -371,9 +411,9 @@
 	netdev->set_multicast_list = &ixgb_set_multi;
 	netdev->set_mac_address = &ixgb_set_mac;
 	netdev->change_mtu = &ixgb_change_mtu;
+	set_ethtool_ops(netdev);
 	netdev->tx_timeout = &ixgb_tx_timeout;
 	netdev->watchdog_timeo = HZ;
-	SET_ETHTOOL_OPS(netdev, &ixgb_ethtool_ops);
 #ifdef CONFIG_IXGB_NAPI
 	netdev->poll = &ixgb_clean;
 	netdev->weight = 64;
@@ -395,22 +435,24 @@
 
 	/* setup the private structure */
 
-	if ((err = ixgb_sw_init(adapter)))
+	if((err = ixgb_sw_init(adapter)))
 		goto err_sw_init;
 
 	netdev->features = NETIF_F_SG |
-	    NETIF_F_HW_CSUM |
-	    NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER;
+			   NETIF_F_HW_CSUM |
+			   NETIF_F_HW_VLAN_TX |
+			   NETIF_F_HW_VLAN_RX |
+			   NETIF_F_HW_VLAN_FILTER;
 #ifdef NETIF_F_TSO
 	netdev->features |= NETIF_F_TSO;
 #endif
 
-	if (pci_using_dac)
+	if(pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
 
 	/* make sure the EEPROM is good */
 
-	if (!ixgb_validate_eeprom_checksum(&adapter->hw)) {
+	if(!ixgb_validate_eeprom_checksum(&adapter->hw)) {
 		printk(KERN_ERR "The EEPROM Checksum Is Not Valid\n");
 		err = -EIO;
 		goto err_eeprom;
@@ -418,7 +460,7 @@
 
 	ixgb_get_ee_mac_addr(&adapter->hw, netdev->dev_addr);
 
-	if (!is_valid_ether_addr(netdev->dev_addr)) {
+	if(!is_valid_ether_addr(netdev->dev_addr)) {
 		err = -EIO;
 		goto err_eeprom;
 	}
@@ -432,7 +474,7 @@
 	INIT_WORK(&adapter->tx_timeout_task,
 		  (void (*)(void *))ixgb_tx_timeout_task, netdev);
 
-	if ((err = register_netdev(netdev)))
+	if((err = register_netdev(netdev)))
 		goto err_register;
 
 	/* we're going to reset, so assume we have no link for now */
@@ -441,7 +483,7 @@
 	netif_stop_queue(netdev);
 
 	printk(KERN_INFO "%s: Intel(R) PRO/10GbE Network Connection\n",
-	       netdev->name);
+		   netdev->name);
 	ixgb_check_options(adapter);
 	/* reset the hardware with the new settings */
 
@@ -450,13 +492,13 @@
 	cards_found++;
 	return 0;
 
-      err_register:
-      err_sw_init:
-      err_eeprom:
+err_register:
+err_sw_init:
+err_eeprom:
 	iounmap(adapter->hw.hw_addr);
-      err_ioremap:
+err_ioremap:
 	free_netdev(netdev);
-      err_alloc_etherdev:
+err_alloc_etherdev:
 	pci_release_regions(pdev);
 	return err;
 }
@@ -471,7 +513,8 @@
  * memory.
  **/
 
-static void __devexit ixgb_remove(struct pci_dev *pdev)
+static void __devexit
+ixgb_remove(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct ixgb_adapter *adapter = netdev->priv;
@@ -493,7 +536,8 @@
  * OS network device settings (MTU size).
  **/
 
-static int __devinit ixgb_sw_init(struct ixgb_adapter *adapter)
+static int __devinit
+ixgb_sw_init(struct ixgb_adapter *adapter)
 {
 	struct ixgb_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
@@ -510,9 +554,10 @@
 
 	hw->max_frame_size = netdev->mtu + ENET_HEADER_SIZE + ENET_FCS_LENGTH;
 
-	if ((hw->device_id == IXGB_DEVICE_ID_82597EX)
-	    || (hw->device_id == IXGB_DEVICE_ID_82597EX_SR))
-		hw->mac_type = ixgb_82597;
+	if((hw->device_id == IXGB_DEVICE_ID_82597EX)
+	   ||(hw->device_id == IXGB_DEVICE_ID_82597EX_LR)
+	   ||(hw->device_id == IXGB_DEVICE_ID_82597EX_SR))
+			hw->mac_type = ixgb_82597;
 	else {
 		/* should never have loaded on this device */
 		printk(KERN_ERR "ixgb: unsupported device id\n");
@@ -540,31 +585,32 @@
  * and the stack is notified that the interface is ready.
  **/
 
-static int ixgb_open(struct net_device *netdev)
+static int
+ixgb_open(struct net_device *netdev)
 {
 	struct ixgb_adapter *adapter = netdev->priv;
 	int err;
 
 	/* allocate transmit descriptors */
 
-	if ((err = ixgb_setup_tx_resources(adapter)))
+	if((err = ixgb_setup_tx_resources(adapter)))
 		goto err_setup_tx;
 
 	/* allocate receive descriptors */
 
-	if ((err = ixgb_setup_rx_resources(adapter)))
+	if((err = ixgb_setup_rx_resources(adapter)))
 		goto err_setup_rx;
 
-	if ((err = ixgb_up(adapter)))
+	if((err = ixgb_up(adapter)))
 		goto err_up;
 
 	return 0;
 
-      err_up:
+err_up:
 	ixgb_free_rx_resources(adapter);
-      err_setup_rx:
+err_setup_rx:
 	ixgb_free_tx_resources(adapter);
-      err_setup_tx:
+err_setup_tx:
 	ixgb_reset(adapter);
 
 	return err;
@@ -582,7 +628,8 @@
  * hardware, and all transmit and receive resources are freed.
  **/
 
-static int ixgb_close(struct net_device *netdev)
+static int
+ixgb_close(struct net_device *netdev)
 {
 	struct ixgb_adapter *adapter = netdev->priv;
 
@@ -601,15 +648,16 @@
  * Return 0 on success, negative on failure
  **/
 
-static int ixgb_setup_tx_resources(struct ixgb_adapter *adapter)
+int
+ixgb_setup_tx_resources(struct ixgb_adapter *adapter)
 {
 	struct ixgb_desc_ring *txdr = &adapter->tx_ring;
 	struct pci_dev *pdev = adapter->pdev;
 	int size;
 
 	size = sizeof(struct ixgb_buffer) * txdr->count;
-	txdr->buffer_info = kmalloc(size, GFP_KERNEL);
-	if (!txdr->buffer_info) {
+	txdr->buffer_info = vmalloc(size);
+	if(!txdr->buffer_info) {
 		return -ENOMEM;
 	}
 	memset(txdr->buffer_info, 0, size);
@@ -620,8 +668,8 @@
 	IXGB_ROUNDUP(txdr->size, 4096);
 
 	txdr->desc = pci_alloc_consistent(pdev, txdr->size, &txdr->dma);
-	if (!txdr->desc) {
-		kfree(txdr->buffer_info);
+	if(!txdr->desc) {
+		vfree(txdr->buffer_info);
 		return -ENOMEM;
 	}
 	memset(txdr->desc, 0, txdr->size);
@@ -639,7 +687,8 @@
  * Configure the Tx unit of the MAC after a reset.
  **/
 
-static void ixgb_configure_tx(struct ixgb_adapter *adapter)
+static void
+ixgb_configure_tx(struct ixgb_adapter *adapter)
 {
 	uint64_t tdba = adapter->tx_ring.dma;
 	uint32_t tdlen = adapter->tx_ring.count * sizeof(struct ixgb_tx_desc);
@@ -679,8 +728,8 @@
 
 	/* Setup Transmit Descriptor Settings for this adapter */
 	adapter->tx_cmd_type =
-	    IXGB_TX_DESC_TYPE
-	    | (adapter->tx_int_delay_enable ? IXGB_TX_DESC_CMD_IDE : 0);
+		IXGB_TX_DESC_TYPE 
+		| (adapter->tx_int_delay_enable ? IXGB_TX_DESC_CMD_IDE : 0);
 }
 
 /**
@@ -690,15 +739,16 @@
  * Returns 0 on success, negative on failure
  **/
 
-static int ixgb_setup_rx_resources(struct ixgb_adapter *adapter)
+int
+ixgb_setup_rx_resources(struct ixgb_adapter *adapter)
 {
 	struct ixgb_desc_ring *rxdr = &adapter->rx_ring;
 	struct pci_dev *pdev = adapter->pdev;
 	int size;
 
 	size = sizeof(struct ixgb_buffer) * rxdr->count;
-	rxdr->buffer_info = kmalloc(size, GFP_KERNEL);
-	if (!rxdr->buffer_info) {
+	rxdr->buffer_info = vmalloc(size);
+	if(!rxdr->buffer_info) {
 		return -ENOMEM;
 	}
 	memset(rxdr->buffer_info, 0, size);
@@ -710,8 +760,8 @@
 
 	rxdr->desc = pci_alloc_consistent(pdev, rxdr->size, &rxdr->dma);
 
-	if (!rxdr->desc) {
-		kfree(rxdr->buffer_info);
+	if(!rxdr->desc) {
+		vfree(rxdr->buffer_info);
 		return -ENOMEM;
 	}
 	memset(rxdr->desc, 0, rxdr->size);
@@ -727,7 +777,8 @@
  * @adapter: Board private structure
  **/
 
-static void ixgb_setup_rctl(struct ixgb_adapter *adapter)
+static void
+ixgb_setup_rctl(struct ixgb_adapter *adapter)
 {
 	uint32_t rctl;
 
@@ -736,9 +787,9 @@
 	rctl &= ~(3 << IXGB_RCTL_MO_SHIFT);
 
 	rctl |=
-	    IXGB_RCTL_BAM | IXGB_RCTL_RDMTS_1_2 |
-	    IXGB_RCTL_RXEN | IXGB_RCTL_CFF |
-	    (adapter->hw.mc_filter_type << IXGB_RCTL_MO_SHIFT);
+		IXGB_RCTL_BAM | IXGB_RCTL_RDMTS_1_2 | 
+		IXGB_RCTL_RXEN | IXGB_RCTL_CFF | 
+		(adapter->hw.mc_filter_type << IXGB_RCTL_MO_SHIFT);
 
 	rctl |= IXGB_RCTL_SECRC;
 
@@ -768,7 +819,8 @@
  * Configure the Rx unit of the MAC after a reset.
  **/
 
-static void ixgb_configure_rx(struct ixgb_adapter *adapter)
+static void
+ixgb_configure_rx(struct ixgb_adapter *adapter)
 {
 	uint64_t rdba = adapter->rx_ring.dma;
 	uint32_t rdlen = adapter->rx_ring.count * sizeof(struct ixgb_rx_desc);
@@ -797,51 +849,14 @@
 	IXGB_WRITE_REG(hw, RDH, 0);
 	IXGB_WRITE_REG(hw, RDT, 0);
 
-	/* burst 16 or burst when RXT0 */
-	rxdctl = RXDCTL_WTHRESH_DEFAULT << IXGB_RXDCTL_WTHRESH_SHIFT
-	    | RXDCTL_HTHRESH_DEFAULT << IXGB_RXDCTL_HTHRESH_SHIFT
-	    | RXDCTL_PTHRESH_DEFAULT << IXGB_RXDCTL_PTHRESH_SHIFT;
+						/* burst 16 or burst when RXT0*/
+	rxdctl =  RXDCTL_WTHRESH_DEFAULT << IXGB_RXDCTL_WTHRESH_SHIFT 
+			| RXDCTL_HTHRESH_DEFAULT << IXGB_RXDCTL_HTHRESH_SHIFT 
+			| RXDCTL_PTHRESH_DEFAULT << IXGB_RXDCTL_PTHRESH_SHIFT;
 	IXGB_WRITE_REG(hw, RXDCTL, rxdctl);
 
-	if (adapter->raidc) {
-		uint32_t raidc;
-		uint8_t poll_threshold;
-
-		/* Poll every rx_int_delay period, if RBD exists
-		 * Receive Backlog Detection is set to <threshold> 
-		 * Rx Descriptors
-		 * max is 0x3F == set to poll when 504 RxDesc left 
-		 * min is 0 */
-
-		/* polling times are 1 == 0.8192us
-		   2 == 1.6384us
-		   3 == 3.2768us etc
-		   ...
-		   511 == 418 us
-		 */
-#define IXGB_RAIDC_POLL_DEFAULT 122	/* set to poll every ~100 us under load 
-					   also known as 10000 interrupts / sec */
-
-		/* divide this by 2^3 (8) to get a register size count */
-		poll_threshold = ((adapter->rx_ring.count - 1) >> 3);
-		/* poll at half of that size */
-		poll_threshold >>= 1;
-		/* make sure its not bigger than our max */
-		poll_threshold &= 0x3F;
-
-		raidc = IXGB_RAIDC_EN |	/* turn on raidc style moderation */
-		    IXGB_RAIDC_RXT_GATE |	/* don't interrupt with rxt0 while
-						   in RBD mode (polling) */
-		    (IXGB_RAIDC_POLL_DEFAULT << IXGB_RAIDC_POLL_SHIFT) |
-		    /* this sets the regular "min interrupt delay" */
-		    (adapter->rx_int_delay << IXGB_RAIDC_DELAY_SHIFT) |
-		    poll_threshold;
-
-		IXGB_WRITE_REG(hw, RAIDC, raidc);
-	}
-
 	/* Enable Receive Checksum Offload for TCP and UDP */
-	if (adapter->rx_csum == TRUE) {
+	if(adapter->rx_csum == TRUE) {
 		rxcsum = IXGB_READ_REG(hw, RXCSUM);
 		rxcsum |= IXGB_RXCSUM_TUOFL;
 		IXGB_WRITE_REG(hw, RXCSUM, rxcsum);
@@ -859,13 +874,14 @@
  * Free all transmit software resources
  **/
 
-static void ixgb_free_tx_resources(struct ixgb_adapter *adapter)
+void
+ixgb_free_tx_resources(struct ixgb_adapter *adapter)
 {
 	struct pci_dev *pdev = adapter->pdev;
 
 	ixgb_clean_tx_ring(adapter);
 
-	kfree(adapter->tx_ring.buffer_info);
+	vfree(adapter->tx_ring.buffer_info);
 	adapter->tx_ring.buffer_info = NULL;
 
 	pci_free_consistent(pdev, adapter->tx_ring.size,
@@ -874,33 +890,42 @@
 	adapter->tx_ring.desc = NULL;
 }
 
+static inline void
+ixgb_unmap_and_free_tx_resource(struct ixgb_adapter *adapter,
+					struct ixgb_buffer *buffer_info)
+{
+	struct pci_dev *pdev = adapter->pdev;
+	if(buffer_info->dma) {
+		pci_unmap_page(pdev,
+			   buffer_info->dma,
+			   buffer_info->length,
+			   PCI_DMA_TODEVICE);
+		buffer_info->dma = 0;
+	}
+	if(buffer_info->skb) {
+		dev_kfree_skb_any(buffer_info->skb);
+		buffer_info->skb = NULL;
+	}
+}
+
 /**
  * ixgb_clean_tx_ring - Free Tx Buffers
  * @adapter: board private structure
  **/
 
-static void ixgb_clean_tx_ring(struct ixgb_adapter *adapter)
+static void
+ixgb_clean_tx_ring(struct ixgb_adapter *adapter)
 {
 	struct ixgb_desc_ring *tx_ring = &adapter->tx_ring;
 	struct ixgb_buffer *buffer_info;
-	struct pci_dev *pdev = adapter->pdev;
 	unsigned long size;
 	unsigned int i;
 
 	/* Free all the Tx ring sk_buffs */
 
-	for (i = 0; i < tx_ring->count; i++) {
+	for(i = 0; i < tx_ring->count; i++) {
 		buffer_info = &tx_ring->buffer_info[i];
-		if (buffer_info->skb) {
-
-			pci_unmap_page(pdev,
-				       buffer_info->dma,
-				       buffer_info->length, PCI_DMA_TODEVICE);
-
-			dev_kfree_skb(buffer_info->skb);
-
-			buffer_info->skb = NULL;
-		}
+		ixgb_unmap_and_free_tx_resource(adapter, buffer_info);
 	}
 
 	size = sizeof(struct ixgb_buffer) * tx_ring->count;
@@ -924,14 +949,15 @@
  * Free all receive software resources
  **/
 
-static void ixgb_free_rx_resources(struct ixgb_adapter *adapter)
+void
+ixgb_free_rx_resources(struct ixgb_adapter *adapter)
 {
 	struct ixgb_desc_ring *rx_ring = &adapter->rx_ring;
 	struct pci_dev *pdev = adapter->pdev;
 
 	ixgb_clean_rx_ring(adapter);
 
-	kfree(rx_ring->buffer_info);
+	vfree(rx_ring->buffer_info);
 	rx_ring->buffer_info = NULL;
 
 	pci_free_consistent(pdev, rx_ring->size, rx_ring->desc, rx_ring->dma);
@@ -944,7 +970,8 @@
  * @adapter: board private structure
  **/
 
-static void ixgb_clean_rx_ring(struct ixgb_adapter *adapter)
+static void
+ixgb_clean_rx_ring(struct ixgb_adapter *adapter)
 {
 	struct ixgb_desc_ring *rx_ring = &adapter->rx_ring;
 	struct ixgb_buffer *buffer_info;
@@ -954,9 +981,9 @@
 
 	/* Free all the Rx ring sk_buffs */
 
-	for (i = 0; i < rx_ring->count; i++) {
+	for(i = 0; i < rx_ring->count; i++) {
 		buffer_info = &rx_ring->buffer_info[i];
-		if (buffer_info->skb) {
+		if(buffer_info->skb) {
 
 			pci_unmap_single(pdev,
 					 buffer_info->dma,
@@ -991,12 +1018,13 @@
  * Returns 0 on success, negative on failure
  **/
 
-static int ixgb_set_mac(struct net_device *netdev, void *p)
+static int
+ixgb_set_mac(struct net_device *netdev, void *p)
 {
 	struct ixgb_adapter *adapter = netdev->priv;
 	struct sockaddr *addr = p;
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if(!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
@@ -1016,7 +1044,8 @@
  * promiscuous mode, and all-multi behavior.
  **/
 
-static void ixgb_set_multi(struct net_device *netdev)
+static void
+ixgb_set_multi(struct net_device *netdev)
 {
 	struct ixgb_adapter *adapter = netdev->priv;
 	struct ixgb_hw *hw = &adapter->hw;
@@ -1028,16 +1057,16 @@
 
 	rctl = IXGB_READ_REG(hw, RCTL);
 
-	if (netdev->flags & IFF_PROMISC) {
+	if(netdev->flags & IFF_PROMISC) {
 		rctl |= (IXGB_RCTL_UPE | IXGB_RCTL_MPE);
-	} else if (netdev->flags & IFF_ALLMULTI) {
+	} else if(netdev->flags & IFF_ALLMULTI) {
 		rctl |= IXGB_RCTL_MPE;
 		rctl &= ~IXGB_RCTL_UPE;
 	} else {
 		rctl &= ~(IXGB_RCTL_UPE | IXGB_RCTL_MPE);
 	}
 
-	if (netdev->mc_count > IXGB_MAX_NUM_MULTICAST_ADDRESSES) {
+	if(netdev->mc_count > IXGB_MAX_NUM_MULTICAST_ADDRESSES) {
 		rctl |= IXGB_RCTL_MPE;
 		IXGB_WRITE_REG(hw, RCTL, rctl);
 	} else {
@@ -1045,10 +1074,10 @@
 
 		IXGB_WRITE_REG(hw, RCTL, rctl);
 
-		for (i = 0, mc_ptr = netdev->mc_list; mc_ptr;
-		     i++, mc_ptr = mc_ptr->next)
+		for(i = 0, mc_ptr = netdev->mc_list; mc_ptr;
+			i++, mc_ptr = mc_ptr->next)
 			memcpy(&mta[i * IXGB_ETH_LENGTH_OF_ADDRESS],
-			       mc_ptr->dmi_addr, IXGB_ETH_LENGTH_OF_ADDRESS);
+				   mc_ptr->dmi_addr, IXGB_ETH_LENGTH_OF_ADDRESS);
 
 		ixgb_mc_addr_list_update(hw, mta, netdev->mc_count, 0);
 	}
@@ -1059,7 +1088,8 @@
  * @data: pointer to netdev cast into an unsigned long
  **/
 
-static void ixgb_watchdog(unsigned long data)
+static void
+ixgb_watchdog(unsigned long data)
 {
 	struct ixgb_adapter *adapter = (struct ixgb_adapter *)data;
 	struct net_device *netdev = adapter->netdev;
@@ -1073,21 +1103,22 @@
 		netif_stop_queue(netdev);
 	}
 
-	if (adapter->hw.link_up) {
-		if (!netif_carrier_ok(netdev)) {
+	if(adapter->hw.link_up) {
+		if(!netif_carrier_ok(netdev)) {
 			printk(KERN_INFO "ixgb: %s NIC Link is Up %d Mbps %s\n",
-			       netdev->name, 10000, "Full Duplex");
+				   netdev->name, 10000, "Full Duplex");
 			adapter->link_speed = 10000;
 			adapter->link_duplex = FULL_DUPLEX;
 			netif_carrier_on(netdev);
 			netif_wake_queue(netdev);
 		}
 	} else {
-		if (netif_carrier_ok(netdev)) {
+		if(netif_carrier_ok(netdev)) {
 			adapter->link_speed = 0;
 			adapter->link_duplex = 0;
 			printk(KERN_INFO
-			       "ixgb: %s NIC Link is Down\n", netdev->name);
+				   "ixgb: %s NIC Link is Down\n",
+				   netdev->name);
 			netif_carrier_off(netdev);
 			netif_stop_queue(netdev);
 
@@ -1096,8 +1127,8 @@
 
 	ixgb_update_stats(adapter);
 
-	if (!netif_carrier_ok(netdev)) {
-		if (IXGB_DESC_UNUSED(txdr) + 1 < txdr->count) {
+	if(!netif_carrier_ok(netdev)) {
+		if(IXGB_DESC_UNUSED(txdr) + 1 < txdr->count) {
 			/* We've lost link, so the controller stops DMA,
 			 * but we've got queued Tx work that's never going
 			 * to get done, so reset controller to flush Tx.
@@ -1108,9 +1139,9 @@
 
 	/* Early detection of hung controller */
 	i = txdr->next_to_clean;
-	if (txdr->buffer_info[i].dma &&
-	    time_after(jiffies, txdr->buffer_info[i].time_stamp + HZ) &&
-	    !(IXGB_READ_REG(&adapter->hw, STATUS) & IXGB_STATUS_TXOFF))
+	if(txdr->buffer_info[i].dma &&
+	   time_after(jiffies, txdr->buffer_info[i].time_stamp + HZ) &&
+	   !(IXGB_READ_REG(&adapter->hw, STATUS) & IXGB_STATUS_TXOFF))
 		netif_stop_queue(netdev);
 
 	/* generate an interrupt to force clean up of any stragglers */
@@ -1133,7 +1164,7 @@
 	uint8_t ipcss, ipcso, tucss, tucso, hdr_len;
 	uint16_t ipcse, tucse, mss;
 
-	if (likely(skb_shinfo(skb)->tso_size)) {
+	if(likely(skb_shinfo(skb)->tso_size)) {
 		hdr_len = ((skb->h.raw - skb->data) + (skb->h.th->doff << 2));
 		mss = skb_shinfo(skb)->tso_size;
 		skb->nh.iph->tot_len = 0;
@@ -1160,22 +1191,16 @@
 		context_desc->mss = cpu_to_le16(mss);
 		context_desc->hdr_len = hdr_len;
 		context_desc->status = 0;
-		context_desc->cmd_type_len = cpu_to_le32(IXGB_CONTEXT_DESC_TYPE
-							 |
-							 IXGB_CONTEXT_DESC_CMD_TSE
-							 |
-							 IXGB_CONTEXT_DESC_CMD_IP
-							 |
-							 IXGB_CONTEXT_DESC_CMD_TCP
-							 |
-							 IXGB_CONTEXT_DESC_CMD_RS
-							 |
-							 IXGB_CONTEXT_DESC_CMD_IDE
-							 | (skb->len -
-							    (hdr_len)));
+		context_desc->cmd_type_len = cpu_to_le32(
+						  IXGB_CONTEXT_DESC_TYPE 
+						| IXGB_CONTEXT_DESC_CMD_TSE
+						| IXGB_CONTEXT_DESC_CMD_IP
+						| IXGB_CONTEXT_DESC_CMD_TCP
+						| IXGB_CONTEXT_DESC_CMD_RS
+						| IXGB_CONTEXT_DESC_CMD_IDE
+						| (skb->len - (hdr_len)));
 
-		if (++i == adapter->tx_ring.count)
-			i = 0;
+		if(++i == adapter->tx_ring.count) i = 0;
 		adapter->tx_ring.next_to_use = i;
 
 		return TRUE;
@@ -1192,7 +1217,7 @@
 	unsigned int i;
 	uint8_t css, cso;
 
-	if (likely(skb->ip_summed == CHECKSUM_HW)) {
+	if(likely(skb->ip_summed == CHECKSUM_HW)) {
 		css = skb->h.raw - skb->data;
 		cso = (skb->h.raw + skb->csum) - skb->data;
 
@@ -1203,16 +1228,16 @@
 		context_desc->tucso = cso;
 		context_desc->tucse = 0;
 		/* zero out any previously existing data in one instruction */
-		*(uint32_t *) & (context_desc->ipcss) = 0;
+		*(uint32_t *)&(context_desc->ipcss) = 0;
 		context_desc->status = 0;
 		context_desc->hdr_len = 0;
 		context_desc->mss = 0;
 		context_desc->cmd_type_len =
-		    cpu_to_le32(IXGB_CONTEXT_DESC_TYPE
-				| IXGB_TX_DESC_CMD_RS | IXGB_TX_DESC_CMD_IDE);
+			cpu_to_le32(IXGB_CONTEXT_DESC_TYPE
+					| IXGB_TX_DESC_CMD_RS 
+					| IXGB_TX_DESC_CMD_IDE);
 
-		if (++i == adapter->tx_ring.count)
-			i = 0;
+		if(++i == adapter->tx_ring.count) i = 0;
 		adapter->tx_ring.next_to_use = i;
 
 		return TRUE;
@@ -1239,45 +1264,46 @@
 
 	i = tx_ring->next_to_use;
 
-	while (len) {
+	while(len) {
 		buffer_info = &tx_ring->buffer_info[i];
 		size = min(len, IXGB_MAX_JUMBO_FRAME_SIZE);
 		buffer_info->length = size;
 		buffer_info->dma =
-		    pci_map_single(adapter->pdev,
-				   skb->data + offset, size, PCI_DMA_TODEVICE);
+			pci_map_single(adapter->pdev,
+				skb->data + offset,
+				size,
+				PCI_DMA_TODEVICE);
 		buffer_info->time_stamp = jiffies;
 
 		len -= size;
 		offset += size;
 		count++;
-		if (++i == tx_ring->count)
-			i = 0;
+		if(++i == tx_ring->count) i = 0;
 	}
 
-	for (f = 0; f < nr_frags; f++) {
+	for(f = 0; f < nr_frags; f++) {
 		struct skb_frag_struct *frag;
 
 		frag = &skb_shinfo(skb)->frags[f];
 		len = frag->size;
 		offset = 0;
 
-		while (len) {
+		while(len) {
 			buffer_info = &tx_ring->buffer_info[i];
 			size = min(len, IXGB_MAX_JUMBO_FRAME_SIZE);
 			buffer_info->length = size;
 			buffer_info->dma =
-			    pci_map_page(adapter->pdev,
-					 frag->page,
-					 frag->page_offset + offset,
-					 size, PCI_DMA_TODEVICE);
+				pci_map_page(adapter->pdev,
+					frag->page,
+					frag->page_offset + offset,
+					size,
+					PCI_DMA_TODEVICE);
 			buffer_info->time_stamp = jiffies;
 
 			len -= size;
 			offset += size;
 			count++;
-			if (++i == tx_ring->count)
-				i = 0;
+			if(++i == tx_ring->count) i = 0;
 		}
 	}
 	i = (i == 0) ? tx_ring->count - 1 : i - 1;
@@ -1288,8 +1314,7 @@
 }
 
 static inline void
-ixgb_tx_queue(struct ixgb_adapter *adapter, int count, int vlan_id,
-	      int tx_flags)
+ixgb_tx_queue(struct ixgb_adapter *adapter, int count, int vlan_id,int tx_flags)
 {
 	struct ixgb_desc_ring *tx_ring = &adapter->tx_ring;
 	struct ixgb_tx_desc *tx_desc = NULL;
@@ -1299,36 +1324,35 @@
 	uint8_t popts = 0;
 	unsigned int i;
 
-	if (tx_flags & IXGB_TX_FLAGS_TSO) {
+	if(tx_flags & IXGB_TX_FLAGS_TSO) {
 		cmd_type_len |= IXGB_TX_DESC_CMD_TSE;
 		popts |= (IXGB_TX_DESC_POPTS_IXSM | IXGB_TX_DESC_POPTS_TXSM);
 	}
 
-	if (tx_flags & IXGB_TX_FLAGS_CSUM)
+	if(tx_flags & IXGB_TX_FLAGS_CSUM)
 		popts |= IXGB_TX_DESC_POPTS_TXSM;
 
-	if (tx_flags & IXGB_TX_FLAGS_VLAN) {
+	if(tx_flags & IXGB_TX_FLAGS_VLAN) {
 		cmd_type_len |= IXGB_TX_DESC_CMD_VLE;
 	}
 
 	i = tx_ring->next_to_use;
 
-	while (count--) {
+	while(count--) {
 		buffer_info = &tx_ring->buffer_info[i];
 		tx_desc = IXGB_TX_DESC(*tx_ring, i);
 		tx_desc->buff_addr = cpu_to_le64(buffer_info->dma);
 		tx_desc->cmd_type_len =
-		    cpu_to_le32(cmd_type_len | buffer_info->length);
+			cpu_to_le32(cmd_type_len | buffer_info->length);
 		tx_desc->status = status;
 		tx_desc->popts = popts;
 		tx_desc->vlan = cpu_to_le16(vlan_id);
 
-		if (++i == tx_ring->count)
-			i = 0;
+		if(++i == tx_ring->count) i = 0;
 	}
 
-	tx_desc->cmd_type_len |= cpu_to_le32(IXGB_TX_DESC_CMD_EOP
-					     | IXGB_TX_DESC_CMD_RS);
+	tx_desc->cmd_type_len |= cpu_to_le32(IXGB_TX_DESC_CMD_EOP 
+				| IXGB_TX_DESC_CMD_RS );
 
 	/* Force memory writes to complete before letting h/w
 	 * know there are new descriptors to fetch.  (Only
@@ -1346,7 +1370,8 @@
 #define DESC_NEEDED TXD_USE_COUNT(IXGB_MAX_DATA_PER_TXD) + \
 	MAX_SKB_FRAGS * TXD_USE_COUNT(PAGE_SIZE) + 1
 
-static int ixgb_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
+static int
+ixgb_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct ixgb_adapter *adapter = netdev->priv;
 	unsigned int first;
@@ -1354,33 +1379,33 @@
 	unsigned long flags;
 	int vlan_id = 0;
 
-	if (skb->len <= 0) {
+	if(skb->len <= 0) {
 		dev_kfree_skb_any(skb);
 		return 0;
 	}
 
 	spin_lock_irqsave(&adapter->tx_lock, flags);
-	if (unlikely(IXGB_DESC_UNUSED(&adapter->tx_ring) < DESC_NEEDED)) {
+	if(unlikely(IXGB_DESC_UNUSED(&adapter->tx_ring) < DESC_NEEDED)) {
 		netif_stop_queue(netdev);
 		spin_unlock_irqrestore(&adapter->tx_lock, flags);
 		return 1;
 	}
 	spin_unlock_irqrestore(&adapter->tx_lock, flags);
 
-	if (adapter->vlgrp && vlan_tx_tag_present(skb)) {
+	if(adapter->vlgrp && vlan_tx_tag_present(skb)) {
 		tx_flags |= IXGB_TX_FLAGS_VLAN;
 		vlan_id = vlan_tx_tag_get(skb);
 	}
 
 	first = adapter->tx_ring.next_to_use;
-
-	if (ixgb_tso(adapter, skb))
+	
+	if(ixgb_tso(adapter, skb))
 		tx_flags |= IXGB_TX_FLAGS_TSO;
-	else if (ixgb_tx_csum(adapter, skb))
+	else if(ixgb_tx_csum(adapter, skb))
 		tx_flags |= IXGB_TX_FLAGS_CSUM;
 
 	ixgb_tx_queue(adapter, ixgb_tx_map(adapter, skb, first), vlan_id,
-		      tx_flags);
+			tx_flags);
 
 	netdev->trans_start = jiffies;
 
@@ -1392,7 +1417,8 @@
  * @netdev: network interface device structure
  **/
 
-static void ixgb_tx_timeout(struct net_device *netdev)
+static void
+ixgb_tx_timeout(struct net_device *netdev)
 {
 	struct ixgb_adapter *adapter = netdev->priv;
 
@@ -1400,14 +1426,13 @@
 	schedule_work(&adapter->tx_timeout_task);
 }
 
-static void ixgb_tx_timeout_task(struct net_device *netdev)
+static void
+ixgb_tx_timeout_task(struct net_device *netdev)
 {
 	struct ixgb_adapter *adapter = netdev->priv;
 
-	netif_device_detach(netdev);
 	ixgb_down(adapter, TRUE);
 	ixgb_up(adapter);
-	netif_device_attach(netdev);
 }
 
 /**
@@ -1418,7 +1443,8 @@
  * The statistics are actually updated from the timer callback.
  **/
 
-static struct net_device_stats *ixgb_get_stats(struct net_device *netdev)
+static struct net_device_stats *
+ixgb_get_stats(struct net_device *netdev)
 {
 	struct ixgb_adapter *adapter = netdev->priv;
 
@@ -1433,27 +1459,28 @@
  * Returns 0 on success, negative on failure
  **/
 
-static int ixgb_change_mtu(struct net_device *netdev, int new_mtu)
+static int
+ixgb_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct ixgb_adapter *adapter = netdev->priv;
-	uint32_t old_mtu = adapter->rx_buffer_len;
 	int max_frame = new_mtu + ENET_HEADER_SIZE + ENET_FCS_LENGTH;
+	int old_max_frame = netdev->mtu + ENET_HEADER_SIZE + ENET_FCS_LENGTH;
+
 
-	if ((max_frame < IXGB_MIN_ENET_FRAME_SIZE_WITHOUT_FCS + ENET_FCS_LENGTH)
-	    || (max_frame > IXGB_MAX_JUMBO_FRAME_SIZE + ENET_FCS_LENGTH)) {
+	if((max_frame < IXGB_MIN_ENET_FRAME_SIZE_WITHOUT_FCS + ENET_FCS_LENGTH)
+	   || (max_frame > IXGB_MAX_JUMBO_FRAME_SIZE + ENET_FCS_LENGTH)) {
 		IXGB_ERR("Invalid MTU setting\n");
 		return -EINVAL;
 	}
 
-	if ((max_frame <=
-	     IXGB_MAX_ENET_FRAME_SIZE_WITHOUT_FCS + ENET_FCS_LENGTH)
-	    || (max_frame <= IXGB_RXBUFFER_2048)) {
+	if((max_frame <= IXGB_MAX_ENET_FRAME_SIZE_WITHOUT_FCS + ENET_FCS_LENGTH)
+	   || (max_frame <= IXGB_RXBUFFER_2048)) {
 		adapter->rx_buffer_len = IXGB_RXBUFFER_2048;
 
-	} else if (max_frame <= IXGB_RXBUFFER_4096) {
+	} else if(max_frame <= IXGB_RXBUFFER_4096) {
 		adapter->rx_buffer_len = IXGB_RXBUFFER_4096;
 
-	} else if (max_frame <= IXGB_RXBUFFER_8192) {
+	} else if(max_frame <= IXGB_RXBUFFER_8192) {
 		adapter->rx_buffer_len = IXGB_RXBUFFER_8192;
 
 	} else {
@@ -1462,7 +1489,7 @@
 
 	netdev->mtu = new_mtu;
 
-	if (old_mtu != adapter->rx_buffer_len && netif_running(netdev)) {
+	if(old_max_frame != max_frame && netif_running(netdev)) {
 
 		ixgb_down(adapter, TRUE);
 		ixgb_up(adapter);
@@ -1476,7 +1503,8 @@
  * @adapter: board private structure
  **/
 
-static void ixgb_update_stats(struct ixgb_adapter *adapter)
+void
+ixgb_update_stats(struct ixgb_adapter *adapter)
 {
 	adapter->stats.tprl += IXGB_READ_REG(&adapter->hw, TPRL);
 	adapter->stats.tprh += IXGB_READ_REG(&adapter->hw, TPRH);
@@ -1585,31 +1613,33 @@
  * @pt_regs: CPU registers structure
  **/
 
-static irqreturn_t ixgb_intr(int irq, void *data, struct pt_regs *regs)
+static irqreturn_t
+ixgb_intr(int irq, void *data, struct pt_regs *regs)
 {
 	struct net_device *netdev = data;
 	struct ixgb_adapter *adapter = netdev->priv;
 	struct ixgb_hw *hw = &adapter->hw;
-	uint32_t icr = IXGB_READ_REG(&adapter->hw, ICR);
+	uint32_t icr = IXGB_READ_REG(hw, ICR);
 #ifndef CONFIG_IXGB_NAPI
 	unsigned int i;
 #endif
 
-	if (unlikely(!icr))
-		return IRQ_NONE;	/* Not our interrupt */
+	if(unlikely(!icr))
+		return IRQ_NONE;  /* Not our interrupt */
 
-	if (unlikely(icr & (IXGB_INT_RXSEQ | IXGB_INT_LSC))) {
+	if(unlikely(icr & (IXGB_INT_RXSEQ | IXGB_INT_LSC))) {
 		mod_timer(&adapter->watchdog_timer, jiffies);
 	}
+
 #ifdef CONFIG_IXGB_NAPI
-	if (netif_rx_schedule_prep(netdev)) {
+	if(netif_rx_schedule_prep(netdev)) {
 
 		/* Disable interrupts and register for poll. The flush 
-		   of the posted write is intentionally left out.
-		 */
+		  of the posted write is intentionally left out.
+		*/
 
 		atomic_inc(&adapter->irq_sem);
-		IXGB_WRITE_REG(hw, IMC, ~0);
+		IXGB_WRITE_REG(&adapter->hw, IMC, ~0);
 		__netif_rx_schedule(netdev);
 	}
 #else
@@ -1621,16 +1651,7 @@
 		if(!ixgb_clean_rx_irq(adapter) &
 		   !ixgb_clean_tx_irq(adapter))
 			break;
-	/* if RAIDC:EN == 1 and ICR:RXDMT0 == 1, we need to
-	 * set IMS:RXDMT0 to 1 to restart the RBD timer (POLL)
-	 */
-	if ((icr & IXGB_INT_RXDMT0) && adapter->raidc) {
-		/* ready the timer by writing the clear reg */
-		IXGB_WRITE_REG(hw, IMC, IXGB_INT_RXDMT0);
-		/* now restart it, h/w will decide if its necessary */
-		IXGB_WRITE_REG(hw, IMS, IXGB_INT_RXDMT0);
-	}
-#endif
+#endif 
 	return IRQ_HANDLED;
 }
 
@@ -1640,25 +1661,32 @@
  * @adapter: board private structure
  **/
 
-static int ixgb_clean(struct net_device *netdev, int *budget)
+static int
+ixgb_clean(struct net_device *netdev, int *budget)
 {
 	struct ixgb_adapter *adapter = netdev->priv;
 	int work_to_do = min(*budget, netdev->quota);
+	int tx_cleaned;
 	int work_done = 0;
+	
+	if (!netif_carrier_ok(netdev))
+		goto quit_polling;
 
-	ixgb_clean_tx_irq(adapter);
+	tx_cleaned = ixgb_clean_tx_irq(adapter);
 	ixgb_clean_rx_irq(adapter, &work_done, work_to_do);
 
 	*budget -= work_done;
 	netdev->quota -= work_done;
-
-	if (work_done < work_to_do || !netif_running(netdev)) {
-		netif_rx_complete(netdev);
-		/* RAIDC will be automatically restarted by irq_enable */
+	
+	/* if no Tx cleanup and not enough Rx work done, exit the polling mode */
+	if((!tx_cleaned && (work_done < work_to_do)) || 
+				!netif_running(netdev)) {
+quit_polling:	netif_rx_complete(netdev);
 		ixgb_irq_enable(adapter);
+		return 0;
 	}
 
-	return (work_done >= work_to_do);
+	return 1;
 }
 #endif
 
@@ -1667,11 +1695,11 @@
  * @adapter: board private structure
  **/
 
-static boolean_t ixgb_clean_tx_irq(struct ixgb_adapter *adapter)
+static boolean_t
+ixgb_clean_tx_irq(struct ixgb_adapter *adapter)
 {
 	struct ixgb_desc_ring *tx_ring = &adapter->tx_ring;
 	struct net_device *netdev = adapter->netdev;
-	struct pci_dev *pdev = adapter->pdev;
 	struct ixgb_tx_desc *tx_desc, *eop_desc;
 	struct ixgb_buffer *buffer_info;
 	unsigned int i, eop;
@@ -1681,9 +1709,9 @@
 	eop = tx_ring->buffer_info[i].next_to_watch;
 	eop_desc = IXGB_TX_DESC(*tx_ring, eop);
 
-	while (eop_desc->status & IXGB_TX_DESC_STATUS_DD) {
+	while(eop_desc->status & IXGB_TX_DESC_STATUS_DD) {
 
-		for (cleaned = FALSE; !cleaned;) {
+		for(cleaned = FALSE; !cleaned; ) {
 			tx_desc = IXGB_TX_DESC(*tx_ring, i);
 			buffer_info = &tx_ring->buffer_info[i];
 
@@ -1692,28 +1720,12 @@
 			       IXGB_TX_DESC_POPTS_IXSM))
 				adapter->hw_csum_tx_good++;
 
-			if (buffer_info->dma) {
-
-				pci_unmap_page(pdev,
-					       buffer_info->dma,
-					       buffer_info->length,
-					       PCI_DMA_TODEVICE);
-
-				buffer_info->dma = 0;
-			}
-
-			if (buffer_info->skb) {
-
-				dev_kfree_skb_any(buffer_info->skb);
+			ixgb_unmap_and_free_tx_resource(adapter, buffer_info);
 
-				buffer_info->skb = NULL;
-			}
-
-			*(uint32_t *) & (tx_desc->status) = 0;
+			*(uint32_t *)&(tx_desc->status) = 0;
 
 			cleaned = (i == eop);
-			if (++i == tx_ring->count)
-				i = 0;
+			if(++i == tx_ring->count) i = 0;
 		}
 
 		eop = tx_ring->buffer_info[i].next_to_watch;
@@ -1723,8 +1735,8 @@
 	tx_ring->next_to_clean = i;
 
 	spin_lock(&adapter->tx_lock);
-	if (cleaned && netif_queue_stopped(netdev) && netif_carrier_ok(netdev)
-	    && (IXGB_DESC_UNUSED(tx_ring) > IXGB_TX_QUEUE_WAKE)) {
+	if(cleaned && netif_queue_stopped(netdev) && netif_carrier_ok(netdev) &&
+	   (IXGB_DESC_UNUSED(tx_ring) > IXGB_TX_QUEUE_WAKE)) {
 
 		netif_wake_queue(netdev);
 	}
@@ -1742,20 +1754,21 @@
 
 static inline void
 ixgb_rx_checksum(struct ixgb_adapter *adapter,
-		 struct ixgb_rx_desc *rx_desc, struct sk_buff *skb)
+		 struct ixgb_rx_desc *rx_desc,
+		 struct sk_buff *skb)
 {
 	/* Ignore Checksum bit is set OR
 	 * TCP Checksum has not been calculated
 	 */
-	if ((rx_desc->status & IXGB_RX_DESC_STATUS_IXSM) ||
-	    (!(rx_desc->status & IXGB_RX_DESC_STATUS_TCPCS))) {
+	if((rx_desc->status & IXGB_RX_DESC_STATUS_IXSM) ||
+	   (!(rx_desc->status & IXGB_RX_DESC_STATUS_TCPCS))) {
 		skb->ip_summed = CHECKSUM_NONE;
 		return;
 	}
 
 	/* At this point we know the hardware did the TCP checksum */
 	/* now look at the TCP checksum error bit */
-	if (rx_desc->errors & IXGB_RX_DESC_ERRORS_TCPE) {
+	if(rx_desc->errors & IXGB_RX_DESC_ERRORS_TCPE) {
 		/* let the stack verify checksum errors */
 		skb->ip_summed = CHECKSUM_NONE;
 		adapter->hw_csum_rx_error++;
@@ -1792,18 +1805,22 @@
 	rx_desc = IXGB_RX_DESC(*rx_ring, i);
 	buffer_info = &rx_ring->buffer_info[i];
 
-	while (rx_desc->status & IXGB_RX_DESC_STATUS_DD) {
+	while(rx_desc->status & IXGB_RX_DESC_STATUS_DD) {
 
+#ifdef CONFIG_IXGB_NAPI
+		if(*work_done >= work_to_do)
+			break;
+
+		(*work_done)++;
+#endif
 		skb = buffer_info->skb;
 		prefetch(skb->data);
 
-		if (++i == rx_ring->count)
-			i = 0;
+		if(++i == rx_ring->count) i = 0;
 		next_rxd = IXGB_RX_DESC(*rx_ring, i);
 		prefetch(next_rxd);
 
-		if ((j = i + 1) == rx_ring->count)
-			j = 0;
+		if((j = i + 1) == rx_ring->count) j = 0;
 		next2_buffer = &rx_ring->buffer_info[j];
 		prefetch(next2_buffer);
 
@@ -1811,27 +1828,22 @@
 		next_skb = next_buffer->skb;
 		prefetch(next_skb);
 
-#ifdef CONFIG_IXGB_NAPI
-		if (*work_done >= work_to_do)
-			break;
-
-		(*work_done)++;
-#endif
 
 		cleaned = TRUE;
 
 		pci_unmap_single(pdev,
 				 buffer_info->dma,
-				 buffer_info->length, PCI_DMA_FROMDEVICE);
+				 buffer_info->length,
+				 PCI_DMA_FROMDEVICE);
 
 		length = le16_to_cpu(rx_desc->length);
 
-		if (unlikely(!(rx_desc->status & IXGB_RX_DESC_STATUS_EOP))) {
+		if(unlikely(!(rx_desc->status & IXGB_RX_DESC_STATUS_EOP))) {
 
 			/* All receives must fit into a single buffer */
 
 			IXGB_DBG("Receive packet consumed multiple buffers "
-				 "length<%x>\n", length);
+					 "length<%x>\n", length);
 
 			dev_kfree_skb_irq(skb);
 			rx_desc->status = 0;
@@ -1864,26 +1876,22 @@
 
 		skb->protocol = eth_type_trans(skb, netdev);
 #ifdef CONFIG_IXGB_NAPI
-		if (adapter->vlgrp
-		    && (rx_desc->status & IXGB_RX_DESC_STATUS_VP)) {
+		if(adapter->vlgrp && (rx_desc->status & IXGB_RX_DESC_STATUS_VP)) {
 			vlan_hwaccel_receive_skb(skb, adapter->vlgrp,
-						 le16_to_cpu(rx_desc->
-							     special &
-							     IXGB_RX_DESC_SPECIAL_VLAN_MASK));
+				le16_to_cpu(rx_desc->special) &
+					IXGB_RX_DESC_SPECIAL_VLAN_MASK);
 		} else {
 			netif_receive_skb(skb);
 		}
-#else				/* CONFIG_IXGB_NAPI */
-		if (adapter->vlgrp
-		    && (rx_desc->status & IXGB_RX_DESC_STATUS_VP)) {
+#else /* CONFIG_IXGB_NAPI */
+		if(adapter->vlgrp && (rx_desc->status & IXGB_RX_DESC_STATUS_VP)) {
 			vlan_hwaccel_rx(skb, adapter->vlgrp,
-					le16_to_cpu(rx_desc->
-						    special &
-						    IXGB_RX_DESC_SPECIAL_VLAN_MASK));
+				le16_to_cpu(rx_desc->special) &
+					IXGB_RX_DESC_SPECIAL_VLAN_MASK);
 		} else {
 			netif_rx(skb);
 		}
-#endif				/* CONFIG_IXGB_NAPI */
+#endif /* CONFIG_IXGB_NAPI */
 		netdev->last_rx = jiffies;
 
 		rx_desc->status = 0;
@@ -1905,7 +1913,8 @@
  * @adapter: address of board private structure
  **/
 
-static void ixgb_alloc_rx_buffers(struct ixgb_adapter *adapter)
+static void
+ixgb_alloc_rx_buffers(struct ixgb_adapter *adapter)
 {
 	struct ixgb_desc_ring *rx_ring = &adapter->rx_ring;
 	struct net_device *netdev = adapter->netdev;
@@ -1921,19 +1930,15 @@
 	buffer_info = &rx_ring->buffer_info[i];
 	cleancount = IXGB_DESC_UNUSED(rx_ring);
 
-	/* lessen this to 4 if we're
-	 * in the midst of raidc and rbd is occuring
-	 * because we don't want to delay returning buffers when low
-	 */
-	num_group_tail_writes = adapter->raidc ? 4 : IXGB_RX_BUFFER_WRITE;
+	num_group_tail_writes = IXGB_RX_BUFFER_WRITE;
 
 	/* leave one descriptor unused */
-	while (--cleancount > 0) {
+	while(--cleancount > 0) {
 		rx_desc = IXGB_RX_DESC(*rx_ring, i);
 
 		skb = dev_alloc_skb(adapter->rx_buffer_len + NET_IP_ALIGN);
 
-		if (unlikely(!skb)) {
+		if(unlikely(!skb)) {
 			/* Better luck next round */
 			break;
 		}
@@ -1949,13 +1954,14 @@
 		buffer_info->skb = skb;
 		buffer_info->length = adapter->rx_buffer_len;
 		buffer_info->dma =
-		    pci_map_single(pdev,
+			pci_map_single(pdev,
 				   skb->data,
-				   adapter->rx_buffer_len, PCI_DMA_FROMDEVICE);
+				   adapter->rx_buffer_len,
+				   PCI_DMA_FROMDEVICE);
 
 		rx_desc->buff_addr = cpu_to_le64(buffer_info->dma);
 
-		if ((i & ~(num_group_tail_writes - 1)) == i) {
+		if((i & ~(num_group_tail_writes- 1)) == i) {
 			/* Force memory writes to complete before letting h/w
 			 * know there are new descriptors to fetch.  (Only
 			 * applicable for weak-ordered memory model archs,
@@ -1965,8 +1971,7 @@
 			IXGB_WRITE_REG(&adapter->hw, RDT, i);
 		}
 
-		if (++i == rx_ring->count)
-			i = 0;
+		if(++i == rx_ring->count) i = 0;
 		buffer_info = &rx_ring->buffer_info[i];
 	}
 
@@ -1988,7 +1993,7 @@
 	ixgb_irq_disable(adapter);
 	adapter->vlgrp = grp;
 
-	if (grp) {
+	if(grp) {
 		/* enable VLAN tag insert/strip */
 		ctrl = IXGB_READ_REG(&adapter->hw, CTRL0);
 		ctrl |= IXGB_CTRL0_VME;
@@ -2017,7 +2022,8 @@
 	ixgb_irq_enable(adapter);
 }
 
-static void ixgb_vlan_rx_add_vid(struct net_device *netdev, uint16_t vid)
+static void
+ixgb_vlan_rx_add_vid(struct net_device *netdev, uint16_t vid)
 {
 	struct ixgb_adapter *adapter = netdev->priv;
 	uint32_t vfta, index;
@@ -2030,19 +2036,20 @@
 	ixgb_write_vfta(&adapter->hw, index, vfta);
 }
 
-static void ixgb_vlan_rx_kill_vid(struct net_device *netdev, uint16_t vid)
+static void
+ixgb_vlan_rx_kill_vid(struct net_device *netdev, uint16_t vid)
 {
 	struct ixgb_adapter *adapter = netdev->priv;
 	uint32_t vfta, index;
 
 	ixgb_irq_disable(adapter);
 
-	if (adapter->vlgrp)
+	if(adapter->vlgrp)
 		adapter->vlgrp->vlan_devices[vid] = NULL;
 
 	ixgb_irq_enable(adapter);
 
-	/* remove VID from filter table */
+	/* remove VID from filter table*/
 
 	index = (vid >> 5) & 0x7F;
 	vfta = IXGB_READ_REG_ARRAY(&adapter->hw, VFTA, index);
@@ -2050,14 +2057,15 @@
 	ixgb_write_vfta(&adapter->hw, index, vfta);
 }
 
-static void ixgb_restore_vlan(struct ixgb_adapter *adapter)
+static void
+ixgb_restore_vlan(struct ixgb_adapter *adapter)
 {
 	ixgb_vlan_rx_register(adapter->netdev, adapter->vlgrp);
 
-	if (adapter->vlgrp) {
+	if(adapter->vlgrp) {
 		uint16_t vid;
-		for (vid = 0; vid < VLAN_GROUP_ARRAY_LEN; vid++) {
-			if (!adapter->vlgrp->vlan_devices[vid])
+		for(vid = 0; vid < VLAN_GROUP_ARRAY_LEN; vid++) {
+			if(!adapter->vlgrp->vlan_devices[vid])
 				continue;
 			ixgb_vlan_rx_add_vid(adapter->netdev, vid);
 		}
@@ -2075,7 +2083,7 @@
 {
 	struct pci_dev *pdev = NULL;
 
-	switch (event) {
+	switch(event) {
 	case SYS_DOWN:
 	case SYS_HALT:
 	case SYS_POWER_OFF:
@@ -2092,14 +2100,15 @@
  * @param pdev pci driver structure used for passing to
  * @param state power state to enter 
  **/
-static int ixgb_suspend(struct pci_dev *pdev, uint32_t state)
+static int
+ixgb_suspend(struct pci_dev *pdev, uint32_t state)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct ixgb_adapter *adapter = netdev->priv;
 
 	netif_device_detach(netdev);
 
-	if (netif_running(netdev))
+	if(netif_running(netdev))
 		ixgb_down(adapter, TRUE);
 
 	pci_save_state(pdev);
diff -Nru a/drivers/net/ixgb/ixgb_osdep.h b/drivers/net/ixgb/ixgb_osdep.h
--- a/drivers/net/ixgb/ixgb_osdep.h	2005-01-10 23:54:12 -05:00
+++ b/drivers/net/ixgb/ixgb_osdep.h	2005-01-10 23:54:12 -05:00
@@ -78,19 +78,19 @@
 #define DEBUGOUT7 DEBUGOUT3
 
 #define IXGB_WRITE_REG(a, reg, value) ( \
-    writel((value), ((a)->hw_addr + IXGB_##reg)))
+	writel((value), ((a)->hw_addr + IXGB_##reg)))
 
 #define IXGB_READ_REG(a, reg) ( \
-    readl((a)->hw_addr + IXGB_##reg))
+	readl((a)->hw_addr + IXGB_##reg))
 
 #define IXGB_WRITE_REG_ARRAY(a, reg, offset, value) ( \
-    writel((value), ((a)->hw_addr + IXGB_##reg + ((offset) << 2))))
+	writel((value), ((a)->hw_addr + IXGB_##reg + ((offset) << 2))))
 
 #define IXGB_READ_REG_ARRAY(a, reg, offset) ( \
-    readl((a)->hw_addr + IXGB_##reg + ((offset) << 2)))
+	readl((a)->hw_addr + IXGB_##reg + ((offset) << 2)))
 
 #define IXGB_WRITE_FLUSH(a) IXGB_READ_REG(a, STATUS)
 
 #define IXGB_MEMCPY memcpy
 
-#endif				/* _IXGB_OSDEP_H_ */
+#endif /* _IXGB_OSDEP_H_ */
diff -Nru a/drivers/net/ixgb/ixgb_param.c b/drivers/net/ixgb/ixgb_param.c
--- a/drivers/net/ixgb/ixgb_param.c	2005-01-10 23:54:12 -05:00
+++ b/drivers/net/ixgb/ixgb_param.c	2005-01-10 23:54:12 -05:00
@@ -34,31 +34,21 @@
 
 #define IXGB_MAX_NIC 8
 
-#define OPTION_UNSET    -1
+#define OPTION_UNSET	-1
 #define OPTION_DISABLED 0
 #define OPTION_ENABLED  1
 
-/* Module Parameters are always initialized to -1, so that the driver
- * can tell the difference between no user specified value or the
- * user asking for the default value.
- * The true default values are loaded in when ixgb_check_options is called.
- *
- * This is a GCC extension to ANSI C.
- * See the item "Labeled Elements in Initializers" in the section
- * "Extensions to the C Language Family" of the GCC documentation.
- */
-
-#define IXGB_PARAM_INIT { [0 ... IXGB_MAX_NIC] = OPTION_UNSET }
-
 /* All parameters are treated the same, as an integer array of values.
  * This macro just reduces the need to repeat the same declaration code
  * over and over (plus this helps to avoid typo bugs).
  */
 
-#define IXGB_PARAM(X, S) \
-static int __devinitdata X[IXGB_MAX_NIC + 1] = IXGB_PARAM_INIT; \
-module_param_array(X, int, NULL, 0); \
-MODULE_PARM_DESC(X, S);
+#define IXGB_PARAM_INIT { [0 ... IXGB_MAX_NIC] = OPTION_UNSET }
+#define IXGB_PARAM(X, desc) \
+	static int __devinitdata X[IXGB_MAX_NIC+1] = IXGB_PARAM_INIT; \
+	static int num_##X = 0; \
+	module_param_array_named(X, X, int, &num_##X, 0); \
+	MODULE_PARM_DESC(X, desc);
 
 /* Transmit Descriptor Count
  *
@@ -121,15 +111,6 @@
 
 IXGB_PARAM(RxIntDelay, "Receive Interrupt Delay");
 
-/* Receive Interrupt Moderation enable (uses RxIntDelay too)
- *
- * Valid Range: 0,1
- *
- * Default Value: 1
- */
-
-IXGB_PARAM(RAIDC, "Disable or enable Receive Interrupt Moderation");
-
 /* Receive Flow control high threshold (when we send a pause frame)
  * (FCRTH)
  *
@@ -173,13 +154,6 @@
 
 IXGB_PARAM(IntDelayEnable, "Transmit Interrupt Delay Enable");
 
-#define DEFAULT_TXD			    256
-#define MAX_TXD				   4096
-#define MIN_TXD				     64
-
-#define DEFAULT_RXD			   1024
-#define MAX_RXD				   4096
-#define MIN_RXD				     64
 
 #define DEFAULT_TIDV	   		     32
 #define MAX_TIDV			 0xFFFF
@@ -224,9 +198,10 @@
 	} arg;
 };
 
-static int __devinit ixgb_validate_option(int *value, struct ixgb_option *opt)
+static int __devinit
+ixgb_validate_option(int *value, struct ixgb_option *opt)
 {
-	if (*value == OPTION_UNSET) {
+	if(*value == OPTION_UNSET) {
 		*value = opt->def;
 		return 0;
 	}
@@ -243,32 +218,31 @@
 		}
 		break;
 	case range_option:
-		if (*value >= opt->arg.r.min && *value <= opt->arg.r.max) {
+		if(*value >= opt->arg.r.min && *value <= opt->arg.r.max) {
 			printk(KERN_INFO "%s set to %i\n", opt->name, *value);
 			return 0;
 		}
 		break;
-	case list_option:{
-			int i;
-			struct ixgb_opt_list *ent;
-
-			for (i = 0; i < opt->arg.l.nr; i++) {
-				ent = &opt->arg.l.p[i];
-				if (*value == ent->i) {
-					if (ent->str[0] != '\0')
-						printk(KERN_INFO "%s\n",
-						       ent->str);
-					return 0;
-				}
+	case list_option: {
+		int i;
+		struct ixgb_opt_list *ent;
+
+		for(i = 0; i < opt->arg.l.nr; i++) {
+			ent = &opt->arg.l.p[i];
+			if(*value == ent->i) {
+				if(ent->str[0] != '\0')
+					printk(KERN_INFO "%s\n", ent->str);
+				return 0;
 			}
 		}
+	}
 		break;
 	default:
 		BUG();
 	}
 
 	printk(KERN_INFO "Invalid %s specified (%i) %s\n",
-	       opt->name, *value, opt->err);
+		   opt->name, *value, opt->err);
 	*value = opt->def;
 	return -1;
 }
@@ -285,198 +259,218 @@
  * in a variable in the adapter structure.
  **/
 
-void __devinit ixgb_check_options(struct ixgb_adapter *adapter)
+void __devinit
+ixgb_check_options(struct ixgb_adapter *adapter)
 {
 	int bd = adapter->bd_number;
-	if (bd >= IXGB_MAX_NIC) {
+	if(bd >= IXGB_MAX_NIC) {
 		printk(KERN_NOTICE
-		       "Warning: no configuration for board #%i\n", bd);
+			   "Warning: no configuration for board #%i\n", bd);
 		printk(KERN_NOTICE "Using defaults for all values\n");
-		bd = IXGB_MAX_NIC;
 	}
 
-	{			/* Transmit Descriptor Count */
+	{ /* Transmit Descriptor Count */
 		struct ixgb_option opt = {
 			.type = range_option,
 			.name = "Transmit Descriptors",
-			.err = "using default of " __MODULE_STRING(DEFAULT_TXD),
-			.def = DEFAULT_TXD,
-			.arg = {.r = {.min = MIN_TXD,
-				      .max = MAX_TXD}}
+			.err  = "using default of " __MODULE_STRING(DEFAULT_TXD),
+			.def  = DEFAULT_TXD,
+			.arg  = { .r = { .min = MIN_TXD,
+					 .max = MAX_TXD}}
 		};
 		struct ixgb_desc_ring *tx_ring = &adapter->tx_ring;
 
-		tx_ring->count = TxDescriptors[bd];
-		ixgb_validate_option(&tx_ring->count, &opt);
+		if(num_TxDescriptors > bd) {
+			tx_ring->count = TxDescriptors[bd];
+			ixgb_validate_option(&tx_ring->count, &opt);
+		} else {
+			tx_ring->count = opt.def;
+		}
 		IXGB_ROUNDUP(tx_ring->count, IXGB_REQ_TX_DESCRIPTOR_MULTIPLE);
 	}
-	{			/* Receive Descriptor Count */
+	{ /* Receive Descriptor Count */
 		struct ixgb_option opt = {
 			.type = range_option,
 			.name = "Receive Descriptors",
-			.err = "using default of " __MODULE_STRING(DEFAULT_RXD),
-			.def = DEFAULT_RXD,
-			.arg = {.r = {.min = MIN_RXD,
-				      .max = MAX_RXD}}
+			.err  = "using default of " __MODULE_STRING(DEFAULT_RXD),
+			.def  = DEFAULT_RXD,
+			.arg  = { .r = { .min = MIN_RXD,
+					 .max = MAX_RXD}}
 		};
 		struct ixgb_desc_ring *rx_ring = &adapter->rx_ring;
 
-		rx_ring->count = RxDescriptors[bd];
-		ixgb_validate_option(&rx_ring->count, &opt);
+		if(num_RxDescriptors > bd) {
+			rx_ring->count = RxDescriptors[bd];
+			ixgb_validate_option(&rx_ring->count, &opt);
+		} else {
+			rx_ring->count = opt.def;
+		}
 		IXGB_ROUNDUP(rx_ring->count, IXGB_REQ_RX_DESCRIPTOR_MULTIPLE);
 	}
-	{			/* Receive Checksum Offload Enable */
+	{ /* Receive Checksum Offload Enable */
 		struct ixgb_option opt = {
 			.type = enable_option,
 			.name = "Receive Checksum Offload",
-			.err = "defaulting to Enabled",
-			.def = OPTION_ENABLED
+			.err  = "defaulting to Enabled",
+			.def  = OPTION_ENABLED
 		};
 
-		int rx_csum = XsumRX[bd];
-		ixgb_validate_option(&rx_csum, &opt);
-		adapter->rx_csum = rx_csum;
+		if(num_XsumRX > bd) {
+			int rx_csum = XsumRX[bd];
+			ixgb_validate_option(&rx_csum, &opt);
+			adapter->rx_csum = rx_csum;
+		} else {
+			adapter->rx_csum = opt.def;
+		}
 	}
-	{			/* Flow Control */
+	{ /* Flow Control */
 
 		struct ixgb_opt_list fc_list[] =
-		    { {ixgb_fc_none, "Flow Control Disabled"},
-		{ixgb_fc_rx_pause, "Flow Control Receive Only"},
-		{ixgb_fc_tx_pause, "Flow Control Transmit Only"},
-		{ixgb_fc_full, "Flow Control Enabled"},
-		{ixgb_fc_default, "Flow Control Hardware Default"}
-		};
+			{{ ixgb_fc_none,	"Flow Control Disabled" },
+			 { ixgb_fc_rx_pause,"Flow Control Receive Only" },
+			 { ixgb_fc_tx_pause,"Flow Control Transmit Only" },
+			 { ixgb_fc_full,	"Flow Control Enabled" },
+			 { ixgb_fc_default, "Flow Control Hardware Default" }};
 
 		struct ixgb_option opt = {
 			.type = list_option,
 			.name = "Flow Control",
-			.err = "reading default settings from EEPROM",
-			.def = ixgb_fc_full,
-			.arg = {.l = {.nr = LIST_LEN(fc_list),
-				      .p = fc_list}}
+			.err  = "reading default settings from EEPROM",
+			.def  = ixgb_fc_full,
+			.arg  = { .l = { .nr = LIST_LEN(fc_list),
+					 .p = fc_list }}
 		};
 
-		int fc = FlowControl[bd];
-		ixgb_validate_option(&fc, &opt);
-		adapter->hw.fc.type = fc;
+		if(num_FlowControl > bd) {
+			int fc = FlowControl[bd];
+			ixgb_validate_option(&fc, &opt);
+			adapter->hw.fc.type = fc;
+		} else {
+			adapter->hw.fc.type = opt.def;
+		}
 	}
-	{			/* Receive Flow Control High Threshold */
+	{ /* Receive Flow Control High Threshold */
 		struct ixgb_option opt = {
 			.type = range_option,
 			.name = "Rx Flow Control High Threshold",
-			.err =
-			    "using default of " __MODULE_STRING(DEFAULT_FCRTH),
-			.def = DEFAULT_FCRTH,
-			.arg = {.r = {.min = MIN_FCRTH,
-				      .max = MAX_FCRTH}}
+			.err  = "using default of " __MODULE_STRING(DEFAULT_FCRTH),
+			.def  = DEFAULT_FCRTH,
+			.arg  = { .r = { .min = MIN_FCRTH,
+					 .max = MAX_FCRTH}}
 		};
 
-		adapter->hw.fc.high_water = RxFCHighThresh[bd];
-		ixgb_validate_option(&adapter->hw.fc.high_water, &opt);
-		if (!(adapter->hw.fc.type & ixgb_fc_rx_pause))
-			printk(KERN_INFO
-			       "Ignoring RxFCHighThresh when no RxFC\n");
+		if(num_RxFCHighThresh > bd) {
+			adapter->hw.fc.high_water = RxFCHighThresh[bd];
+			ixgb_validate_option(&adapter->hw.fc.high_water, &opt);
+		} else {
+			adapter->hw.fc.high_water = opt.def;
+		}
+		if(!(adapter->hw.fc.type & ixgb_fc_rx_pause) )
+			printk (KERN_INFO 
+				"Ignoring RxFCHighThresh when no RxFC\n");
 	}
-	{			/* Receive Flow Control Low Threshold */
+	{ /* Receive Flow Control Low Threshold */
 		struct ixgb_option opt = {
 			.type = range_option,
 			.name = "Rx Flow Control Low Threshold",
-			.err =
-			    "using default of " __MODULE_STRING(DEFAULT_FCRTL),
-			.def = DEFAULT_FCRTL,
-			.arg = {.r = {.min = MIN_FCRTL,
-				      .max = MAX_FCRTL}}
+			.err  = "using default of " __MODULE_STRING(DEFAULT_FCRTL),
+			.def  = DEFAULT_FCRTL,
+			.arg  = { .r = { .min = MIN_FCRTL,
+					 .max = MAX_FCRTL}}
 		};
 
-		adapter->hw.fc.low_water = RxFCLowThresh[bd];
-		ixgb_validate_option(&adapter->hw.fc.low_water, &opt);
-		if (!(adapter->hw.fc.type & ixgb_fc_rx_pause))
-			printk(KERN_INFO
-			       "Ignoring RxFCLowThresh when no RxFC\n");
+		if(num_RxFCLowThresh > bd) {
+			adapter->hw.fc.low_water = RxFCLowThresh[bd];
+			ixgb_validate_option(&adapter->hw.fc.low_water, &opt);
+		} else {
+			adapter->hw.fc.low_water = opt.def;
+		}
+		if(!(adapter->hw.fc.type & ixgb_fc_rx_pause) )
+			printk (KERN_INFO 
+				"Ignoring RxFCLowThresh when no RxFC\n");
 	}
-	{			/* Flow Control Pause Time Request */
+	{ /* Flow Control Pause Time Request*/
 		struct ixgb_option opt = {
 			.type = range_option,
 			.name = "Flow Control Pause Time Request",
-			.err =
-			    "using default of "
-			    __MODULE_STRING(DEFAULT_FCPAUSE),
-			.def = DEFAULT_FCPAUSE,
-			.arg = {.r = {.min = MIN_FCPAUSE,
-				      .max = MAX_FCPAUSE}}
+			.err  = "using default of "__MODULE_STRING(DEFAULT_FCPAUSE),
+			.def  = DEFAULT_FCPAUSE,
+			.arg = { .r = { .min = MIN_FCPAUSE,
+					.max = MAX_FCPAUSE}}
 		};
 
-		int pause_time = FCReqTimeout[bd];
-
-		ixgb_validate_option(&pause_time, &opt);
-		if (!(adapter->hw.fc.type & ixgb_fc_rx_pause))
-			printk(KERN_INFO
-			       "Ignoring FCReqTimeout when no RxFC\n");
-		adapter->hw.fc.pause_time = pause_time;
+		if(num_FCReqTimeout > bd) {
+			int pause_time = FCReqTimeout[bd];
+			ixgb_validate_option(&pause_time, &opt);
+			adapter->hw.fc.pause_time = pause_time;
+		} else {
+			adapter->hw.fc.pause_time = opt.def;
+		}
+		if(!(adapter->hw.fc.type & ixgb_fc_rx_pause) )
+			printk (KERN_INFO 
+				"Ignoring FCReqTimeout when no RxFC\n");
 	}
 	/* high low and spacing check for rx flow control thresholds */
 	if (adapter->hw.fc.type & ixgb_fc_rx_pause) {
 		/* high must be greater than low */
 		if (adapter->hw.fc.high_water < (adapter->hw.fc.low_water + 8)) {
 			/* set defaults */
-			printk(KERN_INFO
-			       "RxFCHighThresh must be >= (RxFCLowThresh + 8), "
-			       "Using Defaults\n");
+			printk (KERN_INFO 
+				"RxFCHighThresh must be >= (RxFCLowThresh + 8), "
+				"Using Defaults\n");
 			adapter->hw.fc.high_water = DEFAULT_FCRTH;
-			adapter->hw.fc.low_water = DEFAULT_FCRTL;
+			adapter->hw.fc.low_water  = DEFAULT_FCRTL;
 		}
 	}
-	{			/* Receive Interrupt Delay */
+	{ /* Receive Interrupt Delay */
 		struct ixgb_option opt = {
 			.type = range_option,
 			.name = "Receive Interrupt Delay",
-			.err =
-			    "using default of " __MODULE_STRING(DEFAULT_RDTR),
-			.def = DEFAULT_RDTR,
-			.arg = {.r = {.min = MIN_RDTR,
-				      .max = MAX_RDTR}}
-		};
-
-		adapter->rx_int_delay = RxIntDelay[bd];
-		ixgb_validate_option(&adapter->rx_int_delay, &opt);
-	}
-	{			/* Receive Interrupt Moderation */
-		struct ixgb_option opt = {
-			.type = enable_option,
-			.name = "Advanced Receive Interrupt Moderation",
-			.err = "defaulting to Enabled",
-			.def = OPTION_ENABLED
+			.err  = "using default of " __MODULE_STRING(DEFAULT_RDTR),
+			.def  = DEFAULT_RDTR,
+			.arg  = { .r = { .min = MIN_RDTR,
+					 .max = MAX_RDTR}}
 		};
-		int raidc = RAIDC[bd];
 
-		ixgb_validate_option(&raidc, &opt);
-		adapter->raidc = raidc;
+		if(num_RxIntDelay > bd) {
+			adapter->rx_int_delay = RxIntDelay[bd];
+			ixgb_validate_option(&adapter->rx_int_delay, &opt);
+		} else {
+			adapter->rx_int_delay = opt.def;
+		}
 	}
-	{			/* Transmit Interrupt Delay */
+	{ /* Transmit Interrupt Delay */
 		struct ixgb_option opt = {
 			.type = range_option,
 			.name = "Transmit Interrupt Delay",
-			.err =
-			    "using default of " __MODULE_STRING(DEFAULT_TIDV),
-			.def = DEFAULT_TIDV,
-			.arg = {.r = {.min = MIN_TIDV,
-				      .max = MAX_TIDV}}
+			.err  = "using default of " __MODULE_STRING(DEFAULT_TIDV),
+			.def  = DEFAULT_TIDV,
+			.arg  = { .r = { .min = MIN_TIDV,
+					 .max = MAX_TIDV}}
 		};
 
-		adapter->tx_int_delay = TxIntDelay[bd];
-		ixgb_validate_option(&adapter->tx_int_delay, &opt);
+		if(num_TxIntDelay > bd) {
+			adapter->tx_int_delay = TxIntDelay[bd];
+			ixgb_validate_option(&adapter->tx_int_delay, &opt);
+		} else {
+			adapter->tx_int_delay = opt.def;
+		}
 	}
 
-	{			/* Transmit Interrupt Delay Enable */
+	{ /* Transmit Interrupt Delay Enable */
 		struct ixgb_option opt = {
 			.type = enable_option,
 			.name = "Tx Interrupt Delay Enable",
-			.err = "defaulting to Enabled",
-			.def = OPTION_ENABLED
+			.err  = "defaulting to Enabled",
+			.def  = OPTION_ENABLED
 		};
-		int ide = IntDelayEnable[bd];
 
-		ixgb_validate_option(&ide, &opt);
-		adapter->tx_int_delay_enable = ide;
+		if(num_IntDelayEnable > bd) {
+			int ide = IntDelayEnable[bd];
+			ixgb_validate_option(&ide, &opt);
+			adapter->tx_int_delay_enable = ide;
+		} else {
+			adapter->tx_int_delay_enable = opt.def;
+		}
 	}
 }
diff -Nru a/drivers/net/s2io.c b/drivers/net/s2io.c
--- a/drivers/net/s2io.c	2005-01-10 23:54:12 -05:00
+++ b/drivers/net/s2io.c	2005-01-10 23:54:12 -05:00
@@ -560,21 +560,35 @@
 	for (i = 0; i < config->rx_ring_num; i++) {
 		blk_cnt =
 		    config->rx_cfg[i].num_rxd / (MAX_RXDS_PER_BLOCK + 1);
+		if (!nic->ba[i])
+			goto end_free;
 		for (j = 0; j < blk_cnt; j++) {
 			int k = 0;
-			if (!nic->ba[i][j])
-				continue;
+			if (!nic->ba[i][j]) {
+				kfree(nic->ba[i]);
+				goto end_free;
+			}
 			while (k != MAX_RXDS_PER_BLOCK) {
 				buffAdd_t *ba = &nic->ba[i][j][k];
+				if (!ba || !ba->ba_0_org || !ba->ba_1_org)
+				{
+					kfree(nic->ba[i]);
+					kfree(nic->ba[i][j]);
+					if(ba->ba_0_org)
+						kfree(ba->ba_0_org);
+					if(ba->ba_1_org)
+						kfree(ba->ba_1_org);
+					goto end_free;
+				}
 				kfree(ba->ba_0_org);
 				kfree(ba->ba_1_org);
 				k++;
 			}
 			kfree(nic->ba[i][j]);
 		}
-		if (nic->ba[i])
-			kfree(nic->ba[i]);
+		kfree(nic->ba[i]);
 	}
+end_free:
 #endif
 
 	if (mac_control->stats_mem) {
diff -Nru a/drivers/net/s2io.h b/drivers/net/s2io.h
--- a/drivers/net/s2io.h	2005-01-10 23:54:12 -05:00
+++ b/drivers/net/s2io.h	2005-01-10 23:54:12 -05:00
@@ -740,8 +740,8 @@
 {
 	u64 ret = 0;
 	ret = readl(addr + 4);
-	(u64) ret <<= 32;
-	(u64) ret |= readl(addr);
+	ret <<= 32;
+	ret |= readl(addr);
 
 	return ret;
 }
diff -Nru a/drivers/net/smc-ultra.c b/drivers/net/smc-ultra.c
--- a/drivers/net/smc-ultra.c	2005-01-10 23:54:12 -05:00
+++ b/drivers/net/smc-ultra.c	2005-01-10 23:54:12 -05:00
@@ -156,8 +156,6 @@
 	/* Look for any installed ISAPnP cards */
 	if (isapnp_present() && (ultra_probe_isapnp(dev) == 0))
 		return 0;
-
-	printk(KERN_NOTICE "smc-ultra.c: No ISAPnP cards found, trying standard ones...\n");
 #endif
 
 	for (i = 0; ultra_portlist[i]; i++) {
diff -Nru a/drivers/net/smc91x.c b/drivers/net/smc91x.c
--- a/drivers/net/smc91x.c	2005-01-10 23:54:12 -05:00
+++ b/drivers/net/smc91x.c	2005-01-10 23:54:12 -05:00
@@ -1333,6 +1333,19 @@
 	return IRQ_HANDLED;
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+/*
+ * Polling receive - used by netconsole and other diagnostic tools
+ * to allow network i/o with interrupts disabled.
+ */
+static void smc_poll_controller(struct net_device *dev)
+{
+	disable_irq(dev->irq);
+	smc_interrupt(dev->irq, dev, NULL);
+	enable_irq(dev->irq);
+}
+#endif
+
 /* Our watchdog timed out. Called by the networking layer */
 static void smc_timeout(struct net_device *dev)
 {
@@ -1912,6 +1925,9 @@
 	dev->get_stats = smc_query_statistics;
 	dev->set_multicast_list = smc_set_multicast_list;
 	dev->ethtool_ops = &smc_ethtool_ops;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller = smc_poll_controller;
+#endif
 
 	tasklet_init(&lp->tx_task, smc_hardware_send_pkt, (unsigned long)dev);
 	INIT_WORK(&lp->phy_configure, smc_phy_configure, dev);
diff -Nru a/drivers/net/wireless/orinoco.c b/drivers/net/wireless/orinoco.c
--- a/drivers/net/wireless/orinoco.c	2005-01-10 23:54:12 -05:00
+++ b/drivers/net/wireless/orinoco.c	2005-01-10 23:54:12 -05:00
@@ -617,9 +617,8 @@
 	unsigned long flags;
 	int err;
 
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
 
 	err = __orinoco_up(dev);
 
@@ -671,10 +670,9 @@
 		return NULL; /* FIXME: Can we do better than this? */
 	}
 
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return NULL; /* FIXME: Erg, we've been signalled, how
-			      * do we propagate this back up? */
+	if (orinoco_lock(priv, &flags) != 0)
+		return NULL;  /* FIXME: Erg, we've been signalled, how
+			       * do we propagate this back up? */
 
 	if (priv->iw_mode == IW_MODE_ADHOC) {
 		memset(&wstats->qual, 0, sizeof(wstats->qual));
@@ -1819,10 +1817,8 @@
 		return 0;
 	}
 
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
-
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
 		
 	err = hermes_disable_port(hw, 0);
 	if (err) {
@@ -1864,11 +1860,10 @@
 {
 	struct orinoco_private *priv = netdev_priv(dev);
 	struct hermes *hw = &priv->hw;
-	int err;
+	int err = 0;
 	unsigned long flags;
 
-	err = orinoco_lock(priv, &flags);
-	if (err)
+	if (orinoco_lock(priv, &flags) != 0)
 		/* When the hardware becomes available again, whatever
 		 * detects that is responsible for re-initializing
 		 * it. So no need for anything further */
@@ -2411,9 +2406,8 @@
 	int err = 0;
 	unsigned long flags;
 
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
 
 	err = hermes_read_ltv(hw, USER_BAP, HERMES_RID_CURRENTBSSID,
 			      ETH_ALEN, NULL, buf);
@@ -2433,9 +2427,8 @@
 	int len;
 	unsigned long flags;
 
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
 
 	if (strlen(priv->desired_essid) > 0) {
 		/* We read the desired SSID from the hardware rather
@@ -2486,9 +2479,8 @@
 	long freq = 0;
 	unsigned long flags;
 
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
 	
 	err = hermes_read_wordrec(hw, USER_BAP, HERMES_RID_CURRENTCHANNEL, &channel);
 	if (err)
@@ -2528,9 +2520,8 @@
 	int i;
 	unsigned long flags;
 
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
 
 	err = hermes_read_ltv(hw, USER_BAP, HERMES_RID_SUPPORTEDDATARATES,
 			      sizeof(list), NULL, &list);
@@ -2568,9 +2559,8 @@
 
 	rrq->length = sizeof(range);
 
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
 
 	mode = priv->iw_mode;
 	orinoco_unlock(priv, &flags);
@@ -2639,9 +2629,8 @@
 	range.min_frag = 256;
 	range.max_frag = 2346;
 
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
 	if (priv->has_wep) {
 		range.max_encoding_tokens = ORINOCO_MAX_KEYS;
 
@@ -2706,10 +2695,9 @@
 		if (copy_from_user(keybuf, erq->pointer, erq->length))
 			return -EFAULT;
 	}
-	
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
+
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
 	
 	if (erq->pointer) {
 		if (erq->length > ORINOCO_MAX_KEY_SIZE) {
@@ -2788,12 +2776,10 @@
 	int index = (erq->flags & IW_ENCODE_INDEX) - 1;
 	u16 xlen = 0;
 	char keybuf[ORINOCO_MAX_KEY_SIZE];
-	int err;
 	unsigned long flags;
-	
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
+
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
 
 	if ((index < 0) || (index >= ORINOCO_MAX_KEYS))
 		index = priv->tx_key;
@@ -2833,7 +2819,6 @@
 {
 	struct orinoco_private *priv = netdev_priv(dev);
 	char essidbuf[IW_ESSID_MAX_SIZE+1];
-	int err;
 	unsigned long flags;
 
 	/* Note : ESSID is ignored in Ad-Hoc demo mode, but we can set it
@@ -2851,9 +2836,8 @@
 		essidbuf[erq->length] = '\0';
 	}
 
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
 
 	memcpy(priv->desired_essid, essidbuf, sizeof(priv->desired_essid));
 
@@ -2877,9 +2861,8 @@
 		if (err)
 			return err;
 	} else {
-		err = orinoco_lock(priv, &flags);
-		if (err)
-			return err;
+		if (orinoco_lock(priv, &flags) != 0)
+			return -EBUSY;
 		memcpy(essidbuf, priv->desired_essid, sizeof(essidbuf));
 		orinoco_unlock(priv, &flags);
 	}
@@ -2899,7 +2882,6 @@
 {
 	struct orinoco_private *priv = netdev_priv(dev);
 	char nickbuf[IW_ESSID_MAX_SIZE+1];
-	int err;
 	unsigned long flags;
 
 	if (nrq->length > IW_ESSID_MAX_SIZE)
@@ -2912,9 +2894,8 @@
 
 	nickbuf[nrq->length] = '\0';
 	
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
 
 	memcpy(priv->nick, nickbuf, sizeof(priv->nick));
 
@@ -2927,12 +2908,10 @@
 {
 	struct orinoco_private *priv = netdev_priv(dev);
 	char nickbuf[IW_ESSID_MAX_SIZE+1];
-	int err;
 	unsigned long flags;
 
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
 
 	memcpy(nickbuf, priv->nick, IW_ESSID_MAX_SIZE+1);
 	orinoco_unlock(priv, &flags);
@@ -2949,7 +2928,6 @@
 {
 	struct orinoco_private *priv = netdev_priv(dev);
 	int chan = -1;
-	int err;
 	unsigned long flags;
 
 	/* We can only use this in Ad-Hoc demo mode to set the operating
@@ -2978,9 +2956,8 @@
 	     ! (priv->channel_mask & (1 << (chan-1)) ) )
 		return -EINVAL;
 
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
 	priv->channel = chan;
 	orinoco_unlock(priv, &flags);
 
@@ -2998,9 +2975,8 @@
 	if (!priv->has_sensitivity)
 		return -EOPNOTSUPP;
 
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
 	err = hermes_read_wordrec(hw, USER_BAP,
 				  HERMES_RID_CNFSYSTEMSCALE, &val);
 	orinoco_unlock(priv, &flags);
@@ -3018,7 +2994,6 @@
 {
 	struct orinoco_private *priv = netdev_priv(dev);
 	int val = srq->value;
-	int err;
 	unsigned long flags;
 
 	if (!priv->has_sensitivity)
@@ -3027,9 +3002,8 @@
 	if ((val < 1) || (val > 3))
 		return -EINVAL;
 	
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
 	priv->ap_density = val;
 	orinoco_unlock(priv, &flags);
 
@@ -3040,7 +3014,6 @@
 {
 	struct orinoco_private *priv = netdev_priv(dev);
 	int val = rrq->value;
-	int err;
 	unsigned long flags;
 
 	if (rrq->disabled)
@@ -3049,9 +3022,8 @@
 	if ( (val < 0) || (val > 2347) )
 		return -EINVAL;
 
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
 
 	priv->rts_thresh = val;
 	orinoco_unlock(priv, &flags);
@@ -3065,9 +3037,8 @@
 	int err = 0;
 	unsigned long flags;
 
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
 
 	if (priv->has_mwo) {
 		if (frq->disabled)
@@ -3102,9 +3073,8 @@
 	u16 val;
 	unsigned long flags;
 
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
 	
 	if (priv->has_mwo) {
 		err = hermes_read_wordrec(hw, USER_BAP,
@@ -3166,9 +3136,8 @@
 	if (ratemode == -1)
 		return -EINVAL;
 
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
 	priv->bitratemode = ratemode;
 	orinoco_unlock(priv, &flags);
 
@@ -3185,9 +3154,8 @@
 	u16 val;
 	unsigned long flags;
 
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
 
 	ratemode = priv->bitratemode;
 
@@ -3247,9 +3215,8 @@
 	int err = 0;
 	unsigned long flags;
 
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
 
 	if (prq->disabled) {
 		priv->pm_on = 0;
@@ -3302,9 +3269,8 @@
 	u16 enable, period, timeout, mcast;
 	unsigned long flags;
 
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
 	
 	err = hermes_read_wordrec(hw, USER_BAP, HERMES_RID_CNFPMENABLED, &enable);
 	if (err)
@@ -3351,9 +3317,8 @@
 	u16 short_limit, long_limit, lifetime;
 	unsigned long flags;
 
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
 	
 	err = hermes_read_wordrec(hw, USER_BAP, HERMES_RID_SHORTRETRYLIMIT,
 				  &short_limit);
@@ -3399,12 +3364,10 @@
 {
 	struct orinoco_private *priv = netdev_priv(dev);
 	int val = *( (int *) wrq->u.name );
-	int err;
 	unsigned long flags;
 
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
 
 	priv->ibss_port = val ;
 
@@ -3419,12 +3382,10 @@
 {
 	struct orinoco_private *priv = netdev_priv(dev);
 	int *val = (int *)wrq->u.name;
-	int err;
 	unsigned long flags;
 
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
 
 	*val = priv->ibss_port;
 	orinoco_unlock(priv, &flags);
@@ -3439,9 +3400,8 @@
 	int err = 0;
 	unsigned long flags;
 
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
 
 	switch (val) {
 	case 0: /* Try to do IEEE ad-hoc mode */
@@ -3478,12 +3438,10 @@
 {
 	struct orinoco_private *priv = netdev_priv(dev);
 	int *val = (int *)wrq->u.name;
-	int err;
 	unsigned long flags;
 
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
 
 	*val = priv->prefer_port3;
 	orinoco_unlock(priv, &flags);
@@ -3513,9 +3471,8 @@
 	}
 
 	/* Make sure nobody mess with the structure while we do */
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
 
 	/* orinoco_lock() doesn't disable interrupts, so make sure the
 	 * interrupt rx path don't get confused while we copy */
@@ -3546,12 +3503,10 @@
 	struct iw_quality spy_stat[IW_MAX_SPY];
 	int number;
 	int i;
-	int err;
 	unsigned long flags;
 
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
 
 	number = priv->spy_number;
 	if ((number > 0) && (srq->pointer)) {
@@ -3621,9 +3576,8 @@
 		break;
 
 	case SIOCSIWMODE:
-		err = orinoco_lock(priv, &flags);
-		if (err)
-			return err;
+		if (orinoco_lock(priv, &flags) != 0)
+			return -EBUSY;
 		switch (wrq->u.mode) {
 		case IW_MODE_ADHOC:
 			if (! (priv->has_ibss || priv->has_port3) )
@@ -3648,9 +3602,8 @@
 		break;
 
 	case SIOCGIWMODE:
-		err = orinoco_lock(priv, &flags);
-		if (err)
-			return err;
+		if (orinoco_lock(priv, &flags) != 0)
+			return -EBUSY;
 		wrq->u.mode = priv->iw_mode;
 		orinoco_unlock(priv, &flags);
 		break;
@@ -3865,9 +3818,8 @@
 		if(priv->has_preamble) {
 			int val = *( (int *) wrq->u.name );
 
-			err = orinoco_lock(priv, &flags);
-			if (err)
-				return err;
+			if (orinoco_lock(priv, &flags) != 0)
+				return -EBUSY;
 			if (val)
 				priv->preamble = 1;
 			else
@@ -3882,9 +3834,8 @@
 		if(priv->has_preamble) {
 			int *val = (int *)wrq->u.name;
 
-			err = orinoco_lock(priv, &flags);
-			if (err)
-				return err;
+			if (orinoco_lock(priv, &flags) != 0)
+				return -EBUSY;
 			*val = priv->preamble;
 			orinoco_unlock(priv, &flags);
 		} else
diff -Nru a/drivers/net/wireless/wl3501_cs.c b/drivers/net/wireless/wl3501_cs.c
--- a/drivers/net/wireless/wl3501_cs.c	2005-01-10 23:54:12 -05:00
+++ b/drivers/net/wireless/wl3501_cs.c	2005-01-10 23:54:12 -05:00
@@ -100,7 +100,7 @@
 /* Parameters that can be set with 'insmod' */
 /* Bit map of interrupts to choose from */
 /* This means pick from 15, 14, 12, 11, 10, 9, 7, 5, 4, and 3 */
-static unsigned long wl3501_irq_mask = 0xdeb8;
+static unsigned int wl3501_irq_mask = 0xdeb8;
 static int wl3501_irq_list[4] = { -1 };
 
 /*
@@ -2279,7 +2279,7 @@
 module_init(wl3501_init_module);
 module_exit(wl3501_exit_module);
 
-module_param(wl3501_irq_mask, int, 0);
+module_param(wl3501_irq_mask, uint, 0);
 module_param_array(wl3501_irq_list, int, NULL, 0);
 MODULE_AUTHOR("Fox Chen <mhchen@golf.ccl.itri.org.tw>, "
 	      "Arnaldo Carvalho de Melo <acme@conectiva.com.br>,"
diff -Nru a/include/linux/arcdevice.h b/include/linux/arcdevice.h
--- a/include/linux/arcdevice.h	2005-01-10 23:54:12 -05:00
+++ b/include/linux/arcdevice.h	2005-01-10 23:54:12 -05:00
@@ -343,7 +343,6 @@
 
 void arcnet_unregister_proto(struct ArcProto *proto);
 irqreturn_t arcnet_interrupt(int irq, void *dev_id, struct pt_regs *regs);
-void arcdev_setup(struct net_device *dev);
 struct net_device *alloc_arcdev(char *name);
 void arcnet_rx(struct net_device *dev, int bufnum);
 

--------------090609000705090202000403--
