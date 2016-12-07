From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V3 7/7] liquidio VF rx data and ctl path
Date: Wed, 7 Dec 2016 08:54:37 -0800
Message-ID: <1481129677-10586-8-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1481129677-10586-1-git-send-email-rvatsavayi@caviumnetworks.com>
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
Received: from mail-cys01nam02on0084.outbound.protection.outlook.com ([104.47.37.84]:43712
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932886AbcLGQzR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 11:55:17 -0500
In-Reply-To: <1481129677-10586-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds support for VF receive data control path.

Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 412 ++++++++++++++++++++-
 .../net/ethernet/cavium/liquidio/octeon_device.c   |   2 +-
 drivers/net/ethernet/cavium/liquidio/octeon_droq.c |  10 +
 .../ethernet/cavium/liquidio/response_manager.c    |   3 +-
 4 files changed, 423 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index e4297f8..9989ac3 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -38,6 +38,8 @@
 
 #define DEFAULT_MSG_ENABLE (NETIF_MSG_DRV | NETIF_MSG_PROBE | NETIF_MSG_LINK)
 
+/* Bit mask values for lio->ifstate */
+#define   LIO_IFSTATE_DROQ_OPS             0x01
 #define   LIO_IFSTATE_REGISTERED           0x02
 #define   LIO_IFSTATE_RUNNING              0x04
 
@@ -55,6 +57,14 @@ struct liquidio_if_cfg_resp {
 	u64 status;
 };
 
+struct liquidio_rx_ctl_context {
+	int octeon_id;
+
+	wait_queue_head_t wc;
+
+	int cond;
+};
+
 union tx_info {
 	u64 u64;
 	struct {
@@ -177,6 +187,16 @@ static int wait_for_pending_requests(struct octeon_device *oct)
 };
 
 /**
+ * \brief check interface state
+ * @param lio per-network private data
+ * @param state_flag flag state to check
+ */
+static int ifstate_check(struct lio *lio, int state_flag)
+{
+	return atomic_read(&lio->ifstate) & state_flag;
+}
+
+/**
  * \brief set interface state
  * @param lio per-network private data
  * @param state_flag flag state to set
@@ -510,6 +530,31 @@ static void update_link_status(struct net_device *netdev,
 	}
 }
 
+static void update_txq_status(struct octeon_device *oct, int iq_num)
+{
+	struct octeon_instr_queue *iq = oct->instr_queue[iq_num];
+	struct net_device *netdev;
+	struct lio *lio;
+
+	netdev = oct->props[iq->ifidx].netdev;
+	lio = GET_LIO(netdev);
+	if (netif_is_multiqueue(netdev)) {
+		if (__netif_subqueue_stopped(netdev, iq->q_index) &&
+		    lio->linfo.link.s.link_up &&
+		    (!octnet_iq_is_full(oct, iq_num))) {
+			netif_wake_subqueue(netdev, iq->q_index);
+			INCR_INSTRQUEUE_PKT_COUNT(lio->oct_dev, iq_num,
+						  tx_restart, 1);
+		} else {
+			if (!octnet_iq_is_full(oct, lio->txq)) {
+				INCR_INSTRQUEUE_PKT_COUNT(
+				    lio->oct_dev, lio->txq, tx_restart, 1);
+				wake_q(netdev, lio->txq);
+			}
+		}
+	}
+}
+
 static
 int liquidio_schedule_msix_droq_pkt_handler(struct octeon_droq *droq, u64 ret)
 {
@@ -818,6 +863,91 @@ static void octeon_destroy_resources(struct octeon_device *oct)
 }
 
 /**
+ * \brief Callback for rx ctrl
+ * @param status status of request
+ * @param buf pointer to resp structure
+ */
+static void rx_ctl_callback(struct octeon_device *oct,
+			    u32 status, void *buf)
+{
+	struct octeon_soft_command *sc = (struct octeon_soft_command *)buf;
+	struct liquidio_rx_ctl_context *ctx;
+
+	ctx  = (struct liquidio_rx_ctl_context *)sc->ctxptr;
+
+	oct = lio_get_device(ctx->octeon_id);
+	if (status)
+		dev_err(&oct->pci_dev->dev, "rx ctl instruction failed. Status: %llx\n",
+			CVM_CAST64(status));
+	WRITE_ONCE(ctx->cond, 1);
+
+	/* This barrier is required to be sure that the response has been
+	 * written fully before waking up the handler
+	 */
+	wmb();
+
+	wake_up_interruptible(&ctx->wc);
+}
+
+/**
+ * \brief Send Rx control command
+ * @param lio per-network private data
+ * @param start_stop whether to start or stop
+ */
+static void send_rx_ctrl_cmd(struct lio *lio, int start_stop)
+{
+	struct octeon_device *oct = (struct octeon_device *)lio->oct_dev;
+	int ctx_size = sizeof(struct liquidio_rx_ctl_context);
+	struct liquidio_rx_ctl_context *ctx;
+	struct octeon_soft_command *sc;
+	union octnet_cmd *ncmd;
+	int retval;
+
+	if (oct->props[lio->ifidx].rx_on == start_stop)
+		return;
+
+	sc = (struct octeon_soft_command *)
+		octeon_alloc_soft_command(oct, OCTNET_CMD_SIZE,
+					  16, ctx_size);
+
+	ncmd = (union octnet_cmd *)sc->virtdptr;
+	ctx  = (struct liquidio_rx_ctl_context *)sc->ctxptr;
+
+	WRITE_ONCE(ctx->cond, 0);
+	ctx->octeon_id = lio_get_device_id(oct);
+	init_waitqueue_head(&ctx->wc);
+
+	ncmd->u64 = 0;
+	ncmd->s.cmd = OCTNET_CMD_RX_CTL;
+	ncmd->s.param1 = start_stop;
+
+	octeon_swap_8B_data((u64 *)ncmd, (OCTNET_CMD_SIZE >> 3));
+
+	sc->iq_no = lio->linfo.txpciq[0].s.q_no;
+
+	octeon_prepare_soft_command(oct, sc, OPCODE_NIC,
+				    OPCODE_NIC_CMD, 0, 0, 0);
+
+	sc->callback = rx_ctl_callback;
+	sc->callback_arg = sc;
+	sc->wait_time = 5000;
+
+	retval = octeon_send_soft_command(oct, sc);
+	if (retval == IQ_SEND_FAILED) {
+		netif_info(lio, rx_err, lio->netdev, "Failed to send RX Control message\n");
+	} else {
+		/* Sleep on a wait queue till the cond flag indicates that the
+		 * response arrived or timed-out.
+		 */
+		if (sleep_cond(&ctx->wc, &ctx->cond) == -EINTR)
+			return;
+		oct->props[lio->ifidx].rx_on = start_stop;
+	}
+
+	octeon_free_soft_command(oct, sc);
+}
+
+/**
  * \brief Destroy NIC device interface
  * @param oct octeon device
  * @param ifidx which interface to destroy
@@ -828,6 +958,7 @@ static void octeon_destroy_resources(struct octeon_device *oct)
 static void liquidio_destroy_nic_device(struct octeon_device *oct, int ifidx)
 {
 	struct net_device *netdev = oct->props[ifidx].netdev;
+	struct napi_struct *napi, *n;
 	struct lio *lio;
 
 	if (!netdev) {
@@ -843,6 +974,15 @@ static void liquidio_destroy_nic_device(struct octeon_device *oct, int ifidx)
 	if (atomic_read(&lio->ifstate) & LIO_IFSTATE_RUNNING)
 		liquidio_stop(netdev);
 
+	if (oct->props[lio->ifidx].napi_enabled == 1) {
+		list_for_each_entry_safe(napi, n, &netdev->napi_list, dev_list)
+			napi_disable(napi);
+
+		oct->props[lio->ifidx].napi_enabled = 0;
+
+		oct->droq[0]->ops.poll_mode = 0;
+	}
+
 	if (atomic_read(&lio->ifstate) & LIO_IFSTATE_REGISTERED)
 		unregister_netdev(netdev);
 
@@ -863,7 +1003,8 @@ static void liquidio_destroy_nic_device(struct octeon_device *oct, int ifidx)
  */
 static int liquidio_stop_nic_module(struct octeon_device *oct)
 {
-	int i;
+	struct lio *lio;
+	int i, j;
 
 	dev_dbg(&oct->pci_dev->dev, "Stopping network interfaces\n");
 	if (!oct->ifcount) {
@@ -871,6 +1012,17 @@ static int liquidio_stop_nic_module(struct octeon_device *oct)
 		return 1;
 	}
 
+	spin_lock_bh(&oct->cmd_resp_wqlock);
+	oct->cmd_resp_state = OCT_DRV_OFFLINE;
+	spin_unlock_bh(&oct->cmd_resp_wqlock);
+
+	for (i = 0; i < oct->ifcount; i++) {
+		lio = GET_LIO(oct->props[i].netdev);
+		for (j = 0; j < lio->linfo.num_rxpciq; j++)
+			octeon_unregister_droq_ops(oct,
+						   lio->linfo.rxpciq[j].s.q_no);
+	}
+
 	for (i = 0; i < oct->ifcount; i++)
 		liquidio_destroy_nic_device(oct, i);
 
@@ -1091,6 +1243,41 @@ static void free_netsgbuf_with_resp(void *buf)
 }
 
 /**
+ * \brief Setup output queue
+ * @param oct octeon device
+ * @param q_no which queue
+ * @param num_descs how many descriptors
+ * @param desc_size size of each descriptor
+ * @param app_ctx application context
+ */
+static int octeon_setup_droq(struct octeon_device *oct, int q_no, int num_descs,
+			     int desc_size, void *app_ctx)
+{
+	int ret_val;
+
+	dev_dbg(&oct->pci_dev->dev, "Creating Droq: %d\n", q_no);
+	/* droq creation and local register settings. */
+	ret_val = octeon_create_droq(oct, q_no, num_descs, desc_size, app_ctx);
+	if (ret_val < 0)
+		return ret_val;
+
+	if (ret_val == 1) {
+		dev_dbg(&oct->pci_dev->dev, "Using default droq %d\n", q_no);
+		return 0;
+	}
+
+	/* Enable the droq queues */
+	octeon_set_droq_pkt_op(oct, q_no, 1);
+
+	/* Send Credit for Octeon Output queues. Credits are always
+	 * sent after the output queue is enabled.
+	 */
+	writel(oct->droq[q_no]->max_count, oct->droq[q_no]->pkts_credit_reg);
+
+	return ret_val;
+}
+
+/**
  * \brief Callback for getting interface configuration
  * @param status status of request
  * @param buf pointer to resp structure
@@ -1142,6 +1329,155 @@ static u16 select_q(struct net_device *dev, struct sk_buff *skb,
 	return (u16)(qindex % (lio->linfo.num_txpciq));
 }
 
+/** Routine to push packets arriving on Octeon interface upto network layer.
+ * @param oct_id   - octeon device id.
+ * @param skbuff   - skbuff struct to be passed to network layer.
+ * @param len      - size of total data received.
+ * @param rh       - Control header associated with the packet
+ * @param param    - additional control data with the packet
+ * @param arg      - farg registered in droq_ops
+ */
+static void
+liquidio_push_packet(u32 octeon_id __attribute__((unused)),
+		     void *skbuff,
+		     u32 len,
+		     union octeon_rh *rh,
+		     void *param,
+		     void *arg)
+{
+	struct napi_struct *napi = param;
+	struct octeon_droq *droq =
+		container_of(param, struct octeon_droq, napi);
+	struct net_device *netdev = (struct net_device *)arg;
+	struct sk_buff *skb = (struct sk_buff *)skbuff;
+
+	if (netdev) {
+		struct lio *lio = GET_LIO(netdev);
+		int packet_was_received;
+
+		/* Do not proceed if the interface is not in RUNNING state. */
+		if (!ifstate_check(lio, LIO_IFSTATE_RUNNING)) {
+			recv_buffer_free(skb);
+			droq->stats.rx_dropped++;
+			return;
+		}
+
+		skb->dev = netdev;
+
+		skb_record_rx_queue(skb, droq->q_no);
+		if (likely(len > MIN_SKB_SIZE)) {
+			struct octeon_skb_page_info *pg_info;
+			unsigned char *va;
+
+			pg_info = ((struct octeon_skb_page_info *)(skb->cb));
+			if (pg_info->page) {
+				/* For Paged allocation use the frags */
+				va = page_address(pg_info->page) +
+					pg_info->page_offset;
+				memcpy(skb->data, va, MIN_SKB_SIZE);
+				skb_put(skb, MIN_SKB_SIZE);
+				skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags,
+						pg_info->page,
+						pg_info->page_offset +
+						MIN_SKB_SIZE,
+						len - MIN_SKB_SIZE,
+						LIO_RXBUFFER_SZ);
+			}
+		} else {
+			struct octeon_skb_page_info *pg_info =
+				((struct octeon_skb_page_info *)(skb->cb));
+			skb_copy_to_linear_data(skb,
+						page_address(pg_info->page) +
+						pg_info->page_offset, len);
+			skb_put(skb, len);
+			put_page(pg_info->page);
+		}
+
+		skb_pull(skb, rh->r_dh.len * 8);
+		skb->protocol = eth_type_trans(skb, skb->dev);
+
+		if ((netdev->features & NETIF_F_RXCSUM) &&
+		    (rh->r_dh.csum_verified & CNNIC_CSUM_VERIFIED))
+			/* checksum has already been verified */
+			skb->ip_summed = CHECKSUM_UNNECESSARY;
+		else
+			skb->ip_summed = CHECKSUM_NONE;
+
+		packet_was_received = (napi_gro_receive(napi, skb) != GRO_DROP);
+
+		if (packet_was_received) {
+			droq->stats.rx_bytes_received += len;
+			droq->stats.rx_pkts_received++;
+			netdev->last_rx = jiffies;
+		} else {
+			droq->stats.rx_dropped++;
+			netif_info(lio, rx_err, lio->netdev,
+				   "droq:%d  error rx_dropped:%llu\n",
+				   droq->q_no, droq->stats.rx_dropped);
+		}
+
+	} else {
+		recv_buffer_free(skb);
+	}
+}
+
+/**
+ * \brief callback when receive interrupt occurs and we are in NAPI mode
+ * @param arg pointer to octeon output queue
+ */
+static void liquidio_vf_napi_drv_callback(void *arg)
+{
+	struct octeon_droq *droq = arg;
+
+	napi_schedule_irqoff(&droq->napi);
+}
+
+/**
+ * \brief Entry point for NAPI polling
+ * @param napi NAPI structure
+ * @param budget maximum number of items to process
+ */
+static int liquidio_napi_poll(struct napi_struct *napi, int budget)
+{
+	struct octeon_instr_queue *iq;
+	struct octeon_device *oct;
+	struct octeon_droq *droq;
+	int tx_done = 0, iq_no;
+	int work_done;
+
+	droq = container_of(napi, struct octeon_droq, napi);
+	oct = droq->oct_dev;
+	iq_no = droq->q_no;
+
+	/* Handle Droq descriptors */
+	work_done = octeon_process_droq_poll_cmd(oct, droq->q_no,
+						 POLL_EVENT_PROCESS_PKTS,
+						 budget);
+
+	/* Flush the instruction queue */
+	iq = oct->instr_queue[iq_no];
+	if (iq) {
+		/* Process iq buffers with in the budget limits */
+		tx_done = octeon_flush_iq(oct, iq, 1, budget);
+		/* Update iq read-index rather than waiting for next interrupt.
+		 * Return back if tx_done is false.
+		 */
+		update_txq_status(oct, iq_no);
+	} else {
+		dev_err(&oct->pci_dev->dev, "%s: iq (%d) num invalid\n",
+			__func__, iq_no);
+	}
+
+	if ((work_done < budget) && (tx_done)) {
+		napi_complete(napi);
+		octeon_process_droq_poll_cmd(droq->oct_dev, droq->q_no,
+					     POLL_EVENT_ENABLE_INTR, 0);
+		return 0;
+	}
+
+	return (!tx_done) ? (budget) : (work_done);
+}
+
 /**
  * \brief Setup input and output queues
  * @param octeon_dev octeon device
@@ -1153,16 +1489,68 @@ static u16 select_q(struct net_device *dev, struct sk_buff *skb,
  */
 static int setup_io_queues(struct octeon_device *octeon_dev, int ifidx)
 {
+	struct octeon_droq_ops droq_ops;
 	struct net_device *netdev;
+	static int cpu_id_modulus;
+	struct octeon_droq *droq;
+	struct napi_struct *napi;
+	static int cpu_id;
 	int num_tx_descs;
 	struct lio *lio;
 	int retval = 0;
-	int q;
+	int q, q_no;
 
 	netdev = octeon_dev->props[ifidx].netdev;
 
 	lio = GET_LIO(netdev);
 
+	memset(&droq_ops, 0, sizeof(struct octeon_droq_ops));
+
+	droq_ops.fptr = liquidio_push_packet;
+	droq_ops.farg = netdev;
+
+	droq_ops.poll_mode = 1;
+	droq_ops.napi_fn = liquidio_vf_napi_drv_callback;
+	cpu_id = 0;
+	cpu_id_modulus = num_present_cpus();
+
+	/* set up DROQs. */
+	for (q = 0; q < lio->linfo.num_rxpciq; q++) {
+		q_no = lio->linfo.rxpciq[q].s.q_no;
+
+		retval = octeon_setup_droq(
+		    octeon_dev, q_no,
+		    CFG_GET_NUM_RX_DESCS_NIC_IF(octeon_get_conf(octeon_dev),
+						lio->ifidx),
+		    CFG_GET_NUM_RX_BUF_SIZE_NIC_IF(octeon_get_conf(octeon_dev),
+						   lio->ifidx),
+		    NULL);
+		if (retval) {
+			dev_err(&octeon_dev->pci_dev->dev,
+				"%s : Runtime DROQ(RxQ) creation failed.\n",
+				__func__);
+			return 1;
+		}
+
+		droq = octeon_dev->droq[q_no];
+		napi = &droq->napi;
+		netif_napi_add(netdev, napi, liquidio_napi_poll, 64);
+
+		/* designate a CPU for this droq */
+		droq->cpu_id = cpu_id;
+		cpu_id++;
+		if (cpu_id >= cpu_id_modulus)
+			cpu_id = 0;
+
+		octeon_register_droq_ops(octeon_dev, q_no, &droq_ops);
+	}
+
+	/* 23XX VF can send/recv control messages (via the first VF-owned
+	 * droq) from the firmware even if the ethX interface is down,
+	 * so that's why poll_mode must be off for the first droq.
+	 */
+	octeon_dev->droq[0]->ops.poll_mode = 0;
+
 	/* set up IQs. */
 	for (q = 0; q < lio->linfo.num_txpciq; q++) {
 		num_tx_descs = CFG_GET_NUM_TX_DESCS_NIC_IF(
@@ -1189,6 +1577,16 @@ static int liquidio_open(struct net_device *netdev)
 {
 	struct lio *lio = GET_LIO(netdev);
 	struct octeon_device *oct = lio->oct_dev;
+	struct napi_struct *napi, *n;
+
+	if (!oct->props[lio->ifidx].napi_enabled) {
+		list_for_each_entry_safe(napi, n, &netdev->napi_list, dev_list)
+			napi_enable(napi);
+
+		oct->props[lio->ifidx].napi_enabled = 1;
+
+		oct->droq[0]->ops.poll_mode = 1;
+	}
 
 	ifstate_set(lio, LIO_IFSTATE_RUNNING);
 
@@ -1198,6 +1596,9 @@ static int liquidio_open(struct net_device *netdev)
 	netif_info(lio, ifup, lio->netdev, "Interface Open, ready for traffic\n");
 	start_txq(netdev);
 
+	/* tell Octeon to start forwarding packets to host */
+	send_rx_ctrl_cmd(lio, 1);
+
 	dev_info(&oct->pci_dev->dev, "%s interface is opened\n", netdev->name);
 
 	return 0;
@@ -1220,6 +1621,9 @@ static int liquidio_stop(struct net_device *netdev)
 	netif_carrier_off(netdev);
 	lio->link_changes++;
 
+	/* tell Octeon to stop forwarding packets to host */
+	send_rx_ctrl_cmd(lio, 0);
+
 	ifstate_reset(lio, LIO_IFSTATE_RUNNING);
 
 	txqs_stop(netdev);
@@ -2016,6 +2420,8 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 			goto setup_nic_dev_fail;
 		}
 
+		ifstate_set(lio, LIO_IFSTATE_DROQ_OPS);
+
 		/* For VFs, enable Octeon device interrupts here,
 		 * as this is contingent upon IO queue setup
 		 */
@@ -2026,8 +2432,10 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 		 * tx and rx queues
 		 */
 		lio->txq = lio->linfo.txpciq[0].s.q_no;
+		lio->rxq = lio->linfo.rxpciq[0].s.q_no;
 
 		lio->tx_qsize = octeon_get_tx_qsize(octeon_dev, lio->txq);
+		lio->rx_qsize = octeon_get_rx_qsize(octeon_dev, lio->rxq);
 
 		if (setup_glists(lio, num_iqueues)) {
 			dev_err(&octeon_dev->pci_dev->dev,
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.c b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
index 583818e..a8df493 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
@@ -1374,7 +1374,7 @@ void lio_enable_irq(struct octeon_droq *droq, struct octeon_instr_queue *iq)
 	/*write resend. Writing RESEND in SLI_PKTX_CNTS should be enough
 	 *to trigger tx interrupts as well, if they are pending.
 	 */
-	if (oct && OCTEON_CN23XX_PF(oct)) {
+	if (oct && (OCTEON_CN23XX_PF(oct) || OCTEON_CN23XX_VF(oct))) {
 		if (droq)
 			writeq(CN23XX_INTR_RESEND, droq->pkts_sent_reg);
 		/*we race with firmrware here. read and write the IN_DONE_CNTS*/
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
index 8bf1ac76..0be87d1 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
@@ -28,6 +28,7 @@
 #include "cn66xx_regs.h"
 #include "cn66xx_device.h"
 #include "cn23xx_pf_device.h"
+#include "cn23xx_vf_device.h"
 
 struct niclist {
 	struct list_head list;
@@ -261,6 +262,11 @@ int octeon_init_droq(struct octeon_device *oct,
 
 		c_pkts_per_intr = (u32)CFG_GET_OQ_PKTS_PER_INTR(conf23);
 		c_refill_threshold = (u32)CFG_GET_OQ_REFILL_THRESHOLD(conf23);
+	} else if (OCTEON_CN23XX_VF(oct)) {
+		struct octeon_config *conf23 = CHIP_CONF(oct, cn23xx_vf);
+
+		c_pkts_per_intr = (u32)CFG_GET_OQ_PKTS_PER_INTR(conf23);
+		c_refill_threshold = (u32)CFG_GET_OQ_REFILL_THRESHOLD(conf23);
 	} else {
 		return 1;
 	}
@@ -889,6 +895,10 @@ static inline void octeon_droq_drop_packets(struct octeon_device *oct,
 			lio_enable_irq(oct->droq[q_no], oct->instr_queue[q_no]);
 		}
 		break;
+
+		case OCTEON_CN23XX_VF_VID:
+			lio_enable_irq(oct->droq[q_no], oct->instr_queue[q_no]);
+		break;
 		}
 		return 0;
 	}
diff --git a/drivers/net/ethernet/cavium/liquidio/response_manager.c b/drivers/net/ethernet/cavium/liquidio/response_manager.c
index fdaf742..2fbaae9 100644
--- a/drivers/net/ethernet/cavium/liquidio/response_manager.c
+++ b/drivers/net/ethernet/cavium/liquidio/response_manager.c
@@ -84,7 +84,8 @@ int lio_process_ordered_list(struct octeon_device *octeon_dev,
 
 		sc = (struct octeon_soft_command *)ordered_sc_list->
 		    head.next;
-		if (OCTEON_CN23XX_PF(octeon_dev)) {
+		if (OCTEON_CN23XX_PF(octeon_dev) ||
+		    OCTEON_CN23XX_VF(octeon_dev)) {
 			rdp = (struct octeon_instr_rdp *)&sc->cmd.cmd3.rdp;
 			rptr = sc->cmd.cmd3.rptr;
 		} else {
-- 
1.8.3.1
