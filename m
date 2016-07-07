From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v4 07/11] drivers: net: xgene: Enable MDIO driver
Date: Wed,  6 Jul 2016 17:35:08 -0700
Message-ID: <1467851712-24780-8-git-send-email-isubramanian@apm.com>
References: <1467851712-24780-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	matthias.bgg@gmail.com, andrew@lunn.ch,
	Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:33836 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932606AbcGGAf2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2016 20:35:28 -0400
Received: by mail-pf0-f177.google.com with SMTP id h14so887165pfe.1
        for <netdev@vger.kernel.org>; Wed, 06 Jul 2016 17:35:27 -0700 (PDT)
In-Reply-To: <1467851712-24780-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables MDIO driver by,

- Selecting MDIO_XGENE
- Changed open and close to use phy_start and phy_stop
- Changed to use mac_ops->tx(rx)_enable and tx(rx)_disable

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Tested-by: Fushen Chen <fchen@apm.com>
Tested-by: Toan Le <toanle@apm.com>
Tested-by: Matthias Brugger <mbrugger@suse.com>
---
 drivers/net/ethernet/apm/xgene/Kconfig           |  1 +
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c   |  8 ++++----
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 12 ++++++------
 3 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/Kconfig b/drivers/net/ethernet/apm/xgene/Kconfig
index 19e38af..300e3b5 100644
--- a/drivers/net/ethernet/apm/xgene/Kconfig
+++ b/drivers/net/ethernet/apm/xgene/Kconfig
@@ -3,6 +3,7 @@ config NET_XGENE
 	depends on HAS_DMA
 	depends on ARCH_XGENE || COMPILE_TEST
 	select PHYLIB
+	select MDIO_XGENE
 	help
 	  This is the Ethernet driver for the on-chip ethernet interface on the
 	  APM X-Gene SoC.
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
index 96f8de7..37d0c14 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
@@ -788,13 +788,13 @@ static void xgene_enet_adjust_link(struct net_device *ndev)
 		if (pdata->phy_speed != phydev->speed) {
 			pdata->phy_speed = phydev->speed;
 			mac_ops->set_speed(pdata);
-			xgene_gmac_rx_enable(pdata);
-			xgene_gmac_tx_enable(pdata);
+			mac_ops->rx_enable(pdata);
+			mac_ops->tx_enable(pdata);
 			phy_print_status(phydev);
 		}
 	} else {
-		xgene_gmac_rx_disable(pdata);
-		xgene_gmac_tx_disable(pdata);
+		mac_ops->rx_disable(pdata);
+		mac_ops->tx_disable(pdata);
 		pdata->phy_speed = SPEED_UNKNOWN;
 		phy_print_status(phydev);
 	}
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index a8693de..ed30b51 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -739,9 +739,9 @@ static int xgene_enet_open(struct net_device *ndev)
 	if (ret)
 		return ret;
 
-	if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII)
+	if (pdata->phy_dev) {
 		phy_start(pdata->phy_dev);
-	else {
+	} else {
 		schedule_delayed_work(&pdata->link_work, PHY_POLL_LINK_OFF);
 		netif_carrier_off(ndev);
 	}
@@ -756,12 +756,12 @@ static int xgene_enet_open(struct net_device *ndev)
 static int xgene_enet_close(struct net_device *ndev)
 {
 	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
-	const struct xgene_mac_ops *mac_ops = pdata->mac_ops;
 	int i;
 
-	netif_tx_stop_all_queues(ndev);
-	mac_ops->tx_disable(pdata);
-	mac_ops->rx_disable(pdata);
+	if (pdata->phy_dev)
+		phy_stop(pdata->phy_dev);
+	else
+		cancel_delayed_work_sync(&pdata->link_work);
 
 	if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII)
 		phy_stop(pdata->phy_dev);
-- 
1.9.1
