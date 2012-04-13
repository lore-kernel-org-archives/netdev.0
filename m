From: xiong <xiong@qca.qualcomm.com>
Subject: [PATCH 29/37] atl1c: update PHY reset related routine
Date: Fri, 13 Apr 2012 08:14:54 +0800
Message-ID: <1334276102-15866-30-git-send-email-xiong@qca.qualcomm.com>
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

Many magic data are re-configured for PHY during its reset operation
based on chip type to get better compability and stability.
REG_PHY_CTRL register may be configured by BIOS before enter OS.
so, the driver can't directly write to it without any Read-Op.
this change also affect suspend and phy_disable routines.
PHY debug ports and extension registers are refined as well.

Signed-off-by: xiong <xiong@qca.qualcomm.com>
Tested-by: Liu David <dwliu@qca.qualcomm.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_hw.c   |  188 +++++++------
 drivers/net/ethernet/atheros/atl1c/atl1c_hw.h   |  323 ++++++++++++++++-------
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |   23 +-
 3 files changed, 340 insertions(+), 194 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.c b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.c
index 6cbe78a..7172d61 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.c
@@ -454,6 +454,32 @@ int atl1c_write_phy_ext(struct atl1c_hw *hw, u8 dev_addr,
 	return atl1c_write_phy_core(hw, true, dev_addr, reg_addr, phy_data);
 }
 
+int atl1c_read_phy_dbg(struct atl1c_hw *hw, u16 reg_addr, u16 *phy_data)
+{
+	int err;
+
+	err = atl1c_write_phy_reg(hw, MII_DBG_ADDR, reg_addr);
+	if (unlikely(err))
+		return err;
+	else
+		err = atl1c_read_phy_reg(hw, MII_DBG_DATA, phy_data);
+
+	return err;
+}
+
+int atl1c_write_phy_dbg(struct atl1c_hw *hw, u16 reg_addr, u16 phy_data)
+{
+	int err;
+
+	err = atl1c_write_phy_reg(hw, MII_DBG_ADDR, reg_addr);
+	if (unlikely(err))
+		return err;
+	else
+		err = atl1c_write_phy_reg(hw, MII_DBG_DATA, phy_data);
+
+	return err;
+}
+
 /*
  * Configures PHY autoneg and flow control advertisement settings
  *
@@ -496,119 +522,107 @@ static int atl1c_phy_setup_adv(struct atl1c_hw *hw)
 
 void atl1c_phy_disable(struct atl1c_hw *hw)
 {
-	AT_WRITE_REGW(hw, REG_GPHY_CTRL,
-			GPHY_CTRL_PW_WOL_DIS | GPHY_CTRL_EXT_RESET);
-}
-
-static void atl1c_phy_magic_data(struct atl1c_hw *hw)
-{
-	u16 data;
+	u32 phy_ctrl_data;
 
-	data = ANA_LOOP_SEL_10BT | ANA_EN_MASK_TB | ANA_EN_10BT_IDLE |
-		((1 & ANA_INTERVAL_SEL_TIMER_MASK) <<
-		ANA_INTERVAL_SEL_TIMER_SHIFT);
-
-	atl1c_write_phy_reg(hw, MII_DBG_ADDR, MII_ANA_CTRL_18);
-	atl1c_write_phy_reg(hw, MII_DBG_DATA, data);
-
-	data = (2 & ANA_SERDES_CDR_BW_MASK) | ANA_MS_PAD_DBG |
-		ANA_SERDES_EN_DEEM | ANA_SERDES_SEL_HSP | ANA_SERDES_EN_PLL |
-		ANA_SERDES_EN_LCKDT;
-
-	atl1c_write_phy_reg(hw, MII_DBG_ADDR, MII_ANA_CTRL_5);
-	atl1c_write_phy_reg(hw, MII_DBG_DATA, data);
-
-	data = (44 & ANA_LONG_CABLE_TH_100_MASK) |
-		((33 & ANA_SHORT_CABLE_TH_100_MASK) <<
-		ANA_SHORT_CABLE_TH_100_SHIFT) | ANA_BP_BAD_LINK_ACCUM |
-		ANA_BP_SMALL_BW;
-
-	atl1c_write_phy_reg(hw, MII_DBG_ADDR, MII_ANA_CTRL_54);
-	atl1c_write_phy_reg(hw, MII_DBG_DATA, data);
-
-	data = (11 & ANA_IECHO_ADJ_MASK) | ((11 & ANA_IECHO_ADJ_MASK) <<
-		ANA_IECHO_ADJ_2_SHIFT) | ((8 & ANA_IECHO_ADJ_MASK) <<
-		ANA_IECHO_ADJ_1_SHIFT) | ((8 & ANA_IECHO_ADJ_MASK) <<
-		ANA_IECHO_ADJ_0_SHIFT);
-
-	atl1c_write_phy_reg(hw, MII_DBG_ADDR, MII_ANA_CTRL_4);
-	atl1c_write_phy_reg(hw, MII_DBG_DATA, data);
-
-	data = ANA_RESTART_CAL | ((7 & ANA_MANUL_SWICH_ON_MASK) <<
-		ANA_MANUL_SWICH_ON_SHIFT) | ANA_MAN_ENABLE |
-		ANA_SEL_HSP | ANA_EN_HB | ANA_OEN_125M;
-
-	atl1c_write_phy_reg(hw, MII_DBG_ADDR, MII_ANA_CTRL_0);
-	atl1c_write_phy_reg(hw, MII_DBG_DATA, data);
-
-	if (hw->ctrl_flags & ATL1C_HIB_DISABLE) {
-		atl1c_write_phy_reg(hw, MII_DBG_ADDR, MII_ANA_CTRL_41);
-		if (atl1c_read_phy_reg(hw, MII_DBG_DATA, &data) != 0)
-			return;
-		data &= ~ANA_TOP_PS_EN;
-		atl1c_write_phy_reg(hw, MII_DBG_DATA, data);
-
-		atl1c_write_phy_reg(hw, MII_DBG_ADDR, MII_ANA_CTRL_11);
-		if (atl1c_read_phy_reg(hw, MII_DBG_DATA, &data) != 0)
-			return;
-		data &= ~ANA_PS_HIB_EN;
-		atl1c_write_phy_reg(hw, MII_DBG_DATA, data);
-	}
+	AT_READ_REG(hw, REG_GPHY_CTRL, &phy_ctrl_data);
+	phy_ctrl_data &= ~(GPHY_CTRL_EXT_RESET | GPHY_CTRL_CLS);
+	phy_ctrl_data |= GPHY_CTRL_SEL_ANA_RST | GPHY_CTRL_HIB_PULSE |
+			GPHY_CTRL_HIB_EN | GPHY_CTRL_PHY_IDDQ |
+			GPHY_CTRL_PWDOWN_HW;
+	AT_WRITE_REGW(hw, REG_GPHY_CTRL, phy_ctrl_data);
 }
 
+
 int atl1c_phy_reset(struct atl1c_hw *hw)
 {
 	struct atl1c_adapter *adapter = hw->adapter;
 	struct pci_dev *pdev = adapter->pdev;
 	u16 phy_data;
-	u32 phy_ctrl_data = GPHY_CTRL_DEFAULT;
-	u32 mii_ier_data = IER_LINK_UP | IER_LINK_DOWN;
+	u32 phy_ctrl_data, lpi_ctrl;
 	int err;
 
-	if (hw->ctrl_flags & ATL1C_HIB_DISABLE)
-		phy_ctrl_data &= ~GPHY_CTRL_HIB_EN;
-
+	/* reset PHY core */
+	AT_READ_REG(hw, REG_GPHY_CTRL, &phy_ctrl_data);
+	phy_ctrl_data &= ~(GPHY_CTRL_EXT_RESET | GPHY_CTRL_PHY_IDDQ |
+		GPHY_CTRL_GATE_25M_EN | GPHY_CTRL_PWDOWN_HW | GPHY_CTRL_CLS);
+	phy_ctrl_data |= GPHY_CTRL_SEL_ANA_RST;
+	if (!(hw->ctrl_flags & ATL1C_HIB_DISABLE))
+		phy_ctrl_data |= (GPHY_CTRL_HIB_EN | GPHY_CTRL_HIB_PULSE);
+	else
+		phy_ctrl_data &= ~(GPHY_CTRL_HIB_EN | GPHY_CTRL_HIB_PULSE);
 	AT_WRITE_REG(hw, REG_GPHY_CTRL, phy_ctrl_data);
 	AT_WRITE_FLUSH(hw);
