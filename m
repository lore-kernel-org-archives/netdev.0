From: Romain Perier <romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Subject: [PATCH v8 04/15] net: e100: Replace PCI pool old API
Date: Fri, 28 Apr 2017 16:27:11 +0200
Message-ID: <20170428142722.1282-5-romain.perier@collabora.com>
References: <20170428142722.1282-1-romain.perier@collabora.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Romain Perier <romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>,
        Peter Senna Tschudin <peter.senna-ZGY8ohtN/8pPYcu2f3hruQ@public.gmane.org>
To: Dan Williams <dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, stas.yakovlev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        "James E.J. Bottomley" <jejb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
        "Martin K. Petersen" <martin.petersen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        Felipe Balbi <balbi-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170428142722.1282-1-romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The PCI pool API is deprecated. This commit replaces the PCI pool old
API by the appropriate function with the DMA pool API.

Signed-off-by: Romain Perier <romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Acked-by: Peter Senna Tschudin <peter.senna-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Acked-by: Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Tested-by: Peter Senna Tschudin <peter.senna-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
---
 drivers/net/ethernet/intel/e100.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/intel/e100.c
index 2b7323d392dc..d1002c21ce8c 100644
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
@@ -2958,8 +2958,8 @@ static int e100_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
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
@@ -2999,7 +2999,7 @@ static void e100_remove(struct pci_dev *pdev)
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

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
