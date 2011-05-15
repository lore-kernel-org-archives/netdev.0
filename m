From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 09/13] ixgbe: Merge ATR reinit into the service task
Date: Sat, 14 May 2011 18:23:43 -0700
Message-ID: <1305422627-9583-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1305422627-9583-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:52581 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759557Ab1EOBXx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 May 2011 21:23:53 -0400
In-Reply-To: <1305422627-9583-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change merges the ATR table reinitialization into the service task.
This is yet another opportunity to avoid any race conditions as we don't
want to be attempting to reinitialize the table during a possible reset.

In addition this change adds a counter for table reinitialization so that
it can be tracked as part of the regular statistics.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Evan Swanson <evan.swanson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe.h         |    3 +-
 drivers/net/ixgbe/ixgbe_ethtool.c |    1 +
 drivers/net/ixgbe/ixgbe_main.c    |   65 +++++++++++++++++++-----------------
 3 files changed, 37 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 760b850..a180cde 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -382,6 +382,7 @@ struct ixgbe_adapter {
 #define IXGBE_FLAG2_SEARCH_FOR_SFP              (u32)(1 << 4)
 #define IXGBE_FLAG2_SFP_NEEDS_RESET             (u32)(1 << 5)
 #define IXGBE_FLAG2_RESET_REQUESTED             (u32)(1 << 6)
+#define IXGBE_FLAG2_FDIR_REQUIRES_REINIT        (u32)(1 << 7)
 
 	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
 	u16 bd_number;
@@ -455,12 +456,12 @@ struct ixgbe_adapter {
 	bool link_up;
 	unsigned long link_check_timeout;
 
-	struct work_struct fdir_reinit_task;
 	struct work_struct check_overtemp_task;
 	struct work_struct service_task;
 	struct timer_list service_timer;
 	u32 fdir_pballoc;
 	u32 atr_sample_rate;
+	unsigned long fdir_overflow; /* number of times ATR was backed off */
 	spinlock_t fdir_perfect_lock;
 #ifdef IXGBE_FCOE
 	struct ixgbe_fcoe fcoe;
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 1fdd075..cb1555b 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -84,6 +84,7 @@ static struct ixgbe_stats ixgbe_gstrings_stats[] = {
 	{"hw_rsc_flushed", IXGBE_STAT(rsc_total_flush)},
 	{"fdir_match", IXGBE_STAT(stats.fdirmatch)},
 	{"fdir_miss", IXGBE_STAT(stats.fdirmiss)},
+	{"fdir_overflow", IXGBE_STAT(fdir_overflow)},
 	{"rx_fifo_errors", IXGBE_NETDEV_STAT(rx_fifo_errors)},
 	{"rx_missed_errors", IXGBE_NETDEV_STAT(rx_missed_errors)},
 	{"tx_aborted_errors", IXGBE_NETDEV_STAT(tx_aborted_errors)},
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index dbb20e5..7edd360 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1950,16 +1950,20 @@ static irqreturn_t ixgbe_msix_lsc(int irq, void *data)
 	case ixgbe_mac_X540:
 		/* Handle Flow Director Full threshold interrupt */
 		if (eicr & IXGBE_EICR_FLOW_DIR) {
+			int reinit_count = 0;
 			int i;
-			IXGBE_WRITE_REG(hw, IXGBE_EICR, IXGBE_EICR_FLOW_DIR);
-			/* Disable transmits before FDIR Re-initialization */
-			netif_tx_stop_all_queues(netdev);
 			for (i = 0; i < adapter->num_tx_queues; i++) {
-				struct ixgbe_ring *tx_ring =
-							    adapter->tx_ring[i];
+				struct ixgbe_ring *ring = adapter->tx_ring[i];
 				if (test_and_clear_bit(__IXGBE_TX_FDIR_INIT_DONE,
-						       &tx_ring->state))
-					schedule_work(&adapter->fdir_reinit_task);
+						       &ring->state))
+					reinit_count++;
+			}
+			if (reinit_count) {
+				/* no more flow director interrupts until after init */
+				IXGBE_WRITE_REG(hw, IXGBE_EIMC, IXGBE_EIMC_FLOW_DIR);
+				eicr &= ~IXGBE_EICR_FLOW_DIR;
+				adapter->flags2 |= IXGBE_FLAG2_FDIR_REQUIRES_REINIT;
+				ixgbe_service_event_schedule(adapter);
 			}
 		}
 		break;
@@ -4198,7 +4202,8 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 
 	ixgbe_napi_disable_all(adapter);
 
-	adapter->flags2 &= ~IXGBE_FLAG2_RESET_REQUESTED;
+	adapter->flags2 &= ~(IXGBE_FLAG2_FDIR_REQUIRES_REINIT |
+			     IXGBE_FLAG2_RESET_REQUESTED);
 	adapter->flags &= ~IXGBE_FLAG_NEED_LINK_UPDATE;
 
 	del_timer_sync(&adapter->service_timer);
@@ -4212,13 +4217,6 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 		free_cpumask_var(q_vector->affinity_mask);
 	}
 
