From: Helmut Schaa <helmut.schaa@googlemail.com>
Subject: Re: [PATCH 1/2 v3] xps: Improvements in TX queue selection
Date: Tue, 26 Oct 2010 08:18:47 +0200
Message-ID: <201010260818.47523.helmut.schaa@googlemail.com>
References: <alpine.DEB.1.00.1010211303390.30535@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:57693 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752843Ab0JZGTd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 02:19:33 -0400
Received: by bwz11 with SMTP id 11so3101740bwz.19
        for <netdev@vger.kernel.org>; Mon, 25 Oct 2010 23:19:32 -0700 (PDT)
In-Reply-To: <alpine.DEB.1.00.1010211303390.30535@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Am Donnerstag 21 Oktober 2010 schrieb Tom Herbert:
> In dev_pick_tx, don't do work in calculating queue index or setting
> the index in the sock unless the device has more than one queue.  This
> allows the sock to be set only with a queue index of a multi-queue
> device which is desirable if device are stacked like in a tunnel.
> 
> We also allow the mapping of a socket to queue to be changed.  To
> maintain in order packet transmission a flag (ooo_okay) has been
> added to the sk_buff structure.  If a transport layer sets this flag
> on a packet, the transmit queue can be changed for the socket.
> Presumably, the transport would set this if there was no possbility
> of creating OOO packets (for instance, there are no packets in flight
> for the socket).  This patch includes the modification in TCP output
> for setting this flag.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---

[...]

> diff --git a/net/core/dev.c b/net/core/dev.c
> index b2269ac..a538ed5 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2123,28 +2123,32 @@ static struct netdev_queue *dev_pick_tx(struct net_device *dev,
>  					struct sk_buff *skb)
>  {
>  	int queue_index;
> -	const struct net_device_ops *ops = dev->netdev_ops;
>  
> -	if (ops->ndo_select_queue) {
> -		queue_index = ops->ndo_select_queue(dev, skb);
> -		queue_index = dev_cap_txqueue(dev, queue_index);
> -	} else {
> +	if (dev->real_num_tx_queues > 1) {
>  		struct sock *sk = skb->sk;
> +
>  		queue_index = sk_tx_queue_get(sk);
> -		if (queue_index < 0) {
>  
> -			queue_index = 0;
> -			if (dev->real_num_tx_queues > 1)
> +		if (queue_index < 0 || skb->ooo_okay ||
> +		    queue_index >= dev->real_num_tx_queues) {
> +			const struct net_device_ops *ops = dev->netdev_ops;
> +			int old_index = queue_index;
> +
> +			if (ops->ndo_select_queue) {
> +				queue_index = ops->ndo_select_queue(dev, skb);
> +				queue_index = dev_cap_txqueue(dev, queue_index);
> +			} else
>  				queue_index = skb_tx_hash(dev, skb);

Wouldn't that break mac80211 QoS again for bridged AP mode interfaces (see
commit deabc772f39405054a438d711f408d2d94d26d96, "net: fix tx queue selection
for bridged devices implementing select_queue")?

Helmut
