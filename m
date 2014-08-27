From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v2] ethernet: arc: Add support for Rockchip SoC layer device tree bindings
Date: Wed, 27 Aug 2014 22:11:29 +0200
Message-ID: <3619843.a6HHkMsuOu@wuerfel>
References: <1409122527-17673-1-git-send-email-romain.perier@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: heiko@sntech.de, linux-rockchip@lists.infradead.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Romain Perier <romain.perier@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.24]:57842 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932146AbaH0UL7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 16:11:59 -0400
In-Reply-To: <1409122527-17673-1-git-send-email-romain.perier@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 27 August 2014 06:55:27 Romain Perier wrote:
> This patch defines a platform glue layer for Rockchip SoCs which
> support arc-emac driver. It ensures that regulator for the rmii is on
> before trying to connect to the ethernet controller. It applies right
> speed and mode changes to the grf when ethernet settings change.
> 
> Signed-off-by: Romain Perier <romain.perier@gmail.com>
> ---
>  drivers/net/ethernet/arc/Kconfig         |  15 +++
>  drivers/net/ethernet/arc/Makefile        |   1 +
>  drivers/net/ethernet/arc/emac.h          |   2 +
>  drivers/net/ethernet/arc/emac_main.c     |   2 +
>  drivers/net/ethernet/arc/emac_rockchip.c | 224 +++++++++++++++++++++++++++++++
>  5 files changed, 244 insertions(+)
>  create mode 100644 drivers/net/ethernet/arc/emac_rockchip.c
> 
> diff --git a/drivers/net/ethernet/arc/Kconfig b/drivers/net/ethernet/arc/Kconfig
> index 89e04fd..6d96a82 100644
> --- a/drivers/net/ethernet/arc/Kconfig
> +++ b/drivers/net/ethernet/arc/Kconfig
> @@ -32,4 +32,19 @@ config ARC_EMAC
>  	  non-standard on-chip ethernet device ARC EMAC 10/100 is used.
>  	  Say Y here if you have such a board.  If unsure, say N.
>  
> +config EMAC_ROCKCHIP
> +       tristate "Rockchip EMAC support"
> +       select ARC_EMAC_CORE
> +       depends on OF_IRQ
> +       depends on OF_NET
> +       depends on ARCH_ROCKCHIP
> +       depends on REGULATOR_ACT8865
> +       depends on SMSC_PHY
> +       depends on MFD_SYSCON

You should generally not add 'depends on' for specific drivers out
of a subsystems. Just list the build-time dependencies, like

	depends on OF_IRQ && OF_NET && PHYLIB && REGULATOR && MFD_SYSCON

You can add the ARCH_ROCKCHIPS part if you think that's valuable, but
add an '|| COMPILE_TEST' so it's possible to still build it elsewhere.

> +#define GRF_MODE_MII   BIT(0)
> +#define GRF_MODE_RMII  0x0
> +#define GRF_SPEED_10M  0x0
> +#define GRF_SPEED_100M BIT(1)

Just use 0x... for consistency for all of these.

> +static const struct of_device_id emac_rockchip_dt_ids[];

Can you rearrange it to avoid the forward declaration?

> +       priv->soc_data = (struct emac_rockchip_soc_data *)match->data;

This cast turns a 'const' pointer into a non-const pointer, which is
bad. Mark the soc_data pointer as const as well so you can remove the
cast here.

> +	/* write-enable bits */
> +	data = BIT(16) | BIT(17);
> +
> +	data |= GRF_SPEED_100M;
> +	data |= GRF_MODE_RMII;

If you have macros for some bits, you should have them for all of them.

> +	rate = 50000000;

Where does this number come from?

> +static const struct of_device_id emac_rockchip_dt_ids[] = {
> +	{ .compatible = "rockchip,rk3066-emac", .data = (void *)&emac_rockchip_dt_data[0]},
> +	{ .compatible = "rockchip,rk3188-emac", .data = (void *)&emac_rockchip_dt_data[1]},
> +	{ /* Sentinel */ }
> +};

This cast is harmless, but I'd remove it as well.

	Arnd
