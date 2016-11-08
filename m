From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH] net: ethernet: ti: davinci_cpdma: fix fixed prio cpdma ctlr configuration
Date: Tue,  8 Nov 2016 15:10:56 +0200
Message-ID: <1478610656-24634-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: mugunthanvnm@ti.com, grygorii.strashko@ti.com,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:34077 "EHLO
        mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753340AbcKHNLC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2016 08:11:02 -0500
Received: by mail-lf0-f47.google.com with SMTP id o141so66821238lff.1
        for <netdev@vger.kernel.org>; Tue, 08 Nov 2016 05:11:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The dma ctlr is reseted to 0 while cpdma start, thus cpdma ctlr
cannot be configured after cpdma is stopped. So, restore content
of cpdma ctlr while off/on procedure.

Based on net-next/master

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
 drivers/net/ethernet/ti/cpsw.c          |   6 +-
 drivers/net/ethernet/ti/davinci_cpdma.c | 103 +++++++++++++++++---------------
 drivers/net/ethernet/ti/davinci_cpdma.h |   2 +
 3 files changed, 58 insertions(+), 53 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index b1ddf89..4d04b8e 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1376,10 +1376,6 @@ static int cpsw_ndo_open(struct net_device *ndev)
 				  ALE_ALL_PORTS, ALE_ALL_PORTS, 0, 0);
 
 	if (!cpsw_common_res_usage_state(cpsw)) {
-		/* setup tx dma to fixed prio and zero offset */
-		cpdma_control_set(cpsw->dma, CPDMA_TX_PRIO_FIXED, 1);
-		cpdma_control_set(cpsw->dma, CPDMA_RX_BUFFER_OFFSET, 0);
-
 		/* disable priority elevation */
 		__raw_writel(0, &cpsw->regs->ptype);
 
@@ -2710,6 +2706,8 @@ static int cpsw_probe(struct platform_device *pdev)
 	dma_params.desc_align		= 16;
 	dma_params.has_ext_regs		= true;
 	dma_params.desc_hw_addr         = dma_params.desc_mem_phys;
+	dma_params.rxbuf_offset		= 0;
+	dma_params.fixed_prio		= 1;
 
 	cpsw->dma = cpdma_ctlr_create(&dma_params);
 	if (!cpsw->dma) {
diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index c3f35f1..05afc05 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -124,6 +124,29 @@ struct cpdma_chan {
 	int	int_set, int_clear, td;
 };
 
+struct cpdma_control_info {
+	u32		reg;
+	u32		shift, mask;
+	int		access;
+#define ACCESS_RO	BIT(0)
+#define ACCESS_WO	BIT(1)
+#define ACCESS_RW	(ACCESS_RO | ACCESS_WO)
+};
+
+static struct cpdma_control_info controls[] = {
+	[CPDMA_CMD_IDLE]	  = {CPDMA_DMACONTROL,	3,  1,      ACCESS_WO},
+	[CPDMA_COPY_ERROR_FRAMES] = {CPDMA_DMACONTROL,	4,  1,      ACCESS_RW},
+	[CPDMA_RX_OFF_LEN_UPDATE] = {CPDMA_DMACONTROL,	2,  1,      ACCESS_RW},
+	[CPDMA_RX_OWNERSHIP_FLIP] = {CPDMA_DMACONTROL,	1,  1,      ACCESS_RW},
+	[CPDMA_TX_PRIO_FIXED]	  = {CPDMA_DMACONTROL,	0,  1,      ACCESS_RW},
+	[CPDMA_STAT_IDLE]	  = {CPDMA_DMASTATUS,	31, 1,      ACCESS_RO},
+	[CPDMA_STAT_TX_ERR_CODE]  = {CPDMA_DMASTATUS,	20, 0xf,    ACCESS_RW},
+	[CPDMA_STAT_TX_ERR_CHAN]  = {CPDMA_DMASTATUS,	16, 0x7,    ACCESS_RW},
+	[CPDMA_STAT_RX_ERR_CODE]  = {CPDMA_DMASTATUS,	12, 0xf,    ACCESS_RW},
+	[CPDMA_STAT_RX_ERR_CHAN]  = {CPDMA_DMASTATUS,	8,  0x7,    ACCESS_RW},
+	[CPDMA_RX_BUFFER_OFFSET]  = {CPDMA_RXBUFFOFS,	0,  0xffff, ACCESS_RW},
+};
+
 #define tx_chan_num(chan)	(chan)
 #define rx_chan_num(chan)	((chan) + CPDMA_MAX_CHANNELS)
 #define is_rx_chan(chan)	((chan)->chan_num >= CPDMA_MAX_CHANNELS)
@@ -253,6 +276,31 @@ static void cpdma_desc_free(struct cpdma_desc_pool *pool,
 	gen_pool_free(pool->gen_pool, (unsigned long)desc, pool->desc_size);
 }
 
+static int _cpdma_control_set(struct cpdma_ctlr *ctlr, int control, int value)
+{
+	struct cpdma_control_info *info = &controls[control];
+	u32 val;
+
+	if (!ctlr->params.has_ext_regs)
+		return -ENOTSUPP;
+
+	if (ctlr->state != CPDMA_STATE_ACTIVE)
+		return -EINVAL;
+
+	if (control < 0 || control >= ARRAY_SIZE(controls))
+		return -ENOENT;
+
+	if ((info->access & ACCESS_WO) != ACCESS_WO)
+		return -EPERM;
+
+	val  = dma_reg_read(ctlr, info->reg);
+	val &= ~(info->mask << info->shift);
+	val |= (value & info->mask) << info->shift;
+	dma_reg_write(ctlr, info->reg, val);
+
+	return 0;
+}
+
 struct cpdma_ctlr *cpdma_ctlr_create(struct cpdma_params *params)
 {
 	struct cpdma_ctlr *ctlr;
@@ -324,6 +372,11 @@ int cpdma_ctlr_start(struct cpdma_ctlr *ctlr)
 		if (ctlr->channels[i])
 			cpdma_chan_start(ctlr->channels[i]);
 	}
+
+	_cpdma_control_set(ctlr, CPDMA_TX_PRIO_FIXED, ctlr->params.fixed_prio);
+	_cpdma_control_set(ctlr, CPDMA_RX_BUFFER_OFFSET,
+			   ctlr->params.rxbuf_offset);
+
 	spin_unlock_irqrestore(&ctlr->lock, flags);
 	return 0;
 }
@@ -874,29 +927,6 @@ int cpdma_chan_int_ctrl(struct cpdma_chan *chan, bool enable)
 	return 0;
 }
 
