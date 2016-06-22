From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next 04/13] liquidio: Napi rx/tx traffic
Date: Tue, 21 Jun 2016 22:53:06 -0700
Message-ID: <1466574795-4306-5-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1466574795-4306-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0093.outbound.protection.outlook.com ([65.55.169.93]:30902
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750907AbcFVFzU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2016 01:55:20 -0400
In-Reply-To: <1466574795-4306-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This Patch adds tx buffer handling  to Napi along with RX
traffic. Also separate spinlocks are introduced for handling
iq posting and buffer reclaim so that tx path and tx interrupt
do not compete against each other.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
---
 .../net/ethernet/cavium/liquidio/cn66xx_device.c   |   3 +-
 .../net/ethernet/cavium/liquidio/cn66xx_device.h   |   3 +-
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 150 +++++++++++++--------
 .../net/ethernet/cavium/liquidio/octeon_device.h   |   4 +-
 drivers/net/ethernet/cavium/liquidio/octeon_iq.h   |  12 +-
 .../net/ethernet/cavium/liquidio/request_manager.c | 110 +++++++++------
 6 files changed, 177 insertions(+), 105 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c b/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c
index c577559..d35864a 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c
@@ -496,8 +496,7 @@ u32 lio_cn6xxx_bar1_idx_read(struct octeon_device *oct, u32 idx)
 }
 
 u32
-lio_cn6xxx_update_read_index(struct octeon_device *oct __attribute__((unused)),
-			     struct octeon_instr_queue *iq)
+lio_cn6xxx_update_read_index(struct octeon_instr_queue *iq)
 {
 	u32 new_idx = readl(iq->inst_cnt_reg);
 
diff --git a/drivers/net/ethernet/cavium/liquidio/cn66xx_device.h b/drivers/net/ethernet/cavium/liquidio/cn66xx_device.h
index f779187..fe2932c 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn66xx_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/cn66xx_device.h
@@ -91,8 +91,7 @@ void lio_cn6xxx_bar1_idx_setup(struct octeon_device *oct, u64 core_addr,
 void lio_cn6xxx_bar1_idx_write(struct octeon_device *oct, u32 idx, u32 mask);
 u32 lio_cn6xxx_bar1_idx_read(struct octeon_device *oct, u32 idx);
 u32
-lio_cn6xxx_update_read_index(struct octeon_device *oct __attribute__((unused)),
-			     struct octeon_instr_queue *iq);
+lio_cn6xxx_update_read_index(struct octeon_instr_queue *iq);
 void lio_cn6xxx_enable_interrupt(void *chip);
 void lio_cn6xxx_disable_interrupt(void *chip);
 void cn6xxx_get_pcie_qlmport(struct octeon_device *oct);
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 9f3a93b..8310eb8 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -365,7 +365,7 @@ static int wait_for_pending_requests(struct octeon_device *oct)
 				[OCTEON_ORDERED_SC_LIST].pending_req_count);
 		if (pcount)
 			schedule_timeout_uninterruptible(HZ / 10);
-		 else
+		else
 			break;
 	}
 
@@ -409,7 +409,7 @@ static inline void pcierror_quiesce_device(struct octeon_device *oct)
 			iq->octeon_read_index = iq->host_write_index;
 			iq->stats.instr_processed +=
 				atomic_read(&iq->instr_pending);
-			lio_process_iq_request_list(oct, iq);
+			lio_process_iq_request_list(oct, iq, 0);
 			spin_unlock_bh(&iq->lock);
 		}
 	}
@@ -959,6 +959,36 @@ static inline void update_link_status(struct net_device *netdev,
 	}
 }
 
