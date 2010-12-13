From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 4/5] ifb: add multiqueue support
Date: Mon, 13 Dec 2010 17:26:13 +0100
Message-ID: <1292257573.2759.41.camel@edumazet-laptop>
References: <1292251414-5154-1-git-send-email-xiaosuo@gmail.com>
	 <1292251414-5154-4-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:60138 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757968Ab0LMQ0T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 11:26:19 -0500
Received: by fxm18 with SMTP id 18so6445915fxm.2
        for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 08:26:17 -0800 (PST)
In-Reply-To: <1292251414-5154-4-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 13 d=C3=A9cembre 2010 =C3=A0 22:43 +0800, Changli Gao a =C3=A9=
crit :
> Each ifb NIC has nr_cpu_ids rx queues and nr_cpu_ids queues. Packets
> transmitted to ifb are enqueued to the corresponding per cpu tx queue=
s,
> and processed in the corresponding per cpu tasklet latter.
>=20
> The stats are converted to the u64 ones.
>=20
> tq is a stack variable now. It makes ifb_q_private smaller and tx que=
ue
> locked only once in ri_tasklet.
>=20

Might be good to say the tx_queue_len is multiplied by number of online
cpus ;)

> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ---
>  drivers/net/ifb.c |  211 ++++++++++++++++++++++++++++++++++++-------=
-----------
>  1 file changed, 141 insertions(+), 70 deletions(-)
> diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
> index 57c5cfb..16c767b 100644
> --- a/drivers/net/ifb.c
> +++ b/drivers/net/ifb.c
> @@ -37,56 +37,63 @@
>  #include <net/net_namespace.h>
> =20
>  #define TX_Q_LIMIT    32
> +struct ifb_q_private {
> +	struct tasklet_struct	ifb_tasklet;
> +	struct sk_buff_head	rq;
> +	struct u64_stats_sync	syncp;
> +	u64			rx_packets;
> +	u64			rx_bytes;
> +	u64			rx_dropped;
> +};
> +
>  struct ifb_private {
> -	struct tasklet_struct   ifb_tasklet;
> -	int     tasklet_pending;
> -	struct sk_buff_head     rq;
> -	struct sk_buff_head     tq;
> +	struct ifb_q_private __percpu	*q;

You probably could use dev->ml_priv (lstats/tstats/dstats)
so that ifb_private just disapears (we save a full cache line)

>  };
> =20
>  static int numifbs =3D 2;
> =20
> -static void ri_tasklet(unsigned long dev)
> +static void ri_tasklet(unsigned long _dev)
>  {
> -
> -	struct net_device *_dev =3D (struct net_device *)dev;
> -	struct ifb_private *dp =3D netdev_priv(_dev);
> -	struct net_device_stats *stats =3D &_dev->stats;
> +	struct net_device *dev =3D (struct net_device *)_dev;
> +	struct ifb_private *p =3D netdev_priv(dev);
> +	struct ifb_q_private *qp;
>  	struct netdev_queue *txq;
>  	struct sk_buff *skb;
> -
> -	txq =3D netdev_get_tx_queue(_dev, 0);
> -	skb =3D skb_peek(&dp->tq);
> -	if (skb =3D=3D NULL) {
> -		if (__netif_tx_trylock(txq)) {
> -			skb_queue_splice_tail_init(&dp->rq, &dp->tq);
> -			__netif_tx_unlock(txq);
> -		} else {
> -			/* reschedule */
> -			goto resched;
> -		}
> +	struct sk_buff_head tq;
> +
> +	__skb_queue_head_init(&tq);
> +	txq =3D netdev_get_tx_queue(dev, raw_smp_processor_id());
> +	qp =3D per_cpu_ptr(p->q, raw_smp_processor_id());

	qp =3D this_cpu_ptr(dev->ifb_qp); is faster

> +	if (!__netif_tx_trylock(txq)) {
> +		tasklet_schedule(&qp->ifb_tasklet);
> +		return;
>  	}
> +	skb_queue_splice_tail_init(&qp->rq, &tq);
> +	if (netif_tx_queue_stopped(txq))
> +		netif_tx_wake_queue(txq);
> +	__netif_tx_unlock(txq);
> =20
> -	while ((skb =3D skb_dequeue(&dp->tq)) !=3D NULL) {
> +	while ((skb =3D __skb_dequeue(&tq)) !=3D NULL) {
>  		u32 from =3D G_TC_FROM(skb->tc_verd);
> =20
>  		skb->tc_verd =3D 0;
>  		skb->tc_verd =3D SET_TC_NCLS(skb->tc_verd);
> -		stats->tx_packets++;
> -		stats->tx_bytes +=3D skb->len;
> +		u64_stats_update_begin(&qp->syncp);
> +		txq->tx_packets++;
> +		txq->tx_bytes +=3D skb->len;
> =20
>  		rcu_read_lock();
>  		skb->dev =3D dev_get_by_index_rcu(&init_net, skb->skb_iif);
>  		if (!skb->dev) {
>  			rcu_read_unlock();
> +			txq->tx_dropped++;
> +			u64_stats_update_end(&qp->syncp);
>  			dev_kfree_skb(skb);
> -			stats->tx_dropped++;
> -			if (skb_queue_len(&dp->tq) !=3D 0)
> -				goto resched;
> -			break;
> +			continue;
>  		}
>  		rcu_read_unlock();
> -		skb->skb_iif =3D _dev->ifindex;
> +		u64_stats_update_end(&qp->syncp);
> +		skb->skb_iif =3D dev->ifindex;

Why is this necessary ? shouldnt skb->skb_iif already be dev->ifindex ?

> =20
>  		if (from & AT_EGRESS) {
>  			dev_queue_xmit(skb);
> @@ -96,48 +103,32 @@ static void ri_tasklet(unsigned long dev)
>  		} else
>  			BUG();
>  	}
> -
> -	if (__netif_tx_trylock(txq)) {
> -		skb =3D skb_peek(&dp->rq);
> -		if (skb =3D=3D NULL) {
> -			dp->tasklet_pending =3D 0;
> -			if (netif_queue_stopped(_dev))
> -				netif_wake_queue(_dev);
> -		} else {
> -			__netif_tx_unlock(txq);
> -			goto resched;
> -		}
> -		__netif_tx_unlock(txq);
> -	} else {
> -resched:
> -		dp->tasklet_pending =3D 1;
> -		tasklet_schedule(&dp->ifb_tasklet);
> -	}
> -
>  }
> =20
>  static netdev_tx_t ifb_xmit(struct sk_buff *skb, struct net_device *=
dev)
>  {
> -	struct ifb_private *dp =3D netdev_priv(dev);
> -	struct net_device_stats *stats =3D &dev->stats;
> +	struct ifb_private *p =3D netdev_priv(dev);
> +	struct ifb_q_private *qp =3D per_cpu_ptr(p->q,
> +					       skb_get_queue_mapping(skb));

Would be good to add a=20

WARN_ON(skb_get_queue_mapping(skb) !=3D smp_processor_id());


>  	u32 from =3D G_TC_FROM(skb->tc_verd);
> =20
> -	stats->rx_packets++;
> -	stats->rx_bytes +=3D skb->len;
> +	u64_stats_update_begin(&qp->syncp);
> +	qp->rx_packets++;
> +	qp->rx_bytes +=3D skb->len;
> =20
>  	if (!(from & (AT_INGRESS|AT_EGRESS)) || !skb->skb_iif) {
> +		qp->rx_dropped++;
> +		u64_stats_update_end(&qp->syncp);
>  		dev_kfree_skb(skb);
> -		stats->rx_dropped++;
>  		return NETDEV_TX_OK;
>  	}
> +	u64_stats_update_end(&qp->syncp);
> =20
> -	__skb_queue_tail(&dp->rq, skb);
> -	if (!dp->tasklet_pending) {
> -		dp->tasklet_pending =3D 1;
> -		tasklet_schedule(&dp->ifb_tasklet);
> -	}
> +	__skb_queue_tail(&qp->rq, skb);
> +	if (skb_queue_len(&qp->rq) =3D=3D 1)
> +		tasklet_schedule(&qp->ifb_tasklet);
> =20
> -	if (skb_queue_len(&dp->rq) >=3D dev->tx_queue_len)
> +	if (skb_queue_len(&qp->rq) >=3D dev->tx_queue_len)

This seems wrong...
You need to change to netif_tx_stop_queue(txq)

>  		netif_stop_queue(dev);
> =20
>  	return NETDEV_TX_OK;
> @@ -145,33 +136,103 @@ static netdev_tx_t ifb_xmit(struct sk_buff *sk=
b, struct net_device *dev)
> =20
>  static int ifb_close(struct net_device *dev)
>  {
> -	struct ifb_private *dp =3D netdev_priv(dev);
> -
> -	tasklet_kill(&dp->ifb_tasklet);
> -	netif_stop_queue(dev);
> -	__skb_queue_purge(&dp->rq);
> -	__skb_queue_purge(&dp->tq);
> +	struct ifb_private *p =3D netdev_priv(dev);
> +	struct ifb_q_private *qp;
> +	int cpu;
> +
> +	for_each_possible_cpu(cpu) {
> +		qp =3D per_cpu_ptr(p->q, cpu);
> +		tasklet_kill(&qp->ifb_tasklet);
> +		netif_tx_stop_queue(netdev_get_tx_queue(dev, cpu));
> +		__skb_queue_purge(&qp->rq);
> +	}
> =20
>  	return 0;
>  }
> =20
>  static int ifb_open(struct net_device *dev)
>  {
> -	struct ifb_private *dp =3D netdev_priv(dev);
> +	int cpu;
> +



> +	for_each_possible_cpu(cpu)
> +		netif_tx_start_queue(netdev_get_tx_queue(dev, cpu));
> +
> +	return 0;
> +}
> +
> +static int ifb_init(struct net_device *dev)
> +{
> +	struct ifb_private *p =3D netdev_priv(dev);
> +	struct ifb_q_private *q;
> +	int cpu;
> =20
> -	tasklet_init(&dp->ifb_tasklet, ri_tasklet, (unsigned long)dev);
> -	__skb_queue_head_init(&dp->rq);
> -	__skb_queue_head_init(&dp->tq);
> -	netif_start_queue(dev);
> +	p->q =3D alloc_percpu(struct ifb_q_private);
> +	if (!p->q)
> +		return -ENOMEM;

Hmm, maybe  use netdev_queue_numa_node_write() somewhere, so that
qdisc_alloc() can use NUMA affinities.

> +	for_each_possible_cpu(cpu) {
> +		q =3D per_cpu_ptr(p->q, cpu);
> +		tasklet_init(&q->ifb_tasklet, ri_tasklet, (unsigned long)dev);
> +		__skb_queue_head_init(&q->rq);
> +	}
> =20
>  	return 0;
>  }
> =20
> +static void ifb_uninit(struct net_device *dev)
> +{
> +	struct ifb_private *p =3D netdev_priv(dev);
> +
> +	free_percpu(p->q);
> +}
> +
> +static u16 ifb_select_queue(struct net_device *dev, struct sk_buff *=
skb)
> +{
> +	return smp_processor_id();
> +}
> +
> +static struct rtnl_link_stats64 *ifb_get_stats64(struct net_device *=
dev,
> +		struct rtnl_link_stats64 *stats)
> +{
> +	struct ifb_private *p =3D netdev_priv(dev);
> +	struct ifb_q_private *q;
> +	struct netdev_queue *txq;
> +	int cpu;
> +	u64 rx_packets, rx_bytes, rx_dropped;
> +	u64 tx_packets, tx_bytes, tx_dropped;
> +	unsigned int start;
> +
> +	for_each_possible_cpu(cpu) {
> +		q =3D per_cpu_ptr(p->q, cpu);
> +		txq =3D netdev_get_tx_queue(dev, cpu);
> +		do {
> +			start =3D u64_stats_fetch_begin_bh(&q->syncp);
> +			rx_packets =3D q->rx_packets;
> +			rx_bytes =3D q->rx_bytes;
> +			rx_dropped =3D q->rx_dropped;
> +			tx_packets =3D txq->tx_packets;
> +			tx_bytes =3D txq->tx_bytes;
> +			tx_dropped =3D txq->tx_dropped;
> +		} while (u64_stats_fetch_retry_bh(&q->syncp, start));
> +		stats->rx_packets +=3D rx_packets;
> +		stats->rx_bytes +=3D rx_bytes;
> +		stats->rx_dropped +=3D rx_dropped;
> +		stats->tx_packets +=3D tx_packets;
> +		stats->tx_bytes +=3D tx_bytes;
> +		stats->tx_dropped +=3D tx_dropped;
> +	}
> +
> +	return stats;
> +}
> +
>  static const struct net_device_ops ifb_netdev_ops =3D {
> +	.ndo_init		=3D ifb_init,
> +	.ndo_uninit		=3D ifb_uninit,
>  	.ndo_open		=3D ifb_open,
>  	.ndo_stop		=3D ifb_close,
>  	.ndo_start_xmit		=3D ifb_xmit,
>  	.ndo_validate_addr	=3D eth_validate_addr,
> +	.ndo_select_queue	=3D ifb_select_queue,
> +	.ndo_get_stats64	=3D ifb_get_stats64,
>  };
> =20
>  static void ifb_setup(struct net_device *dev)
> @@ -202,11 +263,21 @@ static int ifb_validate(struct nlattr *tb[], st=
ruct nlattr *data[])
>  	return 0;
>  }
> =20
> +static int ifb_get_tx_queues(struct net *net, struct nlattr *tb[],
> +			     unsigned int *tx_queues,
> +			     unsigned int *real_tx_queues)
> +{
> +	*real_tx_queues =3D *tx_queues =3D nr_cpu_ids;
> +
> +	return 0;
> +}
> +
>  static struct rtnl_link_ops ifb_link_ops __read_mostly =3D {
>  	.kind		=3D "ifb",
>  	.priv_size	=3D sizeof(struct ifb_private),
>  	.setup		=3D ifb_setup,
>  	.validate	=3D ifb_validate,
> +	.get_tx_queues	=3D ifb_get_tx_queues,
>  };
> =20
>  /* Number of ifb devices to be set up by this module. */
> @@ -218,8 +289,8 @@ static int __init ifb_init_one(int index)
>  	struct net_device *dev_ifb;
>  	int err;
> =20
> -	dev_ifb =3D alloc_netdev(sizeof(struct ifb_private), "ifb%d", ifb_s=
etup);
> -
> +	dev_ifb =3D alloc_netdev_mq(sizeof(struct ifb_private), "ifb%d",
> +				  ifb_setup, nr_cpu_ids);
>  	if (!dev_ifb)
>  		return -ENOMEM;
> =20


