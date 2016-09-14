From: LABBE Corentin <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC PATCH 9/9] ethernet: sun8i-emac: add pm_runtime support
Date: Wed, 14 Sep 2016 16:03:04 +0200
Message-ID: <20160914140304.GA27639@Red>
References: <1473425117-18645-1-git-send-email-clabbe.montjoie@gmail.com>
 <1473425117-18645-10-git-send-email-clabbe.montjoie@gmail.com>
 <20160912204451.GO9449@lukather>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org,
        linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160912204451.GO9449@lukather>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 12, 2016 at 10:44:51PM +0200, Maxime Ripard wrote:
> Hi,
> 
> On Fri, Sep 09, 2016 at 02:45:17PM +0200, Corentin Labbe wrote:
> > This patch add pm_runtime support to sun8i-emac.
> > For the moment, only basic support is added, (the device is marked as
> > used when net/open)
> > 
> > Signed-off-by: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > ---
> >  drivers/net/ethernet/allwinner/sun8i-emac.c | 62 ++++++++++++++++++++++++++++-
> >  1 file changed, 60 insertions(+), 2 deletions(-)
> > 
> > diff --git a/drivers/net/ethernet/allwinner/sun8i-emac.c b/drivers/net/ethernet/allwinner/sun8i-emac.c
> > index 1c4bc80..cce886e 100644
> > --- a/drivers/net/ethernet/allwinner/sun8i-emac.c
> > +++ b/drivers/net/ethernet/allwinner/sun8i-emac.c
> > @@ -9,7 +9,6 @@
> >   * - MAC filtering
> >   * - Jumbo frame
> >   * - features rx-all (NETIF_F_RXALL_BIT)
> > - * - PM runtime
> >   */
> >  #include <linux/bitops.h>
> >  #include <linux/clk.h>
> > @@ -27,6 +26,7 @@
> >  #include <linux/pinctrl/consumer.h>
> >  #include <linux/pinctrl/pinctrl.h>
> >  #include <linux/platform_device.h>
> > +#include <linux/pm_runtime.h>
> >  #include <linux/reset.h>
> >  #include <linux/scatterlist.h>
> >  #include <linux/skbuff.h>
> > @@ -1301,11 +1301,18 @@ static int sun8i_emac_open(struct net_device *ndev)
> >  	int err;
> >  	u32 v;
> >  
> > +	err = pm_runtime_get_sync(priv->dev);
> > +	if (err) {
> > +		pm_runtime_put_noidle(priv->dev);
> > +		dev_err(priv->dev, "pm_runtime error: %d\n", err);
> > +		return err;
> > +	}
> > +
> >  	err = request_irq(priv->irq, sun8i_emac_dma_interrupt, 0,
> >  			  dev_name(priv->dev), ndev);
> >  	if (err) {
> >  		dev_err(priv->dev, "Cannot request IRQ: %d\n", err);
> > -		return err;
> > +		goto err_runtime;
> >  	}
> >  
> >  	/* Set interface mode (and configure internal PHY on H3) */
> > @@ -1395,6 +1402,8 @@ err_syscon:
> >  	sun8i_emac_unset_syscon(ndev);
> >  err_irq:
> >  	free_irq(priv->irq, ndev);
> > +err_runtime:
> > +	pm_runtime_put(priv->dev);
> >  	return err;
> >  }
> >  
> > @@ -1483,6 +1492,8 @@ static int sun8i_emac_stop(struct net_device *ndev)
> >  	dma_free_coherent(priv->dev, priv->nbdesc_tx * sizeof(struct dma_desc),
> >  			  priv->dd_tx, priv->dd_tx_phy);
> >  
> > +	pm_runtime_put(priv->dev);
> > +
> >  	return 0;
> >  }
> >  
> > @@ -2210,6 +2221,8 @@ static int sun8i_emac_probe(struct platform_device *pdev)
> >  		goto probe_err;
> >  	}
> >  
> > +	pm_runtime_enable(priv->dev);
> > +
> >  	return 0;
> >  
> >  probe_err:
> > @@ -2221,6 +2234,8 @@ static int sun8i_emac_remove(struct platform_device *pdev)
> >  {
> >  	struct net_device *ndev = platform_get_drvdata(pdev);
> >  
> > +	pm_runtime_disable(&pdev->dev);
> > +
> >  	unregister_netdev(ndev);
> >  	platform_set_drvdata(pdev, NULL);
> >  	free_netdev(ndev);
> > @@ -2228,6 +2243,47 @@ static int sun8i_emac_remove(struct platform_device *pdev)
> >  	return 0;
> >  }
> >  
> > +static int __maybe_unused sun8i_emac_suspend(struct platform_device *pdev, pm_message_t state)
> > +{
> > +	struct net_device *ndev = platform_get_drvdata(pdev);
> > +	struct sun8i_emac_priv *priv = netdev_priv(ndev);
> > +
> > +	napi_disable(&priv->napi);
> > +
> > +	if (netif_running(ndev))
> > +		netif_device_detach(ndev);
> > +
> > +	sun8i_emac_stop_tx(ndev);
> > +	sun8i_emac_stop_rx(ndev);
> > +
> > +	sun8i_emac_rx_clean(ndev);
> > +	sun8i_emac_tx_clean(ndev);
> > +
> > +	phy_stop(ndev->phydev);
> > +
> > +	return 0;
> > +}
> > +
> > +static int __maybe_unused sun8i_emac_resume(struct platform_device *pdev)
> > +{
> > +	struct net_device *ndev = platform_get_drvdata(pdev);
> > +	struct sun8i_emac_priv *priv = netdev_priv(ndev);
> > +
> > +	phy_start(ndev->phydev);
> > +
> > +	sun8i_emac_start_tx(ndev);
> > +	sun8i_emac_start_rx(ndev);
> > +
> > +	if (netif_running(ndev))
> > +		netif_device_attach(ndev);
> > +
> > +	netif_start_queue(ndev);
> > +
> > +	napi_enable(&priv->napi);
> > +
> > +	return 0;
> > +}
> 
> The main idea behind the runtime PM hooks is that they bring the
> device to a working state and shuts it down when it's not needed
> anymore.
> 

I expect that the first part (all pm_runtime_xxx) of the patch bring that.
When the interface is not opened:
cat /sys/devices/platform/soc/1c30000.ethernet/power/runtime_status 
suspended

> However, they shouldn't be called when the device is still in used, so
> all the mangling with NAPI, the phy and so on is irrelevant here, but
> the clocks, resets, for example, are.
> 

I do the same as other ethernet driver for suspend/resume.

> >  static const struct of_device_id sun8i_emac_of_match_table[] = {
> >  	{ .compatible = "allwinner,sun8i-a83t-emac",
> >  	  .data = &emac_variant_a83t },
> > @@ -2246,6 +2302,8 @@ static struct platform_driver sun8i_emac_driver = {
> >  		.name           = "sun8i-emac",
> >  		.of_match_table	= sun8i_emac_of_match_table,
> >  	},
> > +	.suspend	= sun8i_emac_suspend,
> > +	.resume		= sun8i_emac_resume,
> 
> These are not the runtime PM hooks. How did you test that?
> 

Anyway I didnt test suspend/resume so I will remove it until I successfully found how to hibernate my board.

Thanks

Regards

Corentin Labbe
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
