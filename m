From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipv4: Create and use fib_compute_spec_dst() helper.
Date: Fri, 29 Jun 2012 02:16:25 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1206282309340.1722@ja.ssi.bg>
References: <20120628.035946.1026666621448892198.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:56353 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751645Ab2F1XKd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jun 2012 19:10:33 -0400
In-Reply-To: <20120628.035946.1026666621448892198.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Thu, 28 Jun 2012, David Miller wrote:

> +__be32 fib_compute_spec_dst(struct sk_buff *skb)
> +{
> +	struct net_device *dev = skb->dev;
> +	struct in_device *in_dev;
> +	struct fib_result res;
> +	struct flowi4 fl4;
> +	struct net *net;
> +

	This is bad for looped m/b-cast: ip_mc_output calls
ip_dev_loopback_xmit where pkt_type is set to PACKET_LOOPBACK.
May be we have to check skb_dst as below.

	Also, for rt_spec_dst __mkroute_output used fl4->daddr for
looped unicast traffic and fl4->saddr for
RTCF_BROADCAST | RTCF_MULTICAST. Can we check rt_flags instead?
It will catch some pkt_type values such as PACKET_LOOPBACK.
For example, check similar to icmp_send():

	struct rtable *rt = skb_rtable(skb);

	/* input or output route destined to local stack?
	 * daddr can be mcast/bcast
	 */
	if (rt && rt->rt_flags & RTCF_LOCAL) {
		if (rt_is_input_route(rt)) {
			if (!(rt->rt_flags & (RTCF_BROADCAST |
					      RTCF_MULTICAST)))
				return ip_hdr(skb)->daddr;
			/* select saddr */
		} else
			return (rt->rt_flags & (RTCF_BROADCAST | 
						RTCF_MULTICAST)) ?
				ip_hdr(skb)->saddr : ip_hdr(skb)->daddr;
	}

	Isn't pkt_type just a hint from sender? We can not use
it for such places. What if hackers use unicast mac (PACKET_HOST)
combined with multicast daddr? I'm not sure that pkt_type
is a strong validator for layer 3 addresses.

> +	if (skb->pkt_type != PACKET_BROADCAST &&
> +	    skb->pkt_type != PACKET_MULTICAST)
> +		return ip_hdr(skb)->daddr;

	So, above check should be removed if we check rt_flags.

> +
> +	in_dev = __in_dev_get_rcu(dev);
> +	BUG_ON(!in_dev);
> +	fl4.flowi4_oif = 0;
> +	fl4.flowi4_iif = 0;

	It is not clear to me why ip_route_input_mc and
ip_route_input_slow (brd_input) call fib_validate_source()
with arg oif=0. How would fib_rule_match match flowi_iif
for such traffic then?

	May be iif should be always set just like in
ip_route_output_slow because now we do output lookup to
unicast target?:

	fl4.flowi4_iif = net->loopback_dev->ifindex;

> +	fl4.daddr = ip_hdr(skb)->saddr;
> +	fl4.saddr = ip_hdr(skb)->daddr;

	Here only 0 is allowed for m/b-cast daddr, we are not
going to use ip_hdr(skb)->daddr, so no need to provide it:

	fl4.saddr = 0;

	fib_validate_source was called with dst=0 for bcast/mcast.

> +	fl4.flowi4_tos = RT_TOS(ip_hdr(skb)->tos);
> +	fl4.flowi4_scope = RT_SCOPE_UNIVERSE;
> +	fl4.flowi4_mark = IN_DEV_SRC_VMARK(in_dev) ? skb->mark : 0;
> +
> +	net = dev_net(dev);

	Now net will be needed above for iif.

> +	if (!fib_lookup(net, &fl4, &res))
> +		return FIB_RES_PREFSRC(net, res);
> +	else

	What about providing ip_hdr(skb)->saddr as
2nd argument here (it is validated by input routing
to be unicast or 0.0.0.0):

> +		return inet_select_addr(dev, 0, RT_SCOPE_UNIVERSE);

	By this way we will prefer local address from the
same subnet as iph->saddr. Also, we should not call
fib_lookup if ipv4_is_zeronet(ip_hdr(skb)->saddr), we
should use RT_SCOPE_LINK for inet_select_addr in this case.
By this way we will prefer addresses with scope link for
target 0.0.0.0. There is such logic that uses RT_SCOPE_LINK in
ip_route_input_mc() and ip_route_input_slow().

>  int ip_options_compile(struct net *net,
>  		       struct ip_options *opt, struct sk_buff *skb)
>  {
> -	int l;
> -	unsigned char *iph;
> -	unsigned char *optptr;
> -	int optlen;
> +	__be32 spec_dst = (__force __be32) 0;
>  	unsigned char *pp_ptr = NULL;
> -	struct rtable *rt = NULL;
> +	unsigned char *optptr;
> +	unsigned char *iph;
> +	int optlen, l;
>  
>  	if (skb != NULL) {
> -		rt = skb_rtable(skb);
> +		spec_dst = fib_compute_spec_dst(skb);

	If we use rt_flags above I'm not sure whether
ip_options_compile is called with valid rt_flags from the
bridging code.

Regards
--
Julian Anastasov <ja@ssi.bg>
