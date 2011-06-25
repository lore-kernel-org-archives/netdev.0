From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 50/72] xilinx/ll_temac: Move the Xilinx drivers
Date: Sat, 25 Jun 2011 06:59:01 -0700
Message-ID: <1309010363-22750-51-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	John Williams <john.williams@petalogix.com>,
	"David H. Lynch Jr." <dhlii@dlasys.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:37770 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752260Ab1FYOAR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 10:00:17 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the Xilinx drivers into drivers/net/ethernet/xilinx/ and
make the necessary Kconfig and Makefile changes.

CC: John Williams <john.williams@petalogix.com>
CC: "David H. Lynch Jr." <dhlii@dlasys.net>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/Kconfig                                |   15 ---------
 drivers/net/Makefile                               |    4 --
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/xilinx/Kconfig                |   31 ++++++++++++++++++++
 drivers/net/ethernet/xilinx/Makefile               |    7 ++++
 drivers/net/{ => ethernet/xilinx}/ll_temac.h       |    0
 drivers/net/{ => ethernet/xilinx}/ll_temac_main.c  |    0
 drivers/net/{ => ethernet/xilinx}/ll_temac_mdio.c  |    0
 .../net/{ => ethernet/xilinx}/xilinx_emaclite.c    |    0
 10 files changed, 40 insertions(+), 19 deletions(-)
 create mode 100644 drivers/net/ethernet/xilinx/Kconfig
 create mode 100644 drivers/net/ethernet/xilinx/Makefile
 rename drivers/net/{ => ethernet/xilinx}/ll_temac.h (100%)
 rename drivers/net/{ => ethernet/xilinx}/ll_temac_main.c (100%)
 rename drivers/net/{ => ethernet/xilinx}/ll_temac_mdio.c (100%)
 rename drivers/net/{ => ethernet/xilinx}/xilinx_emaclite.c (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 0e13828..05534af 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -576,13 +576,6 @@ config NET_POCKET
 	  the questions about this class of network devices. If you say Y, you
 	  will be asked for your specific device in the following questions.
 
-config XILINX_EMACLITE
-	tristate "Xilinx 10/100 Ethernet Lite support"
-	depends on PPC32 || MICROBLAZE
-	select PHYLIB
-	help
-	  This driver supports the 10/100 Ethernet Lite from Xilinx.
-
 config LANTIQ_ETOP
 	tristate "Lantiq SoC ETOP driver"
 	depends on SOC_TYPE_XWAY
@@ -645,14 +638,6 @@ config GELIC_WIRELESS
 	  the driver automatically distinguishes the models, you can
 	  safely enable this option even if you have a wireless-less model.
 
-config XILINX_LL_TEMAC
-	tristate "Xilinx LL TEMAC (LocalLink Tri-mode Ethernet MAC) driver"
-	depends on PPC || MICROBLAZE
-	select PHYLIB
-	help
-	  This driver supports the Xilinx 10/100/1000 LocalLink TEMAC
-	  core used in Xilinx Spartan and Virtex FPGAs
-
 endif # NETDEV_1000
 
 #
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 58d1c38..eee20c5 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -39,10 +39,6 @@ obj-$(CONFIG_NET_SB1000) += sb1000.o
 obj-$(CONFIG_HP100) += hp100.o
 obj-$(CONFIG_FORCEDETH) += forcedeth.o
 
-ll_temac-objs := ll_temac_main.o ll_temac_mdio.o
-obj-$(CONFIG_XILINX_LL_TEMAC) += ll_temac.o
-obj-$(CONFIG_XILINX_EMACLITE) += xilinx_emaclite.o
-
 obj-$(CONFIG_PPP) += ppp_generic.o
 obj-$(CONFIG_PPP_ASYNC) += ppp_async.o
 obj-$(CONFIG_PPP_SYNC_TTY) += ppp_synctty.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 0ae98cb..8c57df8 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -127,5 +127,6 @@ config TSI108_ETH
 	  will be called tsi108_eth.
 
 source "drivers/net/ethernet/via/Kconfig"
+source "drivers/net/ethernet/xilinx/Kconfig"
 
 endif # ETHERNET
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 9b5df9f..e802591 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -51,3 +51,4 @@ obj-$(CONFIG_NET_TI) += ti/
 obj-$(CONFIG_NET_TULIP) += tulip/
 obj-$(CONFIG_TSI108_ETH) += tsi108_eth.o
 obj-$(CONFIG_NET_VENDOR_VIA) += via/
+obj-$(CONFIG_NET_VENDOR_XILINX) += xilinx/
diff --git a/drivers/net/ethernet/xilinx/Kconfig b/drivers/net/ethernet/xilinx/Kconfig
new file mode 100644
index 0000000..d66feb1
--- /dev/null
+++ b/drivers/net/ethernet/xilinx/Kconfig
@@ -0,0 +1,31 @@
+#
+# Xilink device configuration
+#
+
+config NET_VENDOR_XILINX
+	bool "Xilinx devices"
+	depends on PPC || PPC32 || MICROBLAZE
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about Xilinx devices. If you say Y, you will be asked
+	  for your specific card in the following questions.
+
+config XILINX_EMACLITE
+	tristate "Xilinx 10/100 Ethernet Lite support"
+	depends on NET_VENDOR_XILINX && (PPC32 || MICROBLAZE)
+	select PHYLIB
+	---help---
+	  This driver supports the 10/100 Ethernet Lite from Xilinx.
+
+config XILINX_LL_TEMAC
+	tristate "Xilinx LL TEMAC (LocalLink Tri-mode Ethernet MAC) driver"
+	depends on NET_VENDOR_XILINX && (PPC || MICROBLAZE)
+	select PHYLIB
+	---help---
+	  This driver supports the Xilinx 10/100/1000 LocalLink TEMAC
+	  core used in Xilinx Spartan and Virtex FPGAs
diff --git a/drivers/net/ethernet/xilinx/Makefile b/drivers/net/ethernet/xilinx/Makefile
new file mode 100644
index 0000000..5feac73
--- /dev/null
+++ b/drivers/net/ethernet/xilinx/Makefile
@@ -0,0 +1,7 @@
+#
+# Makefile for the Xilink network device drivers.
+#
+
+ll_temac-objs := ll_temac_main.o ll_temac_mdio.o
+obj-$(CONFIG_XILINX_LL_TEMAC) += ll_temac.o
+obj-$(CONFIG_XILINX_EMACLITE) += xilinx_emaclite.o
diff --git a/drivers/net/ll_temac.h b/drivers/net/ethernet/xilinx/ll_temac.h
similarity index 100%
rename from drivers/net/ll_temac.h
rename to drivers/net/ethernet/xilinx/ll_temac.h
diff --git a/drivers/net/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
similarity index 100%
rename from drivers/net/ll_temac_main.c
rename to drivers/net/ethernet/xilinx/ll_temac_main.c
diff --git a/drivers/net/ll_temac_mdio.c b/drivers/net/ethernet/xilinx/ll_temac_mdio.c
similarity index 100%
rename from drivers/net/ll_temac_mdio.c
rename to drivers/net/ethernet/xilinx/ll_temac_mdio.c
diff --git a/drivers/net/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
similarity index 100%
rename from drivers/net/xilinx_emaclite.c
rename to drivers/net/ethernet/xilinx/xilinx_emaclite.c
-- 
1.7.5.4

