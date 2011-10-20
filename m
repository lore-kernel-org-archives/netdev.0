From: "Ren, Cloud" <cjren@qca.qualcomm.com>
Subject: RE: [patch net-next]alx: Atheros AR8131/AR8151/AR8152/AR8161
 Ethernet driver
Date: Thu, 20 Oct 2011 07:29:27 +0000
Message-ID: <6349D7A510622448B1BA0967850A8438011CC12D@nasanexd02d.na.qualcomm.com>
References: <1319009213-20627-1-git-send-email-cloud.ren@atheros.com>
 <20111019222140.GA9937@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"Rodriguez, Luis" <rodrigue@qca.qualcomm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:24625 "EHLO
	wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754387Ab1JTH33 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 03:29:29 -0400
In-Reply-To: <20111019222140.GA9937@electric-eye.fr.zoreil.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for your information.

Drivers on different OSs share alf_hw.c, alf_hw.h, alc_hw.c and alc_hw.h

So it looks some of codes are duplicate, because other drivers need them.


-----Original Message-----
From: Francois Romieu [mailto:romieu@fr.zoreil.com] 
Sent: Thursday, October 20, 2011 6:22 AM
To: Ren, Cloud
Cc: davem@davemloft.net; Rodriguez, Luis; netdev@vger.kernel.org; linux-kernel@vger.kernel.org
Subject: Re: [patch net-next]alx: Atheros AR8131/AR8151/AR8152/AR8161 Ethernet driver

