From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] net: add QCA alx Ethernet driver
Date: Fri, 2 Mar 2012 00:40:07 +0100
Message-ID: <20120301234007.GA18488@electric-eye.fr.zoreil.com>
References: <1330480210-30470-1-git-send-email-rodrigue@qca.qualcomm.com> <20120228193237.2d56f2b8@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Luis R. Rodriguez" <rodrigue@qca.qualcomm.com>,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mcgrof@frijolero.org,
	qca-linux-team@qualcomm.com, nic-devel@qualcomm.com,
	kgiori@qca.qualcomm.com, chris.snook@gmail.com,
	mathieu@qca.qualcomm.com, bryanh@quicinc.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:48341 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751205Ab2CAXkl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Mar 2012 18:40:41 -0500
Content-Disposition: inline
In-Reply-To: <20120228193237.2d56f2b8@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> :
[...]
> Evolution is better. The new driver has lots of new callbacks to handle
> the fact it is dealing with two different chipsets. Not only that your callbacks
> are built at runtime which leads to security concerns.
> 
> There is a reason the two Marvell based drivers (skge and sky2) are
> different drivers. Having to do extra per-chip callbacks is a clear sign
> the driver should be split in two.

(arguable)

Whatever QCA chooses, here is a collection of things QCA's incoming patches
could avoid.

