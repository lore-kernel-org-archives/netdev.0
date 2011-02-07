From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v4 3/5] net: use ndo_fix_features for
 ethtool_ops->set_flags
Date: Mon, 07 Feb 2011 19:46:12 +0000
Message-ID: <1297107972.4077.11.camel@bwh-desktop>
References: <cover.1296741561.git.mirq-linux@rere.qmqm.pl>
	 <bbe7e5742ffe44fb2938b7b6c2c656395fc361ac.1296741562.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:20919 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752451Ab1BGTqO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Feb 2011 14:46:14 -0500
In-Reply-To: <bbe7e5742ffe44fb2938b7b6c2c656395fc361ac.1296741562.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-02-03 at 15:21 +0100, Micha=C5=82 Miros=C5=82aw wrote:
> Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
> ---
>  net/core/ethtool.c |   31 +++++++++++++++++++++++++++++--
>  1 files changed, 29 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index 555accf..6e7c6f2 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -240,6 +240,34 @@ static int ethtool_set_features(struct net_devic=
e *dev, void __user *useraddr)
>  	return ret;
>  }
> =20
> +static int __ethtool_set_flags(struct net_device *dev, u32 data)
> +{
> +	u32 changed;
> +
> +	if (data & ~flags_dup_features)
> +		return -EINVAL;
> +
> +	/* legacy set_flags() op */
> +	if (dev->ethtool_ops->set_flags) {
> +		if (unlikely(dev->hw_features & flags_dup_features))
> +			netdev_warn(dev,
> +				"driver BUG: mixed hw_features and set_flags()\n");
> +		return dev->ethtool_ops->set_flags(dev, data);
> +	}
> +
> +	/* allow changing only bits set in hw_features */
> +	changed =3D (data ^ dev->wanted_features) & flags_dup_features;
> +	if (changed & ~dev->hw_features)
> +		return -EOPNOTSUPP;
[...]

The error code should only be EOPNOTSUPP if (dev->hw_features &
flags_dup_features) =3D=3D 0.  Otherwise it should be EINVAL.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

