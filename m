From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 3/3] ixgbe: Add 82599 device id's,
	hook it up into the main driver.
Date: Fri, 27 Feb 2009 17:45:05 -0800
Message-ID: <20090228014505.22664.59888.stgit@lost.foo-projects.org>
References: <20090228013916.22664.54781.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.emeryville.ca.mail.comcast.net ([76.96.30.24]:53797 "EHLO
	QMTA02.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754638AbZB1BpZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 20:45:25 -0500
In-Reply-To: <20090228013916.22664.54781.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>

With the hardware-specific code in place, add all supported device id's,
along with base driver changes to enable 82599 devices.  The devices
being enabled are:

8086:10f7: 82599EB 10 Gigabit KX4 Network Connection
8086:10fb: 82599EB 10 Gigabit Network Connection

The device 8086:10fb is a fully-pluggable SFP+ NIC.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/Makefile        |    5 
 drivers/net/ixgbe/ixgbe.h         |   29 +-
 drivers/net/ixgbe/ixgbe_ethtool.c |    1 
 drivers/net/ixgbe/ixgbe_main.c    |  659 ++++++++++++++++++++++++++++++-------
 4 files changed, 559 insertions(+), 135 deletions(-)

diff --git a/drivers/net/ixgbe/Makefile b/drivers/net/ixgbe/Makefile
index f606195..b3f8208 100644
--- a/drivers/net/ixgbe/Makefile
+++ b/drivers/net/ixgbe/Makefile
@@ -33,6 +33,7 @@
 obj-$(CONFIG_IXGBE) += ixgbe.o
 
 ixgbe-objs := ixgbe_main.o ixgbe_common.o ixgbe_ethtool.o \
-              ixgbe_82598.o ixgbe_phy.o
+              ixgbe_82599.o ixgbe_82598.o ixgbe_phy.o
 
-ixgbe-$(CONFIG_IXGBE_DCB) +=  ixgbe_dcb.o ixgbe_dcb_82598.o ixgbe_dcb_nl.o
+ixgbe-$(CONFIG_IXGBE_DCB) +=  ixgbe_dcb.o ixgbe_dcb_82598.o \
+                              ixgbe_dcb_82599.o ixgbe_dcb_nl.o
diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 2d877da..0b54717 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -140,9 +140,9 @@ struct ixgbe_ring {
 	int cpu;
 #endif
 	struct ixgbe_queue_stats stats;
-	u16 v_idx; /* maps directly to the index for this ring in the hardware
-	           * vector array, can also be used for finding the bit in EICR
-	           * and friends that represents the vector for this ring */
+	u64 v_idx; /* maps directly to the index for this ring in the hardware
+	            * vector array, can also be used for finding the bit in EICR
+	            * and friends that represents the vector for this ring */
 
 
 	u16 work_limit;                /* max work per interrupt */
@@ -166,8 +166,8 @@ struct ixgbe_ring_feature {
 	int mask;
 };
 
-#define MAX_RX_QUEUES 64
-#define MAX_TX_QUEUES 32
+#define MAX_RX_QUEUES 128
+#define MAX_TX_QUEUES 128
 
 #define MAX_RX_PACKET_BUFFERS ((adapter->flags & IXGBE_FLAG_DCB_ENABLED) \
                               ? 8 : 1)
@@ -211,11 +211,13 @@ struct ixgbe_q_vector {
 #define OTHER_VECTOR 1
 #define NON_Q_VECTORS (OTHER_VECTOR)
 
+#define MAX_MSIX_VECTORS_82599 64
+#define MAX_MSIX_Q_VECTORS_82599 64
 #define MAX_MSIX_VECTORS_82598 18
 #define MAX_MSIX_Q_VECTORS_82598 16
 
-#define MAX_MSIX_Q_VECTORS MAX_MSIX_Q_VECTORS_82598
-#define MAX_MSIX_COUNT MAX_MSIX_VECTORS_82598
+#define MAX_MSIX_Q_VECTORS MAX_MSIX_Q_VECTORS_82599
+#define MAX_MSIX_COUNT MAX_MSIX_VECTORS_82599
 
 #define MIN_MSIX_Q_VECTORS 2
 #define MIN_MSIX_COUNT (MIN_MSIX_Q_VECTORS + NON_Q_VECTORS)
@@ -227,7 +229,7 @@ struct ixgbe_adapter {
 	u16 bd_number;
 	struct work_struct reset_task;
 	struct ixgbe_q_vector q_vector[MAX_MSIX_Q_VECTORS];
-	char name[MAX_MSIX_COUNT][IFNAMSIZ + 5];
+	char name[MAX_MSIX_COUNT][IFNAMSIZ + 9];
 	struct ixgbe_dcb_config dcb_cfg;
 	struct ixgbe_dcb_config temp_dcb_cfg;
 	u8 dcb_set_bitmap;
@@ -252,6 +254,7 @@ struct ixgbe_adapter {
 	struct ixgbe_ring *rx_ring;	/* One per active queue */
 	int num_rx_queues;
 	u64 hw_csum_rx_error;
+	u64 hw_rx_no_dma_resources;
 	u64 hw_csum_rx_good;
 	u64 non_eop_descs;
 	int num_msix_vectors;
@@ -280,6 +283,7 @@ struct ixgbe_adapter {
 #define IXGBE_FLAG_DCA_CAPABLE                  (u32)(1 << 11)
 #define IXGBE_FLAG_IMIR_ENABLED                 (u32)(1 << 12)
 #define IXGBE_FLAG_MQ_CAPABLE                   (u32)(1 << 13)
+#define IXGBE_FLAG_DCB_ENABLED                  (u32)(1 << 14)
 #define IXGBE_FLAG_RSS_ENABLED                  (u32)(1 << 16)
 #define IXGBE_FLAG_RSS_CAPABLE                  (u32)(1 << 17)
 #define IXGBE_FLAG_VMDQ_CAPABLE                 (u32)(1 << 18)
@@ -287,7 +291,8 @@ struct ixgbe_adapter {
 #define IXGBE_FLAG_FAN_FAIL_CAPABLE             (u32)(1 << 20)
 #define IXGBE_FLAG_NEED_LINK_UPDATE             (u32)(1 << 22)
 #define IXGBE_FLAG_IN_WATCHDOG_TASK             (u32)(1 << 23)
-#define IXGBE_FLAG_DCB_ENABLED                  (u32)(1 << 24)
+#define IXGBE_FLAG_IN_SFP_LINK_TASK             (u32)(1 << 24)
+#define IXGBE_FLAG_IN_SFP_MOD_TASK              (u32)(1 << 25)
 
 /* default to trying for four seconds */
 #define IXGBE_TRY_LINK_TIMEOUT (4 * HZ)
@@ -317,7 +322,9 @@ struct ixgbe_adapter {
 	struct work_struct watchdog_task;
 	struct work_struct sfp_task;
 	struct timer_list sfp_timer;
-
+	struct work_struct multispeed_fiber_task;
+	struct work_struct sfp_config_module_task;
+	u32 wol;
 	u16 eeprom_version;
 };
 
@@ -330,9 +337,11 @@ enum ixbge_state_t {
 
 enum ixgbe_boards {
 	board_82598,
+	board_82599,
 };
 
 extern struct ixgbe_info ixgbe_82598_info;
+extern struct ixgbe_info ixgbe_82599_info;
 #ifdef CONFIG_IXGBE_DCB
 extern struct dcbnl_rtnl_ops dcbnl_ops;
 extern int ixgbe_copy_dcb_cfg(struct ixgbe_dcb_config *src_dcb_cfg,
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 35d820e..ae38bca 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -89,6 +89,7 @@ static struct ixgbe_stats ixgbe_gstrings_stats[] = {
 	{"rx_header_split", IXGBE_STAT(rx_hdr_split)},
 	{"alloc_rx_page_failed", IXGBE_STAT(alloc_rx_page_failed)},
 	{"alloc_rx_buff_failed", IXGBE_STAT(alloc_rx_buff_failed)},
+	{"rx_no_dma_resources", IXGBE_STAT(hw_rx_no_dma_resources)},
 };
 
 #define IXGBE_QUEUE_STATS_LEN \
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 6564235..d0b9870 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -47,12 +47,13 @@ char ixgbe_driver_name[] = "ixgbe";
 static const char ixgbe_driver_string[] =
                               "Intel(R) 10 Gigabit PCI Express Network Driver";
 
-#define DRV_VERSION "1.3.56-k2"
+#define DRV_VERSION "2.0.8-k2"
 const char ixgbe_driver_version[] = DRV_VERSION;
 static char ixgbe_copyright[] = "Copyright (c) 1999-2009 Intel Corporation.";
 
 static const struct ixgbe_info *ixgbe_info_tbl[] = {
 	[board_82598] = &ixgbe_82598_info,
+	[board_82599] = &ixgbe_82599_info,
 };
 
 /* ixgbe_pci_tbl - PCI Device ID Table
@@ -86,6 +87,10 @@ static struct pci_device_id ixgbe_pci_tbl[] = {
 	 board_82598 },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598_BX),
 	 board_82598 },
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_KX4),
+	 board_82599 },
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_SFP),
+	 board_82599 },
 
 	/* required last entry */
 	{0, }
@@ -129,17 +134,53 @@ static void ixgbe_get_hw_control(struct ixgbe_adapter *adapter)
 	                ctrl_ext | IXGBE_CTRL_EXT_DRV_LOAD);
 }
 
-static void ixgbe_set_ivar(struct ixgbe_adapter *adapter, u16 int_alloc_entry,
-                           u8 msix_vector)
+/*
+ * ixgbe_set_ivar - set the IVAR registers, mapping interrupt causes to vectors
+ * @adapter: pointer to adapter struct
+ * @direction: 0 for Rx, 1 for Tx, -1 for other causes
+ * @queue: queue to map the corresponding interrupt to
+ * @msix_vector: the vector to map to the corresponding queue
+ *
+ */
+static void ixgbe_set_ivar(struct ixgbe_adapter *adapter, s8 direction,
+	                   u8 queue, u8 msix_vector)
 {
 	u32 ivar, index;
-
-	msix_vector |= IXGBE_IVAR_ALLOC_VAL;
-	index = (int_alloc_entry >> 2) & 0x1F;
-	ivar = IXGBE_READ_REG(&adapter->hw, IXGBE_IVAR(index));
-	ivar &= ~(0xFF << (8 * (int_alloc_entry & 0x3)));
-	ivar |= (msix_vector << (8 * (int_alloc_entry & 0x3)));
-	IXGBE_WRITE_REG(&adapter->hw, IXGBE_IVAR(index), ivar);
+	struct ixgbe_hw *hw = &adapter->hw;
+	switch (hw->mac.type) {
+	case ixgbe_mac_82598EB:
+		msix_vector |= IXGBE_IVAR_ALLOC_VAL;
+		if (direction == -1)
+			direction = 0;
+		index = (((direction * 64) + queue) >> 2) & 0x1F;
+		ivar = IXGBE_READ_REG(hw, IXGBE_IVAR(index));
+		ivar &= ~(0xFF << (8 * (queue & 0x3)));
+		ivar |= (msix_vector << (8 * (queue & 0x3)));
+		IXGBE_WRITE_REG(hw, IXGBE_IVAR(index), ivar);
+		break;
+	case ixgbe_mac_82599EB:
+		if (direction == -1) {
+			/* other causes */
+			msix_vector |= IXGBE_IVAR_ALLOC_VAL;
+			index = ((queue & 1) * 8);
+			ivar = IXGBE_READ_REG(&adapter->hw, IXGBE_IVAR_MISC);
+			ivar &= ~(0xFF << index);
+			ivar |= (msix_vector << index);
+			IXGBE_WRITE_REG(&adapter->hw, IXGBE_IVAR_MISC, ivar);
+			break;
+		} else {
+			/* tx or rx causes */
+			msix_vector |= IXGBE_IVAR_ALLOC_VAL;
+			index = ((16 * (queue & 1)) + (8 * direction));
+			ivar = IXGBE_READ_REG(hw, IXGBE_IVAR(queue >> 1));
+			ivar &= ~(0xFF << index);
+			ivar |= (msix_vector << index);
+			IXGBE_WRITE_REG(hw, IXGBE_IVAR(queue >> 1), ivar);
+			break;
+		}
+	default:
+		break;
+	}
 }
 
 static void ixgbe_unmap_and_free_tx_resource(struct ixgbe_adapter *adapter,
@@ -310,13 +351,19 @@ static void ixgbe_update_rx_dca(struct ixgbe_adapter *adapter,
 
 	if (rx_ring->cpu != cpu) {
 		rxctrl = IXGBE_READ_REG(&adapter->hw, IXGBE_DCA_RXCTRL(q));
-		rxctrl &= ~IXGBE_DCA_RXCTRL_CPUID_MASK;
-		rxctrl |= dca3_get_tag(&adapter->pdev->dev, cpu);
+		if (adapter->hw.mac.type == ixgbe_mac_82598EB) {
+			rxctrl &= ~IXGBE_DCA_RXCTRL_CPUID_MASK;
+			rxctrl |= dca3_get_tag(&adapter->pdev->dev, cpu);
+		} else if (adapter->hw.mac.type == ixgbe_mac_82599EB) {
+			rxctrl &= ~IXGBE_DCA_RXCTRL_CPUID_MASK_82599;
+			rxctrl |= (dca3_get_tag(&adapter->pdev->dev, cpu) <<
+			           IXGBE_DCA_RXCTRL_CPUID_SHIFT_82599);
+		}
 		rxctrl |= IXGBE_DCA_RXCTRL_DESC_DCA_EN;
 		rxctrl |= IXGBE_DCA_RXCTRL_HEAD_DCA_EN;
 		rxctrl &= ~(IXGBE_DCA_RXCTRL_DESC_RRO_EN);
 		rxctrl &= ~(IXGBE_DCA_RXCTRL_DESC_WRO_EN |
-			    IXGBE_DCA_RXCTRL_DESC_HSRO_EN);
+		            IXGBE_DCA_RXCTRL_DESC_HSRO_EN);
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_DCA_RXCTRL(q), rxctrl);
 		rx_ring->cpu = cpu;
 	}
@@ -332,8 +379,14 @@ static void ixgbe_update_tx_dca(struct ixgbe_adapter *adapter,
 
 	if (tx_ring->cpu != cpu) {
 		txctrl = IXGBE_READ_REG(&adapter->hw, IXGBE_DCA_TXCTRL(q));
-		txctrl &= ~IXGBE_DCA_TXCTRL_CPUID_MASK;
-		txctrl |= dca3_get_tag(&adapter->pdev->dev, cpu);
+		if (adapter->hw.mac.type == ixgbe_mac_82598EB) {
+			txctrl &= ~IXGBE_DCA_TXCTRL_CPUID_MASK;
+			txctrl |= dca3_get_tag(&adapter->pdev->dev, cpu);
+		} else if (adapter->hw.mac.type == ixgbe_mac_82599EB) {
+			txctrl &= ~IXGBE_DCA_TXCTRL_CPUID_MASK_82599;
+			txctrl |= (dca3_get_tag(&adapter->pdev->dev, cpu) <<
+			           IXGBE_DCA_TXCTRL_CPUID_SHIFT_82599);
+		}
 		txctrl |= IXGBE_DCA_TXCTRL_DESC_DCA_EN;
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_DCA_TXCTRL(q), txctrl);
 		tx_ring->cpu = cpu;
@@ -464,6 +517,19 @@ static inline void ixgbe_rx_checksum(struct ixgbe_adapter *adapter,
 	adapter->hw_csum_rx_good++;
 }
 
+static inline void ixgbe_release_rx_desc(struct ixgbe_hw *hw,
+                                         struct ixgbe_ring *rx_ring, u32 val)
+{
+	/*
+	 * Force memory writes to complete before letting h/w
+	 * know there are new descriptors to fetch.  (Only
+	 * applicable for weak-ordered memory model archs,
+	 * such as IA-64).
+	 */
+	wmb();
+	IXGBE_WRITE_REG(hw, IXGBE_RDT(rx_ring->reg_idx), val);
+}
+
 /**
  * ixgbe_alloc_rx_buffers - Replace used receive buffers; packet split
  * @adapter: address of board private structure
@@ -476,6 +542,7 @@ static void ixgbe_alloc_rx_buffers(struct ixgbe_adapter *adapter,
 	union ixgbe_adv_rx_desc *rx_desc;
 	struct ixgbe_rx_buffer *bi;
 	unsigned int i;
+	unsigned int bufsz = rx_ring->rx_buf_len + NET_IP_ALIGN;
 
 	i = rx_ring->next_to_use;
 	bi = &rx_ring->rx_buffer_info[i];
@@ -505,9 +572,7 @@ static void ixgbe_alloc_rx_buffers(struct ixgbe_adapter *adapter,
 
 		if (!bi->skb) {
 			struct sk_buff *skb;
-			skb = netdev_alloc_skb(adapter->netdev,
-			                       (rx_ring->rx_buf_len +
-			                        NET_IP_ALIGN));
+			skb = netdev_alloc_skb(adapter->netdev, bufsz);
 
 			if (!skb) {
 				adapter->alloc_rx_buff_failed++;
@@ -522,8 +587,7 @@ static void ixgbe_alloc_rx_buffers(struct ixgbe_adapter *adapter,
 			skb_reserve(skb, NET_IP_ALIGN);
 
 			bi->skb = skb;
-			bi->dma = pci_map_single(pdev, skb->data,
-			                         rx_ring->rx_buf_len,
+			bi->dma = pci_map_single(pdev, skb->data, bufsz,
 			                         PCI_DMA_FROMDEVICE);
 		}
 		/* Refresh the desc even if buffer_addrs didn't change because
@@ -547,14 +611,7 @@ no_buffers:
 		if (i-- == 0)
 			i = (rx_ring->count - 1);
 
-		/*
-		 * Force memory writes to complete before letting h/w
-		 * know there are new descriptors to fetch.  (Only
-		 * applicable for weak-ordered memory model archs,
-		 * such as IA-64).
-		 */
-		wmb();
-		writel(i, adapter->hw.hw_addr + rx_ring->tail);
+		ixgbe_release_rx_desc(&adapter->hw, rx_ring, i);
 	}
 }
 
@@ -732,7 +789,7 @@ static void ixgbe_configure_msix(struct ixgbe_adapter *adapter)
 
 		for (i = 0; i < q_vector->rxr_count; i++) {
 			j = adapter->rx_ring[r_idx].reg_idx;
-			ixgbe_set_ivar(adapter, IXGBE_IVAR_RX_QUEUE(j), v_idx);
+			ixgbe_set_ivar(adapter, 0, j, v_idx);
 			r_idx = find_next_bit(q_vector->rxr_idx,
 			                      adapter->num_rx_queues,
 			                      r_idx + 1);
@@ -742,7 +799,7 @@ static void ixgbe_configure_msix(struct ixgbe_adapter *adapter)
 
 		for (i = 0; i < q_vector->txr_count; i++) {
 			j = adapter->tx_ring[r_idx].reg_idx;
-			ixgbe_set_ivar(adapter, IXGBE_IVAR_TX_QUEUE(j), v_idx);
+			ixgbe_set_ivar(adapter, 1, j, v_idx);
 			r_idx = find_next_bit(q_vector->txr_idx,
 			                      adapter->num_tx_queues,
 			                      r_idx + 1);
@@ -759,7 +816,11 @@ static void ixgbe_configure_msix(struct ixgbe_adapter *adapter)
 		                EITR_INTS_PER_SEC_TO_REG(q_vector->eitr));
 	}
 
-	ixgbe_set_ivar(adapter, IXGBE_IVAR_OTHER_CAUSES_INDEX, v_idx);
+	if (adapter->hw.mac.type == ixgbe_mac_82598EB)
+		ixgbe_set_ivar(adapter, -1, IXGBE_IVAR_OTHER_CAUSES_INDEX,
+		               v_idx);
+	else if (adapter->hw.mac.type == ixgbe_mac_82599EB)
+		ixgbe_set_ivar(adapter, -1, 1, v_idx);
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EITR(v_idx), 1950);
 
 	/* set up to autoclear timer, and the vectors */
@@ -897,6 +958,9 @@ static void ixgbe_set_itr_msix(struct ixgbe_q_vector *q_vector)
 		new_itr = ((q_vector->eitr * 90)/100) + ((new_itr * 10)/100);
 		q_vector->eitr = new_itr;
 		itr_reg = EITR_INTS_PER_SEC_TO_REG(new_itr);
+		if (adapter->hw.mac.type == ixgbe_mac_82599EB)
+			/* Resolution is 2 usec on 82599, so halve the rate */
+			itr_reg >>= 1;
 		/* must write high and low 16 bits to reset counter */
 		DPRINTK(TX_ERR, DEBUG, "writing eitr(%d): %08X\n", v_idx,
 		        itr_reg);
@@ -918,6 +982,24 @@ static void ixgbe_check_fan_failure(struct ixgbe_adapter *adapter, u32 eicr)
 	}
 }
 
+static void ixgbe_check_sfp_event(struct ixgbe_adapter *adapter, u32 eicr)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+
+	if (eicr & IXGBE_EICR_GPI_SDP1) {
+		/* Clear the interrupt */
+		IXGBE_WRITE_REG(hw, IXGBE_EICR, IXGBE_EICR_GPI_SDP1);
+		schedule_work(&adapter->multispeed_fiber_task);
+	} else if (eicr & IXGBE_EICR_GPI_SDP2) {
+		/* Clear the interrupt */
+		IXGBE_WRITE_REG(hw, IXGBE_EICR, IXGBE_EICR_GPI_SDP2);
+		schedule_work(&adapter->sfp_config_module_task);
+	} else {
+		/* Interrupt isn't for us... */
+		return;
+	}
+}
+
 static void ixgbe_check_lsc(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
@@ -950,8 +1032,11 @@ static irqreturn_t ixgbe_msix_lsc(int irq, void *data)
 	if (eicr & IXGBE_EICR_LSC)
 		ixgbe_check_lsc(adapter);
 
-	ixgbe_check_fan_failure(adapter, eicr);
+	if (hw->mac.type == ixgbe_mac_82598EB)
+		ixgbe_check_fan_failure(adapter, eicr);
 
+	if (hw->mac.type == ixgbe_mac_82599EB)
+		ixgbe_check_sfp_event(adapter, eicr);
 	if (!test_bit(__IXGBE_DOWN, &adapter->state))
 		IXGBE_WRITE_REG(hw, IXGBE_EIMS, IXGBE_EIMS_OTHER);
 
@@ -1314,6 +1399,9 @@ static void ixgbe_set_itr(struct ixgbe_adapter *adapter)
 		new_itr = ((q_vector->eitr * 90)/100) + ((new_itr * 10)/100);
 		q_vector->eitr = new_itr;
 		itr_reg = EITR_INTS_PER_SEC_TO_REG(new_itr);
+		if (adapter->hw.mac.type == ixgbe_mac_82599EB)
+			/* Resolution is 2 usec on 82599, so halve the rate */
+			itr_reg >>= 1;
 		/* must write high and low 16 bits to reset counter */
 		IXGBE_WRITE_REG(hw, IXGBE_EITR(0), itr_reg | (itr_reg)<<16);
 	}
@@ -1328,6 +1416,10 @@ static void ixgbe_set_itr(struct ixgbe_adapter *adapter)
 static inline void ixgbe_irq_disable(struct ixgbe_adapter *adapter)
 {
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC, ~0);
+	if (adapter->hw.mac.type == ixgbe_mac_82599EB) {
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC_EX(1), ~0);
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC_EX(2), ~0);
+	}
 	IXGBE_WRITE_FLUSH(&adapter->hw);
 	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
 		int i;
