From: Romain Perier <romain.perier@collabora.com>
Subject: [PATCH v11 4/8] net: e100: Replace PCI pool old API
Date: Wed,  9 Aug 2017 10:28:21 +0200
Message-ID: <20170809082825.9226-5-romain.perier@collabora.com>
References: <20170809082825.9226-1-romain.perier@collabora.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Romain Perier <romain.perier@collabora.com>
To: Dan Williams <dan.j.williams@intel.com>,
        Doug Ledford <dledford@redhat.com>,
        Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        jeffrey.t.kirsher@intel.com,
        "David S. Miller" <davem@davemloft.net>, stas.yakovlev@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170809082825.9226-1-romain.perier@collabora.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
index 4d10270ddf8f..d1470d30351c 100644
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
 
-	nic->cbs = pci_pool_alloc(nic->cbs_pool, GFP_KERNEL,
+	nic->cbs = dma_pool_alloc(nic->cbs_pool, GFP_KERNEL,
 				  &nic->cbs_dma_addr);
 	if (!nic->cbs)
 		return -ENOMEM;
@@ -2961,8 +2961,8 @@ static int e100_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
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
@@ -3002,7 +3002,7 @@ static void e100_remove(struct pci_dev *pdev)
 		unregister_netdev(netdev);
 		e100_free(nic);
 		pci_iounmap(pdev, nic->csr);
-		pci_pool_destroy(nic->cbs_pool);
+		dma_pool_destroy(nic->cbs_pool);
 		free_netdev(netdev);
 		pci_release_regions(pdev);
 		pci_disable_device(pdev);
-- 
2.11.0
