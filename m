From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] dpaa_eth: use correct device for DMA mapping API
Date: Mon, 10 Jul 2017 17:14:27 +0200
Message-ID: <20170710151447.2814348-1-arnd@arndb.de>
Cc: Christoph Hellwig <hch@lst.de>,
        Marek Szyprowski <m.szyprowski@samsung.com>,
        Robin Murphy <robin.murphy@arm.com>,
        "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Geert Uytterhoeven <geert@linux-m68k.org>,
        Arnd Bergmann <arnd@arndb.de>,
        Camelia Groza <camelia.groza@nxp.com>,
        Claudiu Manoil <claudiu.manoil@nxp.com>,
        linux-kernel@vger.kernel.org
To: Madalin Bucur <madalin.bucur@nxp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Geert Uytterhoeven ran into a build error without CONFIG_HAS_DMA,
as a result of the driver calling set_dma_ops(). While we can
fix the build error in the dma-mapping implementation, there is
another problem in this driver:

The configuration for the DMA is done by the platform code,
looking up information about the system from the device tree.
This copies the information only in an incomplete way, setting
the dma_map_ops and forcing a specific mask, but ignoring all
settings regarding IOMMU, coherence etc.

A better way to avoid the problem is to only ever pass a device
into the dma_mapping implementation that has been setup by the
platform code. In this case, that is the parent device, so we
can get that pointer at probe time. Fortunately, we already have
a pointer in the device specific structure for that, so we only
need to modify that.

Fixes: fb52728a9294 ("dpaa_eth: reuse the dma_ops provided by the FMan MAC device")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
Not tested, please see if this works before applying!
---
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c | 11 ++---------
 1 file changed, 2 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
index 757b873735a5..f7b0b928cd53 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
@@ -2646,14 +2646,6 @@ static int dpaa_eth_probe(struct platform_device *pdev)
 	priv->buf_layout[RX].priv_data_size = DPAA_RX_PRIV_DATA_SIZE; /* Rx */
 	priv->buf_layout[TX].priv_data_size = DPAA_TX_PRIV_DATA_SIZE; /* Tx */
 
-	/* device used for DMA mapping */
-	set_dma_ops(dev, get_dma_ops(&pdev->dev));
-	err = dma_coerce_mask_and_coherent(dev, DMA_BIT_MASK(40));
-	if (err) {
-		dev_err(dev, "dma_coerce_mask_and_coherent() failed\n");
-		goto dev_mask_failed;
-	}
-
 	/* bp init */
 	for (i = 0; i < DPAA_BPS_NUM; i++) {
 		int err;
@@ -2665,7 +2657,8 @@ static int dpaa_eth_probe(struct platform_device *pdev)
 		dpaa_bps[i]->raw_size = bpool_buffer_raw_size(i, DPAA_BPS_NUM);
 		/* avoid runtime computations by keeping the usable size here */
 		dpaa_bps[i]->size = dpaa_bp_size(dpaa_bps[i]->raw_size);
-		dpaa_bps[i]->dev = dev;
+		/* DMA operations are done on the platform-provided device */
+		dpaa_bps[i]->dev = dev->parent;
 
 		err = dpaa_bp_alloc_pool(dpaa_bps[i]);
 		if (err < 0) {
-- 
2.9.0
