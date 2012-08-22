From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 06/18] netfilter: add protocol independant NAT core
Date: Thu, 23 Aug 2012 00:13:57 +0200 (MEST)
Message-ID: <Pine.GSO.4.63.1208230008220.5113@stinky-local.trash.net>
References: <1345434006-16549-1-git-send-email-kaber@trash.net>
 <1345434006-16549-7-git-send-email-kaber@trash.net>
 <alpine.LNX.2.01.1208201011480.6101@frira.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.01.1208201011480.6101@frira.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 20 Aug 2012, Jan Engelhardt wrote:

> On Monday 2012-08-20 05:39, Patrick McHardy wrote:
>>
>> enum ctattr_nat {
>> 	CTA_NAT_UNSPEC,
>> -	CTA_NAT_MINIP,
>> -	CTA_NAT_MAXIP,
>> +	CTA_NAT_V4_MINIP,
>> +#define CTA_NAT_MINIP CTA_NAT_V4_MINIP
>> +	CTA_NAT_V4_MAXIP,
>> +#define CTA_NAT_MAXIP CTA_NAT_V4_MAXIP
>> 	CTA_NAT_PROTO,
>> 	__CTA_NAT_MAX
>> };
>
> One could also
>
> enum ctattr_nat {
>   ...
>   __CTA_NAT_MAX,
>
>  CTA_NAT_MINIP = CTA_NAT_V4_MINIP,
>  CTA_NAT_MAXIP = CTA_NAT_V4_MAXIP,
> };
>
> to provide the old names.

Sure. Doesn't really matter since defines are not used consistently
(in which case you could use them for #ifdefs).

>> diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
>> index fcc543c..33372a1 100644
>> --- a/net/ipv4/netfilter/Kconfig
>> +++ b/net/ipv4/netfilter/Kconfig
> [...]
>>
>> -config NF_NAT_NEEDED
>> -	bool
>> -	depends on NF_NAT
>> -	default y
>> -
>
> Could add "if NF_NAT_IPV4".."endif" block as appropriate around here,
> to save on all the extra "depend on NF_NAT_IPV4" clauses.

Agreed.
>> +static int nf_nat_ipv4_in_range(const struct nf_conntrack_tuple *t,
>> +				const struct nf_nat_range *range)
>> +{
>> +	return ntohl(t->src.u3.ip) >= ntohl(range->min_addr.ip) &&
>> +	       ntohl(t->src.u3.ip) <= ntohl(range->max_addr.ip);
>> +}
>
> static bool ..

Changed.

>> +static bool nf_nat_ipv4_manip_pkt(struct sk_buff *skb,
>> +				  unsigned int iphdroff,
>> +				  const struct nf_nat_l4proto *l4proto,
>> +				  const struct nf_conntrack_tuple *target,
>> +				  enum nf_nat_manip_type maniptype)
>> +{
>> +	struct iphdr *iph;
>> +	unsigned int hdroff;
>> +
>> +	if (!skb_make_writable(skb, iphdroff + sizeof(*iph)))
>> +		return false;
>> +
>> +	iph = (void *)skb->data + iphdroff;
>
> Is iph = ip_hdr(skb), hdroff = iphdroff+skb_iphdrlen(iph) not usable here?

No, we're also translating the inner packets in ICMP error messages.

>> +	hdroff = iphdroff + iph->ihl * 4;
>> +
>> +	if (!l4proto->manip_pkt(skb, &nf_nat_l3proto_ipv4, iphdroff, hdroff,
>> +				target, maniptype))
>> +		return false;
>> +	iph = (void *)skb->data + iphdroff;
>
> Is trying to avoid some GNU extensions a worthwhile goal? If so,
> iph = (struct iphdr *)(skb->data + iphdroff) should be used, like in:

I don't get your point.

>> +static void nf_nat_ipv4_csum_update(struct sk_buff *skb,
>> +				    unsigned int iphdroff, __sum16 *check,
>> +				    const struct nf_conntrack_tuple *t,
>> +				    enum nf_nat_manip_type maniptype)
>> +{
>> +	struct iphdr *iph = (struct iphdr *)(skb->data + iphdroff);
>> [...]
>> +}
>
>
>
>> +static void nf_nat_ipv4_csum_recalc(struct sk_buff *skb,
>> +				    u8 proto, void *data, __sum16 *check,
>> +				    int datalen, int oldlen)
>> +{
>> +	const struct iphdr *iph = ip_hdr(skb);
>> +	struct rtable *rt = skb_rtable(skb);
>> +
>> +	if (skb->ip_summed != CHECKSUM_PARTIAL) {
>> +		if (!(rt->rt_flags & RTCF_LOCAL) &&
>> +		    (!skb->dev || skb->dev->features & NETIF_F_V4_CSUM)) {
>> +			skb->ip_summed = CHECKSUM_PARTIAL;
>> +			skb->csum_start = skb_headroom(skb) +
>> +					  skb_network_offset(skb) +
>> +					  ip_hdrlen(skb);
>> +			skb->csum_offset = (void *)check - data;
>> +			*check = ~csum_tcpudp_magic(iph->saddr, iph->daddr,
>> +						    datalen, proto, 0);
>> +		} else {
>> +			*check = 0;
>> +			*check = csum_tcpudp_magic(iph->saddr, iph->daddr,
>> +						   datalen, proto,
>> +						   csum_partial(data, datalen,
>> +								0));
>> +			if (proto == IPPROTO_UDP && !*check)
>> +				*check = CSUM_MANGLED_0;
>> +		}
>> +	} else
>> +		inet_proto_csum_replace2(check, skb,
>> +					 htons(oldlen), htons(datalen), 1);
>> +}
>
> Here is a style factory trick: invert the condition such that the
> simple case is first, and the big one becomes an else if
> with a reduced indent:

This is existing code, I don't want to bloat the diff by unnecessarily
rearranging it.

>> +static void __exit nf_nat_l3proto_ipv4_exit(void)
>> +{
>> +	nf_nat_l3proto_unregister(&nf_nat_l3proto_ipv4);
>> +	nf_nat_l4proto_unregister(NFPROTO_IPV4, &nf_nat_l4proto_icmp);
>> +}
>> +
>> +MODULE_LICENSE("GPL");
>> +MODULE_ALIAS("nf-nat-" __stringify(AF_INET));
>
> Technically, this would have to be NFPROTO_IPV4, though GNU C has yet
> to gain an extension to stringify enum constants..

I'm aware of that.

>> +	/* 1) If this srcip/proto/src-proto-part is currently mapped,
>> +	 * and that same mapping gives a unique tuple within the given
>> +	 * range, use that.
>> +	 *
>> +	 * This is only required for source (ie. NAT/masq) mappings.
>> +	 * So far, we don't do local source mappings, so multiple
>> +	 * manips not an issue.
>           manips are not an issue.
>
>
>> -		/* nf_conntrack_alter_reply might re-allocate extension area */
>> +		/* nf_conntrack_alter_reply might re-allocate exntension aera */
>
> extension was correct :)

Fixed, thanks.

>> +		.target		= xt_snat_target_v1,
>> +		.targetsize	= sizeof(struct nf_nat_range),
>> +		.table		= "nat",
>> +		.hooks		= (1 << NF_INET_POST_ROUTING) |
>> +				  (1 << NF_INET_LOCAL_OUT),
>> +		.me		= THIS_MODULE,
>
> .family = NFPROTO_UNSPEC,
>
> Just for completeness.

This is obvious.
