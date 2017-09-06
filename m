From: Romain Perier <romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Subject: [PATCH v13 4/5] hinic: Replace PCI pool old API
Date: Wed,  6 Sep 2017 11:08:56 +0200
Message-ID: <20170906090857.14846-5-romain.perier@collabora.com>
References: <20170906090857.14846-1-romain.perier@collabora.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
        Romain Perier <romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
To: Dan Williams <dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, stas.yakovlev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        Aviad Krawczyk <aviad.krawczyk-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170906090857.14846-1-romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The PCI pool API is deprecated. This commit replaces the PCI pool old
API by the appropriate function with the DMA pool API.

Signed-off-by: Romain Perier <romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
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
2.11.0

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
