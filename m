From: Selvin Xavier <selvin.xavier@broadcom.com>
Subject: [PATCH V5 for-next 17/21] RDMA/bnxt_re: Handling dispatching of events to IB stack
Date: Fri, 10 Feb 2017 03:19:49 -0800
Message-ID: <1486725593-9872-18-git-send-email-selvin.xavier@broadcom.com>
References: <1486725593-9872-1-git-send-email-selvin.xavier@broadcom.com>
Cc: netdev@vger.kernel.org, Selvin Xavier <selvin.xavier@broadcom.com>,
        Eddie Wai <eddie.wai@broadcom.com>,
        Devesh Sharma <devesh.sharma@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
To: dledford@redhat.com, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:35317 "EHLO
        mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752191AbdBJLXE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 06:23:04 -0500
Received: by mail-qk0-f181.google.com with SMTP id u25so35228166qki.2
        for <netdev@vger.kernel.org>; Fri, 10 Feb 2017 03:21:17 -0800 (PST)
In-Reply-To: <1486725593-9872-1-git-send-email-selvin.xavier@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements events dispatching to the IB stack
based on NETDEV events received.

v2: Removed cleanup of the resources during driver unload since
    we are calling unregister_netdevice_notifier first in the exit.

v3: Fixes cocci warnings and some sparse warnings
v5: Removes qp_wait parameter from bnxt_re_dev_stop() as it was never used

Signed-off-by: Eddie Wai <eddie.wai@broadcom.com>
Signed-off-by: Devesh Sharma <devesh.sharma@broadcom.com>
Signed-off-by: Somnath Kotur <somnath.kotur@broadcom.com>
Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Signed-off-by: Selvin Xavier <selvin.xavier@broadcom.com>
---
 drivers/infiniband/hw/bnxt_re/main.c | 59 ++++++++++++++++++++++++++++++++++++
 1 file changed, 59 insertions(+)

diff --git a/drivers/infiniband/hw/bnxt_re/main.c b/drivers/infiniband/hw/bnxt_re/main.c
index 95dbbbe..c84691a 100644
--- a/drivers/infiniband/hw/bnxt_re/main.c
+++ b/drivers/infiniband/hw/bnxt_re/main.c
@@ -712,6 +712,51 @@ static int bnxt_re_alloc_res(struct bnxt_re_dev *rdev)
 	return rc;
 }
 
+static void bnxt_re_dispatch_event(struct ib_device *ibdev, struct ib_qp *qp,
+				   u8 port_num, enum ib_event_type event)
+{
+	struct ib_event ib_event;
+
+	ib_event.device = ibdev;
+	if (qp)
+		ib_event.element.qp = qp;
+	else
+		ib_event.element.port_num = port_num;
+	ib_event.event = event;
+	ib_dispatch_event(&ib_event);
+}
+
+static bool bnxt_re_is_qp1_or_shadow_qp(struct bnxt_re_dev *rdev,
+					struct bnxt_re_qp *qp)
+{
+	return (qp->ib_qp.qp_type == IB_QPT_GSI) || (qp == rdev->qp1_sqp);
+}
+
+static void bnxt_re_dev_stop(struct bnxt_re_dev *rdev)
+{
+	int mask = IB_QP_STATE;
+	struct ib_qp_attr qp_attr;
+	struct bnxt_re_qp *qp;
+
+	qp_attr.qp_state = IB_QPS_ERR;
+	mutex_lock(&rdev->qp_lock);
+	list_for_each_entry(qp, &rdev->qp_list, list) {
+		/* Modify the state of all QPs except QP1/Shadow QP */
+		if (!bnxt_re_is_qp1_or_shadow_qp(rdev, qp)) {
+			if (qp->qplib_qp.state !=
+			    CMDQ_MODIFY_QP_NEW_STATE_RESET &&
+			    qp->qplib_qp.state !=
+			    CMDQ_MODIFY_QP_NEW_STATE_ERR) {
+				bnxt_re_dispatch_event(&rdev->ibdev, &qp->ib_qp,
+						       1, IB_EVENT_QP_FATAL);
+				bnxt_re_modify_qp(&qp->ib_qp, &qp_attr, mask,
+						  NULL);
+			}
+		}
+	}
+	mutex_unlock(&rdev->qp_lock);
+}
+
 static void bnxt_re_ib_unreg(struct bnxt_re_dev *rdev, bool lock_wait)
 {
 	int i, rc;
@@ -871,6 +916,9 @@ static int bnxt_re_ib_reg(struct bnxt_re_dev *rdev)
 		}
 	}
 	set_bit(BNXT_RE_FLAG_IBDEV_REGISTERED, &rdev->flags);
+	bnxt_re_dispatch_event(&rdev->ibdev, NULL, 1, IB_EVENT_PORT_ACTIVE);
+	bnxt_re_dispatch_event(&rdev->ibdev, NULL, 1, IB_EVENT_GID_CHANGE);
+
 	return 0;
 free_sctx:
 	bnxt_re_net_stats_ctx_free(rdev, rdev->qplib_ctx.stats.fw_id, true);
@@ -950,8 +998,19 @@ static void bnxt_re_task(struct work_struct *work)
 				"Failed to register with IB: %#x", rc);
 		break;
 	case NETDEV_UP:
+		bnxt_re_dispatch_event(&rdev->ibdev, NULL, 1,
+				       IB_EVENT_PORT_ACTIVE);
+		break;
 	case NETDEV_DOWN:
+		bnxt_re_dev_stop(rdev);
+		break;
 	case NETDEV_CHANGE:
+		if (!netif_carrier_ok(rdev->netdev))
+			bnxt_re_dev_stop(rdev);
+		else if (netif_carrier_ok(rdev->netdev))
+			bnxt_re_dispatch_event(&rdev->ibdev, NULL, 1,
+					       IB_EVENT_PORT_ACTIVE);
+		break;
 	default:
 		break;
 	}
-- 
2.5.5
