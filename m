From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/9] igb: update ring and adapter structure to improve performance
Date: Tue, 20 Sep 2011 00:11:26 -0700
Message-ID: <1316502690-25488-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1316502690-25488-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:19158 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752054Ab1ITHLf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Sep 2011 03:11:35 -0400
In-Reply-To: <1316502690-25488-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change is meant to improve performance by splitting the Tx and Rx
rings into 3 sections.  The first is primarily a read only section
containing basic things like the indexes, a pointer to the dev and netdev
structures, and basic information.  The second section contains the stats
and next_to_use and next_to_clean values.  The third section is primarily
unused values that can just be placed at the end of the ring and are not
used in the hot path.

The adapter structure has several sections that are read in the hot path.
In order to improve performance there I am combining the frequent read
hot path items into a single cache line.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by:  Aaron Brown  <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb.h      |   83 ++++++++++++++++-------------
 drivers/net/ethernet/intel/igb/igb_main.c |    4 +-
 2 files changed, 46 insertions(+), 41 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index b2f2a8c..7036fd5 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -187,26 +187,26 @@ struct igb_q_vector {
 };
 
 struct igb_ring {
-	struct igb_q_vector *q_vector; /* backlink to q_vector */
-	struct net_device *netdev;     /* back pointer to net_device */
-	struct device *dev;            /* device pointer for dma mapping */
-	dma_addr_t dma;                /* phys address of the ring */
-	void *desc;                    /* descriptor ring memory */
-	unsigned int size;             /* length of desc. ring in bytes */
-	u16 count;                     /* number of desc. in the ring */
+	struct igb_q_vector *q_vector;	/* backlink to q_vector */
+	struct net_device *netdev;	/* back pointer to net_device */
+	struct device *dev;		/* device pointer for dma mapping */
+	struct igb_buffer *buffer_info;	/* array of buffer info structs */
+	void *desc;			/* descriptor ring memory */
+	unsigned long flags;		/* ring specific flags */
+	void __iomem *tail;		/* pointer to ring tail register */
+
+	u16 count;			/* number of desc. in the ring */
+	u8 queue_index;			/* logical index of the ring*/
+	u8 reg_idx;			/* physical index of the ring */
+	u32 size;			/* length of desc. ring in bytes */
+
+	/* everything past this point are written often */
+	u16 next_to_clean ____cacheline_aligned_in_smp;
 	u16 next_to_use;
-	u16 next_to_clean;
-	u8 queue_index;
-	u8 reg_idx;
-	void __iomem *head;
-	void __iomem *tail;
-	struct igb_buffer *buffer_info; /* array of buffer info structs */
 
 	unsigned int total_bytes;
 	unsigned int total_packets;
 
-	u32 flags;
-
 	union {
 		/* TX */
 		struct {
@@ -221,6 +221,8 @@ struct igb_ring {
 			struct u64_stats_sync rx_syncp;
 		};
 	};
+	/* Items past this point are only used during ring alloc / free */
+	dma_addr_t dma;                /* phys address of the ring */
 };
 
 #define IGB_RING_FLAG_RX_CSUM        0x00000001 /* RX CSUM enabled */
@@ -248,15 +250,15 @@ static inline int igb_desc_unused(struct igb_ring *ring)
 
 /* board specific private data structure */
 struct igb_adapter {
-	struct timer_list watchdog_timer;
-	struct timer_list phy_info_timer;
 	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
-	u16 mng_vlan_id;
-	u32 bd_number;
-	u32 wol;
-	u32 en_mng_pt;
-	u16 link_speed;
-	u16 link_duplex;
+
+	struct net_device *netdev;
+
+	unsigned long state;
+	unsigned int flags;
+
+	unsigned int num_q_vectors;
+	struct msix_entry *msix_entries;
 
 	/* Interrupt Throttle Rate */
 	u32 rx_itr_setting;
@@ -264,27 +266,36 @@ struct igb_adapter {
 	u16 tx_itr;
 	u16 rx_itr;
 
-	struct work_struct reset_task;
-	struct work_struct watchdog_task;
-	bool fc_autoneg;
-	u8  tx_timeout_factor;
-	struct timer_list blink_timer;
-	unsigned long led_status;
-
 	/* TX */
-	struct igb_ring *tx_ring[16];
 	u32 tx_timeout_count;
+	int num_tx_queues;
+	struct igb_ring *tx_ring[16];
 
 	/* RX */
-	struct igb_ring *rx_ring[16];
-	int num_tx_queues;
 	int num_rx_queues;
+	struct igb_ring *rx_ring[16];
 
 	u32 max_frame_size;
 	u32 min_frame_size;
 
+	struct timer_list watchdog_timer;
+	struct timer_list phy_info_timer;
+
+	u16 mng_vlan_id;
+	u32 bd_number;
+	u32 wol;
+	u32 en_mng_pt;
+	u16 link_speed;
+	u16 link_duplex;
+
+	struct work_struct reset_task;
+	struct work_struct watchdog_task;
+	bool fc_autoneg;
+	u8  tx_timeout_factor;
+	struct timer_list blink_timer;
+	unsigned long led_status;
+
 	/* OS defined structs */
-	struct net_device *netdev;
 	struct pci_dev *pdev;
 	struct cyclecounter cycles;
 	struct timecounter clock;
@@ -306,15 +317,11 @@ struct igb_adapter {
 
 	int msg_enable;
 
-	unsigned int num_q_vectors;
 	struct igb_q_vector *q_vector[MAX_Q_VECTORS];
-	struct msix_entry *msix_entries;
 	u32 eims_enable_mask;
 	u32 eims_other;
 
 	/* to not mess up cache alignment, always add to the bottom */
-	unsigned long state;
-	unsigned int flags;
 	u32 eeprom_wol;
 
 	struct igb_ring *multi_tx_table[IGB_ABS_MAX_TX_QUEUES];
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index af8c2f7..9fa2ad0 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -2679,7 +2679,6 @@ void igb_configure_tx_ring(struct igb_adapter *adapter,
 	                tdba & 0x00000000ffffffffULL);
 	wr32(E1000_TDBAH(reg_idx), tdba >> 32);
 
-	ring->head = hw->hw_addr + E1000_TDH(reg_idx);
 	ring->tail = hw->hw_addr + E1000_TDT(reg_idx);
 	wr32(E1000_TDH(reg_idx), 0);
 	writel(0, ring->tail);
@@ -3040,7 +3039,6 @@ void igb_configure_rx_ring(struct igb_adapter *adapter,
 	               ring->count * sizeof(union e1000_adv_rx_desc));
 
 	/* initialize head and tail */
-	ring->head = hw->hw_addr + E1000_RDH(reg_idx);
 	ring->tail = hw->hw_addr + E1000_RDT(reg_idx);
 	wr32(E1000_RDH(reg_idx), 0);
 	writel(0, ring->tail);
@@ -5653,7 +5651,7 @@ static bool igb_clean_tx_irq(struct igb_q_vector *q_vector)
 				"  jiffies              <%lx>\n"
 				"  desc.status          <%x>\n",
 				tx_ring->queue_index,
-				readl(tx_ring->head),
+				rd32(E1000_TDH(tx_ring->reg_idx)),
 				readl(tx_ring->tail),
 				tx_ring->next_to_use,
 				tx_ring->next_to_clean,
-- 
1.7.6.2
