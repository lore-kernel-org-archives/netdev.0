From: xiong <xiong@qca.qualcomm.com>
Subject: [PATCH 09/12] atl1c: correct wrong definition of REG_DMA_CTRL
Date: Sat, 14 Apr 2012 17:59:25 +0800
Message-ID: <1334397568-8444-10-git-send-email-xiong@qca.qualcomm.com>
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

some fields of REG_DMA_CTRL(15C0) are wrong, replace with the newest one.
haredware uses fixed dma-write-block size, remove dmaw_block related code
in function atl1c_configure_dma.

Signed-off-by: xiong <xiong@qca.qualcomm.com>
Tested-by: Liu David <dwliu@qca.qualcomm.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_hw.h   |   46 +++++++++++++---------
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |   29 ++------------
 2 files changed, 32 insertions(+), 43 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
index 18c1f18..f502b4d 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
@@ -25,6 +25,12 @@
 #include <linux/types.h>
 #include <linux/mii.h>
 
+#define FIELD_GETX(_x, _name)   ((_x) >> (_name##_SHIFT) & (_name##_MASK))
+#define FIELD_SETX(_x, _name, _v) \
+(((_x) & ~((_name##_MASK) << (_name##_SHIFT))) |\
+(((_v) & (_name##_MASK)) << (_name##_SHIFT)))
+#define FIELDX(_name, _v) (((_v) & (_name##_MASK)) << (_name##_SHIFT))
+
 struct atl1c_adapter;
 struct atl1c_hw;
 
@@ -528,25 +534,27 @@ int atl1c_phy_power_saving(struct atl1c_hw *hw);
 #define RXD_DMA_DOWN_TIMER_SHIFT	16
 
 /* DMA Engine Control Register */
-#define REG_DMA_CTRL                	0x15C0
-#define DMA_CTRL_DMAR_IN_ORDER          0x1
-#define DMA_CTRL_DMAR_ENH_ORDER         0x2
-#define DMA_CTRL_DMAR_OUT_ORDER         0x4
-#define DMA_CTRL_RCB_VALUE              0x8
-#define DMA_CTRL_DMAR_BURST_LEN_MASK    0x0007
-#define DMA_CTRL_DMAR_BURST_LEN_SHIFT   4
-#define DMA_CTRL_DMAW_BURST_LEN_MASK    0x0007
-#define DMA_CTRL_DMAW_BURST_LEN_SHIFT   7
-#define DMA_CTRL_DMAR_REQ_PRI           0x400
-#define DMA_CTRL_DMAR_DLY_CNT_MASK      0x001F
-#define DMA_CTRL_DMAR_DLY_CNT_SHIFT     11
-#define DMA_CTRL_DMAW_DLY_CNT_MASK      0x000F
-#define DMA_CTRL_DMAW_DLY_CNT_SHIFT     16
-#define DMA_CTRL_CMB_EN               	0x100000
-#define DMA_CTRL_SMB_EN			0x200000
-#define DMA_CTRL_CMB_NOW		0x400000
-#define MAC_CTRL_SMB_DIS		0x1000000
-#define DMA_CTRL_SMB_NOW		0x80000000
+#define REG_DMA_CTRL			0x15C0
+#define DMA_CTRL_SMB_NOW                BIT(31)
+#define DMA_CTRL_WPEND_CLR              BIT(30)
+#define DMA_CTRL_RPEND_CLR              BIT(29)
+#define DMA_CTRL_WDLY_CNT_MASK          0xFUL
+#define DMA_CTRL_WDLY_CNT_SHIFT         16
+#define DMA_CTRL_WDLY_CNT_DEF           4
+#define DMA_CTRL_RDLY_CNT_MASK          0x1FUL
+#define DMA_CTRL_RDLY_CNT_SHIFT         11
+#define DMA_CTRL_RDLY_CNT_DEF           15
+#define DMA_CTRL_RREQ_PRI_DATA          BIT(10)      /* 0:tpd, 1:data */
+#define DMA_CTRL_WREQ_BLEN_MASK         7UL
+#define DMA_CTRL_WREQ_BLEN_SHIFT        7
+#define DMA_CTRL_RREQ_BLEN_MASK         7UL
+#define DMA_CTRL_RREQ_BLEN_SHIFT        4
+#define L1C_CTRL_DMA_RCB_LEN128         BIT(3)   /* 0:64bytes,1:128bytes */
+#define DMA_CTRL_RORDER_MODE_MASK       7UL
+#define DMA_CTRL_RORDER_MODE_SHIFT      0
+#define DMA_CTRL_RORDER_MODE_OUT        4
+#define DMA_CTRL_RORDER_MODE_ENHANCE    2
+#define DMA_CTRL_RORDER_MODE_IN         1
 
 /* INT-triggle/SMB Control Register */
 #define REG_SMB_STAT_TIMER		0x15C4	/* 2us resolution */
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index b36c033..1ce48d0 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -1099,30 +1099,11 @@ static void atl1c_configure_dma(struct atl1c_adapter *adapter)
 	struct atl1c_hw *hw = &adapter->hw;
 	u32 dma_ctrl_data;
 
-	dma_ctrl_data = DMA_CTRL_DMAR_REQ_PRI;
-
-	switch (hw->dma_order) {
-	case atl1c_dma_ord_in:
-		dma_ctrl_data |= DMA_CTRL_DMAR_IN_ORDER;
-		break;
-	case atl1c_dma_ord_enh:
-		dma_ctrl_data |= DMA_CTRL_DMAR_ENH_ORDER;
-		break;
-	case atl1c_dma_ord_out:
-		dma_ctrl_data |= DMA_CTRL_DMAR_OUT_ORDER;
-		break;
-	default:
-		break;
-	}
-
-	dma_ctrl_data |= (((u32)hw->dmar_block) & DMA_CTRL_DMAR_BURST_LEN_MASK)
-		<< DMA_CTRL_DMAR_BURST_LEN_SHIFT;
-	dma_ctrl_data |= (((u32)hw->dmaw_block) & DMA_CTRL_DMAW_BURST_LEN_MASK)
-		<< DMA_CTRL_DMAW_BURST_LEN_SHIFT;
-	dma_ctrl_data |= (((u32)hw->dmar_dly_cnt) & DMA_CTRL_DMAR_DLY_CNT_MASK)
-		<< DMA_CTRL_DMAR_DLY_CNT_SHIFT;
-	dma_ctrl_data |= (((u32)hw->dmaw_dly_cnt) & DMA_CTRL_DMAW_DLY_CNT_MASK)
-		<< DMA_CTRL_DMAW_DLY_CNT_SHIFT;
+	dma_ctrl_data = FIELDX(DMA_CTRL_RORDER_MODE, DMA_CTRL_RORDER_MODE_OUT) |
+		DMA_CTRL_RREQ_PRI_DATA |
+		FIELDX(DMA_CTRL_RREQ_BLEN, hw->dmar_block) |
+		FIELDX(DMA_CTRL_WDLY_CNT, DMA_CTRL_WDLY_CNT_DEF) |
+		FIELDX(DMA_CTRL_RDLY_CNT, DMA_CTRL_RDLY_CNT_DEF);
 
 	AT_WRITE_REG(hw, REG_DMA_CTRL, dma_ctrl_data);
 }
-- 
1.7.7
