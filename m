From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next 02/19] cnic: Use pfid for internal memory
 offsets.
Date: Wed, 6 Oct 2010 15:16:06 +0200
Message-ID: <1286370966.30552.13.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, mchan@broadcom.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4218 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757395Ab0JFNjX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Oct 2010 09:39:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <mchan@broadcom.com>

The pfid (physical function ID) is the same as PCI function on production
devices.  The pfid for future devices will be different and will be used
for internal memory offsets.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
---
 drivers/net/cnic.c |  144 +++++++++++++++++++++++++++-------------------------
 drivers/net/cnic.h |    1 +
 2 files changed, 75 insertions(+), 70 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 0e31d5a..50cded7 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -1246,8 +1246,8 @@ static int cnic_bnx2x_iscsi_init1(struct cnic_dev *dev, struct kwqe *kwqe)
 {
 	struct cnic_local *cp = dev->cnic_priv;
 	struct iscsi_kwqe_init1 *req1 = (struct iscsi_kwqe_init1 *) kwqe;
-	int func = cp->func, pages;
-	int hq_bds;
+	int hq_bds, pages;
+	u32 pfid = cp->pfid;
 
 	cp->num_iscsi_tasks = req1->num_tasks_per_conn;
 	cp->num_ccells = req1->num_ccells_per_conn;
@@ -1264,60 +1264,60 @@ static int cnic_bnx2x_iscsi_init1(struct cnic_dev *dev, struct kwqe *kwqe)
 		return 0;
 
 	/* init Tstorm RAM */
-	CNIC_WR16(dev, BAR_TSTRORM_INTMEM + TSTORM_ISCSI_RQ_SIZE_OFFSET(func),
+	CNIC_WR16(dev, BAR_TSTRORM_INTMEM + TSTORM_ISCSI_RQ_SIZE_OFFSET(pfid),
 		  req1->rq_num_wqes);
-	CNIC_WR16(dev, BAR_TSTRORM_INTMEM + TSTORM_ISCSI_PAGE_SIZE_OFFSET(func),
+	CNIC_WR16(dev, BAR_TSTRORM_INTMEM + TSTORM_ISCSI_PAGE_SIZE_OFFSET(pfid),
 		  PAGE_SIZE);
 	CNIC_WR8(dev, BAR_TSTRORM_INTMEM +
-		 TSTORM_ISCSI_PAGE_SIZE_LOG_OFFSET(func), PAGE_SHIFT);
+		 TSTORM_ISCSI_PAGE_SIZE_LOG_OFFSET(pfid), PAGE_SHIFT);
 	CNIC_WR16(dev, BAR_TSTRORM_INTMEM +
-		  TSTORM_ISCSI_NUM_OF_TASKS_OFFSET(func),
+		  TSTORM_ISCSI_NUM_OF_TASKS_OFFSET(pfid),
 		  req1->num_tasks_per_conn);
 
 	/* init Ustorm RAM */
 	CNIC_WR16(dev, BAR_USTRORM_INTMEM +
-		  USTORM_ISCSI_RQ_BUFFER_SIZE_OFFSET(func),
+		  USTORM_ISCSI_RQ_BUFFER_SIZE_OFFSET(pfid),
 		  req1->rq_buffer_size);
-	CNIC_WR16(dev, BAR_USTRORM_INTMEM + USTORM_ISCSI_PAGE_SIZE_OFFSET(func),
+	CNIC_WR16(dev, BAR_USTRORM_INTMEM + USTORM_ISCSI_PAGE_SIZE_OFFSET(pfid),
 		  PAGE_SIZE);
 	CNIC_WR8(dev, BAR_USTRORM_INTMEM +
-		 USTORM_ISCSI_PAGE_SIZE_LOG_OFFSET(func), PAGE_SHIFT);
+		 USTORM_ISCSI_PAGE_SIZE_LOG_OFFSET(pfid), PAGE_SHIFT);
 	CNIC_WR16(dev, BAR_USTRORM_INTMEM +
-		  USTORM_ISCSI_NUM_OF_TASKS_OFFSET(func),
+		  USTORM_ISCSI_NUM_OF_TASKS_OFFSET(pfid),
 		  req1->num_tasks_per_conn);
-	CNIC_WR16(dev, BAR_USTRORM_INTMEM + USTORM_ISCSI_RQ_SIZE_OFFSET(func),
+	CNIC_WR16(dev, BAR_USTRORM_INTMEM + USTORM_ISCSI_RQ_SIZE_OFFSET(pfid),
 		  req1->rq_num_wqes);
-	CNIC_WR16(dev, BAR_USTRORM_INTMEM + USTORM_ISCSI_CQ_SIZE_OFFSET(func),
+	CNIC_WR16(dev, BAR_USTRORM_INTMEM + USTORM_ISCSI_CQ_SIZE_OFFSET(pfid),
 		  req1->cq_num_wqes);
-	CNIC_WR16(dev, BAR_USTRORM_INTMEM + USTORM_ISCSI_R2TQ_SIZE_OFFSET(func),
+	CNIC_WR16(dev, BAR_USTRORM_INTMEM + USTORM_ISCSI_R2TQ_SIZE_OFFSET(pfid),
 		  cp->num_iscsi_tasks * BNX2X_ISCSI_MAX_PENDING_R2TS);
 
 	/* init Xstorm RAM */
-	CNIC_WR16(dev, BAR_XSTRORM_INTMEM + XSTORM_ISCSI_PAGE_SIZE_OFFSET(func),
+	CNIC_WR16(dev, BAR_XSTRORM_INTMEM + XSTORM_ISCSI_PAGE_SIZE_OFFSET(pfid),
 		  PAGE_SIZE);
 	CNIC_WR8(dev, BAR_XSTRORM_INTMEM +
-		 XSTORM_ISCSI_PAGE_SIZE_LOG_OFFSET(func), PAGE_SHIFT);
+		 XSTORM_ISCSI_PAGE_SIZE_LOG_OFFSET(pfid), PAGE_SHIFT);
 	CNIC_WR16(dev, BAR_XSTRORM_INTMEM +
-		  XSTORM_ISCSI_NUM_OF_TASKS_OFFSET(func),
+		  XSTORM_ISCSI_NUM_OF_TASKS_OFFSET(pfid),
 		  req1->num_tasks_per_conn);
-	CNIC_WR16(dev, BAR_XSTRORM_INTMEM + XSTORM_ISCSI_HQ_SIZE_OFFSET(func),
+	CNIC_WR16(dev, BAR_XSTRORM_INTMEM + XSTORM_ISCSI_HQ_SIZE_OFFSET(pfid),
 		  hq_bds);
-	CNIC_WR16(dev, BAR_XSTRORM_INTMEM + XSTORM_ISCSI_SQ_SIZE_OFFSET(func),
+	CNIC_WR16(dev, BAR_XSTRORM_INTMEM + XSTORM_ISCSI_SQ_SIZE_OFFSET(pfid),
 		  req1->num_tasks_per_conn);
-	CNIC_WR16(dev, BAR_XSTRORM_INTMEM + XSTORM_ISCSI_R2TQ_SIZE_OFFSET(func),
+	CNIC_WR16(dev, BAR_XSTRORM_INTMEM + XSTORM_ISCSI_R2TQ_SIZE_OFFSET(pfid),
 		  cp->num_iscsi_tasks * BNX2X_ISCSI_MAX_PENDING_R2TS);
 
 	/* init Cstorm RAM */
-	CNIC_WR16(dev, BAR_CSTRORM_INTMEM + CSTORM_ISCSI_PAGE_SIZE_OFFSET(func),
+	CNIC_WR16(dev, BAR_CSTRORM_INTMEM + CSTORM_ISCSI_PAGE_SIZE_OFFSET(pfid),
 		  PAGE_SIZE);
 	CNIC_WR8(dev, BAR_CSTRORM_INTMEM +
-		 CSTORM_ISCSI_PAGE_SIZE_LOG_OFFSET(func), PAGE_SHIFT);
+		 CSTORM_ISCSI_PAGE_SIZE_LOG_OFFSET(pfid), PAGE_SHIFT);
 	CNIC_WR16(dev, BAR_CSTRORM_INTMEM +
-		  CSTORM_ISCSI_NUM_OF_TASKS_OFFSET(func),
+		  CSTORM_ISCSI_NUM_OF_TASKS_OFFSET(pfid),
 		  req1->num_tasks_per_conn);
-	CNIC_WR16(dev, BAR_CSTRORM_INTMEM + CSTORM_ISCSI_CQ_SIZE_OFFSET(func),
+	CNIC_WR16(dev, BAR_CSTRORM_INTMEM + CSTORM_ISCSI_CQ_SIZE_OFFSET(pfid),
 		  req1->cq_num_wqes);
-	CNIC_WR16(dev, BAR_CSTRORM_INTMEM + CSTORM_ISCSI_HQ_SIZE_OFFSET(func),
+	CNIC_WR16(dev, BAR_CSTRORM_INTMEM + CSTORM_ISCSI_HQ_SIZE_OFFSET(pfid),
 		  hq_bds);
 
 	return 0;
@@ -1327,7 +1327,7 @@ static int cnic_bnx2x_iscsi_init2(struct cnic_dev *dev, struct kwqe *kwqe)
 {
 	struct iscsi_kwqe_init2 *req2 = (struct iscsi_kwqe_init2 *) kwqe;
 	struct cnic_local *cp = dev->cnic_priv;
-	int func = cp->func;
+	u32 pfid = cp->pfid;
 	struct iscsi_kcqe kcqe;
 	struct kcqe *cqes[1];
 
@@ -1339,21 +1339,21 @@ static int cnic_bnx2x_iscsi_init2(struct cnic_dev *dev, struct kwqe *kwqe)
 	}
 
 	CNIC_WR(dev, BAR_TSTRORM_INTMEM +
-		TSTORM_ISCSI_ERROR_BITMAP_OFFSET(func), req2->error_bit_map[0]);
+		TSTORM_ISCSI_ERROR_BITMAP_OFFSET(pfid), req2->error_bit_map[0]);
 	CNIC_WR(dev, BAR_TSTRORM_INTMEM +
-		TSTORM_ISCSI_ERROR_BITMAP_OFFSET(func) + 4,
+		TSTORM_ISCSI_ERROR_BITMAP_OFFSET(pfid) + 4,
 		req2->error_bit_map[1]);
 
 	CNIC_WR16(dev, BAR_USTRORM_INTMEM +
-		  USTORM_ISCSI_CQ_SQN_SIZE_OFFSET(func), req2->max_cq_sqn);
+		  USTORM_ISCSI_CQ_SQN_SIZE_OFFSET(pfid), req2->max_cq_sqn);
 	CNIC_WR(dev, BAR_USTRORM_INTMEM +
-		USTORM_ISCSI_ERROR_BITMAP_OFFSET(func), req2->error_bit_map[0]);
+		USTORM_ISCSI_ERROR_BITMAP_OFFSET(pfid), req2->error_bit_map[0]);
 	CNIC_WR(dev, BAR_USTRORM_INTMEM +
-		USTORM_ISCSI_ERROR_BITMAP_OFFSET(func) + 4,
+		USTORM_ISCSI_ERROR_BITMAP_OFFSET(pfid) + 4,
 		req2->error_bit_map[1]);
 
 	CNIC_WR16(dev, BAR_CSTRORM_INTMEM +
-		  CSTORM_ISCSI_CQ_SQN_SIZE_OFFSET(func), req2->max_cq_sqn);
+		  CSTORM_ISCSI_CQ_SQN_SIZE_OFFSET(pfid), req2->max_cq_sqn);
 
 	kcqe.completion_status = ISCSI_KCQE_COMPLETION_STATUS_SUCCESS;
 
@@ -1804,37 +1804,37 @@ static void cnic_init_storm_conn_bufs(struct cnic_dev *dev,
 static void cnic_init_bnx2x_mac(struct cnic_dev *dev)
 {
 	struct cnic_local *cp = dev->cnic_priv;
-	int func = CNIC_FUNC(cp);
+	u32 pfid = cp->pfid;
 	u8 *mac = dev->mac_addr;
 
 	CNIC_WR8(dev, BAR_XSTRORM_INTMEM +
-		 XSTORM_ISCSI_LOCAL_MAC_ADDR0_OFFSET(func), mac[0]);
+		 XSTORM_ISCSI_LOCAL_MAC_ADDR0_OFFSET(pfid), mac[0]);
 	CNIC_WR8(dev, BAR_XSTRORM_INTMEM +
-		 XSTORM_ISCSI_LOCAL_MAC_ADDR1_OFFSET(func), mac[1]);
+		 XSTORM_ISCSI_LOCAL_MAC_ADDR1_OFFSET(pfid), mac[1]);
 	CNIC_WR8(dev, BAR_XSTRORM_INTMEM +
-		 XSTORM_ISCSI_LOCAL_MAC_ADDR2_OFFSET(func), mac[2]);
+		 XSTORM_ISCSI_LOCAL_MAC_ADDR2_OFFSET(pfid), mac[2]);
 	CNIC_WR8(dev, BAR_XSTRORM_INTMEM +
-		 XSTORM_ISCSI_LOCAL_MAC_ADDR3_OFFSET(func), mac[3]);
+		 XSTORM_ISCSI_LOCAL_MAC_ADDR3_OFFSET(pfid), mac[3]);
 	CNIC_WR8(dev, BAR_XSTRORM_INTMEM +
-		 XSTORM_ISCSI_LOCAL_MAC_ADDR4_OFFSET(func), mac[4]);
+		 XSTORM_ISCSI_LOCAL_MAC_ADDR4_OFFSET(pfid), mac[4]);
 	CNIC_WR8(dev, BAR_XSTRORM_INTMEM +
-		 XSTORM_ISCSI_LOCAL_MAC_ADDR5_OFFSET(func), mac[5]);
+		 XSTORM_ISCSI_LOCAL_MAC_ADDR5_OFFSET(pfid), mac[5]);
 
 	CNIC_WR8(dev, BAR_TSTRORM_INTMEM +
-		 TSTORM_ISCSI_TCP_VARS_LSB_LOCAL_MAC_ADDR_OFFSET(func), mac[5]);
+		 TSTORM_ISCSI_TCP_VARS_LSB_LOCAL_MAC_ADDR_OFFSET(pfid), mac[5]);
 	CNIC_WR8(dev, BAR_TSTRORM_INTMEM +
-		 TSTORM_ISCSI_TCP_VARS_LSB_LOCAL_MAC_ADDR_OFFSET(func) + 1,
+		 TSTORM_ISCSI_TCP_VARS_LSB_LOCAL_MAC_ADDR_OFFSET(pfid) + 1,
 		 mac[4]);
 	CNIC_WR8(dev, BAR_TSTRORM_INTMEM +
-		 TSTORM_ISCSI_TCP_VARS_MSB_LOCAL_MAC_ADDR_OFFSET(func), mac[3]);
+		 TSTORM_ISCSI_TCP_VARS_MSB_LOCAL_MAC_ADDR_OFFSET(pfid), mac[3]);
 	CNIC_WR8(dev, BAR_TSTRORM_INTMEM +
-		 TSTORM_ISCSI_TCP_VARS_MSB_LOCAL_MAC_ADDR_OFFSET(func) + 1,
+		 TSTORM_ISCSI_TCP_VARS_MSB_LOCAL_MAC_ADDR_OFFSET(pfid) + 1,
 		 mac[2]);
 	CNIC_WR8(dev, BAR_TSTRORM_INTMEM +
-		 TSTORM_ISCSI_TCP_VARS_MSB_LOCAL_MAC_ADDR_OFFSET(func) + 2,
+		 TSTORM_ISCSI_TCP_VARS_MSB_LOCAL_MAC_ADDR_OFFSET(pfid) + 2,
 		 mac[1]);
 	CNIC_WR8(dev, BAR_TSTRORM_INTMEM +
-		 TSTORM_ISCSI_TCP_VARS_MSB_LOCAL_MAC_ADDR_OFFSET(func) + 3,
+		 TSTORM_ISCSI_TCP_VARS_MSB_LOCAL_MAC_ADDR_OFFSET(pfid) + 3,
 		 mac[0]);
 }
 
