From: Jeff Garzik <jgarzik@pobox.com>
Subject: [BK PATCHES] 2.6.x net driver updates
Date: Sun, 06 Mar 2005 18:38:35 -0500
Message-ID: <422B947B.5080504@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030602010205090106010908"
Cc: Netdev <netdev@oss.sgi.com>, Linux Kernel <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030602010205090106010908
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Mostly fixes / MIPS update.

--------------030602010205090106010908
Content-Type: text/plain;
 name="changelog.txt"
Content-Disposition: inline;
 filename="changelog.txt"
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by oss.sgi.com id j26NgnR7018145

Please do a

	bk pull bk://gkernel.bkbits.net/net-drivers-2.6

This will update the following files:

 drivers/net/bagetlance.c             | 1368 ----------------------------=
-------
 Documentation/networking/ixgb.txt    |    9=20
 MAINTAINERS                          |    4=20
 drivers/net/Kconfig                  |   14=20
 drivers/net/Makefile                 |    1=20
 drivers/net/Space.c                  |   11=20
 drivers/net/amd8111e.c               |    2=20
 drivers/net/au1000_eth.c             | 1361 ++++++++++++++++++++++++++++=
------
 drivers/net/au1000_eth.h             |   55 -
 drivers/net/dl2k.c                   |    2=20
 drivers/net/gianfar.c                |    2=20
 drivers/net/ibm_emac/ibm_emac.h      |    4=20
 drivers/net/ibm_emac/ibm_emac_core.c |   16=20
 drivers/net/ibm_emac/ibm_emac_core.h |    2=20
 drivers/net/ioc3-eth.c               |   82 +-
 drivers/net/jazzsonic.c              |  217 +++--
 drivers/net/meth.c                   |  275 +++----
 drivers/net/meth.h                   |    2=20
 drivers/net/mv643xx_eth.c            |    2=20
 drivers/net/pcnet32.c                |   47 -
 drivers/net/s2io.c                   |   45 -
 drivers/net/sb1250-mac.c             |  109 +-
 drivers/net/sgiseeq.c                |   70 +
 drivers/net/sk98lin/skge.c           |    2=20
 drivers/net/sonic.c                  |    4=20
 drivers/net/wan/Kconfig              |   11=20
 drivers/net/wan/hd6457x.c            |    2=20
 drivers/net/wan/z85230.c             |    4=20
 include/linux/pci_ids.h              |    5=20
 29 files changed, 1720 insertions(+), 2008 deletions(-)

through these ChangeSets:

<takis:lumumba.luc.ac.be>:
  o Possible AMD8111e free irq issue

Don Fry:
  o pcnet32: 79c976 with fiber optic fix

Ganesh Venkatesan:
  o ixgb: Documentation/networking/ixgb.txt

John W. Linville:
  o sk98lin: add MODULE_DEVICE_TABLE entry

Krzysztof Halasa:
  o WAN drivers fix: N2, C101, PCI200SYN - quite fatal

Kumar Gala:
  o initialize a spin lock in gianfar driver

Matt Porter:
  o emac: fix skb allocation for full-size jumbo frames
  o Add PPC440SP support to IBM EMAC driver

Ralf B=E4chle:
  o SGI Seeq updates
  o SB1250 driver updates
  o S2IO syntax fixes
  o Meth driver updates
  o Marvell MV-64340 driver upda
  o Jazzsonic driver updates
  o IOC3 driver updates
  o Remove Baget network driver
  o Au1000 driver updates

Thierry Vignaud:
  o fix driver name in dl2k as returned by ETHTOOL_GDRVINFO

tom watson:
  o drivers/net/wan/z85230.c interrupt handling fix


--------------030602010205090106010908
Content-Type: text/plain;
 name="patch"
Content-Disposition: inline;
 filename="patch"
Content-Transfer-Encoding: 7bit

diff -Nru a/Documentation/networking/ixgb.txt b/Documentation/networking/ixgb.txt
--- a/Documentation/networking/ixgb.txt	2005-03-06 18:36:50 -05:00
+++ b/Documentation/networking/ixgb.txt	2005-03-06 18:36:50 -05:00
@@ -1,7 +1,7 @@
 Linux* Base Driver for the Intel(R) PRO/10GbE Family of Adapters
 ================================================================
 
-September 13, 2004
+November 17, 2004
 
 
 Contents
@@ -18,8 +18,7 @@
 ===============
 
 This file describes the Linux* Base Driver for the Intel(R) PRO/10GbE Family 
-of Adapters, version 1.0.x.  This driver includes support for Itanium(TM)2 and
-EM64T systems.
+of Adapters, version 1.0.x.  
 
 For questions related to hardware requirements, refer to the documentation 
 supplied with your Intel PRO/10GbE adapter. All hardware requirements listed 
@@ -71,8 +70,8 @@
     Ethernet PAUSE frames.
 
 RxDescriptors
-Valid Range: 64-4096
-Default Value: 1024
+Valid Range: 64-512
+Default Value: 512
     This value is the number of receive descriptors allocated by the driver. 
     Increasing this value allows the driver to buffer more incoming packets. 
     Each descriptor is 16 bytes.  A receive buffer is also allocated for 
diff -Nru a/MAINTAINERS b/MAINTAINERS
--- a/MAINTAINERS	2005-03-06 18:36:50 -05:00
+++ b/MAINTAINERS	2005-03-06 18:36:50 -05:00
@@ -910,10 +910,10 @@
 W:	http://www.icp-vortex.com/
 S:	Supported
 
-GENERIC HDLC DRIVER, N2 AND C101 DRIVERS
+GENERIC HDLC DRIVER, N2, C101, PCI200SYN and WANXL DRIVERS
 P:	Krzysztof Halasa
 M:	khc@pm.waw.pl
-W:	http://hq.pm.waw.pl/hdlc/
+W:	http://www.kernel.org/pub/linux/utils/net/hdlc/
 S:	Maintained
 
 HAYES ESP SERIAL DRIVER
diff -Nru a/drivers/net/Kconfig b/drivers/net/Kconfig
--- a/drivers/net/Kconfig	2005-03-06 18:36:50 -05:00
+++ b/drivers/net/Kconfig	2005-03-06 18:36:50 -05:00
@@ -445,7 +445,7 @@
 
 config MIPS_JAZZ_SONIC
 	tristate "MIPS JAZZ onboard SONIC Ethernet support"
-	depends on NET_ETHERNET && MIPS_JAZZ
+	depends on NET_ETHERNET && MACH_JAZZ
 	help
 	  This is the driver for the onboard card of MIPS Magnum 4000,
 	  Acer PICA, Olivetti M700-10 and a few other identical OEM systems.
@@ -470,7 +470,7 @@
 
 config SGI_IOC3_ETH
 	bool "SGI IOC3 Ethernet"
-	depends on NET_ETHERNET && SGI_IP27
+	depends on NET_ETHERNET && PCI && SGI_IP27
 	select CRC32
 	select MII
 	help
@@ -1763,14 +1763,6 @@
 	  DEC (now Compaq) based on the AMD Lance chipset, including the
 	  DEPCA series.  (This chipset is better known via the NE2100 cards.)
 
-config BAGETLANCE
-	tristate "Baget AMD LANCE support"
-	depends on NET_ETHERNET && BAGET_MIPS
-	help
-	  Say Y to enable kernel support for AMD Lance Ethernet cards on the
-	  MIPS-32-based Baget embedded system.  This chipset is better known
-	  via the NE2100 cards.
-
 config 68360_ENET
 	bool "Motorola 68360 ethernet controller"
 	depends on M68360
@@ -2077,7 +2069,7 @@
 
 config MV643XX_ETH
 	tristate "MV-643XX Ethernet support"
-	depends on MOMENCO_OCELOT_C || MOMENCO_JAGUAR_ATX
+	depends on MOMENCO_OCELOT_C || MOMENCO_JAGUAR_ATX || MOMENCO_OCELOT_3
 	help
 	  This driver supports the gigabit Ethernet on the Marvell MV643XX
 	  chipset which is used in the Momenco Ocelot C and Jaguar ATX.
diff -Nru a/drivers/net/Makefile b/drivers/net/Makefile
--- a/drivers/net/Makefile	2005-03-06 18:36:50 -05:00
+++ b/drivers/net/Makefile	2005-03-06 18:36:50 -05:00
@@ -162,7 +162,6 @@
 obj-$(CONFIG_MIPS_GT96100ETH) += gt96100eth.o
 obj-$(CONFIG_MIPS_AU1X00_ENET) += au1000_eth.o
 obj-$(CONFIG_SGI_IOC3_ETH) += ioc3-eth.o
-obj-$(CONFIG_BAGETLANCE) += bagetlance.o
 obj-$(CONFIG_DECLANCE) += declance.o
 obj-$(CONFIG_ATARILANCE) += atarilance.o
 obj-$(CONFIG_ATARI_BIONET) += atari_bionet.o
diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	2005-03-06 18:36:50 -05:00
+++ b/drivers/net/Space.c	2005-03-06 18:36:50 -05:00
@@ -302,16 +302,6 @@
 	{NULL, 0},
 };
 
-static struct devprobe2 mips_probes[] __initdata = {
-#ifdef CONFIG_MIPS_JAZZ_SONIC
-	{sonic_probe, 0},
-#endif
-#ifdef CONFIG_BAGETLANCE        /* Lance-based Baget ethernet boards */
-        {bagetlance_probe, 0},
-#endif
-	{NULL, 0},
-};
-
 /*
  * Unified ethernet device probe, segmented per architecture and
  * per bus interface. This drives the legacy devices only for now.
@@ -325,7 +315,6 @@
 		return;
 
 	(void)(	probe_list2(unit, m68k_probes, base_addr == 0) &&
-		probe_list2(unit, mips_probes, base_addr == 0) &&
 		probe_list2(unit, eisa_probes, base_addr == 0) &&
 		probe_list2(unit, mca_probes, base_addr == 0) &&
 		probe_list2(unit, isa_probes, base_addr == 0) &&
diff -Nru a/drivers/net/amd8111e.c b/drivers/net/amd8111e.c
--- a/drivers/net/amd8111e.c	2005-03-06 18:36:50 -05:00
+++ b/drivers/net/amd8111e.c	2005-03-06 18:36:50 -05:00
@@ -1381,6 +1381,8 @@
 
 	if(amd8111e_restart(dev)){
 		spin_unlock_irq(&lp->lock);
+		if (dev->irq)
+			free_irq(dev->irq, dev);
 		return -ENOMEM;
 	}
 	/* Start ipg timer */
diff -Nru a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
--- a/drivers/net/au1000_eth.c	2005-03-06 18:36:50 -05:00
+++ b/drivers/net/au1000_eth.c	2005-03-06 18:36:50 -05:00
@@ -1,10 +1,19 @@
 /*
- * Alchemy Semi Au1000 ethernet driver
  *
- * Copyright 2001 MontaVista Software Inc.
+ * Alchemy Au1x00 ethernet driver
+ *
+ * Copyright 2001,2002,2003 MontaVista Software Inc.
+ * Copyright 2002 TimeSys Corp.
+ * Added ethtool/mii-tool support,
+ * Copyright 2004 Matt Porter <mporter@kernel.crashing.org>
+ * Update: 2004 Bjoern Riemer, riemer@fokus.fraunhofer.de 
+ * or riemer@riemer-nt.de: fixed the link beat detection with 
+ * ioctls (SIOCGMIIPHY)
  * Author: MontaVista Software, Inc.
  *         	ppopov@mvista.com or source@mvista.com
  *
+ * ########################################################################
+ *
  *  This program is free software; you can distribute it and/or modify it
  *  under the terms of the GNU General Public License (Version 2) as
  *  published by the Free Software Foundation.
@@ -17,46 +26,59 @@
  *  You should have received a copy of the GNU General Public License along
  *  with this program; if not, write to the Free Software Foundation, Inc.,
  *  59 Temple Place - Suite 330, Boston MA 02111-1307, USA.
+ *
+ * ########################################################################
+ *
+ * 
  */
-#include <linux/config.h>
 
 #include <linux/module.h>
 #include <linux/kernel.h>
+#include <linux/sched.h>
 #include <linux/string.h>
 #include <linux/timer.h>
 #include <linux/errno.h>
 #include <linux/in.h>
 #include <linux/ioport.h>
+#include <linux/bitops.h>
 #include <linux/slab.h>
 #include <linux/interrupt.h>
 #include <linux/pci.h>
 #include <linux/init.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
+#include <linux/ethtool.h>
+#include <linux/mii.h>
 #include <linux/skbuff.h>
 #include <linux/delay.h>
-#include <linux/crc32.h>
-#include <linux/bitops.h>
-
 #include <asm/mipsregs.h>
 #include <asm/irq.h>
 #include <asm/io.h>
-#include <asm/au1000.h>
+#include <asm/processor.h>
 
+#include <asm/mach-au1x00/au1000.h>
+#include <asm/cpu.h>
 #include "au1000_eth.h"
 
 #ifdef AU1000_ETH_DEBUG
-static int au1000_debug = 10;
+static int au1000_debug = 5;
 #else
 static int au1000_debug = 3;
 #endif
 
+#define DRV_NAME	"au1000eth"
+#define DRV_VERSION	"1.5"
+#define DRV_AUTHOR	"Pete Popov <ppopov@embeddedalley.com>"
+#define DRV_DESC	"Au1xxx on-chip Ethernet driver"
+
+MODULE_AUTHOR(DRV_AUTHOR);
+MODULE_DESCRIPTION(DRV_DESC);
+MODULE_LICENSE("GPL");
+
 // prototypes
-static void *dma_alloc(size_t, dma_addr_t *);
-static void dma_free(void *, size_t);
 static void hard_stop(struct net_device *);
 static void enable_rx_tx(struct net_device *dev);
-static int __init au1000_probe1(long, int, int);
+static struct net_device * au1000_probe(u32 ioaddr, int irq, int port_num);
 static int au1000_init(struct net_device *);
 static int au1000_open(struct net_device *);
 static int au1000_close(struct net_device *);
@@ -78,8 +100,7 @@
 // externs
 extern  void ack_rise_edge_irq(unsigned int);
 extern int get_ethernet_addr(char *ethernet_addr);
-extern inline void str2eaddr(unsigned char *ea, unsigned char *str);
-extern inline unsigned char str2hexnum(unsigned char c);
+extern void str2eaddr(unsigned char *ea, unsigned char *str);
 extern char * __init prom_getcmdline(void);
 
 /*
@@ -97,29 +118,6 @@
  * complete immediately.
  */
 
-
-/*
- * Base address and interrupt of the Au1xxx ethernet macs
- */
-static struct {
-	unsigned int port;
-	int irq;
-} au1000_iflist[NUM_INTERFACES] = {
-		{AU1000_ETH0_BASE, AU1000_ETH0_IRQ}, 
-		{AU1000_ETH1_BASE, AU1000_ETH1_IRQ}
-	},
-  au1500_iflist[NUM_INTERFACES] = {
-		{AU1500_ETH0_BASE, AU1000_ETH0_IRQ}, 
-		{AU1500_ETH1_BASE, AU1000_ETH1_IRQ}
-	},
-  au1100_iflist[NUM_INTERFACES] = {
-		{AU1000_ETH0_BASE, AU1000_ETH0_IRQ}, 
-		{0, 0}
-	};
-
-static char version[] __devinitdata =
-    "au1000eth.c:1.0 ppopov@mvista.com\n";
-
 /* These addresses are only used if yamon doesn't tell us what
  * the mac address is, and the mac address is not passed on the
  * command line.
@@ -135,18 +133,36 @@
 #define cpu_to_dma32 cpu_to_be32
 #define dma32_to_cpu be32_to_cpu
 
+struct au1000_private *au_macs[NUM_ETH_INTERFACES];
 
 /* FIXME 
  * All of the PHY code really should be detached from the MAC 
  * code.
  */
 
+/* Default advertise */
+#define GENMII_DEFAULT_ADVERTISE \
+	ADVERTISED_10baseT_Half | ADVERTISED_10baseT_Full | \
+	ADVERTISED_100baseT_Half | ADVERTISED_100baseT_Full | \
+	ADVERTISED_Autoneg
+
+#define GENMII_DEFAULT_FEATURES \
+	SUPPORTED_10baseT_Half | SUPPORTED_10baseT_Full | \
+	SUPPORTED_100baseT_Half | SUPPORTED_100baseT_Full | \
+	SUPPORTED_Autoneg
+
+static char *phy_link[] = 
+{	"unknown", 
+	"10Base2", "10BaseT", 
+	"AUI",
+	"100BaseT", "100BaseTX", "100BaseFX"
+};
+
 int bcm_5201_init(struct net_device *dev, int phy_addr)
 {
 	s16 data;
 	
 	/* Stop auto-negotiation */
-	//printk("bcm_5201_init\n");
 	data = mdio_read(dev, phy_addr, MII_CONTROL);
 	mdio_write(dev, phy_addr, MII_CONTROL, data & ~MII_CNTL_AUTO);
 
@@ -161,17 +177,8 @@
 	data |= MII_CNTL_RST_AUTO | MII_CNTL_AUTO;
 	mdio_write(dev, phy_addr, MII_CONTROL, data);
 
-	/* Enable TX LED instead of FDX */
-	data = mdio_read(dev, phy_addr, MII_INT);
-	data &= ~MII_FDX_LED;
-	mdio_write(dev, phy_addr, MII_INT, data);
-
-	/* Enable TX LED instead of FDX */
-	data = mdio_read(dev, phy_addr, MII_INT);
-	data &= ~MII_FDX_LED;
-	mdio_write(dev, phy_addr, MII_INT, data);
-
-	if (au1000_debug > 4) dump_mii(dev, phy_addr);
+	if (au1000_debug > 4) 
+		dump_mii(dev, phy_addr);
 	return 0;
 }
 
