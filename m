From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 1/2] net: ethernet: renesas: ravb: use phydev from struct net_device
Date: Sat, 20 Aug 2016 00:52:18 +0200
Message-ID: <1471647139-1867-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
        linux-kernel@vger.kernel.org, Philippe Reynes <tremyfr@gmail.com>
To: sergei.shtylyov@cogentembedded.com, davem@davemloft.net,
        kazuya.mizuguchi.ks@renesas.com, ykaneko0929@gmail.com,
        horms+renesas@verge.net.au, masaru.nagai.vx@renesas.com,
        geert+renesas@glider.be, niklas.soderlund+renesas@ragnatech.se
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The private structure contain a pointer to phydev, but the structure
net_device already contain such pointer. So we can remove the pointer
phy_dev in the private structure, and update the driver to use the
one contained in struct net_device.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/renesas/ravb.h      |    1 -
 drivers/net/ethernet/renesas/ravb_main.c |   29 ++++++++++++-----------------
 2 files changed, 12 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/renesas/ravb.h b/drivers/net/ethernet/renesas/ravb.h
index 4e5d5e9..f110966 100644
--- a/drivers/net/ethernet/renesas/ravb.h
+++ b/drivers/net/ethernet/renesas/ravb.h
@@ -1011,7 +1011,6 @@ struct ravb_private {
 	struct work_struct work;
 	/* MII transceiver section. */
 	struct mii_bus *mii_bus;	/* MDIO bus control */
-	struct phy_device *phydev;	/* PHY device control */
 	int link;
 	phy_interface_t phy_interface;
 	int msg_enable;
diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
index d4809ad..d21c9a4 100644
--- a/drivers/net/ethernet/renesas/ravb_main.c
+++ b/drivers/net/ethernet/renesas/ravb_main.c
@@ -942,7 +942,7 @@ out:
 static void ravb_adjust_link(struct net_device *ndev)
 {
 	struct ravb_private *priv = netdev_priv(ndev);
-	struct phy_device *phydev = priv->phydev;
+	struct phy_device *phydev = ndev->phydev;
 	bool new_state = false;
 
 	if (phydev->link) {
@@ -1032,22 +1032,19 @@ static int ravb_phy_init(struct net_device *ndev)
 
 	phy_attached_info(phydev);
 
-	priv->phydev = phydev;
-
 	return 0;
 }
 
 /* PHY control start function */
 static int ravb_phy_start(struct net_device *ndev)
 {
-	struct ravb_private *priv = netdev_priv(ndev);
 	int error;
 
 	error = ravb_phy_init(ndev);
 	if (error)
 		return error;
 
-	phy_start(priv->phydev);
+	phy_start(ndev->phydev);
 
 	return 0;
 }
@@ -1058,9 +1055,9 @@ static int ravb_get_settings(struct net_device *ndev, struct ethtool_cmd *ecmd)
 	int error = -ENODEV;
 	unsigned long flags;
 
-	if (priv->phydev) {
+	if (ndev->phydev) {
 		spin_lock_irqsave(&priv->lock, flags);
-		error = phy_ethtool_gset(priv->phydev, ecmd);
+		error = phy_ethtool_gset(ndev->phydev, ecmd);
 		spin_unlock_irqrestore(&priv->lock, flags);
 	}
 
@@ -1073,7 +1070,7 @@ static int ravb_set_settings(struct net_device *ndev, struct ethtool_cmd *ecmd)
 	unsigned long flags;
 	int error;
 
-	if (!priv->phydev)
+	if (!ndev->phydev)
 		return -ENODEV;
 
 	spin_lock_irqsave(&priv->lock, flags);
@@ -1081,7 +1078,7 @@ static int ravb_set_settings(struct net_device *ndev, struct ethtool_cmd *ecmd)
 	/* Disable TX and RX */
 	ravb_rcv_snd_disable(ndev);
 
-	error = phy_ethtool_sset(priv->phydev, ecmd);
+	error = phy_ethtool_sset(ndev->phydev, ecmd);
 	if (error)
 		goto error_exit;
 
@@ -1110,9 +1107,9 @@ static int ravb_nway_reset(struct net_device *ndev)
 	int error = -ENODEV;
 	unsigned long flags;
 
-	if (priv->phydev) {
+	if (ndev->phydev) {
 		spin_lock_irqsave(&priv->lock, flags);
-		error = phy_start_aneg(priv->phydev);
+		error = phy_start_aneg(ndev->phydev);
 		spin_unlock_irqrestore(&priv->lock, flags);
 	}
 
@@ -1661,10 +1658,9 @@ static int ravb_close(struct net_device *ndev)
 	}
 
 	/* PHY disconnect */
-	if (priv->phydev) {
-		phy_stop(priv->phydev);
-		phy_disconnect(priv->phydev);
-		priv->phydev = NULL;
+	if (ndev->phydev) {
+		phy_stop(ndev->phydev);
+		phy_disconnect(ndev->phydev);
 	}
 
 	if (priv->chip_id != RCAR_GEN2) {
@@ -1753,8 +1749,7 @@ static int ravb_hwtstamp_set(struct net_device *ndev, struct ifreq *req)
 /* ioctl to device function */
 static int ravb_do_ioctl(struct net_device *ndev, struct ifreq *req, int cmd)
 {
-	struct ravb_private *priv = netdev_priv(ndev);
-	struct phy_device *phydev = priv->phydev;
+	struct phy_device *phydev = ndev->phydev;
 
 	if (!netif_running(ndev))
 		return -EINVAL;
-- 
1.7.4.4
