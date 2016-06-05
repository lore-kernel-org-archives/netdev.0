From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 2/6] qed: PF-VF resource negotiation
Date: Sun, 5 Jun 2016 13:11:12 +0300
Message-ID: <1465121476-32494-3-git-send-email-Yuval.Mintz@qlogic.com>
References: <1465121476-32494-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:6978 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750951AbcFEKLf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jun 2016 06:11:35 -0400
In-Reply-To: <1465121476-32494-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

One of the goals of the vf's first message to the PF [acquire]
is to learn about the number of resources available to it [macs, vlans,
etc.]. This is done via negotiation - the VF requires a set of resources,
which the PF either approves or disaproves and sends a smaller set of
resources as alternative. In this later case, the VF is then expected to
either abort the probe or re-send the acquire message with less
required resources.

While this infrastructure exists since the initial submision of qed
SRIOV support, it's in fact completely inoperational - PF isn't really
looking into the resources the VF has asked for and is never going to
reply to the VF that it lacks resources.

This patch addresses this flow, fixing it and allowing the PF and VF
to actually agree on a set of resources.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_sriov.c | 144 ++++++++++++++++++----------
 drivers/net/ethernet/qlogic/qed/qed_sriov.h |   4 +-
 drivers/net/ethernet/qlogic/qed/qed_vf.c    |  56 +++++++----
 3 files changed, 135 insertions(+), 69 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.c b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
index 9857624..dbb4553 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
@@ -322,6 +322,9 @@ static void qed_iov_setup_vfdb(struct qed_hwfn *p_hwfn)
 		vf->opaque_fid = (p_hwfn->hw_info.opaque_fid & 0xff) |
 				 (vf->abs_vf_id << 8);
 		vf->vport_id = idx + 1;
+
+		vf->num_mac_filters = QED_ETH_VF_NUM_MAC_FILTERS;
+		vf->num_vlan_filters = QED_ETH_VF_NUM_VLAN_FILTERS;
 	}
 }
 
