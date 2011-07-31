From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 09/71] smsc: Move the SMC (SMSC) drivers
Date: Sat, 30 Jul 2011 20:26:28 -0700
Message-ID: <1312082850-24914-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Nicolas Pitre <nico@fluxnic.net>,
	Donald Becker <becker@scyld.com>, Erik Stahlman <erik@vt.edu>,
	Dustin McIntire <dustin@sensoria.com>,
	Steve Glendinning <steve.glendinning@smsc.com>,
	David Hinds <dahinds@users.sourceforge.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:2191 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753091Ab1GaD1n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Jul 2011 23:27:43 -0400
In-Reply-To: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Moves the SMC (SMSC) drivers into drivers/net/ethernet/smsc/ and the
necessary Kconfig and Makefile changes.  Also did some cleanup
of NET_VENDOR_SMC Kconfig tag for the 8390 based drivers.

CC: Nicolas Pitre <nico@fluxnic.net>
CC: Donald Becker <becker@scyld.com>
CC: Erik Stahlman <erik@vt.edu>
CC: Dustin McIntire <dustin@sensoria.com>
CC: Steve Glendinning <steve.glendinning@smsc.com>
CC: David Hinds <dahinds@users.sourceforge.net>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                                        |    6 +-
 drivers/net/Kconfig                                |  105 ----------------
 drivers/net/Makefile                               |    7 -
 drivers/net/ethernet/8390/Kconfig                  |   21 +---
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/smsc/Kconfig                  |  128 ++++++++++++++++++++
 drivers/net/ethernet/smsc/Makefile                 |   11 ++
 drivers/net/{ => ethernet/smsc}/epic100.c          |    0
 drivers/net/{ => ethernet/smsc}/smc911x.c          |    0
 drivers/net/{ => ethernet/smsc}/smc911x.h          |    0
 drivers/net/{ => ethernet/smsc}/smc9194.c          |    0
 drivers/net/{ => ethernet/smsc}/smc9194.h          |    0
 .../net/{pcmcia => ethernet/smsc}/smc91c92_cs.c    |    0
 drivers/net/{ => ethernet/smsc}/smc91x.c           |    0
 drivers/net/{ => ethernet/smsc}/smc91x.h           |    0
 drivers/net/{ => ethernet/smsc}/smsc911x.c         |    0
 drivers/net/{ => ethernet/smsc}/smsc911x.h         |    0
 drivers/net/{ => ethernet/smsc}/smsc9420.c         |    0
 drivers/net/{ => ethernet/smsc}/smsc9420.h         |    0
 drivers/net/pcmcia/Kconfig                         |   11 --
 drivers/net/pcmcia/Makefile                        |    1 -
 22 files changed, 148 insertions(+), 144 deletions(-)
 create mode 100644 drivers/net/ethernet/smsc/Kconfig
 create mode 100644 drivers/net/ethernet/smsc/Makefile
 rename drivers/net/{ => ethernet/smsc}/epic100.c (100%)
 rename drivers/net/{ => ethernet/smsc}/smc911x.c (100%)
 rename drivers/net/{ => ethernet/smsc}/smc911x.h (100%)
 rename drivers/net/{ => ethernet/smsc}/smc9194.c (100%)
 rename drivers/net/{ => ethernet/smsc}/smc9194.h (100%)
 rename drivers/net/{pcmcia => ethernet/smsc}/smc91c92_cs.c (100%)
 rename drivers/net/{ => ethernet/smsc}/smc91x.c (100%)
 rename drivers/net/{ => ethernet/smsc}/smc91x.h (100%)
 rename drivers/net/{ => ethernet/smsc}/smsc911x.c (100%)
 rename drivers/net/{ => ethernet/smsc}/smsc911x.h (100%)
 rename drivers/net/{ => ethernet/smsc}/smsc9420.c (100%)
 rename drivers/net/{ => ethernet/smsc}/smsc9420.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index eb35265..31c76f4 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5831,7 +5831,7 @@ F:	mm/sl?b.c
 SMC91x ETHERNET DRIVER
 M:	Nicolas Pitre <nico@fluxnic.net>
 S:	Odd Fixes
-F:	drivers/net/smc91x.*
+F:	drivers/net/ethernet/smsc/smc91x.*
 
 SMM665 HARDWARE MONITOR DRIVER
 M:	Guenter Roeck <linux@roeck-us.net>
