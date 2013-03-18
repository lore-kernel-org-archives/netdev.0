From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH 2/4] xen-netfront: drop skb when skb->len
 > 65535
Date: Mon, 18 Mar 2013 13:46:20 +0000
Message-ID: <51471AAC.2050509@citrix.com>
References: <1363602955-24790-1-git-send-email-wei.liu2@citrix.com> <1363602955-24790-3-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xen.org>,
	<annie.li@oracle.com>, <ian.campbell@citrix.com>,
	<konrad.wilk@oracle.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:52426 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752085Ab3CRNqX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 09:46:23 -0400
In-Reply-To: <1363602955-24790-3-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18/03/13 10:35, Wei Liu wrote:
> The `size' field of Xen network wire format is uint16_t, anything bigger than
> 65535 will cause overflow.

The backend needs to be able to handle these bad packets without
disconnecting the VIF -- we can't fix all the frontend drivers.

David

> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> ---
>  drivers/net/xen-netfront.c |   12 ++++++++++++
>  1 file changed, 12 insertions(+)
> 
> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> index 5527663..8c3d065 100644
> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -547,6 +547,18 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  	unsigned int len = skb_headlen(skb);
>  	unsigned long flags;
>  
> +	/*
> +	 * wire format of xen_netif_tx_request only supports skb->len
> +	 * < 64K, because size field in xen_netif_tx_request is
> +	 * uint16_t.
> +	 */
> +	if (unlikely(skb->len > (uint16_t)(~0))) {
> +		net_alert_ratelimited(
> +			"xennet: skb->len = %d, too big for wire format\n",
> +			skb->len);
> +		goto drop;
> +	}
> +
>  	slots = DIV_ROUND_UP(offset + len, PAGE_SIZE) +
>  		xennet_count_skb_frag_slots(skb);
>  	if (unlikely(slots > MAX_SKB_FRAGS + 1)) {