@@ -1348,7 +1440,20 @@ static inline void ixgbe_irq_enable(struct ixgbe_adapter *adapter)
 	mask = IXGBE_EIMS_ENABLE_MASK;
 	if (adapter->flags & IXGBE_FLAG_FAN_FAIL_CAPABLE)
 		mask |= IXGBE_EIMS_GPI_SDP1;
+	if (adapter->hw.mac.type == ixgbe_mac_82599EB) {
+		mask |= IXGBE_EIMS_GPI_SDP1;
+		mask |= IXGBE_EIMS_GPI_SDP2;
+	}
+
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS, mask);
+	if (adapter->hw.mac.type == ixgbe_mac_82599EB) {
+		/* enable the rest of the queue vectors */
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS_EX(1),
+		                (IXGBE_EIMS_RTX_QUEUE << 16));
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS_EX(2),
+		                ((IXGBE_EIMS_RTX_QUEUE << 16) |
+		                  IXGBE_EIMS_RTX_QUEUE));
+	}
 	IXGBE_WRITE_FLUSH(&adapter->hw);
 }
 
@@ -1384,6 +1489,9 @@ static irqreturn_t ixgbe_intr(int irq, void *data)
 	if (eicr & IXGBE_EICR_LSC)
 		ixgbe_check_lsc(adapter);
 
