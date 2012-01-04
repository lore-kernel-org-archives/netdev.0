From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2/2 net-next] cnic: Improve error recovery on bnx2x
 devices
Date: Wed, 4 Jan 2012 14:12:28 -0800
Message-ID: <1325715148-1371-2-git-send-email-mchan@broadcom.com>
References: <1325715148-1371-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3711 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757152Ab2ADWGH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jan 2012 17:06:07 -0500
In-Reply-To: <1325715148-1371-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a bnx2x device encounters parity errors, it will not respond to all
SPQ messages.  As a result, the shutdown sequence before reset can take
a long time as the ulp drivers (bnx2i/bnx2fc) have to wait for timeout
of all such messages.

To improve this scenario, when bnx2x returns error on the SPQ, we'll send
an immediate response to the ulp drivers to avoid such lengthy timeouts.

Adjust the return code of relevant functions to return error only if
the message cannot be sent on the SPQ so that we'll generate an error
completion to the ulp drivers.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/cnic.c      |   74 +++++++++++++++++++++++++++--
 drivers/net/ethernet/broadcom/cnic_defs.h |    1 +
 drivers/net/ethernet/broadcom/cnic_if.h   |    7 ++-
 3 files changed, 74 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index 567cb04..dd3a0a2 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -1361,7 +1361,7 @@ static int cnic_submit_kwqe_16(struct cnic_dev *dev, u32 cmd, u32 cid,
 	if (ret == 1)
 		return 0;
 
-	return -EBUSY;
+	return ret;
 }
 
 static void cnic_reply_bnx2x_kcqes(struct cnic_dev *dev, int ulp_type,
@@ -1849,7 +1849,7 @@ static int cnic_bnx2x_iscsi_ofld1(struct cnic_dev *dev, struct kwqe *wqes[],
 done:
 	cqes[0] = (struct kcqe *) &kcqe;
 	cnic_reply_bnx2x_kcqes(dev, CNIC_ULP_ISCSI, cqes, 1);
-	return ret;
+	return 0;
 }
 
 
@@ -1947,7 +1947,7 @@ destroy_reply:
 	cqes[0] = (struct kcqe *) &kcqe;
 	cnic_reply_bnx2x_kcqes(dev, CNIC_ULP_ISCSI, cqes, 1);
 
-	return ret;
+	return 0;
 }
 
 static void cnic_init_storm_conn_bufs(struct cnic_dev *dev,
@@ -2513,6 +2513,57 @@ static int cnic_bnx2x_fcoe_fw_destroy(struct cnic_dev *dev, struct kwqe *kwqe)
 	return ret;
 }
 
+static void cnic_bnx2x_kwqe_err(struct cnic_dev *dev, struct kwqe *kwqe)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	struct kcqe kcqe;
+	struct kcqe *cqes[1];
+	u32 cid;
+	u32 opcode = KWQE_OPCODE(kwqe->kwqe_op_flag);
+	u32 layer_code = kwqe->kwqe_op_flag & KWQE_LAYER_MASK;
+	int ulp_type;
+
+	cid = kwqe->kwqe_info0;
+	memset(&kcqe, 0, sizeof(kcqe));
+
+	if (layer_code == KWQE_FLAGS_LAYER_MASK_L5_ISCSI) {
+		ulp_type = CNIC_ULP_ISCSI;
+		if (opcode == ISCSI_KWQE_OPCODE_UPDATE_CONN)
+			cid = kwqe->kwqe_info1;
+
+		kcqe.kcqe_op_flag = (opcode + 0x10) << KCQE_FLAGS_OPCODE_SHIFT;
+		kcqe.kcqe_op_flag |= KCQE_FLAGS_LAYER_MASK_L5_ISCSI;
+		kcqe.kcqe_info1 = ISCSI_KCQE_COMPLETION_STATUS_NIC_ERROR;
+		kcqe.kcqe_info2 = cid;
+		cnic_get_l5_cid(cp, BNX2X_SW_CID(cid), &kcqe.kcqe_info0);
+
+	} else if (layer_code == KWQE_FLAGS_LAYER_MASK_L4) {
+		struct l4_kcq *l4kcqe = (struct l4_kcq *) &kcqe;
+		u32 kcqe_op;
+
+		ulp_type = CNIC_ULP_L4;
+		if (opcode == L4_KWQE_OPCODE_VALUE_CONNECT1)
+			kcqe_op = L4_KCQE_OPCODE_VALUE_CONNECT_COMPLETE;
+		else if (opcode == L4_KWQE_OPCODE_VALUE_RESET)
+			kcqe_op = L4_KCQE_OPCODE_VALUE_RESET_COMP;
+		else if (opcode == L4_KWQE_OPCODE_VALUE_CLOSE)
+			kcqe_op = L4_KCQE_OPCODE_VALUE_CLOSE_COMP;
+		else
+			return;
+
+		kcqe.kcqe_op_flag = (kcqe_op << KCQE_FLAGS_OPCODE_SHIFT) |
+				    KCQE_FLAGS_LAYER_MASK_L4;
+		l4kcqe->status = L4_KCQE_COMPLETION_STATUS_NIC_ERROR;
+		l4kcqe->cid = cid;
+		cnic_get_l5_cid(cp, BNX2X_SW_CID(cid), &l4kcqe->conn_id);
+	} else {
+		return;
+	}
+
+	cqes[0] = (struct kcqe *) &kcqe;
+	cnic_reply_bnx2x_kcqes(dev, ulp_type, cqes, 1);
+}
+
 static int cnic_submit_bnx2x_iscsi_kwqes(struct cnic_dev *dev,
 					 struct kwqe *wqes[], u32 num_wqes)
 {
@@ -2570,9 +2621,17 @@ static int cnic_submit_bnx2x_iscsi_kwqes(struct cnic_dev *dev,
 				   opcode);
 			break;
 		}
