From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 07/10] qed: Reflect PF link when initializing VF
Date: Mon, 20 Feb 2017 22:43:36 +0200
Message-ID: <1487623419-6442-8-git-send-email-Yuval.Mintz@cavium.com>
References: <1487623419-6442-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:46407 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751118AbdBTU7b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 15:59:31 -0500
In-Reply-To: <1487623419-6442-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

VF learns of the current link state via its bulletin board,
which might reflect either the physical link state or some
user-configured logical state.
Whenever the physical link changes or whnever such a configuration
is explicitly made by user the PF driver would update the bulletin
that the VF reads. But if neither has happened - i.e., PF still
hasn't got a physical link up and no additional configuration was
done the VF wouldn't have a valid link information available.

Simply reflect the physical link state whenever the VF is
initialized. The user could then affect it however he wants.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_sriov.c | 90 ++++++++++++++++-------------
 1 file changed, 51 insertions(+), 39 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.c b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
index 3f4bf31..29ed785 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
@@ -831,10 +831,52 @@ static void qed_iov_free_vf_igu_sbs(struct qed_hwfn *p_hwfn,
 	vf->num_sbs = 0;
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
 static int qed_iov_init_hw_for_vf(struct qed_hwfn *p_hwfn,
 				  struct qed_ptt *p_ptt,
 				  struct qed_iov_vf_init_params *p_params)
 {
+	struct qed_mcp_link_capabilities link_caps;
+	struct qed_mcp_link_params link_params;
+	struct qed_mcp_link_state link_state;
 	u8 num_of_vf_avaiable_chains = 0;
 	struct qed_vf_info *vf = NULL;
 	u16 qid, num_irqs;
@@ -923,6 +965,15 @@ static int qed_iov_init_hw_for_vf(struct qed_hwfn *p_hwfn,
 			   p_queue->fw_tx_qid, p_queue->fw_cid);
 	}
 
+	/* Update the link configuration in bulletin */
+	memcpy(&link_params, qed_mcp_get_link_params(p_hwfn),
+	       sizeof(link_params));
+	memcpy(&link_state, qed_mcp_get_link_state(p_hwfn), sizeof(link_state));
+	memcpy(&link_caps, qed_mcp_get_link_capabilities(p_hwfn),
+	       sizeof(link_caps));
+	qed_iov_set_link(p_hwfn, p_params->rel_vf_id,
+			 &link_params, &link_state, &link_caps);
+
 	rc = qed_iov_enable_vf_access(p_hwfn, p_ptt, vf);
 	if (!rc) {
 		vf->b_init = true;
@@ -934,45 +985,6 @@ static int qed_iov_init_hw_for_vf(struct qed_hwfn *p_hwfn,
 	return rc;
 }
 
-static void qed_iov_set_link(struct qed_hwfn *p_hwfn,
-			     u16 vfid,
-			     struct qed_mcp_link_params *params,
-			     struct qed_mcp_link_state *link,
-			     struct qed_mcp_link_capabilities *p_caps)
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
 static int qed_iov_release_hw_for_vf(struct qed_hwfn *p_hwfn,
 				     struct qed_ptt *p_ptt, u16 rel_vf_id)
 {
-- 
1.9.3
