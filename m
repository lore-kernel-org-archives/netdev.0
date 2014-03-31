From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/13] i40e/i40evf: fix error checking path
Date: Mon, 31 Mar 2014 16:34:54 -0700
Message-ID: <1396308899-20926-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1396308899-20926-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jean Sacren <sakiwit@gmail.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Mitch Williams <mitch.a.williams@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:2042 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751724AbaCaXgb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Mar 2014 19:36:31 -0400
In-Reply-To: <1396308899-20926-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Sacren <sakiwit@gmail.com>

The commit 6494294f277fd ("i40e/i40evf: Use
dma_set_mask_and_coherent") uses dma_set_mask_and_coherent() to
replace dma_set_coherent_mask() for the benefit of return error.
The conversion brings some confusion in error checking as whether
against DMA_BIT_MASK(64) or DMA_BIT_MASK(32). For one, if error is
zero, the check will be against DMA_BIT_MASK(64) twice. Fix this
error checking by binding the check to the pertinent one.

Cc: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jean Sacren <sakiwit@gmail.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c     | 11 ++++++-----
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 11 ++++++-----
 2 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index a1ec793..861b722 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8091,12 +8091,13 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
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
index 51c84c1..e35e66f 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2191,12 +2191,13 @@ static int i40evf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
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
-- 
1.9.0
