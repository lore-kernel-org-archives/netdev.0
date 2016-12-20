From: Selvin Xavier <selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: [PATCH for bnxt_re V3 20/21] bnxt_re: Add QP event handling
Date: Tue, 20 Dec 2016 01:13:30 -0800
Message-ID: <1482225211-22423-21-git-send-email-selvin.xavier@broadcom.com>
References: <1482225211-22423-1-git-send-email-selvin.xavier@broadcom.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, michael.chan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
        Selvin Xavier <selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Eddie Wai <eddie.wai-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Devesh Sharma <devesh.sharma-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Somnath Kotur <somnath.kotur-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Sriharsha Basavapatna <sriharsha.basavapatna-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
To: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1482225211-22423-1-git-send-email-selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Implements callback handler for processing Async events related to a QP.
This patch also implements the control path command completion handling.

v3: Removes unwanted braces

Signed-off-by: Eddie Wai <eddie.wai-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Signed-off-by: Devesh Sharma <devesh.sharma-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Signed-off-by: Somnath Kotur <somnath.kotur-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Signed-off-by: Selvin Xavier <selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
---
 drivers/infiniband/hw/bnxtre/bnxt_qplib_rcfw.c | 47 ++++++++++++++++++++++++++
 1 file changed, 47 insertions(+)

diff --git a/drivers/infiniband/hw/bnxtre/bnxt_qplib_rcfw.c b/drivers/infiniband/hw/bnxtre/bnxt_qplib_rcfw.c
index 488c26f..761d32a 100644
--- a/drivers/infiniband/hw/bnxtre/bnxt_qplib_rcfw.c
+++ b/drivers/infiniband/hw/bnxtre/bnxt_qplib_rcfw.c
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

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
