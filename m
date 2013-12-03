From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net v4] xen-netback: fix fragment detection in checksum
 setup
Date: Tue, 3 Dec 2013 14:02:44 +0000
Message-ID: <20131203140243.GF14293@zion.uk.xensource.com>
References: <1386005715-27566-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	Zoltan Kiss <zoltan.kiss@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	David Miller <davem@davemloft.net>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:22903 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752729Ab3LCOCp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Dec 2013 09:02:45 -0500
Content-Disposition: inline
In-Reply-To: <1386005715-27566-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 02, 2013 at 05:35:15PM +0000, Paul Durrant wrote:
> The code to detect fragments in checksum_setup() was missing for IPv4 and
> too eager for IPv6. (It transpires that Windows seems to send IPv6 packets
> with a fragment header even if they are not a fragment - i.e. offset is zero,
> and M bit is not set).
> This patch also incorporates a fix to callers of maybe_pull_tail() where
> skb->network_header was being erroneously added to the length argument.
> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
> Cc: Wei Liu <wei.liu2@citrix.com>
> Cc: Ian Campbell <ian.campbell@citrix.com>
> Cc: David Vrabel <david.vrabel@citrix.com>
> cc: David Miller <davem@davemloft.net>
> ---
> v4
> - Re-work maybe_pull_tail() to have a failure path and update mac and
>   network header pointers on success.
> - Re-work callers of maybe_pull_tail() to handle failures and allow for
>   movement of skb header pointers.
> - Incorporate fixes from patch "Fix pull size in checksum_setup_ip" since
>   it also modifies callers of maybe_pull_tail().
> - Remove error messages in checksum routines that could be triggered by frontends
> 
> v3
> - Use defined values for 'fragment offset' and 'more fragments'
> 
> v2
> - Added comments noting what fragment/offset masks mean
> 
>  drivers/net/xen-netback/netback.c |  215 ++++++++++++++++++++-----------------
>  include/linux/ipv6.h              |    1 +
>  include/net/ipv6.h                |    3 +-
>  3 files changed, 120 insertions(+), 99 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index 64f0e0d..e3d7216 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -1149,49 +1149,62 @@ static int xenvif_set_skb_gso(struct xenvif *vif,
>  	return 0;
>  }
>  
> -static inline void maybe_pull_tail(struct sk_buff *skb, unsigned int len)
> +static inline bool maybe_pull_tail(struct sk_buff *skb, unsigned int len,
> +				   unsigned int max)
>  {
> -	if (skb_is_nonlinear(skb) && skb_headlen(skb) < len) {
> -		/* If we need to pullup then pullup to the max, so we
> -		 * won't need to do it again.
> -		 */
> -		int target = min_t(int, skb->len, MAX_TCP_HEADER);
> -		__pskb_pull_tail(skb, target - skb_headlen(skb));
> -	}
> +	if (skb_headlen(skb) >= len)
> +		return true;
> +
> +	/* If we need to pullup then pullup to the max, so we
> +	 * won't need to do it again.
> +	 */
> +	if (max > skb->len)
> +		max = skb->len;
> +
> +	__pskb_pull_tail(skb, max - skb_headlen(skb));
> +
> +	return skb_headlen(skb) >= len;
>  }
>  
> +/* This value should be large enough to cover a tagged ethernet header plus
> + * maximally sized IP and TCP or UDP headers.
> + */
> +#define MAX_IP_HDR_LEN 128
> +
>  static int checksum_setup_ip(struct xenvif *vif, struct sk_buff *skb,
>  			     int recalculate_partial_csum)
>  {
> -	struct iphdr *iph = (void *)skb->data;
> -	unsigned int header_size;
>  	unsigned int off;
> +	bool fragment;
>  	int err = -EPROTO;
>  
> -	off = sizeof(struct iphdr);
> +	fragment = false;
>  
> -	header_size = skb->network_header + off + MAX_IPOPTLEN;
> -	maybe_pull_tail(skb, header_size);
> +	if (!maybe_pull_tail(skb, sizeof(struct iphdr), MAX_IP_HDR_LEN))
> +		goto out;
> +

I think you need to correctly update err to reflect this failure.
Using -EPROTO will wrongly blame frontend while it is backend that's
failing to process the packet.

Wei.
