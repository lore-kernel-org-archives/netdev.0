From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next v2 2/5] xen-netback: Add support for IPv6
 checksum offload from guest
Date: Tue, 8 Oct 2013 14:30:45 +0100
Message-ID: <20131008133045.GI28411@zion.uk.xensource.com>
References: <1381229896-18657-1-git-send-email-paul.durrant@citrix.com>
 <1381229896-18657-3-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:7119 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754771Ab3JHNar (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Oct 2013 09:30:47 -0400
Content-Disposition: inline
In-Reply-To: <1381229896-18657-3-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 08, 2013 at 11:58:13AM +0100, Paul Durrant wrote:
[...]
> -/*
> - * This is the amount of packet we copy rather than map, so that the
> - * guest can't fiddle with the contents of the headers while we do
> - * packet processing on them (netfilter, routing, etc).
> +/* This is a miniumum size for the linear area to avoid lots of
> + * calls to __pskb_pull_tail() as we set up checksum offsets.
>   */
> -#define PKT_PROT_LEN    (ETH_HLEN + \
> -			 VLAN_HLEN + \
> -			 sizeof(struct iphdr) + MAX_IPOPTLEN + \
> -			 sizeof(struct tcphdr) + MAX_TCP_OPTION_SPACE)
> +#define PKT_PROT_LEN 128
>  

Where does 128 come from?

>  static u16 frag_get_pending_idx(skb_frag_t *frag)
>  {
> @@ -1118,61 +1113,72 @@ static int xenvif_set_skb_gso(struct xenvif *vif,
>  	return 0;
>  }
>  
> -static int checksum_setup(struct xenvif *vif, struct sk_buff *skb)
> +static inline void maybe_pull_tail(struct sk_buff *skb, unsigned int len)
>  {
> -	struct iphdr *iph;
> +	if (skb_is_nonlinear(skb) && skb_headlen(skb) < len) {
> +		int target = min_t(int, skb->len, len);
> +		__pskb_pull_tail(skb, target - skb_headlen(skb));
> +	}
> +}
> +
> +static int checksum_setup_ip(struct xenvif *vif, struct sk_buff *skb,
> +			     int recalculate_partial_csum)
> +{
[...]
>  
>  		if (recalculate_partial_csum) {
>  			struct tcphdr *tcph = tcp_hdr(skb);
> +
> +			header_size = skb->network_header +
> +				off +
> +				sizeof(struct tcphdr) +
> +				MAX_TCP_OPTION_SPACE;
> +			maybe_pull_tail(skb, header_size);
> +

I presume this function is checksum_setup stripped down to handle IPv4
packet. What's the purpose of changing its behaviour? Why the pull_tail
here?

> +static int checksum_setup_ipv6(struct xenvif *vif, struct sk_buff *skb,
> +			       int recalculate_partial_csum)
> +{
> +	int err = -EPROTO;
> +	struct ipv6hdr *ipv6h = (void *)skb->data;
> +	u8 nexthdr;
> +	unsigned int header_size;
> +	unsigned int off;
> +	bool done;
> +
> +	done = false;
> +	off = sizeof(struct ipv6hdr);
> +
> +	header_size = skb->network_header + off;
> +	maybe_pull_tail(skb, header_size);
> +
> +	nexthdr = ipv6h->nexthdr;
> +
> +	while ((off <= sizeof(struct ipv6hdr) + ntohs(ipv6h->payload_len)) &&
> +	       !done) {
> +		/* We only access at most the first 2 bytes of any option header
> +		 * to determine the next one.
> +		 */
> +		header_size = skb->network_header + off + 2;
> +		maybe_pull_tail(skb, header_size);
> +

Will this cause performance problem? Is it possible that you pull too
many times?

> +		switch (nexthdr) {
> +		case IPPROTO_FRAGMENT: {
> +			struct frag_hdr *hp = (void *)(skb->data + off);
> +
> +			nexthdr = hp->nexthdr;
> +			off += 8;
> +			break;
> +		}
> +		case IPPROTO_DSTOPTS:
> +		case IPPROTO_HOPOPTS:
> +		case IPPROTO_ROUTING: {
> +			struct ipv6_opt_hdr *hp = (void *)(skb->data + off);
> +
> +			nexthdr = hp->nexthdr;
> +			off += ipv6_optlen(hp);
> +			break;
> +		}
> +		case IPPROTO_AH: {
> +			struct ip_auth_hdr *hp = (void *)(skb->data + off);
> +
> +			nexthdr = hp->nexthdr;
> +			off += (hp->hdrlen+2)<<2;
> +			break;
> +		}
> +		default:
> +			done = true;
> +			break;

Can you make the logic explicit here?

   case IPPROTO_TCP:
   case IPPROTO_UDP:
        done = true;
	break;
   default:
        break;

Another minor suggestion is that change "done" to "found" because you're
trying to find the two type of headers.

> +	switch (nexthdr) {
> +	case IPPROTO_TCP:
> +		if (!skb_partial_csum_set(skb, off,
> +					  offsetof(struct tcphdr, check)))
> +			goto out;
> +
> +		if (recalculate_partial_csum) {
> +			struct tcphdr *tcph = tcp_hdr(skb);
> +
> +			header_size = skb->network_header +
> +				off +
> +				sizeof(struct tcphdr) +
> +				MAX_TCP_OPTION_SPACE;
> +			maybe_pull_tail(skb, header_size);
> +

Same question as IPv4 counterpart, why do you need to pull here?

Wei.
