From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 1/2] net: ethernet: altera_tse: use phydev from struct net_device
Date: Sat, 18 Jun 2016 16:37:20 +0200
Message-ID: <1466260641-22506-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, nios2-dev@lists.rocketboards.org,
	linux-kernel@vger.kernel.org, Philippe Reynes <tremyfr@gmail.com>
To: vbridger@opensource.altera.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The private structure contain a pointer to phydev, but the structure
net_device already contain such pointer. So we can remove the pointer
phydev in the private structure, and update the driver to use the
one contained in struct net_device.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/altera/altera_tse.h         |    1 -
 drivers/net/ethernet/altera/altera_tse_ethtool.c |    6 ++----
 drivers/net/ethernet/altera/altera_tse_main.c    |   16 +++++++---------
 3 files changed, 9 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/altera/altera_tse.h b/drivers/net/ethernet/altera/altera_tse.h
index 103c30d..e005200 100644
--- a/drivers/net/ethernet/altera/altera_tse.h
+++ b/drivers/net/ethernet/altera/altera_tse.h
@@ -473,7 +473,6 @@ struct altera_tse_private {
 	int phy_addr;		/* PHY's MDIO address, -1 for autodetection */
 	phy_interface_t phy_iface;
 	struct mii_bus *mdio;
-	struct phy_device *phydev;
 	int oldspeed;
 	int oldduplex;
 	int oldlink;
diff --git a/drivers/net/ethernet/altera/altera_tse_ethtool.c b/drivers/net/ethernet/altera/altera_tse_ethtool.c
index be72e1e..c1b5608 100644
--- a/drivers/net/ethernet/altera/altera_tse_ethtool.c
+++ b/drivers/net/ethernet/altera/altera_tse_ethtool.c
@@ -235,8 +235,7 @@ static void tse_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 
 static int tse_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct altera_tse_private *priv = netdev_priv(dev);
-	struct phy_device *phydev = priv->phydev;
+	struct phy_device *phydev = dev->phydev;
 
 	if (phydev == NULL)
 		return -ENODEV;
@@ -246,8 +245,7 @@ static int tse_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 static int tse_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct altera_tse_private *priv = netdev_priv(dev);
-	struct phy_device *phydev = priv->phydev;
+	struct phy_device *phydev = dev->phydev;
 
 	if (phydev == NULL)
 		return -ENODEV;
diff --git a/drivers/net/ethernet/altera/altera_tse_main.c b/drivers/net/ethernet/altera/altera_tse_main.c
index f749e4d..49025e9 100644
--- a/drivers/net/ethernet/altera/altera_tse_main.c
+++ b/drivers/net/ethernet/altera/altera_tse_main.c
@@ -625,7 +625,7 @@ out:
 static void altera_tse_adjust_link(struct net_device *dev)
 {
 	struct altera_tse_private *priv = netdev_priv(dev);
-	struct phy_device *phydev = priv->phydev;
+	struct phy_device *phydev = dev->phydev;
 	int new_state = 0;
 
 	/* only change config if there is a link */
@@ -845,7 +845,6 @@ static int init_phy(struct net_device *dev)
 	netdev_dbg(dev, "attached to PHY %d UID 0x%08x Link = %d\n",
 		   phydev->mdio.addr, phydev->phy_id, phydev->link);
 
-	priv->phydev = phydev;
 	return 0;
 }
 
@@ -1172,8 +1171,8 @@ static int tse_open(struct net_device *dev)
 
 	spin_unlock_irqrestore(&priv->rxdma_irq_lock, flags);
 
-	if (priv->phydev)
-		phy_start(priv->phydev);
+	if (dev->phydev)
+		phy_start(dev->phydev);
 
 	napi_enable(&priv->napi);
 	netif_start_queue(dev);
@@ -1205,8 +1204,8 @@ static int tse_shutdown(struct net_device *dev)
 	unsigned long int flags;
 
 	/* Stop the PHY */
-	if (priv->phydev)
-		phy_stop(priv->phydev);
+	if (dev->phydev)
+		phy_stop(dev->phydev);
 
 	netif_stop_queue(dev);
 	napi_disable(&priv->napi);
@@ -1545,10 +1544,9 @@ err_free_netdev:
 static int altera_tse_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
-	struct altera_tse_private *priv = netdev_priv(ndev);
 
-	if (priv->phydev)
-		phy_disconnect(priv->phydev);
+	if (ndev->phydev)
+		phy_disconnect(ndev->phydev);
 
 	platform_set_drvdata(pdev, NULL);
 	altera_tse_mdio_destroy(ndev);
-- 
1.7.4.4
