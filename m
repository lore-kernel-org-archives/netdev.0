From: xiong <xiong@qca.qualcomm.com>
Subject: [PATCH 05/12] atl1c: remove SMB/CMB DMA related code
Date: Wed, 18 Apr 2012 13:32:29 +0800
Message-ID: <1334727156-6830-6-git-send-email-xiong@qca.qualcomm.com>
References: <1334727156-6830-1-git-send-email-xiong@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <qca-linux-team@qualcomm.com>, <nic-devel@qualcomm.com>,
	xiong <xiong@qca.qualcomm.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1334727156-6830-1-git-send-email-xiong@qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

l1c & later chips don't support DMA for SMB.
CMB is removed from hardware.
reg(15C8) is used to trig interrupt by tpd threshold.

Signed-off-by: xiong <xiong@qca.qualcomm.com>
Tested-by: Liu David <dwliu@qca.qualcomm.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c.h      |   19 +------------
 drivers/net/ethernet/atheros/atl1c/atl1c_hw.h   |   10 +-----
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |   34 ++---------------------
 3 files changed, 6 insertions(+), 57 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c.h b/drivers/net/ethernet/atheros/atl1c/atl1c.h
index cf82b74..93b5991 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c.h
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c.h
@@ -426,10 +426,6 @@ struct atl1c_hw {
 #define ATL1C_FPGA_VERSION              0x8000
 	u16 link_cap_flags;
 #define ATL1C_LINK_CAP_1000M		0x0001
-	u16 cmb_tpd;
-	u16 cmb_rrd;
-	u16 cmb_rx_timer; /* 2us resolution */
-	u16 cmb_tx_timer;
 	u32 smb_timer;
 
 	u16 rrd_thresh; /* Threshold of number of RRD produced to trigger
@@ -449,8 +445,7 @@ struct atl1c_hw {
 
 /*
  * atl1c_ring_header represents a single, contiguous block of DMA space
- * mapped for the three descriptor rings (tpd, rfd, rrd) and the two
- * message blocks (cmb, smb) described below
+ * mapped for the three descriptor rings (tpd, rfd, rrd) described below
  */
 struct atl1c_ring_header {
 	void *desc;		/* virtual address */
@@ -524,16 +519,6 @@ struct atl1c_rrd_ring {
 	u16 next_to_clean;
 };
 
-struct atl1c_cmb {
-	void *cmb;
-	dma_addr_t dma;
-};
-
-struct atl1c_smb {
-	void *smb;
-	dma_addr_t dma;
-};
-
 /* board specific private data structure */
 struct atl1c_adapter {
 	struct net_device   *netdev;
@@ -571,8 +556,6 @@ struct atl1c_adapter {
 	struct atl1c_tpd_ring tpd_ring[AT_MAX_TRANSMIT_QUEUE];
 	struct atl1c_rfd_ring rfd_ring;
 	struct atl1c_rrd_ring rrd_ring;
-	struct atl1c_cmb cmb;
-	struct atl1c_smb smb;
 	u32 bd_number;     /* board number;*/
 };
 
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
index f5c7473..caff2ae 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
@@ -447,8 +447,6 @@ int atl1c_phy_power_saving(struct atl1c_hw *hw);
  */
 #define REG_RX_BASE_ADDR_HI		0x1540
 #define REG_TX_BASE_ADDR_HI		0x1544
-#define REG_SMB_BASE_ADDR_HI		0x1548
-#define REG_SMB_BASE_ADDR_LO		0x154C
 #define REG_RFD0_HEAD_ADDR_LO		0x1550
 #define REG_RFD_RING_SIZE		0x1560
 #define RFD_RING_SIZE_MASK		0x0FFF
@@ -461,7 +459,6 @@ int atl1c_phy_power_saving(struct atl1c_hw *hw);
 #define REG_NTPD_HEAD_ADDR_LO		0x1580
 #define REG_TPD_RING_SIZE		0x1584
 #define TPD_RING_SIZE_MASK		0xFFFF
-#define REG_CMB_BASE_ADDR_LO		0x1588
 
 /* TXQ Control Register */
 #define REG_TXQ_CTRL                	0x1590
@@ -556,13 +553,10 @@ int atl1c_phy_power_saving(struct atl1c_hw *hw);
 #define MAC_CTRL_SMB_DIS		0x1000000
 #define DMA_CTRL_SMB_NOW		0x80000000
 
-/* CMB/SMB Control Register */
+/* INT-triggle/SMB Control Register */
 #define REG_SMB_STAT_TIMER		0x15C4	/* 2us resolution */
 #define SMB_STAT_TIMER_MASK		0xFFFFFF
-#define REG_CMB_TPD_THRESH		0x15C8
-#define CMB_TPD_THRESH_MASK		0xFFFF
-#define REG_CMB_TX_TIMER		0x15CC	/* 2us resolution */
-#define CMB_TX_TIMER_MASK		0xFFFF
+#define REG_TINT_TPD_THRESH             0x15C8 /* tpd th to trig intrrupt */
 
 /* Mail box */
 #define MB_RFDX_PROD_IDX_MASK		0xFFFF
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 885e892..ceb9df5 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -733,8 +733,6 @@ static int __devinit atl1c_sw_init(struct atl1c_adapter *adapter)
 
 	hw->ict = 50000;		/* 100ms */
 	hw->smb_timer = 200000;	  	/* 400ms */
-	hw->cmb_tpd = 4;
-	hw->cmb_tx_timer = 1;		/* 2 us  */
 	hw->rx_imt = 200;
 	hw->tx_imt = 1000;
 
@@ -943,8 +941,7 @@ static int atl1c_setup_ring_resources(struct atl1c_adapter *adapter)
 		sizeof(struct atl1c_tpd_desc) * tpd_ring->count * 2 +
 		sizeof(struct atl1c_rx_free_desc) * rx_desc_count +
 		sizeof(struct atl1c_recv_ret_status) * rx_desc_count +
-		sizeof(struct atl1c_hw_stats) +
-		8 * 4 + 8 * 2;
+		8 * 4;
 
 	ring_header->desc = pci_alloc_consistent(pdev, ring_header->size,
 				&ring_header->dma);
@@ -977,8 +974,6 @@ static int atl1c_setup_ring_resources(struct atl1c_adapter *adapter)
 		rrd_ring->count;
 	offset += roundup(rrd_ring->size, 8);
 
-	adapter->smb.dma = ring_header->dma + offset;
-	adapter->smb.smb = (u8 *)ring_header->desc + offset;
 	return 0;
 
 err_nomem:
@@ -993,8 +988,6 @@ static void atl1c_configure_des_ring(struct atl1c_adapter *adapter)
 	struct atl1c_rrd_ring *rrd_ring = &adapter->rrd_ring;
 	struct atl1c_tpd_ring *tpd_ring = (struct atl1c_tpd_ring *)
 				adapter->tpd_ring;
-	struct atl1c_cmb *cmb = (struct atl1c_cmb *) &adapter->cmb;
-	struct atl1c_smb *smb = (struct atl1c_smb *) &adapter->smb;
 	u32 data;
 
 	/* TPD */
@@ -1029,14 +1022,6 @@ static void atl1c_configure_des_ring(struct atl1c_adapter *adapter)
 	AT_WRITE_REG(hw, REG_RRD_RING_SIZE,
 			(rrd_ring->count & RRD_RING_SIZE_MASK));
 
-	/* CMB */
-	AT_WRITE_REG(hw, REG_CMB_BASE_ADDR_LO, cmb->dma & AT_DMA_LO_ADDR_MASK);
-
-	/* SMB */
-	AT_WRITE_REG(hw, REG_SMB_BASE_ADDR_HI,
-			(u32)((smb->dma & AT_DMA_HI_ADDR_MASK) >> 32));
-	AT_WRITE_REG(hw, REG_SMB_BASE_ADDR_LO,
-			(u32)(smb->dma & AT_DMA_LO_ADDR_MASK));
 	if (hw->nic_type == athr_l2c_b) {
 		AT_WRITE_REG(hw, REG_SRAM_RXF_LEN, 0x02a0L);
 		AT_WRITE_REG(hw, REG_SRAM_TXF_LEN, 0x0100L);
@@ -1115,12 +1100,6 @@ static void atl1c_configure_dma(struct atl1c_adapter *adapter)
 	u32 dma_ctrl_data;
 
 	dma_ctrl_data = DMA_CTRL_DMAR_REQ_PRI;
-	if (hw->ctrl_flags & ATL1C_CMB_ENABLE)
-		dma_ctrl_data |= DMA_CTRL_CMB_EN;
-	if (hw->ctrl_flags & ATL1C_SMB_ENABLE)
-		dma_ctrl_data |= DMA_CTRL_SMB_EN;
-	else
-		dma_ctrl_data |= MAC_CTRL_SMB_DIS;
 
 	switch (hw->dma_order) {
 	case atl1c_dma_ord_in:
@@ -1440,16 +1419,9 @@ static int atl1c_configure(struct atl1c_adapter *adapter)
 	master_ctrl_data |= MASTER_CTRL_SA_TIMER_EN;
 	AT_WRITE_REG(hw, REG_MASTER_CTRL, master_ctrl_data);
 
-	if (hw->ctrl_flags & ATL1C_CMB_ENABLE) {
-		AT_WRITE_REG(hw, REG_CMB_TPD_THRESH,
-			hw->cmb_tpd & CMB_TPD_THRESH_MASK);
-		AT_WRITE_REG(hw, REG_CMB_TX_TIMER,
-			hw->cmb_tx_timer & CMB_TX_TIMER_MASK);
-	}
+	AT_WRITE_REG(hw, REG_SMB_STAT_TIMER,
+		hw->smb_timer & SMB_STAT_TIMER_MASK);
 
-	if (hw->ctrl_flags & ATL1C_SMB_ENABLE)
-		AT_WRITE_REG(hw, REG_SMB_STAT_TIMER,
-			hw->smb_timer & SMB_STAT_TIMER_MASK);
 	/* set MTU */
 	AT_WRITE_REG(hw, REG_MTU, hw->max_frame_size + ETH_HLEN +
 			VLAN_HLEN + ETH_FCS_LEN);
-- 
1.7.7
