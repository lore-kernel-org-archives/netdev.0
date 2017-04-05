From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 2/4] net: dsa: add new DSA switch driver for the
 SMSC-LAN9303
Date: Wed, 5 Apr 2017 20:12:32 +0200
Message-ID: <20170405181232.GE21965@lunn.ch>
References: <20170405092024.16048-1-jbe@pengutronix.de>
 <20170405092024.16048-3-jbe@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        f.fainelli@gmail.com, kernel@pengutronix.de,
        vivien.didelot@savoirfairelinux.com, davem@davemloft.net
To: Juergen Borleis <jbe@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170405092024.16048-3-jbe@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 05, 2017 at 11:20:22AM +0200, Juergen Borleis wrote:
> The SMSC/Microchip LAN9303 is an ethernet switch device with one CPU port
> and two external ethernet ports with built-in phys.
> 
> This driver uses the DSA framework, but is currently only capable of
> separating the two external ports. There is no offload support yet.
> 
> Signed-off-by: Juergen Borleis <jbe@pengutronix.de>
> ---
>  drivers/net/phy/lan9303-core.c | 924 +++++++++++++++++++++++++++++++++++++++++
>  drivers/net/phy/lan9303.h      |  21 +

drivers/net/dsa please.

One general comment. I'm assuming parts of this code comes from
openwrt swconfig. In swconfig, i think they consider switches to be
part of the PHY layer. In DSA, switches are switches, PHYs are
PHYs. So the naming in this driver needs to reflect this.

