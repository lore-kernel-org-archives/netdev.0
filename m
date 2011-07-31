From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 55/71] bfin_mac: Move the Analog Devices Inc driver
Date: Sat, 30 Jul 2011 20:27:14 -0700
Message-ID: <1312082850-24914-56-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	<uclinux-dist-devel@blackfin.uclinux.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:2242 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753401Ab1GaD2j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Jul 2011 23:28:39 -0400
In-Reply-To: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the Analog Devices Inc driver into drivers/net/ethernet/adi/ and
make the necessary Kconfig and Makefile changes.

CC: <uclinux-dist-devel@blackfin.uclinux.org>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                               |    2 +-
 drivers/net/Kconfig                       |   46 --------------------
 drivers/net/Makefile                      |    1 -
 drivers/net/ethernet/Kconfig              |    1 +
 drivers/net/ethernet/Makefile             |    1 +
 drivers/net/ethernet/adi/Kconfig          |   65 +++++++++++++++++++++++++++++
 drivers/net/ethernet/adi/Makefile         |    5 ++
 drivers/net/{ => ethernet/adi}/bfin_mac.c |    0
 drivers/net/{ => ethernet/adi}/bfin_mac.h |    0
 9 files changed, 73 insertions(+), 48 deletions(-)
 create mode 100644 drivers/net/ethernet/adi/Kconfig
 create mode 100644 drivers/net/ethernet/adi/Makefile
 rename drivers/net/{ => ethernet/adi}/bfin_mac.c (100%)
 rename drivers/net/{ => ethernet/adi}/bfin_mac.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index a91e8fb..83a51ad 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1440,7 +1440,7 @@ BLACKFIN EMAC DRIVER
 L:	uclinux-dist-devel@blackfin.uclinux.org
 W:	http://blackfin.uclinux.org
 S:	Supported
-F:	drivers/net/bfin_mac.*
+F:	drivers/net/ethernet/adi/
 
 BLACKFIN RTC DRIVER
 M:	Mike Frysinger <vapier.adi@gmail.com>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 61e71d0..bb4bc4b 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -252,52 +252,6 @@ config SH_ETH
 	  This driver supporting CPUs are:
 		- SH7710, SH7712, SH7763, SH7619, SH7724, and SH7757.
 
-config BFIN_MAC
-	tristate "Blackfin on-chip MAC support"
-	depends on NET_ETHERNET && (BF516 || BF518 || BF526 || BF527 || BF536 || BF537)
-	select CRC32
-	select MII
-	select PHYLIB
-	select BFIN_MAC_USE_L1 if DMA_UNCACHED_NONE
-	help
-	  This is the driver for Blackfin on-chip mac device. Say Y if you want it
-	  compiled into the kernel. This driver is also available as a module
-	  ( = code which can be inserted in and removed from the running kernel
-	  whenever you want). The module will be called bfin_mac.
-
-config BFIN_MAC_USE_L1
-	bool "Use L1 memory for rx/tx packets"
-	depends on BFIN_MAC && (BF527 || BF537)
-	default y
-	help
-	  To get maximum network performance, you should use L1 memory as rx/tx buffers.
-	  Say N here if you want to reserve L1 memory for other uses.
-
-config BFIN_TX_DESC_NUM
-	int "Number of transmit buffer packets"
-	depends on BFIN_MAC
-	range 6 10 if BFIN_MAC_USE_L1
-	range 10 100
-	default "10"
-	help
-	  Set the number of buffer packets used in driver.
-
-config BFIN_RX_DESC_NUM
-	int "Number of receive buffer packets"
-	depends on BFIN_MAC
-	range 20 100 if BFIN_MAC_USE_L1
-	range 20 800
-	default "20"
-	help
-	  Set the number of buffer packets used in driver.
-
-config BFIN_MAC_USE_HWSTAMP
-	bool "Use IEEE 1588 hwstamp"
-	depends on BFIN_MAC && BF518
-	default y
-	help
-	  To support the IEEE 1588 Precision Time Protocol (PTP), select y here
-
 config NET_NETX
 	tristate "NetX Ethernet support"
 	select MII
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 8e6dbd7..d249d76 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -57,7 +57,6 @@ obj-$(CONFIG_EQUALIZER) += eql.o
 obj-$(CONFIG_TUN) += tun.o
 obj-$(CONFIG_VETH) += veth.o
 obj-$(CONFIG_NET_NETX) += netx-eth.o
