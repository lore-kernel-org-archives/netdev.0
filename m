From: Timur Tabi <timur@codeaurora.org>
Subject: [PATCH 1/5] [net-next] net: qcom/emac: display the phy driver info after we connect
Date: Fri, 27 Jan 2017 16:43:43 -0600
Message-ID: <1485557028-32510-2-git-send-email-timur@codeaurora.org>
References: <1485557028-32510-1-git-send-email-timur@codeaurora.org>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:57234 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750851AbdA0Wzl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 17:55:41 -0500
In-Reply-To: <1485557028-32510-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PHY driver is attached only when the driver calls
phy_connect_direct().  Calling phy_attached_print() to display
information about the PHY driver prior to that point is meaningless.
The interface can be brought down, a new PHY driver can be loaded,
and the interface then brought back up.  This is the correct time
to display information about the attached driver.

Since phy_attached_print() also prints information about the
interrupt, that needs to be set as well.

Signed-off-by: Timur Tabi <timur@codeaurora.org>
---
 drivers/net/ethernet/qualcomm/emac/emac-mac.c | 4 +++-
 drivers/net/ethernet/qualcomm/emac/emac-phy.c | 3 ---
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/emac/emac-mac.c b/drivers/net/ethernet/qualcomm/emac/emac-mac.c
index e4793d7..155e273 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac-mac.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac-mac.c
@@ -981,6 +981,7 @@ int emac_mac_up(struct emac_adapter *adpt)
 	emac_mac_config(adpt);
 	emac_mac_rx_descs_refill(adpt, &adpt->rx_q);
 
+	adpt->phydev->irq = PHY_IGNORE_INTERRUPT;
 	ret = phy_connect_direct(netdev, adpt->phydev, emac_adjust_link,
 				 PHY_INTERFACE_MODE_SGMII);
 	if (ret) {
@@ -988,11 +989,12 @@ int emac_mac_up(struct emac_adapter *adpt)
 		return ret;
 	}
 
+	phy_attached_print(adpt->phydev, NULL);
+
 	/* enable mac irq */
 	writel((u32)~DIS_INT, adpt->base + EMAC_INT_STATUS);
 	writel(adpt->irq.mask, adpt->base + EMAC_INT_MASK);
 
-	adpt->phydev->irq = PHY_IGNORE_INTERRUPT;
 	phy_start(adpt->phydev);
 
 	napi_enable(&adpt->rx_q.napi);
diff --git a/drivers/net/ethernet/qualcomm/emac/emac-phy.c b/drivers/net/ethernet/qualcomm/emac/emac-phy.c
index 1d7852f..441c1936 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac-phy.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac-phy.c
@@ -226,8 +226,5 @@ int emac_phy_config(struct platform_device *pdev, struct emac_adapter *adpt)
 		return -ENODEV;
 	}
 
-	if (adpt->phydev->drv)
-		phy_attached_print(adpt->phydev, NULL);
-
 	return 0;
 }
-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
