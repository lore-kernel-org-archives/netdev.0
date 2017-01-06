From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH v2 3/7] net: ethernet: ti: cpdma: minimize number of parameters in cpdma_desc_pool_create/destroy()
Date: Fri, 6 Jan 2017 14:07:31 -0600
Message-ID: <20170106200735.4210-4-grygorii.strashko@ti.com>
References: <20170106200735.4210-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fllnx210.ext.ti.com ([198.47.19.17]:58960 "EHLO
        fllnx210.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S937968AbdAFUHk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 15:07:40 -0500
In-Reply-To: <20170106200735.4210-1-grygorii.strashko@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update cpdma_desc_pool_create/destroy() to accept only one parameter
struct cpdma_ctlr*, as this structure contains all required
information for pool creation/destruction.

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/davinci_cpdma.c | 62 ++++++++++++++++-----------------
 1 file changed, 30 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index a53b384..7080eb9 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -181,8 +181,10 @@ static struct cpdma_control_info controls[] = {
 				 (directed << CPDMA_TO_PORT_SHIFT));	\
 	} while (0)
 
-static void cpdma_desc_pool_destroy(struct cpdma_desc_pool *pool)
+static void cpdma_desc_pool_destroy(struct cpdma_ctlr *ctlr)
 {
+	struct cpdma_desc_pool *pool = ctlr->pool;
+
 	if (!pool)
 		return;
 
@@ -191,7 +193,7 @@ static void cpdma_desc_pool_destroy(struct cpdma_desc_pool *pool)
 	     gen_pool_size(pool->gen_pool),
 	     gen_pool_avail(pool->gen_pool));
 	if (pool->cpumap)
-		dma_free_coherent(pool->dev, pool->mem_size, pool->cpumap,
+		dma_free_coherent(ctlr->dev, pool->mem_size, pool->cpumap,
 				  pool->phys);
 	else
 		iounmap(pool->iomap);
@@ -203,37 +205,37 @@ static void cpdma_desc_pool_destroy(struct cpdma_desc_pool *pool)
  * devices (e.g. cpsw switches) use plain old memory.  Descriptor pools
  * abstract out these details
  */
-static struct cpdma_desc_pool *
-cpdma_desc_pool_create(struct device *dev, u32 phys, dma_addr_t hw_addr,
-				int size, int align)
+int cpdma_desc_pool_create(struct cpdma_ctlr *ctlr)
 {
+	struct cpdma_params *cpdma_params = &ctlr->params;
 	struct cpdma_desc_pool *pool;
-	int ret;
+	int ret = -ENOMEM;
 
-	pool = devm_kzalloc(dev, sizeof(*pool), GFP_KERNEL);
+	pool = devm_kzalloc(ctlr->dev, sizeof(*pool), GFP_KERNEL);
 	if (!pool)
 		goto gen_pool_create_fail;
+	ctlr->pool = pool;
 
-	pool->dev	= dev;
-	pool->mem_size	= size;
-	pool->desc_size	= ALIGN(sizeof(struct cpdma_desc), align);
-	pool->num_desc	= size / pool->desc_size;
+	pool->mem_size	= cpdma_params->desc_mem_size;
+	pool->desc_size	= ALIGN(sizeof(struct cpdma_desc),
+				cpdma_params->desc_align);
+	pool->num_desc	= pool->mem_size / pool->desc_size;
 
-	pool->gen_pool = devm_gen_pool_create(dev, ilog2(pool->desc_size), -1,
-					      "cpdma");
+	pool->gen_pool = devm_gen_pool_create(ctlr->dev, ilog2(pool->desc_size),
+					      -1, "cpdma");
 	if (IS_ERR(pool->gen_pool)) {
-		dev_err(dev, "pool create failed %ld\n",
-			PTR_ERR(pool->gen_pool));
+		ret = PTR_ERR(pool->gen_pool);
+		dev_err(ctlr->dev, "pool create failed %d\n", ret);
 		goto gen_pool_create_fail;
 	}
 
-	if (phys) {
-		pool->phys  = phys;
-		pool->iomap = ioremap(phys, size); /* should be memremap? */
-		pool->hw_addr = hw_addr;
+	if (cpdma_params->desc_mem_phys) {
+		pool->phys  = cpdma_params->desc_mem_phys;
+		pool->iomap = ioremap(pool->phys, pool->mem_size);
+		pool->hw_addr = cpdma_params->desc_hw_addr;
 	} else {
-		pool->cpumap = dma_alloc_coherent(dev, size, &pool->hw_addr,
-						  GFP_KERNEL);
+		pool->cpumap = dma_alloc_coherent(ctlr->dev,  pool->mem_size,
+						  &pool->hw_addr, GFP_KERNEL);
 		pool->iomap = (void __iomem __force *)pool->cpumap;
 		pool->phys = pool->hw_addr; /* assumes no IOMMU, don't use this value */
 	}
@@ -244,16 +246,17 @@ cpdma_desc_pool_create(struct device *dev, u32 phys, dma_addr_t hw_addr,
 	ret = gen_pool_add_virt(pool->gen_pool, (unsigned long)pool->iomap,
 				pool->phys, pool->mem_size, -1);
 	if (ret < 0) {
-		dev_err(dev, "pool add failed %d\n", ret);
+		dev_err(ctlr->dev, "pool add failed %d\n", ret);
 		goto gen_pool_add_virt_fail;
 	}
 
-	return pool;
+	return 0;
 
 gen_pool_add_virt_fail:
-	cpdma_desc_pool_destroy(pool);
+	cpdma_desc_pool_destroy(ctlr);
 gen_pool_create_fail:
-	return NULL;
+	ctlr->pool = NULL;
+	return ret;
 }
 
 static inline dma_addr_t desc_phys(struct cpdma_desc_pool *pool,
@@ -502,12 +505,7 @@ struct cpdma_ctlr *cpdma_ctlr_create(struct cpdma_params *params)
 	ctlr->chan_num = 0;
 	spin_lock_init(&ctlr->lock);
 
-	ctlr->pool = cpdma_desc_pool_create(ctlr->dev,
-					    ctlr->params.desc_mem_phys,
-					    ctlr->params.desc_hw_addr,
-					    ctlr->params.desc_mem_size,
-					    ctlr->params.desc_align);
-	if (!ctlr->pool)
+	if (cpdma_desc_pool_create(ctlr))
 		return NULL;
 
 	if (WARN_ON(ctlr->num_chan > CPDMA_MAX_CHANNELS))
@@ -623,7 +621,7 @@ int cpdma_ctlr_destroy(struct cpdma_ctlr *ctlr)
 	for (i = 0; i < ARRAY_SIZE(ctlr->channels); i++)
 		cpdma_chan_destroy(ctlr->channels[i]);
 
-	cpdma_desc_pool_destroy(ctlr->pool);
+	cpdma_desc_pool_destroy(ctlr);
 	return ret;
 }
 EXPORT_SYMBOL_GPL(cpdma_ctlr_destroy);
-- 
2.10.1.dirty
