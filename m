From: Selvin Xavier <selvin.xavier@broadcom.com>
Subject: [PATCH V2  17/22] bnxt_re: Handling dispatching of events to IB stack
Date: Thu,  8 Dec 2016 22:48:11 -0800
Message-ID: <1481266096-23331-18-git-send-email-selvin.xavier@broadcom.com>
References: <1481266096-23331-1-git-send-email-selvin.xavier@broadcom.com>
Cc: netdev@vger.kernel.org, Selvin Xavier <selvin.xavier@broadcom.com>,
        Eddie Wai <eddie.wai@broadcom.com>,
        Devesh Sharma <devesh.sharma@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
To: dledford@redhat.com, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lpdvsmtp01.broadcom.com ([192.19.211.62]:45706 "EHLO
        relay.smtp.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932209AbcLIGsh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2016 01:48:37 -0500
In-Reply-To: <1481266096-23331-1-git-send-email-selvin.xavier@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements handling dispatch of appropriate event to the IB stack
based on NETDEV events received.

v2: Removed cleanup of the resources during driver unload since we are calling
    unregister_netdevice_notifier first in the exit.

Signed-off-by: Eddie Wai <eddie.wai@broadcom.com>
Signed-off-by: Devesh Sharma <devesh.sharma@broadcom.com>
Signed-off-by: Somnath Kotur <somnath.kotur@broadcom.com>
Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Signed-off-by: Selvin Xavier <selvin.xavier@broadcom.com>
---
 drivers/infiniband/hw/bnxtre/bnxt_re_main.c | 64 +++++++++++++++++++++++++++++
 1 file changed, 64 insertions(+)

diff --git a/drivers/infiniband/hw/bnxtre/bnxt_re_main.c b/drivers/infiniband/hw/bnxtre/bnxt_re_main.c
index fd52e65..260dec1 100644
--- a/drivers/infiniband/hw/bnxtre/bnxt_re_main.c
+++ b/drivers/infiniband/hw/bnxtre/bnxt_re_main.c
@@ -720,6 +720,60 @@ static int bnxt_re_alloc_res(struct bnxt_re_dev *rdev)
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
+static void bnxt_re_dev_stop(struct bnxt_re_dev *rdev, bool qp_wait)
+{
+	int mask = IB_QP_STATE, qp_count, count = 1;
+	struct ib_qp_attr qp_attr;
+	struct bnxt_re_qp *qp;
+
+	qp_attr.qp_state = IB_QPS_ERR;
+	mutex_lock(&rdev->qp_lock);
+	list_for_each_entry(qp, &rdev->qp_list, list) {
+		/* Modify the state of all QPs except QP1/Shadow QP */
+		if (qp && !bnxt_re_is_qp1_or_shadow_qp(rdev, qp)) {
+			if (qp->qplib_qp.state !=
+			    CMDQ_MODIFY_QP_NEW_STATE_RESET ||
+			    qp->qplib_qp.state !=
+			    CMDQ_MODIFY_QP_NEW_STATE_ERR) {
+				bnxt_re_dispatch_event(&rdev->ibdev, &qp->ib_qp,
+						       1, IB_EVENT_QP_FATAL);
+				bnxt_re_modify_qp(&qp->ib_qp, &qp_attr, mask,
+						  NULL);
+			}
+		}
+	}
+
+	mutex_unlock(&rdev->qp_lock);
+	if (qp_wait) {
+		/* Give the application some time to clean up */
+		do {
+			qp_count = atomic_read(&rdev->qp_count);
+			msleep(100);
+		} while ((qp_count != atomic_read(&rdev->qp_count)) &&
+			  count--);
+	}
+}
+
 static void bnxt_re_ib_unreg(struct bnxt_re_dev *rdev, bool lock_wait)
 {
 	int i, rc;
@@ -878,6 +932,8 @@ static int bnxt_re_ib_reg(struct bnxt_re_dev *rdev)
 		}
 	}
 	set_bit(BNXT_RE_FLAG_IBDEV_REGISTERED, &rdev->flags);
+	bnxt_re_dispatch_event(&rdev->ibdev, NULL, 1, IB_EVENT_PORT_ACTIVE);
+	bnxt_re_dispatch_event(&rdev->ibdev, NULL, 1, IB_EVENT_GID_CHANGE);
 
 	return 0;
 free_sctx:
@@ -956,10 +1012,18 @@ static void bnxt_re_task(struct work_struct *work)
 				"Failed to register with IB: %#x", rc);
 			break;
 	case NETDEV_UP:
+		bnxt_re_dispatch_event(&rdev->ibdev, NULL, 1,
+				       IB_EVENT_PORT_ACTIVE);
 		break;
 	case NETDEV_DOWN:
+		bnxt_re_dev_stop(rdev, false);
 		break;
 	case NETDEV_CHANGE:
+		if (!netif_carrier_ok(rdev->netdev))
+			bnxt_re_dev_stop(rdev, false);
+		else if (netif_carrier_ok(rdev->netdev))
+			bnxt_re_dispatch_event(&rdev->ibdev, NULL, 1,
+					       IB_EVENT_PORT_ACTIVE);
 		break;
 	default:
 		break;
-- 
2.5.5
