From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC] loopback: optimization
Date: Tue, 04 Nov 2008 07:36:48 +0100
Message-ID: <490FED80.9090601@cosmosbay.com>
References: <20081103213758.59a8361d@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:58267 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752035AbYKDGhA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2008 01:37:00 -0500
In-Reply-To: <20081103213758.59a8361d@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> This is something I was trying out to try improving loopback performa=
nce.
> It moves loopback processing from the generic backlog per-cpu queues,
> to its own set of queues. I thought this might help the cache localit=
y
> and the loopback doesn't have to do relatively expensive local_irq_di=
sable()
> operations.
>=20
> BUT it didn't seem to help with tbench, but it might help others who
> want to go farther with it. Code runs but treat it ASIS at this point=
=2E
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20
>=20
> --- a/drivers/net/loopback.c	2008-11-03 10:13:31.000000000 -0800
> +++ b/drivers/net/loopback.c	2008-11-03 11:05:52.000000000 -0800
> @@ -59,51 +59,79 @@
>  #include <linux/percpu.h>
>  #include <net/net_namespace.h>
> =20
> -struct pcpu_lstats {
> +struct loopback_per_cpu {
> +	struct sk_buff_head rxq;
> +	struct napi_struct napi;
> +
>  	unsigned long packets;
>  	unsigned long bytes;
>  };
> =20
> +
>  /*
>   * The higher levels take care of making this non-reentrant (it's
>   * called with bh's disabled).
>   */
>  static int loopback_xmit(struct sk_buff *skb, struct net_device *dev=
)
>  {
> -	struct pcpu_lstats *pcpu_lstats, *lb_stats;
> +	struct loopback_per_cpu *lo =3D dev->ml_priv, *pcpu;
> =20
>  	skb_orphan(skb);
> =20
> -	skb->protocol =3D eth_type_trans(skb,dev);
> +	skb->protocol =3D eth_type_trans(skb, dev);
> =20
>  	dev->last_rx =3D jiffies;
> =20
>  	/* it's OK to use per_cpu_ptr() because BHs are off */
> -	pcpu_lstats =3D dev->ml_priv;
> -	lb_stats =3D per_cpu_ptr(pcpu_lstats, smp_processor_id());
> -	lb_stats->bytes +=3D skb->len;
> -	lb_stats->packets++;
> +	pcpu =3D per_cpu_ptr(lo, smp_processor_id());
> =20
> -	netif_rx(skb);
> +	if (likely(pcpu->rxq.qlen < netdev_max_backlog)) {

> +		if (pcpu->rxq.qlen =3D=3D 0)
> +			__napi_schedule(&lo->napi);

Hum...

Most of the time I suspect we take this __napi_schedule() thing.

So are you sure you use the right one (&lo->napi, not &pcpu->napi) ?

This is the where point we still do a cache line ping-pong.

> +
> +		__skb_queue_tail(&pcpu->rxq, skb);
> +		pcpu->bytes +=3D skb->len;
> +		pcpu->packets++;
> +
> +		return NET_XMIT_SUCCESS;
> +	} else {
> +		dev->stats.rx_dropped++;
> +		dev_kfree_skb_any(skb);
> +		return NET_XMIT_DROP;
> +	}
> +}
> =20
> -	return 0;
> +static int loopback_poll(struct napi_struct *napi, int work_limit)
> +{
> +	struct loopback_per_cpu *pcpu
> +		=3D container_of(napi, struct loopback_per_cpu, napi);
> +	struct sk_buff *skb;
> +	int work_done =3D 0;
> +
> +	while ( (skb =3D __skb_dequeue(&pcpu->rxq)) ) {
> +		netif_receive_skb(skb);
> +
> +		if (++work_done >=3D work_limit)
> +			goto done;
> +	}
> +
> +	__napi_complete(napi);
> +done:
> +	return work_done;
>  }
> =20
>  static struct net_device_stats *get_stats(struct net_device *dev)
>  {
> -	const struct pcpu_lstats *pcpu_lstats;
> +	const struct loopback_per_cpu *lo =3D dev->ml_priv;
>  	struct net_device_stats *stats =3D &dev->stats;
>  	unsigned long bytes =3D 0;
>  	unsigned long packets =3D 0;
>  	int i;
> =20
> -	pcpu_lstats =3D dev->ml_priv;
>  	for_each_possible_cpu(i) {
> -		const struct pcpu_lstats *lb_stats;
> -
> -		lb_stats =3D per_cpu_ptr(pcpu_lstats, i);
> -		bytes   +=3D lb_stats->bytes;
> -		packets +=3D lb_stats->packets;
> +		const struct loopback_per_cpu *pcpu =3D per_cpu_ptr(lo, i);
> +		bytes   +=3D pcpu->bytes;
> +		packets +=3D pcpu->packets;
>  	}
>  	stats->rx_packets =3D packets;
>  	stats->tx_packets =3D packets;
> @@ -127,21 +155,43 @@ static const struct ethtool_ops loopback
> =20
>  static int loopback_dev_init(struct net_device *dev)
>  {
> -	struct pcpu_lstats *lstats;
> +	struct loopback_per_cpu *lo;
> +	int i;
> =20
> -	lstats =3D alloc_percpu(struct pcpu_lstats);
> -	if (!lstats)
> +	lo =3D alloc_percpu(struct loopback_per_cpu);
> +	if (!lo)
>  		return -ENOMEM;
> =20
> -	dev->ml_priv =3D lstats;
> +	dev->ml_priv =3D lo;
> +
> +	for_each_possible_cpu(i) {
> +		struct loopback_per_cpu *pcpu =3D per_cpu_ptr(lo, i);
> +		skb_queue_head_init(&pcpu->rxq);
> +		netif_napi_add(dev, &pcpu->napi, loopback_poll, 64);
> +	}
> +
> +	return 0;
> +}
> +
> +static int loopback_dev_stop(struct net_device *dev)
> +{
> +	struct loopback_per_cpu *lo =3D dev->ml_priv;
> +	int i;
> +
> +	for_each_possible_cpu(i) {
> +		struct loopback_per_cpu *pcpu =3D per_cpu_ptr(lo, i);
> +
> +		napi_synchronize(&pcpu->napi);
> +		__skb_queue_purge(&pcpu->rxq);
> +	}
>  	return 0;
>  }
> =20
>  static void loopback_dev_free(struct net_device *dev)
>  {
> -	struct pcpu_lstats *lstats =3D dev->ml_priv;
> +	struct loopback_per_cpu *lo =3D dev->ml_priv;
> =20
> -	free_percpu(lstats);
> +	free_percpu(lo);
>  	free_netdev(dev);
>  }
> =20
> @@ -169,6 +219,7 @@ static void loopback_setup(struct net_de
>  	dev->header_ops		=3D &eth_header_ops;
>  	dev->init =3D loopback_dev_init;
>  	dev->destructor =3D loopback_dev_free;
> +	dev->stop =3D loopback_dev_stop;
>  }
> =20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
>=20


