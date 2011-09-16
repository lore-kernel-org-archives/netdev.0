From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/11] ixgbe: Correctly name and handle MSI-X other interrupt
Date: Thu, 15 Sep 2011 21:42:53 -0700
Message-ID: <1316148173-11209-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1316148173-11209-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:15976 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752052Ab1IPEnB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Sep 2011 00:43:01 -0400
In-Reply-To: <1316148173-11209-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

It was possible to inadvertently add additional interrupt causes to the
MSI-X other interrupt.  This occurred when things such as RX buffer overrun
events were being triggered at the same time as an event such as a Flow
Director table reinit request.  In order to avoid this we should be
explicitly programming only the interrupts that we want enabled.  In
addition I am renaming the ixgbe_msix_lsc function and interrupt to drop
any implied meaning of this being a link status only interrupt.

Unfortunately the patch is a bit ugly due to the fact that ixgbe_irq_enable
needed to be moved up before ixgbe_msix_other in order to have things
defined in the correct order.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |    1 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  191 +++++++++++++------------
 2 files changed, 97 insertions(+), 95 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 3f5a744..bfdd42b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -491,7 +491,6 @@ struct ixgbe_adapter {
 	int node;
 	u32 led_reg;
 	u32 interrupt_event;
-	char lsc_int_name[IFNAMSIZ + 9];
 
 	/* SR-IOV */
 	DECLARE_BITMAP(active_vfs, IXGBE_MAX_VF_FUNCTIONS);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 0ee7d09..6026ab0 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1828,7 +1828,98 @@ static void ixgbe_check_lsc(struct ixgbe_adapter *adapter)
 	}
 }
 
