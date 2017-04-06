From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/7] fm10k: future-proof state bitmaps using DECLARE_BITMAP
Date: Thu,  6 Apr 2017 00:54:52 -0700
Message-ID: <20170406075456.27757-4-jeffrey.t.kirsher@intel.com>
References: <20170406075456.27757-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:8948 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756695AbdDFHzG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Apr 2017 03:55:06 -0400
In-Reply-To: <20170406075456.27757-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This ensures that future programmers do not have to remember to re-size
the bitmaps due to adding new values. Although this is unlikely for this
driver, it may happen and it's best to prevent it from ever being an
issue.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k.h         | 40 ++++++++-------
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c |  4 +-
 drivers/net/ethernet/intel/fm10k/fm10k_main.c    | 10 ++--
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c  |  2 +-
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c     | 62 ++++++++++++------------
 5 files changed, 61 insertions(+), 57 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k.h b/drivers/net/ethernet/intel/fm10k/fm10k.h
index d6db1c48d4dc..b496300d0268 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k.h
@@ -65,14 +65,16 @@ enum fm10k_ring_state_t {
 	__FM10K_TX_DETECT_HANG,
 	__FM10K_HANG_CHECK_ARMED,
 	__FM10K_TX_XPS_INIT_DONE,
+	/* This must be last and is used to calculate BITMAP size */
+	__FM10K_TX_STATE_SIZE__,
 };
 
 #define check_for_tx_hang(ring) \
-	test_bit(__FM10K_TX_DETECT_HANG, &(ring)->state)
+	test_bit(__FM10K_TX_DETECT_HANG, (ring)->state)
 #define set_check_for_tx_hang(ring) \
-	set_bit(__FM10K_TX_DETECT_HANG, &(ring)->state)
+	set_bit(__FM10K_TX_DETECT_HANG, (ring)->state)
 #define clear_check_for_tx_hang(ring) \
