From: <srinivas.kandagatla@st.com>
Subject: [PATCH RFC 02/10] drivers: reset: Reset controller driver for STiH415
Date: Tue, 12 Nov 2013 13:52:26 +0000
Message-ID: <1384264346-7397-1-git-send-email-srinivas.kandagatla@st.com>
References: <1384264311-7308-1-git-send-email-srinivas.kandagatla@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Rob Herring <rob.herring@calxeda.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Stephen Warren <swarren@wwwdotorg.org>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Rob Landley <rob@landley.net>,
	Russell King <linux@arm.linux.org.uk>,
	Srinivas Kandagatla <srinivas.kandagatla@st.com>,
	Stuart Menefy <stuart.menefy@st.com>,
	Pavel Machek <pavel@ucw.cz>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Len Brown <len.brown@intel.com>, <stephen.gallimore@st.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Grant Likely <grant.likely@linaro.org>,
	<devicetree@vger.kernel.org>, <linux-doc@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <kernel@stlinux.com>,
	<linux-pm@vger.kernel.org>
To: <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <1384264311-7308-1-git-send-email-srinivas.kandagatla@st.com>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Gallimore <stephen.gallimore@st.com>

This patch adds a reset controller platform driver for the STiH415
SoC. This initial version provides a compatible driver for the
"st,stih415-powerdown" device, which registers a system configuration
register based reset controller that controls the powerdown state of
hardware such as the on-chip USB host controllers.

Signed-off-by: Stephen Gallimore <stephen.gallimore@st.com>
---
 .../devicetree/bindings/reset/st,sti-powerdown.txt |   46 ++++++++++++
 arch/arm/boot/dts/stih415.dtsi                     |    6 ++
 drivers/reset/sti/Kconfig                          |    4 +
 drivers/reset/sti/Makefile                         |    3 +
 drivers/reset/sti/reset-stih415.c                  |   77 ++++++++++++++++++++
 .../dt-bindings/reset-controller/stih415-resets.h  |   19 +++++
 6 files changed, 155 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/reset/st,sti-powerdown.txt
 create mode 100644 drivers/reset/sti/reset-stih415.c
 create mode 100644 include/dt-bindings/reset-controller/stih415-resets.h

diff --git a/Documentation/devicetree/bindings/reset/st,sti-powerdown.txt b/Documentation/devicetree/bindings/reset/st,sti-powerdown.txt
new file mode 100644
index 0000000..23a808c
--- /dev/null
+++ b/Documentation/devicetree/bindings/reset/st,sti-powerdown.txt
@@ -0,0 +1,46 @@
+STMicroelectronics STi family Sysconfig Peripheral Powerdown Reset Controller
+=============================================================================
+
+This binding describes a reset controller device that is used to enable and
+disable on-chip peripheral controllers such as USB and SATA, using
+"powerdown" control bits found in the STi family SoC system configuration
+registers. These have been grouped together into a single reset controller
+device for convenience.
+
+The actual action taken when powerdown is asserted is hardware dependent.
+However, when asserted it may not be possible to access the hardware's
+registers and after an assert/deassert sequence the hardware's previous state
+may no longer be valid.
+
+Please refer to reset.txt in this directory for common reset
+controller binding usage.
+
+Required properties:
+- compatible: Should be "st,<chip>-powerdown"
+- #reset-cells: 1, see below
+
+example:
+
+	powerdown: powerdown-controller {
+		#reset-cells = <1>;
+		compatible = "st,stih415-powerdown";
+	};
+
+
+Specifying powerdown control of devices
+=======================================
+
+Device nodes should specify the reset channel required in their "resets"
+property, containing a phandle to the powerdown device node and an
+index specifying which channel to use, as described in reset.txt
+
+example:
+
+	usb1: usb@fe200000 {
+		resets	= <&powerdown STIH41X_USB1_POWERDOWN>;
+	};
+
+Macro definitions for the supported reset channels can be found in:
+
+include/dt-bindings/reset-controller/stih415-resets.h
+include/dt-bindings/reset-controller/stih416-resets.h
diff --git a/arch/arm/boot/dts/stih415.dtsi b/arch/arm/boot/dts/stih415.dtsi
index 74ab8de..09379a6b 100644
--- a/arch/arm/boot/dts/stih415.dtsi
+++ b/arch/arm/boot/dts/stih415.dtsi
@@ -9,6 +9,7 @@
 #include "stih41x.dtsi"
 #include "stih415-clock.dtsi"
 #include "stih415-pinctrl.dtsi"
