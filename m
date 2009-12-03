From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 5/5] cnic: Use dma_alloc_coherent().
Date: Wed, 2 Dec 2009 17:15:39 -0800
Message-ID: <1259802939-4742-5-git-send-email-mchan@broadcom.com>
References: <1259802939-4742-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2977 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753291AbZLCBId (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Dec 2009 20:08:33 -0500
In-Reply-To: <1259802939-4742-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace pci_alloc_consistent() with dma_alloc_coherent() so that
appropriate GFP flags can be used.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/cnic.c |   54 ++++++++++++++++++++++++++++-----------------------
 1 files changed, 30 insertions(+), 24 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index d78e803..d4c6e7f 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -667,14 +667,14 @@ static void cnic_free_dma(struct cnic_dev *dev, struct cnic_dma *dma)
 
 	for (i = 0; i < dma->num_pages; i++) {
 		if (dma->pg_arr[i]) {
-			pci_free_consistent(dev->pcidev, BCM_PAGE_SIZE,
-					    dma->pg_arr[i], dma->pg_map_arr[i]);
+			dma_free_coherent(&dev->pcidev->dev, BCM_PAGE_SIZE,
+					  dma->pg_arr[i], dma->pg_map_arr[i]);
 			dma->pg_arr[i] = NULL;
 		}
 	}
 	if (dma->pgtbl) {
-		pci_free_consistent(dev->pcidev, dma->pgtbl_size,
-				    dma->pgtbl, dma->pgtbl_map);
+		dma_free_coherent(&dev->pcidev->dev, dma->pgtbl_size,
+				  dma->pgtbl, dma->pgtbl_map);
 		dma->pgtbl = NULL;
 	}
 	kfree(dma->pg_arr);
@@ -725,9 +725,10 @@ static int cnic_alloc_dma(struct cnic_dev *dev, struct cnic_dma *dma,
 	dma->num_pages = pages;
 
 	for (i = 0; i < pages; i++) {
-		dma->pg_arr[i] = pci_alloc_consistent(dev->pcidev,
-						      BCM_PAGE_SIZE,
-						      &dma->pg_map_arr[i]);
+		dma->pg_arr[i] = dma_alloc_coherent(&dev->pcidev->dev,
+						    BCM_PAGE_SIZE,
+						    &dma->pg_map_arr[i],
+						    GFP_ATOMIC);
 		if (dma->pg_arr[i] == NULL)
 			goto error;
 	}
@@ -736,8 +737,8 @@ static int cnic_alloc_dma(struct cnic_dev *dev, struct cnic_dma *dma,
 
 	dma->pgtbl_size = ((pages * 8) + BCM_PAGE_SIZE - 1) &
 			  ~(BCM_PAGE_SIZE - 1);
-	dma->pgtbl = pci_alloc_consistent(dev->pcidev, dma->pgtbl_size,
-					  &dma->pgtbl_map);
+	dma->pgtbl = dma_alloc_coherent(&dev->pcidev->dev, dma->pgtbl_size,
+					&dma->pgtbl_map, GFP_ATOMIC);
 	if (dma->pgtbl == NULL)
 		goto error;
 
@@ -757,9 +758,9 @@ static void cnic_free_context(struct cnic_dev *dev)
 
 	for (i = 0; i < cp->ctx_blks; i++) {
 		if (cp->ctx_arr[i].ctx) {
-			pci_free_consistent(dev->pcidev, cp->ctx_blk_size,
-					    cp->ctx_arr[i].ctx,
-					    cp->ctx_arr[i].mapping);
+			dma_free_coherent(&dev->pcidev->dev, cp->ctx_blk_size,
+					  cp->ctx_arr[i].ctx,
+					  cp->ctx_arr[i].mapping);
 			cp->ctx_arr[i].ctx = NULL;
 		}
 	}
@@ -781,14 +782,14 @@ static void cnic_free_resc(struct cnic_dev *dev)
 	}
 
 	if (cp->l2_buf) {
-		pci_free_consistent(dev->pcidev, cp->l2_buf_size,
-				    cp->l2_buf, cp->l2_buf_map);
+		dma_free_coherent(&dev->pcidev->dev, cp->l2_buf_size,
+				  cp->l2_buf, cp->l2_buf_map);
 		cp->l2_buf = NULL;
 	}
 
 	if (cp->l2_ring) {
-		pci_free_consistent(dev->pcidev, cp->l2_ring_size,
-				    cp->l2_ring, cp->l2_ring_map);
+		dma_free_coherent(&dev->pcidev->dev, cp->l2_ring_size,
+				  cp->l2_ring, cp->l2_ring_map);
 		cp->l2_ring = NULL;
 	}
 
@@ -849,8 +850,10 @@ static int cnic_alloc_context(struct cnic_dev *dev)
 
 		for (i = 0; i < cp->ctx_blks; i++) {
 			cp->ctx_arr[i].ctx =
-				pci_alloc_consistent(dev->pcidev, BCM_PAGE_SIZE,
-						     &cp->ctx_arr[i].mapping);
+				dma_alloc_coherent(&dev->pcidev->dev,
+						   BCM_PAGE_SIZE,
+						   &cp->ctx_arr[i].mapping,
+						   GFP_KERNEL);
 			if (cp->ctx_arr[i].ctx == NULL)
 				return -ENOMEM;
 		}
@@ -863,15 +866,17 @@ static int cnic_alloc_l2_rings(struct cnic_dev *dev, int pages)
 	struct cnic_local *cp = dev->cnic_priv;
 
 	cp->l2_ring_size = pages * BCM_PAGE_SIZE;
-	cp->l2_ring = pci_alloc_consistent(dev->pcidev, cp->l2_ring_size,
-					   &cp->l2_ring_map);
+	cp->l2_ring = dma_alloc_coherent(&dev->pcidev->dev, cp->l2_ring_size,
+					 &cp->l2_ring_map,
+					 GFP_KERNEL | __GFP_COMP);
 	if (!cp->l2_ring)
 		return -ENOMEM;
 
 	cp->l2_buf_size = (cp->l2_rx_ring_size + 1) * cp->l2_single_buf_size;
 	cp->l2_buf_size = PAGE_ALIGN(cp->l2_buf_size);
-	cp->l2_buf = pci_alloc_consistent(dev->pcidev, cp->l2_buf_size,
-					   &cp->l2_buf_map);
+	cp->l2_buf = dma_alloc_coherent(&dev->pcidev->dev, cp->l2_buf_size,
+					&cp->l2_buf_map,
+					GFP_KERNEL | __GFP_COMP);
 	if (!cp->l2_buf)
 		return -ENOMEM;
 
@@ -1006,8 +1011,9 @@ static int cnic_alloc_bnx2x_context(struct cnic_dev *dev)
 
 	for (i = 0; i < blks; i++) {
 		cp->ctx_arr[i].ctx =
-			pci_alloc_consistent(dev->pcidev, cp->ctx_blk_size,
-					     &cp->ctx_arr[i].mapping);
+			dma_alloc_coherent(&dev->pcidev->dev, cp->ctx_blk_size,
+					   &cp->ctx_arr[i].mapping,
+					   GFP_KERNEL);
 		if (cp->ctx_arr[i].ctx == NULL)
 			return -ENOMEM;
 
-- 
1.6.4.GIT