cloud.ren@atheros.com <cloud.ren@atheros.com> :
> diff --git a/drivers/net/ethernet/atheros/alx/alc_cb.c 
> b/drivers/net/ethernet/atheros/alx/alc_cb.c
[...]
> +int alc_read_phy_reg(struct alx_hw *hw, u32 device_type,
> +		     u16 reg_addr, u16 *phy_data)
> +{
> +	bool fast = false;
> +	bool ext = false;
> +	u16 error;
> +	int retval = 0;
> +
> +	ALX_MDIO_LOCK(&hw->mdio_lock);

Frowned upon / useless wrapper. 

> +
> +	if (device_type != ALX_MDIO_NORM_DEV)
> +		ext = true;

This method seems to be always called with device_type = ALX_MDIO_NORM_DEV.

> +
> +	error = l1c_read_phy(hw, ext, device_type, fast,
> +			     reg_addr, phy_data);

Imho the driver wants something like l1c_read_phy_{fast/slow}.

> +	if (error) {
> +		HW_PRINT(ERR, "Error when reading phy reg (%d).", error);
> +		retval = ALX_ERR_PHY_READ_REG;

I am a bit sceptical that private error codes are really useful in a mundane ethernet driver.

[...]
> +int alc_write_phy_reg(struct alx_hw *hw, u32 device_type,
> +		      u16 reg_addr, u16 phy_data)
> +{
> +	bool fast = false;
> +	bool ext = false;
> +	u16 error;
> +	int retval = 0;
> +
> +	ALX_MDIO_LOCK(&hw->mdio_lock);
> +
> +	if (device_type != ALX_MDIO_NORM_DEV)
> +		ext = true;

This method seems to be always called with device_type = ALX_MDIO_NORM_DEV.

> +
> +	error = l1c_write_phy(hw, ext, device_type, fast,
> +			      reg_addr, phy_data);

It fits in a single 80 columns line.

[...]
> +int alc_init_phy(struct alx_hw *hw)
> +{
> +	u16 phy_id[2];
> +	int retval = 0;

Useless init.

> +
> +	HW_PRINT(DEBUG, "ENTER\n");

Old school.

> +
> +	/* 1. init mdio spin lock */
> +	ALX_MDIO_LOCK_INIT(&hw->mdio_lock);

The comment adds no value.

> +
> +	/* 2. read phy id */
> +	retval = alc_read_phy_reg(hw, ALX_MDIO_NORM_DEV,
> +				  L1C_MII_PHYSID1, &phy_id[0]);

Sic.

> +	if (retval)
> +		return retval;
> +	retval = alc_read_phy_reg(hw, ALX_MDIO_NORM_DEV,
> +				  L1C_MII_PHYSID1, &phy_id[1]);
> +	if (retval)
> +		return retval;
> +
> +	memcpy(&hw->phy_id, phy_id, sizeof(hw->phy_id));
> +
> +	hw->autoneg_advertised = (ALX_LINK_SPEED_1GB_FULL |
> +				  ALX_LINK_SPEED_10_HALF  |
> +				  ALX_LINK_SPEED_10_FULL  |
> +				  ALX_LINK_SPEED_100_HALF |
> +				  ALX_LINK_SPEED_100_FULL);

Parenthesis abuse.

[...]
> +int alc_ack_phy_intr(struct alx_hw *hw) {
> +	int retval = 0;

Useless init.

> +	u16 isr = 0;
> +
> +	HW_PRINT(DEBUG, "ENTER\n");
> +
> +	retval = alc_read_phy_reg(hw, ALX_MDIO_NORM_DEV,
> +				  L1C_MII_ISR, &isr);
> +	if (retval)
> +		return retval;
> +
> +	return retval;

The style is terrible. What about:

	return alc_read_phy_reg(hw, ALX_MDIO_NORM_DEV, L1C_MII_ISR, &isr);

[...]
> +int alc_clear_mac_addr(struct alx_hw *hw) {
> +	int retval = 0;
> +
> +	HW_PRINT(DEBUG, "ENTER\n");
> +
> +	return retval;
> +}

{alc/alf}_clear_mac_addr always returns 0 and it does not seem to do anything else.

[...]
> +int alc_config_rx(struct alx_hw *hw)
> +{
> +	int retval = 0;
> +	return retval;
> +}

Useless. {alc/alf}_config_rx always returns 0 and it does not anything else.

[...]
> +int alc_check_nvram(struct alx_hw *hw, bool *exist) {
> +	*exist = false;
> +	return 0;
> +}

Strictly identical to alf_check_nvram.

[...]
> +int alc_get_ethtool_regs(struct alx_hw *hw, void *buff) {
> +	u32 *regs = (u32 *)buff;

Useless cast from void.

> +	int retval = 0;
> +
> +	MEM_R32(hw, L1C_LNK_CAP,        &regs[0]);
> +	MEM_R32(hw, L1C_PMCTRL,         &regs[1]);
> +	MEM_R32(hw, L1C_HALFD,          &regs[2]);
> +	MEM_R32(hw, L1C_SLD,            &regs[3]);
> +	MEM_R32(hw, L1C_MASTER,         &regs[4]);
> +	MEM_R32(hw, L1C_MANU_TIMER,     &regs[5]);
> +	MEM_R32(hw, L1C_IRQ_MODU_TIMER, &regs[6]);
> +	MEM_R32(hw, L1C_PHY_CTRL,       &regs[7]);
> +	MEM_R32(hw, L1C_LNK_CTRL,       &regs[8]);
> +	MEM_R32(hw, L1C_MAC_STS,        &regs[9]);
> +
> +	MEM_R32(hw, L1C_MDIO,      &regs[10]);
> +	MEM_R32(hw, L1C_SERDES,    &regs[11]);
> +	MEM_R32(hw, L1C_MAC_CTRL,  &regs[12]);
> +	MEM_R32(hw, L1C_GAP,       &regs[13]);
> +	MEM_R32(hw, L1C_STAD0,     &regs[14]);
> +	MEM_R32(hw, L1C_STAD1,     &regs[15]);
> +	MEM_R32(hw, L1C_HASH_TBL0, &regs[16]);
> +	MEM_R32(hw, L1C_HASH_TBL1, &regs[17]);
> +	MEM_R32(hw, L1C_RXQ0,      &regs[18]);
> +	MEM_R32(hw, L1C_RXQ1,      &regs[19]);
> +
> +	MEM_R32(hw, L1C_RXQ2, &regs[20]);
> +	MEM_R32(hw, L1C_RXQ3, &regs[21]);
> +	MEM_R32(hw, L1C_TXQ0, &regs[22]);
> +	MEM_R32(hw, L1C_TXQ1, &regs[23]);
> +	MEM_R32(hw, L1C_TXQ2, &regs[24]);
> +	MEM_R32(hw, L1C_MTU,  &regs[25]);
> +	MEM_R32(hw, L1C_WOL0, &regs[26]);
> +	MEM_R32(hw, L1C_WOL1, &regs[27]);
> +	MEM_R32(hw, L1C_WOL2, &regs[28]);

Tabulate and save code ?

[...]
> diff --git a/drivers/net/ethernet/atheros/alx/alc_hw.h 
> b/drivers/net/ethernet/atheros/alx/alc_hw.h
> --- /dev/null
> +++ b/drivers/net/ethernet/atheros/alx/alc_hw.h
[...]
> +#ifdef __cplusplus
> +extern "C" {
> +#endif/*__cplusplus*/

Please remove this stuff before it gets noticed.

[...]
> +#define L1C_PCI_CMD                     0x0004  /* 16bit */
> +#define L1C_PCI_CMD_DISINT              BIT_10S
> +#define L1C_PCI_CMD_MASTEREN            BIT_2S
> +#define L1C_PCI_CMD_MEMEN               BIT_1S
> +#define L1C_PCI_CMD_IOEN                BIT_0S

Duplicates from <linux/pci_regs.h>

[...]
> +/********************* PHY regs definition 
> +***************************/
> +
> +/* PHY Control Register */
> +#define L1C_MII_BMCR                        0x00
> +#define L1C_BMCR_SPEED_SELECT_MSB           0x0040
> +#define L1C_BMCR_COLL_TEST_ENABLE           0x0080
> +#define L1C_BMCR_FULL_DUPLEX                0x0100
> +#define L1C_BMCR_RESTART_AUTO_NEG           0x0200
> +#define L1C_BMCR_ISOLATE                    0x0400
> +#define L1C_BMCR_POWER_DOWN                 0x0800
> +#define L1C_BMCR_AUTO_NEG_EN                0x1000
> +#define L1C_BMCR_SPEED_SELECT_LSB           0x2000
> +#define L1C_BMCR_LOOPBACK                   0x4000
> +#define L1C_BMCR_RESET                      0x8000
> +#define L1C_BMCR_SPEED_MASK                 0x2040
> +#define L1C_BMCR_SPEED_1000                 0x0040
> +#define L1C_BMCR_SPEED_100                  0x2000
> +#define L1C_BMCR_SPEED_10                   0x0000

Please use existing #define from <linux/mii.h>.

> +
> +/* PHY Status Register */
> +#define L1C_MII_BMSR                        0x01
> +#define L1C_BMSR_EXTENDED_CAPS              0x0001
> +#define L1C_BMSR_JABBER_DETECT              0x0002
> +#define L1C_BMSR_LINK_STATUS                0x0004
> +#define L1C_BMSR_AUTONEG_CAPS               0x0008
> +#define L1C_BMSR_REMOTE_FAULT               0x0010
> +#define L1C_BMSR_AUTONEG_COMPLETE           0x0020
> +#define L1C_BMSR_PREAMBLE_SUPPRESS          0x0040
> +#define L1C_BMSR_EXTENDED_STATUS            0x0100
> +#define L1C_BMSR_100T2_HD_CAPS              0x0200
> +#define L1C_BMSR_100T2_FD_CAPS              0x0400
> +#define L1C_BMSR_10T_HD_CAPS                0x0800
> +#define L1C_BMSR_10T_FD_CAPS                0x1000
> +#define L1C_BMSR_100X_HD_CAPS               0x2000
> +#define L1C_BMMII_SR_100X_FD_CAPS           0x4000
> +#define L1C_BMMII_SR_100T4_CAPS             0x8000

Sic.

[...]
> diff --git a/drivers/net/ethernet/atheros/alx/alf_cb.c 
> b/drivers/net/ethernet/atheros/alx/alf_cb.c
> --- /dev/null
> +++ b/drivers/net/ethernet/atheros/alx/alf_cb.c
[...]
> +int alf_get_ethtool_regs(struct alx_hw *hw, void *buff) {
> +	u32 *regs = (u32 *)buff;
> +	int i;
> +	int retval = 0;
> +
> +	MEM_R32(hw, L1F_PM_CSR,     &regs[0]);
> +	MEM_R32(hw, L1F_DEV_CAP,    &regs[1]);
> +	MEM_R32(hw, L1F_DEV_CTRL,   &regs[2]);
> +	MEM_R32(hw, L1F_LNK_CAP,    &regs[3]);
> +	MEM_R32(hw, L1F_LNK_CTRL,   &regs[4]);
> +	MEM_R32(hw, L1F_UE_SVRT,    &regs[5]);
> +	MEM_R32(hw, L1F_EFLD,       &regs[6]);
> +	MEM_R32(hw, L1F_SLD,        &regs[7]);
> +	MEM_R32(hw, L1F_PPHY_MISC1, &regs[8]);
> +	MEM_R32(hw, L1F_PPHY_MISC2, &regs[9]);
> +
> +	MEM_R32(hw, L1F_PDLL_TRNS1,   &regs[10]);
> +	MEM_R32(hw, L1F_TLEXTN_STATS, &regs[11]);
> +	MEM_R32(hw, L1F_EFUSE_CTRL,   &regs[12]);
> +	MEM_R32(hw, L1F_EFUSE_DATA,   &regs[13]);
> +	MEM_R32(hw, L1F_SPI_OP1,      &regs[14]);
> +	MEM_R32(hw, L1F_SPI_OP2,      &regs[15]);
> +	MEM_R32(hw, L1F_SPI_OP3,      &regs[16]);
> +	MEM_R32(hw, L1F_EF_CTRL,      &regs[17]);
> +	MEM_R32(hw, L1F_EF_ADDR,      &regs[18]);
> +	MEM_R32(hw, L1F_EF_DATA,      &regs[19]);
> +
> +	MEM_R32(hw, L1F_SPI_ID,         &regs[20]);
> +	MEM_R32(hw, L1F_SPI_CFG_START,  &regs[21]);
> +	MEM_R32(hw, L1F_PMCTRL,         &regs[22]);
> +	MEM_R32(hw, L1F_LTSSM_CTRL,     &regs[23]);
> +	MEM_R32(hw, L1F_MASTER,         &regs[24]);
> +	MEM_R32(hw, L1F_MANU_TIMER,     &regs[25]);
> +	MEM_R32(hw, L1F_IRQ_MODU_TIMER, &regs[26]);
> +	MEM_R32(hw, L1F_PHY_CTRL,       &regs[27]);
> +	MEM_R32(hw, L1F_MAC_STS,        &regs[28]);
> +	MEM_R32(hw, L1F_MDIO,           &regs[29]);
> +
> +	MEM_R32(hw, L1F_MDIO_EXTN,   &regs[30]);
> +	MEM_R32(hw, L1F_PHY_STS,     &regs[31]);
> +	MEM_R32(hw, L1F_BIST0,       &regs[32]);
> +	MEM_R32(hw, L1F_BIST1,       &regs[33]);
> +	MEM_R32(hw, L1F_SERDES,      &regs[34]);
> +	MEM_R32(hw, L1F_LED_CTRL,    &regs[35]);
> +	MEM_R32(hw, L1F_LED_PATN,    &regs[36]);
> +	MEM_R32(hw, L1F_LED_PATN2,   &regs[37]);
> +	MEM_R32(hw, L1F_SYSALV,      &regs[38]);
> +	MEM_R32(hw, L1F_PCIERR_INST, &regs[39]);
> +
> +	MEM_R32(hw, L1F_LPI_DECISN_TIMER, &regs[40]);
> +	MEM_R32(hw, L1F_LPI_CTRL,         &regs[41]);
> +	MEM_R32(hw, L1F_LPI_WAIT,         &regs[42]);
> +	MEM_R32(hw, L1F_HRTBT_VLAN,       &regs[43]);
> +	MEM_R32(hw, L1F_HRTBT_CTRL,       &regs[44]);
> +	MEM_R32(hw, L1F_RXPARSE,          &regs[45]);
> +	MEM_R32(hw, L1F_MAC_CTRL,         &regs[46]);
> +	MEM_R32(hw, L1F_GAP,              &regs[47]);
> +	MEM_R32(hw, L1F_STAD1,            &regs[48]);
> +	MEM_R32(hw, L1F_LED_CTRL,         &regs[49]);
> +
> +	MEM_R32(hw, L1F_HASH_TBL0, &regs[50]);
> +	MEM_R32(hw, L1F_HASH_TBL1, &regs[51]);
> +	MEM_R32(hw, L1F_HALFD,     &regs[52]);
> +	MEM_R32(hw, L1F_DMA,       &regs[53]);
> +	MEM_R32(hw, L1F_WOL0,      &regs[54]);
> +	MEM_R32(hw, L1F_WOL1,      &regs[55]);
> +	MEM_R32(hw, L1F_WOL2,      &regs[56]);
> +	MEM_R32(hw, L1F_WRR,       &regs[57]);
> +	MEM_R32(hw, L1F_HQTPD,     &regs[58]);
> +	MEM_R32(hw, L1F_CPUMAP1,   &regs[59]);
> +	MEM_R32(hw, L1F_CPUMAP2,   &regs[60]);
> +	MEM_R32(hw, L1F_MISC,      &regs[61]);

You ought to iterate with a well chosen data structure so as to avoid this huge code pollution.

[...]
> +int alf_init_hw_callbacks(struct alx_hw *hw) {
> +	int retval = 0;
> +
> +	/* NIC */
> +	hw->cbs.identify_nic   = &alf_identify_nic;
> +	/* MAC */
> +	hw->cbs.reset_mac      = &alf_reset_mac;
> +	hw->cbs.start_mac      = &alf_start_mac;
> +	hw->cbs.stop_mac       = &alf_stop_mac;
> +	hw->cbs.config_mac     = &alf_config_mac;
> +	hw->cbs.get_mac_addr   = &alf_get_mac_addr;
> +	hw->cbs.set_mac_addr   = &alf_set_mac_addr;
> +	hw->cbs.clear_mac_addr = &alf_clear_mac_addr;
> +	hw->cbs.set_mc_addr    = &alf_set_mc_addr;
> +	hw->cbs.clear_mc_addr  = &alf_clear_mc_addr;
> +
> +	/* PHY */
> +	hw->cbs.init_phy       = &alf_init_phy;
> +	hw->cbs.reset_phy      = &alf_reset_phy;
> +	hw->cbs.read_phy_reg   = &alf_read_phy_reg;
> +	hw->cbs.write_phy_reg  = &alf_write_phy_reg;
> +	hw->cbs.check_phy_link = &alf_check_phy_link;
> +	hw->cbs.setup_phy_link = &alf_setup_phy_link;
> +	hw->cbs.setup_phy_link_speed = &alf_setup_phy_link_speed;
> +
> +	/* Interrupt */
> +	hw->cbs.ack_phy_intr		= &alf_ack_phy_intr;
> +	hw->cbs.enable_legacy_intr	= &alf_enable_legacy_intr;
> +	hw->cbs.disable_legacy_intr	= &alf_disable_legacy_intr;
> +	hw->cbs.enable_msix_intr	= &alf_enable_msix_intr;
> +	hw->cbs.disable_msix_intr	= &alf_disable_msix_intr;
> +
> +	/* Configure */
> +	hw->cbs.config_rx	= &alf_config_rx;
> +	hw->cbs.config_tx	= &alf_config_tx;
> +	hw->cbs.config_fc	= &alf_config_fc;
> +	hw->cbs.config_rss	= &alf_config_rss;
> +	hw->cbs.config_msix	= &alf_config_msix;
> +	hw->cbs.config_wol	= &alf_config_wol;
> +	hw->cbs.config_aspm	= &alf_config_aspm;
> +	hw->cbs.config_mac_ctrl	= &alf_config_mac_ctrl;
> +	hw->cbs.config_pow_save	= &alf_config_pow_save;
> +	hw->cbs.reset_pcie	= &alf_reset_pcie;
> +
> +	/* NVRam */
> +	hw->cbs.check_nvram	= &alf_check_nvram;
> +
> +	/* Others */
> +	hw->cbs.get_ethtool_regs = alf_get_ethtool_regs;
> +
> +	retval = alf_set_hw_capabilities(hw);
> +
> +	retval = alf_set_hw_infos(hw);
> +
> +	/* print hw flags */
> +	HW_PRINT(INFO, "HW Flags = 0x%x\n", hw->flags);
> +	return retval;

Almost every method in this file ought to be static.

[...]
> diff --git a/drivers/net/ethernet/atheros/alx/alf_hw.c 
> b/drivers/net/ethernet/atheros/alx/alf_hw.c
> --- /dev/null
> +++ b/drivers/net/ethernet/atheros/alx/alf_hw.c
[...]
> +/* disable/enable MAC/RXQ/TXQ
> + * en
> + *    true:enable
> + *    false:disable
> + * return
> + *    0:success
> + *    non-0-fail
> + */
> +u16 l1f_enable_mac(PETHCONTEXT ctx, bool en, u16 en_ctrl)

The name of this method is rather poor.

> +{
> +	u32 rxq, txq, mac, val;
> +	u16 i;
> +
> +	MEM_R32(ctx, L1F_RXQ0, &rxq);
> +	MEM_R32(ctx, L1F_TXQ0, &txq);
> +	MEM_R32(ctx, L1F_MAC_CTRL, &mac);
> +
> +	if (en) { /* enable */
> +		MEM_W32(ctx, L1F_RXQ0, rxq | L1F_RXQ0_EN);
> +		MEM_W32(ctx, L1F_TXQ0, txq | L1F_TXQ0_EN);
> +		if (0 != (en_ctrl & LX_MACSPEED_1000)) {
> +			FIELD_SETL(mac, L1F_MAC_CTRL_SPEED,
> +			    L1F_MAC_CTRL_SPEED_1000);
> +		} else {
> +			FIELD_SETL(mac, L1F_MAC_CTRL_SPEED,
> +			    L1F_MAC_CTRL_SPEED_10_100);
> +		}
> +		if (0 != (en_ctrl & LX_MACDUPLEX_FULL)) {
> +			mac |= L1F_MAC_CTRL_FULLD;
> +		} else {
> +			mac &= ~L1F_MAC_CTRL_FULLD;
> +		}
> +		/* rx filter */
> +		if (0 != (en_ctrl & LX_FLT_PROMISC)) {
> +			mac |= L1F_MAC_CTRL_PROMISC_EN;
> +		} else {
> +			mac &= ~L1F_MAC_CTRL_PROMISC_EN;
> +		}
> +		if (0 != (en_ctrl & LX_FLT_MULTI_ALL)) {
> +			mac |= L1F_MAC_CTRL_MULTIALL_EN;
> +		} else {
> +			mac &= ~L1F_MAC_CTRL_MULTIALL_EN;
> +		}
> +		if (0 != (en_ctrl & LX_FLT_BROADCAST)) {
> +			mac |= L1F_MAC_CTRL_BRD_EN;
> +		} else {
> +			mac &= ~L1F_MAC_CTRL_BRD_EN;
> +		}
Code duplication. Who cares ?
> +		if (0 != (en_ctrl & LX_FLT_DIRECT)) {
> +			mac |= L1F_MAC_CTRL_RX_EN;
> +		} else { /* disable all recv if direct not enable */
> +			mac &= ~L1F_MAC_CTRL_RX_EN;
> +		}
> +		if (0 != (en_ctrl & LX_FC_TXEN)) {
> +			mac |= L1F_MAC_CTRL_TXFC_EN;
> +		} else {
> +			mac &= ~L1F_MAC_CTRL_TXFC_EN;
> +		}
<blink>do it</blink>
> +		if (0 != (en_ctrl & LX_FC_RXEN)) {
> +			mac |= L1F_MAC_CTRL_RXFC_EN;
> +		} else {
> +			mac &= ~L1F_MAC_CTRL_RXFC_EN;
> +		}
> +		if (0 != (en_ctrl & LX_VLAN_STRIP)) {
> +			mac |= L1F_MAC_CTRL_VLANSTRIP;
> +		} else {
> +			mac &= ~L1F_MAC_CTRL_VLANSTRIP;
> +		}
Nevermind. 
> +		if (0 != (en_ctrl & LX_LOOPBACK)) {
> +			mac |= (L1F_MAC_CTRL_LPBACK_EN);
> +		} else {
> +			mac &= ~L1F_MAC_CTRL_LPBACK_EN;
> +		}
> +		if (0 != (en_ctrl & LX_SINGLE_PAUSE)) {
> +			mac |= L1F_MAC_CTRL_SPAUSE_EN;
> +		} else {
> +			mac &= ~L1F_MAC_CTRL_SPAUSE_EN;
> +		}
> +		if (0 != (en_ctrl & LX_ADD_FCS)) {
> +			mac |= (L1F_MAC_CTRL_PCRCE | L1F_MAC_CTRL_CRCE);
> +		} else {
> +			mac &= ~(L1F_MAC_CTRL_PCRCE | L1F_MAC_CTRL_CRCE);
> +		}
> +		MEM_W32(ctx, L1F_MAC_CTRL, mac | L1F_MAC_CTRL_TX_EN);

It may make some sense to move these ~60 loc in a xyz_enable_something method...


> +	} else { /* disable mac */

... and this would be the xyz_disable_something counterpart.

[...]
> +u16 l1f_enable_aspm(PETHCONTEXT ctx, bool l0s_en, bool l1_en, u8 
> +lnk_stat) {
> +	u32 pmctrl;
> +	u8 rev = (u8)(FIELD_GETX(ctx->pci_revid, L1F_PCI_REVID));
> +
> +	lnk_stat = lnk_stat;
> +
> +
> +#if 0 /* let sys bios control the L0S/L1 enable/disable */

Don't #if 0. Just remove it.

[...]
> +u16 l1f_write_phy(PETHCONTEXT ctx, bool ext, u8 dev, bool fast,
> +		  u16 reg, u16 data)
> +{
> +	u32 val;
> +	u16 clk_sel, i, ret = 0;
> +
> +#if MAC_TYPE_FPGA == MAC_TYPE
> +	MEM_W32(ctx, L1F_MDIO, 0);
> +	US_DELAY(ctx, 30);
> +	for (i = 0; i < L1F_MDIO_MAX_AC_TO; i++) {
> +		MEM_R32(ctx, L1F_MDIO, &val);
> +		if (0 == (val & L1F_MDIO_BUSY)) {
> +			break;
> +		}
> +		US_DELAY(ctx, 10);
> +	}

I wonder how many times this 'for' loop is duplicated (4x ?).

[...]
> diff --git a/drivers/net/ethernet/atheros/alx/alf_hw.h 
> b/drivers/net/ethernet/atheros/alx/alf_hw.h
> --- /dev/null
> +++ b/drivers/net/ethernet/atheros/alx/alf_hw.h
[...]
> +#ifdef __cplusplus
> +extern "C" {
> +#endif/*__cplusplus*/

Oops.

[...]
> +#define L1F_PCI_CMD                     0x0004  /* 16bit */
> +#define L1F_PCI_CMD_DISINT              BIT_10S
> +#define L1F_PCI_CMD_MASTEREN            BIT_2S
> +#define L1F_PCI_CMD_MEMEN               BIT_1S
> +#define L1F_PCI_CMD_IOEN                BIT_0S

Duplicates <linux/pci_regs.h>

[...]
> diff --git a/drivers/net/ethernet/atheros/alx/alx_ethtool.c 
> b/drivers/net/ethernet/atheros/alx/alx_ethtool.c
> +++ b/drivers/net/ethernet/atheros/alx/alx_ethtool.c
[...]
> +static struct ethtool_ops alx_ethtool_ops = {
> +	.get_settings    = alx_get_settings,
> +	.set_settings    = alx_set_settings,
> +	.get_pauseparam  = alx_get_pauseparam,
> +	.set_pauseparam  = alx_set_pauseparam,
> +	.get_drvinfo     = alx_get_drvinfo,
> +	.get_regs_len    = alx_get_regs_len,
> +	.get_regs        = alx_get_regs,
> +	.get_wol         = alx_get_wol,
> +	.set_wol         = alx_set_wol,
> +	.get_msglevel    = alx_get_msglevel,
> +	.set_msglevel    = alx_set_msglevel,
> +	.nway_reset      = alx_nway_reset,
> +	.get_link        = ethtool_op_get_link,
> +	.get_eeprom_len  = alx_get_eeprom_len,
> +	.get_eeprom      = alx_get_eeprom,
> +	.set_eeprom      = alx_set_eeprom,
> +	.get_tx_csum     = alx_get_tx_csum,
> +	.get_sg          = ethtool_op_get_sg,
> +	.set_sg          = ethtool_op_set_sg,
> +#ifdef NETIF_F_TSO
> +	.get_tso         = ethtool_op_get_tso,
> +#endif

Please switch to ndo_{fix/set}_features.

> diff --git a/drivers/net/ethernet/atheros/alx/alx_hwcom.h 
> b/drivers/net/ethernet/atheros/alx/alx_hwcom.h
> +++ b/drivers/net/ethernet/atheros/alx/alx_hwcom.h
[...]
> +#define LX_SWAP_DW(_x) (\
> +	(((_x) << 24) & 0xFF000000UL) |\
> +	(((_x) <<  8) & 0x00FF0000UL) |\
> +	(((_x) >>  8) & 0x0000FF00UL) |\
> +	(((_x) >> 24) & 0x000000FFUL))
> +
> +#define LX_SWAP_W(_x) (\
> +	(((_x) >> 8) & 0x00FFU) |\
> +	(((_x) << 8) & 0xFF00U))

Duplicates swabXY.

[...]
> +/* interop between drivers */
> +#define LX_DRV_TYPE_MASK                SHIFT27(0x1FUL)
> +#define LX_DRV_TYPE_SHIFT               27
> +#define LX_DRV_TYPE_UNKNOWN             0
> +#define LX_DRV_TYPE_BIOS                1
> +#define LX_DRV_TYPE_BTROM               2
> +#define LX_DRV_TYPE_PKT                 3
> +#define LX_DRV_TYPE_NDS2                4
> +#define LX_DRV_TYPE_UEFI                5
> +#define LX_DRV_TYPE_NDS5                6
> +#define LX_DRV_TYPE_NDS62               7
> +#define LX_DRV_TYPE_NDS63               8
> +#define LX_DRV_TYPE_LNX                 9
> +#define LX_DRV_TYPE_ODI16               10
> +#define LX_DRV_TYPE_ODI32               11
> +#define LX_DRV_TYPE_FRBSD               12
> +#define LX_DRV_TYPE_NTBSD               13
> +#define LX_DRV_TYPE_WCE                 14

No.

[...]
> diff --git a/drivers/net/ethernet/atheros/alx/alx_main.c 
> b/drivers/net/ethernet/atheros/alx/alx_main.c
> --- /dev/null
> +++ b/drivers/net/ethernet/atheros/alx/alx_main.c
[...]
> +static int alx_validate_mac_addr(u8 *mac_addr) {
> +	int retval = 0;
> +
> +	if (mac_addr[0] & 0x01) {
> +		printk(KERN_DEBUG "MAC address is multicast\n");
> +		retval = ALX_ERR_MAC_ADDR;
> +	} else if (mac_addr[0] == 0xff && mac_addr[1] == 0xff) {
> +		printk(KERN_DEBUG "MAC address is broadcast\n");
> +		retval = ALX_ERR_MAC_ADDR;
> +	} else if (mac_addr[0] == 0 && mac_addr[1] == 0 &&
> +		   mac_addr[2] == 0 && mac_addr[3] == 0 &&
> +		   mac_addr[4] == 0 && mac_addr[5] == 0) {
> +		printk(KERN_DEBUG "MAC address is all zeros\n");
> +		retval = ALX_ERR_MAC_ADDR;
> +	}
> +	return retval;
> +}

Please see is_valid_ether_addr, is_broadcast_ether_addr.

[...]
> +static void alx_receive_skb(struct alx_msix_param *msix,
> +			    struct sk_buff *skb,
> +			    u32 vlan_tag, bool vlan_flag)
> +{
> +	struct alx_adapter *adpt = msix->adpt;
> +
> +	if (adpt->vlgrp && vlan_flag) {

This kind of vlan support code is outdated. Please see ndo_{fix/set}_features.

[...]
> +/* alx_alloc_tx_descriptor - allocate Tx Descriptors */ static int 
> +alx_alloc_tx_descriptor(struct alx_adapter *adpt,
> +				   struct alx_tx_queue *txque)
> +{
> +	struct alx_ring_header *ring_header = &adpt->ring_header;
> +	int size;
> +
> +	DRV_PRINT(IF, INFO, "tpq.count = %d\n", txque->tpq.count);
> +
> +	size = sizeof(struct alx_buffer) * txque->tpq.count;
> +	txque->tpq.tpbuff = kzalloc(size, GFP_KERNEL);
> +	if (!txque->tpq.tpbuff)
> +		goto err_alloc_tpq_buffer;
> +	memset(txque->tpq.tpbuff, 0, size);

Useless memset (kZalloc).

> +
> +	/* round up to nearest 4K */
> +	txque->tpq.size = txque->tpq.count * sizeof(struct alx_tpdesc);
> +
> +	txque->tpq.tpdma = ring_header->dma + ring_header->used;
> +	txque->tpq.tpdesc = ring_header->desc + ring_header->used;
> +	adpt->hw.tpdma[txque->que_idx] = (u64)txque->tpq.tpdma;
> +	ring_header->used += ALIGN(txque->tpq.size, 8);
> +
> +	txque->tpq.produce_idx = 0;
> +	txque->tpq.consume_idx = 0;
> +	txque->max_packets = txque->tpq.count;
> +	return 0;
> +
> +err_alloc_tpq_buffer:
> +	kfree(txque->tpq.tpbuff);
> +	txque->tpq.tpbuff = NULL;

txque->tpq.tpbuff is already NULL before the kfree.

[...]
> +static int alx_alloc_rx_descriptor(struct alx_adapter *adpt,
> +				   struct alx_rx_queue *rxque)
> +{
[...]
> +		rxque->rfq.rfbuff = kzalloc(size, GFP_KERNEL);
> +		if (!rxque->rfq.rfbuff)
> +			goto err_alloc_rfq_buffer;
> +		memset(rxque->rfq.rfbuff, 0, size);

kzalloc + useless memset.

[...]
> +	if (CHK_RX_FLAG(SW_QUE)) {
> +		size = sizeof(struct alx_sw_buffer) * rxque->swq.count;
> +		rxque->swq.swbuff = kzalloc(size, GFP_KERNEL);
> +		if (!rxque->swq.swbuff)
> +			goto err_alloc_swq_buffer;
> +		memset(rxque->swq.swbuff, 0, size);
> +
> +		rxque->swq.consume_idx = 0;
> +		rxque->swq.produce_idx = 0;
> +	}
> +
> +	rxque->max_packets = rxque->rrq.count / 2;
> +	return 0;
> +
> +err_alloc_swq_buffer:
> +	kfree(rxque->swq.swbuff);
> +	rxque->swq.swbuff = NULL;

rxque->swq.swbuff is already NULL before the kfree.

[...]
> +static int alx_alloc_all_rtx_descriptor(struct alx_adapter *adpt) {
[...]
> +	ring_header->desc = pci_alloc_consistent(pdev, ring_header->size,
> +				&ring_header->dma);
> +
> +	if (!ring_header->desc) {
> +		DRV_PRINT(IF, ERR, "pci_alloc_consistend failed\n");
> +		retval = -ENOMEM;
> +		goto err_alloc_dma;
> +	}
> +	memset(ring_header->desc, 0, ring_header->size);

- pci_alloc_consistent returns a zeroed area.
- obsolescent. Ought to be dma_alloc_coherent.

[...]
> +#ifdef CONFIG_PM
> +int alx_suspend(struct pci_dev *pdev, pm_message_t state) {
> +	int retval;
> +
> +	retval = alx_shutdown_internal(pdev, state);
> +	if (retval)
> +		return retval;
> +
> +	return 0;

int alx_suspend(struct pci_dev *pdev, pm_message_t state) {
	return alx_shutdown_internal(pdev, state); }


You may consider using device_driver.pm.

[...]
> +netdev_tx_t alx_start_xmit_frames(struct sk_buff *skb,
> +				  struct alx_adapter *adpt,
> +				  struct alx_tx_queue *txque)
> +{
[...]
> +	if (!spin_trylock_irqsave(&adpt->tx_lock, flags)) {
> +		DRV_PRINT(TX, EMERG, "tx locked!\n");
> +		return NETDEV_TX_LOCKED;
> +	}

I am not sure that NETDEV_TX_LOCKED is welcome in new drivers.

> +
> +	if (!alx_check_num_tpdescs(txque, skb)) {
> +		/* no enough descriptor, just stop queue */
> +		netif_stop_queue(adpt->netdev);
> +		spin_unlock_irqrestore(&adpt->tx_lock, flags);
> +		return NETDEV_TX_BUSY;
> +	}

The driver has gone a bridge too far : it should disable the tx queue when it detects that it may not be able to honor the next xmit request.

[...]
> +static int alx_mac_ioctl(struct net_device *netdev,
> +			 struct ifreq *ifr, int cmd)
> +{
[...]
> +	switch (cmd) {
> +	case SIOCDEVGMACREG:

SIOCDEVPRIVATE abuse.

[...]
> +int __devinit alx_init(struct pci_dev *pdev,
> +		       const struct pci_device_id *ent) {
[...]
> +	netdev->base_addr = (unsigned long)adpt->hw.hw_addr;

Use of base_addr ought to be avoided. It's old-fashioned.

[...]
> +	adpt->bd_number = cards_found;

bd_number is never used. Please remove it as well as cards_found.

[...]
> +static void __devexit alx_remove(struct pci_dev *pdev) {
[...]
> +	for (que_idx = 0; que_idx < adpt->num_txques; que_idx++) {
> +		kfree(adpt->tx_queue[que_idx]);
> +		adpt->tx_queue[que_idx] = NULL;
> +	}
> +	for (que_idx = 0; que_idx < adpt->num_rxques; que_idx++) {
> +		kfree(adpt->rx_queue[que_idx]);
> +		adpt->rx_queue[que_idx] = NULL;
> +	}

This is duplicating alx_free_all_rtx_queue.

[...]
> diff --git a/drivers/net/ethernet/atheros/alx/alx_sw.h 
> b/drivers/net/ethernet/atheros/alx/alx_sw.h
> --- /dev/null
> +++ b/drivers/net/ethernet/atheros/alx/alx_sw.h
[...]
> +struct alx_hw {
> +	struct alx_adapter	*adpt;
> +	struct alx_hw_callbacks	 cbs;
> +	u8 __iomem	*hw_addr; /* inner register address */
> +	u16		pci_venid;
> +	u16		pci_devid;
> +	u16		pci_sub_devid;
> +	u16		pci_sub_venid;
> +	u8		pci_revid;

Gross duplication of fields available through adpt->pdev.

[...]
> +	spinlock_t	mdio_lock;
> +	unsigned long	mdio_flags;

Please leave it on the stack, thanks.

[...]
> +typedef struct alx_hw ETHCONTEXT;
> +typedef ETHCONTEXT * PETHCONTEXT;

Please remove the obfuscating typedefs.

[...]
> +/* Error Codes */
> +#define ALX_SUCCESS			0
> +
> +#define ALX_ERR_MAC			-1

Unused.

> +#define ALX_ERR_MAC_INIT		-2
> +#define ALX_ERR_MAC_RESET		-3
> +#define ALX_ERR_MAC_START		-4
> +#define ALX_ERR_MAC_STOP		-5
> +#define ALX_ERR_MAC_CONFIGURE		-6
> +#define ALX_ERR_MAC_ADDR		-7
> +
> +#define ALX_ERR_PHY			-20
> +#define ALX_ERR_PHY_INIT		-21

Unused.

> +#define ALX_ERR_PHY_RESET		-22
> +#define ALX_ERR_PHY_SETUP_LNK		-23
> +#define ALX_ERR_PHY_CHECK_LNK		-24
> +#define ALX_ERR_PHY_READ_REG		-25
> +#define ALX_ERR_PHY_WRITE_REG		-26
> +#define ALX_ERR_PHY_RESOLVED		-27
> +
> +#define ALX_ERR_PCIE			-40

Unused.

> +#define ALX_ERR_PCIE_RESET		-41
> +#define ALX_ERR_PWR_SAVING		-42
> +#define ALX_ERR_ASPM			-43
> +#define ALX_ERR_EEPROM			-44

Unused.

> +#define ALX_ERR_DISABLE_DRV		-45
> +
> +#define ALX_ERR_FLOW_CONTROL		-50
> +#define ALX_ERR_FC_NOT_NEGOTIATED	-51

Unused.

> +#define ALX_ERR_FC_NOT_SUPPORTED	-52

Unused.

> +
> +#define ALX_ERR_INVALID_ARGUMENT	0x7FFFFFFD

Unused.

> +#define ALX_ERR_NOT_SUPPORTED		0x7FFFFFFE
> +#define ALX_ERR_NOT_IMPLEMENTED		0x7FFFFFFF

Unused.

--
Ueimor