@@ -179,7 +186,6 @@
 {
 	s16 mii_control, timeout;
 	
-	//printk("bcm_5201_reset\n");
 	mii_control = mdio_read(dev, phy_addr, MII_CONTROL);
 	mdio_write(dev, phy_addr, MII_CONTROL, mii_control | MII_CNTL_RESET);
 	mdelay(1);
@@ -242,12 +248,16 @@
 		printk("lsi_80227_init\n");
 
 	/* restart auto-negotiation */
-	mdio_write(dev, phy_addr, 0, 0x3200);
-
+	mdio_write(dev, phy_addr, MII_CONTROL,
+		   MII_CNTL_F100 | MII_CNTL_AUTO | MII_CNTL_RST_AUTO); // | MII_CNTL_FDX);
 	mdelay(1);
 
 	/* set up LEDs to correct display */
+#ifdef CONFIG_MIPS_MTX1
+	mdio_write(dev, phy_addr, 17, 0xff80);
+#else
 	mdio_write(dev, phy_addr, 17, 0xffc0);
+#endif
 
 	if (au1000_debug > 4)
 		dump_mii(dev, phy_addr);
@@ -294,9 +304,9 @@
 	mii_data = mdio_read(dev, aup->phy_addr, MII_STATUS);
 	if (mii_data & MII_STAT_LINK) {
 		*link = 1;
-		mii_data = mdio_read(dev, aup->phy_addr, MII_LSI_STAT);
-		if (mii_data & MII_LSI_STAT_SPD) {
-			if (mii_data & MII_LSI_STAT_FDX) {
+		mii_data = mdio_read(dev, aup->phy_addr, MII_LSI_PHY_STAT);
+		if (mii_data & MII_LSI_PHY_STAT_SPD) {
+			if (mii_data & MII_LSI_PHY_STAT_FDX) {
 				*speed = IF_PORT_100BASEFX;
 				dev->if_port = IF_PORT_100BASEFX;
 			}
@@ -337,12 +347,396 @@
 	return 0;
 }
 
+int am79c874_init(struct net_device *dev, int phy_addr)
+{
+	s16 data;
+
+	/* 79c874 has quit resembled bit assignments to BCM5201 */
+	if (au1000_debug > 4)
+		printk("am79c847_init\n");
+
+	/* Stop auto-negotiation */
+	data = mdio_read(dev, phy_addr, MII_CONTROL);
+	mdio_write(dev, phy_addr, MII_CONTROL, data & ~MII_CNTL_AUTO);
+
+	/* Set advertisement to 10/100 and Half/Full duplex
+	 * (full capabilities) */
+	data = mdio_read(dev, phy_addr, MII_ANADV);
+	data |= MII_NWAY_TX | MII_NWAY_TX_FDX | MII_NWAY_T_FDX | MII_NWAY_T;
+	mdio_write(dev, phy_addr, MII_ANADV, data);
+	
+	/* Restart auto-negotiation */
+	data = mdio_read(dev, phy_addr, MII_CONTROL);
+	data |= MII_CNTL_RST_AUTO | MII_CNTL_AUTO;
+
+	mdio_write(dev, phy_addr, MII_CONTROL, data);
+
+	if (au1000_debug > 4) dump_mii(dev, phy_addr);
+	return 0;
+}
+
+int am79c874_reset(struct net_device *dev, int phy_addr)
+{
+	s16 mii_control, timeout;
+	
+	if (au1000_debug > 4)
+		printk("am79c874_reset\n");
+
+	mii_control = mdio_read(dev, phy_addr, MII_CONTROL);
+	mdio_write(dev, phy_addr, MII_CONTROL, mii_control | MII_CNTL_RESET);
+	mdelay(1);
+	for (timeout = 100; timeout > 0; --timeout) {
+		mii_control = mdio_read(dev, phy_addr, MII_CONTROL);
+		if ((mii_control & MII_CNTL_RESET) == 0)
+			break;
+		mdelay(1);
+	}
+	if (mii_control & MII_CNTL_RESET) {
+		printk(KERN_ERR "%s PHY reset timeout !\n", dev->name);
+		return -1;
+	}
+	return 0;
+}
+
+int 
+am79c874_status(struct net_device *dev, int phy_addr, u16 *link, u16 *speed)
+{
+	u16 mii_data;
+	struct au1000_private *aup;
+
+	// printk("am79c874_status\n");
+	if (!dev) {
+		printk(KERN_ERR "am79c874_status error: NULL dev\n");
+		return -1;
+	}
+
+	aup = (struct au1000_private *) dev->priv;
+	mii_data = mdio_read(dev, aup->phy_addr, MII_STATUS);
+
+	if (mii_data & MII_STAT_LINK) {
+		*link = 1;
+		mii_data = mdio_read(dev, aup->phy_addr, MII_AMD_PHY_STAT);
+		if (mii_data & MII_AMD_PHY_STAT_SPD) {
+			if (mii_data & MII_AMD_PHY_STAT_FDX) {
+				*speed = IF_PORT_100BASEFX;
+				dev->if_port = IF_PORT_100BASEFX;
+			}
+			else {
+				*speed = IF_PORT_100BASETX;
+				dev->if_port = IF_PORT_100BASETX;
+			}
+		}
+		else {
+			*speed = IF_PORT_10BASET;
+			dev->if_port = IF_PORT_10BASET;
+		}
+
+	}
+	else {
+		*link = 0;
+		*speed = 0;
+		dev->if_port = IF_PORT_UNKNOWN;
+	}
+	return 0;
+}
+
+int lxt971a_init(struct net_device *dev, int phy_addr)
+{
+	if (au1000_debug > 4)
+		printk("lxt971a_init\n");
+
+	/* restart auto-negotiation */
+	mdio_write(dev, phy_addr, MII_CONTROL,
+		   MII_CNTL_F100 | MII_CNTL_AUTO | MII_CNTL_RST_AUTO | MII_CNTL_FDX);
+
+	/* set up LEDs to correct display */
+	mdio_write(dev, phy_addr, 20, 0x0422);
+
+	if (au1000_debug > 4)
+		dump_mii(dev, phy_addr);
+	return 0;
+}
+
+int lxt971a_reset(struct net_device *dev, int phy_addr)
+{
+	s16 mii_control, timeout;
+	
+	if (au1000_debug > 4) {
+		printk("lxt971a_reset\n");
+		dump_mii(dev, phy_addr);
+	}
+
+	mii_control = mdio_read(dev, phy_addr, MII_CONTROL);
+	mdio_write(dev, phy_addr, MII_CONTROL, mii_control | MII_CNTL_RESET);
+	mdelay(1);
+	for (timeout = 100; timeout > 0; --timeout) {
+		mii_control = mdio_read(dev, phy_addr, MII_CONTROL);
+		if ((mii_control & MII_CNTL_RESET) == 0)
+			break;
+		mdelay(1);
+	}
+	if (mii_control & MII_CNTL_RESET) {
+		printk(KERN_ERR "%s PHY reset timeout !\n", dev->name);
+		return -1;
+	}
+	return 0;
+}
+
+int
+lxt971a_status(struct net_device *dev, int phy_addr, u16 *link, u16 *speed)
+{
+	u16 mii_data;
+	struct au1000_private *aup;
+
+	if (!dev) {
+		printk(KERN_ERR "lxt971a_status error: NULL dev\n");
+		return -1;
+	}
+	aup = (struct au1000_private *) dev->priv;
+
+	mii_data = mdio_read(dev, aup->phy_addr, MII_STATUS);
+	if (mii_data & MII_STAT_LINK) {
+		*link = 1;
+		mii_data = mdio_read(dev, aup->phy_addr, MII_INTEL_PHY_STAT);
+		if (mii_data & MII_INTEL_PHY_STAT_SPD) {
+			if (mii_data & MII_INTEL_PHY_STAT_FDX) {
+				*speed = IF_PORT_100BASEFX;
+				dev->if_port = IF_PORT_100BASEFX;
+			}
+			else {
+				*speed = IF_PORT_100BASETX;
+				dev->if_port = IF_PORT_100BASETX;
+			}
+		}
+		else  {
+			*speed = IF_PORT_10BASET;
+			dev->if_port = IF_PORT_10BASET;
+		}
+
+	}
+	else {
+		*link = 0;
+		*speed = 0;
+		dev->if_port = IF_PORT_UNKNOWN;
+	}
+	return 0;
+}
+
+int ks8995m_init(struct net_device *dev, int phy_addr)
+{
+	s16 data;
+	
+//	printk("ks8995m_init\n");
+	/* Stop auto-negotiation */
+	data = mdio_read(dev, phy_addr, MII_CONTROL);
+	mdio_write(dev, phy_addr, MII_CONTROL, data & ~MII_CNTL_AUTO);
+
+	/* Set advertisement to 10/100 and Half/Full duplex
+	 * (full capabilities) */
+	data = mdio_read(dev, phy_addr, MII_ANADV);
+	data |= MII_NWAY_TX | MII_NWAY_TX_FDX | MII_NWAY_T_FDX | MII_NWAY_T;
+	mdio_write(dev, phy_addr, MII_ANADV, data);
+	
+	/* Restart auto-negotiation */
+	data = mdio_read(dev, phy_addr, MII_CONTROL);
+	data |= MII_CNTL_RST_AUTO | MII_CNTL_AUTO;
+	mdio_write(dev, phy_addr, MII_CONTROL, data);
+
+	if (au1000_debug > 4) dump_mii(dev, phy_addr);
+
+	return 0;
+}
+
+int ks8995m_reset(struct net_device *dev, int phy_addr)
+{
+	s16 mii_control, timeout;
+	
+//	printk("ks8995m_reset\n");
+	mii_control = mdio_read(dev, phy_addr, MII_CONTROL);
+	mdio_write(dev, phy_addr, MII_CONTROL, mii_control | MII_CNTL_RESET);
+	mdelay(1);
+	for (timeout = 100; timeout > 0; --timeout) {
+		mii_control = mdio_read(dev, phy_addr, MII_CONTROL);
+		if ((mii_control & MII_CNTL_RESET) == 0)
+			break;
+		mdelay(1);
+	}
+	if (mii_control & MII_CNTL_RESET) {
+		printk(KERN_ERR "%s PHY reset timeout !\n", dev->name);
+		return -1;
+	}
+	return 0;
+}
+
+int ks8995m_status(struct net_device *dev, int phy_addr, u16 *link, u16 *speed)
+{
+	u16 mii_data;
+	struct au1000_private *aup;
+
+	if (!dev) {
+		printk(KERN_ERR "ks8995m_status error: NULL dev\n");
+		return -1;
+	}
+	aup = (struct au1000_private *) dev->priv;
+
+	mii_data = mdio_read(dev, aup->phy_addr, MII_STATUS);
+	if (mii_data & MII_STAT_LINK) {
+		*link = 1;
+		mii_data = mdio_read(dev, aup->phy_addr, MII_AUX_CNTRL);
+		if (mii_data & MII_AUX_100) {
+			if (mii_data & MII_AUX_FDX) {
+				*speed = IF_PORT_100BASEFX;
+				dev->if_port = IF_PORT_100BASEFX;
+			}
+			else {
+				*speed = IF_PORT_100BASETX;
+				dev->if_port = IF_PORT_100BASETX;
+			}
+		}
+		else  {											
+			*speed = IF_PORT_10BASET;
+			dev->if_port = IF_PORT_10BASET;
+		}
+
+	}
+	else {
+		*link = 0;
+		*speed = 0;
+		dev->if_port = IF_PORT_UNKNOWN;
+	}
+	return 0;
+}
+
+int
+smsc_83C185_init (struct net_device *dev, int phy_addr)
+{
+	s16 data;
+
+	if (au1000_debug > 4)
+		printk("smsc_83C185_init\n");
+
+	/* Stop auto-negotiation */
+	data = mdio_read(dev, phy_addr, MII_CONTROL);
+	mdio_write(dev, phy_addr, MII_CONTROL, data & ~MII_CNTL_AUTO);
+
+	/* Set advertisement to 10/100 and Half/Full duplex
+	 * (full capabilities) */
+	data = mdio_read(dev, phy_addr, MII_ANADV);
+	data |= MII_NWAY_TX | MII_NWAY_TX_FDX | MII_NWAY_T_FDX | MII_NWAY_T;
+	mdio_write(dev, phy_addr, MII_ANADV, data);
+	
+	/* Restart auto-negotiation */
+	data = mdio_read(dev, phy_addr, MII_CONTROL);
+	data |= MII_CNTL_RST_AUTO | MII_CNTL_AUTO;
+
+	mdio_write(dev, phy_addr, MII_CONTROL, data);
+
+	if (au1000_debug > 4) dump_mii(dev, phy_addr);
+	return 0;
+}
+
+int
+smsc_83C185_reset (struct net_device *dev, int phy_addr)
+{
+	s16 mii_control, timeout;
+	
+	if (au1000_debug > 4)
+		printk("smsc_83C185_reset\n");
+
+	mii_control = mdio_read(dev, phy_addr, MII_CONTROL);
+	mdio_write(dev, phy_addr, MII_CONTROL, mii_control | MII_CNTL_RESET);
+	mdelay(1);
+	for (timeout = 100; timeout > 0; --timeout) {
+		mii_control = mdio_read(dev, phy_addr, MII_CONTROL);
+		if ((mii_control & MII_CNTL_RESET) == 0)
+			break;
+		mdelay(1);
+	}
+	if (mii_control & MII_CNTL_RESET) {
+		printk(KERN_ERR "%s PHY reset timeout !\n", dev->name);
+		return -1;
+	}
+	return 0;
+}
+
+int 
+smsc_83C185_status (struct net_device *dev, int phy_addr, u16 *link, u16 *speed)
+{
+	u16 mii_data;
+	struct au1000_private *aup;
+
+	if (!dev) {
+		printk(KERN_ERR "smsc_83C185_status error: NULL dev\n");
+		return -1;
+	}
+
+	aup = (struct au1000_private *) dev->priv;
+	mii_data = mdio_read(dev, aup->phy_addr, MII_STATUS);
+
+	if (mii_data & MII_STAT_LINK) {
+		*link = 1;
+		mii_data = mdio_read(dev, aup->phy_addr, 0x1f);
+		if (mii_data & (1<<3)) {
+			if (mii_data & (1<<4)) {
+				*speed = IF_PORT_100BASEFX;
+				dev->if_port = IF_PORT_100BASEFX;
+			}
+			else {
+				*speed = IF_PORT_100BASETX;
+				dev->if_port = IF_PORT_100BASETX;
+			}
+		}
+		else {
+			*speed = IF_PORT_10BASET;
+			dev->if_port = IF_PORT_10BASET;
+		}
+	}
+	else {
+		*link = 0;
+		*speed = 0;
+		dev->if_port = IF_PORT_UNKNOWN;
+	}
+	return 0;
+}
+
+
+#ifdef CONFIG_MIPS_BOSPORUS
+int stub_init(struct net_device *dev, int phy_addr)
+{
+	//printk("PHY stub_init\n");
+	return 0;
+}
+
+int stub_reset(struct net_device *dev, int phy_addr)
+{
+	//printk("PHY stub_reset\n");
+	return 0;
+}
+
+int 
+stub_status(struct net_device *dev, int phy_addr, u16 *link, u16 *speed)
+{
+	//printk("PHY stub_status\n");
+	*link = 1;
+	/* hmmm, revisit */
+	*speed = IF_PORT_100BASEFX;
+	dev->if_port = IF_PORT_100BASEFX;
+	return 0;
+}
+#endif
+
 struct phy_ops bcm_5201_ops = {
 	bcm_5201_init,
 	bcm_5201_reset,
 	bcm_5201_status,
 };
 
+struct phy_ops am79c874_ops = {
+	am79c874_init,
+	am79c874_reset,
+	am79c874_status,
+};
+
 struct phy_ops am79c901_ops = {
 	am79c901_init,
 	am79c901_reset,
@@ -355,26 +749,89 @@
 	lsi_80227_status,
 };
 
+struct phy_ops lxt971a_ops = { 
+	lxt971a_init,
+	lxt971a_reset,
+	lxt971a_status,
+};
+
+struct phy_ops ks8995m_ops = {
+	ks8995m_init,
+	ks8995m_reset,
+	ks8995m_status,
+};
+
+struct phy_ops smsc_83C185_ops = {
+	smsc_83C185_init,
+	smsc_83C185_reset,
+	smsc_83C185_status,
+};
+
+#ifdef CONFIG_MIPS_BOSPORUS
+struct phy_ops stub_ops = {
+	stub_init,
+	stub_reset,
+	stub_status,
+};
+#endif
+
 static struct mii_chip_info {
 	const char * name;
 	u16 phy_id0;
 	u16 phy_id1;
 	struct phy_ops *phy_ops;	
+	int dual_phy;
 } mii_chip_table[] = {
-	{"Broadcom BCM5201 10/100 BaseT PHY",  0x0040, 0x6212, &bcm_5201_ops },
-	{"AMD 79C901 HomePNA PHY",  0x0000, 0x35c8, &am79c901_ops },
-	{"LSI 80227 10/100 BaseT PHY", 0x0016, 0xf840, &lsi_80227_ops },
-	{"Broadcom BCM5221 10/100 BaseT PHY",  0x0040, 0x61e4, &bcm_5201_ops },
+	{"Broadcom BCM5201 10/100 BaseT PHY",0x0040,0x6212, &bcm_5201_ops,0},
+	{"Broadcom BCM5221 10/100 BaseT PHY",0x0040,0x61e4, &bcm_5201_ops,0},
+	{"Broadcom BCM5222 10/100 BaseT PHY",0x0040,0x6322, &bcm_5201_ops,1},
+	{"AMD 79C901 HomePNA PHY",0x0000,0x35c8, &am79c901_ops,0},
+	{"AMD 79C874 10/100 BaseT PHY",0x0022,0x561b, &am79c874_ops,0},
+	{"LSI 80227 10/100 BaseT PHY",0x0016,0xf840, &lsi_80227_ops,0},
+	{"Intel LXT971A Dual Speed PHY",0x0013,0x78e2, &lxt971a_ops,0},
+	{"Kendin KS8995M 10/100 BaseT PHY",0x0022,0x1450, &ks8995m_ops,0},
+	{"SMSC LAN83C185 10/100 BaseT PHY",0x0007,0xc0a3, &smsc_83C185_ops,0},
+#ifdef CONFIG_MIPS_BOSPORUS
+	{"Stub", 0x1234, 0x5678, &stub_ops },
+#endif
 	{0,},
 };
 
 static int mdio_read(struct net_device *dev, int phy_id, int reg)
 {
 	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	volatile u32 *mii_control_reg;
+	volatile u32 *mii_data_reg;
 	u32 timedout = 20;
 	u32 mii_control;
 
-	while (aup->mac->mii_control & MAC_MII_BUSY) {
+	#ifdef CONFIG_BCM5222_DUAL_PHY
+	/* First time we probe, it's for the mac0 phy.
+	 * Since we haven't determined yet that we have a dual phy,
+	 * aup->mii->mii_control_reg won't be setup and we'll
+	 * default to the else statement.
+	 * By the time we probe for the mac1 phy, the mii_control_reg
+	 * will be setup to be the address of the mac0 phy control since
+	 * both phys are controlled through mac0.
+	 */
+	if (aup->mii && aup->mii->mii_control_reg) {
+		mii_control_reg = aup->mii->mii_control_reg;
+		mii_data_reg = aup->mii->mii_data_reg;
+	}
+	else if (au_macs[0]->mii && au_macs[0]->mii->mii_control_reg) {
+		/* assume both phys are controlled through mac0 */
+		mii_control_reg = au_macs[0]->mii->mii_control_reg;
+		mii_data_reg = au_macs[0]->mii->mii_data_reg;
+	}
+	else 
+	#endif
+	{
+		/* default control and data reg addresses */
+		mii_control_reg = &aup->mac->mii_control;
+		mii_data_reg = &aup->mac->mii_data;
+	}
+
+	while (*mii_control_reg & MAC_MII_BUSY) {
 		mdelay(1);
 		if (--timedout == 0) {
 			printk(KERN_ERR "%s: read_MII busy timeout!!\n", 
@@ -386,10 +843,10 @@
 	mii_control = MAC_SET_MII_SELECT_REG(reg) | 
 		MAC_SET_MII_SELECT_PHY(phy_id) | MAC_MII_READ;
 
-	aup->mac->mii_control = mii_control;
+	*mii_control_reg = mii_control;
 
 	timedout = 20;
-	while (aup->mac->mii_control & MAC_MII_BUSY) {
+	while (*mii_control_reg & MAC_MII_BUSY) {
 		mdelay(1);
 		if (--timedout == 0) {
 			printk(KERN_ERR "%s: mdio_read busy timeout!!\n", 
@@ -397,16 +854,36 @@
 			return -1;
 		}
 	}
-	return (int)aup->mac->mii_data;
+	return (int)*mii_data_reg;
 }
 
 static void mdio_write(struct net_device *dev, int phy_id, int reg, u16 value)
 {
 	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	volatile u32 *mii_control_reg;
+	volatile u32 *mii_data_reg;
 	u32 timedout = 20;
 	u32 mii_control;
 
-	while (aup->mac->mii_control & MAC_MII_BUSY) {
+	#ifdef CONFIG_BCM5222_DUAL_PHY
+	if (aup->mii && aup->mii->mii_control_reg) {
+		mii_control_reg = aup->mii->mii_control_reg;
+		mii_data_reg = aup->mii->mii_data_reg;
+	}
+	else if (au_macs[0]->mii && au_macs[0]->mii->mii_control_reg) {
+		/* assume both phys are controlled through mac0 */
+		mii_control_reg = au_macs[0]->mii->mii_control_reg;
+		mii_data_reg = au_macs[0]->mii->mii_data_reg;
+	}
+	else 
+	#endif
+	{
+		/* default control and data reg addresses */
+		mii_control_reg = &aup->mac->mii_control;
+		mii_data_reg = &aup->mac->mii_data;
+	}
+
+	while (*mii_control_reg & MAC_MII_BUSY) {
 		mdelay(1);
 		if (--timedout == 0) {
 			printk(KERN_ERR "%s: mdio_write busy timeout!!\n", 
@@ -418,8 +895,8 @@
 	mii_control = MAC_SET_MII_SELECT_REG(reg) | 
 		MAC_SET_MII_SELECT_PHY(phy_id) | MAC_MII_WRITE;
 
-	aup->mac->mii_data = value;
-	aup->mac->mii_control = mii_control;
+	*mii_data_reg = value;
+	*mii_control_reg = mii_control;
 }
 
 
@@ -437,12 +914,13 @@
 	}
 }
 
-static int __init mii_probe (struct net_device * dev)
+static int mii_probe (struct net_device * dev)
 {
 	struct au1000_private *aup = (struct au1000_private *) dev->priv;
 	int phy_addr;
-
-	aup->mii = NULL;
+#ifdef CONFIG_MIPS_BOSPORUS
+	int phy_found=0;
+#endif
 
 	/* search for total of 32 possible mii phy addresses */
 	for (phy_addr = 0; phy_addr < 32; phy_addr++) {
@@ -450,9 +928,17 @@
 		u16 phy_id0, phy_id1;
 		int i;
 
+		#ifdef CONFIG_BCM5222_DUAL_PHY
+		/* Mask the already found phy, try next one */
+		if (au_macs[0]->mii && au_macs[0]->mii->mii_control_reg) {
+			if (au_macs[0]->phy_addr == phy_addr)
+				continue;
+		}
+		#endif
+
 		mii_status = mdio_read(dev, phy_addr, MII_STATUS);
 		if (mii_status == 0xffff || mii_status == 0x0000)
-			/* the mii is not accessible, try next one */
+			/* the mii is not accessable, try next one */
 			continue;
 
 		phy_id0 = mdio_read(dev, phy_addr, MII_PHY_ID0);
@@ -462,6 +948,66 @@
 		for (i = 0; mii_chip_table[i].phy_id1; i++) {
 			if (phy_id0 == mii_chip_table[i].phy_id0 &&
 			    phy_id1 == mii_chip_table[i].phy_id1) {
+				struct mii_phy * mii_phy = aup->mii;
+
+				printk(KERN_INFO "%s: %s at phy address %d\n",
+				       dev->name, mii_chip_table[i].name, 
+				       phy_addr);
+#ifdef CONFIG_MIPS_BOSPORUS
+				phy_found = 1;
+#endif
+				mii_phy->chip_info = mii_chip_table+i;
+				aup->phy_addr = phy_addr;
+				aup->want_autoneg = 1;
+				aup->phy_ops = mii_chip_table[i].phy_ops;
+				aup->phy_ops->phy_init(dev,phy_addr);
+
+				// Check for dual-phy and then store required 
+				// values and set indicators. We need to do 
+				// this now since mdio_{read,write} need the 
+				// control and data register addresses.
+				#ifdef CONFIG_BCM5222_DUAL_PHY
+				if ( mii_chip_table[i].dual_phy) {
+
+					/* assume both phys are controlled 
+					 * through MAC0. Board specific? */
+					
+					/* sanity check */
+					if (!au_macs[0] || !au_macs[0]->mii)
+						return -1;
+					aup->mii->mii_control_reg = (u32 *)
+						&au_macs[0]->mac->mii_control;
+					aup->mii->mii_data_reg = (u32 *)
+						&au_macs[0]->mac->mii_data;
+				}
+				#endif
+				goto found;
+			}
+		}
+	}
+found:
+
+#ifdef CONFIG_MIPS_BOSPORUS
+	/* This is a workaround for the Micrel/Kendin 5 port switch
+	   The second MAC doesn't see a PHY connected... so we need to
+	   trick it into thinking we have one.
+		
+	   If this kernel is run on another Au1500 development board
+	   the stub will be found as well as the actual PHY. However,
+	   the last found PHY will be used... usually at Addr 31 (Db1500).	
+	*/
+	if ( (!phy_found) )
+	{
+		u16 phy_id0, phy_id1;
+		int i;
+
+		phy_id0 = 0x1234;
+		phy_id1 = 0x5678;
+
+		/* search our mii table for the current mii */ 
+		for (i = 0; mii_chip_table[i].phy_id1; i++) {
+			if (phy_id0 == mii_chip_table[i].phy_id0 &&
+			    phy_id1 == mii_chip_table[i].phy_id1) {
 				struct mii_phy * mii_phy;
 
 				printk(KERN_INFO "%s: %s at phy address %d\n",
@@ -471,31 +1017,39 @@
 						GFP_KERNEL);
 				if (mii_phy) {
 					mii_phy->chip_info = mii_chip_table+i;
-					mii_phy->phy_addr = phy_addr;
+					aup->phy_addr = phy_addr;
 					mii_phy->next = aup->mii;
 					aup->phy_ops = 
 						mii_chip_table[i].phy_ops;
 					aup->mii = mii_phy;
 					aup->phy_ops->phy_init(dev,phy_addr);
 				} else {
-					printk(KERN_ERR "%s: out of memory\n",
+					printk(KERN_ERR "%s: out of memory\n", 
 							dev->name);
 					return -1;
 				}
-				/* the current mii is on our mii_info_table,
-				   try next address */
+				mii_phy->chip_info = mii_chip_table+i;
+				aup->phy_addr = phy_addr;
+				aup->phy_ops = mii_chip_table[i].phy_ops;
+				aup->phy_ops->phy_init(dev,phy_addr);
 				break;
 			}
 		}
 	}
+	if (aup->mac_id == 0) {
+		/* the Bosporus phy responds to addresses 0-5 but 
+		 * 5 is the correct one.
+		 */
+		aup->phy_addr = 5;
+	}
+#endif
 
-	if (aup->mii == NULL) {
-		printk(KERN_ERR "%s: No MII transceivers found!\n", dev->name);
+	if (aup->mii->chip_info == NULL) {
+		printk(KERN_ERR "%s: Au1x No MII transceivers found!\n",
+				dev->name);
 		return -1;
 	}
 
-	/* use last PHY */
-	aup->phy_addr = aup->mii->phy_addr;
 	printk(KERN_INFO "%s: Using %s as default\n", 
 			dev->name, aup->mii->chip_info->name);
 
@@ -516,7 +1070,6 @@
 	if (pDB) {
 		aup->pDBfree = pDB->pnext;
 	}
-	//printk("GetFreeDB: %x\n", pDB);
 	return pDB;
 }
 
@@ -528,35 +1081,6 @@
 	aup->pDBfree = pDB;
 }
 
-
-/*
-  DMA memory allocation, derived from pci_alloc_consistent.
-  However, the Au1000 data cache is coherent (when programmed
-  so), therefore we return KSEG0 address, not KSEG1.
-*/
-static void *dma_alloc(size_t size, dma_addr_t * dma_handle)
-{
-	void *ret;
-	int gfp = GFP_ATOMIC | GFP_DMA;
-
-	ret = (void *) __get_free_pages(gfp, get_order(size));
-
-	if (ret != NULL) {
-		memset(ret, 0, size);
-		*dma_handle = virt_to_bus(ret);
-		ret = (void *)KSEG0ADDR(ret);
-	}
-	return ret;
-}
-
-
-static void dma_free(void *vaddr, size_t size)
-{
-	vaddr = (void *)KSEG0ADDR(vaddr);
-	free_pages((unsigned long) vaddr, get_order(size));
-}
-
-
 static void enable_rx_tx(struct net_device *dev)
 {
 	struct au1000_private *aup = (struct au1000_private *) dev->priv;
@@ -582,6 +1106,7 @@
 
 static void reset_mac(struct net_device *dev)
 {
+	int i;
 	u32 flags;
 	struct au1000_private *aup = (struct au1000_private *) dev->priv;
 
@@ -590,13 +1115,32 @@
 				dev->name, (unsigned)aup);
 
 	spin_lock_irqsave(&aup->lock, flags);
-	del_timer(&aup->timer);
+	if (aup->timer.function == &au1000_timer) {/* check if timer initted */
+		del_timer(&aup->timer);
+	}
+
 	hard_stop(dev);
-	*aup->enable = MAC_EN_CLOCK_ENABLE;
-	au_sync_delay(2);
-       	*aup->enable = 0;
-	au_sync_delay(2);
+	#ifdef CONFIG_BCM5222_DUAL_PHY
+	if (aup->mac_id != 0) {
+	#endif
+		/* If BCM5222, we can't leave MAC0 in reset because then 
+		 * we can't access the dual phy for ETH1 */
+		*aup->enable = MAC_EN_CLOCK_ENABLE;
+		au_sync_delay(2);
+		*aup->enable = 0;
+		au_sync_delay(2);
+	#ifdef CONFIG_BCM5222_DUAL_PHY
+	}
+	#endif
 	aup->tx_full = 0;
+	for (i = 0; i < NUM_RX_DMA; i++) {
+		/* reset control bits */
+		aup->rx_dma_ring[i]->buff_stat &= ~0xf;
+	}
+	for (i = 0; i < NUM_TX_DMA; i++) {
+		/* reset control bits */
+		aup->tx_dma_ring[i]->buff_stat &= ~0xf;
+	}
 	spin_unlock_irqrestore(&aup->lock, flags);
 }
 
@@ -611,93 +1155,348 @@
 {
 	int i;
 
-	for (i=0; i<NUM_RX_DMA; i++) {
+	for (i = 0; i < NUM_RX_DMA; i++) {
 		aup->rx_dma_ring[i] = 
 			(volatile rx_dma_t *) (rx_base + sizeof(rx_dma_t)*i);
 	}
-	for (i=0; i<NUM_TX_DMA; i++) {
+	for (i = 0; i < NUM_TX_DMA; i++) {
 		aup->tx_dma_ring[i] = 
 			(volatile tx_dma_t *) (tx_base + sizeof(tx_dma_t)*i);
 	}
 }
 
+static struct {
+	int port;
+	u32 base_addr;
+	u32 macen_addr;
+	int irq;
+	struct net_device *dev;
+} iflist[2];
+
+static int num_ifs;
+
+/*
+ * Setup the base address and interupt of the Au1xxx ethernet macs
+ * based on cpu type and whether the interface is enabled in sys_pinfunc
+ * register. The last interface is enabled if SYS_PF_NI2 (bit 4) is 0.
+ */
 static int __init au1000_init_module(void)
 {
-	int i;
-	int prid;
-	int base_addr, irq;
+	struct cpuinfo_mips *c = &current_cpu_data;
+	int ni = (int)((au_readl(SYS_PINFUNC) & (u32)(SYS_PF_NI2)) >> 4);
+	struct net_device *dev;
+	int i, found_one = 0;
 
-	prid = read_c0_prid();
-	for (i=0; i<NUM_INTERFACES; i++) {
-		if ( (prid & 0xffff0000) == 0x00030000 ) {
-			base_addr = au1000_iflist[i].port;
-			irq = au1000_iflist[i].irq;
-		} else if ( (prid & 0xffff0000) == 0x01030000 ) {
-			base_addr = au1500_iflist[i].port;
-			irq = au1500_iflist[i].irq;
-		} else if ( (prid & 0xffff0000) == 0x02030000 ) {
-			base_addr = au1100_iflist[i].port;
-			irq = au1100_iflist[i].irq;
+	switch (c->cputype) {
+#ifdef CONFIG_SOC_AU1000
+	case CPU_AU1000:
+		num_ifs = 2 - ni;
+		iflist[0].base_addr = AU1000_ETH0_BASE;
+		iflist[1].base_addr = AU1000_ETH1_BASE;
+		iflist[0].macen_addr = AU1000_MAC0_ENABLE;
+		iflist[1].macen_addr = AU1000_MAC1_ENABLE;
+		iflist[0].irq = AU1000_MAC0_DMA_INT;
+		iflist[1].irq = AU1000_MAC1_DMA_INT;
+		break;
+#endif
+#ifdef CONFIG_SOC_AU1100
+	case CPU_AU1100:
+		num_ifs = 1 - ni;
+		iflist[0].base_addr = AU1100_ETH0_BASE;
+		iflist[0].macen_addr = AU1100_MAC0_ENABLE;
+		iflist[0].irq = AU1100_MAC0_DMA_INT;
+		break;
+#endif
+#ifdef CONFIG_SOC_AU1500
+	case CPU_AU1500:
+		num_ifs = 2 - ni;
+		iflist[0].base_addr = AU1500_ETH0_BASE;
+		iflist[1].base_addr = AU1500_ETH1_BASE;
+		iflist[0].macen_addr = AU1500_MAC0_ENABLE;
+		iflist[1].macen_addr = AU1500_MAC1_ENABLE;
+		iflist[0].irq = AU1500_MAC0_DMA_INT;
+		iflist[1].irq = AU1500_MAC1_DMA_INT;
+		break;
+#endif
+#ifdef CONFIG_SOC_AU1550
+	case CPU_AU1550:
+		num_ifs = 2 - ni;
+		iflist[0].base_addr = AU1550_ETH0_BASE;
+		iflist[1].base_addr = AU1550_ETH1_BASE;
+		iflist[0].macen_addr = AU1550_MAC0_ENABLE;
+		iflist[1].macen_addr = AU1550_MAC1_ENABLE;
+		iflist[0].irq = AU1550_MAC0_DMA_INT;
+		iflist[1].irq = AU1550_MAC1_DMA_INT;
+		break;
+#endif
+	default:
+		num_ifs = 0;
+	}
+	for(i = 0; i < num_ifs; i++) {
+		dev = au1000_probe(iflist[i].base_addr, iflist[i].irq, i);
+		iflist[i].dev = dev;
+		if (dev)
+			found_one++;
+	}
+	if (!found_one)
+		return -ENODEV;
+	return 0;
+}
+
+static int au1000_setup_aneg(struct net_device *dev, u32 advertise)
+{
+	struct au1000_private *aup = (struct au1000_private *)dev->priv;
+	u16 ctl, adv;
+
+	/* Setup standard advertise */
+	adv = mdio_read(dev, aup->phy_addr, MII_ADVERTISE);
+	adv &= ~(ADVERTISE_ALL | ADVERTISE_100BASE4);
+	if (advertise & ADVERTISED_10baseT_Half)
+		adv |= ADVERTISE_10HALF;
+	if (advertise & ADVERTISED_10baseT_Full)
+		adv |= ADVERTISE_10FULL;
+	if (advertise & ADVERTISED_100baseT_Half)
+		adv |= ADVERTISE_100HALF;
+	if (advertise & ADVERTISED_100baseT_Full)
+		adv |= ADVERTISE_100FULL;
+	mdio_write(dev, aup->phy_addr, MII_ADVERTISE, adv);
+
+	/* Start/Restart aneg */
+	ctl = mdio_read(dev, aup->phy_addr, MII_BMCR);
+	ctl |= (BMCR_ANENABLE | BMCR_ANRESTART);
+	mdio_write(dev, aup->phy_addr, MII_BMCR, ctl);
+
+	return 0;
+}
+
+static int au1000_setup_forced(struct net_device *dev, int speed, int fd)
+{
+	struct au1000_private *aup = (struct au1000_private *)dev->priv;
+	u16 ctl;
+
+	ctl = mdio_read(dev, aup->phy_addr, MII_BMCR);
+	ctl &= ~(BMCR_FULLDPLX | BMCR_SPEED100 | BMCR_ANENABLE);
+
+	/* First reset the PHY */
+	mdio_write(dev, aup->phy_addr, MII_BMCR, ctl | BMCR_RESET);
+
+	/* Select speed & duplex */
+	switch (speed) {
+		case SPEED_10:
+			break;
+		case SPEED_100:
+			ctl |= BMCR_SPEED100;
+			break;
+		case SPEED_1000:
+		default:
+			return -EINVAL;
+	}
+	if (fd == DUPLEX_FULL)
+		ctl |= BMCR_FULLDPLX;
+	mdio_write(dev, aup->phy_addr, MII_BMCR, ctl);
+
+	return 0;
+}
+
+
+static void
+au1000_start_link(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct au1000_private *aup = (struct au1000_private *)dev->priv;
+	u32 advertise;
+	int autoneg;
+	int forced_speed;
+	int forced_duplex;
+
+	/* Default advertise */
+	advertise = GENMII_DEFAULT_ADVERTISE;
+	autoneg = aup->want_autoneg;
+	forced_speed = SPEED_100;
+	forced_duplex = DUPLEX_FULL;
+
+	/* Setup link parameters */
+	if (cmd) {
+		if (cmd->autoneg == AUTONEG_ENABLE) {
+			advertise = cmd->advertising;
+			autoneg = 1;
 		} else {
-			printk(KERN_ERR "au1000 eth: unknown Processor ID\n");
-			return -ENODEV;
-		}
-		// check for valid entries, au1100 only has one entry
-		if (base_addr && irq) {
-			if (au1000_probe1(base_addr, irq, i) != 0)
-				return -ENODEV;
+			autoneg = 0;
+
+			forced_speed = cmd->speed;
+			forced_duplex = cmd->duplex;
 		}
 	}
+
+	/* Configure PHY & start aneg */
+	aup->want_autoneg = autoneg;
+	if (autoneg)
+		au1000_setup_aneg(dev, advertise);
+	else
+		au1000_setup_forced(dev, forced_speed, forced_duplex);
+	mod_timer(&aup->timer, jiffies + HZ);
+}
+
+static int au1000_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct au1000_private *aup = (struct au1000_private *)dev->priv;
+	u16 link, speed;
+
+	cmd->supported = GENMII_DEFAULT_FEATURES;
+	cmd->advertising = GENMII_DEFAULT_ADVERTISE;
+	cmd->port = PORT_MII;
+	cmd->transceiver = XCVR_EXTERNAL;
+	cmd->phy_address = aup->phy_addr;
+	spin_lock_irq(&aup->lock);
+	cmd->autoneg = aup->want_autoneg;
+	aup->phy_ops->phy_status(dev, aup->phy_addr, &link, &speed);
+	if ((speed == IF_PORT_100BASETX) || (speed == IF_PORT_100BASEFX))
+		cmd->speed = SPEED_100;
+	else if (speed == IF_PORT_10BASET)
+		cmd->speed = SPEED_10;
+	if (link && (dev->if_port == IF_PORT_100BASEFX))
+		cmd->duplex = DUPLEX_FULL;
+	else
+		cmd->duplex = DUPLEX_HALF;
+	spin_unlock_irq(&aup->lock);
 	return 0;
 }
 
-static int __init
-au1000_probe1(long ioaddr, int irq, int port_num)
+static int au1000_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	 struct au1000_private *aup = (struct au1000_private *)dev->priv;
+	  unsigned long features = GENMII_DEFAULT_FEATURES;
+
+	 if (!capable(CAP_NET_ADMIN))
+		 return -EPERM;
+
+	 if (cmd->autoneg != AUTONEG_ENABLE && cmd->autoneg != AUTONEG_DISABLE)
+		 return -EINVAL;
+	 if (cmd->autoneg == AUTONEG_ENABLE && cmd->advertising == 0)
+		 return -EINVAL;
+	 if (cmd->duplex != DUPLEX_HALF && cmd->duplex != DUPLEX_FULL)
+		 return -EINVAL;
+	 if (cmd->autoneg == AUTONEG_DISABLE)
+		 switch (cmd->speed) {
+		 case SPEED_10:
+			 if (cmd->duplex == DUPLEX_HALF &&
+				 (features & SUPPORTED_10baseT_Half) == 0)
+				 return -EINVAL;
+			 if (cmd->duplex == DUPLEX_FULL &&
+				 (features & SUPPORTED_10baseT_Full) == 0)
+				 return -EINVAL;
+			 break;
+		 case SPEED_100:
+			 if (cmd->duplex == DUPLEX_HALF &&
+				 (features & SUPPORTED_100baseT_Half) == 0)
+				 return -EINVAL;
+			 if (cmd->duplex == DUPLEX_FULL &&
+				 (features & SUPPORTED_100baseT_Full) == 0)
+				 return -EINVAL;
+			 break;
+		 default:
+			 return -EINVAL;
+		 }
+	 else if ((features & SUPPORTED_Autoneg) == 0)
+		 return -EINVAL;
+
+	 spin_lock_irq(&aup->lock);
+	 au1000_start_link(dev, cmd);
+	 spin_unlock_irq(&aup->lock);
+	 return 0;
+}
+
+static int au1000_nway_reset(struct net_device *dev)
+{
+	struct au1000_private *aup = (struct au1000_private *)dev->priv;
+
+	if (!aup->want_autoneg)
+		return -EINVAL;
+	spin_lock_irq(&aup->lock);
+	au1000_start_link(dev, NULL);
+	spin_unlock_irq(&aup->lock);
+	return 0;
+}
+
+static void
+au1000_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
+{
+	struct au1000_private *aup = (struct au1000_private *)dev->priv;
+
+	strcpy(info->driver, DRV_NAME);
+	strcpy(info->version, DRV_VERSION);
+	info->fw_version[0] = '\0';
+	sprintf(info->bus_info, "%s %d", DRV_NAME, aup->mac_id);
+	info->regdump_len = 0;
+}
+
+static u32 au1000_get_link(struct net_device *dev)
+{
+	return netif_carrier_ok(dev);
+}
+
+static struct ethtool_ops au1000_ethtool_ops = {
+	.get_settings = au1000_get_settings,
+	.set_settings = au1000_set_settings,
+	.get_drvinfo = au1000_get_drvinfo,
+	.nway_reset = au1000_nway_reset,
+	.get_link = au1000_get_link
+};
+
+static struct net_device *
+au1000_probe(u32 ioaddr, int irq, int port_num)
 {
-	struct net_device *dev;
 	static unsigned version_printed = 0;
 	struct au1000_private *aup = NULL;
-	int i, retval = 0;
+	struct net_device *dev = NULL;
 	db_dest_t *pDB, *pDBfree;
 	char *pmac, *argptr;
 	char ethaddr[6];
+	int i, err;
 
-	if (!request_region(PHYSADDR(ioaddr), MAC_IOSIZE, "Au1000 ENET"))
-		 return -ENODEV;
+	if (!request_mem_region(CPHYSADDR(ioaddr), MAC_IOSIZE, "Au1x00 ENET"))
+		return NULL;
 
-	if (version_printed++ == 0)
-		printk(version);
-
-	retval = -ENOMEM;
+	if (version_printed++ == 0) 
+		printk("%s version %s %s\n", DRV_NAME, DRV_VERSION, DRV_AUTHOR);
 
 	dev = alloc_etherdev(sizeof(struct au1000_private));
 	if (!dev) {
 		printk (KERN_ERR "au1000 eth: alloc_etherdev failed\n");  
-		goto out;
+		return NULL;
 	}
 
-	SET_MODULE_OWNER(dev);
+	if ((err = register_netdev(dev))) {
+		printk(KERN_ERR "Au1x_eth Cannot register net device err %d\n",
+				err);
+		free_netdev(dev);
+		return NULL;
+	}
 
-	printk("%s: Au1xxx ethernet found at 0x%lx, irq %d\n", 
-	       dev->name, ioaddr, irq);
+	printk("%s: Au1x Ethernet found at 0x%x, irq %d\n", 
+			dev->name, ioaddr, irq);
 
 	aup = dev->priv;
 
 	/* Allocate the data buffers */
-	aup->vaddr = (u32)dma_alloc(MAX_BUF_SIZE * 
-			(NUM_TX_BUFFS+NUM_RX_BUFFS), &aup->dma_addr);
-	if (!aup->vaddr)
-		goto out1;
+	/* Snooping works fine with eth on all au1xxx */
+	aup->vaddr = (u32)dma_alloc_noncoherent(NULL,
+			MAX_BUF_SIZE * (NUM_TX_BUFFS+NUM_RX_BUFFS),
+			&aup->dma_addr,
+			0);
+	if (!aup->vaddr) {
+		free_netdev(dev);
+		release_mem_region(CPHYSADDR(ioaddr), MAC_IOSIZE);
+		return NULL;
+	}
 
 	/* aup->mac is the base address of the MAC's registers */
 	aup->mac = (volatile mac_reg_t *)((unsigned long)ioaddr);
 	/* Setup some variables for quick register address access */
-	switch (ioaddr) {
-	case AU1000_ETH0_BASE:
-	case AU1500_ETH0_BASE:
+	if (ioaddr == iflist[0].base_addr)
+	{
 		/* check env variables first */
 		if (!get_ethernet_addr(ethaddr)) { 
-			memcpy(au1000_mac_addr, ethaddr, sizeof(dev->dev_addr));
+			memcpy(au1000_mac_addr, ethaddr, sizeof(au1000_mac_addr));
 		} else {
 			/* Check command line */
 			argptr = prom_getcmdline();
@@ -708,38 +1507,32 @@
 			} else {
 				str2eaddr(ethaddr, pmac + strlen("ethaddr="));
 				memcpy(au1000_mac_addr, ethaddr, 
-						sizeof(dev->dev_addr));
+						sizeof(au1000_mac_addr));
 			}
 		}
-		if (ioaddr == AU1000_ETH0_BASE)
-			aup->enable = (volatile u32 *) 
-				((unsigned long)AU1000_MAC0_ENABLE);
-		else
 			aup->enable = (volatile u32 *) 
-				((unsigned long)AU1500_MAC0_ENABLE);
-		memcpy(dev->dev_addr, au1000_mac_addr, sizeof(dev->dev_addr));
+				((unsigned long)iflist[0].macen_addr);
+		memcpy(dev->dev_addr, au1000_mac_addr, sizeof(au1000_mac_addr));
 		setup_hw_rings(aup, MAC0_RX_DMA_ADDR, MAC0_TX_DMA_ADDR);
-			break;
-	case AU1000_ETH1_BASE:
-	case AU1500_ETH1_BASE:
-		if (ioaddr == AU1000_ETH1_BASE)
-			aup->enable = (volatile u32 *) 
-				((unsigned long)AU1000_MAC1_ENABLE);
+		aup->mac_id = 0;
+		au_macs[0] = aup;
+	}
 		else
+	if (ioaddr == iflist[1].base_addr)
+	{
 			aup->enable = (volatile u32 *) 
-				((unsigned long)AU1500_MAC1_ENABLE);
-		memcpy(dev->dev_addr, au1000_mac_addr, sizeof(dev->dev_addr));
+				((unsigned long)iflist[1].macen_addr);
+		memcpy(dev->dev_addr, au1000_mac_addr, sizeof(au1000_mac_addr));
 		dev->dev_addr[4] += 0x10;
 		setup_hw_rings(aup, MAC1_RX_DMA_ADDR, MAC1_TX_DMA_ADDR);
-			break;
-	default:
+		aup->mac_id = 1;
+		au_macs[1] = aup;
+	}
+	else
+	{
 		printk(KERN_ERR "%s: bad ioaddr\n", dev->name);
-		break;
-
 	}
 
-	aup->phy_addr = PHY_ADDRESS;
-
 	/* bring the device out of reset, otherwise probing the mii
 	 * will hang */
 	*aup->enable = MAC_EN_CLOCK_ENABLE;
@@ -748,15 +1541,22 @@
 		MAC_EN_RESET2 | MAC_EN_CLOCK_ENABLE;
 	au_sync_delay(2);
 
-	retval = mii_probe(dev);
-	if (retval)
-		 goto out2;
+	aup->mii = kmalloc(sizeof(struct mii_phy), GFP_KERNEL);
+	if (!aup->mii) {
+		printk(KERN_ERR "%s: out of memory\n", dev->name);
+		goto err_out;
+	}
+	aup->mii->mii_control_reg = 0;
+	aup->mii->mii_data_reg = 0;
+
+	if (mii_probe(dev) != 0) {
+		goto err_out;
+	}
 
-	retval = -EINVAL;
 	pDBfree = NULL;
 	/* setup the data buffer descriptors and attach a buffer to each one */
 	pDB = aup->db;
-	for (i=0; i<(NUM_TX_BUFFS+NUM_RX_BUFFS); i++) {
+	for (i = 0; i < (NUM_TX_BUFFS+NUM_RX_BUFFS); i++) {
 		pDB->pnext = pDBfree;
 		pDBfree = pDB;
 		pDB->vaddr = (u32 *)((unsigned)aup->vaddr + MAX_BUF_SIZE*i);
@@ -765,15 +1565,19 @@
 	}
 	aup->pDBfree = pDBfree;
 
-	for (i=0; i<NUM_RX_DMA; i++) {
+	for (i = 0; i < NUM_RX_DMA; i++) {
 		pDB = GetFreeDB(aup);
-		if (!pDB) goto out2;
+		if (!pDB) {
+			goto err_out;
+		}
 		aup->rx_dma_ring[i]->buff_stat = (unsigned)pDB->dma_addr;
 		aup->rx_db_inuse[i] = pDB;
 	}
-	for (i=0; i<NUM_TX_DMA; i++) {
+	for (i = 0; i < NUM_TX_DMA; i++) {
 		pDB = GetFreeDB(aup);
-		if (!pDB) goto out2;
+		if (!pDB) {
+			goto err_out;
+		}
 		aup->tx_dma_ring[i]->buff_stat = (unsigned)pDB->dma_addr;
 		aup->tx_dma_ring[i]->len = 0;
 		aup->tx_db_inuse[i] = pDB;
@@ -788,6 +1592,7 @@
 	dev->get_stats = au1000_get_stats;
 	dev->set_multicast_list = &set_rx_mode;
 	dev->do_ioctl = &au1000_ioctl;
+	SET_ETHTOOL_OPS(dev, &au1000_ethtool_ops);
 	dev->set_config = &au1000_set_config;
 	dev->tx_timeout = au1000_tx_timeout;
 	dev->watchdog_timeo = ETH_TX_TIMEOUT;
@@ -798,23 +1603,32 @@
 	 */
 	reset_mac(dev);
 
-	retval = register_netdev(dev);
-	if (retval)
-		goto out2;
-	return 0;
+	return dev;
 
-out2:
-	dma_free(aup->vaddr, MAX_BUF_SIZE * (NUM_TX_BUFFS+NUM_RX_BUFFS));
-out1:
+err_out:
+	/* here we should have a valid dev plus aup-> register addresses
+	 * so we can reset the mac properly.*/
+	reset_mac(dev);
+	if (aup->mii)
+		kfree(aup->mii);
+	for (i = 0; i < NUM_RX_DMA; i++) {
+		if (aup->rx_db_inuse[i])
+			ReleaseDB(aup, aup->rx_db_inuse[i]);
+	}
+	for (i = 0; i < NUM_TX_DMA; i++) {
+		if (aup->tx_db_inuse[i])
+			ReleaseDB(aup, aup->tx_db_inuse[i]);
+	}
+	dma_free_noncoherent(NULL,
+			MAX_BUF_SIZE * (NUM_TX_BUFFS+NUM_RX_BUFFS),
+			(void *)aup->vaddr,
+			aup->dma_addr);
+	unregister_netdev(dev);
 	free_netdev(dev);
-out:
-	release_region(PHYSADDR(ioaddr), MAC_IOSIZE);
-	printk(KERN_ERR "%s: au1000_probe1 failed.  Returns %d\n",
-	       dev->name, retval);
-	return retval;
+	release_mem_region(CPHYSADDR(ioaddr), MAC_IOSIZE);
+	return NULL;
 }
 
-
 /* 
  * Initialize the interface.
  *
@@ -832,7 +1646,8 @@
 	u32 control;
 	u16 link, speed;
 
-	if (au1000_debug > 4) printk("%s: au1000_init\n", dev->name);
+	if (au1000_debug > 4) 
+		printk("%s: au1000_init\n", dev->name);
 
 	spin_lock_irqsave(&aup->lock, flags);
 
@@ -852,7 +1667,7 @@
 	aup->mac->mac_addr_low = dev->dev_addr[3]<<24 | dev->dev_addr[2]<<16 |
 		dev->dev_addr[1]<<8 | dev->dev_addr[0];
 
-	for (i=0; i<NUM_RX_DMA; i++) {
+	for (i = 0; i < NUM_RX_DMA; i++) {
 		aup->rx_dma_ring[i]->buff_stat |= RX_DMA_ENABLE;
 	}
 	au_sync();
@@ -865,7 +1680,13 @@
 	if (link && (dev->if_port == IF_PORT_100BASEFX)) {
 		control |= MAC_FULL_DUPLEX;
 	}
+
+	/* fix for startup without cable */
+	if (!link) 
+		dev->flags &= ~IFF_RUNNING;
+
 	aup->mac->control = control;
+	aup->mac->vlan1_tag = 0x8100; /* activate vlan support */
 	au_sync();
 
 	spin_unlock_irqrestore(&aup->lock, flags);
@@ -949,6 +1770,7 @@
 		return retval;
 	}
 
+	init_timer(&aup->timer); /* used in ioctl() */
 	aup->timer.expires = RUN_AT((3*HZ)); 
 	aup->timer.data = (unsigned long)dev;
 	aup->timer.function = &au1000_timer; /* timer handler */
@@ -968,22 +1790,49 @@
 	if (au1000_debug > 4)
 		printk("%s: close: dev=%p\n", dev->name, dev);
 
+	reset_mac(dev);
+
 	spin_lock_irqsave(&aup->lock, flags);
 	
 	/* stop the device */
-	if (netif_device_present(dev))
-		netif_stop_queue(dev);
+	netif_stop_queue(dev);
 
 	/* disable the interrupt */
 	free_irq(dev->irq, dev);
 	spin_unlock_irqrestore(&aup->lock, flags);
 
-	reset_mac(dev);
 	return 0;
 }
 
 static void __exit au1000_cleanup_module(void)
 {
+	int i, j;
+	struct net_device *dev;
+	struct au1000_private *aup;
+
+	for (i = 0; i < num_ifs; i++) {
+		dev = iflist[i].dev;
+		if (dev) {
+			aup = (struct au1000_private *) dev->priv;
+			unregister_netdev(dev);
+			if (aup->mii)
+				kfree(aup->mii);
+			for (j = 0; j < NUM_RX_DMA; j++) {
+				if (aup->rx_db_inuse[j])
+					ReleaseDB(aup, aup->rx_db_inuse[j]);
+			}
+			for (j = 0; j < NUM_TX_DMA; j++) {
+				if (aup->tx_db_inuse[j])
+					ReleaseDB(aup, aup->tx_db_inuse[j]);
+			}
+			dma_free_noncoherent(NULL,
+					MAX_BUF_SIZE * (NUM_TX_BUFFS+NUM_RX_BUFFS),
+					(void *)aup->vaddr,
+					aup->dma_addr);
+			free_netdev(dev);
+			release_mem_region(CPHYSADDR(iflist[i].base_addr), MAC_IOSIZE);
+		}
+	}
 }
 
 
@@ -1028,9 +1877,8 @@
 	ptxd = aup->tx_dma_ring[aup->tx_tail];
 
 	while (ptxd->buff_stat & TX_T_DONE) {
- 		update_tx_stats(dev, ptxd->status, aup->tx_len[aup->tx_tail]  & 0x3ff);
+		update_tx_stats(dev, ptxd->status, ptxd->len & 0x3ff);
 		ptxd->buff_stat &= ~TX_T_DONE;
- 		aup->tx_len[aup->tx_tail] = 0;
 		ptxd->len = 0;
 		au_sync();
 
@@ -1056,7 +1904,7 @@
 	db_dest_t *pDB;
 	int i;
 
-	if (au1000_debug > 4)
+	if (au1000_debug > 5)
 		printk("%s: tx: aup %x len=%d, data=%p, head %d\n", 
 				dev->name, (unsigned)aup, skb->len, 
 				skb->data, aup->tx_head);
@@ -1070,8 +1918,7 @@
 		return 1;
 	}
 	else if (buff_stat & TX_T_DONE) {
- 		update_tx_stats(dev, ptxd->status, aup->tx_len[aup->tx_head] & 0x3ff);
- 		aup->tx_len[aup->tx_head] = 0;
+		update_tx_stats(dev, ptxd->status, ptxd->len & 0x3ff);
 		ptxd->len = 0;
 	}
 
@@ -1082,17 +1929,15 @@
 
 	pDB = aup->tx_db_inuse[aup->tx_head];
 	memcpy((void *)pDB->vaddr, skb->data, skb->len);
-	if (skb->len < MAC_MIN_PKT_SIZE) {
-		for (i=skb->len; i<MAC_MIN_PKT_SIZE; i++) { 
+	if (skb->len < ETH_ZLEN) {
+		for (i=skb->len; i<ETH_ZLEN; i++) { 
 			((char *)pDB->vaddr)[i] = 0;
 		}
- 		aup->tx_len[aup->tx_head] = MAC_MIN_PKT_SIZE;
-		ptxd->len = MAC_MIN_PKT_SIZE;
+		ptxd->len = ETH_ZLEN;
 	}
-	else {
- 		aup->tx_len[aup->tx_head] = skb->len;
+	else
 		ptxd->len = skb->len;
-	}
+
 	ptxd->buff_stat = pDB->dma_addr | TX_DMA_ENABLE;
 	au_sync();
 	dev_kfree_skb(skb);
@@ -1137,8 +1982,9 @@
 	volatile rx_dma_t *prxd;
 	u32 buff_stat, status;
 	db_dest_t *pDB;
+	u32	frmlen;
 
-	if (au1000_debug > 4)
+	if (au1000_debug > 5)
 		printk("%s: au1000_rx head %d\n", dev->name, aup->rx_head);
 
 	prxd = aup->rx_dma_ring[aup->rx_head];
@@ -1150,7 +1996,9 @@
 		if (!(status & RX_ERROR))  {
 
 			/* good frame */
-			skb = dev_alloc_skb((status & RX_FRAME_LEN_MASK) + 2);
+			frmlen = (status & RX_FRAME_LEN_MASK);
+			frmlen -= 4; /* Remove FCS */
+			skb = dev_alloc_skb(frmlen + 2);
 			if (skb == NULL) {
 				printk(KERN_ERR
 				       "%s: Memory squeeze, dropping packet.\n",
@@ -1160,9 +2008,9 @@
 			}
 			skb->dev = dev;
 			skb_reserve(skb, 2);	/* 16 byte IP header align */
-			eth_copy_and_sum(skb, (unsigned char *)pDB->vaddr, 
-					status & RX_FRAME_LEN_MASK, 0);
-			skb_put(skb, status & RX_FRAME_LEN_MASK);
+			eth_copy_and_sum(skb,
+				(unsigned char *)pDB->vaddr, frmlen, 0);
+			skb_put(skb, frmlen);
 			skb->protocol = eth_type_trans(skb, dev);
 			netif_rx(skb);	/* pass the packet to upper layers */
 		}
@@ -1206,17 +2054,20 @@
 /*
  * Au1000 interrupt service routine.
  */
-irqreturn_t au1000_interrupt(int irq, void *dev_id, struct pt_regs *regs)
+static irqreturn_t au1000_interrupt(int irq, void *dev_id, struct pt_regs *regs)
 {
 	struct net_device *dev = (struct net_device *) dev_id;
 
 	if (dev == NULL) {
 		printk(KERN_ERR "%s: isr: null dev ptr\n", dev->name);
-		return IRQ_NONE;
+		return IRQ_RETVAL(1);
 	}
-	au1000_tx_ack(dev);
+
+	/* Handle RX interrupts first to minimize chance of overrun */
+
 	au1000_rx(dev);
-	return IRQ_HANDLED;
+	au1000_tx_ack(dev);
+	return IRQ_RETVAL(1);
 }
 
 
@@ -1233,6 +2084,23 @@
 	netif_wake_queue(dev);
 }
 
+
+static unsigned const ethernet_polynomial = 0x04c11db7U;
+static inline u32 ether_crc(int length, unsigned char *data)
+{
+    int crc = -1;
+
+    while(--length >= 0) {
+		unsigned char current_octet = *data++;
+		int bit;
+		for (bit = 0; bit < 8; bit++, current_octet >>= 1)
+			crc = (crc << 1) ^
+				((crc < 0) ^ (current_octet & 1) ? 
+				 ethernet_polynomial : 0);
+    }
+    return crc;
+}
+
 static void set_rx_mode(struct net_device *dev)
 {
 	struct au1000_private *aup = (struct au1000_private *) dev->priv;
@@ -1256,8 +2124,8 @@
 		mc_filter[1] = mc_filter[0] = 0;
 		for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
 			 i++, mclist = mclist->next) {
-			set_bit(ether_crc_le(ETH_ALEN, mclist->dmi_addr)>>26, 
-					mc_filter);
+			set_bit(ether_crc(ETH_ALEN, mclist->dmi_addr)>>26, 
+					(long *)mc_filter);
 		}
 		aup->mac->multi_hash_high = mc_filter[1];
 		aup->mac->multi_hash_low = mc_filter[0];
@@ -1269,28 +2137,28 @@
 
 static int au1000_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
+	struct au1000_private *aup = (struct au1000_private *)dev->priv;
 	u16 *data = (u16 *)&rq->ifr_ifru;
 
-	/* fixme */
 	switch(cmd) { 
-	case SIOCGMIIPHY:	/* Get the address of the PHY in use. */
-		data[0] = PHY_ADDRESS;
-		return 0;
-
-	case SIOCGMIIREG:	/* Read the specified MII register. */
-		//data[3] = mdio_read(ioaddr, data[0], data[1]); 
-		return 0;
-
-	case SIOCSMIIREG:	/* Write the specified MII register */
-		if (!capable(CAP_NET_ADMIN))
-			return -EPERM;
-
-		//mdio_write(ioaddr, data[0], data[1], data[2]);
-		return 0;
-
-	default:
-		return -EOPNOTSUPP;
+		case SIOCDEVPRIVATE:	/* Get the address of the PHY in use. */
+		case SIOCGMIIPHY:
+		        if (!netif_running(dev)) return -EINVAL;
+			data[0] = aup->phy_addr;
+		case SIOCDEVPRIVATE+1:	/* Read the specified MII register. */
+		case SIOCGMIIREG:
+			data[3] =  mdio_read(dev, data[0], data[1]); 
+			return 0;
+		case SIOCDEVPRIVATE+2:	/* Write the specified MII register */
+		case SIOCSMIIREG: 
+			if (!capable(CAP_NET_ADMIN))
+				return -EPERM;
+			mdio_write(dev, data[0], data[1],data[2]);
+			return 0;
+		default:
+			return -EOPNOTSUPP;
 	}
+
 }
 
 
@@ -1352,7 +2220,6 @@
 			/* set Speed to 100Mbps, Half Duplex */
 			/* disable auto negotiation and enable 100MBit Mode */
 			control = mdio_read(dev, aup->phy_addr, MII_CONTROL);
-			printk("read control %x\n", control);
 			control &= ~(MII_CNTL_AUTO | MII_CNTL_FDX);
 			control |= MII_CNTL_F100;
 			mdio_write(dev, aup->phy_addr, MII_CONTROL, control);
diff -Nru a/drivers/net/au1000_eth.h b/drivers/net/au1000_eth.h
--- a/drivers/net/au1000_eth.h	2005-03-06 18:36:50 -05:00
+++ b/drivers/net/au1000_eth.h	2005-03-06 18:36:50 -05:00
@@ -1,10 +1,13 @@
 /*
- * Alchemy Semi Au1000 ethernet driver include file
+ *
+ * Alchemy Au1x00 ethernet driver include file
  *
  * Author: Pete Popov <ppopov@mvista.com>
  *
  * Copyright 2001 MontaVista Software Inc.
  *
+ * ########################################################################
+ *
  *  This program is free software; you can distribute it and/or modify it
  *  under the terms of the GNU General Public License (Version 2) as
  *  published by the Free Software Foundation.
@@ -17,14 +20,16 @@
  *  You should have received a copy of the GNU General Public License along
  *  with this program; if not, write to the Free Software Foundation, Inc.,
  *  59 Temple Place - Suite 330, Boston MA 02111-1307, USA.
+ *
+ * ########################################################################
+ *
+ * 
  */
-#include <linux/config.h>
 
 
-#define NUM_INTERFACES 2
 #define MAC_IOSIZE 0x10000
-#define NUM_RX_DMA 4       /* Au1000 has 4 rx hardware descriptors */
-#define NUM_TX_DMA 4       /* Au1000 has 4 tx hardware descriptors */
+#define NUM_RX_DMA 4       /* Au1x00 has 4 rx hardware descriptors */
+#define NUM_TX_DMA 4       /* Au1x00 has 4 tx hardware descriptors */
 
 #define NUM_RX_BUFFS 4
 #define NUM_TX_BUFFS 4
@@ -33,12 +38,6 @@
 #define ETH_TX_TIMEOUT HZ/4
 #define MAC_MIN_PKT_SIZE 64
 
-#if defined(CONFIG_MIPS_PB1000) || defined(CONFIG_MIPS_PB1500) || defined(CONFIG_MIPS_PB1100)
-#define PHY_ADDRESS              0
-#define PHY_CONTROL_DEFAULT 0x3000
-#define PHY_CONTROL_REG_ADDR     0
-#endif
-
 #define MULTICAST_FILTER_LIMIT 64
 
 /* FIXME 
@@ -54,11 +53,13 @@
 #define MII_ANLPAR  0x0005
 #define MII_AEXP    0x0006
 #define MII_ANEXT   0x0007
-#define MII_LSI_CONFIG 0x0011
-#define MII_LSI_STAT   0x0012
-#define MII_AUX_CNTRL  0x0018
-#define MII_INT        0x001A
+#define MII_LSI_PHY_CONFIG 0x0011
+/* Status register */
+#define MII_LSI_PHY_STAT   0x0012
+#define MII_AMD_PHY_STAT   MII_LSI_PHY_STAT
+#define MII_INTEL_PHY_STAT 0x0011
 
+#define MII_AUX_CNTRL  0x0018
 /* mii registers specific to AMD 79C901 */
 #define	MII_STATUS_SUMMARY = 0x0018
 
@@ -121,23 +122,30 @@
 #define	MII_STSSUM_AUTO  0x0002
 #define MII_STSSUM_SPD   0x0001
 
-/* lsi status register */
-
-#define MII_LSI_STAT_FDX	0x0040
-#define MII_LSI_STAT_SPD	0x0080
+/* lsi phy status register */
+#define MII_LSI_PHY_STAT_FDX	0x0040
+#define MII_LSI_PHY_STAT_SPD	0x0080
+
+/* amd phy status register */
+#define MII_AMD_PHY_STAT_FDX	0x0800
+#define MII_AMD_PHY_STAT_SPD	0x0400
+
+/* intel phy status register */
+#define MII_INTEL_PHY_STAT_FDX	0x0200
+#define MII_INTEL_PHY_STAT_SPD	0x4000
 
 /* Auxilliary Control/Status Register */
 #define MII_AUX_FDX      0x0001
 #define MII_AUX_100      0x0002
 #define MII_AUX_F100     0x0004
 #define MII_AUX_ANEG     0x0008
-#define MII_FDX_LED	 0x8000
 
 typedef struct mii_phy {
 	struct mii_phy * next;
 	struct mii_chip_info * chip_info;
-	int phy_addr;
 	u16 status;
+	u32 *mii_control_reg;
+	u32 *mii_data_reg;
 } mii_phy_t;
 
 struct phy_ops {
@@ -197,7 +205,6 @@
 	db_dest_t db[NUM_RX_BUFFS+NUM_TX_BUFFS];
 	volatile rx_dma_t *rx_dma_ring[NUM_RX_DMA];
 	volatile tx_dma_t *tx_dma_ring[NUM_TX_DMA];
-	int tx_len[NUM_TX_DMA];
 	db_dest_t *rx_db_inuse[NUM_RX_DMA];
 	db_dest_t *tx_db_inuse[NUM_TX_DMA];
 	u32 rx_head;
@@ -205,6 +212,7 @@
 	u32 tx_tail;
 	u32 tx_full;
 
+	int mac_id;
 	mii_phy_t *mii;
 	struct phy_ops *phy_ops;
 	
@@ -218,9 +226,10 @@
 	u8 *hash_table;
 	u32 hash_mode;
 	u32 intr_work_done; /* number of Rx and Tx pkts processed in the isr */
-	u32 phy_addr;          /* PHY address */
+	int phy_addr;          /* phy address */
 	u32 options;           /* User-settable misc. driver options. */
 	u32 drv_flags;
+	int want_autoneg;
 	struct net_device_stats stats;
 	struct timer_list timer;
 	spinlock_t lock;       /* Serialise access to device */
diff -Nru a/drivers/net/bagetlance.c b/drivers/net/bagetlance.c
--- a/drivers/net/bagetlance.c	2005-03-06 18:36:50 -05:00
+++ /dev/null	Wed Dec 31 16:00:00 196900
@@ -1,1368 +0,0 @@
-/*
- * bagetlance.c: Ethernet driver for VME Lance cards on Baget/MIPS
- *      This code stealed and adopted from linux/drivers/net/atarilance.c
- *      See that for author info
- *
- * Copyright (C) 1998 Gleb Raiko & Vladimir Roganov
- */
-
-/* 
- * Driver code for Baget/Lance taken from atarilance.c, which also
- * works well in case of Besta. Most significant changes made here
- * related with 16BIT-only access to A24 space.
- */
-
-static char *version = "bagetlance.c: v1.1 11/10/98\n";
-
-#include <linux/module.h>
-#include <linux/stddef.h>
-#include <linux/kernel.h>
-#include <linux/string.h>
-#include <linux/errno.h>
-#include <linux/slab.h>
-#include <linux/interrupt.h>
-#include <linux/init.h>
-#include <linux/netdevice.h>
-#include <linux/etherdevice.h>
-#include <linux/skbuff.h>
-#include <linux/bitops.h>
-
-#include <asm/irq.h>
-#include <asm/io.h>
-#include <asm/baget/baget.h>
-
-#define BAGET_LANCE_IRQ  BAGET_IRQ_MASK(0xdf)
-
-/*
- *  Define following if you don't need 16BIT-only access to Lance memory
- *  (Normally BAGET needs it)
- */
-#undef NORMAL_MEM_ACCESS 
-
-/* Debug level:
- *  0 = silent, print only serious errors
- *  1 = normal, print error messages
- *  2 = debug, print debug infos
- *  3 = debug, print even more debug infos (packet data)
- */
-
-#define	LANCE_DEBUG	1  
-
-#ifdef LANCE_DEBUG
-static int lance_debug = LANCE_DEBUG;
-#else
-static int lance_debug = 1;
-#endif
-MODULE_PARM(lance_debug, "i");
-MODULE_PARM_DESC(lance_debug, "Lance debug level (0-3)");
-MODULE_LICENSE("GPL");
-
-/* Print debug messages on probing? */
-#undef LANCE_DEBUG_PROBE
-
-#define	DPRINTK(n,a)							\
-	do {										\
-		if (lance_debug >= n)					\
-			printk a;							\
-	} while( 0 )
-
-#ifdef LANCE_DEBUG_PROBE
-# define PROBE_PRINT(a)	printk a
-#else
-# define PROBE_PRINT(a)
-#endif
-
-/* These define the number of Rx and Tx buffers as log2. (Only powers
- * of two are valid)
- * Much more rx buffers (32) are reserved than tx buffers (8), since receiving
- * is more time critical then sending and packets may have to remain in the
- * board's memory when main memory is low.
- */
-
-/* Baget Lance has 64K on-board memory, so it looks we can't increase
-   buffer quantity (40*1.5K is about 64K) */
-
-#define TX_LOG_RING_SIZE			3
-#define RX_LOG_RING_SIZE			5
-
-/* These are the derived values */
-
-#define TX_RING_SIZE			(1 << TX_LOG_RING_SIZE)
-#define TX_RING_LEN_BITS		(TX_LOG_RING_SIZE << 5)
-#define	TX_RING_MOD_MASK		(TX_RING_SIZE - 1)
-
-#define RX_RING_SIZE			(1 << RX_LOG_RING_SIZE)
-#define RX_RING_LEN_BITS		(RX_LOG_RING_SIZE << 5)
-#define	RX_RING_MOD_MASK		(RX_RING_SIZE - 1)
-
-/* The LANCE Rx and Tx ring descriptors. */
-struct lance_rx_head {
-	volatile unsigned short	base;		/* Low word of base addr */
-#ifdef NORMAL_MEM_ACCESS
-       /* Following two fields are joined into one short to guarantee
-		  16BIT access to Baget lance registers */
-	volatile unsigned char	flag;
-	unsigned char			base_hi;	/* High word of base addr (unused) */
-#else
-/* Following macros are used as replecements to 8BIT fields */
-#define GET_FLAG(h)    (((h)->flag_base_hi >> 8) & 0xff)
-#define SET_FLAG(h,f)  (h)->flag_base_hi = ((h)->flag_base_hi & 0xff) | \
-		                                                (((unsigned)(f)) << 8)
-	volatile unsigned short flag_base_hi; 
-#endif
-	volatile short			buf_length;	/* This length is 2s complement! */
-	volatile short			msg_length;	/* This length is "normal". */
-};
-
-
-struct lance_tx_head {
-	volatile unsigned short	base;		/* Low word of base addr */
-#ifdef NORMAL_MEM_ACCESS 
-/* See comments above about 8BIT-access Baget A24-space problems */
-	volatile unsigned char	flag;
-	unsigned char			base_hi;	/* High word of base addr (unused) */
-#else
-	volatile unsigned short  flag_base_hi;
-#endif
-	volatile short			length;		/* Length is 2s complement! */
-	volatile short			misc;
-};
-
-struct ringdesc {
-	volatile unsigned short	adr_lo;		/* Low 16 bits of address */
-#ifdef NORMAL_MEM_ACCESS 
-/* See comments above about 8BIT-access Bage A24-space problems */
-	unsigned char	len;		/* Length bits */
-	unsigned char	adr_hi;		/* High 8 bits of address (unused) */
-#else
-	volatile unsigned short  len_adr_hi;
-#endif
-};
-
-/* The LANCE initialization block, described in databook. */
-struct lance_init_block {
-	unsigned short	mode;		/* Pre-set mode */
-	unsigned char	hwaddr[6];	/* Physical ethernet address */
-	unsigned		filter[2];	/* Multicast filter (unused). */
-	/* Receive and transmit ring base, along with length bits. */
-	struct ringdesc	rx_ring;
-	struct ringdesc	tx_ring;
-};
-
-/* The whole layout of the Lance shared memory */
-struct lance_memory {
-	struct lance_init_block	init;
-	struct lance_tx_head	tx_head[TX_RING_SIZE];
-	struct lance_rx_head	rx_head[RX_RING_SIZE];
-	char					packet_area[0];	/* packet data follow after the
-											 * init block and the ring
-											 * descriptors and are located
-											 * at runtime */
-};
-
-/* RieblCard specifics:
- * The original TOS driver for these cards reserves the area from offset
- * 0xee70 to 0xeebb for storing configuration data. Of interest to us is the
- * Ethernet address there, and the magic for verifying the data's validity.
- * The reserved area isn't touch by packet buffers. Furthermore, offset 0xfffe
- * is reserved for the interrupt vector number.
- */
-#define	RIEBL_RSVD_START	0xee70
-#define	RIEBL_RSVD_END		0xeec0
-#define RIEBL_MAGIC			0x09051990
-#define RIEBL_MAGIC_ADDR	((unsigned long *)(((char *)MEM) + 0xee8a))
-#define RIEBL_HWADDR_ADDR	((unsigned char *)(((char *)MEM) + 0xee8e))
-#define RIEBL_IVEC_ADDR		((unsigned short *)(((char *)MEM) + 0xfffe))
-
-/* This is a default address for the old RieblCards without a battery
- * that have no ethernet address at boot time. 00:00:36:04 is the
- * prefix for Riebl cards, the 00:00 at the end is arbitrary.
- */
-
-static unsigned char OldRieblDefHwaddr[6] = {
-	0x00, 0x00, 0x36, 0x04, 0x00, 0x00
-};
-
-/* I/O registers of the Lance chip */
-
-struct lance_ioreg {
-/* base+0x0 */	volatile unsigned short	data;
-/* base+0x2 */	volatile unsigned short	addr;
-				unsigned char			_dummy1[3];
-/* base+0x7 */	volatile unsigned char	ivec;
-				unsigned char			_dummy2[5];
-/* base+0xd */	volatile unsigned char	eeprom;
-				unsigned char			_dummy3;
-/* base+0xf */	volatile unsigned char	mem;
-};
-
-/* Types of boards this driver supports */
-
-enum lance_type {
-	OLD_RIEBL,		/* old Riebl card without battery */
-	NEW_RIEBL,		/* new Riebl card with battery */
-	PAM_CARD		/* PAM card with EEPROM */
-};
-
-static char *lance_names[] = {
-	"Riebl-Card (without battery)",
-	"Riebl-Card (with battery)",
-	"PAM intern card"
-};
-
-/* The driver's private device structure */
-
-struct lance_private {
-	enum lance_type		cardtype;
-	struct lance_ioreg	*iobase;
-	struct lance_memory	*mem;
-	int					cur_rx, cur_tx;	/* The next free ring entry */
-	int					dirty_tx;		/* Ring entries to be freed. */
-						/* copy function */
-	void				*(*memcpy_f)( void *, const void *, size_t );
-	struct net_device_stats stats;
-/* These two must be longs for set_bit() */
-	long				tx_full;
-	long				lock;
-};
-
-/* I/O register access macros */
-
-#define	MEM		lp->mem
-#define	DREG	IO->data
-#define	AREG	IO->addr
-#define	REGA(a)	( AREG = (a), DREG )
-
-/* Definitions for packet buffer access: */
-#define PKT_BUF_SZ		1544
-/* Get the address of a packet buffer corresponding to a given buffer head */
-#define	PKTBUF_ADDR(head)	(((unsigned char *)(MEM)) + (head)->base)
-
-/* Possible memory/IO addresses for probing */
-
-struct lance_addr {
-	unsigned long	memaddr;
-	unsigned long	ioaddr;
-	int				slow_flag;
-} lance_addr_list[] = {
-	{ BAGET_LANCE_MEM_BASE, BAGET_LANCE_IO_BASE, 1 }	/* Baget Lance */
-};
-
-#define	N_LANCE_ADDR	(sizeof(lance_addr_list)/sizeof(*lance_addr_list))
-
-
-#define LANCE_HI_BASE (0xff & (BAGET_LANCE_MEM_BASE >> 16))
-
-/* Definitions for the Lance */
-
-/* tx_head flags */
-#define TMD1_ENP		0x01	/* end of packet */
-#define TMD1_STP		0x02	/* start of packet */
-#define TMD1_DEF		0x04	/* deferred */
-#define TMD1_ONE		0x08	/* one retry needed */
-#define TMD1_MORE		0x10	/* more than one retry needed */
-#define TMD1_ERR		0x40	/* error summary */
-#define TMD1_OWN 		0x80	/* ownership (set: chip owns) */
-
-#define TMD1_OWN_CHIP	TMD1_OWN
-#define TMD1_OWN_HOST	0
-
-/* tx_head misc field */
-#define TMD3_TDR		0x03FF	/* Time Domain Reflectometry counter */
-#define TMD3_RTRY		0x0400	/* failed after 16 retries */
-#define TMD3_LCAR		0x0800	/* carrier lost */
-#define TMD3_LCOL		0x1000	/* late collision */
-#define TMD3_UFLO		0x4000	/* underflow (late memory) */
-#define TMD3_BUFF		0x8000	/* buffering error (no ENP) */
-
-/* rx_head flags */
-#define RMD1_ENP		0x01	/* end of packet */
-#define RMD1_STP		0x02	/* start of packet */
-#define RMD1_BUFF		0x04	/* buffer error */
-#define RMD1_CRC		0x08	/* CRC error */
-#define RMD1_OFLO		0x10	/* overflow */
-#define RMD1_FRAM		0x20	/* framing error */
-#define RMD1_ERR		0x40	/* error summary */
-#define RMD1_OWN 		0x80	/* ownership (set: ship owns) */
-
-#define RMD1_OWN_CHIP	RMD1_OWN
-#define RMD1_OWN_HOST	0
-
-/* register names */
-#define CSR0	0		/* mode/status */
-#define CSR1	1		/* init block addr (low) */
-#define CSR2	2		/* init block addr (high) */
-#define CSR3	3		/* misc */
-#define CSR8	8	  	/* address filter */
-#define CSR15	15		/* promiscuous mode */
-
-/* CSR0 */
-/* (R=readable, W=writeable, S=set on write, C=clear on write) */
-#define CSR0_INIT	0x0001		/* initialize (RS) */
-#define CSR0_STRT	0x0002		/* start (RS) */
-#define CSR0_STOP	0x0004		/* stop (RS) */
-#define CSR0_TDMD	0x0008		/* transmit demand (RS) */
-#define CSR0_TXON	0x0010		/* transmitter on (R) */
-#define CSR0_RXON	0x0020		/* receiver on (R) */
-#define CSR0_INEA	0x0040		/* interrupt enable (RW) */
-#define CSR0_INTR	0x0080		/* interrupt active (R) */
-#define CSR0_IDON	0x0100		/* initialization done (RC) */
-#define CSR0_TINT	0x0200		/* transmitter interrupt (RC) */
-#define CSR0_RINT	0x0400		/* receiver interrupt (RC) */
-#define CSR0_MERR	0x0800		/* memory error (RC) */
-#define CSR0_MISS	0x1000		/* missed frame (RC) */
-#define CSR0_CERR	0x2000		/* carrier error (no heartbeat :-) (RC) */
-#define CSR0_BABL	0x4000		/* babble: tx-ed too many bits (RC) */
-#define CSR0_ERR	0x8000		/* error (RC) */
-
-/* CSR3 */
-#define CSR3_BCON	0x0001		/* byte control */
-#define CSR3_ACON	0 // fixme: 0x0002		/* ALE control */
-#define CSR3_BSWP	0x0004		/* byte swap (1=big endian) */
-
-
-
-/***************************** Prototypes *****************************/
-
-static int addr_accessible( volatile void *regp, int wordflag, int
-                            writeflag );
-static int lance_probe1( struct net_device *dev, struct lance_addr *init_rec );
-static int lance_open( struct net_device *dev );
-static void lance_init_ring( struct net_device *dev );
-static int lance_start_xmit( struct sk_buff *skb, struct net_device *dev );
-static irqreturn_t lance_interrupt( int irq, void *dev_id, struct pt_regs *fp );
-static int lance_rx( struct net_device *dev );
-static int lance_close( struct net_device *dev );
-static struct net_device_stats *lance_get_stats( struct net_device *dev );
-static void set_multicast_list( struct net_device *dev );
-static int lance_set_mac_address( struct net_device *dev, void *addr );
-
-/************************* End of Prototypes **************************/
-
-/* Network traffic statistic (bytes) */
-
-int lance_stat = 0;
-
-static void update_lance_stat (int len) {
-		lance_stat += len;
-}
-
-/* 
-   This function is used to access Baget/Lance memory to avoid 
-   8/32BIT access to VAC A24 space 
-   ALL memcpy calls was chenged to this function to avoid dbe problems
-   Don't confuse with function name -- it stays from original code
-*/
-
-void *slow_memcpy( void *dst, const void *src, size_t len )
-
-{	
-	unsigned long to     = (unsigned long)dst;
-	unsigned long from   = (unsigned long)src;
-	unsigned long to_end = to +len;
-	
-	/* Unaligned flags */
-
-	int odd_from   = from   & 1;
-	int odd_to     = to     & 1;
-	int odd_to_end = to_end & 1;
-
-	/* Align for 16BIT-access first */
-
-	register unsigned short *from_a   = (unsigned short*) (from   & ~1);
-	register unsigned short *to_a     = (unsigned short*) (to     & ~1); 
-	register unsigned short *to_end_a = (unsigned short*) (to_end & ~1);
-
-	/* Caching values -- not in loop invariant */
-
-	register unsigned short from_v; 
-	register unsigned short to_v;
-
-	/* Invariant is: from_a and to_a are pointers before or exactly to
-	   currently copying byte */
-
-	if (odd_to) { 
-			/* First byte unaligned case */
-			from_v = *from_a;
-			to_v   = *to_a;
-
-			to_v &= ~0xff;
-			to_v |=  0xff & (from_v >> (odd_from ? 0 : 8));
-			*to_a++ = to_v;
-
-			if (odd_from) from_a++;
-	}
-    if (odd_from == odd_to) {
-			/* Same parity */
-			while (to_a + 7 < to_end_a) {
-					unsigned long dummy1, dummy2;
-					unsigned long reg1, reg2, reg3, reg4;
-
-					__asm__ __volatile__(
-					".set\tnoreorder\n\t"
-					".set\tnoat\n\t"
-					"lh\t%2,0(%1)\n\t"
-					"nop\n\t"
-					 "lh\t%3,2(%1)\n\t"
-					"sh\t%2,0(%0)\n\t"
-					   "lh\t%4,4(%1)\n\t"
-					 "sh\t%3,2(%0)\n\t"
-					    "lh\t%5,6(%1)\n\t"
-					   "sh\t%4,4(%0)\n\t"
-					"lh\t%2,8(%1)\n\t"
-					    "sh\t%5,6(%0)\n\t"
-					 "lh\t%3,10(%1)\n\t"
-					"sh\t%2,8(%0)\n\t"
-					  "lh\t%4,12(%1)\n\t"
-					 "sh\t%3,10(%0)\n\t"
-					    "lh\t%5,14(%1)\n\t"
-					  "sh\t%4,12(%0)\n\t"
-					 "nop\n\t"
-					    "sh\t%5,14(%0)\n\t"
-					".set\tat\n\t"
-					".set\treorder"
-					:"=r" (dummy1), "=r" (dummy2),
-					"=&r" (reg1), "=&r" (reg2), "=&r" (reg3), "=&r" (reg4)
-					:"0" (to_a), "1" (from_a)
-					:"memory");
-
-					to_a   += 8;
-					from_a += 8;
-
-			}
-			while (to_a < to_end_a) {
-					*to_a++ = *from_a++;
-			}
-	} else {
-			/* Different parity */
-			from_v = *from_a;
-			while (to_a < to_end_a) {
-					unsigned short from_v_next;
-					from_v_next = *++from_a;
-					*to_a++ = ((from_v & 0xff)<<8) | ((from_v_next>>8) & 0xff);
-					from_v = from_v_next; 
-			}
-
-	}
-	if (odd_to_end) {
-			/* Last byte unaligned case */
-			to_v = *to_a;
-			from_v = *from_a;
-
-			to_v &= ~0xff00;
-			if (odd_from == odd_to) {
-					to_v |= from_v & 0xff00;
-			} else {
-					to_v |= (from_v<<8) & 0xff00;
-			}
-
-			*to_a = to_v;
-	}
-
-	update_lance_stat( len );
-
-	return( dst );
-}
-
-
-struct net_device * __init bagetlance_probe(int unit)
-{
-	struct net_device *dev;
-	int i;
-	static int found;
-	int err = -ENODEV;
-
-	if (found)
-		/* Assume there's only one board possible... That seems true, since
-		 * the Riebl/PAM board's address cannot be changed. */
-		return ERR_PTR(-ENODEV);
-
-	dev = alloc_etherdev(sizeof(struct lance_private));
-	if (!dev)
-		return ERR_PTR(-ENOMEM);
-
-	SET_MODULE_OWNER(dev);
-
-	for( i = 0; i < N_LANCE_ADDR; ++i ) {
-		if (lance_probe1( dev, &lance_addr_list[i] )) {
-			found = 1;
-			break;
-		}
-	}
-	if (!found)
-		goto out;
-	err = register_netdev(dev);
-	if (err)
-		goto out1;
-	return dev;
-out1:
-	free_irq(dev->irq, dev);
-out:
-	free_netdev(dev);
-	return ERR_PTR(err);
-}
-
-/* Derived from hwreg_present() in vme/config.c: */
-
-static int __init addr_accessible( volatile void *regp, 
-				   int wordflag, 
-				   int writeflag )
-{	
-		/* We have a fine function to do it */
-		extern int try_read(unsigned long, int);
-		return try_read((unsigned long)regp, sizeof(short)) != -1;   
-}
-
-
-
-/* Original atari driver uses it */
-#define IRQ_TYPE_PRIO SA_INTERRUPT
-#define IRQ_SOURCE_TO_VECTOR(x) (x)
-
-static int __init lance_probe1( struct net_device *dev,
-				struct lance_addr *init_rec )
-
-{	volatile unsigned short *memaddr =
-		(volatile unsigned short *)init_rec->memaddr;
-	volatile unsigned short *ioaddr =
-		(volatile unsigned short *)init_rec->ioaddr;
-	struct lance_private	*lp;
-	struct lance_ioreg		*IO;
-	int 					i;
-	static int 				did_version;
-	unsigned short			save1, save2;
-
-	PROBE_PRINT(( "Probing for Lance card at mem %#lx io %#lx\n",
-				  (long)memaddr, (long)ioaddr ));
-
-	/* Test whether memory readable and writable */
-	PROBE_PRINT(( "lance_probe1: testing memory to be accessible\n" ));
-	if (!addr_accessible( memaddr, 1, 1 )) goto probe_fail;
-
-	if ((unsigned long)memaddr >= KSEG2) {
-			/* FIXME: do we need to undo that on cleanup paths? */
-			extern int kseg2_alloc_io (unsigned long addr, unsigned long size);
-			if (kseg2_alloc_io((unsigned long)memaddr, BAGET_LANCE_MEM_SIZE)) {
-					printk("bagetlance: unable map lance memory\n");
-					goto probe_fail;
-			}
-	}
-
-	/* Written values should come back... */
-	PROBE_PRINT(( "lance_probe1: testing memory to be writable (1)\n" ));
-	save1 = *memaddr;
-	*memaddr = 0x0001;
-	if (*memaddr != 0x0001) goto probe_fail;
-	PROBE_PRINT(( "lance_probe1: testing memory to be writable (2)\n" ));
-	*memaddr = 0x0000;
-	if (*memaddr != 0x0000) goto probe_fail;
-	*memaddr = save1;
-
-	/* First port should be readable and writable */
-	PROBE_PRINT(( "lance_probe1: testing ioport to be accessible\n" ));
-	if (!addr_accessible( ioaddr, 1, 1 )) goto probe_fail;
-
-	/* and written values should be readable */
-	PROBE_PRINT(( "lance_probe1: testing ioport to be writeable\n" ));
-	save2 = ioaddr[1];
-	ioaddr[1] = 0x0001;
-	if (ioaddr[1] != 0x0001) goto probe_fail;
-
-	/* The CSR0_INIT bit should not be readable */
-	PROBE_PRINT(( "lance_probe1: testing CSR0 register function (1)\n" ));
-	save1 = ioaddr[0];
-	ioaddr[1] = CSR0;
-	ioaddr[0] = CSR0_INIT | CSR0_STOP;
-	if (ioaddr[0] != CSR0_STOP) {
-		ioaddr[0] = save1;
-		ioaddr[1] = save2;
-		goto probe_fail;
-	}
-	PROBE_PRINT(( "lance_probe1: testing CSR0 register function (2)\n" ));
-	ioaddr[0] = CSR0_STOP;
-	if (ioaddr[0] != CSR0_STOP) {
-		ioaddr[0] = save1;
-		ioaddr[1] = save2;
-		goto probe_fail;
-	}
-
-	/* Now ok... */
-	PROBE_PRINT(( "lance_probe1: Lance card detected\n" ));
-	goto probe_ok;
-
-  probe_fail:
-	return( 0 );
-
-  probe_ok:
-	lp = netdev_priv(dev);
-	MEM = (struct lance_memory *)memaddr;
-	IO = lp->iobase = (struct lance_ioreg *)ioaddr;
-	dev->base_addr = (unsigned long)ioaddr; /* informational only */
-	lp->memcpy_f = init_rec->slow_flag ? slow_memcpy : memcpy;
-
-	REGA( CSR0 ) = CSR0_STOP;
-
-	/* Now test for type: If the eeprom I/O port is readable, it is a
-	 * PAM card */
-	if (addr_accessible( &(IO->eeprom), 0, 0 )) {
-		/* Switch back to Ram */
-		i = IO->mem;
-		lp->cardtype = PAM_CARD;
-	}
-#ifdef NORMAL_MEM_ACCESS
-	else if (*RIEBL_MAGIC_ADDR == RIEBL_MAGIC) {
-#else
-	else if (({
-			unsigned short *a = (unsigned short*)RIEBL_MAGIC_ADDR;
-		    (((int)a[0]) << 16) + ((int)a[1]) == RIEBL_MAGIC;
-	})) {
-#endif
-		lp->cardtype = NEW_RIEBL;
-	}
-	else
-		lp->cardtype = OLD_RIEBL;
-
-	if (lp->cardtype == PAM_CARD ||
-		memaddr == (unsigned short *)0xffe00000) {
-		/* PAMs card and Riebl on ST use level 5 autovector */
-		if (request_irq(BAGET_LANCE_IRQ, lance_interrupt, IRQ_TYPE_PRIO,
-		            "PAM/Riebl-ST Ethernet", dev))
-			goto probe_fail;
-		dev->irq = (unsigned short)BAGET_LANCE_IRQ;
-	}
-	else {
-		/* For VME-RieblCards, request a free VME int;
-		 * (This must be unsigned long, since dev->irq is short and the
-		 * IRQ_MACHSPEC bit would be cut off...)
-		 */
-		unsigned long irq = BAGET_LANCE_IRQ; 
-		if (!irq) {
-			printk( "Lance: request for VME interrupt failed\n" );
-			goto probe_fail;
-		}
-		if (request_irq(irq, lance_interrupt, IRQ_TYPE_PRIO,
-		            "Riebl-VME Ethernet", dev))
-			goto probe_fail;
-		dev->irq = irq;
-	}
-
-	printk("%s: %s at io %#lx, mem %#lx, irq %d%s, hwaddr ",
-		   dev->name, lance_names[lp->cardtype],
-		   (unsigned long)ioaddr,
-		   (unsigned long)memaddr,
-		   dev->irq,
-		   init_rec->slow_flag ? " (slow memcpy)" : "" );
-
-	/* Get the ethernet address */
-	switch( lp->cardtype ) {
-	  case OLD_RIEBL:
-		/* No ethernet address! (Set some default address) */
-		slow_memcpy( dev->dev_addr, OldRieblDefHwaddr, 6 );
-		break;
-	  case NEW_RIEBL:
-		lp->memcpy_f( dev->dev_addr, RIEBL_HWADDR_ADDR, 6 );
-		break;
-	  case PAM_CARD:
-		i = IO->eeprom;
-		for( i = 0; i < 6; ++i )
-			dev->dev_addr[i] =
-				((((unsigned short *)MEM)[i*2] & 0x0f) << 4) |
-				((((unsigned short *)MEM)[i*2+1] & 0x0f));
-		i = IO->mem;
-		break;
-	}
-	for( i = 0; i < 6; ++i )
-		printk( "%02x%s", dev->dev_addr[i], (i < 5) ? ":" : "\n" );
-	if (lp->cardtype == OLD_RIEBL) {
-		printk( "%s: Warning: This is a default ethernet address!\n",
-				dev->name );
-		printk( "      Use \"ifconfig hw ether ...\" to set the address.\n" );
-	}
-
-	MEM->init.mode = 0x0000;		/* Disable Rx and Tx. */
-
-	{
-			unsigned char hwaddr[6];
-			for( i = 0; i < 6; i++ ) 
-					hwaddr[i] = dev->dev_addr[i^1]; /* <- 16 bit swap! */
-			slow_memcpy(MEM->init.hwaddr, hwaddr, sizeof(hwaddr));
-	}
-
-	MEM->init.filter[0] = 0x00000000;
-	MEM->init.filter[1] = 0x00000000;
-	MEM->init.rx_ring.adr_lo = offsetof( struct lance_memory, rx_head );
-
-#ifdef NORMAL_MEM_ACCESS
-	MEM->init.rx_ring.adr_hi = LANCE_HI_BASE; 
-	MEM->init.rx_ring.len    = RX_RING_LEN_BITS;
-#else
-	MEM->init.rx_ring.len_adr_hi = 
-			((unsigned)RX_RING_LEN_BITS << 8) | LANCE_HI_BASE;
-#endif
-
-
-	MEM->init.tx_ring.adr_lo = offsetof( struct lance_memory, tx_head );
-
-#ifdef NORMAL_MEM_ACCESS
-	MEM->init.tx_ring.adr_hi = LANCE_HI_BASE; 
-	MEM->init.tx_ring.len    = TX_RING_LEN_BITS;
-#else
-	MEM->init.tx_ring.len_adr_hi = 
-			((unsigned)TX_RING_LEN_BITS<<8) | LANCE_HI_BASE;
-#endif
-
-	if (lp->cardtype == PAM_CARD)
-		IO->ivec = IRQ_SOURCE_TO_VECTOR(dev->irq);
-	else
-		*RIEBL_IVEC_ADDR = IRQ_SOURCE_TO_VECTOR(dev->irq);
-
-	if (did_version++ == 0)
-		DPRINTK( 1, ( version ));
-
-	/* The LANCE-specific entries in the device structure. */
-	dev->open = &lance_open;
-	dev->hard_start_xmit = &lance_start_xmit;
-	dev->stop = &lance_close;
-	dev->get_stats = &lance_get_stats;
-	dev->set_multicast_list = &set_multicast_list;
-	dev->set_mac_address = &lance_set_mac_address;
-	dev->start = 0;
-
-	memset( &lp->stats, 0, sizeof(lp->stats) );
-
-	return( 1 );
-}
-
-
-static int lance_open( struct net_device *dev )
-
-{	struct lance_private *lp = netdev_priv(dev);
-	struct lance_ioreg	 *IO = lp->iobase;
-	int i;
-
-	DPRINTK( 2, ( "%s: lance_open()\n", dev->name ));
-
-	lance_init_ring(dev);
-	/* Re-initialize the LANCE, and start it when done. */
-
-	REGA( CSR3 ) = CSR3_BSWP | (lp->cardtype == PAM_CARD ? CSR3_ACON : 0);
-	REGA( CSR2 ) = 0;
-	REGA( CSR1 ) = 0;
-	REGA( CSR0 ) = CSR0_INIT;
-	/* From now on, AREG is kept to point to CSR0 */
-
-	i = 1000000;
-	while (--i > 0)
-		if (DREG & CSR0_IDON)
-			break;
-	if (i < 0 || (DREG & CSR0_ERR)) {
-		DPRINTK( 2, ( "lance_open(): opening %s failed, i=%d, csr0=%04x\n",
-					  dev->name, i, DREG ));
-		DREG = CSR0_STOP;
-		return( -EIO );
-	}
-	DREG = CSR0_IDON;
-	DREG = CSR0_STRT;
-	DREG = CSR0_INEA;
-
-	dev->tbusy = 0;
-	dev->interrupt = 0;
-	dev->start = 1;
-
-	DPRINTK( 2, ( "%s: LANCE is open, csr0 %04x\n", dev->name, DREG ));
-	return( 0 );
-}
-
-
-/* Initialize the LANCE Rx and Tx rings. */
-
-static void lance_init_ring( struct net_device *dev )
-
-{	struct lance_private *lp = netdev_priv(dev);
-	int i;
-	unsigned offset;
-
-	lp->lock = 0;
-	lp->tx_full = 0;
-	lp->cur_rx = lp->cur_tx = 0;
-	lp->dirty_tx = 0;
-
-	offset = offsetof( struct lance_memory, packet_area );
-
-/* If the packet buffer at offset 'o' would conflict with the reserved area
- * of RieblCards, advance it */
-#define	CHECK_OFFSET(o)														 \
-	do {																	 \
-		if (lp->cardtype == OLD_RIEBL || lp->cardtype == NEW_RIEBL) {		 \
-			if (((o) < RIEBL_RSVD_START) ? (o)+PKT_BUF_SZ > RIEBL_RSVD_START \
-										 : (o) < RIEBL_RSVD_END)			 \
-				(o) = RIEBL_RSVD_END;										 \
-		}																	 \
-	} while(0)
-
-	for( i = 0; i < TX_RING_SIZE; i++ ) {
-		CHECK_OFFSET(offset);
-		MEM->tx_head[i].base = offset;
-#ifdef NORMAL_MEM_ACCESS
-		MEM->tx_head[i].flag = TMD1_OWN_HOST;
- 		MEM->tx_head[i].base_hi = LANCE_HI_BASE;
-#else
-		MEM->tx_head[i].flag_base_hi = 
-				(TMD1_OWN_HOST<<8) | LANCE_HI_BASE;
-#endif
-		MEM->tx_head[i].length = 0;
-		MEM->tx_head[i].misc = 0;
-		offset += PKT_BUF_SZ;
-	}
-
-	for( i = 0; i < RX_RING_SIZE; i++ ) {
-		CHECK_OFFSET(offset);
-		MEM->rx_head[i].base = offset;
-#ifdef NORMAL_MEM_ACCESS
-		MEM->rx_head[i].flag = TMD1_OWN_CHIP;
-		MEM->rx_head[i].base_hi = LANCE_HI_BASE; 
-#else
-		MEM->rx_head[i].flag_base_hi = 
-				(TMD1_OWN_CHIP<<8) | LANCE_HI_BASE;
-#endif
-		MEM->rx_head[i].buf_length = -PKT_BUF_SZ;
-		MEM->rx_head[i].msg_length = 0;
-		offset += PKT_BUF_SZ;
-	}
-}
-
-
-static int lance_start_xmit( struct sk_buff *skb, struct net_device *dev )
-
-{	struct lance_private *lp = netdev_priv(dev);
-	struct lance_ioreg	 *IO = lp->iobase;
-	int entry, len;
-	struct lance_tx_head *head;
-	unsigned long flags;
-
-	/* The old LANCE chips doesn't automatically pad buffers to min. size. */
-	len = (ETH_ZLEN < skb->len) ? skb->len : ETH_ZLEN;
-	/* PAM-Card has a bug: Can only send packets with even number of bytes! */
-	if (lp->cardtype == PAM_CARD && (len & 1))
-		++len;
-
-	if (len > skb->len) {
-		skb = skb_padto(skb, len);
-		if (skb == NULL)
-			return 0;
-	}	
-
-	/* Transmitter timeout, serious problems. */
-	if (dev->tbusy) {
-		int tickssofar = jiffies - dev->trans_start;
-		if (tickssofar < 20)
-			return( 1 );
-		AREG = CSR0;
-		DPRINTK( 1, ( "%s: transmit timed out, status %04x, resetting.\n",
-					  dev->name, DREG ));
-		DREG = CSR0_STOP;
-		/*
-		 * Always set BSWP after a STOP as STOP puts it back into
-		 * little endian mode.
-		 */
-		REGA( CSR3 ) = CSR3_BSWP | (lp->cardtype == PAM_CARD ? CSR3_ACON : 0);
-		lp->stats.tx_errors++;
-#ifndef final_version
-		{	int i;
-			DPRINTK( 2, ( "Ring data: dirty_tx %d cur_tx %d%s cur_rx %d\n",
-						  lp->dirty_tx, lp->cur_tx,
-						  lp->tx_full ? " (full)" : "",
-						  lp->cur_rx ));
-			for( i = 0 ; i < RX_RING_SIZE; i++ )
-				DPRINTK( 2, ( "rx #%d: base=%04x blen=%04x mlen=%04x\n",
-							  i, MEM->rx_head[i].base,
-							  -MEM->rx_head[i].buf_length,
-							  MEM->rx_head[i].msg_length ));
-			for( i = 0 ; i < TX_RING_SIZE; i++ )
-				DPRINTK( 2, ( "tx #%d: base=%04x len=%04x misc=%04x\n",
-							  i, MEM->tx_head[i].base,
-							  -MEM->tx_head[i].length,
-							  MEM->tx_head[i].misc ));
-		}
-#endif
-		lance_init_ring(dev);
-		REGA( CSR0 ) = CSR0_INEA | CSR0_INIT | CSR0_STRT;
-
-		dev->tbusy = 0;
-		dev->trans_start = jiffies;
-
-		return( 0 );
-	}
-
-	DPRINTK( 2, ( "%s: lance_start_xmit() called, csr0 %4.4x.\n",
-				  dev->name, DREG ));
-
-	/* Block a timer-based transmit from overlapping.  This could better be
-	   done with atomic_swap(1, dev->tbusy), but set_bit() works as well. */
-	if (test_and_set_bit( 0, (void*)&dev->tbusy ) != 0) {
-		DPRINTK( 0, ( "%s: Transmitter access conflict.\n", dev->name ));
-		return 1;
-	}
-
-	if (test_and_set_bit( 0, (void*)&lp->lock ) != 0) {
-		DPRINTK( 0, ( "%s: tx queue lock!.\n", dev->name ));
-		/* don't clear dev->tbusy flag. */
-		return 1;
-	}
-
-	/* Fill in a Tx ring entry */
-	if (lance_debug >= 3) {
-		u_char *p;
-		int i;
-		printk( "%s: TX pkt type 0x%04x from ", dev->name,
-				((u_short *)skb->data)[6]);
-		for( p = &((u_char *)skb->data)[6], i = 0; i < 6; i++ )
-			printk("%02x%s", *p++, i != 5 ? ":" : "" );
-		printk(" to ");
-		for( p = (u_char *)skb->data, i = 0; i < 6; i++ )
-			printk("%02x%s", *p++, i != 5 ? ":" : "" );
-		printk(" data at 0x%08x len %d\n", (int)skb->data,
-			   (int)skb->len );
-	}
-
-	/* We're not prepared for the int until the last flags are set/reset. And
-	 * the int may happen already after setting the OWN_CHIP... */
-	save_flags(flags);
-	cli();
-
-	/* Mask to ring buffer boundary. */
-	entry = lp->cur_tx & TX_RING_MOD_MASK;
-	head  = &(MEM->tx_head[entry]);
-
-	/* Caution: the write order is important here, set the "ownership" bits
-	 * last.
-	 */
-
-	head->length = -len;
-	head->misc = 0;
-	lp->memcpy_f( PKTBUF_ADDR(head), (void *)skb->data, skb->len );
-#ifdef NORMAL_MEM_ACCESS
-	head->flag = TMD1_OWN_CHIP | TMD1_ENP | TMD1_STP;
-#else
-    SET_FLAG(head,(TMD1_OWN_CHIP | TMD1_ENP | TMD1_STP));
-#endif
-	lp->stats.tx_bytes += skb->len;
-	dev_kfree_skb( skb );
-	lp->cur_tx++;
-	while( lp->cur_tx >= TX_RING_SIZE && lp->dirty_tx >= TX_RING_SIZE ) {
-		lp->cur_tx -= TX_RING_SIZE;
-		lp->dirty_tx -= TX_RING_SIZE;
-	}
-
-	/* Trigger an immediate send poll. */
-	DREG = CSR0_INEA | CSR0_TDMD;
-	dev->trans_start = jiffies;
-
-	lp->lock = 0;
-#ifdef NORMAL_MEM_ACCESS
-	if ((MEM->tx_head[(entry+1) & TX_RING_MOD_MASK].flag & TMD1_OWN) ==
-#else
-	if ((GET_FLAG(&MEM->tx_head[(entry+1) & TX_RING_MOD_MASK]) & TMD1_OWN) ==
-#endif
-		TMD1_OWN_HOST)
-		dev->tbusy = 0;
-	else
-		lp->tx_full = 1;
-	restore_flags(flags);
-
-	return 0;
-}
-
-/* The LANCE interrupt handler. */
-
-static irqreturn_t lance_interrupt( int irq, void *dev_id, struct pt_regs *fp)
-{
-	struct net_device *dev = dev_id;
-	struct lance_private *lp;
-	struct lance_ioreg	 *IO;
-	int csr0, boguscnt = 10;
-	int handled = 0;
-
-	if (dev == NULL) {
-		DPRINTK( 1, ( "lance_interrupt(): interrupt for unknown device.\n" ));
-		return IRQ_NONE;
-	}
-
-	lp = netdev_priv(dev);
-	IO = lp->iobase;
-	AREG = CSR0;
-
-	if (dev->interrupt) {
-			DPRINTK( 1, ( "Re-entering CAUSE=%08x STATUS=%08x\n",  
-						  read_32bit_cp0_register(CP0_CAUSE),  
-						  read_32bit_cp0_register(CP0_STATUS) ));
-			panic("lance: interrupt handler reentered !");
-	}
-
-	dev->interrupt = 1;
-
-	while( ((csr0 = DREG) & (CSR0_ERR | CSR0_TINT | CSR0_RINT)) &&
-		   --boguscnt >= 0) {
-		handled = 1;
-		/* Acknowledge all of the current interrupt sources ASAP. */
-		DREG = csr0 & ~(CSR0_INIT | CSR0_STRT | CSR0_STOP |
-									CSR0_TDMD | CSR0_INEA);
-
-		DPRINTK( 2, ( "%s: interrupt  csr0=%04x new csr=%04x.\n",
-					  dev->name, csr0, DREG ));
-
-		if (csr0 & CSR0_RINT)			/* Rx interrupt */
-			lance_rx( dev );
-
-		if (csr0 & CSR0_TINT) {			/* Tx-done interrupt */
-			int dirty_tx = lp->dirty_tx;
-
-			while( dirty_tx < lp->cur_tx) {
-				int entry = dirty_tx & TX_RING_MOD_MASK;
-#ifdef NORMAL_MEM_ACCESS
-				int status = MEM->tx_head[entry].flag;
-#else
-				int status = GET_FLAG(&MEM->tx_head[entry]);
-#endif
-				if (status & TMD1_OWN_CHIP)
-					break;			/* It still hasn't been Txed */
-
-#ifdef NORMAL_MEM_ACCESS
-				MEM->tx_head[entry].flag = 0;
-#else
-				SET_FLAG(&MEM->tx_head[entry],0);
-#endif
-
-				if (status & TMD1_ERR) {
-					/* There was an major error, log it. */
-					int err_status = MEM->tx_head[entry].misc;
-					lp->stats.tx_errors++;
-					if (err_status & TMD3_RTRY) lp->stats.tx_aborted_errors++;
-					if (err_status & TMD3_LCAR) lp->stats.tx_carrier_errors++;
-					if (err_status & TMD3_LCOL) lp->stats.tx_window_errors++;
-					if (err_status & TMD3_UFLO) {
-						/* Ackk!  On FIFO errors the Tx unit is turned off! */
-						lp->stats.tx_fifo_errors++;
-						/* Remove this verbosity later! */
-						DPRINTK( 1, ( "%s: Tx FIFO error! Status %04x\n",
-									  dev->name, csr0 ));
-						/* Restart the chip. */
-						DREG = CSR0_STRT;
-					}
-				} else {
-					if (status & (TMD1_MORE | TMD1_ONE | TMD1_DEF))
-						lp->stats.collisions++;
-					lp->stats.tx_packets++;
-				}
-				dirty_tx++;
-			}
-
-#ifndef final_version
-			if (lp->cur_tx - dirty_tx >= TX_RING_SIZE) {
-				DPRINTK( 0, ( "out-of-sync dirty pointer,"
-							  " %d vs. %d, full=%d.\n",
-							  dirty_tx, lp->cur_tx, lp->tx_full ));
-				dirty_tx += TX_RING_SIZE;
-			}
-#endif
-
-			if (lp->tx_full && dev->tbusy
-				&& dirty_tx > lp->cur_tx - TX_RING_SIZE + 2) {
-				/* The ring is no longer full, clear tbusy. */
-				lp->tx_full = 0;
-				dev->tbusy = 0;
-				mark_bh( NET_BH );
-			}
-
-			lp->dirty_tx = dirty_tx;
-		}
-
-		/* Log misc errors. */
-		if (csr0 & CSR0_BABL) lp->stats.tx_errors++; /* Tx babble. */
-		if (csr0 & CSR0_MISS) lp->stats.rx_errors++; /* Missed a Rx frame. */
-		if (csr0 & CSR0_MERR) {
-			DPRINTK( 1, ( "%s: Bus master arbitration failure (?!?), "
-						  "status %04x.\n", dev->name, csr0 ));
-			/* Restart the chip. */
-			DREG = CSR0_STRT;
-		}
-	}
-
-    /* Clear any other interrupt, and set interrupt enable. */
-	DREG = CSR0_BABL | CSR0_CERR | CSR0_MISS | CSR0_MERR |
-		   CSR0_IDON | CSR0_INEA;
-
-	DPRINTK( 2, ( "%s: exiting interrupt, csr0=%#04x.\n",
-				  dev->name, DREG ));
-	dev->interrupt = 0;
-	return IRQ_RETVAL(handled);
-}
-
-
-static int lance_rx( struct net_device *dev )
-
-{	struct lance_private *lp = netdev_priv(dev);
-	int entry = lp->cur_rx & RX_RING_MOD_MASK;
-	int i;
-
-#ifdef NORMAL_MEM_ACCESS
-	DPRINTK( 2, ( "%s: rx int, flag=%04x\n", dev->name,
-				  MEM->rx_head[entry].flag ));
-#else
-	DPRINTK( 2, ( "%s: rx int, flag=%04x\n", dev->name,
-				  GET_FLAG(&MEM->rx_head[entry]) ));
-#endif
-
-	/* If we own the next entry, it's a new packet. Send it up. */
-#ifdef NORMAL_MEM_ACCESS
-	while( (MEM->rx_head[entry].flag & RMD1_OWN) == RMD1_OWN_HOST ) {
-#else
-	while( (GET_FLAG(&MEM->rx_head[entry]) & RMD1_OWN) == RMD1_OWN_HOST ) {
-#endif
-		struct lance_rx_head *head = &(MEM->rx_head[entry]);
-#ifdef NORMAL_MEM_ACCESS
-		int status = head->flag;
-#else
-		int status = GET_FLAG(head);
-#endif
-
-		if (status != (RMD1_ENP|RMD1_STP)) {		/* There was an error. */
-			/* There is a tricky error noted by John Murphy,
-			   <murf@perftech.com> to Russ Nelson: Even with full-sized
-			   buffers it's possible for a jabber packet to use two
-			   buffers, with only the last correctly noting the error. */
-			if (status & RMD1_ENP)	/* Only count a general error at the */
-				lp->stats.rx_errors++; /* end of a packet.*/
-			if (status & RMD1_FRAM) lp->stats.rx_frame_errors++;
-			if (status & RMD1_OFLO) lp->stats.rx_over_errors++;
-			if (status & RMD1_CRC) lp->stats.rx_crc_errors++;
-			if (status & RMD1_BUFF) lp->stats.rx_fifo_errors++;
-#ifdef NORMAL_MEM_ACCESS
-			head->flag &= (RMD1_ENP|RMD1_STP);
-#else
-			SET_FLAG(head,GET_FLAG(head) & (RMD1_ENP|RMD1_STP));
-#endif
-		} else {
-			/* Malloc up new buffer, compatible with net-3. */
-			short pkt_len = head->msg_length & 0xfff;
-			struct sk_buff *skb;
-
-			if (pkt_len < 60) {
-				printk( "%s: Runt packet!\n", dev->name );
-				lp->stats.rx_errors++;
-			}
-			else {
-				skb = dev_alloc_skb( pkt_len+2 );
-				if (skb == NULL) {
-					DPRINTK( 1, ( "%s: Memory squeeze, deferring packet.\n",
-								  dev->name ));
-                          for( i = 0; i < RX_RING_SIZE; i++ )
-#ifdef NORMAL_MEM_ACCESS
-                        if (MEM->rx_head[(entry+i) & RX_RING_MOD_MASK].flag &
-#else
-						if (GET_FLAG(&MEM->rx_head[(entry+i) & \
-												  RX_RING_MOD_MASK]) &
-#endif
-							RMD1_OWN_CHIP)
-							break;
-
-					if (i > RX_RING_SIZE - 2) {
-						lp->stats.rx_dropped++;
-#ifdef NORMAL_MEM_ACCESS
-                        head->flag |= RMD1_OWN_CHIP;
-#else
-                        SET_FLAG(head,GET_FLAG(head) | RMD1_OWN_CHIP);
-#endif
-						lp->cur_rx++;
-					}
-					break;
-				}
-
-				if (lance_debug >= 3) {
-					u_char *data = PKTBUF_ADDR(head), *p;
-					printk( "%s: RX pkt type 0x%04x from ", dev->name,
-							((u_short *)data)[6]);
-					for( p = &data[6], i = 0; i < 6; i++ )
-						printk("%02x%s", *p++, i != 5 ? ":" : "" );
-					printk(" to ");
-					for( p = data, i = 0; i < 6; i++ )
-						printk("%02x%s", *p++, i != 5 ? ":" : "" );
-					printk(" data %02x %02x %02x %02x %02x %02x %02x %02x "
-						   "len %d\n",
-						   data[15], data[16], data[17], data[18],
-						   data[19], data[20], data[21], data[22],
-						   pkt_len );
-				}
-
-				skb->dev = dev;
-				skb_reserve( skb, 2 );	/* 16 byte align */
-				skb_put( skb, pkt_len );	/* Make room */
-				lp->memcpy_f( skb->data, PKTBUF_ADDR(head), pkt_len );
-				skb->protocol = eth_type_trans( skb, dev );
-				netif_rx( skb );
-				dev->last_rx = jiffies;
-				lp->stats.rx_packets++;
-				lp->stats.rx_bytes += pkt_len;
-			}
-		}
-
-#ifdef NORMAL_MEM_ACCESS
-		head->flag |= RMD1_OWN_CHIP;
-#else
-		SET_FLAG(head,GET_FLAG(head) | RMD1_OWN_CHIP);
-#endif
-		entry = (++lp->cur_rx) & RX_RING_MOD_MASK;
-	}
-	lp->cur_rx &= RX_RING_MOD_MASK;
-
-	/* From lance.c (Donald Becker): */
-	/* We should check that at least two ring entries are free.	 If not,
-	   we should free one and mark stats->rx_dropped++. */
-
-	return 0;
-}
-
-
-static int lance_close( struct net_device *dev )
-
-{	struct lance_private *lp = netdev_priv(dev);
-	struct lance_ioreg	 *IO = lp->iobase;
-
-	dev->start = 0;
-	dev->tbusy = 1;
-
-	AREG = CSR0;
-
-	DPRINTK( 2, ( "%s: Shutting down ethercard, status was %2.2x.\n",
-				  dev->name, DREG ));
-
-	/* We stop the LANCE here -- it occasionally polls
-	   memory if we don't. */
-	DREG = CSR0_STOP;
-
-	return 0;
-}
-
-
-static struct net_device_stats *lance_get_stats( struct net_device *dev )
-
-{	
-	struct lance_private *lp = netdev_priv(dev);
-	return &lp->stats;
-}
-
-
-/* Set or clear the multicast filter for this adaptor.
-   num_addrs == -1		Promiscuous mode, receive all packets
-   num_addrs == 0		Normal mode, clear multicast list
-   num_addrs > 0		Multicast mode, receive normal and MC packets, and do
-						best-effort filtering.
- */
-
-static void set_multicast_list( struct net_device *dev )
-
-{	struct lance_private *lp = netdev_priv(dev);
-	struct lance_ioreg	 *IO = lp->iobase;
-
-	if (!dev->start)
-		/* Only possible if board is already started */
-		return;
-
-	/* We take the simple way out and always enable promiscuous mode. */
-	DREG = CSR0_STOP; /* Temporarily stop the lance. */
-
-	if (dev->flags & IFF_PROMISC) {
-		/* Log any net taps. */
-		DPRINTK( 1, ( "%s: Promiscuous mode enabled.\n", dev->name ));
-		REGA( CSR15 ) = 0x8000; /* Set promiscuous mode */
-	} else {
-		short multicast_table[4];
-		int num_addrs = dev->mc_count;
-		int i;
-		/* We don't use the multicast table, but rely on upper-layer
-		 * filtering. */
-		memset( multicast_table, (num_addrs == 0) ? 0 : -1,
-				sizeof(multicast_table) );
-		for( i = 0; i < 4; i++ )
-			REGA( CSR8+i ) = multicast_table[i];
-		REGA( CSR15 ) = 0; /* Unset promiscuous mode */
-	}
-
-	/*
-	 * Always set BSWP after a STOP as STOP puts it back into
-	 * little endian mode.
-	 */
-	REGA( CSR3 ) = CSR3_BSWP | (lp->cardtype == PAM_CARD ? CSR3_ACON : 0);
-
-	/* Resume normal operation and reset AREG to CSR0 */
-	REGA( CSR0 ) = CSR0_IDON | CSR0_INEA | CSR0_STRT;
-}
-
-
-/* This is needed for old RieblCards and possible for new RieblCards */
-
-static int lance_set_mac_address( struct net_device *dev, void *addr )
-
-{	struct lance_private *lp = netdev_priv(dev);
-	struct sockaddr *saddr = addr;
-	int i;
-
-	if (lp->cardtype != OLD_RIEBL && lp->cardtype != NEW_RIEBL)
-		return( -EOPNOTSUPP );
-
-	if (dev->start) {
-		/* Only possible while card isn't started */
-		DPRINTK( 1, ( "%s: hwaddr can be set only while card isn't open.\n",
-					  dev->name ));
-		return( -EIO );
-	}
-
-	slow_memcpy( dev->dev_addr, saddr->sa_data, dev->addr_len );
-
-	{
-			unsigned char hwaddr[6];
-			for( i = 0; i < 6; i++ ) 
-					hwaddr[i] = dev->dev_addr[i^1]; /* <- 16 bit swap! */
-			slow_memcpy(MEM->init.hwaddr, hwaddr, sizeof(hwaddr));
-	}
-
-	lp->memcpy_f( RIEBL_HWADDR_ADDR, dev->dev_addr, 6 );
-	/* set also the magic for future sessions */
-#ifdef NORMAL_MEM_ACCESS
-	*RIEBL_MAGIC_ADDR = RIEBL_MAGIC;
-#else
-	{
-			unsigned long magic = RIEBL_MAGIC;
-			slow_memcpy(RIEBL_MAGIC_ADDR, &magic, sizeof(*RIEBL_MAGIC_ADDR));
-	}
-#endif
-	return( 0 );
-}
-
-
-#ifdef MODULE
-static struct net_device *bagetlance_dev;
-
-int init_module(void)
-{
-	bagetlance_dev = bagetlance_probe(-1);
-	if (IS_ERR(bagetlance_dev))
-		return PTR_ERR(bagetlance_dev);
-	return 0;
-}
-
-void cleanup_module(void)
-{
-	unregister_netdev(bagetlance_dev);
-	free_irq(bagetlance_dev->irq, bagetlance_dev);
-	free_netdev(bagetlance_dev);
-}
-
-#endif /* MODULE */
-
-/*
- * Local variables:
- *  c-indent-level: 4
- *  tab-width: 4
- * End:
- */
diff -Nru a/drivers/net/dl2k.c b/drivers/net/dl2k.c
--- a/drivers/net/dl2k.c	2005-03-06 18:36:50 -05:00
+++ b/drivers/net/dl2k.c	2005-03-06 18:36:50 -05:00
@@ -1199,7 +1199,7 @@
 static void rio_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
 	struct netdev_private *np = netdev_priv(dev);
-	strcpy(info->driver, "DL2K");
+	strcpy(info->driver, "dl2k");
 	strcpy(info->version, DRV_VERSION);
 	strcpy(info->bus_info, pci_name(np->pdev));
 }	
diff -Nru a/drivers/net/gianfar.c b/drivers/net/gianfar.c
--- a/drivers/net/gianfar.c	2005-03-06 18:36:50 -05:00
+++ b/drivers/net/gianfar.c	2005-03-06 18:36:50 -05:00
@@ -377,6 +377,8 @@
 			ADVERTISED_1000baseT_Full);
 	mii_info->autoneg = 1;
 
+	spin_lock_init(&mii_info->mdio_lock);
+
 	mii_info->mii_id = priv->einfo->phyid;
 
 	mii_info->dev = dev;
diff -Nru a/drivers/net/ibm_emac/ibm_emac.h b/drivers/net/ibm_emac/ibm_emac.h
--- a/drivers/net/ibm_emac/ibm_emac.h	2005-03-06 18:36:50 -05:00
+++ b/drivers/net/ibm_emac/ibm_emac.h	2005-03-06 18:36:50 -05:00
@@ -237,6 +237,10 @@
 #define EMAC_RWMR_DEFAULT		0x1000a200
 #define EMAC_TMR0_DEFAULT		EMAC_TMR0_TFAE_2_32
 #define EMAC_TMR1_DEFAULT		0xa00f0000
+#elif defined(CONFIG_440SP)
+#define EMAC_RWMR_DEFAULT		0x08002000
+#define EMAC_TMR0_DEFAULT		EMAC_TMR0_TFAE_128_2048
+#define EMAC_TMR1_DEFAULT		0xf8200000
 #else
 #define EMAC_RWMR_DEFAULT		0x0f002000
 #define EMAC_TMR0_DEFAULT		0x00000000
diff -Nru a/drivers/net/ibm_emac/ibm_emac_core.c b/drivers/net/ibm_emac/ibm_emac_core.c
--- a/drivers/net/ibm_emac/ibm_emac_core.c	2005-03-06 18:36:50 -05:00
+++ b/drivers/net/ibm_emac/ibm_emac_core.c	2005-03-06 18:36:50 -05:00
@@ -1041,7 +1041,7 @@
 	/* set speed (default is 10Mb) */
 	switch (speed) {
 	case SPEED_1000:
-		mode_reg |= EMAC_M1_JUMBO_ENABLE | EMAC_M1_RFS_16K;
+		mode_reg |= EMAC_M1_RFS_16K;
 		if (fep->rgmii_dev) {
 			struct ibm_ocp_rgmii *rgmii = RGMII_PRIV(fep->rgmii_dev);
 
@@ -1118,6 +1118,7 @@
 {
 	struct ocp_enet_private *fep = dev->priv;
 	int old_mtu = dev->mtu;
+	unsigned long mode_reg;
 	emac_t *emacp = fep->emacp;
 	u32 em0mr0;
 	int i, full;
@@ -1160,10 +1161,17 @@
 			fep->rx_skb[i] = NULL;
 		}
 
-		/* Set new rx_buffer_size and advertise new mtu */
-		fep->rx_buffer_size =
-		    new_mtu + ENET_HEADER_SIZE + ENET_FCS_SIZE;
+		/* Set new rx_buffer_size, jumbo cap, and advertise new mtu */
+		mode_reg = in_be32(&emacp->em0mr1);
+		if (new_mtu > ENET_DEF_MTU_SIZE) {
+			mode_reg |= EMAC_M1_JUMBO_ENABLE;
+			fep->rx_buffer_size = EMAC_MAX_FRAME;
+		} else {
+			mode_reg &= ~EMAC_M1_JUMBO_ENABLE;
+			fep->rx_buffer_size = ENET_DEF_BUF_SIZE;
+		}
 		dev->mtu = new_mtu;
+		out_be32(&emacp->em0mr1, mode_reg);
 
 		/* Re-init rx skbs */
 		fep->rx_slot = 0;
diff -Nru a/drivers/net/ibm_emac/ibm_emac_core.h b/drivers/net/ibm_emac/ibm_emac_core.h
--- a/drivers/net/ibm_emac/ibm_emac_core.h	2005-03-06 18:36:50 -05:00
+++ b/drivers/net/ibm_emac/ibm_emac_core.h	2005-03-06 18:36:50 -05:00
@@ -77,6 +77,8 @@
 
 #define ENET_HEADER_SIZE	14
 #define ENET_FCS_SIZE		4
+#define ENET_DEF_MTU_SIZE	1500
+#define ENET_DEF_BUF_SIZE	(ENET_DEF_MTU_SIZE + ENET_HEADER_SIZE + ENET_FCS_SIZE)
 #define EMAC_MIN_FRAME		64
 #define EMAC_MAX_FRAME		9018
 #define EMAC_MIN_MTU		(EMAC_MIN_FRAME - ENET_HEADER_SIZE - ENET_FCS_SIZE)
diff -Nru a/drivers/net/ioc3-eth.c b/drivers/net/ioc3-eth.c
--- a/drivers/net/ioc3-eth.c	2005-03-06 18:36:50 -05:00
+++ b/drivers/net/ioc3-eth.c	2005-03-06 18:36:50 -05:00
@@ -463,6 +463,29 @@
 	printk(".\n");
 }
 
+static void __ioc3_set_mac_address(struct net_device *dev)
+{
+	struct ioc3_private *ip = netdev_priv(dev);
+	struct ioc3 *ioc3 = ip->regs;
+
+	ioc3_w_emar_h((dev->dev_addr[5] <<  8) | dev->dev_addr[4]);
+	ioc3_w_emar_l((dev->dev_addr[3] << 24) | (dev->dev_addr[2] << 16) |
+	              (dev->dev_addr[1] <<  8) | dev->dev_addr[0]);
+}
+
+static int ioc3_set_mac_address(struct net_device *dev, void *addr)
+{
+	struct ioc3_private *ip = netdev_priv(dev);
+	struct sockaddr *sa = addr;
+
+	memcpy(dev->dev_addr, sa->sa_data, dev->addr_len);
+
+	spin_lock_irq(&ip->ioc3_lock);
+	__ioc3_set_mac_address(dev);
+	spin_unlock_irq(&ip->ioc3_lock);
+
+	return 0;
+}
 
 /*
  * Caller must hold the ioc3_lock ever for MII readers.  This is also
@@ -1014,9 +1037,7 @@
 	(void) ioc3_r_etcdc();			/* Clear on read */
 	ioc3_w_ercsr(15);			/* RX low watermark  */
 	ioc3_w_ertr(0);				/* Interrupt immediately */
-	ioc3_w_emar_h((dev->dev_addr[5] <<  8) | dev->dev_addr[4]);
-	ioc3_w_emar_l((dev->dev_addr[3] << 24) | (dev->dev_addr[2] << 16) |
-	              (dev->dev_addr[1] <<  8) | dev->dev_addr[0]);
+	__ioc3_set_mac_address(dev);
 	ioc3_w_ehar_h(ip->ehar_h);
 	ioc3_w_ehar_l(ip->ehar_l);
 	ioc3_w_ersr(42);			/* XXX should be random */
@@ -1100,6 +1121,7 @@
 	       && dev->device == PCI_DEVICE_ID_SGI_IOC3;
 }
 
+#ifdef CONFIG_SERIAL_8250
 /*
  * Note about serial ports and consoles:
  * For console output, everyone uses the IOC3 UARTA (offset 0x178)
@@ -1121,15 +1143,14 @@
  * "device" routine referred to in this console structure
  * (ip27prom_console_dev).
  *
- * Also look in ip27-pci.c:pci_fixuop_ioc3() for some comments on working
+ * Also look in ip27-pci.c:pci_fixup_ioc3() for some comments on working
  * around ioc3 oddities in this respect.
  *
  * The IOC3 serials use a 22MHz clock rate with an additional divider by 3.
  * (IOC3_BAUD = (22000000 / (3*16)))
  */
 
-static inline void ioc3_serial_probe(struct pci_dev *pdev,
-				struct ioc3 *ioc3)
+static void __devinit ioc3_serial_probe(struct pci_dev *pdev, struct ioc3 *ioc3)
 {
 	struct serial_struct req;
 
@@ -1160,9 +1181,9 @@
 	req.iomem_base      = (unsigned char *) &ioc3->sregs.uartb;
 	register_serial(&req);
 }
+#endif
 
-static int __devinit ioc3_probe(struct pci_dev *pdev,
-	                        const struct pci_device_id *ent)
+static int ioc3_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	unsigned int sw_physid1, sw_physid2;
 	struct net_device *dev = NULL;
@@ -1170,11 +1191,39 @@
 	struct ioc3 *ioc3;
 	unsigned long ioc3_base, ioc3_size;
 	u32 vendor, model, rev;
-	int err;
+	int err, pci_using_dac;
+
+	/* Configure DMA attributes. */
+	err = pci_set_dma_mask(pdev, 0xffffffffffffffffULL);
+	if (!err) {
+		pci_using_dac = 1;
+		err = pci_set_consistent_dma_mask(pdev, 0xffffffffffffffffULL);
+		if (err < 0) {
+			printk(KERN_ERR "%s: Unable to obtain 64 bit DMA "
+			       "for consistent allocations\n", pci_name(pdev));
+			goto out;
+		}
+	} else {
+		err = pci_set_dma_mask(pdev, 0xffffffffULL);
+		if (err) {
+			printk(KERN_ERR "%s: No usable DMA configuration, "
+			       "aborting.\n", pci_name(pdev));
+			goto out;
+		}
+		pci_using_dac = 0;
+	}
+
+	if (pci_enable_device(pdev))
+		return -ENODEV;
 
 	dev = alloc_etherdev(sizeof(struct ioc3_private));
-	if (!dev)
-		return -ENOMEM;
+	if (!dev) {
+		err = -ENOMEM;
+		goto out_disable;
+	}
+
+	if (pci_using_dac)
+		dev->features |= NETIF_F_HIGHDMA;
 
 	err = pci_request_regions(pdev, "ioc3");
 	if (err)
@@ -1237,6 +1286,7 @@
 	dev->get_stats		= ioc3_get_stats;
 	dev->do_ioctl		= ioc3_ioctl;
 	dev->set_multicast_list	= ioc3_set_multicast_list;
+	dev->set_mac_address	= ioc3_set_mac_address;
 	dev->ethtool_ops	= &ioc3_ethtool_ops;
 #ifdef CONFIG_SGI_IOC3_ETH_HW_TX_CSUM
 	dev->features		= NETIF_F_IP_CSUM;
@@ -1269,6 +1319,12 @@
 	pci_release_regions(pdev);
 out_free:
 	free_netdev(dev);
+out_disable:
+	/*
+	 * We should call pci_disable_device(pdev); here if the IOC3 wasn't
+	 * such a weird device ...
+	 */
+out:
 	return err;
 }
 
@@ -1282,6 +1338,10 @@
 	iounmap(ioc3);
 	pci_release_regions(pdev);
 	free_netdev(dev);
+	/*
+	 * We should call pci_disable_device(pdev); here if the IOC3 wasn't
+	 * such a weird device ...
+	 */
 }
 
 static struct pci_device_id ioc3_pci_tbl[] = {
diff -Nru a/drivers/net/jazzsonic.c b/drivers/net/jazzsonic.c
--- a/drivers/net/jazzsonic.c	2005-03-06 18:36:50 -05:00
+++ b/drivers/net/jazzsonic.c	2005-03-06 18:36:50 -05:00
@@ -14,6 +14,7 @@
  */
 
 #include <linux/kernel.h>
+#include <linux/module.h>
 #include <linux/types.h>
 #include <linux/fcntl.h>
 #include <linux/interrupt.h>
@@ -28,6 +29,7 @@
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
 #include <linux/bitops.h>
+#include <linux/device.h>
 
 #include <asm/bootinfo.h>
 #include <asm/system.h>
@@ -37,7 +39,10 @@
 #include <asm/jazz.h>
 #include <asm/jazzdma.h>
 
-#define DRV_NAME "jazzsonic"
+static char jazz_sonic_string[] = "jazzsonic";
+static struct platform_device *jazz_sonic_device;
+
+#define SONIC_MEM_SIZE	0x100
 
 #define SREGS_PAD(n)    u16 n;
 
@@ -50,8 +55,8 @@
 
 #define SONIC_WRITE(reg,val)						\
 do {									\
-	*((volatile unsigned int *)base_addr+reg) = val;		\
-}
+	*((volatile unsigned int *)base_addr+(reg)) = (val);		\
+} while (0)
 
 
 /* use 0 for production, 1 for verification, >2 for debug */
@@ -80,70 +85,7 @@
 	0xffff			/* end of list */
 };
 
-/* Index to functions, as function prototypes. */
-
-static int sonic_probe1(struct net_device *dev, unsigned int base_addr,
-                        unsigned int irq);
-
-
-/*
- * Probe for a SONIC ethernet controller on a Mips Jazz board.
- * Actually probing is superfluous but we're paranoid.
- */
-struct net_device * __init sonic_probe(int unit)
-{
-	struct net_device *dev;
-	struct sonic_local *lp;
-	unsigned int base_addr;
-	int err = 0;
-	int i;
-
-	/*
-	 * Don't probe if we're not running on a Jazz board.
-	 */
-	if (mips_machgroup != MACH_GROUP_JAZZ)
-		return ERR_PTR(-ENODEV);
-
-	dev = alloc_etherdev(0);
-	if (!dev)
-		return ERR_PTR(-ENOMEM);
-
-	sprintf(dev->name, "eth%d", unit);
-	netdev_boot_setup_check(dev);
-	base_addr = dev->base_addr;
-
-	if (base_addr >= KSEG0)	{ /* Check a single specified location. */
-		err = sonic_probe1(dev, base_addr, dev->irq);
-	} else if (base_addr != 0) { /* Don't probe at all. */
-		err = -ENXIO;
-	} else {
-		for (i = 0; sonic_portlist[i].port; i++) {
-			int io = sonic_portlist[i].port;
-			if (sonic_probe1(dev, io, sonic_portlist[i].irq) == 0)
-				break;
-		}
-		if (!sonic_portlist[i].port)
-			err = -ENODEV;
-	}
-	if (err)
-		goto out;
-	err = register_netdev(dev);
-	if (err)
-		goto out1;
-	return dev;
-out1:
-	lp = dev->priv;
-	vdma_free(lp->rba_laddr);
-	kfree(lp->rba);
-	vdma_free(lp->cda_laddr);
-	kfree(lp);
-	release_region(dev->base_addr, 0x100);
-out:
-	free_netdev(dev);
-	return ERR_PTR(err);
-}
-
-static int __init sonic_probe1(struct net_device *dev, unsigned int base_addr,
+static int __init sonic_probe1(struct net_device *dev, unsigned long base_addr,
                                unsigned int irq)
 {
 	static unsigned version_printed;
@@ -153,7 +95,7 @@
 	int err = -ENODEV;
 	int i;
 
-	if (!request_region(base_addr, 0x100, DRV_NAME))
+	if (!request_mem_region(base_addr, SONIC_MEM_SIZE, jazz_sonic_string))
 		return -EBUSY;
 	/*
 	 * get the Silicon Revision ID. If this is one of the known
@@ -233,7 +175,7 @@
 		memset(lp, 0, sizeof(struct sonic_local));
 
 		/* get the virtual dma address */
-		lp->cda_laddr = vdma_alloc(PHYSADDR(lp),sizeof(*lp));
+		lp->cda_laddr = vdma_alloc(CPHYSADDR(lp),sizeof(*lp));
 		if (lp->cda_laddr == ~0UL) {
 			printk("%s: couldn't get DMA page entry for "
 			       "descriptors\n", dev->name);
@@ -254,7 +196,7 @@
 		}
 
 		/* get virtual dma address */
-		lp->rba_laddr = vdma_alloc(PHYSADDR(lp->rba),
+		lp->rba_laddr = vdma_alloc(CPHYSADDR(lp->rba),
 		                           SONIC_NUM_RRS * SONIC_RBSIZE);
 		if (lp->rba_laddr == ~0UL) {
 			printk("%s: couldn't get DMA page entry for receive "
@@ -291,7 +233,66 @@
 out1:
 	kfree(lp);
 out:
-	release_region(base_addr, 0x100);
+	release_region(base_addr, SONIC_MEM_SIZE);
+	return err;
+}
+
+/*
+ * Probe for a SONIC ethernet controller on a Mips Jazz board.
+ * Actually probing is superfluous but we're paranoid.
+ */
+static int __init jazz_sonic_probe(struct device *device)
+{
+	struct net_device *dev;
+	struct sonic_local *lp;
+	unsigned long base_addr;
+	int err = 0;
+	int i;
+
+	/*
+	 * Don't probe if we're not running on a Jazz board.
+	 */
+	if (mips_machgroup != MACH_GROUP_JAZZ)
+		return -ENODEV;
+
+	dev = alloc_etherdev(0);
+	if (!dev)
+		return -ENOMEM;
+
+	netdev_boot_setup_check(dev);
+	base_addr = dev->base_addr;
+
+	if (base_addr >= KSEG0)	{ /* Check a single specified location. */
+		err = sonic_probe1(dev, base_addr, dev->irq);
+	} else if (base_addr != 0) { /* Don't probe at all. */
+		err = -ENXIO;
+	} else {
+		for (i = 0; sonic_portlist[i].port; i++) {
+			int io = sonic_portlist[i].port;
+			if (sonic_probe1(dev, io, sonic_portlist[i].irq) == 0)
+				break;
+		}
+		if (!sonic_portlist[i].port)
+			err = -ENODEV;
+	}
+	if (err)
+		goto out;
+	err = register_netdev(dev);
+	if (err)
+		goto out1;
+
+	return 0;
+
+out1:
+	lp = dev->priv;
+	vdma_free(lp->rba_laddr);
+	kfree(lp->rba);
+	vdma_free(lp->cda_laddr);
+	kfree(lp);
+	release_region(dev->base_addr, SONIC_MEM_SIZE);
+out:
+	free_netdev(dev);
+
 	return err;
 }
 
@@ -304,3 +305,77 @@
 #define sonic_chiptomem(x)      KSEG1ADDR(vdma_log2phys(x))
 
 #include "sonic.c"
+
+static int __devexit jazz_sonic_device_remove (struct device *device)
+{
+	struct net_device *dev = device->driver_data;
+
+	unregister_netdev (dev);
+	release_region (dev->base_addr, SONIC_MEM_SIZE);
+	free_netdev (dev);
+
+	return 0;
+}
+
+static struct device_driver jazz_sonic_driver = {
+	.name	= jazz_sonic_string,
+	.bus	= &platform_bus_type,
+	.probe	= jazz_sonic_probe,
+	.remove	= __devexit_p(jazz_sonic_device_remove),
+};
+                                                                                
+static void jazz_sonic_platform_release (struct device *device)
+{
+	struct platform_device *pldev;
+
+	/* free device */
+	pldev = to_platform_device (device);
+	kfree (pldev);
+}
+
+static int __init jazz_sonic_init_module(void)
+{
+	struct platform_device *pldev;
+
+	if (driver_register(&jazz_sonic_driver)) {
+		printk(KERN_ERR "Driver registration failed\n");
+		return -ENOMEM;
+	}
+
+	jazz_sonic_device = NULL;
+
+	if (!(pldev = kmalloc (sizeof (*pldev), GFP_KERNEL))) {
+		goto out_unregister;
+	}
+
+	memset(pldev, 0, sizeof (*pldev));
+	pldev->name		= jazz_sonic_string;
+	pldev->id		= 0;
+	pldev->dev.release	= jazz_sonic_platform_release;
+	jazz_sonic_device	= pldev;
+
+	if (platform_device_register (pldev)) {
+		kfree(pldev);
+		jazz_sonic_device = NULL;
+	}
+
+	return 0;
+
+out_unregister:
+	platform_device_unregister(pldev);
+
+	return -ENOMEM;
+}
+
+static void __exit jazz_sonic_cleanup_module(void)
+{
+	driver_unregister(&jazz_sonic_driver);
+
+	if (jazz_sonic_device) {
+		platform_device_unregister(jazz_sonic_device);
+		jazz_sonic_device = NULL;
+	}
+}
+
+module_init(jazz_sonic_init_module);
+module_exit(jazz_sonic_cleanup_module);
diff -Nru a/drivers/net/meth.c b/drivers/net/meth.c
--- a/drivers/net/meth.c	2005-03-06 18:36:50 -05:00
+++ b/drivers/net/meth.c	2005-03-06 18:36:50 -05:00
@@ -27,7 +27,7 @@
 #include <linux/ip.h>          /* struct iphdr */
 #include <linux/tcp.h>         /* struct tcphdr */
 #include <linux/skbuff.h>
-#include <linux/mii.h> /*MII definitions */
+#include <linux/mii.h>         /* MII definitions */
 
 #include <asm/ip32/mace.h>
 #include <asm/ip32/ip32_ints.h>
@@ -105,27 +105,27 @@
 		(int)o2meth_eaddr[3]&0xFF,(int)o2meth_eaddr[4]&0xFF,(int)o2meth_eaddr[5]&0xFF);
 	for (i = 0; i < 6; i++)
 		dev->dev_addr[i] = o2meth_eaddr[i];
-	mace_eth_write((*(u64*)o2meth_eaddr)>>16, mac_addr);
+	mace->eth.mac_addr = (*(unsigned long*)o2meth_eaddr) >> 16;
 }
 
 /*
  * Waits for BUSY status of mdio bus to clear
  */
-#define WAIT_FOR_PHY(___rval)						\
-	while ((___rval = mace_eth_read(phy_data)) & MDIO_BUSY) {	\
-		udelay(25);						\
+#define WAIT_FOR_PHY(___rval)					\
+	while ((___rval = mace->eth.phy_data) & MDIO_BUSY) {	\
+		udelay(25);					\
 	}
 /*read phy register, return value read */
 static unsigned long mdio_read(struct meth_private *priv, unsigned long phyreg)
 {
 	unsigned long rval;
 	WAIT_FOR_PHY(rval);
-	mace_eth_write((priv->phy_addr << 5) | (phyreg & 0x1f), phy_regs);
+	mace->eth.phy_regs = (priv->phy_addr << 5) | (phyreg & 0x1f);
 	udelay(25);
-	mace_eth_write(1, phy_trans_go);
+	mace->eth.phy_trans_go = 1;
 	udelay(25);
 	WAIT_FOR_PHY(rval);
-	return rval&MDIO_DATA_MASK;
+	return rval & MDIO_DATA_MASK;
 }
 
 static int mdio_probe(struct meth_private *priv)
@@ -191,7 +191,7 @@
 			priv->mac_ctrl |= METH_PHY_FDX;
 		else
 			priv->mac_ctrl &= ~METH_PHY_FDX;
-		mace_eth_write(priv->mac_ctrl, mac_ctrl);
+		mace->eth.mac_ctrl = priv->mac_ctrl;
 	}
 
 	if ((priv->mac_ctrl & METH_100MBIT) ^ speed) {
@@ -200,7 +200,7 @@
 			priv->mac_ctrl |= METH_100MBIT;
 		else
 			priv->mac_ctrl &= ~METH_100MBIT;
-		mace_eth_write(priv->mac_ctrl, mac_ctrl);
+		mace->eth.mac_ctrl = priv->mac_ctrl;
 	}
 }
 
@@ -214,26 +214,28 @@
 		return -ENOMEM;
 	memset(priv->tx_ring, 0, TX_RING_BUFFER_SIZE);
 	priv->tx_count = priv->tx_read = priv->tx_write = 0;
-	mace_eth_write(priv->tx_ring_dma, tx_ring_base);
+	mace->eth.tx_ring_base = priv->tx_ring_dma;
 	/* Now init skb save area */
-	memset(priv->tx_skbs,0,sizeof(priv->tx_skbs));
-	memset(priv->tx_skb_dmas,0,sizeof(priv->tx_skb_dmas));
+	memset(priv->tx_skbs, 0, sizeof(priv->tx_skbs));
+	memset(priv->tx_skb_dmas, 0, sizeof(priv->tx_skb_dmas));
 	return 0;
 }
 
 static int meth_init_rx_ring(struct meth_private *priv)
 {
 	int i;
-	for(i=0;i<RX_RING_ENTRIES;i++){
-		priv->rx_skbs[i]=alloc_skb(METH_RX_BUFF_SIZE,0);
-		/* 8byte status vector+3quad padding + 2byte padding,
-		   to put data on 64bit aligned boundary */
+
+	for (i = 0; i < RX_RING_ENTRIES; i++) {
+		priv->rx_skbs[i] = alloc_skb(METH_RX_BUFF_SIZE, 0);
+		/* 8byte status vector + 3quad padding + 2byte padding,
+		 * to put data on 64bit aligned boundary */
 		skb_reserve(priv->rx_skbs[i],METH_RX_HEAD);
 		priv->rx_ring[i]=(rx_packet*)(priv->rx_skbs[i]->head);
 		/* I'll need to re-sync it after each RX */
-		priv->rx_ring_dmas[i]=dma_map_single(NULL,priv->rx_ring[i],
-						     METH_RX_BUFF_SIZE,DMA_FROM_DEVICE);
-		mace_eth_write(priv->rx_ring_dmas[i], rx_fifo);
+		priv->rx_ring_dmas[i] = 
+			dma_map_single(NULL, priv->rx_ring[i],
+				       METH_RX_BUFF_SIZE, DMA_FROM_DEVICE);
+		mace->eth.rx_fifo = priv->rx_ring_dmas[i];
 	}
         priv->rx_write = 0;
 	return 0;
@@ -257,10 +259,11 @@
 {
 	int i;
 
-	for(i=0;i<RX_RING_ENTRIES;i++) {
-		dma_unmap_single(NULL,priv->rx_ring_dmas[i],METH_RX_BUFF_SIZE,DMA_FROM_DEVICE);
-		priv->rx_ring[i]=0;
-		priv->rx_ring_dmas[i]=0;
+	for (i = 0; i < RX_RING_ENTRIES; i++) {
+		dma_unmap_single(NULL, priv->rx_ring_dmas[i],
+				 METH_RX_BUFF_SIZE, DMA_FROM_DEVICE);
+		priv->rx_ring[i] = 0;
+		priv->rx_ring_dmas[i] = 0;
 		kfree_skb(priv->rx_skbs[i]);
 	}
 }
@@ -270,8 +273,9 @@
 	struct meth_private *priv = (struct meth_private *) dev->priv;
 
 	/* Reset card */
-	mace_eth_write(SGI_MAC_RESET, mac_ctrl);
-	mace_eth_write(0, mac_ctrl);
+	mace->eth.mac_ctrl = SGI_MAC_RESET;
+	udelay(1);
+	mace->eth.mac_ctrl = 0;
 	udelay(25);
 
 	/* Load ethernet address */
@@ -279,24 +283,24 @@
 	/* Should load some "errata", but later */
 	
 	/* Check for device */
-	if(mdio_probe(priv) < 0) {
+	if (mdio_probe(priv) < 0) {
 		DPRINTK("Unable to find PHY\n");
 		return -ENODEV;
 	}
 
 	/* Initial mode: 10 | Half-duplex | Accept normal packets */
 	priv->mac_ctrl = METH_ACCEPT_MCAST | METH_DEFAULT_IPG;
-	if(dev->flags | IFF_PROMISC)
+	if (dev->flags | IFF_PROMISC)
 		priv->mac_ctrl |= METH_PROMISC;
-	mace_eth_write(priv->mac_ctrl, mac_ctrl);
+	mace->eth.mac_ctrl = priv->mac_ctrl;
 
 	/* Autonegotiate speed and duplex mode */
 	meth_check_link(dev);
 
 	/* Now set dma control, but don't enable DMA, yet */
-	priv->dma_ctrl= (4 << METH_RX_OFFSET_SHIFT) |
-		(RX_RING_ENTRIES << METH_RX_DEPTH_SHIFT);
-	mace_eth_write(priv->dma_ctrl, dma_ctrl);
+	priv->dma_ctrl = (4 << METH_RX_OFFSET_SHIFT) |
+			 (RX_RING_ENTRIES << METH_RX_DEPTH_SHIFT);
+	mace->eth.dma_ctrl = priv->dma_ctrl;
 
 	return 0;
 }
@@ -335,7 +339,7 @@
 	/* Start DMA */
 	priv->dma_ctrl |= METH_DMA_TX_EN | /*METH_DMA_TX_INT_EN |*/
 			  METH_DMA_RX_EN | METH_DMA_RX_INT_EN;
-	mace_eth_write(priv->dma_ctrl, dma_ctrl);
+	mace->eth.dma_ctrl = priv->dma_ctrl;
 
 	DPRINTK("About to start queue\n");
 	netif_start_queue(dev);
@@ -359,7 +363,7 @@
 	/* shut down DMA */
 	priv->dma_ctrl &= ~(METH_DMA_TX_EN | METH_DMA_TX_INT_EN |
 			    METH_DMA_RX_EN | METH_DMA_RX_INT_EN);
-	mace_eth_write(priv->dma_ctrl, dma_ctrl);
+	mace->eth.dma_ctrl = priv->dma_ctrl;
 	free_irq(dev->irq, dev);
 	meth_free_tx_ring(priv);
 	meth_free_rx_ring(priv);
@@ -373,56 +377,57 @@
 static void meth_rx(struct net_device* dev, unsigned long int_status)
 {
 	struct sk_buff *skb;
+	unsigned long status;
 	struct meth_private *priv = (struct meth_private *) dev->priv;
-	unsigned long fifo_rptr=(int_status&METH_INT_RX_RPTR_MASK)>>8;
+	unsigned long fifo_rptr = (int_status & METH_INT_RX_RPTR_MASK) >> 8;
+
 	spin_lock(&priv->meth_lock);
-	priv->dma_ctrl&=~METH_DMA_RX_INT_EN;
-	mace_eth_write(priv->dma_ctrl, dma_ctrl);
+	priv->dma_ctrl &= ~METH_DMA_RX_INT_EN;
+	mace->eth.dma_ctrl = priv->dma_ctrl;
 	spin_unlock(&priv->meth_lock);
 
-	if (int_status & METH_INT_RX_UNDERFLOW){
-		fifo_rptr=(fifo_rptr-1)&(0xF);
+	if (int_status & METH_INT_RX_UNDERFLOW) {
+		fifo_rptr = (fifo_rptr - 1) & 0x0f;
 	}
-	while(priv->rx_write != fifo_rptr) {
-		u64 status;
-		dma_unmap_single(NULL,priv->rx_ring_dmas[priv->rx_write],
-				 METH_RX_BUFF_SIZE,DMA_FROM_DEVICE);
-		status=priv->rx_ring[priv->rx_write]->status.raw;
+	while (priv->rx_write != fifo_rptr) {
+		dma_unmap_single(NULL, priv->rx_ring_dmas[priv->rx_write],
+				 METH_RX_BUFF_SIZE, DMA_FROM_DEVICE);
+		status = priv->rx_ring[priv->rx_write]->status.raw;
 #if MFE_DEBUG
-		if(!(status&METH_RX_ST_VALID)) {
+		if (!(status & METH_RX_ST_VALID)) {
 			DPRINTK("Not received? status=%016lx\n",status);
 		}
 #endif
-		if((!(status&METH_RX_STATUS_ERRORS))&&(status&METH_RX_ST_VALID)){
-			int len=(status&0xFFFF) - 4; /* omit CRC */
+		if ((!(status & METH_RX_STATUS_ERRORS)) && (status & METH_RX_ST_VALID)) {
+			int len = (status & 0xffff) - 4; /* omit CRC */
 			/* length sanity check */
-			if(len < 60 || len > 1518) {
-				printk(KERN_DEBUG "%s: bogus packet size: %d, status=%#2lx.\n",
+			if (len < 60 || len > 1518) {
+				printk(KERN_DEBUG "%s: bogus packet size: %ld, status=%#2lx.\n",
 				       dev->name, priv->rx_write,
 				       priv->rx_ring[priv->rx_write]->status.raw);
 				priv->stats.rx_errors++;
 				priv->stats.rx_length_errors++;
-				skb=priv->rx_skbs[priv->rx_write];
+				skb = priv->rx_skbs[priv->rx_write];
 			} else {
-				skb=alloc_skb(METH_RX_BUFF_SIZE,GFP_ATOMIC|GFP_DMA);
-				if(!skb){
+				skb = alloc_skb(METH_RX_BUFF_SIZE, GFP_ATOMIC | GFP_DMA);
+				if (!skb) {
 					/* Ouch! No memory! Drop packet on the floor */
 					DPRINTK("No mem: dropping packet\n");
 					priv->stats.rx_dropped++;
-					skb=priv->rx_skbs[priv->rx_write];
+					skb = priv->rx_skbs[priv->rx_write];
 				} else {
-					struct sk_buff *skb_c=priv->rx_skbs[priv->rx_write];
-					/* 8byte status vector+3quad padding + 2byte padding,
-					   to put data on 64bit aligned boundary */
-					skb_reserve(skb,METH_RX_HEAD);
+					struct sk_buff *skb_c = priv->rx_skbs[priv->rx_write];
+					/* 8byte status vector + 3quad padding + 2byte padding,
+					 * to put data on 64bit aligned boundary */
+					skb_reserve(skb, METH_RX_HEAD);
 					/* Write metadata, and then pass to the receive level */
-					skb_put(skb_c,len);
-					priv->rx_skbs[priv->rx_write]=skb;
+					skb_put(skb_c, len);
+					priv->rx_skbs[priv->rx_write] = skb;
 					skb_c->dev = dev;
 					skb_c->protocol = eth_type_trans(skb_c, dev);
 					dev->last_rx = jiffies;
 					priv->stats.rx_packets++;
-					priv->stats.rx_bytes+=len;
+					priv->stats.rx_bytes += len;
 					netif_rx(skb_c);
 				}
 			}
@@ -445,18 +450,19 @@
 				printk(KERN_WARNING "Carrier Event Seen\n");
 #endif
 		}
-		priv->rx_ring[priv->rx_write]=(rx_packet*)skb->head;
-		priv->rx_ring[priv->rx_write]->status.raw=0;
-		priv->rx_ring_dmas[priv->rx_write]=dma_map_single(NULL,priv->rx_ring[priv->rx_write],
-								  METH_RX_BUFF_SIZE,DMA_FROM_DEVICE);
-		mace_eth_write(priv->rx_ring_dmas[priv->rx_write], rx_fifo);
+		priv->rx_ring[priv->rx_write] = (rx_packet*)skb->head;
+		priv->rx_ring[priv->rx_write]->status.raw = 0;
+		priv->rx_ring_dmas[priv->rx_write] = 
+			dma_map_single(NULL, priv->rx_ring[priv->rx_write],
+				       METH_RX_BUFF_SIZE, DMA_FROM_DEVICE);
+		mace->eth.rx_fifo = priv->rx_ring_dmas[priv->rx_write];
 		ADVANCE_RX_PTR(priv->rx_write);
 	}
 	spin_lock(&priv->meth_lock);
 	/* In case there was underflow, and Rx DMA was disabled */
-	priv->dma_ctrl|=METH_DMA_RX_INT_EN|METH_DMA_RX_EN;
-	mace_eth_write(priv->dma_ctrl, dma_ctrl);
-	mace_eth_write(METH_INT_RX_THRESHOLD, int_stat);
+	priv->dma_ctrl |= METH_DMA_RX_INT_EN | METH_DMA_RX_EN;
+	mace->eth.dma_ctrl = priv->dma_ctrl;
+	mace->eth.int_stat = METH_INT_RX_THRESHOLD;
 	spin_unlock(&priv->meth_lock);
 }
 
@@ -464,31 +470,31 @@
 {
 	struct meth_private *priv = (struct meth_private *) dev->priv;
 
-	return(priv->tx_count >= TX_RING_ENTRIES-1);
+	return (priv->tx_count >= TX_RING_ENTRIES - 1);
 }
 
 static void meth_tx_cleanup(struct net_device* dev, unsigned long int_status)
 {
 	struct meth_private *priv = dev->priv;
-	u64 status;
+	unsigned long status;
 	struct sk_buff *skb;
-	unsigned long rptr=(int_status&TX_INFO_RPTR)>>16;
+	unsigned long rptr = (int_status&TX_INFO_RPTR) >> 16;
 
 	spin_lock(&priv->meth_lock);
 
 	/* Stop DMA notification */
 	priv->dma_ctrl &= ~(METH_DMA_TX_INT_EN);
-	mace_eth_write(priv->dma_ctrl, dma_ctrl);
+	mace->eth.dma_ctrl = priv->dma_ctrl;
 
-	while(priv->tx_read != rptr){
+	while (priv->tx_read != rptr) {
 		skb = priv->tx_skbs[priv->tx_read];
 		status = priv->tx_ring[priv->tx_read].header.raw;
 #if MFE_DEBUG>=1
-		if(priv->tx_read==priv->tx_write)
-			DPRINTK("Auchi! tx_read=%d,tx_write=%d,rptr=%d?\n",priv->tx_read,priv->tx_write,rptr);
+		if (priv->tx_read == priv->tx_write)
+			DPRINTK("Auchi! tx_read=%d,tx_write=%d,rptr=%d?\n", priv->tx_read, priv->tx_write,rptr);
 #endif
-		if(status & METH_TX_ST_DONE) {
-			if(status & METH_TX_ST_SUCCESS){
+		if (status & METH_TX_ST_DONE) {
+			if (status & METH_TX_ST_SUCCESS){
 				priv->stats.tx_packets++;
 				priv->stats.tx_bytes += skb->len;
 			} else {
@@ -518,19 +524,19 @@
 		priv->tx_skbs[priv->tx_read] = NULL;
 		priv->tx_ring[priv->tx_read].header.raw = 0;
 		priv->tx_read = (priv->tx_read+1)&(TX_RING_ENTRIES-1);
-		priv->tx_count --;
+		priv->tx_count--;
 	}
 
 	/* wake up queue if it was stopped */
-	if (netif_queue_stopped(dev) && ! meth_tx_full(dev)) {
+	if (netif_queue_stopped(dev) && !meth_tx_full(dev)) {
 		netif_wake_queue(dev);
 	}
 
-	mace_eth_write(METH_INT_TX_EMPTY | METH_INT_TX_PKT, int_stat);
+	mace->eth.int_stat = METH_INT_TX_EMPTY | METH_INT_TX_PKT;
 	spin_unlock(&priv->meth_lock);
 }
 
-static void meth_error(struct net_device* dev, u32 status)
+static void meth_error(struct net_device* dev, unsigned status)
 {
 	struct meth_private *priv = (struct meth_private *) dev->priv;
 
@@ -548,17 +554,16 @@
 	if (status & (METH_INT_RX_UNDERFLOW)) {
 		printk(KERN_WARNING "meth: Rx underflow\n");
 		spin_lock(&priv->meth_lock);
-		mace_eth_write(METH_INT_RX_UNDERFLOW, int_stat);
+		mace->eth.int_stat = METH_INT_RX_UNDERFLOW;
 		/* more underflow interrupts will be delivered, 
-		   effectively throwing us into an infinite loop.
-		   Thus I stop processing Rx in this case.
-		*/
-		priv->dma_ctrl&=~METH_DMA_RX_EN;
-		mace_eth_write(priv->dma_ctrl, dma_ctrl);
+		 * effectively throwing us into an infinite loop.
+		 *  Thus I stop processing Rx in this case. */
+		priv->dma_ctrl &= ~METH_DMA_RX_EN;
+		mace->eth.dma_ctrl = priv->dma_ctrl;
 		DPRINTK("Disabled meth Rx DMA temporarily\n");
 		spin_unlock(&priv->meth_lock);
 	}
-	mace_eth_write(METH_INT_ERROR, int_stat);
+	mace->eth.int_stat = METH_INT_ERROR;
 }
 
 /*
@@ -570,12 +575,12 @@
 	struct meth_private *priv = (struct meth_private *) dev->priv;
 	unsigned long status;
 
-	status = mace_eth_read(int_stat);
-	while (status & 0xFF) {
+	status = mace->eth.int_stat;
+	while (status & 0xff) {
 		/* First handle errors - if we get Rx underflow,
-		   Rx DMA will be disabled, and Rx handler will reenable
-		   it. I don't think it's possible to get Rx underflow,
-		   without getting Rx interrupt */
+		 * Rx DMA will be disabled, and Rx handler will reenable
+		 * it. I don't think it's possible to get Rx underflow,
+		 * without getting Rx interrupt */
 		if (status & METH_INT_ERROR) {
 			meth_error(dev, status);
 		}
@@ -589,7 +594,7 @@
 			/* send it to meth_rx for handling */
 			meth_rx(dev, status);
 		}
-		status = mace_eth_read(int_stat);
+		status = mace->eth.int_stat;
 	}
 
 	return IRQ_HANDLED;
@@ -601,45 +606,45 @@
 static void meth_tx_short_prepare(struct meth_private *priv,
 				  struct sk_buff *skb)
 {
-	tx_packet *desc=&priv->tx_ring[priv->tx_write];
-	int len = (skb->len<ETH_ZLEN)?ETH_ZLEN:skb->len;
+	tx_packet *desc = &priv->tx_ring[priv->tx_write];
+	int len = (skb->len < ETH_ZLEN) ? ETH_ZLEN : skb->len;
 
-	desc->header.raw=METH_TX_CMD_INT_EN|(len-1)|((128-len)<<16);
+	desc->header.raw = METH_TX_CMD_INT_EN | (len-1) | ((128-len) << 16);
 	/* maybe I should set whole thing to 0 first... */
-	memcpy(desc->data.dt+(120-len),skb->data,skb->len);
-	if(skb->len < len)
-		memset(desc->data.dt+120-len+skb->len,0,len-skb->len);
+	memcpy(desc->data.dt + (120 - len), skb->data, skb->len);
+	if (skb->len < len)
+		memset(desc->data.dt + 120 - len + skb->len, 0, len-skb->len);
 }
 #define TX_CATBUF1 BIT(25)
 static void meth_tx_1page_prepare(struct meth_private *priv,
 				  struct sk_buff *skb)
 {
-	tx_packet *desc=&priv->tx_ring[priv->tx_write];
+	tx_packet *desc = &priv->tx_ring[priv->tx_write];
 	void *buffer_data = (void *)(((unsigned long)skb->data + 7) & ~7);
 	int unaligned_len = (int)((unsigned long)buffer_data - (unsigned long)skb->data);
 	int buffer_len = skb->len - unaligned_len;
 	dma_addr_t catbuf;
 
-	desc->header.raw=METH_TX_CMD_INT_EN|TX_CATBUF1|(skb->len-1);
+	desc->header.raw = METH_TX_CMD_INT_EN | TX_CATBUF1 | (skb->len - 1);
 
 	/* unaligned part */
-	if(unaligned_len){
-		memcpy(desc->data.dt+(120-unaligned_len),
+	if (unaligned_len) {
+		memcpy(desc->data.dt + (120 - unaligned_len),
 		       skb->data, unaligned_len);
-		desc->header.raw |= (128-unaligned_len) << 16;
+		desc->header.raw |= (128 - unaligned_len) << 16;
 	}
 
 	/* first page */
 	catbuf = dma_map_single(NULL, buffer_data, buffer_len,
 				DMA_TO_DEVICE);
 	desc->data.cat_buf[0].form.start_addr = catbuf >> 3;
-	desc->data.cat_buf[0].form.len = buffer_len-1;
+	desc->data.cat_buf[0].form.len = buffer_len - 1;
 }
 #define TX_CATBUF2 BIT(26)
 static void meth_tx_2page_prepare(struct meth_private *priv,
 				  struct sk_buff *skb)
 {
-	tx_packet *desc=&priv->tx_ring[priv->tx_write];
+	tx_packet *desc = &priv->tx_ring[priv->tx_write];
 	void *buffer1_data = (void *)(((unsigned long)skb->data + 7) & ~7);
 	void *buffer2_data = (void *)PAGE_ALIGN((unsigned long)skb->data);
 	int unaligned_len = (int)((unsigned long)buffer1_data - (unsigned long)skb->data);
@@ -647,44 +652,44 @@
 	int buffer2_len = skb->len - buffer1_len - unaligned_len;
 	dma_addr_t catbuf1, catbuf2;
 
-	desc->header.raw=METH_TX_CMD_INT_EN|TX_CATBUF1|TX_CATBUF2|(skb->len-1);
+	desc->header.raw = METH_TX_CMD_INT_EN | TX_CATBUF1 | TX_CATBUF2| (skb->len - 1);
 	/* unaligned part */
-	if(unaligned_len){
-		memcpy(desc->data.dt+(120-unaligned_len),
+	if (unaligned_len){
+		memcpy(desc->data.dt + (120 - unaligned_len),
 		       skb->data, unaligned_len);
-		desc->header.raw |= (128-unaligned_len) << 16;
+		desc->header.raw |= (128 - unaligned_len) << 16;
 	}
 
 	/* first page */
 	catbuf1 = dma_map_single(NULL, buffer1_data, buffer1_len,
 				 DMA_TO_DEVICE);
 	desc->data.cat_buf[0].form.start_addr = catbuf1 >> 3;
-	desc->data.cat_buf[0].form.len = buffer1_len-1;
+	desc->data.cat_buf[0].form.len = buffer1_len - 1;
 	/* second page */
 	catbuf2 = dma_map_single(NULL, buffer2_data, buffer2_len,
 				 DMA_TO_DEVICE);
 	desc->data.cat_buf[1].form.start_addr = catbuf2 >> 3;
-	desc->data.cat_buf[1].form.len = buffer2_len-1;
+	desc->data.cat_buf[1].form.len = buffer2_len - 1;
 }
 
 static void meth_add_to_tx_ring(struct meth_private *priv, struct sk_buff *skb)
 {
 	/* Remember the skb, so we can free it at interrupt time */
 	priv->tx_skbs[priv->tx_write] = skb;
-	if(skb->len <= 120) {
+	if (skb->len <= 120) {
 		/* Whole packet fits into descriptor */
-		meth_tx_short_prepare(priv,skb);
-	} else if(PAGE_ALIGN((unsigned long)skb->data) !=
-		  PAGE_ALIGN((unsigned long)skb->data+skb->len-1)) {
+		meth_tx_short_prepare(priv, skb);
+	} else if (PAGE_ALIGN((unsigned long)skb->data) !=
+		   PAGE_ALIGN((unsigned long)skb->data + skb->len - 1)) {
 		/* Packet crosses page boundary */
-		meth_tx_2page_prepare(priv,skb);
+		meth_tx_2page_prepare(priv, skb);
 	} else {
 		/* Packet is in one page */
-		meth_tx_1page_prepare(priv,skb);
+		meth_tx_1page_prepare(priv, skb);
 	}
-	priv->tx_write = (priv->tx_write+1) & (TX_RING_ENTRIES-1);
-	mace_eth_write(priv->tx_write, tx_info);
-	priv->tx_count ++;
+	priv->tx_write = (priv->tx_write + 1) & (TX_RING_ENTRIES - 1);
+	mace->eth.tx_info = priv->tx_write;
+	priv->tx_count++;
 }
 
 /*
@@ -695,10 +700,10 @@
 	struct meth_private *priv = (struct meth_private *) dev->priv;
 	unsigned long flags;
 
-	spin_lock_irqsave(&priv->meth_lock,flags);
+	spin_lock_irqsave(&priv->meth_lock, flags);
 	/* Stop DMA notification */
 	priv->dma_ctrl &= ~(METH_DMA_TX_INT_EN);
-	mace_eth_write(priv->dma_ctrl, dma_ctrl);
+	mace->eth.dma_ctrl = priv->dma_ctrl;
 
 	meth_add_to_tx_ring(priv, skb);
 	dev->trans_start = jiffies; /* save the timestamp */
@@ -711,9 +716,9 @@
 
 	/* Restart DMA notification */
 	priv->dma_ctrl |= METH_DMA_TX_INT_EN;
-	mace_eth_write(priv->dma_ctrl, dma_ctrl);
+	mace->eth.dma_ctrl = priv->dma_ctrl;
 
-	spin_unlock_irqrestore(&priv->meth_lock,flags);
+	spin_unlock_irqrestore(&priv->meth_lock, flags);
 
 	return 0;
 }
@@ -743,11 +748,11 @@
 	meth_init_rx_ring(priv);
 
 	/* Restart dma */
-	priv->dma_ctrl|=METH_DMA_TX_EN|METH_DMA_RX_EN|METH_DMA_RX_INT_EN;
-	mace_eth_write(priv->dma_ctrl, dma_ctrl);
+	priv->dma_ctrl |= METH_DMA_TX_EN | METH_DMA_RX_EN | METH_DMA_RX_INT_EN;
+	mace->eth.dma_ctrl = priv->dma_ctrl;
 
 	/* Enable interrupt */
-	spin_unlock_irqrestore(&priv->meth_lock,flags);
+	spin_unlock_irqrestore(&priv->meth_lock, flags);
 
 	dev->trans_start = jiffies;
 	netif_wake_queue(dev);
@@ -760,8 +765,14 @@
  */
 static int meth_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	DPRINTK("ioctl\n");
-	return 0;
+	/* XXX Not yet implemented */
+	switch(cmd) { 
+	case SIOCGMIIPHY:
+	case SIOCGMIIREG:
+	case SIOCSMIIREG:
+	default:
+		return -EOPNOTSUPP;
+	}
 }
 
 /*
@@ -808,7 +819,7 @@
 	}
 
 	printk(KERN_INFO "%s: SGI MACE Ethernet rev. %d\n",
-	       dev->name, (unsigned int)mace_eth_read(mac_ctrl) >> 29);
+	       dev->name, (unsigned int)(mace->eth.mac_ctrl >> 29));
 	return 0;
 }
 
diff -Nru a/drivers/net/meth.h b/drivers/net/meth.h
--- a/drivers/net/meth.h	2005-03-06 18:36:50 -05:00
+++ b/drivers/net/meth.h	2005-03-06 18:36:50 -05:00
@@ -29,7 +29,7 @@
 #define RX_BUCKET_SIZE 256
 
 #undef BIT
-#define BIT(x)	(1 << (x))
+#define BIT(x)	(1UL << (x))
 
 /* For more detailed explanations of what each field menas,
    see Nick's great comments to #defines below (or docs, if
diff -Nru a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
--- a/drivers/net/mv643xx_eth.c	2005-03-06 18:36:50 -05:00
+++ b/drivers/net/mv643xx_eth.c	2005-03-06 18:36:50 -05:00
@@ -1349,13 +1349,11 @@
 
 #ifdef MV64340_CHECKSUM_OFFLOAD_TX
 #ifdef MAX_SKB_FRAGS
-#ifndef CONFIG_JAGUAR_DMALOW
         /*
          * Zero copy can only work if we use Discovery II memory. Else, we will
          * have to map the buffers to ISA memory which is only 16 MB
          */
         dev->features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_HW_CSUM;
-#endif
 #endif
 #endif
 
diff -Nru a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
--- a/drivers/net/pcnet32.c	2005-03-06 18:36:50 -05:00
+++ b/drivers/net/pcnet32.c	2005-03-06 18:36:50 -05:00
@@ -1429,25 +1429,36 @@
 	val |= 0x10;
     lp->a.write_csr (ioaddr, 124, val);
 
-    /* 24 Jun 2004 according AMD, in order to change the PHY,
-     * DANAS (or DISPM for 79C976) must be set; then select the speed,
-     * duplex, and/or enable auto negotiation, and clear DANAS */
-    if (lp->mii && !(lp->options & PCNET32_PORT_ASEL)) {
-	lp->a.write_bcr(ioaddr, 32, lp->a.read_bcr(ioaddr, 32) | 0x0080);
-	/* disable Auto Negotiation, set 10Mpbs, HD */
-	val = lp->a.read_bcr(ioaddr, 32) & ~0xb8;
-	if (lp->options & PCNET32_PORT_FD)
-	    val |= 0x10;
-	if (lp->options & PCNET32_PORT_100)
-	    val |= 0x08;
-	lp->a.write_bcr (ioaddr, 32, val);
+    /* Allied Telesyn AT 2700/2701 FX looses the link, so skip that */
+    if (lp->pci_dev->subsystem_vendor == PCI_VENDOR_ID_AT &&
+        (lp->pci_dev->subsystem_device == PCI_SUBDEVICE_ID_AT_2700FX ||
+	 lp->pci_dev->subsystem_device == PCI_SUBDEVICE_ID_AT_2701FX)) {
+	printk(KERN_DEBUG "%s: Skipping PHY selection.\n", dev->name);
     } else {
-	if (lp->options & PCNET32_PORT_ASEL) {
-	    lp->a.write_bcr(ioaddr, 32, lp->a.read_bcr(ioaddr, 32) | 0x0080);
-	    /* enable auto negotiate, setup, disable fd */
-	    val = lp->a.read_bcr(ioaddr, 32) & ~0x98;
-	    val |= 0x20;
-	    lp->a.write_bcr(ioaddr, 32, val);
+	/*
+	 * 24 Jun 2004 according AMD, in order to change the PHY,
+	 * DANAS (or DISPM for 79C976) must be set; then select the speed,
+	 * duplex, and/or enable auto negotiation, and clear DANAS
+	 */
+	if (lp->mii && !(lp->options & PCNET32_PORT_ASEL)) {
+	    lp->a.write_bcr(ioaddr, 32,
+				lp->a.read_bcr(ioaddr, 32) | 0x0080);
+	    /* disable Auto Negotiation, set 10Mpbs, HD */
+	    val = lp->a.read_bcr(ioaddr, 32) & ~0xb8;
+	    if (lp->options & PCNET32_PORT_FD)
+		val |= 0x10;
+	    if (lp->options & PCNET32_PORT_100)
+		val |= 0x08;
+	    lp->a.write_bcr (ioaddr, 32, val);
+	} else {
+	    if (lp->options & PCNET32_PORT_ASEL) {
+		lp->a.write_bcr(ioaddr, 32,
+			lp->a.read_bcr(ioaddr, 32) | 0x0080);
+		/* enable auto negotiate, setup, disable fd */
+		val = lp->a.read_bcr(ioaddr, 32) & ~0x98;
+		val |= 0x20;
+		lp->a.write_bcr(ioaddr, 32, val);
+	    }
 	}
     }
 
diff -Nru a/drivers/net/s2io.c b/drivers/net/s2io.c
--- a/drivers/net/s2io.c	2005-03-06 18:36:50 -05:00
+++ b/drivers/net/s2io.c	2005-03-06 18:36:50 -05:00
@@ -36,28 +36,29 @@
  * in PCI Configuration space.
  ************************************************************************/
 
-#include<linux/config.h>
-#include<linux/module.h>
-#include<linux/types.h>
-#include<linux/errno.h>
-#include<linux/ioport.h>
-#include<linux/pci.h>
-#include<linux/kernel.h>
-#include<linux/netdevice.h>
-#include<linux/etherdevice.h>
-#include<linux/skbuff.h>
-#include<linux/init.h>
-#include<linux/delay.h>
-#include<linux/stddef.h>
-#include<linux/ioctl.h>
-#include<linux/timex.h>
-#include<linux/sched.h>
-#include<linux/ethtool.h>
-#include<asm/system.h>
-#include<asm/uaccess.h>
-#include<linux/version.h>
-#include<asm/io.h>
-#include<linux/workqueue.h>
+#include <linux/config.h>
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/errno.h>
+#include <linux/ioport.h>
+#include <linux/pci.h>
+#include <linux/kernel.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+#include <linux/init.h>
+#include <linux/delay.h>
+#include <linux/stddef.h>
+#include <linux/ioctl.h>
+#include <linux/timex.h>
+#include <linux/sched.h>
+#include <linux/ethtool.h>
+#include <linux/version.h>
+#include <linux/workqueue.h>
+
+#include <asm/io.h>
+#include <asm/system.h>
+#include <asm/uaccess.h>
 
 /* local include */
 #include "s2io.h"
diff -Nru a/drivers/net/sb1250-mac.c b/drivers/net/sb1250-mac.c
--- a/drivers/net/sb1250-mac.c	2005-03-06 18:36:50 -05:00
+++ b/drivers/net/sb1250-mac.c	2005-03-06 18:36:50 -05:00
@@ -14,47 +14,11 @@
  * You should have received a copy of the GNU General Public License
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+ *
+ *
+ * This driver is designed for the Broadcom SiByte SOC built-in
+ * Ethernet controllers. Written by Mitch Lichtenberg at Broadcom Corp.
  */
-
-/*
-  This driver is designed for the Broadcom SiByte SOC built-in
-  Ethernet controllers.
-  
-  Written by Mitch Lichtenberg at Broadcom Corp.
-*/
-
-
-
-#define CONFIG_SBMAC_COALESCE
-
-/* A few user-configurable values.
-   These may be modified when a driver module is loaded. */
-
-static int debug = 1;			/* 1 normal messages, 0 quiet .. 7 verbose. */
-static int noisy_mii = 1;		/* mii status msgs */
-
-/* Used to pass the media type, etc.
-   Both 'options[]' and 'full_duplex[]' should exist for driver
-   interoperability.
-   The media type is usually passed in 'options[]'.
-*/
-
-#define MAX_UNITS 3		/* More are supported, limit only on options */
-#ifdef MODULE
-static int options[MAX_UNITS] = {-1, -1, -1};
-static int full_duplex[MAX_UNITS] = {-1, -1, -1};
-#endif
-
-#ifdef CONFIG_SBMAC_COALESCE
-static int int_pktcnt = 0;
-static int int_timeout = 0;
-#endif
-
-/* Operational parameters that usually are not changed. */
-
-/* Time in jiffies before concluding the transmitter is hung. */
-#define TX_TIMEOUT  (2*HZ)
-
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
@@ -89,16 +53,56 @@
 #endif
 
 
+/* Operational parameters that usually are not changed. */
+
+#define CONFIG_SBMAC_COALESCE
+
+#define MAX_UNITS 3		/* More are supported, limit only on options */
+
+/* Time in jiffies before concluding the transmitter is hung. */
+#define TX_TIMEOUT  (2*HZ)
+
 
 MODULE_AUTHOR("Mitch Lichtenberg (Broadcom Corp.)");
 MODULE_DESCRIPTION("Broadcom SiByte SOC GB Ethernet driver");
-MODULE_PARM(debug, "i");
-MODULE_PARM(noisy_mii, "i");
-MODULE_PARM(options, "1-" __MODULE_STRING(MAX_UNITS) "i");
-MODULE_PARM(full_duplex, "1-" __MODULE_STRING(MAX_UNITS) "i");
 
-MODULE_PARM(int_pktcnt, "i");
-MODULE_PARM(int_timeout, "i");
+/* A few user-configurable values which may be modified when a driver
+   module is loaded. */
+
+/* 1 normal messages, 0 quiet .. 7 verbose. */
+static int debug = 1;
+module_param(debug, int, S_IRUGO);
+MODULE_PARM_DESC(debug, "Debug messages");
+
+/* mii status msgs */
+static int noisy_mii = 1;
+module_param(noisy_mii, int, S_IRUGO);
+MODULE_PARM_DESC(noisy_mii, "MII status messages");
+
+/* Used to pass the media type, etc.
+   Both 'options[]' and 'full_duplex[]' should exist for driver
+   interoperability.
+   The media type is usually passed in 'options[]'.
+*/
+#ifdef MODULE
+static int options[MAX_UNITS] = {-1, -1, -1};
+module_param_array(options, int, NULL, S_IRUGO);
+MODULE_PARM_DESC(options, "1-" __MODULE_STRING(MAX_UNITS));
+
+static int full_duplex[MAX_UNITS] = {-1, -1, -1};
+module_param_array(full_duplex, int, NULL, S_IRUGO);
+MODULE_PARM_DESC(full_duplex, "1-" __MODULE_STRING(MAX_UNITS));
+#endif
+
+#ifdef CONFIG_SBMAC_COALESCE
+static int int_pktcnt = 0;
+module_param(int_pktcnt, int, S_IRUGO);
+MODULE_PARM_DESC(int_pktcnt, "Packet count");
+
+static int int_timeout = 0;
+module_param(int_timeout, int, S_IRUGO);
+MODULE_PARM_DESC(int_timeout, "Timeout value");
+#endif
 
 #include <asm/sibyte/sb1250.h>
 #include <asm/sibyte/sb1250_defs.h>
@@ -1811,8 +1815,6 @@
 	
 	/* read system identification to determine revision */
 	if (periph_rev >= 2) {
-		printk(KERN_INFO "%s: enabling TCP rcv checksum\n",
-		       sc->sbm_dev->name);
 		sc->rx_hw_checksum = ENABLE;
 	} else {
 		sc->rx_hw_checksum = DISABLE;
@@ -2417,6 +2419,11 @@
 	if (err)
 		goto out_uninit;
 
+	if (periph_rev >= 2) {
+		printk(KERN_INFO "%s: enabling TCP rcv checksum\n",
+			sc->sbm_dev->name);
+	}
+
 	/*
 	 * Display Ethernet address (this is called during the config
 	 * process so we need to finish off the config message that
@@ -2879,12 +2886,12 @@
 		dev->mem_end = 0;
 		if (sbmac_init(dev, idx)) {
 			port = A_MAC_CHANNEL_BASE(idx);
-			SBMAC_WRITECSR(KSEG1ADDR(port+R_MAC_ETHERNET_ADDR),
-					sbmac_orig_hwaddr[idx] );
+			SBMAC_WRITECSR(IOADDR(port+R_MAC_ETHERNET_ADDR),
+				       sbmac_orig_hwaddr[idx]);
 			free_netdev(dev);
 			continue;
 		}
-		dev_sbmac[idx++] = dev;
+		dev_sbmac[idx] = dev;
 	}
 	return 0;
 }
diff -Nru a/drivers/net/sgiseeq.c b/drivers/net/sgiseeq.c
--- a/drivers/net/sgiseeq.c	2005-03-06 18:36:50 -05:00
+++ b/drivers/net/sgiseeq.c	2005-03-06 18:36:50 -05:00
@@ -136,9 +136,10 @@
 	hregs->rx_ctrl = HPC3_ERXCTRL_ACTIVE;
 }
 
-static inline void seeq_load_eaddr(struct net_device *dev,
-				   struct sgiseeq_regs *sregs)
+static inline void __sgiseeq_set_mac_address(struct net_device *dev)
 {
+	struct sgiseeq_private *sp = netdev_priv(dev);
+	struct sgiseeq_regs *sregs = sp->sregs;
 	int i;
 
 	sregs->tstat = SEEQ_TCMD_RB0;
@@ -146,6 +147,20 @@
 		sregs->rw.eth_addr[i] = dev->dev_addr[i];
 }
 
+static int sgiseeq_set_mac_address(struct net_device *dev, void *addr)
+{
+	struct sgiseeq_private *sp = netdev_priv(dev);
+	struct sockaddr *sa = addr;
+
+	memcpy(dev->dev_addr, sa->sa_data, dev->addr_len);
+
+	spin_lock_irq(&sp->tx_lock);
+	__sgiseeq_set_mac_address(dev);
+	spin_unlock_irq(&sp->tx_lock);
+
+	return 0;
+}
+
 #define TCNTINFO_INIT (HPCDMA_EOX | HPCDMA_ETXD)
 #define RCNTCFG_INIT  (HPCDMA_OWN | HPCDMA_EORP | HPCDMA_XIE)
 #define RCNTINFO_INIT (RCNTCFG_INIT | (PKT_BUF_SZ & HPCDMA_BCNT))
@@ -159,13 +174,7 @@
 	sp->rx_new = sp->tx_new = 0;
 	sp->rx_old = sp->tx_old = 0;
 
-	seeq_load_eaddr(dev, sp->sregs);
-
-	/* XXX for now just accept packets directly to us
-	 * XXX and ether-broadcast.  Will do multicast and
-	 * XXX promiscuous mode later. -davem
-	 */
-	sp->mode = SEEQ_RCMD_RBCAST;
+	__sgiseeq_set_mac_address(dev);
 
 	/* Setup tx ring. */
 	for(i = 0; i < SEEQ_TX_BUFFERS; i++) {
@@ -175,7 +184,7 @@
 			buffer = (unsigned long) kmalloc(PKT_BUF_SZ, GFP_KERNEL);
 			if (!buffer)
 				return -ENOMEM;
-			sp->tx_desc[i].buf_vaddr = KSEG1ADDR(buffer);
+			sp->tx_desc[i].buf_vaddr = CKSEG1ADDR(buffer);
 			sp->tx_desc[i].tdma.pbuf = CPHYSADDR(buffer);
 		}
 		sp->tx_desc[i].tdma.cntinfo = TCNTINFO_INIT;
@@ -189,7 +198,7 @@
 			buffer = (unsigned long) kmalloc(PKT_BUF_SZ, GFP_KERNEL);
 			if (!buffer)
 				return -ENOMEM;
-			sp->rx_desc[i].buf_vaddr = KSEG1ADDR(buffer);
+			sp->rx_desc[i].buf_vaddr = CKSEG1ADDR(buffer);
 			sp->rx_desc[i].rdma.pbuf = CPHYSADDR(buffer);
 		}
 		sp->rx_desc[i].rdma.cntinfo = RCNTINFO_INIT;
@@ -331,10 +340,17 @@
 				/* Copy out of kseg1 to avoid silly cache flush. */
 				eth_copy_and_sum(skb, pkt_pointer + 2, len, 0);
 				skb->protocol = eth_type_trans(skb, dev);
-				netif_rx(skb);
-				dev->last_rx = jiffies;
-				sp->stats.rx_packets++;
-				sp->stats.rx_bytes += len;
+
+				/* We don't want to receive our own packets */
+				if (memcmp(eth_hdr(skb)->h_source, dev->dev_addr, ETH_ALEN)) {
+					netif_rx(skb);
+					dev->last_rx = jiffies;
+					sp->stats.rx_packets++;
+					sp->stats.rx_bytes += len;
+				} else {
+					/* Silently drop my own packets */
+					dev_kfree_skb_irq(skb);
+				}
 			} else {
 				printk (KERN_NOTICE "%s: Memory squeeze, deferring packet.\n",
 					dev->name);
@@ -373,7 +389,7 @@
 	 */
 	while ((td->tdma.cntinfo & (HPCDMA_XIU | HPCDMA_ETXD)) ==
 	      (HPCDMA_XIU | HPCDMA_ETXD))
-		td = (struct sgiseeq_tx_desc *)(long) KSEG1ADDR(td->tdma.pnext);
+		td = (struct sgiseeq_tx_desc *)(long) CKSEG1ADDR(td->tdma.pnext);
 	if (td->tdma.cntinfo & HPCDMA_XIU) {
 		hregs->tx_ndptr = CPHYSADDR(td);
 		hregs->tx_ctrl = HPC3_ETXCTRL_ACTIVE;
@@ -583,6 +599,22 @@
 
 static void sgiseeq_set_multicast(struct net_device *dev)
 {
+	struct sgiseeq_private *sp = (struct sgiseeq_private *) dev->priv;
+	unsigned char oldmode = sp->mode;
+
+	if(dev->flags & IFF_PROMISC)
+		sp->mode = SEEQ_RCMD_RANY;
+	else if ((dev->flags & IFF_ALLMULTI) || dev->mc_count)
+		sp->mode = SEEQ_RCMD_RBMCAST;
+	else
+		sp->mode = SEEQ_RCMD_RBCAST;
+
+	/* XXX I know this sucks, but is there a better way to reprogram
+	 * XXX the receiver? At least, this shouldn't happen too often.
+	 */
+
+	if (oldmode != sp->mode)
+		sgiseeq_reset(dev);
 }
 
 static inline void setup_tx_ring(struct sgiseeq_tx_desc *buf, int nbufs)
@@ -651,13 +683,14 @@
 	sp->sregs = (struct sgiseeq_regs *) &hpc3c0->eth_ext[0];
 	sp->hregs = &hpc3c0->ethregs;
 	sp->name = sgiseeqstr;
+	sp->mode = SEEQ_RCMD_RBCAST;
 
 	sp->rx_desc = (struct sgiseeq_rx_desc *)
-	              KSEG1ADDR(ALIGNED(&sp->srings->rxvector[0]));
+	              CKSEG1ADDR(ALIGNED(&sp->srings->rxvector[0]));
 	dma_cache_wback_inv((unsigned long)&sp->srings->rxvector,
 	                    sizeof(sp->srings->rxvector));
 	sp->tx_desc = (struct sgiseeq_tx_desc *)
-	              KSEG1ADDR(ALIGNED(&sp->srings->txvector[0]));
+	              CKSEG1ADDR(ALIGNED(&sp->srings->txvector[0]));
 	dma_cache_wback_inv((unsigned long)&sp->srings->txvector,
 	                    sizeof(sp->srings->txvector));
 
@@ -681,6 +714,7 @@
 	dev->watchdog_timeo	= (200 * HZ) / 1000;
 	dev->get_stats		= sgiseeq_get_stats;
 	dev->set_multicast_list	= sgiseeq_set_multicast;
+	dev->set_mac_address	= sgiseeq_set_mac_address;
 	dev->irq		= irq;
 
 	if (register_netdev(dev)) {
diff -Nru a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
--- a/drivers/net/sk98lin/skge.c	2005-03-06 18:36:50 -05:00
+++ b/drivers/net/sk98lin/skge.c	2005-03-06 18:36:50 -05:00
@@ -5152,6 +5152,8 @@
 	{ 0, }
 };
 
+MODULE_DEVICE_TABLE(pci, skge_pci_tbl);
+
 static struct pci_driver skge_driver = {
 	.name		= "skge",
 	.id_table	= skge_pci_tbl,
diff -Nru a/drivers/net/sonic.c b/drivers/net/sonic.c
--- a/drivers/net/sonic.c	2005-03-06 18:36:50 -05:00
+++ b/drivers/net/sonic.c	2005-03-06 18:36:50 -05:00
@@ -116,7 +116,7 @@
 	/*
 	 * Map the packet data into the logical DMA address space
 	 */
-	if ((laddr = vdma_alloc(PHYSADDR(skb->data), skb->len)) == ~0UL) {
+	if ((laddr = vdma_alloc(CPHYSADDR(skb->data), skb->len)) == ~0UL) {
 		printk("%s: no VDMA entry for transmit available.\n",
 		       dev->name);
 		dev_kfree_skb(skb);
@@ -223,7 +223,7 @@
 
 			/* We must free the original skb */
 			if (lp->tx_skb[entry]) {
-				dev_kfree_skb(lp->tx_skb[entry]);
+				dev_kfree_skb_irq(lp->tx_skb[entry]);
 				lp->tx_skb[entry] = 0;
 			}
 			/* and the VDMA address */
diff -Nru a/drivers/net/wan/Kconfig b/drivers/net/wan/Kconfig
--- a/drivers/net/wan/Kconfig	2005-03-06 18:36:50 -05:00
+++ b/drivers/net/wan/Kconfig	2005-03-06 18:36:50 -05:00
@@ -155,7 +155,8 @@
 	  Network) card supported by this driver and you are planning to
 	  connect the box to a WAN.
 
-	  You will need supporting software from <http://hq.pm.waw.pl/hdlc/>.
+	  You will need supporting software from
+	  <http://www.kernel.org/pub/linux/utils/net/hdlc/>.
 	  Generic HDLC driver currently supports raw HDLC, Cisco HDLC, Frame
 	  Relay, synchronous Point-to-Point Protocol (PPP) and X.25.
 
@@ -225,7 +226,7 @@
 	  Driver for PCI200SYN cards by Goramo sp. j.
 
 	  If you have such a card, say Y here and see
-	  <http://hq.pm.waw.pl/hdlc/>.
+	  <http://www.kernel.org/pub/linux/utils/net/hdlc/>.
 
 	  To compile this as a module, choose M here: the
 	  module will be called pci200syn.
@@ -239,7 +240,7 @@
 	  Driver for wanXL PCI cards by SBE Inc.
 
 	  If you have such a card, say Y here and see
-	  <http://hq.pm.waw.pl/hdlc/>.
+	  <http://www.kernel.org/pub/linux/utils/net/hdlc/>.
 
 	  To compile this as a module, choose M here: the
 	  module will be called wanxl.
@@ -292,7 +293,7 @@
 	  SDL Communications Inc.
 
 	  If you have such a card, say Y here and see
-	  <http://hq.pm.waw.pl/hdlc/>.
+	  <http://www.kernel.org/pub/linux/utils/net/hdlc/>.
 
 	  Note that N2csu and N2dds cards are not supported by this driver.
 
@@ -308,7 +309,7 @@
 	  Driver for C101 SuperSync ISA cards by Moxa Technologies Co., Ltd.
 
 	  If you have such a card, say Y here and see
-	  <http://hq.pm.waw.pl/pub/hdlc/>
+	  <http://www.kernel.org/pub/linux/utils/net/hdlc/>.
 
 	  To compile this driver as a module, choose M here: the
 	  module will be called c101.
diff -Nru a/drivers/net/wan/hd6457x.c b/drivers/net/wan/hd6457x.c
--- a/drivers/net/wan/hd6457x.c	2005-03-06 18:36:50 -05:00
+++ b/drivers/net/wan/hd6457x.c	2005-03-06 18:36:50 -05:00
@@ -315,7 +315,7 @@
 #endif
 	stats->rx_packets++;
 	stats->rx_bytes += skb->len;
-	skb->dev->last_rx = jiffies;
+	dev->last_rx = jiffies;
 	skb->protocol = hdlc_type_trans(skb, dev);
 	netif_rx(skb);
 }
diff -Nru a/drivers/net/wan/z85230.c b/drivers/net/wan/z85230.c
--- a/drivers/net/wan/z85230.c	2005-03-06 18:36:50 -05:00
+++ b/drivers/net/wan/z85230.c	2005-03-06 18:36:50 -05:00
@@ -734,7 +734,7 @@
 	u8 intr;
 	static volatile int locker=0;
 	int work=0;
-	struct z8530_irqhandler *irqs=dev->chanA.irqs;
+	struct z8530_irqhandler *irqs;
 	
 	if(locker)
 	{
@@ -758,6 +758,8 @@
 		/* Now walk the chip and see what it is wanting - it may be
 		   an IRQ for someone else remember */
 		   
+		irqs=dev->chanA.irqs;
+
 		if(intr & (CHARxIP|CHATxIP|CHAEXT))
 		{
 			if(intr&CHARxIP)
diff -Nru a/include/linux/pci_ids.h b/include/linux/pci_ids.h
--- a/include/linux/pci_ids.h	2005-03-06 18:36:50 -05:00
+++ b/include/linux/pci_ids.h	2005-03-06 18:36:50 -05:00
@@ -1656,6 +1656,11 @@
 #define PCI_DEVICE_ID_OPTIBASE_VPLEXCC	0x2120
 #define PCI_DEVICE_ID_OPTIBASE_VQUEST	0x2130
 
+/* Allied Telesyn */
+#define PCI_VENDOR_ID_AT    		0x1259
+#define PCI_SUBDEVICE_ID_AT_2700FX	0x2701
+#define PCI_SUBDEVICE_ID_AT_2701FX	0x2703
+
 #define PCI_VENDOR_ID_ESS		0x125d
 #define PCI_DEVICE_ID_ESS_ESS1968	0x1968
 #define PCI_DEVICE_ID_ESS_AUDIOPCI	0x1969

--------------030602010205090106010908--
