From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH v2 6/7] net: ethernet: ti: cpsw: add support for ringparam configuration
Date: Fri, 6 Jan 2017 14:07:34 -0600
Message-ID: <20170106200735.4210-7-grygorii.strashko@ti.com>
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

The CPDMA uses one pool of descriptors for both RX and TX which by default
split between all channels proportionally depending on total number of
CPDMA channels and number of TX and RX channels. As result, more
descriptors will be consumed by TX path if there are more TX channels and
there is no way now to dedicate more descriptors for RX path.

So, add the ability to re-split CPDMA pool of descriptors between RX and TX
path via ethtool '-G' command wich will allow to configure and fix number
of descriptors used by RX and TX path, which, then, will be split between
RX/TX channels proportionally depending on RX/TX channels number and
weight. ethtool '-G' command will accept only number of RX entries and rest
of descriptors will be arranged for TX automatically.

Command:
  ethtool -G <devname> rx <number of descriptors>

defaults and limitations:
- minimum number of rx descriptors is 10% of total number of descriptors in
  CPDMA pool
- maximum number of rx descriptors is 90% of total number of descriptors in
  CPDMA pool
- by default, descriptors will be split equally between RX/TX path
- any values passed in "tx" parameter will be ignored

Usage:

 # ethtool -g eth0
	Pre-set maximums:
	RX:             7372
	RX Mini:        0
	RX Jumbo:       0
	TX:             0
	Current hardware settings:
	RX:             4096
	RX Mini:        0
	RX Jumbo:       0
	TX:             4096

 # ethtool -G eth0 rx 7372
 # ethtool -g eth0
	Ring parameters for eth0:
	Pre-set maximums:
	RX:             7372
	RX Mini:        0
	RX Jumbo:       0
	TX:             0
	Current hardware settings:
	RX:             7372
	RX Mini:        0
	RX Jumbo:       0
	TX:             820

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c          | 86 +++++++++++++++++++++++++++++++++
 drivers/net/ethernet/ti/davinci_cpdma.c | 40 ++++++++++++---
 drivers/net/ethernet/ti/davinci_cpdma.h |  4 ++
 3 files changed, 122 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index d39875e..f339268 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2484,6 +2484,90 @@ static int cpsw_nway_reset(struct net_device *ndev)
 		return -EOPNOTSUPP;
 }
 
