From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] Revert "net: ethernet: bcmgenet: use phy_ethtool_{get|set}_link_ksettings"
Date: Sat,  9 Jul 2016 00:54:47 +0200
Message-ID: <1468018487-8102-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: f.fainelli@gmail.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This reverts commit 4386f5662e63 ("net: ethernet: bcmgenet: use
phy_ethtool_{get|set}_link_ksettings")

This patch is wrong, the function phy_ethtool_{get|set}_link_ksettings
don't check if the device is running, but the driver bcmgenet need this
check.

The function {get|set}_settings need to access the mdio bus, and this
bus may only be used when the device is running. Otherwise, the clock
is disable and a mdio access will fail.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c |   28 ++++++++++++++++++++++-
 1 files changed, 26 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 76ed6df..8d4f849 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -450,6 +450,30 @@ static inline void bcmgenet_rdma_ring_writel(struct bcmgenet_priv *priv,
 			genet_dma_ring_regs[r]);
 }
 
+static int bcmgenet_get_settings(struct net_device *dev,
+				 struct ethtool_cmd *cmd)
+{
+	if (!netif_running(dev))
+		return -EINVAL;
+
+	if (!dev->phydev)
+		return -ENODEV;
+
+	return phy_ethtool_gset(dev->phydev, cmd);
+}
+
+static int bcmgenet_set_settings(struct net_device *dev,
+				 struct ethtool_cmd *cmd)
+{
+	if (!netif_running(dev))
+		return -EINVAL;
+
+	if (!dev->phydev)
+		return -ENODEV;
+
+	return phy_ethtool_sset(dev->phydev, cmd);
+}
+
 static int bcmgenet_set_rx_csum(struct net_device *dev,
 				netdev_features_t wanted)
 {
@@ -953,6 +977,8 @@ static struct ethtool_ops bcmgenet_ethtool_ops = {
 	.get_strings		= bcmgenet_get_strings,
 	.get_sset_count		= bcmgenet_get_sset_count,
 	.get_ethtool_stats	= bcmgenet_get_ethtool_stats,
+	.get_settings		= bcmgenet_get_settings,
+	.set_settings		= bcmgenet_set_settings,
 	.get_drvinfo		= bcmgenet_get_drvinfo,
 	.get_link		= ethtool_op_get_link,
 	.get_msglevel		= bcmgenet_get_msglevel,
@@ -964,8 +990,6 @@ static struct ethtool_ops bcmgenet_ethtool_ops = {
 	.nway_reset		= bcmgenet_nway_reset,
 	.get_coalesce		= bcmgenet_get_coalesce,
 	.set_coalesce		= bcmgenet_set_coalesce,
-	.get_link_ksettings = phy_ethtool_get_link_ksettings,
-	.set_link_ksettings = phy_ethtool_set_link_ksettings,
 };
 
 /* Power down the unimac, based on mode. */
-- 
1.7.4.4
