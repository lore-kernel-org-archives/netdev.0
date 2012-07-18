From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/6] ixgbe: Handle failures in the ixgbe_setup_rx/tx_resources calls
Date: Tue, 17 Jul 2012 19:20:41 -0700
Message-ID: <1342578045-17778-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1342578045-17778-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:6702 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752087Ab2GRCUu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jul 2012 22:20:50 -0400
In-Reply-To: <1342578045-17778-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Previously we were exiting without cleaning up the memory internally on the
ixgbe_setup_rx_resources and ixgbe_setup_tx_resources calls.  Instead of
forcing the caller to clean things up for us we should instead just unwind
the rings and free the memory as we go.  This way we can more gracefully
clean up the rings in the event of an allocation failure.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   20 ++++++++++++++++----
 1 file changed, 16 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 17f46f0..373342f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -4549,10 +4549,16 @@ static int ixgbe_setup_all_tx_resources(struct ixgbe_adapter *adapter)
 		err = ixgbe_setup_tx_resources(adapter->tx_ring[i]);
 		if (!err)
 			continue;
+
 		e_err(probe, "Allocation for Tx Queue %u failed\n", i);
-		break;
+		goto err_setup_tx;
 	}
 
+	return 0;
+err_setup_tx:
+	/* rewind the index freeing the rings as we go */
+	while (i--)
+		ixgbe_free_tx_resources(adapter->tx_ring[i]);
 	return err;
 }
 
@@ -4627,10 +4633,16 @@ static int ixgbe_setup_all_rx_resources(struct ixgbe_adapter *adapter)
 		err = ixgbe_setup_rx_resources(adapter->rx_ring[i]);
 		if (!err)
 			continue;
+
 		e_err(probe, "Allocation for Rx Queue %u failed\n", i);
-		break;
+		goto err_setup_rx;
 	}
 
+	return 0;
+err_setup_rx:
+	/* rewind the index freeing the rings as we go */
+	while (i--)
+		ixgbe_free_rx_resources(adapter->rx_ring[i]);
 	return err;
 }
 
@@ -4791,10 +4803,10 @@ static int ixgbe_open(struct net_device *netdev)
 	return 0;
 
 err_req_irq:
-err_setup_rx:
 	ixgbe_free_all_rx_resources(adapter);
-err_setup_tx:
+err_setup_rx:
 	ixgbe_free_all_tx_resources(adapter);
+err_setup_tx:
 	ixgbe_reset(adapter);
 
 	return err;
-- 
1.7.10.4
