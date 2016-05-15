From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 3/5] qed: Reset link on IOV disable
Date: Sun, 15 May 2016 14:48:07 +0300
Message-ID: <1463312889-19351-4-git-send-email-Yuval.Mintz@qlogic.com>
References: <1463312889-19351-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Manish Chopra <Manish.Chopra@qlogic.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:53082 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754143AbcEOLsZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 May 2016 07:48:25 -0400
In-Reply-To: <1463312889-19351-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <Manish.Chopra@qlogic.com>

PF updates its VFs' bulletin boards with link configurations whenever
the physical carrier changes or whenever hyper-user explicitly requires
some setting of the VFs link via the hypervisor's PF.

Since the bulletin board is getting cleaned as part of the IOV disable
flow on the PF side, re-enabling sriov would lead to a VF that sees the
carrier as 'down', until an event causing the PF to re-fill the bulletin
with the link configuration would occur.

To fix this we simply refelect the link state during the flows, giving
the later VFs a default reflecting the PFs link state.

Signed-off-by: Manish Chopra <Manish.Chopra@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_sriov.c | 90 ++++++++++++++++-------------
 1 file changed, 51 insertions(+), 39 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.c b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
index 7b6b4a0..a977f39 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
@@ -806,9 +806,51 @@ static int qed_iov_init_hw_for_vf(struct qed_hwfn *p_hwfn,
 	return rc;
 }
 
+static void qed_iov_set_link(struct qed_hwfn *p_hwfn,
+			     u16 vfid,
+			     struct qed_mcp_link_params *params,
+			     struct qed_mcp_link_state *link,
+			     struct qed_mcp_link_capabilities *p_caps)
+{
+	struct qed_vf_info *p_vf = qed_iov_get_vf_info(p_hwfn,
+						       vfid,
+						       false);
+	struct qed_bulletin_content *p_bulletin;
+
+	if (!p_vf)
+		return;
+
+	p_bulletin = p_vf->bulletin.p_virt;
+	p_bulletin->req_autoneg = params->speed.autoneg;
+	p_bulletin->req_adv_speed = params->speed.advertised_speeds;
+	p_bulletin->req_forced_speed = params->speed.forced_speed;
+	p_bulletin->req_autoneg_pause = params->pause.autoneg;
+	p_bulletin->req_forced_rx = params->pause.forced_rx;
+	p_bulletin->req_forced_tx = params->pause.forced_tx;
+	p_bulletin->req_loopback = params->loopback_mode;
+
+	p_bulletin->link_up = link->link_up;
+	p_bulletin->speed = link->speed;
+	p_bulletin->full_duplex = link->full_duplex;
+	p_bulletin->autoneg = link->an;
+	p_bulletin->autoneg_complete = link->an_complete;
+	p_bulletin->parallel_detection = link->parallel_detection;
+	p_bulletin->pfc_enabled = link->pfc_enabled;
+	p_bulletin->partner_adv_speed = link->partner_adv_speed;
+	p_bulletin->partner_tx_flow_ctrl_en = link->partner_tx_flow_ctrl_en;
+	p_bulletin->partner_rx_flow_ctrl_en = link->partner_rx_flow_ctrl_en;
+	p_bulletin->partner_adv_pause = link->partner_adv_pause;
+	p_bulletin->sfp_tx_fault = link->sfp_tx_fault;
+
+	p_bulletin->capability_speed = p_caps->speed_capabilities;
+}
+
 static int qed_iov_release_hw_for_vf(struct qed_hwfn *p_hwfn,
 				     struct qed_ptt *p_ptt, u16 rel_vf_id)
 {
+	struct qed_mcp_link_capabilities caps;
+	struct qed_mcp_link_params params;
+	struct qed_mcp_link_state link;
 	struct qed_vf_info *vf = NULL;
 	int rc = 0;
 
@@ -823,6 +865,15 @@ static int qed_iov_release_hw_for_vf(struct qed_hwfn *p_hwfn,
 
 	memset(&vf->p_vf_info, 0, sizeof(vf->p_vf_info));
 
+	/* Get the link configuration back in bulletin so
+	 * that when VFs are re-enabled they get the actual
+	 * link configuration.
+	 */
+	memcpy(&params, qed_mcp_get_link_params(p_hwfn), sizeof(params));
+	memcpy(&link, qed_mcp_get_link_state(p_hwfn), sizeof(link));
+	memcpy(&caps, qed_mcp_get_link_capabilities(p_hwfn), sizeof(caps));
+	qed_iov_set_link(p_hwfn, rel_vf_id, &params, &link, &caps);
+
 	if (vf->state != VF_STOPPED) {
 		/* Stopping the VF */
 		rc = qed_sp_vf_stop(p_hwfn, vf->concrete_fid, vf->opaque_fid);
@@ -2542,45 +2593,6 @@ int qed_iov_mark_vf_flr(struct qed_hwfn *p_hwfn, u32 *p_disabled_vfs)
 	return found;
 }
 
-void qed_iov_set_link(struct qed_hwfn *p_hwfn,
-		      u16 vfid,
-		      struct qed_mcp_link_params *params,
-		      struct qed_mcp_link_state *link,
-		      struct qed_mcp_link_capabilities *p_caps)
-{
-	struct qed_vf_info *p_vf = qed_iov_get_vf_info(p_hwfn,
-						       vfid,
-						       false);
-	struct qed_bulletin_content *p_bulletin;
-
-	if (!p_vf)
-		return;
-
-	p_bulletin = p_vf->bulletin.p_virt;
-	p_bulletin->req_autoneg = params->speed.autoneg;
-	p_bulletin->req_adv_speed = params->speed.advertised_speeds;
-	p_bulletin->req_forced_speed = params->speed.forced_speed;
-	p_bulletin->req_autoneg_pause = params->pause.autoneg;
-	p_bulletin->req_forced_rx = params->pause.forced_rx;
-	p_bulletin->req_forced_tx = params->pause.forced_tx;
-	p_bulletin->req_loopback = params->loopback_mode;
-
-	p_bulletin->link_up = link->link_up;
-	p_bulletin->speed = link->speed;
-	p_bulletin->full_duplex = link->full_duplex;
-	p_bulletin->autoneg = link->an;
-	p_bulletin->autoneg_complete = link->an_complete;
-	p_bulletin->parallel_detection = link->parallel_detection;
-	p_bulletin->pfc_enabled = link->pfc_enabled;
-	p_bulletin->partner_adv_speed = link->partner_adv_speed;
-	p_bulletin->partner_tx_flow_ctrl_en = link->partner_tx_flow_ctrl_en;
-	p_bulletin->partner_rx_flow_ctrl_en = link->partner_rx_flow_ctrl_en;
-	p_bulletin->partner_adv_pause = link->partner_adv_pause;
-	p_bulletin->sfp_tx_fault = link->sfp_tx_fault;
-
-	p_bulletin->capability_speed = p_caps->speed_capabilities;
-}
-
 static void qed_iov_get_link(struct qed_hwfn *p_hwfn,
 			     u16 vfid,
 			     struct qed_mcp_link_params *p_params,
-- 
1.9.3
