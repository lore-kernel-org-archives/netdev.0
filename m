From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2/3 net-next] cnic: Add timeout for ramrod replies.
Date: Fri, 26 Aug 2011 12:45:40 -0700
Message-ID: <1314387941-2126-2-git-send-email-mchan@broadcom.com>
References: <1314387941-2126-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2131 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755031Ab1HZUgp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Aug 2011 16:36:45 -0400
In-Reply-To: <1314387941-2126-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the bnx2x device has encountered parity errors, the chip will not DMA
any replies.  Using wait_event_timeout() will allow us to make forward
progress and let bnx2x reset the chip.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Bhanu Prakash Gollapudi <bprakash@broadcom.com>
---
 drivers/net/ethernet/broadcom/cnic.c      |   17 ++++++++++-------
 drivers/net/ethernet/broadcom/cnic.h      |    2 ++
 drivers/net/ethernet/broadcom/cnic_defs.h |    1 +
 3 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index 73060f4..6f10c69 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -1875,12 +1875,12 @@ static int cnic_bnx2x_destroy_ramrod(struct cnic_dev *dev, u32 l5_cid)
 				  hw_cid, NONE_CONNECTION_TYPE, &l5_data);
 
 	if (ret == 0) {
-		wait_event(ctx->waitq, ctx->wait_cond);
+		wait_event_timeout(ctx->waitq, ctx->wait_cond, CNIC_RAMROD_TMO);
 		if (unlikely(test_bit(CTX_FL_CID_ERROR, &ctx->ctx_flags)))
 			return -EBUSY;
 	}
 
-	return ret;
+	return 0;
 }
 
 static int cnic_bnx2x_iscsi_destroy(struct cnic_dev *dev, struct kwqe *kwqe)
@@ -2428,17 +2428,20 @@ static int cnic_bnx2x_fcoe_destroy(struct cnic_dev *dev, struct kwqe *kwqe)
 	init_waitqueue_head(&ctx->waitq);
 	ctx->wait_cond = 0;
 
+	memset(&kcqe, 0, sizeof(kcqe));
+	kcqe.completion_status = FCOE_KCQE_COMPLETION_STATUS_ERROR;
 	memset(&l5_data, 0, sizeof(l5_data));
 	ret = cnic_submit_kwqe_16(dev, FCOE_RAMROD_CMD_ID_TERMINATE_CONN, cid,
 				  FCOE_CONNECTION_TYPE, &l5_data);
 	if (ret == 0) {
-		wait_event(ctx->waitq, ctx->wait_cond);
-		set_bit(CTX_FL_DELETE_WAIT, &ctx->ctx_flags);
-		queue_delayed_work(cnic_wq, &cp->delete_task,
-				   msecs_to_jiffies(2000));
+		wait_event_timeout(ctx->waitq, ctx->wait_cond, CNIC_RAMROD_TMO);
+		if (ctx->wait_cond)
+			kcqe.completion_status = 0;
 	}
 
-	memset(&kcqe, 0, sizeof(kcqe));
+	set_bit(CTX_FL_DELETE_WAIT, &ctx->ctx_flags);
+	queue_delayed_work(cnic_wq, &cp->delete_task, msecs_to_jiffies(2000));
+
 	kcqe.op_code = FCOE_KCQE_OPCODE_DESTROY_CONN;
 	kcqe.fcoe_conn_id = req->conn_id;
 	kcqe.fcoe_conn_context_id = cid;
diff --git a/drivers/net/ethernet/broadcom/cnic.h b/drivers/net/ethernet/broadcom/cnic.h
index 15b1c09..3032809 100644
--- a/drivers/net/ethernet/broadcom/cnic.h
+++ b/drivers/net/ethernet/broadcom/cnic.h
@@ -474,5 +474,7 @@ struct bnx2x_bd_chain_next {
 	  MAX_STAT_COUNTER_ID_E1))
 #endif
 
+#define CNIC_RAMROD_TMO			(HZ / 4)
+
 #endif
 
diff --git a/drivers/net/ethernet/broadcom/cnic_defs.h b/drivers/net/ethernet/broadcom/cnic_defs.h
index e47d210..239de89 100644
--- a/drivers/net/ethernet/broadcom/cnic_defs.h
+++ b/drivers/net/ethernet/broadcom/cnic_defs.h
@@ -67,6 +67,7 @@
 #define FCOE_KWQE_OPCODE_DESTROY		(10)
 #define FCOE_KWQE_OPCODE_STAT			(11)
 
+#define FCOE_KCQE_COMPLETION_STATUS_ERROR	(0x1)
 #define FCOE_KCQE_COMPLETION_STATUS_CTX_ALLOC_FAILURE	(0x3)
 
 /* KCQ (kernel completion queue) response op codes */
-- 
1.7.1
