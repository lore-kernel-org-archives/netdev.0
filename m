From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/4] ixgbe: use atomic bitwise operations when handling reset requests
Date: Thu, 18 Aug 2016 23:03:36 -0700
Message-ID: <1471586616-64728-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1471586616-64728-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:23047 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754523AbcHSGDz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 19 Aug 2016 02:03:55 -0400
In-Reply-To: <1471586616-64728-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Use atomic bitwise operations when setting and checking reset
requests. This should help with possible races in the service task.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |  2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 16 +++++++---------
 2 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 9475ff9..5628e2d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -653,7 +653,6 @@ struct ixgbe_adapter {
 #define IXGBE_FLAG2_TEMP_SENSOR_EVENT		BIT(3)
 #define IXGBE_FLAG2_SEARCH_FOR_SFP		BIT(4)
 #define IXGBE_FLAG2_SFP_NEEDS_RESET		BIT(5)
-#define IXGBE_FLAG2_RESET_REQUESTED		BIT(6)
 #define IXGBE_FLAG2_FDIR_REQUIRES_REINIT	BIT(7)
 #define IXGBE_FLAG2_RSS_FIELD_IPV4_UDP		BIT(8)
 #define IXGBE_FLAG2_RSS_FIELD_IPV6_UDP		BIT(9)
@@ -840,6 +839,7 @@ enum ixgbe_state_t {
 	__IXGBE_IN_SFP_INIT,
 	__IXGBE_PTP_RUNNING,
 	__IXGBE_PTP_TX_IN_PROGRESS,
+	__IXGBE_RESET_REQUESTED,
 };
 
 struct ixgbe_cb {
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index bbbc5b8..6bf131f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1103,7 +1103,7 @@ static void ixgbe_tx_timeout_reset(struct ixgbe_adapter *adapter)
 
 	/* Do the reset outside of interrupt context */
 	if (!test_bit(__IXGBE_DOWN, &adapter->state)) {
-		adapter->flags2 |= IXGBE_FLAG2_RESET_REQUESTED;
+		set_bit(__IXGBE_RESET_REQUESTED, &adapter->state);
 		e_warn(drv, "initiating reset due to tx timeout\n");
 		ixgbe_service_event_schedule(adapter);
 	}
@@ -2777,7 +2777,7 @@ static irqreturn_t ixgbe_msix_other(int irq, void *data)
 		}
 		if (eicr & IXGBE_EICR_ECC) {
 			e_info(link, "Received ECC Err, initiating reset\n");
-			adapter->flags2 |= IXGBE_FLAG2_RESET_REQUESTED;
+			set_bit(__IXGBE_RESET_REQUESTED, &adapter->state);
 			ixgbe_service_event_schedule(adapter);
 			IXGBE_WRITE_REG(hw, IXGBE_EICR, IXGBE_EICR_ECC);
 		}
@@ -3007,7 +3007,7 @@ static irqreturn_t ixgbe_intr(int irq, void *data)
 	case ixgbe_mac_x550em_a:
 		if (eicr & IXGBE_EICR_ECC) {
 			e_info(link, "Received ECC Err, initiating reset\n");
-			adapter->flags2 |= IXGBE_FLAG2_RESET_REQUESTED;
+			set_bit(__IXGBE_RESET_REQUESTED, &adapter->state);
 			ixgbe_service_event_schedule(adapter);
 			IXGBE_WRITE_REG(hw, IXGBE_EICR, IXGBE_EICR_ECC);
 		}
@@ -5500,8 +5500,8 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 
 	ixgbe_napi_disable_all(adapter);
 
-	adapter->flags2 &= ~(IXGBE_FLAG2_FDIR_REQUIRES_REINIT |
-			     IXGBE_FLAG2_RESET_REQUESTED);
+	clear_bit(__IXGBE_RESET_REQUESTED, &adapter->state);
+	adapter->flags2 &= ~IXGBE_FLAG2_FDIR_REQUIRES_REINIT;
 	adapter->flags &= ~IXGBE_FLAG_NEED_LINK_UPDATE;
 
 	del_timer_sync(&adapter->service_timer);
@@ -6921,7 +6921,7 @@ static void ixgbe_watchdog_flush_tx(struct ixgbe_adapter *adapter)
 			 * (Do the reset outside of interrupt context).
 			 */
 			e_warn(drv, "initiating reset to clear Tx work after link loss\n");
-			adapter->flags2 |= IXGBE_FLAG2_RESET_REQUESTED;
+			set_bit(__IXGBE_RESET_REQUESTED, &adapter->state);
 		}
 	}
 }
@@ -7187,11 +7187,9 @@ static void ixgbe_phy_interrupt_subtask(struct ixgbe_adapter *adapter)
 
 static void ixgbe_reset_subtask(struct ixgbe_adapter *adapter)
 {
-	if (!(adapter->flags2 & IXGBE_FLAG2_RESET_REQUESTED))
+	if (!test_and_clear_bit(__IXGBE_RESET_REQUESTED, &adapter->state))
 		return;
 
-	adapter->flags2 &= ~IXGBE_FLAG2_RESET_REQUESTED;
-
 	/* If we're already down, removing or resetting, just bail */
 	if (test_bit(__IXGBE_DOWN, &adapter->state) ||
 	    test_bit(__IXGBE_REMOVING, &adapter->state) ||
-- 
2.7.4