-struct cpdma_control_info {
-	u32		reg;
-	u32		shift, mask;
-	int		access;
-#define ACCESS_RO	BIT(0)
-#define ACCESS_WO	BIT(1)
-#define ACCESS_RW	(ACCESS_RO | ACCESS_WO)
-};
-
-static struct cpdma_control_info controls[] = {
-	[CPDMA_CMD_IDLE]	  = {CPDMA_DMACONTROL,	3,  1,      ACCESS_WO},
-	[CPDMA_COPY_ERROR_FRAMES] = {CPDMA_DMACONTROL,	4,  1,      ACCESS_RW},
-	[CPDMA_RX_OFF_LEN_UPDATE] = {CPDMA_DMACONTROL,	2,  1,      ACCESS_RW},
-	[CPDMA_RX_OWNERSHIP_FLIP] = {CPDMA_DMACONTROL,	1,  1,      ACCESS_RW},
-	[CPDMA_TX_PRIO_FIXED]	  = {CPDMA_DMACONTROL,	0,  1,      ACCESS_RW},
-	[CPDMA_STAT_IDLE]	  = {CPDMA_DMASTATUS,	31, 1,      ACCESS_RO},
-	[CPDMA_STAT_TX_ERR_CODE]  = {CPDMA_DMASTATUS,	20, 0xf,    ACCESS_RW},
-	[CPDMA_STAT_TX_ERR_CHAN]  = {CPDMA_DMASTATUS,	16, 0x7,    ACCESS_RW},
-	[CPDMA_STAT_RX_ERR_CODE]  = {CPDMA_DMASTATUS,	12, 0xf,    ACCESS_RW},
-	[CPDMA_STAT_RX_ERR_CHAN]  = {CPDMA_DMASTATUS,	8,  0x7,    ACCESS_RW},
-	[CPDMA_RX_BUFFER_OFFSET]  = {CPDMA_RXBUFFOFS,	0,  0xffff, ACCESS_RW},
-};
-
 int cpdma_control_get(struct cpdma_ctlr *ctlr, int control)
 {
 	unsigned long flags;
@@ -931,35 +961,10 @@ int cpdma_control_get(struct cpdma_ctlr *ctlr, int control)
 int cpdma_control_set(struct cpdma_ctlr *ctlr, int control, int value)
 {
 	unsigned long flags;
-	struct cpdma_control_info *info = &controls[control];
 	int ret;
-	u32 val;
 
 	spin_lock_irqsave(&ctlr->lock, flags);
-
-	ret = -ENOTSUPP;
-	if (!ctlr->params.has_ext_regs)
-		goto unlock_ret;
-
-	ret = -EINVAL;
-	if (ctlr->state != CPDMA_STATE_ACTIVE)
-		goto unlock_ret;
-
-	ret = -ENOENT;
-	if (control < 0 || control >= ARRAY_SIZE(controls))
-		goto unlock_ret;
-
-	ret = -EPERM;
-	if ((info->access & ACCESS_WO) != ACCESS_WO)
-		goto unlock_ret;
-
-	val  = dma_reg_read(ctlr, info->reg);
-	val &= ~(info->mask << info->shift);
-	val |= (value & info->mask) << info->shift;
-	dma_reg_write(ctlr, info->reg, val);
-	ret = 0;
-
-unlock_ret:
+	ret = _cpdma_control_set(ctlr, control, value);
 	spin_unlock_irqrestore(&ctlr->lock, flags);
 	return ret;
 }
diff --git a/drivers/net/ethernet/ti/davinci_cpdma.h b/drivers/net/ethernet/ti/davinci_cpdma.h
index a07b22b..e66420f 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.h
+++ b/drivers/net/ethernet/ti/davinci_cpdma.h
@@ -31,6 +31,8 @@ struct cpdma_params {
 	void __iomem		*rxthresh, *rxfree;
 	int			num_chan;
 	bool			has_soft_reset;
+	bool			fixed_prio;
+	int			rxbuf_offset;
 	int			min_packet_size;
 	u32			desc_mem_phys;
 	u32			desc_hw_addr;
-- 
1.9.1
