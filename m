From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/14] igb: Move the calls to set the Tx and Rx queues into igb_open
Date: Fri, 19 Oct 2012 04:45:13 -0700
Message-ID: <1350647114-6768-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1350647114-6768-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:64516 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932526Ab2JSLpt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2012 07:45:49 -0400
In-Reply-To: <1350647114-6768-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change helps to address locking issues seen with
netif_set_real_num_tx_queues and netif_set_real_num_rx_queues when used in
the igb_set_interrupt_capability function.  To resolve these locking issues
I have moved the two function calls into __igb_open so that they can be
called while the RTNL lock is held.

An added advantage to this is that the number of queues is not updated
until the last possible moment so if there are any issues in allocating
MSI-X interrupts or resources for the rings we have time to change the
values prior to updating the netdev.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 31 ++++++++++++++++++-------------
 1 file changed, 18 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 4a25b8f..e7b1027 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -948,7 +948,7 @@ static void igb_clear_interrupt_scheme(struct igb_adapter *adapter)
  * Attempt to configure interrupts using the best available
  * capabilities of the hardware and kernel.
  **/
-static int igb_set_interrupt_capability(struct igb_adapter *adapter)
+static void igb_set_interrupt_capability(struct igb_adapter *adapter)
 {
 	int err;
 	int numvecs, i;
@@ -985,7 +985,7 @@ static int igb_set_interrupt_capability(struct igb_adapter *adapter)
 			      adapter->msix_entries,
 			      numvecs);
 	if (err == 0)
-		goto out;
+		return;
 
 	igb_reset_interrupt_capability(adapter);
 
@@ -1015,14 +1015,6 @@ msi_only:
 	adapter->num_q_vectors = 1;
 	if (!pci_enable_msi(adapter->pdev))
 		adapter->flags |= IGB_FLAG_HAS_MSI;
-out:
-	/* Notify the stack of the (possibly) reduced queue counts. */
-	rtnl_lock();
-	netif_set_real_num_tx_queues(adapter->netdev, adapter->num_tx_queues);
-	err = netif_set_real_num_rx_queues(adapter->netdev,
-		adapter->num_rx_queues);
-	rtnl_unlock();
-	return err;
 }
 
 static void igb_add_ring(struct igb_ring *ring,
@@ -1212,9 +1204,7 @@ static int igb_init_interrupt_scheme(struct igb_adapter *adapter)
 	struct pci_dev *pdev = adapter->pdev;
 	int err;
 
-	err = igb_set_interrupt_capability(adapter);
-	if (err)
-		return err;
+	igb_set_interrupt_capability(adapter);
 
 	err = igb_alloc_q_vectors(adapter);
 	if (err) {
@@ -2543,6 +2533,17 @@ static int __igb_open(struct net_device *netdev, bool resuming)
 	if (err)
 		goto err_req_irq;
 
+	/* Notify the stack of the actual queue counts. */
+	err = netif_set_real_num_tx_queues(adapter->netdev,
+					   adapter->num_tx_queues);
+	if (err)
+		goto err_set_queues;
+
+	err = netif_set_real_num_rx_queues(adapter->netdev,
+					   adapter->num_rx_queues);
+	if (err)
+		goto err_set_queues;
+
 	/* From here on the code is the same as igb_up() */
 	clear_bit(__IGB_DOWN, &adapter->state);
 
@@ -2572,6 +2573,8 @@ static int __igb_open(struct net_device *netdev, bool resuming)
 
 	return 0;
 
+err_set_queues:
+	igb_free_irq(adapter);
 err_req_irq:
 	igb_release_hw_control(adapter);
 	igb_power_down_link(adapter);
@@ -6841,7 +6844,9 @@ static int igb_resume(struct device *dev)
 	wr32(E1000_WUS, ~0);
 
 	if (netdev->flags & IFF_UP) {
+		rtnl_lock();
 		err = __igb_open(netdev, true);
+		rtnl_unlock();
 		if (err)
 			return err;
 	}
-- 
1.7.11.7
