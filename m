From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next 01/19] cnic: Pass cp pointer to BNX2X_HW_CID.
Date: Wed, 6 Oct 2010 15:14:54 +0200
Message-ID: <1286370894.30552.10.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, mchan@broadcom.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4218 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757351Ab0JFNjN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Oct 2010 09:39:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <mchan@broadcom.com>

Preparation work for upcoming firmware interface changes.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
---
 drivers/net/cnic.c |   13 +++++--------
 drivers/net/cnic.h |    9 ++++++---
 2 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 2ab6a7c..0e31d5a 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -1209,7 +1209,7 @@ static int cnic_submit_kwqe_16(struct cnic_dev *dev, u32 cmd, u32 cid,
 
 	kwqe.hdr.conn_and_cmd_data =
 		cpu_to_le32(((cmd << SPE_HDR_CMD_ID_SHIFT) |
-			     BNX2X_HW_CID(cid, cp->func)));
+			     BNX2X_HW_CID(cp, cid)));
 	kwqe.hdr.type = cpu_to_le16(type);
 	kwqe.hdr.reserved = 0;
 	kwqe.data.phy_address.lo = cpu_to_le32(l5_data->phy_address.lo);
@@ -1461,7 +1461,7 @@ static int cnic_setup_bnx2x_ctx(struct cnic_dev *dev, struct kwqe *wqes[],
 	struct cnic_context *ctx = &cp->ctx_tbl[req1->iscsi_conn_id];
 	struct cnic_iscsi *iscsi = ctx->proto.iscsi;
 	u32 cid = ctx->cid;
-	u32 hw_cid = BNX2X_HW_CID(cid, cp->func);
+	u32 hw_cid = BNX2X_HW_CID(cp, cid);
 	struct iscsi_context *ictx;
 	struct regpair context_addr;
 	int i, j, n = 2, n_max;
@@ -1673,8 +1673,7 @@ static int cnic_bnx2x_iscsi_ofld1(struct cnic_dev *dev, struct kwqe *wqes[],
 	}
 
 	kcqe.completion_status = ISCSI_KCQE_COMPLETION_STATUS_SUCCESS;
-	kcqe.iscsi_conn_context_id = BNX2X_HW_CID(cp->ctx_tbl[l5_cid].cid,
-						  cp->func);
+	kcqe.iscsi_conn_context_id = BNX2X_HW_CID(cp, cp->ctx_tbl[l5_cid].cid);
 
 done:
 	cqes[0] = (struct kcqe *) &kcqe;
@@ -3885,7 +3884,6 @@ static void cnic_init_bnx2x_tx_ring(struct cnic_dev *dev)
 	struct eth_context *context;
 	struct regpair context_addr;
 	dma_addr_t buf_map;
-	int func = CNIC_FUNC(cp);
 	int port = CNIC_PORT(cp);
 	int i;
 	int cli = BNX2X_ISCSI_CL_ID(CNIC_E1HVN(cp));
@@ -3931,7 +3929,7 @@ static void cnic_init_bnx2x_tx_ring(struct cnic_dev *dev)
 				XSTORM_ETH_ST_CONTEXT_STATISTICS_ENABLE;
 
 	context->xstorm_ag_context.cdu_reserved =
-		CDU_RSRVD_VALUE_TYPE_A(BNX2X_HW_CID(BNX2X_ISCSI_L2_CID, func),
+		CDU_RSRVD_VALUE_TYPE_A(BNX2X_HW_CID(cp, BNX2X_ISCSI_L2_CID),
 					CDU_REGION_NUMBER_XCM_AG,
 					ETH_CONNECTION_TYPE);
 
@@ -3959,7 +3957,6 @@ static void cnic_init_bnx2x_rx_ring(struct cnic_dev *dev)
 	struct regpair context_addr;
 	int i;
 	int port = CNIC_PORT(cp);
-	int func = CNIC_FUNC(cp);
 	int cli = BNX2X_ISCSI_CL_ID(CNIC_E1HVN(cp));
 	u32 val;
 	struct tstorm_eth_client_config tstorm_client = {0};
@@ -3998,7 +3995,7 @@ static void cnic_init_bnx2x_rx_ring(struct cnic_dev *dev)
 						cp->l2_single_buf_size;
 
 	context->ustorm_ag_context.cdu_usage =
-		CDU_RSRVD_VALUE_TYPE_A(BNX2X_HW_CID(BNX2X_ISCSI_L2_CID, func),
+		CDU_RSRVD_VALUE_TYPE_A(BNX2X_HW_CID(cp, BNX2X_ISCSI_L2_CID),
 					CDU_REGION_NUMBER_UCM_AG,
 					ETH_CONNECTION_TYPE);
 
diff --git a/drivers/net/cnic.h b/drivers/net/cnic.h
index 275c361..6c09981 100644
--- a/drivers/net/cnic.h
+++ b/drivers/net/cnic.h
@@ -335,9 +335,7 @@ struct bnx2x_bd_chain_next {
 #define BNX2X_ISCSI_GLB_BUF_SIZE	64
 #define BNX2X_ISCSI_PBL_NOT_CACHED	0xff
 #define BNX2X_ISCSI_PDU_HEADER_NOT_CACHED	0xff
-#define BNX2X_HW_CID(x, func)		((x) | (((func) % PORT_MAX) << 23) | \
-					 (((func) >> 1) << 17))
-#define BNX2X_SW_CID(x)			(x & 0x1ffff)
+
 #define BNX2X_CHIP_NUM_57711		0x164f
 #define BNX2X_CHIP_NUM_57711E		0x1650
 #define BNX2X_CHIP_NUM(x)		(x >> 16)
@@ -372,5 +370,10 @@ struct bnx2x_bd_chain_next {
 #define CNIC_FUNC(cp)			((cp)->func)
 #define CNIC_E1HVN(cp)			((cp)->func >> 1)
 
+#define BNX2X_HW_CID(cp, x)		(((CNIC_FUNC(cp) % PORT_MAX) << 23) | \
+					 (CNIC_E1HVN(cp) << 17) | (x))
+
+#define BNX2X_SW_CID(x)			(x & 0x1ffff)
+
 #endif
 
-- 
1.7.1




