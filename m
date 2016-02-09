From: Bernhard Walle <bernhard-X9USDgGjgfuzQB+pC5nmwQ@public.gmane.org>
Subject: [PATCH v2] net: fec: Add "phy-reset-active-low" property to DT
Date: Tue,  9 Feb 2016 21:01:12 +0100
Message-ID: <1455048072-869-1-git-send-email-bernhard@bwalle.de>
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Bernhard Walle <bernhard-X9USDgGjgfuzQB+pC5nmwQ@public.gmane.org>
To: fabio.estevam-KZfg59tc24xl57MIdRCFDg@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

We need that for a custom hardware that needs the reverse reset
sequence.

Signed-off-by: Bernhard Walle <bernhard-X9USDgGjgfuzQB+pC5nmwQ@public.gmane.org>
---
Changes compared to v1:
 - Add documentation to 'phy-reset-gpios' that flags are ignored
   as suggested by Andrew Lunn.

 Documentation/devicetree/bindings/net/fsl-fec.txt | 7 ++++++-
 drivers/net/ethernet/freescale/fec_main.c         | 8 ++++++--
 2 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/fsl-fec.txt b/Documentation/devicetree/bindings/net/fsl-fec.txt
index a9eb611..0caa429 100644
--- a/Documentation/devicetree/bindings/net/fsl-fec.txt
+++ b/Documentation/devicetree/bindings/net/fsl-fec.txt
@@ -7,11 +7,16 @@ Required properties:
 - phy-mode : See ethernet.txt file in the same directory
 
 Optional properties:
-- phy-reset-gpios : Should specify the gpio for phy reset
+- phy-reset-gpios : Should specify the gpio for phy reset. Additional
+  flags are ignored, see the non-standard 'phy-reset-active-low' property
+  instead.
 - phy-reset-duration : Reset duration in milliseconds.  Should present
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

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
