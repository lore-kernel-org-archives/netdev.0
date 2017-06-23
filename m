From: Heiko Stuebner <heiko@sntech.de>
Subject: Re: [PATCH 05/11] net: stmmac: dwmac-rk: Add internal phy support
Date: Fri, 23 Jun 2017 19:19:39 +0200
Message-ID: <2805278.mLmlzpUgMM@phil>
References: <1498192929-7519-1-git-send-email-david.wu@rock-chips.com> <1498193947-8011-1-git-send-email-david.wu@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: davem@davemloft.net, robh+dt@kernel.org, mark.rutland@arm.com,
        catalin.marinas@arm.com, will.deacon@arm.com, olof@lixom.net,
        linux@armlinux.org.uk, arnd@arndb.de, andrew@lunn.ch,
        f.fainelli@gmail.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, huangtao@rock-chips.com,
        hwg@rock-chips.com, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        linux-rockchip@lists.infradead.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Wu <david.wu@rock-chips.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1498193947-8011-1-git-send-email-david.wu@rock-chips.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

Am Freitag, 23. Juni 2017, 12:59:07 CEST schrieb David Wu:
> To make internal phy worked, need to configure the phy_clock,
> phy cru_reset and related registers.
> 
> Change-Id: I6971c0a769754b824b1b908b56080cbaf7867d13

please remove all Change-Ids from patches before sending upstream.
There were more affected patches in this series.

> Signed-off-by: David Wu <david.wu@rock-chips.com>
> ---
>  .../devicetree/bindings/net/rockchip-dwmac.txt     |  3 +
>  drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c     | 82 ++++++++++++++++++++++
>  2 files changed, 85 insertions(+)
> 
> diff --git a/Documentation/devicetree/bindings/net/rockchip-dwmac.txt b/Documentation/devicetree/bindings/net/rockchip-dwmac.txt
> index 8f42755..0514f69 100644
> --- a/Documentation/devicetree/bindings/net/rockchip-dwmac.txt
> +++ b/Documentation/devicetree/bindings/net/rockchip-dwmac.txt
> @@ -22,6 +22,7 @@ Required properties:
>  	   <&cru SCLK_MACREF_OUT> clock gate for RMII reference clock output
>  	   <&cru ACLK_GMAC>: AXI clock gate for GMAC
>  	   <&cru PCLK_GMAC>: APB clock gate for GMAC
> +	   <&cru MAC_PHY>: clock for internal macphy

that clock should not be listed as always "Required" like it is here.
Make it some sort of extra paragraph marking it as required when using
an internal phy.

>   - clock-names: One name for each entry in the clocks property.
>   - phy-mode: See ethernet.txt file in the same directory.
>   - pinctrl-names: Names corresponding to the numbered pinctrl states.
> @@ -35,6 +36,8 @@ Required properties:
>   - assigned-clocks: main clock, should be <&cru SCLK_MAC>;
>   - assigned-clock-parents = parent of main clock.
>     can be <&ext_gmac> or <&cru SCLK_MAC_PLL>.
> + - phy-type: For internal phy, it must be "internal"; For external phy, no need
> +   to configure this.
>  
>  Optional properties:
>   - tx_delay: Delay value for TXD timing. Range value is 0~0x7F, 0x30 as default.
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
> index a8e8fd5..c1a1413 100644
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
> @@ -750,6 +755,48 @@ static void rk3399_set_rmii_speed(struct rk_priv_data *bsp_priv, int speed)
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

These are primarily registers for the rk3328 and come from the GRF which is
somehow prone to chip-designers moving bits around in registers and also
especially the register offsets (*_CONx) will probably not stay the same
on future socs.


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
> +	/* disable macphy, the default value is enabled */

that comment is not providing useful information, maybe
	/* macphy needs to be disabled before trying to reset it */


> +	regmap_write(priv->grf, RK_GRF_MACPHY_CON0, RK_MACPHY_DISABLE);
> +	if (priv->macphy_reset)
> +		reset_control_assert(priv->macphy_reset);
> +	usleep_range(10, 20);
> +	if (priv->macphy_reset)
> +		reset_control_deassert(priv->macphy_reset);
> +	usleep_range(10, 20);
> +	regmap_write(priv->grf, RK_GRF_MACPHY_CON0, RK_MACPHY_ENABLE);
> +	msleep(30);

does this do anything useful if priv->macphy_reset is not set, or could
we just change that to

if (priv->macphy_reset) {
	regmap_write(priv->grf, RK_GRF_MACPHY_CON0, RK_MACPHY_DISABLE);
	reset_control_assert(priv->macphy_reset);
	usleep_range(10, 20);
	reset_control_deassert(priv->macphy_reset);
	usleep_range(10, 20);
	regmap_write(priv->grf, RK_GRF_MACPHY_CON0, RK_MACPHY_ENABLE);
	msleep(30);
}


Heiko
