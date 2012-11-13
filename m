From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Subject: [RFC PATCH v1 3.7.0-rc4 2/2] dt:net/stmmac: Add dt specific phy reset callback support.
Date: Tue, 13 Nov 2012 13:50:45 +0000
Message-ID: <1352814645-14246-1-git-send-email-srinivas.kandagatla@st.com>
Cc: netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	srinivas.kandagatla@st.com, davem@davemloft.net
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:50460 "EHLO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754614Ab2KMNv0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2012 08:51:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Srinivas Kandagatla <srinivas.kandagatla@st.com>

This patch adds phy reset callback support for stmmac driver via device
trees. It adds three new properties to gmac device tree bindings to
define the reset signal via gpio.
With this patch users can conveniently pass reset gpio number with pre,
pulse and post delay in micro secs via DTs.

 active low:
	_________		 ____________
  <pre-delay>	 | <pulse-delay>|<post-delay>
		 |		|
		 |______________|

 active high:
 		 ________________
    <pre-delay>  |<pulse-delay>	|<post-delay>
		 |		|
	_________|		|___________

Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
---
 Documentation/devicetree/bindings/net/stmmac.txt  |   10 ++++
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c |   50 +++++++++++++++++----
 2 files changed, 51 insertions(+), 9 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
index b55d369..cdc536c 100644
--- a/Documentation/devicetree/bindings/net/stmmac.txt
+++ b/Documentation/devicetree/bindings/net/stmmac.txt
@@ -37,6 +37,12 @@ Optional properties:
 - snps,phy-bus-id	Mdio bus number to connect. if not specified 0 is used.
 - snps,phy-addr		phy address to connect to.
 
+- snps,reset-gpio 	gpio number for phy reset.
+- snps,reset-active-low boolean flag to indicate if phy reset is active low.
+- snps,reset-delays-us  is triplet of delays
+	The 1st cell is reset pre-delay in micro seconds.
+	The 2nd cell is reset pulse in micro seconds.
+	The 3rd cell is reset post-delay in micro seconds.
 
 Examples:
 
@@ -63,4 +69,8 @@ Examples:
 		snps,phy-bus-name = "stmmac";
 		snps,phy-bus-id = <0>;
 		snps,phy-addr = <0x9>;
+
+		snps,reset-gpio = <&gpio_bank4 7>;
+		snps,reset-active-low;
+		snps,reset-delays-us = <0 10000 10000>;
 	};
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
index 0376a5e..f965e83 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
@@ -27,6 +27,9 @@
 #include <linux/mii.h>
 #include <linux/phy.h>
 #include <linux/slab.h>
+#include <linux/of.h>
+#include <linux/of_gpio.h>
+
 #include <asm/io.h>
 
 #include "stmmac.h"
@@ -131,17 +134,46 @@ static int stmmac_mdio_reset(struct mii_bus *bus)
 	struct net_device *ndev = bus->priv;
 	struct stmmac_priv *priv = netdev_priv(ndev);
 	unsigned int mii_address = priv->hw->mii.addr;
+	struct device *dev = priv->device;
 
-	if (priv->plat->mdio_bus_data->phy_reset) {
-		pr_debug("stmmac_mdio_reset: calling phy_reset\n");
-		priv->plat->mdio_bus_data->phy_reset(priv->plat->bsp_priv);
-	}
+	if (!dev->of_node) {
+		if (priv->plat->mdio_bus_data->phy_reset) {
+			pr_debug("stmmac_mdio_reset: calling phy_reset\n");
+			priv->plat->mdio_bus_data->phy_reset(
+							priv->plat->bsp_priv);
+		}
+
+		/* This is a workaround for problems with the STE101P PHY.
+		 * It doesn't complete its reset until at least one clock cycle
+		 * on MDC, so perform a dummy mdio read.
+		 */
+		writel(0, priv->ioaddr + mii_address);
+	} else {
+		int reset_gpio, active_low;
+		struct device_node *np = dev->of_node;
+		u32 delays[3] = {0,};
+
+		if (!np)
+			return 0;
+
+		reset_gpio = of_get_named_gpio(np, "snps,reset-gpio", 0);
+		if (reset_gpio < 0)
+			return 0;
 
-	/* This is a workaround for problems with the STE101P PHY.
-	 * It doesn't complete its reset until at least one clock cycle
-	 * on MDC, so perform a dummy mdio read.
-	 */
-	writel(0, priv->ioaddr + mii_address);
+		active_low = of_get_property(np,
+				"snps,reset-active-low", NULL) ? 1 : 0;
+		of_property_read_u32_array(np,
+				"snps,reset-delays-us", delays, 3);
+
+		gpio_request(reset_gpio, "mdio-reset");
+		gpio_direction_output(reset_gpio, active_low ? 1 : 0);
+		udelay(delays[0]);
+		gpio_set_value(reset_gpio, active_low ? 0 : 1);
+		udelay(delays[1]);
+		gpio_set_value(reset_gpio, active_low ? 1 : 0);
+		udelay(delays[2]);
+		gpio_free(reset_gpio);
+	}
 #endif
 	return 0;
 }
-- 
1.7.0.4