@@ -5866,13 +5866,13 @@ M:	Steve Glendinning <steve.glendinning@smsc.com>
 L:	netdev@vger.kernel.org
 S:	Supported
 F:	include/linux/smsc911x.h
-F:	drivers/net/smsc911x.*
+F:	drivers/net/ethernet/smsc/smsc911x.*
 
 SMSC9420 PCI ETHERNET DRIVER
 M:	Steve Glendinning <steve.glendinning@smsc.com>
 L:	netdev@vger.kernel.org
 S:	Supported
-F:	drivers/net/smsc9420.*
+F:	drivers/net/ethernet/smsc/smsc9420.*
 
 SN-IA64 (Itanium) SUB-PLATFORM
 M:	Jes Sorensen <jes@sgi.com>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 8879506..c0aa2e3 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -508,39 +508,6 @@ config BFIN_MAC_USE_HWSTAMP
 	help
 	  To support the IEEE 1588 Precision Time Protocol (PTP), select y here
 
-config SMC9194
-	tristate "SMC 9194 support"
-	depends on NET_VENDOR_SMC && (ISA || MAC && BROKEN)
-	select CRC32
-	---help---
-	  This is support for the SMC9xxx based Ethernet cards. Choose this
-	  option if you have a DELL laptop with the docking station, or
-	  another SMC9192/9194 based chipset.  Say Y if you want it compiled
-	  into the kernel, and read the file
-	  <file:Documentation/networking/smc9.txt> and the Ethernet-HOWTO,
-	  available from <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called smc9194.
-
-config SMC91X
-	tristate "SMC 91C9x/91C1xxx support"
-	select CRC32
-	select MII
-	depends on ARM || M32R || SUPERH || \
-		MIPS || BLACKFIN || MN10300 || COLDFIRE
-	help
-	  This is a driver for SMC's 91x series of Ethernet chipsets,
-	  including the SMC91C94 and the SMC91C111. Say Y if you want it
-	  compiled into the kernel, and read the file
-	  <file:Documentation/networking/smc9.txt>  and the Ethernet-HOWTO,
-	  available from  <http://www.tldp.org/docs.html#howto>.
-
-	  This driver is also available as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want).
-	  The module will be called smc91x.  If you want to compile it as a
-	  module, say M here and read <file:Documentation/kbuild/modules.txt>.
-
 config PXA168_ETH
 	tristate "Marvell pxa168 ethernet support"
 	depends on CPU_PXA168
@@ -655,44 +622,6 @@ config GRETH
 	help
 	  Say Y here if you want to use the Aeroflex Gaisler GRETH Ethernet MAC.
 
-config SMC911X
-	tristate "SMSC LAN911[5678] support"
-	select CRC32
-	select MII
-	depends on ARM || SUPERH || MN10300
-	help
-	  This is a driver for SMSC's LAN911x series of Ethernet chipsets
-	  including the new LAN9115, LAN9116, LAN9117, and LAN9118.
-	  Say Y if you want it compiled into the kernel, 
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  This driver is also available as a module. The module will be 
-	  called smc911x.  If you want to compile it as a module, say M 
-	  here and read <file:Documentation/kbuild/modules.txt>
-
-config SMSC911X
-	tristate "SMSC LAN911x/LAN921x families embedded ethernet support"
-	depends on ARM || SUPERH || BLACKFIN || MIPS || MN10300
-	select CRC32
-	select MII
-	select PHYLIB
-	---help---
-	  Say Y here if you want support for SMSC LAN911x and LAN921x families
-	  of ethernet controllers.
-
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>. The module
-	  will be called smsc911x.
-
-config SMSC911X_ARCH_HOOKS
-	def_bool n
-	depends on SMSC911X
-	help
-	  If the arch enables this, it allows the arch to implement various
-	  hooks for more comprehensive interrupt control and also to override
-	  the source of the MAC address.
-
 config NET_VENDOR_RACAL
 	bool "Racal-Interlan (Micom) NI cards"
 	depends on ISA
@@ -1091,33 +1020,6 @@ config SIS900
 	  To compile this driver as a module, choose M here: the module
 	  will be called sis900.  This is recommended.
 
