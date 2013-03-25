From: Mike Turquette <mturquette@linaro.org>
Subject: Re: [PATCH net-next 2/2] net/davinci_emac: use clk_{prepare|unprepare}
Date: Mon, 25 Mar 2013 09:16:54 -0700
Message-ID: <20130325161654.4014.68401@quantum>
References: <1364203547-2960-1-git-send-email-nsekhar@ti.com>
 <1364203547-2960-3-git-send-email-nsekhar@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>,
	<davinci-linux-open-source@linux.davincidsp.com>,
	Sekhar Nori <nsekhar@ti.com>
To: Sekhar Nori <nsekhar@ti.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:45130 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758200Ab3CYQRJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Mar 2013 12:17:09 -0400
Received: by mail-pb0-f51.google.com with SMTP id rr4so1569417pbb.10
        for <netdev@vger.kernel.org>; Mon, 25 Mar 2013 09:17:09 -0700 (PDT)
In-Reply-To: <1364203547-2960-3-git-send-email-nsekhar@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Sekhar Nori (2013-03-25 02:25:47)
> Use clk_prepare()/clk_unprepare() in the driver since common
> clock framework needs these to be called before clock is enabled.
> 
> This is in preparation of common clock framework migration
> for DaVinci.
> 
> Cc: Mike Turquette <mturquette@linaro.org>
> Signed-off-by: Sekhar Nori <nsekhar@ti.com>
> ---
>  drivers/net/ethernet/ti/davinci_emac.c |   19 +++++++++++++++++--
>  1 file changed, 17 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
> index b1349b5..436296c 100644
> --- a/drivers/net/ethernet/ti/davinci_emac.c
> +++ b/drivers/net/ethernet/ti/davinci_emac.c
> @@ -350,6 +350,7 @@ struct emac_priv {
>         /*platform specific members*/
>         void (*int_enable) (void);
>         void (*int_disable) (void);
> +       struct clk *clk;
>  };
>  
>  /* EMAC TX Host Error description strings */
> @@ -1870,19 +1871,29 @@ static int davinci_emac_probe(struct platform_device *pdev)
>                 dev_err(&pdev->dev, "failed to get EMAC clock\n");
>                 return -EBUSY;
>         }
> +
> +       rc = clk_prepare(emac_clk);
> +       if (rc) {
> +               dev_err(&pdev->dev, "emac clock prepare failed.\n");
> +               return rc;
> +       }
> +

Is clk_enable ever called for emac_clk here?  I don't see it in the
diff.  clk_prepare and clk_enable should usually be paired, even if
simply calling clk_prepare generates the clock signal that your device
needs.

Also this change only calls clk_prepare at probe-time and clk_unprepare
at remove-time.  Preparing a clock can result in power consumption.
With that in mind should your implementation be more aggressive about
calling clk_{un}prepare?

Regards,
Mike

>         emac_bus_frequency = clk_get_rate(emac_clk);
>  
>         /* TODO: Probe PHY here if possible */
>  
>         ndev = alloc_etherdev(sizeof(struct emac_priv));
> -       if (!ndev)
> -               return -ENOMEM;
> +       if (!ndev) {
> +               rc = -ENOMEM;
> +               goto no_etherdev;
> +       }
>  
>         platform_set_drvdata(pdev, ndev);
>         priv = netdev_priv(ndev);
>         priv->pdev = pdev;
>         priv->ndev = ndev;
>         priv->msg_enable = netif_msg_init(debug_level, DAVINCI_EMAC_DEBUG);
> +       priv->clk = emac_clk;
>  
>         spin_lock_init(&priv->lock);
>  
> @@ -2020,6 +2031,8 @@ no_cpdma_chan:
>         cpdma_ctlr_destroy(priv->dma);
>  no_pdata:
>         free_netdev(ndev);
> +no_etherdev:
> +       clk_unprepare(emac_clk);
>         return rc;
>  }
>  
> @@ -2048,6 +2061,8 @@ static int davinci_emac_remove(struct platform_device *pdev)
>         unregister_netdev(ndev);
>         free_netdev(ndev);
>  
> +       clk_unprepare(priv->clk);
> +
>         return 0;
>  }
>  
> -- 
> 1.7.10.1
