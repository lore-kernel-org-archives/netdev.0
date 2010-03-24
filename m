From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] Fix locking in flush_backlog
Date: Wed, 24 Mar 2010 06:34:42 +0100
Message-ID: <1269408882.2915.42.camel@edumazet-laptop>
References: <alpine.DEB.1.00.1003231635190.360@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:44619 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752059Ab0CXFes (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 01:34:48 -0400
Received: by bwz1 with SMTP id 1so2546865bwz.21
        for <netdev@vger.kernel.org>; Tue, 23 Mar 2010 22:34:47 -0700 (PDT)
In-Reply-To: <alpine.DEB.1.00.1003231635190.360@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 23 mars 2010 =C3=A0 16:39 -0700, Tom Herbert a =C3=A9crit :
> Need to take spinlocks when dequeuing from input_pkt_queue in flush_b=
acklog.
> Also, flush_backlog can now be called directly from netdev_run_todo.
>=20
> Signed-off-by: Tom Herbert <therbert@google.com>

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks Tom

> ---
> diff --git a/net/core/dev.c b/net/core/dev.c
> diff --git a/net/core/dev.c b/net/core/dev.c
> index a03aab4..5e3dc28 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2766,17 +2766,19 @@ int netif_receive_skb(struct sk_buff *skb)
>  EXPORT_SYMBOL(netif_receive_skb);
> =20
>  /* Network device is going away, flush any packets still pending  */
> -static void flush_backlog(void *arg)
> +static void flush_backlog(struct net_device *dev, int cpu)
>  {
> -	struct net_device *dev =3D arg;
> -	struct softnet_data *queue =3D &__get_cpu_var(softnet_data);
> +	struct softnet_data *queue =3D &per_cpu(softnet_data, cpu);
>  	struct sk_buff *skb, *tmp;
> +	unsigned long flags;
> =20
> +	spin_lock_irqsave(&queue->input_pkt_queue.lock, flags);
>  	skb_queue_walk_safe(&queue->input_pkt_queue, skb, tmp)
>  		if (skb->dev =3D=3D dev) {
>  			__skb_unlink(skb, &queue->input_pkt_queue);
>  			kfree_skb(skb);
>  		}
> +	spin_unlock_irqrestore(&queue->input_pkt_queue.lock, flags);
>  }
> =20
>  static int napi_gro_complete(struct sk_buff *skb)
> @@ -5545,6 +5547,7 @@ void netdev_run_todo(void)
>  	while (!list_empty(&list)) {
>  		struct net_device *dev
>  			=3D list_first_entry(&list, struct net_device, todo_list);
> +		int i;
>  		list_del(&dev->todo_list);
> =20
>  		if (unlikely(dev->reg_state !=3D NETREG_UNREGISTERING)) {
> @@ -5556,7 +5559,8 @@ void netdev_run_todo(void)
> =20
>  		dev->reg_state =3D NETREG_UNREGISTERED;
> =20
> -		on_each_cpu(flush_backlog, dev, 1);
> +		for_each_online_cpu(i)
> +			flush_backlog(dev, i);
> =20
>  		netdev_wait_allrefs(dev);
> =20

