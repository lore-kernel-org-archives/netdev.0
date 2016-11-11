From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH v2] net: ethernet: ti: davinci_cpdma: fix fixed prio cpdma ctlr configuration
Date: Fri, 11 Nov 2016 15:45:24 +0200
Message-ID: <1478871924-20985-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: mugunthanvnm@ti.com, grygorii.strashko@ti.com,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The dma ctlr is reseted to 0 while cpdma soft reset, thus cpdma ctlr
cannot be configured after cpdma is stopped. So restoring content
of cpdma ctlr while off/on procedure is needed. The cpdma ctlr off/on
procedure is present while interface down/up and while changing number
of channels with ethtool. In order to not restore content in many
places, move it to cpdma_ctlr_start().

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---

Based on net-next/master

Since v1:
- don't use redundant parameters for cpdma, make prio fixed to be constant

 drivers/net/ethernet/ti/cpsw.c          |   4 --
 drivers/net/ethernet/ti/davinci_cpdma.c | 102 +++++++++++++++++---------------
 2 files changed, 53 insertions(+), 53 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index b1ddf89..39d06e8 100644
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
 
diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index c3f35f1..c2fb1b6 100644
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
@@ -324,6 +372,10 @@ int cpdma_ctlr_start(struct cpdma_ctlr *ctlr)
 		if (ctlr->channels[i])
 			cpdma_chan_start(ctlr->channels[i]);
 	}
+
+	_cpdma_control_set(ctlr, CPDMA_TX_PRIO_FIXED, 1);
+	_cpdma_control_set(ctlr, CPDMA_RX_BUFFER_OFFSET, 0);
+
 	spin_unlock_irqrestore(&ctlr->lock, flags);
 	return 0;
 }
@@ -874,29 +926,6 @@ int cpdma_chan_int_ctrl(struct cpdma_chan *chan, bool enable)
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
@@ -931,35 +960,10 @@ int cpdma_control_get(struct cpdma_ctlr *ctlr, int control)
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
-- 
1.9.1
