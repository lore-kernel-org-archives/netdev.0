From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 3/6] e1000e: Use dma_alloc_coherent where possible
Date: Fri, 10 Aug 2007 13:00:52 -0700
Message-ID: <20070810200052.21509.19321.stgit@localhost.localdomain>
References: <20070810200038.21509.77815.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	andi@firstfloor.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:9264 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S938165AbXHJUAx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2007 16:00:53 -0400
In-Reply-To: <20070810200038.21509.77815.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Instead of using pci_alloc_consistent at GFP_ATOMIC we can be
more reliable at startup and use dma_alloc_coherent instead with
GFP_KERNEL.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/ethtool.c |   16 ++++++++--------
 drivers/net/e1000e/netdev.c  |    9 ++++++---
 2 files changed, 14 insertions(+), 11 deletions(-)

diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index c9d74a8..d184116 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -962,13 +962,13 @@ static void e1000_free_desc_rings(struct e1000_adapter *adapter)
 	}
 
 	if (tx_ring->desc) {
-		pci_free_consistent(pdev, tx_ring->size, tx_ring->desc,
-				    tx_ring->dma);
+		dma_free_coherent(&pdev->dev, tx_ring->size, tx_ring->desc,
+				  tx_ring->dma);
 		tx_ring->desc = NULL;
 	}
 	if (rx_ring->desc) {
-		pci_free_consistent(pdev, rx_ring->size, rx_ring->desc,
-				    rx_ring->dma);
+		dma_free_coherent(&pdev->dev, rx_ring->size, rx_ring->desc,
+				  rx_ring->dma);
 		rx_ring->desc = NULL;
 	}
 
@@ -1004,8 +1004,8 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
 
 	tx_ring->size = tx_ring->count * sizeof(struct e1000_tx_desc);
 	tx_ring->size = ALIGN(tx_ring->size, 4096);
-	tx_ring->desc = pci_alloc_consistent(pdev, tx_ring->size,
-			&tx_ring->dma);
+	tx_ring->desc = dma_alloc_coherent(&pdev->dev, tx_ring->size,
+					   &tx_ring->dma, GFP_KERNEL);
 	if (!tx_ring->desc) {
 		ret_val = 2;
 		goto err_nomem;
@@ -1065,8 +1065,8 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
 	memset(rx_ring->buffer_info, 0, size);
 
 	rx_ring->size = rx_ring->count * sizeof(struct e1000_rx_desc);
-	rx_ring->desc = pci_alloc_consistent(pdev, rx_ring->size,
-					     &rx_ring->dma);
+	rx_ring->desc = dma_alloc_coherent(&pdev->dev, rx_ring->size,
+					   &rx_ring->dma, GFP_KERNEL);
 	if (!rx_ring->desc) {
 		ret_val = 5;
 		goto err_nomem;
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index d711e14..51c9024 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -1344,7 +1344,8 @@ static int e1000_alloc_ring_dma(struct e1000_adapter *adapter,
 {
 	struct pci_dev *pdev = adapter->pdev;
 
-	ring->desc = pci_alloc_consistent(pdev, ring->size, &ring->dma);
+	ring->desc = dma_alloc_coherent(&pdev->dev, ring->size, &ring->dma,
+					GFP_KERNEL);
 	if (!ring->desc)
 		return -ENOMEM;
 
@@ -1479,7 +1480,8 @@ void e1000e_free_tx_resources(struct e1000_adapter *adapter)
 	vfree(tx_ring->buffer_info);
 	tx_ring->buffer_info = NULL;
 
-	pci_free_consistent(pdev, tx_ring->size, tx_ring->desc, tx_ring->dma);
+	dma_free_coherent(&pdev->dev, tx_ring->size, tx_ring->desc,
+			  tx_ring->dma);
 	tx_ring->desc = NULL;
 }
 
@@ -1503,7 +1505,8 @@ void e1000e_free_rx_resources(struct e1000_adapter *adapter)
 	kfree(rx_ring->ps_pages);
 	rx_ring->ps_pages = NULL;
 
-	pci_free_consistent(pdev, rx_ring->size, rx_ring->desc, rx_ring->dma);
+	dma_free_coherent(&pdev->dev, rx_ring->size, rx_ring->desc,
+			  rx_ring->dma);
 	rx_ring->desc = NULL;
 }
 
