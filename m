From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] slip: Use net_device_stats from struct net_device
Date: Thu, 19 Aug 2010 10:49:51 +0200
Message-ID: <1282207791.2549.16.camel@edumazet-laptop>
References: <1282206313-10667-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:42408 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750854Ab0HSIt4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 04:49:56 -0400
In-Reply-To: <1282206313-10667-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 19 ao=C3=BBt 2010 =C3=A0 10:25 +0200, Tobias Klauser a =C3=A9c=
rit :
> Use net_device->stats for stats instead of private variable copies in
> struct slip.
>=20
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
> ---
>  drivers/net/slip.c |   64 ++++++++++++++++++++++--------------------=
----------
>  drivers/net/slip.h |    9 -------
>  2 files changed, 27 insertions(+), 46 deletions(-)


> @@ -561,36 +562,25 @@ static int sl_change_mtu(struct net_device *dev=
, int new_mtu)
>  static struct net_device_stats *
>  sl_get_stats(struct net_device *dev)
>  {
> -	static struct net_device_stats stats;
> +	struct net_device_stats *stats =3D &dev->stats;
>  	struct slip *sl =3D netdev_priv(dev);
>  #ifdef SL_INCLUDE_CSLIP
>  	struct slcompress *comp;
>  #endif
> =20
> -	memset(&stats, 0, sizeof(struct net_device_stats));
> -
> -	stats.rx_packets     =3D sl->rx_packets;
> -	stats.tx_packets     =3D sl->tx_packets;
> -	stats.rx_bytes	     =3D sl->rx_bytes;
> -	stats.tx_bytes	     =3D sl->tx_bytes;
> -	stats.rx_dropped     =3D sl->rx_dropped;
> -	stats.tx_dropped     =3D sl->tx_dropped;
> -	stats.tx_errors      =3D sl->tx_errors;
> -	stats.rx_errors      =3D sl->rx_errors;
> -	stats.rx_over_errors =3D sl->rx_over_errors;
>  #ifdef SL_INCLUDE_CSLIP
> -	stats.rx_fifo_errors =3D sl->rx_compressed;
> -	stats.tx_fifo_errors =3D sl->tx_compressed;
> -	stats.collisions     =3D sl->tx_misses;
> +	stats->rx_fifo_errors =3D sl->rx_compressed;
> +	stats->tx_fifo_errors =3D sl->tx_compressed;
> +	stats->collisions     =3D sl->tx_misses;
>  	comp =3D sl->slcomp;
>  	if (comp) {
> -		stats.rx_fifo_errors +=3D comp->sls_i_compressed;
> -		stats.rx_dropped     +=3D comp->sls_i_tossed;
> -		stats.tx_fifo_errors +=3D comp->sls_o_compressed;
> -		stats.collisions     +=3D comp->sls_o_misses;
> +		stats->rx_fifo_errors +=3D comp->sls_i_compressed;
> +		stats->rx_dropped     +=3D comp->sls_i_tossed;
> +		stats->tx_fifo_errors +=3D comp->sls_o_compressed;
> +		stats->collisions     +=3D comp->sls_o_misses;
>  	}
> -#endif /* CONFIG_INET */
> -	return (&stats);
> +#endif
> +	return stats;
>  }
> =20

Hmm, this is wrong.

Each time sl_get_stats() is called, you are adding stuff to dev->stats

Quite frankly I dont think its a kernel-janitors@vger.kernel.org patch,
its pretty normal netdev stuff.

Please take a look at prior patch posted yesterday.

http://marc.info/?l=3Dlinux-netdev&m=3D128213719605250&w=3D2

Because either you should build your patch on top of it, or ask David t=
o
revert mine before ;)

I advise using a ndo_get_stats64() so that you can perform the adds on =
a
private destination buffer.

Thanks


