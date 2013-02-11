From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH 2/3] driver: net: ethernet: cpsw: make cpts as pointer
Date: Tue, 12 Feb 2013 01:22:19 +0530
Message-ID: <1360612340-9266-3-git-send-email-mugunthanvnm@ti.com>
References: <1360612340-9266-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1360612340-9266-1-git-send-email-mugunthanvnm@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As CPTS is common module for both EMAC in Dual EMAC mode so making cpts as
pointer.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c |   36 +++++++++++++++++++++---------------
 1 file changed, 21 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 8ac60c7..4b964bb 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -319,7 +319,7 @@ struct cpsw_priv {
 	/* snapshot of IRQ numbers */
 	u32 irqs_table[4];
 	u32 num_irqs;
-	struct cpts cpts;
+	struct cpts *cpts;
 };
 
 #define napi_to_priv(napi)	container_of(napi, struct cpsw_priv, napi)
@@ -383,7 +383,7 @@ void cpsw_tx_handler(void *token, int len, int status)
 	 */
 	if (unlikely(netif_queue_stopped(ndev)))
 		netif_start_queue(ndev);
-	cpts_tx_timestamp(&priv->cpts, skb);
+	cpts_tx_timestamp(priv->cpts, skb);
 	priv->stats.tx_packets++;
 	priv->stats.tx_bytes += len;
 	dev_kfree_skb_any(skb);
