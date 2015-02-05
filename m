From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/16] ixgbevf: Fix ordering of shutdown to correctly disable Rx and Tx
Date: Thu,  5 Feb 2015 01:35:46 -0800
Message-ID: <1423128950-12388-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1423128950-12388-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:55144 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756856AbbBEJgI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Feb 2015 04:36:08 -0500
In-Reply-To: <1423128950-12388-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch updates the ordering of the shutdown path so that we attempt to
shutdown the rings more gracefully. Basically the big changes are that we
shutdown the main Rx filter in the case of Rx and we set the carrier_off
state in the case of Tx so that packets stop being delivered from outside
the driver.  Then we shut down interrupts and NAPI.  Finally we stop the
rings from performing DMA and clean them.  This is a bit more graceful than
the previous path.

CC: Alexander Duyck <alexander.h.duyck@redhat.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 38 ++++++++++-------------
 1 file changed, 17 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index b1d25fd..9281685 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -1957,6 +1957,10 @@ static void ixgbevf_up_complete(struct ixgbevf_adapter *adapter)
 	clear_bit(__IXGBEVF_DOWN, &adapter->state);
 	ixgbevf_napi_enable_all(adapter);
 
+	/* clear any pending interrupts, may auto mask */
+	IXGBE_READ_REG(hw, IXGBE_VTEICR);
+	ixgbevf_irq_enable(adapter);
+
 	/* enable transmits */
 	netif_tx_start_all_queues(netdev);
 
@@ -1969,16 +1973,9 @@ static void ixgbevf_up_complete(struct ixgbevf_adapter *adapter)
 
 void ixgbevf_up(struct ixgbevf_adapter *adapter)
 {
-	struct ixgbe_hw *hw = &adapter->hw;
-
 	ixgbevf_configure(adapter);
 
 	ixgbevf_up_complete(adapter);
-
-	/* clear any pending interrupts, may auto mask */
-	IXGBE_READ_REG(hw, IXGBE_VTEICR);
-
-	ixgbevf_irq_enable(adapter);
 }
 
 /**
@@ -2085,17 +2082,20 @@ void ixgbevf_down(struct ixgbevf_adapter *adapter)
 	for (i = 0; i < adapter->num_rx_queues; i++)
 		ixgbevf_disable_rx_queue(adapter, adapter->rx_ring[i]);
 
-	netif_tx_disable(netdev);
-
-	msleep(10);
+	usleep_range(10000, 20000);
 
 	netif_tx_stop_all_queues(netdev);
 
+	/* call carrier off first to avoid false dev_watchdog timeouts */
+	netif_carrier_off(netdev);
+	netif_tx_disable(netdev);
+
 	ixgbevf_irq_disable(adapter);
 
 	ixgbevf_napi_disable_all(adapter);
 
 	del_timer_sync(&adapter->watchdog_timer);
+
 	/* can't call flush scheduled work here because it can deadlock
 	 * if linkwatch_event tries to acquire the rtnl_lock which we are
 	 * holding */
@@ -2110,8 +2110,6 @@ void ixgbevf_down(struct ixgbevf_adapter *adapter)
 				IXGBE_TXDCTL_SWFLSH);
 	}
 
-	netif_carrier_off(netdev);
-
 	if (!pci_channel_offline(adapter->pdev))
 		ixgbevf_reset(adapter);
 
@@ -2995,10 +2993,6 @@ static int ixgbevf_open(struct net_device *netdev)
 	if (!adapter->num_msix_vectors)
 		return -ENOMEM;
 
-	/* disallow open during test */
-	if (test_bit(__IXGBEVF_TESTING, &adapter->state))
-		return -EBUSY;
-
 	if (hw->adapter_stopped) {
 		ixgbevf_reset(adapter);
 		/* if adapter is still stopped then PF isn't up and
@@ -3011,6 +3005,12 @@ static int ixgbevf_open(struct net_device *netdev)
 		}
 	}
 
+	/* disallow open during test */
+	if (test_bit(__IXGBEVF_TESTING, &adapter->state))
+		return -EBUSY;
+
+	netif_carrier_off(netdev);
+
 	/* allocate transmit descriptors */
 	err = ixgbevf_setup_all_tx_resources(adapter);
 	if (err)
@@ -3030,15 +3030,11 @@ static int ixgbevf_open(struct net_device *netdev)
 	 */
 	ixgbevf_map_rings_to_vectors(adapter);
 
-	ixgbevf_up_complete(adapter);
-
-	/* clear any pending interrupts, may auto mask */
-	IXGBE_READ_REG(hw, IXGBE_VTEICR);
 	err = ixgbevf_request_irq(adapter);
 	if (err)
 		goto err_req_irq;
 
-	ixgbevf_irq_enable(adapter);
+	ixgbevf_up_complete(adapter);
 
 	return 0;
 
-- 
1.9.3
