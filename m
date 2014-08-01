From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next 1/2] amd-xgbe: Remove unnecessary spinlocks
Date: Fri, 1 Aug 2014 11:56:29 -0500
Message-ID: <20140801165629.20602.64450.stgit@tlendack-t1.amdoffice.net>
References: <20140801165623.20602.457.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1blp0181.outbound.protection.outlook.com ([207.46.163.181]:54252
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751204AbaHAQ4g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Aug 2014 12:56:36 -0400
In-Reply-To: <20140801165623.20602.457.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the spinlocks around the ethtool get and set settings
functions and within the link adjustment callback routine.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c |   20 +++++---------------
 drivers/net/ethernet/amd/xgbe/xgbe-mdio.c    |    5 -----
 2 files changed, 5 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c b/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
index 6005b60..a076aca 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
@@ -290,13 +290,9 @@ static int xgbe_get_settings(struct net_device *netdev,
 	if (!pdata->phydev)
 		return -ENODEV;
 
-	spin_lock_irq(&pdata->lock);
-
 	ret = phy_ethtool_gset(pdata->phydev, cmd);
 	cmd->transceiver = XCVR_EXTERNAL;
 
-	spin_unlock_irq(&pdata->lock);
-
 	DBGPR("<--xgbe_get_settings\n");
 
 	return ret;
@@ -315,17 +311,14 @@ static int xgbe_set_settings(struct net_device *netdev,
 	if (!pdata->phydev)
 		return -ENODEV;
 
-	spin_lock_irq(&pdata->lock);
-
 	speed = ethtool_cmd_speed(cmd);
 
-	ret = -EINVAL;
 	if (cmd->phy_address != phydev->addr)
-		goto unlock;
+		return -EINVAL;
 
 	if ((cmd->autoneg != AUTONEG_ENABLE) &&
 	    (cmd->autoneg != AUTONEG_DISABLE))
-		goto unlock;
+		return -EINVAL;
 
 	if (cmd->autoneg == AUTONEG_DISABLE) {
 		switch (speed) {
@@ -334,16 +327,16 @@ static int xgbe_set_settings(struct net_device *netdev,
 		case SPEED_1000:
 			break;
 		default:
-			goto unlock;
+			return -EINVAL;
 		}
 
 		if (cmd->duplex != DUPLEX_FULL)
-			goto unlock;
+			return -EINVAL;
 	}
 
 	cmd->advertising &= phydev->supported;
 	if ((cmd->autoneg == AUTONEG_ENABLE) && !cmd->advertising)
-		goto unlock;
+		return -EINVAL;
 
 	ret = 0;
 	phydev->autoneg = cmd->autoneg;
@@ -359,9 +352,6 @@ static int xgbe_set_settings(struct net_device *netdev,
 	if (netif_running(netdev))
 		ret = phy_start_aneg(phydev);
 
-unlock:
-	spin_unlock_irq(&pdata->lock);
-
 	DBGPR("<--xgbe_set_settings\n");
 
 	return ret;
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c b/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
index 225f22d..eecd360 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
@@ -163,7 +163,6 @@ static void xgbe_adjust_link(struct net_device *netdev)
 	struct xgbe_prv_data *pdata = netdev_priv(netdev);
 	struct xgbe_hw_if *hw_if = &pdata->hw_if;
 	struct phy_device *phydev = pdata->phydev;
-	unsigned long flags;
 	int new_state = 0;
 
 	if (phydev == NULL)
@@ -172,8 +171,6 @@ static void xgbe_adjust_link(struct net_device *netdev)
 	DBGPR_MDIO("-->xgbe_adjust_link: address=%d, newlink=%d, curlink=%d\n",
 		   phydev->addr, phydev->link, pdata->phy_link);
 
-	spin_lock_irqsave(&pdata->lock, flags);
-
 	if (phydev->link) {
 		/* Flow control support */
 		if (pdata->pause_autoneg) {
@@ -229,8 +226,6 @@ static void xgbe_adjust_link(struct net_device *netdev)
 	if (new_state)
 		phy_print_status(phydev);
 
-	spin_unlock_irqrestore(&pdata->lock, flags);
-
 	DBGPR_MDIO("<--xgbe_adjust_link\n");
 }
 
