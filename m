From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 1/2] net: ethernet: sun4i-emac: use phydev from struct net_device
Date: Sat, 18 Jun 2016 15:15:39 +0200
Message-ID: <1466255740-20999-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, Philippe Reynes <tremyfr@gmail.com>
To: maxime.ripard@free-electrons.com, wens@csie.org,
	davem@davemloft.net, hdegoede@redhat.com, mugunthanvnm@ti.com,
	a@unstable.cc, fw@strlen.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The private structure contain a pointer to phydev, but the structure
net_device already contain such pointer. So we can remove the pointer
phydev in the private structure, and update the driver to use the
one contained in struct net_device.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/allwinner/sun4i-emac.c |   34 +++++++++++---------------
 1 files changed, 14 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/allwinner/sun4i-emac.c b/drivers/net/ethernet/allwinner/sun4i-emac.c
index de2c4bf..6e31cb6 100644
--- a/drivers/net/ethernet/allwinner/sun4i-emac.c
+++ b/drivers/net/ethernet/allwinner/sun4i-emac.c
@@ -77,7 +77,6 @@ struct emac_board_info {
 
 	int			emacrx_completed_flag;
 
-	struct phy_device	*phy_dev;
 	struct device_node	*phy_node;
 	unsigned int		link;
 	unsigned int		speed;
@@ -115,7 +114,7 @@ static void emac_update_duplex(struct net_device *dev)
 static void emac_handle_link_change(struct net_device *dev)
 {
 	struct emac_board_info *db = netdev_priv(dev);
-	struct phy_device *phydev = db->phy_dev;
+	struct phy_device *phydev = dev->phydev;
 	unsigned long flags;
 	int status_change = 0;
 
@@ -154,21 +153,22 @@ static void emac_handle_link_change(struct net_device *dev)
 static int emac_mdio_probe(struct net_device *dev)
 {
 	struct emac_board_info *db = netdev_priv(dev);
+	struct phy_device *phydev;
 
 	/* to-do: PHY interrupts are currently not supported */
 
 	/* attach the mac to the phy */
-	db->phy_dev = of_phy_connect(db->ndev, db->phy_node,
-				     &emac_handle_link_change, 0,
-				     db->phy_interface);
-	if (!db->phy_dev) {
+	phydev = of_phy_connect(db->ndev, db->phy_node,
+				&emac_handle_link_change, 0,
+				db->phy_interface);
+	if (!phydev) {
 		netdev_err(db->ndev, "could not find the PHY\n");
 		return -ENODEV;
 	}
 
 	/* mask with MAC supported features */
-	db->phy_dev->supported &= PHY_BASIC_FEATURES;
-	db->phy_dev->advertising = db->phy_dev->supported;
+	phydev->supported &= PHY_BASIC_FEATURES;
+	phydev->advertising = phydev->supported;
 
 	db->link = 0;
 	db->speed = 0;
@@ -179,10 +179,7 @@ static int emac_mdio_probe(struct net_device *dev)
 
 static void emac_mdio_remove(struct net_device *dev)
 {
-	struct emac_board_info *db = netdev_priv(dev);
-
-	phy_disconnect(db->phy_dev);
-	db->phy_dev = NULL;
+	phy_disconnect(dev->phydev);
 }
 
 static void emac_reset(struct emac_board_info *db)
@@ -208,8 +205,7 @@ static void emac_inblk_32bit(void __iomem *reg, void *data, int count)
 
 static int emac_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	struct emac_board_info *dm = netdev_priv(dev);
-	struct phy_device *phydev = dm->phy_dev;
+	struct phy_device *phydev = dev->phydev;
 
 	if (!netif_running(dev))
 		return -EINVAL;
@@ -231,8 +227,7 @@ static void emac_get_drvinfo(struct net_device *dev,
 
 static int emac_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct emac_board_info *dm = netdev_priv(dev);
-	struct phy_device *phydev = dm->phy_dev;
+	struct phy_device *phydev = dev->phydev;
 
 	if (!phydev)
 		return -ENODEV;
@@ -242,8 +237,7 @@ static int emac_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 static int emac_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct emac_board_info *dm = netdev_priv(dev);
-	struct phy_device *phydev = dm->phy_dev;
+	struct phy_device *phydev = dev->phydev;
 
 	if (!phydev)
 		return -ENODEV;
@@ -744,7 +738,7 @@ static int emac_open(struct net_device *dev)
 		return ret;
 	}
 
-	phy_start(db->phy_dev);
+	phy_start(dev->phydev);
 	netif_start_queue(dev);
 
 	return 0;
@@ -781,7 +775,7 @@ static int emac_stop(struct net_device *ndev)
 	netif_stop_queue(ndev);
 	netif_carrier_off(ndev);
 
-	phy_stop(db->phy_dev);
+	phy_stop(ndev->phydev);
 
 	emac_mdio_remove(ndev);
 
-- 
1.7.4.4
