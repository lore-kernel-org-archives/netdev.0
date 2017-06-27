From: Heiko Stuebner <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH 05/11] net: stmmac: dwmac-rk: Add internal phy support
Date: Tue, 27 Jun 2017 17:40:04 +0200
Message-ID: <2551050.3LrlfzW890@phil>
References: <1498192929-7519-1-git-send-email-david.wu@rock-chips.com> <2805278.mLmlzpUgMM@phil> <924d248f-f1c0-7fa2-4b97-c4f753ffe35b@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
        catalin.marinas-5wv7dgnIgG8@public.gmane.org, will.deacon-5wv7dgnIgG8@public.gmane.org, olof-nZhT3qVonbNeoWH0uzbU5w@public.gmane.org,
        linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org,
        f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
        alexandre.torgue-qxv4g6HH51o@public.gmane.org, huangtao-TNX95d0MmH7DzftRWevZcw@public.gmane.org,
        hwg-TNX95d0MmH7DzftRWevZcw@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David.Wu" <david.wu-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <924d248f-f1c0-7fa2-4b97-c4f753ffe35b-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi David,

Am Dienstag, 27. Juni 2017, 22:33:20 CEST schrieb David.Wu:
> 在 2017/6/24 1:19, Heiko Stuebner 写道:
> > Am Freitag, 23. Juni 2017, 12:59:07 CEST schrieb David Wu:
> >> To make internal phy worked, need to configure the phy_clock,
> >> phy cru_reset and related registers.
> >>
> >> Change-Id: I6971c0a769754b824b1b908b56080cbaf7867d13
> > 
> > please remove all Change-Ids from patches before sending upstream.
> > There were more affected patches in this series.
> > 
> >> Signed-off-by: David Wu <david.wu-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
> >> ---
> >>   .../devicetree/bindings/net/rockchip-dwmac.txt     |  3 +
> >>   drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c     | 82 ++++++++++++++++++++++
> >>   2 files changed, 85 insertions(+)
> >>
> >> diff --git a/Documentation/devicetree/bindings/net/rockchip-dwmac.txt b/Documentation/devicetree/bindings/net/rockchip-dwmac.txt
> >> index 8f42755..0514f69 100644
> >> --- a/Documentation/devicetree/bindings/net/rockchip-dwmac.txt
> >> +++ b/Documentation/devicetree/bindings/net/rockchip-dwmac.txt
> >> @@ -22,6 +22,7 @@ Required properties:
> >>   	   <&cru SCLK_MACREF_OUT> clock gate for RMII reference clock output
> >>   	   <&cru ACLK_GMAC>: AXI clock gate for GMAC
> >>   	   <&cru PCLK_GMAC>: APB clock gate for GMAC
> >> +	   <&cru MAC_PHY>: clock for internal macphy
> > 
> > that clock should not be listed as always "Required" like it is here.
> > Make it some sort of extra paragraph marking it as required when using
> > an internal phy.
> > 
> 
> Okay, move it to the option.
> 
> >>    - clock-names: One name for each entry in the clocks property.
> >>    - phy-mode: See ethernet.txt file in the same directory.
> >>    - pinctrl-names: Names corresponding to the numbered pinctrl states.
> >> @@ -35,6 +36,8 @@ Required properties:
> >>    - assigned-clocks: main clock, should be <&cru SCLK_MAC>;
> >>    - assigned-clock-parents = parent of main clock.
> >>      can be <&ext_gmac> or <&cru SCLK_MAC_PLL>.
> >> + - phy-type: For internal phy, it must be "internal"; For external phy, no need
> >> +   to configure this.
> >>   
> >>   Optional properties:
> >>    - tx_delay: Delay value for TXD timing. Range value is 0~0x7F, 0x30 as default.
> >> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
> >> index a8e8fd5..c1a1413 100644
> >> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
> >> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
> >> @@ -41,6 +41,7 @@ struct rk_gmac_ops {
> >>   	void (*set_to_rmii)(struct rk_priv_data *bsp_priv);
> >>   	void (*set_rgmii_speed)(struct rk_priv_data *bsp_priv, int speed);
> >>   	void (*set_rmii_speed)(struct rk_priv_data *bsp_priv, int speed);
> >> +	void (*internal_phy_powerup)(struct rk_priv_data *bsp_priv);
> >>   };
> >>   
> >>   struct rk_priv_data {
> >> @@ -52,6 +53,7 @@ struct rk_priv_data {
> >>   
> >>   	bool clk_enabled;
> >>   	bool clock_input;
> >> +	bool internal_phy;
> >>   
> >>   	struct clk *clk_mac;
> >>   	struct clk *gmac_clkin;
> >> @@ -61,6 +63,9 @@ struct rk_priv_data {
> >>   	struct clk *clk_mac_refout;
> >>   	struct clk *aclk_mac;
> >>   	struct clk *pclk_mac;
> >> +	struct clk *clk_macphy;
> >> +
> >> +	struct reset_control *macphy_reset;
> >>   
> >>   	int tx_delay;
> >>   	int rx_delay;
> >> @@ -750,6 +755,48 @@ static void rk3399_set_rmii_speed(struct rk_priv_data *bsp_priv, int speed)
> >>   	.set_rmii_speed = rk3399_set_rmii_speed,
> >>   };
> >>   
> >> +#define RK_GRF_MACPHY_CON0		0xb00
> >> +#define RK_GRF_MACPHY_CON1		0xb04
> >> +#define RK_GRF_MACPHY_CON2		0xb08
> >> +#define RK_GRF_MACPHY_CON3		0xb0c
> >> +
> >> +#define RK_MACPHY_ENABLE		GRF_BIT(0)
> >> +#define RK_MACPHY_DISABLE		GRF_CLR_BIT(0)
> >> +#define RK_MACPHY_CFG_CLK_50M		GRF_BIT(14)
> >> +#define RK_GMAC2PHY_RMII_MODE		(GRF_BIT(6) | GRF_CLR_BIT(7))
> >> +#define RK_GRF_CON2_MACPHY_ID		HIWORD_UPDATE(0x1234, 0xffff, 0)
> >> +#define RK_GRF_CON3_MACPHY_ID		HIWORD_UPDATE(0x35, 0x3f, 0)
> > 
> > These are primarily registers for the rk3328 and come from the GRF which is
> > somehow prone to chip-designers moving bits around in registers and also
> > especially the register offsets (*_CONx) will probably not stay the same
> > on future socs.
> > 
> 
> I think they should try to keep the same. But what you said is very 
> reasonable. So let's give rk3228 and rk3328 different 
> internal_phy_powerup() in the rk_gmac_ops to set their own configuration?

I just looked at both the rk3228 and rk3328 GRFs and really this seems
to be the first time I see GRF-parts that are similar :-) .

There is no need to duplicate code unnecessarily, if the registers really
are the same for both. So I guess, just prefix everything with a rk3228_*
and add a comment that the rk3328 uses the same GRF layout.

That way future socs, can then add their (likely) changed register setups
as needed.


Heiko

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
