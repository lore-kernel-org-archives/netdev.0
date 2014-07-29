From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH v2 2/2] rcar_can: add device tree support
Date: Wed, 30 Jul 2014 02:53:41 +0400
Message-ID: <201407300253.42491.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org, vksavl@gmail.com
To: netdev@vger.kernel.org, wg@grandegger.com, mkl@pengutronix.de,
	linux-can@vger.kernel.org, robh+dt@kernel.org,
	grant.likely@linaro.org, devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:46048 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754456AbaG2Wxn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2014 18:53:43 -0400
Received: by mail-la0-f41.google.com with SMTP id s18so270436lam.14
        for <netdev@vger.kernel.org>; Tue, 29 Jul 2014 15:53:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support of the device tree probing for the Renesas R-Car CAN controllers.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against the 'linux-can-next.git' repo plus the CAN clock handling
patch I've just posted.

Changes in version 2:
- split the device tree bindings document into a separate patch;
- replaced 0 with CLKR_CLKP1 in the 'clock_select' variable intializer
- reversed the condition in the *if* stetement handling the reading of the
  CAN clock selector from the device tree or the paltfrom data;
- renamed the "clock-select" property to "renesas,can-clock-select";
- rebased the patch on top of the CAN clock handling fix.

 drivers/net/can/rcar_can.c |   33 +++++++++++++++++++++++++--------
 1 file changed, 25 insertions(+), 8 deletions(-)

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
 
@@ -738,13 +739,20 @@ static int rcar_can_probe(struct platfor
 	struct net_device *ndev;
 	struct resource *mem;
 	void __iomem *addr;
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
 
 	irq = platform_get_irq(pdev, 0);
@@ -776,13 +784,12 @@ static int rcar_can_probe(struct platfor
 		goto fail_clk;
 	}
 
-	if (pdata->clock_select > CLKR_CLKEXT) {
+	if (clock_select > CLKR_CLKEXT) {
 		err = -EINVAL;
 		dev_err(&pdev->dev, "invalid CAN clock selected\n");
 		goto fail_clk;
 	}
-	priv->can_clk = devm_clk_get(&pdev->dev,
-				     clock_names[pdata->clock_select]);
+	priv->can_clk = devm_clk_get(&pdev->dev, clock_names[clock_select]);
 	if (IS_ERR(priv->can_clk)) {
 		err = PTR_ERR(priv->can_clk);
 		dev_err(&pdev->dev, "cannot get CAN clock: %d\n", err);
@@ -794,7 +801,7 @@ static int rcar_can_probe(struct platfor
 	ndev->flags |= IFF_ECHO;
 	priv->ndev = ndev;
 	priv->regs = addr;
-	priv->clock_select = pdata->clock_select;
+	priv->clock_select = clock_select;
 	priv->can.clock.freq = clk_get_rate(priv->can_clk);
 	priv->can.bittiming_const = &rcar_can_bittiming_const;
 	priv->can.do_set_mode = rcar_can_do_set_mode;
@@ -887,10 +894,20 @@ static int __maybe_unused rcar_can_resum
 
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
