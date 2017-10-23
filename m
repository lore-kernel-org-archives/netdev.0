From: Romain Perier <romain.perier@gmail.com>
Subject: [PATCH v14 4/5] hinic: Replace PCI pool old API
Date: Mon, 23 Oct 2017 19:59:57 +0200
Message-ID: <20171023175958.8327-5-romain.perier@gmail.com>
References: <20171023175958.8327-1-romain.perier@gmail.com>
Cc: dmaengine@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Romain Perier <romain.perier@collabora.com>
To: Jens Axboe <axboe@kernel.dk>,
        Andrew Morton <akpm@linux-foundation.org>,
        Dan Williams <dan.j.williams@intel.com>,
        Vinod Koul <vinod.koul@intel.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Aviad Krawczyk <aviad.krawczyk@huawei.com>,
        Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20171023175958.8327-1-romain.perier@gmail.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Romain Perier <romain.perier@collabora.com>

The PCI pool API is deprecated. This commit replaces the PCI pool old
API by the appropriate function with the DMA pool API.

Signed-off-by: Romain Perier <romain.perier@collabora.com>
---
 drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.c | 10 +++++-----
 drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.h |  2 +-
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.c b/drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.c
index 7d95f0866fb0..28a81ac97af5 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.c
@@ -143,7 +143,7 @@ int hinic_alloc_cmdq_buf(struct hinic_cmdqs *cmdqs,
 	struct hinic_hwif *hwif = cmdqs->hwif;
 	struct pci_dev *pdev = hwif->pdev;
 
-	cmdq_buf->buf = pci_pool_alloc(cmdqs->cmdq_buf_pool, GFP_KERNEL,
+	cmdq_buf->buf = dma_pool_alloc(cmdqs->cmdq_buf_pool, GFP_KERNEL,
 				       &cmdq_buf->dma_addr);
 	if (!cmdq_buf->buf) {
 		dev_err(&pdev->dev, "Failed to allocate cmd from the pool\n");
@@ -161,7 +161,7 @@ int hinic_alloc_cmdq_buf(struct hinic_cmdqs *cmdqs,
 void hinic_free_cmdq_buf(struct hinic_cmdqs *cmdqs,
 			 struct hinic_cmdq_buf *cmdq_buf)
 {
-	pci_pool_free(cmdqs->cmdq_buf_pool, cmdq_buf->buf, cmdq_buf->dma_addr);
+	dma_pool_free(cmdqs->cmdq_buf_pool, cmdq_buf->buf, cmdq_buf->dma_addr);
 }
 
 static unsigned int cmdq_wqe_size_from_bdlen(enum bufdesc_len len)
@@ -875,7 +875,7 @@ int hinic_init_cmdqs(struct hinic_cmdqs *cmdqs, struct hinic_hwif *hwif,
 	int err;
 
 	cmdqs->hwif = hwif;
-	cmdqs->cmdq_buf_pool = pci_pool_create("hinic_cmdq", pdev,
+	cmdqs->cmdq_buf_pool = dma_pool_create("hinic_cmdq", &pdev->dev,
 					       HINIC_CMDQ_BUF_SIZE,
 					       HINIC_CMDQ_BUF_SIZE, 0);
 	if (!cmdqs->cmdq_buf_pool)
@@ -916,7 +916,7 @@ int hinic_init_cmdqs(struct hinic_cmdqs *cmdqs, struct hinic_hwif *hwif,
 	devm_kfree(&pdev->dev, cmdqs->saved_wqs);
 
 err_saved_wqs:
-	pci_pool_destroy(cmdqs->cmdq_buf_pool);
+	dma_pool_destroy(cmdqs->cmdq_buf_pool);
 	return err;
 }
 
@@ -942,5 +942,5 @@ void hinic_free_cmdqs(struct hinic_cmdqs *cmdqs)
 
 	devm_kfree(&pdev->dev, cmdqs->saved_wqs);
 
-	pci_pool_destroy(cmdqs->cmdq_buf_pool);
+	dma_pool_destroy(cmdqs->cmdq_buf_pool);
 }
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.h
index b35583400cb6..23f8d39eab68 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.h
@@ -157,7 +157,7 @@ struct hinic_cmdq {
 struct hinic_cmdqs {
 	struct hinic_hwif       *hwif;
 
-	struct pci_pool         *cmdq_buf_pool;
+	struct dma_pool         *cmdq_buf_pool;
 
 	struct hinic_wq         *saved_wqs;
 
-- 
2.14.1
