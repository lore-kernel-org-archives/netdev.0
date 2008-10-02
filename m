From: Patrick McHardy <kaber@trash.net>
Subject: Re: [net-next PATCH 14/16] iptables socket match
Date: Thu, 02 Oct 2008 11:26:36 +0200
Message-ID: <48E493CC.9020502@trash.net>
References: <20081001142431.4893.48078.stgit@este> <20081001142431.4893.56954.stgit@este>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: KOVACS Krisztian <hidden@sch.bme.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20081001142431.4893.56954.stgit@este>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

KOVACS Krisztian wrote:
> Add iptables 'socket' match, which matches packets for which a TCP/UDP
> socket lookup succeeds.
>   

It seems sufficiently different from what xt_owner does to justify a 
separate module.
Minor nitpicking:

> +static int
> +extract_icmp_fields(const struct sk_buff *skb,
> +		    u8 *protocol,
> +		    __be32 *raddr,
> +		    __be32 *laddr,
> +		    __be16 *rport,
> +		    __be16 *lport)
> +{
> +	struct iphdr *outside_iph = ip_hdr(skb);
> +	struct iphdr *inside_iph, _inside_iph;
> +	struct icmphdr *icmph, _icmph;
> +	__be16 *ports, _ports[2];
> +
> +	icmph = skb_header_pointer(skb, outside_iph->ihl << 2, sizeof(_icmph), &_icmph);
>   

The "ihl << 2" is repeating multiple times. Maybe just store it in a 
variable,
also it would be nicer to use ip_hdrlen().

> +	if (icmph == NULL)
> +		return 1;
> +
> +	switch (icmph->type) {
> +	case ICMP_DEST_UNREACH:
> +	case ICMP_SOURCE_QUENCH:
> +	case ICMP_REDIRECT:
> +	case ICMP_TIME_EXCEEDED:
> +	case ICMP_PARAMETERPROB:
> +		break;
> +	default:
> +		return 1;
> +	}
> +
> +	inside_iph = skb_header_pointer(skb, (outside_iph->ihl << 2) + sizeof(struct icmphdr), sizeof(_inside_iph), &_inside_iph);
>   

And these lines (few more below) should break at 80 characters.

> +	if (inside_iph == NULL)
> +		return -EINVAL;
>   
What is the return convention here? It seems this should also return 1 
as the
other exit paths.

> +static bool
> +socket_mt(const struct sk_buff *skb,
> +	  const struct net_device *in,
> +	  const struct net_device *out,
> +	  const struct xt_match *match,
> +	  const void *matchinfo,
> +	  int offset,
> +	  unsigned int protoff,
> +	  bool *hotdrop)
> +{
>   
...
> +	if (iph->protocol == IPPROTO_UDP || iph->protocol == IPPROTO_TCP) {
> +		hp = skb_header_pointer(skb, ip_hdrlen(skb), sizeof(_hdr), &_hdr);
> +		if (hp == NULL)
> +			return false;
> +
> +		protocol = iph->protocol;
> +		saddr = iph->saddr;
> +		sport = hp->source;
> +		daddr = iph->daddr;
> +		dport = hp->dest;
> +
> +	}
> +	else if (iph->protocol == IPPROTO_ICMP) {
>   

Please put the else on the same line as the closing brace.

