From: Romain Perier <romain.perier@collabora.com>
Subject: [PATCH v7 12/15] scsi: mpt3sas: Replace PCI pool old API
Date: Fri,  7 Apr 2017 09:25:40 +0200
Message-ID: <20170407072543.6936-13-romain.perier@collabora.com>
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
Received: from bhuna.collabora.co.uk ([46.235.227.227]:55877 "EHLO
        bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932595AbdDGH0r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 03:26:47 -0400
In-Reply-To: <20170407072543.6936-1-romain.perier@collabora.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PCI pool API is deprecated. This commit replaces the PCI pool old
API by the appropriate function with the DMA pool API.

Signed-off-by: Romain Perier <romain.perier@collabora.com>
Reviewed-by: Peter Senna Tschudin <peter.senna@collabora.com>
---
 drivers/scsi/mpt3sas/mpt3sas_base.c | 73 +++++++++++++++++--------------------
 1 file changed, 34 insertions(+), 39 deletions(-)

diff --git a/drivers/scsi/mpt3sas/mpt3sas_base.c b/drivers/scsi/mpt3sas/mpt3sas_base.c
index 5b7aec5..5ae1c23 100644
--- a/drivers/scsi/mpt3sas/mpt3sas_base.c
+++ b/drivers/scsi/mpt3sas/mpt3sas_base.c
@@ -3200,9 +3200,8 @@ _base_release_memory_pools(struct MPT3SAS_ADAPTER *ioc)
 	}
 
 	if (ioc->sense) {
-		pci_pool_free(ioc->sense_dma_pool, ioc->sense, ioc->sense_dma);
-		if (ioc->sense_dma_pool)
-			pci_pool_destroy(ioc->sense_dma_pool);
+		dma_pool_free(ioc->sense_dma_pool, ioc->sense, ioc->sense_dma);
+		dma_pool_destroy(ioc->sense_dma_pool);
 		dexitprintk(ioc, pr_info(MPT3SAS_FMT
 			"sense_pool(0x%p): free\n",
 			ioc->name, ioc->sense));
@@ -3210,9 +3209,8 @@ _base_release_memory_pools(struct MPT3SAS_ADAPTER *ioc)
 	}
 
 	if (ioc->reply) {
-		pci_pool_free(ioc->reply_dma_pool, ioc->reply, ioc->reply_dma);
-		if (ioc->reply_dma_pool)
-			pci_pool_destroy(ioc->reply_dma_pool);
+		dma_pool_free(ioc->reply_dma_pool, ioc->reply, ioc->reply_dma);
+		dma_pool_destroy(ioc->reply_dma_pool);
 		dexitprintk(ioc, pr_info(MPT3SAS_FMT
 			"reply_pool(0x%p): free\n",
 			ioc->name, ioc->reply));
@@ -3220,10 +3218,9 @@ _base_release_memory_pools(struct MPT3SAS_ADAPTER *ioc)
 	}
 
 	if (ioc->reply_free) {
-		pci_pool_free(ioc->reply_free_dma_pool, ioc->reply_free,
+		dma_pool_free(ioc->reply_free_dma_pool, ioc->reply_free,
 		    ioc->reply_free_dma);
-		if (ioc->reply_free_dma_pool)
-			pci_pool_destroy(ioc->reply_free_dma_pool);
+		dma_pool_destroy(ioc->reply_free_dma_pool);
 		dexitprintk(ioc, pr_info(MPT3SAS_FMT
 			"reply_free_pool(0x%p): free\n",
 			ioc->name, ioc->reply_free));
@@ -3234,7 +3231,7 @@ _base_release_memory_pools(struct MPT3SAS_ADAPTER *ioc)
 		do {
 			rps = &ioc->reply_post[i];
 			if (rps->reply_post_free) {
-				pci_pool_free(
+				dma_pool_free(
 				    ioc->reply_post_free_dma_pool,
 				    rps->reply_post_free,
 				    rps->reply_post_free_dma);
@@ -3246,8 +3243,7 @@ _base_release_memory_pools(struct MPT3SAS_ADAPTER *ioc)
 		} while (ioc->rdpq_array_enable &&
 			   (++i < ioc->reply_queue_count));
 
-		if (ioc->reply_post_free_dma_pool)
-			pci_pool_destroy(ioc->reply_post_free_dma_pool);
+		dma_pool_destroy(ioc->reply_post_free_dma_pool);
 		kfree(ioc->reply_post);
 	}
 
@@ -3268,12 +3264,11 @@ _base_release_memory_pools(struct MPT3SAS_ADAPTER *ioc)
 	if (ioc->chain_lookup) {
 		for (i = 0; i < ioc->chain_depth; i++) {
 			if (ioc->chain_lookup[i].chain_buffer)
-				pci_pool_free(ioc->chain_dma_pool,
+				dma_pool_free(ioc->chain_dma_pool,
 				    ioc->chain_lookup[i].chain_buffer,
 				    ioc->chain_lookup[i].chain_buffer_dma);
 		}
-		if (ioc->chain_dma_pool)
-			pci_pool_destroy(ioc->chain_dma_pool);
+		dma_pool_destroy(ioc->chain_dma_pool);
 		free_pages((ulong)ioc->chain_lookup, ioc->chain_pages);
 		ioc->chain_lookup = NULL;
 	}
@@ -3448,23 +3443,23 @@ _base_allocate_memory_pools(struct MPT3SAS_ADAPTER *ioc)
 			ioc->name);
 		goto out;
 	}
-	ioc->reply_post_free_dma_pool = pci_pool_create("reply_post_free pool",
-	    ioc->pdev, sz, 16, 0);
+	ioc->reply_post_free_dma_pool = dma_pool_create("reply_post_free pool",
+	    &ioc->pdev->dev, sz, 16, 0);
 	if (!ioc->reply_post_free_dma_pool) {
 		pr_err(MPT3SAS_FMT
-		 "reply_post_free pool: pci_pool_create failed\n",
+		 "reply_post_free pool: dma_pool_create failed\n",
 		 ioc->name);
 		goto out;
 	}
 	i = 0;
 	do {
 		ioc->reply_post[i].reply_post_free =
-		    pci_pool_alloc(ioc->reply_post_free_dma_pool,
+		    dma_pool_alloc(ioc->reply_post_free_dma_pool,
 		    GFP_KERNEL,
 		    &ioc->reply_post[i].reply_post_free_dma);
 		if (!ioc->reply_post[i].reply_post_free) {
 			pr_err(MPT3SAS_FMT
-			"reply_post_free pool: pci_pool_alloc failed\n",
+			"reply_post_free pool: dma_pool_alloc failed\n",
 			ioc->name);
 			goto out;
 		}
@@ -3579,15 +3574,15 @@ _base_allocate_memory_pools(struct MPT3SAS_ADAPTER *ioc)
 			ioc->name);
 		goto out;
 	}
-	ioc->chain_dma_pool = pci_pool_create("chain pool", ioc->pdev,
+	ioc->chain_dma_pool = dma_pool_create("chain pool", &ioc->pdev->dev,
 	    ioc->chain_segment_sz, 16, 0);
 	if (!ioc->chain_dma_pool) {
-		pr_err(MPT3SAS_FMT "chain_dma_pool: pci_pool_create failed\n",
+		pr_err(MPT3SAS_FMT "chain_dma_pool: dma_pool_create failed\n",
 			ioc->name);
 		goto out;
 	}
 	for (i = 0; i < ioc->chain_depth; i++) {
-		ioc->chain_lookup[i].chain_buffer = pci_pool_alloc(
+		ioc->chain_lookup[i].chain_buffer = dma_pool_alloc(
 		    ioc->chain_dma_pool , GFP_KERNEL,
 		    &ioc->chain_lookup[i].chain_buffer_dma);
 		if (!ioc->chain_lookup[i].chain_buffer) {
@@ -3632,17 +3627,17 @@ _base_allocate_memory_pools(struct MPT3SAS_ADAPTER *ioc)
 
 	/* sense buffers, 4 byte align */
 	sz = ioc->scsiio_depth * SCSI_SENSE_BUFFERSIZE;
-	ioc->sense_dma_pool = pci_pool_create("sense pool", ioc->pdev, sz, 4,
-	    0);
+	ioc->sense_dma_pool = dma_pool_create("sense pool", &ioc->pdev->dev, sz,
+					      4, 0);
 	if (!ioc->sense_dma_pool) {
-		pr_err(MPT3SAS_FMT "sense pool: pci_pool_create failed\n",
+		pr_err(MPT3SAS_FMT "sense pool: dma_pool_create failed\n",
 		    ioc->name);
 		goto out;
 	}
-	ioc->sense = pci_pool_alloc(ioc->sense_dma_pool , GFP_KERNEL,
+	ioc->sense = dma_pool_alloc(ioc->sense_dma_pool, GFP_KERNEL,
 	    &ioc->sense_dma);
 	if (!ioc->sense) {
-		pr_err(MPT3SAS_FMT "sense pool: pci_pool_alloc failed\n",
+		pr_err(MPT3SAS_FMT "sense pool: dma_pool_alloc failed\n",
 		    ioc->name);
 		goto out;
 	}
@@ -3656,17 +3651,17 @@ _base_allocate_memory_pools(struct MPT3SAS_ADAPTER *ioc)
 
 	/* reply pool, 4 byte align */
 	sz = ioc->reply_free_queue_depth * ioc->reply_sz;
-	ioc->reply_dma_pool = pci_pool_create("reply pool", ioc->pdev, sz, 4,
-	    0);
+	ioc->reply_dma_pool = dma_pool_create("reply pool", &ioc->pdev->dev, sz,
+					      4, 0);
 	if (!ioc->reply_dma_pool) {
-		pr_err(MPT3SAS_FMT "reply pool: pci_pool_create failed\n",
+		pr_err(MPT3SAS_FMT "reply pool: dma_pool_create failed\n",
 		    ioc->name);
 		goto out;
 	}
-	ioc->reply = pci_pool_alloc(ioc->reply_dma_pool , GFP_KERNEL,
+	ioc->reply = dma_pool_alloc(ioc->reply_dma_pool, GFP_KERNEL,
 	    &ioc->reply_dma);
 	if (!ioc->reply) {
-		pr_err(MPT3SAS_FMT "reply pool: pci_pool_alloc failed\n",
+		pr_err(MPT3SAS_FMT "reply pool: dma_pool_alloc failed\n",
 		    ioc->name);
 		goto out;
 	}
@@ -3682,17 +3677,17 @@ _base_allocate_memory_pools(struct MPT3SAS_ADAPTER *ioc)
 
 	/* reply free queue, 16 byte align */
 	sz = ioc->reply_free_queue_depth * 4;
-	ioc->reply_free_dma_pool = pci_pool_create("reply_free pool",
-	    ioc->pdev, sz, 16, 0);
+	ioc->reply_free_dma_pool = dma_pool_create("reply_free pool",
+	    &ioc->pdev->dev, sz, 16, 0);
 	if (!ioc->reply_free_dma_pool) {
-		pr_err(MPT3SAS_FMT "reply_free pool: pci_pool_create failed\n",
+		pr_err(MPT3SAS_FMT "reply_free pool: dma_pool_create failed\n",
 			ioc->name);
 		goto out;
 	}
-	ioc->reply_free = pci_pool_alloc(ioc->reply_free_dma_pool , GFP_KERNEL,
+	ioc->reply_free = dma_pool_alloc(ioc->reply_free_dma_pool, GFP_KERNEL,
 	    &ioc->reply_free_dma);
 	if (!ioc->reply_free) {
-		pr_err(MPT3SAS_FMT "reply_free pool: pci_pool_alloc failed\n",
+		pr_err(MPT3SAS_FMT "reply_free pool: dma_pool_alloc failed\n",
 			ioc->name);
 		goto out;
 	}
@@ -3710,7 +3705,7 @@ _base_allocate_memory_pools(struct MPT3SAS_ADAPTER *ioc)
 	    ioc->config_page_sz, &ioc->config_page_dma);
 	if (!ioc->config_page) {
 		pr_err(MPT3SAS_FMT
-			"config page: pci_pool_alloc failed\n",
+			"config page: dma_pool_alloc failed\n",
 			ioc->name);
 		goto out;
 	}
-- 
2.9.3
