From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net 2/2] bnx2x: Disable VF access on PF removal
Date: Sun, 27 Oct 2013 13:07:01 +0200
Message-ID: <1382872021-1116-3-git-send-email-yuvalmin@broadcom.com>
References: <1382872021-1116-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: dmitry@broadcom.com, ariele@broadcom.com, eilong@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1543 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753368Ab3J0LHU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Oct 2013 07:07:20 -0400
In-Reply-To: <1382872021-1116-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ariel Elior <ariele@broadcom.com>

When the bnx2x driver is rmmoded, if VFs of a given PF will be assigned
to a VM then that PF will be unable to call `pci_disable_sriov()'.

If for that same PF there would also exist unassigned VFs in the hypervisor,
the result will be that after the removal there will still be virtual PCI
functions on the hypervisor.
If the bnx2x module were to be re-inserted, the result will be that the VFs
on the hypervisor will be re-probed directly following the PF's probe, even
though that in regular loading flow sriov is only enabled once PF is loaded.
The probed VF will then try to access its bar, causing a PCI error as the HW
is not in a state enabling such a request.

This patch adds a missing disablement procedure to the PF's removal, one that
sets registers viewable to the VF to indicate that the VFs have no permission
to access the bar, thus resulting in probe errors instead of PCI errors.

Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c | 16 +++++++++++++++-
 1 file changed, 15 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index bf08ad6..5e07efb 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -2018,6 +2018,8 @@ failed:
 
 void bnx2x_iov_remove_one(struct bnx2x *bp)
 {
+	int vf_idx;
+
 	/* if SRIOV is not enabled there's nothing to do */
 	if (!IS_SRIOV(bp))
 		return;
@@ -2026,6 +2028,18 @@ void bnx2x_iov_remove_one(struct bnx2x *bp)
 	pci_disable_sriov(bp->pdev);
 	DP(BNX2X_MSG_IOV, "sriov disabled\n");
 
+	/* disable access to all VFs */
+	for (vf_idx = 0; vf_idx < bp->vfdb->sriov.total; vf_idx++) {
+		bnx2x_pretend_func(bp,
+				   HW_VF_HANDLE(bp,
+						bp->vfdb->sriov.first_vf_in_pf +
+						vf_idx));
+		DP(BNX2X_MSG_IOV, "disabling internal access for vf %d\n",
+		   bp->vfdb->sriov.first_vf_in_pf + vf_idx);
+		bnx2x_vf_enable_internal(bp, 0);
+		bnx2x_pretend_func(bp, BP_ABS_FUNC(bp));
+	}
+
 	/* free vf database */
 	__bnx2x_iov_free_vfdb(bp);
 }
@@ -3197,7 +3211,7 @@ int bnx2x_enable_sriov(struct bnx2x *bp)
 	 * the "acquire" messages to appear on the VF PF channel.
 	 */
 	DP(BNX2X_MSG_IOV, "about to call enable sriov\n");
-	pci_disable_sriov(bp->pdev);
+	bnx2x_disable_sriov(bp);
 	rc = pci_enable_sriov(bp->pdev, req_vfs);
 	if (rc) {
 		BNX2X_ERR("pci_enable_sriov failed with %d\n", rc);
-- 
1.8.1.227.g44fe835
