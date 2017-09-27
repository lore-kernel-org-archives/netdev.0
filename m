From: Yunsheng Lin <linyunsheng@huawei.com>
Subject: [PATCH v3 net-next 03/10] net: hns3: Add support for PFC setting in TM module
Date: Wed, 27 Sep 2017 09:45:25 +0800
Message-ID: <1506476732-128130-4-git-send-email-linyunsheng@huawei.com>
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

This patch add a pfc_pause_en cmd, and use it to configure
PFC option according to fc_mode in hdev->tm_info.

Signed-off-by: Yunsheng Lin <linyunsheng@huawei.com>
---
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.c  | 68 ++++++++++++++++++++--
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.h  |  5 ++
 2 files changed, 68 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.c
index 73a75d7..0b4b5d9 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.c
@@ -124,6 +124,20 @@ static int hclge_mac_pause_en_cfg(struct hclge_dev *hdev, bool tx, bool rx)
 	return hclge_cmd_send(&hdev->hw, &desc, 1);
 }
 
+static int hclge_pfc_pause_en_cfg(struct hclge_dev *hdev, u8 tx_rx_bitmap,
+				  u8 pfc_bitmap)
+{
+	struct hclge_desc desc;
+	struct hclge_pfc_en_cmd *pfc = (struct hclge_pfc_en_cmd *)&desc.data;
+
+	hclge_cmd_setup_basic_desc(&desc, HCLGE_OPC_CFG_PFC_PAUSE_EN, false);
+
+	pfc->tx_rx_en_bitmap = tx_rx_bitmap;
+	pfc->pri_en_bitmap = pfc_bitmap;
+
+	return hclge_cmd_send(&hdev->hw, &desc, 1);
+}
+
 static int hclge_fill_pri_array(struct hclge_dev *hdev, u8 *pri, u8 pri_id)
 {
 	u8 tc;
@@ -969,20 +983,64 @@ static int hclge_tm_schd_setup_hw(struct hclge_dev *hdev)
 	return hclge_tm_schd_mode_hw(hdev);
 }
 
+static int hclge_pfc_setup_hw(struct hclge_dev *hdev)
+{
+	u8 enable_bitmap = 0;
+
+	if (hdev->tm_info.fc_mode == HCLGE_FC_PFC)
+		enable_bitmap = HCLGE_TX_MAC_PAUSE_EN_MSK |
+				HCLGE_RX_MAC_PAUSE_EN_MSK;
+
+	return hclge_pfc_pause_en_cfg(hdev, enable_bitmap,
+				      hdev->tm_info.hw_pfc_map);
+}
+
+static int hclge_mac_pause_setup_hw(struct hclge_dev *hdev)
+{
+	bool tx_en, rx_en;
+
+	switch (hdev->tm_info.fc_mode) {
+	case HCLGE_FC_NONE:
+		tx_en = false;
+		rx_en = false;
+		break;
+	case HCLGE_FC_RX_PAUSE:
+		tx_en = false;
+		rx_en = true;
+		break;
+	case HCLGE_FC_TX_PAUSE:
+		tx_en = true;
+		rx_en = false;
+		break;
+	case HCLGE_FC_FULL:
+		tx_en = true;
+		rx_en = true;
+		break;
+	default:
+		tx_en = true;
+		rx_en = true;
+	}
+
+	return hclge_mac_pause_en_cfg(hdev, tx_en, rx_en);
+}
+
 int hclge_pause_setup_hw(struct hclge_dev *hdev)
 {
-	bool en = hdev->tm_info.fc_mode != HCLGE_FC_PFC;
 	int ret;
 	u8 i;
 
-	ret = hclge_mac_pause_en_cfg(hdev, en, en);
-	if (ret)
-		return ret;
+	if (hdev->tm_info.fc_mode != HCLGE_FC_PFC)
+		return hclge_mac_pause_setup_hw(hdev);
 
-	/* Only DCB-supported dev supports qset back pressure setting */
+	/* Only DCB-supported dev supports qset back pressure and pfc cmd */
 	if (!hnae3_dev_dcb_supported(hdev))
 		return 0;
 
+	/* When MAC is GE Mode, hdev does not support pfc setting */
+	ret = hclge_pfc_setup_hw(hdev);
+	if (ret)
+		dev_warn(&hdev->pdev->dev, "set pfc pause failed:%d\n", ret);
+
 	for (i = 0; i < hdev->tm_info.num_tc; i++) {
 		ret = hclge_tm_qs_bp_cfg(hdev, i);
 		if (ret)
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.h b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.h
index 85158b0..8ecd83c 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.h
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.h
@@ -94,6 +94,11 @@ struct hclge_bp_to_qs_map_cmd {
 	u32 rsvd1;
 };
 
+struct hclge_pfc_en_cmd {
+	u8 tx_rx_en_bitmap;
+	u8 pri_en_bitmap;
+};
+
 #define hclge_tm_set_field(dest, string, val) \
 			hnae_set_field((dest), (HCLGE_TM_SHAP_##string##_MSK), \
 				       (HCLGE_TM_SHAP_##string##_LSH), val)
-- 
1.9.1