+/* Runs in interrupt context. */
+static void update_txq_status(struct octeon_device *oct, int iq_num)
+{
+	struct net_device *netdev;
+	struct lio *lio;
+	struct octeon_instr_queue *iq = oct->instr_queue[iq_num];
+
+	/*octeon_update_iq_read_idx(oct, iq);*/
+
+	netdev = oct->props[iq->ifidx].netdev;
+
+	/* This is needed because the first IQ does not have
+	 * a netdev associated with it.
+	 */
+	if (!netdev)
+		return;
+
+	lio = GET_LIO(netdev);
+	if (netif_is_multiqueue(netdev)) {
+		if (__netif_subqueue_stopped(netdev, iq->q_index) &&
+		    lio->linfo.link.s.link_up &&
+		    (!octnet_iq_is_full(oct, iq_num))) {
+			netif_wake_subqueue(netdev, iq->q_index);
+		} else {
+			if (!octnet_iq_is_full(oct, lio->txq))
+				wake_q(netdev, lio->txq);
+		}
+	}
+}
+
 /**
  * \brief Droq packet processor sceduler
  * @param oct octeon device
@@ -1246,6 +1276,7 @@ static void liquidio_destroy_nic_device(struct octeon_device *oct, int ifidx)
 {
 	struct net_device *netdev = oct->props[ifidx].netdev;
 	struct lio *lio;
+	struct napi_struct *napi, *n;
 
 	if (!netdev) {
 		dev_err(&oct->pci_dev->dev, "%s No netdevice ptr for index %d\n",
@@ -1262,6 +1293,13 @@ static void liquidio_destroy_nic_device(struct octeon_device *oct, int ifidx)
 	if (atomic_read(&lio->ifstate) & LIO_IFSTATE_RUNNING)
 		txqs_stop(netdev);
 
+	if (oct->props[lio->ifidx].napi_enabled == 1) {
+		list_for_each_entry_safe(napi, n, &netdev->napi_list, dev_list)
+			napi_disable(napi);
+
+		oct->props[lio->ifidx].napi_enabled = 0;
+	}
+
 	if (atomic_read(&lio->ifstate) & LIO_IFSTATE_REGISTERED)
 		unregister_netdev(netdev);
 
@@ -1990,39 +2028,6 @@ static void liquidio_napi_drv_callback(void *arg)
 }
 
 /**
- * \brief Main NAPI poll function
- * @param droq octeon output queue
- * @param budget maximum number of items to process
- */
-static int liquidio_napi_do_rx(struct octeon_droq *droq, int budget)
-{
-	int work_done;
-	struct lio *lio = GET_LIO(droq->napi.dev);
-	struct octeon_device *oct = lio->oct_dev;
-
-	work_done = octeon_process_droq_poll_cmd(oct, droq->q_no,
-						 POLL_EVENT_PROCESS_PKTS,
-						 budget);
-	if (work_done < 0) {
-		netif_info(lio, rx_err, lio->netdev,
-			   "Receive work_done < 0, rxq:%d\n", droq->q_no);
-		goto octnet_napi_finish;
-	}
-
-	if (work_done > budget)
-		dev_err(&oct->pci_dev->dev, ">>>> %s work_done: %d budget: %d\n",
-			__func__, work_done, budget);
-
-	return work_done;
-
-octnet_napi_finish:
-	napi_complete(&droq->napi);
-	octeon_process_droq_poll_cmd(oct, droq->q_no, POLL_EVENT_ENABLE_INTR,
-				     0);
-	return 0;
-}
-
-/**
  * \brief Entry point for NAPI polling
  * @param napi NAPI structure
  * @param budget maximum number of items to process
@@ -2031,19 +2036,41 @@ static int liquidio_napi_poll(struct napi_struct *napi, int budget)
 {
 	struct octeon_droq *droq;
 	int work_done;
+	int tx_done = 0, iq_no;
+	struct octeon_instr_queue *iq;
+	struct octeon_device *oct;
 
 	droq = container_of(napi, struct octeon_droq, napi);
+	oct = droq->oct_dev;
+	iq_no = droq->q_no;
+	/* Handle Droq descriptors */
+	work_done = octeon_process_droq_poll_cmd(oct, droq->q_no,
+						 POLL_EVENT_PROCESS_PKTS,
+						 budget);
 
-	work_done = liquidio_napi_do_rx(droq, budget);
+	/* Flush the instruction queue */
+	iq = oct->instr_queue[iq_no];
+	if (iq) {
+		/* Process iq buffers with in the budget limits */
+		tx_done = octeon_flush_iq(oct, iq, 1, budget);
+		/* Update iq read-index rather than waiting for next interrupt.
+		 * Return back if tx_done is false.
+		 */
+		update_txq_status(oct, iq_no);
+		/*tx_done = (iq->flush_index == iq->octeon_read_index);*/
+	} else {
+		dev_err(&oct->pci_dev->dev, "%s:  iq (%d) num invalid\n",
+			__func__, iq_no);
+	}
 
