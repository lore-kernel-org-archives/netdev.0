From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next v2 1/2] drivers: net: xgene: Add support RGMII TX/RX delay configuration
Date: Mon, 26 Oct 2015 15:25:15 -0700
Message-ID: <1445898316-21372-2-git-send-email-isubramanian@apm.com>
References: <1445898316-21372-1-git-send-email-isubramanian@apm.com>
Cc: devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	patches@apm.com, f.fainelli@gmail.com,
	Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35951 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751651AbbJZWYk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 18:24:40 -0400
Received: by pacfv9 with SMTP id fv9so209377732pac.3
        for <netdev@vger.kernel.org>; Mon, 26 Oct 2015 15:24:40 -0700 (PDT)
In-Reply-To: <1445898316-21372-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add RGMII TX/RX delay configuration support. RGMII standard requires 2ns
delay to help the RGMII bridge receiver to sample data correctly. If the
default value does not provide proper centering of the data sample, the
TX/RX delay parameters can be used to adjust accordingly.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c   |  8 +++-
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h   |  1 +
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 49 ++++++++++++++++++++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h |  2 +
 4 files changed, 59 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
index 652f218..33850a0 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
@@ -461,6 +461,7 @@ static void xgene_gmac_reset(struct xgene_enet_pdata *pdata)
 
 static void xgene_gmac_init(struct xgene_enet_pdata *pdata)
 {
+	struct device *dev = &pdata->pdev->dev;
 	u32 value, mc2;
 	u32 intf_ctl, rgmii;
 	u32 icm0, icm2;
@@ -490,7 +491,12 @@ static void xgene_gmac_init(struct xgene_enet_pdata *pdata)
 	default:
 		ENET_INTERFACE_MODE2_SET(&mc2, 2);
 		intf_ctl |= ENET_GHD_MODE;
-		CFG_TXCLK_MUXSEL0_SET(&rgmii, 4);
+
+		if (dev->of_node) {
+			CFG_TXCLK_MUXSEL0_SET(&rgmii, pdata->tx_delay);
+			CFG_RXCLK_MUXSEL0_SET(&rgmii, pdata->rx_delay);
+		}
+
 		xgene_enet_rd_csr(pdata, DEBUG_REG_ADDR, &value);
 		value |= CFG_BYPASS_UNISEC_TX | CFG_BYPASS_UNISEC_RX;
 		xgene_enet_wr_csr(pdata, DEBUG_REG_ADDR, value);
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
index ff05bbc..6dee73c 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
@@ -144,6 +144,7 @@ enum xgene_enet_rm {
 #define CFG_BYPASS_UNISEC_RX		BIT(1)
 #define CFG_CLE_BYPASS_EN0		BIT(31)
 #define CFG_TXCLK_MUXSEL0_SET(dst, val)	xgene_set_bits(dst, val, 29, 3)
+#define CFG_RXCLK_MUXSEL0_SET(dst, val)	xgene_set_bits(dst, val, 26, 3)
 
 #define CFG_CLE_IP_PROTOCOL0_SET(dst, val)	xgene_set_bits(dst, val, 16, 2)
 #define CFG_CLE_DSTQID0_SET(dst, val)		xgene_set_bits(dst, val, 0, 12)
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index 6b1846d..ce10687 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -1118,6 +1118,47 @@ static int xgene_get_port_id_dt(struct device *dev, struct xgene_enet_pdata *pda
 	return ret;
 }
 
+static int xgene_get_tx_delay(struct xgene_enet_pdata *pdata)
+{
+	struct device *dev = &pdata->pdev->dev;
+	int delay, ret;
+
+	ret = of_property_read_u32(dev->of_node, "tx-delay", &delay);
+	if (ret) {
+		pdata->tx_delay = 4;
+		return 0;
+	}
+
+	if (delay < 0 || delay > 7) {
+		dev_err(dev, "Invalid tx-delay specified\n");
+		return -EINVAL;
+	}
+
+	pdata->tx_delay = delay;
+
+	return 0;
+}
+
+static int xgene_get_rx_delay(struct xgene_enet_pdata *pdata)
+{
+	struct device *dev = &pdata->pdev->dev;
+	int delay, ret;
+
+	ret = of_property_read_u32(dev->of_node, "rx-delay", &delay);
+	if (ret) {
+		pdata->rx_delay = 2;
+		return 0;
+	}
+
+	if (delay < 0 || delay > 7) {
+		dev_err(dev, "Invalid rx-delay specified\n");
+		return -EINVAL;
+	}
+
+	pdata->rx_delay = delay;
+
+	return 0;
+}
 
 static int xgene_enet_get_resources(struct xgene_enet_pdata *pdata)
 {
@@ -1194,6 +1235,14 @@ static int xgene_enet_get_resources(struct xgene_enet_pdata *pdata)
 		return -ENODEV;
 	}
 
+	ret = xgene_get_tx_delay(pdata);
+	if (ret)
+		return ret;
+
+	ret = xgene_get_rx_delay(pdata);
+	if (ret)
+		return ret;
+
 	ret = platform_get_irq(pdev, 0);
 	if (ret <= 0) {
 		dev_err(dev, "Unable to get ENET Rx IRQ\n");
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
index ff89a5d..a6e56b8 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
@@ -184,6 +184,8 @@ struct xgene_enet_pdata {
 	u8 bp_bufnum;
 	u16 ring_num;
 	u32 mss;
+	u8 tx_delay;
+	u8 rx_delay;
 };
 
 struct xgene_indirect_ctl {
-- 
1.9.1