-obj-$(CONFIG_BFIN_MAC) += bfin_mac.o
 obj-$(CONFIG_DM9000) += dm9000.o
 obj-$(CONFIG_ENC28J60) += enc28j60.o
 obj-$(CONFIG_ETHOC) += ethoc.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 6b3b3dc..e087337 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -15,6 +15,7 @@ source "drivers/net/ethernet/3com/Kconfig"
 source "drivers/net/ethernet/amd/Kconfig"
 source "drivers/net/ethernet/apple/Kconfig"
 source "drivers/net/ethernet/atheros/Kconfig"
+source "drivers/net/ethernet/adi/Kconfig"
 source "drivers/net/ethernet/broadcom/Kconfig"
 source "drivers/net/ethernet/brocade/Kconfig"
 source "drivers/net/ethernet/chelsio/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 2a1cbce..826db27 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -7,6 +7,7 @@ obj-$(CONFIG_NET_VENDOR_8390) += 8390/
 obj-$(CONFIG_NET_VENDOR_AMD) += amd/
 obj-$(CONFIG_NET_VENDOR_APPLE) += apple/
 obj-$(CONFIG_NET_VENDOR_ATHEROS) += atheros/
+obj-$(CONFIG_NET_BFIN) += adi/
 obj-$(CONFIG_NET_VENDOR_BROADCOM) += broadcom/
 obj-$(CONFIG_NET_VENDOR_BROCADE) += brocade/
 obj-$(CONFIG_NET_VENDOR_CHELSIO) += chelsio/
diff --git a/drivers/net/ethernet/adi/Kconfig b/drivers/net/ethernet/adi/Kconfig
new file mode 100644
index 0000000..a2c8a3b
--- /dev/null
+++ b/drivers/net/ethernet/adi/Kconfig
@@ -0,0 +1,65 @@
+#
+# Blackfin device configuration
+#
+
+config NET_BFIN
+	bool "Blackfin devices"
+	depends on BF516 || BF518 || BF526 || BF527 || BF536 || BF537
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y.
+	  Make sure you know the name of your card. Read the Ethernet-HOWTO,
+	  available from <http://www.tldp.org/docs.html#howto>.
+
+	  If unsure, say Y.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the remaining Blackfin card questions. If you say Y, you will be
+	  asked for your specific card in the following questions.
+
+config BFIN_MAC
+	tristate "Blackfin on-chip MAC support"
+	depends on NET_BFIN && (BF516 || BF518 || BF526 || BF527 || \
+		 BF536 || BF537)
+	select CRC32
+	select MII
+	select PHYLIB
+	select BFIN_MAC_USE_L1 if DMA_UNCACHED_NONE
+	---help---
+	  This is the driver for Blackfin on-chip mac device. Say Y if you want
+	  it compiled into the kernel. This driver is also available as a
+	  module ( = code which can be inserted in and removed from the running
+	  kernel whenever you want). The module will be called bfin_mac.
+
+config BFIN_MAC_USE_L1
+	bool "Use L1 memory for rx/tx packets"
+	depends on BFIN_MAC && (BF527 || BF537)
+	default y
+	---help---
+	  To get maximum network performance, you should use L1 memory as rx/tx
+	  buffers. Say N here if you want to reserve L1 memory for other uses.
+
+config BFIN_TX_DESC_NUM
+	int "Number of transmit buffer packets"
+	depends on BFIN_MAC
+	range 6 10 if BFIN_MAC_USE_L1
+	range 10 100
+	default "10"
+	---help---
+	  Set the number of buffer packets used in driver.
+
+config BFIN_RX_DESC_NUM
+	int "Number of receive buffer packets"
+	depends on BFIN_MAC
+	range 20 100 if BFIN_MAC_USE_L1
+	range 20 800
+	default "20"
+	---help---
+	  Set the number of buffer packets used in driver.
+
+config BFIN_MAC_USE_HWSTAMP
+	bool "Use IEEE 1588 hwstamp"
+	depends on BFIN_MAC && BF518
+	default y
+	---help---
+	  To support the IEEE 1588 Precision Time Protocol (PTP), select y here
diff --git a/drivers/net/ethernet/adi/Makefile b/drivers/net/ethernet/adi/Makefile
new file mode 100644
index 0000000..b1fbe19
--- /dev/null
+++ b/drivers/net/ethernet/adi/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the Blackfin device drivers.
+#
+
+obj-$(CONFIG_BFIN_MAC) += bfin_mac.o
diff --git a/drivers/net/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
similarity index 100%
rename from drivers/net/bfin_mac.c
rename to drivers/net/ethernet/adi/bfin_mac.c
diff --git a/drivers/net/bfin_mac.h b/drivers/net/ethernet/adi/bfin_mac.h
similarity index 100%
rename from drivers/net/bfin_mac.h
rename to drivers/net/ethernet/adi/bfin_mac.h
-- 
1.7.6

