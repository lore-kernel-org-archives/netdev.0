From: Aristeu Sergio Rozanski Filho <aris@cathedrallabs.org>
Subject: Re: [PATCH] 1/5: eepro: cache EEPROM values
Date: Fri, 7 Jan 2005 09:13:03 -0200
Message-ID: <20050107111303.GR27328@cathedrallabs.org>
References: <20041118234043.GF24080@cathedrallabs.org> <41DE075F.4090008@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="J+eNKFoVC4T1DV3f"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <41DE075F.4090008@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--J+eNKFoVC4T1DV3f
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

> your patches look good, but do not seem to apply.
> 
> can you please resend versus 2.6.10?
sure!
they're attached

-- 
Aristeu


--J+eNKFoVC4T1DV3f
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="01-eepro-cache_eeprom_values.patch"

eepro: cache EEPROM values

Signed-off-by: Aristeu Sergio Rozanski Filho <aris@cathedrallabs.org>

--- 2.6-inc/drivers/net/eepro.c	2004-09-13 15:54:43.000000000 -0300
+++ 2.6-foo/drivers/net/eepro.c	2004-09-14 13:46:15.000000000 -0300
@@ -214,6 +214,7 @@ struct eepro_local {
 	short rcv_lower_limit;
 	short rcv_upper_limit;
 	unsigned char eeprom_reg;
+	unsigned short word[8];
 };
 
 /* The station (ethernet) address prefix, used for IDing the board. */
