From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] net/hsr: Add support for the High-availability
 Seamless Redundancy protocol (HSRv0)
Date: Fri, 20 Sep 2013 15:10:17 -0400 (EDT)
Message-ID: <20130920.151017.2125552741552759738.davem@davemloft.net>
References: <523A4F5E.9070503@xdin.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, joe@perches.com,
	jboticario@gmail.com, balferreira@googlemail.com,
	elias.molina@ehu.es
To: arvid.brodin@xdin.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39694 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753329Ab3ITTKV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Sep 2013 15:10:21 -0400
In-Reply-To: <523A4F5E.9070503@xdin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arvid Brodin <arvid.brodin@xdin.com>
Date: Thu, 19 Sep 2013 03:11:58 +0200

> +/* If dev is a HSR master, return 1; otherwise, return 0.
> + */
> +bool is_hsr_master(struct net_device *dev)

Bool takes on either 'true' or 'false', not '1' or '0'.

> +#if !defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS)
> +		/* We need to memmove the whole header to work around
> +		 * alignment problems caused by the 6-byte HSR tag.
> +		 */
> +		memmove(skb_deliver->data - HSR_TAGLEN, skb_deliver->data,
> +			skb_headlen(skb_deliver));
> +		skb_deliver->data -= HSR_TAGLEN;
> +		skb_deliver->tail -= HSR_TAGLEN;
> +#endif

You can't do this.

First of all, you have no idea if subtracting skb->data a given amount
will underflow the skb buffer start.  You aren't even checking, all
of the standard skb_*() data adjustment interfaces do.

Secondly, everything after the header is now at the wrong offset from
the beginning of the packet.

You will have to memmove() the entire packet if you want to realign
where it starts.
