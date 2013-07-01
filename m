From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Subject: [PATCH RFC 3/3] dt:net:stmmac: Add dt specific phy reset callback support.
Date: Mon,  1 Jul 2013 12:44:05 +0100
Message-ID: <1372679045-13183-1-git-send-email-srinivas.kandagatla@st.com>
References: <1372678962-12959-1-git-send-email-srinivas.kandagatla@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>,
	Rob Landley <rob@landley.net>,
	devicetree-discuss@lists.ozlabs.org, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Srinivas Kandagatla <srinivas.kandagatla@st.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1372678962-12959-1-git-send-email-srinivas.kandagatla@st.com>
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
 Documentation/devicetree/bindings/net/stmmac.txt  |    6 ++++
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c |   31 +++++++++++++++++++++
 2 files changed, 37 insertions(+), 0 deletions(-)

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
index cc15039..677ed16 100644
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
@@ -131,6 +134,34 @@ static int stmmac_mdio_reset(struct mii_bus *bus)
 	struct net_device *ndev = bus->priv;
 	struct stmmac_priv *priv = netdev_priv(ndev);
 	unsigned int mii_address = priv->hw->mii.addr;
+	struct device *dev = priv->device;
+
+	if (dev->of_node) {
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
+
+		active_low = of_property_read_bool(np,
+					"snps,reset-active-low");
+		of_property_read_u32_array(np,
+					"snps,reset-delays-us", delays, 3);
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
 
 	if (priv->plat->mdio_bus_data->phy_reset) {
 		pr_debug("stmmac_mdio_reset: calling phy_reset\n");
-- 
1.7.6.5
