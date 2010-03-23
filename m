From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] rps: make distributing packets fairly among all the
 online CPUs default
Date: Tue, 23 Mar 2010 08:20:52 +0100
Message-ID: <1269328852.3043.13.camel@edumazet-laptop>
References: <4BA85EA2.1090304@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f191.google.com ([209.85.210.191]:37554 "EHLO
	mail-yx0-f191.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752337Ab0CWHU7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Mar 2010 03:20:59 -0400
Received: by yxe29 with SMTP id 29so2583144yxe.4
        for <netdev@vger.kernel.org>; Tue, 23 Mar 2010 00:20:58 -0700 (PDT)
In-Reply-To: <4BA85EA2.1090304@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 23 mars 2010 =C3=A0 14:24 +0800, Changli Gao a =C3=A9crit :
> make distributing packets fairly among all the online CPUs default.
>=20
> Make distributing packets fairly among all the online CPUs default, t=
hen
> users don't need any explicit configuration to get the benefit of RPS=
=2E
>=20
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ----
> net/core/dev.c | 34 ++++++++++++++++++++++++++++++++--
> 1 file changed, 32 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/core/dev.c b/net/core/dev.c
> index c0e2608..a4246f1 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -5234,6 +5234,24 @@ void netif_stacked_transfer_operstate(const st=
ruct net_device *rootdev,
>  }
>  EXPORT_SYMBOL(netif_stacked_transfer_operstate);
> =20
> +static struct rps_map* alloc_rps_map(void)
> +{
> +	struct rps_map *map;
> +	int i, cpu;
> +
> +	map =3D kzalloc(max_t(unsigned,
> +			    RPS_MAP_SIZE(cpumask_weight(cpu_online_mask)),
> +			    L1_CACHE_BYTES), GFP_KERNEL);
> +	if (map =3D=3D NULL)
> +		return NULL;
> +	i =3D 0;
> +	for_each_online_cpu(cpu)
> +		map->cpus[i++] =3D cpu;
> +	map->len =3D i;
> +
> +	return map;
> +}
> +
>  /**
>   *	register_netdevice	- register a network device
>   *	@dev: device to register
> @@ -5282,7 +5300,13 @@ int register_netdevice(struct net_device *dev)
>  			ret =3D -ENOMEM;
>  			goto out;
>  		}
> -
> +		dev->_rx->rps_map =3D alloc_rps_map();
> +		if (dev->_rx->rps_map =3D=3D NULL) {
> +			kfree(dev->_rx);
> +			dev->_rx =3D NULL;
> +			ret =3D -ENOMEM;
> +			goto out;
> +		}
>  		dev->_rx->first =3D dev->_rx;
>  		atomic_set(&dev->_rx->count, 1);
>  		dev->num_rx_queues =3D 1;
> @@ -5688,8 +5712,12 @@ struct net_device *alloc_netdev_mq(int sizeof_=
priv, const char *name,
>  	 * Set a pointer to first element in the array which holds the
>  	 * reference count.
>  	 */
> -	for (i =3D 0; i < queue_count; i++)
> +	for (i =3D 0; i < queue_count; i++) {
>  		rx[i].first =3D rx;
> +		rx[i].rps_map =3D alloc_rps_map();
> +		if (rx[i].rps_map =3D=3D NULL)
> +			goto free_rx;
> +	}
> =20
>  	dev =3D PTR_ALIGN(p, NETDEV_ALIGN);
>  	dev->padded =3D (char *)dev - (char *)p;
> @@ -5723,6 +5751,8 @@ struct net_device *alloc_netdev_mq(int sizeof_p=
riv, const char *name,
>  	return dev;
> =20
>  free_rx:
> +	for (i =3D 0; i < queue_count; i++)
> +		kfree(rx[i].rps_map);
>  	kfree(rx);
>  free_tx:
>  	kfree(tx);
>=20
>=20
> --

You cannot do this like this, these allocations wont be freed.

Better would be to take a look at net/core/net-sysfs.c