-static irqreturn_t ixgbe_msix_lsc(int irq, void *data)
+static inline void ixgbe_irq_enable_queues(struct ixgbe_adapter *adapter,
+					   u64 qmask)
+{
+	u32 mask;
+	struct ixgbe_hw *hw = &adapter->hw;
+
+	switch (hw->mac.type) {
+	case ixgbe_mac_82598EB:
+		mask = (IXGBE_EIMS_RTX_QUEUE & qmask);
+		IXGBE_WRITE_REG(hw, IXGBE_EIMS, mask);
+		break;
+	case ixgbe_mac_82599EB:
+	case ixgbe_mac_X540:
+		mask = (qmask & 0xFFFFFFFF);
+		if (mask)
+			IXGBE_WRITE_REG(hw, IXGBE_EIMS_EX(0), mask);
+		mask = (qmask >> 32);
+		if (mask)
+			IXGBE_WRITE_REG(hw, IXGBE_EIMS_EX(1), mask);
+		break;
+	default:
+		break;
+	}
+	/* skip the flush */
+}
+
+static inline void ixgbe_irq_disable_queues(struct ixgbe_adapter *adapter,
+					    u64 qmask)
+{
+	u32 mask;
+	struct ixgbe_hw *hw = &adapter->hw;
+
+	switch (hw->mac.type) {
+	case ixgbe_mac_82598EB:
+		mask = (IXGBE_EIMS_RTX_QUEUE & qmask);
+		IXGBE_WRITE_REG(hw, IXGBE_EIMC, mask);
+		break;
+	case ixgbe_mac_82599EB:
+	case ixgbe_mac_X540:
+		mask = (qmask & 0xFFFFFFFF);
+		if (mask)
+			IXGBE_WRITE_REG(hw, IXGBE_EIMC_EX(0), mask);
+		mask = (qmask >> 32);
+		if (mask)
+			IXGBE_WRITE_REG(hw, IXGBE_EIMC_EX(1), mask);
+		break;
+	default:
+		break;
+	}
+	/* skip the flush */
+}
+
+/**
+ * ixgbe_irq_enable - Enable default interrupt generation settings
+ * @adapter: board private structure
+ **/
+static inline void ixgbe_irq_enable(struct ixgbe_adapter *adapter, bool queues,
+				    bool flush)
+{
+	u32 mask = (IXGBE_EIMS_ENABLE_MASK & ~IXGBE_EIMS_RTX_QUEUE);
+
+	/* don't reenable LSC while waiting for link */
+	if (adapter->flags & IXGBE_FLAG_NEED_LINK_UPDATE)
+		mask &= ~IXGBE_EIMS_LSC;
+
+	if (adapter->flags2 & IXGBE_FLAG2_TEMP_SENSOR_CAPABLE)
+		mask |= IXGBE_EIMS_GPI_SDP0;
+	if (adapter->flags & IXGBE_FLAG_FAN_FAIL_CAPABLE)
+		mask |= IXGBE_EIMS_GPI_SDP1;
+	switch (adapter->hw.mac.type) {
+	case ixgbe_mac_82599EB:
+	case ixgbe_mac_X540:
+		mask |= IXGBE_EIMS_ECC;
+		mask |= IXGBE_EIMS_GPI_SDP1;
+		mask |= IXGBE_EIMS_GPI_SDP2;
+		mask |= IXGBE_EIMS_MAILBOX;
+		break;
+	default:
+		break;
+	}
+	if ((adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE) &&
+	    !(adapter->flags2 & IXGBE_FLAG2_FDIR_REQUIRES_REINIT))
+		mask |= IXGBE_EIMS_FLOW_DIR;
+
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS, mask);
+	if (queues)
+		ixgbe_irq_enable_queues(adapter, ~0);
+	if (flush)
+		IXGBE_WRITE_FLUSH(&adapter->hw);
+}
+
+static irqreturn_t ixgbe_msix_other(int irq, void *data)
 {
 	struct ixgbe_adapter *adapter = data;
 	struct ixgbe_hw *hw = &adapter->hw;
@@ -1852,6 +1943,9 @@ static irqreturn_t ixgbe_msix_lsc(int irq, void *data)
 	switch (hw->mac.type) {
 	case ixgbe_mac_82599EB:
 	case ixgbe_mac_X540:
+		if (eicr & IXGBE_EICR_ECC)
+			e_info(link, "Received unrecoverable ECC Err, please "
+			       "reboot\n");
 		/* Handle Flow Director Full threshold interrupt */
 		if (eicr & IXGBE_EICR_FLOW_DIR) {
 			int reinit_count = 0;
@@ -1865,7 +1959,6 @@ static irqreturn_t ixgbe_msix_lsc(int irq, void *data)
 			if (reinit_count) {
 				/* no more flow director interrupts until after init */
 				IXGBE_WRITE_REG(hw, IXGBE_EIMC, IXGBE_EIMC_FLOW_DIR);
-				eicr &= ~IXGBE_EICR_FLOW_DIR;
 				adapter->flags2 |= IXGBE_FLAG2_FDIR_REQUIRES_REINIT;
 				ixgbe_service_event_schedule(adapter);
 			}
@@ -1888,64 +1981,11 @@ static irqreturn_t ixgbe_msix_lsc(int irq, void *data)
 
 	/* re-enable the original interrupt state, no lsc, no queues */
 	if (!test_bit(__IXGBE_DOWN, &adapter->state))
-		IXGBE_WRITE_REG(hw, IXGBE_EIMS, eicr &
-		                ~(IXGBE_EIMS_LSC | IXGBE_EIMS_RTX_QUEUE));
+		ixgbe_irq_enable(adapter, false, false);
 
 	return IRQ_HANDLED;
 }
 
-static inline void ixgbe_irq_enable_queues(struct ixgbe_adapter *adapter,
-					   u64 qmask)
-{
-	u32 mask;
-	struct ixgbe_hw *hw = &adapter->hw;
-
-	switch (hw->mac.type) {
-	case ixgbe_mac_82598EB:
-		mask = (IXGBE_EIMS_RTX_QUEUE & qmask);
-		IXGBE_WRITE_REG(hw, IXGBE_EIMS, mask);
-		break;
-	case ixgbe_mac_82599EB:
-	case ixgbe_mac_X540:
-		mask = (qmask & 0xFFFFFFFF);
-		if (mask)
-			IXGBE_WRITE_REG(hw, IXGBE_EIMS_EX(0), mask);
-		mask = (qmask >> 32);
-		if (mask)
-			IXGBE_WRITE_REG(hw, IXGBE_EIMS_EX(1), mask);
-		break;
-	default:
-		break;
-	}
-	/* skip the flush */
-}
-
-static inline void ixgbe_irq_disable_queues(struct ixgbe_adapter *adapter,
-					    u64 qmask)
-{
-	u32 mask;
-	struct ixgbe_hw *hw = &adapter->hw;
-
-	switch (hw->mac.type) {
-	case ixgbe_mac_82598EB:
-		mask = (IXGBE_EIMS_RTX_QUEUE & qmask);
-		IXGBE_WRITE_REG(hw, IXGBE_EIMC, mask);
-		break;
-	case ixgbe_mac_82599EB:
-	case ixgbe_mac_X540:
-		mask = (qmask & 0xFFFFFFFF);
-		if (mask)
-			IXGBE_WRITE_REG(hw, IXGBE_EIMC_EX(0), mask);
-		mask = (qmask >> 32);
-		if (mask)
-			IXGBE_WRITE_REG(hw, IXGBE_EIMC_EX(1), mask);
-		break;
-	default:
-		break;
-	}
-	/* skip the flush */
-}
-
 static irqreturn_t ixgbe_msix_clean_rings(int irq, void *data)
 {
 	struct ixgbe_q_vector *q_vector = data;
@@ -2077,9 +2117,8 @@ static int ixgbe_request_msix_irqs(struct ixgbe_adapter *adapter)
 		}
 	}
 
-	sprintf(adapter->lsc_int_name, "%s:lsc", netdev->name);
 	err = request_irq(adapter->msix_entries[vector].vector,
-			  ixgbe_msix_lsc, 0, adapter->lsc_int_name, adapter);
+			  ixgbe_msix_other, 0, netdev->name, adapter);
 	if (err) {
 		e_err(probe, "request_irq for msix_lsc failed: %d\n", err);
 		goto free_queue_irqs;
@@ -2103,42 +2142,6 @@ free_queue_irqs:
 }
 
 /**
- * ixgbe_irq_enable - Enable default interrupt generation settings
- * @adapter: board private structure
- **/
-static inline void ixgbe_irq_enable(struct ixgbe_adapter *adapter, bool queues,
-				    bool flush)
-{
-	u32 mask;
-
-	mask = (IXGBE_EIMS_ENABLE_MASK & ~IXGBE_EIMS_RTX_QUEUE);
-	if (adapter->flags2 & IXGBE_FLAG2_TEMP_SENSOR_CAPABLE)
-		mask |= IXGBE_EIMS_GPI_SDP0;
-	if (adapter->flags & IXGBE_FLAG_FAN_FAIL_CAPABLE)
-		mask |= IXGBE_EIMS_GPI_SDP1;
-	switch (adapter->hw.mac.type) {
-	case ixgbe_mac_82599EB:
-	case ixgbe_mac_X540:
-		mask |= IXGBE_EIMS_ECC;
-		mask |= IXGBE_EIMS_GPI_SDP1;
-		mask |= IXGBE_EIMS_GPI_SDP2;
-		if (adapter->num_vfs)
-			mask |= IXGBE_EIMS_MAILBOX;
-		break;
-	default:
-		break;
-	}
-	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE)
-		mask |= IXGBE_EIMS_FLOW_DIR;
-
-	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS, mask);
-	if (queues)
-		ixgbe_irq_enable_queues(adapter, ~0);
-	if (flush)
-		IXGBE_WRITE_FLUSH(&adapter->hw);
-}
-
-/**
  * ixgbe_intr - legacy mode Interrupt Handler
  * @irq: interrupt number
  * @data: pointer to a network interface device structure
-- 
1.7.6
