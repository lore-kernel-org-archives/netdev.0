From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 10/10] atl1: reduce forward declarations
Date: Sat,  2 Feb 2008 19:50:12 -0600
Message-ID: <1202003412-4028-10-git-send-email-jacliburn@bellsouth.net>
References: <1202003412-4028-1-git-send-email-jacliburn@bellsouth.net>
Cc: csnook@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jay Cliburn <jacliburn@bellsouth.net>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost02.isp.att.net ([207.115.11.52]:39589 "EHLO
	fmailhost02.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933876AbYBCBu1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Feb 2008 20:50:27 -0500
In-Reply-To: <1202003412-4028-1-git-send-email-jacliburn@bellsouth.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rearrange functions to allow removal of some forward declarations.
Make certain global functions static along the way.

Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
Acked-by: Chris Snook <csnook@redhat.com>
---
 drivers/net/atlx/atl1.c | 1406 +++++++++++++++++++++++-----------------------
 drivers/net/atlx/atl1.h |   10 -
 2 files changed, 703 insertions(+), 713 deletions(-)

diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index 6f4a1d5..240db84 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -108,6 +108,709 @@ module_param(debug, int, 0);
 MODULE_PARM_DESC(debug, "Message level (0=none,...,16=all)");
 
 /*
+ * Reset the transmit and receive units; mask and clear all interrupts.
+ * hw - Struct containing variables accessed by shared code
+ * return : 0  or  idle status (if error)
+ */
+static s32 atl1_reset_hw(struct atl1_hw *hw)
+{
+	struct pci_dev *pdev = hw->back->pdev;
+	struct atl1_adapter *adapter = hw->back;
+	u32 icr;
+	int i;
+
+	/*
+	 * Clear Interrupt mask to stop board from generating
+	 * interrupts & Clear any pending interrupt events
+	 */
+	/*
+	 * iowrite32(0, hw->hw_addr + REG_IMR);
+	 * iowrite32(0xffffffff, hw->hw_addr + REG_ISR);
+	 */
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
+	iowrite16(1, hw->hw_addr + REG_PHY_ENABLE);
+	ioread16(hw->hw_addr + REG_PHY_ENABLE);
+
+	/* delay about 1ms */
+	msleep(1);
+
+	/* Wait at least 10ms for All module to be Idle */
+	for (i = 0; i < 10; i++) {
+		icr = ioread32(hw->hw_addr + REG_IDLE_STATUS);
+		if (!icr)
+			break;
+		/* delay 1 ms */
+		msleep(1);
+		/* FIXME: still the right way to do this? */
+		cpu_relax();
+	}
+
+	if (icr) {
+		if (netif_msg_hw(adapter))
+			dev_dbg(&pdev->dev, "ICR = 0x%x\n", icr);
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
+s32 atl1_read_phy_reg(struct atl1_hw *hw, u16 reg_addr, u16 *phy_data)
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
+s32 atl1_read_mac_addr(struct atl1_hw *hw)
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
+u32 atl1_hash_mc_addr(struct atl1_hw *hw, u8 *mc_addr)
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
+void atl1_hash_set(struct atl1_hw *hw, u32 hash_value)
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
+ * Make L001's PHY out of Power Saving State (bug)
+ * hw - Struct containing variables accessed by shared code
+ * when power on, L001's PHY always on Power saving State
+ * (Gigabit Link forbidden)
+ */
+static s32 atl1_phy_leave_power_saving(struct atl1_hw *hw)
+{
+	s32 ret;
+	ret = atl1_write_phy_reg(hw, 29, 0x0029);
+	if (ret)
+		return ret;
+	return atl1_write_phy_reg(hw, 30, 0);
+}
+
+/*
+ *TODO: do something or get rid of this
+ */
+static s32 atl1_phy_enter_power_saving(struct atl1_hw *hw)
+{
+/*    s32 ret_val;
+ *    u16 phy_data;
+ */
+
+/*
+    ret_val = atl1_write_phy_reg(hw, ...);
+    ret_val = atl1_write_phy_reg(hw, ...);
+    ....
+*/
+	return 0;
+}
+
+/*
+ * Resets the PHY and make all config validate
+ * hw - Struct containing variables accessed by shared code
+ *
+ * Sets bit 15 and 12 of the MII Control regiser (for F001 bug)
+ */
+static s32 atl1_phy_reset(struct atl1_hw *hw)
+{
+	struct pci_dev *pdev = hw->back->pdev;
+	struct atl1_adapter *adapter = hw->back;
+	s32 ret_val;
+	u16 phy_data;
+
+	if (hw->media_type == MEDIA_TYPE_AUTO_SENSOR ||
+	    hw->media_type == MEDIA_TYPE_1000M_FULL)
+		phy_data = MII_CR_RESET | MII_CR_AUTO_NEG_EN;
+	else {
+		switch (hw->media_type) {
+		case MEDIA_TYPE_100M_FULL:
+			phy_data =
+			    MII_CR_FULL_DUPLEX | MII_CR_SPEED_100 |
+			    MII_CR_RESET;
+			break;
+		case MEDIA_TYPE_100M_HALF:
+			phy_data = MII_CR_SPEED_100 | MII_CR_RESET;
+			break;
+		case MEDIA_TYPE_10M_FULL:
+			phy_data =
+			    MII_CR_FULL_DUPLEX | MII_CR_SPEED_10 | MII_CR_RESET;
+			break;
+		default:
+			/* MEDIA_TYPE_10M_HALF: */
+			phy_data = MII_CR_SPEED_10 | MII_CR_RESET;
+			break;
+		}
+	}
+
+	ret_val = atl1_write_phy_reg(hw, MII_BMCR, phy_data);
+	if (ret_val) {
+		u32 val;
+		int i;
+		/* pcie serdes link may be down! */
+		if (netif_msg_hw(adapter))
+			dev_dbg(&pdev->dev, "pcie phy link down\n");
+
+		for (i = 0; i < 25; i++) {
+			msleep(1);
+			val = ioread32(hw->hw_addr + REG_MDIO_CTRL);
+			if (!(val & (MDIO_START | MDIO_BUSY)))
+				break;
+		}
+
+		if ((val & (MDIO_START | MDIO_BUSY)) != 0) {
+			if (netif_msg_hw(adapter))
+				dev_warn(&pdev->dev,
+					"pcie link down at least 25ms\n");
+			return ret_val;
+		}
+	}
+	return 0;
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
+		break;
+
+	case MEDIA_TYPE_1000M_FULL:
+		mii_1000t_ctrl_reg |= MII_ATLX_CR_1000T_FD_CAPS;
+		break;
+
+	case MEDIA_TYPE_100M_FULL:
+		mii_autoneg_adv_reg |= MII_AR_100TX_FD_CAPS;
+		break;
+
+	case MEDIA_TYPE_100M_HALF:
+		mii_autoneg_adv_reg |= MII_AR_100TX_HD_CAPS;
+		break;
+
+	case MEDIA_TYPE_10M_FULL:
+		mii_autoneg_adv_reg |= MII_AR_10T_FD_CAPS;
+		break;
+
+	default:
+		mii_autoneg_adv_reg |= MII_AR_10T_HD_CAPS;
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
+/*
+ * Configures link settings.
+ * hw - Struct containing variables accessed by shared code
+ * Assumes the hardware has previously been reset and the
+ * transmitter and receiver are not enabled.
+ */
+static s32 atl1_setup_link(struct atl1_hw *hw)
+{
+	struct pci_dev *pdev = hw->back->pdev;
+	struct atl1_adapter *adapter = hw->back;
+	s32 ret_val;
+
+	/*
+	 * Options:
+	 *  PHY will advertise value(s) parsed from
+	 *  autoneg_advertised and fc
+	 *  no matter what autoneg is , We will not wait link result.
+	 */
+	ret_val = atl1_phy_setup_autoneg_adv(hw);
+	if (ret_val) {
+		if (netif_msg_link(adapter))
+			dev_dbg(&pdev->dev,
+				"error setting up autonegotiation\n");
+		return ret_val;
+	}
+	/* SW.Reset , En-Auto-Neg if needed */
+	ret_val = atl1_phy_reset(hw);
+	if (ret_val) {
+		if (netif_msg_link(adapter))
+			dev_dbg(&pdev->dev, "error resetting phy\n");
+		return ret_val;
+	}
+	hw->phy_configured = true;
+	return ret_val;
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
+	u32 ret_val = 0;
+
+	/* Zero out the Multicast HASH table */
+	iowrite32(0, hw->hw_addr + REG_RX_HASH_TABLE);
+	/* clear the old settings from the multicast hash table */
+	iowrite32(0, (hw->hw_addr + REG_RX_HASH_TABLE) + (1 << 2));
+
+	atl1_init_flash_opcode(hw);
+
+	if (!hw->phy_configured) {
+		/* enable GPHY LinkChange Interrrupt */
+		ret_val = atl1_write_phy_reg(hw, 18, 0xC00);
+		if (ret_val)
+			return ret_val;
+		/* make PHY out of power-saving state */
+		ret_val = atl1_phy_leave_power_saving(hw);
+		if (ret_val)
+			return ret_val;
+		/* Call a subroutine to configure the link */
+		ret_val = atl1_setup_link(hw);
+	}
+	return ret_val;
+}
+
+/*
+ * Detects the current speed and duplex settings of the hardware.
+ * hw - Struct containing variables accessed by shared code
+ * speed - Speed of the connection
+ * duplex - Duplex setting of the connection
+ */
+static s32 atl1_get_speed_and_duplex(struct atl1_hw *hw, u16 *speed, u16 *duplex)
+{
+	struct pci_dev *pdev = hw->back->pdev;
+	struct atl1_adapter *adapter = hw->back;
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
+		if (netif_msg_hw(adapter))
+			dev_dbg(&pdev->dev, "error getting speed\n");
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
+void atl1_set_mac_addr(struct atl1_hw *hw)
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
+/*
  * atl1_sw_init - Initialize general software structures (struct atl1_adapter)
  * @adapter: board private structure to initialize
  *
@@ -2860,706 +3563,3 @@ const struct ethtool_ops atl1_ethtool_ops = {
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
-	struct atl1_adapter *adapter = hw->back;
-	u32 icr;
-	int i;
-
-	/*
-	 * Clear Interrupt mask to stop board from generating
-	 * interrupts & Clear any pending interrupt events
-	 */
-	/*
-	 * iowrite32(0, hw->hw_addr + REG_IMR);
-	 * iowrite32(0xffffffff, hw->hw_addr + REG_ISR);
-	 */
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
-	iowrite16(1, hw->hw_addr + REG_PHY_ENABLE);
-	ioread16(hw->hw_addr + REG_PHY_ENABLE);
-
-	/* delay about 1ms */
-	msleep(1);
-
-	/* Wait at least 10ms for All module to be Idle */
-	for (i = 0; i < 10; i++) {
-		icr = ioread32(hw->hw_addr + REG_IDLE_STATUS);
-		if (!icr)
-			break;
-		/* delay 1 ms */
-		msleep(1);
-		/* FIXME: still the right way to do this? */
-		cpu_relax();
-	}
-
-	if (icr) {
-		if (netif_msg_hw(adapter))
-			dev_dbg(&pdev->dev, "ICR = 0x%x\n", icr);
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
- * Make L001's PHY out of Power Saving State (bug)
- * hw - Struct containing variables accessed by shared code
- * when power on, L001's PHY always on Power saving State
- * (Gigabit Link forbidden)
- */
-static s32 atl1_phy_leave_power_saving(struct atl1_hw *hw)
-{
-	s32 ret;
-	ret = atl1_write_phy_reg(hw, 29, 0x0029);
-	if (ret)
-		return ret;
-	return atl1_write_phy_reg(hw, 30, 0);
-}
-
-/*
- *TODO: do something or get rid of this
- */
-s32 atl1_phy_enter_power_saving(struct atl1_hw *hw)
-{
-/*    s32 ret_val;
- *    u16 phy_data;
- */
-
-/*
-    ret_val = atl1_write_phy_reg(hw, ...);
-    ret_val = atl1_write_phy_reg(hw, ...);
-    ....
-*/
-	return 0;
-}
-
-/*
- * Resets the PHY and make all config validate
- * hw - Struct containing variables accessed by shared code
- *
- * Sets bit 15 and 12 of the MII Control regiser (for F001 bug)
- */
-static s32 atl1_phy_reset(struct atl1_hw *hw)
-{
-	struct pci_dev *pdev = hw->back->pdev;
-	struct atl1_adapter *adapter = hw->back;
-	s32 ret_val;
-	u16 phy_data;
-
-	if (hw->media_type == MEDIA_TYPE_AUTO_SENSOR ||
-	    hw->media_type == MEDIA_TYPE_1000M_FULL)
-		phy_data = MII_CR_RESET | MII_CR_AUTO_NEG_EN;
-	else {
-		switch (hw->media_type) {
-		case MEDIA_TYPE_100M_FULL:
-			phy_data =
-			    MII_CR_FULL_DUPLEX | MII_CR_SPEED_100 |
-			    MII_CR_RESET;
-			break;
-		case MEDIA_TYPE_100M_HALF:
-			phy_data = MII_CR_SPEED_100 | MII_CR_RESET;
-			break;
-		case MEDIA_TYPE_10M_FULL:
-			phy_data =
-			    MII_CR_FULL_DUPLEX | MII_CR_SPEED_10 | MII_CR_RESET;
-			break;
-		default:
-			/* MEDIA_TYPE_10M_HALF: */
-			phy_data = MII_CR_SPEED_10 | MII_CR_RESET;
-			break;
-		}
-	}
-
-	ret_val = atl1_write_phy_reg(hw, MII_BMCR, phy_data);
-	if (ret_val) {
-		u32 val;
-		int i;
-		/* pcie serdes link may be down! */
-		if (netif_msg_hw(adapter))
-			dev_dbg(&pdev->dev, "pcie phy link down\n");
-
-		for (i = 0; i < 25; i++) {
-			msleep(1);
-			val = ioread32(hw->hw_addr + REG_MDIO_CTRL);
-			if (!(val & (MDIO_START | MDIO_BUSY)))
-				break;
-		}
-
-		if ((val & (MDIO_START | MDIO_BUSY)) != 0) {
-			if (netif_msg_hw(adapter))
-				dev_warn(&pdev->dev,
-					"pcie link down at least 25ms\n");
-			return ret_val;
-		}
-	}
-	return 0;
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
-		break;
-
-	case MEDIA_TYPE_1000M_FULL:
-		mii_1000t_ctrl_reg |= MII_ATLX_CR_1000T_FD_CAPS;
-		break;
-
-	case MEDIA_TYPE_100M_FULL:
-		mii_autoneg_adv_reg |= MII_AR_100TX_FD_CAPS;
-		break;
-
-	case MEDIA_TYPE_100M_HALF:
-		mii_autoneg_adv_reg |= MII_AR_100TX_HD_CAPS;
-		break;
-
-	case MEDIA_TYPE_10M_FULL:
-		mii_autoneg_adv_reg |= MII_AR_10T_FD_CAPS;
-		break;
-
-	default:
-		mii_autoneg_adv_reg |= MII_AR_10T_HD_CAPS;
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
-/*
- * Configures link settings.
- * hw - Struct containing variables accessed by shared code
- * Assumes the hardware has previously been reset and the
- * transmitter and receiver are not enabled.
- */
-static s32 atl1_setup_link(struct atl1_hw *hw)
-{
-	struct pci_dev *pdev = hw->back->pdev;
-	struct atl1_adapter *adapter = hw->back;
-	s32 ret_val;
-
-	/*
-	 * Options:
-	 *  PHY will advertise value(s) parsed from
-	 *  autoneg_advertised and fc
-	 *  no matter what autoneg is , We will not wait link result.
-	 */
-	ret_val = atl1_phy_setup_autoneg_adv(hw);
-	if (ret_val) {
-		if (netif_msg_link(adapter))
-			dev_dbg(&pdev->dev,
-				"error setting up autonegotiation\n");
-		return ret_val;
-	}
-	/* SW.Reset , En-Auto-Neg if needed */
-	ret_val = atl1_phy_reset(hw);
-	if (ret_val) {
-		if (netif_msg_link(adapter))
-			dev_dbg(&pdev->dev, "error resetting phy\n");
-		return ret_val;
-	}
-	hw->phy_configured = true;
-	return ret_val;
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
-	u32 ret_val = 0;
-
-	/* Zero out the Multicast HASH table */
-	iowrite32(0, hw->hw_addr + REG_RX_HASH_TABLE);
-	/* clear the old settings from the multicast hash table */
-	iowrite32(0, (hw->hw_addr + REG_RX_HASH_TABLE) + (1 << 2));
-
-	atl1_init_flash_opcode(hw);
-
-	if (!hw->phy_configured) {
-		/* enable GPHY LinkChange Interrrupt */
-		ret_val = atl1_write_phy_reg(hw, 18, 0xC00);
-		if (ret_val)
-			return ret_val;
-		/* make PHY out of power-saving state */
-		ret_val = atl1_phy_leave_power_saving(hw);
-		if (ret_val)
-			return ret_val;
-		/* Call a subroutine to configure the link */
-		ret_val = atl1_setup_link(hw);
-	}
-	return ret_val;
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
-	struct atl1_adapter *adapter = hw->back;
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
-		if (netif_msg_hw(adapter))
-			dev_dbg(&pdev->dev, "error getting speed\n");
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
index 6220298..51893d6 100644
--- a/drivers/net/atlx/atl1.h
+++ b/drivers/net/atlx/atl1.h
@@ -56,20 +56,10 @@ struct atl1_adapter;
 struct atl1_hw;
 
 /* function prototypes needed by multiple files */
-s32 atl1_phy_setup_autoneg_adv(struct atl1_hw *hw);
-s32 atl1_write_phy_reg(struct atl1_hw *hw, u32 reg_addr, u16 phy_data);
-s32 atl1_get_speed_and_duplex(struct atl1_hw *hw, u16 *speed, u16 *duplex);
-s32 atl1_read_mac_addr(struct atl1_hw *hw);
-s32 atl1_init_hw(struct atl1_hw *hw);
-s32 atl1_get_speed_and_duplex(struct atl1_hw *hw, u16 *speed, u16 *duplex);
-s32 atl1_set_speed_and_duplex(struct atl1_hw *hw, u16 speed, u16 duplex);
 u32 atl1_hash_mc_addr(struct atl1_hw *hw, u8 *mc_addr);
 void atl1_hash_set(struct atl1_hw *hw, u32 hash_value);
 s32 atl1_read_phy_reg(struct atl1_hw *hw, u16 reg_addr, u16 *phy_data);
 void atl1_set_mac_addr(struct atl1_hw *hw);
-s32 atl1_phy_enter_power_saving(struct atl1_hw *hw);
-s32 atl1_reset_hw(struct atl1_hw *hw);
-void atl1_check_options(struct atl1_adapter *adapter);
 static int atl1_mii_ioctl(struct net_device *netdev, struct ifreq *ifr,
 	int cmd);
 static u32 atl1_check_link(struct atl1_adapter *adapter);
-- 
1.5.3.8

