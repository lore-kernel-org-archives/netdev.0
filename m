From: Timur Tabi <timur@codeaurora.org>
Subject: [PATCH 1/3] net: qcom/emac: add shutdown function
Date: Fri, 23 Jun 2017 14:33:28 -0500
Message-ID: <1498246410-29794-2-git-send-email-timur@codeaurora.org>
References: <1498246410-29794-1-git-send-email-timur@codeaurora.org>
Cc: timur@codeaurora.org
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:50256 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754792AbdFWTdf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 15:33:35 -0400
In-Reply-To: <1498246410-29794-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The shutdown function halts all DMA and interrupts, so that all
operations are discontinued when the system shuts down, e.g. via
kexec or a forced reboot.

Tested-by: Tyler Baicar <tbaicar@codeaurora.org>
Signed-off-by: Timur Tabi <timur@codeaurora.org>
---
 drivers/net/ethernet/qualcomm/emac/emac.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/drivers/net/ethernet/qualcomm/emac/emac.c b/drivers/net/ethernet/qualcomm/emac/emac.c
index 98a326f..77c5c92 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac.c
@@ -762,6 +762,19 @@ static int emac_remove(struct platform_device *pdev)
 	return 0;
 }
 
+static void emac_shutdown(struct platform_device *pdev)
+{
+	struct net_device *netdev = dev_get_drvdata(&pdev->dev);
+	struct emac_adapter *adpt = netdev_priv(netdev);
+	struct emac_sgmii *sgmii = &adpt->phy;
+
+	/* Closing the SGMII turns off its interrupts */
+	sgmii->close(adpt);
+
+	/* Resetting the MAC turns off all DMA and its interrupts */
+	emac_mac_reset(adpt);
+}
+
 static struct platform_driver emac_platform_driver = {
 	.probe	= emac_probe,
 	.remove	= emac_remove,
@@ -770,6 +783,7 @@ static int emac_remove(struct platform_device *pdev)
 		.of_match_table = emac_dt_match,
 		.acpi_match_table = ACPI_PTR(emac_acpi_match),
 	},
+	.shutdown = emac_shutdown,
 };
 
 module_platform_driver(emac_platform_driver);
-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
