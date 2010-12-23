From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 9/9] cnic: Add FCoE support on 57712
Date: Thu, 23 Dec 2010 09:43:04 -0800
Message-ID: <1293126184-13097-10-git-send-email-mchan@broadcom.com>
References: <1293126184-13097-1-git-send-email-mchan@broadcom.com>
 <1293126184-13097-2-git-send-email-mchan@broadcom.com>
 <1293126184-13097-3-git-send-email-mchan@broadcom.com>
 <1293126184-13097-4-git-send-email-mchan@broadcom.com>
 <1293126184-13097-5-git-send-email-mchan@broadcom.com>
 <1293126184-13097-6-git-send-email-mchan@broadcom.com>
 <1293126184-13097-7-git-send-email-mchan@broadcom.com>
 <1293126184-13097-8-git-send-email-mchan@broadcom.com>
 <1293126184-13097-9-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4510 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753322Ab0LWSir (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Dec 2010 13:38:47 -0500
In-Reply-To: <1293126184-13097-9-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Connection ID (cid) management
- Slow-path command and response support
- Update version to 2.2.11.

Reviewed-by: Bhanu Prakash Gollapudi <bprakash@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/cnic.c      |  466 +++++++++++-
 drivers/net/cnic.h      |   16 +-
 drivers/net/cnic_defs.h | 2095 +++++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/cnic_if.h   |   22 +-
 4 files changed, 2585 insertions(+), 14 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 6ce7398..4a9c628 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -850,6 +850,7 @@ static void cnic_free_resc(struct cnic_dev *dev)
 	kfree(cp->ctx_tbl);
 	cp->ctx_tbl = NULL;
 
+	cnic_free_id_tbl(&cp->fcoe_cid_tbl);
 	cnic_free_id_tbl(&cp->cid_tbl);
 }
 
@@ -1137,12 +1138,22 @@ static int cnic_alloc_bnx2x_resc(struct cnic_dev *dev)
 
 	cp->iro_arr = ethdev->iro_arr;
 
-	cp->max_cid_space = MAX_ISCSI_TBL_SZ;
+	cp->max_cid_space = MAX_ISCSI_TBL_SZ + BNX2X_FCOE_NUM_CONNECTIONS;
 	cp->iscsi_start_cid = start_cid;
+	cp->fcoe_start_cid = start_cid + MAX_ISCSI_TBL_SZ;
+
+	if (BNX2X_CHIP_IS_E2(cp->chip_id)) {
+		cp->max_cid_space += BNX2X_FCOE_NUM_CONNECTIONS;
+		cp->fcoe_init_cid = ethdev->fcoe_init_cid;
+		if (!cp->fcoe_init_cid)
+			cp->fcoe_init_cid = 0x10;
+	}
+
 	if (start_cid < BNX2X_ISCSI_START_CID) {
 		u32 delta = BNX2X_ISCSI_START_CID - start_cid;
 
 		cp->iscsi_start_cid = BNX2X_ISCSI_START_CID;
+		cp->fcoe_start_cid += delta;
 		cp->max_cid_space += delta;
 	}
 
@@ -1161,6 +1172,9 @@ static int cnic_alloc_bnx2x_resc(struct cnic_dev *dev)
 		cp->ctx_tbl[i].ulp_proto_id = CNIC_ULP_ISCSI;
 	}
 
+	for (i = MAX_ISCSI_TBL_SZ; i < cp->max_cid_space; i++)
+		cp->ctx_tbl[i].ulp_proto_id = CNIC_ULP_FCOE;
+
 	pages = PAGE_ALIGN(cp->max_cid_space * CNIC_KWQ16_DATA_SIZE) /
 		PAGE_SIZE;
 
@@ -1454,8 +1468,11 @@ static void cnic_free_bnx2x_conn_resc(struct cnic_dev *dev, u32 l5_cid)
 		cnic_free_dma(dev, &iscsi->hq_info);
 		cnic_free_dma(dev, &iscsi->r2tq_info);
 		cnic_free_dma(dev, &iscsi->task_array_info);
+		cnic_free_id(&cp->cid_tbl, ctx->cid);
+	} else {
+		cnic_free_id(&cp->fcoe_cid_tbl, ctx->cid);
 	}
-	cnic_free_id(&cp->cid_tbl, ctx->cid);
+
 	ctx->cid = 0;
 }
 
@@ -1467,6 +1484,16 @@ static int cnic_alloc_bnx2x_conn_resc(struct cnic_dev *dev, u32 l5_cid)
 	struct cnic_context *ctx = &cp->ctx_tbl[l5_cid];
 	struct cnic_iscsi *iscsi = ctx->proto.iscsi;
 
+	if (ctx->ulp_proto_id == CNIC_ULP_FCOE) {
+		cid = cnic_alloc_new_id(&cp->fcoe_cid_tbl);
+		if (cid == -1) {
+			ret = -ENOMEM;
+			goto error;
+		}
+		ctx->cid = cid;
+		return 0;
+	}
+
 	cid = cnic_alloc_new_id(&cp->cid_tbl);
 	if (cid == -1) {
 		ret = -ENOMEM;
@@ -2107,8 +2134,307 @@ static int cnic_bnx2x_update_pg(struct cnic_dev *dev, struct kwqe *kwqe)
 	return 0;
 }
 
