From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next 16/19] bnx2x, cnic: Fix SPQ return credit
Date: Wed, 6 Oct 2010 15:33:18 +0200
Message-ID: <1286371998.30552.58.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, mchan@broadcom.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4218 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932325Ab0JFNki (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Oct 2010 09:40:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Return proper L2 and L5 SPQ (slow path queue) credits.  Previously, all
SPQ events were counted as L5 types.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_cmn.c  |   13 ------
 drivers/net/bnx2x/bnx2x_main.c |   86 ++++++++++++++++++++++++++++++++--------
 drivers/net/cnic.c             |   18 +++++----
 drivers/net/cnic_if.h          |   21 ++++++----
 4 files changed, 91 insertions(+), 47 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index a0c5655..a43cbc4 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -1362,19 +1362,6 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 
 	bnx2x_set_eth_mac(bp, 1);
 
-#ifdef BCM_CNIC
-	/* Set iSCSI L2 MAC */
-	mutex_lock(&bp->cnic_mutex);
-	if (bp->cnic_eth_dev.drv_state & CNIC_DRV_STATE_REGD) {
-		bnx2x_set_iscsi_eth_mac_addr(bp, 1);
-		bp->cnic_flags |= BNX2X_CNIC_FLAG_MAC_SET;
-		bnx2x_init_sb(bp, bp->cnic_sb_mapping,
-			      BNX2X_VF_ID_INVALID, false,
-			      CNIC_SB_ID(bp), CNIC_IGU_SB_ID(bp));
-	}
-	mutex_unlock(&bp->cnic_mutex);
-#endif
-
 	if (bp->port.pmf)
 		bnx2x_initial_phy_init(bp, load_mode);
 
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 34ed5db..dcc4900 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -6465,6 +6465,12 @@ static int __devinit bnx2x_set_int_mode(struct bnx2x *bp)
 	return rc;
 }
 
