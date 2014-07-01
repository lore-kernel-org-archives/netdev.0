From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] rcar_can: add device tree support
Date: Wed, 2 Jul 2014 02:27:03 +0400
Message-ID: <201407020227.04235.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org, vksavl@gmail.com, rdunlap@infradead.org,
	linux-doc@vger.kernel.org
To: netdev@vger.kernel.org, wg@grandegger.com, mkl@pengutronix.de,
	linux-can@vger.kernel.org, robh+dt@kernel.org, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, grant.likely@linaro.org,
	devicetree@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support of the device tree probing for the Renesas R-Car CAN controllers
documenting the device tree bindings as necessary.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against the Dave Miller's 'net-next.git' repo ('linux-can-next.git'
repo still doesn't have the R-Car CAN driver for some reason).

 Documentation/devicetree/bindings/net/can/rcar_can.txt |   40 +++++++++++++++++
 drivers/net/can/rcar_can.c                             |   28 +++++++++--
 2 files changed, 63 insertions(+), 5 deletions(-)

Index: net-next/Documentation/devicetree/bindings/net/can/rcar_can.txt
===================================================================
--- /dev/null
+++ net-next/Documentation/devicetree/bindings/net/can/rcar_can.txt
@@ -0,0 +1,40 @@
+Renesas R-Car CAN controller Device Tree Bindings
+-------------------------------------------------
+
+Required properties:
+- compatible: "renesas,can-r8a7778" if CAN controller is a part of R8A7778 SoC.
+	      "renesas,can-r8a7779" if CAN controller is a part of R8A7779 SoC.
+	      "renesas,can-r8a7790" if CAN controller is a part of R8A7790 SoC.
+	      "renesas,can-r8a7791" if CAN controller is a part of R8A7791 SoC.
+- reg: physical base address and size of the R-Car CAN register map.
+- interrupts: interrupt specifier for the sole interrupt.
+- clocks: phandle and clock specifier for the R-Car CAN clock input.
+- pinctrl-0: pin control group to be used for this controller.
+- pinctrl-names: must be "default".
+
+Optional properties:
+- clock-select: R-Car CAN Clock Source Select. Valid values are:
+		<0x0> (default) : Peripheral clock (clkp1)
+		<0x1> : Peripheral clock (clkp2)
+		<0x3> : Externally input clock
+
+Example
+-------
+
+SoC common .dtsi file:
+
+	can0: can@e6e80000 {
+		compatible = "renesas,can-r8a7791";
+		reg = <0 0xe6e80000 0 0x1000>;
+		interrupts = <0 186 IRQ_TYPE_LEVEL_HIGH>;
+		clocks = <&mstp9_clks R8A7791_CLK_RCAN0>;
+		status = "disabled";
+	};
+
+Board specific .dts file:
+
+&can0 {
+	pinctrl-0 = <&can0_pins>;
+	pinctrl-names = "default";
+	status = "okay";
+};
Index: net-next/drivers/net/can/rcar_can.c
===================================================================
--- net-next.orig/drivers/net/can/rcar_can.c
+++ net-next/drivers/net/can/rcar_can.c
@@ -20,6 +20,7 @@
 #include <linux/can/dev.h>
 #include <linux/clk.h>
 #include <linux/can/platform/rcar_can.h>
+#include <linux/of.h>
 
 #define RCAR_CAN_DRV_NAME	"rcar_can"
 
@@ -722,13 +723,20 @@ static int rcar_can_probe(struct platfor
 	struct net_device *ndev;
 	struct resource *mem;
 	void __iomem *addr;
+	u32 clock_select = 0;
 	int err = -ENODEV;
 	int irq;
 
-	pdata = dev_get_platdata(&pdev->dev);
-	if (!pdata) {
-		dev_err(&pdev->dev, "No platform data provided!\n");
-		goto fail;
+	if (!pdev->dev.of_node) {
+		pdata = dev_get_platdata(&pdev->dev);
+		if (!pdata) {
+			dev_err(&pdev->dev, "No platform data provided!\n");
+			goto fail;
+		}
+		clock_select = pdata->clock_select;
+	} else {
+		of_property_read_u32(pdev->dev.of_node, "clock-select",
+				     &clock_select);
 	}
 
 	irq = platform_get_irq(pdev, 0);
@@ -765,7 +773,7 @@ static int rcar_can_probe(struct platfor
 	ndev->flags |= IFF_ECHO;
 	priv->ndev = ndev;
 	priv->regs = addr;
-	priv->clock_select = pdata->clock_select;
+	priv->clock_select = clock_select;
 	priv->can.clock.freq = clk_get_rate(priv->clk);
 	priv->can.bittiming_const = &rcar_can_bittiming_const;
 	priv->can.do_set_mode = rcar_can_do_set_mode;
@@ -858,10 +866,20 @@ static int __maybe_unused rcar_can_resum
 
 static SIMPLE_DEV_PM_OPS(rcar_can_pm_ops, rcar_can_suspend, rcar_can_resume);
 
+static const struct of_device_id rcar_can_of_table[] __maybe_unused = {
+	{ .compatible = "renesas,can-r8a7778" },
+	{ .compatible = "renesas,can-r8a7779" },
+	{ .compatible = "renesas,can-r8a7790" },
+	{ .compatible = "renesas,can-r8a7791" },
+	{ }
+};
+MODULE_DEVICE_TABLE(of, rcar_can_of_table);
+
 static struct platform_driver rcar_can_driver = {
 	.driver = {
 		.name = RCAR_CAN_DRV_NAME,
 		.owner = THIS_MODULE,
+		.of_match_table = of_match_ptr(rcar_can_of_table),
 		.pm = &rcar_can_pm_ops,
 	},
 	.probe = rcar_can_probe,
