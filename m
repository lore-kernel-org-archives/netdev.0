From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net-next] net: fix __skb_try_recv_from_queue to return
 the old behavior
Date: Wed, 17 May 2017 11:04:49 +0200
Message-ID: <1495011889.2644.5.camel@redhat.com>
References: <20170517044710.28300-1-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: Andrei Vagin <avagin@openvz.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36232 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753677AbdEQJFI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 17 May 2017 05:05:08 -0400
In-Reply-To: <20170517044710.28300-1-avagin@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-05-16 at 21:47 -0700, Andrei Vagin wrote:
> This function has to return NULL on a error case, because there is a
> separate error variable.
> 
> The offset has to be changed only if skb is returned
> 
> Cc: Paolo Abeni <pabeni@redhat.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: David S. Miller <davem@davemloft.net>
> Fixes: 65101aeca522 ("net/sock: factor out dequeue/peek with offset cod")
> Signed-off-by: Andrei Vagin <avagin@openvz.org>
> ---
>  net/core/datagram.c | 14 ++++++++------
>  1 file changed, 8 insertions(+), 6 deletions(-)
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
>  	
> 	}
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

Thank you for catching this so early! 

If __skb_try_recv_from_queue() updates the offset if/only if the skb is
returned, than we can also add something like the following ?
(only compile tested, should not bring any functional changes, only
code cleanup)

BTW can you please share some entry pointer/walk-through for the CRIU
tests ? I'd like to try to integrate them in my workflow, thank you!

Paolo
---
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 8ad5862..e65c7ed 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1555,16 +1555,13 @@ struct sk_buff *__skb_recv_udp(struct sock *sk, unsigned int flags,
                error = -EAGAIN;
                *peeked = 0;
                do {
-                       int _off = *off;
-
                        spin_lock_bh(&queue->lock);
                        skb = __skb_try_recv_from_queue(sk, queue, flags,
                                                        udp_skb_destructor,
-                                                       peeked, &_off, err,
+                                                       peeked, off, err,
                                                        &last);
                        if (skb) {
                                spin_unlock_bh(&queue->lock);
-                               *off = _off;
                                return skb;
                        }
 
@@ -1578,20 +1575,17 @@ struct sk_buff *__skb_recv_udp(struct sock *sk, unsigned int flags,
                         * the sk_receive_queue lock if fwd memory scheduling
                         * is needed.
                         */
-                       _off = *off;
                        spin_lock(&sk_queue->lock);
                        skb_queue_splice_tail_init(sk_queue, queue);
 
                        skb = __skb_try_recv_from_queue(sk, queue, flags,
                                                        udp_skb_dtor_locked,
-                                                       peeked, &_off, err,
+                                                       peeked, off, err,
                                                        &last);
                        spin_unlock(&sk_queue->lock);
                        spin_unlock_bh(&queue->lock);
-                       if (skb) {
-                               *off = _off;
+                       if (skb)
                                return skb;
-                       }
