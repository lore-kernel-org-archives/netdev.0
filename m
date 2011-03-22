From: Sriramakrishnan A G <srk@ti.com>
Subject: [PATCHv2] net: davinci_emac:Fix translation logic for buffer descriptor
Date: Tue, 22 Mar 2011 18:01:03 +0530
Message-ID: <1300797063-13558-1-git-send-email-srk@ti.com>
Cc: davinci-linux-open-source@linux.davincidsp.com,
	davem@davemloft.net, srk@ti.com, sshtylyov@mvista.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:51834 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755120Ab1CVMbQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Mar 2011 08:31:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With recent changes to the driver(switch to new cpdma layer),
the support for buffer descriptor address translation logic
is broken. This affects platforms where the physical address of
the descriptors as seen by the DMA engine is different from the
physical address.

Original Patch adding translation logic support:
Commit: ad021ae8862209864dc8ebd3b7d3a55ce84b9ea2

Signed-off-by: Sriramakrishnan A G <srk@ti.com>
---
Addresses review comments from Sergei. Generated against tip of Linus tree.

 drivers/net/davinci_cpdma.c  |   11 ++++++++---
 drivers/net/davinci_cpdma.h  |    1 +
 drivers/net/davinci_emac.c   |    5 ++++-
 include/linux/davinci_emac.h |    1 +
 4 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/drivers/net/davinci_cpdma.c b/drivers/net/davinci_cpdma.c
index e92b2b6..ae47f23 100644
--- a/drivers/net/davinci_cpdma.c
+++ b/drivers/net/davinci_cpdma.c
@@ -76,6 +76,7 @@ struct cpdma_desc {
 
 struct cpdma_desc_pool {
 	u32			phys;
+	u32			hw_addr;
 	void __iomem		*iomap;		/* ioremap map */
 	void			*cpumap;	/* dma_alloc map */
 	int			desc_size, mem_size;
@@ -137,7 +138,8 @@ struct cpdma_chan {
  * abstract out these details
  */
 static struct cpdma_desc_pool *
-cpdma_desc_pool_create(struct device *dev, u32 phys, int size, int align)
+cpdma_desc_pool_create(struct device *dev, u32 phys, u32 hw_addr,
+				int size, int align)
 {
 	int bitmap_size;
 	struct cpdma_desc_pool *pool;
@@ -161,10 +163,12 @@ cpdma_desc_pool_create(struct device *dev, u32 phys, int size, int align)
 	if (phys) {
 		pool->phys  = phys;
 		pool->iomap = ioremap(phys, size);
+		pool->hw_addr = hw_addr;
 	} else {
 		pool->cpumap = dma_alloc_coherent(dev, size, &pool->phys,
 						  GFP_KERNEL);
 		pool->iomap = (void __force __iomem *)pool->cpumap;
+		pool->hw_addr = pool->phys;
 	}
 
 	if (pool->iomap)
@@ -201,14 +205,14 @@ static inline dma_addr_t desc_phys(struct cpdma_desc_pool *pool,
 {
 	if (!desc)
 		return 0;
-	return pool->phys + (__force dma_addr_t)desc -
+	return pool->hw_addr + (__force dma_addr_t)desc -
 			    (__force dma_addr_t)pool->iomap;
 }
 
 static inline struct cpdma_desc __iomem *
 desc_from_phys(struct cpdma_desc_pool *pool, dma_addr_t dma)
 {
-	return dma ? pool->iomap + dma - pool->phys : NULL;
+	return dma ? pool->iomap + dma - pool->hw_addr : NULL;
 }
 
 static struct cpdma_desc __iomem *
@@ -260,6 +264,7 @@ struct cpdma_ctlr *cpdma_ctlr_create(struct cpdma_params *params)
 
 	ctlr->pool = cpdma_desc_pool_create(ctlr->dev,
 					    ctlr->params.desc_mem_phys,
+					    ctlr->params.desc_hw_addr,
 					    ctlr->params.desc_mem_size,
 					    ctlr->params.desc_align);
 	if (!ctlr->pool) {
diff --git a/drivers/net/davinci_cpdma.h b/drivers/net/davinci_cpdma.h
index 868e50e..afa19a0 100644
--- a/drivers/net/davinci_cpdma.h
+++ b/drivers/net/davinci_cpdma.h
@@ -33,6 +33,7 @@ struct cpdma_params {
 	bool			has_soft_reset;
 	int			min_packet_size;
 	u32			desc_mem_phys;
+	u32			desc_hw_addr;
 	int			desc_mem_size;
 	int			desc_align;
 
diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
index 082d6ea..baca6bf 100644
--- a/drivers/net/davinci_emac.c
+++ b/drivers/net/davinci_emac.c
@@ -1854,10 +1854,13 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
 	dma_params.rxcp			= priv->emac_base + 0x660;
 	dma_params.num_chan		= EMAC_MAX_TXRX_CHANNELS;
 	dma_params.min_packet_size	= EMAC_DEF_MIN_ETHPKTSIZE;
-	dma_params.desc_mem_phys	= hw_ram_addr;
+	dma_params.desc_hw_addr		= hw_ram_addr;
 	dma_params.desc_mem_size	= pdata->ctrl_ram_size;
 	dma_params.desc_align		= 16;
 
+	dma_params.desc_mem_phys = pdata->no_bd_ram ? 0 :
+			(u32 __force)res->start + pdata->ctrl_ram_offset;
+
 	priv->dma = cpdma_ctlr_create(&dma_params);
 	if (!priv->dma) {
 		dev_err(emac_dev, "DaVinci EMAC: Error initializing DMA\n");
diff --git a/include/linux/davinci_emac.h b/include/linux/davinci_emac.h
index 5dd4285..5428885 100644
--- a/include/linux/davinci_emac.h
+++ b/include/linux/davinci_emac.h
@@ -36,6 +36,7 @@ struct emac_platform_data {
 
 	u8 rmii_en;
 	u8 version;
+	bool no_bd_ram;
 	void (*interrupt_enable) (void);
 	void (*interrupt_disable) (void);
 };
-- 
1.6.2.4