+	if (hw->mac.type == ixgbe_mac_82599EB)
+		ixgbe_check_sfp_event(adapter, eicr);
+
 	ixgbe_check_fan_failure(adapter, eicr);
 
 	if (napi_schedule_prep(&adapter->q_vector[0].napi)) {
@@ -1474,8 +1582,8 @@ static void ixgbe_configure_msi_and_legacy(struct ixgbe_adapter *adapter)
 	IXGBE_WRITE_REG(hw, IXGBE_EITR(0),
 	                EITR_INTS_PER_SEC_TO_REG(adapter->eitr_param));
 
-	ixgbe_set_ivar(adapter, IXGBE_IVAR_RX_QUEUE(0), 0);
-	ixgbe_set_ivar(adapter, IXGBE_IVAR_TX_QUEUE(0), 0);
+	ixgbe_set_ivar(adapter, 0, 0, 0);
+	ixgbe_set_ivar(adapter, 1, 0, 0);
 
 	map_vector_to_rxq(adapter, 0, 0);
 	map_vector_to_txq(adapter, 0, 0);
@@ -1516,26 +1624,25 @@ static void ixgbe_configure_tx(struct ixgbe_adapter *adapter)
 		txctrl &= ~IXGBE_DCA_TXCTRL_TX_WB_RO_EN;
 		IXGBE_WRITE_REG(hw, IXGBE_DCA_TXCTRL(j), txctrl);
 	}
