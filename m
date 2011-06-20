From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFT PATCH 4/9] net: introduce and use netdev_features_t for
 device features sets
Date: Mon, 20 Jun 2011 22:01:36 +0100
Message-ID: <1308603696.2701.185.camel@bwh-desktop>
References: <cover.1308596962.git.mirq-linux@rere.qmqm.pl>
	 <24e8026de1130f193dc82315f83ad64fcce771d8.1308596963.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:31588 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754439Ab1FTVBj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 17:01:39 -0400
In-Reply-To: <24e8026de1130f193dc82315f83ad64fcce771d8.1308596963.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-06-20 at 21:14 +0200, Micha=C5=82 Miros=C5=82aw wrote:
> The type and bits definitions are moved to separate header so that
> linux/skbuff.h won't need to include linux/netdevice.h.
[...]
> diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
> index c914729..ca869c0 100644
> --- a/drivers/net/sfc/efx.c
> +++ b/drivers/net/sfc/efx.c
> @@ -1883,7 +1883,7 @@ static void efx_set_multicast_list(struct net_d=
evice *net_dev)
>  	/* Otherwise efx_start_port() will do this */
>  }
> =20
> -static int efx_set_features(struct net_device *net_dev, u32 data)
> +static int efx_set_features(struct net_device *net_dev, netdev_featu=
res_t data)
>  {
>  	struct efx_nic *efx =3D netdev_priv(net_dev);
> =20

The type of efx_nic_type::offload_features, defined in
drivers/net/sfc/net_driver.h, will also need to be changed.

[...]
> --- /dev/null
> +++ b/include/linux/netdev_features.h
[...]
> +	/* Segmentation offload features */
[...]
> +	/* Features valid for ethtool to change */
> +	/* =3D all defined minus driver/device-class-related */
[...]
> +	/* List of features with software fallbacks. */
[...]
> +	/*
> +	 * If one device supports one of these features, then enable them
> +	 * for all in netdev_increment_features.
> +	 */
[...]
> +	/*
> +	 * If one device doesn't support one of these features, then disabl=
e it
> +	 * for all in netdev_increment_features.
> +	 */
[...]
> +	/* changeable features with no special hardware requirements */
[...]

A cosmetic detail: these comments should no longer be indented.

[...]
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 3041b6ae..a5a0e76 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
[...]
> @@ -1872,8 +1872,8 @@ struct sk_buff *skb_gso_segment(struct sk_buff =
*skb, u32 features)
>  		if (dev && dev->ethtool_ops && dev->ethtool_ops->get_drvinfo)
>  			dev->ethtool_ops->get_drvinfo(dev, &info);
> =20
> -		WARN(1, "%s: caps=3D(0x%lx, 0x%lx) len=3D%d data_len=3D%d ip_summe=
d=3D%d\n",
> -		     info.driver, dev ? dev->features : 0L,
> +		WARN(1, "%s: caps=3D(0x%llx, 0x%lx) len=3D%d data_len=3D%d ip_summ=
ed=3D%d\n",
> +		     info.driver, dev ? (long long)dev->features : 0LL,
> 		     skb->sk ? skb->sk->sk_route_caps : 0L,
> 		     skb->len, skb->data_len, skb->ip_summed);

The types of sock::sk_route_caps and sock::sk_route_nocaps also need to
be fixed (they are still int and not even unsigned!).

[...]
> @@ -5250,11 +5252,10 @@ u32 netdev_fix_features(struct net_device *de=
v, u32 features)
> =20
>  	return features;
>  }
> -EXPORT_SYMBOL(netdev_fix_features);

I don't think that change belongs in this patch!

[...]
> @@ -5270,8 +5271,10 @@ int __netdev_update_features(struct net_device=
 *dev)
>  	if (dev->features =3D=3D features)
>  		return 0;
> =20
> +	BUILD_BUG_ON(sizeof(features) !=3D sizeof(u32));	/* XXX: need: %Fx =
*/
> +
>  	netdev_dbg(dev, "Features changed: 0x%08x -> 0x%08x\n",
> -		dev->features, features);
> +		(u32)dev->features, (u32)features);
[...]

You could either define macros for this:

#define NETDEV_FEATURES_FMT			"0x%08x"
#define NETDEV_FEATURES_FMT_ARG(features)	features

or follow the current trend of extending %p and passing a pointer to th=
e
value.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

