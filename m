From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: [PATCH] ATHEROS-ALX: Use dma_set_mask_and_coherent and fix a bug
Date: Sat, 15 Mar 2014 19:19:08 +0100
Message-ID: <1394907548-10084-1-git-send-email-peter.senna@gmail.com>
Cc: Peter Senna Tschudin <peter.senna@gmail.com>
To: jcliburn@gmail.com, chris.snook@gmail.com, davem@davemloft.net,
	johannes@sipsolutions.net, jg1.han@samsung.com,
	wangyijing@huawei.com, linux@hahnjo.de, sd@queasysnail.net,
	hahnjo@hahnjo.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 1. For the 64 bits dma mask use dma_set_mask_and_coherent instead of
 dma_set_mask and dma_set_coherent_mask.

 2. For the 32 bits dma mask dma_set_coherent_mask is only called if
 dma_set_mask fails, which is unusual. Assuming this as a bug, fixes
 it by replacing calls to dma_set_mask and dma_set_coherent_mask by a
 call to dma_set_coherent_mask.
 
 Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>
---

 Tested by compilation only.

 drivers/net/ethernet/atheros/alx/main.c | 14 ++++----------
 1 file changed, 4 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/atheros/alx/main.c b/drivers/net/ethernet/atheros/alx/main.c
index 2e45f6e..380d249 100644
--- a/drivers/net/ethernet/atheros/alx/main.c
+++ b/drivers/net/ethernet/atheros/alx/main.c
@@ -1248,19 +1248,13 @@ static int alx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	 * shared register for the high 32 bits, so only a single, aligned,
 	 * 4 GB physical address range can be used for descriptors.
 	 */
-	if (!dma_set_mask(&pdev->dev, DMA_BIT_MASK(64)) &&
-	    !dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(64))) {
+	if (!dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(64))) {
 		dev_dbg(&pdev->dev, "DMA to 64-BIT addresses\n");
 	} else {
-		err = dma_set_mask(&pdev->dev, DMA_BIT_MASK(32));
+		err = dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(32));
 		if (err) {
-			err = dma_set_coherent_mask(&pdev->dev,
-						    DMA_BIT_MASK(32));
-			if (err) {
-				dev_err(&pdev->dev,
-					"No usable DMA config, aborting\n");
-				goto out_pci_disable;
-			}
+			dev_err(&pdev->dev, "No usable DMA config, aborting\n");
+			goto out_pci_disable;
 		}
 	}
 
-- 
1.8.3.1
