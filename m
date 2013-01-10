From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [RFC PATCH v2 07/10] ixgbe: Add function for setting XPS queue
 mapping
Date: Thu, 10 Jan 2013 10:58:12 -0800
Message-ID: <20130110185804.29578.30267.stgit@ahduyck-cp1.jf.intel.com>
References: <20130110184115.29578.85768.stgit@ahduyck-cp1.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, therbert@google.com, ycai@google.com,
	eric.dumazet@gmail.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:3130 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753961Ab3AJS7u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2013 13:59:50 -0500
In-Reply-To: <20130110184115.29578.85768.stgit@ahduyck-cp1.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change adds support for ixgbe to configure the XPS queue mapping on
load.  The result of this change is that on open we will now be resetting
the number of Tx queues, and then setting the default configuration for XPS
based on if ATR is enabled or disabled.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |    1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c  |   14 +++++++++-----
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   10 ++++++++++
 3 files changed, 20 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 8e78676..590f042 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -195,6 +195,7 @@ struct ixgbe_rx_queue_stats {
 
 enum ixgbe_ring_state_t {
 	__IXGBE_TX_FDIR_INIT_DONE,
+	__IXGBE_TX_XPS_INIT_DONE,
 	__IXGBE_TX_DETECT_HANG,
 	__IXGBE_HANG_CHECK_ARMED,
 	__IXGBE_RX_RSC_ENABLED,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
index 4b1eeb6..ab01662 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
@@ -771,19 +771,23 @@ static int ixgbe_alloc_q_vector(struct ixgbe_adapter *adapter,
 {
 	struct ixgbe_q_vector *q_vector;
 	struct ixgbe_ring *ring;
-	int node = -1;
+	int node = NUMA_NO_NODE;
 	int cpu = -1;
 	int ring_count, size;
+	u8 tcs = netdev_get_num_tc(adapter->netdev);
 
 	ring_count = txr_count + rxr_count;
 	size = sizeof(struct ixgbe_q_vector) +
 	       (sizeof(struct ixgbe_ring) * ring_count);
 
 	/* customize cpu for Flow Director mapping */
-	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE) {
-		if (cpu_online(v_idx)) {
-			cpu = v_idx;
-			node = cpu_to_node(cpu);
+	if ((tcs <= 1) && !(adapter->flags & IXGBE_FLAG_SRIOV_ENABLED)) {
+		u16 rss_i = adapter->ring_feature[RING_F_RSS].indices;
+		if (rss_i > 1 && adapter->atr_sample_rate) {
+			if (cpu_online(v_idx)) {
+				cpu = v_idx;
+				node = cpu_to_node(cpu);
+			}
 		}
 	}
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 810f2b8..8ca9794 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2814,6 +2814,16 @@ void ixgbe_configure_tx_ring(struct ixgbe_adapter *adapter,
 		ring->atr_sample_rate = 0;
 	}
 
+	/* initialize XPS */
+	if (!test_and_set_bit(__IXGBE_TX_XPS_INIT_DONE, &ring->state)) {
+		struct ixgbe_q_vector *q_vector = ring->q_vector;
+
+		if (q_vector)
+			netif_set_xps_queue(adapter->netdev,
+					    &q_vector->affinity_mask,
+					    ring->queue_index);
+	}
+
 	clear_bit(__IXGBE_HANG_CHECK_ARMED, &ring->state);
 
 	/* enable queue */
