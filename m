From: Lipeng <lipeng321@huawei.com>
Subject: [PATCH net-next 3/5] net: hns3: add support for set_rxnfc
Date: Tue, 10 Oct 2017 16:42:05 +0800
Message-ID: <1507624927-98008-4-git-send-email-lipeng321@huawei.com>
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

This patch supports the ethtool's set_rxnfc().

Signed-off-by: Lipeng <lipeng321@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns3/hnae3.h        |  2 +
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.c |  9 ++
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h |  1 +
 .../ethernet/hisilicon/hns3/hns3pf/hclge_main.c    | 95 +++++++++++++++++++++-
 .../ethernet/hisilicon/hns3/hns3pf/hclge_main.h    |  8 ++
 .../ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c  | 16 ++++
 6 files changed, 129 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hnae3.h b/drivers/net/ethernet/hisilicon/hns3/hnae3.h
index c677530..d952d62 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hnae3.h
+++ b/drivers/net/ethernet/hisilicon/hns3/hnae3.h
@@ -339,6 +339,8 @@ struct hnae3_ae_ops {
 		       u8 *hfunc);
 	int (*set_rss)(struct hnae3_handle *handle, const u32 *indir,
 		       const u8 *key, const u8 hfunc);
+	int (*set_rss_tuple)(struct hnae3_handle *handle,
+			     struct ethtool_rxnfc *cmd);
 
 	int (*get_tc_size)(struct hnae3_handle *handle);
 
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.c
index 8ecd807..60960e5 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.c
@@ -85,6 +85,15 @@ static int hclge_init_cmd_queue(struct hclge_dev *hdev, int ring_type)
 	return 0;
 }
 
