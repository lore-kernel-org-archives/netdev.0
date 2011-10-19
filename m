From: <cloud.ren@atheros.com>
Subject: [patch net-next]alx: Atheros AR8131/AR8151/AR8152/AR8161 Ethernet driver
Date: Wed, 19 Oct 2011 15:26:53 +0800
Message-ID: <1319009213-20627-1-git-send-email-cloud.ren@atheros.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Luis.Rodriguez@Atheros.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, cloud ren <cloud.ren@atheros.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Received: from mail.atheros.com ([10.234.20.104])
	by sidewinder.atheros.com
	for <netdev@vger.kernel.org>; Wed, 19 Oct 2011 00:33:58 -0700
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

alx: Atheros AR8131/AR8151/AR8152/AR8161 Ethernet driver

It is able to support Atheros AR8131/AR8151/AR8152/AR8161 ethernet adapter.

Signed-off-by: cloud ren <cloud.ren@atheros.com>
---


diff --git a/drivers/net/ethernet/atheros/Kconfig b/drivers/net/ethernet/atheros/Kconfig
index 1ed886d..24976ea 100644
--- a/drivers/net/ethernet/atheros/Kconfig
+++ b/drivers/net/ethernet/atheros/Kconfig
@@ -67,4 +67,17 @@ config ATL1C
 	  To compile this driver as a module, choose M here.  The module
 	  will be called atl1c.
 
+config ALX
+	tristate "Atheros ALX Gigabit Ethernet support (EXPERIMENTAL)"
+	depends on PCI && EXPERIMENTAL
+	select CRC32
+	select NET_CORE
+	select MII
+	---help---
+	  This driver supports the Atheros L1C/L1D/L1F gigabit ethernet
+	  adapter. 
+
+	  To compile this driver as a module, choose M here.  The module
+	  will be called atl1c.
+
 endif # NET_VENDOR_ATHEROS
diff --git a/drivers/net/ethernet/atheros/Makefile b/drivers/net/ethernet/atheros/Makefile
index e7e76fb..5cf1c65 100644
--- a/drivers/net/ethernet/atheros/Makefile
+++ b/drivers/net/ethernet/atheros/Makefile
@@ -6,3 +6,4 @@ obj-$(CONFIG_ATL1) += atlx/
 obj-$(CONFIG_ATL2) += atlx/
 obj-$(CONFIG_ATL1E) += atl1e/
 obj-$(CONFIG_ATL1C) += atl1c/
+obj-$(CONFIG_ALX) += alx/
diff --git a/drivers/net/ethernet/atheros/alx/Makefile b/drivers/net/ethernet/atheros/alx/Makefile
new file mode 100755
index 0000000..62b054e
--- /dev/null
+++ b/drivers/net/ethernet/atheros/alx/Makefile
@@ -0,0 +1,2 @@
+obj-$(CONFIG_ALX) += alx.o
+alx-objs := alx_main.o alx_ethtool.o alc_cb.o alc_hw.o alf_cb.o alf_hw.o
diff --git a/drivers/net/ethernet/atheros/alx/alc_cb.c b/drivers/net/ethernet/atheros/alx/alc_cb.c
new file mode 100755
index 0000000..f3784c0
--- /dev/null
+++ b/drivers/net/ethernet/atheros/alx/alc_cb.c
@@ -0,0 +1,1029 @@
+/*
+ * Copyright (c) 2010 - 2011 Atheros Communications Inc.
+ *
+ * Permission to use, copy, modify, and/or distribute this software for any
+ * purpose with or without fee is hereby granted, provided that the above
+ * copyright notice and this permission notice appear in all copies.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
+ * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
+ * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
+ * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
+ * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
+ * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ */
+
+#include "alc_hw.h"
+
+
+/* NIC */
+int alc_identify_nic(struct alx_hw *hw)
+{
+	return 0;
+}
+
+/* PHY */
+int alc_read_phy_reg(struct alx_hw *hw, u32 device_type,
+		     u16 reg_addr, u16 *phy_data)
+{
+	bool fast = false;
+	bool ext = false;
+	u16 error;
+	int retval = 0;
+
+	ALX_MDIO_LOCK(&hw->mdio_lock);
+
+	if (device_type != ALX_MDIO_NORM_DEV)
+		ext = true;
+
+	error = l1c_read_phy(hw, ext, device_type, fast,
+			     reg_addr, phy_data);
+	if (error) {
+		HW_PRINT(ERR, "Error when reading phy reg (%d).", error);
+		retval = ALX_ERR_PHY_READ_REG;
+	}
+
+	ALX_MDIO_UNLOCK(&hw->mdio_lock);
+
+	return retval;
+}
+
+int alc_write_phy_reg(struct alx_hw *hw, u32 device_type,
+		      u16 reg_addr, u16 phy_data)
+{
+	bool fast = false;
+	bool ext = false;
+	u16 error;
+	int retval = 0;
+
+	ALX_MDIO_LOCK(&hw->mdio_lock);
+
+	if (device_type != ALX_MDIO_NORM_DEV)
+		ext = true;
+
+	error = l1c_write_phy(hw, ext, device_type, fast,
+			      reg_addr, phy_data);
+	if (error) {
+		HW_PRINT(ERR, "Error when writting phy reg (%d).", error);
+		retval = ALX_ERR_PHY_WRITE_REG;
+	}
+
+
+	ALX_MDIO_UNLOCK(&hw->mdio_lock);
+
+	return retval;
+}
+
+
+int alc_init_phy(struct alx_hw *hw)
+{
+	u16 phy_id[2];
+	int retval = 0;
+
+	HW_PRINT(DEBUG, "ENTER\n");
+
+	/* 1. init mdio spin lock */
+	ALX_MDIO_LOCK_INIT(&hw->mdio_lock);
+
+	/* 2. read phy id */
+	retval = alc_read_phy_reg(hw, ALX_MDIO_NORM_DEV,
+				  L1C_MII_PHYSID1, &phy_id[0]);
+	if (retval)
+		return retval;
+	retval = alc_read_phy_reg(hw, ALX_MDIO_NORM_DEV,
+				  L1C_MII_PHYSID1, &phy_id[1]);
+	if (retval)
+		return retval;
+
+	memcpy(&hw->phy_id, phy_id, sizeof(hw->phy_id));
+
+	hw->autoneg_advertised = (ALX_LINK_SPEED_1GB_FULL |
+				  ALX_LINK_SPEED_10_HALF  |
+				  ALX_LINK_SPEED_10_FULL  |
+				  ALX_LINK_SPEED_100_HALF |
+				  ALX_LINK_SPEED_100_FULL);
+	return retval;
+}
+
+
+int alc_reset_phy(struct alx_hw *hw)
+{
+	int retval = 0;
+	bool pws_en, az_en, ptp_en;
+	u32 phy;
+
+	HW_PRINT(DEBUG, "ENTER\n");
+
+	pws_en = az_en = ptp_en = false;
+	CLI_HW_FLAG(PWSAVE_EN);
+	CLI_HW_FLAG(AZ_EN);
+	CLI_HW_FLAG(PTP_EN);
+
+	if (CHK_HW_FLAG(PWSAVE_CAP)) {
+		pws_en = true;
+		SET_HW_FLAG(PWSAVE_EN);
+	}
+
+	if (CHK_HW_FLAG(AZ_CAP)) {
+		az_en = true;
+		SET_HW_FLAG(AZ_EN);
+	}
+
+	if (CHK_HW_FLAG(PTP_CAP)) {
+		ptp_en = true;
+		SET_HW_FLAG(PTP_EN);
+	}
+
+	HW_PRINT(INFO, "Parameters When reset PHY, "
+		 "pws = %d, az = %d, ptp = %d\n",
+		 pws_en, az_en, ptp_en);
+
+	if (l1c_reset_phy(hw, pws_en, az_en, ptp_en))
+		retval = ALX_ERR_PHY_RESET;
+
+	MEM_R32(hw, L1C_PHY_CTRL, &phy);
+	HW_PRINT(INFO, "Parameters When reset PHY, phy reg = 0x%x\n", phy);
+
+	return retval;
+}
+
+/* LINK */
+int alc_setup_phy_link(struct alx_hw *hw, u32 speed, bool autoneg, bool fc)
+{
+	u8 link_cap = 0;
+	int retval = 0;
+
+	HW_PRINT(DEBUG, "ENTER\n");
+
+	HW_PRINT(INFO, "speed = 0x%x, autoneg = %d\n", speed, autoneg);
+	if (speed & ALX_LINK_SPEED_1GB_FULL)
+		link_cap |= LX_LC_1000F;
+
+	if (speed & ALX_LINK_SPEED_100_FULL)
+		link_cap |= LX_LC_100F;
+
+	if (speed & ALX_LINK_SPEED_100_HALF)
+		link_cap |= LX_LC_100H;
+
+	if (speed & ALX_LINK_SPEED_10_FULL)
+		link_cap |= LX_LC_10F;
+
+	if (speed & ALX_LINK_SPEED_10_HALF)
+		link_cap |= LX_LC_10H;
+
+	if (l1c_init_phy_spdfc(hw, autoneg, link_cap, fc))
+		retval = ALX_ERR_PHY_SETUP_LNK;
+
+	return retval;
+}
+
+
+
+int alc_setup_phy_link_speed(struct alx_hw *hw, u32 speed,
+			     bool autoneg, bool fc)
+{
+	int retval = 0;
+
+	HW_PRINT(DEBUG, "ENTER\n");
+
+	/*
+	 * Clear autoneg_advertised and set new values based on input link
+	 * speed.
+	 */
+	hw->autoneg_advertised = 0;
+
+	if (speed & ALX_LINK_SPEED_1GB_FULL)
+		hw->autoneg_advertised |= ALX_LINK_SPEED_1GB_FULL;
+
+	if (speed & ALX_LINK_SPEED_100_FULL)
+		hw->autoneg_advertised |= ALX_LINK_SPEED_100_FULL;
+
+	if (speed & ALX_LINK_SPEED_100_HALF)
+		hw->autoneg_advertised |= ALX_LINK_SPEED_100_HALF;
+
+	if (speed & ALX_LINK_SPEED_10_FULL)
+		hw->autoneg_advertised |= ALX_LINK_SPEED_10_FULL;
+
+	if (speed & ALX_LINK_SPEED_10_HALF)
+		hw->autoneg_advertised |= ALX_LINK_SPEED_10_HALF;
+
+	retval = alc_setup_phy_link(hw, hw->autoneg_advertised,
+				    autoneg, fc);
+	return retval;
+
+
+}
+
+
+
+int alc_check_phy_link(struct alx_hw *hw, u32 *speed, bool *link_up)
+{
+	u16 bmsr, giga;
+	int retval;
+
+	HW_PRINT(DEBUG, "ENTER\n");
+
+	alc_read_phy_reg(hw, ALX_MDIO_NORM_DEV, L1C_MII_BMSR, &bmsr);
+	retval = alc_read_phy_reg(hw, ALX_MDIO_NORM_DEV,
+				  L1C_MII_BMSR, &bmsr);
+	if (retval)
+		return retval;
+
+
+	*link_up = true;
+	if (!(bmsr & L1C_BMSR_LINK_STATUS)) {
+		*link_up = false;
+		*speed = ALX_LINK_SPEED_UNKNOWN;
+		return retval;
+	}
+
+
+	/* Read PHY Specific Status Register (17) */
+	retval = alc_read_phy_reg(hw, ALX_MDIO_NORM_DEV,
+				  L1C_MII_GIGA_PSSR, &giga);
+	if (retval)
+		return retval;
+
+
+	if (!(giga & L1C_GIGA_PSSR_SPD_DPLX_RESOLVED))
+		return ALX_ERR_PHY_RESOLVED;
+
+	switch (giga & L1C_GIGA_PSSR_SPEED) {
+	case L1C_GIGA_PSSR_1000MBS:
+		if (giga & L1C_GIGA_PSSR_DPLX)
+			*speed = ALX_LINK_SPEED_1GB_FULL;
+		else
+			HW_PRINT(ERR, "1000M half is invalid");
+		break;
+	case L1C_GIGA_PSSR_100MBS:
+		if (giga & L1C_GIGA_PSSR_DPLX)
+			*speed = ALX_LINK_SPEED_100_FULL;
+		else
+			*speed = ALX_LINK_SPEED_100_HALF;
+		break;
+	case L1C_GIGA_PSSR_10MBS:
+		if (giga & L1C_GIGA_PSSR_DPLX)
+			*speed = ALX_LINK_SPEED_10_FULL;
+		else
+			*speed = ALX_LINK_SPEED_10_HALF;
+		break;
+	default:
+		*speed = ALX_LINK_SPEED_UNKNOWN;
+		retval = ALX_ERR_PHY_CHECK_LNK;
+		break;
+	}
+
+	return retval;
+}
+
+/* INTR */
+int alc_ack_phy_intr(struct alx_hw *hw)
+{
+	int retval = 0;
+	u16 isr = 0;
+
+	HW_PRINT(DEBUG, "ENTER\n");
+
+	retval = alc_read_phy_reg(hw, ALX_MDIO_NORM_DEV,
+				  L1C_MII_ISR, &isr);
+	if (retval)
+		return retval;
+
+	return retval;
+}
+
+
+/*
+ * 1. stop_mac
+ * 2. reset mac & dma by reg1400(MASTER)
+ * 3. control speed/duplex, hash-alg
+ * 4. clock switch setting
+ */
+int alc_reset_mac(struct alx_hw *hw)
+{
+	int retval = 0;
+
+	HW_PRINT(DEBUG, "ENTER\n");
+
+	if (l1c_reset_mac(hw))
+		retval = ALX_ERR_MAC_RESET;
+
+	return retval;
+}
+
+
+int alc_start_mac(struct alx_hw *hw)
+{
+	u16 en_ctrl = 0;
+	int retval = 0;
+
+	HW_PRINT(DEBUG, "ENTER\n");
+
+	/* set link speed param */
+	switch (hw->link_speed) {
+	case ALX_LINK_SPEED_1GB_FULL:
+		en_ctrl |= LX_MACSPEED_1000;
+		/* fall through */
+	case ALX_LINK_SPEED_100_FULL:
+	case ALX_LINK_SPEED_10_FULL:
+		en_ctrl |= LX_MACDUPLEX_FULL;
+		break;
+	}
+
+	/* set fc param*/
+	switch (hw->cur_fc_mode) {
+	case alx_fc_full:
+		en_ctrl |= LX_FC_RXEN; /* Flow Control RX Enable */
+		en_ctrl |= LX_FC_TXEN; /* Flow Control TX Enable */
+		break;
+	case alx_fc_rx_pause:
+		en_ctrl |= LX_FC_RXEN; /* Flow Control RX Enable */
+		break;
+	case alx_fc_tx_pause:
+		en_ctrl |= LX_FC_TXEN; /* Flow Control TX Enable */
+		break;
+	default:
+		break;
+	}
+
+	if (hw->fc_single_pause)
+		en_ctrl |= LX_SINGLE_PAUSE;
+
+
+	en_ctrl |= LX_FLT_DIRECT; /* RX Enable; and TX Always Enable */
+	en_ctrl |= LX_FLT_BROADCAST; /* RX Broadcast Enable */
+	en_ctrl |= LX_ADD_FCS;
+
+	if (CHK_HW_FLAG(VLANSTRIP_EN))
+		en_ctrl |= LX_VLAN_STRIP;
+
+	if (CHK_HW_FLAG(PROMISC_EN))
+		en_ctrl |=  LX_FLT_PROMISC;
+
+	if (CHK_HW_FLAG(MULTIALL_EN))
+		en_ctrl |= LX_FLT_MULTI_ALL;
+
+
+	if (l1c_enable_mac(hw, true, en_ctrl))
+		retval = ALX_ERR_MAC_START;
+	return retval;
+}
+
+
+/*
+ * 1. stop RXQ (reg15A0) and TXQ (reg1590)
+ * 2. stop MAC (reg1480)
+ */
+int alc_stop_mac(struct alx_hw *hw)
+{
+	int retval = 0;
+
+	HW_PRINT(DEBUG, "ENTER\n");
+
+	if (l1c_enable_mac(hw, false, 0))
+		retval = ALX_ERR_MAC_STOP;
+	return retval;
+}
+
+
+int alc_config_mac(struct alx_hw *hw, u16 rxbuf_sz, u16 rx_qnum,
+		   u16 rxring_sz, u16 tx_qnum,  u16 txring_sz)
+{
+	u8 *addr;
+
+	u32 txmem_hi, txmem_lo[4];
+
+	u32 rxmem_hi, rfdmem_lo, rrdmem_lo;
+
+	u16 smb_timer, mtu_with_eth, int_mod;
+	bool hash_legacy;
+
+	int i;
+	int retval = 0;
+#if MAC_TYPE_FPGA == MAC_TYPE
+	u32 phy;
+#endif
+
+	HW_PRINT(DEBUG, "ENTER\n");
+
+	addr = hw->mac_addr;
+
+	txmem_hi = ALX_DMA_ADDR_HI(hw->tpdma[0]);
+	for (i = 0; i < tx_qnum; i++)
+		txmem_lo[i] = ALX_DMA_ADDR_LO(hw->tpdma[i]);
+
+
+	rxmem_hi = ALX_DMA_ADDR_HI(hw->rfdma[0]);
+	rfdmem_lo = ALX_DMA_ADDR_LO(hw->rfdma[0]);
+	rrdmem_lo = ALX_DMA_ADDR_LO(hw->rrdma[0]);
+
+
+	smb_timer = (u16)hw->smb_timer;
+	mtu_with_eth = hw->mtu + ALX_ETH_LENGTH_OF_HEADER;
+	int_mod = hw->imt;
+
+	hash_legacy = true;
+
+	if (l1c_init_mac(hw, addr, txmem_hi, txmem_lo, tx_qnum, txring_sz,
+			 rxmem_hi, rfdmem_lo, rrdmem_lo, rxring_sz, rxbuf_sz,
+			 smb_timer, mtu_with_eth, int_mod, hash_legacy)) {
+		retval = ALX_ERR_MAC_CONFIGURE;
+	}
+
+#if MAC_TYPE_FPGA == MAC_TYPE
+	MEM_R32(hw, L1C_MDIO, &phy);
+	phy |= 0x10000000;
+	MEM_W32(hw, L1C_MDIO, phy);
+#endif
+	return retval;
+}
+
+
+
+/**
+ *  alc_get_mac_addr
+ *  @hw: pointer to hardware structure
+ **/
+int alc_get_mac_addr(struct alx_hw *hw, u8 *addr)
+{
+	int retval = 0;
+
+	HW_PRINT(DEBUG, "ENTER\n");
+
+	if (l1c_get_perm_macaddr(hw, addr))
+		retval = ALX_ERR_MAC_ADDR;
+
+	return retval;
+}
+
+
+int alc_reset_pcie(struct alx_hw *hw, bool l0s_en, bool l1_en)
+{
+	int retval = 0;
+
+	HW_PRINT(DEBUG, "ENTER\n");
+
+	if (!CHK_HW_FLAG(L0S_CAP))
+		l0s_en = false;
+
+	if (l0s_en)
+		SET_HW_FLAG(L0S_EN);
+	else
+		CLI_HW_FLAG(L0S_EN);
+
+
+	if (!CHK_HW_FLAG(L1_CAP))
+		l1_en = false;
+
+	if (l1_en)
+		SET_HW_FLAG(L1_EN);
+	else
+		CLI_HW_FLAG(L1_EN);
+
+
+
+	if (l1c_reset_pcie(hw, l0s_en, l1_en))
+		retval = ALX_ERR_PCIE_RESET;
+
+	return retval;
+}
+
+
+
+int alc_config_aspm(struct alx_hw *hw, bool l0s_en, bool l1_en)
+{
+	int retval = 0;
+
+	HW_PRINT(DEBUG, "ENTER\n");
+
+	if (!CHK_HW_FLAG(L0S_CAP))
+		l0s_en = false;
+
+	if (l0s_en)
+		SET_HW_FLAG(L0S_EN);
+	else
+		CLI_HW_FLAG(L0S_EN);
+
+
+	if (!CHK_HW_FLAG(L1_CAP))
+		l1_en = false;
+
+	if (l1_en)
+		SET_HW_FLAG(L1_EN);
+	else
+		CLI_HW_FLAG(L1_EN);
+
+
+	if (l1c_enable_aspm(hw, l0s_en, l1_en, 0))
+		retval = ALX_ERR_ASPM;
+
+	return retval;
+}
+
+
+
+/* RAR, Multicast, VLAN */
+int alc_set_mac_addr(struct alx_hw *hw, u8 *addr)
+{
+	u32 sta;
+	int retval = 0;
+
+	HW_PRINT(DEBUG, "ENTER\n");
+
+	/*
+	 * for example: 00-0B-6A-F6-00-DC
+	 * 0<-->6AF600DC, 1<-->000B.
+	 */
+
+	 /* low dword */
+	sta = (((u32)addr[2]) << 24) | (((u32)addr[3]) << 16) |
+	      (((u32)addr[4]) << 8)  | (((u32)addr[5])) ;
+	MEM_W32(hw, L1C_STAD0, sta);
+	/* hight dword */
+	sta = (((u32)addr[0]) << 8) | (((u32)addr[1])) ;
+	MEM_W32(hw, L1C_STAD1, sta);
+
+	return retval;
+}
+
+int alc_clear_mac_addr(struct alx_hw *hw)
+{
+	int retval = 0;
+
+	HW_PRINT(DEBUG, "ENTER\n");
+
+	return retval;
+}
+
+int alc_set_mc_addr(struct alx_hw *hw, u8 *addr)
+{
+	u32 crc32;
+	u32 bit, reg;
+	u32 mta;
+
+	HW_PRINT(DEBUG, "ENTER\n");
+
+	/*
+	* set hash value for a multicast address hash calcu processing.
+	*   1. calcu 32bit CRC for multicast address
+	*   2. reverse crc with MSB to LSB
+	*/
+	crc32 = ALX_ETH_CRC(addr, ALX_ETH_LENGTH_OF_ADDRESS);
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
+	reg = (crc32 >> 31) & 0x1;
+	bit = (crc32 >> 26) & 0x1F;
+
+	MEM_R32(hw, L1C_HASH_TBL0 + (reg<<2), &mta);
+	mta |= (0x1 << bit);
+	MEM_W32(hw, L1C_HASH_TBL0 + (reg<<2), mta);
+
+	return 0;
+}
+
+int alc_clear_mc_addr(struct alx_hw *hw)
+{
+
+	HW_PRINT(DEBUG, "ENTER\n");
+
+	MEM_W32(hw, L1C_HASH_TBL0, 0);
+	MEM_W32(hw, L1C_HASH_TBL1, 0);
+
+	return 0;
+}
+
+
+/* TX, RX, IRQ */
+int alc_config_rx(struct alx_hw *hw)
+{
+	int retval = 0;
+	return retval;
+}
+
+
+int alc_config_tx(struct alx_hw *hw)
+{
+	int retval = 0;
+	return retval;
+}
+
+
+int alc_enable_legacy_intr(struct alx_hw *hw)
+{
+	int retval = 0;
+
+	HW_PRINT(DEBUG, "ENTER\n");
+
+	MEM_W32(hw, L1C_ISR, ~L1C_ISR_DIS);
+	MEM_W32(hw, L1C_IMR, hw->intr_mask);
+
+	return retval;
+}
+
+int alc_disable_legacy_intr(struct alx_hw *hw)
+{
+	int retval = 0;
+
+	HW_PRINT(DEBUG, "ENTER\n");
+
+	MEM_W32(hw, L1C_ISR, L1C_ISR_DIS);
+	MEM_W32(hw, L1C_IMR, 0);
+
+	MEM_FLUSH(hw);
+	return retval;
+}
+
+
+int alc_config_wol(struct alx_hw *hw, u32 wufc)
+{
+	u32 wol;
+	int retval = 0;
+
+	HW_PRINT(DEBUG, "ENTER\n");
+
+	wol = 0;
+	/* turn on magic packet event */
+	if (wufc & ALX_WOL_MAGIC) {
+		wol |= L1C_WOL0_MAGIC_EN | L1C_WOL0_PME_MAGIC_EN;
+		/* magic packet maybe Broadcast&multicast&Unicast frame
+		 * move to l1c_powersaving
+		 */
+	}
+
+	/* turn on link up event */
+	if (wufc & ALX_WOL_PHY) {
+		wol |=  L1C_WOL0_LINK_EN | L1C_WOL0_PME_LINK;
+		/* only link up can wake up */
+		retval = alc_write_phy_reg(hw, ALX_MDIO_NORM_DEV,
+					   L1C_MII_IER, L1C_IER_LINK_UP);
+	}
+
+	MEM_W32(hw, L1C_WOL0, wol);
+
+	return retval;
+}
+
+
+int alc_config_mac_ctrl(struct alx_hw *hw)
+{
+	u32 mac;
+
+	HW_PRINT(DEBUG, "ENTER\n");
+
+	MEM_R32(hw, L1C_MAC_CTRL, &mac);
+
+	/* enable/disable VLAN tag insert,strip */
+	if (CHK_HW_FLAG(VLANSTRIP_EN))
+		mac |= L1C_MAC_CTRL_VLANSTRIP;
+	else
+		mac &= ~L1C_MAC_CTRL_VLANSTRIP;
+
+
+	if (CHK_HW_FLAG(PROMISC_EN))
+		mac |= L1C_MAC_CTRL_PROMISC_EN;
+	else
+		mac &= ~L1C_MAC_CTRL_PROMISC_EN;
+
+
+	if (CHK_HW_FLAG(MULTIALL_EN))
+		mac |= L1C_MAC_CTRL_MULTIALL_EN;
+	else
+		mac &= ~L1C_MAC_CTRL_MULTIALL_EN;
+
+
+	MEM_W32(hw, L1C_MAC_CTRL, mac);
+	return 0;
+}
+
+int alc_config_pow_save(struct alx_hw *hw, u32 speed, bool wol_en,
+			bool tx_en, bool rx_en, bool pws_en)
+{
+	u8 wire_spd = LX_LC_10H;
+	int retval = 0;
+
+	HW_PRINT(DEBUG, "ENTER\n");
+
+	switch (speed) {
+	case ALX_LINK_SPEED_UNKNOWN:
+	case ALX_LINK_SPEED_10_HALF:
+		wire_spd = LX_LC_10H;
+		break;
+	case ALX_LINK_SPEED_10_FULL:
+		wire_spd = LX_LC_10F;
+		break;
+	case ALX_LINK_SPEED_100_HALF:
+		wire_spd = LX_LC_100H;
+		break;
+	case ALX_LINK_SPEED_100_FULL:
+		wire_spd = LX_LC_100F;
+		break;
+	case ALX_LINK_SPEED_1GB_FULL:
+		wire_spd = LX_LC_1000F;
+		break;
+	}
+
+	if (l1c_powersaving(hw, wire_spd, wol_en, tx_en, rx_en, pws_en))
+		retval = ALX_ERR_PWR_SAVING;
+	return retval;
+}
+
+/*
+ * NV Ram
+ */
+int alc_check_nvram(struct alx_hw *hw, bool *exist)
+{
+	*exist = false;
+	return 0;
+}
+
+int alc_read_nvram(struct alx_hw *hw, u16 offset, u32 *data)
+{
+	int i;
+	u32 ectrl1, ectrl2, edata;
+	int retval = 0;
+
+	if (offset & 0x3)
+		return retval; /* address do not align */
+
+	MEM_R32(hw, L1C_EFUSE_CTRL2, &ectrl2);
+	if (!(ectrl2 & L1C_EFUSE_CTRL2_CLK_EN))
+		MEM_W32(hw, L1C_EFUSE_CTRL2, ectrl2|L1C_EFUSE_CTRL2_CLK_EN);
+
+	MEM_W32(hw, L1C_EFUSE_DATA, 0);
+	ectrl1 = FIELDL(L1C_EFUSE_CTRL_ADDR, offset);
+	MEM_W32(hw, L1C_EFUSE_CTRL, ectrl1);
+
+	for (i = 0; i < 10; i++) {
+		__US_DELAY(100);
+		MEM_R32(hw, L1C_EFUSE_CTRL, &ectrl1);
+		if (ectrl1 & L1C_EFUSE_CTRL_FLAG)
+			break;
+	}
+	if (ectrl1 & L1C_EFUSE_CTRL_FLAG) {
+		MEM_R32(hw, L1C_EFUSE_CTRL, &ectrl1);
+		MEM_R32(hw, L1C_EFUSE_DATA, &edata);
+		*data = LX_SWAP_DW((ectrl1 << 16) | (edata >> 16));
+		return retval;
+	}
+
+	if (!(ectrl2 & L1C_EFUSE_CTRL2_CLK_EN))
+		MEM_W32(hw, L1C_EFUSE_CTRL2, ectrl2);
+
+	return retval;
+}
+
+
+int alc_write_nvram(struct alx_hw *hw, u16 offset, u32 data)
+{
+	int retval = 0;
+	return retval;
+}
+
+
+/* fc */
+static int alc_get_fc_mode(struct alx_hw *hw, enum alx_fc_mode *mode)
+{
+	u16 bmsr, giga;
+	int i;
+	int retval = 0;
+
+	for (i = 0; i < ALX_MAX_SETUP_LNK_CYCLE; i++) {
+		__MS_DELAY(100);
+		alc_read_phy_reg(hw, ALX_MDIO_NORM_DEV, L1C_MII_BMSR, &bmsr);
+		alc_read_phy_reg(hw, ALX_MDIO_NORM_DEV, L1C_MII_BMSR, &bmsr);
+		if (bmsr & L1C_BMSR_LINK_STATUS) {
+			/* Read phy Specific Status Register (17) */
+			retval = alc_read_phy_reg(hw, ALX_MDIO_NORM_DEV,
+						  L1C_MII_GIGA_PSSR, &giga);
+			if (retval)
+				return retval;
+
+			if (!(giga & L1C_GIGA_PSSR_SPD_DPLX_RESOLVED))
+				return ALX_ERR_PHY_RESOLVED;
+
+			if ((giga & L1C_GIGA_PSSR_FC_TXEN) &&
+			    (giga & L1C_GIGA_PSSR_FC_RXEN)) {
+				*mode = alx_fc_full;
+			} else if (giga & L1C_GIGA_PSSR_FC_TXEN) {
+				*mode = alx_fc_tx_pause;
+			} else if (giga & L1C_GIGA_PSSR_FC_RXEN) {
+				*mode = alx_fc_rx_pause;
+			} else {
+				*mode = alx_fc_none;
+			}
+			break;
+		}
+	}
+
+	if (i == ALX_MAX_SETUP_LNK_CYCLE)
+		retval = ALX_ERR_PHY_SETUP_LNK;
+	return retval;
+}
+
+
+int alc_config_fc(struct alx_hw *hw)
+{
+	u32 mac;
+	int retval = 0;
+
+	if (hw->disable_fc_autoneg) {
+		hw->fc_was_autonegged = false;
+		hw->cur_fc_mode = hw->req_fc_mode;
+	} else {
+		hw->fc_was_autonegged = true;
+		retval = alc_get_fc_mode(hw, &hw->cur_fc_mode);
+		if (retval)
+			return retval;
+	}
+
+	MEM_R32(hw, L1C_MAC_CTRL, &mac);
+
+	switch (hw->cur_fc_mode) {
+	case alx_fc_none: /* 0 */
+		mac &= ~(L1C_MAC_CTRL_RXFC_EN | L1C_MAC_CTRL_TXFC_EN);
+		break;
+	case alx_fc_rx_pause: /* 1 */
+		mac &= ~L1C_MAC_CTRL_TXFC_EN;
+		mac |= L1C_MAC_CTRL_RXFC_EN;
+		break;
+	case alx_fc_tx_pause: /* 2 */
+		mac |= L1C_MAC_CTRL_TXFC_EN;
+		mac &= ~L1C_MAC_CTRL_RXFC_EN;
+		break;
+	case alx_fc_full: /* 3 */
+	case alx_fc_default: /* 4 */
+		mac |= (L1C_MAC_CTRL_TXFC_EN | L1C_MAC_CTRL_RXFC_EN);
+		break;
+	default:
+		HW_PRINT(ERR, "Flow control param set incorrectly\n");
+		return -1;
+	}
+
+	MEM_W32(hw, L1C_MAC_CTRL, mac);
+
+	return retval;
+}
+
+
+/* ethtool */
+int alc_get_ethtool_regs(struct alx_hw *hw, void *buff)
+{
+	u32 *regs = (u32 *)buff;
+	int retval = 0;
+
+	MEM_R32(hw, L1C_LNK_CAP,        &regs[0]);
+	MEM_R32(hw, L1C_PMCTRL,         &regs[1]);
+	MEM_R32(hw, L1C_HALFD,          &regs[2]);
+	MEM_R32(hw, L1C_SLD,            &regs[3]);
+	MEM_R32(hw, L1C_MASTER,         &regs[4]);
+	MEM_R32(hw, L1C_MANU_TIMER,     &regs[5]);
+	MEM_R32(hw, L1C_IRQ_MODU_TIMER, &regs[6]);
+	MEM_R32(hw, L1C_PHY_CTRL,       &regs[7]);
+	MEM_R32(hw, L1C_LNK_CTRL,       &regs[8]);
+	MEM_R32(hw, L1C_MAC_STS,        &regs[9]);
+
+	MEM_R32(hw, L1C_MDIO,      &regs[10]);
+	MEM_R32(hw, L1C_SERDES,    &regs[11]);
+	MEM_R32(hw, L1C_MAC_CTRL,  &regs[12]);
+	MEM_R32(hw, L1C_GAP,       &regs[13]);
+	MEM_R32(hw, L1C_STAD0,     &regs[14]);
+	MEM_R32(hw, L1C_STAD1,     &regs[15]);
+	MEM_R32(hw, L1C_HASH_TBL0, &regs[16]);
+	MEM_R32(hw, L1C_HASH_TBL1, &regs[17]);
+	MEM_R32(hw, L1C_RXQ0,      &regs[18]);
+	MEM_R32(hw, L1C_RXQ1,      &regs[19]);
+
+	MEM_R32(hw, L1C_RXQ2, &regs[20]);
+	MEM_R32(hw, L1C_RXQ3, &regs[21]);
+	MEM_R32(hw, L1C_TXQ0, &regs[22]);
+	MEM_R32(hw, L1C_TXQ1, &regs[23]);
+	MEM_R32(hw, L1C_TXQ2, &regs[24]);
+	MEM_R32(hw, L1C_MTU,  &regs[25]);
+	MEM_R32(hw, L1C_WOL0, &regs[26]);
+	MEM_R32(hw, L1C_WOL1, &regs[27]);
+	MEM_R32(hw, L1C_WOL2, &regs[28]);
+	return retval;
+}
+
+
+/******************************************************************************/
+
+static int alc_get_hw_capabilities(struct alx_hw *hw)
+{
+	u32 link;
+	int retval = 0;
+	/* set flags of alx_hw */
+
+	MEM_R32(hw, L1C_LNK_CTRL, &link);
+	if (link & L1C_LNK_CTRL_ASPM_ENL0S)
+		SET_HW_FLAG(L0S_CAP);
+	if (link & L1C_LNK_CTRL_ASPM_ENL1)
+		SET_HW_FLAG(L1_CAP);
+
+	if ((hw->mac_type == alx_mac_l1c) ||
+	    (hw->mac_type == alx_mac_l1d_v1) ||
+	    (hw->mac_type == alx_mac_l1d_v2))
+		SET_HW_FLAG(GIGA_CAP);
+
+	SET_HW_FLAG(PWSAVE_CAP);
+	return retval;
+}
+
+/* alc_set_hw_info */
+static int alc_set_hw_infos(struct alx_hw *hw)
+{
+	int retval = 0;
+
+	hw->rxstat_reg = 0x1700;
+	hw->rxstat_sz  = 0x60;
+	hw->txstat_reg = 0x1760;
+	hw->txstat_sz  = 0x68;
+
+	hw->rx_prod_reg[0] = L1C_RFD_PIDX;
+	hw->rx_cons_reg[0] = L1C_RFD_CIDX;
+
+	hw->tx_prod_reg[0] = L1C_TPD_PRI0_PIDX;
+	hw->tx_cons_reg[0] = L1C_TPD_PRI0_CIDX;
+	hw->tx_prod_reg[1] = L1C_TPD_PRI1_PIDX;
+	hw->tx_cons_reg[1] = L1C_TPD_PRI1_CIDX;
+
+	hw->hwreg_sz = 0x80;
+	hw->eeprom_sz = 0;
+
+	return retval;
+}
+
+
+/**
+ *  alc_init_hw_callbacks - Inits func ptrs and MAC type
+ *  @hw: pointer to hardware structure
+ **/
+int alc_init_hw_callbacks(struct alx_hw *hw)
+{
+	int retval = 0;
+
+	/* NIC */
+	hw->cbs.identify_nic   = &alc_identify_nic;
+	/* MAC*/
+	hw->cbs.reset_mac      = &alc_reset_mac;
+	hw->cbs.start_mac      = &alc_start_mac;
+	hw->cbs.stop_mac       = &alc_stop_mac;
+	hw->cbs.config_mac     = &alc_config_mac;
+	hw->cbs.get_mac_addr   = &alc_get_mac_addr;
+	hw->cbs.set_mac_addr   = &alc_set_mac_addr;
+	hw->cbs.clear_mac_addr = &alc_clear_mac_addr;
+	hw->cbs.set_mc_addr    = &alc_set_mc_addr;
+	hw->cbs.clear_mc_addr  = &alc_clear_mc_addr;
+
+	/* PHY */
+	hw->cbs.init_phy       = &alc_init_phy;
+	hw->cbs.reset_phy      = &alc_reset_phy;
+	hw->cbs.read_phy_reg   = &alc_read_phy_reg;
+	hw->cbs.write_phy_reg  = &alc_write_phy_reg;
+	hw->cbs.check_phy_link = &alc_check_phy_link;
+	hw->cbs.setup_phy_link = &alc_setup_phy_link;
+	hw->cbs.setup_phy_link_speed = &alc_setup_phy_link_speed;
+
+
+	/* Interrupt */
+	hw->cbs.ack_phy_intr	= &alc_ack_phy_intr;
+	hw->cbs.enable_legacy_intr  = &alc_enable_legacy_intr;
+	hw->cbs.disable_legacy_intr = &alc_disable_legacy_intr;
+
+	/* Configure */
+	hw->cbs.config_rx	= &alc_config_rx;
+	hw->cbs.config_tx	= &alc_config_tx;
+	hw->cbs.config_fc	= &alc_config_fc;
+	hw->cbs.config_aspm	= &alc_config_aspm;
+	hw->cbs.config_wol	= &alc_config_wol;
+	hw->cbs.config_mac_ctrl	= &alc_config_mac_ctrl;
+	hw->cbs.config_pow_save	= &alc_config_pow_save;
+	hw->cbs.reset_pcie	= &alc_reset_pcie;
+
+	/* NVRam */
+	hw->cbs.check_nvram	= &alc_check_nvram;
+	hw->cbs.read_nvram	= &alc_read_nvram;
+	hw->cbs.write_nvram	= &alc_write_nvram;
+
+	/* Others */
+	hw->cbs.get_ethtool_regs = alc_get_ethtool_regs;
+
+	/* get hw capabilitites to HW->flags */
+	retval = alc_get_hw_capabilities(hw);
+
+	retval = alc_set_hw_infos(hw);
+
+	/* print all flags */
+	HW_PRINT(INFO, "HW Flags = 0x%x\n", hw->flags);
+	return retval;
+}
+
diff --git a/drivers/net/ethernet/atheros/alx/alc_hw.c b/drivers/net/ethernet/atheros/alx/alc_hw.c
new file mode 100755
index 0000000..01c80aa
--- /dev/null
+++ b/drivers/net/ethernet/atheros/alx/alc_hw.c
@@ -0,0 +1,1258 @@
+/*
+ * Copyright (c) 2010 - 2011 Atheros Communications Inc.
+ *
+ * Permission to use, copy, modify, and/or distribute this software for any
+ * purpose with or without fee is hereby granted, provided that the above
+ * copyright notice and this permission notice appear in all copies.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
+ * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
+ * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
+ * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
+ * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
+ * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ */
+
+#include "alc_hw.h"
+
+
+
+/*
+ * get permanent mac address
+ *    0: success
+ *    non-0:fail
+ */
+u16 l1c_get_perm_macaddr(PETHCONTEXT ctx, u8 *addr)
+{
+	u32 val, otp_ctrl, otp_flag, mac0, mac1;
+	u16 i;
+	u16 phy_val;
+
+	/* get it from register first */
+	MEM_R32(ctx, L1C_STAD0, &mac0);
+	MEM_R32(ctx, L1C_STAD1, &mac1);
+
+	*(u32 *)(addr + 2) = LX_SWAP_DW(mac0);
+	*(u16 *)addr = (u16)LX_SWAP_W((u16)mac1);
+	if (macaddr_valid(addr)) {
+		return 0;
+	}
+
+	MEM_R32(ctx, L1C_TWSI_DBG, &val);
+	MEM_R32(ctx, L1C_EFUSE_CTRL2, &otp_ctrl);
+	MEM_R32(ctx, L1C_MASTER, &otp_flag);
+
+	if (0 != (val & L1C_TWSI_DBG_DEV_EXIST) ||
+	    0 != (otp_flag & L1C_MASTER_OTP_FLG)) {
+		/* nov-memory exist, do software-autoload */
+		/* enable OTP_CLK for L1C */
+		if (ctx->pci_devid == L1C_DEV_ID ||
+		    ctx->pci_devid == L2C_DEV_ID) {
+			if (0 != (otp_ctrl & L1C_EFUSE_CTRL2_CLK_EN)) {
+				MEM_W32(ctx, L1C_EFUSE_CTRL2,
+				    otp_ctrl | L1C_EFUSE_CTRL2_CLK_EN);
+				US_DELAY(ctx, 5);
+			}
+		}
+		/* raise voltage temporally for L2CB/L1D */
+		if (ctx->pci_devid == L2CB_DEV_ID ||
+		    ctx->pci_devid == L2CB2_DEV_ID) {
+			/* clear bit[7] of debugport 00 */
+			l1c_read_phydbg(ctx, true, L1C_MIIDBG_ANACTRL,
+			    &phy_val);
+			l1c_write_phydbg(ctx, true, L1C_MIIDBG_ANACTRL,
+			    phy_val & ~L1C_ANACTRL_HB_EN);
+			/* set bit[3] of debugport 3B */
+			l1c_read_phydbg(ctx, true, L1C_MIIDBG_VOLT_CTRL,
+			    &phy_val);
+			l1c_write_phydbg(ctx, true, L1C_MIIDBG_VOLT_CTRL,
+			    phy_val | L1C_VOLT_CTRL_SWLOWEST);
+			US_DELAY(ctx, 20);
+		}
+		/* do load */
+		MEM_R32(ctx, L1C_SLD, &val);
+		MEM_W32(ctx, L1C_SLD, val | L1C_SLD_START);
+		for (i = 0; i < L1C_SLD_MAX_TO; i++) {
+			MS_DELAY(ctx, 1);
+			MEM_R32(ctx, L1C_SLD, &val);
+			if (0 == (val & L1C_SLD_START)) {
+				break;
+			}
+		}
+		/* disable OTP_CLK for L1C */
+		if (ctx->pci_devid == L1C_DEV_ID ||
+		    ctx->pci_devid == L2C_DEV_ID) {
+			MEM_W32(ctx, L1C_EFUSE_CTRL2,
+			    otp_ctrl & ~L1C_EFUSE_CTRL2_CLK_EN);
+			US_DELAY(ctx, 5);
+		}
+		/* low voltage */
+		if (ctx->pci_devid == L2CB_DEV_ID ||
+		    ctx->pci_devid == L2CB2_DEV_ID) {
+			/* set bit[7] of debugport 00 */
+			l1c_read_phydbg(ctx, true, L1C_MIIDBG_ANACTRL,
+			    &phy_val);
+			l1c_write_phydbg(ctx, true, L1C_MIIDBG_ANACTRL,
+			    phy_val | L1C_ANACTRL_HB_EN);
+			/* clear bit[3] of debugport 3B */
+			l1c_read_phydbg(ctx, true, L1C_MIIDBG_VOLT_CTRL,
+			    &phy_val);
+			l1c_write_phydbg(ctx, true, L1C_MIIDBG_VOLT_CTRL,
+			    phy_val & ~L1C_VOLT_CTRL_SWLOWEST);
+			US_DELAY(ctx, 20);
+		}
+		if (i == L1C_SLD_MAX_TO) {
+			goto sw_assign;
+		}
+	} else {
+		if (ctx->pci_devid == L1C_DEV_ID ||
+		    ctx->pci_devid == L2C_DEV_ID) {
+			MEM_W32(ctx, L1C_EFUSE_CTRL2,
+			    otp_ctrl & ~L1C_EFUSE_CTRL2_CLK_EN);
+			US_DELAY(ctx, 5);
+		}
+	}
+
+	MEM_R32(ctx, L1C_STAD0, &mac0);
+	MEM_R32(ctx, L1C_STAD1, &mac1);
+
+	*(u32 *)(addr + 2) = LX_SWAP_DW(mac0);
+	*(u16 *)addr = (u16)LX_SWAP_W((u16)mac1);
+	if (macaddr_valid(addr)) {
+		return 0;
+	}
+
+sw_assign:
+	/* assign a fixed one (Atheros OUI, 00-13-74) */
+	*(u32 *)(addr + 2) = 0x00000074UL;
+	*(u16 *)addr = 0x1300;
+
+	return LX_ERR_ALOAD;
+}
+
+/*
+ * reset mac & dma
+ * return
+ *     0: success
+ *     non-0:fail
+ */
+u16 l1c_reset_mac(PETHCONTEXT ctx)
+{
+	u32 val, mrst_val;
+	u16 ret;
+	u16 i;
+
+	/* disable all interrupts, RXQ/TXQ */
+	MEM_W32(ctx, L1C_IMR, 0);
+	MEM_W32(ctx, L1C_ISR, L1C_ISR_DIS);
+
+	ret = l1c_enable_mac(ctx, false, 0);
+	if (0 != ret) {
+		return ret;
+	}
+	/* reset whole mac safely. OOB is meaningful for L1D only  */
+	MEM_R32(ctx, L1C_MASTER, &mrst_val);
+	mrst_val |= L1C_MASTER_OOB_DIS;
+	MEM_W32(ctx, L1C_MASTER, mrst_val | L1C_MASTER_DMA_MAC_RST);
+
+	/* make sure it's idle */
+	for (i = 0; i < L1C_DMA_MAC_RST_TO; i++) {
+		MEM_R32(ctx, L1C_MASTER, &val);
+		if (0 == (val & L1C_MASTER_DMA_MAC_RST)) {
+			break;
+		}
+		US_DELAY(ctx, 20);
+	}
+	if (i == L1C_DMA_MAC_RST_TO) {
+		return LX_ERR_RSTMAC;
+	}
+	/* keep the old value */
+	MEM_W32(ctx, L1C_MASTER, mrst_val & ~L1C_MASTER_DMA_MAC_RST);
+
+	/* driver control speed/duplex, hash-alg */
+	MEM_R32(ctx, L1C_MAC_CTRL, &val);
+	MEM_W32(ctx, L1C_MAC_CTRL, val | L1C_MAC_CTRL_WOLSPED_SWEN);
+
+	/* clk switch setting */
+	MEM_R32(ctx, L1C_SERDES, &val);
+	switch (ctx->pci_devid) {
+	case L2CB_DEV_ID:
+		MEM_W32(ctx, L1C_SERDES, val & ~L1C_SERDES_PHYCLK_SLWDWN);
+		break;
+	case L2CB2_DEV_ID:
+	case L1D2_DEV_ID:
+		MEM_W32(ctx, L1C_SERDES,
+		    val | L1C_SERDES_PHYCLK_SLWDWN | L1C_SERDES_MACCLK_SLWDWN);
+		break;
+	default:
+		/* the defalut value of default product is OFF */;
+	}
+
+	return 0;
+}
+
+/* reset phy
+ * return
+ *    0: success
+ *    non-0:fail
+ */
+u16 l1c_reset_phy(PETHCONTEXT ctx, bool pws_en, bool az_en, bool ptp_en)
+{
+	u32 val;
+	u16 i, phy_val;
+
+	ptp_en = ptp_en;
+
+	/* reset PHY core */
+	MEM_R32(ctx, L1C_PHY_CTRL, &val);
+	val &= ~(L1C_PHY_CTRL_DSPRST_OUT | L1C_PHY_CTRL_IDDQ |
+	    L1C_PHY_CTRL_GATE_25M | L1C_PHY_CTRL_POWER_DOWN |
+	    L1C_PHY_CTRL_CLS);
+	val |= L1C_PHY_CTRL_RST_ANALOG;
+
+	if (pws_en) {
+		val |= (L1C_PHY_CTRL_HIB_PULSE | L1C_PHY_CTRL_HIB_EN);
+	} else {
+		val &= ~(L1C_PHY_CTRL_HIB_PULSE | L1C_PHY_CTRL_HIB_EN);
+	}
+	MEM_W32(ctx, L1C_PHY_CTRL, val);
+	US_DELAY(ctx, 10); /* 5us is enough */
+	MEM_W32(ctx, L1C_PHY_CTRL, val | L1C_PHY_CTRL_DSPRST_OUT);
+
+	for (i = 0; i < L1C_PHY_CTRL_DSPRST_TO; i++) { /* delay 800us */
+		US_DELAY(ctx, 10);
+	}
+
+	/* switch clock */
+	if (ctx->pci_devid == L2CB_DEV_ID) {
+		l1c_read_phydbg(ctx, true, L1C_MIIDBG_CFGLPSPD, &phy_val);
+		l1c_write_phydbg(ctx, true, L1C_MIIDBG_CFGLPSPD,
+		    phy_val & ~L1C_CFGLPSPD_RSTCNT_CLK125SW); /* clear bit13 */
+	}
+
+	/* fix tx-half-amp issue */
+	if (ctx->pci_devid == L2CB_DEV_ID || ctx->pci_devid == L2CB2_DEV_ID) {
+		l1c_read_phydbg(ctx, true, L1C_MIIDBG_CABLE1TH_DET, &phy_val);
+		l1c_write_phydbg(ctx, true, L1C_MIIDBG_CABLE1TH_DET,
+		    phy_val | L1C_CABLE1TH_DET_EN); /* set bit15 */
+	}
+
+	if (pws_en) {
+		/* clear bit[3] of debugport 3B to 0,
+		 * lower voltage to save power */
+		if (ctx->pci_devid == L2CB_DEV_ID ||
+		    ctx->pci_devid == L2CB2_DEV_ID) {
+			l1c_read_phydbg(ctx, true, L1C_MIIDBG_VOLT_CTRL,
+			    &phy_val);
+			l1c_write_phydbg(ctx, true, L1C_MIIDBG_VOLT_CTRL,
+			    phy_val & ~L1C_VOLT_CTRL_SWLOWEST);
+		}
+		/* power saving config */
+		l1c_write_phydbg(ctx, true, L1C_MIIDBG_LEGCYPS,
+		    (ctx->pci_devid == L1D_DEV_ID ||
+		     ctx->pci_devid == L1D2_DEV_ID) ?
+			L1D_LEGCYPS_DEF : L1C_LEGCYPS_DEF);
+		/* hib */
+		l1c_write_phydbg(ctx, true, L1C_MIIDBG_SYSMODCTRL,
+		    L1C_SYSMODCTRL_IECHOADJ_DEF);
+	} else {
+		/*dis powersaving */
+		l1c_read_phydbg(ctx, true, L1C_MIIDBG_LEGCYPS, &phy_val);
+		l1c_write_phydbg(ctx, true, L1C_MIIDBG_LEGCYPS,
+		    phy_val & ~L1C_LEGCYPS_EN);
+		/* disable hibernate */
+		l1c_read_phydbg(ctx, true, L1C_MIIDBG_HIBNEG, &phy_val);
+		l1c_write_phydbg(ctx, true, L1C_MIIDBG_HIBNEG,
+		    phy_val & ~L1C_HIBNEG_PSHIB_EN);
+	}
+
+	/* az is only for l2cbv2 / l1dv1 /l1dv2 */
+	if (ctx->pci_devid == L1D_DEV_ID ||
+	    ctx->pci_devid == L1D2_DEV_ID ||
+	    ctx->pci_devid == L2CB2_DEV_ID) {
+		if (az_en) {
+			switch (ctx->pci_devid) {
+			case L2CB2_DEV_ID:
+				MEM_W32(ctx, L1C_LPI_DECISN_TIMER,
+				    L1C_LPI_DESISN_TIMER_L2CB);
+				/* az enable 100M */
+				l1c_write_phy(ctx, true, L1C_MIIEXT_ANEG, true,
+				    L1C_MIIEXT_LOCAL_EEEADV,
+				    L1C_LOCAL_EEEADV_100BT);
+				/* az long wake threshold */
+				l1c_write_phy(ctx, true, L1C_MIIEXT_PCS, true,
+				    L1C_MIIEXT_AZCTRL5,
+				    L1C_AZCTRL5_WAKE_LTH_L2CB);
+				/* az short wake threshold */
+				l1c_write_phy(ctx, true, L1C_MIIEXT_PCS, true,
+				    L1C_MIIEXT_AZCTRL4,
+				    L1C_AZCTRL4_WAKE_STH_L2CB);
+
+				l1c_write_phy(ctx, true, L1C_MIIEXT_PCS, true,
+				    L1C_MIIEXT_CLDCTRL3, L1C_CLDCTRL3_L2CB);
+
+				/* bit7 set to 0, otherwise ping fail */
+				l1c_write_phy(ctx, true, L1C_MIIEXT_PCS, true,
+				    L1C_MIIEXT_CLDCTRL7, L1C_CLDCTRL7_L2CB);
+
+				l1c_write_phy(ctx, true, L1C_MIIEXT_PCS, true,
+				    L1C_MIIEXT_AZCTRL2, L1C_AZCTRL2_L2CB);
+				break;
+
+			case L1D_DEV_ID:
+				l1c_write_phydbg(ctx, true,
+				    L1C_MIIDBG_AZ_ANADECT, L1C_AZ_ANADECT_DEF);
+				phy_val = ctx->long_cable ? L1C_CLDCTRL3_L1D :
+				    (L1C_CLDCTRL3_L1D &
+					~(L1C_CLDCTRL3_BP_CABLE1TH_DET_GT|
+					  L1C_CLDCTRL3_AZ_DISAMP));
+				l1c_write_phy(ctx, true, L1C_MIIEXT_PCS, true,
+				    L1C_MIIEXT_CLDCTRL3, phy_val);
+#if PHY_TYPE == PHY_TYPE_FPGA
+				l1c_write_phy(ctx, true, L1C_MIIEXT_PCS, true,
+				    L1C_MIIEXT_CLDCTRL7, L1C_CLDCTRL7_FPGA_DEF);
+				l1c_write_phy(ctx, true, L1C_MIIEXT_PCS, true,
+				    L1C_MIIEXT_AZCTRL, L1C_AZCTRL_FPGA_DEF);
+				l1c_write_phy(ctx, true, L1C_MIIEXT_PCS, true,
+				    L1C_MIIEXT_AZCTRL2, L1C_AZCTRL2_FPGA_DEF);
+#else
+				l1c_write_phy(ctx, true, L1C_MIIEXT_PCS, true,
+				    L1C_MIIEXT_AZCTRL, L1C_AZCTRL_L1D);
+				l1c_write_phy(ctx, true, L1C_MIIEXT_PCS, true,
+				    L1C_MIIEXT_AZCTRL2, L1C_AZCTRL2_L2CB);
+#endif
+				break;
+
+			case L1D2_DEV_ID:
+				l1c_write_phydbg(ctx, true,
+				    L1C_MIIDBG_AZ_ANADECT, L1C_AZ_ANADECT_DEF);
+				phy_val = ctx->long_cable ? L1C_CLDCTRL3_L1D :
+				    (L1C_CLDCTRL3_L1D &
+					~L1C_CLDCTRL3_BP_CABLE1TH_DET_GT);
+				l1c_write_phy(ctx, true, L1C_MIIEXT_PCS, true,
+				    L1C_MIIEXT_CLDCTRL3, phy_val);
+#if PHY_TYPE == PHY_TYPE_FPGA
+				l1c_write_phy(ctx, true, L1C_MIIEXT_PCS, true,
+				    L1C_MIIEXT_CLDCTRL7, L1C_CLDCTRL7_FPGA_DEF);
+				l1c_write_phy(ctx, true, L1C_MIIEXT_PCS, true,
+				    L1C_MIIEXT_AZCTRL, L1C_AZCTRL_FPGA_DEF);
+				l1c_write_phy(ctx, true, L1C_MIIEXT_PCS, true,
+				    L1C_MIIEXT_AZCTRL2, L1C_AZCTRL2_FPGA_DEF);
+#else
+				l1c_write_phy(ctx, true, L1C_MIIEXT_PCS, true,
+				    L1C_MIIEXT_AZCTRL, L1C_AZCTRL_L1D);
+				l1c_write_phy(ctx, true, L1C_MIIEXT_PCS, true,
+				    L1C_MIIEXT_AZCTRL2, L1C_AZCTRL2_L1D2);
+				l1c_write_phy(ctx, true, L1C_MIIEXT_PCS, true,
+				    L1C_MIIEXT_AZCTRL6, L1C_AZCTRL6_L1D2);
+#endif
+				break;
+			}
+		} else {
+			MEM_R32(ctx, L1C_LPI_CTRL, &val);
+			MEM_W32(ctx, L1C_LPI_CTRL, val & ~L1C_LPI_CTRL_EN);
+			l1c_write_phy(ctx, true, L1C_MIIEXT_ANEG, true,
+			    L1C_MIIEXT_LOCAL_EEEADV, 0);
+			l1c_write_phy(ctx, true, L1C_MIIEXT_PCS, true,
+			    L1C_MIIEXT_CLDCTRL3, L1C_CLDCTRL3_L2CB);
+		}
+	}
+
+	/* other debug port need to set */
+	l1c_write_phydbg(ctx, true, L1C_MIIDBG_ANACTRL, L1C_ANACTRL_DEF);
+	l1c_write_phydbg(ctx, true, L1C_MIIDBG_SRDSYSMOD, L1C_SRDSYSMOD_DEF);
+	l1c_write_phydbg(ctx, true, L1C_MIIDBG_TST10BTCFG, L1C_TST10BTCFG_DEF);
+	/* L1c, L2c, L1d, L2cb  link fail inhibit
+	   timer issue of L1c UNH-IOL test fail, set bit7*/
+	l1c_write_phydbg(ctx, true, L1C_MIIDBG_TST100BTCFG,
+	    L1C_TST100BTCFG_DEF | L1C_TST100BTCFG_LITCH_EN);
+
+	/* set phy interrupt mask */
+	l1c_write_phy(ctx, false, 0, true,
+	    L1C_MII_IER, L1C_IER_LINK_UP | L1C_IER_LINK_DOWN);
+
+	return 0;
+}
+
+
+/* reset pcie
+ * just reset pcie relative registers (pci command, clk, aspm...)
+ * return
+ *    0:success
+ *    non-0:fail
+ */
+u16 l1c_reset_pcie(PETHCONTEXT ctx, bool l0s_en, bool l1_en)
+{
+	u32 val;
+	u16 val16;
+	u16 ret;
+
+	/* Workaround for PCI problem when BIOS sets MMRBC incorrectly. */
+	CFG_R16(ctx, L1C_PCI_CMD, &val16);
+	if (0 == (val16 & (L1C_PCI_CMD_IOEN |
+			   L1C_PCI_CMD_MEMEN |
+			   L1C_PCI_CMD_MASTEREN)) ||
+	    0 != (val16 & L1C_PCI_CMD_DISINT)) {
+		val16 = (u16)((val16 | (L1C_PCI_CMD_IOEN |
+					L1C_PCI_CMD_MEMEN |
+					L1C_PCI_CMD_MASTEREN))
+			      & ~L1C_PCI_CMD_DISINT);
+		CFG_W16(ctx, L1C_PCI_CMD, val16);
+	}
+
+	/* Clear any PowerSaving Settings */
+	CFG_W16(ctx, L1C_PM_CSR, 0);
+
+	/* close write attr for some registes */
+	MEM_R32(ctx, L1C_LTSSM_CTRL, &val);
+	MEM_W32(ctx, L1C_LTSSM_CTRL, val & ~L1C_LTSSM_WRO_EN);
+
+	/* mask some pcie error bits */
+	MEM_R32(ctx, L1C_UE_SVRT, &val);
+	val &= ~(L1C_UE_SVRT_DLPROTERR | L1C_UE_SVRT_FCPROTERR);
+	MEM_W32(ctx, L1C_UE_SVRT, val);
+
+	/* pclk */
+	MEM_R32(ctx, L1C_MASTER, &val);
+	val &= ~L1C_MASTER_PCLKSEL_SRDS;
+	MEM_W32(ctx, L1C_MASTER, val);
+
+	/* Set 1000 bit 2, only used for L1c/L2c , WOL usage */
+	if (ctx->pci_devid == L1C_DEV_ID || ctx->pci_devid == L2C_DEV_ID) {
+		MEM_R32(ctx, L1C_PPHY_MISC1, &val);
+		MEM_W32(ctx, L1C_PPHY_MISC1, val | L1C_PPHY_MISC1_RCVDET);
+	} else { /* other device should set bit 5 of reg1400 for WOL */
+		if (0 == (val & L1C_MASTER_WAKEN_25M)) {
+			MEM_W32(ctx, L1C_MASTER, val | L1C_MASTER_WAKEN_25M);
+		}
+	}
+	/* l2cb 1.0*/
+	if (ctx->pci_devid == L2CB_DEV_ID && ctx->pci_revid == L2CB_V10) {
+		MEM_R32(ctx, L1C_PPHY_MISC2, &val);
+		FIELD_SETL(val, L1C_PPHY_MISC2_L0S_TH,
+		    L1C_PPHY_MISC2_L0S_TH_L2CB1);
+		FIELD_SETL(val, L1C_PPHY_MISC2_CDR_BW,
+		    L1C_PPHY_MISC2_CDR_BW_L2CB1);
+		MEM_W32(ctx, L1C_PPHY_MISC2, val);
+		/* extend L1 sync timer, this will use more power,
+		 * only for L2cb v1.0*/
+		if (!ctx->aps_en) {
+			MEM_R32(ctx, L1C_LNK_CTRL, &val);
+			MEM_W32(ctx, L1C_LNK_CTRL, val | L1C_LNK_CTRL_EXTSYNC);
+		}
+	}
+
+	/* l2cbv1.x & l1dv1.x */
+	if (ctx->pci_devid == L2CB_DEV_ID || ctx->pci_devid == L1D_DEV_ID) {
+		MEM_R32(ctx, L1C_PMCTRL, &val);
+		MEM_W32(ctx, L1C_PMCTRL, val | L1C_PMCTRL_L0S_BUFSRX_EN);
+		/* clear vendor message for L1d & L2cb */
+		MEM_R32(ctx, L1C_DMA_DBG, &val);
+		MEM_W32(ctx, L1C_DMA_DBG, val & ~L1C_DMA_DBG_VENDOR_MSG);
+	}
+
+	/* hi-tx-perf */
+	if (ctx->hi_txperf) {
+		MEM_R32(ctx, L1C_PPHY_MISC1, &val);
+		FIELD_SETL(val, L1C_PPHY_MISC1_NFTS,
+		    L1C_PPHY_MISC1_NFTS_HIPERF);
+		MEM_W32(ctx, L1C_PPHY_MISC1, val);
+	}
+	/* l0s, l1 setting */
+	ret = l1c_enable_aspm(ctx, l0s_en, l1_en, 0);
+
+	US_DELAY(ctx, 10);
+
+	return ret;
+}
+
+
+/* disable/enable MAC/RXQ/TXQ
+ * en
+ *    true:enable
+ *    false:disable
+ * return
+ *    0:success
+ *    non-0-fail
+ */
+u16 l1c_enable_mac(PETHCONTEXT ctx, bool en, u16 en_ctrl)
+{
+	u32 rxq, txq, mac, val;
+	u16 i;
+
+	MEM_R32(ctx, L1C_RXQ0, &rxq);
+	MEM_R32(ctx, L1C_TXQ0, &txq);
+	MEM_R32(ctx, L1C_MAC_CTRL, &mac);
+
+	if (en) { /* enable */
+		MEM_W32(ctx, L1C_RXQ0, rxq | L1C_RXQ0_EN);
+		MEM_W32(ctx, L1C_TXQ0, txq | L1C_TXQ0_EN);
+		if (0 != (en_ctrl & LX_MACSPEED_1000)) {
+			FIELD_SETL(mac, L1C_MAC_CTRL_SPEED,
+			    L1C_MAC_CTRL_SPEED_1000);
+		} else {
+			FIELD_SETL(mac, L1C_MAC_CTRL_SPEED,
+			    L1C_MAC_CTRL_SPEED_10_100);
+		}
+		if (0 != (en_ctrl & LX_MACDUPLEX_FULL)) {
+			mac |= L1C_MAC_CTRL_FULLD;
+		} else {
+			mac &= ~L1C_MAC_CTRL_FULLD;
+		}
+		/* rx filter */
+		if (0 != (en_ctrl & LX_FLT_PROMISC)) {
+			mac |= L1C_MAC_CTRL_PROMISC_EN;
+		} else {
+			mac &= ~L1C_MAC_CTRL_PROMISC_EN;
+		}
+		if (0 != (en_ctrl & LX_FLT_MULTI_ALL)) {
+			mac |= L1C_MAC_CTRL_MULTIALL_EN;
+		} else {
+			mac &= ~L1C_MAC_CTRL_MULTIALL_EN;
+		}
+		if (0 != (en_ctrl & LX_FLT_BROADCAST)) {
+			mac |= L1C_MAC_CTRL_BRD_EN;
+		} else {
+			mac &= ~L1C_MAC_CTRL_BRD_EN;
+		}
+		if (0 != (en_ctrl & LX_FLT_DIRECT)) {
+			mac |= L1C_MAC_CTRL_RX_EN;
+		} else { /* disable all recv if direct not enable */
+			mac &= ~L1C_MAC_CTRL_RX_EN;
+		}
+		if (0 != (en_ctrl & LX_FC_TXEN)) {
+			mac |= L1C_MAC_CTRL_TXFC_EN;
+		} else {
+			mac &= ~L1C_MAC_CTRL_TXFC_EN;
+		}
+		if (0 != (en_ctrl & LX_FC_RXEN)) {
+			mac |= L1C_MAC_CTRL_RXFC_EN;
+		} else {
+			mac &= ~L1C_MAC_CTRL_RXFC_EN;
+		}
+		if (0 != (en_ctrl & LX_VLAN_STRIP)) {
+			mac |= L1C_MAC_CTRL_VLANSTRIP;
+		} else {
+			mac &= ~L1C_MAC_CTRL_VLANSTRIP;
+		}
+		if (0 != (en_ctrl & LX_LOOPBACK)) {
+			mac |= (L1C_MAC_CTRL_LPBACK_EN);
+		} else {
+			mac &= ~L1C_MAC_CTRL_LPBACK_EN;
+		}
+		if (0 != (en_ctrl & LX_SINGLE_PAUSE)) {
+			mac |= L1C_MAC_CTRL_SPAUSE_EN;
+		} else {
+			mac &= ~L1C_MAC_CTRL_SPAUSE_EN;
+		}
+		if (0 != (en_ctrl & LX_ADD_FCS)) {
+			mac |= (L1C_MAC_CTRL_PCRCE | L1C_MAC_CTRL_CRCE);
+		} else {
+			mac &= ~(L1C_MAC_CTRL_PCRCE | L1C_MAC_CTRL_CRCE);
+		}
+		MEM_W32(ctx, L1C_MAC_CTRL, mac | L1C_MAC_CTRL_TX_EN);
+	} else { /* disable mac */
+		MEM_W32(ctx, L1C_RXQ0, rxq & ~L1C_RXQ0_EN);
+		MEM_W32(ctx, L1C_TXQ0, txq & ~L1C_TXQ0_EN);
+
+		/* waiting for rxq/txq be idle */
+		for (i = 0; i < L1C_DMA_MAC_RST_TO; i++) {/* wait atmost 1ms */
+			MEM_R32(ctx, L1C_MAC_STS, &val);
+			if (0 == (val &
+			    (L1C_MAC_STS_TXQ_BUSY | L1C_MAC_STS_RXQ_BUSY))) {
+				break;
+			}
+			US_DELAY(ctx, 20);
+		}
+		if (L1C_DMA_MAC_RST_TO == i) {
+			return LX_ERR_RSTMAC;
+		}
+		/* stop mac tx/rx */
+		MEM_W32(ctx, L1C_MAC_CTRL,
+		    mac & ~(L1C_MAC_CTRL_RX_EN | L1C_MAC_CTRL_TX_EN));
+
+		for (i = 0; i < L1C_DMA_MAC_RST_TO; i++) {
+			MEM_R32(ctx, L1C_MAC_STS, &val);
+			if (0 == (val & L1C_MAC_STS_IDLE)) {
+				break;
+			}
+			US_DELAY(ctx, 10);
+		}
+		if (L1C_DMA_MAC_RST_TO == i) {
+			return LX_ERR_RSTMAC;
+		}
+	}
+
+	return 0;
+}
+
+
+/* enable/disable aspm support
+ * that will change settings for phy/mac/pcie
+ */
+u16 l1c_enable_aspm(PETHCONTEXT ctx, bool l0s_en, bool l1_en, u8 lnk_stat)
+{
+	u32 pmctrl;
+	bool linkon;
+
+	linkon = (lnk_stat == LX_LC_10H || lnk_stat == LX_LC_10F ||
+		  lnk_stat == LX_LC_100H || lnk_stat == LX_LC_100F ||
+		  lnk_stat == LX_LC_1000F) ? true : false;
+
+	MEM_R32(ctx, L1C_PMCTRL, &pmctrl);
+	pmctrl &= ~(L1C_PMCTRL_L0S_EN |
+		    L1C_PMCTRL_L1_EN |
+		    L1C_PMCTRL_ASPM_FCEN);
+	FIELD_SETL(pmctrl, L1C_PMCTRL_LCKDET_TIMER,
+	    L1C_PMCTRL_LCKDET_TIMER_DEF);
+
+	/* l1 timer */
+	if (ctx->pci_devid == L2CB2_DEV_ID || ctx->pci_devid == L1D2_DEV_ID) {
+		pmctrl &= ~L1D_PMCTRL_TXL1_AFTER_L0S;
+		FIELD_SETL(pmctrl, L1D_PMCTRL_L1_TIMER,
+		    (lnk_stat == LX_LC_100H ||
+		     lnk_stat == LX_LC_100F ||
+		     lnk_stat == LX_LC_1000F) ?
+			L1D_PMCTRL_L1_TIMER_16US : 1);
+	} else {
+		FIELD_SETL(pmctrl, L1C_PMCTRL_L1_TIMER,
+		    (lnk_stat == LX_LC_100H ||
+		     lnk_stat == LX_LC_100F ||
+		     lnk_stat == LX_LC_1000F) ?
+		    ((ctx->pci_devid == L2CB_DEV_ID) ?
+			L1C_PMCTRL_L1_TIMER_L2CB1 : L1C_PMCTRL_L1_TIMER_DEF
+		    ) : 1);
+	}
+	if (l0s_en) { /* on/off l0s only if bios/system enable l0s */
+		pmctrl |= (L1C_PMCTRL_L0S_EN | L1C_PMCTRL_ASPM_FCEN);
+	}
+	if (l1_en) { /* on/off l1 only if bios/system enable l1 */
+		pmctrl |= (L1C_PMCTRL_L1_EN | L1C_PMCTRL_ASPM_FCEN);
+	}
+
+	if (ctx->pci_devid == L2CB_DEV_ID || ctx->pci_devid == L1D_DEV_ID ||
+	    ctx->pci_devid == L2CB2_DEV_ID || ctx->pci_devid == L1D2_DEV_ID) {
+		/* If the pm_request_l1 time exceeds the value of this timer,
+		   it will enter L0s instead of L1 for this ASPM request.*/
+		FIELD_SETL(pmctrl, L1C_PMCTRL_L1REQ_TO,
+		    L1C_PMCTRL_L1REG_TO_DEF);
+
+		pmctrl |= L1C_PMCTRL_RCVR_WT_1US    |   /* wait 1us not 2ms */
+			  L1C_PMCTRL_L1_SRDSRX_PWD  |   /* pwd serdes */
+			  L1C_PMCTRL_L1_CLKSW_EN;
+		pmctrl &= ~(L1C_PMCTRL_L1_SRDS_EN   |
+			    L1C_PMCTRL_L1_SRDSPLL_EN|
+			    L1C_PMCTRL_L1_BUFSRX_EN |
+			    L1C_PMCTRL_SADLY_EN     |
+			    L1C_PMCTRL_HOTRST_WTEN);
+		/* disable l0s if linkdown or l2cbv1.x */
+		if (!linkon ||
+		    (!ctx->aps_en && ctx->pci_devid == L2CB_DEV_ID)) {
+			pmctrl &= ~L1C_PMCTRL_L0S_EN;
+		}
+	} else { /* l1c */
+		FIELD_SETL(pmctrl, L1C_PMCTRL_L1_TIMER, 0);
+		if (linkon) {
+			pmctrl |= L1C_PMCTRL_L1_SRDS_EN     |
+				  L1C_PMCTRL_L1_SRDSPLL_EN  |
+				  L1C_PMCTRL_L1_BUFSRX_EN;
+			pmctrl &= ~(L1C_PMCTRL_L1_SRDSRX_PWD|
+				    L1C_PMCTRL_L1_CLKSW_EN  |
+				    L1C_PMCTRL_L0S_EN       |
+				    L1C_PMCTRL_L1_EN);
+		} else {
+			pmctrl |= L1C_PMCTRL_L1_CLKSW_EN;
+			pmctrl &= ~(L1C_PMCTRL_L1_SRDS_EN   |
+				    L1C_PMCTRL_L1_SRDSPLL_EN|
+				    L1C_PMCTRL_L1_BUFSRX_EN |
+				    L1C_PMCTRL_L0S_EN);
+		}
+	}
+
+	MEM_W32(ctx, L1C_PMCTRL, pmctrl);
+
+	return 0;
+}
+
+
+/* initialize phy for speed / flow control
+ * lnk_cap
+ *    if autoNeg, is link capability to tell the peer
+ *    if force mode, is forced speed/duplex
+ */
+u16 l1c_init_phy_spdfc(PETHCONTEXT ctx, bool auto_neg,
+		       u8 lnk_cap, bool fc_en)
+{
+	u16 adv, giga, cr;
+	u32 val;
+	u16 ret;
+
+	/* clear flag */
+	l1c_write_phy(ctx, false, 0, false, L1C_MII_DBG_ADDR, 0);
+	MEM_R32(ctx, L1C_DRV, &val);
+	FIELD_SETL(val, LX_DRV_PHY, 0);
+
+	if (auto_neg) {
+		adv = L1C_ADVERTISE_DEFAULT_CAP & ~L1C_ADVERTISE_SPEED_MASK;
+		giga = L1C_GIGA_CR_1000T_DEFAULT_CAP &
+		       ~L1C_GIGA_CR_1000T_SPEED_MASK;
+		val |= LX_DRV_PHY_AUTO;
+		if (!fc_en) {
+			adv &= ~(L1C_ADVERTISE_PAUSE | L1C_ADVERTISE_ASM_DIR);
+		} else {
+			val |= LX_DRV_PHY_FC;
+		}
+		if (0 != (LX_LC_10H & lnk_cap)) {
+			adv |= L1C_ADVERTISE_10T_HD_CAPS;
+			val |= LX_DRV_PHY_10;
+		}
+		if (0 != (LX_LC_10F & lnk_cap)) {
+			adv |= L1C_ADVERTISE_10T_FD_CAPS |
+			       L1C_ADVERTISE_10T_HD_CAPS;
+			val |= LX_DRV_PHY_10 | LX_DRV_PHY_DUPLEX;
+		}
+		if (0 != (LX_LC_100H & lnk_cap)) {
+			adv |= L1C_ADVERTISE_100TX_HD_CAPS;
+			val |= LX_DRV_PHY_100;
+		}
+		if (0 != (LX_LC_100F & lnk_cap)) {
+			adv |= L1C_ADVERTISE_100TX_FD_CAPS |
+			       L1C_ADVERTISE_100TX_HD_CAPS;
+			val |= LX_DRV_PHY_100 | LX_DRV_PHY_DUPLEX;
+		}
+		if (0 != (LX_LC_1000F & lnk_cap)) {
+			giga |= L1C_GIGA_CR_1000T_FD_CAPS;
+			val |= LX_DRV_PHY_1000 | LX_DRV_PHY_DUPLEX;
+		}
+
+		ret = l1c_write_phy(ctx, false, 0, false,
+			L1C_MII_ADVERTISE, adv);
+		ret = l1c_write_phy(ctx, false, 0, false,
+			L1C_MII_GIGA_CR, giga);
+
+		cr = L1C_BMCR_RESET |
+		     L1C_BMCR_AUTO_NEG_EN |
+		     L1C_BMCR_RESTART_AUTO_NEG;
+		ret = l1c_write_phy(ctx, false, 0, false, L1C_MII_BMCR, cr);
+	} else { /* force mode */
+		cr = L1C_BMCR_RESET;
+		switch (lnk_cap) {
+		case LX_LC_10H:
+			cr |= L1C_BMCR_SPEED_10;
+			val |= LX_DRV_PHY_10;
+			break;
+		case LX_LC_10F:
+			cr |= L1C_BMCR_SPEED_10 | L1C_BMCR_FULL_DUPLEX;
+			val |= LX_DRV_PHY_10 | LX_DRV_PHY_DUPLEX;
+			break;
+		case LX_LC_100H:
+			cr |= L1C_BMCR_SPEED_100;
+			val |= LX_DRV_PHY_100;
+			break;
+		case LX_LC_100F:
+			cr |= L1C_BMCR_SPEED_100 | L1C_BMCR_FULL_DUPLEX;
+			val |= LX_DRV_PHY_100 | LX_DRV_PHY_DUPLEX;
+			break;
+		default:
+			return LX_ERR_PARM;
+		}
+		ret = l1c_write_phy(ctx, false, 0, false, L1C_MII_BMCR, cr);
+	}
+
+	if (!ret) {
+		l1c_write_phy(ctx, false, 0, false, L1C_MII_DBG_ADDR,
+		    LX_PHY_INITED);
+	}
+	MEM_W32(ctx, L1C_DRV, val);
+
+	return ret;
+}
+
+/* do post setting on phy if link up/down event occur
+ */
+u16 l1c_post_phy_link(PETHCONTEXT ctx, bool linkon, u8 wire_spd)
+{
+	u16 phy_val;
+	bool adj_th =
+	    (ctx->pci_devid == L2CB_DEV_ID ||
+	     ctx->pci_devid == L2CB2_DEV_ID ||
+	     ctx->pci_devid == L1D_DEV_ID ||
+	     ctx->pci_devid == L1D2_DEV_ID) ? true : false;
+
+	if (linkon) {
+		/* az with broadcom, Half-amp */
+		if (ctx->pci_devid == L1D2_DEV_ID) {
+			l1c_read_phy(ctx, true, L1C_MIIEXT_PCS, true,
+			    L1C_MIIEXT_CLDCTRL6, &phy_val);
+			phy_val = FIELD_GETX(phy_val, L1C_CLDCTRL6_CAB_LEN);
+			l1c_write_phydbg(ctx, true, L1C_MIIDBG_AZ_ANADECT,
+			    (phy_val > L1C_CLDCTRL6_CAB_LEN_SHORT) ?
+				L1C_AZ_ANADECT_LONG : L1C_AZ_ANADECT_DEF);
+			l1c_write_phy(ctx, false, 0, true,
+			    L1C_MII_DBG_ADDR, LX_PHY_INITED);
+		}
+
+		/* threashold adjust */
+		if (adj_th && ctx->msi_lnkpatch &&
+		    (wire_spd == LX_LC_100F || wire_spd == LX_LC_100H)) {
+			l1c_write_phydbg(ctx, true, L1D_MIIDBG_MSE16DB,
+			    L1D_MSE16DB_UP);
+			l1c_write_phydbg(ctx, true, L1D_MIIDBG_SYSMODCTRL,
+			    L1D_SYSMODCTRL_IECHOADJ_DEF);
+		}
+
+	} else {
+		if (adj_th && ctx->msi_lnkpatch) {
+			l1c_write_phydbg(ctx, true, L1D_MIIDBG_SYSMODCTRL,
+			    L1C_SYSMODCTRL_IECHOADJ_DEF);
+			l1c_write_phydbg(ctx, true, L1D_MIIDBG_MSE16DB,
+			    L1D_MSE16DB_DOWN);
+		}
+	}
+
+	return 0;
+}
+
+/* do power saving setting befor enter suspend mode
+ * NOTE:
+ *    1. phy link must be established before calling this function
+ *    2. wol option (pattern,magic,link,etc.) is configed before call it.
+ */
+u16 l1c_powersaving(PETHCONTEXT ctx, u8 wire_spd, bool wol_en,
+		    bool mac_txen, bool mac_rxen, bool pws_en)
+{
+	u32 master_ctrl, mac_ctrl, phy_ctrl;
+	u16 pm_ctrl, ret = 0;
+
+	master_ctrl = 0;
+	mac_ctrl = 0;
+	phy_ctrl = 0;
+
+	pws_en = pws_en;
+
+	MEM_R32(ctx, L1C_MASTER, &master_ctrl);
+	master_ctrl &= ~L1C_MASTER_PCLKSEL_SRDS;
+
+	MEM_R32(ctx, L1C_MAC_CTRL, &mac_ctrl);
+	/* 10/100 half */
+	FIELD_SETL(mac_ctrl, L1C_MAC_CTRL_SPEED,  L1C_MAC_CTRL_SPEED_10_100);
+	mac_ctrl &= ~(L1C_MAC_CTRL_FULLD |
+		      L1C_MAC_CTRL_RX_EN |
+		      L1C_MAC_CTRL_TX_EN);
+
+	MEM_R32(ctx, L1C_PHY_CTRL, &phy_ctrl);
+	phy_ctrl &= ~(L1C_PHY_CTRL_DSPRST_OUT | L1C_PHY_CTRL_CLS);
+	/* if (pws_en) */
+	phy_ctrl |= (L1C_PHY_CTRL_RST_ANALOG | L1C_PHY_CTRL_HIB_PULSE |
+	    L1C_PHY_CTRL_HIB_EN);
+
+	if (wol_en) { /* enable rx packet or tx packet */
+		if (mac_rxen) {
+			mac_ctrl |= (L1C_MAC_CTRL_RX_EN | L1C_MAC_CTRL_BRD_EN);
+		}
+		if (mac_txen) {
+			mac_ctrl |= L1C_MAC_CTRL_TX_EN;
+		}
+		if (LX_LC_1000F == wire_spd) {
+			FIELD_SETL(mac_ctrl, L1C_MAC_CTRL_SPEED,
+			    L1C_MAC_CTRL_SPEED_1000);
+		}
+		if (LX_LC_10F == wire_spd || LX_LC_100F == wire_spd ||
+		    LX_LC_100F == wire_spd) {
+			mac_ctrl |= L1C_MAC_CTRL_FULLD;
+		}
+		phy_ctrl |= L1C_PHY_CTRL_DSPRST_OUT;
+		ret = l1c_write_phy(ctx, false, 0, false,
+		    L1C_MII_IER, L1C_IER_LINK_UP);
+	} else {
+		master_ctrl |= L1C_MASTER_PCLKSEL_SRDS;
+		ret = l1c_write_phy(ctx, false, 0, false, L1C_MII_IER, 0);
+		phy_ctrl |= (L1C_PHY_CTRL_IDDQ | L1C_PHY_CTRL_POWER_DOWN);
+	}
+	MEM_W32(ctx, L1C_MASTER, master_ctrl);
+	MEM_W32(ctx, L1C_MAC_CTRL, mac_ctrl);
+	MEM_W32(ctx, L1C_PHY_CTRL, phy_ctrl);
+
+	/* any debug info ???? */
+	DEBUG_INFOS(ctx, DEBUG_CAT_PME);
+
+	/* set PME_EN ?? */
+	if (wol_en) {
+		CFG_R16(ctx, L1C_PM_CSR, &pm_ctrl);
+		pm_ctrl |= L1C_PM_CSR_PME_EN;
+		CFG_W16(ctx, L1C_PM_CSR, pm_ctrl);
+	}
+
+	return ret;
+}
+
+
+/* read phy register */
+u16 l1c_read_phy(PETHCONTEXT ctx, bool ext, u8 dev, bool fast,
+		 u16 reg, u16 *data)
+{
+	u32 val;
+	u16 clk_sel, i, ret = 0;
+
+#if MAC_TYPE_FPGA == MAC_TYPE
+
+	MEM_W32(ctx, L1C_MDIO, 0);
+	US_DELAY(ctx, 30);
+	for (i = 0; i < L1C_MDIO_MAX_AC_TO; i++) {
+		MEM_R32(ctx, L1C_MDIO, &val);
+		if (0 == (val & L1C_MDIO_BUSY)) {
+			break;
+		}
+		US_DELAY(ctx, 10);
+	}
+#endif
+
+	*data = 0;
+	clk_sel = fast ?
+	    (u16)L1C_MDIO_CLK_SEL_25MD4 : (u16)L1C_MDIO_CLK_SEL_25MD128;
+
+	if (ext) {
+		val = FIELDL(L1C_MDIO_EXTN_DEVAD, dev) |
+		      FIELDL(L1C_MDIO_EXTN_REG, reg);
+		MEM_W32(ctx, L1C_MDIO_EXTN, val);
+
+		val = L1C_MDIO_SPRES_PRMBL |
+		      FIELDL(L1C_MDIO_CLK_SEL, clk_sel) |
+		      L1C_MDIO_START |
+		      L1C_MDIO_MODE_EXT |
+		      L1C_MDIO_OP_READ;
+	} else {
+		val = L1C_MDIO_SPRES_PRMBL |
+		      FIELDL(L1C_MDIO_CLK_SEL, clk_sel) |
+		      FIELDL(L1C_MDIO_REG, reg) |
+		      L1C_MDIO_START |
+		      L1C_MDIO_OP_READ;
+	}
+
+	MEM_W32(ctx, L1C_MDIO, val);
+
+	for (i = 0; i < L1C_MDIO_MAX_AC_TO; i++) {
+		MEM_R32(ctx, L1C_MDIO, &val);
+		if (0 == (val & L1C_MDIO_BUSY)) {
+			*data = (u16)FIELD_GETX(val, L1C_MDIO_DATA);
+			break;
+		}
+		US_DELAY(ctx, 10);
+	}
+	if (L1C_MDIO_MAX_AC_TO == i) {
+		ret = LX_ERR_MIIBUSY;
+	}
+
+#if MAC_TYPE_FPGA == MAC_TYPE
+	val |= L1C_MDIO_SPRES_PRMBL |
+	       FIELDL(L1C_MDIO_CLK_SEL, clk_sel) |
+	       FIELDL(L1C_MDIO_REG, 1) |
+	       L1C_MDIO_START |
+	       L1C_MDIO_OP_READ;
+
+	MEM_W32(ctx, L1C_MDIO, val);
+
+	for (i = 0; i < L1C_MDIO_MAX_AC_TO; i++) {
+		MEM_R32(ctx, L1C_MDIO, &val);
+		if (0 == (val & L1C_MDIO_BUSY)) {
+			break;
+		}
+		US_DELAY(ctx, 10);
+	}
+
+	MEM_W32(ctx, L1C_MDIO, (val & ~L1C_MDIO_START) | L1C_MDIO_AUTO_POLLING);
+	US_DELAY(ctx, 30);
+#endif
+
+	return ret;
+}
+
+/* write phy register */
+u16 l1c_write_phy(PETHCONTEXT ctx, bool ext, u8 dev, bool fast,
+		  u16 reg, u16 data)
+{
+	u32 val;
+	u16 clk_sel, i, ret = 0;
+
+#if MAC_TYPE_FPGA == MAC_TYPE
+	MEM_W32(ctx, L1C_MDIO, 0);
+	US_DELAY(ctx, 30);
+	for (i = 0; i < L1C_MDIO_MAX_AC_TO; i++) {
+		MEM_R32(ctx, L1C_MDIO, &val);
+		if (0 == (val & L1C_MDIO_BUSY)) {
+			break;
+		}
+		US_DELAY(ctx, 10);
+	}
+#endif
+
+	clk_sel = fast ?
+	    (u16)L1C_MDIO_CLK_SEL_25MD4 : (u16)L1C_MDIO_CLK_SEL_25MD128;
+
+	if (ext) {
+		val = FIELDL(L1C_MDIO_EXTN_DEVAD, dev) |
+		      FIELDL(L1C_MDIO_EXTN_REG, reg);
+		MEM_W32(ctx, L1C_MDIO_EXTN, val);
+
+		val = L1C_MDIO_SPRES_PRMBL |
+		      FIELDL(L1C_MDIO_CLK_SEL, clk_sel) |
+		      FIELDL(L1C_MDIO_DATA, data) |
+		      L1C_MDIO_START |
+		      L1C_MDIO_MODE_EXT;
+	} else {
+		val = L1C_MDIO_SPRES_PRMBL |
+		      FIELDL(L1C_MDIO_CLK_SEL, clk_sel) |
+		      FIELDL(L1C_MDIO_REG, reg) |
+		      FIELDL(L1C_MDIO_DATA, data) |
+		      L1C_MDIO_START;
+	}
+
+	MEM_W32(ctx, L1C_MDIO, val);
+
+	for (i = 0; i < L1C_MDIO_MAX_AC_TO; i++) {
+		MEM_R32(ctx, L1C_MDIO, &val);
+		if (0 == (val & L1C_MDIO_BUSY)) {
+			break;
+		}
+		US_DELAY(ctx, 10);
+	}
+	if (L1C_MDIO_MAX_AC_TO == i) {
+		ret = LX_ERR_MIIBUSY;
+	}
+
+#if MAC_TYPE_FPGA == MAC_TYPE
+	val |= L1C_MDIO_SPRES_PRMBL |
+	       FIELDL(L1C_MDIO_CLK_SEL, clk_sel) |
+	       FIELDL(L1C_MDIO_REG, 1) |
+	       L1C_MDIO_START |
+	       L1C_MDIO_OP_READ;
+
+	MEM_W32(ctx, L1C_MDIO, val);
+
+	for (i = 0; i < L1C_MDIO_MAX_AC_TO; i++) {
+		MEM_R32(ctx, L1C_MDIO, &val);
+		if (0 == (val & L1C_MDIO_BUSY)) {
+			break;
+		}
+		US_DELAY(ctx, 10);
+	}
+
+	MEM_W32(ctx, L1C_MDIO, (val & ~L1C_MDIO_START) | L1C_MDIO_AUTO_POLLING);
+	US_DELAY(ctx, 30);
+#endif
+
+	return ret;
+}
+
+u16 l1c_read_phydbg(PETHCONTEXT ctx, bool fast, u16 reg, u16 *data)
+{
+	u16 ret;
+
+	ret = l1c_write_phy(ctx, false, 0, fast, L1C_MII_DBG_ADDR, reg);
+	ret = l1c_read_phy(ctx, false, 0, fast, L1C_MII_DBG_DATA, data);
+
+	return ret;
+}
+
+u16 l1c_write_phydbg(PETHCONTEXT ctx, bool fast, u16 reg, u16 data)
+{
+	u16 ret;
+
+	ret = l1c_write_phy(ctx, false, 0, fast, L1C_MII_DBG_ADDR, reg);
+	ret = l1c_write_phy(ctx, false, 0, fast, L1C_MII_DBG_DATA, data);
+
+	return ret;
+}
+
+
+/*
+ * initialize mac basically
+ *  most of hi-feature no init
+ *      MAC/PHY should be reset before call this function
+ *  smb_timer : million-second
+ *  int_mod   : micro-second
+ *  disable RSS as default
+ */
+u16 l1c_init_mac(PETHCONTEXT ctx, u8 *addr, u32 txmem_hi,
+		 u32 *tx_mem_lo, u8 tx_qnum, u16 txring_sz,
+		 u32 rxmem_hi, u32 rfdmem_lo, u32 rrdmem_lo,
+		 u16 rxring_sz, u16 rxbuf_sz, u16 smb_timer,
+		 u16 mtu, u16 int_mod, bool hash_legacy)
+{
+	u32 val;
+	u16 val16;
+	u8 dmar_len;
+
+	/* set mac-address */
+	val = *(u32 *)(addr + 2);
+	MEM_W32(ctx, L1C_STAD0, LX_SWAP_DW(val));
+	val = *(u16 *)addr ;
+	MEM_W32(ctx, L1C_STAD1, LX_SWAP_W((u16)val));
+
+	/* clear multicast hash table, algrithm */
+	MEM_W32(ctx, L1C_HASH_TBL0, 0);
+	MEM_W32(ctx, L1C_HASH_TBL1, 0);
+	MEM_R32(ctx, L1C_MAC_CTRL, &val);
+	if (hash_legacy) {
+		val |= L1C_MAC_CTRL_MHASH_ALG_HI5B;
+	} else {
+		val &= ~L1C_MAC_CTRL_MHASH_ALG_HI5B;
+	}
+	MEM_W32(ctx, L1C_MAC_CTRL, val);
+
+	/* clear any wol setting/status */
+	MEM_R32(ctx, L1C_WOL0, &val);
+	MEM_W32(ctx, L1C_WOL0, 0);
+
+	/* clk gating */
+	MEM_W32(ctx, L1C_CLK_GATE, (ctx->pci_devid == L1D_DEV_ID) ? 0 :
+		       (L1C_CLK_GATE_DMAR | L1C_CLK_GATE_DMAW |
+			L1C_CLK_GATE_TXQ  | L1C_CLK_GATE_RXQ  |
+			L1C_CLK_GATE_TXMAC));
+
+	/* descriptor ring base memory */
+	MEM_W32(ctx, L1C_TX_BASE_ADDR_HI, txmem_hi);
+	MEM_W32(ctx, L1C_TPD_RING_SZ, txring_sz);
+	switch (tx_qnum) {
+	case 2:
+		MEM_W32(ctx, L1C_TPD_PRI1_ADDR_LO, tx_mem_lo[1]);
+		/* fall through */
+	case 1:
+		MEM_W32(ctx, L1C_TPD_PRI0_ADDR_LO, tx_mem_lo[0]);
+		break;
+	default:
+		return LX_ERR_PARM;
+	}
+	MEM_W32(ctx, L1C_RX_BASE_ADDR_HI, rxmem_hi);
+	MEM_W32(ctx, L1C_RFD_ADDR_LO, rfdmem_lo);
+	MEM_W32(ctx, L1C_RRD_ADDR_LO, rrdmem_lo);
+	MEM_W32(ctx, L1C_RFD_BUF_SZ, rxbuf_sz);
+	MEM_W32(ctx, L1C_RRD_RING_SZ, rxring_sz);
+	MEM_W32(ctx, L1C_RFD_RING_SZ, rxring_sz);
+	MEM_W32(ctx, L1C_SMB_TIMER, smb_timer * 500UL);
+
+	if (ctx->pci_devid == L2CB_DEV_ID) {
+		/* revise SRAM configuration */
+		MEM_W32(ctx, L1C_SRAM5, L1C_SRAM_RXF_LEN_L2CB1);
+		MEM_W32(ctx, L1C_SRAM7, L1C_SRAM_TXF_LEN_L2CB1);
+		MEM_W32(ctx, L1C_SRAM4, L1C_SRAM_RXF_HT_L2CB1);
+		MEM_W32(ctx, L1C_SRAM0, L1C_SRAM_RFD_HT_L2CB1);
+		MEM_W32(ctx, L1C_SRAM6, L1C_SRAM_TXF_HT_L2CB1);
+		MEM_W32(ctx, L1C_SRAM2, L1C_SRAM_TRD_HT_L2CB1);
+		MEM_W32(ctx, L1C_TXQ2, 0); /* TX watermark, goto L1 state.*/
+		MEM_W32(ctx, L1C_RXQ3, 0); /* RXD threshold. */
+	}
+	MEM_W32(ctx, L1C_SRAM9, L1C_SRAM_LOAD_PTR);
+
+	/* int moduration */
+	MEM_R32(ctx, L1C_MASTER, &val);
+	val |= L1C_MASTER_IRQMOD2_EN | L1C_MASTER_IRQMOD1_EN |
+	    L1C_MASTER_SYSALVTIMER_EN;  /* sysalive */
+	MEM_W32(ctx, L1C_MASTER, val);
+	/* set Interrupt Moderator Timer (max interrupt per sec)
+	 * we use seperate time for rx/tx */
+	MEM_W32(ctx, L1C_IRQ_MODU_TIMER, FIELDL(L1C_IRQ_MODU_TIMER1, int_mod) |
+	    FIELDL(L1C_IRQ_MODU_TIMER2, int_mod >> 1));
+
+	/* tpd threshold to trig int */
+	MEM_W32(ctx, L1C_TINT_TPD_THRSHLD, (u32)txring_sz / 3);
+	MEM_W32(ctx, L1C_TINT_TIMER, int_mod * 2);
+	/* re-send int */
+	MEM_W32(ctx, L1C_INT_RETRIG, L1C_INT_RETRIG_TO);
+
+	/* mtu */
+	MEM_W32(ctx, L1C_MTU, (u32)(mtu + 4 + 4)); /* crc + vlan */
+
+	/* txq */
+	if ((mtu + 8) < L1C_TXQ1_JUMBO_TSO_TH) {
+		val = (u32)(mtu + 8 + 7); /* 7 for QWORD align */
+	} else {
+		val = L1C_TXQ1_JUMBO_TSO_TH;
+	}
+	MEM_W32(ctx, L1C_TXQ1, val >> 3);
+
+	MEM_R32(ctx, L1C_DEV_CTRL, &val);
+	dmar_len = (u8)FIELD_GETX(val, L1C_DEV_CTRL_MAXRRS);
+	/* if BIOS had changed the default dma read max length,
+	 * restore it to default value */
+	if (dmar_len < L1C_DEV_CTRL_MAXRRS_MIN) {
+		FIELD_SETL(val, L1C_DEV_CTRL_MAXRRS, L1C_DEV_CTRL_MAXRRS_MIN);
+		MEM_W32(ctx, L1C_DEV_CTRL, val);
+		dmar_len = L1C_DEV_CTRL_MAXRRS_MIN;
+	}
+	val = FIELDL(L1C_TXQ0_TPD_BURSTPREF, L1C_TXQ0_TPD_BURSTPREF_DEF) |
+	      L1C_TXQ0_MODE_ENHANCE |
+	      L1C_TXQ0_LSO_8023_EN |
+	      L1C_TXQ0_SUPT_IPOPT |
+	      FIELDL(L1C_TXQ0_TXF_BURST_PREF,
+		(ctx->pci_devid == L2CB_DEV_ID ||
+		 ctx->pci_devid == L2CB2_DEV_ID) ?
+		 L1C_TXQ0_TXF_BURST_PREF_L2CB : L1C_TXQ0_TXF_BURST_PREF_DEF);
+	MEM_W32(ctx, L1C_TXQ0, val);
+
+	/* fc */
+	MEM_R32(ctx, L1C_SRAM5, &val);
+	val = FIELD_GETX(val, L1C_SRAM_RXF_LEN) << 3; /* bytes */
+	if (val > L1C_SRAM_RXF_LEN_8K) {
+		val16 = L1C_MTU_STD_ALGN;
+		val = (val - (2 * L1C_MTU_STD_ALGN + L1C_MTU_MIN));
+	} else {
+		val16 = L1C_MTU_STD_ALGN;
+		val = (val - L1C_MTU_STD_ALGN);
+	}
+	MEM_W32(ctx, L1C_RXQ2,
+	    FIELDL(L1C_RXQ2_RXF_XOFF_THRESH, val16 >> 3) |
+	    FIELDL(L1C_RXQ2_RXF_XON_THRESH, val >> 3));
+	/* rxq */
+	val = FIELDL(L1C_RXQ0_NUM_RFD_PREF, L1C_RXQ0_NUM_RFD_PREF_DEF) |
+	    L1C_RXQ0_IPV6_PARSE_EN;
+	if (mtu > L1C_MTU_JUMBO_TH) {
+		val |= L1C_RXQ0_CUT_THRU_EN;
+	}
+	if (0 != (ctx->pci_devid & 1)) {
+		FIELD_SETL(val, L1C_RXQ0_ASPM_THRESH,
+		    (ctx->pci_devid == L1D2_DEV_ID) ?
+			L1C_RXQ0_ASPM_THRESH_NO : L1C_RXQ0_ASPM_THRESH_100M);
+	}
+	MEM_W32(ctx, L1C_RXQ0, val);
+
+	/* rfd producer index */
+	MEM_W32(ctx, L1C_RFD_PIDX, (u32)rxring_sz - 1);
+
+	/* DMA */
+	val = FIELDL(L1C_DMA_RORDER_MODE, L1C_DMA_RORDER_MODE_OUT) |
+	      L1C_DMA_RREQ_PRI_DATA |
+	      FIELDL(L1C_DMA_RREQ_BLEN, dmar_len) |
+	      FIELDL(L1C_DMA_WDLY_CNT, L1C_DMA_WDLY_CNT_DEF) |
+	      FIELDL(L1C_DMA_RDLY_CNT, L1C_DMA_RDLY_CNT_DEF) ;
+	MEM_W32(ctx, L1C_DMA, val);
+
+	return 0;
+}
+
+
+u16 l1c_get_phy_config(PETHCONTEXT ctx)
+{
+	u32 val;
+	u16 phy_val;
+
+	MEM_R32(ctx, L1C_PHY_CTRL, &val);
+	if (0 == (val & L1C_PHY_CTRL_DSPRST_OUT)) { /* phy in rst */
+		return LX_DRV_PHY_UNKNOWN;
+	}
+
+	MEM_R32(ctx, L1C_DRV, &val);
+	val = FIELD_GETX(val, LX_DRV_PHY);
+	if (LX_DRV_PHY_UNKNOWN == val) {
+		return LX_DRV_PHY_UNKNOWN;
+	}
+
+	l1c_read_phy(ctx, false, 0, false, L1C_MII_DBG_ADDR, &phy_val);
+	if (LX_PHY_INITED == phy_val) {
+		return (u16) val;
+	}
+
+	return LX_DRV_PHY_UNKNOWN;
+}
+
diff --git a/drivers/net/ethernet/atheros/alx/alc_hw.h b/drivers/net/ethernet/atheros/alx/alc_hw.h
new file mode 100755
index 0000000..da50254
--- /dev/null
+++ b/drivers/net/ethernet/atheros/alx/alc_hw.h
@@ -0,0 +1,1483 @@
+/*
+ * Copyright (c) 2010 - 2011 Atheros Communications Inc.
+ *
+ * Permission to use, copy, modify, and/or distribute this software for any
+ * purpose with or without fee is hereby granted, provided that the above
+ * copyright notice and this permission notice appear in all copies.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
+ * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
+ * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
+ * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
+ * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
+ * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ */
+
+#ifndef L1C_HW_H_
+#define L1C_HW_H_
+
+
+#ifdef __cplusplus
+extern "C" {
+#endif/*__cplusplus*/
+
+/*********************************************************************
+ * some reqs for l1x_sw.h
+ *
+ * 1. some basic type must be defined if there are not defined by
+ *    your compiler:
+ *    u8, u16, u32, bool
+ *
+ * 2. PETHCONTEXT difinition should be in l1x_sw.h and it must contain
+ *    pci_devid & pci_venid & pci_revid
+ *
+ * 3. you must define MAC_FPGA , PHY_FPGA to 1 or o
+ *   #define MAC_TYPE   1   (1:FPGA, 0:ASIC)
+ *   #define PHY_TYPE   0   (2:F1, 1:FPGA, 0:ASIC)
+ *
+ *
+ *
+ *********************************************************************/
+
+#include "alx_hwcom.h"
+
+#if MAC_TYPE == MAC_TYPE_ASIC
+#undef PHY_TYPE
+#define PHY_TYPE PHY_TYPE_ASIC
+#endif
+
+
+/******************************************************************************/
+
+#define L1C_PCI_VID                     0x0000  /* 16bit */
+#define L1C_PCI_DID                     0x0002  /* 16bit */
+#define L1C_PCI_DID_GB                  BIT_0S
+#define L1C_DEV_ID                      0x1063
+#define L2C_DEV_ID                      0x1062
+#define L2CB_DEV_ID                     0x2060
+#define L2CB2_DEV_ID                    0x2062
+#define L1D_DEV_ID                      0x1073
+#define L1D2_DEV_ID                     0x1083
+
+#define L2CB_V10                        0xC0
+#define L2CB_V11                        0xC1
+#define L2CB_V20                        0xC0
+#define L2CB_V21                        0xC1
+
+
+
+#define L1C_PCI_CMD                     0x0004  /* 16bit */
+#define L1C_PCI_CMD_DISINT              BIT_10S
+#define L1C_PCI_CMD_MASTEREN            BIT_2S
+#define L1C_PCI_CMD_MEMEN               BIT_1S
+#define L1C_PCI_CMD_IOEN                BIT_0S
+
+#define L1C_PCI_STAT                    0x0006  /* 16bit */
+#define L1C_PCI_STAT_PERR               BIT_15S
+#define L1C_PCI_STAT_SERR               BIT_14S
+#define L1C_PCI_STAT_RMABT              BIT_13S
+#define L1C_PCI_STAT_RTABT              BIT_12S
+#define L1C_PCI_STAT_STABT              BIT_11S
+#define L1C_PCI_STAT_MDPERR             BIT_8S
+#define L1C_PCI_STAT_INTS               BIT_3S
+
+#define L1C_PCI_REVID                   0x0008  /* 8bit */
+#define L2CB_REV10                      0xC0
+#define L2CB_REV11                      0xC1
+#define L2CB_REV20                      0xC0
+#define L2CB_REV21                      0xC1
+
+#define L1C_PIF                         0x0009  /* 8bit program interface */
+#define L1C_SCC                         0x000A  /* 8bit sub-class */
+#define L1C_BCC                         0x000B  /* 8bit base-class */
+
+#define L1C_BAR1_LO                     0x0010  /* memory space */
+#define L1C_BAR1_HI                     0x0014
+
+#define L1C_BAR2_LO                     0x0018  /* io space */
+#define L1C_BAR2_HI                     0x001C
+
+#define L1C_PCI_SSVID                   0x002C  /* 16bit sub-vendor id */
+#define L1C_PCI_SSDID                   0x002E  /* 16bit sub-device id */
+
+#define L1C_EXPNSN_ROM                  0x0030
+
+#define L1C_INT_LINE                    0x003C  /* 8bit */
+
+#define L1C_PM_CSR                      0x0044  /* 16bit */
+#define L1C_PM_CSR_PME_STAT             BIT_15S
+#define L1C_PM_CSR_DSCAL_MASK           SHIFT13(3U)
+#define L1C_PM_CSR_DSCAL_SHIFT          13
+#define L1C_PM_CSR_DSEL_MASK            SHIFT9(0xFU)
+#define L1C_PM_CSR_DSEL_SHIFT           9
+#define L1C_PM_CSR_PME_EN               BIT_8S
+#define L1C_PM_CSR_PWST_MASK            SHIFT0(3U)
+#define L1C_PM_CSR_PWST_SHIFT           0
+
+#define L1C_PM_DATA                     0x0047  /* 8bit */
+
+#define L1C_DEV_CAP                     0x005C
+#define L1C_DEV_CAP_SPLSL_MASK          SHIFT26(3UL)
+#define L1C_DEV_CAP_SPLSL_SHIFT         26
+#define L1C_DEV_CAP_SPLV_MASK           SHIFT18(0xFFUL)
+#define L1C_DEV_CAP_SPLV_SHIFT          18
+#define L1C_DEV_CAP_RBER                BIT_15
+#define L1C_DEV_CAP_PIPRS               BIT_14
+#define L1C_DEV_CAP_AIPRS               BIT_13
+#define L1C_DEV_CAP_ABPRS               BIT_12
+#define L1C_DEV_CAP_L1ACLAT_MASK        SHIFT9(7UL)
+#define L1C_DEV_CAP_L1ACLAT_SHIFT       9
+#define L1C_DEV_CAP_L0SACLAT_MASK       SHIFT6(7UL)
+#define L1C_DEV_CAP_L0SACLAT_SHIFT      6
+#define L1C_DEV_CAP_EXTAG               BIT_5
+#define L1C_DEV_CAP_PHANTOM             BIT_4
+#define L1C_DEV_CAP_MPL_MASK            SHIFT0(7UL)
+#define L1C_DEV_CAP_MPL_SHIFT           0
+#define L1C_DEV_CAP_MPL_128             1
+#define L1C_DEV_CAP_MPL_256             2
+#define L1C_DEV_CAP_MPL_512             3
+#define L1C_DEV_CAP_MPL_1024            4
+#define L1C_DEV_CAP_MPL_2048            5
+#define L1C_DEV_CAP_MPL_4096            6
+
+#define L1C_DEV_CTRL                    0x0060    /* 16bit */
+#define L1C_DEV_CTRL_MAXRRS_MASK        SHIFT12(7U)
+#define L1C_DEV_CTRL_MAXRRS_SHIFT       12
+#define L1C_DEV_CTRL_MAXRRS_MIN         2
+#define L1C_DEV_CTRL_NOSNP_EN           BIT_11S
+#define L1C_DEV_CTRL_AUXPWR_EN          BIT_10S
+#define L1C_DEV_CTRL_PHANTOM_EN         BIT_9S
+#define L1C_DEV_CTRL_EXTAG_EN           BIT_8S
+#define L1C_DEV_CTRL_MPL_MASK           SHIFT5(7U)
+#define L1C_DEV_CTRL_MPL_SHIFT          5
+#define L1C_DEV_CTRL_RELORD_EN          BIT_4S
+#define L1C_DEV_CTRL_URR_EN             BIT_3S
+#define L1C_DEV_CTRL_FERR_EN            BIT_2S
+#define L1C_DEV_CTRL_NFERR_EN           BIT_1S
+#define L1C_DEV_CTRL_CERR_EN            BIT_0S
+
+#define L1C_DEV_STAT                    0x0062    /* 16bit */
+#define L1C_DEV_STAT_XS_PEND            BIT_5S
+#define L1C_DEV_STAT_AUXPWR             BIT_4S
+#define L1C_DEV_STAT_UR                 BIT_3S
+#define L1C_DEV_STAT_FERR               BIT_2S
+#define L1C_DEV_STAT_NFERR              BIT_1S
+#define L1C_DEV_STAT_CERR               BIT_0S
+
+#define L1C_LNK_CAP                     0x0064
+#define L1C_LNK_CAP_PRTNUM_MASK         SHIFT24(0xFFUL)
+#define L1C_LNK_CAP_PRTNUM_SHIFT        24
+#define L1C_LNK_CAP_CLK_PM              BIT_18
+#define L1C_LNK_CAP_L1EXTLAT_MASK       SHIFT15(7UL)
+#define L1C_LNK_CAP_L1EXTLAT_SHIFT      15
+#define L1C_LNK_CAP_L0SEXTLAT_MASK      SHIFT12(7UL)
+#define L1C_LNK_CAP_L0SEXTLAT_SHIFT     12
+#define L1C_LNK_CAP_ASPM_SUP_MASK       SHIFT10(3UL)
+#define L1C_LNK_CAP_ASPM_SUP_SHIFT      10
+#define L1C_LNK_CAP_ASPM_SUP_L0S        1
+#define L1C_LNK_CAP_ASPM_SUP_L0SL1      3
+#define L1C_LNK_CAP_MAX_LWH_MASK        SHIFT4(0x3FUL)
+#define L1C_LNK_CAP_MAX_LWH_SHIFT       4
+#define L1C_LNK_CAP_MAX_LSPD_MASH       SHIFT0(0xFUL)
+#define L1C_LNK_CAP_MAX_LSPD_SHIFT      0
+
+#define L1C_LNK_CTRL                    0x0068  /* 16bit */
+#define L1C_LNK_CTRL_CLK_PM_EN          BIT_8S
+#define L1C_LNK_CTRL_EXTSYNC            BIT_7S
+#define L1C_LNK_CTRL_CMNCLK_CFG         BIT_6S
+#define L1C_LNK_CTRL_RCB_128B           BIT_3S  /* 0:64b,1:128b */
+#define L1C_LNK_CTRL_ASPM_MASK          SHIFT0(3U)
+#define L1C_LNK_CTRL_ASPM_SHIFT         0
+#define L1C_LNK_CTRL_ASPM_DIS           0
+#define L1C_LNK_CTRL_ASPM_ENL0S         1
+#define L1C_LNK_CTRL_ASPM_ENL1          2
+#define L1C_LNK_CTRL_ASPM_ENL0SL1       3
+
+#define L1C_LNK_STAT                    0x006A  /* 16bit */
+#define L1C_LNK_STAT_SCLKCFG            BIT_12S
+#define L1C_LNK_STAT_LNKTRAIN           BIT_11S
+#define L1C_LNK_STAT_TRNERR             BIT_10S
+#define L1C_LNK_STAT_LNKSPD_MASK        SHIFT0(0xFU)
+#define L1C_LNK_STAT_LNKSPD_SHIFT       0
+#define L1C_LNK_STAT_NEGLW_MASK         SHIFT4(0x3FU)
+#define L1C_LNK_STAT_NEGLW_SHIFT        4
+
+#define L1C_UE_SVRT                     0x010C
+#define L1C_UE_SVRT_UR                  BIT_20
+#define L1C_UE_SVRT_ECRCERR             BIT_19
+#define L1C_UE_SVRT_MTLP                BIT_18
+#define L1C_UE_SVRT_RCVOVFL             BIT_17
+#define L1C_UE_SVRT_UNEXPCPL            BIT_16
+#define L1C_UE_SVRT_CPLABRT             BIT_15
+#define L1C_UE_SVRT_CPLTO               BIT_14
+#define L1C_UE_SVRT_FCPROTERR           BIT_13
+#define L1C_UE_SVRT_PTLP                BIT_12
+#define L1C_UE_SVRT_DLPROTERR           BIT_4
+#define L1C_UE_SVRT_TRNERR              BIT_0
+
+#define L1C_SLD                         0x0218  /* efuse load */
+#define L1C_SLD_FREQ_MASK               SHIFT24(3UL)
+#define L1C_SLD_FREQ_SHIFT              24
+#define L1C_SLD_FREQ_100K               0
+#define L1C_SLD_FREQ_200K               1
+#define L1C_SLD_FREQ_300K               2
+#define L1C_SLD_FREQ_400K               3
+#define L1C_SLD_EXIST                   BIT_23
+#define L1C_SLD_SLVADDR_MASK            SHIFT16(0x7FUL)
+#define L1C_SLD_SLVADDR_SHIFT           16
+#define L1C_SLD_IDLE                    BIT_13
+#define L1C_SLD_STAT                    BIT_12  /* 0:finish,1:in progress */
+#define L1C_SLD_START                   BIT_11
+#define L1C_SLD_STARTADDR_MASK          SHIFT0(0xFFUL)
+#define L1C_SLD_STARTADDR_SHIFT         0
+#define L1C_SLD_MAX_TO                  100
+
+#define L1C_PPHY_MISC1                  0x1000
+#define L1C_PPHY_MISC1_RCVDET           BIT_2
+#define L1C_PPHY_MISC1_NFTS_MASK        SHIFT16(0xFFUL)
+#define L1C_PPHY_MISC1_NFTS_SHIFT       16
+#define L1C_PPHY_MISC1_NFTS_HIPERF      0xA0    /* ???? */
+
+#define L1C_PPHY_MISC2                  0x1004
+#define L1C_PPHY_MISC2_L0S_TH_MASK      SHIFT18(0x3UL)
+#define L1C_PPHY_MISC2_L0S_TH_SHIFT     18
+#define L1C_PPHY_MISC2_L0S_TH_L2CB1     3
+#define L1C_PPHY_MISC2_CDR_BW_MASK      SHIFT16(0x3UL)
+#define L1C_PPHY_MISC2_CDR_BW_SHIFT     16
+#define L1C_PPHY_MISC2_CDR_BW_L2CB1     3
+
+#define L1C_PDLL_TRNS1                  0x1104
+#define L1C_PDLL_TRNS1_D3PLLOFF_EN      BIT_11
+#define L1C_PDLL_TRNS1_REGCLK_SEL_NORM  BIT_10
+#define L1C_PDLL_TRNS1_REPLY_TO_MASK    SHIFT0(0x3FFUL)
+#define L1C_PDLL_TRNS1_REPLY_TO_SHIFT   0
+
+#define L1C_TWSI_DBG                    0x1108
+#define L1C_TWSI_DBG_DEV_EXIST          BIT_29
+
+#define L1C_DMA_DBG                     0x1114
+#define L1C_DMA_DBG_VENDOR_MSG          BIT_0
+
+#define L1C_TLEXTN_STATS                0x1204  /* diff with l1f */
+#define L1C_TLEXTN_STATS_DEVNO_MASK     SHIFT16(0x1FUL)
+#define L1C_TLEXTN_STATS_DEVNO_SHIFT    16
+#define L1C_TLEXTN_STATS_BUSNO_MASK     SHIFT8(0xFFUL)
+#define L1C_TLEXTN_STATS_BUSNO_SHIFT    8
+
+#define L1C_EFUSE_CTRL                  0x12C0
+#define L1C_EFUSE_CTRL_FLAG             BIT_31  /* 0:read,1:write */
+#define L1C_EUFSE_CTRL_ACK              BIT_30
+#define L1C_EFUSE_CTRL_ADDR_MASK        SHIFT16(0x3FFUL)
+#define L1C_EFUSE_CTRL_ADDR_SHIFT       16
+
+#define L1C_EFUSE_DATA                  0x12C4
+
+#define EFUSE_OP_MAX_AC_TIMER           100     /* 1ms */
+
+#define L1C_EFUSE_CTRL2                 0x12F0
+#define L1C_EFUSE_CTRL2_CLK_EN          BIT_1
+
+#define L1C_PMCTRL                      0x12F8
+#define L1C_PMCTRL_HOTRST_WTEN          BIT_31
+#define L1C_PMCTRL_ASPM_FCEN            BIT_30  /* L0s/L1 dis by MAC based on
+						 * thrghput(setting in 15A0) */
+#define L1C_PMCTRL_SADLY_EN             BIT_29
+#define L1C_PMCTRL_L0S_BUFSRX_EN        BIT_28
+#define L1C_PMCTRL_LCKDET_TIMER_MASK    SHIFT24(0xFUL)
+#define L1C_PMCTRL_LCKDET_TIMER_SHIFT   24
+#define L1C_PMCTRL_LCKDET_TIMER_DEF     0xC
+#define L1C_PMCTRL_L1REQ_TO_MASK        SHIFT20(0xFUL)
+#define L1C_PMCTRL_L1REQ_TO_SHIFT       20      /* pm_request_l1 time > @
+						 * ->L0s not L1 */
+#define L1C_PMCTRL_L1REG_TO_DEF         0xC
+#define L1D_PMCTRL_TXL1_AFTER_L0S       BIT_19  /* l1dv2.0+ */
+#define L1D_PMCTRL_L1_TIMER_MASK        SHIFT16(7UL)
+#define L1D_PMCTRL_L1_TIMER_SHIFT       16
+#define L1D_PMCTRL_L1_TIMER_DIS         0
+#define L1D_PMCTRL_L1_TIMER_2US         1
+#define L1D_PMCTRL_L1_TIMER_4US         2
+#define L1D_PMCTRL_L1_TIMER_8US         3
+#define L1D_PMCTRL_L1_TIMER_16US        4
+#define L1D_PMCTRL_L1_TIMER_24US        5
+#define L1D_PMCTRL_L1_TIMER_32US        6
+#define L1D_PMCTRL_L1_TIMER_63US        7
+#define L1C_PMCTRL_L1_TIMER_MASK        SHIFT16(0xFUL)
+#define L1C_PMCTRL_L1_TIMER_SHIFT       16
+#define L1C_PMCTRL_L1_TIMER_L2CB1       7
+#define L1C_PMCTRL_L1_TIMER_DEF         0xF
+#define L1C_PMCTRL_RCVR_WT_1US          BIT_15  /* 1:1us, 0:2ms */
+#define L1C_PMCTRL_PWM_VER_11           BIT_14  /* 0:1.0a,1:1.1 */
+#define L1C_PMCTRL_L1_CLKSW_EN          BIT_13  /* en pcie clk sw in L1 */
+#define L1C_PMCTRL_L0S_EN               BIT_12
+#define L1D_PMCTRL_RXL1_AFTER_L0S       BIT_11  /* l1dv2.0+ */
+#define L1D_PMCTRL_L0S_TIMER_MASK       SHIFT8(7UL)
+#define L1D_PMCTRL_L0S_TIMER_SHIFT      8
+#define L1C_PMCTRL_L0S_TIMER_MASK       SHIFT8(0xFUL)
+#define L1C_PMCTRL_L0S_TIMER_SHIFT      8
+#define L1C_PMCTRL_L1_BUFSRX_EN         BIT_7
+#define L1C_PMCTRL_L1_SRDSRX_PWD        BIT_6   /* power down serdes rx */
+#define L1C_PMCTRL_L1_SRDSPLL_EN        BIT_5
+#define L1C_PMCTRL_L1_SRDS_EN           BIT_4
+#define L1C_PMCTRL_L1_EN                BIT_3
+#define L1C_PMCTRL_CLKREQ_EN            BIT_2
+#define L1C_PMCTRL_RBER_EN              BIT_1
+#define L1C_PMCTRL_SPRSDWER_EN          BIT_0
+
+#define L1C_LTSSM_CTRL                  0x12FC
+#define L1C_LTSSM_WRO_EN                BIT_12
+#define L1C_LTSSM_TXTLP_BYPASS          BIT_7
+
+#define L1C_MASTER                      0x1400
+#define L1C_MASTER_OTP_FLG              BIT_31
+#define L1C_MASTER_DEV_NUM_MASK         SHIFT24(0x7FUL)
+#define L1C_MASTER_DEV_NUM_SHIFT        24
+#define L1C_MASTER_REV_NUM_MASK         SHIFT16(0xFFUL)
+#define L1C_MASTER_REV_NUM_SHIFT        16
+#define L1C_MASTER_RDCLR_INT            BIT_14
+#define L1C_MASTER_CLKSW_L2EV1          BIT_13      /* 0:l2ev2.0,1:l2ev1.0 */
+#define L1C_MASTER_PCLKSEL_SRDS         BIT_12      /* 1:alwys sel pclk from
+						     * serdes, not sw to 25M */
+#define L1C_MASTER_IRQMOD2_EN           BIT_11      /* IRQ MODURATION FOR RX */
+#define L1C_MASTER_IRQMOD1_EN           BIT_10      /* MODURATION FOR TX/RX */
+#define L1C_MASTER_MANU_INT             BIT_9       /* SOFT MANUAL INT */
+#define L1C_MASTER_MANUTIMER_EN         BIT_8
+#define L1C_MASTER_SYSALVTIMER_EN       BIT_7       /* SYS ALIVE TIMER EN */
+#define L1C_MASTER_OOB_DIS              BIT_6       /* OUT OF BOX DIS */
+#define L1C_MASTER_WAKEN_25M            BIT_5       /* WAKE WO. PCIE CLK */
+#define L1C_MASTER_BERT_START           BIT_4
+#define L1C_MASTER_PCIE_TSTMOD_MASK     SHIFT2(3UL)
+#define L1C_MASTER_PCIE_TSTMOD_SHIFT    2
+#define L1C_MASTER_PCIE_RST             BIT_1
+#define L1C_MASTER_DMA_MAC_RST          BIT_0       /* RST MAC & DMA */
+#define L1C_DMA_MAC_RST_TO              50
+
+#define L1C_MANU_TIMER                  0x1404
+
+#define L1C_IRQ_MODU_TIMER              0x1408
+#define L1C_IRQ_MODU_TIMER2_MASK        SHIFT16(0xFFFFUL)
+#define L1C_IRQ_MODU_TIMER2_SHIFT       16          /* ONLY FOR RX */
+#define L1C_IRQ_MODU_TIMER1_MASK        SHIFT0(0xFFFFUL)
+#define L1C_IRQ_MODU_TIMER1_SHIFT       0
+
+#define L1C_PHY_CTRL                    0x140C
+#define L1C_PHY_CTRL_ADDR_MASK          SHIFT19(0x1FUL)
+#define L1C_PHY_CTRL_ADDR_SHIFT         19
+#define L1C_PHY_CTRL_BP_VLTGSW          BIT_18
+#define L1C_PHY_CTRL_100AB_EN           BIT_17
+#define L1C_PHY_CTRL_10AB_EN            BIT_16
+#define L1C_PHY_CTRL_PLL_BYPASS         BIT_15
+#define L1C_PHY_CTRL_POWER_DOWN         BIT_14      /* affect MAC & PHY,
+						     * go to low power sts */
+#define L1C_PHY_CTRL_PLL_ON             BIT_13      /* 1:PLL ALWAYS ON
+						     * 0:CAN SWITCH IN LPW */
+#define L1C_PHY_CTRL_RST_ANALOG         BIT_12
+#define L1C_PHY_CTRL_HIB_PULSE          BIT_11
+#define L1C_PHY_CTRL_HIB_EN             BIT_10
+#define L1C_PHY_CTRL_GIGA_DIS           BIT_9
+#define L1C_PHY_CTRL_IDDQ_DIS           BIT_8       /* POWER ON RST */
+#define L1C_PHY_CTRL_IDDQ               BIT_7       /* WHILE REBOOT, BIT8(1)
+						     * EFFECTS BIT7 */
+#define L1C_PHY_CTRL_LPW_EXIT           BIT_6
+#define L1C_PHY_CTRL_GATE_25M           BIT_5
+#define L1C_PHY_CTRL_RVRS_ANEG          BIT_4
+#define L1C_PHY_CTRL_ANEG_NOW           BIT_3
+#define L1C_PHY_CTRL_LED_MODE           BIT_2
+#define L1C_PHY_CTRL_RTL_MODE           BIT_1
+#define L1C_PHY_CTRL_DSPRST_OUT         BIT_0       /* OUT OF DSP RST STATE */
+#define L1C_PHY_CTRL_DSPRST_TO          80
+#define L1C_PHY_CTRL_CLS                (\
+	L1C_PHY_CTRL_LED_MODE           |\
+	L1C_PHY_CTRL_100AB_EN           |\
+	L1C_PHY_CTRL_PLL_ON)
+
+
+#define L1C_MAC_STS                     0x1410
+#define L1C_MAC_STS_SFORCE_MASK         SHIFT14(0xFUL)
+#define L1C_MAC_STS_SFORCE_SHIFT        14
+#define L1C_MAC_STS_CALIB_DONE          BIT13
+#define L1C_MAC_STS_CALIB_RES_MASK      SHIFT8(0x1FUL)
+#define L1C_MAC_STS_CALIB_RES_SHIFT     8
+#define L1C_MAC_STS_CALIBERR_MASK       SHIFT4(0xFUL)
+#define L1C_MAC_STS_CALIBERR_SHIFT      4
+#define L1C_MAC_STS_TXQ_BUSY            BIT_3
+#define L1C_MAC_STS_RXQ_BUSY            BIT_2
+#define L1C_MAC_STS_TXMAC_BUSY          BIT_1
+#define L1C_MAC_STS_RXMAC_BUSY          BIT_0
+#define L1C_MAC_STS_IDLE                (\
+	L1C_MAC_STS_TXQ_BUSY            |\
+	L1C_MAC_STS_RXQ_BUSY            |\
+	L1C_MAC_STS_TXMAC_BUSY          |\
+	L1C_MAC_STS_RXMAC_BUSY)
+
+#define L1C_MDIO                        0x1414
+#define L1C_MDIO_MODE_EXT               BIT_30      /* 0:normal,1:ext */
+#define L1C_MDIO_POST_READ              BIT_29
+#define L1C_MDIO_AUTO_POLLING           BIT_28
+#define L1C_MDIO_BUSY                   BIT_27
+#define L1C_MDIO_CLK_SEL_MASK           SHIFT27(7UL)
+#define L1C_MDIO_CLK_SEL_SHIFT          24
+#define L1C_MDIO_CLK_SEL_25MD4          0           /* 25M DIV 4 */
+#define L1C_MDIO_CLK_SEL_25MD6          2
+#define L1C_MDIO_CLK_SEL_25MD8          3
+#define L1C_MDIO_CLK_SEL_25MD10         4
+#define L1C_MDIO_CLK_SEL_25MD32         5
+#define L1C_MDIO_CLK_SEL_25MD64         6
+#define L1C_MDIO_CLK_SEL_25MD128        7
+#define L1C_MDIO_START                  BIT_23
+#define L1C_MDIO_SPRES_PRMBL            BIT_22
+#define L1C_MDIO_OP_READ                BIT_21      /* 1:read,0:write */
+#define L1C_MDIO_REG_MASK               SHIFT16(0x1FUL)
+#define L1C_MDIO_REG_SHIFT              16
+#define L1C_MDIO_DATA_MASK              SHIFT0(0xFFFFUL)
+#define L1C_MDIO_DATA_SHIFT             0
+#define L1C_MDIO_MAX_AC_TO              60
+
+#define L1C_MDIO_EXTN                   0x1448
+#define L1C_MDIO_EXTN_PORTAD_MASK       SHIFT21(0x1FUL)
+#define L1C_MDIO_EXTN_PORTAD_SHIFT      21
+#define L1C_MDIO_EXTN_DEVAD_MASK        SHIFT16(0x1FUL)
+#define L1C_MDIO_EXTN_DEVAD_SHIFT       16
+#define L1C_MDIO_EXTN_REG_MASK          SHIFT0(0xFFFFUL)
+#define L1C_MDIO_EXTN_REG_SHIFT         0
+
+#define L1C_PHY_STS                     0x1418
+#define L1C_PHY_STS_LPW                 BIT_31
+#define L1C_PHY_STS_LPI                 BIT_30
+#define L1C_PHY_STS_PWON_STRIP_MASK     SHIFT16(0xFFFUL)
+#define L1C_PHY_STS_PWON_STRIP_SHIFT    16
+
+#define L1C_PHY_STS_DUPLEX              BIT_3
+#define L1C_PHY_STS_LINKUP              BIT_2
+#define L1C_PHY_STS_SPEED_MASK          SHIFT0(3UL)
+#define L1C_PHY_STS_SPEED_SHIFT         0
+#define L1C_PHY_STS_SPEED_SHIFT         0
+#define L1C_PHY_STS_SPEED_1000M         2
+#define L1C_PHY_STS_SPEED_100M          1
+#define L1C_PHY_STS_SPEED_10M           0
+
+#define L1C_BIST0                       0x141C
+#define L1C_BIST0_COL_MASK              SHIFT24(0x3FUL)
+#define L1C_BIST0_COL_SHIFT             24
+#define L1C_BIST0_ROW_MASK              SHIFT12(0xFFFUL)
+#define L1C_BIST0_ROW_SHIFT             12
+#define L1C_BIST0_STEP_MASK             SHIFT8(0xFUL)
+#define L1C_BIST0_STEP_SHIFT            8
+#define L1C_BIST0_PATTERN_MASK          SHIFT4(7UL)
+#define L1C_BIST0_PATTERN_SHIFT         4
+#define L1C_BIST0_CRIT                  BIT_3
+#define L1C_BIST0_FIXED                 BIT_2
+#define L1C_BIST0_FAIL                  BIT_1
+#define L1C_BIST0_START                 BIT_0
+
+#define L1C_BIST1                       0x1420
+#define L1C_BIST1_COL_MASK              SHIFT24(0x3FUL)
+#define L1C_BIST1_COL_SHIFT             24
+#define L1C_BIST1_ROW_MASK              SHIFT12(0xFFFUL)
+#define L1C_BIST1_ROW_SHIFT             12
+#define L1C_BIST1_STEP_MASK             SHIFT8(0xFUL)
+#define L1C_BIST1_STEP_SHIFT            8
+#define L1C_BIST1_PATTERN_MASK          SHIFT4(7UL)
+#define L1C_BIST1_PATTERN_SHIFT         4
+#define L1C_BIST1_CRIT                  BIT_3
+#define L1C_BIST1_FIXED                 BIT_2
+#define L1C_BIST1_FAIL                  BIT_1
+#define L1C_BIST1_START                 BIT_0
+
+#define L1C_SERDES                      0x1424
+#define L1C_SERDES_PHYCLK_SLWDWN        BIT_18
+#define L1C_SERDES_MACCLK_SLWDWN        BIT_17
+#define L1C_SERDES_SELFB_PLL_MASK       SHIFT14(3UL)
+#define L1C_SERDES_SELFB_PLL_SHIFT      14
+#define L1C_SERDES_PHYCLK_SEL_GTX       BIT_13          /* 1:gtx_clk, 0:25M */
+#define L1C_SERDES_PCIECLK_SEL_SRDS     BIT_12          /* 1:serdes,0:25M */
+#define L1C_SERDES_BUFS_RX_EN           BIT_11
+#define L1C_SERDES_PD_RX                BIT_10
+#define L1C_SERDES_PLL_EN               BIT_9
+#define L1C_SERDES_EN                   BIT_8
+#define L1C_SERDES_SELFB_PLL_SEL_CSR    BIT_6       /* 0:state-machine,1:csr */
+#define L1C_SERDES_SELFB_PLL_CSR_MASK   SHIFT4(3UL)
+#define L1C_SERDES_SELFB_PLL_CSR_SHIFT  4
+#define L1C_SERDES_SELFB_PLL_CSR_4      3           /* 4-12% OV-CLK */
+#define L1C_SERDES_SELFB_PLL_CSR_0      2           /* 0-4% OV-CLK */
+#define L1C_SERDES_SELFB_PLL_CSR_12     1           /* 12-18% OV-CLK */
+#define L1C_SERDES_SELFB_PLL_CSR_18     0           /* 18-25% OV-CLK */
+#define L1C_SERDES_VCO_SLOW             BIT_3
+#define L1C_SERDES_VCO_FAST             BIT_2
+#define L1C_SERDES_LOCKDCT_EN           BIT_1
+#define L1C_SERDES_LOCKDCTED            BIT_0
+
+#define L1C_LED_CTRL                    0x1428
+#define L1C_LED_CTRL_PATMAP2_MASK       SHIFT8(3UL)
+#define L1C_LED_CTRL_PATMAP2_SHIFT      8
+#define L1C_LED_CTRL_PATMAP1_MASK       SHIFT6(3UL)
+#define L1C_LED_CTRL_PATMAP1_SHIFT      6
+#define L1C_LED_CTRL_PATMAP0_MASK       SHIFT4(3UL)
+#define L1C_LED_CTRL_PATMAP0_SHIFT      4
+#define L1C_LED_CTRL_D3_MODE_MASK       SHIFT2(3UL)
+#define L1C_LED_CTRL_D3_MODE_SHIFT      2
+#define L1C_LED_CTRL_D3_MODE_NORMAL     0
+#define L1C_LED_CTRL_D3_MODE_WOL_DIS    1
+#define L1C_LED_CTRL_D3_MODE_WOL_ANY    2
+#define L1C_LED_CTRL_D3_MODE_WOL_EN     3
+#define L1C_LED_CTRL_DUTY_CYCL_MASK     SHIFT0(3UL)
+#define L1C_LED_CTRL_DUTY_CYCL_SHIFT    0
+#define L1C_LED_CTRL_DUTY_CYCL_50       0           /* 50% */
+#define L1C_LED_CTRL_DUTY_CYCL_125      1           /* 12.5% */
+#define L1C_LED_CTRL_DUTY_CYCL_25       2           /* 25% */
+#define L1C_LED_CTRL_DUTY_CYCL_75       3           /* 75% */
+
+#define L1C_LED_PATN                    0x142C
+#define L1C_LED_PATN1_MASK              SHIFT16(0xFFFFUL)
+#define L1C_LED_PATN1_SHIFT             16
+#define L1C_LED_PATN0_MASK              SHIFT0(0xFFFFUL)
+#define L1C_LED_PATN0_SHIFT             0
+
+#define L1C_LED_PATN2                   0x1430
+#define L1C_LED_PATN2_MASK              SHIFT0(0xFFFFUL)
+#define L1C_LED_PATN2_SHIFT             0
+
+#define L1C_SYSALV                      0x1434
+#define L1C_SYSALV_FLAG                 BIT_0
+
+#define L1C_PCIERR_INST                 0x1438
+#define L1C_PCIERR_INST_TX_RATE_MASK    SHIFT4(0xFUL)
+#define L1C_PCIERR_INST_TX_RATE_SHIFT   4
+#define L1C_PCIERR_INST_RX_RATE_MASK    SHIFT0(0xFUL)
+#define L1C_PCIERR_INST_RX_RATE_SHIFT   0
+
+#define L1C_LPI_DECISN_TIMER            0x143C
+#define L1C_LPI_DESISN_TIMER_L2CB       0x7D00
+
+#define L1C_LPI_CTRL                    0x1440
+#define L1C_LPI_CTRL_CHK_DA             BIT_31
+#define L1C_LPI_CTRL_ENH_TO_MASK        SHIFT12(0x1FFFUL)
+#define L1C_LPI_CTRL_ENH_TO_SHIFT       12
+#define L1C_LPI_CTRL_ENH_TH_MASK        SHIFT6(0x1FUL)
+#define L1C_LPI_CTRL_ENH_TH_SHIFT       6
+#define L1C_LPI_CTRL_ENH_EN             BIT_5
+#define L1C_LPI_CTRL_CHK_RX             BIT_4
+#define L1C_LPI_CTRL_CHK_STATE          BIT_3
+#define L1C_LPI_CTRL_GMII               BIT_2
+#define L1C_LPI_CTRL_TO_PHY             BIT_1
+#define L1C_LPI_CTRL_EN                 BIT_0
+
+#define L1C_LPI_WAIT                    0x1444
+#define L1C_LPI_WAIT_TIMER_MASK         SHIFT0(0xFFFFUL)
+#define L1C_LPI_WAIT_TIMER_SHIFT        0
+
+#define L1C_MAC_CTRL                    0x1480
+#define L1C_MAC_CTRL_WOLSPED_SWEN       BIT_30  /* 0:phy,1:sw */
+#define L1C_MAC_CTRL_MHASH_ALG_HI5B     BIT_29  /* 1:legacy, 0:marvl(low5b)*/
+#define L1C_MAC_CTRL_SPAUSE_EN          BIT_28
+#define L1C_MAC_CTRL_DBG_EN             BIT_27
+#define L1C_MAC_CTRL_BRD_EN             BIT_26
+#define L1C_MAC_CTRL_MULTIALL_EN        BIT_25
+#define L1C_MAC_CTRL_RX_XSUM_EN         BIT_24
+#define L1C_MAC_CTRL_THUGE              BIT_23
+#define L1C_MAC_CTRL_MBOF               BIT_22
+#define L1C_MAC_CTRL_SPEED_MASK         SHIFT20(3UL)
+#define L1C_MAC_CTRL_SPEED_SHIFT        20
+#define L1C_MAC_CTRL_SPEED_10_100       1
+#define L1C_MAC_CTRL_SPEED_1000         2
+#define L1C_MAC_CTRL_SIMR               BIT_19
+#define L1C_MAC_CTRL_SSTCT              BIT_17
+#define L1C_MAC_CTRL_TPAUSE             BIT_16
+#define L1C_MAC_CTRL_PROMISC_EN         BIT_15
+#define L1C_MAC_CTRL_VLANSTRIP          BIT_14
+#define L1C_MAC_CTRL_PRMBLEN_MASK       SHIFT10(0xFUL)
+#define L1C_MAC_CTRL_PRMBLEN_SHIFT      10
+#define L1C_MAC_CTRL_RHUGE_EN           BIT_9
+#define L1C_MAC_CTRL_FLCHK              BIT_8
+#define L1C_MAC_CTRL_PCRCE              BIT_7
+#define L1C_MAC_CTRL_CRCE               BIT_6
+#define L1C_MAC_CTRL_FULLD              BIT_5
+#define L1C_MAC_CTRL_LPBACK_EN          BIT_4
+#define L1C_MAC_CTRL_RXFC_EN            BIT_3
+#define L1C_MAC_CTRL_TXFC_EN            BIT_2
+#define L1C_MAC_CTRL_RX_EN              BIT_1
+#define L1C_MAC_CTRL_TX_EN              BIT_0
+
+#define L1C_GAP                         0x1484
+#define L1C_GAP_IPGR2_MASK              SHIFT24(0x7FUL)
+#define L1C_GAP_IPGR2_SHIFT             24
+#define L1C_GAP_IPGR1_MASK              SHIFT16(0x7FUL)
+#define L1C_GAP_IPGR1_SHIFT             16
+#define L1C_GAP_MIN_IFG_MASK            SHIFT8(0xFFUL)
+#define L1C_GAP_MIN_IFG_SHIFT           8
+#define L1C_GAP_IPGT_MASK               SHIFT0(0x7FUL)
+#define L1C_GAP_IPGT_SHIFT              0
+
+#define L1C_STAD0                       0x1488
+#define L1C_STAD1                       0x148C
+
+#define L1C_HASH_TBL0                   0x1490
+#define L1C_HASH_TBL1                   0x1494
+
+#define L1C_HALFD                       0x1498
+#define L1C_HALFD_JAM_IPG_MASK          SHIFT24(0xFUL)
+#define L1C_HALFD_JAM_IPG_SHIFT         24
+#define L1C_HALFD_ABEBT_MASK            SHIFT20(0xFUL)
+#define L1C_HALFD_ABEBT_SHIFT           20
+#define L1C_HALFD_ABEBE                 BIT_19
+#define L1C_HALFD_BPNB                  BIT_18
+#define L1C_HALFD_NOBO                  BIT_17
+#define L1C_HALFD_EDXSDFR               BIT_16
+#define L1C_HALFD_RETRY_MASK            SHIFT12(0xFUL)
+#define L1C_HALFD_RETRY_SHIFT           12
+#define L1C_HALFD_LCOL_MASK             SHIFT0(0x3FFUL)
+#define L1C_HALFD_LCOL_SHIFT            0
+
+#define L1C_MTU                         0x149C
+#define L1C_MTU_JUMBO_TH                1514
+#define L1C_MTU_STD_ALGN                1536
+#define L1C_MTU_MIN                     64
+
+#define L1C_WOL0                        0x14A0
+#define L1C_WOL0_PT7_MATCH              BIT_31
+#define L1C_WOL0_PT6_MATCH              BIT_30
+#define L1C_WOL0_PT5_MATCH              BIT_29
+#define L1C_WOL0_PT4_MATCH              BIT_28
+#define L1C_WOL0_PT3_MATCH              BIT_27
+#define L1C_WOL0_PT2_MATCH              BIT_26
+#define L1C_WOL0_PT1_MATCH              BIT_25
+#define L1C_WOL0_PT0_MATCH              BIT_24
+#define L1C_WOL0_PT7_EN                 BIT_23
+#define L1C_WOL0_PT6_EN                 BIT_22
+#define L1C_WOL0_PT5_EN                 BIT_21
+#define L1C_WOL0_PT4_EN                 BIT_20
+#define L1C_WOL0_PT3_EN                 BIT_19
+#define L1C_WOL0_PT2_EN                 BIT_18
+#define L1C_WOL0_PT1_EN                 BIT_17
+#define L1C_WOL0_PT0_EN                 BIT_16
+#define L1C_WOL0_IPV4_SYNC_EVT          BIT_14
+#define L1C_WOL0_IPV6_SYNC_EVT          BIT_13
+#define L1C_WOL0_LINK_EVT               BIT_10
+#define L1C_WOL0_MAGIC_EVT              BIT_9
+#define L1C_WOL0_PATTERN_EVT            BIT_8
+#define L1D_WOL0_OOB_EN                 BIT_6
+#define L1C_WOL0_PME_LINK               BIT_5
+#define L1C_WOL0_LINK_EN                BIT_4
+#define L1C_WOL0_PME_MAGIC_EN           BIT_3
+#define L1C_WOL0_MAGIC_EN               BIT_2
+#define L1C_WOL0_PME_PATTERN_EN         BIT_1
+#define L1C_WOL0_PATTERN_EN             BIT_0
+
+#define L1C_WOL1                        0x14A4
+#define L1C_WOL1_PT3_LEN_MASK           SHIFT24(0xFFUL)
+#define L1C_WOL1_PT3_LEN_SHIFT          24
+#define L1C_WOL1_PT2_LEN_MASK           SHIFT16(0xFFUL)
+#define L1C_WOL1_PT2_LEN_SHIFT          16
+#define L1C_WOL1_PT1_LEN_MASK           SHIFT8(0xFFUL)
+#define L1C_WOL1_PT1_LEN_SHIFT          8
+#define L1C_WOL1_PT0_LEN_MASK           SHIFT0(0xFFUL)
+#define L1C_WOL1_PT0_LEN_SHIFT          0
+
+#define L1C_WOL2                        0x14A8
+#define L1C_WOL2_PT7_LEN_MASK           SHIFT24(0xFFUL)
+#define L1C_WOL2_PT7_LEN_SHIFT          24
+#define L1C_WOL2_PT6_LEN_MASK           SHIFT16(0xFFUL)
+#define L1C_WOL2_PT6_LEN_SHIFT          16
+#define L1C_WOL2_PT5_LEN_MASK           SHIFT8(0xFFUL)
+#define L1C_WOL2_PT5_LEN_SHIFT          8
+#define L1C_WOL2_PT4_LEN_MASK           SHIFT0(0xFFUL)
+#define L1C_WOL2_PT4_LEN_SHIFT          0
+
+#define L1C_SRAM0                       0x1500
+#define L1C_SRAM_RFD_TAIL_ADDR_MASK     SHIFT16(0xFFFUL)
+#define L1C_SRAM_RFD_TAIL_ADDR_SHIFT    16
+#define L1C_SRAM_RFD_HEAD_ADDR_MASK     SHIFT0(0xFFFUL)
+#define L1C_SRAM_RFD_HEAD_ADDR_SHIFT    0
+#define L1C_SRAM_RFD_HT_L2CB1           0x02bf02a0L
+
+#define L1C_SRAM1                       0x1510
+#define L1C_SRAM_RFD_LEN_MASK           SHIFT0(0xFFFUL) /* 8BYTES UNIT */
+#define L1C_SRAM_RFD_LEN_SHIFT          0
+
+#define L1C_SRAM2                       0x1518
+#define L1C_SRAM_TRD_TAIL_ADDR_MASK     SHIFT16(0xFFFUL)
+#define L1C_SRAM_TRD_TAIL_ADDR_SHIFT    16
+#define L1C_SRMA_TRD_HEAD_ADDR_MASK     SHIFT0(0xFFFUL)
+#define L1C_SRAM_TRD_HEAD_ADDR_SHIFT    0
+#define L1C_SRAM_TRD_HT_L2CB1           0x03df03c0L
+
+#define L1C_SRAM3                       0x151C
+#define L1C_SRAM_TRD_LEN_MASK           SHIFT0(0xFFFUL) /* 8BYTES UNIT */
+#define L1C_SRAM_TRD_LEN_SHIFT          0
+
+#define L1C_SRAM4                       0x1520
+#define L1C_SRAM_RXF_TAIL_ADDR_MASK     SHIFT16(0xFFFUL)
+#define L1C_SRAM_RXF_TAIL_ADDR_SHIFT    16
+#define L1C_SRAM_RXF_HEAD_ADDR_MASK     SHIFT0(0xFFFUL)
+#define L1C_SRAM_RXF_HEAD_ADDR_SHIFT    0
+#define L1C_SRAM_RXF_HT_L2CB1           0x029f0000L
+
+#define L1C_SRAM5                       0x1524
+#define L1C_SRAM_RXF_LEN_MASK           SHIFT0(0xFFFUL) /* 8BYTES UNIT */
+#define L1C_SRAM_RXF_LEN_SHIFT          0
+#define L1C_SRAM_RXF_LEN_8K             (8*1024)
+#define L1C_SRAM_RXF_LEN_L2CB1          0x02a0L
+
+#define L1C_SRAM6                       0x1528
+#define L1C_SRAM_TXF_TAIL_ADDR_MASK     SHIFT16(0xFFFUL)
+#define L1C_SRAM_TXF_TAIL_ADDR_SHIFT    16
+#define L1C_SRAM_TXF_HEAD_ADDR_MASK     SHIFT0(0xFFFUL)
+#define L1C_SRAM_TXF_HEAD_ADDR_SHIFT    0
+#define L1C_SRAM_TXF_HT_L2CB1           0x03bf02c0L
+
+#define L1C_SRAM7                       0x152C
+#define L1C_SRAM_TXF_LEN_MASK           SHIFT0(0xFFFUL) /* 8BYTES UNIT */
+#define L1C_SRAM_TXF_LEN_SHIFT          0
+#define L1C_SRAM_TXF_LEN_L2CB1          0x0100L
+
+#define L1C_SRAM8                       0x1530
+#define L1C_SRAM_PATTERN_ADDR_MASK      SHIFT16(0xFFFUL)
+#define L1C_SRAM_PATTERN_ADDR_SHIFT     16
+#define L1C_SRAM_TSO_ADDR_MASK          SHIFT0(0xFFFUL)
+#define L1C_SRAM_TSO_ADDR_SHIFT         0
+
+#define L1C_SRAM9                       0x1534
+#define L1C_SRAM_LOAD_PTR               BIT_0
+
+#define L1C_RX_BASE_ADDR_HI             0x1540
+
+#define L1C_TX_BASE_ADDR_HI             0x1544
+
+#define L1C_RFD_ADDR_LO                 0x1550
+#define L1C_RFD_RING_SZ                 0x1560
+#define L1C_RFD_BUF_SZ                  0x1564
+#define L1C_RFD_BUF_SZ_MASK             SHIFT0(0xFFFFUL)
+#define L1C_RFD_BUF_SZ_SHIFT            0
+
+#define L1C_RRD_ADDR_LO                 0x1568
+#define L1C_RRD_RING_SZ                 0x1578
+#define L1C_RRD_RING_SZ_MASK            SHIFT0(0xFFFUL)
+#define L1C_RRD_RING_SZ_SHIFT           0
+
+#define L1C_TPD_PRI1_ADDR_LO            0x157C
+#define L1C_TPD_PRI0_ADDR_LO            0x1580      /* LOWEST PRORITY */
+
+#define L1C_TPD_PRI1_PIDX               0x15F0      /* 16BIT */
+#define L1C_TPD_PRI0_PIDX               0x15F2      /* 16BIT */
+
+#define L1C_TPD_PRI1_CIDX               0x15F4      /* 16BIT */
+#define L1C_TPD_PRI0_CIDX               0x15F6      /* 16BIT */
+
+#define L1C_TPD_RING_SZ                 0x1584
+#define L1C_TPD_RING_SZ_MASK            SHIFT0(0xFFFFUL)
+#define L1C_TPD_RING_SZ_SHIFT           0
+
+#define L1C_TXQ0                        0x1590
+#define L1C_TXQ0_TXF_BURST_PREF_MASK    SHIFT16(0xFFFFUL)
+#define L1C_TXQ0_TXF_BURST_PREF_SHIFT   16
+#define L1C_TXQ0_TXF_BURST_PREF_DEF     0x200
+#define L1C_TXQ0_TXF_BURST_PREF_L2CB    0x40
+#define L1D_TXQ0_PEDING_CLR             BIT_8
+#define L1C_TXQ0_LSO_8023_EN            BIT_7
+#define L1C_TXQ0_MODE_ENHANCE           BIT_6
+#define L1C_TXQ0_EN                     BIT_5
+#define L1C_TXQ0_SUPT_IPOPT             BIT_4
+#define L1C_TXQ0_TPD_BURSTPREF_MASK     SHIFT0(0xFUL)
+#define L1C_TXQ0_TPD_BURSTPREF_SHIFT    0
+#define L1C_TXQ0_TPD_BURSTPREF_DEF      5
+
+#define L1C_TXQ1                        0x1594
+#define L1C_TXQ1_JUMBO_TSOTHR_MASK      SHIFT0(0x7FFUL) /* 8BYTES UNIT */
+#define L1C_TXQ1_JUMBO_TSOTHR_SHIFT     0
+#define L1C_TXQ1_JUMBO_TSO_TH           (7*1024)    /* byte */
+
+#define L1C_TXQ2                        0x1598          /* ENTER L1 CONTROL */
+#define L1C_TXQ2_BURST_EN               BIT_31
+#define L1C_TXQ2_BURST_HI_WM_MASK       SHIFT16(0xFFFUL)
+#define L1C_TXQ2_BURST_HI_WM_SHIFT      16
+#define L1C_TXQ2_BURST_LO_WM_MASK       SHIFT0(0xFFFUL)
+#define L1C_TXQ2_BURST_LO_WM_SHIFT      0
+
+#define L1C_RFD_PIDX                    0x15E0
+#define L1C_RFD_PIDX_MASK               SHIFT0(0xFFFUL)
+#define L1C_RFD_PIDX_SHIFT              0
+
+#define L1C_RFD_CIDX                    0x15F8
+#define L1C_RFD_CIDX_MASK               SHIFT0(0xFFFUL)
+#define L1C_RFD_CIDX_SHIFT              0
+
+#define L1C_RXQ0                        0x15A0
+#define L1C_RXQ0_EN                     BIT_31
+#define L1C_RXQ0_CUT_THRU_EN            BIT_30
+#define L1C_RXQ0_RSS_HASH_EN            BIT_29
+#define L1C_RXQ0_NON_IP_QTBL            BIT_28  /* 0:q0,1:table */
+#define L1C_RXQ0_RSS_MODE_MASK          SHIFT26(3UL)
+#define L1C_RXQ0_RSS_MODE_SHIFT         26
+#define L1C_RXQ0_RSS_MODE_DIS           0
+#define L1C_RXQ0_RSS_MODE_SQSI          1
+#define L1C_RXQ0_RSS_MODE_MQSI          2
+#define L1C_RXQ0_RSS_MODE_MQMI          3
+#define L1C_RXQ0_NUM_RFD_PREF_MASK      SHIFT20(0x3FUL)
+#define L1C_RXQ0_NUM_RFD_PREF_SHIFT     20
+#define L1C_RXQ0_NUM_RFD_PREF_DEF       8
+#define L1C_RXQ0_RSS_HSTYP_IPV6_TCP_EN  BIT_19
+#define L1C_RXQ0_RSS_HSTYP_IPV6_EN      BIT_18
+#define L1C_RXQ0_RSS_HSTYP_IPV4_TCP_EN  BIT_17
+#define L1C_RXQ0_RSS_HSTYP_IPV4_EN      BIT_16
+#define L1C_RXQ0_RSS_HSTYP_ALL          (\
+	L1C_RXQ0_RSS_HSTYP_IPV6_TCP_EN  |\
+	L1C_RXQ0_RSS_HSTYP_IPV4_TCP_EN  |\
+	L1C_RXQ0_RSS_HSTYP_IPV6_EN      |\
+	L1C_RXQ0_RSS_HSTYP_IPV4_EN)
+#define L1C_RXQ0_IDT_TBL_SIZE_MASK      SHIFT8(0xFFUL)
+#define L1C_RXQ0_IDT_TBL_SIZE_SHIFT     8
+#define L1C_RXQ0_IDT_TBL_SIZE_DEF       0x80
+#define L1C_RXQ0_IPV6_PARSE_EN          BIT_7
+#define L1C_RXQ0_ASPM_THRESH_MASK       SHIFT0(3UL)
+#define L1C_RXQ0_ASPM_THRESH_SHIFT      0
+#define L1C_RXQ0_ASPM_THRESH_NO         0
+#define L1C_RXQ0_ASPM_THRESH_1M         1
+#define L1C_RXQ0_ASPM_THRESH_10M        2
+#define L1C_RXQ0_ASPM_THRESH_100M       3
+
+#define L1C_RXQ1                        0x15A4
+#define L1C_RXQ1_RFD_PREF_DOWN_MASK     SHIFT6(0x3FUL)
+#define L1C_RXQ1_RFD_PREF_DOWN_SHIFT    6
+#define L1C_RXQ1_RFD_PREF_UP_MASK       SHIFT0(0x3FUL)
+#define L1C_RXQ1_RFD_PREF_UP_SHIFT      0
+
+#define L1C_RXQ2                        0x15A8
+/* XOFF: USED SRAM LOWER THAN IT, THEN NOTIFY THE PEER TO SEND AGAIN */
+#define L1C_RXQ2_RXF_XOFF_THRESH_MASK   SHIFT16(0xFFFUL)
+#define L1C_RXQ2_RXF_XOFF_THRESH_SHIFT  16
+#define L1C_RXQ2_RXF_XON_THRESH_MASK    SHIFT0(0xFFFUL)
+#define L1C_RXQ2_RXF_XON_THRESH_SHIFT   0
+
+#define L1C_RXQ3                        0x15AC
+#define L1C_RXQ3_RXD_TIMER_MASK         SHIFT16(0xFFFFUL)
+#define L1C_RXQ3_RXD_TIMER_SHIFT        16
+#define L1C_RXQ3_RXD_THRESH_MASK        SHIFT0(0xFFFUL) /* 8BYTES UNIT */
+#define L1C_RXQ3_RXD_THRESH_SHIFT       0
+
+#define L1C_DMA                         0x15C0
+#define L1C_DMA_WPEND_CLR               BIT_30
+#define L1C_DMA_RPEND_CLR               BIT_29
+#define L1C_DMA_WDLY_CNT_MASK           SHIFT16(0xFUL)
+#define L1C_DMA_WDLY_CNT_SHIFT          16
+#define L1C_DMA_WDLY_CNT_DEF            4
+#define L1C_DMA_RDLY_CNT_MASK           SHIFT11(0x1FUL)
+#define L1C_DMA_RDLY_CNT_SHIFT          11
+#define L1C_DMA_RDLY_CNT_DEF            15
+#define L1C_DMA_RREQ_PRI_DATA           BIT_10      /* 0:tpd, 1:data */
+#define L1C_DMA_WREQ_BLEN_MASK          SHIFT7(7UL)
+#define L1C_DMA_WREQ_BLEN_SHIFT         7
+#define L1C_DMA_RREQ_BLEN_MASK          SHIFT4(7UL)
+#define L1C_DMA_RREQ_BLEN_SHIFT         4
+#define L1C_DMA_RCB_LEN128              BIT_3   /* 0:64bytes,1:128bytes */
+#define L1C_DMA_RORDER_MODE_MASK        SHIFT0(7UL)
+#define L1C_DMA_RORDER_MODE_SHIFT       0
+#define L1C_DMA_RORDER_MODE_OUT         4
+#define L1C_DMA_RORDER_MODE_ENHANCE     2
+#define L1C_DMA_RORDER_MODE_IN          1
+
+#define L1C_SMB_TIMER                   0x15C4
+
+#define L1C_TINT_TPD_THRSHLD            0x15C8
+
+#define L1C_TINT_TIMER                  0x15CC
+
+#define L1C_ISR                         0x1600
+#define L1C_ISR_DIS                     BIT_31
+#define L1C_ISR_PCIE_LNKDOWN            BIT_26
+#define L1C_ISR_PCIE_CERR               BIT_25
+#define L1C_ISR_PCIE_NFERR              BIT_24
+#define L1C_ISR_PCIE_FERR               BIT_23
+#define L1C_ISR_PCIE_UR                 BIT_22
+#define L1C_ISR_MAC_TX                  BIT_21
+#define L1C_ISR_MAC_RX                  BIT_20
+#define L1C_ISR_RX_Q0                   BIT_16
+#define L1C_ISR_TX_Q0                   BIT_15
+#define L1C_ISR_TXQ_TO                  BIT_14
+#define L1C_ISR_PHY_LPW                 BIT_13
+#define L1C_ISR_PHY                     BIT_12
+#define L1C_ISR_TX_CREDIT               BIT_11
+#define L1C_ISR_DMAW                    BIT_10
+#define L1C_ISR_DMAR                    BIT_9
+#define L1C_ISR_TXF_UR                  BIT_8
+#define L1C_ISR_RFD_UR                  BIT_4
+#define L1C_ISR_RXF_OV                  BIT_3
+#define L1C_ISR_MANU                    BIT_2
+#define L1C_ISR_TIMER                   BIT_1
+#define L1C_ISR_SMB                     BIT_0
+
+#define L1C_IMR                         0x1604
+
+#define L1C_INT_RETRIG                  0x1608  /* re-send deassrt/assert
+						 * if sw no reflect */
+#define L1C_INT_RETRIG_TO               20000   /* 40 ms */
+
+/* WOL mask register only for L1Dv2.0 and later chips */
+#define L1D_PATTERN_MASK                0x1620  /* 128bytes, sleep state */
+#define L1D_PATTERN_MASK_LEN            128     /* 128bytes, 32DWORDs */
+
+
+#define L1C_BTROM_CFG                   0x1800  /* pwon rst */
+
+#define L1C_DRV                         0x1804  /* pwon rst */
+/* bit definition is in lx_hwcomm.h */
+
+#define L1C_DRV_ERR1                    0x1808  /* perst */
+#define L1C_DRV_ERR1_GEN                BIT_31  /* geneneral err */
+#define L1C_DRV_ERR1_NOR                BIT_30  /* rrd.nor */
+#define L1C_DRV_ERR1_TRUNC              BIT_29
+#define L1C_DRV_ERR1_RES                BIT_28
+#define L1C_DRV_ERR1_INTFATAL           BIT_27
+#define L1C_DRV_ERR1_TXQPEND            BIT_26
+#define L1C_DRV_ERR1_DMAW               BIT_25
+#define L1C_DRV_ERR1_DMAR               BIT_24
+#define L1C_DRV_ERR1_PCIELNKDWN         BIT_23
+#define L1C_DRV_ERR1_PKTSIZE            BIT_22
+#define L1C_DRV_ERR1_FIFOFUL            BIT_21
+#define L1C_DRV_ERR1_RFDUR              BIT_20
+#define L1C_DRV_ERR1_RRDSI              BIT_19
+#define L1C_DRV_ERR1_UPDATE             BIT_18
+
+#define L1C_DRV_ERR2                    0x180C  /* perst */
+
+#define L1C_CLK_GATE                    0x1814
+#define L1C_CLK_GATE_RXMAC              BIT_5
+#define L1C_CLK_GATE_TXMAC              BIT_4
+#define L1C_CLK_GATE_RXQ                BIT_3
+#define L1C_CLK_GATE_TXQ                BIT_2
+#define L1C_CLK_GATE_DMAR               BIT_1
+#define L1C_CLK_GATE_DMAW               BIT_0
+#define L1C_CLK_GATE_ALL    (\
+	L1C_CLK_GATE_RXMAC  |\
+	L1C_CLK_GATE_TXMAC  |\
+	L1C_CLK_GATE_RXQ    |\
+	L1C_CLK_GATE_TXQ    |\
+	L1C_CLK_GATE_DMAR   |\
+	L1C_CLK_GATE_DMAW)
+
+#define L1C_DBG_ADDR                    0x1900  /* DWORD reg */
+#define L1C_DBG_DATA                    0x1904  /* DWORD reg */
+
+/***************************** IO mapping registers ***************************/
+#define L1C_IO_ADDR                     0x00    /* DWORD reg */
+#define L1C_IO_DATA                     0x04    /* DWORD reg */
+#define L1C_IO_MASTER                   0x08    /* DWORD same as reg0x1400 */
+#define L1C_IO_MAC_CTRL                 0x0C    /* DWORD same as reg0x1480*/
+#define L1C_IO_ISR                      0x10    /* DWORD same as reg0x1600 */
+#define L1C_IO_IMR                      0x14    /* DWORD same as reg0x1604 */
+#define L1C_IO_TPD_PRI1_PIDX            0x18    /* WORD same as reg0x15F0 */
+#define L1C_IO_TPD_PRI0_PIDX            0x1A    /* WORD same as reg0x15F2 */
+#define L1C_IO_TPD_PRI1_CIDX            0x1C    /* WORD same as reg0x15F4 */
+#define L1C_IO_TPD_PRI0_CIDX            0x1E    /* WORD same as reg0x15F6 */
+#define L1C_IO_RFD_PIDX                 0x20    /* WORD same as reg0x15E0 */
+#define L1C_IO_RFD_CIDX                 0x30    /* WORD same as reg0x15F8 */
+#define L1C_IO_MDIO                     0x38    /* WORD same as reg0x1414 */
+#define L1C_IO_PHY_CTRL                 0x3C    /* DWORD same as reg0x140C */
+
+
+
+/********************* PHY regs definition ***************************/
+
+/* PHY Control Register */
+#define L1C_MII_BMCR                        0x00
+#define L1C_BMCR_SPEED_SELECT_MSB           0x0040
+#define L1C_BMCR_COLL_TEST_ENABLE           0x0080
+#define L1C_BMCR_FULL_DUPLEX                0x0100
+#define L1C_BMCR_RESTART_AUTO_NEG           0x0200
+#define L1C_BMCR_ISOLATE                    0x0400
+#define L1C_BMCR_POWER_DOWN                 0x0800
+#define L1C_BMCR_AUTO_NEG_EN                0x1000
+#define L1C_BMCR_SPEED_SELECT_LSB           0x2000
+#define L1C_BMCR_LOOPBACK                   0x4000
+#define L1C_BMCR_RESET                      0x8000
+#define L1C_BMCR_SPEED_MASK                 0x2040
+#define L1C_BMCR_SPEED_1000                 0x0040
+#define L1C_BMCR_SPEED_100                  0x2000
+#define L1C_BMCR_SPEED_10                   0x0000
+
+/* PHY Status Register */
+#define L1C_MII_BMSR                        0x01
+#define L1C_BMSR_EXTENDED_CAPS              0x0001
+#define L1C_BMSR_JABBER_DETECT              0x0002
+#define L1C_BMSR_LINK_STATUS                0x0004
+#define L1C_BMSR_AUTONEG_CAPS               0x0008
+#define L1C_BMSR_REMOTE_FAULT               0x0010
+#define L1C_BMSR_AUTONEG_COMPLETE           0x0020
+#define L1C_BMSR_PREAMBLE_SUPPRESS          0x0040
+#define L1C_BMSR_EXTENDED_STATUS            0x0100
+#define L1C_BMSR_100T2_HD_CAPS              0x0200
+#define L1C_BMSR_100T2_FD_CAPS              0x0400
+#define L1C_BMSR_10T_HD_CAPS                0x0800
+#define L1C_BMSR_10T_FD_CAPS                0x1000
+#define L1C_BMSR_100X_HD_CAPS               0x2000
+#define L1C_BMMII_SR_100X_FD_CAPS           0x4000
+#define L1C_BMMII_SR_100T4_CAPS             0x8000
+
+#define L1C_MII_PHYSID1                     0x02
+#define L1C_MII_PHYSID2                     0x03
+
+
+/* Autoneg Advertisement Register */
+#define L1C_MII_ADVERTISE                   0x04
+#define L1C_ADVERTISE_SELECTOR_FIELD        0x0001
+#define L1C_ADVERTISE_10T_HD_CAPS           0x0020
+#define L1C_ADVERTISE_10T_FD_CAPS           0x0040
+#define L1C_ADVERTISE_100TX_HD_CAPS         0x0080
+#define L1C_ADVERTISE_100TX_FD_CAPS         0x0100
+#define L1C_ADVERTISE_100T4_CAPS            0x0200
+#define L1C_ADVERTISE_PAUSE                 0x0400
+#define L1C_ADVERTISE_ASM_DIR               0x0800
+#define L1C_ADVERTISE_REMOTE_FAULT          0x2000
+#define L1C_ADVERTISE_NEXT_PAGE             0x8000
+#define L1C_ADVERTISE_SPEED_MASK            0x01E0
+#define L1C_ADVERTISE_DEFAULT_CAP           0x1DE0 /* diff with L1C */
+
+/* Link partner ability register */
+#define L1C_MII_LPA                         0x05
+#define L1C_LPA_SLCT_MASK                   0x001F
+#define L1C_LPA_10HALF                      0x0020
+#define L1C_LPA_10FULL                      0x0040
+#define L1C_LPA_100HALF                     0x0080
+#define L1C_LPA_100FULL                     0x0100
+#define L1C_LPA_100BASE4                    0x0200
+#define L1C_LPA_PAUSE                       0x0400
+#define L1C_LPA_ASYPAUSE                    0x0800
+#define L1C_LPA_RFAULT                      0x2000
+#define L1C_LPA_LPACK                       0x4000
+#define L1C_LPA_NPAGE                       0x8000
+
+/* Expansion register          */
+#define L1C_MII_EXPANSION                   0x06
+#define L1C_EXPANSION_NWAY                  0x0001
+#define L1C_EXPANSION_LCWP                  0x0002
+#define L1C_EXPANSION_ENABLENPAGE           0x0004
+#define L1C_EXPANSION_NPCAPABLE             0x0008
+#define L1C_EXPANSION_MFAULTS               0x0010
+#define L1C_EXPANSION_RESV                  0xffe0
+
+/* 1000BASE-T Control Register */
+#define L1C_MII_GIGA_CR                     0x09
+#define L1C_GIGA_CR_1000T_HD_CAPS           0x0100
+#define L1C_GIGA_CR_1000T_FD_CAPS           0x0200
+#define L1C_GIGA_CR_1000T_REPEATER_DTE      0x0400
+
+#define L1C_GIGA_CR_1000T_MS_VALUE          0x0800
+
+#define L1C_GIGA_CR_1000T_MS_ENABLE         0x1000
+
+#define L1C_GIGA_CR_1000T_TEST_MODE_NORMAL  0x0000
+#define L1C_GIGA_CR_1000T_TEST_MODE_1       0x2000
+#define L1C_GIGA_CR_1000T_TEST_MODE_2       0x4000
+#define L1C_GIGA_CR_1000T_TEST_MODE_3       0x6000
+#define L1C_GIGA_CR_1000T_TEST_MODE_4       0x8000
+#define L1C_GIGA_CR_1000T_SPEED_MASK        0x0300
+#define L1C_GIGA_CR_1000T_DEFAULT_CAP       0x0300
+
+/* 1000BASE-T Status Register */
+#define L1C_MII_GIGA_SR                     0x0A
+
+/* PHY Specific Status Register */
+#define L1C_MII_GIGA_PSSR                   0x11
+#define L1C_GIGA_PSSR_FC_RXEN               0x0004
+#define L1C_GIGA_PSSR_FC_TXEN               0x0008
+#define L1C_GIGA_PSSR_SPD_DPLX_RESOLVED     0x0800
+#define L1C_GIGA_PSSR_DPLX                  0x2000
+#define L1C_GIGA_PSSR_SPEED                 0xC000
+#define L1C_GIGA_PSSR_10MBS                 0x0000
+#define L1C_GIGA_PSSR_100MBS                0x4000
+#define L1C_GIGA_PSSR_1000MBS               0x8000
+
+/* PHY Interrupt Enable Register */
+#define L1C_MII_IER                         0x12
+#define L1C_IER_LINK_UP                     0x0400
+#define L1C_IER_LINK_DOWN                   0x0800
+
+/* PHY Interrupt Status Register */
+#define L1C_MII_ISR                         0x13
+#define L1C_ISR_LINK_UP                     0x0400
+#define L1C_ISR_LINK_DOWN                   0x0800
+
+/* Cable-Detect-Test Control Register */
+#define L1C_MII_CDTC                        0x16
+#define L1C_CDTC_EN                         1       /* sc */
+#define L1C_CDTC_PAIR_MASK                  SHIFT8(3U)
+#define L1C_CDTC_PAIR_SHIFT                 8
+
+
+/* Cable-Detect-Test Status Register */
+#define L1C_MII_CDTS                        0x1C
+#define L1C_CDTS_STATUS_MASK                SHIFT8(3U)
+#define L1C_CDTS_STATUS_SHIFT               8
+#define L1C_CDTS_STATUS_NORMAL              0
+#define L1C_CDTS_STATUS_SHORT               1
+#define L1C_CDTS_STATUS_OPEN                2
+#define L1C_CDTS_STATUS_INVALID             3
+
+#define L1C_MII_DBG_ADDR                    0x1D
+#define L1C_MII_DBG_DATA                    0x1E
+
+/***************************** debug port *************************************/
+
+#define L1C_MIIDBG_ANACTRL                  0x00
+#define L1C_ANACTRL_CLK125M_DELAY_EN        BIT_15S
+#define L1C_ANACTRL_VCO_FAST                BIT_14S
+#define L1C_ANACTRL_VCO_SLOW                BIT_13S
+#define L1C_ANACTRL_AFE_MODE_EN             BIT_12S
+#define L1C_ANACTRL_LCKDET_PHY              BIT_11S
+#define L1C_ANACTRL_LCKDET_EN               BIT_10S
+#define L1C_ANACTRL_OEN_125M                BIT_9S
+#define L1C_ANACTRL_HBIAS_EN                BIT_8S
+#define L1C_ANACTRL_HB_EN                   BIT_7S
+#define L1C_ANACTRL_SEL_HSP                 BIT_6S
+#define L1C_ANACTRL_CLASSA_EN               BIT_5S
+#define L1C_ANACTRL_MANUSWON_SWR_MASK       SHIFT2(3U)
+#define L1C_ANACTRL_MANUSWON_SWR_SHIFT      2
+#define L1C_ANACTRL_MANUSWON_SWR_2V         0
+#define L1C_ANACTRL_MANUSWON_SWR_1P9V       1
+#define L1C_ANACTRL_MANUSWON_SWR_1P8V       2
+#define L1C_ANACTRL_MANUSWON_SWR_1P7V       3
+#define L1C_ANACTRL_MANUSWON_BW3_4M         BIT_1S
+#define L1C_ANACTRL_RESTART_CAL             BIT_0S
+#define L1C_ANACTRL_DEF                     0x02EF
+#if 0
+(\
+	L1C_ANACTRL_RESTART_CAL             |\
+	L1C_ANACTRL_MANUSWON_BW3_4M         |\
+	FIELDS(L1C_ANACTRL_MANUSWON_SWR, L1C_ANACTRL_MANUSWON_SWR_1P7V) |\
+	L1C_ANACTRL_CLASSA_EN               |\
+	L1C_ANACTRL_SEL_HSP                 |\
+	L1C_ANACTRL_HB_EN                   |\
+	L1C_ANACTRL_OEN_125M)
+#endif
+
+
+#define L1C_MIIDBG_SYSMODCTRL               0x04
+#define L1C_SYSMODCTRL_IECHOADJ_PFMH_PHY    BIT_15S
+#define L1C_SYSMODCTRL_IECHOADJ_BIASGEN     BIT_14S
+#define L1C_SYSMODCTRL_IECHOADJ_PFML_PHY    BIT_13S
+#define L1C_SYSMODCTRL_IECHOADJ_PS_MASK     SHIFT10(3U)
+#define L1C_SYSMODCTRL_IECHOADJ_PS_SHIFT    10
+#define L1C_SYSMODCTRL_IECHOADJ_PS_40       3
+#define L1C_SYSMODCTRL_IECHOADJ_PS_20       2
+#define L1C_SYSMODCTRL_IECHOADJ_PS_0        1
+#define L1C_SYSMODCTRL_IECHOADJ_10BT_100MV  BIT_6S /* 1:100mv, 0:200mv */
+#define L1C_SYSMODCTRL_IECHOADJ_HLFAP_MASK  SHIFT4(3U)
+#define L1C_SYSMODCTRL_IECHOADJ_HLFAP_SHIFT 4
+#define L1C_SYSMODCTRL_IECHOADJ_VDFULBW     BIT_3S
+#define L1C_SYSMODCTRL_IECHOADJ_VDBIASHLF   BIT_2S
+#define L1C_SYSMODCTRL_IECHOADJ_VDAMPHLF    BIT_1S
+#define L1C_SYSMODCTRL_IECHOADJ_VDLANSW     BIT_0S
+#define L1C_SYSMODCTRL_IECHOADJ_DEF         0x88BB /* ???? */
+#if 0
+(\
+	L1C_SYSMODCTRL_IECHOADJ_VDLANSW     |\
+	L1C_SYSMODCTRL_IECHOADJ_VDAMPHLF    |\
+	L1C_SYSMODCTRL_IECHOADJ_VDFULBW     |\
+	FIELDS(L1C_SYSMODCTRL_IECHOADJ_HLFAP, 3) |\
+	FIELDS(L1C_SYSMODCTRL_IECHOADJ_PS, L1C_SYSMODCTRL_IECHOADJ_PS_20) |\
+	L1C_SYSMODCTRL_IECHOADJ_PFMH_PHY)
+#endif
+
+
+#define L1D_MIIDBG_SYSMODCTRL               0x04    /* l1d & l2cb */
+#define L1D_SYSMODCTRL_IECHOADJ_CUR_ADD     BIT_15S
+#define L1D_SYSMODCTRL_IECHOADJ_CUR_MASK    SHIFT12(7U)
+#define L1D_SYSMODCTRL_IECHOADJ_CUR_SHIFT   12
+#define L1D_SYSMODCTRL_IECHOADJ_VOL_MASK    SHIFT8(0xFU)
+#define L1D_SYSMODCTRL_IECHOADJ_VOL_SHIFT   8
+#define L1D_SYSMODCTRL_IECHOADJ_VOL_17ALL   3
+#define L1D_SYSMODCTRL_IECHOADJ_VOL_100M15  1
+#define L1D_SYSMODCTRL_IECHOADJ_VOL_10M17   0
+#define L1D_SYSMODCTRL_IECHOADJ_BIAS1_MASK  SHIFT4(0xFU)
+#define L1D_SYSMODCTRL_IECHOADJ_BIAS1_SHIFT 4
+#define L1D_SYSMODCTRL_IECHOADJ_BIAS2_MASK  SHIFT0(0xFU)
+#define L1D_SYSMODCTRL_IECHOADJ_BIAS2_SHIFT 0
+#define L1D_SYSMODCTRL_IECHOADJ_DEF         0x4FBB
+
+
+#define L1C_MIIDBG_SRDSYSMOD                0x05
+#define L1C_SRDSYSMOD_LCKDET_EN             BIT_13S
+#define L1C_SRDSYSMOD_PLL_EN                BIT_11S
+#define L1C_SRDSYSMOD_SEL_HSP               BIT_10S
+#define L1C_SRDSYSMOD_HLFTXDR               BIT_9S
+#define L1C_SRDSYSMOD_TXCLK_DELAY_EN        BIT_8S
+#define L1C_SRDSYSMOD_TXELECIDLE            BIT_7S
+#define L1C_SRDSYSMOD_DEEMP_EN              BIT_6S
+#define L1C_SRDSYSMOD_MS_PAD                BIT_2S
+#define L1C_SRDSYSMOD_CDR_ADC_VLTG          BIT_1S
+#define L1C_SRDSYSMOD_CDR_DAC_1MA           BIT_0S
+#define L1C_SRDSYSMOD_DEF                   0x2C46
+
+#define L1C_MIIDBG_CFGLPSPD                 0x0A
+#define L1C_CFGLPSPD_RSTCNT_MASK            SHIFT(3U)
+#define L1C_CFGLPSPD_RSTCNT_SHIFT           14
+#define L1C_CFGLPSPD_RSTCNT_CLK125SW        BIT_13S
+
+#define L1C_MIIDBG_HIBNEG                   0x0B
+#define L1C_HIBNEG_PSHIB_EN                 BIT_15S
+#define L1C_HIBNEG_WAKE_BOTH                BIT_14S
+#define L1C_HIBNEG_ONOFF_ANACHG_SUDEN       BIT_13S
+#define L1C_HIBNEG_HIB_PULSE                BIT_12S
+#define L1C_HIBNEG_GATE_25M_EN              BIT_11S
+#define L1C_HIBNEG_RST_80U                  BIT_10S
+#define L1C_HIBNEG_RST_TIMER_MASK           SHIFT8(3U)
+#define L1C_HIBNEG_RST_TIMER_SHIFT          8
+#define L1C_HIBNEG_GTX_CLK_DELAY_MASK       SHIFT5(3U)
+#define L1C_HIBNEG_GTX_CLK_DELAY_SHIFT      5
+#define L1C_HIBNEG_BYPSS_BRKTIMER           BIT_4S
+#define L1C_HIBNEG_DEF                      0xBC40
+
+#define L1C_MIIDBG_TST10BTCFG               0x12
+#define L1C_TST10BTCFG_INTV_TIMER_MASK      SHIFT14(3U)
+#define L1C_TST10BTCFG_INTV_TIMER_SHIFT     SHIFT14
+#define L1C_TST10BTCFG_TRIGER_TIMER_MASK    SHIFT12(3U)
+#define L1C_TST10BTCFG_TRIGER_TIMER_SHIFT   12
+#define L1C_TST10BTCFG_DIV_MAN_MLT3_EN      BIT_11S
+#define L1C_TST10BTCFG_OFF_DAC_IDLE         BIT_10S
+#define L1C_TST10BTCFG_LPBK_DEEP            BIT_2S /* 1:deep,0:shallow */
+#define L1C_TST10BTCFG_DEF                  0x4C04
+
+#define L1C_MIIDBG_AZ_ANADECT               0x15
+#define L1C_AZ_ANADECT_10BTRX_TH            BIT_15S
+#define L1C_AZ_ANADECT_BOTH_01CHNL          BIT_14S
+#define L1C_AZ_ANADECT_INTV_MASK            SHIFT8(0x3FU)
+#define L1C_AZ_ANADECT_INTV_SHIFT           8
+#define L1C_AZ_ANADECT_THRESH_MASK          SHIFT4(0xFU)
+#define L1C_AZ_ANADECT_THRESH_SHIFT         4
+#define L1C_AZ_ANADECT_CHNL_MASK            SHIFT0(0xFU)
+#define L1C_AZ_ANADECT_CHNL_SHIFT           0
+#define L1C_AZ_ANADECT_DEF                  0x3220
+#define L1C_AZ_ANADECT_LONG                 0xb210
+
+#define L1D_MIIDBG_MSE16DB                  0x18
+#define L1D_MSE16DB_UP                      0x05EA
+#define L1D_MSE16DB_DOWN                    0x02EA
+
+
+#define L1C_MIIDBG_LEGCYPS                  0x29
+#define L1C_LEGCYPS_EN                      BIT_15S
+#define L1C_LEGCYPS_DAC_AMP1000_MASK        SHIFT12(7U)
+#define L1C_LEGCYPS_DAC_AMP1000_SHIFT       12
+#define L1C_LEGCYPS_DAC_AMP100_MASK         SHIFT9(7U)
+#define L1C_LEGCYPS_DAC_AMP100_SHIFT        9
+#define L1C_LEGCYPS_DAC_AMP10_MASK          SHIFT6(7U)
+#define L1C_LEGCYPS_DAC_AMP10_SHIFT         6
+#define L1C_LEGCYPS_UNPLUG_TIMER_MASK       SHIFT3(7U)
+#define L1C_LEGCYPS_UNPLUG_TIMER_SHIFT      3
+#define L1C_LEGCYPS_UNPLUG_DECT_EN          BIT_2S
+#define L1C_LEGCYPS_ECNC_PS_EN              BIT_0S
+#define L1D_LEGCYPS_DEF                     0x129D
+#define L1C_LEGCYPS_DEF                     0x36DD
+
+#define L1C_MIIDBG_TST100BTCFG              0x36
+#define L1C_TST100BTCFG_NORMAL_BW_EN        BIT_15S
+#define L1C_TST100BTCFG_BADLNK_BYPASS       BIT_14S
+#define L1C_TST100BTCFG_SHORTCABL_TH_MASK   SHIFT8(0x3FU)
+#define L1C_TST100BTCFG_SHORTCABL_TH_SHIFT  8
+#define L1C_TST100BTCFG_LITCH_EN            BIT_7S
+#define L1C_TST100BTCFG_VLT_SW              BIT_6S
+#define L1C_TST100BTCFG_LONGCABL_TH_MASK    SHIFT0(0x3FU)
+#define L1C_TST100BTCFG_LONGCABL_TH_SHIFT   0
+#define L1C_TST100BTCFG_DEF                 0xE12C
+
+#define L1C_MIIDBG_VOLT_CTRL                0x3B
+#define L1C_VOLT_CTRL_CABLE1TH_MASK         SHIFT7(0x1FFU)
+#define L1C_VOLT_CTRL_CABLE1TH_SHIFT        7
+#define L1C_VOLT_CTRL_AMPCTRL_MASK          SHIFT5(3U)
+#define L1C_VOLT_CTRL_AMPCTRL_SHIFT         5
+#define L1C_VOLT_CTRL_SW_BYPASS             BIT_4S
+#define L1C_VOLT_CTRL_SWLOWEST              BIT_3S
+#define L1C_VOLT_CTRL_DACAMP10_MASK         SHIFT0(7U)
+#define L1C_VOLT_CTRL_DACAMP10_SHIFT        0
+
+#define L1C_MIIDBG_CABLE1TH_DET             0x3E
+#define L1C_CABLE1TH_DET_EN                 BIT_15S
+
+/***************************** extension **************************************/
+
+/******* dev 3 *********/
+#define L1C_MIIEXT_PCS                      3
+
+#define L1C_MIIEXT_CLDCTRL3                 0x8003
+#define L1C_CLDCTRL3_BP_CABLE1TH_DET_GT     BIT_15S
+#define L1C_CLDCTRL3_AZ_DISAMP              BIT_12S
+#define L1C_CLDCTRL3_L2CB                   0x4D19
+#define L1C_CLDCTRL3_L1D                    0xDD19
+
+#define L1C_MIIEXT_CLDCTRL6                 0x8006
+#define L1C_CLDCTRL6_CAB_LEN_MASK           SHIFT0(0x1FFU)
+#define L1C_CLDCTRL6_CAB_LEN_SHIFT          0
+#define L1C_CLDCTRL6_CAB_LEN_SHORT          0x50
+
+#define L1C_MIIEXT_CLDCTRL7                 0x8007
+#define L1C_CLDCTRL7_VDHLF_BIAS_TH_MASK     SHIFT9(0x7FU)
+#define L1C_CLDCTRL7_VDHLF_BIAS_TH_SHIFT    9
+#define L1C_CLDCTRL7_AFE_AZ_MASK            SHIFT4(0x1FU)
+#define L1C_CLDCTRL7_AFE_AZ_SHIFT           4
+#define L1C_CLDCTRL7_SIDE_PEAK_TH_MASK      SHIFT0(0xFU)
+#define L1C_CLDCTRL7_SIDE_PEAK_TH_SHIFT     0
+#define L1C_CLDCTRL7_DEF                    0x6BF6 /* ???? */
+#define L1C_CLDCTRL7_FPGA_DEF               0x0005
+#define L1C_CLDCTRL7_L2CB                   0x0175
+
+#define L1C_MIIEXT_AZCTRL                   0x8008
+#define L1C_AZCTRL_SHORT_TH_MASK            SHIFT8(0xFFU)
+#define L1C_AZCTRL_SHORT_TH_SHIFT           8
+#define L1C_AZCTRL_LONG_TH_MASK             SHIFT0(0xFFU)
+#define L1C_AZCTRL_LONG_TH_SHIFT            0
+#define L1C_AZCTRL_DEF                      0x1629
+#define L1C_AZCTRL_FPGA_DEF                 0x101D
+#define L1C_AZCTRL_L1D                      0x2034
+
+#define L1C_MIIEXT_AZCTRL2                  0x8009
+#define L1C_AZCTRL2_WAKETRNING_MASK         SHIFT8(0xFFU)
+#define L1C_AZCTRL2_WAKETRNING_SHIFT        8
+#define L1C_AZCTRL2_QUIET_TIMER_MASH        SHIFT6(3U)
+#define L1C_AZCTRL2_QUIET_TIMER_SHIFT       6
+#define L1C_AZCTRL2_PHAS_JMP2               BIT_4S
+#define L1C_AZCTRL2_CLKTRCV_125MD16         BIT_3S
+#define L1C_AZCTRL2_GATE1000_EN             BIT_2S
+#define L1C_AZCTRL2_AVRG_FREQ               BIT_1S
+#define L1C_AZCTRL2_PHAS_JMP4               BIT_0S
+#define L1C_AZCTRL2_DEF                     0x32C0
+#define L1C_AZCTRL2_FPGA_DEF                0x40C8
+#define L1C_AZCTRL2_L2CB                    0xE003
+#define L1C_AZCTRL2_L1D2                    0x18C0
+
+
+#define L1C_MIIEXT_AZCTRL4                  0x800B
+#define L1C_AZCTRL4_WAKE_STH_L2CB           0x0094
+
+#define L1C_MIIEXT_AZCTRL5                  0x800C
+#define L1C_AZCTRL5_WAKE_LTH_L2CB           0x00EB
+
+#define L1C_MIIEXT_AZCTRL6                  0x800D
+#define L1C_AZCTRL6_L1D2                    0x003F
+
+
+
+/********* dev 7 **********/
+#define L1C_MIIEXT_ANEG                     7
+
+#define L1C_MIIEXT_LOCAL_EEEADV             0x3C
+#define L1C_LOCAL_EEEADV_1000BT             BIT_2S
+#define L1C_LOCAL_EEEADV_100BT              BIT_1S
+
+#define L1C_MIIEXT_REMOTE_EEEADV            0x3D
+#define L1C_REMOTE_EEEADV_1000BT            BIT_2S
+#define L1C_REMOTE_EEEADV_100BT             BIT_1S
+
+#define L1C_MIIEXT_EEE_ANEG                 0x8000
+#define L1C_EEE_ANEG_1000M                  BIT_2S
+#define L1C_EEE_ANEG_100M                   BIT_1S
+
+
+
+
+/******************************************************************************/
+
+/* functions */
+
+/* get permanent mac address from
+ * return
+ *    0: success
+ *    non-0:fail
+ */
+u16 l1c_get_perm_macaddr(PETHCONTEXT ctx, u8 *addr);
+
+
+/* reset mac & dma
+ * return
+ *     0: success
+ *     non-0:fail
+ */
+u16 l1c_reset_mac(PETHCONTEXT ctx);
+
+/* reset phy
+ * return
+ *    0: success
+ *    non-0:fail
+ */
+u16 l1c_reset_phy(PETHCONTEXT ctx, bool pws_en, bool az_en, bool ptp_en);
+
+
+/* reset pcie
+ * just reset pcie relative registers (pci command, clk, aspm...)
+ * return
+ *    0:success
+ *    non-0:fail
+ */
+u16 l1c_reset_pcie(PETHCONTEXT ctx, bool l0s_en, bool l1_en);
+
+
+/* disable/enable MAC/RXQ/TXQ
+ * en
+ *    true:enable
+ *    false:disable
+ * return
+ *    0:success
+ *    non-0-fail
+ */
+u16 l1c_enable_mac(PETHCONTEXT ctx, bool en, u16 en_ctrl);
+
+/* enable/disable aspm support
+ * that will change settings for phy/mac/pcie
+ */
+u16 l1c_enable_aspm(PETHCONTEXT ctx, bool l0s_en, bool l1_en, u8 lnk_stat);
+
+
+/* initialize phy for speed / flow control
+ * lnk_cap
+ *    if autoNeg, is link capability to tell the peer
+ *    if force mode, is forced speed/duplex
+ */
+u16 l1c_init_phy_spdfc(PETHCONTEXT ctx, bool auto_neg,
+		       u8 lnk_cap, bool fc_en);
+
+/* do post setting on phy if link up/down event occur
+ */
+u16 l1c_post_phy_link(PETHCONTEXT ctx, bool linkon, u8 wire_spd);
+
+
+/* do power saving setting befor enter suspend mode
+ * NOTE:
+ *    1. phy link must be established before calling this function
+ *    2. wol option (pattern,magic,link,etc.) is configed before call it.
+ */
+u16 l1c_powersaving(PETHCONTEXT ctx, u8 wire_spd, bool wol_en,
+		    bool mac_txen, bool mac_rxen, bool pws_en);
+
+
+/* read phy register */
+u16 l1c_read_phy(PETHCONTEXT ctx, bool ext, u8 dev, bool fast, u16 reg,
+		 u16 *data);
+
+/* write phy register */
+u16 l1c_write_phy(PETHCONTEXT ctx, bool ext, u8 dev,  bool fast, u16 reg,
+		  u16 data);
+
+/* phy debug port */
+u16 l1c_read_phydbg(PETHCONTEXT ctx, bool fast, u16 reg, u16 *data);
+u16 l1c_write_phydbg(PETHCONTEXT ctx, bool fast, u16 reg, u16 data);
+
+/* check the configuration of the PHY */
+u16 l1c_get_phy_config(PETHCONTEXT ctx);
+
+/*
+ * initialize mac basically
+ *  most of hi-feature no init
+ *      MAC/PHY should be reset before call this function
+ */
+u16 l1c_init_mac(PETHCONTEXT ctx, u8 *addr, u32 txmem_hi,
+		 u32 *tx_mem_lo, u8 tx_qnum, u16 txring_sz,
+		 u32 rxmem_hi, u32 rfdmem_lo, u32 rrdmem_lo,
+		 u16 rxring_sz, u16 rxbuf_sz, u16 smb_timer,
+		 u16 mtu, u16 int_mod, bool hash_legacy);
+
+
+
+#ifdef __cplusplus
+}
+#endif/*__cplusplus*/
+
+#endif/*L1C_HW_H_*/
+
diff --git a/drivers/net/ethernet/atheros/alx/alf_cb.c b/drivers/net/ethernet/atheros/alx/alf_cb.c
new file mode 100755
index 0000000..5c42928
--- /dev/null
+++ b/drivers/net/ethernet/atheros/alx/alf_cb.c
@@ -0,0 +1,1368 @@
+/*
+ * Copyright (c) 2010 - 2011 Atheros Communications Inc.
+ *
+ * Permission to use, copy, modify, and/or distribute this software for any
+ * purpose with or without fee is hereby granted, provided that the above
+ * copyright notice and this permission notice appear in all copies.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
+ * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
+ * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
+ * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
+ * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
+ * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ */
+
+#include "alf_hw.h"
+
+
+#define ALF_REV_ID_AR8161_B0            0x10
+
+/* definition for MSIX */
+#define ALF_MSIX_ENTRY_BASE		0x2000
+#define ALF_MSIX_ENTRY_SIZE		16
+#define ALF_MSIX_MSG_LOADDR_OFF		0
+#define ALF_MSIX_MSG_HIADDR_OFF		4
+#define ALF_MSIX_MSG_DATA_OFF		8
+#define ALF_MSIX_MSG_CTRL_OFF		12
+
+#define ALF_MSIX_INDEX_RXQ0		0
+#define ALF_MSIX_INDEX_RXQ1		1
+#define ALF_MSIX_INDEX_RXQ2		2
+#define ALF_MSIX_INDEX_RXQ3		3
+#define ALF_MSIX_INDEX_RXQ4		4
+#define ALF_MSIX_INDEX_RXQ5		5
+#define ALF_MSIX_INDEX_RXQ6		6
+#define ALF_MSIX_INDEX_RXQ7		7
+#define ALF_MSIX_INDEX_TXQ0		8
+#define ALF_MSIX_INDEX_TXQ1		9
+#define ALF_MSIX_INDEX_TXQ2		10
+#define ALF_MSIX_INDEX_TXQ3		11
+#define ALF_MSIX_INDEX_TIMER		12
+#define ALF_MSIX_INDEX_ALERT		13
+#define ALF_MSIX_INDEX_SMB		14
+#define ALF_MSIX_INDEX_PHY		15
+
+
+#define ALF_SRAM_BASE		L1F_SRAM0
+#define ALF_SRAM(_i, _type) \
+		(ALF_SRAM_BASE + ((_i) * sizeof(_type)))
+
+#define ALF_MIB_BASE		L1F_MIB_BASE
+#define ALF_MIB(_i, _type) \
+		(ALF_MIB_BASE + ((_i) * sizeof(_type)))
+
+/* definition for RSS */
+#define ALF_RSS_KEY_BASE	L1F_RSS_KEY0
+#define ALF_RSS_IDT_BASE	L1F_RSS_IDT_TBL0
+#define ALF_RSS_KEY(_i, _type) \
+		(ALF_RSS_KEY_BASE + ((_i) * sizeof(_type)))
+#define ALF_RSS_TBL(_i, _type) \
+		(L1F_RSS_IDT_TBL0 + ((_i) * sizeof(_type)))
+
+
+
+
+
+/* NIC */
+int alf_identify_nic(struct alx_hw *hw)
+{
+	u32 drv;
+	int retval = 0;
+
+	if (hw->pci_revid < ALX_REV_ID_AR8161_V2_0)
+		return retval;
+
+	/* check from V2_0(b0) to ... */
+	switch (hw->pci_revid) {
+	default:
+		MEM_R32(hw, L1F_DRV, &drv);
+		if (drv & LX_DRV_DISABLE)
+			return ALX_ERR_DISABLE_DRV;
+		break;
+	}
+
+	return retval;
+}
+
+/* PHY */
+int alf_read_phy_reg(struct alx_hw *hw, u32 device_type,
+		     u16 reg_addr, u16 *phy_data)
+{
+	bool fast = false;
+	bool ext = false;
+	u16 error;
+	int retval = 0;
+
+	ALX_MDIO_LOCK(&hw->mdio_lock);
+
+	if (device_type != ALX_MDIO_NORM_DEV)
+		ext = true;
+
+	error = l1f_read_phy(hw, ext, device_type, fast,
+			     reg_addr, phy_data);
+	if (error) {
+		HW_PRINT(ERR, "Error when reading phy reg (%d).", error);
+		retval = ALX_ERR_PHY_READ_REG;
+	}
+
+	ALX_MDIO_UNLOCK(&hw->mdio_lock);
+
+	return retval;
+}
+
+int alf_write_phy_reg(struct alx_hw *hw, u32 device_type,
+		      u16 reg_addr, u16 phy_data)
+{
+	bool fast = false;
+	bool ext = false;
+	u16 error;
+	int retval = 0;
+
+	ALX_MDIO_LOCK(&hw->mdio_lock);
+
+	if (device_type != ALX_MDIO_NORM_DEV)
+		ext = true;
+
+	error = l1f_write_phy(hw, ext, device_type, fast,
+			      reg_addr, phy_data);
+	if (error) {
+		HW_PRINT(ERR, "Error when writting phy reg (%d).", error);
+		retval = ALX_ERR_PHY_WRITE_REG;
+	}
+
+
+	ALX_MDIO_UNLOCK(&hw->mdio_lock);
+
+	return retval;
+}
+
+
+int alf_init_phy(struct alx_hw *hw)
+{
+	u16 phy_id[2];
+	int retval = 0;
+
+	HW_PRINT(DEBUG, "ENTER\n");
+
+	/* 1. init mdio spin lock */
+	ALX_MDIO_LOCK_INIT(&hw->mdio_lock);
+
+	/* 2. read phy id */
+	retval = alf_read_phy_reg(hw, ALX_MDIO_NORM_DEV,
+				  L1F_MII_PHYSID1, &phy_id[0]);
+	if (retval)
+		return retval;
+	retval = alf_read_phy_reg(hw, ALX_MDIO_NORM_DEV,
+				  L1F_MII_PHYSID1, &phy_id[1]);
+	if (retval)
+		return retval;
+	memcpy(&hw->phy_id, phy_id, sizeof(hw->phy_id));
+
+	hw->autoneg_advertised = (ALX_LINK_SPEED_1GB_FULL |
+				  ALX_LINK_SPEED_10_HALF  |
+				  ALX_LINK_SPEED_10_FULL  |
+				  ALX_LINK_SPEED_100_HALF |
+				  ALX_LINK_SPEED_100_FULL);
+	return retval;
+}
+
+
+int alf_reset_phy(struct alx_hw *hw)
+{
+	int retval = 0;
+	bool pws_en, az_en, ptp_en;
+	u32 phy;
+
+	HW_PRINT(DEBUG, "ENTER\n");
+
+	pws_en = az_en = ptp_en = false;
+	CLI_HW_FLAG(PWSAVE_EN);
+	CLI_HW_FLAG(AZ_EN);
+	CLI_HW_FLAG(PTP_EN);
+
+	if (CHK_HW_FLAG(PWSAVE_CAP)) {
+		pws_en = true;
+		SET_HW_FLAG(PWSAVE_EN);
+	}
+
+	if (CHK_HW_FLAG(AZ_CAP)) {
+		az_en = true;
+		SET_HW_FLAG(AZ_EN);
+	}
+
+	if (CHK_HW_FLAG(PTP_CAP)) {
+		ptp_en = true;
+		SET_HW_FLAG(PTP_EN);
+	}
+
+	HW_PRINT(INFO, "reset PHY, pws = %d, az = %d, ptp = %d\n",
+		 pws_en, az_en, ptp_en);
+	if (l1f_reset_phy(hw, pws_en, az_en, ptp_en))
+		retval = ALX_ERR_PHY_RESET;
+
+	MEM_R32(hw, L1F_PHY_CTRL, &phy);
+	HW_PRINT(INFO, "Parameters When reset PHY, phy reg = 0x%x\n",
+		 phy);
+
+	return retval;
+}
+
+
+/* LINK */
+int alf_setup_phy_link(struct alx_hw *hw, u32 speed, bool autoneg, bool fc)
+{
+	u8 link_cap = 0;
+	int retval = 0;
+
+	HW_PRINT(DEBUG, "ENTER\n");
+
+	HW_PRINT(INFO, "speed = 0x%x, autoneg = %d\n", speed, autoneg);
+	if (speed & ALX_LINK_SPEED_1GB_FULL)
+		link_cap |= LX_LC_1000F;
+
+	if (speed & ALX_LINK_SPEED_100_FULL)
+		link_cap |= LX_LC_100F;
+
+	if (speed & ALX_LINK_SPEED_100_HALF)
+		link_cap |= LX_LC_100H;
+
+	if (speed & ALX_LINK_SPEED_10_FULL)
+		link_cap |= LX_LC_10F;
+
+	if (speed & ALX_LINK_SPEED_10_HALF)
+		link_cap |= LX_LC_10H;
+
+
+
+	if (l1f_init_phy_spdfc(hw, autoneg, link_cap, fc))
+		retval = ALX_ERR_PHY_SETUP_LNK;
+
+	return retval;
+}
+
+
+int alf_setup_phy_link_speed(struct alx_hw *hw, u32 speed,
+			     bool autoneg, bool fc)
+{
+	int retval = 0;
+
+	HW_PRINT(DEBUG, "ENTER\n");
+
+	/*
+	 * Clear autoneg_advertised and set new values based on input link
+	 * speed.
+	 */
+	hw->autoneg_advertised = 0;
+
+	if (speed & ALX_LINK_SPEED_1GB_FULL)
+		hw->autoneg_advertised |= ALX_LINK_SPEED_1GB_FULL;
+
+	if (speed & ALX_LINK_SPEED_100_FULL)
+		hw->autoneg_advertised |= ALX_LINK_SPEED_100_FULL;
+
+	if (speed & ALX_LINK_SPEED_100_HALF)
+		hw->autoneg_advertised |= ALX_LINK_SPEED_100_HALF;
+
+	if (speed & ALX_LINK_SPEED_10_FULL)
+		hw->autoneg_advertised |= ALX_LINK_SPEED_10_FULL;
+
+	if (speed & ALX_LINK_SPEED_10_HALF)
+		hw->autoneg_advertised |= ALX_LINK_SPEED_10_HALF;
+
+	retval = alf_setup_phy_link(hw, hw->autoneg_advertised,
+				autoneg, fc);
+	return retval;
+
+
+}
+
+
+
+int alf_check_phy_link(struct alx_hw *hw, u32 *speed, bool *link_up)
+{
+	u16 bmsr, giga;
+	int retval;
+
+	HW_PRINT(DEBUG, "ENTER\n");
+
+	alf_read_phy_reg(hw, ALX_MDIO_NORM_DEV, L1F_MII_BMSR, &bmsr);
+	retval = alf_read_phy_reg(hw, ALX_MDIO_NORM_DEV,
+				  L1F_MII_BMSR, &bmsr);
+	if (retval)
+		return retval;
+
+
+	*link_up = true;
+	if (!(bmsr & L1F_BMSR_LINK_STATUS)) {
+		*link_up = false;
+		*speed = ALX_LINK_SPEED_UNKNOWN;
+		return retval;
+	}
+
+	/* Read PHY Specific Status Register (17) */
+	retval = alf_read_phy_reg(hw, ALX_MDIO_NORM_DEV,
+				  L1F_MII_GIGA_PSSR, &giga);
+	if (retval)
+		return retval;
+
+
+	if (!(giga & L1F_GIGA_PSSR_SPD_DPLX_RESOLVED))
+		return ALX_ERR_PHY_RESOLVED;
+
+	switch (giga & L1F_GIGA_PSSR_SPEED) {
+	case L1F_GIGA_PSSR_1000MBS:
+		if (giga & L1F_GIGA_PSSR_DPLX)
+			*speed = ALX_LINK_SPEED_1GB_FULL;
+		else
+			HW_PRINT(ERR, "1000M half is invalid");
+		break;
+	case L1F_GIGA_PSSR_100MBS:
+		if (giga & L1F_GIGA_PSSR_DPLX)
+			*speed = ALX_LINK_SPEED_100_FULL;
+		else
+			*speed = ALX_LINK_SPEED_100_HALF;
+		break;
+	case L1F_GIGA_PSSR_10MBS:
+		if (giga & L1F_GIGA_PSSR_DPLX)
+			*speed = ALX_LINK_SPEED_10_FULL;
+		else
+			*speed = ALX_LINK_SPEED_10_HALF;
+		break;
+	default:
+		*speed = ALX_LINK_SPEED_UNKNOWN;
+		retval = ALX_ERR_PHY_CHECK_LNK;
+		break;
+	}
+
+	return retval;
+}
+
+
+/*
+ * 1. stop_mac
+ * 2. reset mac & dma by reg1400(MASTER)
+ * 3. control speed/duplex, hash-alg
+ * 4. clock switch setting
+ */
+int alf_reset_mac(struct alx_hw *hw)
+{
+	int retval = 0;
+
+	HW_PRINT(DEBUG, "ENTER\n");
+
+	if (l1f_reset_mac(hw))
+		retval = ALX_ERR_MAC_RESET;
+	return retval;
+}
+
+
+int alf_start_mac(struct alx_hw *hw)
+{
+	u16 en_ctrl = 0;
+	int retval = 0;
+
+	HW_PRINT(DEBUG, "ENTER\n");
+
+	/* set link speed param */
+	switch (hw->link_speed) {
+	case ALX_LINK_SPEED_1GB_FULL:
+		en_ctrl |= LX_MACSPEED_1000;
+		/* fall through */
+	case ALX_LINK_SPEED_100_FULL:
+	case ALX_LINK_SPEED_10_FULL:
+		en_ctrl |= LX_MACDUPLEX_FULL;
+		break;
+	}
+
+	/* set fc param*/
+	switch (hw->cur_fc_mode) {
+	case alx_fc_full:
+		en_ctrl |= LX_FC_RXEN; /* Flow Control RX Enable */
+		en_ctrl |= LX_FC_TXEN; /* Flow Control TX Enable */
+		break;
+	case alx_fc_rx_pause:
+		en_ctrl |= LX_FC_RXEN; /* Flow Control RX Enable */
+		break;
+	case alx_fc_tx_pause:
+		en_ctrl |= LX_FC_TXEN; /* Flow Control TX Enable */
+		break;
+	default:
+		break;
+	}
+
+	if (hw->fc_single_pause)
+		en_ctrl |= LX_SINGLE_PAUSE;
+
+
+	en_ctrl |= LX_FLT_DIRECT;    /* RX Enable; and TX Always Enable */
+	en_ctrl |= LX_FLT_BROADCAST; /* RX Broadcast Enable */
+	en_ctrl |= LX_ADD_FCS;
+
+	if (CHK_HW_FLAG(VLANSTRIP_EN))
+		en_ctrl |= LX_VLAN_STRIP;
+
+	if (CHK_HW_FLAG(PROMISC_EN))
+		en_ctrl |=  LX_FLT_PROMISC;
+
+	if (CHK_HW_FLAG(MULTIALL_EN))
+		en_ctrl |= LX_FLT_MULTI_ALL;
+
+
+	if (l1f_enable_mac(hw, true, en_ctrl))
+		retval = ALX_ERR_MAC_START;
+	return retval;
+}
+
+
+/*
+ * 1. stop RXQ (reg15A0) and TXQ (reg1590)
+ * 2. stop MAC (reg1480)
+ */
+int alf_stop_mac(struct alx_hw *hw)
+{
+	int retval = 0;
+
+	HW_PRINT(DEBUG, "ENTER\n");
+
+	if (l1f_enable_mac(hw, false, 0))
+		retval = ALX_ERR_MAC_STOP;
+	return retval;
+}
+
+
+int alf_config_mac(struct alx_hw *hw, u16 rxbuf_sz, u16 rx_qnum,
+		   u16 rxring_sz, u16 tx_qnum,  u16 txring_sz)
+{
+	u8 *addr;
+
+	u32 txmem_hi, txmem_lo[4];
+	u32 rxmem_hi, rfdmem_lo, rrdmem_lo;
+
+	u16 smb_timer, mtu_with_eth, int_mod;
+	bool hash_legacy;
+
+	int i;
+	int retval = 0;
+#if MAC_TYPE_FPGA == MAC_TYPE
+	u32 phy;
+#endif
+
+	HW_PRINT(DEBUG, "ENTER\n");
+
+	addr = hw->mac_addr;
+
+	txmem_hi = ALX_DMA_ADDR_HI(hw->tpdma[0]);
+	for (i = 0; i < tx_qnum; i++)
+		txmem_lo[i] = ALX_DMA_ADDR_LO(hw->tpdma[i]);
+
+
+	rxmem_hi  = ALX_DMA_ADDR_HI(hw->rfdma[0]);
+	rfdmem_lo = ALX_DMA_ADDR_LO(hw->rfdma[0]);
+	rrdmem_lo = ALX_DMA_ADDR_LO(hw->rrdma[0]);
+
+	smb_timer = (u16)hw->smb_timer;
+	mtu_with_eth = hw->mtu + ALX_ETH_LENGTH_OF_HEADER;
+	int_mod = hw->imt;
+
+	hash_legacy = true;
+
+	if (l1f_init_mac(hw, addr, txmem_hi, txmem_lo, tx_qnum, txring_sz,
+			 rxmem_hi, rfdmem_lo, rrdmem_lo, rxring_sz, rxbuf_sz,
+			 smb_timer, mtu_with_eth, int_mod, hash_legacy)) {
+		retval = ALX_ERR_MAC_CONFIGURE;
+	}
+
+#if MAC_TYPE_FPGA == MAC_TYPE
+	MEM_R32(hw, L1F_MDIO, &phy);
+	phy |= 0x10000000;
+	MEM_W32(hw, L1F_MDIO, phy);
+#endif
+	return retval;
+}
+
+
+
+/**
+ *  alf_get_mac_addr
+ *  @hw: pointer to hardware structure
+ **/
+int alf_get_mac_addr(struct alx_hw *hw, u8 *addr)
+{
+	int retval = 0;
+
+	HW_PRINT(DEBUG, "ENTER\n");
+
+	if (l1f_get_perm_macaddr(hw, addr))
+		retval = ALX_ERR_MAC_ADDR;
+	return retval;
+}
+
+
+int alf_reset_pcie(struct alx_hw *hw, bool l0s_en, bool l1_en)
+{
+	int retval = 0;
+
+	HW_PRINT(DEBUG, "ENTER\n");
+
+	if (!CHK_HW_FLAG(L0S_CAP))
+		l0s_en = false;
+
+	if (l0s_en)
+		SET_HW_FLAG(L0S_EN);
+	else
+		CLI_HW_FLAG(L0S_EN);
+
+
+	if (!CHK_HW_FLAG(L1_CAP))
+		l1_en = false;
+
+	if (l1_en)
+		SET_HW_FLAG(L1_EN);
+	else
+		CLI_HW_FLAG(L1_EN);
+
+
+
+	if (l1f_reset_pcie(hw, l0s_en, l1_en))
+		retval = ALX_ERR_PCIE_RESET;
+
+	return retval;
+}
+
+
+int alf_config_aspm(struct alx_hw *hw, bool l0s_en, bool l1_en)
+{
+	int retval = 0;
+
+	HW_PRINT(DEBUG, "ENTER\n");
+
+	if (!CHK_HW_FLAG(L0S_CAP))
+		l0s_en = false;
+
+	if (l0s_en)
+		SET_HW_FLAG(L0S_EN);
+	 else
+		CLI_HW_FLAG(L0S_EN);
+
+
+	if (!CHK_HW_FLAG(L1_CAP))
+		l1_en = false;
+
+	if (l1_en)
+		SET_HW_FLAG(L1_EN);
+	else
+		CLI_HW_FLAG(L1_EN);
+
+
+	if (l1f_enable_aspm(hw, l0s_en, l1_en, 0))
+		retval = ALX_ERR_ASPM;
+
+	return retval;
+}
+
+
+int alf_config_wol(struct alx_hw *hw, u32 wufc)
+{
+	u32 wol;
+	int retval = 0;
+
+	HW_PRINT(DEBUG, "ENTER\n");
+
+	wol = 0;
+	/* turn on magic packet event */
+	if (wufc & ALX_WOL_MAGIC) {
+		wol |= L1F_WOL0_MAGIC_EN | L1F_WOL0_PME_MAGIC_EN;
+		/* magic packet maybe Broadcast&multicast&Unicast frame */
+		/* mac |= MAC_CTRL_BC_EN; */
+	}
+
+	/* turn on link up event */
+	if (wufc & ALX_WOL_PHY) {
+		wol |=  L1F_WOL0_LINK_EN | L1F_WOL0_PME_LINK;
+		/* only link up can wake up */
+		retval = alf_write_phy_reg(hw, ALX_MDIO_NORM_DEV,
+					   L1F_MII_IER, L1F_IER_LINK_UP);
+	}
+	MEM_W32(hw, L1F_WOL0, wol);
+
+	return retval;
+}
+
+
+
+int alf_config_mac_ctrl(struct alx_hw *hw)
+{
+	u32 mac;
+
+	HW_PRINT(DEBUG, "ENTER\n");
+
+	MEM_R32(hw, L1F_MAC_CTRL, &mac);
+
+	/* enable/disable VLAN tag insert,strip */
+	if (CHK_HW_FLAG(VLANSTRIP_EN))
+		mac |= L1F_MAC_CTRL_VLANSTRIP;
+	else
+		mac &= ~L1F_MAC_CTRL_VLANSTRIP;
+
+	if (CHK_HW_FLAG(PROMISC_EN))
+		mac |= L1F_MAC_CTRL_PROMISC_EN;
+	else
+		mac &= ~L1F_MAC_CTRL_PROMISC_EN;
+
+	if (CHK_HW_FLAG(MULTIALL_EN))
+		mac |= L1F_MAC_CTRL_MULTIALL_EN;
+	else
+		mac &= ~L1F_MAC_CTRL_MULTIALL_EN;
+
+	MEM_W32(hw, L1F_MAC_CTRL, mac);
+	return 0;
+}
+
+int alf_config_pow_save(struct alx_hw *hw, u32 speed, bool wol_en,
+			bool tx_en, bool rx_en, bool pws_en)
+{
+	u8 wire_spd = LX_LC_10H;
+	int retval = 0;
+
+	HW_PRINT(DEBUG, "ENTER\n");
+
+	switch (speed) {
+	case ALX_LINK_SPEED_UNKNOWN:
+	case ALX_LINK_SPEED_10_HALF:
+		wire_spd = LX_LC_10H;
+		break;
+	case ALX_LINK_SPEED_10_FULL:
+		wire_spd = LX_LC_10F;
+		break;
+	case ALX_LINK_SPEED_100_HALF:
+		wire_spd = LX_LC_100H;
+		break;
+	case ALX_LINK_SPEED_100_FULL:
+		wire_spd = LX_LC_100F;
+		break;
+	case ALX_LINK_SPEED_1GB_FULL:
+		wire_spd = LX_LC_1000F;
+		break;
+	}
+
+	if (l1f_powersaving(hw, wire_spd, wol_en, tx_en, rx_en, pws_en))
+		retval = ALX_ERR_PWR_SAVING;
+	return retval;
+}
+
+
+
+/* RAR, Multicast, VLAN */
+int alf_set_mac_addr(struct alx_hw *hw, u8 *addr)
+{
+	u32 sta;
+	int retval = 0;
+
+	HW_PRINT(DEBUG, "ENTER\n");
+
+	/*
+	 * for example: 00-0B-6A-F6-00-DC
+	 * 0<-->6AF600DC, 1<-->000B.
+	 */
+
+	 /* low dword */
+	sta = (((u32)addr[2]) << 24) | (((u32)addr[3]) << 16) |
+	      (((u32)addr[4]) << 8)  | (((u32)addr[5])) ;
+	MEM_W32(hw, L1F_STAD0, sta);
+	/* hight dword */
+	sta = (((u32)addr[0]) << 8) | (((u32)addr[1])) ;
+	MEM_W32(hw, L1F_STAD1, sta);
+
+	return retval;
+}
+
+int alf_clear_mac_addr(struct alx_hw *hw)
+{
+	int retval = 0;
+	return retval;
+}
+
+int alf_set_mc_addr(struct alx_hw *hw, u8 *addr)
+{
+	u32 crc32;
+	u32 bit, reg;
+	u32 mta;
+
+	HW_PRINT(DEBUG, "ENTER\n");
+
+	/*
+	* set hash value for a multicast address hash calcu processing.
+	*   1. calcu 32bit CRC for multicast address
+	*   2. reverse crc with MSB to LSB
+	*/
+	crc32 = ALX_ETH_CRC(addr, ALX_ETH_LENGTH_OF_ADDRESS);
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
+	reg = (crc32 >> 31) & 0x1;
+	bit = (crc32 >> 26) & 0x1F;
+
+	MEM_R32(hw, L1F_HASH_TBL0 + (reg<<2), &mta);
+	mta |= (0x1 << bit);
+	MEM_W32(hw, L1F_HASH_TBL0 + (reg<<2), mta);
+
+	return 0;
+}
+
+int alf_clear_mc_addr(struct alx_hw *hw)
+{
+
+	HW_PRINT(DEBUG, "ENTER\n");
+
+	MEM_W32(hw, L1F_HASH_TBL0, 0);
+	MEM_W32(hw, L1F_HASH_TBL1, 0);
+	return 0;
+}
+
+
+/* TX, RX, IRQ */
+int alf_config_rx(struct alx_hw *hw)
+{
+	int retval = 0;
+	return retval;
+}
+
+
+int alf_config_tx(struct alx_hw *hw)
+{
+	u32 wrr;
+	int retval = 0;
+
+	HW_PRINT(DEBUG, "ENTER\n");
+
+	MEM_R32(hw, L1F_WRR, &wrr);
+	switch (hw->wrr_mode) {
+	case alx_wrr_mode_none:
+		FIELD_SETL(wrr, L1F_WRR_PRI, L1F_WRR_PRI_RESTRICT_NONE);
+		break;
+	case alx_wrr_mode_high:
+		FIELD_SETL(wrr, L1F_WRR_PRI, L1F_WRR_PRI_RESTRICT_HI);
+		break;
+	case alx_wrr_mode_high2:
+		FIELD_SETL(wrr, L1F_WRR_PRI, L1F_WRR_PRI_RESTRICT_HI2);
+		break;
+	case alx_wrr_mode_all:
+		FIELD_SETL(wrr, L1F_WRR_PRI, L1F_WRR_PRI_RESTRICT_ALL);
+		break;
+	}
+	FIELD_SETL(wrr, L1F_WRR_PRI0, hw->wrr_prio0);
+	FIELD_SETL(wrr, L1F_WRR_PRI1, hw->wrr_prio1);
+	FIELD_SETL(wrr, L1F_WRR_PRI2, hw->wrr_prio2);
+	FIELD_SETL(wrr, L1F_WRR_PRI3, hw->wrr_prio3);
+	MEM_W32(hw, L1F_WRR, wrr);
+
+	return retval;
+}
+
+
+int alf_config_msix(struct alx_hw *hw, u16 num_intrs,
+		    bool msix_en, bool msi_en)
+{
+	u32 map[2];
+	u32 type;
+	int msix_idx;
+	int retval = 0;
+
+	HW_PRINT(DEBUG, "ENTER\n");
+
+	if (!msix_en)
+		goto configure_legacy;
+
+	memset(map, 0, sizeof(map));
+	for (msix_idx = 0; msix_idx < num_intrs; msix_idx++) {
+		switch (msix_idx) {
+		case ALF_MSIX_INDEX_RXQ0:
+			FIELD_SETL(map[0], L1F_MSI_MAP_TBL1_RXQ0,
+				   ALF_MSIX_INDEX_RXQ0);
+			break;
+		case ALF_MSIX_INDEX_RXQ1:
+			FIELD_SETL(map[0], L1F_MSI_MAP_TBL1_RXQ1,
+				   ALF_MSIX_INDEX_RXQ1);
+			break;
+		case ALF_MSIX_INDEX_RXQ2:
+			FIELD_SETL(map[0], L1F_MSI_MAP_TBL1_RXQ2,
+				   ALF_MSIX_INDEX_RXQ2);
+			break;
+		case ALF_MSIX_INDEX_RXQ3:
+			FIELD_SETL(map[0], L1F_MSI_MAP_TBL1_RXQ3,
+				   ALF_MSIX_INDEX_RXQ3);
+			break;
+		case ALF_MSIX_INDEX_RXQ4:
+			FIELD_SETL(map[1], L1F_MSI_MAP_TBL2_RXQ4,
+				   ALF_MSIX_INDEX_RXQ4);
+			break;
+		case ALF_MSIX_INDEX_RXQ5:
+			FIELD_SETL(map[1], L1F_MSI_MAP_TBL2_RXQ5,
+				   ALF_MSIX_INDEX_RXQ5);
+			break;
+		case ALF_MSIX_INDEX_RXQ6:
+			FIELD_SETL(map[1], L1F_MSI_MAP_TBL2_RXQ6,
+				   ALF_MSIX_INDEX_RXQ6);
+			break;
+		case ALF_MSIX_INDEX_RXQ7:
+			FIELD_SETL(map[1], L1F_MSI_MAP_TBL2_RXQ7,
+				   ALF_MSIX_INDEX_RXQ7);
+			break;
+		case ALF_MSIX_INDEX_TXQ0:
+			FIELD_SETL(map[0], L1F_MSI_MAP_TBL1_TXQ0,
+				   ALF_MSIX_INDEX_TXQ0);
+			break;
+		case ALF_MSIX_INDEX_TXQ1:
+			FIELD_SETL(map[0], L1F_MSI_MAP_TBL1_TXQ1,
+				   ALF_MSIX_INDEX_TXQ1);
+			break;
+		case ALF_MSIX_INDEX_TXQ2:
+			FIELD_SETL(map[1], L1F_MSI_MAP_TBL2_TXQ2,
+				   ALF_MSIX_INDEX_TXQ2);
+			break;
+		case ALF_MSIX_INDEX_TXQ3:
+			FIELD_SETL(map[1], L1F_MSI_MAP_TBL2_TXQ3,
+				   ALF_MSIX_INDEX_TXQ3);
+			break;
+		case ALF_MSIX_INDEX_TIMER:
+			FIELD_SETL(map[0], L1F_MSI_MAP_TBL1_TIMER,
+				   ALF_MSIX_INDEX_TIMER);
+			break;
+		case ALF_MSIX_INDEX_ALERT:
+			FIELD_SETL(map[0], L1F_MSI_MAP_TBL1_ALERT,
+				   ALF_MSIX_INDEX_ALERT);
+			break;
+		case ALF_MSIX_INDEX_SMB:
+			FIELD_SETL(map[1], L1F_MSI_MAP_TBL2_SMB,
+				   ALF_MSIX_INDEX_SMB);
+			break;
+		case ALF_MSIX_INDEX_PHY:
+			FIELD_SETL(map[1], L1F_MSI_MAP_TBL2_PHY,
+				   ALF_MSIX_INDEX_PHY);
+			break;
+		default:
+			break;
+
+		}
+
+	}
+
+	MEM_W32(hw, L1F_MSI_MAP_TBL1, map[0]);
+	MEM_W32(hw, L1F_MSI_MAP_TBL2, map[1]);
+
+	/* 0 to alert, 1 to timer */
+	type = (L1F_MSI_ID_MAP_DMAW |
+		L1F_MSI_ID_MAP_DMAR |
+		L1F_MSI_ID_MAP_PCIELNKDW |
+		L1F_MSI_ID_MAP_PCIECERR |
+		L1F_MSI_ID_MAP_PCIENFERR |
+		L1F_MSI_ID_MAP_PCIEFERR |
+		L1F_MSI_ID_MAP_PCIEUR);
+
+	MEM_W32(hw, L1F_MSI_ID_MAP, type);
+	return retval;
+
+configure_legacy:
+	MEM_W32(hw, L1F_MSI_MAP_TBL1, 0x0);
+	MEM_W32(hw, L1F_MSI_MAP_TBL2, 0x0);
+	MEM_W32(hw, L1F_MSI_ID_MAP, 0x0);
+	if (msi_en) {
+		u32 msi;
+		MEM_R32(hw, 0x1920, &msi);
+		msi |= 0x10000;
+		MEM_W32(hw, 0x1920, msi);
+	}
+	return retval;
+}
+
+/*
+ * Interrupt
+ */
+
+int alf_ack_phy_intr(struct alx_hw *hw)
+{
+	int retval = 0;
+	u16 isr = 0;
+
+	HW_PRINT(DEBUG, "ENTER\n");
+
+	retval = alf_read_phy_reg(hw, ALX_MDIO_NORM_DEV,
+				  L1F_MII_ISR, &isr);
+	return retval;
+}
+int alf_enable_legacy_intr(struct alx_hw *hw)
+{
+	int retval = 0;
+	u16 cmd;
+
+	HW_PRINT(DEBUG, "ENTER\n");
+
+	CFG_R16(hw, L1F_PCI_CMD, &cmd);
+	cmd &= ~L1F_PCI_CMD_DISINT;
+	CFG_W16(hw, L1F_PCI_CMD, cmd);
+
+	MEM_W32(hw, L1F_ISR, ~L1F_ISR_DIS);
+	MEM_W32(hw, L1F_IMR, hw->intr_mask);
+
+	return retval;
+}
+
+int alf_disable_legacy_intr(struct alx_hw *hw)
+{
+	int retval = 0;
+
+	HW_PRINT(DEBUG, "ENTER\n");
+
+	MEM_W32(hw, L1F_ISR, L1F_ISR_DIS);
+	MEM_W32(hw, L1F_IMR, 0);
+
+	MEM_FLUSH(hw);
+	return retval;
+}
+
+
+int alf_enable_msix_intr(struct alx_hw *hw, u8 entry_idx)
+{
+	u32 ctrl_reg;
+	u32 ctrl_val = 0x0;
+	int retval = 0;
+
+	HW_PRINT(DEBUG, "ENTER\n");
+
+	ctrl_reg = ALF_MSIX_ENTRY_BASE + (entry_idx * ALF_MSIX_ENTRY_SIZE) +
+		   ALF_MSIX_MSG_CTRL_OFF;
+
+	MEM_W32(hw, ctrl_reg, ctrl_val);
+	MEM_FLUSH(hw);
+	return retval;
+}
+
+int alf_disable_msix_intr(struct alx_hw *hw, u8 entry_idx)
+{
+	u32 ctrl_reg;
+	u32 ctrl_val = 0x1;
+	int retval = 0;
+
+	HW_PRINT(DEBUG, "ENTER\n");
+
+	ctrl_reg = ALF_MSIX_ENTRY_BASE + (entry_idx * ALF_MSIX_ENTRY_SIZE) +
+		   ALF_MSIX_MSG_CTRL_OFF;
+
+	MEM_W32(hw, ctrl_reg, ctrl_val);
+	MEM_FLUSH(hw);
+	return retval;
+}
+
+
+
+/* RSS */
+int alf_config_rss(struct alx_hw *hw, bool rss_en)
+{
+	int key_len_by_u8 = sizeof(hw->rss_key);
+	int idt_len_by_u32 = sizeof(hw->rss_idt) / sizeof(u32);
+	u32 rxq0;
+	int i;
+	int retval = 0;
+
+	HW_PRINT(DEBUG, "ENTER\n");
+
+	/* Fill out hash function keys */
+	for (i = 0; i < key_len_by_u8; i++) {
+		MEM_W8(hw, ALF_RSS_KEY(i, u8),
+			hw->rss_key[key_len_by_u8 - i - 1]);
+	}
+
+	/* Fill out redirection table */
+	for (i = 0; i < idt_len_by_u32; i++) {
+		MEM_W32(hw, ALF_RSS_TBL(i, u32),
+			hw->rss_idt[i]);
+	}
+
+	MEM_W32(hw, L1F_RSS_BASE_CPU_NUM, hw->rss_base_cpu);
+
+	MEM_R32(hw, L1F_RXQ0, &rxq0);
+	if (hw->rss_hstype & ALX_RSS_HSTYP_IPV4_EN)
+		rxq0 |=  L1F_RXQ0_RSS_HSTYP_IPV4_EN;
+	else
+		rxq0 &=  ~L1F_RXQ0_RSS_HSTYP_IPV4_EN;
+
+	if (hw->rss_hstype & ALX_RSS_HSTYP_TCP4_EN)
+		rxq0 |=  L1F_RXQ0_RSS_HSTYP_IPV4_TCP_EN;
+	else
+		rxq0 &=  ~L1F_RXQ0_RSS_HSTYP_IPV4_TCP_EN;
+
+	if (hw->rss_hstype & ALX_RSS_HSTYP_IPV6_EN)
+		rxq0 |=  L1F_RXQ0_RSS_HSTYP_IPV6_EN;
+	else
+		rxq0 &=  ~L1F_RXQ0_RSS_HSTYP_IPV6_EN;
+
+	if (hw->rss_hstype & ALX_RSS_HSTYP_TCP6_EN)
+		rxq0 |=  L1F_RXQ0_RSS_HSTYP_IPV6_TCP_EN;
+	else
+		rxq0 &=  ~L1F_RXQ0_RSS_HSTYP_IPV6_TCP_EN;
+
+	FIELD_SETL(rxq0, L1F_RXQ0_RSS_MODE, hw->rss_mode);
+	FIELD_SETL(rxq0, L1F_RXQ0_IDT_TBL_SIZE, hw->rss_idt_size);
+
+	if (rss_en)
+		rxq0 |= L1F_RXQ0_RSS_HASH_EN;
+	else
+		rxq0 &= ~L1F_RXQ0_RSS_HASH_EN;
+
+	MEM_W32(hw, L1F_RXQ0, rxq0);
+	return retval;
+}
+
+/* fc */
+static int alf_get_fc_mode(struct alx_hw *hw, enum alx_fc_mode *mode)
+{
+	u16 bmsr, giga;
+	int i;
+	int retval = 0;
+
+	for (i = 0; i < ALX_MAX_SETUP_LNK_CYCLE; i++) {
+		__MS_DELAY(100);
+		alf_read_phy_reg(hw, ALX_MDIO_NORM_DEV, L1F_MII_BMSR, &bmsr);
+		alf_read_phy_reg(hw, ALX_MDIO_NORM_DEV, L1F_MII_BMSR, &bmsr);
+		if (bmsr & L1F_BMSR_LINK_STATUS) {
+			/* Read phy Specific Status Register (17) */
+			retval = alf_read_phy_reg(hw, ALX_MDIO_NORM_DEV,
+					L1F_MII_GIGA_PSSR, &giga);
+			if (retval)
+				return retval;
+
+			if (!(giga & L1F_GIGA_PSSR_SPD_DPLX_RESOLVED))
+				return ALX_ERR_PHY_RESOLVED;
+
+			if ((giga & L1F_GIGA_PSSR_FC_TXEN) &&
+			    (giga & L1F_GIGA_PSSR_FC_RXEN)) {
+				*mode = alx_fc_full;
+			} else if (giga & L1F_GIGA_PSSR_FC_TXEN) {
+				*mode = alx_fc_tx_pause;
+			} else if (giga & L1F_GIGA_PSSR_FC_RXEN) {
+				*mode = alx_fc_rx_pause;
+			} else {
+				*mode = alx_fc_none;
+			}
+			break;
+		}
+	}
+
+	if (i == ALX_MAX_SETUP_LNK_CYCLE)
+		retval = ALX_ERR_PHY_SETUP_LNK;
+	return retval;
+}
+
+int alf_config_fc(struct alx_hw *hw)
+{
+	u32 mac;
+	int retval = 0;
+
+	HW_PRINT(DEBUG, "ENTER\n");
+
+	if (hw->disable_fc_autoneg) {
+		hw->fc_was_autonegged = false;
+		hw->cur_fc_mode = hw->req_fc_mode;
+	} else {
+		hw->fc_was_autonegged = true;
+		retval = alf_get_fc_mode(hw, &hw->cur_fc_mode);
+		if (retval)
+			return retval;
+	}
+
+	MEM_R32(hw, L1F_MAC_CTRL, &mac);
+
+	switch (hw->cur_fc_mode) {
+	case alx_fc_none: /* 0 */
+		mac &= ~(L1F_MAC_CTRL_RXFC_EN | L1F_MAC_CTRL_TXFC_EN);
+		break;
+	case alx_fc_rx_pause: /* 1 */
+		mac &= ~L1F_MAC_CTRL_TXFC_EN;
+		mac |= L1F_MAC_CTRL_RXFC_EN;
+		break;
+	case alx_fc_tx_pause: /* 2 */
+		mac |= L1F_MAC_CTRL_TXFC_EN;
+		mac &= ~L1F_MAC_CTRL_RXFC_EN;
+		break;
+	case alx_fc_full: /* 3 */
+	case alx_fc_default: /* 4 */
+		mac |= (L1F_MAC_CTRL_TXFC_EN | L1F_MAC_CTRL_RXFC_EN);
+		break;
+	default:
+		HW_PRINT(ERR, "Flow control param set incorrectly\n");
+		retval = ALX_ERR_FLOW_CONTROL;
+		break;
+	}
+
+	MEM_W32(hw, L1F_MAC_CTRL, mac);
+
+	return retval;
+}
+
+
+/*
+ * NVRam
+ */
+int alf_check_nvram(struct alx_hw *hw, bool *exist)
+{
+	*exist = false;
+	return 0;
+}
+
+
+/* ethtool */
+int alf_get_ethtool_regs(struct alx_hw *hw, void *buff)
+{
+	u32 *regs = (u32 *)buff;
+	int i;
+	int retval = 0;
+
+	MEM_R32(hw, L1F_PM_CSR,     &regs[0]);
+	MEM_R32(hw, L1F_DEV_CAP,    &regs[1]);
+	MEM_R32(hw, L1F_DEV_CTRL,   &regs[2]);
+	MEM_R32(hw, L1F_LNK_CAP,    &regs[3]);
+	MEM_R32(hw, L1F_LNK_CTRL,   &regs[4]);
+	MEM_R32(hw, L1F_UE_SVRT,    &regs[5]);
+	MEM_R32(hw, L1F_EFLD,       &regs[6]);
+	MEM_R32(hw, L1F_SLD,        &regs[7]);
+	MEM_R32(hw, L1F_PPHY_MISC1, &regs[8]);
+	MEM_R32(hw, L1F_PPHY_MISC2, &regs[9]);
+
+	MEM_R32(hw, L1F_PDLL_TRNS1,   &regs[10]);
+	MEM_R32(hw, L1F_TLEXTN_STATS, &regs[11]);
+	MEM_R32(hw, L1F_EFUSE_CTRL,   &regs[12]);
+	MEM_R32(hw, L1F_EFUSE_DATA,   &regs[13]);
+	MEM_R32(hw, L1F_SPI_OP1,      &regs[14]);
+	MEM_R32(hw, L1F_SPI_OP2,      &regs[15]);
+	MEM_R32(hw, L1F_SPI_OP3,      &regs[16]);
+	MEM_R32(hw, L1F_EF_CTRL,      &regs[17]);
+	MEM_R32(hw, L1F_EF_ADDR,      &regs[18]);
+	MEM_R32(hw, L1F_EF_DATA,      &regs[19]);
+
+	MEM_R32(hw, L1F_SPI_ID,         &regs[20]);
+	MEM_R32(hw, L1F_SPI_CFG_START,  &regs[21]);
+	MEM_R32(hw, L1F_PMCTRL,         &regs[22]);
+	MEM_R32(hw, L1F_LTSSM_CTRL,     &regs[23]);
+	MEM_R32(hw, L1F_MASTER,         &regs[24]);
+	MEM_R32(hw, L1F_MANU_TIMER,     &regs[25]);
+	MEM_R32(hw, L1F_IRQ_MODU_TIMER, &regs[26]);
+	MEM_R32(hw, L1F_PHY_CTRL,       &regs[27]);
+	MEM_R32(hw, L1F_MAC_STS,        &regs[28]);
+	MEM_R32(hw, L1F_MDIO,           &regs[29]);
+
+	MEM_R32(hw, L1F_MDIO_EXTN,   &regs[30]);
+	MEM_R32(hw, L1F_PHY_STS,     &regs[31]);
+	MEM_R32(hw, L1F_BIST0,       &regs[32]);
+	MEM_R32(hw, L1F_BIST1,       &regs[33]);
+	MEM_R32(hw, L1F_SERDES,      &regs[34]);
+	MEM_R32(hw, L1F_LED_CTRL,    &regs[35]);
+	MEM_R32(hw, L1F_LED_PATN,    &regs[36]);
+	MEM_R32(hw, L1F_LED_PATN2,   &regs[37]);
+	MEM_R32(hw, L1F_SYSALV,      &regs[38]);
+	MEM_R32(hw, L1F_PCIERR_INST, &regs[39]);
+
+	MEM_R32(hw, L1F_LPI_DECISN_TIMER, &regs[40]);
+	MEM_R32(hw, L1F_LPI_CTRL,         &regs[41]);
+	MEM_R32(hw, L1F_LPI_WAIT,         &regs[42]);
+	MEM_R32(hw, L1F_HRTBT_VLAN,       &regs[43]);
+	MEM_R32(hw, L1F_HRTBT_CTRL,       &regs[44]);
+	MEM_R32(hw, L1F_RXPARSE,          &regs[45]);
+	MEM_R32(hw, L1F_MAC_CTRL,         &regs[46]);
+	MEM_R32(hw, L1F_GAP,              &regs[47]);
+	MEM_R32(hw, L1F_STAD1,            &regs[48]);
+	MEM_R32(hw, L1F_LED_CTRL,         &regs[49]);
+
+	MEM_R32(hw, L1F_HASH_TBL0, &regs[50]);
+	MEM_R32(hw, L1F_HASH_TBL1, &regs[51]);
+	MEM_R32(hw, L1F_HALFD,     &regs[52]);
+	MEM_R32(hw, L1F_DMA,       &regs[53]);
+	MEM_R32(hw, L1F_WOL0,      &regs[54]);
+	MEM_R32(hw, L1F_WOL1,      &regs[55]);
+	MEM_R32(hw, L1F_WOL2,      &regs[56]);
+	MEM_R32(hw, L1F_WRR,       &regs[57]);
+	MEM_R32(hw, L1F_HQTPD,     &regs[58]);
+	MEM_R32(hw, L1F_CPUMAP1,   &regs[59]);
+	MEM_R32(hw, L1F_CPUMAP2,   &regs[60]);
+	MEM_R32(hw, L1F_MISC,      &regs[61]);
+
+	/* SRAM */
+	for (i = 0; i < 16; i++)
+		MEM_R32(hw, ALF_SRAM(i, u32), &regs[80 + i]);
+
+	/* RTX DESC */
+	MEM_R32(hw, L1F_RX_BASE_ADDR_HI, &regs[100]);
+	MEM_R32(hw, L1F_RFD_ADDR_LO,     &regs[101]);
+	MEM_R32(hw, L1F_RFD_RING_SZ,     &regs[102]);
+	MEM_R32(hw, L1F_RFD_BUF_SZ,      &regs[103]);
+	MEM_R32(hw, L1F_RRD_ADDR_LO,     &regs[104]);
+	MEM_R32(hw, L1F_RRD_RING_SZ,     &regs[105]);
+	MEM_R32(hw, L1F_RFD_PIDX,        &regs[106]);
+	MEM_R32(hw, L1F_RFD_CIDX,        &regs[107]);
+	MEM_R32(hw, L1F_RXQ0,            &regs[108]);
+	MEM_R32(hw, L1F_RXQ1,            &regs[109]);
+	MEM_R32(hw, L1F_RXQ2,            &regs[110]);
+	MEM_R32(hw, L1F_RXQ3,            &regs[111]);
+
+	MEM_R32(hw, L1F_TX_BASE_ADDR_HI,  &regs[112]);
+	MEM_R32(hw, L1F_TPD_PRI0_ADDR_LO, &regs[113]);
+	MEM_R32(hw, L1F_TPD_PRI1_ADDR_LO, &regs[114]);
+	MEM_R32(hw, L1F_TPD_PRI2_ADDR_LO, &regs[115]);
+	MEM_R32(hw, L1F_TPD_PRI3_ADDR_LO, &regs[116]);
+	MEM_R32(hw, L1F_TPD_PRI0_PIDX,    &regs[117]);
+	MEM_R32(hw, L1F_TPD_PRI1_PIDX,    &regs[118]);
+	MEM_R32(hw, L1F_TPD_PRI2_PIDX,    &regs[119]);
+	MEM_R32(hw, L1F_TPD_PRI3_PIDX,    &regs[120]);
+	MEM_R32(hw, L1F_TPD_PRI0_CIDX,    &regs[121]);
+	MEM_R32(hw, L1F_TPD_PRI1_CIDX,    &regs[122]);
+	MEM_R32(hw, L1F_TPD_PRI2_CIDX,    &regs[123]);
+	MEM_R32(hw, L1F_TPD_PRI3_CIDX,    &regs[124]);
+	MEM_R32(hw, L1F_TPD_RING_SZ,      &regs[125]);
+	MEM_R32(hw, L1F_TXQ0,             &regs[126]);
+	MEM_R32(hw, L1F_TXQ1,             &regs[127]);
+	MEM_R32(hw, L1F_TXQ2,             &regs[128]);
+
+	/* MSI, MSIX*/
+	MEM_R32(hw, L1F_MSI_MAP_TBL1, &regs[130]);
+	MEM_R32(hw, L1F_MSI_MAP_TBL2, &regs[131]);
+	MEM_R32(hw, L1F_MSI_ID_MAP,   &regs[132]);
+	MEM_R32(hw, L1F_MSIX_MASK,    &regs[133]);
+	MEM_R32(hw, L1F_MSIX_PENDING, &regs[134]);
+
+	/* RSS */
+	for (i = 0; i < 10; i++)
+		MEM_R32(hw, ALF_RSS_KEY(i, u32), &regs[140 + i]);
+	for (i = 0; i < 32; i++)
+		MEM_R32(hw, ALF_RSS_TBL(i, u32), &regs[150 + i]);
+	MEM_R32(hw, L1F_RSS_HASH_VAL,     &regs[182]);
+	MEM_R32(hw, L1F_RSS_HASH_FLAG,    &regs[183]);
+	MEM_R32(hw, L1F_RSS_BASE_CPU_NUM, &regs[184]);
+
+	/* MIB */
+	for (i = 0; i < 48; i++)
+		MEM_R32(hw, ALF_MIB(i, u32), &regs[190 + i]);
+
+	return retval;
+}
+
+/******************************************************************************/
+
+static int alf_set_hw_capabilities(struct alx_hw *hw)
+{
+	u32 link;
+	int retval = 0;
+
+	MEM_R32(hw, L1F_LNK_CTRL, &link);
+	if (link & L1F_LNK_CTRL_ASPM_ENL0S)
+		SET_HW_FLAG(L0S_CAP);
+	if (link & L1F_LNK_CTRL_ASPM_ENL1)
+		SET_HW_FLAG(L1_CAP);
+
+	if (hw->mac_type == alx_mac_l1f)
+		SET_HW_FLAG(GIGA_CAP);
+
+	/* set flags of alx_phy_info */
+	SET_HW_FLAG(PWSAVE_CAP);
+	return retval;
+}
+
+
+/* alc_set_hw_info */
+static int alf_set_hw_infos(struct alx_hw *hw)
+{
+	int retval = 0;
+
+	hw->rxstat_reg = L1F_MIB_RX_OK;
+	hw->rxstat_sz = 0x60;
+	hw->txstat_reg = L1F_MIB_TX_OK;
+	hw->txstat_sz = 0x68;
+
+	hw->rx_prod_reg[0] = L1F_RFD_PIDX;
+	hw->rx_cons_reg[0] = L1F_RFD_CIDX;
+
+	hw->tx_prod_reg[0] = L1F_TPD_PRI0_PIDX;
+	hw->tx_cons_reg[0] = L1F_TPD_PRI0_CIDX;
+	hw->tx_prod_reg[1] = L1F_TPD_PRI1_PIDX;
+	hw->tx_cons_reg[1] = L1F_TPD_PRI1_CIDX;
+	hw->tx_prod_reg[2] = L1F_TPD_PRI2_PIDX;
+	hw->tx_cons_reg[2] = L1F_TPD_PRI2_CIDX;
+	hw->tx_prod_reg[3] = L1F_TPD_PRI3_PIDX;
+	hw->tx_cons_reg[3] = L1F_TPD_PRI3_CIDX;
+
+	hw->hwreg_sz = 0x200;
+	hw->eeprom_sz = 0;
+
+	return retval;
+}
+
+/*
+ *  alf_init_hw_callbacks
+ */
+int alf_init_hw_callbacks(struct alx_hw *hw)
+{
+	int retval = 0;
+
+	/* NIC */
+	hw->cbs.identify_nic   = &alf_identify_nic;
+	/* MAC */
+	hw->cbs.reset_mac      = &alf_reset_mac;
+	hw->cbs.start_mac      = &alf_start_mac;
+	hw->cbs.stop_mac       = &alf_stop_mac;
+	hw->cbs.config_mac     = &alf_config_mac;
+	hw->cbs.get_mac_addr   = &alf_get_mac_addr;
+	hw->cbs.set_mac_addr   = &alf_set_mac_addr;
+	hw->cbs.clear_mac_addr = &alf_clear_mac_addr;
+	hw->cbs.set_mc_addr    = &alf_set_mc_addr;
+	hw->cbs.clear_mc_addr  = &alf_clear_mc_addr;
+
+	/* PHY */
+	hw->cbs.init_phy       = &alf_init_phy;
+	hw->cbs.reset_phy      = &alf_reset_phy;
+	hw->cbs.read_phy_reg   = &alf_read_phy_reg;
+	hw->cbs.write_phy_reg  = &alf_write_phy_reg;
+	hw->cbs.check_phy_link = &alf_check_phy_link;
+	hw->cbs.setup_phy_link = &alf_setup_phy_link;
+	hw->cbs.setup_phy_link_speed = &alf_setup_phy_link_speed;
+
+	/* Interrupt */
+	hw->cbs.ack_phy_intr		= &alf_ack_phy_intr;
+	hw->cbs.enable_legacy_intr	= &alf_enable_legacy_intr;
+	hw->cbs.disable_legacy_intr	= &alf_disable_legacy_intr;
+	hw->cbs.enable_msix_intr	= &alf_enable_msix_intr;
+	hw->cbs.disable_msix_intr	= &alf_disable_msix_intr;
+
+	/* Configure */
+	hw->cbs.config_rx	= &alf_config_rx;
+	hw->cbs.config_tx	= &alf_config_tx;
+	hw->cbs.config_fc	= &alf_config_fc;
+	hw->cbs.config_rss	= &alf_config_rss;
+	hw->cbs.config_msix	= &alf_config_msix;
+	hw->cbs.config_wol	= &alf_config_wol;
+	hw->cbs.config_aspm	= &alf_config_aspm;
+	hw->cbs.config_mac_ctrl	= &alf_config_mac_ctrl;
+	hw->cbs.config_pow_save	= &alf_config_pow_save;
+	hw->cbs.reset_pcie	= &alf_reset_pcie;
+
+	/* NVRam */
+	hw->cbs.check_nvram	= &alf_check_nvram;
+
+	/* Others */
+	hw->cbs.get_ethtool_regs = alf_get_ethtool_regs;
+
+	retval = alf_set_hw_capabilities(hw);
+
+	retval = alf_set_hw_infos(hw);
+
+	/* print hw flags */
+	HW_PRINT(INFO, "HW Flags = 0x%x\n", hw->flags);
+	return retval;
+}
+
diff --git a/drivers/net/ethernet/atheros/alx/alf_hw.c b/drivers/net/ethernet/atheros/alx/alf_hw.c
new file mode 100755
index 0000000..b696439
--- /dev/null
+++ b/drivers/net/ethernet/atheros/alx/alf_hw.c
@@ -0,0 +1,1143 @@
+/*
+ * Copyright (c) 2010 - 2011 Atheros Communications Inc.
+ *
+ * Permission to use, copy, modify, and/or distribute this software for any
+ * purpose with or without fee is hereby granted, provided that the above
+ * copyright notice and this permission notice appear in all copies.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
+ * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
+ * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
+ * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
+ * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
+ * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ */
+
+#include "alf_hw.h"
+
+
+
+
+/* get permanent mac address from
+ *    0: success
+ *    non-0:fail
+ */
+u16 l1f_get_perm_macaddr(PETHCONTEXT ctx, u8 *addr)
+{
+	u32 val, mac0, mac1;
+	u16 flag, i;
+
+#define INTN_LOADED 0x1
+#define EXTN_LOADED 0x2
+
+	flag = 0;
+	val = 0;
+
+read_mcadr:
+
+	/* get it from register first */
+	MEM_R32(ctx, L1F_STAD0, &mac0);
+	MEM_R32(ctx, L1F_STAD1, &mac1);
+
+	*(u32 *)(addr + 2) = LX_SWAP_DW(mac0);
+	*(u16 *)addr = (u16)LX_SWAP_W((u16)mac1);
+	if (macaddr_valid(addr)) {
+		return 0;
+	}
+
+
+	if (0 == (flag & INTN_LOADED)) {
+		/* load from efuse ? */
+		for (i = 0; i < L1F_SLD_MAX_TO; i++) {
+			MEM_R32(ctx, L1F_SLD, &val);
+			if (0 == (val & (L1F_SLD_STAT | L1F_SLD_START))) {
+				break;
+			}
+			MS_DELAY(ctx, 1);
+		}
+		if (i == L1F_SLD_MAX_TO) {
+			goto sw_assign;
+		}
+		MEM_W32(ctx, L1F_SLD, val | L1F_SLD_START);
+		for (i = 0; i < L1F_SLD_MAX_TO; i++) {
+			MS_DELAY(ctx, 1);
+			MEM_R32(ctx, L1F_SLD, &val);
+			if (0 == (val & L1F_SLD_START)) {
+				break;
+			}
+		}
+		if (i == L1F_SLD_MAX_TO) {
+			goto sw_assign;
+		}
+		flag |= INTN_LOADED;
+		goto read_mcadr;
+	}
+
+	if (0 == (flag & EXTN_LOADED)) {
+		MEM_R32(ctx, L1F_EFLD, &val);
+		if (0 != (val & (L1F_EFLD_F_EXIST | L1F_EFLD_E_EXIST))) {
+			/* load from eeprom/flash ? */
+			for (i = 0; i < L1F_SLD_MAX_TO; i++) {
+				MEM_R32(ctx, L1F_EFLD, &val);
+				if (0 == (val & (L1F_EFLD_STAT |
+						 L1F_EFLD_START))) {
+					break;
+				}
+				MS_DELAY(ctx, 1);
+			}
+			if (i == L1F_SLD_MAX_TO) {
+				goto sw_assign;
+			}
+			MEM_W32(ctx, L1F_EFLD, val | L1F_EFLD_START);
+			for (i = 0; i < L1F_SLD_MAX_TO; i++) {
+				MS_DELAY(ctx, 1);
+				MEM_R32(ctx, L1F_EFLD, &val);
+				if (0 == (val & L1F_EFLD_START)) {
+					break;
+				}
+			}
+			if (i == L1F_SLD_MAX_TO) {
+				goto sw_assign;
+			}
+			flag |= EXTN_LOADED;
+			goto read_mcadr;
+		}
+	}
+
+sw_assign:
+	/* assign a fixed one */
+	*(u32 *)(addr + 2) = 0x00000074UL;
+	*(u16 *)addr = 0x1300;
+
+	return LX_ERR_ALOAD;
+}
+
+
+/* reset mac & dma
+ * return
+ *     0: success
+ *     non-0:fail
+ */
+u16 l1f_reset_mac(PETHCONTEXT ctx)
+{
+	u32 val, pmctrl = 0;
+	u16 ret;
+	u16 i;
+	u8 rev = (u8)(FIELD_GETX(ctx->pci_revid, L1F_PCI_REVID));
+
+	/* disable all interrupts, RXQ/TXQ */
+	MEM_W32(ctx, L1F_MSIX_MASK, ALL_32_BITS); /* ???? msi-x */
+	MEM_W32(ctx, L1F_IMR, 0);
+	MEM_W32(ctx, L1F_ISR, L1F_ISR_DIS);
+
+	ret = l1f_enable_mac(ctx, false, 0);
+	if (0 != ret) {
+		return ret;
+	}
+
+	/* mac reset workaroud */
+	MEM_W32(ctx, L1F_RFD_PIDX, 1);
+
+	/* dis l0s/l1 before mac reset */
+	if ((rev == L1F_REV_A0 || rev == L1F_REV_A1) &&
+	    0 != (ctx->pci_revid & L1F_PCI_REVID_WTH_CR)) {
+		MEM_R32(ctx, L1F_PMCTRL, &pmctrl);
+		if (0 != (pmctrl & (L1F_PMCTRL_L1_EN | L1F_PMCTRL_L0S_EN))) {
+			MEM_W32(ctx, L1F_PMCTRL,
+			    pmctrl & ~(L1F_PMCTRL_L1_EN | L1F_PMCTRL_L0S_EN));
+		}
+	}
+
+	/* reset whole mac safely */
+	MEM_R32(ctx, L1F_MASTER, &val);
+	MEM_W32(ctx, L1F_MASTER,
+	    val | L1F_MASTER_DMA_MAC_RST | L1F_MASTER_OOB_DIS);
+
+	/* make sure it's real idle */
+	US_DELAY(ctx, 10);
+	for (i = 0; i < L1F_DMA_MAC_RST_TO; i++) {
+		MEM_R32(ctx, L1F_RFD_PIDX, &val);
+		if (0 == val) {
+			break;
+		}
+		US_DELAY(ctx, 10);
+	}
+	for (; i < L1F_DMA_MAC_RST_TO; i++) {
+		MEM_R32(ctx, L1F_MASTER, &val);
+		if (0 == (val & L1F_MASTER_DMA_MAC_RST)) {
+			break;
+		}
+		US_DELAY(ctx, 10);
+	}
+	if (i == L1F_DMA_MAC_RST_TO) {
+		return LX_ERR_RSTMAC;
+	}
+	US_DELAY(ctx, 10);
+
+	if ((rev == L1F_REV_A0 || rev == L1F_REV_A1) &&
+	    0 != (ctx->pci_revid & L1F_PCI_REVID_WTH_CR)) {
+		/* set L1F_MASTER_PCLKSEL_SRDS (affect by soft-rst, PERST) */
+		MEM_W32(ctx, L1F_MASTER, val | L1F_MASTER_PCLKSEL_SRDS);
+		/* resoter l0s / l1 */
+		if (0 != (pmctrl & (L1F_PMCTRL_L1_EN | L1F_PMCTRL_L0S_EN))) {
+			MEM_W32(ctx, L1F_PMCTRL, pmctrl);
+		}
+	}
+
+	/* clear Internal OSC settings, switching OSC by hw itself,
+	 * disable isoloate for A0 */
+	MEM_R32(ctx, L1F_MISC3, &val);
+	MEM_W32(ctx, L1F_MISC3,
+	    (val & ~L1F_MISC3_25M_BY_SW) | L1F_MISC3_25M_NOTO_INTNL);
+	MEM_R32(ctx, L1F_MISC, &val);
+	val &= ~L1F_MISC_INTNLOSC_OPEN;
+	if (rev == L1F_REV_A0 || rev == L1F_REV_A1) {
+		val &= ~L1F_MISC_ISO_EN;
+	}
+	MEM_W32(ctx, L1F_MISC, val);
+	US_DELAY(ctx, 20);
+
+	/* driver control speed/duplex, hash-alg */
+	MEM_R32(ctx, L1F_MAC_CTRL, &val);
+	MEM_W32(ctx, L1F_MAC_CTRL, val | L1F_MAC_CTRL_WOLSPED_SWEN);
+
+	/* clk sw */
+	MEM_R32(ctx, L1F_SERDES, &val);
+	MEM_W32(ctx, L1F_SERDES,
+	    val | L1F_SERDES_MACCLK_SLWDWN | L1F_SERDES_PHYCLK_SLWDWN);
+
+	return 0;
+}
+
+/* reset phy
+ * return
+ *    0: success
+ *    non-0:fail
+ */
+u16 l1f_reset_phy(PETHCONTEXT ctx, bool pws_en, bool az_en, bool ptp_en)
+{
+	u32 val;
+	u16 i, phy_val;
+
+	az_en = az_en;
+	ptp_en = ptp_en;
+
+	/* reset PHY core */
+	MEM_R32(ctx, L1F_PHY_CTRL, &val);
+	val &= ~(L1F_PHY_CTRL_DSPRST_OUT | L1F_PHY_CTRL_IDDQ |
+	    L1F_PHY_CTRL_GATE_25M | L1F_PHY_CTRL_POWER_DOWN |
+	    L1F_PHY_CTRL_CLS);
+	val |= L1F_PHY_CTRL_RST_ANALOG;
+
+	if (pws_en) {
+		val |= (L1F_PHY_CTRL_HIB_PULSE | L1F_PHY_CTRL_HIB_EN);
+	} else {
+		val &= ~(L1F_PHY_CTRL_HIB_PULSE | L1F_PHY_CTRL_HIB_EN);
+	}
+	MEM_W32(ctx, L1F_PHY_CTRL, val);
+	US_DELAY(ctx, 10); /* 5us is enough */
+	MEM_W32(ctx, L1F_PHY_CTRL, val | L1F_PHY_CTRL_DSPRST_OUT);
+
+	for (i = 0; i < L1F_PHY_CTRL_DSPRST_TO; i++) { /* delay 800us */
+		US_DELAY(ctx, 10);
+	}
+
+	/* ???? phy power saving */
+#if PHY_TYPE_F1 != PHY_TYPE
+	if (pws_en) {
+		l1f_write_phydbg(ctx, true, L1F_MIIDBG_LEGCYPS,
+		    L1F_LEGCYPS_DEF);
+		l1f_write_phydbg(ctx, true, L1F_MIIDBG_SYSMODCTRL,
+		    L1F_SYSMODCTRL_IECHOADJ_DEF);
+		l1f_write_phy(ctx, true, L1F_MIIEXT_PCS, true,
+		    L1F_MIIEXT_VDRVBIAS, L1F_VDRVBIAS_DEF);
+	} else {
+		l1f_write_phydbg(ctx, true, L1F_MIIDBG_LEGCYPS,
+		    L1F_LEGCYPS_DEF & ~L1F_LEGCYPS_EN);
+		l1f_write_phydbg(ctx, true, L1F_MIIDBG_HIBNEG,
+		    L1F_HIBNEG_DEF & ~(L1F_HIBNEG_PSHIB_EN |
+				       L1F_HIBNEG_HIB_PULSE));
+		l1f_write_phydbg(ctx, true,
+		    L1F_MIIDBG_GREENCFG, L1F_GREENCFG_DEF);
+	}
+#endif/* PHY_TYPE_F1 != PHY_TYPE */
+
+#if PHY_TYPE_F1 != PHY_TYPE
+
+	if (az_en) {
+		l1f_write_phy(ctx, true, L1F_MIIEXT_ANEG, true,
+		    L1F_MIIEXT_LOCAL_EEEADV, /* ?? Fast Eth */
+		    L1F_LOCAL_EEEADV_1000BT | L1F_LOCAL_EEEADV_100BT);
+		/* half amplify */
+		l1f_write_phydbg(ctx, true,
+		    L1F_MIIDBG_AZ_ANADECT, L1F_AZ_ANADECT_DEF);
+
+#if PHY_TYPE_FPGA == PHY_TYPE
+		l1f_write_phy(ctx, true, L1F_MIIEXT_PCS, true,
+		    L1F_MIIEXT_CLDCTRL7, 0x0005);
+		l1f_write_phy(ctx, true, L1F_MIIEXT_PCS, true,
+		    L1F_MIIEXT_AZCTRL, 0x101D);
+		l1f_write_phy(ctx, true, L1F_MIIEXT_PCS, true,
+		    L1F_MIIEXT_AZCTRL2, 0x40C8);
+#else
+		/* ???? */
+#endif/* PHY_TYPE_FPGA == PHY_TYPE */
+	} else {
+		MEM_R32(ctx, L1F_LPI_CTRL, &val);
+		MEM_W32(ctx, L1F_LPI_CTRL, val & ~L1F_LPI_CTRL_EN);
+		l1f_write_phy(ctx, true, L1F_MIIEXT_ANEG, true,
+		    L1F_MIIEXT_LOCAL_EEEADV, 0);
+	}
+
+#endif/* PHY_TYPE_F1 != PHY_TYPE */
+
+#if PHY_TYPE_ASIC == PHY_TYPE
+	l1f_write_phydbg(ctx, true,
+	    L1F_MIIDBG_TST10BTCFG, L1F_TST10BTCFG_DEF);
+	l1f_write_phydbg(ctx, true, L1F_MIIDBG_SRDSYSMOD, L1F_SRDSYSMOD_DEF);
+	l1f_write_phydbg(ctx, true,
+	    L1F_MIIDBG_TST100BTCFG, L1F_TST100BTCFG_DEF);
+	l1f_write_phydbg(ctx, true, L1F_MIIDBG_ANACTRL, L1F_ANACTRL_DEF);
+	l1f_read_phydbg(ctx, true, L1F_MIIDBG_GREENCFG2, &phy_val);
+	l1f_write_phydbg(ctx, true, L1F_MIIDBG_GREENCFG2,
+	    phy_val & ~L1F_GREENCFG2_GATE_DFSE_EN);
+#endif
+
+	/* set phy interrupt mask */
+	l1f_write_phy(ctx, false, 0, true,
+	    L1F_MII_IER, L1F_IER_LINK_UP | L1F_IER_LINK_DOWN);
+
+
+	/* TODO *****???? */
+	return 0;
+}
+
+
+/* reset pcie
+ * just reset pcie relative registers (pci command, clk, aspm...)
+ * return
+ *    0:success
+ *    non-0:fail
+ */
+u16 l1f_reset_pcie(PETHCONTEXT ctx, bool l0s_en, bool l1_en)
+{
+	u32 val;
+	u16 val16;
+	u16 ret;
+	u8 rev = (u8)(FIELD_GETX(ctx->pci_revid, L1F_PCI_REVID));
+
+	/* Workaround for PCI problem when BIOS sets MMRBC incorrectly. */
+	CFG_R16(ctx, L1F_PCI_CMD, &val16);
+	if (0 == (val16 & (L1F_PCI_CMD_IOEN |
+			   L1F_PCI_CMD_MEMEN |
+			   L1F_PCI_CMD_MASTEREN)) ||
+	    0 != (val16 & L1F_PCI_CMD_DISINT)) {
+		val16 = (u16)((val16 | (L1F_PCI_CMD_IOEN |
+					L1F_PCI_CMD_MEMEN |
+					L1F_PCI_CMD_MASTEREN))
+			      & ~L1F_PCI_CMD_DISINT);
+		CFG_W16(ctx, L1F_PCI_CMD, val16);
+	}
+
+	/* Clear any PowerSaving Settings */
+	CFG_W16(ctx, L1F_PM_CSR, 0);
+
+	/* deflt val of PDLL D3PLLOFF */
+	MEM_R32(ctx, L1F_PDLL_TRNS1, &val);
+	MEM_W32(ctx, L1F_PDLL_TRNS1, val & ~L1F_PDLL_TRNS1_D3PLLOFF_EN);
+
+	/* mask some pcie error bits */
+	MEM_R32(ctx, L1F_UE_SVRT, &val);
+	val &= ~(L1F_UE_SVRT_DLPROTERR | L1F_UE_SVRT_FCPROTERR);
+	MEM_W32(ctx, L1F_UE_SVRT, val);
+
+	/* wol 25M  & pclk */
+	MEM_R32(ctx, L1F_MASTER, &val);
+	if ((rev == L1F_REV_A0 || rev == L1F_REV_A1) &&
+	    0 != (ctx->pci_revid & L1F_PCI_REVID_WTH_CR)) {
+		if (0 == (val & L1F_MASTER_WAKEN_25M) ||
+		    0 == (val & L1F_MASTER_PCLKSEL_SRDS)) {
+			MEM_W32(ctx, L1F_MASTER, val | L1F_MASTER_PCLKSEL_SRDS |
+				L1F_MASTER_WAKEN_25M);
+		}
+	} else {
+		if (0 == (val & L1F_MASTER_WAKEN_25M) ||
+		    0 != (val & L1F_MASTER_PCLKSEL_SRDS)) {
+			MEM_W32(ctx, L1F_MASTER,
+			    (val & ~L1F_MASTER_PCLKSEL_SRDS) |
+			    L1F_MASTER_WAKEN_25M);
+		}
+	}
+
+#if 0
+	/* hi-perf ???? stable ????*/
+	MEM_R32(ctx, L1F_PPHY_MISC1, &val);
+	FIELD_SETL(val, L1F_PPHY_MISC1_NFTS, L1F_PPHY_MISC1_NFTS_HIPERF);
+	MEM_W32(ctx, L1F_PPHY_MISC1, val);
+#endif
+
+	/* l0s, l1 setting */
+	ret = l1f_enable_aspm(ctx, l0s_en, l1_en, 0);
+
+	US_DELAY(ctx, 10);
+
+	return ret;
+}
+
+
+/* disable/enable MAC/RXQ/TXQ
+ * en
+ *    true:enable
+ *    false:disable
+ * return
+ *    0:success
+ *    non-0-fail
+ */
+u16 l1f_enable_mac(PETHCONTEXT ctx, bool en, u16 en_ctrl)
+{
+	u32 rxq, txq, mac, val;
+	u16 i;
+
+	MEM_R32(ctx, L1F_RXQ0, &rxq);
+	MEM_R32(ctx, L1F_TXQ0, &txq);
+	MEM_R32(ctx, L1F_MAC_CTRL, &mac);
+
+	if (en) { /* enable */
+		MEM_W32(ctx, L1F_RXQ0, rxq | L1F_RXQ0_EN);
+		MEM_W32(ctx, L1F_TXQ0, txq | L1F_TXQ0_EN);
+		if (0 != (en_ctrl & LX_MACSPEED_1000)) {
+			FIELD_SETL(mac, L1F_MAC_CTRL_SPEED,
+			    L1F_MAC_CTRL_SPEED_1000);
+		} else {
+			FIELD_SETL(mac, L1F_MAC_CTRL_SPEED,
+			    L1F_MAC_CTRL_SPEED_10_100);
+		}
+		if (0 != (en_ctrl & LX_MACDUPLEX_FULL)) {
+			mac |= L1F_MAC_CTRL_FULLD;
+		} else {
+			mac &= ~L1F_MAC_CTRL_FULLD;
+		}
+		/* rx filter */
+		if (0 != (en_ctrl & LX_FLT_PROMISC)) {
+			mac |= L1F_MAC_CTRL_PROMISC_EN;
+		} else {
+			mac &= ~L1F_MAC_CTRL_PROMISC_EN;
+		}
+		if (0 != (en_ctrl & LX_FLT_MULTI_ALL)) {
+			mac |= L1F_MAC_CTRL_MULTIALL_EN;
+		} else {
+			mac &= ~L1F_MAC_CTRL_MULTIALL_EN;
+		}
+		if (0 != (en_ctrl & LX_FLT_BROADCAST)) {
+			mac |= L1F_MAC_CTRL_BRD_EN;
+		} else {
+			mac &= ~L1F_MAC_CTRL_BRD_EN;
+		}
+		if (0 != (en_ctrl & LX_FLT_DIRECT)) {
+			mac |= L1F_MAC_CTRL_RX_EN;
+		} else { /* disable all recv if direct not enable */
+			mac &= ~L1F_MAC_CTRL_RX_EN;
+		}
+		if (0 != (en_ctrl & LX_FC_TXEN)) {
+			mac |= L1F_MAC_CTRL_TXFC_EN;
+		} else {
+			mac &= ~L1F_MAC_CTRL_TXFC_EN;
+		}
+		if (0 != (en_ctrl & LX_FC_RXEN)) {
+			mac |= L1F_MAC_CTRL_RXFC_EN;
+		} else {
+			mac &= ~L1F_MAC_CTRL_RXFC_EN;
+		}
+		if (0 != (en_ctrl & LX_VLAN_STRIP)) {
+			mac |= L1F_MAC_CTRL_VLANSTRIP;
+		} else {
+			mac &= ~L1F_MAC_CTRL_VLANSTRIP;
+		}
+		if (0 != (en_ctrl & LX_LOOPBACK)) {
+			mac |= (L1F_MAC_CTRL_LPBACK_EN);
+		} else {
+			mac &= ~L1F_MAC_CTRL_LPBACK_EN;
+		}
+		if (0 != (en_ctrl & LX_SINGLE_PAUSE)) {
+			mac |= L1F_MAC_CTRL_SPAUSE_EN;
+		} else {
+			mac &= ~L1F_MAC_CTRL_SPAUSE_EN;
+		}
+		if (0 != (en_ctrl & LX_ADD_FCS)) {
+			mac |= (L1F_MAC_CTRL_PCRCE | L1F_MAC_CTRL_CRCE);
+		} else {
+			mac &= ~(L1F_MAC_CTRL_PCRCE | L1F_MAC_CTRL_CRCE);
+		}
+		MEM_W32(ctx, L1F_MAC_CTRL, mac | L1F_MAC_CTRL_TX_EN);
+	} else { /* disable mac */
+		MEM_W32(ctx, L1F_RXQ0, rxq & ~L1F_RXQ0_EN);
+		MEM_W32(ctx, L1F_TXQ0, txq & ~L1F_TXQ0_EN);
+
+		/* waiting for rxq/txq be idle */
+		US_DELAY(ctx, 40);
+
+		/* stop mac tx/rx */
+		MEM_W32(ctx, L1F_MAC_CTRL,
+		    mac & ~(L1F_MAC_CTRL_RX_EN | L1F_MAC_CTRL_TX_EN));
+
+		for (i = 0; i < L1F_DMA_MAC_RST_TO; i++) {
+			MEM_R32(ctx, L1F_MAC_STS, &val);
+			if (0 == (val & L1F_MAC_STS_IDLE)) {
+				break;
+			}
+			US_DELAY(ctx, 10);
+		}
+		if (L1F_DMA_MAC_RST_TO == i) {
+			return LX_ERR_RSTMAC;
+		}
+	}
+
+	return 0;
+}
+
+/* enable/disable aspm support
+ * that will change settings for phy/mac/pcie
+ */
+u16 l1f_enable_aspm(PETHCONTEXT ctx, bool l0s_en, bool l1_en, u8 lnk_stat)
+{
+	u32 pmctrl;
+	u8 rev = (u8)(FIELD_GETX(ctx->pci_revid, L1F_PCI_REVID));
+
+	lnk_stat = lnk_stat;
+
+
+#if 0 /* let sys bios control the L0S/L1 enable/disable */
+
+	u16 lnkctrl;
+	bool sysl0s_en, sysl1_en;
+
+	/* get BIOS/system l0s/l1 setting */
+	sysl0s_en = false;
+	sysl1_en = false;
+	CFG_R16(ctx, L1F_LNK_CTRL, &lnkctrl);
+	lnkctrl = (u16)FIELD_GETX(lnkctrl, L1F_LNK_CTRL_ASPM);
+	switch (lnkctrl) {
+	case L1F_LNK_CTRL_ASPM_ENL0SL1:
+		sysl0s_en = true;
+		sysl1_en = true;
+		break;
+	case L1F_LNK_CTRL_ASPM_ENL1:
+		sysl1_en = true;
+		break;
+	case L1F_LNK_CTRL_ASPM_ENL0S:
+		sysl0s_en = true;
+		break;
+	}
+#endif
+
+	MEM_R32(ctx, L1F_PMCTRL, &pmctrl);
+
+	/* ????default */
+	FIELD_SETL(pmctrl, L1F_PMCTRL_LCKDET_TIMER,
+	    L1F_PMCTRL_LCKDET_TIMER_DEF);
+	pmctrl |= L1F_PMCTRL_RCVR_WT_1US    |   /* wait 1us */
+		  L1F_PMCTRL_L1_CLKSW_EN    |   /* pcie clk sw */
+		  L1F_PMCTRL_L1_SRDSRX_PWD  ;   /* pwd serdes ????default */
+	/* ????default */
+	FIELD_SETL(pmctrl, L1F_PMCTRL_L1REQ_TO, L1F_PMCTRL_L1REG_TO_DEF);
+	FIELD_SETL(pmctrl, L1F_PMCTRL_L1_TIMER, L1F_PMCTRL_L1_TIMER_16US);
+	pmctrl &= ~(L1F_PMCTRL_L1_SRDS_EN |
+		    L1F_PMCTRL_L1_SRDSPLL_EN |
+		    L1F_PMCTRL_L1_BUFSRX_EN |
+		    L1F_PMCTRL_SADLY_EN |       /* ???default */
+		    L1F_PMCTRL_HOTRST_WTEN|
+		    L1F_PMCTRL_L0S_EN |
+		    L1F_PMCTRL_L1_EN |
+		    L1F_PMCTRL_ASPM_FCEN |
+		    L1F_PMCTRL_TXL1_AFTER_L0S |
+		    L1F_PMCTRL_RXL1_AFTER_L0S
+		    );
+	if ((rev == L1F_REV_A0 || rev == L1F_REV_A1) &&
+	    0 != (ctx->pci_revid & L1F_PCI_REVID_WTH_CR)) {
+		pmctrl |= L1F_PMCTRL_L1_SRDS_EN | L1F_PMCTRL_L1_SRDSPLL_EN;
+	}
+
+	/* on/off l0s only if bios/system enable l0s */
+	if (/* sysl0s_en && */ l0s_en) {
+		pmctrl |= (L1F_PMCTRL_L0S_EN | L1F_PMCTRL_ASPM_FCEN);
+	}
+	/* on/off l1 only if bios/system enable l1 */
+	if (/* sysl1_en && */ l1_en) {
+		pmctrl |= (L1F_PMCTRL_L1_EN | L1F_PMCTRL_ASPM_FCEN);
+	}
+
+	MEM_W32(ctx, L1F_PMCTRL, pmctrl);
+
+	return 0;
+}
+
+
+/* initialize phy for speed / flow control
+ * lnk_cap
+ *    if autoNeg, is link capability to tell the peer
+ *    if force mode, is forced speed/duplex
+ */
+u16 l1f_init_phy_spdfc(PETHCONTEXT ctx, bool auto_neg,
+		       u8 lnk_cap, bool fc_en)
+{
+	u16 adv, giga, cr;
+	u32 val;
+	u16 ret;
+
+	/* clear flag */
+	l1f_write_phy(ctx, false, 0, false, L1F_MII_DBG_ADDR, 0);
+	MEM_R32(ctx, L1F_DRV, &val);
+	FIELD_SETL(val, LX_DRV_PHY, 0);
+
+	if (auto_neg) {
+		adv = L1F_ADVERTISE_DEFAULT_CAP & ~L1F_ADVERTISE_SPEED_MASK;
+		giga = L1F_GIGA_CR_1000T_DEFAULT_CAP &
+			~L1F_GIGA_CR_1000T_SPEED_MASK;
+		val |= LX_DRV_PHY_AUTO;
+		if (!fc_en) {
+			adv &= ~(L1F_ADVERTISE_PAUSE | L1F_ADVERTISE_ASM_DIR);
+		} else {
+			val |= LX_DRV_PHY_FC;
+		}
+		if (0 != (LX_LC_10H & lnk_cap)) {
+			adv |= L1F_ADVERTISE_10T_HD_CAPS;
+			val |= LX_DRV_PHY_10;
+		}
+		if (0 != (LX_LC_10F & lnk_cap)) {
+			adv |= L1F_ADVERTISE_10T_FD_CAPS |
+			       L1F_ADVERTISE_10T_HD_CAPS;
+			val |= LX_DRV_PHY_10 | LX_DRV_PHY_DUPLEX;
+		}
+		if (0 != (LX_LC_100H & lnk_cap)) {
+			adv |= L1F_ADVERTISE_100TX_HD_CAPS;
+			val |= LX_DRV_PHY_100;
+		}
+		if (0 != (LX_LC_100F & lnk_cap)) {
+			adv |= L1F_ADVERTISE_100TX_FD_CAPS |
+			       L1F_ADVERTISE_100TX_HD_CAPS;
+			val |= LX_DRV_PHY_100 | LX_DRV_PHY_DUPLEX;
+		}
+		if (0 != (LX_LC_1000F & lnk_cap)) {
+			giga |= L1F_GIGA_CR_1000T_FD_CAPS;
+			val |= LX_DRV_PHY_1000 | LX_DRV_PHY_DUPLEX;
+		}
+
+		ret = l1f_write_phy(ctx, false, 0, false,
+			L1F_MII_ADVERTISE, adv);
+		ret = l1f_write_phy(ctx, false, 0, false,
+			L1F_MII_GIGA_CR, giga);
+
+		cr = L1F_BMCR_RESET | L1F_BMCR_AUTO_NEG_EN |
+		     L1F_BMCR_RESTART_AUTO_NEG;
+		ret = l1f_write_phy(ctx, false, 0, false, L1F_MII_BMCR, cr);
+	} else { /* force mode */
+		cr = L1F_BMCR_RESET;
+		switch (lnk_cap) {
+		case LX_LC_10H:
+			cr |= L1F_BMCR_SPEED_10;
+			val |= LX_DRV_PHY_10;
+			break;
+		case LX_LC_10F:
+			cr |= L1F_BMCR_SPEED_10 | L1F_BMCR_FULL_DUPLEX;
+			val |= LX_DRV_PHY_10 | LX_DRV_PHY_DUPLEX;
+			break;
+		case LX_LC_100H:
+			cr |= L1F_BMCR_SPEED_100;
+			val |= LX_DRV_PHY_100;
+			break;
+		case LX_LC_100F:
+			cr |= L1F_BMCR_SPEED_100 | L1F_BMCR_FULL_DUPLEX;
+			val |= LX_DRV_PHY_100 | LX_DRV_PHY_DUPLEX;
+			break;
+		default:
+			return LX_ERR_PARM;
+		}
+		ret = l1f_write_phy(ctx, false, 0, false, L1F_MII_BMCR, cr);
+	}
+
+	if (!ret) {
+		l1f_write_phy(ctx, false, 0, false,
+		    L1F_MII_DBG_ADDR, LX_PHY_INITED);
+	}
+	MEM_W32(ctx, L1F_DRV, val);
+
+	return ret;
+}
+
+/* do post setting on phy if link up/down event occur
+ */
+u16 l1f_post_phy_link(PETHCONTEXT ctx, bool linkon, u8 wire_spd)
+{
+	ctx = ctx;
+	linkon = linkon;
+	wire_spd = wire_spd;
+
+	return 0;
+}
+
+
+
+/* do power saving setting befor enter suspend mode
+ * NOTE:
+ *    1. phy link must be established before calling this function
+ *    2. wol option (pattern,magic,link,etc.) is configed before call it.
+ */
+u16 l1f_powersaving(PETHCONTEXT ctx,
+		    u8 wire_spd,
+		    bool wol_en,
+		    bool mactx_en,
+		    bool macrx_en,
+		    bool pws_en)
+{
+	u32 master_ctrl, mac_ctrl, phy_ctrl, val;
+	u16 pm_ctrl, ret = 0;
+
+	master_ctrl = 0;
+	mac_ctrl = 0;
+	phy_ctrl = 0;
+
+	pws_en = pws_en;
+
+	MEM_R32(ctx, L1F_MASTER, &master_ctrl);
+	master_ctrl &= ~L1F_MASTER_PCLKSEL_SRDS;
+
+	MEM_R32(ctx, L1F_MAC_CTRL, &mac_ctrl);
+	/* 10/100 half */
+	FIELD_SETL(mac_ctrl, L1F_MAC_CTRL_SPEED,  L1F_MAC_CTRL_SPEED_10_100);
+	mac_ctrl &= ~(L1F_MAC_CTRL_FULLD |
+		      L1F_MAC_CTRL_RX_EN |
+		      L1F_MAC_CTRL_TX_EN);
+
+	MEM_R32(ctx, L1F_PHY_CTRL, &phy_ctrl);
+	phy_ctrl &= ~(L1F_PHY_CTRL_DSPRST_OUT | L1F_PHY_CTRL_CLS);
+	/* if (pws_en) { */
+	phy_ctrl |= (L1F_PHY_CTRL_RST_ANALOG | L1F_PHY_CTRL_HIB_PULSE |
+	    L1F_PHY_CTRL_HIB_EN);
+
+	if (wol_en) { /* enable rx packet or tx packet */
+		if (macrx_en) {
+			mac_ctrl |= (L1F_MAC_CTRL_RX_EN | L1F_MAC_CTRL_BRD_EN);
+		}
+		if (mactx_en) {
+			mac_ctrl |= L1F_MAC_CTRL_TX_EN;
+		}
+		if (LX_LC_1000F == wire_spd) {
+			FIELD_SETL(mac_ctrl, L1F_MAC_CTRL_SPEED,
+			    L1F_MAC_CTRL_SPEED_1000);
+		}
+		if (LX_LC_10F == wire_spd ||
+		    LX_LC_100F == wire_spd ||
+		    LX_LC_100F == wire_spd) {
+			mac_ctrl |= L1F_MAC_CTRL_FULLD;
+		}
+		phy_ctrl |= L1F_PHY_CTRL_DSPRST_OUT;
+		ret = l1f_write_phy(ctx, false, 0, false, L1F_MII_IER,
+		    L1F_IER_LINK_UP);
+	} else {
+		ret = l1f_write_phy(ctx, false, 0, false, L1F_MII_IER, 0);
+		phy_ctrl |= (L1F_PHY_CTRL_IDDQ | L1F_PHY_CTRL_POWER_DOWN);
+	}
+	MEM_W32(ctx, L1F_MASTER, master_ctrl);
+	MEM_W32(ctx, L1F_MAC_CTRL, mac_ctrl);
+	MEM_W32(ctx, L1F_PHY_CTRL, phy_ctrl);
+
+	/* set val of PDLL D3PLLOFF */
+	MEM_R32(ctx, L1F_PDLL_TRNS1, &val);
+	MEM_W32(ctx, L1F_PDLL_TRNS1, val | L1F_PDLL_TRNS1_D3PLLOFF_EN);
+
+	/* any debug info ???? */
+	DEBUG_INFOS(ctx, DEBUG_CAT_PME);
+
+	/* set PME_EN */
+	if (wol_en) {
+		CFG_R16(ctx, L1F_PM_CSR, &pm_ctrl);
+		pm_ctrl |= L1F_PM_CSR_PME_EN;
+		CFG_W16(ctx, L1F_PM_CSR, pm_ctrl);
+	}
+
+	return ret;
+}
+
+
+/* read phy register */
+u16 l1f_read_phy(PETHCONTEXT ctx, bool ext, u8 dev, bool fast,
+		 u16 reg, u16 *data)
+{
+	u32 val;
+	u16 clk_sel, i, ret = 0;
+
+#if MAC_TYPE_FPGA == MAC_TYPE
+
+	MEM_W32(ctx, L1F_MDIO, 0);
+	US_DELAY(ctx, 30);
+	for (i = 0; i < L1F_MDIO_MAX_AC_TO; i++) {
+		MEM_R32(ctx, L1F_MDIO, &val);
+		if (0 == (val & L1F_MDIO_BUSY)) {
+			break;
+		}
+		US_DELAY(ctx, 10);
+	}
+#endif
+
+	*data = 0;
+	clk_sel = fast ?
+	    (u16)L1F_MDIO_CLK_SEL_25MD4 : (u16)L1F_MDIO_CLK_SEL_25MD128;
+
+	if (ext) {
+		val = FIELDL(L1F_MDIO_EXTN_DEVAD, dev) |
+		      FIELDL(L1F_MDIO_EXTN_REG, reg);
+		MEM_W32(ctx, L1F_MDIO_EXTN, val);
+
+		val = L1F_MDIO_SPRES_PRMBL |
+		      FIELDL(L1F_MDIO_CLK_SEL, clk_sel) |
+		      L1F_MDIO_START |
+		      L1F_MDIO_MODE_EXT |
+		      L1F_MDIO_OP_READ;
+	} else {
+		val = L1F_MDIO_SPRES_PRMBL |
+		      FIELDL(L1F_MDIO_CLK_SEL, clk_sel) |
+		      FIELDL(L1F_MDIO_REG, reg) |
+		      L1F_MDIO_START |
+		      L1F_MDIO_OP_READ;
+	}
+
+	MEM_W32(ctx, L1F_MDIO, val);
+
+	for (i = 0; i < L1F_MDIO_MAX_AC_TO; i++) {
+		MEM_R32(ctx, L1F_MDIO, &val);
+		if (0 == (val & L1F_MDIO_BUSY)) {
+			*data = (u16)FIELD_GETX(val, L1F_MDIO_DATA);
+			break;
+		}
+		US_DELAY(ctx, 10);
+	}
+	if (L1F_MDIO_MAX_AC_TO == i) {
+		ret = LX_ERR_MIIBUSY;
+	}
+
+#if MAC_TYPE_FPGA == MAC_TYPE
+	val |= L1F_MDIO_SPRES_PRMBL |
+	       FIELDL(L1F_MDIO_CLK_SEL, clk_sel) |
+	       FIELDL(L1F_MDIO_REG, 1) |
+	       L1F_MDIO_START |
+	       L1F_MDIO_OP_READ;
+
+	MEM_W32(ctx, L1F_MDIO, val);
+
+	for (i = 0; i < L1F_MDIO_MAX_AC_TO; i++) {
+		MEM_R32(ctx, L1F_MDIO, &val);
+		if (0 == (val & L1F_MDIO_BUSY)) {
+			break;
+		}
+		US_DELAY(ctx, 10);
+	}
+
+	MEM_W32(ctx, L1F_MDIO,
+	    (val & ~L1F_MDIO_START) | L1F_MDIO_AUTO_POLLING);
+	US_DELAY(ctx, 30);
+#endif
+
+	return ret;
+}
+
+/* write phy register */
+u16 l1f_write_phy(PETHCONTEXT ctx, bool ext, u8 dev, bool fast,
+		  u16 reg, u16 data)
+{
+	u32 val;
+	u16 clk_sel, i, ret = 0;
+
+#if MAC_TYPE_FPGA == MAC_TYPE
+	MEM_W32(ctx, L1F_MDIO, 0);
+	US_DELAY(ctx, 30);
+	for (i = 0; i < L1F_MDIO_MAX_AC_TO; i++) {
+		MEM_R32(ctx, L1F_MDIO, &val);
+		if (0 == (val & L1F_MDIO_BUSY)) {
+			break;
+		}
+		US_DELAY(ctx, 10);
+	}
+#endif
+
+	clk_sel = fast ?
+	    (u16)L1F_MDIO_CLK_SEL_25MD4 : (u16)L1F_MDIO_CLK_SEL_25MD128;
+
+	if (ext) {
+		val = FIELDL(L1F_MDIO_EXTN_DEVAD, dev) |
+		      FIELDL(L1F_MDIO_EXTN_REG, reg);
+		MEM_W32(ctx, L1F_MDIO_EXTN, val);
+
+		val = L1F_MDIO_SPRES_PRMBL |
+		      FIELDL(L1F_MDIO_CLK_SEL, clk_sel) |
+		      FIELDL(L1F_MDIO_DATA, data) |
+		      L1F_MDIO_START |
+		      L1F_MDIO_MODE_EXT;
+	} else {
+		val = L1F_MDIO_SPRES_PRMBL |
+		      FIELDL(L1F_MDIO_CLK_SEL, clk_sel) |
+		      FIELDL(L1F_MDIO_REG, reg) |
+		      FIELDL(L1F_MDIO_DATA, data) |
+		      L1F_MDIO_START;
+	}
+
+	MEM_W32(ctx, L1F_MDIO, val);
+
+	for (i = 0; i < L1F_MDIO_MAX_AC_TO; i++) {
+		MEM_R32(ctx, L1F_MDIO, &val);
+		if (0 == (val & L1F_MDIO_BUSY)) {
+			break;
+		}
+		US_DELAY(ctx, 10);
+	}
+	if (L1F_MDIO_MAX_AC_TO == i) {
+		ret = LX_ERR_MIIBUSY;
+	}
+
+#if MAC_TYPE_FPGA == MAC_TYPE
+	val |= L1F_MDIO_SPRES_PRMBL |
+	       FIELDL(L1F_MDIO_CLK_SEL, clk_sel) |
+	       FIELDL(L1F_MDIO_REG, 1) |
+	       L1F_MDIO_START |
+	       L1F_MDIO_OP_READ;
+
+	MEM_W32(ctx, L1F_MDIO, val);
+
+	for (i = 0; i < L1F_MDIO_MAX_AC_TO; i++) {
+		MEM_R32(ctx, L1F_MDIO, &val);
+		if (0 == (val & L1F_MDIO_BUSY)) {
+			break;
+		}
+		US_DELAY(ctx, 10);
+	}
+
+	MEM_W32(ctx, L1F_MDIO,
+	    (val & ~L1F_MDIO_START) | L1F_MDIO_AUTO_POLLING);
+	US_DELAY(ctx, 30);
+#endif
+
+	return ret;
+}
+
+u16 l1f_read_phydbg(PETHCONTEXT ctx, bool fast, u16 reg, u16 *data)
+{
+	u16 ret;
+
+	ret = l1f_write_phy(ctx, false, 0, fast, L1F_MII_DBG_ADDR, reg);
+	ret = l1f_read_phy(ctx, false, 0, fast, L1F_MII_DBG_DATA, data);
+
+	return ret;
+}
+
+u16 l1f_write_phydbg(PETHCONTEXT ctx, bool fast, u16 reg, u16 data)
+{
+	u16 ret;
+
+	ret = l1f_write_phy(ctx, false, 0, fast, L1F_MII_DBG_ADDR, reg);
+	ret = l1f_write_phy(ctx, false, 0, fast, L1F_MII_DBG_DATA, data);
+
+	return ret;
+}
+
+
+
+
+
+/*
+ * initialize mac basically
+ *  most of hi-feature no init
+ *      MAC/PHY should be reset before call this function
+ *  smb_timer : million-second
+ *  int_mod   : micro-second
+ *  disable RSS as default
+ */
+u16 l1f_init_mac(PETHCONTEXT ctx, u8 *addr, u32 txmem_hi,
+		 u32 *tx_mem_lo, u8 tx_qnum, u16 txring_sz,
+		 u32 rxmem_hi, u32 rfdmem_lo, u32 rrdmem_lo,
+		 u16 rxring_sz, u16 rxbuf_sz, u16 smb_timer,
+		 u16 mtu, u16 int_mod, bool hash_legacy)
+{
+	u32 val;
+	u16 val16, devid;
+	u8 dmar_len;
+
+	CFG_R16(ctx, L1F_PCI_DID, &devid);
+
+	/* set mac-address */
+	val = *(u32 *)(addr + 2);
+	MEM_W32(ctx, L1F_STAD0, LX_SWAP_DW(val));
+	val = *(u16 *)addr ;
+	MEM_W32(ctx, L1F_STAD1, LX_SWAP_W((u16)val));
+
+	/* clear multicast hash table, algrithm */
+	MEM_W32(ctx, L1F_HASH_TBL0, 0);
+	MEM_W32(ctx, L1F_HASH_TBL1, 0);
+	MEM_R32(ctx, L1F_MAC_CTRL, &val);
+	if (hash_legacy) {
+		val |= L1F_MAC_CTRL_MHASH_ALG_HI5B;
+	} else {
+		val &= ~L1F_MAC_CTRL_MHASH_ALG_HI5B;
+	}
+	MEM_W32(ctx, L1F_MAC_CTRL, val);
+
+	/* clear any wol setting/status */
+	MEM_R32(ctx, L1F_WOL0, &val);
+	MEM_W32(ctx, L1F_WOL0, 0);
+
+	/* clk gating */
+	MEM_W32(ctx, L1F_CLK_GATE,
+	    (FIELD_GETX(ctx->pci_revid, L1F_PCI_REVID) == L1F_REV_B0) ?
+		L1F_CLK_GATE_ALL_B0 : L1F_CLK_GATE_ALL_A0);
+
+	/* idle timeout to switch clk_125M */
+	if (FIELD_GETX(ctx->pci_revid, L1F_PCI_REVID) == L1F_REV_B0) {
+		MEM_W32(ctx, L1F_IDLE_DECISN_TIMER, L1F_IDLE_DECISN_TIMER_DEF);
+	}
+
+	/* descriptor ring base memory */
+	MEM_W32(ctx, L1F_TX_BASE_ADDR_HI, txmem_hi);
+	MEM_W32(ctx, L1F_TPD_RING_SZ, txring_sz);
+	switch (tx_qnum) {
+	case 4:
+		MEM_W32(ctx, L1F_TPD_PRI3_ADDR_LO, tx_mem_lo[3]);
+		/* fall through */
+	case 3:
+		MEM_W32(ctx, L1F_TPD_PRI2_ADDR_LO, tx_mem_lo[2]);
+		/* fall through */
+	case 2:
+		MEM_W32(ctx, L1F_TPD_PRI1_ADDR_LO, tx_mem_lo[1]);
+		/* fall through */
+	case 1:
+		MEM_W32(ctx, L1F_TPD_PRI0_ADDR_LO, tx_mem_lo[0]);
+		break;
+	default:
+		return LX_ERR_PARM;
+	}
+	MEM_W32(ctx, L1F_RX_BASE_ADDR_HI, rxmem_hi);
+	MEM_W32(ctx, L1F_RFD_ADDR_LO, rfdmem_lo);
+	MEM_W32(ctx, L1F_RRD_ADDR_LO, rrdmem_lo);
+	MEM_W32(ctx, L1F_RFD_BUF_SZ, rxbuf_sz);
+	MEM_W32(ctx, L1F_RRD_RING_SZ, rxring_sz);
+	MEM_W32(ctx, L1F_RFD_RING_SZ, rxring_sz);
+	MEM_W32(ctx, L1F_SMB_TIMER, smb_timer * 500UL);
+	MEM_W32(ctx, L1F_SRAM9, L1F_SRAM_LOAD_PTR);
+
+	/* int moduration */
+	MEM_R32(ctx, L1F_MASTER, &val);
+/*    val = (val & ~L1F_MASTER_IRQMOD2_EN) | */
+	val = val | L1F_MASTER_IRQMOD2_EN |
+		L1F_MASTER_IRQMOD1_EN |
+		L1F_MASTER_SYSALVTIMER_EN;  /* sysalive */
+	MEM_W32(ctx, L1F_MASTER, val);
+	MEM_W32(ctx, L1F_IRQ_MODU_TIMER, FIELDL(L1F_IRQ_MODU_TIMER1,
+	    int_mod >> 1));
+
+	/* tpd threshold to trig int */
+	MEM_W32(ctx, L1F_TINT_TPD_THRSHLD, (u32)txring_sz / 3);
+	MEM_W32(ctx, L1F_TINT_TIMER, int_mod);
+	/* re-send int */
+	MEM_W32(ctx, L1F_INT_RETRIG, L1F_INT_RETRIG_TO);
+
+	/* mtu */
+	MEM_W32(ctx, L1F_MTU, (u32)(mtu + 4 + 4)); /* crc + vlan */
+	if (mtu > L1F_MTU_JUMBO_TH) {
+		MEM_R32(ctx, L1F_MAC_CTRL, &val);
+		MEM_W32(ctx, L1F_MAC_CTRL, val & ~L1F_MAC_CTRL_FAST_PAUSE);
+	}
+
+	/* txq */
+	if ((mtu + 8) < L1F_TXQ1_JUMBO_TSO_TH) {
+		val = (u32)(mtu + 8 + 7) >> 3; /* 7 for QWORD align */
+	} else {
+		val = L1F_TXQ1_JUMBO_TSO_TH >> 3;
+	}
+	MEM_W32(ctx, L1F_TXQ1, val | L1F_TXQ1_ERRLGPKT_DROP_EN);
+	MEM_R32(ctx, L1F_DEV_CTRL, &val);
+	dmar_len = (u8)FIELD_GETX(val, L1F_DEV_CTRL_MAXRRS);
+	/* if BIOS had changed the default dma read max length,
+	 * restore it to default value */
+	if (dmar_len < L1F_DEV_CTRL_MAXRRS_MIN) {
+		FIELD_SETL(val, L1F_DEV_CTRL_MAXRRS, L1F_DEV_CTRL_MAXRRS_MIN);
+		MEM_W32(ctx, L1F_DEV_CTRL, val);
+	}
+	val = FIELDL(L1F_TXQ0_TPD_BURSTPREF, L1F_TXQ_TPD_BURSTPREF_DEF) |
+	      L1F_TXQ0_MODE_ENHANCE |
+	      L1F_TXQ0_LSO_8023_EN |
+	      L1F_TXQ0_SUPT_IPOPT |
+	      FIELDL(L1F_TXQ0_TXF_BURST_PREF, L1F_TXQ_TXF_BURST_PREF_DEF);
+	MEM_W32(ctx, L1F_TXQ0, val);
+	val = FIELDL(L1F_HQTPD_Q1_NUMPREF, L1F_TXQ_TPD_BURSTPREF_DEF) |
+	      FIELDL(L1F_HQTPD_Q2_NUMPREF, L1F_TXQ_TPD_BURSTPREF_DEF) |
+	      FIELDL(L1F_HQTPD_Q3_NUMPREF, L1F_TXQ_TPD_BURSTPREF_DEF) |
+	      L1F_HQTPD_BURST_EN;
+	MEM_W32(ctx, L1F_HQTPD, val);
+
+	/* rxq */
+	MEM_R32(ctx, L1F_SRAM5, &val);
+	val = FIELD_GETX(val, L1F_SRAM_RXF_LEN) << 3; /* bytes */
+	if (val > L1F_SRAM_RXF_LEN_8K) {
+		val16 = L1F_MTU_STD_ALGN >> 3;
+		val = (val - (2 * L1F_MTU_STD_ALGN + L1F_MTU_MIN)) >> 3;
+	} else {
+		val16 = L1F_MTU_STD_ALGN >> 3;
+		val = (val - L1F_MTU_STD_ALGN) >> 3;
+	}
+	MEM_W32(ctx, L1F_RXQ2,
+	    FIELDL(L1F_RXQ2_RXF_XOFF_THRESH, val16) |
+	    FIELDL(L1F_RXQ2_RXF_XON_THRESH, val));
+	val = FIELDL(L1F_RXQ0_NUM_RFD_PREF, L1F_RXQ0_NUM_RFD_PREF_DEF) |
+	      FIELDL(L1F_RXQ0_RSS_MODE, L1F_RXQ0_RSS_MODE_DIS) |
+	      FIELDL(L1F_RXQ0_IDT_TBL_SIZE, L1F_RXQ0_IDT_TBL_SIZE_DEF) |
+	      L1F_RXQ0_RSS_HSTYP_ALL |
+	      L1F_RXQ0_RSS_HASH_EN |
+	      L1F_RXQ0_IPV6_PARSE_EN;
+	if (mtu > L1F_MTU_JUMBO_TH) {
+		val |= L1F_RXQ0_CUT_THRU_EN;
+	}
+	if (0 != (devid & 1)) {
+		FIELD_SETL(val, L1F_RXQ0_ASPM_THRESH,
+		    L1F_RXQ0_ASPM_THRESH_100M);
+	}
+	MEM_W32(ctx, L1F_RXQ0, val);
+
+	/* rfd producer index */
+	MEM_W32(ctx, L1F_RFD_PIDX, (u32)rxring_sz - 1);
+
+	/* DMA */
+	MEM_R32(ctx, L1F_DMA, &val);
+	val = FIELDL(L1F_DMA_RORDER_MODE, L1F_DMA_RORDER_MODE_OUT) |
+	      L1F_DMA_RREQ_PRI_DATA |
+	      FIELDL(L1F_DMA_RREQ_BLEN, dmar_len) |
+	      FIELDL(L1F_DMA_WDLY_CNT, L1F_DMA_WDLY_CNT_DEF) |
+	      FIELDL(L1F_DMA_RDLY_CNT, L1F_DMA_RDLY_CNT_DEF) |
+	      FIELDL(L1F_DMA_RCHNL_SEL, L1F_DMA_RCHNL_SEL_4);
+	MEM_W32(ctx, L1F_DMA, val);
+
+	return 0;
+}
+
+
+u16 l1f_get_phy_config(PETHCONTEXT ctx)
+{
+	u32 val;
+	u16 phy_val;
+
+	MEM_R32(ctx, L1F_PHY_CTRL, &val);
+	if (0 == (val & L1F_PHY_CTRL_DSPRST_OUT)) { /* phy in rst */
+		return LX_DRV_PHY_UNKNOWN;
+	}
+
+	MEM_R32(ctx, L1F_DRV, &val);
+	val = FIELD_GETX(val, LX_DRV_PHY);
+	if (LX_DRV_PHY_UNKNOWN == val) {
+		return LX_DRV_PHY_UNKNOWN;
+	}
+
+	l1f_read_phy(ctx, false, 0, false, L1F_MII_DBG_ADDR, &phy_val);
+	if (LX_PHY_INITED == phy_val) {
+		return (u16) val;
+	}
+
+	return LX_DRV_PHY_UNKNOWN;
+}
+
diff --git a/drivers/net/ethernet/atheros/alx/alf_hw.h b/drivers/net/ethernet/atheros/alx/alf_hw.h
new file mode 100755
index 0000000..b18ef82
--- /dev/null
+++ b/drivers/net/ethernet/atheros/alx/alf_hw.h
@@ -0,0 +1,2224 @@
+/*
+ * Copyright (c) 2010 - 2011 Atheros Communications Inc.
+ *
+ * Permission to use, copy, modify, and/or distribute this software for any
+ * purpose with or without fee is hereby granted, provided that the above
+ * copyright notice and this permission notice appear in all copies.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
+ * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
+ * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
+ * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
+ * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
+ * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ */
+
+#ifndef L1F_HW_H_
+#define L1F_HW_H_
+
+#ifdef __cplusplus
+extern "C" {
+#endif/*__cplusplus*/
+
+/*********************************************************************
+ * some reqs for l1f_sw.h
+ *
+ * 1. some basic type must be defined if there are not defined by
+ *    your compiler:
+ *    u8, u16, u32, bool
+ *
+ * 2. PETHCONTEXT difinition should be in l1x_sw.h and it must contain
+ *    pci_devid & pci_venid
+ *
+ * 3. you must define MAC_FPGA , PHY_FPGA to 1 or o
+ *   #define MAC_TYPE   1   (1:FPGA, 0:ASIC)
+ *   #define PHY_TYPE   0   (2:F1, 1:FPGA, 0:ASIC)
+ *
+ *
+ *
+ *********************************************************************/
+
+#include "alx_hwcom.h"
+
+#if MAC_TYPE == MAC_TYPE_ASIC
+#undef PHY_TYPE
+#define PHY_TYPE PHY_TYPE_ASIC
+#endif
+
+/******************************************************************************/
+
+#define L1F_PCI_VID                     0x0000  /* 16bit */
+#define L1F_PCI_DID                     0x0002  /* 16bit */
+#define L1F_PCI_DID_GB                  BIT_0S
+#define L1F_DEV_ID                      0x1091
+#define L2F_DEV_ID                      0x1090
+
+#define L1F_PCI_CMD                     0x0004  /* 16bit */
+#define L1F_PCI_CMD_DISINT              BIT_10S
+#define L1F_PCI_CMD_MASTEREN            BIT_2S
+#define L1F_PCI_CMD_MEMEN               BIT_1S
+#define L1F_PCI_CMD_IOEN                BIT_0S
+
+#define L1F_PCI_STAT                    0x0006  /* 16bit */
+#define L1F_PCI_STAT_PERR               BIT_15S
+#define L1F_PCI_STAT_SERR               BIT_14S
+#define L1F_PCI_STAT_RMABT              BIT_13S
+#define L1F_PCI_STAT_RTABT              BIT_12S
+#define L1F_PCI_STAT_STABT              BIT_11S
+#define L1F_PCI_STAT_MDPERR             BIT_8S
+#define L1F_PCI_STAT_INTS               BIT_3S
+
+#define L1F_PCI_REVID                   0x0008  /* 8bit */
+#define L1F_PCI_REVID_WTH_CR            BIT_1S
+#define L1F_PCI_REVID_WTH_XD            BIT_0S
+#define L1F_PCI_REVID_MASK              SHIFT3(0x1FU)
+#define L1F_PCI_REVID_SHIFT             3
+#define L1F_REV_A0                      0
+#define L1F_REV_A1                      1
+#define L1F_REV_B0                      2
+
+
+#define L1F_PIF                         0x0009  /* 8bit program interface */
+#define L1F_SCC                         0x000A  /* 8bit sub-class */
+#define L1F_BCC                         0x000B  /* 8bit base-class */
+
+#define L1F_BAR1_LO                     0x0010  /* memory space */
+#define L1F_BAR1_HI                     0x0014
+
+#define L1F_BAR2_LO                     0x0018  /* io space */
+#define L1F_BAR2_HI                     0x001C
+
+#define L1F_PCI_SSVID                   0x002C  /* 16bit sub-vendor id */
+#define L1F_PCI_SSDID                   0x002E  /* 16bit sub-device id */
+
+#define L1F_EXPNSN_ROM                  0x0030
+
+#define L1F_INT_LINE                    0x003C  /* 8bit */
+
+#define L1F_PM_CSR                      0x0044  /* 16bit */
+#define L1F_PM_CSR_PME_STAT             BIT_15S
+#define L1F_PM_CSR_DSCAL_MASK           SHIFT13(3U)
+#define L1F_PM_CSR_DSCAL_SHIFT          13
+#define L1F_PM_CSR_DSEL_MASK            SHIFT9(0xFU)
+#define L1F_PM_CSR_DSEL_SHIFT           9
+#define L1F_PM_CSR_PME_EN               BIT_8S
+#define L1F_PM_CSR_PWST_MASK            SHIFT0(3U)
+#define L1F_PM_CSR_PWST_SHIFT           0
+
+#define L1F_PM_DATA                     0x0047  /* 8bit */
+
+#define L1F_DEV_CAP                     0x005C
+#define L1F_DEV_CAP_SPLSL_MASK          SHIFT26(3UL)
+#define L1F_DEV_CAP_SPLSL_SHIFT         26
+#define L1F_DEV_CAP_SPLV_MASK           SHIFT18(0xFFUL)
+#define L1F_DEV_CAP_SPLV_SHIFT          18
+#define L1F_DEV_CAP_RBER                BIT_15
+#define L1F_DEV_CAP_PIPRS               BIT_14
+#define L1F_DEV_CAP_AIPRS               BIT_13
+#define L1F_DEV_CAP_ABPRS               BIT_12
+#define L1F_DEV_CAP_L1ACLAT_MASK        SHIFT9(7UL)
+#define L1F_DEV_CAP_L1ACLAT_SHIFT       9
+#define L1F_DEV_CAP_L0SACLAT_MASK       SHIFT6(7UL)
+#define L1F_DEV_CAP_L0SACLAT_SHIFT      6
+#define L1F_DEV_CAP_EXTAG               BIT_5
+#define L1F_DEV_CAP_PHANTOM             BIT_4
+#define L1F_DEV_CAP_MPL_MASK            SHIFT0(7UL)
+#define L1F_DEV_CAP_MPL_SHIFT           0
+#define L1F_DEV_CAP_MPL_128             1
+#define L1F_DEV_CAP_MPL_256             2
+#define L1F_DEV_CAP_MPL_512             3
+#define L1F_DEV_CAP_MPL_1024            4
+#define L1F_DEV_CAP_MPL_2048            5
+#define L1F_DEV_CAP_MPL_4096            6
+
+#define L1F_DEV_CTRL                    0x0060    /* 16bit */
+#define L1F_DEV_CTRL_MAXRRS_MASK        SHIFT12(7U)
+#define L1F_DEV_CTRL_MAXRRS_SHIFT       12
+#define L1F_DEV_CTRL_MAXRRS_MIN         2
+#define L1F_DEV_CTRL_NOSNP_EN           BIT_11S
+#define L1F_DEV_CTRL_AUXPWR_EN          BIT_10S
+#define L1F_DEV_CTRL_PHANTOM_EN         BIT_9S
+#define L1F_DEV_CTRL_EXTAG_EN           BIT_8S
+#define L1F_DEV_CTRL_MPL_MASK           SHIFT5(7U)
+#define L1F_DEV_CTRL_MPL_SHIFT          5
+#define L1F_DEV_CTRL_RELORD_EN          BIT_4S
+#define L1F_DEV_CTRL_URR_EN             BIT_3S
+#define L1F_DEV_CTRL_FERR_EN            BIT_2S
+#define L1F_DEV_CTRL_NFERR_EN           BIT_1S
+#define L1F_DEV_CTRL_CERR_EN            BIT_0S
+
+
+#define L1F_DEV_STAT                    0x0062    /* 16bit */
+#define L1F_DEV_STAT_XS_PEND            BIT_5S
+#define L1F_DEV_STAT_AUXPWR             BIT_4S
+#define L1F_DEV_STAT_UR                 BIT_3S
+#define L1F_DEV_STAT_FERR               BIT_2S
+#define L1F_DEV_STAT_NFERR              BIT_1S
+#define L1F_DEV_STAT_CERR               BIT_0S
+
+#define L1F_LNK_CAP                     0x0064
+#define L1F_LNK_CAP_PRTNUM_MASK         SHIFT24(0xFFUL)
+#define L1F_LNK_CAP_PRTNUM_SHIFT        24
+#define L1F_LNK_CAP_CLK_PM              BIT_18
+#define L1F_LNK_CAP_L1EXTLAT_MASK       SHIFT15(7UL)
+#define L1F_LNK_CAP_L1EXTLAT_SHIFT      15
+#define L1F_LNK_CAP_L0SEXTLAT_MASK      SHIFT12(7UL)
+#define L1F_LNK_CAP_L0SEXTLAT_SHIFT     12
+#define L1F_LNK_CAP_ASPM_SUP_MASK       SHIFT10(3UL)
+#define L1F_LNK_CAP_ASPM_SUP_SHIFT      10
+#define L1F_LNK_CAP_ASPM_SUP_L0S        1
+#define L1F_LNK_CAP_ASPM_SUP_L0SL1      3
+#define L1F_LNK_CAP_MAX_LWH_MASK        SHIFT4(0x3FUL)
+#define L1F_LNK_CAP_MAX_LWH_SHIFT       4
+#define L1F_LNK_CAP_MAX_LSPD_MASH       SHIFT0(0xFUL)
+#define L1F_LNK_CAP_MAX_LSPD_SHIFT      0
+
+#define L1F_LNK_CTRL                    0x0068  /* 16bit */
+#define L1F_LNK_CTRL_CLK_PM_EN          BIT_8S
+#define L1F_LNK_CTRL_EXTSYNC            BIT_7S
+#define L1F_LNK_CTRL_CMNCLK_CFG         BIT_6S
+#define L1F_LNK_CTRL_RCB_128B           BIT_3S  /* 0:64b,1:128b */
+#define L1F_LNK_CTRL_ASPM_MASK          SHIFT0(3U)
+#define L1F_LNK_CTRL_ASPM_SHIFT         0
+#define L1F_LNK_CTRL_ASPM_DIS           0
+#define L1F_LNK_CTRL_ASPM_ENL0S         1
+#define L1F_LNK_CTRL_ASPM_ENL1          2
+#define L1F_LNK_CTRL_ASPM_ENL0SL1       3
+
+#define L1F_LNK_STAT                    0x006A  /* 16bit */
+#define L1F_LNK_STAT_SCLKCFG            BIT_12S
+#define L1F_LNK_STAT_LNKTRAIN           BIT_11S
+#define L1F_LNK_STAT_TRNERR             BIT_10S
+#define L1F_LNK_STAT_LNKSPD_MASK        SHIFT0(0xFU)
+#define L1F_LNK_STAT_LNKSPD_SHIFT       0
+#define L1F_LNK_STAT_NEGLW_MASK         SHIFT4(0x3FU)
+#define L1F_LNK_STAT_NEGLW_SHIFT        4
+
+#define L1F_MSIX_MASK                   0x0090
+#define L1F_MSIX_PENDING                0x0094
+
+#define L1F_UE_SVRT                     0x010C
+#define L1F_UE_SVRT_UR                  BIT_20
+#define L1F_UE_SVRT_ECRCERR             BIT_19
+#define L1F_UE_SVRT_MTLP                BIT_18
+#define L1F_UE_SVRT_RCVOVFL             BIT_17
+#define L1F_UE_SVRT_UNEXPCPL            BIT_16
+#define L1F_UE_SVRT_CPLABRT             BIT_15
+#define L1F_UE_SVRT_CPLTO               BIT_14
+#define L1F_UE_SVRT_FCPROTERR           BIT_13
+#define L1F_UE_SVRT_PTLP                BIT_12
+#define L1F_UE_SVRT_DLPROTERR           BIT_4
+#define L1F_UE_SVRT_TRNERR              BIT_0
+
+#define L1F_EFLD                        0x0204  /* eeprom/flash load */
+#define L1F_EFLD_F_ENDADDR_MASK         SHIFT16(0x3FFUL)
+#define L1F_EFLD_F_ENDADDR_SHIFT        16
+#define L1F_EFLD_F_EXIST                BIT_10
+#define L1F_EFLD_E_EXIST                BIT_9
+#define L1F_EFLD_EXIST                  BIT_8
+#define L1F_EFLD_STAT                   BIT_5   /* 0:finish,1:in progress */
+#define L1F_EFLD_IDLE                   BIT_4
+#define L1F_EFLD_START                  BIT_0
+
+#define L1F_SLD                         0x0218  /* efuse load */
+#define L1F_SLD_FREQ_MASK               SHIFT24(3UL)
+#define L1F_SLD_FREQ_SHIFT              24
+#define L1F_SLD_FREQ_100K               0
+#define L1F_SLD_FREQ_200K               1
+#define L1F_SLD_FREQ_300K               2
+#define L1F_SLD_FREQ_400K               3
+#define L1F_SLD_EXIST                   BIT_23
+#define L1F_SLD_SLVADDR_MASK            SHIFT16(0x7FUL)
+#define L1F_SLD_SLVADDR_SHIFT           16
+#define L1F_SLD_IDLE                    BIT_13
+#define L1F_SLD_STAT                    BIT_12  /* 0:finish,1:in progress */
+#define L1F_SLD_START                   BIT_11
+#define L1F_SLD_STARTADDR_MASK          SHIFT0(0xFFUL)
+#define L1F_SLD_STARTADDR_SHIFT         0
+#define L1F_SLD_MAX_TO                  100
+
+#define L1F_PCIE_MSIC                   0x021C
+#define L1F_PCIE_MSIC_MSIX_DIS          BIT_22
+#define L1F_PCIE_MSIC_MSI_DIS           BIT_21
+
+#define L1F_PPHY_MISC1                  0x1000
+#define L1F_PPHY_MISC1_RCVDET           BIT_2
+#define L1F_PPHY_MISC1_NFTS_MASK        SHIFT16(0xFFUL)
+#define L1F_PPHY_MISC1_NFTS_SHIFT       16
+#define L1F_PPHY_MISC1_NFTS_HIPERF      0xA0    /* ???? */
+
+#define L1F_PPHY_MISC2                  0x1004
+#define L1F_PPHY_MISC2_L0S_TH_MASK      SHIFT18(0x3UL)
+#define L1F_PPHY_MISC2_L0S_TH_SHIFT     18
+#define L1F_PPHY_MISC2_CDR_BW_MASK      SHIFT16(0x3UL)
+#define L1F_PPHY_MISC2_CDR_BW_SHIFT     16
+
+#define L1F_PDLL_TRNS1                  0x1104
+#define L1F_PDLL_TRNS1_D3PLLOFF_EN      BIT_11
+#define L1F_PDLL_TRNS1_REGCLK_SEL_NORM  BIT_10
+#define L1F_PDLL_TRNS1_REPLY_TO_MASK    SHIFT0(0x3FFUL)
+#define L1F_PDLL_TRNS1_REPLY_TO_SHIFT   0
+
+
+#define L1F_TLEXTN_STATS                0x1208
+#define L1F_TLEXTN_STATS_DEVNO_MASK     SHIFT16(0x1FUL)
+#define L1F_TLEXTN_STATS_DEVNO_SHIFT    16
+#define L1F_TLEXTN_STATS_BUSNO_MASK     SHIFT8(0xFFUL)
+#define L1F_TLEXTN_STATS_BUSNO_SHIFT    8
+
+#define L1F_EFUSE_CTRL                  0x12C0
+#define L1F_EFUSE_CTRL_FLAG             BIT_31          /* 0:read,1:write */
+#define L1F_EUFSE_CTRL_ACK              BIT_30
+#define L1F_EFUSE_CTRL_ADDR_MASK        SHIFT16(0x3FFUL)
+#define L1F_EFUSE_CTRL_ADDR_SHIFT       16
+
+#define L1F_EFUSE_DATA                  0x12C4
+
+#define L1F_SPI_OP1                     0x12C8
+#define L1F_SPI_OP1_RDID_MASK           SHIFT24(0xFFUL)
+#define L1F_SPI_OP1_RDID_SHIFT          24
+#define L1F_SPI_OP1_CE_MASK             SHIFT16(0xFFUL)
+#define L1F_SPI_OP1_CE_SHIFT            16
+#define L1F_SPI_OP1_SE_MASK             SHIFT8(0xFFUL)
+#define L1F_SPI_OP1_SE_SHIFT            8
+#define L1F_SPI_OP1_PRGRM_MASK          SHIFT0(0xFFUL)
+#define L1F_SPI_OP1_PRGRM_SHIFT         0
+
+#define L1F_SPI_OP2                     0x12CC
+#define L1F_SPI_OP2_READ_MASK           SHIFT24(0xFFUL)
+#define L1F_SPI_OP2_READ_SHIFT          24
+#define L1F_SPI_OP2_WRSR_MASK           SHIFT16(0xFFUL)
+#define L1F_SPI_OP2_WRSR_SHIFT          16
+#define L1F_SPI_OP2_RDSR_MASK           SHIFT8(0xFFUL)
+#define L1F_SPI_OP2_RDSR_SHIFT          8
+#define L1F_SPI_OP2_WREN_MASK           SHIFT0(0xFFUL)
+#define L1F_SPI_OP2_WREN_SHIFT          0
+
+#define L1F_SPI_OP3                     0x12E4
+#define L1F_SPI_OP3_WRDI_MASK           SHIFT8(0xFFUL)
+#define L1F_SPI_OP3_WRDI_SHIFT          8
+#define L1F_SPI_OP3_EWSR_MASK           SHIFT0(0xFFUL)
+#define L1F_SPI_OP3_EWSR_SHIFT          0
+
+#define L1F_EF_CTRL                     0x12D0
+#define L1F_EF_CTRL_FSTS_MASK           SHIFT20(0xFFUL)
+#define L1F_EF_CTRL_FSTS_SHIFT          20
+#define L1F_EF_CTRL_CLASS_MASK          SHIFT16(7UL)
+#define L1F_EF_CTRL_CLASS_SHIFT         16
+#define L1F_EF_CTRL_CLASS_F_UNKNOWN     0
+#define L1F_EF_CTRL_CLASS_F_STD         1
+#define L1F_EF_CTRL_CLASS_F_SST         2
+#define L1F_EF_CTRL_CLASS_E_UNKNOWN     0
+#define L1F_EF_CTRL_CLASS_E_1K          1
+#define L1F_EF_CTRL_CLASS_E_4K          2
+#define L1F_EF_CTRL_FRET                BIT_15          /* 0:OK,1:fail */
+#define L1F_EF_CTRL_TYP_MASK            SHIFT12(3UL)
+#define L1F_EF_CTRL_TYP_SHIFT           12
+#define L1F_EF_CTRL_TYP_NONE            0
+#define L1F_EF_CTRL_TYP_F               1
+#define L1F_EF_CTRL_TYP_E               2
+#define L1F_EF_CTRL_TYP_UNKNOWN         3
+#define L1F_EF_CTRL_ONE_CLK             BIT_10
+#define L1F_EF_CTRL_ECLK_MASK           SHIFT8(3UL)
+#define L1F_EF_CTRL_ECLK_SHIFT          8
+#define L1F_EF_CTRL_ECLK_125K           0
+#define L1F_EF_CTRL_ECLK_250K           1
+#define L1F_EF_CTRL_ECLK_500K           2
+#define L1F_EF_CTRL_ECLK_1M             3
+#define L1F_EF_CTRL_FBUSY               BIT_7
+#define L1F_EF_CTRL_ACTION              BIT_6           /* 1:start,0:stop */
+#define L1F_EF_CTRL_AUTO_OP             BIT_5
+#define L1F_EF_CTRL_SST_MODE            BIT_4           /* force using sst */
+#define L1F_EF_CTRL_INST_MASK           SHIFT0(0xFUL)
+#define L1F_EF_CTRL_INST_SHIFT          0
+#define L1F_EF_CTRL_INST_NONE           0
+#define L1F_EF_CTRL_INST_READ           1               /* for flash & eeprom */
+#define L1F_EF_CTRL_INST_RDID           2
+#define L1F_EF_CTRL_INST_RDSR           3
+#define L1F_EF_CTRL_INST_WREN           4
+#define L1F_EF_CTRL_INST_PRGRM          5
+#define L1F_EF_CTRL_INST_SE             6
+#define L1F_EF_CTRL_INST_CE             7
+#define L1F_EF_CTRL_INST_WRSR           10
+#define L1F_EF_CTRL_INST_EWSR           11
+#define L1F_EF_CTRL_INST_WRDI           12
+#define L1F_EF_CTRL_INST_WRITE          2               /* only for eeprom */
+
+#define L1F_EF_ADDR                     0x12D4
+#define L1F_EF_DATA                     0x12D8
+#define L1F_SPI_ID                      0x12DC
+
+#define L1F_SPI_CFG_START               0x12E0
+
+#define L1F_PMCTRL                      0x12F8
+#define L1F_PMCTRL_HOTRST_WTEN          BIT_31
+#define L1F_PMCTRL_ASPM_FCEN            BIT_30  /* L0s/L1 dis by MAC based on
+						 * thrghput(setting in 15A0) */
+#define L1F_PMCTRL_SADLY_EN             BIT_29
+#define L1F_PMCTRL_L0S_BUFSRX_EN        BIT_28
+#define L1F_PMCTRL_LCKDET_TIMER_MASK    SHIFT24(0xFUL)
+#define L1F_PMCTRL_LCKDET_TIMER_SHIFT   24
+#define L1F_PMCTRL_LCKDET_TIMER_DEF     0xC
+#define L1F_PMCTRL_L1REQ_TO_MASK        SHIFT20(0xFUL)
+#define L1F_PMCTRL_L1REQ_TO_SHIFT       20      /* pm_request_l1 time > @
+						 * ->L0s not L1 */
+#define L1F_PMCTRL_L1REG_TO_DEF         0xC
+#define L1F_PMCTRL_TXL1_AFTER_L0S       BIT_19
+#define L1F_PMCTRL_L1_TIMER_MASK        SHIFT16(7UL)
+#define L1F_PMCTRL_L1_TIMER_SHIFT       16
+#define L1F_PMCTRL_L1_TIMER_DIS         0
+#define L1F_PMCTRL_L1_TIMER_2US         1
+#define L1F_PMCTRL_L1_TIMER_4US         2
+#define L1F_PMCTRL_L1_TIMER_8US         3
+#define L1F_PMCTRL_L1_TIMER_16US        4
+#define L1F_PMCTRL_L1_TIMER_24US        5
+#define L1F_PMCTRL_L1_TIMER_32US        6
+#define L1F_PMCTRL_L1_TIMER_63US        7
+#define L1F_PMCTRL_RCVR_WT_1US          BIT_15  /* 1:1us, 0:2ms */
+#define L1F_PMCTRL_PWM_VER_11           BIT_14  /* 0:1.0a,1:1.1 */
+#define L1F_PMCTRL_L1_CLKSW_EN          BIT_13  /* en pcie clk sw in L1 */
+#define L1F_PMCTRL_L0S_EN               BIT_12
+#define L1F_PMCTRL_RXL1_AFTER_L0S       BIT_11
+#define L1F_PMCTRL_L0S_TIMER_MASK       SHIFT8(7UL)
+#define L1F_PMCTRL_L0S_TIMER_SHIFT      8
+#define L1F_PMCTRL_L1_BUFSRX_EN         BIT_7
+#define L1F_PMCTRL_L1_SRDSRX_PWD        BIT_6   /* power down serdes rx */
+#define L1F_PMCTRL_L1_SRDSPLL_EN        BIT_5
+#define L1F_PMCTRL_L1_SRDS_EN           BIT_4
+#define L1F_PMCTRL_L1_EN                BIT_3
+#define L1F_PMCTRL_CLKREQ_EN            BIT_2
+#define L1F_PMCTRL_RBER_EN              BIT_1
+#define L1F_PMCTRL_SPRSDWER_EN          BIT_0
+
+#define L1F_LTSSM_CTRL                  0x12FC
+#define L1F_LTSSM_WRO_EN                BIT_12
+
+
+/******************************************************************************/
+
+#define L1F_MASTER                      0x1400
+#define L1F_MASTER_OTP_FLG              BIT_31
+#define L1F_MASTER_DEV_NUM_MASK         SHIFT24(0x7FUL)
+#define L1F_MASTER_DEV_NUM_SHIFT        24
+#define L1F_MASTER_REV_NUM_MASK         SHIFT16(0xFFUL)
+#define L1F_MASTER_REV_NUM_SHIFT        16
+#define L1F_MASTER_DEASSRT              BIT_15      /*ISSUE DE-ASSERT MSG */
+#define L1F_MASTER_RDCLR_INT            BIT_14
+#define L1F_MASTER_DMA_RST              BIT_13
+#define L1F_MASTER_PCLKSEL_SRDS         BIT_12      /* 1:alwys sel pclk from
+						     * serdes, not sw to 25M */
+#define L1F_MASTER_IRQMOD2_EN           BIT_11      /* IRQ MODURATION FOR RX */
+#define L1F_MASTER_IRQMOD1_EN           BIT_10      /* MODURATION FOR TX/RX */
+#define L1F_MASTER_MANU_INT             BIT_9       /* SOFT MANUAL INT */
+#define L1F_MASTER_MANUTIMER_EN         BIT_8
+#define L1F_MASTER_SYSALVTIMER_EN       BIT_7       /* SYS ALIVE TIMER EN */
+#define L1F_MASTER_OOB_DIS              BIT_6       /* OUT OF BOX DIS */
+#define L1F_MASTER_WAKEN_25M            BIT_5       /* WAKE WO. PCIE CLK */
+#define L1F_MASTER_BERT_START           BIT_4
+#define L1F_MASTER_PCIE_TSTMOD_MASK     SHIFT2(3UL)
+#define L1F_MASTER_PCIE_TSTMOD_SHIFT    2
+#define L1F_MASTER_PCIE_RST             BIT_1
+#define L1F_MASTER_DMA_MAC_RST          BIT_0       /* RST MAC & DMA */
+#define L1F_DMA_MAC_RST_TO              50
+
+#define L1F_MANU_TIMER                  0x1404
+
+#define L1F_IRQ_MODU_TIMER              0x1408
+#define L1F_IRQ_MODU_TIMER2_MASK        SHIFT16(0xFFFFUL)
+#define L1F_IRQ_MODU_TIMER2_SHIFT       16          /* ONLY FOR RX */
+#define L1F_IRQ_MODU_TIMER1_MASK        SHIFT0(0xFFFFUL)
+#define L1F_IRQ_MODU_TIMER1_SHIFT       0
+
+#define L1F_PHY_CTRL                    0x140C
+#define L1F_PHY_CTRL_ADDR_MASK          SHIFT19(0x1FUL)
+#define L1F_PHY_CTRL_ADDR_SHIFT         19
+#define L1F_PHY_CTRL_BP_VLTGSW          BIT_18
+#define L1F_PHY_CTRL_100AB_EN           BIT_17
+#define L1F_PHY_CTRL_10AB_EN            BIT_16
+#define L1F_PHY_CTRL_PLL_BYPASS         BIT_15
+#define L1F_PHY_CTRL_POWER_DOWN         BIT_14      /* affect MAC & PHY,
+						     * go to low power sts */
+#define L1F_PHY_CTRL_PLL_ON             BIT_13      /* 1:PLL ALWAYS ON
+						     * 0:CAN SWITCH IN LPW */
+#define L1F_PHY_CTRL_RST_ANALOG         BIT_12
+#define L1F_PHY_CTRL_HIB_PULSE          BIT_11
+#define L1F_PHY_CTRL_HIB_EN             BIT_10
+#define L1F_PHY_CTRL_GIGA_DIS           BIT_9
+#define L1F_PHY_CTRL_IDDQ_DIS           BIT_8       /* POWER ON RST */
+#define L1F_PHY_CTRL_IDDQ               BIT_7       /* WHILE REBOOT, BIT8(1)
+						     * EFFECTS BIT7 */
+#define L1F_PHY_CTRL_LPW_EXIT           BIT_6
+#define L1F_PHY_CTRL_GATE_25M           BIT_5
+#define L1F_PHY_CTRL_RVRS_ANEG          BIT_4
+#define L1F_PHY_CTRL_ANEG_NOW           BIT_3
+#define L1F_PHY_CTRL_LED_MODE           BIT_2
+#define L1F_PHY_CTRL_RTL_MODE           BIT_1
+#define L1F_PHY_CTRL_DSPRST_OUT         BIT_0       /* OUT OF DSP RST STATE */
+#define L1F_PHY_CTRL_DSPRST_TO          80
+#define L1F_PHY_CTRL_CLS                (\
+	L1F_PHY_CTRL_LED_MODE           |\
+	L1F_PHY_CTRL_100AB_EN           |\
+	L1F_PHY_CTRL_PLL_ON)
+
+#define L1F_MAC_STS                     0x1410
+#define L1F_MAC_STS_SFORCE_MASK         SHIFT14(0xFUL)
+#define L1F_MAC_STS_SFORCE_SHIFT        14
+#define L1F_MAC_STS_CALIB_DONE          BIT13
+#define L1F_MAC_STS_CALIB_RES_MASK      SHIFT8(0x1FUL)
+#define L1F_MAC_STS_CALIB_RES_SHIFT     8
+#define L1F_MAC_STS_CALIBERR_MASK       SHIFT4(0xFUL)
+#define L1F_MAC_STS_CALIBERR_SHIFT      4
+#define L1F_MAC_STS_TXQ_BUSY            BIT_3
+#define L1F_MAC_STS_RXQ_BUSY            BIT_2
+#define L1F_MAC_STS_TXMAC_BUSY          BIT_1
+#define L1F_MAC_STS_RXMAC_BUSY          BIT_0
+#define L1F_MAC_STS_IDLE                (\
+	L1F_MAC_STS_TXQ_BUSY            |\
+	L1F_MAC_STS_RXQ_BUSY            |\
+	L1F_MAC_STS_TXMAC_BUSY          |\
+	L1F_MAC_STS_RXMAC_BUSY)
+
+#define L1F_MDIO                        0x1414
+#define L1F_MDIO_MODE_EXT               BIT_30      /* 0:normal,1:ext */
+#define L1F_MDIO_POST_READ              BIT_29
+#define L1F_MDIO_AUTO_POLLING           BIT_28
+#define L1F_MDIO_BUSY                   BIT_27
+#define L1F_MDIO_CLK_SEL_MASK           SHIFT27(7UL)
+#define L1F_MDIO_CLK_SEL_SHIFT          24
+#define L1F_MDIO_CLK_SEL_25MD4          0           /* 25M DIV 4 */
+#define L1F_MDIO_CLK_SEL_25MD6          2
+#define L1F_MDIO_CLK_SEL_25MD8          3
+#define L1F_MDIO_CLK_SEL_25MD10         4
+#define L1F_MDIO_CLK_SEL_25MD32         5
+#define L1F_MDIO_CLK_SEL_25MD64         6
+#define L1F_MDIO_CLK_SEL_25MD128        7
+#define L1F_MDIO_START                  BIT_23
+#define L1F_MDIO_SPRES_PRMBL            BIT_22
+#define L1F_MDIO_OP_READ                BIT_21      /* 1:read,0:write */
+#define L1F_MDIO_REG_MASK               SHIFT16(0x1FUL)
+#define L1F_MDIO_REG_SHIFT              16
+#define L1F_MDIO_DATA_MASK              SHIFT0(0xFFFFUL)
+#define L1F_MDIO_DATA_SHIFT             0
+#define L1F_MDIO_MAX_AC_TO              60
+
+#define L1F_MDIO_EXTN                   0x1448
+#define L1F_MDIO_EXTN_PORTAD_MASK       SHIFT21(0x1FUL)
+#define L1F_MDIO_EXTN_PORTAD_SHIFT      21
+#define L1F_MDIO_EXTN_DEVAD_MASK        SHIFT16(0x1FUL)
+#define L1F_MDIO_EXTN_DEVAD_SHIFT       16
+#define L1F_MDIO_EXTN_REG_MASK          SHIFT0(0xFFFFUL)
+#define L1F_MDIO_EXTN_REG_SHIFT         0
+
+#define L1F_PHY_STS                     0x1418
+#define L1F_PHY_STS_LPW                 BIT_31
+#define L1F_PHY_STS_LPI                 BIT_30
+#define L1F_PHY_STS_PWON_STRIP_MASK     SHIFT16(0xFFFUL)
+#define L1F_PHY_STS_PWON_STRIP_SHIFT    16
+
+#define L1F_PHY_STS_DUPLEX              BIT_3
+#define L1F_PHY_STS_LINKUP              BIT_2
+#define L1F_PHY_STS_SPEED_MASK          SHIFT0(3UL)
+#define L1F_PHY_STS_SPEED_SHIFT         0
+#define L1F_PHY_STS_SPEED_1000M         2
+#define L1F_PHY_STS_SPEED_100M          1
+#define L1F_PHY_STS_SPEED_10M           0
+
+#define L1F_BIST0                       0x141C
+#define L1F_BIST0_COL_MASK              SHIFT24(0x3FUL)
+#define L1F_BIST0_COL_SHIFT             24
+#define L1F_BIST0_ROW_MASK              SHIFT12(0xFFFUL)
+#define L1F_BIST0_ROW_SHIFT             12
+#define L1F_BIST0_STEP_MASK             SHIFT8(0xFUL)
+#define L1F_BIST0_STEP_SHIFT            8
+#define L1F_BIST0_PATTERN_MASK          SHIFT4(7UL)
+#define L1F_BIST0_PATTERN_SHIFT         4
+#define L1F_BIST0_CRIT                  BIT_3
+#define L1F_BIST0_FIXED                 BIT_2
+#define L1F_BIST0_FAIL                  BIT_1
+#define L1F_BIST0_START                 BIT_0
+
+#define L1F_BIST1                       0x1420
+#define L1F_BIST1_COL_MASK              SHIFT24(0x3FUL)
+#define L1F_BIST1_COL_SHIFT             24
+#define L1F_BIST1_ROW_MASK              SHIFT12(0xFFFUL)
+#define L1F_BIST1_ROW_SHIFT             12
+#define L1F_BIST1_STEP_MASK             SHIFT8(0xFUL)
+#define L1F_BIST1_STEP_SHIFT            8
+#define L1F_BIST1_PATTERN_MASK          SHIFT4(7UL)
+#define L1F_BIST1_PATTERN_SHIFT         4
+#define L1F_BIST1_CRIT                  BIT_3
+#define L1F_BIST1_FIXED                 BIT_2
+#define L1F_BIST1_FAIL                  BIT_1
+#define L1F_BIST1_START                 BIT_0
+
+#define L1F_SERDES                      0x1424
+#define L1F_SERDES_PHYCLK_SLWDWN        BIT_18
+#define L1F_SERDES_MACCLK_SLWDWN        BIT_17
+#define L1F_SERDES_SELFB_PLL_MASK       SHIFT14(3UL)
+#define L1F_SERDES_SELFB_PLL_SHIFT      14
+#define L1F_SERDES_PHYCLK_SEL_GTX       BIT_13          /* 1:gtx_clk, 0:25M */
+#define L1F_SERDES_PCIECLK_SEL_SRDS     BIT_12          /* 1:serdes,0:25M */
+#define L1F_SERDES_BUFS_RX_EN           BIT_11
+#define L1F_SERDES_PD_RX                BIT_10
+#define L1F_SERDES_PLL_EN               BIT_9
+#define L1F_SERDES_EN                   BIT_8
+#define L1F_SERDES_SELFB_PLL_SEL_CSR    BIT_6       /* 0:state-machine,1:csr */
+#define L1F_SERDES_SELFB_PLL_CSR_MASK   SHIFT4(3UL)
+#define L1F_SERDES_SELFB_PLL_CSR_SHIFT  4
+#define L1F_SERDES_SELFB_PLL_CSR_4      3           /* 4-12% OV-CLK */
+#define L1F_SERDES_SELFB_PLL_CSR_0      2           /* 0-4% OV-CLK */
+#define L1F_SERDES_SELFB_PLL_CSR_12     1           /* 12-18% OV-CLK */
+#define L1F_SERDES_SELFB_PLL_CSR_18     0           /* 18-25% OV-CLK */
+#define L1F_SERDES_VCO_SLOW             BIT_3
+#define L1F_SERDES_VCO_FAST             BIT_2
+#define L1F_SERDES_LOCKDCT_EN           BIT_1
+#define L1F_SERDES_LOCKDCTED            BIT_0
+
+#define L1F_LED_CTRL                    0x1428
+#define L1F_LED_CTRL_PATMAP2_MASK       SHIFT8(3UL)
+#define L1F_LED_CTRL_PATMAP2_SHIFT      8
+#define L1F_LED_CTRL_PATMAP1_MASK       SHIFT6(3UL)
+#define L1F_LED_CTRL_PATMAP1_SHIFT      6
+#define L1F_LED_CTRL_PATMAP0_MASK       SHIFT4(3UL)
+#define L1F_LED_CTRL_PATMAP0_SHIFT      4
+#define L1F_LED_CTRL_D3_MODE_MASK       SHIFT2(3UL)
+#define L1F_LED_CTRL_D3_MODE_SHIFT      2
+#define L1F_LED_CTRL_D3_MODE_NORMAL     0
+#define L1F_LED_CTRL_D3_MODE_WOL_DIS    1
+#define L1F_LED_CTRL_D3_MODE_WOL_ANY    2
+#define L1F_LED_CTRL_D3_MODE_WOL_EN     3
+#define L1F_LED_CTRL_DUTY_CYCL_MASK     SHIFT0(3UL)
+#define L1F_LED_CTRL_DUTY_CYCL_SHIFT    0
+#define L1F_LED_CTRL_DUTY_CYCL_50       0           /* 50% */
+#define L1F_LED_CTRL_DUTY_CYCL_125      1           /* 12.5% */
+#define L1F_LED_CTRL_DUTY_CYCL_25       2           /* 25% */
+#define L1F_LED_CTRL_DUTY_CYCL_75       3           /* 75% */
+
+#define L1F_LED_PATN                    0x142C
+#define L1F_LED_PATN1_MASK              SHIFT16(0xFFFFUL)
+#define L1F_LED_PATN1_SHIFT             16
+#define L1F_LED_PATN0_MASK              SHIFT0(0xFFFFUL)
+#define L1F_LED_PATN0_SHIFT             0
+
+#define L1F_LED_PATN2                   0x1430
+#define L1F_LED_PATN2_MASK              SHIFT0(0xFFFFUL)
+#define L1F_LED_PATN2_SHIFT             0
+
+#define L1F_SYSALV                      0x1434
+#define L1F_SYSALV_FLAG                 BIT_0
+
+#define L1F_PCIERR_INST                 0x1438
+#define L1F_PCIERR_INST_TX_RATE_MASK    SHIFT4(0xFUL)
+#define L1F_PCIERR_INST_TX_RATE_SHIFT   4
+#define L1F_PCIERR_INST_RX_RATE_MASK    SHIFT0(0xFUL)
+#define L1F_PCIERR_INST_RX_RATE_SHIFT   0
+
+#define L1F_LPI_DECISN_TIMER            0x143C
+
+#define L1F_LPI_CTRL                    0x1440
+#define L1F_LPI_CTRL_CHK_DA             BIT_31
+#define L1F_LPI_CTRL_ENH_TO_MASK        SHIFT12(0x1FFFUL)
+#define L1F_LPI_CTRL_ENH_TO_SHIFT       12
+#define L1F_LPI_CTRL_ENH_TH_MASK        SHIFT6(0x1FUL)
+#define L1F_LPI_CTRL_ENH_TH_SHIFT       6
+#define L1F_LPI_CTRL_ENH_EN             BIT_5
+#define L1F_LPI_CTRL_CHK_RX             BIT_4
+#define L1F_LPI_CTRL_CHK_STATE          BIT_3
+#define L1F_LPI_CTRL_GMII               BIT_2
+#define L1F_LPI_CTRL_TO_PHY             BIT_1
+#define L1F_LPI_CTRL_EN                 BIT_0
+
+#define L1F_LPI_WAIT                    0x1444
+#define L1F_LPI_WAIT_TIMER_MASK         SHIFT0(0xFFFFUL)
+#define L1F_LPI_WAIT_TIMER_SHIFT        0
+
+#define L1F_HRTBT_VLAN                  0x1450      /* HEARTBEAT, FOR CIFS */
+#define L1F_HRTBT_VLANID_MASK           SHIFT0(0xFFFFUL) /* OR CLOUD */
+#define L1F_HRRBT_VLANID_SHIFT          0
+
+#define L1F_HRTBT_CTRL                  0x1454
+#define L1F_HRTBT_CTRL_EN               BIT_31
+#define L1F_HRTBT_CTRL_PERIOD_MASK      SHIFT25(0x3FUL)
+#define L1F_HRTBT_CTRL_PERIOD_SHIFT     25
+#define L1F_HRTBT_CTRL_HASVLAN          BIT_24
+#define L1F_HRTBT_CTRL_HDRADDR_MASK     SHIFT12(0xFFFUL)    /* A0 */
+#define L1F_HRTBT_CTRL_HDRADDR_SHIFT    12
+#define L1F_HRTBT_CTRL_HDRADDRB0_MASK   SHIFT13(0x7FFUL)    /* B0 */
+#define L1F_HRTBT_CTRL_HDRADDRB0_SHIFT  13
+#define L1F_HRTBT_CTRL_PKT_FRAG         BIT_12              /* B0 */
+#define L1F_HRTBT_CTRL_PKTLEN_MASK      SHIFT0(0xFFFUL)
+#define L1F_HRTBT_CTRL_PKTLEN_SHIFT     0
+
+#define L1F_HRTBT_EXT_CTRL                  0x1AD0      /* B0 */
+#define L1F_HRTBT_EXT_CTRL_NS_EN            BIT_12
+#define L1F_HRTBT_EXT_CTRL_FRAG_LEN_MASK    SHIFT4(0xFFUL)
+#define L1F_HRTBT_EXT_CTRL_FRAG_LEN_SHIFT   4
+#define L1F_HRTBT_EXT_CTRL_IS_8023          BIT_3
+#define L1F_HRTBT_EXT_CTRL_IS_IPV6          BIT_2
+#define L1F_HRTBT_EXT_CTRL_WAKEUP_EN        BIT_1
+#define L1F_HRTBT_EXT_CTRL_ARP_EN           BIT_0
+
+#define L1F_HRTBT_REM_IPV4_ADDR             0x1AD4
+#define L1F_HRTBT_HOST_IPV4_ADDR            0x1478/*use L1F_TRD_BUBBLE_DA_IP4*/
+#define L1F_HRTBT_REM_IPV6_ADDR3            0x1AD8
+#define L1F_HRTBT_REM_IPV6_ADDR2            0x1ADC
+#define L1F_HRTBT_REM_IPV6_ADDR1            0x1AE0
+#define L1F_HRTBT_REM_IPV6_ADDR0            0x1AE4
+/*SWOI_HOST_IPV6_ADDR reuse reg1a60-1a6c, 1a70-1a7c, 1aa0-1aac, 1ab0-1abc.*/
+#define L1F_HRTBT_WAKEUP_PORT               0x1AE8
+#define L1F_HRTBT_WAKEUP_PORT_SRC_MASK      SHIFT16(0xFFFFUL)
+#define L1F_HRTBT_WAKEUP_PORT_SRC_SHIFT     16
+#define L1F_HRTBT_WAKEUP_PORT_DEST_MASK     SHIFT0(0xFFFFUL)
+#define L1F_HRTBT_WAKEUP_PORT_DEST_SHIFT    0
+
+#define L1F_HRTBT_WAKEUP_DATA7              0x1AEC
+#define L1F_HRTBT_WAKEUP_DATA6              0x1AF0
+#define L1F_HRTBT_WAKEUP_DATA5              0x1AF4
+#define L1F_HRTBT_WAKEUP_DATA4              0x1AF8
+#define L1F_HRTBT_WAKEUP_DATA3              0x1AFC
+#define L1F_HRTBT_WAKEUP_DATA2              0x1B80
+#define L1F_HRTBT_WAKEUP_DATA1              0x1B84
+#define L1F_HRTBT_WAKEUP_DATA0              0x1B88
+
+#define L1F_RXPARSE                     0x1458
+#define L1F_RXPARSE_FLT6_L4_MASK        SHIFT30(3UL)
+#define L1F_RXPARSE_FLT6_L4_SHIFT       30
+#define L1F_RXPARSE_FLT6_L3_MASK        SHIFT28(3UL)
+#define L1F_RXPARSE_FLT6_L3_SHIFT       28
+#define L1F_RXPARSE_FLT5_L4_MASK        SHIFT26(3UL)
+#define L1F_RXPARSE_FLT5_L4_SHIFT       26
+#define L1F_RXPARSE_FLT5_L3_MASK        SHIFT24(3UL)
+#define L1F_RXPARSE_FLT5_L3_SHIFT       24
+#define L1F_RXPARSE_FLT4_L4_MASK        SHIFT22(3UL)
+#define L1F_RXPARSE_FLT4_L4_SHIFT       22
+#define L1F_RXPARSE_FLT4_L3_MASK        SHIFT20(3UL)
+#define L1F_RXPARSE_FLT4_L3_SHIFT       20
+#define L1F_RXPARSE_FLT3_L4_MASK        SHIFT18(3UL)
+#define L1F_RXPARSE_FLT3_L4_SHIFT       18
+#define L1F_RXPARSE_FLT3_L3_MASK        SHIFT16(3UL)
+#define L1F_RXPARSE_FLT3_L3_SHIFT       16
+#define L1F_RXPARSE_FLT2_L4_MASK        SHIFT14(3UL)
+#define L1F_RXPARSE_FLT2_L4_SHIFT       14
+#define L1F_RXPARSE_FLT2_L3_MASK        SHIFT12(3UL)
+#define L1F_RXPARSE_FLT2_L3_SHIFT       12
+#define L1F_RXPARSE_FLT1_L4_MASK        SHIFT10(3UL)
+#define L1F_RXPARSE_FLT1_L4_SHIFT       10
+#define L1F_RXPARSE_FLT1_L3_MASK        SHIFT8(3UL)
+#define L1F_RXPARSE_FLT1_L3_SHIFT       8
+#define L1F_RXPARSE_FLT6_EN             BIT_5
+#define L1F_RXPARSE_FLT5_EN             BIT_4
+#define L1F_RXPARSE_FLT4_EN             BIT_3
+#define L1F_RXPARSE_FLT3_EN             BIT_2
+#define L1F_RXPARSE_FLT2_EN             BIT_1
+#define L1F_RXPARSE_FLT1_EN             BIT_0
+#define L1F_RXPARSE_FLT_L4_UDP          0
+#define L1F_RXPARSE_FLT_L4_TCP          1
+#define L1F_RXPARSE_FLT_L4_BOTH         2
+#define L1F_RXPARSE_FLT_L4_NONE         3
+#define L1F_RXPARSE_FLT_L3_IPV6         0
+#define L1F_RXPARSE_FLT_L3_IPV4         1
+#define L1F_RXPARSE_FLT_L3_BOTH         2
+
+/* Terodo support */
+#define L1F_TRD_CTRL                    0x145C
+#define L1F_TRD_CTRL_EN                 BIT_31
+#define L1F_TRD_CTRL_BUBBLE_WAKE_EN     BIT_30
+#define L1F_TRD_CTRL_PREFIX_CMP_HW      BIT_28
+#define L1F_TRD_CTRL_RSHDR_ADDR_MASK    SHIFT16(0xFFFUL)
+#define L1F_TRD_CTRL_RSHDR_ADDR_SHIFT   16
+#define L1F_TRD_CTRL_SINTV_MAX_MASK     SHIFT8(0xFFUL)
+#define L1F_TRD_CTRL_SINTV_MAX_SHIFT    8
+#define L1F_TRD_CTRL_SINTV_MIN_MASK     SHIFT0(0xFFUL)
+#define L1F_TRD_CTRL_SINTV_MIN_SHIFT    0
+
+#define L1F_TRD_RS                      0x1460
+#define L1F_TRD_RS_SZ_MASK              SHIFT20(0xFFFUL)
+#define L1F_TRD_RS_SZ_SHIFT             20
+#define L1F_TRD_RS_NONCE_OFS_MASK       SHIFT8(0xFFFUL)
+#define L1F_TRD_RS_NONCE_OFS_SHIFT      8
+#define L1F_TRD_RS_SEQ_OFS_MASK         SHIFT0(0xFFUL)
+#define L1F_TRD_RS_SEQ_OFS_SHIFT        0
+
+#define L1F_TRD_SRV_IP4                 0x1464
+
+#define L1F_TRD_CLNT_EXTNL_IP4          0x1468
+
+#define L1F_TRD_PORT                    0x146C
+#define L1F_TRD_PORT_CLNT_EXTNL_MASK    SHIFT16(0xFFFFUL)
+#define L1F_TRD_PORT_CLNT_EXTNL_SHIFT   16
+#define L1F_TRD_PORT_SRV_MASK           SHIFT0(0xFFFFUL)
+#define L1F_TRD_PORT_SRV_SHIFT          0
+
+#define L1F_TRD_PREFIX                  0x1470
+
+#define L1F_TRD_BUBBLE_DA_IP4           0x1478
+
+#define L1F_TRD_BUBBLE_DA_PORT          0x147C
+
+
+#define L1F_IDLE_DECISN_TIMER           0x1474  /* B0 */
+#define L1F_IDLE_DECISN_TIMER_DEF       0x400   /* 1ms */
+
+
+#define L1F_MAC_CTRL                    0x1480
+#define L1F_MAC_CTRL_FAST_PAUSE         BIT_31
+#define L1F_MAC_CTRL_WOLSPED_SWEN       BIT_30
+#define L1F_MAC_CTRL_MHASH_ALG_HI5B     BIT_29  /* 1:legacy, 0:marvl(low5b)*/
+#define L1F_MAC_CTRL_SPAUSE_EN          BIT_28
+#define L1F_MAC_CTRL_DBG_EN             BIT_27
+#define L1F_MAC_CTRL_BRD_EN             BIT_26
+#define L1F_MAC_CTRL_MULTIALL_EN        BIT_25
+#define L1F_MAC_CTRL_RX_XSUM_EN         BIT_24
+#define L1F_MAC_CTRL_THUGE              BIT_23
+#define L1F_MAC_CTRL_MBOF               BIT_22
+#define L1F_MAC_CTRL_SPEED_MASK         SHIFT20(3UL)
+#define L1F_MAC_CTRL_SPEED_SHIFT        20
+#define L1F_MAC_CTRL_SPEED_10_100       1
+#define L1F_MAC_CTRL_SPEED_1000         2
+#define L1F_MAC_CTRL_SIMR               BIT_19
+#define L1F_MAC_CTRL_SSTCT              BIT_17
+#define L1F_MAC_CTRL_TPAUSE             BIT_16
+#define L1F_MAC_CTRL_PROMISC_EN         BIT_15
+#define L1F_MAC_CTRL_VLANSTRIP          BIT_14
+#define L1F_MAC_CTRL_PRMBLEN_MASK       SHIFT10(0xFUL)
+#define L1F_MAC_CTRL_PRMBLEN_SHIFT      10
+#define L1F_MAC_CTRL_RHUGE_EN           BIT_9
+#define L1F_MAC_CTRL_FLCHK              BIT_8
+#define L1F_MAC_CTRL_PCRCE              BIT_7
+#define L1F_MAC_CTRL_CRCE               BIT_6
+#define L1F_MAC_CTRL_FULLD              BIT_5
+#define L1F_MAC_CTRL_LPBACK_EN          BIT_4
+#define L1F_MAC_CTRL_RXFC_EN            BIT_3
+#define L1F_MAC_CTRL_TXFC_EN            BIT_2
+#define L1F_MAC_CTRL_RX_EN              BIT_1
+#define L1F_MAC_CTRL_TX_EN              BIT_0
+
+#define L1F_GAP                         0x1484
+#define L1F_GAP_IPGR2_MASK              SHIFT24(0x7FUL)
+#define L1F_GAP_IPGR2_SHIFT             24
+#define L1F_GAP_IPGR1_MASK              SHIFT16(0x7FUL)
+#define L1F_GAP_IPGR1_SHIFT             16
+#define L1F_GAP_MIN_IFG_MASK            SHIFT8(0xFFUL)
+#define L1F_GAP_MIN_IFG_SHIFT           8
+#define L1F_GAP_IPGT_MASK               SHIFT0(0x7FUL)  /* A0 diff with B0 */
+#define L1F_GAP_IPGT_SHIFT              0
+
+#define L1F_STAD0                       0x1488
+#define L1F_STAD1                       0x148C
+
+#define L1F_HASH_TBL0                   0x1490
+#define L1F_HASH_TBL1                   0x1494
+
+#define L1F_HALFD                       0x1498
+#define L1F_HALFD_JAM_IPG_MASK          SHIFT24(0xFUL)
+#define L1F_HALFD_JAM_IPG_SHIFT         24
+#define L1F_HALFD_ABEBT_MASK            SHIFT20(0xFUL)
+#define L1F_HALFD_ABEBT_SHIFT           20
+#define L1F_HALFD_ABEBE                 BIT_19
+#define L1F_HALFD_BPNB                  BIT_18
+#define L1F_HALFD_NOBO                  BIT_17
+#define L1F_HALFD_EDXSDFR               BIT_16
+#define L1F_HALFD_RETRY_MASK            SHIFT12(0xFUL)
+#define L1F_HALFD_RETRY_SHIFT           12
+#define L1F_HALFD_LCOL_MASK             SHIFT0(0x3FFUL)
+#define L1F_HALFD_LCOL_SHIFT            0
+
+#define L1F_MTU                         0x149C
+#define L1F_MTU_JUMBO_TH                1514
+#define L1F_MTU_STD_ALGN                1536
+#define L1F_MTU_MIN                     64
+
+#define L1F_SRAM0                       0x1500
+#define L1F_SRAM_RFD_TAIL_ADDR_MASK     SHIFT16(0xFFFUL)
+#define L1F_SRAM_RFD_TAIL_ADDR_SHIFT    16
+#define L1F_SRAM_RFD_HEAD_ADDR_MASK     SHIFT0(0xFFFUL)
+#define L1F_SRAM_RFD_HEAD_ADDR_SHIFT    0
+
+#define L1F_SRAM1                       0x1510
+#define L1F_SRAM_RFD_LEN_MASK           SHIFT0(0xFFFUL) /* 8BYTES UNIT */
+#define L1F_SRAM_RFD_LEN_SHIFT          0
+
+#define L1F_SRAM2                       0x1518
+#define L1F_SRAM_TRD_TAIL_ADDR_MASK     SHIFT16(0xFFFUL)
+#define L1F_SRAM_TRD_TAIL_ADDR_SHIFT    16
+#define L1F_SRMA_TRD_HEAD_ADDR_MASK     SHIFT0(0xFFFUL)
+#define L1F_SRAM_TRD_HEAD_ADDR_SHIFT    0
+
+#define L1F_SRAM3                       0x151C
+#define L1F_SRAM_TRD_LEN_MASK           SHIFT0(0xFFFUL) /* 8BYTES UNIT */
+#define L1F_SRAM_TRD_LEN_SHIFT          0
+
+#define L1F_SRAM4                       0x1520
+#define L1F_SRAM_RXF_TAIL_ADDR_MASK     SHIFT16(0xFFFUL)
+#define L1F_SRAM_RXF_TAIL_ADDR_SHIFT    16
+#define L1F_SRAM_RXF_HEAD_ADDR_MASK     SHIFT0(0xFFFUL)
+#define L1F_SRAM_RXF_HEAD_ADDR_SHIFT    0
+
+#define L1F_SRAM5                       0x1524
+#define L1F_SRAM_RXF_LEN_MASK           SHIFT0(0xFFFUL) /* 8BYTES UNIT */
+#define L1F_SRAM_RXF_LEN_SHIFT          0
+#define L1F_SRAM_RXF_LEN_8K             (8*1024)
+
+#define L1F_SRAM6                       0x1528
+#define L1F_SRAM_TXF_TAIL_ADDR_MASK     SHIFT16(0xFFFUL)
+#define L1F_SRAM_TXF_TAIL_ADDR_SHIFT    16
+#define L1F_SRAM_TXF_HEAD_ADDR_MASK     SHIFT0(0xFFFUL)
+#define L1F_SRAM_TXF_HEAD_ADDR_SHIFT    0
+
+#define L1F_SRAM7                       0x152C
+#define L1F_SRAM_TXF_LEN_MASK           SHIFT0(0xFFFUL) /* 8BYTES UNIT */
+#define L1F_SRAM_TXF_LEN_SHIFT          0
+
+#define L1F_SRAM8                       0x1530
+#define L1F_SRAM_PATTERN_ADDR_MASK      SHIFT16(0xFFFUL)
+#define L1F_SRAM_PATTERN_ADDR_SHIFT     16
+#define L1F_SRAM_TSO_ADDR_MASK          SHIFT0(0xFFFUL)
+#define L1F_SRAM_TSO_ADDR_SHIFT         0
+
+#define L1F_SRAM9                       0x1534
+#define L1F_SRAM_LOAD_PTR               BIT_0
+
+#define L1F_RX_BASE_ADDR_HI             0x1540
+
+#define L1F_TX_BASE_ADDR_HI             0x1544
+
+#define L1F_RFD_ADDR_LO                 0x1550
+#define L1F_RFD_RING_SZ                 0x1560
+#define L1F_RFD_BUF_SZ                  0x1564
+#define L1F_RFD_BUF_SZ_MASK             SHIFT0(0xFFFFUL)
+#define L1F_RFD_BUF_SZ_SHIFT            0
+
+#define L1F_RRD_ADDR_LO                 0x1568
+#define L1F_RRD_RING_SZ                 0x1578
+#define L1F_RRD_RING_SZ_MASK            SHIFT0(0xFFFUL)
+#define L1F_RRD_RING_SZ_SHIFT           0
+
+#define L1F_TPD_PRI3_ADDR_LO            0x14E4      /* HIGHEST PRIORITY */
+#define L1F_TPD_PRI2_ADDR_LO            0x14E0
+#define L1F_TPD_PRI1_ADDR_LO            0x157C
+#define L1F_TPD_PRI0_ADDR_LO            0x1580      /* LOWEST PRORITY */
+
+#define L1F_TPD_PRI3_PIDX               0x1618      /* 16BIT */
+#define L1F_TPD_PRI2_PIDX               0x161A      /* 16BIT */
+#define L1F_TPD_PRI1_PIDX               0x15F0      /* 16BIT */
+#define L1F_TPD_PRI0_PIDX               0x15F2      /* 16BIT */
+
+#define L1F_TPD_PRI3_CIDX               0x161C      /* 16BIT */
+#define L1F_TPD_PRI2_CIDX               0x161E      /* 16BIT */
+#define L1F_TPD_PRI1_CIDX               0x15F4      /* 16BIT */
+#define L1F_TPD_PRI0_CIDX               0x15F6      /* 16BIT */
+
+#define L1F_TPD_RING_SZ                 0x1584
+#define L1F_TPD_RING_SZ_MASK            SHIFT0(0xFFFFUL)
+#define L1F_TPD_RING_SZ_SHIFT           0
+
+#define L1F_CMB_ADDR_LO                 0x1588      /* NOT USED */
+
+#define L1F_TXQ0                        0x1590
+#define L1F_TXQ0_TXF_BURST_PREF_MASK    SHIFT16(0xFFFFUL)
+#define L1F_TXQ0_TXF_BURST_PREF_SHIFT   16
+#define L1F_TXQ_TXF_BURST_PREF_DEF      0x200
+#define L1F_TXQ0_PEDING_CLR             BIT_8
+#define L1F_TXQ0_LSO_8023_EN            BIT_7
+#define L1F_TXQ0_MODE_ENHANCE           BIT_6
+#define L1F_TXQ0_EN                     BIT_5
+#define L1F_TXQ0_SUPT_IPOPT             BIT_4
+#define L1F_TXQ0_TPD_BURSTPREF_MASK     SHIFT0(0xFUL)
+#define L1F_TXQ0_TPD_BURSTPREF_SHIFT    0
+#define L1F_TXQ_TPD_BURSTPREF_DEF       5
+
+#define L1F_TXQ1                        0x1594
+#define L1F_TXQ1_ERRLGPKT_DROP_EN       BIT_11          /* drop error large
+							 * (>rfd buf) packet */
+#define L1F_TXQ1_JUMBO_TSOTHR_MASK      SHIFT0(0x7FFUL) /* 8BYTES UNIT */
+#define L1F_TXQ1_JUMBO_TSOTHR_SHIFT     0
+#define L1F_TXQ1_JUMBO_TSO_TH           (7*1024)    /* byte */
+
+#define L1F_TXQ2                        0x1598          /* ENTER L1 CONTROL */
+#define L1F_TXQ2_BURST_EN               BIT_31
+#define L1F_TXQ2_BURST_HI_WM_MASK       SHIFT16(0xFFFUL)
+#define L1F_TXQ2_BURST_HI_WM_SHIFT      16
+#define L1F_TXQ2_BURST_LO_WM_MASK       SHIFT0(0xFFFUL)
+#define L1F_TXQ2_BURST_LO_WM_SHIFT      0
+
+#define L1F_RXQ0                        0x15A0
+#define L1F_RXQ0_EN                     BIT_31
+#define L1F_RXQ0_CUT_THRU_EN            BIT_30
+#define L1F_RXQ0_RSS_HASH_EN            BIT_29
+#define L1F_RXQ0_NON_IP_QTBL            BIT_28  /* 0:q0,1:table */
+#define L1F_RXQ0_RSS_MODE_MASK          SHIFT26(3UL)
+#define L1F_RXQ0_RSS_MODE_SHIFT         26
+#define L1F_RXQ0_RSS_MODE_DIS           0
+#define L1F_RXQ0_RSS_MODE_SQSI          1
+#define L1F_RXQ0_RSS_MODE_MQSI          2
+#define L1F_RXQ0_RSS_MODE_MQMI          3
+#define L1F_RXQ0_NUM_RFD_PREF_MASK      SHIFT20(0x3FUL)
+#define L1F_RXQ0_NUM_RFD_PREF_SHIFT     20
+#define L1F_RXQ0_NUM_RFD_PREF_DEF       8
+#define L1F_RXQ0_IDT_TBL_SIZE_MASK      SHIFT8(0x1FFUL)
+#define L1F_RXQ0_IDT_TBL_SIZE_SHIFT     8
+#define L1F_RXQ0_IDT_TBL_SIZE_DEF       0x100
+#define L1F_RXQ0_IPV6_PARSE_EN          BIT_7
+#define L1F_RXQ0_RSS_HSTYP_IPV6_TCP_EN  BIT_5
+#define L1F_RXQ0_RSS_HSTYP_IPV6_EN      BIT_4
+#define L1F_RXQ0_RSS_HSTYP_IPV4_TCP_EN  BIT_3
+#define L1F_RXQ0_RSS_HSTYP_IPV4_EN      BIT_2
+#define L1F_RXQ0_RSS_HSTYP_ALL          (\
+	L1F_RXQ0_RSS_HSTYP_IPV6_TCP_EN  |\
+	L1F_RXQ0_RSS_HSTYP_IPV4_TCP_EN  |\
+	L1F_RXQ0_RSS_HSTYP_IPV6_EN      |\
+	L1F_RXQ0_RSS_HSTYP_IPV4_EN)
+#define L1F_RXQ0_ASPM_THRESH_MASK       SHIFT0(3UL)
+#define L1F_RXQ0_ASPM_THRESH_SHIFT      0
+#define L1F_RXQ0_ASPM_THRESH_NO         0
+#define L1F_RXQ0_ASPM_THRESH_1M         1
+#define L1F_RXQ0_ASPM_THRESH_10M        2
+#define L1F_RXQ0_ASPM_THRESH_100M       3
+
+#define L1F_RXQ1                        0x15A4
+#define L1F_RXQ1_JUMBO_LKAH_MASK        SHIFT12(0xFUL)      /* 32BYTES UNIT */
+#define L1F_RXQ1_JUMBO_LKAH_SHIFT       12
+#define L1F_RXQ1_RFD_PREF_DOWN_MASK     SHIFT6(0x3FUL)
+#define L1F_RXQ1_RFD_PREF_DOWN_SHIFT    6
+#define L1F_RXQ1_RFD_PREF_UP_MASK       SHIFT0(0x3FUL)
+#define L1F_RXQ1_RFD_PREF_UP_SHIFT      0
+
+#define L1F_RXQ2                        0x15A8
+/* XOFF: USED SRAM LOWER THAN IT, THEN NOTIFY THE PEER TO SEND AGAIN */
+#define L1F_RXQ2_RXF_XOFF_THRESH_MASK   SHIFT16(0xFFFUL)
+#define L1F_RXQ2_RXF_XOFF_THRESH_SHIFT  16
+#define L1F_RXQ2_RXF_XON_THRESH_MASK    SHIFT0(0xFFFUL)
+#define L1F_RXQ2_RXF_XON_THRESH_SHIFT   0
+
+#define L1F_RXQ3                        0x15AC
+#define L1F_RXQ3_RXD_TIMER_MASK         SHIFT16(0x7FFFUL)
+#define L1F_RXQ3_RXD_TIMER_SHIFT        16
+#define L1F_RXQ3_RXD_THRESH_MASK        SHIFT0(0xFFFUL) /* 8BYTES UNIT */
+#define L1F_RXQ3_RXD_THRESH_SHIFT       0
+
+#define L1F_DMA                         0x15C0
+#define L1F_DMA_SMB_NOW                 BIT_31
+#define L1F_DMA_WPEND_CLR               BIT_30
+#define L1F_DMA_RPEND_CLR               BIT_29
+#define L1F_DMA_WSRAM_RDCTRL            BIT_28
+#define L1F_DMA_RCHNL_SEL_MASK          SHIFT26(3UL)
+#define L1F_DMA_RCHNL_SEL_SHIFT         26
+#define L1F_DMA_RCHNL_SEL_1             0
+#define L1F_DMA_RCHNL_SEL_2             1
+#define L1F_DMA_RCHNL_SEL_3             2
+#define L1F_DMA_RCHNL_SEL_4             3
+#define L1F_DMA_SMB_EN                  BIT_21      /* smb dma enable */
+#define L1F_DMA_WDLY_CNT_MASK           SHIFT16(0xFUL)
+#define L1F_DMA_WDLY_CNT_SHIFT          16
+#define L1F_DMA_WDLY_CNT_DEF            4
+#define L1F_DMA_RDLY_CNT_MASK           SHIFT11(0x1FUL)
+#define L1F_DMA_RDLY_CNT_SHIFT          11
+#define L1F_DMA_RDLY_CNT_DEF            15
+#define L1F_DMA_RREQ_PRI_DATA           BIT_10      /* 0:tpd, 1:data */
+#define L1F_DMA_WREQ_BLEN_MASK          SHIFT7(7UL)
+#define L1F_DMA_WREQ_BLEN_SHIFT         7
+#define L1F_DMA_RREQ_BLEN_MASK          SHIFT4(7UL)
+#define L1F_DMA_RREQ_BLEN_SHIFT         4
+#define L1F_DMA_PENDING_AUTO_RST        BIT_3
+#define L1F_DMA_RORDER_MODE_MASK        SHIFT0(7UL)
+#define L1F_DMA_RORDER_MODE_SHIFT       0
+#define L1F_DMA_RORDER_MODE_OUT         4
+#define L1F_DMA_RORDER_MODE_ENHANCE     2
+#define L1F_DMA_RORDER_MODE_IN          1
+
+#define L1F_WOL0                        0x14A0
+#define L1F_WOL0_PT7_MATCH              BIT_31
+#define L1F_WOL0_PT6_MATCH              BIT_30
+#define L1F_WOL0_PT5_MATCH              BIT_29
+#define L1F_WOL0_PT4_MATCH              BIT_28
+#define L1F_WOL0_PT3_MATCH              BIT_27
+#define L1F_WOL0_PT2_MATCH              BIT_26
+#define L1F_WOL0_PT1_MATCH              BIT_25
+#define L1F_WOL0_PT0_MATCH              BIT_24
+#define L1F_WOL0_PT7_EN                 BIT_23
+#define L1F_WOL0_PT6_EN                 BIT_22
+#define L1F_WOL0_PT5_EN                 BIT_21
+#define L1F_WOL0_PT4_EN                 BIT_20
+#define L1F_WOL0_PT3_EN                 BIT_19
+#define L1F_WOL0_PT2_EN                 BIT_18
+#define L1F_WOL0_PT1_EN                 BIT_17
+#define L1F_WOL0_PT0_EN                 BIT_16
+#define L1F_WOL0_IPV4_SYNC_EVT          BIT_14
+#define L1F_WOL0_IPV6_SYNC_EVT          BIT_13
+#define L1F_WOL0_LINK_EVT               BIT_10
+#define L1F_WOL0_MAGIC_EVT              BIT_9
+#define L1F_WOL0_PATTERN_EVT            BIT_8
+#define L1F_WOL0_OOB_EN                 BIT_6
+#define L1F_WOL0_PME_LINK               BIT_5
+#define L1F_WOL0_LINK_EN                BIT_4
+#define L1F_WOL0_PME_MAGIC_EN           BIT_3
+#define L1F_WOL0_MAGIC_EN               BIT_2
+#define L1F_WOL0_PME_PATTERN_EN         BIT_1
+#define L1F_WOL0_PATTERN_EN             BIT_0
+
+#define L1F_WOL1                        0x14A4
+#define L1F_WOL1_PT3_LEN_MASK           SHIFT24(0xFFUL)
+#define L1F_WOL1_PT3_LEN_SHIFT          24
+#define L1F_WOL1_PT2_LEN_MASK           SHIFT16(0xFFUL)
+#define L1F_WOL1_PT2_LEN_SHIFT          16
+#define L1F_WOL1_PT1_LEN_MASK           SHIFT8(0xFFUL)
+#define L1F_WOL1_PT1_LEN_SHIFT          8
+#define L1F_WOL1_PT0_LEN_MASK           SHIFT0(0xFFUL)
+#define L1F_WOL1_PT0_LEN_SHIFT          0
+
+#define L1F_WOL2                        0x14A8
+#define L1F_WOL2_PT7_LEN_MASK           SHIFT24(0xFFUL)
+#define L1F_WOL2_PT7_LEN_SHIFT          24
+#define L1F_WOL2_PT6_LEN_MASK           SHIFT16(0xFFUL)
+#define L1F_WOL2_PT6_LEN_SHIFT          16
+#define L1F_WOL2_PT5_LEN_MASK           SHIFT8(0xFFUL)
+#define L1F_WOL2_PT5_LEN_SHIFT          8
+#define L1F_WOL2_PT4_LEN_MASK           SHIFT0(0xFFUL)
+#define L1F_WOL2_PT4_LEN_SHIFT          0
+
+#define L1F_RFD_PIDX                    0x15E0
+#define L1F_RFD_PIDX_MASK               SHIFT0(0xFFFUL)
+#define L1F_RFD_PIDX_SHIFT              0
+
+#define L1F_RFD_CIDX                    0x15F8
+#define L1F_RFD_CIDX_MASK               SHIFT0(0xFFFUL)
+#define L1F_RFD_CIDX_SHIFT              0
+
+/* MIB */
+#define L1F_MIB_BASE                    0x1700
+#define L1F_MIB_RX_OK                   (L1F_MIB_BASE + 0)
+#define L1F_MIB_RX_BC                   (L1F_MIB_BASE + 4)
+#define L1F_MIB_RX_MC                   (L1F_MIB_BASE + 8)
+#define L1F_MIB_RX_PAUSE                (L1F_MIB_BASE + 12)
+#define L1F_MIB_RX_CTRL                 (L1F_MIB_BASE + 16)
+#define L1F_MIB_RX_FCS                  (L1F_MIB_BASE + 20)
+#define L1F_MIB_RX_LENERR               (L1F_MIB_BASE + 24)
+#define L1F_MIB_RX_BYTCNT               (L1F_MIB_BASE + 28)
+#define L1F_MIB_RX_RUNT                 (L1F_MIB_BASE + 32)
+#define L1F_MIB_RX_FRAGMENT             (L1F_MIB_BASE + 36)
+#define L1F_MIB_RX_64B                  (L1F_MIB_BASE + 40)
+#define L1F_MIB_RX_127B                 (L1F_MIB_BASE + 44)
+#define L1F_MIB_RX_255B                 (L1F_MIB_BASE + 48)
+#define L1F_MIB_RX_511B                 (L1F_MIB_BASE + 52)
+#define L1F_MIB_RX_1023B                (L1F_MIB_BASE + 56)
+#define L1F_MIB_RX_1518B                (L1F_MIB_BASE + 60)
+#define L1F_MIB_RX_SZMAX                (L1F_MIB_BASE + 64)
+#define L1F_MIB_RX_OVSZ                 (L1F_MIB_BASE + 68)
+#define L1F_MIB_RXF_OV                  (L1F_MIB_BASE + 72)
+#define L1F_MIB_RRD_OV                  (L1F_MIB_BASE + 76)
+#define L1F_MIB_RX_ALIGN                (L1F_MIB_BASE + 80)
+#define L1F_MIB_RX_BCCNT                (L1F_MIB_BASE + 84)
+#define L1F_MIB_RX_MCCNT                (L1F_MIB_BASE + 88)
+#define L1F_MIB_RX_ERRADDR              (L1F_MIB_BASE + 92)
+#define L1F_MIB_TX_OK                   (L1F_MIB_BASE + 96)
+#define L1F_MIB_TX_BC                   (L1F_MIB_BASE + 100)
+#define L1F_MIB_TX_MC                   (L1F_MIB_BASE + 104)
+#define L1F_MIB_TX_PAUSE                (L1F_MIB_BASE + 108)
+#define L1F_MIB_TX_EXCDEFER             (L1F_MIB_BASE + 112)
+#define L1F_MIB_TX_CTRL                 (L1F_MIB_BASE + 116)
+#define L1F_MIB_TX_DEFER                (L1F_MIB_BASE + 120)
+#define L1F_MIB_TX_BYTCNT               (L1F_MIB_BASE + 124)
+#define L1F_MIB_TX_64B                  (L1F_MIB_BASE + 128)
+#define L1F_MIB_TX_127B                 (L1F_MIB_BASE + 132)
+#define L1F_MIB_TX_255B                 (L1F_MIB_BASE + 136)
+#define L1F_MIB_TX_511B                 (L1F_MIB_BASE + 140)
+#define L1F_MIB_TX_1023B                (L1F_MIB_BASE + 144)
+#define L1F_MIB_TX_1518B                (L1F_MIB_BASE + 148)
+#define L1F_MIB_TX_SZMAX                (L1F_MIB_BASE + 152)
+#define L1F_MIB_TX_1COL                 (L1F_MIB_BASE + 156)
+#define L1F_MIB_TX_2COL                 (L1F_MIB_BASE + 160)
+#define L1F_MIB_TX_LATCOL               (L1F_MIB_BASE + 164)
+#define L1F_MIB_TX_ABRTCOL              (L1F_MIB_BASE + 168)
+#define L1F_MIB_TX_UNDRUN               (L1F_MIB_BASE + 172)
+#define L1F_MIB_TX_TRDBEOP              (L1F_MIB_BASE + 176)
+#define L1F_MIB_TX_LENERR               (L1F_MIB_BASE + 180)
+#define L1F_MIB_TX_TRUNC                (L1F_MIB_BASE + 184)
+#define L1F_MIB_TX_BCCNT                (L1F_MIB_BASE + 188)
+#define L1F_MIB_TX_MCCNT                (L1F_MIB_BASE + 192)
+#define L1F_MIB_UPDATE                  (L1F_MIB_BASE + 196)
+
+/******************************************************************************/
+
+#define L1F_ISR                         0x1600
+#define L1F_ISR_DIS                     BIT_31
+#define L1F_ISR_RX_Q7                   BIT_30
+#define L1F_ISR_RX_Q6                   BIT_29
+#define L1F_ISR_RX_Q5                   BIT_28
+#define L1F_ISR_RX_Q4                   BIT_27
+#define L1F_ISR_PCIE_LNKDOWN            BIT_26
+#define L1F_ISR_PCIE_CERR               BIT_25
+#define L1F_ISR_PCIE_NFERR              BIT_24
+#define L1F_ISR_PCIE_FERR               BIT_23
+#define L1F_ISR_PCIE_UR                 BIT_22
+#define L1F_ISR_MAC_TX                  BIT_21
+#define L1F_ISR_MAC_RX                  BIT_20
+#define L1F_ISR_RX_Q3                   BIT_19
+#define L1F_ISR_RX_Q2                   BIT_18
+#define L1F_ISR_RX_Q1                   BIT_17
+#define L1F_ISR_RX_Q0                   BIT_16
+#define L1F_ISR_TX_Q0                   BIT_15
+#define L1F_ISR_TXQ_TO                  BIT_14
+#define L1F_ISR_PHY_LPW                 BIT_13
+#define L1F_ISR_PHY                     BIT_12
+#define L1F_ISR_TX_CREDIT               BIT_11
+#define L1F_ISR_DMAW                    BIT_10
+#define L1F_ISR_DMAR                    BIT_9
+#define L1F_ISR_TXF_UR                  BIT_8
+#define L1F_ISR_TX_Q3                   BIT_7
+#define L1F_ISR_TX_Q2                   BIT_6
+#define L1F_ISR_TX_Q1                   BIT_5
+#define L1F_ISR_RFD_UR                  BIT_4
+#define L1F_ISR_RXF_OV                  BIT_3
+#define L1F_ISR_MANU                    BIT_2
+#define L1F_ISR_TIMER                   BIT_1
+#define L1F_ISR_SMB                     BIT_0
+
+#define L1F_IMR                         0x1604
+
+#define L1F_INT_RETRIG                  0x1608  /* re-send deassrt/assert
+						 * if sw no reflect */
+#define L1F_INT_RETRIG_TIMER_MASK       SHIFT0(0xFFFFUL)
+#define L1F_INT_RETRIG_TIMER_SHIFT      0
+#define L1F_INT_RETRIG_TO               20000   /* 40ms */
+
+#define L1F_INT_DEASST_TIMER            0x1614  /* re-send deassert
+						 * if sw no reflect */
+
+#define L1F_PATTERN_MASK                0x1620  /* 128bytes, sleep state */
+#define L1F_PATTERN_MASK_LEN            128
+
+
+#define L1F_FLT1_SRC_IP0                0x1A00
+#define L1F_FLT1_SRC_IP1                0x1A04
+#define L1F_FLT1_SRC_IP2                0x1A08
+#define L1F_FLT1_SRC_IP3                0x1A0C
+#define L1F_FLT1_DST_IP0                0x1A10
+#define L1F_FLT1_DST_IP1                0x1A14
+#define L1F_FLT1_DST_IP2                0x1A18
+#define L1F_FLT1_DST_IP3                0x1A1C
+#define L1F_FLT1_PORT                   0x1A20
+#define L1F_FLT1_PORT_DST_MASK          SHIFT16(0xFFFFUL)
+#define L1F_FLT1_PORT_DST_SHIFT         16
+#define L1F_FLT1_PORT_SRC_MASK          SHIFT0(0xFFFFUL)
+#define L1F_FLT1_PORT_SRC_SHIFT         0
+
+#define L1F_FLT2_SRC_IP0                0x1A24
+#define L1F_FLT2_SRC_IP1                0x1A28
+#define L1F_FLT2_SRC_IP2                0x1A2C
+#define L1F_FLT2_SRC_IP3                0x1A30
+#define L1F_FLT2_DST_IP0                0x1A34
+#define L1F_FLT2_DST_IP1                0x1A38
+#define L1F_FLT2_DST_IP2                0x1A40
+#define L1F_FLT2_DST_IP3                0x1A44
+#define L1F_FLT2_PORT                   0x1A48
+#define L1F_FLT2_PORT_DST_MASK          SHIFT16(0xFFFFUL)
+#define L1F_FLT2_PORT_DST_SHIFT         16
+#define L1F_FLT2_PORT_SRC_MASK          SHIFT0(0xFFFFUL)
+#define L1F_FLT2_PORT_SRC_SHIFT         0
+
+#define L1F_FLT3_SRC_IP0                0x1A4C
+#define L1F_FLT3_SRC_IP1                0x1A50
+#define L1F_FLT3_SRC_IP2                0x1A54
+#define L1F_FLT3_SRC_IP3                0x1A58
+#define L1F_FLT3_DST_IP0                0x1A5C
+#define L1F_FLT3_DST_IP1                0x1A60
+#define L1F_FLT3_DST_IP2                0x1A64
+#define L1F_FLT3_DST_IP3                0x1A68
+#define L1F_FLT3_PORT                   0x1A6C
+#define L1F_FLT3_PORT_DST_MASK          SHIFT16(0xFFFFUL)
+#define L1F_FLT3_PORT_DST_SHIFT         16
+#define L1F_FLT3_PORT_SRC_MASK          SHIFT0(0xFFFFUL)
+#define L1F_FLT3_PORT_SRC_SHIFT         0
+
+#define L1F_FLT4_SRC_IP0                0x1A70
+#define L1F_FLT4_SRC_IP1                0x1A74
+#define L1F_FLT4_SRC_IP2                0x1A78
+#define L1F_FLT4_SRC_IP3                0x1A7C
+#define L1F_FLT4_DST_IP0                0x1A80
+#define L1F_FLT4_DST_IP1                0x1A84
+#define L1F_FLT4_DST_IP2                0x1A88
+#define L1F_FLT4_DST_IP3                0x1A8C
+#define L1F_FLT4_PORT                   0x1A90
+#define L1F_FLT4_PORT_DST_MASK          SHIFT16(0xFFFFUL)
+#define L1F_FLT4_PORT_DST_SHIFT         16
+#define L1F_FLT4_PORT_SRC_MASK          SHIFT0(0xFFFFUL)
+#define L1F_FLT4_PORT_SRC_SHIFT         0
+
+#define L1F_FLT5_SRC_IP0                0x1A94
+#define L1F_FLT5_SRC_IP1                0x1A98
+#define L1F_FLT5_SRC_IP2                0x1A9C
+#define L1F_FLT5_SRC_IP3                0x1AA0
+#define L1F_FLT5_DST_IP0                0x1AA4
+#define L1F_FLT5_DST_IP1                0x1AA8
+#define L1F_FLT5_DST_IP2                0x1AAC
+#define L1F_FLT5_DST_IP3                0x1AB0
+#define L1F_FLT5_PORT                   0x1AB4
+#define L1F_FLT5_PORT_DST_MASK          SHIFT16(0xFFFFUL)
+#define L1F_FLT5_PORT_DST_SHIFT         16
+#define L1F_FLT5_PORT_SRC_MASK          SHIFT0(0xFFFFUL)
+#define L1F_FLT5_PORT_SRC_SHIFT         0
+
+#define L1F_FLT6_SRC_IP0                0x1AB8
+#define L1F_FLT6_SRC_IP1                0x1ABC
+#define L1F_FLT6_SRC_IP2                0x1AC0
+#define L1F_FLT6_SRC_IP3                0x1AC8
+#define L1F_FLT6_DST_IP0                0x1620  /* only S0 state */
+#define L1F_FLT6_DST_IP1                0x1624
+#define L1F_FLT6_DST_IP2                0x1628
+#define L1F_FLT6_DST_IP3                0x162C
+#define L1F_FLT6_PORT                   0x1630
+#define L1F_FLT6_PORT_DST_MASK          SHIFT16(0xFFFFUL)
+#define L1F_FLT6_PORT_DST_SHIFT         16
+#define L1F_FLT6_PORT_SRC_MASK          SHIFT0(0xFFFFUL)
+#define L1F_FLT6_PORT_SRC_SHIFT         0
+
+#define L1F_FLTCTRL                     0x1634
+#define L1F_FLTCTRL_PSTHR_TIMER_MASK    SHIFT24(0xFFUL)
+#define L1F_FLTCTRL_PSTHR_TIMER_SHIFT   24
+#define L1F_FLTCTRL_CHK_DSTPRT6         BIT_23
+#define L1F_FLTCTRL_CHK_SRCPRT6         BIT_22
+#define L1F_FLTCTRL_CHK_DSTIP6          BIT_21
+#define L1F_FLTCTRL_CHK_SRCIP6          BIT_20
+#define L1F_FLTCTRL_CHK_DSTPRT5         BIT_19
+#define L1F_FLTCTRL_CHK_SRCPRT5         BIT_18
+#define L1F_FLTCTRL_CHK_DSTIP5          BIT_17
+#define L1F_FLTCTRL_CHK_SRCIP5          BIT_16
+#define L1F_FLTCTRL_CHK_DSTPRT4         BIT_15
+#define L1F_FLTCTRL_CHK_SRCPRT4         BIT_14
+#define L1F_FLTCTRL_CHK_DSTIP4          BIT_13
+#define L1F_FLTCTRL_CHK_SRCIP4          BIT_12
+#define L1F_FLTCTRL_CHK_DSTPRT3         BIT_11
+#define L1F_FLTCTRL_CHK_SRCPRT3         BIT_10
+#define L1F_FLTCTRL_CHK_DSTIP3          BIT_9
+#define L1F_FLTCTRL_CHK_SRCIP3          BIT_8
+#define L1F_FLTCTRL_CHK_DSTPRT2         BIT_7
+#define L1F_FLTCTRL_CHK_SRCPRT2         BIT_6
+#define L1F_FLTCTRL_CHK_DSTIP2          BIT_5
+#define L1F_FLTCTRL_CHK_SRCIP2          BIT_4
+#define L1F_FLTCTRL_CHK_DSTPRT1         BIT_3
+#define L1F_FLTCTRL_CHK_SRCPRT1         BIT_2
+#define L1F_FLTCTRL_CHK_DSTIP1          BIT_1
+#define L1F_FLTCTRL_CHK_SRCIP1          BIT_0
+
+#define L1F_DROP_ALG1                   0x1638
+#define L1F_DROP_ALG1_BWCHGVAL_MASK     SHIFT12(0xFFFFFUL)
+#define L1F_DROP_ALG1_BWCHGVAL_SHIFT    12
+#define L1F_DROP_ALG1_BWCHGSCL_6        BIT_11      /* 0:3.125%, 1:6.25% */
+#define L1F_DROP_ALG1_ASUR_LWQ_EN       BIT_10
+#define L1F_DROP_ALG1_BWCHGVAL_EN       BIT_9
+#define L1F_DROP_ALG1_BWCHGSCL_EN       BIT_8
+#define L1F_DROP_ALG1_PSTHR_AUTO        BIT_7       /* 0:manual, 1:auto */
+#define L1F_DROP_ALG1_MIN_PSTHR_MASK    SHIFT5(3UL)
+#define L1F_DROP_ALG1_MIN_PSTHR_SHIFT   5
+#define L1F_DROP_ALG1_MIN_PSTHR_1_16    0
+#define L1F_DROP_ALG1_MIN_PSTHR_1_8     1
+#define L1F_DROP_ALG1_MIN_PSTHR_1_4     2
+#define L1F_DROP_ALG1_MIN_PSTHR_1_2     3
+#define L1F_DROP_ALG1_PSCL_MASK         SHIFT3(3UL)
+#define L1F_DROP_ALG1_PSCL_SHIFT        3
+#define L1F_DROP_ALG1_PSCL_1_4          0
+#define L1F_DROP_ALG1_PSCL_1_8          1
+#define L1F_DROP_ALG1_PSCL_1_16         2
+#define L1F_DROP_ALG1_PSCL_1_32         3
+#define L1F_DROP_ALG1_TIMESLOT_MASK     SHIFT0(7UL)
+#define L1F_DROP_ALG1_TIMESLOT_SHIFT    0
+#define L1F_DROP_ALG1_TIMESLOT_4MS      0
+#define L1F_DROP_ALG1_TIMESLOT_8MS      1
+#define L1F_DROP_ALG1_TIMESLOT_16MS     2
+#define L1F_DROP_ALG1_TIMESLOT_32MS     3
+#define L1F_DROP_ALG1_TIMESLOT_64MS     4
+#define L1F_DROP_ALG1_TIMESLOT_128MS    5
+#define L1F_DROP_ALG1_TIMESLOT_256MS    6
+#define L1F_DROP_ALG1_TIMESLOT_512MS    7
+
+#define L1F_DROP_ALG2                   0x163C
+#define L1F_DROP_ALG2_SMPLTIME_MASK     SHIFT24(0xFUL)
+#define L1F_DROP_ALG2_SMPLTIME_SHIFT    24
+#define L1F_DROP_ALG2_LWQBW_MASK        SHIFT0(0xFFFFFFUL)
+#define L1F_DROP_ALG2_LWQBW_SHIFT       0
+
+#define L1F_SMB_TIMER                   0x15C4
+
+#define L1F_TINT_TPD_THRSHLD            0x15C8
+
+#define L1F_TINT_TIMER                  0x15CC
+
+#define L1F_CLK_GATE                    0x1814
+#define L1F_CLK_GATE_125M_SW_DIS_CR     BIT_8       /* B0 */
+#define L1F_CLK_GATE_125M_SW_AZ         BIT_7       /* B0 */
+#define L1F_CLK_GATE_125M_SW_IDLE       BIT_6       /* B0 */
+#define L1F_CLK_GATE_RXMAC              BIT_5
+#define L1F_CLK_GATE_TXMAC              BIT_4
+#define L1F_CLK_GATE_RXQ                BIT_3
+#define L1F_CLK_GATE_TXQ                BIT_2
+#define L1F_CLK_GATE_DMAR               BIT_1
+#define L1F_CLK_GATE_DMAW               BIT_0
+#define L1F_CLK_GATE_ALL_A0         (\
+	L1F_CLK_GATE_RXMAC          |\
+	L1F_CLK_GATE_TXMAC          |\
+	L1F_CLK_GATE_RXQ            |\
+	L1F_CLK_GATE_TXQ            |\
+	L1F_CLK_GATE_DMAR           |\
+	L1F_CLK_GATE_DMAW)
+#define L1F_CLK_GATE_ALL_B0         (\
+	L1F_CLK_GATE_ALL_A0         |\
+	L1F_CLK_GATE_125M_SW_AZ     |\
+	L1F_CLK_GATE_125M_SW_IDLE)
+
+
+
+
+
+#define L1F_BTROM_CFG                   0x1800          /* pwon rst */
+
+#define L1F_DRV                         0x1804
+/* bit definition is in lx_hwcomm.h */
+
+#define L1F_DRV_ERR1                    0x1808          /* perst */
+#define L1F_DRV_ERR1_GEN                BIT_31          /* geneneral err */
+#define L1F_DRV_ERR1_NOR                BIT_30          /* rrd.nor */
+#define L1F_DRV_ERR1_TRUNC              BIT_29
+#define L1F_DRV_ERR1_RES                BIT_28
+#define L1F_DRV_ERR1_INTFATAL           BIT_27
+#define L1F_DRV_ERR1_TXQPEND            BIT_26
+#define L1F_DRV_ERR1_DMAW               BIT_25
+#define L1F_DRV_ERR1_DMAR               BIT_24
+#define L1F_DRV_ERR1_PCIELNKDWN         BIT_23
+#define L1F_DRV_ERR1_PKTSIZE            BIT_22
+#define L1F_DRV_ERR1_FIFOFUL            BIT_21
+#define L1F_DRV_ERR1_RFDUR              BIT_20
+#define L1F_DRV_ERR1_RRDSI              BIT_19
+#define L1F_DRV_ERR1_UPDATE             BIT_18
+
+#define L1F_DRV_ERR2                    0x180C
+
+#define L1F_DBG_ADDR                    0x1900  /* DWORD reg */
+#define L1F_DBG_DATA                    0x1904  /* DWORD reg */
+
+#define L1F_SYNC_IPV4_SA                0x1A00
+#define L1F_SYNC_IPV4_DA                0x1A04
+
+#define L1F_SYNC_V4PORT                 0x1A08
+#define L1F_SYNC_V4PORT_DST_MASK        SHIFT16(0xFFFFUL)
+#define L1F_SYNC_V4PORT_DST_SHIFT       16
+#define L1F_SYNC_V4PORT_SRC_MASK        SHIFT0(0xFFFFUL)
+#define L1F_SYNC_V4PORT_SRC_SHIFT       0
+
+#define L1F_SYNC_IPV6_SA0               0x1A0C
+#define L1F_SYNC_IPV6_SA1               0x1A10
+#define L1F_SYNC_IPV6_SA2               0x1A14
+#define L1F_SYNC_IPV6_SA3               0x1A18
+#define L1F_SYNC_IPV6_DA0               0x1A1C
+#define L1F_SYNC_IPV6_DA1               0x1A20
+#define L1F_SYNC_IPV6_DA2               0x1A24
+#define L1F_SYNC_IPV6_DA3               0x1A28
+
+#define L1F_SYNC_V6PORT                 0x1A2C
+#define L1F_SYNC_V6PORT_DST_MASK        SHIFT16(0xFFFFUL)
+#define L1F_SYNC_V6PORT_DST_SHIFT       16
+#define L1F_SYNC_V6PORT_SRC_MASK        SHIFT0(0xFFFFUL)
+#define L1F_SYNC_V6PORT_SRC_SHIFT       0
+
+#define L1F_ARP_REMOTE_IPV4             0x1A30
+#define L1F_ARP_HOST_IPV4               0x1A34
+#define L1F_ARP_MAC0                    0x1A38
+#define L1F_ARP_MAC1                    0x1A3C
+
+#define L1F_1ST_REMOTE_IPV6_0           0x1A40
+#define L1F_1ST_REMOTE_IPV6_1           0x1A44
+#define L1F_1ST_REMOTE_IPV6_2           0x1A48
+#define L1F_1ST_REMOTE_IPV6_3           0x1A4C
+
+#define L1F_1ST_SN_IPV6_0               0x1A50
+#define L1F_1ST_SN_IPV6_1               0x1A54
+#define L1F_1ST_SN_IPV6_2               0x1A58
+#define L1F_1ST_SN_IPV6_3               0x1A5C
+
+#define L1F_1ST_TAR_IPV6_1_0            0x1A60
+#define L1F_1ST_TAR_IPV6_1_1            0x1A64
+#define L1F_1ST_TAR_IPV6_1_2            0x1A68
+#define L1F_1ST_TAR_IPV6_1_3            0x1A6C
+#define L1F_1ST_TAR_IPV6_2_0            0x1A70
+#define L1F_1ST_TAR_IPV6_2_1            0x1A74
+#define L1F_1ST_TAR_IPV6_2_2            0x1A78
+#define L1F_1ST_TAR_IPV6_2_3            0x1A7C
+
+#define L1F_2ND_REMOTE_IPV6_0           0x1A80
+#define L1F_2ND_REMOTE_IPV6_1           0x1A84
+#define L1F_2ND_REMOTE_IPV6_2           0x1A88
+#define L1F_2ND_REMOTE_IPV6_3           0x1A8C
+
+#define L1F_2ND_SN_IPV6_0               0x1A90
+#define L1F_2ND_SN_IPV6_1               0x1A94
+#define L1F_2ND_SN_IPV6_2               0x1A98
+#define L1F_2ND_SN_IPV6_3               0x1A9C
+
+#define L1F_2ND_TAR_IPV6_1_0            0x1AA0
+#define L1F_2ND_TAR_IPV6_1_1            0x1AA4
+#define L1F_2ND_TAR_IPV6_1_2            0x1AA8
+#define L1F_2ND_TAR_IPV6_1_3            0x1AAC
+#define L1F_2ND_TAR_IPV6_2_0            0x1AB0
+#define L1F_2ND_TAR_IPV6_2_1            0x1AB4
+#define L1F_2ND_TAR_IPV6_2_2            0x1AB8
+#define L1F_2ND_TAR_IPV6_2_3            0x1ABC
+
+#define L1F_1ST_NS_MAC0                 0x1AC0
+#define L1F_1ST_NS_MAC1                 0x1AC4
+
+#define L1F_2ND_NS_MAC0                 0x1AC8
+#define L1F_2ND_NS_MAC1                 0x1ACC
+
+#define L1F_PMOFLD                      0x144C
+#define L1F_PMOFLD_ECMA_IGNR_FRG_SSSR   BIT_11  /* B0 */
+#define L1F_PMOFLD_ARP_CNFLCT_WAKEUP    BIT_10  /* B0 */
+#define L1F_PMOFLD_MULTI_SOLD           BIT_9
+#define L1F_PMOFLD_ICMP_XSUM            BIT_8
+#define L1F_PMOFLD_GARP_REPLY           BIT_7
+#define L1F_PMOFLD_SYNCV6_ANY           BIT_6
+#define L1F_PMOFLD_SYNCV4_ANY           BIT_5
+#define L1F_PMOFLD_BY_HW                BIT_4
+#define L1F_PMOFLD_NS_EN                BIT_3
+#define L1F_PMOFLD_ARP_EN               BIT_2
+#define L1F_PMOFLD_SYNCV6_EN            BIT_1
+#define L1F_PMOFLD_SYNCV4_EN            BIT_0
+
+#define L1F_RSS_KEY0                    0x14B0
+#define L1F_RSS_KEY1                    0x14B4
+#define L1F_RSS_KEY2                    0x14B8
+#define L1F_RSS_KEY3                    0x14BC
+#define L1F_RSS_KEY4                    0x14C0
+#define L1F_RSS_KEY5                    0x14C4
+#define L1F_RSS_KEY6                    0x14C8
+#define L1F_RSS_KEY7                    0x14CC
+#define L1F_RSS_KEY8                    0x14D0
+#define L1F_RSS_KEY9                    0x14D4
+
+#define L1F_RSS_IDT_TBL0                0x1B00
+#define L1F_RSS_IDT_TBL1                0x1B04
+#define L1F_RSS_IDT_TBL2                0x1B08
+#define L1F_RSS_IDT_TBL3                0x1B0C
+#define L1F_RSS_IDT_TBL4                0x1B10
+#define L1F_RSS_IDT_TBL5                0x1B14
+#define L1F_RSS_IDT_TBL6                0x1B18
+#define L1F_RSS_IDT_TBL7                0x1B1C
+#define L1F_RSS_IDT_TBL8                0x1B20
+#define L1F_RSS_IDT_TBL9                0x1B24
+#define L1F_RSS_IDT_TBL10               0x1B28
+#define L1F_RSS_IDT_TBL11               0x1B2C
+#define L1F_RSS_IDT_TBL12               0x1B30
+#define L1F_RSS_IDT_TBL13               0x1B34
+#define L1F_RSS_IDT_TBL14               0x1B38
+#define L1F_RSS_IDT_TBL15               0x1B3C
+#define L1F_RSS_IDT_TBL16               0x1B40
+#define L1F_RSS_IDT_TBL17               0x1B44
+#define L1F_RSS_IDT_TBL18               0x1B48
+#define L1F_RSS_IDT_TBL19               0x1B4C
+#define L1F_RSS_IDT_TBL20               0x1B50
+#define L1F_RSS_IDT_TBL21               0x1B54
+#define L1F_RSS_IDT_TBL22               0x1B58
+#define L1F_RSS_IDT_TBL23               0x1B5C
+#define L1F_RSS_IDT_TBL24               0x1B60
+#define L1F_RSS_IDT_TBL25               0x1B64
+#define L1F_RSS_IDT_TBL26               0x1B68
+#define L1F_RSS_IDT_TBL27               0x1B6C
+#define L1F_RSS_IDT_TBL28               0x1B70
+#define L1F_RSS_IDT_TBL29               0x1B74
+#define L1F_RSS_IDT_TBL30               0x1B78
+#define L1F_RSS_IDT_TBL31               0x1B7C
+
+#define L1F_RSS_HASH_VAL                0x15B0
+#define L1F_RSS_HASH_FLAG               0x15B4
+
+#define L1F_RSS_BASE_CPU_NUM            0x15B8
+
+#define L1F_MSI_MAP_TBL1                0x15D0
+#define L1F_MSI_MAP_TBL1_ALERT_MASK     SHIFT28(0xFUL)
+#define L1F_MSI_MAP_TBL1_ALERT_SHIFT    28
+#define L1F_MSI_MAP_TBL1_TIMER_MASK     SHIFT24(0xFUL)
+#define L1F_MSI_MAP_TBL1_TIMER_SHIFT    24
+#define L1F_MSI_MAP_TBL1_TXQ1_MASK      SHIFT20(0xFUL)
+#define L1F_MSI_MAP_TBL1_TXQ1_SHIFT     20
+#define L1F_MSI_MAP_TBL1_TXQ0_MASK      SHIFT16(0xFUL)
+#define L1F_MSI_MAP_TBL1_TXQ0_SHIFT     16
+#define L1F_MSI_MAP_TBL1_RXQ3_MASK      SHIFT12(0xFUL)
+#define L1F_MSI_MAP_TBL1_RXQ3_SHIFT     12
+#define L1F_MSI_MAP_TBL1_RXQ2_MASK      SHIFT8(0xFUL)
+#define L1F_MSI_MAP_TBL1_RXQ2_SHIFT     8
+#define L1F_MSI_MAP_TBL1_RXQ1_MASK      SHIFT4(0xFUL)
+#define L1F_MSI_MAP_TBL1_RXQ1_SHIFT     4
+#define L1F_MSI_MAP_TBL1_RXQ0_MASK      SHIFT0(0xFUL)
+#define L1F_MSI_MAP_TBL1_RXQ0_SHIFT     0
+
+#define L1F_MSI_MAP_TBL2                0x15D8
+#define L1F_MSI_MAP_TBL2_PHY_MASK       SHIFT28(0xFUL)
+#define L1F_MSI_MAP_TBL2_PHY_SHIFT      28
+#define L1F_MSI_MAP_TBL2_SMB_MASK       SHIFT24(0xFUL)
+#define L1F_MSI_MAP_TBL2_SMB_SHIFT      24
+#define L1F_MSI_MAP_TBL2_TXQ3_MASK      SHIFT20(0xFUL)
+#define L1F_MSI_MAP_TBL2_TXQ3_SHIFT     20
+#define L1F_MSI_MAP_TBL2_TXQ2_MASK      SHIFT16(0xFUL)
+#define L1F_MSI_MAP_TBL2_TXQ2_SHIFT     16
+#define L1F_MSI_MAP_TBL2_RXQ7_MASK      SHIFT12(0xFUL)
+#define L1F_MSI_MAP_TBL2_RXQ7_SHIFT     12
+#define L1F_MSI_MAP_TBL2_RXQ6_MASK      SHIFT8(0xFUL)
+#define L1F_MSI_MAP_TBL2_RXQ6_SHIFT     8
+#define L1F_MSI_MAP_TBL2_RXQ5_MASK      SHIFT4(0xFUL)
+#define L1F_MSI_MAP_TBL2_RXQ5_SHIFT     4
+#define L1F_MSI_MAP_TBL2_RXQ4_MASK      SHIFT0(0xFUL)
+#define L1F_MSI_MAP_TBL2_RXQ4_SHIFT     0
+
+#define L1F_MSI_ID_MAP                  0x15D4
+#define L1F_MSI_ID_MAP_RXQ7             BIT_30
+#define L1F_MSI_ID_MAP_RXQ6             BIT_29
+#define L1F_MSI_ID_MAP_RXQ5             BIT_28
+#define L1F_MSI_ID_MAP_RXQ4             BIT_27
+#define L1F_MSI_ID_MAP_PCIELNKDW        BIT_26  /* 0:common,1:timer */
+#define L1F_MSI_ID_MAP_PCIECERR         BIT_25
+#define L1F_MSI_ID_MAP_PCIENFERR        BIT_24
+#define L1F_MSI_ID_MAP_PCIEFERR         BIT_23
+#define L1F_MSI_ID_MAP_PCIEUR           BIT_22
+#define L1F_MSI_ID_MAP_MACTX            BIT_21
+#define L1F_MSI_ID_MAP_MACRX            BIT_20
+#define L1F_MSI_ID_MAP_RXQ3             BIT_19
+#define L1F_MSI_ID_MAP_RXQ2             BIT_18
+#define L1F_MSI_ID_MAP_RXQ1             BIT_17
+#define L1F_MSI_ID_MAP_RXQ0             BIT_16
+#define L1F_MSI_ID_MAP_TXQ0             BIT_15
+#define L1F_MSI_ID_MAP_TXQTO            BIT_14
+#define L1F_MSI_ID_MAP_LPW              BIT_13
+#define L1F_MSI_ID_MAP_PHY              BIT_12
+#define L1F_MSI_ID_MAP_TXCREDIT         BIT_11
+#define L1F_MSI_ID_MAP_DMAW             BIT_10
+#define L1F_MSI_ID_MAP_DMAR             BIT_9
+#define L1F_MSI_ID_MAP_TXFUR            BIT_8
+#define L1F_MSI_ID_MAP_TXQ3             BIT_7
+#define L1F_MSI_ID_MAP_TXQ2             BIT_6
+#define L1F_MSI_ID_MAP_TXQ1             BIT_5
+#define L1F_MSI_ID_MAP_RFDUR            BIT_4
+#define L1F_MSI_ID_MAP_RXFOV            BIT_3
+#define L1F_MSI_ID_MAP_MANU             BIT_2
+#define L1F_MSI_ID_MAP_TIMER            BIT_1
+#define L1F_MSI_ID_MAP_SMB              BIT_0
+
+#define L1F_MSI_RETRANS_TIMER           0x1920
+#define L1F_MSI_MASK_SEL_LINE           BIT_16  /* 1:line,0:standard*/
+#define L1F_MSI_RETRANS_TM_MASK         SHIFT0(0xFFFFUL)
+#define L1F_MSI_RETRANS_TM_SHIFT        0
+
+#define L1F_CR_DMA_CTRL                 0x1930
+#define L1F_CR_DMA_CTRL_PRI             BIT_22
+#define L1F_CR_DMA_CTRL_RRDRXD_JOINT    BIT_21
+#define L1F_CR_DMA_CTRL_BWCREDIT_MASK   SHIFT_19(0x3UL)
+#define L1F_CR_DMA_CTRL_BWCREDIT_SHIFT  19
+#define L1F_CR_DMA_CTRL_BWCREDIT_2KB    0
+#define L1F_CR_DMA_CTRL_BWCREDIT_1KB    1
+#define L1F_CR_DMA_CTRL_BWCREDIT_4KB    2
+#define L1F_CR_DMA_CTRL_BWCREDIT_8KB    3
+#define L1F_CR_DMA_CTRL_BW_EN           BIT_18
+#define L1F_CR_DMA_CTRL_BW_RATIO_MASK   SHIFT_16(0x3UL)
+#define L1F_CR_DMA_CTRL_BW_RATIO_1_2    0
+#define L1F_CR_DMA_CTRL_BW_RATIO_1_4    1
+#define L1F_CR_DMA_CTRL_BW_RATIO_1_8    2
+#define L1F_CR_DMA_CTRL_BW_RATIO_2_1    3
+#define L1F_CR_DMA_CTRL_SOFT_RST        BIT_11
+#define L1F_CR_DMA_CTRL_TXEARLY_EN      BIT_10
+#define L1F_CR_DMA_CTRL_RXEARLY_EN      BIT_9
+#define L1F_CR_DMA_CTRL_WEARLY_EN       BIT_8
+#define L1F_CR_DMA_CTRL_RXTH_MASK       SHIFT_4(0xFUL)
+#define L1F_CR_DMA_CTRL_WTH_MASK        SHIFT_0(0xFUL)
+
+
+#define L1F_EFUSE_BIST                  0x1934
+#define L1F_EFUSE_BIST_COL_MASK         SHIFT24(0x3FUL)
+#define L1F_EFUSE_BIST_COL_SHIFT        24
+#define L1F_EFUSE_BIST_ROW_MASK         SHIFT12(0x7FUL)
+#define L1F_EFUSE_BIST_ROW_SHIFT        12
+#define L1F_EFUSE_BIST_STEP_MASK        SHIFT8(0xFUL)
+#define L1F_EFUSE_BIST_STEP_SHIFT       8
+#define L1F_EFUSE_BIST_PAT_MASK         SHIFT4(0x7UL)
+#define L1F_EFUSE_BIST_PAT_SHIFT        4
+#define L1F_EFUSE_BIST_CRITICAL         BIT_3
+#define L1F_EFUSE_BIST_FIXED            BIT_2
+#define L1F_EFUSE_BIST_FAIL             BIT_1
+#define L1F_EFUSE_BIST_NOW              BIT_0
+
+/* CR DMA ctrl */
+
+/* TX QoS */
+#define L1F_WRR                         0x1938
+#define L1F_WRR_PRI_MASK                SHIFT29(3UL)
+#define L1F_WRR_PRI_SHIFT               29
+#define L1F_WRR_PRI_RESTRICT_ALL        0
+#define L1F_WRR_PRI_RESTRICT_HI         1
+#define L1F_WRR_PRI_RESTRICT_HI2        2
+#define L1F_WRR_PRI_RESTRICT_NONE       3
+#define L1F_WRR_PRI3_MASK               SHIFT24(0x1FUL)
+#define L1F_WRR_PRI3_SHIFT              24
+#define L1F_WRR_PRI2_MASK               SHIFT16(0x1FUL)
+#define L1F_WRR_PRI2_SHIFT              16
+#define L1F_WRR_PRI1_MASK               SHIFT8(0x1FUL)
+#define L1F_WRR_PRI1_SHIFT              8
+#define L1F_WRR_PRI0_MASK               SHIFT0(0x1FUL)
+#define L1F_WRR_PRI0_SHIFT              0
+
+#define L1F_HQTPD                       0x193C
+#define L1F_HQTPD_BURST_EN              BIT_31
+#define L1F_HQTPD_Q3_NUMPREF_MASK       SHIFT8(0xFUL)
+#define L1F_HQTPD_Q3_NUMPREF_SHIFT      8
+#define L1F_HQTPD_Q2_NUMPREF_MASK       SHIFT4(0xFUL)
+#define L1F_HQTPD_Q2_NUMPREF_SHIFT      4
+#define L1F_HQTPD_Q1_NUMPREF_MASK       SHIFT0(0xFUL)
+#define L1F_HQTPD_Q1_NUMPREF_SHIFT      0
+
+#define L1F_CPUMAP1                     0x19A0
+#define L1F_CPUMAP1_VCT7_MASK           SHIFT28(0xFUL)
+#define L1F_CPUMAP1_VCT7_SHIFT          28
+#define L1F_CPUMAP1_VCT6_MASK           SHIFT24(0xFUL)
+#define L1F_CPUMAP1_VCT6_SHIFT          24
+#define L1F_CPUMAP1_VCT5_MASK           SHIFT20(0xFUL)
+#define L1F_CPUMAP1_VCT5_SHIFT          20
+#define L1F_CPUMAP1_VCT4_MASK           SHIFT16(0xFUL)
+#define L1F_CPUMAP1_VCT4_SHIFT          16
+#define L1F_CPUMAP1_VCT3_MASK           SHIFT12(0xFUL)
+#define L1F_CPUMAP1_VCT3_SHIFT          12
+#define L1F_CPUMAP1_VCT2_MASK           SHIFT8(0xFUL)
+#define L1F_CPUMAP1_VCT2_SHIFT          8
+#define L1F_CPUMAP1_VCT1_MASK           SHIFT4(0xFUL)
+#define L1F_CPUMAP1_VCT1_SHIFT          4
+#define L1F_CPUMAP1_VCT0_MASK           SHIFT0(0xFUL)
+#define L1F_CPUMAP1_VCT0_SHIFT          0
+
+#define L1F_CPUMAP2                     0x19A4
+#define L1F_CPUMAP2_VCT15_MASK          SHIFT28(0xFUL)
+#define L1F_CPUMAP2_VCT15_SHIFT         28
+#define L1F_CPUMAP2_VCT14_MASK          SHIFT24(0xFUL)
+#define L1F_CPUMAP2_VCT14_SHIFT         24
+#define L1F_CPUMAP2_VCT13_MASK          SHIFT20(0xFUL)
+#define L1F_CPUMAP2_VCT13_SHIFT         20
+#define L1F_CPUMAP2_VCT12_MASK          SHIFT16(0xFUL)
+#define L1F_CPUMAP2_VCT12_SHIFT         16
+#define L1F_CPUMAP2_VCT11_MASK          SHIFT12(0xFUL)
+#define L1F_CPUMAP2_VCT11_SHIFT         12
+#define L1F_CPUMAP2_VCT10_MASK          SHIFT8(0xFUL)
+#define L1F_CPUMAP2_VCT10_SHIFT         8
+#define L1F_CPUMAP2_VCT9_MASK           SHIFT4(0xFUL)
+#define L1F_CPUMAP2_VCT9_SHIFT          4
+#define L1F_CPUMAP2_VCT8_MASK           SHIFT0(0xFUL)
+#define L1F_CPUMAP2_VCT8_SHIFT          0
+
+#define L1F_MISC                        0x19C0
+#define L1F_MISC_MODU                   BIT_31  /* 0:vector,1:cpu */
+#define L1F_MISC_OVERCUR                BIT_29
+#define L1F_MISC_PSWR_EN                BIT_28
+#define L1F_MISC_PSW_CTRL_MASK          SHIFT24(0xFUL)
+#define L1F_MISC_PSW_CTRL_SHIFT         24
+#define L1F_MISC_PSW_OCP_MASK           SHIFT21(7UL)
+#define L1F_MISC_PSW_OCP_SHIFT          21
+#define L1F_MISC_V18_HIGH               BIT_20
+#define L1F_MISC_LPO_CTRL_MASK          SHIFT16(0xFUL)
+#define L1F_MISC_LPO_CTRL_SHIFT         16
+#define L1F_MISC_ISO_EN                 BIT_12
+#define L1F_MISC_XSTANA_ALWAYS_ON       BIT_11
+#define L1F_MISC_SYS25M_SEL_ADAPTIVE    BIT_10
+#define L1F_MISC_SPEED_SIM              BIT_9
+#define L1F_MISC_S1_LWP_EN              BIT_8
+#define L1F_MISC_MACLPW                 BIT_7   /* pcie/mac do pwsaving
+						 * as phy in lpw state */
+#define L1F_MISC_125M_SW                BIT_6
+#define L1F_MISC_INTNLOSC_OFF_EN        BIT_5
+#define L1F_MISC_EXTN25M_SEL            BIT_4   /* 0:chipset,1:cystle */
+#define L1F_MISC_INTNLOSC_OPEN          BIT_3
+#define L1F_MISC_SMBUS_AT_LED           BIT_2
+#define L1F_MISC_PPS_AT_LED_MASK        SHIFT0(3UL)
+#define L1F_MISC_PPS_AT_LED_SHIFT       0
+#define L1F_MISC_PPS_AT_LED_ACT         1
+#define L1F_MISC_PPS_AT_LED_10_100      2
+#define L1F_MISC_PPS_AT_LED_1000        3
+
+#define L1F_MISC1                       0x19C4
+#define L1F_MSC1_BLK_CRASPM_REQ         BIT_15
+
+#define L1F_MISC3                       0x19CC
+#define L1F_MISC3_25M_BY_SW             BIT_1   /* 1:Software control 25M */
+#define L1F_MISC3_25M_NOTO_INTNL        BIT_0   /* 0:25M switch to intnl OSC */
+
+
+
+/***************************** IO mapping registers ***************************/
+#define L1F_IO_ADDR                     0x00    /* DWORD reg */
+#define L1F_IO_DATA                     0x04    /* DWORD reg */
+#define L1F_IO_MASTER                   0x08    /* DWORD same as reg0x1400 */
+#define L1F_IO_MAC_CTRL                 0x0C    /* DWORD same as reg0x1480*/
+#define L1F_IO_ISR                      0x10    /* DWORD same as reg0x1600 */
+#define L1F_IO_IMR                      0x14    /* DWORD same as reg0x1604 */
+#define L1F_IO_TPD_PRI1_PIDX            0x18    /* WORD same as reg0x15F0 */
+#define L1F_IO_TPD_PRI0_PIDX            0x1A    /* WORD same as reg0x15F2 */
+#define L1F_IO_TPD_PRI1_CIDX            0x1C    /* WORD same as reg0x15F4 */
+#define L1F_IO_TPD_PRI0_CIDX            0x1E    /* WORD same as reg0x15F6 */
+#define L1F_IO_RFD_PIDX                 0x20    /* WORD same as reg0x15E0 */
+#define L1F_IO_RFD_CIDX                 0x30    /* WORD same as reg0x15F8 */
+#define L1F_IO_MDIO                     0x38    /* WORD same as reg0x1414 */
+#define L1F_IO_PHY_CTRL                 0x3C    /* DWORD same as reg0x140C */
+
+
+/********************* PHY regs definition ***************************/
+
+/* PHY Control Register */
+#define L1F_MII_BMCR                        0x00
+#define L1F_BMCR_SPEED_SELECT_MSB           0x0040
+#define L1F_BMCR_COLL_TEST_ENABLE           0x0080
+#define L1F_BMCR_FULL_DUPLEX                0x0100
+#define L1F_BMCR_RESTART_AUTO_NEG           0x0200
+#define L1F_BMCR_ISOLATE                    0x0400
+#define L1F_BMCR_POWER_DOWN                 0x0800
+#define L1F_BMCR_AUTO_NEG_EN                0x1000
+#define L1F_BMCR_SPEED_SELECT_LSB           0x2000
+#define L1F_BMCR_LOOPBACK                   0x4000
+#define L1F_BMCR_RESET                      0x8000
+#define L1F_BMCR_SPEED_MASK                 0x2040
+#define L1F_BMCR_SPEED_1000                 0x0040
+#define L1F_BMCR_SPEED_100                  0x2000
+#define L1F_BMCR_SPEED_10                   0x0000
+
+/* PHY Status Register */
+#define L1F_MII_BMSR                        0x01
+#define L1F_BMSR_EXTENDED_CAPS              0x0001
+#define L1F_BMSR_JABBER_DETECT              0x0002
+#define L1F_BMSR_LINK_STATUS                0x0004
+#define L1F_BMSR_AUTONEG_CAPS               0x0008
+#define L1F_BMSR_REMOTE_FAULT               0x0010
+#define L1F_BMSR_AUTONEG_COMPLETE           0x0020
+#define L1F_BMSR_PREAMBLE_SUPPRESS          0x0040
+#define L1F_BMSR_EXTENDED_STATUS            0x0100
+#define L1F_BMSR_100T2_HD_CAPS              0x0200
+#define L1F_BMSR_100T2_FD_CAPS              0x0400
+#define L1F_BMSR_10T_HD_CAPS                0x0800
+#define L1F_BMSR_10T_FD_CAPS                0x1000
+#define L1F_BMSR_100X_HD_CAPS               0x2000
+#define L1F_BMMII_SR_100X_FD_CAPS           0x4000
+#define L1F_BMMII_SR_100T4_CAPS             0x8000
+
+#define L1F_MII_PHYSID1                     0x02
+#define L1F_MII_PHYSID2                     0x03
+
+
+/* Autoneg Advertisement Register */
+#define L1F_MII_ADVERTISE                   0x04
+#define L1F_ADVERTISE_SELECTOR_FIELD        0x0001
+#define L1F_ADVERTISE_10T_HD_CAPS           0x0020
+#define L1F_ADVERTISE_10T_FD_CAPS           0x0040
+#define L1F_ADVERTISE_100TX_HD_CAPS         0x0080
+#define L1F_ADVERTISE_100TX_FD_CAPS         0x0100
+#define L1F_ADVERTISE_100T4_CAPS            0x0200
+#define L1F_ADVERTISE_PAUSE                 0x0400
+#define L1F_ADVERTISE_ASM_DIR               0x0800
+#define L1F_ADVERTISE_REMOTE_FAULT          0x2000
+#define L1F_ADVERTISE_NEXT_PAGE             0x8000
+#define L1F_ADVERTISE_SPEED_MASK            0x01E0
+#define L1F_ADVERTISE_DEFAULT_CAP           0x1DE0 /* diff with L1C */
+
+/* Link partner ability register */
+#define L1F_MII_LPA                         0x05
+#define L1F_LPA_SLCT_MASK                   0x001F
+#define L1F_LPA_10HALF                      0x0020
+#define L1F_LPA_10FULL                      0x0040
+#define L1F_LPA_100HALF                     0x0080
+#define L1F_LPA_100FULL                     0x0100
+#define L1F_LPA_100BASE4                    0x0200
+#define L1F_LPA_PAUSE                       0x0400
+#define L1F_LPA_ASYPAUSE                    0x0800
+#define L1F_LPA_RFAULT                      0x2000
+#define L1F_LPA_LPACK                       0x4000
+#define L1F_LPA_NPAGE                       0x8000
+
+/* Expansion register          */
+#define L1F_MII_EXPANSION                   0x06
+#define L1F_EXPANSION_NWAY                  0x0001
+#define L1F_EXPANSION_LCWP                  0x0002
+#define L1F_EXPANSION_ENABLENPAGE           0x0004
+#define L1F_EXPANSION_NPCAPABLE             0x0008
+#define L1F_EXPANSION_MFAULTS               0x0010
+#define L1F_EXPANSION_RESV                  0xffe0
+
+/* 1000BASE-T Control Register */
+#define L1F_MII_GIGA_CR                     0x09
+#define L1F_GIGA_CR_1000T_HD_CAPS           0x0100
+#define L1F_GIGA_CR_1000T_FD_CAPS           0x0200
+#define L1F_GIGA_CR_1000T_REPEATER_DTE      0x0400
+
+#define L1F_GIGA_CR_1000T_MS_VALUE          0x0800
+
+#define L1F_GIGA_CR_1000T_MS_ENABLE         0x1000
+
+#define L1F_GIGA_CR_1000T_TEST_MODE_NORMAL  0x0000
+#define L1F_GIGA_CR_1000T_TEST_MODE_1       0x2000
+#define L1F_GIGA_CR_1000T_TEST_MODE_2       0x4000
+#define L1F_GIGA_CR_1000T_TEST_MODE_3       0x6000
+#define L1F_GIGA_CR_1000T_TEST_MODE_4       0x8000
+#define L1F_GIGA_CR_1000T_SPEED_MASK        0x0300
+#define L1F_GIGA_CR_1000T_DEFAULT_CAP       0x0300
+
+/* 1000BASE-T Status Register */
+#define L1F_MII_GIGA_SR                     0x0A
+
+/* PHY Specific Status Register */
+#define L1F_MII_GIGA_PSSR                   0x11
+#define L1F_GIGA_PSSR_FC_RXEN               0x0004
+#define L1F_GIGA_PSSR_FC_TXEN               0x0008
+#define L1F_GIGA_PSSR_SPD_DPLX_RESOLVED     0x0800
+#define L1F_GIGA_PSSR_DPLX                  0x2000
+#define L1F_GIGA_PSSR_SPEED                 0xC000
+#define L1F_GIGA_PSSR_10MBS                 0x0000
+#define L1F_GIGA_PSSR_100MBS                0x4000
+#define L1F_GIGA_PSSR_1000MBS               0x8000
+
+/* PHY Interrupt Enable Register */
+#define L1F_MII_IER                         0x12
+#define L1F_IER_LINK_UP                     0x0400
+#define L1F_IER_LINK_DOWN                   0x0800
+
+/* PHY Interrupt Status Register */
+#define L1F_MII_ISR                         0x13
+#define L1F_ISR_LINK_UP                     0x0400
+#define L1F_ISR_LINK_DOWN                   0x0800
+
+/* Cable-Detect-Test Control Register */
+#define L1F_MII_CDTC                        0x16
+#define L1F_CDTC_EN                         1       /* sc */
+#define L1F_CDTC_PAIR_MASK                  SHIFT8(3U)
+#define L1F_CDTC_PAIR_SHIFT                 8
+
+
+/* Cable-Detect-Test Status Register */
+#define L1F_MII_CDTS                        0x1C
+#define L1F_CDTS_STATUS_MASK                SHIFT8(3U)
+#define L1F_CDTS_STATUS_SHIFT               8
+#define L1F_CDTS_STATUS_NORMAL              0
+#define L1F_CDTS_STATUS_SHORT               1
+#define L1F_CDTS_STATUS_OPEN                2
+#define L1F_CDTS_STATUS_INVALID             3
+
+#define L1F_MII_DBG_ADDR                    0x1D
+#define L1F_MII_DBG_DATA                    0x1E
+
+/***************************** debug port *************************************/
+
+#define L1F_MIIDBG_ANACTRL                  0x00
+#define L1F_ANACTRL_CLK125M_DELAY_EN        BIT_15S
+#define L1F_ANACTRL_VCO_FAST                BIT_14S
+#define L1F_ANACTRL_VCO_SLOW                BIT_13S
+#define L1F_ANACTRL_AFE_MODE_EN             BIT_12S
+#define L1F_ANACTRL_LCKDET_PHY              BIT_11S
+#define L1F_ANACTRL_LCKDET_EN               BIT_10S
+#define L1F_ANACTRL_OEN_125M                BIT_9S
+#define L1F_ANACTRL_HBIAS_EN                BIT_8S
+#define L1F_ANACTRL_HB_EN                   BIT_7S
+#define L1F_ANACTRL_SEL_HSP                 BIT_6S
+#define L1F_ANACTRL_CLASSA_EN               BIT_5S
+#define L1F_ANACTRL_MANUSWON_SWR_MASK       SHIFT2(3U)
+#define L1F_ANACTRL_MANUSWON_SWR_SHIFT      2
+#define L1F_ANACTRL_MANUSWON_SWR_2V         0
+#define L1F_ANACTRL_MANUSWON_SWR_1P9V       1
+#define L1F_ANACTRL_MANUSWON_SWR_1P8V       2
+#define L1F_ANACTRL_MANUSWON_SWR_1P7V       3
+#define L1F_ANACTRL_MANUSWON_BW3_4M         BIT_1S
+#define L1F_ANACTRL_RESTART_CAL             BIT_0S
+#define L1F_ANACTRL_DEF                     0x02EF
+#if 0
+(\
+	L1F_ANACTRL_RESTART_CAL             |\
+	L1F_ANACTRL_MANUSWON_BW3_4M         |\
+	FIELDS(L1F_ANACTRL_MANUSWON_SWR, L1F_ANACTRL_MANUSWON_SWR_1P7V) |\
+	L1F_ANACTRL_CLASSA_EN               |\
+	L1F_ANACTRL_SEL_HSP                 |\
+	L1F_ANACTRL_HB_EN                   |\
+	L1F_ANACTRL_OEN_125M)
+#endif
+
+
+#define L1F_MIIDBG_SYSMODCTRL               0x04
+#define L1F_SYSMODCTRL_IECHOADJ_PFMH_PHY    BIT_15S
+#define L1F_SYSMODCTRL_IECHOADJ_BIASGEN     BIT_14S
+#define L1F_SYSMODCTRL_IECHOADJ_PFML_PHY    BIT_13S
+#define L1F_SYSMODCTRL_IECHOADJ_PS_MASK     SHIFT10(3U)
+#define L1F_SYSMODCTRL_IECHOADJ_PS_SHIFT    10
+#define L1F_SYSMODCTRL_IECHOADJ_PS_40       3
+#define L1F_SYSMODCTRL_IECHOADJ_PS_20       2
+#define L1F_SYSMODCTRL_IECHOADJ_PS_0        1
+#define L1F_SYSMODCTRL_IECHOADJ_10BT_100MV  BIT_6S /* 1:100mv, 0:200mv */
+#define L1F_SYSMODCTRL_IECHOADJ_HLFAP_MASK  SHIFT4(3U)
+#define L1F_SYSMODCTRL_IECHOADJ_HLFAP_SHIFT 4
+#define L1F_SYSMODCTRL_IECHOADJ_VDFULBW     BIT_3S
+#define L1F_SYSMODCTRL_IECHOADJ_VDBIASHLF   BIT_2S
+#define L1F_SYSMODCTRL_IECHOADJ_VDAMPHLF    BIT_1S
+#define L1F_SYSMODCTRL_IECHOADJ_VDLANSW     BIT_0S
+#define L1F_SYSMODCTRL_IECHOADJ_DEF         0xBB8B /* en half bias */
+#if 0
+(\
+	L1F_SYSMODCTRL_IECHOADJ_VDLANSW     |\
+	L1F_SYSMODCTRL_IECHOADJ_VDAMPHLF    |\
+	L1F_SYSMODCTRL_IECHOADJ_VDFULBW     |\
+	FIELDS(L1F_SYSMODCTRL_IECHOADJ_HLFAP, 3) |\
+	FIELDS(L1F_SYSMODCTRL_IECHOADJ_PS, L1F_SYSMODCTRL_IECHOADJ_PS_20) |\
+	L1F_SYSMODCTRL_IECHOADJ_PFMH_PHY)
+#endif
+
+
+#define L1F_MIIDBG_SRDSYSMOD                0x05
+#define L1F_SRDSYSMOD_LCKDET_EN             BIT_13S
+#define L1F_SRDSYSMOD_PLL_EN                BIT_11S
+#define L1F_SRDSYSMOD_SEL_HSP               BIT_10S
+#define L1F_SRDSYSMOD_HLFTXDR               BIT_9S
+#define L1F_SRDSYSMOD_TXCLK_DELAY_EN        BIT_8S
+#define L1F_SRDSYSMOD_TXELECIDLE            BIT_7S
+#define L1F_SRDSYSMOD_DEEMP_EN              BIT_6S
+#define L1F_SRDSYSMOD_MS_PAD                BIT_2S
+#define L1F_SRDSYSMOD_CDR_ADC_VLTG          BIT_1S
+#define L1F_SRDSYSMOD_CDR_DAC_1MA           BIT_0S
+#define L1F_SRDSYSMOD_DEF                   0x2C46
+
+
+#define L1F_MIIDBG_HIBNEG                   0x0B
+#define L1F_HIBNEG_PSHIB_EN                 BIT_15S
+#define L1F_HIBNEG_WAKE_BOTH                BIT_14S
+#define L1F_HIBNEG_ONOFF_ANACHG_SUDEN       BIT_13S
+#define L1F_HIBNEG_HIB_PULSE                BIT_12S
+#define L1F_HIBNEG_GATE_25M_EN              BIT_11S
+#define L1F_HIBNEG_RST_80U                  BIT_10S
+#define L1F_HIBNEG_RST_TIMER_MASK           SHIFT8(3U)
+#define L1F_HIBNEG_RST_TIMER_SHIFT          8
+#define L1F_HIBNEG_GTX_CLK_DELAY_MASK       SHIFT5(3U)
+#define L1F_HIBNEG_GTX_CLK_DELAY_SHIFT      5
+#define L1F_HIBNEG_BYPSS_BRKTIMER           BIT_4S
+#define L1F_HIBNEG_DEF                      0xBC40
+
+#define L1F_MIIDBG_TST10BTCFG               0x12
+#define L1F_TST10BTCFG_INTV_TIMER_MASK      SHIFT14(3U)
+#define L1F_TST10BTCFG_INTV_TIMER_SHIFT     SHIFT14
+#define L1F_TST10BTCFG_TRIGER_TIMER_MASK    SHIFT12(3U)
+#define L1F_TST10BTCFG_TRIGER_TIMER_SHIFT   12
+#define L1F_TST10BTCFG_DIV_MAN_MLT3_EN      BIT_11S
+#define L1F_TST10BTCFG_OFF_DAC_IDLE         BIT_10S
+#define L1F_TST10BTCFG_LPBK_DEEP            BIT_2S /* 1:deep,0:shallow */
+#define L1F_TST10BTCFG_DEF                  0x4C04
+
+#define L1F_MIIDBG_AZ_ANADECT               0x15
+#define L1F_AZ_ANADECT_10BTRX_TH            BIT_15S
+#define L1F_AZ_ANADECT_BOTH_01CHNL          BIT_14S
+#define L1F_AZ_ANADECT_INTV_MASK            SHIFT8(0x3FU)
+#define L1F_AZ_ANADECT_INTV_SHIFT           8
+#define L1F_AZ_ANADECT_THRESH_MASK          SHIFT4(0xFU)
+#define L1F_AZ_ANADECT_THRESH_SHIFT         4
+#define L1F_AZ_ANADECT_CHNL_MASK            SHIFT0(0xFU)
+#define L1F_AZ_ANADECT_CHNL_SHIFT           0
+#define L1F_AZ_ANADECT_DEF                  0x3220
+
+#define L1F_MIIDBG_LEGCYPS                  0x29
+#define L1F_LEGCYPS_EN                      BIT_15S
+#define L1F_LEGCYPS_DAC_AMP1000_MASK        SHIFT12(7U)
+#define L1F_LEGCYPS_DAC_AMP1000_SHIFT       12
+#define L1F_LEGCYPS_DAC_AMP100_MASK         SHIFT9(7U)
+#define L1F_LEGCYPS_DAC_AMP100_SHIFT        9
+#define L1F_LEGCYPS_DAC_AMP10_MASK          SHIFT6(7U)
+#define L1F_LEGCYPS_DAC_AMP10_SHIFT         6
+#define L1F_LEGCYPS_UNPLUG_TIMER_MASK       SHIFT3(7U)
+#define L1F_LEGCYPS_UNPLUG_TIMER_SHIFT      3
+#define L1F_LEGCYPS_UNPLUG_DECT_EN          BIT_2S
+#define L1F_LEGCYPS_ECNC_PS_EN              BIT_0S
+#define L1F_LEGCYPS_DEF                     0x129D
+
+#define L1F_MIIDBG_TST100BTCFG              0x36
+#define L1F_TST100BTCFG_NORMAL_BW_EN        BIT_15S
+#define L1F_TST100BTCFG_BADLNK_BYPASS       BIT_14S
+#define L1F_TST100BTCFG_SHORTCABL_TH_MASK   SHIFT8(0x3FU)
+#define L1F_TST100BTCFG_SHORTCABL_TH_SHIFT  8
+#define L1F_TST100BTCFG_LITCH_EN            BIT_7S
+#define L1F_TST100BTCFG_VLT_SW              BIT_6S
+#define L1F_TST100BTCFG_LONGCABL_TH_MASK    SHIFT0(0x3FU)
+#define L1F_TST100BTCFG_LONGCABL_TH_SHIFT   0
+#define L1F_TST100BTCFG_DEF                 0xE12C
+
+#define L1F_MIIDBG_GREENCFG                 0x3B
+#define L1F_GREENCFG_MSTPS_MSETH2_MASK      SHIFT8(0xFFU)
+#define L1F_GREENCFG_MSTPS_MSETH2_SHIFT     8
+#define L1F_GREENCFG_MSTPS_MSETH1_MASK      SHIFT0(0xFFU)
+#define L1F_GREENCFG_MSTPS_MSETH1_SHIFT     0
+#define L1F_GREENCFG_DEF                    0x7078
+
+#define L1F_MIIDBG_GREENCFG2                0x3D
+#define L1F_GREENCFG2_GATE_DFSE_EN          BIT_7S
+
+
+/***************************** extension **************************************/
+
+/******* dev 3 *********/
+#define L1F_MIIEXT_PCS                      3
+
+#define L1F_MIIEXT_CLDCTRL7                 0x8007
+#define L1F_CLDCTRL7_VDHLF_BIAS_TH_MASK     SHIFT9(0x7FU)
+#define L1F_CLDCTRL7_VDHLF_BIAS_TH_SHIFT    9
+#define L1F_CLDCTRL7_AFE_AZ_MASK            SHIFT4(0x1FU)
+#define L1F_CLDCTRL7_AFE_AZ_SHIFT           4
+#define L1F_CLDCTRL7_SIDE_PEAK_TH_MASK      SHIFT0(0xFU)
+#define L1F_CLDCTRL7_SIDE_PEAK_TH_SHIFT     0
+#define L1F_CLDCTRL7_DEF                    0x6BF6 /* ???? */
+
+#define L1F_MIIEXT_AZCTRL                   0x8008
+#define L1F_AZCTRL_SHORT_TH_MASK            SHIFT8(0xFFU)
+#define L1F_AZCTRL_SHORT_TH_SHIFT           8
+#define L1F_AZCTRL_LONG_TH_MASK             SHIFT0(0xFFU)
+#define L1F_AZCTRL_LONG_TH_SHIFT            0
+#define L1F_AZCTRL_DEF                      0x1629
+
+#define L1F_MIIEXT_AZCTRL2                  0x8009
+#define L1F_AZCTRL2_WAKETRNING_MASK         SHIFT8(0xFFU)
+#define L1F_AZCTRL2_WAKETRNING_SHIFT        8
+#define L1F_AZCTRL2_QUIET_TIMER_MASH        SHIFT6(3U)
+#define L1F_AZCTRL2_QUIET_TIMER_SHIFT       6
+#define L1F_AZCTRL2_PHAS_JMP2               BIT_4S
+#define L1F_AZCTRL2_CLKTRCV_125MD16         BIT_3S
+#define L1F_AZCTRL2_GATE1000_EN             BIT_2S
+#define L1F_AZCTRL2_AVRG_FREQ               BIT_1S
+#define L1F_AZCTRL2_PHAS_JMP4               BIT_0S
+#define L1F_AZCTRL2_DEF                     0x32C0
+
+#define L1F_MIIEXT_AZCTRL6                  0x800D
+
+#define L1F_MIIEXT_VDRVBIAS					0x8062
+#define L1F_VDRVBIAS_SEL_MASK				SHIFT0(0x3U)
+#define L1F_VDRVBIAS_SEL_SHIFT				0
+#define L1F_VDRVBIAS_DEF					0x3
+
+/********* dev 7 **********/
+#define L1F_MIIEXT_ANEG                     7
+
+#define L1F_MIIEXT_LOCAL_EEEADV             0x3C
+#define L1F_LOCAL_EEEADV_1000BT             BIT_2S
+#define L1F_LOCAL_EEEADV_100BT              BIT_1S
+
+#define L1F_MIIEXT_REMOTE_EEEADV            0x3D
+#define L1F_REMOTE_EEEADV_1000BT            BIT_2S
+#define L1F_REMOTE_EEEADV_100BT             BIT_1S
+
+#define L1F_MIIEXT_EEE_ANEG                 0x8000
+#define L1F_EEE_ANEG_1000M                  BIT_2S
+#define L1F_EEE_ANEG_100M                   BIT_1S
+
+
+
+/******************************************************************************/
+
+/* functions */
+
+#if 0
+/* check if the mac address is valid */
+bool macaddr_valid(u8 *addr);
+#endif
+
+/* get permanent mac address from
+ * return
+ *    0: success
+ *    non-0:fail
+ */
+u16 l1f_get_perm_macaddr(PETHCONTEXT ctx, u8 *addr);
+
+
+/* reset mac & dma
+ * return
+ *     0: success
+ *     non-0:fail
+ */
+u16 l1f_reset_mac(PETHCONTEXT ctx);
+
+/* reset phy
+ * return
+ *    0: success
+ *    non-0:fail
+ */
+u16 l1f_reset_phy(PETHCONTEXT ctx, bool pws_en, bool az_en, bool ptp_en);
+
+
+/* reset pcie
+ * just reset pcie relative registers (pci command, clk, aspm...)
+ * return
+ *    0:success
+ *    non-0:fail
+ */
+u16 l1f_reset_pcie(PETHCONTEXT ctx, bool l0s_en, bool l1_en);
+
+
+/* disable/enable MAC/RXQ/TXQ
+ * en
+ *    true:enable
+ *    false:disable
+ * return
+ *    0:success
+ *    non-0-fail
+ */
+u16 l1f_enable_mac(PETHCONTEXT ctx, bool en, u16 en_ctrl);
+
+
+/* enable/disable aspm support
+ * that will change settings for phy/mac/pcie
+ */
+u16 l1f_enable_aspm(PETHCONTEXT ctx, bool l0s_en, bool l1_en, u8 lnk_stat);
+
+
+/* initialize phy for speed / flow control
+ * lnk_cap
+ *    if autoNeg, is link capability to tell the peer
+ *    if force mode, is forced speed/duplex
+ */
+u16 l1f_init_phy_spdfc(PETHCONTEXT ctx, bool auto_neg,
+		       u8 lnk_cap, bool fc_en);
+
+/* do post setting on phy if link up/down event occur
+ */
+u16 l1f_post_phy_link(PETHCONTEXT ctx, bool linkon, u8 wire_spd);
+
+
+/* do power saving setting befor enter suspend mode
+ * NOTE:
+ *    1. phy link must be established before calling this function
+ *    2. wol option (pattern,magic,link,etc.) is configed before call it.
+ */
+u16 l1f_powersaving(PETHCONTEXT ctx, u8 wire_spd, bool wol_en,
+		    bool mactx_en, bool macrx_en, bool pws_en);
+
+/* read phy register */
+u16 l1f_read_phy(PETHCONTEXT ctx, bool ext, u8 dev, bool fast, u16 reg,
+		 u16 *data);
+
+/* write phy register */
+u16 l1f_write_phy(PETHCONTEXT ctx, bool ext, u8 dev,  bool fast, u16 reg,
+		  u16 data);
+
+/* phy debug port */
+u16 l1f_read_phydbg(PETHCONTEXT ctx, bool fast, u16 reg, u16 *data);
+u16 l1f_write_phydbg(PETHCONTEXT ctx, bool fast, u16 reg, u16 data);
+
+
+/* check the configuration of the PHY */
+u16 l1f_get_phy_config(PETHCONTEXT ctx);
+
+/*
+ * initialize mac basically
+ *  most of hi-feature no init
+ *      MAC/PHY should be reset before call this function
+ */
+u16 l1f_init_mac(PETHCONTEXT ctx, u8 *addr, u32 txmem_hi,
+		 u32 *tx_mem_lo, u8 tx_qnum, u16 txring_sz,
+		 u32 rxmem_hi, u32 rfdmem_lo, u32 rrdmem_lo,
+		 u16 rxring_sz, u16 rxbuf_sz, u16 smb_timer,
+		 u16 mtu, u16 int_mod, bool hash_legacy);
+
+
+
+
+#ifdef __cplusplus
+}
+#endif/*__cplusplus*/
+
+#endif/*L1F_HW_H_*/
+
diff --git a/drivers/net/ethernet/atheros/alx/alx.h b/drivers/net/ethernet/atheros/alx/alx.h
new file mode 100755
index 0000000..4568d31
--- /dev/null
+++ b/drivers/net/ethernet/atheros/alx/alx.h
@@ -0,0 +1,738 @@
+/*
+ * Copyright (c) 2010 - 2011 Atheros Communications Inc.
+ *
+ * Permission to use, copy, modify, and/or distribute this software for any
+ * purpose with or without fee is hereby granted, provided that the above
+ * copyright notice and this permission notice appear in all copies.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
+ * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
+ * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
+ * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
+ * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
+ * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ */
+
+#ifndef _ALX_H_
+#define _ALX_H_
+
+#include <linux/types.h>
+#include <linux/module.h>
+#include <linux/pci.h>
+#include <linux/netdevice.h>
+#include <linux/vmalloc.h>
+#include <linux/string.h>
+#include <linux/in.h>
+#include <linux/interrupt.h>
+#include <linux/ip.h>
+#include <linux/tcp.h>
+#include <linux/sctp.h>
+#include <linux/pkt_sched.h>
+#include <linux/ipv6.h>
+#include <linux/slab.h>
+#include <net/checksum.h>
+#include <net/ip6_checksum.h>
+#include <linux/ethtool.h>
+#include <linux/if_vlan.h>
+#include <linux/mii.h>
+
+#include <linux/bitops.h>
+#include <linux/cpumask.h>
+#include <linux/aer.h>
+
+#include "alx_sw.h"
+
+/*
+ * Definition to enable some features
+ */
+#undef CONFIG_ALX_MSIX
+#undef CONFIG_ALX_MSI
+#undef CONFIG_ALX_MTQ
+#undef CONFIG_ALX_MRQ
+#undef CONFIG_ALX_RSS
+/* #define CONFIG_ALX_MSIX */
+#define CONFIG_ALX_MSI
+#define CONFIG_ALX_MTQ
+#define CONFIG_ALX_MRQ
+#ifdef CONFIG_ALX_MRQ
+#define CONFIG_ALX_RSS
+#endif
+
+/*
+ * Definition for validate HW
+ */
+#define ALX_VALID_MTQ 1
+#define ALX_VALID_RSS 0
+#if ALX_VALID_RSS
+#define ALX_DUMP_RSS_DESC 1
+#else
+#define ALX_DUMP_RSS_DESC 0
+#endif
+
+/*
+ * Definition for Dumping msg
+ */
+/* TPD, RRD and RFD Description */
+#define ALX_DUMP_RRD_DESC   0
+#define ALX_DUMP_RFD_DESC   0
+#define ALX_DUMP_TPD_DESC   0
+
+/* Definitions for printing message */
+#define ALX_MSG_LV_ERR		1
+#define ALX_MSG_LV_EMERG	1
+#define ALX_MSG_LV_WARNING	0
+#define ALX_MSG_LV_INFO		0
+#define ALX_MSG_LV_DEBUG	0
+#define ALX_MSG_PFX_NAME	"alx: "
+
+#define ALX_MSG_INIT		BIT_1 /* PCI IF part, And always print */
+#define ALX_MSG_PCI		BIT_2 /* PCI IF part, But doesn't */
+#define ALX_MSG_IF		BIT_3
+#define ALX_MSG_RX		BIT_4
+#define ALX_MSG_TX		BIT_5
+#define ALX_MSG_INTR		BIT_6
+#define ALX_MSG_HW		BIT_7
+#define ALX_MSG_WOL		BIT_8
+#define ALX_MSG_TIMER		BIT_9
+#define ALX_MSG_ETHTOOL		BIT_10
+#define ALX_MSG_IOCTL		BIT_11
+#define ALX_MSG_PARAM		BIT_12
+#define ALX_MSG_FUNC		BIT_13
+
+#define ALX_MSG_GENERAL		(\
+		ALX_MSG_INIT)
+#define ALX_MSG_ALL		(\
+		ALX_MSG_INIT	|\
+		ALX_MSG_PCI	|\
+		ALX_MSG_IF	|\
+		ALX_MSG_RX	|\
+		ALX_MSG_TX	|\
+		ALX_MSG_INTR	|\
+		ALX_MSG_HW	|\
+		ALX_MSG_WOL	|\
+		ALX_MSG_TIMER	|\
+		ALX_MSG_ETHTOOL	|\
+		ALX_MSG_IOCTL	|\
+		ALX_MSG_FUNC    |\
+		ALX_MSG_PARAM)
+
+#define ALX_MSG_DEFAULT		ALX_MSG_GENERAL
+
+#define DRV_PRINT(_mlv, _klv, _fmt, _args...) \
+	if (ALX_MSG_LV_##_klv || (ALX_MSG_##_mlv & adpt->msg_flags)) {\
+		printk(KERN_##_klv ALX_MSG_PFX_NAME "%s: %s: " _fmt, \
+			adpt->netdev->name, __func__ , ## _args); \
+	}
+
+/*
+ * Definitions for ioctl
+ *
+ * redefine them as alx own ioctl vector
+ */
+#define SIOCDEVGMACREG	0x89F0	/* Read MAC Register */
+#define SIOCDEVSMACREG	0x89F1	/* Write MAC Register */
+/* This structure is used in all SIOCxMIIxxx ioctl calls */
+struct mac_ioctl_data {
+	__u32	reg_num;
+	__u32	reg_val;
+};
+
+#if ALX_VALID_RSS
+#define SIOCDEVVALIDRSS 0x89FA
+struct valid_rss_ioctl_data {
+	__u16	cmd_id;
+	__u16	tbl_idx;
+	__u16	tbl_val;
+}
+#endif
+
+/* TODO: refine */
+#define AT_VLAN_TO_TAG(_vlan, _tag)      \
+	_tag =  (((_vlan >> 8) & 0xFF) | \
+		 ((_vlan & 0xFF) << 8))
+
+#define AT_TAG_TO_VLAN(_tag, _vlan)       \
+	_vlan = ((((_tag) >> 8) & 0xFF) | \
+		(((_tag) & 0xFF) << 8))
+
+/* Coalescing Message Block */
+struct coals_msg_block {
+	int test;
+};
+
+
+#define BAR_0   0
+
+#define ALX_DEF_RX_BUF_SIZE	1536
+#define ALX_MAX_JUMBO_PKT_SIZE	(9*1024)
+#define ALX_MAX_TSO_PKT_SIZE	(7*1024)
+
+#define ALX_MAX_ETH_FRAME_SIZE	ALX_MAX_JUMBO_PKT_SIZE
+#define ALX_MIN_ETH_FRAME_SIZE	68
+
+
+#define ALX_MAX_RX_QUEUES	8
+#define ALX_MAX_TX_QUEUES	4
+#define ALX_MAX_HANDLED_INTRS	5
+
+#define ALX_WATCHDOG_TIME   (5 * HZ)
+
+struct alx_cmb {
+	char name[IFNAMSIZ + 9];
+	void *cmb;
+	dma_addr_t dma;
+};
+struct alx_smb {
+	char name[IFNAMSIZ + 9];
+	void *smb;
+	dma_addr_t dma;
+};
+
+
+/*
+ * RRD : definition
+ */
+struct alx_rrdes_general {
+	u32 xsum:16;
+	u32 nor:4;  /* number of RFD */
+	u32 si:12;  /* start index of rfd-ring */
+
+	u32 hash;
+
+	u32 vlan_tag:16; /* vlan-tag */
+	u32 pid:8;       /* Header Length of Header-Data Split. WORD unit */
+	u32 reserve0:1;
+	u32 rss_cpu:3;   /* CPU number used by RSS */
+#if 0
+	u32 rss_t6:1;	/* TCP(IPv6) flag for RSS hash algrithm */
+	u32 rss_i6:1;	/* IPv6 flag for RSS hash algrithm */
+	u32 rss_t4:1;	/* TCP(IPv4)  flag for RSS hash algrithm */
+	u32 rss_i4:1;	/* IPv4 flag for RSS hash algrithm */
+#endif
+	u32 rss_flag:4;
+
+	u32 pkt_len:14; /* length of the packet */
+	u32 l4f:1;      /* L4(TCP/UDP) checksum failed */
+	u32 ipf:1;      /* IP checksum failed */
+	u32 vlan_flag:1;/* vlan tag */
+	u32 reserve1:3;
+	u32 res:1;      /* received error summary */
+	u32 crc:1;      /* crc error */
+	u32 fae:1;      /* frame alignment error */
+	u32 trunc:1;    /* truncated packet, larger than MTU */
+	u32 runt:1;     /* runt packet */
+	u32 icmp:1;     /* incomplete packet,
+			 * due to insufficient rx-descriptor
+			 */
+	u32 bar:1;      /* broadcast address received */
+	u32 mar:1;      /* multicast address received */
+	u32 type:1;     /* ethernet type */
+	u32 fov:1;      /* fifo overflow*/
+	u32 lene:1;     /* length error */
+	u32 update:1;   /* update*/
+};
+
+struct alx_rrdesc {
+	union {
+		struct alx_rrdes_general gnr;
+		/* flat format */
+		union {
+			struct {
+				u32 dw0;
+				u32 dw1;
+				u32 dw2;
+				u32 dw3;
+			} d;
+			struct {
+				u64 qw0;
+				u64 qw1;
+			} q;
+		} fmt;
+	} rr_desc;
+};
+#define rr_dw0	rr_desc.fmt.d.dw0
+#define rr_dw1	rr_desc.fmt.d.dw1
+#define rr_dw2	rr_desc.fmt.d.dw2
+#define rr_dw3	rr_desc.fmt.d.dw3
+#define rr_gnr	rr_desc.gnr
+
+/*
+ * TPD : definition
+ */
+
+/* RFD desciptor */
+struct alx_rfdes_general {
+	u64   addr;
+};
+
+struct alx_rfdesc {
+	union {
+		struct alx_rfdes_general gnr;
+		/* flat format */
+		union {
+			struct {
+				u32 dw0;
+				u32 dw1;
+			} d;
+			struct {
+				u64 qw0;
+			} q;
+		} fmt;
+	} rf_desc;
+};
+#define rf_dw0	rf_desc.fmt.d.dw0
+#define rf_dw1	rf_desc.fmt.d.dw1
+#define rf_qw0	rf_desc.fmt.q.qw0
+#define rf_gnr	rf_desc.gnr
+
+/*
+ * TPD : definition
+ */
+
+/* tpd - general parameter format */
+struct alx_tpdes_general {
+	u32  buffer_len:16; /* include 4-byte CRC */
+	u32  vlan_tag:16;
+
+	u32  l4hdr_offset:8; /* tcp/udp header offset to the 1st byte of
+			      * the packet
+			      */
+	u32  c_csum:1;   /* must be 0 in this format */
+	u32  ip_csum:1;  /* do ip(v4) header checksum offload */
+	u32  tcp_csum:1; /* do tcp checksum offload, both ipv4 and ipv6 */
+	u32  udp_csum:1; /* do udp checksum offlaod, both ipv4 and ipv6 */
+	u32  lso:1;
+	u32  lso_v2:1;  /* must be 0 in this format */
+	u32  vtagged:1; /* vlan-id tagged already */
+	u32  instag:1;  /* insert vlan tag */
+
+	u32  ipv4:1;    /* ipv4 packet */
+	u32  type:1;    /* type of packet (ethernet_ii(1) or snap(0)) */
+	u32  reserve:12; /* reserved, must be 0 */
+	u32  epad:1;     /* even byte padding when this packet */
+	u32  last_frag:1; /* last fragment(buffer) of the packet */
+
+	u64 addr;
+};
+
+/* tpd - custom checksum parameter format */
+struct alx_tpdes_checksum {
+	u32 buffer_len:16; /* include 4-byte CRC */
+	u32 vlan_tag:16;
+
+	u32 payld_offset:8; /* payload offset to the 1st byte of
+			     *  the packet
+			     */
+	u32 c_sum:1;  /* do custom chekcusm offload,
+		       * must be 1 in this format
+		       */
+	u32 ip_sum:1;   /* must be 0 in thhis format */
+	u32 tcp_sum:1;  /* must be 0 in this format */
+	u32 udp_sum:1;  /* must be 0 in this format */
+	u32 lso:1;      /* must be 0 in this format */
+	u32 lso_v2:1;   /* must be 0 in this format */
+	u32 vtagged:1;  /* vlan-id tagged already */
+	u32 instag:1;   /* insert vlan tag */
+
+	u32 ipv4:1;     /* ipv4 packet */
+	u32 type:1;     /* type of packet (ethernet_ii(1) or snap(0)) */
+	u32 cxsum_offset:8;  /* checksum offset to the 1st byte of
+			      * the packet
+			      */
+	u32 reserve:4;  /* reserved, must be 0 */
+	u32 epad:1;     /* even byte padding when this packet */
+	u32 last_frag:1; /* last fragment(buffer) of the packet */
+
+	u64 addr;
+};
+
+
+/* tpd - tcp large send format (v1/v2) */
+struct alx_tpdes_tso {
+	u32 buffer_len:16; /* include 4-byte CRC */
+	u32 vlan_tag:16;
+
+	u32 tcphdr_offset:8; /* tcp hdr offset to the 1st byte of packet */
+	u32 c_sum:1;   /* must be 0 in this format */
+	u32 ip_sum:1;  /* must be 0 in thhis format */
+	u32 tcp_sum:1; /* must be 0 in this format */
+	u32 udp_sum:1; /* must be 0 in this format */
+	u32 lso:1;     /* do tcp large send (ipv4 only) */
+	u32 lso_v2:1;  /* must be 0 in this format */
+	u32 vtagged:1; /* vlan-id tagged already */
+	u32 instag:1;  /* insert vlan tag */
+
+	u32 ipv4:1;    /* ipv4 packet */
+	u32 type:1;    /* type of packet (ethernet_ii(1) or snap(0)) */
+	u32 mss:13;    /* MSS if do tcp large send */
+	u32 last_frag:1; /* last fragment(buffer) of the packet */
+
+	u32 addr_lo;
+	u32 addr_hi;
+};
+
+struct alx_tpdesc {
+	union {
+		struct alx_tpdes_general   gnr;
+		struct alx_tpdes_checksum  sum;
+		struct alx_tpdes_tso       tso;
+		/* flat format */
+		union {
+			struct {
+				u32 dw0;
+				u32 dw1;
+				u32 dw2;
+				u32 dw3;
+			} d;
+			struct {
+				u64 qw0;
+				u64 qw1;
+			} q;
+		} fmt;
+	} tp_desc;
+};
+#define tp_dw0	tp_desc.fmt.d.dw0
+#define tp_dw1	tp_desc.fmt.d.dw1
+#define tp_dw2	tp_desc.fmt.d.dw2
+#define tp_dw3	tp_desc.fmt.d.dw3
+#define tp_qw0	tp_desc.fmt.q.qw0
+#define tp_qw1	tp_desc.fmt.q.qw1
+#define tp_gnr	tp_desc.gnr
+#define tp_sum	tp_desc.sum
+#define tp_tso	tp_desc.tso
+
+
+#define ALX_RRD(_que, _i)	\
+		(&(((struct alx_rrdesc *)(_que)->rrq.rrdesc)[(_i)]))
+#define ALX_RFD(_que, _i)	\
+		(&(((struct alx_rfdesc *)(_que)->rfq.rfdesc)[(_i)]))
+#define ALX_TPD(_que, _i)	\
+		(&(((struct alx_tpdesc *)(_que)->tpq.tpdesc)[(_i)]))
+
+
+/*
+ * alx_ring_header represents a single, contiguous block of DMA space
+ * mapped for the three descriptor rings (tpd, rfd, rrd) and the two
+ * message blocks (cmb, smb) described below
+ */
+struct alx_ring_header {
+	void *desc;             /* virtual address */
+	dma_addr_t dma;         /* physical address*/
+	unsigned int size;      /* length in bytes */
+	unsigned int used;
+};
+
+
+/*
+ * alx_buffer is wrapper around a pointer to a socket buffer
+ * so a DMA handle can be stored along with the skb
+ */
+struct alx_buffer {
+	struct sk_buff *skb;    /* socket buffer */
+	u16 length;             /* rx buffer length */
+	dma_addr_t dma;
+};
+
+struct alx_sw_buffer {
+	struct sk_buff *skb;    /* socket buffer */
+
+	u32 vlan_tag:16;
+	u32 vlan_flag:1;
+	u32 reserved:15;
+};
+
+/* receive free descriptor (rfd) queue */
+struct alx_rfd_queue {
+	struct alx_buffer *rfbuff;
+	struct alx_rfdesc *rfdesc;	/* virtual address */
+	dma_addr_t rfdma;	/* physical address */
+	u16 size;	/* length in bytes */
+	u16 count;	/* number of descriptors in the ring */
+
+	u16 produce_idx; /* it's written to rxque->produce_reg */
+	u16 consume_idx; /* unused*/
+};
+
+/* receive return desciptor (rrd) queue */
+struct alx_rrd_queue {
+	struct alx_rrdesc *rrdesc;	/* virtual address */
+	dma_addr_t rrdma;	/* physical address */
+	u16 size;	/* length in bytes */
+	u16 count;	/* number of descriptors in the ring */
+
+	u16 produce_idx; /* unused */
+	u16 consume_idx; /* rxque->consume_reg */
+};
+
+/* software desciptor (swd) queue */
+struct alx_swd_queue {
+	struct alx_sw_buffer *swbuff;
+	u16 count;	/* number of descriptors in the ring */
+	u16 produce_idx;
+	u16 consume_idx;
+};
+
+/* rx queue */
+struct alx_rx_queue {
+	struct device *dev;	/* device for dma mapping */
+	struct net_device *netdev;	/* netdev ring belongs to */
+	struct alx_msix_param *msix;
+
+	struct alx_rrd_queue rrq;
+	struct alx_rfd_queue rfq;
+	struct alx_swd_queue swq;
+
+
+	u16 que_idx;		/* index in multi rx queues*/
+	u16 max_packets;		/* max work per interrupt */
+
+	u16 produce_reg;
+	u16 consume_reg;
+	u32 flags;
+};
+#define ALX_RX_FLAG_SW_QUE    BIT_0
+#define ALX_RX_FLAG_HW_QUE    BIT_1
+#define CHK_RX_FLAG(_flag)    CHK_FLAG(rxque, RX, _flag)
+#define SET_RX_FLAG(_flag)    SET_FLAG(rxque, RX, _flag)
+#define CLI_RX_FLAG(_flag)    CLI_FLAG(rxque, RX, _flag)
+
+#define GET_RF_BUFFER(_rque, _i)    (&((_rque)->rfq.rfbuff[(_i)]))
+#define GET_SW_BUFFER(_rque, _i)    (&((_rque)->swq.swbuff[(_i)]))
+
+
+/* transimit packet descriptor (tpd) ring */
+struct alx_tpd_queue {
+	struct alx_buffer *tpbuff;
+	struct alx_tpdesc *tpdesc;	/* virtual address */
+	dma_addr_t tpdma;	/* physical address */
+	u16 size;	/* length in bytes */
+	u16 count;	/* number of descriptors in the ring */
+
+	u16 produce_idx;
+	u16 consume_idx;
+	u16 last_produce_idx;
+};
+
+/* tx queue */
+struct alx_tx_queue {
+	struct device *dev;	/* device for dma mapping */
+	struct net_device *netdev;	/* netdev ring belongs to */
+
+	struct alx_tpd_queue tpq;
+	struct alx_msix_param *msix;
+
+	u16 que_idx;     /* needed for multiqueue queue management */
+	u16 max_packets; /* max packets per interrupt */
+
+	u16 produce_reg;
+	u16 consume_reg;
+};
+#define GET_TP_BUFFER(_tque, _i)    (&((_tque)->tpq.tpbuff[(_i)]))
+
+
+/*
+ * definition for array allocations.
+ */
+#define ALX_MAX_MSIX_INTRS	16
+#define ALX_MAX_RX_QUEUES	8
+#define ALX_MAX_TX_QUEUES	4
+
+enum alx_msix_type {
+	alx_msix_type_rx,
+	alx_msix_type_tx,
+	alx_msix_type_other,
+};
+#define ALX_MSIX_TYPE_OTH_TIMER		0
+#define ALX_MSIX_TYPE_OTH_ALERT		1
+#define ALX_MSIX_TYPE_OTH_SMB		2
+#define ALX_MSIX_TYPE_OTH_PHY		3
+
+/* ALX_MAX_MSIX_INTRS of these are allocated,
+ * but we only use one per queue-specific vector.
+ */
+struct alx_msix_param {
+	struct alx_adapter *adpt;
+	unsigned int vec_idx; /* index in HW interrupt vector */
+	char name[IFNAMSIZ + 9];
+
+	/* msix interrupts for queue */
+	u8 rx_map[ALX_MAX_RX_QUEUES];
+	u8 tx_map[ALX_MAX_TX_QUEUES];
+	u8 rx_count;     /* Rx ring count assigned to this vector */
+	u8 tx_count;     /* Tx ring count assigned to this vector */
+
+	struct napi_struct napi;
+	cpumask_var_t affinity_mask;
+	u32 flags;
+};
+
+#define ALX_MSIX_FLAG_RX0	BIT_0
+#define ALX_MSIX_FLAG_RX1	BIT_1
+#define ALX_MSIX_FLAG_RX2	BIT_2
+#define ALX_MSIX_FLAG_RX3	BIT_3
+#define ALX_MSIX_FLAG_RX4	BIT_4
+#define ALX_MSIX_FLAG_RX5	BIT_5
+#define ALX_MSIX_FLAG_RX6	BIT_6
+#define ALX_MSIX_FLAG_RX7	BIT_7
+#define ALX_MSIX_FLAG_TX0	BIT_8
+#define ALX_MSIX_FLAG_TX1	BIT_9
+#define ALX_MSIX_FLAG_TX2	BIT_10
+#define ALX_MSIX_FLAG_TX3	BIT_11
+#define ALX_MSIX_FLAG_TIMER	BIT_12
+#define ALX_MSIX_FLAG_ALERT	BIT_13
+#define ALX_MSIX_FLAG_SMB	BIT_14
+#define ALX_MSIX_FLAG_PHY	BIT_15
+
+#define ALX_MSIX_FLAG_RXS		(\
+		ALX_MSIX_FLAG_RX0	|\
+		ALX_MSIX_FLAG_RX1	|\
+		ALX_MSIX_FLAG_RX2	|\
+		ALX_MSIX_FLAG_RX3	|\
+		ALX_MSIX_FLAG_RX4	|\
+		ALX_MSIX_FLAG_RX5	|\
+		ALX_MSIX_FLAG_RX6	|\
+		ALX_MSIX_FLAG_RX7)
+#define ALX_MSIX_FLAG_TXS		(\
+		ALX_MSIX_FLAG_TX0	|\
+		ALX_MSIX_FLAG_TX1	|\
+		ALX_MSIX_FLAG_TX2	|\
+		ALX_MSIX_FLAG_TX3)
+#define ALX_MSIX_FLAG_ALL		(\
+		ALX_MSIX_FLAG_RXS	|\
+		ALX_MSIX_FLAG_TXS	|\
+		ALX_MSIX_FLAG_TIMER	|\
+		ALX_MSIX_FLAG_ALERT	|\
+		ALX_MSIX_FLAG_SMB	|\
+		ALX_MSIX_FLAG_PHY)
+
+#define CHK_MSIX_FLAG(_flag)	CHK_FLAG(msix, MSIX, _flag)
+#define SET_MSIX_FLAG(_flag)	SET_FLAG(msix, MSIX, _flag)
+#define CLI_MSIX_FLAG(_flag)	CLI_FLAG(msix, MSIX, _flag)
+
+/*
+ *board specific private data structure
+ */
+struct alx_adapter {
+	struct net_device *netdev;
+	struct pci_dev *pdev;
+	struct net_device_stats net_stats;
+	bool netdev_registered;
+
+	struct vlan_group   *vlgrp;
+	u16 bd_number;    /* board number;*/
+
+	struct alx_msix_param *msix[ALX_MAX_MSIX_INTRS];
+	struct msix_entry *msix_entries;
+	int num_msix_rxques;
+	int num_msix_txques;
+	int num_msix_noques;    /* true count of msix_noques for device */
+	int num_msix_intrs;
+
+	int min_msix_intrs;
+	int max_msix_intrs;
+
+	/* All Descriptor memory */
+	struct alx_ring_header ring_header;
+
+	/* TX */
+	struct alx_tx_queue *tx_queue[ALX_MAX_TX_QUEUES];
+	/* RX */
+	struct alx_rx_queue *rx_queue[ALX_MAX_RX_QUEUES];
+
+	u16  num_txques;
+	u16  num_rxques; /* equal max(num_hw_rxques, num_sw_rxques) */
+	u16  num_hw_rxques;
+	u16  num_sw_rxques;
+
+	u16  max_rxques;
+	u16  max_txques;
+
+	u16  num_txdescs;
+	u16  num_rxdescs;
+
+	u32  rxbuf_size;
+
+	struct alx_cmb cmb;
+	struct alx_smb smb;
+
+	/* structs defined in alx_hw.h */
+	struct alx_hw       hw;
+	struct alx_hw_stats hw_stats;
+
+	u32 *config_space;
+
+	struct work_struct alx_task;
+	struct timer_list  alx_timer;
+	unsigned long      alx_state;
+
+	unsigned long link_jiffies;
+
+	u32 wol;
+	spinlock_t tx_lock;
+	spinlock_t rx_lock;
+	atomic_t irq_sem;
+
+	u16 msg_flags;
+	u32 flags[2];
+};
+
+#define ALX_ADPT_FLAG_0_MSI_CAP		BIT_0
+#define ALX_ADPT_FLAG_0_MSI_EN		BIT_1
+#define ALX_ADPT_FLAG_0_MSIX_CAP	BIT_2
+#define ALX_ADPT_FLAG_0_MSIX_EN		BIT_3
+#define ALX_ADPT_FLAG_0_MRQ_CAP		BIT_4
+#define ALX_ADPT_FLAG_0_MRQ_EN		BIT_5
+#define ALX_ADPT_FLAG_0_MTQ_CAP		BIT_6
+#define ALX_ADPT_FLAG_0_MTQ_EN		BIT_7
+#define ALX_ADPT_FLAG_0_SRSS_CAP	BIT_8
+#define ALX_ADPT_FLAG_0_SRSS_EN		BIT_9
+#define ALX_ADPT_FLAG_0_FIXED_MSIX	BIT_28
+
+#define ALX_ADPT_FLAG_1_RESET_REQUESTED		BIT_0
+#define ALX_ADPT_FLAG_1_LSC_REQUESTED		BIT_1
+#define ALX_ADPT_FLAG_1_DBG_REQUESTED		BIT_2
+
+#define CHK_ADPT_FLAG(_idx, _flag)	\
+		CHK_FLAG_ARRAY(adpt, _idx, ADPT, _flag)
+#define SET_ADPT_FLAG(_idx, _flag)	\
+		SET_FLAG_ARRAY(adpt, _idx, ADPT, _flag)
+#define CLI_ADPT_FLAG(_idx, _flag)	\
+		CLI_FLAG_ARRAY(adpt, _idx, ADPT, _flag)
+
+#ifdef HAVE_NETDEV_STATS_IN_NETDEV
+#define GET_NETDEV_STATS(_adpt)		&((_adpt)->netdev->stats);
+#else
+#define GET_NETDEV_STATS(_adpt)		&((_adpt)->net_stats);
+#endif /* HAVE_NETDEV_STATS_IN_NETDEV */
+
+
+/* default to trying for four seconds */
+#define ALX_TRY_LINK_TIMEOUT (4 * HZ)
+
+enum alx_state_t {
+	__ALX_TESTING,
+	__ALX_RESETTING,
+	__ALX_DOWN,
+	__ALX_SERVICE_SCHED,
+	__ALX_IN_SFP_INIT,
+};
+
+
+#define ALX_OPEN_CTRL_IRQ_EN	BIT_0
+#define ALX_OPEN_CTRL_MAC_EN	BIT_1
+
+/* needed by alx_ethtool.c */
+extern char alx_drv_name[];
+extern const char alx_drv_version[];
+extern int alx_open_internal(struct alx_adapter *adpt, u32 ctrl);
+extern void alx_stop_internal(struct alx_adapter *adpt, u32 ctrl);
+extern void alx_reinit_locked(struct alx_adapter *adpt);
+extern void alx_set_ethtool_ops(struct net_device *netdev);
+#ifdef ETHTOOL_OPS_COMPAT
+extern int ethtool_ioctl(struct ifreq *ifr);
+#endif
+
+
+
+#endif /* _ALX_H_ */
diff --git a/drivers/net/ethernet/atheros/alx/alx_ethtool.c b/drivers/net/ethernet/atheros/alx/alx_ethtool.c
new file mode 100755
index 0000000..01388c7
--- /dev/null
+++ b/drivers/net/ethernet/atheros/alx/alx_ethtool.c
@@ -0,0 +1,513 @@
+/*
+ * Copyright (c) 2010 - 2011 Atheros Communications Inc.
+ *
+ * Permission to use, copy, modify, and/or distribute this software for any
+ * purpose with or without fee is hereby granted, provided that the above
+ * copyright notice and this permission notice appear in all copies.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
+ * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
+ * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
+ * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
+ * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
+ * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ */
+
+#include <linux/netdevice.h>
+#include <linux/ethtool.h>
+
+#include "alx.h"
+#include "alx_hwcom.h"
+
+#ifdef ETHTOOL_OPS_COMPAT
+#include "alx_compat_ethtool.c"
+#endif
+
+static int alx_get_settings(struct net_device *netdev,
+			      struct ethtool_cmd *ecmd)
+{
+	struct alx_adapter *adpt = netdev_priv(netdev);
+	struct alx_hw *hw = &adpt->hw;
+	u32 link_speed = hw->link_speed;
+	bool link_up = hw->link_up;
+
+	ecmd->supported = (SUPPORTED_10baseT_Half  |
+			   SUPPORTED_10baseT_Full  |
+			   SUPPORTED_100baseT_Half |
+			   SUPPORTED_100baseT_Full |
+			   SUPPORTED_Autoneg       |
+			   SUPPORTED_TP);
+	if (CHK_HW_FLAG(GIGA_CAP))
+		ecmd->supported |= SUPPORTED_1000baseT_Full;
+
+	ecmd->advertising = ADVERTISED_TP;
+
+	ecmd->advertising |= ADVERTISED_Autoneg;
+	ecmd->advertising |= hw->autoneg_advertised;
+
+	ecmd->port = PORT_TP;
+	ecmd->phy_address = 0;
+	ecmd->autoneg = AUTONEG_ENABLE;
+	ecmd->transceiver = XCVR_INTERNAL;
+
+	if (!in_interrupt()) {
+		hw->cbs.check_phy_link(hw, &link_speed, &link_up);
+		hw->link_speed = link_speed;
+		hw->link_up = link_up;
+	}
+
+	if (link_up) {
+		switch (link_speed) {
+		case ALX_LINK_SPEED_10_HALF:
+			ecmd->speed = SPEED_10;
+			ecmd->duplex = DUPLEX_HALF;
+			break;
+		case ALX_LINK_SPEED_10_FULL:
+			ecmd->speed = SPEED_10;
+			ecmd->duplex = DUPLEX_FULL;
+			break;
+		case ALX_LINK_SPEED_100_HALF:
+			ecmd->speed = SPEED_100;
+			ecmd->duplex = DUPLEX_HALF;
+			break;
+		case ALX_LINK_SPEED_100_FULL:
+			ecmd->speed = SPEED_100;
+			ecmd->duplex = DUPLEX_FULL;
+			break;
+		case ALX_LINK_SPEED_1GB_FULL:
+			ecmd->speed = SPEED_1000;
+			ecmd->duplex = DUPLEX_FULL;
+			break;
+		default:
+			ecmd->speed = -1;
+			ecmd->duplex = -1;
+			break;
+		}
+	} else {
+		ecmd->speed = -1;
+		ecmd->duplex = -1;
+	}
+
+	return 0;
+}
+
+static int alx_set_settings(struct net_device *netdev,
+			      struct ethtool_cmd *ecmd)
+{
+	struct alx_adapter *adpt = netdev_priv(netdev);
+	struct alx_hw *hw = &adpt->hw;
+	u32 advertised, old;
+	int error = 0;
+
+	while (test_and_set_bit(__ALX_RESETTING, &adpt->alx_state))
+		msleep(20);
+
+	old = hw->autoneg_advertised;
+	advertised = 0;
+	if (ecmd->autoneg == AUTONEG_ENABLE) {
+		advertised = ALX_LINK_SPEED_DEFAULT;
+	} else {
+		if (ecmd->speed == SPEED_1000) {
+			if (ecmd->duplex != DUPLEX_FULL) {
+				DRV_PRINT(ETHTOOL, WARNING,
+					"1000M half is invalid\n");
+				clear_bit(__ALX_RESETTING, &adpt->alx_state);
+				return -EINVAL;
+			}
+			advertised = ALX_LINK_SPEED_1GB_FULL;
+		} else if (ecmd->speed == SPEED_100) {
+			if (ecmd->duplex == DUPLEX_FULL)
+				advertised = ALX_LINK_SPEED_100_FULL;
+			else
+				advertised = ALX_LINK_SPEED_100_HALF;
+		} else {
+			if (ecmd->duplex == DUPLEX_FULL)
+				advertised = ALX_LINK_SPEED_10_FULL;
+			else
+				advertised = ALX_LINK_SPEED_10_HALF;
+		}
+	}
+
+	if (hw->autoneg_advertised == advertised) {
+		clear_bit(__ALX_RESETTING, &adpt->alx_state);
+		return error;
+	}
+
+	error = hw->cbs.setup_phy_link_speed(hw, advertised, true,
+			!hw->disable_fc_autoneg);
+	if (error) {
+		DRV_PRINT(ETHTOOL, INFO,
+				"setup link failed with code %d\n", error);
+		hw->cbs.setup_phy_link_speed(hw, old, true,
+				!hw->disable_fc_autoneg);
+	}
+	clear_bit(__ALX_RESETTING, &adpt->alx_state);
+	return error;
+}
+
+
+static void alx_get_pauseparam(struct net_device *netdev,
+			       struct ethtool_pauseparam *pause)
+{
+	struct alx_adapter *adpt = netdev_priv(netdev);
+	struct alx_hw *hw = &adpt->hw;
+
+
+	if (hw->disable_fc_autoneg ||
+	    hw->cur_fc_mode == alx_fc_none)
+		pause->autoneg = 0;
+	else
+		pause->autoneg = 1;
+
+	if (hw->cur_fc_mode == alx_fc_rx_pause) {
+		pause->rx_pause = 1;
+	} else if (hw->cur_fc_mode == alx_fc_tx_pause) {
+		pause->tx_pause = 1;
+	} else if (hw->cur_fc_mode == alx_fc_full) {
+		pause->rx_pause = 1;
+		pause->tx_pause = 1;
+	}
+}
+
+static int alx_set_pauseparam(struct net_device *netdev,
+			      struct ethtool_pauseparam *pause)
+{
+	struct alx_adapter *adpt = netdev_priv(netdev);
+	struct alx_hw *hw = &adpt->hw;
+	enum alx_fc_mode req_fc_mode;
+	bool disable_fc_autoneg;
+	int retval;
+
+	while (test_and_set_bit(__ALX_RESETTING, &adpt->alx_state))
+		msleep(20);
+
+	req_fc_mode        = hw->req_fc_mode;
+	disable_fc_autoneg = hw->disable_fc_autoneg;
+
+
+	if (pause->autoneg != AUTONEG_ENABLE)
+		disable_fc_autoneg = true;
+	else
+		disable_fc_autoneg = false;
+
+	if ((pause->rx_pause && pause->tx_pause) || pause->autoneg)
+		req_fc_mode = alx_fc_full;
+	else if (pause->rx_pause && !pause->tx_pause)
+		req_fc_mode = alx_fc_rx_pause;
+	else if (!pause->rx_pause && pause->tx_pause)
+		req_fc_mode = alx_fc_tx_pause;
+	else if (!pause->rx_pause && !pause->tx_pause)
+		req_fc_mode = alx_fc_none;
+	else
+		return -EINVAL;
+
+	if ((hw->req_fc_mode != req_fc_mode) ||
+	    (hw->disable_fc_autoneg != disable_fc_autoneg)) {
+		hw->req_fc_mode = req_fc_mode;
+		hw->disable_fc_autoneg = disable_fc_autoneg;
+		if (!hw->disable_fc_autoneg)
+			retval = hw->cbs.setup_phy_link(hw,
+				hw->autoneg_advertised, true, true);
+
+		if (hw->cbs.config_fc)
+			hw->cbs.config_fc(hw);
+	}
+
+	clear_bit(__ALX_RESETTING, &adpt->alx_state);
+	return 0;
+}
+
+static u32 alx_get_tx_csum(struct net_device *netdev)
+{
+	return (netdev->features & NETIF_F_HW_CSUM) != 0;
+}
+
+static u32 alx_get_msglevel(struct net_device *netdev)
+{
+#ifdef DBG
+	return 1;
+#else
+	return 0;
+#endif
+}
+
+static void alx_set_msglevel(struct net_device *netdev, u32 data)
+{
+}
+
+
+static int alx_get_regs_len(struct net_device *netdev)
+{
+	struct alx_adapter *adpt = netdev_priv(netdev);
+	struct alx_hw *hw = &adpt->hw;
+	return hw->hwreg_sz * sizeof(32);
+}
+
+static void alx_get_regs(struct net_device *netdev,
+			 struct ethtool_regs *regs, void *buff)
+{
+	struct alx_adapter *adpt = netdev_priv(netdev);
+	struct alx_hw *hw = &adpt->hw;
+
+	regs->version = 0;
+
+	memset(buff, 0, hw->hwreg_sz * sizeof(u32));
+	if (hw->cbs.get_ethtool_regs)
+		hw->cbs.get_ethtool_regs(hw, buff);
+}
+
+static int alx_get_eeprom_len(struct net_device *netdev)
+{
+	struct alx_adapter *adpt = netdev_priv(netdev);
+	struct alx_hw *hw = &adpt->hw;
+	return hw->eeprom_sz;
+}
+
+static int alx_get_eeprom(struct net_device *netdev,
+		struct ethtool_eeprom *eeprom, u8 *bytes)
+{
+	struct alx_adapter *adpt = netdev_priv(netdev);
+	struct alx_hw *hw = &adpt->hw;
+	bool eeprom_exist = false;
+	u32 *eeprom_buff;
+	int first_dword, last_dword;
+	int retval = 0;
+	int i;
+
+	if (eeprom->len == 0)
+		return -EINVAL;
+
+	if (hw->cbs.check_nvram)
+		hw->cbs.check_nvram(hw, &eeprom_exist);
+	if (!eeprom_exist)
+		return -EOPNOTSUPP;
+
+	eeprom->magic = adpt->pdev->vendor |
+			(adpt->pdev->device << 16);
+
+	first_dword = eeprom->offset >> 2;
+	last_dword = (eeprom->offset + eeprom->len - 1) >> 2;
+
+	eeprom_buff = kmalloc(sizeof(u32) *
+			(last_dword - first_dword + 1), GFP_KERNEL);
+	if (eeprom_buff == NULL)
+		return -ENOMEM;
+
+	for (i = first_dword; i < last_dword; i++) {
+		if (hw->cbs.read_nvram) {
+			retval = hw->cbs.read_nvram(hw, i*4,
+					&(eeprom_buff[i-first_dword]));
+			if (retval) {
+				retval =  -EIO;
+				goto out;
+			}
+		}
+	}
+
+	/* Device's eeprom is always little-endian, word addressable */
+	for (i = 0; i < last_dword - first_dword; i++)
+		le32_to_cpus(&eeprom_buff[i]);
+
+	memcpy(bytes, (u8 *)eeprom_buff + (eeprom->offset & 3), eeprom->len);
+out:
+	kfree(eeprom_buff);
+	return retval;
+}
+
+static int alx_set_eeprom(struct net_device *netdev,
+			    struct ethtool_eeprom *eeprom, u8 *bytes)
+{
+	struct alx_adapter *adpt = netdev_priv(netdev);
+	struct alx_hw *hw = &adpt->hw;
+	bool eeprom_exist = false;
+	u32 *eeprom_buff;
+	u32 *ptr;
+	int first_dword, last_dword;
+	int retval = 0;
+	int i;
+
+	if (eeprom->len == 0)
+		return -EINVAL;
+
+	if (hw->cbs.check_nvram)
+		hw->cbs.check_nvram(hw, &eeprom_exist);
+	if (!eeprom_exist)
+		return -EOPNOTSUPP;
+
+
+	if (eeprom->magic != (adpt->pdev->vendor |
+				(adpt->pdev->device << 16)))
+		return -EINVAL;
+
+	first_dword = eeprom->offset >> 2;
+	last_dword = (eeprom->offset + eeprom->len - 1) >> 2;
+	eeprom_buff = kmalloc(ALX_MAX_EEPROM_LEN, GFP_KERNEL);
+	if (eeprom_buff == NULL)
+		return -ENOMEM;
+
+	ptr = (u32 *)eeprom_buff;
+
+	if (eeprom->offset & 3) {
+		/* need read/modify/write of first changed EEPROM word */
+		/* only the second byte of the word is being modified */
+		if (hw->cbs.read_nvram) {
+			retval = hw->cbs.read_nvram(hw, first_dword * 4,
+						&(eeprom_buff[0]));
+			if (retval) {
+				retval = -EIO;
+				goto out;
+			}
+		}
+		ptr++;
+	}
+
+	if (((eeprom->offset + eeprom->len) & 3)) {
+		/* need read/modify/write of last changed EEPROM word */
+		/* only the first byte of the word is being modified */
+		if (hw->cbs.read_nvram) {
+			retval = hw->cbs.read_nvram(hw, last_dword * 4,
+				&(eeprom_buff[last_dword - first_dword]));
+			if (retval) {
+				retval = -EIO;
+				goto out;
+			}
+		}
+	}
+
+	/* Device's eeprom is always little-endian, word addressable */
+	memcpy(ptr, bytes, eeprom->len);
+	for (i = 0; i < last_dword - first_dword + 1; i++) {
+		if (hw->cbs.write_nvram) {
+			retval = hw->cbs.write_nvram(hw, (first_dword + i) * 4,
+						eeprom_buff[i]);
+			if (retval) {
+				retval = -EIO;
+				goto out;
+			}
+		}
+	}
+out:
+	kfree(eeprom_buff);
+	return retval;
+}
+
+static void alx_get_drvinfo(struct net_device *netdev,
+		struct ethtool_drvinfo *drvinfo)
+{
+	struct alx_adapter *adpt = netdev_priv(netdev);
+
+	strncpy(drvinfo->driver,  alx_drv_name, 32);
+	strncpy(drvinfo->version, alx_drv_version, 32);
+	strncpy(drvinfo->fw_version, "alx", 32);
+	strncpy(drvinfo->bus_info, pci_name(adpt->pdev), 32);
+	drvinfo->n_stats = 0;
+	drvinfo->testinfo_len = 0;
+	drvinfo->regdump_len = adpt->hw.hwreg_sz;
+	drvinfo->eedump_len = adpt->hw.eeprom_sz;
+}
+
+
+static int alx_wol_exclusion(struct alx_adapter *adpt,
+			     struct ethtool_wolinfo *wol)
+{
+	struct alx_hw *hw = &adpt->hw;
+	int retval = 1;
+
+	/* WOL not supported except for the following */
+	switch (hw->pci_devid) {
+	case ALX_DEV_ID_AR8131:
+	case ALX_DEV_ID_AR8132:
+	case ALX_DEV_ID_AR8151_V1:
+	case ALX_DEV_ID_AR8151_V2:
+	case ALX_DEV_ID_AR8152_V1:
+	case ALX_DEV_ID_AR8152_V2:
+	case ALX_DEV_ID_AR8161:
+	case ALX_DEV_ID_AR8162:
+		retval = 0;
+		break;
+	default:
+		wol->supported = 0;
+	}
+
+	return retval;
+}
+
+static void alx_get_wol(struct net_device *netdev,
+			  struct ethtool_wolinfo *wol)
+{
+	struct alx_adapter *adpt = netdev_priv(netdev);
+
+	wol->supported = WAKE_MAGIC | WAKE_PHY;
+	wol->wolopts = 0;
+
+	if (adpt->wol & ALX_WOL_MAGIC)
+		wol->wolopts |= WAKE_MAGIC;
+	if (adpt->wol & ALX_WOL_PHY)
+		wol->wolopts |= WAKE_PHY;
+
+	DRV_PRINT(ETHTOOL, INFO, "wol->wolopts = %x.\n", wol->wolopts);
+
+	return;
+}
+
+static int alx_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
+{
+	struct alx_adapter *adpt = netdev_priv(netdev);
+
+	if (wol->wolopts & (WAKE_ARP | WAKE_MAGICSECURE |
+			    WAKE_MCAST | WAKE_BCAST | WAKE_MCAST))
+		return -EOPNOTSUPP;
+
+	if (alx_wol_exclusion(adpt, wol))
+		return wol->wolopts ? -EOPNOTSUPP : 0;
+
+	adpt->wol = 0;
+
+	if (wol->wolopts & WAKE_MAGIC)
+		adpt->wol |= ALX_WOL_MAGIC;
+	if (wol->wolopts & WAKE_PHY)
+		adpt->wol |= ALX_WOL_PHY;
+
+	device_set_wakeup_enable(&adpt->pdev->dev, adpt->wol);
+
+	return 0;
+}
+
+static int alx_nway_reset(struct net_device *netdev)
+{
+	struct alx_adapter *adpt = netdev_priv(netdev);
+	if (netif_running(netdev))
+		alx_reinit_locked(adpt);
+	return 0;
+}
+
+static struct ethtool_ops alx_ethtool_ops = {
+	.get_settings    = alx_get_settings,
+	.set_settings    = alx_set_settings,
+	.get_pauseparam  = alx_get_pauseparam,
+	.set_pauseparam  = alx_set_pauseparam,
+	.get_drvinfo     = alx_get_drvinfo,
+	.get_regs_len    = alx_get_regs_len,
+	.get_regs        = alx_get_regs,
+	.get_wol         = alx_get_wol,
+	.set_wol         = alx_set_wol,
+	.get_msglevel    = alx_get_msglevel,
+	.set_msglevel    = alx_set_msglevel,
+	.nway_reset      = alx_nway_reset,
+	.get_link        = ethtool_op_get_link,
+	.get_eeprom_len  = alx_get_eeprom_len,
+	.get_eeprom      = alx_get_eeprom,
+	.set_eeprom      = alx_set_eeprom,
+	.get_tx_csum     = alx_get_tx_csum,
+	.get_sg          = ethtool_op_get_sg,
+	.set_sg          = ethtool_op_set_sg,
+#ifdef NETIF_F_TSO
+	.get_tso         = ethtool_op_get_tso,
+#endif
+};
+
+void alx_set_ethtool_ops(struct net_device *netdev)
+{
+	SET_ETHTOOL_OPS(netdev, &alx_ethtool_ops);
+}
diff --git a/drivers/net/ethernet/atheros/alx/alx_hwcom.h b/drivers/net/ethernet/atheros/alx/alx_hwcom.h
new file mode 100755
index 0000000..af9dc32
--- /dev/null
+++ b/drivers/net/ethernet/atheros/alx/alx_hwcom.h
@@ -0,0 +1,234 @@
+/*
+ * Copyright (c) 2010 - 2011 Atheros Communications Inc.
+ *
+ * Permission to use, copy, modify, and/or distribute this software for any
+ * purpose with or without fee is hereby granted, provided that the above
+ * copyright notice and this permission notice appear in all copies.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
+ * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
+ * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
+ * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
+ * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
+ * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ */
+
+#ifndef _LX_HWCOMMON_H_
+#define _LX_HWCOMMON_H_
+
+#define PHY_TYPE_ASIC   0
+#define PHY_TYPE_FPGA   1
+#define PHY_TYPE_F1 2
+
+#define MAC_TYPE_ASIC   0
+#define MAC_TYPE_FPGA   1
+
+
+#include "alx_sw.h"
+
+
+#define BIT_31      (1UL << 31)
+#define BIT_30      (1L << 30)
+#define BIT_29      (1L << 29)
+#define BIT_28      (1L << 28)
+#define BIT_27      (1L << 27)
+#define BIT_26      (1L << 26)
+#define BIT_25      (1L << 25)
+#define BIT_24      (1L << 24)
+#define BIT_23      (1L << 23)
+#define BIT_22      (1L << 22)
+#define BIT_21      (1L << 21)
+#define BIT_20      (1L << 20)
+#define BIT_19      (1L << 19)
+#define BIT_18      (1L << 18)
+#define BIT_17      (1L << 17)
+#define BIT_16      (1L << 16)
+#define BIT_15      (1L << 15)
+#define BIT_14      (1L << 14)
+#define BIT_13      (1L << 13)
+#define BIT_12      (1L << 12)
+#define BIT_11      (1L << 11)
+#define BIT_10      (1L << 10)
+#define BIT_9       (1L << 9)
+#define BIT_8       (1L << 8)
+#define BIT_7       (1L << 7)
+#define BIT_6       (1L << 6)
+#define BIT_5       (1L << 5)
+#define BIT_4       (1L << 4)
+#define BIT_3       (1L << 3)
+#define BIT_2       (1L << 2)
+#define BIT_1       (1L << 1)
+#define BIT_0       1L
+
+#define BIT_15S     (1U << 15)
+#define BIT_14S     (1 << 14)
+#define BIT_13S     (1 << 13)
+#define BIT_12S     (1 << 12)
+#define BIT_11S     (1 << 11)
+#define BIT_10S     (1 << 10)
+#define BIT_9S      (1 << 9)
+#define BIT_8S      (1 << 8)
+#define BIT_7S      (1 << 7)
+#define BIT_6S      (1 << 6)
+#define BIT_5S      (1 << 5)
+#define BIT_4S      (1 << 4)
+#define BIT_3S      (1 << 3)
+#define BIT_2S      (1 << 2)
+#define BIT_1S      (1 << 1)
+#define BIT_0S      1
+
+#define SHIFT31(x)  ((x) << 31)
+#define SHIFT30(x)  ((x) << 30)
+#define SHIFT29(x)  ((x) << 29)
+#define SHIFT28(x)  ((x) << 28)
+#define SHIFT27(x)  ((x) << 27)
+#define SHIFT26(x)  ((x) << 26)
+#define SHIFT25(x)  ((x) << 25)
+#define SHIFT24(x)  ((x) << 24)
+#define SHIFT23(x)  ((x) << 23)
+#define SHIFT22(x)  ((x) << 22)
+#define SHIFT21(x)  ((x) << 21)
+#define SHIFT20(x)  ((x) << 20)
+#define SHIFT19(x)  ((x) << 19)
+#define SHIFT18(x)  ((x) << 18)
+#define SHIFT17(x)  ((x) << 17)
+#define SHIFT16(x)  ((x) << 16)
+#define SHIFT15(x)  ((x) << 15)
+#define SHIFT14(x)  ((x) << 14)
+#define SHIFT13(x)  ((x) << 13)
+#define SHIFT12(x)  ((x) << 12)
+#define SHIFT11(x)  ((x) << 11)
+#define SHIFT10(x)  ((x) << 10)
+#define SHIFT9(x)   ((x) << 9)
+#define SHIFT8(x)   ((x) << 8)
+#define SHIFT7(x)   ((x) << 7)
+#define SHIFT6(x)   ((x) << 6)
+#define SHIFT5(x)   ((x) << 5)
+#define SHIFT4(x)   ((x) << 4)
+#define SHIFT3(x)   ((x) << 3)
+#define SHIFT2(x)   ((x) << 2)
+#define SHIFT1(x)   ((x) << 1)
+#define SHIFT0(x)   ((x) << 0)
+
+#define ALL_32_BITS 0xffffffffUL
+
+#define FIELD_GETX(_x, _name)   (((_x) & (_name##_MASK)) >> (_name##_SHIFT))
+#define FIELD_SETS(_x, _name, _v)   (\
+(_x) =                               \
+((_x) & ~(_name##_MASK))            |\
+(((u16)(_v) << (_name##_SHIFT)) & (_name##_MASK)))
+#define FIELD_SETL(_x, _name, _v)   (\
+(_x) =                               \
+((_x) & ~(_name##_MASK))            |\
+(((u32)(_v) << (_name##_SHIFT)) & (_name##_MASK)))
+#define FIELDL(_name, _v) (((u32)(_v) << (_name##_SHIFT)) & (_name##_MASK))
+#define FIELDS(_name, _v) (((u16)(_v) << (_name##_SHIFT)) & (_name##_MASK))
+
+
+
+#define LX_SWAP_DW(_x) (\
+	(((_x) << 24) & 0xFF000000UL) |\
+	(((_x) <<  8) & 0x00FF0000UL) |\
+	(((_x) >>  8) & 0x0000FF00UL) |\
+	(((_x) >> 24) & 0x000000FFUL))
+
+#define LX_SWAP_W(_x) (\
+	(((_x) >> 8) & 0x00FFU) |\
+	(((_x) << 8) & 0xFF00U))
+
+
+#define LX_ERR_SUCCESS          0x0000
+#define LX_ERR_ALOAD            0x0001
+#define LX_ERR_RSTMAC           0x0002
+#define LX_ERR_PARM             0x0003
+#define LX_ERR_MIIBUSY          0x0004
+
+/* link capability */
+#define LX_LC_10H               0x01
+#define LX_LC_10F               0x02
+#define LX_LC_100H              0x04
+#define LX_LC_100F              0x08
+#define LX_LC_1000F             0x10
+#define LX_LC_ALL               \
+	(LX_LC_10H|LX_LC_10F|LX_LC_100H|LX_LC_100F|LX_LC_1000F)
+
+/* options for MAC contrl */
+#define LX_MACSPEED_1000        BIT_0S  /* 1:1000M, 0:10/100M */
+#define LX_MACDUPLEX_FULL       BIT_1S  /* 1:full, 0:half */
+#define LX_FLT_BROADCAST        BIT_2S  /* 1:enable rx-broadcast */
+#define LX_FLT_MULTI_ALL        BIT_3S
+#define LX_FLT_DIRECT           BIT_4S
+#define LX_FLT_PROMISC          BIT_5S
+#define LX_FC_TXEN              BIT_6S
+#define LX_FC_RXEN              BIT_7S
+#define LX_VLAN_STRIP           BIT_8S
+#define LX_LOOPBACK             BIT_9S
+#define LX_ADD_FCS              BIT_10S
+#define LX_SINGLE_PAUSE         BIT_11S
+
+
+/* interop between drivers */
+#define LX_DRV_TYPE_MASK                SHIFT27(0x1FUL)
+#define LX_DRV_TYPE_SHIFT               27
+#define LX_DRV_TYPE_UNKNOWN             0
+#define LX_DRV_TYPE_BIOS                1
+#define LX_DRV_TYPE_BTROM               2
+#define LX_DRV_TYPE_PKT                 3
+#define LX_DRV_TYPE_NDS2                4
+#define LX_DRV_TYPE_UEFI                5
+#define LX_DRV_TYPE_NDS5                6
+#define LX_DRV_TYPE_NDS62               7
+#define LX_DRV_TYPE_NDS63               8
+#define LX_DRV_TYPE_LNX                 9
+#define LX_DRV_TYPE_ODI16               10
+#define LX_DRV_TYPE_ODI32               11
+#define LX_DRV_TYPE_FRBSD               12
+#define LX_DRV_TYPE_NTBSD               13
+#define LX_DRV_TYPE_WCE                 14
+#define LX_DRV_PHY_AUTO                 BIT_26  /* 1:auto, 0:force */
+#define LX_DRV_PHY_1000                 BIT_25
+#define LX_DRV_PHY_100                  BIT_24
+#define LX_DRV_PHY_10                   BIT_23
+#define LX_DRV_PHY_DUPLEX               BIT_22  /* 1:full, 0:half */
+#define LX_DRV_PHY_FC                   BIT_21  /* 1:en flow control */
+#define LX_DRV_PHY_MASK                 SHIFT21(0x1FUL)
+#define LX_DRV_PHY_SHIFT                21
+#define LX_DRV_PHY_UNKNOWN              0
+#define LX_DRV_DISABLE                  BIT_18
+#define LX_DRV_WOLS5_EN                 BIT_17
+#define LX_DRV_WOLS5_BIOS_EN            BIT_16
+#define LX_DRV_AZ_EN                    BIT_12
+#define LX_DRV_WOLPATTERN_EN            BIT_11
+#define LX_DRV_WOLLINKUP_EN             BIT_10
+#define LX_DRV_WOLMAGIC_EN              BIT_9
+#define LX_DRV_WOLCAP_BIOS_EN           BIT_8
+#define LX_DRV_ASPM_SPD1000LMT_MASK     SHIFT4(3UL)
+#define LX_DRV_ASPM_SPD1000LMT_SHIFT    4
+#define LX_DRV_ASPM_SPD1000LMT_100M     0
+#define LX_DRV_ASPM_SPD1000LMT_NO       1
+#define LX_DRV_ASPM_SPD1000LMT_1M       2
+#define LX_DRV_ASPM_SPD1000LMT_10M      3
+#define LX_DRV_ASPM_SPD100LMT_MASK      SHIFT2(3UL)
+#define LX_DRV_ASPM_SPD100LMT_SHIFT     2
+#define LX_DRV_ASPM_SPD100LMT_1M        0
+#define LX_DRV_ASPM_SPD100LMT_10M       1
+#define LX_DRV_ASPM_SPD100LMT_100M      2
+#define LX_DRV_ASPM_SPD100LMT_NO        3
+#define LX_DRV_ASPM_SPD10LMT_MASK       SHIFT0(3UL)
+#define LX_DRV_ASPM_SPD10LMT_SHIFT      0
+#define LX_DRV_ASPM_SPD10LMT_1M         0
+#define LX_DRV_ASPM_SPD10LMT_10M        1
+#define LX_DRV_ASPM_SPD10LMT_100M       2
+#define LX_DRV_ASPM_SPD10LMT_NO         3
+
+/* flag of phy inited */
+#define LX_PHY_INITED           0x003F
+
+/* check if the mac address is valid */
+#define macaddr_valid(_addr) (\
+	0 == ((*(u8 *)(_addr))&1) && \
+	!(0 == *(u32 *)(_addr) && 0 == *((u16 *)(_addr)+2)))
+
+#endif/*_LX_HWCOMMON_H_*/
+
diff --git a/drivers/net/ethernet/atheros/alx/alx_main.c b/drivers/net/ethernet/atheros/alx/alx_main.c
new file mode 100755
index 0000000..18f5ac6
--- /dev/null
+++ b/drivers/net/ethernet/atheros/alx/alx_main.c
@@ -0,0 +1,3863 @@
+/*
+ * Copyright (c) 2010 - 2011 Atheros Communications Inc.
+ *
+ * Permission to use, copy, modify, and/or distribute this software for any
+ * purpose with or without fee is hereby granted, provided that the above
+ * copyright notice and this permission notice appear in all copies.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
+ * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
+ * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
+ * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
+ * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
+ * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ */
+
+#include "alx.h"
+#include "alx_hwcom.h"
+
+#define DRV_VERSION "1.0.0.0"
+#define DRV_NAPI "-NAPI"
+#define DRV_VERSION_FULL DRV_VERSION DRV_NAPI
+
+char alx_drv_name[] = "alx";
+const char alx_drv_description[] =
+	"Atheros(R) AR8131/AR8151/AR8152/AR8161 PCI-E Ethernet Network Driver";
+const char alx_drv_version[] = DRV_VERSION_FULL;
+
+static const char alx_copyright[] =
+	"Copyright (c) 2007 - 2011 Atheros Corporation";
+
+
+/* alx_pci_tbl - PCI Device ID Table
+ *
+ * Wildcard entries (PCI_ANY_ID) should come last
+ * Last entry must be all 0s
+ *
+ * { Vendor ID, Device ID, SubVendor ID, SubDevice ID,
+ *   Class, Class Mask, private data (not used) }
+ */
+#define ALX_ETHER_DEVICE(device_id) {\
+	PCI_DEVICE(ALX_VENDOR_ID, device_id)}
+DEFINE_PCI_DEVICE_TABLE(alx_pci_tbl) = {
+	ALX_ETHER_DEVICE(ALX_DEV_ID_AR8131),
+	ALX_ETHER_DEVICE(ALX_DEV_ID_AR8132),
+	ALX_ETHER_DEVICE(ALX_DEV_ID_AR8151_V1),
+	ALX_ETHER_DEVICE(ALX_DEV_ID_AR8151_V2),
+	ALX_ETHER_DEVICE(ALX_DEV_ID_AR8152_V1),
+	ALX_ETHER_DEVICE(ALX_DEV_ID_AR8152_V2),
+	ALX_ETHER_DEVICE(ALX_DEV_ID_AR8161),
+	{0,}
+};
+MODULE_DEVICE_TABLE(pci, alx_pci_tbl);
+
+MODULE_AUTHOR("Atheros Corporation, <cloud.ren@atheros.com>, "
+		"<xiong.huang@atheros.com>");
+MODULE_DESCRIPTION("Atheros Gigabit Ethernet Driver");
+MODULE_LICENSE("Dual BSD/GPL");
+MODULE_VERSION(DRV_VERSION_FULL);
+
+
+/*
+ *  alx_validate_mac_addr - Validate MAC address
+ */
+static int alx_validate_mac_addr(u8 *mac_addr)
+{
+	int retval = 0;
+
+	if (mac_addr[0] & 0x01) {
+		printk(KERN_DEBUG "MAC address is multicast\n");
+		retval = ALX_ERR_MAC_ADDR;
+	} else if (mac_addr[0] == 0xff && mac_addr[1] == 0xff) {
+		printk(KERN_DEBUG "MAC address is broadcast\n");
+		retval = ALX_ERR_MAC_ADDR;
+	} else if (mac_addr[0] == 0 && mac_addr[1] == 0 &&
+		   mac_addr[2] == 0 && mac_addr[3] == 0 &&
+		   mac_addr[4] == 0 && mac_addr[5] == 0) {
+		printk(KERN_DEBUG "MAC address is all zeros\n");
+		retval = ALX_ERR_MAC_ADDR;
+	}
+	return retval;
+}
+
+
+/*
+ *  alx_set_mac_type - Sets MAC type
+ */
+static int alx_set_mac_type(struct alx_adapter *adpt)
+{
+	struct alx_hw *hw = &adpt->hw;
+	int retval = 0;
+
+	if (hw->pci_venid == ALX_VENDOR_ID) {
+		switch (hw->pci_devid) {
+		case ALX_DEV_ID_AR8131:
+			hw->mac_type = alx_mac_l1c;
+			break;
+		case ALX_DEV_ID_AR8132:
+			hw->mac_type = alx_mac_l2c;
+			break;
+		case ALX_DEV_ID_AR8151_V1:
+			hw->mac_type = alx_mac_l1d_v1;
+			break;
+		case ALX_DEV_ID_AR8151_V2:
+			/* just use l1d configure */
+			hw->mac_type = alx_mac_l1d_v2;
+			break;
+		case ALX_DEV_ID_AR8152_V1:
+			hw->mac_type = alx_mac_l2cb_v1;
+			break;
+		case ALX_DEV_ID_AR8152_V2:
+			if (hw->pci_revid == ALX_REV_ID_AR8152_V2_0)
+				hw->mac_type = alx_mac_l2cb_v20;
+			else
+				hw->mac_type = alx_mac_l2cb_v21;
+			break;
+		case ALX_DEV_ID_AR8161:
+			hw->mac_type = alx_mac_l1f;
+			break;
+		case ALX_DEV_ID_AR8162:
+			hw->mac_type = alx_mac_l2f;
+			break;
+		default:
+			retval = ALX_ERR_NOT_SUPPORTED;
+			break;
+		}
+	} else {
+		retval = ALX_ERR_NOT_SUPPORTED;
+	}
+
+	DRV_PRINT(HW, INFO, "found mac: %d, returns: %d\n",
+		  hw->mac_type, retval);
+	return retval;
+}
+
+/*
+ *  alx_init_hw_callbacks
+ */
+static int alx_init_hw_callbacks(struct alx_adapter *adpt)
+{
+	struct alx_hw *hw = &adpt->hw;
+	int retval = 0;
+
+	alx_set_mac_type(adpt);
+
+
+	switch (hw->mac_type) {
+	case alx_mac_l1f:
+	case alx_mac_l2f:
+		retval = alf_init_hw_callbacks(hw);
+		break;
+	case alx_mac_l1c:
+	case alx_mac_l2c:
+	case alx_mac_l2cb_v1:
+	case alx_mac_l2cb_v20:
+	case alx_mac_l2cb_v21:
+	case alx_mac_l1d_v1:
+	case alx_mac_l1d_v2:
+		retval = alc_init_hw_callbacks(hw);
+		break;
+	default:
+		retval = ALX_ERR_NOT_SUPPORTED;
+		break;
+	}
+
+	return retval;
+}
+
+
+void alx_reinit_locked(struct alx_adapter *adpt)
+{
+
+	WARN_ON(in_interrupt());
+
+	/* put off any impending NetWatchDogTimeout ???? TODO */
+	adpt->netdev->trans_start = jiffies;
+
+	while (test_and_set_bit(__ALX_RESETTING, &adpt->alx_state))
+		msleep(20);
+
+	alx_stop_internal(adpt, ALX_OPEN_CTRL_MAC_EN);
+
+	alx_open_internal(adpt, ALX_OPEN_CTRL_MAC_EN);
+
+	clear_bit(__ALX_RESETTING, &adpt->alx_state);
+}
+
+
+static void alx_task_schedule(struct alx_adapter *adpt)
+{
+	if (!test_bit(__ALX_DOWN, &adpt->alx_state) &&
+	    !test_and_set_bit(__ALX_SERVICE_SCHED, &adpt->alx_state))
+		schedule_work(&adpt->alx_task);
+}
+
+static void alx_check_lsc(struct alx_adapter *adpt)
+{
+	SET_ADPT_FLAG(1, LSC_REQUESTED);
+	adpt->link_jiffies = jiffies + ALX_TRY_LINK_TIMEOUT;
+
+	if (!test_bit(__ALX_DOWN, &adpt->alx_state))
+		alx_task_schedule(adpt);
+}
+
+
+/*
+ * alx_tx_timeout - Respond to a Tx Hang
+ * @netdev: network interface device structure
+ */
+static void alx_tx_timeout(struct net_device *netdev)
+{
+	struct alx_adapter *adpt = netdev_priv(netdev);
+
+	DRV_PRINT(FUNC, DEBUG, "ENTER\n");
+
+	/* Do the reset outside of interrupt context */
+	if (!test_bit(__ALX_DOWN, &adpt->alx_state)) {
+		SET_ADPT_FLAG(1, RESET_REQUESTED);
+		alx_task_schedule(adpt);
+	}
+}
+
+/*
+ * alx_set_multicase_list - Multicast and Promiscuous mode set
+ * @netdev: network interface device structure
+ */
+static void alx_set_multicase_list(struct net_device *netdev)
+{
+	struct alx_adapter *adpt = netdev_priv(netdev);
+	struct alx_hw *hw = &adpt->hw;
+	struct netdev_hw_addr *mc_ptr;
+
+	DRV_PRINT(FUNC, DEBUG, "ENTER\n");
+
+	/* Check for Promiscuous and All Multicast modes */
+	if (netdev->flags & IFF_PROMISC) {
+		SET_HW_FLAG(PROMISC_EN);
+	} else if (netdev->flags & IFF_ALLMULTI) {
+		SET_HW_FLAG(MULTIALL_EN);
+		CLI_HW_FLAG(PROMISC_EN);
+	} else {
+		CLI_HW_FLAG(MULTIALL_EN);
+		CLI_HW_FLAG(PROMISC_EN);
+	}
+	hw->cbs.config_mac_ctrl(hw);
+
+	/* clear the old settings from the multicast hash table */
+	hw->cbs.clear_mc_addr(hw);
+
+	/* comoute mc addresses' hash value ,and put it into hash table */
+	netdev_for_each_mc_addr(mc_ptr, netdev)
+		hw->cbs.set_mc_addr(hw, mc_ptr->addr);
+}
+
+/*
+ * alx_set_mac - Change the Ethernet Address of the NIC
+ */
+static int alx_set_mac_addr(struct net_device *netdev, void *data)
+{
+	struct alx_adapter *adpt = netdev_priv(netdev);
+	struct alx_hw *hw = &adpt->hw;
+	struct sockaddr *addr = data;
+
+	DRV_PRINT(FUNC, DEBUG, "ENTER\n");
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+
+	if (netif_running(netdev))
+		return -EBUSY;
+
+	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
+	memcpy(hw->mac_addr, addr->sa_data, netdev->addr_len);
+
+	if (hw->cbs.set_mac_addr)
+		hw->cbs.set_mac_addr(hw, hw->mac_addr);
+	return 0;
+}
+
+
+/*
+ * Read / Write Ptr Initialize:
+ */
+static void alx_init_ring_ptrs(struct alx_adapter *adpt)
+{
+	int i, j;
+
+	for (i = 0; i < adpt->num_txques; i++) {
+		struct alx_tx_queue *txque = adpt->tx_queue[i];
+		struct alx_buffer *tpbuf = txque->tpq.tpbuff;
+		txque->tpq.produce_idx = 0;
+		txque->tpq.consume_idx = 0;
+		for (j = 0; j < txque->tpq.count; j++)
+			tpbuf[j].dma = 0;
+	}
+
+
+
+	for (i = 0; i < adpt->num_hw_rxques; i++) {
+		struct alx_rx_queue *rxque = adpt->rx_queue[i];
+		struct alx_buffer *rfbuf = rxque->rfq.rfbuff;
+		rxque->rrq.produce_idx = 0;
+		rxque->rrq.consume_idx = 0;
+		rxque->rfq.produce_idx = 0;
+		rxque->rfq.consume_idx = 0;
+		for (j = 0; j < rxque->rfq.count; j++)
+			rfbuf[j].dma = 0;
+	}
+
+	if (CHK_ADPT_FLAG(0, SRSS_EN))
+		goto srrs_enable;
+
+	return;
+
+srrs_enable:
+	for (i = 0; i < adpt->num_sw_rxques; i++) {
+		struct alx_rx_queue *rxque = adpt->rx_queue[i];
+		rxque->swq.produce_idx = 0;
+		rxque->swq.consume_idx = 0;
+	}
+	return;
+}
+
+
+static void alx_config_rss(struct alx_adapter *adpt)
+{
+	static const u8 key[40] = {
+		0xE2, 0x91, 0xD7, 0x3D, 0x18, 0x05, 0xEC, 0x6C,
+		0x2A, 0x94, 0xB3, 0x0D, 0xA5, 0x4F, 0x2B, 0xEC,
+		0xEA, 0x49, 0xAF, 0x7C, 0xE2, 0x14, 0xAD, 0x3D,
+		0xB8, 0x55, 0xAA, 0xBE, 0x6A, 0x3E, 0x67, 0xEA,
+		0x14, 0x36, 0x4D, 0x17, 0x3B, 0xED, 0x20, 0x0D};
+
+	struct alx_hw *hw = &adpt->hw;
+	u32 reta = 0;
+	int i, j;
+
+	/* initialize rss hash type and idt table size */
+	hw->rss_hstype = ALX_RSS_HSTYP_ALL_EN;
+	hw->rss_idt_size = 0x100;
+
+	/* Fill out redirection table */
+	memcpy(hw->rss_key, key, sizeof(hw->rss_key));
+
+	/* Fill out redirection table */
+	memset(hw->rss_idt, 0x0, sizeof(hw->rss_idt));
+	for (i = 0, j = 0; i < 256; i++, j++) {
+		if (j == adpt->max_rxques)
+			j = 0;
+		reta |= (j << ((i & 7) * 4));
+		if ((i & 7) == 7) {
+			hw->rss_idt[i>>3] = reta;
+			reta = 0;
+		}
+	}
+
+	if (hw->cbs.config_rss)
+		hw->cbs.config_rss(hw, CHK_ADPT_FLAG(0, SRSS_EN));
+}
+
+
+/* alx_receive_skb */
+static void alx_receive_skb(struct alx_msix_param *msix,
+			    struct sk_buff *skb,
+			    u32 vlan_tag, bool vlan_flag)
+{
+	struct alx_adapter *adpt = msix->adpt;
+
+	if (adpt->vlgrp && vlan_flag) {
+		u16 vlan;
+		u16 vlan_tag = (u16)vlan_tag;
+		AT_TAG_TO_VLAN(vlan_tag, vlan);
+	}
+	netif_receive_skb(skb);
+}
+
+static bool alx_get_rrdesc(struct alx_rx_queue *rxque,
+			    struct alx_rrdesc *srrd)
+{
+	struct alx_rrdesc *hrrd =
+			ALX_RRD(rxque, rxque->rrq.consume_idx);
+
+	srrd->rr_dw0 = le32_to_cpu(hrrd->rr_dw0);
+	srrd->rr_dw1 = le32_to_cpu(hrrd->rr_dw1);
+	srrd->rr_dw2 = le32_to_cpu(hrrd->rr_dw2);
+	srrd->rr_dw3 = le32_to_cpu(hrrd->rr_dw3);
+
+
+	if (!srrd->rr_gnr.update)
+		return false;
+
+#if ALX_DUMP_RRD_DESC
+	printk(KERN_INFO "RRD [hw]: %08x:%08x:%08x:%08x\n",
+			 hrrd->rr_dw0, hrrd->rr_dw1,
+			 hrrd->rr_dw2, hrrd->rr_dw3);
+	printk(KERN_INFO "RRD [sw]: %08x:%08x:%08x:%08x\n",
+			 srrd->rr_dw0, srrd->rr_dw1,
+			 srrd->rr_dw2, srrd->rr_dw3);
+#endif
+	if (likely(srrd->rr_gnr.nor != 1)) {
+		/* TODO support mul rfd*/
+		printk(KERN_EMERG "Multi rfd not support yet!\n");
+	}
+
+	srrd->rr_gnr.update = 0;
+	hrrd->rr_dw3 = cpu_to_le32(srrd->rr_dw3);
+	if (++rxque->rrq.consume_idx == rxque->rrq.count)
+		rxque->rrq.consume_idx = 0;
+
+	return true;
+}
+
+static bool alx_set_rfdesc(struct alx_rx_queue *rxque,
+			   struct alx_rfdesc *srfd)
+{
+	struct alx_rfdesc *hrfd =
+			ALX_RFD(rxque, rxque->rfq.produce_idx);
+
+	hrfd->rf_qw0 = cpu_to_le64(srfd->rf_qw0);
+
+	if (++rxque->rfq.produce_idx == rxque->rfq.count)
+		rxque->rfq.produce_idx = 0;
+
+#if ALX_DUMP_RFD_DESC
+	printk(KERN_INFO "RFD [hw]: %08x:%08x\n",
+			 hrfd->rf_dw0, hrfd->rf_dw1);
+	printk(KERN_INFO "RFD [sw]: %08x:%08x\n",
+			 srfd->rf_dw0, srfd->rf_dw1);
+#endif
+	return true;
+}
+
+
+static bool alx_set_tpdesc(struct alx_tx_queue *txque,
+			   struct alx_tpdesc *stpd)
+{
+	struct alx_tpdesc *htpd;
+
+	txque->tpq.last_produce_idx = txque->tpq.produce_idx;
+	htpd = ALX_TPD(txque, txque->tpq.produce_idx);
+
+	if (++txque->tpq.produce_idx == txque->tpq.count)
+		txque->tpq.produce_idx = 0;
+
+	htpd->tp_dw0 = cpu_to_le32(stpd->tp_dw0);
+	htpd->tp_dw1 = cpu_to_le32(stpd->tp_dw1);
+	htpd->tp_qw1 = cpu_to_le64(stpd->tp_qw1);
+
+#if ALX_DUMP_TPD_DESC
+	printk(KERN_INFO "TPD [hw]: %08x:%08x:%08x:%08x\n",
+			 htpd->tp_dw0, htpd->tp_dw1,
+			 htpd->tp_dw2, htpd->tp_dw3);
+	printk(KERN_INFO "TPD [sw]: %08x:%08x:%08x:%08x\n",
+			 stpd->tp_dw0, stpd->tp_dw1,
+			 stpd->tp_dw2, stpd->tp_dw3);
+#endif
+	return true;
+}
+
+static void alx_set_tpdesc_lastfrag(struct alx_tx_queue *txque)
+{
+	struct alx_tpdesc *htpd;
+#define ALX_TPD_LAST_FLAGMENT  0x80000000
+	htpd = ALX_TPD(txque, txque->tpq.last_produce_idx);
+	htpd->tp_dw1 |= cpu_to_le32(ALX_TPD_LAST_FLAGMENT);
+}
+
+
+static int alx_refresh_rx_buffer(struct alx_rx_queue *rxque)
+{
+	struct alx_adapter *adpt = netdev_priv(rxque->netdev);
+	struct alx_hw *hw = &adpt->hw;
+	struct alx_buffer *curr_rxbuf;
+	struct alx_buffer *next_rxbuf;
+	struct alx_rfdesc srfd;
+	struct sk_buff *skb;
+	void *skb_data = NULL;
+	u16 count = 0;
+	u16 next_produce_idx;
+
+	next_produce_idx = rxque->rfq.produce_idx;
+	if (++next_produce_idx == rxque->rfq.count)
+		next_produce_idx = 0;
+	curr_rxbuf = GET_RF_BUFFER(rxque, rxque->rfq.produce_idx);
+	next_rxbuf = GET_RF_BUFFER(rxque, next_produce_idx);
+
+	/* this always has a blank rx_buffer*/
+	while (next_rxbuf->dma == 0) {
+		skb = dev_alloc_skb(adpt->rxbuf_size);
+		if (unlikely(!skb)) {
+			DRV_PRINT(RX, INFO, "alloc rx buffer failed\n");
+			break;
+		}
+
+		/*
+		 * Make buffer alignment 2 beyond a 16 byte boundary
+		 * this will result in a 16 byte aligned IP header after
+		 * the 14 byte MAC header is removed
+		 */
+		skb_data = skb->data;
+		/*skb_reserve(skb, NET_IP_ALIGN);*/
+		curr_rxbuf->skb = skb;
+		curr_rxbuf->length = adpt->rxbuf_size;
+		curr_rxbuf->dma = dma_map_single(rxque->dev,
+						 skb_data,
+						 curr_rxbuf->length,
+						 DMA_FROM_DEVICE);
+		srfd.rf_gnr.addr = curr_rxbuf->dma;
+		alx_set_rfdesc(rxque, &srfd);
+
+		next_produce_idx = rxque->rfq.produce_idx;
+		if (++next_produce_idx == rxque->rfq.count)
+			next_produce_idx = 0;
+		curr_rxbuf = GET_RF_BUFFER(rxque, rxque->rfq.produce_idx);
+		next_rxbuf = GET_RF_BUFFER(rxque, next_produce_idx);
+		count++;
+	}
+
+	if (count) {
+		wmb();
+		MEM_W16(hw, rxque->produce_reg, rxque->rfq.produce_idx);
+		DRV_PRINT(RX, INFO, "RX[%d]: prod_reg[0x%x] = 0x%x, "
+			  "rfq.produce_idx = 0x%x\n",
+			  rxque->que_idx, rxque->produce_reg,
+			  rxque->rfq.produce_idx, rxque->rfq.produce_idx);
+	}
+	return count;
+}
+
+
+static void alx_clean_rfdesc(struct alx_rx_queue *rxque,
+		struct alx_rrdesc *srrd)
+{
+	struct alx_buffer *rfbuf = rxque->rfq.rfbuff;
+	u32 consume_idx = srrd->rr_gnr.si;
+	u32 i;
+
+	for (i = 0; i < srrd->rr_gnr.nor; i++) {
+		rfbuf[consume_idx].skb = NULL;
+		if (++consume_idx == rxque->rfq.count)
+			consume_idx = 0;
+	}
+	rxque->rfq.consume_idx = consume_idx;
+
+	return;
+}
+
+
+static bool alx_dispatch_rx_irq(struct alx_msix_param *msix,
+				struct alx_rx_queue *rxque)
+{
+	struct alx_adapter *adpt = msix->adpt;
+	struct pci_dev *pdev = adpt->pdev;
+	struct net_device *netdev  = adpt->netdev;
+
+	struct alx_rrdesc srrd;
+	struct alx_buffer *rfbuf;
+	struct sk_buff *skb;
+	struct alx_rx_queue *swque;
+	struct alx_sw_buffer *curr_swbuf;
+	struct alx_sw_buffer *next_swbuf;
+
+	u16 next_produce_idx;
+	u16 count = 0;
+
+	while (1) {
+		if (!alx_get_rrdesc(rxque, &srrd))
+			break;
+
+		if (srrd.rr_gnr.res || srrd.rr_gnr.lene) {
+			alx_clean_rfdesc(rxque, &srrd);
+			DRV_PRINT(RX, WARNING, "wrong packet!"
+				  "rrd->word3 is 0x%08x\n", srrd.rr_dw3);
+			continue;
+		}
+
+		/* Good Receive */
+		if (likely(srrd.rr_gnr.nor == 1)) {
+			rfbuf = GET_RF_BUFFER(rxque, srrd.rr_gnr.si);
+			pci_unmap_single(pdev, rfbuf->dma,
+					 rfbuf->length, DMA_FROM_DEVICE);
+			rfbuf->dma = 0;
+			skb = rfbuf->skb;
+			DRV_PRINT(RX, INFO, "skb addr = %p, rxbuf_len = %x\n",
+				  skb->data, rfbuf->length);
+		} else {
+			/* TODO */
+			DRV_PRINT(RX, EMERG, "Multil rfd not support yet!\n");
+			break;
+		}
+		alx_clean_rfdesc(rxque, &srrd);
+
+		skb_put(skb, srrd.rr_gnr.pkt_len - ETH_FCS_LEN);
+		skb->protocol = eth_type_trans(skb, netdev);
+		skb->dev = netdev;
+		skb->ip_summed = CHECKSUM_NONE;
+
+		/* start to dispatch */
+		swque = adpt->rx_queue[srrd.rr_gnr.rss_cpu];
+		next_produce_idx = swque->swq.produce_idx;
+		if (++next_produce_idx == swque->swq.count)
+			next_produce_idx = 0;
+
+		curr_swbuf = GET_SW_BUFFER(swque, swque->swq.produce_idx);
+		next_swbuf = GET_SW_BUFFER(swque, next_produce_idx);
+
+		/*
+		 * if full, will discard the packet,
+		 * and at lease has a blank sw_buffer.
+		 */
+		if (!next_swbuf->skb) {
+			curr_swbuf->skb = skb;
+			curr_swbuf->vlan_tag = srrd.rr_gnr.vlan_tag;
+			curr_swbuf->vlan_flag = srrd.rr_gnr.vlan_flag;
+			if (++swque->swq.produce_idx == swque->swq.count)
+				swque->swq.produce_idx = 0;
+		}
+
+		count++;
+		if (count == 32)
+			break;
+	}
+	if (count)
+		alx_refresh_rx_buffer(rxque);
+	return true;
+}
+
+
+
+static bool alx_handle_srx_irq(struct alx_msix_param *msix,
+			       struct alx_rx_queue *rxque,
+			       int *num_pkts, int max_pkts)
+{
+	struct alx_adapter *adpt = msix->adpt;
+	struct net_device *netdev = adpt->netdev;
+	struct alx_sw_buffer *swbuf;
+	bool retval = true;
+
+	while (rxque->swq.consume_idx != rxque->swq.produce_idx) {
+		swbuf = GET_SW_BUFFER(rxque, rxque->swq.consume_idx);
+
+		alx_receive_skb(msix, swbuf->skb, swbuf->vlan_tag,
+				(bool)swbuf->vlan_flag);
+		swbuf->skb = NULL;
+		netdev->last_rx = jiffies;
+
+		if (++rxque->swq.consume_idx == rxque->swq.count)
+			rxque->swq.consume_idx = 0;
+
+		(*num_pkts)++;
+		if (*num_pkts >= max_pkts) {
+			retval = false;
+			break;
+		}
+	}
+	return retval;
+}
+
+static bool alx_handle_rx_irq(struct alx_msix_param *msix,
+			      struct alx_rx_queue *rxque,
+			      int *num_pkts, int max_pkts)
+{
+	struct alx_adapter *adpt = msix->adpt;
+	struct pci_dev *pdev = adpt->pdev;
+	struct net_device *netdev  = adpt->netdev;
+
+	struct alx_rrdesc srrd;
+	struct alx_buffer *rfbuf;
+	struct sk_buff *skb;
+
+	u16 count = 0;
+
+	while (1) {
+		if (!alx_get_rrdesc(rxque, &srrd))
+			break;
+
+		if (srrd.rr_gnr.res || srrd.rr_gnr.lene) {
+			alx_clean_rfdesc(rxque, &srrd);
+			DRV_PRINT(RX, WARNING, "wrong packet!"
+				  "rrd->word3 is 0x%08x\n", srrd.rr_dw3);
+			continue;
+		}
+
+		/* TODO: Good Receive */
+		if (likely(srrd.rr_gnr.nor == 1)) {
+			rfbuf = GET_RF_BUFFER(rxque, srrd.rr_gnr.si);
+			pci_unmap_single(pdev, rfbuf->dma, rfbuf->length,
+					 DMA_FROM_DEVICE);
+			rfbuf->dma = 0;
+			skb = rfbuf->skb;
+		} else {
+			/* TODO */
+			DRV_PRINT(RX, EMERG, "Multil rfd not support yet!\n");
+			break;
+		}
+		alx_clean_rfdesc(rxque, &srrd);
+
+		skb_put(skb, srrd.rr_gnr.pkt_len - ETH_FCS_LEN);
+		skb->protocol = eth_type_trans(skb, netdev);
+		skb->dev = netdev;
+		skb_checksum_none_assert(skb);
+
+		alx_receive_skb(msix, skb, srrd.rr_gnr.vlan_tag,
+				srrd.rr_gnr.vlan_flag);
+
+		netdev->last_rx = jiffies;
+
+		count++;
+
+		(*num_pkts)++;
+		if (*num_pkts >= max_pkts)
+			break;
+	}
+	if (count)
+		alx_refresh_rx_buffer(rxque);
+
+	return true;
+}
+
+
+static bool alx_handle_tx_irq(struct alx_msix_param *msix,
+			      struct alx_tx_queue *txque)
+{
+	struct alx_adapter *adpt = msix->adpt;
+	struct alx_hw *hw = &adpt->hw;
+	struct alx_buffer *tpbuf;
+	u16 consume_data;
+
+	MEM_R16(hw, txque->consume_reg, &consume_data);
+	DRV_PRINT(TX, INFO, "TX[%d]: consume_reg[0x%x] = 0x%x, "
+		  "tpq.consume_idx = 0x%x.\n",
+		  txque->que_idx, txque->consume_reg, consume_data,
+		  txque->tpq.consume_idx);
+
+
+	while (txque->tpq.consume_idx != consume_data) {
+		tpbuf = GET_TP_BUFFER(txque, txque->tpq.consume_idx);
+		if (tpbuf->dma) {
+			pci_unmap_page(adpt->pdev, tpbuf->dma, tpbuf->length,
+				       DMA_TO_DEVICE);
+			tpbuf->dma = 0;
+		}
+
+		if (tpbuf->skb) {
+			dev_kfree_skb_irq(tpbuf->skb);
+			tpbuf->skb = NULL;
+		}
+
+		if (++txque->tpq.consume_idx == txque->tpq.count)
+			txque->tpq.consume_idx = 0;
+	}
+
+	if (netif_queue_stopped(adpt->netdev) &&
+		netif_carrier_ok(adpt->netdev)) {
+		netif_wake_queue(adpt->netdev);
+	}
+	return true;
+}
+
+static irqreturn_t alx_msix_timer(int irq, void *data)
+{
+	struct alx_msix_param *msix = data;
+	struct alx_adapter *adpt = msix->adpt;
+	struct alx_hw *hw = &adpt->hw;
+	u32 isr;
+
+	DRV_PRINT(FUNC, DEBUG, "ENTER\n");
+
+	hw->cbs.disable_msix_intr(hw, msix->vec_idx);
+
+	MEM_R32(hw, ALX_ISR, &isr);
+	isr = isr & (ALX_ISR_TIMER | ALX_ISR_MANU);
+
+
+	if (isr == 0) {
+		hw->cbs.enable_msix_intr(hw, msix->vec_idx);
+		return IRQ_NONE;
+	}
+
+	/* Ack ISR */
+	MEM_W32(hw, ALX_ISR, isr);
+
+	if (isr & ALX_ISR_MANU) {
+		adpt->net_stats.tx_carrier_errors++;
+		alx_check_lsc(adpt);
+	}
+
+	hw->cbs.enable_msix_intr(hw, msix->vec_idx);
+
+	return IRQ_HANDLED;
+}
+
+
+static irqreturn_t alx_msix_alert(int irq, void *data)
+{
+	struct alx_msix_param *msix = data;
+	struct alx_adapter *adpt = msix->adpt;
+	struct alx_hw *hw = &adpt->hw;
+	u32 isr;
+
+	DRV_PRINT(FUNC, DEBUG, "ENTER\n");
+
+	hw->cbs.disable_msix_intr(hw, msix->vec_idx);
+
+	MEM_R32(hw, ALX_ISR, &isr);
+	isr = isr & ALX_ISR_ALERT_MASK;
+
+	if (isr == 0) {
+		hw->cbs.enable_msix_intr(hw, msix->vec_idx);
+		return IRQ_NONE;
+	}
+	MEM_W32(hw, ALX_ISR, isr);
+
+	hw->cbs.enable_msix_intr(hw, msix->vec_idx);
+
+	return IRQ_HANDLED;
+}
+
+static irqreturn_t alx_msix_smb(int irq, void *data)
+{
+	struct alx_msix_param *msix = data;
+	struct alx_adapter *adpt = msix->adpt;
+	struct alx_hw *hw = &adpt->hw;
+
+	DRV_PRINT(FUNC, DEBUG, "ENTER\n");
+
+	hw->cbs.disable_msix_intr(hw, msix->vec_idx);
+
+	hw->cbs.enable_msix_intr(hw, msix->vec_idx);
+
+	return IRQ_HANDLED;
+}
+
+static irqreturn_t alx_msix_phy(int irq, void *data)
+{
+	struct alx_msix_param *msix = data;
+	struct alx_adapter *adpt = msix->adpt;
+	struct alx_hw *hw = &adpt->hw;
+
+	DRV_PRINT(FUNC, DEBUG, "ENTER\n");
+
+	hw->cbs.disable_msix_intr(hw, msix->vec_idx);
+
+	if (hw->cbs.ack_phy_intr)
+		hw->cbs.ack_phy_intr(hw);
+
+	adpt->net_stats.tx_carrier_errors++;
+	alx_check_lsc(adpt);
+
+	hw->cbs.enable_msix_intr(hw, msix->vec_idx);
+
+	return IRQ_HANDLED;
+}
+
+/*
+ * alx_msix_rtx
+ */
+static irqreturn_t alx_msix_rtx(int irq, void *data)
+{
+	struct alx_msix_param *msix = data;
+	struct alx_adapter  *adpt = msix->adpt;
+	struct alx_hw *hw = &adpt->hw;
+
+	DRV_PRINT(INTR, INFO, "msix vec_idx = %d.\n", msix->vec_idx);
+
+	hw->cbs.disable_msix_intr(hw, msix->vec_idx);
+	if (!msix->rx_count && !msix->tx_count) {
+		hw->cbs.enable_msix_intr(hw, msix->vec_idx);
+		return IRQ_HANDLED;
+	}
+
+	napi_schedule(&msix->napi);
+	return IRQ_HANDLED;
+}
+
+/*
+ * alx_napi_msix_rtx
+ */
+static int alx_napi_msix_rtx(struct napi_struct *napi, int max_pkts)
+{
+	struct alx_msix_param *msix =
+			       container_of(napi, struct alx_msix_param, napi);
+	struct alx_adapter *adpt = msix->adpt;
+	struct alx_hw *hw = &adpt->hw;
+	struct alx_rx_queue *rxque;
+	struct alx_rx_queue *swque;
+	struct alx_tx_queue *txque;
+	unsigned long flags = 0;
+	bool complete = true;
+	int num_pkts = 0;
+	int rque_idx, tque_idx;
+	int i, j;
+
+	DRV_PRINT(INTR, INFO, "NAPI: enter alx_napi_msix_rtx.\n");
+
+	/* RX */
+	for (i = 0; i < msix->rx_count; i++) {
+		rque_idx = msix->rx_map[i];
+		num_pkts = 0;
+		if (CHK_ADPT_FLAG(0, SRSS_EN)) {
+			if (!spin_trylock_irqsave(&adpt->rx_lock, flags))
+				goto clean_sw_irq;
+
+			for (j = 0; j < adpt->num_hw_rxques; j++)
+				alx_dispatch_rx_irq(msix, adpt->rx_queue[j]);
+
+			spin_unlock_irqrestore(&adpt->rx_lock, flags);
+clean_sw_irq:
+			swque = adpt->rx_queue[rque_idx];
+			complete &= alx_handle_srx_irq(msix, swque, &num_pkts,
+						       max_pkts);
+
+		} else {
+			rxque = adpt->rx_queue[rque_idx];
+			complete &= alx_handle_rx_irq(msix, rxque, &num_pkts,
+						      max_pkts);
+		}
+	}
+
+
+	/* Handle TX */
+	for (i = 0; i < msix->tx_count; i++) {
+		tque_idx = msix->tx_map[i];
+		txque = adpt->tx_queue[tque_idx];
+		complete &= alx_handle_tx_irq(msix, txque);
+	}
+
+	if (!complete) {
+		DRV_PRINT(INTR, INFO, "Some packets in the queue "
+				"are not handled!");
+		num_pkts = max_pkts;
+	}
+
+	DRV_PRINT(INTR, INFO, "num_pkts = %d, max_pkts = %d.\n",
+			num_pkts, max_pkts);
+	/* If all work done, exit the polling mode */
+	if (num_pkts < max_pkts) {
+		napi_complete(napi);
+		if (!test_bit(__ALX_DOWN, &adpt->alx_state))
+			hw->cbs.enable_msix_intr(hw, msix->vec_idx);
+	}
+
+	return num_pkts;
+}
+
+
+
+/*
+ * alx_napi_legacy_rtx - NAPI Rx polling callback
+ * @adpt: board private structure
+ */
+static int alx_napi_legacy_rtx(struct napi_struct *napi, int max_pkts)
+{
+	struct alx_msix_param *msix =
+				container_of(napi, struct alx_msix_param, napi);
+	struct alx_adapter *adpt = msix->adpt;
+	struct alx_hw *hw = &adpt->hw;
+	int complete = true;
+	int num_pkts = 0;
+	int que_idx;
+
+	DRV_PRINT(INTR, INFO, "NAPI: enter alx_napi_legacy_rtx.\n");
+
+	/* Keep link state information with original netdev */
+	if (!netif_carrier_ok(adpt->netdev))
+		goto enable_rtx_irq;
+
+	for (que_idx = 0; que_idx < adpt->num_txques; que_idx++)
+		complete &= alx_handle_tx_irq(msix, adpt->tx_queue[que_idx]);
+
+	for (que_idx = 0; que_idx < adpt->num_hw_rxques; que_idx++) {
+		num_pkts = 0;
+		complete &= alx_handle_rx_irq(msix, adpt->rx_queue[que_idx],
+					      &num_pkts, max_pkts);
+	}
+
+	if (!complete)
+		num_pkts = max_pkts;
+
+	if (num_pkts < max_pkts) {
+enable_rtx_irq:
+		napi_complete(napi);
+		hw->intr_mask |= (ALX_ISR_RXQ | ALX_ISR_TXQ);
+		MEM_W32(hw, ALX_IMR, hw->intr_mask);
+	}
+	return num_pkts;
+}
+
+
+static void alx_set_msix_flags(struct alx_msix_param *msix,
+		enum alx_msix_type type, int index)
+{
+	if (type == alx_msix_type_rx) {
+		switch (index) {
+		case 0:
+			SET_MSIX_FLAG(RX0);
+			break;
+		case 1:
+			SET_MSIX_FLAG(RX1);
+			break;
+		case 2:
+			SET_MSIX_FLAG(RX2);
+			break;
+		case 3:
+			SET_MSIX_FLAG(RX3);
+			break;
+		case 4:
+			SET_MSIX_FLAG(RX4);
+			break;
+		case 5:
+			SET_MSIX_FLAG(RX5);
+			break;
+		case 6:
+			SET_MSIX_FLAG(RX6);
+			break;
+		case 7:
+			SET_MSIX_FLAG(RX7);
+			break;
+		default:
+			printk(KERN_ERR "alx_set_msix_flags: rx error.");
+			break;
+		}
+	} else if (type == alx_msix_type_tx) {
+		switch (index) {
+		case 0:
+			SET_MSIX_FLAG(TX0);
+			break;
+		case 1:
+			SET_MSIX_FLAG(TX1);
+			break;
+		case 2:
+			SET_MSIX_FLAG(TX2);
+			break;
+		case 3:
+			SET_MSIX_FLAG(TX3);
+			break;
+		default:
+			printk(KERN_ERR "alx_set_msix_flags: tx error.");
+			break;
+		}
+	} else if (type == alx_msix_type_other) {
+		switch (index) {
+		case ALX_MSIX_TYPE_OTH_TIMER:
+			SET_MSIX_FLAG(TIMER);
+			break;
+		case ALX_MSIX_TYPE_OTH_ALERT:
+			SET_MSIX_FLAG(ALERT);
+			break;
+		case ALX_MSIX_TYPE_OTH_SMB:
+			SET_MSIX_FLAG(SMB);
+			break;
+		case ALX_MSIX_TYPE_OTH_PHY:
+			SET_MSIX_FLAG(PHY);
+			break;
+		default:
+			printk(KERN_ERR "alx_set_msix_flags: other error.");
+			break;
+		}
+	}
+}
+
+/* alx_setup_msix_maps */
+static int alx_setup_msix_maps(struct alx_adapter *adpt)
+{
+	int msix_idx = 0;
+	int que_idx = 0;
+	int num_rxques = adpt->num_rxques;
+	int num_txques = adpt->num_txques;
+	int num_msix_rxques = adpt->num_msix_rxques;
+	int num_msix_txques = adpt->num_msix_txques;
+	int num_msix_noques = adpt->num_msix_noques;
+	int retval = 0;
+
+	if (!CHK_ADPT_FLAG(0, MSIX_EN))
+		goto out;
+
+	if (CHK_ADPT_FLAG(0, FIXED_MSIX))
+		goto fixed_msix_map;
+
+	DRV_PRINT(IF, ERR, "don't support non-fixed msix map\n");
+	return -1;
+
+fixed_msix_map:
+	/*
+	 * For RX queue msix map
+	 */
+	msix_idx = 0;
+	for (que_idx = 0; que_idx < num_msix_rxques; que_idx++, msix_idx++) {
+		struct alx_msix_param *msix = adpt->msix[msix_idx];
+		if (que_idx < num_rxques) {
+			adpt->rx_queue[que_idx]->msix = msix;
+			msix->rx_map[msix->rx_count] = que_idx;
+			msix->rx_count++;
+			alx_set_msix_flags(msix, alx_msix_type_rx, que_idx);
+		}
+	}
+	if (msix_idx != num_msix_rxques)
+		DRV_PRINT(IF, ERR, "msix_idx is wrong.\n");
+
+	/*
+	 * For TX queue msix map
+	 */
+	for (que_idx = 0; que_idx < num_msix_txques; que_idx++, msix_idx++) {
+		struct alx_msix_param *msix = adpt->msix[msix_idx];
+		if (que_idx < num_txques) {
+			adpt->tx_queue[que_idx]->msix = msix;
+			msix->tx_map[msix->tx_count] = que_idx;
+			msix->tx_count++;
+			alx_set_msix_flags(msix, alx_msix_type_tx, que_idx);
+		}
+	}
+	if (msix_idx != (num_msix_rxques + num_msix_txques))
+		DRV_PRINT(IF, ERR, "msix_idx is wrong.\n");
+
+
+	/*
+	 * For NON queue msix map
+	 */
+	for (que_idx = 0; que_idx < num_msix_noques; que_idx++, msix_idx++) {
+		struct alx_msix_param *msix = adpt->msix[msix_idx];
+		alx_set_msix_flags(msix, alx_msix_type_other, que_idx);
+	}
+out:
+	return retval;
+}
+
+static inline void alx_reset_msix_maps(struct alx_adapter *adpt)
+{
+	int que_idx, msix_idx;
+
+	for (que_idx = 0; que_idx < adpt->num_rxques; que_idx++)
+		adpt->rx_queue[que_idx]->msix = NULL;
+	for (que_idx = 0; que_idx < adpt->num_txques; que_idx++)
+		adpt->tx_queue[que_idx]->msix = NULL;
+
+	for (msix_idx = 0; msix_idx < adpt->num_msix_intrs; msix_idx++) {
+		struct alx_msix_param *msix = adpt->msix[msix_idx];
+		memset(msix->rx_map, 0, sizeof(msix->rx_map));
+		memset(msix->tx_map, 0, sizeof(msix->tx_map));
+		msix->rx_count = 0;
+		msix->tx_count = 0;
+		CLI_MSIX_FLAG(ALL);
+	}
+}
+
+
+/*
+ * alx_enable_intr - Enable default interrupt generation settings
+ */
+static inline void alx_enable_intr(struct alx_adapter *adpt)
+{
+	struct alx_hw *hw = &adpt->hw;
+	int i;
+
+	if (!atomic_dec_and_test(&adpt->irq_sem))
+		return;
+
+	if (hw->cbs.enable_legacy_intr)
+		hw->cbs.enable_legacy_intr(hw);
+
+	/* enable all MSIX IRQs */
+	for (i = 0; i < adpt->num_msix_intrs; i++) {
+		if (hw->cbs.disable_msix_intr)
+			hw->cbs.disable_msix_intr(hw, i);
+		if (hw->cbs.enable_msix_intr)
+			hw->cbs.enable_msix_intr(hw, i);
+	}
+}
+
+/* alx_disable_intr - Mask off interrupt generation on the NIC */
+static inline void alx_disable_intr(struct alx_adapter *adpt)
+{
+	struct alx_hw *hw = &adpt->hw;
+	atomic_inc(&adpt->irq_sem);
+
+	if (hw->cbs.disable_legacy_intr)
+		hw->cbs.disable_legacy_intr(hw);
+
+	if (CHK_ADPT_FLAG(0, MSIX_EN)) {
+		int i;
+		for (i = 0; i < adpt->num_msix_intrs; i++) {
+			synchronize_irq(adpt->msix_entries[i].vector);
+			hw->cbs.disable_msix_intr(hw, i);
+		}
+	} else {
+		synchronize_irq(adpt->pdev->irq);
+	}
+
+
+}
+
+/*
+ * alx_interrupt - Interrupt Handler
+ * @irq: interrupt number
+ * @data: pointer to a network interface device structure
+ */
+static irqreturn_t alx_interrupt(int irq, void *data)
+{
+	struct net_device *netdev  = data;
+	struct alx_adapter *adpt = netdev_priv(netdev);
+	struct pci_dev *pdev = adpt->pdev;
+	struct alx_hw *hw = &adpt->hw;
+	struct alx_msix_param *msix = adpt->msix[0];
+	int max_intrs = ALX_MAX_HANDLED_INTRS;
+	u32 isr, status;
+
+	do {
+		MEM_R32(hw, ALX_ISR, &isr);
+		status = isr & hw->intr_mask;
+
+		if (status == 0) {
+			MEM_W32(hw, ALX_ISR, 0);
+			if (max_intrs != ALX_MAX_HANDLED_INTRS)
+				return IRQ_HANDLED;
+			return IRQ_NONE;
+		}
+
+		/* ack ISR to PHY register */
+		if (status & ALX_ISR_PHY)
+			hw->cbs.ack_phy_intr(hw);
+		/* ack ISR to MAC register */
+		MEM_W32(hw, ALX_ISR, status | ALX_ISR_DIS);
+
+		/* check if PCIE PHY Link down */
+		if (status & ALX_ISR_ERROR) {
+			DRV_PRINT(INTR, ERR, "ISR error (status = 0x%lx).\n",
+					     status & ALX_ISR_ERROR);
+			/* reset MAC */
+			SET_ADPT_FLAG(1, RESET_REQUESTED);
+			alx_task_schedule(adpt);
+			return IRQ_HANDLED;
+		}
+
+		if (status & (ALX_ISR_RXQ | ALX_ISR_TXQ)) {
+			if (napi_schedule_prep(&(msix->napi))) {
+				hw->intr_mask &= ~(ALX_ISR_RXQ | ALX_ISR_TXQ);
+				MEM_W32(hw, ALX_IMR, hw->intr_mask);
+				__napi_schedule(&(msix->napi));
+			}
+		}
+
+		if (status & ALX_ISR_OVER) {
+			dev_err(&pdev->dev,
+					"TX/RX over flow (status = 0x%lx).\n",
+					status & ALX_ISR_OVER);
+		}
+
+		/* link event */
+		if (status & (ALX_ISR_PHY | ALX_ISR_MANU)) {
+			adpt->net_stats.tx_carrier_errors++;
+			alx_check_lsc(adpt);
+			break;
+		}
+
+	} while (--max_intrs > 0);
+	/* re-enable Interrupt*/
+	MEM_W32(hw, ALX_ISR, 0);
+	return IRQ_HANDLED;
+}
+
+
+/*
+ * alx_request_msix_irqs - Initialize MSI-X interrupts
+ */
+static int alx_request_msix_irq(struct alx_adapter *adpt)
+{
+	struct net_device *netdev = adpt->netdev;
+	irqreturn_t (*handler)(int, void *);
+	int msix_idx;
+	int num_msix_intrs = adpt->num_msix_intrs;
+	int rx_idx = 0, tx_idx = 0;
+	int i;
+	int retval;
+
+	retval = alx_setup_msix_maps(adpt);
+	if (retval)
+		return retval;
+
+	for (msix_idx = 0; msix_idx < num_msix_intrs; msix_idx++) {
+		struct alx_msix_param *msix = adpt->msix[msix_idx];
+
+		if (CHK_MSIX_FLAG(RXS) && CHK_MSIX_FLAG(TXS)) {
+			handler = &alx_msix_rtx;
+			sprintf(msix->name, "%s:%s%d",
+					    netdev->name, "rtx", rx_idx);
+			rx_idx++;
+			tx_idx++;
+		} else if (CHK_MSIX_FLAG(RXS)) {
+			handler = &alx_msix_rtx;
+			sprintf(msix->name, "%s:%s%d",
+					    netdev->name, "rx", rx_idx);
+			rx_idx++;
+		} else if (CHK_MSIX_FLAG(TXS)) {
+			handler = &alx_msix_rtx;
+			sprintf(msix->name, "%s:%s%d",
+					    netdev->name, "tx", tx_idx);
+			tx_idx++;
+		} else if (CHK_MSIX_FLAG(TIMER)) {
+			handler = &alx_msix_timer;
+			sprintf(msix->name, "%s:%s", netdev->name, "timer");
+		} else if (CHK_MSIX_FLAG(ALERT)) {
+			handler = &alx_msix_alert;
+			sprintf(msix->name, "%s:%s", netdev->name, "alert");
+		} else if (CHK_MSIX_FLAG(SMB)) {
+			handler = &alx_msix_smb;
+			sprintf(msix->name, "%s:%s", netdev->name, "smb");
+		} else if (CHK_MSIX_FLAG(PHY)) {
+			handler = &alx_msix_phy;
+			sprintf(msix->name, "%s:%s", netdev->name, "phy");
+		} else {
+			DRV_PRINT(IF, INFO, "The MSIX Entry [%d] is blank.\n",
+					    msix->vec_idx);
+			continue;
+		}
+		DRV_PRINT(IF, INFO, "the MSIX entry [%d] is %s.\n",
+				    msix->vec_idx, msix->name);
+		retval = request_irq(adpt->msix_entries[msix_idx].vector,
+				     handler, 0, msix->name, msix);
+		if (retval) {
+			DRV_PRINT(IF, ERR, "request_irq failed for MSIX "
+					   "Error: %d\n", retval);
+			goto free_msix_irq;
+		}
+		/* assign the mask for this irq */
+		irq_set_affinity_hint(adpt->msix_entries[msix_idx].vector,
+				      msix->affinity_mask);
+	}
+	return retval;
+
+
+free_msix_irq:
+	for (i = 0; i < msix_idx; i++) {
+		irq_set_affinity_hint(adpt->msix_entries[i].vector, NULL);
+		free_irq(adpt->msix_entries[i].vector, adpt->msix[i]);
+	}
+	CLI_ADPT_FLAG(0, MSIX_EN);
+	pci_disable_msix(adpt->pdev);
+	kfree(adpt->msix_entries);
+	adpt->msix_entries = NULL;
+	return retval;
+}
+
+/*
+ * alx_request_irq - initialize interrupts
+ */
+static int alx_request_irq(struct alx_adapter *adpt)
+{
+	struct net_device *netdev = adpt->netdev;
+	int retval;
+
+	/* request MSIX irq */
+	if (CHK_ADPT_FLAG(0, MSIX_EN)) {
+		retval = alx_request_msix_irq(adpt);
+		if (retval)
+			DRV_PRINT(IF, ERR, "request msix irq failed, "
+					"error = %d.\n", retval);
+		goto out;
+	}
+
+	/* request MSI irq */
+	if (CHK_ADPT_FLAG(0, MSI_EN)) {
+		retval = request_irq(adpt->pdev->irq, &alx_interrupt, 0,
+			netdev->name, netdev);
+		if (retval)
+			DRV_PRINT(IF, ERR, "request msix irq failed, "
+					"error = %d.\n", retval);
+		goto out;
+	}
+
+	/* request shared irq */
+	retval = request_irq(adpt->pdev->irq, &alx_interrupt, IRQF_SHARED,
+			netdev->name, netdev);
+	if (retval)
+		DRV_PRINT(IF, ERR, "request shared irq failed, "
+				"error = %d\n", retval);
+out:
+	return retval;
+}
+
+
+static void alx_free_irq(struct alx_adapter *adpt)
+{
+	struct net_device *netdev = adpt->netdev;
+	int i;
+
+	if (CHK_ADPT_FLAG(0, MSIX_EN)) {
+		for (i = 0; i < adpt->num_msix_intrs; i++) {
+			struct alx_msix_param *msix = adpt->msix[i];
+			DRV_PRINT(IF, INFO, "msix entry = %d\n", i);
+			if (!CHK_MSIX_FLAG(ALL))
+				continue;
+			if (CHK_MSIX_FLAG(RXS) || CHK_MSIX_FLAG(TXS)) {
+				irq_set_affinity_hint(
+					adpt->msix_entries[i].vector, NULL);
+			}
+			free_irq(adpt->msix_entries[i].vector, msix);
+		}
+		alx_reset_msix_maps(adpt);
+	} else {
+		free_irq(adpt->pdev->irq, netdev);
+	}
+}
+
+
+static void alx_vlan_rx_register(struct net_device *netdev,
+				 struct vlan_group *grp)
+{
+	struct alx_adapter *adpt = netdev_priv(netdev);
+	struct alx_hw *hw = &adpt->hw;
+
+	if (!test_bit(__ALX_DOWN, &adpt->alx_state))
+		alx_disable_intr(adpt);
+
+	adpt->vlgrp = grp;
+	if (adpt->vlgrp) {
+		/* enable VLAN tag insert/strip */
+		SET_HW_FLAG(VLANSTRIP_EN);
+	} else {
+		/* disable VLAN tag insert/strip */
+		CLI_HW_FLAG(VLANSTRIP_EN);
+	}
+	hw->cbs.config_mac_ctrl(hw);
+
+	if (!test_bit(__ALX_DOWN, &adpt->alx_state))
+		alx_enable_intr(adpt);
+}
+
+static void alx_restore_vlan(struct alx_adapter *adpt)
+{
+	alx_vlan_rx_register(adpt->netdev, adpt->vlgrp);
+}
+
+
+static void alx_napi_enable_all(struct alx_adapter *adpt)
+{
+	struct alx_msix_param *msix;
+	int num_msix_intrs = adpt->num_msix_intrs;
+	int msix_idx;
+
+	if (!CHK_ADPT_FLAG(0, MSIX_EN))
+		num_msix_intrs = 1;
+
+	for (msix_idx = 0; msix_idx < num_msix_intrs; msix_idx++) {
+		struct napi_struct *napi;
+		msix = adpt->msix[msix_idx];
+		napi = &msix->napi;
+		napi_enable(napi);
+	}
+}
+
+static void alx_napi_disable_all(struct alx_adapter *adpt)
+{
+	struct alx_msix_param *msix;
+	int num_msix_intrs = adpt->num_msix_intrs;
+	int msix_idx;
+
+	if (!CHK_ADPT_FLAG(0, MSIX_EN))
+		num_msix_intrs = 1;
+
+	for (msix_idx = 0; msix_idx < num_msix_intrs; msix_idx++) {
+		msix = adpt->msix[msix_idx];
+		napi_disable(&msix->napi);
+	}
+}
+
+
+static void alx_clean_tx_queue(struct alx_tx_queue *txque)
+{
+	struct device *dev = txque->dev;
+	unsigned long size;
+	u16 i;
+
+	/* ring already cleared, nothing to do */
+	if (!txque->tpq.tpbuff)
+		return;
+
+	for (i = 0; i < txque->tpq.count; i++) {
+		struct alx_buffer *tpbuf;
+		tpbuf = GET_TP_BUFFER(txque, i);
+		if (tpbuf->dma) {
+			pci_unmap_single(to_pci_dev(dev),
+					tpbuf->dma,
+					tpbuf->length,
+					DMA_TO_DEVICE);
+			tpbuf->dma = 0;
+		}
+		if (tpbuf->skb) {
+			dev_kfree_skb_any(tpbuf->skb);
+			tpbuf->skb = NULL;
+		}
+	}
+
+	size = sizeof(struct alx_buffer) * txque->tpq.count;
+	memset(txque->tpq.tpbuff, 0, size);
+
+	/* Zero out Tx-buffers */
+	memset(txque->tpq.tpdesc, 0, txque->tpq.size);
+
+	txque->tpq.consume_idx = 0;
+	txque->tpq.produce_idx = 0;
+}
+
+
+/*
+ * alx_clean_all_tx_queues
+ */
+static void alx_clean_all_tx_queues(struct alx_adapter *adpt)
+{
+	int i;
+
+	for (i = 0; i < adpt->num_txques; i++)
+		alx_clean_tx_queue(adpt->tx_queue[i]);
+}
+
+static void alx_clean_rx_queue(struct alx_rx_queue *rxque)
+{
+	struct device *dev = rxque->dev;
+	unsigned long size;
+	int i;
+
+	if (CHK_RX_FLAG(HW_QUE)) {
+		/* ring already cleared, nothing to do */
+		if (!rxque->rfq.rfbuff)
+			goto clean_sw_queue;
+
+		for (i = 0; i < rxque->rfq.count; i++) {
+			struct alx_buffer *rfbuf;
+			rfbuf = GET_RF_BUFFER(rxque, i);
+
+			if (rfbuf->dma) {
+				pci_unmap_single(to_pci_dev(dev),
+						rfbuf->dma,
+						rfbuf->length,
+						DMA_FROM_DEVICE);
+				rfbuf->dma = 0;
+			}
+			if (rfbuf->skb) {
+				dev_kfree_skb(rfbuf->skb);
+				rfbuf->skb = NULL;
+			}
+		}
+		size =  sizeof(struct alx_buffer) * rxque->rfq.count;
+		memset(rxque->rfq.rfbuff, 0, size);
+
+		/* zero out the descriptor ring */
+		memset(rxque->rrq.rrdesc, 0, rxque->rrq.size);
+		rxque->rrq.produce_idx = 0;
+		rxque->rrq.consume_idx = 0;
+
+		memset(rxque->rfq.rfdesc, 0, rxque->rfq.size);
+		rxque->rfq.produce_idx = 0;
+		rxque->rfq.consume_idx = 0;
+	}
+clean_sw_queue:
+	if (CHK_RX_FLAG(SW_QUE)) {
+		/* ring already cleared, nothing to do */
+		if (!rxque->swq.swbuff)
+			return;
+
+		for (i = 0; i < rxque->swq.count; i++) {
+			struct alx_sw_buffer *swbuf;
+			swbuf = GET_SW_BUFFER(rxque, i);
+
+			/* swq doesn't map DMA*/
+
+			if (swbuf->skb) {
+				dev_kfree_skb(swbuf->skb);
+				swbuf->skb = NULL;
+			}
+		}
+		size =  sizeof(struct alx_buffer) * rxque->swq.count;
+		memset(rxque->swq.swbuff, 0, size);
+
+		/* swq doesn't have any descripter rings */
+		rxque->swq.produce_idx = 0;
+		rxque->swq.consume_idx = 0;
+	}
+}
+
+
+/*
+ * alx_clean_all_rx_queues
+ */
+static void alx_clean_all_rx_queues(struct alx_adapter *adpt)
+{
+	int i;
+	for (i = 0; i < adpt->num_rxques; i++)
+		alx_clean_rx_queue(adpt->rx_queue[i]);
+}
+
+
+/**
+ * alx_set_rss_queues: Allocate queues for RSS
+ * @adpt: board private structure to initialize
+ **/
+static inline void alx_set_num_txques(struct alx_adapter *adpt)
+{
+	struct alx_hw *hw = &adpt->hw;
+
+	if (hw->mac_type == alx_mac_l1f || hw->mac_type == alx_mac_l2f)
+		adpt->num_txques = 4;
+	else
+		adpt->num_txques = 2;
+
+	return;
+}
+
+/*
+ * alx_set_rss_queues: Allocate queues for RSS
+ * @adpt: board private structure to initialize
+ */
+static inline void alx_set_num_rxques(struct alx_adapter *adpt)
+{
+	if (CHK_ADPT_FLAG(0, SRSS_CAP)) {
+		adpt->num_hw_rxques = 1;
+		adpt->num_sw_rxques = adpt->max_rxques;
+		adpt->num_rxques =
+			max(adpt->num_hw_rxques, adpt->num_sw_rxques);
+	}
+
+	return;
+}
+
+/*
+ * alx_set_num_queues: Allocate queues for device, feature dependant
+ * @adpt: board private structure to initialize
+ **/
+static void alx_set_num_queues(struct alx_adapter *adpt)
+{
+	/* Start with default case */
+	adpt->num_txques = 1;
+	adpt->num_rxques = 1;
+	adpt->num_hw_rxques = 1;
+	adpt->num_sw_rxques = 0;
+
+	alx_set_num_rxques(adpt);
+	alx_set_num_txques(adpt);
+
+	return;
+}
+
+/* alx_alloc_all_rtx_queue - allocate all queues */
+static int alx_alloc_all_rtx_queue(struct alx_adapter *adpt)
+{
+	int que_idx;
+
+	for (que_idx = 0; que_idx < adpt->num_txques; que_idx++) {
+		struct alx_tx_queue *txque = adpt->tx_queue[que_idx];
+
+		txque = kzalloc(sizeof(struct alx_tx_queue), GFP_KERNEL);
+		if (!txque)
+			goto err_alloc_tx_queue;
+		txque->tpq.count = adpt->num_txdescs;
+		txque->que_idx = que_idx;
+		txque->dev = &adpt->pdev->dev;
+		txque->netdev = adpt->netdev;
+
+		adpt->tx_queue[que_idx] = txque;
+	}
+
+	for (que_idx = 0; que_idx < adpt->num_rxques; que_idx++) {
+		struct alx_rx_queue *rxque = adpt->rx_queue[que_idx];
+
+		rxque = kzalloc(sizeof(struct alx_rx_queue), GFP_KERNEL);
+		if (!rxque)
+			goto err_alloc_rx_queue;
+		rxque->rrq.count = adpt->num_rxdescs;
+		rxque->rfq.count = adpt->num_rxdescs;
+		rxque->swq.count = adpt->num_rxdescs;
+		rxque->que_idx = que_idx;
+		rxque->dev = &adpt->pdev->dev;
+		rxque->netdev = adpt->netdev;
+
+		if (CHK_ADPT_FLAG(0, SRSS_EN)) {
+			if (que_idx < adpt->num_hw_rxques)
+				SET_RX_FLAG(HW_QUE);
+			if (que_idx < adpt->num_sw_rxques)
+				SET_RX_FLAG(SW_QUE);
+		} else {
+			SET_RX_FLAG(HW_QUE);
+		}
+		adpt->rx_queue[que_idx] = rxque;
+	}
+	DRV_PRINT(INIT, DEBUG, "num_tx_descs = %d, num_rx_descs = %d\n",
+			adpt->num_txdescs, adpt->num_rxdescs);
+	return 0;
+
+err_alloc_rx_queue:
+	DRV_PRINT(INIT, ERR, "goto err_alloc_rx_queue");
+	for (que_idx = 0; que_idx < adpt->num_rxques; que_idx++)
+		kfree(adpt->rx_queue[que_idx]);
+err_alloc_tx_queue:
+	DRV_PRINT(INIT, ERR, "goto err_alloc_tx_queue");
+	for (que_idx = 0; que_idx < adpt->num_txques; que_idx++)
+		kfree(adpt->tx_queue[que_idx]);
+	return -ENOMEM;
+}
+
+
+/* alx_free_all_rtx_queue */
+static void alx_free_all_rtx_queue(struct alx_adapter *adpt)
+{
+	int que_idx;
+
+	for (que_idx = 0; que_idx < adpt->num_txques; que_idx++) {
+		kfree(adpt->tx_queue[que_idx]);
+		adpt->tx_queue[que_idx] = NULL;
+	}
+	for (que_idx = 0; que_idx < adpt->num_rxques; que_idx++) {
+		kfree(adpt->rx_queue[que_idx]);
+		adpt->rx_queue[que_idx] = NULL;
+	}
+}
+
+/* alx_set_interrupt_param - set interrupt parameter */
+static int alx_set_interrupt_param(struct alx_adapter *adpt)
+{
+	struct alx_msix_param *msix;
+	int (*poll)(struct napi_struct *, int);
+	int msix_idx;
+
+	if (CHK_ADPT_FLAG(0, MSIX_EN)) {
+		poll = &alx_napi_msix_rtx;
+	} else {
+		adpt->num_msix_intrs = 1;
+		poll = &alx_napi_legacy_rtx;
+	}
+
+	for (msix_idx = 0; msix_idx < adpt->num_msix_intrs; msix_idx++) {
+		msix = kzalloc(sizeof(struct alx_msix_param),
+					   GFP_KERNEL);
+		if (!msix)
+			goto err_alloc_msix;
+		msix->adpt = adpt;
+		msix->vec_idx = msix_idx;
+		/* Allocate the affinity_hint cpumask, configure the mask */
+		if (!alloc_cpumask_var(&msix->affinity_mask, GFP_KERNEL))
+			goto err_alloc_cpumask;
+
+		cpumask_set_cpu((msix_idx % num_online_cpus()),
+				msix->affinity_mask);
+
+		netif_napi_add(adpt->netdev, &msix->napi, (*poll), 64);
+		adpt->msix[msix_idx] = msix;
+	}
+	return 0;
+
+err_alloc_cpumask:
+	kfree(msix);
+	adpt->msix[msix_idx] = NULL;
+err_alloc_msix:
+	for (msix_idx--; msix_idx >= 0; msix_idx--) {
+		msix = adpt->msix[msix_idx];
+		netif_napi_del(&msix->napi);
+		free_cpumask_var(msix->affinity_mask);
+		kfree(msix);
+		adpt->msix[msix_idx] = NULL;
+	}
+	DRV_PRINT(INTR, ERR, "can't allocate memory.\n");
+	return -ENOMEM;
+}
+
+/**
+ * alx_reset_interrupt_param - Free memory allocated for interrupt vectors
+ * @adpt: board private structure to initialize
+ **/
+static void alx_reset_interrupt_param(struct alx_adapter *adpt)
+{
+	int msix_idx;
+
+	for (msix_idx = 0; msix_idx < adpt->num_msix_intrs; msix_idx++) {
+		struct alx_msix_param *msix = adpt->msix[msix_idx];
+		netif_napi_del(&msix->napi);
+		free_cpumask_var(msix->affinity_mask);
+		kfree(msix);
+		adpt->msix[msix_idx] = NULL;
+	}
+}
+
+/* set msix interrupt mode */
+static int alx_set_msix_interrupt_mode(struct alx_adapter *adpt)
+{
+	int msix_intrs, msix_idx;
+	int retval = 0;
+
+	adpt->msix_entries = kcalloc(adpt->max_msix_intrs,
+				sizeof(struct msix_entry), GFP_KERNEL);
+	if (!adpt->msix_entries) {
+		DRV_PRINT(INTR, ERR, "can't allocate msix entry.\n");
+		retval = -1;
+		goto try_msi_mode;
+	}
+
+	for (msix_idx = 0; msix_idx < adpt->max_msix_intrs; msix_idx++)
+		adpt->msix_entries[msix_idx].entry = msix_idx;
+
+
+	msix_intrs = adpt->max_msix_intrs;
+	while (msix_intrs >= adpt->min_msix_intrs) {
+		retval = pci_enable_msix(adpt->pdev, adpt->msix_entries,
+				      msix_intrs);
+		if (!retval) /* Success in acquiring all requested vectors. */
+			break;
+		else if (retval < 0)
+			msix_intrs = 0; /* Nasty failure, quit now */
+		else /* error == number of vectors we should try again with */
+			msix_intrs = retval;
+	}
+	if (msix_intrs < adpt->min_msix_intrs) {
+		DRV_PRINT(INTR, INFO, "can't enable MSI-X interrupts\n");
+		CLI_ADPT_FLAG(0, MSIX_EN);
+		kfree(adpt->msix_entries);
+		adpt->msix_entries = NULL;
+		goto try_msi_mode;
+	}
+
+	DRV_PRINT(INTR, INFO, "enable MSI-X interrupts, num_msix_intrs = %d\n",
+			msix_intrs);
+	SET_ADPT_FLAG(0, MSIX_EN);
+	if (CHK_ADPT_FLAG(0, SRSS_CAP))
+		SET_ADPT_FLAG(0, SRSS_EN);
+
+	adpt->num_msix_intrs = min(msix_intrs, adpt->max_msix_intrs);
+	retval = 0;
+	return retval;
+
+try_msi_mode:
+	CLI_ADPT_FLAG(0, SRSS_CAP);
+	CLI_ADPT_FLAG(0, SRSS_EN);
+	alx_set_num_queues(adpt);
+	retval = -1;
+	return retval;
+}
+
+/* set msi interrupt mode */
+static int alx_set_msi_interrupt_mode(struct alx_adapter *adpt)
+{
+	int retval;
+
+	retval = pci_enable_msi(adpt->pdev);
+	if (retval) {
+		DRV_PRINT(INTR, INFO, "can't enable MSI interrupt. "
+				"retval: %d\n", retval);
+		return retval;
+	}
+	SET_ADPT_FLAG(0, MSI_EN);
+	return retval;
+}
+
+/* set interrupt mode */
+static int alx_set_interrupt_mode(struct alx_adapter *adpt)
+{
+	int retval = 0;
+
+	if (CHK_ADPT_FLAG(0, MSIX_CAP)) {
+		DRV_PRINT(INTR, INFO, "Try to set MSIX interrupt.\n");
+		retval = alx_set_msix_interrupt_mode(adpt);
+		if (!retval)
+			return retval;
+	}
+
+	if (CHK_ADPT_FLAG(0, MSI_CAP)) {
+		DRV_PRINT(INTR, INFO, "Try to set MSI interrupt.\n");
+		retval = alx_set_msi_interrupt_mode(adpt);
+		if (!retval)
+			return retval;
+	}
+
+	DRV_PRINT(INTR, INFO, "can't enable MSIX and MSI interrupt. "
+			"And enable Legacy interrupt.\n");
+	retval = 0;
+	return retval;
+}
+
+
+static void alx_reset_interrupt_mode(struct alx_adapter *adpt)
+{
+	if (CHK_ADPT_FLAG(0, MSIX_EN)) {
+		CLI_ADPT_FLAG(0, MSIX_EN);
+		pci_disable_msix(adpt->pdev);
+		kfree(adpt->msix_entries);
+		adpt->msix_entries = NULL;
+	} else if (CHK_ADPT_FLAG(0, MSI_EN)) {
+		CLI_ADPT_FLAG(0, MSI_EN);
+		pci_disable_msi(adpt->pdev);
+	}
+}
+
+
+static int __devinit alx_init_adapter_special(struct alx_adapter *adpt)
+{
+	switch (adpt->hw.mac_type) {
+	case alx_mac_l1f:
+		goto init_alf_adapter;
+		break;
+	case alx_mac_l1c:
+	case alx_mac_l1d_v1:
+	case alx_mac_l1d_v2:
+	case alx_mac_l2c:
+	case alx_mac_l2cb_v1:
+	case alx_mac_l2cb_v20:
+	case alx_mac_l2cb_v21:
+		goto init_alc_adapter;
+		break;
+	default:
+		break;
+	}
+	return -1;
+
+init_alc_adapter:
+	if (CHK_ADPT_FLAG(0, MSIX_CAP))
+		DRV_PRINT(INIT, ERR, "ALC doesn't support MSIX.\n");
+
+	/* msi for tx, rx and none queues */
+	adpt->num_msix_txques = 0;
+	adpt->num_msix_rxques = 0;
+	adpt->num_msix_noques = 0;
+	return 0;
+
+init_alf_adapter:
+	if (CHK_ADPT_FLAG(0, MSIX_CAP)) {
+		/* msix for tx, rx and none queues */
+		adpt->num_msix_txques = 4;
+		adpt->num_msix_rxques = 8;
+		adpt->num_msix_noques = ALF_MAX_MSIX_NOQUE_INTRS;
+
+		/* msix vector range */
+		adpt->max_msix_intrs = ALF_MAX_MSIX_INTRS;
+		adpt->min_msix_intrs = ALF_MIN_MSIX_INTRS;
+	} else {
+		/* msi for tx, rx and none queues */
+		adpt->num_msix_txques = 0;
+		adpt->num_msix_rxques = 0;
+		adpt->num_msix_noques = 0;
+	}
+	return 0;
+
+}
+/*
+ * alx_init_adapter
+ */
+static int __devinit alx_init_adapter(struct alx_adapter *adpt)
+{
+	struct alx_hw *hw   = &adpt->hw;
+	struct pci_dev	*pdev = adpt->pdev;
+	u32 revision;
+	int max_frame;
+
+	/* PCI config space info */
+
+	hw->pci_venid = pdev->vendor;
+	hw->pci_devid = pdev->device;
+	MEM_R32(hw, PCI_CLASS_REVISION, &revision);
+	hw->pci_revid = revision & 0xFF;
+	hw->pci_sub_venid = pdev->subsystem_vendor;
+	hw->pci_sub_devid = pdev->subsystem_device;
+
+
+	if (alx_init_hw_callbacks(adpt) != 0) {
+		DRV_PRINT(INIT, ERR, "set hw function pointers failed\n");
+		return -1;
+	}
+
+	if (hw->cbs.identify_nic(hw) != 0) {
+		DRV_PRINT(INIT, ERR, "hw is disabled\n");
+		return -1;
+	}
+
+	/* Set adapter flags */
+	switch (hw->mac_type) {
+	case alx_mac_l1f:
+#ifdef CONFIG_ALX_MSI
+		SET_ADPT_FLAG(0, MSI_CAP);
+#endif
+#ifdef CONFIG_ALX_MSIX
+		SET_ADPT_FLAG(0, MSIX_CAP);
+#endif
+		if (CHK_ADPT_FLAG(0, MSIX_CAP)) {
+			SET_ADPT_FLAG(0, FIXED_MSIX);
+			SET_ADPT_FLAG(0, MRQ_CAP);
+#ifdef CONFIG_ALX_RSS
+			SET_ADPT_FLAG(0, SRSS_CAP);
+#endif
+		}
+		pdev->dev_flags |= PCI_DEV_FLAGS_MSI_INTX_DISABLE_BUG;
+		break;
+	case alx_mac_l1c:
+	case alx_mac_l1d_v1:
+	case alx_mac_l1d_v2:
+	case alx_mac_l2c:
+	case alx_mac_l2cb_v1:
+	case alx_mac_l2cb_v20:
+	case alx_mac_l2cb_v21:
+#ifdef CONFIG_ALX_MSI
+		SET_ADPT_FLAG(0, MSI_CAP);
+#endif
+		break;
+	default:
+		break;
+	}
+
+	/* set default for alx_adapter */
+	adpt->max_msix_intrs = 1;
+	adpt->min_msix_intrs = 1;
+	max_frame = adpt->netdev->mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN;
+	adpt->rxbuf_size = adpt->netdev->mtu > ALX_DEF_RX_BUF_SIZE ?
+			ALIGN(max_frame, 8) : ALX_DEF_RX_BUF_SIZE;
+
+	/* set default for alx_hw */
+	hw->link_up = false;
+	hw->link_speed = ALX_LINK_SPEED_UNKNOWN;
+	hw->preamble = 7;
+	hw->intr_mask = ALX_IMR_NORMAL_MASK;
+	hw->smb_timer = 400; /* 400ms */
+	hw->mtu = adpt->netdev->mtu;
+
+	/* set default for wrr */
+	hw->wrr_prio0 = 4;
+	hw->wrr_prio1 = 4;
+	hw->wrr_prio2 = 4;
+	hw->wrr_prio3 = 4;
+	hw->wrr_mode = alx_wrr_mode_none;
+
+	/* set default flow control settings */
+	hw->req_fc_mode = alx_fc_full;
+	hw->cur_fc_mode = alx_fc_full;	/* init for ethtool output */
+	hw->disable_fc_autoneg = false;
+	hw->fc_was_autonegged = false;
+	hw->fc_single_pause = true;
+
+	/* set default for rss info*/
+	hw->rss_hstype = 0;
+	hw->rss_mode = alx_rss_mode_disable;
+	hw->rss_idt_size = 0;
+	hw->rss_base_cpu = 0;
+	memset(hw->rss_idt, 0x0, sizeof(hw->rss_idt));
+	memset(hw->rss_key, 0x0, sizeof(hw->rss_key));
+
+	atomic_set(&adpt->irq_sem, 1);
+	spin_lock_init(&adpt->tx_lock);
+	spin_lock_init(&adpt->rx_lock);
+
+	alx_init_adapter_special(adpt);
+
+	if (hw->cbs.init_phy) {
+		if (hw->cbs.init_phy(hw))
+			return -1;
+	}
+
+	set_bit(__ALX_DOWN, &adpt->alx_state);
+	return 0;
+}
+
+
+static int  alx_set_register_info_special(struct alx_adapter *adpt)
+{
+	struct alx_hw *hw = &adpt->hw;
+	int num_txques = adpt->num_txques;
+
+	switch (adpt->hw.mac_type) {
+	case alx_mac_l1f:
+		goto cache_alf_register;
+		break;
+	case alx_mac_l1c:
+	case alx_mac_l1d_v1:
+	case alx_mac_l1d_v2:
+	case alx_mac_l2c:
+	case alx_mac_l2cb_v1:
+	case alx_mac_l2cb_v20:
+	case alx_mac_l2cb_v21:
+		goto cache_alc_register;
+		break;
+	default:
+		break;
+	}
+	return -1;
+
+cache_alc_register:
+	/* setting for Produce Index and Consume Index */
+	adpt->rx_queue[0]->produce_reg = hw->rx_prod_reg[0];
+	adpt->rx_queue[0]->consume_reg = hw->rx_cons_reg[0];
+
+	switch (num_txques) {
+	case 2:
+		adpt->tx_queue[1]->produce_reg = hw->tx_prod_reg[1];
+		adpt->tx_queue[1]->consume_reg = hw->tx_cons_reg[1];
+	case 1:
+		adpt->tx_queue[0]->produce_reg = hw->tx_prod_reg[0];
+		adpt->tx_queue[0]->consume_reg = hw->tx_cons_reg[0];
+		break;
+	}
+	return 0;
+
+cache_alf_register:
+	/* setting for Produce Index and Consume Index */
+	adpt->rx_queue[0]->produce_reg = hw->rx_prod_reg[0];
+	adpt->rx_queue[0]->consume_reg = hw->rx_cons_reg[0];
+
+	switch (num_txques) {
+	case 4:
+		adpt->tx_queue[3]->produce_reg = hw->tx_prod_reg[3];
+		adpt->tx_queue[3]->consume_reg = hw->tx_cons_reg[3];
+	case 3:
+		adpt->tx_queue[2]->produce_reg = hw->tx_prod_reg[2];
+		adpt->tx_queue[2]->consume_reg = hw->tx_cons_reg[2];
+	case 2:
+		adpt->tx_queue[1]->produce_reg = hw->tx_prod_reg[1];
+		adpt->tx_queue[1]->consume_reg = hw->tx_cons_reg[1];
+	case 1:
+		adpt->tx_queue[0]->produce_reg = hw->tx_prod_reg[0];
+		adpt->tx_queue[0]->consume_reg = hw->tx_cons_reg[0];
+	}
+	return 0;
+}
+
+
+/* alx_alloc_tx_descriptor - allocate Tx Descriptors */
+static int alx_alloc_tx_descriptor(struct alx_adapter *adpt,
+				   struct alx_tx_queue *txque)
+{
+	struct alx_ring_header *ring_header = &adpt->ring_header;
+	int size;
+
+	DRV_PRINT(IF, INFO, "tpq.count = %d\n", txque->tpq.count);
+
+	size = sizeof(struct alx_buffer) * txque->tpq.count;
+	txque->tpq.tpbuff = kzalloc(size, GFP_KERNEL);
+	if (!txque->tpq.tpbuff)
+		goto err_alloc_tpq_buffer;
+	memset(txque->tpq.tpbuff, 0, size);
+
+	/* round up to nearest 4K */
+	txque->tpq.size = txque->tpq.count * sizeof(struct alx_tpdesc);
+
+	txque->tpq.tpdma = ring_header->dma + ring_header->used;
+	txque->tpq.tpdesc = ring_header->desc + ring_header->used;
+	adpt->hw.tpdma[txque->que_idx] = (u64)txque->tpq.tpdma;
+	ring_header->used += ALIGN(txque->tpq.size, 8);
+
+	txque->tpq.produce_idx = 0;
+	txque->tpq.consume_idx = 0;
+	txque->max_packets = txque->tpq.count;
+	return 0;
+
+err_alloc_tpq_buffer:
+	kfree(txque->tpq.tpbuff);
+	txque->tpq.tpbuff = NULL;
+	DRV_PRINT(IF, ERR, "Unable to allocate memory "
+		"for the Tx descriptor.\n");
+	return -ENOMEM;
+}
+
+/* alx_alloc_all_tx_descriptor - allocate all Tx Descriptors */
+static int alx_alloc_all_tx_descriptor(struct alx_adapter *adpt)
+{
+	int i, retval = 0;
+	DRV_PRINT(IF, INFO, "num_tques = %d\n", adpt->num_txques);
+
+	for (i = 0; i < adpt->num_txques; i++) {
+		retval = alx_alloc_tx_descriptor(adpt, adpt->tx_queue[i]);
+		if (!retval)
+			continue;
+
+		DRV_PRINT(IF, ERR, "Allocation for Tx Queue %u failed\n", i);
+		break;
+	}
+
+	return retval;
+}
+
+/* alx_alloc_rx_descriptor - allocate Rx Descriptors */
+static int alx_alloc_rx_descriptor(struct alx_adapter *adpt,
+				   struct alx_rx_queue *rxque)
+{
+	struct alx_ring_header *ring_header = &adpt->ring_header;
+	int size;
+
+	DRV_PRINT(IF, INFO, "RRD.count = %d, RFD.count = %d, "
+			"SWD.count = %d.\n",
+			rxque->rrq.count,
+			rxque->rfq.count,
+			rxque->swq.count);
+
+	if (CHK_RX_FLAG(HW_QUE)) {
+		/* alloc buffer info */
+		size = sizeof(struct alx_buffer) * rxque->rfq.count;
+		rxque->rfq.rfbuff = kzalloc(size, GFP_KERNEL);
+		if (!rxque->rfq.rfbuff)
+			goto err_alloc_rfq_buffer;
+		memset(rxque->rfq.rfbuff, 0, size);
+
+		/*
+		 * set dma's point of rrq and rfq
+		 */
+
+		/* Round up to nearest 4K */
+		rxque->rrq.size =
+			rxque->rrq.count * sizeof(struct alx_rrdesc);
+		rxque->rfq.size =
+			rxque->rfq.count * sizeof(struct alx_rfdesc);
+
+		rxque->rrq.rrdma = ring_header->dma + ring_header->used;
+		rxque->rrq.rrdesc = ring_header->desc + ring_header->used;
+		adpt->hw.rrdma[rxque->que_idx] = (u64)rxque->rrq.rrdma;
+		ring_header->used += ALIGN(rxque->rrq.size, 8);
+
+		rxque->rfq.rfdma = ring_header->dma + ring_header->used;
+		rxque->rfq.rfdesc = ring_header->desc + ring_header->used;
+		adpt->hw.rfdma[rxque->que_idx] = (u64)rxque->rfq.rfdma;
+		ring_header->used += ALIGN(rxque->rfq.size, 8);
+
+		/* clean all counts within rxque */
+		rxque->rrq.produce_idx = 0;
+		rxque->rrq.consume_idx = 0;
+
+		rxque->rfq.produce_idx = 0;
+		rxque->rfq.consume_idx = 0;
+	}
+
+	if (CHK_RX_FLAG(SW_QUE)) {
+		size = sizeof(struct alx_sw_buffer) * rxque->swq.count;
+		rxque->swq.swbuff = kzalloc(size, GFP_KERNEL);
+		if (!rxque->swq.swbuff)
+			goto err_alloc_swq_buffer;
+		memset(rxque->swq.swbuff, 0, size);
+
+		rxque->swq.consume_idx = 0;
+		rxque->swq.produce_idx = 0;
+	}
+
+	rxque->max_packets = rxque->rrq.count / 2;
+	return 0;
+
+err_alloc_swq_buffer:
+	kfree(rxque->swq.swbuff);
+	rxque->swq.swbuff = NULL;
+err_alloc_rfq_buffer:
+	kfree(rxque->rfq.rfbuff);
+	rxque->rfq.rfbuff = NULL;
+	DRV_PRINT(IF, ERR, "Unable to allocate memory "
+		"for the Rx descriptor\n");
+	return -ENOMEM;
+}
+
+/* alx_alloc_all_rx_descriptor - allocate all Rx Descriptors */
+static int alx_alloc_all_rx_descriptor(struct alx_adapter *adpt)
+{
+	int i, error = 0;
+
+	for (i = 0; i < adpt->num_rxques; i++) {
+		error = alx_alloc_rx_descriptor(adpt, adpt->rx_queue[i]);
+		if (!error)
+			continue;
+		DRV_PRINT(IF, ERR, "Allocation for Rx Queue %u failed\n", i);
+		break;
+	}
+
+	return error;
+}
+
+/* alx_free_tx_descriptor - Free Tx Descriptor */
+static void alx_free_tx_descriptor(struct alx_tx_queue *txque)
+{
+	alx_clean_tx_queue(txque);
+
+	kfree(txque->tpq.tpbuff);
+	txque->tpq.tpbuff = NULL;
+
+	/* if not set, then don't free */
+	if (!txque->tpq.tpdesc)
+		return;
+	txque->tpq.tpdesc = NULL;
+}
+
+/* alx_free_all_tx_descriptor - Free all Tx Descriptor */
+static void alx_free_all_tx_descriptor(struct alx_adapter *adpt)
+{
+	int i;
+
+	for (i = 0; i < adpt->num_txques; i++)
+		alx_free_tx_descriptor(adpt->tx_queue[i]);
+}
+
+/* alx_free_all_rx_descriptor - Free all Rx Descriptor */
+static void alx_free_rx_descriptor(struct alx_rx_queue *rxque)
+{
+	alx_clean_rx_queue(rxque);
+
+	if (CHK_RX_FLAG(HW_QUE)) {
+		kfree(rxque->rfq.rfbuff);
+		rxque->rfq.rfbuff = NULL;
+
+		/* if not set, then don't free */
+		if (!rxque->rrq.rrdesc)
+			return;
+		rxque->rrq.rrdesc = NULL;
+
+		if (!rxque->rfq.rfdesc)
+			return;
+		rxque->rfq.rfdesc = NULL;
+	}
+
+	if (CHK_RX_FLAG(SW_QUE)) {
+		kfree(rxque->swq.swbuff);
+		rxque->swq.swbuff = NULL;
+	}
+}
+
+/* alx_free_all_rx_descriptor - Free all Rx Descriptor */
+static void alx_free_all_rx_descriptor(struct alx_adapter *adpt)
+{
+	int i;
+	for (i = 0; i < adpt->num_rxques; i++)
+		alx_free_rx_descriptor(adpt->rx_queue[i]);
+}
+
+/*
+ * alx_alloc_all_rtx_descriptor - allocate Tx / RX descriptor queues
+ * @adpt: board private structure
+ */
+static int alx_alloc_all_rtx_descriptor(struct alx_adapter *adpt)
+{
+	struct pci_dev *pdev = adpt->pdev;
+	struct alx_ring_header *ring_header = &adpt->ring_header;
+	int num_tques = adpt->num_txques;
+	int num_rques = adpt->num_hw_rxques;
+	unsigned int num_tx_descs = adpt->num_txdescs;
+	unsigned int num_rx_descs = adpt->num_rxdescs;
+	int retval;
+
+	/*
+	 * real ring DMA buffer
+	 * each ring/block may need up to 8 bytes for alignment, hence the
+	 * additional bytes tacked onto the end.
+	 */
+	ring_header->size =
+		num_tques * num_tx_descs * sizeof(struct alx_tpdesc) +
+		num_rques * num_rx_descs * sizeof(struct alx_rfdesc) +
+		num_rques * num_rx_descs * sizeof(struct alx_rrdesc) +
+		sizeof(struct coals_msg_block) +
+		sizeof(struct alx_hw_stats) +
+		num_tques * 8 + num_rques * 2 * 8 + 8 * 2;
+	DRV_PRINT(IF, INFO, "num_tques = %d, num_tx_descs = %d.\n",
+			num_tques, num_tx_descs);
+	DRV_PRINT(IF, INFO, "num_rques = %d, num_rx_descs = %d.\n",
+			num_rques, num_rx_descs);
+
+	ring_header->used = 0;
+	ring_header->desc = pci_alloc_consistent(pdev, ring_header->size,
+				&ring_header->dma);
+
+	if (!ring_header->desc) {
+		DRV_PRINT(IF, ERR, "pci_alloc_consistend failed\n");
+		retval = -ENOMEM;
+		goto err_alloc_dma;
+	}
+	memset(ring_header->desc, 0, ring_header->size);
+	ring_header->used = ALIGN(ring_header->dma, 8) - ring_header->dma;
+
+	DRV_PRINT(IF, INFO, "Ring Header: size = %d, used= %d.\n",
+		ring_header->size, ring_header->used);
+
+	/* allocate receive descriptors */
+	retval = alx_alloc_all_tx_descriptor(adpt);
+	if (retval)
+		goto err_alloc_tx;
+
+	/* allocate receive descriptors */
+	retval = alx_alloc_all_rx_descriptor(adpt);
+	if (retval)
+		goto err_alloc_rx;
+
+	/* Init CMB dma address */
+	adpt->cmb.dma = ring_header->dma + ring_header->used;
+	adpt->cmb.cmb = (u8 *) ring_header->desc + ring_header->used;
+	ring_header->used += ALIGN(sizeof(struct coals_msg_block), 8);
+
+	adpt->smb.dma = ring_header->dma + ring_header->used;
+	adpt->smb.smb = (u8 *)ring_header->desc + ring_header->used;
+	ring_header->used += ALIGN(sizeof(struct alx_hw_stats), 8);
+
+	return 0;
+
+err_alloc_rx:
+	alx_free_all_rx_descriptor(adpt);
+err_alloc_tx:
+	alx_free_all_tx_descriptor(adpt);
+err_alloc_dma:
+	return retval;
+}
+
+
+/*
+ * alx_alloc_all_rtx_descriptor - allocate Tx / RX descriptor queues
+ * @adpt: board private structure
+ */
+static void alx_free_all_rtx_descriptor(struct alx_adapter *adpt)
+{
+	struct pci_dev *pdev = adpt->pdev;
+	struct alx_ring_header *ring_header = &adpt->ring_header;
+
+	alx_free_all_tx_descriptor(adpt);
+	alx_free_all_rx_descriptor(adpt);
+
+	adpt->cmb.dma = 0;
+	adpt->cmb.cmb = NULL;
+	adpt->smb.dma = 0;
+	adpt->smb.smb = NULL;
+
+	pci_free_consistent(pdev, ring_header->size, ring_header->desc,
+					ring_header->dma);
+	ring_header->desc = NULL;
+	ring_header->size = ring_header->used = 0;
+}
+
+
+/*
+ * alx_change_mtu - Change the Maximum Transfer Unit
+ * @netdev: network interface device structure
+ * @new_mtu: new value for maximum frame size
+ */
+static int alx_change_mtu(struct net_device *netdev, int new_mtu)
+{
+	struct alx_adapter *adpt = netdev_priv(netdev);
+	int old_mtu   = netdev->mtu;
+	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN;
+	struct pci_dev *pdev = adpt->pdev;
+
+	DRV_PRINT(FUNC, DEBUG, "ENTER\n");
+
+	if ((max_frame < ALX_MIN_ETH_FRAME_SIZE) ||
+	    (max_frame > ALX_MAX_ETH_FRAME_SIZE)) {
+		dev_warn(&pdev->dev, "invalid MTU setting\n");
+		return -EINVAL;
+	}
+	/* set MTU */
+	if (old_mtu != new_mtu && netif_running(netdev)) {
+
+		DRV_PRINT(IF, INFO, "changing MTU from %d to %d\n",
+				netdev->mtu, new_mtu);
+		netdev->mtu = new_mtu;
+		adpt->hw.mtu = new_mtu;
+		adpt->rxbuf_size = new_mtu > ALX_DEF_RX_BUF_SIZE ?
+			ALIGN(max_frame, 8) : ALX_DEF_RX_BUF_SIZE;
+		if (new_mtu > ALX_MAX_TSO_PKT_SIZE) {
+			adpt->netdev->features &= ~NETIF_F_TSO;
+			adpt->netdev->features &= ~NETIF_F_TSO6;
+		} else {
+			adpt->netdev->features |= NETIF_F_TSO;
+			adpt->netdev->features |= NETIF_F_TSO6;
+		}
+
+		alx_reinit_locked(adpt);
+	}
+
+	return 0;
+}
+
+
+int alx_open_internal(struct alx_adapter *adpt, u32 ctrl)
+{
+	struct alx_hw *hw = &adpt->hw;
+	int retval = 0;
+	int i;
+
+	alx_init_ring_ptrs(adpt);
+
+	alx_set_multicase_list(adpt->netdev);
+	alx_restore_vlan(adpt);
+
+	if (hw->cbs.start_mac)
+		retval = hw->cbs.start_mac(hw);
+
+	if (hw->cbs.config_mac)
+		retval = hw->cbs.config_mac(hw, adpt->rxbuf_size,
+				adpt->num_hw_rxques, adpt->num_rxdescs,
+				adpt->num_txques, adpt->num_txdescs);
+
+	if (hw->cbs.config_tx)
+		retval = hw->cbs.config_tx(hw);
+
+	if (hw->cbs.config_rx)
+		retval = hw->cbs.config_rx(hw);
+
+	alx_config_rss(adpt);
+
+	for (i = 0; i < adpt->num_hw_rxques; i++)
+		alx_refresh_rx_buffer(adpt->rx_queue[i]);
+
+	/* configure HW regsiters of MSIX */
+	if (hw->cbs.config_msix)
+		retval = hw->cbs.config_msix(hw, adpt->num_msix_intrs,
+					CHK_ADPT_FLAG(0, MSIX_EN),
+					CHK_ADPT_FLAG(0, MSI_EN));
+
+	if (ctrl & ALX_OPEN_CTRL_IRQ_EN) {
+		retval = alx_request_irq(adpt);
+		if (retval)
+			goto err_request_irq;
+	}
+
+	/* enable NAPI, INTR and TX */
+	alx_napi_enable_all(adpt);
+
+	alx_enable_intr(adpt);
+
+	netif_tx_start_all_queues(adpt->netdev);
+
+	clear_bit(__ALX_DOWN, &adpt->alx_state);
+
+	/* check link status */
+	SET_ADPT_FLAG(1, LSC_REQUESTED);
+	adpt->link_jiffies = jiffies + ALX_TRY_LINK_TIMEOUT;
+	mod_timer(&adpt->alx_timer, jiffies);
+
+	return retval;
+
+err_request_irq:
+	alx_clean_all_rx_queues(adpt);
+	return retval;
+}
+
+
+void alx_stop_internal(struct alx_adapter *adpt, u32 ctrl)
+{
+	struct net_device *netdev = adpt->netdev;
+	struct alx_hw *hw = &adpt->hw;
+
+	set_bit(__ALX_DOWN, &adpt->alx_state);
+
+	netif_tx_stop_all_queues(netdev);
+	/* call carrier off first to avoid false dev_watchdog timeouts */
+	netif_carrier_off(netdev);
+	netif_tx_disable(netdev);
+
+	alx_disable_intr(adpt);
+
+	alx_napi_disable_all(adpt);
+
+	if (ctrl & ALX_OPEN_CTRL_IRQ_EN)
+		alx_free_irq(adpt);
+
+	CLI_ADPT_FLAG(1, LSC_REQUESTED);
+	CLI_ADPT_FLAG(1, RESET_REQUESTED);
+	CLI_ADPT_FLAG(1, DBG_REQUESTED);
+	del_timer_sync(&adpt->alx_timer);
+
+	/* reset MAC to disable all RX/TX */
+	if (ctrl & ALX_OPEN_CTRL_MAC_EN) {
+		if (hw->cbs.reset_mac)
+			hw->cbs.reset_mac(hw);
+	}
+	adpt->hw.link_speed = ALX_LINK_SPEED_UNKNOWN;
+
+	alx_clean_all_tx_queues(adpt);
+	alx_clean_all_rx_queues(adpt);
+}
+
+
+/*
+ * alx_open - Called when a network interface is made active
+ * @netdev: network interface device structure
+ */
+static int alx_open(struct net_device *netdev)
+{
+	struct alx_adapter *adpt = netdev_priv(netdev);
+	struct alx_hw *hw = &adpt->hw;
+	int retval;
+
+	DRV_PRINT(FUNC, DEBUG, "ENTER\n");
+
+	/* disallow open during test */
+	if (test_bit(__ALX_TESTING, &adpt->alx_state))
+		return -EBUSY;
+
+	netif_carrier_off(netdev);
+
+	/* allocate rx/tx dma buffer & descriptors */
+	retval = alx_alloc_all_rtx_descriptor(adpt);
+	if (retval) {
+		DRV_PRINT(IF, ERR, "error in alx_alloc_all_rtx_descriptor.\n");
+		goto err_alloc_rtx;
+	}
+
+	retval = alx_open_internal(adpt, ALX_OPEN_CTRL_IRQ_EN);
+	if (retval)
+		goto err_open_internal;
+
+	return retval;
+
+err_open_internal:
+	alx_stop_internal(adpt, ALX_OPEN_CTRL_IRQ_EN);
+err_alloc_rtx:
+	alx_free_all_rtx_descriptor(adpt);
+	hw->cbs.reset_mac(hw);
+	return retval;
+}
+
+/*
+ * alx_stop - Disables a network interface
+ * @netdev: network interface device structure
+ */
+static int alx_stop(struct net_device *netdev)
+{
+	struct alx_adapter *adpt = netdev_priv(netdev);
+
+	DRV_PRINT(FUNC, DEBUG, "ENTER\n");
+
+	WARN_ON(test_bit(__ALX_RESETTING, &adpt->alx_state));
+	alx_stop_internal(adpt, (ALX_OPEN_CTRL_IRQ_EN |
+			ALX_OPEN_CTRL_MAC_EN));
+	alx_free_all_rtx_descriptor(adpt);
+
+	return 0;
+}
+
+#ifdef CONFIG_PM
+int alx_resume(struct pci_dev *pdev)
+{
+	struct alx_adapter *adpt = pci_get_drvdata(pdev);
+	struct net_device *netdev = adpt->netdev;
+	struct alx_hw *hw = &adpt->hw;
+	u32 retval;
+
+	pci_set_power_state(pdev, PCI_D0);
+	pci_restore_state(pdev);
+	/*
+	 * pci_restore_state clears dev->state_saved so call
+	 * pci_save_state to restore it.
+	 */
+	pci_save_state(pdev);
+
+	pci_enable_wake(pdev, PCI_D3hot, 0);
+	pci_enable_wake(pdev, PCI_D3cold, 0);
+
+	retval = hw->cbs.reset_pcie(hw, true, true);
+	retval = hw->cbs.reset_phy(hw);
+	retval = hw->cbs.reset_mac(hw);
+	retval = hw->cbs.setup_phy_link(hw, hw->autoneg_advertised, true,
+			!hw->disable_fc_autoneg);
+
+	retval = hw->cbs.config_wol(hw, 0);
+
+	if (netif_running(netdev)) {
+		retval = alx_open_internal(adpt, 0);
+		if (retval)
+			return retval;
+	}
+
+	netif_device_attach(netdev);
+	return 0;
+}
+#endif
+
+/*
+ * alx_shutdown_internal is not used when power management
+ * is disabled on older kernels (<2.6.12). causes a compile
+ * warning/error, because it is defined and not used.
+ */
+int alx_shutdown_internal(struct pci_dev *pdev, pm_message_t state)
+{
+	struct alx_adapter *adpt = pci_get_drvdata(pdev);
+	struct net_device *netdev = adpt->netdev;
+	struct alx_hw *hw = &adpt->hw;
+	u32 wufc = adpt->wol;
+	u16 lpa;
+	u32 speed, adv_speed, misc;
+	bool link_up;
+	int i;
+#ifdef CONFIG_PM
+	int retval = 0;
+#endif
+
+	hw->cbs.config_aspm(hw, false, false);
+
+	netif_device_detach(netdev);
+	if (netif_running(netdev)) {
+		alx_stop_internal(adpt, 0);
+		alx_free_irq(adpt);
+		/* alx_free_all_rtx_descriptor(adpt); */
+	}
+	/* alx_clear_intr_scheme(adpt); */
+#ifdef CONFIG_PM
+	retval = pci_save_state(pdev);
+	if (retval)
+		return retval;
+#endif
+	hw->cbs.check_phy_link(hw, &speed, &link_up);
+
+	if (link_up) {
+		if (hw->mac_type == alx_mac_l1f) {
+			MEM_R32(hw, ALX_MISC, &misc);
+			misc |= ALX_MISC_INTNLOSC_OPEN;
+			MEM_W32(hw, ALX_MISC, misc);
+		}
+
+		retval = hw->cbs.read_phy_reg(hw, ALX_MDIO_NORM_DEV,
+				MII_LPA, &lpa);
+		if (retval)
+			return retval;
+
+		adv_speed = ALX_LINK_SPEED_10_HALF;
+		if (lpa & LPA_10FULL)
+			adv_speed = ALX_LINK_SPEED_10_FULL;
+		else if (lpa & LPA_10HALF)
+			adv_speed = ALX_LINK_SPEED_10_HALF;
+		else if (lpa & LPA_100FULL)
+			adv_speed = ALX_LINK_SPEED_100_FULL;
+		else if (lpa & LPA_100HALF)
+			adv_speed = ALX_LINK_SPEED_100_HALF;
+
+		retval = hw->cbs.setup_phy_link(hw, adv_speed, true,
+				!hw->disable_fc_autoneg);
+		if (retval)
+			return retval;
+
+		for (i = 0; i < ALX_MAX_SETUP_LNK_CYCLE; i++) {
+			__MS_DELAY(100);
+			retval = hw->cbs.check_phy_link(hw, &speed, &link_up);
+			if (retval)
+				continue;
+			if (link_up)
+				break;
+		}
+	} else {
+		speed = ALX_LINK_SPEED_10_HALF;
+		link_up = false;
+	}
+	hw->link_speed = speed;
+	hw->link_up = link_up;
+
+	retval = hw->cbs.config_wol(hw, wufc);
+	if (retval)
+		return retval;
+
+	/* clear phy interrupt */
+	retval = hw->cbs.ack_phy_intr(hw);
+	if (retval)
+		return retval;
+
+	if (wufc) {
+		/* pcie patch */
+		device_set_wakeup_enable(&pdev->dev, 1);
+	}
+
+	retval = hw->cbs.config_pow_save(hw, adpt->hw.link_speed,
+			(wufc ? true : false), false,
+			(wufc & ALX_WOL_MAGIC ? true : false), true);
+	if (retval)
+		return retval;
+	pci_enable_wake(pdev, pci_choose_state(pdev, state), (wufc ? 1 : 0));
+	pci_disable_device(pdev);
+	pci_set_power_state(pdev, pci_choose_state(pdev, state));
+
+	return 0;
+}
+
+#ifdef CONFIG_PM
+int alx_suspend(struct pci_dev *pdev, pm_message_t state)
+{
+	int retval;
+
+	retval = alx_shutdown_internal(pdev, state);
+	if (retval)
+		return retval;
+
+	return 0;
+}
+#endif
+
+void alx_shutdown(struct pci_dev *pdev)
+{
+	alx_shutdown_internal(pdev, PMSG_SUSPEND);
+}
+
+
+/**
+ * alx_update_hw_stats - Update the board statistics counters.
+ * @adpt: board private structure
+ **/
+static void alx_update_hw_stats(struct alx_adapter *adpt)
+{
+	struct net_device_stats *net_stats;
+	struct alx_hw *hw = &adpt->hw;
+	struct alx_hw_stats *hwstats = &adpt->hw_stats;
+	unsigned long *hwstat_item = NULL;
+	u32 hwstat_reg;
+	u32 hwstat_data;
+
+	if (test_bit(__ALX_DOWN, &adpt->alx_state) ||
+	    test_bit(__ALX_RESETTING, &adpt->alx_state))
+		return;
+
+	/* update RX status */
+	hwstat_reg  = hw->rxstat_reg;
+	hwstat_item = &hwstats->rx_ok;
+	while (hwstat_reg < hw->rxstat_reg + hw->rxstat_sz) {
+		MEM_R32(hw, hwstat_reg, &hwstat_data);
+		*hwstat_item += hwstat_data;
+		hwstat_reg += 4;
+		hwstat_item++;
+	}
+
+	/* update TX status */
+	hwstat_reg  = hw->txstat_reg;
+	hwstat_item = &hwstats->tx_ok;
+	while (hwstat_reg < hw->txstat_reg + hw->txstat_sz) {
+		MEM_R32(hw, hwstat_reg, &hwstat_data);
+		*hwstat_item += hwstat_data;
+		hwstat_reg += 4;
+		hwstat_item++;
+	}
+
+	net_stats = GET_NETDEV_STATS(adpt);
+	net_stats->rx_packets = hwstats->rx_ok;
+	net_stats->tx_packets = hwstats->tx_ok;
+	net_stats->rx_bytes   = hwstats->rx_byte_cnt;
+	net_stats->tx_bytes   = hwstats->tx_byte_cnt;
+	net_stats->multicast  = hwstats->rx_mcast;
+	net_stats->collisions = hwstats->tx_single_col +
+		hwstats->tx_multi_col * 2 +
+		hwstats->tx_late_col + hwstats->tx_abort_col;
+
+	net_stats->rx_errors  = hwstats->rx_frag + hwstats->rx_fcs_err +
+		hwstats->rx_len_err + hwstats->rx_ov_sz +
+		hwstats->rx_ov_rrd + hwstats->rx_align_err;
+
+	net_stats->rx_fifo_errors   = hwstats->rx_ov_rxf;
+	net_stats->rx_length_errors = hwstats->rx_len_err;
+	net_stats->rx_crc_errors    = hwstats->rx_fcs_err;
+	net_stats->rx_frame_errors  = hwstats->rx_align_err;
+	net_stats->rx_over_errors   = hwstats->rx_ov_rrd + hwstats->rx_ov_rxf;
+
+	net_stats->rx_missed_errors = hwstats->rx_ov_rrd + hwstats->rx_ov_rxf;
+
+	net_stats->tx_errors = hwstats->tx_late_col + hwstats->tx_abort_col +
+		hwstats->tx_underrun + hwstats->tx_trunc;
+	net_stats->tx_fifo_errors    = hwstats->tx_underrun;
+	net_stats->tx_aborted_errors = hwstats->tx_abort_col;
+	net_stats->tx_window_errors  = hwstats->tx_late_col;
+}
+
+
+/**
+ * alx_get_hw_stats - Get System Network Statistics
+ * @netdev: network interface device structure
+ *
+ * Returns the address of the device statistics structure.
+ * The statistics are actually updated from the timer callback.
+ **/
+static struct net_device_stats *alx_get_hw_stats(struct net_device *netdev)
+{
+	struct alx_adapter *adpt = netdev_priv(netdev);
+
+	DRV_PRINT(FUNC, DEBUG, "ENTER\n");
+
+	alx_update_hw_stats(adpt);
+	return GET_NETDEV_STATS(adpt);
+}
+
+
+static void alx_debug_task_routine(struct alx_adapter *adpt)
+{
+	if (!CHK_ADPT_FLAG(1, DBG_REQUESTED))
+		return;
+	CLI_ADPT_FLAG(1, DBG_REQUESTED);
+
+	/*debug code put here */
+}
+
+static void alx_link_task_routine(struct alx_adapter *adpt)
+{
+	struct net_device *netdev = adpt->netdev;
+	struct alx_hw *hw = &adpt->hw;
+	char *link_desc;
+
+	if (!CHK_ADPT_FLAG(1, LSC_REQUESTED))
+		return;
+	CLI_ADPT_FLAG(1, LSC_REQUESTED);
+
+	if (test_bit(__ALX_DOWN, &adpt->alx_state))
+		return;
+
+	if (hw->cbs.check_phy_link) {
+		hw->cbs.check_phy_link(hw,
+			&hw->link_speed, &hw->link_up);
+	} else {
+		/* always assume link is up, if no check link function */
+		hw->link_speed = ALX_LINK_SPEED_1GB_FULL;
+		hw->link_up = true;
+	}
+	DRV_PRINT(TIMER, INFO, "link_speed = %d, link_up = %d\n",
+		  hw->link_speed, hw->link_up);
+
+	if (!hw->link_up && time_after(adpt->link_jiffies, jiffies))
+		SET_ADPT_FLAG(1, LSC_REQUESTED);
+
+	if (hw->link_up) {
+		if (netif_carrier_ok(netdev))
+			return;
+
+		link_desc = (hw->link_speed == ALX_LINK_SPEED_1GB_FULL) ?
+			"1 Gbps Duplex Full" :
+			(hw->link_speed == ALX_LINK_SPEED_100_FULL ?
+			 "100 Mbps Duplex Full" :
+			 (hw->link_speed == ALX_LINK_SPEED_100_HALF ?
+			  "100 Mbps Duplex Half" :
+			  (hw->link_speed == ALX_LINK_SPEED_10_FULL ?
+			   "10 Mbps Duplex Full" :
+			   (hw->link_speed == ALX_LINK_SPEED_10_HALF ?
+			    "10 Mbps Duplex HALF" :
+			    "unknown speed"))));
+		DRV_PRINT(TIMER, INFO, "NIC Link is Up %s\n", link_desc);
+
+		hw->cbs.config_aspm(hw, true, true);
+		hw->cbs.start_mac(hw);
+		netif_carrier_on(netdev);
+		netif_tx_wake_all_queues(netdev);
+	} else {
+		/* only continue if link was up previously */
+		if (!netif_carrier_ok(netdev))
+			return;
+
+		hw->link_speed = 0;
+		DRV_PRINT(TIMER, INFO, "NIC Link is Down\n");
+		netif_carrier_off(netdev);
+		netif_tx_stop_all_queues(netdev);
+
+		hw->cbs.config_aspm(hw, false, true);
+		hw->cbs.stop_mac(hw);
+		hw->cbs.setup_phy_link(hw, hw->autoneg_advertised, true,
+				!hw->disable_fc_autoneg);
+	}
+}
+
+
+static void alx_reset_task_routine(struct alx_adapter *adpt)
+{
+	if (!CHK_ADPT_FLAG(1, RESET_REQUESTED))
+		return;
+	CLI_ADPT_FLAG(1, RESET_REQUESTED);
+
+	if (test_bit(__ALX_DOWN, &adpt->alx_state) ||
+	    test_bit(__ALX_RESETTING, &adpt->alx_state))
+		return;
+
+	alx_reinit_locked(adpt);
+}
+
+
+/**
+ * alx_timer_routine - Timer Call-back
+ * @data: pointer to adapter cast into an unsigned long
+ **/
+static void alx_timer_routine(unsigned long data)
+{
+	struct alx_adapter *adpt = (struct alx_adapter *)data;
+	unsigned long delay;
+
+	/* poll faster when waiting for link */
+	if (CHK_ADPT_FLAG(1, LSC_REQUESTED))
+		delay = HZ / 10;
+	else
+		delay = HZ * 2;
+
+	/* Reset the timer */
+	mod_timer(&adpt->alx_timer, delay + jiffies);
+
+	alx_task_schedule(adpt);
+}
+/**
+ * alx_task_routine - manages and runs subtasks
+ * @work: pointer to work_struct containing our data
+ **/
+static void alx_task_routine(struct work_struct *work)
+{
+	struct alx_adapter *adpt = container_of(work,
+				struct alx_adapter, alx_task);
+	/* test state of adapter */
+	BUG_ON(!test_bit(__ALX_SERVICE_SCHED, &adpt->alx_state));
+
+	/* reset task */
+	alx_reset_task_routine(adpt);
+
+	/* link task */
+	alx_link_task_routine(adpt);
+
+	/* debug task */
+	alx_debug_task_routine(adpt);
+
+	/* flush memory to make sure state is correct before next watchog */
+	smp_mb__before_clear_bit();
+
+	clear_bit(__ALX_SERVICE_SCHED, &adpt->alx_state);
+}
+
+
+/* Calculate the transmit packet descript needed*/
+static bool alx_check_num_tpdescs(struct alx_tx_queue *txque,
+				  const struct sk_buff *skb)
+{
+	u16 num_required = 1;
+	u16 num_available = 0;
+	u16 produce_idx = txque->tpq.produce_idx;
+	u16 consume_idx = txque->tpq.consume_idx;
+	int i = 0;
+
+	u16 proto_hdr_len = 0;
+	if (skb_is_gso(skb)) {
+		proto_hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
+		if (proto_hdr_len < skb_headlen(skb))
+			num_required++;
+		if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6)
+			num_required++;
+	}
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
+		num_required++;
+	num_available = (u16)(consume_idx > produce_idx) ?
+		(consume_idx - produce_idx - 1) :
+		(txque->tpq.count + consume_idx - produce_idx - 1);
+
+	return num_required < num_available;
+}
+
+
+static int alx_tso_csum(struct alx_adapter *adpt, struct alx_tx_queue *txque,
+			struct sk_buff *skb, struct alx_tpdesc *stpd)
+{
+	struct pci_dev *pdev = adpt->pdev;
+	u8 hdr_len;
+	u32 real_len;
+	int error;
+
+	if (skb_is_gso(skb)) {
+		if (skb_header_cloned(skb)) {
+			error = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
+			if (unlikely(error))
+				return -1;
+		}
+
+		if (skb->protocol == htons(ETH_P_IP)) {
+			real_len = (((unsigned char *)ip_hdr(skb) - skb->data)
+					+ ntohs(ip_hdr(skb)->tot_len));
+
+			if (real_len < skb->len)
+				pskb_trim(skb, real_len);
+
+			hdr_len = (skb_transport_offset(skb) + tcp_hdrlen(skb));
+			if (unlikely(skb->len == hdr_len)) {
+				/* only xsum need */
+				dev_warn(&pdev->dev,
+				      "IPV4 tso with zero data??\n");
+				goto check_sum;
+			} else {
+				ip_hdr(skb)->check = 0;
+				tcp_hdr(skb)->check = ~csum_tcpudp_magic(
+							ip_hdr(skb)->saddr,
+							ip_hdr(skb)->daddr,
+							0, IPPROTO_TCP, 0);
+				stpd->tp_gnr.ipv4 = 1;
+			}
+		}
+
+		if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6) {
+			struct alx_tpdesc etpd;
+			memset(&etpd, 0, sizeof(struct alx_tpdesc));
+			memset(stpd, 0, sizeof(struct alx_tpdesc));
+
+			ipv6_hdr(skb)->payload_len = 0;
+			/* check payload == 0 byte ? */
+			hdr_len = (skb_transport_offset(skb) + tcp_hdrlen(skb));
+			if (unlikely(skb->len == hdr_len)) {
+				/* only xsum need */
+				dev_warn(&pdev->dev,
+					"IPV6 tso with zero data??\n");
+				goto check_sum;
+			} else
+				tcp_hdr(skb)->check = ~csum_ipv6_magic(
+						&ipv6_hdr(skb)->saddr,
+						&ipv6_hdr(skb)->daddr,
+						0, IPPROTO_TCP, 0);
+			etpd.tp_tso.addr_lo = skb->len;
+			etpd.tp_tso.lso = 0x1;
+			etpd.tp_tso.lso_v2 = 0x1;
+			stpd->tp_tso.lso_v2 = 0x1;
+			alx_set_tpdesc(txque, &etpd);
+		}
+
+		stpd->tp_tso.lso = 0x1;
+		stpd->tp_tso.tcphdr_offset = skb_transport_offset(skb);
+		stpd->tp_tso.mss = skb_shinfo(skb)->gso_size;
+		return 0;
+	}
+
+check_sum:
+	if (likely(skb->ip_summed == CHECKSUM_PARTIAL)) {
+		u8 css, cso;
+		cso = skb_transport_offset(skb);
+
+		if (unlikely(cso & 0x1)) {
+			dev_err(&pdev->dev,
+			   "pay load offset should not ant event number\n");
+			return -1;
+		} else {
+			css = cso + skb->csum_offset;
+
+			stpd->tp_sum.payld_offset = cso >> 1;
+			stpd->tp_sum.cxsum_offset = css >> 1;
+			stpd->tp_sum.c_sum = 0x1;
+		}
+	}
+	return 0;
+}
+
+static void alx_tx_map(struct alx_adapter *adpt, struct sk_buff *skb,
+		       struct alx_tpdesc *stpd, struct alx_tx_queue *txque)
+{
+	struct alx_buffer *tpbuf = NULL;
+
+	unsigned int nr_frags = skb_shinfo(skb)->nr_frags;
+
+	unsigned int len = skb_headlen(skb);
+
+	u16 map_len = 0;
+	u16 mapped_len = 0;
+	u16 hdr_len = 0;
+	u16 f;
+	u32 tso = stpd->tp_tso.lso;
+
+	if (tso) {
+		/* TSO */
+		map_len = hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
+
+		tpbuf = GET_TP_BUFFER(txque, txque->tpq.produce_idx);
+		tpbuf->length = map_len;
+		tpbuf->dma = dma_map_single(txque->dev,
+					skb->data, hdr_len, DMA_TO_DEVICE);
+		mapped_len += map_len;
+		stpd->tp_gnr.addr = tpbuf->dma;
+		stpd->tp_gnr.buffer_len = tpbuf->length;
+
+		alx_set_tpdesc(txque, stpd);
+	}
+
+	if (mapped_len < len) {
+		tpbuf = GET_TP_BUFFER(txque, txque->tpq.produce_idx);
+		tpbuf->length = len - mapped_len;
+		tpbuf->dma =
+			dma_map_single(txque->dev, skb->data + mapped_len,
+					tpbuf->length, DMA_TO_DEVICE);
+		stpd->tp_gnr.addr = tpbuf->dma;
+		stpd->tp_gnr.buffer_len  = tpbuf->length;
+		alx_set_tpdesc(txque, stpd);
+	}
+
+	for (f = 0; f < nr_frags; f++) {
+		struct skb_frag_struct *frag;
+
+		frag = &skb_shinfo(skb)->frags[f];
+
+		tpbuf = GET_TP_BUFFER(txque, txque->tpq.produce_idx);
+		tpbuf->length = frag->size;
+		tpbuf->dma =
+			dma_map_page(txque->dev, frag->page,
+					frag->page_offset,
+					tpbuf->length,
+					DMA_TO_DEVICE);
+
+		stpd->tp_gnr.addr = tpbuf->dma;
+		stpd->tp_gnr.buffer_len  = tpbuf->length;
+
+		alx_set_tpdesc(txque, stpd);
+	}
+
+
+	/* The last tpd */
+	alx_set_tpdesc_lastfrag(txque);
+	/* The last buffer info contain the skb address,
+	   so it will be free after unmap */
+	tpbuf->skb = skb;
+}
+
+
+netdev_tx_t alx_start_xmit_frames(struct sk_buff *skb,
+				  struct alx_adapter *adpt,
+				  struct alx_tx_queue *txque)
+{
+	struct alx_hw *hw = &adpt->hw;
+	unsigned long flags = 0;
+	struct alx_tpdesc stpd; /* normal*/
+
+	if (test_bit(__ALX_DOWN, &adpt->alx_state)) {
+		dev_kfree_skb_any(skb);
+		return NETDEV_TX_OK;
+	}
+
+	if (!spin_trylock_irqsave(&adpt->tx_lock, flags)) {
+		DRV_PRINT(TX, EMERG, "tx locked!\n");
+		return NETDEV_TX_LOCKED;
+	}
+
+	if (!alx_check_num_tpdescs(txque, skb)) {
+		/* no enough descriptor, just stop queue */
+		netif_stop_queue(adpt->netdev);
+		spin_unlock_irqrestore(&adpt->tx_lock, flags);
+		return NETDEV_TX_BUSY;
+	}
+
+	DRV_PRINT(TX, INFO, "Before XMIT: TX[%d]: tpq.consume_idx = 0x%x, "
+		  "tpq.produce_idx = 0x%x\n",
+		  txque->que_idx, txque->tpq.consume_idx,
+		  txque->tpq.produce_idx);
+	memset(&stpd, 0, sizeof(struct alx_tpdesc));
+	/* do TSO and check sum */
+	if (alx_tso_csum(adpt, txque, skb, &stpd) != 0) {
+		spin_unlock_irqrestore(&adpt->tx_lock, flags);
+		dev_kfree_skb_any(skb);
+		return NETDEV_TX_OK;
+	}
+
+	if (unlikely(adpt->vlgrp && vlan_tx_tag_present(skb))) {
+		u32 vlan = vlan_tx_tag_get(skb);
+		stpd.tp_gnr.instag = 0x1;
+		stpd.tp_gnr.vlan_tag = vlan;
+	}
+
+	if (skb_network_offset(skb) != ETH_HLEN)
+		stpd.tp_gnr.type = 0x1; /* Ethernet frame */
+
+	alx_tx_map(adpt, skb, &stpd, txque);
+
+
+	/* update produce idx */
+	wmb();
+	MEM_W16(hw, txque->produce_reg, txque->tpq.produce_idx);
+	DRV_PRINT(TX, INFO, "TX[%d]: Produce Reg[0x%x] = 0x%x.\n",
+		  txque->que_idx, txque->produce_reg,
+		  txque->tpq.produce_idx);
+
+	spin_unlock_irqrestore(&adpt->tx_lock, flags);
+	return NETDEV_TX_OK;
+}
+
+static netdev_tx_t alx_start_xmit(struct sk_buff *skb,
+				  struct net_device *netdev)
+{
+	struct alx_adapter *adpt = netdev_priv(netdev);
+	struct alx_tx_queue *txque;
+
+	txque = adpt->tx_queue[0];
+	return alx_start_xmit_frames(skb, adpt, txque);
+}
+
+
+
+/*
+ * alx_mii_ioctl -
+ */
+static int alx_mii_ioctl(struct net_device *netdev,
+			 struct ifreq *ifr, int cmd)
+{
+	struct alx_adapter *adpt = netdev_priv(netdev);
+	struct alx_hw *hw = &adpt->hw;
+	struct mii_ioctl_data *data = if_mii(ifr);
+	u32 device_type;
+	u16 reg_addr;
+	int retval = 0;
+
+	DRV_PRINT(FUNC, DEBUG, "ENTER\n");
+
+	if (!netif_running(netdev))
+		return -EINVAL;
+
+	switch (cmd) {
+	case SIOCGMIIPHY:
+		data->phy_id = 0;
+		break;
+
+	case SIOCGMIIREG:
+		if (!capable(CAP_NET_ADMIN)) {
+			retval = -EPERM;
+			goto out;
+		}
+
+		if (data->reg_num & ~(0x1F)) {
+			retval = -EFAULT;
+			goto out;
+		}
+		device_type = ALX_MDIO_NORM_DEV;
+		reg_addr = data->reg_num;
+
+		retval = hw->cbs.read_phy_reg(hw, device_type, reg_addr,
+					      &data->val_out);
+		if (retval) {
+			retval = -EIO;
+			goto out;
+		}
+		break;
+
+	case SIOCSMIIREG:
+		if (!capable(CAP_NET_ADMIN)) {
+			retval = -EPERM;
+			goto out;
+		}
+
+		if (data->reg_num & ~(0x1F)) {
+			retval = -EFAULT;
+			goto out;
+		}
+		device_type = ALX_MDIO_NORM_DEV;
+		reg_addr = data->reg_num;
+
+		DRV_PRINT(IOCTL, DEBUG, "write %x %x",
+			  data->reg_num, data->val_in);
+		retval = hw->cbs.write_phy_reg(hw, device_type, reg_addr,
+					       data->val_in);
+		if (retval) {
+			retval = -EIO;
+			goto out;
+		}
+		break;
+	default:
+		retval = -EOPNOTSUPP;
+		break;
+	}
+out:
+	return retval;
+
+}
+
+
+/*
+ * alx_mac_ioctl -
+ */
+static int alx_mac_ioctl(struct net_device *netdev,
+			 struct ifreq *ifr, int cmd)
+{
+	struct alx_adapter *adpt = netdev_priv(netdev);
+	struct alx_hw *hw = &adpt->hw;
+	struct mac_ioctl_data *data = (struct mac_ioctl_data *)&ifr->ifr_ifru;
+	int retval = 0;
+
+	DRV_PRINT(FUNC, DEBUG, "ENTER\n");
+
+	if (!netif_running(netdev))
+		return -EINVAL;
+
+	switch (cmd) {
+	case SIOCDEVGMACREG:
+		DRV_PRINT(IOCTL, DEBUG, "read mac %x %x",
+			  data->reg_num, data->reg_val);
+		MEM_R32(hw, data->reg_num, &data->reg_val);
+		break;
+
+	case SIOCDEVSMACREG:
+		DRV_PRINT(IOCTL, DEBUG, "write mac %x %x",
+			  data->reg_num, data->reg_val);
+		MEM_W32(hw, data->reg_num, data->reg_val);
+		break;
+	default:
+		retval = -EOPNOTSUPP;
+		break;
+	}
+
+	return retval;
+}
+
+static int alx_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
+{
+	switch (cmd) {
+	case SIOCGMIIPHY:
+	case SIOCGMIIREG:
+	case SIOCSMIIREG:
+		return alx_mii_ioctl(netdev, ifr, cmd);
+
+	case SIOCDEVGMACREG: /* Read MAC Register */
+	case SIOCDEVSMACREG: /* Write MAC Register */
+		return alx_mac_ioctl(netdev, ifr, cmd);
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void alx_poll_controller(struct net_device *netdev)
+{
+	struct alx_adapter *adpt = netdev_priv(netdev);
+	int num_msix_intrs = adpt->num_msix_intrs;
+	int msix_idx;
+
+	DRV_PRINT(FUNC, DEBUG, "ENTER\n");
+
+	/* if interface is down do nothing */
+	if (test_bit(__ALX_DOWN, &adpt->alx_state))
+		return;
+
+	if (CHK_ADPT_FLAG(0, MSIX_EN)) {
+		for (msix_idx = 0; msix_idx < num_msix_intrs; msix_idx++) {
+			struct alx_msix_param *msix = adpt->msix[msix_idx];
+			if (CHK_MSIX_FLAG(RXS) || CHK_MSIX_FLAG(TXS))
+				alx_msix_rtx(0, msix);
+			else if (CHK_MSIX_FLAG(TIMER))
+				alx_msix_timer(0, msix);
+			else if (CHK_MSIX_FLAG(ALERT))
+				alx_msix_alert(0, msix);
+			else if (CHK_MSIX_FLAG(SMB))
+				alx_msix_smb(0, msix);
+			else if (CHK_MSIX_FLAG(PHY))
+				alx_msix_phy(0, msix);
+		}
+	} else {
+		alx_interrupt(adpt->pdev->irq, netdev);
+	}
+}
+#endif
+
+static const struct net_device_ops alx_netdev_ops = {
+	.ndo_open               = alx_open,
+	.ndo_stop               = alx_stop,
+	.ndo_start_xmit         = alx_start_xmit,
+	.ndo_get_stats          = alx_get_hw_stats,
+	.ndo_set_rx_mode        = alx_set_multicase_list,
+	.ndo_validate_addr      = eth_validate_addr,
+	.ndo_set_mac_address    = alx_set_mac_addr,
+	.ndo_change_mtu         = alx_change_mtu,
+	.ndo_do_ioctl           = alx_ioctl,
+	.ndo_tx_timeout         = alx_tx_timeout,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller    = alx_poll_controller,
+#endif
+};
+
+
+/*
+ * alx_init - Device Initialization Routine
+ */
+int __devinit alx_init(struct pci_dev *pdev,
+		       const struct pci_device_id *ent)
+{
+	struct net_device *netdev;
+	struct alx_adapter *adpt = NULL;
+	struct alx_hw *hw = NULL;
+	static int cards_found;
+	int retval;
+
+	/* enable device (incl. PCI PM wakeup and hotplug setup) */
+	retval = pci_enable_device_mem(pdev);
+	if (retval) {
+		dev_err(&pdev->dev, "cannot enable PCI device\n");
+		goto err_alloc_device;
+	}
+
+	/*
+	 * The alx chip can DMA to 64-bit addresses, but it uses a single
+	 * shared register for the high 32 bits, so only a single, aligned,
+	 * 4 GB physical address range can be used at a time.
+	 */
+	if (!dma_set_mask(&pdev->dev, DMA_BIT_MASK(64)) &&
+	    !dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(64))) {
+		dev_info(&pdev->dev, "DMA to 64-BIT addresses.\n");
+	} else {
+		retval = dma_set_mask(&pdev->dev, DMA_BIT_MASK(32));
+		if (retval) {
+			retval = dma_set_coherent_mask(&pdev->dev,
+						       DMA_BIT_MASK(32));
+			if (retval) {
+				dev_err(&pdev->dev, "No usable DMA "
+					"configuration, aborting\n");
+				goto err_alloc_pci_res;
+			}
+		}
+	}
+
+	retval = pci_request_selected_regions(pdev, pci_select_bars(pdev,
+					IORESOURCE_MEM), alx_drv_name);
+	if (retval) {
+		dev_err(&pdev->dev,
+			"pci_request_selected_regions failed 0x%x\n", retval);
+		goto err_alloc_pci_res;
+	}
+
+
+	pci_enable_pcie_error_reporting(pdev);
+	pci_set_master(pdev);
+
+	netdev = alloc_etherdev(sizeof(struct alx_adapter));
+	if (netdev == NULL) {
+		dev_err(&pdev->dev, "etherdev alloc failed\n");
+		retval = -ENOMEM;
+		goto err_alloc_netdev;
+	}
+
+	SET_NETDEV_DEV(netdev, &pdev->dev);
+	netdev->irq  = pdev->irq;
+
+	adpt = netdev_priv(netdev);
+	pci_set_drvdata(pdev, adpt);
+	adpt->netdev = netdev;
+	adpt->pdev = pdev;
+	hw = &adpt->hw;
+	hw->adpt = adpt;
+	adpt->msg_flags = ALX_MSG_DEFAULT;
+
+	adpt->hw.hw_addr = ioremap(pci_resource_start(pdev, BAR_0),
+				   pci_resource_len(pdev, BAR_0));
+	if (!adpt->hw.hw_addr) {
+		DRV_PRINT(INIT, ERR, "cannot map device registers\n");
+		retval = -EIO;
+		goto err_iomap;
+	}
+	netdev->base_addr = (unsigned long)adpt->hw.hw_addr;
+
+	/* set cb member of netdev structure*/
+	netdev->netdev_ops = &alx_netdev_ops;
+	alx_set_ethtool_ops(netdev);
+	netdev->watchdog_timeo = ALX_WATCHDOG_TIME;
+	strncpy(netdev->name, pci_name(pdev), sizeof(netdev->name) - 1);
+
+	adpt->bd_number = cards_found;
+
+	/* init alx_adapte structure */
+	retval = alx_init_adapter(adpt);
+	if (retval) {
+		DRV_PRINT(INIT, ERR, "net device private data init failed\n");
+		goto err_init_adapter;
+	}
+
+	/* 1. reset pcie */
+	retval = hw->cbs.reset_pcie(hw, true, true);
+	if (retval) {
+		DRV_PRINT(INIT, ERR, "PCIE Reset failed (%d).\n", retval);
+		retval = -EIO;
+		goto err_init_adapter;
+	}
+
+	/* 2. Init GPHY as early as possible due to power saving issue  */
+	retval = hw->cbs.reset_phy(hw);
+	if (retval) {
+		DRV_PRINT(INIT, ERR, "PHY Reset failed (%d).\n", retval);
+		retval = -EIO;
+		goto err_init_adapter;
+	}
+
+	/* 3. reset mac */
+	retval = hw->cbs.reset_mac(hw);
+	if (retval) {
+		DRV_PRINT(INIT, ERR, "MAC Reset failed (%d).\n", retval);
+		retval = -EIO;
+		goto err_init_adapter;
+	}
+
+	/* 4. setup link to put it in a known good starting state */
+	retval = hw->cbs.setup_phy_link(hw, hw->autoneg_advertised, true,
+					!hw->disable_fc_autoneg);
+
+	/* 5. get mac addr and perm mac addr, set to register */
+	if (hw->cbs.get_mac_addr) {
+		retval = hw->cbs.get_mac_addr(hw, hw->mac_perm_addr);
+		retval = hw->cbs.get_mac_addr(hw, hw->mac_addr);
+	}
+	if (hw->cbs.set_mac_addr)
+		retval = hw->cbs.set_mac_addr(hw, hw->mac_addr);
+
+	/* 6. get user settings */
+	adpt->num_txdescs = 1024;
+	adpt->num_rxdescs = 512;
+	adpt->max_rxques = min(ALX_MAX_RX_QUEUES, (int)num_online_cpus());
+	adpt->max_txques = min(ALX_MAX_TX_QUEUES, (int)num_online_cpus());
+
+
+	netdev->features = NETIF_F_SG |
+			   NETIF_F_HW_CSUM |
+			   NETIF_F_HW_VLAN_TX |
+			   NETIF_F_HW_VLAN_RX;
+	netdev->features |= NETIF_F_TSO;
+	netdev->features |= NETIF_F_TSO6;
+
+
+	memcpy(netdev->dev_addr, hw->mac_perm_addr, netdev->addr_len);
+	memcpy(netdev->perm_addr, hw->mac_perm_addr, netdev->addr_len);
+	if (alx_validate_mac_addr(netdev->perm_addr)) {
+		DRV_PRINT(INIT, INFO, "invalid MAC address\n");
+		retval = -EIO;
+		goto err_init_adapter;
+	}
+
+	setup_timer(&adpt->alx_timer, &alx_timer_routine,
+		    (unsigned long)adpt);
+	INIT_WORK(&adpt->alx_task, alx_task_routine);
+
+	/* Number of supported queues */
+	alx_set_num_queues(adpt);
+	retval = alx_set_interrupt_mode(adpt);
+	if (retval) {
+		DRV_PRINT(INIT, ERR, "can't set interrupt mode.\n");
+		goto err_set_interrupt_mode;
+	}
+
+	retval = alx_set_interrupt_param(adpt);
+	if (retval) {
+		DRV_PRINT(INIT, ERR, "can't set interrupt parameter.\n");
+		goto err_set_interrupt_param;
+	}
+
+	retval = alx_alloc_all_rtx_queue(adpt);
+	if (retval) {
+		DRV_PRINT(INIT, ERR, "can't allocate memory for queues\n");
+		goto err_alloc_rtx_queue;
+	}
+
+	alx_set_register_info_special(adpt);
+
+	DRV_PRINT(PCI, INFO, "num_msix_noque_intrs = %d, "
+		  "num_msix_rxque_intrs = %d, "
+		  "num_msix_txque_intrs = %d.\n",
+		  adpt->num_msix_noques,
+		  adpt->num_msix_rxques,
+		  adpt->num_msix_txques);
+	DRV_PRINT(PCI, INFO, "num_msix_all_intrs = %d.\n",
+		  adpt->num_msix_intrs);
+
+	/* WOL not supported for all but the following */
+	switch (hw->pci_devid) {
+	case ALX_DEV_ID_AR8131:
+	case ALX_DEV_ID_AR8132:
+	case ALX_DEV_ID_AR8151_V1:
+	case ALX_DEV_ID_AR8151_V2:
+	case ALX_DEV_ID_AR8152_V1:
+	case ALX_DEV_ID_AR8152_V2:
+		adpt->wol = (ALX_WOL_MAGIC | ALX_WOL_PHY);
+		break;
+	case ALX_DEV_ID_AR8161:
+	case ALX_DEV_ID_AR8162:
+		adpt->wol = (ALX_WOL_MAGIC | ALX_WOL_PHY);
+		break;
+	default:
+		adpt->wol = 0;
+		break;
+	}
+	device_set_wakeup_enable(&adpt->pdev->dev, adpt->wol);
+
+	set_bit(__ALX_DOWN, &adpt->alx_state);
+	strcpy(netdev->name, "eth%d");
+	retval = register_netdev(netdev);
+	if (retval) {
+		DRV_PRINT(INIT, ERR, "register netdevice failed\n");
+		goto err_register_netdev;
+	}
+	adpt->netdev_registered = true;
+
+	/* carrier off reporting is important to ethtool even BEFORE open */
+	netif_carrier_off(netdev);
+	/* keep stopping all the transmit queues for older kernels */
+	netif_tx_stop_all_queues(netdev);
+
+	/* print the MAC address */
+	DRV_PRINT(INIT, INFO, "%2.2x:%2.2x:%2.2x:%2.2x:%2.2x:%2.2x\n",
+		  netdev->dev_addr[0], netdev->dev_addr[1],
+		  netdev->dev_addr[2], netdev->dev_addr[3],
+		  netdev->dev_addr[4], netdev->dev_addr[5]);
+
+	DRV_PRINT(INIT, INFO, "RX Queue Count = %u, HRX Queue Count = %u, "
+		  "SRX Queue Count = %u, TX Queue Count = %u\n",
+		  adpt->num_rxques, adpt->num_hw_rxques, adpt->num_sw_rxques,
+		  adpt->num_txques);
+
+	/* print the adapter capability */
+	if (CHK_ADPT_FLAG(0, MSI_CAP))
+		DRV_PRINT(INIT, INFO, "MSI Capable: %s.\n",
+			  CHK_ADPT_FLAG(0, MSI_EN) ? "Enable" : "Disable");
+	if (CHK_ADPT_FLAG(0, MSIX_CAP))
+		DRV_PRINT(INIT, INFO, "MSIX Capable: %s.\n",
+			  CHK_ADPT_FLAG(0, MSIX_EN) ? "Enable" : "Disable");
+	if (CHK_ADPT_FLAG(0, MRQ_CAP))
+		DRV_PRINT(INIT, INFO, "MRQ Capable: %s.\n",
+			  CHK_ADPT_FLAG(0, MRQ_EN) ? "Enable" : "Disable");
+	if (CHK_ADPT_FLAG(0, MRQ_CAP))
+		DRV_PRINT(INIT, INFO, "MTQ Capable: %s.\n",
+			  CHK_ADPT_FLAG(0, MTQ_EN) ? "Enable" : "Disable");
+	if (CHK_ADPT_FLAG(0, SRSS_CAP))
+		DRV_PRINT(INIT, INFO, "RSS(SW) Capable: %s.\n",
+			  CHK_ADPT_FLAG(0, SRSS_EN) ? "Enable" : "Disable");
+
+	DRV_PRINT(INIT, INFO, "Atheros Gigabit Network Connection\n");
+	cards_found++;
+	return 0;
+
+err_register_netdev:
+	alx_free_all_rtx_queue(adpt);
+err_alloc_rtx_queue:
+	alx_reset_interrupt_param(adpt);
+err_set_interrupt_param:
+	alx_reset_interrupt_mode(adpt);
+err_set_interrupt_mode:
+err_init_adapter:
+	iounmap(adpt->hw.hw_addr);
+err_iomap:
+	free_netdev(netdev);
+err_alloc_netdev:
+	pci_release_selected_regions(pdev,
+				     pci_select_bars(pdev, IORESOURCE_MEM));
+err_alloc_pci_res:
+	pci_disable_device(pdev);
+err_alloc_device:
+	DRV_PRINT(INIT, INFO, "Error when probe device(%d).\n", retval);
+	return retval;
+}
+
+/*
+ * alx_remove - Device Removal Routine
+ * @pdev: PCI device information struct
+ */
+static void __devexit alx_remove(struct pci_dev *pdev)
+{
+	struct alx_adapter *adpt = pci_get_drvdata(pdev);
+	struct alx_hw *hw = &adpt->hw;
+	struct net_device *netdev = adpt->netdev;
+	int que_idx;
+
+	set_bit(__ALX_DOWN, &adpt->alx_state);
+	cancel_work_sync(&adpt->alx_task);
+
+	hw->cbs.config_pow_save(hw, ALX_LINK_SPEED_UNKNOWN,
+				false, false, false, false);
+
+	if (adpt->netdev_registered) {
+		unregister_netdev(netdev);
+		adpt->netdev_registered = false;
+	}
+
+	for (que_idx = 0; que_idx < adpt->num_txques; que_idx++) {
+		kfree(adpt->tx_queue[que_idx]);
+		adpt->tx_queue[que_idx] = NULL;
+	}
+	for (que_idx = 0; que_idx < adpt->num_rxques; que_idx++) {
+		kfree(adpt->rx_queue[que_idx]);
+		adpt->rx_queue[que_idx] = NULL;
+	}
+	alx_reset_interrupt_param(adpt);
+	alx_reset_interrupt_mode(adpt);
+
+	iounmap(adpt->hw.hw_addr);
+	pci_release_selected_regions(pdev,
+				     pci_select_bars(pdev, IORESOURCE_MEM));
+
+	DRV_PRINT(INIT, INFO, "complete\n");
+	free_netdev(netdev);
+
+	pci_disable_pcie_error_reporting(pdev);
+
+	pci_disable_device(pdev);
+}
+
+
+/*
+ * alx_pci_error_detected - called when PCI error is detected
+ */
+static pci_ers_result_t alx_pci_error_detected(struct pci_dev *pdev,
+					       pci_channel_state_t state)
+{
+	struct alx_adapter *adpt = pci_get_drvdata(pdev);
+	struct net_device *netdev = adpt->netdev;
+
+	netif_device_detach(netdev);
+
+	if (state == pci_channel_io_perm_failure)
+		return PCI_ERS_RESULT_DISCONNECT;
+
+	if (netif_running(netdev))
+		alx_stop_internal(adpt, ALX_OPEN_CTRL_MAC_EN);
+	pci_disable_device(pdev);
+
+	/* Request a slot reset. */
+	return PCI_ERS_RESULT_NEED_RESET;
+}
+
+/*
+ * alx_pci_error_slot_reset - called after the pci bus has been reset.
+ */
+static pci_ers_result_t alx_pci_error_slot_reset(struct pci_dev *pdev)
+{
+	struct alx_adapter *adpt = pci_get_drvdata(pdev);
+	pci_ers_result_t result;
+
+	if (pci_enable_device_mem(pdev)) {
+		DRV_PRINT(INIT, ERR,
+			"Cannot re-enable PCI device after reset.\n");
+		result =  PCI_ERS_RESULT_DISCONNECT;
+	} else {
+		pci_set_master(pdev);
+
+		pci_enable_wake(pdev, PCI_D3hot, 0);
+		pci_enable_wake(pdev, PCI_D3cold, 0);
+
+		adpt->hw.cbs.reset_mac(&adpt->hw);
+
+		result = PCI_ERS_RESULT_RECOVERED;
+	}
+
+	pci_cleanup_aer_uncorrect_error_status(pdev);
+
+	return result;
+}
+
+/*
+ * alx_pci_error_resume
+ */
+static void alx_pci_error_resume(struct pci_dev *pdev)
+{
+	struct alx_adapter *adpt = pci_get_drvdata(pdev);
+	struct net_device *netdev = adpt->netdev;
+
+	if (netif_running(netdev)) {
+		if (alx_open_internal(adpt, 0))
+			return;
+	}
+
+	netif_device_attach(netdev);
+}
+
+static struct pci_error_handlers alx_err_handler = {
+	.error_detected = alx_pci_error_detected,
+	.slot_reset     = alx_pci_error_slot_reset,
+	.resume         = alx_pci_error_resume,
+};
+
+
+static struct pci_driver alx_driver = {
+	.name     = alx_drv_name,
+	.id_table = alx_pci_tbl,
+	.probe    = alx_init,
+	.remove   = __devexit_p(alx_remove),
+#ifdef CONFIG_PM
+	.suspend  = alx_suspend,
+	.resume   = alx_resume,
+#endif
+	.shutdown = alx_shutdown,
+	.err_handler = &alx_err_handler
+};
+
+
+static int __init alx_init_module(void)
+{
+	int retval;
+	printk(KERN_INFO "%s - version %s\n",
+			alx_drv_description, alx_drv_version);
+	printk(KERN_INFO "%s\n", alx_copyright);
+	retval = pci_register_driver(&alx_driver);
+
+	return retval;
+}
+module_init(alx_init_module);
+
+
+
+static void __exit alx_exit_module(void)
+{
+	pci_unregister_driver(&alx_driver);
+}
+
+
+module_exit(alx_exit_module);
diff --git a/drivers/net/ethernet/atheros/alx/alx_sw.h b/drivers/net/ethernet/atheros/alx/alx_sw.h
new file mode 100755
index 0000000..7f3e81f
--- /dev/null
+++ b/drivers/net/ethernet/atheros/alx/alx_sw.h
@@ -0,0 +1,614 @@
+/*
+ * Copyright (c) 2010 - 2011 Atheros Communications Inc.
+ *
+ * Permission to use, copy, modify, and/or distribute this software for any
+ * purpose with or without fee is hereby granted, provided that the above
+ * copyright notice and this permission notice appear in all copies.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
+ * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
+ * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
+ * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
+ * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
+ * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ */
+
+#ifndef _ALX_SW_H_
+#define _ALX_SW_H_
+
+#include <linux/netdevice.h>
+#include <linux/crc32.h>
+
+/* Vendor ID */
+#define ALX_VENDOR_ID   0x1969
+
+/* Device IDs */
+#define ALX_DEV_ID_AR8131	0x1063	/* l1c */
+#define ALX_DEV_ID_AR8132	0x1062	/* l2c */
+#define ALX_DEV_ID_AR8151_V1	0x1073	/* l1d_v1 */
+#define ALX_DEV_ID_AR8151_V2	0x1083	/* l1d_v2 */
+#define ALX_DEV_ID_AR8152_V1	0x2060	/* l2cb_v1 */
+#define ALX_DEV_ID_AR8152_V2	0x2062	/* l2cb_v2 */
+#define ALX_DEV_ID_AR8161	0x1091	/* l1f */
+#define ALX_DEV_ID_AR8162	0x1090	/* l2f */
+
+#define ALX_REV_ID_AR8152_V1_0	0xc0
+#define ALX_REV_ID_AR8152_V1_1	0xc1
+#define ALX_REV_ID_AR8152_V2_0	0xc0
+#define ALX_REV_ID_AR8152_V2_1	0xc1
+
+#define ALX_REV_ID_AR8161_V2_0  0x10  /* B0 */
+
+/* Generic Registers */
+#define ALX_ISR			0x1600
+#define ALX_IMR			0x1604
+
+#define ALX_ISR_DIS		BIT_31
+#define ALX_ISR_RX_Q7		BIT_30
+#define ALX_ISR_RX_Q6		BIT_29
+#define ALX_ISR_RX_Q5		BIT_28
+#define ALX_ISR_RX_Q4		BIT_27
+#define ALX_ISR_PCIE_LNKDOWN	BIT_26
+#define ALX_ISR_PCIE_CERR	BIT_25
+#define ALX_ISR_PCIE_NFERR	BIT_24
+#define ALX_ISR_PCIE_FERR	BIT_23
+#define ALX_ISR_PCIE_UR		BIT_22
+#define ALX_ISR_MAC_TX		BIT_21
+#define ALX_ISR_MAC_RX		BIT_20
+#define ALX_ISR_RX_Q3		BIT_19
+#define ALX_ISR_RX_Q2		BIT_18
+#define ALX_ISR_RX_Q1		BIT_17
+#define ALX_ISR_RX_Q0		BIT_16
+#define ALX_ISR_TX_Q0		BIT_15
+#define ALX_ISR_TXQ_TO		BIT_14
+#define ALX_ISR_PHY_LPW		BIT_13
+#define ALX_ISR_PHY		BIT_12
+#define ALX_ISR_TX_CREDIT	BIT_11
+#define ALX_ISR_DMAW		BIT_10
+#define ALX_ISR_DMAR		BIT_9
+#define ALX_ISR_TXF_UR		BIT_8
+#define ALX_ISR_TX_Q3		BIT_7
+#define ALX_ISR_TX_Q2		BIT_6
+#define ALX_ISR_TX_Q1		BIT_5
+#define ALX_ISR_RFD_UR		BIT_4
+#define ALX_ISR_RXF_OV		BIT_3
+#define ALX_ISR_MANU		BIT_2
+#define ALX_ISR_TIMER		BIT_1
+#define ALX_ISR_SMB		BIT_0
+
+#define ALX_IMR_NORMAL_MASK  (\
+		ALX_ISR_MANU    |\
+		ALX_ISR_RXF_OV  |\
+		ALX_ISR_RFD_UR  |\
+		ALX_ISR_TXF_UR  |\
+		ALX_ISR_DMAR    |\
+		ALX_ISR_TXQ_TO  |\
+		ALX_ISR_DMAW    |\
+		ALX_ISR_TXQ     |\
+		ALX_ISR_RXQ     |\
+		ALX_ISR_PHY_LPW |\
+		ALX_ISR_PHY     |\
+		ALX_ISR_PCIE_LNKDOWN)
+
+#define ALX_ISR_ALERT_MASK  (\
+		ALX_ISR_DMAR		|\
+		ALX_ISR_DMAW		|\
+		ALX_ISR_TXQ_TO		|\
+		ALX_ISR_PCIE_FERR	|\
+		ALX_ISR_PCIE_LNKDOWN	|\
+		ALX_ISR_RFD_UR		|\
+		ALX_ISR_RXF_OV)
+
+#define ALX_ISR_TXQ  (\
+		ALX_ISR_TX_Q0	|\
+		ALX_ISR_TX_Q1	|\
+		ALX_ISR_TX_Q2	|\
+		ALX_ISR_TX_Q3)
+
+#define ALX_ISR_RXQ  (\
+		ALX_ISR_RX_Q0	|\
+		ALX_ISR_RX_Q1	|\
+		ALX_ISR_RX_Q2	|\
+		ALX_ISR_RX_Q3	|\
+		ALX_ISR_RX_Q4	|\
+		ALX_ISR_RX_Q5	|\
+		ALX_ISR_RX_Q6	|\
+		ALX_ISR_RX_Q7)
+
+#define ALX_ISR_OVER  (\
+		ALX_ISR_RFD_UR	|\
+		ALX_ISR_RXF_OV	|\
+		ALX_ISR_TXF_UR)
+
+#define ALX_ISR_ERROR  (\
+		ALX_ISR_DMAR	|\
+		ALX_ISR_TXQ_TO	|\
+		ALX_ISR_DMAW	|\
+		ALX_ISR_PCIE_LNKDOWN)
+
+/* MISC Register */
+#define ALX_MISC                        0x19C0
+#define ALX_MISC_INTNLOSC_OPEN          BIT_3
+
+/* HW_PRINT */
+#define ALX_HW_MSG_LV_ERR	1
+#define ALX_HW_MSG_LV_INFO	0
+#define ALX_HW_MSG_LV_DEBUG	0
+
+#define ALX_HW_MSG_LV_ALL	0
+#define ALX_HW_MSG_PFX_NAME	"alx_hw: "
+
+#define HW_PRINT(_klv, _fmt, _args...) \
+	if (ALX_HW_MSG_LV_##_klv || ALX_HW_MSG_LV_ALL) {\
+		printk(KERN_##_klv ALX_HW_MSG_PFX_NAME "%s: " _fmt, \
+			__func__, ## _args); \
+	}
+
+
+/* delay function */
+#define US_DELAY(_hw, _n)	__US_DELAY(_n)
+#define MS_DELAY(_hw, _n)	__MS_DELAY(_n)
+#define __US_DELAY(_n)		udelay(_n)
+#define __MS_DELAY(_n)		mdelay(_n)
+
+/* DMA address */
+#define DMA_ADDR_HI_MASK     0xffffffff00000000ULL
+#define DMA_ADDR_LO_MASK     0x00000000ffffffffULL
+
+#define ALX_DMA_ADDR_HI(_addr)	 \
+		((u32)(((u64)(_addr) & DMA_ADDR_HI_MASK) >> 32))
+#define ALX_DMA_ADDR_LO(_addr)	 \
+		((u32)((u64)(_addr) & DMA_ADDR_LO_MASK))
+
+/* mac address length */
+#define ALX_ETH_LENGTH_OF_ADDRESS	6
+#define ALX_ETH_LENGTH_OF_HEADER	ETH_HLEN
+
+#define ALX_ETH_CRC(_addr, _len)	ether_crc((_len), (_addr));
+
+/* Autonegotiation advertised speeds */
+/* Link speed */
+#define ALX_LINK_SPEED_UNKNOWN		0x0
+#define ALX_LINK_SPEED_10_HALF		0x0001
+#define ALX_LINK_SPEED_10_FULL		0x0002
+#define ALX_LINK_SPEED_100_HALF		0x0004
+#define ALX_LINK_SPEED_100_FULL		0x0008
+#define ALX_LINK_SPEED_1GB_FULL		0x0020
+
+#define ALX_LINK_SPEED_DEFAULT        (\
+		ALX_LINK_SPEED_10_HALF  |\
+		ALX_LINK_SPEED_10_FULL  |\
+		ALX_LINK_SPEED_100_HALF |\
+		ALX_LINK_SPEED_100_FULL |\
+		ALX_LINK_SPEED_1GB_FULL)
+
+#define ALX_MAX_SETUP_LNK_CYCLE		100
+
+/* Device Type definitions for new protocol MDIO commands */
+#define ALX_MDIO_PMA_PMD_DEV		0x1
+#define ALX_MDIO_PCS_DEV		0x3
+#define ALX_MDIO_AUTO_NEG_DEV		0x7
+#define ALX_MDIO_NORM_DEV		0x0
+
+#define ALX_MDIO_DEV_TYPE_MASK		0xFF00
+#define ALX_MDIO_DEV_TYPE_SHIFT		0x8
+#define ALX_MDIO_REG_ADDR_MASK		0xff
+#define ALX_MDIO_REG_ADDR_SHIFT		0x0
+
+/* MDIO Lock */
+#define ALX_MDIO_LOCK_INIT(_lock)	\
+		spin_lock_init((_lock))
+#define ALX_MDIO_LOCK(_lock)		\
+		spin_lock_irqsave((_lock), hw->mdio_flags)
+#define ALX_MDIO_UNLOCK(_lock)		\
+		spin_unlock_irqrestore((_lock), hw->mdio_flags)
+
+/* Wake On Lan */
+#define ALX_WOL_PHY	BIT_0 /* PHY Status Change */
+#define ALX_WOL_MAGIC	BIT_1 /* Magic Packet */
+
+#define ALX_MAX_EEPROM_LEN	0x200
+#define ALX_MAX_HWREG_LEN	0x200
+
+/* RSS Settings */
+enum alx_rss_mode {
+	alx_rss_mode_disable = 0,
+	alx_rss_sig_que = 1,
+	alx_rss_mul_que_sig_int = 2,
+	alx_rss_mul_que_mul_int = 4,
+};
+
+/* Flow Control Settings */
+enum alx_fc_mode {
+	alx_fc_none = 0,
+	alx_fc_rx_pause,
+	alx_fc_tx_pause,
+	alx_fc_full,
+	alx_fc_default
+};
+
+/* WRR Restrict Settings */
+enum alx_wrr_mode {
+	alx_wrr_mode_none = 0,
+	alx_wrr_mode_high,
+	alx_wrr_mode_high2,
+	alx_wrr_mode_all
+};
+
+enum alx_mac_type {
+	alx_mac_unknown = 0,
+	alx_mac_l1c,
+	alx_mac_l2c,
+	alx_mac_l1d_v1,
+	alx_mac_l1d_v2,
+	alx_mac_l2cb_v1,
+	alx_mac_l2cb_v20,
+	alx_mac_l2cb_v21,
+	alx_mac_l1f,
+	alx_mac_l2f,
+};
+
+
+/* Statistics counters collected by the MAC */
+struct alx_hw_stats {
+	/* rx */
+	unsigned long rx_ok;
+	unsigned long rx_bcast;
+	unsigned long rx_mcast;
+	unsigned long rx_pause;
+	unsigned long rx_ctrl;
+	unsigned long rx_fcs_err;
+	unsigned long rx_len_err;
+	unsigned long rx_byte_cnt;
+	unsigned long rx_runt;
+	unsigned long rx_frag;
+	unsigned long rx_sz_64B;
+	unsigned long rx_sz_127B;
+	unsigned long rx_sz_255B;
+	unsigned long rx_sz_511B;
+	unsigned long rx_sz_1023B;
+	unsigned long rx_sz_1518B;
+	unsigned long rx_sz_max;
+	unsigned long rx_ov_sz;
+	unsigned long rx_ov_rxf;
+	unsigned long rx_ov_rrd;
+	unsigned long rx_align_err;
+	unsigned long rx_bc_byte_cnt;
+	unsigned long rx_mc_byte_cnt;
+	unsigned long rx_err_addr;
+
+	/* tx */
+	unsigned long tx_ok;
+	unsigned long tx_bcast;
+	unsigned long tx_mcast;
+	unsigned long tx_pause;
+	unsigned long tx_exc_defer;
+	unsigned long tx_ctrl;
+	unsigned long tx_defer;
+	unsigned long tx_byte_cnt;
+	unsigned long tx_sz_64B;
+	unsigned long tx_sz_127B;
+	unsigned long tx_sz_255B;
+	unsigned long tx_sz_511B;
+	unsigned long tx_sz_1023B;
+	unsigned long tx_sz_1518B;
+	unsigned long tx_sz_max;
+	unsigned long tx_single_col;
+	unsigned long tx_multi_col;
+	unsigned long tx_late_col;
+	unsigned long tx_abort_col;
+	unsigned long tx_underrun;
+	unsigned long tx_trd_eop;
+	unsigned long tx_len_err;
+	unsigned long tx_trunc;
+	unsigned long tx_bc_byte_cnt;
+	unsigned long tx_mc_byte_cnt;
+	unsigned long update;
+};
+
+/* HW callback function pointer table */
+struct alx_hw;
+struct alx_hw_callbacks {
+	/* NIC */
+	int (*identify_nic)(struct alx_hw *);
+	/* PHY */
+	int (*init_phy)(struct alx_hw *);
+	int (*reset_phy)(struct alx_hw *);
+	int (*read_phy_reg)(struct alx_hw *, u32, u16, u16 *);
+	int (*write_phy_reg)(struct alx_hw *, u32, u16, u16);
+	/* Link */
+	int (*setup_phy_link)(struct alx_hw *, u32, bool, bool);
+	int (*setup_phy_link_speed)(struct alx_hw *, u32, bool, bool);
+	int (*check_phy_link)(struct alx_hw *, u32 *, bool *);
+
+	/* MAC */
+	int (*reset_mac)(struct alx_hw *);
+	int (*start_mac)(struct alx_hw *);
+	int (*stop_mac)(struct alx_hw *);
+	int (*config_mac)(struct alx_hw *, u16, u16, u16, u16, u16);
+	int (*get_mac_addr)(struct alx_hw *, u8 *);
+	int (*set_mac_addr)(struct alx_hw *, u8 *);
+	int (*clear_mac_addr)(struct alx_hw *);
+	int (*set_mc_addr)(struct alx_hw *, u8 *);
+	int (*clear_mc_addr)(struct alx_hw *);
+
+	/* intr */
+	int (*ack_phy_intr)(struct alx_hw *);
+	int (*enable_legacy_intr)(struct alx_hw *);
+	int (*disable_legacy_intr)(struct alx_hw *);
+	int (*enable_msix_intr)(struct alx_hw *, u8);
+	int (*disable_msix_intr)(struct alx_hw *, u8);
+
+	/* Configure */
+	int (*config_rx)(struct alx_hw *);
+	int (*config_tx)(struct alx_hw *);
+	int (*config_fc)(struct alx_hw *);
+	int (*config_rss)(struct alx_hw *, bool);
+	int (*config_msix)(struct alx_hw *, u16, bool, bool);
+	int (*config_wol)(struct alx_hw *, u32);
+	int (*config_aspm)(struct alx_hw *, bool, bool);
+	int (*config_mac_ctrl)(struct alx_hw *);
+	int (*config_pow_save)(struct alx_hw *, u32,
+				bool, bool, bool, bool);
+	int (*reset_pcie)(struct alx_hw *, bool, bool);
+
+	/* NVRam function */
+	int (*check_nvram)(struct alx_hw *, bool *);
+	int (*read_nvram)(struct alx_hw *, u16, u32 *);
+	int (*write_nvram)(struct alx_hw *, u16, u32);
+
+	/* Others */
+	int (*get_ethtool_regs)(struct alx_hw *, void *);
+};
+
+struct alx_hw {
+	struct alx_adapter	*adpt;
+	struct alx_hw_callbacks	 cbs;
+	u8 __iomem	*hw_addr; /* inner register address */
+	u16		pci_venid;
+	u16		pci_devid;
+	u16		pci_sub_devid;
+	u16		pci_sub_venid;
+	u8		pci_revid;
+
+	bool		long_cable;
+	bool		aps_en;
+	bool		hi_txperf;
+	bool		msi_lnkpatch;
+	u32		hwreg_sz;
+	u32		eeprom_sz;
+
+	/* PHY parameter */
+	u32		phy_id;
+	u32		autoneg_advertised;
+	u32		link_speed;
+	bool		link_up;
+	spinlock_t	mdio_lock;
+	unsigned long	mdio_flags;
+
+	/* MAC parameter */
+	enum alx_mac_type	mac_type;
+	u8	mac_addr[ALX_ETH_LENGTH_OF_ADDRESS];
+	u8	mac_perm_addr[ALX_ETH_LENGTH_OF_ADDRESS];
+	u32	mtu;
+	u16	rxstat_reg;
+	u16	rxstat_sz;
+	u16	txstat_reg;
+	u16	txstat_sz;
+
+	u16	tx_prod_reg[4];
+	u16	tx_cons_reg[4];
+	u16	rx_prod_reg[2];
+	u16	rx_cons_reg[2];
+	u64	tpdma[4];
+	u64	rfdma[2];
+	u64	rrdma[2];
+
+	/* WRR parameter */
+	enum alx_wrr_mode	wrr_mode;
+	u32	wrr_prio0;
+	u32	wrr_prio1;
+	u32	wrr_prio2;
+	u32	wrr_prio3;
+
+	/* RSS parameter */
+	enum alx_rss_mode	rss_mode;
+	u8   rss_hstype;
+	u8   rss_base_cpu;
+	u16  rss_idt_size;
+	u32  rss_idt[32];
+	u8   rss_key[40];
+
+	/* flow control parameter */
+	enum alx_fc_mode cur_fc_mode; /* FC mode in effect */
+	enum alx_fc_mode req_fc_mode; /* FC mode requested by caller */
+	bool disable_fc_autoneg; /* Do not autonegotiate FC */
+	bool fc_was_autonegged; /* Is current_mode the result of autonegging? */
+	bool fc_single_pause;
+
+	/* Others */
+	u32	preamble;
+	u32	intr_mask;
+	u16	smb_timer;
+	u16	imt;    /* Interrupt Moderator timer ( 2us resolution) */
+	u32	flags;
+};
+#define ALX_HW_FLAG_L0S_CAP		BIT_0
+#define ALX_HW_FLAG_L0S_EN		BIT_1
+#define ALX_HW_FLAG_L1_CAP		BIT_2
+#define ALX_HW_FLAG_L1_EN		BIT_3
+#define ALX_HW_FLAG_PWSAVE_CAP		BIT_4
+#define ALX_HW_FLAG_PWSAVE_EN		BIT_5
+#define ALX_HW_FLAG_AZ_CAP		BIT_6
+#define ALX_HW_FLAG_AZ_EN		BIT_7
+#define ALX_HW_FLAG_PTP_CAP		BIT_8
+#define ALX_HW_FLAG_PTP_EN		BIT_9
+#define ALX_HW_FLAG_GIGA_CAP		BIT_10
+
+#define ALX_HW_FLAG_PROMISC_EN		BIT_16   /* for mac ctrl reg */
+#define ALX_HW_FLAG_VLANSTRIP_EN	BIT_17   /* for mac ctrl reg */
+#define ALX_HW_FLAG_MULTIALL_EN		BIT_18   /* for mac ctrl reg */
+#define CHK_HW_FLAG(_flag)	CHK_FLAG(hw, HW, _flag)
+#define SET_HW_FLAG(_flag)	SET_FLAG(hw, HW, _flag)
+#define CLI_HW_FLAG(_flag)	CLI_FLAG(hw, HW, _flag)
+
+
+/* RSS hstype Definitions */
+#define ALX_RSS_HSTYP_IPV4_EN	BIT_0
+#define ALX_RSS_HSTYP_TCP4_EN	BIT_1
+#define ALX_RSS_HSTYP_IPV6_EN	BIT_2
+#define ALX_RSS_HSTYP_TCP6_EN	BIT_3
+#define ALX_RSS_HSTYP_ALL_EN         (\
+		ALX_RSS_HSTYP_IPV4_EN | \
+		ALX_RSS_HSTYP_TCP4_EN | \
+		ALX_RSS_HSTYP_IPV6_EN | \
+		ALX_RSS_HSTYP_TCP6_EN)
+
+
+/* definitions for flags */
+#define CHK_FLAG_ARRAY(_st, _idx, _type, _flag)	\
+		((_st)->flags[_idx] & (ALX_##_type##_FLAG_##_idx##_##_flag))
+#define CHK_FLAG(_st, _type, _flag)	\
+		((_st)->flags & (ALX_##_type##_FLAG_##_flag))
+
+#define SET_FLAG_ARRAY(_st, _idx, _type, _flag) \
+		((_st)->flags[_idx] |= (ALX_##_type##_FLAG_##_idx##_##_flag))
+#define SET_FLAG(_st, _type, _flag) \
+		((_st)->flags |= (ALX_##_type##_FLAG_##_flag))
+
+#define CLI_FLAG_ARRAY(_st, _idx, _type, _flag) \
+		((_st)->flags[_idx] &= ~(ALX_##_type##_FLAG_##_idx##_##_flag))
+#define CLI_FLAG(_st, _type, _flag) \
+		((_st)->flags &= ~(ALX_##_type##_FLAG_##_flag))
+
+
+/* definitions for compatible with *_hw.c and *_hw.h */
+#define __far
+#define DEBUG_INFO(_a, _b)
+#define DEBUG_INFOS(_a, _b)
+
+typedef struct alx_hw ETHCONTEXT;
+typedef ETHCONTEXT * PETHCONTEXT;
+
+
+#define MAC_TYPE	MAC_TYPE_ASIC   /* (1:FPGA, 0:ASIC) */
+#define PHY_TYPE	PHY_TYPE_ASIC   /* (2:F1, 1:FPGA, 0:ASIC) */
+
+#define MAC_TYPE_ASIC	0
+#define MAC_TYPE_FPGA	1
+#define PHY_TYPE_ASIC	0
+#define PHY_TYPE_FPGA	1
+#define PHY_TYPE_F1	2   /* (2:F1, 1:FPGA, 0:ASIC) */
+
+
+#define MEM_FLUSH(_hw)						\
+	do {							\
+		readl((_hw)->hw_addr);				\
+	} while (0)
+
+#define MEM_W32(_hw, _reg, _val)				\
+	do {							\
+		if (((_hw)->mac_type == alx_mac_l2cb_v20) &&	\
+		    ((_reg) < 0x1400))				\
+			readl((_hw)->hw_addr + (_reg));		\
+		writel((_val), ((_hw)->hw_addr + _reg));	\
+	} while (0)
+
+#define MEM_R32(_hw, _reg, _pval)				\
+	do {							\
+		if (unlikely(!(_hw)->link_up))		\
+			readl((_hw)->hw_addr + (_reg));		\
+		*(u32 *)_pval = readl((_hw)->hw_addr + (_reg));	\
+	} while (0)
+
+
+#define MEM_W16(_hw, _reg, _val)				\
+	do {							\
+		if (((_hw)->mac_type == alx_mac_l2cb_v20) &&	\
+		    ((_reg) < 0x1400))				\
+			readl((_hw)->hw_addr + (_reg));		\
+		writew((_val), ((_hw)->hw_addr + _reg));	\
+	} while (0)
+
+
+#define MEM_R16(_hw, _reg, _pval)				\
+	do {							\
+		if (unlikely(!(_hw)->link_up))		\
+			readw((_hw)->hw_addr + (_reg));		\
+		*(u16 *)_pval = readw((_hw)->hw_addr + (_reg));	\
+	} while (0)
+
+
+#define MEM_W8(_hw, _reg, _val)					\
+	do {							\
+		if (((_hw)->mac_type == alx_mac_l2cb_v20) &&	\
+		    ((_reg) < 0x1400))				\
+			readl((_hw)->hw_addr + (_reg));		\
+		writeb((_val), ((_hw)->hw_addr + _reg));	\
+	} while (0)
+
+
+#define MEM_R8(_hw, _reg, _pval)				\
+	do {							\
+		if (unlikely(!(_hw)->link_up))		\
+			readb((_hw)->hw_addr + (_reg));		\
+		*(u8 *)_pval = readb((_hw)->hw_addr + (_reg));	\
+	} while (0)
+
+#define CFG_W16(_hw, _reg, _val)     MEM_W16(_hw, _reg, _val)
+#define CFG_R16(_hw, _reg, _pval)    MEM_R16(_hw, _reg, _pval)
+
+
+/* special definitions for hw */
+#define ALF_MAX_MSIX_NOQUE_INTRS	4
+#define ALF_MIN_MSIX_NOQUE_INTRS	4
+#define ALF_MAX_MSIX_QUEUE_INTRS	12
+#define ALF_MIN_MSIX_QUEUE_INTRS	12
+#define ALF_MAX_MSIX_INTRS \
+		(ALF_MAX_MSIX_QUEUE_INTRS + ALF_MAX_MSIX_NOQUE_INTRS)
+#define ALF_MIN_MSIX_INTRS \
+		(ALF_MIN_MSIX_NOQUE_INTRS + ALF_MIN_MSIX_QUEUE_INTRS)
+
+
+/* function */
+extern int alc_init_hw_callbacks(struct alx_hw *hw);
+extern int alf_init_hw_callbacks(struct alx_hw *hw);
+
+/* Error Codes */
+#define ALX_SUCCESS			0
+
+#define ALX_ERR_MAC			-1
+#define ALX_ERR_MAC_INIT		-2
+#define ALX_ERR_MAC_RESET		-3
+#define ALX_ERR_MAC_START		-4
+#define ALX_ERR_MAC_STOP		-5
+#define ALX_ERR_MAC_CONFIGURE		-6
+#define ALX_ERR_MAC_ADDR		-7
+
+#define ALX_ERR_PHY			-20
+#define ALX_ERR_PHY_INIT		-21
+#define ALX_ERR_PHY_RESET		-22
+#define ALX_ERR_PHY_SETUP_LNK		-23
+#define ALX_ERR_PHY_CHECK_LNK		-24
+#define ALX_ERR_PHY_READ_REG		-25
+#define ALX_ERR_PHY_WRITE_REG		-26
+#define ALX_ERR_PHY_RESOLVED		-27
+
+#define ALX_ERR_PCIE			-40
+#define ALX_ERR_PCIE_RESET		-41
+#define ALX_ERR_PWR_SAVING		-42
+#define ALX_ERR_ASPM			-43
+#define ALX_ERR_EEPROM			-44
+#define ALX_ERR_DISABLE_DRV		-45
+
+#define ALX_ERR_FLOW_CONTROL		-50
+#define ALX_ERR_FC_NOT_NEGOTIATED	-51
+#define ALX_ERR_FC_NOT_SUPPORTED	-52
+
+#define ALX_ERR_INVALID_ARGUMENT	0x7FFFFFFD
+#define ALX_ERR_NOT_SUPPORTED		0x7FFFFFFE
+#define ALX_ERR_NOT_IMPLEMENTED		0x7FFFFFFF
+
+#endif /* _ALX_SW_H_ */
+
