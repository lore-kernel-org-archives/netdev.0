From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [net-next PATCH v2 14/29] fm10k: Add service task to handle delayed
 events
Date: Sat, 20 Sep 2014 19:49:25 -0400
Message-ID: <20140920234908.2977.87810.stgit@ahduyck-bv4.jf.intel.com>
References: <20140920234342.2977.21667.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: nhorman@redhat.com, netdev@vger.kernel.org,
	john.fastabend@gmail.com, matthew.vick@intel.com,
	jeffrey.t.kirsher@intel.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:2469 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751719AbaITX6J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Sep 2014 19:58:09 -0400
In-Reply-To: <20140920234342.2977.21667.stgit@ahduyck-bv4.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for the service task.  The service task takes care
of all processes that cannot be done in interrupt context such as resets,
stats updates, TC prio updates, and checking for hung or detached devices.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

v2: Moved use of container_of macro out of interface declaration.

 drivers/net/ethernet/intel/fm10k/fm10k.h     |   25 +
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c |  435 ++++++++++++++++++++++++++
 2 files changed, 460 insertions(+)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k.h b/drivers/net/ethernet/intel/fm10k/fm10k.h
index ae48d72..b88a52c 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k.h
@@ -239,8 +239,21 @@ struct fm10k_intfc {
 	/* TX */
 	struct fm10k_ring *tx_ring[MAX_QUEUES] ____cacheline_aligned_in_smp;
 
+	u64 restart_queue;
+	u64 tx_busy;
+	u64 tx_csum_errors;
+	u64 alloc_failed;
+	u64 rx_csum_errors;
+	u64 rx_errors;
+
+	u64 tx_bytes_nic;
+	u64 tx_packets_nic;
+	u64 rx_bytes_nic;
+	u64 rx_packets_nic;
+	u64 rx_drops_nic;
 	u64 rx_overrun_pf;
 	u64 rx_overrun_vf;
+	u32 tx_timeout_count;
 
 	/* RX */
 	struct fm10k_ring *rx_ring[MAX_QUEUES];
@@ -257,6 +270,13 @@ struct fm10k_intfc {
 	u16 msg_enable;
 	u16 tx_ring_count;
 	u16 rx_ring_count;
+	struct timer_list service_timer;
+	struct work_struct service_task;
+	unsigned long next_stats_update;
+	unsigned long next_tx_hang_check;
+	unsigned long last_reset;
+	unsigned long link_down_event;
+	bool host_ready;
 
 	u32 reta[FM10K_RETA_SIZE];
 	u32 rssrk[FM10K_RSSRK_SIZE];
@@ -280,6 +300,8 @@ struct fm10k_intfc {
 enum fm10k_state_t {
 	__FM10K_RESETTING,
 	__FM10K_DOWN,
+	__FM10K_SERVICE_SCHED,
+	__FM10K_SERVICE_DISABLE,
 	__FM10K_MBX_LOCK,
 	__FM10K_LINK_DOWN,
 };
@@ -379,6 +401,9 @@ int fm10k_register_pci_driver(void);
 void fm10k_unregister_pci_driver(void);
 void fm10k_up(struct fm10k_intfc *interface);
 void fm10k_down(struct fm10k_intfc *interface);
+void fm10k_update_stats(struct fm10k_intfc *interface);
+void fm10k_service_event_schedule(struct fm10k_intfc *interface);
+void fm10k_update_rx_drop_en(struct fm10k_intfc *interface);
 
 /* Netdev */
 struct net_device *fm10k_alloc_netdev(void);
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 5a28298..4fd272c 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -87,6 +87,404 @@ static int fm10k_hw_ready(struct fm10k_intfc *interface)
 	return FM10K_REMOVED(hw->hw_addr) ? -ENODEV : 0;
 }
 
+void fm10k_service_event_schedule(struct fm10k_intfc *interface)
+{
+	if (!test_bit(__FM10K_SERVICE_DISABLE, &interface->state) &&
+	    !test_and_set_bit(__FM10K_SERVICE_SCHED, &interface->state))
+		schedule_work(&interface->service_task);
+}
+
+static void fm10k_service_event_complete(struct fm10k_intfc *interface)
+{
+	BUG_ON(!test_bit(__FM10K_SERVICE_SCHED, &interface->state));
+
+	/* flush memory to make sure state is correct before next watchog */
+	smp_mb__before_clear_bit();
+	clear_bit(__FM10K_SERVICE_SCHED, &interface->state);
+}
+
+/**
+ * fm10k_service_timer - Timer Call-back
+ * @data: pointer to interface cast into an unsigned long
+ **/
+static void fm10k_service_timer(unsigned long data)
+{
+	struct fm10k_intfc *interface = (struct fm10k_intfc *)data;
+
+	/* Reset the timer */
+	mod_timer(&interface->service_timer, (HZ * 2) + jiffies);
+
+	fm10k_service_event_schedule(interface);
+}
+
+static void fm10k_detach_subtask(struct fm10k_intfc *interface)
+{
+	struct net_device *netdev = interface->netdev;
+
+	/* do nothing if device is still present or hw_addr is set */
+	if (netif_device_present(netdev) || interface->hw.hw_addr)
+		return;
+
+	rtnl_lock();
+
+	if (netif_running(netdev))
+		dev_close(netdev);
+
+	rtnl_unlock();
+}
+
+static void fm10k_reinit(struct fm10k_intfc *interface)
+{
+	struct net_device *netdev = interface->netdev;
+	struct fm10k_hw *hw = &interface->hw;
+	int err;
+
+	WARN_ON(in_interrupt());
+
+	/* put off any impending NetWatchDogTimeout */
+	netdev->trans_start = jiffies;
+
+	while (test_and_set_bit(__FM10K_RESETTING, &interface->state))
+		usleep_range(1000, 2000);
+
+	rtnl_lock();
+
+	if (netif_running(netdev))
+		fm10k_close(netdev);
+
+	fm10k_mbx_free_irq(interface);
+
+	/* delay any future reset requests */
+	interface->last_reset = jiffies + (10 * HZ);
+
+	/* reset and initialize the hardware so it is in a known state */
+	err = hw->mac.ops.reset_hw(hw) ? : hw->mac.ops.init_hw(hw);
+	if (err)
+		dev_err(&interface->pdev->dev, "init_hw failed: %d\n", err);
+
+	/* reassociate interrupts */
+	fm10k_mbx_request_irq(interface);
+
+	if (netif_running(netdev))
+		fm10k_open(netdev);
+
+	rtnl_unlock();
+
+	clear_bit(__FM10K_RESETTING, &interface->state);
+}
+
+static void fm10k_reset_subtask(struct fm10k_intfc *interface)
+{
+	if (!(interface->flags & FM10K_FLAG_RESET_REQUESTED))
+		return;
+
+	interface->flags &= ~FM10K_FLAG_RESET_REQUESTED;
+
+	netdev_err(interface->netdev, "Reset interface\n");
+	interface->tx_timeout_count++;
+
+	fm10k_reinit(interface);
+}
+
+/**
+ * fm10k_configure_swpri_map - Configure Receive SWPRI to PC mapping
+ * @interface: board private structure
+ *
+ * Configure the SWPRI to PC mapping for the port.
+ **/
+static void fm10k_configure_swpri_map(struct fm10k_intfc *interface)
+{
+	struct net_device *netdev = interface->netdev;
+	struct fm10k_hw *hw = &interface->hw;
+	int i;
+
+	/* clear flag indicating update is needed */
+	interface->flags &= ~FM10K_FLAG_SWPRI_CONFIG;
+
+	/* these registers are only available on the PF */
+	if (hw->mac.type != fm10k_mac_pf)
+		return;
+
+	/* configure SWPRI to PC map */
+	for (i = 0; i < FM10K_SWPRI_MAX; i++)
+		fm10k_write_reg(hw, FM10K_SWPRI_MAP(i),
+				netdev_get_prio_tc_map(netdev, i));
+}
+
+/**
+ * fm10k_watchdog_update_host_state - Update the link status based on host.
+ * @interface: board private structure
+ **/
+static void fm10k_watchdog_update_host_state(struct fm10k_intfc *interface)
+{
+	struct fm10k_hw *hw = &interface->hw;
+	s32 err;
+
+	if (test_bit(__FM10K_LINK_DOWN, &interface->state)) {
+		interface->host_ready = false;
+		if (time_is_after_jiffies(interface->link_down_event))
+			return;
+		clear_bit(__FM10K_LINK_DOWN, &interface->state);
+	}
+
+	if (interface->flags & FM10K_FLAG_SWPRI_CONFIG) {
+		if (rtnl_trylock()) {
+			fm10k_configure_swpri_map(interface);
+			rtnl_unlock();
+		}
+	}
+
+	/* lock the mailbox for transmit and receive */
+	fm10k_mbx_lock(interface);
+
+	err = hw->mac.ops.get_host_state(hw, &interface->host_ready);
+	if (err && time_is_before_jiffies(interface->last_reset))
+		interface->flags |= FM10K_FLAG_RESET_REQUESTED;
+
+	/* free the lock */
+	fm10k_mbx_unlock(interface);
+}
+
+/**
+ * fm10k_mbx_subtask - Process upstream and downstream mailboxes
+ * @interface: board private structure
+ *
+ * This function will process both the upstream and downstream mailboxes.
+ * It is necessary for us to hold the rtnl_lock while doing this as the
+ * mailbox accesses are protected by this lock.
+ **/
+static void fm10k_mbx_subtask(struct fm10k_intfc *interface)
+{
+	/* process upstream mailbox and update device state */
+	fm10k_watchdog_update_host_state(interface);
+}
+
+/**
+ * fm10k_watchdog_host_is_ready - Update netdev status based on host ready
+ * @interface: board private structure
+ **/
+static void fm10k_watchdog_host_is_ready(struct fm10k_intfc *interface)
+{
+	struct net_device *netdev = interface->netdev;
+
+	/* only continue if link state is currently down */
+	if (netif_carrier_ok(netdev))
+		return;
+
+	netif_info(interface, drv, netdev, "NIC Link is up\n");
+
+	netif_carrier_on(netdev);
+	netif_tx_wake_all_queues(netdev);
+}
+
+/**
+ * fm10k_watchdog_host_not_ready - Update netdev status based on host not ready
+ * @interface: board private structure
+ **/
+static void fm10k_watchdog_host_not_ready(struct fm10k_intfc *interface)
+{
+	struct net_device *netdev = interface->netdev;
+
+	/* only continue if link state is currently up */
+	if (!netif_carrier_ok(netdev))
+		return;
+
+	netif_info(interface, drv, netdev, "NIC Link is down\n");
+
+	netif_carrier_off(netdev);
+	netif_tx_stop_all_queues(netdev);
+}
+
+/**
+ * fm10k_update_stats - Update the board statistics counters.
+ * @interface: board private structure
+ **/
+void fm10k_update_stats(struct fm10k_intfc *interface)
+{
+	struct net_device_stats *net_stats = &interface->netdev->stats;
+	struct fm10k_hw *hw = &interface->hw;
+	u64 rx_errors = 0, rx_csum_errors = 0, tx_csum_errors = 0;
+	u64 restart_queue = 0, tx_busy = 0, alloc_failed = 0;
+	u64 rx_bytes_nic = 0, rx_pkts_nic = 0, rx_drops_nic = 0;
+	u64 tx_bytes_nic = 0, tx_pkts_nic = 0;
+	u64 bytes, pkts;
+	int i;
+
+	/* do not allow stats update via service task for next second */
+	interface->next_stats_update = jiffies + HZ;
+
+	/* gather some stats to the interface struct that are per queue */
+	for (bytes = 0, pkts = 0, i = 0; i < interface->num_tx_queues; i++) {
+		struct fm10k_ring *tx_ring = interface->tx_ring[i];
+
+		restart_queue += tx_ring->tx_stats.restart_queue;
+		tx_busy += tx_ring->tx_stats.tx_busy;
+		tx_csum_errors += tx_ring->tx_stats.csum_err;
+		bytes += tx_ring->stats.bytes;
+		pkts += tx_ring->stats.packets;
+	}
+
+	interface->restart_queue = restart_queue;
+	interface->tx_busy = tx_busy;
+	net_stats->tx_bytes = bytes;
+	net_stats->tx_packets = pkts;
+	interface->tx_csum_errors = tx_csum_errors;
+	/* gather some stats to the interface struct that are per queue */
+	for (bytes = 0, pkts = 0, i = 0; i < interface->num_rx_queues; i++) {
+		struct fm10k_ring *rx_ring = interface->rx_ring[i];
+
+		bytes += rx_ring->stats.bytes;
+		pkts += rx_ring->stats.packets;
+		alloc_failed += rx_ring->rx_stats.alloc_failed;
+		rx_csum_errors += rx_ring->rx_stats.csum_err;
+		rx_errors += rx_ring->rx_stats.errors;
+	}
+
+	net_stats->rx_bytes = bytes;
+	net_stats->rx_packets = pkts;
+	interface->alloc_failed = alloc_failed;
+	interface->rx_csum_errors = rx_csum_errors;
+	interface->rx_errors = rx_errors;
+
+	hw->mac.ops.update_hw_stats(hw, &interface->stats);
+
+	for (i = 0; i < FM10K_MAX_QUEUES_PF; i++) {
+		struct fm10k_hw_stats_q *q = &interface->stats.q[i];
+
+		tx_bytes_nic += q->tx_bytes.count;
+		tx_pkts_nic += q->tx_packets.count;
+		rx_bytes_nic += q->rx_bytes.count;
+		rx_pkts_nic += q->rx_packets.count;
+		rx_drops_nic += q->rx_drops.count;
+	}
+
+	interface->tx_bytes_nic = tx_bytes_nic;
+	interface->tx_packets_nic = tx_pkts_nic;
+	interface->rx_bytes_nic = rx_bytes_nic;
+	interface->rx_packets_nic = rx_pkts_nic;
+	interface->rx_drops_nic = rx_drops_nic;
+
+	/* Fill out the OS statistics structure */
+	net_stats->rx_errors = interface->stats.xec.count;
+	net_stats->rx_dropped = interface->stats.nodesc_drop.count;
+}
+
+/**
+ * fm10k_watchdog_flush_tx - flush queues on host not ready
+ * @interface - pointer to the device interface structure
+ **/
+static void fm10k_watchdog_flush_tx(struct fm10k_intfc *interface)
+{
+	int some_tx_pending = 0;
+	int i;
+
+	/* nothing to do if carrier is up */
+	if (netif_carrier_ok(interface->netdev))
+		return;
+
+	for (i = 0; i < interface->num_tx_queues; i++) {
+		struct fm10k_ring *tx_ring = interface->tx_ring[i];
+
+		if (tx_ring->next_to_use != tx_ring->next_to_clean) {
+			some_tx_pending = 1;
+			break;
+		}
+	}
+
+	/* We've lost link, so the controller stops DMA, but we've got
+	 * queued Tx work that's never going to get done, so reset
+	 * controller to flush Tx.
+	 */
+	if (some_tx_pending)
+		interface->flags |= FM10K_FLAG_RESET_REQUESTED;
+}
+
+/**
+ * fm10k_watchdog_subtask - check and bring link up
+ * @interface - pointer to the device interface structure
+ **/
+static void fm10k_watchdog_subtask(struct fm10k_intfc *interface)
+{
+	/* if interface is down do nothing */
+	if (test_bit(__FM10K_DOWN, &interface->state) ||
+	    test_bit(__FM10K_RESETTING, &interface->state))
+		return;
+
+	if (interface->host_ready)
+		fm10k_watchdog_host_is_ready(interface);
+	else
+		fm10k_watchdog_host_not_ready(interface);
+
+	/* update stats only once every second */
+	if (time_is_before_jiffies(interface->next_stats_update))
+		fm10k_update_stats(interface);
+
+	/* flush any uncompleted work */
+	fm10k_watchdog_flush_tx(interface);
+}
+
+/**
+ * fm10k_check_hang_subtask - check for hung queues and dropped interrupts
+ * @interface - pointer to the device interface structure
+ *
+ * This function serves two purposes.  First it strobes the interrupt lines
+ * in order to make certain interrupts are occurring.  Secondly it sets the
+ * bits needed to check for TX hangs.  As a result we should immediately
+ * determine if a hang has occurred.
+ */
+static void fm10k_check_hang_subtask(struct fm10k_intfc *interface)
+{
+	int i;
+
+	/* If we're down or resetting, just bail */
+	if (test_bit(__FM10K_DOWN, &interface->state) ||
+	    test_bit(__FM10K_RESETTING, &interface->state))
+		return;
+
+	/* rate limit tx hang checks to only once every 2 seconds */
+	if (time_is_after_eq_jiffies(interface->next_tx_hang_check))
+		return;
+	interface->next_tx_hang_check = jiffies + (2 * HZ);
+
+	if (netif_carrier_ok(interface->netdev)) {
+		/* Force detection of hung controller */
+		for (i = 0; i < interface->num_tx_queues; i++)
+			set_check_for_tx_hang(interface->tx_ring[i]);
+
+		/* Rearm all in-use q_vectors for immediate firing */
+		for (i = 0; i < interface->num_q_vectors; i++) {
+			struct fm10k_q_vector *qv = interface->q_vector[i];
+
+			if (!qv->tx.count && !qv->rx.count)
+				continue;
+			writel(FM10K_ITR_ENABLE | FM10K_ITR_PENDING2, qv->itr);
+		}
+	}
+}
+
+/**
+ * fm10k_service_task - manages and runs subtasks
+ * @work: pointer to work_struct containing our data
+ **/
+static void fm10k_service_task(struct work_struct *work)
+{
+	struct fm10k_intfc *interface;
+
+	interface = container_of(work, struct fm10k_intfc, service_task);
+
+	/* tasks always capable of running, but must be rtnl protected */
+	fm10k_mbx_subtask(interface);
+	fm10k_detach_subtask(interface);
+	fm10k_reset_subtask(interface);
+
+	/* tasks only run when interface is up */
+	fm10k_watchdog_subtask(interface);
+	fm10k_check_hang_subtask(interface);
+
+	/* release lock on service events to allow scheduling next event */
+	fm10k_service_event_complete(interface);
+}
+
 static void fm10k_napi_enable_all(struct fm10k_intfc *interface)
 {
 	struct fm10k_q_vector *q_vector;
@@ -257,6 +655,20 @@ static irqreturn_t fm10k_msix_mbx_pf(int irq, void *data)
 		fm10k_mbx_unlock(interface);
 	}
 
+	/* if switch toggled state we should reset GLORTs */
+	if (eicr & FM10K_EICR_SWITCHNOTREADY) {
+		/* force link down for at least 4 seconds */
+		interface->link_down_event = jiffies + (4 * HZ);
+		set_bit(__FM10K_LINK_DOWN, &interface->state);
+
+		/* reset dglort_map back to no config */
+		hw->mac.dglort_map = FM10K_DGLORTMAP_NONE;
+	}
+
+	/* we should validate host state after interrupt event */
+	hw->mac.get_host_state = 1;
+	fm10k_service_event_schedule(interface);
+
 	/* re-enable mailbox interrupt and indicate 20us delay */
 	fm10k_write_reg(hw, FM10K_ITR(FM10K_MBX_VECTOR),
 			FM10K_ITR_ENABLE | FM10K_MBX_INT_DELAY);
@@ -572,6 +984,9 @@ void fm10k_up(struct fm10k_intfc *interface)
 
 	/* enable transmits */
 	netif_tx_start_all_queues(interface->netdev);
+
+	/* kick off the service timer */
+	mod_timer(&interface->service_timer, jiffies);
 }
 
 static void fm10k_napi_disable_all(struct fm10k_intfc *interface)
@@ -609,6 +1024,11 @@ void fm10k_down(struct fm10k_intfc *interface)
 	/* disable polling routines */
 	fm10k_napi_disable_all(interface);
 
+	del_timer_sync(&interface->service_timer);
+
+	/* capture stats one last time before stopping interface */
+	fm10k_update_stats(interface);
+
 	/* Disable DMA engine for Tx/Rx */
 	hw->mac.ops.stop_hw(hw);
 }
