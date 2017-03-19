From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 2/9] qed: Clean VF malicious indication when disabling IOV
Date: Sun, 19 Mar 2017 13:08:13 +0200
Message-ID: <1489921700-6850-3-git-send-email-Yuval.Mintz@cavium.com>
References: <1489921700-6850-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:45798 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751922AbdCSLIl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Mar 2017 07:08:41 -0400
In-Reply-To: <1489921700-6850-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a VF is considered malicious, driver handling of the VF
FLR flow would clean said indication - but not if the FLR is
part of an sriov-disable flow.
That leads to further issues, as PF wouldn't re-enable the
previously malicious VF when sriov is re-enabled.

No reason for that - simply clean malicious indications in
the sriov-disable flow as well.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_sriov.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.c b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
index 16f503c..2403d58 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
@@ -693,6 +693,11 @@ static int qed_iov_enable_vf_access(struct qed_hwfn *p_hwfn,
 	u32 igu_vf_conf = IGU_VF_CONF_FUNC_EN;
 	int rc;
 
+	/* It's possible VF was previously considered malicious -
+	 * clear the indication even if we're only going to disable VF.
+	 */
+	vf->b_malicious = false;
+
 	if (vf->to_disable)
 		return 0;
 
@@ -705,9 +710,6 @@ static int qed_iov_enable_vf_access(struct qed_hwfn *p_hwfn,
 
 	qed_iov_vf_igu_reset(p_hwfn, p_ptt, vf);
 
-	/* It's possible VF was previously considered malicious */
-	vf->b_malicious = false;
-
 	rc = qed_mcp_config_vf_msix(p_hwfn, p_ptt, vf->abs_vf_id, vf->num_sbs);
 	if (rc)
 		return rc;
-- 
1.9.3
