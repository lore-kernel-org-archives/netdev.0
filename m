From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 3/3] net-next: dsa: add new driver for qca8xxx family
Date: Tue, 13 Sep 2016 03:23:04 +0200
Message-ID: <20160913012304.GC3585@lunn.ch>
References: <1473669337-21221-1-git-send-email-john@phrozen.org>
 <1473669337-21221-4-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        qsdk-review@qca.qualcomm.com
To: John Crispin <john@phrozen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42282 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751561AbcIMBXJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Sep 2016 21:23:09 -0400
Content-Disposition: inline
In-Reply-To: <1473669337-21221-4-git-send-email-john@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +static int
> +qca8k_setup(struct dsa_switch *ds)
> +{
> +	struct qca8k_priv *priv = qca8k_to_priv(ds);
> +	int ret, i, phy_mode = -1;
> +
> +	/* Keep track of which port is the connected to the cpu. This can be
> +	 * phy 11 / port 0 or phy 5 / port 6.
> +	 */
> +	switch (dsa_upstream_port(ds)) {
> +	case 11:
> +		priv->cpu_port = 0;
> +		break;
> +	case 5:
> +		priv->cpu_port = 6;
> +		break;
> +	default:
> +		return -EOPNOTSUPP;
> +	}

Hi John

Can you explain this funkiness with CPU port numbers. Why use 11
instead of 0? I ideally i would like to use 0 here, but if that it not
possible, it needs documenting in the device tree binding that 5 and
11 are special, representing ports 0 and 6.

> +
> +	/* Start by setting up the register mapping */
> +	priv->regmap = devm_regmap_init(ds->dev, NULL, priv,
> +					&qca8k_regmap_config);
> +
> +	if (IS_ERR(priv->regmap))
> +		pr_warn("regmap initialization failed");
> +
> +	/* Initialize CPU port pad mode (xMII type, delays...) */
> +	phy_mode = of_get_phy_mode(ds->ports[ds->dst->cpu_port].dn);
> +	if (phy_mode < 0) {
> +		pr_err("Can't find phy-mode for master device\n");
> +		return phy_mode;
> +	}
> +	ret = qca8k_set_pad_ctrl(priv, priv->cpu_port, phy_mode);
> +	if (ret < 0)
> +		return ret;
> +
> +	/* Enable CPU Port */
> +	qca8k_reg_set(priv, QCA8K_REG_GLOBAL_FW_CTRL0,
> +		      QCA8K_GLOBAL_FW_CTRL0_CPU_PORT_EN);

Does it matter which port is the CPU port here? 11 or 5

> +
> +	/* Enable MIB counters */
> +	qca8k_reg_set(priv, QCA8K_REG_MIB, QCA8K_MIB_CPU_KEEP);
> +	qca8k_write(priv, QCA8K_REG_MODULE_EN, QCA8K_MODULE_EN_MIB);
> +
> +	/* Enable QCA header mode on Port 0 */
> +	qca8k_write(priv, QCA8K_REG_PORT_HDR_CTRL(priv->cpu_port),
> +		    QCA8K_PORT_HDR_CTRL_ALL << QCA8K_PORT_HDR_CTRL_TX_S |
> +		    QCA8K_PORT_HDR_CTRL_ALL << QCA8K_PORT_HDR_CTRL_RX_S);

Does the header mode only work on port 0?

> +static int
> +qca8k_phy_read(struct dsa_switch *ds, int phy, int regnum)
> +{
> +	struct qca8k_priv *priv = qca8k_to_priv(ds);
> +
> +	return mdiobus_read(priv->bus, phy, regnum);
> +}
> +
> +static int
> +qca8k_phy_write(struct dsa_switch *ds, int phy, int regnum, u16 val)
> +{
> +	struct qca8k_priv *priv = qca8k_to_priv(ds);
> +
> +	return mdiobus_write(priv->bus, phy, regnum, val);
> +}

snip

> +static int
> +qca8k_sw_probe(struct mdio_device *mdiodev)
> +{
> +	struct qca8k_priv *priv;
> +	u32 phy_id;
> +
> +	/* sw_addr is irrelevant as the switch occupies the MDIO bus from
> +	 * addresses 0 to 4 (PHYs) and 16-23 (for MDIO 32bits protocol). So
> +	 * we'll probe address 0 to see if we see the right switch family.
> +	 */

So lets see if i have this right.

Port 0 has no internal phy.
Port 1 has an internal PHY at MDIO address 0.
Port 2 has an internal PHY at MDIO address 1.
...
Port 5 has an internal PHY ad MDIO address 4.
Port 6 has no internal PHY.

This is why you have funky port numbers, and phy_to_port.

I think it would be a lot cleaner to handle this in qca8k_phy_read()
and qca8k_phy_write(). 

Also, the comment it a bit misleading. You are probing the PHY ID, not
the switch ID. At least for the Marvell switches, different switches
can have the same embedded PHY. It would be annoying to find there is
another incompatible switch with the same PHY ID.

Is the embedded PHY compatible with the at803x driver?

   Thanks
	Andrew
