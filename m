From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [PATCH]: Third (final?) release of Sun Neptune driver
Date: Fri, 5 Oct 2007 18:46:19 +0200
Message-ID: <200710051846.19965.netdev@axxeo.de>
References: <20071005.031209.57156822.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Hendel@sun.com, greg.onufer@sun.com,
	jeff@garzik.org, Ashley.Saulsbury@sun.com, Matheos.Worku@sun.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:3895 "EHLO mail.axxeo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753242AbXJEQqp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Oct 2007 12:46:45 -0400
In-Reply-To: <20071005.031209.57156822.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

some minor nits.

Could this driver be split into more files. 8k lines per file
is quite a lot. Although GCC might optimize it best this way :-)

David Miller schrieb:
> +#define nr64(reg)		readq(np->regs + (reg))
> +#define nw64(reg, val)		writeq((val), np->regs + (reg))
> +
> +#define nr64_mac(reg)		readq(np->mac_regs + (reg))
> +#define nw64_mac(reg, val)	writeq((val), np->mac_regs + (reg))
> +
> +#define nr64_ipp(reg)		readq(np->regs + np->ipp_off + (reg))
> +#define nw64_ipp(reg, val)	writeq((val), np->regs + np->ipp_off + (reg))
> +
> +#define nr64_pcs(reg)		readq(np->regs + np->pcs_off + (reg))
> +#define nw64_pcs(reg, val)	writeq((val), np->regs + np->pcs_off + (reg))
> +
> +#define nr64_xpcs(reg)		readq(np->regs + np->xpcs_off + (reg))
> +#define nw64_xpcs(reg, val)	writeq((val), np->regs + np->xpcs_off + (reg))

Can these be static inline and get the "struct niu *np" passed?

> +#define niu_lock_parent(np, flags) \
> +	spin_lock_irqsave(&np->parent->lock, flags)
> +#define niu_unlock_parent(np, flags) \
> +	spin_unlock_irqrestore(&np->parent->lock, flags)

Maybe fold that into its callers.

