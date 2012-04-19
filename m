From: xiong <xiong@qca.qualcomm.com>
Subject: [PATCH 08/11] atl1c: refine/update ASPM configuration
Date: Thu, 19 Apr 2012 16:01:28 +0800
Message-ID: <1334822491-30129-9-git-send-email-xiong@qca.qualcomm.com>
References: <1334822491-30129-1-git-send-email-xiong@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <qca-linux-team@qualcomm.com>, <nic-devel@qualcomm.com>,
	xiong <xiong@qca.qualcomm.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:25500 "EHLO
	wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754587Ab2DSICp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 04:02:45 -0400
In-Reply-To: <1334822491-30129-1-git-send-email-xiong@qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

some platforms(BIOS or OS) may change ASPM configuration in
PCI Express Link Control Register directly and dynamically
regardless the device driver installation.
Checking if ASPM support during the driver init phase by reading
PCI Express Link Contrl Register doesn't make sense.
This refine/update assume L0S/L1 is defalut enabled as hw->ctrl_flags
inited. atl1c_set_aspm will set real configuration based on chip
capability to hardware register.
atl1c_disable_l0s_l1 and register definition of REG_PM_CTRL are
refined as well.

Signed-off-by: xiong <xiong@qca.qualcomm.com>
Tested-by: Liu David <dwliu@qca.qualcomm.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_hw.h   |   66 ++++++---
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |  167 +++++++++-------------
 2 files changed, 111 insertions(+), 122 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
index 9779b83..5e49ea2 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
@@ -121,30 +121,50 @@ int atl1c_phy_power_saving(struct atl1c_hw *hw);
 #define OTP_CTRL_CLK_EN			0x0002
 
 #define REG_PM_CTRL			0x12F8
-#define PM_CTRL_SDES_EN			0x00000001
-#define PM_CTRL_RBER_EN			0x00000002
-#define PM_CTRL_CLK_REQ_EN		0x00000004
-#define PM_CTRL_ASPM_L1_EN		0x00000008
-#define PM_CTRL_SERDES_L1_EN		0x00000010
-#define PM_CTRL_SERDES_PLL_L1_EN	0x00000020
-#define PM_CTRL_SERDES_PD_EX_L1		0x00000040
-#define PM_CTRL_SERDES_BUDS_RX_L1_EN	0x00000080
-#define PM_CTRL_L0S_ENTRY_TIMER_MASK	0xF
-#define PM_CTRL_L0S_ENTRY_TIMER_SHIFT	8
-#define PM_CTRL_ASPM_L0S_EN		0x00001000
-#define PM_CTRL_CLK_SWH_L1		0x00002000
-#define PM_CTRL_CLK_PWM_VER1_1		0x00004000
-#define PM_CTRL_RCVR_WT_TIMER		0x00008000
-#define PM_CTRL_L1_ENTRY_TIMER_MASK	0xF
-#define PM_CTRL_L1_ENTRY_TIMER_SHIFT	16
-#define PM_CTRL_PM_REQ_TIMER_MASK	0xF
-#define PM_CTRL_PM_REQ_TIMER_SHIFT	20
-#define PM_CTRL_LCKDET_TIMER_MASK	0xF
+#define PM_CTRL_HOTRST			BIT(31)
+#define PM_CTRL_MAC_ASPM_CHK		BIT(30)	/* L0s/L1 dis by MAC based on
+						 * thrghput(setting in 15A0) */
+#define PM_CTRL_SA_DLY_EN		BIT(29)
+#define PM_CTRL_L0S_BUFSRX_EN		BIT(28)
+#define PM_CTRL_LCKDET_TIMER_MASK	0xFUL
 #define PM_CTRL_LCKDET_TIMER_SHIFT	24