+static void cpsw_get_ringparam(struct net_device *ndev,
+			       struct ethtool_ringparam *ering)
+{
+	struct cpsw_priv *priv = netdev_priv(ndev);
+	struct cpsw_common *cpsw = priv->cpsw;
+
+	/* not supported */
+	ering->tx_max_pending = 0;
+	ering->tx_pending = cpdma_get_num_tx_descs(cpsw->dma);
+	/* Max 90% RX buffers */
+	ering->rx_max_pending = (descs_pool_size * 9) / 10;
+	ering->rx_pending = cpdma_get_num_rx_descs(cpsw->dma);
+}
+
+static int cpsw_set_ringparam(struct net_device *ndev,
+			      struct ethtool_ringparam *ering)
+{
+	struct cpsw_priv *priv = netdev_priv(ndev);
+	struct cpsw_common *cpsw = priv->cpsw;
+	struct cpsw_slave *slave;
+	int i, ret;
+
+	/* ignore ering->tx_pending - only rx_pending adjustment is supported */
+
+	if (ering->rx_mini_pending || ering->rx_jumbo_pending ||
+	    ering->rx_pending < (descs_pool_size / 10) ||
+	    ering->rx_pending > ((descs_pool_size * 9) / 10))
+		return -EINVAL;
+
+	if (ering->rx_pending == cpdma_get_num_rx_descs(cpsw->dma))
+		return 0;
+
+	/* Disable NAPI scheduling */
+	cpsw_intr_disable(cpsw);
+
+	/* Stop all transmit queues for every network device.
+	 * Disable re-using rx descriptors with dormant_on.
+	 */
+	for (i = cpsw->data.slaves, slave = cpsw->slaves; i; i--, slave++) {
+		if (!(slave->ndev && netif_running(slave->ndev)))
+			continue;
+
+		netif_tx_stop_all_queues(slave->ndev);
+		netif_dormant_on(slave->ndev);
+	}
+
+	/* Handle rest of tx packets and stop cpdma channels */
+	cpdma_ctlr_stop(cpsw->dma);
+
+	cpdma_set_num_rx_descs(cpsw->dma, ering->rx_pending);
+
+	for (i = cpsw->data.slaves, slave = cpsw->slaves; i; i--, slave++) {
+		if (!(slave->ndev && netif_running(slave->ndev)))
+			continue;
+
+		/* Enable rx packets handling */
+		netif_dormant_off(slave->ndev);
+	}
+
+	if (cpsw_common_res_usage_state(cpsw)) {
+		cpdma_chan_split_pool(cpsw->dma);
+
+		ret = cpsw_fill_rx_channels(priv);
+		if (ret)
+			goto err;
+
+		/* After this receive is started */
+		cpdma_ctlr_start(cpsw->dma);
+		cpsw_intr_enable(cpsw);
+	}
+
+	/* Resume transmit for every affected interface */
+	for (i = cpsw->data.slaves, slave = cpsw->slaves; i; i--, slave++) {
+		if (!(slave->ndev && netif_running(slave->ndev)))
+			continue;
+		netif_tx_start_all_queues(slave->ndev);
+	}
+	return 0;
+err:
+	dev_err(priv->dev, "cannot set ring params, closing device\n");
+	dev_close(ndev);
+	return ret;
+}
+
 static const struct ethtool_ops cpsw_ethtool_ops = {
 	.get_drvinfo	= cpsw_get_drvinfo,
 	.get_msglevel	= cpsw_get_msglevel,
@@ -2510,6 +2594,8 @@ static const struct ethtool_ops cpsw_ethtool_ops = {
 	.get_eee	= cpsw_get_eee,
 	.set_eee	= cpsw_set_eee,
 	.nway_reset	= cpsw_nway_reset,
+	.get_ringparam = cpsw_get_ringparam,
+	.set_ringparam = cpsw_set_ringparam,
 };
 
 static void cpsw_slave_init(struct cpsw_slave *slave, struct cpsw_common *cpsw,
diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index 65e2f12..d80bff1 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -108,6 +108,8 @@ struct cpdma_ctlr {
 	spinlock_t		lock;
 	struct cpdma_chan	*channels[2 * CPDMA_MAX_CHANNELS];
 	int chan_num;
+	int			num_rx_desc; /* RX descriptors number */
+	int			num_tx_desc; /* TX descriptors number */
 };
 
 struct cpdma_chan {
@@ -518,6 +520,9 @@ struct cpdma_ctlr *cpdma_ctlr_create(struct cpdma_params *params)
 
 	if (cpdma_desc_pool_create(ctlr))
 		return NULL;
+	/* split pool equally between RX/TX by default */
+	ctlr->num_tx_desc = ctlr->pool->num_desc / 2;
+	ctlr->num_rx_desc = ctlr->pool->num_desc - ctlr->num_tx_desc;
 
 	if (WARN_ON(ctlr->num_chan > CPDMA_MAX_CHANNELS))
 		ctlr->num_chan = CPDMA_MAX_CHANNELS;
@@ -717,22 +722,22 @@ static void cpdma_chan_set_descs(struct cpdma_ctlr *ctlr,
 		}
 	}
 	/* use remains */
-	most_chan->desc_num += desc_cnt;
+	if (most_chan)
+		most_chan->desc_num += desc_cnt;
 }
 
 /**
  * cpdma_chan_split_pool - Splits ctrl pool between all channels.
  * Has to be called under ctlr lock
  */
-static int cpdma_chan_split_pool(struct cpdma_ctlr *ctlr)
+int cpdma_chan_split_pool(struct cpdma_ctlr *ctlr)
 {
 	int tx_per_ch_desc = 0, rx_per_ch_desc = 0;
-	struct cpdma_desc_pool *pool = ctlr->pool;
 	int free_rx_num = 0, free_tx_num = 0;
 	int rx_weight = 0, tx_weight = 0;
 	int tx_desc_num, rx_desc_num;
 	struct cpdma_chan *chan;
-	int i, tx_num = 0;
+	int i;
 
 	if (!ctlr->chan_num)
 		return 0;
@@ -750,15 +755,14 @@ static int cpdma_chan_split_pool(struct cpdma_ctlr *ctlr)
 			if (!chan->weight)
 				free_tx_num++;
 			tx_weight += chan->weight;
-			tx_num++;
 		}
 	}
 
 	if (rx_weight > 100 || tx_weight > 100)
 		return -EINVAL;
 