+void hclge_cmd_reuse_desc(struct hclge_desc *desc, bool is_read)
+{
+	desc->flag = cpu_to_le16(HCLGE_CMD_FLAG_NO_INTR | HCLGE_CMD_FLAG_IN);
+	if (is_read)
+		desc->flag |= cpu_to_le16(HCLGE_CMD_FLAG_WR);
+	else
+		desc->flag &= cpu_to_le16(~HCLGE_CMD_FLAG_WR);
+}
+
 void hclge_cmd_setup_basic_desc(struct hclge_desc *desc,
 				enum hclge_opcode_type opcode, bool is_read)
 {
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h
index 8f3ba02a..b437334 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h
@@ -739,6 +739,7 @@ static inline u32 hclge_read_reg(u8 __iomem *base, u32 reg)
 int hclge_cmd_send(struct hclge_hw *hw, struct hclge_desc *desc, int num);
 void hclge_cmd_setup_basic_desc(struct hclge_desc *desc,
 				enum hclge_opcode_type opcode, bool is_read);
+void hclge_cmd_reuse_desc(struct hclge_desc *desc, bool is_read);
 
 int hclge_cmd_set_promisc_mode(struct hclge_dev *hdev,
 			       struct hclge_promisc_param *param);
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
index c91c779..5b5e52c 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
@@ -2595,8 +2595,6 @@ static int hclge_set_rss_tc_mode(struct hclge_dev *hdev, u16 *tc_valid,
 
 static int hclge_set_rss_input_tuple(struct hclge_dev *hdev)
 {
-#define HCLGE_RSS_INPUT_TUPLE_OTHER		0xf
-#define HCLGE_RSS_INPUT_TUPLE_SCTP		0x1f
 	struct hclge_rss_input_tuple_cmd *req;
 	struct hclge_desc desc;
 	int ret;
@@ -2677,6 +2675,98 @@ static int hclge_set_rss(struct hnae3_handle *handle, const u32 *indir,
 	return ret;
 }
 
+static u8 hclge_get_rss_hash_bits(struct ethtool_rxnfc *nfc)
+{
+	u8 hash_sets = nfc->data & RXH_L4_B_0_1 ? HCLGE_S_PORT_BIT : 0;
+
+	if (nfc->data & RXH_L4_B_2_3)
+		hash_sets |= HCLGE_D_PORT_BIT;
+	else
+		hash_sets &= ~HCLGE_D_PORT_BIT;
+
+	if (nfc->data & RXH_IP_SRC)
+		hash_sets |= HCLGE_S_IP_BIT;
+	else
+		hash_sets &= ~HCLGE_S_IP_BIT;
+
+	if (nfc->data & RXH_IP_DST)
+		hash_sets |= HCLGE_D_IP_BIT;
+	else
+		hash_sets &= ~HCLGE_D_IP_BIT;
+
+	if (nfc->flow_type == SCTP_V4_FLOW || nfc->flow_type == SCTP_V6_FLOW)
+		hash_sets |= HCLGE_V_TAG_BIT;
+
+	return hash_sets;
+}
+
+static int hclge_set_rss_tuple(struct hnae3_handle *handle,
+			       struct ethtool_rxnfc *nfc)
+{
+	struct hclge_vport *vport = hclge_get_vport(handle);
+	struct hclge_dev *hdev = vport->back;
+	struct hclge_rss_input_tuple_cmd *req;
+	struct hclge_desc desc;
+	u8 tuple_sets;
+	int ret;
+
+	if (nfc->data & ~(RXH_IP_SRC | RXH_IP_DST |
+			  RXH_L4_B_0_1 | RXH_L4_B_2_3))
+		return -EINVAL;
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
+	hclge_cmd_reuse_desc(&desc, false);
+
+	tuple_sets = hclge_get_rss_hash_bits(nfc);
+	switch (nfc->flow_type) {
+	case TCP_V4_FLOW:
+		req->ipv4_tcp_en = tuple_sets;
+		break;
+	case TCP_V6_FLOW:
+		req->ipv6_tcp_en = tuple_sets;
+		break;
+	case UDP_V4_FLOW:
+		req->ipv4_udp_en = tuple_sets;
+		break;
+	case UDP_V6_FLOW:
+		req->ipv6_udp_en = tuple_sets;
+		break;
+	case SCTP_V4_FLOW:
+		req->ipv4_sctp_en = tuple_sets;
+		break;
+	case SCTP_V6_FLOW:
+		if ((nfc->data & RXH_L4_B_0_1) ||
+		    (nfc->data & RXH_L4_B_2_3))
+			return -EINVAL;
+
+		req->ipv6_sctp_en = tuple_sets;
+		break;
+	case IPV4_FLOW:
+		req->ipv4_fragment_en = HCLGE_RSS_INPUT_TUPLE_OTHER;
+		break;
+	case IPV6_FLOW:
+		req->ipv6_fragment_en = HCLGE_RSS_INPUT_TUPLE_OTHER;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	ret = hclge_cmd_send(&hdev->hw, &desc, 1);
+	if (ret)
+		dev_err(&hdev->pdev->dev,
+			"Set rss tuple fail, status = %d\n", ret);
+
+	return ret;
+}
+
 static int hclge_get_tc_size(struct hnae3_handle *handle)
 {
 	struct hclge_vport *vport = hclge_get_vport(handle);
@@ -4344,6 +4434,7 @@ static void hclge_uninit_ae_dev(struct hnae3_ae_dev *ae_dev)
 	.get_rss_indir_size = hclge_get_rss_indir_size,
 	.get_rss = hclge_get_rss,
 	.set_rss = hclge_set_rss,
+	.set_rss_tuple = hclge_set_rss_tuple,
 	.get_tc_size = hclge_get_tc_size,
 	.get_mac_addr = hclge_get_mac_addr,
 	.set_mac_addr = hclge_set_mac_addr,
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.h b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.h
index 79c1a06..a7c018c 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.h
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.h
@@ -41,6 +41,14 @@
 #define HCLGE_RSS_CFG_TBL_NUM \
 	(HCLGE_RSS_IND_TBL_SIZE / HCLGE_RSS_CFG_TBL_SIZE)
 
+#define HCLGE_RSS_INPUT_TUPLE_OTHER	GENMASK(3, 0)
+#define HCLGE_RSS_INPUT_TUPLE_SCTP	GENMASK(4, 0)
+#define HCLGE_D_PORT_BIT		BIT(0)
+#define HCLGE_S_PORT_BIT		BIT(1)
+#define HCLGE_D_IP_BIT			BIT(2)
+#define HCLGE_S_IP_BIT			BIT(3)
+#define HCLGE_V_TAG_BIT			BIT(4)
+
 #define HCLGE_RSS_TC_SIZE_0		1
 #define HCLGE_RSS_TC_SIZE_1		2
 #define HCLGE_RSS_TC_SIZE_2		4
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c
index 1c5d003..f0e88e0 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c
@@ -533,6 +533,21 @@ int hns3_set_ringparam(struct net_device *ndev, struct ethtool_ringparam *param)
 	return ret;
 }
 
+static int hns3_set_rxnfc(struct net_device *netdev, struct ethtool_rxnfc *cmd)
+{
+	struct hnae3_handle *h = hns3_get_handle(netdev);
+
+	if (!h->ae_algo || !h->ae_algo->ops || !h->ae_algo->ops->set_rss_tuple)
+		return -EOPNOTSUPP;
+
+	switch (cmd->cmd) {
+	case ETHTOOL_SRXFH:
+		return h->ae_algo->ops->set_rss_tuple(h, cmd);
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
 static const struct ethtool_ops hns3_ethtool_ops = {
 	.get_drvinfo = hns3_get_drvinfo,
 	.get_link = hns3_get_link,
@@ -543,6 +558,7 @@ int hns3_set_ringparam(struct net_device *ndev, struct ethtool_ringparam *param)
 	.get_ethtool_stats = hns3_get_stats,
 	.get_sset_count = hns3_get_sset_count,
 	.get_rxnfc = hns3_get_rxnfc,
+	.set_rxnfc = hns3_set_rxnfc,
 	.get_rxfh_key_size = hns3_get_rss_key_size,
 	.get_rxfh_indir_size = hns3_get_rss_indir_size,
 	.get_rxfh = hns3_get_rss,
-- 
1.9.1