-	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE ||
-	    adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE)
-		cancel_work_sync(&adapter->fdir_reinit_task);
-
-	if (adapter->flags2 & IXGBE_FLAG2_TEMP_SENSOR_CAPABLE)
-		cancel_work_sync(&adapter->check_overtemp_task);
-
 	/* disable transmits in the hardware now that interrupts are off */
 	for (i = 0; i < adapter->num_tx_queues; i++) {
 		u8 reg_idx = adapter->tx_ring[i]->reg_idx;
@@ -5950,27 +5948,39 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 }
 
 /**
- * ixgbe_fdir_reinit_task - worker thread to reinit FDIR filter table
- * @work: pointer to work_struct containing our data
+ * ixgbe_fdir_reinit_subtask - worker thread to reinit FDIR filter table
+ * @adapter - pointer to the device adapter structure
  **/
-static void ixgbe_fdir_reinit_task(struct work_struct *work)
+static void ixgbe_fdir_reinit_subtask(struct ixgbe_adapter *adapter)
 {
-	struct ixgbe_adapter *adapter = container_of(work,
-						     struct ixgbe_adapter,
-						     fdir_reinit_task);
 	struct ixgbe_hw *hw = &adapter->hw;
 	int i;
 
+	if (!(adapter->flags2 & IXGBE_FLAG2_FDIR_REQUIRES_REINIT))
+		return;
+
+	adapter->flags2 &= ~IXGBE_FLAG2_FDIR_REQUIRES_REINIT;
+
+	/* if interface is down do nothing */
+	if (test_bit(__IXGBE_DOWN, &adapter->state))
+		return;
+
+	/* do nothing if we are not using signature filters */
+	if (!(adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE))
+		return;
+
+	adapter->fdir_overflow++;
+
 	if (ixgbe_reinit_fdir_tables_82599(hw) == 0) {
 		for (i = 0; i < adapter->num_tx_queues; i++)
 			set_bit(__IXGBE_TX_FDIR_INIT_DONE,
 				&(adapter->tx_ring[i]->state));
+		/* re-enable flow director interrupts */
+		IXGBE_WRITE_REG(hw, IXGBE_EIMS, IXGBE_EIMS_FLOW_DIR);
 	} else {
 		e_err(probe, "failed to finish FDIR re-initialization, "
 		      "ignored adding FDIR ATR filters\n");
 	}
-	/* Done FDIR Re-initialization, enable transmits */
-	netif_tx_start_all_queues(adapter->netdev);
 }
 
 /**
@@ -6370,6 +6380,7 @@ static void ixgbe_service_task(struct work_struct *work)
 	ixgbe_sfp_detection_subtask(adapter);
 	ixgbe_sfp_link_config_subtask(adapter);
 	ixgbe_watchdog_subtask(adapter);
+	ixgbe_fdir_reinit_subtask(adapter);
 	ixgbe_check_hang_subtask(adapter);
 
 	ixgbe_service_event_complete(adapter);
@@ -7637,10 +7648,6 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	/* carrier off reporting is important to ethtool even BEFORE open */
 	netif_carrier_off(netdev);
 
-	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE ||
-	    adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE)
-		INIT_WORK(&adapter->fdir_reinit_task, ixgbe_fdir_reinit_task);
-
 	if (adapter->flags2 & IXGBE_FLAG2_TEMP_SENSOR_CAPABLE)
 		INIT_WORK(&adapter->check_overtemp_task,
 			  ixgbe_check_overtemp_task);
@@ -7700,12 +7707,8 @@ static void __devexit ixgbe_remove(struct pci_dev *pdev)
 	set_bit(__IXGBE_DOWN, &adapter->state);
 	cancel_work_sync(&adapter->service_task);
 
-	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE ||
-	    adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE)
-		cancel_work_sync(&adapter->fdir_reinit_task);
 	if (adapter->flags2 & IXGBE_FLAG2_TEMP_SENSOR_CAPABLE)
 		cancel_work_sync(&adapter->check_overtemp_task);
-
 #ifdef CONFIG_IXGBE_DCA
 	if (adapter->flags & IXGBE_FLAG_DCA_ENABLED) {
 		adapter->flags &= ~IXGBE_FLAG_DCA_ENABLED;
-- 
1.7.4.4

