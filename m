From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/15] ixgbe: fix lockdep annotation issue for ptp's work item
Date: Mon, 29 Jul 2013 05:52:08 -0700
Message-ID: <1375102331-23905-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1375102331-23905-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:64394 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753841Ab3G2Mwc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jul 2013 08:52:32 -0400
In-Reply-To: <1375102331-23905-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch fixes a lockdep issue created due to ixgbe_ptp_stop always running
cancel_work_sync even if the work item had not been created properly with
INIT_WORK. This is caused because ixgbe_ptp_stop did not check to actually
ensure PTP was running first. The new implementation introduces a state in the
&adapter->state field which is used to indicate that PTP is running. (This
replaces the IXGBE_FLAG2_PTP_ENABLED field). This state will use the atomic
set_bit, test_bit, and test_and_clear_bit functions. ixgbe_ptp_stop will check
to ensure that PTP was enabled, (and if not, it will not attempt to do any
cleanup work from ixgbe_ptp_init). This resolves the lockdep annotation warning
found by Stephen Hemminger

Reported-by: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Acked-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |  6 +++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  8 ++++----
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c  | 12 +++++++-----
 3 files changed, 14 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index d882278..6844f39 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -618,9 +618,8 @@ struct ixgbe_adapter {
 #define IXGBE_FLAG2_FDIR_REQUIRES_REINIT        (u32)(1 << 7)
 #define IXGBE_FLAG2_RSS_FIELD_IPV4_UDP		(u32)(1 << 8)
 #define IXGBE_FLAG2_RSS_FIELD_IPV6_UDP		(u32)(1 << 9)
-#define IXGBE_FLAG2_PTP_ENABLED			(u32)(1 << 10)
-#define IXGBE_FLAG2_PTP_PPS_ENABLED		(u32)(1 << 11)
-#define IXGBE_FLAG2_BRIDGE_MODE_VEB		(u32)(1 << 12)
+#define IXGBE_FLAG2_PTP_PPS_ENABLED		(u32)(1 << 10)
+#define IXGBE_FLAG2_BRIDGE_MODE_VEB		(u32)(1 << 11)
 
 	/* Tx fast path data */
 	int num_tx_queues;
@@ -754,6 +753,7 @@ enum ixgbe_state_t {
 	__IXGBE_DOWN,
 	__IXGBE_SERVICE_SCHED,
 	__IXGBE_IN_SFP_INIT,
+	__IXGBE_PTP_RUNNING,
 };
 
 struct ixgbe_cb {
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 5ec2b74..65c36f7 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -4432,7 +4432,7 @@ void ixgbe_reset(struct ixgbe_adapter *adapter)
 	if (hw->mac.san_mac_rar_index)
 		hw->mac.ops.set_vmdq_san_mac(hw, VMDQ_P(0));
 
-	if (adapter->flags2 & IXGBE_FLAG2_PTP_ENABLED)
+	if (test_bit(__IXGBE_PTP_RUNNING, &adapter->state))
 		ixgbe_ptp_reset(adapter);
 }
 
@@ -5761,7 +5761,7 @@ static void ixgbe_watchdog_link_is_up(struct ixgbe_adapter *adapter)
 
 	adapter->last_rx_ptp_check = jiffies;
 
-	if (adapter->flags2 & IXGBE_FLAG2_PTP_ENABLED)
+	if (test_bit(__IXGBE_PTP_RUNNING, &adapter->state))
 		ixgbe_ptp_start_cyclecounter(adapter);
 
 	e_info(drv, "NIC Link is Up %s, Flow Control: %s\n",
@@ -5807,7 +5807,7 @@ static void ixgbe_watchdog_link_is_down(struct ixgbe_adapter *adapter)
 	if (ixgbe_is_sfp(hw) && hw->mac.type == ixgbe_mac_82598EB)
 		adapter->flags2 |= IXGBE_FLAG2_SEARCH_FOR_SFP;
 
-	if (adapter->flags2 & IXGBE_FLAG2_PTP_ENABLED)
+	if (test_bit(__IXGBE_PTP_RUNNING, &adapter->state))
 		ixgbe_ptp_start_cyclecounter(adapter);
 
 	e_info(drv, "NIC Link is Down\n");
@@ -6114,7 +6114,7 @@ static void ixgbe_service_task(struct work_struct *work)
 	ixgbe_fdir_reinit_subtask(adapter);
 	ixgbe_check_hang_subtask(adapter);
 
-	if (adapter->flags2 & IXGBE_FLAG2_PTP_ENABLED) {
+	if (test_bit(__IXGBE_PTP_RUNNING, &adapter->state)) {
 		ixgbe_ptp_overflow_check(adapter);
 		ixgbe_ptp_rx_hang(adapter);
 	}
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
index 331987d..5184e2a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
@@ -885,8 +885,8 @@ void ixgbe_ptp_init(struct ixgbe_adapter *adapter)
 
 	ixgbe_ptp_reset(adapter);
 
-	/* set the flag that PTP has been enabled */
-	adapter->flags2 |= IXGBE_FLAG2_PTP_ENABLED;
+	/* enter the IXGBE_PTP_RUNNING state */
+	set_bit(__IXGBE_PTP_RUNNING, &adapter->state);
 
 	return;
 }
@@ -899,10 +899,12 @@ void ixgbe_ptp_init(struct ixgbe_adapter *adapter)
  */
 void ixgbe_ptp_stop(struct ixgbe_adapter *adapter)
 {
-	/* stop the overflow check task */
-	adapter->flags2 &= ~(IXGBE_FLAG2_PTP_ENABLED |
-			     IXGBE_FLAG2_PTP_PPS_ENABLED);
+	/* Leave the IXGBE_PTP_RUNNING state. */
+	if (!test_and_clear_bit(__IXGBE_PTP_RUNNING, &adapter->state))
+		return;
 
+	/* stop the PPS signal */
+	adapter->flags2 &= ~IXGBE_FLAG2_PTP_PPS_ENABLED;
 	ixgbe_ptp_setup_sdp(adapter);
 
 	cancel_work_sync(&adapter->ptp_tx_work);
-- 
1.7.11.7
