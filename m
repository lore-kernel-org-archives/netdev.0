From: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 3/3] net-next: stmmac: dwmac-sun8i: choose
 internal PHY via compatible
Date: Fri, 28 Jul 2017 11:28:18 +0200
Message-ID: <20170728092818.23419-4-clabbe.montjoie@gmail.com>
References: <20170728092818.23419-1-clabbe.montjoie@gmail.com>
Reply-To: clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: icenowy-h8G6r0blFSE@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
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
	peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
	alexandre.torgue-qxv4g6HH51o@public.gmane.org
Return-path: <linux-sunxi+bncBD7YLCN32UNBBUMI5TFQKGQENL4PG5Y-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <20170728092818.23419-1-clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

The current way to find if the phy is internal is to compare DT phy-mode
and emac_variant/internal_phy.
But it will negate a possible future SoC where an external PHY use the
same phy mode than the internal one.

This patch adds a new way to find if the PHY is internal, via its
compatible.

Since the phy_mode of the internal PHY does need to be know, the
variant internal_phy member is converted to a boolean.

Signed-off-by: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c | 16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c
index fffd6d5fc907..04f7ddd802b0 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c
@@ -48,7 +48,7 @@
  */
 struct emac_variant {
 	u32 default_syscon_value;
-	int internal_phy;
+	bool internal_phy;
 	bool support_mii;
 	bool support_rmii;
 	bool support_rgmii;
@@ -75,7 +75,7 @@ struct sunxi_priv_data {
 
 static const struct emac_variant emac_variant_h3 = {
 	.default_syscon_value = 0x58000,
-	.internal_phy = PHY_INTERFACE_MODE_MII,
+	.internal_phy = true,
 	.support_mii = true,
 	.support_rmii = true,
 	.support_rgmii = true
@@ -83,20 +83,20 @@ static const struct emac_variant emac_variant_h3 = {
 
 static const struct emac_variant emac_variant_v3s = {
 	.default_syscon_value = 0x38000,
-	.internal_phy = PHY_INTERFACE_MODE_MII,
+	.internal_phy = true,
 	.support_mii = true
 };
 
 static const struct emac_variant emac_variant_a83t = {
 	.default_syscon_value = 0,
-	.internal_phy = 0,
+	.internal_phy = false,
 	.support_mii = true,
 	.support_rgmii = true
 };
 
 static const struct emac_variant emac_variant_a64 = {
 	.default_syscon_value = 0,
-	.internal_phy = 0,
+	.internal_phy = false,
 	.support_mii = true,
 	.support_rmii = true,
 	.support_rgmii = true
@@ -889,6 +889,10 @@ static int sun8i_dwmac_probe(struct platform_device *pdev)
 	struct sunxi_priv_data *gmac;
 	struct device *dev = &pdev->dev;
 	int ret;
+	static const struct of_device_id internal_phys[] = {
+		{ .compatible = "allwinner,sun8i-h3-ephy" },
+		{ .compatible = "allwinner,sun8i-v3s-ephy" },
+	};
 
 	ret = stmmac_get_platform_resources(pdev, &stmmac_res);
 	if (ret)
@@ -932,7 +936,7 @@ static int sun8i_dwmac_probe(struct platform_device *pdev)
 	}
 
 	plat_dat->interface = of_get_phy_mode(dev->of_node);
-	if (plat_dat->interface == gmac->variant->internal_phy) {
+	if (of_match_node(internal_phys, plat_dat->phy_node)) {
 		dev_info(&pdev->dev, "Will use internal PHY\n");
 		gmac->use_internal_phy = true;
 		gmac->ephy_clk = of_clk_get(plat_dat->phy_node, 0);
-- 
2.13.0