-config EPIC100
-	tristate "SMC EtherPower II"
-	depends on NET_PCI && PCI
-	select CRC32
-	select MII
-	help
-	  This driver is for the SMC EtherPower II 9432 PCI Ethernet NIC,
-	  which is based on the SMC83c17x (EPIC/100).
-	  More specific information and updates are available from
-	  <http://www.scyld.com/network/epic100.html>.
-
-config SMSC9420
-	tristate "SMSC LAN9420 PCI ethernet adapter support"
-	depends on NET_PCI && PCI
-	select CRC32
-	select PHYLIB
-	select SMSC_PHY
-	help
-	  This is a driver for SMSC's LAN9420 PCI ethernet adapter.
-	  Say Y if you want it compiled into the kernel,
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  This driver is also available as a module. The module will be
-	  called smsc9420.  If you want to compile it as a module, say M
-	  here and read <file:Documentation/kbuild/modules.txt>
-
 config SUNDANCE
 	tristate "Sundance Alta support"
 	depends on NET_PCI && PCI
@@ -1834,13 +1736,6 @@ config MYRI10GE_DCA
 	  driver.  DCA is a method for warming the CPU cache before data
 	  is used, with the intent of lessening the impact of cache misses.
 
-config NETXEN_NIC
-	tristate "NetXen Multi port (1/10) Gigabit Ethernet NIC"
-	depends on PCI
-	select FW_LOADER
-	help
-	  This enables the support for NetXen's Gigabit Ethernet card.
-
 config NIU
 	tristate "Sun Neptune 10Gbit Ethernet support"
 	depends on PCI
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 8e41978..4dfa35c 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -55,8 +55,6 @@ obj-$(CONFIG_MACE) += mace.o
 obj-$(CONFIG_BMAC) += bmac.o
 
 obj-$(CONFIG_TLAN) += tlan.o
-obj-$(CONFIG_EPIC100) += epic100.o
-obj-$(CONFIG_SMSC9420) += smsc9420.o
 obj-$(CONFIG_SIS190) += sis190.o
 obj-$(CONFIG_SIS900) += sis900.o
 obj-$(CONFIG_R6040) += r6040.o
@@ -95,7 +93,6 @@ obj-$(CONFIG_NET) += Space.o loopback.o
 obj-$(CONFIG_SEEQ8005) += seeq8005.o
 obj-$(CONFIG_NET_SB1000) += sb1000.o
 obj-$(CONFIG_HP100) += hp100.o
-obj-$(CONFIG_SMC9194) += smc9194.o
 obj-$(CONFIG_FEC) += fec.o
 obj-$(CONFIG_FEC_MPC52xx) += fec_mpc52xx.o
 ifeq ($(CONFIG_FEC_MPC52xx_MDIO),y)
@@ -178,9 +175,6 @@ obj-$(CONFIG_IBMVETH) += ibmveth.o
 obj-$(CONFIG_S2IO) += s2io.o
 obj-$(CONFIG_VXGE) += vxge/
 obj-$(CONFIG_MYRI10GE) += myri10ge/
-obj-$(CONFIG_SMC91X) += smc91x.o
-obj-$(CONFIG_SMC911X) += smc911x.o
-obj-$(CONFIG_SMSC911X) += smsc911x.o
 obj-$(CONFIG_PXA168_ETH) += pxa168_eth.o
 obj-$(CONFIG_BFIN_MAC) += bfin_mac.o
 obj-$(CONFIG_DM9000) += dm9000.o
@@ -227,7 +221,6 @@ obj-$(CONFIG_NETCONSOLE) += netconsole.o
 
 obj-$(CONFIG_FS_ENET) += fs_enet/
 
-obj-$(CONFIG_NETXEN_NIC) += netxen/
 obj-$(CONFIG_NIU) += niu.o
 obj-$(CONFIG_VIRTIO_NET) += virtio_net.o
 obj-$(CONFIG_SFC) += sfc/
diff --git a/drivers/net/ethernet/8390/Kconfig b/drivers/net/ethernet/8390/Kconfig
index 072c641..1c48e4f 100644
--- a/drivers/net/ethernet/8390/Kconfig
+++ b/drivers/net/ethernet/8390/Kconfig
@@ -262,22 +262,9 @@ config STNIC
 
 	  If unsure, say N.
 
