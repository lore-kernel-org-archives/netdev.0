From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH v2 5/7] net: ethernet: ti: cpsw: add support for descs pool size configuration
Date: Fri, 6 Jan 2017 14:07:33 -0600
Message-ID: <20170106200735.4210-6-grygorii.strashko@ti.com>
References: <20170106200735.4210-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170106200735.4210-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The CPSW CPDMA can process buffer descriptors placed as in internal
CPPI RAM as in DDR. This patch adds support in CPSW and CPDMA for
descs_pool_size mudule parameter, which defines total number of CPDMA CPPI
descriptors to be used for both ingress/egress packets processing:
 - memory size, required for CPDMA descriptor pool, is calculated basing
on number of descriptors specified by user in descs_pool_size and
CPDMA descriptor size and allocated from coherent memory (CMA area);
 - CPDMA descriptor pool will be allocated in DDR if pool memory size >
internal CPPI RAM or use internal CPPI RAM otherwise;
 - if descs_pool_size not specified in DT - the default value 256 will
be used which will allow to place CPDMA descriptors pool into the
internal CPPI RAM (current default behaviour);
 - CPDMA will ignore descs_pool_size if descs_pool_size = 0 for
backward comaptiobility with davinci_emac.

descs_pool_size is boot time setting and can't be changed once
CPSW/CPDMA is initialized.

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c          | 12 +++++++++---
 drivers/net/ethernet/ti/davinci_cpdma.c | 12 ++++++++++++
 drivers/net/ethernet/ti/davinci_cpdma.h |  1 +
 3 files changed, 22 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index b203143..d39875e 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -145,6 +145,7 @@ do {								\
 		cpsw->data.active_slave)
 #define IRQ_NUM			2
 #define CPSW_MAX_QUEUES		8
+#define CPSW_CPDMA_DESCS_POOL_SIZE_DEFAULT 256
 
 static int debug_level;
 module_param(debug_level, int, 0);
@@ -158,6 +159,10 @@ static int rx_packet_max = CPSW_MAX_PACKET_SIZE;
 module_param(rx_packet_max, int, 0);
 MODULE_PARM_DESC(rx_packet_max, "maximum receive packet size (bytes)");
 
+static int descs_pool_size = CPSW_CPDMA_DESCS_POOL_SIZE_DEFAULT;
+module_param(descs_pool_size, int, 0444);
+MODULE_PARM_DESC(descs_pool_size, "Number of CPDMA CPPI descriptors in pool");
+
 struct cpsw_wr_regs {
 	u32	id_ver;
 	u32	soft_reset;
@@ -2969,6 +2974,7 @@ static int cpsw_probe(struct platform_device *pdev)
 	dma_params.has_ext_regs		= true;
 	dma_params.desc_hw_addr         = dma_params.desc_mem_phys;
 	dma_params.bus_freq_mhz		= cpsw->bus_freq_mhz;
+	dma_params.descs_pool_size	= descs_pool_size;
 
 	cpsw->dma = cpdma_ctlr_create(&dma_params);
 	if (!cpsw->dma) {
@@ -3072,9 +3078,9 @@ static int cpsw_probe(struct platform_device *pdev)
 		goto clean_ale_ret;
 	}
 
-	cpsw_notice(priv, probe, "initialized device (regs %pa, irq %d)\n",
-		    &ss_res->start, ndev->irq);
-
+	cpsw_notice(priv, probe,
+		    "initialized device (regs %pa, irq %d, pool size %d)\n",
+		    &ss_res->start, ndev->irq, dma_params.descs_pool_size);
 	if (cpsw->data.dual_emac) {
 		ret = cpsw_probe_dual_emac(priv);
 		if (ret) {
diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index b229bf3..65e2f12 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -219,6 +219,18 @@ int cpdma_desc_pool_create(struct cpdma_ctlr *ctlr)
 				cpdma_params->desc_align);
 	pool->num_desc	= pool->mem_size / pool->desc_size;
 
+	if (cpdma_params->descs_pool_size) {
+		/* recalculate memory size required cpdma descriptor pool
+		 * basing on number of descriptors specified by user and
+		 * if memory size > CPPI internal RAM size (desc_mem_size)
+		 * then switch to use DDR
+		 */
+		pool->num_desc = cpdma_params->descs_pool_size;
+		pool->mem_size = pool->desc_size * pool->num_desc;
+		if (pool->mem_size > cpdma_params->desc_mem_size)
+			cpdma_params->desc_mem_phys = 0;
+	}
+
 	pool->gen_pool = devm_gen_pool_create(ctlr->dev, ilog2(pool->desc_size),
 					      -1, "cpdma");
 	if (IS_ERR(pool->gen_pool)) {
diff --git a/drivers/net/ethernet/ti/davinci_cpdma.h b/drivers/net/ethernet/ti/davinci_cpdma.h
index 4a167db..cb45f8f 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.h
+++ b/drivers/net/ethernet/ti/davinci_cpdma.h
@@ -37,6 +37,7 @@ struct cpdma_params {
 	int			desc_mem_size;
 	int			desc_align;
 	u32			bus_freq_mhz;
+	u32			descs_pool_size;
 
 	/*
 	 * Some instances of embedded cpdma controllers have extra control and
-- 
2.10.1.dirty
