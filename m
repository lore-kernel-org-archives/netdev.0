From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v4 5/5] net: stmmac: Register parent MDIO in case of fake mdio-mux
Date: Sat, 26 Aug 2017 09:33:11 +0200
Message-ID: <20170826073311.25612-6-clabbe.montjoie@gmail.com>
References: <20170826073311.25612-1-clabbe.montjoie@gmail.com>
Cc: icenowy@aosc.io, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: robh+dt@kernel.org, mark.rutland@arm.com,
        maxime.ripard@free-electrons.com, wens@csie.org,
        linux@armlinux.org.uk, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, andrew@lunn.ch, f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170826073311.25612-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In case of a fake MDIO switch/mux (like Allwinner H3),
the registered MDIO node should be the parent of the PHY.
Otherwise of_phy_connect will fail.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index e1be5735365b..4d5f3cc82476 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -312,10 +312,12 @@ static int stmmac_dt_phy(struct plat_stmmacenet_data *plat,
 	static const struct of_device_id need_mdio_ids[] = {
 		{ .compatible = "snps,dwc-qos-ethernet-4.10" },
 		{ .compatible = "allwinner,sun8i-a83t-emac" },
-		{ .compatible = "allwinner,sun8i-h3-emac" },
 		{ .compatible = "allwinner,sun8i-v3s-emac" },
 		{ .compatible = "allwinner,sun50i-a64-emac" },
 	};
+	static const struct of_device_id register_parent_mdio_ids[] = {
+		{ .compatible = "allwinner,sun8i-h3-emac" },
+	};
 
 	/* If phy-handle property is passed from DT, use it as the PHY */
 	plat->phy_node = of_parse_phandle(np, "phy-handle", 0);
@@ -332,7 +334,14 @@ static int stmmac_dt_phy(struct plat_stmmacenet_data *plat,
 		mdio = false;
 	}
 
-	if (of_match_node(need_mdio_ids, np) && !of_phy_is_fixed_link(np)) {
+	/*
+	 * In case of a fake MDIO switch/mux (like Allwinner H3),
+	 * the registered MDIO node should be the parent of the PHY.
+	 * Otherwise of_phy_connect will fail.
+	 */
+	if (of_match_node(register_parent_mdio_ids, np) && !of_phy_is_fixed_link(np)) {
+		plat->mdio_node =  of_get_parent(plat->phy_node);
+	} else if (of_match_node(need_mdio_ids, np) && !of_phy_is_fixed_link(np)) {
 		plat->mdio_node = of_get_child_by_name(np, "mdio");
 	} else {
 		/**
-- 
2.13.5
