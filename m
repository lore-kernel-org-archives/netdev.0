From: Phil Sutter <phil.sutter@viprinet.com>
Subject: [PATCH] fix mv643xx_eth for disabled autoneg
Date: Wed,  6 Mar 2013 18:49:02 +0100
Message-ID: <1362592142-4049-1-git-send-email-phil.sutter@viprinet.com>
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@marvell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.vipri.net ([89.207.250.15]:53767 "EHLO zimbra.vipri.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753222Ab3CFRuL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Mar 2013 12:50:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When autoneg has been disabled in the PHY (Marvell 88E1118 here), auto
negotiation between MAC and PHY seem non-functional anymore. The only
way I found to workaround this is to manually configure the MAC with the
settings sent to the PHY earlier.

Signed-off-by: Phil Sutter <phil.sutter@viprinet.com>
---
 drivers/net/ethernet/marvell/mv643xx_eth.c |   55 ++++++++++++++++++++++++++--
 1 files changed, 51 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 5e1ca0f..5435833 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -1082,6 +1082,45 @@ static void txq_set_fixed_prio_mode(struct tx_queue *txq)
 
 
 /* mii management interface *************************************************/
+static void mv643xx_adjust_pscr(struct mv643xx_eth_private *mp)
+{
+	u32 pscr = rdlp(mp, PORT_SERIAL_CONTROL);
+	u32 autoneg_disable = FORCE_LINK_PASS |
+	             DISABLE_AUTO_NEG_SPEED_GMII |
+		     DISABLE_AUTO_NEG_FOR_FLOW_CTRL |
+		     DISABLE_AUTO_NEG_FOR_DUPLEX;
+
+	if (mp->phy->autoneg == AUTONEG_ENABLE) {
+		/* enable auto negotiation */
+		pscr &= ~autoneg_disable;
+		goto out_write;
+	}
+
+	pscr |= autoneg_disable;
+
+	if (mp->phy->speed == SPEED_1000) {
+		/* force gigabit, half duplex not supported */
+		pscr |= SET_GMII_SPEED_TO_1000;
+		pscr |= SET_FULL_DUPLEX_MODE;
+		goto out_write;
+	}
+
+	pscr &= ~SET_GMII_SPEED_TO_1000;
+
+	if (mp->phy->speed == SPEED_100)
+		pscr |= SET_MII_SPEED_TO_100;
+	else
+		pscr &= ~SET_MII_SPEED_TO_100;
+
+	if (mp->phy->duplex == DUPLEX_FULL)
+		pscr |= SET_FULL_DUPLEX_MODE;
+	else
+		pscr &= ~SET_FULL_DUPLEX_MODE;
+
+out_write:
+	wrlp(mp, PORT_SERIAL_CONTROL, pscr);
+}
+
 static irqreturn_t mv643xx_eth_err_irq(int irq, void *dev_id)
 {
 	struct mv643xx_eth_shared_private *msp = dev_id;
@@ -1500,6 +1539,7 @@ static int
 mv643xx_eth_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct mv643xx_eth_private *mp = netdev_priv(dev);
+	int ret;
 
 	if (mp->phy == NULL)
 		return -EINVAL;
@@ -1509,7 +1549,10 @@ mv643xx_eth_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	 */
 	cmd->advertising &= ~ADVERTISED_1000baseT_Half;
 
-	return phy_ethtool_sset(mp->phy, cmd);
+	ret = phy_ethtool_sset(mp->phy, cmd);
+	if (!ret)
+		mv643xx_adjust_pscr(mp);
+	return ret;
 }
 
 static void mv643xx_eth_get_drvinfo(struct net_device *dev,
@@ -2448,11 +2491,15 @@ static int mv643xx_eth_stop(struct net_device *dev)
 static int mv643xx_eth_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
 	struct mv643xx_eth_private *mp = netdev_priv(dev);
+	int ret;
 
-	if (mp->phy != NULL)
-		return phy_mii_ioctl(mp->phy, ifr, cmd);
+	if (mp->phy == NULL)
+		return -ENOTSUPP;
 
-	return -EOPNOTSUPP;
+	ret = phy_mii_ioctl(mp->phy, ifr, cmd);
+	if (!ret)
+		mv643xx_adjust_pscr(mp);
+	return ret;
 }
 
 static int mv643xx_eth_change_mtu(struct net_device *dev, int new_mtu)
-- 
1.7.3.4
