From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/14] ixgbe: Reorder adapter contents for better cache utilization
Date: Mon, 12 Mar 2012 21:03:45 -0700
Message-ID: <1331611432-30109-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1331611432-30109-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:11875 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751707Ab2CMEED (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Mar 2012 00:04:03 -0400
In-Reply-To: <1331611432-30109-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change moves several frequently accessed items together into one cache
line in order to reduce cache misses in the hot-path.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h |   94 +++++++++++++++---------------
 1 files changed, 48 insertions(+), 46 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index f05bfdb..c5cd2b6 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -373,8 +373,16 @@ static inline u16 ixgbe_desc_unused(struct ixgbe_ring *ring)
 #define MIN_MSIX_Q_VECTORS 2
 #define MIN_MSIX_COUNT (MIN_MSIX_Q_VECTORS + NON_Q_VECTORS)
 
+/* default to trying for four seconds */
+#define IXGBE_TRY_LINK_TIMEOUT (4 * HZ)
+
 /* board specific private data structure */
 struct ixgbe_adapter {
+	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
+	/* OS defined structs */
+	struct net_device *netdev;
+	struct pci_dev *pdev;
+
 	unsigned long state;
 
 	/* Some features need tri-state capability,
@@ -418,59 +426,50 @@ struct ixgbe_adapter {
 #define IXGBE_FLAG2_RESET_REQUESTED             (u32)(1 << 6)
 #define IXGBE_FLAG2_FDIR_REQUIRES_REINIT        (u32)(1 << 7)
 
-	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
-	u16 bd_number;
-	struct ixgbe_q_vector *q_vector[MAX_MSIX_Q_VECTORS];
 
-	/* DCB parameters */
-	struct ieee_pfc *ixgbe_ieee_pfc;
-	struct ieee_ets *ixgbe_ieee_ets;
-	struct ixgbe_dcb_config dcb_cfg;
-	struct ixgbe_dcb_config temp_dcb_cfg;
-	u8 dcb_set_bitmap;
-	u8 dcbx_cap;
-	enum ixgbe_fc_mode last_lfc_mode;
-
-	/* Interrupt Throttle Rate */
-	u32 rx_itr_setting;
-	u32 tx_itr_setting;
-	u16 eitr_low;
-	u16 eitr_high;
-
-	/* Work limits */
+	/* Tx fast path data */
+	int num_tx_queues;
+	u16 tx_itr_setting;
 	u16 tx_work_limit;
 
+	/* Rx fast path data */
+	int num_rx_queues;
+	u16 rx_itr_setting;
+
 	/* TX */
 	struct ixgbe_ring *tx_ring[MAX_TX_QUEUES] ____cacheline_aligned_in_smp;
-	int num_tx_queues;
-	u32 tx_timeout_count;
-	bool detect_tx_hung;
 
 	u64 restart_queue;
 	u64 lsc_int;
+	u32 tx_timeout_count;
 
 	/* RX */
-	struct ixgbe_ring *rx_ring[MAX_RX_QUEUES] ____cacheline_aligned_in_smp;
-	int num_rx_queues;
+	struct ixgbe_ring *rx_ring[MAX_RX_QUEUES];
 	int num_rx_pools;		/* == num_rx_queues in 82598 */
 	int num_rx_queues_per_pool;	/* 1 if 82598, can be many if 82599 */
 	u64 hw_csum_rx_error;
 	u64 hw_rx_no_dma_resources;
+	u64 rsc_total_count;
+	u64 rsc_total_flush;
 	u64 non_eop_descs;
-	int num_msix_vectors;
-	int max_msix_q_vectors;         /* true count of q_vectors for device */
-	struct ixgbe_ring_feature ring_feature[RING_F_ARRAY_SIZE];
-	struct msix_entry *msix_entries;
-
 	u32 alloc_rx_page_failed;
 	u32 alloc_rx_buff_failed;
 
-/* default to trying for four seconds */
-#define IXGBE_TRY_LINK_TIMEOUT (4 * HZ)
+	struct ixgbe_q_vector *q_vector[MAX_MSIX_Q_VECTORS];
 
-	/* OS defined structs */
-	struct net_device *netdev;
-	struct pci_dev *pdev;
+	/* DCB parameters */
+	struct ieee_pfc *ixgbe_ieee_pfc;
+	struct ieee_ets *ixgbe_ieee_ets;
+	struct ixgbe_dcb_config dcb_cfg;
+	struct ixgbe_dcb_config temp_dcb_cfg;
+	u8 dcb_set_bitmap;
+	u8 dcbx_cap;
+	enum ixgbe_fc_mode last_lfc_mode;
+
+	int num_msix_vectors;
+	int max_msix_q_vectors;         /* true count of q_vectors for device */
+	struct ixgbe_ring_feature ring_feature[RING_F_ARRAY_SIZE];
+	struct msix_entry *msix_entries;
 
 	u32 test_icr;
 	struct ixgbe_ring test_tx_ring;
@@ -481,10 +480,6 @@ struct ixgbe_adapter {
 	u16 msg_enable;
 	struct ixgbe_hw_stats stats;
 
-	/* Interrupt Throttle Rate */
-	u32 rx_eitr_param;
-	u32 tx_eitr_param;
-
 	u64 tx_busy;
 	unsigned int tx_ring_count;
 	unsigned int rx_ring_count;
@@ -493,25 +488,35 @@ struct ixgbe_adapter {
 	bool link_up;
 	unsigned long link_check_timeout;
 
-	struct work_struct service_task;
 	struct timer_list service_timer;
+	struct work_struct service_task;
+
+	struct hlist_head fdir_filter_list;
+	unsigned long fdir_overflow; /* number of times ATR was backed off */
+	union ixgbe_atr_input fdir_mask;
+	int fdir_filter_count;
 	u32 fdir_pballoc;
 	u32 atr_sample_rate;
-	unsigned long fdir_overflow; /* number of times ATR was backed off */
 	spinlock_t fdir_perfect_lock;
+
 #ifdef IXGBE_FCOE
 	struct ixgbe_fcoe fcoe;
 #endif /* IXGBE_FCOE */
-	u64 rsc_total_count;
-	u64 rsc_total_flush;
 	u32 wol;
+
+	/* Interrupt Throttle Rate */
+	u16 eitr_low;
+	u16 eitr_high;
+
+	u16 bd_number;
+
 	u16 eeprom_verh;
 	u16 eeprom_verl;
 	u16 eeprom_cap;
 
 	int node;
-	u32 led_reg;
 	u32 interrupt_event;
+	u32 led_reg;
 
 	/* SR-IOV */
 	DECLARE_BITMAP(active_vfs, IXGBE_MAX_VF_FUNCTIONS);
@@ -521,9 +526,6 @@ struct ixgbe_adapter {
 	struct vf_macvlans vf_mvs;
 	struct vf_macvlans *mv_list;
 
-	struct hlist_head fdir_filter_list;
-	union ixgbe_atr_input fdir_mask;
-	int fdir_filter_count;
 	u32 timer_event_accumulator;
 	u32 vferr_refcount;
 };
-- 
1.7.7.6