-	tx_desc_num = (tx_num * pool->num_desc) / ctlr->chan_num;
-	rx_desc_num = pool->num_desc - tx_desc_num;
+	tx_desc_num = ctlr->num_tx_desc;
+	rx_desc_num = ctlr->num_rx_desc;
 
 	if (free_tx_num) {
 		tx_per_ch_desc = tx_desc_num - (tx_weight * tx_desc_num) / 100;
@@ -774,6 +778,8 @@ static int cpdma_chan_split_pool(struct cpdma_ctlr *ctlr)
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(cpdma_chan_split_pool);
+
 
 /* cpdma_chan_set_weight - set weight of a channel in percentage.
  * Tx and Rx channels have separate weights. That is 100% for RX
@@ -907,7 +913,6 @@ struct cpdma_chan *cpdma_chan_create(struct cpdma_ctlr *ctlr, int chan_num,
 	chan->chan_num	= chan_num;
 	chan->handler	= handler;
 	chan->rate	= 0;
-	chan->desc_num = ctlr->pool->num_desc / 2;
 	chan->weight	= 0;
 
 	if (is_rx_chan(chan)) {
@@ -1329,4 +1334,23 @@ int cpdma_control_set(struct cpdma_ctlr *ctlr, int control, int value)
 }
 EXPORT_SYMBOL_GPL(cpdma_control_set);
 
+int cpdma_get_num_rx_descs(struct cpdma_ctlr *ctlr)
+{
+	return ctlr->num_rx_desc;
+}
+EXPORT_SYMBOL_GPL(cpdma_get_num_rx_descs);
+
+int cpdma_get_num_tx_descs(struct cpdma_ctlr *ctlr)
+{
+	return ctlr->num_tx_desc;
+}
+EXPORT_SYMBOL_GPL(cpdma_get_num_tx_descs);
+
+void cpdma_set_num_rx_descs(struct cpdma_ctlr *ctlr, int num_rx_desc)
+{
+	ctlr->num_rx_desc = num_rx_desc;
+	ctlr->num_tx_desc = ctlr->pool->num_desc - ctlr->num_rx_desc;
+}
+EXPORT_SYMBOL_GPL(cpdma_set_num_rx_descs);
+
 MODULE_LICENSE("GPL");
diff --git a/drivers/net/ethernet/ti/davinci_cpdma.h b/drivers/net/ethernet/ti/davinci_cpdma.h
index cb45f8f..fd65ce2 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.h
+++ b/drivers/net/ethernet/ti/davinci_cpdma.h
@@ -114,5 +114,9 @@ enum cpdma_control {
 
 int cpdma_control_get(struct cpdma_ctlr *ctlr, int control);
 int cpdma_control_set(struct cpdma_ctlr *ctlr, int control, int value);
+int cpdma_get_num_rx_descs(struct cpdma_ctlr *ctlr);
+void cpdma_set_num_rx_descs(struct cpdma_ctlr *ctlr, int num_rx_desc);
+int cpdma_get_num_tx_descs(struct cpdma_ctlr *ctlr);
+int cpdma_chan_split_pool(struct cpdma_ctlr *ctlr);
 
 #endif
-- 
2.10.1.dirty
