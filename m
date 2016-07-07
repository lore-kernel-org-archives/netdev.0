From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v5 07/11] drivers: net: xgene: Enable MDIO driver
Date: Thu,  7 Jul 2016 16:02:55 -0700
Message-ID: <1467932579-14320-8-git-send-email-isubramanian@apm.com>
References: <1467932579-14320-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	matthias.bgg@gmail.com, andrew@lunn.ch, linux@armlinux.org.uk,
	Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36482 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753457AbcGGXDD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 19:03:03 -0400
Received: by mail-pa0-f52.google.com with SMTP id uj8so9753112pab.3
        for <netdev@vger.kernel.org>; Thu, 07 Jul 2016 16:03:02 -0700 (PDT)
In-Reply-To: <1467932579-14320-1-git-send-email-isubramanian@apm.com>
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
index 8410ff8..798c007 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
@@ -794,13 +794,13 @@ static void xgene_enet_adjust_link(struct net_device *ndev)
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
