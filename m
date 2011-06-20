From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFT PATCH 7/9] ethtool: prepare for larger netdev_features_t
 type
Date: Mon, 20 Jun 2011 22:16:58 +0100
Message-ID: <1308604618.2701.189.camel@bwh-desktop>
References: <cover.1308596962.git.mirq-linux@rere.qmqm.pl>
	 <852a74b9068b3be7413a65023f6096f142dfd805.1308596963.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:33116 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753838Ab1FTVRB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 17:17:01 -0400
In-Reply-To: <852a74b9068b3be7413a65023f6096f142dfd805.1308596963.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-06-20 at 21:14 +0200, Micha=C5=82 Miros=C5=82aw wrote:
[...]
> @@ -125,19 +131,26 @@ static int ethtool_set_features(struct net_devi=
ce *dev, void __user *useraddr)
>  	if (copy_from_user(features, useraddr, sizeof(features)))
>  		return -EFAULT;
> =20
> -	if (features[0].valid & ~NETIF_F_ETHTOOL_BITS)
> +	/* I wonder if the compiler will be smart enough to loop-unroll
> +	 * and optimize this... (no worries if not) --mq */
> +	for (i =3D ETHTOOL_DEV_FEATURE_WORDS; i-- > 0; ) {
> +		valid =3D (valid << 32)|features[i].valid;
> +		wanted =3D (wanted << 32)|features[i].requested;
> +	}
[...]

I don't know (or care) about optimisation of this, but I would expect
gcc to complain about shifting a 32-bit value by 32 bits.  I suggest yo=
u
write this as:

	for (i =3D 0; i < ETHTOOL_DEV_FEATURE_WORDS; ++i) {
		valid |=3D (netdev_features_t)features[i].valid << 32 *i;
		wanted |=3D (netdev_features_t)features[i].requested << 32 *i;
	}

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