+	if (hw->mac.type == ixgbe_mac_82599EB) {
+		/* We enable 8 traffic classes, DCB only */
+		if (adapter->flags & IXGBE_FLAG_DCB_ENABLED)
+			IXGBE_WRITE_REG(hw, IXGBE_MTQC, (IXGBE_MTQC_RT_ENA |
+			                IXGBE_MTQC_8TC_8TQ));
+	}
 }
 
-#define IXGBE_SRRCTL_BSIZEHDRSIZE_SHIFT	2
+#define IXGBE_SRRCTL_BSIZEHDRSIZE_SHIFT 2
 
 static void ixgbe_configure_srrctl(struct ixgbe_adapter *adapter, int index)
 {
 	struct ixgbe_ring *rx_ring;
 	u32 srrctl;
-	int queue0;
+	int queue0 = 0;
 	unsigned long mask;
 
-	/* program one srrctl register per VMDq index */
-	if (adapter->flags & IXGBE_FLAG_VMDQ_ENABLED) {
-		long shift, len;
-		mask = (unsigned long) adapter->ring_feature[RING_F_RSS].mask;
-		len = sizeof(adapter->ring_feature[RING_F_VMDQ].mask) * 8;
-		shift = find_first_bit(&mask, len);
-		queue0 = index & mask;
-		index = (index & mask) >> shift;
-	/* program one srrctl per RSS queue since RDRXCTL.MVMEN is enabled */
+	if (adapter->hw.mac.type == ixgbe_mac_82599EB) {
+		queue0 = index;
 	} else {
 		mask = (unsigned long) adapter->ring_feature[RING_F_RSS].mask;
 		queue0 = index & mask;
@@ -1572,6 +1679,9 @@ static void ixgbe_configure_srrctl(struct ixgbe_adapter *adapter, int index)
 			srrctl |= rx_ring->rx_buf_len >>
 			          IXGBE_SRRCTL_BSIZEPKT_SHIFT;
 	}
+	if (adapter->hw.mac.type == ixgbe_mac_82599EB)
+		srrctl |= IXGBE_SRRCTL_DROP_EN;
+
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_SRRCTL(index), srrctl);
 }
 
@@ -1603,6 +1713,14 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 	/* Set the RX buffer length according to the mode */
 	if (adapter->flags & IXGBE_FLAG_RX_PS_ENABLED) {
 		rx_buf_len = IXGBE_RX_HDR_SIZE;
+		if (hw->mac.type == ixgbe_mac_82599EB) {
+			/* PSRTYPE must be initialized in 82599 */
+			u32 psrtype = IXGBE_PSRTYPE_TCPHDR |
+			              IXGBE_PSRTYPE_UDPHDR |
+			              IXGBE_PSRTYPE_IPV4HDR |
+			              IXGBE_PSRTYPE_IPV6HDR;
+			IXGBE_WRITE_REG(hw, IXGBE_PSRTYPE(0), psrtype);
+		}
 	} else {
 		if (netdev->mtu <= ETH_DATA_LEN)
 			rx_buf_len = MAXIMUM_ETHERNET_VLAN_SIZE;
@@ -1613,6 +1731,7 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 	fctrl = IXGBE_READ_REG(&adapter->hw, IXGBE_FCTRL);
 	fctrl |= IXGBE_FCTRL_BAM;
 	fctrl |= IXGBE_FCTRL_DPF; /* discard pause frames when FC enabled */
+	fctrl |= IXGBE_FCTRL_PMCF;
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_FCTRL, fctrl);
 
 	hlreg0 = IXGBE_READ_REG(hw, IXGBE_HLREG0);
@@ -1644,23 +1763,43 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 		ixgbe_configure_srrctl(adapter, j);
 	}
 
-	/*
-	 * For VMDq support of different descriptor types or
-	 * buffer sizes through the use of multiple SRRCTL
-	 * registers, RDRXCTL.MVMEN must be set to 1
-	 *
-	 * also, the manual doesn't mention it clearly but DCA hints
-	 * will only use queue 0's tags unless this bit is set.  Side
-	 * effects of setting this bit are only that SRRCTL must be
-	 * fully programmed [0..15]
-	 */
-	if (adapter->flags &
-	    (IXGBE_FLAG_RSS_ENABLED | IXGBE_FLAG_VMDQ_ENABLED)) {
-		rdrxctl = IXGBE_READ_REG(hw, IXGBE_RDRXCTL);
-		rdrxctl |= IXGBE_RDRXCTL_MVMEN;
-		IXGBE_WRITE_REG(hw, IXGBE_RDRXCTL, rdrxctl);
+	if (hw->mac.type == ixgbe_mac_82598EB) {
+		/*
+		 * For VMDq support of different descriptor types or
+		 * buffer sizes through the use of multiple SRRCTL
+		 * registers, RDRXCTL.MVMEN must be set to 1
+		 *
+		 * also, the manual doesn't mention it clearly but DCA hints
+		 * will only use queue 0's tags unless this bit is set.  Side
+		 * effects of setting this bit are only that SRRCTL must be
+		 * fully programmed [0..15]
+		 */
+		if (adapter->flags &
+		    (IXGBE_FLAG_RSS_ENABLED | IXGBE_FLAG_VMDQ_ENABLED)) {
+			rdrxctl = IXGBE_READ_REG(hw, IXGBE_RDRXCTL);
+			rdrxctl |= IXGBE_RDRXCTL_MVMEN;
+			IXGBE_WRITE_REG(hw, IXGBE_RDRXCTL, rdrxctl);
+		}
 	}
 
+	/* Program MRQC for the distribution of queues */
+	if (hw->mac.type == ixgbe_mac_82599EB) {
+		int mask = adapter->flags & (
+				IXGBE_FLAG_RSS_ENABLED
+				| IXGBE_FLAG_DCB_ENABLED
+				);
+
+		switch (mask) {
+		case (IXGBE_FLAG_RSS_ENABLED):
+			mrqc = IXGBE_MRQC_RSSEN;
+			break;
+		case (IXGBE_FLAG_DCB_ENABLED):
+			mrqc = IXGBE_MRQC_RT8TCEN;
+			break;
+		default:
+			break;
+		}
+	}
 	if (adapter->flags & IXGBE_FLAG_RSS_ENABLED) {
 		/* Fill out redirection table */
 		for (i = 0, j = 0; i < 128; i++, j++) {
@@ -1682,12 +1821,9 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 		       | IXGBE_MRQC_RSS_FIELD_IPV4
 		       | IXGBE_MRQC_RSS_FIELD_IPV4_TCP
 		       | IXGBE_MRQC_RSS_FIELD_IPV4_UDP
-		       | IXGBE_MRQC_RSS_FIELD_IPV6_EX_TCP
-		       | IXGBE_MRQC_RSS_FIELD_IPV6_EX
 		       | IXGBE_MRQC_RSS_FIELD_IPV6
 		       | IXGBE_MRQC_RSS_FIELD_IPV6_TCP
-		       | IXGBE_MRQC_RSS_FIELD_IPV6_UDP
-		       | IXGBE_MRQC_RSS_FIELD_IPV6_EX_UDP;
+		       | IXGBE_MRQC_RSS_FIELD_IPV6_UDP;
 		IXGBE_WRITE_REG(hw, IXGBE_MRQC, mrqc);
 	}
 
@@ -1706,6 +1842,12 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 	}
 
 	IXGBE_WRITE_REG(hw, IXGBE_RXCSUM, rxcsum);
+
+	if (hw->mac.type == ixgbe_mac_82599EB) {
+		rdrxctl = IXGBE_READ_REG(hw, IXGBE_RDRXCTL);
+		rdrxctl |= IXGBE_RDRXCTL_CRCSTRIP;
+		IXGBE_WRITE_REG(hw, IXGBE_RDRXCTL, rdrxctl);
+	}
 }
 
 static void ixgbe_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
