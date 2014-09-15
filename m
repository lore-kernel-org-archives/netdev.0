From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net] cxgb4: Don't allocate adapter structure for all PF's
Date: Tue, 16 Sep 2014 02:58:46 +0530
Message-ID: <1410816526-19355-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	kumaras@chelsio.com, anish@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:52068
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755603AbaIOVXD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 17:23:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 35b1de557970 ("rdma/cxgb4: Fixes cxgb4 probe failure in VM when PF is
exposed through PCI Passthrough") moved the code to check for SR-IOV PF[0..3]
much further down in init_one() past the point where we allocate a (struct
adapter) for PF[0..3]. As a result, we left four of these on ever module remove.

Fix: Allocate adapter structure only for PF4

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |   49 ++++++++++++----------
 1 files changed, 27 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 8c34811..e5be511 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -6478,6 +6478,7 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	struct port_info *pi;
 	bool highdma = false;
 	struct adapter *adapter = NULL;
+	void __iomem *regs;
 
 	printk_once(KERN_INFO "%s - version %s\n", DRV_DESC, DRV_VERSION);
 
@@ -6494,19 +6495,35 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto out_release_regions;
 	}
 
+	regs = pci_ioremap_bar(pdev, 0);
+	if (!regs) {
+		dev_err(&pdev->dev, "cannot map device registers\n");
+		err = -ENOMEM;
+		goto out_disable_device;
+	}
+
+	/* We control everything through one PF */
+	func = SOURCEPF_GET(readl(regs + PL_WHOAMI));
+	if (func != ent->driver_data) {
+		iounmap(regs);
+		pci_disable_device(pdev);
+		pci_save_state(pdev);        /* to restore SR-IOV later */
+		goto sriov;
+	}
+
 	if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) {
 		highdma = true;
 		err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
 		if (err) {
 			dev_err(&pdev->dev, "unable to obtain 64-bit DMA for "
 				"coherent allocations\n");
-			goto out_disable_device;
+			goto out_unmap_bar0;
 		}
 	} else {
 		err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (err) {
 			dev_err(&pdev->dev, "no usable DMA configuration\n");
-			goto out_disable_device;
+			goto out_unmap_bar0;
 		}
 	}
 
@@ -6518,7 +6535,7 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	adapter = kzalloc(sizeof(*adapter), GFP_KERNEL);
 	if (!adapter) {
 		err = -ENOMEM;
-		goto out_disable_device;
+		goto out_unmap_bar0;
 	}
 
 	adapter->workq = create_singlethread_workqueue("cxgb4");
@@ -6530,20 +6547,7 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	/* PCI device has been enabled */
 	adapter->flags |= DEV_ENABLED;
 
-	adapter->regs = pci_ioremap_bar(pdev, 0);
-	if (!adapter->regs) {
-		dev_err(&pdev->dev, "cannot map device registers\n");
-		err = -ENOMEM;
-		goto out_free_adapter;
-	}
-
-	/* We control everything through one PF */
-	func = SOURCEPF_GET(readl(adapter->regs + PL_WHOAMI));
-	if (func != ent->driver_data) {
-		pci_save_state(pdev);        /* to restore SR-IOV later */
-		goto sriov;
-	}
-
+	adapter->regs = regs;
 	adapter->pdev = pdev;
 	adapter->pdev_dev = &pdev->dev;
 	adapter->mbox = func;
@@ -6560,7 +6564,8 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	err = t4_prep_adapter(adapter);
 	if (err)
-		goto out_unmap_bar0;
+		goto out_free_adapter;
+
 
 	if (!is_t4(adapter->params.chip)) {
 		s_qpp = QUEUESPERPAGEPF1 * adapter->fn;
@@ -6577,14 +6582,14 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 			dev_err(&pdev->dev,
 				"Incorrect number of egress queues per page\n");
 			err = -EINVAL;
-			goto out_unmap_bar0;
+			goto out_free_adapter;
 		}
 		adapter->bar2 = ioremap_wc(pci_resource_start(pdev, 2),
 		pci_resource_len(pdev, 2));
 		if (!adapter->bar2) {
 			dev_err(&pdev->dev, "cannot map device bar2 region\n");
 			err = -ENOMEM;
-			goto out_unmap_bar0;
+			goto out_free_adapter;
 		}
 	}
 
@@ -6722,13 +6727,13 @@ sriov:
  out_unmap_bar:
 	if (!is_t4(adapter->params.chip))
 		iounmap(adapter->bar2);
- out_unmap_bar0:
-	iounmap(adapter->regs);
  out_free_adapter:
 	if (adapter->workq)
 		destroy_workqueue(adapter->workq);
 
 	kfree(adapter);
+ out_unmap_bar0:
+	iounmap(regs);
  out_disable_device:
 	pci_disable_pcie_error_reporting(pdev);
 	pci_disable_device(pdev);
-- 
1.7.1
