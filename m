From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 1/2] net: ethernet: renesas: sh_eth: use phydev from struct net_device
Date: Wed, 10 Aug 2016 00:04:48 +0200
Message-ID: <1470780289-27496-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
	linux-kernel@vger.kernel.org, Philippe Reynes <tremyfr@gmail.com>
To: sergei.shtylyov@cogentembedded.com, davem@davemloft.net,
	horms+renesas@verge.net.au, geert+renesas@glider.be, andrew@lunn.ch
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The private structure contain a pointer to phydev, but the structure
net_device already contain such pointer. So we can remove the pointer
phy_dev in the private structure, and update the driver to use the
one contained in struct net_device.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/renesas/sh_eth.c |   29 ++++++++++++-----------------
 drivers/net/ethernet/renesas/sh_eth.h |    1 -
 2 files changed, 12 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 799d58d..901ed36 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -1723,7 +1723,7 @@ out:
 static void sh_eth_adjust_link(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
-	struct phy_device *phydev = mdp->phydev;
+	struct phy_device *phydev = ndev->phydev;
 	int new_state = 0;
 
 	if (phydev->link) {
@@ -1800,22 +1800,19 @@ static int sh_eth_phy_init(struct net_device *ndev)
 
 	phy_attached_info(phydev);
 
-	mdp->phydev = phydev;
-
 	return 0;
 }
 
 /* PHY control start function */
 static int sh_eth_phy_start(struct net_device *ndev)
 {
-	struct sh_eth_private *mdp = netdev_priv(ndev);
 	int ret;
 
 	ret = sh_eth_phy_init(ndev);
 	if (ret)
 		return ret;
 
-	phy_start(mdp->phydev);
+	phy_start(ndev->phydev);
 
 	return 0;
 }
@@ -1827,11 +1824,11 @@ static int sh_eth_get_settings(struct net_device *ndev,
 	unsigned long flags;
 	int ret;
 
-	if (!mdp->phydev)
+	if (!ndev->phydev)
 		return -ENODEV;
 
 	spin_lock_irqsave(&mdp->lock, flags);
-	ret = phy_ethtool_gset(mdp->phydev, ecmd);
+	ret = phy_ethtool_gset(ndev->phydev, ecmd);
 	spin_unlock_irqrestore(&mdp->lock, flags);
 
 	return ret;
@@ -1844,7 +1841,7 @@ static int sh_eth_set_settings(struct net_device *ndev,
 	unsigned long flags;
 	int ret;
 
-	if (!mdp->phydev)
+	if (!ndev->phydev)
 		return -ENODEV;
 
 	spin_lock_irqsave(&mdp->lock, flags);
@@ -1852,7 +1849,7 @@ static int sh_eth_set_settings(struct net_device *ndev,
 	/* disable tx and rx */
 	sh_eth_rcv_snd_disable(ndev);
 
-	ret = phy_ethtool_sset(mdp->phydev, ecmd);
+	ret = phy_ethtool_sset(ndev->phydev, ecmd);
 	if (ret)
 		goto error_exit;
 
@@ -2067,11 +2064,11 @@ static int sh_eth_nway_reset(struct net_device *ndev)
 	unsigned long flags;
 	int ret;
 
-	if (!mdp->phydev)
+	if (!ndev->phydev)
 		return -ENODEV;
 
 	spin_lock_irqsave(&mdp->lock, flags);
-	ret = phy_start_aneg(mdp->phydev);
+	ret = phy_start_aneg(ndev->phydev);
 	spin_unlock_irqrestore(&mdp->lock, flags);
 
 	return ret;
@@ -2408,10 +2405,9 @@ static int sh_eth_close(struct net_device *ndev)
 	sh_eth_dev_exit(ndev);
 
 	/* PHY Disconnect */
-	if (mdp->phydev) {
-		phy_stop(mdp->phydev);
-		phy_disconnect(mdp->phydev);
-		mdp->phydev = NULL;
+	if (ndev->phydev) {
+		phy_stop(ndev->phydev);
+		phy_disconnect(ndev->phydev);
 	}
 
 	free_irq(ndev->irq, ndev);
@@ -2429,8 +2425,7 @@ static int sh_eth_close(struct net_device *ndev)
 /* ioctl to device function */
 static int sh_eth_do_ioctl(struct net_device *ndev, struct ifreq *rq, int cmd)
 {
-	struct sh_eth_private *mdp = netdev_priv(ndev);
-	struct phy_device *phydev = mdp->phydev;
+	struct phy_device *phydev = ndev->phydev;
 
 	if (!netif_running(ndev))
 		return -EINVAL;
diff --git a/drivers/net/ethernet/renesas/sh_eth.h b/drivers/net/ethernet/renesas/sh_eth.h
index c62380e..d050f37 100644
--- a/drivers/net/ethernet/renesas/sh_eth.h
+++ b/drivers/net/ethernet/renesas/sh_eth.h
@@ -518,7 +518,6 @@ struct sh_eth_private {
 	/* MII transceiver section. */
 	u32 phy_id;			/* PHY ID */
 	struct mii_bus *mii_bus;	/* MDIO bus control */
-	struct phy_device *phydev;	/* PHY device control */
 	int link;
 	phy_interface_t phy_interface;
 	int msg_enable;
-- 
1.7.4.4