@@ -1739,6 +1881,7 @@ static void ixgbe_vlan_rx_register(struct net_device *netdev,
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	u32 ctrl;
+	int i, j;
 
 	if (!test_bit(__IXGBE_DOWN, &adapter->state))
 		ixgbe_irq_disable(adapter);
@@ -1750,18 +1893,24 @@ static void ixgbe_vlan_rx_register(struct net_device *netdev,
 	 * not in DCB mode.
 	 */
 	ctrl = IXGBE_READ_REG(&adapter->hw, IXGBE_VLNCTRL);
-	ctrl |= IXGBE_VLNCTRL_VME;
-	ctrl &= ~IXGBE_VLNCTRL_CFIEN;
-	IXGBE_WRITE_REG(&adapter->hw, IXGBE_VLNCTRL, ctrl);
-	ixgbe_vlan_rx_add_vid(netdev, 0);
-
-	if (grp) {
+	if (adapter->hw.mac.type == ixgbe_mac_82598EB) {
+		ctrl |= IXGBE_VLNCTRL_VME | IXGBE_VLNCTRL_VFE;
+		ctrl &= ~IXGBE_VLNCTRL_CFIEN;
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_VLNCTRL, ctrl);
+	} else if (adapter->hw.mac.type == ixgbe_mac_82599EB) {
+		ctrl |= IXGBE_VLNCTRL_VFE;
 		/* enable VLAN tag insert/strip */
 		ctrl = IXGBE_READ_REG(&adapter->hw, IXGBE_VLNCTRL);
-		ctrl |= IXGBE_VLNCTRL_VME;
 		ctrl &= ~IXGBE_VLNCTRL_CFIEN;
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_VLNCTRL, ctrl);
+		for (i = 0; i < adapter->num_rx_queues; i++) {
+			j = adapter->rx_ring[i].reg_idx;
+			ctrl = IXGBE_READ_REG(&adapter->hw, IXGBE_RXDCTL(j));
+			ctrl |= IXGBE_RXDCTL_VME;
+			IXGBE_WRITE_REG(&adapter->hw, IXGBE_RXDCTL(j), ctrl);
+		}
 	}
+	ixgbe_vlan_rx_add_vid(netdev, 0);
 
 	if (!test_bit(__IXGBE_DOWN, &adapter->state))
 		ixgbe_irq_enable(adapter);
@@ -1924,9 +2073,21 @@ static void ixgbe_configure_dcb(struct ixgbe_adapter *adapter)
 	}
 	/* Enable VLAN tag insert/strip */
 	vlnctrl = IXGBE_READ_REG(hw, IXGBE_VLNCTRL);
-	vlnctrl |= IXGBE_VLNCTRL_VME | IXGBE_VLNCTRL_VFE;
-	vlnctrl &= ~IXGBE_VLNCTRL_CFIEN;
-	IXGBE_WRITE_REG(hw, IXGBE_VLNCTRL, vlnctrl);
+	if (hw->mac.type == ixgbe_mac_82598EB) {
+		vlnctrl |= IXGBE_VLNCTRL_VME | IXGBE_VLNCTRL_VFE;
+		vlnctrl &= ~IXGBE_VLNCTRL_CFIEN;
+		IXGBE_WRITE_REG(hw, IXGBE_VLNCTRL, vlnctrl);
+	} else if (hw->mac.type == ixgbe_mac_82599EB) {
+		vlnctrl |= IXGBE_VLNCTRL_VFE;
+		vlnctrl &= ~IXGBE_VLNCTRL_CFIEN;
+		IXGBE_WRITE_REG(hw, IXGBE_VLNCTRL, vlnctrl);
+		for (i = 0; i < adapter->num_rx_queues; i++) {
+			j = adapter->rx_ring[i].reg_idx;
+			vlnctrl = IXGBE_READ_REG(hw, IXGBE_RXDCTL(j));
+			vlnctrl |= IXGBE_RXDCTL_VME;
+			IXGBE_WRITE_REG(hw, IXGBE_RXDCTL(j), vlnctrl);
+		}
+	}
 	hw->mac.ops.set_vfta(&adapter->hw, 0, 0, true);
 }
 
@@ -1957,13 +2118,60 @@ static void ixgbe_configure(struct ixgbe_adapter *adapter)
 		                       (adapter->rx_ring[i].count - 1));
 }
 
+static inline bool ixgbe_is_sfp(struct ixgbe_hw *hw)
+{
+	switch (hw->phy.type) {
+	case ixgbe_phy_sfp_avago:
+	case ixgbe_phy_sfp_ftl:
+	case ixgbe_phy_sfp_intel:
+	case ixgbe_phy_sfp_unknown:
+	case ixgbe_phy_tw_tyco:
+	case ixgbe_phy_tw_unknown:
+		return true;
+	default:
+		return false;
+	}
+}
+
+/**
+ * ixgbe_sfp_link_config - set up SFP+ link
+ * @adapter: pointer to private adapter struct
+ **/
+static void ixgbe_sfp_link_config(struct ixgbe_adapter *adapter)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+
+		if (hw->phy.multispeed_fiber) {
+			/*
+			 * In multispeed fiber setups, the device may not have
+			 * had a physical connection when the driver loaded.
+			 * If that's the case, the initial link configuration
+			 * couldn't get the MAC into 10G or 1G mode, so we'll
+			 * never have a link status change interrupt fire.
+			 * We need to try and force an autonegotiation
+			 * session, then bring up link.
+			 */
+			hw->mac.ops.setup_sfp(hw);
+			if (!(adapter->flags & IXGBE_FLAG_IN_SFP_LINK_TASK))
+				schedule_work(&adapter->multispeed_fiber_task);
+		} else {
+			/*
+			 * Direct Attach Cu and non-multispeed fiber modules
+			 * still need to be configured properly prior to
+			 * attempting link.
+			 */
+			if (!(adapter->flags & IXGBE_FLAG_IN_SFP_MOD_TASK))
+				schedule_work(&adapter->sfp_config_module_task);
+		}
+}
+
 /**
- * ixgbe_link_config - set up initial link with default speed and duplex
+ * ixgbe_non_sfp_link_config - set up non-SFP+ link
  * @hw: pointer to private hardware struct
  *
  * Returns 0 on success, negative on failure
  **/
-static int ixgbe_link_config(struct ixgbe_hw *hw)
+static int ixgbe_non_sfp_link_config(struct ixgbe_hw *hw)
 {
 	u32 autoneg;
 	bool link_up = false;
@@ -1983,19 +2191,42 @@ static int ixgbe_link_config(struct ixgbe_hw *hw)
 
 	if (hw->mac.ops.setup_link_speed)
 		ret = hw->mac.ops.setup_link_speed(hw, autoneg, true, link_up);
-
 link_cfg_out:
 	return ret;
 }
 
+#define IXGBE_MAX_RX_DESC_POLL 10
+static inline void ixgbe_rx_desc_queue_enable(struct ixgbe_adapter *adapter,
+	                                      int rxr)
+{
+	int j = adapter->rx_ring[rxr].reg_idx;
+	int k;
+
+	for (k = 0; k < IXGBE_MAX_RX_DESC_POLL; k++) {
+		if (IXGBE_READ_REG(&adapter->hw,
+		                   IXGBE_RXDCTL(j)) & IXGBE_RXDCTL_ENABLE)
+			break;
+		else
+			msleep(1);
+	}
+	if (k >= IXGBE_MAX_RX_DESC_POLL) {
+		DPRINTK(DRV, ERR, "RXDCTL.ENABLE on Rx queue %d "
+		        "not set within the polling period\n", rxr);
+	}
+	ixgbe_release_rx_desc(&adapter->hw, &adapter->rx_ring[rxr],
+	                      (adapter->rx_ring[rxr].count - 1));
+}
+
 static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 	struct ixgbe_hw *hw = &adapter->hw;
 	int i, j = 0;
