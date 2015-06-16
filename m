From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/17] fm10k: use dma_set_mask_and_coherent in fm10k_probe
Date: Tue, 16 Jun 2015 06:47:21 -0700
Message-ID: <1434462448-140563-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1434462448-140563-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:24718 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756710AbbFPNrg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jun 2015 09:47:36 -0400
In-Reply-To: <1434462448-140563-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch cleans up the use of dma_get_required_mask and uses the
simpler dma_set_mask_and_coherent function instead of doing these as
separate steps.

I removed the dma_get_required_mask call because based on some minimal
testing it appears that either (a) we're not doing the right thing with
the call or (b) we don't need it anyways. If the value returned is
<48bits, we'll end up trying with 48 bits anyways. If it's over 48bits,
fm10k can't support that anyways, and we should try 48bits. If 48bits
fails, we'll fallback to 32bits. This cleans up some very funky code.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 24 ++++++------------------
 1 file changed, 6 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 5269b16..0381c8d1 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -1741,30 +1741,18 @@ static int fm10k_probe(struct pci_dev *pdev,
 	struct fm10k_intfc *interface;
 	struct fm10k_hw *hw;
 	int err;
-	u64 dma_mask;
 
 	err = pci_enable_device_mem(pdev);
 	if (err)
 		return err;
 
-	/* By default fm10k only supports a 48 bit DMA mask */
-	dma_mask = DMA_BIT_MASK(48) | dma_get_required_mask(&pdev->dev);
-
-	if ((dma_mask <= DMA_BIT_MASK(32)) ||
-	    dma_set_mask_and_coherent(&pdev->dev, dma_mask)) {
-		dma_mask &= DMA_BIT_MASK(32);
-
+	err = dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(48));
+	if (err)
 		err = dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(32));
-		err = dma_set_mask(&pdev->dev, DMA_BIT_MASK(32));
-		if (err) {
-			err = dma_set_coherent_mask(&pdev->dev,
-						    DMA_BIT_MASK(32));
-			if (err) {
-				dev_err(&pdev->dev,
-					"No usable DMA configuration, aborting\n");
-				goto err_dma;
-			}
-		}
+	if (err) {
+		dev_err(&pdev->dev,
+			"DMA configuration failed: 0x%x\n", err);
+		goto err_dma;
 	}
 
 	err = pci_request_selected_regions(pdev,
-- 
2.4.3
