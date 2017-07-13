From: Timur Tabi <timur@codeaurora.org>
Subject: [PATCH] [for 4.13] net: qcom/emac: fix double free of SGMII IRQ during shutdown
Date: Thu, 13 Jul 2017 15:45:41 -0500
Message-ID: <1499978741-16451-1-git-send-email-timur@codeaurora.org>
Cc: timur@codeaurora.org
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:33832 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753173AbdGMUqp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Jul 2017 16:46:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the interface is not up, then don't try to close it during a
shutdown.  This avoids possible double free of the IRQ, which
can happen during a shutdown.

Fixes: 03eb3eb4d4d5 ("net: qcom/emac: add shutdown function")
Signed-off-by: Timur Tabi <timur@codeaurora.org>
---
 drivers/net/ethernet/qualcomm/emac/emac.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/emac/emac.c b/drivers/net/ethernet/qualcomm/emac/emac.c
index 746d94e..60850bf 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac.c
@@ -766,11 +766,13 @@ static void emac_shutdown(struct platform_device *pdev)
 	struct emac_adapter *adpt = netdev_priv(netdev);
 	struct emac_sgmii *sgmii = &adpt->phy;
 
-	/* Closing the SGMII turns off its interrupts */
-	sgmii->close(adpt);
+	if (netdev->flags & IFF_UP) {
+		/* Closing the SGMII turns off its interrupts */
+		sgmii->close(adpt);
 
-	/* Resetting the MAC turns off all DMA and its interrupts */
-	emac_mac_reset(adpt);
+		/* Resetting the MAC turns off all DMA and its interrupts */
+		emac_mac_reset(adpt);
+	}
 }
 
 static struct platform_driver emac_platform_driver = {
-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
