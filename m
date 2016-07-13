From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 1/2] net: ethernet: ll_temac: use phydev from struct net_device
Date: Thu, 14 Jul 2016 01:48:51 +0200
Message-ID: <1468453732-7370-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, Philippe Reynes <tremyfr@gmail.com>
To: michal.simek@xilinx.com, soren.brinkmann@xilinx.com,
	andrew@lunn.ch, davem@davemloft.net, f.fainelli@gmail.com,
	mugunthanvnm@ti.com, a@unstable.cc, fw@strlen.de,
	felipe.balbi@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35192 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751352AbcGMXtL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2016 19:49:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The private structure contain a pointer to phydev, but the structure
net_device already contain such pointer. So we can remove the pointer
phy in the private structure, and update the driver to use the
one contained in struct net_device.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/xilinx/ll_temac.h      |    1 -
 drivers/net/ethernet/xilinx/ll_temac_main.c |   37 +++++++++++---------------
 2 files changed, 16 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/ll_temac.h b/drivers/net/ethernet/xilinx/ll_temac.h
index 902457e..7d06e3e 100644
--- a/drivers/net/ethernet/xilinx/ll_temac.h
+++ b/drivers/net/ethernet/xilinx/ll_temac.h
@@ -332,7 +332,6 @@ struct temac_local {
 	struct device *dev;
 
 	/* Connection to PHY device */
-	struct phy_device *phy_dev;	/* Pointer to PHY device */
 	struct device_node *phy_node;
 
 	/* MDIO bus data */
diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
index 7397087..8d6a178 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_main.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
@@ -590,7 +590,7 @@ static void temac_device_reset(struct net_device *ndev)
 static void temac_adjust_link(struct net_device *ndev)
 {
 	struct temac_local *lp = netdev_priv(ndev);
-	struct phy_device *phy = lp->phy_dev;
+	struct phy_device *phy = ndev->phydev;
 	u32 mii_speed;
 	int link_state;
 
@@ -843,19 +843,20 @@ static irqreturn_t ll_temac_rx_irq(int irq, void *_ndev)
 static int temac_open(struct net_device *ndev)
 {
 	struct temac_local *lp = netdev_priv(ndev);
+	struct phy_device *phydev = NULL;
 	int rc;
 
 	dev_dbg(&ndev->dev, "temac_open()\n");
 
 	if (lp->phy_node) {
-		lp->phy_dev = of_phy_connect(lp->ndev, lp->phy_node,
-					     temac_adjust_link, 0, 0);
-		if (!lp->phy_dev) {
+		phydev = of_phy_connect(lp->ndev, lp->phy_node,
+					temac_adjust_link, 0, 0);
+		if (!phydev) {
 			dev_err(lp->dev, "of_phy_connect() failed\n");
 			return -ENODEV;
 		}
 
-		phy_start(lp->phy_dev);
+		phy_start(phydev);
 	}
 
 	temac_device_reset(ndev);
@@ -872,9 +873,8 @@ static int temac_open(struct net_device *ndev)
  err_rx_irq:
 	free_irq(lp->tx_irq, ndev);
  err_tx_irq:
-	if (lp->phy_dev)
-		phy_disconnect(lp->phy_dev);
-	lp->phy_dev = NULL;
+	if (phydev)
+		phy_disconnect(phydev);
 	dev_err(lp->dev, "request_irq() failed\n");
 	return rc;
 }
@@ -882,15 +882,15 @@ static int temac_open(struct net_device *ndev)
 static int temac_stop(struct net_device *ndev)
 {
 	struct temac_local *lp = netdev_priv(ndev);
+	struct phy_device *phydev = ndev->phydev;
 
 	dev_dbg(&ndev->dev, "temac_close()\n");
 
 	free_irq(lp->tx_irq, ndev);
 	free_irq(lp->rx_irq, ndev);
 
-	if (lp->phy_dev)
-		phy_disconnect(lp->phy_dev);
-	lp->phy_dev = NULL;
+	if (phydev)
+		phy_disconnect(phydev);
 
 	temac_dma_bd_release(ndev);
 
@@ -916,15 +916,13 @@ temac_poll_controller(struct net_device *ndev)
 
 static int temac_ioctl(struct net_device *ndev, struct ifreq *rq, int cmd)
 {
-	struct temac_local *lp = netdev_priv(ndev);
-
 	if (!netif_running(ndev))
 		return -EINVAL;
 
-	if (!lp->phy_dev)
+	if (!ndev->phydev)
 		return -EINVAL;
 
-	return phy_mii_ioctl(lp->phy_dev, rq, cmd);
+	return phy_mii_ioctl(ndev->phydev, rq, cmd);
 }
 
 static const struct net_device_ops temac_netdev_ops = {
@@ -971,20 +969,17 @@ static const struct attribute_group temac_attr_group = {
 /* ethtool support */
 static int temac_get_settings(struct net_device *ndev, struct ethtool_cmd *cmd)
 {
-	struct temac_local *lp = netdev_priv(ndev);
-	return phy_ethtool_gset(lp->phy_dev, cmd);
+	return phy_ethtool_gset(ndev->phydev, cmd);
 }
 
 static int temac_set_settings(struct net_device *ndev, struct ethtool_cmd *cmd)
 {
-	struct temac_local *lp = netdev_priv(ndev);
-	return phy_ethtool_sset(lp->phy_dev, cmd);
+	return phy_ethtool_sset(ndev->phydev, cmd);
 }
 
 static int temac_nway_reset(struct net_device *ndev)
 {
-	struct temac_local *lp = netdev_priv(ndev);
-	return phy_start_aneg(lp->phy_dev);
+	return phy_start_aneg(ndev->phydev);
 }
 
 static const struct ethtool_ops temac_ethtool_ops = {
-- 
1.7.4.4
