From: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v7 09/10] net: stmmac: dwmac-sun8i: Handle
 integrated/external MDIOs
Date: Wed, 18 Oct 2017 13:44:57 +0200
Message-ID: <20171018114458.17891-10-clabbe.montjoie@gmail.com>
References: <20171018114458.17891-1-clabbe.montjoie@gmail.com>
Reply-To: clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
	Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	mark.rutland-5wv7dgnIgG8@public.gmane.org,
	maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org,
	wens-jdAy2FN1RRM@public.gmane.org,
	linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org,
	catalin.marinas-5wv7dgnIgG8@public.gmane.org,
	will.deacon-5wv7dgnIgG8@public.gmane.org,
	peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
	alexandre.torgue-qxv4g6HH51o@public.gmane.org,
	andrew-g2DYL2Zd6BY@public.gmane.org,
	f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-sunxi+bncBD7YLCN32UNBBSX6TTHQKGQE6QFI47I-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <20171018114458.17891-1-clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

The Allwinner H3 SoC have two distinct MDIO bus, only one could be
active at the same time.
The selection of the active MDIO bus are done via some bits in the EMAC
register of the system controller.

This patch implement this MDIO switch via a custom MDIO-mux.

Signed-off-by: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/ethernet/stmicro/stmmac/Kconfig       |   1 +
 drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c | 353 ++++++++++++++--------
 2 files changed, 224 insertions(+), 130 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/Kconfig b/drivers/net/ethernet/stmicro/stmmac/Kconfig
index 97035766c291..e28c0d2c58e9 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Kconfig
+++ b/drivers/net/ethernet/stmicro/stmmac/Kconfig
@@ -159,6 +159,7 @@ config DWMAC_SUN8I
 	tristate "Allwinner sun8i GMAC support"
 	default ARCH_SUNXI
 	depends on OF && (ARCH_SUNXI || COMPILE_TEST)
+	select MDIO_BUS_MUX
 	---help---
 	  Support for Allwinner H3 A83T A64 EMAC ethernet controllers.
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c
index fffd6d5fc907..7741235093b9 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c
@@ -17,6 +17,7 @@
 #include <linux/clk.h>
 #include <linux/io.h>
 #include <linux/iopoll.h>
+#include <linux/mdio-mux.h>
 #include <linux/mfd/syscon.h>
 #include <linux/module.h>
 #include <linux/of_device.h>
@@ -41,14 +42,14 @@
  *				This value is used for disabling properly EMAC
  *				and used as a good starting value in case of the
  *				boot process(uboot) leave some stuff.
