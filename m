From: Michal Kalderon <Michal.Kalderon@cavium.com>
Subject: [PATCH net-next 1/4] qed: Add iWARP enablement support
Date: Tue, 19 Sep 2017 20:26:16 +0300
Message-ID: <1505841979-26365-2-git-send-email-Michal.Kalderon@cavium.com>
References: <1505841979-26365-1-git-send-email-Michal.Kalderon@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma@vger.kernel.org>, <dledford@redhat.com>,
        Michal Kalderon <Michal.Kalderon@cavium.com>,
        Ariel Elior <Ariel.Elior@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0086.outbound.protection.outlook.com ([104.47.34.86]:34250
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751284AbdISR1X (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 19 Sep 2017 13:27:23 -0400
In-Reply-To: <1505841979-26365-1-git-send-email-Michal.Kalderon@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is the last of the initial iWARP patch series. It
adds the possiblity to actually detect iWARP from the device and enable
it in the critical locations which basically make iWARP available.

It wasn't submitted until now as iWARP hadn't been accepted into
the rdma tree.

Signed-off-by: Michal Kalderon <Michal.Kalderon@cavium.com>
Signed-off-by: Ariel Elior <Ariel.Elior@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_cxt.c         |  6 ++++++
 drivers/net/ethernet/qlogic/qed/qed_mcp.c         | 10 +++++-----
 drivers/net/ethernet/qlogic/qed/qed_rdma.c        |  5 ++++-
 drivers/net/ethernet/qlogic/qed/qed_sp_commands.c |  1 +
 4 files changed, 16 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_cxt.c b/drivers/net/ethernet/qlogic/qed/qed_cxt.c
index af106be..afd07ad 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_cxt.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_cxt.c
@@ -2069,6 +2069,12 @@ static void qed_rdma_set_pf_params(struct qed_hwfn *p_hwfn,
 
 	num_srqs = min_t(u32, 32 * 1024, p_params->num_srqs);
 
+	if (p_hwfn->mcp_info->func_info.protocol == QED_PCI_ETH_RDMA) {
+		DP_NOTICE(p_hwfn,
+			  "Current day drivers don't support RoCE & iWARP simultaneously on the same PF. Default to RoCE-only\n");
+		p_hwfn->hw_info.personality = QED_PCI_ETH_ROCE;
+	}
+
 	switch (p_hwfn->hw_info.personality) {
 	case QED_PCI_ETH_IWARP:
 		/* Each QP requires one connection */
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.c b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
index 376485d..8b99c7d 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
@@ -1691,12 +1691,12 @@ int qed_mcp_get_media_type(struct qed_dev *cdev, u32 *p_media_type)
 	case FW_MB_PARAM_GET_PF_RDMA_ROCE:
 		*p_proto = QED_PCI_ETH_ROCE;
 		break;
-	case FW_MB_PARAM_GET_PF_RDMA_BOTH:
-		DP_NOTICE(p_hwfn,
-			  "Current day drivers don't support RoCE & iWARP. Default to RoCE-only\n");
-		*p_proto = QED_PCI_ETH_ROCE;
-		break;
 	case FW_MB_PARAM_GET_PF_RDMA_IWARP:
+		*p_proto = QED_PCI_ETH_IWARP;
+		break;
+	case FW_MB_PARAM_GET_PF_RDMA_BOTH:
+		*p_proto = QED_PCI_ETH_RDMA;
+		break;
 	default:
 		DP_NOTICE(p_hwfn,
 			  "MFW answers GET_PF_RDMA_PROTOCOL but param is %08x\n",
diff --git a/drivers/net/ethernet/qlogic/qed/qed_rdma.c b/drivers/net/ethernet/qlogic/qed/qed_rdma.c
index 6fb9951..06715f7 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_rdma.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_rdma.c
@@ -156,7 +156,10 @@ static int qed_rdma_alloc(struct qed_hwfn *p_hwfn,
 		return rc;
 
 	p_hwfn->p_rdma_info = p_rdma_info;
-	p_rdma_info->proto = PROTOCOLID_ROCE;
+	if (QED_IS_IWARP_PERSONALITY(p_hwfn))
+		p_rdma_info->proto = PROTOCOLID_IWARP;
+	else
+		p_rdma_info->proto = PROTOCOLID_ROCE;
 
 	num_cons = qed_cxt_get_proto_cid_count(p_hwfn, p_rdma_info->proto,
 					       NULL);
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c b/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
index 46d0c3c..a1d33f3 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
@@ -377,6 +377,7 @@ int qed_sp_pf_start(struct qed_hwfn *p_hwfn,
 		p_ramrod->personality = PERSONALITY_ISCSI;
 		break;
 	case QED_PCI_ETH_ROCE:
+	case QED_PCI_ETH_IWARP:
 		p_ramrod->personality = PERSONALITY_RDMA_AND_ETH;
 		break;
 	default:
-- 
1.8.3.1
