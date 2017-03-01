From: Romain Perier <romain.perier@collabora.com>
Subject: [PATCH v4 14/19] scsi: pmcraid: Replace PCI pool old API
Date: Wed,  1 Mar 2017 16:55:16 +0100
Message-ID: <20170301155521.30281-15-romain.perier@collabora.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([46.235.227.227]:44316 "EHLO
        bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753064AbdCAP4x (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Mar 2017 10:56:53 -0500
In-Reply-To: <20170301155521.30281-1-romain.perier@collabora.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PCI pool API is deprecated. This commits replaces the PCI pool old
API by the appropriated function with the DMA pool API.

Signed-off-by: Romain Perier <romain.perier@collabora.com>
Acked-by: Peter Senna Tschudin <peter.senna@collabora.com>
Tested-by: Peter Senna Tschudin <peter.senna@collabora.com>
---
 drivers/scsi/pmcraid.c | 10 +++++-----
 drivers/scsi/pmcraid.h |  2 +-
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/scsi/pmcraid.c b/drivers/scsi/pmcraid.c
index 49e70a3..0f893c4 100644
--- a/drivers/scsi/pmcraid.c
+++ b/drivers/scsi/pmcraid.c
@@ -4699,13 +4699,13 @@ pmcraid_release_control_blocks(
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
 
@@ -4762,8 +4762,8 @@ static int pmcraid_allocate_control_blocks(struct pmcraid_instance *pinstance)
 		pinstance->host->unique_id);
 
 	pinstance->control_pool =
-		pci_pool_create(pinstance->ctl_pool_name,
-				pinstance->pdev,
+		dma_pool_create(pinstance->ctl_pool_name,
+				&pinstance->pdev->dev,
 				sizeof(struct pmcraid_control_block),
 				PMCRAID_IOARCB_ALIGNMENT, 0);
 
@@ -4772,7 +4772,7 @@ static int pmcraid_allocate_control_blocks(struct pmcraid_instance *pinstance)
 
 	for (i = 0; i < PMCRAID_MAX_CMD; i++) {
 		pinstance->cmd_list[i]->ioa_cb =
-			pci_pool_alloc(
+			dma_pool_alloc(
 				pinstance->control_pool,
 				GFP_KERNEL,
 				&(pinstance->cmd_list[i]->ioa_cb_bus_addr));
diff --git a/drivers/scsi/pmcraid.h b/drivers/scsi/pmcraid.h
index 568b18a..acf5a7b 100644
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
2.9.3
