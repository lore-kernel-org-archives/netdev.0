From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net: reimplement softnet_data.output_queue as a
 FIFO queue
Date: Tue, 27 Apr 2010 22:36:58 +0200
Message-ID: <1272400618.2343.13.camel@edumazet-laptop>
References: <1272359184-2929-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:44327 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755588Ab0D0Unk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 16:43:40 -0400
Received: by bwz19 with SMTP id 19so4950bwz.21
        for <netdev@vger.kernel.org>; Tue, 27 Apr 2010 13:43:38 -0700 (PDT)
In-Reply-To: <1272359184-2929-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 27 avril 2010 =C3=A0 17:06 +0800, Changli Gao a =C3=A9crit :
> reimplement softnet_data.output_queue as a FIFO queue.
>=20
> reimplement softnet_data.output_queue as a FIFO queue to keep the fai=
rness among
> the qdiscs rescheduled.
>=20
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

> ----
>  include/linux/netdevice.h |    1 +
>  net/core/dev.c            |   22 ++++++++++++----------
>  2 files changed, 13 insertions(+), 10 deletions(-)
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 3c5ed5f..c04ca24 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1385,6 +1385,7 @@ static inline int unregister_gifconf(unsigned i=
nt family)
>   */
>  struct softnet_data {
>  	struct Qdisc		*output_queue;
> +	struct Qdisc		**output_queue_tailp;
>  	struct list_head	poll_list;
>  	struct sk_buff		*completion_queue;
> =20
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 4d43f1a..3d31491 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1557,8 +1557,9 @@ static inline void __netif_reschedule(struct Qd=
isc *q)
> =20
>  	local_irq_save(flags);
>  	sd =3D &__get_cpu_var(softnet_data);
> -	q->next_sched =3D sd->output_queue;
> -	sd->output_queue =3D q;
> +	q->next_sched =3D NULL;
> +	*sd->output_queue_tailp =3D q;
> +	sd->output_queue_tailp =3D &q->next_sched;
>  	raise_softirq_irqoff(NET_TX_SOFTIRQ);
>  	local_irq_restore(flags);
>  }
> @@ -2529,6 +2530,7 @@ static void net_tx_action(struct softirq_action=
 *h)
>  		local_irq_disable();
>  		head =3D sd->output_queue;
>  		sd->output_queue =3D NULL;
> +		sd->output_queue_tailp =3D &sd->output_queue;
>  		local_irq_enable();
> =20
>  		while (head) {
> @@ -5594,7 +5596,6 @@ static int dev_cpu_callback(struct notifier_blo=
ck *nfb,
>  			    void *ocpu)
>  {
>  	struct sk_buff **list_skb;
> -	struct Qdisc **list_net;
>  	struct sk_buff *skb;
>  	unsigned int cpu, oldcpu =3D (unsigned long)ocpu;
>  	struct softnet_data *sd, *oldsd;
> @@ -5615,13 +5616,13 @@ static int dev_cpu_callback(struct notifier_b=
lock *nfb,
>  	*list_skb =3D oldsd->completion_queue;
>  	oldsd->completion_queue =3D NULL;
> =20
> -	/* Find end of our output_queue. */
> -	list_net =3D &sd->output_queue;
> -	while (*list_net)
> -		list_net =3D &(*list_net)->next_sched;
>  	/* Append output queue from offline CPU. */
> -	*list_net =3D oldsd->output_queue;
> -	oldsd->output_queue =3D NULL;
> +	if (oldsd->output_queue) {
> +		*sd->output_queue_tailp =3D oldsd->output_queue;
> +		sd->output_queue_tailp =3D oldsd->output_queue_tailp;
> +		oldsd->output_queue =3D NULL;
> +		oldsd->output_queue_tailp =3D &oldsd->output_queue;
> +	}
> =20
>  	raise_softirq_irqoff(NET_TX_SOFTIRQ);
>  	local_irq_enable();
> @@ -5851,7 +5852,8 @@ static int __init net_dev_init(void)
>  		skb_queue_head_init(&sd->input_pkt_queue);
>  		sd->completion_queue =3D NULL;
>  		INIT_LIST_HEAD(&sd->poll_list);
> -
> +		sd->output_queue =3D NULL;
> +		sd->output_queue_tailp =3D &sd->output_queue;
>  #ifdef CONFIG_RPS
>  		sd->csd.func =3D rps_trigger_softirq;
>  		sd->csd.info =3D sd;
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20


