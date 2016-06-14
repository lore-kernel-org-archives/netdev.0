From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V2 2/9] liquidio: Host queue mapping changes
Date: Tue, 14 Jun 2016 16:54:44 -0700
Message-ID: <1465948491-10541-3-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1465948491-10541-1-git-send-email-rvatsavayi@caviumnetworks.com>
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
Received: from mail-bl2on0099.outbound.protection.outlook.com ([65.55.169.99]:57133
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752494AbcFOAKt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2016 20:10:49 -0400
In-Reply-To: <1465948491-10541-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to allocate the input queues based on Numa node in tx path
and queue mapping changes based on the mapping info provided by firmware.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c |  4 +-
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 75 ++++++++++++----------
 .../net/ethernet/cavium/liquidio/liquidio_common.h | 44 ++++++++++++-
 .../net/ethernet/cavium/liquidio/octeon_device.c   | 41 +++++++-----
 drivers/net/ethernet/cavium/liquidio/octeon_iq.h   | 11 ++--
 .../net/ethernet/cavium/liquidio/request_manager.c | 32 +++++++--
 6 files changed, 142 insertions(+), 65 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
index 1096cdb..2937c802 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
@@ -653,7 +653,7 @@ static int lio_get_intr_coalesce(struct net_device *netdev,
 				intrmod_cfg->intrmod_mincnt_trigger;
 		}
 
-		iq = oct->instr_queue[lio->linfo.txpciq[0]];
+		iq = oct->instr_queue[lio->linfo.txpciq[0].s.q_no];
 		intr_coal->tx_max_coalesced_frames = iq->fill_threshold;
 		break;
 
@@ -859,7 +859,7 @@ static int lio_set_intr_coalesce(struct net_device *netdev,
 	if ((intr_coal->tx_max_coalesced_frames >= CN6XXX_DB_MIN) &&
 	    (intr_coal->tx_max_coalesced_frames <= CN6XXX_DB_MAX)) {
 		for (j = 0; j < lio->linfo.num_txpciq; j++) {
-			q_no = lio->linfo.txpciq[j];
+			q_no = lio->linfo.txpciq[j].s.q_no;
 			oct->instr_queue[q_no]->fill_threshold =
 				intr_coal->tx_max_coalesced_frames;
 		}
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 47fba0e..3477a3c 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -682,7 +682,8 @@ static inline void txqs_wake(struct net_device *netdev)
 		int i;
 
 		for (i = 0; i < netdev->num_tx_queues; i++)
-			netif_wake_subqueue(netdev, i);
+			if (__netif_subqueue_stopped(netdev, i))
+				netif_wake_subqueue(netdev, i);
 	} else {
 		netif_wake_queue(netdev);
 	}
@@ -752,11 +753,14 @@ static inline int check_txq_status(struct lio *lio)
 
 		/* check each sub-queue state */
 		for (q = 0; q < numqs; q++) {
-			iq = lio->linfo.txpciq[q & (lio->linfo.num_txpciq - 1)];
+			iq = lio->linfo.txpciq[q %
+				(lio->linfo.num_txpciq)].s.q_no;
 			if (octnet_iq_is_full(lio->oct_dev, iq))
 				continue;
-			wake_q(lio->netdev, q);
-			ret_val++;
+			if (__netif_subqueue_stopped(lio->netdev, q)) {
+				wake_q(lio->netdev, q);
+				ret_val++;
+			}
 		}
 	} else {
 		if (octnet_iq_is_full(lio->oct_dev, lio->txq))
@@ -1230,7 +1234,8 @@ static int liquidio_stop_nic_module(struct octeon_device *oct)
 	for (i = 0; i < oct->ifcount; i++) {
 		lio = GET_LIO(oct->props[i].netdev);
 		for (j = 0; j < lio->linfo.num_rxpciq; j++)
-			octeon_unregister_droq_ops(oct, lio->linfo.rxpciq[j]);
+			octeon_unregister_droq_ops(oct,
+						   lio->linfo.rxpciq[j].s.q_no);
 	}
 
 	for (i = 0; i < oct->ifcount; i++)
@@ -1337,14 +1342,17 @@ static inline int check_txq_state(struct lio *lio, struct sk_buff *skb)
 
 	if (netif_is_multiqueue(lio->netdev)) {
 		q = skb->queue_mapping;
-		iq = lio->linfo.txpciq[(q & (lio->linfo.num_txpciq - 1))];
+		iq = lio->linfo.txpciq[(q % (lio->linfo.num_txpciq))].s.q_no;
 	} else {
 		iq = lio->txq;
+		q = iq;
 	}
 
 	if (octnet_iq_is_full(lio->oct_dev, iq))
 		return 0;
-	wake_q(lio->netdev, q);
+
+	if (__netif_subqueue_stopped(lio->netdev, q))
+		wake_q(lio->netdev, q);
 	return 1;
 }
 
@@ -1743,14 +1751,13 @@ static void if_cfg_callback(struct octeon_device *oct,
 static u16 select_q(struct net_device *dev, struct sk_buff *skb,
 		    void *accel_priv, select_queue_fallback_t fallback)
 {
-	int qindex;
+	u32 qindex = 0;
 	struct lio *lio;
 
 	lio = GET_LIO(dev);
-	/* select queue on chosen queue_mapping or core */
-	qindex = skb_rx_queue_recorded(skb) ?
-		 skb_get_rx_queue(skb) : smp_processor_id();
-	return (u16)(qindex & (lio->linfo.num_txpciq - 1));
+	qindex = skb_tx_hash(dev, skb);
+
+	return (u16)(qindex % (lio->linfo.num_txpciq));
 }
 
 /** Routine to push packets arriving on Octeon interface upto network layer.
@@ -1789,6 +1796,8 @@ liquidio_push_packet(u32 octeon_id,
 
 		skb->dev = netdev;
 
+		skb_record_rx_queue(skb, droq->q_no);
+
 		if (rh->r_dh.has_hwtstamp) {
 			/* timestamp is included from the hardware at the
 			 * beginning of the packet.
@@ -1962,8 +1971,10 @@ static inline int setup_io_queues(struct octeon_device *octeon_dev,
 
 	/* set up DROQs. */
 	for (q = 0; q < lio->linfo.num_rxpciq; q++) {
-		q_no = lio->linfo.rxpciq[q];
-
+		q_no = lio->linfo.rxpciq[q].s.q_no;
+		dev_dbg(&octeon_dev->pci_dev->dev,
+			"setup_io_queues index:%d linfo.rxpciq.s.q_no:%d\n",
+			q, q_no);
 		retval = octeon_setup_droq(octeon_dev, q_no,
 					   CFG_GET_NUM_RX_DESCS_NIC_IF
 						   (octeon_get_conf(octeon_dev),
@@ -2341,7 +2352,7 @@ static struct net_device_stats *liquidio_get_stats(struct net_device *netdev)
 	oct = lio->oct_dev;
 
 	for (i = 0; i < lio->linfo.num_txpciq; i++) {
-		iq_no = lio->linfo.txpciq[i];
+		iq_no = lio->linfo.txpciq[i].s.q_no;
 		iq_stats = &oct->instr_queue[iq_no]->stats;
 		pkts += iq_stats->tx_done;
 		drop += iq_stats->tx_dropped;
@@ -2357,7 +2368,7 @@ static struct net_device_stats *liquidio_get_stats(struct net_device *netdev)
 	bytes = 0;
 
 	for (i = 0; i < lio->linfo.num_rxpciq; i++) {
-		oq_no = lio->linfo.rxpciq[i];
+		oq_no = lio->linfo.rxpciq[i].s.q_no;
 		oq_stats = &oct->droq[oq_no]->stats;
 		pkts += oq_stats->rx_pkts_received;
 		drop += (oq_stats->rx_dropped +
@@ -2670,7 +2681,7 @@ static int liquidio_xmit(struct sk_buff *skb, struct net_device *netdev)
 	struct octnic_data_pkt ndata;
 	struct octeon_device *oct;
 	struct oct_iq_stats *stats;
-	int cpu = 0, status = 0;
+	int status = 0;
 	int q_idx = 0, iq_no = 0;
 	int xmit_more;
 	u32 tag = 0;
@@ -2679,9 +2690,10 @@ static int liquidio_xmit(struct sk_buff *skb, struct net_device *netdev)
 	oct = lio->oct_dev;
 
 	if (netif_is_multiqueue(netdev)) {
-		cpu = skb->queue_mapping;
-		q_idx = (cpu & (lio->linfo.num_txpciq - 1));
-		iq_no = lio->linfo.txpciq[q_idx];
+		q_idx = skb->queue_mapping;
+		q_idx = (q_idx % (lio->linfo.num_txpciq));
+		tag = q_idx;
+		iq_no = lio->linfo.txpciq[q_idx].s.q_no;
 	} else {
 		iq_no = lio->txq;
 	}
@@ -3125,7 +3137,7 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 	struct liquidio_if_cfg_context *ctx;
 	struct liquidio_if_cfg_resp *resp;
 	struct octdev_props *props;
-	int retval, num_iqueues, num_oqueues, q_no;
+	int retval, num_iqueues, num_oqueues;
 	u64 q_mask;
 	int num_cpus = num_online_cpus();
 	union oct_nic_if_cfg if_cfg;
@@ -3257,15 +3269,13 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 		q_mask = resp->cfg_info.oqmask;
 		/* q_mask is 0-based and already verified mask is nonzero */
 		for (j = 0; j < num_oqueues; j++) {
-			q_no = __ffs64(q_mask);
-			q_mask &= (~(1UL << q_no));
-			lio->linfo.rxpciq[j] = q_no;
+			lio->linfo.rxpciq[j].u64 =
+				resp->cfg_info.linfo.rxpciq[j].u64;
 		}
 		q_mask = resp->cfg_info.iqmask;
 		for (j = 0; j < num_iqueues; j++) {
-			q_no = __ffs64(q_mask);
-			q_mask &= (~(1UL << q_no));
-			lio->linfo.txpciq[j] = q_no;
+			lio->linfo.txpciq[j].u64 =
+				resp->cfg_info.linfo.txpciq[j].u64;
 		}
 		lio->linfo.hw_addr = resp->cfg_info.linfo.hw_addr;
 		lio->linfo.gmxport = resp->cfg_info.linfo.gmxport;
@@ -3306,6 +3316,11 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 
 		ether_addr_copy(netdev->dev_addr, mac);
 
+		/* By default all interfaces on a single Octeon uses the same
+		 * tx and rx queues
+		 */
+		lio->txq = lio->linfo.txpciq[0].s.q_no;
+		lio->rxq = lio->linfo.rxpciq[0].s.q_no;
 		if (setup_io_queues(octeon_dev, netdev)) {
 			dev_err(&octeon_dev->pci_dev->dev, "I/O queues creation failed\n");
 			goto setup_nic_dev_fail;
@@ -3313,12 +3328,6 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 
 		ifstate_set(lio, LIO_IFSTATE_DROQ_OPS);
 
-		/* By default all interfaces on a single Octeon uses the same
-		 * tx and rx queues
-		 */
-		lio->txq = lio->linfo.txpciq[0];
-		lio->rxq = lio->linfo.rxpciq[0];
-
 		lio->tx_qsize = octeon_get_tx_qsize(octeon_dev, lio->txq);
 		lio->rx_qsize = octeon_get_rx_qsize(octeon_dev, lio->rxq);
 
diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
index 0ac347c..00b3ef5 100644
--- a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
+++ b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
@@ -516,6 +516,46 @@ union oct_link_status {
 	} s;
 };
 
+/** The txpciq info passed to host from the firmware */
+
+union oct_txpciq {
+	u64 u64;
+
+	struct {
+#ifdef __BIG_ENDIAN_BITFIELD
+		u64 q_no:8;
+		u64 port:8;
+		u64 pkind:6;
+		u64 use_qpg:1;
+		u64 qpg:11;
+		u64 reserved:30;
+#else
+		u64 reserved:30;
+		u64 qpg:11;
+		u64 use_qpg:1;
+		u64 pkind:6;
+		u64 port:8;
+		u64 q_no:8;
+#endif
+	} s;
+};
+
+/** The rxpciq info passed to host from the firmware */
+
+union oct_rxpciq {
+	u64 u64;
+
+	struct {
+#ifdef __BIG_ENDIAN_BITFIELD
+		u64 q_no:8;
+		u64 reserved:56;
+#else
+		u64 reserved:56;
+		u64 q_no:8;
+#endif
+	} s;
+};
+
 /** Information for a OCTEON ethernet interface shared between core & host. */
 struct oct_link_info {
 	union oct_link_status link;
@@ -535,8 +575,8 @@ struct oct_link_info {
 	u16 gmxport;
 #endif
 
-	u8 txpciq[MAX_IOQS_PER_NICIF];
-	u8 rxpciq[MAX_IOQS_PER_NICIF];
+	union oct_txpciq txpciq[MAX_IOQS_PER_NICIF];
+	union oct_rxpciq rxpciq[MAX_IOQS_PER_NICIF];
 };
 
 #define OCT_LINK_INFO_SIZE   (sizeof(struct oct_link_info))
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.c b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
index 8e23e3f..967fe4d 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
@@ -741,36 +741,43 @@ struct octeon_device *octeon_allocate_device(u32 pci_id,
 	return oct;
 }
 
+/* this function is only for setting up the first queue */
 int octeon_setup_instr_queues(struct octeon_device *oct)
 {
-	u32 i, num_iqs = 0;
+	u32 num_iqs = 0;
 	u32 num_descs = 0;
+	u32 iq_no = 0;
+	union oct_txpciq txpciq;
+	int numa_node = cpu_to_node(iq_no % num_online_cpus());
 
+	num_iqs = 1;
 	/* this causes queue 0 to be default queue */
-	if (OCTEON_CN6XXX(oct)) {
-		num_iqs = 1;
+	if (OCTEON_CN6XXX(oct))
 		num_descs =
 			CFG_GET_NUM_DEF_TX_DESCS(CHIP_FIELD(oct, cn6xxx, conf));
-	}
 
 	oct->num_iqs = 0;
 
-	for (i = 0; i < num_iqs; i++) {
-		oct->instr_queue[i] =
+	oct->instr_queue[0] = vmalloc_node(sizeof(*oct->instr_queue[0]),
+				numa_node);
+	if (!oct->instr_queue[0])
+		oct->instr_queue[0] =
 			vmalloc(sizeof(struct octeon_instr_queue));
-		if (!oct->instr_queue[i])
-			return 1;
-
-		memset(oct->instr_queue[i], 0,
-		       sizeof(struct octeon_instr_queue));
-
-		oct->instr_queue[i]->app_ctx = (void *)(size_t)i;
-		if (octeon_init_instr_queue(oct, i, num_descs))
-			return 1;
-
-		oct->num_iqs++;
+	if (!oct->instr_queue[0])
+		return 1;
+	memset(oct->instr_queue[0], 0, sizeof(struct octeon_instr_queue));
+	oct->instr_queue[0]->app_ctx = (void *)(size_t)0;
+	txpciq.u64 = 0;
+	txpciq.s.q_no = iq_no;
+	txpciq.s.use_qpg = 0;
+	txpciq.s.qpg = 0;
+	if (octeon_init_instr_queue(oct, txpciq, num_descs)) {
+		/* prevent memory leak */
+		vfree(oct->instr_queue[0]);
+		return 1;
 	}
 
+	oct->num_iqs++;
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_iq.h b/drivers/net/ethernet/cavium/liquidio/octeon_iq.h
index 592fe49..658f1d0 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_iq.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_iq.h
@@ -81,8 +81,8 @@ struct octeon_instr_queue {
 	/** Flag that indicates if the queue uses 64 byte commands. */
 	u32 iqcmd_64B:1;
 
-	/** Queue Number. */
-	u32 iq_no:5;
+	/** Queue info. */
+	union oct_txpciq txpciq;
 
 	u32 rsvd:17;
 
@@ -268,14 +268,15 @@ void octeon_free_soft_command(struct octeon_device *oct,
 /**
  *  octeon_init_instr_queue()
  *  @param octeon_dev      - pointer to the octeon device structure.
- *  @param iq_no           - queue to be initialized (0 <= q_no <= 3).
+ *  @param txpciq          - queue to be initialized (0 <= q_no <= 3).
  *
  *  Called at driver init time for each input queue. iq_conf has the
  *  configuration parameters for the queue.
  *
  *  @return  Success: 0   Failure: 1
  */
-int octeon_init_instr_queue(struct octeon_device *octeon_dev, u32 iq_no,
+int octeon_init_instr_queue(struct octeon_device *octeon_dev,
+			    union oct_txpciq txpciq,
 			    u32 num_descs);
 
 /**
@@ -313,7 +314,7 @@ void octeon_prepare_soft_command(struct octeon_device *oct,
 int octeon_send_soft_command(struct octeon_device *oct,
 			     struct octeon_soft_command *sc);
 
-int octeon_setup_iq(struct octeon_device *oct, u32 iq_no,
+int octeon_setup_iq(struct octeon_device *oct, union oct_txpciq,
 		    u32 num_descs, void *app_ctx);
 
 #endif				/* __OCTEON_IQ_H__ */
diff --git a/drivers/net/ethernet/cavium/liquidio/request_manager.c b/drivers/net/ethernet/cavium/liquidio/request_manager.c
index 9313915..1240461 100644
--- a/drivers/net/ethernet/cavium/liquidio/request_manager.c
+++ b/drivers/net/ethernet/cavium/liquidio/request_manager.c
@@ -69,12 +69,16 @@ static inline int IQ_INSTR_MODE_64B(struct octeon_device *oct, int iq_no)
 
 /* Return 0 on success, 1 on failure */
 int octeon_init_instr_queue(struct octeon_device *oct,
-			    u32 iq_no, u32 num_descs)
+			    union oct_txpciq txpciq,
+			    u32 num_descs)
 {
 	struct octeon_instr_queue *iq;
 	struct octeon_iq_config *conf = NULL;
+	u32 iq_no = (u32)txpciq.s.q_no;
 	u32 q_size;
 	struct cavium_wq *db_wq;
+	int orig_node = dev_to_node(&oct->pci_dev->dev);
+	int numa_node = cpu_to_node(iq_no % num_online_cpus());
 
 	if (OCTEON_CN6XXX(oct))
 		conf = &(CFG_GET_IQ_CFG(CHIP_FIELD(oct, cn6xxx, conf)));
@@ -96,8 +100,13 @@ int octeon_init_instr_queue(struct octeon_device *oct,
 
 	iq = oct->instr_queue[iq_no];
 
+	set_dev_node(&oct->pci_dev->dev, numa_node);
 	iq->base_addr = lio_dma_alloc(oct, q_size,
 				      (dma_addr_t *)&iq->base_addr_dma);
+	set_dev_node(&oct->pci_dev->dev, orig_node);
+	if (!iq->base_addr)
+		iq->base_addr = lio_dma_alloc(oct, q_size,
+					      (dma_addr_t *)&iq->base_addr_dma);
 	if (!iq->base_addr) {
 		dev_err(&oct->pci_dev->dev, "Cannot allocate memory for instr queue %d\n",
 			iq_no);
@@ -109,7 +118,11 @@ int octeon_init_instr_queue(struct octeon_device *oct,
 	/* Initialize a list to holds requests that have been posted to Octeon
 	 * but has yet to be fetched by octeon
 	 */
-	iq->request_list = vmalloc(sizeof(*iq->request_list) * num_descs);
+	iq->request_list = vmalloc_node((sizeof(*iq->request_list) * num_descs),
+					       numa_node);
+	if (!iq->request_list)
+		iq->request_list = vmalloc(sizeof(*iq->request_list) *
+						  num_descs);
 	if (!iq->request_list) {
 		lio_dma_free(oct, q_size, iq->base_addr, iq->base_addr_dma);
 		dev_err(&oct->pci_dev->dev, "Alloc failed for IQ[%d] nr free list\n",
@@ -122,7 +135,7 @@ int octeon_init_instr_queue(struct octeon_device *oct,
 	dev_dbg(&oct->pci_dev->dev, "IQ[%d]: base: %p basedma: %llx count: %d\n",
 		iq_no, iq->base_addr, iq->base_addr_dma, iq->max_count);
 
-	iq->iq_no = iq_no;
+	iq->txpciq.u64 = txpciq.u64;
 	iq->fill_threshold = (u32)conf->db_min;
 	iq->fill_cnt = 0;
 	iq->host_write_index = 0;
@@ -189,18 +202,25 @@ int octeon_delete_instr_queue(struct octeon_device *oct, u32 iq_no)
 
 /* Return 0 on success, 1 on failure */
 int octeon_setup_iq(struct octeon_device *oct,
-		    u32 iq_no,
+		    union oct_txpciq txpciq,
 		    u32 num_descs,
 		    void *app_ctx)
 {
+	u32 iq_no = (u32)txpciq.s.q_no;
+	int numa_node = cpu_to_node(iq_no % num_online_cpus());
+
 	if (oct->instr_queue[iq_no]) {
 		dev_dbg(&oct->pci_dev->dev, "IQ is in use. Cannot create the IQ: %d again\n",
 			iq_no);
+		oct->instr_queue[iq_no]->txpciq.u64 = txpciq.u64;
 		oct->instr_queue[iq_no]->app_ctx = app_ctx;
 		return 0;
 	}
 	oct->instr_queue[iq_no] =
-	    vmalloc(sizeof(struct octeon_instr_queue));
+	    vmalloc_node(sizeof(struct octeon_instr_queue), numa_node);
+	if (!oct->instr_queue[iq_no])
+		oct->instr_queue[iq_no] =
+		    vmalloc(sizeof(struct octeon_instr_queue));
 	if (!oct->instr_queue[iq_no])
 		return 1;
 
@@ -208,7 +228,7 @@ int octeon_setup_iq(struct octeon_device *oct,
 	       sizeof(struct octeon_instr_queue));
 
 	oct->instr_queue[iq_no]->app_ctx = app_ctx;
-	if (octeon_init_instr_queue(oct, iq_no, num_descs)) {
+	if (octeon_init_instr_queue(oct, txpciq, num_descs)) {
 		vfree(oct->instr_queue[iq_no]);
 		oct->instr_queue[iq_no] = NULL;
 		return 1;
-- 
1.8.3.1