-static int cnic_submit_bnx2x_kwqes(struct cnic_dev *dev, struct kwqe *wqes[],
-				   u32 num_wqes)
+static int cnic_bnx2x_fcoe_stat(struct cnic_dev *dev, struct kwqe *kwqe)
+{
+	struct fcoe_kwqe_stat *req;
+	struct fcoe_stat_ramrod_params *fcoe_stat;
+	union l5cm_specific_data l5_data;
+	struct cnic_local *cp = dev->cnic_priv;
+	int ret;
+	u32 cid;
+
+	req = (struct fcoe_kwqe_stat *) kwqe;
+	cid = BNX2X_HW_CID(cp, cp->fcoe_init_cid);
+
+	fcoe_stat = cnic_get_kwqe_16_data(cp, BNX2X_FCOE_L5_CID_BASE, &l5_data);
+	if (!fcoe_stat)
+		return -ENOMEM;
+
+	memset(fcoe_stat, 0, sizeof(*fcoe_stat));
+	memcpy(&fcoe_stat->stat_kwqe, req, sizeof(*req));
+
+	ret = cnic_submit_kwqe_16(dev, FCOE_RAMROD_CMD_ID_STAT, cid,
+				  FCOE_CONNECTION_TYPE, &l5_data);
+	return ret;
+}
+
+static int cnic_bnx2x_fcoe_init1(struct cnic_dev *dev, struct kwqe *wqes[],
+				 u32 num, int *work)
+{
+	int ret;
+	struct cnic_local *cp = dev->cnic_priv;
+	u32 cid;
+	struct fcoe_init_ramrod_params *fcoe_init;
+	struct fcoe_kwqe_init1 *req1;
+	struct fcoe_kwqe_init2 *req2;
+	struct fcoe_kwqe_init3 *req3;
+	union l5cm_specific_data l5_data;
+
+	if (num < 3) {
+		*work = num;
+		return -EINVAL;
+	}
+	req1 = (struct fcoe_kwqe_init1 *) wqes[0];
+	req2 = (struct fcoe_kwqe_init2 *) wqes[1];
+	req3 = (struct fcoe_kwqe_init3 *) wqes[2];
+	if (req2->hdr.op_code != FCOE_KWQE_OPCODE_INIT2) {
+		*work = 1;
+		return -EINVAL;
+	}
+	if (req3->hdr.op_code != FCOE_KWQE_OPCODE_INIT3) {
+		*work = 2;
+		return -EINVAL;
+	}
+
+	if (sizeof(*fcoe_init) > CNIC_KWQ16_DATA_SIZE) {
+		netdev_err(dev->netdev, "fcoe_init size too big\n");
+		return -ENOMEM;
+	}
+	fcoe_init = cnic_get_kwqe_16_data(cp, BNX2X_FCOE_L5_CID_BASE, &l5_data);
+	if (!fcoe_init)
+		return -ENOMEM;
+
+	memset(fcoe_init, 0, sizeof(*fcoe_init));
+	memcpy(&fcoe_init->init_kwqe1, req1, sizeof(*req1));
+	memcpy(&fcoe_init->init_kwqe2, req2, sizeof(*req2));
+	memcpy(&fcoe_init->init_kwqe3, req3, sizeof(*req3));
+	fcoe_init->eq_addr.lo = cp->kcq2.dma.pg_map_arr[0] & 0xffffffff;
+	fcoe_init->eq_addr.hi = (u64) cp->kcq2.dma.pg_map_arr[0] >> 32;
+	fcoe_init->eq_next_page_addr.lo =
+		cp->kcq2.dma.pg_map_arr[1] & 0xffffffff;
+	fcoe_init->eq_next_page_addr.hi =
+		(u64) cp->kcq2.dma.pg_map_arr[1] >> 32;
+
+	fcoe_init->sb_num = cp->status_blk_num;
+	fcoe_init->eq_prod = MAX_KCQ_IDX;
+	fcoe_init->sb_id = HC_INDEX_FCOE_EQ_CONS;
+	cp->kcq2.sw_prod_idx = 0;
+
+	cid = BNX2X_HW_CID(cp, cp->fcoe_init_cid);
+	printk(KERN_ERR "bdbg: submitting INIT RAMROD \n");
+	ret = cnic_submit_kwqe_16(dev, FCOE_RAMROD_CMD_ID_INIT, cid,
+				  FCOE_CONNECTION_TYPE, &l5_data);
+	*work = 3;
+	return ret;
+}
+
+static int cnic_bnx2x_fcoe_ofld1(struct cnic_dev *dev, struct kwqe *wqes[],
+				 u32 num, int *work)
+{
+	int ret = 0;
+	u32 cid = -1, l5_cid;
+	struct cnic_local *cp = dev->cnic_priv;
+	struct fcoe_kwqe_conn_offload1 *req1;
+	struct fcoe_kwqe_conn_offload2 *req2;
+	struct fcoe_kwqe_conn_offload3 *req3;
+	struct fcoe_kwqe_conn_offload4 *req4;
+	struct fcoe_conn_offload_ramrod_params *fcoe_offload;
+	struct cnic_context *ctx;
+	struct fcoe_context *fctx;
+	struct regpair ctx_addr;
+	union l5cm_specific_data l5_data;
+	struct fcoe_kcqe kcqe;
+	struct kcqe *cqes[1];
+
+	if (num < 4) {
+		*work = num;
+		return -EINVAL;
+	}
+	req1 = (struct fcoe_kwqe_conn_offload1 *) wqes[0];
+	req2 = (struct fcoe_kwqe_conn_offload2 *) wqes[1];
+	req3 = (struct fcoe_kwqe_conn_offload3 *) wqes[2];
+	req4 = (struct fcoe_kwqe_conn_offload4 *) wqes[3];
+
+	*work = 4;
+
+	l5_cid = req1->fcoe_conn_id;
+	if (l5_cid >= BNX2X_FCOE_NUM_CONNECTIONS)
+		goto err_reply;
+
+	l5_cid += BNX2X_FCOE_L5_CID_BASE;
+
+	ctx = &cp->ctx_tbl[l5_cid];
+	if (test_bit(CTX_FL_OFFLD_START, &ctx->ctx_flags))
+		goto err_reply;
+
+	ret = cnic_alloc_bnx2x_conn_resc(dev, l5_cid);
+	if (ret) {
+		ret = 0;
+		goto err_reply;
+	}
+	cid = ctx->cid;
+
+	fctx = cnic_get_bnx2x_ctx(dev, cid, 1, &ctx_addr);
+	if (fctx) {
+		u32 hw_cid = BNX2X_HW_CID(cp, cid);
+		u32 val;
+
+		val = CDU_RSRVD_VALUE_TYPE_A(hw_cid, CDU_REGION_NUMBER_XCM_AG,
+					     FCOE_CONNECTION_TYPE);
+		fctx->xstorm_ag_context.cdu_reserved = val;
+		val = CDU_RSRVD_VALUE_TYPE_A(hw_cid, CDU_REGION_NUMBER_UCM_AG,
+					     FCOE_CONNECTION_TYPE);
+		fctx->ustorm_ag_context.cdu_usage = val;
+	}
+	if (sizeof(*fcoe_offload) > CNIC_KWQ16_DATA_SIZE) {
+		netdev_err(dev->netdev, "fcoe_offload size too big\n");
+		goto err_reply;
+	}
+	fcoe_offload = cnic_get_kwqe_16_data(cp, l5_cid, &l5_data);
+	if (!fcoe_offload)
+		goto err_reply;
+
+	memset(fcoe_offload, 0, sizeof(*fcoe_offload));
+	memcpy(&fcoe_offload->offload_kwqe1, req1, sizeof(*req1));
+	memcpy(&fcoe_offload->offload_kwqe2, req2, sizeof(*req2));
+	memcpy(&fcoe_offload->offload_kwqe3, req3, sizeof(*req3));
+	memcpy(&fcoe_offload->offload_kwqe4, req4, sizeof(*req4));
+
+	cid = BNX2X_HW_CID(cp, cid);
+	ret = cnic_submit_kwqe_16(dev, FCOE_RAMROD_CMD_ID_OFFLOAD_CONN, cid,
+				  FCOE_CONNECTION_TYPE, &l5_data);
+	if (!ret)
+		set_bit(CTX_FL_OFFLD_START, &ctx->ctx_flags);
+
+	return ret;
+
+err_reply:
+	if (cid != -1)
+		cnic_free_bnx2x_conn_resc(dev, l5_cid);
+
+	memset(&kcqe, 0, sizeof(kcqe));
+	kcqe.op_code = FCOE_KCQE_OPCODE_OFFLOAD_CONN;
+	kcqe.fcoe_conn_id = req1->fcoe_conn_id;
+	kcqe.completion_status = FCOE_KCQE_COMPLETION_STATUS_CTX_ALLOC_FAILURE;
+
+	cqes[0] = (struct kcqe *) &kcqe;
+	cnic_reply_bnx2x_kcqes(dev, CNIC_ULP_FCOE, cqes, 1);
+	return ret;
+}
+
+static int cnic_bnx2x_fcoe_enable(struct cnic_dev *dev, struct kwqe *kwqe)
+{
+	struct fcoe_kwqe_conn_enable_disable *req;
+	struct fcoe_conn_enable_disable_ramrod_params *fcoe_enable;
+	union l5cm_specific_data l5_data;
+	int ret;
+	u32 cid, l5_cid;
+	struct cnic_local *cp = dev->cnic_priv;
+
+	req = (struct fcoe_kwqe_conn_enable_disable *) kwqe;
+	cid = req->context_id;
+	l5_cid = req->conn_id + BNX2X_FCOE_L5_CID_BASE;
+
+	if (sizeof(*fcoe_enable) > CNIC_KWQ16_DATA_SIZE) {
+		netdev_err(dev->netdev, "fcoe_enable size too big\n");
+		return -ENOMEM;
+	}
+	fcoe_enable = cnic_get_kwqe_16_data(cp, l5_cid, &l5_data);
+	if (!fcoe_enable)
+		return -ENOMEM;
+
+	memset(fcoe_enable, 0, sizeof(*fcoe_enable));
+	memcpy(&fcoe_enable->enable_disable_kwqe, req, sizeof(*req));
+	ret = cnic_submit_kwqe_16(dev, FCOE_RAMROD_CMD_ID_ENABLE_CONN, cid,
+				  FCOE_CONNECTION_TYPE, &l5_data);
+	return ret;
+}
+
+static int cnic_bnx2x_fcoe_disable(struct cnic_dev *dev, struct kwqe *kwqe)
+{
+	struct fcoe_kwqe_conn_enable_disable *req;
+	struct fcoe_conn_enable_disable_ramrod_params *fcoe_disable;
+	union l5cm_specific_data l5_data;
+	int ret;
+	u32 cid, l5_cid;
+	struct cnic_local *cp = dev->cnic_priv;
+
+	req = (struct fcoe_kwqe_conn_enable_disable *) kwqe;
+	cid = req->context_id;
+	l5_cid = req->conn_id;
+	if (l5_cid >= BNX2X_FCOE_NUM_CONNECTIONS)
+		return -EINVAL;
+
+	l5_cid += BNX2X_FCOE_L5_CID_BASE;
+
+	if (sizeof(*fcoe_disable) > CNIC_KWQ16_DATA_SIZE) {
+		netdev_err(dev->netdev, "fcoe_disable size too big\n");
+		return -ENOMEM;
+	}
+	fcoe_disable = cnic_get_kwqe_16_data(cp, l5_cid, &l5_data);
+	if (!fcoe_disable)
+		return -ENOMEM;
+
+	memset(fcoe_disable, 0, sizeof(*fcoe_disable));
+	memcpy(&fcoe_disable->enable_disable_kwqe, req, sizeof(*req));
+	ret = cnic_submit_kwqe_16(dev, FCOE_RAMROD_CMD_ID_DISABLE_CONN, cid,
+				  FCOE_CONNECTION_TYPE, &l5_data);
+	return ret;
+}
+
+static int cnic_bnx2x_fcoe_destroy(struct cnic_dev *dev, struct kwqe *kwqe)
+{
+	struct fcoe_kwqe_conn_destroy *req;
+	union l5cm_specific_data l5_data;
+	int ret;
+	u32 cid, l5_cid;
+	struct cnic_local *cp = dev->cnic_priv;
+	struct cnic_context *ctx;
+	struct fcoe_kcqe kcqe;
+	struct kcqe *cqes[1];
+
+	req = (struct fcoe_kwqe_conn_destroy *) kwqe;
+	cid = req->context_id;
+	l5_cid = req->conn_id;
+	if (l5_cid >= BNX2X_FCOE_NUM_CONNECTIONS)
+		return -EINVAL;
+
+	l5_cid += BNX2X_FCOE_L5_CID_BASE;
+
+	ctx = &cp->ctx_tbl[l5_cid];
+
+	init_waitqueue_head(&ctx->waitq);
+	ctx->wait_cond = 0;
+
+	memset(&l5_data, 0, sizeof(l5_data));
+	ret = cnic_submit_kwqe_16(dev, FCOE_RAMROD_CMD_ID_TERMINATE_CONN, cid,
+				  FCOE_CONNECTION_TYPE, &l5_data);
+	if (ret == 0) {
+		wait_event(ctx->waitq, ctx->wait_cond);
+		set_bit(CTX_FL_DELETE_WAIT, &ctx->ctx_flags);
+		queue_delayed_work(cnic_wq, &cp->delete_task,
+				   msecs_to_jiffies(2000));
+	}
+
+	memset(&kcqe, 0, sizeof(kcqe));
+	kcqe.op_code = FCOE_KCQE_OPCODE_DESTROY_CONN;
+	kcqe.fcoe_conn_id = req->conn_id;
+	kcqe.fcoe_conn_context_id = cid;
+
+	cqes[0] = (struct kcqe *) &kcqe;
+	cnic_reply_bnx2x_kcqes(dev, CNIC_ULP_FCOE, cqes, 1);
+	return ret;
+}
+
+static int cnic_bnx2x_fcoe_fw_destroy(struct cnic_dev *dev, struct kwqe *kwqe)
+{
+	struct fcoe_kwqe_destroy *req;
+	union l5cm_specific_data l5_data;
+	struct cnic_local *cp = dev->cnic_priv;
+	int ret;
+	u32 cid;
+
+	req = (struct fcoe_kwqe_destroy *) kwqe;
+	cid = BNX2X_HW_CID(cp, cp->fcoe_init_cid);
+
+	memset(&l5_data, 0, sizeof(l5_data));
+	ret = cnic_submit_kwqe_16(dev, FCOE_RAMROD_CMD_ID_DESTROY, cid,
+				  FCOE_CONNECTION_TYPE, &l5_data);
+	return ret;
+}
+
+static int cnic_submit_bnx2x_iscsi_kwqes(struct cnic_dev *dev,
+					 struct kwqe *wqes[], u32 num_wqes)
 {
 	int i, work, ret;
 	u32 opcode;
@@ -2172,6 +2498,98 @@ static int cnic_submit_bnx2x_kwqes(struct cnic_dev *dev, struct kwqe *wqes[],
 	return 0;
 }
 
+static int cnic_submit_bnx2x_fcoe_kwqes(struct cnic_dev *dev,
+					struct kwqe *wqes[], u32 num_wqes)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	int i, work, ret;
+	u32 opcode;
+	struct kwqe *kwqe;
+
+	if (!test_bit(CNIC_F_CNIC_UP, &dev->flags))
+		return -EAGAIN;		/* bnx2 is down */
+
+	if (BNX2X_CHIP_NUM(cp->chip_id) == BNX2X_CHIP_NUM_57710)
+		return -EINVAL;
+
+	for (i = 0; i < num_wqes; ) {
+		kwqe = wqes[i];
+		opcode = KWQE_OPCODE(kwqe->kwqe_op_flag);
+		work = 1;
+
+		switch (opcode) {
+		case FCOE_KWQE_OPCODE_INIT1:
+			ret = cnic_bnx2x_fcoe_init1(dev, &wqes[i],
+						    num_wqes - i, &work);
+			break;
+		case FCOE_KWQE_OPCODE_OFFLOAD_CONN1:
+			ret = cnic_bnx2x_fcoe_ofld1(dev, &wqes[i],
+						    num_wqes - i, &work);
+			break;
+		case FCOE_KWQE_OPCODE_ENABLE_CONN:
+			ret = cnic_bnx2x_fcoe_enable(dev, kwqe);
+			break;
+		case FCOE_KWQE_OPCODE_DISABLE_CONN:
+			ret = cnic_bnx2x_fcoe_disable(dev, kwqe);
+			break;
+		case FCOE_KWQE_OPCODE_DESTROY_CONN:
+			ret = cnic_bnx2x_fcoe_destroy(dev, kwqe);
+			break;
+		case FCOE_KWQE_OPCODE_DESTROY:
+			ret = cnic_bnx2x_fcoe_fw_destroy(dev, kwqe);
+			break;
+		case FCOE_KWQE_OPCODE_STAT:
+			ret = cnic_bnx2x_fcoe_stat(dev, kwqe);
+			break;
+		default:
+			ret = 0;
+			netdev_err(dev->netdev, "Unknown type of KWQE(0x%x)\n",
+				   opcode);
+			break;
+		}
+		if (ret < 0)
+			netdev_err(dev->netdev, "KWQE(0x%x) failed\n",
+				   opcode);
+		i += work;
+	}
+	return 0;
+}
+
+static int cnic_submit_bnx2x_kwqes(struct cnic_dev *dev, struct kwqe *wqes[],
+				   u32 num_wqes)
+{
+	int ret = -EINVAL;
+	u32 layer_code;
+
+	if (!test_bit(CNIC_F_CNIC_UP, &dev->flags))
+		return -EAGAIN;		/* bnx2x is down */
+
+	if (!num_wqes)
+		return 0;
+
+	layer_code = wqes[0]->kwqe_op_flag & KWQE_LAYER_MASK;
+	switch (layer_code) {
+	case KWQE_FLAGS_LAYER_MASK_L5_ISCSI:
+	case KWQE_FLAGS_LAYER_MASK_L4:
+	case KWQE_FLAGS_LAYER_MASK_L2:
+		ret = cnic_submit_bnx2x_iscsi_kwqes(dev, wqes, num_wqes);
+		break;
+
+	case KWQE_FLAGS_LAYER_MASK_L5_FCOE:
+		ret = cnic_submit_bnx2x_fcoe_kwqes(dev, wqes, num_wqes);
+		break;
+	}
+	return ret;
+}
+
+static inline u32 cnic_get_kcqe_layer_mask(u32 opflag)
+{
+	if (unlikely(KCQE_OPCODE(opflag) == FCOE_RAMROD_CMD_ID_TERMINATE_CONN))
+		return KCQE_FLAGS_LAYER_MASK_L4;
+
+	return opflag & KCQE_FLAGS_LAYER_MASK;
+}
+
 static void service_kcqes(struct cnic_dev *dev, int num_cqes)
 {
 	struct cnic_local *cp = dev->cnic_priv;
@@ -2183,7 +2601,7 @@ static void service_kcqes(struct cnic_dev *dev, int num_cqes)
 		struct cnic_ulp_ops *ulp_ops;
 		int ulp_type;
 		u32 kcqe_op_flag = cp->completed_kcq[i]->kcqe_op_flag;
-		u32 kcqe_layer = kcqe_op_flag & KCQE_FLAGS_LAYER_MASK;
+		u32 kcqe_layer = cnic_get_kcqe_layer_mask(kcqe_op_flag);
 
 		if (unlikely(kcqe_op_flag & KCQE_RAMROD_COMPLETION))
 			comp++;
@@ -2191,7 +2609,7 @@ static void service_kcqes(struct cnic_dev *dev, int num_cqes)
 		while (j < num_cqes) {
 			u32 next_op = cp->completed_kcq[i + j]->kcqe_op_flag;
 
-			if ((next_op & KCQE_FLAGS_LAYER_MASK) != kcqe_layer)
+			if (cnic_get_kcqe_layer_mask(next_op) != kcqe_layer)
 				break;
 
 			if (unlikely(next_op & KCQE_RAMROD_COMPLETION))
@@ -2203,6 +2621,8 @@ static void service_kcqes(struct cnic_dev *dev, int num_cqes)
 			ulp_type = CNIC_ULP_RDMA;
 		else if (kcqe_layer == KCQE_FLAGS_LAYER_MASK_L5_ISCSI)
 			ulp_type = CNIC_ULP_ISCSI;
+		else if (kcqe_layer == KCQE_FLAGS_LAYER_MASK_L5_FCOE)
+			ulp_type = CNIC_ULP_FCOE;
 		else if (kcqe_layer == KCQE_FLAGS_LAYER_MASK_L4)
 			ulp_type = CNIC_ULP_L4;
 		else if (kcqe_layer == KCQE_FLAGS_LAYER_MASK_L2)
@@ -3249,6 +3669,18 @@ done:
 	csk_put(csk);
 }
 
+static void cnic_process_fcoe_term_conn(struct cnic_dev *dev, struct kcqe *kcqe)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	struct fcoe_kcqe *fc_kcqe = (struct fcoe_kcqe *) kcqe;
+	u32 l5_cid = fc_kcqe->fcoe_conn_id + BNX2X_FCOE_L5_CID_BASE;
+	struct cnic_context *ctx = &cp->ctx_tbl[l5_cid];
+
+	ctx->timestamp = jiffies;
+	ctx->wait_cond = 1;
+	wake_up(&ctx->waitq);
+}
+
 static void cnic_cm_process_kcqe(struct cnic_dev *dev, struct kcqe *kcqe)
 {
 	struct cnic_local *cp = dev->cnic_priv;
@@ -3257,6 +3689,10 @@ static void cnic_cm_process_kcqe(struct cnic_dev *dev, struct kcqe *kcqe)
 	u32 l5_cid;
 	struct cnic_sock *csk;
 
+	if (opcode == FCOE_RAMROD_CMD_ID_TERMINATE_CONN) {
+		cnic_process_fcoe_term_conn(dev, kcqe);
+		return;
+	}
 	if (opcode == L4_KCQE_OPCODE_VALUE_OFFLOAD_PG ||
 	    opcode == L4_KCQE_OPCODE_VALUE_UPDATE_PG) {
 		cnic_cm_process_offld_pg(dev, l4kcqe);
@@ -3893,7 +4329,7 @@ static void cnic_shutdown_bnx2_rx_ring(struct cnic_dev *dev)
 
 	memset(&l2kwqe, 0, sizeof(l2kwqe));
 	wqes[0] = &l2kwqe;
-	l2kwqe.kwqe_op_flag = (L2_LAYER_CODE << KWQE_FLAGS_LAYER_SHIFT) |
+	l2kwqe.kwqe_op_flag = (L2_LAYER_CODE << KWQE_LAYER_SHIFT) |
 			      (L2_KWQE_OPCODE_VALUE_FLUSH <<
 			       KWQE_OPCODE_SHIFT) | 2;
 	dev->submit_kwqes(dev, wqes, 1);
@@ -4336,6 +4772,10 @@ static void cnic_get_bnx2x_iscsi_info(struct cnic_dev *dev)
 			val16 ^= 0x1e1e;
 		dev->max_iscsi_conn = val16;
 	}
+
+	if (BNX2X_CHIP_IS_E2(cp->chip_id))
+		dev->max_fcoe_conn = BNX2X_FCOE_NUM_CONNECTIONS;
+
 	if (BNX2X_CHIP_IS_E1H(cp->chip_id) || BNX2X_CHIP_IS_E2(cp->chip_id)) {
 		int func = CNIC_FUNC(cp);
 		u32 mf_cfg_addr;
@@ -4362,6 +4802,9 @@ static void cnic_get_bnx2x_iscsi_info(struct cnic_dev *dev)
 				if (!(val & MACP_FUNC_CFG_FLAGS_ISCSI_OFFLOAD))
 					dev->max_iscsi_conn = 0;
 
+				if (!(val & MACP_FUNC_CFG_FLAGS_FCOE_OFFLOAD))
+					dev->max_fcoe_conn = 0;
+
 				addr = BNX2X_MF_CFG_ADDR(mf_cfg_addr,
 					func_ext_config[func].
 					iscsi_mac_addr_upper);
@@ -4463,6 +4906,15 @@ static int cnic_start_bnx2x_hw(struct cnic_dev *dev)
 	if (ret)
 		return -ENOMEM;
 
+	if (BNX2X_CHIP_IS_E2(cp->chip_id)) {
+		ret = cnic_init_id_tbl(&cp->fcoe_cid_tbl,
+					BNX2X_FCOE_NUM_CONNECTIONS,
+					cp->fcoe_start_cid);
+
+		if (ret)
+			return -ENOMEM;
+	}
+
 	cp->bnx2x_igu_sb_id = ethdev->irq_arr[0].status_blk_num2;
 
 	cnic_init_bnx2x_kcq(dev);
diff --git a/drivers/net/cnic.h b/drivers/net/cnic.h
index e46b4c1..b328f6c 100644
--- a/drivers/net/cnic.h
+++ b/drivers/net/cnic.h
@@ -291,6 +291,10 @@ struct cnic_local {
 	atomic_t		iscsi_conn;
 	u32			iscsi_start_cid;
 
+	u32			fcoe_init_cid;
+	u32			fcoe_start_cid;
+	struct cnic_id_tbl	fcoe_cid_tbl;
+
 	u32			max_cid_space;
 
 	/* per connection parameters */
@@ -368,6 +372,10 @@ struct bnx2x_bd_chain_next {
 #define BNX2X_ISCSI_PBL_NOT_CACHED	0xff
 #define BNX2X_ISCSI_PDU_HEADER_NOT_CACHED	0xff
 
+#define BNX2X_FCOE_NUM_CONNECTIONS	128
+
+#define BNX2X_FCOE_L5_CID_BASE		MAX_ISCSI_TBL_SZ
+
 #define BNX2X_CHIP_NUM_57710		0x164e
 #define BNX2X_CHIP_NUM_57711		0x164f
 #define BNX2X_CHIP_NUM_57711E		0x1650
@@ -426,6 +434,10 @@ struct bnx2x_bd_chain_next {
 #define BNX2X_MF_CFG_ADDR(base, field)				\
 			((base) + offsetof(struct mf_cfg, field))
 
+#ifndef ETH_MAX_RX_CLIENTS_E2
+#define ETH_MAX_RX_CLIENTS_E2 		ETH_MAX_RX_CLIENTS_E1H
+#endif
+
 #define CNIC_PORT(cp)			((cp)->pfid & 1)
 #define CNIC_FUNC(cp)			((cp)->func)
 #define CNIC_PATH(cp)			(!BNX2X_CHIP_IS_E2(cp->chip_id) ? 0 :\
@@ -438,7 +450,9 @@ struct bnx2x_bd_chain_next {
 #define BNX2X_SW_CID(x)			(x & 0x1ffff)
 
 #define BNX2X_CL_QZONE_ID(cp, cli)					\
-		(cli + (CNIC_PORT(cp) * ETH_MAX_RX_CLIENTS_E1H))
+		(cli + (CNIC_PORT(cp) * (BNX2X_CHIP_IS_E2(cp->chip_id) ?\
+					ETH_MAX_RX_CLIENTS_E2 :		\
+					ETH_MAX_RX_CLIENTS_E1H)))
 
 #define TCP_TSTORM_OOO_DROP_AND_PROC_ACK	(0<<4)
 #endif
diff --git a/drivers/net/cnic_defs.h b/drivers/net/cnic_defs.h
index 328e8b2..fdbc004 100644
--- a/drivers/net/cnic_defs.h
+++ b/drivers/net/cnic_defs.h
@@ -35,6 +35,40 @@
 #define L5CM_RAMROD_CMD_ID_SEARCHER_DELETE	(L5CM_RAMROD_CMD_ID_BASE + 14)
 #define L5CM_RAMROD_CMD_ID_TERMINATE_OFFLOAD	(L5CM_RAMROD_CMD_ID_BASE + 15)
 
+#define FCOE_KCQE_OPCODE_INIT_FUNC			(0x10)
+#define FCOE_KCQE_OPCODE_DESTROY_FUNC			(0x11)
+#define FCOE_KCQE_OPCODE_STAT_FUNC			(0x12)
+#define FCOE_KCQE_OPCODE_OFFLOAD_CONN			(0x15)
+#define FCOE_KCQE_OPCODE_ENABLE_CONN			(0x16)
+#define FCOE_KCQE_OPCODE_DISABLE_CONN			(0x17)
+#define FCOE_KCQE_OPCODE_DESTROY_CONN			(0x18)
+#define FCOE_KCQE_OPCODE_CQ_EVENT_NOTIFICATION  (0x20)
+#define FCOE_KCQE_OPCODE_FCOE_ERROR				(0x21)
+
+#define FCOE_RAMROD_CMD_ID_INIT			(FCOE_KCQE_OPCODE_INIT_FUNC)
+#define FCOE_RAMROD_CMD_ID_DESTROY		(FCOE_KCQE_OPCODE_DESTROY_FUNC)
+#define FCOE_RAMROD_CMD_ID_OFFLOAD_CONN		(FCOE_KCQE_OPCODE_OFFLOAD_CONN)
+#define FCOE_RAMROD_CMD_ID_ENABLE_CONN		(FCOE_KCQE_OPCODE_ENABLE_CONN)
+#define FCOE_RAMROD_CMD_ID_DISABLE_CONN		(FCOE_KCQE_OPCODE_DISABLE_CONN)
+#define FCOE_RAMROD_CMD_ID_DESTROY_CONN		(FCOE_KCQE_OPCODE_DESTROY_CONN)
+#define FCOE_RAMROD_CMD_ID_STAT			(FCOE_KCQE_OPCODE_STAT_FUNC)
+#define FCOE_RAMROD_CMD_ID_TERMINATE_CONN	(0x81)
+
+#define FCOE_KWQE_OPCODE_INIT1                  (0)
+#define FCOE_KWQE_OPCODE_INIT2                  (1)
+#define FCOE_KWQE_OPCODE_INIT3                  (2)
+#define FCOE_KWQE_OPCODE_OFFLOAD_CONN1  (3)
+#define FCOE_KWQE_OPCODE_OFFLOAD_CONN2  (4)
+#define FCOE_KWQE_OPCODE_OFFLOAD_CONN3  (5)
+#define FCOE_KWQE_OPCODE_OFFLOAD_CONN4  (6)
+#define FCOE_KWQE_OPCODE_ENABLE_CONN	(7)
+#define FCOE_KWQE_OPCODE_DISABLE_CONN	(8)
+#define FCOE_KWQE_OPCODE_DESTROY_CONN	(9)
+#define FCOE_KWQE_OPCODE_DESTROY		(10)
+#define FCOE_KWQE_OPCODE_STAT			(11)
+
+#define FCOE_KCQE_COMPLETION_STATUS_CTX_ALLOC_FAILURE	(0x3)
+
 /* KCQ (kernel completion queue) response op codes */
 #define L4_KCQE_OPCODE_VALUE_CLOSE_COMP             (53)
 #define L4_KCQE_OPCODE_VALUE_RESET_COMP             (54)
@@ -683,6 +717,1496 @@ struct cstorm_iscsi_ag_context {
 };
 
 /*
+ * Parameters initialized during offloaded according to FLOGI/PLOGI/PRLI and used in FCoE context section
+ */
+struct ustorm_fcoe_params {
+#if defined(__BIG_ENDIAN)
+	u16 fcoe_conn_id;
+	u16 flags;
+#define USTORM_FCOE_PARAMS_B_MUL_N_PORT_IDS (0x1<<0)
+#define USTORM_FCOE_PARAMS_B_MUL_N_PORT_IDS_SHIFT 0
+#define USTORM_FCOE_PARAMS_B_E_D_TOV_RES (0x1<<1)
+#define USTORM_FCOE_PARAMS_B_E_D_TOV_RES_SHIFT 1
+#define USTORM_FCOE_PARAMS_B_CONT_INCR_SEQ_CNT (0x1<<2)
+#define USTORM_FCOE_PARAMS_B_CONT_INCR_SEQ_CNT_SHIFT 2
+#define USTORM_FCOE_PARAMS_B_CONF_REQ (0x1<<3)
+#define USTORM_FCOE_PARAMS_B_CONF_REQ_SHIFT 3
+#define USTORM_FCOE_PARAMS_B_REC_VALID (0x1<<4)
+#define USTORM_FCOE_PARAMS_B_REC_VALID_SHIFT 4
+#define USTORM_FCOE_PARAMS_B_CQ_TOGGLE_BIT (0x1<<5)
+#define USTORM_FCOE_PARAMS_B_CQ_TOGGLE_BIT_SHIFT 5
+#define USTORM_FCOE_PARAMS_B_XFRQ_TOGGLE_BIT (0x1<<6)
+#define USTORM_FCOE_PARAMS_B_XFRQ_TOGGLE_BIT_SHIFT 6
+#define USTORM_FCOE_PARAMS_B_C2_VALID (0x1<<7)
+#define USTORM_FCOE_PARAMS_B_C2_VALID_SHIFT 7
+#define USTORM_FCOE_PARAMS_B_ACK_0 (0x1<<8)
+#define USTORM_FCOE_PARAMS_B_ACK_0_SHIFT 8
+#define USTORM_FCOE_PARAMS_RSRV0 (0x7F<<9)
+#define USTORM_FCOE_PARAMS_RSRV0_SHIFT 9
+#elif defined(__LITTLE_ENDIAN)
+	u16 flags;
+#define USTORM_FCOE_PARAMS_B_MUL_N_PORT_IDS (0x1<<0)
+#define USTORM_FCOE_PARAMS_B_MUL_N_PORT_IDS_SHIFT 0
+#define USTORM_FCOE_PARAMS_B_E_D_TOV_RES (0x1<<1)
+#define USTORM_FCOE_PARAMS_B_E_D_TOV_RES_SHIFT 1
+#define USTORM_FCOE_PARAMS_B_CONT_INCR_SEQ_CNT (0x1<<2)
+#define USTORM_FCOE_PARAMS_B_CONT_INCR_SEQ_CNT_SHIFT 2
+#define USTORM_FCOE_PARAMS_B_CONF_REQ (0x1<<3)
+#define USTORM_FCOE_PARAMS_B_CONF_REQ_SHIFT 3
+#define USTORM_FCOE_PARAMS_B_REC_VALID (0x1<<4)
+#define USTORM_FCOE_PARAMS_B_REC_VALID_SHIFT 4
+#define USTORM_FCOE_PARAMS_B_CQ_TOGGLE_BIT (0x1<<5)
+#define USTORM_FCOE_PARAMS_B_CQ_TOGGLE_BIT_SHIFT 5
+#define USTORM_FCOE_PARAMS_B_XFRQ_TOGGLE_BIT (0x1<<6)
+#define USTORM_FCOE_PARAMS_B_XFRQ_TOGGLE_BIT_SHIFT 6
+#define USTORM_FCOE_PARAMS_B_C2_VALID (0x1<<7)
+#define USTORM_FCOE_PARAMS_B_C2_VALID_SHIFT 7
+#define USTORM_FCOE_PARAMS_B_ACK_0 (0x1<<8)
+#define USTORM_FCOE_PARAMS_B_ACK_0_SHIFT 8
+#define USTORM_FCOE_PARAMS_RSRV0 (0x7F<<9)
+#define USTORM_FCOE_PARAMS_RSRV0_SHIFT 9
+	u16 fcoe_conn_id;
+#endif
+#if defined(__BIG_ENDIAN)
+	u8 hc_csdm_byte_en;
+	u8 func_id;
+	u8 port_id;
+	u8 vnic_id;
+#elif defined(__LITTLE_ENDIAN)
+	u8 vnic_id;
+	u8 port_id;
+	u8 func_id;
+	u8 hc_csdm_byte_en;
+#endif
+#if defined(__BIG_ENDIAN)
+	u16 rx_total_conc_seqs;
+	u16 rx_max_fc_pay_len;
+#elif defined(__LITTLE_ENDIAN)
+	u16 rx_max_fc_pay_len;
+	u16 rx_total_conc_seqs;
+#endif
+#if defined(__BIG_ENDIAN)
+	u16 ox_id;
+	u16 rx_max_conc_seqs;
+#elif defined(__LITTLE_ENDIAN)
+	u16 rx_max_conc_seqs;
+	u16 ox_id;
+#endif
+};
+
+/*
+ * FCoE 16-bits index structure
+ */
+struct fcoe_idx16_fields {
+	u16 fields;
+#define FCOE_IDX16_FIELDS_IDX (0x7FFF<<0)
+#define FCOE_IDX16_FIELDS_IDX_SHIFT 0
+#define FCOE_IDX16_FIELDS_MSB (0x1<<15)
+#define FCOE_IDX16_FIELDS_MSB_SHIFT 15
+};
+
+/*
+ * FCoE 16-bits index union
+ */
+union fcoe_idx16_field_union {
+	struct fcoe_idx16_fields fields;
+	u16 val;
+};
+
+/*
+ * 4 regs size
+ */
+struct fcoe_bd_ctx {
+	u32 buf_addr_hi;
+	u32 buf_addr_lo;
+#if defined(__BIG_ENDIAN)
+	u16 rsrv0;
+	u16 buf_len;
+#elif defined(__LITTLE_ENDIAN)
+	u16 buf_len;
+	u16 rsrv0;
+#endif
+#if defined(__BIG_ENDIAN)
+	u16 rsrv1;
+	u16 flags;
+#elif defined(__LITTLE_ENDIAN)
+	u16 flags;
+	u16 rsrv1;
+#endif
+};
+
+/*
+ * Parameters required for placement according to SGL
+ */
+struct ustorm_fcoe_data_place {
+#if defined(__BIG_ENDIAN)
+	u16 cached_sge_off;
+	u8 cached_num_sges;
+	u8 cached_sge_idx;
+#elif defined(__LITTLE_ENDIAN)
+	u8 cached_sge_idx;
+	u8 cached_num_sges;
+	u16 cached_sge_off;
+#endif
+	struct fcoe_bd_ctx cached_sge[3];
+};
+
+struct fcoe_task_ctx_entry_txwr_rxrd {
+#if defined(__BIG_ENDIAN)
+	u16 verify_tx_seq;
+	u8 init_flags;
+#define FCOE_TASK_CTX_ENTRY_TXWR_RXRD_TASK_TYPE (0x7<<0)
+#define FCOE_TASK_CTX_ENTRY_TXWR_RXRD_TASK_TYPE_SHIFT 0
+#define FCOE_TASK_CTX_ENTRY_TXWR_RXRD_DEV_TYPE (0x1<<3)
+#define FCOE_TASK_CTX_ENTRY_TXWR_RXRD_DEV_TYPE_SHIFT 3
+#define FCOE_TASK_CTX_ENTRY_TXWR_RXRD_CLASS_TYPE (0x1<<4)
+#define FCOE_TASK_CTX_ENTRY_TXWR_RXRD_CLASS_TYPE_SHIFT 4
+#define FCOE_TASK_CTX_ENTRY_TXWR_RXRD_SINGLE_SGE (0x1<<5)
+#define FCOE_TASK_CTX_ENTRY_TXWR_RXRD_SINGLE_SGE_SHIFT 5
+#define FCOE_TASK_CTX_ENTRY_TXWR_RXRD_RSRV5 (0x3<<6)
+#define FCOE_TASK_CTX_ENTRY_TXWR_RXRD_RSRV5_SHIFT 6
+	u8 tx_flags;
+#define FCOE_TASK_CTX_ENTRY_TXWR_RXRD_TX_STATE (0xF<<0)
+#define FCOE_TASK_CTX_ENTRY_TXWR_RXRD_TX_STATE_SHIFT 0
+#define FCOE_TASK_CTX_ENTRY_TXWR_RXRD_RSRV4 (0xF<<4)
+#define FCOE_TASK_CTX_ENTRY_TXWR_RXRD_RSRV4_SHIFT 4
+#elif defined(__LITTLE_ENDIAN)
+	u8 tx_flags;
+#define FCOE_TASK_CTX_ENTRY_TXWR_RXRD_TX_STATE (0xF<<0)
+#define FCOE_TASK_CTX_ENTRY_TXWR_RXRD_TX_STATE_SHIFT 0
+#define FCOE_TASK_CTX_ENTRY_TXWR_RXRD_RSRV4 (0xF<<4)
+#define FCOE_TASK_CTX_ENTRY_TXWR_RXRD_RSRV4_SHIFT 4
+	u8 init_flags;
+#define FCOE_TASK_CTX_ENTRY_TXWR_RXRD_TASK_TYPE (0x7<<0)
+#define FCOE_TASK_CTX_ENTRY_TXWR_RXRD_TASK_TYPE_SHIFT 0
+#define FCOE_TASK_CTX_ENTRY_TXWR_RXRD_DEV_TYPE (0x1<<3)
+#define FCOE_TASK_CTX_ENTRY_TXWR_RXRD_DEV_TYPE_SHIFT 3
+#define FCOE_TASK_CTX_ENTRY_TXWR_RXRD_CLASS_TYPE (0x1<<4)
+#define FCOE_TASK_CTX_ENTRY_TXWR_RXRD_CLASS_TYPE_SHIFT 4
+#define FCOE_TASK_CTX_ENTRY_TXWR_RXRD_SINGLE_SGE (0x1<<5)
+#define FCOE_TASK_CTX_ENTRY_TXWR_RXRD_SINGLE_SGE_SHIFT 5
+#define FCOE_TASK_CTX_ENTRY_TXWR_RXRD_RSRV5 (0x3<<6)
+#define FCOE_TASK_CTX_ENTRY_TXWR_RXRD_RSRV5_SHIFT 6
+	u16 verify_tx_seq;
+#endif
+};
+
+struct fcoe_fcp_cmd_payload {
+	u32 opaque[8];
+};
+
+struct fcoe_fc_hdr {
+#if defined(__BIG_ENDIAN)
+	u8 cs_ctl;
+	u8 s_id[3];
+#elif defined(__LITTLE_ENDIAN)
+	u8 s_id[3];
+	u8 cs_ctl;
+#endif
+#if defined(__BIG_ENDIAN)
+	u8 r_ctl;
+	u8 d_id[3];
+#elif defined(__LITTLE_ENDIAN)
+	u8 d_id[3];
+	u8 r_ctl;
+#endif
+#if defined(__BIG_ENDIAN)
+	u8 seq_id;
+	u8 df_ctl;
+	u16 seq_cnt;
+#elif defined(__LITTLE_ENDIAN)
+	u16 seq_cnt;
+	u8 df_ctl;
+	u8 seq_id;
+#endif
+#if defined(__BIG_ENDIAN)
+	u8 type;
+	u8 f_ctl[3];
+#elif defined(__LITTLE_ENDIAN)
+	u8 f_ctl[3];
+	u8 type;
+#endif
+	u32 parameters;
+#if defined(__BIG_ENDIAN)
+	u16 ox_id;
+	u16 rx_id;
+#elif defined(__LITTLE_ENDIAN)
+	u16 rx_id;
+	u16 ox_id;
+#endif
+};
+
+struct fcoe_fc_frame {
+	struct fcoe_fc_hdr fc_hdr;
+	u32 reserved0[2];
+};
+
+union fcoe_cmd_flow_info {
+	struct fcoe_fcp_cmd_payload fcp_cmd_payload;
+	struct fcoe_fc_frame mp_fc_frame;
+};
+
+struct fcoe_read_flow_info {
+	struct fcoe_fc_hdr fc_data_in_hdr;
+	u32 reserved[2];
+};
+
+struct fcoe_fcp_xfr_rdy_payload {
+	u32 burst_len;
+	u32 data_ro;
+};
+
+struct fcoe_write_flow_info {
+	struct fcoe_fc_hdr fc_data_out_hdr;
+	struct fcoe_fcp_xfr_rdy_payload fcp_xfr_payload;
+};
+
+struct fcoe_fcp_rsp_flags {
+	u8 flags;
+#define FCOE_FCP_RSP_FLAGS_FCP_RSP_LEN_VALID (0x1<<0)
+#define FCOE_FCP_RSP_FLAGS_FCP_RSP_LEN_VALID_SHIFT 0
+#define FCOE_FCP_RSP_FLAGS_FCP_SNS_LEN_VALID (0x1<<1)
+#define FCOE_FCP_RSP_FLAGS_FCP_SNS_LEN_VALID_SHIFT 1
+#define FCOE_FCP_RSP_FLAGS_FCP_RESID_OVER (0x1<<2)
+#define FCOE_FCP_RSP_FLAGS_FCP_RESID_OVER_SHIFT 2
+#define FCOE_FCP_RSP_FLAGS_FCP_RESID_UNDER (0x1<<3)
+#define FCOE_FCP_RSP_FLAGS_FCP_RESID_UNDER_SHIFT 3
+#define FCOE_FCP_RSP_FLAGS_FCP_CONF_REQ (0x1<<4)
+#define FCOE_FCP_RSP_FLAGS_FCP_CONF_REQ_SHIFT 4
+#define FCOE_FCP_RSP_FLAGS_FCP_BIDI_FLAGS (0x7<<5)
+#define FCOE_FCP_RSP_FLAGS_FCP_BIDI_FLAGS_SHIFT 5
+};
+
+struct fcoe_fcp_rsp_payload {
+	struct regpair reserved0;
+	u32 fcp_resid;
+#if defined(__BIG_ENDIAN)
+	u16 retry_delay_timer;
+	struct fcoe_fcp_rsp_flags fcp_flags;
+	u8 scsi_status_code;
+#elif defined(__LITTLE_ENDIAN)
+	u8 scsi_status_code;
+	struct fcoe_fcp_rsp_flags fcp_flags;
+	u16 retry_delay_timer;
+#endif
+	u32 fcp_rsp_len;
+	u32 fcp_sns_len;
+};
+
+/*
+ * Fixed size structure in order to plant it in Union structure
+ */
+struct fcoe_fcp_rsp_union {
+	struct fcoe_fcp_rsp_payload payload;
+	struct regpair reserved0;
+};
+
+/*
+ * Fixed size structure in order to plant it in Union structure
+ */
+struct fcoe_abts_rsp_union {
+	u32 r_ctl;
+	u32 abts_rsp_payload[7];
+};
+
+union fcoe_rsp_flow_info {
+	struct fcoe_fcp_rsp_union fcp_rsp;
+	struct fcoe_abts_rsp_union abts_rsp;
+};
+
+struct fcoe_cleanup_flow_info {
+#if defined(__BIG_ENDIAN)
+	u16 reserved1;
+	u16 task_id;
+#elif defined(__LITTLE_ENDIAN)
+	u16 task_id;
+	u16 reserved1;
+#endif
+	u32 reserved2[7];
+};
+
+/*
+ * 32 bytes used for general purposes
+ */
+union fcoe_general_task_ctx {
+	union fcoe_cmd_flow_info cmd_info;
+	struct fcoe_read_flow_info read_info;
+	struct fcoe_write_flow_info write_info;
+	union fcoe_rsp_flow_info rsp_info;
+	struct fcoe_cleanup_flow_info cleanup_info;
+	u32 comp_info[8];
+};
+
+struct fcoe_s_stat_ctx {
+	u8 flags;
+#define FCOE_S_STAT_CTX_ACTIVE (0x1<<0)
+#define FCOE_S_STAT_CTX_ACTIVE_SHIFT 0
+#define FCOE_S_STAT_CTX_ACK_ABORT_SEQ_COND (0x1<<1)
+#define FCOE_S_STAT_CTX_ACK_ABORT_SEQ_COND_SHIFT 1
+#define FCOE_S_STAT_CTX_ABTS_PERFORMED (0x1<<2)
+#define FCOE_S_STAT_CTX_ABTS_PERFORMED_SHIFT 2
+#define FCOE_S_STAT_CTX_SEQ_TIMEOUT (0x1<<3)
+#define FCOE_S_STAT_CTX_SEQ_TIMEOUT_SHIFT 3
+#define FCOE_S_STAT_CTX_P_RJT (0x1<<4)
+#define FCOE_S_STAT_CTX_P_RJT_SHIFT 4
+#define FCOE_S_STAT_CTX_ACK_EOFT (0x1<<5)
+#define FCOE_S_STAT_CTX_ACK_EOFT_SHIFT 5
+#define FCOE_S_STAT_CTX_RSRV1 (0x3<<6)
+#define FCOE_S_STAT_CTX_RSRV1_SHIFT 6
+};
+
+/*
+ * Common section. Both TX and RX processing might write and read from it in different flows
+ */
+struct fcoe_task_ctx_entry_tx_rx_cmn {
+	u32 data_2_trns;
+	union fcoe_general_task_ctx general;
+#if defined(__BIG_ENDIAN)
+	u16 tx_low_seq_cnt;
+	struct fcoe_s_stat_ctx tx_s_stat;
+	u8 tx_seq_id;
+#elif defined(__LITTLE_ENDIAN)
+	u8 tx_seq_id;
+	struct fcoe_s_stat_ctx tx_s_stat;
+	u16 tx_low_seq_cnt;
+#endif
+	u32 common_flags;
+#define FCOE_TASK_CTX_ENTRY_TX_RX_CMN_CID (0xFFFFFF<<0)
+#define FCOE_TASK_CTX_ENTRY_TX_RX_CMN_CID_SHIFT 0
+#define FCOE_TASK_CTX_ENTRY_TX_RX_CMN_VALID (0x1<<24)
+#define FCOE_TASK_CTX_ENTRY_TX_RX_CMN_VALID_SHIFT 24
+#define FCOE_TASK_CTX_ENTRY_TX_RX_CMN_SEQ_INIT (0x1<<25)
+#define FCOE_TASK_CTX_ENTRY_TX_RX_CMN_SEQ_INIT_SHIFT 25
+#define FCOE_TASK_CTX_ENTRY_TX_RX_CMN_PEND_XFER (0x1<<26)
+#define FCOE_TASK_CTX_ENTRY_TX_RX_CMN_PEND_XFER_SHIFT 26
+#define FCOE_TASK_CTX_ENTRY_TX_RX_CMN_PEND_CONF (0x1<<27)
+#define FCOE_TASK_CTX_ENTRY_TX_RX_CMN_PEND_CONF_SHIFT 27
+#define FCOE_TASK_CTX_ENTRY_TX_RX_CMN_EXP_FIRST_FRAME (0x1<<28)
+#define FCOE_TASK_CTX_ENTRY_TX_RX_CMN_EXP_FIRST_FRAME_SHIFT 28
+#define FCOE_TASK_CTX_ENTRY_TX_RX_CMN_RSRV (0x7<<29)
+#define FCOE_TASK_CTX_ENTRY_TX_RX_CMN_RSRV_SHIFT 29
+};
+
+struct fcoe_task_ctx_entry_rxwr_txrd {
+#if defined(__BIG_ENDIAN)
+	u16 rx_id;
+	u16 rx_flags;
+#define FCOE_TASK_CTX_ENTRY_RXWR_TXRD_RX_STATE (0xF<<0)
+#define FCOE_TASK_CTX_ENTRY_RXWR_TXRD_RX_STATE_SHIFT 0
+#define FCOE_TASK_CTX_ENTRY_RXWR_TXRD_NUM_RQ_WQE (0x7<<4)
+#define FCOE_TASK_CTX_ENTRY_RXWR_TXRD_NUM_RQ_WQE_SHIFT 4
+#define FCOE_TASK_CTX_ENTRY_RXWR_TXRD_CONF_REQ (0x1<<7)
+#define FCOE_TASK_CTX_ENTRY_RXWR_TXRD_CONF_REQ_SHIFT 7
+#define FCOE_TASK_CTX_ENTRY_RXWR_TXRD_MISS_FRAME (0x1<<8)
+#define FCOE_TASK_CTX_ENTRY_RXWR_TXRD_MISS_FRAME_SHIFT 8
+#define FCOE_TASK_CTX_ENTRY_RXWR_TXRD_RESERVED0 (0x7F<<9)
+#define FCOE_TASK_CTX_ENTRY_RXWR_TXRD_RESERVED0_SHIFT 9
+#elif defined(__LITTLE_ENDIAN)
+	u16 rx_flags;
+#define FCOE_TASK_CTX_ENTRY_RXWR_TXRD_RX_STATE (0xF<<0)
+#define FCOE_TASK_CTX_ENTRY_RXWR_TXRD_RX_STATE_SHIFT 0
+#define FCOE_TASK_CTX_ENTRY_RXWR_TXRD_NUM_RQ_WQE (0x7<<4)
+#define FCOE_TASK_CTX_ENTRY_RXWR_TXRD_NUM_RQ_WQE_SHIFT 4
+#define FCOE_TASK_CTX_ENTRY_RXWR_TXRD_CONF_REQ (0x1<<7)
+#define FCOE_TASK_CTX_ENTRY_RXWR_TXRD_CONF_REQ_SHIFT 7
+#define FCOE_TASK_CTX_ENTRY_RXWR_TXRD_MISS_FRAME (0x1<<8)
+#define FCOE_TASK_CTX_ENTRY_RXWR_TXRD_MISS_FRAME_SHIFT 8
+#define FCOE_TASK_CTX_ENTRY_RXWR_TXRD_RESERVED0 (0x7F<<9)
+#define FCOE_TASK_CTX_ENTRY_RXWR_TXRD_RESERVED0_SHIFT 9
+	u16 rx_id;
+#endif
+};
+
+struct fcoe_seq_ctx {
+#if defined(__BIG_ENDIAN)
+	u16 low_seq_cnt;
+	struct fcoe_s_stat_ctx s_stat;
+	u8 seq_id;
+#elif defined(__LITTLE_ENDIAN)
+	u8 seq_id;
+	struct fcoe_s_stat_ctx s_stat;
+	u16 low_seq_cnt;
+#endif
+#if defined(__BIG_ENDIAN)
+	u16 err_seq_cnt;
+	u16 high_seq_cnt;
+#elif defined(__LITTLE_ENDIAN)
+	u16 high_seq_cnt;
+	u16 err_seq_cnt;
+#endif
+	u32 low_exp_ro;
+	u32 high_exp_ro;
+};
+
+struct fcoe_single_sge_ctx {
+	struct regpair cur_buf_addr;
+#if defined(__BIG_ENDIAN)
+	u16 reserved0;
+	u16 cur_buf_rem;
+#elif defined(__LITTLE_ENDIAN)
+	u16 cur_buf_rem;
+	u16 reserved0;
+#endif
+};
+
+struct fcoe_mul_sges_ctx {
+	struct regpair cur_sge_addr;
+#if defined(__BIG_ENDIAN)
+	u8 sgl_size;
+	u8 cur_sge_idx;
+	u16 cur_sge_off;
+#elif defined(__LITTLE_ENDIAN)
+	u16 cur_sge_off;
+	u8 cur_sge_idx;
+	u8 sgl_size;
+#endif
+};
+
+union fcoe_sgl_ctx {
+	struct fcoe_single_sge_ctx single_sge;
+	struct fcoe_mul_sges_ctx mul_sges;
+};
+
+struct fcoe_task_ctx_entry_rx_only {
+	struct fcoe_seq_ctx seq_ctx;
+	struct fcoe_seq_ctx ooo_seq_ctx;
+	u32 rsrv3;
+	union fcoe_sgl_ctx sgl_ctx;
+};
+
+struct ustorm_fcoe_task_ctx_entry_rd {
+	struct fcoe_task_ctx_entry_txwr_rxrd tx_wr_rx_rd;
+	struct fcoe_task_ctx_entry_tx_rx_cmn cmn;
+	struct fcoe_task_ctx_entry_rxwr_txrd rx_wr_tx_rd;
+	struct fcoe_task_ctx_entry_rx_only rx_wr;
+	u32 reserved;
+};
+
+/*
+ * Ustorm FCoE Storm Context
+ */
+struct ustorm_fcoe_st_context {
+	struct ustorm_fcoe_params fcoe_params;
+	struct regpair task_addr;
+	struct regpair cq_base_addr;
+	struct regpair rq_pbl_base;
+	struct regpair rq_cur_page_addr;
+	struct regpair confq_pbl_base_addr;
+	struct regpair conn_db_base;
+	struct regpair xfrq_base_addr;
+	struct regpair lcq_base_addr;
+#if defined(__BIG_ENDIAN)
+	union fcoe_idx16_field_union rq_cons;
+	union fcoe_idx16_field_union rq_prod;
+#elif defined(__LITTLE_ENDIAN)
+	union fcoe_idx16_field_union rq_prod;
+	union fcoe_idx16_field_union rq_cons;
+#endif
+#if defined(__BIG_ENDIAN)
+	u16 xfrq_prod;
+	u16 cq_cons;
+#elif defined(__LITTLE_ENDIAN)
+	u16 cq_cons;
+	u16 xfrq_prod;
+#endif
+#if defined(__BIG_ENDIAN)
+	u16 lcq_cons;
+	u16 hc_cram_address;
+#elif defined(__LITTLE_ENDIAN)
+	u16 hc_cram_address;
+	u16 lcq_cons;
+#endif
+#if defined(__BIG_ENDIAN)
+	u16 sq_xfrq_lcq_confq_size;
+	u16 confq_prod;
+#elif defined(__LITTLE_ENDIAN)
+	u16 confq_prod;
+	u16 sq_xfrq_lcq_confq_size;
+#endif
+#if defined(__BIG_ENDIAN)
+	u8 hc_csdm_agg_int;
+	u8 flags;
+#define USTORM_FCOE_ST_CONTEXT_MID_SEQ_PROC_FLAG (0x1<<0)
+#define USTORM_FCOE_ST_CONTEXT_MID_SEQ_PROC_FLAG_SHIFT 0
+#define USTORM_FCOE_ST_CONTEXT_CACHED_CONN_FLAG (0x1<<1)
+#define USTORM_FCOE_ST_CONTEXT_CACHED_CONN_FLAG_SHIFT 1
+#define USTORM_FCOE_ST_CONTEXT_CACHED_TCE_FLAG (0x1<<2)
+#define USTORM_FCOE_ST_CONTEXT_CACHED_TCE_FLAG_SHIFT 2
+#define USTORM_FCOE_ST_CONTEXT_RSRV1 (0x1F<<3)
+#define USTORM_FCOE_ST_CONTEXT_RSRV1_SHIFT 3
+	u8 available_rqes;
+	u8 sp_q_flush_cnt;
+#elif defined(__LITTLE_ENDIAN)
+	u8 sp_q_flush_cnt;
+	u8 available_rqes;
+	u8 flags;
+#define USTORM_FCOE_ST_CONTEXT_MID_SEQ_PROC_FLAG (0x1<<0)
+#define USTORM_FCOE_ST_CONTEXT_MID_SEQ_PROC_FLAG_SHIFT 0
+#define USTORM_FCOE_ST_CONTEXT_CACHED_CONN_FLAG (0x1<<1)
+#define USTORM_FCOE_ST_CONTEXT_CACHED_CONN_FLAG_SHIFT 1
+#define USTORM_FCOE_ST_CONTEXT_CACHED_TCE_FLAG (0x1<<2)
+#define USTORM_FCOE_ST_CONTEXT_CACHED_TCE_FLAG_SHIFT 2
+#define USTORM_FCOE_ST_CONTEXT_RSRV1 (0x1F<<3)
+#define USTORM_FCOE_ST_CONTEXT_RSRV1_SHIFT 3
+	u8 hc_csdm_agg_int;
+#endif
+	struct ustorm_fcoe_data_place data_place;
+	struct ustorm_fcoe_task_ctx_entry_rd tce;
+};
+
+/*
+ * The FCoE non-aggregative context of Tstorm
+ */
+struct tstorm_fcoe_st_context {
+	struct regpair reserved0;
+	struct regpair reserved1;
+};
+
+/*
+ * The fcoe aggregative context section of Xstorm
+ */
+struct xstorm_fcoe_extra_ag_context_section {
+#if defined(__BIG_ENDIAN)
+	u8 tcp_agg_vars1;
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_RESERVED51 (0x3<<0)
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_RESERVED51_SHIFT 0
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_ACK_TO_FE_UPDATED (0x3<<2)
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_ACK_TO_FE_UPDATED_SHIFT 2
+#define XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_PBF_TX_SEQ_ACK_CF (0x3<<4)
+#define XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_PBF_TX_SEQ_ACK_CF_SHIFT 4
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_RESERVED_CLEAR_DA_TIMER_EN (0x1<<6)
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_RESERVED_CLEAR_DA_TIMER_EN_SHIFT 6
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_RESERVED_DA_EXPIRATION_FLAG (0x1<<7)
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_RESERVED_DA_EXPIRATION_FLAG_SHIFT 7
+	u8 __reserved_da_cnt;
+	u16 __mtu;
+#elif defined(__LITTLE_ENDIAN)
+	u16 __mtu;
+	u8 __reserved_da_cnt;
+	u8 tcp_agg_vars1;
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_RESERVED51 (0x3<<0)
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_RESERVED51_SHIFT 0
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_ACK_TO_FE_UPDATED (0x3<<2)
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_ACK_TO_FE_UPDATED_SHIFT 2
+#define XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_PBF_TX_SEQ_ACK_CF (0x3<<4)
+#define XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_PBF_TX_SEQ_ACK_CF_SHIFT 4
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_RESERVED_CLEAR_DA_TIMER_EN (0x1<<6)
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_RESERVED_CLEAR_DA_TIMER_EN_SHIFT 6
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_RESERVED_DA_EXPIRATION_FLAG (0x1<<7)
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_RESERVED_DA_EXPIRATION_FLAG_SHIFT 7
+#endif
+	u32 __task_addr_lo;
+	u32 __task_addr_hi;
+	u32 __reserved55;
+	u32 __tx_prods;
+#if defined(__BIG_ENDIAN)
+	u8 __agg_val8_th;
+	u8 __agg_val8;
+	u16 tcp_agg_vars2;
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_RESERVED57 (0x1<<0)
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_RESERVED57_SHIFT 0
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_RESERVED58 (0x1<<1)
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_RESERVED58_SHIFT 1
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_RESERVED59 (0x1<<2)
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_RESERVED59_SHIFT 2
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_AUX3_FLAG (0x1<<3)
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_AUX3_FLAG_SHIFT 3
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_AUX4_FLAG (0x1<<4)
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_AUX4_FLAG_SHIFT 4
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_RESERVED60 (0x1<<5)
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_RESERVED60_SHIFT 5
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_RESERVED_ACK_TO_FE_UPDATED_EN (0x1<<6)
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_RESERVED_ACK_TO_FE_UPDATED_EN_SHIFT 6
+#define XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_PBF_TX_SEQ_ACK_CF_EN (0x1<<7)
+#define XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_PBF_TX_SEQ_ACK_CF_EN_SHIFT 7
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_RESERVED_TX_FIN_FLAG_EN (0x1<<8)
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_RESERVED_TX_FIN_FLAG_EN_SHIFT 8
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_AUX1_FLAG (0x1<<9)
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_AUX1_FLAG_SHIFT 9
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_SET_RTO_CF (0x3<<10)
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_SET_RTO_CF_SHIFT 10
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_TS_TO_ECHO_UPDATED_CF (0x3<<12)
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_TS_TO_ECHO_UPDATED_CF_SHIFT 12
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_AUX8_CF (0x3<<14)
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_AUX8_CF_SHIFT 14
+#elif defined(__LITTLE_ENDIAN)
+	u16 tcp_agg_vars2;
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_RESERVED57 (0x1<<0)
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_RESERVED57_SHIFT 0
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_RESERVED58 (0x1<<1)
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_RESERVED58_SHIFT 1
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_RESERVED59 (0x1<<2)
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_RESERVED59_SHIFT 2
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_AUX3_FLAG (0x1<<3)
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_AUX3_FLAG_SHIFT 3
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_AUX4_FLAG (0x1<<4)
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_AUX4_FLAG_SHIFT 4
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_RESERVED60 (0x1<<5)
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_RESERVED60_SHIFT 5
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_RESERVED_ACK_TO_FE_UPDATED_EN (0x1<<6)
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_RESERVED_ACK_TO_FE_UPDATED_EN_SHIFT 6
+#define XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_PBF_TX_SEQ_ACK_CF_EN (0x1<<7)
+#define XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_PBF_TX_SEQ_ACK_CF_EN_SHIFT 7
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_RESERVED_TX_FIN_FLAG_EN (0x1<<8)
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_RESERVED_TX_FIN_FLAG_EN_SHIFT 8
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_AUX1_FLAG (0x1<<9)
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_AUX1_FLAG_SHIFT 9
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_SET_RTO_CF (0x3<<10)
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_SET_RTO_CF_SHIFT 10
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_TS_TO_ECHO_UPDATED_CF (0x3<<12)
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_TS_TO_ECHO_UPDATED_CF_SHIFT 12
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_AUX8_CF (0x3<<14)
+#define __XSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_AUX8_CF_SHIFT 14
+	u8 __agg_val8;
+	u8 __agg_val8_th;
+#endif
+	u32 __sq_base_addr_lo;
+	u32 __sq_base_addr_hi;
+	u32 __xfrq_base_addr_lo;
+	u32 __xfrq_base_addr_hi;
+#if defined(__BIG_ENDIAN)
+	u16 __xfrq_cons;
+	u16 __xfrq_prod;
+#elif defined(__LITTLE_ENDIAN)
+	u16 __xfrq_prod;
+	u16 __xfrq_cons;
+#endif
+#if defined(__BIG_ENDIAN)
+	u8 __tcp_agg_vars5;
+	u8 __tcp_agg_vars4;
+	u8 __tcp_agg_vars3;
+	u8 __reserved_force_pure_ack_cnt;
+#elif defined(__LITTLE_ENDIAN)
+	u8 __reserved_force_pure_ack_cnt;
+	u8 __tcp_agg_vars3;
+	u8 __tcp_agg_vars4;
+	u8 __tcp_agg_vars5;
+#endif
+	u32 __tcp_agg_vars6;
+#if defined(__BIG_ENDIAN)
+	u16 __agg_misc6;
+	u16 __tcp_agg_vars7;
+#elif defined(__LITTLE_ENDIAN)
+	u16 __tcp_agg_vars7;
+	u16 __agg_misc6;
+#endif
+	u32 __agg_val10;
+	u32 __agg_val10_th;
+#if defined(__BIG_ENDIAN)
+	u16 __reserved3;
+	u8 __reserved2;
+	u8 __da_only_cnt;
+#elif defined(__LITTLE_ENDIAN)
+	u8 __da_only_cnt;
+	u8 __reserved2;
+	u16 __reserved3;
+#endif
+};
+
+/*
+ * The fcoe aggregative context of Xstorm
+ */
+struct xstorm_fcoe_ag_context {
+#if defined(__BIG_ENDIAN)
+	u16 agg_val1;
+	u8 agg_vars1;
+#define __XSTORM_FCOE_AG_CONTEXT_EXISTS_IN_QM0 (0x1<<0)
+#define __XSTORM_FCOE_AG_CONTEXT_EXISTS_IN_QM0_SHIFT 0
+#define __XSTORM_FCOE_AG_CONTEXT_EXISTS_IN_QM1 (0x1<<1)
+#define __XSTORM_FCOE_AG_CONTEXT_EXISTS_IN_QM1_SHIFT 1
+#define __XSTORM_FCOE_AG_CONTEXT_RESERVED51 (0x1<<2)
+#define __XSTORM_FCOE_AG_CONTEXT_RESERVED51_SHIFT 2
+#define __XSTORM_FCOE_AG_CONTEXT_RESERVED52 (0x1<<3)
+#define __XSTORM_FCOE_AG_CONTEXT_RESERVED52_SHIFT 3
+#define __XSTORM_FCOE_AG_CONTEXT_MORE_TO_SEND_EN (0x1<<4)
+#define __XSTORM_FCOE_AG_CONTEXT_MORE_TO_SEND_EN_SHIFT 4
+#define XSTORM_FCOE_AG_CONTEXT_NAGLE_EN (0x1<<5)
+#define XSTORM_FCOE_AG_CONTEXT_NAGLE_EN_SHIFT 5
+#define __XSTORM_FCOE_AG_CONTEXT_DQ_SPARE_FLAG (0x1<<6)
+#define __XSTORM_FCOE_AG_CONTEXT_DQ_SPARE_FLAG_SHIFT 6
+#define __XSTORM_FCOE_AG_CONTEXT_RESERVED_UNA_GT_NXT_EN (0x1<<7)
+#define __XSTORM_FCOE_AG_CONTEXT_RESERVED_UNA_GT_NXT_EN_SHIFT 7
+	u8 __state;
+#elif defined(__LITTLE_ENDIAN)
+	u8 __state;
+	u8 agg_vars1;
+#define __XSTORM_FCOE_AG_CONTEXT_EXISTS_IN_QM0 (0x1<<0)
+#define __XSTORM_FCOE_AG_CONTEXT_EXISTS_IN_QM0_SHIFT 0
+#define __XSTORM_FCOE_AG_CONTEXT_EXISTS_IN_QM1 (0x1<<1)
+#define __XSTORM_FCOE_AG_CONTEXT_EXISTS_IN_QM1_SHIFT 1
+#define __XSTORM_FCOE_AG_CONTEXT_RESERVED51 (0x1<<2)
+#define __XSTORM_FCOE_AG_CONTEXT_RESERVED51_SHIFT 2
+#define __XSTORM_FCOE_AG_CONTEXT_RESERVED52 (0x1<<3)
+#define __XSTORM_FCOE_AG_CONTEXT_RESERVED52_SHIFT 3
+#define __XSTORM_FCOE_AG_CONTEXT_MORE_TO_SEND_EN (0x1<<4)
+#define __XSTORM_FCOE_AG_CONTEXT_MORE_TO_SEND_EN_SHIFT 4
+#define XSTORM_FCOE_AG_CONTEXT_NAGLE_EN (0x1<<5)
+#define XSTORM_FCOE_AG_CONTEXT_NAGLE_EN_SHIFT 5
+#define __XSTORM_FCOE_AG_CONTEXT_DQ_SPARE_FLAG (0x1<<6)
+#define __XSTORM_FCOE_AG_CONTEXT_DQ_SPARE_FLAG_SHIFT 6
+#define __XSTORM_FCOE_AG_CONTEXT_RESERVED_UNA_GT_NXT_EN (0x1<<7)
+#define __XSTORM_FCOE_AG_CONTEXT_RESERVED_UNA_GT_NXT_EN_SHIFT 7
+	u16 agg_val1;
+#endif
+#if defined(__BIG_ENDIAN)
+	u8 cdu_reserved;
+	u8 __agg_vars4;
+	u8 agg_vars3;
+#define XSTORM_FCOE_AG_CONTEXT_PHYSICAL_QUEUE_NUM2 (0x3F<<0)
+#define XSTORM_FCOE_AG_CONTEXT_PHYSICAL_QUEUE_NUM2_SHIFT 0
+#define __XSTORM_FCOE_AG_CONTEXT_AUX19_CF (0x3<<6)
+#define __XSTORM_FCOE_AG_CONTEXT_AUX19_CF_SHIFT 6
+	u8 agg_vars2;
+#define __XSTORM_FCOE_AG_CONTEXT_DQ_CF (0x3<<0)
+#define __XSTORM_FCOE_AG_CONTEXT_DQ_CF_SHIFT 0
+#define __XSTORM_FCOE_AG_CONTEXT_DQ_SPARE_FLAG_EN (0x1<<2)
+#define __XSTORM_FCOE_AG_CONTEXT_DQ_SPARE_FLAG_EN_SHIFT 2
+#define __XSTORM_FCOE_AG_CONTEXT_AUX8_FLAG (0x1<<3)
+#define __XSTORM_FCOE_AG_CONTEXT_AUX8_FLAG_SHIFT 3
+#define __XSTORM_FCOE_AG_CONTEXT_AUX9_FLAG (0x1<<4)
+#define __XSTORM_FCOE_AG_CONTEXT_AUX9_FLAG_SHIFT 4
+#define XSTORM_FCOE_AG_CONTEXT_DECISION_RULE1 (0x3<<5)
+#define XSTORM_FCOE_AG_CONTEXT_DECISION_RULE1_SHIFT 5
+#define __XSTORM_FCOE_AG_CONTEXT_DQ_CF_EN (0x1<<7)
+#define __XSTORM_FCOE_AG_CONTEXT_DQ_CF_EN_SHIFT 7
+#elif defined(__LITTLE_ENDIAN)
+	u8 agg_vars2;
+#define __XSTORM_FCOE_AG_CONTEXT_DQ_CF (0x3<<0)
+#define __XSTORM_FCOE_AG_CONTEXT_DQ_CF_SHIFT 0
+#define __XSTORM_FCOE_AG_CONTEXT_DQ_SPARE_FLAG_EN (0x1<<2)
+#define __XSTORM_FCOE_AG_CONTEXT_DQ_SPARE_FLAG_EN_SHIFT 2
+#define __XSTORM_FCOE_AG_CONTEXT_AUX8_FLAG (0x1<<3)
+#define __XSTORM_FCOE_AG_CONTEXT_AUX8_FLAG_SHIFT 3
+#define __XSTORM_FCOE_AG_CONTEXT_AUX9_FLAG (0x1<<4)
+#define __XSTORM_FCOE_AG_CONTEXT_AUX9_FLAG_SHIFT 4
+#define XSTORM_FCOE_AG_CONTEXT_DECISION_RULE1 (0x3<<5)
+#define XSTORM_FCOE_AG_CONTEXT_DECISION_RULE1_SHIFT 5
+#define __XSTORM_FCOE_AG_CONTEXT_DQ_CF_EN (0x1<<7)
+#define __XSTORM_FCOE_AG_CONTEXT_DQ_CF_EN_SHIFT 7
+	u8 agg_vars3;
+#define XSTORM_FCOE_AG_CONTEXT_PHYSICAL_QUEUE_NUM2 (0x3F<<0)
+#define XSTORM_FCOE_AG_CONTEXT_PHYSICAL_QUEUE_NUM2_SHIFT 0
+#define __XSTORM_FCOE_AG_CONTEXT_AUX19_CF (0x3<<6)
+#define __XSTORM_FCOE_AG_CONTEXT_AUX19_CF_SHIFT 6
+	u8 __agg_vars4;
+	u8 cdu_reserved;
+#endif
+	u32 more_to_send;
+#if defined(__BIG_ENDIAN)
+	u16 agg_vars5;
+#define XSTORM_FCOE_AG_CONTEXT_DECISION_RULE5 (0x3<<0)
+#define XSTORM_FCOE_AG_CONTEXT_DECISION_RULE5_SHIFT 0
+#define XSTORM_FCOE_AG_CONTEXT_PHYSICAL_QUEUE_NUM0 (0x3F<<2)
+#define XSTORM_FCOE_AG_CONTEXT_PHYSICAL_QUEUE_NUM0_SHIFT 2
+#define XSTORM_FCOE_AG_CONTEXT_PHYSICAL_QUEUE_NUM1 (0x3F<<8)
+#define XSTORM_FCOE_AG_CONTEXT_PHYSICAL_QUEUE_NUM1_SHIFT 8
+#define __XSTORM_FCOE_AG_CONTEXT_CONFQ_DEC_RULE (0x3<<14)
+#define __XSTORM_FCOE_AG_CONTEXT_CONFQ_DEC_RULE_SHIFT 14
+	u16 sq_cons;
+#elif defined(__LITTLE_ENDIAN)
+	u16 sq_cons;
+	u16 agg_vars5;
+#define XSTORM_FCOE_AG_CONTEXT_DECISION_RULE5 (0x3<<0)
+#define XSTORM_FCOE_AG_CONTEXT_DECISION_RULE5_SHIFT 0
+#define XSTORM_FCOE_AG_CONTEXT_PHYSICAL_QUEUE_NUM0 (0x3F<<2)
+#define XSTORM_FCOE_AG_CONTEXT_PHYSICAL_QUEUE_NUM0_SHIFT 2
+#define XSTORM_FCOE_AG_CONTEXT_PHYSICAL_QUEUE_NUM1 (0x3F<<8)
+#define XSTORM_FCOE_AG_CONTEXT_PHYSICAL_QUEUE_NUM1_SHIFT 8
+#define __XSTORM_FCOE_AG_CONTEXT_CONFQ_DEC_RULE (0x3<<14)
+#define __XSTORM_FCOE_AG_CONTEXT_CONFQ_DEC_RULE_SHIFT 14
+#endif
+	struct xstorm_fcoe_extra_ag_context_section __extra_section;
+#if defined(__BIG_ENDIAN)
+	u16 agg_vars7;
+#define __XSTORM_FCOE_AG_CONTEXT_AGG_VAL11_DECISION_RULE (0x7<<0)
+#define __XSTORM_FCOE_AG_CONTEXT_AGG_VAL11_DECISION_RULE_SHIFT 0
+#define __XSTORM_FCOE_AG_CONTEXT_AUX13_FLAG (0x1<<3)
+#define __XSTORM_FCOE_AG_CONTEXT_AUX13_FLAG_SHIFT 3
+#define __XSTORM_FCOE_AG_CONTEXT_QUEUE0_CF (0x3<<4)
+#define __XSTORM_FCOE_AG_CONTEXT_QUEUE0_CF_SHIFT 4
+#define XSTORM_FCOE_AG_CONTEXT_DECISION_RULE3 (0x3<<6)
+#define XSTORM_FCOE_AG_CONTEXT_DECISION_RULE3_SHIFT 6
+#define XSTORM_FCOE_AG_CONTEXT_AUX1_CF (0x3<<8)
+#define XSTORM_FCOE_AG_CONTEXT_AUX1_CF_SHIFT 8
+#define __XSTORM_FCOE_AG_CONTEXT_RESERVED62 (0x1<<10)
+#define __XSTORM_FCOE_AG_CONTEXT_RESERVED62_SHIFT 10
+#define __XSTORM_FCOE_AG_CONTEXT_AUX1_CF_EN (0x1<<11)
+#define __XSTORM_FCOE_AG_CONTEXT_AUX1_CF_EN_SHIFT 11
+#define __XSTORM_FCOE_AG_CONTEXT_AUX10_FLAG (0x1<<12)
+#define __XSTORM_FCOE_AG_CONTEXT_AUX10_FLAG_SHIFT 12
+#define __XSTORM_FCOE_AG_CONTEXT_AUX11_FLAG (0x1<<13)
+#define __XSTORM_FCOE_AG_CONTEXT_AUX11_FLAG_SHIFT 13
+#define __XSTORM_FCOE_AG_CONTEXT_AUX12_FLAG (0x1<<14)
+#define __XSTORM_FCOE_AG_CONTEXT_AUX12_FLAG_SHIFT 14
+#define __XSTORM_FCOE_AG_CONTEXT_AUX2_FLAG (0x1<<15)
+#define __XSTORM_FCOE_AG_CONTEXT_AUX2_FLAG_SHIFT 15
+	u8 agg_val3_th;
+	u8 agg_vars6;
+#define XSTORM_FCOE_AG_CONTEXT_DECISION_RULE6 (0x7<<0)
+#define XSTORM_FCOE_AG_CONTEXT_DECISION_RULE6_SHIFT 0
+#define __XSTORM_FCOE_AG_CONTEXT_XFRQ_DEC_RULE (0x7<<3)
+#define __XSTORM_FCOE_AG_CONTEXT_XFRQ_DEC_RULE_SHIFT 3
+#define __XSTORM_FCOE_AG_CONTEXT_SQ_DEC_RULE (0x3<<6)
+#define __XSTORM_FCOE_AG_CONTEXT_SQ_DEC_RULE_SHIFT 6
+#elif defined(__LITTLE_ENDIAN)
+	u8 agg_vars6;
+#define XSTORM_FCOE_AG_CONTEXT_DECISION_RULE6 (0x7<<0)
+#define XSTORM_FCOE_AG_CONTEXT_DECISION_RULE6_SHIFT 0
+#define __XSTORM_FCOE_AG_CONTEXT_XFRQ_DEC_RULE (0x7<<3)
+#define __XSTORM_FCOE_AG_CONTEXT_XFRQ_DEC_RULE_SHIFT 3
+#define __XSTORM_FCOE_AG_CONTEXT_SQ_DEC_RULE (0x3<<6)
+#define __XSTORM_FCOE_AG_CONTEXT_SQ_DEC_RULE_SHIFT 6
+	u8 agg_val3_th;
+	u16 agg_vars7;
+#define __XSTORM_FCOE_AG_CONTEXT_AGG_VAL11_DECISION_RULE (0x7<<0)
+#define __XSTORM_FCOE_AG_CONTEXT_AGG_VAL11_DECISION_RULE_SHIFT 0
+#define __XSTORM_FCOE_AG_CONTEXT_AUX13_FLAG (0x1<<3)
+#define __XSTORM_FCOE_AG_CONTEXT_AUX13_FLAG_SHIFT 3
+#define __XSTORM_FCOE_AG_CONTEXT_QUEUE0_CF (0x3<<4)
+#define __XSTORM_FCOE_AG_CONTEXT_QUEUE0_CF_SHIFT 4
+#define XSTORM_FCOE_AG_CONTEXT_DECISION_RULE3 (0x3<<6)
+#define XSTORM_FCOE_AG_CONTEXT_DECISION_RULE3_SHIFT 6
+#define XSTORM_FCOE_AG_CONTEXT_AUX1_CF (0x3<<8)
+#define XSTORM_FCOE_AG_CONTEXT_AUX1_CF_SHIFT 8
+#define __XSTORM_FCOE_AG_CONTEXT_RESERVED62 (0x1<<10)
+#define __XSTORM_FCOE_AG_CONTEXT_RESERVED62_SHIFT 10
+#define __XSTORM_FCOE_AG_CONTEXT_AUX1_CF_EN (0x1<<11)
+#define __XSTORM_FCOE_AG_CONTEXT_AUX1_CF_EN_SHIFT 11
+#define __XSTORM_FCOE_AG_CONTEXT_AUX10_FLAG (0x1<<12)
+#define __XSTORM_FCOE_AG_CONTEXT_AUX10_FLAG_SHIFT 12
+#define __XSTORM_FCOE_AG_CONTEXT_AUX11_FLAG (0x1<<13)
+#define __XSTORM_FCOE_AG_CONTEXT_AUX11_FLAG_SHIFT 13
+#define __XSTORM_FCOE_AG_CONTEXT_AUX12_FLAG (0x1<<14)
+#define __XSTORM_FCOE_AG_CONTEXT_AUX12_FLAG_SHIFT 14
+#define __XSTORM_FCOE_AG_CONTEXT_AUX2_FLAG (0x1<<15)
+#define __XSTORM_FCOE_AG_CONTEXT_AUX2_FLAG_SHIFT 15
+#endif
+#if defined(__BIG_ENDIAN)
+	u16 __agg_val11_th;
+	u16 __agg_val11;
+#elif defined(__LITTLE_ENDIAN)
+	u16 __agg_val11;
+	u16 __agg_val11_th;
+#endif
+#if defined(__BIG_ENDIAN)
+	u8 __reserved1;
+	u8 __agg_val6_th;
+	u16 __confq_tx_prod;
+#elif defined(__LITTLE_ENDIAN)
+	u16 __confq_tx_prod;
+	u8 __agg_val6_th;
+	u8 __reserved1;
+#endif
+#if defined(__BIG_ENDIAN)
+	u16 confq_cons;
+	u16 confq_prod;
+#elif defined(__LITTLE_ENDIAN)
+	u16 confq_prod;
+	u16 confq_cons;
+#endif
+	u32 agg_vars8;
+#define __XSTORM_FCOE_AG_CONTEXT_CACHE_WQE_IDX (0xFFFFFF<<0)
+#define __XSTORM_FCOE_AG_CONTEXT_CACHE_WQE_IDX_SHIFT 0
+#define XSTORM_FCOE_AG_CONTEXT_AGG_MISC3 (0xFF<<24)
+#define XSTORM_FCOE_AG_CONTEXT_AGG_MISC3_SHIFT 24
+#if defined(__BIG_ENDIAN)
+	u16 ox_id;
+	u16 sq_prod;
+#elif defined(__LITTLE_ENDIAN)
+	u16 sq_prod;
+	u16 ox_id;
+#endif
+#if defined(__BIG_ENDIAN)
+	u8 agg_val3;
+	u8 agg_val6;
+	u8 agg_val5_th;
+	u8 agg_val5;
+#elif defined(__LITTLE_ENDIAN)
+	u8 agg_val5;
+	u8 agg_val5_th;
+	u8 agg_val6;
+	u8 agg_val3;
+#endif
+#if defined(__BIG_ENDIAN)
+	u16 __pbf_tx_seq_ack;
+	u16 agg_limit1;
+#elif defined(__LITTLE_ENDIAN)
+	u16 agg_limit1;
+	u16 __pbf_tx_seq_ack;
+#endif
+	u32 completion_seq;
+	u32 confq_pbl_base_lo;
+	u32 confq_pbl_base_hi;
+};
+
+/*
+ * The fcoe extra aggregative context section of Tstorm
+ */
+struct tstorm_fcoe_extra_ag_context_section {
+	u32 __agg_val1;
+#if defined(__BIG_ENDIAN)
+	u8 __tcp_agg_vars2;
+	u8 __agg_val3;
+	u16 __agg_val2;
+#elif defined(__LITTLE_ENDIAN)
+	u16 __agg_val2;
+	u8 __agg_val3;
+	u8 __tcp_agg_vars2;
+#endif
+#if defined(__BIG_ENDIAN)
+	u16 __agg_val5;
+	u8 __agg_val6;
+	u8 __tcp_agg_vars3;
+#elif defined(__LITTLE_ENDIAN)
+	u8 __tcp_agg_vars3;
+	u8 __agg_val6;
+	u16 __agg_val5;
+#endif
+	u32 __lcq_prod;
+	u32 rtt_seq;
+	u32 rtt_time;
+	u32 __reserved66;
+	u32 wnd_right_edge;
+	u32 tcp_agg_vars1;
+#define TSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_FIN_SENT_FLAG (0x1<<0)
+#define TSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_FIN_SENT_FLAG_SHIFT 0
+#define TSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_LAST_PACKET_FIN_FLAG (0x1<<1)
+#define TSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_LAST_PACKET_FIN_FLAG_SHIFT 1
+#define TSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_WND_UPD_CF (0x3<<2)
+#define TSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_WND_UPD_CF_SHIFT 2
+#define TSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_TIMEOUT_CF (0x3<<4)
+#define TSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_TIMEOUT_CF_SHIFT 4
+#define TSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_WND_UPD_CF_EN (0x1<<6)
+#define TSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_WND_UPD_CF_EN_SHIFT 6
+#define TSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_TIMEOUT_CF_EN (0x1<<7)
+#define TSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_TIMEOUT_CF_EN_SHIFT 7
+#define TSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_RETRANSMIT_SEQ_EN (0x1<<8)
+#define TSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_RETRANSMIT_SEQ_EN_SHIFT 8
+#define __TSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_LCQ_SND_EN (0x1<<9)
+#define __TSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_LCQ_SND_EN_SHIFT 9
+#define TSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_AUX1_FLAG (0x1<<10)
+#define TSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_AUX1_FLAG_SHIFT 10
+#define TSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_AUX2_FLAG (0x1<<11)
+#define TSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_AUX2_FLAG_SHIFT 11
+#define TSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_AUX1_CF_EN (0x1<<12)
+#define TSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_AUX1_CF_EN_SHIFT 12
+#define TSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_AUX2_CF_EN (0x1<<13)
+#define TSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_AUX2_CF_EN_SHIFT 13
+#define TSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_AUX1_CF (0x3<<14)
+#define TSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_AUX1_CF_SHIFT 14
+#define TSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_AUX2_CF (0x3<<16)
+#define TSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_AUX2_CF_SHIFT 16
+#define TSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_TX_BLOCKED (0x1<<18)
+#define TSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_TX_BLOCKED_SHIFT 18
+#define __TSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_AUX10_CF_EN (0x1<<19)
+#define __TSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_AUX10_CF_EN_SHIFT 19
+#define __TSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_AUX11_CF_EN (0x1<<20)
+#define __TSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_AUX11_CF_EN_SHIFT 20
+#define __TSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_AUX12_CF_EN (0x1<<21)
+#define __TSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_AUX12_CF_EN_SHIFT 21
+#define __TSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_RESERVED1 (0x3<<22)
+#define __TSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_RESERVED1_SHIFT 22
+#define TSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_RETRANSMIT_PEND_SEQ (0xF<<24)
+#define TSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_RETRANSMIT_PEND_SEQ_SHIFT 24
+#define TSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_RETRANSMIT_DONE_SEQ (0xF<<28)
+#define TSTORM_FCOE_EXTRA_AG_CONTEXT_SECTION_RETRANSMIT_DONE_SEQ_SHIFT 28
+	u32 snd_max;
+	u32 __lcq_cons;
+	u32 __reserved2;
+};
+
+/*
+ * The fcoe aggregative context of Tstorm
+ */
+struct tstorm_fcoe_ag_context {
+#if defined(__BIG_ENDIAN)
+	u16 ulp_credit;
+	u8 agg_vars1;
+#define TSTORM_FCOE_AG_CONTEXT_EXISTS_IN_QM0 (0x1<<0)
+#define TSTORM_FCOE_AG_CONTEXT_EXISTS_IN_QM0_SHIFT 0
+#define TSTORM_FCOE_AG_CONTEXT_EXISTS_IN_QM1 (0x1<<1)
+#define TSTORM_FCOE_AG_CONTEXT_EXISTS_IN_QM1_SHIFT 1
+#define TSTORM_FCOE_AG_CONTEXT_EXISTS_IN_QM2 (0x1<<2)
+#define TSTORM_FCOE_AG_CONTEXT_EXISTS_IN_QM2_SHIFT 2
+#define TSTORM_FCOE_AG_CONTEXT_EXISTS_IN_QM3 (0x1<<3)
+#define TSTORM_FCOE_AG_CONTEXT_EXISTS_IN_QM3_SHIFT 3
+#define __TSTORM_FCOE_AG_CONTEXT_QUEUE0_FLUSH_CF (0x3<<4)
+#define __TSTORM_FCOE_AG_CONTEXT_QUEUE0_FLUSH_CF_SHIFT 4
+#define __TSTORM_FCOE_AG_CONTEXT_AUX3_FLAG (0x1<<6)
+#define __TSTORM_FCOE_AG_CONTEXT_AUX3_FLAG_SHIFT 6
+#define __TSTORM_FCOE_AG_CONTEXT_AUX4_FLAG (0x1<<7)
+#define __TSTORM_FCOE_AG_CONTEXT_AUX4_FLAG_SHIFT 7
+	u8 state;
+#elif defined(__LITTLE_ENDIAN)
+	u8 state;
+	u8 agg_vars1;
+#define TSTORM_FCOE_AG_CONTEXT_EXISTS_IN_QM0 (0x1<<0)
+#define TSTORM_FCOE_AG_CONTEXT_EXISTS_IN_QM0_SHIFT 0
+#define TSTORM_FCOE_AG_CONTEXT_EXISTS_IN_QM1 (0x1<<1)
+#define TSTORM_FCOE_AG_CONTEXT_EXISTS_IN_QM1_SHIFT 1
+#define TSTORM_FCOE_AG_CONTEXT_EXISTS_IN_QM2 (0x1<<2)
+#define TSTORM_FCOE_AG_CONTEXT_EXISTS_IN_QM2_SHIFT 2
+#define TSTORM_FCOE_AG_CONTEXT_EXISTS_IN_QM3 (0x1<<3)
+#define TSTORM_FCOE_AG_CONTEXT_EXISTS_IN_QM3_SHIFT 3
+#define __TSTORM_FCOE_AG_CONTEXT_QUEUE0_FLUSH_CF (0x3<<4)
+#define __TSTORM_FCOE_AG_CONTEXT_QUEUE0_FLUSH_CF_SHIFT 4
+#define __TSTORM_FCOE_AG_CONTEXT_AUX3_FLAG (0x1<<6)
+#define __TSTORM_FCOE_AG_CONTEXT_AUX3_FLAG_SHIFT 6
+#define __TSTORM_FCOE_AG_CONTEXT_AUX4_FLAG (0x1<<7)
+#define __TSTORM_FCOE_AG_CONTEXT_AUX4_FLAG_SHIFT 7
+	u16 ulp_credit;
+#endif
+#if defined(__BIG_ENDIAN)
+	u16 __agg_val4;
+	u16 agg_vars2;
+#define __TSTORM_FCOE_AG_CONTEXT_AUX5_FLAG (0x1<<0)
+#define __TSTORM_FCOE_AG_CONTEXT_AUX5_FLAG_SHIFT 0
+#define __TSTORM_FCOE_AG_CONTEXT_AUX6_FLAG (0x1<<1)
+#define __TSTORM_FCOE_AG_CONTEXT_AUX6_FLAG_SHIFT 1
+#define __TSTORM_FCOE_AG_CONTEXT_AUX4_CF (0x3<<2)
+#define __TSTORM_FCOE_AG_CONTEXT_AUX4_CF_SHIFT 2
+#define __TSTORM_FCOE_AG_CONTEXT_AUX5_CF (0x3<<4)
+#define __TSTORM_FCOE_AG_CONTEXT_AUX5_CF_SHIFT 4
+#define __TSTORM_FCOE_AG_CONTEXT_AUX6_CF (0x3<<6)
+#define __TSTORM_FCOE_AG_CONTEXT_AUX6_CF_SHIFT 6
+#define __TSTORM_FCOE_AG_CONTEXT_AUX7_CF (0x3<<8)
+#define __TSTORM_FCOE_AG_CONTEXT_AUX7_CF_SHIFT 8
+#define __TSTORM_FCOE_AG_CONTEXT_AUX7_FLAG (0x1<<10)
+#define __TSTORM_FCOE_AG_CONTEXT_AUX7_FLAG_SHIFT 10
+#define __TSTORM_FCOE_AG_CONTEXT_QUEUE0_FLUSH_CF_EN (0x1<<11)
+#define __TSTORM_FCOE_AG_CONTEXT_QUEUE0_FLUSH_CF_EN_SHIFT 11
+#define TSTORM_FCOE_AG_CONTEXT_AUX4_CF_EN (0x1<<12)
+#define TSTORM_FCOE_AG_CONTEXT_AUX4_CF_EN_SHIFT 12
+#define TSTORM_FCOE_AG_CONTEXT_AUX5_CF_EN (0x1<<13)
+#define TSTORM_FCOE_AG_CONTEXT_AUX5_CF_EN_SHIFT 13
+#define TSTORM_FCOE_AG_CONTEXT_AUX6_CF_EN (0x1<<14)
+#define TSTORM_FCOE_AG_CONTEXT_AUX6_CF_EN_SHIFT 14
+#define TSTORM_FCOE_AG_CONTEXT_AUX7_CF_EN (0x1<<15)
+#define TSTORM_FCOE_AG_CONTEXT_AUX7_CF_EN_SHIFT 15
+#elif defined(__LITTLE_ENDIAN)
+	u16 agg_vars2;
+#define __TSTORM_FCOE_AG_CONTEXT_AUX5_FLAG (0x1<<0)
+#define __TSTORM_FCOE_AG_CONTEXT_AUX5_FLAG_SHIFT 0
+#define __TSTORM_FCOE_AG_CONTEXT_AUX6_FLAG (0x1<<1)
+#define __TSTORM_FCOE_AG_CONTEXT_AUX6_FLAG_SHIFT 1
+#define __TSTORM_FCOE_AG_CONTEXT_AUX4_CF (0x3<<2)
+#define __TSTORM_FCOE_AG_CONTEXT_AUX4_CF_SHIFT 2
+#define __TSTORM_FCOE_AG_CONTEXT_AUX5_CF (0x3<<4)
+#define __TSTORM_FCOE_AG_CONTEXT_AUX5_CF_SHIFT 4
+#define __TSTORM_FCOE_AG_CONTEXT_AUX6_CF (0x3<<6)
+#define __TSTORM_FCOE_AG_CONTEXT_AUX6_CF_SHIFT 6
+#define __TSTORM_FCOE_AG_CONTEXT_AUX7_CF (0x3<<8)
+#define __TSTORM_FCOE_AG_CONTEXT_AUX7_CF_SHIFT 8
+#define __TSTORM_FCOE_AG_CONTEXT_AUX7_FLAG (0x1<<10)
+#define __TSTORM_FCOE_AG_CONTEXT_AUX7_FLAG_SHIFT 10
+#define __TSTORM_FCOE_AG_CONTEXT_QUEUE0_FLUSH_CF_EN (0x1<<11)
+#define __TSTORM_FCOE_AG_CONTEXT_QUEUE0_FLUSH_CF_EN_SHIFT 11
+#define TSTORM_FCOE_AG_CONTEXT_AUX4_CF_EN (0x1<<12)
+#define TSTORM_FCOE_AG_CONTEXT_AUX4_CF_EN_SHIFT 12
+#define TSTORM_FCOE_AG_CONTEXT_AUX5_CF_EN (0x1<<13)
+#define TSTORM_FCOE_AG_CONTEXT_AUX5_CF_EN_SHIFT 13
+#define TSTORM_FCOE_AG_CONTEXT_AUX6_CF_EN (0x1<<14)
+#define TSTORM_FCOE_AG_CONTEXT_AUX6_CF_EN_SHIFT 14
+#define TSTORM_FCOE_AG_CONTEXT_AUX7_CF_EN (0x1<<15)
+#define TSTORM_FCOE_AG_CONTEXT_AUX7_CF_EN_SHIFT 15
+	u16 __agg_val4;
+#endif
+	struct tstorm_fcoe_extra_ag_context_section __extra_section;
+};
+
+/*
+ * The fcoe aggregative context of Ustorm
+ */
+struct ustorm_fcoe_ag_context {
+#if defined(__BIG_ENDIAN)
+	u8 __aux_counter_flags;
+	u8 agg_vars2;
+#define USTORM_FCOE_AG_CONTEXT_TX_CF (0x3<<0)
+#define USTORM_FCOE_AG_CONTEXT_TX_CF_SHIFT 0
+#define __USTORM_FCOE_AG_CONTEXT_TIMER_CF (0x3<<2)
+#define __USTORM_FCOE_AG_CONTEXT_TIMER_CF_SHIFT 2
+#define USTORM_FCOE_AG_CONTEXT_AGG_MISC4_RULE (0x7<<4)
+#define USTORM_FCOE_AG_CONTEXT_AGG_MISC4_RULE_SHIFT 4
+#define __USTORM_FCOE_AG_CONTEXT_AGG_VAL2_MASK (0x1<<7)
+#define __USTORM_FCOE_AG_CONTEXT_AGG_VAL2_MASK_SHIFT 7
+	u8 agg_vars1;
+#define __USTORM_FCOE_AG_CONTEXT_EXISTS_IN_QM0 (0x1<<0)
+#define __USTORM_FCOE_AG_CONTEXT_EXISTS_IN_QM0_SHIFT 0
+#define USTORM_FCOE_AG_CONTEXT_EXISTS_IN_QM1 (0x1<<1)
+#define USTORM_FCOE_AG_CONTEXT_EXISTS_IN_QM1_SHIFT 1
+#define USTORM_FCOE_AG_CONTEXT_EXISTS_IN_QM2 (0x1<<2)
+#define USTORM_FCOE_AG_CONTEXT_EXISTS_IN_QM2_SHIFT 2
+#define USTORM_FCOE_AG_CONTEXT_EXISTS_IN_QM3 (0x1<<3)
+#define USTORM_FCOE_AG_CONTEXT_EXISTS_IN_QM3_SHIFT 3
+#define USTORM_FCOE_AG_CONTEXT_INV_CF (0x3<<4)
+#define USTORM_FCOE_AG_CONTEXT_INV_CF_SHIFT 4
+#define USTORM_FCOE_AG_CONTEXT_COMPLETION_CF (0x3<<6)
+#define USTORM_FCOE_AG_CONTEXT_COMPLETION_CF_SHIFT 6
+	u8 state;
+#elif defined(__LITTLE_ENDIAN)
+	u8 state;
+	u8 agg_vars1;
+#define __USTORM_FCOE_AG_CONTEXT_EXISTS_IN_QM0 (0x1<<0)
+#define __USTORM_FCOE_AG_CONTEXT_EXISTS_IN_QM0_SHIFT 0
+#define USTORM_FCOE_AG_CONTEXT_EXISTS_IN_QM1 (0x1<<1)
+#define USTORM_FCOE_AG_CONTEXT_EXISTS_IN_QM1_SHIFT 1
+#define USTORM_FCOE_AG_CONTEXT_EXISTS_IN_QM2 (0x1<<2)
+#define USTORM_FCOE_AG_CONTEXT_EXISTS_IN_QM2_SHIFT 2
+#define USTORM_FCOE_AG_CONTEXT_EXISTS_IN_QM3 (0x1<<3)
+#define USTORM_FCOE_AG_CONTEXT_EXISTS_IN_QM3_SHIFT 3
+#define USTORM_FCOE_AG_CONTEXT_INV_CF (0x3<<4)
+#define USTORM_FCOE_AG_CONTEXT_INV_CF_SHIFT 4
+#define USTORM_FCOE_AG_CONTEXT_COMPLETION_CF (0x3<<6)
+#define USTORM_FCOE_AG_CONTEXT_COMPLETION_CF_SHIFT 6
+	u8 agg_vars2;
+#define USTORM_FCOE_AG_CONTEXT_TX_CF (0x3<<0)
+#define USTORM_FCOE_AG_CONTEXT_TX_CF_SHIFT 0
+#define __USTORM_FCOE_AG_CONTEXT_TIMER_CF (0x3<<2)
+#define __USTORM_FCOE_AG_CONTEXT_TIMER_CF_SHIFT 2
+#define USTORM_FCOE_AG_CONTEXT_AGG_MISC4_RULE (0x7<<4)
+#define USTORM_FCOE_AG_CONTEXT_AGG_MISC4_RULE_SHIFT 4
+#define __USTORM_FCOE_AG_CONTEXT_AGG_VAL2_MASK (0x1<<7)
+#define __USTORM_FCOE_AG_CONTEXT_AGG_VAL2_MASK_SHIFT 7
+	u8 __aux_counter_flags;
+#endif
+#if defined(__BIG_ENDIAN)
+	u8 cdu_usage;
+	u8 agg_misc2;
+	u16 pbf_tx_seq_ack;
+#elif defined(__LITTLE_ENDIAN)
+	u16 pbf_tx_seq_ack;
+	u8 agg_misc2;
+	u8 cdu_usage;
+#endif
+	u32 agg_misc4;
+#if defined(__BIG_ENDIAN)
+	u8 agg_val3_th;
+	u8 agg_val3;
+	u16 agg_misc3;
+#elif defined(__LITTLE_ENDIAN)
+	u16 agg_misc3;
+	u8 agg_val3;
+	u8 agg_val3_th;
+#endif
+	u32 expired_task_id;
+	u32 agg_misc4_th;
+#if defined(__BIG_ENDIAN)
+	u16 cq_prod;
+	u16 cq_cons;
+#elif defined(__LITTLE_ENDIAN)
+	u16 cq_cons;
+	u16 cq_prod;
+#endif
+#if defined(__BIG_ENDIAN)
+	u16 __reserved2;
+	u8 decision_rules;
+#define USTORM_FCOE_AG_CONTEXT_CQ_DEC_RULE (0x7<<0)
+#define USTORM_FCOE_AG_CONTEXT_CQ_DEC_RULE_SHIFT 0
+#define __USTORM_FCOE_AG_CONTEXT_AGG_VAL3_RULE (0x7<<3)
+#define __USTORM_FCOE_AG_CONTEXT_AGG_VAL3_RULE_SHIFT 3
+#define USTORM_FCOE_AG_CONTEXT_CQ_ARM_N_FLAG (0x1<<6)
+#define USTORM_FCOE_AG_CONTEXT_CQ_ARM_N_FLAG_SHIFT 6
+#define __USTORM_FCOE_AG_CONTEXT_RESERVED1 (0x1<<7)
+#define __USTORM_FCOE_AG_CONTEXT_RESERVED1_SHIFT 7
+	u8 decision_rule_enable_bits;
+#define __USTORM_FCOE_AG_CONTEXT_RESERVED_INV_CF_EN (0x1<<0)
+#define __USTORM_FCOE_AG_CONTEXT_RESERVED_INV_CF_EN_SHIFT 0
+#define USTORM_FCOE_AG_CONTEXT_COMPLETION_CF_EN (0x1<<1)
+#define USTORM_FCOE_AG_CONTEXT_COMPLETION_CF_EN_SHIFT 1
+#define USTORM_FCOE_AG_CONTEXT_TX_CF_EN (0x1<<2)
+#define USTORM_FCOE_AG_CONTEXT_TX_CF_EN_SHIFT 2
+#define __USTORM_FCOE_AG_CONTEXT_TIMER_CF_EN (0x1<<3)
+#define __USTORM_FCOE_AG_CONTEXT_TIMER_CF_EN_SHIFT 3
+#define __USTORM_FCOE_AG_CONTEXT_AUX1_CF_EN (0x1<<4)
+#define __USTORM_FCOE_AG_CONTEXT_AUX1_CF_EN_SHIFT 4
+#define __USTORM_FCOE_AG_CONTEXT_QUEUE0_CF_EN (0x1<<5)
+#define __USTORM_FCOE_AG_CONTEXT_QUEUE0_CF_EN_SHIFT 5
+#define __USTORM_FCOE_AG_CONTEXT_AUX3_CF_EN (0x1<<6)
+#define __USTORM_FCOE_AG_CONTEXT_AUX3_CF_EN_SHIFT 6
+#define __USTORM_FCOE_AG_CONTEXT_DQ_CF_EN (0x1<<7)
+#define __USTORM_FCOE_AG_CONTEXT_DQ_CF_EN_SHIFT 7
+#elif defined(__LITTLE_ENDIAN)
+	u8 decision_rule_enable_bits;
+#define __USTORM_FCOE_AG_CONTEXT_RESERVED_INV_CF_EN (0x1<<0)
+#define __USTORM_FCOE_AG_CONTEXT_RESERVED_INV_CF_EN_SHIFT 0
+#define USTORM_FCOE_AG_CONTEXT_COMPLETION_CF_EN (0x1<<1)
+#define USTORM_FCOE_AG_CONTEXT_COMPLETION_CF_EN_SHIFT 1
+#define USTORM_FCOE_AG_CONTEXT_TX_CF_EN (0x1<<2)
+#define USTORM_FCOE_AG_CONTEXT_TX_CF_EN_SHIFT 2
+#define __USTORM_FCOE_AG_CONTEXT_TIMER_CF_EN (0x1<<3)
+#define __USTORM_FCOE_AG_CONTEXT_TIMER_CF_EN_SHIFT 3
+#define __USTORM_FCOE_AG_CONTEXT_AUX1_CF_EN (0x1<<4)
+#define __USTORM_FCOE_AG_CONTEXT_AUX1_CF_EN_SHIFT 4
+#define __USTORM_FCOE_AG_CONTEXT_QUEUE0_CF_EN (0x1<<5)
+#define __USTORM_FCOE_AG_CONTEXT_QUEUE0_CF_EN_SHIFT 5
+#define __USTORM_FCOE_AG_CONTEXT_AUX3_CF_EN (0x1<<6)
+#define __USTORM_FCOE_AG_CONTEXT_AUX3_CF_EN_SHIFT 6
+#define __USTORM_FCOE_AG_CONTEXT_DQ_CF_EN (0x1<<7)
+#define __USTORM_FCOE_AG_CONTEXT_DQ_CF_EN_SHIFT 7
+	u8 decision_rules;
+#define USTORM_FCOE_AG_CONTEXT_CQ_DEC_RULE (0x7<<0)
+#define USTORM_FCOE_AG_CONTEXT_CQ_DEC_RULE_SHIFT 0
+#define __USTORM_FCOE_AG_CONTEXT_AGG_VAL3_RULE (0x7<<3)
+#define __USTORM_FCOE_AG_CONTEXT_AGG_VAL3_RULE_SHIFT 3
+#define USTORM_FCOE_AG_CONTEXT_CQ_ARM_N_FLAG (0x1<<6)
+#define USTORM_FCOE_AG_CONTEXT_CQ_ARM_N_FLAG_SHIFT 6
+#define __USTORM_FCOE_AG_CONTEXT_RESERVED1 (0x1<<7)
+#define __USTORM_FCOE_AG_CONTEXT_RESERVED1_SHIFT 7
+	u16 __reserved2;
+#endif
+};
+
+/*
+ * Ethernet context section
+ */
+struct xstorm_fcoe_eth_context_section {
+#if defined(__BIG_ENDIAN)
+	u8 remote_addr_4;
+	u8 remote_addr_5;
+	u8 local_addr_0;
+	u8 local_addr_1;
+#elif defined(__LITTLE_ENDIAN)
+	u8 local_addr_1;
+	u8 local_addr_0;
+	u8 remote_addr_5;
+	u8 remote_addr_4;
+#endif
+#if defined(__BIG_ENDIAN)
+	u8 remote_addr_0;
+	u8 remote_addr_1;
+	u8 remote_addr_2;
+	u8 remote_addr_3;
+#elif defined(__LITTLE_ENDIAN)
+	u8 remote_addr_3;
+	u8 remote_addr_2;
+	u8 remote_addr_1;
+	u8 remote_addr_0;
+#endif
+#if defined(__BIG_ENDIAN)
+	u16 reserved_vlan_type;
+	u16 params;
+#define XSTORM_FCOE_ETH_CONTEXT_SECTION_VLAN_ID (0xFFF<<0)
+#define XSTORM_FCOE_ETH_CONTEXT_SECTION_VLAN_ID_SHIFT 0
+#define XSTORM_FCOE_ETH_CONTEXT_SECTION_CFI (0x1<<12)
+#define XSTORM_FCOE_ETH_CONTEXT_SECTION_CFI_SHIFT 12
+#define XSTORM_FCOE_ETH_CONTEXT_SECTION_PRIORITY (0x7<<13)
+#define XSTORM_FCOE_ETH_CONTEXT_SECTION_PRIORITY_SHIFT 13
+#elif defined(__LITTLE_ENDIAN)
+	u16 params;
+#define XSTORM_FCOE_ETH_CONTEXT_SECTION_VLAN_ID (0xFFF<<0)
+#define XSTORM_FCOE_ETH_CONTEXT_SECTION_VLAN_ID_SHIFT 0
+#define XSTORM_FCOE_ETH_CONTEXT_SECTION_CFI (0x1<<12)
+#define XSTORM_FCOE_ETH_CONTEXT_SECTION_CFI_SHIFT 12
+#define XSTORM_FCOE_ETH_CONTEXT_SECTION_PRIORITY (0x7<<13)
+#define XSTORM_FCOE_ETH_CONTEXT_SECTION_PRIORITY_SHIFT 13
+	u16 reserved_vlan_type;
+#endif
+#if defined(__BIG_ENDIAN)
+	u8 local_addr_2;
+	u8 local_addr_3;
+	u8 local_addr_4;
+	u8 local_addr_5;
+#elif defined(__LITTLE_ENDIAN)
+	u8 local_addr_5;
+	u8 local_addr_4;
+	u8 local_addr_3;
+	u8 local_addr_2;
+#endif
+};
+
+/*
+ * Flags used in FCoE context section - 1 byte
+ */
+struct xstorm_fcoe_context_flags {
+	u8 flags;
+#define XSTORM_FCOE_CONTEXT_FLAGS_B_PROC_Q (0x3<<0)
+#define XSTORM_FCOE_CONTEXT_FLAGS_B_PROC_Q_SHIFT 0
+#define XSTORM_FCOE_CONTEXT_FLAGS_B_MID_SEQ (0x1<<2)
+#define XSTORM_FCOE_CONTEXT_FLAGS_B_MID_SEQ_SHIFT 2
+#define XSTORM_FCOE_CONTEXT_FLAGS_B_EXCHANGE_CLEANUP_DEFFERED (0x1<<3)
+#define XSTORM_FCOE_CONTEXT_FLAGS_B_EXCHANGE_CLEANUP_DEFFERED_SHIFT 3
+#define XSTORM_FCOE_CONTEXT_FLAGS_B_REC_SUPPORT (0x1<<4)
+#define XSTORM_FCOE_CONTEXT_FLAGS_B_REC_SUPPORT_SHIFT 4
+#define XSTORM_FCOE_CONTEXT_FLAGS_B_SQ_TOGGLE (0x1<<5)
+#define XSTORM_FCOE_CONTEXT_FLAGS_B_SQ_TOGGLE_SHIFT 5
+#define XSTORM_FCOE_CONTEXT_FLAGS_B_XFRQ_TOGGLE (0x1<<6)
+#define XSTORM_FCOE_CONTEXT_FLAGS_B_XFRQ_TOGGLE_SHIFT 6
+#define XSTORM_FCOE_CONTEXT_FLAGS_B_ABTS_DEFFERED (0x1<<7)
+#define XSTORM_FCOE_CONTEXT_FLAGS_B_ABTS_DEFFERED_SHIFT 7
+};
+
+/*
+ * FCoE SQ element
+ */
+struct fcoe_sqe {
+	u16 wqe;
+#define FCOE_SQE_TASK_ID (0x7FFF<<0)
+#define FCOE_SQE_TASK_ID_SHIFT 0
+#define FCOE_SQE_TOGGLE_BIT (0x1<<15)
+#define FCOE_SQE_TOGGLE_BIT_SHIFT 15
+};
+
+/*
+ * FCoE XFRQ element
+ */
+struct fcoe_xfrqe {
+	u16 wqe;
+#define FCOE_XFRQE_TASK_ID (0x7FFF<<0)
+#define FCOE_XFRQE_TASK_ID_SHIFT 0
+#define FCOE_XFRQE_TOGGLE_BIT (0x1<<15)
+#define FCOE_XFRQE_TOGGLE_BIT_SHIFT 15
+};
+
+/*
+ * FCoE SQ\XFRQ element
+ */
+struct fcoe_cached_wqe {
+#if defined(__BIG_ENDIAN)
+	struct fcoe_xfrqe xfrqe;
+	struct fcoe_sqe sqe;
+#elif defined(__LITTLE_ENDIAN)
+	struct fcoe_sqe sqe;
+	struct fcoe_xfrqe xfrqe;
+#endif
+};
+
+struct fcoe_task_ctx_entry_tx_only {
+	union fcoe_sgl_ctx sgl_ctx;
+};
+
+struct xstorm_fcoe_task_ctx_entry_rd {
+	struct fcoe_task_ctx_entry_tx_only tx_wr;
+	struct fcoe_task_ctx_entry_txwr_rxrd tx_wr_rx_rd;
+	struct fcoe_task_ctx_entry_tx_rx_cmn cmn;
+	struct fcoe_task_ctx_entry_rxwr_txrd rx_wr_tx_rd;
+};
+
+/*
+ * Cached SGEs
+ */
+struct common_fcoe_sgl {
+	struct fcoe_bd_ctx sge[2];
+};
+
+/*
+ * FCP_DATA parameters required for transmission
+ */
+struct xstorm_fcoe_fcp_data {
+	u32 io_rem;
+#if defined(__BIG_ENDIAN)
+	u16 cached_sge_off;
+	u8 cached_num_sges;
+	u8 cached_sge_idx;
+#elif defined(__LITTLE_ENDIAN)
+	u8 cached_sge_idx;
+	u8 cached_num_sges;
+	u16 cached_sge_off;
+#endif
+	struct common_fcoe_sgl cached_sgl;
+};
+
+/*
+ * FCoE context section
+ */
+struct xstorm_fcoe_context_section {
+#if defined(__BIG_ENDIAN)
+	u8 vlan_flag;
+	u8 s_id[3];
+#elif defined(__LITTLE_ENDIAN)
+	u8 s_id[3];
+	u8 vlan_flag;
+#endif
+#if defined(__BIG_ENDIAN)
+	u8 func_id;
+	u8 d_id[3];
+#elif defined(__LITTLE_ENDIAN)
+	u8 d_id[3];
+	u8 func_id;
+#endif
+#if defined(__BIG_ENDIAN)
+	u16 sq_xfrq_lcq_confq_size;
+	u16 tx_max_fc_pay_len;
+#elif defined(__LITTLE_ENDIAN)
+	u16 tx_max_fc_pay_len;
+	u16 sq_xfrq_lcq_confq_size;
+#endif
+	u32 lcq_prod;
+#if defined(__BIG_ENDIAN)
+	u8 port_id;
+	u8 tx_max_conc_seqs_c3;
+	u8 seq_id;
+	struct xstorm_fcoe_context_flags tx_flags;
+#elif defined(__LITTLE_ENDIAN)
+	struct xstorm_fcoe_context_flags tx_flags;
+	u8 seq_id;
+	u8 tx_max_conc_seqs_c3;
+	u8 port_id;
+#endif
+#if defined(__BIG_ENDIAN)
+	u16 verify_tx_seq;
+	u8 func_mode;
+	u8 vnic_id;
+#elif defined(__LITTLE_ENDIAN)
+	u8 vnic_id;
+	u8 func_mode;
+	u16 verify_tx_seq;
+#endif
+	struct regpair confq_curr_page_addr;
+	struct fcoe_cached_wqe cached_wqe[8];
+	struct regpair lcq_base_addr;
+	struct xstorm_fcoe_task_ctx_entry_rd tce;
+	struct xstorm_fcoe_fcp_data fcp_data;
+#if defined(__BIG_ENDIAN)
+	u16 fcoe_tx_stat_params_ram_addr;
+	u16 cmng_port_ram_addr;
+#elif defined(__LITTLE_ENDIAN)
+	u16 cmng_port_ram_addr;
+	u16 fcoe_tx_stat_params_ram_addr;
+#endif
+#if defined(__BIG_ENDIAN)
+	u8 fcp_cmd_pb_cmd_size;
+	u8 eth_hdr_size;
+	u16 pbf_addr;
+#elif defined(__LITTLE_ENDIAN)
+	u16 pbf_addr;
+	u8 eth_hdr_size;
+	u8 fcp_cmd_pb_cmd_size;
+#endif
+#if defined(__BIG_ENDIAN)
+	u8 reserved2[2];
+	u8 cos;
+	u8 dcb_version;
+#elif defined(__LITTLE_ENDIAN)
+	u8 dcb_version;
+	u8 cos;
+	u8 reserved2[2];
+#endif
+	u32 reserved3;
+	struct regpair reserved4[2];
+};
+
+/*
+ * Xstorm FCoE Storm Context
+ */
+struct xstorm_fcoe_st_context {
+	struct xstorm_fcoe_eth_context_section eth;
+	struct xstorm_fcoe_context_section fcoe;
+};
+
+/*
+ * Fcoe connection context
+ */
+struct fcoe_context {
+	struct ustorm_fcoe_st_context ustorm_st_context;
+	struct tstorm_fcoe_st_context tstorm_st_context;
+	struct xstorm_fcoe_ag_context xstorm_ag_context;
+	struct tstorm_fcoe_ag_context tstorm_ag_context;
+	struct ustorm_fcoe_ag_context ustorm_ag_context;
+	struct timers_block_context timers_context;
+	struct xstorm_fcoe_st_context xstorm_st_context;
+};
+
+/*
  * iSCSI context region, used only in iSCSI
  */
 struct ustorm_iscsi_rq_db {
@@ -2268,6 +3792,577 @@ struct iscsi_context {
 };
 
 /*
+ * FCoE KCQ CQE parameters
+ */
+union fcoe_kcqe_params {
+	u32 reserved0[4];
+};
+
+/*
+ * FCoE KCQ CQE
+ */
+struct fcoe_kcqe {
+	u32 fcoe_conn_id;
+	u32 completion_status;
+	u32 fcoe_conn_context_id;
+	union fcoe_kcqe_params params;
+#if defined(__BIG_ENDIAN)
+	u8 flags;
+#define FCOE_KCQE_RESERVED0 (0x7<<0)
+#define FCOE_KCQE_RESERVED0_SHIFT 0
+#define FCOE_KCQE_RAMROD_COMPLETION (0x1<<3)
+#define FCOE_KCQE_RAMROD_COMPLETION_SHIFT 3
+#define FCOE_KCQE_LAYER_CODE (0x7<<4)
+#define FCOE_KCQE_LAYER_CODE_SHIFT 4
+#define FCOE_KCQE_LINKED_WITH_NEXT (0x1<<7)
+#define FCOE_KCQE_LINKED_WITH_NEXT_SHIFT 7
+	u8 op_code;
+	u16 qe_self_seq;
+#elif defined(__LITTLE_ENDIAN)
+	u16 qe_self_seq;
+	u8 op_code;
+	u8 flags;
+#define FCOE_KCQE_RESERVED0 (0x7<<0)
+#define FCOE_KCQE_RESERVED0_SHIFT 0
+#define FCOE_KCQE_RAMROD_COMPLETION (0x1<<3)
+#define FCOE_KCQE_RAMROD_COMPLETION_SHIFT 3
+#define FCOE_KCQE_LAYER_CODE (0x7<<4)
+#define FCOE_KCQE_LAYER_CODE_SHIFT 4
+#define FCOE_KCQE_LINKED_WITH_NEXT (0x1<<7)
+#define FCOE_KCQE_LINKED_WITH_NEXT_SHIFT 7
+#endif
+};
+
+/*
+ * FCoE KWQE header
+ */
+struct fcoe_kwqe_header {
+#if defined(__BIG_ENDIAN)
+	u8 flags;
+#define FCOE_KWQE_HEADER_RESERVED0 (0xF<<0)
+#define FCOE_KWQE_HEADER_RESERVED0_SHIFT 0
+#define FCOE_KWQE_HEADER_LAYER_CODE (0x7<<4)
+#define FCOE_KWQE_HEADER_LAYER_CODE_SHIFT 4
+#define FCOE_KWQE_HEADER_RESERVED1 (0x1<<7)
+#define FCOE_KWQE_HEADER_RESERVED1_SHIFT 7
+	u8 op_code;
+#elif defined(__LITTLE_ENDIAN)
+	u8 op_code;
+	u8 flags;
+#define FCOE_KWQE_HEADER_RESERVED0 (0xF<<0)
+#define FCOE_KWQE_HEADER_RESERVED0_SHIFT 0
+#define FCOE_KWQE_HEADER_LAYER_CODE (0x7<<4)
+#define FCOE_KWQE_HEADER_LAYER_CODE_SHIFT 4
+#define FCOE_KWQE_HEADER_RESERVED1 (0x1<<7)
+#define FCOE_KWQE_HEADER_RESERVED1_SHIFT 7
+#endif
+};
+
+/*
+ * FCoE firmware init request 1
+ */
+struct fcoe_kwqe_init1 {
+#if defined(__BIG_ENDIAN)
+	struct fcoe_kwqe_header hdr;
+	u16 num_tasks;
+#elif defined(__LITTLE_ENDIAN)
+	u16 num_tasks;
+	struct fcoe_kwqe_header hdr;
+#endif
+	u32 task_list_pbl_addr_lo;
+	u32 task_list_pbl_addr_hi;
+	u32 dummy_buffer_addr_lo;
+	u32 dummy_buffer_addr_hi;
+#if defined(__BIG_ENDIAN)
+	u16 rq_num_wqes;
+	u16 sq_num_wqes;
+#elif defined(__LITTLE_ENDIAN)
+	u16 sq_num_wqes;
+	u16 rq_num_wqes;
+#endif
+#if defined(__BIG_ENDIAN)
+	u16 cq_num_wqes;
+	u16 rq_buffer_log_size;
+#elif defined(__LITTLE_ENDIAN)
+	u16 rq_buffer_log_size;
+	u16 cq_num_wqes;
+#endif
+#if defined(__BIG_ENDIAN)
+	u8 flags;
+#define FCOE_KWQE_INIT1_LOG_PAGE_SIZE (0xF<<0)
+#define FCOE_KWQE_INIT1_LOG_PAGE_SIZE_SHIFT 0
+#define FCOE_KWQE_INIT1_LOG_CACHED_PBES_PER_FUNC (0x7<<4)
+#define FCOE_KWQE_INIT1_LOG_CACHED_PBES_PER_FUNC_SHIFT 4
+#define FCOE_KWQE_INIT1_RESERVED1 (0x1<<7)
+#define FCOE_KWQE_INIT1_RESERVED1_SHIFT 7
+	u8 num_sessions_log;
+	u16 mtu;
+#elif defined(__LITTLE_ENDIAN)
+	u16 mtu;
+	u8 num_sessions_log;
+	u8 flags;
+#define FCOE_KWQE_INIT1_LOG_PAGE_SIZE (0xF<<0)
+#define FCOE_KWQE_INIT1_LOG_PAGE_SIZE_SHIFT 0
+#define FCOE_KWQE_INIT1_LOG_CACHED_PBES_PER_FUNC (0x7<<4)
+#define FCOE_KWQE_INIT1_LOG_CACHED_PBES_PER_FUNC_SHIFT 4
+#define FCOE_KWQE_INIT1_RESERVED1 (0x1<<7)
+#define FCOE_KWQE_INIT1_RESERVED1_SHIFT 7
+#endif
+};
+
+/*
+ * FCoE firmware init request 2
+ */
+struct fcoe_kwqe_init2 {
+#if defined(__BIG_ENDIAN)
+	struct fcoe_kwqe_header hdr;
+	u16 reserved0;
+#elif defined(__LITTLE_ENDIAN)
+	u16 reserved0;
+	struct fcoe_kwqe_header hdr;
+#endif
+	u32 hash_tbl_pbl_addr_lo;
+	u32 hash_tbl_pbl_addr_hi;
+	u32 t2_hash_tbl_addr_lo;
+	u32 t2_hash_tbl_addr_hi;
+	u32 t2_ptr_hash_tbl_addr_lo;
+	u32 t2_ptr_hash_tbl_addr_hi;
+	u32 free_list_count;
+};
+
+/*
+ * FCoE firmware init request 3
+ */
+struct fcoe_kwqe_init3 {
+#if defined(__BIG_ENDIAN)
+	struct fcoe_kwqe_header hdr;
+	u16 reserved0;
+#elif defined(__LITTLE_ENDIAN)
+	u16 reserved0;
+	struct fcoe_kwqe_header hdr;
+#endif
+	u32 error_bit_map_lo;
+	u32 error_bit_map_hi;
+#if defined(__BIG_ENDIAN)
+	u8 reserved21[3];
+	u8 cached_session_enable;
+#elif defined(__LITTLE_ENDIAN)
+	u8 cached_session_enable;
+	u8 reserved21[3];
+#endif
+	u32 reserved2[4];
+};
+
+/*
+ * FCoE connection offload request 1
+ */
+struct fcoe_kwqe_conn_offload1 {
+#if defined(__BIG_ENDIAN)
+	struct fcoe_kwqe_header hdr;
+	u16 fcoe_conn_id;
+#elif defined(__LITTLE_ENDIAN)
+	u16 fcoe_conn_id;
+	struct fcoe_kwqe_header hdr;
+#endif
+	u32 sq_addr_lo;
+	u32 sq_addr_hi;
+	u32 rq_pbl_addr_lo;
+	u32 rq_pbl_addr_hi;
+	u32 rq_first_pbe_addr_lo;
+	u32 rq_first_pbe_addr_hi;
+#if defined(__BIG_ENDIAN)
+	u16 reserved0;
+	u16 rq_prod;
+#elif defined(__LITTLE_ENDIAN)
+	u16 rq_prod;
+	u16 reserved0;
+#endif
+};
+
+/*
+ * FCoE connection offload request 2
+ */
+struct fcoe_kwqe_conn_offload2 {
+#if defined(__BIG_ENDIAN)
+	struct fcoe_kwqe_header hdr;
+	u16 tx_max_fc_pay_len;
+#elif defined(__LITTLE_ENDIAN)
+	u16 tx_max_fc_pay_len;
+	struct fcoe_kwqe_header hdr;
+#endif
+	u32 cq_addr_lo;
+	u32 cq_addr_hi;
+	u32 xferq_addr_lo;
+	u32 xferq_addr_hi;
+	u32 conn_db_addr_lo;
+	u32 conn_db_addr_hi;
+	u32 reserved1;
+};
+
+/*
+ * FCoE connection offload request 3
+ */
+struct fcoe_kwqe_conn_offload3 {
+#if defined(__BIG_ENDIAN)
+	struct fcoe_kwqe_header hdr;
+	u16 vlan_tag;
+#define FCOE_KWQE_CONN_OFFLOAD3_VLAN_ID (0xFFF<<0)
+#define FCOE_KWQE_CONN_OFFLOAD3_VLAN_ID_SHIFT 0
+#define FCOE_KWQE_CONN_OFFLOAD3_CFI (0x1<<12)
+#define FCOE_KWQE_CONN_OFFLOAD3_CFI_SHIFT 12
+#define FCOE_KWQE_CONN_OFFLOAD3_PRIORITY (0x7<<13)
+#define FCOE_KWQE_CONN_OFFLOAD3_PRIORITY_SHIFT 13
+#elif defined(__LITTLE_ENDIAN)
+	u16 vlan_tag;
+#define FCOE_KWQE_CONN_OFFLOAD3_VLAN_ID (0xFFF<<0)
+#define FCOE_KWQE_CONN_OFFLOAD3_VLAN_ID_SHIFT 0
+#define FCOE_KWQE_CONN_OFFLOAD3_CFI (0x1<<12)
+#define FCOE_KWQE_CONN_OFFLOAD3_CFI_SHIFT 12
+#define FCOE_KWQE_CONN_OFFLOAD3_PRIORITY (0x7<<13)
+#define FCOE_KWQE_CONN_OFFLOAD3_PRIORITY_SHIFT 13
+	struct fcoe_kwqe_header hdr;
+#endif
+#if defined(__BIG_ENDIAN)
+	u8 tx_max_conc_seqs_c3;
+	u8 s_id[3];
+#elif defined(__LITTLE_ENDIAN)
+	u8 s_id[3];
+	u8 tx_max_conc_seqs_c3;
+#endif
+#if defined(__BIG_ENDIAN)
+	u8 flags;
+#define FCOE_KWQE_CONN_OFFLOAD3_B_MUL_N_PORT_IDS (0x1<<0)
+#define FCOE_KWQE_CONN_OFFLOAD3_B_MUL_N_PORT_IDS_SHIFT 0
+#define FCOE_KWQE_CONN_OFFLOAD3_B_E_D_TOV_RES (0x1<<1)
+#define FCOE_KWQE_CONN_OFFLOAD3_B_E_D_TOV_RES_SHIFT 1
+#define FCOE_KWQE_CONN_OFFLOAD3_B_CONT_INCR_SEQ_CNT (0x1<<2)
+#define FCOE_KWQE_CONN_OFFLOAD3_B_CONT_INCR_SEQ_CNT_SHIFT 2
+#define FCOE_KWQE_CONN_OFFLOAD3_B_CONF_REQ (0x1<<3)
+#define FCOE_KWQE_CONN_OFFLOAD3_B_CONF_REQ_SHIFT 3
+#define FCOE_KWQE_CONN_OFFLOAD3_B_REC_VALID (0x1<<4)
+#define FCOE_KWQE_CONN_OFFLOAD3_B_REC_VALID_SHIFT 4
+#define FCOE_KWQE_CONN_OFFLOAD3_B_C2_VALID (0x1<<5)
+#define FCOE_KWQE_CONN_OFFLOAD3_B_C2_VALID_SHIFT 5
+#define FCOE_KWQE_CONN_OFFLOAD3_B_ACK_0 (0x1<<6)
+#define FCOE_KWQE_CONN_OFFLOAD3_B_ACK_0_SHIFT 6
+#define FCOE_KWQE_CONN_OFFLOAD3_B_VLAN_FLAG (0x1<<7)
+#define FCOE_KWQE_CONN_OFFLOAD3_B_VLAN_FLAG_SHIFT 7
+	u8 d_id[3];
+#elif defined(__LITTLE_ENDIAN)
+	u8 d_id[3];
+	u8 flags;
+#define FCOE_KWQE_CONN_OFFLOAD3_B_MUL_N_PORT_IDS (0x1<<0)
+#define FCOE_KWQE_CONN_OFFLOAD3_B_MUL_N_PORT_IDS_SHIFT 0
+#define FCOE_KWQE_CONN_OFFLOAD3_B_E_D_TOV_RES (0x1<<1)
+#define FCOE_KWQE_CONN_OFFLOAD3_B_E_D_TOV_RES_SHIFT 1
+#define FCOE_KWQE_CONN_OFFLOAD3_B_CONT_INCR_SEQ_CNT (0x1<<2)
+#define FCOE_KWQE_CONN_OFFLOAD3_B_CONT_INCR_SEQ_CNT_SHIFT 2
+#define FCOE_KWQE_CONN_OFFLOAD3_B_CONF_REQ (0x1<<3)
+#define FCOE_KWQE_CONN_OFFLOAD3_B_CONF_REQ_SHIFT 3
+#define FCOE_KWQE_CONN_OFFLOAD3_B_REC_VALID (0x1<<4)
+#define FCOE_KWQE_CONN_OFFLOAD3_B_REC_VALID_SHIFT 4
+#define FCOE_KWQE_CONN_OFFLOAD3_B_C2_VALID (0x1<<5)
+#define FCOE_KWQE_CONN_OFFLOAD3_B_C2_VALID_SHIFT 5
+#define FCOE_KWQE_CONN_OFFLOAD3_B_ACK_0 (0x1<<6)
+#define FCOE_KWQE_CONN_OFFLOAD3_B_ACK_0_SHIFT 6
+#define FCOE_KWQE_CONN_OFFLOAD3_B_VLAN_FLAG (0x1<<7)
+#define FCOE_KWQE_CONN_OFFLOAD3_B_VLAN_FLAG_SHIFT 7
+#endif
+	u32 reserved;
+	u32 confq_first_pbe_addr_lo;
+	u32 confq_first_pbe_addr_hi;
+#if defined(__BIG_ENDIAN)
+	u16 rx_max_fc_pay_len;
+	u16 tx_total_conc_seqs;
+#elif defined(__LITTLE_ENDIAN)
+	u16 tx_total_conc_seqs;
+	u16 rx_max_fc_pay_len;
+#endif
+#if defined(__BIG_ENDIAN)
+	u8 rx_open_seqs_exch_c3;
+	u8 rx_max_conc_seqs_c3;
+	u16 rx_total_conc_seqs;
+#elif defined(__LITTLE_ENDIAN)
+	u16 rx_total_conc_seqs;
+	u8 rx_max_conc_seqs_c3;
+	u8 rx_open_seqs_exch_c3;
+#endif
+};
+
+/*
+ * FCoE connection offload request 4
+ */
+struct fcoe_kwqe_conn_offload4 {
+#if defined(__BIG_ENDIAN)
+	struct fcoe_kwqe_header hdr;
+	u8 reserved2;
+	u8 e_d_tov_timer_val;
+#elif defined(__LITTLE_ENDIAN)
+	u8 e_d_tov_timer_val;
+	u8 reserved2;
+	struct fcoe_kwqe_header hdr;
+#endif
+	u8 src_mac_addr_lo32[4];
+#if defined(__BIG_ENDIAN)
+	u8 dst_mac_addr_hi16[2];
+	u8 src_mac_addr_hi16[2];
+#elif defined(__LITTLE_ENDIAN)
+	u8 src_mac_addr_hi16[2];
+	u8 dst_mac_addr_hi16[2];
+#endif
+	u8 dst_mac_addr_lo32[4];
+	u32 lcq_addr_lo;
+	u32 lcq_addr_hi;
+	u32 confq_pbl_base_addr_lo;
+	u32 confq_pbl_base_addr_hi;
+};
+
+/*
+ * FCoE connection enable request
+ */
+struct fcoe_kwqe_conn_enable_disable {
+#if defined(__BIG_ENDIAN)
+	struct fcoe_kwqe_header hdr;
+	u16 reserved0;
+#elif defined(__LITTLE_ENDIAN)
+	u16 reserved0;
+	struct fcoe_kwqe_header hdr;
+#endif
+	u8 src_mac_addr_lo32[4];
+#if defined(__BIG_ENDIAN)
+	u16 vlan_tag;
+#define FCOE_KWQE_CONN_ENABLE_DISABLE_VLAN_ID (0xFFF<<0)
+#define FCOE_KWQE_CONN_ENABLE_DISABLE_VLAN_ID_SHIFT 0
+#define FCOE_KWQE_CONN_ENABLE_DISABLE_CFI (0x1<<12)
+#define FCOE_KWQE_CONN_ENABLE_DISABLE_CFI_SHIFT 12
+#define FCOE_KWQE_CONN_ENABLE_DISABLE_PRIORITY (0x7<<13)
+#define FCOE_KWQE_CONN_ENABLE_DISABLE_PRIORITY_SHIFT 13
+	u8 src_mac_addr_hi16[2];
+#elif defined(__LITTLE_ENDIAN)
+	u8 src_mac_addr_hi16[2];
+	u16 vlan_tag;
+#define FCOE_KWQE_CONN_ENABLE_DISABLE_VLAN_ID (0xFFF<<0)
+#define FCOE_KWQE_CONN_ENABLE_DISABLE_VLAN_ID_SHIFT 0
+#define FCOE_KWQE_CONN_ENABLE_DISABLE_CFI (0x1<<12)
+#define FCOE_KWQE_CONN_ENABLE_DISABLE_CFI_SHIFT 12
+#define FCOE_KWQE_CONN_ENABLE_DISABLE_PRIORITY (0x7<<13)
+#define FCOE_KWQE_CONN_ENABLE_DISABLE_PRIORITY_SHIFT 13
+#endif
+	u8 dst_mac_addr_lo32[4];
+#if defined(__BIG_ENDIAN)
+	u16 reserved1;
+	u8 dst_mac_addr_hi16[2];
+#elif defined(__LITTLE_ENDIAN)
+	u8 dst_mac_addr_hi16[2];
+	u16 reserved1;
+#endif
+#if defined(__BIG_ENDIAN)
+	u8 vlan_flag;
+	u8 s_id[3];
+#elif defined(__LITTLE_ENDIAN)
+	u8 s_id[3];
+	u8 vlan_flag;
+#endif
+#if defined(__BIG_ENDIAN)
+	u8 reserved3;
+	u8 d_id[3];
+#elif defined(__LITTLE_ENDIAN)
+	u8 d_id[3];
+	u8 reserved3;
+#endif
+	u32 context_id;
+	u32 conn_id;
+	u32 reserved4;
+};
+
+/*
+ * FCoE connection destroy request
+ */
+struct fcoe_kwqe_conn_destroy {
+#if defined(__BIG_ENDIAN)
+	struct fcoe_kwqe_header hdr;
+	u16 reserved0;
+#elif defined(__LITTLE_ENDIAN)
+	u16 reserved0;
+	struct fcoe_kwqe_header hdr;
+#endif
+	u32 context_id;
+	u32 conn_id;
+	u32 reserved1[5];
+};
+
+/*
+ * FCoe destroy request
+ */
+struct fcoe_kwqe_destroy {
+#if defined(__BIG_ENDIAN)
+	struct fcoe_kwqe_header hdr;
+	u16 reserved0;
+#elif defined(__LITTLE_ENDIAN)
+	u16 reserved0;
+	struct fcoe_kwqe_header hdr;
+#endif
+	u32 reserved1[7];
+};
+
+/*
+ * FCoe statistics request
+ */
+struct fcoe_kwqe_stat {
+#if defined(__BIG_ENDIAN)
+	struct fcoe_kwqe_header hdr;
+	u16 reserved0;
+#elif defined(__LITTLE_ENDIAN)
+	u16 reserved0;
+	struct fcoe_kwqe_header hdr;
+#endif
+	u32 stat_params_addr_lo;
+	u32 stat_params_addr_hi;
+	u32 reserved1[5];
+};
+
+/*
+ * FCoE KWQ WQE
+ */
+union fcoe_kwqe {
+	struct fcoe_kwqe_init1 init1;
+	struct fcoe_kwqe_init2 init2;
+	struct fcoe_kwqe_init3 init3;
+	struct fcoe_kwqe_conn_offload1 conn_offload1;
+	struct fcoe_kwqe_conn_offload2 conn_offload2;
+	struct fcoe_kwqe_conn_offload3 conn_offload3;
+	struct fcoe_kwqe_conn_offload4 conn_offload4;
+	struct fcoe_kwqe_conn_enable_disable conn_enable_disable;
+	struct fcoe_kwqe_conn_destroy conn_destroy;
+	struct fcoe_kwqe_destroy destroy;
+	struct fcoe_kwqe_stat statistics;
+};
+
+struct fcoe_task_ctx_entry {
+	struct fcoe_task_ctx_entry_tx_only tx_wr_only;
+	struct fcoe_task_ctx_entry_txwr_rxrd tx_wr_rx_rd;
+	struct fcoe_task_ctx_entry_tx_rx_cmn cmn;
+	struct fcoe_task_ctx_entry_rxwr_txrd rx_wr_tx_rd;
+	struct fcoe_task_ctx_entry_rx_only rx_wr_only;
+	u32 reserved[4];
+};
+
+/*
+ * FCoE connection enable\disable params passed by driver to FW in FCoE enable ramrod
+ */
+struct fcoe_conn_enable_disable_ramrod_params {
+	struct fcoe_kwqe_conn_enable_disable enable_disable_kwqe;
+};
+
+
+/*
+ * FCoE connection offload params passed by driver to FW in FCoE offload ramrod
+ */
+struct fcoe_conn_offload_ramrod_params {
+	struct fcoe_kwqe_conn_offload1 offload_kwqe1;
+	struct fcoe_kwqe_conn_offload2 offload_kwqe2;
+	struct fcoe_kwqe_conn_offload3 offload_kwqe3;
+	struct fcoe_kwqe_conn_offload4 offload_kwqe4;
+};
+
+/*
+ * FCoE init params passed by driver to FW in FCoE init ramrod
+ */
+struct fcoe_init_ramrod_params {
+	struct fcoe_kwqe_init1 init_kwqe1;
+	struct fcoe_kwqe_init2 init_kwqe2;
+	struct fcoe_kwqe_init3 init_kwqe3;
+	struct regpair eq_addr;
+	struct regpair eq_next_page_addr;
+#if defined(__BIG_ENDIAN)
+	u16 sb_num;
+	u16 eq_prod;
+#elif defined(__LITTLE_ENDIAN)
+	u16 eq_prod;
+	u16 sb_num;
+#endif
+#if defined(__BIG_ENDIAN)
+	u16 reserved1;
+	u8 reserved0;
+	u8 sb_id;
+#elif defined(__LITTLE_ENDIAN)
+	u8 sb_id;
+	u8 reserved0;
+	u16 reserved1;
+#endif
+};
+
+
+/*
+ * FCoE statistics params buffer passed by driver to FW in FCoE statistics ramrod
+ */
+struct fcoe_stat_ramrod_params {
+	struct fcoe_kwqe_stat stat_kwqe;
+};
+
+
+/*
+ * FCoE 16-bits vlan structure
+ */
+struct fcoe_vlan_fields {
+	u16 fields;
+#define FCOE_VLAN_FIELDS_VID (0xFFF<<0)
+#define FCOE_VLAN_FIELDS_VID_SHIFT 0
+#define FCOE_VLAN_FIELDS_CLI (0x1<<12)
+#define FCOE_VLAN_FIELDS_CLI_SHIFT 12
+#define FCOE_VLAN_FIELDS_PRI (0x7<<13)
+#define FCOE_VLAN_FIELDS_PRI_SHIFT 13
+};
+
+
+/*
+ * FCoE 16-bits vlan union
+ */
+union fcoe_vlan_field_union {
+	struct fcoe_vlan_fields fields;
+	u16 val;
+};
+
+/*
+ * Parameters used for Class 2 verifications
+ */
+struct ustorm_fcoe_c2_params {
+#if defined(__BIG_ENDIAN)
+	u16 e2e_credit;
+	u16 con_seq;
+#elif defined(__LITTLE_ENDIAN)
+	u16 con_seq;
+	u16 e2e_credit;
+#endif
+#if defined(__BIG_ENDIAN)
+	u16 ackq_prod;
+	u16 open_seq_per_exch;
+#elif defined(__LITTLE_ENDIAN)
+	u16 open_seq_per_exch;
+	u16 ackq_prod;
+#endif
+	struct regpair ackq_pbl_base;
+	struct regpair ackq_cur_seg;
+};
+
+/*
+ * Parameters used for Class 2 verifications
+ */
+struct xstorm_fcoe_c2_params {
+#if defined(__BIG_ENDIAN)
+	u16 reserved0;
+	u8 ackq_x_prod;
+	u8 max_conc_seqs_c2;
+#elif defined(__LITTLE_ENDIAN)
+	u8 max_conc_seqs_c2;
+	u8 ackq_x_prod;
+	u16 reserved0;
+#endif
+	struct regpair ackq_pbl_base;
+	struct regpair ackq_cur_seg;
+};
+
+/*
  * Buffer per connection, used in Tstorm
  */
 struct iscsi_conn_buf {
diff --git a/drivers/net/cnic_if.h b/drivers/net/cnic_if.h
index 33333e7..ccd8140 100644
--- a/drivers/net/cnic_if.h
+++ b/drivers/net/cnic_if.h
@@ -12,22 +12,31 @@
 #ifndef CNIC_IF_H
 #define CNIC_IF_H
 
-#define CNIC_MODULE_VERSION	"2.2.6"
-#define CNIC_MODULE_RELDATE	"Oct 12, 2010"
+#define CNIC_MODULE_VERSION	"2.2.11"
+#define CNIC_MODULE_RELDATE	"Dec 22, 2010"
 
 #define CNIC_ULP_RDMA		0
 #define CNIC_ULP_ISCSI		1
-#define CNIC_ULP_L4		2
-#define MAX_CNIC_ULP_TYPE_EXT	2
-#define MAX_CNIC_ULP_TYPE	3
+#define CNIC_ULP_FCOE		2
+#define CNIC_ULP_L4		3
+#define MAX_CNIC_ULP_TYPE_EXT	3
+#define MAX_CNIC_ULP_TYPE	4
 
 struct kwqe {
 	u32 kwqe_op_flag;
 
+#define KWQE_QID_SHIFT		8
 #define KWQE_OPCODE_MASK	0x00ff0000
 #define KWQE_OPCODE_SHIFT	16
-#define KWQE_FLAGS_LAYER_SHIFT	28
 #define KWQE_OPCODE(x)		((x & KWQE_OPCODE_MASK) >> KWQE_OPCODE_SHIFT)
+#define KWQE_LAYER_MASK			0x70000000
+#define KWQE_LAYER_SHIFT		28
+#define KWQE_FLAGS_LAYER_MASK_L2	(2<<28)
+#define KWQE_FLAGS_LAYER_MASK_L3	(3<<28)
+#define KWQE_FLAGS_LAYER_MASK_L4	(4<<28)
+#define KWQE_FLAGS_LAYER_MASK_L5_RDMA	(5<<28)
+#define KWQE_FLAGS_LAYER_MASK_L5_ISCSI	(6<<28)
+#define KWQE_FLAGS_LAYER_MASK_L5_FCOE	(7<<28)
 
 	u32 kwqe_info0;
 	u32 kwqe_info1;
@@ -62,6 +71,7 @@ struct kcqe {
 		#define KCQE_FLAGS_LAYER_MASK_L4	(4<<28)
 		#define KCQE_FLAGS_LAYER_MASK_L5_RDMA	(5<<28)
 		#define KCQE_FLAGS_LAYER_MASK_L5_ISCSI	(6<<28)
+		#define KCQE_FLAGS_LAYER_MASK_L5_FCOE	(7<<28)
 		#define KCQE_FLAGS_NEXT 		(1<<31)
 		#define KCQE_FLAGS_OPCODE_MASK		(0xff<<16)
 		#define KCQE_FLAGS_OPCODE_SHIFT		(16)
-- 
1.6.4.GIT


