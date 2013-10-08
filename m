From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next v2 5/5] xen-netback: enable IPv6 TCP GSO to the
 guest
Date: Tue, 8 Oct 2013 14:34:21 +0100
Message-ID: <20131008133421.GK28411@zion.uk.xensource.com>
References: <1381229896-18657-1-git-send-email-paul.durrant@citrix.com>
 <1381229896-18657-6-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:35542 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752785Ab3JHNen (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Oct 2013 09:34:43 -0400
Content-Disposition: inline
In-Reply-To: <1381229896-18657-6-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 08, 2013 at 11:58:16AM +0100, Paul Durrant wrote:
[...]
>  	/* Data must not cross a page boundary. */
>  	BUG_ON(size + offset > PAGE_SIZE<<compound_order(page));
> @@ -392,7 +393,14 @@ static void xenvif_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
>  		}
>  
>  		/* Leave a gap for the GSO descriptor. */
> -		if (*head && skb_shinfo(skb)->gso_size && !vif->gso_prefix)
> +		if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4)
> +			gso_type = XEN_NETIF_GSO_TYPE_TCPV4;
> +		else if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6)
> +			gso_type = XEN_NETIF_GSO_TYPE_TCPV6;
> +		else
> +			gso_type = 0;

Should probably #define XEN_NETIF_GSO_TYPE_NONE 0 instead of using plain
0?

> +	if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4) {
> +		gso_type = XEN_NETIF_GSO_TYPE_TCPV4;
> +		gso_size = skb_shinfo(skb)->gso_size;
> +	} else if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6) {
> +		gso_type = XEN_NETIF_GSO_TYPE_TCPV6;
> +		gso_size = skb_shinfo(skb)->gso_size;
> +	} else {
> +		gso_type = 0;

Ditto.

> -	if (!vif->gso_prefix)
> -		meta->gso_size = skb_shinfo(skb)->gso_size;
> -	else
> +	if ((1 << gso_type) & vif->gso_mask) {
> +		meta->gso_type = gso_type;
> +		meta->gso_size = gso_size;
> +	} else {
> +		meta->gso_type = 0;

Ditto.

>  		meta->gso_size = 0;
[...]
> @@ -573,15 +573,40 @@ static int connect_rings(struct backend_info *be)
>  		val = 0;
>  	vif->can_sg = !!val;
>  
> +	vif->gso_mask = 0;
> +	vif->gso_prefix_mask = 0;
> +
>  	if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-gso-tcpv4",
>  			 "%d", &val) < 0)
>  		val = 0;
> -	vif->gso = !!val;
> +	if (val)
> +		vif->gso_mask = 1 << XEN_NETIF_GSO_TYPE_TCPV4;

Not using "|=" ?

>  
>  	if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-gso-tcpv4-prefix",
>  			 "%d", &val) < 0)
>  		val = 0;
> -	vif->gso_prefix = !!val;
> +	if (val)
> +		vif->gso_prefix_mask = 1 << XEN_NETIF_GSO_TYPE_TCPV4;
> +
> +	if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-gso-tcpv6",
> +			 "%d", &val) < 0)
> +		val = 0;
> +	if (val)
> +		vif->gso_mask = 1 << XEN_NETIF_GSO_TYPE_TCPV6;
> +

Not using "|="? Are feature-gso_tcpv{4,6} mutually exclusive?

Same question goes to the setting of gso_prefix_mask.

Wei.
