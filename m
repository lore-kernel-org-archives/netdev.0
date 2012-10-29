From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next V3 10/10] cpsw: support the HWTSTAMP ioctl and the CPTS
Date: Mon, 29 Oct 2012 19:45:20 +0100
Message-ID: <6491321837e5ddba8ba1d941bc5602987390ebab.1351535541.git.richardcochran@gmail.com>
References: <cover.1351535536.git.richardcochran@gmail.com>
Cc: <linux-arm-kernel@lists.infradead.org>,
	David Miller <davem@davemloft.net>,
	Cyril Chemparathy <cyril@ti.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:44513 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760527Ab2J2Sp6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2012 14:45:58 -0400
Received: by mail-ee0-f46.google.com with SMTP id b15so2256783eek.19
        for <netdev@vger.kernel.org>; Mon, 29 Oct 2012 11:45:58 -0700 (PDT)
In-Reply-To: <cover.1351535536.git.richardcochran@gmail.com>
In-Reply-To: <cover.1351535536.git.richardcochran@gmail.com>
References: <cover.1351535536.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch hooks into the CPTS code and adds support for the HWTSTAMP
ioctl. The patch includes code for the CPSW version found in the dm814x
even though the background device tree support for this board is still
missing.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/ti/cpsw.c |  182 ++++++++++++++++++++++++++++++++++++++++
 1 files changed, 182 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index c04627c..023d439 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -24,6 +24,7 @@
 #include <linux/if_ether.h>
 #include <linux/etherdevice.h>
 #include <linux/netdevice.h>
+#include <linux/net_tstamp.h>
 #include <linux/phy.h>
 #include <linux/workqueue.h>
 #include <linux/delay.h>
@@ -35,6 +36,7 @@
 #include <linux/platform_data/cpsw.h>
 
 #include "cpsw_ale.h"
+#include "cpts.h"
 #include "davinci_cpdma.h"
 
 #define CPSW_DEBUG	(NETIF_MSG_HW		| NETIF_MSG_WOL		| \
