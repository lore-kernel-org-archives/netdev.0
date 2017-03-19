From: Romain Perier <romain.perier@collabora.com>
Subject: [PATCH v6 02/15] dmaengine: pch_dma: Replace PCI pool old API
Date: Sun, 19 Mar 2017 18:03:51 +0100
Message-ID: <20170319170404.17362-3-romain.perier@collabora.com>
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
 drivers/dma/pch_dma.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/dma/pch_dma.c b/drivers/dma/pch_dma.c
index f9028e9..afd8f27 100644
--- a/drivers/dma/pch_dma.c
+++ b/drivers/dma/pch_dma.c
@@ -123,7 +123,7 @@ struct pch_dma_chan {
 struct pch_dma {
 	struct dma_device	dma;
 	void __iomem *membase;
-	struct pci_pool		*pool;
+	struct dma_pool		*pool;
 	struct pch_dma_regs	regs;
 	struct pch_dma_desc_regs ch_regs[MAX_CHAN_NR];
 	struct pch_dma_chan	channels[MAX_CHAN_NR];
@@ -437,7 +437,7 @@ static struct pch_dma_desc *pdc_alloc_desc(struct dma_chan *chan, gfp_t flags)
 	struct pch_dma *pd = to_pd(chan->device);
 	dma_addr_t addr;
 
-	desc = pci_pool_zalloc(pd->pool, flags, &addr);
+	desc = dma_pool_zalloc(pd->pool, flags, &addr);
 	if (desc) {
 		INIT_LIST_HEAD(&desc->tx_list);
 		dma_async_tx_descriptor_init(&desc->txd, chan);
@@ -549,7 +549,7 @@ static void pd_free_chan_resources(struct dma_chan *chan)
 	spin_unlock_irq(&pd_chan->lock);
 
 	list_for_each_entry_safe(desc, _d, &tmp_list, desc_node)
-		pci_pool_free(pd->pool, desc, desc->txd.phys);
+		dma_pool_free(pd->pool, desc, desc->txd.phys);
 
 	pdc_enable_irq(chan, 0);
 }
@@ -880,7 +880,7 @@ static int pch_dma_probe(struct pci_dev *pdev,
 		goto err_iounmap;
 	}
 
-	pd->pool = pci_pool_create("pch_dma_desc_pool", pdev,
+	pd->pool = dma_pool_create("pch_dma_desc_pool", &pdev->dev,
 				   sizeof(struct pch_dma_desc), 4, 0);
 	if (!pd->pool) {
 		dev_err(&pdev->dev, "Failed to alloc DMA descriptors\n");
@@ -931,7 +931,7 @@ static int pch_dma_probe(struct pci_dev *pdev,
 	return 0;
 
 err_free_pool:
-	pci_pool_destroy(pd->pool);
+	dma_pool_destroy(pd->pool);
 err_free_irq:
 	free_irq(pdev->irq, pd);
 err_iounmap:
@@ -963,7 +963,7 @@ static void pch_dma_remove(struct pci_dev *pdev)
 			tasklet_kill(&pd_chan->tasklet);
 		}
 
-		pci_pool_destroy(pd->pool);
+		dma_pool_destroy(pd->pool);
 		pci_iounmap(pdev, pd->membase);
 		pci_release_regions(pdev);
 		pci_disable_device(pdev);
-- 
2.9.3
