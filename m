From: Bernhard Walle <bernhard@bwalle.de>
Subject: [PATCH] net: fec: Add "phy-reset-active-low" property to DT
Date: Mon,  8 Feb 2016 21:21:13 +0100
Message-ID: <1454962873-1941-1-git-send-email-bernhard@bwalle.de>
Cc: devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Bernhard Walle <bernhard@bwalle.de>
To: fabio.estevam@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay02.ispgateway.de ([80.67.31.40]:46611 "EHLO
	smtprelay02.ispgateway.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753799AbcBHU1l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 15:27:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need that for a custom hardware that needs the reverse reset
sequence.

Signed-off-by: Bernhard Walle <bernhard@bwalle.de>
---
 Documentation/devicetree/bindings/net/fsl-fec.txt | 3 +++
 drivers/net/ethernet/freescale/fec_main.c         | 8 ++++++--
 2 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/fsl-fec.txt b/Documentation/devicetree/bindings/net/fsl-fec.txt
index a9eb611..a4799ff 100644
--- a/Documentation/devicetree/bindings/net/fsl-fec.txt
+++ b/Documentation/devicetree/bindings/net/fsl-fec.txt
@@ -12,6 +12,9 @@ Optional properties:
   only if property "phy-reset-gpios" is available.  Missing the property
   will have the duration be 1 millisecond.  Numbers greater than 1000 are
   invalid and 1 millisecond will be used instead.
+- phy-reset-active-low : If present then the reset sequence using the GPIO
+  specified in the "phy-reset-gpios" property is reversed (H=reset state,
+  L=operation state).
 - phy-supply : regulator that powers the Ethernet PHY.
 - phy-handle : phandle to the PHY device connected to this device.
 - fixed-link : Assume a fixed link. See fixed-link.txt in the same directory.
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 41c81f6..98caf87 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -3229,6 +3229,7 @@ static int fec_enet_init(struct net_device *ndev)
 static void fec_reset_phy(struct platform_device *pdev)
 {
 	int err, phy_reset;
+	bool active_low = false;
 	int msec = 1;
 	struct device_node *np = pdev->dev.of_node;
 
@@ -3244,14 +3245,17 @@ static void fec_reset_phy(struct platform_device *pdev)
 	if (!gpio_is_valid(phy_reset))
 		return;
 
+	active_low = of_property_read_bool(np, "phy-reset-active-low");
+
 	err = devm_gpio_request_one(&pdev->dev, phy_reset,
-				    GPIOF_OUT_INIT_LOW, "phy-reset");
+			active_low ? GPIOF_OUT_INIT_HIGH : GPIOF_OUT_INIT_LOW,
+			"phy-reset");
 	if (err) {
 		dev_err(&pdev->dev, "failed to get phy-reset-gpios: %d\n", err);
 		return;
 	}
 	msleep(msec);
-	gpio_set_value_cansleep(phy_reset, 1);
+	gpio_set_value_cansleep(phy_reset, !active_low);
 }
 #else /* CONFIG_OF */
 static void fec_reset_phy(struct platform_device *pdev)
-- 
2.7.1