-	msleep(40);
-	phy_ctrl_data |= GPHY_CTRL_EXT_RESET;
-	AT_WRITE_REG(hw, REG_GPHY_CTRL, phy_ctrl_data);
+	udelay(10);
+	AT_WRITE_REG(hw, REG_GPHY_CTRL, phy_ctrl_data | GPHY_CTRL_EXT_RESET);
 	AT_WRITE_FLUSH(hw);
-	msleep(10);
+	udelay(10 * GPHY_CTRL_EXT_RST_TO);	/* delay 800us */
 
+	/* switch clock */
 	if (hw->nic_type == athr_l2c_b) {
-		atl1c_write_phy_reg(hw, MII_DBG_ADDR, 0x0A);
-		atl1c_read_phy_reg(hw, MII_DBG_DATA, &phy_data);
-		atl1c_write_phy_reg(hw, MII_DBG_DATA, phy_data & 0xDFFF);
+		atl1c_read_phy_dbg(hw, MIIDBG_CFGLPSPD, &phy_data);
+		atl1c_write_phy_dbg(hw, MIIDBG_CFGLPSPD,
+			phy_data & ~CFGLPSPD_RSTCNT_CLK125SW);
 	}
 
-	if (hw->nic_type == athr_l2c_b ||
-	    hw->nic_type == athr_l2c_b2 ||
-	    hw->nic_type == athr_l1d ||
-	    hw->nic_type == athr_l1d_2) {
-		atl1c_write_phy_reg(hw, MII_DBG_ADDR, 0x3B);
-		atl1c_read_phy_reg(hw, MII_DBG_DATA, &phy_data);
-		atl1c_write_phy_reg(hw, MII_DBG_DATA, phy_data & 0xFFF7);
-		msleep(20);
+	/* tx-half amplitude issue fix */
+	if (hw->nic_type == athr_l2c_b || hw->nic_type == athr_l2c_b2) {
+		atl1c_read_phy_dbg(hw, MIIDBG_CABLE1TH_DET, &phy_data);
+		phy_data |= CABLE1TH_DET_EN;
+		atl1c_write_phy_dbg(hw, MIIDBG_CABLE1TH_DET, phy_data);
 	}
-	if (hw->nic_type == athr_l1d) {
-		atl1c_write_phy_reg(hw, MII_DBG_ADDR, 0x29);
-		atl1c_write_phy_reg(hw, MII_DBG_DATA, 0x929D);
+
+	/* clear bit3 of dbgport 3B to lower voltage */
+	if (!(hw->ctrl_flags & ATL1C_HIB_DISABLE)) {
+		if (hw->nic_type == athr_l2c_b || hw->nic_type == athr_l2c_b2) {
+			atl1c_read_phy_dbg(hw, MIIDBG_VOLT_CTRL, &phy_data);
+			phy_data &= ~VOLT_CTRL_SWLOWEST;
+			atl1c_write_phy_dbg(hw, MIIDBG_VOLT_CTRL, phy_data);
+		}
+		/* power saving config */
+		phy_data =
+			hw->nic_type == athr_l1d || hw->nic_type == athr_l1d_2 ?
+			L1D_LEGCYPS_DEF : L1C_LEGCYPS_DEF;
+		atl1c_write_phy_dbg(hw, MIIDBG_LEGCYPS, phy_data);
+		/* hib */
+		atl1c_write_phy_dbg(hw, MIIDBG_SYSMODCTRL,
+			SYSMODCTRL_IECHOADJ_DEF);
+	} else {
+		/* disable pws */
+		atl1c_read_phy_dbg(hw, MIIDBG_LEGCYPS, &phy_data);
+		atl1c_write_phy_dbg(hw, MIIDBG_LEGCYPS,
+			phy_data & ~LEGCYPS_EN);
+		/* disable hibernate */
+		atl1c_read_phy_dbg(hw, MIIDBG_HIBNEG, &phy_data);
+		atl1c_write_phy_dbg(hw, MIIDBG_HIBNEG,
+			phy_data & HIBNEG_PSHIB_EN);
 	}
-	if (hw->nic_type == athr_l1c || hw->nic_type == athr_l2c_b2
-		|| hw->nic_type == athr_l2c) {
-		atl1c_write_phy_reg(hw, MII_DBG_ADDR, 0x29);
-		atl1c_write_phy_reg(hw, MII_DBG_DATA, 0xB6DD);
+	/* disable AZ(EEE) by default */
+	if (hw->nic_type == athr_l1d || hw->nic_type == athr_l1d_2 ||
+	    hw->nic_type == athr_l2c_b2) {
+		AT_READ_REG(hw, REG_LPI_CTRL, &lpi_ctrl);
+		AT_WRITE_REG(hw, REG_LPI_CTRL, lpi_ctrl & ~LPI_CTRL_EN);
+		atl1c_write_phy_ext(hw, MIIEXT_ANEG, MIIEXT_LOCAL_EEEADV, 0);
+		atl1c_write_phy_ext(hw, MIIEXT_PCS, MIIEXT_CLDCTRL3,
+			L2CB_CLDCTRL3);
 	}
-	err = atl1c_write_phy_reg(hw, MII_IER, mii_ier_data);
+
+	/* other debug port to set */
+	atl1c_write_phy_dbg(hw, MIIDBG_ANACTRL, ANACTRL_DEF);
+	atl1c_write_phy_dbg(hw, MIIDBG_SRDSYSMOD, SRDSYSMOD_DEF);
+	atl1c_write_phy_dbg(hw, MIIDBG_TST10BTCFG, TST10BTCFG_DEF);
+	/* UNH-IOL test issue, set bit7 */
+	atl1c_write_phy_dbg(hw, MIIDBG_TST100BTCFG,
+		TST100BTCFG_DEF | TST100BTCFG_LITCH_EN);
+
+	/* set phy interrupt mask */
+	phy_data = IER_LINK_UP | IER_LINK_DOWN;
+	err = atl1c_write_phy_reg(hw, MII_IER, phy_data);
 	if (err) {
 		if (netif_msg_hw(adapter))
 			dev_err(&pdev->dev,
 				"Error enable PHY linkChange Interrupt\n");
 		return err;
 	}
-	if (!(hw->ctrl_flags & ATL1C_FPGA_VERSION))
-		atl1c_phy_magic_data(hw);
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
index 672217d..eac90b2 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
@@ -59,6 +59,9 @@ int atl1c_read_phy_ext(struct atl1c_hw *hw, u8 dev_addr,
 			u16 reg_addr, u16 *phy_data);
 int atl1c_write_phy_ext(struct atl1c_hw *hw, u8 dev_addr,
 			u16 reg_addr, u16 phy_data);
+int atl1c_read_phy_dbg(struct atl1c_hw *hw, u16 reg_addr, u16 *phy_data);
+int atl1c_write_phy_dbg(struct atl1c_hw *hw, u16 reg_addr, u16 phy_data);
+
 /* register definition */
 #define REG_DEVICE_CAP              	0x5C
 #define DEVICE_CAP_MAX_PAYLOAD_MASK     0x7
@@ -261,41 +264,32 @@ int atl1c_write_phy_ext(struct atl1c_hw *hw, u8 dev_addr,
 #define IRQ_MODRT_RX_TIMER_SHIFT	16
 
 #define REG_GPHY_CTRL               	0x140C
-#define GPHY_CTRL_EXT_RESET         	0x1
-#define GPHY_CTRL_RTL_MODE		0x2
-#define GPHY_CTRL_LED_MODE		0x4
-#define GPHY_CTRL_ANEG_NOW		0x8
-#define GPHY_CTRL_REV_ANEG		0x10
-#define GPHY_CTRL_GATE_25M_EN       	0x20
-#define GPHY_CTRL_LPW_EXIT          	0x40
-#define GPHY_CTRL_PHY_IDDQ          	0x80
-#define GPHY_CTRL_PHY_IDDQ_DIS      	0x100
-#define GPHY_CTRL_GIGA_DIS		0x200
-#define GPHY_CTRL_HIB_EN            	0x400
-#define GPHY_CTRL_HIB_PULSE         	0x800
-#define GPHY_CTRL_SEL_ANA_RST       	0x1000
-#define GPHY_CTRL_PHY_PLL_ON        	0x2000
-#define GPHY_CTRL_PWDOWN_HW		0x4000
-#define GPHY_CTRL_PHY_PLL_BYPASS	0x8000
-
-#define GPHY_CTRL_DEFAULT (		 \
-		GPHY_CTRL_SEL_ANA_RST	|\
-		GPHY_CTRL_HIB_PULSE	|\
-		GPHY_CTRL_HIB_EN)
-
-#define GPHY_CTRL_PW_WOL_DIS (		 \
-		GPHY_CTRL_SEL_ANA_RST	|\
-		GPHY_CTRL_HIB_PULSE	|\
-		GPHY_CTRL_HIB_EN	|\
-		GPHY_CTRL_PWDOWN_HW	|\
-		GPHY_CTRL_PHY_IDDQ)
-
-#define GPHY_CTRL_POWER_SAVING (	\
-		GPHY_CTRL_SEL_ANA_RST	|\
-		GPHY_CTRL_HIB_EN	|\
-		GPHY_CTRL_HIB_PULSE	|\
-		GPHY_CTRL_PWDOWN_HW	|\
-		GPHY_CTRL_PHY_IDDQ)
+#define GPHY_CTRL_ADDR_MASK		0x1FUL
+#define GPHY_CTRL_ADDR_SHIFT		19
+#define GPHY_CTRL_BP_VLTGSW		BIT(18)
+#define GPHY_CTRL_100AB_EN		BIT(17)
+#define GPHY_CTRL_10AB_EN		BIT(16)
+#define GPHY_CTRL_PHY_PLL_BYPASS	BIT(15)
+#define GPHY_CTRL_PWDOWN_HW		BIT(14)	/* affect MAC&PHY, to low pw */
+#define GPHY_CTRL_PHY_PLL_ON		BIT(13)	/* 1:pll always on, 0:can sw */
+#define GPHY_CTRL_SEL_ANA_RST		BIT(12)
+#define GPHY_CTRL_HIB_PULSE		BIT(11)
+#define GPHY_CTRL_HIB_EN		BIT(10)
+#define GPHY_CTRL_GIGA_DIS		BIT(9)
+#define GPHY_CTRL_PHY_IDDQ_DIS		BIT(8)	/* pw on RST */
+#define GPHY_CTRL_PHY_IDDQ		BIT(7)	/* bit8 affect bit7 while rb */
+#define GPHY_CTRL_LPW_EXIT		BIT(6)
+#define GPHY_CTRL_GATE_25M_EN		BIT(5)
+#define GPHY_CTRL_REV_ANEG		BIT(4)
+#define GPHY_CTRL_ANEG_NOW		BIT(3)
+#define GPHY_CTRL_LED_MODE		BIT(2)
+#define GPHY_CTRL_RTL_MODE		BIT(1)
+#define GPHY_CTRL_EXT_RESET		BIT(0)	/* 1:out of DSP RST status */
+#define GPHY_CTRL_EXT_RST_TO		80	/* 800us atmost */
+#define GPHY_CTRL_CLS			(\
+	GPHY_CTRL_LED_MODE		|\
+	GPHY_CTRL_100AB_EN		|\
+	GPHY_CTRL_PHY_PLL_ON)
 
 /* Block IDLE Status Register */
 #define REG_IDLE_STATUS			0x1410
