From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/3 v2] net: allocate tx queues in register_netdevice
Date: Tue, 19 Oct 2010 10:13:26 +0200
Message-ID: <1287476006.2676.12.camel@edumazet-laptop>
References: <alpine.DEB.1.00.1010182100180.6676@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	bhutchings@solarflare.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:47338 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755871Ab0JSINc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Oct 2010 04:13:32 -0400
Received: by wwj40 with SMTP id 40so841080wwj.1
        for <netdev@vger.kernel.org>; Tue, 19 Oct 2010 01:13:31 -0700 (PDT)
In-Reply-To: <alpine.DEB.1.00.1010182100180.6676@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 18 octobre 2010 =C3=A0 21:04 -0700, Tom Herbert a =C3=A9crit :
> This patch introduces netif_alloc_netdev_queues which is called from
> register_device instead of alloc_netdev_mq.  This makes TX queue
> allocation symmetric with RX allocation.  Also, queue locks allocatio=
n
> is done in netdev_init_one_queue.  Change set_real_num_tx_queues to
> fail if requested number < 1 or greater than number of allocated
> queues.
>=20
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  include/linux/netdevice.h |    4 +-
>  net/core/dev.c            |  106 ++++++++++++++++++++++-------------=
---------
>  2 files changed, 55 insertions(+), 55 deletions(-)
>=20
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 14fbb04..880d565 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1696,8 +1696,8 @@ static inline int netif_is_multiqueue(const str=
uct net_device *dev)
>  	return dev->num_tx_queues > 1;
>  }
> =20
> -extern void netif_set_real_num_tx_queues(struct net_device *dev,
> -					 unsigned int txq);
> +extern int netif_set_real_num_tx_queues(struct net_device *dev,
> +					unsigned int txq);
> =20
>  #ifdef CONFIG_RPS
>  extern int netif_set_real_num_rx_queues(struct net_device *dev,
> diff --git a/net/core/dev.c b/net/core/dev.c
> index d33adec..7ae5c7e 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1553,18 +1553,20 @@ static void dev_queue_xmit_nit(struct sk_buff=
 *skb, struct net_device *dev)
>   * Routine to help set real_num_tx_queues. To avoid skbs mapped to q=
ueues
>   * greater then real_num_tx_queues stale skbs on the qdisc must be f=
lushed.
>   */
> -void netif_set_real_num_tx_queues(struct net_device *dev, unsigned i=
nt txq)
> +int netif_set_real_num_tx_queues(struct net_device *dev, unsigned in=
t txq)
>  {
> -	unsigned int real_num =3D dev->real_num_tx_queues;
> +	if (txq < 1 || txq > dev->num_tx_queues)
> +		return -EINVAL;
> =20
> -	if (unlikely(txq > dev->num_tx_queues))
> -		;
> -	else if (txq > real_num)
> -		dev->real_num_tx_queues =3D txq;
> -	else if (txq < real_num) {
> -		dev->real_num_tx_queues =3D txq;
> -		qdisc_reset_all_tx_gt(dev, txq);
> +	if (dev->reg_state =3D=3D NETREG_REGISTERED) {
> +		ASSERT_RTNL();
> +
> +		if (txq < dev->real_num_tx_queues)
> +			qdisc_reset_all_tx_gt(dev, txq);
>  	}
> +
> +	dev->real_num_tx_queues =3D txq;
> +	return 0;
>  }
>  EXPORT_SYMBOL(netif_set_real_num_tx_queues);
> =20
> @@ -4928,20 +4930,6 @@ static void rollback_registered(struct net_dev=
ice *dev)
>  	rollback_registered_many(&single);
>  }
> =20
> -static void __netdev_init_queue_locks_one(struct net_device *dev,
> -					  struct netdev_queue *dev_queue,
> -					  void *_unused)
> -{
> -	spin_lock_init(&dev_queue->_xmit_lock);
> -	netdev_set_xmit_lockdep_class(&dev_queue->_xmit_lock, dev->type);
> -	dev_queue->xmit_lock_owner =3D -1;
> -}
> -
> -static void netdev_init_queue_locks(struct net_device *dev)
> -{
> -	netdev_for_each_tx_queue(dev, __netdev_init_queue_locks_one, NULL);
> -}
> -
>  unsigned long netdev_fix_features(unsigned long features, const char=
 *name)
>  {
>  	/* Fix illegal SG+CSUM combinations. */
> @@ -5034,6 +5022,41 @@ static int netif_alloc_rx_queues(struct net_de=
vice *dev)
>  	return 0;
>  }
> =20
> +static int netif_alloc_netdev_queues(struct net_device *dev)
> +{
> +	unsigned int count =3D dev->num_tx_queues;
> +	struct netdev_queue *tx;
> +
> +	BUG_ON(count < 1);
> +
> +	tx =3D kcalloc(count, sizeof(struct netdev_queue), GFP_KERNEL);
> +	if (!tx) {
> +		pr_err("netdev: Unable to allocate %u tx queues.\n",
> +		       count);
> +			return -ENOMEM;

One extra tab before the return

Other than that, patch seems fine to me, thanks !

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>



