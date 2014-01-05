From: Yuval Mintz <yuvalmin@broadcom.com>
Subject: [PATCH net 2/5] bnx2x: Correct number of MSI-X vectors for VFs
Date: Sun, 5 Jan 2014 18:33:51 +0200
Message-ID: <1388939634-19948-3-git-send-email-yuvalmin@broadcom.com>
References: <1388939634-19948-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ariele@broadcom.com>, Michal Kalderon <michals@broadcom.com>,
	Yuval Mintz <yuvalmin@broadcom.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:38815 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751112AbaAEQeB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jan 2014 11:34:01 -0500
In-Reply-To: <1388939634-19948-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Kalderon <michals@broadcom.com>

Number of VFs in PCIe configuration space is zero-based. Driver incorrectly
sets the number of VFs to be larger by one than what actually is feasible by
HW, which might cause later VFs to fail to allocate their MSI-X interrupts.

Signed-off-by: Michal Kalderon <michals@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index 2e46c28..ddd95b9 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -3202,13 +3202,16 @@ int bnx2x_enable_sriov(struct bnx2x *bp)
 		bnx2x_iov_static_resc(bp, vf);
 	}
 
-	/* prepare msix vectors in VF configuration space */
+	/* prepare msix vectors in VF configuration space - the value in the
+	 * PCI configuration space should be the index of the last entry,
+	 * namely one less than the actual size of the table
+	 */
 	for (vf_idx = first_vf; vf_idx < first_vf + req_vfs; vf_idx++) {
 		bnx2x_pretend_func(bp, HW_VF_HANDLE(bp, vf_idx));
 		REG_WR(bp, PCICFG_OFFSET + GRC_CONFIG_REG_VF_MSIX_CONTROL,
-		       num_vf_queues);
+		       num_vf_queues - 1);
 		DP(BNX2X_MSG_IOV, "set msix vec num in VF %d cfg space to %d\n",
-		   vf_idx, num_vf_queues);
+		   vf_idx, num_vf_queues - 1);
 	}
 	bnx2x_pretend_func(bp, BP_ABS_FUNC(bp));
 
-- 
1.8.1.227.g44fe835
