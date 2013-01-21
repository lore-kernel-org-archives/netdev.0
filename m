From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 1/2] ipv4: Invalidate the socket cached route on pmtu
 events if possible
Date: Mon, 21 Jan 2013 23:18:27 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1301212245170.1886@ja.ssi.bg>
References: <20130121115911.GE30530@secunet.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	"Yurij M. Plotnikov" <Yurij.Plotnikov@oktetlabs.ru>,
	netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:46021 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756809Ab3AUVPF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jan 2013 16:15:05 -0500
In-Reply-To: <20130121115911.GE30530@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Mon, 21 Jan 2013, Steffen Klassert wrote:

> The route lookup in ipv4_sk_update_pmtu() might return a route
> different from the route we cached at the socket. This is because
> standart routes are per cpu, so each cpu has it's own struct rtable.
> This means that we do not invalidate the socket cached route if the
> NET_RX_SOFTIRQ is not served by the same cpu that the sending socket
> uses. As a result, the cached route reused until we disconnect.
> 
> With this patch we invalidate the socket cached route if possible.
> If the socket is owened by the user, we can't update the cached
> route directly. A followup patch will implement socket release
> callback functions for datagram sockets to handle this case.
> 
> Reported-by: Yurij M. Plotnikov <Yurij.Plotnikov@oktetlabs.ru>
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> ---
>  net/ipv4/route.c |   42 +++++++++++++++++++++++++++++++++++++++++-
>  1 file changed, 41 insertions(+), 1 deletion(-)
> 
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 259cbee..132737a 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -965,7 +965,7 @@ void ipv4_update_pmtu(struct sk_buff *skb, struct net *net, u32 mtu,
>  }
>  EXPORT_SYMBOL_GPL(ipv4_update_pmtu);
>  
> -void ipv4_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, u32 mtu)
> +static void __ipv4_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, u32 mtu)
>  {
>  	const struct iphdr *iph = (const struct iphdr *) skb->data;
>  	struct flowi4 fl4;
> @@ -978,6 +978,46 @@ void ipv4_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, u32 mtu)
>  		ip_rt_put(rt);
>  	}
>  }
> +
> +void ipv4_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, u32 mtu)
> +{
> +	const struct iphdr *iph = (const struct iphdr *) skb->data;
> +	struct flowi4 fl4;
> +	struct rtable *rt;
> +	struct dst_entry *dst;
> +
> +	bh_lock_sock(sk);
> +	rt = (struct rtable *) __sk_dst_get(sk);

	I just saw another problem, sorry that
I missed it the first time. Here __sk_dst_get
does not get reference...

> +
> +	if (sock_owned_by_user(sk) || !rt) {
> +		__ipv4_sk_update_pmtu(skb, sk, mtu);
> +		goto out;
> +	}
> +
> +	__build_flow_key(&fl4, sk, iph, 0, 0, 0, 0, 0);
> +
> +	if (!__sk_dst_check(sk, 0)) {
> +		rt = ip_route_output_flow(sock_net(sk), &fl4, sk);
> +		if (IS_ERR(rt))
> +			goto out;

		but here rt->dst comes with reference.

> +	}

	May be here we can use 'else dst_hold(&rt->dst);' ?
It is needed for __sk_dst_set.

> +
> +	__ip_rt_update_pmtu((struct rtable *) rt->dst.path, &fl4, mtu);
> +
> +	dst = dst_check(&rt->dst, 0);
> +	if (!dst) {

		dst_release(&rt->dst);

> +		rt = ip_route_output_flow(sock_net(sk), &fl4, sk);
> +		if (IS_ERR(rt))
> +			goto out;
> +
> +		dst = &rt->dst;

		Remove above line...

> +	}
> +

	and use here __sk_dst_set(sk, &rt->dst) instead:

> +	 __sk_dst_set(sk, dst);

	Another variant is to remember with flag 'new_rt'
that we should call __sk_dst_set, eg. when rt comes from
ip_route_output_flow. By this way we can avoid some of
the dst_hold/dst_release calls if sk_dst_cache is not
changed. IIRC, according to sk_dst_check, dst_check can
not return different dst from the ->check method.

> +
> +out:
> +	bh_unlock_sock(sk);
> +}
>  EXPORT_SYMBOL_GPL(ipv4_sk_update_pmtu);
>  
>  void ipv4_redirect(struct sk_buff *skb, struct net *net,
> -- 
> 1.7.9.5

Regards

--
Julian Anastasov <ja@ssi.bg>
