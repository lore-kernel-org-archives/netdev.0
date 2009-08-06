From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next-2.6] net: relax dst refcnt in input path
Date: Thu, 06 Aug 2009 13:35:18 -0700 (PDT)
Message-ID: <20090806.133518.263376332.davem@davemloft.net>
References: <4A670469.2050404@gmail.com>
	<4A6708A6.1090200@trash.net>
	<4A6732D6.90809@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org, markmc@redhat.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55783
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751712AbZHFUfJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 16:35:09 -0400
In-Reply-To: <4A6732D6.90809@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 22 Jul 2009 17:40:06 +0200

> [PATCH net-next-2.6] net: relax dst refcnt in input path


Two things:

1) Don't use a boolean name like "noref" it results in using
   double-negatives in one's mind while trying to read and understand
   the code.

   Call these arguments "need_ref" or something like that.

   Also, use "bool" type.

2) I wonder about this:

> @@ -1700,9 +1700,15 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
>  		 * If device doesnt need skb->dst, release it right now while
>  		 * its hot in this cpu cache
>  		 */
> -		if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
> -			skb_dst_drop(skb);
> -
> +		if (skb_dst(skb)) {
> +			if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
> +				skb_dst_drop(skb);
> +			else
> +				/*
> +				 * make sure dst was refcounted by caller
> +				 */
> +				WARN_ON(!(skb->_skb_dst & SKB_DST_REFTAKEN));
> +		}
>  		rc = ops->ndo_start_xmit(skb, dev);
>  		if (rc == NETDEV_TX_OK)

So, won't this warning trigger if we are forwarding to a device that
does not set IFF_XMIT_DST_RELEASE?

If I understand things correctly, in IPv4 when we're not delivering to
a socket, we don't take a reference.

We'll get here from the forwarding path with a DST, and the target TX
device has IFF_XMIT_DST_RELEASE clear, the WARN_ON above will trigger.
