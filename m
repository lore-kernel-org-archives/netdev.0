From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 1/2] net: mv643xx_eth: use phydev from struct net_device
Date: Sun,  2 Oct 2016 12:06:48 +0200
Message-ID: <1475402809-11593-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: sebastian.hesselbarth@gmail.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35333 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750831AbcJBKG6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 2 Oct 2016 06:06:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The private structure contain a pointer to phydev, but the structure
net_device already contain such pointer. So we can remove the pointer
phydev in the private structure, and update the driver to use the
one contained in struct net_device.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/marvell/mv643xx_eth.c |   88 ++++++++++++++--------------
 1 files changed, 43 insertions(+), 45 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 5583118..ae7370d 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -384,8 +384,6 @@ struct mv643xx_eth_private {
 
 	struct net_device *dev;
 
-	struct phy_device *phy;
-
 	struct timer_list mib_counters_timer;
 	spinlock_t mib_counters_lock;
 	struct mib_counters mib_counters;
@@ -1236,7 +1234,7 @@ static void mv643xx_eth_adjust_link(struct net_device *dev)
 		     DISABLE_AUTO_NEG_FOR_FLOW_CTRL |
 		     DISABLE_AUTO_NEG_FOR_DUPLEX;
 
-	if (mp->phy->autoneg == AUTONEG_ENABLE) {
+	if (dev->phydev->autoneg == AUTONEG_ENABLE) {
 		/* enable auto negotiation */
 		pscr &= ~autoneg_disable;
 		goto out_write;
@@ -1244,7 +1242,7 @@ static void mv643xx_eth_adjust_link(struct net_device *dev)
 
 	pscr |= autoneg_disable;
 
-	if (mp->phy->speed == SPEED_1000) {
+	if (dev->phydev->speed == SPEED_1000) {
 		/* force gigabit, half duplex not supported */
 		pscr |= SET_GMII_SPEED_TO_1000;
 		pscr |= SET_FULL_DUPLEX_MODE;
@@ -1253,12 +1251,12 @@ static void mv643xx_eth_adjust_link(struct net_device *dev)
 
 	pscr &= ~SET_GMII_SPEED_TO_1000;
 
-	if (mp->phy->speed == SPEED_100)
+	if (dev->phydev->speed == SPEED_100)
 		pscr |= SET_MII_SPEED_TO_100;
 	else
 		pscr &= ~SET_MII_SPEED_TO_100;
 
-	if (mp->phy->duplex == DUPLEX_FULL)
+	if (dev->phydev->duplex == DUPLEX_FULL)
 		pscr |= SET_FULL_DUPLEX_MODE;
 	else
 		pscr &= ~SET_FULL_DUPLEX_MODE;
@@ -1500,11 +1498,12 @@ static int
 mv643xx_eth_get_settings_phy(struct mv643xx_eth_private *mp,
 			     struct ethtool_cmd *cmd)
 {
+	struct net_device *dev = mp->dev;
 	int err;
 
-	err = phy_read_status(mp->phy);
+	err = phy_read_status(dev->phydev);
 	if (err == 0)
-		err = phy_ethtool_gset(mp->phy, cmd);
+		err = phy_ethtool_gset(dev->phydev, cmd);
 
 	/*
 	 * The MAC does not support 1000baseT_Half.
@@ -1553,23 +1552,21 @@ mv643xx_eth_get_settings_phyless(struct mv643xx_eth_private *mp,
 static void
 mv643xx_eth_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
-	struct mv643xx_eth_private *mp = netdev_priv(dev);
 	wol->supported = 0;
 	wol->wolopts = 0;
-	if (mp->phy)
-		phy_ethtool_get_wol(mp->phy, wol);
+	if (dev->phydev)
+		phy_ethtool_get_wol(dev->phydev, wol);
 }
 
 static int
 mv643xx_eth_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
-	struct mv643xx_eth_private *mp = netdev_priv(dev);
 	int err;
 
-	if (mp->phy == NULL)
+	if (!dev->phydev)
 		return -EOPNOTSUPP;
 
-	err = phy_ethtool_set_wol(mp->phy, wol);
+	err = phy_ethtool_set_wol(dev->phydev, wol);
 	/* Given that mv643xx_eth works without the marvell-specific PHY driver,
 	 * this debugging hint is useful to have.
 	 */
@@ -1583,7 +1580,7 @@ mv643xx_eth_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct mv643xx_eth_private *mp = netdev_priv(dev);
 
-	if (mp->phy != NULL)
+	if (dev->phydev)
 		return mv643xx_eth_get_settings_phy(mp, cmd);
 	else
 		return mv643xx_eth_get_settings_phyless(mp, cmd);
@@ -1592,10 +1589,9 @@ mv643xx_eth_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 static int
 mv643xx_eth_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct mv643xx_eth_private *mp = netdev_priv(dev);
 	int ret;
 
-	if (mp->phy == NULL)
+	if (!dev->phydev)
 		return -EINVAL;
 
 	/*
@@ -1603,7 +1599,7 @@ mv643xx_eth_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	 */
 	cmd->advertising &= ~ADVERTISED_1000baseT_Half;
 
-	ret = phy_ethtool_sset(mp->phy, cmd);
+	ret = phy_ethtool_sset(dev->phydev, cmd);
 	if (!ret)
 		mv643xx_eth_adjust_link(dev);
 	return ret;
@@ -1622,12 +1618,10 @@ static void mv643xx_eth_get_drvinfo(struct net_device *dev,
 
 static int mv643xx_eth_nway_reset(struct net_device *dev)
 {
-	struct mv643xx_eth_private *mp = netdev_priv(dev);
-
-	if (mp->phy == NULL)
+	if (!dev->phydev)
 		return -EINVAL;
 
-	return genphy_restart_aneg(mp->phy);
+	return genphy_restart_aneg(dev->phydev);
 }
 
 static int
@@ -2326,19 +2320,20 @@ static inline void oom_timer_wrapper(unsigned long data)
 
 static void port_start(struct mv643xx_eth_private *mp)
 {
+	struct net_device *dev = mp->dev;
 	u32 pscr;
 	int i;
 
 	/*
 	 * Perform PHY reset, if there is a PHY.
 	 */
-	if (mp->phy != NULL) {
+	if (dev->phydev) {
 		struct ethtool_cmd cmd;
 
-		mv643xx_eth_get_settings(mp->dev, &cmd);
-		phy_init_hw(mp->phy);
-		mv643xx_eth_set_settings(mp->dev, &cmd);
-		phy_start(mp->phy);
+		mv643xx_eth_get_settings(dev, &cmd);
+		phy_init_hw(dev->phydev);
+		mv643xx_eth_set_settings(dev, &cmd);
+		phy_start(dev->phydev);
 	}
 
 	/*
@@ -2350,7 +2345,7 @@ static void port_start(struct mv643xx_eth_private *mp)
 	wrlp(mp, PORT_SERIAL_CONTROL, pscr);
 
 	pscr |= DO_NOT_FORCE_LINK_FAIL;
-	if (mp->phy == NULL)
+	if (!dev->phydev)
 		pscr |= FORCE_LINK_PASS;
 	wrlp(mp, PORT_SERIAL_CONTROL, pscr);
 
@@ -2534,8 +2529,8 @@ static int mv643xx_eth_stop(struct net_device *dev)
 	del_timer_sync(&mp->rx_oom);
 
 	netif_carrier_off(dev);
-	if (mp->phy)
-		phy_stop(mp->phy);
+	if (dev->phydev)
+		phy_stop(dev->phydev);
 	free_irq(dev->irq, dev);
 
 	port_reset(mp);
@@ -2553,13 +2548,12 @@ static int mv643xx_eth_stop(struct net_device *dev)
 
 static int mv643xx_eth_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
-	struct mv643xx_eth_private *mp = netdev_priv(dev);
 	int ret;
 
-	if (mp->phy == NULL)
+	if (!dev->phydev)
 		return -ENOTSUPP;
 
-	ret = phy_mii_ioctl(mp->phy, ifr, cmd);
+	ret = phy_mii_ioctl(dev->phydev, ifr, cmd);
 	if (!ret)
 		mv643xx_eth_adjust_link(dev);
 	return ret;
@@ -3006,7 +3000,8 @@ static struct phy_device *phy_scan(struct mv643xx_eth_private *mp,
 
 static void phy_init(struct mv643xx_eth_private *mp, int speed, int duplex)
 {
-	struct phy_device *phy = mp->phy;
+	struct net_device *dev = mp->dev;
+	struct phy_device *phy = dev->phydev;
 
 	if (speed == 0) {
 		phy->autoneg = AUTONEG_ENABLE;
@@ -3024,6 +3019,7 @@ static void phy_init(struct mv643xx_eth_private *mp, int speed, int duplex)
 
 static void init_pscr(struct mv643xx_eth_private *mp, int speed, int duplex)
 {
+	struct net_device *dev = mp->dev;
 	u32 pscr;
 
 	pscr = rdlp(mp, PORT_SERIAL_CONTROL);
@@ -3033,7 +3029,7 @@ static void init_pscr(struct mv643xx_eth_private *mp, int speed, int duplex)
 	}
 
 	pscr = MAX_RX_PACKET_9700BYTE | SERIAL_PORT_CONTROL_RESERVED;
-	if (mp->phy == NULL) {
+	if (!dev->phydev) {
 		pscr |= DISABLE_AUTO_NEG_SPEED_GMII;
 		if (speed == SPEED_1000)
 			pscr |= SET_GMII_SPEED_TO_1000;
@@ -3072,6 +3068,7 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	struct mv643xx_eth_platform_data *pd;
 	struct mv643xx_eth_private *mp;
 	struct net_device *dev;
+	struct phy_device *phydev = NULL;
 	struct resource *res;
 	int err;
 
@@ -3127,18 +3124,18 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 
 	err = 0;
 	if (pd->phy_node) {
-		mp->phy = of_phy_connect(mp->dev, pd->phy_node,
-					 mv643xx_eth_adjust_link, 0,
-					 PHY_INTERFACE_MODE_GMII);
-		if (!mp->phy)
+		phydev = of_phy_connect(mp->dev, pd->phy_node,
+					mv643xx_eth_adjust_link, 0,
+					PHY_INTERFACE_MODE_GMII);
+		if (!phydev)
 			err = -ENODEV;
 		else
-			phy_addr_set(mp, mp->phy->mdio.addr);
+			phy_addr_set(mp, phydev->mdio.addr);
 	} else if (pd->phy_addr != MV643XX_ETH_PHY_NONE) {
-		mp->phy = phy_scan(mp, pd->phy_addr);
+		phydev = phy_scan(mp, pd->phy_addr);
 
-		if (IS_ERR(mp->phy))
-			err = PTR_ERR(mp->phy);
+		if (IS_ERR(phydev))
+			err = PTR_ERR(phydev);
 		else
 			phy_init(mp, pd->speed, pd->duplex);
 	}
@@ -3222,10 +3219,11 @@ out:
 static int mv643xx_eth_remove(struct platform_device *pdev)
 {
 	struct mv643xx_eth_private *mp = platform_get_drvdata(pdev);
+	struct net_device *dev = mp->dev;
 
 	unregister_netdev(mp->dev);
-	if (mp->phy != NULL)
-		phy_disconnect(mp->phy);
+	if (dev->phydev)
+		phy_disconnect(dev->phydev);
 	cancel_work_sync(&mp->tx_timeout_task);
 
 	if (!IS_ERR(mp->clk))
-- 
1.7.4.4
