From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: cris: eth_v10: use new api ethtool_{get|set}_link_ksettings
Date: Sat, 25 Mar 2017 19:39:05 +0100
Message-ID: <1490467145-32724-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, paul.gortmaker@windriver.com,
        mugunthanvnm@ti.com, a@unstable.cc, fw@strlen.de, jarod@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/cris/eth_v10.c |   32 ++++++++++++++++++++------------
 1 files changed, 20 insertions(+), 12 deletions(-)

diff --git a/drivers/net/cris/eth_v10.c b/drivers/net/cris/eth_v10.c
index 91c876a..da02041 100644
--- a/drivers/net/cris/eth_v10.c
+++ b/drivers/net/cris/eth_v10.c
@@ -1412,31 +1412,39 @@ struct transceiver_ops transceivers[] =
 	return rc;
 }
 
-static int e100_get_settings(struct net_device *dev,
-			     struct ethtool_cmd *cmd)
+static int e100_get_link_ksettings(struct net_device *dev,
+				   struct ethtool_link_ksettings *cmd)
 {
 	struct net_local *np = netdev_priv(dev);
+	u32 supported;
 	int err;
 
 	spin_lock_irq(&np->lock);
-	err = mii_ethtool_gset(&np->mii_if, cmd);
+	err = mii_ethtool_get_link_ksettings(&np->mii_if, cmd);
 	spin_unlock_irq(&np->lock);
 
 	/* The PHY may support 1000baseT, but the Etrax100 does not.  */
-	cmd->supported &= ~(SUPPORTED_1000baseT_Half
-			    | SUPPORTED_1000baseT_Full);
+	ethtool_convert_link_mode_to_legacy_u32(&supported,
+						cmd->link_modes.supported);
+
+	supported &= ~(SUPPORTED_1000baseT_Half | SUPPORTED_1000baseT_Full);
+
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
+						supported);
+
 	return err;
 }
 
-static int e100_set_settings(struct net_device *dev,
-			     struct ethtool_cmd *ecmd)
+static int e100_set_link_ksettings(struct net_device *dev,
+				   const struct ethtool_link_ksettings *ecmd)
 {
-	if (ecmd->autoneg == AUTONEG_ENABLE) {
+	if (ecmd->base.autoneg == AUTONEG_ENABLE) {
 		e100_set_duplex(dev, autoneg);
 		e100_set_speed(dev, 0);
 	} else {
-		e100_set_duplex(dev, ecmd->duplex == DUPLEX_HALF ? half : full);
-		e100_set_speed(dev, ecmd->speed == SPEED_10 ? 10: 100);
+		e100_set_duplex(dev, ecmd->base.duplex == DUPLEX_HALF ?
+				half : full);
+		e100_set_speed(dev, ecmd->base.speed == SPEED_10 ? 10 : 100);
 	}
 
 	return 0;
@@ -1459,11 +1467,11 @@ static int e100_nway_reset(struct net_device *dev)
 }
 
 static const struct ethtool_ops e100_ethtool_ops = {
-	.get_settings	= e100_get_settings,
-	.set_settings	= e100_set_settings,
 	.get_drvinfo	= e100_get_drvinfo,
 	.nway_reset	= e100_nway_reset,
 	.get_link	= ethtool_op_get_link,
+	.get_link_ksettings	= e100_get_link_ksettings,
+	.set_link_ksettings	= e100_set_link_ksettings,
 };
 
 static int
-- 
1.7.4.4