+/* must be called prioir to any HW initializations */
+static inline u16 bnx2x_cid_ilt_lines(struct bnx2x *bp)
+{
+	return L2_ILT_LINES(bp);
+}
+
 void bnx2x_ilt_set_info(struct bnx2x *bp)
 {
 	struct ilt_client_info *ilt_client;
@@ -9350,19 +9356,53 @@ static void bnx2x_cnic_sp_post(struct bnx2x *bp, int count)
 #endif
 
 	spin_lock_bh(&bp->spq_lock);
+	BUG_ON(bp->cnic_spq_pending < count);
 	bp->cnic_spq_pending -= count;
 
-	for (; bp->cnic_spq_pending < bp->cnic_eth_dev.max_kwqe_pending;
-	     bp->cnic_spq_pending++) {
 
-		if (!bp->cnic_kwq_pending)
+	for (; bp->cnic_kwq_pending; bp->cnic_kwq_pending--) {
+		u16 type =  (le16_to_cpu(bp->cnic_kwq_cons->hdr.type)
+				& SPE_HDR_CONN_TYPE) >>
+				SPE_HDR_CONN_TYPE_SHIFT;
+
+		/* Set validation for iSCSI L2 client before sending SETUP
+		 *  ramrod
+		 */
+		if (type == ETH_CONNECTION_TYPE) {
+			u8 cmd = (le32_to_cpu(bp->cnic_kwq_cons->
+					     hdr.conn_and_cmd_data) >>
+				SPE_HDR_CMD_ID_SHIFT) & 0xff;
+
+			if (cmd == RAMROD_CMD_ID_ETH_CLIENT_SETUP)
+				bnx2x_set_ctx_validation(&bp->context.
+						vcxt[BNX2X_ISCSI_ETH_CID].eth,
+					HW_CID(bp, BNX2X_ISCSI_ETH_CID));
+		}
+
+		/* There may be not more than 8 L2 and COMMON SPEs and not more
+		 * than 8 L5 SPEs in the air.
+		 */
+		if ((type == NONE_CONNECTION_TYPE) ||
+		    (type == ETH_CONNECTION_TYPE)) {
+			if (!atomic_read(&bp->spq_left))
+				break;
+			else
+				atomic_dec(&bp->spq_left);
+		} else if (type == ISCSI_CONNECTION_TYPE) {
+			if (bp->cnic_spq_pending >=
+			    bp->cnic_eth_dev.max_kwqe_pending)
+				break;
+			else
+				bp->cnic_spq_pending++;
+		} else {
+			BNX2X_ERR("Unknown SPE type: %d\n", type);
+			bnx2x_panic();
 			break;
+		}
 
 		spe = bnx2x_sp_get_next(bp);
 		*spe = *bp->cnic_kwq_cons;
 
-		bp->cnic_kwq_pending--;
-
 		DP(NETIF_MSG_TIMER, "pending on SPQ %d, on KWQ %d count %d\n",
 		   bp->cnic_spq_pending, bp->cnic_kwq_pending, count);
 
@@ -9467,7 +9507,7 @@ static void bnx2x_cnic_cfc_comp(struct bnx2x *bp, int cid)
 	ctl.data.comp.cid = cid;
 
 	bnx2x_cnic_ctl_send_bh(bp, &ctl);
-	bnx2x_cnic_sp_post(bp, 1);
+	bnx2x_cnic_sp_post(bp, 0);
 }
 
 static int bnx2x_drv_ctl(struct net_device *dev, struct drv_ctl_info *ctl)
@@ -9484,8 +9524,8 @@ static int bnx2x_drv_ctl(struct net_device *dev, struct drv_ctl_info *ctl)
 		break;
 	}
 
-	case DRV_CTL_COMPLETION_CMD: {
-		int count = ctl->data.comp.comp_count;
+	case DRV_CTL_RET_L5_SPQ_CREDIT_CMD: {
+		int count = ctl->data.credit.credit_count;
 
 		bnx2x_cnic_sp_post(bp, count);
 		break;
@@ -9531,6 +9571,14 @@ static int bnx2x_drv_ctl(struct net_device *dev, struct drv_ctl_info *ctl)
 		bnx2x_set_iscsi_eth_mac_addr(bp, 0);
 		break;
 	}
+	case DRV_CTL_RET_L2_SPQ_CREDIT_CMD: {
+		int count = ctl->data.credit.credit_count;
+
+		smp_mb__before_atomic_inc();
+		atomic_add(count, &bp->spq_left);
+		smp_mb__after_atomic_inc();
+		break;
+	}
 
 	default:
 		BNX2X_ERR("unknown command %x\n", ctl->cmd);
@@ -9595,13 +9643,8 @@ static int bnx2x_register_cnic(struct net_device *dev, struct cnic_ops *ops,
 	cp->drv_state = CNIC_DRV_STATE_REGD;
 	cp->iro_arr = bp->iro_arr;
 
-	bnx2x_init_sb(bp, bp->cnic_sb_mapping,
-		      BNX2X_VF_ID_INVALID, false,
-		      CNIC_SB_ID(bp), CNIC_IGU_SB_ID(bp));
-
 	bnx2x_setup_cnic_irq_info(bp);
-	bnx2x_set_iscsi_eth_mac_addr(bp, 1);
-	bp->cnic_flags |= BNX2X_CNIC_FLAG_MAC_SET;
+
 	rcu_assign_pointer(bp->cnic_ops, ops);
 
 	return 0;
@@ -9639,14 +9682,23 @@ struct cnic_eth_dev *bnx2x_cnic_probe(struct net_device *dev)
 	cp->io_base2 = bp->doorbells;
 	cp->max_kwqe_pending = 8;
 	cp->ctx_blk_size = CDU_ILT_PAGE_SZ;
-	cp->ctx_tbl_offset = FUNC_ILT_BASE(BP_FUNC(bp)) + 1;
+	cp->ctx_tbl_offset = FUNC_ILT_BASE(BP_FUNC(bp)) +
+			     bnx2x_cid_ilt_lines(bp);
 	cp->ctx_tbl_len = CNIC_ILT_LINES;
-	cp->starting_cid = BCM_CNIC_CID_START;
+	cp->starting_cid = bnx2x_cid_ilt_lines(bp) * ILT_PAGE_CIDS;
 	cp->drv_submit_kwqes_16 = bnx2x_cnic_sp_queue;
 	cp->drv_ctl = bnx2x_drv_ctl;
 	cp->drv_register_cnic = bnx2x_register_cnic;
 	cp->drv_unregister_cnic = bnx2x_unregister_cnic;
-
+	cp->iscsi_l2_client_id = BNX2X_ISCSI_ETH_CL_ID;
+	cp->iscsi_l2_cid = BNX2X_ISCSI_ETH_CID;
+
+	DP(BNX2X_MSG_SP, "page_size %d, tbl_offset %d, tbl_lines %d, "
+			 "starting cid %d\n",
+	   cp->ctx_blk_size,
+	   cp->ctx_tbl_offset,
+	   cp->ctx_tbl_len,
+	   cp->starting_cid);
 	return cp;
 }
 EXPORT_SYMBOL(bnx2x_cnic_probe);
diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 8025981..27449bf 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -242,14 +242,14 @@ static int cnic_in_use(struct cnic_sock *csk)
 	return test_bit(SK_F_INUSE, &csk->flags);
 }
 
-static void cnic_kwq_completion(struct cnic_dev *dev, u32 count)
+static void cnic_spq_completion(struct cnic_dev *dev, int cmd, u32 count)
 {
 	struct cnic_local *cp = dev->cnic_priv;
 	struct cnic_eth_dev *ethdev = cp->ethdev;
 	struct drv_ctl_info info;
 
-	info.cmd = DRV_CTL_COMPLETION_CMD;
-	info.data.comp.comp_count = count;
+	info.cmd = cmd;
+	info.data.credit.credit_count = count;
 	ethdev->drv_ctl(dev->netdev, &info);
 }
 
@@ -2069,7 +2069,7 @@ static int cnic_submit_bnx2x_kwqes(struct cnic_dev *dev, struct kwqe *wqes[],
 static void service_kcqes(struct cnic_dev *dev, int num_cqes)
 {
 	struct cnic_local *cp = dev->cnic_priv;
-	int i, j;
+	int i, j, comp = 0;
 
 	i = 0;
 	j = 1;
@@ -2080,7 +2080,7 @@ static void service_kcqes(struct cnic_dev *dev, int num_cqes)
 		u32 kcqe_layer = kcqe_op_flag & KCQE_FLAGS_LAYER_MASK;
 
 		if (unlikely(kcqe_op_flag & KCQE_RAMROD_COMPLETION))
-			cnic_kwq_completion(dev, 1);
+			comp++;
 
 		while (j < num_cqes) {
 			u32 next_op = cp->completed_kcq[i + j]->kcqe_op_flag;
@@ -2089,7 +2089,7 @@ static void service_kcqes(struct cnic_dev *dev, int num_cqes)
 				break;
 
 			if (unlikely(next_op & KCQE_RAMROD_COMPLETION))
-				cnic_kwq_completion(dev, 1);
+				comp++;
 			j++;
 		}
 
@@ -2119,6 +2119,8 @@ end:
 		i += j;
 		j = 1;
 	}
+	if (unlikely(comp))
+		cnic_spq_completion(dev, DRV_CTL_RET_L5_SPQ_CREDIT_CMD, comp);
 }
 
 static u16 cnic_bnx2_next_idx(u16 idx)
@@ -4246,7 +4248,7 @@ static void cnic_init_rings(struct cnic_dev *dev)
 		if (test_bit(CNIC_LCL_FL_L2_WAIT, &cp->cnic_local_flags))
 			netdev_err(dev->netdev,
 				"iSCSI CLIENT_SETUP did not complete\n");
-		cnic_kwq_completion(dev, 1);
+		cnic_spq_completion(dev, DRV_CTL_RET_L2_SPQ_CREDIT_CMD, 1);
 		cnic_ring_ctl(dev, BNX2X_ISCSI_L2_CID, cli, 1);
 	}
 }
