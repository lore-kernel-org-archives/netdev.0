From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/17] fm10k: re-map all possible VF queues after a VFLR
Date: Tue, 16 Jun 2015 06:47:23 -0700
Message-ID: <1434462448-140563-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1434462448-140563-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Matthew Vick <matthew.vick@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:62774 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756712AbbFPNrg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jun 2015 09:47:36 -0400
In-Reply-To: <1434462448-140563-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

During initialization, the VF counts its rings by walking the TQDLOC
registers. This works only if the TQMAP/RQMAP registers are set to map
all of the out-of-bound rings back to the first one. This allows the VF
to cleanly detect when it has run out of queues. Update the PF code so
that it resets the empty TQMAP/RQMAP registers post-VFLR to prevent
innocent VF drivers from triggering malicious driver events.

Signed-off-by: Matthew Vick <matthew.vick@intel.com>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
index 891e218..3b94206 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
@@ -1046,6 +1046,12 @@ static s32 fm10k_iov_reset_resources_pf(struct fm10k_hw *hw,
 		fm10k_write_reg(hw, FM10K_RQMAP(qmap_idx + i), vf_q_idx + i);
 	}
 
+	/* repeat the first ring for all the remaining VF rings */
+	for (i = queues_per_pool; i < qmap_stride; i++) {
+		fm10k_write_reg(hw, FM10K_TQMAP(qmap_idx + 1), vf_q_idx);
+		fm10k_write_reg(hw, FM10K_RQMAP(qmap_idx + 1), vf_q_idx);
+	}
+
 	return 0;
 }
 
-- 
2.4.3
