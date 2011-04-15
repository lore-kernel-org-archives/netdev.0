From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net: forcedeth: convert to hw_features
Date: Fri, 15 Apr 2011 17:39:48 +0100
Message-ID: <1302885588.2845.4.camel@bwh-desktop>
References: <20110415145049.CC33613A65@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:20624 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752947Ab1DOQjv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 12:39:51 -0400
In-Reply-To: <20110415145049.CC33613A65@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-04-15 at 16:50 +0200, Micha=C5=82 Miros=C5=82aw wrote:
> This also fixes a race around np->txrxctl_bits while changing RXCSUM =
offload.
>=20
> Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
> ---
>  drivers/net/forcedeth.c |   78 +++++++++++++++----------------------=
---------
>  1 files changed, 26 insertions(+), 52 deletions(-)
>=20
> diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
> index d5ab4da..ec9a32d 100644
> --- a/drivers/net/forcedeth.c
> +++ b/drivers/net/forcedeth.c
> @@ -774,7 +774,6 @@ struct fe_priv {
>  	u32 driver_data;
>  	u32 device_id;
>  	u32 register_size;
> -	int rx_csum;
>  	u32 mac_in_use;
>  	int mgmt_version;
>  	int mgmt_sema;
> @@ -4480,58 +4479,36 @@ static int nv_set_pauseparam(struct net_devic=
e *dev, struct ethtool_pauseparam*
>  	return 0;
>  }
> =20
> -static u32 nv_get_rx_csum(struct net_device *dev)
> +static u32 nv_fix_features(struct net_device *dev, u32 features)
>  {
> -	struct fe_priv *np =3D netdev_priv(dev);
> -	return np->rx_csum !=3D 0;
> +	/* vlan is dependent on rx checksum offload */
> +	if (features & (NETIF_F_HW_VLAN_TX|NETIF_F_HW_VLAN_RX))
> +		features |=3D NETIF_F_RXCSUM;
[...]

Shouldn't this be done the other way round:

	if (!(features & NETIF_F_RXCSUM))
		features &=3D ~(NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX);

So long as the VLAN feature flags are still set in wanted_features, the=
y
will be turned back on automatically if RXCSUM is re-enabled.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

