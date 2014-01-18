From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 3/7] ixgbevf: remove counters for Tx/Rx checksum offload
Date: Fri, 17 Jan 2014 18:30:01 -0800
Message-ID: <1390012205-21995-4-git-send-email-aaron.f.brown@intel.com>
References: <1390012205-21995-1-git-send-email-aaron.f.brown@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:24162 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753229AbaARCaN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jan 2014 21:30:13 -0500
In-Reply-To: <1390012205-21995-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch removes the Tx/Rx counters for checksum offload.

The Tx counter was never updated and the Rx counter is of limited use.
This is in effort to clean up the counters and make them consistent
with the counters shown by ixgbe.

Also this patch removes some members of the adapter structure that were
never used and shuffles others to reduce number of holes.

before:
	/* size: 1568, cachelines: 25, members: 48 */
	/* sum members: 1519, holes: 10, sum holes: 43 */
	/* padding: 6 */
	/* last cacheline: 32 bytes */

after:
	/* size: 1480, cachelines: 24, members: 43 */
	/* sum members: 1479, holes: 1, sum holes: 1 */
	/* last cacheline: 8 bytes */

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ethtool.c      |  2 --
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      | 23 +++++++++--------------
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  4 ----
 3 files changed, 9 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ethtool.c b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
index 0769306..b48df78 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
@@ -79,9 +79,7 @@ static const struct ixgbe_stats ixgbe_gstrings_stats[] = {
 	{"tx_busy", IXGBEVF_ZSTAT(tx_busy)},
 	{"multicast", IXGBEVF_STAT(stats.vfmprc, stats.base_vfmprc,
 				   stats.saved_reset_vfmprc)},
-	{"rx_csum_offload_good", IXGBEVF_ZSTAT(hw_csum_rx_good)},
 	{"rx_csum_offload_errors", IXGBEVF_ZSTAT(hw_csum_rx_error)},
-	{"tx_csum_offload_ctxt", IXGBEVF_ZSTAT(hw_csum_tx_good)},
 #ifdef BP_EXTENDED_STATS
 	{"rx_bp_poll_yield", IXGBEVF_ZSTAT(bp_rx_yields)},
 	{"rx_bp_cleaned", IXGBEVF_ZSTAT(bp_rx_cleaned)},
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index 0642bd2..0068428 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -106,7 +106,6 @@ struct ixgbevf_ring {
 	};
 
 	u64 hw_csum_rx_error;
-	u64 hw_csum_rx_good;
 	u8 __iomem *tail;
 
 	u16 reg_idx; /* holds the special value that gets the hardware register
@@ -336,7 +335,6 @@ static inline u16 ixgbevf_desc_unused(struct ixgbevf_ring *ring)
 struct ixgbevf_adapter {
 	struct timer_list watchdog_timer;
 	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
-	u16 bd_number;
 	struct work_struct reset_task;
 	struct ixgbevf_q_vector *q_vector[MAX_MSIX_Q_VECTORS];
 
@@ -349,25 +347,18 @@ struct ixgbevf_adapter {
 	u32 eims_other;
 
 	/* TX */
-	struct ixgbevf_ring *tx_ring[MAX_TX_QUEUES]; /* One per active queue */
 	int num_tx_queues;
+	struct ixgbevf_ring *tx_ring[MAX_TX_QUEUES]; /* One per active queue */
 	u64 restart_queue;
-	u64 hw_csum_tx_good;
-	u64 lsc_int;
-	u64 hw_tso_ctxt;
-	u64 hw_tso6_ctxt;
 	u32 tx_timeout_count;
 
 	/* RX */
-	struct ixgbevf_ring *rx_ring[MAX_TX_QUEUES]; /* One per active queue */
 	int num_rx_queues;
+	struct ixgbevf_ring *rx_ring[MAX_TX_QUEUES]; /* One per active queue */
 	u64 hw_csum_rx_error;
 	u64 hw_rx_no_dma_resources;
-	u64 hw_csum_rx_good;
 	u64 non_eop_descs;
 	int num_msix_vectors;
-	struct msix_entry *msix_entries;
-
 	u32 alloc_rx_page_failed;
 	u32 alloc_rx_buff_failed;
 
@@ -379,6 +370,8 @@ struct ixgbevf_adapter {
 #define IXGBE_FLAG_IN_NETPOLL                   (u32)(1 << 1)
 #define IXGBEVF_FLAG_QUEUE_RESET_REQUESTED	(u32)(1 << 2)
 
+	struct msix_entry *msix_entries;
+
 	/* OS defined structs */
 	struct net_device *netdev;
 	struct pci_dev *pdev;
@@ -386,10 +379,12 @@ struct ixgbevf_adapter {
 	/* structs defined in ixgbe_vf.h */
 	struct ixgbe_hw hw;
 	u16 msg_enable;
-	struct ixgbevf_hw_stats stats;
+	u16 bd_number;
 	/* Interrupt Throttle Rate */
 	u32 eitr_param;
 
+	struct ixgbevf_hw_stats stats;
+
 	unsigned long state;
 	u64 tx_busy;
 	unsigned int tx_ring_count;
@@ -408,9 +403,9 @@ struct ixgbevf_adapter {
 	u32 link_speed;
 	bool link_up;
 
-	struct work_struct watchdog_task;
-
 	spinlock_t mbx_lock;
+
+	struct work_struct watchdog_task;
 };
 
 enum ixbgevf_state_t {
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 77ddda6..41b72ed 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -357,7 +357,6 @@ static inline void ixgbevf_rx_checksum(struct ixgbevf_ring *ring,
 
 	/* It must be a TCP or UDP packet with a valid checksum */
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
-	ring->hw_csum_rx_good++;
 }
 
 /**
@@ -2263,10 +2262,7 @@ void ixgbevf_update_stats(struct ixgbevf_adapter *adapter)
 	for (i = 0;  i  < adapter->num_rx_queues;  i++) {
 		adapter->hw_csum_rx_error +=
 			adapter->rx_ring[i]->hw_csum_rx_error;
-		adapter->hw_csum_rx_good +=
-			adapter->rx_ring[i]->hw_csum_rx_good;
 		adapter->rx_ring[i]->hw_csum_rx_error = 0;
-		adapter->rx_ring[i]->hw_csum_rx_good = 0;
 	}
 }
 
-- 
1.8.5.GIT
