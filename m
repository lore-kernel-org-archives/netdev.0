From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 3/3] net-next: dsa: add new driver for qca8xxx family
Date: Tue, 13 Sep 2016 02:40:47 +0200
Message-ID: <20160913004047.GB3585@lunn.ch>
References: <1473669337-21221-1-git-send-email-john@phrozen.org>
 <1473669337-21221-4-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        qsdk-review@qca.qualcomm.com
To: John Crispin <john@phrozen.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1473669337-21221-4-git-send-email-john@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi John

> +static u16
> +qca8k_phy_mmd_read(struct qca8k_priv *priv, int phy_addr, u16 addr, u16 reg)
> +{
> +	u16 data;
> +
> +	mutex_lock(&priv->bus->mdio_lock);
> +
> +	priv->bus->write(priv->bus, phy_addr, MII_ATH_MMD_ADDR, addr);
> +	priv->bus->write(priv->bus, phy_addr, MII_ATH_MMD_DATA, reg);
> +	priv->bus->write(priv->bus, phy_addr, MII_ATH_MMD_ADDR, addr | 0x4000);
> +	data = priv->bus->read(priv->bus, phy_addr, MII_ATH_MMD_DATA);
> +
> +	mutex_unlock(&priv->bus->mdio_lock);
> +
> +	return data;
> +}

snip

> +static int
> +qca8k_get_eee(struct dsa_switch *ds, int port,
> +	      struct ethtool_eee *e)
> +{
> +	struct qca8k_priv *priv = qca8k_to_priv(ds);
> +	struct ethtool_eee *p = &priv->port_sts[qca8k_phy_to_port(port)].eee;
> +	u32 lp, adv, supported;
> +	u16 val;
> +
> +	/* The switch has no way to tell the result of the AN so we need to
> +	 * read the result directly from the PHYs MMD registers
> +	 */
> +	val = qca8k_phy_mmd_read(priv, port, MDIO_MMD_PCS, MDIO_PCS_EEE_ABLE);
> +	supported = mmd_eee_cap_to_ethtool_sup_t(val);
> +
> +	val = qca8k_phy_mmd_read(priv, port, MDIO_MMD_AN, MDIO_AN_EEE_ADV);
> +	adv = mmd_eee_adv_to_ethtool_adv_t(val);
> +
> +	val = qca8k_phy_mmd_read(priv, port, MDIO_MMD_AN, MDIO_AN_EEE_LPABLE);
> +	lp = mmd_eee_adv_to_ethtool_adv_t(val);
> +
> +	e->eee_enabled = p->eee_enabled;
> +	e->eee_active = !!(supported & adv & lp);
> +
> +	return 0;
> +}

Couldn't you just call phy_ethtool_get_eee(phydev)? Then you don't
need qca8k_phy_mmd_read()?

     Andrew