@@ -229,6 +231,14 @@ struct cpsw_ss_regs {
 /* The PTP event messages - Sync, Delay_Req, Pdelay_Req, and Pdelay_Resp. */
 #define EVENT_MSG_BITS ((1<<0) | (1<<1) | (1<<2) | (1<<3))
 
+/* Bit definitions for the CPSW1_TS_CTL register */
+#define CPSW_V1_TS_RX_EN		BIT(0)
+#define CPSW_V1_TS_TX_EN		BIT(4)
+#define CPSW_V1_MSG_TYPE_OFS		16
+
+/* Bit definitions for the CPSW1_TS_SEQ_LTYPE register */
+#define CPSW_V1_SEQ_ID_OFS_SHIFT	16
+
 struct cpsw_host_regs {
 	u32	max_blks;
 	u32	blk_cnt;
@@ -297,6 +307,7 @@ struct cpsw_priv {
 	/* snapshot of IRQ numbers */
 	u32 irqs_table[4];
 	u32 num_irqs;
+	struct cpts cpts;
 };
 
 #define napi_to_priv(napi)	container_of(napi, struct cpsw_priv, napi)
@@ -357,6 +368,7 @@ void cpsw_tx_handler(void *token, int len, int status)
 
 	if (unlikely(netif_queue_stopped(ndev)))
 		netif_start_queue(ndev);
+	cpts_tx_timestamp(&priv->cpts, skb);
 	priv->stats.tx_packets++;
 	priv->stats.tx_bytes += len;
 	dev_kfree_skb_any(skb);
@@ -377,6 +389,7 @@ void cpsw_rx_handler(void *token, int len, int status)
 	}
 	if (likely(status >= 0)) {
 		skb_put(skb, len);
+		cpts_rx_timestamp(&priv->cpts, skb);
 		skb->protocol = eth_type_trans(skb, ndev);
 		netif_receive_skb(skb);
 		priv->stats.rx_bytes += len;
@@ -704,6 +717,11 @@ static netdev_tx_t cpsw_ndo_start_xmit(struct sk_buff *skb,
 		return NETDEV_TX_OK;
 	}
 
+	if (skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP && priv->cpts.tx_enable)
+		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
+
+	skb_tx_timestamp(skb);
+
 	ret = cpdma_chan_submit(priv->txch, skb, skb->data,
 				skb->len, GFP_KERNEL);
 	if (unlikely(ret != 0)) {
@@ -741,6 +759,130 @@ static void cpsw_ndo_change_rx_flags(struct net_device *ndev, int flags)
 		dev_err(&ndev->dev, "multicast traffic cannot be filtered!\n");
 }
 
+#ifdef CONFIG_TI_CPTS
+
+static void cpsw_hwtstamp_v1(struct cpsw_priv *priv)
+{
+	struct cpsw_slave *slave = &priv->slaves[priv->data.cpts_active_slave];
+	u32 ts_en, seq_id;
+
+	if (!priv->cpts.tx_enable && !priv->cpts.rx_enable) {
+		slave_write(slave, 0, CPSW1_TS_CTL);
+		return;
+	}
+
+	seq_id = (30 << CPSW_V1_SEQ_ID_OFS_SHIFT) | ETH_P_1588;
+	ts_en = EVENT_MSG_BITS << CPSW_V1_MSG_TYPE_OFS;
+
+	if (priv->cpts.tx_enable)
+		ts_en |= CPSW_V1_TS_TX_EN;
+
+	if (priv->cpts.rx_enable)
+		ts_en |= CPSW_V1_TS_RX_EN;
+
+	slave_write(slave, ts_en, CPSW1_TS_CTL);
+	slave_write(slave, seq_id, CPSW1_TS_SEQ_LTYPE);
+}
+
+static void cpsw_hwtstamp_v2(struct cpsw_priv *priv)
+{
+	struct cpsw_slave *slave = &priv->slaves[priv->data.cpts_active_slave];
+	u32 ctrl, mtype;
+
+	ctrl = slave_read(slave, CPSW2_CONTROL);
+	ctrl &= ~CTRL_ALL_TS_MASK;
+
+	if (priv->cpts.tx_enable)
+		ctrl |= CTRL_TX_TS_BITS;
+
+	if (priv->cpts.rx_enable)
+		ctrl |= CTRL_RX_TS_BITS;
+
+	mtype = (30 << TS_SEQ_ID_OFFSET_SHIFT) | EVENT_MSG_BITS;
+
+	slave_write(slave, mtype, CPSW2_TS_SEQ_MTYPE);
+	slave_write(slave, ctrl, CPSW2_CONTROL);
+	__raw_writel(ETH_P_1588, &priv->regs->ts_ltype);
+}
+
+static int cpsw_hwtstamp_ioctl(struct cpsw_priv *priv, struct ifreq *ifr)
+{
+	struct cpts *cpts = &priv->cpts;
+	struct hwtstamp_config cfg;
+
+	if (copy_from_user(&cfg, ifr->ifr_data, sizeof(cfg)))
+		return -EFAULT;
+
+	/* reserved for future extensions */
+	if (cfg.flags)
+		return -EINVAL;
+
+	switch (cfg.tx_type) {
+	case HWTSTAMP_TX_OFF:
+		cpts->tx_enable = 0;
+		break;
+	case HWTSTAMP_TX_ON:
+		cpts->tx_enable = 1;
+		break;
+	default:
+		return -ERANGE;
+	}
+
+	switch (cfg.rx_filter) {
+	case HWTSTAMP_FILTER_NONE:
+		cpts->rx_enable = 0;
+		break;
+	case HWTSTAMP_FILTER_ALL:
+	case HWTSTAMP_FILTER_PTP_V1_L4_EVENT:
+	case HWTSTAMP_FILTER_PTP_V1_L4_SYNC:
+	case HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ:
+		return -ERANGE;
+	case HWTSTAMP_FILTER_PTP_V2_L4_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_L4_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ:
+	case HWTSTAMP_FILTER_PTP_V2_L2_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_L2_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ:
+	case HWTSTAMP_FILTER_PTP_V2_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
+		cpts->rx_enable = 1;
+		cfg.rx_filter = HWTSTAMP_FILTER_PTP_V2_EVENT;
+		break;
+	default:
+		return -ERANGE;
+	}
+
+	switch (priv->version) {
+	case CPSW_VERSION_1:
+		cpsw_hwtstamp_v1(priv);
+		break;
+	case CPSW_VERSION_2:
+		cpsw_hwtstamp_v2(priv);
+		break;
+	default:
+		return -ENOTSUPP;
+	}
+
+	return copy_to_user(ifr->ifr_data, &cfg, sizeof(cfg)) ? -EFAULT : 0;
+}
+
+#endif /*CONFIG_TI_CPTS*/
+
+static int cpsw_ndo_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
+{
+	struct cpsw_priv *priv = netdev_priv(dev);
+
+	if (!netif_running(dev))
+		return -EINVAL;
+
+#ifdef CONFIG_TI_CPTS
+	if (cmd == SIOCSHWTSTAMP)
+		return cpsw_hwtstamp_ioctl(priv, req);
+#endif
+	return -ENOTSUPP;
+}
+
 static void cpsw_ndo_tx_timeout(struct net_device *ndev)
 {
 	struct cpsw_priv *priv = netdev_priv(ndev);
@@ -781,6 +923,7 @@ static const struct net_device_ops cpsw_netdev_ops = {
 	.ndo_stop		= cpsw_ndo_stop,
 	.ndo_start_xmit		= cpsw_ndo_start_xmit,
 	.ndo_change_rx_flags	= cpsw_ndo_change_rx_flags,
+	.ndo_do_ioctl		= cpsw_ndo_ioctl,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_tx_timeout		= cpsw_ndo_tx_timeout,
@@ -812,11 +955,44 @@ static void cpsw_set_msglevel(struct net_device *ndev, u32 value)
 	priv->msg_enable = value;
 }
 
+static int cpsw_get_ts_info(struct net_device *ndev,
+			    struct ethtool_ts_info *info)
+{
+#ifdef CONFIG_TI_CPTS
+	struct cpsw_priv *priv = netdev_priv(ndev);
+
+	info->so_timestamping =
+		SOF_TIMESTAMPING_TX_HARDWARE |
+		SOF_TIMESTAMPING_TX_SOFTWARE |
+		SOF_TIMESTAMPING_RX_HARDWARE |
+		SOF_TIMESTAMPING_RX_SOFTWARE |
+		SOF_TIMESTAMPING_SOFTWARE |
+		SOF_TIMESTAMPING_RAW_HARDWARE;
+	info->phc_index = priv->cpts.phc_index;
+	info->tx_types =
+		(1 << HWTSTAMP_TX_OFF) |
+		(1 << HWTSTAMP_TX_ON);
+	info->rx_filters =
+		(1 << HWTSTAMP_FILTER_NONE) |
+		(1 << HWTSTAMP_FILTER_PTP_V2_EVENT);
+#else
+	info->so_timestamping =
+		SOF_TIMESTAMPING_TX_SOFTWARE |
+		SOF_TIMESTAMPING_RX_SOFTWARE |
+		SOF_TIMESTAMPING_SOFTWARE;
+	info->phc_index = -1;
+	info->tx_types = 0;
+	info->rx_filters = 0;
+#endif
+	return 0;
+}
+
 static const struct ethtool_ops cpsw_ethtool_ops = {
 	.get_drvinfo	= cpsw_get_drvinfo,
 	.get_msglevel	= cpsw_get_msglevel,
 	.set_msglevel	= cpsw_set_msglevel,
 	.get_link	= ethtool_op_get_link,
+	.get_ts_info	= cpsw_get_ts_info,
 };
 
 static void cpsw_slave_init(struct cpsw_slave *slave, struct cpsw_priv *priv)
@@ -1092,6 +1268,7 @@ static int __devinit cpsw_probe(struct platform_device *pdev)
 	priv->regs = regs;
 	priv->host_port = data->host_port_num;
 	priv->host_port_regs = regs + data->host_port_reg_ofs;
+	priv->cpts.reg = regs + data->cpts_reg_ofs;
 
 	priv->cpsw_ss_res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
 	if (!priv->cpsw_ss_res) {
@@ -1213,6 +1390,10 @@ static int __devinit cpsw_probe(struct platform_device *pdev)
 		goto clean_irq_ret;
 	}
 
+	if (cpts_register(&pdev->dev, &priv->cpts,
+			  data->cpts_clock_mult, data->cpts_clock_shift))
+		dev_err(priv->dev, "error registering cpts device\n");
+
 	cpsw_notice(priv, probe, "initialized device (regs %x, irq %d)\n",
 		  priv->cpsw_res->start, ndev->irq);
 
@@ -1252,6 +1433,7 @@ static int __devexit cpsw_remove(struct platform_device *pdev)
 	pr_info("removing device");
 	platform_set_drvdata(pdev, NULL);
 
+	cpts_unregister(&priv->cpts);
 	free_irq(ndev->irq, priv);
 	cpsw_ale_destroy(priv->ale);
 	cpdma_chan_destroy(priv->txch);
-- 
1.7.2.5
