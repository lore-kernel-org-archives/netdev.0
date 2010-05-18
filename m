From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2/2] cnic: Return SPQ credit to bnx2x after ring setup
 and shutdown.
Date: Tue, 18 May 2010 14:32:53 -0700
Message-ID: <1274218373-16324-2-git-send-email-mchan@broadcom.com>
References: <1274218373-16324-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2795 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754162Ab0ERVbc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 May 2010 17:31:32 -0400
In-Reply-To: <1274218373-16324-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Everytime the iSCSI ring finishes setup or shutdown, we need to return
the SPQ (slow path queue) credit to the bnx2x driver.  Without this step,
the SPQ will eventually be full causing iSCSI to fail.  This can happen
after 3 or 4 MTU changes for example.

Add code to wait for these slow path commands to complete in the RX ring
and return the SPQ credit to bnx2x.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/cnic.c |   71 +++++++++++++++++++++++++++++++++++++++++++++++++++-
 drivers/net/cnic.h |    5 +++
 2 files changed, 75 insertions(+), 1 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 7c6d325..be90d35 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -2145,17 +2145,56 @@ static int cnic_get_kcqes(struct cnic_dev *dev, u16 hw_prod, u16 *sw_prod)
 	return last_cnt;
 }
 
+static int cnic_l2_completion(struct cnic_local *cp)
+{
+	u16 hw_cons, sw_cons;
+	union eth_rx_cqe *cqe, *cqe_ring = (union eth_rx_cqe *)
+					(cp->l2_ring + (2 * BCM_PAGE_SIZE));
+	u32 cmd;
+	int comp = 0;
+
+	if (!test_bit(CNIC_F_BNX2X_CLASS, &cp->dev->flags))
+		return 0;
+
+	hw_cons = *cp->rx_cons_ptr;
+	if ((hw_cons & BNX2X_MAX_RCQ_DESC_CNT) == BNX2X_MAX_RCQ_DESC_CNT)
+		hw_cons++;
+
+	sw_cons = cp->rx_cons;
+	while (sw_cons != hw_cons) {
+		u8 cqe_fp_flags;
+
+		cqe = &cqe_ring[sw_cons & BNX2X_MAX_RCQ_DESC_CNT];
+		cqe_fp_flags = cqe->fast_path_cqe.type_error_flags;
+		if (cqe_fp_flags & ETH_FAST_PATH_RX_CQE_TYPE) {
+			cmd = le32_to_cpu(cqe->ramrod_cqe.conn_and_cmd_data);
+			cmd >>= COMMON_RAMROD_ETH_RX_CQE_CMD_ID_SHIFT;
+			if (cmd == RAMROD_CMD_ID_ETH_CLIENT_SETUP ||
+			    cmd == RAMROD_CMD_ID_ETH_HALT)
+				comp++;
+		}
+		sw_cons = BNX2X_NEXT_RCQE(sw_cons);
+	}
+	return comp;
+}
+
 static void cnic_chk_pkt_rings(struct cnic_local *cp)
 {
 	u16 rx_cons = *cp->rx_cons_ptr;
 	u16 tx_cons = *cp->tx_cons_ptr;
+	int comp = 0;
 
 	if (cp->tx_cons != tx_cons || cp->rx_cons != rx_cons) {
+		if (test_bit(CNIC_LCL_FL_L2_WAIT, &cp->cnic_local_flags))
+			comp = cnic_l2_completion(cp);
+
 		cp->tx_cons = tx_cons;
 		cp->rx_cons = rx_cons;
 
 		uio_event_notify(cp->cnic_uinfo);
 	}
+	if (comp)
+		clear_bit(CNIC_LCL_FL_L2_WAIT, &cp->cnic_local_flags);
 }
 
 static int cnic_service_bnx2(void *data, void *status_blk)
@@ -4168,6 +4207,8 @@ static void cnic_init_rings(struct cnic_dev *dev)
 		for (i = 0; i < sizeof(struct ustorm_eth_rx_producers) / 4; i++)
 			CNIC_WR(dev, off + i * 4, ((u32 *) &rx_prods)[i]);
 
+		set_bit(CNIC_LCL_FL_L2_WAIT, &cp->cnic_local_flags);
+
 		cnic_init_bnx2x_tx_ring(dev);
 		cnic_init_bnx2x_rx_ring(dev);
 
