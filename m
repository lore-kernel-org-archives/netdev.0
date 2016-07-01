From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 1/2] net: ethernet: davinci_emac: use phydev from struct net_device
Date: Sat,  2 Jul 2016 00:02:34 +0200
Message-ID: <1467410555-19514-1-git-send-email-tremyfr@gmail.com>
Cc: linux-omap@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Philippe Reynes <tremyfr@gmail.com>
To: mugunthanvnm@ti.com, grygorii.strashko@ti.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The private structure contain a pointer to phydev, but the structure
net_device already contain such pointer. So we can remove the pointer
phy in the private structure, and update the driver to use the
one contained in struct net_device.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/ti/davinci_emac.c |   61 ++++++++++++++------------------
 1 files changed, 27 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index f56d66e..76683c7 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -348,7 +348,6 @@ struct emac_priv {
 	u32 rx_addr_type;
 	const char *phy_id;
 	struct device_node *phy_node;
-	struct phy_device *phydev;
 	spinlock_t lock;
 	/*platform specific members*/
 	void (*int_enable) (void);
@@ -496,9 +495,8 @@ static void emac_get_drvinfo(struct net_device *ndev,
 static int emac_get_settings(struct net_device *ndev,
 			     struct ethtool_cmd *ecmd)
 {
-	struct emac_priv *priv = netdev_priv(ndev);
-	if (priv->phydev)
-		return phy_ethtool_gset(priv->phydev, ecmd);
+	if (ndev->phydev)
+		return phy_ethtool_gset(ndev->phydev, ecmd);
 	else
 		return -EOPNOTSUPP;
 
@@ -514,9 +512,8 @@ static int emac_get_settings(struct net_device *ndev,
  */
 static int emac_set_settings(struct net_device *ndev, struct ethtool_cmd *ecmd)
 {
-	struct emac_priv *priv = netdev_priv(ndev);
-	if (priv->phydev)
-		return phy_ethtool_sset(priv->phydev, ecmd);
+	if (ndev->phydev)
+		return phy_ethtool_sset(ndev->phydev, ecmd);
 	else
 		return -EOPNOTSUPP;
 
@@ -651,8 +648,8 @@ static void emac_update_phystatus(struct emac_priv *priv)
 	mac_control = emac_read(EMAC_MACCONTROL);
 	cur_duplex = (mac_control & EMAC_MACCONTROL_FULLDUPLEXEN) ?
 			DUPLEX_FULL : DUPLEX_HALF;
-	if (priv->phydev)
-		new_duplex = priv->phydev->duplex;
+	if (ndev->phydev)
+		new_duplex = ndev->phydev->duplex;
 	else
 		new_duplex = DUPLEX_FULL;
 
@@ -1454,7 +1451,7 @@ static void emac_poll_controller(struct net_device *ndev)
 static void emac_adjust_link(struct net_device *ndev)
 {
 	struct emac_priv *priv = netdev_priv(ndev);
-	struct phy_device *phydev = priv->phydev;
+	struct phy_device *phydev = ndev->phydev;
 	unsigned long flags;
 	int new_state = 0;
 
@@ -1483,7 +1480,7 @@ static void emac_adjust_link(struct net_device *ndev)
 	}
 	if (new_state) {
 		emac_update_phystatus(priv);
-		phy_print_status(priv->phydev);
+		phy_print_status(ndev->phydev);
 	}
 
 	spin_unlock_irqrestore(&priv->lock, flags);
@@ -1505,15 +1502,13 @@ static void emac_adjust_link(struct net_device *ndev)
  */
 static int emac_devioctl(struct net_device *ndev, struct ifreq *ifrq, int cmd)
 {
-	struct emac_priv *priv = netdev_priv(ndev);
-
 	if (!(netif_running(ndev)))
 		return -EINVAL;
 
 	/* TODO: Add phy read and write and private statistics get feature */
 
-	if (priv->phydev)
-		return phy_mii_ioctl(priv->phydev, ifrq, cmd);
+	if (ndev->phydev)
+		return phy_mii_ioctl(ndev->phydev, ifrq, cmd);
 	else
 		return -EOPNOTSUPP;
 }
@@ -1542,6 +1537,7 @@ static int emac_dev_open(struct net_device *ndev)
 	int res_num = 0, irq_num = 0;
 	int i = 0;
 	struct emac_priv *priv = netdev_priv(ndev);
+	struct phy_device *phydev = NULL;
 
 	ret = pm_runtime_get_sync(&priv->pdev->dev);
 	if (ret < 0) {
@@ -1607,12 +1603,10 @@ static int emac_dev_open(struct net_device *ndev)
 
 	cpdma_ctlr_start(priv->dma);
 
-	priv->phydev = NULL;
-
 	if (priv->phy_node) {
-		priv->phydev = of_phy_connect(ndev, priv->phy_node,
-					      &emac_adjust_link, 0, 0);
-		if (!priv->phydev) {
+		phydev = of_phy_connect(ndev, priv->phy_node,
+					&emac_adjust_link, 0, 0);
+		if (!phydev) {
 			dev_err(emac_dev, "could not connect to phy %s\n",
 				priv->phy_node->full_name);
 			ret = -ENODEV;
@@ -1621,7 +1615,7 @@ static int emac_dev_open(struct net_device *ndev)
 	}
 
 	/* use the first phy on the bus if pdata did not give us a phy id */
-	if (!priv->phydev && !priv->phy_id) {
+	if (!phydev && !priv->phy_id) {
 		struct device *phy;
 
 		phy = bus_find_device(&mdio_bus_type, NULL, NULL,
@@ -1630,16 +1624,15 @@ static int emac_dev_open(struct net_device *ndev)
 			priv->phy_id = dev_name(phy);
 	}
 
-	if (!priv->phydev && priv->phy_id && *priv->phy_id) {
-		priv->phydev = phy_connect(ndev, priv->phy_id,
-					   &emac_adjust_link,
-					   PHY_INTERFACE_MODE_MII);
+	if (!phydev && priv->phy_id && *priv->phy_id) {
+		phydev = phy_connect(ndev, priv->phy_id,
+				     &emac_adjust_link,
+				     PHY_INTERFACE_MODE_MII);
 
-		if (IS_ERR(priv->phydev)) {
+		if (IS_ERR(phydev)) {
 			dev_err(emac_dev, "could not connect to phy %s\n",
 				priv->phy_id);
-			ret = PTR_ERR(priv->phydev);
-			priv->phydev = NULL;
+			ret = PTR_ERR(phydev);
 			goto err;
 		}
 
@@ -1647,10 +1640,10 @@ static int emac_dev_open(struct net_device *ndev)
 		priv->speed = 0;
 		priv->duplex = ~0;
 
-		phy_attached_info(priv->phydev);
+		phy_attached_info(phydev);
 	}
 
-	if (!priv->phydev) {
+	if (!phydev) {
 		/* No PHY , fix the link, speed and duplex settings */
 		dev_notice(emac_dev, "no phy, defaulting to 100/full\n");
 		priv->link = 1;
@@ -1665,8 +1658,8 @@ static int emac_dev_open(struct net_device *ndev)
 	if (netif_msg_drv(priv))
 		dev_notice(emac_dev, "DaVinci EMAC: Opened %s\n", ndev->name);
 
-	if (priv->phydev)
-		phy_start(priv->phydev);
+	if (phydev)
+		phy_start(phydev);
 
 	return 0;
 
@@ -1717,8 +1710,8 @@ static int emac_dev_stop(struct net_device *ndev)
 	cpdma_ctlr_stop(priv->dma);
 	emac_write(EMAC_SOFTRESET, 1);
 
-	if (priv->phydev)
-		phy_disconnect(priv->phydev);
+	if (ndev->phydev)
+		phy_disconnect(ndev->phydev);
 
 	/* Free IRQ */
 	while ((res = platform_get_resource(priv->pdev, IORESOURCE_IRQ, i))) {
-- 
1.7.4.4
