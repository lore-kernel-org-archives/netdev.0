From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next 02/10] liquidio: Macro replacements
Date: Tue, 28 Jun 2016 17:54:24 -0700
Message-ID: <1467161672-21063-3-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1467161672-21063-1-git-send-email-rvatsavayi@caviumnetworks.com>
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
Received: from mail-by2on0059.outbound.protection.outlook.com ([207.46.100.59]:46448
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752423AbcF2AzK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jun 2016 20:55:10 -0400
In-Reply-To: <1467161672-21063-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch has minor replacements of ACCESS_ONCE macros with
WRITE_ONCE and replacement of BUG_ON with polite version WARN_ON.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
---
 .../net/ethernet/cavium/liquidio/cn66xx_device.c   |  2 +-
 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c | 13 +++---
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 41 ++++++++++--------
 .../net/ethernet/cavium/liquidio/octeon_console.c  | 18 ++++----
 .../net/ethernet/cavium/liquidio/octeon_device.h   |  2 +-
 drivers/net/ethernet/cavium/liquidio/octeon_droq.c |  5 +--
 drivers/net/ethernet/cavium/liquidio/octeon_droq.h |  3 +-
 drivers/net/ethernet/cavium/liquidio/octeon_main.h |  2 +-
 .../net/ethernet/cavium/liquidio/octeon_mem_ops.c  |  9 ++--
 .../net/ethernet/cavium/liquidio/octeon_network.h  |  2 +-
 .../net/ethernet/cavium/liquidio/request_manager.c | 48 ++++------------------
 11 files changed, 58 insertions(+), 87 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c b/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c
index d35864a..b923c7f 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c
@@ -579,7 +579,7 @@ int lio_cn6xxx_process_droq_intr_regs(struct octeon_device *oct)
 			continue;
 
 		droq = oct->droq[oq_no];
-		pkt_count = octeon_droq_check_hw_for_pkts(oct, droq);
+		pkt_count = octeon_droq_check_hw_for_pkts(droq);
 		if (pkt_count) {
 			oct->droq_intr |= (1ULL << oq_no);
 			if (droq->ops.poll_mode) {
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
index a060586..81c3b58 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
@@ -357,9 +357,9 @@ static void octnet_mdio_resp_callback(struct octeon_device *oct,
 	if (status) {
 		dev_err(&oct->pci_dev->dev, "MIDO instruction failed. Status: %llx\n",
 			CVM_CAST64(status));
-		ACCESS_ONCE(mdio_cmd_ctx->cond) = -1;
+		WRITE_ONCE(mdio_cmd_ctx->cond, -1);
 	} else {
-		ACCESS_ONCE(mdio_cmd_ctx->cond) = 1;
+		WRITE_ONCE(mdio_cmd_ctx->cond, 1);
 	}
 	wake_up_interruptible(&mdio_cmd_ctx->wc);
 }
@@ -390,7 +390,7 @@ octnet_mdio45_access(struct lio *lio, int op, int loc, int *value)
 	mdio_cmd_rsp = (struct oct_mdio_cmd_resp *)sc->virtrptr;
 	mdio_cmd = (struct oct_mdio_cmd *)sc->virtdptr;
 
-	ACCESS_ONCE(mdio_cmd_ctx->cond) = 0;
+	WRITE_ONCE(mdio_cmd_ctx->cond, 0);
 	mdio_cmd_ctx->octeon_id = lio_get_device_id(oct_dev);
 	mdio_cmd->op = op;
 	mdio_cmd->mdio_addr = loc;
@@ -429,7 +429,7 @@ octnet_mdio45_access(struct lio *lio, int op, int loc, int *value)
 			octeon_swap_8B_data((u64 *)(&mdio_cmd_rsp->resp),
 					    sizeof(struct oct_mdio_cmd) / 8);
 
-			if (ACCESS_ONCE(mdio_cmd_ctx->cond) == 1) {
+			if (READ_ONCE(mdio_cmd_ctx->cond) == 1) {
 				if (!op)
 					*value = mdio_cmd_rsp->resp.value1;
 			} else {
@@ -623,7 +623,8 @@ lio_get_pauseparam(struct net_device *netdev, struct ethtool_pauseparam *pause)
 
 static void
 lio_get_ethtool_stats(struct net_device *netdev,
-		      struct ethtool_stats *stats, u64 *data)
+		      struct ethtool_stats *stats  __attribute__((unused)),
+		      u64 *data)
 {
 	struct lio *lio = GET_LIO(netdev);
 	struct octeon_device *oct_dev = lio->oct_dev;
@@ -1552,7 +1553,7 @@ static int lio_nway_reset(struct net_device *netdev)
 }
 
 /* Return register dump len. */
-static int lio_get_regs_len(struct net_device *dev)
+static int lio_get_regs_len(struct net_device *dev __attribute__((unused)))
 {
 	return OCT_ETHTOOL_REGDUMP_LEN;
 }
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 9530df8..eda593a 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -251,8 +251,7 @@ static int lio_wait_for_oq_pkts(struct octeon_device *oct)
 		for (i = 0; i < MAX_OCTEON_OUTPUT_QUEUES(oct); i++) {
 			if (!(oct->io_qmask.oq & (1ULL << i)))
 				continue;
-			pkt_cnt += octeon_droq_check_hw_for_pkts(oct,
-								 oct->droq[i]);
+			pkt_cnt += octeon_droq_check_hw_for_pkts(oct->droq[i]);
 		}
 		if (pkt_cnt > 0) {
 			pending_pkts += pkt_cnt;
@@ -507,7 +506,8 @@ static pci_ers_result_t liquidio_pcie_error_detected(struct pci_dev *pdev,
  * \brief mmio handler
  * @param pdev Pointer to PCI device
  */
-static pci_ers_result_t liquidio_pcie_mmio_enabled(struct pci_dev *pdev)
+static pci_ers_result_t liquidio_pcie_mmio_enabled(
+				struct pci_dev *pdev __attribute__((unused)))
 {
 	/* We should never hit this since we never ask for a reset for a Fatal
 	 * Error. We always return DISCONNECT in io_error above.
@@ -523,7 +523,8 @@ static pci_ers_result_t liquidio_pcie_mmio_enabled(struct pci_dev *pdev)
  * Restart the card from scratch, as if from a cold-boot. Implementation
  * resembles the first-half of the octeon_resume routine.
  */
-static pci_ers_result_t liquidio_pcie_slot_reset(struct pci_dev *pdev)
+static pci_ers_result_t liquidio_pcie_slot_reset(
+				struct pci_dev *pdev __attribute__((unused)))
 {
 	/* We should never hit this since we never ask for a reset for a Fatal
 	 * Error. We always return DISCONNECT in io_error above.
@@ -540,7 +541,7 @@ static pci_ers_result_t liquidio_pcie_slot_reset(struct pci_dev *pdev)
  * its OK to resume normal operation. Implementation resembles the
  * second-half of the octeon_resume routine.
  */
-static void liquidio_pcie_resume(struct pci_dev *pdev)
+static void liquidio_pcie_resume(struct pci_dev *pdev __attribute__((unused)))
 {
 	/* Nothing to be done here. */
 }
@@ -551,7 +552,8 @@ static void liquidio_pcie_resume(struct pci_dev *pdev)
  * @param pdev Pointer to PCI device
  * @param state state to suspend to
  */
-static int liquidio_suspend(struct pci_dev *pdev, pm_message_t state)
+static int liquidio_suspend(struct pci_dev *pdev __attribute__((unused)),
+			    pm_message_t state __attribute__((unused)))
 {
 	return 0;
 }
@@ -560,7 +562,7 @@ static int liquidio_suspend(struct pci_dev *pdev, pm_message_t state)
  * \brief called when resuming
  * @param pdev Pointer to PCI device
  */
-static int liquidio_resume(struct pci_dev *pdev)
+static int liquidio_resume(struct pci_dev *pdev __attribute__((unused)))
 {
 	return 0;
 }
@@ -1104,7 +1106,9 @@ static int octeon_setup_interrupt(struct octeon_device *oct)
  * @param pdev PCI device structure
  * @param ent unused
  */
-static int liquidio_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
+static int
+liquidio_probe(struct pci_dev *pdev,
+	       const struct pci_device_id *ent __attribute__((unused)))
 {
 	struct octeon_device *oct_dev = NULL;
 	struct handshake *hs;
@@ -1724,8 +1728,10 @@ static int liquidio_ptp_settime(struct ptp_clock_info *ptp,
  * @param rq request
  * @param on is it on
  */
-static int liquidio_ptp_enable(struct ptp_clock_info *ptp,
-			       struct ptp_clock_request *rq, int on)
+static int
+liquidio_ptp_enable(struct ptp_clock_info *ptp __attribute__((unused)),
+		    struct ptp_clock_request *rq __attribute__((unused)),
+		    int on __attribute__((unused)))
 {
 	return -EOPNOTSUPP;
 }
@@ -1866,7 +1872,7 @@ static int octeon_setup_droq(struct octeon_device *oct, int q_no, int num_descs,
  * @param buf pointer to resp structure
  */
 static void if_cfg_callback(struct octeon_device *oct,
-			    u32 status,
+			    u32 status __attribute__((unused)),
 			    void *buf)
 {
 	struct octeon_soft_command *sc = (struct octeon_soft_command *)buf;
@@ -1880,7 +1886,7 @@ static void if_cfg_callback(struct octeon_device *oct,
 	if (resp->status)
 		dev_err(&oct->pci_dev->dev, "nic if cfg instruction failed. Status: %llx\n",
 			CVM_CAST64(resp->status));
-	ACCESS_ONCE(ctx->cond) = 1;
+	WRITE_ONCE(ctx->cond, 1);
 
 	snprintf(oct->fw_info.liquidio_firmware_version, 32, "%s",
 		 resp->cfg_info.liquidio_firmware_version);
@@ -1900,7 +1906,8 @@ static void if_cfg_callback(struct octeon_device *oct,
  * @returns selected queue number
  */
 static u16 select_q(struct net_device *dev, struct sk_buff *skb,
-		    void *accel_priv, select_queue_fallback_t fallback)
+		    void *accel_priv __attribute__((unused)),
+		    select_queue_fallback_t fallback __attribute__((unused)))
 {
 	u32 qindex = 0;
 	struct lio *lio;
@@ -1920,7 +1927,7 @@ static u16 select_q(struct net_device *dev, struct sk_buff *skb,
  * @param arg	   - farg registered in droq_ops
  */
 static void
-liquidio_push_packet(u32 octeon_id,
+liquidio_push_packet(u32 octeon_id __attribute__((unused)),
 		     void *skbuff,
 		     u32 len,
 		     union octeon_rh *rh,
@@ -2717,7 +2724,7 @@ static int liquidio_change_mtu(struct net_device *netdev, int new_mtu)
  * @param ifr interface request
  * @param cmd command
  */
-static int hwtstamp_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
+static int hwtstamp_ioctl(struct net_device *netdev, struct ifreq *ifr)
 {
 	struct hwtstamp_config conf;
 	struct lio *lio = GET_LIO(netdev);
@@ -2778,7 +2785,7 @@ static int liquidio_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 {
 	switch (cmd) {
 	case SIOCSHWTSTAMP:
-		return hwtstamp_ioctl(netdev, ifr, cmd);
+		return hwtstamp_ioctl(netdev, ifr);
 	default:
 		return -EOPNOTSUPP;
 	}
@@ -3560,7 +3567,7 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 		dev_dbg(&octeon_dev->pci_dev->dev,
 			"requesting config for interface %d, iqs %d, oqs %d\n",
 			ifidx_or_pfnum, num_iqueues, num_oqueues);
-		ACCESS_ONCE(ctx->cond) = 0;
+		WRITE_ONCE(ctx->cond, 0);
 		ctx->octeon_id = lio_get_device_id(octeon_dev);
 		init_waitqueue_head(&ctx->wc);
 
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_console.c b/drivers/net/ethernet/cavium/liquidio/octeon_console.c
index 466147e..f96a9d6 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_console.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_console.c
@@ -170,8 +170,8 @@ struct octeon_pci_console_desc {
 				offsetof(struct cvmx_bootmem_desc, field),   \
 				SIZEOF_FIELD(struct cvmx_bootmem_desc, field))
 
-#define __cvmx_bootmem_lock(flags)
-#define __cvmx_bootmem_unlock(flags)
+#define __cvmx_bootmem_lock(flags)	(flags = flags)
+#define __cvmx_bootmem_unlock(flags)	(flags = flags)
 
 /**
  * This macro returns a member of the
@@ -440,8 +440,7 @@ int octeon_wait_for_bootloader(struct octeon_device *oct,
 }
 
 static void octeon_console_handle_result(struct octeon_device *oct,
-					 size_t console_num,
-					 char *buffer, s32 bytes_read)
+					 size_t console_num)
 {
 	struct octeon_console *console;
 
@@ -505,14 +504,11 @@ static void check_console(struct work_struct *work)
 		 */
 		bytes_read =
 			octeon_console_read(oct, console_num, console_buffer,
-					    sizeof(console_buffer) - 1, 0);
+					    sizeof(console_buffer) - 1);
 		if (bytes_read > 0) {
 			total_read += bytes_read;
-			if (console->waiting) {
-				octeon_console_handle_result(oct, console_num,
-							     console_buffer,
-							     bytes_read);
-			}
+			if (console->waiting)
+				octeon_console_handle_result(oct, console_num);
 			if (octeon_console_debug_enabled(console_num)) {
 				output_console_line(oct, console, console_num,
 						    console_buffer, bytes_read);
@@ -676,7 +672,7 @@ static inline int octeon_console_avail_bytes(u32 buffer_size,
 }
 
 int octeon_console_read(struct octeon_device *oct, u32 console_num,
-			char *buffer, u32 buf_size, u32 flags)
+			char *buffer, u32 buf_size)
 {
 	int bytes_to_read;
 	u32 rd_idx, wr_idx;
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.h b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
index b4e566d..d477222 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
@@ -586,7 +586,7 @@ int octeon_console_write(struct octeon_device *oct, u32 console_num,
 			 char *buffer, u32 write_request_size, u32 flags);
 int octeon_console_write_avail(struct octeon_device *oct, u32 console_num);
 int octeon_console_read(struct octeon_device *oct, u32 console_num,
-			char *buffer, u32 buf_size, u32 flags);
+			char *buffer, u32 buf_size);
 int octeon_console_read_avail(struct octeon_device *oct, u32 console_num);
 
 /** Removes all attached consoles. */
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
index d9bb2f7..d37a314 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
@@ -104,8 +104,7 @@ static inline void *octeon_get_dispatch_arg(struct octeon_device *octeon_dev,
 	return fn_arg;
 }
 
-u32 octeon_droq_check_hw_for_pkts(struct octeon_device *oct,
-				  struct octeon_droq *droq)
+u32 octeon_droq_check_hw_for_pkts(struct octeon_droq *droq)
 {
 	u32 pkt_count = 0;
 
@@ -810,7 +809,7 @@ octeon_droq_process_poll_pkts(struct octeon_device *oct,
 
 		total_pkts_processed += pkts_processed;
 
-		octeon_droq_check_hw_for_pkts(oct, droq);
+		octeon_droq_check_hw_for_pkts(droq);
 	}
 
 	spin_unlock(&droq->lock);
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_droq.h b/drivers/net/ethernet/cavium/liquidio/octeon_droq.h
index 886772c..78a411c 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_droq.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_droq.h
@@ -432,8 +432,7 @@ int octeon_unregister_dispatch_fn(struct octeon_device *oct,
 
 void octeon_droq_print_stats(void);
 
-u32 octeon_droq_check_hw_for_pkts(struct octeon_device *oct,
-				  struct octeon_droq *droq);
+u32 octeon_droq_check_hw_for_pkts(struct octeon_droq *droq);
 
 int octeon_create_droq(struct octeon_device *oct, u32 q_no,
 		       u32 num_descs, u32 desc_size, void *app_ctx);
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_main.h b/drivers/net/ethernet/cavium/liquidio/octeon_main.h
index 0ff3efc..bc14e4c 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_main.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_main.h
@@ -174,7 +174,7 @@ sleep_cond(wait_queue_head_t *wait_queue, int *condition)
 
 	init_waitqueue_entry(&we, current);
 	add_wait_queue(wait_queue, &we);
-	while (!(ACCESS_ONCE(*condition))) {
+	while (!(READ_ONCE(*condition))) {
 		set_current_state(TASK_INTERRUPTIBLE);
 		if (signal_pending(current))
 			goto out;
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.c b/drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.c
index 5aecef8..39c07e9 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.c
@@ -44,18 +44,19 @@
 
 #define MEMOPS_IDX   MAX_BAR1_MAP_INDEX
 
+#ifdef __BIG_ENDIAN_BITFIELD
 static inline void
-octeon_toggle_bar1_swapmode(struct octeon_device *oct __attribute__((unused)),
-			    u32 idx __attribute__((unused)))
+octeon_toggle_bar1_swapmode(struct octeon_device *oct, u32 idx)
 {
-#ifdef __BIG_ENDIAN_BITFIELD
 	u32 mask;
 
 	mask = oct->fn_list.bar1_idx_read(oct, idx);
 	mask = (mask & 0x2) ? (mask & ~2) : (mask | 2);
 	oct->fn_list.bar1_idx_write(oct, idx, mask);
-#endif
 }
+#else
+#define octeon_toggle_bar1_swapmode(oct, idx)
+#endif
 
 static void
 octeon_pci_fastwrite(struct octeon_device *oct, u8 __iomem *mapped_addr,
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_network.h b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
index d0581e6..4489fc4 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_network.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
@@ -359,7 +359,7 @@ lio_map_ring_info(struct octeon_droq *droq, u32 i)
 	dma_addr = dma_map_single(&oct->pci_dev->dev, &droq->info_list[i],
 				  OCT_DROQ_INFO_SIZE, DMA_FROM_DEVICE);
 
-	BUG_ON(dma_mapping_error(&oct->pci_dev->dev, dma_addr));
+	WARN_ON(dma_mapping_error(&oct->pci_dev->dev, dma_addr));
 
 	return (u64)dma_addr;
 }
diff --git a/drivers/net/ethernet/cavium/liquidio/request_manager.c b/drivers/net/ethernet/cavium/liquidio/request_manager.c
index 7eafa75..8c82ccf 100644
--- a/drivers/net/ethernet/cavium/liquidio/request_manager.c
+++ b/drivers/net/ethernet/cavium/liquidio/request_manager.c
@@ -301,40 +301,8 @@ static inline void __copy_cmd_into_iq(struct octeon_instr_queue *iq,
 	memcpy(iqptr, cmd, cmdsize);
 }
 
-static inline int
-__post_command(struct octeon_device *octeon_dev __attribute__((unused)),
-	       struct octeon_instr_queue *iq,
-	       u32 force_db __attribute__((unused)), u8 *cmd)
-{
-	u32 index = -1;
-
-	/* This ensures that the read index does not wrap around to the same
-	 * position if queue gets full before Octeon could fetch any instr.
-	 */
-	if (atomic_read(&iq->instr_pending) >= (s32)(iq->max_count - 1))
-		return -1;
-
-	__copy_cmd_into_iq(iq, cmd);
-
-	/* "index" is returned, host_write_index is modified. */
-	index = iq->host_write_index;
-	INCR_INDEX_BY1(iq->host_write_index, iq->max_count);
-	iq->fill_cnt++;
-
-	/* Flush the command into memory. We need to be sure the data is in
-	 * memory before indicating that the instruction is pending.
-	 */
-	wmb();
-
-	atomic_inc(&iq->instr_pending);
-
-	return index;
-}
-
 static inline struct iq_post_status
-__post_command2(struct octeon_device *octeon_dev __attribute__((unused)),
-		struct octeon_instr_queue *iq,
-		u32 force_db __attribute__((unused)), u8 *cmd)
+__post_command2(struct octeon_instr_queue *iq, u8 *cmd)
 {
 	struct iq_post_status st;
 
@@ -579,7 +547,7 @@ octeon_send_command(struct octeon_device *oct, u32 iq_no,
 	 */
 	spin_lock_bh(&iq->post_lock);
 
-	st = __post_command2(oct, iq, force_db, cmd);
+	st = __post_command2(iq, cmd);
 
 	if (st.status != IQ_SEND_FAILED) {
 		octeon_report_sent_bytes_to_bql(buf, reqtype);
@@ -618,8 +586,8 @@ octeon_prepare_soft_command(struct octeon_device *oct,
 	struct octeon_instr_irh *irh;
 	struct octeon_instr_rdp *rdp;
 
-	BUG_ON(opcode > 15);
-	BUG_ON(subcode > 127);
+	WARN_ON(opcode > 15);
+	WARN_ON(subcode > 127);
 
 	oct_cfg = octeon_get_conf(oct);
 
@@ -671,8 +639,8 @@ int octeon_send_soft_command(struct octeon_device *oct,
 	}
 	irh = (struct octeon_instr_irh *)&sc->cmd.cmd2.irh;
 	if (irh->rflag) {
-		BUG_ON(!sc->dmarptr);
-		BUG_ON(!sc->status_word);
+		WARN_ON(!sc->dmarptr);
+		WARN_ON(!sc->status_word);
 		*sc->status_word = COMPLETION_WORD_INIT;
 
 		rdp = (struct octeon_instr_rdp *)&sc->cmd.cmd2.rdp;
@@ -748,7 +716,7 @@ struct octeon_soft_command *octeon_alloc_soft_command(struct octeon_device *oct,
 	struct octeon_soft_command *sc = NULL;
 	struct list_head *tmp;
 
-	BUG_ON((offset + datasize + rdatasize + ctxsize) >
+	WARN_ON((offset + datasize + rdatasize + ctxsize) >
 	       SOFT_COMMAND_BUFFER_SIZE);
 
 	spin_lock(&oct->sc_buf_pool.lock);
@@ -795,7 +763,7 @@ struct octeon_soft_command *octeon_alloc_soft_command(struct octeon_device *oct,
 	offset = (offset + datasize + 127) & 0xffffff80;
 
 	if (rdatasize) {
-		BUG_ON(rdatasize < 16);
+		WARN_ON(rdatasize < 16);
 		sc->virtrptr = (u8 *)sc + offset;
 		sc->dmarptr = dma_addr + offset;
 		sc->rdatasize = rdatasize;
-- 
1.8.3.1