-config NET_VENDOR_SMC
-	bool "Western Digital/SMC cards"
-	depends on NET_VENDOR_8390 && (ISA || MCA || EISA || MAC)
-	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  Note that the answer to this question doesn't directly affect the
-	  kernel: saying N will just cause the configurator to skip all
-	  the questions about Western Digital cards. If you say Y, you will be
-	  asked for your specific card in the following questions.
-
 config ULTRAMCA
 	tristate "SMC Ultra MCA support"
-	depends on NET_VENDOR_SMC && MCA
+	depends on NET_VENDOR_8390 && MCA
 	select CRC32
 	---help---
 	  If you have a network (Ethernet) card of this type and are running
@@ -289,7 +276,7 @@ config ULTRAMCA
 
 config ULTRA
 	tristate "SMC Ultra support"
-	depends on NET_VENDOR_SMC && ISA
+	depends on NET_VENDOR_8390 && ISA
 	select CRC32
 	---help---
 	  If you have a network (Ethernet) card of this type, say Y and read
@@ -308,7 +295,7 @@ config ULTRA
 
 config ULTRA32
 	tristate "SMC Ultra32 EISA support"
-	depends on NET_VENDOR_SMC && EISA
+	depends on NET_VENDOR_8390 && EISA
 	select CRC32
 	---help---
 	  If you have a network (Ethernet) card of this type, say Y and read
@@ -320,7 +307,7 @@ config ULTRA32
 
 config WD80x3
 	tristate "WD80*3 support"
-	depends on NET_VENDOR_SMC && ISA
+	depends on NET_VENDOR_8390 && ISA
 	select CRC32
 	---help---
 	  If you have a network (Ethernet) card of this type, say Y and read
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index ab591bb..ed5836c 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -18,5 +18,6 @@ source "drivers/net/ethernet/broadcom/Kconfig"
 source "drivers/net/ethernet/chelsio/Kconfig"
 source "drivers/net/ethernet/intel/Kconfig"
 source "drivers/net/ethernet/qlogic/Kconfig"
+source "drivers/net/ethernet/smsc/Kconfig"
 
 endif # ETHERNET
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index d8cf120..983fd27 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -9,3 +9,4 @@ obj-$(CONFIG_NET_VENDOR_BROADCOM) += broadcom/
 obj-$(CONFIG_NET_VENDOR_CHELSIO) += chelsio/
 obj-$(CONFIG_NET_VENDOR_INTEL) += intel/
 obj-$(CONFIG_NET_VENDOR_QLOGIC) += qlogic/
