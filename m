From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH] net/udp: do not touch skb->peeked unless really needed
Date: Tue, 06 Dec 2016 10:53:09 +0100
Message-ID: <1481017989.6225.21.camel@redhat.com>
References: <1480905784.18162.509.camel@edumazet-glaptop3.roam.corp.google.com>
         <1480944138.4694.37.camel@redhat.com>
         <1480948133.18162.527.camel@edumazet-glaptop3.roam.corp.google.com>
         <1480960639.18162.556.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40820 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751139AbcLFJzH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Dec 2016 04:55:07 -0500
In-Reply-To: <1480960639.18162.556.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Mon, 2016-12-05 at 09:57 -0800, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> In UDP recvmsg() path we currently access 3 cache lines from an skb
> while holding receive queue lock, plus another one if packet is
> dequeued, since we need to change skb->next->prev
> 
> 1st cache line (contains ->next/prev pointers, offsets 0x00 and 0x08)
> 2nd cache line (skb->len & skb->peeked, offsets 0x80 and 0x8e)
> 3rd cache line (skb->truesize/users, offsets 0xe0 and 0xe4)
> 
> skb->peeked is only needed to make sure 0-length packets are properly
> handled while MSG_PEEK is operated.
> 
> I had first the intent to remove skb->peeked but the "MSG_PEEK at
> non-zero offset" support added by Sam Kumar makes this not possible.

I'm wondering if peeking with offset is going to complicate the 2 queues
patch, too.

> This patch avoids one cache line miss during the locked section, when
> skb->len and skb->peeked do not have to be read.
> 
> It also avoids the skb_set_peeked() cost for non empty UDP datagrams.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  net/core/datagram.c |   19 ++++++++++---------
>  1 file changed, 10 insertions(+), 9 deletions(-)
> 
> diff --git a/net/core/datagram.c b/net/core/datagram.c
> index 49816af8586bb832e806972b486588041a99524c..9482037a5c8c64aec79e42c65bd2691bdd9450a3 100644
> --- a/net/core/datagram.c
> +++ b/net/core/datagram.c
> @@ -214,6 +214,7 @@ struct sk_buff *__skb_try_recv_datagram(struct sock *sk, unsigned int flags,
>  	if (error)
>  		goto no_packet;
>  
> +	*peeked = 0;
>  	do {
>  		/* Again only user level code calls this function, so nothing
>  		 * interrupt level will suddenly eat the receive_queue.
> @@ -227,22 +228,22 @@ struct sk_buff *__skb_try_recv_datagram(struct sock *sk, unsigned int flags,
>  		spin_lock_irqsave(&queue->lock, cpu_flags);
>  		skb_queue_walk(queue, skb) {
>  			*last = skb;
> -			*peeked = skb->peeked;
>  			if (flags & MSG_PEEK) {
>  				if (_off >= skb->len && (skb->len || _off ||
>  							 skb->peeked)) {
>  					_off -= skb->len;
>  					continue;
>  				}
> -
> -				skb = skb_set_peeked(skb);
> -				error = PTR_ERR(skb);
> -				if (IS_ERR(skb)) {
> -					spin_unlock_irqrestore(&queue->lock,
> -							       cpu_flags);
> -					goto no_packet;
> +				if (!skb->len) {
> +					skb = skb_set_peeked(skb);
> +					if (IS_ERR(skb)) {
> +						error = PTR_ERR(skb);
> +						spin_unlock_irqrestore(&queue->lock,
> +								       cpu_flags);
> +						goto no_packet;
> +					}
>  				}

I don't understand why we can avoid setting skb->peek if len > 0. I
think that will change the kernel behavior if:
- peek with offset is set
- 3 skbs with len > 0 are enqueued
- the u/s peek (with offset) the second one
- the u/s disable peeking with offset and peeks 2 more skbs.

With the current code in the last step the u/s is going to peek the 1#
and the 3# skbs, after this patch will peek the 1# and the 2#. Am I
missing something ? Probably the new behavior is more correct, but still
is a change. 

I gave this a run in my test bed on top of your udp-related patches I
see additional ~3 improvement in the udp flood scenario, and a bit more
in the un-contended scenario.

Thank you,

Paolo
