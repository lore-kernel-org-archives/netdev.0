From: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v6 10/11] net: stmmac: dwmac-sun8i: Handle
 integrated/external MDIOs
Date: Wed, 27 Sep 2017 09:34:13 +0200
Message-ID: <20170927073414.17361-11-clabbe.montjoie@gmail.com>
References: <20170927073414.17361-1-clabbe.montjoie@gmail.com>
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
Return-path: <linux-sunxi+bncBD7YLCN32UNBBDNKVXHAKGQELXSKHXY-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <20170927073414.17361-1-clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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
 drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c | 116 +++++++++++++++++++---
 2 files changed, 104 insertions(+), 13 deletions(-)

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
index 672553b652bd..8bd500c351b4 100644
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
@@ -71,6 +72,7 @@ struct sunxi_priv_data {
 	const struct emac_variant *variant;
 	struct regmap *regmap;
 	bool use_internal_phy;
+	void *mux_handle;
 };
 
 static const struct emac_variant emac_variant_h3 = {
@@ -195,6 +197,9 @@ static const struct emac_variant emac_variant_a64 = {
 #define H3_EPHY_LED_POL		BIT(17) /* 1: active low, 0: active high */
 #define H3_EPHY_SHUTDOWN	BIT(16) /* 1: shutdown, 0: power up */
 #define H3_EPHY_SELECT		BIT(15) /* 1: internal PHY, 0: external PHY */
+#define H3_EPHY_MUX_MASK	(H3_EPHY_SHUTDOWN | H3_EPHY_SELECT)
+#define DWMAC_SUN8I_MDIO_MUX_INTERNAL_ID	1
+#define DWMAC_SUN8I_MDIO_MUX_EXTERNAL_ID	2
 
 /* H3/A64 specific bits */
 #define SYSCON_RMII_EN		BIT(13) /* 1: enable RMII (overrides EPIT) */
@@ -634,6 +639,76 @@ static int sun8i_dwmac_reset(struct stmmac_priv *priv)
 	return 0;
 }
 
+/* MDIO multiplexing switch function
+ * This function is called by the mdio-mux layer when it thinks the mdio bus
+ * multiplexer needs to switch.
+ * 'current_child' is the current value of the mux register
+ * 'desired_child' is the value of the 'reg' property of the target child MDIO
+ * node.
+ * The first time this function is called, current_child == -1.
+ * If current_child == desired_child, then the mux is already set to the
+ * correct bus.
+ *
+ * Note that we do not use reg/mask like mdio-mux-mmioreg because we need to
+ * know easily which bus is used (reset must be done only for desired bus).
+ */
+static int mdio_mux_syscon_switch_fn(int current_child, int desired_child,
+				     void *data)
+{
+	struct stmmac_priv *priv = data;
+	struct sunxi_priv_data *gmac = priv->plat->bsp_priv;
+	u32 reg, val;
+	int ret = 0;
+	bool need_reset = false;
+
+	if (current_child ^ desired_child) {
+		regmap_read(gmac->regmap, SYSCON_EMAC_REG, &reg);
+		switch (desired_child) {
+		case DWMAC_SUN8I_MDIO_MUX_INTERNAL_ID:
+			dev_info(priv->device, "Switch mux to internal PHY");
+			val = (reg & ~H3_EPHY_MUX_MASK) | H3_EPHY_SELECT;
+			if (gmac->use_internal_phy)
+				need_reset = true;
+			break;
+		case DWMAC_SUN8I_MDIO_MUX_EXTERNAL_ID:
+			dev_info(priv->device, "Switch mux to external PHY");
+			val = (reg & ~H3_EPHY_MUX_MASK) | H3_EPHY_SHUTDOWN;
+			if (!gmac->use_internal_phy)
+				need_reset = true;
+			break;
+		default:
+			dev_err(priv->device, "Invalid child id %x\n", desired_child);
+			return -EINVAL;
+		}
+		regmap_write(gmac->regmap, SYSCON_EMAC_REG, val);
+		/* After changing syscon value, the MAC need reset or it will use
+		 * the last value (and so the last PHY set).
+		 * Reset is necessary only when we reach the needed MDIO,
+		 * it timeout in other case.
+		 */
+		if (need_reset)
+			ret = sun8i_dwmac_reset(priv);
+		else
+			dev_dbg(priv->device, "skipped reset\n");
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
@@ -649,12 +724,7 @@ static int sun8i_dwmac_set_syscon(struct stmmac_priv *priv)
 			 val, reg);
 
 	if (gmac->variant->soc_has_internal_phy) {
-		if (!gmac->use_internal_phy) {
-			/* switch to external PHY interface */
-			reg &= ~H3_EPHY_SELECT;
-		} else {
-			reg |= H3_EPHY_SELECT;
-			reg &= ~H3_EPHY_SHUTDOWN;
+		if (gmac->use_internal_phy) {
 			dev_dbg(priv->device, "Select internal_phy %x\n", reg);
 
 			if (of_property_read_bool(priv->plat->phy_node,
@@ -743,6 +813,8 @@ static void sun8i_dwmac_unset_syscon(struct sunxi_priv_data *gmac)
 {
 	u32 reg = gmac->variant->default_syscon_value;
 
+	if (gmac->variant->soc_has_internal_phy && gmac->mux_handle)
+		mdio_mux_uninit(gmac->mux_handle);
 	regmap_write(gmac->regmap, SYSCON_EMAC_REG, reg);
 }
 
@@ -801,12 +873,6 @@ static int sun8i_power_phy(struct stmmac_priv *priv)
 	if (ret)
 		return ret;
 
-	/* After changing syscon value, the MAC need reset or it will use
-	 * the last value (and so the last PHY set.
-	 */
-	ret = sun8i_dwmac_reset(priv);
-	if (ret)
-		return ret;
 	return 0;
 }
 
@@ -889,6 +955,8 @@ static int sun8i_dwmac_probe(struct platform_device *pdev)
 	struct sunxi_priv_data *gmac;
 	struct device *dev = &pdev->dev;
 	int ret;
+	struct stmmac_priv *priv;
+	struct net_device *ndev;
 
 	ret = stmmac_get_platform_resources(pdev, &stmmac_res);
 	if (ret)
@@ -973,9 +1041,31 @@ static int sun8i_dwmac_probe(struct platform_device *pdev)
 
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
2.13.5
