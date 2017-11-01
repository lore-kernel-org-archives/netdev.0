From: Lipeng <lipeng321@huawei.com>
Subject: [PATCH net-next 7/9] net: hns3: Add reset interface implementation in client
Date: Wed, 1 Nov 2017 22:47:20 +0800
Message-ID: <1509547642-51110-8-git-send-email-lipeng321@huawei.com>
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

This patch implement the interface of reset notification in hns3_enet
it will do resetting business which include shutdown nic device,
free and initialize client side resource.

Signed-off-by: qumingguang <qumingguang@huawei.com>
Signed-off-by: Lipeng <lipeng321@huawei.com>
---
 .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c | 153 +++++++++++++++++++++
 1 file changed, 153 insertions(+)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
index aed6611..681a043 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
@@ -3009,11 +3009,164 @@ static int hns3_client_setup_tc(struct hnae3_handle *handle, u8 tc)
 	return ret;
 }
 
+static void hns3_recover_hw_addr(struct net_device *ndev)
+{
+	struct netdev_hw_addr_list *list;
+	struct netdev_hw_addr *ha, *tmp;
+
+	/* go through and sync uc_addr entries to the device */
+	list = &ndev->uc;
+	list_for_each_entry_safe(ha, tmp, &list->list, list)
+		hns3_nic_uc_sync(ndev, ha->addr);
+
+	/* go through and sync mc_addr entries to the device */
+	list = &ndev->mc;
+	list_for_each_entry_safe(ha, tmp, &list->list, list)
+		hns3_nic_mc_sync(ndev, ha->addr);
+}
+
+static void hns3_drop_skb_data(struct hns3_enet_ring *ring, struct sk_buff *skb)
+{
+	dev_kfree_skb_any(skb);
+}
+
+static void hns3_clear_all_ring(struct hnae3_handle *h)
+{
+	struct net_device *ndev = h->kinfo.netdev;
+	struct hns3_nic_priv *priv = netdev_priv(ndev);
+	u32 i;
+
+	for (i = 0; i < h->kinfo.num_tqps; i++) {
+		struct netdev_queue *dev_queue;
+		struct hns3_enet_ring *ring;
+
+		ring = priv->ring_data[i].ring;
+		hns3_clean_tx_ring(ring, ring->desc_num);
+		dev_queue = netdev_get_tx_queue(ndev,
+						priv->ring_data[i].queue_index);
+		netdev_tx_reset_queue(dev_queue);
+
+		ring = priv->ring_data[i + h->kinfo.num_tqps].ring;
+		hns3_clean_rx_ring(ring, ring->desc_num, hns3_drop_skb_data);
+	}
+}
+
+static int hns3_reset_notify_down_enet(struct hnae3_handle *handle)
+{
+	struct hnae3_knic_private_info *kinfo = &handle->kinfo;
+	struct net_device *ndev = kinfo->netdev;
+
+	if (!netif_running(ndev))
+		return -EIO;
+
+	return hns3_nic_net_stop(ndev);
+}
+
+static int hns3_reset_notify_up_enet(struct hnae3_handle *handle)
+{
+	struct hnae3_knic_private_info *kinfo = &handle->kinfo;
+	struct hns3_nic_priv *priv = netdev_priv(kinfo->netdev);
+	int ret = 0;
+
+	if (netif_running(kinfo->netdev)) {
+		ret = hns3_nic_net_up(kinfo->netdev);
+		if (ret) {
+			netdev_err(kinfo->netdev,
+				   "hns net up fail, ret=%d!\n", ret);
+			return ret;
+		}
+
+		priv->last_reset_time = jiffies;
+	}
+
+	return ret;
+}
+
+static int hns3_reset_notify_init_enet(struct hnae3_handle *handle)
+{
+	struct net_device *netdev = handle->kinfo.netdev;
+	struct hns3_nic_priv *priv = netdev_priv(netdev);
+	int ret;
+
+	priv->reset_level = 1;
+	hns3_init_mac_addr(netdev);
+	hns3_nic_set_rx_mode(netdev);
+	hns3_recover_hw_addr(netdev);
+
+	/* Carrier off reporting is important to ethtool even BEFORE open */
+	netif_carrier_off(netdev);
+
+	ret = hns3_get_ring_config(priv);
+	if (ret)
+		return ret;
+
+	ret = hns3_nic_init_vector_data(priv);
+	if (ret)
+		return ret;
+
+	ret = hns3_init_all_ring(priv);
+	if (ret) {
+		hns3_nic_uninit_vector_data(priv);
+		priv->ring_data = NULL;
+	}
+
+	return ret;
+}
+
+static int hns3_reset_notify_uninit_enet(struct hnae3_handle *handle)
+{
+	struct net_device *netdev = handle->kinfo.netdev;
+	struct hns3_nic_priv *priv = netdev_priv(netdev);
+	int ret;
+
+	hns3_clear_all_ring(handle);
+
+	ret = hns3_nic_uninit_vector_data(priv);
+	if (ret) {
+		netdev_err(netdev, "uninit vector error\n");
+		return ret;
+	}
+
+	ret = hns3_uninit_all_ring(priv);
+	if (ret)
+		netdev_err(netdev, "uninit ring error\n");
+
+	priv->ring_data = NULL;
+
+	return ret;
+}
+
+static int hns3_reset_notify(struct hnae3_handle *handle,
+			     enum hnae3_reset_notify_type type)
+{
+	int ret = 0;
+
+	switch (type) {
+	case HNAE3_DOWN_CLIENT:
+		ret = hns3_reset_notify_down_enet(handle);
+		break;
+	case HNAE3_INIT_CLIENT:
+		ret = hns3_reset_notify_init_enet(handle);
+		break;
+	case HNAE3_UNINIT_CLIENT:
+		ret = hns3_reset_notify_uninit_enet(handle);
+		break;
+	case HNAE3_UP_CLIENT:
+		ret = hns3_reset_notify_up_enet(handle);
+		break;
+	default:
+		break;
+	}
+
+	return ret;
+}
+
 static const struct hnae3_client_ops client_ops = {
 	.init_instance = hns3_client_init,
 	.uninit_instance = hns3_client_uninit,
 	.link_status_change = hns3_link_status_change,
 	.setup_tc = hns3_client_setup_tc,
+	.reset_notify = hns3_reset_notify,
 };
 
 /* hns3_init_module - Driver registration routine
-- 
1.9.1