-	clear_bit(__FM10K_TX_DETECT_HANG, &(ring)->state)
+	clear_bit(__FM10K_TX_DETECT_HANG, (ring)->state)
 
 struct fm10k_tx_buffer {
 	struct fm10k_tx_desc *next_to_watch;
@@ -126,7 +128,7 @@ struct fm10k_ring {
 		struct fm10k_rx_buffer *rx_buffer;
 	};
 	u32 __iomem *tail;
-	unsigned long state;
+	DECLARE_BITMAP(state, __FM10K_TX_STATE_SIZE__);
 	dma_addr_t dma;			/* phys. address of descriptor ring */
 	unsigned int size;		/* length in bytes */
 
@@ -266,12 +268,24 @@ enum fm10k_flags_t {
 	__FM10K_FLAGS_SIZE__
 };
 
+enum fm10k_state_t {
+	__FM10K_RESETTING,
+	__FM10K_DOWN,
+	__FM10K_SERVICE_SCHED,
+	__FM10K_SERVICE_DISABLE,
+	__FM10K_MBX_LOCK,
+	__FM10K_LINK_DOWN,
+	__FM10K_UPDATING_STATS,
+	/* This value must be last and determines the BITMAP size */
+	__FM10K_STATE_SIZE__,
+};
+
 struct fm10k_intfc {
 	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
 	struct net_device *netdev;
 	struct fm10k_l2_accel *l2_accel; /* pointer to L2 acceleration list */
 	struct pci_dev *pdev;
-	unsigned long state;
+	DECLARE_BITMAP(state, __FM10K_STATE_SIZE__);
 
 	/* Access flag values using atomic *_bit() operations */
 	DECLARE_BITMAP(flags, __FM10K_FLAGS_SIZE__);
@@ -367,22 +381,12 @@ struct fm10k_intfc {
 	u16 vid;
 };
 
-enum fm10k_state_t {
-	__FM10K_RESETTING,
-	__FM10K_DOWN,
-	__FM10K_SERVICE_SCHED,
-	__FM10K_SERVICE_DISABLE,
-	__FM10K_MBX_LOCK,
-	__FM10K_LINK_DOWN,
-	__FM10K_UPDATING_STATS,
-};
-
 static inline void fm10k_mbx_lock(struct fm10k_intfc *interface)
 {
 	/* busy loop if we cannot obtain the lock as some calls
 	 * such as ndo_set_rx_mode may be made in atomic context
 	 */
-	while (test_and_set_bit(__FM10K_MBX_LOCK, &interface->state))
+	while (test_and_set_bit(__FM10K_MBX_LOCK, interface->state))
 		udelay(20);
 }
 
@@ -390,12 +394,12 @@ static inline void fm10k_mbx_unlock(struct fm10k_intfc *interface)
 {
 	/* flush memory to make sure state is correct */
 	smp_mb__before_atomic();
-	clear_bit(__FM10K_MBX_LOCK, &interface->state);
+	clear_bit(__FM10K_MBX_LOCK, interface->state);
 }
 
 static inline int fm10k_mbx_trylock(struct fm10k_intfc *interface)
 {
-	return !test_and_set_bit(__FM10K_MBX_LOCK, &interface->state);
+	return !test_and_set_bit(__FM10K_MBX_LOCK, interface->state);
 }
 
 /* fm10k_test_staterr - test bits in Rx descriptor status and error fields */
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
index 5269f3ed4682..c7234f35f8ff 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
@@ -562,7 +562,7 @@ static int fm10k_set_ringparam(struct net_device *netdev,
 		return 0;
 	}
 
-	while (test_and_set_bit(__FM10K_RESETTING, &interface->state))
+	while (test_and_set_bit(__FM10K_RESETTING, interface->state))
 		usleep_range(1000, 2000);
 
 	if (!netif_running(interface->netdev)) {
@@ -648,7 +648,7 @@ static int fm10k_set_ringparam(struct net_device *netdev,
 	fm10k_up(interface);
 	vfree(temp_ring);
 clear_reset:
-	clear_bit(__FM10K_RESETTING, &interface->state);
+	clear_bit(__FM10K_RESETTING, interface->state);
 	return err;
 }
 
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index f9612a6b8524..9dffaba85ae6 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -1175,13 +1175,13 @@ bool fm10k_check_tx_hang(struct fm10k_ring *tx_ring)
 		/* update completed stats and continue */
 		tx_ring->tx_stats.tx_done_old = tx_done;
 		/* reset the countdown */
-		clear_bit(__FM10K_HANG_CHECK_ARMED, &tx_ring->state);
+		clear_bit(__FM10K_HANG_CHECK_ARMED, tx_ring->state);
 
 		return false;
 	}
 
 	/* make sure it is true for two checks in a row */
-	return test_and_set_bit(__FM10K_HANG_CHECK_ARMED, &tx_ring->state);
+	return test_and_set_bit(__FM10K_HANG_CHECK_ARMED, tx_ring->state);
 }
 
 /**
@@ -1191,7 +1191,7 @@ bool fm10k_check_tx_hang(struct fm10k_ring *tx_ring)
 void fm10k_tx_timeout_reset(struct fm10k_intfc *interface)
 {
 	/* Do the reset outside of interrupt context */
-	if (!test_bit(__FM10K_DOWN, &interface->state)) {
+	if (!test_bit(__FM10K_DOWN, interface->state)) {
 		interface->tx_timeout_count++;
 		set_bit(FM10K_FLAG_RESET_REQUESTED, interface->flags);
 		fm10k_service_event_schedule(interface);
@@ -1214,7 +1214,7 @@ static bool fm10k_clean_tx_irq(struct fm10k_q_vector *q_vector,
 	unsigned int budget = q_vector->tx.work_limit;
 	unsigned int i = tx_ring->next_to_clean;
 
-	if (test_bit(__FM10K_DOWN, &interface->state))
+	if (test_bit(__FM10K_DOWN, interface->state))
 		return true;
 
 	tx_buffer = &tx_ring->tx_buffer[i];
@@ -1344,7 +1344,7 @@ static bool fm10k_clean_tx_irq(struct fm10k_q_vector *q_vector,
 		smp_mb();
 		if (__netif_subqueue_stopped(tx_ring->netdev,
 					     tx_ring->queue_index) &&
-		    !test_bit(__FM10K_DOWN, &interface->state)) {
+		    !test_bit(__FM10K_DOWN, interface->state)) {
 			netif_wake_subqueue(tx_ring->netdev,
 					    tx_ring->queue_index);
 			++tx_ring->tx_stats.restart_queue;
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index 008408dd6a56..344a392f7a76 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -822,7 +822,7 @@ static int fm10k_update_vid(struct net_device *netdev, u16 vid, bool set)
 	/* Do not throw an error if the interface is down. We will sync once
 	 * we come up
 	 */
-	if (test_bit(__FM10K_DOWN, &interface->state))
+	if (test_bit(__FM10K_DOWN, interface->state))
 		return 0;
 
 	fm10k_mbx_lock(interface);
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 7ae22dd5dd7c..2a54372975f6 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -93,18 +93,18 @@ static int fm10k_hw_ready(struct fm10k_intfc *interface)
 
 void fm10k_service_event_schedule(struct fm10k_intfc *interface)
 {
-	if (!test_bit(__FM10K_SERVICE_DISABLE, &interface->state) &&
-	    !test_and_set_bit(__FM10K_SERVICE_SCHED, &interface->state))
+	if (!test_bit(__FM10K_SERVICE_DISABLE, interface->state) &&
+	    !test_and_set_bit(__FM10K_SERVICE_SCHED, interface->state))
 		queue_work(fm10k_workqueue, &interface->service_task);
 }
 
 static void fm10k_service_event_complete(struct fm10k_intfc *interface)
 {
-	WARN_ON(!test_bit(__FM10K_SERVICE_SCHED, &interface->state));
+	WARN_ON(!test_bit(__FM10K_SERVICE_SCHED, interface->state));
 
 	/* flush memory to make sure state is correct before next watchog */
 	smp_mb__before_atomic();
-	clear_bit(__FM10K_SERVICE_SCHED, &interface->state);
+	clear_bit(__FM10K_SERVICE_SCHED, interface->state);
 }
 
 /**
@@ -159,7 +159,7 @@ static void fm10k_prepare_for_reset(struct fm10k_intfc *interface)
 	/* put off any impending NetWatchDogTimeout */
 	netif_trans_update(netdev);
 
-	while (test_and_set_bit(__FM10K_RESETTING, &interface->state))
+	while (test_and_set_bit(__FM10K_RESETTING, interface->state))
 		usleep_range(1000, 2000);
 
 	rtnl_lock();
@@ -242,7 +242,7 @@ static int fm10k_handle_reset(struct fm10k_intfc *interface)
 
 	rtnl_unlock();
 
-	clear_bit(__FM10K_RESETTING, &interface->state);
+	clear_bit(__FM10K_RESETTING, interface->state);
 
 	return err;
 err_open:
@@ -254,7 +254,7 @@ static int fm10k_handle_reset(struct fm10k_intfc *interface)
 
 	rtnl_unlock();
 
-	clear_bit(__FM10K_RESETTING, &interface->state);
+	clear_bit(__FM10K_RESETTING, interface->state);
 
 	return err;
 }
@@ -316,11 +316,11 @@ static void fm10k_watchdog_update_host_state(struct fm10k_intfc *interface)
 	struct fm10k_hw *hw = &interface->hw;
 	s32 err;
 
-	if (test_bit(__FM10K_LINK_DOWN, &interface->state)) {
+	if (test_bit(__FM10K_LINK_DOWN, interface->state)) {
 		interface->host_ready = false;
 		if (time_is_after_jiffies(interface->link_down_event))
 			return;
-		clear_bit(__FM10K_LINK_DOWN, &interface->state);
+		clear_bit(__FM10K_LINK_DOWN, interface->state);
 	}
 
 	if (test_bit(FM10K_FLAG_SWPRI_CONFIG, interface->flags)) {
@@ -411,7 +411,7 @@ void fm10k_update_stats(struct fm10k_intfc *interface)
 	int i;
 
 	/* ensure only one thread updates stats at a time */
-	if (test_and_set_bit(__FM10K_UPDATING_STATS, &interface->state))
+	if (test_and_set_bit(__FM10K_UPDATING_STATS, interface->state))
 		return;
 
 	/* do not allow stats update via service task for next second */
@@ -492,7 +492,7 @@ void fm10k_update_stats(struct fm10k_intfc *interface)
 	net_stats->rx_errors = rx_errors;
 	net_stats->rx_dropped = interface->stats.nodesc_drop.count;
 
-	clear_bit(__FM10K_UPDATING_STATS, &interface->state);
+	clear_bit(__FM10K_UPDATING_STATS, interface->state);
 }
 
 /**
@@ -532,8 +532,8 @@ static void fm10k_watchdog_flush_tx(struct fm10k_intfc *interface)
 static void fm10k_watchdog_subtask(struct fm10k_intfc *interface)
 {
 	/* if interface is down do nothing */
-	if (test_bit(__FM10K_DOWN, &interface->state) ||
-	    test_bit(__FM10K_RESETTING, &interface->state))
+	if (test_bit(__FM10K_DOWN, interface->state) ||
+	    test_bit(__FM10K_RESETTING, interface->state))
 		return;
 
 	if (interface->host_ready)
@@ -563,8 +563,8 @@ static void fm10k_check_hang_subtask(struct fm10k_intfc *interface)
 	int i;
 
 	/* If we're down or resetting, just bail */
-	if (test_bit(__FM10K_DOWN, &interface->state) ||
-	    test_bit(__FM10K_RESETTING, &interface->state))
+	if (test_bit(__FM10K_DOWN, interface->state) ||
+	    test_bit(__FM10K_RESETTING, interface->state))
 		return;
 
 	/* rate limit tx hang checks to only once every 2 seconds */
@@ -663,7 +663,7 @@ static void fm10k_configure_tx_ring(struct fm10k_intfc *interface,
 			FM10K_PFVTCTL_FTAG_DESC_ENABLE);
 
 	/* Initialize XPS */
-	if (!test_and_set_bit(__FM10K_TX_XPS_INIT_DONE, &ring->state) &&
+	if (!test_and_set_bit(__FM10K_TX_XPS_INIT_DONE, ring->state) &&
 	    ring->q_vector)
 		netif_set_xps_queue(ring->netdev,
 				    &ring->q_vector->affinity_mask,
@@ -980,7 +980,7 @@ void fm10k_netpoll(struct net_device *netdev)
 	int i;
 
 	/* if interface is down do nothing */
-	if (test_bit(__FM10K_DOWN, &interface->state))
+	if (test_bit(__FM10K_DOWN, interface->state))
 		return;
 
 	for (i = 0; i < interface->num_q_vectors; i++)
@@ -1173,7 +1173,7 @@ static irqreturn_t fm10k_msix_mbx_pf(int __always_unused irq, void *data)
 	if (eicr & FM10K_EICR_SWITCHNOTREADY) {
 		/* force link down for at least 4 seconds */
 		interface->link_down_event = jiffies + (4 * HZ);
-		set_bit(__FM10K_LINK_DOWN, &interface->state);
+		set_bit(__FM10K_LINK_DOWN, interface->state);
 
 		/* reset dglort_map back to no config */
 		hw->mac.dglort_map = FM10K_DGLORTMAP_NONE;
@@ -1325,7 +1325,7 @@ static s32 fm10k_lport_map(struct fm10k_hw *hw, u32 **results,
 	if (!err && hw->swapi.status) {
 		/* force link down for a reasonable delay */
 		interface->link_down_event = jiffies + (2 * HZ);
-		set_bit(__FM10K_LINK_DOWN, &interface->state);
+		set_bit(__FM10K_LINK_DOWN, interface->state);
 
 		/* reset dglort_map back to no config */
 		hw->mac.dglort_map = FM10K_DGLORTMAP_NONE;
@@ -1623,10 +1623,10 @@ void fm10k_up(struct fm10k_intfc *interface)
 	hw->mac.ops.update_int_moderator(hw);
 
 	/* enable statistics capture again */
-	clear_bit(__FM10K_UPDATING_STATS, &interface->state);
+	clear_bit(__FM10K_UPDATING_STATS, interface->state);
 
 	/* clear down bit to indicate we are ready to go */
-	clear_bit(__FM10K_DOWN, &interface->state);
+	clear_bit(__FM10K_DOWN, interface->state);
 
 	/* enable polling cleanups */
 	fm10k_napi_enable_all(interface);
@@ -1660,7 +1660,7 @@ void fm10k_down(struct fm10k_intfc *interface)
 	int err, i = 0, count = 0;
 
 	/* signal that we are down to the interrupt handler and service task */
-	if (test_and_set_bit(__FM10K_DOWN, &interface->state))
+	if (test_and_set_bit(__FM10K_DOWN, interface->state))
 		return;
 
 	/* call carrier off first to avoid false dev_watchdog timeouts */
@@ -1680,7 +1680,7 @@ void fm10k_down(struct fm10k_intfc *interface)
 	fm10k_update_stats(interface);
 
 	/* prevent updating statistics while we're down */
-	while (test_and_set_bit(__FM10K_UPDATING_STATS, &interface->state))
+	while (test_and_set_bit(__FM10K_UPDATING_STATS, interface->state))
 		usleep_range(1000, 2000);
 
 	/* skip waiting for TX DMA if we lost PCIe link */
@@ -1849,8 +1849,8 @@ static int fm10k_sw_init(struct fm10k_intfc *interface,
 	memcpy(interface->rssrk, rss_key, sizeof(rss_key));
 
 	/* Start off interface as being down */
-	set_bit(__FM10K_DOWN, &interface->state);
-	set_bit(__FM10K_UPDATING_STATS, &interface->state);
+	set_bit(__FM10K_DOWN, interface->state);
+	set_bit(__FM10K_UPDATING_STATS, interface->state);
 
 	return 0;
 }
@@ -2027,7 +2027,7 @@ static int fm10k_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	 * must ensure it is disabled since we haven't yet requested the timer
 	 * or work item.
 	 */
-	set_bit(__FM10K_SERVICE_DISABLE, &interface->state);
+	set_bit(__FM10K_SERVICE_DISABLE, interface->state);
 
 	err = fm10k_mbx_request_irq(interface);
 	if (err)
@@ -2068,7 +2068,7 @@ static int fm10k_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	fm10k_iov_configure(pdev, 0);
 
 	/* clear the service task disable bit to allow service task to start */
-	clear_bit(__FM10K_SERVICE_DISABLE, &interface->state);
+	clear_bit(__FM10K_SERVICE_DISABLE, interface->state);
 
 	return 0;
 
@@ -2106,7 +2106,7 @@ static void fm10k_remove(struct pci_dev *pdev)
 
 	del_timer_sync(&interface->service_timer);
 
-	set_bit(__FM10K_SERVICE_DISABLE, &interface->state);
+	set_bit(__FM10K_SERVICE_DISABLE, interface->state);
 	cancel_work_sync(&interface->service_task);
 
 	/* free netdev, this may bounce the interrupts due to setup_tc */
@@ -2145,7 +2145,7 @@ static void fm10k_prepare_suspend(struct fm10k_intfc *interface)
 	 * stopped. We stop the watchdog task until after we resume software
 	 * activity.
 	 */
-	set_bit(__FM10K_SERVICE_DISABLE, &interface->state);
+	set_bit(__FM10K_SERVICE_DISABLE, interface->state);
 	cancel_work_sync(&interface->service_task);
 
 	fm10k_prepare_for_reset(interface);
@@ -2171,10 +2171,10 @@ static int fm10k_handle_resume(struct fm10k_intfc *interface)
 
 	/* force link to stay down for a second to prevent link flutter */
 	interface->link_down_event = jiffies + (HZ);
-	set_bit(__FM10K_LINK_DOWN, &interface->state);
+	set_bit(__FM10K_LINK_DOWN, interface->state);
 
 	/* clear the service task disable bit to allow service task to start */
-	clear_bit(__FM10K_SERVICE_DISABLE, &interface->state);
+	clear_bit(__FM10K_SERVICE_DISABLE, interface->state);
 	fm10k_service_event_schedule(interface);
 
 	return err;
-- 
2.12.2