+obj-$(CONFIG_NET_VENDOR_SMSC) += smsc/
diff --git a/drivers/net/ethernet/smsc/Kconfig b/drivers/net/ethernet/smsc/Kconfig
new file mode 100644
index 0000000..dbb3069
--- /dev/null
+++ b/drivers/net/ethernet/smsc/Kconfig
@@ -0,0 +1,128 @@
+#
+# Western Digital/SMC network device configuration
+#
+
+config NET_VENDOR_SMSC
+	bool "SMC (SMSC)/Western Digital devices"
+	depends on ARM || ISA || MAC || ARM || MIPS || M32R || SUPERH || \
+		BLACKFIN || MN10300 || COLDFIRE || PCI || PCMCIA
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about SMC/Western Digital cards. If you say Y, you will
+	  be asked for your specific card in the following questions.
+
+config SMC9194
+	tristate "SMC 9194 support"
+	depends on NET_VENDOR_SMSC && (ISA || MAC && BROKEN)
+	select CRC32
+	---help---
+	  This is support for the SMC9xxx based Ethernet cards. Choose this
+	  option if you have a DELL laptop with the docking station, or
+	  another SMC9192/9194 based chipset.  Say Y if you want it compiled
+	  into the kernel, and read the file
+	  <file:Documentation/networking/smc9.txt> and the Ethernet-HOWTO,
+	  available from <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called smc9194.
+
+config SMC91X
+	tristate "SMC 91C9x/91C1xxx support"
+	select CRC32
+	select MII
+	depends on NET_VENDOR_SMSC && (ARM || M32R || SUPERH || \
+		MIPS || BLACKFIN || MN10300 || COLDFIRE)
+	---help---
+	  This is a driver for SMC's 91x series of Ethernet chipsets,
+	  including the SMC91C94 and the SMC91C111. Say Y if you want it
+	  compiled into the kernel, and read the file
+	  <file:Documentation/networking/smc9.txt>  and the Ethernet-HOWTO,
+	  available from  <http://www.tldp.org/docs.html#howto>.
+
+	  This driver is also available as a module ( = code which can be
+	  inserted in and removed from the running kernel whenever you want).
+	  The module will be called smc91x.  If you want to compile it as a
+	  module, say M here and read <file:Documentation/kbuild/modules.txt>.
+
+config PCMCIA_SMC91C92
+	tristate "SMC 91Cxx PCMCIA support"
+	depends NET_VENDOR_SMSC && PCMCIA
+	select CRC32
+	select MII
+	---help---
+	  Say Y here if you intend to attach an SMC 91Cxx compatible PCMCIA
+	  (PC-card) Ethernet or Fast Ethernet card to your computer.
+
+	  To compile this driver as a module, choose M here: the module will be
+	  called smc91c92_cs.  If unsure, say N.
+
+config EPIC100
+	tristate "SMC EtherPower II"
+	depends on NET_VENDOR_SMSC && PCI
+	select CRC32
+	select MII
+	---help---
+	  This driver is for the SMC EtherPower II 9432 PCI Ethernet NIC,
+	  which is based on the SMC83c17x (EPIC/100).
+	  More specific information and updates are available from
+	  <http://www.scyld.com/network/epic100.html>.
+
+config SMC911X
+	tristate "SMSC LAN911[5678] support"
+	select CRC32
+	select MII
+	depends on NET_VENDOR_SMSC && (ARM || SUPERH || MN10300)
+	---help---
+	  This is a driver for SMSC's LAN911x series of Ethernet chipsets
+	  including the new LAN9115, LAN9116, LAN9117, and LAN9118.
+	  Say Y if you want it compiled into the kernel,
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  This driver is also available as a module. The module will be
+	  called smc911x.  If you want to compile it as a module, say M
+	  here and read <file:Documentation/kbuild/modules.txt>
+
+config SMSC911X
+	tristate "SMSC LAN911x/LAN921x families embedded ethernet support"
+	depends on NET_VENDOR_SMSC && (ARM || SUPERH || BLACKFIN || \
+		   MIPS || MN10300)
+	select CRC32
+	select MII
+	select PHYLIB
+	---help---
+	  Say Y here if you want support for SMSC LAN911x and LAN921x families
+	  of ethernet controllers.
+
+	  To compile this driver as a module, choose M here and read
+	  <file:Documentation/networking/net-modules.txt>. The module
+	  will be called smsc911x.
+
+config SMSC911X_ARCH_HOOKS
+	def_bool n
+	depends on SMSC911X
+	---help---
+	  If the arch enables this, it allows the arch to implement various
+	  hooks for more comprehensive interrupt control and also to override
+	  the source of the MAC address.
+
+config SMSC9420
+	tristate "SMSC LAN9420 PCI ethernet adapter support"
+	depends on NET_VENDOR_SMSC && PCI
+	select CRC32
+	select PHYLIB
+	select SMSC_PHY
+	---help---
+	  This is a driver for SMSC's LAN9420 PCI ethernet adapter.
+	  Say Y if you want it compiled into the kernel,
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  This driver is also available as a module. The module will be
+	  called smsc9420.  If you want to compile it as a module, say M
+	  here and read <file:Documentation/kbuild/modules.txt>
diff --git a/drivers/net/ethernet/smsc/Makefile b/drivers/net/ethernet/smsc/Makefile
new file mode 100644
index 0000000..f3438de
--- /dev/null
+++ b/drivers/net/ethernet/smsc/Makefile
@@ -0,0 +1,11 @@
+#
+# Makefile for the SMSC network device drivers.
+#
+
+obj-$(CONFIG_SMC9194) += smc9194.o
+obj-$(CONFIG_SMC91X) += smc91x.o
+obj-$(CONFIG_PCMCIA_SMC91C92) += smc91c92_cs.o
+obj-$(CONFIG_EPIC100) += epic100.o
+obj-$(CONFIG_SMSC9420) += smsc9420.o
+obj-$(CONFIG_SMC911X) += smc911x.o
+obj-$(CONFIG_SMSC911X) += smsc911x.o
diff --git a/drivers/net/epic100.c b/drivers/net/ethernet/smsc/epic100.c
similarity index 100%
rename from drivers/net/epic100.c
rename to drivers/net/ethernet/smsc/epic100.c
diff --git a/drivers/net/smc911x.c b/drivers/net/ethernet/smsc/smc911x.c
similarity index 100%
rename from drivers/net/smc911x.c
rename to drivers/net/ethernet/smsc/smc911x.c
diff --git a/drivers/net/smc911x.h b/drivers/net/ethernet/smsc/smc911x.h
similarity index 100%
rename from drivers/net/smc911x.h
rename to drivers/net/ethernet/smsc/smc911x.h
diff --git a/drivers/net/smc9194.c b/drivers/net/ethernet/smsc/smc9194.c
similarity index 100%
rename from drivers/net/smc9194.c
rename to drivers/net/ethernet/smsc/smc9194.c
diff --git a/drivers/net/smc9194.h b/drivers/net/ethernet/smsc/smc9194.h
similarity index 100%
rename from drivers/net/smc9194.h
rename to drivers/net/ethernet/smsc/smc9194.h
diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/ethernet/smsc/smc91c92_cs.c
similarity index 100%
rename from drivers/net/pcmcia/smc91c92_cs.c
rename to drivers/net/ethernet/smsc/smc91c92_cs.c
diff --git a/drivers/net/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
similarity index 100%
rename from drivers/net/smc91x.c
rename to drivers/net/ethernet/smsc/smc91x.c
diff --git a/drivers/net/smc91x.h b/drivers/net/ethernet/smsc/smc91x.h
similarity index 100%
rename from drivers/net/smc91x.h
rename to drivers/net/ethernet/smsc/smc91x.h
diff --git a/drivers/net/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
similarity index 100%
rename from drivers/net/smsc911x.c
rename to drivers/net/ethernet/smsc/smsc911x.c
diff --git a/drivers/net/smsc911x.h b/drivers/net/ethernet/smsc/smsc911x.h
similarity index 100%
rename from drivers/net/smsc911x.h
rename to drivers/net/ethernet/smsc/smsc911x.h
diff --git a/drivers/net/smsc9420.c b/drivers/net/ethernet/smsc/smsc9420.c
similarity index 100%
rename from drivers/net/smsc9420.c
rename to drivers/net/ethernet/smsc/smsc9420.c
diff --git a/drivers/net/smsc9420.h b/drivers/net/ethernet/smsc/smsc9420.h
similarity index 100%
rename from drivers/net/smsc9420.h
rename to drivers/net/ethernet/smsc/smsc9420.h
diff --git a/drivers/net/pcmcia/Kconfig b/drivers/net/pcmcia/Kconfig
index 72aa257..f5a738f 100644
--- a/drivers/net/pcmcia/Kconfig
+++ b/drivers/net/pcmcia/Kconfig
@@ -31,17 +31,6 @@ config PCMCIA_FMVJ18X
 	  To compile this driver as a module, choose M here: the module will be
 	  called fmvj18x_cs.  If unsure, say N.
 
