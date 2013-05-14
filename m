From: Frank Li <lznuaa@gmail.com>
Subject: Re: [PATCH] net: ethernet: freescale: use devm_ioremap_resource()
Date: Tue, 14 May 2013 14:21:53 +0800
Message-ID: <CAHrpEqQRPiJqkFoLCGa+QmbnAa++50HRQHvw69uxN7y8zgiR3Q@mail.gmail.com>
References: <1368473874-9569-1-git-send-email-laurent.navet@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Shawn Guo <shawn.guo@linaro.org>, joe@perches.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	kernel list <linux-kernel@vger.kernel.org>
To: Laurent Navet <laurent.navet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:41686 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751962Ab3ENGV4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 May 2013 02:21:56 -0400
In-Reply-To: <1368473874-9569-1-git-send-email-laurent.navet@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/5/14 Laurent Navet <laurent.navet@gmail.com>:
> Replace a call to deprecated devm_request_and_ioremap by devm_ioremap_resource.
> also remove tests on 'r' since devm_ioremap_resource() checks for it
> in a better way.
>
> Found with coccicheck and this semantic patch:
>  scripts/coccinelle/api/devm_ioremap_resource.cocci
>
> Signed-off-by: Laurent Navet <laurent.navet@gmail.com>
> ---
>  drivers/net/ethernet/freescale/fec_main.c |   13 +++++--------
>  1 file changed, 5 insertions(+), 8 deletions(-)
>
> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
> index aff0310..0afc7ff 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -1843,8 +1843,6 @@ fec_probe(struct platform_device *pdev)
>                 pdev->id_entry = of_id->data;
>
>         r = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> -       if (!r)
> -               return -ENXIO;
>

why remove this check?

>         /* Init network device */
>         ndev = alloc_etherdev(sizeof(struct fec_enet_private));
> @@ -1861,17 +1859,16 @@ fec_probe(struct platform_device *pdev)
>             (pdev->id_entry->driver_data & FEC_QUIRK_HAS_GBIT))
>                 fep->pause_flag |= FEC_PAUSE_FLAG_AUTONEG;
>
> -       fep->hwp = devm_request_and_ioremap(&pdev->dev, r);
> +       fep->hwp = devm_ioremap_resource(&pdev->dev, r);
> +       if (IS_ERR(fep->hwp)) {
> +               ret = PTR_ERR(fep->hwp);
> +               goto failed_ioremap;
> +       }
>         fep->pdev = pdev;
>         fep->dev_id = dev_id++;
>
>         fep->bufdesc_ex = 0;
>
> -       if (!fep->hwp) {
> -               ret = -ENOMEM;
> -               goto failed_ioremap;
> -       }
> -
>         platform_set_drvdata(pdev, ndev);
>
>         ret = of_get_phy_mode(pdev->dev.of_node);
> --
> 1.7.10.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
