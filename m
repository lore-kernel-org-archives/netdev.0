From: Quentin Schulz <quentin.schulz-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: [PATCH v2] net: fec: add post PHY reset delay DT property
Date: Tue, 23 May 2017 11:48:08 +0200
Message-ID: <20170523094808.11102-1-quentin.schulz@free-electrons.com>
Cc: Quentin Schulz <quentin.schulz-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org
To: fugang.duan-3arQi8VN3Tc@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Some PHY require to wait for a bit after the reset GPIO has been
toggled. This adds support for the DT property `phy-reset-post-delay`
which gives the delay in milliseconds to wait after reset.

If the DT property is not given, no delay is observed. Post reset delay
greater than 1000ms are invalid.

Signed-off-by: Quentin Schulz <quentin.schulz-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
---

v2:
  - return -EINVAL when phy-reset-post-delay is greater than 1000ms
  instead of defaulting to 1ms,
  - remove `default to 1ms` when phy-reset-post-delay > 1000Ms from DT
  binding doc and commit log,
  - move phy-reset-post-delay property reading before
  devm_gpio_request_one(),

 Documentation/devicetree/bindings/net/fsl-fec.txt |  4 ++++
 drivers/net/ethernet/freescale/fec_main.c         | 16 +++++++++++++++-
 2 files changed, 19 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/fsl-fec.txt b/Documentation/devicetree/bindings/net/fsl-fec.txt
index a1e3693cca16..6f55bdd52f8a 100644
--- a/Documentation/devicetree/bindings/net/fsl-fec.txt
+++ b/Documentation/devicetree/bindings/net/fsl-fec.txt
@@ -15,6 +15,10 @@ Optional properties:
 - phy-reset-active-high : If present then the reset sequence using the GPIO
   specified in the "phy-reset-gpios" property is reversed (H=reset state,
   L=operation state).
+- phy-reset-post-delay : Post reset delay in milliseconds. If present then
+  a delay of phy-reset-post-delay milliseconds will be observed after the
+  phy-reset-gpios has been toggled. Can be omitted thus no delay is
+  observed. Delay is in range of 1ms to 1000ms. Other delays are invalid.
 - phy-supply : regulator that powers the Ethernet PHY.
 - phy-handle : phandle to the PHY device connected to this device.
 - fixed-link : Assume a fixed link. See fixed-link.txt in the same directory.
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 56a563f90b0b..f7c8649fd28f 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -3192,7 +3192,7 @@ static int fec_reset_phy(struct platform_device *pdev)
 {
 	int err, phy_reset;
 	bool active_high = false;
-	int msec = 1;
+	int msec = 1, phy_post_delay = 0;
 	struct device_node *np = pdev->dev.of_node;
 
 	if (!np)
@@ -3209,6 +3209,11 @@ static int fec_reset_phy(struct platform_device *pdev)
 	else if (!gpio_is_valid(phy_reset))
 		return 0;
 
+	err = of_property_read_u32(np, "phy-reset-post-delay", &phy_post_delay);
+	/* valid reset duration should be less than 1s */
+	if (!err && phy_post_delay > 1000)
+		return -EINVAL;
+
 	active_high = of_property_read_bool(np, "phy-reset-active-high");
 
 	err = devm_gpio_request_one(&pdev->dev, phy_reset,
@@ -3226,6 +3231,15 @@ static int fec_reset_phy(struct platform_device *pdev)
 
 	gpio_set_value_cansleep(phy_reset, !active_high);
 
+	if (!phy_post_delay)
+		return 0;
+
+	if (phy_post_delay > 20)
+		msleep(phy_post_delay);
+	else
+		usleep_range(phy_post_delay * 1000,
+			     phy_post_delay * 1000 + 1000);
+
 	return 0;
 }
 #else /* CONFIG_OF */
-- 
2.11.0

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
