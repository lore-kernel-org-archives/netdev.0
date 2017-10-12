From: Yunsheng Lin <linyunsheng@huawei.com>
Subject: [PATCH net-next 2/2] net: hns3: Add mqprio hardware offload support in hns3 driver
Date: Thu, 12 Oct 2017 10:38:32 +0800
Message-ID: <1507775912-22402-3-git-send-email-linyunsheng@huawei.com>
References: <1507775912-22402-1-git-send-email-linyunsheng@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <huangdaode@hisilicon.com>, <xuwei5@hisilicon.com>,
        <liguozhu@hisilicon.com>, <Yisen.Zhuang@huawei.com>,
        <gabriele.paoloni@huawei.com>, <john.garry@huawei.com>,
        <linuxarm@huawei.com>, <yisen.zhuang@huawei.com>,
        <salil.mehta@huawei.com>, <lipeng321@huawei.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <yuvalm@mellanox.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507775912-22402-1-git-send-email-linyunsheng@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When using tc qdisc, dcb_ops->setup_tc is used to tell hclge_dcb
module to do the tm related setup. Only TC_MQPRIO_HW_OFFLOAD_DCB
offload type is supported.

Signed-off-by: Yunsheng Lin <linyunsheng@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns3/hnae3.h        |  1 +
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_dcb.c | 23 +++++++++++
 .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c | 46 ++++++++++++++--------
 3 files changed, 54 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hnae3.h b/drivers/net/ethernet/hisilicon/hns3/hnae3.h
index 575f50d..3acd8db 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hnae3.h
+++ b/drivers/net/ethernet/hisilicon/hns3/hnae3.h
@@ -381,6 +381,7 @@ struct hnae3_dcb_ops {
 	u8   (*setdcbx)(struct hnae3_handle *, u8);
 
 	int (*map_update)(struct hnae3_handle *);
+	int (*setup_tc)(struct hnae3_handle *, u8, u8 *);
 };
 
 struct hnae3_ae_algo {
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_dcb.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_dcb.c
index 1b30a6f..7ec9484 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_dcb.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_dcb.c
@@ -276,6 +276,28 @@ static u8 hclge_setdcbx(struct hnae3_handle *h, u8 mode)
 	return 0;
 }
 
+static int hclge_setup_tc(struct hnae3_handle *h, u8 tc, u8 *prio_tc)
+{
+	struct hclge_vport *vport = hclge_get_vport(h);
+	struct hclge_dev *hdev = vport->back;
+	int ret;
+
+	if (tc > hdev->tc_max) {
+		dev_err(&hdev->pdev->dev,
+			"setup tc failed, tc(%u) > tc_max(%u)\n",
+			tc, hdev->tc_max);
+		return -EINVAL;
+	}
+
+	hclge_tm_schd_info_update(hdev, tc);
+
+	ret = hclge_tm_prio_tc_info_update(hdev, prio_tc);
+	if (ret)
+		return ret;
+
+	return hclge_tm_init_hw(hdev);
+}
+
 static const struct hnae3_dcb_ops hns3_dcb_ops = {
 	.ieee_getets	= hclge_ieee_getets,
 	.ieee_setets	= hclge_ieee_setets,
@@ -284,6 +306,7 @@ static u8 hclge_setdcbx(struct hnae3_handle *h, u8 mode)
 	.getdcbx	= hclge_getdcbx,
 	.setdcbx	= hclge_setdcbx,
 	.map_update	= hclge_map_update,
+	.setup_tc	= hclge_setup_tc,
 };
 
 void hclge_dcb_ops_set(struct hclge_dev *hdev)
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
index ba550c1..79d8d6b 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
@@ -1186,42 +1186,56 @@ static void hns3_nic_udp_tunnel_del(struct net_device *netdev,
 	}
 }
 
-static int hns3_setup_tc(struct net_device *netdev, u8 tc)
+static int hns3_setup_tc(struct net_device *netdev, u8 tc, u8 *prio_tc)
 {
 	struct hnae3_handle *h = hns3_get_handle(netdev);
 	struct hnae3_knic_private_info *kinfo = &h->kinfo;
+	bool if_running;
 	unsigned int i;
 	int ret;
 
 	if (tc > HNAE3_MAX_TC)
 		return -EINVAL;
 
-	if (kinfo->num_tc == tc)
-		return 0;
-
 	if (!netdev)
 		return -EINVAL;
 
-	if (!tc) {
-		netdev_reset_tc(netdev);
-		return 0;
+	if_running = netif_running(netdev);
+	if (if_running) {
+		hns3_nic_net_stop(netdev);
+		msleep(100);
 	}
 
-	/* Set num_tc for netdev */
-	ret = netdev_set_num_tc(netdev, tc);
+	ret = (kinfo->dcb_ops && kinfo->dcb_ops->setup_tc) ?
+		kinfo->dcb_ops->setup_tc(h, tc, prio_tc) : -EOPNOTSUPP;
 	if (ret)
-		return ret;
+		goto out;
+
+	if (tc <= 1) {
+		netdev_reset_tc(netdev);
+	} else {
+		ret = netdev_set_num_tc(netdev, tc);
+		if (ret)
+			goto out;
+
+		for (i = 0; i < HNAE3_MAX_TC; i++) {
+			if (!kinfo->tc_info[i].enable)
+				continue;
 
-	/* Set per TC queues for the VSI */
-	for (i = 0; i < HNAE3_MAX_TC; i++) {
-		if (kinfo->tc_info[i].enable)
 			netdev_set_tc_queue(netdev,
 					    kinfo->tc_info[i].tc,
 					    kinfo->tc_info[i].tqp_count,
 					    kinfo->tc_info[i].tqp_offset);
+		}
 	}
 
-	return 0;
+	ret = hns3_nic_set_real_num_queue(netdev);
+
+out:
+	if (if_running)
+		hns3_nic_net_open(netdev);
+
+	return ret;
 }
 
 static int hns3_nic_setup_tc(struct net_device *dev, enum tc_setup_type type,
@@ -1229,10 +1243,10 @@ static int hns3_nic_setup_tc(struct net_device *dev, enum tc_setup_type type,
 {
 	struct tc_mqprio_qopt *mqprio = type_data;
 
-	if (type != TC_SETUP_MQPRIO)
+	if (type != TC_SETUP_MQPRIO || mqprio->hw != TC_MQPRIO_HW_OFFLOAD_DCB)
 		return -EOPNOTSUPP;
 
-	return hns3_setup_tc(dev, mqprio->num_tc);
+	return hns3_setup_tc(dev, mqprio->num_tc, mqprio->prio_tc_map);
 }
 
 static int hns3_vlan_rx_add_vid(struct net_device *netdev,
-- 
1.9.1
