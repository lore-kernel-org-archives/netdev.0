From: Timur Tabi <timur@codeaurora.org>
Subject: [PATCH] net: qcom/emac: grab a reference to the phydev on ACPI systems
Date: Mon,  9 Jan 2017 17:52:06 -0600
Message-ID: <1484005926-26673-1-git-send-email-timur@codeaurora.org>
To: David Miller <davem@davemloft.net>, johan@kernel.org,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:55418 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752468AbdAIXwK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 18:52:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 6ffe1c4cd0a7 ("net: qcom/emac: fix of_node and phydev leaks")
fixed the problem with reference leaks on phydev, but the fix is
device-tree specific.  When the driver unloads, the reference is
dropped only on DT systems.

Instead, it's cleaner if up grab an reference on ACPI systems.
When the driver unloads, we can drop the reference without having
to check whether we're on a DT system.

Signed-off-by: Timur Tabi <timur@codeaurora.org>
---
 drivers/net/ethernet/qualcomm/emac/emac-phy.c | 6 ++++++
 drivers/net/ethernet/qualcomm/emac/emac.c     | 6 ++----
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/emac/emac-phy.c b/drivers/net/ethernet/qualcomm/emac/emac-phy.c
index 99a14df..af485f1 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac-phy.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac-phy.c
@@ -201,6 +201,12 @@ int emac_phy_config(struct platform_device *pdev, struct emac_adapter *adpt)
 		else
 			adpt->phydev = mdiobus_get_phy(mii_bus, phy_addr);
 
+		/* of_phy_find_device() claims a reference to the phydev,
+		 * so we do that here manually as well. When the driver
+		 * unloads, it can unilaterally drops the reference
+		 * without worrying about ACPI vs DT.
+		 */
+		get_device(&adpt->phydev->mdio.dev);
 	} else {
 		struct device_node *phy_np;
 
diff --git a/drivers/net/ethernet/qualcomm/emac/emac.c b/drivers/net/ethernet/qualcomm/emac/emac.c
index 6ffe192..0aac0de 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac.c
@@ -729,8 +729,7 @@ static int emac_probe(struct platform_device *pdev)
 err_undo_napi:
 	netif_napi_del(&adpt->rx_q.napi);
 err_undo_mdiobus:
-	if (!has_acpi_companion(&pdev->dev))
-		put_device(&adpt->phydev->mdio.dev);
+	put_device(&adpt->phydev->mdio.dev);
 	mdiobus_unregister(adpt->mii_bus);
 err_undo_clocks:
 	emac_clks_teardown(adpt);
@@ -750,8 +749,7 @@ static int emac_remove(struct platform_device *pdev)
 
 	emac_clks_teardown(adpt);
 
-	if (!has_acpi_companion(&pdev->dev))
-		put_device(&adpt->phydev->mdio.dev);
+	put_device(&adpt->phydev->mdio.dev);
 	mdiobus_unregister(adpt->mii_bus);
 	free_netdev(netdev);
 
-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
