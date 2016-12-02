From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next 8/8] drivers: net: xgene: ethtool: Add get/set_pauseparam
Date: Thu,  1 Dec 2016 16:41:44 -0800
Message-ID: <1480639304-18757-9-git-send-email-isubramanian@apm.com>
References: <1480639304-18757-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
        Iyappan Subramanian <isubramanian@apm.com>,
        Quan Nguyen <qnguyen@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:33538 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757758AbcLBAkw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 19:40:52 -0500
Received: by mail-pg0-f43.google.com with SMTP id 3so100724356pgd.0
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 16:40:52 -0800 (PST)
In-Reply-To: <1480639304-18757-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds get_pauseparam and set_pauseparam functions.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Quan Nguyen <qnguyen@apm.com>
---
 .../net/ethernet/apm/xgene/xgene_enet_ethtool.c    | 70 ++++++++++++++++++++++
 1 file changed, 70 insertions(+)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c b/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c
index d372d42..28fdedc 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c
@@ -163,6 +163,74 @@ static void xgene_get_ethtool_stats(struct net_device *ndev,
 		*data++ = *(u64 *)(pdata + gstrings_stats[i].offset);
 }
 
+static void xgene_get_pauseparam(struct net_device *ndev,
+				 struct ethtool_pauseparam *pp)
+{
+	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
+
+	pp->autoneg = pdata->pause_autoneg;
+	pp->tx_pause = pdata->tx_pause;
+	pp->rx_pause = pdata->rx_pause;
+}
+
+static int xgene_set_pauseparam(struct net_device *ndev,
+				struct ethtool_pauseparam *pp)
+{
+	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
+	struct phy_device *phydev = ndev->phydev;
+	u32 oldadv, newadv;
+
+	if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII ||
+	    pdata->phy_mode == PHY_INTERFACE_MODE_SGMII) {
+		if (!phydev)
+			return -EINVAL;
+
+		if (!(phydev->supported & SUPPORTED_Pause) ||
+		    (!(phydev->supported & SUPPORTED_Asym_Pause) &&
+		     pp->rx_pause != pp->tx_pause))
+			return -EINVAL;
+
+		pdata->pause_autoneg = pp->autoneg;
+		pdata->tx_pause = pp->tx_pause;
+		pdata->rx_pause = pp->rx_pause;
+
+		oldadv = phydev->advertising;
+		newadv = oldadv & ~(ADVERTISED_Pause | ADVERTISED_Asym_Pause);
+
+		if (pp->rx_pause)
+			newadv |= ADVERTISED_Pause | ADVERTISED_Asym_Pause;
+
+		if (pp->tx_pause)
+			newadv ^= ADVERTISED_Asym_Pause;
+
+		if (oldadv ^ newadv) {
+			phydev->advertising = newadv;
+
+			if (phydev->autoneg)
+				return phy_start_aneg(phydev);
+
+			if (!pp->autoneg) {
+				pdata->mac_ops->flowctl_tx(pdata,
+							   pdata->tx_pause);
+				pdata->mac_ops->flowctl_rx(pdata,
+							   pdata->rx_pause);
+			}
+		}
+
+	} else {
+		if (pp->autoneg)
+			return -EINVAL;
+
+		pdata->tx_pause = pp->tx_pause;
+		pdata->rx_pause = pp->rx_pause;
+
+		pdata->mac_ops->flowctl_tx(pdata, pdata->tx_pause);
+		pdata->mac_ops->flowctl_rx(pdata, pdata->rx_pause);
+	}
+
+	return 0;
+}
+
 static const struct ethtool_ops xgene_ethtool_ops = {
 	.get_drvinfo = xgene_get_drvinfo,
 	.get_link = ethtool_op_get_link,
@@ -171,6 +239,8 @@ static void xgene_get_ethtool_stats(struct net_device *ndev,
 	.get_ethtool_stats = xgene_get_ethtool_stats,
 	.get_link_ksettings = xgene_get_link_ksettings,
 	.set_link_ksettings = xgene_set_link_ksettings,
+	.get_pauseparam = xgene_get_pauseparam,
+	.set_pauseparam = xgene_set_pauseparam
 };
 
 void xgene_enet_set_ethtool_ops(struct net_device *ndev)
-- 
1.9.1
