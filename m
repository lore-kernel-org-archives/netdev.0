From: Mathieu Olivari <mathieu-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: [PATCH V2 2/5] stmmac: add phy-handle support to the platform layer
Date: Wed, 27 May 2015 11:02:47 -0700
Message-ID: <1432749770-26133-3-git-send-email-mathieu@codeaurora.org>
References: <1432749770-26133-1-git-send-email-mathieu@codeaurora.org>
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, pawel.moll-5wv7dgnIgG8@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org, galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	mturquette-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, sboyd-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	peppe.cavallaro-qxv4g6HH51o@public.gmane.org, mathieu-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	agross-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, joshc-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	architt-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, georgi.djakov-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org,
	wsa-z923LK4zBo2bacvFa/9K2g@public.gmane.org, rnayak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	vbridger-yzvPICuk2ABMcg4IHK0kFoH6Mc4MB0Vx@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1432749770-26133-1-git-send-email-mathieu-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On stmmac driver, PHY specification in device-tree was done using the
non-standard property "snps,phy-addr". Specifying a PHY on a different
MDIO bus that the one within the stmmac controller doesn't seem to be
possible when device-tree is used.

This change adds support for the phy-handle property, as specified in
Documentation/devicetree/bindings/net/ethernet.txt.

Signed-off-by: Mathieu Olivari <mathieu-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 28 ++++++++++++++--------
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |  6 ++++-
 include/linux/stmmac.h                             |  1 +
 3 files changed, 24 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index e4f2739..31c6416 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -52,6 +52,7 @@
 #include "stmmac_ptp.h"
 #include "stmmac.h"
 #include <linux/reset.h>
+#include <linux/of_mdio.h>
 
 #define STMMAC_ALIGN(x)	L1_CACHE_ALIGN(x)
 
@@ -816,18 +817,25 @@ static int stmmac_init_phy(struct net_device *dev)
 	priv->speed = 0;
 	priv->oldduplex = -1;
 
-	if (priv->plat->phy_bus_name)
-		snprintf(bus_id, MII_BUS_ID_SIZE, "%s-%x",
-			 priv->plat->phy_bus_name, priv->plat->bus_id);
-	else
-		snprintf(bus_id, MII_BUS_ID_SIZE, "stmmac-%x",
-			 priv->plat->bus_id);
+	if (priv->plat->phy_node) {
+		phydev = of_phy_connect(dev, priv->plat->phy_node,
+					&stmmac_adjust_link, 0, interface);
+	} else {
+		if (priv->plat->phy_bus_name)
+			snprintf(bus_id, MII_BUS_ID_SIZE, "%s-%x",
+				 priv->plat->phy_bus_name, priv->plat->bus_id);
+		else
+			snprintf(bus_id, MII_BUS_ID_SIZE, "stmmac-%x",
+				 priv->plat->bus_id);
 
-	snprintf(phy_id_fmt, MII_BUS_ID_SIZE + 3, PHY_ID_FMT, bus_id,
-		 priv->plat->phy_addr);
-	pr_debug("stmmac_init_phy:  trying to attach to %s\n", phy_id_fmt);
+		snprintf(phy_id_fmt, MII_BUS_ID_SIZE + 3, PHY_ID_FMT, bus_id,
+			 priv->plat->phy_addr);
+		pr_debug("stmmac_init_phy:  trying to attach to %s\n",
+			 phy_id_fmt);
 
-	phydev = phy_connect(dev, phy_id_fmt, &stmmac_adjust_link, interface);
+		phydev = phy_connect(dev, phy_id_fmt, &stmmac_adjust_link,
+				     interface);
+	}
 
 	if (IS_ERR(phydev)) {
 		pr_err("%s: Could not attach to PHY\n", dev->name);
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 1664c01..8d23155 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -28,6 +28,7 @@
 #include <linux/of.h>
 #include <linux/of_net.h>
 #include <linux/of_device.h>
+#include <linux/of_mdio.h>
 
 #include "stmmac.h"
 #include "stmmac_platform.h"
@@ -144,13 +145,16 @@ static int stmmac_probe_config_dt(struct platform_device *pdev,
 	/* Default to phy auto-detection */
 	plat->phy_addr = -1;
 
+	/* If we find a phy-handle property, use it as the PHY */
+	plat->phy_node = of_parse_phandle(np, "phy-handle", 0);
+
 	/* "snps,phy-addr" is not a standard property. Mark it as deprecated
 	 * and warn of its use. Remove this when phy node support is added.
 	 */
 	if (of_property_read_u32(np, "snps,phy-addr", &plat->phy_addr) == 0)
 		dev_warn(&pdev->dev, "snps,phy-addr property is deprecated\n");
 
-	if (plat->phy_bus_name)
+	if (plat->phy_node || plat->phy_bus_name)
 		plat->mdio_bus_data = NULL;
 	else
 		plat->mdio_bus_data =
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index 7f484a2..c735f5c 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -99,6 +99,7 @@ struct plat_stmmacenet_data {
 	int phy_addr;
 	int interface;
 	struct stmmac_mdio_bus_data *mdio_bus_data;
+	struct device_node *phy_node;
 	struct stmmac_dma_cfg *dma_cfg;
 	int clk_csr;
 	int has_gmac;
-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
