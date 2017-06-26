From: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: [RFC 19/19] qed*: Add iWARP enablement support
Date: Mon, 26 Jun 2017 21:07:09 +0300
Message-ID: <1498500429-22557-20-git-send-email-Michal.Kalderon@cavium.com>
References: <1498500429-22557-1-git-send-email-Michal.Kalderon@cavium.com>
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
In-Reply-To: <1498500429-22557-1-git-send-email-Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch is the last of the initial iWARP patch series. It
adds the possiblity to actually detect iWARP from the device and enable
it in the critical locations which basically make iWARP available.

Signed-off-by: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Ariel Elior <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>

---
 drivers/infiniband/hw/qedr/main.c                 |  2 ++
 drivers/net/ethernet/qlogic/qed/qed_cxt.c         |  6 ++++++
 drivers/net/ethernet/qlogic/qed/qed_mcp.c         | 10 +++++-----
 drivers/net/ethernet/qlogic/qed/qed_rdma.c        |  5 ++++-
 drivers/net/ethernet/qlogic/qed/qed_sp_commands.c |  2 ++
 5 files changed, 19 insertions(+), 6 deletions(-)

diff --git a/drivers/infiniband/hw/qedr/main.c b/drivers/infiniband/hw/qedr/main.c
index c594b11..3357053 100644
--- a/drivers/infiniband/hw/qedr/main.c
+++ b/drivers/infiniband/hw/qedr/main.c
@@ -871,6 +871,8 @@ static struct qedr_dev *qedr_add(struct qed_dev *cdev, struct pci_dev *pdev,
 	if (rc)
 		goto init_err;
 
+	dev->rdma_type = dev_info.rdma_type;
+
 	dev->num_hwfns = dev_info.common.num_hwfns;
 	dev->rdma_ctx = dev->ops->rdma_get_rdma_ctx(cdev);
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_cxt.c b/drivers/net/ethernet/qlogic/qed/qed_cxt.c
index af106be..32bed84 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_cxt.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_cxt.c
@@ -2069,6 +2069,12 @@ static void qed_rdma_set_pf_params(struct qed_hwfn *p_hwfn,
 
 	num_srqs = min_t(u32, 32 * 1024, p_params->num_srqs);
 
+	if (p_hwfn->mcp_info->func_info.protocol == QED_PCI_ETH_RDMA) {
+		DP_NOTICE(p_hwfn,
+			  "Current day drivers don't support RoCE & iWARP. Default to RoCE-only\n");
+		p_hwfn->hw_info.personality = QED_PCI_ETH_ROCE;
+	}
+
 	switch (p_hwfn->hw_info.personality) {
 	case QED_PCI_ETH_IWARP:
 		/* Each QP requires one connection */
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.c b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
index 9da9104..8645099 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
@@ -1650,12 +1650,12 @@ int qed_mcp_get_media_type(struct qed_dev *cdev, u32 *p_media_type)
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
index 46d0c3c..3503b43 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
@@ -376,7 +376,9 @@ int qed_sp_pf_start(struct qed_hwfn *p_hwfn,
 	case QED_PCI_ISCSI:
 		p_ramrod->personality = PERSONALITY_ISCSI;
 		break;
+	case QED_PCI_ETH_IWARP:
 	case QED_PCI_ETH_ROCE:
+	case QED_PCI_ETH_RDMA:
 		p_ramrod->personality = PERSONALITY_RDMA_AND_ETH;
 		break;
 	default:
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
