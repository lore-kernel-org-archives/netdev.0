From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next] bnx2x: Correct logic for pvid configuration.
Date: Sun, 2 Aug 2015 12:42:41 +0300
Message-ID: <1438508561-31209-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <dan.carpenter@oracel.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:3422 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751863AbbHBJm4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Aug 2015 05:42:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 05cc5a39ddb7 ("bnx2x: add vlan filtering offload") has introduced
an incorrect logic for checking whether pvid should be configured for
a vf, causing the hypervisor driver to send unneeded ramrods for all of
the vfs each time a pvid has changed.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
Looks like this has been hidden by the fact that
VLAN_VALID == (1 << MAC_ADDR_VALID).
Since MAC is almost always set by the hypervisor it simply caused
additional ramrods to be sent instead of preventing the feature.
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index ec82831..9d02734 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -2528,7 +2528,7 @@ void bnx2x_pf_set_vfs_vlan(struct bnx2x *bp)
 	DP(BNX2X_MSG_IOV, "configuring vlan for VFs from sp-task\n");
 	for_each_vf(bp, vfidx) {
 		bulletin = BP_VF_BULLETIN(bp, vfidx);
-		if (bulletin->valid_bitmap & VLAN_VALID)
+		if (bulletin->valid_bitmap & (1 << VLAN_VALID))
 			bnx2x_set_vf_vlan(bp->dev, vfidx, bulletin->vlan, 0);
 	}
 }
-- 
1.9.3
