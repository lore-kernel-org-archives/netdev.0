From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH 6/6] drivers: net: ethernet: cpsw: implement timestamping capabilities in cpsw
Date: Wed, 17 Oct 2012 04:15:18 +0530
Message-ID: <1350427518-7230-7-git-send-email-mugunthanvnm@ti.com>
References: <1350427518-7230-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Richard Cochran <richardcochran@gmail.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:57633 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755650Ab2JPWpc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2012 18:45:32 -0400
In-Reply-To: <1350427518-7230-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements timestamping capabilities in cpsw through IOCTL interface
to enable and disable PTP time stamping and adds hardware time stamps to the
packet's skb buffer using cpts api

Cc: Richard Cochran <richardcochran@gmail.com>
Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 Documentation/devicetree/bindings/net/cpsw.txt |    3 +
 drivers/net/ethernet/ti/cpsw.c                 |  296 +++++++++++++++++++++++-
 include/linux/platform_data/cpsw.h             |    1 +
 3 files changed, 289 insertions(+), 11 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documentation/devicetree/bindings/net/cpsw.txt
index dcaabe9..7111019 100644
--- a/Documentation/devicetree/bindings/net/cpsw.txt
+++ b/Documentation/devicetree/bindings/net/cpsw.txt
@@ -16,6 +16,7 @@ Required properties:
 - ale_entries		: Specifies No of entries ALE can hold
 - host_port_reg_ofs	: Specifies host port register offset
 - hw_stats_reg_ofs	: Specifies hardware statistics register offset
+- cpts_reg_ofs		: Specifies the offset of the CPTS registers
 - bd_ram_ofs		: Specifies internal desciptor RAM offset
 - bd_ram_size		: Specifies internal descriptor RAM size
 - rx_descs		: Specifies number of Rx descriptors
@@ -52,6 +53,7 @@ Examples:
 		ale_entries = <1024>;
 		host_port_reg_ofs = <0x108>;
 		hw_stats_reg_ofs = <0x900>;
+		cpts_reg_ofs = <0xc00>;
 		bd_ram_ofs = <0x2000>;
 		bd_ram_size = <0x2000>;
 		no_bd_ram = <0>;
@@ -86,6 +88,7 @@ Examples:
 		ale_entries = <1024>;
 		host_port_reg_ofs = <0x108>;
 		hw_stats_reg_ofs = <0x900>;
+		cpts_reg_ofs = <0xc00>;
 		bd_ram_ofs = <0x2000>;
 		bd_ram_size = <0x2000>;
 		no_bd_ram = <0>;
diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index b6af1c6..45babaa 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -31,11 +31,13 @@
 #include <linux/of.h>
 #include <linux/of_net.h>
 #include <linux/of_device.h>
+#include <linux/net_tstamp.h>
 
 #include <linux/platform_data/cpsw.h>
 
 #include "cpsw_ale.h"
 #include "davinci_cpdma.h"
+#include "cpts.h"
 
 #define CPSW_DEBUG	(NETIF_MSG_HW		| NETIF_MSG_WOL		| \
 			 NETIF_MSG_DRV		| NETIF_MSG_LINK	| \
@@ -124,6 +126,41 @@ do {								\
 			disable_irq_nosync(priv->irqs_table[i]); \
 	} while (0);
 