-	if (work_done < budget) {
+	if ((work_done < budget) && (tx_done)) {
 		napi_complete(napi);
 		octeon_process_droq_poll_cmd(droq->oct_dev, droq->q_no,
 					     POLL_EVENT_ENABLE_INTR, 0);
 		return 0;
 	}
 
-	return work_done;
+	return (!tx_done) ? (budget) : (work_done);
 }
 
 /**
@@ -2177,6 +2204,14 @@ static inline void setup_tx_poll_fn(struct net_device *netdev)
 			   &lio->txq_status_wq.wk.work, msecs_to_jiffies(1));
 }
 
+static inline void cleanup_tx_poll_fn(struct net_device *netdev)
+{
+	struct lio *lio = GET_LIO(netdev);
+
+	cancel_delayed_work_sync(&lio->txq_status_wq.wk.work);
+	destroy_workqueue(lio->txq_status_wq.wq);
+}
+
 /**
  * \brief Net device open for LiquidIO
  * @param netdev network device
@@ -2187,17 +2222,22 @@ static int liquidio_open(struct net_device *netdev)
 	struct octeon_device *oct = lio->oct_dev;
 	struct napi_struct *napi, *n;
 
-	list_for_each_entry_safe(napi, n, &netdev->napi_list, dev_list)
-		napi_enable(napi);
+	if (oct->props[lio->ifidx].napi_enabled == 0) {
+		list_for_each_entry_safe(napi, n, &netdev->napi_list, dev_list)
+			napi_enable(napi);
+
+		oct->props[lio->ifidx].napi_enabled = 1;
+	}
 
 	oct_ptp_open(netdev);
 
 	ifstate_set(lio, LIO_IFSTATE_RUNNING);
+
 	setup_tx_poll_fn(netdev);
+
 	start_txq(netdev);
 
 	netif_info(lio, ifup, lio->netdev, "Interface Open, ready for traffic\n");
-	try_module_get(THIS_MODULE);
 
 	/* tell Octeon to start forwarding packets to host */
 	send_rx_ctrl_cmd(lio, 1);
