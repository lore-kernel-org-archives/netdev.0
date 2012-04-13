From: xiong <xiong@qca.qualcomm.com>
Subject: [PATCH 31/37] atl1c: add function atl1c_power_saving
Date: Fri, 13 Apr 2012 08:14:56 +0800
Message-ID: <1334276102-15866-32-git-send-email-xiong@qca.qualcomm.com>
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

This function is used for suspend of S1/S3/S4 and driver remove.
It sets MAC/PHY based on the WoL configuration to get lower
power consumption.
atl1c_phy_power_saving is renamed to atl1c_phy_to_ps_link, this
function is just make PHY enter a link/speed mode to eat less
power.
REG_MAC_CTRL register is refined as well.

Signed-off-by: xiong <xiong@qca.qualcomm.com>
Tested-by: Liu David <dwliu@qca.qualcomm.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_hw.c   |   74 ++++++++++++++++---
 drivers/net/ethernet/atheros/atl1c/atl1c_hw.h   |   71 +++++++++++-------
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |   90 +----------------------
 3 files changed, 108 insertions(+), 127 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.c b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.c
index 7172d61..a077ab8 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.c
@@ -522,17 +522,9 @@ static int atl1c_phy_setup_adv(struct atl1c_hw *hw)
 
 void atl1c_phy_disable(struct atl1c_hw *hw)
 {
-	u32 phy_ctrl_data;
-
-	AT_READ_REG(hw, REG_GPHY_CTRL, &phy_ctrl_data);
-	phy_ctrl_data &= ~(GPHY_CTRL_EXT_RESET | GPHY_CTRL_CLS);
-	phy_ctrl_data |= GPHY_CTRL_SEL_ANA_RST | GPHY_CTRL_HIB_PULSE |
-			GPHY_CTRL_HIB_EN | GPHY_CTRL_PHY_IDDQ |
-			GPHY_CTRL_PWDOWN_HW;
-	AT_WRITE_REGW(hw, REG_GPHY_CTRL, phy_ctrl_data);
+	atl1c_power_saving(hw, 0);
 }
 
-
 int atl1c_phy_reset(struct atl1c_hw *hw)
 {
 	struct atl1c_adapter *adapter = hw->adapter;
@@ -719,7 +711,8 @@ int atl1c_get_speed_and_duplex(struct atl1c_hw *hw, u16 *speed, u16 *duplex)
 	return 0;
 }
 
-int atl1c_phy_power_saving(struct atl1c_hw *hw)
+/* select link mode to get lower power consumption */
+int atl1c_phy_to_ps_link(struct atl1c_hw *hw)
 {
 	struct atl1c_adapter *adapter = (struct atl1c_adapter *)hw->adapter;
 	struct pci_dev *pdev = adapter->pdev;
@@ -790,3 +783,64 @@ int atl1c_restart_autoneg(struct atl1c_hw *hw)
 
 	return atl1c_write_phy_reg(hw, MII_BMCR, mii_bmcr_data);
 }