-config PCMCIA_SMC91C92
-	tristate "SMC 91Cxx PCMCIA support"
-	select CRC32
-	select MII
-	help
-	  Say Y here if you intend to attach an SMC 91Cxx compatible PCMCIA
-	  (PC-card) Ethernet or Fast Ethernet card to your computer.
-
-	  To compile this driver as a module, choose M here: the module will be
-	  called smc91c92_cs.  If unsure, say N.
-
 config PCMCIA_XIRC2PS
 	tristate "Xircom 16-bit PCMCIA support"
 	help
diff --git a/drivers/net/pcmcia/Makefile b/drivers/net/pcmcia/Makefile
index c2b8b44..f9c9883 100644
--- a/drivers/net/pcmcia/Makefile
+++ b/drivers/net/pcmcia/Makefile
@@ -4,7 +4,6 @@
 
 # 16-bit client drivers
 obj-$(CONFIG_PCMCIA_FMVJ18X)	+= fmvj18x_cs.o
-obj-$(CONFIG_PCMCIA_SMC91C92)	+= smc91c92_cs.o
 obj-$(CONFIG_PCMCIA_XIRC2PS)	+= xirc2ps_cs.o
 obj-$(CONFIG_ARCNET_COM20020_CS)+= com20020_cs.o
 
-- 
1.7.6

