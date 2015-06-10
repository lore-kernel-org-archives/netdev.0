From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/18] ixgbe: add support for interrupts from X550 external PHY
Date: Tue,  9 Jun 2015 18:10:20 -0700
Message-ID: <1433898629-76729-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1433898629-76729-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:59836 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933156AbbFJBKt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jun 2015 21:10:49 -0400
In-Reply-To: <1433898629-76729-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

This patch adds support for receiving interrupts from a external copper
PHY for the X550 part.  This includes enabling, detection as well as
re-enablement.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 32 +++++++++++++++++++++++++++
 2 files changed, 33 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 636f9e3..ac3ac2a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -643,6 +643,7 @@ struct ixgbe_adapter {
 #define IXGBE_FLAG2_RSS_FIELD_IPV4_UDP		(u32)(1 << 8)
 #define IXGBE_FLAG2_RSS_FIELD_IPV6_UDP		(u32)(1 << 9)
 #define IXGBE_FLAG2_PTP_PPS_ENABLED		(u32)(1 << 10)
+#define IXGBE_FLAG2_PHY_INTERRUPT		(u32)(1 << 11)
 
 	/* Tx fast path data */
 	int num_tx_queues;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 30adfb8..1c3477a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2388,6 +2388,8 @@ static void ixgbe_check_overtemp_subtask(struct ixgbe_adapter *adapter)
 
 		break;
 	default:
+		if (adapter->hw.mac.type >= ixgbe_mac_X540)
+			return;
 		if (!(eicr & IXGBE_EICR_GPI_SDP0(hw)))
 			return;
 		break;
@@ -2572,6 +2574,8 @@ static inline void ixgbe_irq_enable(struct ixgbe_adapter *adapter, bool queues,
 	case ixgbe_mac_X540:
 	case ixgbe_mac_X550:
 	case ixgbe_mac_X550EM_x:
+		if (adapter->hw.phy.type == ixgbe_phy_x550em_ext_t)
+			mask |= IXGBE_EICR_GPI_SDP0_X540;
 		mask |= IXGBE_EIMS_ECC;
 		mask |= IXGBE_EIMS_MAILBOX;
 		break;
@@ -2626,6 +2630,13 @@ static irqreturn_t ixgbe_msix_other(int irq, void *data)
 	case ixgbe_mac_X540:
 	case ixgbe_mac_X550:
 	case ixgbe_mac_X550EM_x:
+		if (hw->phy.type == ixgbe_phy_x550em_ext_t &&
+		    (eicr & IXGBE_EICR_GPI_SDP0_X540)) {
+			adapter->flags2 |= IXGBE_FLAG2_PHY_INTERRUPT;
+			ixgbe_service_event_schedule(adapter);
+			IXGBE_WRITE_REG(hw, IXGBE_EICR,
+					IXGBE_EICR_GPI_SDP0_X540);
+		}
 		if (eicr & IXGBE_EICR_ECC) {
 			e_info(link, "Received ECC Err, initiating reset\n");
 			adapter->flags2 |= IXGBE_FLAG2_RESET_REQUESTED;
@@ -6733,6 +6744,26 @@ static void ixgbe_service_timer(unsigned long data)
 	ixgbe_service_event_schedule(adapter);
 }
 
+static void ixgbe_phy_interrupt_subtask(struct ixgbe_adapter *adapter)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	u32 status;
+
+	if (!(adapter->flags2 & IXGBE_FLAG2_PHY_INTERRUPT))
+		return;
+
+	adapter->flags2 &= ~IXGBE_FLAG2_PHY_INTERRUPT;
+
+	if (!hw->phy.ops.handle_lasi)
+		return;
+
+	status = hw->phy.ops.handle_lasi(&adapter->hw);
+	if (status != IXGBE_ERR_OVERTEMP)
+		return;
+
+	e_crit(drv, "%s\n", ixgbe_overheat_msg);
+}
+
 static void ixgbe_reset_subtask(struct ixgbe_adapter *adapter)
 {
 	if (!(adapter->flags2 & IXGBE_FLAG2_RESET_REQUESTED))
@@ -6774,6 +6805,7 @@ static void ixgbe_service_task(struct work_struct *work)
 		return;
 	}
 	ixgbe_reset_subtask(adapter);
+	ixgbe_phy_interrupt_subtask(adapter);
 	ixgbe_sfp_detection_subtask(adapter);
 	ixgbe_sfp_link_config_subtask(adapter);
 	ixgbe_check_overtemp_subtask(adapter);
-- 
2.4.2
