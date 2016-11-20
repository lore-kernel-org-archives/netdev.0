From: Netanel Belgazal <netanel@annapurnalabs.com>
Subject: [PATCH net 05/18] net/ena: add hardware hints capability to the driver
Date: Sun, 20 Nov 2016 10:45:34 +0200
Message-ID: <1479631547-29354-6-git-send-email-netanel@annapurnalabs.com>
References: <1479631547-29354-1-git-send-email-netanel@annapurnalabs.com>
Cc: Netanel Belgazal <netanel@annapurnalabs.com>, dwmw@amazon.com,
        zorik@annapurnalabs.com, alex@annapurnalabs.com,
        saeed@annapurnalabs.com, msw@amazon.com, aliguori@amazon.com,
        nafea@annapurnalabs.com
To: linux-kernel@vger.kernel.org, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479631547-29354-1-git-send-email-netanel@annapurnalabs.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ENA device can update the ena driver about the desire timeouts.
The hardware hints are transmitted as Asynchronous event to the driver.

In case the device does not support this capability, the driver
will use its own defines.

Signed-off-by: Netanel Belgazal <netanel@annapurnalabs.com>
---
 drivers/net/ethernet/amazon/ena/ena_admin_defs.h | 31 +++++++++
 drivers/net/ethernet/amazon/ena/ena_com.c        | 41 ++++++++---
 drivers/net/ethernet/amazon/ena/ena_com.h        |  5 ++
 drivers/net/ethernet/amazon/ena/ena_ethtool.c    |  1 -
 drivers/net/ethernet/amazon/ena/ena_netdev.c     | 86 +++++++++++++++++++-----
 drivers/net/ethernet/amazon/ena/ena_netdev.h     | 19 +++++-
 drivers/net/ethernet/amazon/ena/ena_regs_defs.h  |  2 +
 7 files changed, 157 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_admin_defs.h b/drivers/net/ethernet/amazon/ena/ena_admin_defs.h
