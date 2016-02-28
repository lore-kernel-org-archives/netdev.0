From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 1/4] qed: Semantic refactoring of interrupt code
Date: Sun, 28 Feb 2016 12:26:52 +0200
Message-ID: <1456655215-16345-2-git-send-email-Yuval.Mintz@qlogic.com>
References: <1456655215-16345-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:37119 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757041AbcB1K1E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2016 05:27:04 -0500
In-Reply-To: <1456655215-16345-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dev.c  |   6 +-
 drivers/net/ethernet/qlogic/qed/qed_int.c  | 155 ++++++++++++++++-------------
 drivers/net/ethernet/qlogic/qed/qed_int.h  |   6 +-
 drivers/net/ethernet/qlogic/qed/qed_main.c |  15 +--
 include/linux/qed/qed_if.h                 |   6 ++
 5 files changed, 111 insertions(+), 77 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index acfe7be..d9a5175 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -1011,13 +1011,17 @@ static void qed_hw_get_resc(struct qed_hwfn *p_hwfn)
 {
 	u32 *resc_start = p_hwfn->hw_info.resc_start;
 	u32 *resc_num = p_hwfn->hw_info.resc_num;
+	struct qed_sb_cnt_info sb_cnt_info;
 	int num_funcs, i;
 
 	num_funcs = MAX_NUM_PFS_BB;
 
+	memset(&sb_cnt_info, 0, sizeof(sb_cnt_info));
+	qed_int_get_num_sbs(p_hwfn, &sb_cnt_info);
+
 	resc_num[QED_SB] = min_t(u32,
 				 (MAX_SB_PER_PATH_BB / num_funcs),
-				 qed_int_get_num_sbs(p_hwfn, NULL));
+				 sb_cnt_info.sb_cnt);
 	resc_num[QED_L2_QUEUE] = MAX_NUM_L2_QUEUES_BB / num_funcs;
 	resc_num[QED_VPORT] = MAX_NUM_VPORTS_BB / num_funcs;
 	resc_num[QED_RSS_ENG] = ETH_RSS_ENGINE_NUM_BB / num_funcs;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_int.c b/drivers/net/ethernet/qlogic/qed/qed_int.c
