From: Romain Perier <romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Subject: [PATCH v8 14/15] scsi: pmcraid: Replace PCI pool old API
Date: Fri, 28 Apr 2017 16:27:21 +0200
Message-ID: <20170428142722.1282-15-romain.perier@collabora.com>
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
Tested-by: Peter Senna Tschudin <peter.senna-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
---
 drivers/scsi/pmcraid.c | 10 +++++-----
 drivers/scsi/pmcraid.h |  2 +-
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/scsi/pmcraid.c b/drivers/scsi/pmcraid.c
index a4aadf5f4dc6..0d1f520e4d8a 100644
--- a/drivers/scsi/pmcraid.c
+++ b/drivers/scsi/pmcraid.c
@@ -4658,13 +4658,13 @@ pmcraid_release_control_blocks(
 		return;
 
 	for (i = 0; i < max_index; i++) {
-		pci_pool_free(pinstance->control_pool,
+		dma_pool_free(pinstance->control_pool,
 			      pinstance->cmd_list[i]->ioa_cb,
 			      pinstance->cmd_list[i]->ioa_cb_bus_addr);
 		pinstance->cmd_list[i]->ioa_cb = NULL;
 		pinstance->cmd_list[i]->ioa_cb_bus_addr = 0;
 	}
-	pci_pool_destroy(pinstance->control_pool);
+	dma_pool_destroy(pinstance->control_pool);
 	pinstance->control_pool = NULL;
 }
 
@@ -4721,8 +4721,8 @@ static int pmcraid_allocate_control_blocks(struct pmcraid_instance *pinstance)
 		pinstance->host->unique_id);
 
 	pinstance->control_pool =
-		pci_pool_create(pinstance->ctl_pool_name,
-				pinstance->pdev,
+		dma_pool_create(pinstance->ctl_pool_name,
+				&pinstance->pdev->dev,
 				sizeof(struct pmcraid_control_block),
 				PMCRAID_IOARCB_ALIGNMENT, 0);
 
@@ -4731,7 +4731,7 @@ static int pmcraid_allocate_control_blocks(struct pmcraid_instance *pinstance)
 
 	for (i = 0; i < PMCRAID_MAX_CMD; i++) {
 		pinstance->cmd_list[i]->ioa_cb =
-			pci_pool_alloc(
+			dma_pool_alloc(
 				pinstance->control_pool,
 				GFP_KERNEL,
 				&(pinstance->cmd_list[i]->ioa_cb_bus_addr));
diff --git a/drivers/scsi/pmcraid.h b/drivers/scsi/pmcraid.h
index 01eb2bc16dc1..8bfac72a242b 100644
--- a/drivers/scsi/pmcraid.h
+++ b/drivers/scsi/pmcraid.h
@@ -755,7 +755,7 @@ struct pmcraid_instance {
 
 	/* structures related to command blocks */
 	struct kmem_cache *cmd_cachep;		/* cache for cmd blocks */
-	struct pci_pool *control_pool;		/* pool for control blocks */
+	struct dma_pool *control_pool;		/* pool for control blocks */
 	char   cmd_pool_name[64];		/* name of cmd cache */
 	char   ctl_pool_name[64];		/* name of control cache */
 
-- 
2.11.0

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
