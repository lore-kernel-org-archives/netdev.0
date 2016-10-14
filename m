From: Timur Tabi <timur@codeaurora.org>
Subject: [PATCH] net: qcom/emac: disable interrupts before calling phy_disconnect
Date: Fri, 14 Oct 2016 14:14:35 -0500
Message-ID: <1476472475-12104-1-git-send-email-timur@codeaurora.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:56232 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752077AbcJNTOj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 15:14:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a race condition that can occur if EMAC interrupts are
enabled when phy_disconnect() is called.  phy_disconnect() sets
adjust_link to NULL.  When an interrupt occurs, the ISR might
call phy_mac_interrupt(), which wakes up the workqueue function
phy_state_machine().  This function might reference adjust_link,
thereby causing a null pointer exception.

Signed-off-by: Timur Tabi <timur@codeaurora.org>
---
 drivers/net/ethernet/qualcomm/emac/emac-mac.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/emac/emac-mac.c b/drivers/net/ethernet/qualcomm/emac/emac-mac.c
index e97968e..6fb3bee 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac-mac.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac-mac.c
@@ -1021,14 +1021,18 @@ void emac_mac_down(struct emac_adapter *adpt)
 	napi_disable(&adpt->rx_q.napi);
 
 	phy_stop(adpt->phydev);
-	phy_disconnect(adpt->phydev);
 
-	/* disable mac irq */
+	/* Interrupts must be disabled before the PHY is disconnected, to
+	 * avoid a race condition where adjust_link is null when we get
+	 * an interrupt.
+	 */
 	writel(DIS_INT, adpt->base + EMAC_INT_STATUS);
 	writel(0, adpt->base + EMAC_INT_MASK);
 	synchronize_irq(adpt->irq.irq);
 	free_irq(adpt->irq.irq, &adpt->irq);
 
+	phy_disconnect(adpt->phydev);
+
 	emac_mac_reset(adpt);
 
 	emac_tx_q_descs_free(adpt);
-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