> +static int serdes_init_10g(struct niu *np)
> +{
> +	struct niu_link_config *lp = &np->link_config;
> +	unsigned long ctrl_reg, test_cfg_reg, i;
> +	u64 ctrl_val, test_cfg_val, sig, mask, val;
> +	int err;
> +
> +	switch (np->port) {
> +	case 0:
> +		ctrl_reg = ENET_SERDES_0_CTRL_CFG;
> +		test_cfg_reg = ENET_SERDES_0_TEST_CFG;
> +		break;
> +	case 1:
> +		ctrl_reg = ENET_SERDES_1_CTRL_CFG;
> +		test_cfg_reg = ENET_SERDES_1_TEST_CFG;
> +		break;
> +
> +	default:
> +		return -EINVAL;
> +	}


Maybe small table?

> +	ctrl_val = (ENET_SERDES_CTRL_SDET_0 |
> +		    ENET_SERDES_CTRL_SDET_1 |
> +		    ENET_SERDES_CTRL_SDET_2 |
> +		    ENET_SERDES_CTRL_SDET_3 |
> +		    (0x5 << ENET_SERDES_CTRL_EMPH_0_SHIFT) |
> +		    (0x5 << ENET_SERDES_CTRL_EMPH_1_SHIFT) |
> +		    (0x5 << ENET_SERDES_CTRL_EMPH_2_SHIFT) |
> +		    (0x5 << ENET_SERDES_CTRL_EMPH_3_SHIFT) |
> +		    (0x1 << ENET_SERDES_CTRL_LADJ_0_SHIFT) |
> +		    (0x1 << ENET_SERDES_CTRL_LADJ_1_SHIFT) |
> +		    (0x1 << ENET_SERDES_CTRL_LADJ_2_SHIFT) |
> +		    (0x1 << ENET_SERDES_CTRL_LADJ_3_SHIFT));
> +	test_cfg_val = 0;
> +
> +	if (lp->loopback_mode == LOOPBACK_PHY) {
> +		test_cfg_val |= ((ENET_TEST_MD_PAD_LOOPBACK <<
> +				  ENET_SERDES_TEST_MD_0_SHIFT) |
> +				 (ENET_TEST_MD_PAD_LOOPBACK <<
> +				  ENET_SERDES_TEST_MD_1_SHIFT) |
> +				 (ENET_TEST_MD_PAD_LOOPBACK <<
> +				  ENET_SERDES_TEST_MD_2_SHIFT) |
> +				 (ENET_TEST_MD_PAD_LOOPBACK <<
> +				  ENET_SERDES_TEST_MD_3_SHIFT));
> +	}
> +
> +	nw64(ctrl_reg, ctrl_val);
> +	nw64(test_cfg_reg, test_cfg_val);
> +
> +	for (i = 0; i < 4; i++) {

why 4? (magic number)

> +		u32 rxtx_ctrl, glue0;
> +		int err;
> +
> +		err = esr_read_rxtx_ctrl(np, i, &rxtx_ctrl);
> +		if (err)
> +			return err;
> +		err = esr_read_glue0(np, i, &glue0);
> +		if (err)
> +			return err;
> +
> +		rxtx_ctrl &= ~(ESR_RXTX_CTRL_VMUXLO);
> +		rxtx_ctrl |= (ESR_RXTX_CTRL_ENSTRETCH |
> +			      (2 << ESR_RXTX_CTRL_VMUXLO_SHIFT));
> +
> +		glue0 &= ~(ESR_GLUE_CTRL0_SRATE |
> +			   ESR_GLUE_CTRL0_THCNT |
> +			   ESR_GLUE_CTRL0_BLTIME);
> +		glue0 |= (ESR_GLUE_CTRL0_RXLOSENAB |
> +			  (0xf << ESR_GLUE_CTRL0_SRATE_SHIFT) |
> +			  (0xff << ESR_GLUE_CTRL0_THCNT_SHIFT) |
> +			  (BLTIME_300_CYCLES <<
> +			   ESR_GLUE_CTRL0_BLTIME_SHIFT));
> +
> +		err = esr_write_rxtx_ctrl(np, i, rxtx_ctrl);
> +		if (err)
> +			return err;
> +		err = esr_write_glue0(np, i, glue0);
> +		if (err)
> +			return err;
> +	}
> +
> +	err = esr_reset(np);
> +	if (err)
> +		return err;
> +
> +	sig = nr64(ESR_INT_SIGNALS);
> +	switch (np->port) {
> +	case 0:
> +		mask = ESR_INT_SIGNALS_P0_BITS;
> +		val = (ESR_INT_SRDY0_P0 |
> +		       ESR_INT_DET0_P0 |
> +		       ESR_INT_XSRDY_P0 |
> +		       ESR_INT_XDP_P0_CH3 |
> +		       ESR_INT_XDP_P0_CH2 |
> +		       ESR_INT_XDP_P0_CH1 |
> +		       ESR_INT_XDP_P0_CH0);
> +		break;
> +
> +	case 1:
> +		mask = ESR_INT_SIGNALS_P1_BITS;
> +		val = (ESR_INT_SRDY0_P1 |
> +		       ESR_INT_DET0_P1 |
> +		       ESR_INT_XSRDY_P1 |
> +		       ESR_INT_XDP_P1_CH3 |
> +		       ESR_INT_XDP_P1_CH2 |
> +		       ESR_INT_XDP_P1_CH1 |
> +		       ESR_INT_XDP_P1_CH0);
> +		break;
> +
> +	default:
> +		return -EINVAL;
> +	}

maybe small table? (maybe combined with the other one suggsted above)

> +
> +	if ((sig & mask) != val) {
> +		printk(KERN_ERR PFX "Port %u signal bits [%08x] are not "
> +		       "[%08x]\n", np->port, (int) (sig & mask), (int) val);
> +		return -ENODEV;
> +	}
> +
> +	return 0;
> +}
> +
> +static int serdes_init_1g(struct niu *np)
> +{
> +	u64 val;
> +
> +	val = nr64(ENET_SERDES_1_PLL_CFG);
> +	val &= ~ENET_SERDES_PLL_FBDIV2;
> +	switch (np->port) {
> +	case 0:
> +		val |= ENET_SERDES_PLL_HRATE0;
> +		break;
> +	case 1:
> +		val |= ENET_SERDES_PLL_HRATE1;
> +		break;
> +	case 2:
> +		val |= ENET_SERDES_PLL_HRATE2;
> +		break;
> +	case 3:
> +		val |= ENET_SERDES_PLL_HRATE3;
> +		break;
> +	default:
> +		return -EINVAL;
> +	}

Maybe small table.

> +	nw64(ENET_SERDES_1_PLL_CFG, val);
> +
> +	return 0;
> +}
> +

[...]

> +static int bcm8704_init_user_dev3(struct niu *np)
> +{
> +	int err;
> +
> +	err = mdio_write(np, np->phy_addr,
> +			 BCM8704_USER_DEV3_ADDR, BCM8704_USER_CONTROL,
> +			 (USER_CONTROL_OPTXRST_LVL |
> +			  USER_CONTROL_OPBIASFLT_LVL |
> +			  USER_CONTROL_OBTMPFLT_LVL |
> +			  USER_CONTROL_OPPRFLT_LVL |
> +			  USER_CONTROL_OPTXFLT_LVL |
> +			  USER_CONTROL_OPRXLOS_LVL |
> +			  USER_CONTROL_OPRXFLT_LVL |
> +			  USER_CONTROL_OPTXON_LVL |
> +			  (0x3f << USER_CONTROL_RES1_SHIFT)));
> +	if (err)
> +		return err;
> +
> +	err = mdio_write(np, np->phy_addr,
> +			 BCM8704_USER_DEV3_ADDR, BCM8704_USER_PMD_TX_CONTROL,
> +			 (USER_PMD_TX_CTL_XFP_CLKEN |
> +			  (1 << USER_PMD_TX_CTL_TX_DAC_TXD_SH) |
> +			  (2 << USER_PMD_TX_CTL_TX_DAC_TXCK_SH) |
> +			  USER_PMD_TX_CTL_TSCK_LPWREN));
> +	if (err)
> +		return err;
> +
> +	err = bcm8704_user_dev3_readback(np, BCM8704_USER_CONTROL);
> +	if (err)
> +		return err;
> +	err = bcm8704_user_dev3_readback(np, BCM8704_USER_PMD_TX_CONTROL);
> +	if (err)
> +		return err;
> +
> +	err = mdio_read(np, np->phy_addr, BCM8704_USER_DEV3_ADDR,
> +			BCM8704_USER_OPT_DIGITAL_CTRL);
> +	if (err < 0)
> +		return err;
> +	err &= ~USER_ODIG_CTRL_GPIOS;
> +	err |= (0x3 << USER_ODIG_CTRL_GPIOS_SHIFT);
> +	err = mdio_write(np, np->phy_addr, BCM8704_USER_DEV3_ADDR,
> +			 BCM8704_USER_OPT_DIGITAL_CTRL, err);
> +	if (err)
> +		return err;
> +
> +	udelay(1000000);

maybe convert to mdelay?

> +
> +	return 0;
> +}
> +

