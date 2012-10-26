From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/14] ixgbevf: make sure probe fails on MSI-X enable error
Date: Fri, 26 Oct 2012 04:58:18 -0700
Message-ID: <1351252702-16532-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1351252702-16532-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jakub Kicinski <jakub.kicinski@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:34779 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932403Ab2JZL63 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Oct 2012 07:58:29 -0400
In-Reply-To: <1351252702-16532-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@intel.com>

This driver cannot work without MSI-X interrupts
so there is no mechanism to fall back to.

Signed-off-by: Jakub Kicinski <jakub.kicinski@intel.com>
Acked-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 24 +++++++++++------------
 1 file changed, 11 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index b5979ba..7ceccff 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -1711,8 +1711,8 @@ void ixgbevf_reset(struct ixgbevf_adapter *adapter)
 	}
 }
 
-static void ixgbevf_acquire_msix_vectors(struct ixgbevf_adapter *adapter,
-					 int vectors)
+static int ixgbevf_acquire_msix_vectors(struct ixgbevf_adapter *adapter,
+					int vectors)
 {
 	int err, vector_threshold;
 
@@ -1730,21 +1730,18 @@ static void ixgbevf_acquire_msix_vectors(struct ixgbevf_adapter *adapter,
 	while (vectors >= vector_threshold) {
 		err = pci_enable_msix(adapter->pdev, adapter->msix_entries,
 				      vectors);
-		if (!err) /* Success in acquiring all requested vectors. */
+		if (!err || err < 0) /* Success or a nasty failure. */
 			break;
-		else if (err < 0)
-			vectors = 0; /* Nasty failure, quit now */
 		else /* err == number of vectors we should try again with */
 			vectors = err;
 	}
 
-	if (vectors < vector_threshold) {
-		/* Can't allocate enough MSI-X interrupts?  Oh well.
-		 * This just means we'll go with either a single MSI
-		 * vector or fall back to legacy interrupts.
-		 */
-		hw_dbg(&adapter->hw,
-		       "Unable to allocate MSI-X interrupts\n");
+	if (vectors < vector_threshold)
+		err = -ENOMEM;
+
+	if (err) {
+		dev_err(&adapter->pdev->dev,
+			"Unable to allocate MSI-X interrupts\n");
 		kfree(adapter->msix_entries);
 		adapter->msix_entries = NULL;
 	} else {
@@ -1755,6 +1752,7 @@ static void ixgbevf_acquire_msix_vectors(struct ixgbevf_adapter *adapter,
 		 */
 		adapter->num_msix_vectors = vectors;
 	}
+	return err;
 }
 
 /**
@@ -1858,7 +1856,7 @@ static int ixgbevf_set_interrupt_capability(struct ixgbevf_adapter *adapter)
 	for (vector = 0; vector < v_budget; vector++)
 		adapter->msix_entries[vector].entry = vector;
 
-	ixgbevf_acquire_msix_vectors(adapter, v_budget);
+	err = ixgbevf_acquire_msix_vectors(adapter, v_budget);
 
 	err = netif_set_real_num_tx_queues(netdev, adapter->num_tx_queues);
 	if (err)
-- 
1.7.11.7
