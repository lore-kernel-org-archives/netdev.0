From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH 3/5] net: ethernet: ti: cpsw: add .ndo to set per-queue rate
Date: Tue, 29 Nov 2016 17:00:49 +0200
Message-ID: <1480431651-6081-4-git-send-email-ivan.khoronzhuk@linaro.org>
References: <1480431651-6081-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-omap@vger.kernel.org,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        mugunthanvnm@ti.com, grygorii.strashko@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:35442 "EHLO
        mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933781AbcK2PBY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 10:01:24 -0500
Received: by mail-lf0-f50.google.com with SMTP id b14so123629818lfg.2
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 07:01:23 -0800 (PST)
In-Reply-To: <1480431651-6081-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows to rate limit queues tx queues for cpsw interface.
The rate is set in absolute Mb/s units and cannot be more a speed
an interface is connected with.

The rate for a tx queue can be tested with:

ethtool -L eth0 rx 4 tx 4

echo 100 > /sys/class/net/eth0/queues/tx-0/tx_maxrate
echo 200 > /sys/class/net/eth0/queues/tx-1/tx_maxrate
echo 50 > /sys/class/net/eth0/queues/tx-2/tx_maxrate
echo 30 > /sys/class/net/eth0/queues/tx-3/tx_maxrate

tc qdisc add dev eth0 root handle 1: multiq

tc filter add dev eth0 parent 1: protocol ip prio 1 u32 match ip\
dport 5001 0xffff action skbedit queue_mapping 0

tc filter add dev eth0 parent 1: protocol ip prio 1 u32 match ip\
dport 5002 0xffff action skbedit queue_mapping 1

tc filter add dev eth0 parent 1: protocol ip prio 1 u32 match ip\
dport 5003 0xffff action skbedit queue_mapping 2

tc filter add dev eth0 parent 1: protocol ip prio 1 u32 match ip\
dport 5004 0xffff action skbedit queue_mapping 3

iperf -c 192.168.2.1 -b 110M -p 5001 -f m -t 60
iperf -c 192.168.2.1 -b 215M -p 5002 -f m -t 60
iperf -c 192.168.2.1 -b 55M -p 5003 -f m -t 60
iperf -c 192.168.2.1 -b 32M -p 5004 -f m -t 60

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
 drivers/net/ethernet/ti/cpsw.c | 87 ++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 87 insertions(+)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index da40ea5..c102675 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1872,6 +1872,88 @@ static int cpsw_ndo_vlan_rx_kill_vid(struct net_device *ndev,
 	return ret;
 }
 
+static int cpsw_ndo_set_tx_maxrate(struct net_device *ndev, int queue, u32 rate)
+{
+	struct cpsw_priv *priv = netdev_priv(ndev);
+	int tx_ch_num = ndev->real_num_tx_queues;
+	u32 consumed_rate, min_rate, max_rate;
+	struct cpsw_common *cpsw = priv->cpsw;
+	struct cpsw_slave *slave;
+	int ret, i, weight;
+	int rlim_num = 0;
+	u32 ch_rate;
+
+	ch_rate = netdev_get_tx_queue(ndev, queue)->tx_maxrate;
+	if (ch_rate == rate)
+		return 0;
+
+	if (cpsw->data.dual_emac)
+		slave = &cpsw->slaves[priv->emac_port];
+	else
+		slave = &cpsw->slaves[cpsw->data.active_slave];
+	max_rate = slave->phy->speed;
+
+	consumed_rate = 0;
+	for (i = 0; i < tx_ch_num; i++) {
+		if (i == queue)
+			ch_rate = rate;
+		else
+			ch_rate = netdev_get_tx_queue(ndev, i)->tx_maxrate;
+
+		if (!ch_rate)
+			continue;
+
+		rlim_num++;
+		consumed_rate += ch_rate;
+	}
+
+	if (consumed_rate > max_rate)
+		dev_info(priv->dev, "The common rate shouldn't be more than %dMbps",
+			 max_rate);
+
+	if (consumed_rate > max_rate) {
+		if (max_rate == 10 && consumed_rate <= 100) {
+			max_rate = 100;
+		} else if (max_rate <= 100 && consumed_rate <= 1000) {
+			max_rate = 1000;
+		} else {
+			dev_err(priv->dev, "The common rate cannot be more than %dMbps",
+				max_rate);
+			return -EINVAL;
+		}
+	}
+
+	if (consumed_rate > max_rate) {
+		dev_err(priv->dev, "The common rate cannot be more than %dMbps",
+			max_rate);
+		return -EINVAL;
+	}
+
+	rate *= 1000;
+	min_rate = cpdma_chan_get_min_rate(cpsw->dma);
+	if ((rate < min_rate && rate)) {
+		dev_err(priv->dev, "The common rate cannot be less than %dMbps",
+			min_rate);
+		return -EINVAL;
+	}
+
+	ret = pm_runtime_get_sync(cpsw->dev);
+	if (ret < 0) {
+		pm_runtime_put_noidle(cpsw->dev);
+		return ret;
+	}
+
+	if (rlim_num == tx_ch_num)
+		max_rate = consumed_rate;
+
+	weight = (rate * 100) / (max_rate * 1000);
+	cpdma_chan_set_weight(cpsw->txch[queue], weight);
+
+	ret = cpdma_chan_set_rate(cpsw->txch[queue], rate);
+	pm_runtime_put(cpsw->dev);
+	return ret;
+}
+
 static const struct net_device_ops cpsw_netdev_ops = {
 	.ndo_open		= cpsw_ndo_open,
 	.ndo_stop		= cpsw_ndo_stop,
@@ -1881,6 +1963,7 @@ static const struct net_device_ops cpsw_netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_tx_timeout		= cpsw_ndo_tx_timeout,
 	.ndo_set_rx_mode	= cpsw_ndo_set_rx_mode,
+	.ndo_set_tx_maxrate	= cpsw_ndo_set_tx_maxrate,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= cpsw_ndo_poll_controller,
 #endif
@@ -2100,6 +2183,7 @@ static int cpsw_update_channels_res(struct cpsw_priv *priv, int ch_num, int rx)
 	int (*poll)(struct napi_struct *, int);
 	struct cpsw_common *cpsw = priv->cpsw;
 	void (*handler)(void *, int, int);
+	struct netdev_queue *queue;
 	struct cpdma_chan **chan;
 	int ret, *ch;
 
@@ -2117,6 +2201,8 @@ static int cpsw_update_channels_res(struct cpsw_priv *priv, int ch_num, int rx)
 
 	while (*ch < ch_num) {
 		chan[*ch] = cpdma_chan_create(cpsw->dma, *ch, handler, rx);
+		queue = netdev_get_tx_queue(priv->ndev, *ch);
+		queue->tx_maxrate = 0;
 
 		if (IS_ERR(chan[*ch]))
 			return PTR_ERR(chan[*ch]);
@@ -2752,6 +2838,7 @@ static int cpsw_probe(struct platform_device *pdev)
 	dma_params.desc_align		= 16;
 	dma_params.has_ext_regs		= true;
 	dma_params.desc_hw_addr         = dma_params.desc_mem_phys;
+	dma_params.bus_freq_mhz		= cpsw->bus_freq_mhz;
 
 	cpsw->dma = cpdma_ctlr_create(&dma_params);
 	if (!cpsw->dma) {
-- 
2.7.4
