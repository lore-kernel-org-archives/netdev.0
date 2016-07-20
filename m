From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/20] fm10k: perform data path reset even when switch is not ready
Date: Wed, 20 Jul 2016 15:23:44 -0700
Message-ID: <1469053438-85381-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1469053438-85381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	guru.anbalagane@oracle.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:44560 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755344AbcGTWYC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2016 18:24:02 -0400
In-Reply-To: <1469053438-85381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

A while ago, an additional check for the switch being ready was added to
reset_hw. A recent refactor accidentally made this check return an error
code on failure which caused fm10k_probe to fail when the switch wasn't
brought up first. The original reasoning for the check was to prevent
additional data path reset when the fabric wasn't ready yet. However,
there isn't a compelling reason to keep the check, as the data path
reset will restore hardware to a known good state. Remove the check and
perform the data path reset regardless of the switch manager state.

An alternative fix is to return FM10K_SUCCESS instead, and bypass the
actual data path reset. This should be fine as we will perform
a reset_hw once the switch is active. However, since data path reset
will reset many parts of the hardware it seems better to just perform
the reset regardless of switch state.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
index 7fbd94b..23f3566 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
@@ -63,11 +63,6 @@ static s32 fm10k_reset_hw_pf(struct fm10k_hw *hw)
 	if (reg & (FM10K_DMA_CTRL_TX_ACTIVE | FM10K_DMA_CTRL_RX_ACTIVE))
 		return FM10K_ERR_DMA_PENDING;
 
-	/* verify the switch is ready for reset */
-	reg = fm10k_read_reg(hw, FM10K_DMA_CTRL2);
-	if (!(reg & FM10K_DMA_CTRL2_SWITCH_READY))
-		return FM10K_ERR_DMA_PENDING;
-
 force_reset:
 	/* Inititate data path reset */
 	reg = FM10K_DMA_CTRL_DATAPATH_RESET;
-- 
2.5.5
