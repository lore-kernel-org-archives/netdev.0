From: Romain Perier <romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Subject: [PATCH v5 08/19] scsi: be2iscsi: Replace PCI pool old API
Date: Wed,  8 Mar 2017 17:19:46 +0100
Message-ID: <20170308161957.28941-9-romain.perier@collabora.com>
References: <20170308161957.28941-1-romain.perier@collabora.com>
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
In-Reply-To: <20170308161957.28941-1-romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The PCI pool API is deprecated. This commit replaces the PCI pool old
API by the appropriate function with the DMA pool API.

Signed-off-by: Romain Perier <romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Acked-by: Peter Senna Tschudin <peter.senna-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Tested-by: Peter Senna Tschudin <peter.senna-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
---
 drivers/scsi/be2iscsi/be_iscsi.c | 6 +++---
 drivers/scsi/be2iscsi/be_main.c  | 6 +++---
 drivers/scsi/be2iscsi/be_main.h  | 2 +-
 3 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/scsi/be2iscsi/be_iscsi.c b/drivers/scsi/be2iscsi/be_iscsi.c
index a484457..d76ef77 100644
--- a/drivers/scsi/be2iscsi/be_iscsi.c
+++ b/drivers/scsi/be2iscsi/be_iscsi.c
@@ -87,8 +87,8 @@ struct iscsi_cls_session *beiscsi_session_create(struct iscsi_endpoint *ep,
 		return NULL;
 	sess = cls_session->dd_data;
 	beiscsi_sess = sess->dd_data;
-	beiscsi_sess->bhs_pool =  pci_pool_create("beiscsi_bhs_pool",
-						   phba->pcidev,
+	beiscsi_sess->bhs_pool =  dma_pool_create("beiscsi_bhs_pool",
+						   &phba->pcidev->dev,
 						   sizeof(struct be_cmd_bhs),
 						   64, 0);
 	if (!beiscsi_sess->bhs_pool)
@@ -113,7 +113,7 @@ void beiscsi_session_destroy(struct iscsi_cls_session *cls_session)
 	struct beiscsi_session *beiscsi_sess = sess->dd_data;
 
 	printk(KERN_INFO "In beiscsi_session_destroy\n");
-	pci_pool_destroy(beiscsi_sess->bhs_pool);
+	dma_pool_destroy(beiscsi_sess->bhs_pool);
 	iscsi_session_teardown(cls_session);
 }
 
diff --git a/drivers/scsi/be2iscsi/be_main.c b/drivers/scsi/be2iscsi/be_main.c
index 32b2713..dd43480 100644
--- a/drivers/scsi/be2iscsi/be_main.c
+++ b/drivers/scsi/be2iscsi/be_main.c
@@ -4307,7 +4307,7 @@ static void beiscsi_cleanup_task(struct iscsi_task *task)
 	pwrb_context = &phwi_ctrlr->wrb_context[cri_index];
 
 	if (io_task->cmd_bhs) {
-		pci_pool_free(beiscsi_sess->bhs_pool, io_task->cmd_bhs,
+		dma_pool_free(beiscsi_sess->bhs_pool, io_task->cmd_bhs,
 			      io_task->bhs_pa.u.a64.address);
 		io_task->cmd_bhs = NULL;
 		task->hdr = NULL;
@@ -4424,7 +4424,7 @@ static int beiscsi_alloc_pdu(struct iscsi_task *task, uint8_t opcode)
 	struct beiscsi_session *beiscsi_sess = beiscsi_conn->beiscsi_sess;
 	dma_addr_t paddr;
 
-	io_task->cmd_bhs = pci_pool_alloc(beiscsi_sess->bhs_pool,
+	io_task->cmd_bhs = dma_pool_alloc(beiscsi_sess->bhs_pool,
 					  GFP_ATOMIC, &paddr);
 	if (!io_task->cmd_bhs)
 		return -ENOMEM;
@@ -4551,7 +4551,7 @@ static int beiscsi_alloc_pdu(struct iscsi_task *task, uint8_t opcode)
 	if (io_task->pwrb_handle)
 		free_wrb_handle(phba, pwrb_context, io_task->pwrb_handle);
 	io_task->pwrb_handle = NULL;
-	pci_pool_free(beiscsi_sess->bhs_pool, io_task->cmd_bhs,
+	dma_pool_free(beiscsi_sess->bhs_pool, io_task->cmd_bhs,
 		      io_task->bhs_pa.u.a64.address);
 	io_task->cmd_bhs = NULL;
 	return -ENOMEM;
diff --git a/drivers/scsi/be2iscsi/be_main.h b/drivers/scsi/be2iscsi/be_main.h
index 2188579..cf58d31 100644
--- a/drivers/scsi/be2iscsi/be_main.h
+++ b/drivers/scsi/be2iscsi/be_main.h
@@ -446,7 +446,7 @@ struct beiscsi_hba {
 	 test_bit(BEISCSI_HBA_ONLINE, &phba->state))
 
 struct beiscsi_session {
-	struct pci_pool *bhs_pool;
+	struct dma_pool *bhs_pool;
 };
 
 /**
-- 
2.9.3

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
