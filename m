From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] rps: allocate rx queues in
 register_netdevice only
Date: Fri, 24 Sep 2010 09:07:29 +0200
Message-ID: <1285312049.2380.66.camel@edumazet-laptop>
References: <1285273118.7794.23.camel@achroite.uk.solarflarecom.com>
	 <1285273194.7794.24.camel@achroite.uk.solarflarecom.com>
	 <1285296505.2380.43.camel@edumazet-laptop>
	 <1285298795.2380.54.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com, Tom Herbert <therbert@google.com>
To: Ben Hutchings <bhutchings@solarflare.com>,
	Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:62807 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754141Ab0IXHHe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Sep 2010 03:07:34 -0400
Received: by wwb18 with SMTP id 18so727635wwb.1
        for <netdev@vger.kernel.org>; Fri, 24 Sep 2010 00:07:32 -0700 (PDT)
In-Reply-To: <1285298795.2380.54.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 24 septembre 2010 =C3=A0 05:26 +0200, Eric Dumazet a =C3=A9=
crit :
> > Also, I dont understand why we need to restrict
> > netif_set_real_num_rx_queues() to lower the count.
> > This wastes memory.
> >=20
> > Why dont we allocate dev->_rx once we know the real count, not in
> > alloc_netdev_mq() but in register_netdevice() ?
> >=20
> >=20
>=20
> Here is a patch to make this possible
>=20
> I guess a similar thing could be done for tx queues.
>=20
> boot tested, but please double check.
>=20
> Thanks
>=20
> [PATCH net-next-2.6] rps: allocate rx queues in register_netdevice()
>=20
> Instead of having two places were we allocate dev->_rx, introduce
> netif_alloc_rx_queues() helper and call it only from
> register_netdevice(), not from alloc_netdev_mq()
>=20
> Goal is to let drivers change dev->num_rx_queues after allocating net=
dev
> and before registering it.
>=20
> This also removes a lot of ifdefs in net/core/dev.c
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  net/core/dev.c |   76 +++++++++++++++++++---------------------------=
-
>  1 file changed, 32 insertions(+), 44 deletions(-)
>=20
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 2c7934f..9110b8d 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -4964,6 +4964,34 @@ void netif_stacked_transfer_operstate(const st=
ruct net_device *rootdev,
>  }
>  EXPORT_SYMBOL(netif_stacked_transfer_operstate);
> =20
> +static int netif_alloc_rx_queues(struct net_device *dev)
> +{
> +#ifdef CONFIG_RPS
> +	unsigned int i, count =3D dev->num_rx_queues;
> +

Tom

I tried to find a caller with dev->num_rx_queues =3D 0, but failed

If it's valid, we might add a

	if (!dev->num_rx_queues)
		dev->num_rx_queues =3D 1;

I wonder if you remember why you added the section :
	/*
	 * Allocate a single RX queue if driver never called
	 * alloc_netdev_mq
	 */
>=20
>=20
> +	if (count) {
> +		struct netdev_rx_queue *rx;
> +
> +		rx =3D kcalloc(count, sizeof(struct netdev_rx_queue), GFP_KERNEL);
> +		if (!rx) {
> +			pr_err("netdev: Unable to allocate %u rx queues.\n",
> +			       count);
> +			return -ENOMEM;
> +		}
> +		dev->_rx =3D rx;
> +		atomic_set(&rx->count, count);
> +
> +		/*
> +		 * Set a pointer to first element in the array which holds the
> +		 * reference count.
> +		 */
> +		for (i =3D 0; i < count; i++)
> +			rx[i].first =3D rx;
> +	}
> +#endif
> +	return 0;
> +}
> +
>  /**
>   *	register_netdevice	- register a network device
>   *	@dev: device to register
> @@ -5001,24 +5029,10 @@ int register_netdevice(struct net_device *dev=
)
> =20
>  	dev->iflink =3D -1;
> =20
> -#ifdef CONFIG_RPS
> -	if (!dev->num_rx_queues) {
> -		/*
> -		 * Allocate a single RX queue if driver never called
> -		 * alloc_netdev_mq
> -		 */
> -
> -		dev->_rx =3D kzalloc(sizeof(struct netdev_rx_queue), GFP_KERNEL);
> -		if (!dev->_rx) {
> -			ret =3D -ENOMEM;
> -			goto out;
> -		}
> +	ret =3D netif_alloc_rx_queues(dev);
> +	if (ret)
> +		goto out;
> =20
> -		dev->_rx->first =3D dev->_rx;
> -		atomic_set(&dev->_rx->count, 1);
> -		dev->num_rx_queues =3D 1;
> -	}
> -#endif
>  	/* Init, if this function is available */
>  	if (dev->netdev_ops->ndo_init) {
>  		ret =3D dev->netdev_ops->ndo_init(dev);
> @@ -5414,10 +5428,6 @@ struct net_device *alloc_netdev_mq(int sizeof_=
priv, const char *name,
>  	struct net_device *dev;
>  	size_t alloc_size;
>  	struct net_device *p;
> -#ifdef CONFIG_RPS
> -	struct netdev_rx_queue *rx;
> -	int i;
> -#endif
> =20
>  	BUG_ON(strlen(name) >=3D sizeof(dev->name));
> =20
> @@ -5443,29 +5453,12 @@ struct net_device *alloc_netdev_mq(int sizeof=
_priv, const char *name,
>  		goto free_p;
>  	}
> =20
> -#ifdef CONFIG_RPS
> -	rx =3D kcalloc(queue_count, sizeof(struct netdev_rx_queue), GFP_KER=
NEL);
> -	if (!rx) {
> -		printk(KERN_ERR "alloc_netdev: Unable to allocate "
> -		       "rx queues.\n");
> -		goto free_tx;
> -	}
> -
> -	atomic_set(&rx->count, queue_count);
> -
> -	/*
> -	 * Set a pointer to first element in the array which holds the
> -	 * reference count.
> -	 */
> -	for (i =3D 0; i < queue_count; i++)
> -		rx[i].first =3D rx;
> -#endif
> =20
>  	dev =3D PTR_ALIGN(p, NETDEV_ALIGN);
>  	dev->padded =3D (char *)dev - (char *)p;
> =20
>  	if (dev_addr_init(dev))
> -		goto free_rx;
> +		goto free_tx;
> =20
>  	dev_mc_init(dev);
>  	dev_uc_init(dev);
> @@ -5477,7 +5470,6 @@ struct net_device *alloc_netdev_mq(int sizeof_p=
riv, const char *name,
>  	dev->real_num_tx_queues =3D queue_count;
> =20
>  #ifdef CONFIG_RPS
> -	dev->_rx =3D rx;
>  	dev->num_rx_queues =3D queue_count;
>  #endif
> =20
> @@ -5495,11 +5487,7 @@ struct net_device *alloc_netdev_mq(int sizeof_=
priv, const char *name,
>  	strcpy(dev->name, name);
>  	return dev;
> =20
> -free_rx:
> -#ifdef CONFIG_RPS
> -	kfree(rx);
>  free_tx:
> -#endif
>  	kfree(tx);
>  free_p:
>  	kfree(p);
>=20


