From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V5 7/9] liquidio CN23XX: code cleanup
Date: Wed, 9 Nov 2016 15:13:50 -0800
Message-ID: <1478733232-15739-8-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1478733232-15739-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
        Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
        Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0081.outbound.protection.outlook.com ([104.47.32.81]:54484
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754409AbcKIXOi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Nov 2016 18:14:38 -0500
In-Reply-To: <1478733232-15739-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cleaned up unnecessary comments and added some minor macros.

Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/cn66xx_device.c   | 13 ++++---------
 drivers/net/ethernet/cavium/liquidio/cn66xx_device.h   |  4 ++--
 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c     | 14 ++++----------
 drivers/net/ethernet/cavium/liquidio/lio_main.c        | 16 +++++-----------
 drivers/net/ethernet/cavium/liquidio/liquidio_common.h |  2 --
 drivers/net/ethernet/cavium/liquidio/octeon_device.c   |  8 ++++----
 drivers/net/ethernet/cavium/liquidio/octeon_droq.c     |  2 +-
 drivers/net/ethernet/cavium/liquidio/octeon_droq.h     |  1 -
 drivers/net/ethernet/cavium/liquidio/octeon_iq.h       |  1 -
 drivers/net/ethernet/cavium/liquidio/octeon_main.h     | 18 ------------------
 drivers/net/ethernet/cavium/liquidio/request_manager.c |  7 ++-----
 .../net/ethernet/cavium/liquidio/response_manager.c    |  6 +-----
 .../net/ethernet/cavium/liquidio/response_manager.h    |  1 -
 13 files changed, 23 insertions(+), 70 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c b/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c
index e779af8..1ebc225 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c
@@ -275,7 +275,6 @@ void lio_cn6xxx_setup_iq_regs(struct octeon_device *oct, u32 iq_no)
 {
 	struct octeon_instr_queue *iq = oct->instr_queue[iq_no];
 
-	/* Disable Packet-by-Packet mode; No Parse Mode or Skip length */
 	octeon_write_csr64(oct, CN6XXX_SLI_IQ_PKT_INSTR_HDR64(iq_no), 0);
 
 	/* Write the start of the input queue's ring and its size  */
@@ -378,7 +377,7 @@ void lio_cn6xxx_disable_io_queues(struct octeon_device *oct)
 
 	/* Reset the doorbell register for each Input queue. */
 	for (i = 0; i < MAX_OCTEON_INSTR_QUEUES(oct); i++) {
-		if (!(oct->io_qmask.iq & (1ULL << i)))
+		if (!(oct->io_qmask.iq & BIT_ULL(i)))
 			continue;
 		octeon_write_csr(oct, CN6XXX_SLI_IQ_DOORBELL(i), 0xFFFFFFFF);
 		d32 = octeon_read_csr(oct, CN6XXX_SLI_IQ_DOORBELL(i));
@@ -400,9 +399,8 @@ void lio_cn6xxx_disable_io_queues(struct octeon_device *oct)
 	;
 
 	/* Reset the doorbell register for each Output queue. */
-	/* for (i = 0; i < oct->num_oqs; i++) { */
 	for (i = 0; i < MAX_OCTEON_OUTPUT_QUEUES(oct); i++) {
-		if (!(oct->io_qmask.oq & (1ULL << i)))
+		if (!(oct->io_qmask.oq & BIT_ULL(i)))
 			continue;
 		octeon_write_csr(oct, CN6XXX_SLI_OQ_PKTS_CREDIT(i), 0xFFFFFFFF);
 		d32 = octeon_read_csr(oct, CN6XXX_SLI_OQ_PKTS_CREDIT(i));
@@ -537,15 +535,14 @@ static int lio_cn6xxx_process_droq_intr_regs(struct octeon_device *oct)
 
 	oct->droq_intr = 0;
 
-	/* for (oq_no = 0; oq_no < oct->num_oqs; oq_no++) { */
 	for (oq_no = 0; oq_no < MAX_OCTEON_OUTPUT_QUEUES(oct); oq_no++) {
-		if (!(droq_mask & (1ULL << oq_no)))
+		if (!(droq_mask & BIT_ULL(oq_no)))
 			continue;
 
 		droq = oct->droq[oq_no];
 		pkt_count = octeon_droq_check_hw_for_pkts(droq);
 		if (pkt_count) {
-			oct->droq_intr |= (1ULL << oq_no);
+			oct->droq_intr |= BIT_ULL(oq_no);
 			if (droq->ops.poll_mode) {
 				u32 value;
 				u32 reg;
@@ -721,8 +718,6 @@ int lio_setup_cn66xx_octeon_device(struct octeon_device *oct)
 int lio_validate_cn6xxx_config_info(struct octeon_device *oct,
 				    struct octeon_config *conf6xxx)
 {
-	/* int total_instrs = 0; */
-
 	if (CFG_GET_IQ_MAX_Q(conf6xxx) > CN6XXX_MAX_INPUT_QUEUES) {
 		dev_err(&oct->pci_dev->dev, "%s: Num IQ (%d) exceeds Max (%d)\n",
 			__func__, CFG_GET_IQ_MAX_Q(conf6xxx),
diff --git a/drivers/net/ethernet/cavium/liquidio/cn66xx_device.h b/drivers/net/ethernet/cavium/liquidio/cn66xx_device.h
index a40a913..32fbbb2 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn66xx_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/cn66xx_device.h
@@ -96,8 +96,8 @@ void lio_cn6xxx_setup_reg_address(struct octeon_device *oct, void *chip,
 				  struct octeon_reg_list *reg_list);
 u32 lio_cn6xxx_coprocessor_clock(struct octeon_device *oct);
 u32 lio_cn6xxx_get_oq_ticks(struct octeon_device *oct, u32 time_intr_in_us);
-int lio_setup_cn66xx_octeon_device(struct octeon_device *);
+int lio_setup_cn66xx_octeon_device(struct octeon_device *oct);
 int lio_validate_cn6xxx_config_info(struct octeon_device *oct,
-				    struct octeon_config *);
+				    struct octeon_config *conf6xxx);
 
 #endif
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
index f163e0a..1674522 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
@@ -757,9 +757,6 @@ static void lio_set_msglevel(struct net_device *netdev, u32 msglvl)
 	/*sum of oct->instr_queue[iq_no]->stats.tx_dropped */
 	data[i++] = CVM_CAST64(netstats->tx_dropped);
 
-	/*data[i++] = CVM_CAST64(stats->multicast); */
-	/*data[i++] = CVM_CAST64(stats->collisions); */
-
 	/* firmware tx stats */
 	/*per_core_stats[cvmx_get_core_num()].link_stats[mdata->from_ifidx].
 	 *fromhost.fw_total_sent
@@ -910,9 +907,8 @@ static void lio_set_msglevel(struct net_device *netdev, u32 msglvl)
 	/*lio->link_changes*/
 	data[i++] = CVM_CAST64(lio->link_changes);
 
-	/* TX  -- lio_update_stats(lio); */
 	for (j = 0; j < MAX_OCTEON_INSTR_QUEUES(oct_dev); j++) {
-		if (!(oct_dev->io_qmask.iq & (1ULL << j)))
+		if (!(oct_dev->io_qmask.iq & BIT_ULL(j)))
 			continue;
 		/*packets to network port*/
 		/*# of packets tx to network */
@@ -954,9 +950,8 @@ static void lio_set_msglevel(struct net_device *netdev, u32 msglvl)
 	}
 
 	/* RX */
-	/* for (j = 0; j < oct_dev->num_oqs; j++) { */
 	for (j = 0; j < MAX_OCTEON_OUTPUT_QUEUES(oct_dev); j++) {
-		if (!(oct_dev->io_qmask.oq & (1ULL << j)))
+		if (!(oct_dev->io_qmask.oq & BIT_ULL(j)))
 			continue;
 
 		/*packets send to TCP/IP network stack */
@@ -1030,7 +1025,7 @@ static void lio_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
 
 		num_iq_stats = ARRAY_SIZE(oct_iq_stats_strings);
 		for (i = 0; i < MAX_OCTEON_INSTR_QUEUES(oct_dev); i++) {
-			if (!(oct_dev->io_qmask.iq & (1ULL << i)))
+			if (!(oct_dev->io_qmask.iq & BIT_ULL(i)))
 				continue;
 			for (j = 0; j < num_iq_stats; j++) {
 				sprintf(data, "tx-%d-%s", i,
@@ -1040,9 +1035,8 @@ static void lio_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
 		}
 
 		num_oq_stats = ARRAY_SIZE(oct_droq_stats_strings);
-		/* for (i = 0; i < oct_dev->num_oqs; i++) { */
 		for (i = 0; i < MAX_OCTEON_OUTPUT_QUEUES(oct_dev); i++) {
-			if (!(oct_dev->io_qmask.oq & (1ULL << i)))
+			if (!(oct_dev->io_qmask.oq & BIT_ULL(i)))
 				continue;
 			for (j = 0; j < num_oq_stats; j++) {
 				sprintf(data, "rx-%d-%s", i,
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index eb46ffa..7e0bdbe 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -19,10 +19,8 @@
 * This file may also be available under a different license from Cavium.
 * Contact Cavium, Inc. for more information
 **********************************************************************/
-#include <linux/version.h>
 #include <linux/pci.h>
 #include <linux/firmware.h>
-#include <linux/ptp_clock_kernel.h>
 #include <net/vxlan.h>
 #include <linux/kthread.h>
 #include "liquidio_common.h"
@@ -201,9 +199,8 @@ static void octeon_droq_bh(unsigned long pdev)
 	struct octeon_device_priv *oct_priv =
 		(struct octeon_device_priv *)oct->priv;
 
-	/* for (q_no = 0; q_no < oct->num_oqs; q_no++) { */
 	for (q_no = 0; q_no < MAX_OCTEON_OUTPUT_QUEUES(oct); q_no++) {
-		if (!(oct->io_qmask.oq & (1ULL << q_no)))
+		if (!(oct->io_qmask.oq & BIT_ULL(q_no)))
 			continue;
 		reschedule |= octeon_droq_process_packets(oct, oct->droq[q_no],
 							  MAX_PACKET_BUDGET);
@@ -238,7 +235,7 @@ static int lio_wait_for_oq_pkts(struct octeon_device *oct)
 		pending_pkts = 0;
 
 		for (i = 0; i < MAX_OCTEON_OUTPUT_QUEUES(oct); i++) {
-			if (!(oct->io_qmask.oq & (1ULL << i)))
+			if (!(oct->io_qmask.oq & BIT_ULL(i)))
 				continue;
 			pkt_cnt += octeon_droq_check_hw_for_pkts(oct->droq[i]);
 		}
@@ -320,7 +317,7 @@ static inline void pcierror_quiesce_device(struct octeon_device *oct)
 	for (i = 0; i < MAX_OCTEON_INSTR_QUEUES(oct); i++) {
 		struct octeon_instr_queue *iq;
 
-		if (!(oct->io_qmask.iq & (1ULL << i)))
+		if (!(oct->io_qmask.iq & BIT_ULL(i)))
 			continue;
 		iq = oct->instr_queue[i];
 
@@ -386,7 +383,6 @@ static void stop_pci_io(struct octeon_device *oct)
 	dev_dbg(&oct->pci_dev->dev, "Device state is now %s\n",
 		lio_get_state_string(&oct->status));
 
-	/* cn63xx_cleanup_aer_uncorrect_error_status(oct->pci_dev); */
 	/* making it a common function for all OCTEON models */
 	cleanup_aer_uncorrect_error_status(oct->pci_dev);
 }
@@ -941,7 +937,6 @@ static inline void update_link_status(struct net_device *netdev,
 
 		if (lio->linfo.link.s.link_up) {
 			netif_carrier_on(netdev);
-			/* start_txq(netdev); */
 			txqs_wake(netdev);
 		} else {
 			netif_carrier_off(netdev);
@@ -1019,7 +1014,7 @@ static void liquidio_schedule_droq_pkt_handlers(struct octeon_device *oct)
 	if (oct->int_status & OCT_DEV_INTR_PKT_DATA) {
 		for (oq_no = 0; oq_no < MAX_OCTEON_OUTPUT_QUEUES(oct);
 		     oq_no++) {
-			if (!(oct->droq_intr & (1ULL << oq_no)))
+			if (!(oct->droq_intr & BIT_ULL(oq_no)))
 				continue;
 
 			droq = oct->droq[oq_no];
@@ -1468,7 +1463,7 @@ static void octeon_destroy_resources(struct octeon_device *oct)
 	/* fallthrough */
 	case OCT_DEV_IN_RESET:
 	case OCT_DEV_DROQ_INIT_DONE:
-		/*atomic_set(&oct->status, OCT_DEV_DROQ_INIT_DONE);*/
+		/* Wait for any pending operations */
 		mdelay(100);
 		for (i = 0; i < MAX_OCTEON_OUTPUT_QUEUES(oct); i++) {
 			if (!(oct->io_qmask.oq & BIT_ULL(i)))
@@ -2461,7 +2456,6 @@ static int liquidio_napi_poll(struct napi_struct *napi, int budget)
 		 * Return back if tx_done is false.
 		 */
 		update_txq_status(oct, iq_no);
-		/*tx_done = (iq->flush_index == iq->octeon_read_index);*/
 	} else {
 		dev_err(&oct->pci_dev->dev, "%s:  iq (%d) num invalid\n",
 			__func__, iq_no);
diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
index edf1282..1d2eba7 100644
--- a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
+++ b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
@@ -68,8 +68,6 @@ enum octeon_tag_type {
  */
 #define OPCODE_CORE 0           /* used for generic core operations */
 #define OPCODE_NIC  1           /* used for NIC operations */
-#define OPCODE_LAST OPCODE_NIC
-
 /* Subcodes are used by host driver/apps to identify the sub-operation
  * for the core. They only need to by unique for a given subsystem.
  */
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.c b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
index 295e2ca..278c880 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
@@ -649,12 +649,12 @@ void octeon_free_device_mem(struct octeon_device *oct)
 	int i;
 
 	for (i = 0; i < MAX_OCTEON_OUTPUT_QUEUES(oct); i++) {
-		if (oct->io_qmask.oq & (1ULL << i))
+		if (oct->io_qmask.oq & BIT_ULL(i))
 			vfree(oct->droq[i]);
 	}
 
 	for (i = 0; i < MAX_OCTEON_INSTR_QUEUES(oct); i++) {
-		if (oct->io_qmask.iq & (1ULL << i))
+		if (oct->io_qmask.iq & BIT_ULL(i))
 			vfree(oct->instr_queue[i]);
 	}
 
@@ -1148,7 +1148,7 @@ int octeon_get_tx_qsize(struct octeon_device *oct, u32 q_no)
 
 {
 	if (oct && (q_no < MAX_OCTEON_INSTR_QUEUES(oct)) &&
-	    (oct->io_qmask.iq & (1ULL << q_no)))
+	    (oct->io_qmask.iq & BIT_ULL(q_no)))
 		return oct->instr_queue[q_no]->max_count;
 
 	return -1;
@@ -1157,7 +1157,7 @@ int octeon_get_tx_qsize(struct octeon_device *oct, u32 q_no)
 int octeon_get_rx_qsize(struct octeon_device *oct, u32 q_no)
 {
 	if (oct && (q_no < MAX_OCTEON_OUTPUT_QUEUES(oct)) &&
-	    (oct->io_qmask.oq & (1ULL << q_no)))
+	    (oct->io_qmask.oq & BIT_ULL(q_no)))
 		return oct->droq[q_no]->max_count;
 	return -1;
 }
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
index 886987f..8f6fc95 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
@@ -337,7 +337,7 @@ int octeon_init_droq(struct octeon_device *oct,
 	/* For 56xx Pass1, this function won't be called, so no checks. */
 	oct->fn_list.setup_oq_regs(oct, q_no);
 
-	oct->io_qmask.oq |= (1ULL << q_no);
+	oct->io_qmask.oq |= BIT_ULL(q_no);
 
 	return 0;
 
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_droq.h b/drivers/net/ethernet/cavium/liquidio/octeon_droq.h
index 5be002d..d591f5f 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_droq.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_droq.h
@@ -121,7 +121,6 @@ struct oct_droq_stats {
 	/** Num of Packets dropped due to receive path failures. */
 	u64 rx_dropped;
 
-	/** Num of vxlan packets received; */
 	u64 rx_vxlan;
 
 	/** Num of failures of recv_buffer_alloc() */
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_iq.h b/drivers/net/ethernet/cavium/liquidio/octeon_iq.h
index e4d426b..b493e67 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_iq.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_iq.h
@@ -69,7 +69,6 @@ struct oct_iq_stats {
 	u64 tx_vxlan; /* tunnel */
 	u64 tx_dmamap_fail;
 	u64 tx_restart;
-	/*u64 tx_timeout_count;*/
 };
 
 #define OCT_IQ_STATS_SIZE   (sizeof(struct oct_iq_stats))
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_main.h b/drivers/net/ethernet/cavium/liquidio/octeon_main.h
index 3afa61e..db86c63 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_main.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_main.h
@@ -207,24 +207,6 @@ static inline int octeon_map_pci_barx(struct octeon_device *oct,
 	return errno;
 }
 
-static inline void
-sleep_atomic_cond(wait_queue_head_t *waitq, atomic_t *pcond)
-{
-	wait_queue_t we;
-
-	init_waitqueue_entry(&we, current);
-	add_wait_queue(waitq, &we);
-	while (!atomic_read(pcond)) {
-		set_current_state(TASK_INTERRUPTIBLE);
-		if (signal_pending(current))
-			goto out;
-		schedule();
-	}
-out:
-	set_current_state(TASK_RUNNING);
-	remove_wait_queue(waitq, &we);
-}
-
 /* Gives up the CPU for a timeout period.
  * Check that the condition is not true before we go to sleep for a
  * timeout period.
diff --git a/drivers/net/ethernet/cavium/liquidio/request_manager.c b/drivers/net/ethernet/cavium/liquidio/request_manager.c
index a73560c..f6e1616 100644
--- a/drivers/net/ethernet/cavium/liquidio/request_manager.c
+++ b/drivers/net/ethernet/cavium/liquidio/request_manager.c
@@ -145,7 +145,7 @@ int octeon_init_instr_queue(struct octeon_device *oct,
 
 	spin_lock_init(&iq->iq_flush_running_lock);
 
-	oct->io_qmask.iq |= (1ULL << iq_no);
+	oct->io_qmask.iq |= BIT_ULL(iq_no);
 
 	/* Set the 32B/64B mode for each input queue */
 	oct->io_qmask.iq64B |= ((conf->instr_type == 64) << iq_no);
@@ -252,9 +252,8 @@ int lio_wait_for_instr_fetch(struct octeon_device *oct)
 	do {
 		instr_cnt = 0;
 
-		/*for (i = 0; i < oct->num_iqs; i++) {*/
 		for (i = 0; i < MAX_OCTEON_INSTR_QUEUES(oct); i++) {
-			if (!(oct->io_qmask.iq & (1ULL << i)))
+			if (!(oct->io_qmask.iq & BIT_ULL(i)))
 				continue;
 			pending =
 			    atomic_read(&oct->
@@ -579,8 +578,6 @@ static void check_db_timeout(struct work_struct *work)
 	/* This is only done here to expedite packets being flushed
 	 * for cases where there are no IQ completion interrupts.
 	 */
-	/*if (iq->do_auto_flush)*/
-	/*	octeon_flush_iq(oct, iq, 2, 0);*/
 
 	return st.status;
 }
diff --git a/drivers/net/ethernet/cavium/liquidio/response_manager.c b/drivers/net/ethernet/cavium/liquidio/response_manager.c
index be52178d..9e496c1 100644
--- a/drivers/net/ethernet/cavium/liquidio/response_manager.c
+++ b/drivers/net/ethernet/cavium/liquidio/response_manager.c
@@ -81,11 +81,7 @@ int lio_process_ordered_list(struct octeon_device *octeon_dev,
 		spin_lock_bh(&ordered_sc_list->lock);
 
 		if (ordered_sc_list->head.next == &ordered_sc_list->head) {
-			/* ordered_sc_list is empty; there is
-			 * nothing to process
-			 */
-			spin_unlock_bh
-			    (&ordered_sc_list->lock);
+			spin_unlock_bh(&ordered_sc_list->lock);
 			return 1;
 		}
 
diff --git a/drivers/net/ethernet/cavium/liquidio/response_manager.h b/drivers/net/ethernet/cavium/liquidio/response_manager.h
index 7a48752..d377faf 100644
--- a/drivers/net/ethernet/cavium/liquidio/response_manager.h
+++ b/drivers/net/ethernet/cavium/liquidio/response_manager.h
@@ -85,7 +85,6 @@ enum {
 /**  A value of 0x00000000 indicates no error i.e. success */
 #define DRIVER_ERROR_NONE                 0x00000000
 
-/**  (Major number: 0x0000; Minor Number: 0x0001) */
 #define DRIVER_ERROR_REQ_PENDING          0x00000001
 #define DRIVER_ERROR_REQ_TIMEOUT          0x00000003
 #define DRIVER_ERROR_REQ_EINTR            0x00000004
-- 
1.8.3.1