+	int num_rx_rings = adapter->num_rx_queues;
 	int err;
 	int max_frame = netdev->mtu + ETH_HLEN + ETH_FCS_LEN;
 	u32 txdctl, rxdctl, mhadd;
+	u32 dmatxctl;
 	u32 gpie;
 
 	ixgbe_get_hw_control(adapter);
@@ -2027,6 +2258,13 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 		IXGBE_WRITE_REG(hw, IXGBE_GPIE, gpie);
 	}
 
+	if (hw->mac.type == ixgbe_mac_82599EB) {
+		gpie = IXGBE_READ_REG(hw, IXGBE_GPIE);
+		gpie |= IXGBE_SDP1_GPIEN;
+		gpie |= IXGBE_SDP2_GPIEN;
+		IXGBE_WRITE_REG(hw, IXGBE_GPIE, gpie);
+	}
+
 	mhadd = IXGBE_READ_REG(hw, IXGBE_MHADD);
 	if (max_frame != (mhadd >> IXGBE_MHADD_MFS_SHIFT)) {
 		mhadd &= ~IXGBE_MHADD_MFS_MASK;
@@ -2040,11 +2278,23 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 		txdctl = IXGBE_READ_REG(hw, IXGBE_TXDCTL(j));
 		/* enable WTHRESH=8 descriptors, to encourage burst writeback */
 		txdctl |= (8 << 16);
+		IXGBE_WRITE_REG(hw, IXGBE_TXDCTL(j), txdctl);
+	}
+
+	if (hw->mac.type == ixgbe_mac_82599EB) {
+		/* DMATXCTL.EN must be set after all Tx queue config is done */
+		dmatxctl = IXGBE_READ_REG(hw, IXGBE_DMATXCTL);
+		dmatxctl |= IXGBE_DMATXCTL_TE;
+		IXGBE_WRITE_REG(hw, IXGBE_DMATXCTL, dmatxctl);
+	}
+	for (i = 0; i < adapter->num_tx_queues; i++) {
+		j = adapter->tx_ring[i].reg_idx;
+		txdctl = IXGBE_READ_REG(hw, IXGBE_TXDCTL(j));
 		txdctl |= IXGBE_TXDCTL_ENABLE;
 		IXGBE_WRITE_REG(hw, IXGBE_TXDCTL(j), txdctl);
 	}
 
-	for (i = 0; i < adapter->num_rx_queues; i++) {
+	for (i = 0; i < num_rx_rings; i++) {
 		j = adapter->rx_ring[i].reg_idx;
 		rxdctl = IXGBE_READ_REG(hw, IXGBE_RXDCTL(j));
 		/* enable PTHRESH=32 descriptors (half the internal cache)
@@ -2053,11 +2303,16 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 		rxdctl |= 0x0020;
 		rxdctl |= IXGBE_RXDCTL_ENABLE;
 		IXGBE_WRITE_REG(hw, IXGBE_RXDCTL(j), rxdctl);
+		if (hw->mac.type == ixgbe_mac_82599EB)
+			ixgbe_rx_desc_queue_enable(adapter, i);
 	}
 	/* enable all receives */
 	rxdctl = IXGBE_READ_REG(hw, IXGBE_RXCTRL);
-	rxdctl |= (IXGBE_RXCTRL_DMBYPS | IXGBE_RXCTRL_RXEN);
-	IXGBE_WRITE_REG(hw, IXGBE_RXCTRL, rxdctl);
+	if (hw->mac.type == ixgbe_mac_82598EB)
+		rxdctl |= (IXGBE_RXCTRL_DMBYPS | IXGBE_RXCTRL_RXEN);
+	else
+		rxdctl |= IXGBE_RXCTRL_RXEN;
+	hw->mac.ops.enable_rx_dma(hw, rxdctl);
 
 	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED)
 		ixgbe_configure_msix(adapter);
@@ -2074,9 +2329,27 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 
 	ixgbe_irq_enable(adapter);
 
-	err = ixgbe_link_config(hw);
-	if (err)
-		dev_err(&adapter->pdev->dev, "link_config FAILED %d\n", err);
+	/*
+	 * For hot-pluggable SFP+ devices, a new SFP+ module may have
+	 * arrived before interrupts were enabled.  We need to kick off
+	 * the SFP+ module setup first, then try to bring up link.
+	 * If we're not hot-pluggable SFP+, we just need to configure link
+	 * and bring it up.
+	 */
+	err = hw->phy.ops.identify(hw);
+	if (err == IXGBE_ERR_SFP_NOT_SUPPORTED) {
+		DPRINTK(PROBE, ERR, "PHY not supported on this NIC %d\n", err);
+		ixgbe_down(adapter);
+		return err;
+	}
+
+	if (ixgbe_is_sfp(hw)) {
+		ixgbe_sfp_link_config(adapter);
+	} else {
+		err = ixgbe_non_sfp_link_config(hw);
+		if (err)
+			DPRINTK(PROBE, ERR, "link_config FAILED %d\n", err);
+	}
 
 	/* enable transmits */
 	netif_tx_start_all_queues(netdev);
@@ -2506,6 +2779,12 @@ static inline bool ixgbe_cache_ring_dcb(struct ixgbe_adapter *adapter)
 				adapter->tx_ring[i].reg_idx = i << 2;
 			}
 			ret = true;
+		} else if (adapter->hw.mac.type == ixgbe_mac_82599EB) {
+			for (i = 0; i < dcb_i; i++) {
+				adapter->rx_ring[i].reg_idx = i << 4;
+				adapter->tx_ring[i].reg_idx = i << 4;
+			}
+			ret = true;
 		} else {
 			ret = false;
 		}
@@ -2801,7 +3080,10 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	adapter->ring_feature[RING_F_RSS].indices = rss;
 	adapter->flags |= IXGBE_FLAG_RSS_ENABLED;
 	adapter->ring_feature[RING_F_DCB].indices = IXGBE_MAX_DCB_INDICES;
-	adapter->max_msix_q_vectors = MAX_MSIX_Q_VECTORS_82598;
+	if (hw->mac.type == ixgbe_mac_82598EB)
+		adapter->max_msix_q_vectors = MAX_MSIX_Q_VECTORS_82598;
+	else if (hw->mac.type == ixgbe_mac_82599EB)
+		adapter->max_msix_q_vectors = MAX_MSIX_Q_VECTORS_82599;
 
 #ifdef CONFIG_IXGBE_DCB
 	/* Configure DCB traffic classes */
@@ -2822,9 +3104,6 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	                   adapter->ring_feature[RING_F_DCB].indices);
 
 #endif
-	if (hw->mac.ops.get_media_type &&
-	    (hw->mac.ops.get_media_type(hw) == ixgbe_media_type_copper))
-		adapter->flags |= IXGBE_FLAG_FAN_FAIL_CAPABLE;
 
 	/* default flow control settings */
 	hw->fc.requested_mode = ixgbe_fc_none;
@@ -3272,6 +3551,9 @@ static int ixgbe_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_hw *hw = &adapter->hw;
+	u32 ctrl, fctrl;
+	u32 wufc = adapter->wol;
 #ifdef CONFIG_PM
 	int retval = 0;
 #endif
@@ -3295,9 +3577,33 @@ static int ixgbe_suspend(struct pci_dev *pdev, pm_message_t state)
 	if (retval)
 		return retval;
 #endif
+	if (wufc) {
+		ixgbe_set_rx_mode(netdev);
 
-	pci_enable_wake(pdev, PCI_D3hot, 0);
-	pci_enable_wake(pdev, PCI_D3cold, 0);
+		/* turn on all-multi mode if wake on multicast is enabled */
+		if (wufc & IXGBE_WUFC_MC) {
+			fctrl = IXGBE_READ_REG(hw, IXGBE_FCTRL);
+			fctrl |= IXGBE_FCTRL_MPE;
+			IXGBE_WRITE_REG(hw, IXGBE_FCTRL, fctrl);
+		}
+
+		ctrl = IXGBE_READ_REG(hw, IXGBE_CTRL);
+		ctrl |= IXGBE_CTRL_GIO_DIS;
+		IXGBE_WRITE_REG(hw, IXGBE_CTRL, ctrl);
+
+		IXGBE_WRITE_REG(hw, IXGBE_WUFC, wufc);
+	} else {
+		IXGBE_WRITE_REG(hw, IXGBE_WUC, 0);
+		IXGBE_WRITE_REG(hw, IXGBE_WUFC, 0);
+	}
+
+	if (wufc && hw->mac.type == ixgbe_mac_82599EB) {
+		pci_enable_wake(pdev, PCI_D3hot, 1);
+		pci_enable_wake(pdev, PCI_D3cold, 1);
+	} else {
+		pci_enable_wake(pdev, PCI_D3hot, 0);
+		pci_enable_wake(pdev, PCI_D3cold, 0);
+	}
 
 	ixgbe_release_hw_control(adapter);
 
