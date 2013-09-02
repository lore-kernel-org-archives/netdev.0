From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 4/5] cnic: Eliminate local copy of pfid.
Date: Mon, 2 Sep 2013 11:42:31 -0700
Message-ID: <1378147352-9076-5-git-send-email-mchan@broadcom.com>
References: <1378147352-9076-1-git-send-email-mchan@broadcom.com>
 <1378147352-9076-2-git-send-email-mchan@broadcom.com>
 <1378147352-9076-3-git-send-email-mchan@broadcom.com>
 <1378147352-9076-4-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3447 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755806Ab3IBSWk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Sep 2013 14:22:40 -0400
In-Reply-To: <1378147352-9076-4-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use bp->pfid from bnx2x instead to avoid duplication.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/cnic.c |   29 ++++++++++++-----------------
 drivers/net/ethernet/broadcom/cnic.h |    1 -
 2 files changed, 12 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index 435a167..8142480 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -1395,7 +1395,7 @@ static int cnic_submit_kwqe_16(struct cnic_dev *dev, u32 cmd, u32 cid,
 			     BNX2X_HW_CID(bp, cid)));
 
 	type_16 = (type << SPE_HDR_CONN_TYPE_SHIFT) & SPE_HDR_CONN_TYPE;
-	type_16 |= (cp->pfid << SPE_HDR_FUNCTION_ID_SHIFT) &
+	type_16 |= (bp->pfid << SPE_HDR_FUNCTION_ID_SHIFT) &
 		   SPE_HDR_FUNCTION_ID;
 
 	kwqe.hdr.type = cpu_to_le16(type_16);
@@ -1433,7 +1433,6 @@ static void cnic_reply_bnx2x_kcqes(struct cnic_dev *dev, int ulp_type,
 static void cnic_bnx2x_set_tcp_options(struct cnic_dev *dev, int time_stamps,
 				       int en_tcp_dack)
 {
-	struct cnic_local *cp = dev->cnic_priv;
 	struct bnx2x *bp = netdev_priv(dev->netdev);
 	u8 xstorm_flags = XSTORM_L5CM_TCP_FLAGS_WND_SCL_EN;
 	u16 tstorm_flags = 0;
@@ -1446,10 +1445,10 @@ static void cnic_bnx2x_set_tcp_options(struct cnic_dev *dev, int time_stamps,
 		tstorm_flags |= TSTORM_L5CM_TCP_FLAGS_DELAYED_ACK_EN;
 
 	CNIC_WR8(dev, BAR_XSTRORM_INTMEM +
-		 XSTORM_ISCSI_TCP_VARS_FLAGS_OFFSET(cp->pfid), xstorm_flags);
+		 XSTORM_ISCSI_TCP_VARS_FLAGS_OFFSET(bp->pfid), xstorm_flags);
 
 	CNIC_WR16(dev, BAR_TSTRORM_INTMEM +
-		  TSTORM_ISCSI_TCP_VARS_FLAGS_OFFSET(cp->pfid), tstorm_flags);
+		  TSTORM_ISCSI_TCP_VARS_FLAGS_OFFSET(bp->pfid), tstorm_flags);
 }
 
 static int cnic_bnx2x_iscsi_init1(struct cnic_dev *dev, struct kwqe *kwqe)
@@ -1458,7 +1457,7 @@ static int cnic_bnx2x_iscsi_init1(struct cnic_dev *dev, struct kwqe *kwqe)
 	struct bnx2x *bp = netdev_priv(dev->netdev);
 	struct iscsi_kwqe_init1 *req1 = (struct iscsi_kwqe_init1 *) kwqe;
 	int hq_bds, pages;
-	u32 pfid = cp->pfid;
+	u32 pfid = bp->pfid;
 
 	cp->num_iscsi_tasks = req1->num_tasks_per_conn;
 	cp->num_ccells = req1->num_ccells_per_conn;
