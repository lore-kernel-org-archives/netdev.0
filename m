From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 7/9] bnx2x: Prevent pci_disable_sriov with assigned VFs
Date: Sun, 17 Aug 2014 16:47:49 +0300
Message-ID: <1408283271-16176-8-git-send-email-Yuval.Mintz@qlogic.com>
References: <1408283271-16176-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:65489 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751744AbaHQNsV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Aug 2014 09:48:21 -0400
In-Reply-To: <1408283271-16176-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Trying to disable sriov when VFs are assigned may lead to all kinds of problems.
This patch unifies the call in the driver to pci_disable_sriov() and prevents
them if some of the PF's child VFs are marked as assigned.

[Notice this is a bad scenario either way; User should not reach a point where
the OS tries to disable SRIOV when a VF is assigned - but currently there's no
way of preventing the user from doing so, and the ill-effect for the driver is
smaller this way]

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index 45ae68d..c88b20a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -1352,9 +1352,7 @@ void bnx2x_iov_remove_one(struct bnx2x *bp)
 	if (!IS_SRIOV(bp))
 		return;
 
-	DP(BNX2X_MSG_IOV, "about to call disable sriov\n");
-	pci_disable_sriov(bp->pdev);
-	DP(BNX2X_MSG_IOV, "sriov disabled\n");
+	bnx2x_disable_sriov(bp);
 
 	/* disable access to all VFs */
 	for (vf_idx = 0; vf_idx < bp->vfdb->sriov.total; vf_idx++) {
@@ -2483,7 +2481,7 @@ int bnx2x_sriov_configure(struct pci_dev *dev, int num_vfs_param)
 	bp->requested_nr_virtfn = num_vfs_param;
 	if (num_vfs_param == 0) {
 		bnx2x_set_pf_tx_switching(bp, false);
-		pci_disable_sriov(dev);
+		bnx2x_disable_sriov(bp);
 		return 0;
 	} else {
 		return bnx2x_enable_sriov(bp);
@@ -2596,6 +2594,12 @@ void bnx2x_pf_set_vfs_vlan(struct bnx2x *bp)
 
 void bnx2x_disable_sriov(struct bnx2x *bp)
 {
+	if (pci_vfs_assigned(bp->pdev)) {
+		DP(BNX2X_MSG_IOV,
+		   "Unloading driver while VFs are assigned - VFs will not be deallocated\n");
+		return;
+	}
+
 	pci_disable_sriov(bp->pdev);
 }
 
-- 
1.7.1