> +static int lan9303_read(struct regmap *regmap, unsigned int offset, u32 *reg)
> +{
> +	int ret;
> +
> +	/* we can lose arbitration for the I2C case, because the device
> +	 * tries to detect and read an external EEPROM after reset and acts as
> +	 * a master on the shared I2C bus itself. This conflicts with our
> +	 * attempts to access the device as a slave at the same moment.
> +	 */
> +	do {
> +		ret = regmap_read(regmap, offset, reg);
> +		if (ret == -EAGAIN)
> +			msleep(500);
> +	} while (ret == -EAGAIN);

Please limit the number of retires, and return -EIO if you don't get
access.

> +/* virtual phy registers must be read mapped */
> +static int lan9303_virt_phy_reg_read(struct lan9303 *chip, int regnum)
> +{
> +	int ret;
> +	u32 val;
> +
> +	if (regnum > 7)
> +		return -EINVAL;
> +
> +	ret = lan9303_read(chip->regmap, LAN9303_VIRT_PHY_BASE + regnum, &val);
> +	if (ret != 0)
> +		return ret;

Here, and everywhere else, please just use (ret)

> +
> +	return val & 0xffff;
> +}
> +
> +static int lan9303_virt_phy_reg_write(struct lan9303 *chip, int regnum, u16 val)
> +{
> +	if (regnum > 7)
> +		return -EINVAL;
> +
> +	return regmap_write(chip->regmap, LAN9303_VIRT_PHY_BASE + regnum, val);

Does this virtual PHY use the usual 10/100/1000 PHY registers?


> +}
> +
> +static int lan9303_port_phy_reg_wait_for_completion(struct lan9303 *chip)
> +{
> +	int ret;
> +	u32 reg;
> +
> +	/* transfer completed? */
> +	do {
> +		ret = lan9303_read(chip->regmap, LAN9303_PMI_ACCESS, &reg);
> +		if (ret != 0)
> +			return ret;
> +	} while (reg & LAN9303_PMI_ACCESS_MII_BUSY);

Again, no endless looping please. Abort after a while.

> +
> +	return 0;
> +}
> +
> +static int lan9303_port_phy_reg_read(struct lan9303 *chip, int addr, int regnum)
> +{
> +	int ret;
> +	u32 val;
> +
> +	val = ((unsigned int)addr) << 11; /* setup phy ID */
> +	val |= ((unsigned int)regnum) << 6;
> +
> +	mutex_lock(&chip->indirect_mutex);
> +
> +	ret = lan9303_port_phy_reg_wait_for_completion(chip);
> +	if (ret != 0)
> +		goto on_error;
> +
> +	/* start the MII read cycle */
> +	ret = regmap_write(chip->regmap, LAN9303_PMI_ACCESS, val);
> +	if (ret != 0)
> +		goto on_error;
> +
> +	ret = lan9303_port_phy_reg_wait_for_completion(chip);
> +	if (ret != 0)
> +		goto on_error;
> +
> +	/* read the result of this operation */
> +	ret = lan9303_read(chip->regmap, LAN9303_PMI_DATA, &val);
> +	if (ret != 0)
> +		goto on_error;
> +
> +	mutex_unlock(&chip->indirect_mutex);
> +
> +	return val & 0xffff;
> +
> +on_error:
> +	mutex_unlock(&chip->indirect_mutex);
> +	return ret;
> +}
> +
> +static int lan9303_phy_reg_write(struct lan9303 *chip, int addr, int regnum,
> +				 unsigned int val)
> +{
> +	int ret;
> +	u32 reg;
> +
> +	reg = ((unsigned int)addr) << 11; /* setup phy ID */

Within Linux, PHY ID means the contents of PHY registers 2 and 3. It
would be good not to confuse things by using a different meaning.

> +	reg |= ((unsigned int)regnum) << 6;
> +	reg |= LAN9303_PMI_ACCESS_MII_WRITE;
> +
> +	mutex_lock(&chip->indirect_mutex);
> +
> +	ret = lan9303_port_phy_reg_wait_for_completion(chip);
> +	if (ret != 0)
> +		goto on_error;
> +
> +	/* write the data first... */
> +	ret = regmap_write(chip->regmap, LAN9303_PMI_DATA, val);
> +	if (ret != 0)
> +		goto on_error;
> +
> +	/* ...then start the MII write cycle */
> +	ret = regmap_write(chip->regmap, LAN9303_PMI_ACCESS, reg);
> +
> +on_error:
> +	mutex_unlock(&chip->indirect_mutex);
> +	return ret;
> +}
> +
> +static int lan9303_switch_wait_for_completion(struct lan9303 *chip)
> +{
> +	int ret;
> +	u32 reg;
> +
> +	/* transfer completed? */
> +	do {
> +		ret = lan9303_read(chip->regmap, LAN9303_SWITCH_CSR_CMD, &reg);
> +		if (ret) {
> +			dev_err(chip->dev,
> +				"Failed to read csr command status: %d\n",
> +				ret);
> +			return ret;
> +		}
> +	} while (reg & LAN9303_SWITCH_CSR_CMD_BUSY);

More endless looping...

> +
> +	return 0;
> +}
> +
> +static int lan9303_write_switch_reg(struct lan9303 *chip, u16 regnum, u32 val)
> +{
> +	u32 reg;
> +	int ret;
> +
> +	reg = regnum;
> +	reg |= LAN9303_SWITCH_CSR_CMD_LANES;
> +	reg |= LAN9303_SWITCH_CSR_CMD_BUSY;
> +
> +	mutex_lock(&chip->indirect_mutex);
> +
> +	ret = lan9303_switch_wait_for_completion(chip);
> +	if (ret)
> +		goto on_error;
> +
> +	ret = regmap_write(chip->regmap, LAN9303_SWITCH_CSR_DATA, val);
> +	if (ret) {
> +		dev_err(chip->dev, "Failed to write csr data reg: %d\n", ret);
> +		goto on_error;
> +	}
> +
> +	/* trigger write */
> +	ret = regmap_write(chip->regmap, LAN9303_SWITCH_CSR_CMD, reg);
> +	if (ret)
> +		dev_err(chip->dev, "Failed to write csr command reg: %d\n",
> +			ret);
> +
> +on_error:
> +	mutex_unlock(&chip->indirect_mutex);
> +	return ret;
> +}
> +
> +static int lan9303_read_switch_reg(struct lan9303 *chip, u16 regnum, u32 *val)
> +{
> +	u32 reg;
> +	int ret;
> +
> +	reg = regnum;
> +	reg |= LAN9303_SWITCH_CSR_CMD_LANES;
> +	reg |= LAN9303_SWITCH_CSR_CMD_RW;
> +	reg |= LAN9303_SWITCH_CSR_CMD_BUSY;
> +
> +	mutex_lock(&chip->indirect_mutex);
> +
> +	ret = lan9303_switch_wait_for_completion(chip);
> +	if (ret)
> +		goto on_error;
> +
> +	/* trigger read */
> +	ret = regmap_write(chip->regmap, LAN9303_SWITCH_CSR_CMD, reg);
> +	if (ret) {
> +		dev_err(chip->dev, "Failed to write csr command reg: %d\n",
> +			ret);
> +		goto on_error;
> +	}
> +
> +	ret = lan9303_switch_wait_for_completion(chip);
> +	if (ret)
> +		goto on_error;
> +
> +	ret = lan9303_read(chip->regmap, LAN9303_SWITCH_CSR_DATA, val);
> +	if (ret)
> +		dev_err(chip->dev, "Failed to read csr data reg: %d\n",
> +			ret);
> +on_error:
> +	mutex_unlock(&chip->indirect_mutex);
> +	return ret;
> +}
> +
> +static int lan9303_detect_phy_ids(struct lan9303 *chip)

This is another example of phy_ids having a different meaning to
normal. lan9303_detect_phy_addrs()?

> +{
> +	int reg;
> +
> +	/* depending on the 'phy_addr_sel_strap' setting, the three phys are
> +	 * using IDs 0-1-2 or IDs 1-2-3. We cannot read back the
> +	 * 'phy_addr_sel_strap' setting directly, so we need a test, which
> +	 * configuration is active:
> +	 * Register 18 of phy 3 reads as 0x0000, if 'phy_addr_sel_strap' is 0
> +	 * and the IDs are 0-1-2, else it contains something different from
> +	 * 0x0000, which means 'phy_addr_sel_strap' is 1 and the IDs are 1-2-3.
> +	 */
> +	reg = lan9303_port_phy_reg_read(chip, 3, 18);

#defines for 3 and 18?

> +	if (reg < 0) {
> +		dev_err(chip->dev, "Failed to detect phy config: %d\n", reg);
> +		return reg;
> +	}
> +
> +	if (reg != 0)
> +		chip->phy_addr_sel_strap = 1;
> +	else
> +		chip->phy_addr_sel_strap = 0;
> +
> +	dev_dbg(chip->dev, "Phy configuration '%s' detected\n",
> +		chip->phy_addr_sel_strap ? "1-2-3" : "0-1-2");
> +
> +	return 0;
> +}
> +
> +static void lan9303_report_virt_phy_config(struct lan9303 *chip,
> +					   unsigned int reg)
> +{
> +	switch ((reg >> 8) & 0x03) {
> +	case 0:
> +		dev_info(chip->dev, "Virtual phy in 'MII MAC mode'\n");
> +		break;
> +	case 1:
> +		dev_info(chip->dev, "Virtual phy in 'MII PHY mode'\n");
> +		break;
> +	case 2:
> +		dev_info(chip->dev, "Virtual phy in 'RMII PHY mode'\n");
> +		break;
> +	case 3:
> +		dev_err(chip->dev, "Invalid virtual phy mode\n");
> +		break;
> +	}
> +
> +	if (reg & BIT(6))
> +		dev_info(chip->dev, "RMII clock is an output\n");
> +	else
> +		dev_info(chip->dev, "RMII clock is an input\n");
> +}
> +
> +/* stop processing packets at all ports */
> +static int lan9303_disable_switching(struct lan9303 *chip)

switching normally means allowing packets to go from port to port,
based on address learning. Is that what is being disabled here? Or are
you just disabling ports so no frames at all pass through?

> +{
> +	int ret;
> +
> +	ret = lan9303_write_switch_reg(chip, LAN9303_MAC_RX_CFG_0, 0x02);

#defines for these magic numbers.

> +	if (ret)
> +		return ret;
> +	ret = lan9303_write_switch_reg(chip, LAN9303_MAC_RX_CFG_1, 0x02);
> +	if (ret)
> +		return ret;
> +	ret = lan9303_write_switch_reg(chip, LAN9303_MAC_RX_CFG_2, 0x02);
> +	if (ret)
> +		return ret;
> +	ret = lan9303_write_switch_reg(chip, LAN9303_MAC_TX_CFG_0, 0x56);
> +	if (ret)
> +		return ret;
> +	ret = lan9303_write_switch_reg(chip, LAN9303_MAC_TX_CFG_1, 0x56);
> +	if (ret)
> +		return ret;
> +	return lan9303_write_switch_reg(chip, LAN9303_MAC_TX_CFG_2, 0x56);
> +}
> +
> +/* start processing packets at CPU port */
> +static int lan9303_enable_switching(struct lan9303 *chip)
> +{
> +	int ret;
> +
> +	ret = lan9303_write_switch_reg(chip, LAN9303_MAC_RX_CFG_0, 0x03);
> +	if (ret)
> +		return ret;
> +
> +	return lan9303_write_switch_reg(chip, LAN9303_MAC_TX_CFG_0, 0x57);
> +}
> +
> +/* We want a special working switch:
> + * - do not route between port 1 and 2

route generally refers to layer 3, IP routing. Forward is the more
common term for layer 2, but it can also be used at L3, so is still a
bit ambiguous.

> + * - route everything from port 1 to port 0
> + * - route everything from port 2 to port 0
> + * - route special tagged packets from port 0 to port 1 *or* port 2
> + */
> +static int lan9303_separate_ports(struct lan9303 *chip)
> +{
> +	int ret;
> +
> +	ret = lan9303_write_switch_reg(chip, LAN9303_SWE_PORT_MIRROR,
> +				LAN9303_SWE_PORT_MIRROR_SNIFFER_PORT0 |
> +				LAN9303_SWE_PORT_MIRROR_MIRRORED_PORT1 |
> +				LAN9303_SWE_PORT_MIRROR_MIRRORED_PORT2 |
> +				LAN9303_SWE_PORT_MIRROR_ENABLE_RX_MIRRORING |
> +				LAN9303_SWE_PORT_MIRROR_SNIFF_ALL);
> +	if (ret)
> +		return ret;
> +
> +	/* enable defining the destination port via special VLAN tagging
> +	 * for port 0
> +	 */
> +	ret = lan9303_write_switch_reg(chip, LAN9303_SWE_INGRESS_PORT_TYPE,
> +				       0x03);
> +	if (ret)
> +		return ret;
> +
> +	/* tag incoming packets at port 1 and 2 on their way to port 0 to be
> +	 * able to discover their source port
> +	 */
> +	ret = lan9303_write_switch_reg(chip, LAN9303_BM_EGRSS_PORT_TYPE,
> +			LAN9303_BM_EGRSS_PORT_TYPE_SPECIAL_TAG_PORT0);
> +	if (ret)
> +		return ret;
> +
> +	/* prevent port 1 and 2 from forwarding packets by their own */
> +	return lan9303_write_switch_reg(chip, LAN9303_SWE_PORT_STATE,
> +				LAN9303_SWE_PORT_STATE_FORWARDING_PORT0 |
> +				LAN9303_SWE_PORT_STATE_BLOCKING_PORT1 |
> +				LAN9303_SWE_PORT_STATE_BLOCKING_PORT2);
> +}
> +
> +static int lan9303_handle_reset(struct lan9303 *chip)
> +{
> +	if (!chip->reset_gpio)
> +		return 0;
> +
> +	gpiod_export_link(chip->dev, "reset", chip->reset_gpio);

Why do this? Are you expecting userspace to reset the switch?

> +
> +	if (chip->reset_duration != 0)
> +		msleep(chip->reset_duration);
> +
> +	/* release (deassert) reset and activate the device */
> +	gpiod_set_value_cansleep(chip->reset_gpio, 0);
> +
> +	return 0;
> +}
> +
> +static int lan9303_check_device(struct lan9303 *chip)
> +{
> +	int ret;
> +	u32 reg;
> +
> +	ret = lan9303_read(chip->regmap, LAN9303_CHIP_REV, &reg);
> +	if (ret) {
> +		dev_err(chip->dev, "failed to read chip revision register: %d\n",
> +			ret);
> +#ifdef DEBUG
> +		if (!chip->reset_gpio) {
> +			dev_warn(chip->dev,
> +				 "Maybe failed due to missing reset GPIO\n");
> +		}
> +#endif

No #ifdef please. Either this should be mandatory, and you should of
failed in the probe function, or it is optional, and then there is no
need to warn.

> +		return ret;
> +	}
> +
> +	if ((reg >> 16) != 0x9303) {

#define for the ID?

> +		dev_err(chip->dev, "Invalid chip found: %X\n", reg >> 16);
> +		return ret;
> +	}
> +
> +	/* The default state of the LAN9303 device is to forward packets between
> +	 * all ports (if not configured differently by an external EEPROM).
> +	 * The initial state of a DSA device must be forwarding packets only
> +	 * between the external and the internal ports and no forwarding
> +	 * between the external ports. In preparation we stop packet handling
> +	 * at all for now until the LAN9303 device is re-programmed accordingly.
> +	 */
> +	ret = lan9303_disable_switching(chip);
> +	if (ret)
> +		dev_warn(chip->dev, "failed to disable switching %d\n", ret);
> +
> +	dev_info(chip->dev, "Found LAN9303 rev. %u\n", reg & 0xffff);
> +
> +	ret = lan9303_detect_phy_ids(chip);
> +	if (ret) {
> +		dev_err(chip->dev, "failed to discover phy bootstrap setup: %d\n",
> +			ret);
> +		return ret;
> +	}
> +
> +	ret = lan9303_read(chip->regmap, LAN9303_HW_CFG, &reg);
> +	if (ret) {
> +		dev_err(chip->dev, "failed to detect hardware configuration %d\n",
> +			ret);
> +		return ret;
> +	}
> +
> +	if (reg & LAN9303_HW_CFG_AMDX_EN_PORT1)
> +		dev_info(chip->dev, "Port 1 auto-dmx enabled\n");
> +	if (reg & LAN9303_HW_CFG_AMDX_EN_PORT2)
> +		dev_info(chip->dev, "Port 2 auto-dmx enabled\n");

What is dmx?

> +
> +	ret = lan9303_read(chip->regmap, LAN9303_VIRT_SPECIAL_CTRL, &reg);
> +	if (ret < 0)
> +		dev_err(chip->dev, "failed to read virtual phy configuration %d\n",
> +			ret);
> +	else
> +		lan9303_report_virt_phy_config(chip, reg);
> +
> +	ret = lan9303_read_switch_reg(chip, LAN9303_SW_DEV_ID, &reg);
> +	if (ret) {
> +		dev_err(chip->dev, "failed to read switch device ID %d\n", ret);
> +		return ret;
> +	}
> +	dev_info(chip->dev, "Switch device: %x, version %u, revision %u found\n",
> +		 (reg >> 16) & 0xff, (reg >> 8) & 0xff, reg & 0xff);
> +
> +	ret = lan9303_read_switch_reg(chip, LAN9303_MAC_VER_ID_0, &reg);
> +	if (ret) {
> +		dev_err(chip->dev, "failed to read switch MAC 0 ID %d\n", ret);
> +		return ret;
> +	}
> +	dev_info(chip->dev, "MAC 0 device: %x, version %u, revision %u found\n",
> +		 (reg >> 8) & 0xf, (reg >> 4) & 0xf, reg & 0xf);
> +
> +	ret = lan9303_read_switch_reg(chip, LAN9303_MAC_VER_ID_1, &reg);
> +	if (ret) {
> +		dev_err(chip->dev, "failed to read switch MAC 1 ID %d\n", ret);
> +		return ret;
> +	}
> +	dev_info(chip->dev, "MAC 1 device: %x, version %u, revision %u found\n",
> +		 (reg >> 8) & 0xf, (reg >> 4) & 0xf, reg & 0xf);
> +
> +	ret = lan9303_read_switch_reg(chip, LAN9303_MAC_VER_ID_2, &reg);
> +	if (ret) {
> +		dev_err(chip->dev, "failed to read switch MAC 2 ID %d\n", ret);
> +		return ret;
> +	}
> +	dev_info(chip->dev, "MAC 2 device: %x, version %u, revision %u found\n",
> +		 (reg >> 8) & 0xf, (reg >> 4) & 0xf, reg & 0xf);
> +

We are spamming the log with lots of information here. Do we need it
all?

> +	return 0;
> +}
> +
> +/* ---------------------------- DSA -----------------------------------*/
> +
> +static enum dsa_tag_protocol lan9303_get_tag_protocol(struct dsa_switch *ds)
> +{
> +	return DSA_TAG_PROTO_LAN9303;
> +}
> +
> +static int lan9303_setup(struct dsa_switch *ds)
> +{
> +	struct lan9303 *chip = ds_to_lan9303(ds);
> +	int ret;
> +
> +	/* Make sure that port 0 is the cpu port */
> +	if (!dsa_is_cpu_port(ds, 0)) {
> +		dev_err(chip->dev, "port 0 is not the CPU port\n");
> +		return -EINVAL;
> +	}
> +
> +	ret = lan9303_separate_ports(chip);
> +	if (ret)
> +		dev_err(chip->dev, "failed to separate ports %d\n", ret);
> +
> +	ret = lan9303_enable_switching(chip);
> +	if (ret)
> +		dev_err(chip->dev, "failed to re-enable switching %d\n", ret);
> +
> +	return 0;
> +}
> +
> +struct lan9303_mib_desc {
> +	unsigned int offset; /* offset of first MAC */
> +	const char *name;
> +};
> +
> +static const struct lan9303_mib_desc lan9303_mib[] = {
> +	{ .offset = LAN9303_MAC_RX_BRDCST_CNT_0, .name = "RxBroad", },
> +	{ .offset = LAN9303_MAC_RX_PAUSE_CNT_0, .name = "RxPause", },
> +	{ .offset = LAN9303_MAC_RX_MULCST_CNT_0, .name = "RxMulti", },
> +	{ .offset = LAN9303_MAC_RX_PKTOK_CNT_0, .name = "RxOk", },
> +	{ .offset = LAN9303_MAC_RX_CRCERR_CNT_0, .name = "RxCrcErr", },
> +	{ .offset = LAN9303_MAC_RX_ALIGN_CNT_0, .name = "RxAlignErr", },
> +	{ .offset = LAN9303_MAC_RX_JABB_CNT_0, .name = "RxJabber", },
> +	{ .offset = LAN9303_MAC_RX_FRAG_CNT_0, .name = "RxFragment", },
> +	{ .offset = LAN9303_MAC_RX_64_CNT_0, .name = "Rx64Byte", },
> +	{ .offset = LAN9303_MAC_RX_127_CNT_0, .name = "Rx128Byte", },
> +	{ .offset = LAN9303_MAC_RX_255_CNT_0, .name = "Rx256Byte", },
> +	{ .offset = LAN9303_MAC_RX_511_CNT_0, .name = "Rx512Byte", },
> +	{ .offset = LAN9303_MAC_RX_1023_CNT_0, .name = "Rx1024Byte", },
> +	{ .offset = LAN9303_MAC_RX_MAX_CNT_0, .name = "RxMaxByte", },
> +	{ .offset = LAN9303_MAC_RX_PKTLEN_CNT_0, .name = "RxByteCnt", },
> +	{ .offset = LAN9303_MAC_RX_SYMBL_CNT_0, .name = "RxSymbolCnt", },
> +	{ .offset = LAN9303_MAC_RX_CTLFRM_CNT_0, .name = "RxCfs", },
> +	{ .offset = LAN9303_MAC_RX_OVRSZE_CNT_0, .name = "RxOverFlow", },
> +	{ .offset = LAN9303_MAC_TX_UNDSZE_CNT_0, .name = "TxShort", },
> +	{ .offset = LAN9303_MAC_TX_BRDCST_CNT_0, .name = "TxBroad", },
> +	{ .offset = LAN9303_MAC_TX_PAUSE_CNT_0, .name = "TxPause", },
> +	{ .offset = LAN9303_MAC_TX_MULCST_CNT_0, .name = "TxMulti", },
> +	{ .offset = LAN9303_MAC_RX_UNDSZE_CNT_0, .name = "TxUnderRun", },
> +	{ .offset = LAN9303_MAC_TX_64_CNT_0, .name = "Tx64Byte", },
> +	{ .offset = LAN9303_MAC_TX_127_CNT_0, .name = "Tx128Byte", },
> +	{ .offset = LAN9303_MAC_TX_255_CNT_0, .name = "Tx256Byte", },
> +	{ .offset = LAN9303_MAC_TX_511_CNT_0, .name = "Tx512Byte", },
> +	{ .offset = LAN9303_MAC_TX_1023_CNT_0, .name = "Tx1024Byte", },
> +	{ .offset = LAN9303_MAC_TX_MAX_CNT_0, .name = "TxMaxByte", },
> +	{ .offset = LAN9303_MAC_TX_PKTLEN_CNT_0, .name = "TxByteCnt", },
> +	{ .offset = LAN9303_MAC_TX_PKTOK_CNT_0, .name = "TxOk", },
> +	{ .offset = LAN9303_MAC_TX_TOTALCOL_CNT_0, .name = "TxCollision", },
> +	{ .offset = LAN9303_MAC_TX_MULTICOL_CNT_0, .name = "TxMultiCol", },
> +	{ .offset = LAN9303_MAC_TX_SNGLECOL_CNT_0, .name = "TxSingleCol", },
> +	{ .offset = LAN9303_MAC_TX_EXCOL_CNT_0, .name = "TxExcCol", },
> +	{ .offset = LAN9303_MAC_TX_DEFER_CNT_0, .name = "TxDefer", },
> +	{ .offset = LAN9303_MAC_TX_LATECOL_0, .name = "TxLateCol", },
> +};
> +
> +static void lan9303_get_strings(struct dsa_switch *ds, int port, uint8_t *data)
> +{
> +	unsigned int u;
> +
> +	for (u = 0; u < ARRAY_SIZE(lan9303_mib); u++) {
> +		strncpy(data + u * ETH_GSTRING_LEN, lan9303_mib[u].name,
> +			ETH_GSTRING_LEN);
> +	}
> +}
> +
> +static int lan9303_phy_read(struct dsa_switch *ds, int phy, int regnum)
> +{
> +	struct lan9303 *chip = ds_to_lan9303(ds);
> +	int phy_base = chip->phy_addr_sel_strap;
> +
> +	if (phy == phy_base)
> +		return lan9303_virt_phy_reg_read(chip, regnum);
> +	if (phy > phy_base + 2)
> +		return -ENODEV;
> +
> +	return lan9303_port_phy_reg_read(chip, phy, regnum);
> +}

PHY functions in the middle of stats functions? Maybe move them later?

> +
> +static int lan9303_phy_write(struct dsa_switch *ds, int phy, int regnum,
> +			     u16 val)
> +{
> +	struct lan9303 *chip = ds_to_lan9303(ds);
> +	int phy_base = chip->phy_addr_sel_strap;
> +
> +	if (phy == phy_base)
> +		return lan9303_virt_phy_reg_write(chip, regnum, val);
> +	if (phy > phy_base + 2)
> +		return -ENODEV;
> +
> +	return lan9303_phy_reg_write(chip, phy, regnum, val);

Does the MDIO bus go to the outside world? Could there be external
PHYs?

> +}
> +
> +static void lan9303_get_ethtool_stats(struct dsa_switch *ds, int port,
> +				      uint64_t *data)
> +{
> +	struct lan9303 *chip = ds_to_lan9303(ds);
> +	u32 reg;
> +	unsigned int u, poff;
> +	int ret;
> +
> +	dev_dbg(chip->dev, "%s called\n", __func__);

I think this can be removed.

> +
> +	poff = port * 0x400;
> +
> +	for (u = 0; u < ARRAY_SIZE(lan9303_mib); u++) {
> +		ret = lan9303_read_switch_reg(chip,
> +					      lan9303_mib[u].offset + poff,
> +					      &reg);
> +		if (ret != 0)
> +			dev_warn(chip->dev, "Reading status reg %u failed\n",
> +				 lan9303_mib[u].offset + poff);
> +		data[u] = reg;
> +	}
> +}
> +
> +/* ethtool function used to query the number of statistics items */
> +static int lan9303_get_sset_count(struct dsa_switch *ds)
> +{
> +	return ARRAY_SIZE(lan9303_mib);
> +}
> +
> +/* power on the given port */
> +static int lan9303_port_enable(struct dsa_switch *ds, int port,
> +			       struct phy_device *phy)
> +{
> +	struct lan9303 *chip = ds_to_lan9303(ds);
> +	int rc;

Please be consistent and use ret.

> +
> +	/* enable internal data handling */
> +	switch (port) {
> +	case 1:
> +		rc = lan9303_write_switch_reg(chip, LAN9303_MAC_RX_CFG_1, 0x03);
> +		rc += lan9303_write_switch_reg(chip, LAN9303_MAC_TX_CFG_1,
> +					       0x57);
> +		break;
> +	case 2:
> +		rc = lan9303_write_switch_reg(chip, LAN9303_MAC_RX_CFG_2, 0x03);
> +		rc += lan9303_write_switch_reg(chip, LAN9303_MAC_TX_CFG_2,
> +					       0x57);
> +		break;
> +	default:
> +		dev_dbg(chip->dev, "Error: request to power up invalid port %d\n",
> +			port);
> +		return -ENODEV;
> +	}
> +
> +	return rc;
> +}
> +
> +static void lan9303_port_disable(struct dsa_switch *ds, int port,
> +				 struct phy_device *phy)
> +{
> +	struct lan9303 *chip = ds_to_lan9303(ds);
> +	int rc;
> +
> +	/* disable internal data handling */
> +	switch (port) {
> +	case 1:
> +		rc = lan9303_phy_reg_write(chip, chip->phy_addr_sel_strap + 1,
> +					   0, BIT(14) | BIT(11));
> +		rc += lan9303_write_switch_reg(chip, LAN9303_MAC_RX_CFG_1,
> +					       0x02);
> +		rc += lan9303_write_switch_reg(chip, LAN9303_MAC_TX_CFG_1,
> +					       0x56);

It seems odd that port_enable does not touch the PHY, but port_disable
does. What is this doing?

> +		break;
> +	case 2:
> +		rc = lan9303_phy_reg_write(chip, chip->phy_addr_sel_strap + 2,
> +					   0, BIT(14) | BIT(11));
> +		rc += lan9303_write_switch_reg(chip, LAN9303_MAC_RX_CFG_2,
> +					       0x02);
> +		rc += lan9303_write_switch_reg(chip, LAN9303_MAC_TX_CFG_2,
> +					       0x56);
> +		break;
> +	default:
> +		dev_dbg(chip->dev, "Error: request to power down invalid port %d\n",
> +			port);
> +	}
> +}
> +
> +static struct dsa_switch_ops lan9303_switch_ops = {
> +	.get_tag_protocol = lan9303_get_tag_protocol,
> +	.setup = lan9303_setup,
> +	.get_strings = lan9303_get_strings,
> +	.phy_read = lan9303_phy_read,
> +	.phy_write = lan9303_phy_write,
> +	.get_ethtool_stats = lan9303_get_ethtool_stats,
> +	.get_sset_count = lan9303_get_sset_count,
> +	.port_enable = lan9303_port_enable,
> +	.port_disable = lan9303_port_disable,
> +};
> +
> +static int lan9303_register_phys(struct lan9303 *chip)

This one place where the switch is being called a phy.

> +{
> +	chip->ds.priv = chip;
> +	chip->ds.dev = chip->dev;
> +	chip->ds.ops = &lan9303_switch_ops;
> +	chip->ds.phys_mii_mask = chip->phy_addr_sel_strap ? 0xe : 0x7;
> +
> +	return dsa_register_switch(&chip->ds, chip->dev);
> +}
> +
> +static void lan9303_probe_reset_gpio(struct lan9303 *chip,
> +				     struct device_node *np)
> +{
> +	chip->reset_gpio = devm_gpiod_get_optional(chip->dev, "phy-reset",

This is a reset for the switch, not a PHY in the switch i think. We
have established a bit of a standard in DSA drivers to just call this
"reset".

> +						   GPIOD_OUT_LOW);
> +
> +	if (!chip->reset_gpio) {
> +		dev_dbg(chip->dev, "No reset GPIO defined\n");
> +		return;
> +	}
> +
> +	chip->reset_duration = 200;
> +
> +	if (np) {
> +		of_property_read_u32(np, "phy-reset-duration",
> +				     &chip->reset_duration);
> +	} else {
> +		dev_dbg(chip->dev, "reset duration defaults to 200 ms\n");
> +	}
> +
> +	/* A sane reset duration should not be longer than 1s */
> +	if (chip->reset_duration > 1000)
> +		chip->reset_duration = 1000;
> +}
> +
> +int lan9303_probe(struct lan9303 *chip, struct device_node *np)
> +{
> +	int ret;
> +
> +	mutex_init(&chip->indirect_mutex);
> +
> +	lan9303_probe_reset_gpio(chip, np);
> +
> +	ret = lan9303_handle_reset(chip);
> +	if (ret != 0)
> +		return ret;
> +
> +	ret = lan9303_check_device(chip);
> +	if (ret != 0)
> +		return ret;
> +
> +	ret = lan9303_register_phys(chip);
> +	if (ret != 0)
> +		return ret;
> +
> +	return 0;
> +}
> +
> +int lan9303_remove(struct lan9303 *chip)
> +{
> +	int rc;
> +
> +	rc = lan9303_disable_switching(chip);
> +	if (rc != 0)
> +		dev_warn(chip->dev, "shutting down failed\n");
> +
> +	dsa_unregister_switch(&chip->ds);
> +
> +	/* assert reset to the whole device to prevent it from doing anything */
> +	gpiod_set_value_cansleep(chip->reset_gpio, 1);
> +	gpiod_unexport(chip->reset_gpio);
> +
> +	return 0;
> +}
> +
> +MODULE_AUTHOR("Juergen Borleis <kernel@pengutronix.de>");
> +MODULE_DESCRIPTION("Driver for SMSC/Microchip LAN9303 three port ethernet switch");
> +MODULE_LICENSE("GPL");
> diff --git a/drivers/net/phy/lan9303.h b/drivers/net/phy/lan9303.h
> new file mode 100644
> index 0000000000000..cfb1c5d5fef51
> --- /dev/null
> +++ b/drivers/net/phy/lan9303.h
> @@ -0,0 +1,21 @@
> +#include <linux/regmap.h>
> +#include <linux/device.h>
> +#include <net/dsa.h>
> +
> +struct lan9303 {
> +	struct device *dev;
> +	struct regmap *regmap;
> +	struct regmap_irq_chip_data *irq_data;
> +	struct gpio_desc *reset_gpio;
> +	u32 reset_duration; /* in [ms] */
> +	bool phy_addr_sel_strap;
> +	struct dsa_switch ds;
> +	struct mutex indirect_mutex; /* protect indexed register access */
> +};
> +
> +extern const struct regmap_access_table lan9303_register_set;
> +
> +#define ds_to_lan9303(dsasw) container_of(dsasw, struct lan9303, ds)
> +
> +int lan9303_probe(struct lan9303 *chip, struct device_node *np);
> +int lan9303_remove(struct lan9303 *chip);
> -- 
> 2.11.0
> 

  Andrew
