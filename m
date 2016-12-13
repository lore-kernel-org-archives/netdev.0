From: Timur Tabi <timur@codeaurora.org>
Subject: [PATCH] net: qcom/emac: don't try to claim clocks on ACPI systems
Date: Tue, 13 Dec 2016 13:55:30 -0600
Message-ID: <1481658930-565-1-git-send-email-timur@codeaurora.org>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        Christopher Covington <cov@codeaurora.org>,
        alokc@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:42860 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752409AbcLMUPK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2016 15:15:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On ACPI systems, clocks are not available to drivers directly.  They are
handled exclusively by ACPI and/or firmware, so there is no clock driver.
Calls to clk_get() always fail, so we should not even attempt to claim
any clocks on ACPI systems.

Signed-off-by: Timur Tabi <timur@codeaurora.org>
---
 drivers/net/ethernet/qualcomm/emac/emac.c | 22 ++++++++++++----------
 1 file changed, 12 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/emac/emac.c b/drivers/net/ethernet/qualcomm/emac/emac.c
index ae32f85..b1c1cdc 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac.c
@@ -627,11 +627,12 @@ static int emac_probe(struct platform_device *pdev)
 	if (ret)
 		goto err_undo_netdev;
 
-	/* initialize clocks */
-	ret = emac_clks_phase1_init(pdev, adpt);
-	if (ret) {
-		dev_err(&pdev->dev, "could not initialize clocks\n");
-		goto err_undo_netdev;
+	if (!has_acpi_companion(&pdev->dev)) {
+		ret = emac_clks_phase1_init(pdev, adpt);
+		if (ret) {
+			dev_err(&pdev->dev, "could not initialize clocks\n");
+			goto err_undo_netdev;
+		}
 	}
 
 	netdev->watchdog_timeo = EMAC_WATCHDOG_TIME;
@@ -655,11 +656,12 @@ static int emac_probe(struct platform_device *pdev)
 	if (ret)
 		goto err_undo_mdiobus;
 
-	/* enable clocks */
-	ret = emac_clks_phase2_init(pdev, adpt);
-	if (ret) {
-		dev_err(&pdev->dev, "could not initialize clocks\n");
-		goto err_undo_mdiobus;
+	if (!has_acpi_companion(&pdev->dev)) {
+		ret = emac_clks_phase2_init(pdev, adpt);
+		if (ret) {
+			dev_err(&pdev->dev, "could not initialize clocks\n");
+			goto err_undo_mdiobus;
+		}
 	}
 
 	emac_mac_reset(adpt);
-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
