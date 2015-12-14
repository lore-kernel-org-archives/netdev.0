From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/15] fm10k: Cleanup exception handling for mailbox interrupt
Date: Sun, 13 Dec 2015 16:27:41 -0800
Message-ID: <1450052867-36654-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1450052867-36654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:65123 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752035AbbLNA1v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Dec 2015 19:27:51 -0500
In-Reply-To: <1450052867-36654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

This patch addresses two issues.

First is the fact that the fm10k_mbx_free_irq was assuming msix_entries was
valid and that will not always be the case.  As such we need to add a check
for if it is NULL.

Second is the fact that we weren't freeing the IRQ if the mailbox API
returned an error on trying to connect.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Reviewed-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index b9ed94a..694c648 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -1124,6 +1124,10 @@ void fm10k_mbx_free_irq(struct fm10k_intfc *interface)
 	struct fm10k_hw *hw = &interface->hw;
 	int itr_reg;
 
+	/* no mailbox IRQ to free if MSI-X is not enabled */
+	if (!interface->msix_entries)
+		return;
+
 	/* disconnect the mailbox */
 	hw->mbx.ops.disconnect(hw, &hw->mbx);
 
@@ -1446,10 +1450,15 @@ int fm10k_mbx_request_irq(struct fm10k_intfc *interface)
 		err = fm10k_mbx_request_irq_pf(interface);
 	else
 		err = fm10k_mbx_request_irq_vf(interface);
+	if (err)
+		return err;
 
 	/* connect mailbox */
-	if (!err)
-		err = hw->mbx.ops.connect(hw, &hw->mbx);
+	err = hw->mbx.ops.connect(hw, &hw->mbx);
+
+	/* if the mailbox failed to connect, then free IRQ */
+	if (err)
+		fm10k_mbx_free_irq(interface);
 
 	return err;
 }
-- 
2.5.0
