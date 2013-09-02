From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 2/5] cnic: Redefine BNX2X_HW_CID using existing
 bnx2x macros
Date: Mon, 2 Sep 2013 11:42:29 -0700
Message-ID: <1378147352-9076-3-git-send-email-mchan@broadcom.com>
References: <1378147352-9076-1-git-send-email-mchan@broadcom.com>
 <1378147352-9076-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4758 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756877Ab3IBSWU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Sep 2013 14:22:20 -0400
In-Reply-To: <1378147352-9076-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

to avoid duplication of the same logic.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/cnic.c |   25 ++++++++++++++++---------
 drivers/net/ethernet/broadcom/cnic.h |    5 ++---
 2 files changed, 18 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index 3dadc81..750b9a6 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -1384,6 +1384,7 @@ static int cnic_submit_kwqe_16(struct cnic_dev *dev, u32 cmd, u32 cid,
 				u32 type, union l5cm_specific_data *l5_data)
 {
 	struct cnic_local *cp = dev->cnic_priv;
+	struct bnx2x *bp = netdev_priv(dev->netdev);
 	struct l5cm_spe kwqe;
 	struct kwqe_16 *kwq[1];
 	u16 type_16;
@@ -1391,7 +1392,7 @@ static int cnic_submit_kwqe_16(struct cnic_dev *dev, u32 cmd, u32 cid,
 
 	kwqe.hdr.conn_and_cmd_data =
 		cpu_to_le32(((cmd << SPE_HDR_CMD_ID_SHIFT) |
-			     BNX2X_HW_CID(cp, cid)));
+			     BNX2X_HW_CID(bp, cid)));
 
 	type_16 = (type << SPE_HDR_CONN_TYPE_SHIFT) & SPE_HDR_CONN_TYPE;
 	type_16 |= (cp->pfid << SPE_HDR_FUNCTION_ID_SHIFT) &
