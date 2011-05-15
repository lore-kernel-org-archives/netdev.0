From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 10/13] ixgbe: Merge over-temp task into service task
Date: Sat, 14 May 2011 18:23:44 -0700
Message-ID: <1305422627-9583-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1305422627-9583-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:1031 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759564Ab1EOBXx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 May 2011 21:23:53 -0400
In-Reply-To: <1305422627-9583-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change merges the over-temp task into the service task.  As a result
all tasklets are finally combined into once single tasklet for easier
management.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe.h      |    2 +-
 drivers/net/ixgbe/ixgbe_main.c |   87 ++++++++++++++++++++++++----------------
 2 files changed, 53 insertions(+), 36 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index a180cde..e467b20 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -379,6 +379,7 @@ struct ixgbe_adapter {
 #define IXGBE_FLAG2_RSC_CAPABLE                 (u32)(1)
 #define IXGBE_FLAG2_RSC_ENABLED                 (u32)(1 << 1)
 #define IXGBE_FLAG2_TEMP_SENSOR_CAPABLE         (u32)(1 << 2)
+#define IXGBE_FLAG2_TEMP_SENSOR_EVENT           (u32)(1 << 3)
 #define IXGBE_FLAG2_SEARCH_FOR_SFP              (u32)(1 << 4)
 #define IXGBE_FLAG2_SFP_NEEDS_RESET             (u32)(1 << 5)
 #define IXGBE_FLAG2_RESET_REQUESTED             (u32)(1 << 6)
@@ -456,7 +457,6 @@ struct ixgbe_adapter {
 	bool link_up;
 	unsigned long link_check_timeout;
 
-	struct work_struct check_overtemp_task;
 	struct work_struct service_task;
 	struct timer_list service_timer;
 	u32 fdir_pballoc;
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 7edd360..dad56e1 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1825,35 +1825,51 @@ static void ixgbe_set_itr_msix(struct ixgbe_q_vector *q_vector)
 }
 
 /**
- * ixgbe_check_overtemp_task - worker thread to check over tempurature
- * @work: pointer to work_struct containing our data
+ * ixgbe_check_overtemp_subtask - check for over tempurature
+ * @adapter: pointer to adapter
  **/
-static void ixgbe_check_overtemp_task(struct work_struct *work)
+static void ixgbe_check_overtemp_subtask(struct ixgbe_adapter *adapter)
 {
-	struct ixgbe_adapter *adapter = container_of(work,
-						     struct ixgbe_adapter,
-						     check_overtemp_task);
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 eicr = adapter->interrupt_event;
 
-	if (!(adapter->flags2 & IXGBE_FLAG2_TEMP_SENSOR_CAPABLE))
+	if (test_bit(__IXGBE_DOWN, &adapter->state))
 		return;
 
+	if (!(adapter->flags2 & IXGBE_FLAG2_TEMP_SENSOR_CAPABLE) &&
+	    !(adapter->flags2 & IXGBE_FLAG2_TEMP_SENSOR_EVENT))
+		return;
+
+	adapter->flags2 &= ~IXGBE_FLAG2_TEMP_SENSOR_EVENT;
+
 	switch (hw->device_id) {
-	case IXGBE_DEV_ID_82599_T3_LOM: {
-		u32 autoneg;
-		bool link_up = false;
+	case IXGBE_DEV_ID_82599_T3_LOM:
+		/*
+		 * Since the warning interrupt is for both ports
+		 * we don't have to check if:
+		 *  - This interrupt wasn't for our port.
+		 *  - We may have missed the interrupt so always have to
+		 *    check if we  got a LSC
+		 */
+		if (!(eicr & IXGBE_EICR_GPI_SDP0) &&
+		    !(eicr & IXGBE_EICR_LSC))
+			return;
+
+		if (!(eicr & IXGBE_EICR_LSC) && hw->mac.ops.check_link) {
+			u32 autoneg;
+			bool link_up = false;
 
-		if (hw->mac.ops.check_link)
 			hw->mac.ops.check_link(hw, &autoneg, &link_up, false);
 
-		if (((eicr & IXGBE_EICR_GPI_SDP0) && (!link_up)) ||
-		    (eicr & IXGBE_EICR_LSC))
-			/* Check if this is due to overtemp */
-			if (hw->phy.ops.check_overtemp(hw) == IXGBE_ERR_OVERTEMP)
-				break;
-		return;
-	}
+			if (link_up)
+				return;
+		}
+
+		/* Check if this is not due to overtemp */
+		if (hw->phy.ops.check_overtemp(hw) != IXGBE_ERR_OVERTEMP)
+			return;
+
+		break;
 	default:
 		if (!(eicr & IXGBE_EICR_GPI_SDP0))
 			return;
@@ -1863,8 +1879,8 @@ static void ixgbe_check_overtemp_task(struct work_struct *work)
 	       "Network adapter has been stopped because it has over heated. "
 	       "Restart the computer. If the problem persists, "
 	       "power off the system and replace the adapter\n");
-	/* write to clear the interrupt */
-	IXGBE_WRITE_REG(hw, IXGBE_EICR, IXGBE_EICR_GPI_SDP0);
+
+	adapter->interrupt_event = 0;
 }
 
 static void ixgbe_check_fan_failure(struct ixgbe_adapter *adapter, u32 eicr)
@@ -1940,13 +1956,6 @@ static irqreturn_t ixgbe_msix_lsc(int irq, void *data)
 
 	switch (hw->mac.type) {
 	case ixgbe_mac_82599EB:
-		ixgbe_check_sfp_event(adapter, eicr);
-		if ((adapter->flags2 & IXGBE_FLAG2_TEMP_SENSOR_CAPABLE) &&
-		    ((eicr & IXGBE_EICR_GPI_SDP0) || (eicr & IXGBE_EICR_LSC))) {
-			adapter->interrupt_event = eicr;
-			schedule_work(&adapter->check_overtemp_task);
-		}
-		/* now fallthrough to handle Flow Director */
 	case ixgbe_mac_X540:
 		/* Handle Flow Director Full threshold interrupt */
 		if (eicr & IXGBE_EICR_FLOW_DIR) {
@@ -1966,6 +1975,15 @@ static irqreturn_t ixgbe_msix_lsc(int irq, void *data)
 				ixgbe_service_event_schedule(adapter);
 			}
 		}
+		ixgbe_check_sfp_event(adapter, eicr);
+		if ((adapter->flags2 & IXGBE_FLAG2_TEMP_SENSOR_CAPABLE) &&
+		    ((eicr & IXGBE_EICR_GPI_SDP0) || (eicr & IXGBE_EICR_LSC))) {
+			if (!test_bit(__IXGBE_DOWN, &adapter->state)) {
+				adapter->interrupt_event = eicr;
+				adapter->flags2 |= IXGBE_FLAG2_TEMP_SENSOR_EVENT;
+				ixgbe_service_event_schedule(adapter);
+			}
+		}
 		break;
 	default:
 		break;
@@ -2561,8 +2579,11 @@ static irqreturn_t ixgbe_intr(int irq, void *data)
 		ixgbe_check_sfp_event(adapter, eicr);
 		if ((adapter->flags2 & IXGBE_FLAG2_TEMP_SENSOR_CAPABLE) &&
 		    ((eicr & IXGBE_EICR_GPI_SDP0) || (eicr & IXGBE_EICR_LSC))) {
-			adapter->interrupt_event = eicr;
-			schedule_work(&adapter->check_overtemp_task);
+			if (!test_bit(__IXGBE_DOWN, &adapter->state)) {
+				adapter->interrupt_event = eicr;
+				adapter->flags2 |= IXGBE_FLAG2_TEMP_SENSOR_EVENT;
+				ixgbe_service_event_schedule(adapter);
+			}
 		}
 		break;
 	default:
@@ -5974,7 +5995,7 @@ static void ixgbe_fdir_reinit_subtask(struct ixgbe_adapter *adapter)
 	if (ixgbe_reinit_fdir_tables_82599(hw) == 0) {
 		for (i = 0; i < adapter->num_tx_queues; i++)
 			set_bit(__IXGBE_TX_FDIR_INIT_DONE,
-				&(adapter->tx_ring[i]->state));
+			        &(adapter->tx_ring[i]->state));
 		/* re-enable flow director interrupts */
 		IXGBE_WRITE_REG(hw, IXGBE_EIMS, IXGBE_EIMS_FLOW_DIR);
 	} else {
@@ -6379,6 +6400,7 @@ static void ixgbe_service_task(struct work_struct *work)
 	ixgbe_reset_subtask(adapter);
 	ixgbe_sfp_detection_subtask(adapter);
 	ixgbe_sfp_link_config_subtask(adapter);
+	ixgbe_check_overtemp_subtask(adapter);
 	ixgbe_watchdog_subtask(adapter);
 	ixgbe_fdir_reinit_subtask(adapter);
 	ixgbe_check_hang_subtask(adapter);
@@ -7648,9 +7670,6 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	/* carrier off reporting is important to ethtool even BEFORE open */
 	netif_carrier_off(netdev);
 
-	if (adapter->flags2 & IXGBE_FLAG2_TEMP_SENSOR_CAPABLE)
-		INIT_WORK(&adapter->check_overtemp_task,
-			  ixgbe_check_overtemp_task);
 #ifdef CONFIG_IXGBE_DCA
 	if (dca_add_requester(&pdev->dev) == 0) {
 		adapter->flags |= IXGBE_FLAG_DCA_ENABLED;
@@ -7707,8 +7726,6 @@ static void __devexit ixgbe_remove(struct pci_dev *pdev)
 	set_bit(__IXGBE_DOWN, &adapter->state);
 	cancel_work_sync(&adapter->service_task);
 
-	if (adapter->flags2 & IXGBE_FLAG2_TEMP_SENSOR_CAPABLE)
-		cancel_work_sync(&adapter->check_overtemp_task);
 #ifdef CONFIG_IXGBE_DCA
 	if (adapter->flags & IXGBE_FLAG_DCA_ENABLED) {
 		adapter->flags &= ~IXGBE_FLAG_DCA_ENABLED;
-- 
1.7.4.4

