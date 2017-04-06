From: Juergen Borleis <jbe@pengutronix.de>
Subject: Re: [PATCH 2/4] net: dsa: add new DSA switch driver for the SMSC-LAN9303
Date: Thu, 6 Apr 2017 12:18:56 +0200
Message-ID: <201704061218.57438.jbe@pengutronix.de>
References: <20170405092024.16048-1-jbe@pengutronix.de> <20170405092024.16048-3-jbe@pengutronix.de> <20170405181232.GE21965@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Cc: Andrew Lunn <andrew@lunn.ch>, f.fainelli@gmail.com,
        vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, davem@davemloft.net
To: kernel@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:55489 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754111AbdDFKTl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 06:19:41 -0400
In-Reply-To: <20170405181232.GE21965@lunn.ch>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

v2 of the patches will follow.

On Wednesday 05 April 2017 20:12:32 Andrew Lunn wrote:
> [...]
> > +	do {
> > +		ret = regmap_read(regmap, offset, reg);
> > +		if (ret == -EAGAIN)
> > +			msleep(500);
> > +	} while (ret == -EAGAIN);
>
> Please limit the number of retires, and return -EIO if you don't get
> access.

Done in v2.

> > +/* virtual phy registers must be read mapped */
> > +static int lan9303_virt_phy_reg_read(struct lan9303 *chip, int regnum)
> > +{
> > +	int ret;
> > +	u32 val;
> > +
> > +	if (regnum > 7)
> > +		return -EINVAL;
> > +
> > +	ret = lan9303_read(chip->regmap, LAN9303_VIRT_PHY_BASE + regnum, &val);
> > +	if (ret != 0) 
> > +		return ret;
>
> Here, and everywhere else, please just use (ret)

Done in v2.

> [...]
> > +static int lan9303_virt_phy_reg_write(struct lan9303 *chip, int regnum, u16 val)
> > +{ 
> > +	if (regnum > 7)
> > +		return -EINVAL;
> > +
> > +	return regmap_write(chip->regmap, LAN9303_VIRT_PHY_BASE + regnum, val);
>
> Does this virtual PHY use the usual 10/100/1000 PHY registers?

Yes. Registers 0...6

> [...]
> > +	do {
> > +		ret = lan9303_read(chip->regmap, LAN9303_PMI_ACCESS, &reg);
> > +		if (ret != 0)
> > +			return ret;
> > +	} while (reg & LAN9303_PMI_ACCESS_MII_BUSY);
>
> Again, no endless looping please. Abort after a while.

Done in v2.

> [...]
> > +static int lan9303_phy_reg_write(struct lan9303 *chip, int addr, int regnum,
> > +				 unsigned int val) 
> > +{
> > +	int ret;
> > +	u32 reg;
> > +
> > +	reg = ((unsigned int)addr) << 11; /* setup phy ID */
>
> Within Linux, PHY ID means the contents of PHY registers 2 and 3. It
> would be good not to confuse things by using a different meaning.

Renamed in v2.

> [...]
> > +	/* transfer completed? */
> > +	do {
> > +		ret = lan9303_read(chip->regmap, LAN9303_SWITCH_CSR_CMD, &reg);
> > +		if (ret) {
> > +			dev_err(chip->dev,
> > +				"Failed to read csr command status: %d\n",
> > +				ret);
> > +			return ret;
> > +		}
> > +	} while (reg & LAN9303_SWITCH_CSR_CMD_BUSY);
>
> More endless looping...

More done in v2 :)

> [...]
> > +static int lan9303_detect_phy_ids(struct lan9303 *chip)
>
> This is another example of phy_ids having a different meaning to
> normal. lan9303_detect_phy_addrs()?

Renamed in v2.

> > +{
> > +	int reg;
> > +
> > +	/* depending on the 'phy_addr_sel_strap' setting, the three phys are
> > +	 * using IDs 0-1-2 or IDs 1-2-3. We cannot read back the
> > +	 * 'phy_addr_sel_strap' setting directly, so we need a test, which
> > +	 * configuration is active:
> > +	 * Register 18 of phy 3 reads as 0x0000, if 'phy_addr_sel_strap' is 0
> > +	 * and the IDs are 0-1-2, else it contains something different from
> > +	 * 0x0000, which means 'phy_addr_sel_strap' is 1 and the IDs are 1-2-3.
> > +	 */ 
> > +	reg = lan9303_port_phy_reg_read(chip, 3, 18);
>
> #defines for 3 and 18?

Done in v2.

>
> > +	if (reg < 0) {
> > +		dev_err(chip->dev, "Failed to detect phy config: %d\n", reg);
> > +		return reg;
> > +	}
> > +
> > +	if (reg != 0)
> > +		chip->phy_addr_sel_strap = 1;
> > +	else
> > +		chip->phy_addr_sel_strap = 0;
> > +
> > +	dev_dbg(chip->dev, "Phy configuration '%s' detected\n",
> > +		chip->phy_addr_sel_strap ? "1-2-3" : "0-1-2");
> > +
> > +	return 0;
> > +}
> > +
> > +static void lan9303_report_virt_phy_config(struct lan9303 *chip,
> > +					   unsigned int reg)
> > +{
> > +	switch ((reg >> 8) & 0x03) {
> > +	case 0:
> > +		dev_info(chip->dev, "Virtual phy in 'MII MAC mode'\n");
> > +		break;
> > +	case 1:
> > +		dev_info(chip->dev, "Virtual phy in 'MII PHY mode'\n");
> > +		break;
> > +	case 2:
> > +		dev_info(chip->dev, "Virtual phy in 'RMII PHY mode'\n");
> > +		break;
> > +	case 3:
> > +		dev_err(chip->dev, "Invalid virtual phy mode\n");
> > +		break;
> > +	}
> > +
> > +	if (reg & BIT(6))
> > +		dev_info(chip->dev, "RMII clock is an output\n");
> > +	else
> > +		dev_info(chip->dev, "RMII clock is an input\n");
> > +}
> > +
> > +/* stop processing packets at all ports */
> > +static int lan9303_disable_switching(struct lan9303 *chip)
>
> switching normally means allowing packets to go from port to port,
> based on address learning. Is that what is being disabled here? Or are
> you just disabling ports so no frames at all pass through?

Yes. The device defaults to learning mode and starts to switch packages
immediately.

> > +{
> > +	int ret;
> > +
> > +	ret = lan9303_write_switch_reg(chip, LAN9303_MAC_RX_CFG_0, 0x02);
>
> #defines for these magic numbers.

I refactored this routines in v2.

> [...]
> > +
> > +/* We want a special working switch:
> > + * - do not route between port 1 and 2
>
> route generally refers to layer 3, IP routing. Forward is the more
> common term for layer 2, but it can also be used at L3, so is still a
> bit ambiguous.

I'm not a network expert. In v2 I use "forwarding" instead.

> [...]
> > +static int lan9303_handle_reset(struct lan9303 *chip)
> > +{
> > +	if (!chip->reset_gpio)
> > +		return 0;
> > +
> > +	gpiod_export_link(chip->dev, "reset", chip->reset_gpio);
>
> Why do this? Are you expecting userspace to reset the switch?

Leftover from development. Removed in v2.

> [...]
> > +#ifdef DEBUG
> > +		if (!chip->reset_gpio) {
> > +			dev_warn(chip->dev,
> > +				 "Maybe failed due to missing reset GPIO\n");
> > +		}
> > +#endif
>
> No #ifdef please. Either this should be mandatory, and you should of
> failed in the probe function, or it is optional, and then there is no
> need to warn.

Done in v2.

> [...]
> > +	if ((reg >> 16) != 0x9303) {
>
> #define for the ID?

Done in v2.

> [...]
> > +	if (reg & LAN9303_HW_CFG_AMDX_EN_PORT1)
> > +		dev_info(chip->dev, "Port 1 auto-dmx enabled\n");
> > +	if (reg & LAN9303_HW_CFG_AMDX_EN_PORT2)
> > +		dev_info(chip->dev, "Port 2 auto-dmx enabled\n");
>
> What is dmx?

Typo...

> [...]
> We are spamming the log with lots of information here. Do we need it
> all?

Leftover from development, removed in v2.

> [...]
> > +static int lan9303_phy_read(struct dsa_switch *ds, int phy, int regnum)
> > +{ 
> > +	struct lan9303 *chip = ds_to_lan9303(ds);
> > +	int phy_base = chip->phy_addr_sel_strap;
> > +
> > +	if (phy == phy_base)
> > +		return lan9303_virt_phy_reg_read(chip, regnum);
> > +	if (phy > phy_base + 2)
> > +		return -ENODEV;
> > +
> > +	return lan9303_port_phy_reg_read(chip, phy, regnum);
> > +}
>
> PHY functions in the middle of stats functions? Maybe move them later?

Done in v2.

> > +
> > +static int lan9303_phy_write(struct dsa_switch *ds, int phy, int regnum,
> > +			          u16 val) 
> > +{
> > +	struct lan9303 *chip = ds_to_lan9303(ds);
> > +	int phy_base = chip->phy_addr_sel_strap;
> > +
> > +	if (phy == phy_base)
> > +		return lan9303_virt_phy_reg_write(chip, regnum, val);
> > +	if (phy > phy_base + 2)
> > +		return -ENODEV;
> > +
> > +	return lan9303_phy_reg_write(chip, phy, regnum, val);
>
> Does the MDIO bus go to the outside world? Could there be external
> PHYs?

???? This device includes two phys (at port 1 and 2) and these functions are
called to detect their state.

> [...]
> > +	dev_dbg(chip->dev, "%s called\n", __func__);
>
> I think this can be removed.

Done in v2.

> [...]
> > +/* power on the given port */
> > +static int lan9303_port_enable(struct dsa_switch *ds, int port,
> > +			       struct phy_device *phy)
> > +{
> > +	struct lan9303 *chip = ds_to_lan9303(ds);
> > +	int rc;
>
> Please be consistent and use ret.

Changed by refactoring the whole function in v2.

> > +	/* enable internal data handling */
> > +	switch (port) {
> > +	case 1:
> > +		rc = lan9303_write_switch_reg(chip, LAN9303_MAC_RX_CFG_1, 0x03);
> > +		rc += lan9303_write_switch_reg(chip, LAN9303_MAC_TX_CFG_1,
> > +					       0x57);
> > +		break;
> > +	case 2:
> > +		rc = lan9303_write_switch_reg(chip, LAN9303_MAC_RX_CFG_2, 0x03);
> > +		rc += lan9303_write_switch_reg(chip, LAN9303_MAC_TX_CFG_2,
> > +					       0x57);
> > +		break;
> > +	default:
> > +		dev_dbg(chip->dev, "Error: request to power up invalid port %d\n",
> > +			port);
> > +		return -ENODEV;
> > +	}
> > +
> > +	return rc;
> > +}
> > +
> > +static void lan9303_port_disable(struct dsa_switch *ds, int port,
> > +				 struct phy_device *phy)
> > +{
> > +	struct lan9303 *chip = ds_to_lan9303(ds);
> > +	int rc;
> > +
> > +	/* disable internal data handling */
> > +	switch (port) {
> > +	case 1:
> > +		rc = lan9303_phy_reg_write(chip, chip->phy_addr_sel_strap + 1,
> > +					   0, BIT(14) | BIT(11));
> > +		rc += lan9303_write_switch_reg(chip, LAN9303_MAC_RX_CFG_1,
> > +					       0x02);
> > +		rc += lan9303_write_switch_reg(chip, LAN9303_MAC_TX_CFG_1,
> > +					       0x56);
>
> It seems odd that port_enable does not touch the PHY, but port_disable
> does. What is this doing?

My experience is, the framework powers up the phys by its own in conjunction
with calling lan9303_port_enable(), but do not power down them in conjunction
with calling lan9303_port_disable(). In v2 I do not touch the phy anymore.

> [...]
> > +static int lan9303_register_phys(struct lan9303 *chip)
>
> This one place where the switch is being called a phy.

Renamed in v2.

> [...]
> > +static void lan9303_probe_reset_gpio(struct lan9303 *chip,
> > +				     struct device_node *np)
> > +{
> > +	chip->reset_gpio = devm_gpiod_get_optional(chip->dev, "phy-reset",
>
> This is a reset for the switch, not a PHY in the switch i think. We
> have established a bit of a standard in DSA drivers to just call this
> "reset".

Renamed in v2.

Thanks
Juergen

-- 
Pengutronix e.K.                             | Juergen Borleis             |
Linux Solutions for Science and Industry     | Phone: +49-5121-206917-5128 |
Peiner Str. 6-8, 31137 Hildesheim, Germany   | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686             | http://www.pengutronix.de/  |
