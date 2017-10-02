From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/13] fm10k: don't loop while resetting VFs due to VFLR event
Date: Mon,  2 Oct 2017 08:42:33 -0700
Message-ID: <20171002154236.84043-11-jeffrey.t.kirsher@intel.com>
References: <20171002154236.84043-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:58698 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751731AbdJBPnA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 2 Oct 2017 11:43:00 -0400
In-Reply-To: <20171002154236.84043-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

We've always had a really weird looping construction for resetting VFs.
We read the VFLRE register and reset the VF if the corresponding bit is
set, which makes sense. However we loop continuously until we no longer
have any bits left unset. At first this makes sense, as a sort of "keep
trying until we succeed" concept.

Unfortunately this causes a problem if we happen to surprise remove
while this code is executing, because in this case we'll always read all
1s for the VFLRE register. This results in a hard lockup on the CPU
because the loop will never terminate.

Because our own reset function will clear the VFLR event register
always, (except when we've lost PCIe link obviously) there is no real
reason to loop. In practice, we'll loop over once and find that no VFs
are pending anymore.

Lets just check once. Since we're clear the notification when we reset
there's no benefit to the loop. Additionally, there shouldn't be a race
as future VLFRE events should trigger an interrupt. Additionally, we
didn't warn or do anything in the looped case anyways.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_iov.c | 24 +++++++++++-------------
 1 file changed, 11 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_iov.c b/drivers/net/ethernet/intel/fm10k/fm10k_iov.c
index dfc88a463735..03897720bf0b 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_iov.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_iov.c
@@ -66,23 +66,21 @@ s32 fm10k_iov_event(struct fm10k_intfc *interface)
 		goto read_unlock;
 
 	/* read VFLRE to determine if any VFs have been reset */
-	do {
-		vflre = fm10k_read_reg(hw, FM10K_PFVFLRE(1));
-		vflre <<= 32;
-		vflre |= fm10k_read_reg(hw, FM10K_PFVFLRE(0));
+	vflre = fm10k_read_reg(hw, FM10K_PFVFLRE(1));
+	vflre <<= 32;
+	vflre |= fm10k_read_reg(hw, FM10K_PFVFLRE(0));
 
-		i = iov_data->num_vfs;
+	i = iov_data->num_vfs;
 
-		for (vflre <<= 64 - i; vflre && i--; vflre += vflre) {
-			struct fm10k_vf_info *vf_info = &iov_data->vf_info[i];
+	for (vflre <<= 64 - i; vflre && i--; vflre += vflre) {
+		struct fm10k_vf_info *vf_info = &iov_data->vf_info[i];
 
-			if (vflre >= 0)
-				continue;
+		if (vflre >= 0)
+			continue;
 
-			hw->iov.ops.reset_resources(hw, vf_info);
-			vf_info->mbx.ops.connect(hw, &vf_info->mbx);
-		}
-	} while (i != iov_data->num_vfs);
+		hw->iov.ops.reset_resources(hw, vf_info);
+		vf_info->mbx.ops.connect(hw, &vf_info->mbx);
+	}
 
 read_unlock:
 	rcu_read_unlock();
-- 
2.14.2
