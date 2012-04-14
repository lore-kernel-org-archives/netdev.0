From: xiong <xiong@qca.qualcomm.com>
Subject: [PATCH 02/12] atl1c: remove multiple-RX-Q code
Date: Sat, 14 Apr 2012 17:59:18 +0800
Message-ID: <1334397568-8444-3-git-send-email-xiong@qca.qualcomm.com>
References: <1334397568-8444-1-git-send-email-xiong@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <qca-linux-team@qualcomm.com>, <nic-devel@qualcomm.com>,
	xiong <xiong@qca.qualcomm.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1334397568-8444-1-git-send-email-xiong@qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

the multiple-RX-Q in hardware doesn't work,
all related register definition & code are removed.

Signed-off-by: xiong <xiong@qca.qualcomm.com>
Tested-by: Liu David <dwliu@qca.qualcomm.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c.h      |   22 +--
 drivers/net/ethernet/atheros/atl1c/atl1c_hw.h   |   36 ----
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |  216 +++++++----------------
 3 files changed, 65 insertions(+), 209 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c.h b/drivers/net/ethernet/atheros/atl1c/atl1c.h
index ca70e16..c725ee5 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c.h
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c.h
@@ -297,20 +297,6 @@ enum atl1c_dma_req_block {
 	atl1c_dma_req_4096 = 5
 };
 
