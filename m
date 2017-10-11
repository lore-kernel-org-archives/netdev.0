From: Timur Tabi <timur@codeaurora.org>
Subject: [PATCH 4/4] net: qcom/emac: clean up some TX/RX error messages
Date: Wed, 11 Oct 2017 14:52:26 -0500
Message-ID: <1507751546-10265-5-git-send-email-timur@codeaurora.org>
References: <1507751546-10265-1-git-send-email-timur@codeaurora.org>
Cc: timur@codeaurora.org
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:37706 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752518AbdJKTwd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 15:52:33 -0400
In-Reply-To: <1507751546-10265-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some of the error messages that are printed by the interrupt handlers
are poorly written.  For example, many don't include a device prefix,
so there's no indication that they are EMAC errors.

Also use rate limiting for all messages that could be printed from
interrupt context.

Signed-off-by: Timur Tabi <timur@codeaurora.org>
---
 drivers/net/ethernet/qualcomm/emac/emac-sgmii.c | 15 ++++++---------
 drivers/net/ethernet/qualcomm/emac/emac.c       |  8 ++++----
 2 files changed, 10 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/emac/emac-sgmii.c b/drivers/net/ethernet/qualcomm/emac/emac-sgmii.c
index 29ba37a08372..e8ab512ee7e3 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac-sgmii.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac-sgmii.c
@@ -68,10 +68,10 @@ static void emac_sgmii_link_init(struct emac_adapter *adpt)
 	writel(val, phy->base + EMAC_SGMII_PHY_AUTONEG_CFG2);
 }
 
-static int emac_sgmii_irq_clear(struct emac_adapter *adpt, u32 irq_bits)
+static int emac_sgmii_irq_clear(struct emac_adapter *adpt, u8 irq_bits)
 {
 	struct emac_sgmii *phy = &adpt->phy;
-	u32 status;
+	u8 status;
 
 	writel_relaxed(irq_bits, phy->base + EMAC_SGMII_PHY_INTERRUPT_CLEAR);
 	writel_relaxed(IRQ_GLOBAL_CLEAR, phy->base + EMAC_SGMII_PHY_IRQ_CMD);
@@ -86,9 +86,8 @@ static int emac_sgmii_irq_clear(struct emac_adapter *adpt, u32 irq_bits)
 				      EMAC_SGMII_PHY_INTERRUPT_STATUS,
 				      status, !(status & irq_bits), 1,
 				      SGMII_PHY_IRQ_CLR_WAIT_TIME)) {
-		netdev_err(adpt->netdev,
-			   "error: failed clear SGMII irq: status:0x%x bits:0x%x\n",
-			   status, irq_bits);
+		net_err_ratelimited("%s: failed to clear SGMII irq: status:0x%x bits:0x%x\n",
+				    adpt->netdev->name, status, irq_bits);
 		return -EIO;
 	}
 
@@ -109,7 +108,7 @@ static irqreturn_t emac_sgmii_interrupt(int irq, void *data)
 {
 	struct emac_adapter *adpt = data;
 	struct emac_sgmii *phy = &adpt->phy;
-	u32 status;
+	u8 status;
 
 	status = readl(phy->base + EMAC_SGMII_PHY_INTERRUPT_STATUS);
 	status &= SGMII_ISR_MASK;
@@ -139,10 +138,8 @@ static irqreturn_t emac_sgmii_interrupt(int irq, void *data)
 		atomic_set(&phy->decode_error_count, 0);
 	}
 
-	if (emac_sgmii_irq_clear(adpt, status)) {
-		netdev_warn(adpt->netdev, "failed to clear SGMII interrupt\n");
+	if (emac_sgmii_irq_clear(adpt, status))
 		schedule_work(&adpt->work_thread);
-	}
 
 	return IRQ_HANDLED;
 }
diff --git a/drivers/net/ethernet/qualcomm/emac/emac.c b/drivers/net/ethernet/qualcomm/emac/emac.c
index ee6f2d27502c..70c92b649b29 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac.c
@@ -148,9 +148,8 @@ static irqreturn_t emac_isr(int _irq, void *data)
 		goto exit;
 
 	if (status & ISR_ERROR) {
-		netif_warn(adpt,  intr, adpt->netdev,
-			   "warning: error irq status 0x%lx\n",
-			   status & ISR_ERROR);
+		net_err_ratelimited("%s: error interrupt 0x%lx\n",
+				    adpt->netdev->name, status & ISR_ERROR);
 		/* reset MAC */
 		schedule_work(&adpt->work_thread);
 	}
@@ -169,7 +168,8 @@ static irqreturn_t emac_isr(int _irq, void *data)
 		emac_mac_tx_process(adpt, &adpt->tx_q);
 
 	if (status & ISR_OVER)
-		net_warn_ratelimited("warning: TX/RX overflow\n");
+		net_warn_ratelimited("%s: TX/RX overflow interrupt\n",
+				     adpt->netdev->name);
 
 exit:
 	/* enable the interrupt */
-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