@@ -404,7 +404,7 @@ void cpsw_rx_handler(void *token, int len, int status)
 	}
 	if (likely(status >= 0)) {
 		skb_put(skb, len);
-		cpts_rx_timestamp(&priv->cpts, skb);
+		cpts_rx_timestamp(priv->cpts, skb);
 		skb->protocol = eth_type_trans(skb, ndev);
 		netif_receive_skb(skb);
 		priv->stats.rx_bytes += len;
@@ -760,7 +760,8 @@ static netdev_tx_t cpsw_ndo_start_xmit(struct sk_buff *skb,
 		return NETDEV_TX_OK;
 	}
 
-	if (skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP && priv->cpts.tx_enable)
+	if (skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP &&
+				priv->cpts->tx_enable)
 		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
 
 	skb_tx_timestamp(skb);
@@ -815,7 +816,7 @@ static void cpsw_hwtstamp_v1(struct cpsw_priv *priv)
 	struct cpsw_slave *slave = &priv->slaves[priv->data.cpts_active_slave];
 	u32 ts_en, seq_id;
 
-	if (!priv->cpts.tx_enable && !priv->cpts.rx_enable) {
+	if (!priv->cpts->tx_enable && !priv->cpts->rx_enable) {
 		slave_write(slave, 0, CPSW1_TS_CTL);
 		return;
 	}
@@ -823,10 +824,10 @@ static void cpsw_hwtstamp_v1(struct cpsw_priv *priv)
 	seq_id = (30 << CPSW_V1_SEQ_ID_OFS_SHIFT) | ETH_P_1588;
 	ts_en = EVENT_MSG_BITS << CPSW_V1_MSG_TYPE_OFS;
 
-	if (priv->cpts.tx_enable)
+	if (priv->cpts->tx_enable)
 		ts_en |= CPSW_V1_TS_TX_EN;
 
-	if (priv->cpts.rx_enable)
+	if (priv->cpts->rx_enable)
 		ts_en |= CPSW_V1_TS_RX_EN;
 
 	slave_write(slave, ts_en, CPSW1_TS_CTL);
@@ -841,10 +842,10 @@ static void cpsw_hwtstamp_v2(struct cpsw_priv *priv)
 	ctrl = slave_read(slave, CPSW2_CONTROL);
 	ctrl &= ~CTRL_ALL_TS_MASK;
 
-	if (priv->cpts.tx_enable)
+	if (priv->cpts->tx_enable)
 		ctrl |= CTRL_TX_TS_BITS;
 
-	if (priv->cpts.rx_enable)
+	if (priv->cpts->rx_enable)
 		ctrl |= CTRL_RX_TS_BITS;
 
 	mtype = (30 << TS_SEQ_ID_OFFSET_SHIFT) | EVENT_MSG_BITS;
@@ -857,7 +858,7 @@ static void cpsw_hwtstamp_v2(struct cpsw_priv *priv)
 static int cpsw_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
 {
 	struct cpsw_priv *priv = netdev_priv(dev);
-	struct cpts *cpts = &priv->cpts;
+	struct cpts *cpts = priv->cpts;
 	struct hwtstamp_config cfg;
 
 	if (copy_from_user(&cfg, ifr->ifr_data, sizeof(cfg)))
@@ -1086,7 +1087,7 @@ static int cpsw_get_ts_info(struct net_device *ndev,
 		SOF_TIMESTAMPING_RX_SOFTWARE |
 		SOF_TIMESTAMPING_SOFTWARE |
 		SOF_TIMESTAMPING_RAW_HARDWARE;
-	info->phc_index = priv->cpts.phc_index;
+	info->phc_index = priv->cpts->phc_index;
 	info->tx_types =
 		(1 << HWTSTAMP_TX_OFF) |
 		(1 << HWTSTAMP_TX_ON);
@@ -1272,6 +1273,11 @@ static int cpsw_probe(struct platform_device *pdev)
 	priv->dev  = &ndev->dev;
 	priv->msg_enable = netif_msg_init(debug_level, CPSW_DEBUG);
 	priv->rx_packet_max = max(rx_packet_max, 128);
+	priv->cpts = devm_kzalloc(&pdev->dev, sizeof(struct cpts), GFP_KERNEL);
+	if (!ndev) {
+		pr_err("error allocating cpts\n");
+		goto clean_ndev_ret;
+	}
 
 	/*
 	 * This may be required here for child devices.
@@ -1358,7 +1364,7 @@ static int cpsw_probe(struct platform_device *pdev)
 	switch (priv->version) {
 	case CPSW_VERSION_1:
 		priv->host_port_regs = ss_regs + CPSW1_HOST_PORT_OFFSET;
-		priv->cpts.reg       = ss_regs + CPSW1_CPTS_OFFSET;
+		priv->cpts->reg       = ss_regs + CPSW1_CPTS_OFFSET;
 		dma_params.dmaregs   = ss_regs + CPSW1_CPDMA_OFFSET;
 		dma_params.txhdp     = ss_regs + CPSW1_STATERAM_OFFSET;
 		ale_params.ale_regs  = ss_regs + CPSW1_ALE_OFFSET;
@@ -1369,7 +1375,7 @@ static int cpsw_probe(struct platform_device *pdev)
 		break;
 	case CPSW_VERSION_2:
 		priv->host_port_regs = ss_regs + CPSW2_HOST_PORT_OFFSET;
-		priv->cpts.reg       = ss_regs + CPSW2_CPTS_OFFSET;
+		priv->cpts->reg       = ss_regs + CPSW2_CPTS_OFFSET;
 		dma_params.dmaregs   = ss_regs + CPSW2_CPDMA_OFFSET;
 		dma_params.txhdp     = ss_regs + CPSW2_STATERAM_OFFSET;
 		ale_params.ale_regs  = ss_regs + CPSW2_ALE_OFFSET;
@@ -1471,7 +1477,7 @@ static int cpsw_probe(struct platform_device *pdev)
 		goto clean_irq_ret;
 	}
 
-	if (cpts_register(&pdev->dev, &priv->cpts,
+	if (cpts_register(&pdev->dev, priv->cpts,
 			  data->cpts_clock_mult, data->cpts_clock_shift))
 		dev_err(priv->dev, "error registering cpts device\n");
 
@@ -1516,7 +1522,7 @@ static int cpsw_remove(struct platform_device *pdev)
 	pr_info("removing device");
 	platform_set_drvdata(pdev, NULL);
 
-	cpts_unregister(&priv->cpts);
+	cpts_unregister(priv->cpts);
 	free_irq(ndev->irq, priv);
 	cpsw_ale_destroy(priv->ale);
 	cpdma_chan_destroy(priv->txch);
-- 
1.7.9.5