@@ -1541,9 +1540,8 @@ static int cnic_bnx2x_iscsi_init1(struct cnic_dev *dev, struct kwqe *kwqe)
 static int cnic_bnx2x_iscsi_init2(struct cnic_dev *dev, struct kwqe *kwqe)
 {
 	struct iscsi_kwqe_init2 *req2 = (struct iscsi_kwqe_init2 *) kwqe;
-	struct cnic_local *cp = dev->cnic_priv;
 	struct bnx2x *bp = netdev_priv(dev->netdev);
-	u32 pfid = cp->pfid;
+	u32 pfid = bp->pfid;
 	struct iscsi_kcqe kcqe;
 	struct kcqe *cqes[1];
 
@@ -2078,9 +2076,8 @@ static void cnic_init_storm_conn_bufs(struct cnic_dev *dev,
 
 static void cnic_init_bnx2x_mac(struct cnic_dev *dev)
 {
-	struct cnic_local *cp = dev->cnic_priv;
 	struct bnx2x *bp = netdev_priv(dev->netdev);
-	u32 pfid = cp->pfid;
+	u32 pfid = bp->pfid;
 	u8 *mac = dev->mac_addr;
 
 	CNIC_WR8(dev, BAR_XSTRORM_INTMEM +
@@ -2186,7 +2183,7 @@ static int cnic_bnx2x_connect(struct cnic_dev *dev, struct kwqe *wqes[],
 	cnic_init_storm_conn_bufs(dev, kwqe1, kwqe3, conn_buf);
 
 	CNIC_WR16(dev, BAR_XSTRORM_INTMEM +
-		  XSTORM_ISCSI_LOCAL_VLAN_OFFSET(cp->pfid), csk->vlan_id);
+		  XSTORM_ISCSI_LOCAL_VLAN_OFFSET(bp->pfid), csk->vlan_id);
 
 	ret = cnic_submit_kwqe_16(dev, L5CM_RAMROD_CMD_ID_TCP_CONNECT,
 			kwqe1->cid, ISCSI_CONNECTION_TYPE, &l5_data);
@@ -4228,9 +4225,8 @@ static void cnic_cm_stop_bnx2x_hw(struct cnic_dev *dev)
 
 static int cnic_cm_init_bnx2x_hw(struct cnic_dev *dev)
 {
-	struct cnic_local *cp = dev->cnic_priv;
 	struct bnx2x *bp = netdev_priv(dev->netdev);
-	u32 pfid = cp->pfid;
+	u32 pfid = bp->pfid;
 	u32 port = BP_PORT(bp);
 
 	cnic_init_bnx2x_mac(dev);
@@ -4996,7 +4992,7 @@ static void cnic_init_bnx2x_rx_ring(struct cnic_dev *dev,
 	data->general.activate_flg = 1;
 	data->general.sp_client_id = cli;
 	data->general.mtu = cpu_to_le16(cp->l2_single_buf_size - 14);
-	data->general.func_id = cp->pfid;
+	data->general.func_id = bp->pfid;
 
 	for (i = 0; i < BNX2X_MAX_RX_DESC_CNT; i++, rxbd++) {
 		dma_addr_t buf_map;
@@ -5046,7 +5042,7 @@ static void cnic_init_bnx2x_kcq(struct cnic_dev *dev)
 {
 	struct cnic_local *cp = dev->cnic_priv;
 	struct bnx2x *bp = netdev_priv(dev->netdev);
-	u32 pfid = cp->pfid;
+	u32 pfid = bp->pfid;
 
 	cp->kcq1.io_addr = BAR_CSTRORM_INTMEM +
 			   CSTORM_ISCSI_EQ_PROD_OFFSET(pfid, 0);
@@ -5090,11 +5086,10 @@ static int cnic_start_bnx2x_hw(struct cnic_dev *dev)
 	u32 pfid;
 
 	dev->stats_addr = ethdev->addr_drv_info_to_mcp;
-	cp->pfid = bp->pfid;
 	cp->func = bp->pf_num;
 
 	func = CNIC_FUNC(cp);
-	pfid = cp->pfid;
+	pfid = bp->pfid;
 
 	ret = cnic_init_id_tbl(&cp->cid_tbl, MAX_ISCSI_TBL_SZ,
 			       cp->iscsi_start_cid, 0);
@@ -5393,7 +5388,7 @@ static void cnic_stop_bnx2x_hw(struct cnic_dev *dev)
 
 	*cp->kcq1.hw_prod_idx_ptr = 0;
 	CNIC_WR(dev, BAR_CSTRORM_INTMEM +
-		CSTORM_ISCSI_EQ_CONS_OFFSET(cp->pfid, 0), 0);
+		CSTORM_ISCSI_EQ_CONS_OFFSET(bp->pfid, 0), 0);
 	CNIC_WR16(dev, cp->kcq1.io_addr, 0);
 	cnic_free_resc(dev);
 }
diff --git a/drivers/net/ethernet/broadcom/cnic.h b/drivers/net/ethernet/broadcom/cnic.h
index 10531f6..0121a5d 100644
--- a/drivers/net/ethernet/broadcom/cnic.h
+++ b/drivers/net/ethernet/broadcom/cnic.h
@@ -303,7 +303,6 @@ struct cnic_local {
 
 	u32			chip_id;
 	int			func;
-	u32			pfid;
 
 	u32			shmem_base;
 
-- 
1.7.1
