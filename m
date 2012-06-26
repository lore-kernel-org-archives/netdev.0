From: Shawn Guo <shawn.guo@linaro.org>
Subject: [PATCH 3/3] net: fec: add phy-reset-interval for device tree probe
Date: Tue, 26 Jun 2012 16:45:08 +0800
Message-ID: <1340700308-8315-4-git-send-email-shawn.guo@linaro.org>
References: <1340700308-8315-1-git-send-email-shawn.guo@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>,
	Shawn Guo <shawn.guo@linaro.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe006.messaging.microsoft.com ([213.199.154.209]:4110
	"EHLO am1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755729Ab2FZIpS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 04:45:18 -0400
In-Reply-To: <1340700308-8315-1-git-send-email-shawn.guo@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Different boards may require different phy reset interval time.  Add
property phy-reset-interval for device tree probe, so that the boards
that need a longer interval time can specify it in their device tree.

Along with the update to phy related stuff, it also makes a minor fix
on phy-reset-gpios in binding document to have it be optional to match
the driver code.

Signed-off-by: Shawn Guo <shawn.guo@linaro.org>
---
 Documentation/devicetree/bindings/net/fsl-fec.txt |    5 ++++-
 drivers/net/ethernet/freescale/fec.c              |    4 +++-
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/fsl-fec.txt b/Documentation/devicetree/bindings/net/fsl-fec.txt
index 7ab9e1a..74a4ce7 100644
--- a/Documentation/devicetree/bindings/net/fsl-fec.txt
+++ b/Documentation/devicetree/bindings/net/fsl-fec.txt
@@ -7,10 +7,13 @@ Required properties:
 - phy-mode : String, operation mode of the PHY interface.
   Supported values are: "mii", "gmii", "sgmii", "tbi", "rmii",
   "rgmii", "rgmii-id", "rgmii-rxid", "rgmii-txid", "rtbi", "smii".
-- phy-reset-gpios : Should specify the gpio for phy reset
 
 Optional properties:
 - local-mac-address : 6 bytes, mac address
+- phy-reset-gpios : Should specify the gpio for phy reset
+- phy-reset-interval : Reset interval time in milliseconds.  Should present
+  only if property "phy-reset-gpios" is available.  When "phy-reset-gpios"
+  is available, missing the property will have the interval be 1 millisecond.
 
 Example:
 
diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index 4dce9e3..86ecaae 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -1507,18 +1507,20 @@ static int __devinit fec_get_phy_mode_dt(struct platform_device *pdev)
 static void __devinit fec_reset_phy(struct platform_device *pdev)
 {
 	int err, phy_reset;
+	int msec = 1;
 	struct device_node *np = pdev->dev.of_node;
 
 	if (!np)
 		return;
 
+	of_property_read_u32(np, "phy-reset-interval", &msec);
 	phy_reset = of_get_named_gpio(np, "phy-reset-gpios", 0);
 	err = gpio_request_one(phy_reset, GPIOF_OUT_INIT_LOW, "phy-reset");
 	if (err) {
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
