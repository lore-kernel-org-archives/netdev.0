From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [net-next PATCH v2 13/29] fm10k: add support for Tx/Rx rings
Date: Sat, 20 Sep 2014 19:49:03 -0400
Message-ID: <20140920234856.2977.86655.stgit@ahduyck-bv4.jf.intel.com>
References: <20140920234342.2977.21667.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: nhorman@redhat.com, netdev@vger.kernel.org,
	john.fastabend@gmail.com, matthew.vick@intel.com,
	jeffrey.t.kirsher@intel.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:61161 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751649AbaITX5q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Sep 2014 19:57:46 -0400
In-Reply-To: <20140920234342.2977.21667.stgit@ahduyck-bv4.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change adds the defines and structures necessary to support both Tx
and Rx descriptor rings.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k.h        |  188 +++++++++++++++++++++++
 drivers/net/ethernet/intel/fm10k/fm10k_main.c   |   63 ++++++++
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c |   70 ++++++++-
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c    |    4 
 4 files changed, 323 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k.h b/drivers/net/ethernet/intel/fm10k/fm10k.h
index 3f83eeb..ae48d72 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k.h
@@ -31,7 +31,118 @@
 
 #define FM10K_MAX_JUMBO_FRAME_SIZE	15358	/* Maximum supported size 15K */
 
