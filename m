From: Lipeng <lipeng321@huawei.com>
Subject: [PATCH net-next 5/8] net: hns3: set the VLAN Ethernet type to HW
Date: Thu, 31 Aug 2017 21:39:06 +0800
Message-ID: <1504186749-8926-6-git-send-email-lipeng321@huawei.com>
References: <1504186749-8926-1-git-send-email-lipeng321@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linuxarm@huawei.com>, <yisen.zhuang@huawei.com>,
        <salil.mehta@huawei.com>, <lipeng321@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga05-in.huawei.com ([45.249.212.191]:5069 "EHLO
        szxga05-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751034AbdHaNLY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 09:11:24 -0400
In-Reply-To: <1504186749-8926-1-git-send-email-lipeng321@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set the VLAN Ethetnet type(0x8100) to HW. With this
configure, HW can identify vlan packets.

Signed-off-by: Mingguang Qu <qumingguang@huawei.com>
Signed-off-by: Lipeng <lipeng321@huawei.com>
---
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h | 13 +++++
 .../ethernet/hisilicon/hns3/hns3pf/hclge_main.c    | 58 +++++++++++++++++++++-
 .../ethernet/hisilicon/hns3/hns3pf/hclge_main.h    | 11 ++++
 3 files changed, 80 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h
index dd8e513..b841df1 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h
@@ -655,6 +655,19 @@ struct hclge_vlan_filter_vf_cfg {
 	u8  vf_bitmap[16];
 };
 
+struct hclge_tx_vlan_type_cfg {
+	u16 ot_vlan_type;
+	u16 in_vlan_type;
+	u8 rsv[20];
+};
+
+struct hclge_rx_vlan_type_cfg {
+	u16 ot_fst_vlan_type;
+	u16 ot_sec_vlan_type;
+	u16 in_fst_vlan_type;
+	u16 in_sec_vlan_type;
+	u8 rsv[16];
+};
 struct hclge_cfg_com_tqp_queue {
 	__le16 tqp_id;
 	__le16 stream_id;
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
index 7374053..f2ea88f 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
@@ -3694,10 +3694,52 @@ static int hclge_set_vf_vlan_filter(struct hnae3_handle *handle, int vfid,
 	return hclge_set_vf_vlan_common(hdev, vfid, false, vlan, qos, proto);
 }
 
+static int hclge_set_vlan_protocol_type(struct hclge_dev *hdev)
+{
+	struct hclge_desc desc;
+	struct hclge_rx_vlan_type_cfg *rx_req =
+		(struct hclge_rx_vlan_type_cfg *)&desc.data[0];
+	struct hclge_tx_vlan_type_cfg *tx_req =
+		(struct hclge_tx_vlan_type_cfg *)&desc.data[0];
+	enum hclge_cmd_status status;
+
+	hclge_cmd_setup_basic_desc(&desc,
+				   HCLGE_OPC_MAC_VLAN_TYPE_ID, false);
+
+	rx_req->ot_fst_vlan_type = hdev->vlan_type_cfg.rx_ot_fst_vlan_type;
+	rx_req->ot_sec_vlan_type = hdev->vlan_type_cfg.rx_ot_sec_vlan_type;
+	rx_req->in_fst_vlan_type = hdev->vlan_type_cfg.rx_in_fst_vlan_type;
+	rx_req->in_sec_vlan_type = hdev->vlan_type_cfg.rx_in_sec_vlan_type;
+
+	status = hclge_cmd_send(&hdev->hw, &desc, 1);
+	if (status) {
+		dev_err(&hdev->pdev->dev,
+			"Send rxvlan protocol type command fail, ret =%d.\n",
+			status);
+		return -EIO;
+	}
+
+	hclge_cmd_setup_basic_desc(&desc,
+				   HCLGE_OPC_MAC_VLAN_INSERT, false);
+
+	tx_req->ot_vlan_type = hdev->vlan_type_cfg.tx_ot_vlan_type;
+	tx_req->in_vlan_type = hdev->vlan_type_cfg.tx_in_vlan_type;
+
+	status = hclge_cmd_send(&hdev->hw, &desc, 1);
+	if (status) {
+		dev_err(&hdev->pdev->dev,
+			"Send txvlan protocol type command fail, ret =%d.\n",
+			status);
+		return -EIO;
+	}
+	return 0;
+}
+
 static int hclge_init_vlan_config(struct hclge_dev *hdev)
 {
-#define HCLGE_VLAN_TYPE_VF_TABLE   0
-#define HCLGE_VLAN_TYPE_PORT_TABLE 1
+#define HCLGE_VLAN_TYPE_VF_TABLE	0
+#define HCLGE_VLAN_TYPE_PORT_TABLE	1
+#define HCLGE_DEF_VLAN_TYPE		0x8100
 	struct hnae3_handle *handle;
 	int ret;
 
@@ -3708,6 +3750,18 @@ static int hclge_init_vlan_config(struct hclge_dev *hdev)
 
 	ret = hclge_set_vlan_filter_ctrl(hdev, HCLGE_VLAN_TYPE_PORT_TABLE,
 					 true);
+
+	hdev->vlan_type_cfg.rx_in_fst_vlan_type = HCLGE_DEF_VLAN_TYPE;
+	hdev->vlan_type_cfg.rx_in_sec_vlan_type = HCLGE_DEF_VLAN_TYPE;
+	hdev->vlan_type_cfg.rx_ot_fst_vlan_type = HCLGE_DEF_VLAN_TYPE;
+	hdev->vlan_type_cfg.rx_ot_sec_vlan_type = HCLGE_DEF_VLAN_TYPE;
+	hdev->vlan_type_cfg.tx_ot_vlan_type = HCLGE_DEF_VLAN_TYPE;
+	hdev->vlan_type_cfg.tx_in_vlan_type = HCLGE_DEF_VLAN_TYPE;
+
+	ret = hclge_set_vlan_protocol_type(hdev);
+	if (ret)
+		return ret;
+
 	handle = &hdev->vport[0].nic;
 	ret = hclge_set_port_vlan_filter(handle, htons(ETH_P_8021Q), 0, false);
 
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.h b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.h
index edb10ad..0905ae5 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.h
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.h
@@ -388,6 +388,15 @@ struct hclge_hw_stats {
 	struct hclge_32_bit_stats   all_32_bit_stats;
 };
 
+struct hclge_vlan_type_cfg {
+	u16 rx_ot_fst_vlan_type;
+	u16 rx_ot_sec_vlan_type;
+	u16 rx_in_fst_vlan_type;
+	u16 rx_in_sec_vlan_type;
+	u16 tx_ot_vlan_type;
+	u16 tx_in_vlan_type;
+};
+
 struct hclge_dev {
 	struct pci_dev *pdev;
 	struct hnae3_ae_dev *ae_dev;
@@ -469,6 +478,8 @@ struct hclge_dev {
 	enum hclge_mta_dmac_sel_type mta_mac_sel_type;
 	bool enable_mta; /* Mutilcast filter enable */
 	bool accept_mta_mc; /* Whether accept mta filter multicast */
+
+	struct hclge_vlan_type_cfg vlan_type_cfg;
 };
 
 struct hclge_vport {
-- 
1.9.1
