From: Simon Baatz <gmbnomis@gmail.com>
Subject: [PATCH 2/2] mv643xx_eth: defer probing if Marvell Orion MDIO driver not loaded
Date: Sun, 24 Mar 2013 21:34:00 +0100
Message-ID: <1364157240-28883-3-git-send-email-gmbnomis@gmail.com>
References: <1364157240-28883-1-git-send-email-gmbnomis@gmail.com>
Cc: jason@lakedaemon.net, andrew@lunn.ch, davem@davemloft.net,
	Simon Baatz <gmbnomis@gmail.com>
To: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, florian@openwrt.org,
	thomas.petazzoni@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:57532 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753869Ab3CXUet (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Mar 2013 16:34:49 -0400
In-Reply-To: <1364157240-28883-1-git-send-email-gmbnomis@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When both the Marvell MV643XX ethernet driver and the Orion MDIO driver
are compiled as modules, the ethernet driver may be probed before the
MDIO driver.  Let mv643xx_eth_probe() return EPROBE_DEFER in this case,
i.e. when it cannot find the PHY.

Signed-off-by: Simon Baatz <gmbnomis@gmail.com>
---
 drivers/net/ethernet/marvell/mv643xx_eth.c |   12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index a65a92e..aedbd82 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -2681,7 +2681,7 @@ static struct phy_device *phy_scan(struct mv643xx_eth_private *mp,
 	}
 
 	/* Attempt to connect to the PHY using orion-mdio */
-	phydev = NULL;
+	phydev = ERR_PTR(-ENODEV);
 	for (i = 0; i < num; i++) {
 		int addr = (start + i) & 0x1f;
 
@@ -2812,11 +2812,17 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	netif_set_real_num_tx_queues(dev, mp->txq_count);
 	netif_set_real_num_rx_queues(dev, mp->rxq_count);
 
-	if (pd->phy_addr != MV643XX_ETH_PHY_NONE)
+	if (pd->phy_addr != MV643XX_ETH_PHY_NONE) {
 		mp->phy = phy_scan(mp, pd->phy_addr);
 
-	if (mp->phy != NULL)
+		if (IS_ERR(mp->phy)) {
+			err = PTR_ERR(mp->phy);
+			if (err == -ENODEV)
+				err = -EPROBE_DEFER;
+			goto out;
+		}
 		phy_init(mp, pd->speed, pd->duplex);
+	}
 
 	SET_ETHTOOL_OPS(dev, &mv643xx_eth_ethtool_ops);
 
-- 
1.7.9.5
