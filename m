From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net-next] tcp: add tcp_add_backlog()
Date: Mon, 29 Aug 2016 15:51:37 -0300
Message-ID: <20160829185137.GC11144@localhost.localdomain>
References: <1472308674.14381.226.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50156 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751378AbcH2Sxf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 29 Aug 2016 14:53:35 -0400
Content-Disposition: inline
In-Reply-To: <1472308674.14381.226.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 27, 2016 at 07:37:54AM -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> When TCP operates in lossy environments (between 1 and 10 % packet
> losses), many SACK blocks can be exchanged, and I noticed we could
> drop them on busy senders, if these SACK blocks have to be queued
> into the socket backlog.
> 
> While the main cause is the poor performance of RACK/SACK processing,
> we can try to avoid these drops of valuable information that can lead to
> spurious timeouts and retransmits.
> 
> Cause of the drops is the skb->truesize overestimation caused by :
> 
> - drivers allocating ~2048 (or more) bytes as a fragment to hold an
>   Ethernet frame.
> 
> - various pskb_may_pull() calls bringing the headers into skb->head
>   might have pulled all the frame content, but skb->truesize could
>   not be lowered, as the stack has no idea of each fragment truesize.
> 
> The backlog drops are also more visible on bidirectional flows, since
> their sk_rmem_alloc can be quite big.
> 
> Let's add some room for the backlog, as only the socket owner
> can selectively take action to lower memory needs, like collapsing
> receive queues or partial ofo pruning.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> ---
>  include/net/tcp.h   |    1 +
>  net/ipv4/tcp_ipv4.c |   33 +++++++++++++++++++++++++++++----
>  net/ipv6/tcp_ipv6.c |    5 +----
>  3 files changed, 31 insertions(+), 8 deletions(-)
> 
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 25d64f6de69e1f639ed1531bf2d2df3f00fd76a2..5f5f09f6e019682ef29c864d2f43a8f247fcdd9a 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -1163,6 +1163,7 @@ static inline void tcp_prequeue_init(struct tcp_sock *tp)
>  }
>  
>  bool tcp_prequeue(struct sock *sk, struct sk_buff *skb);
> +bool tcp_add_backlog(struct sock *sk, struct sk_buff *skb);
>  
>  #undef STATE_TRACE
>  
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index ad41e8ecf796bba1bd6d9ed155ca4a57ced96844..53e80cd004b6ce401c3acbb4b243b243c5c3c4a3 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -1532,6 +1532,34 @@ bool tcp_prequeue(struct sock *sk, struct sk_buff *skb)
>  }
>  EXPORT_SYMBOL(tcp_prequeue);
>  
> +bool tcp_add_backlog(struct sock *sk, struct sk_buff *skb)
> +{
> +	u32 limit = sk->sk_rcvbuf + sk->sk_sndbuf;
> +
> +	/* Only socket owner can try to collapse/prune rx queues
> +	 * to reduce memory overhead, so add a little headroom here.
> +	 * Few sockets backlog are possibly concurrently non empty.
> +	 */
> +	limit += 64*1024;
> +
> +	/* In case all data was pulled from skb frags (in __pskb_pull_tail()),
> +	 * we can fix skb->truesize to its real value to avoid future drops.
> +	 * This is valid because skb is not yet charged to the socket.
> +	 * It has been noticed pure SACK packets were sometimes dropped
> +	 * (if cooked by drivers without copybreak feature).
> +	 */
> +	if (!skb->data_len)
> +		skb->truesize = SKB_TRUESIZE(skb_end_offset(skb));

Shouldn't __pskb_pull_tail() already fix this? As it seems the expected
behavior and it would have a more global effect then. For drivers not
using copybreak, that's needed here anyway, but maybe this help other
protocols/situations too.

Thanks,
  Marcelo
