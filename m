From: Lipeng <lipeng321@huawei.com>
Subject: [PATCH net-next 4/5] net: hns3: add support for ETHTOOL_GRXFH
Date: Tue, 10 Oct 2017 16:42:06 +0800
Message-ID: <1507624927-98008-5-git-send-email-lipeng321@huawei.com>
References: <1507624927-98008-1-git-send-email-lipeng321@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linuxarm@huawei.com>, <yisen.zhuang@huawei.com>,
        <salil.mehta@huawei.com>, <lipeng321@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507624927-98008-1-git-send-email-lipeng321@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch add support for ethtool's ETHTOOL_GRXFH in hns3_get_rxnfc().

Signed-off-by: Lipeng <lipeng321@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns3/hnae3.h        |  2 +
 .../ethernet/hisilicon/hns3/hns3pf/hclge_main.c    | 64 ++++++++++++++++++++++
 .../ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c  |  2 +
 3 files changed, 68 insertions(+)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hnae3.h b/drivers/net/ethernet/hisilicon/hns3/hnae3.h
index d952d62..575f50d 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hnae3.h
+++ b/drivers/net/ethernet/hisilicon/hns3/hnae3.h
@@ -341,6 +341,8 @@ struct hnae3_ae_ops {
 		       const u8 *key, const u8 hfunc);
 	int (*set_rss_tuple)(struct hnae3_handle *handle,
 			     struct ethtool_rxnfc *cmd);
+	int (*get_rss_tuple)(struct hnae3_handle *handle,
+			     struct ethtool_rxnfc *cmd);
 
 	int (*get_tc_size)(struct hnae3_handle *handle);
 
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
index 5b5e52c..c322b45 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
@@ -2767,6 +2767,69 @@ static int hclge_set_rss_tuple(struct hnae3_handle *handle,
 	return ret;
 }
 
+static int hclge_get_rss_tuple(struct hnae3_handle *handle,
+			       struct ethtool_rxnfc *nfc)
+{
+	struct hclge_vport *vport = hclge_get_vport(handle);
+	struct hclge_dev *hdev = vport->back;
+	struct hclge_rss_input_tuple_cmd *req;
+	struct hclge_desc desc;
+	u8 tuple_sets;
+	int ret;
+
+	nfc->data = 0;
+
+	req = (struct hclge_rss_input_tuple_cmd *)desc.data;
+	hclge_cmd_setup_basic_desc(&desc, HCLGE_OPC_RSS_INPUT_TUPLE, true);
+	ret = hclge_cmd_send(&hdev->hw, &desc, 1);
+	if (ret) {
+		dev_err(&hdev->pdev->dev,
+			"Read rss tuple fail, status = %d\n", ret);
+		return ret;
+	}
+
+	switch (nfc->flow_type) {
+	case TCP_V4_FLOW:
+		tuple_sets = req->ipv4_tcp_en;
+		break;
+	case UDP_V4_FLOW:
+		tuple_sets = req->ipv4_udp_en;
+		break;
+	case TCP_V6_FLOW:
+		tuple_sets = req->ipv6_tcp_en;
+		break;
+	case UDP_V6_FLOW:
+		tuple_sets = req->ipv6_udp_en;
+		break;
+	case SCTP_V4_FLOW:
+		tuple_sets = req->ipv4_sctp_en;
+		break;
+	case SCTP_V6_FLOW:
+		tuple_sets = req->ipv6_sctp_en;
+		break;
+	case IPV4_FLOW:
+	case IPV6_FLOW:
+		tuple_sets = HCLGE_S_IP_BIT | HCLGE_D_IP_BIT;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	if (!tuple_sets)
+		return 0;
+
+	if (tuple_sets & HCLGE_D_PORT_BIT)
+		nfc->data |= RXH_L4_B_2_3;
+	if (tuple_sets & HCLGE_S_PORT_BIT)
+		nfc->data |= RXH_L4_B_0_1;
+	if (tuple_sets & HCLGE_D_IP_BIT)
+		nfc->data |= RXH_IP_DST;
+	if (tuple_sets & HCLGE_S_IP_BIT)
+		nfc->data |= RXH_IP_SRC;
+
+	return 0;
+}
+
 static int hclge_get_tc_size(struct hnae3_handle *handle)
 {
 	struct hclge_vport *vport = hclge_get_vport(handle);
@@ -4435,6 +4498,7 @@ static void hclge_uninit_ae_dev(struct hnae3_ae_dev *ae_dev)
 	.get_rss = hclge_get_rss,
 	.set_rss = hclge_set_rss,
 	.set_rss_tuple = hclge_set_rss_tuple,
+	.get_rss_tuple = hclge_get_rss_tuple,
 	.get_tc_size = hclge_get_tc_size,
 	.get_mac_addr = hclge_get_mac_addr,
 	.set_mac_addr = hclge_set_mac_addr,
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c
index f0e88e0..b64fbd3 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c
@@ -452,6 +452,8 @@ static int hns3_get_rxnfc(struct net_device *netdev,
 	case ETHTOOL_GRXRINGS:
 		cmd->data = h->ae_algo->ops->get_tc_size(h);
 		break;
+	case ETHTOOL_GRXFH:
+		return h->ae_algo->ops->get_rss_tuple(h, cmd);
 	default:
 		return -EOPNOTSUPP;
 	}
-- 
1.9.1
