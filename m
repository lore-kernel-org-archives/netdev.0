From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v6 07/12] drivers: net: xgene: Enable MDIO driver
Date: Wed, 20 Jul 2016 23:59:25 -0700
Message-ID: <1469084370-16781-8-git-send-email-isubramanian@apm.com>
References: <1469084370-16781-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	linux@armlinux.org.uk, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35769 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751490AbcGUG7M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2016 02:59:12 -0400
Received: by mail-pa0-f52.google.com with SMTP id iw10so26138925pac.2
        for <netdev@vger.kernel.org>; Wed, 20 Jul 2016 23:59:12 -0700 (PDT)
In-Reply-To: <1469084370-16781-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables MDIO driver by,

- Selecting MDIO_XGENE
- Changed open and close to use phy_start and phy_stop
- Changed to use mac_ops->tx(rx)_enable and tx(rx)_disable

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Tested-by: Fushen Chen <fchen@apm.com>
Tested-by: Toan Le <toanle@apm.com>
---
 drivers/net/ethernet/apm/xgene/Kconfig           | 1 +
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c   | 8 ++++----
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 4 ++--
 3 files changed, 7 insertions(+), 6 deletions(-)

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
index b8b643f..27a7a1c 100644
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
index 6398337..d1d6b5e 100644
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
-- 
1.9.1
