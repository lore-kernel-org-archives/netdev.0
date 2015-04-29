From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next 4/6] ipv6: Only create RTF_CACHE routes after
 encountering pmtu exception
Date: Wed, 29 Apr 2015 13:39:18 +0200
Message-ID: <20150429113918.GN8928@secunet.com>
References: <1430255273-3045254-1-git-send-email-kafai@fb.com>
 <1430255273-3045254-5-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>,
	Kernel Team <Kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:57722 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753506AbbD2LjX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Apr 2015 07:39:23 -0400
Content-Disposition: inline
In-Reply-To: <1430255273-3045254-5-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 28, 2015 at 02:07:51PM -0700, Martin KaFai Lau wrote:
>  
> -static void ip6_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
> -			       struct sk_buff *skb, u32 mtu)
> +static void __ip6_rt_update_pmtu(struct dst_entry *dst, const struct sock *sk,
> +				 const struct ipv6hdr *iph, u32 mtu)
>  {
>  	struct rt6_info *rt6 = (struct rt6_info *)dst;
> +	struct net *net;
> +
> +	if (rt6->rt6i_flags & RTF_LOCAL)
> +		return;
>  
>  	dst_confirm(dst);
> -	if (mtu < dst_mtu(dst) && (rt6->rt6i_flags & RTF_CACHE)) {
> -		struct net *net = dev_net(dst->dev);
> +	mtu = max_t(u32, mtu, IPV6_MIN_MTU);
> +	if (mtu >= dst_mtu(dst))
> +		return;
>  
> -		rt6->rt6i_flags |= RTF_MODIFIED;
> -		if (mtu < IPV6_MIN_MTU)
> -			mtu = IPV6_MIN_MTU;
> +	if (!(rt6->rt6i_flags & RTF_CACHE)) {
> +		const struct in6_addr *daddr, *saddr;
> +		struct rt6_info *nrt6;
>  
> -		rt6->rt6i_pmtu = mtu;
> -		rt6_update_expires(rt6, net->ipv6.sysctl.ip6_rt_mtu_expires);
> +		if (iph) {
> +			daddr = &iph->daddr;
> +			saddr = &iph->saddr;
> +		} else if (sk) {
> +			daddr = &sk->sk_v6_daddr;
> +			saddr = &inet6_sk(sk)->saddr;
> +		} else {
> +			return;
> +		}
> +		nrt6 = ip6_pmtu_rt_cache_alloc(rt6, daddr, saddr);
> +		if (!nrt6)
> +			return;
> +		/* ip6_ins_rt(nrt6) will bump the rt6->rt6i_node->fn_sernum
> +		 * which will fail the next rt6_check() and invalidate the
> +		 * sk->sk_dst_cache.
> +		 */
> +		if (ip6_ins_rt(nrt6)) {
> +			dst_destroy(&nrt6->dst);

fib6_add() does a dst_free() on error, so calling dst_destroy()
here might result in a use after free.


> +			return;
> +		}
> +
> +		rt6 = nrt6;
> +		dst = &nrt6->dst;
>  	}
> +
> +	net = dev_net(dst->dev);
> +	rt6->rt6i_flags |= RTF_MODIFIED;
> +	rt6->rt6i_pmtu = mtu;
> +	rt6_update_expires(rt6, net->ipv6.sysctl.ip6_rt_mtu_expires);

The update of expires and the setting of rt6i_pmtu should
happen before the route is inserted with ip6_ins_rt().
This is because fib6_add_rt2node() tries to reuse old
expired routes if still in the fib tree, the necessary
informations are copied from the new route before it
returnes -EEXIST on the new route. If your new route
has no expires value set, fib6_add_rt2node() cleans
expires of the old route before it resues it.

Also rt6i_pmtu should be copied to the reused route in
fib6_add_rt2node(), this should be done already in your
first patchset. Otherwise we might use stale pmtu informations.