@@ -1850,10 +1850,10 @@ static void cnic_bnx2x_set_tcp_timestamp(struct cnic_dev *dev, int tcp_ts)
 	}
 
 	CNIC_WR8(dev, BAR_XSTRORM_INTMEM +
-		 XSTORM_ISCSI_TCP_VARS_FLAGS_OFFSET(cp->func), xstorm_flags);
+		 XSTORM_ISCSI_TCP_VARS_FLAGS_OFFSET(cp->pfid), xstorm_flags);
 
 	CNIC_WR16(dev, BAR_TSTRORM_INTMEM +
-		  TSTORM_ISCSI_TCP_VARS_FLAGS_OFFSET(cp->func), tstorm_flags);
+		  TSTORM_ISCSI_TCP_VARS_FLAGS_OFFSET(cp->pfid), tstorm_flags);
 }
 
 static int cnic_bnx2x_connect(struct cnic_dev *dev, struct kwqe *wqes[],
@@ -1928,7 +1928,7 @@ static int cnic_bnx2x_connect(struct cnic_dev *dev, struct kwqe *wqes[],
 	cnic_init_storm_conn_bufs(dev, kwqe1, kwqe3, conn_buf);
 
 	CNIC_WR16(dev, BAR_XSTRORM_INTMEM +
-		  XSTORM_ISCSI_LOCAL_VLAN_OFFSET(cp->func), csk->vlan_id);
+		  XSTORM_ISCSI_LOCAL_VLAN_OFFSET(cp->pfid), csk->vlan_id);
 
 	cnic_bnx2x_set_tcp_timestamp(dev,
 		kwqe1->tcp_flags & L4_KWQ_CONNECT_REQ1_TIME_STAMP);
@@ -3283,30 +3283,30 @@ static void cnic_cm_stop_bnx2x_hw(struct cnic_dev *dev)
 static int cnic_cm_init_bnx2x_hw(struct cnic_dev *dev)
 {
 	struct cnic_local *cp = dev->cnic_priv;
-	int func = CNIC_FUNC(cp);
+	u32 pfid = cp->pfid;
 
 	cnic_init_bnx2x_mac(dev);
 	cnic_bnx2x_set_tcp_timestamp(dev, 1);
 
 	CNIC_WR16(dev, BAR_XSTRORM_INTMEM +
-		  XSTORM_ISCSI_LOCAL_VLAN_OFFSET(func), 0);
+		  XSTORM_ISCSI_LOCAL_VLAN_OFFSET(pfid), 0);
 
 	CNIC_WR(dev, BAR_XSTRORM_INTMEM +
-		XSTORM_TCP_GLOBAL_DEL_ACK_COUNTER_ENABLED_OFFSET(func), 1);
+		XSTORM_TCP_GLOBAL_DEL_ACK_COUNTER_ENABLED_OFFSET(pfid), 1);
 	CNIC_WR(dev, BAR_XSTRORM_INTMEM +
-		XSTORM_TCP_GLOBAL_DEL_ACK_COUNTER_MAX_COUNT_OFFSET(func),
+		XSTORM_TCP_GLOBAL_DEL_ACK_COUNTER_MAX_COUNT_OFFSET(pfid),
 		DEF_MAX_DA_COUNT);
 
 	CNIC_WR8(dev, BAR_XSTRORM_INTMEM +
-		 XSTORM_ISCSI_TCP_VARS_TTL_OFFSET(func), DEF_TTL);
+		 XSTORM_ISCSI_TCP_VARS_TTL_OFFSET(pfid), DEF_TTL);
 	CNIC_WR8(dev, BAR_XSTRORM_INTMEM +
-		 XSTORM_ISCSI_TCP_VARS_TOS_OFFSET(func), DEF_TOS);
+		 XSTORM_ISCSI_TCP_VARS_TOS_OFFSET(pfid), DEF_TOS);
 	CNIC_WR8(dev, BAR_XSTRORM_INTMEM +
-		 XSTORM_ISCSI_TCP_VARS_ADV_WND_SCL_OFFSET(func), 2);
+		 XSTORM_ISCSI_TCP_VARS_ADV_WND_SCL_OFFSET(pfid), 2);
 	CNIC_WR(dev, BAR_XSTRORM_INTMEM +
-		XSTORM_TCP_TX_SWS_TIMER_VAL_OFFSET(func), DEF_SWS_TIMER);
+		XSTORM_TCP_TX_SWS_TIMER_VAL_OFFSET(pfid), DEF_SWS_TIMER);
 
