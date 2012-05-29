From: Devendra Naga <devendra.aaru@gmail.com>
Subject: [PATCH] r6040: disable pci device if the subsequent calls (after pci_enable_device) fails
Date: Wed, 30 May 2012 04:44:10 +0530
Message-ID: <1338333250-11974-1-git-send-email-devendra.aaru@gmail.com>
Cc: Devendra Naga <devendra.aaru@gmail.com>
To: Florian Fainelli <florian@openwrt.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

the calls after the pci_enable_device may fail, and will error out with out
disabling it. disable the device at error paths.

Signed-off-by: Devendra Naga <devendra.aaru@gmail.com>
---
 drivers/net/ethernet/rdc/r6040.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index 4de7364..8f5079a 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -1096,20 +1096,20 @@ static int __devinit r6040_init_one(struct pci_dev *pdev,
 	if (err) {
 		dev_err(&pdev->dev, "32-bit PCI DMA addresses"
 				"not supported by the card\n");
-		goto err_out;
+		goto err_out_disable_dev;
 	}
 	err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
 	if (err) {
 		dev_err(&pdev->dev, "32-bit PCI DMA addresses"
 				"not supported by the card\n");
-		goto err_out;
+		goto err_out_disable_dev;
 	}
 
 	/* IO Size check */
 	if (pci_resource_len(pdev, bar) < io_size) {
 		dev_err(&pdev->dev, "Insufficient PCI resources, aborting\n");
 		err = -EIO;
-		goto err_out;
+		goto err_out_disable_dev;
 	}
 
 	pci_set_master(pdev);
@@ -1117,7 +1117,7 @@ static int __devinit r6040_init_one(struct pci_dev *pdev,
 	dev = alloc_etherdev(sizeof(struct r6040_private));
 	if (!dev) {
 		err = -ENOMEM;
-		goto err_out;
+		goto err_out_disable_dev;
 	}
 	SET_NETDEV_DEV(dev, &pdev->dev);
 	lp = netdev_priv(dev);
@@ -1238,6 +1238,8 @@ err_out_free_res:
 	pci_release_regions(pdev);
 err_out_free_dev:
 	free_netdev(dev);
+err_out_disable_dev:
+	pci_disable_device(pdev);
 err_out:
 	return err;
 }
-- 
1.7.9.5
