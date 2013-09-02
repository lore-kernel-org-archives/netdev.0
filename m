From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 1/5] cnic: Use CHIP_NUM macros from bnx2x.h
Date: Mon, 2 Sep 2013 11:42:28 -0700
Message-ID: <1378147352-9076-2-git-send-email-mchan@broadcom.com>
References: <1378147352-9076-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2700 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756901Ab3IBSWW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Sep 2013 14:22:22 -0400
In-Reply-To: <1378147352-9076-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This eliminates duplication and ensures that all bnx2x chips will be
supported.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/cnic.c |   37 ++++++++++++---------
 drivers/net/ethernet/broadcom/cnic.h |   59 ++++-----------------------------
 2 files changed, 29 insertions(+), 67 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index 4f8a535..3dadc81 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -1184,6 +1184,7 @@ error:
 static int cnic_alloc_bnx2x_context(struct cnic_dev *dev)
 {
 	struct cnic_local *cp = dev->cnic_priv;
+	struct bnx2x *bp = netdev_priv(dev->netdev);
 	int ctx_blk_size = cp->ethdev->ctx_blk_size;
 	int total_mem, blks, i;
 
@@ -1201,7 +1202,7 @@ static int cnic_alloc_bnx2x_context(struct cnic_dev *dev)
 
 	cp->ctx_blks = blks;
 	cp->ctx_blk_size = ctx_blk_size;
-	if (!BNX2X_CHIP_IS_57710(cp->chip_id))
+	if (!CHIP_IS_E1(bp))
 		cp->ctx_align = 0;
 	else
 		cp->ctx_align = ctx_blk_size;
@@ -1231,6 +1232,7 @@ static int cnic_alloc_bnx2x_context(struct cnic_dev *dev)
 static int cnic_alloc_bnx2x_resc(struct cnic_dev *dev)
 {
 	struct cnic_local *cp = dev->cnic_priv;
+	struct bnx2x *bp = netdev_priv(dev->netdev);
 	struct cnic_eth_dev *ethdev = cp->ethdev;
 	u32 start_cid = ethdev->starting_cid;
 	int i, j, n, ret, pages;
@@ -1240,7 +1242,7 @@ static int cnic_alloc_bnx2x_resc(struct cnic_dev *dev)
 	cp->iscsi_start_cid = start_cid;
 	cp->fcoe_start_cid = start_cid + MAX_ISCSI_TBL_SZ;
 
-	if (BNX2X_CHIP_IS_E2_PLUS(cp->chip_id)) {
+	if (BNX2X_CHIP_IS_E2_PLUS(bp)) {
 		cp->max_cid_space += dev->max_fcoe_conn;
 		cp->fcoe_init_cid = ethdev->fcoe_init_cid;
 		if (!cp->fcoe_init_cid)
@@ -1288,7 +1290,7 @@ static int cnic_alloc_bnx2x_resc(struct cnic_dev *dev)
 	if (ret)
 		goto error;
 
-	if (CNIC_SUPPORTS_FCOE(cp)) {
+	if (CNIC_SUPPORTS_FCOE(bp)) {
 		ret = cnic_alloc_kcq(dev, &cp->kcq2, true);
 		if (ret)
 			goto error;
@@ -1679,6 +1681,7 @@ static int cnic_setup_bnx2x_ctx(struct cnic_dev *dev, struct kwqe *wqes[],
 				u32 num)
 {
 	struct cnic_local *cp = dev->cnic_priv;
+	struct bnx2x *bp = netdev_priv(dev->netdev);
 	struct iscsi_kwqe_conn_offload1 *req1 =
 			(struct iscsi_kwqe_conn_offload1 *) wqes[0];
 	struct iscsi_kwqe_conn_offload2 *req2 =
@@ -1745,7 +1748,7 @@ static int cnic_setup_bnx2x_ctx(struct cnic_dev *dev, struct kwqe *wqes[],
 		XSTORM_ISCSI_CONTEXT_FLAGS_B_INITIAL_R2T;
 	ictx->xstorm_st_context.common.ethernet.reserved_vlan_type =
 		ETH_P_8021Q;
-	if (BNX2X_CHIP_IS_E2_PLUS(cp->chip_id) &&
+	if (BNX2X_CHIP_IS_E2_PLUS(bp) &&
 		cp->port_mode == CHIP_2_PORT_MODE) {
 
 		port = 0;
@@ -2716,7 +2719,7 @@ static int cnic_submit_bnx2x_iscsi_kwqes(struct cnic_dev *dev,
 static int cnic_submit_bnx2x_fcoe_kwqes(struct cnic_dev *dev,
 					struct kwqe *wqes[], u32 num_wqes)
 {
-	struct cnic_local *cp = dev->cnic_priv;
+	struct bnx2x *bp = netdev_priv(dev->netdev);
 	int i, work, ret;
 	u32 opcode;
 	struct kwqe *kwqe;
@@ -2724,7 +2727,7 @@ static int cnic_submit_bnx2x_fcoe_kwqes(struct cnic_dev *dev,
 	if (!test_bit(CNIC_F_CNIC_UP, &dev->flags))
 		return -EAGAIN;		/* bnx2 is down */
 
-	if (!BNX2X_CHIP_IS_E2_PLUS(cp->chip_id))
+	if (!BNX2X_CHIP_IS_E2_PLUS(bp))
 		return -EINVAL;
 
 	for (i = 0; i < num_wqes; ) {
@@ -4902,6 +4905,7 @@ static void cnic_init_bnx2x_tx_ring(struct cnic_dev *dev,
 				    struct client_init_ramrod_data *data)
 {
 	struct cnic_local *cp = dev->cnic_priv;
+	struct bnx2x *bp = netdev_priv(dev->netdev);
 	struct cnic_uio_dev *udev = cp->udev;
 	union eth_tx_bd_types *txbd = (union eth_tx_bd_types *) udev->l2_ring;
 	dma_addr_t buf_map, ring_map = udev->l2_ring_map;
@@ -4930,7 +4934,7 @@ static void cnic_init_bnx2x_tx_ring(struct cnic_dev *dev,
 		start_bd->general_data &= ~ETH_TX_START_BD_PARSE_NBDS;
 		start_bd->general_data |= (1 << ETH_TX_START_BD_HDR_NBDS_SHIFT);
 
-		if (BNX2X_CHIP_IS_E2_PLUS(cp->chip_id))
+		if (BNX2X_CHIP_IS_E2_PLUS(bp))
 			pbd_e2->parsing_data = (UNICAST_ADDRESS <<
 				ETH_TX_PARSE_BD_E2_ETH_ADDR_TYPE_SHIFT);
 		else
@@ -4967,6 +4971,7 @@ static void cnic_init_bnx2x_rx_ring(struct cnic_dev *dev,
 				    struct client_init_ramrod_data *data)
 {
 	struct cnic_local *cp = dev->cnic_priv;
+	struct bnx2x *bp = netdev_priv(dev->netdev);
 	struct cnic_uio_dev *udev = cp->udev;
 	struct eth_rx_bd *rxbd = (struct eth_rx_bd *) (udev->l2_ring +
 				BNX2_PAGE_SIZE);
@@ -4975,7 +4980,7 @@ static void cnic_init_bnx2x_rx_ring(struct cnic_dev *dev,
 	struct host_sp_status_block *sb = cp->bnx2x_def_status_blk;
 	int i;
 	u32 cli = cp->ethdev->iscsi_l2_client_id;
-	int cl_qzone_id = BNX2X_CL_QZONE_ID(cp, cli);
+	int cl_qzone_id = BNX2X_CL_QZONE_ID(bp, cli);
 	u32 val;
 	dma_addr_t ring_map = udev->l2_ring_map;
 
@@ -5040,7 +5045,7 @@ static void cnic_init_bnx2x_kcq(struct cnic_dev *dev)
 			   CSTORM_ISCSI_EQ_PROD_OFFSET(pfid, 0);
 	cp->kcq1.sw_prod_idx = 0;
 
-	if (BNX2X_CHIP_IS_E2_PLUS(cp->chip_id)) {
+	if (BNX2X_CHIP_IS_E2_PLUS(bp)) {
 		struct host_hc_status_block_e2 *sb = cp->status_blk.gen;
 
 		cp->kcq1.hw_prod_idx_ptr =
@@ -5056,7 +5061,7 @@ static void cnic_init_bnx2x_kcq(struct cnic_dev *dev)
 			&sb->sb.running_index[SM_RX_ID];
 	}
 
-	if (BNX2X_CHIP_IS_E2_PLUS(cp->chip_id)) {
+	if (BNX2X_CHIP_IS_E2_PLUS(bp)) {
 		struct host_hc_status_block_e2 *sb = cp->status_blk.gen;
 
 		cp->kcq2.io_addr = BAR_USTRORM_INTMEM +
@@ -5091,7 +5096,7 @@ static int cnic_start_bnx2x_hw(struct cnic_dev *dev)
 	if (ret)
 		return -ENOMEM;
 
-	if (BNX2X_CHIP_IS_E2_PLUS(cp->chip_id)) {
+	if (BNX2X_CHIP_IS_E2_PLUS(bp)) {
 		ret = cnic_init_id_tbl(&cp->fcoe_cid_tbl, dev->max_fcoe_conn,
 					cp->fcoe_start_cid, 0);
 
@@ -5173,10 +5178,10 @@ static void cnic_init_rings(struct cnic_dev *dev)
 		rx_prods.cqe_prod = BNX2X_MAX_RCQ_DESC_CNT;
 		barrier();
 
-		cl_qzone_id = BNX2X_CL_QZONE_ID(cp, cli);
+		cl_qzone_id = BNX2X_CL_QZONE_ID(bp, cli);
 
 		off = BAR_USTRORM_INTMEM +
-			(BNX2X_CHIP_IS_E2_PLUS(cp->chip_id) ?
+			(BNX2X_CHIP_IS_E2_PLUS(bp) ?
 			 USTORM_RX_PRODS_E2_OFFSET(cl_qzone_id) :
 			 USTORM_RX_PRODS_E1X_OFFSET(CNIC_PORT(cp), cli));
 
@@ -5365,7 +5370,7 @@ static void cnic_stop_bnx2x_hw(struct cnic_dev *dev)
 
 	cnic_free_irq(dev);
 
-	if (BNX2X_CHIP_IS_E2_PLUS(cp->chip_id)) {
+	if (BNX2X_CHIP_IS_E2_PLUS(bp)) {
 		idx_off = offsetof(struct hc_status_block_e2, index_values) +
 			  (hc_index * sizeof(u16));
 
@@ -5556,7 +5561,7 @@ static struct cnic_dev *init_bnx2x_cnic(struct net_device *dev)
 
 	if (!(ethdev->drv_state & CNIC_DRV_STATE_NO_ISCSI))
 		cdev->max_iscsi_conn = ethdev->max_iscsi_conn;
-	if (CNIC_SUPPORTS_FCOE(cp)) {
+	if (CNIC_SUPPORTS_FCOE(bp)) {
 		cdev->max_fcoe_conn = ethdev->max_fcoe_conn;
 		cdev->max_fcoe_exchanges = ethdev->max_fcoe_exchanges;
 	}
@@ -5576,7 +5581,7 @@ static struct cnic_dev *init_bnx2x_cnic(struct net_device *dev)
 	cp->stop_cm = cnic_cm_stop_bnx2x_hw;
 	cp->enable_int = cnic_enable_bnx2x_int;
 	cp->disable_int_sync = cnic_disable_bnx2x_int_sync;
-	if (BNX2X_CHIP_IS_E2_PLUS(cp->chip_id)) {
+	if (BNX2X_CHIP_IS_E2_PLUS(bp)) {
 		cp->ack_int = cnic_ack_bnx2x_e2_msix;
 		cp->arm_int = cnic_arm_bnx2x_e2_msix;
 	} else {
diff --git a/drivers/net/ethernet/broadcom/cnic.h b/drivers/net/ethernet/broadcom/cnic.h
index e7a2474..519f587 100644
--- a/drivers/net/ethernet/broadcom/cnic.h
+++ b/drivers/net/ethernet/broadcom/cnic.h
@@ -364,47 +364,7 @@ struct bnx2x_bd_chain_next {
 
 #define BNX2X_FCOE_L5_CID_BASE		MAX_ISCSI_TBL_SZ
 
-#define BNX2X_CHIP_NUM_57710		0x164e
-#define BNX2X_CHIP_NUM_57711		0x164f
-#define BNX2X_CHIP_NUM_57711E		0x1650
-#define BNX2X_CHIP_NUM_57712		0x1662
-#define BNX2X_CHIP_NUM_57712E		0x1663
-#define BNX2X_CHIP_NUM_57713		0x1651
-#define BNX2X_CHIP_NUM_57713E		0x1652
-#define BNX2X_CHIP_NUM_57800		0x168a
-#define BNX2X_CHIP_NUM_57810		0x168e
-#define BNX2X_CHIP_NUM_57840		0x168d
-
-#define BNX2X_CHIP_NUM(x)		(x >> 16)
-#define BNX2X_CHIP_IS_57710(x)		\
-	(BNX2X_CHIP_NUM(x) == BNX2X_CHIP_NUM_57710)
-#define BNX2X_CHIP_IS_57711(x)		\
-	(BNX2X_CHIP_NUM(x) == BNX2X_CHIP_NUM_57711)
-#define BNX2X_CHIP_IS_57711E(x)		\
-	(BNX2X_CHIP_NUM(x) == BNX2X_CHIP_NUM_57711E)
-#define BNX2X_CHIP_IS_E1H(x)		\
-	(BNX2X_CHIP_IS_57711(x) || BNX2X_CHIP_IS_57711E(x))
-#define BNX2X_CHIP_IS_57712(x)		\
-	(BNX2X_CHIP_NUM(x) == BNX2X_CHIP_NUM_57712)
-#define BNX2X_CHIP_IS_57712E(x)		\
-	(BNX2X_CHIP_NUM(x) == BNX2X_CHIP_NUM_57712E)
-#define BNX2X_CHIP_IS_57713(x)		\
-	(BNX2X_CHIP_NUM(x) == BNX2X_CHIP_NUM_57713)
-#define BNX2X_CHIP_IS_57713E(x)		\
-	(BNX2X_CHIP_NUM(x) == BNX2X_CHIP_NUM_57713E)
-#define BNX2X_CHIP_IS_57800(x)		\
-	(BNX2X_CHIP_NUM(x) == BNX2X_CHIP_NUM_57800)
-#define BNX2X_CHIP_IS_57810(x)		\
-	(BNX2X_CHIP_NUM(x) == BNX2X_CHIP_NUM_57810)
-#define BNX2X_CHIP_IS_57840(x)		\
-	(BNX2X_CHIP_NUM(x) == BNX2X_CHIP_NUM_57840)
-#define BNX2X_CHIP_IS_E2(x)		\
-	(BNX2X_CHIP_IS_57712(x) || BNX2X_CHIP_IS_57712E(x) || \
-	 BNX2X_CHIP_IS_57713(x) || BNX2X_CHIP_IS_57713E(x))
-#define BNX2X_CHIP_IS_E3(x)			\
-	(BNX2X_CHIP_IS_57800(x) || BNX2X_CHIP_IS_57810(x) || \
-	 BNX2X_CHIP_IS_57840(x))
-#define BNX2X_CHIP_IS_E2_PLUS(x) (BNX2X_CHIP_IS_E2(x) || BNX2X_CHIP_IS_E3(x))
+#define BNX2X_CHIP_IS_E2_PLUS(bp) (CHIP_IS_E2(bp) || CHIP_IS_E3(bp))
 
 #define BNX2X_RX_DESC_CNT		(BNX2_PAGE_SIZE / \
 					 sizeof(struct eth_rx_bd))
@@ -441,8 +401,6 @@ struct bnx2x_bd_chain_next {
 
 #define CNIC_PORT(cp)			((cp)->pfid & 1)
 #define CNIC_FUNC(cp)			((cp)->func)
-#define CNIC_PATH(cp)			(!BNX2X_CHIP_IS_E2_PLUS(cp->chip_id) ? \
-					 0 : (CNIC_FUNC(cp) & 1))
 #define CNIC_E1HVN(cp)			((cp)->pfid >> 1)
 
 #define BNX2X_HW_CID(cp, x)		((CNIC_PORT(cp) << 23) | \
@@ -450,20 +408,19 @@ struct bnx2x_bd_chain_next {
 
 #define BNX2X_SW_CID(x)			(x & 0x1ffff)
 
-#define BNX2X_CL_QZONE_ID(cp, cli)					\
-		(BNX2X_CHIP_IS_E2_PLUS(cp->chip_id) ? cli :		\
-		 cli + (CNIC_PORT(cp) * ETH_MAX_RX_CLIENTS_E1H))
+#define BNX2X_CL_QZONE_ID(bp, cli)					\
+		(BNX2X_CHIP_IS_E2_PLUS(bp) ? cli :			\
+		 cli + (BP_PORT(bp) * ETH_MAX_RX_CLIENTS_E1H))
 
 #ifndef MAX_STAT_COUNTER_ID
 #define MAX_STAT_COUNTER_ID						\
-	(BNX2X_CHIP_IS_E1H((cp)->chip_id) ? MAX_STAT_COUNTER_ID_E1H :	\
-	 ((BNX2X_CHIP_IS_E2_PLUS((cp)->chip_id)) ? MAX_STAT_COUNTER_ID_E2 :\
+	(CHIP_IS_E1H(bp) ? MAX_STAT_COUNTER_ID_E1H :			\
+	 ((BNX2X_CHIP_IS_E2_PLUS(bp)) ? MAX_STAT_COUNTER_ID_E2 :	\
 	  MAX_STAT_COUNTER_ID_E1))
 #endif
 
-#define CNIC_SUPPORTS_FCOE(cp)					\
-	(BNX2X_CHIP_IS_E2_PLUS((cp)->chip_id) &&		\
-	 !((cp)->ethdev->drv_state & CNIC_DRV_STATE_NO_FCOE))
+#define CNIC_SUPPORTS_FCOE(cp)						\
+	(BNX2X_CHIP_IS_E2_PLUS(bp) && !NO_FCOE(bp))
 
 #define CNIC_RAMROD_TMO			(HZ / 4)
 
-- 
1.7.1
