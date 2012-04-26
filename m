From: xiong <xiong@qca.qualcomm.com>
Subject: [PATCH 04/10] atl1c: refine SERDES-clock related code
Date: Thu, 26 Apr 2012 14:27:12 +0800
Message-ID: <1335421638-16304-5-git-send-email-xiong@qca.qualcomm.com>
References: <1335421638-16304-1-git-send-email-xiong@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <qca-linux-team@qualcomm.com>, <nic-devel@qualcomm.com>,
	xiong <xiong@qca.qualcomm.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:17482 "EHLO
	wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754119Ab2DZG2d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 02:28:33 -0400
In-Reply-To: <1335421638-16304-1-git-send-email-xiong@qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bit 17/18 of reg1424 must be clear for l2cb 1.x, or it will cause
the write-reg operation fail without cable connected.
so, please do connect the cable when apply this patch to the driver
to make sure these 2bits are cleared by new driver.
The revised code is move to al1c_reset_mac.
SERDES register definition is refined as well.

when do reset MAC, speed/duplex control right should be transferred
to software before do PHY auto-neg -- by bit MASTER_CTRL_SPEED_MODE_SW.
SERDES register definition is refined as well.

Signed-off-by: xiong <xiong@qca.qualcomm.com>
Tested-by: Liu David <dwliu@qca.qualcomm.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_ethtool.c |    2 +-
 drivers/net/ethernet/atheros/atl1c/atl1c_hw.h      |   34 +++++++++++------
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c    |   40 +++++++++++++-------
 3 files changed, 49 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_ethtool.c b/drivers/net/ethernet/atheros/atl1c/atl1c_ethtool.c