- * @internal_phy:		Does the MAC embed an internal PHY
+ * @soc_has_internal_phy:	Does the MAC embed an internal PHY
  * @support_mii:		Does the MAC handle MII
  * @support_rmii:		Does the MAC handle RMII
  * @support_rgmii:		Does the MAC handle RGMII
  */
 struct emac_variant {
 	u32 default_syscon_value;
-	int internal_phy;
+	bool soc_has_internal_phy;
 	bool support_mii;
 	bool support_rmii;
 	bool support_rgmii;
@@ -61,7 +62,8 @@ struct emac_variant {
  * @rst_ephy:	reference to the optional EPHY reset for the internal PHY
  * @variant:	reference to the current board variant
  * @regmap:	regmap for using the syscon
- * @use_internal_phy: Does the current PHY choice imply using the internal PHY
+ * @internal_phy_powered: Does the internal PHY is enabled
+ * @mux_handle:	Internal pointer used by mdio-mux lib
  */
 struct sunxi_priv_data {
 	struct clk *tx_clk;
@@ -70,12 +72,13 @@ struct sunxi_priv_data {
 	struct reset_control *rst_ephy;
 	const struct emac_variant *variant;
 	struct regmap *regmap;
-	bool use_internal_phy;
+	bool internal_phy_powered;
+	void *mux_handle;
 };
 
 static const struct emac_variant emac_variant_h3 = {
 	.default_syscon_value = 0x58000,
-	.internal_phy = PHY_INTERFACE_MODE_MII,
+	.soc_has_internal_phy = true,
 	.support_mii = true,
 	.support_rmii = true,
 	.support_rgmii = true
@@ -83,20 +86,20 @@ static const struct emac_variant emac_variant_h3 = {
 
 static const struct emac_variant emac_variant_v3s = {
 	.default_syscon_value = 0x38000,
-	.internal_phy = PHY_INTERFACE_MODE_MII,
+	.soc_has_internal_phy = true,
 	.support_mii = true
 };
 
 static const struct emac_variant emac_variant_a83t = {
 	.default_syscon_value = 0,
-	.internal_phy = 0,
+	.soc_has_internal_phy = false,
 	.support_mii = true,
 	.support_rgmii = true
 };
 
 static const struct emac_variant emac_variant_a64 = {
 	.default_syscon_value = 0,
-	.internal_phy = 0,
+	.soc_has_internal_phy = false,
 	.support_mii = true,
 	.support_rmii = true,
 	.support_rgmii = true
@@ -195,6 +198,9 @@ static const struct emac_variant emac_variant_a64 = {
 #define H3_EPHY_LED_POL		BIT(17) /* 1: active low, 0: active high */
 #define H3_EPHY_SHUTDOWN	BIT(16) /* 1: shutdown, 0: power up */
 #define H3_EPHY_SELECT		BIT(15) /* 1: internal PHY, 0: external PHY */
+#define H3_EPHY_MUX_MASK	(H3_EPHY_SHUTDOWN | H3_EPHY_SELECT)
+#define DWMAC_SUN8I_MDIO_MUX_INTERNAL_ID	1
+#define DWMAC_SUN8I_MDIO_MUX_EXTERNAL_ID	2
 
 /* H3/A64 specific bits */
 #define SYSCON_RMII_EN		BIT(13) /* 1: enable RMII (overrides EPIT) */
@@ -634,6 +640,159 @@ static int sun8i_dwmac_reset(struct stmmac_priv *priv)
 	return 0;
 }
 
+/* Search in mdio-mux node for internal PHY node and get its clk/reset */
+static int get_ephy_nodes(struct stmmac_priv *priv)
+{
+	struct sunxi_priv_data *gmac = priv->plat->bsp_priv;
+	struct device_node *mdio_mux, *iphynode;
+	struct device_node *mdio_internal;
+	int ret;
+
+	mdio_mux = of_get_child_by_name(priv->plat->mdio_node, "mdio-mux");
+	if (!mdio_mux) {
+		dev_err(priv->device, "Cannot get mdio-mux node\n");
+		return -ENODEV;
+	}
+
+	mdio_internal = of_find_compatible_node(mdio_mux, NULL,
+						"allwinner,sun8i-h3-mdio-internal");
+	if (!mdio_internal) {
+		dev_err(priv->device, "Cannot get internal_mdio node\n");
+		return -ENODEV;
+	}
+
+	/* Seek for internal PHY */
+	for_each_child_of_node(mdio_internal, iphynode) {
+		gmac->ephy_clk = of_clk_get(iphynode, 0);
+		if (IS_ERR(gmac->ephy_clk))
+			continue;
+		gmac->rst_ephy = of_reset_control_get_exclusive(iphynode, NULL);
+		if (IS_ERR(gmac->rst_ephy)) {
+			ret = PTR_ERR(gmac->rst_ephy);
+			if (ret == -EPROBE_DEFER)
+				return ret;
+			continue;
+		}
+		dev_info(priv->device, "Found internal PHY node\n");
+		return 0;
+	}
+	return -ENODEV;
+}
+
+static int sun8i_dwmac_power_internal_phy(struct stmmac_priv *priv)
+{
+	struct sunxi_priv_data *gmac = priv->plat->bsp_priv;
+	int ret;
+
+	if (gmac->internal_phy_powered) {
+		dev_warn(priv->device, "Internal PHY already powered\n");
+		return 0;
+	}
+
+	dev_info(priv->device, "Powering internal PHY\n");
+	ret = clk_prepare_enable(gmac->ephy_clk);
+	if (ret) {
+		dev_err(priv->device, "Cannot enable internal PHY\n");
+		return ret;
+	}
+
+	/* Make sure the EPHY is properly reseted, as U-Boot may leave
+	 * it at deasserted state, and thus it may fail to reset EMAC.
+	 */
+	reset_control_assert(gmac->rst_ephy);
+
+	ret = reset_control_deassert(gmac->rst_ephy);
+	if (ret) {
+		dev_err(priv->device, "Cannot deassert internal phy\n");
+		clk_disable_unprepare(gmac->ephy_clk);
+		return ret;
+	}
+
+	gmac->internal_phy_powered = true;
+
+	return 0;
+}
+
+static int sun8i_dwmac_unpower_internal_phy(struct sunxi_priv_data *gmac)
+{
+	if (!gmac->internal_phy_powered)
+		return 0;
+
+	clk_disable_unprepare(gmac->ephy_clk);
+	reset_control_assert(gmac->rst_ephy);
+	gmac->internal_phy_powered = false;
+	return 0;
+}
+
+/* MDIO multiplexing switch function
+ * This function is called by the mdio-mux layer when it thinks the mdio bus
+ * multiplexer needs to switch.
+ * 'current_child' is the current value of the mux register
+ * 'desired_child' is the value of the 'reg' property of the target child MDIO
+ * node.
+ * The first time this function is called, current_child == -1.
+ * If current_child == desired_child, then the mux is already set to the
+ * correct bus.
+ */
+static int mdio_mux_syscon_switch_fn(int current_child, int desired_child,
+				     void *data)
+{
+	struct stmmac_priv *priv = data;
+	struct sunxi_priv_data *gmac = priv->plat->bsp_priv;
+	u32 reg, val;
+	int ret = 0;
+	bool need_power_ephy = false;
+
+	if (current_child ^ desired_child) {
+		regmap_read(gmac->regmap, SYSCON_EMAC_REG, &reg);
+		switch (desired_child) {
+		case DWMAC_SUN8I_MDIO_MUX_INTERNAL_ID:
+			dev_info(priv->device, "Switch mux to internal PHY");
+			val = (reg & ~H3_EPHY_MUX_MASK) | H3_EPHY_SELECT;
+
+			need_power_ephy = true;
+			break;
+		case DWMAC_SUN8I_MDIO_MUX_EXTERNAL_ID:
+			dev_info(priv->device, "Switch mux to external PHY");
+			val = (reg & ~H3_EPHY_MUX_MASK) | H3_EPHY_SHUTDOWN;
+			need_power_ephy = false;
+			break;
+		default:
+			dev_err(priv->device, "Invalid child ID %x\n",
+				desired_child);
+			return -EINVAL;
+		}
+		regmap_write(gmac->regmap, SYSCON_EMAC_REG, val);
+		if (need_power_ephy) {
+			ret = sun8i_dwmac_power_internal_phy(priv);
+			if (ret)
+				return ret;
+		} else {
+			sun8i_dwmac_unpower_internal_phy(gmac);
+		}
+		/* After changing syscon value, the MAC need reset or it will
+		 * use the last value (and so the last PHY set).
+		 */
+		ret = sun8i_dwmac_reset(priv);
+	}
+	return ret;
+}
+
+static int sun8i_dwmac_register_mdio_mux(struct stmmac_priv *priv)
+{
+	int ret;
+	struct device_node *mdio_mux;
+	struct sunxi_priv_data *gmac = priv->plat->bsp_priv;
+
+	mdio_mux = of_get_child_by_name(priv->plat->mdio_node, "mdio-mux");
+	if (!mdio_mux)
+		return -ENODEV;
+
+	ret = mdio_mux_init(priv->device, mdio_mux, mdio_mux_syscon_switch_fn,
+			    &gmac->mux_handle, priv, priv->mii);
+	return ret;
+}
+
 static int sun8i_dwmac_set_syscon(struct stmmac_priv *priv)
 {
 	struct sunxi_priv_data *gmac = priv->plat->bsp_priv;
@@ -648,35 +807,25 @@ static int sun8i_dwmac_set_syscon(struct stmmac_priv *priv)
 			 "Current syscon value is not the default %x (expect %x)\n",
 			 val, reg);
 
-	if (gmac->variant->internal_phy) {
-		if (!gmac->use_internal_phy) {
-			/* switch to external PHY interface */
-			reg &= ~H3_EPHY_SELECT;
-		} else {
-			reg |= H3_EPHY_SELECT;
-			reg &= ~H3_EPHY_SHUTDOWN;
-			dev_dbg(priv->device, "Select internal_phy %x\n", reg);
-
-			if (of_property_read_bool(priv->plat->phy_node,
-						  "allwinner,leds-active-low"))
-				reg |= H3_EPHY_LED_POL;
-			else
-				reg &= ~H3_EPHY_LED_POL;
-
-			/* Force EPHY xtal frequency to 24MHz. */
-			reg |= H3_EPHY_CLK_SEL;
-
-			ret = of_mdio_parse_addr(priv->device,
-						 priv->plat->phy_node);
-			if (ret < 0) {
-				dev_err(priv->device, "Could not parse MDIO addr\n");
-				return ret;
-			}
-			/* of_mdio_parse_addr returns a valid (0 ~ 31) PHY
-			 * address. No need to mask it again.
-			 */
-			reg |= ret << H3_EPHY_ADDR_SHIFT;
+	if (gmac->variant->soc_has_internal_phy) {
+		if (of_property_read_bool(priv->plat->phy_node,
+					  "allwinner,leds-active-low"))
+			reg |= H3_EPHY_LED_POL;
+		else
+			reg &= ~H3_EPHY_LED_POL;
+
+		/* Force EPHY xtal frequency to 24MHz. */
+		reg |= H3_EPHY_CLK_SEL;
+
+		ret = of_mdio_parse_addr(priv->device, priv->plat->phy_node);
+		if (ret < 0) {
+			dev_err(priv->device, "Could not parse MDIO addr\n");
+			return ret;
 		}
+		/* of_mdio_parse_addr returns a valid (0 ~ 31) PHY
+		 * address. No need to mask it again.
+		 */
+		reg |= 1 << H3_EPHY_ADDR_SHIFT;
 	}
 
 	if (!of_property_read_u32(node, "allwinner,tx-delay-ps", &val)) {
@@ -746,81 +895,21 @@ static void sun8i_dwmac_unset_syscon(struct sunxi_priv_data *gmac)
 	regmap_write(gmac->regmap, SYSCON_EMAC_REG, reg);
 }
 
-static int sun8i_dwmac_power_internal_phy(struct stmmac_priv *priv)
+static void sun8i_dwmac_exit(struct platform_device *pdev, void *priv)
 {
-	struct sunxi_priv_data *gmac = priv->plat->bsp_priv;
-	int ret;
-
-	if (!gmac->use_internal_phy)
-		return 0;
-
-	ret = clk_prepare_enable(gmac->ephy_clk);
-	if (ret) {
-		dev_err(priv->device, "Cannot enable ephy\n");
-		return ret;
-	}
-
-	/* Make sure the EPHY is properly reseted, as U-Boot may leave
-	 * it at deasserted state, and thus it may fail to reset EMAC.
-	 */
-	reset_control_assert(gmac->rst_ephy);
+	struct sunxi_priv_data *gmac = priv;
 
-	ret = reset_control_deassert(gmac->rst_ephy);
-	if (ret) {
-		dev_err(priv->device, "Cannot deassert ephy\n");
-		clk_disable_unprepare(gmac->ephy_clk);
-		return ret;
+	if (gmac->variant->soc_has_internal_phy) {
+		/* sun8i_dwmac_exit could be called with mdiomux uninit */
+		if (gmac->mux_handle)
+			mdio_mux_uninit(gmac->mux_handle);
+		if (gmac->internal_phy_powered)
+			sun8i_dwmac_unpower_internal_phy(gmac);
 	}
 
-	return 0;
-}
-
-static int sun8i_dwmac_unpower_internal_phy(struct sunxi_priv_data *gmac)
-{
-	if (!gmac->use_internal_phy)
-		return 0;
-
-	clk_disable_unprepare(gmac->ephy_clk);
-	reset_control_assert(gmac->rst_ephy);
-	return 0;
-}
-
-/* sun8i_power_phy() - Activate the PHY:
- * In case of error, no need to call sun8i_unpower_phy(),
- * it will be called anyway by sun8i_dwmac_exit()
- */
-static int sun8i_power_phy(struct stmmac_priv *priv)
-{
-	int ret;
-
-	ret = sun8i_dwmac_power_internal_phy(priv);
-	if (ret)
-		return ret;
-
-	ret = sun8i_dwmac_set_syscon(priv);
-	if (ret)
-		return ret;
-
-	/* After changing syscon value, the MAC need reset or it will use
-	 * the last value (and so the last PHY set.
-	 */
-	ret = sun8i_dwmac_reset(priv);
-	if (ret)
-		return ret;
-	return 0;
-}
-
-static void sun8i_unpower_phy(struct sunxi_priv_data *gmac)
-{
 	sun8i_dwmac_unset_syscon(gmac);
-	sun8i_dwmac_unpower_internal_phy(gmac);
-}
-
-static void sun8i_dwmac_exit(struct platform_device *pdev, void *priv)
-{
-	struct sunxi_priv_data *gmac = priv;
 
-	sun8i_unpower_phy(gmac);
+	reset_control_put(gmac->rst_ephy);
 
 	clk_disable_unprepare(gmac->tx_clk);
 
@@ -849,7 +938,7 @@ static struct mac_device_info *sun8i_dwmac_setup(void *ppriv)
 	if (!mac)
 		return NULL;
 
-	ret = sun8i_power_phy(priv);
+	ret = sun8i_dwmac_set_syscon(priv);
 	if (ret)
 		return NULL;
 
@@ -889,6 +978,8 @@ static int sun8i_dwmac_probe(struct platform_device *pdev)
 	struct sunxi_priv_data *gmac;
 	struct device *dev = &pdev->dev;
 	int ret;
+	struct stmmac_priv *priv;
+	struct net_device *ndev;
 
 	ret = stmmac_get_platform_resources(pdev, &stmmac_res);
 	if (ret)
@@ -932,29 +1023,6 @@ static int sun8i_dwmac_probe(struct platform_device *pdev)
 	}
 
 	plat_dat->interface = of_get_phy_mode(dev->of_node);
-	if (plat_dat->interface == gmac->variant->internal_phy) {
-		dev_info(&pdev->dev, "Will use internal PHY\n");
-		gmac->use_internal_phy = true;
-		gmac->ephy_clk = of_clk_get(plat_dat->phy_node, 0);
-		if (IS_ERR(gmac->ephy_clk)) {
-			ret = PTR_ERR(gmac->ephy_clk);
-			dev_err(&pdev->dev, "Cannot get EPHY clock: %d\n", ret);
-			return -EINVAL;
-		}
-
-		gmac->rst_ephy = of_reset_control_get(plat_dat->phy_node, NULL);
-		if (IS_ERR(gmac->rst_ephy)) {
-			ret = PTR_ERR(gmac->rst_ephy);
-			if (ret == -EPROBE_DEFER)
-				return ret;
-			dev_err(&pdev->dev, "No EPHY reset control found %d\n",
-				ret);
-			return -EINVAL;
-		}
-	} else {
-		dev_info(&pdev->dev, "Will use external PHY\n");
-		gmac->use_internal_phy = false;
-	}
 
 	/* platform data specifying hardware features and callbacks.
 	 * hardware features were copied from Allwinner drivers.
@@ -973,9 +1041,34 @@ static int sun8i_dwmac_probe(struct platform_device *pdev)
 
 	ret = stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
 	if (ret)
-		sun8i_dwmac_exit(pdev, plat_dat->bsp_priv);
+		goto dwmac_exit;
+
+	ndev = dev_get_drvdata(&pdev->dev);
+	priv = netdev_priv(ndev);
+	/* The mux must be registered after parent MDIO
+	 * so after stmmac_dvr_probe()
+	 */
+	if (gmac->variant->soc_has_internal_phy) {
+		ret = get_ephy_nodes(priv);
+		if (ret)
+			return ret;
+		ret = sun8i_dwmac_register_mdio_mux(priv);
+		if (ret) {
+			dev_err(&pdev->dev, "Failed to register mux\n");
+			goto dwmac_mux;
+		}
+	} else {
+		ret = sun8i_dwmac_reset(priv);
+		if (ret)
+			goto dwmac_exit;
+	}
 
 	return ret;
+dwmac_mux:
+	sun8i_dwmac_unset_syscon(gmac);
+dwmac_exit:
+	sun8i_dwmac_exit(pdev, plat_dat->bsp_priv);
+return ret;
 }
 
 static const struct of_device_id sun8i_dwmac_match[] = {
-- 
2.13.6