-	CNIC_WR(dev, BAR_TSTRORM_INTMEM + TSTORM_TCP_MAX_CWND_OFFSET(func),
+	CNIC_WR(dev, BAR_TSTRORM_INTMEM + TSTORM_TCP_MAX_CWND_OFFSET(pfid),
 		DEF_MAX_CWND);
 	return 0;
 }
@@ -4123,9 +4123,13 @@ static int cnic_start_bnx2x_hw(struct cnic_dev *dev)
 	struct cnic_local *cp = dev->cnic_priv;
 	int func = CNIC_FUNC(cp), ret, i;
 	int port = CNIC_PORT(cp);
+	u32 pfid;
 	u16 eq_idx;
 	u8 sb_id = cp->status_blk_num;
 
+	cp->pfid = func;
+	pfid = cp->pfid;
+
 	ret = cnic_init_id_tbl(&cp->cid_tbl, MAX_ISCSI_TBL_SZ,
 			       cp->iscsi_start_cid);
 
@@ -4133,7 +4137,7 @@ static int cnic_start_bnx2x_hw(struct cnic_dev *dev)
 		return -ENOMEM;
 
 	cp->kcq1.io_addr = BAR_CSTRORM_INTMEM +
-			  CSTORM_ISCSI_EQ_PROD_OFFSET(func, 0);
+			  CSTORM_ISCSI_EQ_PROD_OFFSET(pfid, 0);
 	cp->kcq1.sw_prod_idx = 0;
 
 	cp->kcq1.hw_prod_idx_ptr =
