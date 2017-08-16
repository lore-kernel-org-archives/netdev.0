From: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Subject: [PATCH V4 net-next 21/21] net-next/hinic: Add select_queue and netpoll
Date: Wed, 16 Aug 2017 20:03:06 +0800
Message-ID: <d5f45e39dc7d5ccb0bcb6bd5e2ebea7d6ffaba83.1502883967.git.aviad.krawczyk@huawei.com>
References: <cover.1502883967.git.aviad.krawczyk@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
        <bc.y@huawei.com>, <victor.gissin@huawei.com>,
        <aviad.krawczyk@huawei.com>, <zhaochen6@huawei.com>,
        <tony.qu@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1502883967.git.aviad.krawczyk@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add more netdev operations.

Signed-off-by: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Signed-off-by: Zhao Chen <zhaochen6@huawei.com>
---
 MAINTAINERS                                    |  7 ++++++
 drivers/net/ethernet/huawei/hinic/hinic_main.c | 35 ++++++++++++++++++++++++++
 2 files changed, 42 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 2db0f8c..9ee5902 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -6240,6 +6240,13 @@ L:	linux-input@vger.kernel.org
 S:	Maintained
 F:	drivers/input/touchscreen/htcpen.c
 
+HUAWEI ETHERNET DRIVER
+M:	Aviad Krawczyk <aviad.krawczyk@huawei.com>
+L:	netdev@vger.kernel.org
+S:	Supported
+F:	Documentation/networking/hinic.txt
+F:	drivers/net/ethernet/huawei/hinic/
+
 HUGETLB FILESYSTEM
 M:	Nadia Yvette Chambers <nyc@holomorphy.com>
 S:	Maintained
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_main.c b/drivers/net/ethernet/huawei/hinic/hinic_main.c
index a77a7f8..5306ec1 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_main.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_main.c
@@ -787,6 +787,37 @@ static void hinic_get_stats64(struct net_device *netdev,
 	stats->tx_errors  = nic_tx_stats->tx_dropped;
 }
 
+static u16 hinic_select_queue(struct net_device *netdev, struct sk_buff *skb,
+			      void *accel_priv,
+			      select_queue_fallback_t fallback)
+{
+	u16 qid;
+
+	if (skb_rx_queue_recorded(skb))
+		qid = skb_get_rx_queue(skb);
+	else
+		qid = fallback(netdev, skb);
+
+	return qid;
+}
+
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
@@ -799,6 +830,10 @@ static void hinic_get_stats64(struct net_device *netdev,
 	.ndo_start_xmit = hinic_xmit_frame,
 	.ndo_tx_timeout = hinic_tx_timeout,
 	.ndo_get_stats64 = hinic_get_stats64,
+	.ndo_select_queue = hinic_select_queue,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller = hinic_netpoll,
+#endif
 };
 
 static void netdev_features_init(struct net_device *netdev)
-- 
1.9.1