+
+int atl1c_power_saving(struct atl1c_hw *hw, u32 wufc)
+{
+	struct atl1c_adapter *adapter = (struct atl1c_adapter *)hw->adapter;
+	struct pci_dev *pdev = adapter->pdev;
+	u32 master_ctrl, mac_ctrl, phy_ctrl;
+	u32 wol_ctrl, speed;
+	u16 phy_data;
+
+	wol_ctrl = 0;
+	speed = adapter->link_speed == SPEED_1000 ?
+		MAC_CTRL_SPEED_1000 : MAC_CTRL_SPEED_10_100;
+
+	AT_READ_REG(hw, REG_MASTER_CTRL, &master_ctrl);
+	AT_READ_REG(hw, REG_MAC_CTRL, &mac_ctrl);
+	AT_READ_REG(hw, REG_GPHY_CTRL, &phy_ctrl);
+
+	master_ctrl &= ~MASTER_CTRL_CLK_SEL_DIS;
+	mac_ctrl = FIELD_SETX(mac_ctrl, MAC_CTRL_SPEED, speed);
+	mac_ctrl &= ~(MAC_CTRL_DUPLX | MAC_CTRL_RX_EN | MAC_CTRL_TX_EN);
+	if (adapter->link_duplex == FULL_DUPLEX)
+		mac_ctrl |= MAC_CTRL_DUPLX;
+	phy_ctrl &= ~(GPHY_CTRL_EXT_RESET | GPHY_CTRL_CLS);
+	phy_ctrl |= GPHY_CTRL_SEL_ANA_RST | GPHY_CTRL_HIB_PULSE |
+		    GPHY_CTRL_HIB_EN;
+	if (!wufc) { /* without WoL */
+		master_ctrl |= MASTER_CTRL_CLK_SEL_DIS;
+		phy_ctrl |= GPHY_CTRL_PHY_IDDQ | GPHY_CTRL_PWDOWN_HW;
+		AT_WRITE_REG(hw, REG_MASTER_CTRL, master_ctrl);
+		AT_WRITE_REG(hw, REG_MAC_CTRL, mac_ctrl);
+		AT_WRITE_REG(hw, REG_GPHY_CTRL, phy_ctrl);
+		AT_WRITE_REG(hw, REG_WOL_CTRL, 0);
+		hw->phy_configured = false; /* re-init PHY when resume */
+		return 0;
+	}
+	phy_ctrl |= GPHY_CTRL_EXT_RESET;
+	if (wufc & AT_WUFC_MAG) {
+		mac_ctrl |= MAC_CTRL_RX_EN | MAC_CTRL_BC_EN;
+		wol_ctrl |= WOL_MAGIC_EN | WOL_MAGIC_PME_EN;
+		if (hw->nic_type == athr_l2c_b && hw->revision_id == L2CB_V11)
+			wol_ctrl |= WOL_PATTERN_EN | WOL_PATTERN_PME_EN;
+	}
+	if (wufc & AT_WUFC_LNKC) {
+		wol_ctrl |= WOL_LINK_CHG_EN | WOL_LINK_CHG_PME_EN;
+		if (atl1c_write_phy_reg(hw, MII_IER, IER_LINK_UP) != 0) {
+			dev_dbg(&pdev->dev, "%s: write phy MII_IER faild.\n",
+				atl1c_driver_name);
+		}
+	}
+	/* clear PHY interrupt */
+	atl1c_read_phy_reg(hw, MII_ISR, &phy_data);
+
+	dev_dbg(&pdev->dev, "%s: suspend MAC=%x,MASTER=%x,PHY=0x%x,WOL=%x\n",
+		atl1c_driver_name, mac_ctrl, master_ctrl, phy_ctrl, wol_ctrl);
+	AT_WRITE_REG(hw, REG_MASTER_CTRL, master_ctrl);
+	AT_WRITE_REG(hw, REG_MAC_CTRL, mac_ctrl);
+	AT_WRITE_REG(hw, REG_GPHY_CTRL, phy_ctrl);
+	AT_WRITE_REG(hw, REG_WOL_CTRL, wol_ctrl);
+
+	return 0;
+}
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
index eac90b2..59817ca 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
@@ -48,7 +48,8 @@ bool atl1c_read_eeprom(struct atl1c_hw *hw, u32 offset, u32 *p_value);
 int atl1c_phy_init(struct atl1c_hw *hw);
 int atl1c_check_eeprom_exist(struct atl1c_hw *hw);
 int atl1c_restart_autoneg(struct atl1c_hw *hw);