index 3feb846..859ea84 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_ethtool.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_ethtool.c
@@ -153,7 +153,7 @@ static void atl1c_get_regs(struct net_device *netdev,
 	AT_READ_REG(hw, REG_LINK_CTRL, 		  p++);
 	AT_READ_REG(hw, REG_IDLE_STATUS, 	  p++);
 	AT_READ_REG(hw, REG_MDIO_CTRL, 		  p++);
-	AT_READ_REG(hw, REG_SERDES_LOCK, 	  p++);
+	AT_READ_REG(hw, REG_SERDES,		  p++);
 	AT_READ_REG(hw, REG_MAC_CTRL, 		  p++);
 	AT_READ_REG(hw, REG_MAC_IPG_IFG, 	  p++);
 	AT_READ_REG(hw, REG_MAC_STA_ADDR, 	  p++);
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
index cb2d20b..113e67b 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
@@ -327,18 +327,28 @@ int atl1c_write_phy_ext(struct atl1c_hw *hw, u8 dev_addr,
 #define BIST1_FUSE_FLAG             	0x4
 
 /* SerDes Lock Detect Control and Status Register */
-#define REG_SERDES_LOCK            	0x1424
-#define SERDES_LOCK_DETECT          	0x1  /* SerDes lock detected. This signal
-					      * comes from Analog SerDes */
-#define SERDES_LOCK_DETECT_EN       	0x2  /* 1: Enable SerDes Lock detect function */
-#define SERDES_LOCK_STS_SELFB_PLL_SHIFT 0xE
-#define SERDES_LOCK_STS_SELFB_PLL_MASK  0x3
-#define SERDES_OVCLK_18_25		0x0
-#define SERDES_OVCLK_12_18		0x1
-#define SERDES_OVCLK_0_4		0x2
-#define SERDES_OVCLK_4_12		0x3
-#define SERDES_MAC_CLK_SLOWDOWN		0x20000
-#define SERDES_PYH_CLK_SLOWDOWN		0x40000
+#define REG_SERDES			0x1424
+#define SERDES_PHY_CLK_SLOWDOWN		BIT(18)
+#define SERDES_MAC_CLK_SLOWDOWN		BIT(17)
+#define SERDES_SELFB_PLL_MASK		0x3UL
+#define SERDES_SELFB_PLL_SHIFT		14
+#define SERDES_PHYCLK_SEL_GTX		BIT(13)	/* 1:gtx_clk, 0:25M */
+#define SERDES_PCIECLK_SEL_SRDS		BIT(12)	/* 1:serdes,0:25M */
+#define SERDES_BUFS_RX_EN		BIT(11)
+#define SERDES_PD_RX			BIT(10)
+#define SERDES_PLL_EN			BIT(9)
+#define SERDES_EN			BIT(8)
+#define SERDES_SELFB_PLL_SEL_CSR	BIT(6)	/* 0:state-machine,1:csr */
+#define SERDES_SELFB_PLL_CSR_MASK	0x3UL
+#define SERDES_SELFB_PLL_CSR_SHIFT	4
+#define SERDES_SELFB_PLL_CSR_4		3	/* 4-12% OV-CLK */
+#define SERDES_SELFB_PLL_CSR_0		2	/* 0-4% OV-CLK */
+#define SERDES_SELFB_PLL_CSR_12		1	/* 12-18% OV-CLK */
+#define SERDES_SELFB_PLL_CSR_18		0	/* 18-25% OV-CLK */
+#define SERDES_VCO_SLOW			BIT(3)
+#define SERDES_VCO_FAST			BIT(2)
+#define SERDES_LOCK_DETECT_EN		BIT(1)
+#define SERDES_LOCK_DETECT		BIT(0)
 
 /* MAC Control Register  */
 #define REG_MAC_CTRL         		0x1480
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index f0f348b..cf78287 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -1008,7 +1008,6 @@ static void atl1c_configure_des_ring(struct atl1c_adapter *adapter)
 	struct atl1c_rrd_ring *rrd_ring = &adapter->rrd_ring;
 	struct atl1c_tpd_ring *tpd_ring = (struct atl1c_tpd_ring *)
 				adapter->tpd_ring;
-	u32 data;
 
 	/* TPD */
 	AT_WRITE_REG(hw, REG_TX_BASE_ADDR_HI,
@@ -1052,13 +1051,6 @@ static void atl1c_configure_des_ring(struct atl1c_adapter *adapter)
 		AT_WRITE_REG(hw, REG_TXF_WATER_MARK, 0);	/* TX watermark, to enter l1 state.*/
 		AT_WRITE_REG(hw, REG_RXD_DMA_CTRL, 0);		/* RXD threshold.*/
 	}
-	if (hw->nic_type == athr_l2c_b || hw->nic_type == athr_l1d_2) {
-			/* Power Saving for L2c_B */
-		AT_READ_REG(hw, REG_SERDES_LOCK, &data);
-		data |= SERDES_MAC_CLK_SLOWDOWN;
-		data |= SERDES_PYH_CLK_SLOWDOWN;
-		AT_WRITE_REG(hw, REG_SERDES_LOCK, data);
-	}
 	/* Load all of base address above */
 	AT_WRITE_REG(hw, REG_LOAD_PTR, 1);
 }
@@ -1177,7 +1169,7 @@ static int atl1c_reset_mac(struct atl1c_hw *hw)
 {
 	struct atl1c_adapter *adapter = (struct atl1c_adapter *)hw->adapter;
 	struct pci_dev *pdev = adapter->pdev;
-	u32 master_ctrl_data = 0;
+	u32 ctrl_data = 0;
 
 	AT_WRITE_REG(hw, REG_IMR, 0);
 	AT_WRITE_REG(hw, REG_ISR, ISR_DIS_INT);
@@ -1189,10 +1181,9 @@ static int atl1c_reset_mac(struct atl1c_hw *hw)
 	 * the current PCI configuration.  The global reset bit is self-
 	 * clearing, and should clear within a microsecond.
 	 */
-	AT_READ_REG(hw, REG_MASTER_CTRL, &master_ctrl_data);
-	master_ctrl_data |= MASTER_CTRL_OOB_DIS;
-	AT_WRITE_REG(hw, REG_MASTER_CTRL,
-		master_ctrl_data | MASTER_CTRL_SOFT_RST);
+	AT_READ_REG(hw, REG_MASTER_CTRL, &ctrl_data);
+	ctrl_data |= MASTER_CTRL_OOB_DIS;
+	AT_WRITE_REG(hw, REG_MASTER_CTRL, ctrl_data | MASTER_CTRL_SOFT_RST);
 
 	AT_WRITE_FLUSH(hw);
 	msleep(10);
@@ -1204,7 +1195,28 @@ static int atl1c_reset_mac(struct atl1c_hw *hw)
 			" disabled for 10ms second\n");
 		return -1;
 	}
-	AT_WRITE_REG(hw, REG_MASTER_CTRL, master_ctrl_data);
+	AT_WRITE_REG(hw, REG_MASTER_CTRL, ctrl_data);
+
+	/* driver control speed/duplex */
+	AT_READ_REG(hw, REG_MAC_CTRL, &ctrl_data);
+	AT_WRITE_REG(hw, REG_MAC_CTRL, ctrl_data | MAC_CTRL_SPEED_MODE_SW);
+
+	/* clk switch setting */
+	AT_READ_REG(hw, REG_SERDES, &ctrl_data);
+	switch (hw->nic_type) {
+	case athr_l2c_b:
+		ctrl_data &= ~(SERDES_PHY_CLK_SLOWDOWN |
+				SERDES_MAC_CLK_SLOWDOWN);
+		AT_WRITE_REG(hw, REG_SERDES, ctrl_data);
+		break;
+	case athr_l2c_b2:
+	case athr_l1d_2:
+		ctrl_data |= SERDES_PHY_CLK_SLOWDOWN | SERDES_MAC_CLK_SLOWDOWN;
+		AT_WRITE_REG(hw, REG_SERDES, ctrl_data);
+		break;
+	default:
+		break;
+	}
 
 	return 0;
 }
-- 
1.7.7
