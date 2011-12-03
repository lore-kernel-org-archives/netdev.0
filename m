From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/6] e1000e: Avoid wrong check on TX hang
Date: Sat,  3 Dec 2011 03:44:26 -0800
Message-ID: <1322912671-6903-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1322912671-6903-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Michael Wang <wangyun@linux.vnet.ibm.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Flavio Leitner <fbl@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:29132 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754527Ab1LCLoe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Dec 2011 06:44:34 -0500
In-Reply-To: <1322912671-6903-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Wang <wangyun@linux.vnet.ibm.com>

Descriptors may not be write-back while checking TX hang with flag
FLAG2_DMA_BURST on.
So when we detect hang, we just flush the descriptor and detect
again for once.

Signed-off-by: Michael Wang <wangyun@linux.vnet.ibm.com>
Signed-off-by: Flavio Leitner <fbl@redhat.com>
Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/e1000.h  |    1 +
 drivers/net/ethernet/intel/e1000e/netdev.c |   23 ++++++++++++++++++++---
 2 files changed, 21 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/e1000.h b/drivers/net/ethernet/intel/e1000e/e1000.h
index 9fe18d1..f478a22 100644
--- a/drivers/net/ethernet/intel/e1000e/e1000.h
+++ b/drivers/net/ethernet/intel/e1000e/e1000.h
@@ -309,6 +309,7 @@ struct e1000_adapter {
 	u32 txd_cmd;
 
 	bool detect_tx_hung;
+	bool tx_hang_recheck;
 	u8 tx_timeout_factor;
 
 	u32 tx_int_delay;
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index c6e9763..3c12e6a 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -1014,6 +1014,7 @@ static void e1000_print_hw_hang(struct work_struct *work)
 	struct e1000_adapter *adapter = container_of(work,
 	                                             struct e1000_adapter,
 	                                             print_hang_task);
+	struct net_device *netdev = adapter->netdev;
 	struct e1000_ring *tx_ring = adapter->tx_ring;
 	unsigned int i = tx_ring->next_to_clean;
 	unsigned int eop = tx_ring->buffer_info[i].next_to_watch;
@@ -1025,6 +1026,21 @@ static void e1000_print_hw_hang(struct work_struct *work)
 	if (test_bit(__E1000_DOWN, &adapter->state))
 		return;
 
+	if ((!adapter->tx_hang_recheck) &&
+	    (adapter->flags2 & FLAG2_DMA_BURST)) {
+		/* May be block on write-back, flush and detect again
+		 * flush pending descriptor writebacks to memory
+		 */
+		ew32(TIDV, adapter->tx_int_delay | E1000_TIDV_FPD);
+		/* execute the writes immediately */
+		e1e_flush();
+		adapter->tx_hang_recheck = 1;
+		return;
+	}
+	/* Real hang detected */
+	adapter->tx_hang_recheck = 0;
+	netif_stop_queue(netdev);
+
 	e1e_rphy(hw, PHY_STATUS, &phy_status);
 	e1e_rphy(hw, PHY_1000T_STATUS, &phy_1000t_status);
 	e1e_rphy(hw, PHY_EXT_STATUS, &phy_ext_status);
@@ -1145,10 +1161,10 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter)
 		if (tx_ring->buffer_info[i].time_stamp &&
 		    time_after(jiffies, tx_ring->buffer_info[i].time_stamp
 			       + (adapter->tx_timeout_factor * HZ)) &&
-		    !(er32(STATUS) & E1000_STATUS_TXOFF)) {
+		    !(er32(STATUS) & E1000_STATUS_TXOFF))
 			schedule_work(&adapter->print_hang_task);
-			netif_stop_queue(netdev);
-		}
+		else
+			adapter->tx_hang_recheck = 0;
 	}
 	adapter->total_tx_bytes += total_tx_bytes;
 	adapter->total_tx_packets += total_tx_packets;
@@ -3838,6 +3854,7 @@ static int e1000_open(struct net_device *netdev)
 
 	e1000_irq_enable(adapter);
 
+	adapter->tx_hang_recheck = 0;
 	netif_start_queue(netdev);
 
 	adapter->idle_check = true;
-- 
1.7.6.4
