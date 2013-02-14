From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] net: Convert skb->csum_(start|offset) integrity BUG_ON()
 to WARN_ON() & drop
Date: Thu, 14 Feb 2013 18:50:08 +0000
Message-ID: <20130214185008.GA10745@casper.infradead.org>
References: <20130213234021.GA21829@casper.infradead.org>
 <20130213234843.GB21829@casper.infradead.org>
 <20130213.193759.1094469499685059296.davem@davemloft.net>
 <20130214101853.GC21829@casper.infradead.org>
 <1360858943.6884.47.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:50806 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761517Ab3BNSuL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 13:50:11 -0500
Content-Disposition: inline
In-Reply-To: <1360858943.6884.47.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/14/13 at 08:22am, Eric Dumazet wrote:
> It seems not possible to avoid bugs, being a BUG_ON() or a out of bound
> memory access or whatever. We must fix them eventually.

Of course, I never intended to not fix this but I still think
leaving the BUG_ON() is wrong ;-)

> In this case, it seems we must limit payload to 
> 
> 65535 - MAX_TCP_HEADER 
> 
> It would make tcp_xmit_size_goal() a bit shorter.
> 
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 2c7e596..2f6c8e5 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -793,10 +793,7 @@ static unsigned int tcp_xmit_size_goal(struct sock *sk, u32 mss_now,
>  	xmit_size_goal = mss_now;
>  
>  	if (large_allowed && sk_can_gso(sk)) {
> -		xmit_size_goal = ((sk->sk_gso_max_size - 1) -
> -				  inet_csk(sk)->icsk_af_ops->net_header_len -
> -				  inet_csk(sk)->icsk_ext_hdr_len -
> -				  tp->tcp_header_len);
> +		xmit_size_goal = sk->sk_gso_max_size - 1 - MAX_TCP_HEADER;
>  
>  		/* TSQ : try to have two TSO segments in flight */
>  		xmit_size_goal = min_t(u32, xmit_size_goal,

I don't think this would help. The allocated skb data will still
exceed 64K and thus after trimming the acked data and collapsing
the header might be stored after the 64K mark.

We would have to limit the skb tailroom to 64K upon allocation.
That would mean we would waste some of the additional space that
kmalloc() might have given us:

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 32443eb..c8f9850 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -241,6 +241,8 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mas
         * to allow max possible filling before reallocation.
         */
        size = SKB_WITH_OVERHEAD(ksize(data));
+       /* ensure that all offsets based on skb->head fit into 16bits */
+       size = min_t(int, size, 65535);
        prefetchw(data + size);
 
        /*


Or if that is not ideal, avoiding the collapse that causes the overflow
would also help:


diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 5d45159..e9111b4 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2301,6 +2301,12 @@ static void tcp_retrans_try_collapse(struct sock *sk, struct sk_buff *to,
                if (after(TCP_SKB_CB(skb)->end_seq, tcp_wnd_end(tp)))
                        break;
 
+               /* Never collapse if the resulting headroom + data exceeds
+                * 64K as that is the maximum csum_start can cover.
+                */
+               if (skb_headroom(to) + to->len + skb->len > 65535)
+                       break;
+
                tcp_collapse_retrans(sk, to);
        }
 }
