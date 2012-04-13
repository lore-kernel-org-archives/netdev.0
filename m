From: xiong <xiong@qca.qualcomm.com>
Subject: [PATCH 06/37] atl1c: split 2 32bit registers of TPD to 4 16bit registers
Date: Fri, 13 Apr 2012 08:14:31 +0800
Message-ID: <1334276102-15866-7-git-send-email-xiong@qca.qualcomm.com>
References: <1334276102-15866-1-git-send-email-xiong@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <qca-linux-team@qualcomm.com>, <nic-devel@qualcomm.com>,
	xiong <xiong@qca.qualcomm.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1334276102-15866-1-git-send-email-xiong@qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

TPD producer/consumer index is 16bit wide.
16bit read/write reduce the dependency of the 2 tpd rings (hi and lo) 
rename reg(157C/1580) to keep name coninsistency.

Signed-off-by: xiong <xiong@qca.qualcomm.com>
Tested-by: Liu David <dwliu@qca.qualcomm.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c.h      |   10 +++++-
 drivers/net/ethernet/atheros/atl1c/atl1c_hw.h   |   17 ++++-------
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |   34 +++++-----------------
 3 files changed, 22 insertions(+), 39 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c.h b/drivers/net/ethernet/atheros/atl1c/atl1c.h
index f8628bc..16a5c7a 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c.h
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c.h
@@ -583,8 +583,14 @@ struct atl1c_adapter {
 #define AT_WRITE_REGW(a, reg, value) (\
 		writew((value), ((a)->hw_addr + reg)))
 
-#define AT_READ_REGW(a, reg) (\
-		readw((a)->hw_addr + reg))
+#define AT_READ_REGW(a, reg, pdata) do {				\
+		if (unlikely((a)->hibernate)) {				\
+			readw((a)->hw_addr + reg);			\
+			*(u16 *)pdata = readw((a)->hw_addr + reg);	\
+		} else {						\
+			*(u16 *)pdata = readw((a)->hw_addr + reg);	\
+		}							\
+	} while (0)
 
 #define AT_WRITE_REG_ARRAY(a, reg, offset, value) ( \
 		writel((value), (((a)->hw_addr + reg) + ((offset) << 2))))
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
index caff2ae..ca45fad 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
@@ -455,8 +455,8 @@ int atl1c_phy_power_saving(struct atl1c_hw *hw);
 #define REG_RRD0_HEAD_ADDR_LO		0x1568
 #define REG_RRD_RING_SIZE		0x1578
 #define RRD_RING_SIZE_MASK		0x0FFF
-#define REG_HTPD_HEAD_ADDR_LO		0x157C
-#define REG_NTPD_HEAD_ADDR_LO		0x1580
+#define REG_TPD_PRI1_ADDR_LO		0x157C
+#define REG_TPD_PRI0_ADDR_LO		0x1580
 #define REG_TPD_RING_SIZE		0x1584
 #define TPD_RING_SIZE_MASK		0xFFFF
 
@@ -562,15 +562,10 @@ int atl1c_phy_power_saving(struct atl1c_hw *hw);
 #define MB_RFDX_PROD_IDX_MASK		0xFFFF
 #define REG_MB_RFD0_PROD_IDX		0x15E0
 
-#define MB_PRIO_PROD_IDX_MASK		0xFFFF
-#define REG_MB_PRIO_PROD_IDX		0x15F0
-#define MB_HTPD_PROD_IDX_SHIFT		0
-#define MB_NTPD_PROD_IDX_SHIFT		16
-
-#define MB_PRIO_CONS_IDX_MASK		0xFFFF
-#define REG_MB_PRIO_CONS_IDX		0x15F4
-#define MB_HTPD_CONS_IDX_SHIFT		0
-#define MB_NTPD_CONS_IDX_SHIFT		16
+#define REG_TPD_PRI1_PIDX               0x15F0	/* 16bit,hi-tpd producer idx */
+#define REG_TPD_PRI0_PIDX		0x15F2	/* 16bit,lo-tpd producer idx */
+#define REG_TPD_PRI1_CIDX		0x15F4	/* 16bit,hi-tpd consumer idx */
+#define REG_TPD_PRI0_CIDX		0x15F6	/* 16bit,lo-tpd consumer idx */
 
 #define REG_MB_RFD01_CONS_IDX		0x15F8
 #define MB_RFD0_CONS_IDX_MASK		0x0000FFFF
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index ceb9df5..c7d7640 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -995,10 +995,10 @@ static void atl1c_configure_des_ring(struct atl1c_adapter *adapter)
 			(u32)((tpd_ring[atl1c_trans_normal].dma &
 				AT_DMA_HI_ADDR_MASK) >> 32));
 	/* just enable normal priority TX queue */
