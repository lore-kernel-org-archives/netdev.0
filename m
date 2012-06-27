From: Shawn Guo <shawn.guo@linaro.org>
Subject: [PATCH v2 5/5] net: fec: add phy-reset-duration for device tree probe
Date: Wed, 27 Jun 2012 21:45:24 +0800
Message-ID: <1340804724-29410-6-git-send-email-shawn.guo@linaro.org>
References: <1340804724-29410-1-git-send-email-shawn.guo@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: =?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>,
	Florian Fainelli <florian@openwrt.org>,
	<netdev@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>,
	<devicetree-discuss@lists.ozlabs.org>,
	Shawn Guo <shawn.guo@linaro.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe006.messaging.microsoft.com ([216.32.181.186]:51379
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755653Ab2F0Npm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 09:45:42 -0400
In-Reply-To: <1340804724-29410-1-git-send-email-shawn.guo@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Different boards may require different phy reset duration.  Add property
phy-reset-duration for device tree probe, so that the boards that need
a longer reset duration can specify it in their device tree.

Signed-off-by: Shawn Guo <shawn.guo@linaro.org>
---
 Documentation/devicetree/bindings/net/fsl-fec.txt |    4 ++++
 drivers/net/ethernet/freescale/fec.c              |    8 +++++++-
 2 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/fsl-fec.txt b/Documentation/devicetree/bindings/net/fsl-fec.txt
index 0428920..f7a2fef 100644
--- a/Documentation/devicetree/bindings/net/fsl-fec.txt
+++ b/Documentation/devicetree/bindings/net/fsl-fec.txt
@@ -11,6 +11,10 @@ Required properties:
 Optional properties:
 - local-mac-address : 6 bytes, mac address
 - phy-reset-gpios : Should specify the gpio for phy reset
+- phy-reset-duration : Reset duration in milliseconds.  Should present
+  only if property "phy-reset-gpios" is available.  Missing the property
+  will have the duration be 1 millisecond.  Numbers greater than 1000 are
+  invalid and 1 millisecond will be used instead.
 
 Example:
 
diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index f174070..dafd797 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -1507,11 +1507,17 @@ static int __devinit fec_get_phy_mode_dt(struct platform_device *pdev)
 static void __devinit fec_reset_phy(struct platform_device *pdev)
 {
 	int err, phy_reset;
+	int msec = 1;
 	struct device_node *np = pdev->dev.of_node;
 
 	if (!np)
 		return;
 
+	of_property_read_u32(np, "phy-reset-duration", &msec);
+	/* A sane reset duration should not be longer than 1s */
+	if (msec > 1000)
+		msec = 1;
+
 	phy_reset = of_get_named_gpio(np, "phy-reset-gpios", 0);
 	err = devm_gpio_request_one(&pdev->dev, phy_reset,
 				    GPIOF_OUT_INIT_LOW, "phy-reset");
@@ -1519,7 +1525,7 @@ static void __devinit fec_reset_phy(struct platform_device *pdev)
 		pr_debug("FEC: failed to get gpio phy-reset: %d\n", err);
 		return;
 	}
-	msleep(1);
+	msleep(msec);
 	gpio_set_value(phy_reset, 1);
 }
 #else /* CONFIG_OF */
-- 
1.7.5.4
