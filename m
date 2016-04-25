From: Joachim Eastwood <manabian@gmail.com>
Subject: Re: [PATCH V3] net: stmmac: socfpga: Remove re-registration of reset controller
Date: Mon, 25 Apr 2016 20:11:27 +0200
Message-ID: <CAGhQ9VzpZcP23DC0LZ95YggtsBDsUCe-NHEtna7hY9Yvdr=ZGg@mail.gmail.com>
References: <1461240710-5381-1-git-send-email-marex@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"peppe.cavallaro" <peppe.cavallaro@st.com>,
	alexandre.torgue@st.com,
	Matthew Gerlach <mgerlach@opensource.altera.com>,
	Dinh Nguyen <dinguyen@opensource.altera.com>,
	"David S . Miller" <davem@davemloft.net>
To: Marek Vasut <marex@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:33342 "EHLO
	mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932905AbcDYSL2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 14:11:28 -0400
Received: by mail-io0-f179.google.com with SMTP id f89so157315834ioi.0
        for <netdev@vger.kernel.org>; Mon, 25 Apr 2016 11:11:28 -0700 (PDT)
In-Reply-To: <1461240710-5381-1-git-send-email-marex@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Marek,

On 21 April 2016 at 14:11, Marek Vasut <marex@denx.de> wrote:
> Both socfpga_dwmac_parse_data() in dwmac-socfpga.c and stmmac_dvr_probe()
> in stmmac_main.c functions call devm_reset_control_get() to register an
> reset controller for the stmmac. This results in an attempt to register
> two reset controllers for the same non-shared reset line.
>
> The first attempt to register the reset controller works fine. The second
> attempt fails with warning from the reset controller core, see below.
> The warning is produced because the reset line is non-shared and thus
> it is allowed to have only up-to one reset controller associated with
> that reset line, not two or more.
>
> The solution has multiple parts. First, the original socfpga_dwmac_init()
> is tweaked to use reset controller pointer from the stmmac_priv (private
> data of the stmmac core) instead of the local instance, which was used
> before. The local re-registration of the reset controller is removed.
>
> Next, the socfpga_dwmac_init() is moved after stmmac_dvr_probe() in the
> probe function. This order is legal according to Altera and it makes the
> code much easier, since there is no need to temporarily register and
> unregister the reset controller ; the reset controller is already registered
> by the stmmac_dvr_probe().
>
> Finally, plat_dat->exit and socfpga_dwmac_exit() is no longer necessary,
> since the functionality is already performed by the stmmac core.

I am trying to rebase my changes on top of your two patches and
noticed a couple of things.

>  static int socfpga_dwmac_init(struct platform_device *pdev, void *priv)
>  {
> -       struct socfpga_dwmac    *dwmac = priv;
> +       struct socfpga_dwmac *dwmac = priv;
>         struct net_device *ndev = platform_get_drvdata(pdev);
>         struct stmmac_priv *stpriv = NULL;
>         int ret = 0;
>
> -       if (ndev)
> -               stpriv = netdev_priv(ndev);
> +       if (!ndev)
> +               return -EINVAL;

ndev can never be NULL here. socfpga_dwmac_init() is only called if
stmmac_dvr_probe() succeeds or we are running the resume callback. So
I don't see how this could ever be NULL.


> +
> +       stpriv = netdev_priv(ndev);

It's not really nice to access 'stmmac_priv' as it should be private
to the core driver, but I don't see any other good solution right now.


> +       if (!stpriv)
> +               return -EINVAL;
>
>         /* Assert reset to the enet controller before changing the phy mode */
> -       if (dwmac->stmmac_rst)
> -               reset_control_assert(dwmac->stmmac_rst);
> +       if (stpriv->stmmac_rst)
> +               reset_control_assert(stpriv->stmmac_rst);
>
>         /* Setup the phy mode in the system manager registers according to
>          * devicetree configuration
> @@ -227,8 +210,8 @@ static int socfpga_dwmac_init(struct platform_device *pdev, void *priv)
>         /* Deassert reset for the phy configuration to be sampled by
>          * the enet controller, and operation to start in requested mode
>          */
> -       if (dwmac->stmmac_rst)
> -               reset_control_deassert(dwmac->stmmac_rst);
> +       if (stpriv->stmmac_rst)
> +               reset_control_deassert(stpriv->stmmac_rst);
>
>         /* Before the enet controller is suspended, the phy is suspended.
>          * This causes the phy clock to be gated. The enet controller is
> @@ -245,7 +228,7 @@ static int socfpga_dwmac_init(struct platform_device *pdev, void *priv)
>          * control register 0, and can be modified by the phy driver
>          * framework.
>          */
> -       if (stpriv && stpriv->phydev)
> +       if (stpriv->phydev)
>                 phy_resume(stpriv->phydev);

Before this change phy_resume() was only called during driver resume
when , but your patches cause phy_resume() to called at probe time as
well. Is this okey?


regards,
Joachim Eastwood
