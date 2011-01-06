From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next] cnic: Fix the type field in SPQ messages
Date: Wed, 5 Jan 2011 17:14:13 -0800
Message-ID: <1294276453-5957-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1964 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753798Ab1AFCJH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jan 2011 21:09:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The new firmware interface requires each Slow Path Queue (SPQ) message's
type field to include the function number.  The existing code does not
do this consistently.  We fix this by OR'ing in the function number
into the type field centrally in cnic_submit_kwqe_16().

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/cnic.c |   33 ++++++++++++---------------------
 1 files changed, 12 insertions(+), 21 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index aa5016a..263a294 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -1290,12 +1290,18 @@ static int cnic_submit_kwqe_16(struct cnic_dev *dev, u32 cmd, u32 cid,
 	struct cnic_local *cp = dev->cnic_priv;
 	struct l5cm_spe kwqe;
 	struct kwqe_16 *kwq[1];
+	u16 type_16;
 	int ret;
 
 	kwqe.hdr.conn_and_cmd_data =
 		cpu_to_le32(((cmd << SPE_HDR_CMD_ID_SHIFT) |
 			     BNX2X_HW_CID(cp, cid)));
-	kwqe.hdr.type = cpu_to_le16(type);
+
+	type_16 = (type << SPE_HDR_CONN_TYPE_SHIFT) & SPE_HDR_CONN_TYPE;
+	type_16 |= (cp->pfid << SPE_HDR_FUNCTION_ID_SHIFT) &
+		   SPE_HDR_FUNCTION_ID;
+
+	kwqe.hdr.type = cpu_to_le16(type_16);
 	kwqe.hdr.reserved1 = 0;
 	kwqe.data.phy_address.lo = cpu_to_le32(l5_data->phy_address.lo);
 	kwqe.data.phy_address.hi = cpu_to_le32(l5_data->phy_address.hi);
@@ -1819,19 +1825,15 @@ static int cnic_bnx2x_destroy_ramrod(struct cnic_dev *dev, u32 l5_cid)
 	struct cnic_context *ctx = &cp->ctx_tbl[l5_cid];
 	union l5cm_specific_data l5_data;
 	int ret;
-	u32 hw_cid, type;
+	u32 hw_cid;
 
 	init_waitqueue_head(&ctx->waitq);
 	ctx->wait_cond = 0;
 	memset(&l5_data, 0, sizeof(l5_data));
 	hw_cid = BNX2X_HW_CID(cp, ctx->cid);
-	type = (NONE_CONNECTION_TYPE << SPE_HDR_CONN_TYPE_SHIFT)
-		& SPE_HDR_CONN_TYPE;
-	type |= ((cp->pfid << SPE_HDR_FUNCTION_ID_SHIFT) &
-		 SPE_HDR_FUNCTION_ID);
 
 	ret = cnic_submit_kwqe_16(dev, RAMROD_CMD_ID_COMMON_CFC_DEL,
-				  hw_cid, type, &l5_data);
+				  hw_cid, NONE_CONNECTION_TYPE, &l5_data);
 
 	if (ret == 0)
 		wait_event(ctx->waitq, ctx->wait_cond);
@@ -2204,7 +2206,6 @@ static int cnic_bnx2x_fcoe_init1(struct cnic_dev *dev, struct kwqe *wqes[],
 	cp->kcq2.sw_prod_idx = 0;
 
 	cid = BNX2X_HW_CID(cp, cp->fcoe_init_cid);
-	printk(KERN_ERR "bdbg: submitting INIT RAMROD \n");
 	ret = cnic_submit_kwqe_16(dev, FCOE_RAMROD_CMD_ID_INIT, cid,
 				  FCOE_CONNECTION_TYPE, &l5_data);
 	*work = 3;
@@ -4977,7 +4978,7 @@ static void cnic_init_rings(struct cnic_dev *dev)
 	} else if (test_bit(CNIC_F_BNX2X_CLASS, &dev->flags)) {
 		u32 cli = cp->ethdev->iscsi_l2_client_id;
 		u32 cid = cp->ethdev->iscsi_l2_cid;
-		u32 cl_qzone_id, type;
+		u32 cl_qzone_id;
 		struct client_init_ramrod_data *data;
 		union l5cm_specific_data l5_data;
 		struct ustorm_eth_rx_producers rx_prods = {0};
@@ -5009,15 +5010,10 @@ static void cnic_init_rings(struct cnic_dev *dev)
 		l5_data.phy_address.lo = udev->l2_buf_map & 0xffffffff;
 		l5_data.phy_address.hi = (u64) udev->l2_buf_map >> 32;
 
-		type = (ETH_CONNECTION_TYPE << SPE_HDR_CONN_TYPE_SHIFT)
-			& SPE_HDR_CONN_TYPE;
-		type |= ((cp->pfid << SPE_HDR_FUNCTION_ID_SHIFT) &
-			SPE_HDR_FUNCTION_ID);
-
 		set_bit(CNIC_LCL_FL_RINGS_INITED, &cp->cnic_local_flags);
 
 		cnic_submit_kwqe_16(dev, RAMROD_CMD_ID_ETH_CLIENT_SETUP,
-			cid, type, &l5_data);
+			cid, ETH_CONNECTION_TYPE, &l5_data);
 
 		i = 0;
 		while (test_bit(CNIC_LCL_FL_L2_WAIT, &cp->cnic_local_flags) &&
@@ -5047,7 +5043,6 @@ static void cnic_shutdown_rings(struct cnic_dev *dev)
 		u32 cid = cp->ethdev->iscsi_l2_cid;
 		union l5cm_specific_data l5_data;
 		int i;
-		u32 type;
 
 		cnic_ring_ctl(dev, cid, cli, 0);
 
@@ -5068,12 +5063,8 @@ static void cnic_shutdown_rings(struct cnic_dev *dev)
 		cnic_spq_completion(dev, DRV_CTL_RET_L2_SPQ_CREDIT_CMD, 1);
 
 		memset(&l5_data, 0, sizeof(l5_data));
-		type = (NONE_CONNECTION_TYPE << SPE_HDR_CONN_TYPE_SHIFT)
-			& SPE_HDR_CONN_TYPE;
-		type |= ((cp->pfid << SPE_HDR_FUNCTION_ID_SHIFT) &
-			 SPE_HDR_FUNCTION_ID);
 		cnic_submit_kwqe_16(dev, RAMROD_CMD_ID_COMMON_CFC_DEL,
-			cid, type, &l5_data);
+			cid, NONE_CONNECTION_TYPE, &l5_data);
 		msleep(10);
 	}
 	clear_bit(CNIC_LCL_FL_RINGS_INITED, &cp->cnic_local_flags);
-- 
1.6.4.GIT


