From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC] tulip: Support for byte queue limits
Date: Wed, 17 Jul 2013 16:42:07 +0100
Message-ID: <1374075727.3861.6.camel@bwh-desktop.uk.level5networks.com>
References: <20130717040959.24815.qmail@science.horizon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <eric.dumazet@gmail.com>, <grantgrundler@gmail.com>,
	<grundler@parisc-linux.org>, <netdev@vger.kernel.org>
To: George Spelvin <linux@horizon.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:59515 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754724Ab3GQPmL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jul 2013 11:42:11 -0400
In-Reply-To: <20130717040959.24815.qmail@science.horizon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-07-17 at 00:09 -0400, George Spelvin wrote:
> >>  	wmb();
> >>  
> >> -	tp->cur_tx++;
> >> -
> >>  	/* Trigger an immediate transmit demand. */
> >>  	iowrite32(0, tp->base_addr + CSR1);
> >>  
> >> +	tp->cur_tx++;
> >> +	netdev_sent_queue(dev, skb->len);
> >>  	spin_unlock_irqrestore(&tp->lock, flags);
> 
> > This is not good practice, because once you start DMA you have
> > effectively passed ownership of the skb to the TX completion handler.
> 
> Thank you for this advice.  Just to be clear, is the only issue reading
> skb->len from a potentially deallocated skb?

That's what I was thinking of.

> Or is it also going go
> give the byte queue system fits if the transmit complete handler calls
> netdev_completed_queue before the transmitter calls netdev_sent_queue?

I don't know.

> I'd hope it can underflow safely, and only look at the net value after
> the transmit handler returns.
> 
> > Presumably the TX completion handler will hold this spinlock and
> > therefore cannot free the skb before you use skb->len above.  So this
> > will be safe now.  But one day someone may want to get rid of this lock,
> > so this is a trap waiting to spring.
> 
> Sounds like a fun project.  But I have to dig into the BQL code; if it's
> getting and dropping locks inside netdev_*_queue, the win is limited.
> 
> (A lock-free version would have separate "sent" and "completed" counters,
> and compute the difference when a snapshot is required.)

Yes, it is lock-free with separate counters.  The implementation is in
lib/dynamic_queue_limits.c.  I think that the use of POSDIFF() protects
against races that could leave completed > sent.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
