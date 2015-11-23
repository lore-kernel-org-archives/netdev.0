From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/15] fm10k: do not assume VF always has 1 queue
Date: Mon, 23 Nov 2015 11:36:02 -0800
Message-ID: <1448307376-20063-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1448307376-20063-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:20880 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750996AbbKWTgV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2015 14:36:21 -0500
In-Reply-To: <1448307376-20063-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

It is possible that the PF has not yet assigned resources to the VF.
Although rare, this could result in the VF attempting to read queues it
does not own and result in FUM or THI faults in the PF. To prevent this,
check queue 0 before we continue in init_hw_vf.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_type.h | 1 +
 drivers/net/ethernet/intel/fm10k/fm10k_vf.c   | 7 ++++++-
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_type.h b/drivers/net/ethernet/intel/fm10k/fm10k_type.h
index 318a212..35afd71 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_type.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_type.h
@@ -77,6 +77,7 @@ struct fm10k_hw;
 #define FM10K_PCIE_SRIOV_CTRL_VFARI		0x10
 
 #define FM10K_ERR_PARAM				-2
+#define FM10K_ERR_NO_RESOURCES			-3
 #define FM10K_ERR_REQUESTS_PENDING		-4
 #define FM10K_ERR_RESET_REQUESTED		-5
 #define FM10K_ERR_DMA_PENDING			-6
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_vf.c b/drivers/net/ethernet/intel/fm10k/fm10k_vf.c
index 36c8b0a..3a18ef1 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_vf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_vf.c
@@ -103,7 +103,12 @@ static s32 fm10k_init_hw_vf(struct fm10k_hw *hw)
 	s32 err;
 	u16 i;
 
-	/* assume we always have at least 1 queue */
+	/* verify we have at least 1 queue */
+	if (!~fm10k_read_reg(hw, FM10K_TXQCTL(0)) ||
+	    !~fm10k_read_reg(hw, FM10K_RXQCTL(0)))
+		return FM10K_ERR_NO_RESOURCES;
+
+	/* determine how many queues we have */
 	for (i = 1; tqdloc0 && (i < FM10K_MAX_QUEUES_POOL); i++) {
 		/* verify the Descriptor cache offsets are increasing */
 		tqdloc = ~fm10k_read_reg(hw, FM10K_TQDLOC(i));
-- 
2.5.0