+#define CPSW_MISC_INTR_EN		BIT(4)
+
+#define CPSW_EVT_SYNC_EN		BIT(0)
+#define CPSW_EVT_DELAY_REQ_EN		BIT(1)
+#define CPSW_EVT_PDELAY_REQ_EN		BIT(2)
+#define CPSW_EVT_PDELAY_RESP_EN		BIT(3)
+#define CPSW_EVT_MSG_TYPE_EN		(CPSW_EVT_SYNC_EN |		\
+					 CPSW_EVT_DELAY_REQ_EN |	\
+					 CPSW_EVT_PDELAY_REQ_EN |	\
+					 CPSW_EVT_PDELAY_RESP_EN)
+#define CPSW_V1_TS_RX_EN		BIT(0)
+#define CPSW_V1_TS_TX_EN		BIT(4)
+#define CPSW_V1_MSG_TYPE_OFS		16
+#define CPSW_V1_SEQ_ID_OFS_SHIFT	16
+
+#define CPSW_V2_TS_RX_EN		BIT(0)
+#define CPSW_V2_TS_TX_EN		BIT(1)
+#define CPSW_V2_TS_LTYPE_1_EN		BIT(2)
+#define CPSW_V2_TS_LTYPE_2_EN		BIT(3)
+#define CPSW_V2_TS_ANNEX_D_EN		BIT(4)
+#define CPSW_V2_TS_320			BIT(14)
+#define CPSW_V2_TS_319			BIT(13)
+#define CPSW_V2_TS_132			BIT(12)
+#define CPSW_V2_TS_131			BIT(11)
+#define CPSW_V2_TS_130			BIT(10)
+#define CPSW_V2_TS_129			BIT(9)
+#define CPSW_V2_TS_TTL			BIT(8)
+#define CPSW_V2_SEQ_ID_OFS_SHIFT	16
+#define CPSW_V2_TS_EN		(CPSW_V2_TS_ANNEX_D_EN |		\
+				CPSW_V2_TS_LTYPE_1_EN |			\
+				CPSW_V2_TS_320 | CPSW_V2_TS_319 |	\
+				CPSW_V2_TS_132 | CPSW_V2_TS_131 |	\
+				CPSW_V2_TS_130 | CPSW_V2_TS_129 |	\
+				CPSW_V2_TS_TTL)
+
 enum CPSW_SLAVE_REG_OFS {
 	MAX_BLKS,
 	BLK_CNT,
@@ -248,6 +285,7 @@ struct cpsw_priv {
 	struct cpsw_regs __iomem	*regs;
 	struct cpsw_ss_regs __iomem	*ss_regs;
 	struct cpsw_host_regs __iomem	*host_port_regs;
+	struct cpts_priv		*cpts;
 	u32				msg_enable;
 	struct net_device_stats		stats;
 	int				rx_packet_max;
@@ -263,6 +301,7 @@ struct cpsw_priv {
 	/* snapshot of IRQ numbers */
 	u32 irqs_table[4];
 	u32 num_irqs;
+	u32 statistics_irq;
 };
 
 #define napi_to_priv(napi)	container_of(napi, struct cpsw_priv, napi)
@@ -297,6 +336,180 @@ static void cpsw_ndo_set_rx_mode(struct net_device *ndev)
 	}
 }
 