@@ -4283,7 +4285,7 @@ static void cnic_shutdown_rings(struct cnic_dev *dev)
 		if (test_bit(CNIC_LCL_FL_L2_WAIT, &cp->cnic_local_flags))
 			netdev_err(dev->netdev,
 				"iSCSI CLIENT_HALT did not complete\n");
-		cnic_kwq_completion(dev, 1);
+		cnic_spq_completion(dev, DRV_CTL_RET_L2_SPQ_CREDIT_CMD, 1);
 
 		memset(&l5_data, 0, sizeof(l5_data));
 		type = (NONE_CONNECTION_TYPE << SPE_HDR_CONN_TYPE_SHIFT)
diff --git a/drivers/net/cnic_if.h b/drivers/net/cnic_if.h
index 4018de1..98ebac5 100644
--- a/drivers/net/cnic_if.h
+++ b/drivers/net/cnic_if.h
@@ -12,8 +12,8 @@
 #ifndef CNIC_IF_H
 #define CNIC_IF_H
 
-#define CNIC_MODULE_VERSION	"2.1.3"
-#define CNIC_MODULE_RELDATE	"June 24, 2010"
+#define CNIC_MODULE_VERSION	"2.2.5"
+#define CNIC_MODULE_RELDATE	"September 29, 2010"
 
 #define CNIC_ULP_RDMA		0
 #define CNIC_ULP_ISCSI		1
