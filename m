From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: NULL pointer dereference panic in stable (2.6.33.2), amd64
Date: Mon, 12 Apr 2010 09:08:34 +0530
Message-ID: <OF19A2A36F.5B268C61-ON65257703.0012EB6A-65257703.0013F81C@in.ibm.com>
References: <201004112338.47019.nuclearcat@nuclearcat.com> <1271025353.2078.155.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Denys Fedorysychenko <nuclearcat@nuclearcat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp06.in.ibm.com ([122.248.162.6]:39486 "EHLO
	e28smtp06.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751508Ab0DLDiL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Apr 2010 23:38:11 -0400
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp06.in.ibm.com (8.14.3/8.13.1) with ESMTP id o3C3c8fB007938
	for <netdev@vger.kernel.org>; Mon, 12 Apr 2010 09:08:08 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o3C3c8P0512106
	for <netdev@vger.kernel.org>; Mon, 12 Apr 2010 09:08:08 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o3C3c86s016533
	for <netdev@vger.kernel.org>; Mon, 12 Apr 2010 09:08:08 +0530
In-Reply-To: <1271025353.2078.155.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

Eric Dumazet <eric.dumazet@gmail.com> wrote on 04/12/2010 04:05:53 AM:

> I believe the following lines from dev_pick_tx() are not the problem :
>
>    if (sk && sk->sk_dst_cache)
>       sk_tx_queue_set(sk, queue_index);
>
> It is IMHO not safe, because route for this socket might have just
> changed and we are transmitting an old packet (queued some milli seconds
> before, when route was different).
>
> We then memorize a queue_index that might be too big for the new device
> of new selected route.
>
> Next packet we want to transmit will take the cached value of
> queue_index, correct for old device, maybe not correct for new device.

When route changes, I think my patch had reset sk->sk_tx_queue_mapping
by calling sk_tx_queue_clear. I don't know if I missed any path where
the route changes and sk_dst_reset() was not called.

The following might be better to prove the panic is due to this, since
your suggestion will hide a panic that happens somewhat rare (according
to Denys):

      if (sk_tx_queue_recorded(sk)) {
            queue_index = sk_tx_queue_get(sk);
+           queue_index = dev_cap_txqueue(dev, queue_index);
      } else {

Thanks,

- KK

> You could try to revert commit a4ee3ce3293dc931fab19beb472a8bde1295aebe
>
> commit a4ee3ce3293dc931fab19beb472a8bde1295aebe
> Author: Krishna Kumar <krkumar2@in.ibm.com>
> Date:   Mon Oct 19 23:50:07 2009 +0000
>
>     net: Use sk_tx_queue_mapping for connected sockets
>
>     For connected sockets, the first run of dev_pick_tx saves the
>     calculated txq in sk_tx_queue_mapping. This is not saved if
>     either the device has a queue select or the socket is not
>     connected. Next iterations of dev_pick_tx uses the cached value
>     of sk_tx_queue_mapping.
>
>     Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 28b0b9e..fa88dcd 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1791,13 +1791,25 @@ EXPORT_SYMBOL(skb_tx_hash);
>  static struct netdev_queue *dev_pick_tx(struct net_device *dev,
>                 struct sk_buff *skb)
>  {
> -   const struct net_device_ops *ops = dev->netdev_ops;
> -   u16 queue_index = 0;
> +   u16 queue_index;
> +   struct sock *sk = skb->sk;
> +
> +   if (sk_tx_queue_recorded(sk)) {
> +      queue_index = sk_tx_queue_get(sk);
> +   } else {
> +      const struct net_device_ops *ops = dev->netdev_ops;
>
> -   if (ops->ndo_select_queue)
> -      queue_index = ops->ndo_select_queue(dev, skb);
> -   else if (dev->real_num_tx_queues > 1)
> -      queue_index = skb_tx_hash(dev, skb);
> +      if (ops->ndo_select_queue) {
> +         queue_index = ops->ndo_select_queue(dev, skb);
> +      } else {
> +         queue_index = 0;
> +         if (dev->real_num_tx_queues > 1)
> +            queue_index = skb_tx_hash(dev, skb);
> +
> +         if (sk && sk->sk_dst_cache)
> +            sk_tx_queue_set(sk, queue_index);
> +      }
> +   }
>
>     skb_set_queue_mapping(skb, queue_index);
>     return netdev_get_tx_queue(dev, queue_index);
>
>

