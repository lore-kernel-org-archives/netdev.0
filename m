From: Timur Tabi <timur@codeaurora.org>
Subject: [PATCH 3/3] net: qcom/emac: add support for emulation systems
Date: Fri, 23 Jun 2017 14:33:30 -0500
Message-ID: <1498246410-29794-4-git-send-email-timur@codeaurora.org>
References: <1498246410-29794-1-git-send-email-timur@codeaurora.org>
Cc: timur@codeaurora.org
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:50308 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754807AbdFWTdg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 15:33:36 -0400
In-Reply-To: <1498246410-29794-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On emulation systems, the EMAC's internal PHY ("SGMII") is not present,
but is not needed for network functionality.  So just display a warning
message and ignore the SGMII.

Tested-by: Philip Elcan <pelcan@codeaurora.org>
Tested-by: Adam Wallis <awallis@codeaurora.org>
Signed-off-by: Timur Tabi <timur@codeaurora.org>
---
 drivers/net/ethernet/qualcomm/emac/emac-sgmii.c | 23 +++++++++++++++++++++--
 1 file changed, 21 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/emac/emac-sgmii.c b/drivers/net/ethernet/qualcomm/emac/emac-sgmii.c
index 18c184e..29ba37a 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac-sgmii.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac-sgmii.c
@@ -297,6 +297,14 @@ static int emac_sgmii_acpi_match(struct device *dev, void *data)
 	{}
 };
 
+/* Dummy function for systems without an internal PHY. This avoids having
+ * to check for NULL pointers before calling the functions.
+ */
+static int emac_sgmii_dummy(struct emac_adapter *adpt)
+{
+	return 0;
+}
+
 int emac_sgmii_config(struct platform_device *pdev, struct emac_adapter *adpt)
 {
 	struct platform_device *sgmii_pdev = NULL;
@@ -311,8 +319,19 @@ int emac_sgmii_config(struct platform_device *pdev, struct emac_adapter *adpt)
 					emac_sgmii_acpi_match);
 
 		if (!dev) {
-			dev_err(&pdev->dev, "cannot find internal phy node\n");
-			return -ENODEV;
+			dev_warn(&pdev->dev, "cannot find internal phy node\n");
+			/* There is typically no internal PHY on emulation
+			 * systems, so if we can't find the node, assume
+			 * we are on an emulation system and stub-out
+			 * support for the internal PHY.  These systems only
+			 * use ACPI.
+			 */
+			phy->open = emac_sgmii_dummy;
+			phy->close = emac_sgmii_dummy;
+			phy->link_up = emac_sgmii_dummy;
+			phy->link_down = emac_sgmii_dummy;
+
+			return 0;
 		}
 
 		sgmii_pdev = to_platform_device(dev);
-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