@@ -1690,7 +1691,7 @@ static int cnic_setup_bnx2x_ctx(struct cnic_dev *dev, struct kwqe *wqes[],
 	struct cnic_context *ctx = &cp->ctx_tbl[req1->iscsi_conn_id];
 	struct cnic_iscsi *iscsi = ctx->proto.iscsi;
 	u32 cid = ctx->cid;
-	u32 hw_cid = BNX2X_HW_CID(cp, cid);
+	u32 hw_cid = BNX2X_HW_CID(bp, cid);
 	struct iscsi_context *ictx;
 	struct regpair context_addr;
 	int i, j, n = 2, n_max;
@@ -1870,6 +1871,7 @@ static int cnic_bnx2x_iscsi_ofld1(struct cnic_dev *dev, struct kwqe *wqes[],
 	struct iscsi_kwqe_conn_offload1 *req1;
 	struct iscsi_kwqe_conn_offload2 *req2;
 	struct cnic_local *cp = dev->cnic_priv;
+	struct bnx2x *bp = netdev_priv(dev->netdev);
 	struct cnic_context *ctx;
 	struct iscsi_kcqe kcqe;
 	struct kcqe *cqes[1];
@@ -1923,7 +1925,7 @@ static int cnic_bnx2x_iscsi_ofld1(struct cnic_dev *dev, struct kwqe *wqes[],
 	}
 
 	kcqe.completion_status = ISCSI_KCQE_COMPLETION_STATUS_SUCCESS;
-	kcqe.iscsi_conn_context_id = BNX2X_HW_CID(cp, cp->ctx_tbl[l5_cid].cid);
+	kcqe.iscsi_conn_context_id = BNX2X_HW_CID(bp, cp->ctx_tbl[l5_cid].cid);
 
 done:
 	cqes[0] = (struct kcqe *) &kcqe;
@@ -1959,6 +1961,7 @@ static int cnic_bnx2x_iscsi_update(struct cnic_dev *dev, struct kwqe *kwqe)
 static int cnic_bnx2x_destroy_ramrod(struct cnic_dev *dev, u32 l5_cid)
 {
 	struct cnic_local *cp = dev->cnic_priv;
+	struct bnx2x *bp = netdev_priv(dev->netdev);
 	struct cnic_context *ctx = &cp->ctx_tbl[l5_cid];
 	union l5cm_specific_data l5_data;
 	int ret;
@@ -1967,7 +1970,7 @@ static int cnic_bnx2x_destroy_ramrod(struct cnic_dev *dev, u32 l5_cid)
 	init_waitqueue_head(&ctx->waitq);
 	ctx->wait_cond = 0;
 	memset(&l5_data, 0, sizeof(l5_data));
-	hw_cid = BNX2X_HW_CID(cp, ctx->cid);
+	hw_cid = BNX2X_HW_CID(bp, ctx->cid);
 
 	ret = cnic_submit_kwqe_16(dev, RAMROD_CMD_ID_COMMON_CFC_DEL,
 				  hw_cid, NONE_CONNECTION_TYPE, &l5_data);
@@ -2252,11 +2255,12 @@ static int cnic_bnx2x_fcoe_stat(struct cnic_dev *dev, struct kwqe *kwqe)
 	struct fcoe_stat_ramrod_params *fcoe_stat;
 	union l5cm_specific_data l5_data;
 	struct cnic_local *cp = dev->cnic_priv;
+	struct bnx2x *bp = netdev_priv(dev->netdev);
 	int ret;
 	u32 cid;
 
 	req = (struct fcoe_kwqe_stat *) kwqe;
-	cid = BNX2X_HW_CID(cp, cp->fcoe_init_cid);
+	cid = BNX2X_HW_CID(bp, cp->fcoe_init_cid);
 
 	fcoe_stat = cnic_get_kwqe_16_data(cp, BNX2X_FCOE_L5_CID_BASE, &l5_data);
 	if (!fcoe_stat)
@@ -2275,6 +2279,7 @@ static int cnic_bnx2x_fcoe_init1(struct cnic_dev *dev, struct kwqe *wqes[],
 {
 	int ret;
 	struct cnic_local *cp = dev->cnic_priv;
+	struct bnx2x *bp = netdev_priv(dev->netdev);
 	u32 cid;
 	struct fcoe_init_ramrod_params *fcoe_init;
 	struct fcoe_kwqe_init1 *req1;
@@ -2319,7 +2324,7 @@ static int cnic_bnx2x_fcoe_init1(struct cnic_dev *dev, struct kwqe *wqes[],
 	fcoe_init->sb_id = HC_INDEX_FCOE_EQ_CONS;
 	cp->kcq2.sw_prod_idx = 0;
 
-	cid = BNX2X_HW_CID(cp, cp->fcoe_init_cid);
+	cid = BNX2X_HW_CID(bp, cp->fcoe_init_cid);
 	ret = cnic_submit_kwqe_16(dev, FCOE_RAMROD_CMD_ID_INIT_FUNC, cid,
 				  FCOE_CONNECTION_TYPE, &l5_data);
 	*work = 3;
@@ -2332,6 +2337,7 @@ static int cnic_bnx2x_fcoe_ofld1(struct cnic_dev *dev, struct kwqe *wqes[],
 	int ret = 0;
 	u32 cid = -1, l5_cid;
 	struct cnic_local *cp = dev->cnic_priv;
+	struct bnx2x *bp = netdev_priv(dev->netdev);
 	struct fcoe_kwqe_conn_offload1 *req1;
 	struct fcoe_kwqe_conn_offload2 *req2;
 	struct fcoe_kwqe_conn_offload3 *req3;
@@ -2374,7 +2380,7 @@ static int cnic_bnx2x_fcoe_ofld1(struct cnic_dev *dev, struct kwqe *wqes[],
 
 	fctx = cnic_get_bnx2x_ctx(dev, cid, 1, &ctx_addr);
 	if (fctx) {
-		u32 hw_cid = BNX2X_HW_CID(cp, cid);
+		u32 hw_cid = BNX2X_HW_CID(bp, cid);
 		u32 val;
 
 		val = CDU_RSRVD_VALUE_TYPE_A(hw_cid, CDU_REGION_NUMBER_XCM_AG,
@@ -2398,7 +2404,7 @@ static int cnic_bnx2x_fcoe_ofld1(struct cnic_dev *dev, struct kwqe *wqes[],
 	memcpy(&fcoe_offload->offload_kwqe3, req3, sizeof(*req3));
 	memcpy(&fcoe_offload->offload_kwqe4, req4, sizeof(*req4));
 
-	cid = BNX2X_HW_CID(cp, cid);
+	cid = BNX2X_HW_CID(bp, cid);
 	ret = cnic_submit_kwqe_16(dev, FCOE_RAMROD_CMD_ID_OFFLOAD_CONN, cid,
 				  FCOE_CONNECTION_TYPE, &l5_data);
 	if (!ret)
@@ -2556,13 +2562,14 @@ static int cnic_bnx2x_fcoe_fw_destroy(struct cnic_dev *dev, struct kwqe *kwqe)
 	struct fcoe_kwqe_destroy *req;
 	union l5cm_specific_data l5_data;
 	struct cnic_local *cp = dev->cnic_priv;
+	struct bnx2x *bp = netdev_priv(dev->netdev);
 	int ret;
 	u32 cid;
 
 	cnic_bnx2x_delete_wait(dev, MAX_ISCSI_TBL_SZ);
 
 	req = (struct fcoe_kwqe_destroy *) kwqe;
-	cid = BNX2X_HW_CID(cp, cp->fcoe_init_cid);
+	cid = BNX2X_HW_CID(bp, cp->fcoe_init_cid);
 
 	memset(&l5_data, 0, sizeof(l5_data));
 	ret = cnic_submit_kwqe_16(dev, FCOE_RAMROD_CMD_ID_DESTROY_FUNC, cid,
diff --git a/drivers/net/ethernet/broadcom/cnic.h b/drivers/net/ethernet/broadcom/cnic.h
index 519f587..0408ae2 100644
--- a/drivers/net/ethernet/broadcom/cnic.h
+++ b/drivers/net/ethernet/broadcom/cnic.h
@@ -401,10 +401,9 @@ struct bnx2x_bd_chain_next {
 
 #define CNIC_PORT(cp)			((cp)->pfid & 1)
 #define CNIC_FUNC(cp)			((cp)->func)
-#define CNIC_E1HVN(cp)			((cp)->pfid >> 1)
 
-#define BNX2X_HW_CID(cp, x)		((CNIC_PORT(cp) << 23) | \
-					 (CNIC_E1HVN(cp) << 17) | (x))
+#define BNX2X_HW_CID(bp, x)		((BP_PORT(bp) << 23) | \
+					 (BP_VN(bp) << 17) | (x))
 
 #define BNX2X_SW_CID(x)			(x & 0x1ffff)
 
-- 
1.7.1
