From: Yunsheng Lin <linyunsheng@huawei.com>
Subject: [PATCH v3 net-next 04/10] net: hns3: Add support for port shaper setting in TM module
Date: Wed, 27 Sep 2017 09:45:26 +0800
Message-ID: <1506476732-128130-5-git-send-email-linyunsheng@huawei.com>
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

This patch add a tm_port_shaper cmd and set port shaper
to HCLGE_ETHER_MAX_RATE on TM initialization process.

Signed-off-by: Yunsheng Lin <linyunsheng@huawei.com>
---
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.c  | 32 ++++++++++++++++++++++
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.h  |  4 +++
 2 files changed, 36 insertions(+)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.c
index 0b4b5d9..f79cebd 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.c
@@ -301,6 +301,34 @@ static int hclge_tm_pg_shapping_cfg(struct hclge_dev *hdev,
 	return hclge_cmd_send(&hdev->hw, &desc, 1);
 }
 
+static int hclge_tm_port_shaper_cfg(struct hclge_dev *hdev)
+{
+	struct hclge_port_shapping_cmd *shap_cfg_cmd;
+	struct hclge_desc desc;
+	u32 shapping_para = 0;
+	u8 ir_u, ir_b, ir_s;
+	int ret;
+
+	ret = hclge_shaper_para_calc(HCLGE_ETHER_MAX_RATE,
+				     HCLGE_SHAPER_LVL_PORT,
+				     &ir_b, &ir_u, &ir_s);
+	if (ret)
+		return ret;
+
+	hclge_cmd_setup_basic_desc(&desc, HCLGE_OPC_TM_PORT_SHAPPING, false);
+	shap_cfg_cmd = (struct hclge_port_shapping_cmd *)desc.data;
+
+	hclge_tm_set_field(shapping_para, IR_B, ir_b);
+	hclge_tm_set_field(shapping_para, IR_U, ir_u);
+	hclge_tm_set_field(shapping_para, IR_S, ir_s);
+	hclge_tm_set_field(shapping_para, BS_B, HCLGE_SHAPER_BS_U_DEF);
+	hclge_tm_set_field(shapping_para, BS_S, HCLGE_SHAPER_BS_S_DEF);
+
+	shap_cfg_cmd->port_shapping_para = cpu_to_le32(shapping_para);
+
+	return hclge_cmd_send(&hdev->hw, &desc, 1);
+}
+
 static int hclge_tm_pri_shapping_cfg(struct hclge_dev *hdev,
 				     enum hclge_shap_bucket bucket, u8 pri_id,
 				     u8 ir_b, u8 ir_u, u8 ir_s,
@@ -864,6 +892,10 @@ static int hclge_tm_shaper_cfg(struct hclge_dev *hdev)
 {
 	int ret;
 
+	ret = hclge_tm_port_shaper_cfg(hdev);
+	if (ret)
+		return ret;
+
 	ret = hclge_tm_pg_shaper_cfg(hdev);
 	if (ret)
 		return ret;
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.h b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.h
index 8ecd83c..19a01e4 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.h
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.h
@@ -99,6 +99,10 @@ struct hclge_pfc_en_cmd {
 	u8 pri_en_bitmap;
 };
 
+struct hclge_port_shapping_cmd {
+	__le32 port_shapping_para;
+};
+
 #define hclge_tm_set_field(dest, string, val) \
 			hnae_set_field((dest), (HCLGE_TM_SHAP_##string##_MSK), \
 				       (HCLGE_TM_SHAP_##string##_LSH), val)
-- 
1.9.1