-int atl1c_phy_power_saving(struct atl1c_hw *hw);
+int atl1c_phy_to_ps_link(struct atl1c_hw *hw);
+int atl1c_power_saving(struct atl1c_hw *hw, u32 wufc);
 void atl1c_stop_phy_polling(struct atl1c_hw *hw);
 void atl1c_start_phy_polling(struct atl1c_hw *hw, u16 clk_sel);
 int atl1c_read_phy_core(struct atl1c_hw *hw, bool ext, u8 dev,
@@ -62,6 +63,16 @@ int atl1c_write_phy_ext(struct atl1c_hw *hw, u8 dev_addr,
 int atl1c_read_phy_dbg(struct atl1c_hw *hw, u16 reg_addr, u16 *phy_data);
 int atl1c_write_phy_dbg(struct atl1c_hw *hw, u16 reg_addr, u16 phy_data);
 
+/* hw-ids */
+#define PCI_DEVICE_ID_ATTANSIC_L2C      0x1062
+#define PCI_DEVICE_ID_ATTANSIC_L1C      0x1063
+#define PCI_DEVICE_ID_ATHEROS_L2C_B	0x2060 /* AR8152 v1.1 Fast 10/100 */
+#define PCI_DEVICE_ID_ATHEROS_L2C_B2	0x2062 /* AR8152 v2.0 Fast 10/100 */
+#define PCI_DEVICE_ID_ATHEROS_L1D	0x1073 /* AR8151 v1.0 Gigabit 1000 */
+#define PCI_DEVICE_ID_ATHEROS_L1D_2_0	0x1083 /* AR8151 v2.0 Gigabit 1000 */
+#define L2CB_V10			0xc0
+#define L2CB_V11			0xc1
+
 /* register definition */
 #define REG_DEVICE_CAP              	0x5C
 #define DEVICE_CAP_MAX_PAYLOAD_MASK     0x7
@@ -405,35 +416,37 @@ int atl1c_write_phy_dbg(struct atl1c_hw *hw, u16 reg_addr, u16 phy_data);
 
 /* MAC Control Register  */
 #define REG_MAC_CTRL         		0x1480
-#define MAC_CTRL_TX_EN			0x1
-#define MAC_CTRL_RX_EN			0x2
-#define MAC_CTRL_TX_FLOW		0x4
-#define MAC_CTRL_RX_FLOW            	0x8
-#define MAC_CTRL_LOOPBACK          	0x10
-#define MAC_CTRL_DUPLX              	0x20
-#define MAC_CTRL_ADD_CRC            	0x40
-#define MAC_CTRL_PAD                	0x80
-#define MAC_CTRL_LENCHK             	0x100
-#define MAC_CTRL_HUGE_EN            	0x200
-#define MAC_CTRL_PRMLEN_SHIFT       	10
-#define MAC_CTRL_PRMLEN_MASK        	0xf
-#define MAC_CTRL_RMV_VLAN           	0x4000
-#define MAC_CTRL_PROMIS_EN          	0x8000
-#define MAC_CTRL_TX_PAUSE           	0x10000
-#define MAC_CTRL_SCNT               	0x20000
-#define MAC_CTRL_SRST_TX            	0x40000
-#define MAC_CTRL_TX_SIMURST         	0x80000
+#define MAC_CTRL_SPEED_MODE_SW		BIT(30)	/* 0:phy,1:sw */
+#define MAC_CTRL_HASH_ALG_CRC32		BIT(29)	/* 1:legacy,0:lw_5b */
+#define MAC_CTRL_SINGLE_PAUSE_EN	BIT(28)
+#define MAC_CTRL_DBG			BIT(27)
+#define MAC_CTRL_BC_EN			BIT(26)
+#define MAC_CTRL_MC_ALL_EN		BIT(25)
+#define MAC_CTRL_RX_CHKSUM_EN		BIT(24)
+#define MAC_CTRL_TX_HUGE		BIT(23)
+#define MAC_CTRL_DBG_TX_BKPRESURE	BIT(22)
+#define MAC_CTRL_SPEED_MASK		3UL
 #define MAC_CTRL_SPEED_SHIFT        	20
-#define MAC_CTRL_SPEED_MASK         	0x3
-#define MAC_CTRL_DBG_TX_BKPRESURE   	0x400000
-#define MAC_CTRL_TX_HUGE            	0x800000
-#define MAC_CTRL_RX_CHKSUM_EN       	0x1000000
-#define MAC_CTRL_MC_ALL_EN          	0x2000000
-#define MAC_CTRL_BC_EN              	0x4000000
-#define MAC_CTRL_DBG                	0x8000000
-#define MAC_CTRL_SINGLE_PAUSE_EN	0x10000000
-#define MAC_CTRL_HASH_ALG_CRC32		0x20000000
-#define MAC_CTRL_SPEED_MODE_SW		0x40000000
+#define MAC_CTRL_SPEED_10_100		1
+#define MAC_CTRL_SPEED_1000		2
+#define MAC_CTRL_TX_SIMURST		BIT(19)
+#define MAC_CTRL_SCNT			BIT(17)
+#define MAC_CTRL_TX_PAUSE		BIT(16)
+#define MAC_CTRL_PROMIS_EN		BIT(15)
+#define MAC_CTRL_RMV_VLAN		BIT(14)
+#define MAC_CTRL_PRMLEN_MASK		0xFUL
+#define MAC_CTRL_PRMLEN_SHIFT		10
+#define MAC_CTRL_HUGE_EN		BIT(9)
+#define MAC_CTRL_LENCHK			BIT(8)
+#define MAC_CTRL_PAD			BIT(7)
+#define MAC_CTRL_ADD_CRC		BIT(6)
+#define MAC_CTRL_DUPLX			BIT(5)
+#define MAC_CTRL_LOOPBACK		BIT(4)
+#define MAC_CTRL_RX_FLOW		BIT(3)
+#define MAC_CTRL_TX_FLOW		BIT(2)
+#define MAC_CTRL_RX_EN			BIT(1)
+#define MAC_CTRL_TX_EN			BIT(0)
+
 
 /* MAC IPG/IFG Control Register  */
 #define REG_MAC_IPG_IFG             	0x1484
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 7f2e8eb..8c2f28c 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -24,14 +24,6 @@
 #define ATL1C_DRV_VERSION "1.0.1.0-NAPI"
 char atl1c_driver_name[] = "atl1c";
 char atl1c_driver_version[] = ATL1C_DRV_VERSION;
-#define PCI_DEVICE_ID_ATTANSIC_L2C      0x1062
-#define PCI_DEVICE_ID_ATTANSIC_L1C      0x1063
-#define PCI_DEVICE_ID_ATHEROS_L2C_B	0x2060 /* AR8152 v1.1 Fast 10/100 */
-#define PCI_DEVICE_ID_ATHEROS_L2C_B2	0x2062 /* AR8152 v2.0 Fast 10/100 */
-#define PCI_DEVICE_ID_ATHEROS_L1D	0x1073 /* AR8151 v1.0 Gigabit 1000 */
-#define PCI_DEVICE_ID_ATHEROS_L1D_2_0	0x1083 /* AR8151 v2.0 Gigabit 1000 */
-#define L2CB_V10			0xc0
-#define L2CB_V11			0xc1
 
 /*
  * atl1c_pci_tbl - PCI Device ID Table
@@ -2306,12 +2298,7 @@ static int atl1c_suspend(struct device *dev)
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct atl1c_adapter *adapter = netdev_priv(netdev);
 	struct atl1c_hw *hw = &adapter->hw;
-	u32 mac_ctrl_data = 0;
-	u32 master_ctrl_data = 0;
-	u32 wol_ctrl_data = 0;
-	u16 mii_intr_status_data = 0;
 	u32 wufc = adapter->wol;
-	u32 phy_ctrl_data;
 
 	atl1c_disable_l0s_l1(hw);
 	if (netif_running(netdev)) {
@@ -2321,82 +2308,9 @@ static int atl1c_suspend(struct device *dev)
 	netif_device_detach(netdev);
 
 	if (wufc)
-		if (atl1c_phy_power_saving(hw) != 0)
+		if (atl1c_phy_to_ps_link(hw) != 0)
 			dev_dbg(&pdev->dev, "phy power saving failed");
-
-	AT_READ_REG(hw, REG_MASTER_CTRL, &master_ctrl_data);
-	AT_READ_REG(hw, REG_MAC_CTRL, &mac_ctrl_data);
-	AT_READ_REG(hw, REG_GPHY_CTRL, &phy_ctrl_data);
-
-	master_ctrl_data &= ~MASTER_CTRL_CLK_SEL_DIS;
-	mac_ctrl_data &= ~(MAC_CTRL_PRMLEN_MASK << MAC_CTRL_PRMLEN_SHIFT);
-	mac_ctrl_data |= (((u32)adapter->hw.preamble_len &
-			MAC_CTRL_PRMLEN_MASK) <<
-			MAC_CTRL_PRMLEN_SHIFT);
-	mac_ctrl_data &= ~(MAC_CTRL_SPEED_MASK << MAC_CTRL_SPEED_SHIFT);
-	mac_ctrl_data &= ~MAC_CTRL_DUPLX;
-	phy_ctrl_data &= ~(GPHY_CTRL_EXT_RESET | GPHY_CTRL_CLS);
-	phy_ctrl_data |= GPHY_CTRL_SEL_ANA_RST | GPHY_CTRL_HIB_PULSE |
-			GPHY_CTRL_HIB_EN;
-
-	if (wufc) {
-		mac_ctrl_data |= MAC_CTRL_RX_EN;
-		phy_ctrl_data |= GPHY_CTRL_EXT_RESET;
-		if (adapter->link_speed == SPEED_1000 ||
-			adapter->link_speed == SPEED_0) {
-			mac_ctrl_data |= atl1c_mac_speed_1000 <<
-					MAC_CTRL_SPEED_SHIFT;
-			mac_ctrl_data |= MAC_CTRL_DUPLX;
-		} else
-			mac_ctrl_data |= atl1c_mac_speed_10_100 <<
-					MAC_CTRL_SPEED_SHIFT;
-
-		if (adapter->link_duplex == DUPLEX_FULL)
-			mac_ctrl_data |= MAC_CTRL_DUPLX;
-
-		/* turn on magic packet wol */
-		if (wufc & AT_WUFC_MAG) {
-			wol_ctrl_data |= WOL_MAGIC_EN | WOL_MAGIC_PME_EN;
-			if (hw->nic_type == athr_l2c_b &&
-			    hw->revision_id == L2CB_V11) {
-				wol_ctrl_data |=
-					WOL_PATTERN_EN | WOL_PATTERN_PME_EN;
-			}
-		}
-		if (wufc & AT_WUFC_LNKC) {
-			wol_ctrl_data |=  WOL_LINK_CHG_EN | WOL_LINK_CHG_PME_EN;
-			/* only link up can wake up */
-			if (atl1c_write_phy_reg(hw, MII_IER, IER_LINK_UP) != 0) {
-				dev_dbg(&pdev->dev, "%s: read write phy "
-						  "register failed.\n",
-						  atl1c_driver_name);
-			}
-		}
-		/* clear phy interrupt */
-		atl1c_read_phy_reg(hw, MII_ISR, &mii_intr_status_data);
-		/* Config MAC Ctrl register */
-		__atl1c_vlan_mode(netdev->features, &mac_ctrl_data);
-
-		/* magic packet maybe Broadcast&multicast&Unicast frame */
-		if (wufc & AT_WUFC_MAG)
-			mac_ctrl_data |= MAC_CTRL_BC_EN;
-
-		dev_dbg(&pdev->dev,
-			"%s: suspend MAC=0x%x\n",
-			atl1c_driver_name, mac_ctrl_data);
-	} else {
-		master_ctrl_data |= MASTER_CTRL_CLK_SEL_DIS;
-		mac_ctrl_data |= atl1c_mac_speed_10_100 << MAC_CTRL_SPEED_SHIFT;
-		mac_ctrl_data |= MAC_CTRL_DUPLX;
-		phy_ctrl_data |= GPHY_CTRL_PHY_IDDQ | GPHY_CTRL_PWDOWN_HW;
-		wol_ctrl_data = 0;
-		hw->phy_configured = false; /* re-init PHY when resume */
-	}
-
-	AT_WRITE_REG(hw, REG_MASTER_CTRL, master_ctrl_data);
-	AT_WRITE_REG(hw, REG_MAC_CTRL, mac_ctrl_data);
-	AT_WRITE_REG(hw, REG_GPHY_CTRL, phy_ctrl_data);
-	AT_WRITE_REG(hw, REG_WOL_CTRL, wol_ctrl_data);
+	atl1c_power_saving(hw, wufc);
 
 	return 0;
 }
-- 
1.7.7
