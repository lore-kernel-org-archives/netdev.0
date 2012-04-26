From: xiong <xiong@qca.qualcomm.com>
Subject: [PATCH 02/10] atl1c: refine phy-register read/write function
Date: Thu, 26 Apr 2012 14:27:10 +0800
Message-ID: <1335421638-16304-3-git-send-email-xiong@qca.qualcomm.com>
References: <1335421638-16304-1-git-send-email-xiong@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <qca-linux-team@qualcomm.com>, <nic-devel@qualcomm.com>,
	xiong <xiong@qca.qualcomm.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1335421638-16304-1-git-send-email-xiong@qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

phy register is read/write via MDIO control module ---
that module will be affected by the hibernate status,
to access phy regs in hib stutus, slow frequency clk must
be selected.
To access phy extension register, the MDIO related
registers are refined/updated, a _core function is
re-wroted for both regular PHY regs and extension regs.
existing PHY r/w function is revised based on the _core.
PHY extension registers will be used for the comming
patches.

Signed-off-by: xiong <xiong@qca.qualcomm.com>
Tested-by: Liu David <dwliu@qca.qualcomm.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_hw.c   |  189 ++++++++++++++++++----
 drivers/net/ethernet/atheros/atl1c/atl1c_hw.h   |   65 +++++---
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |    4 +-
 3 files changed, 197 insertions(+), 61 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.c b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.c
index bd1667c..a17b531 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.c
@@ -278,33 +278,158 @@ void atl1c_hash_set(struct atl1c_hw *hw, u32 hash_value)
 }
 
 /*
- * Reads the value from a PHY register
- * hw - Struct containing variables accessed by shared code
- * reg_addr - address of the PHY register to read
+ * wait mdio module be idle
+ * return true: idle
+ *        false: still busy
  */
-int atl1c_read_phy_reg(struct atl1c_hw *hw, u16 reg_addr, u16 *phy_data)
+bool atl1c_wait_mdio_idle(struct atl1c_hw *hw)
 {
 	u32 val;
 	int i;
 
-	val = ((u32)(reg_addr & MDIO_REG_ADDR_MASK)) << MDIO_REG_ADDR_SHIFT |
-		MDIO_START | MDIO_SUP_PREAMBLE | MDIO_RW |
-		MDIO_CLK_25_4 << MDIO_CLK_SEL_SHIFT;
+	for (i = 0; i < MDIO_MAX_AC_TO; i++) {
+		AT_READ_REG(hw, REG_MDIO_CTRL, &val);
+		if (!(val & (MDIO_CTRL_BUSY | MDIO_CTRL_START)))
+			break;
+		udelay(10);
+	}
+
+	return i != MDIO_MAX_AC_TO;
+}
 
+void atl1c_stop_phy_polling(struct atl1c_hw *hw)
+{
+	if (!(hw->ctrl_flags & ATL1C_FPGA_VERSION))
+		return;
+
+	AT_WRITE_REG(hw, REG_MDIO_CTRL, 0);
+	atl1c_wait_mdio_idle(hw);
+}
+
+void atl1c_start_phy_polling(struct atl1c_hw *hw, u16 clk_sel)
+{
+	u32 val;
+
+	if (!(hw->ctrl_flags & ATL1C_FPGA_VERSION))
+		return;
+
+	val = MDIO_CTRL_SPRES_PRMBL |
+		FIELDX(MDIO_CTRL_CLK_SEL, clk_sel) |
+		FIELDX(MDIO_CTRL_REG, 1) |
+		MDIO_CTRL_START |
+		MDIO_CTRL_OP_READ;
 	AT_WRITE_REG(hw, REG_MDIO_CTRL, val);
+	atl1c_wait_mdio_idle(hw);
+	val |= MDIO_CTRL_AP_EN;
+	val &= ~MDIO_CTRL_START;
+	AT_WRITE_REG(hw, REG_MDIO_CTRL, val);
+	udelay(30);
+}
 
