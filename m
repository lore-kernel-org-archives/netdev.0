From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 38/39] mv643xx_eth: add PHY-less mode
Date: Tue,  3 Jun 2008 13:02:53 +0200
Message-ID: <1212490974-23719-39-git-send-email-buytenh@wantstofly.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Cc: netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:48750 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753018AbYFCMA1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 08:00:27 -0400
In-Reply-To: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On some boards, the mv643xx_eth MAC isn't connected to a PHY but
directly (via the MII/GMII/RGMII interface) to another MAC-layer
device.  This patch allows specifying ->phy_addr = -1 to skip all
PHY-related initialisation and run-time poking in that case.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |   87 ++++++++++++++++++++++++++++++++++++++-------
 1 files changed, 74 insertions(+), 13 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 54c9c76..4b6c810 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -1092,6 +1092,22 @@ static int mv643xx_eth_get_settings(struct net_device *dev, struct ethtool_cmd *
 	return err;
 }
 
+static int mv643xx_eth_get_settings_phyless(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	cmd->supported = SUPPORTED_MII;
+	cmd->advertising = ADVERTISED_MII;
+	cmd->speed = SPEED_1000;
+	cmd->duplex = DUPLEX_FULL;
+	cmd->port = PORT_MII;
+	cmd->phy_address = 0;
+	cmd->transceiver = XCVR_INTERNAL;
+	cmd->autoneg = AUTONEG_DISABLE;
+	cmd->maxtxpkt = 1;
+	cmd->maxrxpkt = 1;
+
+	return 0;
+}
+
 static int mv643xx_eth_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct mv643xx_eth_private *mep = netdev_priv(dev);
@@ -1109,6 +1125,11 @@ static int mv643xx_eth_set_settings(struct net_device *dev, struct ethtool_cmd *
 	return err;
 }
 
+static int mv643xx_eth_set_settings_phyless(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	return -EINVAL;
+}
+
 static void mv643xx_eth_get_drvinfo(struct net_device *dev,
 				    struct ethtool_drvinfo *drvinfo)
 {
@@ -1126,12 +1147,22 @@ static int mv643xx_eth_nway_reset(struct net_device *dev)
 	return mii_nway_restart(&mep->mii);
 }
 
+static int mv643xx_eth_nway_reset_phyless(struct net_device *dev)
+{
+	return -EINVAL;
+}
+
 static u32 mv643xx_eth_get_link(struct net_device *dev)
 {
 	struct mv643xx_eth_private *mep = netdev_priv(dev);
 	return mii_link_ok(&mep->mii);
 }
 
+static u32 mv643xx_eth_get_link_phyless(struct net_device *dev)
+{
+	return 1;
+}
+
 static void mv643xx_eth_get_strings(struct net_device *dev,
 				    uint32_t stringset, uint8_t *data)
 {
@@ -1191,6 +1222,18 @@ static const struct ethtool_ops mv643xx_eth_ethtool_ops = {
 	.get_sset_count		= mv643xx_eth_get_sset_count,
 };
 
+static const struct ethtool_ops mv643xx_eth_ethtool_ops_phyless = {
+	.get_settings		= mv643xx_eth_get_settings_phyless,
+	.set_settings		= mv643xx_eth_set_settings_phyless,
+	.get_drvinfo		= mv643xx_eth_get_drvinfo,
+	.nway_reset		= mv643xx_eth_nway_reset_phyless,
+	.get_link		= mv643xx_eth_get_link_phyless,
+	.set_sg			= ethtool_op_set_sg,
+	.get_strings		= mv643xx_eth_get_strings,
+	.get_ethtool_stats	= mv643xx_eth_get_ethtool_stats,
+	.get_sset_count		= mv643xx_eth_get_sset_count,
+};
+
 
 /* address handling *********************************************************/
 static void uc_addr_get(struct mv643xx_eth_private *mep, unsigned char *addr)
@@ -1637,12 +1680,16 @@ static irqreturn_t mv643xx_eth_irq(int irq, void *dev_id)
 	}
 
 	if (int_cause_ext & (INT_EXT_PHY | INT_EXT_LINK)) {
-		if (mii_link_ok(&mep->mii)) {
-			struct ethtool_cmd cmd;
+		if (mep->phy_addr == -1 || mii_link_ok(&mep->mii)) {
 			int i;
 
-			mii_ethtool_gset(&mep->mii, &cmd);
-			update_pscr(mep, cmd.speed, cmd.duplex);
+			if (mep->phy_addr != -1) {
+				struct ethtool_cmd cmd;
+
+				mii_ethtool_gset(&mep->mii, &cmd);
+				update_pscr(mep, cmd.speed, cmd.duplex);
+			}
+
 			for (i = 0; i < 8; i++)
 				if (mep->txq_mask & (1 << i))
 					txq_enable(mep->txq + i);
@@ -1732,7 +1779,6 @@ static void phy_reset(struct mv643xx_eth_private *mep)
 static void port_start(struct mv643xx_eth_private *mep)
 {
 	u32 pscr;
-	struct ethtool_cmd ethtool_cmd;
 	int i;
 
 	/*
@@ -1752,9 +1798,16 @@ static void port_start(struct mv643xx_eth_private *mep)
 
 	wrl(mep, SDMA_CONFIG(mep->port_num), PORT_SDMA_CONFIG_DEFAULT_VALUE);
 
-	mv643xx_eth_get_settings(mep->dev, &ethtool_cmd);
-	phy_reset(mep);
-	mv643xx_eth_set_settings(mep->dev, &ethtool_cmd);
+	/*
+	 * Perform PHY reset, if there is a PHY.
+	 */
+	if (mep->phy_addr != -1) {
+		struct ethtool_cmd cmd;
+
+		mv643xx_eth_get_settings(mep->dev, &cmd);
+		phy_reset(mep);
+		mv643xx_eth_set_settings(mep->dev, &cmd);
+	}
 
 	/*
 	 * Configure TX path and queues.
@@ -1971,7 +2024,10 @@ static int mv643xx_eth_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
 	struct mv643xx_eth_private *mep = netdev_priv(dev);
 
-	return generic_mii_ioctl(&mep->mii, if_mii(ifr), cmd, NULL);
+	if (mep->phy_addr != -1)
+		return generic_mii_ioctl(&mep->mii, if_mii(ifr), cmd, NULL);
+
+	return -EOPNOTSUPP;
 }
 
 static int mv643xx_eth_change_mtu(struct net_device *dev, int new_mtu)
@@ -2368,10 +2424,15 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	mib_counters_clear(mep);
 	INIT_WORK(&mep->tx_timeout_task, tx_timeout_task);
 
-	err = phy_init(mep, pd);
-	if (err)
-		goto out;
-	SET_ETHTOOL_OPS(dev, &mv643xx_eth_ethtool_ops);
+	if (mep->phy_addr != -1) {
+		err = phy_init(mep, pd);
+		if (err)
+			goto out;
+
+		SET_ETHTOOL_OPS(dev, &mv643xx_eth_ethtool_ops);
+	} else {
+		SET_ETHTOOL_OPS(dev, &mv643xx_eth_ethtool_ops_phyless);
+	}
 
 
 	res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
-- 
1.5.3.4

