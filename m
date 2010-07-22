From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: macvtap: Limit packet queue length
Date: Thu, 22 Jul 2010 08:59:58 -0700
Message-ID: <1279814398.3211.1.camel@localhost.localdomain>
References: <20100722064157.GA25913@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>, Mark Wagner <mwagner@redhat.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:60072 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750743Ab0GVQAE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jul 2010 12:00:04 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e9.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o6MFhb3L024403
	for <netdev@vger.kernel.org>; Thu, 22 Jul 2010 11:43:37 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o6MG03hk259754
	for <netdev@vger.kernel.org>; Thu, 22 Jul 2010 12:00:03 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o6MG01sU022750
	for <netdev@vger.kernel.org>; Thu, 22 Jul 2010 13:00:03 -0300
In-Reply-To: <20100722064157.GA25913@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-07-22 at 14:41 +0800, Herbert Xu wrote:
>  {
>         struct macvtap_queue *q = macvtap_get_queue(dev, skb);
>         if (!q)
> -               return -ENOLINK;
> +               goto drop;
> +
> +       if (skb_queue_len(&q->sk.sk_receive_queue) >=
> dev->tx_queue_len)
> +               goto drop;
> 

Do we need to orphan skb here, just like tun?

>         skb_queue_tail(&q->sk.sk_receive_queue, skb);
>         wake_up_interruptible_poll(sk_sleep(&q->sk), POLLIN |
> POLLRDNORM | POLLRDBAND);
> -       return 0;
> +       return NET_RX_SUCCESS;
> +
> +drop:

Do we need to increase dropped++ counter here to let user know there are
packets dropped?

> +       kfree_skb(skb);
> +       return NET_RX_DROP;
>  }
> 
> 

