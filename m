From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH net-next 4/4] net-next: dsa: add dsa support for Mediatek
 MT7530 switch
Date: Mon, 13 Mar 2017 17:41:18 +0100
Message-ID: <20170313164118.GE3953@lunn.ch>
References: <1489421488-300-1-git-send-email-sean.wang@mediatek.com>
 <1489421488-300-5-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mark.rutland-5wv7dgnIgG8@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Landen.Chao-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org,
 f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, keyhaede-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
 linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, objelf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, matthias.bgg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
 davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1489421488-300-5-git-send-email-sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mediatek/>
List-Post: <mailto:linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-mediatek" <linux-mediatek-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Sean

Just looking at the GPIO handling at the moment.

> +	/* Reset whole chip through gpio pin or
> +	 * memory-mapped registers for different
> +	 * type of hardware
> +	 */
> +	if (priv->mcm) {
> +		regmap_update_bits(priv->ethsys, SYSC_REG_RSTCTRL,
> +				   RESET_MCM, RESET_MCM);
> +		usleep_range(1000, 1100);
> +		regmap_update_bits(priv->ethsys, SYSC_REG_RSTCTRL,
> +				   RESET_MCM, ~RESET_MCM);
> +	} else {
> +		gpio_direction_output(priv->reset, 0);
> +		usleep_range(1000, 1100);
> +		gpio_set_value(priv->reset, 1);
> +	}

....

> +	/* Not MCM that indicates switch works as the remote standalone
> +	 * integrated circuit so the GPIO pin would be used to complete
> +	 * the reset, otherwise memory-mapped register accessing used
> +	 * through syscon provides in the case of MCM.
> +	 */
> +	if (!priv->mcm) {
> +		priv->reset = of_get_named_gpio(dn, "mediatek,reset-pin", 0);
> +		if (!gpio_is_valid(priv->reset))
> +			return priv->reset;
> +
> +		ret = devm_gpio_request_one(&mdiodev->dev,
> +					    priv->reset, GPIOF_OUT_INIT_LOW,
> +					    "mediatek,reset-pin");
> +		if (ret < 0) {
> +			dev_err(&mdiodev->dev,
> +				"fail to devm_gpio_request reset\n");
> +			return ret;
> +		}
> +	}

You are not handling the flags part of the GPIO binding. It is better
to use devm_gpiod_ API calls, which will handle the active low flags
for you.

    Andrew
