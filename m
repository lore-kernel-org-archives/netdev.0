From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH net-next-2.6] sfc: Implement NETIF_F_LOOPBACK
Date: Mon, 9 May 2011 09:36:35 +0200
Message-ID: <20110509073635.GA16708@rere.qmqm.pl>
References: <1304559011-15983-1-git-send-email-maheshb@google.com>
 <1304640751.2857.34.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com,
	Mahesh Bandewar <maheshb@google.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:37301 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753037Ab1EIHgh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2011 03:36:37 -0400
Content-Disposition: inline
In-Reply-To: <1304640751.2857.34.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 06, 2011 at 01:12:31AM +0100, Ben Hutchings wrote:
> We already have comprehensive support for loopback testing, so pick
> the nearest mode and run with it.
>=20
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
> David, this depends on Mahesh's patch to define NETIF_F_LOOPBACK
> <http://patchwork.ozlabs.org/patch/94190/>.  Although you've marked t=
hat
> as RFC, I think it is ready to apply.
>=20
> Ben.
>=20
>  drivers/net/sfc/efx.c |   24 ++++++++++++++++++++++--
>  1 files changed, 22 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
> index 38a55e9..b7bfb49 100644
> --- a/drivers/net/sfc/efx.c
> +++ b/drivers/net/sfc/efx.c
> @@ -1884,6 +1884,25 @@ static int efx_set_features(struct net_device =
*net_dev, u32 data)
>  	if (net_dev->features & ~data & NETIF_F_NTUPLE)
>  		efx_filter_clear_rx(efx, EFX_FILTER_PRI_MANUAL);
> =20
> +	/* Toggle loopback if required */
> +	if ((net_dev->features ^ data) & NETIF_F_LOOPBACK) {
> +		enum efx_loopback_mode old_mode;
> +		int rc;
> +
> +		mutex_lock(&efx->mac_lock);
> +		old_mode =3D efx->loopback_mode;
> +		if (data & NETIF_F_LOOPBACK)
> +			efx->loopback_mode =3D __ffs(efx->loopback_modes);
> +		else
> +			efx->loopback_mode =3D LOOPBACK_NONE;
> +		rc =3D __efx_reconfigure_port(efx);
> +		if (rc)
> +			efx->loopback_mode =3D old_mode;
> +		mutex_unlock(&efx->mac_lock);
> +		if (rc)
> +			return rc;
> +	}
> +
>  	return 0;
>  }

If other features than NETIF_F_LOOPBACK were changed correctly, this sh=
ould
update dev->features of what changed before error return. If not, devic=
e's
state will diverge to what is in dev->features.

> @@ -2472,8 +2491,9 @@ static int __devinit efx_pci_probe(struct pci_d=
ev *pci_dev,
>  	net_dev->vlan_features |=3D (NETIF_F_ALL_CSUM | NETIF_F_SG |
>  				   NETIF_F_HIGHDMA | NETIF_F_ALL_TSO |
>  				   NETIF_F_RXCSUM);
> -	/* All offloads can be toggled */
> -	net_dev->hw_features =3D net_dev->features & ~NETIF_F_HIGHDMA;
> +	/* All offloads can be toggled, and so can loopback */
> +	net_dev->hw_features =3D ((net_dev->features & ~NETIF_F_HIGHDMA) |
> +				NETIF_F_LOOPBACK);
>  	efx =3D netdev_priv(net_dev);
>  	pci_set_drvdata(pci_dev, efx);
>  	SET_NETDEV_DEV(net_dev, &pci_dev->dev);

You can remove the '& ~NETIF_F_HIGHDMA' part, as it's now allowed to be
changed (commit fa2bd7ff9247f4218dfc907db14d000cd7edd862).

Best Regards,
Micha=B3 Miros=B3aw
