From: Aristeu Sergio Rozanski Filho <aris@cathedrallabs.org>
Subject: [PATCH 2.6.10 3/5] eepro: basic ethtool support
Date: Fri, 7 Jan 2005 09:51:00 -0200
Message-ID: <20050107115100.GU27328@cathedrallabs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

eepro: basic ethtool support

Signed-off-by: Aristeu Sergio Rozanski Filho <aris@cathedrallabs.org>

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
 
