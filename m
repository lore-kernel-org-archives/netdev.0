From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Fix locking in flush_backlog
Date: Tue, 23 Mar 2010 07:29:17 +0100
Message-ID: <1269325757.3043.11.camel@edumazet-laptop>
References: <alpine.DEB.1.00.1003222257470.3718@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f182.google.com ([209.85.221.182]:52400 "EHLO
	mail-qy0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752116Ab0CWG3X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Mar 2010 02:29:23 -0400
Received: by qyk12 with SMTP id 12so3334076qyk.5
        for <netdev@vger.kernel.org>; Mon, 22 Mar 2010 23:29:23 -0700 (PDT)
In-Reply-To: <alpine.DEB.1.00.1003222257470.3718@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 22 mars 2010 =C3=A0 23:04 -0700, Tom Herbert a =C3=A9crit :
> Need to take spinlocks when dequeuing from input_pkt_queue in=20
> flush_backlog.  Also, with the spinlock the backlog queues can
> be flushed directly from netdev_run_todo.
>=20
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
> diff --git a/net/core/dev.c b/net/core/dev.c
> index a03aab4..e7db656 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2765,20 +2765,6 @@ int netif_receive_skb(struct sk_buff *skb)
>  }
>  EXPORT_SYMBOL(netif_receive_skb);
> =20
> -/* Network device is going away, flush any packets still pending  */
> -static void flush_backlog(void *arg)
> -{
> -	struct net_device *dev =3D arg;
> -	struct softnet_data *queue =3D &__get_cpu_var(softnet_data);
> -	struct sk_buff *skb, *tmp;
> -
> -	skb_queue_walk_safe(&queue->input_pkt_queue, skb, tmp)
> -		if (skb->dev =3D=3D dev) {
> -			__skb_unlink(skb, &queue->input_pkt_queue);
> -			kfree_skb(skb);
> -		}
> -}
> -
>  static int napi_gro_complete(struct sk_buff *skb)
>  {
>  	struct packet_type *ptype;
> @@ -5545,6 +5531,7 @@ void netdev_run_todo(void)
>  	while (!list_empty(&list)) {
>  		struct net_device *dev
>  			=3D list_first_entry(&list, struct net_device, todo_list);
> +		int i;
>  		list_del(&dev->todo_list);
> =20
>  		if (unlikely(dev->reg_state !=3D NETREG_UNREGISTERING)) {
> @@ -5556,7 +5543,22 @@ void netdev_run_todo(void)
> =20
>  		dev->reg_state =3D NETREG_UNREGISTERED;
> =20
> -		on_each_cpu(flush_backlog, dev, 1);
> +		/* Flush backlog queues of any pending packets */
> +		for_each_online_cpu(i) {
> +			struct softnet_data *queue =3D &per_cpu(softnet_data, i);
> +			struct sk_buff *skb, *tmp;
> +			unsigned long flags;
> +
> +			spin_lock_irqsave(&queue->input_pkt_queue.lock, flags);
> +			skb_queue_walk_safe(&queue->input_pkt_queue, skb, tmp)
> +				if (skb->dev =3D=3D dev) {
> +					__skb_unlink(skb,
> +					    &queue->input_pkt_queue);
> +					kfree_skb(skb);
> +				}
> +			spin_unlock_irqrestore(&queue->input_pkt_queue.lock,
> +			    flags);
> +		}
> =20
>  		netdev_wait_allrefs(dev);
> =20

OK (this is a patch for net-next-2.6)

Could you please keep the function, to ease netdev_run_todo() review ?

Thanks