@@ -80,18 +80,15 @@ struct kcqe {
 #define DRV_CTL_IO_RD_CMD		0x102
 #define DRV_CTL_CTX_WR_CMD		0x103
 #define DRV_CTL_CTXTBL_WR_CMD		0x104
-#define DRV_CTL_COMPLETION_CMD		0x105
+#define DRV_CTL_RET_L5_SPQ_CREDIT_CMD	0x105
 #define DRV_CTL_START_L2_CMD		0x106
 #define DRV_CTL_STOP_L2_CMD		0x107
+#define DRV_CTL_RET_L2_SPQ_CREDIT_CMD	0x10c
 
 struct cnic_ctl_completion {
 	u32	cid;
 };
 
-struct drv_ctl_completion {
-	u32	comp_count;
-};
-
 struct cnic_ctl_info {
 	int	cmd;
 	union {
@@ -100,6 +97,10 @@ struct cnic_ctl_info {
 	} data;
 };
 
+struct drv_ctl_spq_credit {
+	u32	credit_count;
+};
+
 struct drv_ctl_io {
 	u32		cid_addr;
 	u32		offset;
@@ -115,7 +116,7 @@ struct drv_ctl_l2_ring {
 struct drv_ctl_info {
 	int	cmd;
 	union {
-		struct drv_ctl_completion comp;
+		struct drv_ctl_spq_credit credit;
 		struct drv_ctl_io io;
 		struct drv_ctl_l2_ring ring;
 		char bytes[MAX_DRV_CTL_DATA];
@@ -162,7 +163,9 @@ struct cnic_eth_dev {
 	u32		max_iscsi_conn;
 	u32		max_fcoe_conn;
 	u32		max_rdma_conn;
-	u32		reserved0[2];
+	u32		fcoe_init_cid;
+	u16		iscsi_l2_client_id;
+	u16		iscsi_l2_cid;
 
 	int		num_irq;
 	struct cnic_irq	irq_arr[MAX_CNIC_VEC];
-- 
1.7.1




