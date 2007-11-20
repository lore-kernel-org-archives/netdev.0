From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 05/11] netpoll: dont need rx_flags
Date: Mon, 19 Nov 2007 19:39:28 -0800 (PST)
Message-ID: <20071119.193928.167909754.davem@davemloft.net>
References: <20071103184314.216145305@linux-foundation.org>
	<20071103184338.692312004@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: satyam@infradead.org, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47930
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752596AbXKTDj2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 22:39:28 -0500
In-Reply-To: <20071103184338.692312004@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Sat, 03 Nov 2007 11:43:19 -0700

> The rx_flags variable is redundant. Turning rx on/off is done
> via setting the rx_np pointer.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Not all of these transformations are equivalent, and as a result
you're adding a bug.

> @@ -51,12 +50,11 @@ static inline int netpoll_rx(struct sk_b
>  	unsigned long flags;
>  	int ret = 0;
>  
> -	if (!npinfo || (!npinfo->rx_np && !npinfo->rx_flags))
> +	if (!npinfo || !npinfo->rx_np)
>  		return 0;
>  
>  	spin_lock_irqsave(&npinfo->rx_lock, flags);
> -	/* check rx_flags again with the lock held */
> -	if (npinfo->rx_flags && __netpoll_rx(skb))
> +	if (__netpoll_rx(skb))
>  		ret = 1;
>  	spin_unlock_irqrestore(&npinfo->rx_lock, flags);

If you're using ->rx_np == NULL as your new guard, you have
to duplicate that test inside of holding the lock.

->rx_np goes to NULL under the lock, but in the previous code if
the rx_flags is set we know that ->rx_np is also NULL, that's
why it was OK to only recheck ->rx_flags in the lock and not
->rx_np as well.

Therefore we have to replace the test on ->rx_flags with ->rx_np in
all spots to retain correct semantics.

I've made this correction to your patch and applied it to net-2.6.25

Thanks.