+#define MAX_QUEUES	FM10K_MAX_QUEUES_PF
+
+#define FM10K_MIN_RXD		 128
+#define FM10K_MAX_RXD		4096
+#define FM10K_DEFAULT_RXD	 256
+
+#define FM10K_MIN_TXD		 128
+#define FM10K_MAX_TXD		4096
+#define FM10K_DEFAULT_TXD	 256
+#define FM10K_DEFAULT_TX_WORK	 256
+
+#define FM10K_RXBUFFER_256	  256
+#define FM10K_RXBUFFER_16384	16384
+#define FM10K_RX_HDR_LEN	FM10K_RXBUFFER_256
+#if PAGE_SIZE <= FM10K_RXBUFFER_16384
+#define FM10K_RX_BUFSZ		(PAGE_SIZE / 2)
+#else
+#define FM10K_RX_BUFSZ		FM10K_RXBUFFER_16384
+#endif
+
+/* How many Rx Buffers do we bundle into one write to the hardware ? */
+#define FM10K_RX_BUFFER_WRITE	16	/* Must be power of 2 */
+
+enum fm10k_ring_state_t {
+	__FM10K_TX_DETECT_HANG,
+	__FM10K_HANG_CHECK_ARMED,
+};
+
+#define check_for_tx_hang(ring) \
+	test_bit(__FM10K_TX_DETECT_HANG, &(ring)->state)
+#define set_check_for_tx_hang(ring) \
+	set_bit(__FM10K_TX_DETECT_HANG, &(ring)->state)
+#define clear_check_for_tx_hang(ring) \
+	clear_bit(__FM10K_TX_DETECT_HANG, &(ring)->state)
+
+struct fm10k_tx_buffer {
+	struct fm10k_tx_desc *next_to_watch;
+	struct sk_buff *skb;
+	unsigned int bytecount;
+	u16 gso_segs;
+	u16 tx_flags;
+	DEFINE_DMA_UNMAP_ADDR(dma);
+	DEFINE_DMA_UNMAP_LEN(len);
+};
+
+struct fm10k_rx_buffer {
+	dma_addr_t dma;
+	struct page *page;
+	u32 page_offset;
+};
+
+struct fm10k_queue_stats {
+	u64 packets;
+	u64 bytes;
+};
+
+struct fm10k_tx_queue_stats {
+	u64 restart_queue;
+	u64 csum_err;
+	u64 tx_busy;
+	u64 tx_done_old;
+};
+
+struct fm10k_rx_queue_stats {
+	u64 alloc_failed;
+	u64 csum_err;
+	u64 errors;
+};
+
+struct fm10k_ring {
+	struct fm10k_q_vector *q_vector;/* backpointer to host q_vector */
+	struct net_device *netdev;	/* netdev ring belongs to */
+	struct device *dev;		/* device for DMA mapping */
+	void *desc;			/* descriptor ring memory */
+	union {
+		struct fm10k_tx_buffer *tx_buffer;
+		struct fm10k_rx_buffer *rx_buffer;
+	};
+	u32 __iomem *tail;
+	unsigned long state;
+	dma_addr_t dma;			/* phys. address of descriptor ring */
+	unsigned int size;		/* length in bytes */
+
+	u8 queue_index;			/* needed for queue management */
+	u8 reg_idx;			/* holds the special value that gets
+					 * the hardware register offset
+					 * associated with this ring, which is
+					 * different for DCB and RSS modes
+					 */
+	u8 qos_pc;			/* priority class of queue */
+	u16 vid;			/* default vlan ID of queue */
+	u16 count;			/* amount of descriptors */
+
+	u16 next_to_alloc;
+	u16 next_to_use;
+	u16 next_to_clean;
+
+	struct fm10k_queue_stats stats;
+	struct u64_stats_sync syncp;
+	union {
+		/* Tx */
+		struct fm10k_tx_queue_stats tx_stats;
+		/* Rx */
+		struct {
+			struct fm10k_rx_queue_stats rx_stats;
+			struct sk_buff *skb;
+		};
+	};
+} ____cacheline_internodealigned_in_smp;
+
 struct fm10k_ring_container {
+	struct fm10k_ring *ring;	/* pointer to linked list of rings */
 	unsigned int total_bytes;	/* total bytes processed this int */
 	unsigned int total_packets;	/* total packets processed this int */
 	u16 work_limit;			/* total work allowed per interrupt */
@@ -46,6 +157,15 @@ struct fm10k_ring_container {
 
 #define FM10K_ITR_ENABLE	(FM10K_ITR_AUTOMASK | FM10K_ITR_MASK_CLEAR)
 
+static inline struct netdev_queue *txring_txq(const struct fm10k_ring *ring)
+{
+	return &ring->netdev->_tx[ring->queue_index];
+}
+
+/* iterator for handling rings in ring container */
+#define fm10k_for_each_ring(pos, head) \
+	for (pos = &(head).ring[(head).count]; (--pos) >= (head).ring;)
+
 #define MAX_Q_VECTORS 256
 #define MIN_Q_VECTORS	1
 enum fm10k_non_q_vectors {
@@ -68,6 +188,9 @@ struct fm10k_q_vector {
 	char name[IFNAMSIZ + 9];
 
 	struct rcu_head rcu;	/* to avoid race with update stats on free */
+
+	/* for dynamic allocation of rings associated with this q_vector */
+	struct fm10k_ring ring[0] ____cacheline_internodealigned_in_smp;
 };
 
 enum fm10k_ring_f_enum {
@@ -113,9 +236,15 @@ struct fm10k_intfc {
 	int num_rx_queues;
 	u16 rx_itr;
 
+	/* TX */
+	struct fm10k_ring *tx_ring[MAX_QUEUES] ____cacheline_aligned_in_smp;
+
 	u64 rx_overrun_pf;
 	u64 rx_overrun_vf;
 
+	/* RX */
+	struct fm10k_ring *rx_ring[MAX_QUEUES];
+
 	/* Queueing vectors */
 	struct fm10k_q_vector *q_vector[MAX_Q_VECTORS];
 	struct msix_entry *msix_entries;
@@ -176,6 +305,65 @@ static inline int fm10k_mbx_trylock(struct fm10k_intfc *interface)
 	return !test_and_set_bit(__FM10K_MBX_LOCK, &interface->state);
 }
 
+/* fm10k_test_staterr - test bits in Rx descriptor status and error fields */
+static inline __le32 fm10k_test_staterr(union fm10k_rx_desc *rx_desc,
+					const u32 stat_err_bits)
+{
+	return rx_desc->d.staterr & cpu_to_le32(stat_err_bits);
+}
+
+/* fm10k_desc_unused - calculate if we have unused descriptors */
+static inline u16 fm10k_desc_unused(struct fm10k_ring *ring)
+{
+	s16 unused = ring->next_to_clean - ring->next_to_use - 1;
+
+	return likely(unused < 0) ? unused + ring->count : unused;
+}
+
+#define FM10K_TX_DESC(R, i)	\
+	(&(((struct fm10k_tx_desc *)((R)->desc))[i]))
+#define FM10K_RX_DESC(R, i)	\
+	 (&(((union fm10k_rx_desc *)((R)->desc))[i]))
+
+#define FM10K_MAX_TXD_PWR	14
+#define FM10K_MAX_DATA_PER_TXD	(1 << FM10K_MAX_TXD_PWR)
+
+/* Tx Descriptors needed, worst case */
+#define TXD_USE_COUNT(S)	DIV_ROUND_UP((S), FM10K_MAX_DATA_PER_TXD)
+#define DESC_NEEDED	(MAX_SKB_FRAGS + 4)
+
+enum fm10k_tx_flags {
+	/* Tx offload flags */
+	FM10K_TX_FLAGS_CSUM	= 0x01,
+};
+
+/* This structure is stored as little endian values as that is the native
+ * format of the Rx descriptor.  The ordering of these fields is reversed
+ * from the actual ftag header to allow for a single bswap to take care
+ * of placing all of the values in network order
+ */
+union fm10k_ftag_info {
+	__le64 ftag;
+	struct {
+		/* dglort and sglort combined into a single 32bit desc read */
+		__le32 glort;
+		/* upper 16 bits of vlan are reserved 0 for swpri_type_user */
+		__le32 vlan;
+	} d;
+	struct {
+		__le16 dglort;
+		__le16 sglort;
+		__le16 vlan;
+		__le16 swpri_type_user;
+	} w;
+};
+
+struct fm10k_cb {
+	union fm10k_ftag_info fi;
+};
+
+#define FM10K_CB(skb) ((struct fm10k_cb *)(skb)->cb)
+
 /* main */
 extern char fm10k_driver_name[];
 extern const char fm10k_driver_version[];
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index b0a2ba1..bf84c26 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -183,10 +183,12 @@ static int fm10k_alloc_q_vector(struct fm10k_intfc *interface,
 				unsigned int rxr_count, unsigned int rxr_idx)
 {
 	struct fm10k_q_vector *q_vector;
+	struct fm10k_ring *ring;
 	int ring_count, size;
 
 	ring_count = txr_count + rxr_count;
-	size = sizeof(struct fm10k_q_vector);
+	size = sizeof(struct fm10k_q_vector) +
+	       (sizeof(struct fm10k_ring) * ring_count);
 
 	/* allocate q_vector and rings */
 	q_vector = kzalloc(size, GFP_KERNEL);
@@ -202,14 +204,66 @@ static int fm10k_alloc_q_vector(struct fm10k_intfc *interface,
 	q_vector->interface = interface;
 	q_vector->v_idx = v_idx;
 
+	/* initialize pointer to rings */
+	ring = q_vector->ring;
+
 	/* save Tx ring container info */
+	q_vector->tx.ring = ring;
+	q_vector->tx.work_limit = FM10K_DEFAULT_TX_WORK;
 	q_vector->tx.itr = interface->tx_itr;
 	q_vector->tx.count = txr_count;
 
+	while (txr_count) {
+		/* assign generic ring traits */
+		ring->dev = &interface->pdev->dev;
+		ring->netdev = interface->netdev;
+
+		/* configure backlink on ring */
+		ring->q_vector = q_vector;
+
+		/* apply Tx specific ring traits */
+		ring->count = interface->tx_ring_count;
+		ring->queue_index = txr_idx;
+
+		/* assign ring to interface */
+		interface->tx_ring[txr_idx] = ring;
+
+		/* update count and index */
+		txr_count--;
+		txr_idx += v_count;
+
+		/* push pointer to next ring */
+		ring++;
+	}
+
 	/* save Rx ring container info */
+	q_vector->rx.ring = ring;
 	q_vector->rx.itr = interface->rx_itr;
 	q_vector->rx.count = rxr_count;
 
+	while (rxr_count) {
+		/* assign generic ring traits */
+		ring->dev = &interface->pdev->dev;
+		ring->netdev = interface->netdev;
+
+		/* configure backlink on ring */
+		ring->q_vector = q_vector;
+
+		/* apply Rx specific ring traits */
+		ring->count = interface->rx_ring_count;
+		ring->queue_index = rxr_idx;
+
+		/* assign ring to interface */
+		interface->rx_ring[rxr_idx] = ring;
+
+		/* update count and index */
+		rxr_count--;
+		rxr_idx += v_count;
+
+		/* push pointer to next ring */
+		ring++;
+	}
+
 	return 0;
 }
 
@@ -225,6 +279,13 @@ static int fm10k_alloc_q_vector(struct fm10k_intfc *interface,
 static void fm10k_free_q_vector(struct fm10k_intfc *interface, int v_idx)
 {
 	struct fm10k_q_vector *q_vector = interface->q_vector[v_idx];
+	struct fm10k_ring *ring;
+
+	fm10k_for_each_ring(ring, q_vector->tx)
+		interface->tx_ring[ring->queue_index] = NULL;
+
+	fm10k_for_each_ring(ring, q_vector->rx)
+		interface->rx_ring[ring->queue_index] = NULL;
 
 	interface->q_vector[v_idx] = NULL;
 	netif_napi_del(&q_vector->napi);
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index 487efcb..b987bb6 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -67,10 +67,19 @@ int fm10k_open(struct net_device *netdev)
 	/* setup GLORT assignment for this port */
 	fm10k_request_glort_range(interface);
 
+	/* Notify the stack of the actual queue counts */
+
+	err = netif_set_real_num_rx_queues(netdev,
+					   interface->num_rx_queues);
+	if (err)
+		goto err_set_queues;
+
 	fm10k_up(interface);
 
 	return 0;
 
+err_set_queues:
+	fm10k_qv_free_irq(interface);
 err_req_irq:
 	return err;
 }
@@ -474,6 +483,64 @@ void fm10k_reset_rx_state(struct fm10k_intfc *interface)
 	__dev_mc_unsync(netdev, NULL);
 }
 
+/**
+ * fm10k_get_stats64 - Get System Network Statistics
+ * @netdev: network interface device structure
+ * @stats: storage space for 64bit statistics
+ *
+ * Returns 64bit statistics, for use in the ndo_get_stats64 callback. This
+ * function replaces fm10k_get_stats for kernels which support it.
+ */
+static struct rtnl_link_stats64 *fm10k_get_stats64(struct net_device *netdev,
+						   struct rtnl_link_stats64 *stats)
+{
+	struct fm10k_intfc *interface = netdev_priv(netdev);
+	struct fm10k_ring *ring;
+	unsigned int start, i;
+	u64 bytes, packets;
+
+	rcu_read_lock();
+
+	for (i = 0; i < interface->num_rx_queues; i++) {
+		ring = ACCESS_ONCE(interface->rx_ring[i]);
+
+		if (!ring)
+			continue;
+
+		do {
+			start = u64_stats_fetch_begin_irq(&ring->syncp);
+			packets = ring->stats.packets;
+			bytes   = ring->stats.bytes;
+		} while (u64_stats_fetch_retry_irq(&ring->syncp, start));
+
+		stats->rx_packets += packets;
+		stats->rx_bytes   += bytes;
+	}
+
+	for (i = 0; i < interface->num_tx_queues; i++) {
+		ring = ACCESS_ONCE(interface->rx_ring[i]);
+
+		if (!ring)
+			continue;
+
+		do {
+			start = u64_stats_fetch_begin_irq(&ring->syncp);
+			packets = ring->stats.packets;
+			bytes   = ring->stats.bytes;
+		} while (u64_stats_fetch_retry_irq(&ring->syncp, start));
+
+		stats->tx_packets += packets;
+		stats->tx_bytes   += bytes;
+	}
+
+	rcu_read_unlock();
+
+	/* following stats updated by fm10k_service_task() */
+	stats->rx_missed_errors	= netdev->stats.rx_missed_errors;
+
+	return stats;
+}
+
 static const struct net_device_ops fm10k_netdev_ops = {
 	.ndo_open		= fm10k_open,
 	.ndo_stop		= fm10k_close,
@@ -484,6 +551,7 @@ static const struct net_device_ops fm10k_netdev_ops = {
 	.ndo_vlan_rx_add_vid	= fm10k_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	= fm10k_vlan_rx_kill_vid,
 	.ndo_set_rx_mode	= fm10k_set_rx_mode,
+	.ndo_get_stats64	= fm10k_get_stats64,
 };
 
 #define DEFAULT_DEBUG_LEVEL_SHIFT 3
@@ -493,7 +561,7 @@ struct net_device *fm10k_alloc_netdev(void)
 	struct fm10k_intfc *interface;
 	struct net_device *dev;
 
-	dev = alloc_etherdev(sizeof(struct fm10k_intfc));
+	dev = alloc_etherdev_mq(sizeof(struct fm10k_intfc), MAX_QUEUES);
 	if (!dev)
 		return NULL;
 
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 2257ab1..5a28298 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -707,6 +707,10 @@ static int fm10k_sw_init(struct fm10k_intfc *interface,
 		netdev->hw_features &= ~NETIF_F_GSO_UDP_TUNNEL;
 	}
 
+	/* set default ring sizes */
+	interface->tx_ring_count = FM10K_DEFAULT_TXD;
+	interface->rx_ring_count = FM10K_DEFAULT_RXD;
+
 	/* set default interrupt moderation */
 	interface->tx_itr = FM10K_ITR_10K;
 	interface->rx_itr = FM10K_ITR_ADAPTIVE | FM10K_ITR_20K;
