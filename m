From: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
Subject: [PATCH 3/3] driver: net: ethernet: cpsw: implement interrupt pacing
 via ethtool
Date: Thu, 7 Mar 2013 18:00:21 +0530
Message-ID: <1362659421-11884-4-git-send-email-mugunthanvnm@ti.com>
References: <1362659421-11884-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
 linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <1362659421-11884-1-git-send-email-mugunthanvnm-l0cyMroinI0@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss/>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: "devicetree-discuss"
 <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

This patch implements support for interrupt pacing block of CPSW via ethtool

Signed-off-by: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
---
 drivers/net/ethernet/ti/cpsw.c |   95 ++++++++++++++++++++++++++++++++++++++++
 1 file changed, 95 insertions(+)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index fa91eec..da7276d 100644
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
@@ -160,6 +167,15 @@ struct cpsw_wr_regs {
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
@@ -314,6 +330,8 @@ struct cpsw_priv {
 	struct cpsw_host_regs __iomem	*host_port_regs;
 	u32				msg_enable;
 	u32				version;
+	u32				coal_intvl;
+	u32				bus_freq_mhz;
 	struct net_device_stats		stats;
 	int				rx_packet_max;
 	int				host_port;
@@ -612,6 +630,68 @@ static void cpsw_adjust_link(struct net_device *ndev)
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
+	priv->coal_intvl = coal_intvl;
+
+	return 0;
+}
+
 static inline int __show_stat(char *buf, int maxlen, const char *name, u32 val)
 {
 	static char *leader = "........................................";
@@ -834,6 +914,14 @@ static int cpsw_ndo_open(struct net_device *ndev)
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
@@ -1279,6 +1367,8 @@ static const struct ethtool_ops cpsw_ethtool_ops = {
 	.get_ts_info	= cpsw_get_ts_info,
 	.get_settings	= cpsw_get_settings,
 	.set_settings	= cpsw_set_settings,
+	.get_coalesce	= cpsw_get_coalesce,
+	.set_coalesce	= cpsw_set_coalesce,
 };
 
 static void cpsw_slave_init(struct cpsw_slave *slave, struct cpsw_priv *priv,
@@ -1469,6 +1559,9 @@ static int cpsw_probe_dual_emac(struct platform_device *pdev,
 	priv_sl2->slaves = priv->slaves;
 	priv_sl2->clk = priv->clk;
 
+	priv_sl2->coal_intvl = 0;
+	priv_sl2->bus_freq_mhz = clk_get_rate(priv_sl2->clk) / 1000000;
+
 	priv_sl2->cpsw_res = priv->cpsw_res;
 	priv_sl2->regs = priv->regs;
 	priv_sl2->host_port = priv->host_port;
@@ -1578,6 +1671,8 @@ static int cpsw_probe(struct platform_device *pdev)
 		ret = -ENODEV;
 		goto clean_slave_ret;
 	}
+	priv->coal_intvl = 0;
+	priv->bus_freq_mhz = clk_get_rate(priv->clk) / 1000000;
 
 	priv->cpsw_res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	if (!priv->cpsw_res) {
-- 
1.7.9.5