[...]

> +static void niu_init_xif(struct niu *);
> +
> +static int link_status_10g(struct niu *np, int *link_up_p)
> +{
> +	unsigned long flags;
> +	int err, link_up;
> +
> +	if (np->link_config.loopback_mode != LOOPBACK_DISABLED)
> +		return -EINVAL;
> +
> +	link_up = 0;
> +
> +	spin_lock_irqsave(&np->lock, flags);
> +
> +	err = mdio_read(np, np->phy_addr, BCM8704_PMA_PMD_DEV_ADDR,
> +			BCM8704_PMD_RCV_SIGDET);
> +	if (err < 0)
> +		return err;

missing spin_unlock_irqsave()?

> +	if (!(err & PMD_RCV_SIGDET_GLOBAL))
> +		goto out;
> +
> +	err = mdio_read(np, np->phy_addr, BCM8704_PCS_DEV_ADDR,
> +			BCM8704_PCS_10G_R_STATUS);
> +	if (err < 0)
> +		return err;
missing spin_unlock_irqsave()?

> +	if (!(err & PCS_10G_R_STATUS_BLK_LOCK))
> +		goto out;
> +
> +	err = mdio_read(np, np->phy_addr, BCM8704_PHYXS_DEV_ADDR,
> +			BCM8704_PHYXS_XGXS_LANE_STAT);
> +	if (err < 0)
> +		return err;
> +
> +	if (err != (PHYXS_XGXS_LANE_STAT_ALINGED |
> +		    PHYXS_XGXS_LANE_STAT_MAGIC |
> +		    PHYXS_XGXS_LANE_STAT_LANE3 |
> +		    PHYXS_XGXS_LANE_STAT_LANE2 |
> +		    PHYXS_XGXS_LANE_STAT_LANE1 |
> +		    PHYXS_XGXS_LANE_STAT_LANE0))
> +		goto out;
> +
> +	link_up = 1;
> +	np->link_config.active_speed = SPEED_10000;
> +	np->link_config.active_duplex = DUPLEX_FULL;
> +
> +out:
> +	spin_unlock_irqrestore(&np->lock, flags);
> +
> +	*link_up_p = link_up;
> +	return 0;
> +}

[...]

> +static void niu_set_primary_mac(struct niu *np, unsigned char *addr)
> +{
> +	u16 reg0 = addr[4] << 8 | addr[5];
> +	u16 reg1 = addr[2] << 8 | addr[3];
> +	u16 reg2 = addr[0] << 8 | addr[1];
> +
> +	if (np->flags & NIU_FLAGS_XMAC) {
> +		nw64_mac(XMAC_ADDR0, reg0);
> +		nw64_mac(XMAC_ADDR1, reg1);
> +		nw64_mac(XMAC_ADDR2, reg2);
> +	} else {
> +		nw64_mac(BMAC_ADDR0, reg0);
> +		nw64_mac(BMAC_ADDR1, reg1);
> +		nw64_mac(BMAC_ADDR2, reg2);
> +	}
> +}
> +
> +static int niu_num_alt_addr(struct niu *np)
static int niu_num_alt_addr(const struct niu *np)

> +{
> +	if (np->flags & NIU_FLAGS_XMAC)
> +		return XMAC_NUM_ALT_ADDR;
> +	else
> +		return BMAC_NUM_ALT_ADDR;
> +}
> +

[...]

> +static void niu_set_max_burst(struct niu *np, struct tx_ring_info *rp)
> +{
> +	int mtu = np->dev->mtu;
> +
> +	rp->max_burst = mtu + 32;
> +	if (rp->max_burst > 4096)
> +		rp->max_burst = 4096;

Why 32 and 4096? (Magic values)

> +}
> +

... ok, I stop here, since this drivers is damn big :-)

Best Regards

Ingo Oeser
