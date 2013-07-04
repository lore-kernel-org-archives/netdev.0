From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Subject: [PATCH v2 3/3] dt:net:stmmac: Add dt specific phy reset callback support.
Date: Thu,  4 Jul 2013 10:35:48 +0100
Message-ID: <1372930548-19452-1-git-send-email-srinivas.kandagatla@st.com>
References: <1372930496-18923-1-git-send-email-srinivas.kandagatla@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>,
	Rob Landley <rob@landley.net>,
	devicetree-discuss@lists.ozlabs.org, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Srinivas Kandagatla <srinivas.kandagatla@st.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1372930496-18923-1-git-send-email-srinivas.kandagatla@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Srinivas Kandagatla <srinivas.kandagatla@st.com>

This patch adds phy reset callback support for stmmac driver via device
trees. It adds three new properties to gmac device tree bindings to
define the reset signal via gpio.

With this patch users can conveniently pass reset gpio number with pre,
pulse and post delay in micro secs via DTs.

 active low:
		_________		 ____________
	<pre-delay>	|<pulse-delay>	|<post-delay>
		 	|		|
		 	|_______________|

 active high:
 			 ________________
	<pre-delay>	|<pulse-delay>	|<post-delay>
			|		|
		________|		|___________

Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
---
 Documentation/devicetree/bindings/net/stmmac.txt  |    6 +++
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c |   48 ++++++++++++++++++++-
 include/linux/stmmac.h                            |    4 ++
 3 files changed, 56 insertions(+), 2 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
index e1ddfcc..261c563 100644
--- a/Documentation/devicetree/bindings/net/stmmac.txt
+++ b/Documentation/devicetree/bindings/net/stmmac.txt
@@ -13,6 +13,12 @@ Required properties:
 - phy-mode: String, operation mode of the PHY interface.
   Supported values are: "mii", "rmii", "gmii", "rgmii".
 - snps,phy-addr		phy address to connect to.
+- snps,reset-gpio 	gpio number for phy reset.
+- snps,reset-active-low boolean flag to indicate if phy reset is active low.
+- snps,reset-delays-us  is triplet of delays
+	The 1st cell is reset pre-delay in micro seconds.
+	The 2nd cell is reset pulse in micro seconds.
+	The 3rd cell is reset post-delay in micro seconds.
 - snps,pbl		Programmable Burst Length
 - snps,fixed-burst	Program the DMA to use the fixed burst mode
 - snps,mixed-burst	Program the DMA to use the mixed burst mode
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
index cc15039..fe7bc99 100644
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
@@ -131,10 +134,46 @@ static int stmmac_mdio_reset(struct mii_bus *bus)
 	struct net_device *ndev = bus->priv;
 	struct stmmac_priv *priv = netdev_priv(ndev);
 	unsigned int mii_address = priv->hw->mii.addr;
+	struct stmmac_mdio_bus_data *data = priv->plat->mdio_bus_data;
+
+#ifdef CONFIG_OF
+	if (priv->device->of_node) {
+		int reset_gpio, active_low;
+
+		if (data->reset_gpio < 0) {
+			struct device_node *np = priv->device->of_node;
+			if (!np)
+				return 0;
+
+			data->reset_gpio = of_get_named_gpio(np,
+						"snps,reset-gpio", 0);
+			if (data->reset_gpio < 0)
+				return 0;
+
+			data->active_low = of_property_read_bool(np,
+						"snps,reset-active-low");
+			of_property_read_u32_array(np,
+				"snps,reset-delays-us", data->delays, 3);
+		}
+
+		reset_gpio = data->reset_gpio;
+		active_low = data->active_low;
+
+		if (!gpio_request(reset_gpio, "mdio-reset")) {
+			gpio_direction_output(reset_gpio, active_low ? 1 : 0);
+			udelay(data->delays[0]);
+			gpio_set_value(reset_gpio, active_low ? 0 : 1);
+			udelay(data->delays[1]);
+			gpio_set_value(reset_gpio, active_low ? 1 : 0);
+			udelay(data->delays[2]);
+			gpio_free(reset_gpio);
+		}
+	}
+#endif
 
-	if (priv->plat->mdio_bus_data->phy_reset) {
+	if (data->phy_reset) {
 		pr_debug("stmmac_mdio_reset: calling phy_reset\n");
-		priv->plat->mdio_bus_data->phy_reset(priv->plat->bsp_priv);
+		data->phy_reset(priv->plat->bsp_priv);
 	}
 
 	/* This is a workaround for problems with the STE101P PHY.
@@ -172,6 +211,11 @@ int stmmac_mdio_register(struct net_device *ndev)
 	else
 		irqlist = priv->mii_irq;
 
+#ifdef CONFIG_OF
+	if (priv->device->of_node)
+		mdio_bus_data->reset_gpio = -1;
+#endif
+
 	new_bus->name = "stmmac";
 	new_bus->read = &stmmac_mdio_read;
 	new_bus->write = &stmmac_mdio_write;
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index c1b3ed3..9e495d31 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -80,6 +80,10 @@ struct stmmac_mdio_bus_data {
 	unsigned int phy_mask;
 	int *irqs;
 	int probed_phy_irq;
+#ifdef CONFIG_OF
+	int reset_gpio, active_low;
+	u32 delays[3];
+#endif
 };
 
 struct stmmac_dma_cfg {
-- 
1.7.6.5
