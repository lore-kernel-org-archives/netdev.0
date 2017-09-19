From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH net 3/7] net: hns3: Fix ring and vector map command
Date: Tue, 19 Sep 2017 02:06:24 +0100
Message-ID: <20170919010628.175732-4-salil.mehta@huawei.com>
References: <20170919010628.175732-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <lipeng321@huawei.com>, <mehta.salil.lnk@gmail.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linux-rdma@vger.kernel.org>, <linuxarm@huawei.com>,
        Mingguang Qu <qumingguang@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170919010628.175732-1-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lipeng <lipeng321@huawei.com>

This patch add INT_GL and VF id to vector configure when bind ring
with vector. INT_GL means Interrupt Gap Limiting. Vector id starts
from 0 in each VF, so the bind command must specify VF id.

Signed-off-by: Lipeng <lipeng321@huawei.com>
Signed-off-by: Mingguang Qu <qumingguang@huawei.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h  | 8 ++++++--
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c | 8 ++++++++
 2 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h
index 91ae0135ee50..c2b613b40509 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h
@@ -238,7 +238,7 @@ struct hclge_tqp_map {
 	u8 rsv[18];
 };
 
-#define HCLGE_VECTOR_ELEMENTS_PER_CMD	11
+#define HCLGE_VECTOR_ELEMENTS_PER_CMD	10
 
 enum hclge_int_type {
 	HCLGE_INT_TX,
@@ -252,8 +252,12 @@ struct hclge_ctrl_vector_chain {
 #define HCLGE_INT_TYPE_S	0
 #define HCLGE_INT_TYPE_M	0x3
 #define HCLGE_TQP_ID_S		2
-#define HCLGE_TQP_ID_M		(0x3fff << HCLGE_TQP_ID_S)
+#define HCLGE_TQP_ID_M		(0x7ff << HCLGE_TQP_ID_S)
+#define HCLGE_INT_GL_IDX_S	13
+#define HCLGE_INT_GL_IDX_M	(0x3 << HCLGE_INT_GL_IDX_S)
 	__le16 tqp_type_and_id[HCLGE_VECTOR_ELEMENTS_PER_CMD];
+	u8 vfid;
+	u8 rsv;
 };
 
 #define HCLGE_TC_NUM		8
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
index e324bc6e9f4f..eafd9c678162 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
@@ -2680,7 +2680,11 @@ int hclge_map_vport_ring_to_vector(struct hclge_vport *vport, int vector_id,
 			       hnae_get_bit(node->flag, HNAE3_RING_TYPE_B));
 		hnae_set_field(req->tqp_type_and_id[i], HCLGE_TQP_ID_M,
 			       HCLGE_TQP_ID_S,	node->tqp_index);
+		hnae_set_field(req->tqp_type_and_id[i], HCLGE_INT_GL_IDX_M,
+			       HCLGE_INT_GL_IDX_S,
+			       hnae_get_bit(node->flag, HNAE3_RING_TYPE_B));
 		req->tqp_type_and_id[i] = cpu_to_le16(req->tqp_type_and_id[i]);
+		req->vfid = vport->vport_id;
 
 		if (++i >= HCLGE_VECTOR_ELEMENTS_PER_CMD) {
 			req->int_cause_num = HCLGE_VECTOR_ELEMENTS_PER_CMD;
@@ -2764,8 +2768,12 @@ static int hclge_unmap_ring_from_vector(
 			       hnae_get_bit(node->flag, HNAE3_RING_TYPE_B));
 		hnae_set_field(req->tqp_type_and_id[i], HCLGE_TQP_ID_M,
 			       HCLGE_TQP_ID_S,	node->tqp_index);
+		hnae_set_field(req->tqp_type_and_id[i], HCLGE_INT_GL_IDX_M,
+			       HCLGE_INT_GL_IDX_S,
+			       hnae_get_bit(node->flag, HNAE3_RING_TYPE_B));
 
 		req->tqp_type_and_id[i] = cpu_to_le16(req->tqp_type_and_id[i]);
+		req->vfid = vport->vport_id;
 
 		if (++i >= HCLGE_VECTOR_ELEMENTS_PER_CMD) {
 			req->int_cause_num = HCLGE_VECTOR_ELEMENTS_PER_CMD;
-- 
2.11.0
