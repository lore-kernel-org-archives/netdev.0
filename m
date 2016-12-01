From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH 6/7] net: ethernet: ti: cpsw: add support for descs_pool_size dt property
Date: Thu, 1 Dec 2016 17:34:31 -0600
Message-ID: <20161201233432.6182-7-grygorii.strashko@ti.com>
References: <20161201233432.6182-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161201233432.6182-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The CPSW CPDMA can process buffer descriptors placed as in internal
CPPI RAM as in DDR. This patch adds support in CPSW and CPDMA for
descs_pool_size DT property, which defines total number of CPDMA CPPI
descriptors to be used for both ingress/egress packets processing:
 - memory size required for CPDMA descriptor pool is calculated basing
on number of descriptors specified by user in descs_pool_size and
CPDMA descriptor size;
 - allocate CPDMA descriptor pool in DDR if pool memory size >
internal CPPI RAM or use internal CPPI RAM otherwise;
 - if descs_pool_size not specified in DT - the default value 256 will
be used which will allow to place CPDMA descriptors pool into the
internal CPPI RAM (current default behaviour);
 - CPDMA will ignore descs_pool_size if descs_pool_size = 0 for
backward comaptiobility with davinci_emac.

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c          |  5 +++++
 drivers/net/ethernet/ti/cpsw.h          |  1 +
 drivers/net/ethernet/ti/davinci_cpdma.c | 12 ++++++++++++
 drivers/net/ethernet/ti/davinci_cpdma.h |  1 +
 4 files changed, 19 insertions(+)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index dd5d830..a98c6260 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -145,6 +145,7 @@ do {								\
 		cpsw->data.active_slave)
 #define IRQ_NUM			2
 #define CPSW_MAX_QUEUES		8
+#define CPSW_CPDMA_DESCS_POOL_SIZE_DEFAULT 256
 
 static int debug_level;
 module_param(debug_level, int, 0);
@@ -2557,6 +2558,9 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 	if (of_property_read_bool(node, "dual_emac"))
 		data->dual_emac = 1;
 
+	data->descs_pool_size = CPSW_CPDMA_DESCS_POOL_SIZE_DEFAULT;
+	of_property_read_u32(node, "descs_pool_size", &data->descs_pool_size);
+
 	/*
 	 * Populate all the child nodes here...
 	 */
@@ -2967,6 +2971,7 @@ static int cpsw_probe(struct platform_device *pdev)
 	dma_params.has_ext_regs		= true;
 	dma_params.desc_hw_addr         = dma_params.desc_mem_phys;
 	dma_params.bus_freq_mhz		= cpsw->bus_freq_mhz;
+	dma_params.descs_pool_size	= cpsw->data.descs_pool_size;
 
 	cpsw->dma = cpdma_ctlr_create(&dma_params);
 	if (!cpsw->dma) {
diff --git a/drivers/net/ethernet/ti/cpsw.h b/drivers/net/ethernet/ti/cpsw.h
index 16b54c6..8835d79 100644
--- a/drivers/net/ethernet/ti/cpsw.h
+++ b/drivers/net/ethernet/ti/cpsw.h
@@ -38,6 +38,7 @@ struct cpsw_platform_data {
 	u32	mac_control;	/* Mac control register */
 	u16	default_vlan;	/* Def VLAN for ALE lookup in VLAN aware mode*/
 	bool	dual_emac;	/* Enable Dual EMAC mode */
+	u32	descs_pool_size;	/* Number of Rx/Tx Descriptios */
 };
 
 void cpsw_phy_sel(struct device *dev, phy_interface_t phy_mode, int slave);
diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index ba892bb..f45bb8a 100644
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
2.10.1