+#include <dt-bindings/reset-controller/stih415-resets.h>
 / {
 
 	L2: cache-controller {
@@ -27,6 +28,11 @@
 		ranges;
 		compatible	= "simple-bus";
 
+		powerdown: powerdown-controller {
+			#reset-cells = <1>;
+			compatible = "st,stih415-powerdown";
+		};
+
 		syscfg_sbc: sbc-syscfg@fe600000{
 			compatible      = "st,stih415-sbc-syscfg", "syscon";
 			reg		= <0xfe600000 0xb4>;
diff --git a/drivers/reset/sti/Kconfig b/drivers/reset/sti/Kconfig
index ba13796..ef6654a 100644
--- a/drivers/reset/sti/Kconfig
+++ b/drivers/reset/sti/Kconfig
@@ -4,4 +4,8 @@ config STI_RESET_SYSCFG
 	bool
 	select RESET_CONTROLLER
 
+config STIH415_RESET
+	bool
+	select STI_RESET_SYSCFG
+
 endif
diff --git a/drivers/reset/sti/Makefile b/drivers/reset/sti/Makefile
index c4a51d9..fce4433 100644
--- a/drivers/reset/sti/Makefile
+++ b/drivers/reset/sti/Makefile
@@ -1 +1,4 @@
 obj-$(CONFIG_STI_RESET_SYSCFG) += reset-syscfg.o
+
+# SoC specific reset devices
+obj-$(CONFIG_STIH415_RESET) += reset-stih415.o
diff --git a/drivers/reset/sti/reset-stih415.c b/drivers/reset/sti/reset-stih415.c
new file mode 100644
index 0000000..56c2146
--- /dev/null
+++ b/drivers/reset/sti/reset-stih415.c
@@ -0,0 +1,77 @@
+/*
+ * Copyright (C) 2013 STMicroelectronics (R&D) Limited
+ * Author: Stephen Gallimore <stephen.gallimore@st.com>
+ * Author: Srinivas Kandagatla <srinivas.kandagatla@st.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+#include <linux/module.h>
+#include <linux/of.h>
+#include <linux/of_platform.h>
+#include <linux/platform_device.h>
+
+#include <dt-bindings/reset-controller/stih415-resets.h>
+
+#include "reset-syscfg.h"
+
+/*
+ * STiH415 Peripheral powerdown definitions.
+ */
+static const char stih415_front[] = "st,stih415-front-syscfg";
+static const char stih415_rear[] = "st,stih415-rear-syscfg";
+static const char stih415_sbc[] = "st,stih415-sbc-syscfg";
+static const char stih415_lpm[] = "st,stih415-lpm-syscfg";
+
+#define STIH415_PDN_FRONT(_bit) \
+	_SYSCFG_RST_CH(stih415_front, SYSCFG_114, _bit, SYSSTAT_187, _bit)
+
+#define STIH415_PDN_REAR(_cntl, _stat) \
+	_SYSCFG_RST_CH(stih415_rear, SYSCFG_336, _cntl, SYSSTAT_384, _stat)
+
+#define SYSCFG_114	0x38 /* Powerdown request EMI/NAND/Keyscan */
+#define SYSSTAT_187	0x15c /* Powerdown status EMI/NAND/Keyscan */
+
+#define SYSCFG_336	0x90 /* Powerdown request USB/SATA/PCIe */
+#define SYSSTAT_384	0x150 /* Powerdown status USB/SATA/PCIe */
+
+static const struct syscfg_reset_channel_data stih415_powerdowns[] = {
+	[STIH415_EMISS_POWERDOWN]	= STIH415_PDN_FRONT(0),
+	[STIH415_NAND_POWERDOWN]	= STIH415_PDN_FRONT(1),
+	[STIH415_KEYSCAN_POWERDOWN]	= STIH415_PDN_FRONT(2),
+	[STIH415_USB0_POWERDOWN]	= STIH415_PDN_REAR(0, 0),
+	[STIH415_USB1_POWERDOWN]	= STIH415_PDN_REAR(1, 1),
+	[STIH415_USB2_POWERDOWN]	= STIH415_PDN_REAR(2, 2),
+	[STIH415_SATA0_POWERDOWN]	= STIH415_PDN_REAR(3, 3),
+	[STIH415_SATA1_POWERDOWN]	= STIH415_PDN_REAR(4, 4),
+	[STIH415_PCIE_POWERDOWN]	= STIH415_PDN_REAR(5, 8),
+};
+
+static struct syscfg_reset_controller_data stih415_powerdown_controller = {
+	.wait_for_ack = true,
+	.nr_channels = ARRAY_SIZE(stih415_powerdowns),
+	.channels = stih415_powerdowns,
+};
+
+static struct of_device_id stih415_reset_match[] = {
+	{ .compatible = "st,stih415-powerdown",
+	  .data = &stih415_powerdown_controller, },
+	{},
+};
+
+static struct platform_driver stih415_reset_driver = {
+	.probe = syscfg_reset_probe,
+	.driver = {
+		.name = "reset-stih415",
+		.owner = THIS_MODULE,
+		.of_match_table = stih415_reset_match,
+	},
+};
+
+static int __init stih415_reset_init(void)
+{
+	return platform_driver_register(&stih415_reset_driver);
+}
+arch_initcall(stih415_reset_init);
diff --git a/include/dt-bindings/reset-controller/stih415-resets.h b/include/dt-bindings/reset-controller/stih415-resets.h
new file mode 100644
index 0000000..2d54e68
--- /dev/null
+++ b/include/dt-bindings/reset-controller/stih415-resets.h
@@ -0,0 +1,19 @@
+/*
+ * This header provides constants for the reset controller
+ * based peripheral powerdown requests on the STMicroelectronics
+ * STiH415 SoC.
+ */
+#ifndef _DT_BINDINGS_RESET_CONTROLLER_STIH415
+#define _DT_BINDINGS_RESET_CONTROLLER_STIH415
+
+#define STIH415_EMISS_POWERDOWN		0
+#define STIH415_NAND_POWERDOWN		1
+#define STIH415_KEYSCAN_POWERDOWN	2
+#define STIH415_USB0_POWERDOWN		3
+#define STIH415_USB1_POWERDOWN		4
+#define STIH415_USB2_POWERDOWN		5
+#define STIH415_SATA0_POWERDOWN		6
+#define STIH415_SATA1_POWERDOWN		7
+#define STIH415_PCIE_POWERDOWN		8
+
+#endif /* _DT_BINDINGS_RESET_CONTROLLER_STIH415 */
-- 
1.7.6.5

