From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 6/8] ixgbe add thermal sensor support for x540 hardware
Date: Wed, 28 Sep 2011 23:30:14 -0700
Message-ID: <1317277816-6024-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1317277816-6024-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:37696 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751175Ab1I2GaW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Sep 2011 02:30:22 -0400
In-Reply-To: <1317277816-6024-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Add code to enable thermal sensors for the x540 hardware, as well as a
thermal interrupt check which will exit with a critical message of a
thermal overheat is detected. Intent of code allows other mac types to
be added with different configuration in the future.

Fixed in this version is the addition of setting the temp_sensor
capable flag which was previously only set for a specific mac.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   66 ++++++++++++++++++-------
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h |    2 +
 2 files changed, 50 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index ba703d3..79636ea 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1751,6 +1751,39 @@ static void ixgbe_check_fan_failure(struct ixgbe_adapter *adapter, u32 eicr)
 	}
 }
 
+static void ixgbe_check_overtemp_event(struct ixgbe_adapter *adapter, u32 eicr)
+{
+	if (!(adapter->flags2 & IXGBE_FLAG2_TEMP_SENSOR_CAPABLE))
+		return;
+
+	switch (adapter->hw.mac.type) {
+	case ixgbe_mac_82599EB:
+		/*
+		 * Need to check link state so complete overtemp check
+		 * on service task
+		 */
+		if (((eicr & IXGBE_EICR_GPI_SDP0) || (eicr & IXGBE_EICR_LSC)) &&
+		    (!test_bit(__IXGBE_DOWN, &adapter->state))) {
+			adapter->interrupt_event = eicr;
+			adapter->flags2 |= IXGBE_FLAG2_TEMP_SENSOR_EVENT;
+			ixgbe_service_event_schedule(adapter);
+			return;
+		}
+		return;
+	case ixgbe_mac_X540:
+		if (!(eicr & IXGBE_EICR_TS))
+			return;
+		break;
+	default:
+		return;
+	}
+
+	e_crit(drv,
+	       "Network adapter has been stopped because it has over heated. "
+	       "Restart the computer. If the problem persists, "
+	       "power off the system and replace the adapter\n");
+}
+
 static void ixgbe_check_sfp_event(struct ixgbe_adapter *adapter, u32 eicr)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
@@ -1854,7 +1887,16 @@ static inline void ixgbe_irq_enable(struct ixgbe_adapter *adapter, bool queues,
 		mask &= ~IXGBE_EIMS_LSC;
 
 	if (adapter->flags2 & IXGBE_FLAG2_TEMP_SENSOR_CAPABLE)
-		mask |= IXGBE_EIMS_GPI_SDP0;
+		switch (adapter->hw.mac.type) {
+		case ixgbe_mac_82599EB:
+			mask |= IXGBE_EIMS_GPI_SDP0;
+			break;
+		case ixgbe_mac_X540:
+			mask |= IXGBE_EIMS_TS;
+			break;
+		default:
+			break;
+		}
 	if (adapter->flags & IXGBE_FLAG_FAN_FAIL_CAPABLE)
 		mask |= IXGBE_EIMS_GPI_SDP1;
 	switch (adapter->hw.mac.type) {
@@ -1924,14 +1966,7 @@ static irqreturn_t ixgbe_msix_other(int irq, void *data)
 			}
 		}
 		ixgbe_check_sfp_event(adapter, eicr);
-		if ((adapter->flags2 & IXGBE_FLAG2_TEMP_SENSOR_CAPABLE) &&
-		    ((eicr & IXGBE_EICR_GPI_SDP0) || (eicr & IXGBE_EICR_LSC))) {
-			if (!test_bit(__IXGBE_DOWN, &adapter->state)) {
-				adapter->interrupt_event = eicr;
-				adapter->flags2 |= IXGBE_FLAG2_TEMP_SENSOR_EVENT;
-				ixgbe_service_event_schedule(adapter);
-			}
-		}
+		ixgbe_check_overtemp_event(adapter, eicr);
 		break;
 	default:
 		break;
@@ -2140,15 +2175,9 @@ static irqreturn_t ixgbe_intr(int irq, void *data)
 
 	switch (hw->mac.type) {
 	case ixgbe_mac_82599EB:
+	case ixgbe_mac_X540:
 		ixgbe_check_sfp_event(adapter, eicr);
-		if ((adapter->flags2 & IXGBE_FLAG2_TEMP_SENSOR_CAPABLE) &&
-		    ((eicr & IXGBE_EICR_GPI_SDP0) || (eicr & IXGBE_EICR_LSC))) {
-			if (!test_bit(__IXGBE_DOWN, &adapter->state)) {
-				adapter->interrupt_event = eicr;
-				adapter->flags2 |= IXGBE_FLAG2_TEMP_SENSOR_EVENT;
-				ixgbe_service_event_schedule(adapter);
-			}
-		}
+		ixgbe_check_overtemp_event(adapter, eicr);
 		break;
 	default:
 		break;
@@ -4913,8 +4942,9 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 			adapter->flags |= IXGBE_FLAG_FAN_FAIL_CAPABLE;
 		adapter->max_msix_q_vectors = MAX_MSIX_Q_VECTORS_82598;
 		break;
-	case ixgbe_mac_82599EB:
 	case ixgbe_mac_X540:
+		adapter->flags2 |= IXGBE_FLAG2_TEMP_SENSOR_CAPABLE;
+	case ixgbe_mac_82599EB:
 		adapter->max_msix_q_vectors = MAX_MSIX_Q_VECTORS_82599;
 		adapter->flags2 |= IXGBE_FLAG2_RSC_CAPABLE;
 		adapter->flags2 |= IXGBE_FLAG2_RSC_ENABLED;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index 16dd461..838847c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -1280,6 +1280,7 @@ enum {
 #define IXGBE_EICR_LSC          0x00100000 /* Link Status Change */
 #define IXGBE_EICR_LINKSEC      0x00200000 /* PN Threshold */
 #define IXGBE_EICR_MNG          0x00400000 /* Manageability Event Interrupt */
+#define IXGBE_EICR_TS           0x00800000 /* Thermal Sensor Event */
 #define IXGBE_EICR_GPI_SDP0     0x01000000 /* Gen Purpose Interrupt on SDP0 */
 #define IXGBE_EICR_GPI_SDP1     0x02000000 /* Gen Purpose Interrupt on SDP1 */
 #define IXGBE_EICR_GPI_SDP2     0x04000000 /* Gen Purpose Interrupt on SDP2 */
@@ -1314,6 +1315,7 @@ enum {
 #define IXGBE_EIMS_MAILBOX      IXGBE_EICR_MAILBOX   /* VF to PF Mailbox Int */
 #define IXGBE_EIMS_LSC          IXGBE_EICR_LSC       /* Link Status Change */
 #define IXGBE_EIMS_MNG          IXGBE_EICR_MNG       /* MNG Event Interrupt */
+#define IXGBE_EIMS_TS           IXGBE_EICR_TS        /* Thermel Sensor Event */
 #define IXGBE_EIMS_GPI_SDP0     IXGBE_EICR_GPI_SDP0  /* SDP0 Gen Purpose Int */
 #define IXGBE_EIMS_GPI_SDP1     IXGBE_EICR_GPI_SDP1  /* SDP1 Gen Purpose Int */
 #define IXGBE_EIMS_GPI_SDP2     IXGBE_EICR_GPI_SDP2  /* SDP2 Gen Purpose Int */
-- 
1.7.6.2
