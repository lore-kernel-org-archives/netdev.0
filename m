From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH v3 2/2] rcar_can: add device tree support
Date: Fri, 1 Aug 2014 01:25:53 +0400
Message-ID: <201408010125.54723.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org, vksavl@gmail.com
To: netdev@vger.kernel.org, wg@grandegger.com, mkl@pengutronix.de,
	linux-can@vger.kernel.org, robh+dt@kernel.org,
	grant.likely@linaro.org, devicetree@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support of the device tree probing for the Renesas R-Car CAN controllers.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against the 'linux-can-next.git' repo plus the CAN clock handling
patch I've just posted.

Changes in version 3:
- resolved rejects due to the 'clock_select' variable declaration being moved to
  the CAN clock handling patch.

Changes in version 2:
- split the device tree bindings document into a separate patch;
- replaced 0 with CLKR_CLKP1 in the 'clock_select' variable intializer
- reversed the condition in the *if* stetement handling the reading of the
  CAN clock selector from the device tree or the paltfrom data;
- renamed the "clock-select" property to "renesas,can-clock-select";
- rebased the patch on top of the CAN clock handling fix.

 drivers/net/can/rcar_can.c |   28 ++++++++++++++++++++++------
 1 file changed, 22 insertions(+), 6 deletions(-)

Index: linux-can-next/drivers/net/can/rcar_can.c
===================================================================
--- linux-can-next.orig/drivers/net/can/rcar_can.c
+++ linux-can-next/drivers/net/can/rcar_can.c
@@ -20,6 +20,7 @@
 #include <linux/can/dev.h>
 #include <linux/clk.h>
 #include <linux/can/platform/rcar_can.h>
+#include <linux/of.h>
 
 #define RCAR_CAN_DRV_NAME	"rcar_can"
 
@@ -738,16 +739,21 @@ static int rcar_can_probe(struct platfor
 	struct net_device *ndev;
 	struct resource *mem;
 	void __iomem *addr;
-	u32 clock_select;
+	u32 clock_select = CLKR_CLKP1;
 	int err = -ENODEV;
 	int irq;
 
-	pdata = dev_get_platdata(&pdev->dev);
-	if (!pdata) {
-		dev_err(&pdev->dev, "No platform data provided!\n");
-		goto fail;
+	if (pdev->dev.of_node) {
+		of_property_read_u32(pdev->dev.of_node,
+				     "renesas,can-clock-select", &clock_select);
+	} else {
+		pdata = dev_get_platdata(&pdev->dev);
+		if (!pdata) {
+			dev_err(&pdev->dev, "No platform data provided!\n");
+			goto fail;
+		}
+		clock_select = pdata->clock_select;
 	}
-	clock_select = pdata->clock_select;
 
 	irq = platform_get_irq(pdev, 0);
 	if (!irq) {
@@ -888,10 +894,20 @@ static int __maybe_unused rcar_can_resum
 
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
