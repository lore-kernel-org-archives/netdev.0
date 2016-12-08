From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next] udp: under rx pressure, try to condense skbs
Date: Thu, 8 Dec 2016 10:46:20 +0100
Message-ID: <20161208104620.5fc691b8@redhat.com>
References: <1481131173.4930.36.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, Paolo Abeni <pabeni@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54696 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751667AbcLHJqY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Dec 2016 04:46:24 -0500
In-Reply-To: <1481131173.4930.36.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 07 Dec 2016 09:19:33 -0800
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> Under UDP flood, many softirq producers try to add packets to
> UDP receive queue, and one user thread is burning one cpu trying
> to dequeue packets as fast as possible.
> 
> Two parts of the per packet cost are :
> - copying payload from kernel space to user space,
> - freeing memory pieces associated with skb.
> 
> If socket is under pressure, softirq handler(s) can try to pull in
> skb->head the payload of the packet if it fits.
> 
> Meaning the softirq handler(s) can free/reuse the page fragment
> immediately, instead of letting udp_recvmsg() do this hundreds of usec
> later, possibly from another node.
> 
> 
> Additional gains :
> - We reduce skb->truesize and thus can store more packets per SO_RCVBUF
> - We avoid cache line misses at copyout() time and consume_skb() time,
> and avoid one put_page() with potential alien freeing on NUMA hosts.
> 
> This comes at the cost of a copy, bounded to available tail room, which
> is usually small. (We might have to fix GRO_MAX_HEAD which looks bigger
> than necessary)
> 
> This patch gave me about 5 % increase in throughput in my tests.

Hmmm... I'm not thrilled to have such heuristics, that change memory
behavior when half of the queue size (sk->sk_rcvbuf) is reached.

Most of the win comes from doing a local atomic page-refcnt decrement
oppose to doing a remote CPU refcnf-dec.  And as you noticed the
benefit is quite high saving 241 cycles (see [1]).  And you patch is
"using" these cycles to copy the packet instead.

This might no be a win in the future.  I'm working on a more generic
solution (page_pool) that (as one objective) target this remote recfnt.


[1] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/mm/bench/page_bench03.c
 Measured on: i7-4790K CPU @ 4.00GHz
 Same CPU release cost  : 251 cycles
 Remote CPU release cost: 492 cycles

 
> skb_condense() helper could probably used in other contexts.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Paolo Abeni <pabeni@redhat.com>
> ---
[...]
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index b45cd1494243fc99686016949f4546dbba11f424..84151cf40aebb973bad5bee3ee4be0758084d83c 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -4931,3 +4931,31 @@ struct sk_buff *pskb_extract(struct sk_buff *skb, int off,
>  EXPORT_SYMBOL(pskb_extract);
> +
> +/**
> + * skb_condense - try to get rid of fragments/frag_list if possible
> + * @skb: buffer
> + *
> + * Can be used to save memory before skb is added to a busy queue.
> + * If packet has bytes in frags and enough tail room in skb->head,
> + * pull all of them, so that we can free the frags right now and adjust
> + * truesize.
> + * Notes:
> + *	We do not reallocate skb->head thus can not fail.
> + *	Caller must re-evaluate skb->truesize if needed.
> + */
> +void skb_condense(struct sk_buff *skb)
> +{
> +	if (!skb->data_len ||
> +	    skb->data_len > skb->end - skb->tail ||
> +	    skb_cloned(skb))
> +		return;

So this only active, depending on how driver constructed the SKB, but
all end-up doing a function call (not inlined).

> +	/* Nice, we can free page frag(s) right now */
> +	__pskb_pull_tail(skb, skb->data_len);
> +
> +	/* Now adjust skb->truesize, since __pskb_pull_tail() does
> +	 * not do this.
> +	 */
> +	skb->truesize = SKB_TRUESIZE(skb_end_offset(skb));
> +}
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index 16d88ba9ff1c402f77063cfb5eea2708d86da2fc..f5628ada47b53f0d92d08210e5d7e4132a107f73 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
[...]
> @@ -1208,6 +1208,16 @@ int __udp_enqueue_schedule_skb(struct sock *sk, struct sk_buff *skb)
>  	if (rmem > sk->sk_rcvbuf)
>  		goto drop;
>  
> +	/* Under mem pressure, it might be helpful to help udp_recvmsg()
> +	 * having linear skbs :
> +	 * - Reduce memory overhead and thus increase receive queue capacity
> +	 * - Less cache line misses at copyout() time
> +	 * - Less work at consume_skb() (less alien page frag freeing)
> +	 */
> +	if (rmem > (sk->sk_rcvbuf >> 1))
> +		skb_condense(skb);
> +	size = skb->truesize;
> +



-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
