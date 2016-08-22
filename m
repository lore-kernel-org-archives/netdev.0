From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH v4 5/5] net: ethernet: ti: cpsw: add ethtool channels support
Date: Mon, 22 Aug 2016 21:18:28 +0300
Message-ID: <1471889908-29983-6-git-send-email-ivan.khoronzhuk@linaro.org>
References: <1471889908-29983-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-kernel@vger.kernel.org, linux-omap@vger.kernel.org,
        nsekhar@ti.com, dlide@ti.com,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: davem@davemloft.net, netdev@vger.kernel.org, mugunthanvnm@ti.com,
        grygorii.strashko@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471889908-29983-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These ops allow to control number of channels driver is allowed to
work with at cpdma level. The maximum number of channels is 8 for
rx and 8 for tx. In dual_emac mode the h/w channels are shared
between two interfaces and changing number on one interface changes
number of channels on another.

How many channels are supported and enabled:
$ ethtool -l ethX

Change number of channels (up to 8)
$ ethtool -L ethX rx 6 tx 6

Per-channel statistic:
$ ethtool -S ethX

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
 drivers/net/ethernet/ti/cpsw.c | 180 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 180 insertions(+)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 1fbb50f..4273e7f 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -736,6 +736,11 @@ static void cpsw_rx_handler(void *token, int len, int status)
 	}
 
 requeue:
+	if (netif_dormant(ndev)) {
+		dev_kfree_skb_any(new_skb);
+		return;
+	}
+
 	ch = cpsw->rxch[skb_get_queue_mapping(new_skb)];
 	ret = cpdma_chan_submit(ch, new_skb, new_skb->data,
 				skb_tailroom(new_skb), 0);
@@ -2060,6 +2065,179 @@ static void cpsw_ethtool_op_complete(struct net_device *ndev)
 		cpsw_err(priv, drv, "ethtool complete failed %d\n", ret);
 }
 
+static void cpsw_get_channels(struct net_device *ndev,
+			      struct ethtool_channels *ch)
+{
+	struct cpsw_common *cpsw = ndev_to_cpsw(ndev);
+
+	ch->max_combined = 0;
+	ch->max_rx = CPSW_MAX_QUEUES;
+	ch->max_tx = CPSW_MAX_QUEUES;
+	ch->max_other = 0;
+	ch->other_count = 0;
+	ch->rx_count = cpsw->rx_ch_num;
+	ch->tx_count = cpsw->tx_ch_num;
+	ch->combined_count = 0;
+}
+
+static int cpsw_check_ch_settings(struct cpsw_common *cpsw,
+				  struct ethtool_channels *ch)
+{
+	if (ch->combined_count)
+		return -EINVAL;
+
+	/* verify we have at least one channel in each direction */
+	if (!ch->rx_count || !ch->tx_count)
+		return -EINVAL;
+
+	if (ch->rx_count > cpsw->data.channels ||
+	    ch->tx_count > cpsw->data.channels)
+		return -EINVAL;
+
+	return 0;
+}
+
+static int cpsw_update_channels_res(struct cpsw_priv *priv, int ch_num, int rx)
+{
+	int (*poll)(struct napi_struct *, int);
+	struct cpsw_common *cpsw = priv->cpsw;
+	void (*handler)(void *, int, int);
+	struct cpdma_chan **chan;
+	int ret, *ch;
+
+	if (rx) {
+		ch = &cpsw->rx_ch_num;
+		chan = cpsw->rxch;
+		handler = cpsw_rx_handler;
+		poll = cpsw_rx_poll;
+	} else {
+		ch = &cpsw->tx_ch_num;
+		chan = cpsw->txch;
+		handler = cpsw_tx_handler;
+		poll = cpsw_tx_poll;
+	}
+
+	while (*ch < ch_num) {
+		chan[*ch] = cpdma_chan_create(cpsw->dma, *ch, handler, rx);
+
+		if (IS_ERR(chan[*ch]))
+			return PTR_ERR(chan[*ch]);
+
+		if (!chan[*ch])
+			return -EINVAL;
+
+		cpsw_info(priv, ifup, "created new %d %s channel\n", *ch,
+			  (rx ? "rx" : "tx"));
+		(*ch)++;
+	}
+
+	while (*ch > ch_num) {
+		(*ch)--;
+
+		ret = cpdma_chan_destroy(chan[*ch]);
+		if (ret)
+			return ret;
+
+		cpsw_info(priv, ifup, "destroyed %d %s channel\n", *ch,
+			  (rx ? "rx" : "tx"));
+	}
+
+	return 0;
+}
+
+static int cpsw_update_channels(struct cpsw_priv *priv,
+				struct ethtool_channels *ch)
+{
+	int ret;
+
+	ret = cpsw_update_channels_res(priv, ch->rx_count, 1);
+	if (ret)
+		return ret;
+
+	ret = cpsw_update_channels_res(priv, ch->tx_count, 0);
+	if (ret)
+		return ret;
+
+	return 0;
+}
+
+static int cpsw_set_channels(struct net_device *ndev,
+			     struct ethtool_channels *chs)
+{
+	struct cpsw_priv *priv = netdev_priv(ndev);
+	struct cpsw_common *cpsw = priv->cpsw;
+	struct cpsw_slave *slave;
+	int i, ret;
+
+	ret = cpsw_check_ch_settings(cpsw, chs);
+	if (ret < 0)
+		return ret;
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
+	ret = cpsw_update_channels(priv, chs);
+	if (ret)
+		goto err;
+
+	for (i = cpsw->data.slaves, slave = cpsw->slaves; i; i--, slave++) {
+		if (!(slave->ndev && netif_running(slave->ndev)))
+			continue;
+
+		/* Inform stack about new count of queues */
+		ret = netif_set_real_num_tx_queues(slave->ndev,
+						   cpsw->tx_ch_num);
+		if (ret) {
+			dev_err(priv->dev, "cannot set real number of tx queues\n");
+			goto err;
+		}
+
+		ret = netif_set_real_num_rx_queues(slave->ndev,
+						   cpsw->rx_ch_num);
+		if (ret) {
+			dev_err(priv->dev, "cannot set real number of rx queues\n");
+			goto err;
+		}
+
+		/* Enable rx packets handling */
+		netif_dormant_off(slave->ndev);
+	}
+
+	if (cpsw_common_res_usage_state(cpsw)) {
+		if (cpsw_fill_rx_channels(priv))
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
+	dev_err(priv->dev, "cannot update channels number, closing device\n");
+	dev_close(ndev);
+	return ret;
+}
+
 static const struct ethtool_ops cpsw_ethtool_ops = {
 	.get_drvinfo	= cpsw_get_drvinfo,
 	.get_msglevel	= cpsw_get_msglevel,
@@ -2081,6 +2259,8 @@ static const struct ethtool_ops cpsw_ethtool_ops = {
 	.get_regs	= cpsw_get_regs,
 	.begin		= cpsw_ethtool_op_begin,
 	.complete	= cpsw_ethtool_op_complete,
+	.get_channels	= cpsw_get_channels,
+	.set_channels	= cpsw_set_channels,
 };
 
 static void cpsw_slave_init(struct cpsw_slave *slave, struct cpsw_common *cpsw,
-- 
1.9.1