+#ifdef CONFIG_TI_CPTS
+
+#define cpts_interrupt(priv)						   \
+	do {								   \
+		if (unlikely(readl(&priv->cpts->reg->intstat_raw) & 0x01))  \
+			cpts_event_fifo_read(priv->cpts);		   \
+	} while (0)
+
+static int cpts_enable_ts(struct cpsw_priv *priv, bool tx_state, bool rx_state)
+{
+	u32 ts_en = 0;
+	u32 seq_id = 0;
+
+	if (priv->cpsw_version == CPSW_VERSION_1) {
+		if (tx_state || rx_state) {
+			/* Enable TS */
+			if (tx_state)
+				ts_en = CPSW_V1_TS_TX_EN;
+			if (rx_state)
+				ts_en |= CPSW_V1_TS_RX_EN;
+			ts_en |= CPSW_EVT_MSG_TYPE_EN << CPSW_V1_MSG_TYPE_OFS;
+
+			writel(ts_en, cpsw_slave_reg(priv, &priv->slaves[0],
+						   TS_CTL));
+			writel(ts_en, cpsw_slave_reg(priv, &priv->slaves[1],
+						   TS_CTL));
+
+			seq_id = (CPSW_SEQ_ID_OFS << CPSW_V1_SEQ_ID_OFS_SHIFT) |
+				CPSW_801_1Q_LTYPE;
+			writel(seq_id, cpsw_slave_reg(priv, &priv->slaves[0],
+						   TS_SEQ_LTYPE));
+			writel(seq_id, cpsw_slave_reg(priv, &priv->slaves[1],
+						   TS_SEQ_LTYPE));
+		} else {
+			/* Disable TS */
+			writel(0, cpsw_slave_reg(priv, &priv->slaves[0],
+						 TS_CTL));
+			writel(0, cpsw_slave_reg(priv, &priv->slaves[1],
+						 TS_CTL));
+		}
+	} else {
+		if (tx_state || rx_state) {
+			/* Enable TS */
+			if (tx_state)
+				ts_en = CPSW_V2_TS_TX_EN;
+			if (rx_state)
+				ts_en |= CPSW_V2_TS_RX_EN;
+			ts_en |= CPSW_V2_TS_EN;
+
+			writel(ts_en, cpsw_slave_reg(priv, &priv->slaves[0],
+						   PORT_CONTROL));
+			writel(ts_en, cpsw_slave_reg(priv, &priv->slaves[1],
+						   PORT_CONTROL));
+
+			seq_id = (CPSW_SEQ_ID_OFS << CPSW_V2_SEQ_ID_OFS_SHIFT) |
+				CPSW_EVT_MSG_TYPE_EN;
+			writel(seq_id, cpsw_slave_reg(priv, &priv->slaves[0],
+						   TS_SEQ_MTYPE));
+			writel(seq_id, cpsw_slave_reg(priv, &priv->slaves[1],
+						   TS_SEQ_MTYPE));
+
+			writel(CPSW_801_1Q_LTYPE, &priv->regs->ts_ltype);
+		} else {
+			/* Disable TS */
+			writel(0, cpsw_slave_reg(priv, &priv->slaves[0],
+						 PORT_CONTROL));
+			writel(0, cpsw_slave_reg(priv, &priv->slaves[1],
+						 PORT_CONTROL));
+
+			writel(0, cpsw_slave_reg(priv, &priv->slaves[0],
+						 TS_SEQ_MTYPE));
+			writel(0, cpsw_slave_reg(priv, &priv->slaves[1],
+						 TS_SEQ_MTYPE));
+		}
+	}
+
+	if (tx_state || rx_state)
+		pr_info("cpts: Enabling PTP Time stamping...\n");
+	else
+		pr_info("cpts: Disabling PTP Time stamping...\n");
+
+	return 0;
+}
+
+static int cpsw_hwtstamp_ioctl(struct net_device *ndev,
+		struct ifreq *ifr, int cmd)
+{
+	struct hwtstamp_config config;
+	struct cpsw_priv *priv = netdev_priv(ndev);
+
+	if (copy_from_user(&config, ifr->ifr_data, sizeof(config)))
+		return -EFAULT;
+
+	netdev_dbg(priv->ndev,
+		   "%s config flag:0x%x, tx_type:0x%x, rx_filter:0x%x\n",
+		   __func__, config.flags, config.tx_type, config.rx_filter);
+
+	/* reserved for future extensions */
+	if (config.flags)
+		return -EINVAL;
+
+	switch (config.tx_type) {
+	case HWTSTAMP_TX_OFF:
+		priv->cpts->enable_txts = false;
+		break;
+	case HWTSTAMP_TX_ON:
+		priv->cpts->enable_txts = true;
+		break;
+	default:
+		return -ERANGE;
+	}
+
+	switch (config.rx_filter) {
+	case HWTSTAMP_FILTER_NONE:
+		/*
+		 * Don't allow any timestamping
+		 */
+		priv->cpts->enable_rxts = false;
+		break;
+
+	case HWTSTAMP_FILTER_PTP_V1_L4_EVENT:
+	case HWTSTAMP_FILTER_PTP_V1_L4_SYNC:
+	case HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ:
+		netdev_err(priv->ndev,
+			   "PTP V1 L4 Timestamping is not supported!!!\n");
+		config.rx_filter = HWTSTAMP_FILTER_NONE;
+		config.tx_type = HWTSTAMP_TX_OFF;
+		break;
+
+	case HWTSTAMP_FILTER_PTP_V2_L4_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_L4_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ:
+		if (priv->cpsw_version == CPSW_VERSION_1) {
+			netdev_err(priv->ndev,
+			       "PTP V1 L4 Timestamping is not supported!!!\n");
+			priv->cpts->enable_txts = false;
+			priv->cpts->enable_rxts = false;
+			break;
+		}
+	case HWTSTAMP_FILTER_PTP_V2_L2_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_L2_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ:
+	case HWTSTAMP_FILTER_PTP_V2_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
+		if (priv->cpsw_version == CPSW_VERSION_1)
+			config.rx_filter = HWTSTAMP_FILTER_PTP_V2_L2_EVENT;
+		else
+			config.rx_filter = HWTSTAMP_FILTER_PTP_V2_EVENT;
+		priv->cpts->enable_rxts = true;
+		break;
+	default:
+		return -ERANGE;
+	}
+
+	cpts_enable_ts(priv, priv->cpts->enable_txts, priv->cpts->enable_rxts);
+
+	return copy_to_user(ifr->ifr_data, &config, sizeof(config)) ?
+			-EFAULT : 0;
+}
+
+static inline void cpts_enable_hw_clock(struct cpsw_priv *priv)
+{
+	if (cpts_register(&priv->pdev->dev, priv->cpts) == 0)
+		/* Enable CPSW_SS Misc Interrupt */
+		writel(CPSW_MISC_INTR_EN, &priv->ss_regs->misc_en);
+}
+
+#else
+#define cpts_interrupt(priv)
+#define cpsw_hwtstamp_ioctl(ndev, ifr, cmd) (-EOPNOTSUPP)
+#define cpts_enable_hw_clock(priv)
+#endif
+
 static void cpsw_intr_enable(struct cpsw_priv *priv)
 {
 	__raw_writel(0xFF, &priv->ss_regs->tx_en);
@@ -323,6 +536,7 @@ void cpsw_tx_handler(void *token, int len, int status)
 
 	if (unlikely(netif_queue_stopped(ndev)))
 		netif_start_queue(ndev);
+	cpts_tx_timestamp(priv->cpts, skb);
 	priv->stats.tx_packets++;
 	priv->stats.tx_bytes += len;
 	dev_kfree_skb_any(skb);
@@ -343,6 +557,7 @@ void cpsw_rx_handler(void *token, int len, int status)
 	}
 	if (likely(status >= 0)) {
 		skb_put(skb, len);
+		cpts_rx_timestamp(priv->cpts, skb);
 		skb->protocol = eth_type_trans(skb, ndev);
 		netif_receive_skb(skb);
 		priv->stats.rx_bytes += len;
@@ -367,6 +582,16 @@ void cpsw_rx_handler(void *token, int len, int status)
 	WARN_ON(ret < 0);
 }
 
