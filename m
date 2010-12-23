From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 4/9] cnic: Use proper client and connection IDs
 on iSCSI ring
Date: Thu, 23 Dec 2010 09:42:59 -0800
Message-ID: <1293126184-13097-5-git-send-email-mchan@broadcom.com>
References: <1293126184-13097-1-git-send-email-mchan@broadcom.com>
 <1293126184-13097-2-git-send-email-mchan@broadcom.com>
 <1293126184-13097-3-git-send-email-mchan@broadcom.com>
 <1293126184-13097-4-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4838 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753605Ab0LWSkf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Dec 2010 13:40:35 -0500
In-Reply-To: <1293126184-13097-4-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the IDs specified by the bnx2x driver when initializing the ring.
We don't have to make code changes when these IDs change in the future.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/cnic.c |   21 ++++++++++++---------
 drivers/net/cnic.h |    5 -----
 2 files changed, 12 insertions(+), 14 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 9f80fb4..9bd133d 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -4119,7 +4119,7 @@ static void cnic_init_bnx2x_tx_ring(struct cnic_dev *dev,
 	struct host_sp_status_block *sb = cp->bnx2x_def_status_blk;
 	int port = CNIC_PORT(cp);
 	int i;
-	int cli = BNX2X_ISCSI_CL_ID(CNIC_E1HVN(cp));
+	u32 cli = cp->ethdev->iscsi_l2_client_id;
 	u32 val;
 
 	memset(txbd, 0, BCM_PAGE_SIZE);
@@ -4180,7 +4180,7 @@ static void cnic_init_bnx2x_rx_ring(struct cnic_dev *dev,
 	struct host_sp_status_block *sb = cp->bnx2x_def_status_blk;
 	int i;
 	int port = CNIC_PORT(cp);
-	int cli = BNX2X_ISCSI_CL_ID(CNIC_E1HVN(cp));
+	u32 cli = cp->ethdev->iscsi_l2_client_id;
 	int cl_qzone_id = BNX2X_CL_QZONE_ID(cp, cli);
 	u32 val;
 	dma_addr_t ring_map = udev->l2_ring_map;
@@ -4244,6 +4244,7 @@ static void cnic_init_bnx2x_rx_ring(struct cnic_dev *dev,
 
 	cp->rx_cons_ptr =
 		&sb->sp_sb.index_values[HC_SP_INDEX_ETH_ISCSI_RX_CQ_CONS];
+	cp->rx_cons = *cp->rx_cons_ptr;
 }
 
 static void cnic_get_bnx2x_iscsi_info(struct cnic_dev *dev)
@@ -4437,7 +4438,8 @@ static void cnic_init_rings(struct cnic_dev *dev)
 		cnic_init_bnx2_rx_ring(dev);
 		set_bit(CNIC_LCL_FL_RINGS_INITED, &cp->cnic_local_flags);
 	} else if (test_bit(CNIC_F_BNX2X_CLASS, &dev->flags)) {
-		u32 cli = BNX2X_ISCSI_CL_ID(CNIC_E1HVN(cp));
+		u32 cli = cp->ethdev->iscsi_l2_client_id;
+		u32 cid = cp->ethdev->iscsi_l2_cid;
 		u32 cl_qzone_id, type;
 		struct client_init_ramrod_data *data;
 		union l5cm_specific_data l5_data;
@@ -4478,7 +4480,7 @@ static void cnic_init_rings(struct cnic_dev *dev)
 		set_bit(CNIC_LCL_FL_RINGS_INITED, &cp->cnic_local_flags);
 
 		cnic_submit_kwqe_16(dev, RAMROD_CMD_ID_ETH_CLIENT_SETUP,
-			BNX2X_ISCSI_L2_CID, type, &l5_data);
+			cid, type, &l5_data);
 
 		i = 0;
 		while (test_bit(CNIC_LCL_FL_L2_WAIT, &cp->cnic_local_flags) &&
@@ -4489,7 +4491,7 @@ static void cnic_init_rings(struct cnic_dev *dev)
 			netdev_err(dev->netdev,
 				"iSCSI CLIENT_SETUP did not complete\n");
 		cnic_spq_completion(dev, DRV_CTL_RET_L2_SPQ_CREDIT_CMD, 1);
-		cnic_ring_ctl(dev, BNX2X_ISCSI_L2_CID, cli, 1);
+		cnic_ring_ctl(dev, cid, cli, 1);
 	}
 }
 
@@ -4504,19 +4506,20 @@ static void cnic_shutdown_rings(struct cnic_dev *dev)
 		cnic_shutdown_bnx2_rx_ring(dev);
 	} else if (test_bit(CNIC_F_BNX2X_CLASS, &dev->flags)) {
 		struct cnic_local *cp = dev->cnic_priv;
-		u32 cli = BNX2X_ISCSI_CL_ID(CNIC_E1HVN(cp));
+		u32 cli = cp->ethdev->iscsi_l2_client_id;
+		u32 cid = cp->ethdev->iscsi_l2_cid;
 		union l5cm_specific_data l5_data;
 		int i;
 		u32 type;
 
-		cnic_ring_ctl(dev, BNX2X_ISCSI_L2_CID, cli, 0);
+		cnic_ring_ctl(dev, cid, cli, 0);
 
 		set_bit(CNIC_LCL_FL_L2_WAIT, &cp->cnic_local_flags);
 
 		l5_data.phy_address.lo = cli;
 		l5_data.phy_address.hi = 0;
 		cnic_submit_kwqe_16(dev, RAMROD_CMD_ID_ETH_HALT,
-			BNX2X_ISCSI_L2_CID, ETH_CONNECTION_TYPE, &l5_data);
+			cid, ETH_CONNECTION_TYPE, &l5_data);
 		i = 0;
 		while (test_bit(CNIC_LCL_FL_L2_WAIT, &cp->cnic_local_flags) &&
 		       ++i < 10)
@@ -4533,7 +4536,7 @@ static void cnic_shutdown_rings(struct cnic_dev *dev)
 		type |= ((cp->pfid << SPE_HDR_FUNCTION_ID_SHIFT) &
 			 SPE_HDR_FUNCTION_ID);
 		cnic_submit_kwqe_16(dev, RAMROD_CMD_ID_COMMON_CFC_DEL,
-			BNX2X_ISCSI_L2_CID, type, &l5_data);
+			cid, type, &l5_data);
 		msleep(10);
 	}
 	clear_bit(CNIC_LCL_FL_RINGS_INITED, &cp->cnic_local_flags);
diff --git a/drivers/net/cnic.h b/drivers/net/cnic.h
index bf38e57..8e947b7 100644
--- a/drivers/net/cnic.h
+++ b/drivers/net/cnic.h
@@ -356,11 +356,6 @@ struct bnx2x_bd_chain_next {
 #define BNX2X_CONTEXT_MEM_SIZE		1024
 #define BNX2X_FCOE_CID			16
 
-/* iSCSI client IDs are 17, 19, 21, 23 */
-#define BNX2X_ISCSI_BASE_CL_ID		17
-#define BNX2X_ISCSI_CL_ID(vn)		(BNX2X_ISCSI_BASE_CL_ID + ((vn) << 1))
-
-#define BNX2X_ISCSI_L2_CID		17
 #define BNX2X_ISCSI_START_CID		18
 #define BNX2X_ISCSI_NUM_CONNECTIONS	128
 #define BNX2X_ISCSI_TASK_CONTEXT_SIZE	128
-- 
1.6.4.GIT


