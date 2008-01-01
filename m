From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 12/26] atl1: refactor atl1_probe
Date: Mon, 31 Dec 2007 20:22:39 -0600
Message-ID: <1199154173-4058-13-git-send-email-jacliburn@bellsouth.net>
References: <1199154173-4058-1-git-send-email-jacliburn@bellsouth.net>
Cc: Jay Cliburn <jacliburn@bellsouth.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost02.isp.att.net ([204.127.217.102]:63805 "EHLO
	fmailhost02.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752313AbYAAC2O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 21:28:14 -0500
In-Reply-To: <1199154173-4058-1-git-send-email-jacliburn@bellsouth.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Refactor atl1_probe to conform with current vendor driver version 1.2.40.2.
Also reorder functions to minimize the need for forward declarations.

Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
---
 drivers/net/atlx/atl1.c | 1397 +++++++++++++++++++++++------------------------
 drivers/net/atlx/atl1.h |   21 +-
 2 files changed, 691 insertions(+), 727 deletions(-)

diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index e96f706..d38f26f 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -101,17 +101,681 @@ static const struct pci_device_id atl1_pci_tbl[] = {
 MODULE_DEVICE_TABLE(pci, atl1_pci_tbl);
 
 /*
+ * Reset the transmit and receive units; mask and clear all interrupts.
+ * hw - Struct containing variables accessed by shared code
+ * return : 0  or  idle status (if error)
+ */
+static s32 atl1_reset_hw(struct atl1_hw *hw)
+{
+	struct pci_dev *pdev = hw->back->pdev;
+	u32 icr;
+	int i;
+
+	/*
+	 * Issue Soft Reset to the MAC.  This will reset the chip's
+	 * transmit, receive, DMA.  It will not effect
+	 * the current PCI configuration.  The global reset bit is self-
+	 * clearing, and should clear within a microsecond.
+	 */
+	iowrite32(MASTER_CTRL_SOFT_RST, hw->hw_addr + REG_MASTER_CTRL);
+	ioread32(hw->hw_addr + REG_MASTER_CTRL);
+
+	/* delay about 1ms */
+	msleep(1);
+
+	/* wait at least 10ms for idle */
+	for (i = 0; i < 10; i++) {
+		icr = ioread32(hw->hw_addr + REG_IDLE_STATUS);
+		if (!icr)
+			break;
+		/* delay 1 ms */
+		msleep(1);
+		cpu_relax();
+	}
+
+	if (icr) {
+		dev_dbg(&pdev->dev, "ICR = 0x%x\n", icr);
+		return icr;
+	}
+
+	return 0;
+}
+
+/* function about EEPROM
+ *
+ * check_eeprom_exist
+ * return 0 if eeprom exist
+ */
+static int atl1_check_eeprom_exist(struct atl1_hw *hw)
+{
+	u32 value;
+
+	value = ioread32(hw->hw_addr + REG_SPI_FLASH_CTRL);
+	if (value & SPI_FLASH_CTRL_EN_VPD) {
+		value &= ~SPI_FLASH_CTRL_EN_VPD;
+		iowrite32(value, hw->hw_addr + REG_SPI_FLASH_CTRL);
+	}
+
+	value = ioread16(hw->hw_addr + REG_PCIE_CAP_LIST);
+	return ((value & 0xFF00) == 0x6C00) ? 0 : 1;
+}
+
+static bool atl1_read_eeprom(struct atl1_hw *hw, u32 offset, u32 *p_value)
+{
+	int i;
+	u32 control;
+
+	if (offset & 3)
+		/* address do not align */
+		return false;
+
+	iowrite32(0, hw->hw_addr + REG_VPD_DATA);
+	control = (offset & VPD_CAP_VPD_ADDR_MASK) << VPD_CAP_VPD_ADDR_SHIFT;
+	iowrite32(control, hw->hw_addr + REG_VPD_CAP);
+	ioread32(hw->hw_addr + REG_VPD_CAP);
+
+	for (i = 0; i < 10; i++) {
+		msleep(2);
+		control = ioread32(hw->hw_addr + REG_VPD_CAP);
+		if (control & VPD_CAP_VPD_FLAG)
+			break;
+	}
+	if (control & VPD_CAP_VPD_FLAG) {
+		*p_value = ioread32(hw->hw_addr + REG_VPD_DATA);
+		return true;
+	}
+	/* timeout */
+	return false;
+}
+
+/*
+ * Reads the value from a PHY register
+ * hw - Struct containing variables accessed by shared code
+ * reg_addr - address of the PHY register to read
+ */
+static s32 atl1_read_phy_reg(struct atl1_hw *hw, u16 reg_addr, u16 *phy_data)
+{
+	u32 val;
+	int i;
+
+	val = ((u32) (reg_addr & MDIO_REG_ADDR_MASK)) << MDIO_REG_ADDR_SHIFT |
+		MDIO_START | MDIO_SUP_PREAMBLE | MDIO_RW | MDIO_CLK_25_4 <<
+		MDIO_CLK_SEL_SHIFT;
+	iowrite32(val, hw->hw_addr + REG_MDIO_CTRL);
+	ioread32(hw->hw_addr + REG_MDIO_CTRL);
+
+	for (i = 0; i < MDIO_WAIT_TIMES; i++) {
+		udelay(2);
+		val = ioread32(hw->hw_addr + REG_MDIO_CTRL);
+		if (!(val & (MDIO_START | MDIO_BUSY)))
+			break;
+	}
+	if (!(val & (MDIO_START | MDIO_BUSY))) {
+		*phy_data = (u16) val;
+		return 0;
+	}
+	return ATLX_ERR_PHY;
+}
+
+#define CUSTOM_SPI_CS_SETUP	2
+#define CUSTOM_SPI_CLK_HI	2
+#define CUSTOM_SPI_CLK_LO	2
+#define CUSTOM_SPI_CS_HOLD	2
+#define CUSTOM_SPI_CS_HI	3
+
+static bool atl1_spi_read(struct atl1_hw *hw, u32 addr, u32 *buf)
+{
+	int i;
+	u32 value;
+
+	iowrite32(0, hw->hw_addr + REG_SPI_DATA);
+	iowrite32(addr, hw->hw_addr + REG_SPI_ADDR);
+
+	value = SPI_FLASH_CTRL_WAIT_READY |
+	    (CUSTOM_SPI_CS_SETUP & SPI_FLASH_CTRL_CS_SETUP_MASK) <<
+	    SPI_FLASH_CTRL_CS_SETUP_SHIFT | (CUSTOM_SPI_CLK_HI &
+					     SPI_FLASH_CTRL_CLK_HI_MASK) <<
+	    SPI_FLASH_CTRL_CLK_HI_SHIFT | (CUSTOM_SPI_CLK_LO &
+					   SPI_FLASH_CTRL_CLK_LO_MASK) <<
+	    SPI_FLASH_CTRL_CLK_LO_SHIFT | (CUSTOM_SPI_CS_HOLD &
+					   SPI_FLASH_CTRL_CS_HOLD_MASK) <<
+	    SPI_FLASH_CTRL_CS_HOLD_SHIFT | (CUSTOM_SPI_CS_HI &
+					    SPI_FLASH_CTRL_CS_HI_MASK) <<
+	    SPI_FLASH_CTRL_CS_HI_SHIFT | (1 & SPI_FLASH_CTRL_INS_MASK) <<
+	    SPI_FLASH_CTRL_INS_SHIFT;
+
+	iowrite32(value, hw->hw_addr + REG_SPI_FLASH_CTRL);
+
+	value |= SPI_FLASH_CTRL_START;
+	iowrite32(value, hw->hw_addr + REG_SPI_FLASH_CTRL);
+	ioread32(hw->hw_addr + REG_SPI_FLASH_CTRL);
+
+	for (i = 0; i < 10; i++) {
+		msleep(1);
+		value = ioread32(hw->hw_addr + REG_SPI_FLASH_CTRL);
+		if (!(value & SPI_FLASH_CTRL_START))
+			break;
+	}
+
+	if (value & SPI_FLASH_CTRL_START)
+		return false;
+
+	*buf = ioread32(hw->hw_addr + REG_SPI_DATA);
+
+	return true;
+}
+
+/*
+ * get_permanent_address
+ * return 0 if get valid mac address,
+ */
+static int atl1_get_permanent_address(struct atl1_hw *hw)
+{
+	u32 addr[2];
+	u32 i, control;
+	u16 reg;
+	u8 eth_addr[ETH_ALEN];
+	bool key_valid;
+
+	if (is_valid_ether_addr(hw->perm_mac_addr))
+		return 0;
+
+	/* init */
+	addr[0] = addr[1] = 0;
+
+	if (!atl1_check_eeprom_exist(hw)) {
+		reg = 0;
+		key_valid = false;
+		/* Read out all EEPROM content */
+		i = 0;
+		while (1) {
+			if (atl1_read_eeprom(hw, i + 0x100, &control)) {
+				if (key_valid) {
+					if (reg == REG_MAC_STA_ADDR)
+						addr[0] = control;
+					else if (reg == (REG_MAC_STA_ADDR + 4))
+						addr[1] = control;
+					key_valid = false;
+				} else if ((control & 0xff) == 0x5A) {
+					key_valid = true;
+					reg = (u16) (control >> 16);
+				} else
+					break;
+			} else
+				/* read error */
+				break;
+			i += 4;
+		}
+
+		*(u32 *) &eth_addr[2] = swab32(addr[0]);
+		*(u16 *) &eth_addr[0] = swab16(*(u16 *) &addr[1]);
+		if (is_valid_ether_addr(eth_addr)) {
+			memcpy(hw->perm_mac_addr, eth_addr, ETH_ALEN);
+			return 0;
+		}
+		return 1;
+	}
+
+	/* see if SPI FLAGS exist ? */
+	addr[0] = addr[1] = 0;
+	reg = 0;
+	key_valid = false;
+	i = 0;
+	while (1) {
+		if (atl1_spi_read(hw, i + 0x1f000, &control)) {
+			if (key_valid) {
+				if (reg == REG_MAC_STA_ADDR)
+					addr[0] = control;
+				else if (reg == (REG_MAC_STA_ADDR + 4))
+					addr[1] = control;
+				key_valid = false;
+			} else if ((control & 0xff) == 0x5A) {
+				key_valid = true;
+				reg = (u16) (control >> 16);
+			} else
+				/* data end */
+				break;
+		} else
+			/* read error */
+			break;
+		i += 4;
+	}
+
+	*(u32 *) &eth_addr[2] = swab32(addr[0]);
+	*(u16 *) &eth_addr[0] = swab16(*(u16 *) &addr[1]);
+	if (is_valid_ether_addr(eth_addr)) {
+		memcpy(hw->perm_mac_addr, eth_addr, ETH_ALEN);
+		return 0;
+	}
+
+	/*
+	 * On some motherboards, the MAC address is written by the
+	 * BIOS directly to the MAC register during POST, and is
+	 * not stored in eeprom.  If all else thus far has failed
+	 * to fetch the permanent MAC address, try reading it directly.
+	 */
+	addr[0] = ioread32(hw->hw_addr + REG_MAC_STA_ADDR);
+	addr[1] = ioread16(hw->hw_addr + (REG_MAC_STA_ADDR + 4));
+	*(u32 *) &eth_addr[2] = swab32(addr[0]);
+	*(u16 *) &eth_addr[0] = swab16(*(u16 *) &addr[1]);
+	if (is_valid_ether_addr(eth_addr)) {
+		memcpy(hw->perm_mac_addr, eth_addr, ETH_ALEN);
+		return 0;
+	}
+
+	return 1;
+}
+
+/*
+ * Reads the adapter's MAC address from the EEPROM
+ * hw - Struct containing variables accessed by shared code
+ */
+static s32 atl1_read_mac_addr(struct atl1_hw *hw)
+{
+	u16 i;
+
+	if (atl1_get_permanent_address(hw))
+		random_ether_addr(hw->perm_mac_addr);
+
+	for (i = 0; i < ETH_ALEN; i++)
+		hw->mac_addr[i] = hw->perm_mac_addr[i];
+	return 0;
+}
+
+/*
+ * Hashes an address to determine its location in the multicast table
+ * hw - Struct containing variables accessed by shared code
+ * mc_addr - the multicast address to hash
+ *
+ * atl1_hash_mc_addr
+ *  purpose
+ *      set hash value for a multicast address
+ *      hash calcu processing :
+ *          1. calcu 32bit CRC for multicast address
+ *          2. reverse crc with MSB to LSB
+ */
+static u32 atl1_hash_mc_addr(struct atl1_hw *hw, u8 *mc_addr)
+{
+	u32 crc32, value = 0;
+	int i;
+
+	crc32 = ether_crc_le(6, mc_addr);
+	for (i = 0; i < 32; i++)
+		value |= (((crc32 >> i) & 1) << (31 - i));
+
+	return value;
+}
+
+/*
+ * Sets the bit in the multicast table corresponding to the hash value.
+ * hw - Struct containing variables accessed by shared code
+ * hash_value - Multicast address hash value
+ */
+static void atl1_hash_set(struct atl1_hw *hw, u32 hash_value)
+{
+	u32 hash_bit, hash_reg;
+	u32 mta;
+
+	/*
+	 * The HASH Table  is a register array of 2 32-bit registers.
+	 * It is treated like an array of 64 bits.  We want to set
+	 * bit BitArray[hash_value]. So we figure out what register
+	 * the bit is in, read it, OR in the new bit, then write
+	 * back the new value.  The register is determined by the
+	 * upper 7 bits of the hash value and the bit within that
+	 * register are determined by the lower 5 bits of the value.
+	 */
+	hash_reg = (hash_value >> 31) & 0x1;
+	hash_bit = (hash_value >> 26) & 0x1F;
+	mta = ioread32((hw->hw_addr + REG_RX_HASH_TABLE) + (hash_reg << 2));
+	mta |= (1 << hash_bit);
+	iowrite32(mta, (hw->hw_addr + REG_RX_HASH_TABLE) + (hash_reg << 2));
+}
+
+/*
+ * Writes a value to a PHY register
+ * hw - Struct containing variables accessed by shared code
+ * reg_addr - address of the PHY register to write
+ * data - data to write to the PHY
+ */
+static s32 atl1_write_phy_reg(struct atl1_hw *hw, u32 reg_addr, u16 phy_data)
+{
+	int i;
+	u32 val;
+
+	val = ((u32) (phy_data & MDIO_DATA_MASK)) << MDIO_DATA_SHIFT |
+	    (reg_addr & MDIO_REG_ADDR_MASK) << MDIO_REG_ADDR_SHIFT |
+	    MDIO_SUP_PREAMBLE |
+	    MDIO_START | MDIO_CLK_25_4 << MDIO_CLK_SEL_SHIFT;
+	iowrite32(val, hw->hw_addr + REG_MDIO_CTRL);
+	ioread32(hw->hw_addr + REG_MDIO_CTRL);
+
+	for (i = 0; i < MDIO_WAIT_TIMES; i++) {
+		udelay(2);
+		val = ioread32(hw->hw_addr + REG_MDIO_CTRL);
+		if (!(val & (MDIO_START | MDIO_BUSY)))
+			break;
+	}
+
+	if (!(val & (MDIO_START | MDIO_BUSY)))
+		return 0;
+
+	return ATLX_ERR_PHY;
+}
+
+/*
+ * Configures PHY autoneg and flow control advertisement settings
+ * hw - Struct containing variables accessed by shared code
+ */
+static s32 atl1_phy_setup_autoneg_adv(struct atl1_hw *hw)
+{
+	s32 ret_val;
+	s16 mii_autoneg_adv_reg;
+	s16 mii_1000t_ctrl_reg;
+
+	/* Read the MII Auto-Neg Advertisement Register (Address 4). */
+	mii_autoneg_adv_reg = MII_AR_DEFAULT_CAP_MASK;
+
+	/* Read the MII 1000Base-T Control Register (Address 9). */
+	mii_1000t_ctrl_reg = MII_ATLX_CR_1000T_DEFAULT_CAP_MASK;
+
+	/*
+	 * First we clear all the 10/100 mb speed bits in the Auto-Neg
+	 * Advertisement Register (Address 4) and the 1000 mb speed bits in
+	 * the  1000Base-T Control Register (Address 9).
+	 */
+	mii_autoneg_adv_reg &= ~MII_AR_SPEED_MASK;
+	mii_1000t_ctrl_reg &= ~MII_ATLX_CR_1000T_SPEED_MASK;
+
+	/*
+	 * Need to parse media_type  and set up
+	 * the appropriate PHY registers.
+	 */
+	switch (hw->media_type) {
+	case MEDIA_TYPE_AUTO_SENSOR:
+		mii_autoneg_adv_reg |= (MII_AR_10T_HD_CAPS |
+					MII_AR_10T_FD_CAPS |
+					MII_AR_100TX_HD_CAPS |
+					MII_AR_100TX_FD_CAPS);
+		mii_1000t_ctrl_reg |= MII_ATLX_CR_1000T_FD_CAPS;
+		hw->autoneg_advertised = ADVERTISE_10_HALF |
+					ADVERTISE_10_FULL  |
+					ADVERTISE_100_HALF |
+					ADVERTISE_100_FULL |
+					ADVERTISE_1000_FULL;
+		break;
+
+	case MEDIA_TYPE_100M_FULL:
+		mii_1000t_ctrl_reg |= MII_AR_100TX_FD_CAPS;
+		hw->autoneg_advertised = ADVERTISE_100_FULL;
+		break;
+
+	case MEDIA_TYPE_100M_HALF:
+		mii_autoneg_adv_reg |= MII_AR_100TX_HD_CAPS;
+		hw->autoneg_advertised = ADVERTISE_100_HALF;
+		break;
+
+	case MEDIA_TYPE_10M_FULL:
+		mii_autoneg_adv_reg |= MII_AR_10T_FD_CAPS;
+		hw->autoneg_advertised = ADVERTISE_10_FULL;
+		break;
+
+	default:
+		mii_autoneg_adv_reg |= MII_AR_10T_HD_CAPS;
+		hw->autoneg_advertised = ADVERTISE_10_HALF;
+		break;
+	}
+
+	/* flow control fixed to enable all */
+	mii_autoneg_adv_reg |= (MII_AR_ASM_DIR | MII_AR_PAUSE);
+
+	hw->mii_autoneg_adv_reg = mii_autoneg_adv_reg;
+	hw->mii_1000t_ctrl_reg = mii_1000t_ctrl_reg;
+
+	ret_val = atl1_write_phy_reg(hw, MII_ADVERTISE, mii_autoneg_adv_reg);
+	if (ret_val)
+		return ret_val;
+
+	ret_val = atl1_write_phy_reg(hw, MII_ATLX_CR, mii_1000t_ctrl_reg);
+	if (ret_val)
+		return ret_val;
+
+	return 0;
+}
+
+static void atl1_init_flash_opcode(struct atl1_hw *hw)
+{
+	if (hw->flash_vendor >= ARRAY_SIZE(flash_table))
+		/* Atmel */
+		hw->flash_vendor = 0;
+
+	/* Init OP table */
+	iowrite8(flash_table[hw->flash_vendor].cmd_program,
+		hw->hw_addr + REG_SPI_FLASH_OP_PROGRAM);
+	iowrite8(flash_table[hw->flash_vendor].cmd_sector_erase,
+		hw->hw_addr + REG_SPI_FLASH_OP_SC_ERASE);
+	iowrite8(flash_table[hw->flash_vendor].cmd_chip_erase,
+		hw->hw_addr + REG_SPI_FLASH_OP_CHIP_ERASE);
+	iowrite8(flash_table[hw->flash_vendor].cmd_rdid,
+		hw->hw_addr + REG_SPI_FLASH_OP_RDID);
+	iowrite8(flash_table[hw->flash_vendor].cmd_wren,
+		hw->hw_addr + REG_SPI_FLASH_OP_WREN);
+	iowrite8(flash_table[hw->flash_vendor].cmd_rdsr,
+		hw->hw_addr + REG_SPI_FLASH_OP_RDSR);
+	iowrite8(flash_table[hw->flash_vendor].cmd_wrsr,
+		hw->hw_addr + REG_SPI_FLASH_OP_WRSR);
+	iowrite8(flash_table[hw->flash_vendor].cmd_read,
+		hw->hw_addr + REG_SPI_FLASH_OP_READ);
+}
+
+static void atl1_init_pcie(struct atl1_hw *hw)
+{
+	u32 val;
+
+	val = LTSSM_TEST_MODE_DEF;
+	iowrite32(val, hw->hw_addr + REG_LTSSM_TEST_MODE);
+	val = ioread32(hw->hw_addr + REG_PCIE_PHY_MISC3);
+	val |= PCIE_PHY_MISC3_DS_PWR_DOWN;
+	iowrite32(val, hw->hw_addr + REG_PCIE_PHY_MISC3);
+}
+
+static bool atl1_check_cable(struct atl1_hw *hw)
+{
+	u16 pair_num;
+	u16 i;
+	u16 phy_val;
+
+	phy_val = 0x8000;
+	atl1_write_phy_reg(hw, MII_BMCR, phy_val);
+
+	for (pair_num = 0; pair_num < 4; pair_num++) {
+		phy_val = (u16) (pair_num << CDTC_PAIR_OFFSET);
+		phy_val |= CDTC_EN;
+		atl1_write_phy_reg(hw, MII_CDTC, phy_val);
+		for (i = 0; i < 200; i++) {
+			msleep(1);
+			atl1_read_phy_reg(hw, MII_CDTC, &phy_val);
+			if (!(phy_val & CDTC_EN))
+				break;
+		}
+		msleep(1);
+		atl1_read_phy_reg(hw, MII_CDTS, &phy_val);
+		if (((phy_val >> CDTS_STATUS_OFFSET) & 3) != CDTS_OPEN)
+			return true;
+	}
+	return false;
+}
+static s32 atl1_phy_commit(struct atl1_hw *hw)
+{
+	s32 retval;
+	u16 phy_data;
+	u32 val;
+	int i;
+
+	phy_data = MII_CR_RESET | MII_CR_AUTO_NEG_EN | MII_CR_RESTART_AUTO_NEG;
+	retval = atl1_write_phy_reg(hw, MII_BMCR, phy_data);
+	if (retval) {
+		for (i = 0; i < 25; i++) {
+			msleep(1);
+			val = ioread32(hw->hw_addr + REG_MDIO_CTRL);
+			if (!(val & (MDIO_START | MDIO_BUSY)))
+				break;
+		}
+		if (val & (MDIO_START | MDIO_BUSY))
+			return retval;
+	}
+	return 0;
+}
+
+static s32 atl1_phy_init(struct atl1_hw *hw)
+{
+	u16 phy_data;
+	u16 i;
+	s32 retval;
+
+	if (hw->phy_configured)
+		return 0;
+
+	iowrite16(0, hw->hw_addr + REG_PHY_ENABLE);
+	msleep(2);
+	iowrite16(PHY_RESET, hw->hw_addr + REG_PHY_ENABLE);
+	msleep(2);
+
+	/* check for cable */
+	if (!atl1_check_cable(hw))
+		set_bit(0, &hw->force_ps);
+	else
+		clear_bit(0, &hw->force_ps);
+
+	/* enable PHY link change interrupt */
+	retval = atl1_write_phy_reg(hw, 18, 0xC00);
+	if (retval)
+		return retval;
+
+	/* setup autonegotiation parameters */
+	retval = atl1_phy_setup_autoneg_adv(hw);
+	if (retval)
+		return retval;
+
+	retval = atl1_phy_commit(hw);
+	if (retval)
+		return retval;
+
+	if (test_bit(0, &hw->force_ps)) {
+		atl1_write_phy_reg(hw, MII_DBG_ADDR, 0);
+		atl1_write_phy_reg(hw, MII_DBG_DATA, 0x124E);
+		atl1_write_phy_reg(hw, MII_DBG_ADDR, 1);
+		atl1_read_phy_reg(hw, MII_DBG_DATA, &phy_data);
+		phy_data |= 0x3;
+		atl1_write_phy_reg(hw, MII_DBG_DATA, phy_data);
+
+		for (i = 0; i < 15; i++)
+			msleep(100);
+		atl1_write_phy_reg(hw, MII_DBG_ADDR, 0);
+		atl1_write_phy_reg(hw, MII_DBG_DATA, 0x024E);
+	}
+	hw->phy_configured = true;
+	return retval;
+}
+
+/*
+ * Performs basic configuration of the adapter.
+ * hw - Struct containing variables accessed by shared code
+ * Assumes that the controller has previously been reset and is in a
+ * post-reset uninitialized state. Initializes multicast table,
+ * and  Calls routines to setup link
+ * Leaves the transmit and receive units disabled and uninitialized.
+ */
+static s32 atl1_init_hw(struct atl1_hw *hw)
+{
+	u32 retval = 0;
+
+	atl1_init_pcie(hw);
+	iowrite32(0, hw->hw_addr + REG_RX_HASH_TABLE);
+	iowrite32(0, (hw->hw_addr + REG_RX_HASH_TABLE) + (1 << 2));
+	atl1_init_flash_opcode(hw);
+	retval = atl1_phy_init(hw);
+
+	return retval;
+}
+
+/*
+ * Detects the current speed and duplex settings of the hardware.
+ * hw - Struct containing variables accessed by shared code
+ * speed - Speed of the connection
+ * duplex - Duplex setting of the connection
+ */
+static s32 atl1_get_speed_and_duplex(struct atl1_hw *hw, u16 *speed,
+	u16 *duplex)
+{
+	struct pci_dev *pdev = hw->back->pdev;
+	s32 ret_val;
+	u16 phy_data;
+
+	/* ; --- Read   PHY Specific Status Register (17) */
+	ret_val = atl1_read_phy_reg(hw, MII_ATLX_PSSR, &phy_data);
+	if (ret_val)
+		return ret_val;
+
+	if (!(phy_data & MII_ATLX_PSSR_SPD_DPLX_RESOLVED))
+		return ATLX_ERR_PHY_RES;
+
+	switch (phy_data & MII_ATLX_PSSR_SPEED) {
+	case MII_ATLX_PSSR_1000MBS:
+		*speed = SPEED_1000;
+		break;
+	case MII_ATLX_PSSR_100MBS:
+		*speed = SPEED_100;
+		break;
+	case MII_ATLX_PSSR_10MBS:
+		*speed = SPEED_10;
+		break;
+	default:
+		dev_dbg(&pdev->dev, "error getting speed\n");
+		return ATLX_ERR_PHY_SPEED;
+		break;
+	}
+	if (phy_data & MII_ATLX_PSSR_DPLX)
+		*duplex = FULL_DUPLEX;
+	else
+		*duplex = HALF_DUPLEX;
+
+	return 0;
+}
+
+static void atl1_set_mac_addr(struct atl1_hw *hw)
+{
+	u32 value;
+	/*
+	 * 00-0B-6A-F6-00-DC
+	 * 0:  6AF600DC   1: 000B
+	 * low dword
+	 */
+	value = (((u32) hw->mac_addr[2]) << 24) |
+	    (((u32) hw->mac_addr[3]) << 16) |
+	    (((u32) hw->mac_addr[4]) << 8) | (((u32) hw->mac_addr[5]));
+	iowrite32(value, hw->hw_addr + REG_MAC_STA_ADDR);
+	/* high dword */
+	value = (((u32) hw->mac_addr[0]) << 8) | (((u32) hw->mac_addr[1]));
+	iowrite32(value, (hw->hw_addr + REG_MAC_STA_ADDR) + (1 << 2));
+}
+
+static int atl1_alloc_queues(struct atl1_adapter *adapter)
+{
+	/* temporary placeholder function for NAPI */
+
+	return 0;
+}
+
+/*
  * atl1_sw_init - Initialize general software structures (struct atl1_adapter)
  * @adapter: board private structure to initialize
- *
- * atl1_sw_init initializes the Adapter private data structure.
- * Fields are initialized based on PCI device information and
- * OS network device settings (MTU size).
  */
 static int __devinit atl1_sw_init(struct atl1_adapter *adapter)
 {
 	struct atl1_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
+	int err;
 
 	hw->max_frame_size = netdev->mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN;
 	hw->min_frame_size = ETH_ZLEN + ETH_FCS_LEN;
@@ -121,6 +785,7 @@ static int __devinit atl1_sw_init(struct atl1_adapter *adapter)
 	adapter->ict = 50000;		/* 100ms */
 	adapter->link_speed = SPEED_0;	/* hardware init */
 	adapter->link_duplex = FULL_DUPLEX;
+	adapter->num_rx_queues = 1;
 
 	hw->phy_configured = false;
 	hw->preamble_len = 7;
@@ -143,7 +808,7 @@ static int __devinit atl1_sw_init(struct atl1_adapter *adapter)
 	hw->tx_jumbo_task_th = (hw->max_frame_size + 7) >> 3;
 	hw->tpd_fetch_gap = 1;
 	hw->rcb_value = atl1_rcb_64;
-	hw->dma_ord = atl1_dma_ord_enh;
+	hw->dma_ord = atl1_dma_ord_out;
 	hw->dmar_block = atl1_dma_req_1024;
 	hw->dmaw_block = atl1_dma_req_1024;
 	hw->cmb_rrd = 4;
@@ -152,8 +817,16 @@ static int __devinit atl1_sw_init(struct atl1_adapter *adapter)
 	hw->cmb_tx_timer = 256;	/* about 512us */
 	hw->smb_timer = 100000;	/* about 200ms */
 
+	err = atl1_alloc_queues(adapter);
+	if (err) {
+		dev_printk(KERN_DEBUG, &adapter->pdev->dev,
+			"unable to allocate memory for queues\n");
+		return -ENOMEM;
+	}
+
 	spin_lock_init(&adapter->lock);
 	spin_lock_init(&adapter->mb_lock);
+	set_bit(__ATL1_DOWN, &adapter->flags);
 
 	return 0;
 }
@@ -811,22 +1484,6 @@ static u32 atl1_configure(struct atl1_adapter *adapter)
 }
 
 /*
- * atl1_pcie_patch - Patch for PCIE module
- */
-static void atl1_pcie_patch(struct atl1_adapter *adapter)
-{
-	u32 value;
-
-	/* much vendor magic here */
-	value = 0x6500;
-	iowrite32(value, adapter->hw.hw_addr + 0x12FC);
-	/* pcie flow control mode change */
-	value = ioread32(adapter->hw.hw_addr + 0x1008);
-	value |= 0x8000;
-	iowrite32(value, adapter->hw.hw_addr + 0x1008);
-}
-
-/*
  * When ACPI resume on some VIA MotherBoard, the Interrupt Disable bit/0x400
  * on PCI Command register is disable.
  * The function enable this bit.
@@ -2131,6 +2788,7 @@ static int __devinit atl1_probe(struct pci_dev *pdev,
 		err = -EIO;
 		goto err_pci_iomap;
 	}
+
 	/* get device revision number */
 	adapter->hw.dev_rev = ioread16(adapter->hw.hw_addr +
 		(REG_MASTER_CTRL + 2));
@@ -2169,26 +2827,11 @@ static int __devinit atl1_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_common;
 
-	netdev->features = NETIF_F_HW_CSUM;
-	netdev->features |= NETIF_F_SG;
-	netdev->features |= (NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX);
-	netdev->features |= NETIF_F_TSO;
-	netdev->features |= NETIF_F_LLTX;
+	netdev->features = NETIF_F_HW_CSUM | NETIF_F_SG | NETIF_F_TSO |
+		NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX | NETIF_F_LLTX;
 
-	/*
-	 * patch for some L1 of old version,
-	 * the final version of L1 may not need these
-	 * patches
-	 */
-	/* atl1_pcie_patch(adapter); */
-
-	/* really reset GPHY core */
-	iowrite16(0, adapter->hw.hw_addr + REG_PHY_ENABLE);
+	atl1_phy_init(&adapter->hw);
 
-	/*
-	 * reset the controller to
-	 * put the device in a known good starting state
-	 */
 	if (atl1_reset_hw(&adapter->hw)) {
 		err = -EIO;
 		goto err_common;
@@ -2205,18 +2848,6 @@ static int __devinit atl1_probe(struct pci_dev *pdev,
 
 	atl1_check_options(adapter);
 
-	/* pre-init the MAC, and setup link */
-	err = atl1_init_hw(&adapter->hw);
-	if (err) {
-		err = -EIO;
-		goto err_common;
-	}
-
-	atl1_pcie_patch(adapter);
-	/* assume we have no link for now */
-	netif_carrier_off(netdev);
-	netif_stop_queue(netdev);
-
 	init_timer(&adapter->watchdog_timer);
 	adapter->watchdog_timer.function = &atl1_watchdog;
 	adapter->watchdog_timer.data = (unsigned long)adapter;
@@ -2236,8 +2867,11 @@ static int __devinit atl1_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_common;
 
+	netif_carrier_off(netdev);
+	netif_stop_queue(netdev);
+
 	cards_found++;
-	atl1_via_workaround(adapter);
+
 	return 0;
 
 err_common:
@@ -2852,662 +3486,3 @@ const struct ethtool_ops atl1_ethtool_ops = {
 	.get_sset_count		= atl1_get_sset_count,
 	.set_tso		= ethtool_op_set_tso,
 };
-
-/*
- * Reset the transmit and receive units; mask and clear all interrupts.
- * hw - Struct containing variables accessed by shared code
- * return : 0  or  idle status (if error)
- */
-s32 atl1_reset_hw(struct atl1_hw *hw)
-{
-	struct pci_dev *pdev = hw->back->pdev;
-	u32 icr;
-	int i;
-
-	/*
-	 * Issue Soft Reset to the MAC.  This will reset the chip's
-	 * transmit, receive, DMA.  It will not effect
-	 * the current PCI configuration.  The global reset bit is self-
-	 * clearing, and should clear within a microsecond.
-	 */
-	iowrite32(MASTER_CTRL_SOFT_RST, hw->hw_addr + REG_MASTER_CTRL);
-	ioread32(hw->hw_addr + REG_MASTER_CTRL);
-
-	/* delay about 1ms */
-	msleep(1);
-
-	/* wait at least 10ms for idle */
-	for (i = 0; i < 10; i++) {
-		icr = ioread32(hw->hw_addr + REG_IDLE_STATUS);
-		if (!icr)
-			break;
-		/* delay 1 ms */
-		msleep(1);
-		cpu_relax();
-	}
-
-	if (icr) {
-		dev_dbg(&pdev->dev, "ICR = 0x%x\n", icr);
-		return icr;
-	}
-
-	return 0;
-}
-
-/* function about EEPROM
- *
- * check_eeprom_exist
- * return 0 if eeprom exist
- */
-static int atl1_check_eeprom_exist(struct atl1_hw *hw)
-{
-	u32 value;
-
-	value = ioread32(hw->hw_addr + REG_SPI_FLASH_CTRL);
-	if (value & SPI_FLASH_CTRL_EN_VPD) {
-		value &= ~SPI_FLASH_CTRL_EN_VPD;
-		iowrite32(value, hw->hw_addr + REG_SPI_FLASH_CTRL);
-	}
-
-	value = ioread16(hw->hw_addr + REG_PCIE_CAP_LIST);
-	return ((value & 0xFF00) == 0x6C00) ? 0 : 1;
-}
-
-static bool atl1_read_eeprom(struct atl1_hw *hw, u32 offset, u32 *p_value)
-{
-	int i;
-	u32 control;
-
-	if (offset & 3)
-		/* address do not align */
-		return false;
-
-	iowrite32(0, hw->hw_addr + REG_VPD_DATA);
-	control = (offset & VPD_CAP_VPD_ADDR_MASK) << VPD_CAP_VPD_ADDR_SHIFT;
-	iowrite32(control, hw->hw_addr + REG_VPD_CAP);
-	ioread32(hw->hw_addr + REG_VPD_CAP);
-
-	for (i = 0; i < 10; i++) {
-		msleep(2);
-		control = ioread32(hw->hw_addr + REG_VPD_CAP);
-		if (control & VPD_CAP_VPD_FLAG)
-			break;
-	}
-	if (control & VPD_CAP_VPD_FLAG) {
-		*p_value = ioread32(hw->hw_addr + REG_VPD_DATA);
-		return true;
-	}
-	/* timeout */
-	return false;
-}
-
-/*
- * Reads the value from a PHY register
- * hw - Struct containing variables accessed by shared code
- * reg_addr - address of the PHY register to read
- */
-s32 atl1_read_phy_reg(struct atl1_hw *hw, u16 reg_addr, u16 *phy_data)
-{
-	u32 val;
-	int i;
-
-	val = ((u32) (reg_addr & MDIO_REG_ADDR_MASK)) << MDIO_REG_ADDR_SHIFT |
-		MDIO_START | MDIO_SUP_PREAMBLE | MDIO_RW | MDIO_CLK_25_4 <<
-		MDIO_CLK_SEL_SHIFT;
-	iowrite32(val, hw->hw_addr + REG_MDIO_CTRL);
-	ioread32(hw->hw_addr + REG_MDIO_CTRL);
-
-	for (i = 0; i < MDIO_WAIT_TIMES; i++) {
-		udelay(2);
-		val = ioread32(hw->hw_addr + REG_MDIO_CTRL);
-		if (!(val & (MDIO_START | MDIO_BUSY)))
-			break;
-	}
-	if (!(val & (MDIO_START | MDIO_BUSY))) {
-		*phy_data = (u16) val;
-		return 0;
-	}
-	return ATLX_ERR_PHY;
-}
-
-#define CUSTOM_SPI_CS_SETUP	2
-#define CUSTOM_SPI_CLK_HI	2
-#define CUSTOM_SPI_CLK_LO	2
-#define CUSTOM_SPI_CS_HOLD	2
-#define CUSTOM_SPI_CS_HI	3
-
-static bool atl1_spi_read(struct atl1_hw *hw, u32 addr, u32 *buf)
-{
-	int i;
-	u32 value;
-
-	iowrite32(0, hw->hw_addr + REG_SPI_DATA);
-	iowrite32(addr, hw->hw_addr + REG_SPI_ADDR);
-
-	value = SPI_FLASH_CTRL_WAIT_READY |
-	    (CUSTOM_SPI_CS_SETUP & SPI_FLASH_CTRL_CS_SETUP_MASK) <<
-	    SPI_FLASH_CTRL_CS_SETUP_SHIFT | (CUSTOM_SPI_CLK_HI &
-					     SPI_FLASH_CTRL_CLK_HI_MASK) <<
-	    SPI_FLASH_CTRL_CLK_HI_SHIFT | (CUSTOM_SPI_CLK_LO &
-					   SPI_FLASH_CTRL_CLK_LO_MASK) <<
-	    SPI_FLASH_CTRL_CLK_LO_SHIFT | (CUSTOM_SPI_CS_HOLD &
-					   SPI_FLASH_CTRL_CS_HOLD_MASK) <<
-	    SPI_FLASH_CTRL_CS_HOLD_SHIFT | (CUSTOM_SPI_CS_HI &
-					    SPI_FLASH_CTRL_CS_HI_MASK) <<
-	    SPI_FLASH_CTRL_CS_HI_SHIFT | (1 & SPI_FLASH_CTRL_INS_MASK) <<
-	    SPI_FLASH_CTRL_INS_SHIFT;
-
-	iowrite32(value, hw->hw_addr + REG_SPI_FLASH_CTRL);
-
-	value |= SPI_FLASH_CTRL_START;
-	iowrite32(value, hw->hw_addr + REG_SPI_FLASH_CTRL);
-	ioread32(hw->hw_addr + REG_SPI_FLASH_CTRL);
-
-	for (i = 0; i < 10; i++) {
-		msleep(1);
-		value = ioread32(hw->hw_addr + REG_SPI_FLASH_CTRL);
-		if (!(value & SPI_FLASH_CTRL_START))
-			break;
-	}
-
-	if (value & SPI_FLASH_CTRL_START)
-		return false;
-
-	*buf = ioread32(hw->hw_addr + REG_SPI_DATA);
-
-	return true;
-}
-
-/*
- * get_permanent_address
- * return 0 if get valid mac address,
- */
-static int atl1_get_permanent_address(struct atl1_hw *hw)
-{
-	u32 addr[2];
-	u32 i, control;
-	u16 reg;
-	u8 eth_addr[ETH_ALEN];
-	bool key_valid;
-
-	if (is_valid_ether_addr(hw->perm_mac_addr))
-		return 0;
-
-	/* init */
-	addr[0] = addr[1] = 0;
-
-	if (!atl1_check_eeprom_exist(hw)) {
-		reg = 0;
-		key_valid = false;
-		/* Read out all EEPROM content */
-		i = 0;
-		while (1) {
-			if (atl1_read_eeprom(hw, i + 0x100, &control)) {
-				if (key_valid) {
-					if (reg == REG_MAC_STA_ADDR)
-						addr[0] = control;
-					else if (reg == (REG_MAC_STA_ADDR + 4))
-						addr[1] = control;
-					key_valid = false;
-				} else if ((control & 0xff) == 0x5A) {
-					key_valid = true;
-					reg = (u16) (control >> 16);
-				} else
-					break;
-			} else
-				/* read error */
-				break;
-			i += 4;
-		}
-
-		*(u32 *) &eth_addr[2] = swab32(addr[0]);
-		*(u16 *) &eth_addr[0] = swab16(*(u16 *) &addr[1]);
-		if (is_valid_ether_addr(eth_addr)) {
-			memcpy(hw->perm_mac_addr, eth_addr, ETH_ALEN);
-			return 0;
-		}
-		return 1;
-	}
-
-	/* see if SPI FLAGS exist ? */
-	addr[0] = addr[1] = 0;
-	reg = 0;
-	key_valid = false;
-	i = 0;
-	while (1) {
-		if (atl1_spi_read(hw, i + 0x1f000, &control)) {
-			if (key_valid) {
-				if (reg == REG_MAC_STA_ADDR)
-					addr[0] = control;
-				else if (reg == (REG_MAC_STA_ADDR + 4))
-					addr[1] = control;
-				key_valid = false;
-			} else if ((control & 0xff) == 0x5A) {
-				key_valid = true;
-				reg = (u16) (control >> 16);
-			} else
-				/* data end */
-				break;
-		} else
-			/* read error */
-			break;
-		i += 4;
-	}
-
-	*(u32 *) &eth_addr[2] = swab32(addr[0]);
-	*(u16 *) &eth_addr[0] = swab16(*(u16 *) &addr[1]);
-	if (is_valid_ether_addr(eth_addr)) {
-		memcpy(hw->perm_mac_addr, eth_addr, ETH_ALEN);
-		return 0;
-	}
-
-	/*
-	 * On some motherboards, the MAC address is written by the
-	 * BIOS directly to the MAC register during POST, and is
-	 * not stored in eeprom.  If all else thus far has failed
-	 * to fetch the permanent MAC address, try reading it directly.
-	 */
-	addr[0] = ioread32(hw->hw_addr + REG_MAC_STA_ADDR);
-	addr[1] = ioread16(hw->hw_addr + (REG_MAC_STA_ADDR + 4));
-	*(u32 *) &eth_addr[2] = swab32(addr[0]);
-	*(u16 *) &eth_addr[0] = swab16(*(u16 *) &addr[1]);
-	if (is_valid_ether_addr(eth_addr)) {
-		memcpy(hw->perm_mac_addr, eth_addr, ETH_ALEN);
-		return 0;
-	}
-
-	return 1;
-}
-
-/*
- * Reads the adapter's MAC address from the EEPROM
- * hw - Struct containing variables accessed by shared code
- */
-s32 atl1_read_mac_addr(struct atl1_hw *hw)
-{
-	u16 i;
-
-	if (atl1_get_permanent_address(hw))
-		random_ether_addr(hw->perm_mac_addr);
-
-	for (i = 0; i < ETH_ALEN; i++)
-		hw->mac_addr[i] = hw->perm_mac_addr[i];
-	return 0;
-}
-
-/*
- * Hashes an address to determine its location in the multicast table
- * hw - Struct containing variables accessed by shared code
- * mc_addr - the multicast address to hash
- *
- * atl1_hash_mc_addr
- *  purpose
- *      set hash value for a multicast address
- *      hash calcu processing :
- *          1. calcu 32bit CRC for multicast address
- *          2. reverse crc with MSB to LSB
- */
-u32 atl1_hash_mc_addr(struct atl1_hw *hw, u8 *mc_addr)
-{
-	u32 crc32, value = 0;
-	int i;
-
-	crc32 = ether_crc_le(6, mc_addr);
-	for (i = 0; i < 32; i++)
-		value |= (((crc32 >> i) & 1) << (31 - i));
-
-	return value;
-}
-
-/*
- * Sets the bit in the multicast table corresponding to the hash value.
- * hw - Struct containing variables accessed by shared code
- * hash_value - Multicast address hash value
- */
-void atl1_hash_set(struct atl1_hw *hw, u32 hash_value)
-{
-	u32 hash_bit, hash_reg;
-	u32 mta;
-
-	/*
-	 * The HASH Table  is a register array of 2 32-bit registers.
-	 * It is treated like an array of 64 bits.  We want to set
-	 * bit BitArray[hash_value]. So we figure out what register
-	 * the bit is in, read it, OR in the new bit, then write
-	 * back the new value.  The register is determined by the
-	 * upper 7 bits of the hash value and the bit within that
-	 * register are determined by the lower 5 bits of the value.
-	 */
-	hash_reg = (hash_value >> 31) & 0x1;
-	hash_bit = (hash_value >> 26) & 0x1F;
-	mta = ioread32((hw->hw_addr + REG_RX_HASH_TABLE) + (hash_reg << 2));
-	mta |= (1 << hash_bit);
-	iowrite32(mta, (hw->hw_addr + REG_RX_HASH_TABLE) + (hash_reg << 2));
-}
-
-/*
- * Writes a value to a PHY register
- * hw - Struct containing variables accessed by shared code
- * reg_addr - address of the PHY register to write
- * data - data to write to the PHY
- */
-s32 atl1_write_phy_reg(struct atl1_hw *hw, u32 reg_addr, u16 phy_data)
-{
-	int i;
-	u32 val;
-
-	val = ((u32) (phy_data & MDIO_DATA_MASK)) << MDIO_DATA_SHIFT |
-	    (reg_addr & MDIO_REG_ADDR_MASK) << MDIO_REG_ADDR_SHIFT |
-	    MDIO_SUP_PREAMBLE |
-	    MDIO_START | MDIO_CLK_25_4 << MDIO_CLK_SEL_SHIFT;
-	iowrite32(val, hw->hw_addr + REG_MDIO_CTRL);
-	ioread32(hw->hw_addr + REG_MDIO_CTRL);
-
-	for (i = 0; i < MDIO_WAIT_TIMES; i++) {
-		udelay(2);
-		val = ioread32(hw->hw_addr + REG_MDIO_CTRL);
-		if (!(val & (MDIO_START | MDIO_BUSY)))
-			break;
-	}
-
-	if (!(val & (MDIO_START | MDIO_BUSY)))
-		return 0;
-
-	return ATLX_ERR_PHY;
-}
-
-/*
- * Configures PHY autoneg and flow control advertisement settings
- * hw - Struct containing variables accessed by shared code
- */
-s32 atl1_phy_setup_autoneg_adv(struct atl1_hw *hw)
-{
-	s32 ret_val;
-	s16 mii_autoneg_adv_reg;
-	s16 mii_1000t_ctrl_reg;
-
-	/* Read the MII Auto-Neg Advertisement Register (Address 4). */
-	mii_autoneg_adv_reg = MII_AR_DEFAULT_CAP_MASK;
-
-	/* Read the MII 1000Base-T Control Register (Address 9). */
-	mii_1000t_ctrl_reg = MII_ATLX_CR_1000T_DEFAULT_CAP_MASK;
-
-	/*
-	 * First we clear all the 10/100 mb speed bits in the Auto-Neg
-	 * Advertisement Register (Address 4) and the 1000 mb speed bits in
-	 * the  1000Base-T Control Register (Address 9).
-	 */
-	mii_autoneg_adv_reg &= ~MII_AR_SPEED_MASK;
-	mii_1000t_ctrl_reg &= ~MII_ATLX_CR_1000T_SPEED_MASK;
-
-	/*
-	 * Need to parse media_type  and set up
-	 * the appropriate PHY registers.
-	 */
-	switch (hw->media_type) {
-	case MEDIA_TYPE_AUTO_SENSOR:
-		mii_autoneg_adv_reg |= (MII_AR_10T_HD_CAPS |
-					MII_AR_10T_FD_CAPS |
-					MII_AR_100TX_HD_CAPS |
-					MII_AR_100TX_FD_CAPS);
-		mii_1000t_ctrl_reg |= MII_ATLX_CR_1000T_FD_CAPS;
-		hw->autoneg_advertised = ADVERTISE_10_HALF |
-					ADVERTISE_10_FULL  |
-					ADVERTISE_100_HALF |
-					ADVERTISE_100_FULL |
-					ADVERTISE_1000_FULL;
-		break;
-
-	case MEDIA_TYPE_100M_FULL:
-		mii_1000t_ctrl_reg |= MII_AR_100TX_FD_CAPS;
-		hw->autoneg_advertised = ADVERTISE_100_FULL;
-		break;
-
-	case MEDIA_TYPE_100M_HALF:
-		mii_autoneg_adv_reg |= MII_AR_100TX_HD_CAPS;
-		hw->autoneg_advertised = ADVERTISE_100_HALF;
-		break;
-
-	case MEDIA_TYPE_10M_FULL:
-		mii_autoneg_adv_reg |= MII_AR_10T_FD_CAPS;
-		hw->autoneg_advertised = ADVERTISE_10_FULL;
-		break;
-
-	default:
-		mii_autoneg_adv_reg |= MII_AR_10T_HD_CAPS;
-		hw->autoneg_advertised = ADVERTISE_10_HALF;
-		break;
-	}
-
-	/* flow control fixed to enable all */
-	mii_autoneg_adv_reg |= (MII_AR_ASM_DIR | MII_AR_PAUSE);
-
-	hw->mii_autoneg_adv_reg = mii_autoneg_adv_reg;
-	hw->mii_1000t_ctrl_reg = mii_1000t_ctrl_reg;
-
-	ret_val = atl1_write_phy_reg(hw, MII_ADVERTISE, mii_autoneg_adv_reg);
-	if (ret_val)
-		return ret_val;
-
-	ret_val = atl1_write_phy_reg(hw, MII_ATLX_CR, mii_1000t_ctrl_reg);
-	if (ret_val)
-		return ret_val;
-
-	return 0;
-}
-
-static void atl1_init_flash_opcode(struct atl1_hw *hw)
-{
-	if (hw->flash_vendor >= ARRAY_SIZE(flash_table))
-		/* Atmel */
-		hw->flash_vendor = 0;
-
-	/* Init OP table */
-	iowrite8(flash_table[hw->flash_vendor].cmd_program,
-		hw->hw_addr + REG_SPI_FLASH_OP_PROGRAM);
-	iowrite8(flash_table[hw->flash_vendor].cmd_sector_erase,
-		hw->hw_addr + REG_SPI_FLASH_OP_SC_ERASE);
-	iowrite8(flash_table[hw->flash_vendor].cmd_chip_erase,
-		hw->hw_addr + REG_SPI_FLASH_OP_CHIP_ERASE);
-	iowrite8(flash_table[hw->flash_vendor].cmd_rdid,
-		hw->hw_addr + REG_SPI_FLASH_OP_RDID);
-	iowrite8(flash_table[hw->flash_vendor].cmd_wren,
-		hw->hw_addr + REG_SPI_FLASH_OP_WREN);
-	iowrite8(flash_table[hw->flash_vendor].cmd_rdsr,
-		hw->hw_addr + REG_SPI_FLASH_OP_RDSR);
-	iowrite8(flash_table[hw->flash_vendor].cmd_wrsr,
-		hw->hw_addr + REG_SPI_FLASH_OP_WRSR);
-	iowrite8(flash_table[hw->flash_vendor].cmd_read,
-		hw->hw_addr + REG_SPI_FLASH_OP_READ);
-}
-
-static void atl1_init_pcie(struct atl1_hw *hw)
-{
-	u32 val;
-
-	val = LTSSM_TEST_MODE_DEF;
-	iowrite32(val, hw->hw_addr + REG_LTSSM_TEST_MODE);
-	val = ioread32(hw->hw_addr + REG_PCIE_PHY_MISC3);
-	val |= PCIE_PHY_MISC3_DS_PWR_DOWN;
-	iowrite32(val, hw->hw_addr + REG_PCIE_PHY_MISC3);
-}
-
-static bool atl1_check_cable(struct atl1_hw *hw)
-{
-	u16 pair_num;
-	u16 i;
-	u16 phy_val;
-
-	phy_val = 0x8000;
-	atl1_write_phy_reg(hw, MII_BMCR, phy_val);
-
-	for (pair_num = 0; pair_num < 4; pair_num++) {
-		phy_val = (u16) (pair_num << CDTC_PAIR_OFFSET);
-		phy_val |= CDTC_EN;
-		atl1_write_phy_reg(hw, MII_CDTC, phy_val);
-		for (i = 0; i < 200; i++) {
-			msleep(1);
-			atl1_read_phy_reg(hw, MII_CDTC, &phy_val);
-			if (!(phy_val & CDTC_EN))
-				break;
-		}
-		msleep(1);
-		atl1_read_phy_reg(hw, MII_CDTS, &phy_val);
-		if (((phy_val >> CDTS_STATUS_OFFSET) & 3) != CDTS_OPEN)
-			return true;
-	}
-	return false;
-}
-static s32 atl1_phy_commit(struct atl1_hw *hw)
-{
-	s32 retval;
-	u16 phy_data;
-	u32 val;
-	int i;
-
-	phy_data = MII_CR_RESET | MII_CR_AUTO_NEG_EN | MII_CR_RESTART_AUTO_NEG;
-	retval = atl1_write_phy_reg(hw, MII_BMCR, phy_data);
-	if (retval) {
-		for (i = 0; i < 25; i++) {
-			msleep(1);
-			val = ioread32(hw->hw_addr + REG_MDIO_CTRL);
-			if (!(val & (MDIO_START | MDIO_BUSY)))
-				break;
-		}
-		if (val & (MDIO_START | MDIO_BUSY))
-			return retval;
-	}
-	return 0;
-}
-
-static s32 atl1_phy_init(struct atl1_hw *hw)
-{
-	u16 phy_data;
-	u16 i;
-	s32 retval;
-
-	if (hw->phy_configured)
-		return 0;
-
-	iowrite16(0, hw->hw_addr + REG_PHY_ENABLE);
-	msleep(2);
-	iowrite16(PHY_RESET, hw->hw_addr + REG_PHY_ENABLE);
-	msleep(2);
-
-	/* check for cable */
-	if (!atl1_check_cable(hw))
-		set_bit(0, &hw->force_ps);
-	else
-		clear_bit(0, &hw->force_ps);
-
-	/* enable PHY link change interrupt */
-	retval = atl1_write_phy_reg(hw, 18, 0xC00);
-	if (retval)
-		return retval;
-
-	/* setup autonegotiation parameters */
-	retval = atl1_phy_setup_autoneg_adv(hw);
-	if (retval)
-		return retval;
-
-	retval = atl1_phy_commit(hw);
-	if (retval)
-		return retval;
-
-	if (test_bit(0, &hw->force_ps)) {
-		atl1_write_phy_reg(hw, MII_DBG_ADDR, 0);
-		atl1_write_phy_reg(hw, MII_DBG_DATA, 0x124E);
-		atl1_write_phy_reg(hw, MII_DBG_ADDR, 1);
-		atl1_read_phy_reg(hw, MII_DBG_DATA, &phy_data);
-		phy_data |= 0x3;
-		atl1_write_phy_reg(hw, MII_DBG_DATA, phy_data);
-
-		for (i = 0; i < 15; i++)
-			msleep(100);
-		atl1_write_phy_reg(hw, MII_DBG_ADDR, 0);
-		atl1_write_phy_reg(hw, MII_DBG_DATA, 0x024E);
-	}
-	hw->phy_configured = true;
-	return retval;
-}
-
-/*
- * Performs basic configuration of the adapter.
- * hw - Struct containing variables accessed by shared code
- * Assumes that the controller has previously been reset and is in a
- * post-reset uninitialized state. Initializes multicast table,
- * and  Calls routines to setup link
- * Leaves the transmit and receive units disabled and uninitialized.
- */
-s32 atl1_init_hw(struct atl1_hw *hw)
-{
-	u32 retval = 0;
-
-	atl1_init_pcie(hw);
-	iowrite32(0, hw->hw_addr + REG_RX_HASH_TABLE);
-	iowrite32(0, (hw->hw_addr + REG_RX_HASH_TABLE) + (1 << 2));
-	atl1_init_flash_opcode(hw);
-	retval = atl1_phy_init(hw);
-
-	return retval;
-}
-
-/*
- * Detects the current speed and duplex settings of the hardware.
- * hw - Struct containing variables accessed by shared code
- * speed - Speed of the connection
- * duplex - Duplex setting of the connection
- */
-s32 atl1_get_speed_and_duplex(struct atl1_hw *hw, u16 *speed, u16 *duplex)
-{
-	struct pci_dev *pdev = hw->back->pdev;
-	s32 ret_val;
-	u16 phy_data;
-
-	/* ; --- Read   PHY Specific Status Register (17) */
-	ret_val = atl1_read_phy_reg(hw, MII_ATLX_PSSR, &phy_data);
-	if (ret_val)
-		return ret_val;
-
-	if (!(phy_data & MII_ATLX_PSSR_SPD_DPLX_RESOLVED))
-		return ATLX_ERR_PHY_RES;
-
-	switch (phy_data & MII_ATLX_PSSR_SPEED) {
-	case MII_ATLX_PSSR_1000MBS:
-		*speed = SPEED_1000;
-		break;
-	case MII_ATLX_PSSR_100MBS:
-		*speed = SPEED_100;
-		break;
-	case MII_ATLX_PSSR_10MBS:
-		*speed = SPEED_10;
-		break;
-	default:
-		dev_dbg(&pdev->dev, "error getting speed\n");
-		return ATLX_ERR_PHY_SPEED;
-		break;
-	}
-	if (phy_data & MII_ATLX_PSSR_DPLX)
-		*duplex = FULL_DUPLEX;
-	else
-		*duplex = HALF_DUPLEX;
-
-	return 0;
-}
-
-void atl1_set_mac_addr(struct atl1_hw *hw)
-{
-	u32 value;
-	/*
-	 * 00-0B-6A-F6-00-DC
-	 * 0:  6AF600DC   1: 000B
-	 * low dword
-	 */
-	value = (((u32) hw->mac_addr[2]) << 24) |
-	    (((u32) hw->mac_addr[3]) << 16) |
-	    (((u32) hw->mac_addr[4]) << 8) | (((u32) hw->mac_addr[5]));
-	iowrite32(value, hw->hw_addr + REG_MAC_STA_ADDR);
-	/* high dword */
-	value = (((u32) hw->mac_addr[0]) << 8) | (((u32) hw->mac_addr[1]));
-	iowrite32(value, (hw->hw_addr + REG_MAC_STA_ADDR) + (1 << 2));
-}
diff --git a/drivers/net/atlx/atl1.h b/drivers/net/atlx/atl1.h
index c1b99f2..2c2570e 100644
--- a/drivers/net/atlx/atl1.h
+++ b/drivers/net/atlx/atl1.h
@@ -56,25 +56,13 @@ struct atl1_adapter;
 struct atl1_hw;
 
 /* function prototypes needed by multiple files */
-s32 atl1_phy_setup_autoneg_adv(struct atl1_hw *hw);
-s32 atl1_write_phy_reg(struct atl1_hw *hw, u32 reg_addr, u16 phy_data);
-s32 atl1_get_speed_and_duplex(struct atl1_hw *hw, u16 *speed, u16 *duplex);
-s32 atl1_read_mac_addr(struct atl1_hw *hw);
-s32 atl1_init_hw(struct atl1_hw *hw);
-s32 atl1_get_speed_and_duplex(struct atl1_hw *hw, u16 *speed, u16 *duplex);
-s32 atl1_set_speed_and_duplex(struct atl1_hw *hw, u16 speed, u16 duplex);
-u32 atl1_hash_mc_addr(struct atl1_hw *hw, u8 *mc_addr);
-void atl1_hash_set(struct atl1_hw *hw, u32 hash_value);
-s32 atl1_read_phy_reg(struct atl1_hw *hw, u16 reg_addr, u16 *phy_data);
-void atl1_set_mac_addr(struct atl1_hw *hw);
-s32 atl1_phy_enter_power_saving(struct atl1_hw *hw);
-s32 atl1_reset_hw(struct atl1_hw *hw);
-void atl1_check_options(struct atl1_adapter *adapter);
+static u32 atl1_hash_mc_addr(struct atl1_hw *hw, u8 *mc_addr);
+static void atl1_hash_set(struct atl1_hw *hw, u32 hash_value);
+static s32 atl1_read_phy_reg(struct atl1_hw *hw, u16 reg_addr, u16 *phy_data);
+static void atl1_set_mac_addr(struct atl1_hw *hw);
 static int atl1_mii_ioctl(struct net_device *netdev, struct ifreq *ifr,
 	int cmd);
 static u32 atl1_check_link(struct atl1_adapter *adapter);
-void atl1_down(struct atl1_adapter *adapter);
-int atl1_reset(struct atl1_adapter *adapter);
 
 extern const struct ethtool_ops atl1_ethtool_ops;
 
@@ -806,6 +794,7 @@ struct atl1_adapter {
 	struct atl1_smb smb;
 	struct atl1_cmb cmb;
 	unsigned long flags;
+	int num_rx_queues;
 };
 
 enum atl1_state {
-- 
1.5.3.3

