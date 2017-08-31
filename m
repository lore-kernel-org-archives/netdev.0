From: Lipeng <lipeng321@huawei.com>
Subject: [PATCH net-next 6/8] net: hns3: fix bug of reuse command description
Date: Thu, 31 Aug 2017 21:39:07 +0800
Message-ID: <1504186749-8926-7-git-send-email-lipeng321@huawei.com>
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

When reuse command description, the in/out bit and W/R bit of the
command flag should be both updated. The old code did not update
in/out bit, this patch fix it.

Signed-off-by: Mingguang Qu <qumingguang@huawei.com>
Signed-off-by: Lipeng <lipeng321@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.c  | 9 +++++++++
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h  | 2 +-
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c | 6 +++---
 3 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.c
index 8b511e6..fe2b116 100644
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
index b841df1..5887418 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h
@@ -753,7 +753,7 @@ static inline u32 hclge_read_reg(u8 __iomem *base, u32 reg)
 int hclge_cmd_send(struct hclge_hw *hw, struct hclge_desc *desc, int num);
 void hclge_cmd_setup_basic_desc(struct hclge_desc *desc,
 				enum hclge_opcode_type opcode, bool is_read);
-
+void hclge_cmd_reuse_desc(struct hclge_desc *desc, bool is_read);
 int hclge_cmd_set_promisc_mode(struct hclge_dev *hdev,
 			       struct hclge_promisc_param *param);
 
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
index f2ea88f..12be24f 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
@@ -3302,11 +3302,11 @@ static int hclge_add_mac_vlan_tbl(struct hclge_vport *vport,
 							   resp_code,
 							   HCLGE_MAC_VLAN_ADD);
 	} else {
-		mc_desc[0].flag &= cpu_to_le16(~HCLGE_CMD_FLAG_WR);
+		hclge_cmd_reuse_desc(&mc_desc[0], false);
 		mc_desc[0].flag |= cpu_to_le16(HCLGE_CMD_FLAG_NEXT);
-		mc_desc[1].flag &= cpu_to_le16(~HCLGE_CMD_FLAG_WR);
+		hclge_cmd_reuse_desc(&mc_desc[1], false);
 		mc_desc[1].flag |= cpu_to_le16(HCLGE_CMD_FLAG_NEXT);
-		mc_desc[2].flag &= cpu_to_le16(~HCLGE_CMD_FLAG_WR);
+		hclge_cmd_reuse_desc(&mc_desc[2], false);
 		mc_desc[2].flag &= cpu_to_le16(~HCLGE_CMD_FLAG_NEXT);
 		memcpy(mc_desc[0].data, req,
 		       sizeof(struct hclge_mac_vlan_tbl_entry));
-- 
1.9.1