@@ -389,6 +383,26 @@ int atl1c_write_phy_ext(struct atl1c_hw *hw, u8 dev_addr,
 #define SERDES_LOCK_DETECT_EN		BIT(1)
 #define SERDES_LOCK_DETECT		BIT(0)
 
+#define REG_LPI_DECISN_TIMER            0x143C
+#define L2CB_LPI_DESISN_TIMER		0x7D00
+
+#define REG_LPI_CTRL                    0x1440
+#define LPI_CTRL_CHK_DA			BIT(31)
+#define LPI_CTRL_ENH_TO_MASK		0x1FFFUL
+#define LPI_CTRL_ENH_TO_SHIFT		12
+#define LPI_CTRL_ENH_TH_MASK		0x1FUL
+#define LPI_CTRL_ENH_TH_SHIFT		6
+#define LPI_CTRL_ENH_EN			BIT(5)
+#define LPI_CTRL_CHK_RX			BIT(4)
+#define LPI_CTRL_CHK_STATE		BIT(3)
+#define LPI_CTRL_GMII			BIT(2)
+#define LPI_CTRL_TO_PHY			BIT(1)
+#define LPI_CTRL_EN			BIT(0)
+
+#define REG_LPI_WAIT			0x1444
+#define LPI_WAIT_TIMER_MASK		0xFFFFUL
+#define LPI_WAIT_TIMER_SHIFT		0
+
 /* MAC Control Register  */
 #define REG_MAC_CTRL         		0x1480
 #define MAC_CTRL_TX_EN			0x1
@@ -852,73 +866,188 @@ int atl1c_write_phy_ext(struct atl1c_hw *hw, u8 dev_addr,
 #define MII_DBG_ADDR			0x1D
 #define MII_DBG_DATA			0x1E
 
-#define MII_ANA_CTRL_0			0x0
-#define ANA_RESTART_CAL			0x0001
-#define ANA_MANUL_SWICH_ON_SHIFT	0x1
-#define ANA_MANUL_SWICH_ON_MASK		0xF
-#define ANA_MAN_ENABLE			0x0020
-#define ANA_SEL_HSP			0x0040
-#define ANA_EN_HB			0x0080
-#define ANA_EN_HBIAS			0x0100
-#define ANA_OEN_125M			0x0200
-#define ANA_EN_LCKDT			0x0400
-#define ANA_LCKDT_PHY			0x0800
-#define ANA_AFE_MODE			0x1000
-#define ANA_VCO_SLOW			0x2000
-#define ANA_VCO_FAST			0x4000
-#define ANA_SEL_CLK125M_DSP		0x8000
+/***************************** debug port *************************************/
+
+#define MIIDBG_ANACTRL                  0x00
+#define ANACTRL_CLK125M_DELAY_EN        0x8000
+#define ANACTRL_VCO_FAST                0x4000
+#define ANACTRL_VCO_SLOW                0x2000
+#define ANACTRL_AFE_MODE_EN             0x1000
+#define ANACTRL_LCKDET_PHY              0x800
+#define ANACTRL_LCKDET_EN               0x400
+#define ANACTRL_OEN_125M                0x200
+#define ANACTRL_HBIAS_EN                0x100
+#define ANACTRL_HB_EN                   0x80
+#define ANACTRL_SEL_HSP                 0x40
+#define ANACTRL_CLASSA_EN               0x20
+#define ANACTRL_MANUSWON_SWR_MASK       3U
+#define ANACTRL_MANUSWON_SWR_SHIFT      2
+#define ANACTRL_MANUSWON_SWR_2V         0
+#define ANACTRL_MANUSWON_SWR_1P9V       1
+#define ANACTRL_MANUSWON_SWR_1P8V       2
+#define ANACTRL_MANUSWON_SWR_1P7V       3
+#define ANACTRL_MANUSWON_BW3_4M         0x2
+#define ANACTRL_RESTART_CAL             0x1
+#define ANACTRL_DEF                     0x02EF
+
+#define MIIDBG_SYSMODCTRL               0x04
+#define SYSMODCTRL_IECHOADJ_PFMH_PHY    0x8000
+#define SYSMODCTRL_IECHOADJ_BIASGEN     0x4000
+#define SYSMODCTRL_IECHOADJ_PFML_PHY    0x2000
+#define SYSMODCTRL_IECHOADJ_PS_MASK     3U
+#define SYSMODCTRL_IECHOADJ_PS_SHIFT    10
+#define SYSMODCTRL_IECHOADJ_PS_40       3
+#define SYSMODCTRL_IECHOADJ_PS_20       2
+#define SYSMODCTRL_IECHOADJ_PS_0        1
+#define SYSMODCTRL_IECHOADJ_10BT_100MV  0x40 /* 1:100mv, 0:200mv */
+#define SYSMODCTRL_IECHOADJ_HLFAP_MASK  3U
+#define SYSMODCTRL_IECHOADJ_HLFAP_SHIFT 4
+#define SYSMODCTRL_IECHOADJ_VDFULBW     0x8
+#define SYSMODCTRL_IECHOADJ_VDBIASHLF   0x4
+#define SYSMODCTRL_IECHOADJ_VDAMPHLF    0x2
+#define SYSMODCTRL_IECHOADJ_VDLANSW     0x1
+#define SYSMODCTRL_IECHOADJ_DEF         0x88BB /* ???? */
+
+/* for l1d & l2cb */
+#define SYSMODCTRL_IECHOADJ_CUR_ADD     0x8000
+#define SYSMODCTRL_IECHOADJ_CUR_MASK    7U
+#define SYSMODCTRL_IECHOADJ_CUR_SHIFT   12
+#define SYSMODCTRL_IECHOADJ_VOL_MASK    0xFU
+#define SYSMODCTRL_IECHOADJ_VOL_SHIFT   8
+#define SYSMODCTRL_IECHOADJ_VOL_17ALL   3
+#define SYSMODCTRL_IECHOADJ_VOL_100M15  1
+#define SYSMODCTRL_IECHOADJ_VOL_10M17   0
+#define SYSMODCTRL_IECHOADJ_BIAS1_MASK  0xFU
+#define SYSMODCTRL_IECHOADJ_BIAS1_SHIFT 4
+#define SYSMODCTRL_IECHOADJ_BIAS2_MASK  0xFU
+#define SYSMODCTRL_IECHOADJ_BIAS2_SHIFT 0
+#define L1D_SYSMODCTRL_IECHOADJ_DEF     0x4FBB
+
+#define MIIDBG_SRDSYSMOD                0x05
+#define SRDSYSMOD_LCKDET_EN             0x2000
+#define SRDSYSMOD_PLL_EN                0x800
+#define SRDSYSMOD_SEL_HSP               0x400
+#define SRDSYSMOD_HLFTXDR               0x200
+#define SRDSYSMOD_TXCLK_DELAY_EN        0x100
+#define SRDSYSMOD_TXELECIDLE            0x80
+#define SRDSYSMOD_DEEMP_EN              0x40
+#define SRDSYSMOD_MS_PAD                0x4
+#define SRDSYSMOD_CDR_ADC_VLTG          0x2
+#define SRDSYSMOD_CDR_DAC_1MA           0x1
+#define SRDSYSMOD_DEF                   0x2C46
+
+#define MIIDBG_CFGLPSPD                 0x0A
+#define CFGLPSPD_RSTCNT_MASK            3U
+#define CFGLPSPD_RSTCNT_SHIFT           14
+#define CFGLPSPD_RSTCNT_CLK125SW        0x2000
+
+#define MIIDBG_HIBNEG                   0x0B
+#define HIBNEG_PSHIB_EN                 0x8000
+#define HIBNEG_WAKE_BOTH                0x4000
+#define HIBNEG_ONOFF_ANACHG_SUDEN       0x2000
+#define HIBNEG_HIB_PULSE                0x1000
+#define HIBNEG_GATE_25M_EN              0x800
+#define HIBNEG_RST_80U                  0x400
+#define HIBNEG_RST_TIMER_MASK           3U
+#define HIBNEG_RST_TIMER_SHIFT          8
+#define HIBNEG_GTX_CLK_DELAY_MASK       3U
+#define HIBNEG_GTX_CLK_DELAY_SHIFT      5
+#define HIBNEG_BYPSS_BRKTIMER           0x10
+#define HIBNEG_DEF                      0xBC40
+
+#define MIIDBG_TST10BTCFG               0x12
+#define TST10BTCFG_INTV_TIMER_MASK      3U
+#define TST10BTCFG_INTV_TIMER_SHIFT     14
+#define TST10BTCFG_TRIGER_TIMER_MASK    3U
+#define TST10BTCFG_TRIGER_TIMER_SHIFT   12
+#define TST10BTCFG_DIV_MAN_MLT3_EN      0x800
+#define TST10BTCFG_OFF_DAC_IDLE         0x400
+#define TST10BTCFG_LPBK_DEEP            0x4 /* 1:deep,0:shallow */
+#define TST10BTCFG_DEF                  0x4C04
+
+#define MIIDBG_AZ_ANADECT		0x15
+#define AZ_ANADECT_10BTRX_TH		0x8000
+#define AZ_ANADECT_BOTH_01CHNL		0x4000
+#define AZ_ANADECT_INTV_MASK		0x3FU
+#define AZ_ANADECT_INTV_SHIFT		8
+#define AZ_ANADECT_THRESH_MASK		0xFU
+#define AZ_ANADECT_THRESH_SHIFT		4
+#define AZ_ANADECT_CHNL_MASK		0xFU
+#define AZ_ANADECT_CHNL_SHIFT		0
+#define AZ_ANADECT_DEF			0x3220
+#define AZ_ANADECT_LONG                 0xb210
+
+#define MIIDBG_MSE16DB			0x18	/* l1d */
+#define L1D_MSE16DB_UP			0x05EA
+#define L1D_MSE16DB_DOWN		0x02EA
+
+#define MIIDBG_LEGCYPS                  0x29
+#define LEGCYPS_EN                      0x8000
+#define LEGCYPS_DAC_AMP1000_MASK        7U
+#define LEGCYPS_DAC_AMP1000_SHIFT       12
+#define LEGCYPS_DAC_AMP100_MASK         7U
+#define LEGCYPS_DAC_AMP100_SHIFT        9
+#define LEGCYPS_DAC_AMP10_MASK          7U
+#define LEGCYPS_DAC_AMP10_SHIFT         6
+#define LEGCYPS_UNPLUG_TIMER_MASK       7U
+#define LEGCYPS_UNPLUG_TIMER_SHIFT      3
+#define LEGCYPS_UNPLUG_DECT_EN          0x4
+#define LEGCYPS_ECNC_PS_EN              0x1
+#define L1D_LEGCYPS_DEF                 0x129D
+#define L1C_LEGCYPS_DEF                 0x36DD
+
+#define MIIDBG_TST100BTCFG              0x36
+#define TST100BTCFG_NORMAL_BW_EN        0x8000
+#define TST100BTCFG_BADLNK_BYPASS       0x4000
+#define TST100BTCFG_SHORTCABL_TH_MASK   0x3FU
+#define TST100BTCFG_SHORTCABL_TH_SHIFT  8
+#define TST100BTCFG_LITCH_EN            0x80
+#define TST100BTCFG_VLT_SW              0x40
+#define TST100BTCFG_LONGCABL_TH_MASK    0x3FU
+#define TST100BTCFG_LONGCABL_TH_SHIFT   0
+#define TST100BTCFG_DEF                 0xE12C
+
+#define MIIDBG_VOLT_CTRL                0x3B	/* only for l2cb 1 & 2 */
+#define VOLT_CTRL_CABLE1TH_MASK         0x1FFU
+#define VOLT_CTRL_CABLE1TH_SHIFT        7
+#define VOLT_CTRL_AMPCTRL_MASK          3U
+#define VOLT_CTRL_AMPCTRL_SHIFT         5
+#define VOLT_CTRL_SW_BYPASS             0x10
+#define VOLT_CTRL_SWLOWEST              0x8
+#define VOLT_CTRL_DACAMP10_MASK         7U
+#define VOLT_CTRL_DACAMP10_SHIFT        0
+
+#define MIIDBG_CABLE1TH_DET             0x3E
+#define CABLE1TH_DET_EN                 0x8000
+
+
+/******* dev 3 *********/
+#define MIIEXT_PCS                      3
 
-#define MII_ANA_CTRL_4			0x4
-#define ANA_IECHO_ADJ_MASK		0xF
-#define ANA_IECHO_ADJ_3_SHIFT		0
-#define ANA_IECHO_ADJ_2_SHIFT		4
-#define ANA_IECHO_ADJ_1_SHIFT		8
-#define ANA_IECHO_ADJ_0_SHIFT		12
+#define MIIEXT_CLDCTRL3                 0x8003
+#define CLDCTRL3_BP_CABLE1TH_DET_GT     0x8000
+#define CLDCTRL3_AZ_DISAMP              0x1000
+#define L2CB_CLDCTRL3                   0x4D19
+#define L1D_CLDCTRL3                    0xDD19
 
-#define MII_ANA_CTRL_5			0x5
-#define ANA_SERDES_CDR_BW_SHIFT		0
-#define ANA_SERDES_CDR_BW_MASK		0x3
-#define ANA_MS_PAD_DBG			0x0004
-#define ANA_SPEEDUP_DBG			0x0008
-#define ANA_SERDES_TH_LOS_SHIFT		4
-#define ANA_SERDES_TH_LOS_MASK		0x3
-#define ANA_SERDES_EN_DEEM		0x0040
-#define ANA_SERDES_TXELECIDLE		0x0080
-#define ANA_SERDES_BEACON		0x0100
-#define ANA_SERDES_HALFTXDR		0x0200
-#define ANA_SERDES_SEL_HSP		0x0400
-#define ANA_SERDES_EN_PLL		0x0800
-#define ANA_SERDES_EN			0x1000
-#define ANA_SERDES_EN_LCKDT		0x2000
+#define MIIEXT_CLDCTRL6			0x8006
+#define CLDCTRL6_CAB_LEN_MASK		0x1FFU
+#define CLDCTRL6_CAB_LEN_SHIFT          0
+#define CLDCTRL6_CAB_LEN_SHORT          0x50
 
-#define MII_ANA_CTRL_11			0xB
-#define ANA_PS_HIB_EN			0x8000
+/********* dev 7 **********/
+#define MIIEXT_ANEG                     7
 
-#define MII_ANA_CTRL_18			0x12
-#define ANA_TEST_MODE_10BT_01SHIFT	0
-#define ANA_TEST_MODE_10BT_01MASK	0x3
-#define ANA_LOOP_SEL_10BT		0x0004
-#define ANA_RGMII_MODE_SW		0x0008
-#define ANA_EN_LONGECABLE		0x0010
-#define ANA_TEST_MODE_10BT_2		0x0020
-#define ANA_EN_10BT_IDLE		0x0400
-#define ANA_EN_MASK_TB			0x0800
-#define ANA_TRIGGER_SEL_TIMER_SHIFT	12
-#define ANA_TRIGGER_SEL_TIMER_MASK	0x3
-#define ANA_INTERVAL_SEL_TIMER_SHIFT	14
-#define ANA_INTERVAL_SEL_TIMER_MASK	0x3
+#define MIIEXT_LOCAL_EEEADV             0x3C
+#define LOCAL_EEEADV_1000BT             0x4
+#define LOCAL_EEEADV_100BT              0x2
 
-#define MII_ANA_CTRL_41			0x29
-#define ANA_TOP_PS_EN			0x8000
+#define MIIEXT_REMOTE_EEEADV            0x3D
+#define REMOTE_EEEADV_1000BT            0x4
+#define REMOTE_EEEADV_100BT             0x2
 
-#define MII_ANA_CTRL_54			0x36
-#define ANA_LONG_CABLE_TH_100_SHIFT	0
-#define ANA_LONG_CABLE_TH_100_MASK	0x3F
-#define ANA_DESERVED			0x0040
-#define ANA_EN_LIT_CH			0x0080
-#define ANA_SHORT_CABLE_TH_100_SHIFT	8
-#define ANA_SHORT_CABLE_TH_100_MASK	0x3F
-#define ANA_BP_BAD_LINK_ACCUM		0x4000
-#define ANA_BP_SMALL_BW			0x8000
+#define MIIEXT_EEE_ANEG                 0x8000
+#define EEE_ANEG_1000M                  0x4
+#define EEE_ANEG_100M                   0x2
 
 #endif /*_ATL1C_HW_H_*/
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index e43f42f..9f6416e 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -2313,6 +2313,7 @@ static int atl1c_suspend(struct device *dev)
 	u32 wol_ctrl_data = 0;
 	u16 mii_intr_status_data = 0;
 	u32 wufc = adapter->wol;
+	u32 phy_ctrl_data;
 
 	atl1c_disable_l0s_l1(hw);
 	if (netif_running(netdev)) {
@@ -2327,6 +2328,7 @@ static int atl1c_suspend(struct device *dev)
 
 	AT_READ_REG(hw, REG_MASTER_CTRL, &master_ctrl_data);
 	AT_READ_REG(hw, REG_MAC_CTRL, &mac_ctrl_data);
+	AT_READ_REG(hw, REG_GPHY_CTRL, &phy_ctrl_data);
 
 	master_ctrl_data &= ~MASTER_CTRL_CLK_SEL_DIS;
 	mac_ctrl_data &= ~(MAC_CTRL_PRMLEN_MASK << MAC_CTRL_PRMLEN_SHIFT);
@@ -2335,9 +2337,13 @@ static int atl1c_suspend(struct device *dev)
 			MAC_CTRL_PRMLEN_SHIFT);
 	mac_ctrl_data &= ~(MAC_CTRL_SPEED_MASK << MAC_CTRL_SPEED_SHIFT);
 	mac_ctrl_data &= ~MAC_CTRL_DUPLX;
+	phy_ctrl_data &= ~(GPHY_CTRL_EXT_RESET | GPHY_CTRL_CLS);
+	phy_ctrl_data |= GPHY_CTRL_SEL_ANA_RST | GPHY_CTRL_HIB_PULSE |
+			GPHY_CTRL_HIB_EN;
 
 	if (wufc) {
 		mac_ctrl_data |= MAC_CTRL_RX_EN;
+		phy_ctrl_data |= GPHY_CTRL_EXT_RESET;
 		if (adapter->link_speed == SPEED_1000 ||
 			adapter->link_speed == SPEED_0) {
 			mac_ctrl_data |= atl1c_mac_speed_1000 <<
@@ -2380,23 +2386,20 @@ static int atl1c_suspend(struct device *dev)
 		dev_dbg(&pdev->dev,
 			"%s: suspend MAC=0x%x\n",
 			atl1c_driver_name, mac_ctrl_data);
-		AT_WRITE_REG(hw, REG_MASTER_CTRL, master_ctrl_data);
-		AT_WRITE_REG(hw, REG_WOL_CTRL, wol_ctrl_data);
-		AT_WRITE_REG(hw, REG_MAC_CTRL, mac_ctrl_data);
-
-		AT_WRITE_REG(hw, REG_GPHY_CTRL, GPHY_CTRL_DEFAULT |
-			GPHY_CTRL_EXT_RESET);
 	} else {
-		AT_WRITE_REG(hw, REG_GPHY_CTRL, GPHY_CTRL_POWER_SAVING);
 		master_ctrl_data |= MASTER_CTRL_CLK_SEL_DIS;
 		mac_ctrl_data |= atl1c_mac_speed_10_100 << MAC_CTRL_SPEED_SHIFT;
 		mac_ctrl_data |= MAC_CTRL_DUPLX;
-		AT_WRITE_REG(hw, REG_MASTER_CTRL, master_ctrl_data);
-		AT_WRITE_REG(hw, REG_MAC_CTRL, mac_ctrl_data);
-		AT_WRITE_REG(hw, REG_WOL_CTRL, 0);
+		phy_ctrl_data |= GPHY_CTRL_PHY_IDDQ | GPHY_CTRL_PWDOWN_HW;
+		wol_ctrl_data = 0;
 		hw->phy_configured = false; /* re-init PHY when resume */
 	}
 
+	AT_WRITE_REG(hw, REG_MASTER_CTRL, master_ctrl_data);
+	AT_WRITE_REG(hw, REG_MAC_CTRL, mac_ctrl_data);
+	AT_WRITE_REG(hw, REG_GPHY_CTRL, phy_ctrl_data);
+	AT_WRITE_REG(hw, REG_WOL_CTRL, wol_ctrl_data);
+
 	return 0;
 }
 
-- 
1.7.7
