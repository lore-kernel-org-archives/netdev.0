From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net-next v2] net: fix __skb_try_recv_from_queue to
 return the old behavior
Date: Thu, 18 May 2017 11:53:56 +0200
Message-ID: <1495101236.2479.8.camel@redhat.com>
References: <1495011889.2644.5.camel@redhat.com>
         <20170517183905.10971-1-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: Andrei Vagin <avagin@openvz.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59804 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751782AbdERJx7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 May 2017 05:53:59 -0400
In-Reply-To: <20170517183905.10971-1-avagin@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-05-17 at 11:39 -0700, Andrei Vagin wrote:
> This function has to return NULL on a error case, because there is a
> separate error variable.
> 
> The offset has to be changed only if skb is returned
> 
> v2: fix udp code to not use an extra variable
> 
> Cc: Paolo Abeni <pabeni@redhat.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: David S. Miller <davem@davemloft.net>
> Fixes: 65101aeca522 ("net/sock: factor out dequeue/peek with offset cod")
> Signed-off-by: Andrei Vagin <avagin@openvz.org>
> ---
>  net/core/datagram.c | 14 ++++++++------
>  net/ipv4/udp.c      | 12 +++---------
>  2 files changed, 11 insertions(+), 15 deletions(-)
> 
> diff --git a/net/core/datagram.c b/net/core/datagram.c
> index a4592b4..bc46118 100644
> --- a/net/core/datagram.c
> +++ b/net/core/datagram.c
> @@ -170,20 +170,21 @@ struct sk_buff *__skb_try_recv_from_queue(struct sock *sk,
>  					  struct sk_buff **last)
>  {
>  	struct sk_buff *skb;
> +	int _off = *off;
>  
>  	*last = queue->prev;
>  	skb_queue_walk(queue, skb) {
>  		if (flags & MSG_PEEK) {
> -			if (*off >= skb->len && (skb->len || *off ||
> +			if (_off >= skb->len && (skb->len || _off ||
>  						 skb->peeked)) {
> -				*off -= skb->len;
> +				_off -= skb->len;
>  				continue;
>  			}
>  			if (!skb->len) {
>  				skb = skb_set_peeked(skb);
>  				if (unlikely(IS_ERR(skb))) {
>  					*err = PTR_ERR(skb);
> -					return skb;
> +					return NULL;
>  				}
>  			}
>  			*peeked = 1;
> @@ -193,6 +194,7 @@ struct sk_buff *__skb_try_recv_from_queue(struct sock *sk,
>  			if (destructor)
>  				destructor(sk, skb);
>  		}
> +		*off = _off;
>  		return skb;
>  	}
>  	return NULL;
> @@ -253,8 +255,6 @@ struct sk_buff *__skb_try_recv_datagram(struct sock *sk, unsigned int flags,
>  
>  	*peeked = 0;
>  	do {
> -		int _off = *off;
> -
>  		/* Again only user level code calls this function, so nothing
>  		 * interrupt level will suddenly eat the receive_queue.
>  		 *
> @@ -263,8 +263,10 @@ struct sk_buff *__skb_try_recv_datagram(struct sock *sk, unsigned int flags,
>  		 */
>  		spin_lock_irqsave(&queue->lock, cpu_flags);
>  		skb = __skb_try_recv_from_queue(sk, queue, flags, destructor,
> -						peeked, &_off, err, last);
> +						peeked, off, &error, last);
>  		spin_unlock_irqrestore(&queue->lock, cpu_flags);
> +		if (error)
> +			goto no_packet;
>  		if (skb)
>  			return skb;
>  
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index 7bd56c9..278e707 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -1465,16 +1465,13 @@ struct sk_buff *__skb_recv_udp(struct sock *sk, unsigned int flags,
>  		error = -EAGAIN;
>  		*peeked = 0;
>  		do {
> -			int _off = *off;
> -
>  			spin_lock_bh(&queue->lock);
>  			skb = __skb_try_recv_from_queue(sk, queue, flags,
>  							udp_skb_destructor,
> -							peeked, &_off, err,
> +							peeked, off, err,
>  							&last);
>  			if (skb) {
>  				spin_unlock_bh(&queue->lock);
> -				*off = _off;
>  				return skb;
>  			}
>  
> @@ -1488,20 +1485,17 @@ struct sk_buff *__skb_recv_udp(struct sock *sk, unsigned int flags,
>  			 * the sk_receive_queue lock if fwd memory scheduling
>  			 * is needed.
>  			 */
> -			_off = *off;
>  			spin_lock(&sk_queue->lock);
>  			skb_queue_splice_tail_init(sk_queue, queue);
>  
>  			skb = __skb_try_recv_from_queue(sk, queue, flags,
>  							udp_skb_dtor_locked,
> -							peeked, &_off, err,
> +							peeked, off, err,
>  							&last);
>  			spin_unlock(&sk_queue->lock);
>  			spin_unlock_bh(&queue->lock);
> -			if (skb) {
> -				*off = _off;
> +			if (skb)
>  				return skb;
> -			}
>  
>  busy_check:
>  			if (!sk_can_busy_loop(sk))

LGTM, thanks!

Acked-by: Paolo Abeni <pabeni@redhat.com>
