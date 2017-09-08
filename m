From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v5 10/10] net: stmmac: dwmac-sun8i: Handle
 integrated/external MDIOs
Date: Fri, 8 Sep 2017 15:05:20 +0200
Message-ID: <20170908130520.GA11248@lunn.ch>
References: <20170908071156.5115-1-clabbe.montjoie@gmail.com>
 <20170908071156.5115-11-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: robh+dt@kernel.org, mark.rutland@arm.com,
        maxime.ripard@free-electrons.com, wens@csie.org,
        linux@armlinux.org.uk, catalin.marinas@arm.com,
        will.deacon@arm.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Corentin Labbe <clabbe.montjoie@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170908071156.5115-11-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +#define DWMAC_sUN8I_MDIO_MUX_INTERNAL_ID	0
> +#define DWMAC_sUN8I_MDIO_MUX_EXTERNAL_ID	1
>  
>  /* H3/A64 specific bits */
>  #define SYSCON_RMII_EN		BIT(13) /* 1: enable RMII (overrides EPIT) */
> @@ -634,6 +639,76 @@ static int sun8i_dwmac_reset(struct stmmac_priv *priv)
>  	return 0;
>  }
>  
> +/* MDIO multiplexing switch function
> + * This function is called by the mdio-mux layer when it thinks the mdio bus
> + * multiplexer needs to switch.
> + * 'current_child' is the current value of the mux register
> + * 'desired_child' is the value of the 'reg' property of the target child MDIO
> + * node.
> + * The first time this function is called, current_child == -1.
> + * If current_child == desired_child, then the mux is already set to the
> + * correct bus.
> + *
> + * Note that we do not use reg/mask like mdio-mux-mmioreg because we need to
> + * know easily which bus is used (reset must be done only for desired bus).
> + */
> +static int mdio_mux_syscon_switch_fn(int current_child, int desired_child,
> +				     void *data)
> +{
> +	struct stmmac_priv *priv = data;
> +	struct sunxi_priv_data *gmac = priv->plat->bsp_priv;
> +	u32 reg, val;
> +	int ret = 0;
> +	bool need_reset = false;
> +
> +	if (current_child ^ desired_child) {
> +		regmap_read(gmac->regmap, SYSCON_EMAC_REG, &reg);
> +		switch (desired_child) {
> +		case DWMAC_sUN8I_MDIO_MUX_INTERNAL_ID:
> +			dev_info(priv->device, "Switch mux to internal PHY");
> +			val = (reg & ~H3_EPHY_MUX_MASK) | H3_EPHY_SELECT;
> +			if (gmac->use_internal_phy)
> +				need_reset = true;
> +			break;

This i don't get. Why do you need use_internal_phy? Isn't that
implicit from DWMAC_sUN8I_MDIO_MUX_INTERNAL_ID? Is it even possible to
use an external PHY on the internal MDIO bus?

> +		case DWMAC_sUN8I_MDIO_MUX_EXTERNAL_ID:
> +			dev_info(priv->device, "Switch mux to external PHY");
> +			val = (reg & ~H3_EPHY_MUX_MASK) | H3_EPHY_SHUTDOWN;
> +			if (!gmac->use_internal_phy)
> +				need_reset = true;
> +			break;

And is it possible to use the internal PHY on the external bus?

    Andrew