@@ -1123,8 +1126,6 @@ static void qed_iov_vf_cleanup(struct qed_hwfn *p_hwfn,
 
 	p_vf->vf_bulletin = 0;
 	p_vf->vport_instance = 0;
-	p_vf->num_mac_filters = 0;
-	p_vf->num_vlan_filters = 0;
 	p_vf->configured_features = 0;
 
 	/* If VF previously requested less resources, go back to default */
@@ -1141,6 +1142,91 @@ static void qed_iov_vf_cleanup(struct qed_hwfn *p_hwfn,
 	qed_iov_clean_vf(p_hwfn, p_vf->relative_vf_id);
 }
 
+static u8 qed_iov_vf_mbx_acquire_resc(struct qed_hwfn *p_hwfn,
+				      struct qed_ptt *p_ptt,
+				      struct qed_vf_info *p_vf,
+				      struct vf_pf_resc_request *p_req,
+				      struct pf_vf_resc *p_resp)
+{
+	int i;
+
+	/* Queue related information */
+	p_resp->num_rxqs = p_vf->num_rxqs;
+	p_resp->num_txqs = p_vf->num_txqs;
+	p_resp->num_sbs = p_vf->num_sbs;
+
+	for (i = 0; i < p_resp->num_sbs; i++) {
+		p_resp->hw_sbs[i].hw_sb_id = p_vf->igu_sbs[i];
+		p_resp->hw_sbs[i].sb_qid = 0;
+	}
+
+	/* These fields are filled for backward compatibility.
+	 * Unused by modern vfs.
+	 */
+	for (i = 0; i < p_resp->num_rxqs; i++) {
+		qed_fw_l2_queue(p_hwfn, p_vf->vf_queues[i].fw_rx_qid,
+				(u16 *)&p_resp->hw_qid[i]);
+		p_resp->cid[i] = p_vf->vf_queues[i].fw_cid;
+	}
+
+	/* Filter related information */
+	p_resp->num_mac_filters = min_t(u8, p_vf->num_mac_filters,
+					p_req->num_mac_filters);
+	p_resp->num_vlan_filters = min_t(u8, p_vf->num_vlan_filters,
+					 p_req->num_vlan_filters);
+
+	/* This isn't really needed/enforced, but some legacy VFs might depend
+	 * on the correct filling of this field.
+	 */
+	p_resp->num_mc_filters = QED_MAX_MC_ADDRS;
+
+	/* Validate sufficient resources for VF */
+	if (p_resp->num_rxqs < p_req->num_rxqs ||
+	    p_resp->num_txqs < p_req->num_txqs ||
+	    p_resp->num_sbs < p_req->num_sbs ||
+	    p_resp->num_mac_filters < p_req->num_mac_filters ||
+	    p_resp->num_vlan_filters < p_req->num_vlan_filters ||
+	    p_resp->num_mc_filters < p_req->num_mc_filters) {
+		DP_VERBOSE(p_hwfn,
+			   QED_MSG_IOV,
+			   "VF[%d] - Insufficient resources: rxq [%02x/%02x] txq [%02x/%02x] sbs [%02x/%02x] mac [%02x/%02x] vlan [%02x/%02x] mc [%02x/%02x]\n",
+			   p_vf->abs_vf_id,
+			   p_req->num_rxqs,
+			   p_resp->num_rxqs,
+			   p_req->num_rxqs,
+			   p_resp->num_txqs,
+			   p_req->num_sbs,
+			   p_resp->num_sbs,
+			   p_req->num_mac_filters,
+			   p_resp->num_mac_filters,
+			   p_req->num_vlan_filters,
+			   p_resp->num_vlan_filters,
+			   p_req->num_mc_filters, p_resp->num_mc_filters);
+		return PFVF_STATUS_NO_RESOURCE;
+	}
+
+	return PFVF_STATUS_SUCCESS;
+}
+
+static void qed_iov_vf_mbx_acquire_stats(struct qed_hwfn *p_hwfn,
+					 struct pfvf_stats_info *p_stats)
+{
+	p_stats->mstats.address = PXP_VF_BAR0_START_MSDM_ZONE_B +
+				  offsetof(struct mstorm_vf_zone,
+					   non_trigger.eth_queue_stat);
+	p_stats->mstats.len = sizeof(struct eth_mstorm_per_queue_stat);
+	p_stats->ustats.address = PXP_VF_BAR0_START_USDM_ZONE_B +
+				  offsetof(struct ustorm_vf_zone,
+					   non_trigger.eth_queue_stat);
+	p_stats->ustats.len = sizeof(struct eth_ustorm_per_queue_stat);
+	p_stats->pstats.address = PXP_VF_BAR0_START_PSDM_ZONE_B +
+				  offsetof(struct pstorm_vf_zone,
+					   non_trigger.eth_queue_stat);
+	p_stats->pstats.len = sizeof(struct eth_pstorm_per_queue_stat);
+	p_stats->tstats.address = 0;
+	p_stats->tstats.len = 0;
+}
+
 static void qed_iov_vf_mbx_acquire(struct qed_hwfn *p_hwfn,
 				   struct qed_ptt *p_ptt,
 				   struct qed_vf_info *vf)
@@ -1149,7 +1235,7 @@ static void qed_iov_vf_mbx_acquire(struct qed_hwfn *p_hwfn,
 	struct pfvf_acquire_resp_tlv *resp = &mbx->reply_virt->acquire_resp;
 	struct pf_vf_pfdev_info *pfdev_info = &resp->pfdev_info;
 	struct vfpf_acquire_tlv *req = &mbx->req_virt->acquire;
-	u8 i, vfpf_status = PFVF_STATUS_NOT_SUPPORTED;
+	u8 vfpf_status = PFVF_STATUS_NOT_SUPPORTED;
 	struct pf_vf_resc *resc = &resp->resc;
 	int rc;
 
@@ -1185,10 +1271,7 @@ static void qed_iov_vf_mbx_acquire(struct qed_hwfn *p_hwfn,
 	/* Store the acquire message */
 	memcpy(&vf->acquire, req, sizeof(vf->acquire));
 
-	/* Fill in vf info stuff */
 	vf->opaque_fid = req->vfdev_info.opaque_fid;
-	vf->num_mac_filters = 1;
-	vf->num_vlan_filters = QED_ETH_VF_NUM_VLAN_FILTERS;
 
 	vf->vf_bulletin = req->bulletin_addr;
 	vf->bulletin.size = (vf->bulletin.size < req->bulletin_size) ?
@@ -1204,26 +1287,7 @@ static void qed_iov_vf_mbx_acquire(struct qed_hwfn *p_hwfn,
 	if (p_hwfn->cdev->num_hwfns > 1)
 		pfdev_info->capabilities |= PFVF_ACQUIRE_CAP_100G;
 
-	pfdev_info->stats_info.mstats.address =
-	    PXP_VF_BAR0_START_MSDM_ZONE_B +
-	    offsetof(struct mstorm_vf_zone, non_trigger.eth_queue_stat);
-	pfdev_info->stats_info.mstats.len =
-	    sizeof(struct eth_mstorm_per_queue_stat);
-
-	pfdev_info->stats_info.ustats.address =
-	    PXP_VF_BAR0_START_USDM_ZONE_B +
-	    offsetof(struct ustorm_vf_zone, non_trigger.eth_queue_stat);
-	pfdev_info->stats_info.ustats.len =
-	    sizeof(struct eth_ustorm_per_queue_stat);
-
-	pfdev_info->stats_info.pstats.address =
-	    PXP_VF_BAR0_START_PSDM_ZONE_B +
-	    offsetof(struct pstorm_vf_zone, non_trigger.eth_queue_stat);
-	pfdev_info->stats_info.pstats.len =
-	    sizeof(struct eth_pstorm_per_queue_stat);
-
-	pfdev_info->stats_info.tstats.address = 0;
-	pfdev_info->stats_info.tstats.len = 0;
+	qed_iov_vf_mbx_acquire_stats(p_hwfn, &pfdev_info->stats_info);
 
 	memcpy(pfdev_info->port_mac, p_hwfn->hw_info.hw_mac_addr, ETH_ALEN);
 
@@ -1240,29 +1304,13 @@ static void qed_iov_vf_mbx_acquire(struct qed_hwfn *p_hwfn,
 	pfdev_info->dev_type = p_hwfn->cdev->type;
 	pfdev_info->chip_rev = p_hwfn->cdev->chip_rev;
 
-	resc->num_rxqs = vf->num_rxqs;
-	resc->num_txqs = vf->num_txqs;
-	resc->num_sbs = vf->num_sbs;
-	for (i = 0; i < resc->num_sbs; i++) {
-		resc->hw_sbs[i].hw_sb_id = vf->igu_sbs[i];
-		resc->hw_sbs[i].sb_qid = 0;
-	}
-
-	for (i = 0; i < resc->num_rxqs; i++) {
-		qed_fw_l2_queue(p_hwfn, vf->vf_queues[i].fw_rx_qid,
-				(u16 *)&resc->hw_qid[i]);
-		resc->cid[i] = vf->vf_queues[i].fw_cid;
-	}
-
-	resc->num_mac_filters = min_t(u8, vf->num_mac_filters,
-				      req->resc_request.num_mac_filters);
-	resc->num_vlan_filters = min_t(u8, vf->num_vlan_filters,
-				       req->resc_request.num_vlan_filters);
-
-	/* This isn't really required as VF isn't limited, but some VFs might
-	 * actually test this value, so need to provide it.
+	/* Fill resources available to VF; Make sure there are enough to
+	 * satisfy the VF's request.
 	 */
-	resc->num_mc_filters = req->resc_request.num_mc_filters;
+	vfpf_status = qed_iov_vf_mbx_acquire_resc(p_hwfn, p_ptt, vf,
+						  &req->resc_request, resc);
+	if (vfpf_status != PFVF_STATUS_SUCCESS)
+		goto out;
 
 	/* Start the VF in FW */
 	rc = qed_sp_vf_start(p_hwfn, vf);
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.h b/drivers/net/ethernet/qlogic/qed/qed_sriov.h
index 2bcaeb3..ea24795 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.h
@@ -10,6 +10,9 @@
 #define _QED_SRIOV_H
 #include <linux/types.h>
 #include "qed_vf.h"
+
+#define QED_ETH_VF_NUM_MAC_FILTERS 1
+#define QED_ETH_VF_NUM_VLAN_FILTERS 2
 #define QED_VF_ARRAY_LENGTH (3)
 
 #define IS_VF(cdev)             ((cdev)->b_is_vf)
@@ -22,7 +25,6 @@
 #define IS_PF_SRIOV_ALLOC(p_hwfn)       (!!((p_hwfn)->pf_iov_info))
 
 #define QED_MAX_VF_CHAINS_PER_PF 16
-#define QED_ETH_VF_NUM_VLAN_FILTERS 2
 
 #define QED_ETH_MAX_VF_NUM_VLAN_FILTERS	\
 	(MAX_NUM_VFS * QED_ETH_VF_NUM_VLAN_FILTERS)
diff --git a/drivers/net/ethernet/qlogic/qed/qed_vf.c b/drivers/net/ethernet/qlogic/qed/qed_vf.c
index ce8aec3..46751ce 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_vf.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_vf.c
@@ -117,30 +117,56 @@ exit:
 }
 
 #define VF_ACQUIRE_THRESH 3
-#define VF_ACQUIRE_MAC_FILTERS 1
+static void qed_vf_pf_acquire_reduce_resc(struct qed_hwfn *p_hwfn,
+					  struct vf_pf_resc_request *p_req,
+					  struct pf_vf_resc *p_resp)
+{
+	DP_VERBOSE(p_hwfn,
+		   QED_MSG_IOV,
+		   "PF unwilling to fullill resource request: rxq [%02x/%02x] txq [%02x/%02x] sbs [%02x/%02x] mac [%02x/%02x] vlan [%02x/%02x] mc [%02x/%02x]. Try PF recommended amount\n",
+		   p_req->num_rxqs,
+		   p_resp->num_rxqs,
+		   p_req->num_rxqs,
+		   p_resp->num_txqs,
+		   p_req->num_sbs,
+		   p_resp->num_sbs,
+		   p_req->num_mac_filters,
+		   p_resp->num_mac_filters,
+		   p_req->num_vlan_filters,
+		   p_resp->num_vlan_filters,
+		   p_req->num_mc_filters, p_resp->num_mc_filters);
+
+	/* humble our request */
+	p_req->num_txqs = p_resp->num_txqs;
+	p_req->num_rxqs = p_resp->num_rxqs;
+	p_req->num_sbs = p_resp->num_sbs;
+	p_req->num_mac_filters = p_resp->num_mac_filters;
+	p_req->num_vlan_filters = p_resp->num_vlan_filters;
+	p_req->num_mc_filters = p_resp->num_mc_filters;
+}
 
 static int qed_vf_pf_acquire(struct qed_hwfn *p_hwfn)
 {
 	struct qed_vf_iov *p_iov = p_hwfn->vf_iov_info;
 	struct pfvf_acquire_resp_tlv *resp = &p_iov->pf2vf_reply->acquire_resp;
 	struct pf_vf_pfdev_info *pfdev_info = &resp->pfdev_info;
-	u8 rx_count = 1, tx_count = 1, num_sbs = 1;
-	u8 num_mac = VF_ACQUIRE_MAC_FILTERS;
+	struct vf_pf_resc_request *p_resc;
 	bool resources_acquired = false;
 	struct vfpf_acquire_tlv *req;
 	int rc = 0, attempts = 0;
 
 	/* clear mailbox and prep first tlv */
 	req = qed_vf_pf_prep(p_hwfn, CHANNEL_TLV_ACQUIRE, sizeof(*req));
+	p_resc = &req->resc_request;
 
 	/* starting filling the request */
 	req->vfdev_info.opaque_fid = p_hwfn->hw_info.opaque_fid;
 
-	req->resc_request.num_rxqs = rx_count;
-	req->resc_request.num_txqs = tx_count;
-	req->resc_request.num_sbs = num_sbs;
-	req->resc_request.num_mac_filters = num_mac;
-	req->resc_request.num_vlan_filters = QED_ETH_VF_NUM_VLAN_FILTERS;
+	p_resc->num_rxqs = QED_MAX_VF_CHAINS_PER_PF;
+	p_resc->num_txqs = QED_MAX_VF_CHAINS_PER_PF;
+	p_resc->num_sbs = QED_MAX_VF_CHAINS_PER_PF;
+	p_resc->num_mac_filters = QED_ETH_VF_NUM_MAC_FILTERS;
+	p_resc->num_vlan_filters = QED_ETH_VF_NUM_VLAN_FILTERS;
 
 	req->vfdev_info.os_type = VFPF_ACQUIRE_OS_LINUX;
 	req->vfdev_info.fw_major = FW_MAJOR_VERSION;
@@ -187,18 +213,8 @@ static int qed_vf_pf_acquire(struct qed_hwfn *p_hwfn)
 			resources_acquired = true;
 		} else if (resp->hdr.status == PFVF_STATUS_NO_RESOURCE &&
 			   attempts < VF_ACQUIRE_THRESH) {
-			DP_VERBOSE(p_hwfn,
-				   QED_MSG_IOV,
-				   "PF unwilling to fullfill resource request. Try PF recommended amount\n");
-
-			/* humble our request */
-			req->resc_request.num_txqs = resp->resc.num_txqs;
-			req->resc_request.num_rxqs = resp->resc.num_rxqs;
-			req->resc_request.num_sbs = resp->resc.num_sbs;
-			req->resc_request.num_mac_filters =
-			    resp->resc.num_mac_filters;
-			req->resc_request.num_vlan_filters =
-			    resp->resc.num_vlan_filters;
+			qed_vf_pf_acquire_reduce_resc(p_hwfn, p_resc,
+						      &resp->resc);
 
 			/* Clear response buffer */
 			memset(p_iov->pf2vf_reply, 0, sizeof(union pfvf_tlvs));
-- 
1.9.3
