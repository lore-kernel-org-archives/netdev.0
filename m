From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] net: reimplement completion_queue as a FIFO queue
Date: Mon, 26 Apr 2010 07:14:01 +0200
Message-ID: <1272258841.2069.968.camel@edumazet-laptop>
References: <1272252016-11755-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:46248 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750969Ab0DZFOI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 01:14:08 -0400
Received: by bwz19 with SMTP id 19so126774bwz.21
        for <netdev@vger.kernel.org>; Sun, 25 Apr 2010 22:14:04 -0700 (PDT)
In-Reply-To: <1272252016-11755-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 26 avril 2010 =C3=A0 11:20 +0800, Changli Gao a =C3=A9crit :
> reimplement completion_queue as a FIFO queue.
>=20
> As slab allocator always does its best to return the latest unused ob=
jects, we'd
> better release skb in order, this patch reimplement completion_queue =
as a FIFO
> queue instead of the old LIFO queue.
>=20

1) New devices dont use completion queue.

2) Hot objects are the last enqueued.
   If many objects were queued, the old one are not hot anymore.

   Using FIFO will give more cache misses, when walking the chain
(skb->next)

3) Claim about slab allocators properties are irrelevant. SLUB doesnt
touch objects, unless some debugging is on.

> At the same time, a opencoding skb queue is replaced with a sk_buff_h=
ead queue.
>=20

Yes, this is a pro, yet it cost a bit more, because of extra things
(qlen management, and two pointers per object)

=46or example, compare text size before and after the patch.

If you feel open coding a LIFO is error prone, you could add generic
primitives to kernel ?

> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ----
>  include/linux/netdevice.h |    2 +-
>  net/core/dev.c            |   28 ++++++++++------------------
>  net/core/netpoll.c        |   12 +++++-------
>  3 files changed, 16 insertions(+), 26 deletions(-)
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 3c5ed5f..785e514 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1386,7 +1386,7 @@ static inline int unregister_gifconf(unsigned i=
nt family)
>  struct softnet_data {
>  	struct Qdisc		*output_queue;
>  	struct list_head	poll_list;
> -	struct sk_buff		*completion_queue;
> +	struct sk_buff_head	completion_queue;
> =20
>  #ifdef CONFIG_RPS
>  	struct softnet_data	*rps_ipi_list;
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 4d43f1a..5bbfa0f 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1578,8 +1578,7 @@ void dev_kfree_skb_irq(struct sk_buff *skb)
> =20
>  		local_irq_save(flags);
>  		sd =3D &__get_cpu_var(softnet_data);
> -		skb->next =3D sd->completion_queue;
> -		sd->completion_queue =3D skb;
> +		__skb_queue_tail(&sd->completion_queue, skb);
>  		raise_softirq_irqoff(NET_TX_SOFTIRQ);
>  		local_irq_restore(flags);
>  	}
> @@ -2506,18 +2505,16 @@ static void net_tx_action(struct softirq_acti=
on *h)
>  {
>  	struct softnet_data *sd =3D &__get_cpu_var(softnet_data);
> =20
> -	if (sd->completion_queue) {
> -		struct sk_buff *clist;
> +	if (!skb_queue_empty(&sd->completion_queue)) {
> +		struct sk_buff_head queue;
> +		struct sk_buff *skb;
> =20
> +		__skb_queue_head_init(&queue);
>  		local_irq_disable();
> -		clist =3D sd->completion_queue;
> -		sd->completion_queue =3D NULL;
> +		skb_queue_splice_tail_init(&sd->completion_queue, &queue);
>  		local_irq_enable();
> =20
> -		while (clist) {
> -			struct sk_buff *skb =3D clist;
> -			clist =3D clist->next;
> -
> +		while ((skb =3D __skb_dequeue(&queue))) {
>  			WARN_ON(atomic_read(&skb->users));
>  			__kfree_skb(skb);
>  		}
> @@ -5593,7 +5590,6 @@ static int dev_cpu_callback(struct notifier_blo=
ck *nfb,
>  			    unsigned long action,
>  			    void *ocpu)
>  {
> -	struct sk_buff **list_skb;
>  	struct Qdisc **list_net;
>  	struct sk_buff *skb;
>  	unsigned int cpu, oldcpu =3D (unsigned long)ocpu;
> @@ -5607,13 +5603,9 @@ static int dev_cpu_callback(struct notifier_bl=
ock *nfb,
>  	sd =3D &per_cpu(softnet_data, cpu);
>  	oldsd =3D &per_cpu(softnet_data, oldcpu);
> =20
> -	/* Find end of our completion_queue. */
> -	list_skb =3D &sd->completion_queue;
> -	while (*list_skb)
> -		list_skb =3D &(*list_skb)->next;
>  	/* Append completion queue from offline CPU. */
> -	*list_skb =3D oldsd->completion_queue;
> -	oldsd->completion_queue =3D NULL;
> +	skb_queue_splice_tail_init(&oldsd->completion_queue,
> +				   &sd->completion_queue);
> =20
>  	/* Find end of our output_queue. */
>  	list_net =3D &sd->output_queue;
> @@ -5849,7 +5841,7 @@ static int __init net_dev_init(void)
>  		struct softnet_data *sd =3D &per_cpu(softnet_data, i);
> =20
>  		skb_queue_head_init(&sd->input_pkt_queue);
> -		sd->completion_queue =3D NULL;
> +		__skb_queue_head_init(&sd->completion_queue);
>  		INIT_LIST_HEAD(&sd->poll_list);
> =20
>  #ifdef CONFIG_RPS
> diff --git a/net/core/netpoll.c b/net/core/netpoll.c
> index a58f59b..3905a14 100644
> --- a/net/core/netpoll.c
> +++ b/net/core/netpoll.c
> @@ -222,17 +222,15 @@ static void zap_completion_queue(void)
>  	unsigned long flags;
>  	struct softnet_data *sd =3D &get_cpu_var(softnet_data);
> =20
> -	if (sd->completion_queue) {
> -		struct sk_buff *clist;
> +	if (!skb_queue_empty(&sd->completion_queue)) {
> +		struct sk_buff_head queue;
> +		struct sk_buff *skb;
> =20
>  		local_irq_save(flags);
> -		clist =3D sd->completion_queue;
> -		sd->completion_queue =3D NULL;
> +		skb_queue_splice_tail_init(&sd->completion_queue, &queue);
>  		local_irq_restore(flags);
> =20
> -		while (clist !=3D NULL) {
> -			struct sk_buff *skb =3D clist;
> -			clist =3D clist->next;
> +		while ((skb =3D __skb_dequeue(&queue))) {
>  			if (skb->destructor) {
>  				atomic_inc(&skb->users);
>  				dev_kfree_skb_any(skb); /* put this one back */
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20


