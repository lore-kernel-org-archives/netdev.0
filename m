From: Mikko Perttunen <cyndis-/1wQRMveznE@public.gmane.org>
Subject: Re: [PATCH 2/7] net: stmmac: Balance PTP reference clock
 enable/disable
Date: Mon, 27 Feb 2017 11:31:39 +0200
Message-ID: <53f18077-6a4d-339f-192e-287a1f889fb7@kapsi.fi>
References: <20170223172438.14770-1-thierry.reding@gmail.com>
 <20170223172438.14770-3-thierry.reding@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        Alexandre Torgue <alexandre.torgue-qxv4g6HH51o@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Joao Pinto <Joao.Pinto-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>,
        Alexandre Courbot <gnurou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Jon Hunter <jonathanh-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Thierry Reding <thierry.reding-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170223172438.14770-3-thierry.reding-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 23.02.2017 19:24, Thierry Reding wrote:
> From: Thierry Reding <treding-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
>
> clk_prepare_enable() and clk_disable_unprepare() for this clock aren't
> properly balanced, which can trigger a WARN_ON() in the common clock
> framework.
>
> Signed-off-by: Thierry Reding <treding-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c     | 4 ++++
>  drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 1 -
>  2 files changed, 4 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 3cbe09682afe..6b7a5ce19589 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -1711,6 +1711,10 @@ static int stmmac_hw_setup(struct net_device *dev, bool init_ptp)
>  	stmmac_mmc_setup(priv);
>
>  	if (init_ptp) {
> +		ret = clk_prepare_enable(priv->plat->clk_ptp_ref);
> +		if (ret < 0)
> +			netdev_warn(priv->dev, "failed to enable PTP reference clock: %d\n", ret);
> +

Should we return an error code if the clock enable fails?

>  		ret = stmmac_init_ptp(priv);
>  		if (ret == -EOPNOTSUPP)
>  			netdev_warn(priv->dev, "PTP not supported by HW\n");
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> index 5b18355c0d2b..d285d6cfbd0d 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> @@ -365,7 +365,6 @@ stmmac_probe_config_dt(struct platform_device *pdev, const char **mac)
>  		plat->clk_ptp_ref = NULL;
>  		dev_warn(&pdev->dev, "PTP uses main clock\n");
>  	} else {
> -		clk_prepare_enable(plat->clk_ptp_ref);
>  		plat->clk_ptp_rate = clk_get_rate(plat->clk_ptp_ref);
>  		dev_dbg(&pdev->dev, "PTP rate %d\n", plat->clk_ptp_rate);
>  	}
>

It seems like there will still be a refcount mismatch for the clock if 
any of the request_irqs that are after stmmac_hw_setup in stmmac_open fail.

Cheers,
Mikko.