+static irqreturn_t cpsw_statistics_interrupt(int irq, void *dev_id)
+{
+	struct cpsw_priv *priv = dev_id;
+
+	cpts_interrupt(priv);
+
+	cpdma_ctlr_eoi_statistics(priv->dma);
+	return IRQ_HANDLED;
+}
+
 static irqreturn_t cpsw_interrupt(int irq, void *dev_id)
 {
 	struct cpsw_priv *priv = dev_id;
@@ -618,6 +843,9 @@ static int cpsw_ndo_open(struct net_device *ndev)
 	/* continue even if we didn't manage to submit all receive descs */
 	cpsw_info(priv, ifup, "submitted %d rx descriptors\n", i);
 
+	/* Enable CPTS clock */
+	cpts_enable_hw_clock(priv);
+
 	cpdma_ctlr_start(priv->dma);
 	cpsw_intr_enable(priv);
 	napi_enable(&priv->napi);
@@ -641,12 +869,14 @@ static int cpsw_ndo_stop(struct net_device *ndev)
 
 	cpsw_info(priv, ifdown, "shutting down cpsw device\n");
 	cpsw_intr_disable(priv);
+	disable_irq_nosync(priv->statistics_irq);
 	cpdma_ctlr_int_ctrl(priv->dma, false);
 	cpdma_ctlr_stop(priv->dma);
 	netif_stop_queue(priv->ndev);
 	napi_disable(&priv->napi);
 	netif_carrier_off(priv->ndev);
 	cpsw_ale_stop(priv->ale);
+	cpts_unregister(priv->cpts);
 	for_each_slave(priv, cpsw_slave_stop, priv);
 	pm_runtime_put_sync(&priv->pdev->dev);
 	return 0;
@@ -738,6 +968,23 @@ static void cpsw_ndo_poll_controller(struct net_device *ndev)
 }
 #endif
 
