From: Russell King - ARM Linux <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>
Subject: Re: [PATCHv2 net-next 15/16] net: mvpp2: add support for an
 additional clock needed for PPv2.2
Date: Sat, 7 Jan 2017 09:29:29 +0000
Message-ID: <20170107092929.GH14217@n2100.armlinux.org.uk>
References: <1482943592-12556-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <1482943592-12556-16-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
        Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Yehuda Yitschak <yehuday-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
        Jason Cooper <jason-NLaQJdtUoK4Be96aLqz0jA@public.gmane.org>,
        Hanna Hawa <hannah-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
        Nadav Haklai <nadavh-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
        Gregory Clement <gregory.clement-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
        Stefan Chulski <stefanc-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
        Marcin Wojtas <mw-nYOzD4b6Jr9Wk0Htik3J/w@public.gmane.org>,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1482943592-12556-16-git-send-email-thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 28, 2016 at 05:46:31PM +0100, Thomas Petazzoni wrote:
> The PPv2.2 variant of the network controller needs an additional
> clock, the "MG clock" in order for the IP block to operate
> properly. This commit adds support for this additional clock to the
> driver, reworking as needed the error handling path.

There's more clocks that are required.

Firstly, what I'm finding is that the MDIO block in the CP110 does not
work at all (locks the system up if accessed) if these clocks are not
enabled:

	cpm_syscon0 1 9, cpm_syscon0 1 6, cpm_syscon0 1 5

The XMDIO block requires the same clocks to be functional.  Since the
MDIO and XMDIO blocks are actually part of the ethernet controller,
it's not that surprising.

We can't rely on the ethernet controller having been probed, because
the 8k has two sets of MDIO buses - one set per CP110.  It's entirely
possible that people will put all their PHYs for both CP110 instances
on one set of MDIO buses (eg, the master).  Indeed, this is exactly
what SolidRun have done, and hence how I found the problem.

So, it looks to me like DT doesn't actually describe the hardware here -
especially when looking at the reg properties, they overlap with each
other.

> Signed-off-by: Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
> ---
>  drivers/net/ethernet/marvell/mvpp2.c | 25 +++++++++++++++++++++----
>  1 file changed, 21 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
> index 20e9429..194de00 100644
> --- a/drivers/net/ethernet/marvell/mvpp2.c
> +++ b/drivers/net/ethernet/marvell/mvpp2.c
> @@ -702,6 +702,7 @@ struct mvpp2 {
>  	/* Common clocks */
>  	struct clk *pp_clk;
>  	struct clk *gop_clk;
> +	struct clk *mg_clk;
>  
>  	/* List of pointers to port structures */
>  	struct mvpp2_port **port_list;
> @@ -6899,6 +6900,18 @@ static int mvpp2_probe(struct platform_device *pdev)
>  	if (err < 0)
>  		goto err_pp_clk;
>  
> +	if (priv->hw_version == MVPP22) {
> +		priv->mg_clk = devm_clk_get(&pdev->dev, "mg_clk");
> +		if (IS_ERR(priv->mg_clk)) {
> +			err = PTR_ERR(priv->mg_clk);
> +			goto err_gop_clk;
> +		}
> +
> +		err = clk_prepare_enable(priv->mg_clk);
> +		if (err < 0)
> +			goto err_gop_clk;
> +	}
> +
>  	/* Get system's tclk rate */
>  	priv->tclk = clk_get_rate(priv->pp_clk);
>  
> @@ -6906,14 +6919,14 @@ static int mvpp2_probe(struct platform_device *pdev)
>  	err = mvpp2_init(pdev, priv);
>  	if (err < 0) {
>  		dev_err(&pdev->dev, "failed to initialize controller\n");
> -		goto err_gop_clk;
> +		goto err_mg_clk;
>  	}
>  
>  	port_count = of_get_available_child_count(dn);
>  	if (port_count == 0) {
>  		dev_err(&pdev->dev, "no ports enabled\n");
>  		err = -ENODEV;
> -		goto err_gop_clk;
> +		goto err_mg_clk;
>  	}
>  
>  	priv->port_list = devm_kcalloc(&pdev->dev, port_count,
> @@ -6921,19 +6934,22 @@ static int mvpp2_probe(struct platform_device *pdev)
>  				      GFP_KERNEL);
>  	if (!priv->port_list) {
>  		err = -ENOMEM;
> -		goto err_gop_clk;
> +		goto err_mg_clk;
>  	}
>  
>  	/* Initialize ports */
>  	for_each_available_child_of_node(dn, port_node) {
>  		err = mvpp2_port_probe(pdev, port_node, priv);
>  		if (err < 0)
> -			goto err_gop_clk;
> +			goto err_mg_clk;
>  	}
>  
>  	platform_set_drvdata(pdev, priv);
>  	return 0;
>  
> +err_mg_clk:
> +	if (priv->hw_version == MVPP22)
> +		clk_disable_unprepare(priv->mg_clk);
>  err_gop_clk:
>  	clk_disable_unprepare(priv->gop_clk);
>  err_pp_clk:
> @@ -6969,6 +6985,7 @@ static int mvpp2_remove(struct platform_device *pdev)
>  				  aggr_txq->descs_phys);
>  	}
>  
> +	clk_disable_unprepare(priv->mg_clk);
>  	clk_disable_unprepare(priv->pp_clk);
>  	clk_disable_unprepare(priv->gop_clk);
>  
> -- 
> 2.7.4
> 
> 
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
