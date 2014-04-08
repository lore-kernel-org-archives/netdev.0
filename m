From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 2/2] macvlan: Move broadcasts into a work queue
Date: Tue, 8 Apr 2014 09:55:23 -0700
Message-ID: <20140408095523.2d4e14bd@nehalam.linuxnetplumber.net>
References: <<20140407075347.GA26461@gondor.apana.org.au>
	<E1WX4P2-0006wA-9Q@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:56463 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750868AbaDHQz1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2014 12:55:27 -0400
Received: by mail-pb0-f45.google.com with SMTP id uo5so1295187pbc.4
        for <netdev@vger.kernel.org>; Tue, 08 Apr 2014 09:55:26 -0700 (PDT)
In-Reply-To: <E1WX4P2-0006wA-9Q@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 07 Apr 2014 15:55:36 +0800
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> +static void macvlan_broadcast_enqueue(struct macvlan_port *port,
> +				      struct sk_buff *skb)
> +{
> +	int err = -ENOMEM;
> +
> +	skb = skb_clone(skb, GFP_ATOMIC);
> +	if (unlikely(!skb))
> +		goto err;
> +
> +	spin_lock(&port->bc_queue.lock);
> +	if (skb_queue_len(&port->bc_queue) < skb->dev->tx_queue_len) {
> +		__skb_queue_tail(&port->bc_queue, skb);
> +		err = 0;
> +	}
> +	spin_unlock(&port->bc_queue.lock);
> +
> +	if (unlikely(err)) {
> +err:
> +		atomic_long_inc(&skb->dev->rx_dropped);
> +		return;
> +	}
> +

unlikely() with goto is redundant and unnecessary.

IMHO jumping into a block is bad code style

Why not just move err: to the end as in:


	skb = skb_clone(skb, GFP_ATOMIC);
	if (unlikely(!skb))
		goto err;

	spin_lock(&port->bc_queue.lock);
	if (skb_queue_len(&port->bc_queue) < skb->dev->tx_queue_len) {
		__skb_queue_tail(&port->bc_queue, skb);
		err = 0;
	}
	spin_unlock(&port->bc_queue.lock);

	if (err)
		goto err;

	schedule_work(&port->bc_work);
	return;
err:

	atomic_long_inc(&skb->dev->rx_dropped);
}
