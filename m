From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next v2 04/10] net: phy: add Broadcom BCM7xxx
 internal PHY driver
Date: Thu, 13 Feb 2014 11:34:54 +0100
Message-ID: <20140213103454.GA14941@electric-eye.fr.zoreil.com>
References: <1392269395-23513-1-git-send-email-f.fainelli@gmail.com>
 <1392269395-23513-5-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, cernekee@gmail.com,
	devicetree@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:44081 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753203AbaBMKfB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 05:35:01 -0500
Content-Disposition: inline
In-Reply-To: <1392269395-23513-5-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli <f.fainelli@gmail.com> :
[...]
> diff --git a/drivers/net/phy/bcm7xxx.c b/drivers/net/phy/bcm7xxx.c
> new file mode 100644
> index 0000000..6aea6e2
> --- /dev/null
> +++ b/drivers/net/phy/bcm7xxx.c
[...]
> +static int bcm7445_config_init(struct phy_device *phydev)
> +{
> +	int ret;

It could be declared after 'i' below.

> +	const struct bcm7445_regs {

static const

> +		int reg;
> +		u16 value;
> +	} bcm7445_regs_cfg[] = {
> +		/* increases ADC latency by 24ns */
> +		{ 0x17, 0x0038 },
> +		{ 0x15, 0xAB95 },
> +		/* increases internal 1V LDO voltage by 5% */
> +		{ 0x17, 0x2038 },
> +		{ 0x15, 0xBB22 },
> +		/* reduce RX low pass filter corner frequency */
> +		{ 0x17, 0x6038 },
> +		{ 0x15, 0xFFC5 },
> +		/* reduce RX high pass filter corner frequency */
> +		{ 0x17, 0x003a },
> +		{ 0x15, 0x2002 },
> +	};
> +	unsigned int i;
> +
> +	for (i = 0; i < ARRAY_SIZE(bcm7445_regs_cfg); i++) {
> +		ret = phy_write(phydev,
> +				bcm7445_regs_cfg[i].reg,
> +				bcm7445_regs_cfg[i].value);
> +		if (ret)
> +			return ret;
> +	}
> +
> +	return 0;
> +}
> +
> +static void phy_write_exp(struct phy_device *phydev,
> +					u16 reg, u16 value)

static void phy_write_exp(struct phy_device *phydev, u16 reg, u16 value)

> +{
> +	phy_write(phydev, 0x17, 0xf00 | reg);
> +	phy_write(phydev, 0x15, value);
> +}
> +
> +static void phy_write_misc(struct phy_device *phydev,
> +					u16 reg, u16 chl, u16 value)
   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ all tabs that don't line up

static void phy_write_misc(struct phy_device *phydev,
			   u16 reg, u16 chl, u16 value)

static void phy_write_misc(struct phy_device *phydev, u16 reg, u16 chl,
			   u16 value)

static void phy_write_misc(struct phy_device *phydev, u16 reg, u16 chl, u16 val)


> +{
> +	int tmp;
> +
> +	phy_write(phydev, 0x18, 0x7);
> +
> +	tmp = phy_read(phydev, 0x18);
> +	tmp |= 0x800;
> +	phy_write(phydev, 0x18, tmp);
> +
> +	tmp = (chl * 0x2000) | reg;
> +	phy_write(phydev, 0x17, tmp);
> +
> +	phy_write(phydev, 0x15, value);

You may use some #define for the 0x15, 0x17 and 0x18 values.

> +}
> +
> +static int bcm7xxx_28nm_afe_config_init(struct phy_device *phydev)
> +{
> +	/* write AFE_RXCONFIG_0 */
> +	phy_write_misc(phydev, 0x38, 0x0000, 0xeb19);
> +
> +	/* write AFE_RXCONFIG_1 */
> +	phy_write_misc(phydev, 0x38, 0x0001, 0x9a3f);
> +
> +	/* write AFE_RX_LP_COUNTER */
> +	phy_write_misc(phydev, 0x38, 0x0003, 0x7fc7);
> +
> +	/* write AFE_HPF_TRIM_OTHERS */
> +	phy_write_misc(phydev, 0x3A, 0x0000, 0x000b);
> +
> +	/* write AFTE_TX_CONFIG */
> +	phy_write_misc(phydev, 0x39, 0x0000, 0x0800);

Some #define may be welcome to replace the comments.

[...]
> +static int bcm7xxx_28nm_config_init(struct phy_device *phydev)
> +{
> +	int ret;
> +
> +	ret = bcm7445_config_init(phydev);
> +	if (ret)
> +		return ret;
> +
> +	return bcm7xxx_28nm_afe_config_init(phydev);
> +}
> +
> +static int phy_set_clr_bits(struct phy_device *dev, int location,
> +					int set_mask, int clr_mask)
> +{
> +	int v, ret;
> +
> +	v = phy_read(dev, location);
> +	if (v < 0)
> +		return v;
> +
> +	v &= ~clr_mask;
> +	v |= set_mask;
> +
> +	ret = phy_write(dev, location, v);
> +	if (ret < 0)
> +		return ret;
> +
> +	return v;
> +}
> +
> +static int bcm7xxx_config_init(struct phy_device *phydev)
> +{
> +	/* Enable 64 clock MDIO */
> +	phy_write(phydev, 0x1d, 0x1000);
> +	phy_read(phydev, 0x1d);
> +
> +	/* Workaround only required for 100Mbits/sec */
> +	if (!(phydev->dev_flags & PHY_BRCM_100MBPS_WAR))
> +		return 0;
> +
> +	/* set shadow mode 2 */
> +	phy_set_clr_bits(phydev, 0x1f, 0x0004, 0x0004);

phy_set_clr_bits returned status code is not checked.

> +
> +	/* set iddq_clkbias */
> +	phy_write(phydev, 0x14, 0x0F00);
> +	udelay(10);
> +
> +	/* reset iddq_clkbias */
> +	phy_write(phydev, 0x14, 0x0C00);
> +
> +	phy_write(phydev, 0x13, 0x7555);
> +
> +	/* reset shadow mode 2 */
> +	phy_set_clr_bits(phydev, 0x1f, 0x0004, 0);

phy_set_clr_bits returned status code is not checked.

> +
> +	return 0;
> +}
> +
> +/* Workaround for putting the PHY in IDDQ mode, required
> + * for all BCM7XXX PHYs
> + */
> +static int bcm7xxx_suspend(struct phy_device *phydev)

Factor out with bcm7445_config_init and some helper ?

> +{
> +	int ret;
> +	const struct bcm7xxx_regs {
> +		int reg;
> +		u16 value;
> +	} bcm7xxx_suspend_cfg[] = {
> +		{ 0x1f, 0x008b },
> +		{ 0x10, 0x01c0 },
> +		{ 0x14, 0x7000 },
> +		{ 0x1f, 0x000f },
> +		{ 0x10, 0x20d0 },
> +		{ 0x1f, 0x000b },
> +	};
> +	unsigned int i;

-- 
Ueimor
