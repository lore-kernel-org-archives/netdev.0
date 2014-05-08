From: George Cherian <george.cherian@ti.com>
Subject: [PATCH v2 3/3] drivers: net: davinci_cpdma: Convert kzalloc() to devm_kzalloc().
Date: Thu, 8 May 2014 15:20:52 +0530
Message-ID: <1399542652-14900-4-git-send-email-george.cherian@ti.com>
References: <1399542652-14900-1-git-send-email-george.cherian@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <mugunthanvnm@ti.com>, <balbi@ti.com>,
	<zonque@gmail.com>, <mpa@pengutronix.de>, <tklauser@distanz.ch>,
	George Cherian <george.cherian@ti.com>
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1399542652-14900-1-git-send-email-george.cherian@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert kzalloc() to devm_kzalloc().

Signed-off-by: George Cherian <george.cherian@ti.com>
Reviewed-by: Felipe Balbi <balbi@ti.com>
---
 drivers/net/ethernet/ti/davinci_cpdma.c | 35 +++++++++++----------------------
 1 file changed, 12 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index 88ef270..539dbde 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -158,9 +158,9 @@ cpdma_desc_pool_create(struct device *dev, u32 phys, u32 hw_addr,
 	int bitmap_size;
 	struct cpdma_desc_pool *pool;
 
-	pool = kzalloc(sizeof(*pool), GFP_KERNEL);
+	pool = devm_kzalloc(dev, sizeof(*pool), GFP_KERNEL);
 	if (!pool)
-		return NULL;
+		goto fail;
 
 	spin_lock_init(&pool->lock);
 
@@ -170,7 +170,7 @@ cpdma_desc_pool_create(struct device *dev, u32 phys, u32 hw_addr,
 	pool->num_desc	= size / pool->desc_size;
 
 	bitmap_size  = (pool->num_desc / BITS_PER_LONG) * sizeof(long);
-	pool->bitmap = kzalloc(bitmap_size, GFP_KERNEL);
+	pool->bitmap = devm_kzalloc(dev, bitmap_size, GFP_KERNEL);
 	if (!pool->bitmap)
 		goto fail;
 
@@ -187,10 +187,7 @@ cpdma_desc_pool_create(struct device *dev, u32 phys, u32 hw_addr,
 
 	if (pool->iomap)
 		return pool;
-
 fail:
-	kfree(pool->bitmap);
-	kfree(pool);
 	return NULL;
 }
 
@@ -203,7 +200,6 @@ static void cpdma_desc_pool_destroy(struct cpdma_desc_pool *pool)
 
 	spin_lock_irqsave(&pool->lock, flags);
 	WARN_ON(pool->used_desc);
-	kfree(pool->bitmap);
 	if (pool->cpumap) {
 		dma_free_coherent(pool->dev, pool->mem_size, pool->cpumap,
 				  pool->phys);
@@ -211,7 +207,6 @@ static void cpdma_desc_pool_destroy(struct cpdma_desc_pool *pool)
 		iounmap(pool->iomap);
 	}
 	spin_unlock_irqrestore(&pool->lock, flags);
-	kfree(pool);
 }
 
 static inline dma_addr_t desc_phys(struct cpdma_desc_pool *pool,
@@ -276,7 +271,7 @@ struct cpdma_ctlr *cpdma_ctlr_create(struct cpdma_params *params)
 {
 	struct cpdma_ctlr *ctlr;
 
-	ctlr = kzalloc(sizeof(*ctlr), GFP_KERNEL);
+	ctlr = devm_kzalloc(params->dev, sizeof(*ctlr), GFP_KERNEL);
 	if (!ctlr)
 		return NULL;
 
@@ -468,7 +463,6 @@ int cpdma_ctlr_destroy(struct cpdma_ctlr *ctlr)
 
 	cpdma_desc_pool_destroy(ctlr->pool);
 	spin_unlock_irqrestore(&ctlr->lock, flags);
-	kfree(ctlr);
 	return ret;
 }
 EXPORT_SYMBOL_GPL(cpdma_ctlr_destroy);
@@ -507,21 +501,22 @@ struct cpdma_chan *cpdma_chan_create(struct cpdma_ctlr *ctlr, int chan_num,
 				     cpdma_handler_fn handler)
 {
 	struct cpdma_chan *chan;
-	int ret, offset = (chan_num % CPDMA_MAX_CHANNELS) * 4;
+	int offset = (chan_num % CPDMA_MAX_CHANNELS) * 4;
 	unsigned long flags;
 
 	if (__chan_linear(chan_num) >= ctlr->num_chan)
 		return NULL;
 
-	ret = -ENOMEM;
-	chan = kzalloc(sizeof(*chan), GFP_KERNEL);
+	chan = devm_kzalloc(ctlr->dev, sizeof(*chan), GFP_KERNEL);
 	if (!chan)
-		goto err_chan_alloc;
+		return ERR_PTR(-ENOMEM);
 
 	spin_lock_irqsave(&ctlr->lock, flags);
-	ret = -EBUSY;
-	if (ctlr->channels[chan_num])
-		goto err_chan_busy;
+	if (ctlr->channels[chan_num]) {
+		spin_unlock_irqrestore(&ctlr->lock, flags);
+		devm_kfree(ctlr->dev, chan);
+		return ERR_PTR(-EBUSY);
+	}
 
 	chan->ctlr	= ctlr;
 	chan->state	= CPDMA_STATE_IDLE;
@@ -551,12 +546,6 @@ struct cpdma_chan *cpdma_chan_create(struct cpdma_ctlr *ctlr, int chan_num,
 	ctlr->channels[chan_num] = chan;
 	spin_unlock_irqrestore(&ctlr->lock, flags);
 	return chan;
-
-err_chan_busy:
-	spin_unlock_irqrestore(&ctlr->lock, flags);
-	kfree(chan);
-err_chan_alloc:
-	return ERR_PTR(ret);
 }
 EXPORT_SYMBOL_GPL(cpdma_chan_create);
 
-- 
1.8.3.1
