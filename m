From: Romain Perier <romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Subject: [PATCH v7 02/15] dmaengine: pch_dma: Replace PCI pool old API
Date: Fri,  7 Apr 2017 09:25:30 +0200
Message-ID: <20170407072543.6936-3-romain.perier@collabora.com>
References: <20170407072543.6936-1-romain.perier@collabora.com>
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
In-Reply-To: <20170407072543.6936-1-romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The PCI pool API is deprecated. This commit replaces the PCI pool old
API by the appropriate function with the DMA pool API.

Signed-off-by: Romain Perier <romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Acked-by: Peter Senna Tschudin <peter.senna-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Tested-by: Peter Senna Tschudin <peter.senna-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
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

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
