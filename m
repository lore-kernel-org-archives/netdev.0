From: Timur Tabi <timur@freescale.com>
Subject: [PATCH] netdev/phy: add MDIO bus multiplexer driven by a memory-mapped FPGA
Date: Wed, 22 Aug 2012 16:45:54 -0500
Message-ID: <1345671954-6398-1-git-send-email-timur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
To: Andy Fleming <afleming@freescale.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<david.daney@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe005.messaging.microsoft.com ([216.32.180.31]:19117
	"EHLO va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932343Ab2HVVqB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 17:46:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An FPGA controls which sub-bus is connected to the master MDIO bus.  The
FPGA must be memory-mapped and contain only 8-bit registers (which keeps
things simple).

Tested on a Freescale P5020DS board which uses the "PIXIS" FPGA attached
to the localbus.

Signed-off-by: Timur Tabi <timur@freescale.com>
---
 .../devicetree/bindings/net/mdio-mux-fpga.txt      |   74 ++++++++
 drivers/net/phy/Kconfig                            |   13 ++
 drivers/net/phy/Makefile                           |    1 +
 drivers/net/phy/mdio-mux-fpga.c                    |  186 ++++++++++++++++++++
 4 files changed, 274 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/mdio-mux-fpga.txt
 create mode 100644 drivers/net/phy/mdio-mux-fpga.c

diff --git a/Documentation/devicetree/bindings/net/mdio-mux-fpga.txt b/Documentation/devicetree/bindings/net/mdio-mux-fpga.txt
new file mode 100644
index 0000000..ef567c6
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/mdio-mux-fpga.txt
@@ -0,0 +1,74 @@
+Properties for an MDIO bus multiplexer/switch controlled by an FPGA register.
+
+This is a special case of a MDIO bus multiplexer.  An FPGA register is used
+to control which child bus is connected.
+
+Required properties in addition to the generic multiplexer properties:
+
+- compatible : string, must contain "mdio-mux-fpga"
+
+- mdio-mux-device : phandle, points to the FPGA (or similar) node.  This
+	must be a memory-mapped device with 8-bit registers.
+
+- mdio-mux-register : integer, contains the offset of the register that
+	controls the bus multiplexer.
+
+- mdio-mux-mask : integer, contains an 8-bit mask that specifies which
+	bits in the register control the actual bus multiplexer.  The
+	'reg' property of each child mdio-mux node must be constrained by
+	this mask.
+
+Example:
+
+The FPGA node defines a memory-mapped FPGA with a register space of 0x30 bytes.
+For the "EMI2" MDIO bus, register 9 (BRDCFG1) controls the mux on that bus.
+A bitmask of 0x6 means that bits 1 and 2 (bit 0 is lsb) are the bits on
+BRDCFG1 that control the actual mux.
+
+	/* The FPGA node */
+	fpga: board-control@3,0 {
+		compatible = "fsl,p5020ds-fpga", "fsl,fpga-ngpixis";
+		reg = <3 0 0x30>;
+	};
+
+	/* The parent MDIO bus. */
+	xmdio0: mdio@f1000 {
+		#address-cells = <1>;
+		#size-cells = <0>;
+		compatible = "fsl,fman-xmdio";
+		reg = <0xf1000 0x1000>;
+		interrupts = <100 1 0 0>;
+	};
+
+	mdio-mux-emi2 {
+		compatible = "mdio-mux-fpga", "mdio-mux";
+		mdio-parent-bus = <&xmdio0>;
+		#address-cells = <1>;
+		#size-cells = <0>;
+		mdio-mux-device = <&fpga>;
+		mdio-mux-register = <9>; // BRDCFG1
+		mdio-mux-mask = <0x6>; // EMI2
+
+		emi2_slot1: mdio@0 {	// Slot 1 XAUI (FM2)
+			reg = <0>;
+			#address-cells = <1>;
+			#size-cells = <0>;
+
+			phy_xgmii_slot1: ethernet-phy@0 {
+				compatible = "ethernet-phy-ieee802.3-c45";
+				reg = <4>;
+			};
+		};
+
+		emi2_slot2: mdio@2 {	// Slot 2 XAUI (FM1)
+			reg = <2>;
+			#address-cells = <1>;
+			#size-cells = <0>;
+
+			phy_xgmii_slot2: ethernet-phy@4 {
+				compatible = "ethernet-phy-ieee802.3-c45";
+				reg = <0>;
+			};
+		};
+	};
+
diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 3090dc6..c3fc957 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -159,6 +159,19 @@ config MDIO_BUS_MUX_GPIO
 	  several child MDIO busses to a parent bus.  Child bus
 	  selection is under the control of GPIO lines.
 
+config MDIO_BUS_MUX_FPGA
+	tristate "Support for FPGA-controlled MDIO bus multiplexers"
+	depends on OF_MDIO
+	select MDIO_BUS_MUX
+	help
+	  This module provides a driver for MDIO bus multiplexers that
+	  are controlled via a simple memory-mapped FPGA device.  The
+	  multiplexer connects one of several child MDIO busses to a parent
+	  bus.  Child bus selection is under the control of one of the
+	  FPGA's registers.
+
+	  Currently, only 8-bit registers are supported.
+
 endif # PHYLIB
 
 config MICREL_KS8995MA
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index 6d2dc6c..3bf4d7a 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -28,3 +28,4 @@ obj-$(CONFIG_MICREL_KS8995MA)	+= spi_ks8995.o
 obj-$(CONFIG_AMD_PHY)		+= amd.o
 obj-$(CONFIG_MDIO_BUS_MUX)	+= mdio-mux.o
 obj-$(CONFIG_MDIO_BUS_MUX_GPIO)	+= mdio-mux-gpio.o
+obj-$(CONFIG_MDIO_BUS_MUX_FPGA) += mdio-mux-fpga.o
diff --git a/drivers/net/phy/mdio-mux-fpga.c b/drivers/net/phy/mdio-mux-fpga.c
new file mode 100644
index 0000000..7b4e69c
--- /dev/null
+++ b/drivers/net/phy/mdio-mux-fpga.c
@@ -0,0 +1,186 @@
+/*
+ * FPGA MDIO MUX driver
+ *
+ * This driver supports
+ * Author: Timur Tabi <timur@freescale.com>
+ *
+ * Copyright 2012 Freescale Semiconductor, Inc.
+ *
+ * This file is licensed under the terms of the GNU General Public License
+ * version 2.  This program is licensed "as is" without any warranty of any
+ * kind, whether express or implied.
+ */
+
+#include <linux/platform_device.h>
+#include <linux/device.h>
+#include <linux/of_mdio.h>
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/phy.h>
+#include <linux/mdio-mux.h>
+
+struct mdio_mux_fpga_state {
+	void *mux_handle;
+	phys_addr_t phys;
+	unsigned int offset;
+	uint8_t mask;
+};
+
+/*
+ * MDIO multiplexing switch function
+ *
+ * This function is called by the mdio-mux layer when it thinks the mdio bus
+ * multiplexer needs to switch.
+ *
+ * 'current_child' is the current value of the mux register (masked via
+ * s->mask).
+ *
+ * 'desired_child' is the value of the 'reg' property of the target child MDIO
+ * node.
+ *
+ * The first time this function is called, current_child == -1.
+ *
+ * If current_child == desired_child, then the mux is already set to the
+ * correct bus.
+ */
+static int mdio_mux_fpga_switch_fn(int current_child, int desired_child,
+				      void *data)
+{
+	struct mdio_mux_fpga_state *s = data;
+
+	if (current_child ^ desired_child) {
+		void *p = ioremap(s->phys + s->offset, 1);
+		uint8_t x;
+
+		if (!p)
+			return -ENOMEM;
+
+		x = ioread8(p);
+		iowrite8((x & ~s->mask) | desired_child, p);
+
+		iounmap(p);
+	}
+
+	return 0;
+}
+
+static int __devinit mdio_mux_fpga_probe(struct platform_device *pdev)
+{
+	struct device_node *np2, *np = pdev->dev.of_node;
+	struct mdio_mux_fpga_state *s;
+	struct resource res;
+	const __be32 *iprop;
+	int len, ret;
+
+	dev_dbg(&pdev->dev, "probing node %s\n", np->full_name);
+
+	s = devm_kzalloc(&pdev->dev, sizeof(*s), GFP_KERNEL);
+	if (!s)
+		return -ENOMEM;
+
+	iprop = of_get_property(np, "mdio-mux-device", &len);
+	if (!iprop || len != sizeof(phandle)) {
+		dev_err(&pdev->dev, "missing mdio-mux-device property\n");
+		return -ENODEV;
+	}
+	np2 = of_find_node_by_phandle(be32_to_cpup(iprop));
+	if (!np2) {
+		dev_err(&pdev->dev, "mdio-mux-device points to invalid node\n");
+		return -ENODEV;
+	}
+
+	ret = of_address_to_resource(np2, 0, &res);
+	if (ret) {
+		dev_err(&pdev->dev, "cannot obtain memory map for node %s\n",
+			np2->full_name);
+		return ret;
+	}
+	s->phys = res.start;
+
+	iprop = of_get_property(np, "mdio-mux-register", &len);
+	if (!iprop || len != sizeof(uint32_t)) {
+		dev_err(&pdev->dev, "missing mdio-mux-register property\n");
+		return -EINVAL;
+	}
+	s->offset = be32_to_cpup(iprop);
+	if (s->offset >= resource_size(&res)) {
+		dev_err(&pdev->dev, "mdio-mux-register value %u is too large\n",
+			s->offset);
+		return -EINVAL;
+	}
+
+	iprop = of_get_property(np, "mdio-mux-mask", &len);
+	if (!iprop || len != sizeof(uint32_t)) {
+		dev_err(&pdev->dev, "missing mdio-mux-mask property\n");
+		return -ENODEV;
+	}
+	if (be32_to_cpup(iprop) > 255) {
+		dev_err(&pdev->dev, "only 8-bit registers are supported\n");
+		return -EINVAL;
+	}
+	s->mask = be32_to_cpup(iprop);
+
+	/*
+	 * Verify that the 'reg' property of each child MDIO bus does not
+	 * set any bits outside of the 'mask'.
+	 */
+	for_each_available_child_of_node(np, np2) {
+		iprop = of_get_property(np2, "reg", &len);
+		if (!iprop || len != sizeof(uint32_t)) {
+			dev_err(&pdev->dev, "mdio-mux child node %s is "
+				"missing a 'reg' property\n", np2->full_name);
+			return -ENODEV;
+		}
+		if (be32_to_cpup(iprop) & ~s->mask) {
+			dev_err(&pdev->dev, "mdio-mux child node %s has "
+				"a 'reg' value with unmasked bits\n",
+				np2->full_name);
+			return -ENODEV;
+		}
+	}
+
+	ret = mdio_mux_init(&pdev->dev, mdio_mux_fpga_switch_fn,
+			    &s->mux_handle, s);
+	if (ret) {
+		dev_err(&pdev->dev, "failed to register mdio-mux bus %s\n",
+			np->full_name);
+		return ret;
+	}
+
+	pdev->dev.platform_data = s;
+
+	return 0;
+}
+
+static int __devexit mdio_mux_fpga_remove(struct platform_device *pdev)
+{
+	struct mdio_mux_fpga_state *s = dev_get_platdata(&pdev->dev);
+
+	mdio_mux_uninit(s->mux_handle);
+
+	return 0;
+}
+
+static struct of_device_id mdio_mux_fpga_match[] = {
+	{
+		.compatible = "mdio-mux-fpga",
+	},
+	{},
+};
+MODULE_DEVICE_TABLE(of, mdio_mux_fpga_match);
+
+static struct platform_driver mdio_mux_fpga_driver = {
+	.driver = {
+		.name		= "mdio-mux-fpga",
+		.owner		= THIS_MODULE,
+		.of_match_table = mdio_mux_fpga_match,
+	},
+	.probe		= mdio_mux_fpga_probe,
+	.remove		= __devexit_p(mdio_mux_fpga_remove),
+};
+
+module_platform_driver(mdio_mux_fpga_driver);
+
+MODULE_AUTHOR("Timur Tabi <timur@freescale.com>");
+MODULE_DESCRIPTION("FPGA MDIO MUX driver");
+MODULE_LICENSE("GPL v2");
-- 
1.7.3.4
