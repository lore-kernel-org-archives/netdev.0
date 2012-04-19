From: xiong <xiong@qca.qualcomm.com>
Subject: [PATCH 09/11] atl1c: refine atl1c_pcie_patch
Date: Thu, 19 Apr 2012 16:01:29 +0800
Message-ID: <1334822491-30129-10-git-send-email-xiong@qca.qualcomm.com>
References: <1334822491-30129-1-git-send-email-xiong@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <qca-linux-team@qualcomm.com>, <nic-devel@qualcomm.com>,
	xiong <xiong@qca.qualcomm.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1334822491-30129-1-git-send-email-xiong@qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

bit PCIE_PHYMISC_FORCE_RCV_DET is only for l1c&l2c to fix WoL issue,
other chips set bit5 of REG_MASTER_CTRL --- this way could save more
power than the former, and the bit should be kept all time.
l2cb 1.x has special setting for L0S/L1
l2cb 1.x & l1d 1.x should clear Vendor Message on some platforms,
otherwise it will cause the root complex hang.

Signed-off-by: xiong <xiong@qca.qualcomm.com>
Tested-by: Liu David <dwliu@qca.qualcomm.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_hw.h   |   17 ++++++--
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |   49 +++++++++++++++++------
 2 files changed, 48 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
index 5e49ea2..59051e7 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
@@ -96,17 +96,24 @@ int atl1c_phy_power_saving(struct atl1c_hw *hw);
 #define PCIE_DEV_MISC_SERDES_SEL_DIN   	0x10
 
 #define REG_PCIE_PHYMISC	    	0x1000
-#define PCIE_PHYMISC_FORCE_RCV_DET	0x4
+#define PCIE_PHYMISC_FORCE_RCV_DET	BIT(2)
+#define PCIE_PHYMISC_NFTS_MASK		0xFFUL
+#define PCIE_PHYMISC_NFTS_SHIFT		16
 
 #define REG_PCIE_PHYMISC2		0x1004
-#define PCIE_PHYMISC2_SERDES_CDR_MASK	0x3
-#define PCIE_PHYMISC2_SERDES_CDR_SHIFT	16
-#define PCIE_PHYMISC2_SERDES_TH_MASK	0x3
-#define PCIE_PHYMISC2_SERDES_TH_SHIFT	18
+#define PCIE_PHYMISC2_L0S_TH_MASK	0x3UL
+#define PCIE_PHYMISC2_L0S_TH_SHIFT	18
+#define L2CB1_PCIE_PHYMISC2_L0S_TH	3
+#define PCIE_PHYMISC2_CDR_BW_MASK	0x3UL
+#define PCIE_PHYMISC2_CDR_BW_SHIFT	16
+#define L2CB1_PCIE_PHYMISC2_CDR_BW	3
 
 #define REG_TWSI_DEBUG			0x1108
 #define TWSI_DEBUG_DEV_EXIST		0x20000000
 
+#define REG_DMA_DBG			0x1114
+#define DMA_DBG_VENDOR_MSG		BIT(0)
+
 #define REG_EEPROM_CTRL			0x12C0
 #define EEPROM_CTRL_DATA_HI_MASK	0xFFFF
 #define EEPROM_CTRL_DATA_HI_SHIFT	0
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 47fe6ad..17b91db 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -87,20 +87,37 @@ static void atl1c_pcie_patch(struct atl1c_hw *hw)
 	mst_data &= ~MASTER_CTRL_CLK_SEL_DIS;
 	AT_WRITE_REG(hw, REG_MASTER_CTRL, mst_data);
 
