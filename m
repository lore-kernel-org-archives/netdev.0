From: Romain Perier <romain.perier@collabora.com>
Subject: [PATCH v4 09/19] scsi: csiostor: Replace PCI pool old API
Date: Wed,  1 Mar 2017 16:55:11 +0100
Message-ID: <20170301155521.30281-10-romain.perier@collabora.com>
References: <20170301155521.30281-1-romain.perier@collabora.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170301155521.30281-1-romain.perier@collabora.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The PCI pool API is deprecated. This commits replaces the PCI pool old
API by the appropriated function with the DMA pool API. It also updates
the name of some variables and the content of comments, accordingly.

Signed-off-by: Romain Perier <romain.perier@collabora.com>
Reviewed-by: Peter Senna Tschudin <peter.senna@collabora.com>
---
 drivers/scsi/csiostor/csio_hw.h   |  2 +-
 drivers/scsi/csiostor/csio_init.c | 11 ++++++-----
 drivers/scsi/csiostor/csio_scsi.c |  6 +++---
 3 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/drivers/scsi/csiostor/csio_hw.h b/drivers/scsi/csiostor/csio_hw.h
index 029bef8..55b04fc 100644
--- a/drivers/scsi/csiostor/csio_hw.h
+++ b/drivers/scsi/csiostor/csio_hw.h
@@ -465,7 +465,7 @@ struct csio_hw {
 	struct csio_pport	pport[CSIO_MAX_PPORTS];	/* Ports (XGMACs) */
 	struct csio_hw_params	params;			/* Hw parameters */
 
-	struct pci_pool		*scsi_pci_pool;		/* PCI pool for SCSI */
+	struct dma_pool		*scsi_dma_pool;		/* DMA pool for SCSI */
 	mempool_t		*mb_mempool;		/* Mailbox memory pool*/
 	mempool_t		*rnode_mempool;		/* rnode memory pool */
 
diff --git a/drivers/scsi/csiostor/csio_init.c b/drivers/scsi/csiostor/csio_init.c
index dbe416f..292964c 100644
--- a/drivers/scsi/csiostor/csio_init.c
+++ b/drivers/scsi/csiostor/csio_init.c
@@ -485,9 +485,10 @@ csio_resource_alloc(struct csio_hw *hw)
 	if (!hw->rnode_mempool)
 		goto err_free_mb_mempool;
 
-	hw->scsi_pci_pool = pci_pool_create("csio_scsi_pci_pool", hw->pdev,
-					    CSIO_SCSI_RSP_LEN, 8, 0);
-	if (!hw->scsi_pci_pool)
+	hw->scsi_dma_pool = dma_pool_create("csio_scsi_dma_pool",
+					    &hw->pdev->dev, CSIO_SCSI_RSP_LEN,
+					    8, 0);
+	if (!hw->scsi_dma_pool)
 		goto err_free_rn_pool;
 
 	return 0;
@@ -505,8 +506,8 @@ csio_resource_alloc(struct csio_hw *hw)
 static void
 csio_resource_free(struct csio_hw *hw)
 {
-	pci_pool_destroy(hw->scsi_pci_pool);
-	hw->scsi_pci_pool = NULL;
+	dma_pool_destroy(hw->scsi_dma_pool);
+	hw->scsi_dma_pool = NULL;
 	mempool_destroy(hw->rnode_mempool);
 	hw->rnode_mempool = NULL;
 	mempool_destroy(hw->mb_mempool);
diff --git a/drivers/scsi/csiostor/csio_scsi.c b/drivers/scsi/csiostor/csio_scsi.c
index a1ff75f..dab0d3f 100644
--- a/drivers/scsi/csiostor/csio_scsi.c
+++ b/drivers/scsi/csiostor/csio_scsi.c
@@ -2445,7 +2445,7 @@ csio_scsim_init(struct csio_scsim *scm, struct csio_hw *hw)
 
 		/* Allocate Dma buffers for Response Payload */
 		dma_buf = &ioreq->dma_buf;
-		dma_buf->vaddr = pci_pool_alloc(hw->scsi_pci_pool, GFP_KERNEL,
+		dma_buf->vaddr = dma_pool_alloc(hw->scsi_dma_pool, GFP_KERNEL,
 						&dma_buf->paddr);
 		if (!dma_buf->vaddr) {
 			csio_err(hw,
@@ -2485,7 +2485,7 @@ csio_scsim_init(struct csio_scsim *scm, struct csio_hw *hw)
 		ioreq = (struct csio_ioreq *)tmp;
 
 		dma_buf = &ioreq->dma_buf;
-		pci_pool_free(hw->scsi_pci_pool, dma_buf->vaddr,
+		dma_pool_free(hw->scsi_dma_pool, dma_buf->vaddr,
 			      dma_buf->paddr);
 
 		kfree(ioreq);
@@ -2516,7 +2516,7 @@ csio_scsim_exit(struct csio_scsim *scm)
 		ioreq = (struct csio_ioreq *)tmp;
 
 		dma_buf = &ioreq->dma_buf;
-		pci_pool_free(scm->hw->scsi_pci_pool, dma_buf->vaddr,
+		dma_pool_free(scm->hw->scsi_dma_pool, dma_buf->vaddr,
 			      dma_buf->paddr);
 
 		kfree(ioreq);
-- 
2.9.3
