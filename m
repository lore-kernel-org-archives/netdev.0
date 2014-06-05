From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net v2] xen-netback: Fix handling of skbs requiring too
 many slots
Date: Thu, 5 Jun 2014 11:07:34 +0100
Message-ID: <20140605100734.GM6043@zion.uk.xensource.com>
References: <1401908331-13297-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xen-devel@lists.xenproject.org>, <ian.campbell@citrix.com>,
	<wei.liu2@citrix.com>, <paul.durrant@citrix.com>,
	<linux@eikelenboom.it>, <netdev@vger.kernel.org>,
	<david.vrabel@citrix.com>, <davem@davemloft.net>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:37746 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750925AbaFEKHw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jun 2014 06:07:52 -0400
Content-Disposition: inline
In-Reply-To: <1401908331-13297-1-git-send-email-zoltan.kiss@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 04, 2014 at 07:58:51PM +0100, Zoltan Kiss wrote:
> A recent commit (a02eb4 "xen-netback: worse-case estimate in xenvif_rx_action is
> underestimating") capped the slot estimation to MAX_SKB_FRAGS, but that triggers
> the next BUG_ON a few lines down, as the packet consumes more slots than
> estimated.
> This patch introduces full_coalesce on the skb callback buffer, which is used in
> start_new_rx_buffer() to decide whether netback needs coalescing more
> aggresively. By doing that, no packet should need more than
> (XEN_NETIF_MAX_TX_SIZE + 1) / PAGE_SIZE data slots (excluding the optional GSO
> slot, it doesn't carry data, therefore irrelevant in this case), as the provided
> buffers are fully utilized.
> 

Acked-by: Wei Liu <wei.liu2@citrix.com>

Minor nit below.

[...]
> @@ -602,10 +611,14 @@ static void xenvif_rx_action(struct xenvif *vif)
>  
>  		/* To avoid the estimate becoming too pessimal for some
>  		 * frontends that limit posted rx requests, cap the estimate
> -		 * at MAX_SKB_FRAGS.
> +		 * at MAX_SKB_FRAGS. In this case netback will fully coalesce
> +		 * the skb into the provided slots.
>  		 */
> -		if (max_slots_needed > MAX_SKB_FRAGS)
> +		if (max_slots_needed > MAX_SKB_FRAGS) {
>  			max_slots_needed = MAX_SKB_FRAGS;
> +			XENVIF_RX_CB(skb)->full_coalesce = true;
> +		} else
> +			XENVIF_RX_CB(skb)->full_coalesce = false;
>  

Please enclose this line with {}, which is required by kernel coding
style.

Wei.
