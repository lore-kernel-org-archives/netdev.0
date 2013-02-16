From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/15] ixgbe: Add function for setting XPS queue mapping
Date: Sat, 16 Feb 2013 00:33:27 -0800
Message-ID: <1361003616-3422-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1361003616-3422-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:2804 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752477Ab3BPIdr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Feb 2013 03:33:47 -0500
In-Reply-To: <1361003616-3422-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change adds support for ixgbe to configure the XPS queue mapping on
load.  The result of this change is that on open we will now be resetting
the number of Tx queues, and then setting the default configuration for XPS
based on if ATR is enabled or disabled.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Reviewed-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c  | 14 +++++++++-----
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 10 ++++++++++
 3 files changed, 20 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 4a2831c..5213563 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -201,6 +201,7 @@ struct ixgbe_rx_queue_stats {
 
 enum ixgbe_ring_state_t {
 	__IXGBE_TX_FDIR_INIT_DONE,
+	__IXGBE_TX_XPS_INIT_DONE,
 	__IXGBE_TX_DETECT_HANG,
 	__IXGBE_HANG_CHECK_ARMED,
 	__IXGBE_RX_RSC_ENABLED,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
index 9fafa38..ef5f7a6 100644
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
index 5fd1667..16c9858 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2813,6 +2813,16 @@ void ixgbe_configure_tx_ring(struct ixgbe_adapter *adapter,
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
-- 
1.7.11.7
