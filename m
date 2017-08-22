From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH v2 net] udp: on peeking bad csum, drop packets even if
 not at head
Date: Tue, 22 Aug 2017 18:47:42 +0200
Message-ID: <1503420462.13544.9.camel@redhat.com>
References: <20170821213912.93333-1-willemdebruijn.kernel@gmail.com>
         <1503355232.2499.15.camel@edumazet-glaptop3.roam.corp.google.com>
         <1503419968.2499.33.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>,
        netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37030 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751157AbdHVQro (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 22 Aug 2017 12:47:44 -0400
In-Reply-To: <1503419968.2499.33.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-08-22 at 09:39 -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> When peeking, if a bad csum is discovered, the skb is unlinked from
> the queue with __sk_queue_drop_skb and the peek operation restarted.
> 
> __sk_queue_drop_skb only drops packets that match the queue head.
> 
> This fails if the skb was found after the head, using SO_PEEK_OFF
> socket option. This causes an infinite loop.
> 
> We MUST drop this problematic skb, and we can simply check if skb was
> already removed by another thread, by looking at skb->next :
> 
> This pointer is set to NULL by the  __skb_unlink() operation, that might
> have happened only under the spinlock protection.
> 
> Many thanks to syzkaller team (and particularly Dmitry Vyukov who
> provided us nice C reproducers exhibiting the lockup) and Willem de
> Bruijn who provided first version for this patch and a test program.
> 
> Fixes: 627d2d6b5500 ("udp: enable MSG_PEEK at non-zero offset")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: Willem de Bruijn <willemb@google.com>
> ---
>  net/core/datagram.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/core/datagram.c b/net/core/datagram.c
> index a21ca8dee5ea..8c2f4489ff8f 100644
> --- a/net/core/datagram.c
> +++ b/net/core/datagram.c
> @@ -362,7 +362,7 @@ int __sk_queue_drop_skb(struct sock *sk, struct sk_buff_head *sk_queue,
>  	if (flags & MSG_PEEK) {
>  		err = -ENOENT;
>  		spin_lock_bh(&sk_queue->lock);
> -		if (skb == skb_peek(sk_queue)) {
> +		if (skb->next) {
>  			__skb_unlink(skb, sk_queue);
>  			refcount_dec(&skb->users);
>  			if (destructor)
> 

This version is really nice!

Acked-by: Paolo Abeni <pabeni@redhat.com>