@@ -608,16 +609,22 @@ out:
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
@@ -625,7 +632,7 @@ static void __init printEEPROMInfo(short
 	printk(KERN_DEBUG " IO Address: %#x\n", (Word>>ee_IO0)<<4);
 
 	if (net_debug>4)  {
-		Word=read_eeprom(ioaddr, 1, dev);
+		Word = lp->word[1];
 		printk(KERN_DEBUG "Word1:\n");
 		printk(KERN_DEBUG " INT: %d\n", Word & ee_IntMask);
 		printk(KERN_DEBUG " LI: %d\n", GetBit(Word,ee_LI));
@@ -636,7 +643,7 @@ static void __init printEEPROMInfo(short
 		printk(KERN_DEBUG " Duplex: %d\n", GetBit(Word,ee_Duplex));
 	}
 
-	Word=read_eeprom(ioaddr, 5, dev);
+	Word = lp->word[5];
 	printk(KERN_DEBUG "Word5:\n");
 	printk(KERN_DEBUG " BNC: %d\n",GetBit(Word,ee_BNC_TPE));
 	printk(KERN_DEBUG " NumConnectors: %d\n",GetBit(Word,ee_NumConn));
@@ -646,12 +653,12 @@ static void __init printEEPROMInfo(short
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
 
@@ -725,7 +732,7 @@ static void __init eepro_print_info (str
 		printk(", %s.\n", ifmap[dev->if_port]);
 
 	if (net_debug > 3) {
-		i = read_eeprom(dev->base_addr, 5, dev);
+		i = lp->word[5];
 		if (i & 0x2000) /* bit 13 of EEPROM word 5 */
 			printk(KERN_DEBUG "%s: Concurrent Processing is "
 				"enabled but not used!\n", dev->name);
@@ -733,7 +740,7 @@ static void __init eepro_print_info (str
 
 	/* Check the station address for the manufacturer's code */
 	if (net_debug>3)
-		printEEPROMInfo(dev->base_addr, dev);
+		printEEPROMInfo(dev);
 }
 
 /* This is the real probe routine.  Linux has a history of friendly device
@@ -796,11 +803,16 @@ static int __init eepro_probe1(struct ne
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
@@ -817,15 +829,15 @@ static int __init eepro_probe1(struct ne
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
@@ -941,7 +953,7 @@ static int eepro_open(struct net_device 
 	if (net_debug > 3)
 		printk(KERN_DEBUG "%s: entering eepro_open routine.\n", dev->name);
 
-	irqMask = read_eeprom(ioaddr,7,dev);
+	irqMask = lp->word[7];
 
 	if (lp->eepro == LAN595FX_10ISA) {
 		if (net_debug > 3) printk(KERN_DEBUG "p->eepro = 3;\n");

--J+eNKFoVC4T1DV3f
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="02-eepro-module_param.patch"

diff -uprN -X dontdiff 2.6-inc/drivers/net/eepro.c 2.6/drivers/net/eepro.c
--- 2.6-inc/drivers/net/eepro.c	2005-01-07 09:01:26.128430328 -0200
+++ 2.6/drivers/net/eepro.c	2005-01-07 09:01:12.409515920 -0200
@@ -1732,10 +1732,11 @@ MODULE_AUTHOR("Pascal Dupuis, and aris@c
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

--J+eNKFoVC4T1DV3f
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="03-eepro-ethtool_basic.patch"

diff -uprN -X dontdiff 2.6-inc/drivers/net/eepro.c 2.6/drivers/net/eepro.c
--- 2.6-inc/drivers/net/eepro.c	2005-01-07 09:03:59.854060480 -0200
+++ 2.6/drivers/net/eepro.c	2005-01-07 09:04:39.659009208 -0200
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
 
@@ -146,19 +147,21 @@ static const char version[] =
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
@@ -743,16 +746,17 @@ static void __init eepro_print_info (str
 		printEEPROMInfo(dev);
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
@@ -862,6 +866,7 @@ static int __init eepro_probe1(struct ne
  	dev->set_multicast_list = &set_multicast_list;
  	dev->tx_timeout		= eepro_tx_timeout;
  	dev->watchdog_timeo	= TX_TIMEOUT;
+	dev->ethtool_ops	= &eepro_ethtool_ops;
  
 	/* print boot time info */
 	eepro_print_info(dev);
@@ -1082,8 +1087,6 @@ static int eepro_open(struct net_device 
 		old9 = inb(ioaddr + 9);
 
 		if (irqMask==ee_FX_INT2IRQ) {
-			enum iftype { AUI=0, BNC=1, TPE=2 };
-
 			if (net_debug > 3) {
 				printk(KERN_DEBUG "IrqMask: %#x\n",irqMask);
 				printk(KERN_DEBUG "i82595FX detected!\n");
@@ -1713,6 +1716,64 @@ eepro_transmit_interrupt(struct net_devi
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
@@ -1728,7 +1789,7 @@ static int autodetect;
 static int n_eepro;
 /* For linux 2.1.xx */
 
-MODULE_AUTHOR("Pascal Dupuis, and aris@cathedrallabs.org");
+MODULE_AUTHOR("Pascal Dupuis and others");
 MODULE_DESCRIPTION("Intel i82595 ISA EtherExpressPro10/10+ driver");
 MODULE_LICENSE("GPL");
 

--J+eNKFoVC4T1DV3f
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="04-eepro-fix_return_value_in_init.patch"

eepro: fix return value in init_module()

Signed-off-by: Aristeu Sergio Rozanski Filho <aris@cathedrallabs.org>

--- 2.6/drivers/net/eepro.c.orig	2004-10-05 22:26:48.000000000 -0300
+++ 2.6/drivers/net/eepro.c	2004-10-05 22:27:00.000000000 -0300
@@ -1811,7 +1811,7 @@ init_module(void)
 	if (io[0] == 0 && autodetect == 0) {
 		printk(KERN_WARNING "eepro_init_module: Probe is very dangerous in ISA boards!\n");
 		printk(KERN_WARNING "eepro_init_module: Please add \"autodetect=1\" to force probe\n");
-		return 1;
+		return -ENODEV;
 	}
 	else if (autodetect) {
 		/* if autodetect is set then we must force detection */

--J+eNKFoVC4T1DV3f
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="05-eepro-fix_autodetect_option.patch"

eepro: fix auto-detection option

Signed-off-by: Aristeu Sergio Rozanski Filho <aris@cathedrallabs.org>

--- 2.6-dual/drivers/net/eepro.c.orig	2004-10-05 22:27:55.000000000 -0300
+++ 2.6-dual/drivers/net/eepro.c	2004-10-05 21:44:23.000000000 -0300
@@ -1779,7 +1779,9 @@ static struct ethtool_ops eepro_ethtool_
 #define MAX_EEPRO 8
 static struct net_device *dev_eepro[MAX_EEPRO];
 
-static int io[MAX_EEPRO];
+static int io[MAX_EEPRO] = {
+  [0 ... MAX_EEPRO-1] = -1
+};
 static int irq[MAX_EEPRO];
 static int mem[MAX_EEPRO] = {	/* Size of the rx buffer in KB */
   [0 ... MAX_EEPRO-1] = RCV_DEFAULT_RAM/1024
@@ -1808,19 +1810,21 @@ init_module(void)
 {
 	struct net_device *dev;
 	int i;
-	if (io[0] == 0 && autodetect == 0) {
+	if (io[0] == -1 && autodetect == 0) {
 		printk(KERN_WARNING "eepro_init_module: Probe is very dangerous in ISA boards!\n");
 		printk(KERN_WARNING "eepro_init_module: Please add \"autodetect=1\" to force probe\n");
 		return -ENODEV;
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

--J+eNKFoVC4T1DV3f--
