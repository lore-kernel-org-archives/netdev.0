From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next v3 2/5] xen-netback: add support for IPv6
 checksum offload from guest
Date: Fri, 11 Oct 2013 11:09:43 +0100
Message-ID: <20131011100943.GE15556@zion.uk.xensource.com>
References: <1381418733-20470-1-git-send-email-paul.durrant@citrix.com>
 <1381418733-20470-3-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:13889 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757040Ab3JKKJo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Oct 2013 06:09:44 -0400
Content-Disposition: inline
In-Reply-To: <1381418733-20470-3-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 10, 2013 at 04:25:30PM +0100, Paul Durrant wrote:
[...]
> -#define PKT_PROT_LEN    (ETH_HLEN + \
> -			 VLAN_HLEN + \
> -			 sizeof(struct iphdr) + MAX_IPOPTLEN + \
> -			 sizeof(struct tcphdr) + MAX_TCP_OPTION_SPACE)
> +#define PKT_PROT_LEN 128

I'm not against changing this, but could you please add comment on why
128 is chosen.

>  
[...]
> +	while ((off <= sizeof(struct ipv6hdr) + ntohs(ipv6h->payload_len)) &&
> +	       !done) {
> +		switch (nexthdr) {
> +		case IPPROTO_FRAGMENT: {
> +			struct frag_hdr *hp = (void *)(skb->data + off);
> +
> +			header_size = skb->network_header +
> +				off +
> +				sizeof(struct frag_hdr);
> +			maybe_pull_tail(skb, header_size);
> +
> +			nexthdr = hp->nexthdr;
> +			off += 8;

Can you use sizeof(frag_hdr) instead of 8?

> +			break;
> +		}
> +		case IPPROTO_DSTOPTS:
> +		case IPPROTO_HOPOPTS:
> +		case IPPROTO_ROUTING: {
> +			struct ipv6_opt_hdr *hp = (void *)(skb->data + off);
> +
> +			header_size = skb->network_header +
> +				off +
> +				sizeof(struct ipv6_opt_hdr);
> +			maybe_pull_tail(skb, header_size);
> +
> +			nexthdr = hp->nexthdr;
> +			off += ipv6_optlen(hp);
> +			break;
> +		}
> +		case IPPROTO_AH: {
> +			struct ip_auth_hdr *hp = (void *)(skb->data + off);
> +
> +			header_size = skb->network_header +
> +				off +
> +				sizeof(struct ip_auth_hdr);
> +			maybe_pull_tail(skb, header_size);
> +
> +			nexthdr = hp->nexthdr;
> +			off += (hp->hdrlen+2)<<2;
> +			break;
> +		}
> +		case IPPROTO_TCP:
> +		case IPPROTO_UDP:
> +			found = true;
> +			/* Fall through */
> +		default:
> +			done = true;
> +			break;

The above 'switch' doesn't seem to cover all IPPROTO_*. Will it cause
the loop to exit too early? In other words, does any IPPROTO_* not
listed above marks the end of parsing?

[...]
>  	unsigned long now = jiffies;
> @@ -1428,12 +1598,7 @@ static int xenvif_tx_submit(struct xenvif *vif, int budget)
>  
>  		xenvif_fill_frags(vif, skb);
>  
> -		/*
> -		 * If the initial fragment was < PKT_PROT_LEN then
> -		 * pull through some bytes from the other fragments to
> -		 * increase the linear region to PKT_PROT_LEN bytes.
> -		 */
> -		if (skb_headlen(skb) < PKT_PROT_LEN && skb_is_nonlinear(skb)) {
> +		if (skb_is_nonlinear(skb) && skb_headlen(skb) < PKT_PROT_LEN) {

This change is not necessary: the comment is useful, and swapping two
operands of && doesn't have any effect.

Wei.
