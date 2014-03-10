From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH net V2] Xen-netback: Fix issue caused by using gso_type
 wrongly
Date: Mon, 10 Mar 2014 15:12:07 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD027D64B@AMSPEX01CL01.citrite.net>
References: <1394463514-2979-1-git-send-email-Annie.li@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: Annie Li <Annie.li@oracle.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([185.25.65.24]:60839 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752651AbaCJPMJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 11:12:09 -0400
In-Reply-To: <1394463514-2979-1-git-send-email-Annie.li@oracle.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Annie Li [mailto:Annie.li@oracle.com]
> Sent: 10 March 2014 14:59
> To: xen-devel@lists.xen.org; netdev@vger.kernel.org
> Cc: konrad.wilk@oracle.com; Ian Campbell; Wei Liu; Paul Durrant;
> annie.li@oracle.com
> Subject: [PATCH net V2] Xen-netback: Fix issue caused by using gso_type
> wrongly
> 
> From: Annie Li <annie.li@oracle.com>
> 
> Current netback uses gso_type to check whether the skb contains
> gso offload, and this is wrong. Gso_size is the right one to
> check gso existence, and gso_type is only used to check gso type.
> 
> Some skbs contains nonzero gso_type and zero gso_size, current
> netback would treat these skbs as gso and create wrong response
> for this. This also causes ssh failure to domu from other server.
> 
> V2: use skb_is_gso function as Paul Durrant suggested
> 
> Signed-off-by: Annie Li <annie.li@oracle.com>

Reviewed-by: Paul Durrant <paul.durrant@citrix.com>

> ---
>  drivers/net/xen-netback/netback.c |   39 +++++++++++++++++---------------
> ----
>  1 files changed, 18 insertions(+), 21 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-
> netback/netback.c
> index e5284bc..438d0c0 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -240,7 +240,7 @@ static void xenvif_gop_frag_copy(struct xenvif *vif,
> struct sk_buff *skb,
>  	struct gnttab_copy *copy_gop;
>  	struct xenvif_rx_meta *meta;
>  	unsigned long bytes;
> -	int gso_type;
> +	int gso_type = XEN_NETIF_GSO_TYPE_NONE;
> 
>  	/* Data must not cross a page boundary. */
>  	BUG_ON(size + offset > PAGE_SIZE<<compound_order(page));
> @@ -299,12 +299,12 @@ static void xenvif_gop_frag_copy(struct xenvif *vif,
> struct sk_buff *skb,
>  		}
> 
>  		/* Leave a gap for the GSO descriptor. */
> -		if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4)
> -			gso_type = XEN_NETIF_GSO_TYPE_TCPV4;
> -		else if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6)
> -			gso_type = XEN_NETIF_GSO_TYPE_TCPV6;
> -		else
> -			gso_type = XEN_NETIF_GSO_TYPE_NONE;
> +		if (skb_is_gso(skb)) {
> +			if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4)
> +				gso_type = XEN_NETIF_GSO_TYPE_TCPV4;
> +			else if (skb_shinfo(skb)->gso_type &
> SKB_GSO_TCPV6)
> +				gso_type = XEN_NETIF_GSO_TYPE_TCPV6;
> +		}
> 
>  		if (*head && ((1 << gso_type) & vif->gso_mask))
>  			vif->rx.req_cons++;
> @@ -338,19 +338,15 @@ static int xenvif_gop_skb(struct sk_buff *skb,
>  	int head = 1;
>  	int old_meta_prod;
>  	int gso_type;
> -	int gso_size;
> 
>  	old_meta_prod = npo->meta_prod;
> 
> -	if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4) {
> -		gso_type = XEN_NETIF_GSO_TYPE_TCPV4;
> -		gso_size = skb_shinfo(skb)->gso_size;
> -	} else if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6) {
> -		gso_type = XEN_NETIF_GSO_TYPE_TCPV6;
> -		gso_size = skb_shinfo(skb)->gso_size;
> -	} else {
> -		gso_type = XEN_NETIF_GSO_TYPE_NONE;
> -		gso_size = 0;
> +	gso_type = XEN_NETIF_GSO_TYPE_NONE;
> +	if (skb_is_gso(skb)) {
> +		if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4)
> +			gso_type = XEN_NETIF_GSO_TYPE_TCPV4;
> +		else if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6)
> +			gso_type = XEN_NETIF_GSO_TYPE_TCPV6;
>  	}
> 
>  	/* Set up a GSO prefix descriptor, if necessary */
> @@ -358,7 +354,7 @@ static int xenvif_gop_skb(struct sk_buff *skb,
>  		req = RING_GET_REQUEST(&vif->rx, vif->rx.req_cons++);
>  		meta = npo->meta + npo->meta_prod++;
>  		meta->gso_type = gso_type;
> -		meta->gso_size = gso_size;
> +		meta->gso_size = skb_shinfo(skb)->gso_size;
>  		meta->size = 0;
>  		meta->id = req->id;
>  	}
> @@ -368,7 +364,7 @@ static int xenvif_gop_skb(struct sk_buff *skb,
> 
>  	if ((1 << gso_type) & vif->gso_mask) {
>  		meta->gso_type = gso_type;
> -		meta->gso_size = gso_size;
> +		meta->gso_size = skb_shinfo(skb)->gso_size;
>  	} else {
>  		meta->gso_type = XEN_NETIF_GSO_TYPE_NONE;
>  		meta->gso_size = 0;
> @@ -500,8 +496,9 @@ static void xenvif_rx_action(struct xenvif *vif)
>  			size = skb_frag_size(&skb_shinfo(skb)->frags[i]);
>  			max_slots_needed += DIV_ROUND_UP(size,
> PAGE_SIZE);
>  		}
> -		if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4 ||
> -		    skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6)
> +		if (skb_is_gso(skb) &&
> +		   (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4 ||
> +		    skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6))
>  			max_slots_needed++;
> 
>  		/* If the skb may not fit then bail out now */
> --
> 1.7.3.4
