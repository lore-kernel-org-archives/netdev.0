From: Ian Molton <ian.molton@codethink.co.uk>
Subject: [PATCH v3 1/7] Initial csb1724 board support (FDT)
Date: Tue,  7 Aug 2012 15:34:46 +0100
Message-ID: <1344350092-24050-2-git-send-email-ian.molton@codethink.co.uk>
References: <1344350092-24050-1-git-send-email-ian.molton@codethink.co.uk>
Cc: andrew@lunn.ch, thomas.petazzoni@free-electrons.com,
	ben.dooks@codethink.co.uk, arnd@arndb.de, netdev@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([37.128.190.40]:50801 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754725Ab2HGOfH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2012 10:35:07 -0400
In-Reply-To: <1344350092-24050-1-git-send-email-ian.molton@codethink.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for the csb1724 SoM.

It includes serial and SATA support.

Signed-off-by: Ian Molton <ian.molton@codethink.co.uk>
---
 arch/arm/boot/dts/kirkwood-csb1724.dts |   30 ++++++++++++++++
 arch/arm/mach-kirkwood/Kconfig         |    7 ++++
 arch/arm/mach-kirkwood/Makefile        |    1 +
 arch/arm/mach-kirkwood/Makefile.boot   |    1 +
 arch/arm/mach-kirkwood/board-csb1724.c |   59 ++++++++++++++++++++++++++++++++
 arch/arm/mach-kirkwood/board-dt.c      |    4 +++
 arch/arm/mach-kirkwood/common.h        |    6 ++++
 7 files changed, 108 insertions(+)
 create mode 100644 arch/arm/boot/dts/kirkwood-csb1724.dts
 create mode 100644 arch/arm/mach-kirkwood/board-csb1724.c

diff --git a/arch/arm/boot/dts/kirkwood-csb1724.dts b/arch/arm/boot/dts/kirkwood-csb1724.dts
new file mode 100644
index 0000000..44dfe9a
--- /dev/null
+++ b/arch/arm/boot/dts/kirkwood-csb1724.dts
@@ -0,0 +1,30 @@
+/dts-v1/;
+
+/include/ "kirkwood.dtsi"
+
+/ {
+	model = "Cogent CSB1724-88F-628X SoM";
+	compatible = "cogent,csb1724", "marvell,kirkwood-88f6281", "marvell,kirkwood";
+
+	memory {
+		device_type = "memory";
+		reg = <0x00000000 0x20000000>;
+	};
+
+	chosen {
+		bootargs = "console=ttyS0,115200n8 earlyprintk";
+	};
+
+	ocp@f1000000 {
+		serial@12000 {
+			clock-frequency = <200000000>;
+			status = "ok";
+		};
+
+		sata@80000 {
+			nr-ports = <2>;
+			status = "ok";
+		};
+	};
+
+};
diff --git a/arch/arm/mach-kirkwood/Kconfig b/arch/arm/mach-kirkwood/Kconfig
index ca5c15a..6d51c50 100644
--- a/arch/arm/mach-kirkwood/Kconfig
+++ b/arch/arm/mach-kirkwood/Kconfig
@@ -109,6 +109,13 @@ config MACH_LSXL_DT
 	  Buffalo Linkstation LS-XHL & LS-CHLv2 devices, using
 	  Flattened Device Tree.
 
+config MACH_CSB1724_DT
+	bool "Cogent CSB1724 SoM (Flattened Device Tree)"
+	select ARCH_KIRKWOOD_DT
+	help
+	  Say 'Y' here if you want your kernel to support the
+	  Cogent CSB1724 SoM, using Flattened Device Tree.
+
 config MACH_TS219
 	bool "QNAP TS-110, TS-119, TS-119P+, TS-210, TS-219, TS-219P and TS-219P+ Turbo NAS"
 	help
diff --git a/arch/arm/mach-kirkwood/Makefile b/arch/arm/mach-kirkwood/Makefile
index 055c85a..665ed63 100644
--- a/arch/arm/mach-kirkwood/Makefile
+++ b/arch/arm/mach-kirkwood/Makefile
@@ -28,3 +28,4 @@ obj-$(CONFIG_MACH_IB62X0_DT)		+= board-ib62x0.o
 obj-$(CONFIG_MACH_TS219_DT)		+= board-ts219.o tsx1x-common.o
 obj-$(CONFIG_MACH_GOFLEXNET_DT)		+= board-goflexnet.o
 obj-$(CONFIG_MACH_LSXL_DT)		+= board-lsxl.o
+obj-$(CONFIG_MACH_CSB1724_DT)		+= board-csb1724.o
diff --git a/arch/arm/mach-kirkwood/Makefile.boot b/arch/arm/mach-kirkwood/Makefile.boot
index 2a576ab..899bc80 100644
--- a/arch/arm/mach-kirkwood/Makefile.boot
+++ b/arch/arm/mach-kirkwood/Makefile.boot
@@ -2,6 +2,7 @@
 params_phys-y	:= 0x00000100
 initrd_phys-y	:= 0x00800000
 
+dtb-$(CONFIG_MACH_CSB1724_DT) += kirkwood-csb1724.dtb
 dtb-$(CONFIG_MACH_DREAMPLUG_DT) += kirkwood-dreamplug.dtb
 dtb-$(CONFIG_MACH_DLINK_KIRKWOOD_DT) += kirkwood-dns320.dtb
 dtb-$(CONFIG_MACH_DLINK_KIRKWOOD_DT) += kirkwood-dns325.dtb
diff --git a/arch/arm/mach-kirkwood/board-csb1724.c b/arch/arm/mach-kirkwood/board-csb1724.c
new file mode 100644
index 0000000..979112d
--- /dev/null
+++ b/arch/arm/mach-kirkwood/board-csb1724.c
@@ -0,0 +1,59 @@
+/*
+ * Copyright 2012 (C), Ian Molton <ian.molton@codethink.co.uk>
+ *
+ * arch/arm/mach-kirkwood/board-csb1724.c
+ *
+ * Cogent csb1724 Board Init for drivers not converted to
+ * flattened device tree yet.
+ *
+ * This file is licensed under the terms of the GNU General Public
+ * License version 2.  This program is licensed "as is" without any
+ * warranty of any kind, whether express or implied.
+ */
+
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include "mpp.h"
+
+static unsigned int csb1724_mpp_config[] __initdata = {
+	MPP0_NF_IO2,
+	MPP1_NF_IO3,
+	MPP2_NF_IO4,
+	MPP3_NF_IO5,
+	MPP4_NF_IO6,
+	MPP5_NF_IO7,
+	MPP8_TW0_SDA,
+	MPP9_TW0_SCK,
+	MPP12_SD_CLK,
+	MPP13_SD_CMD,
+	MPP14_SD_D0,
+	MPP15_SD_D1,
+	MPP16_SD_D2,
+	MPP17_SD_D3,
+	MPP18_NF_IO0,
+	MPP19_NF_IO1,
+	MPP20_GE1_TXD0,
+	MPP21_GE1_TXD1,
+	MPP22_GE1_TXD2,
+	MPP23_GE1_TXD3,
+	MPP24_GE1_RXD0,
+	MPP25_GE1_RXD1,
+	MPP26_GE1_RXD2,
+	MPP27_GE1_RXD3,
+	MPP30_GE1_RXCTL,
+	MPP31_GE1_RXCLK,
+	MPP32_GE1_TCLKOUT,
+	MPP33_GE1_TXCTL,
+	MPP34_SATA1_ACTn,
+	MPP35_SATA0_ACTn,
+	MPP36_TW1_SDA,
+	MPP37_TW1_SCK,
+};
+
+void __init csb1724_init(void)
+{
+	/*
+	 * Basic setup. Needs to be called early.
+	 */
+	kirkwood_mpp_conf(csb1724_mpp_config);
+}
diff --git a/arch/arm/mach-kirkwood/board-dt.c b/arch/arm/mach-kirkwood/board-dt.c
index e4eb450..7679f7f 100644
--- a/arch/arm/mach-kirkwood/board-dt.c
+++ b/arch/arm/mach-kirkwood/board-dt.c
@@ -87,6 +87,9 @@ static void __init kirkwood_dt_init(void)
 	if (of_machine_is_compatible("buffalo,lsxl"))
 		lsxl_init();
 
+	if (of_machine_is_compatible("cogent,csb1724"))
+		csb1724_init();
+
 	of_platform_populate(NULL, kirkwood_dt_match_table,
 			     kirkwood_auxdata_lookup, NULL);
 }
@@ -100,6 +103,7 @@ static const char *kirkwood_dt_board_compat[] = {
 	"qnap,ts219",
 	"seagate,goflexnet",
 	"buffalo,lsxl",
+	"cogent,csb1724",
 	NULL
 };
 
diff --git a/arch/arm/mach-kirkwood/common.h b/arch/arm/mach-kirkwood/common.h
index 304dd1a..8aab1ae 100644
--- a/arch/arm/mach-kirkwood/common.h
+++ b/arch/arm/mach-kirkwood/common.h
@@ -94,6 +94,12 @@ void lsxl_init(void);
 static inline void lsxl_init(void) {};
 #endif
 
+#ifdef CONFIG_MACH_CSB1724_DT
+void csb1724_init(void);
+#else
+static inline void csb1724_init(void) {};
+#endif
+
 /* early init functions not converted to fdt yet */
 char *kirkwood_id(void);
 void kirkwood_l2_init(void);
-- 
1.7.9.5
