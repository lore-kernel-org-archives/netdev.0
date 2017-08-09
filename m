From: Romain Perier <romain.perier@collabora.com>
Subject: [PATCH v11 3/8] IB/mthca: Replace PCI pool old API
Date: Wed,  9 Aug 2017 10:28:20 +0200
Message-ID: <20170809082825.9226-4-romain.perier@collabora.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([46.235.227.227]:42203 "EHLO
        bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752684AbdHII3E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 04:29:04 -0400
In-Reply-To: <20170809082825.9226-1-romain.perier@collabora.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PCI pool API is deprecated. This commit replaces the PCI pool old
API by the appropriate function with the DMA pool API.

Signed-off-by: Romain Perier <romain.perier@collabora.com>
Acked-by: Peter Senna Tschudin <peter.senna@collabora.com>
Tested-by: Peter Senna Tschudin <peter.senna@collabora.com>
Acked-by: Doug Ledford <dledford@redhat.com>
Tested-by: Doug Ledford <dledford@redhat.com>
---
 drivers/infiniband/hw/mthca/mthca_av.c  | 10 +++++-----
 drivers/infiniband/hw/mthca/mthca_cmd.c |  8 ++++----
 drivers/infiniband/hw/mthca/mthca_dev.h |  4 ++--
 3 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/infiniband/hw/mthca/mthca_av.c b/drivers/infiniband/hw/mthca/mthca_av.c
index 2aec9908c40a..e7f6223e9c60 100644
--- a/drivers/infiniband/hw/mthca/mthca_av.c
+++ b/drivers/infiniband/hw/mthca/mthca_av.c
@@ -186,7 +186,7 @@ int mthca_create_ah(struct mthca_dev *dev,
 
 on_hca_fail:
 	if (ah->type == MTHCA_AH_PCI_POOL) {
-		ah->av = pci_pool_zalloc(dev->av_table.pool,
+		ah->av = dma_pool_zalloc(dev->av_table.pool,
 					 GFP_ATOMIC, &ah->avdma);
 		if (!ah->av)
 			return -ENOMEM;
@@ -250,7 +250,7 @@ int mthca_destroy_ah(struct mthca_dev *dev, struct mthca_ah *ah)
 		break;
 
 	case MTHCA_AH_PCI_POOL:
-		pci_pool_free(dev->av_table.pool, ah->av, ah->avdma);
+		dma_pool_free(dev->av_table.pool, ah->av, ah->avdma);
 		break;
 
 	case MTHCA_AH_KMALLOC:
@@ -340,7 +340,7 @@ int mthca_init_av_table(struct mthca_dev *dev)
 	if (err)
 		return err;
 
-	dev->av_table.pool = pci_pool_create("mthca_av", dev->pdev,
+	dev->av_table.pool = dma_pool_create("mthca_av", &dev->pdev->dev,
 					     MTHCA_AV_SIZE,
 					     MTHCA_AV_SIZE, 0);
 	if (!dev->av_table.pool)
@@ -360,7 +360,7 @@ int mthca_init_av_table(struct mthca_dev *dev)
 	return 0;
 
  out_free_pool:
-	pci_pool_destroy(dev->av_table.pool);
+	dma_pool_destroy(dev->av_table.pool);
 
  out_free_alloc:
 	mthca_alloc_cleanup(&dev->av_table.alloc);
@@ -374,6 +374,6 @@ void mthca_cleanup_av_table(struct mthca_dev *dev)
 
 	if (dev->av_table.av_map)
 		iounmap(dev->av_table.av_map);
-	pci_pool_destroy(dev->av_table.pool);
+	dma_pool_destroy(dev->av_table.pool);
 	mthca_alloc_cleanup(&dev->av_table.alloc);
 }
diff --git a/drivers/infiniband/hw/mthca/mthca_cmd.c b/drivers/infiniband/hw/mthca/mthca_cmd.c
index 9d83a53c0c67..0b03c09e637c 100644
--- a/drivers/infiniband/hw/mthca/mthca_cmd.c
+++ b/drivers/infiniband/hw/mthca/mthca_cmd.c
@@ -538,7 +538,7 @@ int mthca_cmd_init(struct mthca_dev *dev)
 		return -ENOMEM;
 	}
 
-	dev->cmd.pool = pci_pool_create("mthca_cmd", dev->pdev,
+	dev->cmd.pool = dma_pool_create("mthca_cmd", &dev->pdev->dev,
 					MTHCA_MAILBOX_SIZE,
 					MTHCA_MAILBOX_SIZE, 0);
 	if (!dev->cmd.pool) {
@@ -551,7 +551,7 @@ int mthca_cmd_init(struct mthca_dev *dev)
 
 void mthca_cmd_cleanup(struct mthca_dev *dev)
 {
-	pci_pool_destroy(dev->cmd.pool);
+	dma_pool_destroy(dev->cmd.pool);
 	iounmap(dev->hcr);
 	if (dev->cmd.flags & MTHCA_CMD_POST_DOORBELLS)
 		iounmap(dev->cmd.dbell_map);
@@ -621,7 +621,7 @@ struct mthca_mailbox *mthca_alloc_mailbox(struct mthca_dev *dev,
 	if (!mailbox)
 		return ERR_PTR(-ENOMEM);
 
-	mailbox->buf = pci_pool_alloc(dev->cmd.pool, gfp_mask, &mailbox->dma);
+	mailbox->buf = dma_pool_alloc(dev->cmd.pool, gfp_mask, &mailbox->dma);
 	if (!mailbox->buf) {
 		kfree(mailbox);
 		return ERR_PTR(-ENOMEM);
@@ -635,7 +635,7 @@ void mthca_free_mailbox(struct mthca_dev *dev, struct mthca_mailbox *mailbox)
 	if (!mailbox)
 		return;
 
-	pci_pool_free(dev->cmd.pool, mailbox->buf, mailbox->dma);
+	dma_pool_free(dev->cmd.pool, mailbox->buf, mailbox->dma);
 	kfree(mailbox);
 }
 
diff --git a/drivers/infiniband/hw/mthca/mthca_dev.h b/drivers/infiniband/hw/mthca/mthca_dev.h
index ec7da9a474cd..5508afbf1c67 100644
--- a/drivers/infiniband/hw/mthca/mthca_dev.h
+++ b/drivers/infiniband/hw/mthca/mthca_dev.h
@@ -118,7 +118,7 @@ enum {
 };
 
 struct mthca_cmd {
-	struct pci_pool          *pool;
+	struct dma_pool          *pool;
 	struct mutex              hcr_mutex;
 	struct semaphore 	  poll_sem;
 	struct semaphore 	  event_sem;
@@ -263,7 +263,7 @@ struct mthca_qp_table {
 };
 
 struct mthca_av_table {
-	struct pci_pool   *pool;
+	struct dma_pool   *pool;
 	int                num_ddr_avs;
 	u64                ddr_av_base;
 	void __iomem      *av_map;
-- 
2.11.0
