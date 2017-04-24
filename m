From: John Fastabend <john.fastabend@gmail.com>
Subject: [PATCH 2/2] ixgbe: add support for XDP_TX action
Date: Sun, 23 Apr 2017 18:31:36 -0700
Message-ID: <20170424013135.8354.93583.stgit@john-Precision-Tower-5810>
References: <20170424013004.8354.34893.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:34356 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1163998AbdDXBbs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Apr 2017 21:31:48 -0400
Received: by mail-io0-f194.google.com with SMTP id h41so44252060ioi.1
        for <netdev@vger.kernel.org>; Sun, 23 Apr 2017 18:31:48 -0700 (PDT)
In-Reply-To: <20170424013004.8354.34893.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>

Add support for XDP_TX action.

A couple design choices were made here. First I use a new ring
pointer structure xdp_ring[] in the adapter struct instead of
pushing the newly allocated xdp TX rings into the tx_ring[]
structure. This means we have to duplicate loops around rings
in places we want to initialize both TX rings and XDP rings.
But by making it explicit it is obvious when we are using XDP
rings and when we are using TX rings. Further we don't have
to do ring arithmatic which is error prone. As a proof point
for doing this my first patches used only a single ring structure
and introduced bugs in FCoE code and macvlan code paths.

Second I am aware this is not the most optimized version of
this code possible. I want to get baseline support in using
the most readable format possible and then once this series
is included I will optimize the TX path in another series
of patches.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 0 files changed

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index cb14813..e8cd449 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -235,7 +235,11 @@ struct vf_macvlans {
 struct ixgbe_tx_buffer {
 	union ixgbe_adv_tx_desc *next_to_watch;
 	unsigned long time_stamp;
-	struct sk_buff *skb;
+	union {
+		struct sk_buff *skb;
+		/* XDP uses address ptr on irq_clean */
+		void *data;
+	};
 	unsigned int bytecount;
 	unsigned short gso_segs;
 	__be16 protocol;
@@ -288,6 +292,7 @@ enum ixgbe_ring_state_t {
 	__IXGBE_TX_XPS_INIT_DONE,
 	__IXGBE_TX_DETECT_HANG,
 	__IXGBE_HANG_CHECK_ARMED,
+	__IXGBE_TX_XDP_RING,
 };
 
 #define ring_uses_build_skb(ring) \
@@ -314,6 +319,12 @@ struct ixgbe_fwd_adapter {
 	set_bit(__IXGBE_RX_RSC_ENABLED, &(ring)->state)
 #define clear_ring_rsc_enabled(ring) \
 	clear_bit(__IXGBE_RX_RSC_ENABLED, &(ring)->state)
+#define ring_is_xdp(ring) \
+	test_bit(__IXGBE_TX_XDP_RING, &(ring)->state)
+#define set_ring_xdp(ring) \
+	set_bit(__IXGBE_TX_XDP_RING, &(ring)->state)
+#define clear_ring_xdp(ring) \
+	clear_bit(__IXGBE_TX_XDP_RING, &(ring)->state)
 struct ixgbe_ring {
 	struct ixgbe_ring *next;	/* pointer to next ring in q_vector */
 	struct ixgbe_q_vector *q_vector; /* backpointer to host q_vector */
@@ -380,6 +391,7 @@ enum ixgbe_ring_f_enum {
 #define IXGBE_MAX_FCOE_INDICES		8
 #define MAX_RX_QUEUES			(IXGBE_MAX_FDIR_INDICES + 1)
 #define MAX_TX_QUEUES			(IXGBE_MAX_FDIR_INDICES + 1)
+#define MAX_XDP_QUEUES			(IXGBE_MAX_FDIR_INDICES + 1)
 #define IXGBE_MAX_L2A_QUEUES		4
 #define IXGBE_BAD_L2A_QUEUE		3
 #define IXGBE_MAX_MACVLANS		31
@@ -623,6 +635,10 @@ struct ixgbe_adapter {
 	__be16 vxlan_port;
 	__be16 geneve_port;
 
+	/* XDP */
+	int num_xdp_queues;
+	struct ixgbe_ring *xdp_ring[MAX_XDP_QUEUES];
+
 	/* TX */
 	struct ixgbe_ring *tx_ring[MAX_TX_QUEUES] ____cacheline_aligned_in_smp;
 
@@ -669,6 +685,7 @@ struct ixgbe_adapter {
 
 	u64 tx_busy;
 	unsigned int tx_ring_count;
+	unsigned int xdp_ring_count;
 	unsigned int rx_ring_count;
 
 	u32 link_speed;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 79a126d..b0fd2f5 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -1071,15 +1071,19 @@ static int ixgbe_set_ringparam(struct net_device *netdev,
 	if (!netif_running(adapter->netdev)) {
 		for (i = 0; i < adapter->num_tx_queues; i++)
 			adapter->tx_ring[i]->count = new_tx_count;
+		for (i = 0; i < adapter->num_xdp_queues; i++)
+			adapter->xdp_ring[i]->count = new_tx_count;
 		for (i = 0; i < adapter->num_rx_queues; i++)
 			adapter->rx_ring[i]->count = new_rx_count;
 		adapter->tx_ring_count = new_tx_count;
+		adapter->xdp_ring_count = new_tx_count;
 		adapter->rx_ring_count = new_rx_count;
 		goto clear_reset;
 	}
 
 	/* allocate temporary buffer to store rings in */
 	i = max_t(int, adapter->num_tx_queues, adapter->num_rx_queues);
+	i = max_t(int, i, adapter->num_xdp_queues);
 	temp_ring = vmalloc(i * sizeof(struct ixgbe_ring));
 
 	if (!temp_ring) {
@@ -1111,12 +1115,33 @@ static int ixgbe_set_ringparam(struct net_device *netdev,
 			}
 		}
 
+		for (i = 0; i < adapter->num_xdp_queues; i++) {
+			memcpy(&temp_ring[i], adapter->xdp_ring[i],
+			       sizeof(struct ixgbe_ring));
+
+			temp_ring[i].count = new_tx_count;
+			err = ixgbe_setup_tx_resources(&temp_ring[i]);
+			if (err) {
+				while (i) {
+					i--;
+					ixgbe_free_tx_resources(&temp_ring[i]);
+				}
+				goto err_setup;
+			}
+		}
+
 		for (i = 0; i < adapter->num_tx_queues; i++) {
 			ixgbe_free_tx_resources(adapter->tx_ring[i]);
 
 			memcpy(adapter->tx_ring[i], &temp_ring[i],
 			       sizeof(struct ixgbe_ring));
 		}
+		for (i = 0; i < adapter->num_xdp_queues; i++) {
+			ixgbe_free_tx_resources(adapter->xdp_ring[i]);
+
+			memcpy(adapter->xdp_ring[i], &temp_ring[i],
+			       sizeof(struct ixgbe_ring));
+		}
 
 		adapter->tx_ring_count = new_tx_count;
 	}
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
index 1b8be7d..b45fdc9 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
@@ -267,12 +267,14 @@ static bool ixgbe_cache_ring_sriov(struct ixgbe_adapter *adapter)
  **/
 static bool ixgbe_cache_ring_rss(struct ixgbe_adapter *adapter)
 {
-	int i;
+	int i, reg_idx;
 
 	for (i = 0; i < adapter->num_rx_queues; i++)
 		adapter->rx_ring[i]->reg_idx = i;
-	for (i = 0; i < adapter->num_tx_queues; i++)
-		adapter->tx_ring[i]->reg_idx = i;
+	for (i = 0, reg_idx = 0; i < adapter->num_tx_queues; i++, reg_idx++)
+		adapter->tx_ring[i]->reg_idx = reg_idx;
+	for (i = 0; i < adapter->num_xdp_queues; i++, reg_idx++)
+		adapter->xdp_ring[i]->reg_idx = reg_idx;
 
 	return true;
 }
@@ -308,6 +310,11 @@ static void ixgbe_cache_ring_register(struct ixgbe_adapter *adapter)
 	ixgbe_cache_ring_rss(adapter);
 }
 
+static int ixgbe_xdp_queues(struct ixgbe_adapter *adapter)
+{
+	return adapter->xdp_prog ? nr_cpu_ids : 0;
+}
+
 #define IXGBE_RSS_64Q_MASK	0x3F
 #define IXGBE_RSS_16Q_MASK	0xF
 #define IXGBE_RSS_8Q_MASK	0x7
@@ -382,6 +389,7 @@ static bool ixgbe_set_dcb_sriov_queues(struct ixgbe_adapter *adapter)
 	adapter->num_rx_queues_per_pool = tcs;
 
 	adapter->num_tx_queues = vmdq_i * tcs;
+	adapter->num_xdp_queues = 0;
 	adapter->num_rx_queues = vmdq_i * tcs;
 
 #ifdef IXGBE_FCOE
@@ -479,6 +487,7 @@ static bool ixgbe_set_dcb_queues(struct ixgbe_adapter *adapter)
 		netdev_set_tc_queue(dev, i, rss_i, rss_i * i);
 
 	adapter->num_tx_queues = rss_i * tcs;
+	adapter->num_xdp_queues = 0;
 	adapter->num_rx_queues = rss_i * tcs;
 
 	return true;
@@ -549,6 +558,7 @@ static bool ixgbe_set_sriov_queues(struct ixgbe_adapter *adapter)
 
 	adapter->num_rx_queues = vmdq_i * rss_i;
 	adapter->num_tx_queues = vmdq_i * rss_i;
+	adapter->num_xdp_queues = 0;
 
 	/* disable ATR as it is not supported when VMDq is enabled */
 	adapter->flags &= ~IXGBE_FLAG_FDIR_HASH_CAPABLE;
@@ -669,6 +679,7 @@ static bool ixgbe_set_rss_queues(struct ixgbe_adapter *adapter)
 #endif /* IXGBE_FCOE */
 	adapter->num_rx_queues = rss_i;
 	adapter->num_tx_queues = rss_i;
+	adapter->num_xdp_queues = ixgbe_xdp_queues(adapter);
 
 	return true;
 }
@@ -689,6 +700,7 @@ static void ixgbe_set_num_queues(struct ixgbe_adapter *adapter)
 	/* Start with base case */
 	adapter->num_rx_queues = 1;
 	adapter->num_tx_queues = 1;
+	adapter->num_xdp_queues = 0;
 	adapter->num_rx_pools = adapter->num_rx_queues;
 	adapter->num_rx_queues_per_pool = 1;
 
@@ -719,8 +731,11 @@ static int ixgbe_acquire_msix_vectors(struct ixgbe_adapter *adapter)
 	struct ixgbe_hw *hw = &adapter->hw;
 	int i, vectors, vector_threshold;
 
-	/* We start by asking for one vector per queue pair */
+	/* We start by asking for one vector per queue pair with XDP queues
+	 * being stacked with TX queues.
+	 */
 	vectors = max(adapter->num_rx_queues, adapter->num_tx_queues);
+	vectors = max(vectors, adapter->num_xdp_queues);
 
 	/* It is easy to be greedy for MSI-X vectors. However, it really
 	 * doesn't do much good if we have a lot more vectors than CPUs. We'll
@@ -800,6 +815,8 @@ static void ixgbe_add_ring(struct ixgbe_ring *ring,
  * @v_idx: index of vector in adapter struct
  * @txr_count: total number of Tx rings to allocate
  * @txr_idx: index of first Tx ring to allocate
+ * @xdp_count: total number of XDP rings to allocate
+ * @xdp_idx: index of first XDP ring to allocate
  * @rxr_count: total number of Rx rings to allocate
  * @rxr_idx: index of first Rx ring to allocate
  *
@@ -808,6 +825,7 @@ static void ixgbe_add_ring(struct ixgbe_ring *ring,
 static int ixgbe_alloc_q_vector(struct ixgbe_adapter *adapter,
 				int v_count, int v_idx,
 				int txr_count, int txr_idx,
+				int xdp_count, int xdp_idx,
 				int rxr_count, int rxr_idx)
 {
 	struct ixgbe_q_vector *q_vector;
@@ -817,7 +835,7 @@ static int ixgbe_alloc_q_vector(struct ixgbe_adapter *adapter,
 	int ring_count, size;
 	u8 tcs = netdev_get_num_tc(adapter->netdev);
 
-	ring_count = txr_count + rxr_count;
+	ring_count = txr_count + rxr_count + xdp_count;
 	size = sizeof(struct ixgbe_q_vector) +
 	       (sizeof(struct ixgbe_ring) * ring_count);
 
@@ -909,6 +927,33 @@ static int ixgbe_alloc_q_vector(struct ixgbe_adapter *adapter,
 		ring++;
 	}
 
+	while (xdp_count) {
+		/* assign generic ring traits */
+		ring->dev = &adapter->pdev->dev;
+		ring->netdev = adapter->netdev;
+
+		/* configure backlink on ring */
+		ring->q_vector = q_vector;
+
+		/* update q_vector Tx values */
+		ixgbe_add_ring(ring, &q_vector->tx);
+
+		/* apply Tx specific ring traits */
+		ring->count = adapter->tx_ring_count;
+		ring->queue_index = xdp_idx;
+		set_ring_xdp(ring);
+
+		/* assign ring to adapter */
+		adapter->xdp_ring[xdp_idx] = ring;
+
+		/* update count and index */
+		xdp_count--;
+		xdp_idx++;
+
+		/* push pointer to next ring */
+		ring++;
+	}
+
 	while (rxr_count) {
 		/* assign generic ring traits */
 		ring->dev = &adapter->pdev->dev;
@@ -1002,17 +1047,18 @@ static int ixgbe_alloc_q_vectors(struct ixgbe_adapter *adapter)
 	int q_vectors = adapter->num_q_vectors;
 	int rxr_remaining = adapter->num_rx_queues;
 	int txr_remaining = adapter->num_tx_queues;
-	int rxr_idx = 0, txr_idx = 0, v_idx = 0;
+	int xdp_remaining = adapter->num_xdp_queues;
+	int rxr_idx = 0, txr_idx = 0, xdp_idx = 0, v_idx = 0;
 	int err;
 
 	/* only one q_vector if MSI-X is disabled. */
 	if (!(adapter->flags & IXGBE_FLAG_MSIX_ENABLED))
 		q_vectors = 1;
 
-	if (q_vectors >= (rxr_remaining + txr_remaining)) {
+	if (q_vectors >= (rxr_remaining + txr_remaining + xdp_remaining)) {
 		for (; rxr_remaining; v_idx++) {
 			err = ixgbe_alloc_q_vector(adapter, q_vectors, v_idx,
-						   0, 0, 1, rxr_idx);
+						   0, 0, 0, 0, 1, rxr_idx);
 
 			if (err)
 				goto err_out;
@@ -1026,8 +1072,11 @@ static int ixgbe_alloc_q_vectors(struct ixgbe_adapter *adapter)
 	for (; v_idx < q_vectors; v_idx++) {
 		int rqpv = DIV_ROUND_UP(rxr_remaining, q_vectors - v_idx);
 		int tqpv = DIV_ROUND_UP(txr_remaining, q_vectors - v_idx);
+		int xqpv = DIV_ROUND_UP(xdp_remaining, q_vectors - v_idx);
+
 		err = ixgbe_alloc_q_vector(adapter, q_vectors, v_idx,
 					   tqpv, txr_idx,
+					   xqpv, xdp_idx,
 					   rqpv, rxr_idx);
 
 		if (err)
@@ -1036,14 +1085,17 @@ static int ixgbe_alloc_q_vectors(struct ixgbe_adapter *adapter)
 		/* update counts and index */
 		rxr_remaining -= rqpv;
 		txr_remaining -= tqpv;
+		xdp_remaining -= xqpv;
 		rxr_idx++;
 		txr_idx++;
+		xdp_idx += xqpv;
 	}
 
 	return 0;
 
 err_out:
 	adapter->num_tx_queues = 0;
+	adapter->num_xdp_queues = 0;
 	adapter->num_rx_queues = 0;
 	adapter->num_q_vectors = 0;
 
@@ -1066,6 +1118,7 @@ static void ixgbe_free_q_vectors(struct ixgbe_adapter *adapter)
 	int v_idx = adapter->num_q_vectors;
 
 	adapter->num_tx_queues = 0;
+	adapter->num_xdp_queues = 0;
 	adapter->num_rx_queues = 0;
 	adapter->num_q_vectors = 0;
 
@@ -1172,9 +1225,10 @@ int ixgbe_init_interrupt_scheme(struct ixgbe_adapter *adapter)
 
 	ixgbe_cache_ring_register(adapter);
 
-	e_dev_info("Multiqueue %s: Rx Queue count = %u, Tx Queue count = %u\n",
+	e_dev_info("Multiqueue %s: Rx Queue count = %u, Tx Queue count = %u XDP Queue count = %u\n",
 		   (adapter->num_rx_queues > 1) ? "Enabled" : "Disabled",
-		   adapter->num_rx_queues, adapter->num_tx_queues);
+		   adapter->num_rx_queues, adapter->num_tx_queues,
+		   adapter->num_xdp_queues);
 
 	set_bit(__IXGBE_DOWN, &adapter->state);
 
@@ -1195,6 +1249,7 @@ int ixgbe_init_interrupt_scheme(struct ixgbe_adapter *adapter)
 void ixgbe_clear_interrupt_scheme(struct ixgbe_adapter *adapter)
 {
 	adapter->num_tx_queues = 0;
+	adapter->num_xdp_queues = 0;
 	adapter->num_rx_queues = 0;
 
 	ixgbe_free_q_vectors(adapter);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index ebcf9c0..a13d2bf 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -594,6 +594,19 @@ static void ixgbe_regdump(struct ixgbe_hw *hw, struct ixgbe_reg_info *reginfo)
 
 }
 
+static void ixgbe_print_buffer(struct ixgbe_ring *ring, int n)
+{
+	struct ixgbe_tx_buffer *tx_buffer;
+
+	tx_buffer = &ring->tx_buffer_info[ring->next_to_clean];
+	pr_info(" %5d %5X %5X %016llX %08X %p %016llX\n",
+		n, ring->next_to_use, ring->next_to_clean,
+		(u64)dma_unmap_addr(tx_buffer, dma),
+		dma_unmap_len(tx_buffer, len),
+		tx_buffer->next_to_watch,
+		(u64)tx_buffer->time_stamp);
+}
+
 /*
  * ixgbe_dump - Print registers, tx-rings and rx-rings
  */
@@ -603,7 +616,7 @@ static void ixgbe_dump(struct ixgbe_adapter *adapter)
 	struct ixgbe_hw *hw = &adapter->hw;
 	struct ixgbe_reg_info *reginfo;
 	int n = 0;
-	struct ixgbe_ring *tx_ring;
+	struct ixgbe_ring *ring;
 	struct ixgbe_tx_buffer *tx_buffer;
 	union ixgbe_adv_tx_desc *tx_desc;
 	struct my_u0 { u64 a; u64 b; } *u0;
@@ -643,14 +656,13 @@ static void ixgbe_dump(struct ixgbe_adapter *adapter)
 		"Queue [NTU] [NTC] [bi(ntc)->dma  ]",
 		"leng", "ntw", "timestamp");
 	for (n = 0; n < adapter->num_tx_queues; n++) {
-		tx_ring = adapter->tx_ring[n];
-		tx_buffer = &tx_ring->tx_buffer_info[tx_ring->next_to_clean];
-		pr_info(" %5d %5X %5X %016llX %08X %p %016llX\n",
-			   n, tx_ring->next_to_use, tx_ring->next_to_clean,
-			   (u64)dma_unmap_addr(tx_buffer, dma),
-			   dma_unmap_len(tx_buffer, len),
-			   tx_buffer->next_to_watch,
-			   (u64)tx_buffer->time_stamp);
+		ring = adapter->tx_ring[n];
+		ixgbe_print_buffer(ring, n);
+	}
+
+	for (n = 0; n < adapter->num_xdp_queues; n++) {
+		ring = adapter->xdp_ring[n];
+		ixgbe_print_buffer(ring, n);
 	}
 
 	/* Print TX Rings */
@@ -695,28 +707,28 @@ static void ixgbe_dump(struct ixgbe_adapter *adapter)
 	 */
 
 	for (n = 0; n < adapter->num_tx_queues; n++) {
-		tx_ring = adapter->tx_ring[n];
+		ring = adapter->tx_ring[n];
 		pr_info("------------------------------------\n");
-		pr_info("TX QUEUE INDEX = %d\n", tx_ring->queue_index);
+		pr_info("TX QUEUE INDEX = %d\n", ring->queue_index);
 		pr_info("------------------------------------\n");
 		pr_info("%s%s    %s              %s        %s          %s\n",
 			"T [desc]     [address 63:0  ] ",
 			"[PlPOIdStDDt Ln] [bi->dma       ] ",
 			"leng", "ntw", "timestamp", "bi->skb");
 
-		for (i = 0; tx_ring->desc && (i < tx_ring->count); i++) {
-			tx_desc = IXGBE_TX_DESC(tx_ring, i);
-			tx_buffer = &tx_ring->tx_buffer_info[i];
+		for (i = 0; ring->desc && (i < ring->count); i++) {
+			tx_desc = IXGBE_TX_DESC(ring, i);
+			tx_buffer = &ring->tx_buffer_info[i];
 			u0 = (struct my_u0 *)tx_desc;
 			if (dma_unmap_len(tx_buffer, len) > 0) {
 				const char *ring_desc;
 
-				if (i == tx_ring->next_to_use &&
-				    i == tx_ring->next_to_clean)
+				if (i == ring->next_to_use &&
+				    i == ring->next_to_clean)
 					ring_desc = " NTC/U";
-				else if (i == tx_ring->next_to_use)
+				else if (i == ring->next_to_use)
 					ring_desc = " NTU";
-				else if (i == tx_ring->next_to_clean)
+				else if (i == ring->next_to_clean)
 					ring_desc = " NTC";
 				else
 					ring_desc = "";
@@ -985,6 +997,10 @@ static void ixgbe_update_xoff_rx_lfc(struct ixgbe_adapter *adapter)
 	for (i = 0; i < adapter->num_tx_queues; i++)
 		clear_bit(__IXGBE_HANG_CHECK_ARMED,
 			  &adapter->tx_ring[i]->state);
+
+	for (i = 0; i < adapter->num_xdp_queues; i++)
+		clear_bit(__IXGBE_HANG_CHECK_ARMED,
+			  &adapter->xdp_ring[i]->state);
 }
 
 static void ixgbe_update_xoff_received(struct ixgbe_adapter *adapter)
@@ -1029,6 +1045,14 @@ static void ixgbe_update_xoff_received(struct ixgbe_adapter *adapter)
 		if (xoff[tc])
 			clear_bit(__IXGBE_HANG_CHECK_ARMED, &tx_ring->state);
 	}
+
+	for (i = 0; i < adapter->num_xdp_queues; i++) {
+		struct ixgbe_ring *xdp_ring = adapter->xdp_ring[i];
+
+		tc = xdp_ring->dcb_tc;
+		if (xoff[tc])
+			clear_bit(__IXGBE_HANG_CHECK_ARMED, &xdp_ring->state);
+	}
 }
 
 static u64 ixgbe_get_tx_completed(struct ixgbe_ring *ring)
@@ -1180,7 +1204,10 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 		total_packets += tx_buffer->gso_segs;
 
 		/* free the skb */
-		napi_consume_skb(tx_buffer->skb, napi_budget);
+		if (ring_is_xdp(tx_ring))
+			page_frag_free(tx_buffer->data);
+		else
+			napi_consume_skb(tx_buffer->skb, napi_budget);
 
 		/* unmap skb header data */
 		dma_unmap_single(tx_ring->dev,
@@ -1241,7 +1268,7 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 	if (check_for_tx_hang(tx_ring) && ixgbe_check_tx_hang(tx_ring)) {
 		/* schedule immediate reset if we believe we hung */
 		struct ixgbe_hw *hw = &adapter->hw;
-		e_err(drv, "Detected Tx Unit Hang\n"
+		e_err(drv, "Detected Tx Unit Hang %s\n"
 			"  Tx Queue             <%d>\n"
 			"  TDH, TDT             <%x>, <%x>\n"
 			"  next_to_use          <%x>\n"
@@ -1249,13 +1276,16 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 			"tx_buffer_info[next_to_clean]\n"
 			"  time_stamp           <%lx>\n"
 			"  jiffies              <%lx>\n",
+			ring_is_xdp(tx_ring) ? "(XDP)" : "",
 			tx_ring->queue_index,
 			IXGBE_READ_REG(hw, IXGBE_TDH(tx_ring->reg_idx)),
 			IXGBE_READ_REG(hw, IXGBE_TDT(tx_ring->reg_idx)),
 			tx_ring->next_to_use, i,
 			tx_ring->tx_buffer_info[i].time_stamp, jiffies);
 
-		netif_stop_subqueue(tx_ring->netdev, tx_ring->queue_index);
+		if (!ring_is_xdp(tx_ring))
+			netif_stop_subqueue(tx_ring->netdev,
+					    tx_ring->queue_index);
 
 		e_info(probe,
 		       "tx hang %d detected on queue %d, resetting adapter\n",
@@ -1268,6 +1298,9 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 		return true;
 	}
 
+	if (ring_is_xdp(tx_ring))
+		return !!budget;
+
 	netdev_tx_completed_queue(txring_txq(tx_ring),
 				  total_packets, total_bytes);
 
@@ -2170,8 +2203,13 @@ static struct sk_buff *ixgbe_build_skb(struct ixgbe_ring *rx_ring,
 
 #define IXGBE_XDP_PASS 0
 #define IXGBE_XDP_CONSUMED 1
+#define IXGBE_XDP_TX 2
 
-static struct sk_buff *ixgbe_run_xdp(struct ixgbe_ring  *rx_ring,
+static int ixgbe_xmit_xdp_ring(struct ixgbe_adapter *adapter,
+			       struct xdp_buff *xdp);
+
+static struct sk_buff *ixgbe_run_xdp(struct ixgbe_adapter *adapter,
+				     struct ixgbe_ring *rx_ring,
 				     struct xdp_buff *xdp)
 {
 	int result = IXGBE_XDP_PASS;
@@ -2188,9 +2226,11 @@ static struct sk_buff *ixgbe_run_xdp(struct ixgbe_ring  *rx_ring,
 	switch (act) {
 	case XDP_PASS:
 		break;
+	case XDP_TX:
+		result = ixgbe_xmit_xdp_ring(adapter, xdp);
+		break;
 	default:
 		bpf_warn_invalid_xdp_action(act);
-	case XDP_TX:
 	case XDP_ABORTED:
 		trace_xdp_exception(rx_ring->netdev, xdp_prog, act);
 		/* fallthrough -- handle aborts by dropping packet */
@@ -2203,6 +2243,23 @@ static struct sk_buff *ixgbe_run_xdp(struct ixgbe_ring  *rx_ring,
 	return ERR_PTR(-result);
 }
 
+static void ixgbe_rx_buffer_flip(struct ixgbe_ring *rx_ring,
+				 struct ixgbe_rx_buffer *rx_buffer,
+				 unsigned int size)
+{
+#if (PAGE_SIZE < 8192)
+	unsigned int truesize = ixgbe_rx_pg_size(rx_ring) / 2;
+
+	rx_buffer->page_offset ^= truesize;
+#else
+	unsigned int truesize = ring_uses_build_skb(rx_ring) ?
+				SKB_DATA_ALIGN(IXGBE_SKB_PAD + size) :
+				SKB_DATA_ALIGN(size);
+
+	rx_buffer->page_offset += truesize;
+#endif
+}
+
 /**
  * ixgbe_clean_rx_irq - Clean completed descriptors from Rx ring - bounce buf
  * @q_vector: structure containing interrupt and ring information
@@ -2221,8 +2278,8 @@ static int ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 			       const int budget)
 {
 	unsigned int total_rx_bytes = 0, total_rx_packets = 0;
-#ifdef IXGBE_FCOE
 	struct ixgbe_adapter *adapter = q_vector->adapter;
+#ifdef IXGBE_FCOE
 	int ddp_bytes;
 	unsigned int mss = 0;
 #endif /* IXGBE_FCOE */
@@ -2262,13 +2319,16 @@ static int ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 						ixgbe_rx_offset(rx_ring);
 			xdp.data_end = xdp.data + size;
 
-			skb = ixgbe_run_xdp(rx_ring, &xdp);
+			skb = ixgbe_run_xdp(adapter, rx_ring, &xdp);
 		}
 
 		if (IS_ERR(skb)) {
+			if (PTR_ERR(skb) == -IXGBE_XDP_TX)
+				ixgbe_rx_buffer_flip(rx_ring, rx_buffer, size);
+			else
+				rx_buffer->pagecnt_bias++;
 			total_rx_packets++;
 			total_rx_bytes += size;
-			rx_buffer->pagecnt_bias++;
 		} else if (skb) {
 			ixgbe_add_rx_frag(rx_ring, rx_buffer, skb, size);
 		} else if (ring_uses_build_skb(rx_ring)) {
@@ -3438,6 +3498,8 @@ static void ixgbe_configure_tx(struct ixgbe_adapter *adapter)
 	/* Setup the HW Tx Head and Tail descriptor pointers */
 	for (i = 0; i < adapter->num_tx_queues; i++)
 		ixgbe_configure_tx_ring(adapter, adapter->tx_ring[i]);
+	for (i = 0; i < adapter->num_xdp_queues; i++)
+		ixgbe_configure_tx_ring(adapter, adapter->xdp_ring[i]);
 }
 
 static void ixgbe_enable_rx_drop(struct ixgbe_adapter *adapter,
@@ -5579,7 +5641,10 @@ static void ixgbe_clean_tx_ring(struct ixgbe_ring *tx_ring)
 		union ixgbe_adv_tx_desc *eop_desc, *tx_desc;
 
 		/* Free all the Tx ring sk_buffs */
-		dev_kfree_skb_any(tx_buffer->skb);
+		if (ring_is_xdp(tx_ring))
+			page_frag_free(tx_buffer->data);
+		else
+			dev_kfree_skb_any(tx_buffer->skb);
 
 		/* unmap skb header data */
 		dma_unmap_single(tx_ring->dev,
@@ -5620,7 +5685,8 @@ static void ixgbe_clean_tx_ring(struct ixgbe_ring *tx_ring)
 	}
 
 	/* reset BQL for queue */
-	netdev_tx_reset_queue(txring_txq(tx_ring));
+	if (!ring_is_xdp(tx_ring))
+		netdev_tx_reset_queue(txring_txq(tx_ring));
 
 	/* reset next_to_use and next_to_clean */
 	tx_ring->next_to_use = 0;
@@ -5649,6 +5715,8 @@ static void ixgbe_clean_all_tx_rings(struct ixgbe_adapter *adapter)
 
 	for (i = 0; i < adapter->num_tx_queues; i++)
 		ixgbe_clean_tx_ring(adapter->tx_ring[i]);
+	for (i = 0; i < adapter->num_xdp_queues; i++)
+		ixgbe_clean_tx_ring(adapter->xdp_ring[i]);
 }
 
 static void ixgbe_fdir_filter_exit(struct ixgbe_adapter *adapter)
@@ -5743,6 +5811,11 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 		u8 reg_idx = adapter->tx_ring[i]->reg_idx;
 		IXGBE_WRITE_REG(hw, IXGBE_TXDCTL(reg_idx), IXGBE_TXDCTL_SWFLSH);
 	}
+	for (i = 0; i < adapter->num_xdp_queues; i++) {
+		u8 reg_idx = adapter->xdp_ring[i]->reg_idx;
+
+		IXGBE_WRITE_REG(hw, IXGBE_TXDCTL(reg_idx), IXGBE_TXDCTL_SWFLSH);
+	}
 
 	/* Disable the Tx DMA engine on 82599 and later MAC */
 	switch (hw->mac.type) {
@@ -6111,7 +6184,7 @@ int ixgbe_setup_tx_resources(struct ixgbe_ring *tx_ring)
  **/
 static int ixgbe_setup_all_tx_resources(struct ixgbe_adapter *adapter)
 {
-	int i, err = 0;
+	int i, j = 0, err = 0;
 
 	for (i = 0; i < adapter->num_tx_queues; i++) {
 		err = ixgbe_setup_tx_resources(adapter->tx_ring[i]);
@@ -6121,10 +6194,20 @@ static int ixgbe_setup_all_tx_resources(struct ixgbe_adapter *adapter)
 		e_err(probe, "Allocation for Tx Queue %u failed\n", i);
 		goto err_setup_tx;
 	}
+	for (j = 0; j < adapter->num_xdp_queues; j++) {
+		err = ixgbe_setup_tx_resources(adapter->xdp_ring[j]);
+		if (!err)
+			continue;
+
+		e_err(probe, "Allocation for Tx Queue %u failed\n", j);
+		goto err_setup_tx;
+	}
 
 	return 0;
 err_setup_tx:
 	/* rewind the index freeing the rings as we go */
+	while (j--)
+		ixgbe_free_tx_resources(adapter->xdp_ring[j]);
 	while (i--)
 		ixgbe_free_tx_resources(adapter->tx_ring[i]);
 	return err;
@@ -6255,6 +6338,9 @@ static void ixgbe_free_all_tx_resources(struct ixgbe_adapter *adapter)
 	for (i = 0; i < adapter->num_tx_queues; i++)
 		if (adapter->tx_ring[i]->desc)
 			ixgbe_free_tx_resources(adapter->tx_ring[i]);
+	for (i = 0; i < adapter->num_xdp_queues; i++)
+		if (adapter->xdp_ring[i]->desc)
+			ixgbe_free_tx_resources(adapter->xdp_ring[i]);
 }
 
 /**
@@ -6674,6 +6760,14 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 		bytes += tx_ring->stats.bytes;
 		packets += tx_ring->stats.packets;
 	}
+	for (i = 0; i < adapter->num_xdp_queues; i++) {
+		struct ixgbe_ring *xdp_ring = adapter->xdp_ring[i];
+
+		restart_queue += xdp_ring->tx_stats.restart_queue;
+		tx_busy += xdp_ring->tx_stats.tx_busy;
+		bytes += xdp_ring->stats.bytes;
+		packets += xdp_ring->stats.packets;
+	}
 	adapter->restart_queue = restart_queue;
 	adapter->tx_busy = tx_busy;
 	netdev->stats.tx_bytes = bytes;
@@ -6867,6 +6961,9 @@ static void ixgbe_fdir_reinit_subtask(struct ixgbe_adapter *adapter)
 		for (i = 0; i < adapter->num_tx_queues; i++)
 			set_bit(__IXGBE_TX_FDIR_INIT_DONE,
 				&(adapter->tx_ring[i]->state));
+		for (i = 0; i < adapter->num_xdp_queues; i++)
+			set_bit(__IXGBE_TX_FDIR_INIT_DONE,
+				&adapter->xdp_ring[i]->state);
 		/* re-enable flow director interrupts */
 		IXGBE_WRITE_REG(hw, IXGBE_EIMS, IXGBE_EIMS_FLOW_DIR);
 	} else {
@@ -6900,6 +6997,8 @@ static void ixgbe_check_hang_subtask(struct ixgbe_adapter *adapter)
 	if (netif_carrier_ok(adapter->netdev)) {
 		for (i = 0; i < adapter->num_tx_queues; i++)
 			set_check_for_tx_hang(adapter->tx_ring[i]);
+		for (i = 0; i < adapter->num_xdp_queues; i++)
+			set_check_for_tx_hang(adapter->xdp_ring[i]);
 	}
 
 	if (!(adapter->flags & IXGBE_FLAG_MSIX_ENABLED)) {
@@ -7130,6 +7229,13 @@ static bool ixgbe_ring_tx_pending(struct ixgbe_adapter *adapter)
 			return true;
 	}
 
+	for (i = 0; i < adapter->num_xdp_queues; i++) {
+		struct ixgbe_ring *ring = adapter->xdp_ring[i];
+
+		if (ring->next_to_use != ring->next_to_clean)
+			return true;
+	}
+
 	return false;
 }
 
@@ -8090,6 +8196,69 @@ static u16 ixgbe_select_queue(struct net_device *dev, struct sk_buff *skb,
 #endif
 }
 
+static int ixgbe_xmit_xdp_ring(struct ixgbe_adapter *adapter,
+			       struct xdp_buff *xdp)
+{
+	struct ixgbe_ring *ring = adapter->xdp_ring[smp_processor_id()];
+	struct ixgbe_tx_buffer *tx_buffer;
+	union ixgbe_adv_tx_desc *tx_desc;
+	u32 len, cmd_type;
+	dma_addr_t dma;
+	u16 i;
+
+	len = xdp->data_end - xdp->data;
+
+	if (unlikely(!ixgbe_desc_unused(ring)))
+		return IXGBE_XDP_CONSUMED;
+
+	dma = dma_map_single(ring->dev, xdp->data, len, DMA_TO_DEVICE);
+	if (dma_mapping_error(ring->dev, dma))
+		return IXGBE_XDP_CONSUMED;
+
+	/* record the location of the first descriptor for this packet */
+	tx_buffer = &ring->tx_buffer_info[ring->next_to_use];
+	tx_buffer->bytecount = len;
+	tx_buffer->gso_segs = 1;
+	tx_buffer->protocol = 0;
+
+	i = ring->next_to_use;
+	tx_desc = IXGBE_TX_DESC(ring, i);
+
+	dma_unmap_len_set(tx_buffer, len, len);
+	dma_unmap_addr_set(tx_buffer, dma, dma);
+	tx_buffer->data = xdp->data;
+	tx_desc->read.buffer_addr = cpu_to_le64(dma);
+
+	/* put descriptor type bits */
+	cmd_type = IXGBE_ADVTXD_DTYP_DATA |
+		   IXGBE_ADVTXD_DCMD_DEXT |
+		   IXGBE_ADVTXD_DCMD_IFCS;
+	cmd_type |= len | IXGBE_TXD_CMD;
+	tx_desc->read.cmd_type_len = cpu_to_le32(cmd_type);
+	tx_desc->read.olinfo_status =
+		cpu_to_le32(len << IXGBE_ADVTXD_PAYLEN_SHIFT);
+
+	/* Force memory writes to complete before letting h/w know there
+	 * are new descriptors to fetch.  (Only applicable for weak-ordered
+	 * memory model archs, such as IA-64).
+	 *
+	 * We also need this memory barrier to make certain all of the
+	 * status bits have been updated before next_to_watch is written.
+	 */
+	wmb();
+
+	/* set next_to_watch value indicating a packet is present */
+	i++;
+	if (i == ring->count)
+		i = 0;
+
+	tx_buffer->next_to_watch = tx_desc;
+	ring->next_to_use = i;
+
+	writel(i, ring->tail);
+	return IXGBE_XDP_TX;
+}
+
 netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
 			  struct ixgbe_adapter *adapter,
 			  struct ixgbe_ring *tx_ring)
@@ -8381,6 +8550,23 @@ static void ixgbe_netpoll(struct net_device *netdev)
 
 #endif
 
+static void ixgbe_get_ring_stats64(struct rtnl_link_stats64 *stats,
+				   struct ixgbe_ring *ring)
+{
+	u64 bytes, packets;
+	unsigned int start;
+
+	if (ring) {
+		do {
+			start = u64_stats_fetch_begin_irq(&ring->syncp);
+			packets = ring->stats.packets;
+			bytes   = ring->stats.bytes;
+		} while (u64_stats_fetch_retry_irq(&ring->syncp, start));
+		stats->tx_packets += packets;
+		stats->tx_bytes   += bytes;
+	}
+}
+
 static void ixgbe_get_stats64(struct net_device *netdev,
 			      struct rtnl_link_stats64 *stats)
 {
@@ -8406,18 +8592,13 @@ static void ixgbe_get_stats64(struct net_device *netdev,
 
 	for (i = 0; i < adapter->num_tx_queues; i++) {
 		struct ixgbe_ring *ring = ACCESS_ONCE(adapter->tx_ring[i]);
-		u64 bytes, packets;
-		unsigned int start;
 
-		if (ring) {
-			do {
-				start = u64_stats_fetch_begin_irq(&ring->syncp);
-				packets = ring->stats.packets;
-				bytes   = ring->stats.bytes;
-			} while (u64_stats_fetch_retry_irq(&ring->syncp, start));
-			stats->tx_packets += packets;
-			stats->tx_bytes   += bytes;
-		}
+		ixgbe_get_ring_stats64(stats, ring);
+	}
+	for (i = 0; i < adapter->num_xdp_queues; i++) {
+		struct ixgbe_ring *ring = ACCESS_ONCE(adapter->xdp_ring[i]);
+
+		ixgbe_get_ring_stats64(stats, ring);
 	}
 	rcu_read_unlock();
 
@@ -9559,9 +9740,23 @@ static int ixgbe_xdp_setup(struct net_device *dev, struct bpf_prog *prog)
 			return -EINVAL;
 	}
 
+	if (nr_cpu_ids > MAX_XDP_QUEUES)
+		return -ENOMEM;
+
 	old_prog = xchg(&adapter->xdp_prog, prog);
-	for (i = 0; i < adapter->num_rx_queues; i++)
-		xchg(&adapter->rx_ring[i]->xdp_prog, adapter->xdp_prog);
+
+	/* If transitioning XDP modes reconfigure rings */
+	if (!!prog != !!old_prog) {
+		int err = ixgbe_setup_tc(dev, netdev_get_num_tc(dev));
+
+		if (err) {
+			rcu_assign_pointer(adapter->xdp_prog, old_prog);
+			return -EINVAL;
+		}
+	} else {
+		for (i = 0; i < adapter->num_rx_queues; i++)
+			xchg(&adapter->rx_ring[i]->xdp_prog, adapter->xdp_prog);
+	}
 
 	if (old_prog)
 		bpf_prog_put(old_prog);
@@ -10070,6 +10265,9 @@ static int ixgbe_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	for (i = 0; i < adapter->num_tx_queues; i++)
 		u64_stats_init(&adapter->tx_ring[i]->syncp);
 
+	for (i = 0; i < adapter->num_xdp_queues; i++)
+		u64_stats_init(&adapter->xdp_ring[i]->syncp);
+
 	/* WOL not supported for all devices */
 	adapter->wol = 0;
 	hw->eeprom.ops.read(hw, 0x2c, &adapter->eeprom_cap);
