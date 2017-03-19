From: Romain Perier <romain.perier@collabora.com>
Subject: [PATCH v6 03/15] IB/mthca: Replace PCI pool old API
Date: Sun, 19 Mar 2017 18:03:52 +0100
Message-ID: <20170319170404.17362-4-romain.perier@collabora.com>
References: <20170319170404.17362-1-romain.perier@collabora.com>
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
In-Reply-To: <20170319170404.17362-1-romain.perier@collabora.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The PCI pool API is deprecated. This commit replaces the PCI pool old
API by the appropriate function with the DMA pool API.

Signed-off-by: Romain Perier <romain.perier@collabora.com>
Acked-by: Peter Senna Tschudin <peter.senna@collabora.com>
Tested-by: Peter Senna Tschudin <peter.senna@collabora.com>
---
 drivers/infiniband/hw/mthca/mthca_av.c  | 10 +++++-----
 drivers/infiniband/hw/mthca/mthca_cmd.c |  8 ++++----
 drivers/infiniband/hw/mthca/mthca_dev.h |  4 ++--
 3 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/infiniband/hw/mthca/mthca_av.c b/drivers/infiniband/hw/mthca/mthca_av.c
index c9f0f36..9d041b6 100644
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
@@ -245,7 +245,7 @@ int mthca_destroy_ah(struct mthca_dev *dev, struct mthca_ah *ah)
 		break;
 
 	case MTHCA_AH_PCI_POOL:
-		pci_pool_free(dev->av_table.pool, ah->av, ah->avdma);
+		dma_pool_free(dev->av_table.pool, ah->av, ah->avdma);
 		break;
 
 	case MTHCA_AH_KMALLOC:
@@ -333,7 +333,7 @@ int mthca_init_av_table(struct mthca_dev *dev)
 	if (err)
 		return err;
 
-	dev->av_table.pool = pci_pool_create("mthca_av", dev->pdev,
+	dev->av_table.pool = dma_pool_create("mthca_av", &dev->pdev->dev,
 					     MTHCA_AV_SIZE,
 					     MTHCA_AV_SIZE, 0);
 	if (!dev->av_table.pool)
@@ -353,7 +353,7 @@ int mthca_init_av_table(struct mthca_dev *dev)
 	return 0;
 
  out_free_pool:
-	pci_pool_destroy(dev->av_table.pool);
+	dma_pool_destroy(dev->av_table.pool);
 
  out_free_alloc:
 	mthca_alloc_cleanup(&dev->av_table.alloc);
@@ -367,6 +367,6 @@ void mthca_cleanup_av_table(struct mthca_dev *dev)
 
 	if (dev->av_table.av_map)
 		iounmap(dev->av_table.av_map);
-	pci_pool_destroy(dev->av_table.pool);
+	dma_pool_destroy(dev->av_table.pool);
 	mthca_alloc_cleanup(&dev->av_table.alloc);
 }
diff --git a/drivers/infiniband/hw/mthca/mthca_cmd.c b/drivers/infiniband/hw/mthca/mthca_cmd.c
index c7f49bb..7f219c8 100644
--- a/drivers/infiniband/hw/mthca/mthca_cmd.c
+++ b/drivers/infiniband/hw/mthca/mthca_cmd.c
@@ -530,7 +530,7 @@ int mthca_cmd_init(struct mthca_dev *dev)
 		return -ENOMEM;
 	}
 
-	dev->cmd.pool = pci_pool_create("mthca_cmd", dev->pdev,
+	dev->cmd.pool = dma_pool_create("mthca_cmd", &dev->pdev->dev,
 					MTHCA_MAILBOX_SIZE,
 					MTHCA_MAILBOX_SIZE, 0);
 	if (!dev->cmd.pool) {
@@ -543,7 +543,7 @@ int mthca_cmd_init(struct mthca_dev *dev)
 
 void mthca_cmd_cleanup(struct mthca_dev *dev)
 {
-	pci_pool_destroy(dev->cmd.pool);
+	dma_pool_destroy(dev->cmd.pool);
 	iounmap(dev->hcr);
 	if (dev->cmd.flags & MTHCA_CMD_POST_DOORBELLS)
 		iounmap(dev->cmd.dbell_map);
@@ -613,7 +613,7 @@ struct mthca_mailbox *mthca_alloc_mailbox(struct mthca_dev *dev,
 	if (!mailbox)
 		return ERR_PTR(-ENOMEM);
 
-	mailbox->buf = pci_pool_alloc(dev->cmd.pool, gfp_mask, &mailbox->dma);
+	mailbox->buf = dma_pool_alloc(dev->cmd.pool, gfp_mask, &mailbox->dma);
 	if (!mailbox->buf) {
 		kfree(mailbox);
 		return ERR_PTR(-ENOMEM);
@@ -627,7 +627,7 @@ void mthca_free_mailbox(struct mthca_dev *dev, struct mthca_mailbox *mailbox)
 	if (!mailbox)
 		return;
 
-	pci_pool_free(dev->cmd.pool, mailbox->buf, mailbox->dma);
+	dma_pool_free(dev->cmd.pool, mailbox->buf, mailbox->dma);
 	kfree(mailbox);
 }
 
diff --git a/drivers/infiniband/hw/mthca/mthca_dev.h b/drivers/infiniband/hw/mthca/mthca_dev.h
index 4393a02..8c3f6ed 100644
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
2.9.3
