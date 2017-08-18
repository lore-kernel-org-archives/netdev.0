From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v3 2/4] net: stmmac: dwmac-sun8i: choose internal PHY via phy-is-integrated
Date: Fri, 18 Aug 2017 14:21:16 +0200
Message-ID: <20170818122118.4925-3-clabbe.montjoie@gmail.com>
References: <20170818122118.4925-1-clabbe.montjoie@gmail.com>
Cc: devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: robh+dt@kernel.org, mark.rutland@arm.com, linux@armlinux.org.uk,
        maxime.ripard@free-electrons.com, wens@csie.org,
        peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170818122118.4925-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The current way to find if the phy is internal is to compare DT phy-mode
and emac_variant/internal_phy.
But it will negate a possible future SoC where an external PHY use the
same phy mode than the internal one.

This patch adds a new way to find if the PHY is internal, via
the phy-is-integrated property.

Since the internal_phy variable does not need anymore to contain the xMII mode
used by the internal PHY, it is still used for knowing the presence of an
internal PHY, so it is modified to a boolean soc_has_internal_phy.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c
index fffd6d5fc907..672553b652bd 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c
@@ -41,14 +41,14 @@
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
@@ -75,7 +75,7 @@ struct sunxi_priv_data {
 
 static const struct emac_variant emac_variant_h3 = {
 	.default_syscon_value = 0x58000,
-	.internal_phy = PHY_INTERFACE_MODE_MII,
+	.soc_has_internal_phy = true,
 	.support_mii = true,
 	.support_rmii = true,
 	.support_rgmii = true
@@ -83,20 +83,20 @@ static const struct emac_variant emac_variant_h3 = {
 
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
@@ -648,7 +648,7 @@ static int sun8i_dwmac_set_syscon(struct stmmac_priv *priv)
 			 "Current syscon value is not the default %x (expect %x)\n",
 			 val, reg);
 
-	if (gmac->variant->internal_phy) {
+	if (gmac->variant->soc_has_internal_phy) {
 		if (!gmac->use_internal_phy) {
 			/* switch to external PHY interface */
 			reg &= ~H3_EPHY_SELECT;
@@ -932,7 +932,7 @@ static int sun8i_dwmac_probe(struct platform_device *pdev)
 	}
 
 	plat_dat->interface = of_get_phy_mode(dev->of_node);
-	if (plat_dat->interface == gmac->variant->internal_phy) {
+	if (of_property_read_bool(plat_dat->phy_node, "phy-is-integrated")) {
 		dev_info(&pdev->dev, "Will use internal PHY\n");
 		gmac->use_internal_phy = true;
 		gmac->ephy_clk = of_clk_get(plat_dat->phy_node, 0);
-- 
2.13.0