-	for (i = 0; i < MDIO_WAIT_TIMES; i++) {
-		udelay(2);
-		AT_READ_REG(hw, REG_MDIO_CTRL, &val);
-		if (!(val & (MDIO_START | MDIO_BUSY)))
-			break;
+
+/*
+ * atl1c_read_phy_core
+ * core funtion to read register in PHY via MDIO control regsiter.
+ * ext: extension register (see IEEE 802.3)
+ * dev: device address (see IEEE 802.3 DEVAD, PRTAD is fixed to 0)
+ * reg: reg to read
+ */
+int atl1c_read_phy_core(struct atl1c_hw *hw, bool ext, u8 dev,
+			u16 reg, u16 *phy_data)
+{
+	u32 val;
+	u16 clk_sel = MDIO_CTRL_CLK_25_4;
+
+	atl1c_stop_phy_polling(hw);
+
+	*phy_data = 0;
+
+	/* only l2c_b2 & l1d_2 could use slow clock */
+	if ((hw->nic_type == athr_l2c_b2 || hw->nic_type == athr_l1d_2) &&
+		hw->hibernate)
+		clk_sel = MDIO_CTRL_CLK_25_128;
+	if (ext) {
+		val = FIELDX(MDIO_EXTN_DEVAD, dev) | FIELDX(MDIO_EXTN_REG, reg);
+		AT_WRITE_REG(hw, REG_MDIO_EXTN, val);
+		val = MDIO_CTRL_SPRES_PRMBL |
+			FIELDX(MDIO_CTRL_CLK_SEL, clk_sel) |
+			MDIO_CTRL_START |
+			MDIO_CTRL_MODE_EXT |
+			MDIO_CTRL_OP_READ;
+	} else {
+		val = MDIO_CTRL_SPRES_PRMBL |
+			FIELDX(MDIO_CTRL_CLK_SEL, clk_sel) |
+			FIELDX(MDIO_CTRL_REG, reg) |
+			MDIO_CTRL_START |
+			MDIO_CTRL_OP_READ;
 	}
-	if (!(val & (MDIO_START | MDIO_BUSY))) {
-		*phy_data = (u16)val;
-		return 0;
+	AT_WRITE_REG(hw, REG_MDIO_CTRL, val);
+
+	if (!atl1c_wait_mdio_idle(hw))
+		return -1;
+
+	AT_READ_REG(hw, REG_MDIO_CTRL, &val);
+	*phy_data = (u16)FIELD_GETX(val, MDIO_CTRL_DATA);
+
+	atl1c_start_phy_polling(hw, clk_sel);
+
+	return 0;
+}
+
+/*
+ * atl1c_write_phy_core
+ * core funtion to write to register in PHY via MDIO control regsiter.
+ * ext: extension register (see IEEE 802.3)
+ * dev: device address (see IEEE 802.3 DEVAD, PRTAD is fixed to 0)
+ * reg: reg to write
+ */
+int atl1c_write_phy_core(struct atl1c_hw *hw, bool ext, u8 dev,
+			u16 reg, u16 phy_data)
+{
+	u32 val;
+	u16 clk_sel = MDIO_CTRL_CLK_25_4;
+
+	atl1c_stop_phy_polling(hw);
+
+
+	/* only l2c_b2 & l1d_2 could use slow clock */
+	if ((hw->nic_type == athr_l2c_b2 || hw->nic_type == athr_l1d_2) &&
+		hw->hibernate)
+		clk_sel = MDIO_CTRL_CLK_25_128;
+
+	if (ext) {
+		val = FIELDX(MDIO_EXTN_DEVAD, dev) | FIELDX(MDIO_EXTN_REG, reg);
+		AT_WRITE_REG(hw, REG_MDIO_EXTN, val);
+		val = MDIO_CTRL_SPRES_PRMBL |
+			FIELDX(MDIO_CTRL_CLK_SEL, clk_sel) |
+			FIELDX(MDIO_CTRL_DATA, phy_data) |
+			MDIO_CTRL_START |
+			MDIO_CTRL_MODE_EXT;
+	} else {
+		val = MDIO_CTRL_SPRES_PRMBL |
+			FIELDX(MDIO_CTRL_CLK_SEL, clk_sel) |
+			FIELDX(MDIO_CTRL_DATA, phy_data) |
+			FIELDX(MDIO_CTRL_REG, reg) |
+			MDIO_CTRL_START;
 	}
+	AT_WRITE_REG(hw, REG_MDIO_CTRL, val);
 
-	return -1;
+	if (!atl1c_wait_mdio_idle(hw))
+		return -1;
+
+	atl1c_start_phy_polling(hw, clk_sel);
+
+	return 0;
+}
+
+/*
+ * Reads the value from a PHY register
+ * hw - Struct containing variables accessed by shared code
+ * reg_addr - address of the PHY register to read
+ */
+int atl1c_read_phy_reg(struct atl1c_hw *hw, u16 reg_addr, u16 *phy_data)
+{
+	return atl1c_read_phy_core(hw, false, 0, reg_addr, phy_data);
 }
 
 /*
@@ -315,27 +440,21 @@ int atl1c_read_phy_reg(struct atl1c_hw *hw, u16 reg_addr, u16 *phy_data)
  */
 int atl1c_write_phy_reg(struct atl1c_hw *hw, u32 reg_addr, u16 phy_data)
 {
-	int i;
-	u32 val;
-
-	val = ((u32)(phy_data & MDIO_DATA_MASK)) << MDIO_DATA_SHIFT   |
-	       (reg_addr & MDIO_REG_ADDR_MASK) << MDIO_REG_ADDR_SHIFT |
-	       MDIO_SUP_PREAMBLE | MDIO_START |
-	       MDIO_CLK_25_4 << MDIO_CLK_SEL_SHIFT;
-
-	AT_WRITE_REG(hw, REG_MDIO_CTRL, val);
-
-	for (i = 0; i < MDIO_WAIT_TIMES; i++) {
-		udelay(2);
-		AT_READ_REG(hw, REG_MDIO_CTRL, &val);
-		if (!(val & (MDIO_START | MDIO_BUSY)))
-			break;
-	}
+	return atl1c_write_phy_core(hw, false, 0, reg_addr, phy_data);
+}
 
-	if (!(val & (MDIO_START | MDIO_BUSY)))
-		return 0;
+/* read from PHY extension register */
+int atl1c_read_phy_ext(struct atl1c_hw *hw, u8 dev_addr,
+			u16 reg_addr, u16 *phy_data)
+{
+	return atl1c_read_phy_core(hw, true, dev_addr, reg_addr, phy_data);
+}
 
-	return -1;
+/* write to PHY extension register */
+int atl1c_write_phy_ext(struct atl1c_hw *hw, u8 dev_addr,
+			u16 reg_addr, u16 phy_data)
+{
+	return atl1c_write_phy_core(hw, true, dev_addr, reg_addr, phy_data);
 }
 
 /*
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
index 459e141..cb2d20b 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
@@ -49,6 +49,17 @@ int atl1c_phy_init(struct atl1c_hw *hw);
 int atl1c_check_eeprom_exist(struct atl1c_hw *hw);
 int atl1c_restart_autoneg(struct atl1c_hw *hw);
 int atl1c_phy_power_saving(struct atl1c_hw *hw);
+bool atl1c_wait_mdio_idle(struct atl1c_hw *hw);
+void atl1c_stop_phy_polling(struct atl1c_hw *hw);
+void atl1c_start_phy_polling(struct atl1c_hw *hw, u16 clk_sel);
+int atl1c_read_phy_core(struct atl1c_hw *hw, bool ext, u8 dev,
+			u16 reg, u16 *phy_data);
+int atl1c_write_phy_core(struct atl1c_hw *hw, bool ext, u8 dev,
+			u16 reg, u16 phy_data);
+int atl1c_read_phy_ext(struct atl1c_hw *hw, u8 dev_addr,
+			u16 reg_addr, u16 *phy_data);
+int atl1c_write_phy_ext(struct atl1c_hw *hw, u8 dev_addr,
+			u16 reg_addr, u16 phy_data);
 /* register definition */
 #define REG_DEVICE_CAP              	0x5C
 #define DEVICE_CAP_MAX_PAYLOAD_MASK     0x7
@@ -268,30 +279,36 @@ int atl1c_phy_power_saving(struct atl1c_hw *hw);
 
 /* MDIO Control Register */
 #define REG_MDIO_CTRL           	0x1414
-#define MDIO_DATA_MASK          	0xffff  /* On MDIO write, the 16-bit
-						 * control data to write to PHY
-						 * MII management register */
-#define MDIO_DATA_SHIFT         	0       /* On MDIO read, the 16-bit
-						 * status data that was read
-						 * from the PHY MII management register */
-#define MDIO_REG_ADDR_MASK      	0x1f    /* MDIO register address */
-#define MDIO_REG_ADDR_SHIFT     	16
-#define MDIO_RW                 	0x200000  /* 1: read, 0: write */
-#define MDIO_SUP_PREAMBLE       	0x400000  /* Suppress preamble */
-#define MDIO_START              	0x800000  /* Write 1 to initiate the MDIO
-						   * master. And this bit is self
-						   * cleared after one cycle */
-#define MDIO_CLK_SEL_SHIFT      	24
-#define MDIO_CLK_25_4           	0
-#define MDIO_CLK_25_6           	2
-#define MDIO_CLK_25_8           	3
-#define MDIO_CLK_25_10          	4
-#define MDIO_CLK_25_14          	5
-#define MDIO_CLK_25_20          	6
-#define MDIO_CLK_25_28          	7
-#define MDIO_BUSY               	0x8000000
-#define MDIO_AP_EN              	0x10000000
-#define MDIO_WAIT_TIMES         	10
+#define MDIO_CTRL_MODE_EXT		BIT(30)
+#define MDIO_CTRL_POST_READ		BIT(29)
+#define MDIO_CTRL_AP_EN			BIT(28)
+#define MDIO_CTRL_BUSY			BIT(27)
+#define MDIO_CTRL_CLK_SEL_MASK		0x7UL
+#define MDIO_CTRL_CLK_SEL_SHIFT		24
+#define MDIO_CTRL_CLK_25_4		0	/* 25MHz divide 4 */
+#define MDIO_CTRL_CLK_25_6		2
+#define MDIO_CTRL_CLK_25_8		3
+#define MDIO_CTRL_CLK_25_10		4
+#define MDIO_CTRL_CLK_25_32		5
+#define MDIO_CTRL_CLK_25_64		6
+#define MDIO_CTRL_CLK_25_128		7
+#define MDIO_CTRL_START			BIT(23)
+#define MDIO_CTRL_SPRES_PRMBL		BIT(22)
+#define MDIO_CTRL_OP_READ		BIT(21)	/* 1:read, 0:write */
+#define MDIO_CTRL_REG_MASK		0x1FUL
+#define MDIO_CTRL_REG_SHIFT		16
+#define MDIO_CTRL_DATA_MASK		0xFFFFUL
+#define MDIO_CTRL_DATA_SHIFT		0
+#define MDIO_MAX_AC_TO			120	/* 1.2ms timeout for slow clk */
+
+/* for extension reg access */
+#define REG_MDIO_EXTN			0x1448
+#define MDIO_EXTN_PORTAD_MASK		0x1FUL
+#define MDIO_EXTN_PORTAD_SHIFT		21
+#define MDIO_EXTN_DEVAD_MASK		0x1FUL
+#define MDIO_EXTN_DEVAD_SHIFT		16
+#define MDIO_EXTN_REG_MASK		0xFFFFUL
+#define MDIO_EXTN_REG_SHIFT		0
 
 /* BIST Control and Status Register0 (for the Packet Memory) */
 #define REG_BIST0_CTRL              	0x141c
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index a6c3f05..1f82880 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -2270,7 +2270,7 @@ static int atl1c_open(struct net_device *netdev)
 		u32 phy_data;
 
 		AT_READ_REG(&adapter->hw, REG_MDIO_CTRL, &phy_data);
-		phy_data |= MDIO_AP_EN;
+		phy_data |= MDIO_CTRL_AP_EN;
 		AT_WRITE_REG(&adapter->hw, REG_MDIO_CTRL, phy_data);
 	}
 	return 0;
@@ -2558,7 +2558,7 @@ static int __devinit atl1c_probe(struct pci_dev *pdev,
 	adapter->mii.mdio_read  = atl1c_mdio_read;
 	adapter->mii.mdio_write = atl1c_mdio_write;
 	adapter->mii.phy_id_mask = 0x1f;
-	adapter->mii.reg_num_mask = MDIO_REG_ADDR_MASK;
+	adapter->mii.reg_num_mask = MDIO_CTRL_REG_MASK;
 	netif_napi_add(netdev, &adapter->napi, atl1c_clean, 64);
 	setup_timer(&adapter->phy_config_timer, atl1c_phy_config,
 			(unsigned long)adapter);
-- 
1.7.7
