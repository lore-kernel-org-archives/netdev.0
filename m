From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] udp6: fix socket leak on early demux
Date: Thu, 27 Jul 2017 00:06:01 -0700
Message-ID: <1501139161.12695.20.camel@edumazet-glaptop3.roam.corp.google.com>
References: <fa8561e5d814bfcd8aeb20f09732a716ffca772c.1501082940.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Sam Edwards <CFSworks@gmail.com>,
        Marc Haber <mh+netdev@zugschlus.de>,
        Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:37964 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750878AbdG0HOI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 03:14:08 -0400
Received: by mail-wm0-f66.google.com with SMTP id r123so13219104wmb.5
        for <netdev@vger.kernel.org>; Thu, 27 Jul 2017 00:14:07 -0700 (PDT)
In-Reply-To: <fa8561e5d814bfcd8aeb20f09732a716ffca772c.1501082940.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-07-26 at 17:29 +0200, Paolo Abeni wrote:
> When an early demuxed packet reaches __udp6_lib_lookup_skb(), the
> sk reference is retrieved and used, but the relevant reference
> count is leaked and the socket destructor is never called.
> Beyond leaking the sk memory, if there are pending UDP packets
> in the receive queue, even the related accounted memory is leaked.
> 
> In the long run, this will cause persistent forward allocation errors
> and no UDP skbs (both ipv4 and ipv6) will be able to reach the
> user-space.
> 
> Fix this by explicitly accessing the early demux reference before
> the lookup, and properly decreasing the socket reference count
> after usage.
> 
> Also drop the skb_steal_sock() in __udp6_lib_lookup_skb(), and
> the now obsoleted comment about "socket cache".
> 
> The newly added code is derived from the current ipv4 code for the
> similar path.


Nice catch Paolo.

I believe there is one point to discuss, see below.

> 
> Reported-by: Sam Edwards <CFSworks@gmail.com>
> Reported-by: Marc Haber <mh+netdev@zugschlus.de>
> Fixes: 5425077d73e0 ("net: ipv6: Add early demux handler for UDP unicast")
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> ---
>  include/net/udp.h |  1 +
>  net/ipv4/udp.c    |  3 ++-
>  net/ipv6/udp.c    | 28 +++++++++++++++++++---------
>  3 files changed, 22 insertions(+), 10 deletions(-)
> 
> diff --git a/include/net/udp.h b/include/net/udp.h
> index 56ce2d2a612d..cc8036987dcb 100644
> --- a/include/net/udp.h
> +++ b/include/net/udp.h
> @@ -260,6 +260,7 @@ static inline struct sk_buff *skb_recv_udp(struct sock *sk, unsigned int flags,
>  }
>  
>  void udp_v4_early_demux(struct sk_buff *skb);
> +void udp_sk_rx_dst_set(struct sock *sk, struct dst_entry *dst);
>  int udp_get_port(struct sock *sk, unsigned short snum,
>  		 int (*saddr_cmp)(const struct sock *,
>  				  const struct sock *));
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index fac7cb9e3b0f..e6276fa3750b 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -1928,7 +1928,7 @@ static int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
>  /* For TCP sockets, sk_rx_dst is protected by socket lock
>   * For UDP, we use xchg() to guard against concurrent changes.
>   */
> -static void udp_sk_rx_dst_set(struct sock *sk, struct dst_entry *dst)
> +void udp_sk_rx_dst_set(struct sock *sk, struct dst_entry *dst)
>  {
>  	struct dst_entry *old;
>  
> @@ -1937,6 +1937,7 @@ static void udp_sk_rx_dst_set(struct sock *sk, struct dst_entry *dst)
>  		dst_release(old);
>  	}
>  }
> +EXPORT_SYMBOL(udp_sk_rx_dst_set);
>  
>  /*
>   *	Multicasts and broadcasts go to each listener.
> diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
> index 4a3e65626e8b..e74fe497d823 100644
> --- a/net/ipv6/udp.c
> +++ b/net/ipv6/udp.c
> @@ -291,11 +291,7 @@ static struct sock *__udp6_lib_lookup_skb(struct sk_buff *skb,
>  					  struct udp_table *udptable)
>  {
>  	const struct ipv6hdr *iph = ipv6_hdr(skb);
> -	struct sock *sk;
>  
> -	sk = skb_steal_sock(skb);
> -	if (unlikely(sk))
> -		return sk;
>  	return __udp6_lib_lookup(dev_net(skb->dev), &iph->saddr, sport,
>  				 &iph->daddr, dport, inet6_iif(skb),
>  				 udptable, skb);
> @@ -804,6 +800,25 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
>  	if (udp6_csum_init(skb, uh, proto))
>  		goto csum_error;
>  
> +	/* Check if the socket is already available, e.g. due to early demux */
> +	sk = skb_steal_sock(skb);
> +	if (sk) {
> +		struct dst_entry *dst = skb_dst(skb);
> +		int ret;
> +
> +		if (unlikely(sk->sk_rx_dst != dst))
> +			udp_sk_rx_dst_set(sk, dst);
> +
> +		ret = udpv6_queue_rcv_skb(sk, skb);
> +		sock_put(sk);
> +		/* a return value > 0 means to resubmit the input, but
> +		 * it wants the return to be -protocol, or 0
> +		 */
> +		if (ret > 0)
> +			return -ret;

IPv6 and IPv4 have different behavior for resubmit

I believe "return ret;"  would be more appropriate here.

> +		return 0;
> +	}
> +
>  	/*
>  	 *	Multicast receive code
>  	 */
> @@ -812,11 +827,6 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
>  				saddr, daddr, udptable, proto);
>  
>  	/* Unicast */
> -
> -	/*
> -	 * check socket cache ... must talk to Alan about his plans
> -	 * for sock caches... i'll skip this for now.
> -	 */
>  	sk = __udp6_lib_lookup_skb(skb, uh->source, uh->dest, udptable);
>  	if (sk) {
>  		int ret;
