From: Petri Gynther <pgynther@google.com>
Subject: Re: [PATCH net-next v2] net: bcmgenet: Remove checks on clock handles
Date: Wed, 22 Jul 2015 21:39:14 -0700
Message-ID: <CAGXr9JEpJi7E4HMJvL8cs4pbYoGU6uOJqbjxt36URvhfHYGBNg@mail.gmail.com>
References: <1437611303-29011-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jaedon Shin <jaedon.shin@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:37252 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750789AbbGWEjP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2015 00:39:15 -0400
Received: by wibud3 with SMTP id ud3so200472814wib.0
        for <netdev@vger.kernel.org>; Wed, 22 Jul 2015 21:39:14 -0700 (PDT)
In-Reply-To: <1437611303-29011-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 22, 2015 at 5:28 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> Instead of multiplying the number of checks for IS_ERR(priv->clk),
> simply NULLify the 'struct clk' pointer which is something the Linux
> common clock framework perfectly deals with and does early return for
> each and every single clk_* API functions.
>
> Having every single function check for !IS_ERR(priv->clk) is both
> redundant and error prone, as it turns out, we were doing it for the
> main GENET clock: priv->clk, but not for the Wake-on-LAN or EEE clock,
> so let's just be consistent here.
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Acked-by: Petri Gynther <pgynther@google.com>

> ---
> Changes in v2:
>
> - remove all IS_ERR() checks as described, there were two missing in v1
>
>  drivers/net/ethernet/broadcom/genet/bcmgenet.c | 26 ++++++++++++--------------
>  1 file changed, 12 insertions(+), 14 deletions(-)
>
> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> index 5bf7ce0ae221..c6f2d396edf0 100644
> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> @@ -2625,8 +2625,7 @@ static int bcmgenet_open(struct net_device *dev)
>         netif_dbg(priv, ifup, dev, "bcmgenet_open\n");
>
>         /* Turn on the clock */
> -       if (!IS_ERR(priv->clk))
> -               clk_prepare_enable(priv->clk);
> +       clk_prepare_enable(priv->clk);
>
>         /* If this is an internal GPHY, power it back on now, before UniMAC is
>          * brought out of reset as absolutely no UniMAC activity is allowed
> @@ -2703,8 +2702,7 @@ err_irq0:
>  err_fini_dma:
>         bcmgenet_fini_dma(priv);
>  err_clk_disable:
> -       if (!IS_ERR(priv->clk))
> -               clk_disable_unprepare(priv->clk);
> +       clk_disable_unprepare(priv->clk);
>         return ret;
>  }
>
> @@ -2761,8 +2759,7 @@ static int bcmgenet_close(struct net_device *dev)
>         if (priv->internal_phy)
>                 ret = bcmgenet_power_down(priv, GENET_POWER_PASSIVE);
>
> -       if (!IS_ERR(priv->clk))
> -               clk_disable_unprepare(priv->clk);
> +       clk_disable_unprepare(priv->clk);
>
>         return ret;
>  }
> @@ -3215,11 +3212,12 @@ static int bcmgenet_probe(struct platform_device *pdev)
>                 priv->version = pd->genet_version;
>
>         priv->clk = devm_clk_get(&priv->pdev->dev, "enet");
> -       if (IS_ERR(priv->clk))
> +       if (IS_ERR(priv->clk)) {
>                 dev_warn(&priv->pdev->dev, "failed to get enet clock\n");
> +               priv->clk = NULL;
> +       }
>
> -       if (!IS_ERR(priv->clk))
> -               clk_prepare_enable(priv->clk);
> +       clk_prepare_enable(priv->clk);
>
>         bcmgenet_set_hw_params(priv);
>
> @@ -3230,8 +3228,10 @@ static int bcmgenet_probe(struct platform_device *pdev)
>         INIT_WORK(&priv->bcmgenet_irq_work, bcmgenet_irq_task);
>
>         priv->clk_wol = devm_clk_get(&priv->pdev->dev, "enet-wol");
> -       if (IS_ERR(priv->clk_wol))
> +       if (IS_ERR(priv->clk_wol)) {
>                 dev_warn(&priv->pdev->dev, "failed to get enet-wol clock\n");
> +               priv->clk_wol = NULL;
> +       }
>
>         priv->clk_eee = devm_clk_get(&priv->pdev->dev, "enet-eee");
>         if (IS_ERR(priv->clk_eee)) {
> @@ -3257,8 +3257,7 @@ static int bcmgenet_probe(struct platform_device *pdev)
>         netif_carrier_off(dev);
>
>         /* Turn off the main clock, WOL clock is handled separately */
> -       if (!IS_ERR(priv->clk))
> -               clk_disable_unprepare(priv->clk);
> +       clk_disable_unprepare(priv->clk);
>
>         err = register_netdev(dev);
>         if (err)
> @@ -3267,8 +3266,7 @@ static int bcmgenet_probe(struct platform_device *pdev)
>         return err;
>
>  err_clk_disable:
> -       if (!IS_ERR(priv->clk))
> -               clk_disable_unprepare(priv->clk);
> +       clk_disable_unprepare(priv->clk);
>  err:
>         free_netdev(dev);
>         return err;
> --
> 2.1.0
>