+static int cpsw_ndo_do_ioctl(struct net_device *ndev, struct ifreq *ifrq,
+		int cmd)
+{
+	if (!(netif_running(ndev)))
+		return -EINVAL;
+
+	switch (cmd) {
+
+	case SIOCSHWTSTAMP:
+		return cpsw_hwtstamp_ioctl(ndev, ifrq, cmd);
+
+	default:
+		return -EOPNOTSUPP;
+	}
+	return 0;
+}
+
 static const struct net_device_ops cpsw_netdev_ops = {
 	.ndo_open		= cpsw_ndo_open,
 	.ndo_stop		= cpsw_ndo_stop,
@@ -748,6 +995,7 @@ static const struct net_device_ops cpsw_netdev_ops = {
 	.ndo_tx_timeout		= cpsw_ndo_tx_timeout,
 	.ndo_get_stats		= cpsw_ndo_get_stats,
 	.ndo_set_rx_mode	= cpsw_ndo_set_rx_mode,
+	.ndo_do_ioctl		= cpsw_ndo_do_ioctl,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= cpsw_ndo_poll_controller,
 #endif
@@ -874,6 +1122,13 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 	}
 	data->hw_stats_reg_ofs = prop;
 
+	if (of_property_read_u32(node, "cpts_reg_ofs", &prop)) {
+		pr_err("Missing cpts_reg_ofs property in the DT.\n");
+		ret = -EINVAL;
+		goto error_ret;
+	}
+	data->cpts_reg_ofs = prop;
+
 	if (of_property_read_u32(node, "bd_ram_ofs", &prop)) {
 		pr_err("Missing bd_ram_ofs property in the DT.\n");
 		ret = -EINVAL;
@@ -952,7 +1207,6 @@ static int __devinit cpsw_probe(struct platform_device *pdev)
 	struct cpdma_params		dma_params;
 	struct cpsw_ale_params		ale_params;
 	void __iomem			*regs;
-	struct resource			*res;
 	int ret = 0, i, k = 0;
 
 	ndev = alloc_etherdev(sizeof(struct cpsw_priv));
@@ -967,6 +1221,12 @@ static int __devinit cpsw_probe(struct platform_device *pdev)
 	priv->pdev = pdev;
 	priv->ndev = ndev;
 	priv->dev  = &ndev->dev;
+	priv->cpts = devm_kzalloc(&pdev->dev, sizeof(struct cpts_priv),
+				  GFP_KERNEL);
+	if (!priv->cpts) {
+		ret = -EBUSY;
+		goto clean_ndev_ret;
+	}
 	priv->msg_enable = netif_msg_init(debug_level, CPSW_DEBUG);
 	priv->rx_packet_max = max(rx_packet_max, 128);
 
@@ -1026,6 +1286,8 @@ static int __devinit cpsw_probe(struct platform_device *pdev)
 	priv->regs = regs;
 	priv->host_port = data->host_port_num;
 	priv->host_port_regs = regs + data->host_port_reg_ofs;
+	/* Init CPTS Regs offsets */
+	priv->cpts->reg = regs + data->cpts_reg_ofs;
 
 	priv->cpsw_ss_res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
 	if (!priv->cpsw_ss_res) {
@@ -1119,17 +1381,27 @@ static int __devinit cpsw_probe(struct platform_device *pdev)
 		goto clean_ale_ret;
 	}
 
-	while ((res = platform_get_resource(priv->pdev, IORESOURCE_IRQ, k))) {
-		for (i = res->start; i <= res->end; i++) {
-			if (request_irq(i, cpsw_interrupt, IRQF_DISABLED,
-					dev_name(&pdev->dev), priv)) {
-				dev_err(priv->dev, "error attaching irq\n");
-				goto clean_ale_ret;
-			}
-			priv->irqs_table[k] = i;
-			priv->num_irqs = k;
+	for (k = 0; (k < 3) ; k++) {
+		i = platform_get_irq(pdev, k);
+		if (i < 0)
+			continue;
+		if (request_irq(i, cpsw_interrupt, IRQF_DISABLED,
+				dev_name(&pdev->dev), priv)) {
+			dev_err(priv->dev, "error attaching irq\n");
+			goto clean_ale_ret;
+		}
+		priv->irqs_table[k] = i;
+		priv->num_irqs = k+1;
+	}
+
+	i = platform_get_irq(pdev, k);
+	if (i >= 0) {
+		if (request_irq(i, cpsw_statistics_interrupt, IRQF_DISABLED,
+				dev_name(&pdev->dev), priv)) {
+			dev_err(priv->dev, "error attaching irq\n");
+			goto clean_ale_ret;
 		}
-		k++;
+		priv->statistics_irq = i;
 	}
 
 	ndev->flags |= IFF_ALLMULTI;	/* see cpsw_ndo_change_rx_flags() */
@@ -1154,6 +1426,7 @@ static int __devinit cpsw_probe(struct platform_device *pdev)
 
 clean_irq_ret:
 	free_irq(ndev->irq, priv);
+	free_irq(priv->statistics_irq, priv);
 clean_ale_ret:
 	cpsw_ale_destroy(priv->ale);
 clean_dma_ret:
@@ -1187,6 +1460,7 @@ static int __devexit cpsw_remove(struct platform_device *pdev)
 	platform_set_drvdata(pdev, NULL);
 
 	free_irq(ndev->irq, priv);
+	free_irq(priv->statistics_irq, priv);
 	cpsw_ale_destroy(priv->ale);
 	cpdma_chan_destroy(priv->txch);
 	cpdma_chan_destroy(priv->rxch);
diff --git a/include/linux/platform_data/cpsw.h b/include/linux/platform_data/cpsw.h
index c4e23d0..4b4b1b8 100644
--- a/include/linux/platform_data/cpsw.h
+++ b/include/linux/platform_data/cpsw.h
@@ -41,6 +41,7 @@ struct cpsw_platform_data {
 	u32     host_port_num; /* The port number for the host port */
 
 	u32	hw_stats_reg_ofs;  /* cpsw hardware statistics counters */
+	u32	cpts_reg_ofs;      /* cpts register offset */
 
 	u32	bd_ram_ofs;   /* embedded buffer descriptor RAM offset*/
 	u32	bd_ram_size;  /*buffer descriptor ram size */
-- 
1.7.0.4
