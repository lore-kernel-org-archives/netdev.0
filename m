From: Lipeng <lipeng321@huawei.com>
Subject: [PATCH net-next 3/8] net: hns3: set default mac vlan mask
Date: Thu, 31 Aug 2017 21:39:04 +0800
Message-ID: <1504186749-8926-4-git-send-email-lipeng321@huawei.com>
References: <1504186749-8926-1-git-send-email-lipeng321@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linuxarm@huawei.com>, <yisen.zhuang@huawei.com>,
        <salil.mehta@huawei.com>, <lipeng321@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1504186749-8926-1-git-send-email-lipeng321@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add the mask configuration of the MAC_VLAN table. Command
HCLGE_OPC_MAC_VLAN_MASK_SET is used to add/read the mask
configuration of the MAC_VLAN (u/m vlan) table. Set default mask
as {0x00, 0x00, 0x00, 0x00, 0x00, 0x00} means that all bits of
mac_vlan are not masked.

Signed-off-by: Mingguang Qu <qumingguang@huawei.com>
Signed-off-by: Lipeng <lipeng321@huawei.com>
---
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h |  9 +++++
 .../ethernet/hisilicon/hns3/hns3pf/hclge_main.c    | 43 +++++++++++++++++++++-
 2 files changed, 51 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h
index c2b613b..dd8e513 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h
@@ -186,6 +186,7 @@ enum hclge_opcode_type {
 	HCLGE_OPC_MAC_VLAN_INSERT	    = 0x1003,
 	HCLGE_OPC_MAC_ETHTYPE_ADD	    = 0x1010,
 	HCLGE_OPC_MAC_ETHTYPE_REMOVE	= 0x1011,
+	HCLGE_OPC_MAC_VLAN_MASK_SET	= 0x1012,
 
 	/* Multicast linear table cmd */
 	HCLGE_OPC_MTA_MAC_MODE_CFG	    = 0x1020,
@@ -575,6 +576,14 @@ struct hclge_mac_vlan_tbl_entry {
 	u8      rsv2[6];
 };
 
+#define HCLGE_VLAN_MASK_EN_B		0x0
+struct hclge_mac_vlan_mask_entry {
+	u8 rsv0[2];
+	u8 vlan_mask;
+	u8 rsv1;
+	u8 mac_mask[6];
+	u8 rsv2[14];
+};
 #define HCLGE_CFG_MTA_MAC_SEL_S		0x0
 #define HCLGE_CFG_MTA_MAC_SEL_M		(0x3 << HCLGE_CFG_MTA_MAC_SEL_S)
 #define HCLGE_CFG_MTA_MAC_EN_B		0x7
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
index 3a8cb40..5d49856 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
@@ -2089,8 +2089,37 @@ static int hclge_get_autoneg(struct hnae3_handle *handle)
 	return hdev->hw.mac.autoneg;
 }
 
+static int hclge_set_default_mac_vlan_mask(struct hclge_dev *hdev,
+					   bool mask_vlan,
+					   u8 *mac_mask)
+{
+	struct hclge_mac_vlan_mask_entry *req;
+	enum hclge_cmd_status status;
+	struct hclge_desc desc;
+	int i;
+
+	req = (struct hclge_mac_vlan_mask_entry *)desc.data;
+	hclge_cmd_setup_basic_desc(&desc, HCLGE_OPC_MAC_VLAN_MASK_SET, false);
+
+	hnae_set_bit(req->vlan_mask, HCLGE_VLAN_MASK_EN_B,
+		     mask_vlan);
+	for (i = 0; i < ETH_ALEN; i++)
+		req->mac_mask[i] = mac_mask[i];
+
+	status = hclge_cmd_send(&hdev->hw, &desc, 1);
+	if (status) {
+		dev_err(&hdev->pdev->dev,
+			"Config mac_vlan_mask failed for cmd_send, ret =%d.\n",
+			status);
+		return -EIO;
+	}
+
+	return 0;
+}
+
 static int hclge_mac_init(struct hclge_dev *hdev)
 {
+	u8 mac_mask[ETH_ALEN] = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
 	struct hclge_mac *mac = &hdev->hw.mac;
 	int ret;
 
@@ -2124,7 +2153,19 @@ static int hclge_mac_init(struct hclge_dev *hdev)
 		return ret;
 	}
 
-	return hclge_cfg_func_mta_filter(hdev, 0, hdev->accept_mta_mc);
+	ret = hclge_cfg_func_mta_filter(hdev, 0, hdev->accept_mta_mc);
+	if (ret) {
+		dev_err(&hdev->pdev->dev,
+			"set mta filter mode fail ret=%d\n", ret);
+		return ret;
+	}
+
+	ret = hclge_set_default_mac_vlan_mask(hdev, true, mac_mask);
+	if (ret)
+		dev_err(&hdev->pdev->dev,
+			"set default mac_vlan_mask fail ret=%d\n", ret);
+
+	return ret;
 }
 
 static void hclge_task_schedule(struct hclge_dev *hdev)
-- 
1.9.1
