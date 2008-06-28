From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver updates for .27
Date: Sat, 28 Jun 2008 11:09:42 -0400
Message-ID: <20080628150941.GA14018@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:46259 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753211AbYF1PJn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Jun 2008 11:09:43 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is rebased and updated from the last pull.  The lone change:
dropped retina driver, as it needs further work.

Please pull from 'davem-next' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git dave=
m-next

to receive the following updates:

 Documentation/networking/dm9000.txt             |  167 ++++
 arch/blackfin/mach-bf527/boards/ezkit.c         |    7 +-
 arch/blackfin/mach-bf533/boards/H8606.c         |    7 +-
 arch/blackfin/mach-bf537/boards/generic_board.c |    7 +-
 drivers/net/8139cp.c                            |    1 -
 drivers/net/8139too.c                           |   13 +-
 drivers/net/Kconfig                             |   31 +-
 drivers/net/cxgb3/cxgb3_offload.c               |   21 +-
 drivers/net/cxgb3/t3cdev.h                      |    3 +-
 drivers/net/dl2k.c                              |    2 +-
 drivers/net/dm9000.c                            | 1159 ++++++++++++---=
--------
 drivers/net/dm9000.h                            |   11 +
 drivers/net/e1000/e1000_main.c                  |   34 -
 drivers/net/e1000e/e1000.h                      |    4 +
 drivers/net/e1000e/netdev.c                     |   48 +-
 drivers/net/fealnx.c                            |   43 +-
 drivers/net/forcedeth.c                         |    5 +
 drivers/net/igb/igb.h                           |    4 +
 drivers/net/igb/igb_main.c                      |   47 +-
 drivers/net/ixgbe/ixgbe.h                       |    9 +
 drivers/net/ixgbe/ixgbe_ethtool.c               |   11 +
 drivers/net/ixgbe/ixgbe_main.c                  |  111 ++-
 drivers/net/pci-skeleton.c                      |    1 -
 drivers/net/sh_eth.c                            |    4 +-
 drivers/net/sh_eth.h                            |    4 +-
 drivers/net/tsi108_eth.c                        |    1 -
 drivers/net/tulip/21142.c                       |    6 +-
 drivers/net/tulip/de2104x.c                     |   10 +-
 drivers/net/tulip/eeprom.c                      |    6 +-
 drivers/net/tulip/interrupt.c                   |    5 +-
 drivers/net/tulip/media.c                       |    5 +-
 drivers/net/tulip/pnic.c                        |    5 +-
 drivers/net/tulip/pnic2.c                       |    5 +-
 drivers/net/tulip/timer.c                       |    6 +-
 drivers/net/tulip/tulip.h                       |    4 +-
 drivers/net/tulip/tulip_core.c                  |    8 +-
 drivers/net/typhoon.c                           |    3 -
 drivers/net/usb/rndis_host.c                    |   14 +-
 drivers/net/wireless/rndis_wlan.c               |    4 +-
 drivers/pci/pci-acpi.c                          |   20 +
 include/linux/dm9000.h                          |    1 +
 include/linux/usb/rndis_host.h                  |    3 +-
 42 files changed, 1122 insertions(+), 738 deletions(-)
 create mode 100644 Documentation/networking/dm9000.txt

Andy Gospodarek (1):
      e1000: remove e1000_clean_tx_irq call from e1000_netpoll

Auke Kok (1):
      e1000: remove PCI Express device IDs

Ben Dooks (10):
      DM9000: Add support for DM9000A and DM9000B chips
      DM9000: Cleanups after the resource changes
      DM9000: Cleanup source code
      DM9000: Cleanup source code - remove forward declerations
      DM9000: Use NSR to determine link-status on internal PHY
      DM9000: Allow the use of the NSR register to get link status.
      DM9000: Add missing msleep() in EEPROM wait code.
      DM9000: Re-unite menuconfig entries for DM9000 driver
      DM9000: Remove DEFAULT_TRIGGER for request_irq() flags.
      DM9000: Add documentation for the driver.

Divy Le Ray (1):
      cxgb3 - add missing adapter type for RDMA

Grant Grundler (1):
      drivers/net/tulip: update first comment in tulip files

Harvey Harrison (1):
      tulip: remove wrapper around get_unaligned

Jeff Garzik (2):
      [netdrvr] fealnx: clean up nasty mess of arch ifdefs
      [netdrvr] kill sync_irq-before-freq_irq pattern

Jussi Kivilinna (1):
      rndis_host: pass buffer length to rndis_command

Laurent Pinchart (2):
      DM9000: Remove the 2 resources probe scheme.
      DM9000: Fixup blackfin after removing 2 resource usage

Mallikarjuna R Chilakala (1):
      ixgbe: add LRO support

M=E1rton N=E9meth (1):
      8139too: some style cleanups

Nobuhiro Iwamatsu (1):
      net: sh_eth: Fix compile error sh_eth

Taku Izumi (2):
      e1000e: make ioport free
      igb: make ioport free

Tobias Diedrich (2):
      Fix forcedeth hibernate/wake-on-lan problems
      Fix forcedeth hibernate/wake-on-lan problems

diff --git a/Documentation/networking/dm9000.txt b/Documentation/networ=
king/dm9000.txt
new file mode 100644
index 0000000..65df3de
--- /dev/null
+++ b/Documentation/networking/dm9000.txt
@@ -0,0 +1,167 @@
+DM9000 Network driver
+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
+
+Copyright 2008 Simtec Electronics,
+	  Ben Dooks <ben@simtec.co.uk> <ben-linux@fluff.org>
+
+
+Introduction
+------------
+
+This file describes how to use the DM9000 platform-device based networ=
k driver
+that is contained in the files drivers/net/dm9000.c and drivers/net/dm=
9000.h.
+
+The driver supports three DM9000 variants, the DM9000E which is the fi=
rst chip
+supported as well as the newer DM9000A and DM9000B devices. It is curr=
ently
+maintained and tested by Ben Dooks, who should be CC: to any patches f=
or this
+driver.
+
+
+Defining the platform device
+----------------------------
+
+The minimum set of resources attached to the platform device are as fo=
llows:
+
+    1) The physical address of the address register
+    2) The physical address of the data register
+    3) The IRQ line the device's interrupt pin is connected to.
+
+These resources should be specified in that order, as the ordering of =
the
+two address regions is important (the driver expects these to be addre=
ss
+and then data).
+
+An example from arch/arm/mach-s3c2410/mach-bast.c is:
+
+static struct resource bast_dm9k_resource[] =3D {
+	[0] =3D {
+		.start =3D S3C2410_CS5 + BAST_PA_DM9000,
+		.end   =3D S3C2410_CS5 + BAST_PA_DM9000 + 3,
+		.flags =3D IORESOURCE_MEM,
+	},
+	[1] =3D {
+		.start =3D S3C2410_CS5 + BAST_PA_DM9000 + 0x40,
+		.end   =3D S3C2410_CS5 + BAST_PA_DM9000 + 0x40 + 0x3f,
+		.flags =3D IORESOURCE_MEM,
+	},
+	[2] =3D {
+		.start =3D IRQ_DM9000,
+		.end   =3D IRQ_DM9000,
+		.flags =3D IORESOURCE_IRQ | IORESOURCE_IRQ_HIGHLEVEL,
+	}
+};
+
+static struct platform_device bast_device_dm9k =3D {
+	.name		=3D "dm9000",
+	.id		=3D 0,
+	.num_resources	=3D ARRAY_SIZE(bast_dm9k_resource),
+	.resource	=3D bast_dm9k_resource,
+};
+
+Note the setting of the IRQ trigger flag in bast_dm9k_resource[2].flag=
s,
+as this will generate a warning if it is not present. The trigger from
+the flags field will be passed to request_irq() when registering the I=
RQ
+handler to ensure that the IRQ is setup correctly.
+
+This shows a typical platform device, without the optional configurati=
on
+platform data supplied. The next example uses the same resources, but =
adds
+the optional platform data to pass extra configuration data:
+
+static struct dm9000_plat_data bast_dm9k_platdata =3D {
+	.flags		=3D DM9000_PLATF_16BITONLY,
+};
+
+static struct platform_device bast_device_dm9k =3D {
+	.name		=3D "dm9000",
+	.id		=3D 0,
+	.num_resources	=3D ARRAY_SIZE(bast_dm9k_resource),
+	.resource	=3D bast_dm9k_resource,
+	.dev		=3D {
+		.platform_data =3D &bast_dm9k_platdata,
+	}
+};
+
+The platform data is defined in include/linux/dm9000.h and described b=
elow.
+
+
+Platform data
+-------------
+
+Extra platform data for the DM9000 can describe the IO bus width to th=
e
+device, whether or not an external PHY is attached to the device and
+the availability of an external configuration EEPROM.
+
+The flags for the platform data .flags field are as follows:
+
+DM9000_PLATF_8BITONLY
+
+	The IO should be done with 8bit operations.
+
+DM9000_PLATF_16BITONLY
+
+	The IO should be done with 16bit operations.
+
+DM9000_PLATF_32BITONLY
+
+	The IO should be done with 32bit operations.
+
+DM9000_PLATF_EXT_PHY
+
+	The chip is connected to an external PHY.
+
+DM9000_PLATF_NO_EEPROM
+
+	This can be used to signify that the board does not have an
+	EEPROM, or that the EEPROM should be hidden from the user.
+
+DM9000_PLATF_SIMPLE_PHY
+
+	Switch to using the simpler PHY polling method which does not
+	try and read the MII PHY state regularly. This is only available
+	when using the internal PHY. See the section on link state polling
+	for more information.
+
+	The config symbol DM9000_FORCE_SIMPLE_PHY_POLL, Kconfig entry
+	"Force simple NSR based PHY polling" allows this flag to be
+	forced on at build time.
+
+
+PHY Link state polling
+----------------------
+
+The driver keeps track of the link state and informs the network core
+about link (carrier) availablilty. This is managed by several methods
+depending on the version of the chip and on which PHY is being used.
+
+For the internal PHY, the original (and currently default) method is
+to read the MII state, either when the status changes if we have the
+necessary interrupt support in the chip or every two seconds via a
+periodic timer.
+
+To reduce the overhead for the internal PHY, there is now the option
+of using the DM9000_FORCE_SIMPLE_PHY_POLL config, or DM9000_PLATF_SIMP=
LE_PHY
+platform data option to read the summary information without the
+expensive MII accesses. This method is faster, but does not print
+as much information.
+
+When using an external PHY, the driver currently has to poll the MII
+link status as there is no method for getting an interrupt on link cha=
nge.
+
+
+DM9000A / DM9000B
+-----------------
+
+These chips are functionally similar to the DM9000E and are supported =
easily
+by the same driver. The features are:
+
+   1) Interrupt on internal PHY state change. This means that the peri=
odic
+      polling of the PHY status may be disabled on these devices when =
using
+      the internal PHY.
+
+   2) TCP/UDP checksum offloading, which the driver does not currently=
 support.
