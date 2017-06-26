From: Michal Kalderon <Michal.Kalderon@cavium.com>
Subject: [RFC 11/19] qed: Add iWARP protocol support in context allocation
Date: Mon, 26 Jun 2017 21:07:01 +0300
Message-ID: <1498500429-22557-12-git-send-email-Michal.Kalderon@cavium.com>
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
Received: from mail-by2nam03on0073.outbound.protection.outlook.com ([104.47.42.73]:28960
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751425AbdFZSNM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 26 Jun 2017 14:13:12 -0400
In-Reply-To: <1498500429-22557-1-git-send-email-Michal.Kalderon@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When computing how much memory is required for the different hw clients
iWARP protocol should be taken into account

Signed-off-by: Michal Kalderon <Michal.Kalderon@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
Signed-off-by: Ariel Elior <Ariel.Elior@cavium.com>

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
