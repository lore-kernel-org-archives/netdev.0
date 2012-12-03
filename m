From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next 3/7] ipv6: improve ipv6_find_hdr() to skip
 empty routing headers
Date: Mon, 3 Dec 2012 15:04:58 +0100
Message-ID: <20121203140458.GA1596@1984>
References: <1354214149-33651-1-git-send-email-jesse@nicira.com>
 <1354214149-33651-4-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	dev@openvswitch.org, Ansis Atteka <aatteka@nicira.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:52340 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752888Ab2LCOFs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Dec 2012 09:05:48 -0500
Content-Disposition: inline
In-Reply-To: <1354214149-33651-4-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 29, 2012 at 10:35:45AM -0800, Jesse Gross wrote:
> From: Ansis Atteka <aatteka@nicira.com>
> 
> This patch prepares ipv6_find_hdr() function so that it could be
> able to skip routing headers, where segements_left is 0. This is
> required to handle multiple routing header case correctly when
> changing IPv6 addresses.
> 
> Signed-off-by: Ansis Atteka <aatteka@nicira.com>
> Signed-off-by: Jesse Gross <jesse@nicira.com>
> ---
>  include/net/ipv6.h      |    5 +++--
>  net/ipv6/exthdrs_core.c |   36 ++++++++++++++++++++++++++++--------
>  2 files changed, 31 insertions(+), 10 deletions(-)
> 
> diff --git a/include/net/ipv6.h b/include/net/ipv6.h
> index b2f0cfb..acbd8e0 100644
> --- a/include/net/ipv6.h
> +++ b/include/net/ipv6.h
> @@ -631,8 +631,9 @@ extern int			ipv6_skip_exthdr(const struct sk_buff *, int start,
>  extern bool			ipv6_ext_hdr(u8 nexthdr);
>  
>  enum {
> -	IP6_FH_F_FRAG	= (1 << 0),
> -	IP6_FH_F_AUTH	= (1 << 1),
> +	IP6_FH_F_FRAG		= (1 << 0),
> +	IP6_FH_F_AUTH		= (1 << 1),
> +	IP6_FH_F_SKIP_RH	= (1 << 2),
>  };
>  
>  /* find specified header and get offset to it */
> diff --git a/net/ipv6/exthdrs_core.c b/net/ipv6/exthdrs_core.c
> index 8ea253a..11b4e29 100644
> --- a/net/ipv6/exthdrs_core.c
> +++ b/net/ipv6/exthdrs_core.c
> @@ -132,9 +132,11 @@ EXPORT_SYMBOL(ipv6_skip_exthdr);
>   * *offset is meaningless and fragment offset is stored in *fragoff if fragoff
>   * isn't NULL.
>   *
> - * if flags is not NULL and it's a fragment, then the frag flag IP6_FH_F_FRAG
> - * will be set. If it's an AH header, the IP6_FH_F_AUTH flag is set and
> - * target < 0, then this function will stop at the AH header.
> + * if flags is not NULL and it's a fragment, then the frag flag
> + * IP6_FH_F_FRAG will be set. If it's an AH header, the
> + * IP6_FH_F_AUTH flag is set and target < 0, then this function will
> + * stop at the AH header. If IP6_FH_F_SKIP_RH flag was passed, then this
> + * function will skip all those routing headers, where segements_left was 0.
>   */
>  int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
>  		  int target, unsigned short *fragoff, int *flags)
> @@ -142,6 +144,7 @@ int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
>  	unsigned int start = skb_network_offset(skb) + sizeof(struct ipv6hdr);
>  	u8 nexthdr = ipv6_hdr(skb)->nexthdr;
>  	unsigned int len;
> +	bool found;
>  
>  	if (fragoff)
>  		*fragoff = 0;
> @@ -159,9 +162,10 @@ int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
>  	}
>  	len = skb->len - start;
>  
> -	while (nexthdr != target) {

If the offset is set as parameter via ipv6_find_hdr, we now are always
entering the loop even if we found the target header we're looking
for, before that didn't happen.

Something seems wrong here to me.

> +	do {
>  		struct ipv6_opt_hdr _hdr, *hp;
>  		unsigned int hdrlen;
> +		found = (nexthdr == target);
>  
>  		if ((!ipv6_ext_hdr(nexthdr)) || nexthdr == NEXTHDR_NONE) {
>  			if (target < 0)
> @@ -172,6 +176,20 @@ int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
>  		hp = skb_header_pointer(skb, start, sizeof(_hdr), &_hdr);
>  		if (hp == NULL)
>  			return -EBADMSG;
> +
> +		if (nexthdr == NEXTHDR_ROUTING) {
> +			struct ipv6_rt_hdr _rh, *rh;
> +
> +			rh = skb_header_pointer(skb, start, sizeof(_rh),
> +						&_rh);
> +			if (rh == NULL)
> +				return -EBADMSG;
> +
> +			if (flags && (*flags & IP6_FH_F_SKIP_RH) &&
> +			    rh->segments_left == 0)
> +				found = false;
> +		}
> +
>  		if (nexthdr == NEXTHDR_FRAGMENT) {
>  			unsigned short _frag_off;
>  			__be16 *fp;
> @@ -205,10 +223,12 @@ int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
>  		} else
>  			hdrlen = ipv6_optlen(hp);
>  
> -		nexthdr = hp->nexthdr;
> -		len -= hdrlen;
> -		start += hdrlen;
> -	}
> +		if (!found) {
> +			nexthdr = hp->nexthdr;
> +			len -= hdrlen;
> +			start += hdrlen;
> +		}
> +	} while (!found);
>  
>  	*offset = start;
>  	return nexthdr;
> -- 
> 1.7.9.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
