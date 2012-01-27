From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/11] e1000e: disable Early Receive DMA on ICH LOMs
Date: Thu, 26 Jan 2012 19:08:39 -0800
Message-ID: <1327633729-14086-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1327633729-14086-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:64222 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752818Ab2A0DIy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jan 2012 22:08:54 -0500
In-Reply-To: <1327633729-14086-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Internal stress testing with jumbo frames shows the reliability of ICH9 and
ICH10D devices is improved in certain corner cases by disabling the Early
Receive feature. To reduce the performance impact caused by disabling this
feature, the packet buffer sizes and relevant flow control settings are
modified accordingly.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/e1000.h   |    2 +-
 drivers/net/ethernet/intel/e1000e/ich8lan.c |    2 -
 drivers/net/ethernet/intel/e1000e/netdev.c  |   60 +++++++++++----------------
 3 files changed, 25 insertions(+), 39 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/e1000.h b/drivers/net/ethernet/intel/e1000e/e1000.h
index 4b3a276..70bc9e9 100644
--- a/drivers/net/ethernet/intel/e1000e/e1000.h
+++ b/drivers/net/ethernet/intel/e1000e/e1000.h
@@ -420,7 +420,7 @@ struct e1000_info {
 #define FLAG_HAS_FLASH                    (1 << 1)
 #define FLAG_HAS_HW_VLAN_FILTER           (1 << 2)
 #define FLAG_HAS_WOL                      (1 << 3)
-#define FLAG_HAS_ERT                      (1 << 4)
+/* reserved bit4 */
 #define FLAG_HAS_CTRLEXT_ON_LOAD          (1 << 5)
 #define FLAG_HAS_SWSM_ON_LOAD             (1 << 6)
 #define FLAG_HAS_JUMBO_FRAMES             (1 << 7)
diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index 1b69c2d..e446e05 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -4110,7 +4110,6 @@ const struct e1000_info e1000_ich9_info = {
 				  | FLAG_HAS_WOL
 				  | FLAG_HAS_CTRLEXT_ON_LOAD
 				  | FLAG_HAS_AMT
-				  | FLAG_HAS_ERT
 				  | FLAG_HAS_FLASH
 				  | FLAG_APME_IN_WUC,
 	.pba			= 10,
@@ -4128,7 +4127,6 @@ const struct e1000_info e1000_ich10_info = {
 				  | FLAG_HAS_WOL
 				  | FLAG_HAS_CTRLEXT_ON_LOAD
 				  | FLAG_HAS_AMT
-				  | FLAG_HAS_ERT
 				  | FLAG_HAS_FLASH
 				  | FLAG_APME_IN_WUC,
 	.pba			= 10,
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 89af6c0..49b5ded 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -2947,8 +2947,7 @@ static void e1000_setup_rctl(struct e1000_adapter *adapter)
 	 * per packet.
 	 */
 	pages = PAGE_USE_COUNT(adapter->netdev->mtu);
-	if (!(adapter->flags & FLAG_HAS_ERT) && (pages <= 3) &&
-	    (PAGE_SIZE <= 16384) && (rctl & E1000_RCTL_LPE))
+	if ((pages <= 3) && (PAGE_SIZE <= 16384) && (rctl & E1000_RCTL_LPE))
 		adapter->rx_ps_pages = pages;
 	else
 		adapter->rx_ps_pages = 0;
@@ -3095,23 +3094,14 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
 	}
 	ew32(RXCSUM, rxcsum);
 
-	/*
-	 * Enable early receives on supported devices, only takes effect when
-	 * packet size is equal or larger than the specified value (in 8 byte
-	 * units), e.g. using jumbo frames when setting to E1000_ERT_2048
-	 */
-	if ((adapter->flags & FLAG_HAS_ERT) ||
-	    (adapter->hw.mac.type == e1000_pch2lan)) {
+	if (adapter->hw.mac.type == e1000_pch2lan) {
+		/*
+		 * With jumbo frames, excessive C-state transition
+		 * latencies result in dropped transactions.
+		 */
 		if (adapter->netdev->mtu > ETH_DATA_LEN) {
 			u32 rxdctl = er32(RXDCTL(0));
 			ew32(RXDCTL(0), rxdctl | 0x3);
-			if (adapter->flags & FLAG_HAS_ERT)
-				ew32(ERT, E1000_ERT_2048 | (1 << 13));
-			/*
-			 * With jumbo frames and early-receive enabled,
-			 * excessive C-state transition latencies result in
-			 * dropped transactions.
-			 */
 			pm_qos_update_request(&adapter->netdev->pm_qos_req, 55);
 		} else {
 			pm_qos_update_request(&adapter->netdev->pm_qos_req,
@@ -3422,9 +3412,7 @@ void e1000e_reset(struct e1000_adapter *adapter)
 			 * if short on Rx space, Rx wins and must trump Tx
 			 * adjustment or use Early Receive if available
 			 */
-			if ((pba < min_rx_space) &&
-			    (!(adapter->flags & FLAG_HAS_ERT)))
-				/* ERT enabled in e1000_configure_rx */
+			if (pba < min_rx_space)
 				pba = min_rx_space;
 		}
 
@@ -3438,8 +3426,6 @@ void e1000e_reset(struct e1000_adapter *adapter)
 	 * (or the size used for early receive) above it in the Rx FIFO.
 	 * Set it to the lower of:
 	 * - 90% of the Rx FIFO size, and
-	 * - the full Rx FIFO size minus the early receive size (for parts
-	 *   with ERT support assuming ERT set to E1000_ERT_2048), or
 	 * - the full Rx FIFO size minus one full frame
 	 */
 	if (adapter->flags & FLAG_DISABLE_FC_PAUSE_TIME)
@@ -3450,14 +3436,19 @@ void e1000e_reset(struct e1000_adapter *adapter)
 	fc->current_mode = fc->requested_mode;
 
 	switch (hw->mac.type) {
+	case e1000_ich9lan:
+	case e1000_ich10lan:
+		if (adapter->netdev->mtu > ETH_DATA_LEN) {
+			pba = 14;
+			ew32(PBA, pba);
+			fc->high_water = 0x2800;
+			fc->low_water = fc->high_water - 8;
+			break;
+		}
+		/* fall-through */
 	default:
-		if ((adapter->flags & FLAG_HAS_ERT) &&
-		    (adapter->netdev->mtu > ETH_DATA_LEN))
-			hwm = min(((pba << 10) * 9 / 10),
-				  ((pba << 10) - (E1000_ERT_2048 << 3)));
-		else
-			hwm = min(((pba << 10) * 9 / 10),
-				  ((pba << 10) - adapter->max_frame_size));
+		hwm = min(((pba << 10) * 9 / 10),
+			  ((pba << 10) - adapter->max_frame_size));
 
 		fc->high_water = hwm & E1000_FCRTH_RTH; /* 8-byte granularity */
 		fc->low_water = fc->high_water - 8;
@@ -3490,11 +3481,10 @@ void e1000e_reset(struct e1000_adapter *adapter)
 
 	/*
 	 * Disable Adaptive Interrupt Moderation if 2 full packets cannot
-	 * fit in receive buffer and early-receive not supported.
+	 * fit in receive buffer.
 	 */
 	if (adapter->itr_setting & 0x3) {
-		if (((adapter->max_frame_size * 2) > (pba << 10)) &&
-		    !(adapter->flags & FLAG_HAS_ERT)) {
+		if ((adapter->max_frame_size * 2) > (pba << 10)) {
 			if (!(adapter->flags2 & FLAG2_DISABLE_AIM)) {
 				dev_info(&adapter->pdev->dev,
 					"Interrupt Throttle Rate turned off\n");
@@ -3862,9 +3852,8 @@ static int e1000_open(struct net_device *netdev)
 	     E1000_MNG_DHCP_COOKIE_STATUS_VLAN))
 		e1000_update_mng_vlan(adapter);
 
-	/* DMA latency requirement to workaround early-receive/jumbo issue */
-	if ((adapter->flags & FLAG_HAS_ERT) ||
-	    (adapter->hw.mac.type == e1000_pch2lan))
+	/* DMA latency requirement to workaround jumbo issue */
+	if (adapter->hw.mac.type == e1000_pch2lan)
 		pm_qos_add_request(&adapter->netdev->pm_qos_req,
 				   PM_QOS_CPU_DMA_LATENCY,
 				   PM_QOS_DEFAULT_VALUE);
@@ -3975,8 +3964,7 @@ static int e1000_close(struct net_device *netdev)
 	    !test_bit(__E1000_TESTING, &adapter->state))
 		e1000e_release_hw_control(adapter);
 
-	if ((adapter->flags & FLAG_HAS_ERT) ||
-	    (adapter->hw.mac.type == e1000_pch2lan))
+	if (adapter->hw.mac.type == e1000_pch2lan)
 		pm_qos_remove_request(&adapter->netdev->pm_qos_req);
 
 	pm_runtime_put_sync(&pdev->dev);
-- 
1.7.7.6
