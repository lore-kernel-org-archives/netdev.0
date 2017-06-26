From: Michal Kalderon <Michal.Kalderon@cavium.com>
Subject: [RFC 09/19] qed: iWARP implement disconnect flows
Date: Mon, 26 Jun 2017 21:06:59 +0300
Message-ID: <1498500429-22557-10-git-send-email-Michal.Kalderon@cavium.com>
References: <1498500429-22557-1-git-send-email-Michal.Kalderon@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Michal Kalderon <Michal.Kalderon@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>,
        Ariel Elior <Ariel.Elior@cavium.com>
To: <michal.kalderon@cavium.com>, <ram.amrani@cavium.com>,
        <yuval.mintz@cavium.com>, <ariel.elior@cavium.com>,
        <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <linux-rdma@vger.kernel.org>, <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0074.outbound.protection.outlook.com ([104.47.32.74]:9120
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751386AbdFZSMO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 26 Jun 2017 14:12:14 -0400
In-Reply-To: <1498500429-22557-1-git-send-email-Michal.Kalderon@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch takes care of active/passive disconnect flows.
Disconnect flows can be initiated remotely, in which case a async event
will arrive from peer and indicated to qedr driver. These
are referred to as exceptions. When a QP is destroyed, it needs to check
that it's associated ep has been closed.

Signed-off-by: Michal Kalderon <Michal.Kalderon@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
Signed-off-by: Ariel Elior <Ariel.Elior@cavium.com>

---
 drivers/net/ethernet/qlogic/qed/qed_iwarp.c | 90 ++++++++++++++++++++++++++++-
 include/linux/qed/qed_rdma_if.h             |  2 +
 2 files changed, 91 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_iwarp.c b/drivers/net/ethernet/qlogic/qed/qed_iwarp.c
index a5da9fc..84bcda3 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_iwarp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_iwarp.c
@@ -496,6 +496,8 @@ static void qed_iwarp_destroy_ep(struct qed_hwfn *p_hwfn,
 
 int qed_iwarp_destroy_qp(struct qed_hwfn *p_hwfn, struct qed_rdma_qp *qp)
 {
+	struct qed_iwarp_ep *ep = qp->ep;
+	int wait_count = 0;
 	int rc = 0;
 
 	if (qp->iwarp_state != QED_IWARP_QP_STATE_ERROR) {
@@ -505,6 +507,18 @@ int qed_iwarp_destroy_qp(struct qed_hwfn *p_hwfn, struct qed_rdma_qp *qp)
 			return rc;
 	}
 
+	/* Make sure ep is closed before returning and freeing memory. */
+	if (ep) {
+		while (ep->state != QED_IWARP_EP_CLOSED && wait_count++ < 200)
+			msleep(100);
+
+		if (ep->state != QED_IWARP_EP_CLOSED)
+			DP_NOTICE(p_hwfn, "ep state close timeout state=%x\n",
+				  ep->state);
+
+		qed_iwarp_destroy_ep(p_hwfn, ep, false);
+	}
+
 	rc = qed_iwarp_fw_destroy(p_hwfn, qp);
 
 	if (qp->shared_queue)
@@ -1956,6 +1970,61 @@ int qed_iwarp_stop(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
 	return qed_iwarp_ll2_stop(p_hwfn, p_ptt);
 }
 
+void qed_iwarp_qp_in_error(struct qed_hwfn *p_hwfn,
+			   struct qed_iwarp_ep *ep, u8 fw_return_code)
+{
+	struct qed_iwarp_cm_event_params params;
+
+	qed_iwarp_modify_qp(p_hwfn, ep->qp, QED_IWARP_QP_STATE_ERROR, true);
+
+	params.event = QED_IWARP_EVENT_CLOSE;
+	params.ep_context = ep;
+	params.cm_info = &ep->cm_info;
+	params.status = (fw_return_code == IWARP_QP_IN_ERROR_GOOD_CLOSE) ?
+			 0 : -ECONNRESET;
+
+	ep->state = QED_IWARP_EP_CLOSED;
+	spin_lock_bh(&p_hwfn->p_rdma_info->iwarp.iw_lock);
+	list_del(&ep->list_entry);
+	spin_unlock_bh(&p_hwfn->p_rdma_info->iwarp.iw_lock);
+
+	ep->event_cb(ep->cb_context, &params);
+}
+
+void qed_iwarp_exception_received(struct qed_hwfn *p_hwfn,
+				  struct qed_iwarp_ep *ep, int fw_ret_code)
+{
+	struct qed_iwarp_cm_event_params params;
+	bool event_cb = false;
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "EP(0x%x) fw_ret_code=%d\n",
+		   ep->cid, fw_ret_code);
+
+	switch (fw_ret_code) {
+	case IWARP_EXCEPTION_DETECTED_LLP_CLOSED:
+		params.status = 0;
+		params.event = QED_IWARP_EVENT_DISCONNECT;
+		event_cb = true;
+		break;
+	case IWARP_EXCEPTION_DETECTED_LLP_RESET:
+		params.status = -ECONNRESET;
+		params.event = QED_IWARP_EVENT_DISCONNECT;
+		event_cb = true;
+		break;
+	default:
+		DP_VERBOSE(p_hwfn, QED_MSG_RDMA,
+			   "Unhandled exception received...fw_ret_code=%d\n",
+			   fw_ret_code);
+		break;
+	}
+
+	if (event_cb) {
+		params.ep_context = ep;
+		params.cm_info = &ep->cm_info;
+		ep->event_cb(ep->cb_context, &params);
+	}
+}
+
 void
 qed_iwarp_connect_complete(struct qed_hwfn *p_hwfn,
 			   struct qed_iwarp_ep *ep, u8 fw_return_code)
@@ -2009,8 +2078,27 @@ static int qed_iwarp_async_event(struct qed_hwfn *p_hwfn,
 			   ep->tcp_cid, fw_return_code);
 		qed_iwarp_connect_complete(p_hwfn, ep, fw_return_code);
 		break;
-		/* Async event for active side only */
+	case IWARP_EVENT_TYPE_ASYNC_EXCEPTION_DETECTED:
+		if (!qed_iwarp_check_ep_ok(p_hwfn, ep))
+			return -EINVAL;
+		DP_VERBOSE(p_hwfn,
+			   QED_MSG_RDMA,
+			   "QP(0x%x) IWARP_EVENT_TYPE_ASYNC_EXCEPTION_DETECTED fw_ret_code=%d\n",
+			   ep->cid, fw_return_code);
+		qed_iwarp_exception_received(p_hwfn, ep, fw_return_code);
+		break;
+	case IWARP_EVENT_TYPE_ASYNC_QP_IN_ERROR_STATE:
+		/* Async completion for Close Connection ramrod */
+		if (!qed_iwarp_check_ep_ok(p_hwfn, ep))
+			return -EINVAL;
+		DP_VERBOSE(p_hwfn,
+			   QED_MSG_RDMA,
+			   "QP(0x%x) IWARP_EVENT_TYPE_ASYNC_QP_IN_ERROR_STATE fw_ret_code=%d\n",
+			   ep->cid, fw_return_code);
+		qed_iwarp_qp_in_error(p_hwfn, ep, fw_return_code);
+		break;
 	case IWARP_EVENT_TYPE_ASYNC_ENHANCED_MPA_REPLY_ARRIVED:
+		/* Async event for active side only */
 		if (!qed_iwarp_check_ep_ok(p_hwfn, ep))
 			return -EINVAL;
 		DP_VERBOSE(p_hwfn,
diff --git a/include/linux/qed/qed_rdma_if.h b/include/linux/qed/qed_rdma_if.h
index e9514a6..01966c3 100644
--- a/include/linux/qed/qed_rdma_if.h
+++ b/include/linux/qed/qed_rdma_if.h
@@ -474,6 +474,8 @@ enum qed_iwarp_event_type {
 	QED_IWARP_EVENT_MPA_REQUEST,	  /* Passive side request received */
 	QED_IWARP_EVENT_PASSIVE_COMPLETE, /* ack on mpa response */
 	QED_IWARP_EVENT_ACTIVE_COMPLETE,  /* Active side reply received */
+	QED_IWARP_EVENT_DISCONNECT,
+	QED_IWARP_EVENT_CLOSE,
 	QED_IWARP_EVENT_ACTIVE_MPA_REPLY,
 };
 
-- 
1.8.3.1
