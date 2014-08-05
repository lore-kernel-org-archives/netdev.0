From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v2 1/2] amd-xgbe: Use dma_set_mask_and_coherent to
 set DMA mask
Date: Tue, 5 Aug 2014 13:30:38 -0500
Message-ID: <20140805183038.32561.86398.stgit@tlendack-t1.amdoffice.net>
References: <20140805183032.32561.85828.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2lp0243.outbound.protection.outlook.com ([207.46.163.243]:19364
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755403AbaHESan (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Aug 2014 14:30:43 -0400
In-Reply-To: <20140805183032.32561.85828.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the dma_set_mask_and_coherent function to set the DMA mask rather
than setting the DMA mask fields directly.  This was originally done
to work around a bug in the arm64 DMA support when RAM started above
the 4GB boundary which has since been fixed.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-main.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-main.c b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
index ec977d3..8aa6a93 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-main.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
@@ -303,8 +303,11 @@ static int xgbe_probe(struct platform_device *pdev)
 	/* Set the DMA mask */
 	if (!dev->dma_mask)
 		dev->dma_mask = &dev->coherent_dma_mask;
-	*(dev->dma_mask) = DMA_BIT_MASK(40);
-	dev->coherent_dma_mask = DMA_BIT_MASK(40);
+	ret = dma_set_mask_and_coherent(dev, DMA_BIT_MASK(40));
+	if (ret) {
+		dev_err(dev, "dma_set_mask_and_coherent failed\n");
+		goto err_io;
+	}
 
 	if (of_property_read_bool(dev->of_node, "dma-coherent")) {
 		pdata->axdomain = XGBE_DMA_OS_AXDOMAIN;