@@ -2217,39 +2257,35 @@ static int liquidio_open(struct net_device *netdev)
  */
 static int liquidio_stop(struct net_device *netdev)
 {
-	struct napi_struct *napi, *n;
 	struct lio *lio = GET_LIO(netdev);
 	struct octeon_device *oct = lio->oct_dev;
 
-	netif_info(lio, ifdown, lio->netdev, "Stopping interface!\n");
+	ifstate_reset(lio, LIO_IFSTATE_RUNNING);
+
+	netif_tx_disable(netdev);
+
 	/* Inform that netif carrier is down */
+	netif_carrier_off(netdev);
 	lio->intf_open = 0;
 	lio->linfo.link.s.link_up = 0;
 	lio->link_changes++;
 
-	netif_carrier_off(netdev);
+	/* Pause for a moment and wait for Octeon to flush out (to the wire) any
+	 * egress packets that are in-flight.
+	 */
+	set_current_state(TASK_INTERRUPTIBLE);
+	schedule_timeout(msecs_to_jiffies(100));
 
-	/* tell Octeon to stop forwarding packets to host */
+	/* Now it should be safe to tell Octeon that nic interface is down. */
 	send_rx_ctrl_cmd(lio, 0);
 
-	cancel_delayed_work_sync(&lio->txq_status_wq.wk.work);
-	destroy_workqueue(lio->txq_status_wq.wq);
+	cleanup_tx_poll_fn(netdev);
 
 	if (lio->ptp_clock) {
 		ptp_clock_unregister(lio->ptp_clock);
 		lio->ptp_clock = NULL;
 	}
 
-	ifstate_reset(lio, LIO_IFSTATE_RUNNING);
-
-	/* This is a hack that allows DHCP to continue working. */
-	set_bit(__LINK_STATE_START, &lio->netdev->state);
-
-	list_for_each_entry_safe(napi, n, &netdev->napi_list, dev_list)
-		napi_disable(napi);
-
-	txqs_stop(netdev);
-
 	dev_info(&oct->pci_dev->dev, "%s interface is stopped\n", netdev->name);
 	module_put(THIS_MODULE);
 
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.h b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
index dd88df7..abfc0d6 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
@@ -204,8 +204,7 @@ struct octeon_fn_list {
 	void (*bar1_idx_setup)(struct octeon_device *, u64, u32, int);
 	void (*bar1_idx_write)(struct octeon_device *, u32, u32);
 	u32 (*bar1_idx_read)(struct octeon_device *, u32);
-	u32 (*update_iq_read_idx)(struct octeon_device *,
-				  struct octeon_instr_queue *);
+	u32 (*update_iq_read_idx)(struct octeon_instr_queue *);
 
 	void (*enable_oq_pkt_time_intr)(struct octeon_device *, u32);
 	void (*disable_oq_pkt_time_intr)(struct octeon_device *, u32);
@@ -267,6 +266,7 @@ struct octdev_props {
 	/* Each interface in the Octeon device has a network
 	 * device pointer (used for OS specific calls).
 	 */
+	int    napi_enabled;
 	int    gmxport;
 	struct net_device *netdev;
 };
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_iq.h b/drivers/net/ethernet/cavium/liquidio/octeon_iq.h
index 7c275ef..69d5b91 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_iq.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_iq.h
@@ -80,6 +80,12 @@ struct octeon_instr_queue {
 	/** A spinlock to protect access to the input ring.  */
 	spinlock_t lock;
 
+	/** A spinlock to protect while posting on the ring.  */
+	spinlock_t post_lock;
+
+	/** A spinlock to protect access to the input ring.*/
+	spinlock_t iq_flush_running_lock;
+
 	/** Flag that indicates if the queue uses 64 byte commands. */
 	u32 iqcmd_64B:1;
 
@@ -339,7 +345,7 @@ octeon_register_reqtype_free_fn(struct octeon_device *oct, int reqtype,
 
 int
 lio_process_iq_request_list(struct octeon_device *oct,
-			    struct octeon_instr_queue *iq);
+			    struct octeon_instr_queue *iq, u32 napi_budget);
 
 int octeon_send_command(struct octeon_device *oct, u32 iq_no,
 			u32 force_db, void *cmd, void *buf,
@@ -357,5 +363,7 @@ int octeon_send_soft_command(struct octeon_device *oct,
 int octeon_setup_iq(struct octeon_device *oct, int ifidx,
 		    int q_index, union oct_txpciq iq_no, u32 num_descs,
 		    void *app_ctx);
-
+int
+octeon_flush_iq(struct octeon_device *oct, struct octeon_instr_queue *iq,
+		u32 pending_thresh, u32 napi_budget);
 #endif				/* __OCTEON_IQ_H__ */
diff --git a/drivers/net/ethernet/cavium/liquidio/request_manager.c b/drivers/net/ethernet/cavium/liquidio/request_manager.c
index 51031010..7eafa75 100644
--- a/drivers/net/ethernet/cavium/liquidio/request_manager.c
+++ b/drivers/net/ethernet/cavium/liquidio/request_manager.c
@@ -51,7 +51,7 @@ struct iq_post_status {
 };
 
 static void check_db_timeout(struct work_struct *work);
-static void  __check_db_timeout(struct octeon_device *oct, unsigned long iq_no);
+static void  __check_db_timeout(struct octeon_device *oct, u64 iq_no);
 
 static void (*reqtype_free_fn[MAX_OCTEON_DEVICES][REQTYPE_LAST + 1]) (void *);
 
@@ -149,6 +149,9 @@ int octeon_init_instr_queue(struct octeon_device *oct,
 
 	/* Initialize the spinlock for this instruction queue */
 	spin_lock_init(&iq->lock);
+	spin_lock_init(&iq->post_lock);
+
+	spin_lock_init(&iq->iq_flush_running_lock);
 
 	oct->io_qmask.iq |= (1ULL << iq_no);
 
@@ -391,13 +394,13 @@ __add_to_request_list(struct octeon_instr_queue *iq,
 
 int
 lio_process_iq_request_list(struct octeon_device *oct,
-			    struct octeon_instr_queue *iq)
+			    struct octeon_instr_queue *iq, u32 napi_budget)
 {
 	int reqtype;
 	void *buf;
 	u32 old = iq->flush_index;
 	u32 inst_count = 0;
-	unsigned pkts_compl = 0, bytes_compl = 0;
+	unsigned int pkts_compl = 0, bytes_compl = 0;
 	struct octeon_soft_command *sc;
 	struct octeon_instr_irh *irh;
 
@@ -457,6 +460,9 @@ lio_process_iq_request_list(struct octeon_device *oct,
  skip_this:
 		inst_count++;
 		INCR_INDEX_BY1(old, iq->max_count);
+
+		if ((napi_budget) && (inst_count >= napi_budget))
+			break;
 	}
 	if (bytes_compl)
 		octeon_report_tx_completion_to_bql(iq->app_ctx, pkts_compl,
@@ -466,38 +472,63 @@ lio_process_iq_request_list(struct octeon_device *oct,
 	return inst_count;
 }
 
-static inline void
-update_iq_indices(struct octeon_device *oct, struct octeon_instr_queue *iq)
+/* Can only be called from process context */
+int
+octeon_flush_iq(struct octeon_device *oct, struct octeon_instr_queue *iq,
+		u32 pending_thresh, u32 napi_budget)
 {
 	u32 inst_processed = 0;
+	u32 tot_inst_processed = 0;
+	int tx_done = 1;
 
-	/* Calculate how many commands Octeon has read and move the read index
-	 * accordingly.
-	 */
-	iq->octeon_read_index = oct->fn_list.update_iq_read_idx(oct, iq);
+	if (!spin_trylock(&iq->iq_flush_running_lock))
+		return tx_done;
 
-	/* Move the NORESPONSE requests to the per-device completion list. */
-	if (iq->flush_index != iq->octeon_read_index)
-		inst_processed = lio_process_iq_request_list(oct, iq);
+	spin_lock_bh(&iq->lock);
 
-	if (inst_processed) {
-		atomic_sub(inst_processed, &iq->instr_pending);
-		iq->stats.instr_processed += inst_processed;
-	}
-}
+	iq->octeon_read_index = oct->fn_list.update_iq_read_idx(iq);
 
-static void
-octeon_flush_iq(struct octeon_device *oct, struct octeon_instr_queue *iq,
-		u32 pending_thresh)
-{
 	if (atomic_read(&iq->instr_pending) >= (s32)pending_thresh) {
-		spin_lock_bh(&iq->lock);
-		update_iq_indices(oct, iq);
-		spin_unlock_bh(&iq->lock);
+		do {
+			/* Process any outstanding IQ packets. */
+			if (iq->flush_index == iq->octeon_read_index)
+				break;
+
+			if (napi_budget)
+				inst_processed = lio_process_iq_request_list
+					(oct, iq,
+					 napi_budget - tot_inst_processed);
+			else
+				inst_processed =
+					lio_process_iq_request_list(oct, iq, 0);
+
+			if (inst_processed) {
+				atomic_sub(inst_processed, &iq->instr_pending);
+				iq->stats.instr_processed += inst_processed;
+			}
+
+			tot_inst_processed += inst_processed;
+			inst_processed = 0;
+
+		} while (tot_inst_processed < napi_budget);
+
+		if (napi_budget && (tot_inst_processed >= napi_budget))
+			tx_done = 0;
 	}
+
+	iq->last_db_time = jiffies;
+
+	spin_unlock_bh(&iq->lock);
+
+	spin_unlock(&iq->iq_flush_running_lock);
+
+	return tx_done;
 }
 
-static void __check_db_timeout(struct octeon_device *oct, unsigned long iq_no)
+/* Process instruction queue after timeout.
+ * This routine gets called from a workqueue or when removing the module.
+ */
+static void __check_db_timeout(struct octeon_device *oct, u64 iq_no)
 {
 	struct octeon_instr_queue *iq;
 	u64 next_time;
@@ -508,24 +539,17 @@ static void __check_db_timeout(struct octeon_device *oct, unsigned long iq_no)
 	if (!iq)
 		return;
 
+	/* return immediately, if no work pending */
+	if (!atomic_read(&iq->instr_pending))
+		return;
 	/* If jiffies - last_db_time < db_timeout do nothing  */
 	next_time = iq->last_db_time + iq->db_timeout;
 	if (!time_after(jiffies, (unsigned long)next_time))
 		return;
 	iq->last_db_time = jiffies;
 
-	/* Get the lock and prevent tasklets. This routine gets called from
-	 * the poll thread. Instructions can now be posted in tasklet context
-	 */
-	spin_lock_bh(&iq->lock);
-	if (iq->fill_cnt != 0)
-		ring_doorbell(oct, iq);
-
-	spin_unlock_bh(&iq->lock);
-
 	/* Flush the instruction queue */
-	if (iq->do_auto_flush)
-		octeon_flush_iq(oct, iq, 1);
+	octeon_flush_iq(oct, iq, 1, 0);
 }
 
 /* Called by the Poll thread at regular intervals to check the instruction
@@ -550,7 +574,10 @@ octeon_send_command(struct octeon_device *oct, u32 iq_no,
 	struct iq_post_status st;
 	struct octeon_instr_queue *iq = oct->instr_queue[iq_no];
 
-	spin_lock_bh(&iq->lock);
+	/* Get the lock and prevent other tasks and tx interrupt handler from
+	 * running.
+	 */
+	spin_lock_bh(&iq->post_lock);
 
 	st = __post_command2(oct, iq, force_db, cmd);
 
@@ -566,10 +593,13 @@ octeon_send_command(struct octeon_device *oct, u32 iq_no,
 		INCR_INSTRQUEUE_PKT_COUNT(oct, iq_no, instr_dropped, 1);
 	}
 
-	spin_unlock_bh(&iq->lock);
+	spin_unlock_bh(&iq->post_lock);
 
-	if (iq->do_auto_flush)
-		octeon_flush_iq(oct, iq, 2);
+	/* This is only done here to expedite packets being flushed
+	 * for cases where there are no IQ completion interrupts.
+	 */
+	/*if (iq->do_auto_flush)*/
+	/*	octeon_flush_iq(oct, iq, 2, 0);*/
 
 	return st.status;
 }
-- 
1.8.3.1
