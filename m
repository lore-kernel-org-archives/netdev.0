From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 1/2] net: ethernet: apm: xgene: use phydev from struct net_device
Date: Sun, 11 Sep 2016 17:54:03 +0200
Message-ID: <1473609244-4365-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: isubramanian@apm.com, kchudgar@apm.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The private structure contain a pointer to phydev, but the structure
net_device already contain such pointer. So we can remove the pointer
phy_dev in the private structure, and update the driver to use the
one contained in struct net_device.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 .../net/ethernet/apm/xgene/xgene_enet_ethtool.c    |    4 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c     |   24 ++++++++++----------
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c   |    8 +++---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h   |    1 -
 4 files changed, 18 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c b/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c
index 22a7b26..e1f44ae 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c
@@ -57,7 +57,7 @@ static void xgene_get_drvinfo(struct net_device *ndev,
 static int xgene_get_settings(struct net_device *ndev, struct ethtool_cmd *cmd)
 {
 	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
-	struct phy_device *phydev = pdata->phy_dev;
+	struct phy_device *phydev = ndev->phydev;
 
 	if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII) {
 		if (phydev == NULL)
@@ -96,7 +96,7 @@ static int xgene_get_settings(struct net_device *ndev, struct ethtool_cmd *cmd)
 static int xgene_set_settings(struct net_device *ndev, struct ethtool_cmd *cmd)
 {
 	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
-	struct phy_device *phydev = pdata->phy_dev;
+	struct phy_device *phydev = ndev->phydev;
 
 	if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII) {
 		if (!phydev)
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
index da413c8..c481f10 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
@@ -713,7 +713,7 @@ static void xgene_enet_adjust_link(struct net_device *ndev)
 {
 	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
 	const struct xgene_mac_ops *mac_ops = pdata->mac_ops;
-	struct phy_device *phydev = pdata->phy_dev;
+	struct phy_device *phydev = ndev->phydev;
 
 	if (phydev->link) {
 		if (pdata->phy_speed != phydev->speed) {
@@ -773,15 +773,13 @@ int xgene_enet_phy_connect(struct net_device *ndev)
 			netdev_err(ndev, "Could not connect to PHY\n");
 			return -ENODEV;
 		}
-
-		pdata->phy_dev = phy_dev;
 	} else {
 #ifdef CONFIG_ACPI
 		struct acpi_device *adev = acpi_phy_find_device(dev);
 		if (adev)
-			pdata->phy_dev =  adev->driver_data;
-
-		phy_dev = pdata->phy_dev;
+			phy_dev = adev->driver_data;
+		else
+			phy_dev = NULL;
 
 		if (!phy_dev ||
 		    phy_connect_direct(ndev, phy_dev, &xgene_enet_adjust_link,
@@ -849,8 +847,6 @@ static int xgene_mdiobus_register(struct xgene_enet_pdata *pdata,
 	if (!phy)
 		return -EIO;
 
-	pdata->phy_dev = phy;
-
 	return ret;
 }
 
@@ -890,14 +886,18 @@ int xgene_enet_mdio_config(struct xgene_enet_pdata *pdata)
 
 void xgene_enet_phy_disconnect(struct xgene_enet_pdata *pdata)
 {
-	if (pdata->phy_dev)
-		phy_disconnect(pdata->phy_dev);
+	struct net_device *ndev = pdata->ndev;
+
+	if (ndev->phydev)
+		phy_disconnect(ndev->phydev);
 }
 
 void xgene_enet_mdio_remove(struct xgene_enet_pdata *pdata)
 {
-	if (pdata->phy_dev)
-		phy_disconnect(pdata->phy_dev);
+	struct net_device *ndev = pdata->ndev;
+
+	if (ndev->phydev)
+		phy_disconnect(ndev->phydev);
 
 	mdiobus_unregister(pdata->mdio_bus);
 	mdiobus_free(pdata->mdio_bus);
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index b8b9495..522ba92 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -748,8 +748,8 @@ static int xgene_enet_open(struct net_device *ndev)
 	if (ret)
 		return ret;
 
-	if (pdata->phy_dev) {
-		phy_start(pdata->phy_dev);
+	if (ndev->phydev) {
+		phy_start(ndev->phydev);
 	} else {
 		schedule_delayed_work(&pdata->link_work, PHY_POLL_LINK_OFF);
 		netif_carrier_off(ndev);
@@ -772,8 +772,8 @@ static int xgene_enet_close(struct net_device *ndev)
 	mac_ops->tx_disable(pdata);
 	mac_ops->rx_disable(pdata);
 
-	if (pdata->phy_dev)
-		phy_stop(pdata->phy_dev);
+	if (ndev->phydev)
+		phy_stop(ndev->phydev);
 	else
 		cancel_delayed_work_sync(&pdata->link_work);
 
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
index b339fc1..7735371 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
@@ -174,7 +174,6 @@ struct xgene_cle_ops {
 struct xgene_enet_pdata {
 	struct net_device *ndev;
 	struct mii_bus *mdio_bus;
-	struct phy_device *phy_dev;
 	int phy_speed;
 	struct clk *clk;
 	struct platform_device *pdev;
-- 
1.7.4.4