+
+
+ethtool
+-------
+
+The driver supports the ethtool interface for access to the driver
+state information, the PHY state and the EEPROM.
diff --git a/arch/blackfin/mach-bf527/boards/ezkit.c b/arch/blackfin/ma=
ch-bf527/boards/ezkit.c
index 5958eec..689b69c 100644
--- a/arch/blackfin/mach-bf527/boards/ezkit.c
+++ b/arch/blackfin/mach-bf527/boards/ezkit.c
@@ -323,10 +323,15 @@ static struct platform_device smc91x_device =3D {
 static struct resource dm9000_resources[] =3D {
 	[0] =3D {
 		.start	=3D 0x203FB800,
-		.end	=3D 0x203FB800 + 8,
+		.end	=3D 0x203FB800 + 1,
 		.flags	=3D IORESOURCE_MEM,
 	},
 	[1] =3D {
+		.start	=3D 0x203FB800 + 4,
+		.end	=3D 0x203FB800 + 5,
+		.flags	=3D IORESOURCE_MEM,
+	},
+	[2] =3D {
 		.start	=3D IRQ_PF9,
 		.end	=3D IRQ_PF9,
 		.flags	=3D (IORESOURCE_IRQ | IORESOURCE_IRQ_HIGHEDGE),
diff --git a/arch/blackfin/mach-bf533/boards/H8606.c b/arch/blackfin/ma=
ch-bf533/boards/H8606.c
index 7cc4864..4103a97 100644
--- a/arch/blackfin/mach-bf533/boards/H8606.c
+++ b/arch/blackfin/mach-bf533/boards/H8606.c
@@ -65,10 +65,15 @@ static struct platform_device rtc_device =3D {
 static struct resource dm9000_resources[] =3D {
 	[0] =3D {
 		.start	=3D 0x20300000,
-		.end	=3D 0x20300000 + 8,
+		.end	=3D 0x20300000 + 1,
 		.flags	=3D IORESOURCE_MEM,
 	},
 	[1] =3D {
+		.start	=3D 0x20300000 + 4,
+		.end	=3D 0x20300000 + 5,
+		.flags	=3D IORESOURCE_MEM,
+	},
+	[2] =3D {
 		.start	=3D IRQ_PF10,
 		.end	=3D IRQ_PF10,
 		.flags	=3D (IORESOURCE_IRQ | IORESOURCE_IRQ_HIGHEDGE),
diff --git a/arch/blackfin/mach-bf537/boards/generic_board.c b/arch/bla=
ckfin/mach-bf537/boards/generic_board.c
index 7d25082..01b63e2 100644
--- a/arch/blackfin/mach-bf537/boards/generic_board.c
+++ b/arch/blackfin/mach-bf537/boards/generic_board.c
@@ -166,10 +166,15 @@ static struct platform_device smc91x_device =3D {
 static struct resource dm9000_resources[] =3D {
 	[0] =3D {
 		.start	=3D 0x203FB800,
-		.end	=3D 0x203FB800 + 8,
+		.end	=3D 0x203FB800 + 1,
 		.flags	=3D IORESOURCE_MEM,
 	},
 	[1] =3D {
+		.start	=3D 0x203FB800 + 4,
+		.end	=3D 0x203FB800 + 5,
+		.flags	=3D IORESOURCE_MEM,
+	},
+	[2] =3D {
 		.start	=3D IRQ_PF9,
 		.end	=3D IRQ_PF9,
 		.flags	=3D (IORESOURCE_IRQ | IORESOURCE_IRQ_HIGHEDGE),
diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index 934db35..6011d6f 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -1213,7 +1213,6 @@ static int cp_close (struct net_device *dev)
=20
 	spin_unlock_irqrestore(&cp->lock, flags);
=20
-	synchronize_irq(dev->irq);
 	free_irq(dev->irq, dev);
=20
 	cp_free_rings(cp);
diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index b23a00c..75317a1 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -107,8 +107,8 @@
 #include <linux/mii.h>
 #include <linux/completion.h>
 #include <linux/crc32.h>
-#include <asm/io.h>
-#include <asm/uaccess.h>
+#include <linux/io.h>
+#include <linux/uaccess.h>
 #include <asm/irq.h>
=20
 #define RTL8139_DRIVER_NAME   DRV_NAME " Fast Ethernet driver " DRV_VE=
RSION
@@ -134,7 +134,7 @@
=20
 #if RTL8139_DEBUG
 /* note: prints function name for you */
-#  define DPRINTK(fmt, args...) printk(KERN_DEBUG "%s: " fmt, __FUNCTI=
ON__ , ## args)
+#  define DPRINTK(fmt, args...) printk(KERN_DEBUG "%s: " fmt, __func__=
 , ## args)
 #else
 #  define DPRINTK(fmt, args...)
 #endif
@@ -145,7 +145,7 @@
 #  define assert(expr) \
         if(unlikely(!(expr))) {				        \
         printk(KERN_ERR "Assertion failed! %s,%s,%s,line=3D%d\n",	\
-        #expr,__FILE__,__FUNCTION__,__LINE__);		        \
+	#expr, __FILE__, __func__, __LINE__);			\
         }
 #endif
=20
@@ -219,7 +219,7 @@ enum {
 #define RTL8139B_IO_SIZE 256
=20
 #define RTL8129_CAPS	HAS_MII_XCVR
-#define RTL8139_CAPS	HAS_CHIP_XCVR|HAS_LNK_CHNG
+#define RTL8139_CAPS	(HAS_CHIP_XCVR|HAS_LNK_CHNG)
=20
 typedef enum {
 	RTL8139 =3D 0,
@@ -1889,7 +1889,7 @@ static void rtl8139_rx_err (u32 rx_status, struct=
 net_device *dev,
 }
=20
 #if RX_BUF_IDX =3D=3D 3
-static __inline__ void wrap_copy(struct sk_buff *skb, const unsigned c=
har *ring,
+static inline void wrap_copy(struct sk_buff *skb, const unsigned char =
*ring,
 				 u32 offset, unsigned int size)
 {
 	u32 left =3D RX_BUF_LEN - offset;
@@ -2231,7 +2231,6 @@ static int rtl8139_close (struct net_device *dev)
=20
 	spin_unlock_irqrestore (&tp->lock, flags);
=20
-	synchronize_irq (dev->irq);	/* racy, but that's ok here */
 	free_irq (dev->irq, dev);
=20
 	rtl8139_tx_clear (tp);
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 287d087..d85b9d0 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -938,6 +938,23 @@ config DM9000
 	  To compile this driver as a module, choose M here.  The module
 	  will be called dm9000.
=20
+config DM9000_DEBUGLEVEL
+	int "DM9000 maximum debug level"
+	depends on DM9000
+	default 4
+	help
+	  The maximum level of debugging code compiled into the DM9000
+	  driver.
+
+config DM9000_FORCE_SIMPLE_PHY_POLL
+	bool "Force simple NSR based PHY polling"
+	depends on DM9000
+	---help---
+	  This configuration forces the DM9000 to use the NSR's LinkStatus
+	  bit to determine if the link is up or down instead of the more
+	  costly MII PHY reads. Note, this will not work if the chip is
+	  operating with an external PHY.
+
 config ENC28J60
 	tristate "ENC28J60 support"
 	depends on EXPERIMENTAL && SPI && NET_ETHERNET
@@ -955,14 +972,6 @@ config ENC28J60_WRITEVERIFY
 	  Enable the verify after the buffer write useful for debugging purpo=
se.
 	  If unsure, say N.
=20
-config DM9000_DEBUGLEVEL
-	int "DM9000 maximum debug level"
-	depends on DM9000
-	default 4
-	help
-	  The maximum level of debugging code compiled into the DM9000
-	  driver.
-
 config SMC911X
 	tristate "SMSC LAN911[5678] support"
 	select CRC32
@@ -2025,9 +2034,6 @@ config E1000E
 	  To compile this driver as a module, choose M here. The module
 	  will be called e1000e.
=20
-config E1000E_ENABLED
-	def_bool E1000E !=3D n
-
 config IP1000
 	tristate "IP1000 Gigabit Ethernet support"
 	depends on PCI && EXPERIMENTAL
@@ -2462,7 +2468,8 @@ config EHEA
=20
 config IXGBE
 	tristate "Intel(R) 10GbE PCI Express adapters support"
-	depends on PCI
+	depends on PCI && INET
+	select INET_LRO
 	---help---
 	  This driver supports Intel(R) 10GbE PCI Express family of
 	  adapters.  For more information on how to identify your adapter, go
diff --git a/drivers/net/cxgb3/cxgb3_offload.c b/drivers/net/cxgb3/cxgb=
3_offload.c
index ff9c013..ae6ff5d 100644
--- a/drivers/net/cxgb3/cxgb3_offload.c
+++ b/drivers/net/cxgb3/cxgb3_offload.c
@@ -1248,6 +1248,25 @@ static inline void unregister_tdev(struct t3cdev=
 *tdev)
 	mutex_unlock(&cxgb3_db_lock);
 }
=20
+static inline int adap2type(struct adapter *adapter)
+{
+	int type =3D 0;
+
+	switch (adapter->params.rev) {
+	case T3_REV_A:
+		type =3D T3A;
+		break;
+	case T3_REV_B:
+	case T3_REV_B2:
+		type =3D T3B;
+		break;
+	case T3_REV_C:
+		type =3D T3C;
+		break;
+	}
+	return type;
+}
+
 void __devinit cxgb3_adapter_ofld(struct adapter *adapter)
 {
 	struct t3cdev *tdev =3D &adapter->tdev;
@@ -1257,7 +1276,7 @@ void __devinit cxgb3_adapter_ofld(struct adapter =
*adapter)
 	cxgb3_set_dummy_ops(tdev);
 	tdev->send =3D t3_offload_tx;
 	tdev->ctl =3D cxgb_offload_ctl;
-	tdev->type =3D adapter->params.rev =3D=3D 0 ? T3A : T3B;
+	tdev->type =3D adap2type(adapter);
=20
 	register_tdev(tdev);
 }
diff --git a/drivers/net/cxgb3/t3cdev.h b/drivers/net/cxgb3/t3cdev.h
index a18c8a1..8556628 100644
--- a/drivers/net/cxgb3/t3cdev.h
+++ b/drivers/net/cxgb3/t3cdev.h
@@ -45,7 +45,8 @@ struct cxgb3_client;
=20
 enum t3ctype {
 	T3A =3D 0,
-	T3B
+	T3B,
+	T3C,
 };
=20
 struct t3cdev {
diff --git a/drivers/net/dl2k.c b/drivers/net/dl2k.c
index 8277e89..f803711 100644
--- a/drivers/net/dl2k.c
+++ b/drivers/net/dl2k.c
@@ -1753,7 +1753,7 @@ rio_close (struct net_device *dev)
=20
 	/* Stop Tx and Rx logics */
 	writel (TxDisable | RxDisable | StatsDisable, ioaddr + MACCtrl);
-	synchronize_irq (dev->irq);
+
 	free_irq (dev->irq, dev);
 	del_timer_sync (&np->timer);
=20
diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index 08a7365..952e10d 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -44,9 +44,8 @@
=20
 #define DM9000_PHY		0x40	/* PHY address 0x01 */
=20
-#define CARDNAME "dm9000"
-#define PFX CARDNAME ": "
-#define DRV_VERSION	"1.30"
+#define CARDNAME	"dm9000"
+#define DRV_VERSION	"1.31"
=20
 #ifdef CONFIG_BLACKFIN
 #define readsb	insb
@@ -55,9 +54,6 @@
 #define writesb	outsb
 #define writesw	outsw
 #define writesl	outsl
-#define DEFAULT_TRIGGER IRQF_TRIGGER_HIGH
-#else
-#define DEFAULT_TRIGGER (0)
 #endif
=20
 /*
@@ -85,23 +81,36 @@ MODULE_PARM_DESC(watchdog, "transmit timeout in mil=
liseconds");
  * these two devices.
  */
=20
+/* The driver supports the original DM9000E, and now the two newer
+ * devices, DM9000A and DM9000B.
+ */
+
+enum dm9000_type {
+	TYPE_DM9000E,	/* original DM9000 */
+	TYPE_DM9000A,
+	TYPE_DM9000B
+};
+
 /* Structure/enum declaration ------------------------------- */
 typedef struct board_info {
=20
-	void __iomem *io_addr;	/* Register I/O base address */
-	void __iomem *io_data;	/* Data I/O address */
-	u16 irq;		/* IRQ */
+	void __iomem	*io_addr;	/* Register I/O base address */
+	void __iomem	*io_data;	/* Data I/O address */
+	u16		 irq;		/* IRQ */
=20
-	u16 tx_pkt_cnt;
-	u16 queue_pkt_len;
-	u16 queue_start_addr;
-	u16 dbug_cnt;
-	u8 io_mode;		/* 0:word, 2:byte */
-	u8 phy_addr;
-	unsigned int flags;
-	unsigned int in_suspend :1;
+	u16		tx_pkt_cnt;
+	u16		queue_pkt_len;
+	u16		queue_start_addr;
+	u16		dbug_cnt;
+	u8		io_mode;		/* 0:word, 2:byte */
+	u8		phy_addr;
+	u8		imr_all;
=20
-	int debug_level;
+	unsigned int	flags;
+	unsigned int	in_suspend :1;
+	int		debug_level;
+
+	enum dm9000_type type;
=20
 	void (*inblk)(void __iomem *port, void *data, int length);
 	void (*outblk)(void __iomem *port, void *data, int length);
@@ -120,10 +129,10 @@ typedef struct board_info {
 	struct delayed_work phy_poll;
 	struct net_device  *ndev;
=20
-	spinlock_t lock;
+	spinlock_t	lock;
=20
 	struct mii_if_info mii;
-	u32 msg_enable;
+	u32		msg_enable;
 } board_info_t;
=20
 /* debug code */
@@ -140,26 +149,6 @@ static inline board_info_t *to_dm9000_board(struct=
 net_device *dev)
 	return dev->priv;
 }
=20
-/* function declaration ------------------------------------- */
-static int dm9000_probe(struct platform_device *);
-static int dm9000_open(struct net_device *);
-static int dm9000_start_xmit(struct sk_buff *, struct net_device *);
-static int dm9000_stop(struct net_device *);
-static int dm9000_ioctl(struct net_device *dev, struct ifreq *req, int=
 cmd);
-
-static void dm9000_init_dm9000(struct net_device *);
-
-static irqreturn_t dm9000_interrupt(int, void *);
-
-static int dm9000_phy_read(struct net_device *dev, int phyaddr_unsused=
, int reg);
-static void dm9000_phy_write(struct net_device *dev, int phyaddr_unuse=
d, int reg,
-			   int value);
-
-static void dm9000_read_eeprom(board_info_t *, int addr, u8 *to);
-static void dm9000_write_eeprom(board_info_t *, int addr, u8 *dp);
-static void dm9000_rx(struct net_device *);
-static void dm9000_hash_table(struct net_device *);
-
 /* DM9000 network board routine ---------------------------- */
=20
 static void
@@ -302,52 +291,135 @@ static void dm9000_set_io(struct board_info *db,=
 int byte_width)
=20
 static void dm9000_schedule_poll(board_info_t *db)
 {
-	schedule_delayed_work(&db->phy_poll, HZ * 2);
+	if (db->type =3D=3D TYPE_DM9000E)
+		schedule_delayed_work(&db->phy_poll, HZ * 2);
 }
=20
-/* Our watchdog timed out. Called by the networking layer */
-static void dm9000_timeout(struct net_device *dev)
+static int dm9000_ioctl(struct net_device *dev, struct ifreq *req, int=
 cmd)
+{
+	board_info_t *dm =3D to_dm9000_board(dev);
+
+	if (!netif_running(dev))
+		return -EINVAL;
+
+	return generic_mii_ioctl(&dm->mii, if_mii(req), cmd, NULL);
+}
+
+static unsigned int
+dm9000_read_locked(board_info_t *db, int reg)
 {
-	board_info_t *db =3D (board_info_t *) dev->priv;
-	u8 reg_save;
 	unsigned long flags;
+	unsigned int ret;
=20
-	/* Save previous register address */
-	reg_save =3D readb(db->io_addr);
-	spin_lock_irqsave(&db->lock,flags);
+	spin_lock_irqsave(&db->lock, flags);
+	ret =3D ior(db, reg);
+	spin_unlock_irqrestore(&db->lock, flags);
=20
-	netif_stop_queue(dev);
-	dm9000_reset(db);
-	dm9000_init_dm9000(dev);
-	/* We can accept TX packets again */
-	dev->trans_start =3D jiffies;
-	netif_wake_queue(dev);
+	return ret;
+}
=20
-	/* Restore previous register address */
-	writeb(reg_save, db->io_addr);
-	spin_unlock_irqrestore(&db->lock,flags);
+static int dm9000_wait_eeprom(board_info_t *db)
+{
+	unsigned int status;
+	int timeout =3D 8;	/* wait max 8msec */
+
+	/* The DM9000 data sheets say we should be able to
+	 * poll the ERRE bit in EPCR to wait for the EEPROM
+	 * operation. From testing several chips, this bit
+	 * does not seem to work.
+	 *
+	 * We attempt to use the bit, but fall back to the
+	 * timeout (which is why we do not return an error
+	 * on expiry) to say that the EEPROM operation has
+	 * completed.
+	 */
+
+	while (1) {
+		status =3D dm9000_read_locked(db, DM9000_EPCR);
+
+		if ((status & EPCR_ERRE) =3D=3D 0)
+			break;
+
+		msleep(1);
+
+		if (timeout-- < 0) {
+			dev_dbg(db->dev, "timeout waiting EEPROM\n");
+			break;
+		}
+	}
+
+	return 0;
 }
=20
-#ifdef CONFIG_NET_POLL_CONTROLLER
 /*
- *Used by netconsole
+ *  Read a word data from EEPROM
  */
-static void dm9000_poll_controller(struct net_device *dev)
+static void
+dm9000_read_eeprom(board_info_t *db, int offset, u8 *to)
 {
-	disable_irq(dev->irq);
-	dm9000_interrupt(dev->irq,dev);
-	enable_irq(dev->irq);
+	unsigned long flags;
+
+	if (db->flags & DM9000_PLATF_NO_EEPROM) {
+		to[0] =3D 0xff;
+		to[1] =3D 0xff;
+		return;
+	}
+
+	mutex_lock(&db->addr_lock);
+
+	spin_lock_irqsave(&db->lock, flags);
+
+	iow(db, DM9000_EPAR, offset);
+	iow(db, DM9000_EPCR, EPCR_ERPRR);
+
+	spin_unlock_irqrestore(&db->lock, flags);
+
+	dm9000_wait_eeprom(db);
+
+	/* delay for at-least 150uS */
+	msleep(1);
+
+	spin_lock_irqsave(&db->lock, flags);
+
+	iow(db, DM9000_EPCR, 0x0);
+
+	to[0] =3D ior(db, DM9000_EPDRL);
+	to[1] =3D ior(db, DM9000_EPDRH);
+
+	spin_unlock_irqrestore(&db->lock, flags);
+
+	mutex_unlock(&db->addr_lock);
 }
-#endif
=20
-static int dm9000_ioctl(struct net_device *dev, struct ifreq *req, int=
 cmd)
+/*
+ * Write a word data to SROM
+ */
+static void
+dm9000_write_eeprom(board_info_t *db, int offset, u8 *data)
 {
-	board_info_t *dm =3D to_dm9000_board(dev);
+	unsigned long flags;
=20
-	if (!netif_running(dev))
-		return -EINVAL;
+	if (db->flags & DM9000_PLATF_NO_EEPROM)
+		return;
=20
-	return generic_mii_ioctl(&dm->mii, if_mii(req), cmd, NULL);
+	mutex_lock(&db->addr_lock);
+
+	spin_lock_irqsave(&db->lock, flags);
+	iow(db, DM9000_EPAR, offset);
+	iow(db, DM9000_EPDRH, data[1]);
+	iow(db, DM9000_EPDRL, data[0]);
+	iow(db, DM9000_EPCR, EPCR_WEP | EPCR_ERPRW);
+	spin_unlock_irqrestore(&db->lock, flags);
+
+	dm9000_wait_eeprom(db);
+
+	mdelay(1);	/* wait at least 150uS to clear */
+
+	spin_lock_irqsave(&db->lock, flags);
+	iow(db, DM9000_EPCR, 0);
+	spin_unlock_irqrestore(&db->lock, flags);
+
+	mutex_unlock(&db->addr_lock);
 }
=20
 /* ethtool ops */
@@ -400,7 +472,14 @@ static int dm9000_nway_reset(struct net_device *de=
v)
 static u32 dm9000_get_link(struct net_device *dev)
 {
 	board_info_t *dm =3D to_dm9000_board(dev);
-	return mii_link_ok(&dm->mii);
+	u32 ret;
+
+	if (dm->flags & DM9000_PLATF_EXT_PHY)
+		ret =3D mii_link_ok(&dm->mii);
+	else
+		ret =3D dm9000_read_locked(dm, DM9000_NSR) & NSR_LINKST ? 1 : 0;
+
+	return ret;
 }
=20
 #define DM_EEPROM_MAGIC		(0x444D394B)
@@ -472,15 +551,48 @@ static const struct ethtool_ops dm9000_ethtool_op=
s =3D {
  	.set_eeprom		=3D dm9000_set_eeprom,
 };
=20
+static void dm9000_show_carrier(board_info_t *db,
+				unsigned carrier, unsigned nsr)
+{
+	struct net_device *ndev =3D db->ndev;
+	unsigned ncr =3D dm9000_read_locked(db, DM9000_NCR);
+
+	if (carrier)
+		dev_info(db->dev, "%s: link up, %dMbps, %s-duplex, no LPA\n",
+			 ndev->name, (nsr & NSR_SPEED) ? 10 : 100,
+			 (ncr & NCR_FDX) ? "full" : "half");
+	else
+		dev_info(db->dev, "%s: link down\n", ndev->name);
+}
+
 static void
 dm9000_poll_work(struct work_struct *w)
 {
 	struct delayed_work *dw =3D container_of(w, struct delayed_work, work=
);
 	board_info_t *db =3D container_of(dw, board_info_t, phy_poll);
+	struct net_device *ndev =3D db->ndev;
+
+	if (db->flags & DM9000_PLATF_SIMPLE_PHY &&
+	    !(db->flags & DM9000_PLATF_EXT_PHY)) {
+		unsigned nsr =3D dm9000_read_locked(db, DM9000_NSR);
+		unsigned old_carrier =3D netif_carrier_ok(ndev) ? 1 : 0;
+		unsigned new_carrier;
=20
-	mii_check_media(&db->mii, netif_msg_link(db), 0);
+		new_carrier =3D (nsr & NSR_LINKST) ? 1 : 0;
+
+		if (old_carrier !=3D new_carrier) {
+			if (netif_msg_link(db))
+				dm9000_show_carrier(db, new_carrier, nsr);
+
+			if (!new_carrier)
+				netif_carrier_off(ndev);
+			else
+				netif_carrier_on(ndev);
+		}
+	} else
+		mii_check_media(&db->mii, netif_msg_link(db), 0);
 =09
-	if (netif_running(db->ndev))
+	if (netif_running(ndev))
 		dm9000_schedule_poll(db);
 }
=20
@@ -492,12 +604,6 @@ dm9000_poll_work(struct work_struct *w)
 static void
 dm9000_release_board(struct platform_device *pdev, struct board_info *=
db)
 {
-	if (db->data_res =3D=3D NULL) {
-		if (db->addr_res !=3D NULL)
-			release_mem_region((unsigned long)db->io_addr, 4);
-		return;
-	}
-
 	/* unmap our resources */
=20
 	iounmap(db->io_addr);
@@ -505,288 +611,73 @@ dm9000_release_board(struct platform_device *pde=
v, struct board_info *db)
=20
 	/* release the resources */
=20
-	if (db->data_req !=3D NULL) {
-		release_resource(db->data_req);
-		kfree(db->data_req);
-	}
+	release_resource(db->data_req);
+	kfree(db->data_req);
=20
-	if (db->addr_req !=3D NULL) {
-		release_resource(db->addr_req);
-		kfree(db->addr_req);
-	}
+	release_resource(db->addr_req);
+	kfree(db->addr_req);
 }
=20
-#define res_size(_r) (((_r)->end - (_r)->start) + 1)
-
-/*
- * Search DM9000 board, allocate space and register it
- */
-static int __devinit
-dm9000_probe(struct platform_device *pdev)
+static unsigned char dm9000_type_to_char(enum dm9000_type type)
 {
-	struct dm9000_plat_data *pdata =3D pdev->dev.platform_data;
-	struct board_info *db;	/* Point a board information structure */
-	struct net_device *ndev;
-	const unsigned char *mac_src;
-	unsigned long base;
-	int ret =3D 0;
-	int iosize;
-	int i;
-	u32 id_val;
-
-	/* Init network device */
-	ndev =3D alloc_etherdev(sizeof (struct board_info));
-	if (!ndev) {
-		dev_err(&pdev->dev, "could not allocate device.\n");
-		return -ENOMEM;
-	}
-
-	SET_NETDEV_DEV(ndev, &pdev->dev);
-
-	dev_dbg(&pdev->dev, "dm9000_probe()\n");
-
-	/* setup board info structure */
-	db =3D (struct board_info *) ndev->priv;
-	memset(db, 0, sizeof (*db));
-
-	db->dev =3D &pdev->dev;
-	db->ndev =3D ndev;
-
-	spin_lock_init(&db->lock);
-	mutex_init(&db->addr_lock);
-
-	INIT_DELAYED_WORK(&db->phy_poll, dm9000_poll_work);
-
-
-	if (pdev->num_resources < 2) {
-		ret =3D -ENODEV;
-		goto out;
-	} else if (pdev->num_resources =3D=3D 2) {
-		base =3D pdev->resource[0].start;
-
-		if (!request_mem_region(base, 4, ndev->name)) {
-			ret =3D -EBUSY;
-			goto out;
-		}
-
-		ndev->base_addr =3D base;
-		ndev->irq =3D pdev->resource[1].start;
-		db->io_addr =3D (void __iomem *)base;
-		db->io_data =3D (void __iomem *)(base + 4);
-
-		/* ensure at least we have a default set of IO routines */
-		dm9000_set_io(db, 2);
-
-	} else {
-		db->addr_res =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
-		db->data_res =3D platform_get_resource(pdev, IORESOURCE_MEM, 1);
-		db->irq_res  =3D platform_get_resource(pdev, IORESOURCE_IRQ, 0);
-
-		if (db->addr_res =3D=3D NULL || db->data_res =3D=3D NULL ||
-		    db->irq_res =3D=3D NULL) {
-			dev_err(db->dev, "insufficient resources\n");
-			ret =3D -ENOENT;
-			goto out;
-		}
-
-		i =3D res_size(db->addr_res);
-		db->addr_req =3D request_mem_region(db->addr_res->start, i,
-						  pdev->name);
-
-		if (db->addr_req =3D=3D NULL) {
-			dev_err(db->dev, "cannot claim address reg area\n");
-			ret =3D -EIO;
-			goto out;
-		}
-
-		db->io_addr =3D ioremap(db->addr_res->start, i);
-
-		if (db->io_addr =3D=3D NULL) {
-			dev_err(db->dev, "failed to ioremap address reg\n");
-			ret =3D -EINVAL;
-			goto out;
-		}
-
-		iosize =3D res_size(db->data_res);
-		db->data_req =3D request_mem_region(db->data_res->start, iosize,
-						  pdev->name);
-
-		if (db->data_req =3D=3D NULL) {
-			dev_err(db->dev, "cannot claim data reg area\n");
-			ret =3D -EIO;
-			goto out;
-		}
-
-		db->io_data =3D ioremap(db->data_res->start, iosize);
-
-		if (db->io_data =3D=3D NULL) {
-			dev_err(db->dev,"failed to ioremap data reg\n");
-			ret =3D -EINVAL;
-			goto out;
-		}
-
-		/* fill in parameters for net-dev structure */
-
-		ndev->base_addr =3D (unsigned long)db->io_addr;
-		ndev->irq	=3D db->irq_res->start;
-
-		/* ensure at least we have a default set of IO routines */
-		dm9000_set_io(db, iosize);
+	switch (type) {
+	case TYPE_DM9000E: return 'e';
+	case TYPE_DM9000A: return 'a';
+	case TYPE_DM9000B: return 'b';
 	}
=20
-	/* check to see if anything is being over-ridden */
-	if (pdata !=3D NULL) {
-		/* check to see if the driver wants to over-ride the
-		 * default IO width */
-
-		if (pdata->flags & DM9000_PLATF_8BITONLY)
-			dm9000_set_io(db, 1);
-
-		if (pdata->flags & DM9000_PLATF_16BITONLY)
-			dm9000_set_io(db, 2);
-
-		if (pdata->flags & DM9000_PLATF_32BITONLY)
-			dm9000_set_io(db, 4);
-
-		/* check to see if there are any IO routine
-		 * over-rides */
-
-		if (pdata->inblk !=3D NULL)
-			db->inblk =3D pdata->inblk;
-
-		if (pdata->outblk !=3D NULL)
-			db->outblk =3D pdata->outblk;
-
-		if (pdata->dumpblk !=3D NULL)
-			db->dumpblk =3D pdata->dumpblk;
-
-		db->flags =3D pdata->flags;
-	}
-
-	dm9000_reset(db);
-
-	/* try two times, DM9000 sometimes gets the first read wrong */
-	for (i =3D 0; i < 8; i++) {
-		id_val  =3D ior(db, DM9000_VIDL);
-		id_val |=3D (u32)ior(db, DM9000_VIDH) << 8;
-		id_val |=3D (u32)ior(db, DM9000_PIDL) << 16;
-		id_val |=3D (u32)ior(db, DM9000_PIDH) << 24;
-
-		if (id_val =3D=3D DM9000_ID)
-			break;
-		dev_err(db->dev, "read wrong id 0x%08x\n", id_val);
-	}
-
-	if (id_val !=3D DM9000_ID) {
-		dev_err(db->dev, "wrong id: 0x%08x\n", id_val);
-		ret =3D -ENODEV;
-		goto out;
-	}
-
-	/* from this point we assume that we have found a DM9000 */
-
-	/* driver system function */
-	ether_setup(ndev);
-
-	ndev->open		 =3D &dm9000_open;
-	ndev->hard_start_xmit    =3D &dm9000_start_xmit;
-	ndev->tx_timeout         =3D &dm9000_timeout;
-	ndev->watchdog_timeo =3D msecs_to_jiffies(watchdog);
-	ndev->stop		 =3D &dm9000_stop;
-	ndev->set_multicast_list =3D &dm9000_hash_table;
-	ndev->ethtool_ops	 =3D &dm9000_ethtool_ops;
-	ndev->do_ioctl		 =3D &dm9000_ioctl;
-
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	ndev->poll_controller	 =3D &dm9000_poll_controller;
-#endif
-
-	db->msg_enable       =3D NETIF_MSG_LINK;
-	db->mii.phy_id_mask  =3D 0x1f;
-	db->mii.reg_num_mask =3D 0x1f;
-	db->mii.force_media  =3D 0;
-	db->mii.full_duplex  =3D 0;
-	db->mii.dev	     =3D ndev;
-	db->mii.mdio_read    =3D dm9000_phy_read;
-	db->mii.mdio_write   =3D dm9000_phy_write;
-
-	mac_src =3D "eeprom";
-
-	/* try reading the node address from the attached EEPROM */
-	for (i =3D 0; i < 6; i +=3D 2)
-		dm9000_read_eeprom(db, i / 2, ndev->dev_addr+i);
-
-	if (!is_valid_ether_addr(ndev->dev_addr)) {
-		/* try reading from mac */
-
-		mac_src =3D "chip";
-		for (i =3D 0; i < 6; i++)
-			ndev->dev_addr[i] =3D ior(db, i+DM9000_PAR);
-	}
-
-	if (!is_valid_ether_addr(ndev->dev_addr))
-		dev_warn(db->dev, "%s: Invalid ethernet MAC address. Please "
-			 "set using ifconfig\n", ndev->name);
-
-	platform_set_drvdata(pdev, ndev);
-	ret =3D register_netdev(ndev);
-
-	if (ret =3D=3D 0) {
-		DECLARE_MAC_BUF(mac);
-		printk("%s: dm9000 at %p,%p IRQ %d MAC: %s (%s)\n",
-		       ndev->name,  db->io_addr, db->io_data, ndev->irq,
-		       print_mac(mac, ndev->dev_addr), mac_src);
-	}
-	return 0;
-
-out:
-	dev_err(db->dev, "not found (%d).\n", ret);
-
-	dm9000_release_board(pdev, db);
-	free_netdev(ndev);
-
-	return ret;
+	return '?';
 }
=20
 /*
- *  Open the interface.
- *  The interface is opened whenever "ifconfig" actives it.
+ *  Set DM9000 multicast address
  */
-static int
-dm9000_open(struct net_device *dev)
+static void
+dm9000_hash_table(struct net_device *dev)
 {
 	board_info_t *db =3D (board_info_t *) dev->priv;
-	unsigned long irqflags =3D db->irq_res->flags & IRQF_TRIGGER_MASK;
+	struct dev_mc_list *mcptr =3D dev->mc_list;
+	int mc_cnt =3D dev->mc_count;
+	int i, oft;
+	u32 hash_val;
+	u16 hash_table[4];
+	u8 rcr =3D RCR_DIS_LONG | RCR_DIS_CRC | RCR_RXEN;
+	unsigned long flags;
=20
-	if (netif_msg_ifup(db))
-		dev_dbg(db->dev, "enabling %s\n", dev->name);
+	dm9000_dbg(db, 1, "entering %s\n", __func__);
=20
-	/* If there is no IRQ type specified, default to something that
-	 * may work, and tell the user that this is a problem */
+	spin_lock_irqsave(&db->lock, flags);
=20
-	if (irqflags =3D=3D IRQF_TRIGGER_NONE) {
-		dev_warn(db->dev, "WARNING: no IRQ resource flags set.\n");
-		irqflags =3D DEFAULT_TRIGGER;
-	}
+	for (i =3D 0, oft =3D DM9000_PAR; i < 6; i++, oft++)
+		iow(db, oft, dev->dev_addr[i]);
=20
-	irqflags |=3D IRQF_SHARED;
+	/* Clear Hash Table */
+	for (i =3D 0; i < 4; i++)
+		hash_table[i] =3D 0x0;
=20
-	if (request_irq(dev->irq, &dm9000_interrupt, irqflags, dev->name, dev=
))
-		return -EAGAIN;
+	/* broadcast address */
+	hash_table[3] =3D 0x8000;
=20
-	/* Initialize DM9000 board */
-	dm9000_reset(db);
-	dm9000_init_dm9000(dev);
+	if (dev->flags & IFF_PROMISC)
+		rcr |=3D RCR_PRMSC;
=20
-	/* Init driver variable */
-	db->dbug_cnt =3D 0;
+	if (dev->flags & IFF_ALLMULTI)
+		rcr |=3D RCR_ALL;
=20
-	mii_check_media(&db->mii, netif_msg_link(db), 1);
-	netif_start_queue(dev);
-=09
-	dm9000_schedule_poll(db);
+	/* the multicast address in Hash Table : 64 bits */
+	for (i =3D 0; i < mc_cnt; i++, mcptr =3D mcptr->next) {
+		hash_val =3D ether_crc_le(6, mcptr->dmi_addr) & 0x3f;
+		hash_table[hash_val / 16] |=3D (u16) 1 << (hash_val % 16);
+	}
=20
-	return 0;
+	/* Write the hash table to MAC MD table */
+	for (i =3D 0, oft =3D DM9000_MAR; i < 4; i++) {
+		iow(db, oft++, hash_table[i]);
+		iow(db, oft++, hash_table[i] >> 8);
+	}
+
+	iow(db, DM9000_RCR, rcr);
+	spin_unlock_irqrestore(&db->lock, flags);
 }
=20
 /*
@@ -795,7 +686,8 @@ dm9000_open(struct net_device *dev)
 static void
 dm9000_init_dm9000(struct net_device *dev)
 {
-	board_info_t *db =3D (board_info_t *) dev->priv;
+	board_info_t *db =3D dev->priv;
+	unsigned int imr;
=20
 	dm9000_dbg(db, 1, "entering %s\n", __func__);
=20
@@ -822,8 +714,14 @@ dm9000_init_dm9000(struct net_device *dev)
 	/* Set address filter table */
 	dm9000_hash_table(dev);
=20
+	imr =3D IMR_PAR | IMR_PTM | IMR_PRM;
+	if (db->type !=3D TYPE_DM9000E)
+		imr |=3D IMR_LNKCHNG;
+
+	db->imr_all =3D imr;
+
 	/* Enable TX/RX interrupt mask */
-	iow(db, DM9000_IMR, IMR_PAR | IMR_PTM | IMR_PRM);
+	iow(db, DM9000_IMR, imr);
=20
 	/* Init Driver variable */
 	db->tx_pkt_cnt =3D 0;
@@ -831,6 +729,29 @@ dm9000_init_dm9000(struct net_device *dev)
 	dev->trans_start =3D 0;
 }
=20
+/* Our watchdog timed out. Called by the networking layer */
+static void dm9000_timeout(struct net_device *dev)
+{
+	board_info_t *db =3D (board_info_t *) dev->priv;
+	u8 reg_save;
+	unsigned long flags;
+
+	/* Save previous register address */
+	reg_save =3D readb(db->io_addr);
+	spin_lock_irqsave(&db->lock, flags);
+
+	netif_stop_queue(dev);
+	dm9000_reset(db);
+	dm9000_init_dm9000(dev);
+	/* We can accept TX packets again */
+	dev->trans_start =3D jiffies;
+	netif_wake_queue(dev);
+
+	/* Restore previous register address */
+	writeb(reg_save, db->io_addr);
+	spin_unlock_irqrestore(&db->lock, flags);
+}
+
 /*
  *  Hardware start transmission.
  *  Send a packet to media from the upper layer.
@@ -839,7 +760,7 @@ static int
 dm9000_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	unsigned long flags;
-	board_info_t *db =3D (board_info_t *) dev->priv;
+	board_info_t *db =3D dev->priv;
=20
 	dm9000_dbg(db, 3, "%s:\n", __func__);
=20
@@ -879,50 +800,12 @@ dm9000_start_xmit(struct sk_buff *skb, struct net=
_device *dev)
 	return 0;
 }
=20
-static void
-dm9000_shutdown(struct net_device *dev)
-{
-	board_info_t *db =3D (board_info_t *) dev->priv;
-
-	/* RESET device */
-	dm9000_phy_write(dev, 0, MII_BMCR, BMCR_RESET);	/* PHY RESET */
-	iow(db, DM9000_GPR, 0x01);	/* Power-Down PHY */
-	iow(db, DM9000_IMR, IMR_PAR);	/* Disable all interrupt */
-	iow(db, DM9000_RCR, 0x00);	/* Disable RX */
-}
-
-/*
- * Stop the interface.
- * The interface is stopped when it is brought.
- */
-static int
-dm9000_stop(struct net_device *ndev)
-{
-	board_info_t *db =3D (board_info_t *) ndev->priv;
-
-	if (netif_msg_ifdown(db))
-		dev_dbg(db->dev, "shutting down %s\n", ndev->name);
-
-	cancel_delayed_work_sync(&db->phy_poll);
-
-	netif_stop_queue(ndev);
-	netif_carrier_off(ndev);
-
-	/* free interrupt */
-	free_irq(ndev->irq, ndev);
-
-	dm9000_shutdown(ndev);
-
-	return 0;
-}
-
 /*
  * DM9000 interrupt handler
  * receive the packet to upper layer, free the transmitted packet
  */
=20
-static void
-dm9000_tx_done(struct net_device *dev, board_info_t * db)
+static void dm9000_tx_done(struct net_device *dev, board_info_t *db)
 {
 	int tx_status =3D ior(db, DM9000_NSR);	/* Got TX status */
=20
@@ -945,52 +828,6 @@ dm9000_tx_done(struct net_device *dev, board_info_=
t * db)
 	}
 }
=20
-static irqreturn_t
-dm9000_interrupt(int irq, void *dev_id)
-{
-	struct net_device *dev =3D dev_id;
-	board_info_t *db =3D (board_info_t *) dev->priv;
-	int int_status;
-	u8 reg_save;
-
-	dm9000_dbg(db, 3, "entering %s\n", __func__);
-
-	/* A real interrupt coming */
-
-	spin_lock(&db->lock);
-
-	/* Save previous register address */
-	reg_save =3D readb(db->io_addr);
-
-	/* Disable all interrupts */
-	iow(db, DM9000_IMR, IMR_PAR);
-
-	/* Got DM9000 interrupt status */
-	int_status =3D ior(db, DM9000_ISR);	/* Got ISR */
-	iow(db, DM9000_ISR, int_status);	/* Clear ISR status */
-
-	if (netif_msg_intr(db))
-		dev_dbg(db->dev, "interrupt status %02x\n", int_status);
-
-	/* Received the coming packet */
-	if (int_status & ISR_PRS)
-		dm9000_rx(dev);
-
-	/* Trnasmit Interrupt check */
-	if (int_status & ISR_PTS)
-		dm9000_tx_done(dev, db);
-
-	/* Re-enable interrupt mask */
-	iow(db, DM9000_IMR, IMR_PAR | IMR_PTM | IMR_PRM);
-
-	/* Restore previous register address */
-	writeb(reg_save, db->io_addr);
-
-	spin_unlock(&db->lock);
-
-	return IRQ_HANDLED;
-}
-
 struct dm9000_rxhdr {
 	u8	RxPktReady;
 	u8	RxStatus;
@@ -1094,173 +931,109 @@ dm9000_rx(struct net_device *dev)
 	} while (rxbyte =3D=3D DM9000_PKT_RDY);
 }
=20
-static unsigned int
-dm9000_read_locked(board_info_t *db, int reg)
+static irqreturn_t dm9000_interrupt(int irq, void *dev_id)
 {
-	unsigned long flags;
-	unsigned int ret;
+	struct net_device *dev =3D dev_id;
+	board_info_t *db =3D dev->priv;
+	int int_status;
+	u8 reg_save;
=20
-	spin_lock_irqsave(&db->lock, flags);
-	ret =3D ior(db, reg);
-	spin_unlock_irqrestore(&db->lock, flags);
+	dm9000_dbg(db, 3, "entering %s\n", __func__);
=20
-	return ret;
-}
+	/* A real interrupt coming */
=20
-static int dm9000_wait_eeprom(board_info_t *db)
-{
-	unsigned int status;
-	int timeout =3D 8;	/* wait max 8msec */
+	spin_lock(&db->lock);
=20
-	/* The DM9000 data sheets say we should be able to
-	 * poll the ERRE bit in EPCR to wait for the EEPROM
-	 * operation. From testing several chips, this bit
-	 * does not seem to work.
-	 *
-	 * We attempt to use the bit, but fall back to the
-	 * timeout (which is why we do not return an error
-	 * on expiry) to say that the EEPROM operation has
-	 * completed.
-	 */
+	/* Save previous register address */
+	reg_save =3D readb(db->io_addr);
=20
-	while (1) {
-		status =3D dm9000_read_locked(db, DM9000_EPCR);
+	/* Disable all interrupts */
+	iow(db, DM9000_IMR, IMR_PAR);
=20
-		if ((status & EPCR_ERRE) =3D=3D 0)
-			break;
+	/* Got DM9000 interrupt status */
+	int_status =3D ior(db, DM9000_ISR);	/* Got ISR */
+	iow(db, DM9000_ISR, int_status);	/* Clear ISR status */
=20
-		if (timeout-- < 0) {
-			dev_dbg(db->dev, "timeout waiting EEPROM\n");
-			break;
-		}
-	}
+	if (netif_msg_intr(db))
+		dev_dbg(db->dev, "interrupt status %02x\n", int_status);
=20
-	return 0;
-}
+	/* Received the coming packet */
+	if (int_status & ISR_PRS)
+		dm9000_rx(dev);
=20
-/*
- *  Read a word data from EEPROM
- */
-static void
-dm9000_read_eeprom(board_info_t *db, int offset, u8 *to)
-{
-	unsigned long flags;
+	/* Trnasmit Interrupt check */
+	if (int_status & ISR_PTS)
+		dm9000_tx_done(dev, db);
=20
-	if (db->flags & DM9000_PLATF_NO_EEPROM) {
-		to[0] =3D 0xff;
-		to[1] =3D 0xff;
-		return;
+	if (db->type !=3D TYPE_DM9000E) {
+		if (int_status & ISR_LNKCHNG) {
+			/* fire a link-change request */
+			schedule_delayed_work(&db->phy_poll, 1);
+		}
 	}
=20
-	mutex_lock(&db->addr_lock);
-
-	spin_lock_irqsave(&db->lock, flags);
-
-	iow(db, DM9000_EPAR, offset);
-	iow(db, DM9000_EPCR, EPCR_ERPRR);
-
-	spin_unlock_irqrestore(&db->lock, flags);
-
-	dm9000_wait_eeprom(db);
-
-	/* delay for at-least 150uS */
-	msleep(1);
-
-	spin_lock_irqsave(&db->lock, flags);
-
-	iow(db, DM9000_EPCR, 0x0);
+	/* Re-enable interrupt mask */
+	iow(db, DM9000_IMR, db->imr_all);
=20
-	to[0] =3D ior(db, DM9000_EPDRL);
-	to[1] =3D ior(db, DM9000_EPDRH);
+	/* Restore previous register address */
+	writeb(reg_save, db->io_addr);
=20
-	spin_unlock_irqrestore(&db->lock, flags);
+	spin_unlock(&db->lock);
=20
-	mutex_unlock(&db->addr_lock);
+	return IRQ_HANDLED;
 }
=20
+#ifdef CONFIG_NET_POLL_CONTROLLER
 /*
- * Write a word data to SROM
+ *Used by netconsole
  */
-static void
-dm9000_write_eeprom(board_info_t *db, int offset, u8 *data)
+static void dm9000_poll_controller(struct net_device *dev)
 {
-	unsigned long flags;
-
-	if (db->flags & DM9000_PLATF_NO_EEPROM)
-		return;
-
-	mutex_lock(&db->addr_lock);
-
-	spin_lock_irqsave(&db->lock, flags);
-	iow(db, DM9000_EPAR, offset);
-	iow(db, DM9000_EPDRH, data[1]);
-	iow(db, DM9000_EPDRL, data[0]);
-	iow(db, DM9000_EPCR, EPCR_WEP | EPCR_ERPRW);
-	spin_unlock_irqrestore(&db->lock, flags);
-
-	dm9000_wait_eeprom(db);
-
-	mdelay(1);	/* wait at least 150uS to clear */
-
-	spin_lock_irqsave(&db->lock, flags);
-	iow(db, DM9000_EPCR, 0);
-	spin_unlock_irqrestore(&db->lock, flags);
-
-	mutex_unlock(&db->addr_lock);
+	disable_irq(dev->irq);
+	dm9000_interrupt(dev->irq, dev);
+	enable_irq(dev->irq);
 }
+#endif
=20
 /*
- *  Set DM9000 multicast address
+ *  Open the interface.
+ *  The interface is opened whenever "ifconfig" actives it.
  */
-static void
-dm9000_hash_table(struct net_device *dev)
+static int
+dm9000_open(struct net_device *dev)
 {
-	board_info_t *db =3D (board_info_t *) dev->priv;
-	struct dev_mc_list *mcptr =3D dev->mc_list;
-	int mc_cnt =3D dev->mc_count;
-	int i, oft;
-	u32 hash_val;
-	u16 hash_table[4];
-	u8 rcr =3D RCR_DIS_LONG | RCR_DIS_CRC | RCR_RXEN;
-	unsigned long flags;
-
-	dm9000_dbg(db, 1, "entering %s\n", __func__);
+	board_info_t *db =3D dev->priv;
+	unsigned long irqflags =3D db->irq_res->flags & IRQF_TRIGGER_MASK;
=20
-	spin_lock_irqsave(&db->lock, flags);
+	if (netif_msg_ifup(db))
+		dev_dbg(db->dev, "enabling %s\n", dev->name);
=20
-	for (i =3D 0, oft =3D DM9000_PAR; i < 6; i++, oft++)
-		iow(db, oft, dev->dev_addr[i]);
+	/* If there is no IRQ type specified, default to something that
+	 * may work, and tell the user that this is a problem */
=20
-	/* Clear Hash Table */
-	for (i =3D 0; i < 4; i++)
-		hash_table[i] =3D 0x0;
+	if (irqflags =3D=3D IRQF_TRIGGER_NONE)
+		dev_warn(db->dev, "WARNING: no IRQ resource flags set.\n");
=20
-	/* broadcast address */
-	hash_table[3] =3D 0x8000;
+	irqflags |=3D IRQF_SHARED;
=20
-	if (dev->flags & IFF_PROMISC)
-		rcr |=3D RCR_PRMSC;
+	if (request_irq(dev->irq, &dm9000_interrupt, irqflags, dev->name, dev=
))
+		return -EAGAIN;
=20
-	if (dev->flags & IFF_ALLMULTI)
-		rcr |=3D RCR_ALL;
+	/* Initialize DM9000 board */
+	dm9000_reset(db);
+	dm9000_init_dm9000(dev);
=20
-	/* the multicast address in Hash Table : 64 bits */
-	for (i =3D 0; i < mc_cnt; i++, mcptr =3D mcptr->next) {
-		hash_val =3D ether_crc_le(6, mcptr->dmi_addr) & 0x3f;
-		hash_table[hash_val / 16] |=3D (u16) 1 << (hash_val % 16);
-	}
+	/* Init driver variable */
+	db->dbug_cnt =3D 0;
=20
-	/* Write the hash table to MAC MD table */
-	for (i =3D 0, oft =3D DM9000_MAR; i < 4; i++) {
-		iow(db, oft++, hash_table[i]);
-		iow(db, oft++, hash_table[i] >> 8);
-	}
+	mii_check_media(&db->mii, netif_msg_link(db), 1);
+	netif_start_queue(dev);
+=09
+	dm9000_schedule_poll(db);
=20
-	iow(db, DM9000_RCR, rcr);
-	spin_unlock_irqrestore(&db->lock, flags);
+	return 0;
 }
=20
-
 /*
  * Sleep, either by using msleep() or if we are suspending, then
  * use mdelay() to sleep.
@@ -1323,7 +1096,8 @@ dm9000_phy_read(struct net_device *dev, int phy_r=
eg_unused, int reg)
  *   Write a word to phyxcer
  */
 static void
-dm9000_phy_write(struct net_device *dev, int phyaddr_unused, int reg, =
int value)
+dm9000_phy_write(struct net_device *dev,
+		 int phyaddr_unused, int reg, int value)
 {
 	board_info_t *db =3D (board_info_t *) dev->priv;
 	unsigned long flags;
@@ -1363,6 +1137,273 @@ dm9000_phy_write(struct net_device *dev, int ph=
yaddr_unused, int reg, int value)
 	mutex_unlock(&db->addr_lock);
 }
=20
+static void
+dm9000_shutdown(struct net_device *dev)
+{
+	board_info_t *db =3D dev->priv;
+
+	/* RESET device */
+	dm9000_phy_write(dev, 0, MII_BMCR, BMCR_RESET);	/* PHY RESET */
+	iow(db, DM9000_GPR, 0x01);	/* Power-Down PHY */
+	iow(db, DM9000_IMR, IMR_PAR);	/* Disable all interrupt */
+	iow(db, DM9000_RCR, 0x00);	/* Disable RX */
+}
+
+/*
+ * Stop the interface.
+ * The interface is stopped when it is brought.
+ */
+static int
+dm9000_stop(struct net_device *ndev)
+{
+	board_info_t *db =3D ndev->priv;
+
+	if (netif_msg_ifdown(db))
+		dev_dbg(db->dev, "shutting down %s\n", ndev->name);
+
+	cancel_delayed_work_sync(&db->phy_poll);
+
+	netif_stop_queue(ndev);
+	netif_carrier_off(ndev);
+
+	/* free interrupt */
+	free_irq(ndev->irq, ndev);
+
+	dm9000_shutdown(ndev);
+
+	return 0;
+}
+
+#define res_size(_r) (((_r)->end - (_r)->start) + 1)
+
+/*
+ * Search DM9000 board, allocate space and register it
+ */
+static int __devinit
+dm9000_probe(struct platform_device *pdev)
+{
+	struct dm9000_plat_data *pdata =3D pdev->dev.platform_data;
+	struct board_info *db;	/* Point a board information structure */
+	struct net_device *ndev;
+	const unsigned char *mac_src;
+	int ret =3D 0;
+	int iosize;
+	int i;
+	u32 id_val;
+
+	/* Init network device */
+	ndev =3D alloc_etherdev(sizeof(struct board_info));
+	if (!ndev) {
+		dev_err(&pdev->dev, "could not allocate device.\n");
+		return -ENOMEM;
+	}
+
+	SET_NETDEV_DEV(ndev, &pdev->dev);
+
+	dev_dbg(&pdev->dev, "dm9000_probe()\n");
+
+	/* setup board info structure */
+	db =3D ndev->priv;
+	memset(db, 0, sizeof(*db));
+
+	db->dev =3D &pdev->dev;
+	db->ndev =3D ndev;
+
+	spin_lock_init(&db->lock);
+	mutex_init(&db->addr_lock);
+
+	INIT_DELAYED_WORK(&db->phy_poll, dm9000_poll_work);
+
+	db->addr_res =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	db->data_res =3D platform_get_resource(pdev, IORESOURCE_MEM, 1);
+	db->irq_res  =3D platform_get_resource(pdev, IORESOURCE_IRQ, 0);
+
+	if (db->addr_res =3D=3D NULL || db->data_res =3D=3D NULL ||
+	    db->irq_res =3D=3D NULL) {
+		dev_err(db->dev, "insufficient resources\n");
+		ret =3D -ENOENT;
+		goto out;
+	}
+
+	iosize =3D res_size(db->addr_res);
+	db->addr_req =3D request_mem_region(db->addr_res->start, iosize,
+					  pdev->name);
+
+	if (db->addr_req =3D=3D NULL) {
+		dev_err(db->dev, "cannot claim address reg area\n");
+		ret =3D -EIO;
+		goto out;
+	}
+
+	db->io_addr =3D ioremap(db->addr_res->start, iosize);
+
+	if (db->io_addr =3D=3D NULL) {
+		dev_err(db->dev, "failed to ioremap address reg\n");
+		ret =3D -EINVAL;
+		goto out;
+	}
+
+	iosize =3D res_size(db->data_res);
+	db->data_req =3D request_mem_region(db->data_res->start, iosize,
+					  pdev->name);
+
+	if (db->data_req =3D=3D NULL) {
+		dev_err(db->dev, "cannot claim data reg area\n");
+		ret =3D -EIO;
+		goto out;
+	}
+
+	db->io_data =3D ioremap(db->data_res->start, iosize);
+
+	if (db->io_data =3D=3D NULL) {
+		dev_err(db->dev, "failed to ioremap data reg\n");
+		ret =3D -EINVAL;
+		goto out;
+	}
+
+	/* fill in parameters for net-dev structure */
+	ndev->base_addr =3D (unsigned long)db->io_addr;
+	ndev->irq	=3D db->irq_res->start;
+
+	/* ensure at least we have a default set of IO routines */
+	dm9000_set_io(db, iosize);
+
+	/* check to see if anything is being over-ridden */
+	if (pdata !=3D NULL) {
+		/* check to see if the driver wants to over-ride the
+		 * default IO width */
+
+		if (pdata->flags & DM9000_PLATF_8BITONLY)
+			dm9000_set_io(db, 1);
+
+		if (pdata->flags & DM9000_PLATF_16BITONLY)
+			dm9000_set_io(db, 2);
+
+		if (pdata->flags & DM9000_PLATF_32BITONLY)
+			dm9000_set_io(db, 4);
+
+		/* check to see if there are any IO routine
+		 * over-rides */
+
+		if (pdata->inblk !=3D NULL)
+			db->inblk =3D pdata->inblk;
+
+		if (pdata->outblk !=3D NULL)
+			db->outblk =3D pdata->outblk;
+
+		if (pdata->dumpblk !=3D NULL)
+			db->dumpblk =3D pdata->dumpblk;
+
+		db->flags =3D pdata->flags;
+	}
+
+#ifdef CONFIG_DM9000_FORCE_SIMPLE_PHY_POLL
+	db->flags |=3D DM9000_PLATF_SIMPLE_PHY;
+#endif
+
+	dm9000_reset(db);
+
+	/* try multiple times, DM9000 sometimes gets the read wrong */
+	for (i =3D 0; i < 8; i++) {
+		id_val  =3D ior(db, DM9000_VIDL);
+		id_val |=3D (u32)ior(db, DM9000_VIDH) << 8;
+		id_val |=3D (u32)ior(db, DM9000_PIDL) << 16;
+		id_val |=3D (u32)ior(db, DM9000_PIDH) << 24;
+
+		if (id_val =3D=3D DM9000_ID)
+			break;
+		dev_err(db->dev, "read wrong id 0x%08x\n", id_val);
+	}
+
+	if (id_val !=3D DM9000_ID) {
+		dev_err(db->dev, "wrong id: 0x%08x\n", id_val);
+		ret =3D -ENODEV;
+		goto out;
+	}
+
+	/* Identify what type of DM9000 we are working on */
+
+	id_val =3D ior(db, DM9000_CHIPR);
+	dev_dbg(db->dev, "dm9000 revision 0x%02x\n", id_val);
+
+	switch (id_val) {
+	case CHIPR_DM9000A:
+		db->type =3D TYPE_DM9000A;
+		break;
+	case CHIPR_DM9000B:
+		db->type =3D TYPE_DM9000B;
+		break;
+	default:
+		dev_dbg(db->dev, "ID %02x =3D> defaulting to DM9000E\n", id_val);
+		db->type =3D TYPE_DM9000E;
+	}
+
+	/* from this point we assume that we have found a DM9000 */
+
+	/* driver system function */
+	ether_setup(ndev);
+
+	ndev->open		 =3D &dm9000_open;
+	ndev->hard_start_xmit    =3D &dm9000_start_xmit;
+	ndev->tx_timeout         =3D &dm9000_timeout;
+	ndev->watchdog_timeo =3D msecs_to_jiffies(watchdog);
+	ndev->stop		 =3D &dm9000_stop;
+	ndev->set_multicast_list =3D &dm9000_hash_table;
+	ndev->ethtool_ops	 =3D &dm9000_ethtool_ops;
+	ndev->do_ioctl		 =3D &dm9000_ioctl;
+
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	ndev->poll_controller	 =3D &dm9000_poll_controller;
+#endif
+
+	db->msg_enable       =3D NETIF_MSG_LINK;
+	db->mii.phy_id_mask  =3D 0x1f;
+	db->mii.reg_num_mask =3D 0x1f;
+	db->mii.force_media  =3D 0;
+	db->mii.full_duplex  =3D 0;
+	db->mii.dev	     =3D ndev;
+	db->mii.mdio_read    =3D dm9000_phy_read;
+	db->mii.mdio_write   =3D dm9000_phy_write;
+
+	mac_src =3D "eeprom";
+
+	/* try reading the node address from the attached EEPROM */
+	for (i =3D 0; i < 6; i +=3D 2)
+		dm9000_read_eeprom(db, i / 2, ndev->dev_addr+i);
+
+	if (!is_valid_ether_addr(ndev->dev_addr)) {
+		/* try reading from mac */
+	=09
+		mac_src =3D "chip";
+		for (i =3D 0; i < 6; i++)
+			ndev->dev_addr[i] =3D ior(db, i+DM9000_PAR);
+	}
+
+	if (!is_valid_ether_addr(ndev->dev_addr))
+		dev_warn(db->dev, "%s: Invalid ethernet MAC address. Please "
+			 "set using ifconfig\n", ndev->name);
+
+	platform_set_drvdata(pdev, ndev);
+	ret =3D register_netdev(ndev);
+
+	if (ret =3D=3D 0) {
+		DECLARE_MAC_BUF(mac);
+		printk(KERN_INFO "%s: dm9000%c at %p,%p IRQ %d MAC: %s (%s)\n",
+		       ndev->name, dm9000_type_to_char(db->type),
+		       db->io_addr, db->io_data, ndev->irq,
+		       print_mac(mac, ndev->dev_addr), mac_src);
+	}
+	return 0;
+
+out:
+	dev_err(db->dev, "not found (%d).\n", ret);
+
+	dm9000_release_board(pdev, db);
+	free_netdev(ndev);
+
+	return ret;
+}
+
 static int
 dm9000_drv_suspend(struct platform_device *dev, pm_message_t state)
 {
@@ -1432,7 +1473,7 @@ dm9000_init(void)
 {
 	printk(KERN_INFO "%s Ethernet Driver, V%s\n", CARDNAME, DRV_VERSION);
=20
-	return platform_driver_register(&dm9000_driver);	/* search board and =
register */
+	return platform_driver_register(&dm9000_driver);
 }
=20
 static void __exit
diff --git a/drivers/net/dm9000.h b/drivers/net/dm9000.h
index 82cad36..ba25cf5 100644
--- a/drivers/net/dm9000.h
+++ b/drivers/net/dm9000.h
@@ -45,6 +45,9 @@
 #define DM9000_CHIPR           0x2C
 #define DM9000_SMCR            0x2F
=20
+#define CHIPR_DM9000A	       0x19
+#define CHIPR_DM9000B	       0x1B
+
 #define DM9000_MRCMDX          0xF0
 #define DM9000_MRCMD           0xF2
 #define DM9000_MRRL            0xF4
@@ -131,5 +134,13 @@
 #define DM9000_PKT_RDY		0x01	/* Packet ready to receive */
 #define DM9000_PKT_MAX		1536	/* Received packet max size */
=20
+/* DM9000A / DM9000B definitions */
+
+#define IMR_LNKCHNG		(1<<5)
+#define IMR_UNDERRUN		(1<<4)
+
+#define ISR_LNKCHNG		(1<<5)
+#define ISR_UNDERRUN		(1<<4)
+
 #endif /* _DM9000X_H_ */
=20
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_m=
ain.c
index 59579b1..311ca26 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -47,12 +47,6 @@ static const char e1000_copyright[] =3D "Copyright (=
c) 1999-2006 Intel Corporation
  * Macro expands to...
  *   {PCI_DEVICE(PCI_VENDOR_ID_INTEL, device_id)}
  */
-#ifdef CONFIG_E1000E_ENABLED
-  #define PCIE(x)=20
-#else
-  #define PCIE(x) x,
-#endif
-
 static struct pci_device_id e1000_pci_tbl[] =3D {
 	INTEL_E1000_ETHERNET_DEVICE(0x1000),
 	INTEL_E1000_ETHERNET_DEVICE(0x1001),
@@ -79,14 +73,6 @@ static struct pci_device_id e1000_pci_tbl[] =3D {
 	INTEL_E1000_ETHERNET_DEVICE(0x1026),
 	INTEL_E1000_ETHERNET_DEVICE(0x1027),
 	INTEL_E1000_ETHERNET_DEVICE(0x1028),
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x1049))
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x104A))
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x104B))
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x104C))
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x104D))
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x105E))
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x105F))
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x1060))
 	INTEL_E1000_ETHERNET_DEVICE(0x1075),
 	INTEL_E1000_ETHERNET_DEVICE(0x1076),
 	INTEL_E1000_ETHERNET_DEVICE(0x1077),
