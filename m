From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [RFC PATCH 12/13] xen-netfront: implement TX persistent
 grants
Date: Mon, 18 May 2015 16:55:09 +0100
Message-ID: <555A0B5D.3090505@citrix.com>
References: <1431451117-70051-1-git-send-email-joao.martins@neclab.eu>
 <1431451117-70051-13-git-send-email-joao.martins@neclab.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, <ian.campbell@citrix.com>,
	<david.vrabel@citrix.com>, <boris.ostrovsky@oracle.com>
To: Joao Martins <joao.martins@neclab.eu>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:53588 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754145AbbERPzN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 11:55:13 -0400
In-Reply-To: <1431451117-70051-13-git-send-email-joao.martins@neclab.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/05/15 18:18, Joao Martins wrote:
> Instead of grant/revoking the buffer related to the skb, it will use
> an already granted page and memcpy  to it. The grants will be mapped
> by xen-netback and reused overtime, but only unmapped when the vif
> disconnects, as opposed to every packet.
> 
> This only happens if the backend supports persistent grants since it
> would, otherwise, introduce the overhead of a memcpy on top of the
> grant map.
[...]
> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
[...]
> @@ -1610,7 +1622,10 @@ static int xennet_init_queue(struct netfront_queue *queue)
>  	for (i = 0; i < NET_TX_RING_SIZE; i++) {
>  		skb_entry_set_link(&queue->tx_skbs[i], i+1);
>  		queue->grant_tx[i].ref = GRANT_INVALID_REF;
> -		queue->grant_tx[i].page = NULL;
> +		if (queue->info->feature_persistent)
> +			queue->grant_tx[i].page = alloc_page(GFP_NOIO);

Need to check for alloc failure here and unwind correctly?

Why NOIO?

> +		else
> +			queue->grant_tx[i].page = NULL;
>  	}
>  
>  	/* Clear out rx_skbs */
> 
