From: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 11/12] qed: Add iWARP protocol support in context allocation
Date: Sun, 2 Jul 2017 10:29:31 +0300
Message-ID: <1498980572-29519-12-git-send-email-Michal.Kalderon@cavium.com>
References: <1498980572-29519-1-git-send-email-Michal.Kalderon@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        Ariel Elior <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
To: <michal.kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>, <ram.amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        <yuval.mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>, <ariel.elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1498980572-29519-1-git-send-email-Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

When computing how much memory is required for the different hw clients
iWARP protocol should be taken into account

Signed-off-by: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Ariel Elior <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
---
 drivers/net/ethernet/qlogic/qed/qed_cxt.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_cxt.c b/drivers/net/ethernet/qlogic/qed/qed_cxt.c
index 38716f7..af106be 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_cxt.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_cxt.c
@@ -246,14 +246,16 @@ struct qed_cxt_mngr {
 static bool src_proto(enum protocol_type type)
 {
 	return type == PROTOCOLID_ISCSI ||
-	       type == PROTOCOLID_FCOE;
+	       type == PROTOCOLID_FCOE ||
+	       type == PROTOCOLID_IWARP;
 }
 
 static bool tm_cid_proto(enum protocol_type type)
 {
 	return type == PROTOCOLID_ISCSI ||
 	       type == PROTOCOLID_FCOE ||
-	       type == PROTOCOLID_ROCE;
+	       type == PROTOCOLID_ROCE ||
+	       type == PROTOCOLID_IWARP;
 }
 
 static bool tm_tid_proto(enum protocol_type type)
@@ -2068,6 +2070,11 @@ static void qed_rdma_set_pf_params(struct qed_hwfn *p_hwfn,
 	num_srqs = min_t(u32, 32 * 1024, p_params->num_srqs);
 
 	switch (p_hwfn->hw_info.personality) {
+	case QED_PCI_ETH_IWARP:
+		/* Each QP requires one connection */
+		num_cons = min_t(u32, IWARP_MAX_QPS, p_params->num_qps);
+		proto = PROTOCOLID_IWARP;
+		break;
 	case QED_PCI_ETH_ROCE:
 		num_qps = min_t(u32, ROCE_MAX_QPS, p_params->num_qps);
 		num_cons = num_qps * 2;	/* each QP requires two connections */
@@ -2103,6 +2110,8 @@ int qed_cxt_set_pf_params(struct qed_hwfn *p_hwfn, u32 rdma_tasks)
 	qed_cxt_set_proto_cid_count(p_hwfn, PROTOCOLID_CORE, core_cids, 0);
 
 	switch (p_hwfn->hw_info.personality) {
+	case QED_PCI_ETH_RDMA:
+	case QED_PCI_ETH_IWARP:
 	case QED_PCI_ETH_ROCE:
 	{
 			qed_rdma_set_pf_params(p_hwfn,
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
