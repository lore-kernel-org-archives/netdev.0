From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/11] ixgbevf: make sure probe fails on MSI-X enable error
Date: Tue, 13 Nov 2012 06:03:16 -0800
Message-ID: <1352815405-751-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1352815405-751-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jakub Kicinski <jakub.kicinski@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:8266 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754715Ab2KMOD3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2012 09:03:29 -0500
In-Reply-To: <1352815405-751-1-git-send-email-jeffrey.t.kirsher@intel.com>
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
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 26 +++++++++++------------
 1 file changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index f3d3947..a8fbe6c 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -1721,8 +1721,8 @@ void ixgbevf_reset(struct ixgbevf_adapter *adapter)
 	}
 }
 
-static void ixgbevf_acquire_msix_vectors(struct ixgbevf_adapter *adapter,
-					 int vectors)
+static int ixgbevf_acquire_msix_vectors(struct ixgbevf_adapter *adapter,
+					int vectors)
 {
 	int err, vector_threshold;
 
@@ -1740,21 +1740,18 @@ static void ixgbevf_acquire_msix_vectors(struct ixgbevf_adapter *adapter,
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
@@ -1765,6 +1762,7 @@ static void ixgbevf_acquire_msix_vectors(struct ixgbevf_adapter *adapter,
 		 */
 		adapter->num_msix_vectors = vectors;
 	}
+	return err;
 }
 
 /**
@@ -1868,7 +1866,9 @@ static int ixgbevf_set_interrupt_capability(struct ixgbevf_adapter *adapter)
 	for (vector = 0; vector < v_budget; vector++)
 		adapter->msix_entries[vector].entry = vector;
 
-	ixgbevf_acquire_msix_vectors(adapter, v_budget);
+	err = ixgbevf_acquire_msix_vectors(adapter, v_budget);
+	if (err)
+		goto out;
 
 	err = netif_set_real_num_tx_queues(netdev, adapter->num_tx_queues);
 	if (err)
-- 
1.7.11.7