-		if (ret < 0)
+		if (ret < 0) {
 			netdev_err(dev->netdev, "KWQE(0x%x) failed\n",
 				   opcode);
+
+			/* Possibly bnx2x parity error, send completion
+			 * to ulp drivers with error code to speed up
+			 * cleanup and reset recovery.
+			 */
+			if (ret == -EIO || ret == -EAGAIN)
+				cnic_bnx2x_kwqe_err(dev, kwqe);
+		}
 		i += work;
 	}
 	return 0;
@@ -3849,6 +3908,9 @@ static void cnic_cm_process_kcqe(struct cnic_dev *dev, struct kcqe *kcqe)
 	case L4_KCQE_OPCODE_VALUE_RESET_COMP:
 	case L5CM_RAMROD_CMD_ID_SEARCHER_DELETE:
 	case L5CM_RAMROD_CMD_ID_TERMINATE_OFFLOAD:
+		if (l4kcqe->status == L4_KCQE_COMPLETION_STATUS_NIC_ERROR)
+			set_bit(SK_F_HW_ERR, &csk->flags);
+
 		cp->close_conn(csk, opcode);
 		break;
 
@@ -3976,7 +4038,9 @@ static void cnic_close_bnx2x_conn(struct cnic_sock *csk, u32 opcode)
 	case L4_KCQE_OPCODE_VALUE_CLOSE_COMP:
 	case L4_KCQE_OPCODE_VALUE_RESET_COMP:
 		if (cnic_ready_to_close(csk, opcode)) {
-			if (test_bit(SK_F_PG_OFFLD_COMPLETE, &csk->flags))
+			if (test_bit(SK_F_HW_ERR, &csk->flags))
+				close_complete = 1;
+			else if (test_bit(SK_F_PG_OFFLD_COMPLETE, &csk->flags))
 				cmd = L5CM_RAMROD_CMD_ID_SEARCHER_DELETE;
 			else
 				close_complete = 1;
diff --git a/drivers/net/ethernet/broadcom/cnic_defs.h b/drivers/net/ethernet/broadcom/cnic_defs.h
index 239de89..86936f6 100644
--- a/drivers/net/ethernet/broadcom/cnic_defs.h
+++ b/drivers/net/ethernet/broadcom/cnic_defs.h
@@ -85,6 +85,7 @@
 
 /* KCQ (kernel completion queue) completion status */
 #define L4_KCQE_COMPLETION_STATUS_SUCCESS           (0)
+#define L4_KCQE_COMPLETION_STATUS_NIC_ERROR         (4)
 #define L4_KCQE_COMPLETION_STATUS_TIMEOUT           (0x93)
 
 #define L4_KCQE_COMPLETION_STATUS_CTX_ALLOC_FAIL    (0x83)
diff --git a/drivers/net/ethernet/broadcom/cnic_if.h b/drivers/net/ethernet/broadcom/cnic_if.h
index d1f6456..1517763 100644
--- a/drivers/net/ethernet/broadcom/cnic_if.h
+++ b/drivers/net/ethernet/broadcom/cnic_if.h
@@ -1,6 +1,6 @@
 /* cnic_if.h: Broadcom CNIC core network driver.
  *
- * Copyright (c) 2006-2011 Broadcom Corporation
+ * Copyright (c) 2006-2012 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -12,8 +12,8 @@
 #ifndef CNIC_IF_H
 #define CNIC_IF_H
 
-#define CNIC_MODULE_VERSION	"2.5.7"
-#define CNIC_MODULE_RELDATE	"July 20, 2011"
+#define CNIC_MODULE_VERSION	"2.5.8"
+#define CNIC_MODULE_RELDATE	"Jan 3, 2012"
 
 #define CNIC_ULP_RDMA		0
 #define CNIC_ULP_ISCSI		1
@@ -261,6 +261,7 @@ struct cnic_sock {
 #define SK_F_CONNECT_START	4
 #define SK_F_IPV6		5
 #define SK_F_CLOSING		7
+#define SK_F_HW_ERR		8
 
 	atomic_t ref_count;
 	u32 state;
-- 
1.7.1
