From: Romain Perier <romain.perier@gmail.com>
Subject: [PATCH v14 3/5] net: e100: Replace PCI pool old API
Date: Mon, 23 Oct 2017 19:59:56 +0200
Message-ID: <20171023175958.8327-4-romain.perier@gmail.com>
References: <20171023175958.8327-1-romain.perier@gmail.com>
Cc: dmaengine@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Romain Perier <romain.perier@collabora.com>
To: Jens Axboe <axboe@kernel.dk>,
        Andrew Morton <akpm@linux-foundation.org>,
        Dan Williams <dan.j.williams@intel.com>,
        Vinod Koul <vinod.koul@intel.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Aviad Krawczyk <aviad.krawczyk@huawei.com>,
        Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:55118 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932143AbdJWSAX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 14:00:23 -0400
In-Reply-To: <20171023175958.8327-1-romain.perier@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Romain Perier <romain.perier@collabora.com>

The PCI pool API is deprecated. This commit replaces the PCI pool old
API by the appropriate function with the DMA pool API.

Signed-off-by: Romain Perier <romain.perier@collabora.com>
Acked-by: Peter Senna Tschudin <peter.senna@collabora.com>
Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Tested-by: Peter Senna Tschudin <peter.senna@collabora.com>
---
 drivers/net/ethernet/intel/e100.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/intel/e100.c
index 184f11242f56..ba52475b9ff0 100644
--- a/drivers/net/ethernet/intel/e100.c
+++ b/drivers/net/ethernet/intel/e100.c
@@ -607,7 +607,7 @@ struct nic {
 	struct mem *mem;
 	dma_addr_t dma_addr;
 
-	struct pci_pool *cbs_pool;
+	struct dma_pool *cbs_pool;
 	dma_addr_t cbs_dma_addr;
 	u8 adaptive_ifs;
 	u8 tx_threshold;
@@ -1892,7 +1892,7 @@ static void e100_clean_cbs(struct nic *nic)
 			nic->cb_to_clean = nic->cb_to_clean->next;
 			nic->cbs_avail++;
 		}
-		pci_pool_free(nic->cbs_pool, nic->cbs, nic->cbs_dma_addr);
+		dma_pool_free(nic->cbs_pool, nic->cbs, nic->cbs_dma_addr);
 		nic->cbs = NULL;
 		nic->cbs_avail = 0;
 	}
@@ -1910,7 +1910,7 @@ static int e100_alloc_cbs(struct nic *nic)
 	nic->cb_to_use = nic->cb_to_send = nic->cb_to_clean = NULL;
 	nic->cbs_avail = 0;
 
-	nic->cbs = pci_pool_zalloc(nic->cbs_pool, GFP_KERNEL,
+	nic->cbs = dma_pool_zalloc(nic->cbs_pool, GFP_KERNEL,
 				   &nic->cbs_dma_addr);
 	if (!nic->cbs)
 		return -ENOMEM;
@@ -2960,8 +2960,8 @@ static int e100_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		netif_err(nic, probe, nic->netdev, "Cannot register net device, aborting\n");
 		goto err_out_free;
 	}
-	nic->cbs_pool = pci_pool_create(netdev->name,
-			   nic->pdev,
+	nic->cbs_pool = dma_pool_create(netdev->name,
+			   &nic->pdev->dev,
 			   nic->params.cbs.max * sizeof(struct cb),
 			   sizeof(u32),
 			   0);
@@ -3001,7 +3001,7 @@ static void e100_remove(struct pci_dev *pdev)
 		unregister_netdev(netdev);
 		e100_free(nic);
 		pci_iounmap(pdev, nic->csr);
-		pci_pool_destroy(nic->cbs_pool);
+		dma_pool_destroy(nic->cbs_pool);
 		free_netdev(netdev);
 		pci_release_regions(pdev);
 		pci_disable_device(pdev);
-- 
2.14.1
