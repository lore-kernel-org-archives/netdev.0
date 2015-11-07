From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v2] drivers: net: xgene: fix RGMII 10/100Mb mode
Date: Sat,  7 Nov 2015 11:50:40 -0800
Message-ID: <1446925840-14224-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	fchen@apm.com, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36391 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753554AbbKGTtu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Nov 2015 14:49:50 -0500
Received: by pacdm15 with SMTP id dm15so132159484pac.3
        for <netdev@vger.kernel.org>; Sat, 07 Nov 2015 11:49:49 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the RGMII 10/100M mode by reprogramming the clock.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Tested-by: Fushen Chen <fchen@apm.com>
---

v2: Address v1 review comments
	- targeting bug fix patch to "net" tree

v1: Initial revision
---

 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c   | 49 +++++++++++++++++++++++-
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h   |  1 +
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c |  1 -
 3 files changed, 48 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
index 33850a0..c31e691 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
@@ -459,6 +459,45 @@ static void xgene_gmac_reset(struct xgene_enet_pdata *pdata)
 	xgene_enet_wr_mcx_mac(pdata, MAC_CONFIG_1_ADDR, 0);
 }
 
+static void xgene_enet_configure_clock(struct xgene_enet_pdata *pdata)
+{
+	struct device *dev = &pdata->pdev->dev;
+
+	if (dev->of_node) {
+		struct clk *parent = clk_get_parent(pdata->clk);
+
+		switch (pdata->phy_speed) {
+		case SPEED_10:
+			clk_set_rate(parent, 2500000);
+			break;
+		case SPEED_100:
+			clk_set_rate(parent, 25000000);
+			break;
+		default:
+			clk_set_rate(parent, 125000000);
+			break;
+		}
+	}
+#ifdef CONFIG_ACPI
+	else {
+		switch (pdata->phy_speed) {
+		case SPEED_10:
+			acpi_evaluate_object(ACPI_HANDLE(dev),
+					     "S10", NULL, NULL);
+			break;
+		case SPEED_100:
+			acpi_evaluate_object(ACPI_HANDLE(dev),
+					     "S100", NULL, NULL);
+			break;
+		default:
+			acpi_evaluate_object(ACPI_HANDLE(dev),
+					     "S1G", NULL, NULL);
+			break;
+		}
+	}
+#endif
+}
+
 static void xgene_gmac_init(struct xgene_enet_pdata *pdata)
 {
 	struct device *dev = &pdata->pdev->dev;
@@ -477,12 +516,14 @@ static void xgene_gmac_init(struct xgene_enet_pdata *pdata)
 	switch (pdata->phy_speed) {
 	case SPEED_10:
 		ENET_INTERFACE_MODE2_SET(&mc2, 1);
+		intf_ctl &= ~(ENET_LHD_MODE | ENET_GHD_MODE);
 		CFG_MACMODE_SET(&icm0, 0);
 		CFG_WAITASYNCRD_SET(&icm2, 500);
 		rgmii &= ~CFG_SPEED_1250;
 		break;
 	case SPEED_100:
 		ENET_INTERFACE_MODE2_SET(&mc2, 1);
+		intf_ctl &= ~ENET_GHD_MODE;
 		intf_ctl |= ENET_LHD_MODE;
 		CFG_MACMODE_SET(&icm0, 1);
 		CFG_WAITASYNCRD_SET(&icm2, 80);
@@ -490,12 +531,15 @@ static void xgene_gmac_init(struct xgene_enet_pdata *pdata)
 		break;
 	default:
 		ENET_INTERFACE_MODE2_SET(&mc2, 2);
+		intf_ctl &= ~ENET_LHD_MODE;
 		intf_ctl |= ENET_GHD_MODE;
-
+		CFG_MACMODE_SET(&icm0, 2);
+		CFG_WAITASYNCRD_SET(&icm2, 0);
 		if (dev->of_node) {
 			CFG_TXCLK_MUXSEL0_SET(&rgmii, pdata->tx_delay);
 			CFG_RXCLK_MUXSEL0_SET(&rgmii, pdata->rx_delay);
 		}
+		rgmii |= CFG_SPEED_1250;
 
 		xgene_enet_rd_csr(pdata, DEBUG_REG_ADDR, &value);
 		value |= CFG_BYPASS_UNISEC_TX | CFG_BYPASS_UNISEC_RX;
@@ -503,7 +547,7 @@ static void xgene_gmac_init(struct xgene_enet_pdata *pdata)
 		break;
 	}
 
-	mc2 |= FULL_DUPLEX2;
+	mc2 |= FULL_DUPLEX2 | PAD_CRC;
 	xgene_enet_wr_mcx_mac(pdata, MAC_CONFIG_2_ADDR, mc2);
 	xgene_enet_wr_mcx_mac(pdata, INTERFACE_CONTROL_ADDR, intf_ctl);
 
@@ -522,6 +566,7 @@ static void xgene_gmac_init(struct xgene_enet_pdata *pdata)
 	/* Rtype should be copied from FP */
 	xgene_enet_wr_csr(pdata, RSIF_RAM_DBG_REG0_ADDR, 0);
 	xgene_enet_wr_csr(pdata, RGMII_REG_0_ADDR, rgmii);
+	xgene_enet_configure_clock(pdata);
 
 	/* Rx-Tx traffic resume */
 	xgene_enet_wr_csr(pdata, CFG_LINK_AGGR_RESUME_0_ADDR, TX_PORT0);
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
index 6dee73c..c153a1d 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
@@ -181,6 +181,7 @@ enum xgene_enet_rm {
 #define ENET_LHD_MODE			BIT(25)
 #define ENET_GHD_MODE			BIT(26)
 #define FULL_DUPLEX2			BIT(0)
+#define PAD_CRC				BIT(2)
 #define SCAN_AUTO_INCR			BIT(5)
 #define TBYT_ADDR			0x38
 #define TPKT_ADDR			0x39
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index ce10687..991412c 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -698,7 +698,6 @@ static int xgene_enet_open(struct net_device *ndev)
 	else
 		schedule_delayed_work(&pdata->link_work, PHY_POLL_LINK_OFF);
 
-	netif_carrier_off(ndev);
 	netif_start_queue(ndev);
 
 	return ret;
-- 
1.9.1
