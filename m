From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH 1/1] drivers: net: cpsw: add support to show hw stats via ethtool get_regs
Date: Fri, 19 Jul 2013 19:37:21 +0530
Message-ID: <1374242841-17141-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <linux-omap@vger.kernel.org>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-omap-owner@vger.kernel.org>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support to show CPSW hardware statistics to user via ethtool get_regs
ops so user can find if there were any error reported or the system is
over loaded duing hagh data rate transfer.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c |   74 ++++++++++++++++++++++++++++++++++++++--
 1 file changed, 71 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 05a1674..64117f5 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -85,12 +85,14 @@ do {								\
 
 #define HOST_PORT_NUM		0
 #define SLIVER_SIZE		0x40
+#define CPSW_HW_STATS_LEN	36
 
 #define CPSW1_HOST_PORT_OFFSET	0x028
 #define CPSW1_SLAVE_OFFSET	0x050
 #define CPSW1_SLAVE_SIZE	0x040
 #define CPSW1_CPDMA_OFFSET	0x100
 #define CPSW1_STATERAM_OFFSET	0x200
+#define CPSW1_HW_STATS		0x400
 #define CPSW1_CPTS_OFFSET	0x500
 #define CPSW1_ALE_OFFSET	0x600
 #define CPSW1_SLIVER_OFFSET	0x700
@@ -99,6 +101,7 @@ do {								\
 #define CPSW2_SLAVE_OFFSET	0x200
 #define CPSW2_SLAVE_SIZE	0x100
 #define CPSW2_CPDMA_OFFSET	0x800
+#define CPSW2_HW_STATS		0x900
 #define CPSW2_STATERAM_OFFSET	0xa00
 #define CPSW2_CPTS_OFFSET	0xc00
 #define CPSW2_ALE_OFFSET	0xd00
@@ -332,6 +335,7 @@ struct cpsw_priv {
 	struct cpsw_platform_data	data;
 	struct cpsw_ss_regs __iomem	*regs;
 	struct cpsw_wr_regs __iomem	*wr_regs;
+	void __iomem			*hw_stats;
 	struct cpsw_host_regs __iomem	*host_port_regs;
 	u32				msg_enable;
 	u32				version;
@@ -723,6 +727,64 @@ static int cpsw_set_coalesce(struct net_device *ndev,
 	return 0;
 }
 
+static int cpsw_get_regs_len(struct net_device *ndev)
+{
+	int len;
+
+	len = CPSW_HW_STATS_LEN * sizeof(u32);
+	len += 2 * sizeof(struct cpdma_chan_stats);
+
+	return len;
+}
+
+static void cpsw_get_regs(struct net_device *ndev,
+			  struct ethtool_regs *regs, void *p)
+{
+	struct cpsw_priv *priv = netdev_priv(ndev);
+	struct cpdma_chan_stats	dma_stats;
+	u32 *reg = p;
+	int i;
+
+	/* update CPSW IP version */
+	regs->version = priv->version;
+
+	/* Packet Tx/Rx statistics */
+	for (i = 0; i < CPSW_HW_STATS_LEN; i++)
+		reg[i] = readl(((u32 *)priv->hw_stats) + i);
+
+	/* Rx DMA statistics */
+	cpdma_chan_get_stats(priv->rxch, &dma_stats);
+	reg[i++] = dma_stats.head_enqueue;
+	reg[i++] = dma_stats.tail_enqueue;
+	reg[i++] = dma_stats.pad_enqueue;
+	reg[i++] = dma_stats.misqueued;
+	reg[i++] = dma_stats.desc_alloc_fail;
+	reg[i++] = dma_stats.pad_alloc_fail;
+	reg[i++] = dma_stats.runt_receive_buff;
+	reg[i++] = dma_stats.runt_transmit_buff;
+	reg[i++] = dma_stats.empty_dequeue;
+	reg[i++] = dma_stats.busy_dequeue;
+	reg[i++] = dma_stats.good_dequeue;
+	reg[i++] = dma_stats.requeue;
+	reg[i++] = dma_stats.teardown_dequeue;
+
+	/* Tx DMA statistics */
+	cpdma_chan_get_stats(priv->txch, &dma_stats);
+	reg[i++] = dma_stats.head_enqueue;
+	reg[i++] = dma_stats.tail_enqueue;
+	reg[i++] = dma_stats.pad_enqueue;
+	reg[i++] = dma_stats.misqueued;
+	reg[i++] = dma_stats.desc_alloc_fail;
+	reg[i++] = dma_stats.pad_alloc_fail;
+	reg[i++] = dma_stats.runt_receive_buff;
+	reg[i++] = dma_stats.runt_transmit_buff;
+	reg[i++] = dma_stats.empty_dequeue;
+	reg[i++] = dma_stats.busy_dequeue;
+	reg[i++] = dma_stats.good_dequeue;
+	reg[i++] = dma_stats.requeue;
+	reg[i++] = dma_stats.teardown_dequeue;
+}
+
 static inline int __show_stat(char *buf, int maxlen, const char *name, u32 val)
 {
 	static char *leader = "........................................";
@@ -1344,9 +1406,10 @@ static void cpsw_get_drvinfo(struct net_device *ndev,
 {
 	struct cpsw_priv *priv = netdev_priv(ndev);
 
-	strlcpy(info->driver, "TI CPSW Driver v1.0", sizeof(info->driver));
+	strlcpy(info->driver, "cpsw", sizeof(info->driver));
 	strlcpy(info->version, "1.0", sizeof(info->version));
 	strlcpy(info->bus_info, priv->pdev->name, sizeof(info->bus_info));
+	info->regdump_len = cpsw_get_regs_len(ndev);
 }
 
 static u32 cpsw_get_msglevel(struct net_device *ndev)
@@ -1426,6 +1489,8 @@ static const struct ethtool_ops cpsw_ethtool_ops = {
 	.set_settings	= cpsw_set_settings,
 	.get_coalesce	= cpsw_get_coalesce,
 	.set_coalesce	= cpsw_set_coalesce,
+	.get_regs_len	= cpsw_get_regs_len,
+	.get_regs	= cpsw_get_regs,
 };
 
 static void cpsw_slave_init(struct cpsw_slave *slave, struct cpsw_priv *priv,
@@ -1623,6 +1688,7 @@ static int cpsw_probe_dual_emac(struct platform_device *pdev,
 	priv_sl2->host_port = priv->host_port;
 	priv_sl2->host_port_regs = priv->host_port_regs;
 	priv_sl2->wr_regs = priv->wr_regs;
+	priv_sl2->hw_stats = priv->hw_stats;
 	priv_sl2->dma = priv->dma;
 	priv_sl2->txch = priv->txch;
 	priv_sl2->rxch = priv->rxch;
@@ -1780,7 +1846,8 @@ static int cpsw_probe(struct platform_device *pdev)
 	switch (priv->version) {
 	case CPSW_VERSION_1:
 		priv->host_port_regs = ss_regs + CPSW1_HOST_PORT_OFFSET;
-		priv->cpts->reg       = ss_regs + CPSW1_CPTS_OFFSET;
+		priv->hw_stats	     = ss_regs + CPSW1_HW_STATS;
+		priv->cpts->reg      = ss_regs + CPSW1_CPTS_OFFSET;
 		dma_params.dmaregs   = ss_regs + CPSW1_CPDMA_OFFSET;
 		dma_params.txhdp     = ss_regs + CPSW1_STATERAM_OFFSET;
 		ale_params.ale_regs  = ss_regs + CPSW1_ALE_OFFSET;
@@ -1791,7 +1858,8 @@ static int cpsw_probe(struct platform_device *pdev)
 		break;
 	case CPSW_VERSION_2:
 		priv->host_port_regs = ss_regs + CPSW2_HOST_PORT_OFFSET;
-		priv->cpts->reg       = ss_regs + CPSW2_CPTS_OFFSET;
+		priv->hw_stats	     = ss_regs + CPSW2_HW_STATS;
+		priv->cpts->reg      = ss_regs + CPSW2_CPTS_OFFSET;
 		dma_params.dmaregs   = ss_regs + CPSW2_CPDMA_OFFSET;
 		dma_params.txhdp     = ss_regs + CPSW2_STATERAM_OFFSET;
 		ale_params.ale_regs  = ss_regs + CPSW2_ALE_OFFSET;
-- 
1.7.9.5

