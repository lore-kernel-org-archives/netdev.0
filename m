From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 1/2] net: ethernet: fec-mpc52xx: use phydev from struct net_device
Date: Tue, 17 May 2016 00:32:33 +0200
Message-ID: <1463437954-6014-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, treding@nvidia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36302 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751810AbcEPWco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 18:32:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The private structure contain a pointer to phydev, but the structure
net_device already contain such pointer. So we can remove the pointer
phydev in the private structure, and update the driver to use the
one contained in struct net_device.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/freescale/fec_mpc52xx.c |   43 ++++++++++++--------------
 1 files changed, 20 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_mpc52xx.c b/drivers/net/ethernet/freescale/fec_mpc52xx.c
index f444714..bcf0600 100644
--- a/drivers/net/ethernet/freescale/fec_mpc52xx.c
+++ b/drivers/net/ethernet/freescale/fec_mpc52xx.c
@@ -66,7 +66,6 @@ struct mpc52xx_fec_priv {
 	/* MDIO link details */
 	unsigned int mdio_speed;
 	struct device_node *phy_node;
-	struct phy_device *phydev;
 	enum phy_state link;
 	int seven_wire_mode;
 };
@@ -165,7 +164,7 @@ static int mpc52xx_fec_alloc_rx_buffers(struct net_device *dev, struct bcom_task
 static void mpc52xx_fec_adjust_link(struct net_device *dev)
 {
 	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
-	struct phy_device *phydev = priv->phydev;
+	struct phy_device *phydev = dev->phydev;
 	int new_state = 0;
 
 	if (phydev->link != PHY_DOWN) {
@@ -215,16 +214,17 @@ static void mpc52xx_fec_adjust_link(struct net_device *dev)
 static int mpc52xx_fec_open(struct net_device *dev)
 {
 	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
+	struct phy_device *phydev = NULL;
 	int err = -EBUSY;
 
 	if (priv->phy_node) {
-		priv->phydev = of_phy_connect(priv->ndev, priv->phy_node,
-					      mpc52xx_fec_adjust_link, 0, 0);
-		if (!priv->phydev) {
+		phydev = of_phy_connect(priv->ndev, priv->phy_node,
+					mpc52xx_fec_adjust_link, 0, 0);
+		if (!phydev) {
 			dev_err(&dev->dev, "of_phy_connect failed\n");
 			return -ENODEV;
 		}
-		phy_start(priv->phydev);
+		phy_start(phydev);
 	}
 
 	if (request_irq(dev->irq, mpc52xx_fec_interrupt, IRQF_SHARED,
@@ -268,10 +268,9 @@ static int mpc52xx_fec_open(struct net_device *dev)
  free_ctrl_irq:
 	free_irq(dev->irq, dev);
  free_phy:
-	if (priv->phydev) {
-		phy_stop(priv->phydev);
-		phy_disconnect(priv->phydev);
-		priv->phydev = NULL;
+	if (phydev) {
+		phy_stop(phydev);
+		phy_disconnect(phydev);
 	}
 
 	return err;
@@ -280,6 +279,7 @@ static int mpc52xx_fec_open(struct net_device *dev)
 static int mpc52xx_fec_close(struct net_device *dev)
 {
 	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
+	struct phy_device *phydev = dev->phydev;
 
 	netif_stop_queue(dev);
 
@@ -291,11 +291,10 @@ static int mpc52xx_fec_close(struct net_device *dev)
 	free_irq(priv->r_irq, dev);
 	free_irq(priv->t_irq, dev);
 
-	if (priv->phydev) {
+	if (phydev) {
 		/* power down phy */
-		phy_stop(priv->phydev);
-		phy_disconnect(priv->phydev);
-		priv->phydev = NULL;
+		phy_stop(phydev);
+		phy_disconnect(phydev);
 	}
 
 	return 0;
@@ -766,10 +765,9 @@ static void mpc52xx_fec_reset(struct net_device *dev)
 static int mpc52xx_fec_get_ksettings(struct net_device *dev,
 				     struct ethtool_link_ksettings *cmd)
 {
-	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
-	struct phy_device *phydev = priv->phydev;
+	struct phy_device *phydev = dev->phydev;
 
-	if (!priv->phydev)
+	if (!phydev)
 		return -ENODEV;
 
 	return phy_ethtool_ksettings_get(phydev, cmd);
@@ -778,10 +776,9 @@ static int mpc52xx_fec_get_ksettings(struct net_device *dev,
 static int mpc52xx_fec_set_ksettings(struct net_device *dev,
 				     const struct ethtool_link_ksettings *cmd)
 {
-	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
-	struct phy_device *phydev = priv->phydev;
+	struct phy_device *phydev = dev->phydev;
 
-	if (!priv->phydev)
+	if (!phydev)
 		return -ENODEV;
 
 	return phy_ethtool_ksettings_set(phydev, cmd);
@@ -811,12 +808,12 @@ static const struct ethtool_ops mpc52xx_fec_ethtool_ops = {
 
 static int mpc52xx_fec_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
+	struct phy_device *phydev = dev->phydev;
 
-	if (!priv->phydev)
+	if (!phydev)
 		return -ENOTSUPP;
 
-	return phy_mii_ioctl(priv->phydev, rq, cmd);
+	return phy_mii_ioctl(phydev, rq, cmd);
 }
 
 static const struct net_device_ops mpc52xx_fec_netdev_ops = {
-- 
1.7.4.4
