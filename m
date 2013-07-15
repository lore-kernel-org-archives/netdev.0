From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC] tulip: Support for byte queue limits
Date: Tue, 16 Jul 2013 00:58:09 +0100
Message-ID: <1373932689.3745.30.camel@bwh-desktop.uk.level5networks.com>
References: <20130712180116.21176.qmail@science.horizon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <grantgrundler@gmail.com>, <eric.dumazet@gmail.com>,
	<grundler@parisc-linux.org>, <netdev@vger.kernel.org>
To: George Spelvin <linux@horizon.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:62898 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753834Ab3GOX6N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jul 2013 19:58:13 -0400
In-Reply-To: <20130712180116.21176.qmail@science.horizon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-07-12 at 14:01 -0400, George Spelvin wrote:
> > Hi George,
> > While you are right that functionally it doesn't matter, my preference
> > would be to have nothing between the wmb() and iowrite() that kicks
> > off the TX. This marginally helps kick off the TX process consistently
> > slightly sooner. On modern HW, probably irrelevant, but not on the HW
> > these chips are used on.
> 
> I'll revise it.  It just made sense to me to put it next to the other
> bookkeeping line of tp->cur_tx++.  Should I move them both below the
> iowrite()?  As in:
> 
> --- a/drivers/net/ethernet/dec/tulip/tulip_core.c
> +++ b/drivers/net/ethernet/dec/tulip/tulip_core.c
> @@ -702,11 +702,11 @@ tulip_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  	tp->tx_ring[entry].status = cpu_to_le32(DescOwned);
>  	wmb();
>  
> -	tp->cur_tx++;
> -
>  	/* Trigger an immediate transmit demand. */
>  	iowrite32(0, tp->base_addr + CSR1);
>  
> +	tp->cur_tx++;
> +	netdev_sent_queue(dev, skb->len);

This is not good practice, because once you start DMA you have
effectively passed ownership of the skb to the TX completion handler.

>  	spin_unlock_irqrestore(&tp->lock, flags);

Presumably the TX completion handler will hold this spinlock and
therefore cannot free the skb before you use skb->len above.  So this
will be safe now.  But one day someone may want to get rid of this lock,
so this is a trap waiting to spring.

Ben.

>  	return NETDEV_TX_OK;
> 
> > Lastly, given I haven't powered up a system in two years which has
> > tulip, any one want to take over maintainer for tulip driver?
> > It's basically obsolete with a few rare patches like this one coming in.
> 
> I'm not up to it myself, sorry.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
