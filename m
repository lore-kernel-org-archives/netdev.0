From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/16] fm10k: print error message when stop_hw fails
Date: Tue,  5 Apr 2016 01:01:22 -0700
Message-ID: <1459843288-40623-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459843288-40623-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:2972 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757552AbcDEICZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 04:02:25 -0400
In-Reply-To: <1459843288-40623-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

fm10k_stop_hw_generic calls fm10k_disable_queues_generic, which may
return an error code indicating that the queues were not stopped within
the time limit. Notify the user by displaying a message in the kernel
message ring, in a similar way to how we notify the user when reset_hw
fails. There isn't much we can do to recover from this error, so
currently nothing else is done.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index ed1f8cf..3c7c819 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -1656,6 +1656,7 @@ void fm10k_down(struct fm10k_intfc *interface)
 {
 	struct net_device *netdev = interface->netdev;
 	struct fm10k_hw *hw = &interface->hw;
+	int err;
 
 	/* signal that we are down to the interrupt handler and service task */
 	set_bit(__FM10K_DOWN, &interface->state);
@@ -1680,7 +1681,9 @@ void fm10k_down(struct fm10k_intfc *interface)
 	fm10k_update_stats(interface);
 
 	/* Disable DMA engine for Tx/Rx */
-	hw->mac.ops.stop_hw(hw);
+	err = hw->mac.ops.stop_hw(hw);
+	if (err)
+		dev_err(&interface->pdev->dev, "stop_hw failed: %d\n", err);
 
 	/* free any buffers still on the rings */
 	fm10k_clean_all_tx_rings(interface);
-- 
2.5.5
