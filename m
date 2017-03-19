From: Romain Perier <romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Subject: [PATCH v6 13/15] scsi: mvsas: Replace PCI pool old API
Date: Sun, 19 Mar 2017 18:04:02 +0100
Message-ID: <20170319170404.17362-14-romain.perier@collabora.com>
References: <20170319170404.17362-1-romain.perier@collabora.com>
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
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170319170404.17362-1-romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The PCI pool API is deprecated. This commit replaces the PCI pool old
API by the appropriate function with the DMA pool API.

Signed-off-by: Romain Perier <romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Reviewed-by: Peter Senna Tschudin <peter.senna-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
---
 drivers/scsi/mvsas/mv_init.c | 6 +++---
 drivers/scsi/mvsas/mv_sas.c  | 6 +++---
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/scsi/mvsas/mv_init.c b/drivers/scsi/mvsas/mv_init.c
index 8280046..41d2276 100644
--- a/drivers/scsi/mvsas/mv_init.c
+++ b/drivers/scsi/mvsas/mv_init.c
@@ -125,8 +125,7 @@ static void mvs_free(struct mvs_info *mvi)
 	else
 		slot_nr = MVS_CHIP_SLOT_SZ;
 
-	if (mvi->dma_pool)
-		pci_pool_destroy(mvi->dma_pool);
+	dma_pool_destroy(mvi->dma_pool);
 
 	if (mvi->tx)
 		dma_free_coherent(mvi->dev,
@@ -296,7 +295,8 @@ static int mvs_alloc(struct mvs_info *mvi, struct Scsi_Host *shost)
 		goto err_out;
 
 	sprintf(pool_name, "%s%d", "mvs_dma_pool", mvi->id);
-	mvi->dma_pool = pci_pool_create(pool_name, mvi->pdev, MVS_SLOT_BUF_SZ, 16, 0);
+	mvi->dma_pool = dma_pool_create(pool_name, &mvi->pdev->dev,
+					MVS_SLOT_BUF_SZ, 16, 0);
 	if (!mvi->dma_pool) {
 			printk(KERN_DEBUG "failed to create dma pool %s.\n", pool_name);
 			goto err_out;
diff --git a/drivers/scsi/mvsas/mv_sas.c b/drivers/scsi/mvsas/mv_sas.c
index c7cc803..ee81d10 100644
--- a/drivers/scsi/mvsas/mv_sas.c
+++ b/drivers/scsi/mvsas/mv_sas.c
@@ -790,7 +790,7 @@ static int mvs_task_prep(struct sas_task *task, struct mvs_info *mvi, int is_tmf
 	slot->n_elem = n_elem;
 	slot->slot_tag = tag;
 
-	slot->buf = pci_pool_alloc(mvi->dma_pool, GFP_ATOMIC, &slot->buf_dma);
+	slot->buf = dma_pool_alloc(mvi->dma_pool, GFP_ATOMIC, &slot->buf_dma);
 	if (!slot->buf) {
 		rc = -ENOMEM;
 		goto err_out_tag;
@@ -840,7 +840,7 @@ static int mvs_task_prep(struct sas_task *task, struct mvs_info *mvi, int is_tmf
 	return rc;
 
 err_out_slot_buf:
-	pci_pool_free(mvi->dma_pool, slot->buf, slot->buf_dma);
+	dma_pool_free(mvi->dma_pool, slot->buf, slot->buf_dma);
 err_out_tag:
 	mvs_tag_free(mvi, tag);
 err_out:
@@ -918,7 +918,7 @@ static void mvs_slot_task_free(struct mvs_info *mvi, struct sas_task *task,
 	}
 
 	if (slot->buf) {
-		pci_pool_free(mvi->dma_pool, slot->buf, slot->buf_dma);
+		dma_pool_free(mvi->dma_pool, slot->buf, slot->buf_dma);
 		slot->buf = NULL;
 	}
 	list_del_init(&slot->entry);
-- 
2.9.3

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
