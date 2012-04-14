From: xiong <xiong@qca.qualcomm.com>
Subject: [PATCH 11/12] atl1c: using fixed TXQ configuration for l2cb and l1c
Date: Sat, 14 Apr 2012 17:59:27 +0800
Message-ID: <1334397568-8444-12-git-send-email-xiong@qca.qualcomm.com>
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

using fixed TXQ config for l2cb and l1c regardless dmar_block
to make tx-DMA more stable.
register REG_TXQ_CTRL is refined as well.

Signed-off-by: xiong <xiong@qca.qualcomm.com>
Tested-by: Liu David <dwliu@qca.qualcomm.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_hw.h   |   34 +++++++++++++++++------
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |   13 ++-------
 2 files changed, 28 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
index f502b4d..a0b56ef 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
@@ -467,15 +467,31 @@ int atl1c_phy_power_saving(struct atl1c_hw *hw);
 #define TPD_RING_SIZE_MASK		0xFFFF
 
 /* TXQ Control Register */
-#define REG_TXQ_CTRL                	0x1590
-#define	TXQ_NUM_TPD_BURST_MASK     	0xF
-#define TXQ_NUM_TPD_BURST_SHIFT    	0
-#define TXQ_CTRL_IP_OPTION_EN		0x10
-#define TXQ_CTRL_EN                     0x20
-#define TXQ_CTRL_ENH_MODE               0x40
-#define TXQ_CTRL_LS_8023_EN		0x80
-#define TXQ_TXF_BURST_NUM_SHIFT    	16
-#define TXQ_TXF_BURST_NUM_MASK     	0xFFFF
+#define REG_TXQ_CTRL			0x1590
+#define TXQ_TXF_BURST_NUM_MASK          0xFFFFUL
+#define TXQ_TXF_BURST_NUM_SHIFT		16
+#define L1C_TXQ_TXF_BURST_PREF          0x200
+#define L2CB_TXQ_TXF_BURST_PREF         0x40
+#define TXQ_CTRL_PEDING_CLR             BIT(8)
+#define TXQ_CTRL_LS_8023_EN             BIT(7)
+#define TXQ_CTRL_ENH_MODE               BIT(6)
+#define TXQ_CTRL_EN                     BIT(5)
+#define TXQ_CTRL_IP_OPTION_EN           BIT(4)
+#define TXQ_NUM_TPD_BURST_MASK          0xFUL
+#define TXQ_NUM_TPD_BURST_SHIFT         0
+#define TXQ_NUM_TPD_BURST_DEF           5
+#define TXQ_CFGV			(\
+	FIELDX(TXQ_NUM_TPD_BURST, TXQ_NUM_TPD_BURST_DEF) |\
+	TXQ_CTRL_ENH_MODE |\
+	TXQ_CTRL_LS_8023_EN |\
+	TXQ_CTRL_IP_OPTION_EN)
+#define L1C_TXQ_CFGV			(\
+	TXQ_CFGV |\
+	FIELDX(TXQ_TXF_BURST_NUM, L1C_TXQ_TXF_BURST_PREF))
+#define L2CB_TXQ_CFGV			(\
+	TXQ_CFGV |\
+	FIELDX(TXQ_TXF_BURST_NUM, L2CB_TXQ_TXF_BURST_PREF))
+
 
 /* Jumbo packet Threshold for task offload */
 #define REG_TX_TSO_OFFLOAD_THRESH	0x1594 /* In 8-bytes */
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index d6ebaa4..8e737a5 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -1049,7 +1049,6 @@ static void atl1c_configure_tx(struct atl1c_adapter *adapter)
 	u32 max_pay_load;
 	u16 tx_offload_thresh;
 	u32 txq_ctrl_data;
-	u32 max_pay_load_data;
 
 	tx_offload_thresh = MAX_TX_OFFLOAD_THRESH;
 	AT_WRITE_REG(hw, REG_TX_TSO_OFFLOAD_THRESH,
@@ -1059,15 +1058,9 @@ static void atl1c_configure_tx(struct atl1c_adapter *adapter)
 			DEVICE_CTRL_MAX_RREQ_SZ_MASK;
 	hw->dmar_block = min_t(u32, max_pay_load, hw->dmar_block);
 
-	txq_ctrl_data = (hw->tpd_burst & TXQ_NUM_TPD_BURST_MASK) <<
-			TXQ_NUM_TPD_BURST_SHIFT;
-	if (hw->ctrl_flags & ATL1C_TXQ_MODE_ENHANCE)
-		txq_ctrl_data |= TXQ_CTRL_ENH_MODE;
-	max_pay_load_data = (atl1c_pay_load_size[hw->dmar_block] &
-			TXQ_TXF_BURST_NUM_MASK) << TXQ_TXF_BURST_NUM_SHIFT;
-	if (hw->nic_type == athr_l2c_b || hw->nic_type == athr_l2c_b2)
-		max_pay_load_data >>= 1;
-	txq_ctrl_data |= max_pay_load_data;
+	txq_ctrl_data =
+		hw->nic_type == athr_l2c_b || hw->nic_type == athr_l2c_b2 ?
+		L2CB_TXQ_CFGV : L1C_TXQ_CFGV;
 
 	AT_WRITE_REG(hw, REG_TXQ_CTRL, txq_ctrl_data);
 }
-- 
1.7.7