@@ -3330,32 +3636,56 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 		missed_rx += mpc;
 		adapter->stats.mpc[i] += mpc;
 		total_mpc += adapter->stats.mpc[i];
-		adapter->stats.rnbc[i] += IXGBE_READ_REG(hw, IXGBE_RNBC(i));
+		if (hw->mac.type == ixgbe_mac_82598EB)
+			adapter->stats.rnbc[i] += IXGBE_READ_REG(hw, IXGBE_RNBC(i));
 		adapter->stats.qptc[i] += IXGBE_READ_REG(hw, IXGBE_QPTC(i));
 		adapter->stats.qbtc[i] += IXGBE_READ_REG(hw, IXGBE_QBTC(i));
 		adapter->stats.qprc[i] += IXGBE_READ_REG(hw, IXGBE_QPRC(i));
 		adapter->stats.qbrc[i] += IXGBE_READ_REG(hw, IXGBE_QBRC(i));
-		adapter->stats.pxonrxc[i] += IXGBE_READ_REG(hw,
-		                                            IXGBE_PXONRXC(i));
+		if (hw->mac.type == ixgbe_mac_82599EB) {
+			adapter->stats.pxonrxc[i] += IXGBE_READ_REG(hw,
+			                                    IXGBE_PXONRXCNT(i));
+			adapter->stats.pxoffrxc[i] += IXGBE_READ_REG(hw,
+			                                   IXGBE_PXOFFRXCNT(i));
+			adapter->stats.qprdc[i] += IXGBE_READ_REG(hw, IXGBE_QPRDC(i));
+			adapter->hw_rx_no_dma_resources += adapter->stats.qprdc[i];
+		} else {
+			adapter->stats.pxonrxc[i] += IXGBE_READ_REG(hw,
+			                                      IXGBE_PXONRXC(i));
+			adapter->stats.pxoffrxc[i] += IXGBE_READ_REG(hw,
+			                                     IXGBE_PXOFFRXC(i));
+		}
 		adapter->stats.pxontxc[i] += IXGBE_READ_REG(hw,
 		                                            IXGBE_PXONTXC(i));
-		adapter->stats.pxoffrxc[i] += IXGBE_READ_REG(hw,
-		                                            IXGBE_PXOFFRXC(i));
 		adapter->stats.pxofftxc[i] += IXGBE_READ_REG(hw,
-		                                            IXGBE_PXOFFTXC(i));
+		                                             IXGBE_PXOFFTXC(i));
 	}
 	adapter->stats.gprc += IXGBE_READ_REG(hw, IXGBE_GPRC);
 	/* work around hardware counting issue */
 	adapter->stats.gprc -= missed_rx;
 
 	/* 82598 hardware only has a 32 bit counter in the high register */
-	adapter->stats.gorc += IXGBE_READ_REG(hw, IXGBE_GORCH);
-	adapter->stats.gotc += IXGBE_READ_REG(hw, IXGBE_GOTCH);
-	adapter->stats.tor += IXGBE_READ_REG(hw, IXGBE_TORH);
+	if (hw->mac.type == ixgbe_mac_82599EB) {
+		adapter->stats.gorc += IXGBE_READ_REG(hw, IXGBE_GORCL);
+		IXGBE_READ_REG(hw, IXGBE_GORCH); /* to clear */
+		adapter->stats.gotc += IXGBE_READ_REG(hw, IXGBE_GOTCL);
+		IXGBE_READ_REG(hw, IXGBE_GOTCH); /* to clear */
+		adapter->stats.tor += IXGBE_READ_REG(hw, IXGBE_TORL);
+		IXGBE_READ_REG(hw, IXGBE_TORH); /* to clear */
+		adapter->stats.lxonrxc += IXGBE_READ_REG(hw, IXGBE_LXONRXCNT);
+		adapter->stats.lxoffrxc += IXGBE_READ_REG(hw, IXGBE_LXOFFRXCNT);
+	} else {
+		adapter->stats.lxonrxc += IXGBE_READ_REG(hw, IXGBE_LXONRXC);
+		adapter->stats.lxoffrxc += IXGBE_READ_REG(hw, IXGBE_LXOFFRXC);
+		adapter->stats.gorc += IXGBE_READ_REG(hw, IXGBE_GORCH);
+		adapter->stats.gotc += IXGBE_READ_REG(hw, IXGBE_GOTCH);
+		adapter->stats.tor += IXGBE_READ_REG(hw, IXGBE_TORH);
+	}
 	bprc = IXGBE_READ_REG(hw, IXGBE_BPRC);
 	adapter->stats.bprc += bprc;
 	adapter->stats.mprc += IXGBE_READ_REG(hw, IXGBE_MPRC);
-	adapter->stats.mprc -= bprc;
+	if (hw->mac.type == ixgbe_mac_82598EB)
+		adapter->stats.mprc -= bprc;
 	adapter->stats.roc += IXGBE_READ_REG(hw, IXGBE_ROC);
 	adapter->stats.prc64 += IXGBE_READ_REG(hw, IXGBE_PRC64);
 	adapter->stats.prc127 += IXGBE_READ_REG(hw, IXGBE_PRC127);
@@ -3364,8 +3694,6 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 	adapter->stats.prc1023 += IXGBE_READ_REG(hw, IXGBE_PRC1023);
 	adapter->stats.prc1522 += IXGBE_READ_REG(hw, IXGBE_PRC1522);
 	adapter->stats.rlec += IXGBE_READ_REG(hw, IXGBE_RLEC);
-	adapter->stats.lxonrxc += IXGBE_READ_REG(hw, IXGBE_LXONRXC);
-	adapter->stats.lxoffrxc += IXGBE_READ_REG(hw, IXGBE_LXOFFRXC);
 	lxon = IXGBE_READ_REG(hw, IXGBE_LXONTXC);
 	adapter->stats.lxontxc += lxon;
 	lxoff = IXGBE_READ_REG(hw, IXGBE_LXOFFTXC);
@@ -3438,6 +3766,55 @@ static void ixgbe_watchdog(unsigned long data)
 }
 
 /**
+ * ixgbe_multispeed_fiber_task - worker thread to configure multispeed fiber
+ * @work: pointer to work_struct containing our data
+ **/
+static void ixgbe_multispeed_fiber_task(struct work_struct *work)
+{
+	struct ixgbe_adapter *adapter = container_of(work,
+	                                             struct ixgbe_adapter,
+	                                             multispeed_fiber_task);
+	struct ixgbe_hw *hw = &adapter->hw;
+	u32 autoneg;
+
+	adapter->flags |= IXGBE_FLAG_IN_SFP_LINK_TASK;
+	if (hw->mac.ops.get_link_capabilities)
+		hw->mac.ops.get_link_capabilities(hw, &autoneg,
+		                                  &hw->mac.autoneg);
+	if (hw->mac.ops.setup_link_speed)
+		hw->mac.ops.setup_link_speed(hw, autoneg, true, true);
+	adapter->flags |= IXGBE_FLAG_NEED_LINK_UPDATE;
+	adapter->flags &= ~IXGBE_FLAG_IN_SFP_LINK_TASK;
+}
+
+/**
+ * ixgbe_sfp_config_module_task - worker thread to configure a new SFP+ module
+ * @work: pointer to work_struct containing our data
+ **/
+static void ixgbe_sfp_config_module_task(struct work_struct *work)
+{
+	struct ixgbe_adapter *adapter = container_of(work,
+	                                             struct ixgbe_adapter,
+	                                             sfp_config_module_task);
+	struct ixgbe_hw *hw = &adapter->hw;
+	u32 err;
+
+	adapter->flags |= IXGBE_FLAG_IN_SFP_MOD_TASK;
+	err = hw->phy.ops.identify_sfp(hw);
+	if (err == IXGBE_ERR_SFP_NOT_SUPPORTED) {
+		DPRINTK(PROBE, ERR, "PHY not supported on this NIC %d\n", err);
+		ixgbe_down(adapter);
+		return;
+	}
+	hw->mac.ops.setup_sfp(hw);
+
+	if (!adapter->flags & IXGBE_FLAG_IN_SFP_LINK_TASK)
+		/* This will also work for DA Twinax connections */
+		schedule_work(&adapter->multispeed_fiber_task);
+	adapter->flags &= ~IXGBE_FLAG_IN_SFP_MOD_TASK;
+}
+
+/**
  * ixgbe_watchdog_task - worker thread to bring link up
  * @work: pointer to work_struct containing our data
  **/