-	AT_WRITE_REG(hw, REG_NTPD_HEAD_ADDR_LO,
+	AT_WRITE_REG(hw, REG_TPD_PRI0_ADDR_LO,
 			(u32)(tpd_ring[atl1c_trans_normal].dma &
 				AT_DMA_LO_ADDR_MASK));
-	AT_WRITE_REG(hw, REG_HTPD_HEAD_ADDR_LO,
+	AT_WRITE_REG(hw, REG_TPD_PRI1_ADDR_LO,
 			(u32)(tpd_ring[atl1c_trans_high].dma &
 				AT_DMA_LO_ADDR_MASK));
 	AT_WRITE_REG(hw, REG_TPD_RING_SIZE,
@@ -1519,16 +1519,11 @@ static bool atl1c_clean_tx_irq(struct atl1c_adapter *adapter,
 	struct pci_dev *pdev = adapter->pdev;
 	u16 next_to_clean = atomic_read(&tpd_ring->next_to_clean);
 	u16 hw_next_to_clean;
-	u16 shift;
-	u32 data;
+	u16 reg;
 
-	if (type == atl1c_trans_high)
-		shift = MB_HTPD_CONS_IDX_SHIFT;
-	else
-		shift = MB_NTPD_CONS_IDX_SHIFT;
+	reg = type == atl1c_trans_high ? REG_TPD_PRI1_CIDX : REG_TPD_PRI0_CIDX;
 
-	AT_READ_REG(&adapter->hw, REG_MB_PRIO_CONS_IDX, &data);
-	hw_next_to_clean = (data >> shift) & MB_PRIO_PROD_IDX_MASK;
+	AT_READ_REGW(&adapter->hw, reg, &hw_next_to_clean);
 
 	while (next_to_clean != hw_next_to_clean) {
 		buffer_info = &tpd_ring->buffer_info[next_to_clean];
@@ -2090,23 +2085,10 @@ static void atl1c_tx_queue(struct atl1c_adapter *adapter, struct sk_buff *skb,
 			   struct atl1c_tpd_desc *tpd, enum atl1c_trans_queue type)
 {
 	struct atl1c_tpd_ring *tpd_ring = &adapter->tpd_ring[type];
-	u32 prod_data;
+	u16 reg;
 
-	AT_READ_REG(&adapter->hw, REG_MB_PRIO_PROD_IDX, &prod_data);
-	switch (type) {
-	case atl1c_trans_high:
-		prod_data &= 0xFFFF0000;
-		prod_data |= tpd_ring->next_to_use & 0xFFFF;
-		break;
-	case atl1c_trans_normal:
-		prod_data &= 0x0000FFFF;
-		prod_data |= (tpd_ring->next_to_use & 0xFFFF) << 16;
-		break;
-	default:
-		break;
-	}
-	wmb();
-	AT_WRITE_REG(&adapter->hw, REG_MB_PRIO_PROD_IDX, prod_data);
+	reg = type == atl1c_trans_high ? REG_TPD_PRI1_PIDX : REG_TPD_PRI0_PIDX;
+	AT_WRITE_REGW(&adapter->hw, reg, tpd_ring->next_to_use);
 }
 
 static netdev_tx_t atl1c_xmit_frame(struct sk_buff *skb,
-- 
1.7.7
