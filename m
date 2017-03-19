From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 9/9] qed: Always publish VF link from leading hwfn
Date: Sun, 19 Mar 2017 13:08:20 +0200
Message-ID: <1489921700-6850-10-git-send-email-Yuval.Mintz@cavium.com>
References: <1489921700-6850-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:45848 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752013AbdCSLIz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Mar 2017 07:08:55 -0400
In-Reply-To: <1489921700-6850-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The link information exists only on the leading hwfn,
but some of its derivatives [e.g., min/max rate] need to
be configured for each hwfn.
When re-basing the VF link view, use the leading hwfn
information as basis for all existing hwfns to allow
said configurations to stick.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_sriov.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.c b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
index 0d37d73..18fc6e6 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
@@ -3945,6 +3945,7 @@ static int qed_get_vf_config(struct qed_dev *cdev,
 
 void qed_inform_vf_link_state(struct qed_hwfn *hwfn)
 {
+	struct qed_hwfn *lead_hwfn = QED_LEADING_HWFN(hwfn->cdev);
 	struct qed_mcp_link_capabilities caps;
 	struct qed_mcp_link_params params;
 	struct qed_mcp_link_state link;
@@ -3961,9 +3962,15 @@ void qed_inform_vf_link_state(struct qed_hwfn *hwfn)
 		if (!vf_info)
 			continue;
 
-		memcpy(&params, qed_mcp_get_link_params(hwfn), sizeof(params));
-		memcpy(&link, qed_mcp_get_link_state(hwfn), sizeof(link));
-		memcpy(&caps, qed_mcp_get_link_capabilities(hwfn),
+		/* Only hwfn0 is actually interested in the link speed.
+		 * But since only it would receive an MFW indication of link,
+		 * need to take configuration from it - otherwise things like
+		 * rate limiting for hwfn1 VF would not work.
+		 */
+		memcpy(&params, qed_mcp_get_link_params(lead_hwfn),
+		       sizeof(params));
+		memcpy(&link, qed_mcp_get_link_state(lead_hwfn), sizeof(link));
+		memcpy(&caps, qed_mcp_get_link_capabilities(lead_hwfn),
 		       sizeof(caps));
 
 		/* Modify link according to the VF's configured link state */
-- 
1.9.3