> diff --git a/drivers/net/ethernet/atheros/Kconfig b/drivers/net/ethernet/atheros/Kconfig
> index 1ed886d..a1cfc98 100644
> --- a/drivers/net/ethernet/atheros/Kconfig
> +++ b/drivers/net/ethernet/atheros/Kconfig
[...]
> +#include <linux/pci_regs.h>
> +#include <linux/mii.h>
> +
> +#include "alc_hw.h"
> +
> +
> +/* NIC */
> +static int alc_identify_nic(struct alx_hw *hw)
> +{
> +	return 0;
> +}
> +
> +
> +/* PHY */
> +static int alc_read_phy_reg(struct alx_hw *hw, u16 reg_addr, u16 *phy_data)
> +{
> +	unsigned long  flags;
                     ^^

(applies several times through the driver)

> +	int  retval = 0;
> +
> +	spin_lock_irqsave(&hw->mdio_lock, flags);
> +
> +	if (l1c_read_phy(hw, false, ALX_MDIO_DEV_TYPE_NORM, false, reg_addr,
> +			 phy_data)) {

The return status style is gross. It could (should ?) be:

	rc = l1c_read_phy(hw, false, ALX_MDIO_DEV_TYPE_NORM, false, reg, data);
	if (rc < 0)


[...]
> +static int alc_setup_phy_link(struct alx_hw *hw, u32 speed, bool autoneg,
> +			      bool fc)
> +{
> +	u8 link_cap = 0;
> +	int retval = 0;
> +
> +	alx_hw_info(hw, "speed = 0x%x, autoneg = %d\n", speed, autoneg);
> +	if (speed & ALX_LINK_SPEED_1GB_FULL)
> +		link_cap |= LX_LC_1000F;
> +
> +	if (speed & ALX_LINK_SPEED_100_FULL)
> +		link_cap |= LX_LC_100F;
> +
> +	if (speed & ALX_LINK_SPEED_100_HALF)
> +		link_cap |= LX_LC_100H;
> +
> +	if (speed & ALX_LINK_SPEED_10_FULL)
> +		link_cap |= LX_LC_10F;
> +
> +	if (speed & ALX_LINK_SPEED_10_HALF)
> +		link_cap |= LX_LC_10H;

This ought to be a loop but one of LX_LC_... or ALX_LINK_SPEED_... probably
deserves to be removed.

[...]
> +static int alc_setup_phy_link_speed(struct alx_hw *hw, u32 speed,
> +				    bool autoneg, bool fc)
> +{
> +	/*
> +	 * Clear autoneg_advertised and set new values based on input link
> +	 * speed.
> +	 */
> +	hw->autoneg_advertised = 0;
> +
> +	if (speed & ALX_LINK_SPEED_1GB_FULL)
> +		hw->autoneg_advertised |= ALX_LINK_SPEED_1GB_FULL;
> +
> +	if (speed & ALX_LINK_SPEED_100_FULL)
> +		hw->autoneg_advertised |= ALX_LINK_SPEED_100_FULL;
> +
> +	if (speed & ALX_LINK_SPEED_100_HALF)
> +		hw->autoneg_advertised |= ALX_LINK_SPEED_100_HALF;
> +
> +	if (speed & ALX_LINK_SPEED_10_FULL)
> +		hw->autoneg_advertised |= ALX_LINK_SPEED_10_FULL;
> +
> +	if (speed & ALX_LINK_SPEED_10_HALF)
> +		hw->autoneg_advertised |= ALX_LINK_SPEED_10_HALF;
> +
> +	return alc_setup_phy_link(hw, hw->autoneg_advertised,
> +				  autoneg, fc);

It should fit within a single line.

> +}
> +
> +
> +static int alc_check_phy_link(struct alx_hw *hw, u32 *speed, bool *link_up)
> +{
> +	u16 bmsr, giga;
> +	int retval;
> +
> +	alc_read_phy_reg(hw, MII_BMSR, &bmsr);
> +	retval = alc_read_phy_reg(hw, MII_BMSR, &bmsr);
> +	if (retval)
> +		return retval;
> +
> +	if (!(bmsr & BMSR_LSTATUS)) {
> +		*link_up = false;
> +		*speed = ALX_LINK_SPEED_UNKNOWN;
> +		return 0;

It could be 'return rc^Wretval' too.

[...]
> +static int alc_config_mac(struct alx_hw *hw, u16 rxbuf_sz, u16 rx_qnum,
> +			  u16 rxring_sz, u16 tx_qnum,  u16 txring_sz)
> +{
> +	u8 *addr;
> +
> +	u32 txmem_hi, txmem_lo[4];
> +
> +	u32 rxmem_hi, rfdmem_lo, rrdmem_lo;
> +
> +	u16 smb_timer, mtu_with_eth, int_mod;
> +	bool hash_legacy;
> +
> +	int i;

Why are they so many empty lines ?

> +	int retval = 0;
> +
> +	addr = hw->mac_addr;
> +
> +	txmem_hi = ALX_DMA_ADDR_HI(hw->tpdma[0]);
> +	for (i = 0; i < tx_qnum; i++)
> +		txmem_lo[i] = ALX_DMA_ADDR_LO(hw->tpdma[i]);
> +
> +
> +	rxmem_hi = ALX_DMA_ADDR_HI(hw->rfdma[0]);
> +	rfdmem_lo = ALX_DMA_ADDR_LO(hw->rfdma[0]);
> +	rrdmem_lo = ALX_DMA_ADDR_LO(hw->rrdma[0]);
> +
> +
> +	smb_timer = (u16)hw->smb_timer;
> +	mtu_with_eth = hw->mtu + ALX_ETH_LENGTH_OF_HEADER;
> +	int_mod = hw->imt;
> +
> +	hash_legacy = true;
> +
> +	if (l1c_init_mac(hw, addr, txmem_hi, txmem_lo, tx_qnum, txring_sz,
> +			 rxmem_hi, rfdmem_lo, rrdmem_lo, rxring_sz, rxbuf_sz,
> +			 smb_timer, mtu_with_eth, int_mod, hash_legacy)) {

This should use some real struct.


> +		alx_hw_err(hw, "error when config mac\n");
> +		retval = -EINVAL;
> +	}
> +
> +	return retval;
> +}
> +
> +
> +/**
> + *  alc_get_mac_addr
> + *  @hw: pointer to hardware structure
> + **/

Useless.

[...]
> +static int alc_config_mac_ctrl(struct alx_hw *hw)
> +{
> +	u32 mac;
> +
> +	alx_mem_r32(hw, L1C_MAC_CTRL, &mac);
> +
> +	/* enable/disable VLAN tag insert,strip */
> +	if (CHK_HW_FLAG(VLANSTRIP_EN))
> +		mac |= L1C_MAC_CTRL_VLANSTRIP;
> +	else
> +		mac &= ~L1C_MAC_CTRL_VLANSTRIP;
> +
> +	if (CHK_HW_FLAG(PROMISC_EN))
> +		mac |= L1C_MAC_CTRL_PROMISC_EN;
> +	else
> +		mac &= ~L1C_MAC_CTRL_PROMISC_EN;
> +
> +	if (CHK_HW_FLAG(MULTIALL_EN))
> +		mac |= L1C_MAC_CTRL_MULTIALL_EN;
> +	else
> +		mac &= ~L1C_MAC_CTRL_MULTIALL_EN;
> +
> +	if (CHK_HW_FLAG(LOOPBACK_EN))
> +		mac |= L1C_MAC_CTRL_LPBACK_EN;
> +	else
> +		mac &= ~L1C_MAC_CTRL_LPBACK_EN;

Code duplication. Could use loops.

[...]
> +/* RAR, Multicast, VLAN */
> +static int alc_set_mac_addr(struct alx_hw *hw, u8 *addr)
> +{
> +	u32 sta;
> +
> +	/*
> +	 * for example: 00-0B-6A-F6-00-DC
> +	 * 0<-->6AF600DC, 1<-->000B.
> +	 */
> +
> +	/* low dword */
> +	sta = (((u32)addr[2]) << 24) | (((u32)addr[3]) << 16) |
> +	      (((u32)addr[4]) << 8)  | (((u32)addr[5])) ;

Useless casts.

[...]
> +static int alc_config_tx(struct alx_hw *hw)
> +{
> +	return 0;
> +}

al{fc}_config_tx always return 0.

So do al{fc}_config_mac_ctrl, _set_mac_addr, _get_ethtool_regs and
surely a few others.

[...]
> +int alc_init_hw_callbacks(struct alx_hw *hw)
> +{
> +	/* NIC */
> +	hw->cbs.identify_nic   = &alc_identify_nic;
> +	/* MAC*/
> +	hw->cbs.reset_mac      = &alc_reset_mac;
> +	hw->cbs.start_mac      = &alc_start_mac;
> +	hw->cbs.stop_mac       = &alc_stop_mac;
> +	hw->cbs.config_mac     = &alc_config_mac;
> +	hw->cbs.get_mac_addr   = &alc_get_mac_addr;
> +	hw->cbs.set_mac_addr   = &alc_set_mac_addr;
> +	hw->cbs.set_mc_addr    = &alc_set_mc_addr;
> +	hw->cbs.clear_mc_addr  = &alc_clear_mc_addr;
> +
> +	/* PHY */
> +	hw->cbs.init_phy          = &alc_init_phy;
> +	hw->cbs.reset_phy         = &alc_reset_phy;
> +	hw->cbs.read_phy_reg      = &alc_read_phy_reg;
> +	hw->cbs.write_phy_reg     = &alc_write_phy_reg;
> +	hw->cbs.check_phy_link    = &alc_check_phy_link;
> +	hw->cbs.setup_phy_link    = &alc_setup_phy_link;
> +	hw->cbs.setup_phy_link_speed = &alc_setup_phy_link_speed;
> +
> +	/* Interrupt */
> +	hw->cbs.ack_phy_intr	= &alc_ack_phy_intr;
> +	hw->cbs.enable_legacy_intr  = &alc_enable_legacy_intr;
> +	hw->cbs.disable_legacy_intr = &alc_disable_legacy_intr;
> +
> +	/* Configure */
> +	hw->cbs.config_tx	= &alc_config_tx;
> +	hw->cbs.config_fc	= &alc_config_fc;
> +	hw->cbs.config_aspm	= &alc_config_aspm;
> +	hw->cbs.config_wol	= &alc_config_wol;
> +	hw->cbs.config_mac_ctrl	= &alc_config_mac_ctrl;
> +	hw->cbs.config_pow_save	= &alc_config_pow_save;
> +	hw->cbs.reset_pcie	= &alc_reset_pcie;
> +
> +	/* NVRam */
> +	hw->cbs.check_nvram	= &alc_check_nvram;
> +	hw->cbs.read_nvram	= &alc_read_nvram;
> +	hw->cbs.write_nvram	= &alc_write_nvram;
> +
> +	/* Others */
> +	hw->cbs.get_ethtool_regs = alc_get_ethtool_regs;

Two alc nics, twice the size ? Mildly efficient.

[...]
> diff --git a/drivers/net/ethernet/atheros/alx/alc_hw.c b/drivers/net/ethernet/atheros/alx/alc_hw.c
> new file mode 100644
> index 0000000..b0eb72c
> --- /dev/null
> +++ b/drivers/net/ethernet/atheros/alx/alc_hw.c
[...]
> +u16 l1c_reset_phy(struct alx_hw *hw, bool pws_en, bool az_en, bool ptp_en)
> +{
> +	u32 val;
> +	u16 i, phy_val;
> +
> +	ptp_en = ptp_en;
> +
> +	/* reset PHY core */
> +	alx_mem_r32(hw, L1C_PHY_CTRL, &val);
> +	val &= ~(L1C_PHY_CTRL_DSPRST_OUT | L1C_PHY_CTRL_IDDQ |
> +		 L1C_PHY_CTRL_GATE_25M | L1C_PHY_CTRL_POWER_DOWN |
> +		 L1C_PHY_CTRL_CLS);
> +	val |= L1C_PHY_CTRL_RST_ANALOG;
> +
> +	if (pws_en)
> +		val |= (L1C_PHY_CTRL_HIB_PULSE | L1C_PHY_CTRL_HIB_EN);
> +	else
> +		val &= ~(L1C_PHY_CTRL_HIB_PULSE | L1C_PHY_CTRL_HIB_EN);
> +
> +	alx_mem_w32(hw, L1C_PHY_CTRL, val);
> +	udelay(10); /* 5us is enough */
> +	alx_mem_w32(hw, L1C_PHY_CTRL, val | L1C_PHY_CTRL_DSPRST_OUT);
> +
> +	/* delay 800us */
> +	for (i = 0; i < L1C_PHY_CTRL_DSPRST_TO; i++)
> +		udelay(10);
> +
> +	/* switch clock */
> +	if (hw->pci_devid == L2CB_DEV_ID) {
> +		l1c_read_phydbg(hw, true, L1C_MIIDBG_CFGLPSPD, &phy_val);
> +		/* clear bit13 */
> +		l1c_write_phydbg(hw, true, L1C_MIIDBG_CFGLPSPD,
> +				 phy_val & ~L1C_CFGLPSPD_RSTCNT_CLK125SW);
> +	}
> +
> +	/* fix tx-half-amp issue */
> +	if (hw->pci_devid == L2CB_DEV_ID || hw->pci_devid == L2CB2_DEV_ID) {
> +		l1c_read_phydbg(hw, true, L1C_MIIDBG_CABLE1TH_DET, &phy_val);
> +		l1c_write_phydbg(hw, true, L1C_MIIDBG_CABLE1TH_DET,
> +				 phy_val | L1C_CABLE1TH_DET_EN); /* set bit15 */
> +	}
> +
> +	if (pws_en) {
> +		/* clear bit[3] of debugport 3B to 0,
> +		 * lower voltage to save power */
> +		if (hw->pci_devid == L2CB_DEV_ID ||
> +		    hw->pci_devid == L2CB2_DEV_ID) {
> +			l1c_read_phydbg(hw, true, L1C_MIIDBG_VOLT_CTRL,
> +					&phy_val);
> +			l1c_write_phydbg(hw, true, L1C_MIIDBG_VOLT_CTRL,
> +					 phy_val & ~L1C_VOLT_CTRL_SWLOWEST);
> +		}
> +		/* power saving config */
> +		l1c_write_phydbg(hw, true, L1C_MIIDBG_LEGCYPS,
> +				 (hw->pci_devid == L1D_DEV_ID ||
> +				  hw->pci_devid == L1D2_DEV_ID) ?
> +				 L1D_LEGCYPS_DEF : L1C_LEGCYPS_DEF);
> +		/* hib */
> +		l1c_write_phydbg(hw, true, L1C_MIIDBG_SYSMODCTRL,
> +				 L1C_SYSMODCTRL_IECHOADJ_DEF);
> +	} else {
> +		/*dis powersaving */
> +		l1c_read_phydbg(hw, true, L1C_MIIDBG_LEGCYPS, &phy_val);
> +		l1c_write_phydbg(hw, true, L1C_MIIDBG_LEGCYPS,
> +				 phy_val & ~L1C_LEGCYPS_EN);
> +		/* disable hibernate */
> +		l1c_read_phydbg(hw, true, L1C_MIIDBG_HIBNEG, &phy_val);
> +		l1c_write_phydbg(hw, true, L1C_MIIDBG_HIBNEG,
> +				 phy_val & ~L1C_HIBNEG_PSHIB_EN);
> +	}
> +
> +	/* az is only for l2cbv2 / l1dv1 /l1dv2 */
> +	if (hw->pci_devid == L1D_DEV_ID ||
> +	    hw->pci_devid == L1D2_DEV_ID ||
> +	    hw->pci_devid == L2CB2_DEV_ID) {

If it's chipset specific, why not take it elsewhere...

> +		if (az_en) {
> +			switch (hw->pci_devid) {
> +			case L2CB2_DEV_ID:
[...]
> +			case L1D2_DEV_ID:
> +				l1c_write_phydbg(hw, true,
> +						 L1C_MIIDBG_AZ_ANADECT,
> +						 L1C_AZ_ANADECT_DEF);
> +				phy_val = hw->long_cable ? L1C_CLDCTRL3_L1D :
> +					  (L1C_CLDCTRL3_L1D &
> +					   ~L1C_CLDCTRL3_BP_CABLE1TH_DET_GT);
> +				l1c_write_phy(hw, true, L1C_MIIEXT_PCS, true,
> +					      L1C_MIIEXT_CLDCTRL3, phy_val);
> +				l1c_write_phy(hw, true, L1C_MIIEXT_PCS, true,
> +					      L1C_MIIEXT_AZCTRL,
> +					      L1C_AZCTRL_L1D);
> +				l1c_write_phy(hw, true, L1C_MIIEXT_PCS, true,
> +					      L1C_MIIEXT_AZCTRL2,
> +					      L1C_AZCTRL2_L1D2);
> +				l1c_write_phy(hw, true, L1C_MIIEXT_PCS, true,
> +					      L1C_MIIEXT_AZCTRL6,
> +					      L1C_AZCTRL6_L1D2);

... and shift this stuff back to the left.

[...]
> +u16 l1c_reset_pcie(struct alx_hw *hw, bool l0s_en, bool l1_en)
> +{
> +	u32 val;
> +	u16 val16;
> +	u16 ret;
> +
> +	/* Workaround for PCI problem when BIOS sets MMRBC incorrectly. */
> +	alx_cfg_r16(hw, PCI_COMMAND, &val16);
> +	if ((val16 & (PCI_COMMAND_IO |
> +		      PCI_COMMAND_MEMORY |
> +		      PCI_COMMAND_MASTER)) == 0 ||
> +	    (val16 & PCI_COMMAND_INTX_DISABLE) != 0) {
> +		val16 = (u16)((val16 | (PCI_COMMAND_IO |
> +					PCI_COMMAND_MEMORY |
> +					PCI_COMMAND_MASTER))
> +			      & ~PCI_COMMAND_INTX_DISABLE);
> +		alx_cfg_w16(hw, PCI_COMMAND, val16);
> +	}

	u16 cmd;

#define ALX_PCI_CMD (PCI_COMMAND_IO | PCI_COMMAND_MEMORY | PCI_COMMAND_MASTER)

	alx_cfg_r16(hw, PCI_COMMAND, &cmd);
	if (!(cmd & ALX_PCI_CMD) || (cmd & PCI_COMMAND_INTX_DISABLE)) {
		cmd = (cmd | ALX_PCI_CMD) & ~PCI_COMMAND_INTX_DISABLE;
		alx_cfg_w16(hw, PCI_COMMAND, cmd);
	}

[...]
> +u16 l1c_enable_mac(struct alx_hw *hw, bool en, u16 en_ctrl)
> +{
> +	u32 rxq, txq, mac, val;
> +	u16 i;
> +
> +	alx_mem_r32(hw, L1C_RXQ0, &rxq);
> +	alx_mem_r32(hw, L1C_TXQ0, &txq);
> +	alx_mem_r32(hw, L1C_MAC_CTRL, &mac);
> +
> +	if (en) { /* enable */
> +		alx_mem_w32(hw, L1C_RXQ0, rxq | L1C_RXQ0_EN);
> +		alx_mem_w32(hw, L1C_TXQ0, txq | L1C_TXQ0_EN);
> +		if ((en_ctrl & LX_MACSPEED_1000) != 0) {
> +			FIELD_SETL(mac, L1C_MAC_CTRL_SPEED,
> +				   L1C_MAC_CTRL_SPEED_1000);
> +		} else {
> +			FIELD_SETL(mac, L1C_MAC_CTRL_SPEED,
> +				   L1C_MAC_CTRL_SPEED_10_100);
> +		}

		speed = (en_ctrl & LX_MACSPEED_1000) ?
			L1C_MAC_CTRL_SPEED_1000 : L1C_MAC_CTRL_SPEED_10_100;

		FIELD_SETL(mac, L1C_MAC_CTRL_SPEED(speed);
> +
> +		test_set_or_clear(mac, en_ctrl, LX_MACDUPLEX_FULL,
> +				  L1C_MAC_CTRL_FULLD);
> +
> +		/* rx filter */
> +		test_set_or_clear(mac, en_ctrl, LX_FLT_PROMISC,
> +				  L1C_MAC_CTRL_PROMISC_EN);
> +		test_set_or_clear(mac, en_ctrl, LX_FLT_MULTI_ALL,
> +				  L1C_MAC_CTRL_MULTIALL_EN);
> +		test_set_or_clear(mac, en_ctrl, LX_FLT_BROADCAST,
> +				  L1C_MAC_CTRL_BRD_EN);
> +		test_set_or_clear(mac, en_ctrl, LX_FLT_DIRECT,
> +				  L1C_MAC_CTRL_RX_EN);
> +		test_set_or_clear(mac, en_ctrl, LX_FC_TXEN,
> +				  L1C_MAC_CTRL_TXFC_EN);
> +		test_set_or_clear(mac, en_ctrl, LX_FC_RXEN,
> +				  L1C_MAC_CTRL_RXFC_EN);
> +		test_set_or_clear(mac, en_ctrl, LX_VLAN_STRIP,
> +				  L1C_MAC_CTRL_VLANSTRIP);
> +		test_set_or_clear(mac, en_ctrl, LX_LOOPBACK,
> +				  L1C_MAC_CTRL_LPBACK_EN);
> +		test_set_or_clear(mac, en_ctrl, LX_SINGLE_PAUSE,
> +				  L1C_MAC_CTRL_SPAUSE_EN);
> +		test_set_or_clear(mac, en_ctrl, LX_ADD_FCS,
> +				  (L1C_MAC_CTRL_PCRCE | L1C_MAC_CTRL_CRCE));

Loop.

(test_set_or_clear is a macro => code bloat)

[...]
> diff --git a/drivers/net/ethernet/atheros/alx/alx.h b/drivers/net/ethernet/atheros/alx/alx.h
> new file mode 100644
> index 0000000..6482bee
> --- /dev/null
> +++ b/drivers/net/ethernet/atheros/alx/alx.h
[...]
> +#define ALX_VLAN_TO_TAG(_vlan, _tag) \
> +	do { \
> +		_tag =  ((((_vlan) >> 8) & 0xFF) | (((_vlan) & 0xFF) << 8)); \
> +	} while (0)
> +
> +#define ALX_TAG_TO_VLAN(_tag, _vlan) \
> +	do { \
> +		_vlan = ((((_tag) >> 8) & 0xFF) | (((_tag) & 0xFF) << 8)) ; \
> +	} while (0)


It should be a real inline function.

> +
> +/* Coalescing Message Block */
> +struct coals_msg_block {
> +	int test;
> +};
> +
> +
> +#define BAR_0   0
> +
> +#define ALX_DEF_RX_BUF_SIZE	1536
> +#define ALX_MAX_JUMBO_PKT_SIZE	(9*1024)
> +#define ALX_MAX_TSO_PKT_SIZE	(7*1024)
> +
> +#define ALX_MAX_ETH_FRAME_SIZE	ALX_MAX_JUMBO_PKT_SIZE
> +#define ALX_MIN_ETH_FRAME_SIZE	68
> +
> +
> +#define ALX_MAX_RX_QUEUES	8
> +#define ALX_MAX_TX_QUEUES	4
> +#define ALX_MAX_HANDLED_INTRS	5
> +
> +#define ALX_WATCHDOG_TIME   (5 * HZ)
> +
> +struct alx_cmb {
> +	char name[IFNAMSIZ + 9];
> +	void *cmb;
> +	dma_addr_t dma;
> +};
> +struct alx_smb {
> +	char name[IFNAMSIZ + 9];
> +	void *smb;
> +	dma_addr_t dma;
> +};

What are these 'name' fields for ?

> +
> +
> +/*
> + * RRD : definition
> + */
> +
> +/* general parameter format of rrd */
> +struct alx_rrdes_general {
> +	u32 xsum:16;
> +	u32 nor:4;  /* number of RFD */
> +	u32 si:12;  /* start index of rfd-ring */

Bitfields are mildly welcome to say the least.

[...]
> diff --git a/drivers/net/ethernet/atheros/alx/alx_ethtool.c b/drivers/net/ethernet/atheros/alx/alx_ethtool.c
> new file mode 100644
> index 0000000..c044133
> --- /dev/null
> +++ b/drivers/net/ethernet/atheros/alx/alx_ethtool.c
[...]
> +#ifdef ETHTOOL_OPS_COMPAT
> +#include "alx_compat_ethtool.c"
> +#endif

This should go.

> +
> +
> +static int alx_get_settings(struct net_device *netdev,
> +			    struct ethtool_cmd *ecmd)
> +{
> +	struct alx_adapter *adpt = netdev_priv(netdev);
> +	struct alx_hw *hw = &adpt->hw;
> +	u32 link_speed = hw->link_speed;
> +	bool link_up = hw->link_up;
> +
> +	ecmd->supported = (SUPPORTED_10baseT_Half  |
> +			   SUPPORTED_10baseT_Full  |
> +			   SUPPORTED_100baseT_Half |
> +			   SUPPORTED_100baseT_Full |
> +			   SUPPORTED_Autoneg       |
> +			   SUPPORTED_TP);
> +	if (CHK_HW_FLAG(GIGA_CAP))
> +		ecmd->supported |= SUPPORTED_1000baseT_Full;
> +
> +	ecmd->advertising = ADVERTISED_TP;
> +
> +	ecmd->advertising |= ADVERTISED_Autoneg;
> +	ecmd->advertising |= hw->autoneg_advertised;
> +
> +	ecmd->port = PORT_TP;
> +	ecmd->phy_address = 0;
> +	ecmd->autoneg = AUTONEG_ENABLE;
> +	ecmd->transceiver = XCVR_INTERNAL;
> +
> +	if (!in_interrupt()) {

Dead branch. :o(

[...]
> +static int alx_set_settings(struct net_device *netdev,
> +			    struct ethtool_cmd *ecmd)
> +{
> +	struct alx_adapter *adpt = netdev_priv(netdev);
> +	struct alx_hw *hw = &adpt->hw;
> +	u32 advertised, old;
> +	int error = 0;
> +
> +	while (CHK_ADPT_FLAG(1, STATE_RESETTING))
> +		msleep(20);

An upper bound would not hurt.

[...]
> +static void alx_set_msglevel(struct net_device *netdev, u32 data)
> +{
> +	struct alx_adapter *adpt = netdev_priv(netdev);
> +	adpt->msg_enable = data;

Missing empty line.

> +}
> +
> +
> +static int alx_get_regs_len(struct net_device *netdev)
> +{
> +	struct alx_adapter *adpt = netdev_priv(netdev);
> +	struct alx_hw *hw = &adpt->hw;
> +	return hw->hwreg_sz * sizeof(32);

Missing empty line.

[...]
> +static void alx_get_drvinfo(struct net_device *netdev,
> +			    struct ethtool_drvinfo *drvinfo)
> +{
> +	struct alx_adapter *adpt = netdev_priv(netdev);
> +
> +	strlcpy(drvinfo->driver,  alx_drv_name, sizeof(drvinfo->driver));
> +	strlcpy(drvinfo->fw_version, "alx", 32);

No random stuff in fw_version.

[...]
> diff --git a/drivers/net/ethernet/atheros/alx/alx_hwcom.h b/drivers/net/ethernet/atheros/alx/alx_hwcom.h
> new file mode 100644
> index 0000000..d3bd2f1
> --- /dev/null
> +++ b/drivers/net/ethernet/atheros/alx/alx_hwcom.h
[...]
> +#define ASHFT31(_x)  ((_x) << 31)
> +#define ASHFT30(_x)  ((_x) << 30)
> +#define ASHFT29(_x)  ((_x) << 29)
> +#define ASHFT28(_x)  ((_x) << 28)
> +#define ASHFT27(_x)  ((_x) << 27)
> +#define ASHFT26(_x)  ((_x) << 26)
> +#define ASHFT25(_x)  ((_x) << 25)
> +#define ASHFT24(_x)  ((_x) << 24)
> +#define ASHFT23(_x)  ((_x) << 23)
> +#define ASHFT22(_x)  ((_x) << 22)
> +#define ASHFT21(_x)  ((_x) << 21)
> +#define ASHFT20(_x)  ((_x) << 20)
> +#define ASHFT19(_x)  ((_x) << 19)
> +#define ASHFT18(_x)  ((_x) << 18)
> +#define ASHFT17(_x)  ((_x) << 17)
> +#define ASHFT16(_x)  ((_x) << 16)
> +#define ASHFT15(_x)  ((_x) << 15)
> +#define ASHFT14(_x)  ((_x) << 14)
> +#define ASHFT13(_x)  ((_x) << 13)
> +#define ASHFT12(_x)  ((_x) << 12)
> +#define ASHFT11(_x)  ((_x) << 11)
> +#define ASHFT10(_x)  ((_x) << 10)
> +#define ASHFT9(_x)   ((_x) << 9)
> +#define ASHFT8(_x)   ((_x) << 8)
> +#define ASHFT7(_x)   ((_x) << 7)
> +#define ASHFT6(_x)   ((_x) << 6)
> +#define ASHFT5(_x)   ((_x) << 5)
> +#define ASHFT4(_x)   ((_x) << 4)
> +#define ASHFT3(_x)   ((_x) << 3)
> +#define ASHFT2(_x)   ((_x) << 2)
> +#define ASHFT1(_x)   ((_x) << 1)
> +#define ASHFT0(_x)   ((_x) << 0)

It does not save much.

[...]
> diff --git a/drivers/net/ethernet/atheros/alx/alx_main.c b/drivers/net/ethernet/atheros/alx/alx_main.c
> new file mode 100644
> index 0000000..a51c608
> --- /dev/null
> +++ b/drivers/net/ethernet/atheros/alx/alx_main.c
[...]
> +int alx_cfg_r16(const struct alx_hw *hw, int reg, u16 *pval)
> +{
> +	if (!(hw && hw->adpt && hw->adpt->pdev))
> +		return -EINVAL;
> +	return pci_read_config_word(hw->adpt->pdev, reg, pval);
> +}
> +
> +
> +int alx_cfg_w16(const struct alx_hw *hw, int reg, u16 val)
> +{
> +	if (!(hw && hw->adpt && hw->adpt->pdev))
> +		return -EINVAL;
> +	return pci_write_config_word(hw->adpt->pdev, reg, val);
> +}

"We don't know the context this code runs from."

[...]
> +static void alx_mem_r16(const struct alx_hw *hw, int reg, u16 *val)
> +{
> +	if (unlikely(!hw->link_up))
> +		readl(hw->hw_addr + reg);
> +	*(u16 *)val = readw(hw->hw_addr + reg);

Useless cast.

[...]
> +void alx_hw_printk(const char *level, const struct alx_hw *hw,
> +		   const char *fmt, ...)
> +{
> +	struct va_format vaf;
> +	va_list args;
> +
> +	va_start(args, fmt);
> +	vaf.fmt = fmt;
> +	vaf.va = &args;
> +
> +	if (hw && hw->adpt && hw->adpt->netdev)
> +		__netdev_printk(level, hw->adpt->netdev, &vaf);
> +	else
> +		printk("%salx_hw: %pV", level, &vaf);
> +
> +	va_end(args);
> +}

Designing a new logging facility smells like being unable to figure
the current context.

And the printk does not even use KERN_... :o(

> +
> +
> +/*
> + *  alx_validate_mac_addr - Validate MAC address
> + */
> +static int alx_validate_mac_addr(u8 *mac_addr)
> +{
> +	int retval = 0;
> +
> +	if (mac_addr[0] & 0x01) {
> +		printk(KERN_DEBUG "MAC address is multicast\n");
> +		retval = -EADDRNOTAVAIL;
> +	} else if (mac_addr[0] == 0xff && mac_addr[1] == 0xff) {
> +		printk(KERN_DEBUG "MAC address is broadcast\n");
> +		retval = -EADDRNOTAVAIL;
> +	} else if (mac_addr[0] == 0 && mac_addr[1] == 0 &&
> +		   mac_addr[2] == 0 && mac_addr[3] == 0 &&
> +		   mac_addr[4] == 0 && mac_addr[5] == 0) {
> +		printk(KERN_DEBUG "MAC address is all zeros\n");
> +		retval = -EADDRNOTAVAIL;
> +	}
> +	return retval;
> +}

Bloat. It should use is_valid_ether_addr.

[...]
> diff --git a/drivers/net/ethernet/atheros/alx/alx_sw.h b/drivers/net/ethernet/atheros/alx/alx_sw.h
> new file mode 100644
> index 0000000..3daa392
> --- /dev/null
> +++ b/drivers/net/ethernet/atheros/alx/alx_sw.h
[...]
> +/* mac address length */
> +#define ALX_ETH_LENGTH_OF_ADDRESS       6

ETH_ALEN

> +#define ALX_ETH_LENGTH_OF_HEADER        ETH_HLEN

:o(

[...]
> +struct alx_hw {
> +	struct alx_adapter	*adpt;
> +	struct alx_hw_callbacks	 cbs;
> +	u8 __iomem     *hw_addr; /* inner register address */
> +	u16             pci_venid;
> +	u16             pci_devid;
> +	u16             pci_sub_devid;
> +	u16             pci_sub_venid;
> +	u8              pci_revid;

/me feels like reading drivers/net/wireless/rtlwifi

The pci_... values are available through the pci_dev struct. They do not
need to be duplicated (especially those that are not used).

> +
> +	bool            long_cable;
> +	bool            aps_en;
> +	bool            hi_txperf;
> +	bool            msi_lnkpatch;
> +	u32             dma_chnl;
> +	u32             hwreg_sz;
> +	u32             eeprom_sz;
> +
> +	/* PHY parameter */
> +	u32             phy_id;
> +	u32             autoneg_advertised;
> +	u32             link_speed;
> +	bool            link_up;
> +	spinlock_t      mdio_lock;
> +
> +	/* MAC parameter */
> +	enum alx_mac_type mac_type;
> +	u8              mac_addr[ALX_ETH_LENGTH_OF_ADDRESS];
> +	u8              mac_perm_addr[ALX_ETH_LENGTH_OF_ADDRESS];
> +
> +	u32             mtu;

What is wrong with net_device.mtu ?

> +	u16             rxstat_reg;
> +	u16             rxstat_sz;
> +	u16             txstat_reg;
> +	u16             txstat_sz;

struct alx_something {
	u16 reg;
	u16 size;
} rxstat, txstat;

> +
> +	u16             tx_prod_reg[4];
> +	u16             tx_cons_reg[4];
> +	u16             rx_prod_reg[2];
> +	u16             rx_cons_reg[2];
> +	u64             tpdma[4];
> +	u64             rfdma[2];
> +	u64             rrdma[2];

Should be dma_addr_t

[...]
> +/* definitions for flags */
> +
> +#define CHK_FLAG_ARRAY(_st, _idx, _type, _flag)	\
> +		((_st)->flags[_idx] & (ALX_##_type##_FLAG_##_idx##_##_flag))
> +#define CHK_FLAG(_st, _type, _flag)	\
> +		((_st)->flags & (ALX_##_type##_FLAG_##_flag))
> +
> +#define SET_FLAG_ARRAY(_st, _idx, _type, _flag) \
> +		((_st)->flags[_idx] |= (ALX_##_type##_FLAG_##_idx##_##_flag))
> +#define SET_FLAG(_st, _type, _flag) \
> +		((_st)->flags |= (ALX_##_type##_FLAG_##_flag))
> +
> +#define CLI_FLAG_ARRAY(_st, _idx, _type, _flag) \
> +		((_st)->flags[_idx] &= ~(ALX_##_type##_FLAG_##_idx##_##_flag))
> +#define CLI_FLAG(_st, _type, _flag) \
> +		((_st)->flags &= ~(ALX_##_type##_FLAG_##_flag))

These macros do not help navigating through the ALX_HW_FLAG_ defines.

-- 
Ueimor
