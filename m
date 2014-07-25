From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] can: c_can_platform: Fix raminit, use devm_ioremap()
 instead of devm_ioremap_resource()
Date: Fri, 25 Jul 2014 13:21:01 -0700
Message-ID: <CAGVrzcZT0e2vLF5N-fwgkxYGtLxtcp0_SvV1iYGBfd2+PB=-Ng@mail.gmail.com>
References: <1406273810-19116-1-git-send-email-mkl@pengutronix.de> <1406273810-19116-2-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, linux-can@vger.kernel.org,
	kernel <kernel@pengutronix.de>,
	George Cherian <george.cherian@ti.com>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	linux-stable <stable@vger.kernel.org>,
	"jg1.han@samsung.com" <jg1.han@samsung.com>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1406273810-19116-2-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2014-07-25 0:36 GMT-07:00 Marc Kleine-Budde <mkl@pengutronix.de>:
> From: George Cherian <george.cherian@ti.com>
>
> The raminit register is shared register for both can0 and can1. Since commit:
>
>     32766ff net: can: Convert to use devm_ioremap_resource
>
> devm_ioremap_resource() is used to map raminit register. When using both
> interfaces the mapping for the can1 interface fails, leading to a non
> functional can interface.

Unfortunately, this is not the first time that devres conversions
break drivers because they were semi-automatic conversions without
taking a look at what the driver expects, see:

6892b41d9701283085b655c6086fb57a5d63fa47 ("net: davinci: emac: Convert
to devm_* api") and
33b7107f59a61236d94ecd6b45e20283cd5abcc8 ("net: davinci_emac: Replace
devm_request_irq with request_irq")

arguably, a comment here explaining why the request_mem_region() on
this resource should not be done might help people using automated
tools not to break things in the future...

>
> Signed-off-by: George Cherian <george.cherian@ti.com>
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
> Cc: linux-stable <stable@vger.kernel.org> # >= v3.11
> Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
> ---
>  drivers/net/can/c_can/c_can_platform.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/can/c_can/c_can_platform.c b/drivers/net/can/c_can/c_can_platform.c
> index 824108c..12430be 100644
> --- a/drivers/net/can/c_can/c_can_platform.c
> +++ b/drivers/net/can/c_can/c_can_platform.c
> @@ -287,7 +287,8 @@ static int c_can_plat_probe(struct platform_device *pdev)
>                         break;
>                 }
>
> -               priv->raminit_ctrlreg = devm_ioremap_resource(&pdev->dev, res);
> +               priv->raminit_ctrlreg = devm_ioremap(&pdev->dev, res->start,
> +                                                    resource_size(res));
>                 if (IS_ERR(priv->raminit_ctrlreg) || priv->instance < 0)
>                         dev_info(&pdev->dev, "control memory is not used for raminit\n");
>                 else
> --
> 2.0.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Florian
