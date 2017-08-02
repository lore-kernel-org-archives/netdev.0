From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v3 05/11] net: stmmac: dwmac-rk: Add internal phy support
Date: Wed, 2 Aug 2017 10:38:04 -0700
Message-ID: <6b1ebf64-6903-6d35-b1fc-92ec47334425@gmail.com>
References: <1501654546-17292-1-git-send-email-david.wu@rock-chips.com>
 <1501654888-19514-1-git-send-email-david.wu@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: peppe.cavallaro-qxv4g6HH51o@public.gmane.org, alexandre.torgue-qxv4g6HH51o@public.gmane.org,
        huangtao-TNX95d0MmH7DzftRWevZcw@public.gmane.org, hwg-TNX95d0MmH7DzftRWevZcw@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Wu <david.wu-TNX95d0MmH7DzftRWevZcw@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
        mark.rutland-5wv7dgnIgG8@public.gmane.org, catalin.marinas-5wv7dgnIgG8@public.gmane.org, will.deacon-5wv7dgnIgG8@public.gmane.org,
        olof-nZhT3qVonbNeoWH0uzbU5w@public.gmane.org, linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1501654888-19514-1-git-send-email-david.wu-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Content-Language: en-US
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 08/01/2017 11:21 PM, David Wu wrote:
> To make internal phy work, need to configure the phy_clock,
> phy cru_reset and related registers.
> 
> Signed-off-by: David Wu <david.wu-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
> ---
>  .../devicetree/bindings/net/rockchip-dwmac.txt     |  6 +-
>  drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c     | 81 ++++++++++++++++++++++
>  2 files changed, 86 insertions(+), 1 deletion(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/rockchip-dwmac.txt b/Documentation/devicetree/bindings/net/rockchip-dwmac.txt
> index 8f42755..ec39b31 100644
> --- a/Documentation/devicetree/bindings/net/rockchip-dwmac.txt
> +++ b/Documentation/devicetree/bindings/net/rockchip-dwmac.txt
> @@ -25,7 +25,8 @@ Required properties:
>   - clock-names: One name for each entry in the clocks property.
>   - phy-mode: See ethernet.txt file in the same directory.
>   - pinctrl-names: Names corresponding to the numbered pinctrl states.
> - - pinctrl-0: pin-control mode. can be <&rgmii_pins> or <&rmii_pins>.
> + - pinctrl-0: pin-control mode. can be <&rgmii_pins>, <&rmii_pins> or led pins
> +   for internal phy mode.
>   - clock_in_out: For RGMII, it must be "input", means main clock(125MHz)
>     is not sourced from SoC's PLL, but input from PHY; For RMII, "input" means
>     PHY provides the reference clock(50MHz), "output" means GMAC provides the
> @@ -40,6 +41,9 @@ Optional properties:
>   - tx_delay: Delay value for TXD timing. Range value is 0~0x7F, 0x30 as default.
>   - rx_delay: Delay value for RXD timing. Range value is 0~0x7F, 0x10 as default.
>   - phy-supply: phandle to a regulator if the PHY needs one
> + - clocks: <&cru MAC_PHY>: Clock selector for internal macphy
> + - phy-is-internal: A boolean property allows us to know that MAC will connect to
> +   internal phy.

This is incorrect in two ways:

- this is a property of the PHY, so it should be documented as such in
Documentation/devicetree/bindings/net/phy.txt so other bindings can
re-use it

- if it was specific to your MAC you would expect a vendor prefix to
this property, which is not there

An alternative way to implement the external/internal logic selection
would be mandate that your Ethernet PHY node have a compatible string
like this:

phy@0 {
	compatible = "ethernet-phy-id1234.d400", "ethernet-phy-802.3-c22";
};

Then you don't need this phy-is-internal property, because you can
locate the PHY node by the phy-handle (see more about that in a reply to
patch 10) and you can determine ahead of time whether this PHY is
internal or not based on its compatible string.

Thank you

>  
>  Example:
>  
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
> index a8e8fd5..7b80ab9 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
> @@ -41,6 +41,7 @@ struct rk_gmac_ops {
>  	void (*set_to_rmii)(struct rk_priv_data *bsp_priv);
>  	void (*set_rgmii_speed)(struct rk_priv_data *bsp_priv, int speed);
>  	void (*set_rmii_speed)(struct rk_priv_data *bsp_priv, int speed);
> +	void (*internal_phy_powerup)(struct rk_priv_data *bsp_priv);
>  };
>  
>  struct rk_priv_data {
> @@ -52,6 +53,7 @@ struct rk_priv_data {
>  
>  	bool clk_enabled;
>  	bool clock_input;
> +	bool internal_phy;
>  
>  	struct clk *clk_mac;
>  	struct clk *gmac_clkin;
> @@ -61,6 +63,9 @@ struct rk_priv_data {
>  	struct clk *clk_mac_refout;
>  	struct clk *aclk_mac;
>  	struct clk *pclk_mac;
> +	struct clk *clk_macphy;
> +
> +	struct reset_control *macphy_reset;
>  
>  	int tx_delay;
>  	int rx_delay;
> @@ -750,6 +755,50 @@ static void rk3399_set_rmii_speed(struct rk_priv_data *bsp_priv, int speed)
>  	.set_rmii_speed = rk3399_set_rmii_speed,
>  };
>  
> +#define RK_GRF_MACPHY_CON0		0xb00
> +#define RK_GRF_MACPHY_CON1		0xb04
> +#define RK_GRF_MACPHY_CON2		0xb08
> +#define RK_GRF_MACPHY_CON3		0xb0c
> +
> +#define RK_MACPHY_ENABLE		GRF_BIT(0)
> +#define RK_MACPHY_DISABLE		GRF_CLR_BIT(0)
> +#define RK_MACPHY_CFG_CLK_50M		GRF_BIT(14)
> +#define RK_GMAC2PHY_RMII_MODE		(GRF_BIT(6) | GRF_CLR_BIT(7))
> +#define RK_GRF_CON2_MACPHY_ID		HIWORD_UPDATE(0x1234, 0xffff, 0)
> +#define RK_GRF_CON3_MACPHY_ID		HIWORD_UPDATE(0x35, 0x3f, 0)
> +
> +static void rk_gmac_internal_phy_powerup(struct rk_priv_data *priv)
> +{
> +	if (priv->ops->internal_phy_powerup)
> +		priv->ops->internal_phy_powerup(priv);
> +
> +	regmap_write(priv->grf, RK_GRF_MACPHY_CON0, RK_MACPHY_CFG_CLK_50M);
> +	regmap_write(priv->grf, RK_GRF_MACPHY_CON0, RK_GMAC2PHY_RMII_MODE);
> +
> +	regmap_write(priv->grf, RK_GRF_MACPHY_CON2, RK_GRF_CON2_MACPHY_ID);
> +	regmap_write(priv->grf, RK_GRF_MACPHY_CON3, RK_GRF_CON3_MACPHY_ID);
> +
> +	if (priv->macphy_reset) {
> +		/* macphy needs to be disabled before trying to reset it */
> +		regmap_write(priv->grf, RK_GRF_MACPHY_CON0, RK_MACPHY_DISABLE);
> +		if (priv->macphy_reset)
> +			reset_control_assert(priv->macphy_reset);
> +		usleep_range(10, 20);
> +		if (priv->macphy_reset)
> +			reset_control_deassert(priv->macphy_reset);
> +		usleep_range(10, 20);
> +		regmap_write(priv->grf, RK_GRF_MACPHY_CON0, RK_MACPHY_ENABLE);
> +		msleep(30);
> +	}
> +}
> +
> +static void rk_gmac_internal_phy_powerdown(struct rk_priv_data *priv)
> +{
> +	regmap_write(priv->grf, RK_GRF_MACPHY_CON0, RK_MACPHY_DISABLE);
> +	if (priv->macphy_reset)
> +		reset_control_assert(priv->macphy_reset);
> +}
> +
>  static int gmac_clk_init(struct rk_priv_data *bsp_priv)
>  {
>  	struct device *dev = &bsp_priv->pdev->dev;
> @@ -803,6 +852,14 @@ static int gmac_clk_init(struct rk_priv_data *bsp_priv)
>  			clk_set_rate(bsp_priv->clk_mac, 50000000);
>  	}
>  
> +	if (bsp_priv->internal_phy) {
> +		bsp_priv->clk_macphy = devm_clk_get(dev, "clk_macphy");
> +		if (IS_ERR(bsp_priv->clk_macphy))
> +			dev_err(dev, "cannot get %s clock\n", "clk_macphy");
> +		else
> +			clk_set_rate(bsp_priv->clk_macphy, 50000000);
> +	}
> +
>  	return 0;
>  }
>  
> @@ -826,6 +883,9 @@ static int gmac_clk_enable(struct rk_priv_data *bsp_priv, bool enable)
>  						bsp_priv->clk_mac_refout);
>  			}
>  
> +			if (!IS_ERR(bsp_priv->clk_macphy))
> +				clk_prepare_enable(bsp_priv->clk_macphy);
> +
>  			if (!IS_ERR(bsp_priv->aclk_mac))
>  				clk_prepare_enable(bsp_priv->aclk_mac);
>  
> @@ -858,6 +918,9 @@ static int gmac_clk_enable(struct rk_priv_data *bsp_priv, bool enable)
>  						bsp_priv->clk_mac_refout);
>  			}
>  
> +			if (!IS_ERR(bsp_priv->clk_macphy))
> +				clk_disable_unprepare(bsp_priv->clk_macphy);
> +
>  			if (!IS_ERR(bsp_priv->aclk_mac))
>  				clk_disable_unprepare(bsp_priv->aclk_mac);
>  
> @@ -940,6 +1003,18 @@ static struct rk_priv_data *rk_gmac_setup(struct platform_device *pdev,
>  			bsp_priv->clock_input = false;
>  	}
>  
> +	bsp_priv->internal_phy = device_property_read_bool(dev,
> +							   "phy-is-internal");
> +	if (bsp_priv->internal_phy) {
> +		bsp_priv->macphy_reset = devm_reset_control_get(dev, "mac-phy");
> +		if (IS_ERR(bsp_priv->macphy_reset)) {
> +			dev_info(dev, "no macphy_reset control found\n");
> +			bsp_priv->macphy_reset = NULL;
> +		}
> +	}
> +	dev_info(dev, "internal PHY? (%s).\n",
> +		 bsp_priv->internal_phy ? "yes" : "no");
> +
>  	ret = of_property_read_u32(dev->of_node, "tx_delay", &value);
>  	if (ret) {
>  		bsp_priv->tx_delay = 0x30;
> @@ -1014,6 +1089,9 @@ static int rk_gmac_powerup(struct rk_priv_data *bsp_priv)
>  	pm_runtime_enable(dev);
>  	pm_runtime_get_sync(dev);
>  
> +	if (bsp_priv->internal_phy)
> +		rk_gmac_internal_phy_powerup(bsp_priv);
> +
>  	return 0;
>  }
>  
> @@ -1021,6 +1099,9 @@ static void rk_gmac_powerdown(struct rk_priv_data *gmac)
>  {
>  	struct device *dev = &gmac->pdev->dev;
>  
> +	if (gmac->internal_phy)
> +		rk_gmac_internal_phy_powerdown(gmac);
> +
>  	pm_runtime_put_sync(dev);
>  	pm_runtime_disable(dev);
>  
> 


-- 
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
