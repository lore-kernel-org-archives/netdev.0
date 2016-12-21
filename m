From: Selvin Xavier <selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: [PATCH for bnxt_re V4 17/21] RDMA/bnxt_re: Handling dispatching of events to IB stack
Date: Wed, 21 Dec 2016 03:42:06 -0800
Message-ID: <1482320530-5344-18-git-send-email-selvin.xavier@broadcom.com>
References: <1482320530-5344-1-git-send-email-selvin.xavier@broadcom.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, michael.chan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
        Selvin Xavier <selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Eddie Wai <eddie.wai-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Devesh Sharma <devesh.sharma-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Somnath Kotur <somnath.kotur-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Sriharsha Basavapatna <sriharsha.basavapatna-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
To: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1482320530-5344-1-git-send-email-selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch implements events dispatching to the IB stack
based on NETDEV events received.

v2: Removed cleanup of the resources during driver unload since
    we are calling unregister_netdevice_notifier first in the exit.

v3: Fixes cocci warnings and some sparse warnings

Signed-off-by: Eddie Wai <eddie.wai-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Signed-off-by: Devesh Sharma <devesh.sharma-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Signed-off-by: Somnath Kotur <somnath.kotur-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Signed-off-by: Selvin Xavier <selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
---
 drivers/infiniband/hw/bnxt_re/main.c | 65 ++++++++++++++++++++++++++++++++++++
 1 file changed, 65 insertions(+)

diff --git a/drivers/infiniband/hw/bnxt_re/main.c b/drivers/infiniband/hw/bnxt_re/main.c
index ab0b35a..bd13414 100644
--- a/drivers/infiniband/hw/bnxt_re/main.c
+++ b/drivers/infiniband/hw/bnxt_re/main.c
@@ -729,6 +729,60 @@ static int bnxt_re_alloc_res(struct bnxt_re_dev *rdev)
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
@@ -888,6 +942,9 @@ static int bnxt_re_ib_reg(struct bnxt_re_dev *rdev)
 		}
 	}
 	set_bit(BNXT_RE_FLAG_IBDEV_REGISTERED, &rdev->flags);
+	bnxt_re_dispatch_event(&rdev->ibdev, NULL, 1, IB_EVENT_PORT_ACTIVE);
+	bnxt_re_dispatch_event(&rdev->ibdev, NULL, 1, IB_EVENT_GID_CHANGE);
+
 	return 0;
 free_sctx:
 	bnxt_re_net_stats_ctx_free(rdev, rdev->qplib_ctx.stats.fw_id, true);
@@ -967,10 +1024,18 @@ static void bnxt_re_task(struct work_struct *work)
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

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
