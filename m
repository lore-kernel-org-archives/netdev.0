From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net: batch skb dequeueing from softnet
 input_pkt_queue
Date: Tue, 13 Apr 2010 10:08:32 +0200
Message-ID: <1271146112.16881.213.camel@edumazet-laptop>
References: <1271173102-2980-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:64927 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751397Ab0DMIIl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 04:08:41 -0400
Received: by bwz19 with SMTP id 19so190809bwz.21
        for <netdev@vger.kernel.org>; Tue, 13 Apr 2010 01:08:39 -0700 (PDT)
In-Reply-To: <1271173102-2980-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 13 avril 2010 =C3=A0 23:38 +0800, Changli Gao a =C3=A9crit :
> batch skb dequeueing from softnet input_pkt_queue
>=20
> batch skb dequeueing from softnet input_pkt_queue to reduce potential=
 lock
> contention and irq disabling/enabling.
>=20

Very interesting idea, but implementation is too complex, and probably
buggy, in a area that too few people understand today.

Could you keep it as simple as possible ?

> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ----
>  include/linux/netdevice.h |    2 ++
>  net/core/dev.c            |   45 +++++++++++++++++++++++++++++++++++=
++++------
>  2 files changed, 41 insertions(+), 6 deletions(-)
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index d1a21b5..bc7a0d7 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1335,6 +1335,8 @@ struct softnet_data {
>  	struct call_single_data	csd ____cacheline_aligned_in_smp;
>  #endif
>  	struct sk_buff_head	input_pkt_queue;
> +	struct sk_buff_head	processing_queue;

	Probably not necessary.

> +	volatile bool		flush_processing_queue;

Use of 'volatile' is strongly discouraged, I would say, forbidden.=20

Its usually a sign of 'I dont exactly what memory ordering I need, so I
throw a volatile just in case'. We live in a world full of RCU, read ,
write, full barriers. And these apis are well documented.

>  	struct napi_struct	backlog;
>  };
> =20
> diff --git a/net/core/dev.c b/net/core/dev.c
> index a10a216..ac24293 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2324,6 +2324,11 @@ static void trigger_softirq(void *data)
>  }
>  #endif /* CONFIG_SMP */
> =20
> +static inline u32 softnet_input_qlen(struct softnet_data *queue)
> +{
> +	return queue->input_pkt_queue.qlen + queue->processing_queue.qlen;
> +}
> +
>  /*
>   * enqueue_to_backlog is called to queue an skb to a per CPU backlog
>   * queue (may be a remote CPU queue).
> @@ -2339,8 +2344,8 @@ static int enqueue_to_backlog(struct sk_buff *s=
kb, int cpu)
>  	__get_cpu_var(netdev_rx_stat).total++;
> =20
>  	rps_lock(queue);
> -	if (queue->input_pkt_queue.qlen <=3D netdev_max_backlog) {
> -		if (queue->input_pkt_queue.qlen) {
> +	if (softnet_input_qlen(queue) <=3D netdev_max_backlog) {
> +		if (softnet_input_qlen(queue)) {
>  enqueue:
>  			__skb_queue_tail(&queue->input_pkt_queue, skb);
>  			rps_unlock(queue);
> @@ -2803,6 +2808,7 @@ static void flush_backlog(void *arg)
>  			__skb_unlink(skb, &queue->input_pkt_queue);
>  			kfree_skb(skb);
>  		}
> +	queue->flush_processing_queue =3D true;

	Probably not necessary

>  	rps_unlock(queue);
>  }
> =20
> @@ -3112,14 +3118,23 @@ static int process_backlog(struct napi_struct=
 *napi, int quota)
>  	struct softnet_data *queue =3D &__get_cpu_var(softnet_data);
>  	unsigned long start_time =3D jiffies;
> =20
> +	if (queue->flush_processing_queue) {

Really... this is bloat IMHO

> +		struct sk_buff *skb;
> +
> +		queue->flush_processing_queue =3D false;
> +		while ((skb =3D __skb_dequeue(&queue->processing_queue)))
> +			kfree_skb(skb);
> +	}
> +
>  	napi->weight =3D weight_p;
>  	do {
>  		struct sk_buff *skb;
> =20
>  		local_irq_disable();
>  		rps_lock(queue);
> -		skb =3D __skb_dequeue(&queue->input_pkt_queue);
> -		if (!skb) {
> +		skb_queue_splice_tail_init(&queue->input_pkt_queue,
> +					   &queue->processing_queue);
> +		if (skb_queue_empty(&queue->processing_queue)) {
>  			__napi_complete(napi);
>  			rps_unlock(queue);
>  			local_irq_enable();
> @@ -3128,9 +3143,22 @@ static int process_backlog(struct napi_struct =
*napi, int quota)
>  		rps_unlock(queue);
>  		local_irq_enable();
> =20
> -		__netif_receive_skb(skb);
> -	} while (++work < quota && jiffies =3D=3D start_time);
> +		while ((skb =3D __skb_dequeue(&queue->processing_queue))) {
> +			__netif_receive_skb(skb);
> +			if (++work < quota && jiffies =3D=3D start_time)
> +				continue;
> +			if (!queue->flush_processing_queue)
> +				goto out;
> +			queue->flush_processing_queue =3D false;

once again, ... so much code for a unlikely event...

> +			while ((skb =3D __skb_dequeue(&queue->processing_queue))) {
> +				__netif_receive_skb(skb);
> +				++work;
> +			}
> +			goto out;
> +		}
> +	} while (1);
> =20
> +out:
>  	return work;
>  }
> =20
> @@ -5487,6 +5515,9 @@ static int dev_cpu_callback(struct notifier_blo=
ck *nfb,
>  	raise_softirq_irqoff(NET_TX_SOFTIRQ);
>  	local_irq_enable();
> =20
> +	while ((skb =3D __skb_dequeue(&oldsd->processing_queue)))
> +		netif_rx(skb);
> +
>  	/* Process offline CPU's input_pkt_queue */
>  	while ((skb =3D __skb_dequeue(&oldsd->input_pkt_queue)))
>  		netif_rx(skb);
> @@ -5709,6 +5740,8 @@ static int __init net_dev_init(void)
> =20
>  		queue =3D &per_cpu(softnet_data, i);
>  		skb_queue_head_init(&queue->input_pkt_queue);
> +		skb_queue_head_init(&queue->processing_queue);
> +		queue->flush_processing_queue =3D false;
>  		queue->completion_queue =3D NULL;
>  		INIT_LIST_HEAD(&queue->poll_list);
> =20

I advise to keep it simple.

My suggestion would be to limit this patch only to process_backlog().

Really if you touch other areas, there is too much risk.

Perform sort of skb_queue_splice_tail_init() into a local (stack) queue=
,
but the trick is to not touch input_pkt_queue.qlen, so that we dont slo=
w
down enqueue_to_backlog().

Process at most 'quota' skbs (or jiffies limit).

relock queue.
input_pkt_queue.qlen -=3D number_of_handled_skbs;

In the unlikely event we have unprocessed skbs in local queue,
re-insert the remaining skbs at head of input_pt_queue.

Consider if input_pkt_queue.qlen is 0 or not, to call
__napi_complete(napi); or not :)



