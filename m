From: Robin Holt <holt@sgi.com>
Subject: [PATCH v12 5/6] flexcan: Prefer device tree clock frequency if available.
Date: Fri, 12 Aug 2011 03:45:51 -0500
Message-ID: <1313138752-24006-6-git-send-email-holt@sgi.com>
References: <1313138752-24006-1-git-send-email-holt@sgi.com>
Cc: Robin Holt <holt@sgi.com>, socketcan-core@lists.berlios.de,
	netdev@vger.kernel.org, PPC list <linuxppc-dev@lists.ozlabs.org>,
	devicetree-discuss@lists.ozlabs.org
To: Robin Holt <holt@sgi.com>, Kumar Gala <galak@kernel.crashing.org>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	U Bhaskar-B22300 <B22300@freescale.
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.179.29]:48940 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752626Ab1HLIqc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Aug 2011 04:46:32 -0400
In-Reply-To: <1313138752-24006-1-git-send-email-holt@sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If our CAN device's device tree node has a clock-frequency property,
then use that value for the can devices clock frequency.  If not, fall
back to asking the platform/mach code for the clock frequency associated
with the flexcan device.

Signed-off-by: Robin Holt <holt@sgi.com>
To: Kumar Gala <galak@kernel.crashing.org>
To: Wolfgang Grandegger <wg@grandegger.com>,
To: Marc Kleine-Budde <mkl@pengutronix.de>,
To: U Bhaskar-B22300 <B22300@freescale.com>
To: Scott Wood <scottwood@freescale.com>
To: Grant Likely <grant.likely@secretlab.ca>
Cc: socketcan-core@lists.berlios.de,
Cc: netdev@vger.kernel.org,
Cc: PPC list <linuxppc-dev@lists.ozlabs.org>
Cc: devicetree-discuss@lists.ozlabs.org
---
 .../devicetree/bindings/net/can/fsl-flexcan.txt    |    2 +
 drivers/net/can/flexcan.c                          |   34 ++++++++++++++-----
 2 files changed, 27 insertions(+), 9 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/can/fsl-flexcan.txt b/Documentation/devicetree/bindings/net/can/fsl-flexcan.txt
index 80a78a9..80313db 100644
--- a/Documentation/devicetree/bindings/net/can/fsl-flexcan.txt
+++ b/Documentation/devicetree/bindings/net/can/fsl-flexcan.txt
@@ -11,6 +11,7 @@ Required properties:
 
 - reg : Offset and length of the register set for this device
 - interrupts : Interrupt tuple for this device
+- clock-frequency : The oscillator frequency driving the flexcan device
 
 Example:
 
@@ -19,4 +20,5 @@ Example:
 		reg = <0x1c000 0x1000>;
 		interrupts = <48 0x2>;
 		interrupt-parent = <&mpic>;
+		clock-frequency = <200000000>; // filled in by bootloader
 	};
diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index 662f832..f5fd3f8 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -33,6 +33,7 @@
 #include <linux/kernel.h>
 #include <linux/list.h>
 #include <linux/module.h>
+#include <linux/of.h>
 #include <linux/platform_device.h>
 
 #define DRV_NAME			"flexcan"
@@ -925,16 +926,29 @@ static int __devinit flexcan_probe(struct platform_device *pdev)
 	struct net_device *dev;
 	struct flexcan_priv *priv;
 	struct resource *mem;
-	struct clk *clk;
+	struct clk *clk = NULL;
 	void __iomem *base;
 	resource_size_t mem_size;
 	int err, irq;
+	u32 clock_freq = 0;
+
+	if (pdev->dev.of_node) {
+		const u32 *clock_freq_p;
 
-	clk = clk_get(&pdev->dev, NULL);
-	if (IS_ERR(clk)) {
-		dev_err(&pdev->dev, "no clock defined\n");
-		err = PTR_ERR(clk);
-		goto failed_clock;
+		clock_freq_p = of_get_property(pdev->dev.of_node,
+						"clock-frequency", NULL);
+		if (clock_freq_p)
+			clock_freq = *clock_freq_p;
+	}
+
+	if (!clock_freq) {
+		clk = clk_get(&pdev->dev, NULL);
+		if (IS_ERR(clk)) {
+			dev_err(&pdev->dev, "no clock defined\n");
+			err = PTR_ERR(clk);
+			goto failed_clock;
+		}
+		clock_freq = clk_get_rate(clk);
 	}
 
 	mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
@@ -967,7 +981,7 @@ static int __devinit flexcan_probe(struct platform_device *pdev)
 	dev->flags |= IFF_ECHO; /* we support local echo in hardware */
 
 	priv = netdev_priv(dev);
-	priv->can.clock.freq = clk_get_rate(clk);
+	priv->can.clock.freq = clock_freq;
 	priv->can.bittiming_const = &flexcan_bittiming_const;
 	priv->can.do_set_mode = flexcan_set_mode;
 	priv->can.do_get_berr_counter = flexcan_get_berr_counter;
@@ -1002,7 +1016,8 @@ static int __devinit flexcan_probe(struct platform_device *pdev)
  failed_map:
 	release_mem_region(mem->start, mem_size);
  failed_get:
-	clk_put(clk);
+	if (clk)
+		clk_put(clk);
  failed_clock:
 	return err;
 }
@@ -1020,7 +1035,8 @@ static int __devexit flexcan_remove(struct platform_device *pdev)
 	mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	release_mem_region(mem->start, resource_size(mem));
 
-	clk_put(priv->clk);
+	if (priv->clk)
+		clk_put(priv->clk);
 
 	free_candev(dev);
 
-- 
1.7.2.1

