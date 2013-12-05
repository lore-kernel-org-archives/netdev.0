From: annie li <annie.li@oracle.com>
Subject: Re: [PATCH net v5] xen-netback: fix fragment detection in checksum
 setup
Date: Thu, 05 Dec 2013 14:28:08 +0800
Message-ID: <52A01CF8.4000804@oracle.com>
References: <1386092369-13618-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	Zoltan Kiss <zoltan.kiss@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	David Miller <davem@davemloft.net>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:39143 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751246Ab3LEG2X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 01:28:23 -0500
In-Reply-To: <1386092369-13618-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2013/12/4 1:39, Paul Durrant wrote:

>   
> +/* This value should be large enough to cover a tagged ethernet header plus
> + * an IPv6 header, all options, and a maximal TCP or UDP header.
> + */
> +#define MAX_IPV6_HDR_LEN 256
> +
> +#define OPT_HDR(type, skb, off) \
> +	(type *)(skb_network_header(skb) + (off))
> +
>   static int checksum_setup_ipv6(struct xenvif *vif, struct sk_buff *skb,
>   			       int recalculate_partial_csum)
>   {
> -	int err = -EPROTO;
> -	struct ipv6hdr *ipv6h = (void *)skb->data;
> +	int err;
>   	u8 nexthdr;
> -	unsigned int header_size;
>   	unsigned int off;
> +	unsigned int len;
>   	bool fragment;
>   	bool done;
>   
> +	fragment = false;
>   	done = false;
>   
>   	off = sizeof(struct ipv6hdr);
>   
> -	header_size = skb->network_header + off;
> -	maybe_pull_tail(skb, header_size);
> +	err = maybe_pull_tail(skb, off, MAX_IPV6_HDR_LEN);
> +	if (err < 0)
> +		goto out;
>   
> -	nexthdr = ipv6h->nexthdr;
> +	nexthdr = ipv6_hdr(skb)->nexthdr;
>   
> -	while ((off <= sizeof(struct ipv6hdr) + ntohs(ipv6h->payload_len)) &&
> -	       !done) {
> +	len = sizeof(struct ipv6hdr) + ntohs(ipv6_hdr(skb)->payload_len);
> +	while (off <= len && !done) {
>   		switch (nexthdr) {
>   		case IPPROTO_DSTOPTS:
>   		case IPPROTO_HOPOPTS:
>   		case IPPROTO_ROUTING: {
> -			struct ipv6_opt_hdr *hp = (void *)(skb->data + off);
> +			struct ipv6_opt_hdr *hp;
>   
> -			header_size = skb->network_header +
> -				off +
> -				sizeof(struct ipv6_opt_hdr);
> -			maybe_pull_tail(skb, header_size);
> +			err = maybe_pull_tail(skb,
> +					      off +
> +					      sizeof(struct ipv6_opt_hdr),
> +					      MAX_IPV6_HDR_LEN);
> +			if (err < 0)
> +				goto out;
>   
> +			hp = OPT_HDR(struct ipv6_opt_hdr, skb, off);
>   			nexthdr = hp->nexthdr;
>   			off += ipv6_optlen(hp);
>   			break;
>   		}
>   		case IPPROTO_AH: {
> -			struct ip_auth_hdr *hp = (void *)(skb->data + off);
> +			struct ip_auth_hdr *hp;
> +
> +			err = maybe_pull_tail(skb,
> +					      off +
> +					      sizeof(struct ip_auth_hdr),
> +					      MAX_IPV6_HDR_LEN);
> +			if (err < 0)
> +				goto out;
> +
> +			hp = OPT_HDR(struct ip_auth_hdr, skb, off);
> +			nexthdr = hp->nexthdr;
> +			off += ipv6_authlen(hp);
> +			break;
> +		}
> +		case IPPROTO_FRAGMENT: {
> +			struct frag_hdr *hp;
>   
> -			header_size = skb->network_header +
> -				off +
> -				sizeof(struct ip_auth_hdr);
> -			maybe_pull_tail(skb, header_size);
> +			err = maybe_pull_tail(skb,
> +					      off +
> +					      sizeof(struct frag_hdr),
> +					      MAX_IPV6_HDR_LEN);
> +			if (err < 0)
> +				goto out;
> +
> +			hp = OPT_HDR(struct frag_hdr, skb, off);
> +
> +			if (hp->frag_off & htons(IP6_OFFSET | IP6_MF))
> +				fragment = true;
>   
>   			nexthdr = hp->nexthdr;
> -			off += (hp->hdrlen+2)<<2;
> +			off += sizeof(struct frag_hdr);
>   			break;
>   		}
> -		case IPPROTO_FRAGMENT:
> -			fragment = true;
> -			/* fall through */

About IPv6 extension headers, should "Encapsulating Security Payload" be 
processed too?(See rfc2460 and rfc2406) Is there any concern to ignore 
it here?

Thanks
Annie
