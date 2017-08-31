From: Lipeng <lipeng321@huawei.com>
Subject: [PATCH net-next 2/8] net: hns3: update ring and vector map command
Date: Thu, 31 Aug 2017 21:39:03 +0800
Message-ID: <1504186749-8926-3-git-send-email-lipeng321@huawei.com>
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

Add INT_GL and VF id to vector configure when bind ring with vector.
INT_GL means Interrupt Gap Limiting.Vector id starts from 0 in each
VF, so the bind command must specify VF id.

Signed-off-by: Lipeng <lipeng321@huawei.com>
Signed-off-by: Mingguang Qu <qumingguang@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns3/hnae3.h        |   4 +
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h |   8 +-
 .../ethernet/hisilicon/hns3/hns3pf/hclge_main.c    | 105 ++++++++-------------
 .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c |   9 ++
 4 files changed, 60 insertions(+), 66 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hnae3.h b/drivers/net/ethernet/hisilicon/hns3/hnae3.h
index e23e028..3617372 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hnae3.h
+++ b/drivers/net/ethernet/hisilicon/hns3/hnae3.h
@@ -108,11 +108,15 @@ struct hnae3_vector_info {
 #define HNAE3_RING_TYPE_B 0
 #define HNAE3_RING_TYPE_TX 0
 #define HNAE3_RING_TYPE_RX 1
+#define HNAE3_RING_GL_IDX_B 0
+#define HNAE3_RING_GL_RX 0
+#define HNAE3_RING_GL_TX 1
 
 struct hnae3_ring_chain_node {
 	struct hnae3_ring_chain_node *next;
 	u32 tqp_index;
 	u32 flag;
+	u32 int_gl_idx;
 };
 
 #define HNAE3_IS_TX_RING(node) \
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h
index 91ae013..c2b613b 100644
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
index acc4016..3a8cb40 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
@@ -2346,6 +2346,13 @@ static int hclge_get_vector(struct hnae3_handle *handle, u16 vector_num,
 	return alloc;
 }
 
+static void hclge_free_vector(struct hclge_dev *hdev, int vector_id)
+{
+	hdev->vector_status[vector_id] = HCLGE_INVALID_VPORT;
+	hdev->num_msi_left += 1;
+	hdev->num_msi_used -= 1;
+}
+
 static int hclge_get_vector_index(struct hclge_dev *hdev, int vector)
 {
 	int i;
@@ -2672,19 +2679,21 @@ static int hclge_rss_init_hw(struct hclge_dev *hdev)
 	return ret;
 }
 
-int hclge_map_vport_ring_to_vector(struct hclge_vport *vport, int vector_id,
-				   struct hnae3_ring_chain_node *ring_chain)
+int hclge_bind_ring_with_vector(struct hclge_vport *vport,
+				int vector_id, bool en,
+				struct hnae3_ring_chain_node *ring_chain)
 {
 	struct hclge_dev *hdev = vport->back;
-	struct hclge_ctrl_vector_chain *req;
 	struct hnae3_ring_chain_node *node;
 	struct hclge_desc desc;
-	int ret;
+	struct hclge_ctrl_vector_chain *req
+		= (struct hclge_ctrl_vector_chain *)desc.data;
+	enum hclge_cmd_status status;
+	enum hclge_opcode_type op;
 	int i;
 
-	hclge_cmd_setup_basic_desc(&desc, HCLGE_OPC_ADD_RING_TO_VECTOR, false);
-
-	req = (struct hclge_ctrl_vector_chain *)desc.data;
+	op = en ? HCLGE_OPC_ADD_RING_TO_VECTOR : HCLGE_OPC_DEL_RING_TO_VECTOR;
+	hclge_cmd_setup_basic_desc(&desc, op, false);
 	req->int_vector_id = vector_id;
 
 	i = 0;
@@ -2694,17 +2703,21 @@ int hclge_map_vport_ring_to_vector(struct hclge_vport *vport, int vector_id,
 			       hnae_get_bit(node->flag, HNAE3_RING_TYPE_B));
 		hnae_set_field(req->tqp_type_and_id[i], HCLGE_TQP_ID_M,
 			       HCLGE_TQP_ID_S,	node->tqp_index);
+		hnae_set_field(req->tqp_type_and_id[i], HCLGE_INT_GL_IDX_M,
+			       HCLGE_INT_GL_IDX_S,
+			       hnae_get_bit(node->int_gl_idx,
+					    HNAE3_RING_GL_IDX_B));
 		req->tqp_type_and_id[i] = cpu_to_le16(req->tqp_type_and_id[i]);
-
 		if (++i >= HCLGE_VECTOR_ELEMENTS_PER_CMD) {
 			req->int_cause_num = HCLGE_VECTOR_ELEMENTS_PER_CMD;
+			req->vfid = vport->vport_id;
 
-			ret = hclge_cmd_send(&hdev->hw, &desc, 1);
-			if (ret) {
+			status = hclge_cmd_send(&hdev->hw, &desc, 1);
+			if (status) {
 				dev_err(&hdev->pdev->dev,
 					"Map TQP fail, status is %d.\n",
-					ret);
-				return ret;
+					status);
+				return -EIO;
 			}
 			i = 0;
 
@@ -2717,12 +2730,12 @@ int hclge_map_vport_ring_to_vector(struct hclge_vport *vport, int vector_id,
 
 	if (i > 0) {
 		req->int_cause_num = i;
-
-		ret = hclge_cmd_send(&hdev->hw, &desc, 1);
-		if (ret) {
+		req->vfid = vport->vport_id;
+		status = hclge_cmd_send(&hdev->hw, &desc, 1);
+		if (status) {
 			dev_err(&hdev->pdev->dev,
-				"Map TQP fail, status is %d.\n", ret);
-			return ret;
+				"Map TQP fail, status is %d.\n", status);
+			return -EIO;
 		}
 	}
 
@@ -2744,7 +2757,7 @@ int hclge_map_handle_ring_to_vector(struct hnae3_handle *handle,
 		return vector_id;
 	}
 
-	return hclge_map_vport_ring_to_vector(vport, vector_id, ring_chain);
+	return hclge_bind_ring_with_vector(vport, vector_id, true, ring_chain);
 }
 
 static int hclge_unmap_ring_from_vector(
@@ -2753,11 +2766,7 @@ static int hclge_unmap_ring_from_vector(
 {
 	struct hclge_vport *vport = hclge_get_vport(handle);
 	struct hclge_dev *hdev = vport->back;
-	struct hclge_ctrl_vector_chain *req;
-	struct hnae3_ring_chain_node *node;
-	struct hclge_desc desc;
-	int i, vector_id;
-	int ret;
+	int vector_id, ret;
 
 	vector_id = hclge_get_vector_index(hdev, vector);
 	if (vector_id < 0) {
@@ -2766,49 +2775,17 @@ static int hclge_unmap_ring_from_vector(
 		return vector_id;
 	}
 
-	hclge_cmd_setup_basic_desc(&desc, HCLGE_OPC_DEL_RING_TO_VECTOR, false);
-
-	req = (struct hclge_ctrl_vector_chain *)desc.data;
-	req->int_vector_id = vector_id;
-
-	i = 0;
-	for (node = ring_chain; node; node = node->next) {
-		hnae_set_field(req->tqp_type_and_id[i], HCLGE_INT_TYPE_M,
-			       HCLGE_INT_TYPE_S,
-			       hnae_get_bit(node->flag, HNAE3_RING_TYPE_B));
-		hnae_set_field(req->tqp_type_and_id[i], HCLGE_TQP_ID_M,
-			       HCLGE_TQP_ID_S,	node->tqp_index);
-
-		req->tqp_type_and_id[i] = cpu_to_le16(req->tqp_type_and_id[i]);
-
-		if (++i >= HCLGE_VECTOR_ELEMENTS_PER_CMD) {
-			req->int_cause_num = HCLGE_VECTOR_ELEMENTS_PER_CMD;
-
-			ret = hclge_cmd_send(&hdev->hw, &desc, 1);
-			if (ret) {
-				dev_err(&hdev->pdev->dev,
-					"Unmap TQP fail, status is %d.\n",
-					ret);
-				return ret;
-			}
-			i = 0;
-			hclge_cmd_setup_basic_desc(&desc,
-						   HCLGE_OPC_ADD_RING_TO_VECTOR,
-						   false);
-			req->int_vector_id = vector_id;
-		}
+	ret = hclge_bind_ring_with_vector(vport, vector_id, false, ring_chain);
+	if (ret) {
+		dev_err(&handle->pdev->dev,
+			"Unmap ring from vector fail. vectorid=%d, ret =%d\n",
+			vector_id,
+			ret);
+		return ret;
 	}
 
-	if (i > 0) {
-		req->int_cause_num = i;
-
-		ret = hclge_cmd_send(&hdev->hw, &desc, 1);
-		if (ret) {
-			dev_err(&hdev->pdev->dev,
-				"Unmap TQP fail, status is %d.\n", ret);
-			return ret;
-		}
-	}
+	/* Free this MSIX or MSI vector */
+	hclge_free_vector(hdev, vector_id);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
index 1c3e294..2e3c287 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
@@ -2276,6 +2276,8 @@ static int hns3_get_vector_ring_chain(struct hns3_enet_tqp_vector *tqp_vector,
 		cur_chain->tqp_index = tx_ring->tqp->tqp_index;
 		hnae_set_bit(cur_chain->flag, HNAE3_RING_TYPE_B,
 			     HNAE3_RING_TYPE_TX);
+		hnae_set_bit(cur_chain->int_gl_idx, HNAE3_RING_GL_IDX_B,
+			     HNAE3_RING_GL_TX);
 
 		cur_chain->next = NULL;
 
@@ -2291,6 +2293,8 @@ static int hns3_get_vector_ring_chain(struct hns3_enet_tqp_vector *tqp_vector,
 			chain->tqp_index = tx_ring->tqp->tqp_index;
 			hnae_set_bit(chain->flag, HNAE3_RING_TYPE_B,
 				     HNAE3_RING_TYPE_TX);
+			hnae_set_bit(cur_chain->int_gl_idx, HNAE3_RING_GL_IDX_B,
+				     HNAE3_RING_GL_TX);
 
 			cur_chain = chain;
 		}
@@ -2302,6 +2306,8 @@ static int hns3_get_vector_ring_chain(struct hns3_enet_tqp_vector *tqp_vector,
 		cur_chain->tqp_index = rx_ring->tqp->tqp_index;
 		hnae_set_bit(cur_chain->flag, HNAE3_RING_TYPE_B,
 			     HNAE3_RING_TYPE_RX);
+		hnae_set_bit(cur_chain->int_gl_idx, HNAE3_RING_GL_IDX_B,
+			     HNAE3_RING_GL_RX);
 
 		rx_ring = rx_ring->next;
 	}
@@ -2315,6 +2321,9 @@ static int hns3_get_vector_ring_chain(struct hns3_enet_tqp_vector *tqp_vector,
 		chain->tqp_index = rx_ring->tqp->tqp_index;
 		hnae_set_bit(chain->flag, HNAE3_RING_TYPE_B,
 			     HNAE3_RING_TYPE_RX);
+		hnae_set_bit(cur_chain->int_gl_idx, HNAE3_RING_GL_IDX_B,
+			     HNAE3_RING_GL_RX);
+
 		cur_chain = chain;
 
 		rx_ring = rx_ring->next;
-- 
1.9.1