-#define PM_CTRL_EN_BUFS_RX_L0S		0x10000000
-#define PM_CTRL_SA_DLY_EN		0x20000000
-#define PM_CTRL_MAC_ASPM_CHK		0x40000000
-#define PM_CTRL_HOTRST			0x80000000
+#define PM_CTRL_LCKDET_TIMER_DEF	0xC
+#define PM_CTRL_PM_REQ_TIMER_MASK	0xFUL
+#define PM_CTRL_PM_REQ_TIMER_SHIFT	20	/* pm_request_l1 time > @
+						 * ->L0s not L1 */
+#define PM_CTRL_PM_REQ_TO_DEF		0xC
+#define PMCTRL_TXL1_AFTER_L0S		BIT(19)	/* l1dv2.0+ */
+#define L1D_PMCTRL_L1_ENTRY_TM_MASK	7UL	/* l1dv2.0+, 3bits */
+#define L1D_PMCTRL_L1_ENTRY_TM_SHIFT	16
+#define L1D_PMCTRL_L1_ENTRY_TM_DIS	0
+#define L1D_PMCTRL_L1_ENTRY_TM_2US	1
+#define L1D_PMCTRL_L1_ENTRY_TM_4US	2
+#define L1D_PMCTRL_L1_ENTRY_TM_8US	3
+#define L1D_PMCTRL_L1_ENTRY_TM_16US	4
+#define L1D_PMCTRL_L1_ENTRY_TM_24US	5
+#define L1D_PMCTRL_L1_ENTRY_TM_32US	6
+#define L1D_PMCTRL_L1_ENTRY_TM_63US	7
+#define PM_CTRL_L1_ENTRY_TIMER_MASK	0xFUL  /* l1C 4bits */
+#define PM_CTRL_L1_ENTRY_TIMER_SHIFT	16
+#define L2CB1_PM_CTRL_L1_ENTRY_TM	7
+#define L1C_PM_CTRL_L1_ENTRY_TM		0xF
+#define PM_CTRL_RCVR_WT_TIMER		BIT(15)	/* 1:1us, 0:2ms */
+#define PM_CTRL_CLK_PWM_VER1_1		BIT(14)	/* 0:1.0a,1:1.1 */
+#define PM_CTRL_CLK_SWH_L1		BIT(13)	/* en pcie clk sw in L1 */
+#define PM_CTRL_ASPM_L0S_EN		BIT(12)
+#define PM_CTRL_RXL1_AFTER_L0S		BIT(11)	/* l1dv2.0+ */
+#define L1D_PMCTRL_L0S_TIMER_MASK	7UL	/* l1d2.0+, 3bits*/
+#define L1D_PMCTRL_L0S_TIMER_SHIFT	8
+#define PM_CTRL_L0S_ENTRY_TIMER_MASK	0xFUL	/* l1c, 4bits */
+#define PM_CTRL_L0S_ENTRY_TIMER_SHIFT	8
+#define PM_CTRL_SERDES_BUFS_RX_L1_EN	BIT(7)
+#define PM_CTRL_SERDES_PD_EX_L1		BIT(6)	/* power down serdes rx */
+#define PM_CTRL_SERDES_PLL_L1_EN	BIT(5)
+#define PM_CTRL_SERDES_L1_EN		BIT(4)
+#define PM_CTRL_ASPM_L1_EN		BIT(3)
+#define PM_CTRL_CLK_REQ_EN		BIT(2)
+#define PM_CTRL_RBER_EN			BIT(1)
+#define PM_CTRL_SPRSDWER_EN		BIT(0)
 
 #define REG_LTSSM_ID_CTRL		0x12FC
 #define LTSSM_ID_EN_WRO			0x1000
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 9783afc..47fe6ad 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -64,7 +64,7 @@ static int atl1c_stop_mac(struct atl1c_hw *hw);
 static void atl1c_enable_rx_ctrl(struct atl1c_hw *hw);
 static void atl1c_enable_tx_ctrl(struct atl1c_hw *hw);
 static void atl1c_disable_l0s_l1(struct atl1c_hw *hw);
-static void atl1c_set_aspm(struct atl1c_hw *hw, bool linkup);
+static void atl1c_set_aspm(struct atl1c_hw *hw, u16 link_speed);
 static void atl1c_setup_mac_ctrl(struct atl1c_adapter *adapter);
 static void atl1c_clean_rx_irq(struct atl1c_adapter *adapter,
 		   int *work_done, int work_to_do);
@@ -255,7 +255,7 @@ static void atl1c_check_link_status(struct atl1c_adapter *adapter)
 		if (atl1c_stop_mac(hw) != 0)
 			if (netif_msg_hw(adapter))
 				dev_warn(&pdev->dev, "stop mac failed\n");
-		atl1c_set_aspm(hw, false);
+		atl1c_set_aspm(hw, SPEED_0);
 		netif_carrier_off(netdev);
 		netif_stop_queue(netdev);
 		atl1c_phy_reset(hw);
