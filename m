From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH 1/3] net: ucc_geth: drop acquired references in probe
 error path and remove
Date: Fri, 8 Aug 2014 22:34:56 +0200
Message-ID: <20140808203456.GB5134@pengutronix.de>
References: <1407448106-1819-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	kernel@pengutronix.de, Florian Fainelli <f.fainelli@gmail.com>
To: Li Yang <leoli@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:34519 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750853AbaHHUfF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2014 16:35:05 -0400
Content-Disposition: inline
In-Reply-To: <1407448106-1819-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 07, 2014 at 11:48:24PM +0200, Uwe Kleine-K=F6nig wrote:
> The ucc_geth_probe function assigns to ug_info->tbi_node and
> ug_info->phy_node a value returned by of_parse_phandle which returns =
a
> new reference. Put this reference again in the error path of
> ucc_geth_probe and when removing the device.
>=20
> Signed-off-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
> ---
> No Fixes: footer here. The problem already exists in v2.6.31-rc1 (e.g=
=2E
> commit 0b9da337dca9 (net: Rework ucc_geth driver to use of_mdio
> infrastructure)). Didn't continue to research a specific commit.
> ---
>  drivers/net/ethernet/freescale/ucc_geth.c | 9 ++++++++-
>  1 file changed, 8 insertions(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/ethernet/freescale/ucc_geth.c b/drivers/net/=
ethernet/freescale/ucc_geth.c
> index 36fc429298e3..5f1aab9c4ee7 100644
> --- a/drivers/net/ethernet/freescale/ucc_geth.c
> +++ b/drivers/net/ethernet/freescale/ucc_geth.c
> @@ -3864,8 +3864,11 @@ static int ucc_geth_probe(struct platform_devi=
ce* ofdev)
>  	/* Create an ethernet device instance */
>  	dev =3D alloc_etherdev(sizeof(*ugeth));
> =20
> -	if (dev =3D=3D NULL)
> +	if (dev =3D=3D NULL) {
> +		of_node_put(ug_info->tbi_node);
> +		of_node_put(ug_info->phy_node);
>  		return -ENOMEM;
> +	}
> =20
>  	ugeth =3D netdev_priv(dev);
>  	spin_lock_init(&ugeth->lock);
> @@ -3899,6 +3902,8 @@ static int ucc_geth_probe(struct platform_devic=
e* ofdev)
>  			pr_err("%s: Cannot register net device, aborting\n",
>  			       dev->name);
>  		free_netdev(dev);
> +		of_node_put(ug_info->tbi_node);
> +		of_node_put(ug_info->phy_node);
>  		return err;
>  	}
> =20
> @@ -3922,6 +3927,8 @@ static int ucc_geth_remove(struct platform_devi=
ce* ofdev)
>  	unregister_netdev(dev);
>  	free_netdev(dev);
>  	ucc_geth_memclean(ugeth);
> +	of_node_put(ugeth->info->tbi_node);
> +	of_node_put(ugeth->info->phy_node);
this must read:

	of_node_put(ugeth->ug_info->tbi_node);
	of_node_put(ugeth->ug_info->phy_node);

otherwise it fails to build.

@davem: Should I send a fixup or a new version?

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