index fa73daa..7fd1be6 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_int.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_int.c
@@ -343,17 +343,17 @@ void qed_int_sp_dpc(unsigned long hwfn_cookie)
 
 static void qed_int_sb_attn_free(struct qed_hwfn *p_hwfn)
 {
-	struct qed_dev *cdev   = p_hwfn->cdev;
-	struct qed_sb_attn_info *p_sb   = p_hwfn->p_sb_attn;
-
-	if (p_sb) {
-		if (p_sb->sb_attn)
-			dma_free_coherent(&cdev->pdev->dev,
-					  SB_ATTN_ALIGNED_SIZE(p_hwfn),
-					  p_sb->sb_attn,
-					  p_sb->sb_phys);
-		kfree(p_sb);
-	}
+	struct qed_sb_attn_info *p_sb = p_hwfn->p_sb_attn;
+
+	if (!p_sb)
+		return;
+
+	if (p_sb->sb_attn)
+		dma_free_coherent(&p_hwfn->cdev->pdev->dev,
+				  SB_ATTN_ALIGNED_SIZE(p_hwfn),
+				  p_sb->sb_attn,
+				  p_sb->sb_phys);
+	kfree(p_sb);
 }
 
 static void qed_int_sb_attn_setup(struct qed_hwfn *p_hwfn,
@@ -433,6 +433,7 @@ void qed_init_cau_sb_entry(struct qed_hwfn *p_hwfn,
 			   u16 vf_number,
 			   u8 vf_valid)
 {
+	struct qed_dev *cdev = p_hwfn->cdev;
 	u32 cau_state;
 
 	memset(p_sb_entry, 0, sizeof(*p_sb_entry));
@@ -451,14 +452,12 @@ void qed_init_cau_sb_entry(struct qed_hwfn *p_hwfn,
 
 	cau_state = CAU_HC_DISABLE_STATE;
 
-	if (p_hwfn->cdev->int_coalescing_mode == QED_COAL_MODE_ENABLE) {
+	if (cdev->int_coalescing_mode == QED_COAL_MODE_ENABLE) {
 		cau_state = CAU_HC_ENABLE_STATE;
-		if (!p_hwfn->cdev->rx_coalesce_usecs)
-			p_hwfn->cdev->rx_coalesce_usecs =
-				QED_CAU_DEF_RX_USECS;
-		if (!p_hwfn->cdev->tx_coalesce_usecs)
-			p_hwfn->cdev->tx_coalesce_usecs =
-				QED_CAU_DEF_TX_USECS;
+		if (!cdev->rx_coalesce_usecs)
+			cdev->rx_coalesce_usecs = QED_CAU_DEF_RX_USECS;
+		if (!cdev->tx_coalesce_usecs)
+			cdev->tx_coalesce_usecs = QED_CAU_DEF_TX_USECS;
 	}
 
 	SET_FIELD(p_sb_entry->data, CAU_SB_ENTRY_STATE0, cau_state);
@@ -638,8 +637,10 @@ int qed_int_sb_release(struct qed_hwfn *p_hwfn,
 	sb_info->sb_ack = 0;
 	memset(sb_info->sb_virt, 0, sizeof(*sb_info->sb_virt));
 
-	p_hwfn->sbs_info[sb_id] = NULL;
-	p_hwfn->num_sbs--;
+	if (p_hwfn->sbs_info[sb_id] != NULL) {
+		p_hwfn->sbs_info[sb_id] = NULL;
+		p_hwfn->num_sbs--;
+	}
 
 	return 0;
 }
@@ -648,14 +649,15 @@ static void qed_int_sp_sb_free(struct qed_hwfn *p_hwfn)
 {
 	struct qed_sb_sp_info *p_sb = p_hwfn->p_sp_sb;
 
-	if (p_sb) {
-		if (p_sb->sb_info.sb_virt)
-			dma_free_coherent(&p_hwfn->cdev->pdev->dev,
-					  SB_ALIGNED_SIZE(p_hwfn),
-					  p_sb->sb_info.sb_virt,
-					  p_sb->sb_info.sb_phys);
-		kfree(p_sb);
-	}
+	if (!p_sb)
+		return;
+
+	if (p_sb->sb_info.sb_virt)
+		dma_free_coherent(&p_hwfn->cdev->pdev->dev,
+				  SB_ALIGNED_SIZE(p_hwfn),
+				  p_sb->sb_info.sb_virt,
+				  p_sb->sb_info.sb_phys);
+	kfree(p_sb);
 }
 
 static int qed_int_sp_sb_alloc(struct qed_hwfn *p_hwfn,
@@ -718,36 +720,36 @@ int qed_int_register_cb(struct qed_hwfn *p_hwfn,
 			__le16 **p_fw_cons)
 {
 	struct qed_sb_sp_info *p_sp_sb = p_hwfn->p_sp_sb;
-	int qed_status = -ENOMEM;
+	int rc = -ENOMEM;
 	u8 pi;
 
 	/* Look for a free index */
 	for (pi = 0; pi < ARRAY_SIZE(p_sp_sb->pi_info_arr); pi++) {
-		if (!p_sp_sb->pi_info_arr[pi].comp_cb) {
-			p_sp_sb->pi_info_arr[pi].comp_cb = comp_cb;
-			p_sp_sb->pi_info_arr[pi].cookie = cookie;
-			*sb_idx = pi;
-			*p_fw_cons = &p_sp_sb->sb_info.sb_virt->pi_array[pi];
-			qed_status = 0;
-			break;
-		}
+		if (p_sp_sb->pi_info_arr[pi].comp_cb)
+			continue;
+
+		p_sp_sb->pi_info_arr[pi].comp_cb = comp_cb;
+		p_sp_sb->pi_info_arr[pi].cookie = cookie;
+		*sb_idx = pi;
+		*p_fw_cons = &p_sp_sb->sb_info.sb_virt->pi_array[pi];
+		rc = 0;
+		break;
 	}
 
-	return qed_status;
+	return rc;
 }
 
 int qed_int_unregister_cb(struct qed_hwfn *p_hwfn, u8 pi)
 {
 	struct qed_sb_sp_info *p_sp_sb = p_hwfn->p_sp_sb;
-	int qed_status = -ENOMEM;
 
-	if (p_sp_sb->pi_info_arr[pi].comp_cb) {
-		p_sp_sb->pi_info_arr[pi].comp_cb = NULL;
-		p_sp_sb->pi_info_arr[pi].cookie = NULL;
-		qed_status = 0;
-	}
+	if (p_sp_sb->pi_info_arr[pi].comp_cb == NULL)
+		return -ENOMEM;
 
-	return qed_status;
+	p_sp_sb->pi_info_arr[pi].comp_cb = NULL;
+	p_sp_sb->pi_info_arr[pi].cookie = NULL;
+
+	return 0;
 }
 
 u16 qed_int_get_sp_sb_id(struct qed_hwfn *p_hwfn)
@@ -937,6 +939,39 @@ void qed_int_igu_init_pure_rt(struct qed_hwfn *p_hwfn,
 	}
 }
 
+static u32 qed_int_igu_read_cam_block(struct qed_hwfn	*p_hwfn,
+				      struct qed_ptt	*p_ptt,
+				      u16		sb_id)
+{
+	u32 val = qed_rd(p_hwfn, p_ptt,
+			 IGU_REG_MAPPING_MEMORY +
+			 sizeof(u32) * sb_id);
+	struct qed_igu_block *p_block;
+
+	p_block = &p_hwfn->hw_info.p_igu_info->igu_map.igu_blocks[sb_id];
+
+	/* stop scanning when hit first invalid PF entry */
+	if (!GET_FIELD(val, IGU_MAPPING_LINE_VALID) &&
+	    GET_FIELD(val, IGU_MAPPING_LINE_PF_VALID))
+		goto out;
+
+	/* Fill the block information */
+	p_block->status		= QED_IGU_STATUS_VALID;
+	p_block->function_id	= GET_FIELD(val,
+					    IGU_MAPPING_LINE_FUNCTION_NUMBER);
+	p_block->is_pf		= GET_FIELD(val, IGU_MAPPING_LINE_PF_VALID);
+	p_block->vector_number	= GET_FIELD(val,
+					    IGU_MAPPING_LINE_VECTOR_NUMBER);
+
+	DP_VERBOSE(p_hwfn, NETIF_MSG_INTR,
+		   "IGU_BLOCK: [SB 0x%04x, Value in CAM 0x%08x] func_id = %d is_pf = %d vector_num = 0x%x\n",
+		   sb_id, val, p_block->function_id,
+		   p_block->is_pf, p_block->vector_number);
+
+out:
+	return val;
+}
+
 int qed_int_igu_read_cam(struct qed_hwfn *p_hwfn,
 			 struct qed_ptt *p_ptt)
 {
@@ -963,26 +998,13 @@ int qed_int_igu_read_cam(struct qed_hwfn *p_hwfn,
 	     sb_id++) {
 		blk = &p_igu_info->igu_map.igu_blocks[sb_id];
 
-		val = qed_rd(p_hwfn, p_ptt,
-			     IGU_REG_MAPPING_MEMORY + sizeof(u32) * sb_id);
+		val	= qed_int_igu_read_cam_block(p_hwfn, p_ptt, sb_id);
 
 		/* stop scanning when hit first invalid PF entry */
 		if (!GET_FIELD(val, IGU_MAPPING_LINE_VALID) &&
 		    GET_FIELD(val, IGU_MAPPING_LINE_PF_VALID))
 			break;
 
-		blk->status = QED_IGU_STATUS_VALID;
-		blk->function_id = GET_FIELD(val,
-					     IGU_MAPPING_LINE_FUNCTION_NUMBER);
-		blk->is_pf = GET_FIELD(val, IGU_MAPPING_LINE_PF_VALID);
-		blk->vector_number = GET_FIELD(val,
-					       IGU_MAPPING_LINE_VECTOR_NUMBER);
-
-		DP_VERBOSE(p_hwfn, NETIF_MSG_INTR,
-			   "IGU_BLOCK[sb_id]:%x:func_id = %d is_pf = %d vector_num = 0x%x\n",
-			   val, blk->function_id, blk->is_pf,
-			   blk->vector_number);
-
 		if (blk->is_pf) {
 			if (blk->function_id == p_hwfn->rel_pf_id) {
 				blk->status |= QED_IGU_STATUS_PF;
@@ -1121,18 +1143,17 @@ void qed_int_setup(struct qed_hwfn *p_hwfn,
 	qed_int_sp_dpc_setup(p_hwfn);
 }
 
-int qed_int_get_num_sbs(struct qed_hwfn *p_hwfn,
-			int *p_iov_blks)
+void qed_int_get_num_sbs(struct qed_hwfn	*p_hwfn,
+			 struct qed_sb_cnt_info *p_sb_cnt_info)
 {
 	struct qed_igu_info *info = p_hwfn->hw_info.p_igu_info;
 
-	if (!info)
-		return 0;
-
-	if (p_iov_blks)
-		*p_iov_blks = info->free_blks;
+	if (!info || !p_sb_cnt_info)
+		return;
 
-	return info->igu_sb_cnt;
+	p_sb_cnt_info->sb_cnt		= info->igu_sb_cnt;
+	p_sb_cnt_info->sb_iov_cnt	= info->igu_sb_cnt_iov;
+	p_sb_cnt_info->sb_free_blk	= info->free_blks;
 }
 
 void qed_int_disable_post_isr_release(struct qed_dev *cdev)
diff --git a/drivers/net/ethernet/qlogic/qed/qed_int.h b/drivers/net/ethernet/qlogic/qed/qed_int.h
index 51e0b09..c57f2e6 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_int.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_int.h
@@ -161,12 +161,12 @@ void qed_int_sp_dpc(unsigned long hwfn_cookie);
  *        blocks configured for this funciton in the igu.
  *
  * @param p_hwfn
- * @param p_iov_blks - configured free blks for vfs
+ * @param p_sb_cnt_info
  *
  * @return int - number of status blocks configured
  */
-int qed_int_get_num_sbs(struct qed_hwfn *p_hwfn,
-			int *p_iov_blks);
+void qed_int_get_num_sbs(struct qed_hwfn	*p_hwfn,
+			 struct qed_sb_cnt_info *p_sb_cnt_info);
 
 /**
  * @brief qed_int_disable_post_isr_release - performs the cleanup post ISR
diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index 25d6e91..caa689e 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -634,15 +634,18 @@ static int qed_get_int_fp(struct qed_dev *cdev, struct qed_int_info *info)
 static int qed_slowpath_setup_int(struct qed_dev *cdev,
 				  enum qed_int_mode int_mode)
 {
-	int rc, i;
-	u8 num_vectors = 0;
-
+	struct qed_sb_cnt_info sb_cnt_info;
+	int rc;
+	int i;
 	memset(&cdev->int_params, 0, sizeof(struct qed_int_params));
 
 	cdev->int_params.in.int_mode = int_mode;
-	for_each_hwfn(cdev, i)
-		num_vectors +=  qed_int_get_num_sbs(&cdev->hwfns[i], NULL) + 1;
-	cdev->int_params.in.num_vectors = num_vectors;
+	for_each_hwfn(cdev, i) {
+		memset(&sb_cnt_info, 0, sizeof(sb_cnt_info));
+		qed_int_get_num_sbs(&cdev->hwfns[i], &sb_cnt_info);
+		cdev->int_params.in.num_vectors += sb_cnt_info.sb_cnt;
+		cdev->int_params.in.num_vectors++; /* slowpath */
+	}
 
 	/* We want a minimum of one slowpath and one fastpath vector per hwfn */
 	cdev->int_params.in.min_msix_cnt = cdev->num_hwfns * 2;
diff --git a/include/linux/qed/qed_if.h b/include/linux/qed/qed_if.h
index 3d43c1d..1f7599c7 100644
--- a/include/linux/qed/qed_if.h
+++ b/include/linux/qed/qed_if.h
@@ -446,6 +446,12 @@ struct qed_eth_stats {
 #define RX_PI           0
 #define TX_PI(tc)       (RX_PI + 1 + tc)
 
+struct qed_sb_cnt_info {
+	int	sb_cnt;
+	int	sb_iov_cnt;
+	int	sb_free_blk;
+};
+
 static inline u16 qed_sb_update_sb_idx(struct qed_sb_info *sb_info)
 {
 	u32 prod = 0;
-- 
1.9.3
