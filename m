From: Lipeng <lipeng321@huawei.com>
Subject: [PATCH net-next 6/9] net: hns3: Add timeout process in hns3_enet
Date: Wed, 1 Nov 2017 22:47:19 +0800
Message-ID: <1509547642-51110-7-git-send-email-lipeng321@huawei.com>
References: <1509547642-51110-1-git-send-email-lipeng321@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linuxarm@huawei.com>, <yisen.zhuang@huawei.com>,
        <salil.mehta@huawei.com>, <lipeng321@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1509547642-51110-1-git-send-email-lipeng321@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch add timeout handler in hns3_enet.c to handle
TX side timeout event, when TX timeout event occur, it will triger
NIC driver into reset process.

Signed-off-by: qumingguang <qumingguang@huawei.com>
Signed-off-by: Lipeng <lipeng321@huawei.com>
---
 .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c | 86 ++++++++++++++++++++++
 .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h |  2 +
 2 files changed, 88 insertions(+)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
index c6c5b2a..aed6611 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
@@ -258,6 +258,7 @@ static int hns3_nic_net_up(struct net_device *netdev)
 
 static int hns3_nic_net_open(struct net_device *netdev)
 {
+	struct hns3_nic_priv *priv = netdev_priv(netdev);
 	int ret;
 
 	netif_carrier_off(netdev);
@@ -273,6 +274,7 @@ static int hns3_nic_net_open(struct net_device *netdev)
 		return ret;
 	}
 
+	priv->last_reset_time = jiffies;
 	return 0;
 }
 
@@ -1322,10 +1324,91 @@ static int hns3_nic_change_mtu(struct net_device *netdev, int new_mtu)
 	return ret;
 }
 
+static bool hns3_get_tx_timeo_queue_info(struct net_device *ndev)
+{
+	struct hns3_nic_priv *priv = netdev_priv(ndev);
+	struct hns3_enet_ring *tx_ring = NULL;
+	int timeout_queue = 0;
+	int hw_head, hw_tail;
+	int i;
+
+	/* Find the stopped queue the same way the stack does */
+	for (i = 0; i < ndev->real_num_tx_queues; i++) {
+		struct netdev_queue *q;
+		unsigned long trans_start;
+
+		q = netdev_get_tx_queue(ndev, i);
+		trans_start = q->trans_start;
+		if (netif_xmit_stopped(q) &&
+		    time_after(jiffies,
+			       (trans_start + ndev->watchdog_timeo))) {
+			timeout_queue = i;
+			break;
+		}
+	}
+
+	if (i == ndev->num_tx_queues) {
+		netdev_info(ndev,
+			    "no netdev TX timeout queue found, timeout count: %llu\n",
+			    priv->tx_timeout_count);
+		return false;
+	}
+
+	tx_ring = priv->ring_data[timeout_queue].ring;
+
+	hw_head = readl_relaxed(tx_ring->tqp->io_base +
+				HNS3_RING_RX_RING_HEAD_REG);
+	hw_tail = readl_relaxed(tx_ring->tqp->io_base +
+				HNS3_RING_RX_RING_TAIL_REG);
+	netdev_info(ndev,
+		    "tx_timeout count: %llu, queue id: %d, SW_NTU: 0x%x, SW_NTC: 0x%x, HW_HEAD: 0x%x, HW_TAIL: 0x%x, INT: 0x%x\n",
+		    priv->tx_timeout_count,
+		    timeout_queue,
+		    tx_ring->next_to_use,
+		    tx_ring->next_to_clean,
+		    hw_head,
+		    hw_tail,
+		    readl(tx_ring->tqp_vector->mask_addr));
+
+	return true;
+}
+
+static void hns3_nic_net_timeout(struct net_device *ndev)
+{
+	struct hns3_nic_priv *priv = netdev_priv(ndev);
+	unsigned long last_reset_time = priv->last_reset_time;
+	struct hnae3_handle *h = priv->ae_handle;
+
+	if (!hns3_get_tx_timeo_queue_info(ndev))
+		return;
+
+	priv->tx_timeout_count++;
+
+	/* This timeout is far away enough from last timeout,
+	 * if timeout again,set the reset type to PF reset
+	 */
+	if (time_after(jiffies, (last_reset_time + 20 * HZ)))
+		priv->reset_level = HNAE3_FUNC_RESET;
+
+	/* Don't do any new action before the next timeout */
+	else if (time_before(jiffies, (last_reset_time + ndev->watchdog_timeo)))
+		return;
+
+	priv->last_reset_time = jiffies;
+
+	if (h->ae_algo->ops->reset_event)
+		h->ae_algo->ops->reset_event(h, priv->reset_level, 0);
+
+	priv->reset_level++;
+	if (priv->reset_level > HNAE3_GLOBAL_RESET)
+		priv->reset_level = HNAE3_GLOBAL_RESET;
+}
+
 static const struct net_device_ops hns3_nic_netdev_ops = {
 	.ndo_open		= hns3_nic_net_open,
 	.ndo_stop		= hns3_nic_net_stop,
 	.ndo_start_xmit		= hns3_nic_net_xmit,
+	.ndo_tx_timeout		= hns3_nic_net_timeout,
 	.ndo_set_mac_address	= hns3_nic_net_set_mac_address,
 	.ndo_change_mtu		= hns3_nic_change_mtu,
 	.ndo_set_features	= hns3_nic_set_features,
@@ -2763,6 +2846,9 @@ static int hns3_client_init(struct hnae3_handle *handle)
 	priv->dev = &pdev->dev;
 	priv->netdev = netdev;
 	priv->ae_handle = handle;
+	priv->last_reset_time = jiffies;
+	priv->reset_level = HNAE3_FUNC_RESET;
+	priv->tx_timeout_count = 0;
 
 	handle->kinfo.netdev = netdev;
 	handle->priv = (void *)priv;
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h
index 58dc30b..8a9de75 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h
@@ -518,6 +518,8 @@ struct hns3_nic_priv {
 	/* The most recently read link state */
 	int link;
 	u64 tx_timeout_count;
+	enum hnae3_reset_type reset_level;
+	unsigned long last_reset_time;
 
 	unsigned long state;
 
-- 
1.9.1