@@ -4175,6 +4216,15 @@ static void cnic_init_rings(struct cnic_dev *dev)
 		l5_data.phy_address.hi = 0;
 		cnic_submit_kwqe_16(dev, RAMROD_CMD_ID_ETH_CLIENT_SETUP,
 			BNX2X_ISCSI_L2_CID, ETH_CONNECTION_TYPE, &l5_data);
+		i = 0;
+		while (test_bit(CNIC_LCL_FL_L2_WAIT, &cp->cnic_local_flags) &&
+		       ++i < 10)
+			msleep(1);
+
+		if (test_bit(CNIC_LCL_FL_L2_WAIT, &cp->cnic_local_flags))
+			netdev_err(dev->netdev,
+				"iSCSI CLIENT_SETUP did not complete\n");
+		cnic_kwq_completion(dev, 1);
 		cnic_ring_ctl(dev, BNX2X_ISCSI_L2_CID, cli, 1);
 	}
 }
@@ -4187,14 +4237,25 @@ static void cnic_shutdown_rings(struct cnic_dev *dev)
 		struct cnic_local *cp = dev->cnic_priv;
 		u32 cli = BNX2X_ISCSI_CL_ID(CNIC_E1HVN(cp));
 		union l5cm_specific_data l5_data;
+		int i;
 
 		cnic_ring_ctl(dev, BNX2X_ISCSI_L2_CID, cli, 0);
 
+		set_bit(CNIC_LCL_FL_L2_WAIT, &cp->cnic_local_flags);
+
 		l5_data.phy_address.lo = cli;
 		l5_data.phy_address.hi = 0;
 		cnic_submit_kwqe_16(dev, RAMROD_CMD_ID_ETH_HALT,
 			BNX2X_ISCSI_L2_CID, ETH_CONNECTION_TYPE, &l5_data);
-		msleep(10);
+		i = 0;
+		while (test_bit(CNIC_LCL_FL_L2_WAIT, &cp->cnic_local_flags) &&
+		       ++i < 10)
+			msleep(1);
+
+		if (test_bit(CNIC_LCL_FL_L2_WAIT, &cp->cnic_local_flags))
+			netdev_err(dev->netdev,
+				"iSCSI CLIENT_HALT did not complete\n");
+		cnic_kwq_completion(dev, 1);
 
 		memset(&l5_data, 0, sizeof(l5_data));
 		cnic_submit_kwqe_16(dev, RAMROD_CMD_ID_ETH_CFC_DEL,
@@ -4315,7 +4376,15 @@ static void cnic_stop_hw(struct cnic_dev *dev)
 {
 	if (test_bit(CNIC_F_CNIC_UP, &dev->flags)) {
 		struct cnic_local *cp = dev->cnic_priv;
+		int i = 0;
 
+		/* Need to wait for the ring shutdown event to complete
+		 * before clearing the CNIC_UP flag.
+		 */
+		while (cp->uio_dev != -1 && i < 15) {
+			msleep(100);
+			i++;
+		}
 		clear_bit(CNIC_F_CNIC_UP, &dev->flags);
 		rcu_assign_pointer(cp->ulp_ops[CNIC_ULP_L4], NULL);
 		synchronize_rcu();
diff --git a/drivers/net/cnic.h b/drivers/net/cnic.h
index 4422497..08b1235 100644
--- a/drivers/net/cnic.h
+++ b/drivers/net/cnic.h
@@ -181,6 +181,7 @@ struct cnic_local {
 
 	unsigned long cnic_local_flags;
 #define	CNIC_LCL_FL_KWQ_INIT		0x0
+#define	CNIC_LCL_FL_L2_WAIT		0x1
 
 	struct cnic_dev *dev;
 
@@ -348,6 +349,10 @@ struct bnx2x_bd_chain_next {
 #define BNX2X_RCQ_DESC_CNT		(BCM_PAGE_SIZE / sizeof(union eth_rx_cqe))
 #define BNX2X_MAX_RCQ_DESC_CNT		(BNX2X_RCQ_DESC_CNT - 1)
 
+#define BNX2X_NEXT_RCQE(x) (((x) & BNX2X_MAX_RCQ_DESC_CNT) ==		\
+		(BNX2X_MAX_RCQ_DESC_CNT - 1)) ?				\
+		((x) + 2) : ((x) + 1)
+
 #define BNX2X_DEF_SB_ID			16
 
 #define BNX2X_ISCSI_RX_SB_INDEX_NUM					\
-- 
1.6.4.GIT


