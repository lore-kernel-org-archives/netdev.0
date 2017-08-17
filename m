From: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Subject: [PATCH V7 net-next 21/22] net-next/hinic: Add netpoll
Date: Fri, 18 Aug 2017 03:04:55 +0800
Message-ID: <30baa46b02a2dfb015e8225a6aa0f64369bd4304.1502996307.git.aviad.krawczyk@huawei.com>
References: <cover.1502996306.git.aviad.krawczyk@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
        <bc.y@huawei.com>, <victor.gissin@huawei.com>,
        <aviad.krawczyk@huawei.com>, <zhaochen6@huawei.com>,
        <tony.qu@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1502996306.git.aviad.krawczyk@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add more netdev operation - netpoll.

Signed-off-by: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Signed-off-by: Zhao Chen <zhaochen6@huawei.com>
---
 drivers/net/ethernet/huawei/hinic/hinic_main.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/drivers/net/ethernet/huawei/hinic/hinic_main.c b/drivers/net/ethernet/huawei/hinic/hinic_main.c
index a77a7f8..59f3358 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_main.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_main.c
@@ -787,6 +787,23 @@ static void hinic_get_stats64(struct net_device *netdev,
 	stats->tx_errors  = nic_tx_stats->tx_dropped;
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void hinic_netpoll(struct net_device *netdev)
+{
+	struct hinic_dev *nic_dev = netdev_priv(netdev);
+	int i, num_qps;
+
+	num_qps = hinic_hwdev_num_qps(nic_dev->hwdev);
+	for (i = 0; i < num_qps; i++) {
+		struct hinic_txq *txq = &nic_dev->txqs[i];
+		struct hinic_rxq *rxq = &nic_dev->rxqs[i];
+
+		napi_schedule(&txq->napi);
+		napi_schedule(&rxq->napi);
+	}
+}
+#endif
+
 static const struct net_device_ops hinic_netdev_ops = {
 	.ndo_open = hinic_open,
 	.ndo_stop = hinic_close,
@@ -799,6 +816,9 @@ static void hinic_get_stats64(struct net_device *netdev,
 	.ndo_start_xmit = hinic_xmit_frame,
 	.ndo_tx_timeout = hinic_tx_timeout,
 	.ndo_get_stats64 = hinic_get_stats64,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller = hinic_netpoll,
+#endif
 };
 
 static void netdev_features_init(struct net_device *netdev)
-- 
1.9.1
