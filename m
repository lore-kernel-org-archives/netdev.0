From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH v2 4/5] driver: net: ethernet: cpsw: implement interrupt pacing via ethtool
Date: Tue, 12 Mar 2013 14:46:37 +0530
Message-ID: <1363079798-18147-5-git-send-email-mugunthanvnm@ti.com>
References: <1363079798-18147-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <devicetree-discuss@lists.ozlabs.org>,
	<linux-omap@vger.kernel.org>, <b-cousson@ti.com>, <paul@pwsan.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1363079798-18147-1-git-send-email-mugunthanvnm@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch implements support for interrupt pacing block of CPSW via ethtool
Inetrrupt pacing block is common of both the ethernet interface in
dual emac mode

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c |  104 ++++++++++++++++++++++++++++++++++++++++
 1 file changed, 104 insertions(+)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 83ce890..d6cf698 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -126,6 +126,13 @@ do {								\
 #define CPSW_FIFO_DUAL_MAC_MODE		(1 << 15)
 #define CPSW_FIFO_RATE_LIMIT_MODE	(2 << 15)
 
+#define CPSW_INTPACEEN		(0x3f << 16)
+#define CPSW_INTPRESCALE_MASK	(0x7FF << 0)
+#define CPSW_CMINTMAX_CNT	63
+#define CPSW_CMINTMIN_CNT	2
+#define CPSW_CMINTMAX_INTVL	(1000 / CPSW_CMINTMIN_CNT)
+#define CPSW_CMINTMIN_INTVL	((1000 / CPSW_CMINTMAX_CNT) + 1)
+
 #define cpsw_enable_irq(priv)	\
 	do {			\
 		u32 i;		\
@@ -164,6 +171,15 @@ struct cpsw_wr_regs {
 	u32	rx_en;
 	u32	tx_en;
 	u32	misc_en;
+	u32	mem_allign1[8];
+	u32	rx_thresh_stat;
+	u32	rx_stat;
+	u32	tx_stat;
+	u32	misc_stat;
+	u32	mem_allign2[8];
+	u32	rx_imax;
+	u32	tx_imax;
+
 };
 
 struct cpsw_ss_regs {
@@ -318,6 +334,8 @@ struct cpsw_priv {
 	struct cpsw_host_regs __iomem	*host_port_regs;
 	u32				msg_enable;
 	u32				version;
+	u32				coal_intvl;
+	u32				bus_freq_mhz;
 	struct net_device_stats		stats;
 	int				rx_packet_max;
 	int				host_port;
@@ -616,6 +634,77 @@ static void cpsw_adjust_link(struct net_device *ndev)
 	}
 }
 
+static int cpsw_get_coalesce(struct net_device *ndev,
+				struct ethtool_coalesce *coal)
+{
+	struct cpsw_priv *priv = netdev_priv(ndev);
+
+	coal->rx_coalesce_usecs = priv->coal_intvl;
+	return 0;
+}
+
+static int cpsw_set_coalesce(struct net_device *ndev,
+				struct ethtool_coalesce *coal)
+{
+	struct cpsw_priv *priv = netdev_priv(ndev);
+	u32 int_ctrl;
+	u32 num_interrupts = 0;
+	u32 prescale = 0;
+	u32 addnl_dvdr = 1;
+	u32 coal_intvl = 0;
+
+	if (!coal->rx_coalesce_usecs)
+		return -EINVAL;
+
+	coal_intvl = coal->rx_coalesce_usecs;
+
+	int_ctrl =  readl(&priv->wr_regs->int_control);
+	prescale = priv->bus_freq_mhz * 4;
+
+	if (coal_intvl < CPSW_CMINTMIN_INTVL)
+		coal_intvl = CPSW_CMINTMIN_INTVL;
+
+	if (coal_intvl > CPSW_CMINTMAX_INTVL) {
+		/* Interrupt pacer works with 4us Pulse, we can
+		 * throttle further by dilating the 4us pulse.
+		 */
+		addnl_dvdr = CPSW_INTPRESCALE_MASK / prescale;
+
+		if (addnl_dvdr > 1) {
+			prescale *= addnl_dvdr;
+			if (coal_intvl > (CPSW_CMINTMAX_INTVL * addnl_dvdr))
+				coal_intvl = (CPSW_CMINTMAX_INTVL
+						* addnl_dvdr);
+		} else {
+			addnl_dvdr = 1;
+			coal_intvl = CPSW_CMINTMAX_INTVL;
+		}
+	}
+
+	num_interrupts = (1000 * addnl_dvdr) / coal_intvl;
+	writel(num_interrupts, &priv->wr_regs->rx_imax);
+	writel(num_interrupts, &priv->wr_regs->tx_imax);
+
+	int_ctrl |= CPSW_INTPACEEN;
+	int_ctrl &= (~CPSW_INTPRESCALE_MASK);
+	int_ctrl |= (prescale & CPSW_INTPRESCALE_MASK);
+	writel(int_ctrl, &priv->wr_regs->int_control);
+
+	cpsw_notice(priv, timer, "Set coalesce to %d usecs.\n", coal_intvl);
+	if (priv->data.dual_emac) {
+		int i;
+
+		for (i = 0; i < priv->data.slaves; i++) {
+			priv = netdev_priv(priv->slaves[i].ndev);
+			priv->coal_intvl = coal_intvl;
+		}
+	} else {
+		priv->coal_intvl = coal_intvl;
+	}
+
+	return 0;
+}
+
 static inline int __show_stat(char *buf, int maxlen, const char *name, u32 val)
 {
 	static char *leader = "........................................";
@@ -838,6 +927,14 @@ static int cpsw_ndo_open(struct net_device *ndev)
 		cpsw_info(priv, ifup, "submitted %d rx descriptors\n", i);
 	}
 
+	/* Enable Interrupt pacing if configured */
+	if (priv->coal_intvl != 0) {
+		struct ethtool_coalesce coal;
+
+		coal.rx_coalesce_usecs = (priv->coal_intvl << 4);
+		cpsw_set_coalesce(ndev, &coal);
+	}
+
 	cpdma_ctlr_start(priv->dma);
 	cpsw_intr_enable(priv);
 	napi_enable(&priv->napi);
@@ -1279,6 +1376,8 @@ static const struct ethtool_ops cpsw_ethtool_ops = {
 	.get_ts_info	= cpsw_get_ts_info,
 	.get_settings	= cpsw_get_settings,
 	.set_settings	= cpsw_set_settings,
+	.get_coalesce	= cpsw_get_coalesce,
+	.set_coalesce	= cpsw_set_coalesce,
 };
 
 static void cpsw_slave_init(struct cpsw_slave *slave, struct cpsw_priv *priv,
@@ -1466,6 +1565,9 @@ static int cpsw_probe_dual_emac(struct platform_device *pdev,
 	priv_sl2->slaves = priv->slaves;
 	priv_sl2->clk = priv->clk;
 
+	priv_sl2->coal_intvl = 0;
+	priv_sl2->bus_freq_mhz = priv->bus_freq_mhz;
+
 	priv_sl2->cpsw_res = priv->cpsw_res;
 	priv_sl2->regs = priv->regs;
 	priv_sl2->host_port = priv->host_port;
@@ -1575,6 +1677,8 @@ static int cpsw_probe(struct platform_device *pdev)
 		ret = -ENODEV;
 		goto clean_slave_ret;
 	}
+	priv->coal_intvl = 0;
+	priv->bus_freq_mhz = clk_get_rate(priv->clk) / 1000000;
 
 	priv->cpsw_res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	if (!priv->cpsw_res) {
-- 
1.7.9.5

