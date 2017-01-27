From: Timur Tabi <timur@codeaurora.org>
Subject: [PATCH 2/5] [net-next] net: qcom/emac: always use autonegotiation to configure the SGMII link
Date: Fri, 27 Jan 2017 16:43:44 -0600
Message-ID: <1485557028-32510-3-git-send-email-timur@codeaurora.org>
References: <1485557028-32510-1-git-send-email-timur@codeaurora.org>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:57204 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750762AbdA0Wzf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 17:55:35 -0500
In-Reply-To: <1485557028-32510-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Regardless of how the external PHY is configured, the internal PHY
(the "SGMII" block) is capable of configuring the SGMII link automatically.
When the external PHY link comes up, regardless of how it is configured,
the SGMII link is configured automatically.

Signed-off-by: Timur Tabi <timur@codeaurora.org>
---
 drivers/net/ethernet/qualcomm/emac/emac-sgmii.c | 49 +++++--------------------
 1 file changed, 10 insertions(+), 39 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/emac/emac-sgmii.c b/drivers/net/ethernet/qualcomm/emac/emac-sgmii.c
index 0149b52..b5269c4 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac-sgmii.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac-sgmii.c
@@ -47,44 +47,19 @@
 
 #define SERDES_START_WAIT_TIMES			100
 
-static int emac_sgmii_link_init(struct emac_adapter *adpt)
+/* Initialize the SGMII link between the internal and external PHYs. */
+static void emac_sgmii_link_init(struct emac_adapter *adpt)
 {
-	struct phy_device *phydev = adpt->phydev;
 	struct emac_sgmii *phy = &adpt->phy;
 	u32 val;
 
+	/* Always use autonegotiation. It works no matter how the external
+	 * PHY is configured.
+	 */
 	val = readl(phy->base + EMAC_SGMII_PHY_AUTONEG_CFG2);
-
-	if (phydev->autoneg == AUTONEG_ENABLE) {
-		val &= ~(FORCE_AN_RX_CFG | FORCE_AN_TX_CFG);
-		val |= AN_ENABLE;
-		writel(val, phy->base + EMAC_SGMII_PHY_AUTONEG_CFG2);
-	} else {
-		u32 speed_cfg;
-
-		switch (phydev->speed) {
-		case SPEED_10:
-			speed_cfg = SPDMODE_10;
-			break;
-		case SPEED_100:
-			speed_cfg = SPDMODE_100;
-			break;
-		case SPEED_1000:
-			speed_cfg = SPDMODE_1000;
-			break;
-		default:
-			return -EINVAL;
-		}
-
-		if (phydev->duplex == DUPLEX_FULL)
-			speed_cfg |= DUPLEX_MODE;
-
-		val &= ~AN_ENABLE;
-		writel(speed_cfg, phy->base + EMAC_SGMII_PHY_SPEED_CFG1);
-		writel(val, phy->base + EMAC_SGMII_PHY_AUTONEG_CFG2);
-	}
-
-	return 0;
+	val &= ~(FORCE_AN_RX_CFG | FORCE_AN_TX_CFG);
+	val |= AN_ENABLE;
+	writel(val, phy->base + EMAC_SGMII_PHY_AUTONEG_CFG2);
 }
 
 static int emac_sgmii_irq_clear(struct emac_adapter *adpt, u32 irq_bits)
@@ -145,12 +120,7 @@ void emac_sgmii_reset(struct emac_adapter *adpt)
 	int ret;
 
 	emac_sgmii_reset_prepare(adpt);
-
-	ret = emac_sgmii_link_init(adpt);
-	if (ret) {
-		netdev_err(adpt->netdev, "unsupported link speed\n");
-		return;
-	}
+	emac_sgmii_link_init(adpt);
 
 	ret = adpt->phy.initialize(adpt);
 	if (ret)
@@ -287,6 +257,7 @@ int emac_sgmii_config(struct platform_device *pdev, struct emac_adapter *adpt)
 		goto error;
 
 	emac_sgmii_irq_clear(adpt, SGMII_PHY_INTERRUPT_ERR);
+	emac_sgmii_link_init(adpt);
 
 	/* We've remapped the addresses, so we don't need the device any
 	 * more.  of_find_device_by_node() says we should release it.
-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
