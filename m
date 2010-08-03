From: Kulikov Vasiliy <segooon@gmail.com>
Subject: [PATCH 03/11] cxgb3: do not use PCI resources before pci_enable_device()
Date: Tue,  3 Aug 2010 19:43:11 +0400
Message-ID: <1280850192-5408-1-git-send-email-segooon@gmail.com>
Cc: Divy Le Ray <divy@chelsio.com>,
	"David S. Miller" <davem@davemloft.net>,
	Roland Dreier <rolandd@cisco.com>,
	Steve Wise <swise@opengridcomputing.com>,
	Ben Hutchings <ben@decadent.org.uk>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: kernel-janitors@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
 drivers/net/cxgb3/cxgb3_main.c |   25 +++++++++++++------------
 1 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 066fd5b..ad19585 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -3198,17 +3198,17 @@ static int __devinit init_one(struct pci_dev *pdev,
 		}
 	}
 
-	err = pci_request_regions(pdev, DRV_NAME);
+	err = pci_enable_device(pdev);
 	if (err) {
-		/* Just info, some other driver may have claimed the device. */
-		dev_info(&pdev->dev, "cannot obtain PCI resources\n");
-		return err;
+		dev_err(&pdev->dev, "cannot enable PCI device\n");
+		goto out;
 	}
 
-	err = pci_enable_device(pdev);
+	err = pci_request_regions(pdev, DRV_NAME);
 	if (err) {
-		dev_err(&pdev->dev, "cannot enable PCI device\n");
-		goto out_release_regions;
+		/* Just info, some other driver may have claimed the device. */
+		dev_info(&pdev->dev, "cannot obtain PCI resources\n");
+		goto out_disable_device;
 	}
 
 	if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) {
@@ -3217,11 +3217,11 @@ static int __devinit init_one(struct pci_dev *pdev,
 		if (err) {
 			dev_err(&pdev->dev, "unable to obtain 64-bit DMA for "
 			       "coherent allocations\n");
-			goto out_disable_device;
+			goto out_release_regions;
 		}
 	} else if ((err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32))) != 0) {
 		dev_err(&pdev->dev, "no usable DMA configuration\n");
-		goto out_disable_device;
+		goto out_release_regions;
 	}
 
 	pci_set_master(pdev);
@@ -3234,7 +3234,7 @@ static int __devinit init_one(struct pci_dev *pdev,
 	adapter = kzalloc(sizeof(*adapter), GFP_KERNEL);
 	if (!adapter) {
 		err = -ENOMEM;
-		goto out_disable_device;
+		goto out_release_regions;
 	}
 
 	adapter->nofail_skb =
@@ -3370,11 +3370,12 @@ out_free_dev:
 out_free_adapter:
 	kfree(adapter);
 
-out_disable_device:
-	pci_disable_device(pdev);
 out_release_regions:
 	pci_release_regions(pdev);
+out_disable_device:
+	pci_disable_device(pdev);
 	pci_set_drvdata(pdev, NULL);
+out:
 	return err;
 }
 
-- 
1.7.0.4