@@ -4147,41 +4151,41 @@ static int cnic_start_bnx2x_hw(struct cnic_dev *dev)
 	/* Only 1 EQ */
 	CNIC_WR16(dev, cp->kcq1.io_addr, MAX_KCQ_IDX);
 	CNIC_WR(dev, BAR_CSTRORM_INTMEM +
-		CSTORM_ISCSI_EQ_CONS_OFFSET(func, 0), 0);
+		CSTORM_ISCSI_EQ_CONS_OFFSET(pfid, 0), 0);
 	CNIC_WR(dev, BAR_CSTRORM_INTMEM +
-		CSTORM_ISCSI_EQ_NEXT_PAGE_ADDR_OFFSET(func, 0),
+		CSTORM_ISCSI_EQ_NEXT_PAGE_ADDR_OFFSET(pfid, 0),
 		cp->kcq1.dma.pg_map_arr[1] & 0xffffffff);
 	CNIC_WR(dev, BAR_CSTRORM_INTMEM +
-		CSTORM_ISCSI_EQ_NEXT_PAGE_ADDR_OFFSET(func, 0) + 4,
+		CSTORM_ISCSI_EQ_NEXT_PAGE_ADDR_OFFSET(pfid, 0) + 4,
 		(u64) cp->kcq1.dma.pg_map_arr[1] >> 32);
 	CNIC_WR(dev, BAR_CSTRORM_INTMEM +
-		CSTORM_ISCSI_EQ_NEXT_EQE_ADDR_OFFSET(func, 0),
+		CSTORM_ISCSI_EQ_NEXT_EQE_ADDR_OFFSET(pfid, 0),
 		cp->kcq1.dma.pg_map_arr[0] & 0xffffffff);
 	CNIC_WR(dev, BAR_CSTRORM_INTMEM +
-		CSTORM_ISCSI_EQ_NEXT_EQE_ADDR_OFFSET(func, 0) + 4,
+		CSTORM_ISCSI_EQ_NEXT_EQE_ADDR_OFFSET(pfid, 0) + 4,
 		(u64) cp->kcq1.dma.pg_map_arr[0] >> 32);
 	CNIC_WR8(dev, BAR_CSTRORM_INTMEM +
-		CSTORM_ISCSI_EQ_NEXT_PAGE_ADDR_VALID_OFFSET(func, 0), 1);
+		CSTORM_ISCSI_EQ_NEXT_PAGE_ADDR_VALID_OFFSET(pfid, 0), 1);
 	CNIC_WR16(dev, BAR_CSTRORM_INTMEM +
-		CSTORM_ISCSI_EQ_SB_NUM_OFFSET(func, 0), cp->status_blk_num);
+		CSTORM_ISCSI_EQ_SB_NUM_OFFSET(pfid, 0), cp->status_blk_num);
 	CNIC_WR8(dev, BAR_CSTRORM_INTMEM +
-		CSTORM_ISCSI_EQ_SB_INDEX_OFFSET(func, 0),
+		CSTORM_ISCSI_EQ_SB_INDEX_OFFSET(pfid, 0),
 		HC_INDEX_C_ISCSI_EQ_CONS);
 
 	for (i = 0; i < cp->conn_buf_info.num_pages; i++) {
 		CNIC_WR(dev, BAR_TSTRORM_INTMEM +
-			TSTORM_ISCSI_CONN_BUF_PBL_OFFSET(func, i),
+			TSTORM_ISCSI_CONN_BUF_PBL_OFFSET(pfid, i),
 			cp->conn_buf_info.pgtbl[2 * i]);
 		CNIC_WR(dev, BAR_TSTRORM_INTMEM +
-			TSTORM_ISCSI_CONN_BUF_PBL_OFFSET(func, i) + 4,
+			TSTORM_ISCSI_CONN_BUF_PBL_OFFSET(pfid, i) + 4,
 			cp->conn_buf_info.pgtbl[(2 * i) + 1]);
 	}
 
 	CNIC_WR(dev, BAR_USTRORM_INTMEM +
-		USTORM_ISCSI_GLOBAL_BUF_PHYS_ADDR_OFFSET(func),
+		USTORM_ISCSI_GLOBAL_BUF_PHYS_ADDR_OFFSET(pfid),
 		cp->gbl_buf_info.pg_map_arr[0] & 0xffffffff);
 	CNIC_WR(dev, BAR_USTRORM_INTMEM +
-		USTORM_ISCSI_GLOBAL_BUF_PHYS_ADDR_OFFSET(func) + 4,
+		USTORM_ISCSI_GLOBAL_BUF_PHYS_ADDR_OFFSET(pfid) + 4,
 		(u64) cp->gbl_buf_info.pg_map_arr[0] >> 32);
 
 	cnic_setup_bnx2x_context(dev);
@@ -4386,7 +4390,7 @@ static void cnic_stop_bnx2x_hw(struct cnic_dev *dev)
 			   index_values[HC_INDEX_C_ISCSI_EQ_CONS]),
 		  0);
 	CNIC_WR(dev, BAR_CSTRORM_INTMEM +
-		CSTORM_ISCSI_EQ_CONS_OFFSET(cp->func, 0), 0);
+		CSTORM_ISCSI_EQ_CONS_OFFSET(cp->pfid, 0), 0);
 	CNIC_WR16(dev, cp->kcq1.io_addr, 0);
 	cnic_free_resc(dev);
 }
diff --git a/drivers/net/cnic.h b/drivers/net/cnic.h
index 6c09981..ef2c25e 100644
--- a/drivers/net/cnic.h
+++ b/drivers/net/cnic.h
@@ -272,6 +272,7 @@ struct cnic_local {
 
 	u32			chip_id;
 	int			func;
+	u32			pfid;
 	u32			shmem_base;
 
 	u32			uio_dev;
-- 
1.7.1




