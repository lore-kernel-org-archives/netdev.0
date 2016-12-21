From: Selvin Xavier <selvin.xavier@broadcom.com>
Subject: [PATCH for bnxt_re V4 20/21] RDMA/bnxt_re: Add QP event handling
Date: Wed, 21 Dec 2016 03:42:09 -0800
Message-ID: <1482320530-5344-21-git-send-email-selvin.xavier@broadcom.com>
References: <1482320530-5344-1-git-send-email-selvin.xavier@broadcom.com>
Cc: netdev@vger.kernel.org, michael.chan@broadcom.com,
        Selvin Xavier <selvin.xavier@broadcom.com>,
        Eddie Wai <eddie.wai@broadcom.com>,
        Devesh Sharma <devesh.sharma@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
To: dledford@redhat.com, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:33607 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933162AbcLULoR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 06:44:17 -0500
Received: by mail-wm0-f54.google.com with SMTP id g23so2394428wme.0
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2016 03:44:16 -0800 (PST)
In-Reply-To: <1482320530-5344-1-git-send-email-selvin.xavier@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implements callback handler for processing Async events related to a QP.
This patch also implements the control path command completion handling.

v3: Removes unwanted braces

Signed-off-by: Eddie Wai <eddie.wai@broadcom.com>
Signed-off-by: Devesh Sharma <devesh.sharma@broadcom.com>
Signed-off-by: Somnath Kotur <somnath.kotur@broadcom.com>
Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Signed-off-by: Selvin Xavier <selvin.xavier@broadcom.com>
---
 drivers/infiniband/hw/bnxt_re/qplib_rcfw.c | 47 ++++++++++++++++++++++++++++++
 1 file changed, 47 insertions(+)

diff --git a/drivers/infiniband/hw/bnxt_re/qplib_rcfw.c b/drivers/infiniband/hw/bnxt_re/qplib_rcfw.c
index 9144b5a..a000397 100644
--- a/drivers/infiniband/hw/bnxt_re/qplib_rcfw.c
+++ b/drivers/infiniband/hw/bnxt_re/qplib_rcfw.c
@@ -257,6 +257,44 @@ static int bnxt_qplib_process_func_event(struct bnxt_qplib_rcfw *rcfw,
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
+	return 0;
+}
+
 /* SP - CREQ Completion handlers */
 static void bnxt_qplib_service_creq(unsigned long data)
 {
@@ -280,6 +318,15 @@ static void bnxt_qplib_service_creq(unsigned long data)
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
