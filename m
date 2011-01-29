From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v3 3/5] net: use ndo_fix_features for
 ethtool_ops->set_flags
Date: Sun, 30 Jan 2011 08:44:03 +1000
Message-ID: <1296341043.3477.64.camel@localhost>
References: <cover.1296325509.git.mirq-linux@rere.qmqm.pl>
	 <3ebf175d86bad22033e680e0cde198598ffcedc6.1296325509.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:17329 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755086Ab1A2WoG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jan 2011 17:44:06 -0500
In-Reply-To: <3ebf175d86bad22033e680e0cde198598ffcedc6.1296325509.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2011-01-29 at 19:39 +0100, Micha=C5=82 Miros=C5=82aw wrote:
> Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
> ---
>  net/core/ethtool.c |   22 ++++++++++++++++++++--
>  1 files changed, 20 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index 409aebb..17a689f4 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -240,6 +240,25 @@ static int ethtool_set_features(struct net_devic=
e *dev, void __user *useraddr)
>  	return ret;
>  }
> =20
> +static int __ethtool_set_flags(struct net_device *dev, u32 data)
> +{
> +	if (data & ~flags_dup_features)
> +		return -EINVAL;
> +
> +	if (!(dev->hw_features & flags_dup_features)) {
> +		if (!dev->ethtool_ops->set_flags)
> +			return -EOPNOTSUPP;
> +		return dev->ethtool_ops->set_flags(dev, data);
> +	}
> +
> +	dev->wanted_features =3D
> +		(dev->wanted_features & ~flags_dup_features) | data;
> +
> +	netdev_update_features(dev);
> +
> +	return 0;
[...]

I think it would be clearer to write this as:

	if (dev->hw_features & flags_dup_features) {
		dev->wanted_features =3D
			(dev->wanted_features & ~flags_dup_features) | data;
		netdev_update_features(dev);
		return 0;
	}

	if (dev->ethtool_ops->set_flags)
		return dev->ethtool_ops->set_flags(dev, data);

	return -EOPNOTSUPP;

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