@@ -95,28 +81,9 @@ PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x1060))
 	INTEL_E1000_ETHERNET_DEVICE(0x107A),
 	INTEL_E1000_ETHERNET_DEVICE(0x107B),
 	INTEL_E1000_ETHERNET_DEVICE(0x107C),
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x107D))
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x107E))
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x107F))
 	INTEL_E1000_ETHERNET_DEVICE(0x108A),
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x108B))
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x108C))
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x1096))
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x1098))
 	INTEL_E1000_ETHERNET_DEVICE(0x1099),
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x109A))
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x10A4))
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x10A5))
 	INTEL_E1000_ETHERNET_DEVICE(0x10B5),
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x10B9))
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x10BA))
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x10BB))
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x10BC))
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x10C4))
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x10C5))
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x10D5))
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x10D9))
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x10DA))
 	/* required last entry */
 	{0,}
 };
@@ -5284,7 +5251,6 @@ e1000_netpoll(struct net_device *netdev)
=20
 	disable_irq(adapter->pdev->irq);
 	e1000_intr(adapter->pdev->irq, netdev);
-	e1000_clean_tx_irq(adapter, adapter->tx_ring);
 #ifndef CONFIG_E1000_NAPI
 	adapter->clean_rx(adapter, adapter->rx_ring);
 #endif
diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index d3bc6f8..4a4f62e 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -283,6 +283,10 @@ struct e1000_adapter {
 	unsigned long led_status;
=20
 	unsigned int flags;
+
+	/* for ioport free */
+	int bars;
+	int need_ioport;
 };
=20
 struct e1000_info {
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index ccb8ca2..22f2fc9 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -4002,7 +4002,11 @@ static int e1000_resume(struct pci_dev *pdev)
 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
 	e1000e_disable_l1aspm(pdev);
-	err =3D pci_enable_device(pdev);
+
+	if (adapter->need_ioport)
+		err =3D pci_enable_device(pdev);
+	else
+		err =3D pci_enable_device_mem(pdev);
 	if (err) {
 		dev_err(&pdev->dev,
 			"Cannot enable PCI device from suspend\n");
@@ -4103,9 +4107,14 @@ static pci_ers_result_t e1000_io_slot_reset(stru=
ct pci_dev *pdev)
 	struct net_device *netdev =3D pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter =3D netdev_priv(netdev);
 	struct e1000_hw *hw =3D &adapter->hw;
+	int err;
=20
 	e1000e_disable_l1aspm(pdev);
-	if (pci_enable_device(pdev)) {
+	if (adapter->need_ioport)
+		err =3D pci_enable_device(pdev);
+	else
+		err =3D pci_enable_device_mem(pdev);
+	if (err) {
 		dev_err(&pdev->dev,
 			"Cannot re-enable PCI device after reset.\n");
 		return PCI_ERS_RESULT_DISCONNECT;
@@ -4184,6 +4193,21 @@ static void e1000_print_device_info(struct e1000=
_adapter *adapter)
 }
=20
 /**
+ * e1000e_is_need_ioport - determine if an adapter needs ioport resour=
ces or not
+ * @pdev: PCI device information struct
+ *
+ * Returns true if an adapters needs ioport resources
+ **/
+static int e1000e_is_need_ioport(struct pci_dev *pdev)
+{
+	switch (pdev->device) {
+	/* Currently there are no adapters that need ioport resources */
+	default:
+		return false;
+	}
+}
+
+/**
  * e1000_probe - Device Initialization Routine
  * @pdev: PCI device information struct
  * @ent: entry in e1000_pci_tbl
@@ -4208,9 +4232,19 @@ static int __devinit e1000_probe(struct pci_dev =
*pdev,
 	int i, err, pci_using_dac;
 	u16 eeprom_data =3D 0;
 	u16 eeprom_apme_mask =3D E1000_EEPROM_APME;
+	int bars, need_ioport;
=20
 	e1000e_disable_l1aspm(pdev);
-	err =3D pci_enable_device(pdev);
+
+	/* do not allocate ioport bars when not needed */
+	need_ioport =3D e1000e_is_need_ioport(pdev);
+	if (need_ioport) {
+		bars =3D pci_select_bars(pdev, IORESOURCE_MEM | IORESOURCE_IO);
+		err =3D pci_enable_device(pdev);
+	} else {
+		bars =3D pci_select_bars(pdev, IORESOURCE_MEM);
+		err =3D pci_enable_device_mem(pdev);
+	}
 	if (err)
 		return err;
=20
@@ -4233,7 +4267,7 @@ static int __devinit e1000_probe(struct pci_dev *=
pdev,
 		}
 	}
=20
-	err =3D pci_request_regions(pdev, e1000e_driver_name);
+	err =3D pci_request_selected_regions(pdev, bars, e1000e_driver_name);
 	if (err)
 		goto err_pci_reg;
=20
@@ -4258,6 +4292,8 @@ static int __devinit e1000_probe(struct pci_dev *=
pdev,
 	adapter->hw.adapter =3D adapter;
 	adapter->hw.mac.type =3D ei->mac;
 	adapter->msg_enable =3D (1 << NETIF_MSG_DRV | NETIF_MSG_PROBE) - 1;
+	adapter->bars =3D bars;
+	adapter->need_ioport =3D need_ioport;
=20
 	mmio_start =3D pci_resource_start(pdev, 0);
 	mmio_len =3D pci_resource_len(pdev, 0);
@@ -4497,7 +4533,7 @@ err_sw_init:
 err_ioremap:
 	free_netdev(netdev);
 err_alloc_etherdev:
-	pci_release_regions(pdev);
+	pci_release_selected_regions(pdev, bars);
 err_pci_reg:
 err_dma:
 	pci_disable_device(pdev);
@@ -4545,7 +4581,7 @@ static void __devexit e1000_remove(struct pci_dev=
 *pdev)
 	iounmap(adapter->hw.hw_addr);
 	if (adapter->hw.flash_address)
 		iounmap(adapter->hw.flash_address);
-	pci_release_regions(pdev);
+	pci_release_selected_regions(pdev, adapter->bars);
=20
 	free_netdev(netdev);
=20
diff --git a/drivers/net/fealnx.c b/drivers/net/fealnx.c
index 7bb9c72..3c1364d 100644
--- a/drivers/net/fealnx.c
+++ b/drivers/net/fealnx.c
@@ -90,6 +90,7 @@ static int full_duplex[MAX_UNITS] =3D { -1, -1, -1, -=
1, -1, -1, -1, -1 };
 #include <asm/processor.h>	/* Processor type for cache alignment. */
 #include <asm/io.h>
 #include <asm/uaccess.h>
+#include <asm/byteorder.h>
=20
 /* These identify the driver base version and may not be removed. */
 static char version[] =3D
@@ -861,40 +862,20 @@ static int netdev_open(struct net_device *dev)
 	   Wait the specified 50 PCI cycles after a reset by initializing
 	   Tx and Rx queues and the address filter list.
 	   FIXME (Ueimor): optimistic for alpha + posted writes ? */
-#if defined(__powerpc__) || defined(__sparc__)
-// 89/9/1 modify,
-//   np->bcrvalue=3D0x04 | 0x0x38;  /* big-endian, 256 burst length */
-	np->bcrvalue =3D 0x04 | 0x10;	/* big-endian, tx 8 burst length */
-	np->crvalue =3D 0xe00;	/* rx 128 burst length */
-#elif defined(__alpha__) || defined(__x86_64__)
-// 89/9/1 modify,
-//   np->bcrvalue=3D0x38;           /* little-endian, 256 burst length=
 */
-	np->bcrvalue =3D 0x10;	/* little-endian, 8 burst length */
-	np->crvalue =3D 0xe00;	/* rx 128 burst length */
-#elif defined(__i386__)
-#if defined(MODULE)
-// 89/9/1 modify,
-//   np->bcrvalue=3D0x38;           /* little-endian, 256 burst length=
 */
+
 	np->bcrvalue =3D 0x10;	/* little-endian, 8 burst length */
-	np->crvalue =3D 0xe00;	/* rx 128 burst length */
-#else
-	/* When not a module we can work around broken '486 PCI boards. */
-#define x86 boot_cpu_data.x86
-// 89/9/1 modify,
-//   np->bcrvalue=3D(x86 <=3D 4 ? 0x10 : 0x38);
-	np->bcrvalue =3D 0x10;
-	np->crvalue =3D (x86 <=3D 4 ? 0xa00 : 0xe00);
-	if (x86 <=3D 4)
-		printk(KERN_INFO "%s: This is a 386/486 PCI system, setting burst "
-		       "length to %x.\n", dev->name, (x86 <=3D 4 ? 0x10 : 0x38));
+#ifdef __BIG_ENDIAN
+	np->bcrvalue |=3D 0x04;	/* big-endian */
 #endif
-#else
-// 89/9/1 modify,
-//   np->bcrvalue=3D0x38;
-	np->bcrvalue =3D 0x10;
-	np->crvalue =3D 0xe00;	/* rx 128 burst length */
-#warning Processor architecture undefined!
+
+#if defined(__i386__) && !defined(MODULE)
+	if (boot_cpu_data.x86 <=3D 4)
+		np->crvalue =3D 0xa00;
+	else
 #endif
+		np->crvalue =3D 0xe00;	/* rx 128 burst length */
+
+
 // 89/12/29 add,
 // 90/1/16 modify,
 //   np->imrvalue=3DFBE|TUNF|CNTOVF|RBU|TI|RI;
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index c980ce9..afd063f 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -5559,6 +5559,11 @@ static int __devinit nv_probe(struct pci_dev *pc=
i_dev, const struct pci_device_i
 	/* set mac address */
 	nv_copy_mac_to_hw(dev);
=20
+	/* Workaround current PCI init glitch:  wakeup bits aren't
+	 * being set from PCI PM capability.
+	 */
+	device_init_wakeup(&pci_dev->dev, 1);
+
 	/* disable WOL */
 	writel(0, base + NvRegWakeUpFlags);
 	np->wolenabled =3D 0;
diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index 6b2e7d3..0eecb8b 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -271,6 +271,10 @@ struct igb_adapter {
 	unsigned int msi_enabled;
=20
 	u32 eeprom_wol;
+
+	/* for ioport free */
+	int bars;
+	int need_ioport;
 };
=20
 enum e1000_state_t {
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 7b6b780..e13b8db 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -820,6 +820,21 @@ void igb_reset(struct igb_adapter *adapter)
 }
=20
 /**
+ * igb_is_need_ioport - determine if an adapter needs ioport resources=
 or not
+ * @pdev: PCI device information struct
+ *
+ * Returns true if an adapter needs ioport resources
+ **/
+static int igb_is_need_ioport(struct pci_dev *pdev)
+{
+	switch (pdev->device) {
+	/* Currently there are no adapters that need ioport resources */
+	default:
+		return false;
+	}
+}
+
+/**
  * igb_probe - Device Initialization Routine
  * @pdev: PCI device information struct
  * @ent: entry in igb_pci_tbl
@@ -843,8 +858,17 @@ static int __devinit igb_probe(struct pci_dev *pde=
v,
 	u16 eeprom_data =3D 0;
 	u16 eeprom_apme_mask =3D IGB_EEPROM_APME;
 	u32 part_num;
+	int bars, need_ioport;
=20
-	err =3D pci_enable_device(pdev);
+	/* do not allocate ioport bars when not needed */
+	need_ioport =3D igb_is_need_ioport(pdev);
+	if (need_ioport) {
+		bars =3D pci_select_bars(pdev, IORESOURCE_MEM | IORESOURCE_IO);
+		err =3D pci_enable_device(pdev);
+	} else {
+		bars =3D pci_select_bars(pdev, IORESOURCE_MEM);
+		err =3D pci_enable_device_mem(pdev);
+	}
 	if (err)
 		return err;
=20
@@ -866,7 +890,7 @@ static int __devinit igb_probe(struct pci_dev *pdev=
,
 		}
 	}
=20
-	err =3D pci_request_regions(pdev, igb_driver_name);
+	err =3D pci_request_selected_regions(pdev, bars, igb_driver_name);
 	if (err)
 		goto err_pci_reg;
=20
@@ -887,6 +911,8 @@ static int __devinit igb_probe(struct pci_dev *pdev=
,
 	hw =3D &adapter->hw;
 	hw->back =3D adapter;
 	adapter->msg_enable =3D NETIF_MSG_DRV | NETIF_MSG_PROBE;
+	adapter->bars =3D bars;
+	adapter->need_ioport =3D need_ioport;
=20
 	mmio_start =3D pci_resource_start(pdev, 0);
 	mmio_len =3D pci_resource_len(pdev, 0);
@@ -1127,7 +1153,7 @@ err_hw_init:
 err_ioremap:
 	free_netdev(netdev);
 err_alloc_etherdev:
-	pci_release_regions(pdev);
+	pci_release_selected_regions(pdev, bars);
 err_pci_reg:
 err_dma:
 	pci_disable_device(pdev);
@@ -1174,7 +1200,7 @@ static void __devexit igb_remove(struct pci_dev *=
pdev)
 	iounmap(adapter->hw.hw_addr);
 	if (adapter->hw.flash_address)
 		iounmap(adapter->hw.flash_address);
-	pci_release_regions(pdev);
+	pci_release_selected_regions(pdev, adapter->bars);
=20
 	free_netdev(netdev);
=20
@@ -3975,7 +4001,11 @@ static int igb_resume(struct pci_dev *pdev)
=20
 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
-	err =3D pci_enable_device(pdev);
+
+	if (adapter->need_ioport)
+		err =3D pci_enable_device(pdev);
+	else
+		err =3D pci_enable_device_mem(pdev);
 	if (err) {
 		dev_err(&pdev->dev,
 			"igb: Cannot enable PCI device from suspend\n");
@@ -4078,8 +4108,13 @@ static pci_ers_result_t igb_io_slot_reset(struct=
 pci_dev *pdev)
 	struct net_device *netdev =3D pci_get_drvdata(pdev);
 	struct igb_adapter *adapter =3D netdev_priv(netdev);
 	struct e1000_hw *hw =3D &adapter->hw;
+	int err;
=20
-	if (pci_enable_device(pdev)) {
+	if (adapter->need_ioport)
+		err =3D pci_enable_device(pdev);
+	else
+		err =3D pci_enable_device_mem(pdev);
+	if (err) {
 		dev_err(&pdev->dev,
 			"Cannot re-enable PCI device after reset.\n");
 		return PCI_ERS_RESULT_DISCONNECT;
diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index d981134..956914a 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -32,6 +32,7 @@
 #include <linux/types.h>
 #include <linux/pci.h>
 #include <linux/netdevice.h>
+#include <linux/inet_lro.h>
=20
 #include "ixgbe_type.h"
 #include "ixgbe_common.h"
@@ -100,6 +101,9 @@
 #define IXGBE_TX_FLAGS_VLAN_MASK	0xffff0000
 #define IXGBE_TX_FLAGS_VLAN_SHIFT	16
=20
+#define IXGBE_MAX_LRO_DESCRIPTORS       8
+#define IXGBE_MAX_LRO_AGGREGATE         32
+
 /* wrapper around a pointer to a socket buffer,
  * so a DMA handle can be stored along with the buffer */
 struct ixgbe_tx_buffer {
@@ -150,6 +154,8 @@ struct ixgbe_ring {
 	/* cpu for tx queue */
 	int cpu;
 #endif
+	struct net_lro_mgr lro_mgr;
+	bool lro_used;
 	struct ixgbe_queue_stats stats;
 	u8 v_idx; /* maps directly to the index for this ring in the hardware
 		   * vector array, can also be used for finding the bit in EICR
@@ -287,6 +293,9 @@ struct ixgbe_adapter {
=20
 	unsigned long state;
 	u64 tx_busy;
+	u64 lro_aggregated;
+	u64 lro_flushed;
+	u64 lro_no_desc;
 };
=20
 enum ixbge_state_t {
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgb=
e_ethtool.c
index 4e46377..12990b1 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -90,6 +90,8 @@ static struct ixgbe_stats ixgbe_gstrings_stats[] =3D =
{
 	{"rx_header_split", IXGBE_STAT(rx_hdr_split)},
 	{"alloc_rx_page_failed", IXGBE_STAT(alloc_rx_page_failed)},
 	{"alloc_rx_buff_failed", IXGBE_STAT(alloc_rx_buff_failed)},
+	{"lro_aggregated", IXGBE_STAT(lro_aggregated)},
+	{"lro_flushed", IXGBE_STAT(lro_flushed)},
 };
=20
 #define IXGBE_QUEUE_STATS_LEN \
@@ -787,6 +789,7 @@ static void ixgbe_get_ethtool_stats(struct net_devi=
ce *netdev,
 	int stat_count =3D sizeof(struct ixgbe_queue_stats) / sizeof(u64);
 	int j, k;
 	int i;
+	u64 aggregated =3D 0, flushed =3D 0, no_desc =3D 0;
=20
 	ixgbe_update_stats(adapter);
 	for (i =3D 0; i < IXGBE_GLOBAL_STATS_LEN; i++) {
@@ -801,11 +804,17 @@ static void ixgbe_get_ethtool_stats(struct net_de=
vice *netdev,
 		i +=3D k;
 	}
 	for (j =3D 0; j < adapter->num_rx_queues; j++) {
+		aggregated +=3D adapter->rx_ring[j].lro_mgr.stats.aggregated;
+		flushed +=3D adapter->rx_ring[j].lro_mgr.stats.flushed;
+		no_desc +=3D adapter->rx_ring[j].lro_mgr.stats.no_desc;
 		queue_stat =3D (u64 *)&adapter->rx_ring[j].stats;
 		for (k =3D 0; k < stat_count; k++)
 			data[i + k] =3D queue_stat[k];
 		i +=3D k;
 	}
+	adapter->lro_aggregated =3D aggregated;
+	adapter->lro_flushed =3D flushed;
+	adapter->lro_no_desc =3D no_desc;
 }
=20
 static void ixgbe_get_strings(struct net_device *netdev, u32 stringset=
,
@@ -973,6 +982,8 @@ static struct ethtool_ops ixgbe_ethtool_ops =3D {
 	.get_ethtool_stats      =3D ixgbe_get_ethtool_stats,
 	.get_coalesce           =3D ixgbe_get_coalesce,
 	.set_coalesce           =3D ixgbe_set_coalesce,
+	.get_flags              =3D ethtool_op_get_flags,
+	.set_flags              =3D ethtool_op_set_flags,
 };
=20
 void ixgbe_set_ethtool_ops(struct net_device *netdev)
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_m=
ain.c
index 0d37c90..f429c9a 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -389,24 +389,39 @@ static int __ixgbe_notify_dca(struct device *dev,=
 void *data)
  * ixgbe_receive_skb - Send a completed packet up the stack
  * @adapter: board private structure
  * @skb: packet to send up
- * @is_vlan: packet has a VLAN tag
- * @tag: VLAN tag from descriptor
+ * @status: hardware indication of status of receive
+ * @rx_ring: rx descriptor ring (for a specific queue) to setup
+ * @rx_desc: rx descriptor
  **/
 static void ixgbe_receive_skb(struct ixgbe_adapter *adapter,
-			      struct sk_buff *skb, bool is_vlan,
-			      u16 tag)
+			      struct sk_buff *skb, u8 status,
+			      struct ixgbe_ring *ring,
+                              union ixgbe_adv_rx_desc *rx_desc)
 {
-	if (!(adapter->flags & IXGBE_FLAG_IN_NETPOLL)) {
-		if (adapter->vlgrp && is_vlan)
-			vlan_hwaccel_receive_skb(skb, adapter->vlgrp, tag);
-		else
-			netif_receive_skb(skb);
-	} else {
+	bool is_vlan =3D (status & IXGBE_RXD_STAT_VP);
+	u16 tag =3D le16_to_cpu(rx_desc->wb.upper.vlan);
=20
+	if (adapter->netdev->features & NETIF_F_LRO &&
+	    skb->ip_summed =3D=3D CHECKSUM_UNNECESSARY) {
 		if (adapter->vlgrp && is_vlan)
-			vlan_hwaccel_rx(skb, adapter->vlgrp, tag);
+			lro_vlan_hwaccel_receive_skb(&ring->lro_mgr, skb,
+			                             adapter->vlgrp, tag,
+			                             rx_desc);
 		else
-			netif_rx(skb);
+			lro_receive_skb(&ring->lro_mgr, skb, rx_desc);
+		ring->lro_used =3D true;
+	} else {
+		if (!(adapter->flags & IXGBE_FLAG_IN_NETPOLL)) {
+			if (adapter->vlgrp && is_vlan)
+				vlan_hwaccel_receive_skb(skb, adapter->vlgrp, tag);
+			else
+				netif_receive_skb(skb);
+		} else {
+			if (adapter->vlgrp && is_vlan)
+				vlan_hwaccel_rx(skb, adapter->vlgrp, tag);
+			else
+				netif_rx(skb);
+		}
 	}
 }
=20
@@ -546,8 +561,8 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_adapter=
 *adapter,
 	struct sk_buff *skb;
 	unsigned int i;
 	u32 upper_len, len, staterr;
-	u16 hdr_info, vlan_tag;
-	bool is_vlan, cleaned =3D false;
+	u16 hdr_info;
+	bool cleaned =3D false;
 	int cleaned_count =3D 0;
 	unsigned int total_rx_bytes =3D 0, total_rx_packets =3D 0;
=20
@@ -556,8 +571,6 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_adapter=
 *adapter,
 	rx_desc =3D IXGBE_RX_DESC_ADV(*rx_ring, i);
 	staterr =3D le32_to_cpu(rx_desc->wb.upper.status_error);
 	rx_buffer_info =3D &rx_ring->rx_buffer_info[i];
-	is_vlan =3D (staterr & IXGBE_RXD_STAT_VP);
-	vlan_tag =3D le16_to_cpu(rx_desc->wb.upper.vlan);
=20
 	while (staterr & IXGBE_RXD_STAT_DD) {
 		if (*work_done >=3D work_to_do)
@@ -635,7 +648,7 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_adapter=
 *adapter,
 		total_rx_packets++;
=20
 		skb->protocol =3D eth_type_trans(skb, netdev);
-		ixgbe_receive_skb(adapter, skb, is_vlan, vlan_tag);
+		ixgbe_receive_skb(adapter, skb, staterr, rx_ring, rx_desc);
 		netdev->last_rx =3D jiffies;
=20
 next_desc:
@@ -652,8 +665,11 @@ next_desc:
 		rx_buffer_info =3D next_buffer;
=20
 		staterr =3D le32_to_cpu(rx_desc->wb.upper.status_error);
-		is_vlan =3D (staterr & IXGBE_RXD_STAT_VP);
-		vlan_tag =3D le16_to_cpu(rx_desc->wb.upper.vlan);
+	}
+
+	if (rx_ring->lro_used) {
+		lro_flush_all(&rx_ring->lro_mgr);
+		rx_ring->lro_used =3D false;
 	}
=20
 	rx_ring->next_to_clean =3D i;
@@ -1382,6 +1398,33 @@ static void ixgbe_configure_tx(struct ixgbe_adap=
ter *adapter)
=20
 #define IXGBE_SRRCTL_BSIZEHDRSIZE_SHIFT			2
 /**
+ * ixgbe_get_skb_hdr - helper function for LRO header processing
+ * @skb: pointer to sk_buff to be added to LRO packet
+ * @iphdr: pointer to tcp header structure
+ * @tcph: pointer to tcp header structure
+ * @hdr_flags: pointer to header flags
+ * @priv: private data
+ **/
+static int ixgbe_get_skb_hdr(struct sk_buff *skb, void **iphdr, void *=
*tcph,
+                             u64 *hdr_flags, void *priv)
+{
+	union ixgbe_adv_rx_desc *rx_desc =3D priv;
+
+	/* Verify that this is a valid IPv4 TCP packet */
+	if (!(rx_desc->wb.lower.lo_dword.pkt_info &
+	    (IXGBE_RXDADV_PKTTYPE_IPV4 | IXGBE_RXDADV_PKTTYPE_TCP)))
+		return -1;
+
+	/* Set network headers */
+	skb_reset_network_header(skb);
+	skb_set_transport_header(skb, ip_hdrlen(skb));
+	*iphdr =3D ip_hdr(skb);
+	*tcph =3D tcp_hdr(skb);
+	*hdr_flags =3D LRO_IPV4 | LRO_TCP;
+	return 0;
+}
+
+/**
  * ixgbe_configure_rx - Configure 8254x Receive Unit after Reset
  * @adapter: board private structure
  *
@@ -1470,6 +1513,17 @@ static void ixgbe_configure_rx(struct ixgbe_adap=
ter *adapter)
 		adapter->rx_ring[i].tail =3D IXGBE_RDT(i);
 	}
=20
+	/* Intitial LRO Settings */
+	adapter->rx_ring[i].lro_mgr.max_aggr =3D IXGBE_MAX_LRO_AGGREGATE;
+	adapter->rx_ring[i].lro_mgr.max_desc =3D IXGBE_MAX_LRO_DESCRIPTORS;
+	adapter->rx_ring[i].lro_mgr.get_skb_header =3D ixgbe_get_skb_hdr;
+	adapter->rx_ring[i].lro_mgr.features =3D LRO_F_EXTRACT_VLAN_ID;
+	if (!(adapter->flags & IXGBE_FLAG_IN_NETPOLL))
+		adapter->rx_ring[i].lro_mgr.features |=3D LRO_F_NAPI;
+	adapter->rx_ring[i].lro_mgr.dev =3D adapter->netdev;
+	adapter->rx_ring[i].lro_mgr.ip_summed =3D CHECKSUM_UNNECESSARY;
+	adapter->rx_ring[i].lro_mgr.ip_summed_aggr =3D CHECKSUM_UNNECESSARY;
+
 	if (adapter->flags & IXGBE_FLAG_RSS_ENABLED) {
 		/* Fill out redirection table */
 		for (i =3D 0, j =3D 0; i < 128; i++, j++) {
@@ -2489,12 +2543,18 @@ int ixgbe_setup_rx_resources(struct ixgbe_adapt=
er *adapter,
 	struct pci_dev *pdev =3D adapter->pdev;
 	int size;
=20
+	size =3D sizeof(struct net_lro_desc) * IXGBE_MAX_LRO_DESCRIPTORS;
+	rxdr->lro_mgr.lro_arr =3D vmalloc(size);
+	if (!rxdr->lro_mgr.lro_arr)
+		return -ENOMEM;
+	memset(rxdr->lro_mgr.lro_arr, 0, size);
+
 	size =3D sizeof(struct ixgbe_rx_buffer) * rxdr->count;
 	rxdr->rx_buffer_info =3D vmalloc(size);
 	if (!rxdr->rx_buffer_info) {
 		DPRINTK(PROBE, ERR,
 			"vmalloc allocation failed for the rx desc ring\n");
-		return -ENOMEM;
+		goto alloc_failed;
 	}
 	memset(rxdr->rx_buffer_info, 0, size);
=20
@@ -2508,13 +2568,18 @@ int ixgbe_setup_rx_resources(struct ixgbe_adapt=
er *adapter,
 		DPRINTK(PROBE, ERR,
 			"Memory allocation failed for the rx desc ring\n");
 		vfree(rxdr->rx_buffer_info);
-		return -ENOMEM;
+		goto alloc_failed;
 	}
=20
 	rxdr->next_to_clean =3D 0;
 	rxdr->next_to_use =3D 0;
=20
 	return 0;
+
+alloc_failed:
+	vfree(rxdr->lro_mgr.lro_arr);
+	rxdr->lro_mgr.lro_arr =3D NULL;
+	return -ENOMEM;
 }
=20
 /**
@@ -2565,6 +2630,9 @@ static void ixgbe_free_rx_resources(struct ixgbe_=
adapter *adapter,
 {
 	struct pci_dev *pdev =3D adapter->pdev;
=20
+	vfree(rx_ring->lro_mgr.lro_arr);
+	rx_ring->lro_mgr.lro_arr =3D NULL;
+
 	ixgbe_clean_rx_ring(adapter, rx_ring);
=20
 	vfree(rx_ring->rx_buffer_info);
@@ -3517,6 +3585,7 @@ static int __devinit ixgbe_probe(struct pci_dev *=
pdev,
 			   NETIF_F_HW_VLAN_RX |
 			   NETIF_F_HW_VLAN_FILTER;
=20
+	netdev->features |=3D NETIF_F_LRO;
 	netdev->features |=3D NETIF_F_TSO;
 	netdev->features |=3D NETIF_F_TSO6;
=20
diff --git a/drivers/net/pci-skeleton.c b/drivers/net/pci-skeleton.c
index fffc49b..53451c3 100644
--- a/drivers/net/pci-skeleton.c
+++ b/drivers/net/pci-skeleton.c
@@ -1739,7 +1739,6 @@ static int netdrv_close (struct net_device *dev)
=20
 	spin_unlock_irqrestore (&tp->lock, flags);
=20
-	synchronize_irq (dev->irq);
 	free_irq (dev->irq, dev);
=20
 	netdrv_tx_clear (dev);
diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
index f64d987..37f3116 100644
--- a/drivers/net/sh_eth.c
+++ b/drivers/net/sh_eth.c
@@ -322,7 +322,7 @@ static int sh_eth_dev_init(struct net_device *ndev)
 	ctrl_outl((FIFO_SIZE_T | FIFO_SIZE_R), ioaddr + FDR);
 	ctrl_outl(0, ioaddr + TFTR);
=20
-	ctrl_outl(RMCR_RST, ioaddr + RMCR);
+	ctrl_outl(0, ioaddr + RMCR);
=20
 	rx_int_var =3D mdp->rx_int_var =3D DESC_I_RINT8 | DESC_I_RINT5;
 	tx_int_var =3D mdp->tx_int_var =3D DESC_I_TINT2;
@@ -994,7 +994,7 @@ static int sh_mdio_init(struct net_device *ndev, in=
t id)
 	/* Hook up MII support for ethtool */
 	mdp->mii_bus->name =3D "sh_mii";
 	mdp->mii_bus->dev =3D &ndev->dev;
-	mdp->mii_bus->id =3D id;
+	mdp->mii_bus->id[0] =3D id;
=20
 	/* PHY IRQ */
 	mdp->mii_bus->irq =3D kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);
diff --git a/drivers/net/sh_eth.h b/drivers/net/sh_eth.h
index ca2db6b..e01e1c3 100644
--- a/drivers/net/sh_eth.h
+++ b/drivers/net/sh_eth.h
@@ -40,8 +40,6 @@
 #define PKT_BUF_SZ		1538
=20
 /* Chip Base Address */
-#define SH_ETH0_BASE 0xA7000000
-#define SH_ETH1_BASE 0xA7000400
 #define SH_TSU_ADDR 0xA7000804
=20
 /* Chip Registers */
@@ -462,3 +460,5 @@ static void swaps(char *src, int len)
 		*p =3D swab32(*p);
 #endif
 }
+
+#endif
diff --git a/drivers/net/tsi108_eth.c b/drivers/net/tsi108_eth.c
index febfaee..43fde99 100644
--- a/drivers/net/tsi108_eth.c
+++ b/drivers/net/tsi108_eth.c
@@ -1437,7 +1437,6 @@ static int tsi108_close(struct net_device *dev)
 		dev_kfree_skb(skb);
 	}
=20
-	synchronize_irq(data->irq_num);
 	free_irq(data->irq_num, dev);
=20
 	/* Discard the RX ring. */
diff --git a/drivers/net/tulip/21142.c b/drivers/net/tulip/21142.c
index 6c400cc..1210fb3 100644
--- a/drivers/net/tulip/21142.c
+++ b/drivers/net/tulip/21142.c
@@ -1,7 +1,6 @@
 /*
 	drivers/net/tulip/21142.c
=20
-	Maintained by Valerie Henson <val_henson@linux.intel.com>
 	Copyright 2000,2001  The Linux Kernel Team
 	Written/copyright 1994-2001 by Donald Becker.
=20
@@ -9,9 +8,8 @@
 	of the GNU General Public License, incorporated herein by reference.
=20
 	Please refer to Documentation/DocBook/tulip-user.{pdf,ps,html}
-	for more information on this driver, or visit the project
-	Web page at http://sourceforge.net/projects/tulip/
-
+	for more information on this driver.
+	Please submit bugs to http://bugzilla.kernel.org/ .
 */
=20
 #include <linux/delay.h>
diff --git a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
index 1b5edd6..9281d06 100644
--- a/drivers/net/tulip/de2104x.c
+++ b/drivers/net/tulip/de2104x.c
@@ -124,8 +124,6 @@ MODULE_PARM_DESC (rx_copybreak, "de2104x Breakpoint=
 at which Rx packets are copi
 /* Time in jiffies before concluding the transmitter is hung. */
 #define TX_TIMEOUT		(6*HZ)
=20
-#define DE_UNALIGNED_16(a)	(u16)(get_unaligned((u16 *)(a)))
-
 /* This is a mysterious value that can be written to CSR11 in the 2104=
0 (only)
    to support a pre-NWay full-duplex signaling mechanism using short f=
rames.
    No one knows what it should be, but if left at its default value so=
me
@@ -1811,7 +1809,7 @@ static void __devinit de21041_get_srom_info (stru=
ct de_private *de)
 		goto bad_srom;
=20
 	/* get default media type */
-	switch (DE_UNALIGNED_16(&il->default_media)) {
+	switch (get_unaligned(&il->default_media)) {
 	case 0x0001:  de->media_type =3D DE_MEDIA_BNC; break;
 	case 0x0002:  de->media_type =3D DE_MEDIA_AUI; break;
 	case 0x0204:  de->media_type =3D DE_MEDIA_TP_FD; break;
@@ -1875,9 +1873,9 @@ static void __devinit de21041_get_srom_info (stru=
ct de_private *de)
 		bufp +=3D sizeof (ib->opts);
=20
 		if (ib->opts & MediaCustomCSRs) {
-			de->media[idx].csr13 =3D DE_UNALIGNED_16(&ib->csr13);
-			de->media[idx].csr14 =3D DE_UNALIGNED_16(&ib->csr14);
-			de->media[idx].csr15 =3D DE_UNALIGNED_16(&ib->csr15);
+			de->media[idx].csr13 =3D get_unaligned(&ib->csr13);
+			de->media[idx].csr14 =3D get_unaligned(&ib->csr14);
+			de->media[idx].csr15 =3D get_unaligned(&ib->csr15);
 			bufp +=3D sizeof(ib->csr13) + sizeof(ib->csr14) +
 				sizeof(ib->csr15);
=20
diff --git a/drivers/net/tulip/eeprom.c b/drivers/net/tulip/eeprom.c
index da2206f..0dcced1 100644
--- a/drivers/net/tulip/eeprom.c
+++ b/drivers/net/tulip/eeprom.c
@@ -1,7 +1,6 @@
 /*
 	drivers/net/tulip/eeprom.c
=20
-	Maintained by Valerie Henson <val_henson@linux.intel.com>
 	Copyright 2000,2001  The Linux Kernel Team
 	Written/copyright 1994-2001 by Donald Becker.
=20
@@ -9,9 +8,8 @@
 	of the GNU General Public License, incorporated herein by reference.
=20
 	Please refer to Documentation/DocBook/tulip-user.{pdf,ps,html}
-	for more information on this driver, or visit the project
-	Web page at http://sourceforge.net/projects/tulip/
-
+	for more information on this driver.
+	Please submit bug reports to http://bugzilla.kernel.org/.
 */
=20
 #include <linux/pci.h>
diff --git a/drivers/net/tulip/interrupt.c b/drivers/net/tulip/interrup=
t.c
index 6284afd..c6bad98 100644
--- a/drivers/net/tulip/interrupt.c
+++ b/drivers/net/tulip/interrupt.c
@@ -1,7 +1,6 @@
 /*
 	drivers/net/tulip/interrupt.c
=20
-	Maintained by Valerie Henson <val_henson@linux.intel.com>
 	Copyright 2000,2001  The Linux Kernel Team
 	Written/copyright 1994-2001 by Donald Becker.
=20
@@ -9,8 +8,8 @@
 	of the GNU General Public License, incorporated herein by reference.
=20
 	Please refer to Documentation/DocBook/tulip-user.{pdf,ps,html}
-	for more information on this driver, or visit the project
-	Web page at http://sourceforge.net/projects/tulip/
+	for more information on this driver.
+        Please submit bugs to http://bugzilla.kernel.org/ .
=20
 */
=20
diff --git a/drivers/net/tulip/media.c b/drivers/net/tulip/media.c
index b562566..91cf9c8 100644
--- a/drivers/net/tulip/media.c
+++ b/drivers/net/tulip/media.c
@@ -1,7 +1,6 @@
 /*
 	drivers/net/tulip/media.c
=20
-	Maintained by Valerie Henson <val_henson@linux.intel.com>
 	Copyright 2000,2001  The Linux Kernel Team
 	Written/copyright 1994-2001 by Donald Becker.
=20
@@ -9,9 +8,9 @@
 	of the GNU General Public License, incorporated herein by reference.
=20
 	Please refer to Documentation/DocBook/tulip-user.{pdf,ps,html}
-	for more information on this driver, or visit the project
-	Web page at http://sourceforge.net/projects/tulip/
+	for more information on this driver.
=20
+	Please submit bugs to http://bugzilla.kernel.org/ .
 */
=20
 #include <linux/kernel.h>
diff --git a/drivers/net/tulip/pnic.c b/drivers/net/tulip/pnic.c
index be82a2e..d3253ed 100644
--- a/drivers/net/tulip/pnic.c
+++ b/drivers/net/tulip/pnic.c
@@ -1,7 +1,6 @@
 /*
 	drivers/net/tulip/pnic.c
=20
-	Maintained by Valerie Henson <val_henson@linux.intel.com>
 	Copyright 2000,2001  The Linux Kernel Team
 	Written/copyright 1994-2001 by Donald Becker.
=20
@@ -9,9 +8,9 @@
 	of the GNU General Public License, incorporated herein by reference.
=20
 	Please refer to Documentation/DocBook/tulip-user.{pdf,ps,html}
-	for more information on this driver, or visit the project
-	Web page at http://sourceforge.net/projects/tulip/
+	for more information on this driver.
=20
+	Please submit bugs to http://bugzilla.kernel.org/ .
 */
=20
 #include <linux/kernel.h>
diff --git a/drivers/net/tulip/pnic2.c b/drivers/net/tulip/pnic2.c
index 4e4a879..f495791 100644
--- a/drivers/net/tulip/pnic2.c
+++ b/drivers/net/tulip/pnic2.c
@@ -1,7 +1,6 @@
 /*
 	drivers/net/tulip/pnic2.c
=20
-	Maintained by Valerie Henson <val_henson@linux.intel.com>
 	Copyright 2000,2001  The Linux Kernel Team
 	Written/copyright 1994-2001 by Donald Becker.
         Modified to hep support PNIC_II by Kevin B. Hendricks
@@ -10,9 +9,9 @@
 	of the GNU General Public License, incorporated herein by reference.
=20
 	Please refer to Documentation/DocBook/tulip-user.{pdf,ps,html}
-	for more information on this driver, or visit the project
-	Web page at http://sourceforge.net/projects/tulip/
+	for more information on this driver.
=20
+        Please submit bugs to http://bugzilla.kernel.org/ .
 */
=20
=20
diff --git a/drivers/net/tulip/timer.c b/drivers/net/tulip/timer.c
index d2c1f42..a0e0842 100644
--- a/drivers/net/tulip/timer.c
+++ b/drivers/net/tulip/timer.c
@@ -1,7 +1,6 @@
 /*
 	drivers/net/tulip/timer.c
=20
-	Maintained by Valerie Henson <val_henson@linux.intel.com>
 	Copyright 2000,2001  The Linux Kernel Team
 	Written/copyright 1994-2001 by Donald Becker.
=20
@@ -9,11 +8,12 @@
 	of the GNU General Public License, incorporated herein by reference.
=20
 	Please refer to Documentation/DocBook/tulip-user.{pdf,ps,html}
-	for more information on this driver, or visit the project
-	Web page at http://sourceforge.net/projects/tulip/
+	for more information on this driver.
=20
+	Please submit bugs to http://bugzilla.kernel.org/ .
 */
=20
+
 #include "tulip.h"
=20
=20
diff --git a/drivers/net/tulip/tulip.h b/drivers/net/tulip/tulip.h
index 92c68a2..19abbc3 100644
--- a/drivers/net/tulip/tulip.h
+++ b/drivers/net/tulip/tulip.h
@@ -8,9 +8,9 @@
 	of the GNU General Public License, incorporated herein by reference.
=20
 	Please refer to Documentation/DocBook/tulip-user.{pdf,ps,html}
-	for more information on this driver, or visit the project
-	Web page at http://sourceforge.net/projects/tulip/
+	for more information on this driver.
=20
+	Please submit bugs to http://bugzilla.kernel.org/ .
 */
=20
 #ifndef __NET_TULIP_H__
diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_c=
ore.c
index af8d2c4..cafa89e 100644
--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -1,7 +1,5 @@
-/* tulip_core.c: A DEC 21x4x-family ethernet driver for Linux. */
+/*	tulip_core.c: A DEC 21x4x-family ethernet driver for Linux.
=20
-/*
-	Maintained by Valerie Henson <val_henson@linux.intel.com>
 	Copyright 2000,2001  The Linux Kernel Team
 	Written/copyright 1994-2001 by Donald Becker.
=20
@@ -9,9 +7,9 @@
 	of the GNU General Public License, incorporated herein by reference.
=20
 	Please refer to Documentation/DocBook/tulip-user.{pdf,ps,html}
-	for more information on this driver, or visit the project
-	Web page at http://sourceforge.net/projects/tulip/
+	for more information on this driver.
=20
+	Please submit bugs to http://bugzilla.kernel.org/ .
 */
=20
=20
diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index c0dd25b..8549f11 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -334,8 +334,6 @@ enum state_values {
 #define TYPHOON_RESET_TIMEOUT_NOSLEEP	((6 * 1000000) / TYPHOON_UDELAY)
 #define TYPHOON_WAIT_TIMEOUT		((1000000 / 2) / TYPHOON_UDELAY)
=20
-#define typhoon_synchronize_irq(x) synchronize_irq(x)
-
 #if defined(NETIF_F_TSO)
 #define skb_tso_size(x)		(skb_shinfo(x)->gso_size)
 #define TSO_NUM_DESCRIPTORS	2
@@ -2143,7 +2141,6 @@ typhoon_close(struct net_device *dev)
 		printk(KERN_ERR "%s: unable to stop runtime\n", dev->name);
=20
 	/* Make sure there is no irq handler running on a different CPU. */
-	typhoon_synchronize_irq(dev->irq);
 	free_irq(dev->irq, dev);
=20
 	typhoon_free_rx_rings(tp);
diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.=
c
index ae467f1..61c98be 100644
--- a/drivers/net/usb/rndis_host.c
+++ b/drivers/net/usb/rndis_host.c
@@ -74,7 +74,7 @@ EXPORT_SYMBOL_GPL(rndis_status);
  * Call context is likely probe(), before interface name is known,
  * which is why we won't try to use it in the diagnostics.
  */
-int rndis_command(struct usbnet *dev, struct rndis_msg_hdr *buf)
+int rndis_command(struct usbnet *dev, struct rndis_msg_hdr *buf, int b=
uflen)
 {
 	struct cdc_state	*info =3D (void *) &dev->data;
 	int			master_ifnum;
@@ -121,7 +121,7 @@ int rndis_command(struct usbnet *dev, struct rndis_=
msg_hdr *buf)
 			USB_CDC_GET_ENCAPSULATED_RESPONSE,
 			USB_DIR_IN | USB_TYPE_CLASS | USB_RECIP_INTERFACE,
 			0, master_ifnum,
-			buf, CONTROL_BUFFER_SIZE,
+			buf, buflen,
 			RNDIS_CONTROL_TIMEOUT_MS);
 		if (likely(retval >=3D 8)) {
 			msg_len =3D le32_to_cpu(buf->msg_len);
@@ -239,7 +239,7 @@ static int rndis_query(struct usbnet *dev, struct u=
sb_interface *intf,
 	u.get->len =3D cpu_to_le32(in_len);
 	u.get->offset =3D ccpu2(20);
=20
-	retval =3D rndis_command(dev, u.header);
+	retval =3D rndis_command(dev, u.header, CONTROL_BUFFER_SIZE);
 	if (unlikely(retval < 0)) {
 		dev_err(&intf->dev, "RNDIS_MSG_QUERY(0x%08x) failed, %d\n",
 				oid, retval);
@@ -328,7 +328,7 @@ generic_rndis_bind(struct usbnet *dev, struct usb_i=
nterface *intf, int flags)
 	u.init->max_transfer_size =3D cpu_to_le32(dev->rx_urb_size);
=20
 	net->change_mtu =3D NULL;
-	retval =3D rndis_command(dev, u.header);
+	retval =3D rndis_command(dev, u.header, CONTROL_BUFFER_SIZE);
 	if (unlikely(retval < 0)) {
 		/* it might not even be an RNDIS device!! */
 		dev_err(&intf->dev, "RNDIS init failed, %d\n", retval);
@@ -409,7 +409,7 @@ generic_rndis_bind(struct usbnet *dev, struct usb_i=
nterface *intf, int flags)
 	u.set->offset =3D ccpu2((sizeof *u.set) - 8);
 	*(__le32 *)(u.buf + sizeof *u.set) =3D RNDIS_DEFAULT_FILTER;
=20
-	retval =3D rndis_command(dev, u.header);
+	retval =3D rndis_command(dev, u.header, CONTROL_BUFFER_SIZE);
 	if (unlikely(retval < 0)) {
 		dev_err(&intf->dev, "rndis set packet filter, %d\n", retval);
 		goto halt_fail_and_release;
@@ -424,7 +424,7 @@ halt_fail_and_release:
 	memset(u.halt, 0, sizeof *u.halt);
 	u.halt->msg_type =3D RNDIS_MSG_HALT;
 	u.halt->msg_len =3D ccpu2(sizeof *u.halt);
-	(void) rndis_command(dev, (void *)u.halt);
+	(void) rndis_command(dev, (void *)u.halt, CONTROL_BUFFER_SIZE);
 fail_and_release:
 	usb_set_intfdata(info->data, NULL);
 	usb_driver_release_interface(driver_of(intf), info->data);
@@ -449,7 +449,7 @@ void rndis_unbind(struct usbnet *dev, struct usb_in=
terface *intf)
 	if (halt) {
 		halt->msg_type =3D RNDIS_MSG_HALT;
 		halt->msg_len =3D ccpu2(sizeof *halt);
-		(void) rndis_command(dev, (void *)halt);
+		(void) rndis_command(dev, (void *)halt, CONTROL_BUFFER_SIZE);
 		kfree(halt);
 	}
=20
diff --git a/drivers/net/wireless/rndis_wlan.c b/drivers/net/wireless/r=
ndis_wlan.c
index a36d2c8..f001f2a 100644
--- a/drivers/net/wireless/rndis_wlan.c
+++ b/drivers/net/wireless/rndis_wlan.c
@@ -448,7 +448,7 @@ static int rndis_query_oid(struct usbnet *dev, __le=
32 oid, void *data, int *len)
 	u.get->msg_len =3D ccpu2(sizeof *u.get);
 	u.get->oid =3D oid;
=20
-	ret =3D rndis_command(dev, u.header);
+	ret =3D rndis_command(dev, u.header, buflen);
 	if (ret =3D=3D 0) {
 		ret =3D le32_to_cpu(u.get_c->len);
 		*len =3D (*len > ret) ? ret : *len;
@@ -498,7 +498,7 @@ static int rndis_set_oid(struct usbnet *dev, __le32=
 oid, void *data, int len)
 	u.set->handle =3D ccpu2(0);
 	memcpy(u.buf + sizeof(*u.set), data, len);
=20
-	ret =3D rndis_command(dev, u.header);
+	ret =3D rndis_command(dev, u.header, buflen);
 	if (ret =3D=3D 0)
 		ret =3D rndis_error_status(u.set_c->status);
=20
diff --git a/drivers/pci/pci-acpi.c b/drivers/pci/pci-acpi.c
index 9d6fc8e..f7904ff 100644
--- a/drivers/pci/pci-acpi.c
+++ b/drivers/pci/pci-acpi.c
@@ -315,6 +315,25 @@ static pci_power_t acpi_pci_choose_state(struct pc=
i_dev *pdev,
 	}
 	return PCI_POWER_ERROR;
 }
+
+static int acpi_platform_enable_wakeup(struct device *dev, int is_on)
+{
+	struct acpi_device	*adev;
+	int			status;
+
+	if (!device_can_wakeup(dev))
+		return -EINVAL;
+
+	if (is_on && !device_may_wakeup(dev))
+		return -EINVAL;
+
+	status =3D acpi_bus_get_device(DEVICE_ACPI_HANDLE(dev), &adev);
+	if (status < 0)
+		return status;
+
+	adev->wakeup.state.enabled =3D !!is_on;
+	return 0;
+}
 #endif
=20
 static int acpi_pci_set_power_state(struct pci_dev *dev, pci_power_t s=
tate)
@@ -399,6 +418,7 @@ static int __init acpi_pci_init(void)
 		return 0;
 #ifdef	CONFIG_ACPI_SLEEP
 	platform_pci_choose_state =3D acpi_pci_choose_state;
+	platform_enable_wakeup =3D acpi_platform_enable_wakeup;
 #endif
 	platform_pci_set_power_state =3D acpi_pci_set_power_state;
 	return 0;
diff --git a/include/linux/dm9000.h b/include/linux/dm9000.h
index a375046..fc82446 100644
--- a/include/linux/dm9000.h
+++ b/include/linux/dm9000.h
@@ -21,6 +21,7 @@
 #define DM9000_PLATF_32BITONLY	(0x0004)
 #define DM9000_PLATF_EXT_PHY	(0x0008)
 #define DM9000_PLATF_NO_EEPROM	(0x0010)
+#define DM9000_PLATF_SIMPLE_PHY (0x0020)  /* Use NSR to find LinkStatu=
s */
=20
 /* platfrom data for platfrom device structure's platfrom_data field *=
/
=20
diff --git a/include/linux/usb/rndis_host.h b/include/linux/usb/rndis_h=
ost.h
index 29d6458..0a6e6d4 100644
--- a/include/linux/usb/rndis_host.h
+++ b/include/linux/usb/rndis_host.h
@@ -260,7 +260,8 @@ struct rndis_keepalive_c {	/* IN (optionally OUT) *=
/
=20
=20
 extern void rndis_status(struct usbnet *dev, struct urb *urb);
-extern int rndis_command(struct usbnet *dev, struct rndis_msg_hdr *buf=
);
+extern int
+rndis_command(struct usbnet *dev, struct rndis_msg_hdr *buf, int bufle=
n);
 extern int
 generic_rndis_bind(struct usbnet *dev, struct usb_interface *intf, int=
 flags);
 extern void rndis_unbind(struct usbnet *dev, struct usb_interface *int=
f);
