From: Jon Mason <jon.mason-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: [PATCH v4 5/7] net: ethernet: bgmac: device tree phy enablement
Date: Tue,  1 Nov 2016 16:04:40 -0400
Message-ID: <1478030682-27012-6-git-send-email-jon.mason@broadcom.com>
References: <1478030682-27012-1-git-send-email-jon.mason@broadcom.com>
Cc: rafal-g1n6cQUeyibVItvQsEIGlw@public.gmane.org, bcm-kernel-feedback-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1478030682-27012-1-git-send-email-jon.mason-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Change the bgmac driver to allow for phy's defined by the device tree

Signed-off-by: Jon Mason <jon.mason-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
---
 drivers/net/ethernet/broadcom/bgmac-bcma.c     | 48 ++++++++++++++++++++++++
 drivers/net/ethernet/broadcom/bgmac-platform.c | 48 +++++++++++++++++++++++-
 drivers/net/ethernet/broadcom/bgmac.c          | 52 ++------------------------
 drivers/net/ethernet/broadcom/bgmac.h          |  7 ++++
 4 files changed, 105 insertions(+), 50 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac-bcma.c b/drivers/net/ethernet/broadcom/bgmac-bcma.c
index c16ec3a..3e3efde 100644
--- a/drivers/net/ethernet/broadcom/bgmac-bcma.c
+++ b/drivers/net/ethernet/broadcom/bgmac-bcma.c
@@ -80,6 +80,50 @@ static void bcma_bgmac_cmn_maskset32(struct bgmac *bgmac, u16 offset, u32 mask,
 	bcma_maskset32(bgmac->bcma.cmn, offset, mask, set);
 }
 