-enum atl1c_rss_mode {
-	atl1c_rss_mode_disable = 0,
-	atl1c_rss_sig_que = 1,
-	atl1c_rss_mul_que_sig_int = 2,
-	atl1c_rss_mul_que_mul_int = 4,
-};
-
-enum atl1c_rss_type {
-	atl1c_rss_disable = 0,
-	atl1c_rss_ipv4 = 1,
-	atl1c_rss_ipv4_tcp = 2,
-	atl1c_rss_ipv6 = 4,
-	atl1c_rss_ipv6_tcp = 8
-};
 
 enum atl1c_nic_type {
 	athr_l1c = 0,
@@ -451,9 +437,6 @@ struct atl1c_hw {
 	u16 tpd_thresh;
 	u8 tpd_burst;   /* Number of TPD to prefetch in cache-aligned burst. */
 	u8 rfd_burst;
-	enum atl1c_rss_type rss_type;
-	enum atl1c_rss_mode rss_mode;
-	u8 rss_hash_bits;
 	u32 base_cpu;
 	u32 indirect_tab;
 	u8 mac_addr[ETH_ALEN];
@@ -586,11 +569,10 @@ struct atl1c_adapter {
 	/* All Descriptor memory */
 	struct atl1c_ring_header ring_header;
 	struct atl1c_tpd_ring tpd_ring[AT_MAX_TRANSMIT_QUEUE];
-	struct atl1c_rfd_ring rfd_ring[AT_MAX_RECEIVE_QUEUE];
-	struct atl1c_rrd_ring rrd_ring[AT_MAX_RECEIVE_QUEUE];
+	struct atl1c_rfd_ring rfd_ring;
+	struct atl1c_rrd_ring rrd_ring;
 	struct atl1c_cmb cmb;
 	struct atl1c_smb smb;
-	int num_rx_queues;
 	u32 bd_number;     /* board number;*/
 };
 
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
index 655fc6c..855aca0 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
@@ -461,17 +461,11 @@ int atl1c_phy_power_saving(struct atl1c_hw *hw);
 #define REG_SMB_BASE_ADDR_HI		0x1548
 #define REG_SMB_BASE_ADDR_LO		0x154C
 #define REG_RFD0_HEAD_ADDR_LO		0x1550
-#define REG_RFD1_HEAD_ADDR_LO		0x1554
-#define REG_RFD2_HEAD_ADDR_LO		0x1558
-#define REG_RFD3_HEAD_ADDR_LO		0x155C
 #define REG_RFD_RING_SIZE		0x1560
 #define RFD_RING_SIZE_MASK		0x0FFF
 #define REG_RX_BUF_SIZE			0x1564
 #define RX_BUF_SIZE_MASK		0xFFFF
 #define REG_RRD0_HEAD_ADDR_LO		0x1568
-#define REG_RRD1_HEAD_ADDR_LO		0x156C
-#define REG_RRD2_HEAD_ADDR_LO		0x1570
-#define REG_RRD3_HEAD_ADDR_LO		0x1574
 #define REG_RRD_RING_SIZE		0x1578
 #define RRD_RING_SIZE_MASK		0x0FFF
 #define REG_HTPD_HEAD_ADDR_LO		0x157C
@@ -480,30 +474,6 @@ int atl1c_phy_power_saving(struct atl1c_hw *hw);
 #define TPD_RING_SIZE_MASK		0xFFFF
 #define REG_CMB_BASE_ADDR_LO		0x1588
 
-/* RSS about */
-#define REG_RSS_KEY0                    0x14B0
-#define REG_RSS_KEY1                    0x14B4
-#define REG_RSS_KEY2                    0x14B8
-#define REG_RSS_KEY3                    0x14BC
-#define REG_RSS_KEY4                    0x14C0
-#define REG_RSS_KEY5                    0x14C4
-#define REG_RSS_KEY6                    0x14C8
-#define REG_RSS_KEY7                    0x14CC
-#define REG_RSS_KEY8                    0x14D0
-#define REG_RSS_KEY9                    0x14D4
-#define REG_IDT_TABLE0                	0x14E0
-#define REG_IDT_TABLE1                  0x14E4
-#define REG_IDT_TABLE2                  0x14E8
-#define REG_IDT_TABLE3                  0x14EC
-#define REG_IDT_TABLE4                  0x14F0
-#define REG_IDT_TABLE5                  0x14F4
-#define REG_IDT_TABLE6                  0x14F8
-#define REG_IDT_TABLE7                  0x14FC
-#define REG_IDT_TABLE                   REG_IDT_TABLE0
-#define REG_RSS_HASH_VALUE              0x15B0
-#define REG_RSS_HASH_FLAG               0x15B4
-#define REG_BASE_CPU_NUMBER             0x15B8
-
 /* TXQ Control Register */
 #define REG_TXQ_CTRL                	0x1590
 #define	TXQ_NUM_TPD_BURST_MASK     	0xF
@@ -608,9 +578,6 @@ int atl1c_phy_power_saving(struct atl1c_hw *hw);
 /* Mail box */
 #define MB_RFDX_PROD_IDX_MASK		0xFFFF
 #define REG_MB_RFD0_PROD_IDX		0x15E0
-#define REG_MB_RFD1_PROD_IDX		0x15E4
-#define REG_MB_RFD2_PROD_IDX		0x15E8
-#define REG_MB_RFD3_PROD_IDX		0x15EC
 
 #define MB_PRIO_PROD_IDX_MASK		0xFFFF
 #define REG_MB_PRIO_PROD_IDX		0x15F0
@@ -625,9 +592,6 @@ int atl1c_phy_power_saving(struct atl1c_hw *hw);
 #define REG_MB_RFD01_CONS_IDX		0x15F8
 #define MB_RFD0_CONS_IDX_MASK		0x0000FFFF
 #define MB_RFD1_CONS_IDX_MASK		0xFFFF0000
-#define REG_MB_RFD23_CONS_IDX		0x15FC
-#define MB_RFD2_CONS_IDX_MASK		0x0000FFFF
-#define MB_RFD3_CONS_IDX_MASK		0xFFFF0000
 
 /* Interrupt Status Register */
 #define REG_ISR    			0x1600
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 1f1f9eb..226be99 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -66,7 +66,7 @@ static void atl1c_enable_tx_ctrl(struct atl1c_hw *hw);
 static void atl1c_disable_l0s_l1(struct atl1c_hw *hw);
 static void atl1c_set_aspm(struct atl1c_hw *hw, bool linkup);
 static void atl1c_setup_mac_ctrl(struct atl1c_adapter *adapter);
-static void atl1c_clean_rx_irq(struct atl1c_adapter *adapter, u8 que,
+static void atl1c_clean_rx_irq(struct atl1c_adapter *adapter,
 		   int *work_done, int work_to_do);
 static int atl1c_up(struct atl1c_adapter *adapter);
 static void atl1c_down(struct atl1c_adapter *adapter);
@@ -75,29 +75,6 @@ static const u16 atl1c_pay_load_size[] = {
 	128, 256, 512, 1024, 2048, 4096,
 };
 
-static const u16 atl1c_rfd_prod_idx_regs[AT_MAX_RECEIVE_QUEUE] =
-{
-	REG_MB_RFD0_PROD_IDX,
-	REG_MB_RFD1_PROD_IDX,
-	REG_MB_RFD2_PROD_IDX,
-	REG_MB_RFD3_PROD_IDX
-};
-
-static const u16 atl1c_rfd_addr_lo_regs[AT_MAX_RECEIVE_QUEUE] =
-{
-	REG_RFD0_HEAD_ADDR_LO,
-	REG_RFD1_HEAD_ADDR_LO,
-	REG_RFD2_HEAD_ADDR_LO,
-	REG_RFD3_HEAD_ADDR_LO
-};
-
-static const u16 atl1c_rrd_addr_lo_regs[AT_MAX_RECEIVE_QUEUE] =
-{
-	REG_RRD0_HEAD_ADDR_LO,
-	REG_RRD1_HEAD_ADDR_LO,
-	REG_RRD2_HEAD_ADDR_LO,
-	REG_RRD3_HEAD_ADDR_LO
-};
 
 static const u32 atl1c_default_msg = NETIF_MSG_DRV | NETIF_MSG_PROBE |
 	NETIF_MSG_LINK | NETIF_MSG_TIMER | NETIF_MSG_IFDOWN | NETIF_MSG_IFUP;
@@ -730,9 +707,8 @@ static int __devinit atl1c_sw_init(struct atl1c_adapter *adapter)
 	device_set_wakeup_enable(&pdev->dev, false);
 	adapter->link_speed = SPEED_0;
 	adapter->link_duplex = FULL_DUPLEX;
-	adapter->num_rx_queues = AT_DEF_RECEIVE_QUEUE;
 	adapter->tpd_ring[0].count = 1024;
-	adapter->rfd_ring[0].count = 512;
+	adapter->rfd_ring.count = 512;
 
 	hw->vendor_id = pdev->vendor;
 	hw->device_id = pdev->device;
@@ -751,14 +727,6 @@ static int __devinit atl1c_sw_init(struct atl1c_adapter *adapter)
 	hw->phy_configured = false;
 	hw->preamble_len = 7;
 	hw->max_frame_size = adapter->netdev->mtu;
-	if (adapter->num_rx_queues < 2) {
-		hw->rss_type = atl1c_rss_disable;
-		hw->rss_mode = atl1c_rss_mode_disable;
-	} else {
-		hw->rss_type = atl1c_rss_ipv4;
-		hw->rss_mode = atl1c_rss_mul_que_mul_int;
-		hw->rss_hash_bits = 16;
-	}
 	hw->autoneg_advertised = ADVERTISED_Autoneg;
 	hw->indirect_tab = 0xE4E4E4E4;
 	hw->base_cpu = 0;
@@ -852,24 +820,22 @@ static void atl1c_clean_tx_ring(struct atl1c_adapter *adapter,
  */
 static void atl1c_clean_rx_ring(struct atl1c_adapter *adapter)
 {
-	struct atl1c_rfd_ring *rfd_ring = adapter->rfd_ring;
-	struct atl1c_rrd_ring *rrd_ring = adapter->rrd_ring;
+	struct atl1c_rfd_ring *rfd_ring = &adapter->rfd_ring;
+	struct atl1c_rrd_ring *rrd_ring = &adapter->rrd_ring;
 	struct atl1c_buffer *buffer_info;
 	struct pci_dev *pdev = adapter->pdev;
-	int i, j;
+	int j;
 
-	for (i = 0; i < adapter->num_rx_queues; i++) {
-		for (j = 0; j < rfd_ring[i].count; j++) {
-			buffer_info = &rfd_ring[i].buffer_info[j];
-			atl1c_clean_buffer(pdev, buffer_info, 0);
-		}
-		/* zero out the descriptor ring */
-		memset(rfd_ring[i].desc, 0, rfd_ring[i].size);
-		rfd_ring[i].next_to_clean = 0;
-		rfd_ring[i].next_to_use = 0;
-		rrd_ring[i].next_to_use = 0;
-		rrd_ring[i].next_to_clean = 0;
+	for (j = 0; j < rfd_ring->count; j++) {
+		buffer_info = &rfd_ring->buffer_info[j];
+		atl1c_clean_buffer(pdev, buffer_info, 0);
 	}
+	/* zero out the descriptor ring */
+	memset(rfd_ring->desc, 0, rfd_ring->size);
+	rfd_ring->next_to_clean = 0;
+	rfd_ring->next_to_use = 0;
+	rrd_ring->next_to_use = 0;
+	rrd_ring->next_to_clean = 0;
 }
 
 /*
@@ -878,8 +844,8 @@ static void atl1c_clean_rx_ring(struct atl1c_adapter *adapter)
 static void atl1c_init_ring_ptrs(struct atl1c_adapter *adapter)
 {
 	struct atl1c_tpd_ring *tpd_ring = adapter->tpd_ring;
-	struct atl1c_rfd_ring *rfd_ring = adapter->rfd_ring;
-	struct atl1c_rrd_ring *rrd_ring = adapter->rrd_ring;
+	struct atl1c_rfd_ring *rfd_ring = &adapter->rfd_ring;
+	struct atl1c_rrd_ring *rrd_ring = &adapter->rrd_ring;
 	struct atl1c_buffer *buffer_info;
 	int i, j;
 
@@ -891,15 +857,13 @@ static void atl1c_init_ring_ptrs(struct atl1c_adapter *adapter)
 			ATL1C_SET_BUFFER_STATE(&buffer_info[i],
 					ATL1C_BUFFER_FREE);
 	}
-	for (i = 0; i < adapter->num_rx_queues; i++) {
-		rfd_ring[i].next_to_use = 0;
-		rfd_ring[i].next_to_clean = 0;
-		rrd_ring[i].next_to_use = 0;
-		rrd_ring[i].next_to_clean = 0;
-		for (j = 0; j < rfd_ring[i].count; j++) {
-			buffer_info = &rfd_ring[i].buffer_info[j];
-			ATL1C_SET_BUFFER_STATE(buffer_info, ATL1C_BUFFER_FREE);
-		}
+	rfd_ring->next_to_use = 0;
+	rfd_ring->next_to_clean = 0;
+	rrd_ring->next_to_use = 0;
+	rrd_ring->next_to_clean = 0;
+	for (j = 0; j < rfd_ring->count; j++) {
+		buffer_info = &rfd_ring->buffer_info[j];
+		ATL1C_SET_BUFFER_STATE(buffer_info, ATL1C_BUFFER_FREE);
 	}
 }
 
@@ -936,27 +900,23 @@ static int atl1c_setup_ring_resources(struct atl1c_adapter *adapter)
 {
 	struct pci_dev *pdev = adapter->pdev;
 	struct atl1c_tpd_ring *tpd_ring = adapter->tpd_ring;
-	struct atl1c_rfd_ring *rfd_ring = adapter->rfd_ring;
-	struct atl1c_rrd_ring *rrd_ring = adapter->rrd_ring;
+	struct atl1c_rfd_ring *rfd_ring = &adapter->rfd_ring;
+	struct atl1c_rrd_ring *rrd_ring = &adapter->rrd_ring;
 	struct atl1c_ring_header *ring_header = &adapter->ring_header;
-	int num_rx_queues = adapter->num_rx_queues;
 	int size;
 	int i;
 	int count = 0;
 	int rx_desc_count = 0;
 	u32 offset = 0;
 
-	rrd_ring[0].count = rfd_ring[0].count;
+	rrd_ring->count = rfd_ring->count;
 	for (i = 1; i < AT_MAX_TRANSMIT_QUEUE; i++)
 		tpd_ring[i].count = tpd_ring[0].count;
 
-	for (i = 1; i < adapter->num_rx_queues; i++)
-		rfd_ring[i].count = rrd_ring[i].count = rfd_ring[0].count;
-
 	/* 2 tpd queue, one high priority queue,
 	 * another normal priority queue */
 	size = sizeof(struct atl1c_buffer) * (tpd_ring->count * 2 +
-		rfd_ring->count * num_rx_queues);
+		rfd_ring->count);
 	tpd_ring->buffer_info = kzalloc(size, GFP_KERNEL);
 	if (unlikely(!tpd_ring->buffer_info)) {
 		dev_err(&pdev->dev, "kzalloc failed, size = %d\n",
@@ -969,12 +929,11 @@ static int atl1c_setup_ring_resources(struct atl1c_adapter *adapter)
 		count += tpd_ring[i].count;
 	}
 
-	for (i = 0; i < num_rx_queues; i++) {
-		rfd_ring[i].buffer_info =
-			(struct atl1c_buffer *) (tpd_ring->buffer_info + count);
-		count += rfd_ring[i].count;
-		rx_desc_count += rfd_ring[i].count;
-	}
+	rfd_ring->buffer_info =
+		(struct atl1c_buffer *) (tpd_ring->buffer_info + count);
+	count += rfd_ring->count;
+	rx_desc_count += rfd_ring->count;
+
 	/*
 	 * real ring DMA buffer
 	 * each ring/block may need up to 8 bytes for alignment, hence the
@@ -985,7 +944,7 @@ static int atl1c_setup_ring_resources(struct atl1c_adapter *adapter)
 		sizeof(struct atl1c_rx_free_desc) * rx_desc_count +
 		sizeof(struct atl1c_recv_ret_status) * rx_desc_count +
 		sizeof(struct atl1c_hw_stats) +
-		8 * 4 + 8 * 2 * num_rx_queues;
+		8 * 4 + 8 * 2;
 
 	ring_header->desc = pci_alloc_consistent(pdev, ring_header->size,
 				&ring_header->dma);
@@ -1006,22 +965,17 @@ static int atl1c_setup_ring_resources(struct atl1c_adapter *adapter)
 		offset += roundup(tpd_ring[i].size, 8);
 	}
 	/* init RFD ring */
-	for (i = 0; i < num_rx_queues; i++) {
-		rfd_ring[i].dma = ring_header->dma + offset;
-		rfd_ring[i].desc = (u8 *) ring_header->desc + offset;
-		rfd_ring[i].size = sizeof(struct atl1c_rx_free_desc) *
-				rfd_ring[i].count;
-		offset += roundup(rfd_ring[i].size, 8);
-	}
+	rfd_ring->dma = ring_header->dma + offset;
+	rfd_ring->desc = (u8 *) ring_header->desc + offset;
+	rfd_ring->size = sizeof(struct atl1c_rx_free_desc) * rfd_ring->count;
+	offset += roundup(rfd_ring->size, 8);
 
 	/* init RRD ring */
-	for (i = 0; i < num_rx_queues; i++) {
-		rrd_ring[i].dma = ring_header->dma + offset;
-		rrd_ring[i].desc = (u8 *) ring_header->desc + offset;
-		rrd_ring[i].size = sizeof(struct atl1c_recv_ret_status) *
-				rrd_ring[i].count;
-		offset += roundup(rrd_ring[i].size, 8);
-	}
+	rrd_ring->dma = ring_header->dma + offset;
+	rrd_ring->desc = (u8 *) ring_header->desc + offset;
+	rrd_ring->size = sizeof(struct atl1c_recv_ret_status) *
+		rrd_ring->count;
+	offset += roundup(rrd_ring->size, 8);
 
 	adapter->smb.dma = ring_header->dma + offset;
 	adapter->smb.smb = (u8 *)ring_header->desc + offset;
@@ -1035,15 +989,12 @@ err_nomem:
 static void atl1c_configure_des_ring(struct atl1c_adapter *adapter)
 {
 	struct atl1c_hw *hw = &adapter->hw;
-	struct atl1c_rfd_ring *rfd_ring = (struct atl1c_rfd_ring *)
-				adapter->rfd_ring;
-	struct atl1c_rrd_ring *rrd_ring = (struct atl1c_rrd_ring *)
-				adapter->rrd_ring;
+	struct atl1c_rfd_ring *rfd_ring = &adapter->rfd_ring;
+	struct atl1c_rrd_ring *rrd_ring = &adapter->rrd_ring;
 	struct atl1c_tpd_ring *tpd_ring = (struct atl1c_tpd_ring *)
 				adapter->tpd_ring;
 	struct atl1c_cmb *cmb = (struct atl1c_cmb *) &adapter->cmb;
 	struct atl1c_smb *smb = (struct atl1c_smb *) &adapter->smb;
-	int i;
 	u32 data;
 
 	/* TPD */
@@ -1063,22 +1014,20 @@ static void atl1c_configure_des_ring(struct atl1c_adapter *adapter)
 
 	/* RFD */
 	AT_WRITE_REG(hw, REG_RX_BASE_ADDR_HI,
-			(u32)((rfd_ring[0].dma & AT_DMA_HI_ADDR_MASK) >> 32));
-	for (i = 0; i < adapter->num_rx_queues; i++)
-		AT_WRITE_REG(hw, atl1c_rfd_addr_lo_regs[i],
-			(u32)(rfd_ring[i].dma & AT_DMA_LO_ADDR_MASK));
+			(u32)((rfd_ring->dma & AT_DMA_HI_ADDR_MASK) >> 32));
+	AT_WRITE_REG(hw, REG_RFD0_HEAD_ADDR_LO,
+			(u32)(rfd_ring->dma & AT_DMA_LO_ADDR_MASK));
 
 	AT_WRITE_REG(hw, REG_RFD_RING_SIZE,
-			rfd_ring[0].count & RFD_RING_SIZE_MASK);
+			rfd_ring->count & RFD_RING_SIZE_MASK);
 	AT_WRITE_REG(hw, REG_RX_BUF_SIZE,
 			adapter->rx_buffer_len & RX_BUF_SIZE_MASK);
 
 	/* RRD */
-	for (i = 0; i < adapter->num_rx_queues; i++)
-		AT_WRITE_REG(hw, atl1c_rrd_addr_lo_regs[i],
-			(u32)(rrd_ring[i].dma & AT_DMA_LO_ADDR_MASK));
+	AT_WRITE_REG(hw, REG_RRD0_HEAD_ADDR_LO,
+			(u32)(rrd_ring->dma & AT_DMA_LO_ADDR_MASK));
 	AT_WRITE_REG(hw, REG_RRD_RING_SIZE,
-			(rrd_ring[0].count & RRD_RING_SIZE_MASK));
+			(rrd_ring->count & RRD_RING_SIZE_MASK));
 
 	/* CMB */
 	AT_WRITE_REG(hw, REG_CMB_BASE_ADDR_LO, cmb->dma & AT_DMA_LO_ADDR_MASK);
@@ -1152,21 +1101,7 @@ static void atl1c_configure_rx(struct atl1c_adapter *adapter)
 
 	if (hw->ctrl_flags & ATL1C_RX_IPV6_CHKSUM)
 		rxq_ctrl_data |= IPV6_CHKSUM_CTRL_EN;
-	if (hw->rss_type == atl1c_rss_ipv4)
-		rxq_ctrl_data |= RSS_HASH_IPV4;
-	if (hw->rss_type == atl1c_rss_ipv4_tcp)
-		rxq_ctrl_data |= RSS_HASH_IPV4_TCP;
-	if (hw->rss_type == atl1c_rss_ipv6)
-		rxq_ctrl_data |= RSS_HASH_IPV6;
-	if (hw->rss_type == atl1c_rss_ipv6_tcp)
-		rxq_ctrl_data |= RSS_HASH_IPV6_TCP;
-	if (hw->rss_type != atl1c_rss_disable)
-		rxq_ctrl_data |= RRS_HASH_CTRL_EN;
 
-	rxq_ctrl_data |= (hw->rss_mode & RSS_MODE_MASK) <<
-			RSS_MODE_SHIFT;
-	rxq_ctrl_data |= (hw->rss_hash_bits & RSS_HASH_BITS_MASK) <<
-			RSS_HASH_BITS_SHIFT;
 	if (hw->ctrl_flags & ATL1C_ASPM_CTRL_MON)
 		rxq_ctrl_data |= (ASPM_THRUPUT_LIMIT_1M &
 			ASPM_THRUPUT_LIMIT_MASK) << ASPM_THRUPUT_LIMIT_SHIFT;
@@ -1174,14 +1109,6 @@ static void atl1c_configure_rx(struct atl1c_adapter *adapter)
 	AT_WRITE_REG(hw, REG_RXQ_CTRL, rxq_ctrl_data);
 }
 
-static void atl1c_configure_rss(struct atl1c_adapter *adapter)
-{
-	struct atl1c_hw *hw = &adapter->hw;
-
-	AT_WRITE_REG(hw, REG_IDT_TABLE, hw->indirect_tab);
-	AT_WRITE_REG(hw, REG_BASE_CPU_NUMBER, hw->base_cpu);
-}
-
 static void atl1c_configure_dma(struct atl1c_adapter *adapter)
 {
 	struct atl1c_hw *hw = &adapter->hw;
@@ -1253,19 +1180,6 @@ static void atl1c_enable_rx_ctrl(struct atl1c_hw *hw)
 	u32 data;
 
 	AT_READ_REG(hw, REG_RXQ_CTRL, &data);
-	switch (hw->adapter->num_rx_queues) {
-	case 4:
-		data |= (RXQ3_CTRL_EN | RXQ2_CTRL_EN | RXQ1_CTRL_EN);
-		break;
-	case 3:
-		data |= (RXQ2_CTRL_EN | RXQ1_CTRL_EN);
-		break;
-	case 2:
-		data |= RXQ1_CTRL_EN;
-		break;
-	default:
-		break;
-	}
 	data |= RXQ_CTRL_EN;
 	AT_WRITE_REG(hw, REG_RXQ_CTRL, data);
 }
@@ -1544,7 +1458,6 @@ static int atl1c_configure(struct atl1c_adapter *adapter)
 
 	atl1c_configure_tx(adapter);
 	atl1c_configure_rx(adapter);
-	atl1c_configure_rss(adapter);
 	atl1c_configure_dma(adapter);
 
 	return 0;
@@ -1747,9 +1660,9 @@ static inline void atl1c_rx_checksum(struct atl1c_adapter *adapter,
 	skb_checksum_none_assert(skb);
 }
 
-static int atl1c_alloc_rx_buffer(struct atl1c_adapter *adapter, const int ringid)
+static int atl1c_alloc_rx_buffer(struct atl1c_adapter *adapter)
 {
-	struct atl1c_rfd_ring *rfd_ring = &adapter->rfd_ring[ringid];
+	struct atl1c_rfd_ring *rfd_ring = &adapter->rfd_ring;
 	struct pci_dev *pdev = adapter->pdev;
 	struct atl1c_buffer *buffer_info, *next_info;
 	struct sk_buff *skb;
@@ -1801,7 +1714,7 @@ static int atl1c_alloc_rx_buffer(struct atl1c_adapter *adapter, const int ringid
 		/* TODO: update mailbox here */
 		wmb();
 		rfd_ring->next_to_use = rfd_next_to_use;
-		AT_WRITE_REG(&adapter->hw, atl1c_rfd_prod_idx_regs[ringid],
+		AT_WRITE_REG(&adapter->hw, REG_MB_RFD0_PROD_IDX,
 			rfd_ring->next_to_use & MB_RFDX_PROD_IDX_MASK);
 	}
 
@@ -1840,7 +1753,7 @@ static void atl1c_clean_rfd(struct atl1c_rfd_ring *rfd_ring,
 	rfd_ring->next_to_clean = rfd_index;
 }
 
-static void atl1c_clean_rx_irq(struct atl1c_adapter *adapter, u8 que,
+static void atl1c_clean_rx_irq(struct atl1c_adapter *adapter,
 		   int *work_done, int work_to_do)
 {
 	u16 rfd_num, rfd_index;
@@ -1848,8 +1761,8 @@ static void atl1c_clean_rx_irq(struct atl1c_adapter *adapter, u8 que,
 	u16 length;
 	struct pci_dev *pdev = adapter->pdev;
 	struct net_device *netdev  = adapter->netdev;
-	struct atl1c_rfd_ring *rfd_ring = &adapter->rfd_ring[que];
-	struct atl1c_rrd_ring *rrd_ring = &adapter->rrd_ring[que];
+	struct atl1c_rfd_ring *rfd_ring = &adapter->rfd_ring;
+	struct atl1c_rrd_ring *rrd_ring = &adapter->rrd_ring;
 	struct sk_buff *skb;
 	struct atl1c_recv_ret_status *rrs;
 	struct atl1c_buffer *buffer_info;
@@ -1915,7 +1828,7 @@ rrs_checked:
 		count++;
 	}
 	if (count)
-		atl1c_alloc_rx_buffer(adapter, que);
+		atl1c_alloc_rx_buffer(adapter);
 }
 
 /*
@@ -1932,7 +1845,7 @@ static int atl1c_clean(struct napi_struct *napi, int budget)
 	if (!netif_carrier_ok(adapter->netdev))
 		goto quit_polling;
 	/* just enable one RXQ */
-	atl1c_clean_rx_irq(adapter, 0, &work_done, budget);
+	atl1c_clean_rx_irq(adapter, &work_done, budget);
 
 	if (work_done < budget) {
 quit_polling:
@@ -2334,19 +2247,16 @@ static int atl1c_up(struct atl1c_adapter *adapter)
 	struct net_device *netdev = adapter->netdev;
 	int num;
 	int err;
-	int i;
 
 	netif_carrier_off(netdev);
 	atl1c_init_ring_ptrs(adapter);
 	atl1c_set_multi(netdev);
 	atl1c_restore_vlan(adapter);
 
-	for (i = 0; i < adapter->num_rx_queues; i++) {
-		num = atl1c_alloc_rx_buffer(adapter, i);
-		if (unlikely(num == 0)) {
-			err = -ENOMEM;
-			goto err_alloc_rx;
-		}
+	num = atl1c_alloc_rx_buffer(adapter);
+	if (unlikely(num == 0)) {
+		err = -ENOMEM;
+		goto err_alloc_rx;
 	}
 
 	if (atl1c_configure(adapter)) {
-- 
1.7.7
