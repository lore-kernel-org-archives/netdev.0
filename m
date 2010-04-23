From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v6] net: batch skb dequeueing from softnet
 input_pkt_queue
Date: Fri, 23 Apr 2010 11:27:05 +0200
Message-ID: <1272014825.7895.7851.camel@edumazet-laptop>
References: <1272010378-2955-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, jamal <hadi@cyberus.ca>,
	Tom Herbert <therbert@google.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:61474 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753504Ab0DWJ1S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 05:27:18 -0400
Received: by bwz25 with SMTP id 25so10917069bwz.28
        for <netdev@vger.kernel.org>; Fri, 23 Apr 2010 02:27:16 -0700 (PDT)
In-Reply-To: <1272010378-2955-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 23 avril 2010 =C3=A0 16:12 +0800, Changli Gao a =C3=A9crit =
:
> batch skb dequeueing from softnet input_pkt_queue.
>=20
> batch skb dequeueing from softnet input_pkt_queue to reduce potential=
 lock
> contention when RPS is enabled.
>=20
> Note: in the worst case, the number of packets in a softnet_data may =
be double
> of netdev_max_backlog.
>=20
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Very good patch Changli, thanks !

Lets see how it improves thing for Jamal benchs ;)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

> ----
>  include/linux/netdevice.h |    6 +++--
>  net/core/dev.c            |   50 +++++++++++++++++++++++++++++++----=
-----------
>  2 files changed, 38 insertions(+), 18 deletions(-)
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 3c5ed5f..6ae9f2b 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1387,6 +1387,7 @@ struct softnet_data {
>  	struct Qdisc		*output_queue;
>  	struct list_head	poll_list;
>  	struct sk_buff		*completion_queue;
> +	struct sk_buff_head	process_queue;
> =20
>  #ifdef CONFIG_RPS
>  	struct softnet_data	*rps_ipi_list;
> @@ -1401,10 +1402,11 @@ struct softnet_data {
>  	struct napi_struct	backlog;
>  };
> =20
> -static inline void input_queue_head_incr(struct softnet_data *sd)
> +static inline void input_queue_head_add(struct softnet_data *sd,
> +					unsigned int len)
>  {
>  #ifdef CONFIG_RPS
> -	sd->input_queue_head++;
> +	sd->input_queue_head +=3D len;
>  #endif
>  }
> =20
> diff --git a/net/core/dev.c b/net/core/dev.c
> index a4a7c36..c1585f9 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2409,12 +2409,13 @@ static int enqueue_to_backlog(struct sk_buff =
*skb, int cpu,
>  	__get_cpu_var(netdev_rx_stat).total++;
> =20
>  	rps_lock(sd);
> -	if (sd->input_pkt_queue.qlen <=3D netdev_max_backlog) {
> -		if (sd->input_pkt_queue.qlen) {
> +	if (skb_queue_len(&sd->input_pkt_queue) <=3D netdev_max_backlog) {
> +		if (skb_queue_len(&sd->input_pkt_queue)) {
>  enqueue:
>  			__skb_queue_tail(&sd->input_pkt_queue, skb);
>  #ifdef CONFIG_RPS
> -			*qtail =3D sd->input_queue_head + sd->input_pkt_queue.qlen;
> +			*qtail =3D sd->input_queue_head +
> +					skb_queue_len(&sd->input_pkt_queue);
>  #endif
>  			rps_unlock(sd);
>  			local_irq_restore(flags);
> @@ -2934,13 +2935,21 @@ static void flush_backlog(void *arg)
>  	struct sk_buff *skb, *tmp;
> =20
>  	rps_lock(sd);
> -	skb_queue_walk_safe(&sd->input_pkt_queue, skb, tmp)
> +	skb_queue_walk_safe(&sd->input_pkt_queue, skb, tmp) {
>  		if (skb->dev =3D=3D dev) {
>  			__skb_unlink(skb, &sd->input_pkt_queue);
>  			kfree_skb(skb);
> -			input_queue_head_incr(sd);
> +			input_queue_head_add(sd, 1);
>  		}
> +	}
>  	rps_unlock(sd);
> +
> +	skb_queue_walk_safe(&sd->process_queue, skb, tmp) {
> +		if (skb->dev =3D=3D dev) {
> +			__skb_unlink(skb, &sd->process_queue);
> +			kfree_skb(skb);
> +		}
> +	}
>  }
> =20
>  static int napi_gro_complete(struct sk_buff *skb)
> @@ -3286,24 +3295,30 @@ static int process_backlog(struct napi_struct=
 *napi, int quota)
>  	}
>  #endif
>  	napi->weight =3D weight_p;
> -	do {
> +	local_irq_disable();
> +	while (1) {
>  		struct sk_buff *skb;
> =20
> -		local_irq_disable();
> +		while ((skb =3D __skb_dequeue(&sd->process_queue))) {
> +			local_irq_enable();
> +			__netif_receive_skb(skb);
> +			if (++work >=3D quota)
> +				return work;
> +			local_irq_disable();
> +		}
> +
>  		rps_lock(sd);
> -		skb =3D __skb_dequeue(&sd->input_pkt_queue);
> -		if (!skb) {
> +		input_queue_head_add(sd, skb_queue_len(&sd->input_pkt_queue));
> +		skb_queue_splice_tail_init(&sd->input_pkt_queue,
> +					   &sd->process_queue);
> +		if (skb_queue_empty(&sd->process_queue)) {
>  			__napi_complete(napi);
>  			rps_unlock(sd);
> -			local_irq_enable();
>  			break;
>  		}
> -		input_queue_head_incr(sd);
>  		rps_unlock(sd);
> -		local_irq_enable();
> -
> -		__netif_receive_skb(skb);
> -	} while (++work < quota);
> +	}
> +	local_irq_enable();
> =20
>  	return work;
>  }
> @@ -5631,8 +5646,10 @@ static int dev_cpu_callback(struct notifier_bl=
ock *nfb,
>  	/* Process offline CPU's input_pkt_queue */
>  	while ((skb =3D __skb_dequeue(&oldsd->input_pkt_queue))) {
>  		netif_rx(skb);
> -		input_queue_head_incr(oldsd);
> +		input_queue_head_add(oldsd, 1);
>  	}
> +	while ((skb =3D __skb_dequeue(&oldsd->process_queue)))
> +		netif_rx(skb);
> =20
>  	return NOTIFY_OK;
>  }
> @@ -5851,6 +5868,7 @@ static int __init net_dev_init(void)
>  		struct softnet_data *sd =3D &per_cpu(softnet_data, i);
> =20
>  		skb_queue_head_init(&sd->input_pkt_queue);
> +		skb_queue_head_init(&sd->process_queue);
>  		sd->completion_queue =3D NULL;
>  		INIT_LIST_HEAD(&sd->poll_list);
> =20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20


