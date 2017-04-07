From: Romain Perier <romain.perier@collabora.com>
Subject: [PATCH v7 08/15] scsi: be2iscsi: Replace PCI pool old API
Date: Fri,  7 Apr 2017 09:25:36 +0200
Message-ID: <20170407072543.6936-9-romain.perier@collabora.com>
References: <20170407072543.6936-1-romain.perier@collabora.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org, linux-scsi@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Romain Perier <romain.perier@collabora.com>,
        Peter Senna Tschudin <peter.senna@collabora.co.uk>
To: Dan Williams <dan.j.williams@intel.com>,
        Doug Ledford <dledford@redhat.com>,
        Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        jeffrey.t.kirsher@intel.com,
        "David S. Miller" <davem@davemloft.net>, stas.yakovlev@gmail.com,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        "Martin K. Petersen" <martin.petersen@oracle.com>,
        Felipe Balbi <balbi@kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([46.235.227.227]:55841 "EHLO
        bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754444AbdDGH02 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 03:26:28 -0400
In-Reply-To: <20170407072543.6936-1-romain.perier@collabora.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PCI pool API is deprecated. This commit replaces the PCI pool old
API by the appropriate function with the DMA pool API.

Signed-off-by: Romain Perier <romain.perier@collabora.com>
Acked-by: Peter Senna Tschudin <peter.senna@collabora.com>
Tested-by: Peter Senna Tschudin <peter.senna@collabora.com>
---
 drivers/scsi/be2iscsi/be_iscsi.c | 6 +++---
 drivers/scsi/be2iscsi/be_main.c  | 6 +++---
 drivers/scsi/be2iscsi/be_main.h  | 2 +-
 3 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/scsi/be2iscsi/be_iscsi.c b/drivers/scsi/be2iscsi/be_iscsi.c
index 97dca46..43a80ce 100644
--- a/drivers/scsi/be2iscsi/be_iscsi.c
+++ b/drivers/scsi/be2iscsi/be_iscsi.c
@@ -82,8 +82,8 @@ struct iscsi_cls_session *beiscsi_session_create(struct iscsi_endpoint *ep,
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
@@ -108,7 +108,7 @@ void beiscsi_session_destroy(struct iscsi_cls_session *cls_session)
 	struct beiscsi_session *beiscsi_sess = sess->dd_data;
 
 	printk(KERN_INFO "In beiscsi_session_destroy\n");
-	pci_pool_destroy(beiscsi_sess->bhs_pool);
+	dma_pool_destroy(beiscsi_sess->bhs_pool);
 	iscsi_session_teardown(cls_session);
 }
 
diff --git a/drivers/scsi/be2iscsi/be_main.c b/drivers/scsi/be2iscsi/be_main.c
index f862332..b4542e7 100644
--- a/drivers/scsi/be2iscsi/be_main.c
+++ b/drivers/scsi/be2iscsi/be_main.c
@@ -4257,7 +4257,7 @@ static void beiscsi_cleanup_task(struct iscsi_task *task)
 	pwrb_context = &phwi_ctrlr->wrb_context[cri_index];
 
 	if (io_task->cmd_bhs) {
-		pci_pool_free(beiscsi_sess->bhs_pool, io_task->cmd_bhs,
+		dma_pool_free(beiscsi_sess->bhs_pool, io_task->cmd_bhs,
 			      io_task->bhs_pa.u.a64.address);
 		io_task->cmd_bhs = NULL;
 		task->hdr = NULL;
@@ -4374,7 +4374,7 @@ static int beiscsi_alloc_pdu(struct iscsi_task *task, uint8_t opcode)
 	struct beiscsi_session *beiscsi_sess = beiscsi_conn->beiscsi_sess;
 	dma_addr_t paddr;
 
-	io_task->cmd_bhs = pci_pool_alloc(beiscsi_sess->bhs_pool,
+	io_task->cmd_bhs = dma_pool_alloc(beiscsi_sess->bhs_pool,
 					  GFP_ATOMIC, &paddr);
 	if (!io_task->cmd_bhs)
 		return -ENOMEM;
@@ -4501,7 +4501,7 @@ static int beiscsi_alloc_pdu(struct iscsi_task *task, uint8_t opcode)
 	if (io_task->pwrb_handle)
 		free_wrb_handle(phba, pwrb_context, io_task->pwrb_handle);
 	io_task->pwrb_handle = NULL;
-	pci_pool_free(beiscsi_sess->bhs_pool, io_task->cmd_bhs,
+	dma_pool_free(beiscsi_sess->bhs_pool, io_task->cmd_bhs,
 		      io_task->bhs_pa.u.a64.address);
 	io_task->cmd_bhs = NULL;
 	return -ENOMEM;
diff --git a/drivers/scsi/be2iscsi/be_main.h b/drivers/scsi/be2iscsi/be_main.h
index 338dbe0..81ce3ff 100644
--- a/drivers/scsi/be2iscsi/be_main.h
+++ b/drivers/scsi/be2iscsi/be_main.h
@@ -438,7 +438,7 @@ struct beiscsi_hba {
 	 test_bit(BEISCSI_HBA_ONLINE, &phba->state))
 
 struct beiscsi_session {
-	struct pci_pool *bhs_pool;
+	struct dma_pool *bhs_pool;
 };
 
 /**
-- 
2.9.3