index a46e749..51b2a92 100644
--- a/drivers/net/ethernet/amazon/ena/ena_admin_defs.h
+++ b/drivers/net/ethernet/amazon/ena/ena_admin_defs.h
@@ -70,6 +70,8 @@ enum ena_admin_aq_feature_id {
 
 	ENA_ADMIN_MAX_QUEUES_NUM		= 2,
 
+	ENA_ADMIN_HW_HINTS			= 3,
+
 	ENA_ADMIN_RSS_HASH_FUNCTION		= 10,
 
 	ENA_ADMIN_STATELESS_OFFLOAD_CONFIG	= 11,
@@ -749,6 +751,31 @@ struct ena_admin_feature_rss_ind_table {
 	struct ena_admin_rss_ind_table_entry inline_entry;
 };
 
+/* When hint value is 0, driver should use it's own predefined value */
+struct ena_admin_ena_hw_hints {
+	/* value in ms */
+	u16 mmio_read_timeout;
+
+	/* value in ms */
+	u16 driver_watchdog_timeout;
+
+	/* Per packet tx completion timeout. value in ms */
+	u16 missing_tx_completion_timeout;
+
+	u16 missed_tx_completion_count_threshold_to_reset;
+
+	/* value in ms */
+	u16 admin_completion_tx_timeout;
+
+	u16 netdev_wd_timeout;
+
+	u16 max_tx_sgl_size;
+
+	u16 max_rx_sgl_size;
+
+	u16 reserved[8];
+};
+
 struct ena_admin_get_feat_cmd {
 	struct ena_admin_aq_common_desc aq_common_descriptor;
 
@@ -782,6 +809,8 @@ struct ena_admin_get_feat_resp {
 		struct ena_admin_feature_rss_ind_table ind_table;
 
 		struct ena_admin_feature_intr_moder_desc intr_moderation;
+
+		struct ena_admin_ena_hw_hints hw_hints;
 	} u;
 };
 
@@ -857,6 +886,8 @@ enum ena_admin_aenq_notification_syndrom {
 	ENA_ADMIN_SUSPEND	= 0,
 
 	ENA_ADMIN_RESUME	= 1,
+
+	ENA_ADMIN_UPDATE_HINTS	= 2,
 };
 
 struct ena_admin_aenq_entry {
diff --git a/drivers/net/ethernet/amazon/ena/ena_com.c b/drivers/net/ethernet/amazon/ena/ena_com.c
index 6bd2b9b..366c2c5 100644
--- a/drivers/net/ethernet/amazon/ena/ena_com.c
+++ b/drivers/net/ethernet/amazon/ena/ena_com.c
@@ -508,15 +508,13 @@ static int ena_com_comp_status_to_errno(u8 comp_status)
 static int ena_com_wait_and_process_admin_cq_polling(struct ena_comp_ctx *comp_ctx,
 						     struct ena_com_admin_queue *admin_queue)
 {
-	unsigned long flags;
-	u32 start_time;
+	unsigned long flags, timeout;
 	int ret;
 
-	start_time = ((u32)jiffies_to_usecs(jiffies));
+	timeout = jiffies + usecs_to_jiffies(admin_queue->completion_timeout);
 
 	while (comp_ctx->status == ENA_CMD_SUBMITTED) {
-		if ((((u32)jiffies_to_usecs(jiffies)) - start_time) >
-		    ADMIN_CMD_TIMEOUT_US) {
+		if (time_is_before_jiffies(timeout)) {
 			pr_err("Wait for completion (polling) timeout\n");
 			/* ENA didn't have any completion */
 			spin_lock_irqsave(&admin_queue->q_lock, flags);
@@ -560,7 +558,8 @@ static int ena_com_wait_and_process_admin_cq_interrupts(struct ena_comp_ctx *com
 	int ret;
 
 	wait_for_completion_timeout(&comp_ctx->wait_event,
-				    usecs_to_jiffies(ADMIN_CMD_TIMEOUT_US));
+				    usecs_to_jiffies(
+					    admin_queue->completion_timeout));
 
 	/* In case the command wasn't completed find out the root cause.
 	 * There might be 2 kinds of errors
@@ -600,12 +599,14 @@ static u32 ena_com_reg_bar_read32(struct ena_com_dev *ena_dev, u16 offset)
 	struct ena_com_mmio_read *mmio_read = &ena_dev->mmio_read;
 	volatile struct ena_admin_ena_mmio_req_read_less_resp *read_resp =
 		mmio_read->read_resp;
-	u32 mmio_read_reg, ret;
+	u32 mmio_read_reg, timeout, ret;
 	unsigned long flags;
 	int i;
 
 	might_sleep();
 
+	timeout = mmio_read->reg_read_to ? : ENA_REG_READ_TIMEOUT;
+
 	/* If readless is disabled, perform regular read */
 	if (!mmio_read->readless_supported)
 		return readl(ena_dev->reg_bar + offset);
@@ -626,14 +627,14 @@ static u32 ena_com_reg_bar_read32(struct ena_com_dev *ena_dev, u16 offset)
 
 	writel(mmio_read_reg, ena_dev->reg_bar + ENA_REGS_MMIO_REG_READ_OFF);
 
-	for (i = 0; i < ENA_REG_READ_TIMEOUT; i++) {
+	for (i = 0; i < timeout; i++) {
 		if (read_resp->req_id == mmio_read->seq_num)
 			break;
 
 		udelay(1);
 	}
 
-	if (unlikely(i == ENA_REG_READ_TIMEOUT)) {
+	if (unlikely(i == timeout)) {
 		pr_err("reading reg failed for timeout. expected: req id[%hu] offset[%hu] actual: req id[%hu] offset[%hu]\n",
 		       mmio_read->seq_num, offset, read_resp->req_id,
 		       read_resp->reg_off);
@@ -1723,6 +1724,20 @@ int ena_com_get_dev_attr_feat(struct ena_com_dev *ena_dev,
 	memcpy(&get_feat_ctx->offload, &get_resp.u.offload,
 	       sizeof(get_resp.u.offload));
 
+	/* Driver hints isn't mandatory admin command. So in case the
+	 * command isn't supported set driver hints to 0
+	 */
+	rc = ena_com_get_feature(ena_dev, &get_resp, ENA_ADMIN_HW_HINTS);
+
+	if (!rc)
+		memcpy(&get_feat_ctx->hw_hints, &get_resp.u.hw_hints,
+		       sizeof(get_resp.u.hw_hints));
+	else if (rc == -EPERM)
+		memset(&get_feat_ctx->hw_hints, 0x0,
+		       sizeof(get_feat_ctx->hw_hints));
+	else
+		return rc;
+
 	return 0;
 }
 
@@ -1848,6 +1863,14 @@ int ena_com_dev_reset(struct ena_com_dev *ena_dev)
 		return rc;
 	}
 
+	timeout = (cap & ENA_REGS_CAPS_ADMIN_CMD_TO_MASK) >>
+		ENA_REGS_CAPS_ADMIN_CMD_TO_SHIFT;
+	if (timeout)
+		/* the resolution of timeout reg is 100ms */
+		ena_dev->admin_queue.completion_timeout = timeout * 100000;
+	else
+		ena_dev->admin_queue.completion_timeout = ADMIN_CMD_TIMEOUT_US;
+
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/amazon/ena/ena_com.h b/drivers/net/ethernet/amazon/ena/ena_com.h
index 509d7b8..6883ee5 100644
--- a/drivers/net/ethernet/amazon/ena/ena_com.h
+++ b/drivers/net/ethernet/amazon/ena/ena_com.h
@@ -96,6 +96,8 @@
 #define ENA_INTR_MODER_LEVEL_STRIDE			2
 #define ENA_INTR_BYTE_COUNT_NOT_SUPPORTED		0xFFFFFF
 
+#define ENA_HW_HINTS_NO_TIMEOUT				0xFFFF
+
 enum ena_intr_moder_level {
 	ENA_INTR_MODER_LOWEST = 0,
 	ENA_INTR_MODER_LOW,
@@ -232,6 +234,7 @@ struct ena_com_admin_queue {
 	void *q_dmadev;
 	spinlock_t q_lock; /* spinlock for the admin queue */
 	struct ena_comp_ctx *comp_ctx;
+	u32 completion_timeout;
 	u16 q_depth;
 	struct ena_com_admin_cq cq;
 	struct ena_com_admin_sq sq;
@@ -266,6 +269,7 @@ struct ena_com_aenq {
 struct ena_com_mmio_read {
 	struct ena_admin_ena_mmio_req_read_less_resp *read_resp;
 	dma_addr_t read_resp_dma_addr;
+	u32 reg_read_to; /* in us */
 	u16 seq_num;
 	bool readless_supported;
 	/* spin lock to ensure a single outstanding read */
@@ -335,6 +339,7 @@ struct ena_com_dev_get_features_ctx {
 	struct ena_admin_device_attr_feature_desc dev_attr;
 	struct ena_admin_feature_aenq_desc aenq;
 	struct ena_admin_feature_offload_desc offload;
+	struct ena_admin_ena_hw_hints hw_hints;
 };
 
 struct ena_com_create_io_ctx {
diff --git a/drivers/net/ethernet/amazon/ena/ena_ethtool.c b/drivers/net/ethernet/amazon/ena/ena_ethtool.c
index 67b2338f..a1fbfc2 100644
--- a/drivers/net/ethernet/amazon/ena/ena_ethtool.c
+++ b/drivers/net/ethernet/amazon/ena/ena_ethtool.c
@@ -80,7 +80,6 @@ struct ena_stats {
 	ENA_STAT_TX_ENTRY(tx_poll),
 	ENA_STAT_TX_ENTRY(doorbells),
 	ENA_STAT_TX_ENTRY(prepare_ctx_err),
-	ENA_STAT_TX_ENTRY(missing_tx_comp),
 	ENA_STAT_TX_ENTRY(bad_req_id),
 };
 
diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.c b/drivers/net/ethernet/amazon/ena/ena_netdev.c
index 7247abb..e7dda8b 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.c
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.c
@@ -1989,6 +1989,7 @@ static netdev_tx_t ena_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	tx_info->tx_descs = nb_hw_desc;
 	tx_info->last_jiffies = jiffies;
+	tx_info->print_once = 0;
 
 	tx_ring->next_to_use = ENA_TX_RING_IDX_NEXT(next_to_use,
 		tx_ring->ring_size);
@@ -2542,33 +2543,34 @@ static void check_for_missing_tx_completions(struct ena_adapter *adapter)
 	if (!test_bit(ENA_FLAG_DEV_UP, &adapter->flags))
 		return;
 
+	if (adapter->missing_tx_completion_to == ENA_HW_HINTS_NO_TIMEOUT)
+		return;
+
 	budget = ENA_MONITORED_TX_QUEUES;
 
 	for (i = adapter->last_monitored_tx_qid; i < adapter->num_queues; i++) {
 		tx_ring = &adapter->tx_ring[i];
 
+		missed_tx = 0;
+
 		for (j = 0; j < tx_ring->ring_size; j++) {
 			tx_buf = &tx_ring->tx_buffer_info[j];
 			last_jiffies = tx_buf->last_jiffies;
-			if (unlikely(last_jiffies && time_is_before_jiffies(last_jiffies + TX_TIMEOUT))) {
-				netif_notice(adapter, tx_err, adapter->netdev,
-					     "Found a Tx that wasn't completed on time, qid %d, index %d.\n",
-					     tx_ring->qid, j);
+			if (unlikely(last_jiffies && time_is_before_jiffies(last_jiffies + adapter->missing_tx_completion_to))) {
+				if (!tx_buf->print_once)
+					netif_notice(adapter, tx_err, adapter->netdev,
+						     "Found a Tx that wasn't completed on time, qid %d, index %d.\n",
+						     tx_ring->qid, j);
 
-				u64_stats_update_begin(&tx_ring->syncp);
-				missed_tx = tx_ring->tx_stats.missing_tx_comp++;
-				u64_stats_update_end(&tx_ring->syncp);
+				tx_buf->print_once = 1;
+				missed_tx++;
 
-				/* Clear last jiffies so the lost buffer won't
-				 * be counted twice.
-				 */
-				tx_buf->last_jiffies = 0;
-
-				if (unlikely(missed_tx > MAX_NUM_OF_TIMEOUTED_PACKETS)) {
+				if (unlikely(missed_tx > adapter->missing_tx_completion_threshold)) {
 					netif_err(adapter, tx_err, adapter->netdev,
 						  "The number of lost tx completion is above the threshold (%d > %d). Reset the device\n",
-						  missed_tx, MAX_NUM_OF_TIMEOUTED_PACKETS);
+						  missed_tx, adapter->missing_tx_completion_threshold);
 					set_bit(ENA_FLAG_TRIGGER_RESET, &adapter->flags);
+					return;
 				}
 			}
 		}
@@ -2589,8 +2591,11 @@ static void check_for_missing_keep_alive(struct ena_adapter *adapter)
 	if (!adapter->wd_state)
 		return;
 
-	keep_alive_expired = round_jiffies(adapter->last_keep_alive_jiffies
-					   + ENA_DEVICE_KALIVE_TIMEOUT);
+	if (adapter->keep_alive_timeout == ENA_HW_HINTS_NO_TIMEOUT)
+		return;
+
+	keep_alive_expired = round_jiffies(adapter->last_keep_alive_jiffies +
+					   adapter->keep_alive_timeout);
 	if (unlikely(time_is_before_jiffies(keep_alive_expired))) {
 		netif_err(adapter, drv, adapter->netdev,
 			  "Keep alive watchdog timeout.\n");
@@ -2613,6 +2618,44 @@ static void check_for_admin_com_state(struct ena_adapter *adapter)
 	}
 }
 
+static void ena_update_hints(struct ena_adapter *adapter,
+			     struct ena_admin_ena_hw_hints *hints)
+{
+	struct net_device *netdev = adapter->netdev;
+
+	if (hints->admin_completion_tx_timeout)
+		adapter->ena_dev->admin_queue.completion_timeout =
+			hints->admin_completion_tx_timeout * 1000;
+
+	if (hints->mmio_read_timeout)
+		/* convert to usec */
+		adapter->ena_dev->mmio_read.reg_read_to =
+			hints->mmio_read_timeout * 1000;
+
+	if (hints->missed_tx_completion_count_threshold_to_reset)
+		adapter->missing_tx_completion_threshold =
+			hints->missed_tx_completion_count_threshold_to_reset;
+
+	if (hints->missing_tx_completion_timeout) {
+		if (hints->missing_tx_completion_timeout == ENA_HW_HINTS_NO_TIMEOUT)
+			adapter->missing_tx_completion_to = ENA_HW_HINTS_NO_TIMEOUT;
+		else
+			adapter->missing_tx_completion_to =
+				msecs_to_jiffies(hints->missing_tx_completion_timeout);
+	}
+
+	if (hints->netdev_wd_timeout)
+		netdev->watchdog_timeo = msecs_to_jiffies(hints->netdev_wd_timeout);
+
+	if (hints->driver_watchdog_timeout) {
+		if (hints->driver_watchdog_timeout == ENA_HW_HINTS_NO_TIMEOUT)
+			adapter->keep_alive_timeout = ENA_HW_HINTS_NO_TIMEOUT;
+		else
+			adapter->keep_alive_timeout =
+				msecs_to_jiffies(hints->driver_watchdog_timeout);
+	}
+}
+
 static void ena_update_host_info(struct ena_admin_host_info *host_info,
 				 struct net_device *netdev)
 {
@@ -3024,6 +3067,11 @@ static int ena_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	INIT_WORK(&adapter->reset_task, ena_fw_reset_device);
 
 	adapter->last_keep_alive_jiffies = jiffies;
+	adapter->keep_alive_timeout = ENA_DEVICE_KALIVE_TIMEOUT;
+	adapter->missing_tx_completion_to = TX_TIMEOUT;
+	adapter->missing_tx_completion_threshold = MAX_NUM_OF_TIMEOUTED_PACKETS;
+
+	ena_update_hints(adapter, &get_feat_ctx.hw_hints);
 
 	init_timer(&adapter->timer_service);
 	adapter->timer_service.expires = round_jiffies(jiffies + HZ);
@@ -3232,6 +3280,7 @@ static void ena_notification(void *adapter_data,
 			     struct ena_admin_aenq_entry *aenq_e)
 {
 	struct ena_adapter *adapter = (struct ena_adapter *)adapter_data;
+	struct ena_admin_ena_hw_hints *hints;
 
 	WARN(aenq_e->aenq_common_desc.group != ENA_ADMIN_NOTIFICATION,
 	     "Invalid group(%x) expected %x\n",
@@ -3249,6 +3298,11 @@ static void ena_notification(void *adapter_data,
 	case ENA_ADMIN_RESUME:
 		queue_work(ena_wq, &adapter->resume_io_task);
 		break;
+	case ENA_ADMIN_UPDATE_HINTS:
+		hints = (struct ena_admin_ena_hw_hints *)
+			(&aenq_e->inline_data_w4);
+		ena_update_hints(adapter, hints);
+		break;
 	default:
 		netif_err(adapter, drv, adapter->netdev,
 			  "Invalid aenq notification link state %d\n",
diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.h b/drivers/net/ethernet/amazon/ena/ena_netdev.h
index 69d7e9e..f8ef1f0 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.h
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.h
@@ -146,7 +146,18 @@ struct ena_tx_buffer {
 	u32 tx_descs;
 	/* num of buffers used by this skb */
 	u32 num_of_bufs;
-	/* Save the last jiffies to detect missing tx packets */
+
+	/* Used for detect missing tx packets to limit the number of prints */
+	u32 print_once;
+	/* Save the last jiffies to detect missing tx packets
+	 *
+	 * sets to non zero value on ena_start_xmit and set to zero on
+	 * napi and timer_Service_routine.
+	 *
+	 * while this value is not protected by lock,
+	 * a given packet is not expected to be handled by ena_start_xmit
+	 * and by napi/timer_service at the same time.
+	 */
 	unsigned long last_jiffies;
 	struct ena_com_buf bufs[ENA_PKT_MAX_BUFS];
 } ____cacheline_aligned;
@@ -170,7 +181,6 @@ struct ena_stats_tx {
 	u64 napi_comp;
 	u64 tx_poll;
 	u64 doorbells;
-	u64 missing_tx_comp;
 	u64 bad_req_id;
 };
 
@@ -269,6 +279,8 @@ struct ena_adapter {
 	struct msix_entry *msix_entries;
 	int msix_vecs;
 
+	u32 missing_tx_completion_threshold;
+
 	u32 tx_usecs, rx_usecs; /* interrupt moderation */
 	u32 tx_frames, rx_frames; /* interrupt moderation */
 
@@ -282,6 +294,9 @@ struct ena_adapter {
 
 	u8 mac_addr[ETH_ALEN];
 
+	unsigned long keep_alive_timeout;
+	unsigned long missing_tx_completion_to;
+
 	char name[ENA_NAME_MAX_LEN];
 
 	unsigned long flags;
diff --git a/drivers/net/ethernet/amazon/ena/ena_regs_defs.h b/drivers/net/ethernet/amazon/ena/ena_regs_defs.h
index 26097a2..c3891c5 100644
--- a/drivers/net/ethernet/amazon/ena/ena_regs_defs.h
+++ b/drivers/net/ethernet/amazon/ena/ena_regs_defs.h
@@ -78,6 +78,8 @@
 #define ENA_REGS_CAPS_RESET_TIMEOUT_MASK		0x3e
 #define ENA_REGS_CAPS_DMA_ADDR_WIDTH_SHIFT		8
 #define ENA_REGS_CAPS_DMA_ADDR_WIDTH_MASK		0xff00
+#define ENA_REGS_CAPS_ADMIN_CMD_TO_SHIFT		16
+#define ENA_REGS_CAPS_ADMIN_CMD_TO_MASK		0xf0000
 
 /* aq_caps register */
 #define ENA_REGS_AQ_CAPS_AQ_DEPTH_MASK		0xffff
-- 
1.9.1
