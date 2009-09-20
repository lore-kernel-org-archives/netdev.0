From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netdev: stats on multiqueue possible bug
Date: Sun, 20 Sep 2009 09:24:08 +0200
Message-ID: <4AB5D898.4080804@gmail.com>
References: <20090919222608.5fdf80b8@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:48025 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751603AbZITHYI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Sep 2009 03:24:08 -0400
In-Reply-To: <20090919222608.5fdf80b8@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> Dave, I think you were trying to optimize something here that
> doesn't need optimization.
>=20
> If transmit stats (all) wrap to zero, then the stats would not
> be set correctly. Move local variable into loop as well.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20
> --- a/net/core/dev.c	2009-09-19 15:19:13.902495560 -0700
> +++ b/net/core/dev.c	2009-09-19 15:48:21.126458728 -0700
> @@ -5079,19 +5079,19 @@ const struct net_device_stats *dev_get_s
>  		unsigned long tx_bytes =3D 0, tx_packets =3D 0, tx_dropped =3D 0;
>  		struct net_device_stats *stats =3D &dev->stats;
>  		unsigned int i;
> -		struct netdev_queue *txq;
> =20
>  		for (i =3D 0; i < dev->num_tx_queues; i++) {
> -			txq =3D netdev_get_tx_queue(dev, i);
> +			const struct netdev_queue *txq
> +				 =3D netdev_get_tx_queue(dev, i);
>  			tx_bytes   +=3D txq->tx_bytes;
>  			tx_packets +=3D txq->tx_packets;
>  			tx_dropped +=3D txq->tx_dropped;
>  		}
> -		if (tx_bytes || tx_packets || tx_dropped) {
> -			stats->tx_bytes   =3D tx_bytes;
> -			stats->tx_packets =3D tx_packets;
> -			stats->tx_dropped =3D tx_dropped;
> -		}
> +
> +		stats->tx_bytes   =3D tx_bytes;
> +		stats->tx_packets =3D tx_packets;
> +		stats->tx_dropped =3D tx_dropped;
> +
>  		return stats;
>  	}
>  }

Most devices dont update txq->tx_bytes/tx_packets/tx_dropped yet, but
still update their device->stats

Your patch makes these devices clearing their stats.

In the case all stats wrap to zero, we'll give old values. If you think=
 this is=20
a bug, you should find another way to fix it :)
