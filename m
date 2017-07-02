From: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 04/12] qed: Add iWARP support in ll2 connections
Date: Sun, 2 Jul 2017 10:29:24 +0300
Message-ID: <1498980572-29519-5-git-send-email-Michal.Kalderon@cavium.com>
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

Add a new connection type for iWARP ll2 connections for setting
correct ll2 filters and connection type to FW.

Signed-off-by: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Ariel Elior <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
---
 drivers/net/ethernet/qlogic/qed/qed_ll2.c | 13 +++++++++++--
 include/linux/qed/qed_ll2_if.h            |  1 +
 2 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_ll2.c b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
index e235fb2..c06ad4f 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_ll2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
@@ -896,7 +896,8 @@ static int qed_sp_ll2_rx_queue_start(struct qed_hwfn *p_hwfn,
 	p_ramrod->main_func_queue = (conn_type == QED_LL2_TYPE_OOO) ? 0 : 1;
 
 	if ((IS_MF_DEFAULT(p_hwfn) || IS_MF_SI(p_hwfn)) &&
-	    p_ramrod->main_func_queue && (conn_type != QED_LL2_TYPE_ROCE)) {
+	    p_ramrod->main_func_queue && (conn_type != QED_LL2_TYPE_ROCE) &&
+	    (conn_type != QED_LL2_TYPE_IWARP)) {
 		p_ramrod->mf_si_bcast_accept_all = 1;
 		p_ramrod->mf_si_mcast_accept_all = 1;
 	} else {
@@ -972,12 +973,20 @@ static int qed_sp_ll2_tx_queue_start(struct qed_hwfn *p_hwfn,
 		p_ramrod->conn_type = PROTOCOLID_FCOE;
 		break;
 	case QED_LL2_TYPE_ISCSI:
-	case QED_LL2_TYPE_OOO:
 		p_ramrod->conn_type = PROTOCOLID_ISCSI;
 		break;
 	case QED_LL2_TYPE_ROCE:
 		p_ramrod->conn_type = PROTOCOLID_ROCE;
 		break;
+	case QED_LL2_TYPE_IWARP:
+		p_ramrod->conn_type = PROTOCOLID_IWARP;
+		break;
+	case QED_LL2_TYPE_OOO:
+		if (p_hwfn->hw_info.personality == QED_PCI_ISCSI)
+			p_ramrod->conn_type = PROTOCOLID_ISCSI;
+		else
+			p_ramrod->conn_type = PROTOCOLID_IWARP;
+		break;
 	default:
 		p_ramrod->conn_type = PROTOCOLID_ETH;
 		DP_NOTICE(p_hwfn, "Unknown connection type: %d\n", conn_type);
diff --git a/include/linux/qed/qed_ll2_if.h b/include/linux/qed/qed_ll2_if.h
index c9c56bc..dd7a3b8 100644
--- a/include/linux/qed/qed_ll2_if.h
+++ b/include/linux/qed/qed_ll2_if.h
@@ -50,6 +50,7 @@ enum qed_ll2_conn_type {
 	QED_LL2_TYPE_OOO,
 	QED_LL2_TYPE_RESERVED2,
 	QED_LL2_TYPE_ROCE,
+	QED_LL2_TYPE_IWARP,
 	QED_LL2_TYPE_RESERVED3,
 	MAX_QED_LL2_RX_CONN_TYPE
 };
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
