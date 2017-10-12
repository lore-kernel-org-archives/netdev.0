From: "Niklas =?iso-8859-1?Q?S=F6derlund?=" <niklas.soderlund@ragnatech.se>
Subject: Re: [PATCH] ravb: Consolidate clock handling
Date: Thu, 12 Oct 2017 15:46:19 +0200
Message-ID: <20171012134619.GE22539@bigcity.dyn.berto.se>
References: <1507796693-14268-1-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Simon Horman <horms+renesas@verge.net.au>,
        netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
To: Geert Uytterhoeven <geert+renesas@glider.be>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1507796693-14268-1-git-send-email-geert+renesas@glider.be>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Geert,

Grate patch!

Reviewed-by: Niklas Söderlund <niklas.soderlund+renesas@ragnatech.se>

On 2017-10-12 10:24:53 +0200, Geert Uytterhoeven wrote:
> The module clock is used for two purposes:
>   - Wake-on-LAN (WoL), which is optional,
>   - gPTP Timer Increment (GTI) configuration, which is mandatory.
> 
> As the clock is needed for GTI configuration anyway, WoL is always
> available.  Hence remove duplication and repeated obtaining of the clock
> by making GTI use the stored clock for WoL use.
> 
> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
> ---
>  drivers/net/ethernet/renesas/ravb_main.c | 35 +++++++++-----------------------
>  1 file changed, 10 insertions(+), 25 deletions(-)
> 
> diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
> index fdf30bfa403bf416..8fad62f08e85e3ac 100644
> --- a/drivers/net/ethernet/renesas/ravb_main.c
> +++ b/drivers/net/ethernet/renesas/ravb_main.c
> @@ -1337,20 +1337,15 @@ static void ravb_get_wol(struct net_device *ndev, struct ethtool_wolinfo *wol)
>  {
>  	struct ravb_private *priv = netdev_priv(ndev);
>  
> -	wol->supported = 0;
> -	wol->wolopts = 0;
> -
> -	if (priv->clk) {
> -		wol->supported = WAKE_MAGIC;
> -		wol->wolopts = priv->wol_enabled ? WAKE_MAGIC : 0;
> -	}
> +	wol->supported = WAKE_MAGIC;
> +	wol->wolopts = priv->wol_enabled ? WAKE_MAGIC : 0;
>  }
>  
>  static int ravb_set_wol(struct net_device *ndev, struct ethtool_wolinfo *wol)
>  {
>  	struct ravb_private *priv = netdev_priv(ndev);
>  
> -	if (!priv->clk || wol->wolopts & ~WAKE_MAGIC)
> +	if (wol->wolopts & ~WAKE_MAGIC)
>  		return -EOPNOTSUPP;
>  
>  	priv->wol_enabled = !!(wol->wolopts & WAKE_MAGIC);
> @@ -1912,22 +1907,12 @@ MODULE_DEVICE_TABLE(of, ravb_match_table);
>  
>  static int ravb_set_gti(struct net_device *ndev)
>  {
> -
> +	struct ravb_private *priv = netdev_priv(ndev);
>  	struct device *dev = ndev->dev.parent;
> -	struct device_node *np = dev->of_node;
>  	unsigned long rate;
> -	struct clk *clk;
>  	uint64_t inc;
>  
> -	clk = of_clk_get(np, 0);
> -	if (IS_ERR(clk)) {
> -		dev_err(dev, "could not get clock\n");
> -		return PTR_ERR(clk);
> -	}
> -
> -	rate = clk_get_rate(clk);
> -	clk_put(clk);
> -
> +	rate = clk_get_rate(priv->clk);
>  	if (!rate)
>  		return -EINVAL;
>  
> @@ -2073,10 +2058,11 @@ static int ravb_probe(struct platform_device *pdev)
>  
>  	priv->chip_id = chip_id;
>  
> -	/* Get clock, if not found that's OK but Wake-On-Lan is unavailable */
>  	priv->clk = devm_clk_get(&pdev->dev, NULL);
> -	if (IS_ERR(priv->clk))
> -		priv->clk = NULL;
> +	if (IS_ERR(priv->clk)) {
> +		error = PTR_ERR(priv->clk);
> +		goto out_release;
> +	}
>  
>  	/* Set function */
>  	ndev->netdev_ops = &ravb_netdev_ops;
> @@ -2144,8 +2130,7 @@ static int ravb_probe(struct platform_device *pdev)
>  	if (error)
>  		goto out_napi_del;
>  
> -	if (priv->clk)
> -		device_set_wakeup_capable(&pdev->dev, 1);
> +	device_set_wakeup_capable(&pdev->dev, 1);
>  
>  	/* Print device information */
>  	netdev_info(ndev, "Base address at %#x, %pM, IRQ %d.\n",
> -- 
> 2.7.4
> 

-- 
Regards,
Niklas Söderlund
