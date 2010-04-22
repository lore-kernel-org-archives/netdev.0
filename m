From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v5] net: batch skb dequeueing from softnet
 input_pkt_queue
Date: Thu, 22 Apr 2010 13:37:07 +0200
Message-ID: <1271936227.7895.5285.camel@edumazet-laptop>
References: <1271927357-2973-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, jamal <hadi@cyberus.ca>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:57274 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753774Ab0DVLhT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 07:37:19 -0400
Received: by bwz25 with SMTP id 25so9492484bwz.28
        for <netdev@vger.kernel.org>; Thu, 22 Apr 2010 04:37:17 -0700 (PDT)
In-Reply-To: <1271927357-2973-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 22 avril 2010 =C3=A0 17:09 +0800, Changli Gao a =C3=A9crit :
> batch skb dequeueing from softnet input_pkt_queue
>=20
> batch skb dequeueing from softnet input_pkt_queue to reduce potential=
 lock
> contention when RPS is enabled. input_pkt_queue is reimplemented as a=
 single
> linked list (FIFO) to keep enqueueing and dequeueing as fast as posib=
le, and
> input_pkt_queue_lock is moved into RPS section to reduce 4 bytes on 3=
2bits
> machine.
>=20
> Note: input_pkt_queue_len doesn't been decreased until process_backlo=
g()
> returns.
>=20
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ----
>  include/linux/netdevice.h |   12 ++++-
>  net/core/dev.c            |   99 +++++++++++++++++++++++++++++++++--=
-----------
>  2 files changed, 82 insertions(+), 29 deletions(-)
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 3c5ed5f..58abdd5 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1387,6 +1387,7 @@ struct softnet_data {
>  	struct Qdisc		*output_queue;
>  	struct list_head	poll_list;
>  	struct sk_buff		*completion_queue;
> +	struct sk_buff		*process_queue;
> =20
>  #ifdef CONFIG_RPS
>  	struct softnet_data	*rps_ipi_list;
> @@ -1396,15 +1397,20 @@ struct softnet_data {
>  	struct softnet_data	*rps_ipi_next;
>  	unsigned int		cpu;
>  	unsigned int		input_queue_head;
> +	spinlock_t		input_pkt_queue_lock;
>  #endif
> -	struct sk_buff_head	input_pkt_queue;
> +	unsigned int		input_pkt_queue_len;
> +	struct sk_buff		*input_pkt_queue_head;
> +	struct sk_buff		**input_pkt_queue_tailp;
> +
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
> index e904c47..f37c223 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -211,14 +211,14 @@ static inline struct hlist_head *dev_index_hash=
(struct net *net, int ifindex)
>  static inline void rps_lock(struct softnet_data *sd)
>  {
>  #ifdef CONFIG_RPS
> -	spin_lock(&sd->input_pkt_queue.lock);
> +	spin_lock(&sd->input_pkt_queue_lock);
>  #endif
>  }
> =20
>  static inline void rps_unlock(struct softnet_data *sd)
>  {
>  #ifdef CONFIG_RPS
> -	spin_unlock(&sd->input_pkt_queue.lock);
> +	spin_unlock(&sd->input_pkt_queue_lock);
>  #endif
>  }
> =20
> @@ -2409,12 +2409,15 @@ static int enqueue_to_backlog(struct sk_buff =
*skb, int cpu,
>  	__get_cpu_var(netdev_rx_stat).total++;
> =20
>  	rps_lock(sd);
> -	if (sd->input_pkt_queue.qlen <=3D netdev_max_backlog) {
> -		if (sd->input_pkt_queue.qlen) {
> +	if (sd->input_pkt_queue_len <=3D netdev_max_backlog) {
> +		if (sd->input_pkt_queue_len) {
>  enqueue:
> -			__skb_queue_tail(&sd->input_pkt_queue, skb);
> +			skb->next =3D NULL;
> +			*sd->input_pkt_queue_tailp =3D skb;
> +			sd->input_pkt_queue_tailp =3D &skb->next;
> +			sd->input_pkt_queue_len++;
>  #ifdef CONFIG_RPS
> -			*qtail =3D sd->input_queue_head + sd->input_pkt_queue.qlen;
> +			*qtail =3D sd->input_queue_head + sd->input_pkt_queue_len;
>  #endif
>  			rps_unlock(sd);
>  			local_irq_restore(flags);
> @@ -2927,19 +2930,37 @@ EXPORT_SYMBOL(netif_receive_skb);
>  /* Network device is going away, flush any packets still pending
>   * Called with irqs disabled.
>   */
> -static void flush_backlog(void *arg)
> +
> +static struct sk_buff **__flush_backlog(struct softnet_data *sd,
> +					struct sk_buff **pskb,
> +					struct net_device *dev)
>  {
> -	struct net_device *dev =3D arg;
> -	struct softnet_data *sd =3D &__get_cpu_var(softnet_data);
> -	struct sk_buff *skb, *tmp;
> +	struct sk_buff *skb;
> =20
> -	rps_lock(sd);
> -	skb_queue_walk_safe(&sd->input_pkt_queue, skb, tmp)
> +	while (*pskb) {
> +		skb =3D *pskb;
>  		if (skb->dev =3D=3D dev) {
> -			__skb_unlink(skb, &sd->input_pkt_queue);
> +			*pskb =3D skb->next;
>  			kfree_skb(skb);
> -			input_queue_head_incr(sd);
> +			input_queue_head_add(sd, 1);
> +			sd->input_pkt_queue_len--;
> +		} else {
> +			pskb =3D &skb->next;
>  		}
> +	}
> +
> +	return pskb;
> +}
> +
> +static void flush_backlog(void *arg)
> +{
> +	struct softnet_data *sd =3D &__get_cpu_var(softnet_data);
> +	struct sk_buff **tailp;
> +
> +	rps_lock(sd);
> +	tailp =3D __flush_backlog(sd, &sd->input_pkt_queue_head, arg);
> +	sd->input_pkt_queue_tailp =3D tailp;
> +	__flush_backlog(sd, &sd->process_queue, arg);
>  	rps_unlock(sd);
>  }
> =20
> @@ -3249,24 +3270,39 @@ static int process_backlog(struct napi_struct=
 *napi, int quota)
>  	struct softnet_data *sd =3D &__get_cpu_var(softnet_data);
> =20
>  	napi->weight =3D weight_p;
> +	local_irq_disable();
>  	do {
>  		struct sk_buff *skb;
> =20
> -		local_irq_disable();
> +		while (sd->process_queue) {
> +			skb =3D sd->process_queue;
> +			sd->process_queue =3D skb->next;
> +			local_irq_enable();
> +			__netif_receive_skb(skb);
> +			if (++work >=3D quota) {
> +				local_irq_disable();
> +				rps_lock(sd);
> +				goto out;
> +			}
> +			local_irq_disable();
> +		}
> +
>  		rps_lock(sd);
> -		skb =3D __skb_dequeue(&sd->input_pkt_queue);
> -		if (!skb) {
> +		if (sd->input_pkt_queue_head =3D=3D NULL) {
>  			__napi_complete(napi);
> -			rps_unlock(sd);
> -			local_irq_enable();
>  			break;
>  		}
> -		input_queue_head_incr(sd);
> +		sd->process_queue =3D sd->input_pkt_queue_head;
> +		sd->input_pkt_queue_head =3D NULL;
> +		sd->input_pkt_queue_tailp =3D &sd->input_pkt_queue_head;
>  		rps_unlock(sd);
> -		local_irq_enable();
> +	} while (1);
> =20
> -		__netif_receive_skb(skb);
> -	} while (++work < quota);
> +out:
> +	sd->input_pkt_queue_len -=3D work;
> +	input_queue_head_add(sd, work);
> +	rps_unlock(sd);
> +	local_irq_enable();
> =20



Please reorder things better.

Most likely this function is called for one packet.

In your version you take twice the rps_lock()/rps_unlock() path, so
it'll be slower.

Once to 'transfert' one list to process list

Once to be able to do the 'label out:' post processing.