@@ -670,6 +1090,9 @@ static int fm10k_sw_init(struct fm10k_intfc *interface,
 		netdev->vlan_features |= NETIF_F_HIGHDMA;
 	}
 
+	/* delay any future reset requests */
+	interface->last_reset = jiffies + (10 * HZ);
+
 	/* reset and initialize the hardware so it is in a known state */
 	err = hw->mac.ops.reset_hw(hw) ? : hw->mac.ops.init_hw(hw);
 	if (err) {
@@ -707,6 +1130,12 @@ static int fm10k_sw_init(struct fm10k_intfc *interface,
 		netdev->hw_features &= ~NETIF_F_GSO_UDP_TUNNEL;
 	}
 
+	/* Initialize service timer and service task */
+	set_bit(__FM10K_SERVICE_DISABLE, &interface->state);
+	setup_timer(&interface->service_timer, &fm10k_service_timer,
+		    (unsigned long)interface);
+	INIT_WORK(&interface->service_task, fm10k_service_task);
+
 	/* set default ring sizes */
 	interface->tx_ring_count = FM10K_DEFAULT_TXD;
 	interface->rx_ring_count = FM10K_DEFAULT_RXD;
@@ -871,6 +1300,9 @@ static int fm10k_probe(struct pci_dev *pdev,
 	/* print warning for non-optimal configurations */
 	fm10k_slot_warn(interface);
 
+	/* clear the service task disable bit to allow service task to start */
+	clear_bit(__FM10K_SERVICE_DISABLE, &interface->state);
+
 	return 0;
 
 err_register:
@@ -904,6 +1336,9 @@ static void fm10k_remove(struct pci_dev *pdev)
 	struct fm10k_intfc *interface = pci_get_drvdata(pdev);
 	struct net_device *netdev = interface->netdev;
 
+	set_bit(__FM10K_SERVICE_DISABLE, &interface->state);
+	cancel_work_sync(&interface->service_task);
+
 	/* free netdev, this may bounce the interrupts due to setup_tc */
 	if (netdev->reg_state == NETREG_REGISTERED)
 		unregister_netdev(netdev);
