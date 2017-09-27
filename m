From: Yunsheng Lin <linyunsheng@huawei.com>
Subject: [PATCH v3 net-next 10/10] net: hns3: Add DCB support when interacting with network stack
Date: Wed, 27 Sep 2017 09:45:32 +0800
Message-ID: <1506476732-128130-11-git-send-email-linyunsheng@huawei.com>
References: <1506476732-128130-1-git-send-email-linyunsheng@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <huangdaode@hisilicon.com>, <xuwei5@hisilicon.com>,
        <liguozhu@hisilicon.com>, <Yisen.Zhuang@huawei.com>,
        <gabriele.paoloni@huawei.com>, <john.garry@huawei.com>,
        <linuxarm@huawei.com>, <yisen.zhuang@huawei.com>,
        <salil.mehta@huawei.com>, <lipeng321@huawei.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1506476732-128130-1-git-send-email-linyunsheng@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When using lldptool to configure DCB parameter, hclge_dcb module
call the client_ops->setup_tc to tell network stack which queue
and priority is using for specific tc.

Signed-off-by: Yunsheng Lin <linyunsheng@huawei.com>
---
V2:
	Drop mqprio support.

V1:
	Initial submit.
---
 .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c | 102 ++++++++++++++++++---
 1 file changed, 87 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
index 11dab26..4a0890f9 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
@@ -196,6 +196,32 @@ static void hns3_vector_gl_rl_init(struct hns3_enet_tqp_vector *tqp_vector)
 	tqp_vector->tx_group.flow_level = HNS3_FLOW_LOW;
 }
 
+static int hns3_nic_set_real_num_queue(struct net_device *netdev)
+{
+	struct hns3_nic_priv *priv = netdev_priv(netdev);
+	struct hnae3_handle *h = priv->ae_handle;
+	struct hnae3_knic_private_info *kinfo = &h->kinfo;
+	unsigned int queue_size = kinfo->rss_size * kinfo->num_tc;
+	int ret;
+
+	ret = netif_set_real_num_tx_queues(netdev, queue_size);
+	if (ret) {
+		netdev_err(netdev,
+			   "netif_set_real_num_tx_queues fail, ret=%d!\n",
+			   ret);
+		return ret;
+	}
+
+	ret = netif_set_real_num_rx_queues(netdev, queue_size);
+	if (ret) {
+		netdev_err(netdev,
+			   "netif_set_real_num_rx_queues fail, ret=%d!\n", ret);
+		return ret;
+	}
+
+	return 0;
+}
+
 static int hns3_nic_net_up(struct net_device *netdev)
 {
 	struct hns3_nic_priv *priv = netdev_priv(netdev);
@@ -232,26 +258,13 @@ static int hns3_nic_net_up(struct net_device *netdev)
 
 static int hns3_nic_net_open(struct net_device *netdev)
 {
-	struct hns3_nic_priv *priv = netdev_priv(netdev);
-	struct hnae3_handle *h = priv->ae_handle;
 	int ret;
 
 	netif_carrier_off(netdev);
 
-	ret = netif_set_real_num_tx_queues(netdev, h->kinfo.num_tqps);
-	if (ret) {
-		netdev_err(netdev,
-			   "netif_set_real_num_tx_queues fail, ret=%d!\n",
-			   ret);
-		return ret;
-	}
-
-	ret = netif_set_real_num_rx_queues(netdev, h->kinfo.num_tqps);
-	if (ret) {
-		netdev_err(netdev,
-			   "netif_set_real_num_rx_queues fail, ret=%d!\n", ret);
+	ret = hns3_nic_set_real_num_queue(netdev);
+	if (ret)
 		return ret;
-	}
 
 	ret = hns3_nic_net_up(netdev);
 	if (ret) {
@@ -2848,10 +2861,69 @@ static void hns3_link_status_change(struct hnae3_handle *handle, bool linkup)
 	}
 }
 
+static int hns3_client_setup_tc(struct hnae3_handle *handle, u8 tc)
+{
+	struct hnae3_knic_private_info *kinfo = &handle->kinfo;
+	struct net_device *ndev = kinfo->netdev;
+	bool if_running = netif_running(ndev);
+	int ret;
+	u8 i;
+
+	if (tc > HNAE3_MAX_TC)
+		return -EINVAL;
+
+	if (!ndev)
+		return -ENODEV;
+
+	ret = netdev_set_num_tc(ndev, tc);
+	if (ret)
+		return ret;
+
+	if (if_running) {
+		(void)hns3_nic_net_stop(ndev);
+		msleep(100);
+	}
+
+	ret = (kinfo->dcb_ops && kinfo->dcb_ops->map_update) ?
+		kinfo->dcb_ops->map_update(handle) : -EOPNOTSUPP;
+	if (ret)
+		goto err_out;
+
+	if (tc <= 1) {
+		netdev_reset_tc(ndev);
+		goto out;
+	}
+
+	for (i = 0; i < HNAE3_MAX_TC; i++) {
+		struct hnae3_tc_info *tc_info = &kinfo->tc_info[i];
+
+		if (tc_info->enable)
+			netdev_set_tc_queue(ndev,
+					    tc_info->tc,
+					    tc_info->tqp_count,
+					    tc_info->tqp_offset);
+	}
+
+	for (i = 0; i < HNAE3_MAX_USER_PRIO; i++) {
+		netdev_set_prio_tc_map(ndev, i,
+				       kinfo->prio_tc[i]);
+	}
+
+out:
+	ret = hns3_nic_set_real_num_queue(ndev);
+
+err_out:
+	if (if_running)
+		(void)hns3_nic_net_open(ndev);
+
+	return ret;
+}
+
 const struct hnae3_client_ops client_ops = {
 	.init_instance = hns3_client_init,
 	.uninit_instance = hns3_client_uninit,
 	.link_status_change = hns3_link_status_change,
+	.setup_tc = hns3_client_setup_tc,
 };
 
 /* hns3_init_module - Driver registration routine
-- 
1.9.1
