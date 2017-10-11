From: Timur Tabi <timur@codeaurora.org>
Subject: [PATCH 1/4] net: qcom/emac: specify the correct DMA mask
Date: Wed, 11 Oct 2017 14:52:23 -0500
Message-ID: <1507751546-10265-2-git-send-email-timur@codeaurora.org>
References: <1507751546-10265-1-git-send-email-timur@codeaurora.org>
Cc: timur@codeaurora.org
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:37580 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752518AbdJKTwb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 15:52:31 -0400
In-Reply-To: <1507751546-10265-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 64/32-bit DMA mask hackery in the EMAC driver is not actually necessary,
and is technically not accurate.  The EMAC hardware is limted to a 45-bit
DMA address.  Although no EMAC-enabled system can have that much DDR,
an IOMMU could possible provide a larger address.  Rather than play games
with the DMA mappings, the driver should provide a correct value and
trust the DMA/IOMMU layers to do the right thing.

Signed-off-by: Timur Tabi <timur@codeaurora.org>
---
 drivers/net/ethernet/qualcomm/emac/emac.c | 17 ++++-------------
 1 file changed, 4 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/emac/emac.c b/drivers/net/ethernet/qualcomm/emac/emac.c
index f477ba29c569..ee6f2d27502c 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac.c
@@ -615,20 +615,11 @@ static int emac_probe(struct platform_device *pdev)
 	u32 reg;
 	int ret;
 
-	/* The EMAC itself is capable of 64-bit DMA, so try that first. */
-	ret = dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(64));
+	/* The TPD buffer address is limited to 45 bits. */
+	ret = dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(45));
 	if (ret) {
-		/* Some platforms may restrict the EMAC's address bus to less
-		 * then the size of DDR. In this case, we need to try a
-		 * smaller mask.  We could try every possible smaller mask,
-		 * but that's overkill.  Instead, just fall to 32-bit, which
-		 * should always work.
-		 */
-		ret = dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(32));
-		if (ret) {
-			dev_err(&pdev->dev, "could not set DMA mask\n");
-			return ret;
-		}
+		dev_err(&pdev->dev, "could not set DMA mask\n");
+		return ret;
 	}
 
 	netdev = alloc_etherdev(sizeof(struct emac_adapter));
-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
