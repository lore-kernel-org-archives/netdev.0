From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/17] fm10k: reset max_queues on init_hw_vf failure
Date: Thu,  3 Dec 2015 16:29:40 -0800
Message-ID: <1449188994-64940-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449188994-64940-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:14336 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754287AbbLDA34 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 19:29:56 -0500
In-Reply-To: <1449188994-64940-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

VF drivers must detect how many queues are available. Previously, the
driver assumed that each VF has at minimum 1 queue. This assumption is
incorrect, since it is possible that the PF has not yet assigned the
queues to the VF by the time the VF checks. To resolve this, we added a
check first to ensure that the first queue is infact owned by the VF at
init_hw_vf time. However, the code flow did not reset hw->mac.max_queues
to 0. In some cases, such as during reinit flows, we call init_hw_vf
without clearing the previous value of hw->mac.max_queues. Due to this,
when init_hw_vf errors out, if its error code is not properly handled
the VF driver may still believe it has queues which no longer belong to
it. Fix this by clearing the hw->mac.max_queues on exit due to errors.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Reviewed-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_vf.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_vf.c b/drivers/net/ethernet/intel/fm10k/fm10k_vf.c
index 3a18ef1..d512575 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_vf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_vf.c
@@ -105,8 +105,10 @@ static s32 fm10k_init_hw_vf(struct fm10k_hw *hw)
 
 	/* verify we have at least 1 queue */
 	if (!~fm10k_read_reg(hw, FM10K_TXQCTL(0)) ||
-	    !~fm10k_read_reg(hw, FM10K_RXQCTL(0)))
-		return FM10K_ERR_NO_RESOURCES;
+	    !~fm10k_read_reg(hw, FM10K_RXQCTL(0))) {
+		err = FM10K_ERR_NO_RESOURCES;
+		goto reset_max_queues;
+	}
 
 	/* determine how many queues we have */
 	for (i = 1; tqdloc0 && (i < FM10K_MAX_QUEUES_POOL); i++) {
@@ -124,7 +126,7 @@ static s32 fm10k_init_hw_vf(struct fm10k_hw *hw)
 	/* shut down queues we own and reset DMA configuration */
 	err = fm10k_disable_queues_generic(hw, i);
 	if (err)
-		return err;
+		goto reset_max_queues;
 
 	/* record maximum queue count */
 	hw->mac.max_queues = i;
@@ -134,6 +136,11 @@ static s32 fm10k_init_hw_vf(struct fm10k_hw *hw)
 			       FM10K_TXQCTL_VID_MASK) >> FM10K_TXQCTL_VID_SHIFT;
 
 	return 0;
+
+reset_max_queues:
+	hw->mac.max_queues = 0;
+
+	return err;
 }
 
 /* This structure defines the attibutes to be parsed below */
-- 
2.5.0
