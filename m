From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH] ipv6: Fix the pmtu path for connected UDP socket
Date: Fri, 18 Mar 2016 00:17:21 -0700
Message-ID: <20160318071721.GA9052@tessaserdar-mba.local.DHCP.thefacebook.com>
References: <1457989187-92851-1-git-send-email-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "David S . Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, <netdev@vger.kernel.org>
To: Wei Wang <weiwan@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:31871 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753110AbcCRHRe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2016 03:17:34 -0400
Content-Disposition: inline
In-Reply-To: <1457989187-92851-1-git-send-email-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 14, 2016 at 01:59:47PM -0700, Wei Wang wrote:
> From: Wei Wang <weiwan@google.com>
>
> When ICMPV6_PKT_TOOBIG message is received by a connected UDP socket,
> the new mtu value is not properly updated in the dst_entry associated
> with the socket.
A nit picking, the new mtu value cannot always be set directly
to the current dst_entry associated with the socket (i.e. sk->sk_dst_cache).
In this case, a RTF_CACHE clone has to be created.

The problem could be better understood if the commit message was like:
"After creating the RTF_CACHE clone (with the new mtu value),
sk->sk_dst_cache is not _immediately_ set to this RTF_CACHE clone.
getsockopt(IPV6_MTU) does not do a dst_check() first.  Hence,
if there was no outgoing message to trigger the dst_check() invalidation
logic, it may return the stale mtu value."

> -void ip6_update_pmtu(struct sk_buff *skb, struct net *net, __be32 mtu, int oif,
> -		     u32 mark);
> +void ip6_update_pmtu(struct net *net, struct sock *sk, struct sk_buff *skb,
> +		     __be32 mtu, int oif, u32 mark);
>  void ip6_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, __be32 mtu);
This change seems to make the API a bit confusing.  The none _sk_ version
is also taking a sk param now.

> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -1346,7 +1346,7 @@ static bool rt6_cache_allowed_for_pmtu(const struct rt6_info *rt)
>  		(rt->rt6i_flags & RTF_PCPU || rt->rt6i_node);
>  }
>
> -static void __ip6_rt_update_pmtu(struct dst_entry *dst, const struct sock *sk,
> +static void __ip6_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
>  				 const struct ipv6hdr *iph, u32 mtu)
>  {
>  	struct rt6_info *rt6 = (struct rt6_info *)dst;
> @@ -1377,12 +1377,8 @@ static void __ip6_rt_update_pmtu(struct dst_entry *dst, const struct sock *sk,
>  		nrt6 = ip6_rt_cache_alloc(rt6, daddr, saddr);
>  		if (nrt6) {
>  			rt6_do_update_pmtu(nrt6, mtu);
> -
> -			/* ip6_ins_rt(nrt6) will bump the
> -			 * rt6->rt6i_node->fn_sernum
> -			 * which will fail the next rt6_check() and
> -			 * invalidate the sk->sk_dst_cache.
> -			 */
> +			if (sk)
> +				ip6_dst_store(sk, &nrt6->dst, daddr, saddr);
daddr/saddr could be from iph which is from skb.  Considering skb could be
gone, are they suitable to be set in np->daddr_cache and np->saddr_cache?

After looking at this patch, I like your last patch more because this
problem seems to be limited to the connected udp socket only (?) and
udp knows better on what to pass to ip6_dst_store().  Feeling bad
now about steering you to this direction :(

Thanks,
-- Martin