+static int bcma_phy_connect(struct bgmac *bgmac)
+{
+	struct phy_device *phy_dev;
+	char bus_id[MII_BUS_ID_SIZE + 3];
+
+	/* Connect to the PHY */
+	snprintf(bus_id, sizeof(bus_id), PHY_ID_FMT, bgmac->mii_bus->id,
+		 bgmac->phyaddr);
+	phy_dev = phy_connect(bgmac->net_dev, bus_id, bgmac_adjust_link,
+			      PHY_INTERFACE_MODE_MII);
+	if (IS_ERR(phy_dev)) {
+		dev_err(bgmac->dev, "PHY connecton failed\n");
+		return PTR_ERR(phy_dev);
+	}
+
+	return 0;
+}
+
+static int bcma_phy_direct_connect(struct bgmac *bgmac)
+{
+	struct fixed_phy_status fphy_status = {
+		.link = 1,
+		.speed = SPEED_1000,
+		.duplex = DUPLEX_FULL,
+	};
+	struct phy_device *phy_dev;
+	int err;
+
+	phy_dev = fixed_phy_register(PHY_POLL, &fphy_status, -1, NULL);
+	if (!phy_dev || IS_ERR(phy_dev)) {
+		dev_err(bgmac->dev, "Failed to register fixed PHY device\n");
+		return -ENODEV;
+	}
+
+	err = phy_connect_direct(bgmac->net_dev, phy_dev, bgmac_adjust_link,
+				 PHY_INTERFACE_MODE_MII);
+	if (err) {
+		dev_err(bgmac->dev, "Connecting PHY failed\n");
+		return err;
+	}
+
+	return err;
+}
+
 static const struct bcma_device_id bgmac_bcma_tbl[] = {
 	BCMA_CORE(BCMA_MANUF_BCM, BCMA_CORE_4706_MAC_GBIT,
 		  BCMA_ANY_REV, BCMA_ANY_CLASS),
@@ -275,6 +319,10 @@ static int bgmac_probe(struct bcma_device *core)
 	bgmac->cco_ctl_maskset = bcma_bgmac_cco_ctl_maskset;
 	bgmac->get_bus_clock = bcma_bgmac_get_bus_clock;
 	bgmac->cmn_maskset32 = bcma_bgmac_cmn_maskset32;
+	if (bgmac->mii_bus)
+		bgmac->phy_connect = bcma_phy_connect;
+	else
+		bgmac->phy_connect = bcma_phy_direct_connect;
 
 	err = bgmac_enet_probe(bgmac);
 	if (err)
diff --git a/drivers/net/ethernet/broadcom/bgmac-platform.c b/drivers/net/ethernet/broadcom/bgmac-platform.c
index be52f27..aed5dc5 100644
--- a/drivers/net/ethernet/broadcom/bgmac-platform.c
+++ b/drivers/net/ethernet/broadcom/bgmac-platform.c
@@ -16,6 +16,7 @@
 #include <linux/bcma/bcma.h>
 #include <linux/etherdevice.h>
 #include <linux/of_address.h>
+#include <linux/of_mdio.h>
 #include <linux/of_net.h>
 #include "bgmac.h"
 
@@ -86,6 +87,46 @@ static void platform_bgmac_cmn_maskset32(struct bgmac *bgmac, u16 offset,
 	WARN_ON(1);
 }
 
+static int platform_phy_connect(struct bgmac *bgmac)
+{
+	struct phy_device *phy_dev;
+
+	phy_dev = of_phy_get_and_connect(bgmac->net_dev, bgmac->dev->of_node,
+					 bgmac_adjust_link);
+	if (!phy_dev) {
+		dev_err(bgmac->dev, "Phy connect failed\n");
+		return -ENODEV;
+	}
+
+	return 0;
+}
+
+static int platform_phy_direct_connect(struct bgmac *bgmac)
+{
+	struct fixed_phy_status fphy_status = {
+		.link = 1,
+		.speed = SPEED_1000,
+		.duplex = DUPLEX_FULL,
+	};
+	struct phy_device *phy_dev;
+	int err;
+
+	phy_dev = fixed_phy_register(PHY_POLL, &fphy_status, -1, NULL);
+	if (!phy_dev || IS_ERR(phy_dev)) {
+		dev_err(bgmac->dev, "Failed to register fixed PHY device\n");
+		return -ENODEV;
+	}
+
+	err = phy_connect_direct(bgmac->net_dev, phy_dev, bgmac_adjust_link,
+				 PHY_INTERFACE_MODE_MII);
+	if (err) {
+		dev_err(bgmac->dev, "Connecting PHY failed\n");
+		return err;
+	}
+
+	return err;
+}
+
 static int bgmac_probe(struct platform_device *pdev)
 {
 	struct device_node *np = pdev->dev.of_node;
@@ -102,7 +143,6 @@ static int bgmac_probe(struct platform_device *pdev)
 	/* Set the features of the 4707 family */
 	bgmac->feature_flags |= BGMAC_FEAT_CLKCTLST;
 	bgmac->feature_flags |= BGMAC_FEAT_NO_RESET;
-	bgmac->feature_flags |= BGMAC_FEAT_FORCE_SPEED_2500;
 	bgmac->feature_flags |= BGMAC_FEAT_CMDCFG_SR_REV4;
 	bgmac->feature_flags |= BGMAC_FEAT_TX_MASK_SETUP;
 	bgmac->feature_flags |= BGMAC_FEAT_RX_MASK_SETUP;
@@ -151,6 +191,12 @@ static int bgmac_probe(struct platform_device *pdev)
 	bgmac->cco_ctl_maskset = platform_bgmac_cco_ctl_maskset;
 	bgmac->get_bus_clock = platform_bgmac_get_bus_clock;
 	bgmac->cmn_maskset32 = platform_bgmac_cmn_maskset32;
+	if (of_parse_phandle(np, "phy-handle", 0)) {
+		bgmac->phy_connect = platform_phy_connect;
+	} else {
+		bgmac->phy_connect = platform_phy_direct_connect;
+		bgmac->feature_flags |= BGMAC_FEAT_FORCE_SPEED_2500;
+	}
 
 	return bgmac_enet_probe(bgmac);
 }
diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index 856379c..4584958 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -1388,7 +1388,7 @@ static const struct ethtool_ops bgmac_ethtool_ops = {
  * MII
  **************************************************/
 
-static void bgmac_adjust_link(struct net_device *net_dev)
+void bgmac_adjust_link(struct net_device *net_dev)
 {
 	struct bgmac *bgmac = netdev_priv(net_dev);
 	struct phy_device *phy_dev = net_dev->phydev;
@@ -1411,50 +1411,7 @@ static void bgmac_adjust_link(struct net_device *net_dev)
 		phy_print_status(phy_dev);
 	}
 }
-
-static int bgmac_phy_connect_direct(struct bgmac *bgmac)
-{
-	struct fixed_phy_status fphy_status = {
-		.link = 1,
-		.speed = SPEED_1000,
-		.duplex = DUPLEX_FULL,
-	};
-	struct phy_device *phy_dev;
-	int err;
-
-	phy_dev = fixed_phy_register(PHY_POLL, &fphy_status, -1, NULL);
-	if (!phy_dev || IS_ERR(phy_dev)) {
-		dev_err(bgmac->dev, "Failed to register fixed PHY device\n");
-		return -ENODEV;
-	}
-
-	err = phy_connect_direct(bgmac->net_dev, phy_dev, bgmac_adjust_link,
-				 PHY_INTERFACE_MODE_MII);
-	if (err) {
-		dev_err(bgmac->dev, "Connecting PHY failed\n");
-		return err;
-	}
-
-	return err;
-}
-
-static int bgmac_phy_connect(struct bgmac *bgmac)
-{
-	struct phy_device *phy_dev;
-	char bus_id[MII_BUS_ID_SIZE + 3];
-
-	/* Connect to the PHY */
-	snprintf(bus_id, sizeof(bus_id), PHY_ID_FMT, bgmac->mii_bus->id,
-		 bgmac->phyaddr);
-	phy_dev = phy_connect(bgmac->net_dev, bus_id, &bgmac_adjust_link,
-			      PHY_INTERFACE_MODE_MII);
-	if (IS_ERR(phy_dev)) {
-		dev_err(bgmac->dev, "PHY connecton failed\n");
-		return PTR_ERR(phy_dev);
-	}
-
-	return 0;
-}
+EXPORT_SYMBOL_GPL(bgmac_adjust_link);
 
 int bgmac_enet_probe(struct bgmac *info)
 {
@@ -1507,10 +1464,7 @@ int bgmac_enet_probe(struct bgmac *info)
 
 	netif_napi_add(net_dev, &bgmac->napi, bgmac_poll, BGMAC_WEIGHT);
 
-	if (!bgmac->mii_bus)
-		err = bgmac_phy_connect_direct(bgmac);
-	else
-		err = bgmac_phy_connect(bgmac);
+	err = bgmac_phy_connect(bgmac);
 	if (err) {
 		dev_err(bgmac->dev, "Cannot connect to phy\n");
 		goto err_dma_free;
diff --git a/drivers/net/ethernet/broadcom/bgmac.h b/drivers/net/ethernet/broadcom/bgmac.h
index 80836b4..ea52ac3 100644
--- a/drivers/net/ethernet/broadcom/bgmac.h
+++ b/drivers/net/ethernet/broadcom/bgmac.h
@@ -513,10 +513,12 @@ struct bgmac {
 	u32 (*get_bus_clock)(struct bgmac *bgmac);
 	void (*cmn_maskset32)(struct bgmac *bgmac, u16 offset, u32 mask,
 			      u32 set);
+	int (*phy_connect)(struct bgmac *bgmac);
 };
 
 int bgmac_enet_probe(struct bgmac *info);
 void bgmac_enet_remove(struct bgmac *bgmac);
+void bgmac_adjust_link(struct net_device *net_dev);
 
 struct mii_bus *bcma_mdio_mii_register(struct bcma_device *core, u8 phyaddr);
 void bcma_mdio_mii_unregister(struct mii_bus *mii_bus);
@@ -583,4 +585,9 @@ static inline void bgmac_set(struct bgmac *bgmac, u16 offset, u32 set)
 {
 	bgmac_maskset(bgmac, offset, ~0, set);
 }
+
+static inline int bgmac_phy_connect(struct bgmac *bgmac)
+{
+	return bgmac->phy_connect(bgmac);
+}
 #endif /* _BGMAC_H */
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
