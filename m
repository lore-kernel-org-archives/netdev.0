From: Selvin Xavier <selvin.xavier@broadcom.com>
Subject: [PATCH V2  21/22] bnxt_re: Add QP event handling
Date: Thu,  8 Dec 2016 22:48:15 -0800
Message-ID: <1481266096-23331-22-git-send-email-selvin.xavier@broadcom.com>
References: <1481266096-23331-1-git-send-email-selvin.xavier@broadcom.com>
Cc: netdev@vger.kernel.org, Selvin Xavier <selvin.xavier@broadcom.com>,
        Eddie Wai <eddie.wai@broadcom.com>,
        Devesh Sharma <devesh.sharma@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
To: dledford@redhat.com, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lpdvsmtp01.broadcom.com ([192.19.211.62]:45715 "EHLO
        relay.smtp.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932392AbcLIGsj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2016 01:48:39 -0500
In-Reply-To: <1481266096-23331-1-git-send-email-selvin.xavier@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implements callback handler for processing affiliated Async events of a QP.
This patch also implements the control path command completion handling.

Signed-off-by: Eddie Wai <eddie.wai@broadcom.com>
Signed-off-by: Devesh Sharma <devesh.sharma@broadcom.com>
Signed-off-by: Somnath Kotur <somnath.kotur@broadcom.com>
Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Signed-off-by: Selvin Xavier <selvin.xavier@broadcom.com>
---
 drivers/infiniband/hw/bnxtre/bnxt_qplib_rcfw.c | 49 ++++++++++++++++++++++++++
 1 file changed, 49 insertions(+)

diff --git a/drivers/infiniband/hw/bnxtre/bnxt_qplib_rcfw.c b/drivers/infiniband/hw/bnxtre/bnxt_qplib_rcfw.c
index 5b71acd..3e6bb3f 100644
--- a/drivers/infiniband/hw/bnxtre/bnxt_qplib_rcfw.c
+++ b/drivers/infiniband/hw/bnxtre/bnxt_qplib_rcfw.c
@@ -246,6 +246,46 @@ static int bnxt_qplib_process_func_event(struct bnxt_qplib_rcfw *rcfw,
 	return 0;
 }
 
+static int bnxt_qplib_process_qp_event(struct bnxt_qplib_rcfw *rcfw,
+				       struct creq_qp_event *qp_event)
+{
+	struct bnxt_qplib_crsq *crsq = &rcfw->crsq;
+	struct bnxt_qplib_hwq *cmdq = &rcfw->cmdq;
+	struct bnxt_qplib_crsqe *crsqe;
+	u16 cbit, cookie, blocked = 0;
+	unsigned long flags;
+	u32 sw_cons;
+
+	switch (qp_event->event) {
+	case CREQ_QP_EVENT_EVENT_QP_ERROR_NOTIFICATION:
+		break;
+	default:
+	{
+		/* Command Response */
+		spin_lock_irqsave(&cmdq->lock, flags);
+		sw_cons = HWQ_CMP(crsq->cons, crsq);
+		crsqe = &crsq->crsq[sw_cons];
+		crsq->cons++;
+		memcpy(&crsqe->qp_event, qp_event, sizeof(crsqe->qp_event));
+
+		cookie = le16_to_cpu(crsqe->qp_event.cookie);
+		blocked = cookie & RCFW_CMD_IS_BLOCKING;
+		cookie &= RCFW_MAX_COOKIE_VALUE;
+		cbit = cookie % RCFW_MAX_OUTSTANDING_CMD;
+		if (!test_and_clear_bit(cbit, rcfw->cmdq_bitmap))
+			dev_warn(&rcfw->pdev->dev,
+				 "QPLIB: CMD bit %d was not requested", cbit);
+
+		cmdq->cons += crsqe->req_size;
+		spin_unlock_irqrestore(&cmdq->lock, flags);
+		if (!blocked)
+			wake_up(&rcfw->waitq);
+		break;
+	}
+	}
+	return 0;
+}
+
 /* SP - CREQ Completion handlers */
 static void bnxt_qplib_service_creq(unsigned long data)
 {
@@ -269,6 +309,15 @@ static void bnxt_qplib_service_creq(unsigned long data)
 		type = creqe->type & CREQ_BASE_TYPE_MASK;
 		switch (type) {
 		case CREQ_BASE_TYPE_QP_EVENT:
+			if (!bnxt_qplib_process_qp_event
+			    (rcfw, (struct creq_qp_event *)creqe))
+				rcfw->creq_qp_event_processed++;
+			else {
+				dev_warn(&rcfw->pdev->dev, "QPLIB: crsqe with");
+				dev_warn(&rcfw->pdev->dev,
+					 "QPLIB: type = 0x%x not handled",
+					 type);
+			}
 			break;
 		case CREQ_BASE_TYPE_FUNC_EVENT:
 			if (!bnxt_qplib_process_func_event
-- 
2.5.5