-	AT_READ_REG(hw, REG_PCIE_PHYMISC, &data);
-	data |= PCIE_PHYMISC_FORCE_RCV_DET;
-	AT_WRITE_REG(hw, REG_PCIE_PHYMISC, data);
-
+	/* WoL/PCIE related settings */
+	if (hw->nic_type == athr_l1c || hw->nic_type == athr_l2c) {
+		AT_READ_REG(hw, REG_PCIE_PHYMISC, &data);
+		data |= PCIE_PHYMISC_FORCE_RCV_DET;
+		AT_WRITE_REG(hw, REG_PCIE_PHYMISC, data);
+	} else { /* new dev set bit5 of MASTER */
+		if (!(mst_data & MASTER_CTRL_WAKEN_25M))
+			AT_WRITE_REG(hw, REG_MASTER_CTRL,
+				mst_data | MASTER_CTRL_WAKEN_25M);
+	}
+	/* aspm/PCIE setting only for l2cb 1.0 */
 	if (hw->nic_type == athr_l2c_b && hw->revision_id == L2CB_V10) {
 		AT_READ_REG(hw, REG_PCIE_PHYMISC2, &data);
-
-		data &= ~(PCIE_PHYMISC2_SERDES_CDR_MASK <<
-			PCIE_PHYMISC2_SERDES_CDR_SHIFT);
-		data |= 3 << PCIE_PHYMISC2_SERDES_CDR_SHIFT;
-		data &= ~(PCIE_PHYMISC2_SERDES_TH_MASK <<
-			PCIE_PHYMISC2_SERDES_TH_SHIFT);
-		data |= 3 << PCIE_PHYMISC2_SERDES_TH_SHIFT;
+		data = FIELD_SETX(data, PCIE_PHYMISC2_CDR_BW,
+			L2CB1_PCIE_PHYMISC2_CDR_BW);
+		data = FIELD_SETX(data, PCIE_PHYMISC2_L0S_TH,
+			L2CB1_PCIE_PHYMISC2_L0S_TH);
 		AT_WRITE_REG(hw, REG_PCIE_PHYMISC2, data);
+		/* extend L1 sync timer */
+		AT_READ_REG(hw, REG_LINK_CTRL, &data);
+		data |= LINK_CTRL_EXT_SYNC;
+		AT_WRITE_REG(hw, REG_LINK_CTRL, data);
+	}
+	/* l2cb 1.x & l1d 1.x */
+	if (hw->nic_type == athr_l2c_b || hw->nic_type == athr_l1d) {
+		AT_READ_REG(hw, REG_PM_CTRL, &data);
+		data |= PM_CTRL_L0S_BUFSRX_EN;
+		AT_WRITE_REG(hw, REG_PM_CTRL, data);
+		/* clear vendor msg */
+		AT_READ_REG(hw, REG_DMA_DBG, &data);
+		AT_WRITE_REG(hw, REG_DMA_DBG, data & ~DMA_DBG_VENDOR_MSG);
 	}
 }
 
@@ -1181,8 +1198,8 @@ static int atl1c_reset_mac(struct atl1c_hw *hw)
 	 */
 	AT_READ_REG(hw, REG_MASTER_CTRL, &master_ctrl_data);
 	master_ctrl_data |= MASTER_CTRL_OOB_DIS;
-	AT_WRITE_REGW(hw, REG_MASTER_CTRL, ((master_ctrl_data | MASTER_CTRL_SOFT_RST)
-			& 0xFFFF));
+	AT_WRITE_REG(hw, REG_MASTER_CTRL,
+		master_ctrl_data | MASTER_CTRL_SOFT_RST);
 
 	AT_WRITE_FLUSH(hw);
 	msleep(10);
@@ -1194,6 +1211,8 @@ static int atl1c_reset_mac(struct atl1c_hw *hw)
 			" disabled for 10ms second\n");
 		return -1;
 	}
+	AT_WRITE_REG(hw, REG_MASTER_CTRL, master_ctrl_data);
+
 	return 0;
 }
 
@@ -1338,6 +1357,10 @@ static int atl1c_configure(struct atl1c_adapter *adapter)
 	u32 intr_modrt_data;
 	u32 data;
 
+	AT_READ_REG(hw, REG_MASTER_CTRL, &master_ctrl_data);
+	master_ctrl_data &= ~(MASTER_CTRL_TX_ITIMER_EN |
+			      MASTER_CTRL_RX_ITIMER_EN |
+			      MASTER_CTRL_INT_RDCLR);
 	/* clear interrupt status */
 	AT_WRITE_REG(hw, REG_ISR, 0xFFFFFFFF);
 	/*  Clear any WOL status */
-- 
1.7.7
