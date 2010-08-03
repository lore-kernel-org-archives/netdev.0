From: Kulikov Vasiliy <segooon@gmail.com>
Subject: [PATCH 04/11] cxgb4vf: do not use PCI resources before pci_enable_device()
Date: Tue,  3 Aug 2010 19:43:15 +0400
Message-ID: <1280850196-5448-1-git-send-email-segooon@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:46162 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756010Ab0HCPnU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Aug 2010 11:43:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IRQ and resource[] may not have correct values until
after PCI hotplug setup occurs at pci_enable_device() time.

The semantic match that finds this problem is as follows:

// <smpl>
@@
identifier x;
identifier request ~= "pci_request.*|pci_resource.*";
@@

(
* x->irq
|
* x->resource
|
* request(x, ...)
)
 ...
*pci_enable_device(x)
// </smpl>

Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
---
 drivers/net/cxgb4vf/cxgb4vf_main.c |   31 ++++++++++++++++---------------
 1 files changed, 16 insertions(+), 15 deletions(-)

diff --git a/drivers/net/cxgb4vf/cxgb4vf_main.c b/drivers/net/cxgb4vf/cxgb4vf_main.c
index a165632..7b6d07f 100644
--- a/drivers/net/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/cxgb4vf/cxgb4vf_main.c
@@ -2462,23 +2462,24 @@ static int __devinit cxgb4vf_pci_probe(struct pci_dev *pdev,
 		version_printed = 1;
 	}
 
+
 	/*
-	 * Reserve PCI resources for the device.  If we can't get them some
-	 * other driver may have already claimed the device ...
+	 * Initialize generic PCI device state.
 	 */
-	err = pci_request_regions(pdev, KBUILD_MODNAME);
+	err = pci_enable_device(pdev);
 	if (err) {
-		dev_err(&pdev->dev, "cannot obtain PCI resources\n");
+		dev_err(&pdev->dev, "cannot enable PCI device\n");
 		return err;
 	}
 
 	/*
-	 * Initialize generic PCI device state.
+	 * Reserve PCI resources for the device.  If we can't get them some
+	 * other driver may have already claimed the device ...
 	 */
-	err = pci_enable_device(pdev);
+	err = pci_request_regions(pdev, KBUILD_MODNAME);
 	if (err) {
-		dev_err(&pdev->dev, "cannot enable PCI device\n");
-		goto err_release_regions;
+		dev_err(&pdev->dev, "cannot obtain PCI resources\n");
+		goto err_disable_device;
 	}
 
 	/*
@@ -2491,14 +2492,14 @@ static int __devinit cxgb4vf_pci_probe(struct pci_dev *pdev,
 		if (err) {
 			dev_err(&pdev->dev, "unable to obtain 64-bit DMA for"
 				" coherent allocations\n");
-			goto err_disable_device;
+			goto err_release_regions;
 		}
 		pci_using_dac = 1;
 	} else {
 		err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (err != 0) {
 			dev_err(&pdev->dev, "no usable DMA configuration\n");
-			goto err_disable_device;
+			goto err_release_regions;
 		}
 		pci_using_dac = 0;
 	}
@@ -2514,7 +2515,7 @@ static int __devinit cxgb4vf_pci_probe(struct pci_dev *pdev,
 	adapter = kzalloc(sizeof(*adapter), GFP_KERNEL);
 	if (!adapter) {
 		err = -ENOMEM;
-		goto err_disable_device;
+		goto err_release_regions;
 	}
 	pci_set_drvdata(pdev, adapter);
 	adapter->pdev = pdev;
@@ -2750,13 +2751,13 @@ err_free_adapter:
 	kfree(adapter);
 	pci_set_drvdata(pdev, NULL);
 
-err_disable_device:
-	pci_disable_device(pdev);
-	pci_clear_master(pdev);
-
 err_release_regions:
 	pci_release_regions(pdev);
 	pci_set_drvdata(pdev, NULL);
+	pci_clear_master(pdev);
+
+err_disable_device:
+	pci_disable_device(pdev);
 
 err_out:
 	return err;
-- 
1.7.0.4

