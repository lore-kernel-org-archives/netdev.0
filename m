From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv1 net] xen-netback: use skb to determine number of
 required guest Rx requests
Date: Thu, 14 Jan 2016 16:54:56 -0500 (EST)
Message-ID: <20160114.165456.1025501284568544813.davem@davemloft.net>
References: <1452784710-11923-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	ian.campbell@citrix.com, wei.liu2@citrix.com
To: david.vrabel@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50463 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754082AbcANVy6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2016 16:54:58 -0500
In-Reply-To: <1452784710-11923-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Vrabel <david.vrabel@citrix.com>
Date: Thu, 14 Jan 2016 15:18:30 +0000

> -	needed = xenvif_rx_ring_slots_needed(queue->vif);
> +	skb = skb_peek(&queue->rx_queue);
> +	if (!skb)
> +		return false;
> +
> +	needed = DIV_ROUND_UP(skb->len, XEN_PAGE_SIZE);
> +	if (skb_is_gso(skb))
> +		needed++;

If I am not mistaken, we moved away from this kind of test exactly because
it is inaccurate and may under-estimate the needs.

It is possible for an N byte SKB to require N segments.  Therefore, the:

	DIV_ROUND_UP(skb->len, XEN_PAGE_SIZE);

calculation doesn't cut it.
