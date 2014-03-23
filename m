From: Jean Sacren <sakiwit@gmail.com>
Subject: [PATCH net-next] i40e: i40evf: fix error checking path
Date: Sun, 23 Mar 2014 14:26:58 -0600
Message-ID: <1395606418-22964-1-git-send-email-sakiwit@gmail.com>
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Mitch Williams <mitch.a.williams@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:58122 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750933AbaCWUaU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Mar 2014 16:30:20 -0400
Received: by mail-pd0-f173.google.com with SMTP id z10so4466539pdj.32
        for <netdev@vger.kernel.org>; Sun, 23 Mar 2014 13:30:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit 6494294f277fd ("i40e/i40evf: Use
dma_set_mask_and_coherent") uses dma_set_mask_and_coherent() to
replace dma_set_coherent_mask() for the benefit of return error.
The conversion brings some confusion in error checking as whether
against DMA_BIT_MASK(64) or DMA_BIT_MASK(32). For one, if error is
zero, the check will be against DMA_BIT_MASK(64) twice. Fix this
error checking by binding the check to the pertinent one.

Signed-off-by: Jean Sacren <sakiwit@gmail.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c     | 11 ++++++-----
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 11 ++++++-----
 2 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 113354214517..37b2f55ea43b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8041,12 +8041,13 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	/* set up for high or low dma */
 	err = dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(64));
-	if (err)
-		err = dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(32));
 	if (err) {
-		dev_err(&pdev->dev,
-			"DMA configuration failed: 0x%x\n", err);
-		goto err_dma;
+		err = dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(32));
+		if (err) {
+			dev_err(&pdev->dev,
+				"DMA configuration failed: 0x%x\n", err);
+			goto err_dma;
+		}
 	}
 
 	/* set up pci connections */
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index d381bcc4ea9f..fdf9edf97ff1 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2188,12 +2188,13 @@ static int i40evf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		return err;
 
 	err = dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(64));
-	if (err)
-		err = dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(32));
 	if (err) {
-		dev_err(&pdev->dev,
-			"DMA configuration failed: 0x%x\n", err);
-		goto err_dma;
+		err = dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(32));
+		if (err) {
+			dev_err(&pdev->dev,
+				"DMA configuration failed: 0x%x\n", err);
+			goto err_dma;
+		}
 	}
 
 	err = pci_request_regions(pdev, i40evf_driver_name);
