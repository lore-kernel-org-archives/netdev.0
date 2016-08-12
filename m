From: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 2/4] net: hix5hd2_gmac: add reset control and clock
 signals
Date: Fri, 12 Aug 2016 13:48:24 -0500
Message-ID: <20160812184824.GA8959@rob-hp-laptop>
References: <1470906115-155569-1-git-send-email-lidongpo@hisilicon.com>
 <1470906115-155569-3-git-send-email-lidongpo@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mark.rutland-5wv7dgnIgG8@public.gmane.org, mturquette-rdvid1DuHRBWk0Htik3J/w@public.gmane.org,
	sboyd-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org,
	zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org,
	andrew-g2DYL2Zd6BY@public.gmane.org, xuejiancheng-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org,
	benjamin.chenhao-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org, howell.yang-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Dongpo Li <lidongpo-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1470906115-155569-3-git-send-email-lidongpo-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 11, 2016 at 05:01:53PM +0800, Dongpo Li wrote:
> From: Li Dongpo <lidongpo-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
> 
> Add three reset control signals, "mac_core_rst", "mac_ifc_rst" and
> "phy_rst".
> The following diagram explained how the reset signals work.
> 
>                         SoC
> |-----------------------------------------------------
> |                               ------                |
> |                               | cpu |               |
> |                               ------                |
> |                                  |                  |
> |                              ------------ AMBA bus  |
> |                         GMAC     |                  |
> |                            ----------------------   |
> | ------------- mac_core_rst | --------------      |  |
> | |clock and   |-------------->|   mac core  |     |  |
> | |reset       |             | --------------      |  |
> | |generator   |----         |       |             |  |
> | -------------     |        | ----------------    |  |
> |          |        ---------->| mac interface |   |  |
> |          |     mac_ifc_rst | ----------------    |  |
> |          |                 |       |             |  |
> |          |                 | ------------------  |  |
> |          |phy_rst          | | RGMII interface | |  |
> |          |                 | ------------------  |  |
> |          |                 ----------------------   |
> |----------|------------------------------------------|
>            |                          |
>            |                      ----------
>            |--------------------- |PHY chip |
>                                   ----------
> 
> The "mac_core_rst" represents "mac core reset signal", it resets
> the mac core including packet processing unit, descriptor processing unit,
> tx engine, rx engine, control unit.
> The "mac_ifc_rst" represents "mac interface reset signal", it resets
> the mac interface. The mac interface unit connects mac core and
> data interface like MII/RMII/RGMII. After we set a new value of
> interface mode, we must reset mac interface to reload the new mode value.
> The "phy_rst" represents "phy reset signal", it does a hardware reset
> on the PHY chip. This reset signal is optinal if the PHY can work well
> without the hardware reset.
> 
> Add one more clock signal, the existing is MAC core clock,
> and the new one is MAC interface clock.
> 
> Signed-off-by: Dongpo Li <lidongpo-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
> ---
>  .../bindings/net/hisilicon-hix5hd2-gmac.txt        |  16 ++-
>  drivers/net/ethernet/hisilicon/hix5hd2_gmac.c      | 140 +++++++++++++++++++--
>  2 files changed, 143 insertions(+), 13 deletions(-)


> 
> @@ -807,16 +829,26 @@ static int hix5hd2_net_open(struct net_device *dev)
>  	struct phy_device *phy;
>  	int ret;
>  
> -	ret = clk_prepare_enable(priv->clk);
> +	ret = clk_prepare_enable(priv->mac_core_clk);
> +	if (ret < 0) {
> +		netdev_err(dev, "failed to enable mac core clk %d\n", ret);
> +		return ret;
> +	}
> +
> +	ret = clk_prepare_enable(priv->mac_ifc_clk);
>  	if (ret < 0) {
> -		netdev_err(dev, "failed to enable clk %d\n", ret);
> +		clk_disable_unprepare(priv->mac_core_clk);
> +		netdev_err(dev, "failed to enable mac ifc clk %d\n", ret);

This change will break with existing DTs. The mac_ifc_clk should be 
optional.

Rob

>  		return ret;
>  	}
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