@@ -3467,10 +3844,20 @@ static void ixgbe_watchdog_task(struct work_struct *work)
 
 	if (link_up) {
 		if (!netif_carrier_ok(netdev)) {
-			u32 frctl = IXGBE_READ_REG(hw, IXGBE_FCTRL);
-			u32 rmcs = IXGBE_READ_REG(hw, IXGBE_RMCS);
-#define FLOW_RX (frctl & IXGBE_FCTRL_RFCE)
-#define FLOW_TX (rmcs & IXGBE_RMCS_TFCE_802_3X)
+			bool flow_rx, flow_tx;
+
+			if (hw->mac.type == ixgbe_mac_82599EB) {
+				u32 mflcn = IXGBE_READ_REG(hw, IXGBE_MFLCN);
+				u32 fccfg = IXGBE_READ_REG(hw, IXGBE_FCCFG);
+				flow_rx = (mflcn & IXGBE_MFLCN_RFCE);
+				flow_tx = (fccfg & IXGBE_FCCFG_TFCE_802_3X);
+			} else {
+				u32 frctl = IXGBE_READ_REG(hw, IXGBE_FCTRL);
+				u32 rmcs = IXGBE_READ_REG(hw, IXGBE_RMCS);
+				flow_rx = (frctl & IXGBE_FCTRL_RFCE);
+				flow_tx = (rmcs & IXGBE_RMCS_TFCE_802_3X);
+			}
+
 			printk(KERN_INFO "ixgbe: %s NIC Link is Up %s, "
 			       "Flow Control: %s\n",
 			       netdev->name,
@@ -3478,9 +3865,9 @@ static void ixgbe_watchdog_task(struct work_struct *work)
 			        "10 Gbps" :
 			        (link_speed == IXGBE_LINK_SPEED_1GB_FULL ?
 			         "1 Gbps" : "unknown speed")),
-			       ((FLOW_RX && FLOW_TX) ? "RX/TX" :
-			        (FLOW_RX ? "RX" :
-			        (FLOW_TX ? "TX" : "None"))));
+			       ((flow_rx && flow_tx) ? "RX/TX" :
+			        (flow_rx ? "RX" :
+			        (flow_tx ? "TX" : "None"))));
 
 			netif_carrier_on(netdev);
 		} else {
@@ -3987,7 +4374,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	const struct ixgbe_info *ii = ixgbe_info_tbl[ent->driver_data];
 	static int cards_found;
 	int i, err, pci_using_dac;
-	u16 link_status, link_speed, link_width;
+	u16 pm_value = 0;
 	u32 part_num, eec;
 
 	err = pci_enable_device(pdev);
@@ -4086,6 +4473,13 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 
 	INIT_WORK(&adapter->sfp_task, ixgbe_sfp_task);
 
+	/* multispeed fiber has its own tasklet, called from GPI SDP1 context */
+	INIT_WORK(&adapter->multispeed_fiber_task, ixgbe_multispeed_fiber_task);
+
+	/* a new SFP+ module arrival, called from GPI SDP2 context */
+	INIT_WORK(&adapter->sfp_config_module_task,
+	          ixgbe_sfp_config_module_task);
+
 	err = ii->get_invariants(hw);
 	if (err == IXGBE_ERR_SFP_NOT_PRESENT) {
 		/* start a kernel thread to watch for a module to arrive */
@@ -4166,26 +4560,41 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_sw_init;
 
+	switch (pdev->device) {
+	case IXGBE_DEV_ID_82599_KX4:
+#define IXGBE_PCIE_PMCSR 0x44
+		adapter->wol = IXGBE_WUFC_MAG;
+		pci_read_config_word(pdev, IXGBE_PCIE_PMCSR, &pm_value);
+		pci_write_config_word(pdev, IXGBE_PCIE_PMCSR,
+		                      (pm_value | (1 << 8)));
+		break;
+	default:
+		adapter->wol = 0;
+		break;
+	}
+	device_init_wakeup(&adapter->pdev->dev, true);
+	device_set_wakeup_enable(&adapter->pdev->dev, adapter->wol);
+
 	/* print bus type/speed/width info */
-	pci_read_config_word(pdev, IXGBE_PCI_LINK_STATUS, &link_status);
-	link_speed = link_status & IXGBE_PCI_LINK_SPEED;
-	link_width = link_status & IXGBE_PCI_LINK_WIDTH;
 	dev_info(&pdev->dev, "(PCI Express:%s:%s) %pM\n",
-	        ((link_speed == IXGBE_PCI_LINK_SPEED_5000) ? "5.0Gb/s" :
-	         (link_speed == IXGBE_PCI_LINK_SPEED_2500) ? "2.5Gb/s" :
-	         "Unknown"),
-	        ((link_width == IXGBE_PCI_LINK_WIDTH_8) ? "Width x8" :
-	         (link_width == IXGBE_PCI_LINK_WIDTH_4) ? "Width x4" :
-	         (link_width == IXGBE_PCI_LINK_WIDTH_2) ? "Width x2" :
-	         (link_width == IXGBE_PCI_LINK_WIDTH_1) ? "Width x1" :
+	        ((hw->bus.speed == ixgbe_bus_speed_5000) ? "5.0Gb/s":
+	         (hw->bus.speed == ixgbe_bus_speed_2500) ? "2.5Gb/s":"Unknown"),
+	        ((hw->bus.width == ixgbe_bus_width_pcie_x8) ? "Width x8" :
+	         (hw->bus.width == ixgbe_bus_width_pcie_x4) ? "Width x4" :
+	         (hw->bus.width == ixgbe_bus_width_pcie_x1) ? "Width x1" :
 	         "Unknown"),
 	        netdev->dev_addr);
 	ixgbe_read_pba_num_generic(hw, &part_num);
-	dev_info(&pdev->dev, "MAC: %d, PHY: %d, PBA No: %06x-%03x\n",
-	         hw->mac.type, hw->phy.type,
-	         (part_num >> 8), (part_num & 0xff));
+	if (ixgbe_is_sfp(hw) && hw->phy.sfp_type != ixgbe_sfp_type_not_present)
+		dev_info(&pdev->dev, "MAC: %d, PHY: %d, SFP+: %d, PBA No: %06x-%03x\n",
+		         hw->mac.type, hw->phy.type, hw->phy.sfp_type,
+		         (part_num >> 8), (part_num & 0xff));
+	else
+		dev_info(&pdev->dev, "MAC: %d, PHY: %d, PBA No: %06x-%03x\n",
+		         hw->mac.type, hw->phy.type,
+		         (part_num >> 8), (part_num & 0xff));
 
-	if (link_width <= IXGBE_PCI_LINK_WIDTH_4) {
+	if (hw->bus.width <= ixgbe_bus_width_pcie_x4) {
 		dev_warn(&pdev->dev, "PCI-Express bandwidth available for "
 		         "this card is not sufficient for optimal "
 		         "performance.\n");
@@ -4229,6 +4638,8 @@ err_eeprom:
 	clear_bit(__IXGBE_SFP_MODULE_NOT_FOUND, &adapter->state);
 	del_timer_sync(&adapter->sfp_timer);
 	cancel_work_sync(&adapter->sfp_task);
+	cancel_work_sync(&adapter->multispeed_fiber_task);
+	cancel_work_sync(&adapter->sfp_config_module_task);
 	iounmap(hw->hw_addr);
 err_ioremap:
 	free_netdev(netdev);
@@ -4265,6 +4676,8 @@ static void __devexit ixgbe_remove(struct pci_dev *pdev)
 	del_timer_sync(&adapter->sfp_timer);
 	cancel_work_sync(&adapter->watchdog_task);
 	cancel_work_sync(&adapter->sfp_task);
+	cancel_work_sync(&adapter->multispeed_fiber_task);
+	cancel_work_sync(&adapter->sfp_config_module_task);
 	flush_scheduled_work();
 
 #ifdef CONFIG_IXGBE_DCA

