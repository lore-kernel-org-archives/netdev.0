From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 1/5] cnic: Add functions to allocate and free
 UIO rings
Date: Sat, 8 Sep 2012 09:01:01 -0700
Message-ID: <1347120065-26492-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3146 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754894Ab2IHPsV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Sep 2012 11:48:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These functions are needed to free up memory when the rings are no longer
needed.

Reviewed-by: Eddie Wai <eddie.wai@broadcom.com>
Reviewed-by: Bhanu Prakash Gollapudi <bprakash@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/cnic.c |   59 +++++++++++++++++++++++-----------
 1 files changed, 40 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index 3b4fc61..ff35894 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -823,10 +823,8 @@ static void cnic_free_context(struct cnic_dev *dev)
 	}
 }
 
-static void __cnic_free_uio(struct cnic_uio_dev *udev)
+static void __cnic_free_uio_rings(struct cnic_uio_dev *udev)
 {
-	uio_unregister_device(&udev->cnic_uinfo);
-
 	if (udev->l2_buf) {
 		dma_free_coherent(&udev->pdev->dev, udev->l2_buf_size,
 				  udev->l2_buf, udev->l2_buf_map);
@@ -839,6 +837,14 @@ static void __cnic_free_uio(struct cnic_uio_dev *udev)
 		udev->l2_ring = NULL;
 	}
 
+}
+
+static void __cnic_free_uio(struct cnic_uio_dev *udev)
+{
+	uio_unregister_device(&udev->cnic_uinfo);
+
+	__cnic_free_uio_rings(udev);
+
 	pci_dev_put(udev->pdev);
 	kfree(udev);
 }
@@ -996,6 +1002,34 @@ static int cnic_alloc_kcq(struct cnic_dev *dev, struct kcq_info *info,
 	return 0;
 }
 
+static int __cnic_alloc_uio_rings(struct cnic_uio_dev *udev, int pages)
+{
+	struct cnic_local *cp = udev->dev->cnic_priv;
+
+	if (udev->l2_ring)
+		return 0;
+
+	udev->l2_ring_size = pages * BCM_PAGE_SIZE;
+	udev->l2_ring = dma_alloc_coherent(&udev->pdev->dev, udev->l2_ring_size,
+					   &udev->l2_ring_map,
+					   GFP_KERNEL | __GFP_COMP);
+	if (!udev->l2_ring)
+		return -ENOMEM;
+
+	udev->l2_buf_size = (cp->l2_rx_ring_size + 1) * cp->l2_single_buf_size;
+	udev->l2_buf_size = PAGE_ALIGN(udev->l2_buf_size);
+	udev->l2_buf = dma_alloc_coherent(&udev->pdev->dev, udev->l2_buf_size,
+					  &udev->l2_buf_map,
+					  GFP_KERNEL | __GFP_COMP);
+	if (!udev->l2_buf) {
+		__cnic_free_uio_rings(udev);
+		return -ENOMEM;
+	}
+
+	return 0;
+
+}
+
 static int cnic_alloc_uio_rings(struct cnic_dev *dev, int pages)
 {
 	struct cnic_local *cp = dev->cnic_priv;
@@ -1020,20 +1054,9 @@ static int cnic_alloc_uio_rings(struct cnic_dev *dev, int pages)
 
 	udev->dev = dev;
 	udev->pdev = dev->pcidev;
-	udev->l2_ring_size = pages * BCM_PAGE_SIZE;
-	udev->l2_ring = dma_alloc_coherent(&udev->pdev->dev, udev->l2_ring_size,
-					   &udev->l2_ring_map,
-					   GFP_KERNEL | __GFP_COMP);
-	if (!udev->l2_ring)
-		goto err_udev;
 
-	udev->l2_buf_size = (cp->l2_rx_ring_size + 1) * cp->l2_single_buf_size;
-	udev->l2_buf_size = PAGE_ALIGN(udev->l2_buf_size);
-	udev->l2_buf = dma_alloc_coherent(&udev->pdev->dev, udev->l2_buf_size,
-					  &udev->l2_buf_map,
-					  GFP_KERNEL | __GFP_COMP);
-	if (!udev->l2_buf)
-		goto err_dma;
+	if (__cnic_alloc_uio_rings(udev, pages))
+		goto err_udev;
 
 	write_lock(&cnic_dev_lock);
 	list_add(&udev->list, &cnic_udev_list);
@@ -1044,9 +1067,7 @@ static int cnic_alloc_uio_rings(struct cnic_dev *dev, int pages)
 	cp->udev = udev;
 
 	return 0;
- err_dma:
-	dma_free_coherent(&udev->pdev->dev, udev->l2_ring_size,
-			  udev->l2_ring, udev->l2_ring_map);
+
  err_udev:
 	kfree(udev);
 	return -ENOMEM;
-- 
1.7.1