@@ -273,7 +273,7 @@ static void atl1c_check_link_status(struct atl1c_adapter *adapter)
 		    adapter->link_duplex != duplex) {
 			adapter->link_speed  = speed;
 			adapter->link_duplex = duplex;
-			atl1c_set_aspm(hw, true);
+			atl1c_set_aspm(hw, speed);
 			atl1c_enable_tx_ctrl(hw);
 			atl1c_enable_rx_ctrl(hw);
 			atl1c_setup_mac_ctrl(adapter);
@@ -691,12 +691,8 @@ static int atl1c_setup_mac_funcs(struct atl1c_hw *hw)
 
 	hw->ctrl_flags = ATL1C_INTR_MODRT_ENABLE  |
 			 ATL1C_TXQ_MODE_ENHANCE;
-	if (link_ctrl_data & LINK_CTRL_L0S_EN)
-		hw->ctrl_flags |= ATL1C_ASPM_L0S_SUPPORT;
-	if (link_ctrl_data & LINK_CTRL_L1_EN)
-		hw->ctrl_flags |= ATL1C_ASPM_L1_SUPPORT;
-	if (link_ctrl_data & LINK_CTRL_EXT_SYNC)
-		hw->ctrl_flags |= ATL1C_LINK_EXT_SYNC;
+	hw->ctrl_flags |= ATL1C_ASPM_L0S_SUPPORT |
+			  ATL1C_ASPM_L1_SUPPORT;
 	hw->ctrl_flags |= ATL1C_ASPM_CTRL_MON;
 
 	if (hw->nic_type == athr_l1c ||
@@ -1203,112 +1199,83 @@ static int atl1c_reset_mac(struct atl1c_hw *hw)
 
 static void atl1c_disable_l0s_l1(struct atl1c_hw *hw)
 {
-	u32 pm_ctrl_data;
-
-	AT_READ_REG(hw, REG_PM_CTRL, &pm_ctrl_data);
-	pm_ctrl_data &= ~(PM_CTRL_L1_ENTRY_TIMER_MASK <<
-			PM_CTRL_L1_ENTRY_TIMER_SHIFT);
-	pm_ctrl_data &= ~PM_CTRL_CLK_SWH_L1;
-	pm_ctrl_data &= ~PM_CTRL_ASPM_L0S_EN;
-	pm_ctrl_data &= ~PM_CTRL_ASPM_L1_EN;
-	pm_ctrl_data &= ~PM_CTRL_MAC_ASPM_CHK;
-	pm_ctrl_data &= ~PM_CTRL_SERDES_PD_EX_L1;
+	u16 ctrl_flags = hw->ctrl_flags;
 
-	pm_ctrl_data |= PM_CTRL_SERDES_BUDS_RX_L1_EN;
-	pm_ctrl_data |= PM_CTRL_SERDES_PLL_L1_EN;
-	pm_ctrl_data |=	PM_CTRL_SERDES_L1_EN;
-	AT_WRITE_REG(hw, REG_PM_CTRL, pm_ctrl_data);
+	hw->ctrl_flags &= ~(ATL1C_ASPM_L0S_SUPPORT | ATL1C_ASPM_L1_SUPPORT);
+	atl1c_set_aspm(hw, SPEED_0);
+	hw->ctrl_flags = ctrl_flags;
 }
 
 /*
  * Set ASPM state.
  * Enable/disable L0s/L1 depend on link state.
  */
-static void atl1c_set_aspm(struct atl1c_hw *hw, bool linkup)
+static void atl1c_set_aspm(struct atl1c_hw *hw, u16 link_speed)
 {
 	u32 pm_ctrl_data;
-	u32 link_ctrl_data;
-	u32 link_l1_timer = 0xF;
+	u32 link_l1_timer;
 
 	AT_READ_REG(hw, REG_PM_CTRL, &pm_ctrl_data);
-	AT_READ_REG(hw, REG_LINK_CTRL, &link_ctrl_data);
+	pm_ctrl_data &= ~(PM_CTRL_ASPM_L1_EN |
+			  PM_CTRL_ASPM_L0S_EN |
+			  PM_CTRL_MAC_ASPM_CHK);
+	/* L1 timer */
+	if (hw->nic_type == athr_l2c_b2 || hw->nic_type == athr_l1d_2) {
+		pm_ctrl_data &= ~PMCTRL_TXL1_AFTER_L0S;
+		link_l1_timer =
+			link_speed == SPEED_1000 || link_speed == SPEED_100 ?
+			L1D_PMCTRL_L1_ENTRY_TM_16US : 1;
+		pm_ctrl_data = FIELD_SETX(pm_ctrl_data,
+			L1D_PMCTRL_L1_ENTRY_TM, link_l1_timer);
+	} else {
+		link_l1_timer = hw->nic_type == athr_l2c_b ?
+			L2CB1_PM_CTRL_L1_ENTRY_TM : L1C_PM_CTRL_L1_ENTRY_TM;
+		if (link_speed != SPEED_1000 && link_speed != SPEED_100)
+			link_l1_timer = 1;
+		pm_ctrl_data = FIELD_SETX(pm_ctrl_data,
+			PM_CTRL_L1_ENTRY_TIMER, link_l1_timer);
+	}
 
-	pm_ctrl_data &= ~PM_CTRL_SERDES_PD_EX_L1;
-	pm_ctrl_data &=  ~(PM_CTRL_L1_ENTRY_TIMER_MASK <<
-			PM_CTRL_L1_ENTRY_TIMER_SHIFT);
-	pm_ctrl_data &= ~(PM_CTRL_LCKDET_TIMER_MASK <<
-			PM_CTRL_LCKDET_TIMER_SHIFT);
-	pm_ctrl_data |= AT_LCKDET_TIMER	<< PM_CTRL_LCKDET_TIMER_SHIFT;
+	/* L0S/L1 enable */
+	if (hw->ctrl_flags & ATL1C_ASPM_L0S_SUPPORT)
+		pm_ctrl_data |= PM_CTRL_ASPM_L0S_EN | PM_CTRL_MAC_ASPM_CHK;
+	if (hw->ctrl_flags & ATL1C_ASPM_L1_SUPPORT)
+		pm_ctrl_data |= PM_CTRL_ASPM_L1_EN | PM_CTRL_MAC_ASPM_CHK;
 
+	/* l2cb & l1d & l2cb2 & l1d2 */
 	if (hw->nic_type == athr_l2c_b || hw->nic_type == athr_l1d ||
-		hw->nic_type == athr_l2c_b2 || hw->nic_type == athr_l1d_2) {
-		link_ctrl_data &= ~LINK_CTRL_EXT_SYNC;
-		if (!(hw->ctrl_flags & ATL1C_APS_MODE_ENABLE)) {
-			if (hw->nic_type == athr_l2c_b && hw->revision_id == L2CB_V10)
-				link_ctrl_data |= LINK_CTRL_EXT_SYNC;
-		}
-
-		AT_WRITE_REG(hw, REG_LINK_CTRL, link_ctrl_data);
-
-		pm_ctrl_data |= PM_CTRL_RCVR_WT_TIMER;
-		pm_ctrl_data &= ~(PM_CTRL_PM_REQ_TIMER_MASK <<
-			PM_CTRL_PM_REQ_TIMER_SHIFT);
-		pm_ctrl_data |= AT_ASPM_L1_TIMER <<
-			PM_CTRL_PM_REQ_TIMER_SHIFT;
-		pm_ctrl_data &= ~PM_CTRL_SA_DLY_EN;
-		pm_ctrl_data &= ~PM_CTRL_HOTRST;
-		pm_ctrl_data |= 1 << PM_CTRL_L1_ENTRY_TIMER_SHIFT;
-		pm_ctrl_data |= PM_CTRL_SERDES_PD_EX_L1;
-	}
-	pm_ctrl_data |= PM_CTRL_MAC_ASPM_CHK;
-	if (linkup) {
-		pm_ctrl_data &= ~PM_CTRL_ASPM_L1_EN;
-		pm_ctrl_data &= ~PM_CTRL_ASPM_L0S_EN;
-		if (hw->ctrl_flags & ATL1C_ASPM_L1_SUPPORT)
-			pm_ctrl_data |= PM_CTRL_ASPM_L1_EN;
-		if (hw->ctrl_flags & ATL1C_ASPM_L0S_SUPPORT)
-			pm_ctrl_data |= PM_CTRL_ASPM_L0S_EN;
-
-		if (hw->nic_type == athr_l2c_b || hw->nic_type == athr_l1d ||
-			hw->nic_type == athr_l2c_b2 || hw->nic_type == athr_l1d_2) {
-			if (hw->nic_type == athr_l2c_b)
-				if (!(hw->ctrl_flags & ATL1C_APS_MODE_ENABLE))
-					pm_ctrl_data &= ~PM_CTRL_ASPM_L0S_EN;
-			pm_ctrl_data &= ~PM_CTRL_SERDES_L1_EN;
-			pm_ctrl_data &= ~PM_CTRL_SERDES_PLL_L1_EN;
-			pm_ctrl_data &= ~PM_CTRL_SERDES_BUDS_RX_L1_EN;
-			pm_ctrl_data |= PM_CTRL_CLK_SWH_L1;
-		if (hw->adapter->link_speed == SPEED_100 ||
-				hw->adapter->link_speed == SPEED_1000) {
-				pm_ctrl_data &=  ~(PM_CTRL_L1_ENTRY_TIMER_MASK <<
-					PM_CTRL_L1_ENTRY_TIMER_SHIFT);
-				if (hw->nic_type == athr_l2c_b)
-					link_l1_timer = 7;
-				else if (hw->nic_type == athr_l2c_b2 ||
-					hw->nic_type == athr_l1d_2)
-					link_l1_timer = 4;
-				pm_ctrl_data |= link_l1_timer <<
-					PM_CTRL_L1_ENTRY_TIMER_SHIFT;
-			}
-		} else {
-			pm_ctrl_data |= PM_CTRL_SERDES_L1_EN;
-			pm_ctrl_data |= PM_CTRL_SERDES_PLL_L1_EN;
-			pm_ctrl_data |= PM_CTRL_SERDES_BUDS_RX_L1_EN;
-			pm_ctrl_data &= ~PM_CTRL_CLK_SWH_L1;
+	    hw->nic_type == athr_l2c_b2 || hw->nic_type == athr_l1d_2) {
+		pm_ctrl_data = FIELD_SETX(pm_ctrl_data,
+			PM_CTRL_PM_REQ_TIMER, PM_CTRL_PM_REQ_TO_DEF);
+		pm_ctrl_data |= PM_CTRL_RCVR_WT_TIMER |
+				PM_CTRL_SERDES_PD_EX_L1 |
+				PM_CTRL_CLK_SWH_L1;
+		pm_ctrl_data &= ~(PM_CTRL_SERDES_L1_EN |
+				  PM_CTRL_SERDES_PLL_L1_EN |
+				  PM_CTRL_SERDES_BUFS_RX_L1_EN |
+				  PM_CTRL_SA_DLY_EN |
+				  PM_CTRL_HOTRST);
+		/* disable l0s if link down or l2cb */
+		if (link_speed == SPEED_0 || hw->nic_type == athr_l2c_b)
 			pm_ctrl_data &= ~PM_CTRL_ASPM_L0S_EN;
-			pm_ctrl_data &= ~PM_CTRL_ASPM_L1_EN;
-
+	} else { /* l1c */
+		pm_ctrl_data =
+			FIELD_SETX(pm_ctrl_data, PM_CTRL_L1_ENTRY_TIMER, 0);
+		if (link_speed != SPEED_0) {
+			pm_ctrl_data |= PM_CTRL_SERDES_L1_EN |
+					PM_CTRL_SERDES_PLL_L1_EN |
+					PM_CTRL_SERDES_BUFS_RX_L1_EN;
+			pm_ctrl_data &= ~(PM_CTRL_SERDES_PD_EX_L1 |
+					  PM_CTRL_CLK_SWH_L1 |
+					  PM_CTRL_ASPM_L0S_EN |
+					  PM_CTRL_ASPM_L1_EN);
+		} else { /* link down */
+			pm_ctrl_data |= PM_CTRL_CLK_SWH_L1;
+			pm_ctrl_data &= ~(PM_CTRL_SERDES_L1_EN |
+					  PM_CTRL_SERDES_PLL_L1_EN |
+					  PM_CTRL_SERDES_BUFS_RX_L1_EN |
+					  PM_CTRL_ASPM_L0S_EN);
 		}
-	} else {
-		pm_ctrl_data &= ~PM_CTRL_SERDES_L1_EN;
-		pm_ctrl_data &= ~PM_CTRL_ASPM_L0S_EN;
-		pm_ctrl_data &= ~PM_CTRL_SERDES_PLL_L1_EN;
-		pm_ctrl_data |= PM_CTRL_CLK_SWH_L1;
-
-		if (hw->ctrl_flags & ATL1C_ASPM_L1_SUPPORT)
-			pm_ctrl_data |= PM_CTRL_ASPM_L1_EN;
-		else
-			pm_ctrl_data &= ~PM_CTRL_ASPM_L1_EN;
 	}
 	AT_WRITE_REG(hw, REG_PM_CTRL, pm_ctrl_data);
 
@@ -2235,6 +2202,8 @@ static void atl1c_down(struct atl1c_adapter *adapter)
 	napi_disable(&adapter->napi);
 	atl1c_irq_disable(adapter);
 	atl1c_free_irq(adapter);
+	/* disable ASPM if device inactive */
+	atl1c_disable_l0s_l1(&adapter->hw);
 	/* reset MAC to disable all RX/TX */
 	atl1c_reset_mac(&adapter->hw);
 	msleep(1);
-- 
1.7.7
