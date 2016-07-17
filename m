From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 2/2] net: ethernet: marvell: pxa168_eth: use phy_ethtool_{get|set}_link_ksettings
Date: Sun, 17 Jul 2016 23:30:46 +0200
Message-ID: <1468791046-19567-2-git-send-email-tremyfr@gmail.com>
References: <1468791046-19567-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, jszhang@marvell.com,
	sergei.shtylyov@cogentembedded.com, mugunthanvnm@ti.com,
	a@unstable.cc, fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33472 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751198AbcGQVa4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jul 2016 17:30:56 -0400
In-Reply-To: <1468791046-19567-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are two generics functions phy_ethtool_{get|set}_link_ksettings,
so we can use them instead of defining the same code in the driver.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/marvell/pxa168_eth.c |   39 +++++++++++++---------------
 1 files changed, 18 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index d466326..aeeb2e7 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -274,8 +274,8 @@ enum hash_table_entry {
 	HASH_ENTRY_RECEIVE_DISCARD_BIT = 2
 };
 
-static int pxa168_get_settings(struct net_device *dev, struct ethtool_cmd *cmd);
-static int pxa168_set_settings(struct net_device *dev, struct ethtool_cmd *cmd);
+static int pxa168_get_link_ksettings(struct net_device *dev,
+				     struct ethtool_link_ksettings *cmd);
 static int pxa168_init_hw(struct pxa168_eth_private *pep);
 static int pxa168_init_phy(struct net_device *dev);
 static void eth_port_reset(struct net_device *dev);
@@ -971,7 +971,7 @@ static void pxa168_eth_adjust_link(struct net_device *dev)
 static int pxa168_init_phy(struct net_device *dev)
 {
 	struct pxa168_eth_private *pep = netdev_priv(dev);
-	struct ethtool_cmd cmd;
+	struct ethtool_link_ksettings cmd;
 	struct phy_device *phy = NULL;
 	int err;
 
@@ -987,20 +987,21 @@ static int pxa168_init_phy(struct net_device *dev)
 	if (err)
 		return err;
 
-	err = pxa168_get_settings(dev, &cmd);
+	err = pxa168_get_link_ksettings(dev, &cmd);
 	if (err)
 		return err;
 
-	cmd.phy_address = pep->phy_addr;
-	cmd.speed = pep->phy_speed;
-	cmd.duplex = pep->phy_duplex;
-	cmd.advertising = PHY_BASIC_FEATURES;
-	cmd.autoneg = AUTONEG_ENABLE;
+	cmd.base.phy_address = pep->phy_addr;
+	cmd.base.speed = pep->phy_speed;
+	cmd.base.duplex = pep->phy_duplex;
+	ethtool_convert_legacy_u32_to_link_mode(cmd.link_modes.advertising,
+						PHY_BASIC_FEATURES);
+	cmd.base.autoneg = AUTONEG_ENABLE;
 
-	if (cmd.speed != 0)
-		cmd.autoneg = AUTONEG_DISABLE;
+	if (cmd.base.speed != 0)
+		cmd.base.autoneg = AUTONEG_DISABLE;
 
-	return pxa168_set_settings(dev, &cmd);
+	return phy_ethtool_set_link_ksettings(dev, &cmd);
 }
 
 static int pxa168_init_hw(struct pxa168_eth_private *pep)
@@ -1372,22 +1373,18 @@ static int pxa168_eth_do_ioctl(struct net_device *dev, struct ifreq *ifr,
 	return -EOPNOTSUPP;
 }
 
-static int pxa168_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int pxa168_get_link_ksettings(struct net_device *dev,
+				     struct ethtool_link_ksettings *cmd)
 {
 	int err;
 
 	err = phy_read_status(dev->phydev);
 	if (err == 0)
-		err = phy_ethtool_gset(dev->phydev, cmd);
+		err = phy_ethtool_ksettings_get(dev->phydev, cmd);
 
 	return err;
 }
 
-static int pxa168_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
-{
-	return phy_ethtool_sset(dev->phydev, cmd);
-}
-
 static void pxa168_get_drvinfo(struct net_device *dev,
 			       struct ethtool_drvinfo *info)
 {
@@ -1398,11 +1395,11 @@ static void pxa168_get_drvinfo(struct net_device *dev,
 }
 
 static const struct ethtool_ops pxa168_ethtool_ops = {
-	.get_settings	= pxa168_get_settings,
-	.set_settings	= pxa168_set_settings,
 	.get_drvinfo	= pxa168_get_drvinfo,
 	.get_link	= ethtool_op_get_link,
 	.get_ts_info	= ethtool_op_get_ts_info,
+	.get_link_ksettings = pxa168_get_link_ksettings,
+	.set_link_ksettings = phy_ethtool_set_link_ksettings,
 };
 
 static const struct net_device_ops pxa168_eth_netdev_ops = {
-- 
1.7.4.4
